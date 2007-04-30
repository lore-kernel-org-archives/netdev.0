From: "Tim Durack" <tdurack@gmail.com>
Subject: Re: r8169 ethernet bonding problems
Date: Mon, 30 Apr 2007 10:39:10 -0400
Message-ID: <9e246b4d0704300739g1f2aa94co6cbd86a3b5e24e41@mail.gmail.com>
References: <9e246b4d0704180552q16b05017wd0d7041c3ce04f46@mail.gmail.com>
	 <20070418181333.GA2261@electric-eye.fr.zoreil.com>
	 <9e246b4d0704271353g105ecd62j4f35a6e9027ad590@mail.gmail.com>
	 <20070427220918.GB24358@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Francois Romieu" <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.233]:19700 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423315AbXD3OjL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Apr 2007 10:39:11 -0400
Received: by wx-out-0506.google.com with SMTP id h31so1551029wxd
        for <netdev@vger.kernel.org>; Mon, 30 Apr 2007 07:39:10 -0700 (PDT)
In-Reply-To: <20070427220918.GB24358@electric-eye.fr.zoreil.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Can you revert patch #0012 and see if it changes this part of the problem ?

Reverted. mac is still wrong - I assume the eprom got corrupted somehow.

~# modprobe r8169
r8169 Gigabit Ethernet driver 2.2LK-NAPI loaded
ACPI: PCI Interrupt 0000:00:09.0[A] -> GSI 18 (level, low) -> IRQ 16
eth1: RTL8169sc/8110sc at 0xf8838000, 00:00:00:00:68:93, IRQ 16
r8169 Gigabit Ethernet driver 2.2LK-NAPI loaded
ACPI: PCI Interrupt 0000:00:0b.0[A] -> GSI 19 (level, low) -> IRQ 17
eth2: RTL8169sc/8110sc at 0xf883a000, 00:30:18:ab:68:94, IRQ 17
r8169 Gigabit Ethernet driver 2.2LK-NAPI loaded
ACPI: PCI Interrupt 0000:00:0c.0[A] -> GSI 16 (level, low) -> IRQ 18
eth4: RTL8169sc/8110sc at 0xf8a76000, 00:30:18:ab:68:95, IRQ 18

I can work around this with an "ip links set dev eth5 addr" for now.

Strange things is, this group of interfaces used to get initialised as
eth0/1/2, in sequence. Now one of the interfaces is always out of
order.

> A tcpdump trace 1) before promiscuous mode 2) after promiscuous mode 3)
> after link failure (i.e. failover does not work) would be welcome.

Will get these shortly.

lspci -vx:

00:00.0 Host bridge: VIA Technologies, Inc. CN700/VN800/P4M800CE/Pro Host Bridge
	Subsystem: VIA Technologies, Inc. CN700/VN800/P4M800CE/Pro Host Bridge
	Flags: bus master, 66MHz, medium devsel, latency 8
	Memory at e8000000 (32-bit, prefetchable) [size=128M]
	Capabilities: [80] AGP version 3.5
	Capabilities: [50] Power Management version 2
00: 06 11 14 03 06 00 30 22 00 00 00 06 00 08 80 00
10: 08 00 00 e8 00 00 00 00 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 06 11 14 03
30: 00 00 00 00 80 00 00 00 00 00 00 00 00 00 00 00

00:00.1 Host bridge: VIA Technologies, Inc. CN700/VN800/P4M800CE/Pro Host Bridge
	Flags: bus master, medium devsel, latency 0
00: 06 11 14 13 06 00 00 02 00 00 00 06 00 00 00 00
10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
30: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

00:00.2 Host bridge: VIA Technologies, Inc. CN700/VN800/P4M800CE/Pro Host Bridge
	Flags: bus master, medium devsel, latency 0
00: 06 11 14 23 06 00 00 02 00 00 00 06 00 00 00 00
10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
30: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

00:00.3 Host bridge: VIA Technologies, Inc. PT890 Host Bridge
	Flags: bus master, medium devsel, latency 0
00: 06 11 08 32 06 00 00 02 00 00 00 06 00 00 00 00
10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
30: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

00:00.4 Host bridge: VIA Technologies, Inc. CN700/VN800/P4M800CE/Pro Host Bridge
	Flags: bus master, medium devsel, latency 0
