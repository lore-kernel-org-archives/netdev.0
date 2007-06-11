From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: [PATCH] NET: Multiqueue network device support.
Date: Mon, 11 Jun 2007 11:05:31 -0700
Message-ID: <D5C1322C3E673F459512FB59E0DDC3290303AB0B@orsmsx414.amr.corp.intel.com>
References: <466D883B.5050409@trash.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>, <jeff@garzik.org>,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>
To: "Patrick McHardy" <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:7871 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752331AbXFKSFd convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jun 2007 14:05:33 -0400
Content-class: urn:content-classes:message
In-Reply-To: <466D883B.5050409@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> PJ Waskiewicz wrote:
> > diff --git a/net/sched/sch_generic.c 
> b/net/sched/sch_generic.c index 
> > f28bb2d..b9dc2a6 100644
> > --- a/net/sched/sch_generic.c
> > +++ b/net/sched/sch_generic.c
> > @@ -123,7 +123,8 @@ static inline int qdisc_restart(struct 
> net_device *dev)
> >  			/* And release queue */
> >  			spin_unlock(&dev->queue_lock);
> >  
> > -			if (!netif_queue_stopped(dev)) {
> > +			if (!netif_queue_stopped(dev) &&
> > +			    !netif_subqueue_stopped(dev, 
> skb->queue_mapping)) {
> >  				int ret;
> >  
> >  				ret = dev_hard_start_xmit(skb, dev);
> 
> 
> Your patch doesn't update any other users of netif_queue_stopped().
> The assumption that they can pass packets to the driver when 
> the queue is running is no longer valid since they don't know 
> whether the subqueue the packet will end up in is active (it 
> might be different from queue 0 if packets were redirected 
> from a multiqueue aware qdisc through TC actions). So they 
> need to be changed to check the subqueue state as well.

I will look at all these cases and change them accordingly.  Thanks for
catching that.

> BTW, I couldn't find anything but a single 
> netif_wake_subqueue in your (old) e1000 patch. Why doesn't it 
> stop subqueues?

A previous e1000 patch stopped subqueues.  The last e1000 patch I sent
to the list doesn't stop them, and that's a problem with that patch; it
was sent purely to show how the alloc_etherdev_mq() stuff worked, but I
missed the subqueue control.  I can fix that and send an updated patch
if you'd like.  The reason I missed it is we maintain an out-of-tree
driver and an in-tree driver, and mixing/matching code between the two
becomes a bit of a juggling act sometimes when doing little engineering
snippits.

Thanks for reviewing these.  I'll repost something with updates from
your feedback.

Cheers,
-PJ Waskiewicz
