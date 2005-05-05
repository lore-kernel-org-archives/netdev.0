From: Peter Buckingham <peter@pantasys.com>
Subject: Re: Mystery packet killing tg3
Date: Thu, 05 May 2005 11:40:24 -0700
Message-ID: <427A6898.4070804@pantasys.com>
References: <20050502162405.65dfb4a9@localhost.localdomain> <20050502200251.38271b61.davem@davemloft.net> <m14qdiyhcn.fsf@muc.de> <42791825.2080204@pantasys.com> <20050505114327.GA51761@muc.de> <427A5363.2080703@pantasys.com> <20050505180609.GB24386@muc.de> <427A6426.40104@pantasys.com> <20050505183144.GD24386@muc.de>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050001030104020109040704"
Cc: "David S. Miller" <davem@davemloft.net>, jgarzik@pobox.com,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@muc.de>
In-Reply-To: <20050505183144.GD24386@muc.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------050001030104020109040704
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Andi Kleen wrote:
> That should be impossible. Or it sounds like a serious
> hardware problem. DAC should normally always work with all e1000 AFAIK.

okay.

I basically just force it to take a 32bit dma mask. I admit i'm a little 
clueless as to what this truely means. I had assumed that it would 
result in only dma'ing to an area below 4GB, but I hadn't really 
validated that assumption :-(

> Most likely you have some hardware problem and it is somehow magically
> worked around by IOMMU remapping. One difference is that
> the remapping makes all IO slower, perhaps the changed timing
> works around some bug.

this is always a possibility, can you suggest some ways of isolating 
this problem?

> Have you contacted the e1000 maintainters? 

not as yet, if you think that it is valuable i will.

i've attached a fresh dmesg from a system running off a hard drive. this 
may or may not give you more clues about this.

thanks for your help,

peter

--------------050001030104020109040704
Content-Type: text/plain;
 name="iommu_dmesg.txt"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="iommu_dmesg.txt"

Bootdata ok (command line is vga=normal root=/dev/hda3 console=tty0)
Linux version 2.6.8-24.11-smp (geeko@buildhost) (gcc version 3.3.3 (SuSE Linux)) #1 SMP Tue Mar 1 18:17:49 PST 2005
BIOS-provided physical RAM map:
 BIOS-e820: 0000000000000000 - 000000000009fc00 (usable)
 BIOS-e820: 000000000009fc00 - 00000000000a0000 (reserved)
 BIOS-e820: 00000000000e6000 - 0000000000100000 (reserved)
 BIOS-e820: 0000000000100000 - 0000000097ff0000 (usable)
 BIOS-e820: 0000000097ff0000 - 0000000097ffe000 (ACPI data)
 BIOS-e820: 0000000097ffe000 - 0000000098000000 (ACPI NVS)
 BIOS-e820: 00000000fec00000 - 00000000fec01000 (reserved)
 BIOS-e820: 00000000fee00000 - 00000000fee01000 (reserved)
 BIOS-e820: 00000000ff780000 - 0000000100000000 (reserved)
 BIOS-e820: 0000000100000000 - 0000000240000000 (usable)
Scanning NUMA topology in Northbridge 24
Number of nodes 8 (70070)
Node 0 MemBase 0000000000000000 Limit 000000007fffffff
Node 1 MemBase 0000000080000000 Limit 00000000ffffffff
Node 2 MemBase 0000000100000000 Limit 000000017fffffff
Node 3 MemBase 0000000180000000 Limit 00000001ffffffff
Skipping disabled node 4
Skipping disabled node 5
Node 6 MemBase 0000000200000000 Limit 000000023fffffff
Skipping disabled node 7
node 1 shift 24 addr ff000000 conflict 0
node 3 shift 25 addr 1fe000000 conflict 0
Using node hash shift of 26
Bootmem setup node 0 0000000000000000-000000007fffffff
Bootmem setup node 1 0000000080000000-00000000ffffffff
Bootmem setup node 2 0000000100000000-000000017fffffff
Bootmem setup node 3 0000000180000000-00000001ffffffff
Bootmem setup node 6 0000000200000000-000000023fffffff
No mptable found.
On node 0 totalpages: 524287
  DMA zone: 4096 pages, LIFO batch:1
  Normal zone: 520191 pages, LIFO batch:16
  HighMem zone: 0 pages, LIFO batch:1
On node 1 totalpages: 524287
  DMA zone: 0 pages, LIFO batch:1
  Normal zone: 524287 pages, LIFO batch:16
  HighMem zone: 0 pages, LIFO batch:1
On node 2 totalpages: 524287
  DMA zone: 0 pages, LIFO batch:1
  Normal zone: 524287 pages, LIFO batch:16
  HighMem zone: 0 pages, LIFO batch:1
On node 3 totalpages: 524287
  DMA zone: 0 pages, LIFO batch:1
  Normal zone: 524287 pages, LIFO batch:16
  HighMem zone: 0 pages, LIFO batch:1
On node 6 totalpages: 262143
  DMA zone: 0 pages, LIFO batch:1
  Normal zone: 262143 pages, LIFO batch:16
  HighMem zone: 0 pages, LIFO batch:1
NVidia chipset found. Disabling timer override
ACPI: RSDP (v000 ACPIAM                                    ) @ 0x00000000000f8700
ACPI: RSDT (v001 A M I  OEMRSDT  0x03000518 MSFT 0x00000097) @ 0x0000000097ff0000
ACPI: FADT (v002 A M I  OEMFACP  0x03000518 MSFT 0x00000097) @ 0x0000000097ff0200
ACPI: MADT (v001 A M I  OEMAPIC  0x03000518 MSFT 0x00000097) @ 0x0000000097ff0390
ACPI: OEMB (v001 A M I  AMI_OEM  0x03000518 MSFT 0x00000097) @ 0x0000000097ffe040
ACPI: MCFG (v001 A M I  OEMMCFG  0x03000518 MSFT 0x00000097) @ 0x0000000097ff65e0
ACPI: DSDT (v001  0ABGS 0ABGS023 0x00000023 INTL 0x02002026) @ 0x0000000000000000
ACPI: Local APIC address 0xfee00000
ACPI: LAPIC (acpi_id[0x01] lapic_id[0x00] enabled)
Processor #0 15:5 APIC version 16
ACPI: LAPIC (acpi_id[0x02] lapic_id[0x01] enabled)
Processor #1 15:5 APIC version 16
ACPI: LAPIC (acpi_id[0x03] lapic_id[0x02] enabled)
Processor #2 15:5 APIC version 16
ACPI: LAPIC (acpi_id[0x04] lapic_id[0x03] enabled)
Processor #3 15:5 APIC version 16
ACPI: LAPIC (acpi_id[0x05] lapic_id[0x04] enabled)
Processor #4 15:5 APIC version 16
ACPI: LAPIC (acpi_id[0x06] lapic_id[0x05] enabled)
Processor #5 15:5 APIC version 16
ACPI: LAPIC (acpi_id[0x07] lapic_id[0x06] enabled)
Processor #6 15:5 APIC version 16
ACPI: LAPIC (acpi_id[0x08] lapic_id[0x07] enabled)
Processor #7 15:5 APIC version 16
ACPI: IOAPIC (id[0x08] address[0xfec00000] gsi_base[0])
IOAPIC[0]: apic_id 8, version 17, address 0xfec00000, GSI 0-23
ACPI: IOAPIC (id[0x09] address[0xbeeff000] gsi_base[24])
IOAPIC[1]: apic_id 9, version 17, address 0xbeeff000, GSI 24-47
ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
ACPI: IRQ9 used by override.
Using ACPI (MADT) for SMP configuration information
Checking aperture...
CPU 0: aperture @ 98000000 size 32 MB
Aperture from northbridge cpu 0 too small (32 MB)
No AGP bridge found
Your BIOS doesn't leave a aperture memory hole
Please enable the IOMMU option in the BIOS setup
This costs you 64 MB of RAM
Mapping aperture over 65536 KB of RAM @ 4000000
Built 8 zonelists
Kernel command line: vga=normal root=/dev/hda3 console=tty0
Initializing CPU#0
PID hash table entries: 4096 (order: 12, 131072 bytes)
time.c: Using 1.193182 MHz PIT timer.
time.c: Detected 2000.032 MHz processor.
Console: colour VGA+ 80x25
Dentry cache hash table entries: 2097152 (order: 12, 16777216 bytes)
Inode-cache hash table entries: 1048576 (order: 11, 8388608 bytes)
Memory: 7505340k/9437184k available (3226k kernel code, 0k reserved, 1578k data, 228k init)
Calibrating delay loop... 3964.92 BogoMIPS (lpj=1982464)
Mount-cache hash table entries: 256 (order: 0, 4096 bytes)
CPU: L1 I Cache: 64K (64 bytes/line), D cache 64K (64 bytes/line)
CPU: L2 Cache: 1024K (64 bytes/line)
Using local APIC NMI watchdog using perfctr0
CPU: L1 I Cache: 64K (64 bytes/line), D cache 64K (64 bytes/line)
CPU: L2 Cache: 1024K (64 bytes/line)
CPU0: AMD Opteron(tm) Processor 846 HE stepping 0a
per-CPU timeslice cutoff: 1023.93 usecs.
task migration cache decay timeout: 2 msecs.
Booting processor 1/1 rip 6000 rsp 10202647f58
Initializing CPU#1
Calibrating delay loop... <7>spurious 8259A interrupt: IRQ7.
3940.35 BogoMIPS (lpj=1970176)
CPU: L1 I Cache: 64K (64 bytes/line), D cache 64K (64 bytes/line)
CPU: L2 Cache: 1024K (64 bytes/line)
AMD Opteron(tm) Processor 846 HE stepping 0a
Booting processor 2/2 rip 6000 rsp 101fff93f58
Initializing CPU#2
Calibrating delay loop... 3940.35 BogoMIPS (lpj=1970176)
CPU: L1 I Cache: 64K (64 bytes/line), D cache 64K (64 bytes/line)
CPU: L2 Cache: 1024K (64 bytes/line)
AMD Opteron(tm) Processor 846 HE stepping 0a
Booting processor 3/3 rip 6000 rsp 1023ff85f58
Initializing CPU#3
Calibrating delay loop... 3940.35 BogoMIPS (lpj=1970176)
CPU: L1 I Cache: 64K (64 bytes/line), D cache 64K (64 bytes/line)
CPU: L2 Cache: 1024K (64 bytes/line)
AMD Opteron(tm) Processor 846 HE stepping 0a
Booting processor 4/4 rip 6000 rsp 10097fbbf58
Initializing CPU#4
Calibrating delay loop... 3940.35 BogoMIPS (lpj=1970176)
CPU: L1 I Cache: 64K (64 bytes/line), D cache 64K (64 bytes/line)
CPU: L2 Cache: 1024K (64 bytes/line)
AMD Opteron(tm) Processor 846 HE stepping 0a
Booting processor 5/5 rip 6000 rsp 10181c49f58
Initializing CPU#5
Calibrating delay loop... 3940.35 BogoMIPS (lpj=1970176)
CPU: L1 I Cache: 64K (64 bytes/line), D cache 64K (64 bytes/line)
CPU: L2 Cache: 1024K (64 bytes/line)
AMD Opteron(tm) Processor 846 HE stepping 0a
Booting processor 6/6 rip 6000 rsp 10008069f58
Initializing CPU#6
Calibrating delay loop... 3940.35 BogoMIPS (lpj=1970176)
CPU: L1 I Cache: 64K (64 bytes/line), D cache 64K (64 bytes/line)
CPU: L2 Cache: 1024K (64 bytes/line)
AMD Opteron(tm) Processor 846 HE stepping 0a
Booting processor 7/7 rip 6000 rsp 10081c7df58
Initializing CPU#7
Calibrating delay loop... 3940.35 BogoMIPS (lpj=1970176)
CPU: L1 I Cache: 64K (64 bytes/line), D cache 64K (64 bytes/line)
CPU: L2 Cache: 1024K (64 bytes/line)
AMD Opteron(tm) Processor 846 HE stepping 0a
Total of 8 processors activated (31547.39 BogoMIPS).
Using local APIC timer interrupts.
Detected 12.500 MHz APIC timer.
checking TSC synchronization across 8 CPUs: passed.
time.c: Using PIT/TSC based timekeeping.
Brought up 8 CPUs
NET: Registered protocol family 16
PCI: Using configuration type 1
mtrr: v2.0 (20020519)
ACPI: Subsystem revision 20040715
ACPI: Interpreter enabled
ACPI: Using IOAPIC for interrupt routing
ACPI: PCI Root Bridge [PCI0] (00:00)
PCI: Probing PCI hardware (bus 00)
PCI: Transparent bridge - 0000:00:09.0
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.P0P1._PRT]
ACPI: PCI Root Bridge [PCIC] (00:40)
PCI: Probing PCI hardware (bus 40)
ACPI: PCI Interrupt Routing Table [\_SB_.PCIC._PRT]
ACPI: PCI Interrupt Link [LNKA] (IRQs 16 17 18 19) *10
ACPI: PCI Interrupt Link [LNKB] (IRQs 16 17 18 19) *9
ACPI: PCI Interrupt Link [LNKC] (IRQs 16 17 18 19) *11
ACPI: PCI Interrupt Link [LNKD] (IRQs 16 17 18 19) *0, disabled.
ACPI: PCI Interrupt Link [LNKE] (IRQs 16 17 18 19) *0, disabled.
ACPI: PCI Interrupt Link [LUS0] (IRQs 20 21 22) *0, disabled.
ACPI: PCI Interrupt Link [LUS1] (IRQs 20 21 22) *0, disabled.
ACPI: PCI Interrupt Link [LUS2] (IRQs 20 21 22) *0, disabled.
ACPI: PCI Interrupt Link [LKLN] (IRQs 20 21 22) *0, disabled.
ACPI: PCI Interrupt Link [LAUI] (IRQs 20 21 22) *0, disabled.
ACPI: PCI Interrupt Link [LKMO] (IRQs 20 21 22) *0, disabled.
ACPI: PCI Interrupt Link [LKSM] (IRQs 20 21 22) *0, disabled.
ACPI: PCI Interrupt Link [LTID] (IRQs 20 21 22) *0, disabled.
ACPI: PCI Interrupt Link [LTIE] (IRQs 20 21 22) *0, disabled.
ACPI: PCI Interrupt Link [LATA] (IRQs 20 21 22) *14
ACPI: PCI Interrupt Link [LN2A] (IRQs 40 41 42 43) *0, disabled.
ACPI: PCI Interrupt Link [LN2B] (IRQs 40 41 42 43) *0, disabled.
ACPI: PCI Interrupt Link [LN2C] (IRQs 40 41 42 43) *0, disabled.
ACPI: PCI Interrupt Link [LN2D] (IRQs 40 41 42 43) *0, disabled.
ACPI: PCI Interrupt Link [LK2N] (IRQs 44 45 46 47) *0, disabled.
ACPI: PCI Interrupt Link [LT5D] (IRQs 44 45 46 47) *0, disabled.
ACPI: PCI Interrupt Link [LT2E] (IRQs 44 45 46 47) *0, disabled.
ACPI: PCI Interrupt Link [LN3A] (IRQs 40 41 42 43) *0, disabled.
ACPI: PCI Interrupt Link [LN3B] (IRQs 40 41 42 43) *0, disabled.
ACPI: PCI Interrupt Link [LN3C] (IRQs 40 41 42 43) *0, disabled.
ACPI: PCI Interrupt Link [LN3D] (IRQs 40 41 42 43) *0, disabled.
ACPI: PCI Interrupt Link [LN4A] (IRQs 40 41 42 43) *0, disabled.
ACPI: PCI Interrupt Link [LN4B] (IRQs 40 41 42 43) *0, disabled.
ACPI: PCI Interrupt Link [LN4C] (IRQs 40 41 42 43) *0, disabled.
ACPI: PCI Interrupt Link [LN4D] (IRQs 40 41 42 43) *0, disabled.
SCSI subsystem initialized
usbcore: registered new driver usbfs
usbcore: registered new driver hub
PCI: Using ACPI for IRQ routing
ACPI: PCI Interrupt Link [LKSM] enabled at IRQ 22
ACPI: PCI interrupt 0000:00:01.1[A] -> GSI 22 (level, low) -> IRQ 22
ACPI: PCI Interrupt Link [LNKA] enabled at IRQ 19
ACPI: PCI interrupt 0000:05:06.0[A] -> GSI 19 (level, low) -> IRQ 19
ACPI: PCI Interrupt Link [LNKB] enabled at IRQ 18
ACPI: PCI interrupt 0000:05:07.0[A] -> GSI 18 (level, low) -> IRQ 18
ACPI: PCI Interrupt Link [LNKC] enabled at IRQ 17
ACPI: PCI interrupt 0000:01:00.0[A] -> GSI 17 (level, low) -> IRQ 17
ACPI: PCI Interrupt Link [LN3C] enabled at IRQ 43
ACPI: PCI interrupt 0000:41:00.0[A] -> GSI 43 (level, low) -> IRQ 43
PCI-DMA: Disabling AGP.
PCI-DMA: aperture base @ 4000000 size 65536 KB
PCI-DMA: Reserving 64MB of IOMMU area in the AGP aperture
IA32 emulation $Id: sys_ia32.c 72 2005-03-02 01:01:07Z peter $
Total HugeTLB memory allocated, 0
NTFS driver 2.1.17 [Flags: R/O].
subfs 0.9
Initializing Cryptographic API
pci_hotplug: PCI Hot Plug PCI Core version: 0.5
pciehp: PCI Express Hot Plug Controller Driver version: 0.4
vesafb: probe of vesafb0 failed with error -6
ACPI: Power Button (FF) [PWRF]
ACPI: Processor [CPU1] (supports C1)
ACPI: Processor [CPU2] (supports C1)
ACPI: Processor [CPU3] (supports C1)
ACPI: Processor [CPU4] (supports C1)
ACPI: Processor [CPU5] (supports C1)
ACPI: Processor [CPU6] (supports C1)
ACPI: Processor [CPU7] (supports C1)
ACPI: Processor [CPU8] (supports C1)
Real Time Clock Driver v1.12
Non-volatile memory driver v1.2
Linux agpgart interface v0.100 (c) Dave Jones
ipmi message handler version v33
ipmi device interface version v33
IPMI System Interface driver version v33, KCS version v33, SMIC version v33, BT version v33
ipmi_si: Found SMBIOS-specified state machine at I/O address 0x62
 Could not set up I/O space
