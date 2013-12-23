From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] net: rose: restore old recvmsg behavior
Date: Mon, 23 Dec 2013 04:17:06 +0100
Message-ID: <20131223031706.GL14073@order.stressinduktion.org>
References: <1387755151-9653-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:46791 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757004Ab3LWDRH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Dec 2013 22:17:07 -0500
Content-Disposition: inline
In-Reply-To: <1387755151-9653-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 23, 2013 at 12:32:31AM +0100, Florian Westphal wrote:
> --- a/net/rose/af_rose.c
> +++ b/net/rose/af_rose.c
> @@ -1253,6 +1253,7 @@ static int rose_recvmsg(struct kiocb *iocb, struct socket *sock,
>  
>  	if (msg->msg_name) {
>  		struct sockaddr_rose *srose;
> +		struct full_sockaddr_rose *full_srose = msg->msg_name;
>  
>  		memset(msg->msg_name, 0, sizeof(struct full_sockaddr_rose));
>  		srose = msg->msg_name;
> @@ -1260,18 +1261,9 @@ static int rose_recvmsg(struct kiocb *iocb, struct socket *sock,
>  		srose->srose_addr   = rose->dest_addr;
>  		srose->srose_call   = rose->dest_call;
>  		srose->srose_ndigis = rose->dest_ndigis;
> -		if (msg->msg_namelen >= sizeof(struct full_sockaddr_rose)) {
> -			struct full_sockaddr_rose *full_srose = (struct full_sockaddr_rose *)msg->msg_name;
> -			for (n = 0 ; n < rose->dest_ndigis ; n++)
> -				full_srose->srose_digis[n] = rose->dest_digis[n];
> -			msg->msg_namelen = sizeof(struct full_sockaddr_rose);
> -		} else {
> -			if (rose->dest_ndigis >= 1) {
> -				srose->srose_ndigis = 1;
> -				srose->srose_digi = rose->dest_digis[0];
> -			}
> -			msg->msg_namelen = sizeof(struct sockaddr_rose);
> -		}
> +		for (n = 0 ; n < rose->dest_ndigis ; n++)
> +			full_srose->srose_digis[n] = rose->dest_digis[n];
> +		msg->msg_namelen = sizeof(struct full_sockaddr_rose);
>  	}
>  
>  	skb_free_datagram(sk, skb);

Looks good. I guess we want to push that to stable, too?

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