00: 06 11 14 43 06 00 00 02 00 00 00 06 00 00 00 00
10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
30: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

00:00.7 Host bridge: VIA Technologies, Inc. CN700/VN800/P4M800CE/Pro Host Bridge
	Flags: bus master, medium devsel, latency 0
00: 06 11 14 73 06 00 00 02 00 00 00 06 00 00 00 00
10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
30: 00 00 00 00 a0 00 00 00 00 00 00 00 00 00 00 00

00:01.0 PCI bridge: VIA Technologies, Inc. VT8237 PCI Bridge (prog-if
00 [Normal decode])
	Flags: bus master, 66MHz, medium devsel, latency 0
	Bus: primary=00, secondary=01, subordinate=01, sec-latency=0
	I/O behind bridge: 0000d000-0000dfff
	Memory behind bridge: fb000000-fcffffff
	Prefetchable memory behind bridge: f4000000-f7ffffff
	Capabilities: [70] Power Management version 2
00: 06 11 98 b1 07 00 30 02 00 00 04 06 00 00 01 00
10: 00 00 00 00 00 00 00 00 00 01 01 00 d0 d0 20 e2
20: 00 fb f0 fc 00 f4 f0 f7 00 00 00 00 00 00 00 00
30: 00 00 00 00 70 00 00 00 00 00 00 00 00 00 08 00

00:09.0 Ethernet controller: Realtek Semiconductor Co., Ltd. RTL-8169
Gigabit Ethernet (rev 10)
	Subsystem: Jetway Information Co., Ltd. Unknown device 10ec
	Flags: bus master, 66MHz, medium devsel, latency 64, IRQ 16
	I/O ports at f200 [size=256]
	Memory at fdfff000 (32-bit, non-prefetchable) [size=256]
	[virtual] Expansion ROM at 40000000 [disabled] [size=64K]
	Capabilities: [dc] Power Management version 2
00: ec 10 69 81 17 00 b0 02 10 00 00 02 08 40 00 00
10: 01 f2 00 00 00 f0 ff fd 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 f3 16 ec 10
30: 00 00 00 00 dc 00 00 00 00 00 00 00 0b 01 20 40

00:0a.0 FireWire (IEEE 1394): VIA Technologies, Inc. IEEE 1394 Host
Controller (rev 80) (prog-if 10 [OHCI])
	Subsystem: VIA Technologies, Inc. IEEE 1394 Host Controller
	Flags: bus master, stepping, medium devsel, latency 32, IRQ 17
	Memory at fdffe000 (32-bit, non-prefetchable) [size=2K]
	I/O ports at ff00 [size=128]
	Capabilities: [50] Power Management version 2
00: 06 11 44 30 87 00 10 02 80 10 00 0c 01 20 00 00
10: 00 e0 ff fd 01 ff 00 00 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 06 11 44 30
30: 00 00 00 00 50 00 00 00 00 00 00 00 05 01 00 20

00:0b.0 Ethernet controller: Realtek Semiconductor Co., Ltd. RTL-8169
Gigabit Ethernet (rev 10)
	Subsystem: Jetway Information Co., Ltd. Unknown device 10ec
	Flags: bus master, 66MHz, medium devsel, latency 64, IRQ 17
	I/O ports at f000 [size=256]
	Memory at fdffd000 (32-bit, non-prefetchable) [size=256]
	[virtual] Expansion ROM at 40010000 [disabled] [size=64K]
	Capabilities: [dc] Power Management version 2
00: ec 10 69 81 17 00 b0 02 10 00 00 02 08 40 00 00
10: 01 f0 00 00 00 d0 ff fd 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 f3 16 ec 10
30: 00 00 00 00 dc 00 00 00 00 00 00 00 05 01 20 40

00:0c.0 Ethernet controller: Realtek Semiconductor Co., Ltd. RTL-8169
Gigabit Ethernet (rev 10)
	Subsystem: Jetway Information Co., Ltd. Unknown device 10ec
	Flags: bus master, 66MHz, medium devsel, latency 64, IRQ 18
	I/O ports at ec00 [size=256]
	Memory at fdffc000 (32-bit, non-prefetchable) [size=256]
	[virtual] Expansion ROM at 40020000 [disabled] [size=64K]
	Capabilities: [dc] Power Management version 2
