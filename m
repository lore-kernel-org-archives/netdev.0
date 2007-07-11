From: Olaf Kirch <okir@lst.de>
Subject: Re: Races in net_rx_action vs netpoll?
Date: Wed, 11 Jul 2007 09:41:37 +0200
Message-ID: <200707110941.38587.okir@lst.de>
References: <200707041416.33732.okir@lst.de> <200707101244.32753.okir@lst.de> <20070710.224457.95896396.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from verein.lst.de ([213.95.11.210]:48944 "EHLO mail.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756054AbXGKHuX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Jul 2007 03:50:23 -0400
In-Reply-To: <20070710.224457.95896396.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 11 July 2007 07:44, David Miller wrote:
> > +#ifdef CONFIG_NETPOLL
> > +	/* Prevent race with netpoll - yes, this is a kludge.
> > +	 * But at least it doesn't penalize the non-netpoll
> > +	 * code path. */
> > +	if (test_bit(__LINK_STATE_POLL_LIST_FROZEN, &dev->state))
> > +		return;
> > +#endif
> > +
> >  	local_irq_save(flags);
> >  	BUG_ON(!test_bit(__LINK_STATE_RX_SCHED, &dev->state));
> >  	list_del(&dev->poll_list);
> 
> That new bit can be set in interrupt context can't it?

It's set and cleared in poll_napi only, and as far as I can tell 
poll_napi will only ever be called from via softirq, but never
from an interrupt handler directly.

I also don't think the test_bit() needs to lock out interrupts.
The only reason we do it for the RX_SCHED bit is that the RX_SCHED
bit and the poll_list change must happen atomically wrt interrupts
from the NIC, right?

Olaf
-- 
Olaf Kirch  |  --- o --- Nous sommes du soleil we love when we play
okir@lst.de |    / | \   sol.dhoop.naytheet.ah kin.ir.samse.qurax
