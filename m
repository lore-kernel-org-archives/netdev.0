From: Alan Stern <stern@rowland.harvard.edu>
Subject: e100 problem in 2.6.32
Date: Mon, 14 Dec 2009 15:42:37 -0500 (EST)
Message-ID: <Pine.LNX.4.44L0.0912141538200.2690-100000@iolanthe.rowland.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Network list <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from iolanthe.rowland.org ([192.131.102.54]:39701 "HELO
	iolanthe.rowland.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1752880AbZLNUmk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Dec 2009 15:42:40 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Below is a dmesg log showing a system bootup, followed by a bunch of
errors starting at timestamp 97.579794 when I did "rmmod e100".  (The
interface was up at the time.)

Is this new?  Is there a fix?

Alan Stern


[    0.000000] Linux version 2.6.32 (stern@iolanthe.rowland.org) (gcc v=
ersion 4.3.2 20081105 (Red Hat 4.3.2-7) (GCC) ) #1 SMP PREEMPT Mon Dec =
7 11:53:37 EST 2009
[    0.000000] KERNEL supported cpus:
[    0.000000]   Intel GenuineIntel
[    0.000000]   AMD AuthenticAMD
[    0.000000]   NSC Geode by NSC
[    0.000000]   Cyrix CyrixInstead
[    0.000000]   Centaur CentaurHauls
[    0.000000]   Transmeta GenuineTMx86
[    0.000000]   Transmeta TransmetaCPU
[    0.000000]   UMC UMC UMC UMC
[    0.000000] BIOS-provided physical RAM map:
[    0.000000]  BIOS-e820: 0000000000000000 - 000000000009fc00 (usable)
[    0.000000]  BIOS-e820: 000000000009fc00 - 00000000000a0000 (reserve=
d)
[    0.000000]  BIOS-e820: 00000000000e0000 - 0000000000100000 (reserve=
d)
[    0.000000]  BIOS-e820: 0000000000100000 - 000000002fe40000 (usable)
[    0.000000]  BIOS-e820: 000000002fe40000 - 000000002fe50000 (ACPI da=
ta)
[    0.000000]  BIOS-e820: 000000002fe50000 - 000000002ff00000 (ACPI NV=
S)
[    0.000000] DMI 2.3 present.
[    0.000000] last_pfn =3D 0x2fe40 max_arch_pfn =3D 0x100000
[    0.000000] MTRR default type: uncachable
[    0.000000] MTRR fixed ranges enabled:
[    0.000000]   00000-9FFFF write-back
[    0.000000]   A0000-DFFFF uncachable
[    0.000000]   E0000-FFFFF write-back
[    0.000000] MTRR variable ranges enabled:
[    0.000000]   0 base 000000000 mask FE0000000 write-back
[    0.000000]   1 base 020000000 mask FF0000000 write-back
[    0.000000]   2 base 02FF00000 mask FFFF00000 uncachable
[    0.000000]   3 disabled
[    0.000000]   4 disabled
[    0.000000]   5 disabled
[    0.000000]   6 disabled
[    0.000000]   7 disabled
[    0.000000] initial memory mapped : 0 - 01c00000
[    0.000000] init_memory_mapping: 0000000000000000-000000002fe40000
[    0.000000]  0000000000 - 0000400000 page 4k
[    0.000000]  0000400000 - 002fc00000 page 2M
[    0.000000]  002fc00000 - 002fe40000 page 4k
[    0.000000] kernel direct mapping tables up to 2fe40000 @ 7000-c000
[    0.000000] RAMDISK: 2fb31000 - 2fe2fafc
[    0.000000] ACPI: RSDP 000f7300 00014 (v00 ACPIAM)
[    0.000000] ACPI: RSDT 2fe40000 00030 (v01 INTEL  D845GBV2 20030714 =
MSFT 00000097)
[    0.000000] ACPI: FACP 2fe40200 00081 (v02 INTEL  D845GBV2 20030714 =
MSFT 00000097)
[    0.000000] ACPI: DSDT 2fe40370 03FD7 (v01 INTEL  D845GBV2 0000010A =
MSFT 0100000D)
[    0.000000] ACPI: FACS 2fe50000 00040
[    0.000000] ACPI: APIC 2fe40300 00068 (v01 INTEL  D845GBV2 20030714 =
MSFT 00000097)
[    0.000000] ACPI: ASF! 2fe44350 00084 (v16 AMIASF I845GASF 00000001 =
MSFT 0100000D)
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] 766MB LOWMEM available.
[    0.000000]   mapped low ram: 0 - 2fe40000
[    0.000000]   low ram: 0 - 2fe40000
[    0.000000]   node 0 low ram: 00000000 - 2fe40000
[    0.000000]   node 0 bootmap 00008000 - 0000dfc8
[    0.000000] (9 early reservations) =3D=3D> bootmem [0000000000 - 002=
fe40000]
[    0.000000]   #0 [0000000000 - 0000001000]   BIOS data page =3D=3D> =
[0000000000 - 0000001000]
[    0.000000]   #1 [0000001000 - 0000002000]    EX TRAMPOLINE =3D=3D> =
[0000001000 - 0000002000]
[    0.000000]   #2 [0000006000 - 0000007000]       TRAMPOLINE =3D=3D> =
[0000006000 - 0000007000]
[    0.000000]   #3 [0001000000 - 000187119c]    TEXT DATA BSS =3D=3D> =
[0001000000 - 000187119c]
[    0.000000]   #4 [002fb31000 - 002fe2fafc]          RAMDISK =3D=3D> =
[002fb31000 - 002fe2fafc]
[    0.000000]   #5 [000009fc00 - 0000100000]    BIOS reserved =3D=3D> =
[000009fc00 - 0000100000]
[    0.000000]   #6 [0001872000 - 0001879178]              BRK =3D=3D> =
[0001872000 - 0001879178]
[    0.000000]   #7 [0000007000 - 0000008000]          PGTABLE =3D=3D> =
[0000007000 - 0000008000]
[    0.000000]   #8 [0000008000 - 000000e000]          BOOTMAP =3D=3D> =
[0000008000 - 000000e000]
[    0.000000] found SMP MP-table at [c00ff780] ff780
[    0.000000] Zone PFN ranges:
[    0.000000]   DMA      0x00000000 -> 0x00001000
[    0.000000]   Normal   0x00001000 -> 0x0002fe40
[    0.000000] Movable zone start PFN for each node
[    0.000000] early_node_map[2] active PFN ranges
[    0.000000]     0: 0x00000000 -> 0x0000009f
[    0.000000]     0: 0x00000100 -> 0x0002fe40
[    0.000000] On node 0 totalpages: 196063
[    0.000000] free_area_init_node: node 0, pgdat c12ef820, node_mem_ma=
p c187a000
[    0.000000]   DMA zone: 52 pages used for memmap
[    0.000000]   DMA zone: 0 pages reserved
[    0.000000]   DMA zone: 3947 pages, LIFO batch:0
[    0.000000]   Normal zone: 2439 pages used for memmap
[    0.000000]   Normal zone: 189625 pages, LIFO batch:31
[    0.000000] Using APIC driver default
[    0.000000] ACPI: PM-Timer IO Port: 0x408
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] ACPI: LAPIC (acpi_id[0x01] lapic_id[0x00] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x02] lapic_id[0x81] disabled)
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x01] dfl dfl lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x02] dfl dfl lint[0x1])
[    0.000000] ACPI: IOAPIC (id[0x01] address[0xfec00000] gsi_base[0])
[    0.000000] IOAPIC[0]: apic_id 1, version 32, address 0xfec00000, GS=
I 0-23
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high lev=
el)
[    0.000000] ACPI: IRQ0 used by override.
[    0.000000] ACPI: IRQ2 used by override.
[    0.000000] ACPI: IRQ9 used by override.
[    0.000000] Enabling APIC mode:  Flat.  Using 1 I/O APICs
[    0.000000] Using ACPI (MADT) for SMP configuration information
[    0.000000] SMP: Allowing 2 CPUs, 1 hotplug CPUs
[    0.000000] nr_irqs_gsi: 24
[    0.000000] PM: Registered nosave memory: 000000000009f000 - 0000000=
0000a0000
[    0.000000] PM: Registered nosave memory: 00000000000a0000 - 0000000=
0000e0000
[    0.000000] PM: Registered nosave memory: 00000000000e0000 - 0000000=
000100000
[    0.000000] Allocating PCI resources starting at 2ff00000 (gap: 2ff0=
0000:d0100000)
[    0.000000] NR_CPUS:8 nr_cpumask_bits:8 nr_cpu_ids:2 nr_node_ids:1
[    0.000000] PERCPU: Embedded 13 pages/cpu @c2400000 s30936 r0 d22312=
 u2097152
[    0.000000] pcpu-alloc: s30936 r0 d22312 u2097152 alloc=3D1*4194304
[    0.000000] pcpu-alloc: [0] 0 1=20
[    0.000000] Built 1 zonelists in Zone order, mobility grouping on.  =
Total pages: 193572
[    0.000000] Kernel command line: ro root=3DUUID=3D38b19631-670b-4ec8=
-be1a-a65458d523ae resume=3D/dev/hda7 no_console_suspend
[    0.000000] PID hash table entries: 4096 (order: 2, 16384 bytes)
[    0.000000] Dentry cache hash table entries: 131072 (order: 7, 52428=
8 bytes)
[    0.000000] Inode-cache hash table entries: 65536 (order: 6, 262144 =
bytes)
[    0.000000] Enabling fast FPU save and restore... done.
[    0.000000] Enabling unmasked SIMD FPU exception support... done.
[    0.000000] Initializing CPU#0
[    0.000000] Memory: 761180k/784640k available (1848k kernel code, 22=
700k reserved, 1171k data, 284k init, 0k highmem)
[    0.000000] virtual kernel memory layout:
[    0.000000]     fixmap  : 0xfff1f000 - 0xfffff000   ( 896 kB)
[    0.000000]     vmalloc : 0xf0640000 - 0xfff1d000   ( 248 MB)
[    0.000000]     lowmem  : 0xc0000000 - 0xefe40000   ( 766 MB)
[    0.000000]       .init : 0xc12f4000 - 0xc133b000   ( 284 kB)
[    0.000000]       .data : 0xc11ce2b2 - 0xc12f3208   (1171 kB)
[    0.000000]       .text : 0xc1000000 - 0xc11ce2b2   (1848 kB)
[    0.000000] Checking if this processor honours the WP bit even in su=
pervisor mode...Ok.
[    0.000000] SLUB: Genslabs=3D13, HWalign=3D128, Order=3D0-3, MinObje=
cts=3D0, CPUs=3D2, Nodes=3D1
[    0.000000] Hierarchical RCU implementation.
[    0.000000] NR_IRQS:512
[    0.000000] CPU 0 irqstacks, hard=3Dc2400000 soft=3Dc2401000
[    0.000000] Console: colour VGA+ 80x25
[    0.000000] console [tty0] enabled
[    0.000000] Lock dependency validator: Copyright (c) 2006 Red Hat, I=
nc., Ingo Molnar
[    0.000000] ... MAX_LOCKDEP_SUBCLASSES:  8
[    0.000000] ... MAX_LOCK_DEPTH:          48
[    0.000000] ... MAX_LOCKDEP_KEYS:        8191
[    0.000000] ... CLASSHASH_SIZE:          4096
[    0.000000] ... MAX_LOCKDEP_ENTRIES:     16384
[    0.000000] ... MAX_LOCKDEP_CHAINS:      32768
[    0.000000] ... CHAINHASH_SIZE:          16384
[    0.000000]  memory used by lock dependency info: 3567 kB
[    0.000000]  per task-struct memory footprint: 1152 bytes
[    0.000000] Fast TSC calibration using PIT
[    0.000000] Detected 1799.650 MHz processor.
[    0.004068] Calibrating delay loop (skipped), value calculated using=
 timer frequency.. 3599.30 BogoMIPS (lpj=3D7198600)
