From: "Paul Aviles" <paul.aviles@palei.com>
Subject: e1000 Detected Tx Unit Hang
Date: Sat, 2 Sep 2006 10:39:44 -0400
Message-ID: <002c01c6ce9d$a1cf9100$3224050a@avilespaxp>
Mime-Version: 1.0
Content-Type: text/plain;
	format=flowed;
	charset="iso-8859-1";
	reply-type=original
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl-7-36.cofs.net ([68.142.7.36]:42299 "EHLO www.palei.com")
	by vger.kernel.org with ESMTP id S1750837AbWIBOjs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Sep 2006 10:39:48 -0400
Received: from avilespaxp ([10.5.36.50])
	by www.palei.com (8.13.1/8.13.1) with SMTP id k82EdkQm005129
	for <netdev@vger.kernel.org>; Sat, 2 Sep 2006 10:39:46 -0400
To: <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I am getting "e1000: eth0: e1000_clean_tx_irq: Detected Tx Unit Hang"  using 
stock 2.6.17.11, 2.6.17.5 or 2.6.17.4 kernels on centos 4.3.

 The server is a Tyan GS12 ( 82541GI/PI and 82547GI) and is connected to a 
Netgear GS724T Gig  switch. I can easily reproduce the problem by trying to 
do a large ftp transfer to the server. It does not happen if the server is 
connected to a dummy 100 Mb switch, only when is connected to the Gig 
switch.
I have also tried the options line below disabling tso, tx and rx in the 
modprobe.conf without any luck.

 options e1000 XsumRX=0 Speed=1000 Duplex=2 InterruptThrottleRate=0 
FlowControl=3 RxDescriptors=4096 TxDescriptors=4096 RxIntDelay=0 
TxIntDelay=0

 in /var/log/kernel I get the following...

Sep  1 23:53:01 www kernel: e1000: eth0: e1000_clean_tx_irq: Detected Tx 
Unit Hang
Sep  1 23:53:01 www kernel:   Tx Queue             <0>
Sep  1 23:53:01 www kernel:   TDH                  <4c4>
Sep  1 23:53:01 www kernel:   TDT                  <4c9>
Sep  1 23:53:01 www kernel:   next_to_use          <4c9>
Sep  1 23:53:01 www kernel:   next_to_clean        <4c4>
Sep  1 23:53:01 www kernel: buffer_info[next_to_clean]
Sep  1 23:53:01 www kernel:   time_stamp           <ffff9c60>
Sep  1 23:53:01 www kernel:   next_to_watch        <4c4>
Sep  1 23:53:01 www kernel:   jiffies              <ffff9d96>
Sep  1 23:53:01 www kernel:   next_to_watch.status <0>
.
repeats the same as above a few times....
.
Sep  1 23:53:10 www kernel: NETDEV WATCHDOG: eth0: transmit timed out
Sep  1 23:53:13 www kernel: e1000: eth0: e1000_watchdog_task: NIC Link
 is Up 1000 Mbps Full Duplex

 then the server locks up, no response from the keyboard at all and must be 
forced down with a power kill. The suggested tips on how to deal with this 
issue are not working so if I can help troubleshoot this let me know.

 Here is my system info,

 driver: e1000
version: 7.0.33-k2-NAPI
firmware-version: N/A
bus-info: 0000:02:01.0

lspci -vv output below..

00:00.0 Host bridge: Intel Corporation 82875P/E7210 Memory Controller Hub 
(rev 02)
        Subsystem: Intel Corporation 82875P/E7210 Memory Controller Hub
        Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
Stepping- SERR+ FastB2B-
        Status: Cap+ 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=fast >TAbort- 
<TAbort- <MAbort+ >SERR- <PERR-
        Latency: 0
        Region 0: Memory at 90000000 (32-bit, prefetchable) [size=128M]
        Capabilities: [e4] Vendor Specific Information
        Capabilities: [a0] AGP version 3.0
                Status: RQ=32 Iso- ArqSz=2 Cal=0 SBA+ ITACoh- GART64- 
HTrans- 64bit- FW+ AGP3- Rate=x1,x2,x4
                Command: RQ=1 ArqSz=0 Cal=0 SBA- AGP- GART64- 64bit- FW- 
Rate=<none>

00:01.0 PCI bridge: Intel Corporation 82875P Processor to AGP Controller 
(rev 02) (prog-if 00 [Normal decode])
        Control: I/O- Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
Stepping- SERR- FastB2B-
        Status: Cap- 66Mhz+ UDF- FastB2B+ ParErr- DEVSEL=fast >TAbort- 
<TAbort- <MAbort- >SERR- <PERR-
        Latency: 64
        Bus: primary=00, secondary=01, subordinate=01, sec-latency=0
        Secondary status: 66Mhz+ FastB2B+ ParErr- DEVSEL=medium >TAbort- 
