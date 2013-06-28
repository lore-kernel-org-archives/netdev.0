From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: Check the argument for listen(2)
Date: Fri, 28 Jun 2013 09:29:02 -0700
Message-ID: <1372436942.3301.286.camel@edumazet-glaptop>
References: <1372436076-61436-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f176.google.com ([209.85.215.176]:46006 "EHLO
	mail-ea0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755797Ab3F1Q2z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Jun 2013 12:28:55 -0400
Received: by mail-ea0-f176.google.com with SMTP id z15so1134336ead.21
        for <netdev@vger.kernel.org>; Fri, 28 Jun 2013 09:28:54 -0700 (PDT)
In-Reply-To: <1372436076-61436-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2013-06-29 at 00:14 +0800, Changli Gao wrote:
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
> +		return EINVAL;
> +
>  	lock_sock(sk);
>  
>  	err = -EINVAL;

This seems pretty buggy to me.

1) EINVAL is not -EINVAL

2) This might break existing applications.
