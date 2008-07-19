From: Ian Jeffray <ian@jeffray.co.uk>
Subject: Re: sendfile() broken with 2.6.26 + Apache 2 ?
Date: Sat, 19 Jul 2008 17:31:12 +0100
Message-ID: <488216D0.9060703@jeffray.co.uk>
References: <487CD7A7.2080800@jeffray.co.uk>	<4881DEB2.8030508@bellsouth.net>	<4881E0BD.4060608@jeffray.co.uk> <20080719095215.375ae9a2@osprey.hogchain.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jay Cliburn <jacliburn@bellsouth.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.blueyonder.co.uk ([195.188.213.7]:57521 "EHLO
	smtp-out4.blueyonder.co.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752919AbYGSQbS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Jul 2008 12:31:18 -0400
In-Reply-To: <20080719095215.375ae9a2@osprey.hogchain.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jay Cliburn wrote:
> On Sat, 19 Jul 2008 13:40:29 +0100
> Ian Jeffray <ian@jeffray.co.uk> wrote:
> 
>> Hi Jay,
>>
>>> Can you please enable verbose logging
>>>
>>> echo 8 > /proc/sys/kernel/printk
>>> ethtool -s eth0 msglvl 0xffff
>>>
>>> and see if the driver issues any error messages as the file is
>>> transferred?
>> Nothing, sorry.
> 
> Can you please provide a complete dmesg for the sender?

I'm not sure what you really mean here.   Certainly nothing EXTRA
appears in the log when I turn on that logging.   Maybe I'm missing
something?  Sorry.   Anyhow, here's my full dmesg - though I
suspect this isn't what you're after.

Ian

ian@moschops $ dmesg
Linux version 2.6.26 (ian@moschops) (gcc version 4.3.1 (Debian 4.3.1-2) 
) #2 SMP Tue Jul 15 00:27:51 BST 2008
BIOS-provided physical RAM map:
  BIOS-e820: 0000000000000000 - 000000000009fc00 (usable)
  BIOS-e820: 000000000009fc00 - 00000000000a0000 (reserved)
  BIOS-e820: 00000000000e4000 - 0000000000100000 (reserved)
  BIOS-e820: 0000000000100000 - 000000007ff80000 (usable)
  BIOS-e820: 000000007ff80000 - 000000007ff8e000 (ACPI data)
  BIOS-e820: 000000007ff8e000 - 000000007ffe0000 (ACPI NVS)
  BIOS-e820: 000000007ffe0000 - 0000000080000000 (reserved)
  BIOS-e820: 00000000fee00000 - 00000000fee01000 (reserved)
  BIOS-e820: 00000000fff00000 - 0000000100000000 (reserved)
1151MB HIGHMEM available.
896MB LOWMEM available.
found SMP MP-table at [c00ff780] 000ff780
Entering add_active_range(0, 0, 524160) 0 entries of 256 used
Zone PFN ranges:
   DMA             0 ->     4096
   Normal       4096 ->   229376
   HighMem    229376 ->   524160
Movable zone start PFN for each node
early_node_map[1] active PFN ranges
     0:        0 ->   524160
On node 0 totalpages: 524160
   DMA zone: 32 pages used for memmap
   DMA zone: 0 pages reserved
   DMA zone: 4064 pages, LIFO batch:0
   Normal zone: 1760 pages used for memmap
   Normal zone: 223520 pages, LIFO batch:31
   HighMem zone: 2303 pages used for memmap
   HighMem zone: 292481 pages, LIFO batch:31
   Movable zone: 0 pages used for memmap
DMI 2.4 present.
ACPI: RSDP 000FBCC0, 0014 (r0 ACPIAM)
ACPI: RSDT 7FF80000, 003C (r1 A_M_I_ OEMRSDT   7000703 MSFT       97)
ACPI: FACP 7FF80200, 0084 (r2 A_M_I_ OEMFACP   7000703 MSFT       97)
ACPI: DSDT 7FF805C0, 8C16 (r1  A0753 A0753001        1 INTL 20060113)
ACPI: FACS 7FF8E000, 0040
ACPI: APIC 7FF80390, 006C (r1 A_M_I_ OEMAPIC   7000703 MSFT       97)
ACPI: MCFG 7FF80400, 003C (r1 A_M_I_ OEMMCFG   7000703 MSFT       97)
ACPI: OEMB 7FF8E040, 0081 (r1 A_M_I_ AMI_OEM   7000703 MSFT       97)
ACPI: HPET 7FF891E0, 0038 (r1 A_M_I_ OEMHPET   7000703 MSFT       97)
ACPI: OSFR 7FF89220, 00B0 (r1 A_M_I_ OEMOSFR   7000703 MSFT       97)
ACPI: PM-Timer IO Port: 0x808
ACPI: Local APIC address 0xfee00000
ACPI: LAPIC (acpi_id[0x01] lapic_id[0x00] enabled)
ACPI: LAPIC (acpi_id[0x02] lapic_id[0x01] enabled)
ACPI: LAPIC (acpi_id[0x03] lapic_id[0x82] disabled)
ACPI: LAPIC (acpi_id[0x04] lapic_id[0x83] disabled)
ACPI: IOAPIC (id[0x02] address[0xfec00000] gsi_base[0])
IOAPIC[0]: apic_id 2, version 32, address 0xfec00000, GSI 0-23
ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
ACPI: IRQ0 used by override.
ACPI: IRQ2 used by override.
ACPI: IRQ9 used by override.
Enabling APIC mode:  Flat.  Using 1 I/O APICs
ACPI: HPET id: 0xffffffff base: 0xfed00000
Using ACPI (MADT) for SMP configuration information
Allocating PCI resources starting at 88000000 (gap: 80000000:7ee00000)
SMP: Allowing 4 CPUs, 2 hotplug CPUs
PERCPU: Allocating 41704 bytes of per cpu data
NR_CPUS: 8, nr_cpu_ids: 4
Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 520065
Kernel command line: root=/dev/sda1 ro quiet
mapped APIC to ffffb000 (fee00000)
mapped IOAPIC to ffffa000 (fec00000)
Enabling fast FPU save and restore... done.
Enabling unmasked SIMD FPU exception support... done.
Initializing CPU#0
PID hash table entries: 4096 (order: 12, 16384 bytes)
Detected 2671.693 MHz processor.
Console: colour VGA+ 80x25
console [tty0] enabled
Dentry cache hash table entries: 131072 (order: 7, 524288 bytes)
Inode-cache hash table entries: 65536 (order: 6, 262144 bytes)
Memory: 2072176k/2096640k available (4172k kernel code, 23412k reserved, 
1238k data, 276k init, 1179136k highmem)
virtual kernel memory layout:
     fixmap  : 0xfff4d000 - 0xfffff000   ( 712 kB)
     pkmap   : 0xff800000 - 0xffc00000   (4096 kB)
     vmalloc : 0xf8800000 - 0xff7fe000   ( 111 MB)
     lowmem  : 0xc0000000 - 0xf8000000   ( 896 MB)
       .init : 0xc0651000 - 0xc0696000   ( 276 kB)
       .data : 0xc05133d8 - 0xc0648f9c   (1238 kB)
       .text : 0xc0100000 - 0xc05133d8   (4172 kB)
Checking if this processor honours the WP bit even in supervisor mode...Ok.
CPA: page pool initialized 1 of 1 pages preallocated
hpet clockevent registered
Calibrating delay using timer specific routine.. 5346.76 BogoMIPS 
(lpj=10693532)
Mount-cache hash table entries: 512
CPU: L1 I cache: 32K, L1 D cache: 32K
CPU: L2 cache: 4096K
CPU: Physical Processor ID: 0
CPU: Processor Core ID: 0
Intel machine check architecture supported.
Intel machine check reporting enabled on CPU#0.
using mwait in idle threads.
Checking 'hlt' instruction... OK.
ACPI: Core revision 20080321
ENABLING IO-APIC IRQs
..TIMER: vector=0x31 apic1=0 pin1=2 apic2=-1 pin2=-1
CPU0: Intel(R) Core(TM)2 Duo CPU     E6750  @ 2.66GHz stepping 0b
Booting processor 1/1 ip 2000
Initializing CPU#1
Calibrating delay using timer specific routine.. 5343.23 BogoMIPS 
(lpj=10686460)
CPU: L1 I cache: 32K, L1 D cache: 32K
CPU: L2 cache: 4096K
CPU: Physical Processor ID: 0
CPU: Processor Core ID: 1
Intel machine check architecture supported.
Intel machine check reporting enabled on CPU#1.
CPU1: Intel(R) Core(TM)2 Duo CPU     E6750  @ 2.66GHz stepping 0b
checking TSC synchronization [CPU#0 -> CPU#1]: passed.
Brought up 2 CPUs
Total of 2 processors activated (10689.99 BogoMIPS).
net_namespace: 644 bytes
NET: Registered protocol family 16
No dock devices found.
ACPI: bus type pci registered
PCI: MCFG configuration 0: base e0000000 segment 0 buses 0 - 255
PCI: Not using MMCONFIG.
PCI: PCI BIOS revision 3.00 entry at 0xf0031, last bus=5
PCI: Using configuration type 1 for base access
Setting up standard PCI resources
ACPI: EC: Look up EC in DSDT
ACPI: Interpreter enabled
ACPI: (supports S0 S5)
ACPI: Using IOAPIC for interrupt routing
PCI: MCFG configuration 0: base e0000000 segment 0 buses 0 - 255
PCI: MCFG area at e0000000 reserved in ACPI motherboard resources
PCI: Using MMCONFIG for extended config space
ACPI: PCI Root Bridge [PCI0] (0000:00)
pci 0000:00:1f.0: quirk: region 0800-087f claimed by ICH6 ACPI/GPIO/TCO
pci 0000:00:1f.0: quirk: region 0480-04bf claimed by ICH6 GPIO
PCI: Transparent bridge - 0000:00:1e.0
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.P0P2._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.P0P1._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.P0P8._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.P0P9._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.P0P4._PRT]
ACPI: PCI Interrupt Link [LNKA] (IRQs 3 4 5 6 7 10 *11 12 14 15)
ACPI: PCI Interrupt Link [LNKB] (IRQs 3 4 5 6 7 *10 11 12 14 15)
ACPI: PCI Interrupt Link [LNKC] (IRQs 3 4 *5 6 7 10 11 12 14 15)
ACPI: PCI Interrupt Link [LNKD] (IRQs 3 4 5 6 7 10 11 12 *14 15)
ACPI: PCI Interrupt Link [LNKE] (IRQs 3 4 5 6 7 10 11 12 14 15) *0, 
disabled.
ACPI: PCI Interrupt Link [LNKF] (IRQs *3 4 5 6 7 10 11 12 14 15)
ACPI: PCI Interrupt Link [LNKG] (IRQs 3 4 5 6 7 10 11 12 14 *15)
ACPI: PCI Interrupt Link [LNKH] (IRQs 3 4 5 6 *7 10 11 12 14 15)
ACPI Warning (tbutils-0217): Incorrect checksum in table [OEMB] - ED, 
should be EC [20080321]
Linux Plug and Play Support v0.97 (c) Adam Belay
pnp: PnP ACPI init
ACPI: bus type pnp registered
pnp: PnP ACPI: found 14 devices
ACPI: ACPI bus type pnp unregistered
PnPBIOS: Disabled by ACPI PNP
SCSI subsystem initialized
libata version 3.00 loaded.
usbcore: registered new interface driver usbfs
usbcore: registered new interface driver hub
usbcore: registered new device driver usb
PCI: Using ACPI for IRQ routing
NET: Registered protocol family 8
NET: Registered protocol family 20
hpet0: at MMIO 0xfed00000, IRQs 2, 8, 0, 0
hpet0: 4 64-bit timers, 14318180 Hz
ACPI: RTC can wake from S4
system 00:01: iomem range 0xfed14000-0xfed19fff has been reserved
system 00:06: ioport range 0x290-0x297 has been reserved
system 00:07: ioport range 0x4d0-0x4d1 has been reserved
system 00:07: ioport range 0x800-0x87f has been reserved
system 00:07: ioport range 0x480-0x4bf has been reserved
system 00:07: iomem range 0xfed1c000-0xfed1ffff has been reserved
system 00:07: iomem range 0xfed20000-0xfed3ffff has been reserved
system 00:07: iomem range 0xfed50000-0xfed8ffff has been reserved
system 00:07: iomem range 0xffa00000-0xffafffff has been reserved
system 00:07: iomem range 0xffb00000-0xffbfffff has been reserved
system 00:07: iomem range 0xffe00000-0xffefffff has been reserved
system 00:07: iomem range 0xfff00000-0xfffffffe could not be reserved
system 00:0a: iomem range 0xfec00000-0xfec00fff has been reserved
system 00:0a: iomem range 0xfee00000-0xfee00fff could not be reserved
system 00:0c: iomem range 0xe0000000-0xefffffff has been reserved
system 00:0d: iomem range 0x0-0x9ffff could not be reserved
system 00:0d: iomem range 0xc0000-0xcffff could not be reserved
system 00:0d: iomem range 0xe0000-0xfffff could not be reserved
system 00:0d: iomem range 0x100000-0x7fffffff could not be reserved
PCI: Bridge: 0000:00:01.0
   IO window: disabled.
   MEM window: 0xfc000000-0xfe8fffff
   PREFETCH window: 0x00000000d0000000-0x00000000dfffffff
PCI: Bridge: 0000:00:1c.0
   IO window: disabled.
   MEM window: disabled.
   PREFETCH window: 0x00000000fae00000-0x00000000faefffff
PCI: Bridge: 0000:00:1c.4
   IO window: d000-dfff
   MEM window: 0xfea00000-0xfeafffff
   PREFETCH window: disabled.
PCI: Bridge: 0000:00:1c.5
   IO window: disabled.
   MEM window: 0xfe900000-0xfe9fffff
   PREFETCH window: 0x0000000088000000-0x00000000880fffff
PCI: Bridge: 0000:00:1e.0
   IO window: e000-efff
   MEM window: 0xfeb00000-0xfebfffff
   PREFETCH window: 0x00000000faf00000-0x00000000faffffff
ACPI: PCI Interrupt 0000:00:01.0[A] -> GSI 16 (level, low) -> IRQ 16
PCI: Setting latency timer of device 0000:00:01.0 to 64
ACPI: PCI Interrupt 0000:00:1c.0[A] -> GSI 17 (level, low) -> IRQ 17
PCI: Setting latency timer of device 0000:00:1c.0 to 64
ACPI: PCI Interrupt 0000:00:1c.4[A] -> GSI 17 (level, low) -> IRQ 17
PCI: Setting latency timer of device 0000:00:1c.4 to 64
ACPI: PCI Interrupt 0000:00:1c.5[B] -> GSI 16 (level, low) -> IRQ 16
PCI: Setting latency timer of device 0000:00:1c.5 to 64
PCI: Setting latency timer of device 0000:00:1e.0 to 64
NET: Registered protocol family 2
IP route cache hash table entries: 32768 (order: 5, 131072 bytes)
TCP established hash table entries: 131072 (order: 8, 1048576 bytes)
TCP bind hash table entries: 65536 (order: 7, 524288 bytes)
TCP: Hash tables configured (established 131072 bind 65536)
TCP reno registered
NET: Registered protocol family 1
audit: initializing netlink socket (disabled)
type=2000 audit(1216140289.344:1): initialized
highmem bounce pool size: 64 pages
Installing knfsd (copyright (C) 1996 okir@monad.swb.de).
NTFS driver 2.1.29 [Flags: R/O].
SGI XFS with ACLs, security attributes, realtime, large block numbers, 
no debug enabled
SGI XFS Quota Management subsystem
msgmni has been set to 1745
io scheduler noop registered
io scheduler anticipatory registered
io scheduler deadline registered
io scheduler cfq registered (default)
pci 0000:01:00.0: Boot video device
PCI: Setting latency timer of device 0000:00:01.0 to 64
assign_interrupt_mode Found MSI capability
Allocate Port Service[0000:00:01.0:pcie00]
Allocate Port Service[0000:00:01.0:pcie03]
PCI: Setting latency timer of device 0000:00:1c.0 to 64
assign_interrupt_mode Found MSI capability
Allocate Port Service[0000:00:1c.0:pcie00]
Allocate Port Service[0000:00:1c.0:pcie02]
Allocate Port Service[0000:00:1c.0:pcie03]
PCI: Setting latency timer of device 0000:00:1c.4 to 64
assign_interrupt_mode Found MSI capability
Allocate Port Service[0000:00:1c.4:pcie00]
Allocate Port Service[0000:00:1c.4:pcie02]
Allocate Port Service[0000:00:1c.4:pcie03]
PCI: Setting latency timer of device 0000:00:1c.5 to 64
assign_interrupt_mode Found MSI capability
Allocate Port Service[0000:00:1c.5:pcie00]
Allocate Port Service[0000:00:1c.5:pcie02]
Allocate Port Service[0000:00:1c.5:pcie03]
ACPI: SSDT 7FF8E0D0, 01D2 (r1    AMI   CPU1PM        1 INTL 20060113)
ACPI: ACPI0007:00 is registered as cooling_device0
ACPI: SSDT 7FF8E2B0, 0143 (r1    AMI   CPU2PM        1 INTL 20060113)
ACPI: ACPI0007:01 is registered as cooling_device1
isapnp: Scanning for PnP cards...
Switched to high resolution mode on CPU 1
Switched to high resolution mode on CPU 0
isapnp: No Plug & Play device found
hpet_resources: 0xfed00000 is busy
Non-volatile memory driver v1.2
Hangcheck: starting hangcheck timer 0.9.0 (tick is 180 seconds, margin 
is 60 seconds).
Hangcheck: Using get_cycles().
Serial: 8250/16550 driver $Revision: 1.90 $ 4 ports, IRQ sharing enabled
serial8250: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
00:09: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
brd: module loaded
loop: module loaded
ACPI: PCI Interrupt 0000:02:00.0[A] -> GSI 17 (level, low) -> IRQ 17
PCI: Setting latency timer of device 0000:02:00.0 to 64
atl1 0000:02:00.0: version 2.1.3
Linux video capture interface: v2.00
Uniform Multi-Platform E-IDE driver
ide: Assuming 33MHz system bus speed for PIO modes; override with idebus=xx
JMB: IDE controller (0x197b:0x2363 rev 0x03) at  PCI slot 0000:03:00.1
ACPI: PCI Interrupt 0000:03:00.1[B] -> GSI 17 (level, low) -> IRQ 17
JMB: 100% native mode on irq 17
     ide0: BM-DMA at 0xd400-0xd407
     ide1: BM-DMA at 0xd408-0xd40f
Probing IDE interface ide0...
hda: ST3320620A, ATA DISK drive
hda: host max PIO5 wanted PIO255(auto-tune) selected PIO4
hda: UDMA/100 mode selected
Probing IDE interface ide1...
ide0 at 0xdc00-0xdc07,0xd882 on irq 17
ide1 at 0xd800-0xd807,0xd482 on irq 17
ide_generic: please use "probe_mask=0x3f" module parameter for probing 
all legacy ISA IDE ports
hda: max request size: 512KiB
hda: 625142448 sectors (320072 MB) w/16384KiB Cache, CHS=38913/255/63
hda: cache flushes supported
  hda: hda1
Driver 'sd' needs updating - please use bus_type methods
Driver 'sr' needs updating - please use bus_type methods
ahci 0000:03:00.0: version 3.0
ACPI: PCI Interrupt 0000:03:00.0[A] -> GSI 16 (level, low) -> IRQ 16
ahci 0000:03:00.0: AHCI 0001.0000 32 slots 2 ports 3 Gbps 0x3 impl SATA mode
ahci 0000:03:00.0: flags: 64bit ncq pm led clo pmp pio slum part
PCI: Setting latency timer of device 0000:03:00.0 to 64
scsi0 : ahci
scsi1 : ahci
ata1: SATA max UDMA/133 abar m8192@0xfeafe000 port 0xfeafe100 irq 16
ata2: SATA max UDMA/133 abar m8192@0xfeafe000 port 0xfeafe180 irq 16
ata1: SATA link down (SStatus 0 SControl 300)
ata2: SATA link down (SStatus 0 SControl 300)
ata_piix 0000:00:1f.2: version 2.12
ACPI: PCI Interrupt 0000:00:1f.2[B] -> GSI 22 (level, low) -> IRQ 22
ata_piix 0000:00:1f.2: MAP [ P0 -- P1 -- ]
PCI: Setting latency timer of device 0000:00:1f.2 to 64
scsi2 : ata_piix
scsi3 : ata_piix
ata3: SATA max UDMA/133 cmd 0xb000 ctl 0xac00 bmdma 0xa480 irq 22
ata4: SATA max UDMA/133 cmd 0xa880 ctl 0xa800 bmdma 0xa488 irq 22
ata3: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
ata3.00: ATA-8: WDC WD5000AAKS-07YGA0, 12.01C02, max UDMA/133
ata3.00: 976773168 sectors, multi 16: LBA48 NCQ (depth 0/32)
ata3.00: configured for UDMA/133
ata4: SATA link down (SStatus 0 SControl 300)
scsi 2:0:0:0: Direct-Access     ATA      WDC WD5000AAKS-0 12.0 PQ: 0 ANSI: 5
sd 2:0:0:0: [sda] 976773168 512-byte hardware sectors (500108 MB)
sd 2:0:0:0: [sda] Write Protect is off
sd 2:0:0:0: [sda] Mode Sense: 00 3a 00 00
sd 2:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't 
support DPO or FUA
sd 2:0:0:0: [sda] 976773168 512-byte hardware sectors (500108 MB)
sd 2:0:0:0: [sda] Write Protect is off
sd 2:0:0:0: [sda] Mode Sense: 00 3a 00 00
sd 2:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't 
support DPO or FUA
  sda: sda1 sda2 sda3 sda4
sd 2:0:0:0: [sda] Attached SCSI disk
sd 2:0:0:0: Attached scsi generic sg0 type 0
ACPI: PCI Interrupt 0000:00:1f.5[B] -> GSI 22 (level, low) -> IRQ 22
ata_piix 0000:00:1f.5: MAP [ P0 -- P1 -- ]
PCI: Setting latency timer of device 0000:00:1f.5 to 64
scsi4 : ata_piix
scsi5 : ata_piix
ata5: SATA max UDMA/133 cmd 0xc000 ctl 0xbc00 bmdma 0xb480 irq 22
ata6: SATA max UDMA/133 cmd 0xb880 ctl 0xb800 bmdma 0xb488 irq 22
ata5: SATA link up 1.5 Gbps (SStatus 113 SControl 300)
ata5.00: ATA-7: Maxtor 6L300S0, BANC1G10, max UDMA/133
ata5.00: 586114704 sectors, multi 0: LBA48 NCQ (not used)
ata5.00: configured for UDMA/133
ata6: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
ata6.00: ATA-7: ST3500630AS, 3.AAE, max UDMA/133
ata6.00: 976773168 sectors, multi 16: LBA48 NCQ (depth 0/32)
ata6.00: configured for UDMA/133
scsi 4:0:0:0: Direct-Access     ATA      Maxtor 6L300S0   BANC PQ: 0 ANSI: 5
sd 4:0:0:0: [sdb] 586114704 512-byte hardware sectors (300091 MB)
sd 4:0:0:0: [sdb] Write Protect is off
sd 4:0:0:0: [sdb] Mode Sense: 00 3a 00 00
sd 4:0:0:0: [sdb] Write cache: enabled, read cache: enabled, doesn't 
support DPO or FUA
sd 4:0:0:0: [sdb] 586114704 512-byte hardware sectors (300091 MB)
sd 4:0:0:0: [sdb] Write Protect is off
sd 4:0:0:0: [sdb] Mode Sense: 00 3a 00 00
sd 4:0:0:0: [sdb] Write cache: enabled, read cache: enabled, doesn't 
support DPO or FUA
  sdb: sdb1
sd 4:0:0:0: [sdb] Attached SCSI disk
sd 4:0:0:0: Attached scsi generic sg1 type 0
scsi 5:0:0:0: Direct-Access     ATA      ST3500630AS      3.AA PQ: 0 ANSI: 5
sd 5:0:0:0: [sdc] 976773168 512-byte hardware sectors (500108 MB)
sd 5:0:0:0: [sdc] Write Protect is off
sd 5:0:0:0: [sdc] Mode Sense: 00 3a 00 00
sd 5:0:0:0: [sdc] Write cache: enabled, read cache: enabled, doesn't 
support DPO or FUA
sd 5:0:0:0: [sdc] 976773168 512-byte hardware sectors (500108 MB)
sd 5:0:0:0: [sdc] Write Protect is off
sd 5:0:0:0: [sdc] Mode Sense: 00 3a 00 00
sd 5:0:0:0: [sdc] Write cache: enabled, read cache: enabled, doesn't 
support DPO or FUA
  sdc: sdc1
sd 5:0:0:0: [sdc] Attached SCSI disk
sd 5:0:0:0: Attached scsi generic sg2 type 0
ACPI: PCI Interrupt 0000:00:1a.7[C] -> GSI 18 (level, low) -> IRQ 18
PCI: Setting latency timer of device 0000:00:1a.7 to 64
ehci_hcd 0000:00:1a.7: EHCI Host Controller
ehci_hcd 0000:00:1a.7: new USB bus registered, assigned bus number 1
ehci_hcd 0000:00:1a.7: debug port 1
PCI: cache line size of 32 is not supported by device 0000:00:1a.7
ehci_hcd 0000:00:1a.7: irq 18, io mem 0xfbfffc00
ehci_hcd 0000:00:1a.7: USB 2.0 started, EHCI 1.00, driver 10 Dec 2004
usb usb1: configuration #1 chosen from 1 choice
hub 1-0:1.0: USB hub found
hub 1-0:1.0: 6 ports detected
usb usb1: New USB device found, idVendor=1d6b, idProduct=0002
usb usb1: New USB device strings: Mfr=3, Product=2, SerialNumber=1
usb usb1: Product: EHCI Host Controller
usb usb1: Manufacturer: Linux 2.6.26 ehci_hcd
usb usb1: SerialNumber: 0000:00:1a.7
ACPI: PCI Interrupt 0000:00:1d.7[A] -> GSI 23 (level, low) -> IRQ 23
PCI: Setting latency timer of device 0000:00:1d.7 to 64
ehci_hcd 0000:00:1d.7: EHCI Host Controller
ehci_hcd 0000:00:1d.7: new USB bus registered, assigned bus number 2
ehci_hcd 0000:00:1d.7: debug port 1
PCI: cache line size of 32 is not supported by device 0000:00:1d.7
ehci_hcd 0000:00:1d.7: irq 23, io mem 0xfbfff800
ehci_hcd 0000:00:1d.7: USB 2.0 started, EHCI 1.00, driver 10 Dec 2004
usb usb2: configuration #1 chosen from 1 choice
hub 2-0:1.0: USB hub found
hub 2-0:1.0: 6 ports detected
usb usb2: New USB device found, idVendor=1d6b, idProduct=0002
usb usb2: New USB device strings: Mfr=3, Product=2, SerialNumber=1
usb usb2: Product: EHCI Host Controller
usb usb2: Manufacturer: Linux 2.6.26 ehci_hcd
usb usb2: SerialNumber: 0000:00:1d.7
ohci_hcd: 2006 August 04 USB 1.1 'Open' Host Controller (OHCI) Driver
USB Universal Host Controller Interface driver v3.0
ACPI: PCI Interrupt 0000:00:1a.0[A] -> GSI 16 (level, low) -> IRQ 16
PCI: Setting latency timer of device 0000:00:1a.0 to 64
uhci_hcd 0000:00:1a.0: UHCI Host Controller
uhci_hcd 0000:00:1a.0: new USB bus registered, assigned bus number 3
uhci_hcd 0000:00:1a.0: irq 16, io base 0x0000c800
usb usb3: configuration #1 chosen from 1 choice
hub 3-0:1.0: USB hub found
hub 3-0:1.0: 2 ports detected
usb usb3: New USB device found, idVendor=1d6b, idProduct=0001
usb usb3: New USB device strings: Mfr=3, Product=2, SerialNumber=1
usb usb3: Product: UHCI Host Controller
usb usb3: Manufacturer: Linux 2.6.26 uhci_hcd
usb usb3: SerialNumber: 0000:00:1a.0
ACPI: PCI Interrupt 0000:00:1a.1[B] -> GSI 21 (level, low) -> IRQ 21
PCI: Setting latency timer of device 0000:00:1a.1 to 64
uhci_hcd 0000:00:1a.1: UHCI Host Controller
uhci_hcd 0000:00:1a.1: new USB bus registered, assigned bus number 4
uhci_hcd 0000:00:1a.1: irq 21, io base 0x0000c880
usb usb4: configuration #1 chosen from 1 choice
hub 4-0:1.0: USB hub found
hub 4-0:1.0: 2 ports detected
usb usb4: New USB device found, idVendor=1d6b, idProduct=0001
usb usb4: New USB device strings: Mfr=3, Product=2, SerialNumber=1
usb usb4: Product: UHCI Host Controller
usb usb4: Manufacturer: Linux 2.6.26 uhci_hcd
usb usb4: SerialNumber: 0000:00:1a.1
ACPI: PCI Interrupt 0000:00:1a.2[C] -> GSI 18 (level, low) -> IRQ 18
PCI: Setting latency timer of device 0000:00:1a.2 to 64
uhci_hcd 0000:00:1a.2: UHCI Host Controller
uhci_hcd 0000:00:1a.2: new USB bus registered, assigned bus number 5
uhci_hcd 0000:00:1a.2: irq 18, io base 0x0000cc00
usb usb5: configuration #1 chosen from 1 choice
hub 5-0:1.0: USB hub found
hub 5-0:1.0: 2 ports detected
usb usb5: New USB device found, idVendor=1d6b, idProduct=0001
usb usb5: New USB device strings: Mfr=3, Product=2, SerialNumber=1
usb usb5: Product: UHCI Host Controller
usb usb5: Manufacturer: Linux 2.6.26 uhci_hcd
usb usb5: SerialNumber: 0000:00:1a.2
ACPI: PCI Interrupt 0000:00:1d.0[A] -> GSI 23 (level, low) -> IRQ 23
PCI: Setting latency timer of device 0000:00:1d.0 to 64
uhci_hcd 0000:00:1d.0: UHCI Host Controller
uhci_hcd 0000:00:1d.0: new USB bus registered, assigned bus number 6
uhci_hcd 0000:00:1d.0: irq 23, io base 0x0000c080
usb usb6: configuration #1 chosen from 1 choice
hub 6-0:1.0: USB hub found
hub 6-0:1.0: 2 ports detected
usb usb6: New USB device found, idVendor=1d6b, idProduct=0001
usb usb6: New USB device strings: Mfr=3, Product=2, SerialNumber=1
usb usb6: Product: UHCI Host Controller
usb usb6: Manufacturer: Linux 2.6.26 uhci_hcd
usb usb6: SerialNumber: 0000:00:1d.0
ACPI: PCI Interrupt 0000:00:1d.1[B] -> GSI 19 (level, low) -> IRQ 19
PCI: Setting latency timer of device 0000:00:1d.1 to 64
uhci_hcd 0000:00:1d.1: UHCI Host Controller
uhci_hcd 0000:00:1d.1: new USB bus registered, assigned bus number 7
uhci_hcd 0000:00:1d.1: irq 19, io base 0x0000c400
usb usb7: configuration #1 chosen from 1 choice
hub 7-0:1.0: USB hub found
hub 7-0:1.0: 2 ports detected
usb usb7: New USB device found, idVendor=1d6b, idProduct=0001
usb usb7: New USB device strings: Mfr=3, Product=2, SerialNumber=1
usb usb7: Product: UHCI Host Controller
usb usb7: Manufacturer: Linux 2.6.26 uhci_hcd
usb usb7: SerialNumber: 0000:00:1d.1
ACPI: PCI Interrupt 0000:00:1d.2[C] -> GSI 18 (level, low) -> IRQ 18
PCI: Setting latency timer of device 0000:00:1d.2 to 64
uhci_hcd 0000:00:1d.2: UHCI Host Controller
uhci_hcd 0000:00:1d.2: new USB bus registered, assigned bus number 8
uhci_hcd 0000:00:1d.2: irq 18, io base 0x0000c480
usb usb8: configuration #1 chosen from 1 choice
hub 8-0:1.0: USB hub found
hub 8-0:1.0: 2 ports detected
usb usb8: New USB device found, idVendor=1d6b, idProduct=0001
usb usb8: New USB device strings: Mfr=3, Product=2, SerialNumber=1
usb usb8: Product: UHCI Host Controller
usb usb8: Manufacturer: Linux 2.6.26 uhci_hcd
usb usb8: SerialNumber: 0000:00:1d.2
Initializing USB Mass Storage driver...
usb 8-1: new low speed USB device using uhci_hcd and address 2
usb 8-1: configuration #1 chosen from 2 choices
usb 8-1: New USB device found, idVendor=6666, idProduct=f100
usb 8-1: New USB device strings: Mfr=1, Product=2, SerialNumber=0
usb 8-1: Product: Sky/Sky+ Digibox Controller
usb 8-1: Manufacturer: Joseph Heenan
usb 8-2: new low speed USB device using uhci_hcd and address 3
usb 8-2: configuration #1 chosen from 1 choice
usb 8-2: New USB device found, idVendor=051d, idProduct=0002
usb 8-2: New USB device strings: Mfr=3, Product=1, SerialNumber=2
usb 8-2: Product: Smart-UPS 1500 FW:653.13.I USB FW:7.3
usb 8-2: Manufacturer: American Power Conversion
usb 8-2: SerialNumber: AS0652111186
usbcore: registered new interface driver usb-storage
USB Mass Storage support registered.
PNP: PS/2 Controller [PNP0303:PS2K] at 0x60,0x64 irq 1
PNP: PS/2 appears to have AUX port disabled, if this is incorrect please 
boot with i8042.nopnp
serio: i8042 KBD port at 0x60,0x64 irq 1
mice: PS/2 mouse device common for all mice
input: PC Speaker as /class/input/input0
input: AT Translated Set 2 keyboard as /class/input/input1
I2O subsystem v1.325
i2o: max drivers = 8
I2O Bus Adapter OSM v1.317
I2O Block Device OSM v1.325
I2O SCSI Peripheral OSM v1.316
I2O ProcFS OSM v1.316
rtc_cmos 00:03: rtc core: registered rtc_cmos as rtc0
rtc0: alarms up to one month, y3k
i2c /dev entries driver
ACPI: PCI Interrupt 0000:00:1f.3[C] -> GSI 18 (level, low) -> IRQ 18
GRE over IPv4 tunneling driver
TCP bic registered
TCP cubic registered
TCP westwood registered
TCP highspeed registered
TCP hybla registered
TCP htcp registered
TCP vegas registered
TCP veno registered
TCP scalable registered
TCP lp registered
TCP yeah registered
TCP illinois registered
NET: Registered protocol family 10
lo: Disabled Privacy Extensions
IPv6 over IPv4 tunneling driver
sit0: Disabled Privacy Extensions
ip6tnl0: Disabled Privacy Extensions
NET: Registered protocol family 17
NET: Registered protocol family 15
Bridge firewalling registered
RPC: Registered udp transport module.
RPC: Registered tcp transport module.
802.1Q VLAN Support v1.8 Ben Greear <greearb@candelatech.com>
All bugs added by David S. Miller <davem@redhat.com>
Using IPI No-Shortcut mode
rtc_cmos 00:03: setting system clock to 2008-07-15 16:44:57 UTC (1216140297)
BIOS EDD facility v0.16 2004-Jun-25, 6 devices found
VFS: Mounted root (ext2 filesystem) readonly.
Freeing unused kernel memory: 276k freed
Linux agpgart interface v0.103
bttv: driver version 0.9.17 loaded
bttv: using 8 buffers with 2080k (520 pages) each for capture
bttv: Bt8xx card found (0).
ACPI: PCI Interrupt 0000:05:01.0[A] -> GSI 17 (level, low) -> IRQ 17
bttv0: Bt878 (rev 2) at 0000:05:01.0, irq: 17, latency: 64, mmio: 0xfaffe000
bttv0: using:  *** UNKNOWN/GENERIC ***  [card=0,autodetected]
bttv0: gpio: en=00000000, out=00000000 in=00ebff80 [init]
tveeprom 1-0050: Huh, no eeprom present (err=-121)?
bttv0: tuner type unset
bttv0: i2c: checking for MSP34xx @ 0x80... not found
bttv0: i2c: checking for TDA9875 @ 0xb0... not found
bttv0: i2c: checking for TDA7432 @ 0x8a... not found
bttv0: registered device video0
bttv0: registered device vbi0
usbcore: registered new interface driver hiddev
hiddev96hidraw0: USB HID v1.00 Device [Joseph Heenan Sky/Sky+ Digibox 
Controller] on usb-0000:00:1d.2-1
hiddev97hidraw1: USB HID v1.10 Device [American Power Conversion 
Smart-UPS 1500 FW:653.13.I USB FW:7.3] on usb-0000:00:1d.2-2
usbcore: registered new interface driver usbhid
usbhid: v2.6:USB HID core driver
Adding 3911816k swap on /dev/sda2.  Priority:-1 extents:1 across:3911816k
w83627ehf: Found W83627DHG chip at 0x290
w83627ehf w83627ehf.656: VID pins in output mode, CPU VID not available
coretemp coretemp.0: Using relative temperature scale!
coretemp coretemp.1: Using relative temperature scale!
XFS mounting filesystem sda4
Ending clean XFS mount for filesystem: sda4
kjournald starting.  Commit interval 5 seconds
EXT3-fs warning: checktime reached, running e2fsck is recommended
EXT3 FS on sdb1, internal journal
EXT3-fs: mounted filesystem with ordered data mode.
kjournald starting.  Commit interval 5 seconds
EXT3-fs warning: checktime reached, running e2fsck is recommended
EXT3 FS on sdc1, internal journal
EXT3-fs: mounted filesystem with ordered data mode.
kjournald starting.  Commit interval 5 seconds
EXT3-fs warning: maximal mount count reached, running e2fsck is recommended
EXT3 FS on hda1, internal journal
EXT3-fs: mounted filesystem with ordered data mode.
atl1 0000:02:00.0: eth0 link is up 1000 Mbps full duplex
warning: `named' uses 32-bit capabilities (legacy support in use)
eth0: no IPv6 routers present
bttv0: unloading
bttv: driver version 0.9.17 loaded
bttv: using 8 buffers with 2080k (520 pages) each for capture
bttv: Bt8xx card found (0).
bttv0: Bt878 (rev 2) at 0000:05:01.0, irq: 17, latency: 64, mmio: 0xfaffe000
bttv0: using:  *** UNKNOWN/GENERIC ***  [card=0,autodetected]
bttv0: gpio: en=00000000, out=00000000 in=00ebff80 [init]
tveeprom 1-0050: Huh, no eeprom present (err=-121)?
bttv0: tuner type=10
bttv0: i2c: checking for MSP34xx @ 0x80... not found
bttv0: i2c: checking for TDA9875 @ 0xb0... not found
bttv0: i2c: checking for TDA7432 @ 0x8a... not found
All bytes are equal. It is not a TEA5767
tuner' 1-0060: chip found @ 0xc0 (bt878 #0 [sw])
tuner-simple 1-0060: creating new instance
tuner-simple 1-0060: type set to 10 (Alps TSBE1)
bttv0: registered device video0
bttv0: registered device vbi0
bttv0: PLL: 28636363 => 35468950 .. ok

ian@moschops $