<TAbort- <MAbort+ <SERR- <PERR-
        BridgeCtl: Parity- SERR- NoISA- VGA- MAbort- >Reset- FastB2B-

00:03.0 PCI bridge: Intel Corporation 82875P/E7210 Processor to PCI to CSA 
Bridge (rev 02) (prog-if 00 [Normal decode])
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
Stepping- SERR+ FastB2B-
        Status: Cap- 66Mhz+ UDF- FastB2B+ ParErr- DEVSEL=fast >TAbort- 
<TAbort- <MAbort- >SERR- <PERR-
        Latency: 32
        Bus: primary=00, secondary=02, subordinate=02, sec-latency=0
        I/O behind bridge: 00002000-00002fff
        Memory behind bridge: fc100000-fc1fffff
        Secondary status: 66Mhz+ FastB2B+ ParErr- DEVSEL=medium >TAbort- 
<TAbort- <MAbort- <SERR- <PERR-
        BridgeCtl: Parity- SERR- NoISA+ VGA- MAbort- >Reset- FastB2B-

00:1d.0 USB Controller: Intel Corporation 82801EB/ER (ICH5/ICH5R) USB UHCI 
Controller #1 (rev 02) (prog-if 00 [UHCI])
        Subsystem: Intel Corporation: Unknown device 24c0
        Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
Stepping- SERR- FastB2B-
        Status: Cap- 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- 
<TAbort- <MAbort- >SERR- <PERR-
        Latency: 0
        Interrupt: pin A routed to IRQ 18
        Region 4: I/O ports at 1400 [size=32]

00:1d.1 USB Controller: Intel Corporation 82801EB/ER (ICH5/ICH5R) USB UHCI 
Controller #2 (rev 02) (prog-if 00 [UHCI])
        Subsystem: Intel Corporation: Unknown device 24c0
        Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
Stepping- SERR- FastB2B-
        Status: Cap- 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- 
<TAbort- <MAbort- >SERR- <PERR-
        Latency: 0
        Interrupt: pin B routed to IRQ 19
        Region 4: I/O ports at 1420 [size=32]

00:1d.2 USB Controller: Intel Corporation 82801EB/ER (ICH5/ICH5R) USB UHCI 
Controller #3 (rev 02) (prog-if 00 [UHCI])
        Subsystem: Intel Corporation: Unknown device 24c0
        Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
Stepping- SERR- FastB2B-
        Status: Cap- 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- 
<TAbort- <MAbort- >SERR- <PERR-
        Latency: 0
        Interrupt: pin C routed to IRQ 16
        Region 4: I/O ports at 1440 [size=32]

00:1d.3 USB Controller: Intel Corporation 82801EB/ER (ICH5/ICH5R) USB UHCI 
Controller #4 (rev 02) (prog-if 00 [UHCI])
        Subsystem: Intel Corporation: Unknown device 24c0
        Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
Stepping- SERR- FastB2B-
        Status: Cap- 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- 
<TAbort- <MAbort- >SERR- <PERR-
        Latency: 0
        Interrupt: pin A routed to IRQ 18
        Region 4: I/O ports at 1460 [size=32]

00:1d.7 USB Controller: Intel Corporation 82801EB/ER (ICH5/ICH5R) USB2 EHCI 
Controller (rev 02) (prog-if 20 [EHCI])
        Subsystem: Intel Corporation: Unknown device 24d0
        Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
Stepping- SERR+ FastB2B-
        Status: Cap+ 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- 
<TAbort- <MAbort- >SERR- <PERR-
        Latency: 0
        Interrupt: pin D routed to IRQ 17
        Region 0: Memory at fc000000 (32-bit, non-prefetchable) [size=1K]
        Capabilities: [50] Power Management version 2
                Flags: PMEClk- DSI- D1- D2- AuxCurrent=375mA 
PME(D0+,D1-,D2-,D3hot+,D3cold+)
                Status: D0 PME-Enable- DSel=0 DScale=0 PME-
        Capabilities: [58] Debug port

00:1e.0 PCI bridge: Intel Corporation 82801 PCI Bridge (rev c2) (prog-if 00 
[Normal decode])
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
Stepping- SERR+ FastB2B-
        Status: Cap- 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=fast >TAbort- 
<TAbort- <MAbort- >SERR- <PERR-
        Latency: 0
        Bus: primary=00, secondary=03, subordinate=03, sec-latency=32
        I/O behind bridge: 00003000-00003fff
        Memory behind bridge: fc200000-fdffffff
        Prefetchable memory behind bridge: 88000000-880fffff
        Secondary status: 66Mhz- FastB2B+ ParErr- DEVSEL=medium >TAbort- 
<TAbort- <MAbort- <SERR- <PERR-
        BridgeCtl: Parity- SERR- NoISA+ VGA+ MAbort- >Reset- FastB2B-

