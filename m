From: "Richard Bollinger" <rabollinger@gmail.com>
Subject: tg3 driver fails with on-board BCM95789 NICS (GigaByte GA-7VCSV)
Date: Tue, 24 Oct 2006 17:32:47 -0400
Message-ID: <7744a2840610241432i42364aaap672f8eb5bf25c066@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.170]:53594 "EHLO
	ug-out-1314.google.com") by vger.kernel.org with ESMTP
	id S1161232AbWJXVdG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Oct 2006 17:33:06 -0400
Received: by ug-out-1314.google.com with SMTP id 32so336432ugm
        for <netdev@vger.kernel.org>; Tue, 24 Oct 2006 14:33:01 -0700 (PDT)
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

GigaByte GA-7VCSV-RH motherboard w/two dual core Xeon's, 4gb RAM,
Intel 5000v Chipset, dual Broadcom 5789 Gigabit Ethernet Controllers,
connected to Dell GigE switch.

Both interfaces work fine with vendor's drivers on Windows 2003, but
using Linux 2.6.18.1 tg3 or vendor's Linux driver, the first interface
only works for a few packets, then stops receiving, while the second
interface doesn't work at all - even to the point of recognizing the
link is up or down.  Same results with 2.6.17.14 and non-smp kernel.

lspci -v output:

00:00.0 Host bridge: Intel Corporation: Unknown device 25d4 (rev 92)
Subsystem: Giga-byte Technology: Unknown device 25d8
Flags: bus master, fast devsel, latency 0
Capabilities: [50] Power Management version 2
Capabilities: [58] Message Signalled Interrupts: 64bit- Queue=0/1 Enable-
Capabilities: [6c] #10 [0041]

00:02.0 PCI bridge: Intel Corporation: Unknown device 25e2 (rev 92)
(prog-if 00 [Normal decode])
Flags: bus master, fast devsel, latency 0
Bus: primary=00, secondary=01, subordinate=05, sec-latency=0
I/O behind bridge: 00002000-00003fff
Memory behind bridge: de000000-de3fffff
Prefetchable memory behind bridge: 00000000d1000000-00000000d1100000
Capabilities: [50] Power Management version 2
Capabilities: [58] Message Signalled Interrupts: 64bit- Queue=0/1 Enable-
Capabilities: [6c] #10 [0041]

00:03.0 PCI bridge: Intel Corporation: Unknown device 25e3 (rev 92)
(prog-if 00 [Normal decode])
Flags: bus master, fast devsel, latency 0
Bus: primary=00, secondary=06, subordinate=06, sec-latency=0
Capabilities: [50] Power Management version 2
Capabilities: [58] Message Signalled Interrupts: 64bit- Queue=0/1 Enable-
Capabilities: [6c] #10 [0041]

00:10.0 Host bridge: Intel Corporation: Unknown device 25f0 (rev 92)
Subsystem: Giga-byte Technology: Unknown device 25f0
Flags: fast devsel

00:10.1 Host bridge: Intel Corporation: Unknown device 25f0 (rev 92)
Subsystem: Giga-byte Technology: Unknown device 25f0
Flags: fast devsel

00:10.2 Host bridge: Intel Corporation: Unknown device 25f0 (rev 92)
Subsystem: Giga-byte Technology: Unknown device 25f0
Flags: fast devsel

00:11.0 Host bridge: Intel Corporation: Unknown device 25f1 (rev 92)
Subsystem: Giga-byte Technology: Unknown device 25f1
Flags: fast devsel

00:13.0 Host bridge: Intel Corporation: Unknown device 25f3 (rev 92)
Subsystem: Giga-byte Technology: Unknown device 25f3
Flags: fast devsel

00:15.0 Host bridge: Intel Corporation: Unknown device 25f5 (rev 92)
Subsystem: Giga-byte Technology: Unknown device 25f5
Flags: fast devsel

00:16.0 Host bridge: Intel Corporation: Unknown device 25f6 (rev 92)
Subsystem: Giga-byte Technology: Unknown device 25f6
Flags: fast devsel

00:1c.0 PCI bridge: Intel Corporation: Unknown device 2690 (rev 09)
(prog-if 00 [Normal decode])
Flags: bus master, fast devsel, latency 0
Bus: primary=00, secondary=07, subordinate=07, sec-latency=0
Capabilities: [40] #10 [0141]
Capabilities: [80] Message Signalled Interrupts: 64bit- Queue=0/0 Enable-
Capabilities: [90] #0d [0000]
Capabilities: [a0] Power Management version 2

00:1c.1 PCI bridge: Intel Corporation: Unknown device 2692 (rev 09)
(prog-if 00 [Normal decode])
Flags: bus master, fast devsel, latency 0
Bus: primary=00, secondary=08, subordinate=08, sec-latency=0
Memory behind bridge: de500000-de5fffff
Capabilities: [40] #10 [0141]
Capabilities: [80] Message Signalled Interrupts: 64bit- Queue=0/0 Enable-
Capabilities: [90] #0d [0000]
Capabilities: [a0] Power Management version 2

