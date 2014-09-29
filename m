From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH][net-next] ipv4: unnecessary to set err on no_route
 path
Date: Mon, 29 Sep 2014 22:30:03 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1409292224230.2304@ja.home.ssi.bg>
References: <1411982198-17416-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:41018 "EHLO ja.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751176AbaI2TaI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Sep 2014 15:30:08 -0400
In-Reply-To: <1411982198-17416-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Mon, 29 Sep 2014, roy.qing.li@gmail.com wrote:

> From: Li RongQing <roy.qing.li@gmail.com>
> 
> When the code skips to no_route label, it will skip to local_input at last,
> then err will be reset on the local_input path before exit function.

	But local_input saves -err into rth->dst.error,
the places you change provided more-specific error code.

> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
> ---
>  net/ipv4/route.c |   11 ++++-------
>  1 file changed, 4 insertions(+), 7 deletions(-)
> 
> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> index d4bd68d..403914b 100644
> --- a/net/ipv4/route.c
> +++ b/net/ipv4/route.c
> @@ -1704,11 +1704,9 @@ static int ip_route_input_slow(struct sk_buff *skb, __be32 daddr, __be32 saddr,
>  	fl4.daddr = daddr;
>  	fl4.saddr = saddr;
>  	err = fib_lookup(net, &fl4, &res);
> -	if (err != 0) {
> -		if (!IN_DEV_FORWARD(in_dev))
> -			err = -EHOSTUNREACH;
> +	if (err != 0)
>  		goto no_route;
> -	}
> +
>  
>  	if (res.type == RTN_BROADCAST)
>  		goto brd_input;
> @@ -1721,10 +1719,9 @@ static int ip_route_input_slow(struct sk_buff *skb, __be32 daddr, __be32 saddr,
>  		goto local_input;
>  	}
>  
> -	if (!IN_DEV_FORWARD(in_dev)) {
> -		err = -EHOSTUNREACH;
> +	if (!IN_DEV_FORWARD(in_dev))
>  		goto no_route;
> -	}
> +
>  	if (res.type != RTN_UNICAST)
>  		goto martian_destination;
>  
> -- 
> 1.7.10.4

Regards

--
Julian Anastasov <ja@ssi.bg>
