From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 2/3] NET: [CORE] Stack changes to add multiqueue hardware
 support API
Date: Sun, 24 Jun 2007 14:00:04 +0200
Message-ID: <467E5CC4.8070503@trash.net>
References: <20070623213614.18241.45511.stgit@localhost.localdomain> <20070623213628.18241.51876.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, jeff@garzik.org,
	auke-jan.h.kok@intel.com, hadi@cyberus.ca
To: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:41489 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754297AbXFXMAG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Jun 2007 08:00:06 -0400
In-Reply-To: <20070623213628.18241.51876.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

PJ Waskiewicz wrote:
> +struct net_device *alloc_netdev_mq(int sizeof_priv, const char *name,
> +		void (*setup)(struct net_device *), int queue_count)
>  {
>  	void *p;
>  	struct net_device *dev;
> @@ -3361,7 +3368,9 @@ struct net_device *alloc_netdev(int sizeof_priv, const char *name,
>  	BUG_ON(strlen(name) >= sizeof(dev->name));
>  
>  	/* ensure 32-byte alignment of both the device and private area */
> -	alloc_size = (sizeof(*dev) + NETDEV_ALIGN_CONST) & ~NETDEV_ALIGN_CONST;
> +	alloc_size = (sizeof(*dev) + NETDEV_ALIGN_CONST +
> +		     (sizeof(struct net_device_subqueue) * (queue_count - 1))) &


Why queue_count - 1 ? It should be queue_count I think.


Otherwise ACK for this patch except that it should also contain the
sch_generic changes.
