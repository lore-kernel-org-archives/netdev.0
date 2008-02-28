From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] [NET 2.6.26]: Add per-connection option to set max TSO
	frame   size
Date: Thu, 28 Feb 2008 08:07:46 +0000
Message-ID: <20080228080746.GA7067@ff.dom.local>
References: <20080227172606.4446.97153.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, stephen.hemminger@vyatta.com,
	netdev@vger.kernel.org
To: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.171]:38790 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753314AbYB1IGr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Feb 2008 03:06:47 -0500
Received: by ug-out-1314.google.com with SMTP id z38so178443ugc.16
        for <netdev@vger.kernel.org>; Thu, 28 Feb 2008 00:06:43 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20080227172606.4446.97153.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 27-02-2008 18:26, PJ Waskiewicz wrote:
...
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index a2f0032..3bf825b 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -620,6 +620,7 @@ struct net_device
>  
>  	/* Partially transmitted GSO packet. */
>  	struct sk_buff		*gso_skb;
> +	u16			max_gso_frame_size;
...
> +static inline void netif_set_max_gso_size(struct net_device *dev, u16 size)
> +	__u16			sk_gso_max_size;
>  	int			sk_rcvlowat;
>  	unsigned long 		sk_flags;
>  	unsigned long	        sk_lingertime;
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 908f07c..689a678 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -4021,6 +4021,7 @@ struct net_device *alloc_netdev_mq(int sizeof_priv, const char *name,
>  	}
>  
>  	dev->egress_subqueue_count = queue_count;
> +	dev->max_gso_frame_size = 65536;

Does it fit into u16?

Isn't it "nicer" with some constant (#define MAX_GSO_FRAME_SIZE ...)?

Why not more consistent names, e.g.:
dev->gso_max_size;
sk_gso_max_size;
netif_set_gso_max_size()
(GSO_MAX_SIZE)
or
dev->max_gso_frame_size;
sk_max_gso_frame_size;
netif_set_max_gso_frame_size()
(MAX_GSO_FRAME_SIZE)
etc.?

Regards,
Jarek P.
