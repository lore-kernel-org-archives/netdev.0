From: Mikael Pettersson <mikpe@it.uu.se>
Subject: occasional netdev watchdog timeouts with sungem on Apple G5
Date: Wed, 27 Jan 2010 15:21:23 +0100
Message-ID: <19296.19427.642026.703829@pilspetsen.it.uu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755297Ab0A0OVg@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

For a few months now I've been getting very occasional netdev
watchdog timeouts on the built-in sungem ethernet in my G5. I
can't say exactly when it started, but probably post-2.6.30.

The kernel always recovers so it's not a big problem, but I find it
a bit alarming since I never see this with any other ethernet driver.

dmesg from 2.6.33-rc4:

sungem.c:v0.98 8/24/03 David S. Miller (davem@redhat.com)
PHY ID: 2062e0, addr: 1
eth0: Sun GEM (PCI) 10/100/1000BaseT Ethernet 00:0a:95:aa:66:50
eth0: Found BCM5421-K2 PHY
...
eth0: Link is up at 100 Mbps, full-duplex.
...
eth0: Pause is enabled (rxfifo: 10240 off: 7168 on: 5632)
...
NETDEV WATCHDOG: eth0 (gem): transmit queue 0 timed out
------------[ cut here ]------------
Badness at net/sched/sch_generic.c:255
NIP: c0000000002812ac LR: c0000000002812a8 CTR: 0000000000000001
REGS: c0000001f3513750 TRAP: 0700   Not tainted  (2.6.33-rc4)
MSR: 9000000000029032 <EE,ME,CE,IR,DR>  CR: 28000484  XER: 20000000
TASK = c0000001f6390000[2856] 'sshd' THREAD: c0000001f3510000 CPU: 1
GPR00: c0000000002812a8 c0000001f35139d0 c000000000457ed0 000000000000003e 
GPR04: 0000000000000000 ffffffffffffffff 0000000000000000 000000000001ffff 
GPR08: c0000000004788b8 c0000000003c8f08 c0000000004788b8 0000000008bb9000 
GPR12: 0000000028000482 c000000000474680 0000000020103670 00000000806595c4 
GPR16: 00000000631b65ac 0000000000000100 c00000000044a740 c00000000045d300 
GPR20: c0000001f60d5020 c0000001f60d5420 c0000001f60d5820 ffffffffffffffff 
GPR24: 0000000000000001 0000000000000000 0000000000000000 0000000000000002 
GPR28: 0000000000000001 0000000000000000 c000000000412258 c0000001f4750000 
NIP [c0000000002812ac] .dev_watchdog+0x1d0/0x310
LR [c0000000002812a8] .dev_watchdog+0x1cc/0x310
Call Trace:
[c0000001f35139d0] [c0000000002812a8] .dev_watchdog+0x1cc/0x310 (unreliable)
[c0000001f3513ad0] [c000000000054890] .run_timer_softirq+0x1c4/0x2a0
[c0000001f3513bd0] [c00000000004e870] .__do_softirq+0xf0/0x1d0
[c0000001f3513ca0] [c00000000000bbc0] .do_softirq+0x50/0x94
[c0000001f3513d20] [c00000000004e5c0] .irq_exit+0x54/0xb0
[c0000001f3513da0] [c00000000001be6c] .timer_interrupt+0xb4/0xe0
[c0000001f3513e30] [c000000000003610] decrementer_common+0x110/0x180
Instruction dump:
41fe0040 38810070 7fe3fb78 38a00040 4bfe96b1 60000000 7fa6eb78 7fe4fb78 
7c651b78 e87e8028 48054ee5 60000000 <0fe00000> e93e8020 38000001 98090000 
eth0: transmit timed out, resetting
eth0: TX_STATE[003ffc05:00000001:0000001f]
eth0: RX_STATE[0100c805:00000001:00000021]
eth0: Link is up at 1000 Mbps, full-duplex.
eth0: Pause is enabled (rxfifo: 10240 off: 7168 on: 5632)
eth0: transmit timed out, resetting
eth0: TX_STATE[00000001:00000000:00000001]
eth0: RX_STATE[00064801:00000000:00000001]
eth0: Link is up at 100 Mbps, full-duplex.
eth0: Pause is enabled (rxfifo: 10240 off: 7168 on: 5632)
eth0: transmit timed out, resetting
eth0: TX_STATE[003ffc05:00000001:0000001f]
eth0: RX_STATE[0100c805:00000001:00000021]
eth0: Link is up at 100 Mbps, full-duplex.
eth0: Pause is enabled (rxfifo: 10240 off: 7168 on: 5632)

