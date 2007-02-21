From: Matti Aarnio <matti.aarnio@zmailer.org>
Subject: Re: skge dysfunction on Amd X2 machine with 4GB memory
Date: Wed, 21 Feb 2007 03:06:30 +0200
Message-ID: <20070221010630.GA3883@mea-ext.zmailer.org>
References: <20070211145755.GW3438@mea-ext.zmailer.org> <20070220071502.GA5081@tuatara.stupidest.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Chris Wedgwood <cw@f00f.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from z2.cat.iki.fi ([212.16.98.133]:47526 "EHLO z2.cat.iki.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932287AbXBUBGc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Feb 2007 20:06:32 -0500
Received: (mea@mea-ext) by mail.zmailer.org id S3540017AbXBUBGb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Feb 2007 03:06:31 +0200
Content-Disposition: inline
In-Reply-To: <20070220071502.GA5081@tuatara.stupidest.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 19, 2007 at 11:15:02PM -0800, Chris Wedgwood wrote:
> On Sun, Feb 11, 2007 at 04:57:55PM +0200, Matti Aarnio wrote:
> > With the skge driver there seems to be some sort of problem to work
> > in a system with memory above the 4 GB of PCI address space.
> 
> The chipset (apparently) doesn't deal with bus addresses over 4GB even
> though the MAC does.

Would NVidia made such a mistake at nForce4 ?

The system is ASUS board (A8N-*) for AMD Athlon X2 with NVidia nForce4
chipset, which (I am sure I did mention it) should be apparent from
"forcedeth" ethernet driver.

That one is working just fine with its "HIGHDMA" mode.

Peeking deeper into system hardware:

 # dmesg|grep forcedeth
 forcedeth.c: Reverse Engineered nForce ethernet driver. Version 0.59.
 forcedeth: using HIGHDMA
 eth0: forcedeth.c: subsystem: 01043:8141 bound to 0000:00:0a.0
 # dmesg|grep skge
 skge 1.9 addr 0xc9008000 irq 17 chip Yukon-Lite rev 9


forcedeth:

  00:0a.0 0680: 10de:0057 (rev f3)
        Subsystem: 1043:8141
        Flags: bus master, 66MHz, fast devsel, latency 0, IRQ 20
        Memory at ca100000 (32-bit, non-prefetchable) [size=4K]
        I/O ports at d000 [size=8]
        Capabilities: [44] Power Management version 2

skge:

  05:0c.0 0200: 11ab:4320 (rev 13)
        Subsystem: 1043:811a
        Flags: 66MHz, medium devsel, IRQ 17
        Memory at c9008000 (32-bit, non-prefetchable) [size=16K]
        I/O ports at c400 [size=256]
        Expansion ROM at ca020000 [disabled] [size=128K]
        Capabilities: [48] Power Management version 2
        Capabilities: [50] Vital Product Data


Hmm..  The skge is on bus #5, which is behind bridge:

  00:09.0 PCI bridge: nVidia Corporation CK804 PCI Bridge (rev f2) (prog-if 01 [Subtractive decode])
        Flags: bus master, 66MHz, fast devsel, latency 0
        Bus: primary=00, secondary=05, subordinate=05, sec-latency=128
        I/O behind bridge: 0000b000-0000cfff
        Memory behind bridge: c8000000-c9ffffff
        Prefetchable memory behind bridge: ca000000-ca0fffff



> I guess the right way to fix this long term is to detect systems with
> these chips and mask the dma_mask globally (or if you're clever per
> bus)?


I don't have any DAC capable PCI cards to see if the bus #5 is unable to pass
DACs to primary bus and to Athlon's memory controller.

The bus #5 has following devices:

 05:06.0 FireWire (IEEE 1394): Texas Instruments TSB12LV23 IEEE-1394 Controller
 05:08.0 Multimedia video controller: Brooktree Corporation Bt848 Video Capture (rev 12)
 05:0a.0 RAID bus controller: Silicon Image, Inc. SiI 3114 [SATALink/SATARaid] Serial ATA Controller (rev 02)
 05:0b.0 FireWire (IEEE 1394): Texas Instruments TSB43AB22A IEEE-1394a-2000 Controller (PHY/Link)
 05:0c.0 Ethernet controller: Marvell Technology Group Ltd. 88E8001 Gigabit Ethernet Controller (rev 13)

Numbers 6 and 8 are plugin cards, and they don't use DACs.
I don't think that SiI 3114 or TI TSB43AB22A are using DACs either.

/Matti Aarnio
