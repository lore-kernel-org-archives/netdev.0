From: Willy Tarreau <w@1wt.eu>
Subject: Re: WARNING: at net/sched/sch_generic.c:219 dev_watchdog+0xfe/0x17e() with tg3 network
Date: Fri, 21 Nov 2008 18:55:15 +0100
Message-ID: <20081121175515.GA32198@1wt.eu>
References: <491954E1.2050002@gmail.com> <1226403067.7685.1598.camel@twins> <491E49AA.60407@gmail.com> <20081118065006.GC24654@1wt.eu> <20081120031101.GD26448@xw6200.broadcom.net> <20081120053746.GB15168@1wt.eu> <20081120184310.GB27712@xw6200.broadcom.net> <20081120212637.GB23844@1wt.eu> <20081120215318.GB27907@xw6200.broadcom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Roger Heflin <rogerheflin@gmail.com>,
	Peter Zijlstra <peterz@infradead.org>,
	LKML <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Matt Carlson <mcarlson@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:1340 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751107AbYKURzY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Nov 2008 12:55:24 -0500
Content-Disposition: inline
In-Reply-To: <20081120215318.GB27907@xw6200.broadcom.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Matt,

On Thu, Nov 20, 2008 at 01:53:18PM -0800, Matt Carlson wrote:
> > Today, with the notebook connected to a gig switch, I could not reproduce
> > the problem, even after one hour of approximately the same workload. I'll
> > retry with the original 100 Mbps switch on monday.
> 
> Was it really a 5704 that you were using?

No, I was wrong, finally it's a 5705 :

tg3.c:v3.94 (August 14, 2008)
ACPI: PCI Interrupt Link [C0C5] enabled at IRQ 11
tg3 0000:02:0e.0: PCI INT A -> Link[C0C5] -> GSI 11 (level, low) -> IRQ 11
eth0: Tigon3 [partno(BMC5705mA3) rev 3003 PHY(5705)] (PCI:33MHz:32-bit) 10/100/1000Base-T Ethernet 00:0d:9d:91:ef:24
eth0: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[0] WireSpeed[0] TSOcap[1]
eth0: dma_rwctrl[763f0000] dma_mask[64-bit]
tg3: eth0: Link is up at 1000 Mbps, full duplex.
tg3: eth0: Flow control is on for TX and on for RX.

Here's the lspci :

02:0e.0 Class 0200: 14e4:165e (rev 03)
        Subsystem: 103c:088c
        Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
        Status: Cap+ 66Mhz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
        Latency: 64 (16000ns min), cache line size 10
        Interrupt: pin A routed to IRQ 11
        Region 0: Memory at 90000000 (64-bit, non-prefetchable) [size=64K]
        Expansion ROM at 5c000000 [disabled] [size=64K]
        Capabilities: [48] Power Management version 2
                Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot+,D3cold+)
                Status: D0 PME-Enable- DSel=0 DScale=1 PME-
        Capabilities: [50] Vital Product Data
        Capabilities: [58] Message Signalled Interrupts: 64bit+ Queue=0/3 Enable-
                Address: fbff71ffffbfebfc  Data: edff
00: e4 14 5e 16 06 00 b0 02 03 00 00 02 10 40 00 00
10: 04 00 00 90 00 00 00 00 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 07 00 00 00 3c 10 8c 08
30: 00 00 00 00 48 00 00 00 00 00 00 00 0b 01 40 00

Regards,
Willy