00:1c.2 PCI bridge: Intel Corporation: Unknown device 2694 (rev 09)
(prog-if 00 [Normal decode])
Flags: bus master, fast devsel, latency 0
Bus: primary=00, secondary=09, subordinate=09, sec-latency=0
Memory behind bridge: de600000-de6fffff
Capabilities: [40] #10 [0141]
Capabilities: [80] Message Signalled Interrupts: 64bit- Queue=0/0 Enable-
Capabilities: [90] #0d [0000]
Capabilities: [a0] Power Management version 2

00:1c.3 PCI bridge: Intel Corporation: Unknown device 2696 (rev 09)
(prog-if 00 [Normal decode])
Flags: bus master, fast devsel, latency 0
Bus: primary=00, secondary=0a, subordinate=0a, sec-latency=0
Capabilities: [40] #10 [0141]
Capabilities: [80] Message Signalled Interrupts: 64bit- Queue=0/0 Enable-
Capabilities: [90] #0d [0000]
Capabilities: [a0] Power Management version 2

00:1e.0 PCI bridge: Intel Corporation: Unknown device 244e (rev d9)
(prog-if 01 [Subtractive decode])
Flags: bus master, fast devsel, latency 0
Bus: primary=00, secondary=0b, subordinate=0b, sec-latency=32
I/O behind bridge: 00004000-00004fff
Memory behind bridge: de400000-de4fffff
Prefetchable memory behind bridge: 00000000dc000000-00000000ddf00000
Capabilities: [50] #0d [0000]

00:1f.0 ISA bridge: Intel Corporation: Unknown device 2670 (rev 09)
Subsystem: Giga-byte Technology: Unknown device 2670
Flags: bus master, medium devsel, latency 0

00:1f.1 IDE interface: Intel Corporation: Unknown device 269e (rev 09)
(prog-if 8a [Master SecP PriP])
Subsystem: Giga-byte Technology: Unknown device 269e
Flags: bus master, medium devsel, latency 0, IRQ 18
I/O ports at <unassigned>
I/O ports at <unassigned>
I/O ports at <unassigned>
I/O ports at <unassigned>
I/O ports at 1800 [size=16]

00:1f.2 RAID bus controller: Intel Corporation: Unknown device 2682 (rev 09)
Subsystem: Giga-byte Technology: Unknown device 346d
Flags: bus master, 66Mhz, medium devsel, latency 0, IRQ 19
I/O ports at 1838 [size=8]
I/O ports at 182c [size=4]
I/O ports at 1830 [size=8]
I/O ports at 1828 [size=4]
I/O ports at 1840 [size=32]
Memory at de900000 (32-bit, non-prefetchable) [size=1K]
Capabilities: [70] Power Management version 2
Capabilities: [a8] #12 [0010]

00:1f.3 SMBus: Intel Corporation: Unknown device 269b (rev 09)
Subsystem: Giga-byte Technology: Unknown device 269b
Flags: medium devsel, IRQ 19
I/O ports at 1860 [size=32]

01:00.0 PCI bridge: Intel Corporation: Unknown device 3500 (rev 01)
(prog-if 00 [Normal decode])
Flags: bus master, fast devsel, latency 0
Bus: primary=01, secondary=02, subordinate=04, sec-latency=0
I/O behind bridge: 00002000-00002fff
Memory behind bridge: de000000-de1fffff
Prefetchable memory behind bridge: 00000000d1000000-00000000d1000000
Capabilities: [44] #10 [0051]
Capabilities: [70] Power Management version 2
Capabilities: [80] #0d [0000]

01:00.3 PCI bridge: Intel Corporation: Unknown device 350c (rev 01)
(prog-if 00 [Normal decode])
Flags: bus master, fast devsel, latency 0
Bus: primary=01, secondary=05, subordinate=05, sec-latency=0
I/O behind bridge: 00003000-00003fff
Memory behind bridge: de200000-de2fffff
Prefetchable memory behind bridge: 00000000d1100000-00000000d1100000
Capabilities: [44] #10 [0071]
Capabilities: [6c] Power Management version 2
Capabilities: [80] #0d [0000]
Capabilities: [d8] #07 [0003]

02:00.0 PCI bridge: Intel Corporation: Unknown device 3510 (rev 01)
(prog-if 00 [Normal decode])
Flags: bus master, fast devsel, latency 0
Bus: primary=02, secondary=03, subordinate=03, sec-latency=0
I/O behind bridge: 00002000-00002fff
Memory behind bridge: de000000-de1fffff
Prefetchable memory behind bridge: 00000000d1000000-00000000d1000000
Capabilities: [44] #10 [0061]
Capabilities: [60] Message Signalled Interrupts: 64bit+ Queue=0/0 Enable-
Capabilities: [70] Power Management version 2
Capabilities: [80] #0d [0000]