Trying to free nonexistent resource <00000062-00000063>
ipmi_si: Unable to find any System Interface(s)
Copyright (C) 2004 MontaVista Software - IPMI Powerdown via sys_reboot version v33.
serio: i8042 KBD port at 0x60,0x64 irq 1
serio: i8042 AUX port at 0x60,0x64 irq 12
Serial: 8250/16550 driver $Revision: 1.1 $ 8 ports, IRQ sharing disabled
ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
ttyS1 at I/O 0x2f8 (irq = 3) is a 16550A
RAMDISK driver initialized: 16 RAM disks of 65536K size 1024 blocksize
loop: loaded (max 8 devices)
nbd: Couldn't get a blowfish cipher context.
Intel(R) PRO/1000 Network Driver - version 5.3.19-k2
Copyright (c) 1999-2004 Intel Corporation.
ACPI: PCI interrupt 0000:05:07.0[A] -> GSI 18 (level, low) -> IRQ 18
e1000: eth0: e1000_probe: Intel(R) PRO/1000 Network Connection
eth0: TCP Segmentation Offload (TSO) disabled by default
pcnet32.c:v1.30i 06.28.2004 tsbogend@alpha.franken.de
e100: Intel(R) PRO/100 Network Driver, 3.0.27-k2-NAPI
e100: Copyright(c) 1999-2004 Intel Corporation
Uniform Multi-Platform E-IDE driver Revision: 7.00alpha2
ide: Assuming 33MHz system bus speed for PIO modes; override with idebus=xx
NFORCE-CK804: IDE controller at PCI slot 0000:00:06.0
NFORCE-CK804: chipset revision 162
NFORCE-CK804: not 100% native mode: will probe irqs later
NFORCE-CK804: 0000:00:06.0 (rev a2) UDMA133 controller
    ide0: BM-DMA at 0x6000-0x6007, BIOS settings: hda:DMA, hdb:DMA
    ide1: BM-DMA at 0x6008-0x600f, BIOS settings: hdc:DMA, hdd:DMA