lspci -v:

0000:f0:0b.0 Host bridge: Apple Computer Inc. U3 AGP
	Flags: bus master, 66MHz, medium devsel, latency 16
	Capabilities: <access denied>

0000:f0:10.0 VGA compatible controller: nVidia Corporation NV34 [GeForce FX 5200 Ultra] (rev a1) (prog-if 00 [VGA controller])
	Subsystem: nVidia Corporation Unknown device 0010
	Flags: bus master, 66MHz, medium devsel, latency 16, IRQ 48
	Memory at a1000000 (32-bit, non-prefetchable) [size=16M]
	Memory at a8000000 (32-bit, prefetchable) [size=128M]
	Expansion ROM at a0000000 [disabled] [size=128K]
	Capabilities: <access denied>

0001:00:00.0 Host bridge: Apple Computer Inc. Unknown device 004a
	Flags: bus master, fast devsel, latency 0
	Capabilities: <access denied>

0001:00:01.0 PCI bridge: Advanced Micro Devices [AMD] AMD-8131 PCI-X Bridge (rev 12) (prog-if 00 [Normal decode])
	Flags: bus master, 66MHz, medium devsel, latency 32
	Bus: primary=00, secondary=06, subordinate=06, sec-latency=32
	Memory behind bridge: 90000000-900fffff
	Capabilities: <access denied>

0001:00:02.0 PCI bridge: Advanced Micro Devices [AMD] AMD-8131 PCI-X Bridge (rev 12) (prog-if 00 [Normal decode])
	Flags: bus master, 66MHz, medium devsel, latency 32
	Bus: primary=00, secondary=07, subordinate=07, sec-latency=32
	Capabilities: <access denied>

0001:00:03.0 PCI bridge: Apple Computer Inc. K2 HT-PCI Bridge (prog-if 00 [Normal decode])
	Flags: bus master, fast devsel, latency 0
	Bus: primary=00, secondary=01, subordinate=01, sec-latency=32
	Memory behind bridge: 80000000-800fffff
	Prefetchable memory behind bridge: 00000000-000fffff
	Capabilities: <access denied>

0001:00:04.0 PCI bridge: Apple Computer Inc. K2 HT-PCI Bridge (prog-if 00 [Normal decode])
	Flags: bus master, fast devsel, latency 0
	Bus: primary=00, secondary=02, subordinate=02, sec-latency=32
	Memory behind bridge: 80100000-801fffff
	Prefetchable memory behind bridge: 00000000-000fffff
	Capabilities: <access denied>

0001:00:05.0 PCI bridge: Apple Computer Inc. K2 HT-PCI Bridge (prog-if 00 [Normal decode])
	Flags: bus master, fast devsel, latency 0
	Bus: primary=00, secondary=03, subordinate=03, sec-latency=32
	Memory behind bridge: 80200000-802fffff
	Prefetchable memory behind bridge: 00000000-000fffff
	Capabilities: <access denied>

0001:00:06.0 PCI bridge: Apple Computer Inc. K2 HT-PCI Bridge (prog-if 00 [Normal decode])
	Flags: bus master, fast devsel, latency 0
	Bus: primary=00, secondary=04, subordinate=04, sec-latency=32
	Memory behind bridge: 80300000-805fffff
	Prefetchable memory behind bridge: 00000000-000fffff
	Capabilities: <access denied>

0001:00:07.0 PCI bridge: Apple Computer Inc. K2 HT-PCI Bridge (prog-if 00 [Normal decode])
	Flags: bus master, fast devsel, latency 0
	Bus: primary=00, secondary=05, subordinate=05, sec-latency=32
	Memory behind bridge: 80600000-806fffff
	Prefetchable memory behind bridge: 00000000-000fffff
	Capabilities: <access denied>

