From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH 1/2] [RFC] NET: Implement a standard ndev_printk family
Date: Fri, 8 Jun 2007 16:24:15 -0700
Message-ID: <20070608162415.1481dfec@localhost.localdomain>
References: <20070608220007.31573.14931.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org, davem@davemloft.net,
	arjan@linux.intel.com
To: Auke Kok <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:50582 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754406AbXFHXY1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jun 2007 19:24:27 -0400
In-Reply-To: <20070608220007.31573.14931.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


>  
> +#define ndev_printk(kern_level, netif_level, netdev, format, arg...) \
> +	do { if ((netdev)->msg_enable & NETIF_MSG_##netif_level) { \
> +		printk(kern_level "%s: " format, \
> +		(netdev)->name, ## arg); } } while (0)

Could you make a version that doesn't evaluate the arguments twice?

> +#ifdef DEBUG
> +#define ndev_dbg(level, netdev, format, arg...) \
> +	ndev_printk(KERN_DEBUG, level, netdev, format, ## arg)
> +#else
> +#define ndev_dbg(level, netdev, format, arg...) \
> +	do { (void)(netdev); } while (0)
> +#endif
> +
> +#define ndev_err(level, netdev, format, arg...) \
> +	ndev_printk(KERN_ERR, level, netdev, format, ## arg)
> +#define ndev_info(level, netdev, format, arg...) \
> +	ndev_printk(KERN_INFO, level, netdev, format, ## arg)
> +#define ndev_warn(level, netdev, format, arg...) \
> +	ndev_printk(KERN_WARNING, level, netdev, format, ## arg)
> +#define ndev_notice(level, netdev, format, arg...) \
> +	ndev_printk(KERN_NOTICE, level, netdev, format, ## arg)
> +
>  #define netif_msg_drv(p)	((p)->msg_enable & NETIF_MSG_DRV)
>  #define netif_msg_probe(p)	((p)->msg_enable & NETIF_MSG_PROBE)
>  #define netif_msg_link(p)	((p)->msg_enable & NETIF_MSG_LINK)
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 5a7f20f..e854c09 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -3376,6 +3376,16 @@ struct net_device *alloc_netdev(int sizeof_priv, const char *name,
>  		dev->priv = netdev_priv(dev);
>  
>  	dev->get_stats = internal_stats;
> +	dev->msg_enable = NETIF_MSG_DRV | NETIF_MSG_PROBE | NETIF_MSG_LINK;
> +#ifdef DEBUG
> +	/* put these to good use: */
> +	dev->msg_enable |= NETIF_MSG_TIMER | NETIF_MSG_IFDOWN |
> +	                   NETIF_MSG_IFUP | NETIF_MSG_RX_ERR |
> +	                   NETIF_MSG_TX_ERR | NETIF_MSG_TX_QUEUED |
> +	                   NETIF_MSG_INTR | NETIF_MSG_TX_DONE |
> +	                   NETIF_MSG_RX_STATUS | NETIF_MSG_PKTDATA |
> +	                   NETIF_MSG_HW | NETIF_MSG_WOL;
> +#endif

Let driver writer choose message enable bits please.



-- 
Stephen Hemminger <shemminger@linux-foundation.org>
