From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: Realtek 8169 problems with net booting
Date: Sat, 29 Nov 2008 21:06:00 +0000
Message-ID: <20081129210600.GT28946@ZenIV.linux.org.uk>
References: <20081124181456.66a967d2@lxorguk.ukuu.org.uk> <20081129204416.GA6401@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:45094 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752270AbYK2VGE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Nov 2008 16:06:04 -0500
Content-Disposition: inline
In-Reply-To: <20081129204416.GA6401@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Nov 29, 2008 at 09:44:17PM +0100, Francois Romieu wrote:
> Alan Cox <alan@lxorguk.ukuu.org.uk> :
> > On one box here it has always been the case that now and then the boot
> > with crash just after r8169 is loaded iff the BIOS network rom (ie the
> > dhcp stuff) is enabled. Its erratic, hard to reproduce but I finally got
> > around to looking at the driver and have a question that seems to apply
> > to several network drivers
> [...]
> > The master bit is off when the driver is loaded it appears but surely the
> > driver should do
> >
> > 	twiddle a few bits
> > 	soft reset chip
> > 	pci_set_master
> 
> You are right.
> 
> Can you try the attached patch against 2.6.28-rc6 and tell if it makes a
> difference or not ?
> 
> While I did not test it in a BIOS network boot configuration it did not
> crash trivially with these devices:
> RTL8168b/8111b / XID 38000000
> RTL8110s       / XID 04000000
> 
> Note to others: this patch needs testing with different chipsets (XID)
> before being included upstream.

FWIW, on one of two very similar motherboards I'm seeing the hard hangs
from 8169 with netboot enabled, but that smells like a hardware problem;
that crap got more and more frequent until I had to disconnect the
interface.  Other symptoms: it kept trying to renegotiate the link every
few seconds.  Hang used to happen on the first incoming packet after
boot, _but_ that didn't happen on each boot.  IIRC, what finally got me
to call it quits was near 100% frequency of buggered boots *and* a hang
during downloading the kernel.  I'm not entirely sure about the last
part, though - will retest once I get that box free for experiments.

Motherboards might be actually identical; r8169 *are*, according to lspci.
Device in question is
00:0d.0 Ethernet controller: Realtek Semiconductor Co., Ltd. RTL-8169 Gigabit Ethernet (rev 10)
        Subsystem: AOPEN Inc. AK86-L motherboard
        Flags: bus master, 66MHz, medium devsel, latency 32, IRQ 23
        I/O ports at b000 [size=256]
        Memory at ed000000 (32-bit, non-prefetchable) [size=256]
        [virtual] Expansion ROM at 70100000 [disabled] [size=128K]
        Capabilities: [dc] Power Management version 2