[    0.004563] Mount-cache hash table entries: 512
[    0.009204] CPU: Trace cache: 12K uops, L1 D cache: 8K
[    0.009335] CPU: L2 cache: 512K
[    0.009421] CPU: Hyper-Threading is disabled
[    0.009511] mce: CPU supports 4 MCE banks
[    0.009657] Checking 'hlt' instruction... OK.
[    0.024543] lockdep: fixing up alternatives.
[    0.024633] SMP alternatives: switching to UP code
[    0.029793] ACPI: Core revision 20090903
[    0.062942] ..TIMER: vector=3D0x30 apic1=3D0 pin1=3D2 apic2=3D-1 pin=
2=3D-1
[    0.102568] CPU0: Intel(R) Pentium(R) 4 CPU 1.80GHz stepping 07
[    0.104001] Brought up 1 CPUs
[    0.104001] Total of 1 processors activated (3599.30 BogoMIPS).
[    0.106100] NET: Registered protocol family 16
[    0.108765] ACPI: bus type pci registered
[    0.109760] PCI: PCI BIOS revision 2.10 entry at 0xf0031, last bus=3D=
1
[    0.109859] PCI: Using configuration type 1 for base access
[    0.124203] bio: create slab <bio-0> at 0
[    0.132424] ACPI: EC: Look up EC in DSDT
[    0.145848] ACPI: Executed 2 blocks of module-level executable AML c=
ode
[    0.180145] ACPI: Interpreter enabled
[    0.180247] ACPI: (supports S0 S1 S3 S4 S5)
[    0.180828] ACPI: Using IOAPIC for interrupt routing
[    0.235689] ACPI: Power Resource [URP1] (off)
[    0.236156] ACPI: Power Resource [FDDP] (off)
[    0.236425] ACPI: Power Resource [LPTP] (off)
[    0.237734] ACPI: PCI Root Bridge [PCI0] (0000:00)
[    0.238527] pci 0000:00:00.0: reg 10 32bit mmio pref: [0xf8000000-0x=
fbffffff]
[    0.238765] pci 0000:00:02.0: reg 10 32bit mmio pref: [0xf0000000-0x=
f7ffffff]
[    0.238782] pci 0000:00:02.0: reg 14 32bit mmio: [0xffa80000-0xffaff=
fff]
[    0.239043] pci 0000:00:1d.0: reg 20 io port: [0xe800-0xe81f]
[    0.239168] pci 0000:00:1d.1: reg 20 io port: [0xe880-0xe89f]
[    0.239293] pci 0000:00:1d.2: reg 20 io port: [0xec00-0xec1f]
[    0.239454] pci 0000:00:1d.7: reg 10 32bit mmio: [0xffa7fc00-0xffa7f=
fff]
[    0.239573] pci 0000:00:1d.7: PME# supported from D0 D3hot D3cold
[    0.239674] pci 0000:00:1d.7: PME# disabled
[    0.239879] * The chipset may have PM-Timer Bug. Due to workarounds =
for a bug,
[    0.239882] * this clock source is slow. If you are sure your timer =
does not have
[    0.239884] * this bug, please use "acpi_pm_good" to disable the wor=
karound
[    0.240227] pci 0000:00:1f.0: quirk: region 0400-047f claimed by ICH=
4 ACPI/GPIO/TCO
[    0.240369] pci 0000:00:1f.0: quirk: region 0480-04bf claimed by ICH=
4 GPIO
[    0.240548] pci 0000:00:1f.1: reg 10 io port: [0x00-0x07]
[    0.240565] pci 0000:00:1f.1: reg 14 io port: [0x00-0x03]
[    0.240580] pci 0000:00:1f.1: reg 18 io port: [0x00-0x07]
[    0.240595] pci 0000:00:1f.1: reg 1c io port: [0x00-0x03]
[    0.240611] pci 0000:00:1f.1: reg 20 io port: [0xffa0-0xffaf]
[    0.240626] pci 0000:00:1f.1: reg 24 32bit mmio: [0x000000-0x0003ff]
[    0.240748] pci 0000:00:1f.3: reg 20 io port: [0xe000-0xe01f]
[    0.240856] pci 0000:00:1f.5: reg 10 io port: [0xe400-0xe4ff]
[    0.240871] pci 0000:00:1f.5: reg 14 io port: [0xe080-0xe0bf]
[    0.240887] pci 0000:00:1f.5: reg 18 32bit mmio: [0xffa7f800-0xffa7f=
9ff]
[    0.240902] pci 0000:00:1f.5: reg 1c 32bit mmio: [0xffa7f400-0xffa7f=
4ff]
[    0.240971] pci 0000:00:1f.5: PME# supported from D0 D3hot D3cold
[    0.241069] pci 0000:00:1f.5: PME# disabled
[    0.241253] pci 0000:01:00.0: reg 10 32bit mmio: [0xff8fd000-0xff8fd=
fff]
[    0.241355] pci 0000:01:00.0: supports D1 D2
[    0.241360] pci 0000:01:00.0: PME# supported from D0 D1 D2 D3hot
[    0.241457] pci 0000:01:00.0: PME# disabled
[    0.241617] pci 0000:01:00.1: reg 10 32bit mmio: [0xff8fe000-0xff8fe=
fff]
[    0.241716] pci 0000:01:00.1: supports D1 D2
[    0.241721] pci 0000:01:00.1: PME# supported from D0 D1 D2 D3hot
[    0.241817] pci 0000:01:00.1: PME# disabled
[    0.241977] pci 0000:01:00.2: reg 10 32bit mmio: [0xff8ffc00-0xff8ff=
cff]
[    0.242076] pci 0000:01:00.2: supports D1 D2
[    0.242081] pci 0000:01:00.2: PME# supported from D0 D1 D2 D3hot
[    0.242179] pci 0000:01:00.2: PME# disabled
[    0.242393] pci 0000:01:01.0: reg 20 io port: [0xd880-0xd89f]
[    0.242565] pci 0000:01:01.1: reg 20 io port: [0xdc00-0xdc1f]
[    0.242699] pci 0000:01:01.2: reg 10 32bit mmio: [0xff8ff800-0xff8ff=
8ff]
[    0.242800] pci 0000:01:01.2: PME# supported from D0 D3hot
[    0.242896] pci 0000:01:01.2: PME# disabled
[    0.243049] pci 0000:01:02.0: reg 10 32bit mmio: [0xff8e0000-0xff8ef=
fff]
[    0.243065] pci 0000:01:02.0: reg 14 32bit mmio pref: [0xe6af0000-0x=
e6afffff]
[    0.243081] pci 0000:01:02.0: reg 18 32bit mmio: [0xff8d0000-0xff8df=
fff]
[    0.243219] pci 0000:01:08.0: reg 10 32bit mmio: [0xff8fc000-0xff8fc=
fff]
[    0.243237] pci 0000:01:08.0: reg 14 io port: [0xd800-0xd83f]
[    0.243326] pci 0000:01:08.0: supports D1 D2
[    0.243331] pci 0000:01:08.0: PME# supported from D0 D1 D2 D3hot D3c=
old
[    0.243428] pci 0000:01:08.0: PME# disabled
[    0.243594] pci 0000:00:1e.0: transparent bridge
[    0.243687] pci 0000:00:1e.0: bridge io port: [0xd000-0xdfff]
[    0.243698] pci 0000:00:1e.0: bridge 32bit mmio: [0xff800000-0xff8ff=
fff]
[    0.243709] pci 0000:00:1e.0: bridge 32bit mmio pref: [0xe6a00000-0x=
e6afffff]
[    0.243731] pci_bus 0000:00: on NUMA node 0
[    0.244028] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0._PRT]
[    0.245053] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.P0P1._PRT]
[    0.270213] ACPI: PCI Interrupt Link [LNKA] (IRQs 3 4 5 6 7 9 10 *11=
 12 14 15)
[    0.271538] ACPI: PCI Interrupt Link [LNKB] (IRQs *3 4 5 6 7 9 10 11=
 12 14 15)
[    0.273183] ACPI: PCI Interrupt Link [LNKC] (IRQs 3 4 5 6 7 *9 10 11=
 12 14 15)
[    0.274490] ACPI: PCI Interrupt Link [LNKD] (IRQs 3 4 *5 6 7 9 10 11=
 12 14 15)
[    0.275796] ACPI: PCI Interrupt Link [LNKE] (IRQs 3 4 5 6 7 9 10 *11=
 12 14 15)
[    0.277251] ACPI: PCI Interrupt Link [LNKF] (IRQs 3 4 5 6 7 9 10 *11=
 12 14 15)
[    0.278552] ACPI: PCI Interrupt Link [LNKG] (IRQs 3 4 5 6 7 9 10 *11=
 12 14 15)
[    0.279859] ACPI: PCI Interrupt Link [LNKH] (IRQs 3 4 5 6 7 9 *10 11=
 12 14 15)
[    0.282538] vgaarb: device added: PCI:0000:00:02.0,decodes=3Dio+mem,=
owns=3Dio+mem,locks=3Dnone
[    0.282799] vgaarb: loaded
[    0.283843] PCI: Using ACPI for IRQ routing
[    0.286108] Switching to clocksource tsc
[    0.289344] pnp: PnP ACPI init
[    0.289512] ACPI: bus type pnp registered
[    0.312242] pnp: PnP ACPI: found 14 devices
[    0.312341] ACPI: ACPI bus type pnp unregistered
[    0.312487] system 00:05: ioport range 0x4d0-0x4d1 has been reserved
[    0.312636] system 00:0c: ioport range 0x400-0x47f has been reserved
[    0.312734] system 00:0c: ioport range 0x680-0x6ff has been reserved
[    0.312831] system 00:0c: ioport range 0x480-0x4bf has been reserved
[    0.312937] system 00:0c: iomem range 0xfec00000-0xfec00fff could no=
t be reserved
[    0.313077] system 00:0c: iomem range 0xfee00000-0xfee00fff has been=
 reserved
[    0.313203] system 00:0d: iomem range 0x0-0x9ffff could not be reser=
ved
[    0.313306] system 00:0d: iomem range 0xc0000-0xdffff could not be r=
eserved
[    0.313409] system 00:0d: iomem range 0xe0000-0xfffff could not be r=
eserved
[    0.313513] system 00:0d: iomem range 0x100000-0x2fefffff could not =
be reserved
[    0.351612] pci 0000:00:1e.0: PCI bridge, secondary bus 0000:01
[    0.351715] pci 0000:00:1e.0:   IO window: 0xd000-0xdfff
[    0.352080] pci 0000:00:1e.0:   MEM window: 0xff800000-0xff8fffff
[    0.352179] pci 0000:00:1e.0:   PREFETCH window: 0xe6a00000-0xe6afff=
ff
[    0.352295] pci 0000:00:1e.0: setting latency timer to 64
[    0.352306] pci_bus 0000:00: resource 0 io:  [0x00-0xffff]
[    0.352313] pci_bus 0000:00: resource 1 mem: [0x000000-0xffffffff]
[    0.352319] pci_bus 0000:01: resource 0 io:  [0xd000-0xdfff]
[    0.352325] pci_bus 0000:01: resource 1 mem: [0xff800000-0xff8fffff]
[    0.352331] pci_bus 0000:01: resource 2 pref mem [0xe6a00000-0xe6aff=
fff]
[    0.352337] pci_bus 0000:01: resource 3 io:  [0x00-0xffff]
[    0.352343] pci_bus 0000:01: resource 4 mem: [0x000000-0xffffffff]
[    0.352507] NET: Registered protocol family 2
[    0.353138] IP route cache hash table entries: 32768 (order: 5, 1310=
72 bytes)
[    0.354863] TCP established hash table entries: 131072 (order: 8, 10=
48576 bytes)
[    0.356713] TCP bind hash table entries: 65536 (order: 9, 2097152 by=
tes)
[    0.368619] TCP: Hash tables configured (established 131072 bind 655=
36)
[    0.368830] TCP reno registered
[    0.369451] NET: Registered protocol family 1
[    0.369626] pci 0000:00:02.0: Boot video device
[    0.369647] pci 0000:00:1d.0: uhci_check_and_reset_hc: legsup =3D 0x=
0f30
[    0.369653] pci 0000:00:1d.0: Performing full reset
[    0.369684] pci 0000:00:1d.1: uhci_check_and_reset_hc: legsup =3D 0x=
0030
[    0.369689] pci 0000:00:1d.1: Performing full reset
[    0.369720] pci 0000:00:1d.2: uhci_check_and_reset_hc: legsup =3D 0x=
0030
[    0.369725] pci 0000:00:1d.2: Performing full reset
[    0.369786] pci 0000:00:1d.7: EHCI: BIOS handoff
[    1.968031] pci 0000:00:1d.7: EHCI: BIOS handoff failed (BIOS bug?) =
01010001
[    1.968376] pci 0000:01:01.0: uhci_check_and_reset_hc: legsup =3D 0x=
2000
[    1.968381] pci 0000:01:01.0: Performing full reset
[    1.968411] pci 0000:01:01.1: uhci_check_and_reset_hc: legsup =3D 0x=
2000
[    1.968416] pci 0000:01:01.1: Performing full reset
[    1.968491] pci 0000:01:08.0: Firmware left e100 interrupts enabled;=
 disabling
