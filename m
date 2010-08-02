From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH v2 2/2] macvtap: Implement multiqueue macvtap driver
Date: Mon, 2 Aug 2010 17:52:28 +0200
Message-ID: <201008021752.28475.arnd@arndb.de>
References: <20100802143304.1517.42494.sendpatchset@krkumar2.in.ibm.com> <20100802143310.1517.55824.sendpatchset@krkumar2.in.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, bhutchings@solarflare.com,
	netdev@vger.kernel.org, mst@redhat.com, therbert@google.com
To: Krishna Kumar <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.10]:57925 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752654Ab0HBPws (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Aug 2010 11:52:48 -0400
In-Reply-To: <20100802143310.1517.55824.sendpatchset@krkumar2.in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 02 August 2010, Krishna Kumar wrote:
> Implement multiqueue facility for macvtap driver. The idea is that
> a macvtap device can be opened multiple times and the fd's can be
> used to register eg, as backend for vhost.
>
> Please review.

Only two very minor points from my side:

> diff -ruNp org/include/linux/netdevice.h new/include/linux/netdevice.h
> --- org/include/linux/netdevice.h	2010-07-25 16:57:07.000000000 +0530
> +++ new/include/linux/netdevice.h	2010-08-02 16:05:57.000000000 +0530
> @@ -2253,6 +2253,7 @@ static inline const char *netdev_name(co
>  	return dev->name;
>  }
>  
> +extern int skb_calculate_flow(struct net_device *dev, struct sk_buff *skb);
>  extern int netdev_printk(const char *level, const struct net_device *dev,
>  			 const char *format, ...)
>  	__attribute__ ((format (printf, 3, 4)));

This logically belongs into the first patch.

> diff -ruNp org/include/linux/if_macvlan.h new/include/linux/if_macvlan.h
> --- org/include/linux/if_macvlan.h	2010-08-02 15:32:33.000000000 +0530
> +++ new/include/linux/if_macvlan.h	2010-08-02 15:32:33.000000000 +0530
> @@ -40,6 +40,14 @@ struct macvlan_rx_stats {
>  	unsigned long		rx_errors;
>  };
>  
> +#define MIN(x, y)		(((x) < (y)) ? (x) : (y))
> +
> +/*
> + * Maximum times a macvtap device can be opened. This can be used to
> + * configure the number of receive queue, e.g. for multiqueue virtio.
> + */
> +#define MAX_MACVTAP_QUEUES	MIN(16, NR_CPUS)
> +

Please use the existing min() or min_t() macro instead of providing your own.

	Arnd
