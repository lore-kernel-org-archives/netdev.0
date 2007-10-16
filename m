From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: new NAPI interface broken
Date: Tue, 16 Oct 2007 17:42:08 +1000
Message-ID: <1192520528.7205.9.camel@pasglop>
References: <200709071137.02801.ossthema@de.ibm.com>
	 <20070912.055004.88490155.davem@davemloft.net>
	 <1192519787.7205.3.camel@pasglop>
Reply-To: benh@kernel.crashing.org
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: ossthema@de.ibm.com, shemminger@linux-foundation.org,
	netdev@vger.kernel.org, themann@de.ibm.com, raisch@de.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:52894 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933259AbXJPHmX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Oct 2007 03:42:23 -0400
In-Reply-To: <1192519787.7205.3.camel@pasglop>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> So the powerpc platform just honors the affinity mask, and depending on
> the PIC does things that range from nothing to spreading interrupts to
> CPUs in the affinity mask.
> 
> All interrupts by defaults are spread to all CPUs (full balancing).
> 
> At this stage, it's afaik userland business to enforce different
> policies by changing the affinities via /proc/irq/*.
> 
> Do you have any pointer to how that is done on x86 or sparc64 ? On my
> x86 laptop using ubuntu gutsy, I definitely see the IRQ on which the
> network card is connected (e1000) happily spread between the 2 cores
> just like powerpc would do.

More specifically, IRQF_NOBALANCING doesn't seem to be set anywhere
except a few arch specific timer interrupts etc... nowhere I can see in
network drivers or the network stack (the stack wouldn't know what IRQ
anyway since not all drivers set netdev->irq).

We currently don't have a balance kthread like x86 has, though I wonder
if we should move this one out of x86 and make it generic (hell, it's
even hidden in the IO_APIC code :-) But at this stage, HW balancing by
the PIC is the norm and seems to be happening.

Ben.


