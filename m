From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 6/7] neigh: Add device constructor/destructor
 capability.
Date: Thu, 1 Dec 2011 19:08:35 +0000
Message-ID: <1322766515.2797.0.camel@bwh-desktop>
References: <20111130.224151.1479303742039627135.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:59224 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755974Ab1LATIm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2011 14:08:42 -0500
In-Reply-To: <20111130.224151.1479303742039627135.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-11-30 at 22:41 -0500, David Miller wrote:
> If the neigh entry has device private state, it will need
> constructor/destructor ops.
> 
> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---
>  include/linux/netdevice.h |    2 ++
>  net/core/neighbour.c      |   15 ++++++++++++++-
>  2 files changed, 16 insertions(+), 1 deletions(-)
> 
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index 5462c2c..1c4ddb3 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -974,6 +974,8 @@ struct net_device_ops {
>  						    netdev_features_t features);
>  	int			(*ndo_set_features)(struct net_device *dev,
>  						    netdev_features_t features);
> +	int			(*ndo_neigh_construct)(struct neighbour *n);
> +	int			(*ndo_neigh_destroy)(struct neighbour *n);

ndo_neigh_destroy should return void, since the return value is not
used:

[...]
> @@ -707,7 +717,10 @@ void neigh_destroy(struct neighbour *neigh)
>  	skb_queue_purge(&neigh->arp_queue);
>  	neigh->arp_queue_len_bytes = 0;
>  
> -	dev_put(neigh->dev);
> +	if (dev->netdev_ops->ndo_neigh_destroy)
> +		dev->netdev_ops->ndo_neigh_destroy(neigh);
> +
> +	dev_put(dev);
>  	neigh_parms_put(neigh->parms);
>  
>  	NEIGH_PRINTK2("neigh %p is destroyed.\n", neigh);

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