00:1f.0 ISA bridge: Intel Corporation 82801EB/ER (ICH5/ICH5R) LPC Interface 
Bridge (rev 02)
        Control: I/O+ Mem+ BusMaster+ SpecCycle+ MemWINV- VGASnoop- ParErr- 
Stepping- SERR- FastB2B-
        Status: Cap- 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- 
<TAbort- <MAbort- >SERR- <PERR-
        Latency: 0

00:1f.1 IDE interface: Intel Corporation 82801EB/ER (ICH5/ICH5R) IDE 
Controller (rev 02) (prog-if 8a [Master SecP PriP])
        Subsystem: Intel Corporation: Unknown device 24c0
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
Stepping- SERR- FastB2B-
        Status: Cap- 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- 
<TAbort- <MAbort- >SERR- <PERR-
        Latency: 0
        Interrupt: pin A routed to IRQ 16
        Region 0: I/O ports at <unassigned>
        Region 1: I/O ports at <unassigned>
        Region 2: I/O ports at <unassigned>
        Region 3: I/O ports at <unassigned>
        Region 4: I/O ports at 14a0 [size=16]
        Region 5: Memory at 88100000 (32-bit, non-prefetchable) [size=1K]

00:1f.3 SMBus: Intel Corporation 82801EB/ER (ICH5/ICH5R) SMBus Controller 
(rev 02)
        Subsystem: Intel Corporation: Unknown device 24c0
        Control: I/O+ Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- 
Stepping- SERR- FastB2B-
        Status: Cap- 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- 
<TAbort- <MAbort- >SERR- <PERR-
        Interrupt: pin B routed to IRQ 10
        Region 4: I/O ports at 1480 [size=32]

02:01.0 Ethernet controller: Intel Corporation 82547GI Gigabit Ethernet 
Controller
        Subsystem: Intel Corporation PRO/1000 CT Network Connection
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
Stepping- SERR- FastB2B-
        Status: Cap+ 66Mhz+ UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- 
<TAbort- <MAbort- >SERR- <PERR-
        Latency: 0 (63750ns min), Cache Line Size 08
        Interrupt: pin A routed to IRQ 16
        Region 0: Memory at fc100000 (32-bit, non-prefetchable) [size=128K]
        Region 2: I/O ports at 2000 [size=32]
        Capabilities: [dc] Power Management version 2
                Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA 
PME(D0+,D1-,D2-,D3hot+,D3cold+)
                Status: D0 PME-Enable- DSel=0 DScale=1 PME-

03:00.0 VGA compatible controller: ATI Technologies Inc Rage XL (rev 27) 
(prog-if 00 [VGA])
        Subsystem: ATI Technologies Inc Rage XL
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- 
Stepping+ SERR- FastB2B-
        Status: Cap+ 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- 
<TAbort- <MAbort- >SERR- <PERR-
        Latency: 66 (2000ns min), Cache Line Size 08
        Interrupt: pin A routed to IRQ 5
        Region 0: Memory at fd000000 (32-bit, non-prefetchable) [size=16M]
        Region 1: I/O ports at 3000 [size=256]
        Region 2: Memory at fc240000 (32-bit, non-prefetchable) [size=4K]
        [virtual] Expansion ROM at 88000000 [disabled] [size=128K]
        Capabilities: [5c] Power Management version 2
                Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA 
PME(D0-,D1-,D2-,D3hot-,D3cold-)
                Status: D0 PME-Enable- DSel=0 DScale=0 PME-

03:02.0 Ethernet controller: Intel Corporation 82541GI/PI Gigabit Ethernet 
Controller
        Subsystem: Intel Corporation PRO/1000 MT Network Connection
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- 
Stepping- SERR+ FastB2B-
        Status: Cap+ 66Mhz+ UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- 
<TAbort- <MAbort- >SERR- <PERR-
        Latency: 52 (63750ns min), Cache Line Size 08
        Interrupt: pin A routed to IRQ 16
        Region 0: Memory at fc220000 (32-bit, non-prefetchable) [size=128K]
        Region 1: Memory at fc200000 (32-bit, non-prefetchable) [size=128K]
        Region 2: I/O ports at 3400 [size=64]
        [virtual] Expansion ROM at 88020000 [disabled] [size=128K]
        Capabilities: [dc] Power Management version 2
                Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA 
PME(D0+,D1-,D2-,D3hot+,D3cold+)
                Status: D0 PME-Enable- DSel=0 DScale=1 PME-
        Capabilities: [e4] PCI-X non-bridge device.
                Command: DPERE- ERO+ RBC=0 OST=0
                Status: Bus=0 Dev=0 Func=0 64bit- 133MHz- SCD- USC-, 
DC=simple, DMMRBC=2, DMOST=0, DMCRS=0, RSCEM-

Regards,

Paul Aviles 



-- 
VGER BF report: U 0.453695
