From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] gro: __napi_gro_receive() optimizations
Date: Wed, 25 Aug 2010 13:57:26 -0700 (PDT)
Message-ID: <20100825.135726.189708768.davem@davemloft.net>
References: <1282768431.2681.144.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52670
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752600Ab0HYU5M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Aug 2010 16:57:12 -0400
In-Reply-To: <1282768431.2681.144.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 25 Aug 2010 22:33:51 +0200

> @@ -102,19 +102,9 @@ vlan_gro_common(struct napi_struct *napi, struct vlan_group *grp,
>  	if (vlan_dev)
>  		skb->dev = vlan_dev;
>  	else if (vlan_id)
> -		goto drop;
> -
> -	for (p = napi->gro_list; p; p = p->next) {
> -		NAPI_GRO_CB(p)->same_flow =
> -			p->dev == skb->dev && !compare_ether_header(
> -				skb_mac_header(p), skb_gro_mac_header(skb));
> -		NAPI_GRO_CB(p)->flush = 0;
> -	}
> -
> -	return dev_gro_receive(napi, skb);
> +		return GRO_DROP;
>  
> -drop:
> -	return GRO_DROP;
> +	return __napi_gro_receive(napi, skb);

I was looking at this the other day and considering something
similar but I didn't do it because this now makes the call chain
deeper.

And that can make a performance difference.

I don't want to add this hunk unless some GRO perf regression tests
are done.

Thanks.
