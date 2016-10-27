From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ip6_tunnel: Clear IP6CB(skb)->frag_max_size in
 ip4ip6_tnl_xmit()
Date: Thu, 27 Oct 2016 16:25:14 -0400 (EDT)
Message-ID: <20161027.162514.2259363994362412217.davem@davemloft.net>
References: <20161024150712.5133-1-elicooper@gmx.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: elicooper@gmx.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33708 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935293AbcJ0UZQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Oct 2016 16:25:16 -0400
In-Reply-To: <20161024150712.5133-1-elicooper@gmx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eli Cooper <elicooper@gmx.com>
Date: Mon, 24 Oct 2016 23:07:12 +0800

> diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
> index 202d16a..4110562 100644
> --- a/net/ipv6/ip6_tunnel.c
> +++ b/net/ipv6/ip6_tunnel.c
> @@ -1205,6 +1205,7 @@ ip4ip6_tnl_xmit(struct sk_buff *skb, struct net_device *dev)
>  	int err;
>  
>  	memset(&(IPCB(skb)->opt), 0, sizeof(IPCB(skb)->opt));
> +	IP6CB(skb)->frag_max_size = 0;
>  
>  	tproto = ACCESS_ONCE(t->parms.proto);
>  	if (tproto != IPPROTO_IPIP && tproto != 0)

This doesn't look right at all.

Either skb->cb is interpreted as IPCB() past this point, or
it is interpreted as IP6CB().

So pick which structure is used, and simply clear that specific
structure.
