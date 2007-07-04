From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 2/4] net: use numa_node in net_devcice->dev instead of parent
Date: Wed, 4 Jul 2007 09:51:20 +0100
Message-ID: <20070704085120.GB19515@infradead.org>
References: <200706291330.37070.yinghai.lu@sun.com> <468ABF92.5030800@sun.com> <20070703143407.7e4232f8@freepuppy.localdomain.hemminger.net> <200707031730.51677.yinghai.lu@sun.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Andi Kleen <ak@suse.de>, Greg KH <greg@kroah.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Yinghai Lu <Yinghai.Lu@Sun.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:33920 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758635AbXGDIvZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jul 2007 04:51:25 -0400
Content-Disposition: inline
In-Reply-To: <200707031730.51677.yinghai.lu@sun.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 03, 2007 at 05:30:51PM -0700, Yinghai Lu wrote:
> [PATCH 2/4] net: use numa_node in net_devcice->dev instead of parent
> 
> Signed-off-by: Yinghai Lu <yinghai.lu@sun.com>
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index 27cfe5f..005cc1c 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -217,7 +217,7 @@ nodata:
>  struct sk_buff *__netdev_alloc_skb(struct net_device *dev,
>  		unsigned int length, gfp_t gfp_mask)
>  {
> -	int node = dev->dev.parent ? dev_to_node(dev->dev.parent) : -1;
> +	int node = dev_to_node(&dev->dev);

This looks wrong to me unless the device model has once again changed
silently.  When I wrote this code &dev->dev was a device allocated
as part of the netdevice and the parent is the pci (or whatever) device
that has the node information.

