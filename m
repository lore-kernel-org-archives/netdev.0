From: Frederik Himpe <fhimpe@telenet.be>
Subject: e1000e: NIC not working (afer resume?)
Date: Thu, 8 Sep 2011 07:45:06 +0000 (UTC)
Message-ID: <j49rq2$oko$1@dough.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lo.gmane.org ([80.91.229.12]:54367 "EHLO lo.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932266Ab1IHHp0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Sep 2011 03:45:26 -0400
Received: from list by lo.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1R1ZIX-0001J7-Pq
	for netdev@vger.kernel.org; Thu, 08 Sep 2011 09:45:21 +0200
Received: from artipc9.vub.ac.be ([134.184.26.59])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 08 Sep 2011 09:45:21 +0200
Received: from fhimpe by artipc9.vub.ac.be with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 08 Sep 2011 09:45:21 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I have a Dell Latitude E6400 which has a network card supported by the 
e1000e driver. Often (I think after a suspend/resume cycle), the network 
card does not work at all: the NIC is correctly seen by ifconfig, but 
running ethtool just returns: "No such device". dhclient -v gives the 
impression that it's correctly sending out DHCPDISCOVER packets on the 
NIC, but a tcpdump running on the same machine does not see any packets 
going out.

I'm using Debian's 3.0.0-3 kernel (corresponding with Linux 3.0.3).

Full lspci, .config and dmesg output at
http://artipc10.vub.ac.be/~frederik/e1000e/

Here is some relevant summary.

How can I find out what is going wrong?

# ifconfig eth0
eth0      Link encap:Ethernet  HWaddr 00:21:70:e1:bb:4c  
          UP BROADCAST PROMISC MULTICAST  MTU:1500  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)
          Interrupt:22 Memory:f6ae0000-f6b00000 


# ethtool eth0
Settings for eth0:
Cannot get device settings: No such device
Cannot get wake-on-lan settings: No such device
Cannot get message level: No such device
Cannot get link status: No such device
No data available

# lspci -vvnn
00:19.0 Ethernet controller [0200]: Intel Corporation 82567LM Gigabit Network Connection [8086:10f5] (rev 03)
        Subsystem: Dell Device [1028:0233]
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
                Address: 00000000fee0300c  Data: 4182
        Capabilities: [e0] PCI Advanced Features
                AFCap: TP+ FLR+
                AFCtrl: FLR-
                AFStatus: TP-
        Kernel driver in use: e1000e


