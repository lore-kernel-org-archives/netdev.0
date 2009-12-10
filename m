From: Ian Marsh <mushypea@dominion.net.uk>
Subject: r8169
Date: Thu, 10 Dec 2009 20:58:21 +0000
Message-ID: <20091210205821.GX6965@slinky.marshes.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from slinky.marshes.co.uk ([80.45.84.194]:35264 "EHLO
	slinky.marshes.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757023AbZLJVYr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Dec 2009 16:24:47 -0500
Received: from mushypea by slinky.marshes.co.uk with local (Exim 4.69)
	(envelope-from <mushypea@dominion.net.uk>)
	id 1NIq5d-00056l-Kl
	for netdev@vger.kernel.org; Thu, 10 Dec 2009 20:58:21 +0000
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, all,

After many hours of frustration trying to solve this, I am hoping you guys can
shed some light and help me out.

I have a PC with an Asus P5B i965 motherboard, which has an on-board gigabit
ethernet port.  According to dmesg this is a "RTL8168b/8111b", lspci reports a
"Ethernet controller [0200]: Realtek Semiconductor Co., Ltd. RTL8111/8168B PCI
Express Gigabit Ethernet controller [10ec:8168] (rev 01)".

This PC is a media centre PC, currently using Xubuntu Hardy (8.04.1), with
stock kernel image, 2.6.24-19-generic.  This uses version 2.2LK of the r8169
driver (according to modinfo, srcversion: 449281D8F257330CF6D0E38), which
works perfectly.

I want to upgrade, and have tried Mythbuntu Karmic (9.10), with stock kernel
image, 2.6.31-14-generic.  This uses version 2.3LK-NAPI of the r8169 driver
(according to modinfo, srcversion: AF7CFACF4C12EBE33B133F7), which does not
work for anything beyond pings and very small connections, e.g. browsing to
the Google homepage.

I also tried Mythbuntu Jaunty (9.04) with kernel 2.6.28-11-generic, same
problem.

I also tried (on Mythbuntu Karmic) upgrading the kernel (via a USB stick) to
2.6.32-7-generic, still no joy.

Oh, and I've tried with pci=nomsi too.  And noapic.  Same result every time.

Just to be clear about the symptoms:

1) Network comes up.
2) DHCP succeeds (I get a statically-mapped IP via DHCP)
3) pings work
4) Google homepage works
5) Large web pages (e.g. ubuntu.com, bbc.co.uk) fail, not even fetching the
   initial HTML page.

For example, a wget test did this:

--2009-12-10 11:27:58--  http://www.ubuntu.com/
Resolving www.ubuntu.com... 91.189.90.41
Connecting to www.ubuntu.com|91.189.90.41|:80... connected.
HTTP request sent, awaiting response... 200 OK
Length: 18366 (18K) [text/html]
Saving to: `/dev/null'

84% [================>   ] 15,465      --.-K/s  eta 11s

It gets to that almost instantly, then hangs.  Ctrl-C and repeat causes it to
hang at the exact same place every time.  Different pages hang at different
byte counts, but each page always hangs at the same point.


The relevant part of dmesg is:

r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
r8169 0000:03:00.0: PCI INT A -> GSI 19 (level, low) -> IRQ 19
r8169 0000:03:00.0: setting latency timer to 64
  alloc irq_desc for 28 on node -1
  alloc kstat_irqs on node -1
r8169 0000:03:00.0: irq 28 for MSI/MSI-X
eth0: RTL8168b/8111b at 0xf80d6000, 00:1a:92:9d:44:55, XID 38000000 IRQ 28

Full output of uname -a:

Linux shiny 2.6.31-14-generic #48-Ubuntu SMP Fri Oct 16 14:04:26 UTC 2009 i686 GNU/Linux

The relevant part of lspci -nnvvv is:

03:00.0 Ethernet controller [0200]: Realtek Semiconductor Co., Ltd. RTL8111/8168B PCI Express Gigabit Ethernet controller [10ec:
8168] (rev 01)
        Subsystem: ASUSTeK Computer Inc. Device [1043:81aa]
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+
        Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
        Latency: 0, Cache Line Size: 32 bytes
        Interrupt: pin A routed to IRQ 28
        Region 0: I/O ports at b800 [size=256]
        Region 2: Memory at d1eff000 (64-bit, non-prefetchable) [size=4K]
        Expansion ROM at d1ec0000 [disabled] [size=128K]
        Capabilities: [40] Power Management version 2
                Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=375mA PME(D0-,D1+,D2+,D3hot+,D3cold+)
                Status: D0 PME-Enable- DSel=0 DScale=0 PME-
        Capabilities: [48] Vital Product Data <?>
        Capabilities: [50] Message Signalled Interrupts: Mask- 64bit+ Queue=0/1 Enable+
                Address: 00000000fee0300c  Data: 41a1
        Capabilities: [60] Express (v1) Endpoint, MSI 00
                DevCap: MaxPayload 1024 bytes, PhantFunc 0, Latency L0s <1us, L1 unlimited
                        ExtTag+ AttnBtn+ AttnInd+ PwrInd+ RBE- FLReset-
                DevCtl: Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
                        RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop+
                        MaxPayload 128 bytes, MaxReadReq 4096 bytes
                DevSta: CorrErr- UncorrErr+ FatalErr- UnsuppReq+ AuxPwr+ TransPend-
                LnkCap: Port #0, Speed 2.5GT/s, Width x1, ASPM L0s, Latency L0 unlimited, L1 unlimited
                        ClockPM- Suprise- LLActRep- BwNot-
                LnkCtl: ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk+
                        ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
                LnkSta: Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+ DLActive- BWMgmt- ABWMgmt-
        Capabilities: [84] Vendor Specific Information <?>
        Capabilities: [100] Advanced Error Reporting <?>
        Capabilities: [12c] Virtual Channel <?>
        Capabilities: [148] Device Serial Number 68-81-ec-10-00-00-00-1a
        Capabilities: [154] Power Budgeting <?>
        Kernel driver in use: r8169


Would appreciate any ideas/suggestions.  I'm fairly handy with Linux and C,
although new to kernel hacking, but willing to get my hands dirty to get this
fixed.  If you need any further info or any debugs running, just let me know.

Thanks in advance for your time,

Ian.

