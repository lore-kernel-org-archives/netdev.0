From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] ip_gre: include route header_len in max_headroom
	calculation
Date: Sat, 20 Mar 2010 20:37:36 +0800
Message-ID: <20100320123736.GC1930@gondor.apana.org.au>
References: <1269088078-7343-1-git-send-email-timo.teras@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Timo Teras <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:33201 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752086Ab0CTMhj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Mar 2010 08:37:39 -0400
Content-Disposition: inline
In-Reply-To: <1269088078-7343-1-git-send-email-timo.teras@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Mar 20, 2010 at 02:27:58PM +0200, Timo Teras wrote:
>
> diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
> index f47c9f7..f78402d 100644
> --- a/net/ipv4/ip_gre.c
> +++ b/net/ipv4/ip_gre.c
> @@ -810,11 +810,13 @@ static netdev_tx_t ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev
>  			tunnel->err_count = 0;
>  	}
>  
> -	max_headroom = LL_RESERVED_SPACE(tdev) + gre_hlen;
> +	max_headroom = LL_RESERVED_SPACE(tdev) + gre_hlen + rt->u.dst.header_len;
>  
>  	if (skb_headroom(skb) < max_headroom || skb_shared(skb)||
>  	    (skb_cloned(skb) && !skb_clone_writable(skb, 0))) {
>  		struct sk_buff *new_skb = skb_realloc_headroom(skb, max_headroom);
> +		if (max_headroom > dev->needed_headroom)
> +			dev->needed_headroom = max_headroom;

Are you sure about this? LL_RESERVED_SPACE already includes
dev->needed_headroom so won't this get bigger each time?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
