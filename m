From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH net-next] socket: use iov_length()
Date: Thu, 15 Jan 2015 21:45:20 +0000
Message-ID: <20150115214519.GB29656@ZenIV.linux.org.uk>
References: <1421230070-4104-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:53187 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751510AbbAOVpX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2015 16:45:23 -0500
Content-Disposition: inline
In-Reply-To: <1421230070-4104-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 14, 2015 at 11:07:50AM +0100, Nicolas Dichtel wrote:
> Better to use available helpers.
> 
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> ---
>  net/socket.c | 8 ++------
>  1 file changed, 2 insertions(+), 6 deletions(-)
> 
> diff --git a/net/socket.c b/net/socket.c
> index a2c33a4dc7ba..b1f3fa4da020 100644
> --- a/net/socket.c
> +++ b/net/socket.c
> @@ -883,10 +883,8 @@ static ssize_t do_sock_read(struct msghdr *msg, struct kiocb *iocb,
>  {
>  	struct socket *sock = file->private_data;
>  	size_t size = 0;
> -	int i;
>  
> -	for (i = 0; i < nr_segs; i++)
> -		size += iov[i].iov_len;
> +	size = iov_length(iov, nr_segs);

What's wrong with size = iocb->ki_nbytes instead of calling anything?
