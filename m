From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [linux-pm] [PATCH] 3c59x: Get rid of "Trying to free already-free IRQ"
Date: Fri, 25 Sep 2009 14:32:30 +0200
Message-ID: <200909251432.30738.rjw@sisk.pl>
References: <Pine.LNX.4.44L0.0909250038300.14463-100000@netrider.rowland.org>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-pm@lists.linux-foundation.org,
	Anton Vorontsov <avorontsov@ru.mvista.com>,
	netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Alan Stern <stern@rowland.harvard.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ogre.sisk.pl ([217.79.144.158]:52083 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752540AbZIYMbb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Sep 2009 08:31:31 -0400
In-Reply-To: <Pine.LNX.4.44L0.0909250038300.14463-100000@netrider.rowland.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 25 September 2009, Alan Stern wrote:
> On Thu, 24 Sep 2009, Anton Vorontsov wrote:
> 
> > Though, there are few other issues with suspend/resume in this driver.
> > The intention of calling free_irq() in suspend() was to avoid any
> > possible spurious interrupts (see commit 5b039e681b8c5f30aac9cc04385
> > "3c59x PM fixes"). But,
> > 
> > - On resume, the driver was requesting IRQ just after pci_set_master(),
> >   but before vortex_up() (which actually resets 3c59x chips).
> 
> Shouldn't it be possible to reset the chip (or at least prevent it from 
> generating spurious IRQs) during the early-resume phase?
> 
> > - Issuing free_irq() on a shared IRQ doesn't guarantee that a buggy
> >   HW won't trigger spurious interrupts in another driver that
> >   requested the same interrupt. So, if we want to protect from
> >   unexpected interrupts, then on suspend we should issue disable_irq(),
> >   not free_irq().
> 
> What if some other device shares the IRQ and still relies on receiving
> interrupts when this code runs?  Won't disable_irq() mess up the other
> device?

Ah, I overlooked the disable_irq()/enable_irq() part, which is not really
necessary anyway.

Anton, have you tried without that?

Rafael
