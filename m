From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] net: Check the argument for listen(2)
Date: Fri, 28 Jun 2013 09:33:23 -0700
Message-ID: <1372437203.3301.288.camel@edumazet-glaptop>
References: <1372436577-61749-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f51.google.com ([74.125.83.51]:60388 "EHLO
	mail-ee0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751511Ab3F1QdP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Jun 2013 12:33:15 -0400
Received: by mail-ee0-f51.google.com with SMTP id e52so1124951eek.38
        for <netdev@vger.kernel.org>; Fri, 28 Jun 2013 09:33:14 -0700 (PDT)
In-Reply-To: <1372436577-61749-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2013-06-29 at 00:22 +0800, Changli Gao wrote:
> As we use u16 to save the value of the argument for listen(2),
> we'd better check if the value is larger than SINT_MAX other
> than cut it down silently on error.
> ---
>  net/ipv4/af_inet.c |    3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
> index b4d0be2..35aaf00 100644
> --- a/net/ipv4/af_inet.c
> +++ b/net/ipv4/af_inet.c
> @@ -198,6 +198,9 @@ int inet_listen(struct socket *sock, int backlog)
>  	unsigned char old_state;
>  	int err;
>  
> +	if (backlog >= (1 << 16))
> +		return -EINVAL;
> +
>  	lock_sock(sk);
>  
>  	err = -EINVAL;


Well, there is still this possible regression for old applications.

Just use u32 fields instead of u16 ?