02:02.0 PCI bridge: Intel Corporation: Unknown device 3518 (rev 01)
(prog-if 00 [Normal decode])
Flags: bus master, fast devsel, latency 0
Bus: primary=02, secondary=04, subordinate=04, sec-latency=0
Capabilities: [44] #10 [0061]
Capabilities: [60] Message Signalled Interrupts: 64bit+ Queue=0/0 Enable-
Capabilities: [70] Power Management version 2
Capabilities: [80] #0d [0000]

03:00.0 Unknown mass storage controller: CMD Technology Inc: Unknown
device 3132 (rev 01)
Subsystem: CMD Technology Inc: Unknown device 3132
Flags: bus master, fast devsel, latency 0, IRQ 16
Memory at de100000 (64-bit, non-prefetchable) [size=128]
Memory at de000000 (64-bit, non-prefetchable) [size=16K]
I/O ports at 2080 [size=128]
Expansion ROM at d1000000 [disabled] [size=512K]
Capabilities: [54] Power Management version 2
Capabilities: [5c] Message Signalled Interrupts: 64bit+ Queue=0/0 Enable-
Capabilities: [70] #10 [0011]

05:01.0 RAID bus controller: CMD Technology Inc: Unknown device 3114 (rev 02)
Subsystem: CMD Technology Inc: Unknown device 7114
Flags: bus master, 66Mhz, medium devsel, latency 32, IRQ 24
I/O ports at 3020 [size=8]
I/O ports at 3014 [size=4]
I/O ports at 3018 [size=8]
I/O ports at 3010 [size=4]
I/O ports at 3000 [size=16]
Memory at de200000 (32-bit, non-prefetchable) [size=1K]
Expansion ROM at d1100000 [disabled] [size=512K]
Capabilities: [60] Power Management version 2

08:00.0 Ethernet controller: BROADCOM Corporation: Unknown device 169d (rev 11)
Subsystem: Giga-byte Technology: Unknown device 169d
Flags: bus master, fast devsel, latency 0, IRQ 16
Memory at de500000 (64-bit, non-prefetchable) [size=64K]
Capabilities: [48] Power Management version 2
Capabilities: [50] Vital Product Data
Capabilities: [58] Message Signalled Interrupts: 64bit+ Queue=0/3 Enable-
Capabilities: [d0] #10 [0001]

09:00.0 Ethernet controller: BROADCOM Corporation: Unknown device 169d (rev 11)
Subsystem: Giga-byte Technology: Unknown device 169d
Flags: bus master, fast devsel, latency 0, IRQ 9
Memory at de600000 (64-bit, non-prefetchable) [size=64K]
Capabilities: [48] Power Management version 2
Capabilities: [50] Vital Product Data
Capabilities: [58] Message Signalled Interrupts: 64bit+ Queue=0/3 Enable-
Capabilities: [d0] #10 [0001]

0b:01.0 Ethernet controller: Lite-On Communications Inc LNE100TX (rev 21)
Subsystem: Netgear FA310TX
Flags: bus master, medium devsel, latency 32, IRQ 16
I/O ports at 4000 [size=256]
Memory at de440000 (32-bit, non-prefetchable) [size=256]
Expansion ROM at de480000 [disabled] [size=256K]

0b:02.0 VGA compatible controller: Unknown device 18ca:0020 (prog-if 00 [VGA])
Subsystem: Giga-byte Technology: Unknown device 0020
Flags: 66Mhz, medium devsel
BIST result: 00
Memory at dc000000 (32-bit, prefetchable) [size=32M]
Memory at de400000 (32-bit, non-prefetchable) [size=256K]
I/O ports at 4400 [size=128]
Expansion ROM at <unassigned> [disabled]
Capabilities: [40] Power Management version 2

Interesting portion of dmesg output:
...
tg3.c:v3.65 (August 07, 2006)
PCI: Setting latency timer of device 0000:08:00.0 to 64
eth1: Tigon3 [partno(BCM95789) rev 4101 PHY(5750)] (PCI Express)
10/100/1000BaseT Ethernet 00:16:e6:80:b1:3e
eth1: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[0] Split[0] WireSpeed[1] TSOcap[1]
eth1: dma_rwctrl[76180000] dma_mask[64-bit]
PCI: Setting latency timer of device 0000:09:00.0 to 64
eth2: Tigon3 [partno(BCM95789) rev 4101 PHY(5750)] (PCI Express)
10/100/1000BaseT Ethernet 00:16:e6:80:b1:3f
eth2: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[0] Split[0] WireSpeed[1] TSOcap[1]
eth2: dma_rwctrl[76180000] dma_mask[64-bit]
tg3: eth1: Link is up at 1000 Mbps, full duplex.
tg3: eth1: Flow control is on for TX and on for RX.

Any ideas?  W2003 assigned different IRQ's (17 & 18 vs 16 & 9), but
the IO addresses seem consistent (DE500000-DE50FFFF&
DE600000-DE60FFFF).

Thanks, Rich B
