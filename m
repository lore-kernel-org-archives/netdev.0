From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] [NET 2.6.26]: Add per-connection option to set max TSO
	frame size
Date: Fri, 29 Feb 2008 10:53:20 +0000
Message-ID: <20080229105319.GB4337@ff.dom.local>
References: <20080228183150.4431.81252.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, stephen.hemminger@vyatta.com,
	netdev@vger.kernel.org
To: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fk-out-0910.google.com ([209.85.128.185]:45884 "EHLO
	fk-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755328AbYB2KwP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Feb 2008 05:52:15 -0500
Received: by fk-out-0910.google.com with SMTP id z23so5245086fkz.5
        for <netdev@vger.kernel.org>; Fri, 29 Feb 2008 02:52:13 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20080228183150.4431.81252.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 28, 2008 at 10:31:50AM -0800, PJ Waskiewicz wrote:
...

Looks ...almost OK to me, but:

> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index a2f0032..b460fd3 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -724,6 +724,10 @@ struct net_device
>  	/* rtnetlink link ops */
>  	const struct rtnl_link_ops *rtnl_link_ops;
>  
> +	/* for setting kernel sock attribute on TCP connection setup */
> +#define GSO_MAX_SIZE		65536
> +	u32			gso_max_size;
> +

Now probably unsigned int should "suffice" too.

>  	/* The TX queue control structures */
>  	unsigned int			egress_subqueue_count;
>  	struct net_device_subqueue	egress_subqueue[1];
> @@ -1475,6 +1479,11 @@ static inline int netif_needs_gso(struct net_device *dev, struct sk_buff *skb)
>  		unlikely(skb->ip_summed != CHECKSUM_PARTIAL));
>  }
>  
> +static inline void netif_set_gso_max_size(struct net_device *dev, u16 size)

u16?

> +{
> +       dev->gso_max_size = size;

^^^^^^^^^^ a tab needed here.
...
> diff --git a/include/net/sock.h b/include/net/sock.h
> index 8a7889b..1c52822 100644
> --- a/include/net/sock.h
> +++ b/include/net/sock.h
...
> @@ -236,6 +237,7 @@ struct sock {
>  	gfp_t			sk_allocation;
>  	int			sk_route_caps;
>  	int			sk_gso_type;
> +	__u32			sk_gso_max_size;

unsigned int? But, actually I wonder if sk_gso_type and sk_gso_max_size
can't be two shorts yet?

Regards,
Jarek P.
