From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: r8169 driver problem with RTL8110SB chip (on iop3xx ARM board)
Date: Fri, 28 Jul 2006 13:15:34 +0200
Message-ID: <20060728111534.GD25854@xi.wantstofly.org>
References: <20060728101109.GA25854@xi.wantstofly.org> <20060728104946.GA6710@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, tbm@cyrius.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from alephnull.demon.nl ([83.160.184.112]:40618 "EHLO
	xi.wantstofly.org") by vger.kernel.org with ESMTP id S932630AbWG1LPj
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Jul 2006 07:15:39 -0400
To: Francois Romieu <romieu@fr.zoreil.com>
Content-Disposition: inline
In-Reply-To: <20060728104946.GA6710@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 28, 2006 at 12:49:46PM +0200, Francois Romieu wrote:

> > The in-kernel 'r8169' drivers in 2.6.17 and 2.6.18-rc2 appear to work
> > initially, but they don't actually seem to transmit any packets on the
> > wire, nor do they receive any.
> > 
> > Boot logs from 2.6.17 and 2.6.18-rc2 attached.  Apart from the MAC
> > address for eth1 being incorrect (boot loader bug, being worked on)
> > there don't seem to be any strange messages or errors.
> 
> Can you send:
> - the output of 'lspci -vvx' 

0000:00:01.0 Ethernet controller: Realtek Semiconductor Co., Ltd. RTL-8169 Gigabit Ethernet (rev 10)
	Subsystem: Realtek Semiconductor Co., Ltd. RTL-8169 Gigabit Ethernet
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr+ Stepping- SERR+ FastB2B-
	Status: Cap+ 66MHz+ UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR+ <PERR+
	Latency: 0 (1000ns min, 250ns max), Cache Line Size: 0x08 (32 bytes)
	Interrupt: pin A routed to IRQ 27
	Region 0: I/O ports at fe000000 [size=256]
	Region 1: Memory at 800a0200 (32-bit, non-prefetchable) [size=256]
	Expansion ROM at 80080000 [disabled] [size=64K]
	Capabilities: [dc] Power Management version 2
		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=375mA PME(D0-,D1+,D2+,D3hot+,D3cold+)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [60] Vital Product Data
00: ec 10 69 81 47 01 30 c2 10 00 00 02 08 00 00 00
10: 01 00 00 90 00 02 0a 40 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 ec 10 69 81
30: 00 00 fc dd dc 00 00 00 00 00 00 00 1b 01 04 01

0000:00:02.0 Ethernet controller: Realtek Semiconductor Co., Ltd. RTL-8169 Gigabit Ethernet (rev 10)
	Subsystem: Realtek Semiconductor Co., Ltd. RTL-8169 Gigabit Ethernet
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr+ Stepping- SERR+ FastB2B-
	Status: Cap+ 66MHz+ UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 0 (1000ns min, 250ns max), Cache Line Size: 0x08 (32 bytes)
	Interrupt: pin A routed to IRQ 28
	Region 0: I/O ports at fe000400 [size=256]
	Region 1: Memory at 800a0300 (32-bit, non-prefetchable) [size=256]
	Expansion ROM at 80090000 [disabled] [size=64K]
	Capabilities: [dc] Power Management version 2
		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=375mA PME(D0-,D1+,D2+,D3hot+,D3cold+)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [60] Vital Product Data
00: ec 10 69 81 47 01 38 02 10 00 00 02 08 00 00 00
10: 01 04 00 90 00 03 0a 40 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 ec 10 69 81
30: 00 00 98 56 dc 00 00 00 00 00 00 00 1c 01 04 01

0000:00:03.0 Unknown mass storage controller: Silicon Image, Inc. (formerly CMD Technology Inc) SiI 3512 [SATALink/SATARaid] Serial ATA Controller (rev 01)
	Subsystem: Silicon Image, Inc. (formerly CMD Technology Inc) SiI 3512 [SATALink/SATARaid] Serial ATA Controller
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr+ Stepping- SERR+ FastB2B-
	Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 0, Cache Line Size: 0x08 (32 bytes)
	Interrupt: pin A routed to IRQ 29
	Region 0: I/O ports at fe000850 [size=8]
	Region 1: I/O ports at fe000860 [size=4]
	Region 2: I/O ports at fe000858 [size=8]
	Region 3: I/O ports at fe000864 [size=4]
	Region 4: I/O ports at fe000840 [size=16]
	Region 5: Memory at 800a0000 (32-bit, non-prefetchable) [size=512]
	Expansion ROM at 80000000 [disabled] [size=512K]
	Capabilities: [60] Power Management version 2
		Flags: PMEClk- DSI+ D1+ D2+ AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
		Status: D0 PME-Enable- DSel=0 DScale=2 PME-
00: 95 10 12 35 47 01 b0 02 01 00 80 01 08 00 00 00
10: 51 08 00 90 61 08 00 90 59 08 00 90 65 08 00 90
20: 41 08 00 90 00 00 0a 40 00 00 00 00 95 10 12 35
30: 00 00 00 00 60 00 00 00 00 00 00 00 1d 01 00 00

0000:00:04.0 USB Controller: VIA Technologies, Inc. VT82xxxxx UHCI USB 1.1 Controller (rev 61) (prog-if 00 [UHCI])
	Subsystem: VIA Technologies, Inc. VT82xxxxx UHCI USB 1.1 Controller
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr+ Stepping- SERR+ FastB2B-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 22, Cache Line Size: 0x08 (32 bytes)
	Interrupt: pin A routed to IRQ 28
	Region 4: I/O ports at fe000800 [size=32]
	Capabilities: [80] Power Management version 2
		Flags: PMEClk+ DSI- D1+ D2+ AuxCurrent=0mA PME(D0+,D1+,D2+,D3hot+,D3cold-)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
00: 06 11 38 30 47 01 10 02 61 00 03 0c 08 16 80 00
10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
20: 01 08 00 90 00 00 00 00 00 00 00 00 06 11 38 30
30: 00 00 00 00 80 00 00 00 00 00 00 00 0c 01 00 00

0000:00:04.1 USB Controller: VIA Technologies, Inc. VT82xxxxx UHCI USB 1.1 Controller (rev 61) (prog-if 00 [UHCI])
	Subsystem: VIA Technologies, Inc. VT82xxxxx UHCI USB 1.1 Controller
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr+ Stepping- SERR+ FastB2B-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 22, Cache Line Size: 0x08 (32 bytes)
	Interrupt: pin B routed to IRQ 27
	Region 4: I/O ports at fe000820 [size=32]
	Capabilities: [80] Power Management version 2
		Flags: PMEClk+ DSI- D1+ D2+ AuxCurrent=0mA PME(D0+,D1+,D2+,D3hot+,D3cold-)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
00: 06 11 38 30 47 01 10 02 61 00 03 0c 08 16 80 00
10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
20: 21 08 00 90 00 00 00 00 00 00 00 00 06 11 38 30
30: 00 00 00 00 80 00 00 00 00 00 00 00 0b 02 00 00

0000:00:04.2 USB Controller: VIA Technologies, Inc. USB 2.0 (rev 63) (prog-if 20 [EHCI])
	Subsystem: VIA Technologies, Inc. USB 2.0
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr+ Stepping- SERR+ FastB2B-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 22, Cache Line Size: 0x08 (32 bytes)
	Interrupt: pin C routed to IRQ 29
	Region 0: Memory at 800a0400 (32-bit, non-prefetchable) [size=256]
	Capabilities: [80] Power Management version 2
		Flags: PMEClk+ DSI- D1+ D2+ AuxCurrent=0mA PME(D0+,D1+,D2+,D3hot+,D3cold-)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
00: 06 11 04 31 57 01 10 02 63 20 03 0c 08 16 80 00
10: 00 04 0a 40 00 00 00 00 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 06 11 04 31
30: 00 00 00 00 80 00 00 00 00 00 00 00 1d 03 00 00


> - the content of /proc/interrupts

           CPU0
  9:     560468   IOP32X Timer Tick
 27:      76294   uhci_hcd:usb3, eth0
 28:          0   uhci_hcd:usb2
 29:          0   ehci_hcd:usb1
Err:          0


> - an ethtool dump of the registers. I don't know if Realtek's driver
>   support but it can help even the in-kernel driver

I'm running with the Realtek driver right now which doesn't support
ethtool, and I'm running off NFS root so I can't boot with r8169 for the
moment (-ENOSATADISK.)  I'll ask someone else with the same board to do
the test and will post the results.


> > It doesn't seem to be a PHY configuration issue -- with a custom program
> > to dump the MDIO registers (is there any reason r8169 doesn't support
> > mii-tool, by the way?  will you take a patch to add that?), we get the
> 
> I had written it once, with some rework of the mii functions in the
> driver.  It was hit by conflicts generated by various changes as well
> as higher priority bugs/features requests. You can send your code or
> I can resurrect it at your option.

My 'code' is just a userland program that maps /dev/mem and does
essentially this:

	static unsigned short phy_read(void *rtl, int reg)
	{
		volatile unsigned int *phyar;

		phyar = (volatile unsigned int *)(rtl + 0x60);

		*phyar = reg << 16;
		while (!(*phyar & 0x80000000))
			;

		return *phyar & 0xffff;
	}

If you have code for MII already, it would be great if you could merge
that at some point.


> > Just wondering if you've seen this kind of behavior before before I dig
> > into it further?  I'm pretty sure the hardware is okay, since r1000 works,
> > and the on-board SATA and UHCI/EHCI USB work fine as well.
> 
> I have had a few success reports with the 8110 (and failures too, see
> http://bugzilla.kernel.org/show_bug.cgi?id=5284) but I have not received
> reports for this behavior lately. Complete lack of Rx/Tx activity have
> been observed due to some irq problems. It does not seem to be the issue
> here.

IRQ routing appears to be okay here.  The relevant PCI INTx <-> CPU XINTx
pin routing is specified by hand on this platform, see n2100_pci_map_irq()
in the file:

	http://svn.wantstofly.org/iop3xx/99-thecus.diff

I'll get back to you about the ethtool dump.  Anything else I can do in
the meanwhile?


cheers,
Lennert
