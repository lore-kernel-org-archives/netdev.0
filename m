From: David Miller <davem@davemloft.net>
Subject: Re: ssb: Fix DMA-API compilation for non-PCI systems
Date: Mon, 10 Nov 2008 14:53:43 -0800 (PST)
Message-ID: <20081110.145343.171487164.davem@davemloft.net>
References: <20081110.135231.96349017.davem@davemloft.net>
	<200811102307.37838.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mb@bu3sch.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39421
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751557AbYKJWxo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Nov 2008 17:53:44 -0500
In-Reply-To: <200811102307.37838.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Buesch <mb@bu3sch.de>
Date: Mon, 10 Nov 2008 23:07:37 +0100

> On Monday 10 November 2008 22:52:31 David Miller wrote:
> > 
> > I applied this since it's a build buster and we should
> > get it fixed quickly.
> > 
> > But as I look at this, the thing to really do here is get
> > rid of these stupid switch statements.  None of it is needed.
> > 
> > The layer that sets up the SSB devices should simply save the
> > generic device pointer for the DMA entity into some new
> > ->dma_dev struct member.
> >
> > Then you just use generic dma_*() interfaces unilaterally.  For PCI
> > devices it will "just work".
> 
> We tried that. It doesn't work. It breaks on several architectures
> that do special things in the pci_dma... functions.
> See the git history and mailinglists, please.

Then those architectures need to fix their implementations,
simply.  They aren't implementing the generic DMA interfaces
properly.  Other subsystems do make use of the generic DMA
interfaces in this way.

Even something as simple as checking for &pci_bus_type in the
dma_*() routines (like powerpc did for quite some time) is
enough to fix the problem.
