From: Stuart Anderson <sba@srl.caltech.edu>
Subject: tg3 lockup under load on SMP kernel
Date: Sat, 28 Jun 2003 16:17:56 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200306282317.QAA05803@jelly.caltech.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: linux-net@vger.kernel.org, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I am having a problem with the tg3 driver locking up dual-xeon machines
when put under heavy load if and only if I am running an SMP kernel.
No problems with tg3+UP or bcm5700+SMP or with the a SysKonnect
card under load with either UP or SMP kernel.

The machines are:
dual 2.2GHz P4 Xeon/2GB RAM/Super Micro P4DL6 MOBO running
RedHat7.3 plus whatever kernel is needed. Besides the on-board
Broadcom BCM5701 10/100/1000 copper GigE there is one SysKonnect9843
fiber GigE PCI card and 2 3Ware IDE-RAID cards per machine.

I first ran into this with RH2.4.18, and reproduced the problem with
vanilla 2.4.20 and 2.4.20 plus tg3 1.4c patch at that time. It is now
a more important issue and I am seeing it with RH smp-2.4.20-13.7 but
not the uni-processor 2.4.20-13.7--both of which use the tg3 1.5 driver.

Any suggestions on how to get tg3 running stably under SMP
kernel on a BCM5701 interface would be greatly appreciated.

Here is the output of lspci -v.

# lspci -v
00:00.0 Host bridge: ServerWorks: Unknown device 0012 (rev 13)
        Flags: fast devsel

00:00.1 Host bridge: ServerWorks: Unknown device 0012
        Flags: fast devsel

00:00.2 Host bridge: ServerWorks: Unknown device 0000
        Flags: fast devsel

00:02.0 VGA compatible controller: ATI Technologies Inc Rage XL (rev 27)
(prog-if 00 [VGA])
        Subsystem: ATI Technologies Inc Rage XL
        Flags: bus master, stepping, medium devsel, latency 64, IRQ 11
        Memory at fb000000 (32-bit, non-prefetchable) [size=16M]
        I/O ports at a800 [size=256]
        Memory at fc7ff000 (32-bit, non-prefetchable) [size=4K]
        Expansion ROM at fc7c0000 [disabled] [size=128K]
        Capabilities: [5c] Power Management version 2

00:04.0 Ethernet controller: Intel Corp. 82557/8/9 [Ethernet Pro 100] (rev 0d)
        Subsystem: Intel Corp. EtherExpress PRO/100 S Server Adapter
        Flags: bus master, medium devsel, latency 64, IRQ 9
        Memory at fc7fd000 (32-bit, non-prefetchable) [size=4K]
        I/O ports at af00 [size=64]
        Memory at fc7a0000 (32-bit, non-prefetchable) [size=128K]
        Expansion ROM at fc7e0000 [disabled] [size=64K]
        Capabilities: [dc] Power Management version 2
                          
00:0f.0 ISA bridge: ServerWorks CSB5 South Bridge (rev 93)
        Subsystem: Unknown device d915:5538
        Flags: bus master, medium devsel, latency 64
                          
00:0f.1 IDE interface: ServerWorks CSB5 IDE Controller (rev 93) (prog-if 8a [Master SecP PriP])
        Subsystem: ServerWorks CSB5 IDE Controller
        Flags: bus master, medium devsel, latency 64
        I/O ports at <ignored>
        I/O ports at <ignored>
        I/O ports at <ignored>
        I/O ports at <ignored>
        I/O ports at ffa0 [size=16]
                          
00:0f.2 USB Controller: ServerWorks OSB4/CSB5 USB Controller (rev 05) (prog-if 10 [OHCI])
        Subsystem: ServerWorks OSB4/CSB5 USB Controller
        Flags: bus master, medium devsel, latency 64, IRQ 10
        Memory at fc7fe000 (32-bit, non-prefetchable) [size=4K]
                          
00:0f.3 Host bridge: ServerWorks: Unknown device 0225
        Subsystem: Unknown device d915:5538
        Flags: bus master, medium devsel, latency 0
                          
00:10.0 Host bridge: ServerWorks: Unknown device 0101 (rev 03)
        Flags: 66Mhz, medium devsel
        Capabilities: [60] PCI-X non-bridge device.
                          
00:10.2 Host bridge: ServerWorks: Unknown device 0101 (rev 03)
        Flags: 66Mhz, medium devsel
        Capabilities: [60] PCI-X non-bridge device.
                          
00:11.0 Host bridge: ServerWorks: Unknown device 0101 (rev 03)
        Flags: 66Mhz, medium devsel
        Capabilities: [60] PCI-X non-bridge device.
                          
00:11.2 Host bridge: ServerWorks: Unknown device 0101 (rev 03)
        Flags: 66Mhz, medium devsel
        Capabilities: [60] PCI-X non-bridge device.
                          
01:02.0 RAID bus controller: 3ware Inc 3ware 7000-series ATA-RAID (rev 01)
        Subsystem: 3ware Inc 3ware 7000-series ATA-RAID
        Flags: bus master, medium devsel, latency 64, IRQ 10
        I/O ports at bfa0 [size=16]
        Memory at fd8ffc00 (32-bit, non-prefetchable) [size=16]
        Memory at fd000000 (32-bit, non-prefetchable) [size=8M]
        Expansion ROM at fd8e0000 [disabled] [size=64K]
        Capabilities: [40] Power Management version 1
                          
01:03.0 Ethernet controller: BROADCOM Corporation NetXtreme BCM5701 Gigabit Ethernet (rev 15)
        Subsystem: BROADCOM Corporation: Unknown device 1644
        Flags: bus master, 66Mhz, medium devsel, latency 64, IRQ 5
        Memory at fd8d0000 (64-bit, non-prefetchable) [size=64K]
        Expansion ROM at fd8c0000 [disabled] [size=64K]
        Capabilities: [40] PCI-X non-bridge device.
        Capabilities: [48] Power Management version 2
        Capabilities: [50] Vital Product Data
        Capabilities: [58] Message Signalled Interrupts: 64bit+ Queue=0/3 Enable-
                          
02:02.0 RAID bus controller: 3ware Inc 3ware 7000-series ATA-RAID (rev 01)
        Subsystem: 3ware Inc 3ware 7000-series ATA-RAID
        Flags: bus master, medium devsel, latency 64, IRQ 7
        I/O ports at cfa0 [size=16]
        Memory at fe9ffc00 (32-bit, non-prefetchable) [size=16]
        Memory at fe000000 (32-bit, non-prefetchable) [size=8M]
        Expansion ROM at fe9e0000 [disabled] [size=64K]
        Capabilities: [40] Power Management version 1
                          
03:02.0 Ethernet controller: Syskonnect (Schneider & Koch) Gigabit Ethernet (rev 12)
        Subsystem: Syskonnect (Schneider & Koch) SK-9843 (1000Base-SX single link)
        Flags: bus master, 66Mhz, medium devsel, latency 64, IRQ 11
        Memory at feafc000 (32-bit, non-prefetchable) [size=16K]
        I/O ports at d800 [size=256]
        Expansion ROM at feac0000 [disabled] [size=128K]
        Capabilities: [48] Power Management version 1
        Capabilities: [50] Vital Product Data


-- 
Stuart Anderson  sba@srl.caltech.edu  http://www.srl.caltech.edu/personnel/sba
