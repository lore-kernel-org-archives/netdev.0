From: Willy Tarreau <w@1wt.eu>
Subject: Re: PATCH] net: b44.c fix sleeping-with-spinlock-helt during resume
Date: Sat, 7 Jun 2008 08:01:12 +0200
Message-ID: <20080607060112.GA9748@1wt.eu>
References: <20080531201130.0244dc29@infradead.org> <200806011203.40437.mb@bu3sch.de> <20080601090107.1ed8d5a7@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Buesch <mb@bu3sch.de>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, akpm@linux-foundation.org,
	stable@kernel.org
To: Arjan van de Ven <arjan@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:1506 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751524AbYFGGB2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 7 Jun 2008 02:01:28 -0400
Content-Disposition: inline
In-Reply-To: <20080601090107.1ed8d5a7@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Arjan, Michael,

On Sun, Jun 01, 2008 at 09:01:07AM -0700, Arjan van de Ven wrote:
> On Sun, 1 Jun 2008 12:03:40 +0200
> Michael Buesch <mb@bu3sch.de> wrote:
> 
> > Index: wireless-testing/drivers/ssb/driver_pcicore.c
> > ===================================================================
> > --- wireless-testing.orig/drivers/ssb/driver_pcicore.c
> > 2008-04-23 16:06:56.000000000 +0200 +++
> > wireless-testing/drivers/ssb/driver_pcicore.c	2008-06-01
> > 12:02:33.000000000 +0200 @@ -537,12 +537,12 @@ int
> > ssb_pcicore_dev_irqvecs_enable(struc int err = 0; u32 tmp;
> >  
> > -	might_sleep();
> > -
> >  	if (!pdev)
> >  		goto out;
> >  	bus = pdev->bus;
> >  
> > +	might_sleep_if(pdev->id.coreid != SSB_DEV_PCI);
> > +
> >  	/* Enable interrupts for this device. */
> >  	if (bus->host_pci &&
> >  	    ((pdev->id.revision >= 6) || (pdev->id.coreid ==
> > SSB_DEV_PCIE))) {
> > 
> > 
> > 
> 
> fair enough.... can we get something like this into 2.6.26 still? Quite
> a few people are hitting this (even though the warning is harmless, it
> still is better to silence it)

Care to CC stable when people are already hitting the problem ?

FWIW, the fix was merged in mainline as commit
  a3bafeedfff2ac5fa0a316bea4570e27900b6fcc

thanks!
willy