[    1.969523] Trying to unpack rootfs image as initramfs...
[    2.202526] Freeing initrd memory: 3066k freed
[    2.256578] msgmni has been set to 1493
[    2.260613] alg: No test for stdrng (krng)
[    2.260928] io scheduler noop registered
[    2.261016] io scheduler anticipatory registered
[    2.261104] io scheduler deadline registered
[    2.262015] io scheduler cfq registered (default)
[    2.301424] Real Time Clock Driver v1.12b
[    2.302214] Linux agpgart interface v0.103
[    2.302441] agpgart-intel 0000:00:00.0: Intel 830M Chipset
[    2.302741] agpgart-intel 0000:00:00.0: detected 892K stolen memory
[    2.306229] agpgart-intel 0000:00:00.0: AGP aperture is 128M @ 0xf00=
00000
[    2.307040] Serial: 8250/16550 driver, 4 ports, IRQ sharing disabled
[    2.307811] serial8250: ttyS0 at I/O 0x3f8 (irq =3D 4) is a 16550A
[    2.312450] 00:08: ttyS0 at I/O 0x3f8 (irq =3D 4) is a 16550A
[    2.328326] brd: module loaded
[    2.328421] Uniform Multi-Platform E-IDE driver
[    2.329238] piix 0000:00:1f.1: IDE controller (0x8086:0x24cb rev 0x0=
2)
[    2.329349] PIIX_IDE 0000:00:1f.1: enabling device (0005 -> 0007)
[    2.329470] PIIX_IDE 0000:00:1f.1: PCI INT A -> GSI 18 (level, low) =
-> IRQ 18
[    2.329800] piix 0000:00:1f.1: not 100% native mode: will probe irqs=
 later
