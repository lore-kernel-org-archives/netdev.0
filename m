From: Meelis Roos <mroos@linux.ee>
Subject: tulip hangs under load on sparc64
Date: Tue, 19 Aug 2014 19:12:23 +0300 (EEST)
Message-ID: <alpine.SOC.1.00.1408191904410.7767@math.ut.ee>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: Grant Grundler <grundler@parisc-linux.org>, netdev@vger.kernel.org,
	sparclinux@vger.kernel.org
Return-path: <sparclinux-owner@vger.kernel.org>
Sender: sparclinux-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is not a new problem, I have a note about it from a couple of years 
ago. Now while trying to stress test all my sparc64 test computers I 
found and reproduced it again.

Basically, tulip driver driving onboard davicom ethernet in Sun Netra X1 
suffers a hang under load. Load can be generated with scp from 
fast enough machine so that the Sun becomes a bottleneck.

I remember there was a choice of tulip and dmfe drivers when first 
setting up the box, and for some reason the tulip driver was better on 
sparc64.

00:05.0 Ethernet controller: Davicom Semiconductor, Inc. 21x4x DEC-Tulip compatible 10/100 Ethernet (rev 31)
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr+ Stepping- SERR+ FastB2B- DisINTx-
        Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
        Latency: 0 (5000ns min, 10000ns max)
        Interrupt: pin A routed to IRQ 10
        Region 0: I/O ports at 10100 [size=256]
        Region 1: Memory at 00002000 (32-bit, non-prefetchable) [size=8K]
        Region 2: [virtual] Memory at fffffe0100000000 (32-bit, non-prefetchable)
        Region 3: [virtual] Memory at fffffe0100000000 (32-bit, non-prefetchable)
        Region 4: [virtual] Memory at fffffe0100000000 (32-bit, non-prefetchable)
        Region 5: [virtual] Memory at fffffe0100000000 (32-bit, non-prefetchable)
        Expansion ROM at 00080000 [disabled] [size=256K]
        Capabilities: [50] Power Management version 2
                Flags: PMEClk- DSI+ D1- D2- AuxCurrent=220mA PME(D0-,D1-,D2-,D3hot+,D3cold+)
                Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
        Kernel driver in use: tulip


[   77.953022] Linux Tulip driver version 1.1.15-NAPI (Feb 27, 2007)
[   78.035851] tulip0: Old style EEPROM with no media selection information
[   78.124147] tulip0:  MII transceiver #1 config 1000 status 782d advertising 01e1
[   78.224765] net eth0: Davicom DM9102/DM9102A rev 49 at MMIO 0x1ff00000000, EEPROM not present, 00:03:ba:0c:06:cd, IRQ 9
[   78.369474] tulip1: Old style EEPROM with no media selection information
[   78.457785] tulip1:  MII transceiver #1 config 1000 status 7809 advertising 01e1
[   78.558377] net eth1: Davicom DM9102/DM9102A rev 49 at MMIO 0x1ff00002000, EEPROM not present, 00:03:ba:0c:06:ce, IRQ 10

[...]

[35790.526119] ------------[ cut here ]------------
[35790.586790] WARNING: CPU: 0 PID: 0 at net/sched/sch_generic.c:264 dev_watchdog+0x278/0x2a0()
[35790.697744] NETDEV WATCHDOG: eth0 (tulip): transmit queue 0 timed out
[35790.782400] Modules linked in: ipv6 loop ohci_pci ohci_hcd i2c_ali15x3 i2c_ali1535 sg i2ccore usbcore usb_common
[35790.916222] CPU: 0 PID: 0 Comm: swapper Not tainted 3.17.0-rc1 #131
[35790.998621] Call Trace:
[35791.030744]  [0000000000455dcc] warn_slowpath_fmt+0x2c/0x40
[35791.103989]  [0000000000708f98] dev_watchdog+0x278/0x2a0
[35791.173816]  [000000000048d1e8] call_timer_fn.isra.40+0x8/0x80
[35791.250496]  [000000000048d400] run_timer_softirq+0x1a0/0x260
[35791.326037]  [00000000004588dc] __do_softirq+0xbc/0x1e0
[35791.394724]  [000000000042b980] do_softirq_own_stack+0x20/0x40
[35791.471401]  [0000000000458bac] irq_exit+0x8c/0xa0
[35791.534373]  [000000000042f798] timer_interrupt+0x58/0xa0
[35791.605338]  [00000000004209d4] tl0_irq14+0x14/0x20
[35791.669445]  [000000000042c000] arch_cpu_idle+0x60/0x80
[35791.738137]  [0000000000478994] cpu_startup_entry+0x114/0x180
[35791.813674]  [0000000000930970] start_kernel+0x394/0x3a4
[35791.883503]  [000000000078af6c] tlb_fixup_done+0x80/0x94
[35791.953313]  [0000000000000000]           (null)
[35792.013993] ---[ end trace ab470f2a0234b1ed ]---

-- 
Meelis Roos (mroos@linux.ee)
