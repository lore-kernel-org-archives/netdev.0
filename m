From: David Miller <davem@davemloft.net>
Subject: Re: Races in net_rx_action vs netpoll?
Date: Wed, 11 Jul 2007 19:33:20 -0700 (PDT)
Message-ID: <20070711.193320.102574858.davem@davemloft.net>
References: <200707101244.32753.okir@lst.de>
	<20070710.224457.95896396.davem@davemloft.net>
	<200707110941.38587.okir@lst.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: okir@lst.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38496
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S932874AbXGLCc5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jul 2007 22:32:57 -0400
In-Reply-To: <200707110941.38587.okir@lst.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Olaf Kirch <okir@lst.de>
Date: Wed, 11 Jul 2007 09:41:37 +0200

> On Wednesday 11 July 2007 07:44, David Miller wrote:
> > > +#ifdef CONFIG_NETPOLL
> > > +	/* Prevent race with netpoll - yes, this is a kludge.
> > > +	 * But at least it doesn't penalize the non-netpoll
> > > +	 * code path. */
> > > +	if (test_bit(__LINK_STATE_POLL_LIST_FROZEN, &dev->state))
> > > +		return;
> > > +#endif
> > > +
> > >  	local_irq_save(flags);
> > >  	BUG_ON(!test_bit(__LINK_STATE_RX_SCHED, &dev->state));
> > >  	list_del(&dev->poll_list);
> > 
> > That new bit can be set in interrupt context can't it?
> 
> It's set and cleared in poll_napi only, and as far as I can tell 
> poll_napi will only ever be called from via softirq, but never
> from an interrupt handler directly.
> 
> I also don't think the test_bit() needs to lock out interrupts.
> The only reason we do it for the RX_SCHED bit is that the RX_SCHED
> bit and the poll_list change must happen atomically wrt interrupts
> from the NIC, right?

Ok, sounds good.

I'll add merge your patch with a target of 2.6.23

If you really want, after this patch has sat in 2.6.23 for a while
and got some good testing, we can consider a submission for -stable.
