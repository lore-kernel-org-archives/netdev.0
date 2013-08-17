From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH ipsec 1/3] ipv6: wire up skb->encapsulation
Date: Sat, 17 Aug 2013 20:07:38 +0200
Message-ID: <20130817180738.GA24518@order.stressinduktion.org>
References: <20130817175116.GA7001@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, steffen.klassert@secunet.com,
	yoshfuji@linux-ipv6.org, nicolas.dichtel@6wind.com
To: horms@verge.net.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:57944 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754006Ab3HQSHj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Aug 2013 14:07:39 -0400
Content-Disposition: inline
In-Reply-To: <20130817175116.GA7001@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Simon!

On Sat, Aug 17, 2013 at 07:51:16PM +0200, Hannes Frederic Sowa wrote:
> When pushing a new header before current one call skb_reset_inner_headers
> to record the position of the inner headers in the various ipv6 tunnel
> protocols.
> 
> We later need this to correctly identify the addresses needed to send
> back an error in the xfrm layer.
> 
> This change is safe, because skb->protocol is always checked before
> dereferencing data from the inner protocol.
> 
> Cc: Steffen Klassert <steffen.klassert@secunet.com>
> Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> ---
> 
> This patch is based on Steffen Klassert's ipsec tree.
> 
>  net/ipv6/ip6_gre.c    | 5 +++++
>  net/ipv6/ip6_tunnel.c | 6 ++++++
>  net/ipv6/sit.c        | 5 +++++
>  3 files changed, 16 insertions(+)
> 
> diff --git a/net/ipv6/ip6_gre.c b/net/ipv6/ip6_gre.c
> index ecd6073..90747f1 100644
> --- a/net/ipv6/ip6_gre.c
> +++ b/net/ipv6/ip6_gre.c
> @@ -724,6 +724,11 @@ static netdev_tx_t ip6gre_xmit2(struct sk_buff *skb,
>  		ipv6_push_nfrag_opts(skb, &opt.ops, &proto, NULL);
>  	}
>  
> +	if (likely(!skb->encapsulation)) {
> +		skb_reset_inner_headers(skb);
> +		skb->encapsulation = 1;
> +	}
> +

While doing these patches, I wondered how skb->inner_protocol will be
used in future (you added it in 0d89d2035fe063461a5ddb609b2c12e7fb006e44
("MPLS: Add limited GSO support")). Current use by tunnels seems safe to
me, but I wondered how you would extend its use?

Thanks,

  Hannes