00: ec 10 69 81 17 00 b0 02 10 00 00 02 08 40 00 00
10: 01 ec 00 00 00 c0 ff fd 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 f3 16 ec 10
30: 00 00 00 00 dc 00 00 00 00 00 00 00 0a 01 20 40

00:0f.0 IDE interface: VIA Technologies, Inc. VIA VT6420 SATA RAID
Controller (rev 80) (prog-if 8f [Master SecP SecO PriP PriO])
	Subsystem: VIA Technologies, Inc. VIA VT6420 SATA RAID Controller
	Flags: bus master, medium devsel, latency 32, IRQ 21
	I/O ports at fe00 [size=8]
	I/O ports at fd00 [size=4]
	I/O ports at fc00 [size=8]
	I/O ports at fb00 [size=4]
	I/O ports at fa00 [size=16]
	I/O ports at ee00 [size=256]
	Capabilities: [c0] Power Management version 2
00: 06 11 49 31 07 00 90 02 80 8f 01 01 00 20 80 00
10: 01 fe 00 00 01 fd 00 00 01 fc 00 00 01 fb 00 00
20: 01 fa 00 00 01 ee 00 00 00 00 00 00 06 11 49 31
30: 00 00 00 00 c0 00 00 00 00 00 00 00 0b 02 00 00

00:0f.1 IDE interface: VIA Technologies, Inc.
VT82C586A/B/VT82C686/A/B/VT823x/A/C PIPC Bus Master IDE (rev 06)
(prog-if 8a [Master SecP PriP])
	Subsystem: VIA Technologies, Inc.
VT82C586/B/VT82C686/A/B/VT8233/A/C/VT8235 PIPC Bus Master IDE
	Flags: bus master, medium devsel, latency 32, IRQ 21
	[virtual] Memory at 000001f0 (32-bit, non-prefetchable) [size=8]
	[virtual] Memory at 000003f0 (type 3, non-prefetchable) [size=1]
	[virtual] Memory at 00000170 (32-bit, non-prefetchable) [size=8]
	[virtual] Memory at 00000370 (type 3, non-prefetchable) [size=1]
	I/O ports at f900 [size=16]
	Capabilities: [c0] Power Management version 2
00: 06 11 71 05 07 00 90 02 06 8a 01 01 00 20 00 00
10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
20: 01 f9 00 00 00 00 00 00 00 00 00 00 06 11 71 05
30: 00 00 00 00 c0 00 00 00 00 00 00 00 ff 01 00 00

00:10.0 USB Controller: VIA Technologies, Inc. VT82xxxxx UHCI USB 1.1
Controller (rev 81) (prog-if 00 [UHCI])
	Subsystem: VIA Technologies, Inc. VT82xxxxx UHCI USB 1.1 Controller
	Flags: bus master, medium devsel, latency 32, IRQ 19
	I/O ports at f800 [size=32]
	Capabilities: [80] Power Management version 2
00: 06 11 38 30 07 00 10 02 81 00 03 0c 01 20 80 00
10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
20: 01 f8 00 00 00 00 00 00 00 00 00 00 06 11 38 30
30: 00 00 00 00 80 00 00 00 00 00 00 00 0a 01 00 00

00:10.1 USB Controller: VIA Technologies, Inc. VT82xxxxx UHCI USB 1.1
Controller (rev 81) (prog-if 00 [UHCI])
	Subsystem: VIA Technologies, Inc. VT82xxxxx UHCI USB 1.1 Controller
	Flags: bus master, medium devsel, latency 32, IRQ 19
	I/O ports at f700 [size=32]
	Capabilities: [80] Power Management version 2
00: 06 11 38 30 07 00 10 02 81 00 03 0c 01 20 80 00
10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
20: 01 f7 00 00 00 00 00 00 00 00 00 00 06 11 38 30
30: 00 00 00 00 80 00 00 00 00 00 00 00 0a 01 00 00

00:10.2 USB Controller: VIA Technologies, Inc. VT82xxxxx UHCI USB 1.1
Controller (rev 81) (prog-if 00 [UHCI])
	Subsystem: VIA Technologies, Inc. VT82xxxxx UHCI USB 1.1 Controller
	Flags: bus master, medium devsel, latency 32, IRQ 19
	I/O ports at f600 [size=32]
	Capabilities: [80] Power Management version 2
