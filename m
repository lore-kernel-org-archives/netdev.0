From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 02/11] net: add function to allocate skbuff head
 without data area
Date: Sun, 04 Sep 2011 10:12:18 +0200
Message-ID: <1315123938.2635.1.camel@edumazet-laptop>
References: <1315070771-18576-1-git-send-email-kaber@trash.net>
	 <1315070771-18576-3-git-send-email-kaber@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1315070771-18576-3-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le samedi 03 septembre 2011 =C3=A0 19:26 +0200, kaber@trash.net a =C3=A9=
crit :

> +struct sk_buff *__alloc_skb_head(gfp_t gfp_mask, int node)
> +{
> +	struct sk_buff *skb;
> +
> +	/* Get the HEAD */
> +	skb =3D kmem_cache_alloc_node(skbuff_head_cache,
> +				    gfp_mask & ~__GFP_DMA, node);
> +	if (!skb)
> +		goto out;
> +	prefetchw(skb);

Please remove this prefetchw(), since we have no delay between it and
actual memset(skb).

> +
> +	/*
> +	 * Only clear those fields we need to clear, not those that we will
> +	 * actually initialise below. Hence, don't put any more fields afte=
r
> +	 * the tail pointer in struct sk_buff!
> +	 */
> +	memset(skb, 0, offsetof(struct sk_buff, tail));



--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