Probing IDE interface ide0...
hda: FUJITSU MHT2040AS, ATA DISK drive
Using anticipatory io scheduler
ide0 at 0x1f0-0x1f7,0x3f6 on irq 14
Probing IDE interface ide1...
Probing IDE interface ide1...
Probing IDE interface ide2...
ide2: Wait for ready failed before probe !
Probing IDE interface ide3...
ide3: Wait for ready failed before probe !
Probing IDE interface ide4...
ide4: Wait for ready failed before probe !
Probing IDE interface ide5...
ide5: Wait for ready failed before probe !
hda: max request size: 128KiB
hda: 78140160 sectors (40007 MB) w/8192KiB Cache, CHS=65535/16/63, UDMA(33)
hda: cache flushes supported
 hda: hda1 hda2 hda3
ohci_hcd: 2004 Feb 02 USB 1.1 'Open' Host Controller (OHCI) Driver (PCI)
USB Universal Host Controller Interface driver v2.2
Initializing USB Mass Storage driver...
usbcore: registered new driver usb-storage
USB Mass Storage support registered.
usbcore: registered new driver hiddev
usbcore: registered new driver usbhid
/panta-build/kernel-sources/SuSE-2.6.8/drivers/usb/input/hid-core.c: v2.0:USB HID core driver
mice: PS/2 mouse device common for all mice
input: AT Translated Set 2 keyboard on isa0060/serio0
NET: Registered protocol family 2
IP: routing cache hash table of 65536 buckets, 1024Kbytes
TCP: Hash tables configured (established 262144 bind 65536)
ip_conntrack version 2.1 (8192 buckets, 65536 max) - 520 bytes per conntrack
ip_tables: (C) 2000-2002 Netfilter core team
ipt_recent v0.3.1: Stephen Frost <sfrost@snowman.net>.  http://snowman.net/projects/ipt_recent/
ClusterIP Version 0.5 loaded successfully
arp_tables: (C) 2002 David S. Miller
NET: Registered protocol family 1
NET: Registered protocol family 17
ACPI: (supports S0 S1 S5)
ACPI wakeup devices: 
PS2K USB0 USB1 P0P1 P0P2 P0P3 P0P4 P0P5 BR84 BR83 BR82 BR81 PWRB 
kjournald starting.  Commit interval 5 seconds
EXT3-fs: mounted filesystem with ordered data mode.
VFS: Mounted root (ext3 filesystem) readonly.
Freeing unused kernel memory: 228k freed
EXT3 FS on hda3, internal journal
FAT: utf8 is not a recommended IO charset for FAT filesystems, filesystem will be case sensitive!
Adding 1052248k swap on /dev/hda2.  Priority:42 extents:1
 --------------------- ioctl INIT: pci_find_slot(1, 0)
 --------------------- ioctl INIT: pci_find_slot(1, 0)
 --------------------- ioctl INIT: pci_find_slot(1, 0)
 --------------------- ioctl INIT: pci_find_slot(65, 0)
 --------------------- ioctl INIT: pci_find_slot(65, 0)
 --------------------- ioctl INIT: pci_find_slot(65, 0)
e1000: eth0: e1000_watchdog: NIC Link is Up 100 Mbps Full Duplex
PCI: Setting latency timer of device 0000:01:00.0 to 64
ACPI: PCI interrupt 0000:01:00.0[A] -> GSI 17 (level, low) -> IRQ 17
PCI: Setting latency timer of device 0000:41:00.0 to 64
ACPI: PCI interrupt 0000:41:00.0[A] -> GSI 43 (level, low) -> IRQ 43

Mellanox Tavor Device Driver is creating device "InfiniHost0" (bus=01, devfn=00)


Mellanox Tavor Device Driver is creating device "InfiniHost1" (bus=41, devfn=00)

THH kernel module initialized successfully
[KERNEL_IB][ib_mad_static_compute_base][/var/tmp/IBGD/lib/modules/2.6.8-24.11-smp/source/drivers/infiniband/core/mad_static.c:93]Couldn't find a suitable network device; setting lid_base to 1
NET: Registered protocol family 26

--------------050001030104020109040704--
