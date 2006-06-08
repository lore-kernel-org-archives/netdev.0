From: Grant Grundler <grundler@parisc-linux.org>
Subject: Re: PATCH 2.6.17-rc5 tulip free_irq() called too late
Date: Thu, 8 Jun 2006 09:32:35 -0600
Message-ID: <20060608153235.GD8246@colo.lackof.org>
References: <20060531195234.GA4967@colo.lackof.org> <44883778.8000209@pobox.com> <20060608152221.GC8246@colo.lackof.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, Andrew Morton <akpm@osdl.org>,
	netdev@vger.kernel.org, Val Henson <val.henson@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from colo.lackof.org ([198.49.126.79]:18397 "EHLO colo.lackof.org")
	by vger.kernel.org with ESMTP id S964842AbWFHPch (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2006 11:32:37 -0400
To: Grant Grundler <grundler@parisc-linux.org>
Content-Disposition: inline
In-Reply-To: <20060608152221.GC8246@colo.lackof.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 08, 2006 at 09:22:21AM -0600, Grant Grundler wrote:
> > Perhaps cp_close() in 8139cp.c could be an example of a good ordering? 
> > It stops the chip, syncs irqs, frees irq, then frees [thus unmapping] 
> > the rings.
> 
> Sorry, I don't see how it matters if we disable chip IRQ first
> or unlink from CPU IRQ list first. Does it?

Ok...I think I understand what you are driving at here.
The case is when CPU vector is enabled and shared but
one device _without_ an interrupt handler is registered
is still yanking on the interrupt line. It will cause
linux to disable the line since the IRQ isn't being handled.

This is only possible in the shared IRQ case.

Can we call free_irq() from tulip_down()?
I have the feeling this is going to cause alot more code movement.

thanks,
grant
