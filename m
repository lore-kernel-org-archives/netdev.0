From: Lucas Nussbaum <lucas@lucas-nussbaum.net>
Subject: e1000e: NIC not working, power management issue?
Date: Wed, 14 Sep 2011 15:40:43 +0200
Message-ID: <20110914134042.GA5739@xanadu.blop.info>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: fhimpe@telenet.be
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xanadu.blop.info ([178.79.145.134]:32901 "EHLO xanadu.blop.info"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753359Ab1INOBI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Sep 2011 10:01:08 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I get the same symptoms as the ones reported by Frederik Himpe in
http://www.spinics.net/lists/netdev/msg174336.html
(Sorry for starting a new thread, I could not find a mbox archive of netdev)

My config:
00:19.0 Ethernet controller: Intel Corporation 82567LM Gigabit Network Connection (rev 03)
        Subsystem: Dell Device 024d
        Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B- DisINTx-
        Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
        Interrupt: pin A routed to IRQ 22
        Region 0: Memory at f6ae0000 (32-bit, non-prefetchable) [disabled] [size=128K]
        Region 1: Memory at f6adb000 (32-bit, non-prefetchable) [disabled] [size=4K]
        Region 2: I/O ports at efe0 [disabled] [size=32]
        Capabilities: [c8] Power Management version 2
                Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
                Status: D3 NoSoftRst- PME-Enable+ DSel=0 DScale=1 PME+
        Capabilities: [d0] MSI: Enable- Count=1/1 Maskable- 64bit+
                Address: 00000000fee0300c  Data: 41b9
        Capabilities: [e0] PCI Advanced Features
                AFCap: TP+ FLR+
                AFCtrl: FLR-
                AFStatus: TP-
        Kernel driver in use: e1000e

running Linux 3.1rc4.

Symptoms:
network doesn't work.
ifconfig shows the device, but ethtool eth0 says:
# ethtool eth0
Settings for eth0:
Cannot get device settings: No such device
Cannot get wake-on-lan settings: No such device
Cannot get message level: No such device
Cannot get link status: No such device
No data available

dmesg:
[ 6260.327320] e1000e: Intel(R) PRO/1000 Network Driver - 1.4.4-k
[ 6260.327324] e1000e: Copyright(c) 1999 - 2011 Intel Corporation.
[ 6260.327355] e1000e 0000:00:19.0: PCI INT A -> GSI 22 (level, low) -> IRQ 22
[ 6260.327366] e1000e 0000:00:19.0: setting latency timer to 64
[ 6260.327490] e1000e 0000:00:19.0: irq 43 for MSI/MSI-X
[ 6260.517813] e1000e 0000:00:19.0: eth0: (PCI Express:2.5GT/s:Width x1) 00:24:e8:a7:2c:42
[ 6260.517824] e1000e 0000:00:19.0: eth0: Intel(R) PRO/1000 Network Connection
[ 6260.518077] e1000e 0000:00:19.0: eth0: MAC: 7, PHY: 8, PBA No: 3002FF-0FF
[ 6260.518102] e1000e 0000:00:19.0: PME# enabled
[ 6260.556129] e1000e 0000:00:19.0: BAR 0: set to [mem 0xf6ae0000-0xf6afffff] (PCI address [0xf6ae0000-0xf6afffff])
[ 6260.556139] e1000e 0000:00:19.0: BAR 1: set to [mem 0xf6adb000-0xf6adbfff] (PCI address [0xf6adb000-0xf6adbfff])
[ 6260.556147] e1000e 0000:00:19.0: BAR 2: set to [io  0xefe0-0xefff] (PCI address [0xefe0-0xefff])
[ 6260.556167] e1000e 0000:00:19.0: restoring config space at offset 0xf (was 0x100, writing 0x10a)
[ 6260.556193] e1000e 0000:00:19.0: restoring config space at offset 0x1 (was 0x100000, writing 0x100107)
[ 6260.556253] e1000e 0000:00:19.0: PME# disabled
[ 6260.645141] e1000e 0000:00:19.0: irq 43 for MSI/MSI-X
[ 6260.700393] e1000e 0000:00:19.0: irq 43 for MSI/MSI-X
[ 6260.702222] ADDRCONF(NETDEV_UP): eth0: link is not ready
[ 6261.796451] e1000e 0000:00:19.0: PME# enabled

On a friend's laptop (also Dell latitude E4300, running Linux 3.0), things work
fine. lspci -vvv of the working laptop:
00:19.0 Ethernet controller: Intel Corporation 82567LM Gigabit Network Connection (rev 03)
        Subsystem: Dell Device 024d
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B- DisINTx+
        Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
        Latency: 0
        Interrupt: pin A routed to IRQ 43
        Region 0: Memory at f6ae0000 (32-bit, non-prefetchable) [size=128K]
        Region 1: Memory at f6adb000 (32-bit, non-prefetchable) [size=4K]
        Region 2: I/O ports at efe0 [size=32]
        Capabilities: [c8] Power Management version 2
                Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
                Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=1 PME-
        Capabilities: [d0] MSI: Enable+ Count=1/1 Maskable- 64bit+
                Address: 00000000fee0300c  Data: 412a
        Capabilities: [e0] PCI Advanced Features
                AFCap: TP+ FLR+
                AFCtrl: FLR-
                AFStatus: TP-
        Kernel driver in use: e1000e

dmesg for the working laptop:
[    0.936973] e1000e: Intel(R) PRO/1000 Network Driver - 1.3.10-k2
[    0.936975] e1000e: Copyright(c) 1999 - 2011 Intel Corporation.
[    0.937013] e1000e 0000:00:19.0: PCI INT A -> GSI 22 (level, low) -> IRQ 22
[    0.937024] e1000e 0000:00:19.0: setting latency timer to 64
[    0.937133] e1000e 0000:00:19.0: irq 43 for MSI/MSI-X
[    1.146345] e1000e 0000:00:19.0: eth0: (PCI Express:2.5GT/s:Width x1) 00:21:70:fb:7a:00
[    1.146348] e1000e 0000:00:19.0: eth0: Intel(R) PRO/1000 Network Connection
[    1.146375] e1000e 0000:00:19.0: eth0: MAC: 7, PHY: 8, PBA No: 3002FF-0FF
[   19.568318] e1000e 0000:00:19.0: irq 43 for MSI/MSI-X
[   19.624124] e1000e 0000:00:19.0: irq 43 for MSI/MSI-X

The only thing I understand so far is that my NIC seems to be stuck in D3...

Lucas
