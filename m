From: "Robert Iakobashvili" <coroberti@gmail.com>
Subject: Network card IRQ balancing with Intel 5000 series chipsets
Date: Sun, 24 Dec 2006 11:34:31 +0200
Message-ID: <7e63f56c0612240134s452f6510h8483fb31e5efe799@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.191]:35046 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754226AbWLXJee (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Dec 2006 04:34:34 -0500
Received: by nf-out-0910.google.com with SMTP id o25so4066523nfa
        for <netdev@vger.kernel.org>; Sun, 24 Dec 2006 01:34:32 -0800 (PST)
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sorry for repeating, now in text mode.

Is there a way to balance IRQs from a network card among Intel CPU cores
with Intel 5000 series chipset?

We tried the Broadcom network card (lspci is below) both in MSI and
io-apic mode, but found that the card interrupt may be moved to
another logical CPU, but not balanced among CPUs/cores.

Is that a policy of Intel chipset, that linux cannot overwrite? Can it
be configured
somewhere and by which tools?

Any clues and directions would be very much appreciated.

--------------------------------------------------------------------------------
CONFIG_IRQ_BALANCE=y
and with the same (2.6.9, patched) kernel irq balancing works properly
with older
Intel and with AMD HW.

#lspci -v
Is there a way to balance IRQs from a network card among Intel CPU cores
with Intel 5000 series chipset?

We tried the Broadcom network card (below lspci) both in MSI and
io-apic mode, but
found that the card interrupt may be moved to another logical CPU, but
not balanced
among CPUs/cores.

Is that a policy of Intel chipset, that linux cannot overwrite? Can it
be configured
somewhere and by which tools?

Any clues and directions would be very much appreciated.

--------------------------------------------------------------------------------
CONFIG_IRQ_BALANCE=y
and with the same (2.6.9, patched) kernel irq balancing works properly
with older
Intel and with AMD HW.

#lspci -v
00:00.0 Host bridge: Intel Corporation 5000P Chipset Memory Controller
Hub (rev 92)
        Subsystem: Intel Corporation: Unknown device 8086
        Flags: bus master, fast devsel, latency 0, IRQ 169
        Capabilities: [50] Power Management version 2
        Capabilities: [58] Message Signalled Interrupts: 64bit-
Queue=0/1 Enable-
        Capabilities: [6c] Express Root Port (Slot-) IRQ 0
        Capabilities: [100] Advanced Error Reporting

00:02.0 PCI bridge: Intel Corporation 5000 Series Chipset PCI Express
x4 Port 2 (rev 92) (prog-if 00 [Normal decode])        Flags: bus
master, fast devsel, latency 0
        Bus: primary=00, secondary=1a, subordinate=25, sec-latency=0
        Capabilities: [50] Power Management version 2
        Capabilities: [58] Message Signalled Interrupts: 64bit-
Queue=0/1 Enable-
        Capabilities: [6c] Express Root Port (Slot-) IRQ 0
        Capabilities: [100] Advanced Error Reporting

00:03.0 PCI bridge: Intel Corporation 5000 Series Chipset PCI Express
x4 Port 3 (rev 92) (prog-if 00 [Normal decode])        Flags: bus
master, fast devsel, latency 0
        Bus: primary=00, secondary=04, subordinate=04, sec-latency=0
        I/O behind bridge: 00005000-00005fff
        Memory behind bridge: c8000000-c9ffffff
        Prefetchable memory behind bridge: 00000000c7f00000-00000000c7f00000
        Capabilities: [50] Power Management version 2
        Capabilities: [58] Message Signalled Interrupts: 64bit-
Queue=0/1 Enable-
        Capabilities: [6c] Express Root Port (Slot-) IRQ 0
        Capabilities: [100] Advanced Error Reporting

00:04.0 PCI bridge: Intel Corporation 5000 Series Chipset PCI Express
x8 Port 4-5 (rev 92) (prog-if 00 [Normal decode])
        Flags: bus master, fast devsel, latency 0
        Bus: primary=00, secondary=10, subordinate=10, sec-latency=0
        I/O behind bridge: 00006000-0000ffff
        Capabilities: [50] Power Management version 2
        Capabilities: [58] Message Signalled Interrupts: 64bit-
Queue=0/1 Enable-
        Capabilities: [6c] Express Root Port (Slot-) IRQ 0
        Capabilities: [100] Advanced Error Reporting

00:05.0 PCI bridge: Intel Corporation 5000 Series Chipset PCI Express
x4 Port 5 (rev 92) (prog-if 00 [Normal decode])        Flags: fast
devsel
        Bus: primary=00, secondary=45, subordinate=45, sec-latency=0
        Capabilities: [50] Power Management version 2
        Capabilities: [58] Message Signalled Interrupts: 64bit-
Queue=0/1 Enable-
        Capabilities: [6c] Express Root Port (Slot-) IRQ 0
        Capabilities: [100] Advanced Error Reporting

00:06.0 PCI bridge: Intel Corporation 5000 Series Chipset PCI Express
x8 Port 6-7 (rev 92) (prog-if 00 [Normal decode])
        Flags: bus master, fast devsel, latency 0
        Bus: primary=00, secondary=07, subordinate=07, sec-latency=0
        Capabilities: [50] Power Management version 2
        Capabilities: [58] Message Signalled Interrupts: 64bit-
Queue=0/1 Enable-
        Capabilities: [6c] Express Root Port (Slot-) IRQ 0
        Capabilities: [100] Advanced Error Reporting

00:07.0 PCI bridge: Intel Corporation 5000 Series Chipset PCI Express
x4 Port 7 (rev 92) (prog-if 00 [Normal decode])        Flags: fast
devsel
        Bus: primary=00, secondary=44, subordinate=44, sec-latency=0
        Capabilities: [50] Power Management version 2
        Capabilities: [58] Message Signalled Interrupts: 64bit-
Queue=0/1 Enable-
        Capabilities: [6c] Express Root Port (Slot-) IRQ 0
        Capabilities: [100] Advanced Error Reporting

00:08.0 System peripheral: Intel Corporation 5000 Series Chipset DMA
Engine (rev 92)
        Subsystem: IBM: Unknown device 02dd
        Flags: bus master, fast devsel, latency 0, IRQ 169
        Memory at fe700000 (64-bit, non-prefetchable) [size=1K]
        Capabilities: [50] Power Management version 2
        Capabilities: [58] Message Signalled Interrupts: 64bit-
Queue=0/0 Enable-
        Capabilities: [6c] Express Unknown type IRQ 0

00:10.0 Host bridge: Intel Corporation 5000 Series Chipset Error
Reporting Registers (rev 92)
        Subsystem: IBM: Unknown device 02dd
        Flags: fast devsel

00:10.1 Host bridge: Intel Corporation 5000 Series Chipset Error
Reporting Registers (rev 92)
        Subsystem: Intel Corporation: Unknown device 8086
        Flags: fast devsel

00:10.2 Host bridge: Intel Corporation 5000 Series Chipset Error
Reporting Registers (rev 92)
        Subsystem: Intel Corporation: Unknown device 8086
        Flags: fast devsel

00:11.0 Host bridge: Intel Corporation 5000 Series Chipset Reserved
Registers (rev 92)
        Subsystem: Intel Corporation: Unknown device 8086
        Flags: fast devsel

00:13.0 Host bridge: Intel Corporation 5000 Series Chipset Reserved
Registers (rev 92)
        Subsystem: Intel Corporation: Unknown device 8086
        Flags: fast devsel

00:15.0 Host bridge: Intel Corporation 5000 Series Chipset FBD
Registers (rev 92)
        Subsystem: IBM: Unknown device 02dd
        Flags: fast devsel

00:16.0 Host bridge: Intel Corporation 5000 Series Chipset FBD
Registers (rev 92)
        Subsystem: IBM: Unknown device 02dd
        Flags: fast devsel

00:1c.0 PCI bridge: Intel Corporation 631xESB/632xESB/3100 Chipset PCI
Express Root Port 1 (rev 09) (prog-if 00 [Normal decode])
        Flags: bus master, fast devsel, latency 0
        Bus: primary=00, secondary=02, subordinate=03, sec-latency=0
        Memory behind bridge: cd000000-cfffffff
        Capabilities: [40] Express Root Port (Slot-) IRQ 0
        Capabilities: [80] Message Signalled Interrupts: 64bit-
Queue=0/0 Enable-
        Capabilities: [90] #0d [0000]
        Capabilities: [a0] Power Management version 2
        Capabilities: [100] Virtual Channel
        Capabilities: [180] Unknown (5)

00:1c.1 PCI bridge: Intel Corporation 631xESB/632xESB/3100 Chipset PCI
Express Root Port 2 (rev 09) (prog-if 00 [Normal decode])
        Flags: bus master, fast devsel, latency 0
        Bus: primary=00, secondary=05, subordinate=06, sec-latency=0
        Memory behind bridge: ca000000-ccffffff
        Capabilities: [40] Express Root Port (Slot-) IRQ 0
        Capabilities: [80] Message Signalled Interrupts: 64bit-
Queue=0/0 Enable-
        Capabilities: [90] #0d [0000]
        Capabilities: [a0] Power Management version 2
        Capabilities: [100] Virtual Channel
        Capabilities: [180] Unknown (5)

00:1d.0 USB Controller: Intel Corporation 631xESB/632xESB/3100 Chipset
UHCI USB Controller #1 (rev 09) (prog-if 00 [UHCI])
        Subsystem: IBM: Unknown device 02dd
        Flags: bus master, medium devsel, latency 0, IRQ 193
        I/O ports at 2200 [size=32]

00:1d.1 USB Controller: Intel Corporation 631xESB/632xESB/3100 Chipset
UHCI USB Controller #2 (rev 09) (prog-if 00 [UHCI])
        Subsystem: IBM: Unknown device 02dd
        Flags: bus master, medium devsel, latency 0, IRQ 201
        I/O ports at 2600 [size=32]

00:1d.2 USB Controller: Intel Corporation 631xESB/632xESB/3100 Chipset
UHCI USB Controller #3 (rev 09) (prog-if 00 [UHCI])
        Subsystem: IBM: Unknown device 02dd
        Flags: bus master, medium devsel, latency 0, IRQ 193
        I/O ports at 2a00 [size=32]

00:1d.3 USB Controller: Intel Corporation 631xESB/632xESB/3100 Chipset
UHCI USB Controller #4 (rev 09) (prog-if 00 [UHCI])
        Subsystem: IBM: Unknown device 02dd
        Flags: bus master, medium devsel, latency 0, IRQ 201
        I/O ports at 2e00 [size=32]

00:1d.7 USB Controller: Intel Corporation 631xESB/632xESB/3100 Chipset
EHCI USB2 Controller (rev 09) (prog-if 20 [EHCI])
        Subsystem: IBM: Unknown device 02dd
        Flags: bus master, medium devsel, latency 0, IRQ 193
        Memory at f9000000 (32-bit, non-prefetchable) [size=1K]
        Capabilities: [50] Power Management version 2
        Capabilities: [58] Debug port

00:1e.0 PCI bridge: Intel Corporation 82801 PCI Bridge (rev d9)
(prog-if 01 [Subtractive decode])
        Flags: bus master, fast devsel, latency 0
        Bus: primary=00, secondary=01, subordinate=01, sec-latency=0
        I/O behind bridge: 00003000-00004fff
        Memory behind bridge: de000000-dfffffff
        Prefetchable memory behind bridge: 00000000d0000000-00000000ddf00000
        Capabilities: [50] #0d [0000]

00:1f.0 ISA bridge: Intel Corporation 631xESB/632xESB/3100 Chipset LPC
Interface Controller (rev 09)
        Flags: bus master, medium devsel, latency 0

00:1f.2 IDE interface: Intel Corporation 631xESB/632xESB/3100 Chipset
SATA Storage Controller IDE (rev 09) (prog-if 80 [Master])
        Subsystem: IBM: Unknown device 02dd
        Flags: bus master, 66Mhz, medium devsel, latency 0, IRQ 185
        I/O ports at <ignored>
        I/O ports at <ignored>
        I/O ports at <ignored>
        I/O ports at <ignored>
        I/O ports at 0480 [size=16]
        Capabilities: [70] Power Management version 2

00:1f.3 SMBus: Intel Corporation 631xESB/632xESB/3100 Chipset SMBus
Controller (rev 09)
        Subsystem: IBM: Unknown device 02dd
        Flags: medium devsel, IRQ 185
        I/O ports at 0440 [size=32]

01:06.0 VGA compatible controller: ATI Technologies Inc ES1000 (rev
02) (prog-if 00 [VGA])
        Subsystem: IBM: Unknown device 0305
        Flags: bus master, stepping, medium devsel, latency 64, IRQ 201
        Memory at d0000000 (32-bit, prefetchable) [size=128M]
        I/O ports at 4000 [size=256]
        Memory at dfff0000 (32-bit, non-prefetchable) [size=64K]
        Capabilities: [50] Power Management version 2

02:00.0 PCI bridge: Broadcom: Unknown device 0103 (rev c2) (prog-if 00
[Normal decode])
        Flags: bus master, fast devsel, latency 0
        Bus: primary=02, secondary=03, subordinate=03, sec-latency=0
        Memory behind bridge: cd000000-cfffffff
        Capabilities: [60] Express PCI/PCI-X Bridge IRQ 0
        Capabilities: [90] PCI-X bridge device.
        Capabilities: [b0] Power Management version 2
        Capabilities: [100] Advanced Error Reporting
        Capabilities: [14c] Power Budgeting
        Capabilities: [160] Device Serial Number 23-ba-18-fe-ff-5e-14-00

03:00.0 Ethernet controller: Broadcom Corporation NetXtreme II BCM5708
Gigabit Ethernet (rev 11)
        Subsystem: IBM: Unknown device 0342
        Flags: bus master, 66Mhz, medium devsel, latency 64, IRQ 169
        Memory at ce000000 (64-bit, non-prefetchable) [size=32M]
        Capabilities: [40] PCI-X non-bridge device.
        Capabilities: [48] Power Management version 2
        Capabilities: [50] Vital Product Data
        Capabilities: [58] Message Signalled Interrupts: 64bit+
Queue=0/0 Enable-

04:00.0 RAID bus controller: Adaptec AAC-RAID (Rocket) (rev 02)
        Subsystem: IBM ServeRAID 8k/8k-l8
        Flags: bus master, fast devsel, latency 0, IRQ 209
        Memory at c9e00000 (64-bit, non-prefetchable) [size=2M]
        Memory at c7fe0000 (64-bit, prefetchable) [size=128K]
        I/O ports at 5000 [size=256]
        Capabilities: [40] Express Endpoint IRQ 0
        Capabilities: [e0] Message Signalled Interrupts: 64bit+
Queue=0/2 Enable-
        Capabilities: [100] Advanced Error Reporting

05:00.0 PCI bridge: Broadcom: Unknown device 0103 (rev c2) (prog-if 00
[Normal decode])
        Flags: bus master, fast devsel, latency 0
        Bus: primary=05, secondary=06, subordinate=06, sec-latency=0
        Memory behind bridge: ca000000-ccffffff
        Capabilities: [60] Express PCI/PCI-X Bridge IRQ 0
        Capabilities: [90] PCI-X bridge device.
        Capabilities: [b0] Power Management version 2
        Capabilities: [100] Advanced Error Reporting
        Capabilities: [14c] Power Budgeting
        Capabilities: [160] Device Serial Number 25-ba-18-fe-ff-5e-14-00

06:00.0 Ethernet controller: Broadcom Corporation NetXtreme II BCM5708
Gigabit Ethernet (rev 11)
        Subsystem: IBM: Unknown device 0342
        Flags: bus master, 66Mhz, medium devsel, latency 64, IRQ 209
        Memory at ca000000 (64-bit, non-prefetchable) [size=32M]
        Capabilities: [40] PCI-X non-bridge device.
        Capabilities: [48] Power Management version 2
        Capabilities: [50] Vital Product Data
        Capabilities: [58] Message Signalled Interrupts: 64bit+
Queue=0/0 Enable-

1a:00.0 PCI bridge: Intel Corporation 6311ESB/6321ESB PCI Express
Upstream Port (rev 01) (prog-if 00 [Normal decode])        Flags: bus
master, fast devsel, latency 0
        Bus: primary=1a, secondary=1b, subordinate=24, sec-latency=0
        Capabilities: [44] Express Upstream Port IRQ 0
        Capabilities: [70] Power Management version 2
        Capabilities: [80] #0d [0000]
        Capabilities: [100] Advanced Error Reporting

1a:00.3 PCI bridge: Intel Corporation 6311ESB/6321ESB PCI Express to
PCI-X Bridge (rev 01) (prog-if 00 [Normal decode])
        Flags: fast devsel
        Bus: primary=1a, secondary=25, subordinate=25, sec-latency=64
        Capabilities: [44] Express PCI/PCI-X Bridge IRQ 0
        Capabilities: [6c] Power Management version 2
        Capabilities: [80] #0d [0000]
        Capabilities: [d8] PCI-X bridge device.
        Capabilities: [100] Advanced Error Reporting

1b:00.0 PCI bridge: Intel Corporation 6311ESB/6321ESB PCI Express
Downstream Port E1 (rev 01) (prog-if 00 [Normal decode])
        Flags: bus master, fast devsel, latency 0
        Bus: primary=1b, secondary=1c, subordinate=1c, sec-latency=0
        Capabilities: [44] Express Downstream Port (Slot-) IRQ 0
        Capabilities: [60] Message Signalled Interrupts: 64bit+
Queue=0/0 Enable-
        Capabilities: [70] Power Management version 2
        Capabilities: [80] #0d [0000]
        Capabilities: [100] Advanced Error Reporting

1b:01.0 PCI bridge: Intel Corporation 6311ESB/6321ESB PCI Express
Downstream Port E2 (rev 01) (prog-if 00 [Normal decode])
        Flags: bus master, fast devsel, latency 0
        Bus: primary=1b, secondary=24, subordinate=24, sec-latency=0
        Capabilities: [44] Express Downstream Port (Slot-) IRQ 0
        Capabilities: [60] Message Signalled Interrupts: 64bit+
Queue=0/0 Enable-
        Capabilities: [70] Power Management version 2
        Capabilities: [80] #0d [0000]
        Capabilities: [100] Advanced Error Reporting

-- 
Sincerely,
Robert Iakobashvili,
coroberti %x40 gmail %x2e com
...................................................................
Navigare necesse est, vivere non est necesse
...................................................................
http://sourceforge.net/projects/curl-loader
