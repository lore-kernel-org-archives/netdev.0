From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: Re: mvneta: oops in __rcu_read_lock on mirabox
Date: Mon, 16 Sep 2013 18:24:50 +0200
Message-ID: <20130916182450.639084c6@skate>
References: <CACzLR4tTvt+ROEhkXUCQhV6=bPPTX4LFSkWfrEhF+OdM1Jm1Rw@mail.gmail.com>
	<20130915205701.5c61a444@skate>
	<20130916065047.GH27487@1wt.eu>
	<20130916175152.4e013457@skate>
	<20130916162209.GL12758@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Willy Tarreau <w@1wt.eu>, Andrew Lunn <andrew@lunn.ch>,
	Jason Cooper <jason@lakedaemon.net>, netdev@vger.kernel.org,
	Ethan Tuttle <ethan@ethantuttle.com>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
	Gregory =?UTF-8?B?Q2zDqW1lbnQ=?=
	<gregory.clement@free-electrons.com>,
	linux-arm-kernel@lists.infradead.org
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from top.free-electrons.com ([176.31.233.9]:56897 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750974Ab3IPQYy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Sep 2013 12:24:54 -0400
In-Reply-To: <20130916162209.GL12758@n2100.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Russell,

On Mon, 16 Sep 2013 17:22:09 +0100, Russell King - ARM Linux wrote:

> One seemed to be a single bit error in an instruction inside the kernel
> image.  The other was what seems to be an impossible abort.
> 
> I still don't see how we could end up with a prefetch abort inside memset()
> due to the kernel domain being inaccessible, but still be able to get
> an oops out, especially when we dump out the memory for the faulting
> instruction by accessing that memory via that apparantly inaccessible
> domain while running the code which dumps that memory also under this
> apparantly inaccessible domain.  If the domain containing the kernel
> really was inaccessible, the system would be completely dead.
> 
> The only possibilities I can come up with for that is that abort was
> caused by something spurious happening at the hardware level causing
> corruption of the instruction TLB (corrupting the domain index stored
> in the I-TLB) or other CPU control hardware causing it to spuriously
> generate that fault.
> 
> As the domain field in the page table L1 entries covers bit 8, and the
> single bit error with the instruction was also bit 8, maybe there's a
> design weakness on data line bit 8 causing marginal operation.
> 
> To add to this, the abort given in this report gives an IFSR value of
> 0x409, which equates to "Synchronous parity error on memory access"
> in ARMv7.  The other value (0x400) equates to "TLB conflict abort"
> which can only happen with LPAE support enabled...  So this is just
> getting more weird!

Could this be caused by bitflips in the RAM due to bad timings, or
overheating or that kind of things?

Thomas
-- 
Thomas Petazzoni, Free Electrons
Kernel, drivers, real-time and embedded Linux
development, consulting, training and support.
http://free-electrons.com
