From: Murali Karicheri <m-karicheri2@ti.com>
Subject: rtk8168 driver help needed
Date: Fri, 6 May 2016 18:02:36 -0400
Message-ID: <572D147C.8020203@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: "open list:TI NETCP ETHERNET DRIVER" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arroyo.ext.ti.com ([192.94.94.40]:41532 "EHLO arroyo.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758781AbcEFWCd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 May 2016 18:02:33 -0400
Received: from dflxv15.itg.ti.com ([128.247.5.124])
	by arroyo.ext.ti.com (8.13.7/8.13.7) with ESMTP id u46M2W3q006228
	for <netdev@vger.kernel.org>; Fri, 6 May 2016 17:02:32 -0500
Received: from DLEE70.ent.ti.com (dlemailx.itg.ti.com [157.170.170.113])
	by dflxv15.itg.ti.com (8.14.3/8.13.8) with ESMTP id u46M2Wcu002400
	for <netdev@vger.kernel.org>; Fri, 6 May 2016 17:02:32 -0500
Received: from [158.218.103.157] (ileax41-snat.itg.ti.com [10.172.224.153])	by
 dflp32.itg.ti.com (8.14.3/8.13.8) with ESMTP id u46M2VEm000667	for
 <netdev@vger.kernel.org>; Fri, 6 May 2016 17:02:32 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I am trying to integrate the rtl8168 PCIe card to have Ethernet functional on my
Keystone EVM. I purchased the rtl8111c Gib card from Amazon. The Card is detected
by the RC and I can see it is enumerated and show up when doing lspci command.
However I can't get the Ethernet port functional. Does this need MSI interrupt?
I can't see it has requested any.

root@k2g-evm:~# cat /proc/interrupts 
           CPU0       
 18:     152104       GIC  27 Edge      arch_timer
 22:       3326       GIC 196 Edge      serial
 24:          0       GIC 120 Edge      2530000.i2c
 25:          0       GIC 121 Edge      2530400.i2c
 26:         14       GIC  98 Edge      21805800.spi
 27:          0       GIC 160 Edge      2680000.keystone-dwc3, xhci-hcd:usb1
 30:          0       GIC 228 Edge      gpmc
 31:          0       GIC 229 Edge      21c8000.elm
 32:        159       GIC 356 Level     2a00000.msgmgr rx_005_002
 49:          0       GIC 232 Edge      2700000.edma_ccint
 51:          0       GIC 249 Edge      2700000.edma_ccerrint
 52:       1840       GIC 240 Edge      2728000.edma_ccint
 54:          2       GIC 252 Edge      2728000.edma_ccerrint
 57:       5424       GIC 128 Edge      mmc0
 58:        461       GIC 129 Edge      mmc1
285:          0  Keystone-PCIe-MSI-IRQ   0 Edge      PCIe PME, aerdrv
IPI0:          0  CPU wakeup interrupts
IPI1:          0  Timer broadcast interrupts
IPI2:          0  Rescheduling interrupts
IPI3:          0  Function call interrupts
IPI4:          0  Single function call interrupts
IPI5:          0  CPU stop interrupts
IPI6:          0  IRQ work interrupts
IPI7:          0  completion interrupts


root@k2g-evm:~# ifconfig -a
eth0      Link encap:Ethernet  HWaddr 00:00:00:00:00:00  
          BROADCAST MULTICAST  MTU:1500  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)

gre0      Link encap:UNSPEC  HWaddr 00-00-00-00-00-00-00-50-00-00-00-00-00-00-00-00  
          NOARP  MTU:1476  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1 
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)

gretap0   Link encap:Ethernet  HWaddr 00:00:00:00:00:00  
          BROADCAST MULTICAST  MTU:1462  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)

lo        Link encap:Local Loopback  
          inet addr:127.0.0.1  Mask:255.0.0.0
          inet6 addr: ::1/128 Scope:Host
          UP LOOPBACK RUNNING  MTU:65536  Metric:1
          RX packets:14 errors:0 dropped:0 overruns:0 frame:0
          TX packets:14 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1 
          RX bytes:968 (968.0 B)  TX bytes:968 (968.0 B)

