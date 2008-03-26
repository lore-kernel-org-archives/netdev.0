From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] Improvev netconsole support for RTL8139 NIC driver
Date: Wed, 26 Mar 2008 00:32:28 -0400
Message-ID: <47E9D1DC.6030201@garzik.org>
References: <20080325.203043.196469543.davem@davemloft.net>	<47E9C56F.2070508@pobox.com>	<47E9C784.6050807@garzik.org> <20080325.205331.02412053.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: yang.shi@windriver.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:40173 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750879AbYCZEcb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Mar 2008 00:32:31 -0400
In-Reply-To: <20080325.205331.02412053.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> First, if you mention CPU instructions executed you're
> totally ignoring what I wrote.  Which is that we're
> about to sit spinning on hundreds of cycles doing a PIO
> read on a status register.
> 
> Those hand full of cycles doing the irqsave/irqrestore don't matter,
> at all.
> 
> Again, you're arguing for 18 cycles or so out of say 800.
> It's peanuts, at best.

No, I hear you.

I'm not focusing on cycles, but list examples of the negative effects of 
doing needless work for the sake of consistency:

* eliminates ability to compile-out spinlocks on UP
* code size increases (even if miniscule)
* CPU instructions in a hot path increases (even if lost in the noise)
* stack usage increases (even if miniscule)

But those are just examples of the principle:  don't do work you don't 
need to do.

I also think spin_lock -> spin_lock_irqsave amounts to a slight loss of 
information, too:  Use of spin_lock() rather than spin_lock_irqsave() 
potentially gives the -rt folks some additional flexibility, by 
advertising a different set of acceptable irq-disablement states.

Is the effect huge in this specific case?  No.

Does that give us license to add needless code to drivers?  No, again, IMO.

	Jeff


