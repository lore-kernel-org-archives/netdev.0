From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [PATCH] Intel IXP4xx network drivers v.3 - QMGR
Date: Tue, 08 May 2007 16:12:17 +0200
Message-ID: <m3k5vj76bi.fsf@maximus.localdomain>
References: <m3abwhcy74.fsf@maximus.localdomain>
	<m3vef5biob.fsf@maximus.localdomain>
	<5BB7E1AB-5CE1-43C8-8CE3-E0DE0236BD09@cam.ac.uk>
	<m3hcqoa772.fsf@maximus.localdomain>
	<86D26EBE-5899-468F-9C79-23E83E0DE04B@cam.ac.uk>
	<m33b289zku.fsf@maximus.localdomain>
	<m31whs5ehn.fsf_-_@maximus.localdomain>
	<20070508113232.GA32055@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael-Luke Jones <mlj28@cam.ac.uk>,
	Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org,
	lkml <linux-kernel@vger.kernel.org>,
	Russell King <rmk@arm.linux.org.uk>,
	ARM Linux Mailing List
	<linux-arm-kernel@lists.arm.linux.org.uk>
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S968138AbXEHOMV@vger.kernel.org>
In-Reply-To: <20070508113232.GA32055@xi.wantstofly.org> (Lennert Buytenhek's message of "Tue, 8 May 2007 13:32:32 +0200")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Lennert Buytenhek <buytenh@wantstofly.org> writes:

> The queue manager interrupts should probably be implemented as an
> irqchip, in the same way that GPIO interrupts are implemented.  (I.e.
> allocate 'real' interrupt numbers for them, and use the interrupt
> cascade mechanism.)  You probably want to have separate irqchips for
> the upper and lower halves, too.  This way, drivers can just use
> request_irq() instead of having to bother with platform-specific
> qmgr_set_irq() methods.

Is there a sample somewhere?

> As with Christian's driver, I don't know whether an SRAM allocator
> makes much sense.  We can just set up a static allocation map for the
> in-tree drivers and leave out the allocator altogether.  I.e. I don't
> think it's worth the complexity (and just because the butt-ugly Intel
> code has an allocator isn't a very good reason. :-)

It's a very simple allocator. I don't whink we have enough SRAM
without it. For now it would work but it's probably too small
for all potential users at a time.

There may be up to 6 Ethernet ports (not sure about hardware
status, not yet supported even by Intel) - 7 queues * 128 entries
each = ~ 3.5 KB. Add 2 long queues (RX) for HSS and something
for TX, and then crypto, and maybe other things.

Current allocator have its potential problems, but they can be
solved internally (fragmentation, be we tend to use only
128-entry queues (RX and TX-ready Ethernet pool) and short,
16-entry ones (TX) - easy to deal with).
-- 
Krzysztof Halasa
