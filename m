From: Holger Kiehl <Holger.Kiehl@dwd.de>
Subject: Problems with ixgbe driver
Date: Fri, 14 Jun 2013 11:49:43 +0000 (GMT)
Message-ID: <alpine.LRH.2.02.1306141031490.22892@praktifix.dwd.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; format=flowed; charset=US-ASCII
Cc: linux-kernel <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
To: e1000-devel@lists.sf.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ofcsgdbm.dwd.de ([141.38.3.245]:47023 "EHLO ofcsgdbm.dwd.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752370Ab3FNL6w (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Jun 2013 07:58:52 -0400
Received: from localhost (localhost [127.0.0.1])
	by ofcsgdn3.dwd.de (Postfix) with ESMTP id 8A36953E06
	for <netdev@vger.kernel.org>; Fri, 14 Jun 2013 11:49:43 +0000 (UTC)
Received: from ofcsgdn3.dwd.de ([127.0.0.1])
	by localhost (ofcsgdn3.csg.lan [127.0.0.1]) (amavisd-new, port 10024)
	with LMTP id yI1CrOhRoDBD for <netdev@vger.kernel.org>;
	Fri, 14 Jun 2013 11:49:43 +0000 (UTC)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I have dual port 10Gb Intel network card on a 2 socket (Xeon X5690) with
a total of 12 cores. Hyperthreading is enabled so there are 24 cores.
The problem I have is that when other systems send large amount of data
the network with the intel ixgbe driver gets very slow. Ping times go up
from 0.2ms to appr. 60ms. Some FTP connections stall for more then 2
minutes. What is strange is that heatbeat is configured on the system
with a serial connection to another node and kernel always reports

     ttyS0: 4 input overrun(s)

when lot of data is send and the ping time goes up.

On the network there are three vlan's configured. The network is bonded
(active-backup) together with another HP NC523SFP 10Gb 2-port Server
Adapter. When I switch the network to this card the problem goes away.
Also the ttyS0 input overruns disappear. Note also both network cards
are connected to the same switch.

The system uses Scientific Linux 6.4 with kernel.org kernel. I noticed
this behavior with kernel 3.9.5 and 3.9.6-rc1. Before I did not notice
it because traffic always went over the HP NC523SFP qlcnic card.

In search for a solution to the problem I found a newer ixgbe driver
3.15.1 (3.9.6-rc1. has 3.11.33-k) and tried that. But it has the same
problem. However when I load the module as follows:

     modprobe ixgbe RSS=8,8

the problem goes away. The kernel.org ixgbe driver does not offer this
option. Why? It seems that both drivers have problems on systems with
24 cpu's. But I cannot believe that I am the only one who noticed this,
since ixgbe is widely used.

It would really be nice if one could set the RSS=8,8 option for kernel.org
ixgbe driver too. Or if someone could tell me where I can force the driver
to Receive Side Scaling to 8 even if it means editing the source code.

Below I have added some additional information. Please CC me since I
am not subscribed to any of these lists. And please do not hesitate
to ask if more information is needed.

Many thanks in advance.

Regards,
Holger


Loading ixgbe module 3.15.1 without any options:

    2013-06-14T10:01:15.001506+00:00 helena kernel: [74474.075411] Intel(R) 10 Gigabit PCI Express Network Driver - version 3.15.1
    2013-06-14T10:01:15.033866+00:00 helena kernel: [74474.116422] Copyright (c) 1999-2013 Intel Corporation.
    2013-06-14T10:01:15.204956+00:00 helena kernel: [74474.319440] ixgbe 0000:10:00.0: (PCI Express:5.0GT/s:Width x4) 90:e2:ba:2b:40:80
    2013-06-14T10:01:15.317447+00:00 helena kernel: [74474.362568] ixgbe 0000:10:00.0 eth6: MAC: 2, PHY: 15, SFP+: 5, PBA No: E68785-006
    2013-06-14T10:01:15.317465+00:00 helena kernel: [74474.394068] bonding: bond0: Adding slave eth6.
    2013-06-14T10:01:15.317468+00:00 helena kernel: [74474.431805] ixgbe 0000:10:00.0 eth6: Enabled Features: RxQ: 24 TxQ: 24 FdirHash RSC
    2013-06-14T10:01:15.519117+00:00 helena kernel: [74474.599206] 8021q: adding VLAN 0 to HW filter on device eth6
    2013-06-14T10:01:15.592853+00:00 helena kernel: [74474.633370] bonding: bond0: enslaving eth6 as a backup interface with a down link.
    2013-06-14T10:01:15.592864+00:00 helena kernel: [74474.666823] ixgbe 0000:10:00.0 eth6: detected SFP+: 5
    2013-06-14T10:01:15.634509+00:00 helena kernel: [74474.707900] ixgbe 0000:10:00.0 eth6: Intel(R) 10 Gigabit Network Connection
    2013-06-14T10:01:15.888030+00:00 helena kernel: [74474.917771] ixgbe 0000:10:00.1: (PCI Express:5.0GT/s:Width x4) 90:e2:ba:2b:40:81
    2013-06-14T10:01:15.888032+00:00 helena kernel: [74474.918516] ixgbe 0000:10:00.0 eth6: NIC Link is Up 10 Gbps, Flow Control: RX/TX
    2013-06-14T10:01:15.981283+00:00 helena kernel: [74475.001538] ixgbe 0000:10:00.1 eth7: MAC: 2, PHY: 15, SFP+: 6, PBA No: E68785-006
    2013-06-14T10:01:15.981293+00:00 helena kernel: [74475.006351] bonding: bond0: link status definitely up for interface eth6, 10000 Mbps full duplex.
    2013-06-14T10:01:16.025063+00:00 helena kernel: [74475.094633] ixgbe 0000:10:00.1 eth7: Enabled Features: RxQ: 24 TxQ: 24 FdirHash RSC
    2013-06-14T10:01:16.067357+00:00 helena kernel: [74475.138402] ixgbe 0000:10:00.1 eth7: Intel(R) 10 Gigabit Network Connection


Loading ixgbe module 3.15.1 with RSS=8,8:

    2013-06-14T10:04:24.790464+00:00 helena kernel: [74663.558702] Intel(R) 10 Gigabit PCI Express Network Driver - version 3.15.1
    2013-06-14T10:04:24.790484+00:00 helena kernel: [74663.601435] Copyright (c) 1999-2013 Intel Corporation.
    2013-06-14T10:04:24.853174+00:00 helena kernel: [74663.630652] ixgbe: Receive-Side Scaling (RSS) set to 8
    2013-06-14T10:04:25.043310+00:00 helena kernel: [74663.813984] ixgbe 0000:10:00.0: (PCI Express:5.0GT/s:Width x4) 90:e2:ba:2b:40:80
    2013-06-14T10:04:25.113547+00:00 helena kernel: [74663.853937] ixgbe 0000:10:00.0 eth6: MAC: 2, PHY: 15, SFP+: 5, PBA No: E68785-006
    2013-06-14T10:04:25.113561+00:00 helena kernel: [74663.882910] bonding: bond0: Adding slave eth6.
    2013-06-14T10:04:25.159260+00:00 helena kernel: [74663.924060] ixgbe 0000:10:00.0 eth6: Enabled Features: RxQ: 8 TxQ: 8 FdirHash RSC
    2013-06-14T10:04:25.244858+00:00 helena kernel: [74664.023362] 8021q: adding VLAN 0 to HW filter on device eth6
    2013-06-14T10:04:25.319005+00:00 helena kernel: [74664.055452] bonding: bond0: enslaving eth6 as a backup interface with a down link.
    2013-06-14T10:04:25.319012+00:00 helena kernel: [74664.084567] ixgbe 0000:10:00.0 eth6: detected SFP+: 5
    2013-06-14T10:04:25.362038+00:00 helena kernel: [74664.130774] ixgbe 0000:10:00.0 eth6: Intel(R) 10 Gigabit Network Connection
    2013-06-14T10:04:25.391707+00:00 helena kernel: [74664.172815] ixgbe: Receive-Side Scaling (RSS) set to 8
    2013-06-14T10:04:25.737735+00:00 helena kernel: [74664.334858] ixgbe 0000:10:00.0 eth6: NIC Link is Up 10 Gbps, Flow Control: RX/TX
    2013-06-14T10:04:25.737763+00:00 helena kernel: [74664.353153] ixgbe 0000:10:00.1: (PCI Express:5.0GT/s:Width x4) 90:e2:ba:2b:40:81
    2013-06-14T10:04:25.737765+00:00 helena kernel: [74664.353236] ixgbe 0000:10:00.1 eth7: MAC: 2, PHY: 15, SFP+: 6, PBA No: E68785-006
    2013-06-14T10:04:25.737767+00:00 helena kernel: [74664.353237] ixgbe 0000:10:00.1 eth7: Enabled Features: RxQ: 8 TxQ: 8 FdirHash RSC
    2013-06-14T10:04:25.737769+00:00 helena kernel: [74664.353263] ixgbe 0000:10:00.1 eth7: Intel(R) 10 Gigabit Network Connection
    2013-06-14T10:04:25.817303+00:00 helena kernel: [74664.574233] bonding: bond0: link status definitely up for interface eth6, 10000 Mbps full duplex.


When kernel.org ixgbe driver loads. Note, compiled in, not module:

    2013-06-12T13:15:00.770116+00:00 helena kernel: [   14.873719] ixgbe: Intel(R) 10 Gigabit PCI Express Network Driver - version 3.11.33-k
    2013-06-12T13:15:00.770117+00:00 helena kernel: [   14.924513] ixgbe: Copyright (c) 1999-2013 Intel Corporation.
    2013-06-12T13:15:00.770213+00:00 helena kernel: [   15.086272] ixgbe 0000:10:00.0: Multiqueue Enabled: Rx Queue count = 24, Tx Queue count = 24
    2013-06-12T13:15:00.770214+00:00 helena kernel: [   15.086398] ixgbe 0000:10:00.0: (PCI Express:5.0GT/s:Width x4) 90:e2:ba:2b:40:80
    2013-06-12T13:15:00.770215+00:00 helena kernel: [   15.086481] ixgbe 0000:10:00.0: MAC: 2, PHY: 15, SFP+: 5, PBA No: E68785-006
    2013-06-12T13:15:00.770216+00:00 helena kernel: [   15.086482] ixgbe 0000:10:00.0: PCI-Express bandwidth available for this card is not sufficient for optimal performance.
    2013-06-12T13:15:00.770217+00:00 helena kernel: [   15.086483] ixgbe 0000:10:00.0: For optimal performance a x8 PCI-Express slot is required.
    2013-06-12T13:15:00.770217+00:00 helena kernel: [   15.087586] ixgbe 0000:10:00.0: Intel(R) 10 Gigabit Network Connection
    2013-06-12T13:15:00.770325+00:00 helena kernel: [   15.250040] ixgbe 0000:10:00.1: Multiqueue Enabled: Rx Queue count = 24, Tx Queue count = 24
    2013-06-12T13:15:00.770326+00:00 helena kernel: [   15.250166] ixgbe 0000:10:00.1: (PCI Express:5.0GT/s:Width x4) 90:e2:ba:2b:40:81
    2013-06-12T13:15:00.770326+00:00 helena kernel: [   15.250249] ixgbe 0000:10:00.1: MAC: 2, PHY: 15, SFP+: 6, PBA No: E68785-006
    2013-06-12T13:15:00.770327+00:00 helena kernel: [   15.250250] ixgbe 0000:10:00.1: PCI-Express bandwidth available for this card is not sufficient for optimal performance.
    2013-06-12T13:15:00.770328+00:00 helena kernel: [   15.250250] ixgbe 0000:10:00.1: For optimal performance a x8 PCI-Express slot is required.
    2013-06-12T13:15:00.770329+00:00 helena kernel: [   15.251327] ixgbe 0000:10:00.1: Intel(R) 10 Gigabit Network Connection


lspci:

    00:00.0 Host bridge: Intel Corporation 5520 I/O Hub to ESI Port (rev 13)
    00:01.0 PCI bridge: Intel Corporation 5520/5500/X58 I/O Hub PCI Express Root Port 1 (rev 13)
    00:02.0 PCI bridge: Intel Corporation 5520/5500/X58 I/O Hub PCI Express Root Port 2 (rev 13)
    00:03.0 PCI bridge: Intel Corporation 5520/5500/X58 I/O Hub PCI Express Root Port 3 (rev 13)
    00:04.0 PCI bridge: Intel Corporation 5520/X58 I/O Hub PCI Express Root Port 4 (rev 13)
    00:05.0 PCI bridge: Intel Corporation 5520/X58 I/O Hub PCI Express Root Port 5 (rev 13)
    00:06.0 PCI bridge: Intel Corporation 5520/X58 I/O Hub PCI Express Root Port 6 (rev 13)
    00:07.0 PCI bridge: Intel Corporation 5520/5500/X58 I/O Hub PCI Express Root Port 7 (rev 13)
    00:08.0 PCI bridge: Intel Corporation 5520/5500/X58 I/O Hub PCI Express Root Port 8 (rev 13)
    00:09.0 PCI bridge: Intel Corporation 7500/5520/5500/X58 I/O Hub PCI Express Root Port 9 (rev 13)
    00:0a.0 PCI bridge: Intel Corporation 7500/5520/5500/X58 I/O Hub PCI Express Root Port 10 (rev 13)
    00:0d.0 Host bridge: Intel Corporation Device 343a (rev 13)
    00:0d.1 Host bridge: Intel Corporation Device 343b (rev 13)
    00:0d.2 Host bridge: Intel Corporation Device 343c (rev 13)
    00:0d.3 Host bridge: Intel Corporation Device 343d (rev 13)
    00:0d.4 Host bridge: Intel Corporation 7500/5520/5500/X58 Physical Layer Port 0 (rev 13)
    00:0d.5 Host bridge: Intel Corporation 7500/5520/5500 Physical Layer Port 1 (rev 13)
    00:0d.6 Host bridge: Intel Corporation Device 341a (rev 13)
    00:0e.0 Host bridge: Intel Corporation Device 341c (rev 13)
    00:0e.1 Host bridge: Intel Corporation Device 341d (rev 13)
    00:0e.2 Host bridge: Intel Corporation Device 341e (rev 13)
    00:0e.3 Host bridge: Intel Corporation Device 341f (rev 13)
    00:0e.4 Host bridge: Intel Corporation Device 3439 (rev 13)
    00:14.0 PIC: Intel Corporation 7500/5520/5500/X58 I/O Hub System Management Registers (rev 13)
    00:14.1 PIC: Intel Corporation 7500/5520/5500/X58 I/O Hub GPIO and Scratch Pad Registers (rev 13)
    00:14.2 PIC: Intel Corporation 7500/5520/5500/X58 I/O Hub Control Status and RAS Registers (rev 13)
    00:1c.0 PCI bridge: Intel Corporation 82801JI (ICH10 Family) PCI Express Root Port 1
    00:1c.2 PCI bridge: Intel Corporation 82801JI (ICH10 Family) PCI Express Root Port 3
    00:1c.4 PCI bridge: Intel Corporation 82801JI (ICH10 Family) PCI Express Root Port 5
    00:1d.0 USB controller: Intel Corporation 82801JI (ICH10 Family) USB UHCI Controller #1
    00:1d.1 USB controller: Intel Corporation 82801JI (ICH10 Family) USB UHCI Controller #2
    00:1d.2 USB controller: Intel Corporation 82801JI (ICH10 Family) USB UHCI Controller #3
    00:1d.3 USB controller: Intel Corporation 82801JI (ICH10 Family) USB UHCI Controller #6
    00:1d.7 USB controller: Intel Corporation 82801JI (ICH10 Family) USB2 EHCI Controller #1
    00:1e.0 PCI bridge: Intel Corporation 82801 PCI Bridge (rev 90)
    00:1f.0 ISA bridge: Intel Corporation 82801JIB (ICH10) LPC Interface Controller
    01:03.0 VGA compatible controller: Advanced Micro Devices [AMD] nee ATI ES1000 (rev 02)
    02:00.0 System peripheral: Hewlett-Packard Company Integrated Lights-Out Standard Slave Instrumentation & System Support (rev 04)
    02:00.2 System peripheral: Hewlett-Packard Company Integrated Lights-Out Standard Management Processor Support and Messaging (rev 04)
    02:00.4 USB controller: Hewlett-Packard Company Integrated Lights-Out Standard Virtual USB Controller (rev 01)
    03:00.0 Ethernet controller: Broadcom Corporation NetXtreme II BCM5709 Gigabit Ethernet (rev 20)
    03:00.1 Ethernet controller: Broadcom Corporation NetXtreme II BCM5709 Gigabit Ethernet (rev 20)
    04:00.0 Ethernet controller: Broadcom Corporation NetXtreme II BCM5709 Gigabit Ethernet (rev 20)
    04:00.1 Ethernet controller: Broadcom Corporation NetXtreme II BCM5709 Gigabit Ethernet (rev 20)
    05:00.0 RAID bus controller: Hewlett-Packard Company Smart Array G6 controllers (rev 01)
    08:00.0 PCI bridge: PLX Technology, Inc. PEX 8616 16-lane, 4-Port PCI Express Gen 2 (5.0 GT/s) Switch (rev bb)
    09:04.0 PCI bridge: PLX Technology, Inc. PEX 8616 16-lane, 4-Port PCI Express Gen 2 (5.0 GT/s) Switch (rev bb)
    09:05.0 PCI bridge: PLX Technology, Inc. PEX 8616 16-lane, 4-Port PCI Express Gen 2 (5.0 GT/s) Switch (rev bb)
    09:06.0 PCI bridge: PLX Technology, Inc. PEX 8616 16-lane, 4-Port PCI Express Gen 2 (5.0 GT/s) Switch (rev bb)
    0b:00.0 Mass storage controller: Fusion-io ioDimm3 (rev 01)
    0c:00.0 Mass storage controller: Fusion-io ioDimm3 (rev 01)
    10:00.0 Ethernet controller: Intel Corporation 82599EB 10-Gigabit SFI/SFP+ Network Connection (rev 01)
    10:00.1 Ethernet controller: Intel Corporation 82599EB 10-Gigabit SFI/SFP+ Network Connection (rev 01)
    13:00.0 RAID bus controller: Hewlett-Packard Company Smart Array G6 controllers (rev 01)
    1a:00.0 Ethernet controller: QLogic Corp. cLOM8214 1/10GbE Controller (rev 54)
    1a:00.1 Ethernet controller: QLogic Corp. cLOM8214 1/10GbE Controller (rev 54)
    3e:00.0 Host bridge: Intel Corporation Xeon 5600 Series QuickPath Architecture Generic Non-core Registers (rev 02)
    3e:00.1 Host bridge: Intel Corporation Xeon 5600 Series QuickPath Architecture System Address Decoder (rev 02)
    3e:02.0 Host bridge: Intel Corporation Xeon 5600 Series QPI Link 0 (rev 02)
    3e:02.1 Host bridge: Intel Corporation Xeon 5600 Series QPI Physical 0 (rev 02)
    3e:02.2 Host bridge: Intel Corporation Xeon 5600 Series Mirror Port Link 0 (rev 02)
    3e:02.3 Host bridge: Intel Corporation Xeon 5600 Series Mirror Port Link 1 (rev 02)
    3e:02.4 Host bridge: Intel Corporation Xeon 5600 Series QPI Link 1 (rev 02)
    3e:02.5 Host bridge: Intel Corporation Xeon 5600 Series QPI Physical 1 (rev 02)
    3e:03.0 Host bridge: Intel Corporation Xeon 5600 Series Integrated Memory Controller Registers (rev 02)
    3e:03.1 Host bridge: Intel Corporation Xeon 5600 Series Integrated Memory Controller Target Address Decoder (rev 02)
    3e:03.2 Host bridge: Intel Corporation Xeon 5600 Series Integrated Memory Controller RAS Registers (rev 02)
    3e:03.4 Host bridge: Intel Corporation Xeon 5600 Series Integrated Memory Controller Test Registers (rev 02)
    3e:04.0 Host bridge: Intel Corporation Xeon 5600 Series Integrated Memory Controller Channel 0 Control (rev 02)
    3e:04.1 Host bridge: Intel Corporation Xeon 5600 Series Integrated Memory Controller Channel 0 Address (rev 02)
    3e:04.2 Host bridge: Intel Corporation Xeon 5600 Series Integrated Memory Controller Channel 0 Rank (rev 02)
    3e:04.3 Host bridge: Intel Corporation Xeon 5600 Series Integrated Memory Controller Channel 0 Thermal Control (rev 02)
    3e:05.0 Host bridge: Intel Corporation Xeon 5600 Series Integrated Memory Controller Channel 1 Control (rev 02)
    3e:05.1 Host bridge: Intel Corporation Xeon 5600 Series Integrated Memory Controller Channel 1 Address (rev 02)
    3e:05.2 Host bridge: Intel Corporation Xeon 5600 Series Integrated Memory Controller Channel 1 Rank (rev 02)
    3e:05.3 Host bridge: Intel Corporation Xeon 5600 Series Integrated Memory Controller Channel 1 Thermal Control (rev 02)
    3e:06.0 Host bridge: Intel Corporation Xeon 5600 Series Integrated Memory Controller Channel 2 Control (rev 02)
    3e:06.1 Host bridge: Intel Corporation Xeon 5600 Series Integrated Memory Controller Channel 2 Address (rev 02)
    3e:06.2 Host bridge: Intel Corporation Xeon 5600 Series Integrated Memory Controller Channel 2 Rank (rev 02)
    3e:06.3 Host bridge: Intel Corporation Xeon 5600 Series Integrated Memory Controller Channel 2 Thermal Control (rev 02)
    3f:00.0 Host bridge: Intel Corporation Xeon 5600 Series QuickPath Architecture Generic Non-core Registers (rev 02)
    3f:00.1 Host bridge: Intel Corporation Xeon 5600 Series QuickPath Architecture System Address Decoder (rev 02)
    3f:02.0 Host bridge: Intel Corporation Xeon 5600 Series QPI Link 0 (rev 02)
    3f:02.1 Host bridge: Intel Corporation Xeon 5600 Series QPI Physical 0 (rev 02)
    3f:02.2 Host bridge: Intel Corporation Xeon 5600 Series Mirror Port Link 0 (rev 02)
    3f:02.3 Host bridge: Intel Corporation Xeon 5600 Series Mirror Port Link 1 (rev 02)
    3f:02.4 Host bridge: Intel Corporation Xeon 5600 Series QPI Link 1 (rev 02)
    3f:02.5 Host bridge: Intel Corporation Xeon 5600 Series QPI Physical 1 (rev 02)
    3f:03.0 Host bridge: Intel Corporation Xeon 5600 Series Integrated Memory Controller Registers (rev 02)
    3f:03.1 Host bridge: Intel Corporation Xeon 5600 Series Integrated Memory Controller Target Address Decoder (rev 02)
    3f:03.2 Host bridge: Intel Corporation Xeon 5600 Series Integrated Memory Controller RAS Registers (rev 02)
    3f:03.4 Host bridge: Intel Corporation Xeon 5600 Series Integrated Memory Controller Test Registers (rev 02)
    3f:04.0 Host bridge: Intel Corporation Xeon 5600 Series Integrated Memory Controller Channel 0 Control (rev 02)
    3f:04.1 Host bridge: Intel Corporation Xeon 5600 Series Integrated Memory Controller Channel 0 Address (rev 02)
    3f:04.2 Host bridge: Intel Corporation Xeon 5600 Series Integrated Memory Controller Channel 0 Rank (rev 02)
    3f:04.3 Host bridge: Intel Corporation Xeon 5600 Series Integrated Memory Controller Channel 0 Thermal Control (rev 02)
    3f:05.0 Host bridge: Intel Corporation Xeon 5600 Series Integrated Memory Controller Channel 1 Control (rev 02)
    3f:05.1 Host bridge: Intel Corporation Xeon 5600 Series Integrated Memory Controller Channel 1 Address (rev 02)
    3f:05.2 Host bridge: Intel Corporation Xeon 5600 Series Integrated Memory Controller Channel 1 Rank (rev 02)
    3f:05.3 Host bridge: Intel Corporation Xeon 5600 Series Integrated Memory Controller Channel 1 Thermal Control (rev 02)
    3f:06.0 Host bridge: Intel Corporation Xeon 5600 Series Integrated Memory Controller Channel 2 Control (rev 02)
    3f:06.1 Host bridge: Intel Corporation Xeon 5600 Series Integrated Memory Controller Channel 2 Address (rev 02)
    3f:06.2 Host bridge: Intel Corporation Xeon 5600 Series Integrated Memory Controller Channel 2 Rank (rev 02)
    3f:06.3 Host bridge: Intel Corporation Xeon 5600 Series Integrated Memory Controller Channel 2 Thermal Control (rev 02)


lscpu:

    Architecture:          x86_64
    CPU op-mode(s):        32-bit, 64-bit
    Byte Order:            Little Endian
    CPU(s):                24
    On-line CPU(s) list:   0-23
    Thread(s) per core:    2
    Core(s) per socket:    6
    Socket(s):             2
    NUMA node(s):          2
    Vendor ID:             GenuineIntel
    CPU family:            6
    Model:                 44
    Stepping:              2
    CPU MHz:               1600.000
    BogoMIPS:              6931.29
    Virtualization:        VT-x
    L1d cache:             32K
    L1i cache:             32K
    L2 cache:              256K
    L3 cache:              12288K
    NUMA node0 CPU(s):     0,2,4,6,8,10,12,14,16,18,20,22
    NUMA node1 CPU(s):     1,3,5,7,9,11,13,15,17,19,21,23
