get '/' do
  erb :index
end

get '/sign_in' do
  # the `request_token` method is defined in `app/helpers/oauth.rb`
  redirect request_token.authorize_url
end

get '/sign_out' do
  session.clear
  redirect '/'
end

get '/auth' do
  # the `request_token` method is defined in `app/helpers/oauth.rb`
  @access_token = request_token.get_access_token(:oauth_verifier => params[:oauth_verifier])
  # our request token is only valid until we use it to get an access token, so let's delete it from our session
  session.delete(:request_token)

  if @user = User.find_by_username(@access_token.params[:screen_name]) == nil
    @user = User.new(username: @access_token.params[:screen_name], oauth_token: @access_token.token, oauth_secret: @access_token.secret)
    if @user.save
      session[:user_id] = @user.id
      erb :index
    else
      redirect '/'
    end
  else
    session[:user_id] = User.find_by_username(@access_token.params[:screen_name]).id
   erb :index
 end

end

post '/tweet' do
  user = User.find(session[:user_id])
  twitter_user = Twitter::Client.new(oauth_token: user.oauth_token, oauth_token_secret: user.oauth_secret)
  @tweet = twitter_user.update(params[:tweet_data])
  p @tweet
  erb :tweet
end