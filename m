From: "Henrik Rydberg" <rydberg@euromail.se>
Subject: Re: brcm80211 breakage..
Date: Tue, 31 Jan 2012 20:36:08 +0100
Message-ID: <20120131193608.GA2138@polaris.bitmath.org>
References: <CA+55aFx2UnVZP1Z44dMHeifB2nD1zJ87kz25zZjUdwv0ozwKPA@mail.gmail.com>
 <20120131120846.GA8799@polaris.bitmath.org>
 <CA+55aFy5-x6Zevga=rX_q+6vsmXFHyMJ+m8YqrqjC6yELqS6mw@mail.gmail.com>
 <4F283C16.5090508@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>,
	"John W. Linville" <linville@redhat.com>,
	Network Development <netdev@vger.kernel.org>,
	=?utf-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
To: Arend van Spriel <arend@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay-b21.telenor.se ([195.54.99.212]:37007 "EHLO
	smtprelay-b21.telenor.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753506Ab2AaTyo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2012 14:54:44 -0500
Received: from ipb2.telenor.se (ipb2.telenor.se [195.54.127.165])
	by smtprelay-b21.telenor.se (Postfix) with ESMTP id EC8DCC223
	for <netdev@vger.kernel.org>; Tue, 31 Jan 2012 20:35:22 +0100 (CET)
Content-Disposition: inline
In-Reply-To: <4F283C16.5090508@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > So Ack on the patch from me, but it should go through the network
> > guys. Arend, John?
> > 
> 
> The SPROM code in bcma needs some attention, because the availability of
> it depends between chipsets. I think in bcma not all variations are
> known and thus lacking implementation to handle those. So ultimately
> bcma sprom code needs to be extended (looking at brcmsmac code). The
> sprom code in brcmsmac can go when that has happened.
> 
> I will dive into that. I have not hit the "Failed to get SPROM" case so
> any chipset info would be appreciated (Henrik?).

I guess my first mail never reached the netdev mailinglist. This is
also a MacbookAir3,1. Booting from EFI looks like this:

[    0.429827] bcma-pci-bridge 0000:01:00.0: enabling device (0000 -> 0002)
[    0.430083] bcma: Core 0 found: ChipCommon (manuf 0x4BF, id 0x800, rev 0x22, class 0x0)
[    0.430105] bcma: Core 1 found: IEEE 802.11 (manuf 0x4BF, id 0x812, rev 0x17, class 0x0)
[    0.430147] bcma: Core 2 found: PCIe (manuf 0x4BF, id 0x820, rev 0x0F, class 0x0)
[    0.430234] bcma: Found rev 6 PMU (capabilities 0x108C2606)
[    0.499963] bcma: Failed to get SPROM: -71
[    0.500042] bcma: Bus registered
[    0.619721] bcma-pci-bridge 0000:01:00.0: Signaling PME through PCIe PME interrupt
[    1.487946] usbcore: registered new interface driver bcm5974
[    2.569391] input: bcm5974 as /devices/pci0000:00/0000:00:04.0/usb3/3-3/3-3:1.2/input/input7
[    4.857363] brcmsmac bcma0:0: mfg 4bf core 812 rev 23 class 0 irq 21
[    4.931854] bcma: Switched to core: 0x812
[    4.939215] brcms_module_init: register returned 0

And the lspci entry looks like this:

01:00.0 0280: 14e4:4353 (rev 01)
	Subsystem: 106b:00d1
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 256 bytes
	Interrupt: pin A routed to IRQ 21
	Region 0: Memory at 93100000 (64-bit, non-prefetchable) [size=16K]
	Capabilities: <access denied>
	Kernel driver in use: bcma-pci-bridge

Booting from BIOS is almost the identical, only different irq assignments.

Thanks,
Henrik