tunl0     Link encap:UNSPEC  HWaddr 00-00-00-00-31-00-00-50-00-00-00-00-00-00-00-00  
          NOARP  MTU:1480  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1 
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)

root@k2g-evm:~# ifup eth0
ifconfig: SIOCSIFFLAGS: Cannot assign requested address


[    2.303965] PCI host bridge /soc/pcie@21800000 ranges:
[    2.309108]   No bus range found for /soc/pcie@21800000, using [bus 00-ff]
[    2.316269]    IO 0x23250000..0x23253fff -> 0x00000000
[    2.321499]   MEM 0x50000000..0x5fffffff -> 0x50000000
[    2.331666] keystone-pcie 21801000.pcie: PCI host bridge to bus 0000:00
[    2.338283] pci_bus 0000:00: root bus resource [bus 00-ff]
[    2.343937] pci_bus 0000:00: root bus resource [io  0x0000-0x3fff]
[    2.350114] pci_bus 0000:00: root bus resource [mem 0x50000000-0x5fffffff]
[    2.357095] pci 0000:00:00.0: [104c:b00b] type 01 class 0x060400
[    2.357665] PCI: bus0: Fast back to back transfers disabled
[    2.363717] pci 0000:01:00.0: [10ec:8168] type 00 class 0x020000
[    2.363809] pci 0000:01:00.0: reg 0x10: [io  0x0000-0x00ff]
[    2.363867] pci 0000:01:00.0: reg 0x18: [mem 0x00000000-0x00000fff 64bit]
[    2.363909] pci 0000:01:00.0: reg 0x20: [mem 0x00000000-0x0000ffff 64bit pref]
[    2.363939] pci 0000:01:00.0: reg 0x30: [mem 0x00000000-0x0001ffff pref]
[    2.364099] pci 0000:01:00.0: supports D1 D2
[    2.364116] pci 0000:01:00.0: PME# supported from D0 D1 D2 D3hot D3cold
[    2.381251] PCI: bus1: Fast back to back transfers disabled
[    2.386989] pci 0000:00:00.0: BAR 8: assigned [mem 0x50000000-0x500fffff]
[    2.393937] pci 0000:00:00.0: BAR 9: assigned [mem 0x50100000-0x501fffff pref]
[    2.401221] pci 0000:00:00.0: BAR 7: assigned [io  0x1000-0x1fff]
[    2.407320] pci 0000:01:00.0: BAR 6: assigned [mem 0x50100000-0x5011ffff pref]
[    2.414597] pci 0000:01:00.0: BAR 4: assigned [mem 0x50120000-0x5012ffff 64bit pref]
[    2.422380] pci 0000:01:00.0: BAR 2: assigned [mem 0x50000000-0x50000fff 64bit]
[    2.429702] pci 0000:01:00.0: BAR 0: assigned [io  0x1000-0x10ff]
[    2.435821] pci 0000:00:00.0: PCI bridge to [bus 01]
[    2.440783] pci 0000:00:00.0:   bridge window [io  0x1000-0x1fff]
[    2.446896] pci 0000:00:00.0:   bridge window [mem 0x50000000-0x500fffff]
[    2.453699] pci 0000:00:00.0:   bridge window [mem 0x50100000-0x501fffff pref]
[    2.461453] pcieport 0000:00:00.0: Signaling PME through PCIe PME interrupt
[    2.468411] pci 0000:01:00.0: Signaling PME through PCIe PME interrupt
[    2.475075] pcie_pme 0000:00:00.0:pcie01: service driver pcie_pme loaded
[    2.475392] aer 0000:00:00.0:pcie02: service driver aer loaded
[    2.475652] r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
[    2.481419] r8169 0000:01:00.0: enabling device (0140 -> 0143)
[    2.488865] r8169 0000:01:00.0 eth0: RTL8169 at 0xf0d6a000, 00:00:00:00:00:00, XID 00000000 IRQ 286
[    2.498259] r8169 0000:01:00.0 eth0: jumbo features [frames: 7152 bytes, tx checksumming: ok]


Complete log at http://pastebin.ubuntu.com/16268925/

Can someone help me figure out what is missing?
-- 
Murali Karicheri
Linux Kernel, Keystone
