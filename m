From: Grant Grundler <grundler@parisc-linux.org>
Subject: Re: PATCH 2.6.17-rc5 tulip free_irq() called too late
Date: Thu, 8 Jun 2006 09:22:21 -0600
Message-ID: <20060608152221.GC8246@colo.lackof.org>
References: <20060531195234.GA4967@colo.lackof.org> <44883778.8000209@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Grant Grundler <grundler@parisc-linux.org>,
	Andrew Morton <akpm@osdl.org>, netdev@vger.kernel.org,
	Val Henson <val.henson@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from colo.lackof.org ([198.49.126.79]:3805 "EHLO colo.lackof.org")
	by vger.kernel.org with ESMTP id S964869AbWFHPWY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2006 11:22:24 -0400
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <44883778.8000209@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 08, 2006 at 10:43:04AM -0400, Jeff Garzik wrote:
> (CC'ing our newly minted tulip maintainer, Val)

Excellent!
Has MAINTAINERS file been updated? :)

...
> NAK.  This is a band-aid, and one that creates new problems even as it 
> attempts to solve problems.

You failed to demonstrate that below. Any other objections?

> Calling free_irq() while the chip is still active is just a bad idea, 
> because the chip could raise an interrupt, creating a 
> screaming-interrupts situation. Consider especially the case of shared 
> interrupts here, as a concrete example of how this won't work.

The chip IRQ gets turned off in tulip_down().
It won't be screaming for very long.
No one will hear it screaming and no one will care.
The decision to bring down the NIC was already made.

Secondly, if tulip has a problem with shared IRQs, it's already there.
We would have called free_irq() anyway - just a bit later.
In the shared IRQ case, I expect free_irq() to unlink this instance
of the tulip interrupt handler from the CPU vector list. If that
doesn't happen, I could consider that an arch specific bug,
not a tulip driver bug.

> Perhaps cp_close() in 8139cp.c could be an example of a good ordering? 
> It stops the chip, syncs irqs, frees irq, then frees [thus unmapping] 
> the rings.

Sorry, I don't see how it matters if we disable chip IRQ first
or unlink from CPU IRQ list first. Does it?

thanks,
grant
