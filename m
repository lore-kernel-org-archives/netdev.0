From: Andrei Popa <andrei.popa@i-neo.ro>
Subject: Re: [BUG] ethX misnumbered and one missing in mii-tool
Date: Fri, 30 Mar 2007 10:42:23 +0300
Message-ID: <1175240543.6219.10.camel__11510.7467202053$1175289205$gmane$org@localhost>
References: <1175203383.6219.8.camel@localhost>
	 <4807377b0703292121o6eef3bf2l998878cfd677d821@mail.gmail.com>
Reply-To: andrei.popa@i-neo.ro
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	NetDEV list <netdev@vger.kernel.org>
To: Jesse Brandeburg <jesse.brandeburg@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [85.204.20.254] ([85.204.20.254]:47535 "EHLO megainternet.ro"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753601AbXC3HtV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Mar 2007 03:49:21 -0400
In-Reply-To: <4807377b0703292121o6eef3bf2l998878cfd677d821@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2007-03-29 at 21:21 -0700, Jesse Brandeburg wrote:
> added netdev.
> 
> On 3/29/07, Andrei Popa <andrei.popa@i-neo.ro> wrote:
> > In a dual core 2 server with an intel motherboard and 5 network
> > cards(two onboard) and 1 pci express card with two slots and one pci-x
> > pci64 card the kernel sees all of them in dmesg but in mii-tool are
> > misnumbered and one card is missing.
> > (please CC as I am not subscribed to lkml)
> 
> please don't use mii-tool, ethtool is a much better option and
> actually works with gigabit cards.

ethtool reports the same

> 
> > from dmesg:
> > Intel(R) PRO/1000 Network Driver - version 7.0.33-k2-NAPI
> > Copyright (c) 1999-2005 Intel Corporation.
> > ACPI: PCI Interrupt 0000:03:00.0[A] -> GSI 16 (level, low) -> IRQ 16
> > PCI: Setting latency timer of device 0000:03:00.0 to 64
> > e1000: 0000:03:00.0: e1000_probe: (PCI Express:2.5Gb/s:Width x4)
> > 00:15:17:21:0c:08
> > e1000: eth0: e1000_probe: Intel(R) PRO/1000 Network Connection
> 
> eth0...
> 
> > ACPI: PCI Interrupt 0000:03:00.1[B] -> GSI 17 (level, low) -> IRQ 17
> > PCI: Setting latency timer of device 0000:03:00.1 to 64
> > e1000: 0000:03:00.1: e1000_probe: (PCI Express:2.5Gb/s:Width x4)
> > 00:15:17:21:0c:09
> > e1000: eth0: e1000_probe: Intel(R) PRO/1000 Network Connection
> eth0...
> 
> > ACPI: PCI Interrupt 0000:05:00.0[A] -> GSI 18 (level, low) -> IRQ 18
> > PCI: Setting latency timer of device 0000:05:00.0 to 64
> > e1000: 0000:05:00.0: e1000_probe: (PCI Express:2.5Gb/s:Width x4)
> > 00:15:17:17:b7:68
> > e1000: eth0: e1000_probe: Intel(R) PRO/1000 Network Connection
> eth0...
> > GSI 20 sharing vector 0xC9 and IRQ 20
> > ACPI: PCI Interrupt 0000:05:00.1[B] -> GSI 19 (level, low) -> IRQ 20
> > PCI: Setting latency timer of device 0000:05:00.1 to 64
> > e1000: 0000:05:00.1: e1000_probe: (PCI Express:2.5Gb/s:Width x4)
> > 00:15:17:17:b7:69
> > e1000: eth0: e1000_probe: Intel(R) PRO/1000 Network Connection
> eth0...
> 
> > GSI 21 sharing vector 0xD1 and IRQ 21
> > ACPI: PCI Interrupt 0000:06:02.0[A] -> GSI 27 (level, low) -> IRQ 21
> > e1000: 0000:06:02.0: e1000_probe: (PCI-X:100MHz:64-bit)
> > 00:0e:0c:ba:a8:50
> > e1000: eth0: e1000_probe: Intel(R) PRO/1000 Network Connection
> eth0...
> 
> um, I'm a little confused why every interface was named eth0 when it
> tried to come up.



> you didn't mention what kernel you're using.

this war kernel 2.6.17.14 and the driver was compiled as a module.


with kernel 2.6.20.4(and build in e1000 driver):
zeus ~ # uname -a
Linux zeus 2.6.20.4-zeus3 #3 SMP Wed Mar 28 13:44:50 EEST 2007 x86_64
Intel(R) Xeon(TM) CPU 3.00GHz GenuineIntel GNU/Linux

the devices are recognized ok as eth0,eth1.eth2,eth3,eth4 but misnumered
and one missing int mii-tool/ethtool

Intel(R) PRO/1000 Network Driver - version 7.3.15-k2-NAPI
Copyright (c) 1999-2006 Intel Corporation.
ACPI: PCI Interrupt 0000:03:00.0[A] -> GSI 16 (level, low) -> IRQ 16
PCI: Setting latency timer of device 0000:03:00.0 to 64
e1000: 0000:03:00.0: e1000_probe: (PCI Express:2.5Gb/s:Width x4)
00:15:17:21:0c:08
e1000: eth0: e1000_probe: Intel(R) PRO/1000 Network Connection
ACPI: PCI Interrupt 0000:03:00.1[B] -> GSI 17 (level, low) -> IRQ 17
PCI: Setting latency timer of device 0000:03:00.1 to 64
e1000: 0000:03:00.1: e1000_probe: (PCI Express:2.5Gb/s:Width x4)
00:15:17:21:0c:09
e1000: eth1: e1000_probe: Intel(R) PRO/1000 Network Connection
ACPI: PCI Interrupt 0000:05:00.0[A] -> GSI 18 (level, low) -> IRQ 18
PCI: Setting latency timer of device 0000:05:00.0 to 64
e1000: 0000:05:00.0: e1000_probe: (PCI Express:2.5Gb/s:Width x4)
00:15:17:17:b7:68
e1000: eth2: e1000_probe: Intel(R) PRO/1000 Network Connection
ACPI: PCI Interrupt 0000:05:00.1[B] -> GSI 19 (level, low) -> IRQ 19
PCI: Setting latency timer of device 0000:05:00.1 to 64
e1000: 0000:05:00.1: e1000_probe: (PCI Express:2.5Gb/s:Width x4)
00:15:17:17:b7:69
e1000: eth3: e1000_probe: Intel(R) PRO/1000 Network Connection
ACPI: PCI Interrupt 0000:06:02.0[A] -> GSI 27 (level, low) -> IRQ 27
e1000: 0000:06:02.0: e1000_probe: (PCI-X:100MHz:64-bit)
00:0e:0c:ba:a8:50
e1000: eth4: e1000_probe: Intel(R) PRO/1000 Network Connection

zeus ~ # mii-tool
eth2: no link
eth5: negotiated 100baseTx-FD, link ok
eth6: no link
eth7: no link
zeus ~ #

ethtool shows the same

> 
> you can enable MSI and not share interrupts on this platform, it will
> at least help your PCIe adapters.

Initialy I enabled it but I thought it was a problem from there and
disabled it.

> 
> > zeus ~ # mii-tool
> > eth2: no link
> > eth5: negotiated 100baseTx-FD, link ok
> > eth6: no link
> > eth7: no link
> > zeus ~ #
> >
> > it sees only 4 cards that are misnumbered and one is missing.
> 
> what does 'ip link' or 'ifconfig -a' show?

zeus ~ # ip link
1: eth6: <BROADCAST,MULTICAST> mtu 1500 qdisc noop qlen 1000
    link/ether 00:15:17:21:0c:08 brd ff:ff:ff:ff:ff:ff
2: eth5: <BROADCAST,MULTICAST,UP,10000> mtu 1500 qdisc pfifo_fast qlen
1000
    link/ether 00:15:17:21:0c:09 brd ff:ff:ff:ff:ff:ff
3: eth8: <BROADCAST,MULTICAST> mtu 1500 qdisc noop qlen 1000
    link/ether 00:15:17:17:b7:68 brd ff:ff:ff:ff:ff:ff
4: eth7: <BROADCAST,MULTICAST> mtu 1500 qdisc noop qlen 1000
    link/ether 00:15:17:17:b7:69 brd ff:ff:ff:ff:ff:ff
5: eth2: <BROADCAST,MULTICAST> mtu 1500 qdisc noop qlen 1000
    link/ether 00:0e:0c:ba:a8:50 brd ff:ff:ff:ff:ff:ff
6: lo: <LOOPBACK,UP,10000> mtu 16436 qdisc noqueue
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
zeus ~ #


zeus ~ # ifconfig -a
eth2      Link encap:Ethernet  HWaddr 00:0E:0C:BA:A8:50
          BROADCAST MULTICAST  MTU:1500  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:0 (0.0 b)  TX bytes:0 (0.0 b)
          Base address:0x2000 Memory:b8a00000-b8a20000

eth5      Link encap:Ethernet  HWaddr 00:15:17:21:0C:09
          inet addr:192.168.0.1  Bcast:192.168.0.127
Mask:255.255.255.128
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:58833 errors:0 dropped:0 overruns:0 frame:0
          TX packets:201 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:4058208 (3.8 Mb)  TX bytes:48318 (47.1 Kb)
          Base address:0x4000 Memory:b8920000-b8940000

eth6      Link encap:Ethernet  HWaddr 00:15:17:21:0C:08
          BROADCAST MULTICAST  MTU:1500  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:0 (0.0 b)  TX bytes:0 (0.0 b)
          Base address:0x4020 Memory:b8960000-b8980000

eth7      Link encap:Ethernet  HWaddr 00:15:17:17:B7:69
          BROADCAST MULTICAST  MTU:1500  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:0 (0.0 b)  TX bytes:0 (0.0 b)
          Base address:0x3000 Memory:b8800000-b8820000

eth8      Link encap:Ethernet  HWaddr 00:15:17:17:B7:68
          BROADCAST MULTICAST  MTU:1500  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:0 (0.0 b)  TX bytes:0 (0.0 b)
          Base address:0x3020 Memory:b8820000-b8840000

lo        Link encap:Local Loopback
          inet addr:127.0.0.1  Mask:255.0.0.0
          UP LOOPBACK RUNNING  MTU:16436  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:0 (0.0 b)  TX bytes:0 (0.0 b)



> 
> Jesse