00: 06 11 38 30 07 00 10 02 81 00 03 0c 01 20 80 00
10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
20: 01 f6 00 00 00 00 00 00 00 00 00 00 06 11 38 30
30: 00 00 00 00 80 00 00 00 00 00 00 00 0b 02 00 00

00:10.3 USB Controller: VIA Technologies, Inc. VT82xxxxx UHCI USB 1.1
Controller (rev 81) (prog-if 00 [UHCI])
	Subsystem: VIA Technologies, Inc. VT82xxxxx UHCI USB 1.1 Controller
	Flags: bus master, medium devsel, latency 32, IRQ 19
	I/O ports at f500 [size=32]
	Capabilities: [80] Power Management version 2
00: 06 11 38 30 07 00 10 02 81 00 03 0c 01 20 80 00
10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
20: 01 f5 00 00 00 00 00 00 00 00 00 00 06 11 38 30
30: 00 00 00 00 80 00 00 00 00 00 00 00 0b 02 00 00

00:10.4 USB Controller: VIA Technologies, Inc. USB 2.0 (rev 86)
(prog-if 20 [EHCI])
	Subsystem: VIA Technologies, Inc. USB 2.0
	Flags: bus master, medium devsel, latency 32, IRQ 19
	Memory at fdffb000 (32-bit, non-prefetchable) [size=256]
	Capabilities: [80] Power Management version 2
00: 06 11 04 31 16 00 10 02 86 20 03 0c 08 20 80 00
10: 00 b0 ff fd 00 00 00 00 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 06 11 04 31
30: 00 00 00 00 80 00 00 00 00 00 00 00 0b 03 00 00

00:11.0 ISA bridge: VIA Technologies, Inc. VT8237 ISA bridge
[KT600/K8T800/K8T890 South]
	Subsystem: VIA Technologies, Inc. DFI KT600-AL Motherboard
	Flags: bus master, stepping, medium devsel, latency 0
	Capabilities: [c0] Power Management version 2
00: 06 11 27 32 87 00 10 02 00 00 01 06 00 00 80 00
10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 06 11 27 32
30: 00 00 00 00 c0 00 00 00 00 00 00 00 00 00 00 00

00:11.5 Multimedia audio controller: VIA Technologies, Inc.
VT8233/A/8235/8237 AC97 Audio Controller (rev 60)
	Subsystem: Jetway Information Co., Ltd. Unknown device 4170
	Flags: medium devsel, IRQ 22
	I/O ports at ea00 [size=256]
	Capabilities: [c0] Power Management version 2
00: 06 11 59 30 01 00 10 02 60 00 01 04 00 00 00 00
10: 01 ea 00 00 00 00 00 00 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 f3 16 70 41
30: 00 00 00 00 c0 00 00 00 00 00 00 00 0b 03 00 00

00:12.0 Ethernet controller: VIA Technologies, Inc. VT6102 [Rhine-II] (rev 78)
	Subsystem: VIA Technologies, Inc. VT6102 [Rhine II] Embeded Ethernet
Controller on VT8235
	Flags: bus master, stepping, medium devsel, latency 32, IRQ 20
	I/O ports at e800 [size=256]
	Memory at fdffa000 (32-bit, non-prefetchable) [size=256]
	Capabilities: [40] Power Management version 2
00: 06 11 65 30 87 00 10 02 78 00 00 02 01 20 00 00
10: 01 e8 00 00 00 a0 ff fd 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 06 11 02 01
30: 00 00 00 00 40 00 00 00 00 00 00 00 0a 01 03 08

01:00.0 VGA compatible controller: VIA Technologies, Inc. UniChrome
Pro IGP (rev 01) (prog-if 00 [VGA])
	Subsystem: VIA Technologies, Inc. UniChrome Pro IGP
	Flags: bus master, 66MHz, medium devsel, latency 32, IRQ 10
	Memory at f4000000 (32-bit, prefetchable) [size=64M]
	Memory at fb000000 (32-bit, non-prefetchable) [size=16M]
	[virtual] Expansion ROM at fc000000 [disabled] [size=64K]
	Capabilities: [60] Power Management version 2
	Capabilities: [70] AGP version 3.0
00: 06 11 44 33 07 00 30 02 01 00 00 03 00 20 00 00
10: 08 00 00 f4 00 00 00 fb 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 06 11 44 33
30: 00 00 00 00 60 00 00 00 00 00 00 00 0a 01 02 00
