From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [PATCH] PHYLIB: IRQ event workqueue handling fixes
Date: Fri, 19 Oct 2007 10:17:06 +0200
Message-ID: <20071019081706.GA2598@ff.dom.local>
References: <20071015125301.GC3015@ff.dom.local> <Pine.LNX.4.64N.0710151737250.16262@blysk.ds.pg.gda.pl> <20071016062108.GB1000@ff.dom.local> <Pine.LNX.4.64N.0710161759050.22596@blysk.ds.pg.gda.pl> <20071017085809.GA1658@ff.dom.local> <Pine.LNX.4.64N.0710171221510.28993@blysk.ds.pg.gda.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andy Fleming <afleming@freescale.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Maciej W\. Rozycki" <macro@linux-mips.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx12.go2.pl ([193.17.41.142]:55806 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751312AbXJSIOA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Oct 2007 04:14:00 -0400
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64N.0710171221510.28993@blysk.ds.pg.gda.pl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 18, 2007 at 12:30:35PM +0100, Maciej W. Rozycki wrote:
> On Wed, 17 Oct 2007, Jarek Poplawski wrote:
...
> > 2) phy_change() doesn't reenable irq line after it sees returns
> > with errors; IMHO it should at least write some warning, but maybe
> > try some safety plan, so enable_irq() and try to disable interrupts
> > and free_irq() on the next call (if it happens). (But, I can be very
> > wrong with this - maybe it's OK and official way.)
> 
>  No way to do this safely -- at this point the device probably still has 
> its interrupt output asserted and the register to clear it is 
> inaccessible, so enabling the line will enter an infinite loop.  At this 
> point the system is no longer stable, so it is better to keep at least 
> some functionality, so that it may be attempted to be shut down cleanly, 
> rather than make it completely irresponsive.  The alternative is panic().

But then... your patch seems to make it possible, because it enables
irq to the initial state of the counter. Of course, this could happen
on closing only.

Jarek P.
