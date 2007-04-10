From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [PATCH 2/2] NET: Multiqueue network device support implementation.
Date: Tue, 10 Apr 2007 12:20:49 +0400
Message-ID: <20070410082049.GC16621@2ka.mipt.ru>
References: <20070409212723.31670.27976.stgit@gitlost.site> <20070409212841.31670.59366.stgit@gitlost.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, jgarzik@pobox.com, cramerj@intel.com,
	auke-jan.h.kok@intel.com, christopher.leech@intel.com
To: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:58314 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030470AbXDJIVf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Apr 2007 04:21:35 -0400
Content-Disposition: inline
In-Reply-To: <20070409212841.31670.59366.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 09, 2007 at 02:28:41PM -0700, Peter P Waskiewicz Jr (peter.p.waskiewicz.jr@intel.com) wrote:
> + 	alloc_size = (sizeof(struct net_device_subqueue) * queue_count);
> + 
> + 	p = kzalloc(alloc_size, GFP_KERNEL);
> + 	if (!p) {
> + 		printk(KERN_ERR "alloc_netdev: Unable to allocate queues.\n");
> + 		return NULL;

I think you either do not want to print it, or want additional details
about device...

> + 	}
> + 
> + 	dev->egress_subqueue = p;
> + 	dev->egress_subqueue_count = queue_count;
> +
>  	dev->get_stats = maybe_internal_stats;
>  	setup(dev);
>  	strcpy(dev->name, name);
>  	return dev;
>  }
> -EXPORT_SYMBOL(alloc_netdev);
> +EXPORT_SYMBOL(alloc_netdev_mq);
>  
>  /**
>   *	free_netdev - free network device
> @@ -3345,6 +3358,7 @@ void free_netdev(struct net_device *dev)
>  {
>  #ifdef CONFIG_SYSFS
>  	/*  Compatibility with error handling in drivers */
> +	kfree((char *)dev->egress_subqueue);
>  	if (dev->reg_state == NETREG_UNINITIALIZED) {
>  		kfree((char *)dev - dev->padded);
>  		return;
> @@ -3356,6 +3370,7 @@ void free_netdev(struct net_device *dev)
>  	/* will free via device release */
>  	put_device(&dev->dev);
>  #else
> +	kfree((char *)dev->egress_subqueue);

Still casting :)


-- 
	Evgeniy Polyakov