0001:01:07.0 Class ff00: Apple Computer Inc. K2 KeyLargo Mac/IO (rev 20)
	Flags: bus master, medium devsel, latency 16
	Memory at 80000000 (32-bit, non-prefetchable) [size=512K]

0001:01:08.0 USB Controller: Apple Computer Inc. K2 KeyLargo USB (prog-if 10 [OHCI])
	Flags: bus master, medium devsel, latency 16, IRQ 27
	Memory at 80081000 (32-bit, non-prefetchable) [size=4K]

0001:01:09.0 USB Controller: Apple Computer Inc. K2 KeyLargo USB (prog-if 10 [OHCI])
	Flags: bus master, medium devsel, latency 16, IRQ 28
	Memory at 80080000 (32-bit, non-prefetchable) [size=4K]

0001:02:0b.0 USB Controller: NEC Corporation USB (rev 43) (prog-if 10 [OHCI])
	Subsystem: NEC Corporation Hama USB 2.0 CardBus
	Flags: bus master, medium devsel, latency 16, IRQ 63
	Memory at 80102000 (32-bit, non-prefetchable) [size=4K]
	Capabilities: <access denied>

0001:02:0b.1 USB Controller: NEC Corporation USB (rev 43) (prog-if 10 [OHCI])
	Subsystem: NEC Corporation Hama USB 2.0 CardBus
	Flags: bus master, medium devsel, latency 16, IRQ 63
	Memory at 80101000 (32-bit, non-prefetchable) [size=4K]
	Capabilities: <access denied>

0001:02:0b.2 USB Controller: NEC Corporation USB 2.0 (rev 04) (prog-if 20 [EHCI])
	Subsystem: NEC Corporation USB 2.0
	Flags: bus master, medium devsel, latency 16, IRQ 63
	Memory at 80100000 (32-bit, non-prefetchable) [size=256]
	Capabilities: <access denied>

0001:03:0d.0 Class ff00: Apple Computer Inc. K2 ATA/100
	Flags: bus master, medium devsel, latency 32, IRQ 39
	Memory at 80204000 (32-bit, non-prefetchable) [size=16K]

0001:03:0e.0 FireWire (IEEE 1394): Apple Computer Inc. K2 FireWire (prog-if 10 [OHCI])
	Subsystem: Apple Computer Inc. Unknown device 5811
	Flags: bus master, medium devsel, latency 248, IRQ 40
	Memory at 80200000 (32-bit, non-prefetchable) [size=4K]
	Capabilities: <access denied>

0001:04:0f.0 Ethernet controller: Apple Computer Inc. K2 GMAC (Sun GEM)
	Flags: bus master, 66MHz, slow devsel, latency 16, IRQ 41
	Memory at 80400000 (32-bit, non-prefetchable) [size=2M]
	Expansion ROM at 80300000 [disabled] [size=1M]

0001:05:0c.0 IDE interface: Broadcom K2 SATA (prog-if 8f [Master SecP SecO PriP PriO])
	Subsystem: Broadcom K2 SATA
	Flags: bus master, medium devsel, latency 16, IRQ 16
	I/O ports at <unassigned> [disabled]
	I/O ports at <unassigned> [disabled]
	I/O ports at <unassigned> [disabled]
	I/O ports at <unassigned> [disabled]
	I/O ports at <unassigned> [disabled]
	Memory at 80600000 (32-bit, non-prefetchable) [size=8K]

0001:06:03.0 Ethernet controller: Broadcom Corporation NetXtreme BCM5701 Gigabit Ethernet (rev 15)
	Subsystem: Compaq Computer Corporation NC7770 Gigabit Server Adapter (PCI-X, 10/100/1000-T)
	Flags: bus master, 66MHz, medium devsel, latency 16, IRQ 53
	Memory at 90010000 (64-bit, non-prefetchable) [size=64K]
	[virtual] Expansion ROM at 90000000 [disabled] [size=64K]
	Capabilities: <access denied>

Just FYI, in case a pattern emerges etc.

/Mikael
