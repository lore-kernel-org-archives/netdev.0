From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/4] net: use numa_node in net_devcice->dev instead of
 parent
Date: Wed, 04 Jul 2007 03:35:30 -0700 (PDT)
Message-ID: <20070704.033530.105423846.davem@davemloft.net>
References: <20070703143407.7e4232f8@freepuppy.localdomain.hemminger.net>
	<200707031730.51677.yinghai.lu@sun.com>
	<20070704085120.GB19515@infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Yinghai.Lu@Sun.COM, shemminger@linux-foundation.org,
	akpm@linux-foundation.org, ak@suse.de, greg@kroah.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: hch@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45486
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1760949AbXGDKfL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jul 2007 06:35:11 -0400
In-Reply-To: <20070704085120.GB19515@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Christoph Hellwig <hch@infradead.org>
Date: Wed, 4 Jul 2007 09:51:20 +0100

> On Tue, Jul 03, 2007 at 05:30:51PM -0700, Yinghai Lu wrote:
> > [PATCH 2/4] net: use numa_node in net_devcice->dev instead of parent
> > 
> > Signed-off-by: Yinghai Lu <yinghai.lu@sun.com>
> > diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> > index 27cfe5f..005cc1c 100644
> > --- a/net/core/skbuff.c
> > +++ b/net/core/skbuff.c
> > @@ -217,7 +217,7 @@ nodata:
> >  struct sk_buff *__netdev_alloc_skb(struct net_device *dev,
> >  		unsigned int length, gfp_t gfp_mask)
> >  {
> > -	int node = dev->dev.parent ? dev_to_node(dev->dev.parent) : -1;
> > +	int node = dev_to_node(&dev->dev);
> 
> This looks wrong to me unless the device model has once again changed
> silently.  When I wrote this code &dev->dev was a device allocated
> as part of the netdevice and the parent is the pci (or whatever) device
> that has the node information.

Correct, this change is completely bogus.
