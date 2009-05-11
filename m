From: David Dillow <dave@thedillows.org>
Subject: Re: 2.6.27.19 + 28.7: network timeouts for r8169 and 8139too
Date: Sun, 10 May 2009 20:29:14 -0400
Message-ID: <1242001754.4093.12.camel@obelisk.thedillows.org>
References: <200903041828.49972.m.bueker@berlin.de>
	 <20090322211159.GA23042@electric-eye.fr.zoreil.com>
	 <49CA1822.6050902@grupopie.com> <200904041950.04324.mb@bu3sch.de>
	 <4A06D8D2.4010505@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Michael Buesch <mb@bu3sch.de>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Rui Santos <rsantos@grupopie.com>,
	Michael =?ISO-8859-1?Q?B=FCker?= <m.bueker@berlin.de>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Michael Riepe <michael.riepe@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.knology.net ([24.214.63.101]:45029 "EHLO smtp.knology.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752198AbZEKA3S (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 10 May 2009 20:29:18 -0400
In-Reply-To: <4A06D8D2.4010505@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

cc'ing netdev, where networking discussions have a much higher
probability of getting a developer's attention.

On Sun, 2009-05-10 at 15:38 +0200, Michael Riepe wrote:
> Michael Buesch wrote:
> 
> > I'm currently testing 2.6.29.1 without any additional patches but
> > with the pci=nomsi boot option.
> > 
> > I didn't notice any hickups, yet. I'm running a stresstest on a GBit link for quite
> > some time now. Earlier tests with older kernels and MSI burped earlier.
> > 
> > I will do more testing. If it turns out this is stable I will test the same kernel
> > with Message Signaled Interrupts to see if that causes some breakage.
> 
> I've had this problem up to and including 2.6.29.2. Currently, I'm
> trying 2.6.29.2 with pci=nomsi, and it's stable so far. With MSI
> enabled, a single high-speed TCP transfer will stop after a few seconds,
> but without MSI, I can run four simultaneous transfers to two different
> hosts without a single hickup.
> 
> It seems to me that this particular chip really doesn't like MSI.
> 
> Kernel: 2.6.29.2 (x86_64)
> Board: Intel D945GCLF2
> BIOS version: LF94510J.86A.0099.2008.0731.0303

I'm not sure this is tied to the chip. I've got a similar problem on my
X58 based system; my device is detected as an RTL8168d/8111d by the
r8169 driver, and will go out to lunch under high TX loads under any
kernel after 2.6.28. It seems to be perfectly solid in 2.6.27, but is
detected as a generic RTL8169, as the MAC is unknown to that version of
the driver.

It uses MSI in both cases, so the chip seems happy with MSI in at least
some instances.

I've spent a good part of the weekend bisecting between 2.6.27 and
2.6.28, and it does seem to be working its way into the genirq changes.
It is too early to sure, as I've had a number of kernels that locked up
during boot, so the bisect is a mess, and may not be pointing me in the
right direction. For example, it is currently pointing me at 5fef06...
"Merge branch 'linus' into genirq", which I need to figure out how to
verify.

If the problem is related to changes in the IRQ handling, it could be
that the driver is doing something incorrect WRT interrupts, but I don't
really expect that to be the case.

I'll continue to look at getting a more clean bisection to point us at
the root cause, perhaps keeping the version of the driver constant to
eliminate one variable.