# dmesg | grep -E "e1000e|eth0"
[    1.027437] e1000e: Intel(R) PRO/1000 Network Driver - 1.3.10-k2
[    1.027441] e1000e: Copyright(c) 1999 - 2011 Intel Corporation.
[    1.027480] e1000e 0000:00:19.0: PCI INT A -> GSI 22 (level, low) -> IRQ 22
[    1.027491] e1000e 0000:00:19.0: setting latency timer to 64
[    1.027605] e1000e 0000:00:19.0: irq 43 for MSI/MSI-X
[    1.231440] e1000e 0000:00:19.0: eth0: (PCI Express:2.5GT/s:Width x1) 00:21:70:e1:bb:4c
[    1.231444] e1000e 0000:00:19.0: eth0: Intel(R) PRO/1000 Network Connection
[    1.231470] e1000e 0000:00:19.0: eth0: MAC: 7, PHY: 8, PBA No: 1004FF-0FF
[   22.896268] e1000e 0000:00:19.0: irq 43 for MSI/MSI-X
[   22.952097] e1000e 0000:00:19.0: irq 43 for MSI/MSI-X
[   22.954132] ADDRCONF(NETDEV_UP): eth0: link is not ready
[   24.504903] e1000e: eth0 NIC Link is Up 100 Mbps Full Duplex, Flow Control: Rx/Tx
[   24.506413] e1000e 0000:00:19.0: eth0: 10/100 speed: disabling TSO
[   24.508402] ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
[   34.788022] eth0: no IPv6 routers present
[   41.444922] e1000e: eth0 NIC Link is Up 100 Mbps Full Duplex, Flow Control: Rx/Tx
[   41.446325] e1000e 0000:00:19.0: eth0: 10/100 speed: disabling TSO
[25136.918393] e1000e 0000:00:19.0: PME# enabled
[25142.488050] e1000e 0000:00:19.0: BAR 0: set to [mem 0xf6ae0000-0xf6afffff] (PCI address [0xf6ae0000-0xf6afffff])
[25142.488058] e1000e 0000:00:19.0: BAR 1: set to [mem 0xf6adb000-0xf6adbfff] (PCI address [0xf6adb000-0xf6adbfff])
[25142.488066] e1000e 0000:00:19.0: BAR 2: set to [io  0xefe0-0xefff] (PCI address [0xefe0-0xefff])
[25142.488085] e1000e 0000:00:19.0: restoring config space at offset 0xf (was 0x100, writing 0x10a)
[25142.488110] e1000e 0000:00:19.0: restoring config space at offset 0x1 (was 0x100000, writing 0x100107)
[25142.488167] e1000e 0000:00:19.0: PME# disabled
[25142.510966] e1000e 0000:00:19.0: PCI INT A disabled
[25142.510971] e1000e 0000:00:19.0: PME# enabled
[25143.468668] e1000e 0000:00:19.0: restoring config space at offset 0xf (was 0x100, writing 0x10a)
[25143.468689] e1000e 0000:00:19.0: restoring config space at offset 0x6 (was 0x1, writing 0xefe1)
[25143.468696] e1000e 0000:00:19.0: restoring config space at offset 0x5 (was 0x0, writing 0xf6adb000)
[25143.468703] e1000e 0000:00:19.0: restoring config space at offset 0x4 (was 0x0, writing 0xf6ae0000)
[25143.468713] e1000e 0000:00:19.0: restoring config space at offset 0x1 (was 0x100000, writing 0x100107)
[25143.471149] e1000e 0000:00:19.0: PME# disabled
[25143.471277] e1000e 0000:00:19.0: irq 43 for MSI/MSI-X
[25145.276441] e1000e 0000:00:19.0: PME# enabled
[25146.082051] e1000e 0000:00:19.0: BAR 0: set to [mem 0xf6ae0000-0xf6afffff] (PCI address [0xf6ae0000-0xf6afffff])
[25146.082076] e1000e 0000:00:19.0: BAR 1: set to [mem 0xf6adb000-0xf6adbfff] (PCI address [0xf6adb000-0xf6adbfff])
[25146.082090] e1000e 0000:00:19.0: BAR 2: set to [io  0xefe0-0xefff] (PCI address [0xefe0-0xefff])
[25146.082126] e1000e 0000:00:19.0: restoring config space at offset 0xf (was 0x100, writing 0x10a)
[25146.082169] e1000e 0000:00:19.0: restoring config space at offset 0x1 (was 0x100000, writing 0x100107)
[25146.082280] e1000e 0000:00:19.0: PME# disabled
[25146.176605] e1000e 0000:00:19.0: irq 43 for MSI/MSI-X
[25146.232228] e1000e 0000:00:19.0: irq 43 for MSI/MSI-X
[25146.234003] ADDRCONF(NETDEV_UP): eth0: link is not ready
[25147.328875] e1000e 0000:00:19.0: PME# enabled
[26261.896126] e1000e 0000:00:19.0: BAR 0: set to [mem 0xf6ae0000-0xf6afffff] (PCI address [0xf6ae0000-0xf6afffff])
[26261.896140] e1000e 0000:00:19.0: BAR 1: set to [mem 0xf6adb000-0xf6adbfff] (PCI address [0xf6adb000-0xf6adbfff])
[26261.896149] e1000e 0000:00:19.0: BAR 2: set to [io  0xefe0-0xefff] (PCI address [0xefe0-0xefff])
[26261.896169] e1000e 0000:00:19.0: restoring config space at offset 0xf (was 0x100, writing 0x10a)
[26261.896196] e1000e 0000:00:19.0: restoring config space at offset 0x1 (was 0x100000, writing 0x100107)
[26261.896241] e1000e 0000:00:19.0: PME# disabled
[26261.896316] e1000e 0000:00:19.0: irq 43 for MSI/MSI-X
[26261.972148] e1000e 0000:00:19.0: PME# enabled
[26268.192160] e1000e 0000:00:19.0: BAR 0: set to [mem 0xf6ae0000-0xf6afffff] (PCI address [0xf6ae0000-0xf6afffff])
[26268.192168] e1000e 0000:00:19.0: BAR 1: set to [mem 0xf6adb000-0xf6adbfff] (PCI address [0xf6adb000-0xf6adbfff])
[26268.192175] e1000e 0000:00:19.0: BAR 2: set to [io  0xefe0-0xefff] (PCI address [0xefe0-0xefff])
[26268.192194] e1000e 0000:00:19.0: restoring config space at offset 0xf (was 0x100, writing 0x10a)
[26268.192219] e1000e 0000:00:19.0: restoring config space at offset 0x1 (was 0x100000, writing 0x100107)
[26268.192274] e1000e 0000:00:19.0: PME# disabled
[26268.213875] e1000e 0000:00:19.0: PME# enabled
[26269.172481] e1000e 0000:00:19.0: restoring config space at offset 0xf (was 0x100, writing 0x10a)
[26269.172497] e1000e 0000:00:19.0: restoring config space at offset 0x6 (was 0x1, writing 0xefe1)
[26269.172502] e1000e 0000:00:19.0: restoring config space at offset 0x5 (was 0x0, writing 0xf6adb000)
[26269.172507] e1000e 0000:00:19.0: restoring config space at offset 0x4 (was 0x0, writing 0xf6ae0000)
[26269.172515] e1000e 0000:00:19.0: restoring config space at offset 0x1 (was 0x100000, writing 0x100107)
[26269.174262] e1000e 0000:00:19.0: PME# disabled
[26269.174339] e1000e 0000:00:19.0: irq 43 for MSI/MSI-X
[26272.384806] e1000e 0000:00:19.0: PME# enabled
[26274.688310] e1000e 0000:00:19.0: eth0: Error reading PHY register
[26275.482490] e1000e 0000:00:19.0: eth0: Error reading PHY register
[26276.277343] e1000e 0000:00:19.0: eth0: Error reading PHY register
[26277.075194] e1000e 0000:00:19.0: eth0: Error reading PHY register
[26277.870807] e1000e 0000:00:19.0: eth0: Error reading PHY register
[26278.667881] e1000e 0000:00:19.0: eth0: Error reading PHY register
[26279.463492] e1000e 0000:00:19.0: eth0: Error reading PHY register
[26280.258982] e1000e 0000:00:19.0: eth0: Error reading PHY register
[26281.056598] e1000e 0000:00:19.0: eth0: Error reading PHY register
[26281.855386] e1000e 0000:00:19.0: eth0: Error reading PHY register
[26282.649838] e1000e 0000:00:19.0: eth0: Error reading PHY register
[26283.445674] e1000e 0000:00:19.0: eth0: Error reading PHY register
[26289.848036] e1000e 0000:00:19.0: BAR 0: set to [mem 0xf6ae0000-0xf6afffff] (PCI address [0xf6ae0000-0xf6afffff])
[26289.848044] e1000e 0000:00:19.0: BAR 1: set to [mem 0xf6adb000-0xf6adbfff] (PCI address [0xf6adb000-0xf6adbfff])
[26289.848050] e1000e 0000:00:19.0: BAR 2: set to [io  0xefe0-0xefff] (PCI address [0xefe0-0xefff])
[26289.848067] e1000e 0000:00:19.0: restoring config space at offset 0xf (was 0x100, writing 0x10a)
[26289.848090] e1000e 0000:00:19.0: restoring config space at offset 0x1 (was 0x100000, writing 0x100107)
[26289.848146] e1000e 0000:00:19.0: PME# disabled
[26289.940279] e1000e 0000:00:19.0: irq 43 for MSI/MSI-X
[26289.996092] e1000e 0000:00:19.0: irq 43 for MSI/MSI-X
[26289.996761] ADDRCONF(NETDEV_UP): eth0: link is not ready
[26291.088343] e1000e 0000:00:19.0: PME# enabled
[26900.272077] e1000e 0000:00:19.0: BAR 0: set to [mem 0xf6ae0000-0xf6afffff] (PCI address [0xf6ae0000-0xf6afffff])
[26900.272096] e1000e 0000:00:19.0: BAR 1: set to [mem 0xf6adb000-0xf6adbfff] (PCI address [0xf6adb000-0xf6adbfff])
[26900.272111] e1000e 0000:00:19.0: BAR 2: set to [io  0xefe0-0xefff] (PCI address [0xefe0-0xefff])
[26900.272142] e1000e 0000:00:19.0: restoring config space at offset 0xf (was 0x100, writing 0x10a)
[26900.272180] e1000e 0000:00:19.0: restoring config space at offset 0x1 (was 0x100000, writing 0x100107)
[26900.272250] e1000e 0000:00:19.0: PME# disabled
[26900.272379] e1000e 0000:00:19.0: irq 43 for MSI/MSI-X
[26900.274426] e1000e 0000:00:19.0: eth0: MAC Wakeup cause - Link Status Change
[26905.560584] e1000e: Intel(R) PRO/1000 Network Driver - 1.3.10-k2
[26905.560591] e1000e: Copyright(c) 1999 - 2011 Intel Corporation.
[26905.560650] e1000e 0000:00:19.0: PCI INT A -> GSI 22 (level, low) -> IRQ 22
[26905.560665] e1000e 0000:00:19.0: setting latency timer to 64
[26905.560836] e1000e 0000:00:19.0: irq 43 for MSI/MSI-X
[26905.744547] e1000e 0000:00:19.0: eth0: (PCI Express:2.5GT/s:Width x1) 00:21:70:e1:bb:4c
[26905.744552] e1000e 0000:00:19.0: eth0: Intel(R) PRO/1000 Network Connection
[26905.744581] e1000e 0000:00:19.0: eth0: MAC: 7, PHY: 8, PBA No: 1004FF-0FF
[26905.744594] e1000e 0000:00:19.0: PME# enabled
[26905.880141] e1000e 0000:00:19.0: BAR 0: set to [mem 0xf6ae0000-0xf6afffff] (PCI address [0xf6ae0000-0xf6afffff])
[26905.880149] e1000e 0000:00:19.0: BAR 1: set to [mem 0xf6adb000-0xf6adbfff] (PCI address [0xf6adb000-0xf6adbfff])
[26905.880155] e1000e 0000:00:19.0: BAR 2: set to [io  0xefe0-0xefff] (PCI address [0xefe0-0xefff])
[26905.880172] e1000e 0000:00:19.0: restoring config space at offset 0xf (was 0x100, writing 0x10a)
[26905.880194] e1000e 0000:00:19.0: restoring config space at offset 0x1 (was 0x100000, writing 0x100107)
[26905.880247] e1000e 0000:00:19.0: PME# disabled
[26905.968320] e1000e 0000:00:19.0: irq 43 for MSI/MSI-X
[26906.024395] e1000e 0000:00:19.0: irq 43 for MSI/MSI-X
[26906.025907] ADDRCONF(NETDEV_UP): eth0: link is not ready
[26907.112415] e1000e 0000:00:19.0: PME# enabled
[27308.975856] device eth0 entered promiscuous mode
[27326.414382] device eth0 left promiscuous mode
[27336.815362] device eth0 entered promiscuous mode

* Right after start up: machine is in docking station, network is working 
fine.
* At 25136: resume machine, not in docking station, no network cable 
plugged in, so network connection was not tested.
* At 26261: resume machine, in docking station, network cable plugged in, 
but network connection is not working
* At 26900: rmmod e1000e && modprobe e1000e: network still not working

-- 
Frederik Himpe
