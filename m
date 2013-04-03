From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] MPLS: Add limited GSO support
Date: Wed, 3 Apr 2013 16:59:40 +0100
Message-ID: <1365004780.2897.3.camel@bwh-desktop.uk.solarflarecom.com>
References: <1364966697-20131-1-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <dev@openvswitch.org>, <netdev@vger.kernel.org>,
	Jesse Gross <jesse@nicira.com>,
	Pravin B Shelar <pshelar@nicira.com>
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:6862 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756083Ab3DCP7r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Apr 2013 11:59:47 -0400
In-Reply-To: <1364966697-20131-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I don't know anything about MPLS so this is a pretty superficial review.

On Wed, 2013-04-03 at 14:24 +0900, Simon Horman wrote:
[...]
> --- a/include/linux/netdev_features.h
> +++ b/include/linux/netdev_features.h
> @@ -43,6 +43,7 @@ enum {
>  	NETIF_F_FSO_BIT,		/* ... FCoE segmentation */
>  	NETIF_F_GSO_GRE_BIT,		/* ... GRE with TSO */
>  	NETIF_F_GSO_UDP_TUNNEL_BIT,	/* ... UDP TUNNEL with TSO */
> +	NETIF_F_GSO_MPLS_BIT,		/* ... MPLS segmentation */
>  	/**/NETIF_F_GSO_LAST =		/* last bit, see GSO_MASK */
>  		NETIF_F_GSO_UDP_TUNNEL_BIT,

You need to change NETIF_F_GSO_LAST as well.

[...]
> --- a/include/linux/skbuff.h
> +++ b/include/linux/skbuff.h
[...]
> @@ -2789,12 +2791,17 @@ static inline struct sec_path *skb_sec_path(struct sk_buff *skb)
>  }
>  #endif
>  
> -/* Keeps track of mac header offset relative to skb->head.
> - * It is useful for TSO of Tunneling protocol. e.g. GRE.
> - * For non-tunnel skb it points to skb_mac_header() and for
> - * tunnel skb it points to outer mac header. */
>  struct skb_gso_cb {
> +	/* Keeps track of mac header offset relative to skb->head.
> +	 * It is useful for TSO of Tunneling protocol. e.g. GRE.
> +	 * For non-tunnel skb it points to skb_mac_header() and for
> +	 * tunnel skb it points to outer mac header. */
>  	int mac_offset;
> +
> +	/* Keeps track of the ethernet type of an encapsualted
[...]

Typo: 'encapsualted' should be 'encapsulated'.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
