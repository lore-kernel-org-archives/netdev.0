From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 7974] New: BUG: scheduling while atomic:
 swapper/0x10000100/0
Date: Fri, 9 Feb 2007 13:38:02 -0800
Message-ID: <20070209133802.01286bbb.akpm@linux-foundation.org>
References: <200702091623.l19GNiUP006513@fire-2.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	lpiccilli@gelre.com.br,
	"bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@bugzilla.kernel.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:48167 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752543AbXBIViw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Feb 2007 16:38:52 -0500
In-Reply-To: <200702091623.l19GNiUP006513@fire-2.osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


cond_resched() called from softirq, amongst other problems.

On Fri, 9 Feb 2007 08:23:44 -0800
bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=7974
> 
>            Summary: BUG: scheduling while atomic: swapper/0x10000100/0
>     Kernel Version: 2.6.20
>             Status: NEW
>           Severity: normal
>              Owner: acme@conectiva.com.br
>          Submitter: lpiccilli@gelre.com.br
> 
> 
> The machine hangs in normal boot with 2.6.19 and 2.6.20 after network starts. If
> I boot in single mode and start the services manually, the machine and network
> works fine, but I see this on dmesg:
> 
> Linux version 2.6.20 (root@touche.gelre.net.br) (gcc version 4.1.0 20060515 (Red
> Hat 4.1.0-18)) #6 SMP Mon Feb 5 15:14:30 BRST 2007
> Command line: ro root=/dev/sda2 vga=791 
> BIOS-provided physical RAM map:
>  BIOS-e820: 0000000000000000 - 00000000000a0000 (usable)
>  BIOS-e820: 0000000000100000 - 000000003f7c0000 (usable)
>  BIOS-e820: 000000003f7c0000 - 000000003f7cfc00 (ACPI data)
>  BIOS-e820: 000000003f7cfc00 - 000000003f7ff000 (reserved)
>  BIOS-e820: 000000003f800000 - 0000000040000000 (reserved)
>  BIOS-e820: 00000000e0000000 - 00000000fed00400 (reserved)
>  BIOS-e820: 00000000fed13000 - 00000000feda0000 (reserved)
>  BIOS-e820: 00000000fee00000 - 00000000fee10000 (reserved)
>  BIOS-e820: 00000000ffb00000 - 0000000100000000 (reserved)
> Entering add_active_range(0, 0, 160) 0 entries of 256 used
> Entering add_active_range(0, 256, 260032) 1 entries of 256 used
> end_pfn_map = 1048576
> DMI 2.3 present.
> ACPI: RSDP (v000 DELL                                  ) @ 0x00000000000fd690
> ACPI: RSDT (v001 DELL   PE800    0x00000001 MSFT 0x0100000a) @ 0x00000000000fd6a4
> ACPI: FADT (v001 DELL   PE800    0x00000001 MSFT 0x0100000a) @ 0x00000000000fd6dc
> ACPI: MADT (v001 DELL   PE800    0x00000001 MSFT 0x0100000a) @ 0x00000000000fd750
> ACPI: SPCR (v001 DELL   PE800    0x00000001 MSFT 0x0100000a) @ 0x00000000000fd7c4
> ACPI: HPET (v001 DELL   PE800    0x00000001 MSFT 0x0100000a) @ 0x00000000000fd814
> ACPI: MCFG (v001 DELL   PE800    0x00000001 MSFT 0x0100000a) @ 0x00000000000fd84c
> ACPI: DSDT (v001 DELL   PE800    0x00000001 MSFT 0x0100000e) @ 0x0000000000000000
> Entering add_active_range(0, 0, 160) 0 entries of 256 used
> Entering add_active_range(0, 256, 260032) 1 entries of 256 used
> Zone PFN ranges:
>   DMA             0 ->     4096
>   DMA32        4096 ->  1048576
>   Normal    1048576 ->  1048576
> early_node_map[2] active PFN ranges
>     0:        0 ->      160
>     0:      256 ->   260032
> On node 0 totalpages: 259936
>   DMA zone: 56 pages used for memmap
>   DMA zone: 1279 pages reserved
>   DMA zone: 2665 pages, LIFO batch:0
>   DMA32 zone: 3499 pages used for memmap
>   DMA32 zone: 252437 pages, LIFO batch:31
>   Normal zone: 0 pages used for memmap
> ACPI: PM-Timer IO Port: 0x808
> ACPI: Local APIC address 0xfee00000
> ACPI: LAPIC (acpi_id[0x01] lapic_id[0x00] enabled)
> Processor #0 (Bootup-CPU)
> ACPI: LAPIC (acpi_id[0x02] lapic_id[0x01] enabled)
> Processor #1
> ACPI: LAPIC_NMI (acpi_id[0x01] high edge lint[0x1])
> ACPI: LAPIC_NMI (acpi_id[0x02] high edge lint[0x1])
> ACPI: IOAPIC (id[0x02] address[0xfec00000] gsi_base[0])
> IOAPIC[0]: apic_id 2, address 0xfec00000, GSI 0-23
> ACPI: IOAPIC (id[0x03] address[0xfec80000] gsi_base[32])
> IOAPIC[1]: apic_id 3, address 0xfec80000, GSI 32-55
> ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
> ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
> ACPI: IRQ0 used by override.
> ACPI: IRQ2 used by override.
> ACPI: IRQ9 used by override.
> Setting APIC routing to flat
> ACPI: HPET id: 0xffffffff base: 0xfed00000
> Using ACPI (MADT) for SMP configuration information
> Nosave address range: 00000000000a0000 - 0000000000100000
> Allocating PCI resources starting at 50000000 (gap: 40000000:a0000000)
> PERCPU: Allocating 33024 bytes of per cpu data
> Built 1 zonelists.  Total pages: 255102
> Kernel command line: ro root=/dev/sda2 vga=791 
> Initializing CPU#0
> PID hash table entries: 4096 (order: 12, 32768 bytes)
> Console: colour dummy device 80x25
> Dentry cache hash table entries: 131072 (order: 8, 1048576 bytes)
> Inode-cache hash table entries: 65536 (order: 7, 524288 bytes)
> Checking aperture...
> Memory: 1017476k/1040128k available (3075k kernel code, 21768k reserved, 1225k
> data, 248k init)
> Calibrating delay using timer specific routine.. 6406.66 BogoMIPS (lpj=12813334)
> Mount-cache hash table entries: 256
> CPU: Trace cache: 12K uops, L1 D cache: 16K
> CPU: L2 cache: 1024K
> using mwait in idle threads.
> CPU: Physical Processor ID: 0
> CPU: Processor Core ID: 0
> CPU0: Thermal monitoring enabled (TM1)
> Freeing SMP alternatives: 32k freed
> ACPI: Core revision 20060707
> Using local APIC timer interrupts.
> result 12500392
> Detected 12.500 MHz APIC timer.
> Booting processor 1/2 APIC 0x1
> Initializing CPU#1
> Calibrating delay using timer specific routine.. 6400.14 BogoMIPS (lpj=12800283)
> CPU: Trace cache: 12K uops, L1 D cache: 16K
> CPU: L2 cache: 1024K
> CPU: Physical Processor ID: 0
> CPU: Processor Core ID: 0
> CPU1: Thermal monitoring enabled (TM1)
>               Intel(R) Pentium(R) 4 CPU 3.20GHz stepping 01
> Brought up 2 CPUs
> testing NMI watchdog ... OK.
> time.c: Using 14.318180 MHz WALL HPET GTOD HPET/TSC timer.
> time.c: Detected 3200.112 MHz processor.
> migration_cost=5
> NET: Registered protocol family 16
> ACPI: bus type pci registered
> PCI: Using MMCONFIG at e0000000
> ACPI: Interpreter enabled
> ACPI: Using IOAPIC for interrupt routing
> ACPI: PCI Root Bridge [PCI0] (0000:00)
> PCI: Probing PCI hardware (bus 00)
> Boot video device is 0000:00:02.0
> PCI quirk: region 0800-087f claimed by ICH6 ACPI/GPIO/TCO
> PCI quirk: region 0880-08bf claimed by ICH6 GPIO
> PCI: PXH quirk detected, disabling MSI for SHPC device
> PCI: Transparent bridge - 0000:00:1e.0
> ACPI: PCI Interrupt Routing Table [\_SB_.PCI0._PRT]
> ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PES1._PRT]
> ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PEP0._PRT]
> ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PEP0.PXHA._PRT]
> ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PEP1._PRT]
> ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PEP2._PRT]
> ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PEP3._PRT]
> ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PCIS._PRT]
> ACPI: PCI Interrupt Link [LNKA] (IRQs 3 4 5 6 7 9 10 *11 12)
> ACPI: PCI Interrupt Link [LNKB] (IRQs 3 4 5 6 7 9 10 11 12) *0, disabled.
> ACPI: PCI Interrupt Link [LNKC] (IRQs 3 4 *5 6 7 9 10 11 12)
> ACPI: PCI Interrupt Link [LNKD] (IRQs 3 4 5 6 7 9 *10 11 12)
> ACPI: PCI Interrupt Link [LNKE] (IRQs *3 4 5 6 7 9 10 11 12)
> ACPI: PCI Interrupt Link [LNKF] (IRQs 3 4 5 6 7 9 10 11 12) *0, disabled.
> ACPI: PCI Interrupt Link [LNKG] (IRQs 3 4 5 6 7 9 10 11 12) *0, disabled.
> ACPI: PCI Interrupt Link [LNKH] (IRQs 3 4 5 6 7 9 10 11 12) *0, disabled.
> SCSI subsystem initialized
> libata version 2.00 loaded.
> usbcore: registered new interface driver usbfs
> usbcore: registered new interface driver hub
> usbcore: registered new device driver usb
> PCI: Using ACPI for IRQ routing
> PCI: If a device doesn't work, try "pci=routeirq".  If it helps, post a report
> PCI-GART: No AMD northbridge found.
> PCI: Ignore bogus resource 6 [0:0] of 0000:00:02.0
> PCI: Bridge: 0000:01:00.0
>   IO window: e000-efff
>   MEM window: dfd00000-dfefffff
>   PREFETCH window: d8000000-dbffffff
> PCI: Bridge: 0000:00:01.0
>   IO window: e000-efff
>   MEM window: dfc00000-dfefffff
>   PREFETCH window: d8000000-dbffffff
> PCI: Bridge: 0000:00:1c.0
>   IO window: disabled.
>   MEM window: disabled.
>   PREFETCH window: disabled.
> PCI: Bridge: 0000:00:1c.1
>   IO window: disabled.
>   MEM window: disabled.
>   PREFETCH window: disabled.
> PCI: Bridge: 0000:00:1c.2
>   IO window: d000-dfff
>   MEM window: dfa00000-dfbfffff
>   PREFETCH window: disabled.
> PCI: Bridge: 0000:00:1c.3
>   IO window: disabled.
>   MEM window: disabled.
>   PREFETCH window: disabled.
> PCI: Bridge: 0000:00:1e.0
>   IO window: disabled.
>   MEM window: disabled.
>   PREFETCH window: disabled.
> ACPI: PCI Interrupt 0000:00:01.0[A] -> GSI 16 (level, low) -> IRQ 16
> PCI: Setting latency timer of device 0000:00:01.0 to 64
> PCI: Setting latency timer of device 0000:01:00.0 to 64
> ACPI: PCI Interrupt 0000:00:1c.0[A] -> GSI 19 (level, low) -> IRQ 19
> PCI: Setting latency timer of device 0000:00:1c.0 to 64
> ACPI: PCI Interrupt 0000:00:1c.1[B] -> GSI 21 (level, low) -> IRQ 21
> PCI: Setting latency timer of device 0000:00:1c.1 to 64
> ACPI: PCI Interrupt 0000:00:1c.2[C] -> GSI 22 (level, low) -> IRQ 22
> PCI: Setting latency timer of device 0000:00:1c.2 to 64
> ACPI: PCI Interrupt 0000:00:1c.3[D] -> GSI 23 (level, low) -> IRQ 23
> PCI: Setting latency timer of device 0000:00:1c.3 to 64
> PCI: Setting latency timer of device 0000:00:1e.0 to 64
> NET: Registered protocol family 2
> IP route cache hash table entries: 32768 (order: 6, 262144 bytes)
> TCP established hash table entries: 131072 (order: 9, 2097152 bytes)
> TCP bind hash table entries: 65536 (order: 8, 1048576 bytes)
> TCP: Hash tables configured (established 131072 bind 65536)
> TCP reno registered
> checking if image is initramfs... it is
> Freeing initrd memory: 747k freed
> VFS: Disk quotas dquot_6.5.1
> Dquot-cache hash table entries: 512 (order 0, 4096 bytes)
> SGI XFS with ACLs, security attributes, realtime, large block/inode numbers, no
> debug enabled
> SGI XFS Quota Management subsystem
> io scheduler noop registered
> io scheduler anticipatory registered
> io scheduler deadline registered
> io scheduler cfq registered (default)
> vesafb: framebuffer at 0xd0000000, mapped to 0xffffc20010100000, using 3072k,
> total 7872k
> vesafb: mode is 1024x768x16, linelength=2048, pages=4
> vesafb: scrolling: redraw
> vesafb: Truecolor: size=0:5:6:5, shift=0:11:5:0
> Console: switching to colour frame buffer device 128x48
> fb0: VESA VGA frame buffer device
> input: Power Button (FF) as /class/input/input0
> ACPI: Power Button (FF) [PWRF]
> Real Time Clock Driver v1.12ac
> intel_rng: FWH not detected
> Linux agpgart interface v0.101 (c) Dave Jones
> [drm] Initialized drm 1.1.0 20060810
> Serial: 8250/16550 driver $Revision: 1.90 $ 4 ports, IRQ sharing enabled
> serial8250: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
> RAMDISK driver initialized: 16 RAM disks of 16384K size 1024 blocksize
> Uniform Multi-Platform E-IDE driver Revision: 7.00alpha2
> ide: Assuming 33MHz system bus speed for PIO modes; override with idebus=xx
> ICH6: IDE controller at PCI slot 0000:00:1f.1
> ACPI: Unable to derive IRQ for device 0000:00:1f.1
> ACPI: PCI Interrupt 0000:00:1f.1[A]: no GSI
> ICH6: chipset revision 3
> ICH6: not 100% native mode: will probe irqs later
>     ide0: BM-DMA at 0xfc00-0xfc07, BIOS settings: hda:DMA, hdb:pio
> Probing IDE interface ide0...
> hda: GCR-8483B, ATAPI CD/DVD-ROM drive
> ide0 at 0x1f0-0x1f7,0x3f6 on irq 14
> Probing IDE interface ide1...
> hda: ATAPI 48X CD-ROM drive, 128kB Cache, UDMA(33)
> Uniform CD-ROM driver Revision: 3.20
> ide-floppy driver 0.99.newide
> Adaptec aacraid driver (1.1-5[2423]-mh3)
> ACPI: PCI Interrupt 0000:02:01.0[A] -> GSI 32 (level, low) -> IRQ 32
> AAC0: kernel 4.1-0[7406] 
> AAC0: monitor 4.1-0[7406]
> AAC0: bios 4.1-0[7406]
> AAC0: serial c3b9c8
> scsi0 : aacraid
> scsi 0:0:0:0: Direct-Access     CERC     imgelre          V1.0 PQ: 0 ANSI: 2
> SCSI device sda: 156182272 512-byte hdwr sectors (79965 MB)
> sda: assuming Write Enabled
> sda: assuming drive cache: write through
> SCSI device sda: 156182272 512-byte hdwr sectors (79965 MB)
> sda: assuming Write Enabled
> sda: assuming drive cache: write through
>  sda: sda1 sda2 sda3
> sd 0:0:0:0: Attached scsi removable disk sda
> sd 0:0:0:0: Attached scsi generic sg0 type 0
> ahci 0000:00:1f.2: version 2.0
> ACPI: PCI Interrupt 0000:00:1f.2[C] -> GSI 20 (level, low) -> IRQ 20
> ahci 0000:00:1f.2: PORTS_IMPL is zero, forcing 0xf
> PCI: Setting latency timer of device 0000:00:1f.2 to 64
> ahci 0000:00:1f.2: AHCI 0001.0000 32 slots 4 ports 1.5 Gbps 0xf impl IDE mode
> ahci 0000:00:1f.2: flags: 64bit ncq pm led pmp slum part 
> ata1: SATA max UDMA/133 cmd 0xFFFFC20000002100 ctl 0x0 bmdma 0x0 irq 20
> ata2: SATA max UDMA/133 cmd 0xFFFFC20000002180 ctl 0x0 bmdma 0x0 irq 20
> ata3: SATA max UDMA/133 cmd 0xFFFFC20000002200 ctl 0x0 bmdma 0x0 irq 20
> ata4: SATA max UDMA/133 cmd 0xFFFFC20000002280 ctl 0x0 bmdma 0x0 irq 20
> scsi1 : ahci
> ata1: SATA link down (SStatus 0 SControl 300)
> scsi2 : ahci
> ata2: SATA link down (SStatus 0 SControl 300)
> scsi3 : ahci
> ata3: SATA link down (SStatus 0 SControl 300)
> scsi4 : ahci
> ata4: SATA link down (SStatus 0 SControl 300)
> usbcore: registered new interface driver hiddev
> usbcore: registered new interface driver usbhid
> drivers/usb/input/hid-core.c: v2.6:USB HID core driver
> serio: i8042 KBD port at 0x60,0x64 irq 1
> serio: i8042 AUX port at 0x60,0x64 irq 12
> mice: PS/2 mouse device common for all mice
> input: AT Translated Set 2 keyboard as /class/input/input1
> nf_conntrack version 0.5.0 (4063 buckets, 32504 max)
> ip_tables: (C) 2000-2006 Netfilter Core Team
> arp_tables: (C) 2002 David S. Miller
> TCP cubic registered
> Initializing XFRM netlink socket
> NET: Registered protocol family 1
> NET: Registered protocol family 17
> Freeing unused kernel memory: 248k freed
> XFS mounting filesystem sda2
> Starting XFS recovery on filesystem: sda2 (logdev: internal)
> Ending XFS recovery on filesystem: sda2 (logdev: internal)
> Floppy drive(s): fd0 is 1.44M
> FDC 0 is a National Semiconductor PC87306
> Ethernet Channel Bonding Driver: v3.1.1 (September 26, 2006)
> bonding: In ALB mode you might experience client disconnections upon
> reconnection of a link if the bonding module updelay parameter (5000 msec) is
> incompatible with the forwarding delay time of the switch
> bonding: MII link monitoring set to 100 ms
> tg3.c:v3.72 (January 8, 2007)
> ACPI: PCI Interrupt 0000:05:00.0[A] -> GSI 18 (level, low) -> IRQ 18
> PCI: Setting latency timer of device 0000:05:00.0 to 64
> eth0: Tigon3 [partno(BCM95721) rev 4001 PHY(5750)] (PCI Express)
> 10/100/1000Base-T Ethernet 00:12:3f:6e:2c:f4
> eth0: RXcsums[1] LinkChgREG[1] MIirq[1] ASF[1] Split[0] WireSpeed[1] TSOcap[1] 
> eth0: dma_rwctrl[76180000] dma_mask[64-bit]
> Intel(R) PRO/1000 Network Driver - version 7.3.15-k2-NAPI
> Copyright (c) 1999-2006 Intel Corporation.
> ACPI: PCI Interrupt 0000:02:02.0[A] -> GSI 35 (level, low) -> IRQ 35
> e1000: 0000:02:02.0: e1000_probe: (PCI:66MHz:64-bit) 00:0e:0c:80:f8:a9
> e1000: eth1: e1000_probe: Intel(R) PRO/1000 Network Connection
> ACPI: Unable to derive IRQ for device 0000:00:1f.3
> ACPI: PCI Interrupt 0000:00:1f.3[B]: no GSI
> ACPI: PCI Interrupt 0000:00:1d.7[A] -> GSI 19 (level, low) -> IRQ 19
> PCI: Setting latency timer of device 0000:00:1d.7 to 64
> ehci_hcd 0000:00:1d.7: EHCI Host Controller
> ehci_hcd 0000:00:1d.7: new USB bus registered, assigned bus number 1
> ehci_hcd 0000:00:1d.7: debug port 1
> PCI: cache line size of 128 is not supported by device 0000:00:1d.7
> ehci_hcd 0000:00:1d.7: irq 19, io mem 0xdffc0400
> ehci_hcd 0000:00:1d.7: USB 2.0 started, EHCI 1.00, driver 10 Dec 2004
> usb usb1: configuration #1 chosen from 1 choice
> hub 1-0:1.0: USB hub found
> hub 1-0:1.0: 8 ports detected
> USB Universal Host Controller Interface driver v3.0
> ACPI: PCI Interrupt 0000:00:1d.0[A] -> GSI 19 (level, low) -> IRQ 19
> PCI: Setting latency timer of device 0000:00:1d.0 to 64
> uhci_hcd 0000:00:1d.0: UHCI Host Controller
> uhci_hcd 0000:00:1d.0: new USB bus registered, assigned bus number 2
> uhci_hcd 0000:00:1d.0: irq 19, io base 0x0000ccc0
> usb usb2: configuration #1 chosen from 1 choice
> hub 2-0:1.0: USB hub found
> hub 2-0:1.0: 2 ports detected
> ACPI: PCI Interrupt 0000:00:1d.1[B] -> GSI 18 (level, low) -> IRQ 18
> PCI: Setting latency timer of device 0000:00:1d.1 to 64
> uhci_hcd 0000:00:1d.1: UHCI Host Controller
> uhci_hcd 0000:00:1d.1: new USB bus registered, assigned bus number 3
> uhci_hcd 0000:00:1d.1: irq 18, io base 0x0000cca0
> usb usb3: configuration #1 chosen from 1 choice
> hub 3-0:1.0: USB hub found
> hub 3-0:1.0: 2 ports detected
> ACPI: PCI Interrupt 0000:00:1d.2[C] -> GSI 19 (level, low) -> IRQ 19
> PCI: Setting latency timer of device 0000:00:1d.2 to 64
> uhci_hcd 0000:00:1d.2: UHCI Host Controller
> uhci_hcd 0000:00:1d.2: new USB bus registered, assigned bus number 4
> uhci_hcd 0000:00:1d.2: irq 19, io base 0x0000cc80
> usb usb4: configuration #1 chosen from 1 choice
> hub 4-0:1.0: USB hub found
> hub 4-0:1.0: 2 ports detected
> ACPI: PCI Interrupt 0000:00:1d.3[D] -> GSI 18 (level, low) -> IRQ 18
> PCI: Setting latency timer of device 0000:00:1d.3 to 64
> uhci_hcd 0000:00:1d.3: UHCI Host Controller
> uhci_hcd 0000:00:1d.3: new USB bus registered, assigned bus number 5
> uhci_hcd 0000:00:1d.3: irq 18, io base 0x0000cc60
> usb usb5: configuration #1 chosen from 1 choice
> hub 5-0:1.0: USB hub found
> hub 5-0:1.0: 2 ports detected
> md: Autodetecting RAID arrays.
> md: autorun ...
> md: ... autorun DONE.
> No dock devices found.
> device-mapper: ioctl: 4.11.0-ioctl (2006-10-12) initialised: dm-devel@redhat.com
> kjournald starting.  Commit interval 5 seconds
> EXT3 FS on sda1, internal journal
> EXT3-fs: mounted filesystem with ordered data mode.
> Adding 2024180k swap on /dev/sda3.  Priority:-1 extents:1 across:2024180k
> bonding: bond0: enslaving eth0 as an active interface with a down link.
> bonding: bond0: enslaving eth1 as an active interface with a down link.
> tg3: eth0: Link is up at 1000 Mbps, full duplex.
> tg3: eth0: Flow control is on for TX and on for RX.
> bonding: bond0: link status up for interface eth0, enabling it in 5000 ms.
> bonding: bond0: link status definitely up for interface eth0.
> bonding: bond0: making interface eth0 the new active one.
> BUG: scheduling while atomic: swapper/0x10000100/0
> 
> Call Trace:
>  <IRQ>  [<ffffffff802607d0>] __sched_text_start+0x60/0xb27
>  [<ffffffff8802c8a1>] :tg3:tg3_setup_copper_phy+0x9d9/0xad9
>  [<ffffffff8026f8d5>] smp_local_timer_interrupt+0x34/0x5b
>  [<ffffffff8802d6d4>] :tg3:tg3_setup_phy+0xd33/0xe16
>  [<ffffffff8027f572>] __cond_resched+0x1c/0x44
>  [<ffffffff802613aa>] cond_resched+0x2e/0x39
>  [<ffffffff80209f5a>] kmem_cache_alloc+0x14/0x58
>  [<ffffffff8022df6f>] __alloc_skb+0x36/0x134
>  [<ffffffff804a4ea7>] rtmsg_ifinfo+0x28/0xa1
>  [<ffffffff804a4f81>] rtnetlink_event+0x61/0x68
>  [<ffffffff8028ad24>] notifier_call_chain+0x24/0x36
>  [<ffffffff8049ccad>] dev_set_mac_address+0x53/0x66
>  [<ffffffff88019648>] :bonding:alb_set_slave_mac_addr+0x4b/0x73
>  [<ffffffff88019b0c>] :bonding:alb_swap_mac_addr+0x8b/0x15c
>  [<ffffffff804a02e7>] dev_mc_add+0x137/0x148
>  [<ffffffff88014338>] :bonding:bond_change_active_slave+0x1ea/0x34d
>  [<ffffffff8801481d>] :bonding:bond_select_active_slave+0xbe/0xf4
>  [<ffffffff880165e5>] :bonding:bond_mii_monitor+0x401/0x45b
>  [<ffffffff880161e4>] :bonding:bond_mii_monitor+0x0/0x45b
>  [<ffffffff80287ed2>] run_timer_softirq+0x142/0x1c0
>  [<ffffffff80211f6a>] __do_softirq+0x5c/0xd2
>  [<ffffffff8025ef4c>] call_softirq+0x1c/0x28
>  [<ffffffff80268e95>] do_softirq+0x2c/0x87
>  [<ffffffff8026fdd7>] smp_apic_timer_interrupt+0x57/0x6c
>  [<ffffffff8025691a>] mwait_idle+0x0/0x45
>  [<ffffffff8025e9f6>] apic_timer_interrupt+0x66/0x70
>  <EOI>  [<ffffffff8025695c>] mwait_idle+0x42/0x45
>  [<ffffffff802484e5>] cpu_idle+0x5b/0x7a
>  [<ffffffff8065b88a>] start_secondary+0x4e0/0x4f6
> 
> RTNL: assertion failed at net/core/fib_rules.c (444)
> 
> Call Trace:
>  <IRQ>  [<ffffffff804a8abb>] fib_rules_event+0x3b/0x120
>  [<ffffffff8028ad24>] notifier_call_chain+0x24/0x36
>  [<ffffffff8049ccad>] dev_set_mac_address+0x53/0x66
>  [<ffffffff88019648>] :bonding:alb_set_slave_mac_addr+0x4b/0x73
>  [<ffffffff88019b0c>] :bonding:alb_swap_mac_addr+0x8b/0x15c
>  [<ffffffff804a02e7>] dev_mc_add+0x137/0x148
>  [<ffffffff88014338>] :bonding:bond_change_active_slave+0x1ea/0x34d
>  [<ffffffff8801481d>] :bonding:bond_select_active_slave+0xbe/0xf4
>  [<ffffffff880165e5>] :bonding:bond_mii_monitor+0x401/0x45b
>  [<ffffffff880161e4>] :bonding:bond_mii_monitor+0x0/0x45b
>  [<ffffffff80287ed2>] run_timer_softirq+0x142/0x1c0
>  [<ffffffff80211f6a>] __do_softirq+0x5c/0xd2
>  [<ffffffff8025ef4c>] call_softirq+0x1c/0x28
>  [<ffffffff80268e95>] do_softirq+0x2c/0x87
>  [<ffffffff8026fdd7>] smp_apic_timer_interrupt+0x57/0x6c
>  [<ffffffff8025691a>] mwait_idle+0x0/0x45
>  [<ffffffff8025e9f6>] apic_timer_interrupt+0x66/0x70
>  <EOI>  [<ffffffff8025695c>] mwait_idle+0x42/0x45
>  [<ffffffff802484e5>] cpu_idle+0x5b/0x7a
>  [<ffffffff8065b88a>] start_secondary+0x4e0/0x4f6
> 
> BUG: scheduling while atomic: swapper/0x10000100/0
> 
> Call Trace:
>  <IRQ>  [<ffffffff802607d0>] __sched_text_start+0x60/0xb27
>  [<ffffffff8026f8d5>] smp_local_timer_interrupt+0x34/0x5b
>  [<ffffffff8027f572>] __cond_resched+0x1c/0x44
>  [<ffffffff802613aa>] cond_resched+0x2e/0x39
>  [<ffffffff80262029>] mutex_lock+0x9/0x18
>  [<ffffffff8049ea76>] netdev_run_todo+0x16/0x230
>  [<ffffffff804bcc75>] dst_rcu_free+0x0/0x3f
>  [<ffffffff804d9c29>] inetdev_event+0x29/0x2d0
>  [<ffffffff80263138>] _spin_lock_bh+0x9/0x19
>  [<ffffffff8023d84a>] rt_run_flush+0x92/0xcc
>  [<ffffffff8028ad24>] notifier_call_chain+0x24/0x36
>  [<ffffffff8049ccad>] dev_set_mac_address+0x53/0x66
>  [<ffffffff88019648>] :bonding:alb_set_slave_mac_addr+0x4b/0x73
>  [<ffffffff88019b0c>] :bonding:alb_swap_mac_addr+0x8b/0x15c
>  [<ffffffff804a02e7>] dev_mc_add+0x137/0x148
>  [<ffffffff88014338>] :bonding:bond_change_active_slave+0x1ea/0x34d
>  [<ffffffff8801481d>] :bonding:bond_select_active_slave+0xbe/0xf4
>  [<ffffffff880165e5>] :bonding:bond_mii_monitor+0x401/0x45b
>  [<ffffffff880161e4>] :bonding:bond_mii_monitor+0x0/0x45b
>  [<ffffffff80287ed2>] run_timer_softirq+0x142/0x1c0
>  [<ffffffff80211f6a>] __do_softirq+0x5c/0xd2
>  [<ffffffff8025ef4c>] call_softirq+0x1c/0x28
>  [<ffffffff80268e95>] do_softirq+0x2c/0x87
>  [<ffffffff8026fdd7>] smp_apic_timer_interrupt+0x57/0x6c
>  [<ffffffff8025691a>] mwait_idle+0x0/0x45
>  [<ffffffff8025e9f6>] apic_timer_interrupt+0x66/0x70
>  <EOI>  [<ffffffff8025695c>] mwait_idle+0x42/0x45
>  [<ffffffff802484e5>] cpu_idle+0x5b/0x7a
>  [<ffffffff8065b88a>] start_secondary+0x4e0/0x4f6
> 
> RTNL: assertion failed at net/ipv4/devinet.c (1055)
> 
> Call Trace:
>  <IRQ>  [<ffffffff804d9c48>] inetdev_event+0x48/0x2d0
>  [<ffffffff80263138>] _spin_lock_bh+0x9/0x19
>  [<ffffffff8023d84a>] rt_run_flush+0x92/0xcc
>  [<ffffffff8028ad24>] notifier_call_chain+0x24/0x36
>  [<ffffffff8049ccad>] dev_set_mac_address+0x53/0x66
>  [<ffffffff88019648>] :bonding:alb_set_slave_mac_addr+0x4b/0x73
>  [<ffffffff88019b0c>] :bonding:alb_swap_mac_addr+0x8b/0x15c
>  [<ffffffff804a02e7>] dev_mc_add+0x137/0x148
>  [<ffffffff88014338>] :bonding:bond_change_active_slave+0x1ea/0x34d
>  [<ffffffff8801481d>] :bonding:bond_select_active_slave+0xbe/0xf4
>  [<ffffffff880165e5>] :bonding:bond_mii_monitor+0x401/0x45b
>  [<ffffffff880161e4>] :bonding:bond_mii_monitor+0x0/0x45b
>  [<ffffffff80287ed2>] run_timer_softirq+0x142/0x1c0
>  [<ffffffff80211f6a>] __do_softirq+0x5c/0xd2
>  [<ffffffff8025ef4c>] call_softirq+0x1c/0x28
>  [<ffffffff80268e95>] do_softirq+0x2c/0x87
>  [<ffffffff8026fdd7>] smp_apic_timer_interrupt+0x57/0x6c
>  [<ffffffff8025691a>] mwait_idle+0x0/0x45
>  [<ffffffff8025e9f6>] apic_timer_interrupt+0x66/0x70
>  <EOI>  [<ffffffff8025695c>] mwait_idle+0x42/0x45
>  [<ffffffff802484e5>] cpu_idle+0x5b/0x7a
>  [<ffffffff8065b88a>] start_secondary+0x4e0/0x4f6
> 
> BUG: scheduling while atomic: swapper/0x10000100/0
> 
> Call Trace:
>  <IRQ>  [<ffffffff802607d0>] __sched_text_start+0x60/0xb27
>  [<ffffffff8802c8a1>] :tg3:tg3_setup_copper_phy+0x9d9/0xad9
>  [<ffffffff8026f8d5>] smp_local_timer_interrupt+0x34/0x5b
>  [<ffffffff8802d6d4>] :tg3:tg3_setup_phy+0xd33/0xe16
>  [<ffffffff8027f572>] __cond_resched+0x1c/0x44
>  [<ffffffff802613aa>] cond_resched+0x2e/0x39
>  [<ffffffff80209f5a>] kmem_cache_alloc+0x14/0x58
>  [<ffffffff8022df6f>] __alloc_skb+0x36/0x134
>  [<ffffffff804a4ea7>] rtmsg_ifinfo+0x28/0xa1
>  [<ffffffff804a4f81>] rtnetlink_event+0x61/0x68
>  [<ffffffff8028ad24>] notifier_call_chain+0x24/0x36
>  [<ffffffff8049ccad>] dev_set_mac_address+0x53/0x66
>  [<ffffffff88019648>] :bonding:alb_set_slave_mac_addr+0x4b/0x73
>  [<ffffffff88019b1e>] :bonding:alb_swap_mac_addr+0x9d/0x15c
>  [<ffffffff804a02e7>] dev_mc_add+0x137/0x148
>  [<ffffffff88014338>] :bonding:bond_change_active_slave+0x1ea/0x34d
>  [<ffffffff8801481d>] :bonding:bond_select_active_slave+0xbe/0xf4
>  [<ffffffff880165e5>] :bonding:bond_mii_monitor+0x401/0x45b
>  [<ffffffff880161e4>] :bonding:bond_mii_monitor+0x0/0x45b
>  [<ffffffff80287ed2>] run_timer_softirq+0x142/0x1c0
>  [<ffffffff80211f6a>] __do_softirq+0x5c/0xd2
>  [<ffffffff8025ef4c>] call_softirq+0x1c/0x28
>  [<ffffffff80268e95>] do_softirq+0x2c/0x87
>  [<ffffffff8026fdd7>] smp_apic_timer_interrupt+0x57/0x6c
>  [<ffffffff8025691a>] mwait_idle+0x0/0x45
>  [<ffffffff8025e9f6>] apic_timer_interrupt+0x66/0x70
>  <EOI>  [<ffffffff8025695c>] mwait_idle+0x42/0x45
>  [<ffffffff802484e5>] cpu_idle+0x5b/0x7a
>  [<ffffffff8065b88a>] start_secondary+0x4e0/0x4f6
> 
> RTNL: assertion failed at net/core/fib_rules.c (444)
> 
> Call Trace:
>  <IRQ>  [<ffffffff804a8abb>] fib_rules_event+0x3b/0x120
>  [<ffffffff8028ad24>] notifier_call_chain+0x24/0x36
>  [<ffffffff8049ccad>] dev_set_mac_address+0x53/0x66
>  [<ffffffff88019648>] :bonding:alb_set_slave_mac_addr+0x4b/0x73
>  [<ffffffff88019b1e>] :bonding:alb_swap_mac_addr+0x9d/0x15c
>  [<ffffffff804a02e7>] dev_mc_add+0x137/0x148
>  [<ffffffff88014338>] :bonding:bond_change_active_slave+0x1ea/0x34d
>  [<ffffffff8801481d>] :bonding:bond_select_active_slave+0xbe/0xf4
>  [<ffffffff880165e5>] :bonding:bond_mii_monitor+0x401/0x45b
>  [<ffffffff880161e4>] :bonding:bond_mii_monitor+0x0/0x45b
>  [<ffffffff80287ed2>] run_timer_softirq+0x142/0x1c0
>  [<ffffffff80211f6a>] __do_softirq+0x5c/0xd2
>  [<ffffffff8025ef4c>] call_softirq+0x1c/0x28
>  [<ffffffff80268e95>] do_softirq+0x2c/0x87
>  [<ffffffff8026fdd7>] smp_apic_timer_interrupt+0x57/0x6c
>  [<ffffffff8025691a>] mwait_idle+0x0/0x45
>  [<ffffffff8025e9f6>] apic_timer_interrupt+0x66/0x70
>  <EOI>  [<ffffffff8025695c>] mwait_idle+0x42/0x45
>  [<ffffffff802484e5>] cpu_idle+0x5b/0x7a
>  [<ffffffff8065b88a>] start_secondary+0x4e0/0x4f6
> 
> BUG: scheduling while atomic: swapper/0x10000100/0
> 
> Call Trace:
>  <IRQ>  [<ffffffff802607d0>] __sched_text_start+0x60/0xb27
>  [<ffffffff8026f8d5>] smp_local_timer_interrupt+0x34/0x5b
>  [<ffffffff8027f572>] __cond_resched+0x1c/0x44
>  [<ffffffff802613aa>] cond_resched+0x2e/0x39
>  [<ffffffff80262029>] mutex_lock+0x9/0x18
>  [<ffffffff8049ea76>] netdev_run_todo+0x16/0x230
>  [<ffffffff804bcc75>] dst_rcu_free+0x0/0x3f
>  [<ffffffff804d9c29>] inetdev_event+0x29/0x2d0
>  [<ffffffff80263138>] _spin_lock_bh+0x9/0x19
>  [<ffffffff8023d84a>] rt_run_flush+0x92/0xcc
>  [<ffffffff8028ad24>] notifier_call_chain+0x24/0x36
>  [<ffffffff8049ccad>] dev_set_mac_address+0x53/0x66
>  [<ffffffff88019648>] :bonding:alb_set_slave_mac_addr+0x4b/0x73
>  [<ffffffff88019b1e>] :bonding:alb_swap_mac_addr+0x9d/0x15c
>  [<ffffffff804a02e7>] dev_mc_add+0x137/0x148
>  [<ffffffff88014338>] :bonding:bond_change_active_slave+0x1ea/0x34d
>  [<ffffffff8801481d>] :bonding:bond_select_active_slave+0xbe/0xf4
>  [<ffffffff880165e5>] :bonding:bond_mii_monitor+0x401/0x45b
>  [<ffffffff880161e4>] :bonding:bond_mii_monitor+0x0/0x45b
>  [<ffffffff80287ed2>] run_timer_softirq+0x142/0x1c0
>  [<ffffffff80211f6a>] __do_softirq+0x5c/0xd2
>  [<ffffffff8025ef4c>] call_softirq+0x1c/0x28
>  [<ffffffff80268e95>] do_softirq+0x2c/0x87
>  [<ffffffff8026fdd7>] smp_apic_timer_interrupt+0x57/0x6c
>  [<ffffffff8025691a>] mwait_idle+0x0/0x45
>  [<ffffffff8025e9f6>] apic_timer_interrupt+0x66/0x70
>  <EOI>  [<ffffffff8025695c>] mwait_idle+0x42/0x45
>  [<ffffffff802484e5>] cpu_idle+0x5b/0x7a
>  [<ffffffff8065b88a>] start_secondary+0x4e0/0x4f6
> 
> RTNL: assertion failed at net/ipv4/devinet.c (1055)
> 
> Call Trace:
>  <IRQ>  [<ffffffff804d9c48>] inetdev_event+0x48/0x2d0
>  [<ffffffff80263138>] _spin_lock_bh+0x9/0x19
>  [<ffffffff8023d84a>] rt_run_flush+0x92/0xcc
>  [<ffffffff8028ad24>] notifier_call_chain+0x24/0x36
>  [<ffffffff8049ccad>] dev_set_mac_address+0x53/0x66
>  [<ffffffff88019648>] :bonding:alb_set_slave_mac_addr+0x4b/0x73
>  [<ffffffff88019b1e>] :bonding:alb_swap_mac_addr+0x9d/0x15c
>  [<ffffffff804a02e7>] dev_mc_add+0x137/0x148
>  [<ffffffff88014338>] :bonding:bond_change_active_slave+0x1ea/0x34d
>  [<ffffffff8801481d>] :bonding:bond_select_active_slave+0xbe/0xf4
>  [<ffffffff880165e5>] :bonding:bond_mii_monitor+0x401/0x45b
>  [<ffffffff880161e4>] :bonding:bond_mii_monitor+0x0/0x45b
>  [<ffffffff80287ed2>] run_timer_softirq+0x142/0x1c0
>  [<ffffffff80211f6a>] __do_softirq+0x5c/0xd2
>  [<ffffffff8025ef4c>] call_softirq+0x1c/0x28
>  [<ffffffff80268e95>] do_softirq+0x2c/0x87
>  [<ffffffff8026fdd7>] smp_apic_timer_interrupt+0x57/0x6c
>  [<ffffffff8025691a>] mwait_idle+0x0/0x45
>  [<ffffffff8025e9f6>] apic_timer_interrupt+0x66/0x70
>  <EOI>  [<ffffffff8025695c>] mwait_idle+0x42/0x45
>  [<ffffffff802484e5>] cpu_idle+0x5b/0x7a
>  [<ffffffff8065b88a>] start_secondary+0x4e0/0x4f6
> 
> bonding: bond0: first active interface up!
> NET: Registered protocol family 10
> lo: Disabled Privacy Extensions
> ADDRCONF(NETDEV_UP): eth1: link is not ready
> bond0: no IPv6 routers present
> eth0: no IPv6 routers present
> Installing knfsd (copyright (C) 1996 okir@monad.swb.de).
> NFSD: Using /var/lib/nfs/v4recovery as the NFSv4 state recovery directory
> NFSD: starting 90-second grace period
> 
> 
> # lspci -vx
> 00:00.0 Host bridge: Intel Corporation E7220/E7221 Memory Controller Hub (rev 04)
>         Subsystem: Dell: Unknown device 0185
>         Flags: bus master, fast devsel, latency 0
>         Capabilities: [e0] Vendor Specific Information
> 00: 86 80 88 25 06 01 90 20 04 00 00 06 00 00 00 00
> 10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 20: 00 00 00 00 00 00 00 00 00 00 00 00 28 10 85 01
> 30: 00 00 00 00 e0 00 00 00 00 00 00 00 00 00 00 00
> 
> 00:01.0 PCI bridge: Intel Corporation E7220/E7221 PCI Express Root Port (rev 04)
> (prog-if 00 [Normal decode])
>         Flags: bus master, fast devsel, latency 0
>         Bus: primary=00, secondary=01, subordinate=02, sec-latency=0
>         I/O behind bridge: 0000e000-0000efff
>         Memory behind bridge: dfc00000-dfefffff
>         Prefetchable memory behind bridge: d8000000-dbffffff
>         Capabilities: [88] #0d [0000]
>         Capabilities: [80] Power Management version 2
>         Capabilities: [90] Message Signalled Interrupts: 64bit- Queue=0/0 Enable-
>         Capabilities: [a0] Express Root Port (Slot+) IRQ 0
>         Capabilities: [100] Virtual Channel
>         Capabilities: [140] Unknown (5)
> 00: 86 80 89 25 47 00 10 00 04 00 04 06 10 00 01 00
> 10: 00 00 00 00 00 00 00 00 00 01 02 00 e0 e0 00 00
> 20: c0 df e0 df 00 d8 f0 db 00 00 00 00 00 00 00 00
> 30: 00 00 00 00 88 00 00 00 00 00 00 00 00 01 07 00
> 
> 00:02.0 VGA compatible controller: Intel Corporation E7221 Integrated Graphics
> Controller (rev 04) (prog-if 00 [VGA])
>         Subsystem: Dell: Unknown device 0185
>         Flags: bus master, fast devsel, latency 0, IRQ 11
>         Memory at dff00000 (32-bit, non-prefetchable) [size=512K]
>         I/O ports at 1000 [size=8]
>         Memory at d0000000 (32-bit, prefetchable) [size=128M]
>         Memory at dff80000 (32-bit, non-prefetchable) [size=256K]
>         Capabilities: [d0] Power Management version 2
> 00: 86 80 8a 25 07 00 90 00 04 00 00 03 00 00 00 00
> 10: 00 00 f0 df 01 10 00 00 08 00 00 d0 00 00 f8 df
> 20: 00 00 00 00 00 00 00 00 00 00 00 00 28 10 85 01
> 30: 00 00 00 00 d0 00 00 00 00 00 00 00 0b 01 00 00
> 
> 00:1c.0 PCI bridge: Intel Corporation 82801FB/FBM/FR/FW/FRW (ICH6 Family) PCI
> Express Port 1 (rev 03) (prog-if 00 [Normal decode])
>         Flags: bus master, fast devsel, latency 0
>         Bus: primary=00, secondary=03, subordinate=03, sec-latency=0
>         Capabilities: [40] Express Root Port (Slot+) IRQ 0
>         Capabilities: [80] Message Signalled Interrupts: 64bit- Queue=0/0 Enable-
>         Capabilities: [90] #0d [0000]
>         Capabilities: [a0] Power Management version 2
>         Capabilities: [100] Virtual Channel
>         Capabilities: [180] Unknown (5)
> 00: 86 80 60 26 07 00 10 00 03 00 04 06 10 00 81 00
> 10: 00 00 00 00 00 00 00 00 00 03 03 00 f0 00 00 20
> 20: f0 ff 00 00 f1 ff 01 00 00 00 00 00 00 00 00 00
> 30: 00 00 00 00 40 00 00 00 00 00 00 00 00 01 06 00
> 40: 10 80 41 01
> 00:1c.1 PCI bridge: Intel Corporation 82801FB/FBM/FR/FW/FRW (ICH6 Family) PCI
> Express Port 2 (rev 03) (prog-if 00 [Normal decode])
>         Flags: bus master, fast devsel, latency 0
>         Bus: primary=00, secondary=04, subordinate=04, sec-latency=0
>         Capabilities: [40] Express Root Port (Slot+) IRQ 0
>         Capabilities: [80] Message Signalled Interrupts: 64bit- Queue=0/0 Enable-
>         Capabilities: [90] #0d [0000]
>         Capabilities: [a0] Power Management version 2
>         Capabilities: [100] Virtual Channel
>         Capabilities: [180] Unknown (5)
> 00: 86 80 62 26 47 00 10 00 03 00 04 06 10 00 81 00
> 10: 00 00 00 00 00 00 00 00 00 04 04 00 f0 00 00 20
> 20: f0 ff 00 00 f1 ff 01 00 00 00 00 00 00 00 00 00
> 30: 00 00 00 00 40 00 00 00 00 00 00 00 00 02 07 00
> 40: 10 80 41 01
> 00:1c.2 PCI bridge: Intel Corporation 82801FB/FBM/FR/FW/FRW (ICH6 Family) PCI
> Express Port 3 (rev 03) (prog-if 00 [Normal decode])
>         Flags: bus master, fast devsel, latency 0
>         Bus: primary=00, secondary=05, subordinate=05, sec-latency=0
>         I/O behind bridge: 0000d000-0000dfff
>         Memory behind bridge: dfa00000-dfbfffff
>         Capabilities: [40] Express Root Port (Slot-) IRQ 0
>         Capabilities: [80] Message Signalled Interrupts: 64bit- Queue=0/0 Enable-
>         Capabilities: [90] #0d [0000]
>         Capabilities: [a0] Power Management version 2
>         Capabilities: [100] Virtual Channel
>         Capabilities: [180] Unknown (5)
> 00: 86 80 64 26 47 00 10 00 03 00 04 06 10 00 81 00
> 10: 00 00 00 00 00 00 00 00 00 05 05 00 d0 d0 00 00
> 20: a0 df b0 df f1 ff 01 00 00 00 00 00 00 00 00 00
> 30: 00 00 00 00 40 00 00 00 00 00 00 00 00 03 07 00
> 40: 10 80 41 00
> 00:1c.3 PCI bridge: Intel Corporation 82801FB/FBM/FR/FW/FRW (ICH6 Family) PCI
> Express Port 4 (rev 03) (prog-if 00 [Normal decode])
>         Flags: bus master, fast devsel, latency 0
>         Bus: primary=00, secondary=06, subordinate=06, sec-latency=0
>         Capabilities: [40] Express Root Port (Slot-) IRQ 0
>         Capabilities: [80] Message Signalled Interrupts: 64bit- Queue=0/0 Enable-
>         Capabilities: [90] #0d [0000]
>         Capabilities: [a0] Power Management version 2
>         Capabilities: [100] Virtual Channel
>         Capabilities: [180] Unknown (5)
> 00: 86 80 66 26 47 00 10 00 03 00 04 06 10 00 81 00
> 10: 00 00 00 00 00 00 00 00 00 06 06 00 f0 00 00 20
> 20: f0 ff 00 00 f1 ff 01 00 00 00 00 00 00 00 00 00
> 30: 00 00 00 00 40 00 00 00 00 00 00 00 00 04 07 00
> 40: 10 80 41 00
> 00:1d.0 USB Controller: Intel Corporation 82801FB/FBM/FR/FW/FRW (ICH6 Family)
> USB UHCI #1 (rev 03) (prog-if 00 [UHCI])
>         Subsystem: Dell: Unknown device 0185
>         Flags: bus master, medium devsel, latency 0, IRQ 19
>         I/O ports at ccc0 [size=32]
> 00: 86 80 58 26 05 00 80 02 03 00 03 0c 00 00 80 00
> 10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 20: c1 cc 00 00 00 00 00 00 00 00 00 00 28 10 85 01
> 30: 00 00 00 00 00 00 00 00 00 00 00 00 0a 01 00 00
> 
> 00:1d.1 USB Controller: Intel Corporation 82801FB/FBM/FR/FW/FRW (ICH6 Family)
> USB UHCI #2 (rev 03) (prog-if 00 [UHCI])
>         Subsystem: Dell: Unknown device 0185
>         Flags: bus master, medium devsel, latency 0, IRQ 18
>         I/O ports at cca0 [size=32]
> 00: 86 80 59 26 05 00 80 02 03 00 03 0c 00 00 00 00
> 10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 20: a1 cc 00 00 00 00 00 00 00 00 00 00 28 10 85 01
> 30: 00 00 00 00 00 00 00 00 00 00 00 00 05 02 00 00
> 
> 00:1d.2 USB Controller: Intel Corporation 82801FB/FBM/FR/FW/FRW (ICH6 Family)
> USB UHCI #3 (rev 03) (prog-if 00 [UHCI])
>         Subsystem: Dell: Unknown device 0185
>         Flags: bus master, medium devsel, latency 0, IRQ 19
>         I/O ports at cc80 [size=32]
> 00: 86 80 5a 26 05 00 80 02 03 00 03 0c 00 00 00 00
> 10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 20: 81 cc 00 00 00 00 00 00 00 00 00 00 28 10 85 01
> 30: 00 00 00 00 00 00 00 00 00 00 00 00 0a 03 00 00
> 
> 00:1d.3 USB Controller: Intel Corporation 82801FB/FBM/FR/FW/FRW (ICH6 Family)
> USB UHCI #4 (rev 03) (prog-if 00 [UHCI])
>         Subsystem: Dell: Unknown device 0185
>         Flags: bus master, medium devsel, latency 0, IRQ 18
>         I/O ports at cc60 [size=32]
> 00: 86 80 5b 26 05 00 80 02 03 00 03 0c 00 00 00 00
> 10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 20: 61 cc 00 00 00 00 00 00 00 00 00 00 28 10 85 01
> 30: 00 00 00 00 00 00 00 00 00 00 00 00 05 04 00 00
> 
> 00:1d.7 USB Controller: Intel Corporation 82801FB/FBM/FR/FW/FRW (ICH6 Family)
> USB2 EHCI Controller (rev 03) (prog-if 20 [EHCI])
>         Subsystem: Dell: Unknown device 0185
>         Flags: bus master, medium devsel, latency 0, IRQ 19
>         Memory at dffc0400 (32-bit, non-prefetchable) [size=1K]
>         Capabilities: [50] Power Management version 2
>         Capabilities: [58] Debug port
> 00: 86 80 5c 26 06 01 90 02 03 20 03 0c 00 00 00 00
> 10: 00 04 fc df 00 00 00 00 00 00 00 00 00 00 00 00
> 20: 00 00 00 00 00 00 00 00 00 00 00 00 28 10 85 01
> 30: 00 00 00 00 50 00 00 00 00 00 00 00 0a 01 00 00
> 
> 00:1e.0 PCI bridge: Intel Corporation 82801 PCI Bridge (rev d3) (prog-if 01
> [Subtractive decode])
>         Flags: bus master, fast devsel, latency 0
>         Bus: primary=00, secondary=07, subordinate=07, sec-latency=32
>         Capabilities: [50] #0d [0000]
> 00: 86 80 4e 24 47 01 10 00 d3 01 04 06 00 00 01 00
> 10: 00 00 00 00 00 00 00 00 00 07 07 20 f0 00 80 22
> 20: f0 ff 00 00 f1 ff 01 00 00 00 00 00 00 00 00 00
> 30: 00 00 00 00 50 00 00 00 00 00 00 00 ff 00 07 00
> 
> 00:1f.0 ISA bridge: Intel Corporation 82801FB/FR (ICH6/ICH6R) LPC Interface
> Bridge (rev 03)
>         Flags: bus master, medium devsel, latency 0
> 00: 86 80 40 26 47 01 00 02 03 00 01 06 00 00 80 00
> 10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 20: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 30: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 
> 00:1f.1 IDE interface: Intel Corporation 82801FB/FBM/FR/FW/FRW (ICH6 Family) IDE
> Controller (rev 03) (prog-if 8a [Master SecP PriP])
>         Subsystem: Dell: Unknown device 0185
>         Flags: bus master, medium devsel, latency 0
>         I/O ports at 01f0 [size=8]
>         I/O ports at 03f4 [size=1]
>         I/O ports at 0170 [size=8]
>         I/O ports at 0374 [size=1]
>         I/O ports at fc00 [size=16]
> 00: 86 80 6f 26 05 00 88 02 03 8a 01 01 00 00 00 00
> 10: 01 00 00 00 01 00 00 00 01 00 00 00 01 00 00 00
> 20: 01 fc 00 00 00 00 00 00 00 00 00 00 28 10 85 01
> 30: 00 00 00 00 00 00 00 00 00 00 00 00 00 01 00 00
> 
> 00:1f.2 IDE interface: Intel Corporation 82801FR/FRW (ICH6R/ICH6RW) SATA
> Controller (rev 03) (prog-if 8f [Master SecP SecO PriP PriO])
>         Subsystem: Intel Corporation 82801FR/FRW (ICH6R/ICH6RW) SATA Controller
>         Flags: bus master, 66Mhz, medium devsel, latency 0, IRQ 20
>         I/O ports at ccf0 [size=8]
>         I/O ports at cce8 [size=4]
>         I/O ports at cc58 [size=8]
>         I/O ports at cce0 [size=4]
>         I/O ports at cc40 [size=16]
>         Memory at dffc0000 (32-bit, non-prefetchable) [size=1K]
>         Capabilities: [70] Power Management version 2
> 00: 86 80 52 26 07 00 b0 02 03 8f 01 01 00 00 00 00
> 10: f1 cc 00 00 e9 cc 00 00 59 cc 00 00 e1 cc 00 00
> 20: 41 cc 00 00 00 00 fc df 00 00 00 00 86 80 52 26
> 30: 00 00 00 00 70 00 00 00 00 00 00 00 03 03 00 00
> 
> 00:1f.3 SMBus: Intel Corporation 82801FB/FBM/FR/FW/FRW (ICH6 Family) SMBus
> Controller (rev 03)
>         Subsystem: Dell: Unknown device 0185
>         Flags: medium devsel
>         I/O ports at 08c0 [size=32]
> 00: 86 80 6a 26 01 00 80 02 03 00 05 0c 00 00 00 00
> 10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 20: c1 08 00 00 00 00 00 00 00 00 00 00 28 10 85 01
> 30: 00 00 00 00 00 00 00 00 00 00 00 00 00 02 00 00
> 
> 01:00.0 PCI bridge: Intel Corporation 6702PXH PCI Express-to-PCI Bridge A (rev
> 09) (prog-if 00 [Normal decode])
>         Flags: bus master, fast devsel, latency 0
>         Bus: primary=01, secondary=02, subordinate=02, sec-latency=32
>         I/O behind bridge: 0000e000-0000efff
>         Memory behind bridge: dfd00000-dfefffff
>         Prefetchable memory behind bridge: 00000000d8000000-00000000dbf00000
>         Capabilities: [44] Express PCI/PCI-X Bridge IRQ 0
>         Capabilities: [5c] Message Signalled Interrupts: 64bit+ Queue=0/0 Enable-
>         Capabilities: [6c] Power Management version 2
>         Capabilities: [d8] PCI-X bridge device.
>         Capabilities: [100] Advanced Error Reporting
>         Capabilities: [300] Power Budgeting
> 00: 86 80 2c 03 47 00 10 00 09 00 04 06 10 00 81 00
> 10: 00 00 00 00 00 00 00 00 01 02 02 20 e0 e0 a0 02
> 20: d0 df e0 df 01 d8 f1 db 00 00 00 00 00 00 00 00
> 30: 00 00 00 00 44 00 00 00 00 00 00 00 00 00 07 00
> 
> 02:01.0 RAID bus controller: Adaptec AAC-RAID (rev 01)
>         Subsystem: Dell CERC SATA RAID 2 PCI SATA 6ch (DellCorsair)
>         Flags: bus master, 66Mhz, slow devsel, latency 32, IRQ 32
>         Memory at d8000000 (32-bit, prefetchable) [size=64M]
>         Expansion ROM at dfe00000 [disabled] [size=32K]
>         Capabilities: [80] Power Management version 2
> 00: 05 90 85 02 16 01 b0 04 01 00 04 01 10 20 00 00
> 10: 08 00 00 d8 00 00 00 00 00 00 00 00 00 00 00 00
> 20: 00 00 00 00 00 00 00 00 00 00 00 00 28 10 91 02
> 30: 00 00 e0 df 80 00 00 00 00 00 00 00 0b 01 01 01
> 
> 02:02.0 Ethernet controller: Intel Corporation 82545GM Gigabit Ethernet
> Controller (rev 04)
>         Subsystem: Intel Corporation PRO/1000 MT Server Adapter
>         Flags: bus master, 66Mhz, medium devsel, latency 32, IRQ 35
>         Memory at dfde0000 (64-bit, non-prefetchable) [size=128K]
>         I/O ports at ecc0 [size=64]
>         Capabilities: [dc] Power Management version 2
>         Capabilities: [e4] PCI-X non-bridge device.
> 00: 86 80 26 10 17 01 30 02 04 00 00 02 10 20 00 00
> 10: 04 00 de df 00 00 00 00 00 00 00 00 00 00 00 00
> 20: c1 ec 00 00 00 00 00 00 00 00 00 00 86 80 02 10
> 30: 00 00 00 00 dc 00 00 00 00 00 00 00 0a 01 ff 00
> 
> 05:00.0 Ethernet controller: Broadcom Corporation NetXtreme BCM5721 Gigabit
> Ethernet PCI Express (rev 01)
>         Subsystem: Dell: Unknown device 0185
>         Flags: bus master, fast devsel, latency 0, IRQ 18
>         Memory at dfaf0000 (64-bit, non-prefetchable) [size=64K]
>         Capabilities: [48] Power Management version 2
>         Capabilities: [50] Vital Product Data
>         Capabilities: [58] Message Signalled Interrupts: 64bit+ Queue=0/3 Enable-
>         Capabilities: [d0] Express Endpoint IRQ 0
>         Capabilities: [100] Advanced Error Reporting
>         Capabilities: [13c] Virtual Channel
> 00: e4 14 59 16 06 00 10 00 01 00 00 02 10 00 00 00
> 10: 04 00 af df 00 00 00 00 00 00 00 00 00 00 00 00
> 20: 00 00 00 00 00 00 00 00 07 00 00 00 28 10 85 01
> 30: 00 00 00 00 48 00 00 00 00 00 00 00 05 01 00 00
> 
> # cat /proc/net/bonding/bond0
> Ethernet Channel Bonding Driver: v3.1.1 (September 26, 2006)
> 
> Bonding Mode: adaptive load balancing
> Primary Slave: None
> Currently Active Slave: eth0
> MII Status: up
> MII Polling Interval (ms): 100
> Up Delay (ms): 5000
> Down Delay (ms): 0
> 
> Slave Interface: eth0
> MII Status: up
> Link Failure Count: 0
> Permanent HW addr: 00:12:3f:6e:2c:f4
> 
> Slave Interface: eth1
> MII Status: down
> Link Failure Count: 0
> Permanent HW addr: 00:0e:0c:80:f8:a9
> 
> ------- You are receiving this mail because: -------
> You are on the CC list for the bug, or are watching someone who is.