[    2.329903]     ide0: BM-DMA at 0xffa0-0xffa7
[    2.330006]     ide1: BM-DMA at 0xffa8-0xffaf
[    2.330102] Probing IDE interface ide0...
[    2.616205] hda: ST380011A, ATA DISK drive
[    2.952032] hdb: Maxtor 6Y080P0, ATA DISK drive
[    2.952637] hda: host max PIO4 wanted PIO255(auto-tune) selected PIO=
4
[    2.952933] hda: UDMA/100 mode selected
[    2.953278] hdb: host max PIO4 wanted PIO255(auto-tune) selected PIO=
4
[    2.953387] hdb: UDMA/100 mode selected
[    2.953603] Probing IDE interface ide1...
[    3.688208] hdc: PLEXTOR DVDR PX-740A, ATAPI CD/DVD-ROM drive
[    4.360393] hdc: host max PIO4 wanted PIO255(auto-tune) selected PIO=
4
[    4.361037] hdc: UDMA/33 mode selected
[    4.361541] ide0 at 0x1f0-0x1f7,0x3f6 on irq 14
[    4.362183] ide1 at 0x170-0x177,0x376 on irq 15
[    4.364367] ide_generic: please use "probe_mask=3D0x3f" module param=
eter for probing all legacy ISA IDE ports
[    4.364514] ide-gd driver 1.18
[    4.364813] hda: max request size: 512KiB
[    4.376425] hda: 156301488 sectors (80026 MB) w/2048KiB Cache, CHS=3D=
16383/255/63
[    4.376813] hda: cache flushes supported
[    4.377333]  hda: hda1 hda2 hda3 < hda5 hda6 hda7 hda8 hda9 hda10 hd=
a11 > hda4
[    4.470275] hdb: max request size: 128KiB
[    4.480184] hdb: 160086528 sectors (81964 MB) w/7936KiB Cache, CHS=3D=
65535/16/63
[    4.480559] hdb: cache flushes supported
[    4.480859]  hdb: hdb1 hdb2 hdb3 hdb4 < hdb5 hdb6 hdb7 hdb8 hdb9 >
[    4.552320] ide-cd driver 5.00
[    4.554588] ide-cd: hdc: ATAPI 48X DVD-ROM DVD-R CD-R/RW drive, 2048=
kB Cache
[    4.554904] Uniform CD-ROM driver Revision: 3.20
[    4.567122] PNP: PS/2 Controller [PNP0303:PS2K,PNP0f03:PS2M] at 0x60=
,0x64 irq 1,12
[    4.570814] serio: i8042 KBD port at 0x60,0x64 irq 1
[    4.570984] serio: i8042 AUX port at 0x60,0x64 irq 12
[    4.572850] mice: PS/2 mouse device common for all mice
[    4.574388] cpuidle: using governor ladder
[    4.574481] cpuidle: using governor menu
[    4.575835] TCP cubic registered
[    4.575924] NET: Registered protocol family 17
[    4.576204] Using IPI No-Shortcut mode
[    4.577351] PM: Checking image partition /dev/hda7
[    4.577574] PM: Resume from partition 3:7
[    4.577578] PM: Checking hibernation image.
[    4.592261] PM: Error -22 checking image file
[    4.592267] PM: Resume from disk failed.
[    4.593539] Freeing unused kernel memory: 284k freed
[    4.594446] Write protecting the kernel text: 1852k
[    4.594676] Write protecting the kernel read-only data: 916k
[    4.604332] input: AT Translated Set 2 keyboard as /devices/platform=
/i8042/serio0/input/input0
[    4.928413] input: PS2++ Logitech Mouse as /devices/platform/i8042/s=
erio1/input/input1
[    8.240115] EXT3-fs: INFO: recovery required on readonly filesystem.
[    8.240218] EXT3-fs: write access will be enabled during recovery.
[    8.264858] EXT3-fs: recovery complete.
[    8.265471] kjournald starting.  Commit interval 5 seconds
[    8.266165] EXT3-fs: mounted filesystem with writeback data mode.
[    9.508834] usbcore: registered new interface driver usbfs
[    9.509129] usbcore: registered new interface driver hub
[    9.512137] usbcore: registered new device driver usb
[   10.549879] udevd version 127 started
[   10.797145] input: Sleep Button as /devices/LNXSYSTM:00/LNXSYBUS:00/=
PNP0C0E:00/input/input2
[   10.797189] ACPI: Sleep Button [SLPB]
[   10.797552] input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/=
input/input3
[   10.797570] ACPI: Power Button [PWRF]
[   10.885869] processor LNXCPU:00: registered as cooling_device0
[   10.918715] Floppy drive(s): fd0 is 1.44M
[   10.956681] FDC 0 is a post-1991 82077
[   11.233002] uhci_hcd: USB Universal Host Controller Interface driver
[   11.233413] uhci_hcd 0000:00:1d.0: PCI INT A -> GSI 16 (level, low) =
-> IRQ 16
[   11.233445] uhci_hcd 0000:00:1d.0: setting latency timer to 64
[   11.233454] uhci_hcd 0000:00:1d.0: UHCI Host Controller
[   11.233854] uhci_hcd 0000:00:1d.0: new USB bus registered, assigned =
bus number 1
[   11.233875] uhci_hcd 0000:00:1d.0: detected 2 ports
[   11.233886] uhci_hcd 0000:00:1d.0: uhci_check_and_reset_hc: cmd =3D =
0x0000
[   11.233891] uhci_hcd 0000:00:1d.0: Performing full reset
[   11.233908] uhci_hcd 0000:00:1d.0: supports USB remote wakeup
[   11.233974] uhci_hcd 0000:00:1d.0: irq 16, io base 0x0000e800
[   11.234575] usb usb1: default language 0x0409
[   11.234648] usb usb1: udev 1, busnum 1, minor =3D 0
[   11.234654] usb usb1: New USB device found, idVendor=3D1d6b, idProdu=
ct=3D0001
[   11.234660] usb usb1: New USB device strings: Mfr=3D3, Product=3D2, =
SerialNumber=3D1
[   11.234665] usb usb1: Product: UHCI Host Controller
[   11.234670] usb usb1: Manufacturer: Linux 2.6.32 uhci_hcd
[   11.234674] usb usb1: SerialNumber: 0000:00:1d.0
[   11.235454] usb usb1: uevent
[   11.235746] usb usb1: usb_probe_device
[   11.235753] usb usb1: configuration #1 chosen from 1 choice
[   11.249156] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driv=
er
[   11.249163] Warning! ehci_hcd should always be loaded before uhci_hc=
d and ohci_hcd, not after
[   11.249170] ehci_hcd: block sizes: qh 60 qtd 96 itd 160 sitd 96
[   11.251750] usb usb1: adding 1-0:1.0 (config #1, interface 0)
[   11.251903] usb 1-0:1.0: uevent
[   11.252448] hub 1-0:1.0: usb_probe_interface
[   11.252455] hub 1-0:1.0: usb_probe_interface - got id
[   11.252462] hub 1-0:1.0: USB hub found
[   11.252727] hub 1-0:1.0: 2 ports detected
[   11.252734] hub 1-0:1.0: standalone hub
[   11.252739] hub 1-0:1.0: no power switching (usb 1.0)
[   11.252743] hub 1-0:1.0: individual port over-current protection
[   11.252750] hub 1-0:1.0: power on to power good time: 2ms
[   11.253239] hub 1-0:1.0: local power source is good
[   11.253247] hub 1-0:1.0: trying to enable port power on non-switchab=
le hub
[   11.253850] ehci_hcd 0000:00:1d.7: PCI INT D -> GSI 23 (level, low) =
-> IRQ 23
[   11.253903] ehci_hcd 0000:00:1d.7: setting latency timer to 64
[   11.253912] ehci_hcd 0000:00:1d.7: EHCI Host Controller
[   11.253946] ehci_hcd 0000:00:1d.7: new USB bus registered, assigned =
bus number 2
[   11.253969] ehci_hcd 0000:00:1d.7: reset hcs_params 0x103206 dbg=3D1=
 cc=3D3 pcc=3D2 ordered !ppc ports=3D6
[   11.253977] ehci_hcd 0000:00:1d.7: reset hcc_params 6871 thresh 7 uf=
rames 1024 64 bit addr
[   11.254064] ehci_hcd 0000:00:1d.7: debug port 1
[   11.254076] ehci_hcd 0000:00:1d.7: reset command 080012 (park)=3D0 i=
thresh=3D8 Periodic period=3D1024 Reset HALT
[   11.276742] ehci_hcd 0000:00:1d.7: cache line size of 128 is not sup=
ported
[   11.276751] ehci_hcd 0000:00:1d.7: supports USB remote wakeup
[   11.276841] ehci_hcd 0000:00:1d.7: irq 23, io mem 0xffa7fc00
[   11.276852] ehci_hcd 0000:00:1d.7: reset command 080002 (park)=3D0 i=
thresh=3D8 period=3D1024 Reset HALT
[   11.304816] ohci_hcd: USB 1.1 'Open' Host Controller (OHCI) Driver
[   11.304825] ohci_hcd: block sizes: ed 64 td 64
[   11.304995] ohci_hcd 0000:01:00.0: PCI INT A -> GSI 21 (level, low) =
-> IRQ 21
[   11.305049] ohci_hcd 0000:01:00.0: OHCI Host Controller
[   11.305089] ohci_hcd 0000:01:00.0: new USB bus registered, assigned =
bus number 3
[   11.305110] ohci_hcd 0000:01:00.0: enabled NEC chipset lost interrup=
t quirk
[   11.305193] ohci_hcd 0000:01:00.0: created debug files
[   11.305199] ohci_hcd 0000:01:00.0: supports USB remote wakeup
[   11.305272] ohci_hcd 0000:01:00.0: irq 21, io mem 0xff8fd000
[   11.305303] ehci_hcd 0000:00:1d.7: init command 010001 (park)=3D0 it=
hresh=3D1 period=3D1024 RUN
[   11.316256] ehci_hcd 0000:00:1d.7: USB 2.0 started, EHCI 1.00
[   11.316491] usb usb2: default language 0x0409
[   11.316569] usb usb2: udev 1, busnum 2, minor =3D 128
[   11.316575] usb usb2: New USB device found, idVendor=3D1d6b, idProdu=
ct=3D0002
[   11.316581] usb usb2: New USB device strings: Mfr=3D3, Product=3D2, =
SerialNumber=3D1
[   11.316586] usb usb2: Product: EHCI Host Controller
[   11.316591] usb usb2: Manufacturer: Linux 2.6.32 ehci_hcd
[   11.316595] usb usb2: SerialNumber: 0000:00:1d.7
[   11.316901] usb usb2: uevent
[   11.316975] usb usb2: usb_probe_device
[   11.316982] usb usb2: configuration #1 chosen from 1 choice
[   11.317204] usb usb2: adding 2-0:1.0 (config #1, interface 0)
[   11.317314] usb 2-0:1.0: uevent
[   11.317379] hub 2-0:1.0: usb_probe_interface
[   11.317385] hub 2-0:1.0: usb_probe_interface - got id
[   11.317392] hub 2-0:1.0: USB hub found
[   11.317434] hub 2-0:1.0: 6 ports detected
[   11.317444] hub 2-0:1.0: standalone hub
[   11.317449] hub 2-0:1.0: no power switching (usb 1.0)
[   11.317453] hub 2-0:1.0: individual port over-current protection
[   11.317459] hub 2-0:1.0: power on to power good time: 20ms
[   11.317591] hub 2-0:1.0: local power source is good
[   11.317667] hub 2-0:1.0: trying to enable port power on non-switchab=
le hub
[   11.318025] uhci_hcd 0000:00:1d.1: PCI INT B -> GSI 19 (level, low) =
-> IRQ 19
[   11.318057] uhci_hcd 0000:00:1d.1: setting latency timer to 64
[   11.318066] uhci_hcd 0000:00:1d.1: UHCI Host Controller
[   11.318116] uhci_hcd 0000:00:1d.1: new USB bus registered, assigned =
bus number 4
[   11.318136] uhci_hcd 0000:00:1d.1: detected 2 ports
[   11.318146] uhci_hcd 0000:00:1d.1: uhci_check_and_reset_hc: cmd =3D =
0x0000
[   11.318150] uhci_hcd 0000:00:1d.1: Performing full reset
[   11.318167] uhci_hcd 0000:00:1d.1: supports USB remote wakeup
[   11.318238] uhci_hcd 0000:00:1d.1: irq 19, io base 0x0000e880
[   11.318494] usb usb4: default language 0x0409
[   11.318566] usb usb4: udev 1, busnum 4, minor =3D 384
[   11.318571] usb usb4: New USB device found, idVendor=3D1d6b, idProdu=
ct=3D0001
[   11.318577] usb usb4: New USB device strings: Mfr=3D3, Product=3D2, =
SerialNumber=3D1
[   11.318582] usb usb4: Product: UHCI Host Controller
[   11.318586] usb usb4: Manufacturer: Linux 2.6.32 uhci_hcd
[   11.318590] usb usb4: SerialNumber: 0000:00:1d.1
[   11.318843] usb usb4: uevent
[   11.318926] usb usb4: usb_probe_device
[   11.318933] usb usb4: configuration #1 chosen from 1 choice
[   11.318970] usb usb4: adding 4-0:1.0 (config #1, interface 0)
[   11.319077] usb 4-0:1.0: uevent
[   11.319139] hub 4-0:1.0: usb_probe_interface
[   11.319145] hub 4-0:1.0: usb_probe_interface - got id
[   11.319151] hub 4-0:1.0: USB hub found
[   11.319190] hub 4-0:1.0: 2 ports detected
[   11.319196] hub 4-0:1.0: standalone hub
[   11.319200] hub 4-0:1.0: no power switching (usb 1.0)
[   11.319205] hub 4-0:1.0: individual port over-current protection
[   11.319211] hub 4-0:1.0: power on to power good time: 2ms
[   11.319244] hub 4-0:1.0: local power source is good
[   11.319251] hub 4-0:1.0: trying to enable port power on non-switchab=
le hub
[   11.319500] uhci_hcd 0000:00:1d.2: PCI INT C -> GSI 18 (level, low) =
-> IRQ 18
[   11.319525] uhci_hcd 0000:00:1d.2: setting latency timer to 64
[   11.319533] uhci_hcd 0000:00:1d.2: UHCI Host Controller
[   11.319565] uhci_hcd 0000:00:1d.2: new USB bus registered, assigned =
bus number 5
[   11.319586] uhci_hcd 0000:00:1d.2: detected 2 ports
[   11.319595] uhci_hcd 0000:00:1d.2: uhci_check_and_reset_hc: cmd =3D =
0x0000
[   11.319601] uhci_hcd 0000:00:1d.2: Performing full reset
[   11.319618] uhci_hcd 0000:00:1d.2: supports USB remote wakeup
[   11.319682] uhci_hcd 0000:00:1d.2: irq 18, io base 0x0000ec00
[   11.319854] usb usb5: default language 0x0409
[   11.319921] usb usb5: udev 1, busnum 5, minor =3D 512
[   11.319926] usb usb5: New USB device found, idVendor=3D1d6b, idProdu=
ct=3D0001
[   11.319932] usb usb5: New USB device strings: Mfr=3D3, Product=3D2, =
SerialNumber=3D1
[   11.319937] usb usb5: Product: UHCI Host Controller
[   11.319941] usb usb5: Manufacturer: Linux 2.6.32 uhci_hcd
[   11.319945] usb usb5: SerialNumber: 0000:00:1d.2
[   11.320376] usb usb5: uevent
[   11.320441] usb usb5: usb_probe_device
[   11.320449] usb usb5: configuration #1 chosen from 1 choice
[   11.320504] usb usb5: adding 5-0:1.0 (config #1, interface 0)
[   11.320626] usb 5-0:1.0: uevent
[   11.320687] hub 5-0:1.0: usb_probe_interface
[   11.320693] hub 5-0:1.0: usb_probe_interface - got id
[   11.320699] hub 5-0:1.0: USB hub found
[   11.320743] hub 5-0:1.0: 2 ports detected
[   11.320749] hub 5-0:1.0: standalone hub
[   11.320753] hub 5-0:1.0: no power switching (usb 1.0)
[   11.320757] hub 5-0:1.0: individual port over-current protection
[   11.320762] hub 5-0:1.0: power on to power good time: 2ms
[   11.320803] hub 5-0:1.0: local power source is good
[   11.320810] hub 5-0:1.0: trying to enable port power on non-switchab=
le hub
[   11.352834] hub 1-0:1.0: state 7 ports 2 chg 0000 evt 0000
[   11.373329] e100: Intel(R) PRO/100 Network Driver, 3.5.24-k2-NAPI
[   11.373336] e100: Copyright(c) 1999-2006 Intel Corporation
[   11.416299] hub 2-0:1.0: state 7 ports 6 chg 0000 evt 0000
[   11.416322] hub 4-0:1.0: state 7 ports 2 chg 0000 evt 0000
[   11.420179] hub 5-0:1.0: state 7 ports 2 chg 0000 evt 0000
[   11.530246] input: PC Speaker as /devices/platform/pcspkr/input/inpu=
t4
[   11.548889] ohci_hcd 0000:01:00.0: OHCI controller state
[   11.548900] ohci_hcd 0000:01:00.0: OHCI 1.0, NO legacy support regis=
ters
[   11.548909] ohci_hcd 0000:01:00.0: control 0x283 RWC HCFS=3Doperatio=
nal CBSR=3D3
[   11.548917] ohci_hcd 0000:01:00.0: cmdstatus 0x00000 SOC=3D0
[   11.548924] ohci_hcd 0000:01:00.0: intrstatus 0x00000004 SF
[   11.548931] ohci_hcd 0000:01:00.0: intrenable 0x8000005a MIE RHSC UE=
 RD WDH
[   11.548941] ohci_hcd 0000:01:00.0: hcca frame #00bd
[   11.548949] ohci_hcd 0000:01:00.0: roothub.a 0f000203 POTPGT=3D15 NP=
S NDP=3D3(3)
[   11.548956] ohci_hcd 0000:01:00.0: roothub.b 00000000 PPCM=3D0000 DR=
=3D0000
[   11.548963] ohci_hcd 0000:01:00.0: roothub.status 00008000 DRWE
[   11.548971] ohci_hcd 0000:01:00.0: roothub.portstatus [0] 0x00000100=
 PPS
[   11.548979] ohci_hcd 0000:01:00.0: roothub.portstatus [1] 0x00000100=
 PPS
[   11.548986] ohci_hcd 0000:01:00.0: roothub.portstatus [2] 0x00000100=
 PPS
[   11.549102] usb usb3: default language 0x0409
[   11.549179] usb usb3: udev 1, busnum 3, minor =3D 256
[   11.549186] usb usb3: New USB device found, idVendor=3D1d6b, idProdu=
ct=3D0001
[   11.549192] usb usb3: New USB device strings: Mfr=3D3, Product=3D2, =
SerialNumber=3D1
[   11.549198] usb usb3: Product: OHCI Host Controller
[   11.549203] usb usb3: Manufacturer: Linux 2.6.32 ohci_hcd
[   11.549208] usb usb3: SerialNumber: 0000:01:00.0
[   11.549509] usb usb3: uevent
[   11.549586] usb usb3: usb_probe_device
[   11.549593] usb usb3: configuration #1 chosen from 1 choice
[   11.549637] usb usb3: adding 3-0:1.0 (config #1, interface 0)
[   11.549761] usb 3-0:1.0: uevent
[   11.549827] hub 3-0:1.0: usb_probe_interface
[   11.549833] hub 3-0:1.0: usb_probe_interface - got id
[   11.549840] hub 3-0:1.0: USB hub found
[   11.549883] hub 3-0:1.0: 3 ports detected
[   11.549890] hub 3-0:1.0: standalone hub
[   11.549894] hub 3-0:1.0: no power switching (usb 1.0)
[   11.549898] hub 3-0:1.0: global over-current protection
[   11.549905] hub 3-0:1.0: power on to power good time: 30ms
[   11.549944] hub 3-0:1.0: local power source is good
[   11.549949] hub 3-0:1.0: no over-current condition exists
[   11.549955] hub 3-0:1.0: trying to enable port power on non-switchab=
le hub
[   11.550265] uhci_hcd 0000:01:01.0: PCI INT A -> GSI 22 (level, low) =
-> IRQ 22
[   11.550297] uhci_hcd 0000:01:01.0: UHCI Host Controller
[   11.550332] uhci_hcd 0000:01:01.0: new USB bus registered, assigned =
bus number 6
[   11.550353] uhci_hcd 0000:01:01.0: detected 2 ports
[   11.550363] uhci_hcd 0000:01:01.0: uhci_check_and_reset_hc: cmd =3D =
0x0000
[   11.550368] uhci_hcd 0000:01:01.0: Performing full reset
[   11.550458] uhci_hcd 0000:01:01.0: irq 22, io base 0x0000d880
[   11.550647] usb usb6: default language 0x0409
[   11.550718] usb usb6: udev 1, busnum 6, minor =3D 640
[   11.550724] usb usb6: New USB device found, idVendor=3D1d6b, idProdu=
ct=3D0001
[   11.550731] usb usb6: New USB device strings: Mfr=3D3, Product=3D2, =
SerialNumber=3D1
[   11.550736] usb usb6: Product: UHCI Host Controller
[   11.550740] usb usb6: Manufacturer: Linux 2.6.32 uhci_hcd
[   11.550744] usb usb6: SerialNumber: 0000:01:01.0
[   11.551018] usb usb6: uevent
[   11.551088] usb usb6: usb_probe_device
[   11.551095] usb usb6: configuration #1 chosen from 1 choice
[   11.551147] usb usb6: adding 6-0:1.0 (config #1, interface 0)
[   11.551271] usb 6-0:1.0: uevent
[   11.551334] hub 6-0:1.0: usb_probe_interface
[   11.551340] hub 6-0:1.0: usb_probe_interface - got id
[   11.551346] hub 6-0:1.0: USB hub found
[   11.551388] hub 6-0:1.0: 2 ports detected
[   11.551395] hub 6-0:1.0: standalone hub
[   11.551399] hub 6-0:1.0: no power switching (usb 1.0)
[   11.551403] hub 6-0:1.0: individual port over-current protection
[   11.551409] hub 6-0:1.0: power on to power good time: 2ms
[   11.551447] hub 6-0:1.0: local power source is good
[   11.551454] hub 6-0:1.0: trying to enable port power on non-switchab=
le hub
[   11.551856] ehci_hcd 0000:01:00.2: PCI INT C -> GSI 23 (level, low) =
-> IRQ 23
[   11.551910] ehci_hcd 0000:01:00.2: EHCI Host Controller
[   11.551945] ehci_hcd 0000:01:00.2: new USB bus registered, assigned =
bus number 7
[   11.551970] ehci_hcd 0000:01:00.2: reset hcs_params 0x2395 dbg=3D0 c=
c=3D2 pcc=3D3 ports=3D5
[   11.551981] ehci_hcd 0000:01:00.2: reset portroute 1 0 1 0 0=20
[   11.551988] ehci_hcd 0000:01:00.2: reset hcc_params e806 thresh 0 uf=
rames 256/512/1024 park
[   11.552237] ehci_hcd 0000:01:00.2: park 0
[   11.552259] ehci_hcd 0000:01:00.2: reset command 080b02 park=3D3 ith=
resh=3D8 period=3D1024 Reset HALT
[   11.552271] ehci_hcd 0000:01:00.2: ...powerup ports...
[   11.576143] ehci_hcd 0000:01:00.2: MWI active
[   11.576153] ehci_hcd 0000:01:00.2: supports USB remote wakeup
[   11.576190] ehci_hcd 0000:01:00.2: irq 23, io mem 0xff8ffc00
[   11.576202] ehci_hcd 0000:01:00.2: reset command 080b02 park=3D3 ith=
resh=3D8 period=3D1024 Reset HALT
[   11.576213] ehci_hcd 0000:01:00.2: init command 010009 (park)=3D0 it=
hresh=3D1 period=3D256 RUN
[   11.588334] ehci_hcd 0000:01:00.2: USB 2.0 started, EHCI 1.00
[   11.588537] usb usb7: default language 0x0409
[   11.588610] usb usb7: udev 1, busnum 7, minor =3D 768
[   11.588616] usb usb7: New USB device found, idVendor=3D1d6b, idProdu=
ct=3D0002
[   11.588622] usb usb7: New USB device strings: Mfr=3D3, Product=3D2, =
SerialNumber=3D1
[   11.588628] usb usb7: Product: EHCI Host Controller
[   11.588632] usb usb7: Manufacturer: Linux 2.6.32 ehci_hcd
[   11.588637] usb usb7: SerialNumber: 0000:01:00.2
[   11.588951] usb usb7: uevent
[   11.589031] usb usb7: usb_probe_device
[   11.589039] usb usb7: configuration #1 chosen from 1 choice
[   11.589079] usb usb7: adding 7-0:1.0 (config #1, interface 0)
[   11.589185] usb 7-0:1.0: uevent
[   11.589251] hub 7-0:1.0: usb_probe_interface
[   11.589257] hub 7-0:1.0: usb_probe_interface - got id
[   11.589263] hub 7-0:1.0: USB hub found
[   11.589313] hub 7-0:1.0: 5 ports detected
[   11.589320] hub 7-0:1.0: standalone hub
[   11.589325] hub 7-0:1.0: individual port power switching
[   11.589329] hub 7-0:1.0: individual port over-current protection
[   11.589336] hub 7-0:1.0: power on to power good time: 20ms
[   11.589370] hub 7-0:1.0: local power source is good
[   11.589377] hub 7-0:1.0: enabling power on all ports
[   11.589780] e100 0000:01:08.0: PCI INT A -> GSI 20 (level, low) -> I=
RQ 20
[   11.648282] uhci_hcd 0000:01:01.0: port 1 portsc 008a,00
[   11.648442] uhci_hcd 0000:01:01.0: port 2 portsc 008a,00
[   11.648554] hub 3-0:1.0: state 7 ports 3 chg 0000 evt 0000
[   11.688493] hub 7-0:1.0: state 7 ports 5 chg 0000 evt 0000
[   11.748409] hub 6-0:1.0: state 7 ports 2 chg 0000 evt 0000
[   11.873288] e100 0000:01:08.0: PME# disabled
[   11.874719] e100: eth0: e100_probe: addr 0xff8fc000, irq 20, MAC add=
r 00:0c:f1:a8:ee:4a
[   11.874810] uhci_hcd 0000:01:01.1: PCI INT B -> GSI 21 (level, low) =
-> IRQ 21
[   11.874872] uhci_hcd 0000:01:01.1: UHCI Host Controller
[   11.874926] uhci_hcd 0000:01:01.1: new USB bus registered, assigned =
bus number 8
[   11.874947] uhci_hcd 0000:01:01.1: detected 2 ports
[   11.874957] uhci_hcd 0000:01:01.1: uhci_check_and_reset_hc: cmd =3D =
0x0000
[   11.874962] uhci_hcd 0000:01:01.1: Performing full reset
[   11.875007] uhci_hcd 0000:01:01.1: irq 21, io base 0x0000dc00
[   11.875224] usb usb8: default language 0x0409
[   11.875303] usb usb8: udev 1, busnum 8, minor =3D 896
[   11.875309] usb usb8: New USB device found, idVendor=3D1d6b, idProdu=
ct=3D0001
[   11.875315] usb usb8: New USB device strings: Mfr=3D3, Product=3D2, =
SerialNumber=3D1
[   11.875320] usb usb8: Product: UHCI Host Controller
[   11.875324] usb usb8: Manufacturer: Linux 2.6.32 uhci_hcd
[   11.875329] usb usb8: SerialNumber: 0000:01:01.1
[   11.875674] usb usb8: uevent
[   11.875747] usb usb8: usb_probe_device
[   11.875755] usb usb8: configuration #1 chosen from 1 choice
[   11.875798] usb usb8: adding 8-0:1.0 (config #1, interface 0)
[   11.875905] usb 8-0:1.0: uevent
[   11.875971] hub 8-0:1.0: usb_probe_interface
[   11.875977] hub 8-0:1.0: usb_probe_interface - got id
[   11.875984] hub 8-0:1.0: USB hub found
[   11.876118] hub 8-0:1.0: 2 ports detected
[   11.876125] hub 8-0:1.0: standalone hub
[   11.876129] hub 8-0:1.0: no power switching (usb 1.0)
[   11.876133] hub 8-0:1.0: individual port over-current protection
[   11.876139] hub 8-0:1.0: power on to power good time: 2ms
[   11.876180] hub 8-0:1.0: local power source is good
[   11.876188] hub 8-0:1.0: trying to enable port power on non-switchab=
le hub
[   11.876492] ohci_hcd 0000:01:00.1: PCI INT B -> GSI 22 (level, low) =
-> IRQ 22
[   11.876546] ohci_hcd 0000:01:00.1: OHCI Host Controller
[   11.876580] ohci_hcd 0000:01:00.1: new USB bus registered, assigned =
bus number 9
[   11.876601] ohci_hcd 0000:01:00.1: enabled NEC chipset lost interrup=
t quirk
[   11.876727] ohci_hcd 0000:01:00.1: created debug files
[   11.876733] ohci_hcd 0000:01:00.1: supports USB remote wakeup
[   11.876764] ohci_hcd 0000:01:00.1: irq 22, io mem 0xff8fe000
[   11.976155] uhci_hcd 0000:01:01.1: port 1 portsc 018a,00
[   11.976218] uhci_hcd 0000:01:01.1: port 2 portsc 008a,00
[   12.076269] hub 8-0:1.0: state 7 ports 2 chg 0000 evt 0000
[   12.089134] ohci_hcd 0000:01:00.1: OHCI controller state
[   12.089143] ohci_hcd 0000:01:00.1: OHCI 1.0, NO legacy support regis=
ters
[   12.089152] ohci_hcd 0000:01:00.1: control 0x283 RWC HCFS=3Doperatio=
nal CBSR=3D3
[   12.089159] ohci_hcd 0000:01:00.1: cmdstatus 0x00000 SOC=3D0
[   12.089166] ohci_hcd 0000:01:00.1: intrstatus 0x00000004 SF
[   12.089173] ohci_hcd 0000:01:00.1: intrenable 0x8000005a MIE RHSC UE=
 RD WDH
[   12.089183] ohci_hcd 0000:01:00.1: hcca frame #009e
[   12.089190] ohci_hcd 0000:01:00.1: roothub.a 0f000202 POTPGT=3D15 NP=
S NDP=3D2(2)
[   12.089197] ohci_hcd 0000:01:00.1: roothub.b 00000000 PPCM=3D0000 DR=
=3D0000
[   12.089204] ohci_hcd 0000:01:00.1: roothub.status 00008000 DRWE
[   12.089211] ohci_hcd 0000:01:00.1: roothub.portstatus [0] 0x00000100=
 PPS
[   12.089219] ohci_hcd 0000:01:00.1: roothub.portstatus [1] 0x00000100=
 PPS
[   12.089328] usb usb9: default language 0x0409
[   12.089400] usb usb9: udev 1, busnum 9, minor =3D 1024
[   12.089406] usb usb9: New USB device found, idVendor=3D1d6b, idProdu=
ct=3D0001
[   12.089411] usb usb9: New USB device strings: Mfr=3D3, Product=3D2, =
SerialNumber=3D1
[   12.089417] usb usb9: Product: OHCI Host Controller
[   12.089421] usb usb9: Manufacturer: Linux 2.6.32 ohci_hcd
[   12.089426] usb usb9: SerialNumber: 0000:01:00.1
[   12.089759] usb usb9: uevent
[   12.089842] usb usb9: usb_probe_device
[   12.089852] usb usb9: configuration #1 chosen from 1 choice
[   12.089893] usb usb9: adding 9-0:1.0 (config #1, interface 0)
[   12.090000] usb 9-0:1.0: uevent
[   12.090068] hub 9-0:1.0: usb_probe_interface
[   12.090074] hub 9-0:1.0: usb_probe_interface - got id
[   12.090080] hub 9-0:1.0: USB hub found
[   12.090122] hub 9-0:1.0: 2 ports detected
[   12.090129] hub 9-0:1.0: standalone hub
[   12.090133] hub 9-0:1.0: no power switching (usb 1.0)
[   12.090137] hub 9-0:1.0: global over-current protection
[   12.090143] hub 9-0:1.0: power on to power good time: 30ms
[   12.090178] hub 9-0:1.0: local power source is good
[   12.090183] hub 9-0:1.0: no over-current condition exists
[   12.090189] hub 9-0:1.0: trying to enable port power on non-switchab=
le hub
[   12.090490] ehci_hcd 0000:01:01.2: PCI INT C -> GSI 20 (level, low) =
-> IRQ 20
[   12.090548] ehci_hcd 0000:01:01.2: EHCI Host Controller
[   12.090588] ehci_hcd 0000:01:01.2: new USB bus registered, assigned =
bus number 10
[   12.090611] ehci_hcd 0000:01:01.2: reset hcs_params 0x2204 dbg=3D0 c=
c=3D2 pcc=3D2 ordered !ppc ports=3D4
[   12.090619] ehci_hcd 0000:01:01.2: reset hcc_params 0002 thresh 0 uf=
rames 256/512/1024
[   12.090711] ehci_hcd 0000:01:01.2: reset command 080002 (park)=3D0 i=
thresh=3D8 period=3D1024 Reset HALT
[   12.090733] ehci_hcd 0000:01:01.2: MWI active
[   12.090738] ehci_hcd 0000:01:01.2: supports USB remote wakeup
[   12.090817] ehci_hcd 0000:01:01.2: irq 20, io mem 0xff8ff800
[   12.090826] ehci_hcd 0000:01:01.2: reset command 080002 (park)=3D0 i=
thresh=3D8 period=3D1024 Reset HALT
[   12.090836] ehci_hcd 0000:01:01.2: init command 010009 (park)=3D0 it=
hresh=3D1 period=3D256 RUN
[   12.100204] ehci_hcd 0000:01:01.2: USB 2.0 started, EHCI 0.95
[   12.100404] usb usb10: default language 0x0409
[   12.100476] usb usb10: udev 1, busnum 10, minor =3D 1152
[   12.100482] usb usb10: New USB device found, idVendor=3D1d6b, idProd=
uct=3D0002
[   12.100488] usb usb10: New USB device strings: Mfr=3D3, Product=3D2,=
 SerialNumber=3D1
[   12.100493] usb usb10: Product: EHCI Host Controller
[   12.100498] usb usb10: Manufacturer: Linux 2.6.32 ehci_hcd
[   12.100503] usb usb10: SerialNumber: 0000:01:01.2
[   12.100826] usb usb10: uevent
[   12.100906] usb usb10: usb_probe_device
[   12.100914] usb usb10: configuration #1 chosen from 1 choice
[   12.100953] usb usb10: adding 10-0:1.0 (config #1, interface 0)
[   12.101060] usb 10-0:1.0: uevent
[   12.101129] hub 10-0:1.0: usb_probe_interface
[   12.101135] hub 10-0:1.0: usb_probe_interface - got id
[   12.101142] hub 10-0:1.0: USB hub found
[   12.101183] hub 10-0:1.0: 4 ports detected
[   12.101190] hub 10-0:1.0: standalone hub
[   12.101195] hub 10-0:1.0: no power switching (usb 1.0)
[   12.101199] hub 10-0:1.0: individual port over-current protection
[   12.101206] hub 10-0:1.0: power on to power good time: 20ms
[   12.101240] hub 10-0:1.0: local power source is good
[   12.101248] hub 10-0:1.0: trying to enable port power on non-switcha=
ble hub
[   12.188856] hub 9-0:1.0: state 7 ports 2 chg 0000 evt 0000
[   12.200394] hub 10-0:1.0: state 7 ports 4 chg 0000 evt 0000
[   12.304048] usb usb1: suspend_rh (auto-stop)
[   12.552053] usb usb4: suspend_rh (auto-stop)
[   12.552085] usb usb5: suspend_rh (auto-stop)
[   12.552112] ohci_hcd 0000:01:00.0: auto-stop root hub
[   12.800065] usb usb6: suspend_rh (auto-stop)
[   13.296028] usb usb8: suspend_rh (auto-stop)
[   13.296058] ohci_hcd 0000:01:00.1: auto-stop root hub
[   13.816552] hub 1-0:1.0: hub_suspend
[   13.816814] usb usb1: bus auto-suspend
[   13.816851] usb usb1: suspend_rh
[   13.816970] hub 2-0:1.0: hub_suspend
[   13.816983] usb usb2: bus auto-suspend
[   13.816988] ehci_hcd 0000:00:1d.7: suspend root hub
[   13.817188] hub 4-0:1.0: hub_suspend
[   13.817199] usb usb4: bus auto-suspend
[   13.817204] usb usb4: suspend_rh
[   13.817231] hub 5-0:1.0: hub_suspend
[   13.817241] usb usb5: bus auto-suspend
[   13.817246] usb usb5: suspend_rh
[   13.817272] hub 3-0:1.0: hub_suspend
[   13.817282] usb usb3: bus auto-suspend
[   13.817320] ohci_hcd 0000:01:00.0: suspend root hub
[   13.817338] hub 7-0:1.0: hub_suspend
[   13.817349] usb usb7: bus auto-suspend
[   13.817353] ehci_hcd 0000:01:00.2: suspend root hub
[   13.817503] hub 6-0:1.0: hub_suspend
[   13.817514] usb usb6: bus auto-suspend
[   13.817519] usb usb6: suspend_rh
[   14.816076] hub 8-0:1.0: hub_suspend
[   14.816098] usb usb8: bus auto-suspend
[   14.816106] usb usb8: suspend_rh
[   14.816135] hub 9-0:1.0: hub_suspend
[   14.816146] usb usb9: bus auto-suspend
[   14.816155] ohci_hcd 0000:01:00.1: suspend root hub
[   14.816173] hub 10-0:1.0: hub_suspend
[   14.816183] usb usb10: bus auto-suspend
[   14.816189] ehci_hcd 0000:01:01.2: suspend root hub
[   17.061246] EXT3 FS on hda8, internal journal
[   17.390463] kjournald starting.  Commit interval 5 seconds
[   17.390597] EXT3 FS on hda1, internal journal
[   17.390618] EXT3-fs: mounted filesystem with writeback data mode.
[   17.420909] kjournald starting.  Commit interval 5 seconds
[   17.421068] EXT3 FS on hda9, internal journal
[   17.421089] EXT3-fs: mounted filesystem with writeback data mode.
[   17.450926] kjournald starting.  Commit interval 5 seconds
[   17.451074] EXT3 FS on hda10, internal journal
[   17.451093] EXT3-fs: mounted filesystem with writeback data mode.
[   17.474002] kjournald starting.  Commit interval 5 seconds
[   17.474158] EXT3 FS on hda4, internal journal
[   17.474179] EXT3-fs: mounted filesystem with writeback data mode.
[   17.490768] kjournald starting.  Commit interval 5 seconds
[   17.490922] EXT3 FS on hda11, internal journal
[   17.490942] EXT3-fs: mounted filesystem with writeback data mode.
[   17.569430] EXT3-fs: mounted filesystem with writeback data mode.
[   17.570634] kjournald starting.  Commit interval 5 seconds
[   17.600215] EXT3-fs: mounted filesystem with writeback data mode.
[   17.601567] kjournald starting.  Commit interval 5 seconds
[   17.621456] EXT3-fs: mounted filesystem with writeback data mode.
[   17.622668] kjournald starting.  Commit interval 5 seconds
[   17.665309] EXT3-fs: mounted filesystem with writeback data mode.
[   17.666672] kjournald starting.  Commit interval 5 seconds
[   17.681236] EXT3-fs: mounted filesystem with writeback data mode.
[   17.684047] kjournald starting.  Commit interval 5 seconds
[   18.889035] Adding 530104k swap on /dev/hda7.  Priority:-1 extents:1=
 across:530104k=20
[   20.160382] e100: eth0 NIC Link is Up 100 Mbps Full Duplex
[   51.771997] SysRq : Changing Loglevel
[   51.772132] Loglevel set to 9
[   97.579794] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
[   97.579941] BUG skbuff_head_cache: Poison overwritten
[   97.580003] --------------------------------------------------------=
---------------------
[   97.580003]=20
[   97.580003] INFO: 0xee9b2098-0xee9b2098. First byte 0x6c instead of =
0x6b
[   97.580003] INFO: Allocated in __alloc_skb+0x29/0x11a age=3D14232 cp=
u=3D0 pid=3D1835
[   97.580003] INFO: Freed in __kfree_skb+0x6e/0x71 age=3D10947 cpu=3D0=
 pid=3D2006
[   97.580003] INFO: Slab 0xc21f1828 objects=3D16 used=3D0 fp=3D0xee9b2=
400 flags=3D0x40000082
[   97.580003] INFO: Object 0xee9b2000 @offset=3D0 fp=3D0xee9b2700
[   97.580003]=20
[   97.580003]   Object 0xee9b2000:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6=
b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[   97.580003]   Object 0xee9b2010:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6=
b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[   97.580003]   Object 0xee9b2020:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6=
b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[   97.580003]   Object 0xee9b2030:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6=
b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[   97.580003]   Object 0xee9b2040:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6=
b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[   97.580003]   Object 0xee9b2050:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6=
b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[   97.580003]   Object 0xee9b2060:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6=
b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[   97.580003]   Object 0xee9b2070:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6=
b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[   97.580003]   Object 0xee9b2080:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6=
b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[   97.580003]   Object 0xee9b2090:  6b 6b 6b 6b 6b 6b 6b 6b 6c 6b 6b a=
3             kkkkkkkklkk=A3   =20
[   97.580003]  Redzone 0xee9b209c:  bb bb bb bb                       =
              =BB=BB=BB=BB           =20
[   97.580003]  Padding 0xee9b20c4:  5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5=
a 5a 5a 5a 5a ZZZZZZZZZZZZZZZZ
[   97.580003]  Padding 0xee9b20d4:  5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5=
a 5a 5a 5a 5a ZZZZZZZZZZZZZZZZ
[   97.580003]  Padding 0xee9b20e4:  5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5=
a 5a 5a 5a 5a ZZZZZZZZZZZZZZZZ
[   97.580003]  Padding 0xee9b20f4:  5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5=
a             ZZZZZZZZZZZZ   =20
[   97.580003] Pid: 2006, comm: rmmod Not tainted 2.6.32 #1
[   97.580003] Call Trace:
[   97.580003]  [<c106edbe>] print_trailer+0xff/0x107
[   97.580003]  [<c106ee47>] check_bytes_and_report+0x81/0xa4
[   97.580003]  [<c106ef3f>] check_object+0xa5/0x160
[   97.580003]  [<c106f05e>] __free_slab+0x64/0xf5
[   97.580003]  [<c106f12a>] discard_slab+0x3b/0x3e
[   97.580003]  [<c10704cc>] __slab_free+0x115/0x24b
[   97.580003]  [<c107198f>] kmem_cache_free+0x7b/0xa2
[   97.580003]  [<c11744c6>] ? __kfree_skb+0x6e/0x71
[   97.580003]  [<c11744c6>] ? __kfree_skb+0x6e/0x71
[   97.580003]  [<c11744c6>] __kfree_skb+0x6e/0x71
[   97.580003]  [<c11744f4>] consume_skb+0x2b/0x2d
[   97.580003]  [<f083cb92>] e100_rx_clean_list+0x46/0x75 [e100]
[   97.580003]  [<f083cfa3>] e100_down+0x7e/0x82 [e100]
[   97.580003]  [<f083d0ae>] e100_close+0xd/0x11 [e100]
[   97.580003]  [<c117bc18>] dev_close+0x77/0x98
[   97.580003]  [<c117bcb1>] rollback_registered+0x78/0x210
[   97.580003]  [<c117be7b>] unregister_netdevice+0x32/0x4d
[   97.580003]  [<c117bea8>] unregister_netdev+0x12/0x1a
[   97.580003]  [<f083de9d>] e100_remove+0x27/0x68 [e100]
[   97.580003]  [<c10fb01b>] pci_device_remove+0x19/0x39
[   97.580003]  [<c1146d62>] __device_release_driver+0x79/0xbd
[   97.580003]  [<c1146e0d>] driver_detach+0x67/0x85
[   97.580003]  [<c114630c>] bus_remove_driver+0x69/0x8f
[   97.580003]  [<c1147238>] driver_unregister+0x4d/0x54
[   97.580003]  [<c10fb1e0>] pci_unregister_driver+0x2d/0x69
[   97.580003]  [<f083de71>] e100_cleanup_module+0xd/0x12 [e100]
[   97.580003]  [<c1046ab3>] sys_delete_module+0x17d/0x1d6
[   97.580003]  [<c1002abc>] ? restore_all_notrace+0x0/0x18
[   97.580003]  [<c11cc096>] ? do_page_fault+0x0/0x234
[   97.580003]  [<c1002a08>] sysenter_do_call+0x12/0x36
[   97.580003] FIX skbuff_head_cache: Restoring 0xee9b2098-0xee9b2098=3D=
0x6b
[   97.580003]=20
[   97.580003] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
[   97.580003] BUG skbuff_head_cache: Poison overwritten
[   97.580003] --------------------------------------------------------=
---------------------
[   97.580003]=20
[   97.580003] INFO: 0xee9b2798-0xee9b2798. First byte 0x6c instead of =
0x6b
[   97.580003] INFO: Allocated in __alloc_skb+0x29/0x11a age=3D14232 cp=
u=3D0 pid=3D1573
[   97.580003] INFO: Freed in __kfree_skb+0x6e/0x71 age=3D10947 cpu=3D0=
 pid=3D2006
[   97.580003] INFO: Slab 0xc21f1828 objects=3D16 used=3D0 fp=3D0xee9b2=
400 flags=3D0x40000082
[   97.580003] INFO: Object 0xee9b2700 @offset=3D1792 fp=3D0x(null)
[   97.580003]=20
[   97.580003] Bytes b4 0xee9b26f0:  5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5=
a 5a 5a 5a 5a ZZZZZZZZZZZZZZZZ
[   97.580003]   Object 0xee9b2700:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6=
b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[   97.580003]   Object 0xee9b2710:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6=
b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[   97.580003]   Object 0xee9b2720:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6=
b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[   97.580003]   Object 0xee9b2730:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6=
b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[   97.580003]   Object 0xee9b2740:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6=
b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[   97.580003]   Object 0xee9b2750:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6=
b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[   97.580003]   Object 0xee9b2760:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6=
b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[   97.580003]   Object 0xee9b2770:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6=
b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[   97.580003]   Object 0xee9b2780:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6=
b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[   97.580003]   Object 0xee9b2790:  6b 6b 6b 6b 6b 6b 6b 6b 6c 6b 6b a=
3             kkkkkkkklkk=A3   =20
[   97.580003]  Redzone 0xee9b279c:  bb bb bb bb                       =
              =BB=BB=BB=BB           =20
[   97.580003]  Padding 0xee9b27c4:  5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5=
a 5a 5a 5a 5a ZZZZZZZZZZZZZZZZ
[   97.580003]  Padding 0xee9b27d4:  5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5=
a 5a 5a 5a 5a ZZZZZZZZZZZZZZZZ
[   97.580003]  Padding 0xee9b27e4:  5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5=
a 5a 5a 5a 5a ZZZZZZZZZZZZZZZZ
[   97.580003]  Padding 0xee9b27f4:  5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5=
a             ZZZZZZZZZZZZ   =20
[   97.580003] Pid: 2006, comm: rmmod Not tainted 2.6.32 #1
[   97.580003] Call Trace:
[   97.580003]  [<c106edbe>] print_trailer+0xff/0x107
[   97.580003]  [<c106ee47>] check_bytes_and_report+0x81/0xa4
[   97.580003]  [<c106ef3f>] check_object+0xa5/0x160
[   97.580003]  [<c106f05e>] __free_slab+0x64/0xf5
[   97.580003]  [<c106f12a>] discard_slab+0x3b/0x3e
[   97.580003]  [<c10704cc>] __slab_free+0x115/0x24b
[   97.580003]  [<c107198f>] kmem_cache_free+0x7b/0xa2
[   97.580003]  [<c11744c6>] ? __kfree_skb+0x6e/0x71
[   97.580003]  [<c11744c6>] ? __kfree_skb+0x6e/0x71
[   97.580003]  [<c11744c6>] __kfree_skb+0x6e/0x71
[   97.580003]  [<c11744f4>] consume_skb+0x2b/0x2d
[   97.580003]  [<f083cb92>] e100_rx_clean_list+0x46/0x75 [e100]
[   97.580003]  [<f083cfa3>] e100_down+0x7e/0x82 [e100]
[   97.580003]  [<f083d0ae>] e100_close+0xd/0x11 [e100]
[   97.580003]  [<c117bc18>] dev_close+0x77/0x98
[   97.580003]  [<c117bcb1>] rollback_registered+0x78/0x210
[   97.580003]  [<c117be7b>] unregister_netdevice+0x32/0x4d
[   97.580003]  [<c117bea8>] unregister_netdev+0x12/0x1a
[   97.580003]  [<f083de9d>] e100_remove+0x27/0x68 [e100]
[   97.580003]  [<c10fb01b>] pci_device_remove+0x19/0x39
[   97.580003]  [<c1146d62>] __device_release_driver+0x79/0xbd
[   97.580003]  [<c1146e0d>] driver_detach+0x67/0x85
[   97.580003]  [<c114630c>] bus_remove_driver+0x69/0x8f
[   97.580003]  [<c1147238>] driver_unregister+0x4d/0x54
[   97.580003]  [<c10fb1e0>] pci_unregister_driver+0x2d/0x69
[   97.580003]  [<f083de71>] e100_cleanup_module+0xd/0x12 [e100]
[   97.580003]  [<c1046ab3>] sys_delete_module+0x17d/0x1d6
[   97.580003]  [<c1002abc>] ? restore_all_notrace+0x0/0x18
[   97.580003]  [<c11cc096>] ? do_page_fault+0x0/0x234
[   97.580003]  [<c1002a08>] sysenter_do_call+0x12/0x36
[   97.580003] FIX skbuff_head_cache: Restoring 0xee9b2798-0xee9b2798=3D=
0x6b
[   97.580003]=20
[   97.638596] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
[   97.638738] BUG skbuff_head_cache: Poison overwritten
[   97.638826] --------------------------------------------------------=
---------------------
[   97.638829]=20
[   97.639039] INFO: 0xeebfe698-0xeebfe698. First byte 0x6c instead of =
0x6b
[   97.639140] INFO: Allocated in __alloc_skb+0x29/0x11a age=3D14219 cp=
u=3D0 pid=3D1835
[   97.639275] INFO: Freed in __kfree_skb+0x6e/0x71 age=3D10962 cpu=3D0=
 pid=3D2006
[   97.639368] INFO: Slab 0xc21f8f98 objects=3D16 used=3D0 fp=3D0xeebfe=
100 flags=3D0x40000082
[   97.639501] INFO: Object 0xeebfe600 @offset=3D1536 fp=3D0xeebfee00
[   97.639504]=20
[   97.639668] Bytes b4 0xeebfe5f0:  5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5=
a 5a 5a 5a 5a ZZZZZZZZZZZZZZZZ
[   97.640006]   Object 0xeebfe600:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6=
b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[   97.640006]   Object 0xeebfe610:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6=
b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[   97.640006]   Object 0xeebfe620:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6=
b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[   97.640006]   Object 0xeebfe630:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6=
b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[   97.640006]   Object 0xeebfe640:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6=
b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[   97.640006]   Object 0xeebfe650:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6=
b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[   97.640006]   Object 0xeebfe660:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6=
b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[   97.640006]   Object 0xeebfe670:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6=
b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[   97.640006]   Object 0xeebfe680:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6=
b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[   97.640006]   Object 0xeebfe690:  6b 6b 6b 6b 6b 6b 6b 6b 6c 6b 6b a=
3             kkkkkkkklkk=A3   =20
[   97.640006]  Redzone 0xeebfe69c:  bb bb bb bb                       =
              =BB=BB=BB=BB           =20
[   97.640006]  Padding 0xeebfe6c4:  5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5=
a 5a 5a 5a 5a ZZZZZZZZZZZZZZZZ
[   97.640006]  Padding 0xeebfe6d4:  5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5=
a 5a 5a 5a 5a ZZZZZZZZZZZZZZZZ
[   97.640006]  Padding 0xeebfe6e4:  5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5=
a 5a 5a 5a 5a ZZZZZZZZZZZZZZZZ
[   97.640006]  Padding 0xeebfe6f4:  5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5=
a             ZZZZZZZZZZZZ   =20
[   97.640006] Pid: 2006, comm: rmmod Not tainted 2.6.32 #1
[   97.640006] Call Trace:
[   97.640006]  [<c106edbe>] print_trailer+0xff/0x107
[   97.640006]  [<c106ee47>] check_bytes_and_report+0x81/0xa4
[   97.640006]  [<c106ef3f>] check_object+0xa5/0x160
[   97.640006]  [<c106f05e>] __free_slab+0x64/0xf5
[   97.640006]  [<c106f12a>] discard_slab+0x3b/0x3e
[   97.640006]  [<c10704cc>] __slab_free+0x115/0x24b
[   97.640006]  [<c107198f>] kmem_cache_free+0x7b/0xa2
[   97.640006]  [<c11744c6>] ? __kfree_skb+0x6e/0x71
[   97.640006]  [<c11744c6>] ? __kfree_skb+0x6e/0x71
[   97.640006]  [<c11744c6>] __kfree_skb+0x6e/0x71
[   97.640006]  [<c11744f4>] consume_skb+0x2b/0x2d
[   97.640006]  [<f083cb92>] e100_rx_clean_list+0x46/0x75 [e100]
[   97.640006]  [<f083cfa3>] e100_down+0x7e/0x82 [e100]
[   97.640006]  [<f083d0ae>] e100_close+0xd/0x11 [e100]
[   97.640006]  [<c117bc18>] dev_close+0x77/0x98
[   97.640006]  [<c117bcb1>] rollback_registered+0x78/0x210
[   97.640006]  [<c117be7b>] unregister_netdevice+0x32/0x4d
[   97.640006]  [<c117bea8>] unregister_netdev+0x12/0x1a
[   97.640006]  [<f083de9d>] e100_remove+0x27/0x68 [e100]
[   97.640006]  [<c10fb01b>] pci_device_remove+0x19/0x39
[   97.640006]  [<c1146d62>] __device_release_driver+0x79/0xbd
[   97.640006]  [<c1146e0d>] driver_detach+0x67/0x85
[   97.640006]  [<c114630c>] bus_remove_driver+0x69/0x8f
[   97.640006]  [<c1147238>] driver_unregister+0x4d/0x54
[   97.640006]  [<c10fb1e0>] pci_unregister_driver+0x2d/0x69
[   97.640006]  [<f083de71>] e100_cleanup_module+0xd/0x12 [e100]
[   97.640006]  [<c1046ab3>] sys_delete_module+0x17d/0x1d6
[   97.640006]  [<c1002abc>] ? restore_all_notrace+0x0/0x18
[   97.640006]  [<c11cc096>] ? do_page_fault+0x0/0x234
[   97.640006]  [<c1002a08>] sysenter_do_call+0x12/0x36
[   97.640006] FIX skbuff_head_cache: Restoring 0xeebfe698-0xeebfe698=3D=
0x6b
[   97.640006]=20
[   97.640006] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
[   97.640006] BUG skbuff_head_cache: Poison overwritten
[   97.640006] --------------------------------------------------------=
---------------------
[   97.640006]=20
[   97.640006] INFO: 0xeebfee98-0xeebfee98. First byte 0x6c instead of =
0x6b
[   97.640006] INFO: Allocated in __alloc_skb+0x29/0x11a age=3D14224 cp=
u=3D0 pid=3D0
[   97.640006] INFO: Freed in __kfree_skb+0x6e/0x71 age=3D10962 cpu=3D0=
 pid=3D2006
[   97.640006] INFO: Slab 0xc21f8f98 objects=3D16 used=3D0 fp=3D0xeebfe=
100 flags=3D0x40000082
[   97.640006] INFO: Object 0xeebfee00 @offset=3D3584 fp=3D0xeebfef00
[   97.640006]=20
[   97.640006] Bytes b4 0xeebfedf0:  5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5=
a 5a 5a 5a 5a ZZZZZZZZZZZZZZZZ
[   97.640006]   Object 0xeebfee00:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6=
b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[   97.640006]   Object 0xeebfee10:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6=
b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[   97.640006]   Object 0xeebfee20:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6=
b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[   97.640006]   Object 0xeebfee30:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6=
b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[   97.640006]   Object 0xeebfee40:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6=
b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[   97.640006]   Object 0xeebfee50:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6=
b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[   97.640006]   Object 0xeebfee60:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6=
b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[   97.640006]   Object 0xeebfee70:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6=
b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[   97.640006]   Object 0xeebfee80:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6=
b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[   97.640006]   Object 0xeebfee90:  6b 6b 6b 6b 6b 6b 6b 6b 6c 6b 6b a=
3             kkkkkkkklkk=A3   =20
[   97.640006]  Redzone 0xeebfee9c:  bb bb bb bb                       =
              =BB=BB=BB=BB           =20
[   97.640006]  Padding 0xeebfeec4:  5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5=
a 5a 5a 5a 5a ZZZZZZZZZZZZZZZZ
[   97.640006]  Padding 0xeebfeed4:  5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5=
a 5a 5a 5a 5a ZZZZZZZZZZZZZZZZ
[   97.640006]  Padding 0xeebfeee4:  5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5=
a 5a 5a 5a 5a ZZZZZZZZZZZZZZZZ
[   97.640006]  Padding 0xeebfeef4:  5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5=
a             ZZZZZZZZZZZZ   =20
[   97.640006] Pid: 2006, comm: rmmod Not tainted 2.6.32 #1
[   97.640006] Call Trace:
[   97.640006]  [<c106edbe>] print_trailer+0xff/0x107
[   97.640006]  [<c106ee47>] check_bytes_and_report+0x81/0xa4
[   97.640006]  [<c106ef3f>] check_object+0xa5/0x160
[   97.640006]  [<c106f05e>] __free_slab+0x64/0xf5
[   97.640006]  [<c106f12a>] discard_slab+0x3b/0x3e
[   97.640006]  [<c10704cc>] __slab_free+0x115/0x24b
[   97.640006]  [<c107198f>] kmem_cache_free+0x7b/0xa2
[   97.640006]  [<c11744c6>] ? __kfree_skb+0x6e/0x71
[   97.640006]  [<c11744c6>] ? __kfree_skb+0x6e/0x71
[   97.640006]  [<c11744c6>] __kfree_skb+0x6e/0x71
[   97.640006]  [<c11744f4>] consume_skb+0x2b/0x2d
[   97.640006]  [<f083cb92>] e100_rx_clean_list+0x46/0x75 [e100]
[   97.640006]  [<f083cfa3>] e100_down+0x7e/0x82 [e100]
[   97.640006]  [<f083d0ae>] e100_close+0xd/0x11 [e100]
[   97.640006]  [<c117bc18>] dev_close+0x77/0x98
[   97.640006]  [<c117bcb1>] rollback_registered+0x78/0x210
[   97.640006]  [<c117be7b>] unregister_netdevice+0x32/0x4d
[   97.640006]  [<c117bea8>] unregister_netdev+0x12/0x1a
[   97.640006]  [<f083de9d>] e100_remove+0x27/0x68 [e100]
[   97.640006]  [<c10fb01b>] pci_device_remove+0x19/0x39
[   97.640006]  [<c1146d62>] __device_release_driver+0x79/0xbd
[   97.640006]  [<c1146e0d>] driver_detach+0x67/0x85
[   97.640006]  [<c114630c>] bus_remove_driver+0x69/0x8f
[   97.640006]  [<c1147238>] driver_unregister+0x4d/0x54
[   97.640006]  [<c10fb1e0>] pci_unregister_driver+0x2d/0x69
[   97.640006]  [<f083de71>] e100_cleanup_module+0xd/0x12 [e100]
[   97.640006]  [<c1046ab3>] sys_delete_module+0x17d/0x1d6
[   97.640006]  [<c1002abc>] ? restore_all_notrace+0x0/0x18
[   97.640006]  [<c11cc096>] ? do_page_fault+0x0/0x234
[   97.640006]  [<c1002a08>] sysenter_do_call+0x12/0x36
[   97.640006] FIX skbuff_head_cache: Restoring 0xeebfee98-0xeebfee98=3D=
0x6b
[   97.640006]=20
[   97.640006] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
[   97.640006] BUG skbuff_head_cache: Poison overwritten
[   97.640006] --------------------------------------------------------=
---------------------
[   97.640006]=20
[   97.640006] INFO: 0xeebfef98-0xeebfef98. First byte 0x6c instead of =
0x6b
[   97.640006] INFO: Allocated in __alloc_skb+0x29/0x11a age=3D14234 cp=
u=3D0 pid=3D1835
[   97.640006] INFO: Freed in __kfree_skb+0x6e/0x71 age=3D10962 cpu=3D0=
 pid=3D2006
[   97.640006] INFO: Slab 0xc21f8f98 objects=3D16 used=3D0 fp=3D0xeebfe=
100 flags=3D0x40000082
[   97.640006] INFO: Object 0xeebfef00 @offset=3D3840 fp=3D0xeebfe500
[   97.640006]=20
[   97.640006] Bytes b4 0xeebfeef0:  5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5=
a 5a 5a 5a 5a ZZZZZZZZZZZZZZZZ
[   97.640006]   Object 0xeebfef00:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6=
b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[   97.640006]   Object 0xeebfef10:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6=
b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[   97.640006]   Object 0xeebfef20:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6=
b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[   97.640006]   Object 0xeebfef30:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6=
b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[   97.640006]   Object 0xeebfef40:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6=
b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[   97.640006]   Object 0xeebfef50:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6=
b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[   97.640006]   Object 0xeebfef60:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6=
b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[   97.640006]   Object 0xeebfef70:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6=
b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[   97.640006]   Object 0xeebfef80:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6=
b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[   97.640006]   Object 0xeebfef90:  6b 6b 6b 6b 6b 6b 6b 6b 6c 6b 6b a=
3             kkkkkkkklkk=A3   =20
[   97.640006]  Redzone 0xeebfef9c:  bb bb bb bb                       =
              =BB=BB=BB=BB           =20
[   97.640006]  Padding 0xeebfefc4:  5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5=
a 5a 5a 5a 5a ZZZZZZZZZZZZZZZZ
[   97.640006]  Padding 0xeebfefd4:  5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5=
a 5a 5a 5a 5a ZZZZZZZZZZZZZZZZ
[   97.640006]  Padding 0xeebfefe4:  5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5=
a 5a 5a 5a 5a ZZZZZZZZZZZZZZZZ
[   97.640006]  Padding 0xeebfeff4:  5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5=
a             ZZZZZZZZZZZZ   =20
[   97.640006] Pid: 2006, comm: rmmod Not tainted 2.6.32 #1
[   97.640006] Call Trace:
[   97.640006]  [<c106edbe>] print_trailer+0xff/0x107
[   97.640006]  [<c106ee47>] check_bytes_and_report+0x81/0xa4
[   97.640006]  [<c106ef3f>] check_object+0xa5/0x160
[   97.640006]  [<c106f05e>] __free_slab+0x64/0xf5
[   97.640006]  [<c106f12a>] discard_slab+0x3b/0x3e
[   97.640006]  [<c10704cc>] __slab_free+0x115/0x24b
[   97.640006]  [<c107198f>] kmem_cache_free+0x7b/0xa2
[   97.640006]  [<c11744c6>] ? __kfree_skb+0x6e/0x71
[   97.640006]  [<c11744c6>] ? __kfree_skb+0x6e/0x71
[   97.640006]  [<c11744c6>] __kfree_skb+0x6e/0x71
[   97.640006]  [<c11744f4>] consume_skb+0x2b/0x2d
[   97.640006]  [<f083cb92>] e100_rx_clean_list+0x46/0x75 [e100]
[   97.640006]  [<f083cfa3>] e100_down+0x7e/0x82 [e100]
[   97.640006]  [<f083d0ae>] e100_close+0xd/0x11 [e100]
[   97.640006]  [<c117bc18>] dev_close+0x77/0x98
[   97.640006]  [<c117bcb1>] rollback_registered+0x78/0x210
[   97.640006]  [<c117be7b>] unregister_netdevice+0x32/0x4d
[   97.640006]  [<c117bea8>] unregister_netdev+0x12/0x1a
[   97.640006]  [<f083de9d>] e100_remove+0x27/0x68 [e100]
[   97.640006]  [<c10fb01b>] pci_device_remove+0x19/0x39
[   97.640006]  [<c1146d62>] __device_release_driver+0x79/0xbd
[   97.640006]  [<c1146e0d>] driver_detach+0x67/0x85
[   97.640006]  [<c114630c>] bus_remove_driver+0x69/0x8f
[   97.640006]  [<c1147238>] driver_unregister+0x4d/0x54
[   97.640006]  [<c10fb1e0>] pci_unregister_driver+0x2d/0x69
[   97.640006]  [<f083de71>] e100_cleanup_module+0xd/0x12 [e100]
[   97.640006]  [<c1046ab3>] sys_delete_module+0x17d/0x1d6
[   97.640006]  [<c1002abc>] ? restore_all_notrace+0x0/0x18
[   97.640006]  [<c11cc096>] ? do_page_fault+0x0/0x234
[   97.640006]  [<c1002a08>] sysenter_do_call+0x12/0x36
[   97.640006] FIX skbuff_head_cache: Restoring 0xeebfef98-0xeebfef98=3D=
0x6b
[   97.640006]=20
[   97.732457] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
[   97.732603] BUG skbuff_head_cache: Poison overwritten
[   97.732691] --------------------------------------------------------=
---------------------
[   97.732694]=20
[   97.732906] INFO: 0xef903c98-0xef903c98. First byte 0x6c instead of =
0x6b
[   97.733012] INFO: Allocated in __alloc_skb+0x29/0x11a age=3D14258 cp=
u=3D0 pid=3D1869
[   97.733149] INFO: Freed in __kfree_skb+0x6e/0x71 age=3D10986 cpu=3D0=
 pid=3D2006
[   97.733244] INFO: Slab 0xc222349c objects=3D16 used=3D0 fp=3D0xef903=
d00 flags=3D0x40000082
[   97.733378] INFO: Object 0xef903c00 @offset=3D3072 fp=3D0x(null)
[   97.733380]=20
[   97.733547] Bytes b4 0xef903bf0:  5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5=
a 5a 5a 5a 5a ZZZZZZZZZZZZZZZZ
[   97.734296]   Object 0xef903c00:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6=
b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[   97.735045]   Object 0xef903c10:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6=
b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[   97.735792]   Object 0xef903c20:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6=
b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[   97.736022]   Object 0xef903c30:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6=
b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[   97.736022]   Object 0xef903c40:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6=
b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[   97.736022]   Object 0xef903c50:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6=
b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[   97.736022]   Object 0xef903c60:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6=
b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[   97.736022]   Object 0xef903c70:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6=
b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[   97.736022]   Object 0xef903c80:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6=
b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
[   97.736022]   Object 0xef903c90:  6b 6b 6b 6b 6b 6b 6b 6b 6c 6b 6b a=
3             kkkkkkkklkk=A3   =20
[   97.736022]  Redzone 0xef903c9c:  bb bb bb bb                       =
              =BB=BB=BB=BB           =20
[   97.736022]  Padding 0xef903cc4:  5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5=
a 5a 5a 5a 5a ZZZZZZZZZZZZZZZZ
[   97.736022]  Padding 0xef903cd4:  5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5=
a 5a 5a 5a 5a ZZZZZZZZZZZZZZZZ
[   97.736022]  Padding 0xef903ce4:  5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5=
a 5a 5a 5a 5a ZZZZZZZZZZZZZZZZ
[   97.736022]  Padding 0xef903cf4:  5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5=
a             ZZZZZZZZZZZZ   =20
[   97.736022] Pid: 2006, comm: rmmod Not tainted 2.6.32 #1
[   97.736022] Call Trace:
[   97.736022]  [<c106edbe>] print_trailer+0xff/0x107
[   97.736022]  [<c106ee47>] check_bytes_and_report+0x81/0xa4
[   97.736022]  [<c106ef3f>] check_object+0xa5/0x160
[   97.736022]  [<c106f05e>] __free_slab+0x64/0xf5
[   97.736022]  [<c106f12a>] discard_slab+0x3b/0x3e
[   97.736022]  [<c10704cc>] __slab_free+0x115/0x24b
[   97.736022]  [<c107198f>] kmem_cache_free+0x7b/0xa2
[   97.736022]  [<c11744c6>] ? __kfree_skb+0x6e/0x71
[   97.736022]  [<c11744c6>] ? __kfree_skb+0x6e/0x71
[   97.736022]  [<c11744c6>] __kfree_skb+0x6e/0x71
[   97.736022]  [<c11744f4>] consume_skb+0x2b/0x2d
[   97.736022]  [<f083cb92>] e100_rx_clean_list+0x46/0x75 [e100]
[   97.736022]  [<f083cfa3>] e100_down+0x7e/0x82 [e100]
[   97.736022]  [<f083d0ae>] e100_close+0xd/0x11 [e100]
[   97.736022]  [<c117bc18>] dev_close+0x77/0x98
[   97.736022]  [<c117bcb1>] rollback_registered+0x78/0x210
[   97.736022]  [<c117be7b>] unregister_netdevice+0x32/0x4d
[   97.736022]  [<c117bea8>] unregister_netdev+0x12/0x1a
[   97.736022]  [<f083de9d>] e100_remove+0x27/0x68 [e100]
[   97.736022]  [<c10fb01b>] pci_device_remove+0x19/0x39
[   97.736022]  [<c1146d62>] __device_release_driver+0x79/0xbd
[   97.736022]  [<c1146e0d>] driver_detach+0x67/0x85
[   97.736022]  [<c114630c>] bus_remove_driver+0x69/0x8f
[   97.736022]  [<c1147238>] driver_unregister+0x4d/0x54
[   97.736022]  [<c10fb1e0>] pci_unregister_driver+0x2d/0x69
[   97.736022]  [<f083de71>] e100_cleanup_module+0xd/0x12 [e100]
[   97.736022]  [<c1046ab3>] sys_delete_module+0x17d/0x1d6
[   97.736022]  [<c1002abc>] ? restore_all_notrace+0x0/0x18
[   97.736022]  [<c11cc096>] ? do_page_fault+0x0/0x234
[   97.736022]  [<c1002a08>] sysenter_do_call+0x12/0x36
[   97.736022] FIX skbuff_head_cache: Restoring 0xef903c98-0xef903c98=3D=
0x6b
[   97.736022]=20
[   98.020355] e100 0000:01:08.0: PCI INT A disabled

