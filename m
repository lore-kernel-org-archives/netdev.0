From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Improvev netconsole support for RTL8139 NIC driver
Date: Tue, 25 Mar 2008 20:53:31 -0700 (PDT)
Message-ID: <20080325.205331.02412053.davem@davemloft.net>
References: <20080325.203043.196469543.davem@davemloft.net>
	<47E9C56F.2070508@pobox.com>
	<47E9C784.6050807@garzik.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yang.shi@windriver.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33050
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752043AbYCZDxf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2008 23:53:35 -0400
In-Reply-To: <47E9C784.6050807@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Garzik <jeff@garzik.org>
Date: Tue, 25 Mar 2008 23:48:20 -0400

> Jeff Garzik wrote:
> > I am being realistic...  it's
> > 
> > * not needed
> > * increases code size
> > * increases number of CPU instructions executed
> > * not needed
> 
> I also wonder if using spin_lock_irqsave() makes moving to a real-time 
> kernel with interrupt threads more difficult for that driver.
> 
> And of course we're talking about a hot path here.

First, if you mention CPU instructions executed you're
totally ignoring what I wrote.  Which is that we're
about to sit spinning on hundreds of cycles doing a PIO
read on a status register.

Those hand full of cycles doing the irqsave/irqrestore don't matter,
at all.

Again, you're arguing for 18 cycles or so out of say 800.
It's peanuts, at best.

Secondly, this isn't a hot path.  The "hot path" is in the
->poll() handler which does all of the real packet RX work.
And that runs lockless, in software interrupt context.

The HW interrupt handler's cost is lower bound by the cost of doing a
PIO on the status register, it's impractical to perform any
micro-optimizations of any sort here.

Especially those that sacrifice consistency.
