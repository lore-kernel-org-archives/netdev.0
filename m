From: Divy Le Ray <divy@chelsio.com>
Subject: Re: cxgb3: Replace LRO with GRO
Date: Fri, 13 Mar 2009 00:28:52 -0700
Message-ID: <49BA0B34.7050502@chelsio.com>
References: <20090120101418.13898.57172.stgit@speedy5> <20090121082937.GA1116@gondor.apana.org.au> <49783F7E.6000202@chelsio.com> <20090216033644.GA14431@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:27713 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750975AbZCMH3R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2009 03:29:17 -0400
In-Reply-To: <20090216033644.GA14431@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> When you can get a chance can you see if this patch makes any
> difference at all?

Hi Herbert,

Sorry for the delay.
I had to switch to different development platforms.
I've not seen much perf change with this patch, it looks good though.

Cheers,
Divy

> 
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index d7efaf9..6a542fa 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -2586,8 +2586,10 @@ int skb_gro_receive(struct sk_buff **head, struct sk_buff *skb)
>  {
>  	struct sk_buff *p = *head;
>  	struct sk_buff *nskb;
> +	skb_frag_t *frag;
>  	unsigned int headroom;
>  	unsigned int len = skb_gro_len(skb);
> +	int i;
>  
>  	if (p->len + len >= 65536)
>  		return -E2BIG;
> @@ -2604,9 +2606,9 @@ int skb_gro_receive(struct sk_buff **head, struct sk_buff *skb)
>  		skb_shinfo(skb)->frags[0].size -=
>  			skb_gro_offset(skb) - skb_headlen(skb);
>  
> -		memcpy(skb_shinfo(p)->frags + skb_shinfo(p)->nr_frags,
> -		       skb_shinfo(skb)->frags,
> -		       skb_shinfo(skb)->nr_frags * sizeof(skb_frag_t));
> +		frag = skb_shinfo(p)->frags + skb_shinfo(p)->nr_frags;
> +		for (i = 0; i < skb_shinfo(skb)->nr_frags; i++)
> +			*frag++ = skb_shinfo(skb)->frags[i];
>  
>  		skb_shinfo(p)->nr_frags += skb_shinfo(skb)->nr_frags;
>  		skb_shinfo(skb)->nr_frags = 0;
> 
> Thanks,

