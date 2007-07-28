From: Andi Kleen <ak@suse.de>
Subject: pcnet32 79C972 doesn't survive suspend to RAM
Date: Sat, 28 Jul 2007 18:56:51 +0200
Message-ID: <200707281856.51591.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: pcnet32@verizon.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.suse.de ([195.135.220.2]:38811 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752606AbXG1Q44 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 28 Jul 2007 12:56:56 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hallo,

I tried suspend to RAM on my desktop. Surprisingly near everything worked
after the wakeup, except for the pcnet32 PCI card. Kernel is 2.6.23-rc1-git4
on x86_64.

Bootup:

pcnet32.c:v1.33-NAPI 27.Jun.2006 tsbogend@alpha.franken.de
IOAPIC[0]: Set routing entry (2-21 -> 0x81 -> IRQ 21 Mode:1 Active:1)
ACPI: PCI Interrupt 0000:05:00.0[A] -> GSI 21 (level, low) -> IRQ 21
pcnet32: PCnet/FAST+ 79C972 at 0x1100, 00 a0 d2 18 9d 21
    tx_start_pt(0x0c00):~220 bytes, BCR18(9861):BurstWrEn BurstRdEn NoUFlow 
    SRAMSIZE=0x1700, SRAM_BND=0x0800, assigned IRQ 21.
pcnet32: Found PHY 7810:0003 at address 1.
eth1: registered as PCnet/FAST+ 79C972
pcnet32: 1 cards_found.

After the S3 wakeup I get:

NETDEV WATCHDOG: eth4: transmit timed out
eth4: transmit timed out, status 0053, resetting.
NETDEV WATCHDOG: eth4: transmit timed out
eth4: transmit timed out, status 0053, resetting.
NETDEV WATCHDOG: eth4: transmit timed out
eth4: transmit timed out, status 0053, resetting.
NETDEV WATCHDOG: eth4: transmit timed out
eth4: transmit timed out, status 0053, resetting.
NETDEV WATCHDOG: eth4: transmit timed out
eth4: transmit timed out, status 0053, resetting.
NETDEV WATCHDOG: eth4: transmit timed out
eth4: transmit timed out, status 0053, resetting.
... going on ...

And no packets are getting received either.

lspci -vvvxxx in the broken state:

05:00.0 Ethernet controller: Advanced Micro Devices [AMD] 79c970 [PCnet32 LANCE] (rev 36)
        Subsystem: Allied Telesyn International AT-2700TX 10/100 Fast Ethernet
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
        Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
        Latency: 32 (6000ns min, 6000ns max)
        Interrupt: pin A routed to IRQ 21
        Region 0: I/O ports at 1100 [size=32]
        Region 1: Memory at e8004900 (32-bit, non-prefetchable) [size=32]
        Expansion ROM at fff00000 [disabled] [size=1M]
        Capabilities: [40] Power Management version 1
                Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA PME(D0+,D1+,D2+,D3hot+,D3cold+)
                Status: D0 PME-Enable- DSel=0 DScale=1 PME-
00: 22 10 00 20 07 00 90 02 36 00 00 02 00 20 00 00
10: 01 11 00 00 00 49 00 e8 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 59 12 00 27
30: 00 00 f0 ff 40 00 00 00 00 00 00 00 0b 01 18 18
40: 01 00 11 fe 00 20 00 14 00 00 00 00 00 00 00 00
50: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
60: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
70: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
90: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
d0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
f0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

Interrupt is not shared:
 21:      13292          0   IO-APIC-fasteoi   eth4

-Andi
