From: Julia Lawall <julia@diku.dk>
Subject: Re: question about drivers/net/tg3.c
Date: Wed, 29 Jul 2009 18:59:01 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0907291858431.22045@ask.diku.dk>
References: <Pine.LNX.4.64.0907291743300.22045@ask.diku.dk>
 <20090729163943.GC22014@xw6200.broadcom.net> <Pine.LNX.4.64.0907291857430.22045@ask.diku.dk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Michael Chan <mchan@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Matt Carlson <mcarlson@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw2.diku.dk ([130.225.96.92]:50462 "EHLO mgw2.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755899AbZG2RAv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Jul 2009 13:00:51 -0400
In-Reply-To: <Pine.LNX.4.64.0907291857430.22045@ask.diku.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 29 Jul 2009, Julia Lawall wrote:

> On Wed, 29 Jul 2009, Matt Carlson wrote:
> 
> > On Wed, Jul 29, 2009 at 08:49:35AM -0700, Julia Lawall wrote:
> > > The function tg3_reset_hw in the file drivers/net/tg3.c contains the code:
> > > 
> > > 	/* If statement applies to 5705 and 5750 PCI devices only */
> > > 	if ((GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5705 &&
> > >              tp->pci_chip_rev_id != CHIPREV_ID_5705_A0) ||
> > > 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5750) {
> > >                 if ((tp->tg3_flags & TG3_FLG2_TSO_CAPABLE) &&
> > >                     (tp->pci_chip_rev_id == CHIPREV_ID_5705_A1 ||
> > > 	             tp->pci_chip_rev_id == CHIPREV_ID_5705_A2)) {
> > > 	                /* nothing */
> > > 	        } else if (!(tr32(TG3PCI_PCISTATE) & PCISTATE_BUS_SPEED_HIGH) &&
> > > 	                   !(tp->tg3_flags2 & TG3_FLG2_IS_5788) &&
> > > 			   !(tp->tg3_flags2 & TG3_FLG2_PCI_EXPRESS)) {
> > > 			val |= WDMAC_MODE_RX_ACCEL;
> > > 	        }
> > > 	}
> > > 
> > > 
> > > On the fifth line above there is the code:
> > > 
> > > tp->tg3_flags & TG3_FLG2_TSO_CAPABLE
> > > 
> > > but the tg3_flags field seems to normally have a value whose name contains 
> > > FLAG, and not FLG2.  Should this code be:
> > > 
> > > tp->tg3_flags2 & TG3_FLG2_TSO_CAPABLE
> > > 
> > > or should the constant be different?
> > 
> > On all the copies of tg3.c I have readily available, the line says :
> > 
> > tp->tg3_flags2 & TG3_FLG2_TSO_CAPABLE
> > 
> > Even the latest net-next tree is like this.  Where did you get your
> > source from?
> 
> linux-next

>From Friday, so perhaps it is out of date already.

julia
