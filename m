From: Alexander Beregalov <a.beregalov@gmail.com>
Subject: next-20081117: kernel freezes with netconsole enabled
Date: Wed, 19 Nov 2008 20:57:40 +0300
Message-ID: <20081119175740.GE12456@orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, mpm@selenic.com, satyam.sharma@gmail.com
Return-path: <linux-next-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi 

It is x86_64 SMP
The kernel freezes while transferring kernel log through netconsole,
SysRq does not work at that moment.
The kernel works fine without netconsole.

Here is lspci, then dmesg, config at the end.

00:00.0 Host bridge [0600]: Intel Corporation 5000X Chipset Memory Controller Hub [8086:25c0] (rev 12)
00:02.0 PCI bridge [0604]: Intel Corporation 5000 Series Chipset PCI Express x4 Port 2 [8086:25e2] (rev 12)
00:03.0 PCI bridge [0604]: Intel Corporation 5000 Series Chipset PCI Express x4 Port 3 [8086:25e3] (rev 12)
00:04.0 PCI bridge [0604]: Intel Corporation 5000 Series Chipset PCI Express x8 Port 4-5 [8086:25f8] (rev 12)
00:05.0 PCI bridge [0604]: Intel Corporation 5000 Series Chipset PCI Express x4 Port 5 [8086:25e5] (rev 12)
00:06.0 PCI bridge [0604]: Intel Corporation 5000 Series Chipset PCI Express x8 Port 6-7 [8086:25f9] (rev 12)
00:07.0 PCI bridge [0604]: Intel Corporation 5000 Series Chipset PCI Express x4 Port 7 [8086:25e7] (rev 12)
00:08.0 System peripheral [0880]: Intel Corporation 5000 Series Chipset DMA Engine [8086:1a38] (rev 12)
00:10.0 Host bridge [0600]: Intel Corporation 5000 Series Chipset FSB Registers [8086:25f0] (rev 12)
00:10.1 Host bridge [0600]: Intel Corporation 5000 Series Chipset FSB Registers [8086:25f0] (rev 12)
00:10.2 Host bridge [0600]: Intel Corporation 5000 Series Chipset FSB Registers [8086:25f0] (rev 12)
00:11.0 Host bridge [0600]: Intel Corporation 5000 Series Chipset Reserved Registers [8086:25f1] (rev 12)
00:13.0 Host bridge [0600]: Intel Corporation 5000 Series Chipset Reserved Registers [8086:25f3] (rev 12)
00:15.0 Host bridge [0600]: Intel Corporation 5000 Series Chipset FBD Registers [8086:25f5] (rev 12)
00:16.0 Host bridge [0600]: Intel Corporation 5000 Series Chipset FBD Registers [8086:25f6] (rev 12)
00:1c.0 PCI bridge [0604]: Intel Corporation 631xESB/632xESB/3100 Chipset PCI Express Root Port 1 [8086:2690] (rev 09)
00:1d.0 USB Controller [0c03]: Intel Corporation 631xESB/632xESB/3100 Chipset UHCI USB Controller #1 [8086:2688] (rev 09)
00:1d.1 USB Controller [0c03]: Intel Corporation 631xESB/632xESB/3100 Chipset UHCI USB Controller #2 [8086:2689] (rev 09)
00:1d.2 USB Controller [0c03]: Intel Corporation 631xESB/632xESB/3100 Chipset UHCI USB Controller #3 [8086:268a] (rev 09)
00:1d.3 USB Controller [0c03]: Intel Corporation 631xESB/632xESB/3100 Chipset UHCI USB Controller #4 [8086:268b] (rev 09)
00:1d.7 USB Controller [0c03]: Intel Corporation 631xESB/632xESB/3100 Chipset EHCI USB2 Controller [8086:268c] (rev 09)
00:1e.0 PCI bridge [0604]: Intel Corporation 82801 PCI Bridge [8086:244e] (rev d9)
00:1f.0 ISA bridge [0601]: Intel Corporation 631xESB/632xESB/3100 Chipset LPC Interface Controller [8086:2670] (rev 09)
00:1f.1 IDE interface [0101]: Intel Corporation 631xESB/632xESB IDE Controller [8086:269e] (rev 09)
01:00.0 RAID bus controller [0104]: LSI Logic / Symbios Logic MegaRAID SAS 1078 [1000:0060] (rev 04)
02:00.0 PCI bridge [0604]: Broadcom EPB PCI-Express to PCI-X Bridge [1166:0103] (rev c3)
03:00.0 Ethernet controller [0200]: Broadcom Corporation NetXtreme II BCM5708 Gigabit Ethernet [14e4:164c] (rev 12)
04:00.0 PCI bridge [0604]: Intel Corporation 6311ESB/6321ESB PCI Express Upstream Port [8086:3500] (rev 01)
04:00.3 PCI bridge [0604]: Intel Corporation 6311ESB/6321ESB PCI Express to PCI-X Bridge [8086:350c] (rev 01)
05:00.0 PCI bridge [0604]: Intel Corporation 6311ESB/6321ESB PCI Express Downstream Port E1 [8086:3510] (rev 01)
05:01.0 PCI bridge [0604]: Intel Corporation 6311ESB/6321ESB PCI Express Downstream Port E2 [8086:3514] (rev 01)
06:00.0 PCI bridge [0604]: Broadcom EPB PCI-Express to PCI-X Bridge [1166:0103] (rev c3)
07:00.0 Ethernet controller [0200]: Broadcom Corporation NetXtreme II BCM5708 Gigabit Ethernet [14e4:164c] (rev 12)
0e:0d.0 VGA compatible controller [0300]: ATI Technologies Inc ES1000 [1002:515e] (rev 02)


Dump from serial console:

 Linux-bzImage,setup=0x2a00,size=0x27e200]
 0.000000] BIOS EBDA/lowmem at: 0009f000/0009f000
 0.000000] Linux version 2.6.28-rc5-next-20081117 (alexb@localhost) (gcc version 4.3.2 (Gentoo 4.3.2 p1.0) ) #6 SMP PREEMPT Mon Nov 17 18:25:42 MSK 2008
 0.000000] Command line: root=/dev/sda2 ignore_loglevel console=ttyS0,9600 console=tty0 netconsole=@x.x.x.x/eth0,6666@y.y.y.y/08:00:20:ff:e6:ff
 0.000000] KERNEL supported cpus:
 0.000000]   Intel GenuineIntel
 0.000000]   AMD AuthenticAMD
 0.000000]   Centaur CentaurHauls
 0.000000] BIOS-provided physical RAM map:
 0.000000]  BIOS-e820: 0000000000000000 - 00000000000a0000 (usable)
 0.000000]  BIOS-e820: 0000000000100000 - 000000007fb50000 (usable)
 0.000000]  BIOS-e820: 000000007fb50000 - 000000007fb66000 (reserved)
 0.000000]  BIOS-e820: 000000007fb66000 - 000000007fb85c00 (ACPI data)
 0.000000]  BIOS-e820: 000000007fb85c00 - 0000000080000000 (reserved)
 0.000000]  BIOS-e820: 00000000e0000000 - 00000000f0000000 (reserved)
 0.000000]  BIOS-e820: 00000000fe000000 - 0000000100000000 (reserved)
 0.000000] debug: ignoring loglevel setting.
 0.000000] DMI 2.5 present.
 0.000000] last_pfn = 0x7fb50 max_arch_pfn = 0x3ffffffff
 0.000000] x86 PAT enabled: cpu 0, old 0x7040600070406, new 0x7010600070106
 0.000000] Scanning 2 areas for low memory corruption
 0.000000] modified physical RAM map:
 0.000000]  modified: 0000000000000000 - 0000000000001000 (usable)
 0.000000]  modified: 0000000000001000 - 0000000000006000 (reserved)
 0.000000]  modified: 0000000000006000 - 0000000000008000 (usable)
 0.000000]  modified: 0000000000008000 - 0000000000010000 (reserved)
 0.000000]  modified: 0000000000010000 - 0000000000093000 (usable)
 0.000000]  modified: 0000000000100000 - 000000007fb50000 (usable)
 0.000000]  modified: 000000007fb50000 - 000000007fb66000 (reserved)
 0.000000]  modified: 000000007fb66000 - 000000007fb85c00 (ACPI data)
 0.000000]  modified: 000000007fb85c00 - 0000000080000000 (reserved)
 0.000000]  modified: 00000000e0000000 - 00000000f0000000 (reserved)
 0.000000]  modified: 00000000fe000000 - 0000000100000000 (reserved)
 0.000000] init_memory_mapping: 0000000000000000-000000007fb50000
 0.000000]  0000000000 - 007fb50000 page 4k
 0.000000] kernel direct mapping tables up to 7fb50000 @ 106e000-146f000
 0.000000] last_map_addr: 7fb50000 end: 7fb50000
 0.000000] ACPI: RSDP 000F21C0, 0024 (r2 DELL  )
 0.000000] ACPI: XSDT 000F225C, 0084 (r1 DELL   PE_SC3          1 DELL        1)
 0.000000] ACPI: FACP 7FB83524, 00F4 (r3 DELL   PE_SC3          1 DELL        1)
 0.000000] ACPI: DSDT 7FB66000, 4974 (r1 DELL   PE_SC3          1 INTL 20050624)
 0.000000] ACPI: FACS 7FB85C00, 0040
 0.000000] ACPI: APIC 7FB83078, 0092 (r1 DELL   PE_SC3          1 DELL        1)
 0.000000] ACPI: SPCR 7FB83130, 0050 (r1 DELL   PE_SC3          1 DELL        1)
 0.000000] ACPI: HPET 7FB83184, 0038 (r1 DELL   PE_SC3          1 DELL        1)
 0.000000] ACPI: MCFG 7FB831C0, 003C (r1 DELL   PE_SC3          1 DELL        1)
 0.000000] ACPI: WD__ 7FB83200, 0134 (r1 DELL   PE_SC3          1 DELL        1)
 0.000000] ACPI: SLIC 7FB83338, 0024 (r1 DELL   PE_SC3          1 DELL        1)
 0.000000] ACPI: ERST 7FB6AAF4, 0210 (r1 DELL   PE_SC3          1 DELL        1)
 0.000000] ACPI: HEST 7FB6AD04, 027C (r1 DELL   PE_SC3          1 DELL        1)
 0.000000] ACPI: BERT 7FB6A974, 0030 (r1 DELL   PE_SC3          1 DELL        1)
 0.000000] ACPI: EINJ 7FB6A9A4, 0150 (r1 DELL   PE_SC3          1 DELL        1)
 0.000000] ACPI: TCPA 7FB834BC, 0064 (r1 DELL   PE_SC3          1 DELL        1)
 0.000000] ACPI: DMI detected: Dell PE 1950
 0.000000] ACPI: Local APIC address 0xfee00000
 0.000000] (5 early reservations) ==> bootmem [0000000000 - 007fb50000]
 0.000000]   #0 [0000000000 - 0000001000]   BIOS data page ==> [0000000000 - 0000001000]
 0.000000]   #1 [0000006000 - 0000008000]       TRAMPOLINE ==> [0000006000 - 0000008000]
 0.000000]   #2 [0000200000 - 000106d658]    TEXT DATA BSS ==> [0000200000 - 000106d658]
 0.000000]   #3 [000009f000 - 0000100000]    BIOS reserved ==> [000009f000 - 0000100000]
 0.000000]   #4 [000106e000 - 000146d000]          PGTABLE ==> [000106e000 - 000146d000]
 0.000000] found SMP MP-table at [ffff8800000fe710] 000fe710
 0.000000]  [ffffe20000000000-ffffe200033fffff] PMD -> [ffff880001600000-ffff8800049fffff] on node 0
 0.000000] Zone PFN ranges:
 0.000000]   DMA      0x00000000 -> 0x00001000
 0.000000]   DMA32    0x00001000 -> 0x00100000
 0.000000]   Normal   0x00100000 -> 0x00100000
 0.000000] Movable zone start PFN for each node
 0.000000] early_node_map[4] active PFN ranges
 0.000000]     0: 0x00000000 -> 0x00000001
 0.000000]     0: 0x00000006 -> 0x00000008
 0.000000]     0: 0x00000010 -> 0x00000093
 0.000000]     0: 0x00000100 -> 0x0007fb50
 0.000000] On node 0 totalpages: 522966
 0.000000]   DMA zone: 104 pages used for memmap
 0.000000]   DMA zone: 102 pages reserved
 0.000000]   DMA zone: 3768 pages, LIFO batch:0
 0.000000]   DMA32 zone: 13178 pages used for memmap
 0.000000]   DMA32 zone: 505814 pages, LIFO batch:31
 0.000000]   Normal zone: 0 pages used for memmap
 0.000000]   Movable zone: 0 pages used for memmap
 0.000000] ACPI: PM-Timer IO Port: 0x808
 0.000000] ACPI: Local APIC address 0xfee00000
 0.000000] ACPI: LAPIC (acpi_id[0x01] lapic_id[0x00] enabled)
 0.000000] ACPI: LAPIC (acpi_id[0x02] lapic_id[0x06] enabled)
 0.000000] ACPI: LAPIC (acpi_id[0x03] lapic_id[0x01] enabled)
 0.000000] ACPI: LAPIC (acpi_id[0x04] lapic_id[0x07] enabled)
 0.000000] ACPI: LAPIC (acpi_id[0x05] lapic_id[0x14] disabled)
 0.000000] ACPI: LAPIC (acpi_id[0x06] lapic_id[0x15] disabled)
 0.000000] ACPI: LAPIC (acpi_id[0x07] lapic_id[0x16] disabled)
 0.000000] ACPI: LAPIC (acpi_id[0x08] lapic_id[0x17] disabled)
 0.000000] ACPI: LAPIC_NMI (acpi_id[0xff] high edge lint[0x1])
 0.000000] ACPI: IOAPIC (id[0x08] address[0xfec00000] gsi_base[0])
 0.000000] IOAPIC[0]: apic_id 8, version 0, address 0xfec00000, GSI 0-23
 0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
 0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
 0.000000] ACPI: IRQ0 used by override.
 0.000000] ACPI: IRQ2 used by override.
 0.000000] ACPI: IRQ9 used by override.
 0.000000] ACPI: HPET id: 0x8086a201 base: 0xfed00000
 0.000000] Using ACPI (MADT) for SMP configuration information
 0.000000] SMP: Allowing 8 CPUs, 4 hotplug CPUs
 0.000000] Allocating PCI resources starting at 88000000 (gap: 80000000:60000000)
 0.000000] PERCPU: Allocating 1896448 bytes of per cpu data
 0.000000] NR_CPUS: 8, nr_cpu_ids: 8, nr_node_ids 1
 0.000000] Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 509582
 0.000000] Kernel command line: root=/dev/sda2 ignore_loglevel console=ttyS0,9600 console=tty0 netconsole=@x.x.x.x/eth0,6666@y.y.y.y/08:00:20:ff:e6:ff
 0.000000] Initializing CPU#0
 0.000000] Preemptible RCU implementation.
 0.000000] PID hash table entries: 4096 (order: 12, 32768 bytes)
 0.000000] Extended CMOS year: 2000
 0.000000] TSC: PIT calibration matches PMTIMER. 1 loops
 0.000000] Detected 2992.507 MHz processor.
 0.003333] Console: colour VGA+ 80x25
 0.003333] console [tty0] enabled
 0.003333] console [ttyS0] enabled
 0.003333] Lock dependency validator: Copyright (c) 2006 Red Hat, Inc., Ingo Molnar
 0.003333] ... MAX_LOCKDEP_SUBCLASSES:    8
 0.003333] ... MAX_LOCK_DEPTH:          48
 0.003333] ... MAX_LOCKDEP_KEYS:        8191
 0.003333] ... CLASSHASH_SIZE:           4096
 0.003333] ... MAX_LOCKDEP_ENTRIES:     8192
 0.003333] ... MAX_LOCKDEP_CHAINS:      16384
 0.003333] ... CHAINHASH_SIZE:          8192
 0.003333]  memory used by lock dependency info: 4351 kB
 0.003333]  per task-struct memory footprint: 2688 bytes
 0.003333] Dentry cache hash table entries: 262144 (order: 9, 2097152 bytes)
 0.003333] Inode-cache hash table entries: 131072 (order: 8, 1048576 bytes)
 0.003333] Checking aperture...
 0.003333] No AGP bridge found
 0.003333] Memory: 2000908k/2092352k available (3247k kernel code, 488k absent, 90244k reserved, 1839k data, 2128k init)
 0.003333] SLUB: Genslabs=12, HWalign=64, Order=0-3, MinObjects=0, CPUs=8, Nodes=1
 0.003333] hpet clockevent registered
 0.003333] HPET: 3 timers in total, 0 timers will be used for per-cpu timer
 0.003347] Calibrating delay loop (skipped), value calculated using timer frequency.. 5987.38 BogoMIPS (lpj=9975023)
 0.010111] Mount-cache hash table entries: 256
 0.014205] CPU: L1 I cache: 32K, L1 D cache: 32K
 0.020003] CPU: L2 cache: 4096K
 0.023339] CPU: Physical Processor ID: 0
 0.026670] CPU: Processor Core ID: 0
 0.030008] CPU0: Thermal monitoring enabled (TM1)
 0.033337] using mwait in idle threads.
 0.036689] ACPI: Core revision 20080926
 0.053538] Setting APIC routing to flat
 0.057024] ..TIMER: vector=0x30 apic1=0 pin1=2 apic2=-1 pin2=-1
 0.093498] CPU0: Intel(R) Xeon(R) CPU            5160  @ 3.00GHz stepping 0b
 0.111914] lockdep: fixing up alternatives.
 0.113416] Booting processor 1 APIC 0x6 ip 0x6000
 0.003333] Initializing CPU#1
 0.003333] Calibrating delay using timer specific routine.. 5987.43 BogoMIPS (lpj=9975091)
 0.003333] CPU: L1 I cache: 32K, L1 D cache: 32K
 0.003333] CPU: L2 cache: 4096K
 0.003333] CPU: Physical Processor ID: 3
 0.003333] CPU: Processor Core ID: 0
 0.003333] CPU1: Thermal monitoring enabled (TM2)
 0.003333] x86 PAT enabled: cpu 1, old 0x7040600070406, new 0x7010600070106
 0.211502] CPU1: Intel(R) Xeon(R) CPU            5160  @ 3.00GHz stepping 0b
 0.220015] checking TSC synchronization [CPU#0 -> CPU#1]: passed.
 0.223534] lockdep: fixing up alternatives.
 0.230044] Booting processor 2 APIC 0x1 ip 0x6000
 0.003333] Initializing CPU#2
 0.003333] Calibrating delay using timer specific routine.. 5987.41 BogoMIPS (lpj=9975066)
 0.003333] CPU: L1 I cache: 32K, L1 D cache: 32K
 0.003333] CPU: L2 cache: 4096K
 0.003333] CPU: Physical Processor ID: 0
 0.003333] CPU: Processor Core ID: 1
 0.003333] CPU2: Thermal monitoring enabled (TM2)
 0.003333] x86 PAT enabled: cpu 2, old 0x7040600070406, new 0x7010600070106
 0.328160] CPU2: Intel(R) Xeon(R) CPU            5160  @ 3.00GHz stepping 0b
 0.336681] checking TSC synchronization [CPU#0 -> CPU#2]: passed.
 0.340229] lockdep: fixing up alternatives.
 0.343371] Booting processor 3 APIC 0x7 ip 0x6000
 0.003333] Initializing CPU#3
 0.003333] Calibrating delay using timer specific routine.. 5987.41 BogoMIPS (lpj=9975067)
 0.003333] CPU: L1 I cache: 32K, L1 D cache: 32K
 0.003333] CPU: L2 cache: 4096K
 0.003333] CPU: Physical Processor ID: 3
 0.003333] CPU: Processor Core ID: 1
 0.003333] CPU3: Thermal monitoring enabled (TM2)
 0.003333] x86 PAT enabled: cpu 3, old 0x7040600070406, new 0x7010600070106
 0.441523] CPU3: Intel(R) Xeon(R) CPU            5160  @ 3.00GHz stepping 0b
 0.450013] checking TSC synchronization [CPU#0 -> CPU#3]: passed.
 0.453346] Brought up 4 CPUs
 0.456669] Total of 4 processors activated (23949.65 BogoMIPS).
 0.463561] khelper used greatest stack depth: 5712 bytes left
 0.473709] net_namespace: 744 bytes
 0.473941] NET: Registered protocol family 16
 0.630100] ACPI FADT declares the system doesn't support PCIe ASPM, so disable it
 0.633352] ACPI: bus type pci registered
 0.636706] PCI: MCFG configuration 0: base e0000000 segment 0 buses 0 - 255
 0.640002] PCI: MCFG area at e0000000 reserved in E820
 0.653354] PCI: Using MMCONFIG at e0000000 - efffffff
 0.656667] PCI: Using configuration type 1 for base access
 0.660001] PCI: Dell PowerEdge 1950 detected, enabling pci=bfsort.
 0.684806] ACPI: EC: Look up EC in DSDT
 0.698999] ACPI: BIOS _OSI(Linux) query ignored via DMI
 0.703334] ACPI: Interpreter enabled
 0.706667] ACPI: (supports S0 S5)
 0.716667] ACPI: Using IOAPIC for interrupt routing
 0.740559] ACPI: No dock devices found.
 0.747109] ACPI: PCI Root Bridge [PCI0] (0000:00)
 0.750177] pci 0000:00:00.0: PME# supported from D0 D3hot D3cold
 0.753337] pci 0000:00:00.0: PME# disabled
 0.756751] pci 0000:00:02.0: PME# supported from D0 D3hot D3cold
 0.760003] pci 0000:00:02.0: PME# disabled
 0.763397] pci 0000:00:03.0: PME# supported from D0 D3hot D3cold
 0.766669] pci 0000:00:03.0: PME# disabled
 0.770063] pci 0000:00:04.0: PME# supported from D0 D3hot D3cold
 0.773336] pci 0000:00:04.0: PME# disabled
 0.776728] pci 0000:00:05.0: PME# supported from D0 D3hot D3cold
 0.780003] pci 0000:00:05.0: PME# disabled
 0.783396] pci 0000:00:06.0: PME# supported from D0 D3hot D3cold
 0.786669] pci 0000:00:06.0: PME# disabled
 0.790061] pci 0000:00:07.0: PME# supported from D0 D3hot D3cold
 0.793336] pci 0000:00:07.0: PME# disabled
 0.796717] pci 0000:00:08.0: reg 10 64bit mmio: [0xfc500400-0xfc5007ff]
 0.800032] pci 0000:00:08.0: PME# supported from D0 D3hot D3cold
 0.803336] pci 0000:00:08.0: PME# disabled
 0.807135] pci 0000:00:1c.0: PME# supported from D0 D3hot D3cold
 0.810003] pci 0000:00:1c.0: PME# disabled
 0.813428] pci 0000:00:1d.0: reg 20 io port: [0xcce0-0xccff]
 0.816740] pci 0000:00:1d.1: reg 20 io port: [0xccc0-0xccdf]
 0.820072] pci 0000:00:1d.2: reg 20 io port: [0xcca0-0xccbf]
 0.823406] pci 0000:00:1d.3: reg 20 io port: [0xcc80-0xcc9f]
 0.826745] pci 0000:00:1d.7: reg 10 32bit mmio: [0xfc500000-0xfc5003ff]
 0.830054] pci 0000:00:1d.7: PME# supported from D0 D3hot D3cold
 0.833337] pci 0000:00:1d.7: PME# disabled
 0.836846] pci 0000:00:1f.1: reg 10 io port: [0x00-0x07]
 0.840007] pci 0000:00:1f.1: reg 14 io port: [0x00-0x03]
 0.843341] pci 0000:00:1f.1: reg 18 io port: [0x00-0x07]
 0.846673] pci 0000:00:1f.1: reg 1c io port: [0x00-0x03]
 0.850007] pci 0000:00:1f.1: reg 20 io port: [0xfc00-0xfc0f]
 0.854757] pci 0000:04:00.0: PME# supported from D0 D3hot D3cold
 0.856714] pci 0000:04:00.0: PME# disabled
 0.863696] pci 0000:04:00.3: PME# supported from D0 D3hot D3cold
 0.866714] pci 0000:04:00.3: PME# disabled
 0.873984] pci 0000:00:02.0: bridge 32bit mmio: [0xf2000000-0xf7ffffff]
 0.878280] pci 0000:05:00.0: PME# supported from D0 D3hot D3cold
 0.880047] pci 0000:05:00.0: PME# disabled
 0.887304] pci 0000:05:01.0: PME# supported from D0 D3hot D3cold
 0.890048] pci 0000:05:01.0: PME# disabled
 0.895308] pci 0000:04:00.0: bridge 32bit mmio: [0xf4000000-0xf7ffffff]
 0.900821] pci 0000:06:00.0: PME# supported from D0 D3hot D3cold
 0.903381] pci 0000:06:00.0: PME# disabled
 0.908733] pci 0000:05:00.0: bridge 32bit mmio: [0xf4000000-0xf7ffffff]
 0.914614] pci 0000:07:00.0: reg 10 64bit mmio: [0xf4000000-0xf5ffffff]
 0.917908] pci 0000:07:00.0: PME# supported from D3hot D3cold
 0.920048] pci 0000:07:00.0: PME# disabled
 0.927809] pci 0000:06:00.0: bridge 32bit mmio: [0xf4000000-0xf7ffffff]
 0.936590] pci 0000:01:00.0: reg 10 64bit mmio: [0xfc480000-0xfc4bffff]
 0.936675] pci 0000:01:00.0: reg 18 io port: [0xec00-0xecff]
 0.940013] pci 0000:01:00.0: reg 1c 64bit mmio: [0xfc440000-0xfc47ffff]
 0.943347] pci 0000:01:00.0: reg 30 32bit mmio: [0xfc300000-0xfc307fff]
 0.946687] pci 0000:01:00.0: supports D1
 0.950071] pci 0000:00:03.0: bridge io port: [0xe000-0xefff]
 0.953336] pci 0000:00:03.0: bridge 32bit mmio: [0xfc300000-0xfc4fffff]
 0.957054] pci 0000:02:00.0: PME# supported from D0 D3hot D3cold
 0.960004] pci 0000:02:00.0: PME# disabled
 0.963408] pci 0000:00:1c.0: bridge 32bit mmio: [0xf8000000-0xfbffffff]
 0.966764] pci 0000:03:00.0: reg 10 64bit mmio: [0xf8000000-0xf9ffffff]
 0.970057] pci 0000:03:00.0: PME# supported from D3hot D3cold
 0.973337] pci 0000:03:00.0: PME# disabled
 0.976756] pci 0000:02:00.0: bridge 32bit mmio: [0xf8000000-0xfbffffff]
 0.983417] pci 0000:0e:0d.0: reg 10 32bit mmio: [0xd8000000-0xdfffffff]
 0.986674] pci 0000:0e:0d.0: reg 14 io port: [0xdc00-0xdcff]
 0.990007] pci 0000:0e:0d.0: reg 18 32bit mmio: [0xfc2d0000-0xfc2dffff]
 0.993363] pci 0000:0e:0d.0: reg 30 32bit mmio: [0x000000-0x01ffff]
 0.996678] pci 0000:0e:0d.0: supports D1 D2
 1.000042] pci 0000:00:1e.0: transparent bridge
 1.003336] pci 0000:00:1e.0: bridge io port: [0xd000-0xdfff]
 1.006670] pci 0000:00:1e.0: bridge 32bit mmio: [0xfc100000-0xfc2fffff]
 1.010006] pci 0000:00:1e.0: bridge 64bit mmio pref: [0xd8000000-0xdfffffff]
 1.013381] bus 00 -> node 0
 1.016679] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0._PRT]
 1.026410] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PEX2._PRT]
 1.030459] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PEX2.UPST._PRT]
 1.034162] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PEX2.UPST.DWN1._PRT]
 1.040301] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PEX2.UPST.DWN2._PRT]
 1.044701] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PEX3._PRT]
 1.048029] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PEX3.PE2P._PRT]
 1.051092] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PEX4._PRT]
 1.054689] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PEX6._PRT]
 1.058022] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.SBEX._PRT]
 1.061358] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.COMP._PRT]
 1.090372] ACPI: PCI Interrupt Link [LK00] (IRQs 3 4 5 6 7 10 *11 12)
 1.117048] ACPI: PCI Interrupt Link [LK01] (IRQs 3 4 5 6 7 10 11 12) *0, disabled.
 1.149189] ACPI: PCI Interrupt Link [LK02] (IRQs 3 4 5 6 7 10 11 12) *0, disabled.
 1.179192] ACPI: PCI Interrupt Link [LK03] (IRQs 3 4 *5 6 7 10 11 12)
 1.203712] ACPI: PCI Interrupt Link [LK04] (IRQs 3 4 5 *6 7 10 11 12)
 1.233715] ACPI: PCI Interrupt Link [LK05] (IRQs 3 4 5 6 7 *10 11 12)
 1.262516] ACPI: PCI Interrupt Link [LK06] (IRQs 3 4 5 6 7 10 11 12) *0, disabled.
 1.293704] ACPI: PCI Interrupt Link [LK07] (IRQs 3 4 5 6 7 10 11 12) *0, disabled.
 1.330496] SCSI subsystem initialized
 1.333387] libata version 3.00 loaded.
 1.336768] usbcore: registered new interface driver usbfs
 1.340063] usbcore: registered new interface driver hub
 1.343398] usbcore: registered new device driver usb
 1.346794] dca service started, version 1.4
 1.350063] PCI: Using ACPI for IRQ routing
 1.373536] PCI-GART: No AMD GART found.
 1.376691] hpet0: at MMIO 0xfed00000, IRQs 2, 8, 0
 1.392144] hpet0: 3 comparators, 64-bit 14.318180 MHz counter
 1.403345] Switched to high resolution mode on CPU 0
 1.405443] Switched to high resolution mode on CPU 2
 1.406079] Switched to high resolution mode on CPU 1
 1.406499] Switched to high resolution mode on CPU 3
 1.683403] pnp: PnP ACPI init
 1.719917] ACPI: bus type pnp registered
 1.782048] pnp: PnP ACPI: found 12 devices
 1.832056] ACPI: ACPI bus type pnp unregistered
 1.887292] system 00:08: ioport range 0x800-0x87f has been reserved
 1.963299] system 00:08: ioport range 0x880-0x8bf has been reserved
 2.039306] system 00:08: ioport range 0x8c0-0x8df has been reserved
 2.115311] system 00:08: ioport range 0x8e0-0x8e3 has been reserved
 2.191315] system 00:08: ioport range 0x900-0x900 has been reserved
 2.267323] system 00:08: ioport range 0xc00-0xc7f has been reserved
 2.343330] system 00:08: ioport range 0xca0-0xca7 has been reserved
 2.419342] system 00:08: ioport range 0xca9-0xcab has been reserved
 2.495353] system 00:08: ioport range 0xcad-0xcaf has been reserved
 2.571376] system 00:09: ioport range 0xca8-0xca8 has been reserved
 2.647379] system 00:09: ioport range 0xcac-0xcac has been reserved
 2.723395] system 00:0a: iomem range 0xe0000000-0xefffffff has been reserved
 2.816463] pci 0000:06:00.0: PCI bridge, secondary bus 0000:07
 2.887267] pci 0000:06:00.0:   IO window: disabled
 2.945685] pci 0000:06:00.0:   MEM window: 0xf4000000-0xf7ffffff
 3.018615] pci 0000:06:00.0:   PREFETCH window: disabled
 3.083316] pci 0000:05:00.0: PCI bridge, secondary bus 0000:06
 3.154119] pci 0000:05:00.0:   IO window: disabled
 3.212535] pci 0000:05:00.0:   MEM window: 0xf4000000-0xf7ffffff
 3.285466] pci 0000:05:00.0:   PREFETCH window: disabled
 3.350166] pci 0000:05:01.0: PCI bridge, secondary bus 0000:08
 3.420969] pci 0000:05:01.0:   IO window: disabled
 3.479384] pci 0000:05:01.0:   MEM window: disabled
 3.538796] pci 0000:05:01.0:   PREFETCH window: disabled
 3.603496] pci 0000:04:00.0: PCI bridge, secondary bus 0000:05
 3.674295] pci 0000:04:00.0:   IO window: disabled
 3.732708] pci 0000:04:00.0:   MEM window: 0xf4000000-0xf7ffffff
 3.805637] pci 0000:04:00.0:   PREFETCH window: disabled
 3.870338] pci 0000:04:00.3: PCI bridge, secondary bus 0000:09
 3.941139] pci 0000:04:00.3:   IO window: disabled
 3.999550] pci 0000:04:00.3:   MEM window: disabled
 4.058960] pci 0000:04:00.3:   PREFETCH window: disabled
 4.123661] pci 0000:00:02.0: PCI bridge, secondary bus 0000:04
 4.194463] pci 0000:00:02.0:   IO window: disabled
 4.252785] pci 0000:00:02.0:   MEM window: 0xf2000000-0xf7ffffff
 4.325668] pci 0000:00:02.0:   PREFETCH window: disabled
 4.390235] pci 0000:00:03.0: PCI bridge, secondary bus 0000:01
 4.461037] pci 0000:00:03.0:   IO window: 0xe000-0xefff
 4.524568] pci 0000:00:03.0:   MEM window: 0xfc300000-0xfc4fffff
 4.597452] pci 0000:00:03.0:   PREFETCH window: disabled
 4.662018] pci 0000:00:04.0: PCI bridge, secondary bus 0000:0a
 4.732819] pci 0000:00:04.0:   IO window: disabled
 4.791140] pci 0000:00:04.0:   MEM window: disabled
 4.850503] pci 0000:00:04.0:   PREFETCH window: disabled
 4.915072] pci 0000:00:05.0: PCI bridge, secondary bus 0000:0b
 4.985875] pci 0000:00:05.0:   IO window: disabled
 5.044204] pci 0000:00:05.0:   MEM window: disabled
 5.103568] pci 0000:00:05.0:   PREFETCH window: disabled
 5.168135] pci 0000:00:06.0: PCI bridge, secondary bus 0000:0c
 5.238941] pci 0000:00:06.0:   IO window: disabled
 5.297260] pci 0000:00:06.0:   MEM window: disabled
 5.356624] pci 0000:00:06.0:   PREFETCH window: disabled
 5.421191] pci 0000:00:07.0: PCI bridge, secondary bus 0000:0d
 5.491991] pci 0000:00:07.0:   IO window: disabled
 5.550311] pci 0000:00:07.0:   MEM window: disabled
 5.609675] pci 0000:00:07.0:   PREFETCH window: disabled
 5.674243] pci 0000:02:00.0: PCI bridge, secondary bus 0000:03
 5.745041] pci 0000:02:00.0:   IO window: disabled
 5.803364] pci 0000:02:00.0:   MEM window: 0xf8000000-0xfbffffff
 5.876248] pci 0000:02:00.0:   PREFETCH window: disabled
 5.946972] pci 0000:00:1c.0: PCI bridge, secondary bus 0000:02
 6.017775] pci 0000:00:1c.0:   IO window: disabled
 6.076097] pci 0000:00:1c.0:   MEM window: 0xf8000000-0xfbffffff
 6.148980] pci 0000:00:1c.0:   PREFETCH window: disabled
 6.213551] pci 0000:00:1e.0: PCI bridge, secondary bus 0000:0e
 6.284353] pci 0000:00:1e.0:   IO window: 0xd000-0xdfff
 6.347880] pci 0000:00:1e.0:   MEM window: 0xfc100000-0xfc2fffff
 6.420765] pci 0000:00:1e.0:   PREFETCH window: 0x000000d8000000-0x000000dfffffff
 6.511370] pci 0000:00:02.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
 6.591539] pci 0000:00:02.0: setting latency timer to 64
 6.656195] vendor=8086 device=25e2
 6.697875] pci 0000:04:00.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
 6.778087] pci 0000:04:00.0: setting latency timer to 64
 6.842789] vendor=8086 device=3500
 6.884463] vendor=8086 device=25e2
 6.926140] pci 0000:05:00.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
 7.006352] pci 0000:05:00.0: setting latency timer to 64
 7.071147] pci 0000:06:00.0: setting latency timer to 64
 7.135848] vendor=8086 device=3500
 7.177526] vendor=8086 device=25e2
 7.219207] pci 0000:05:01.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
 7.299417] pci 0000:05:01.0: setting latency timer to 64
 7.364212] pci 0000:04:00.3: setting latency timer to 64
 7.428779] pci 0000:00:03.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
 7.508944] pci 0000:00:03.0: setting latency timer to 64
 7.573514] pci 0000:00:04.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
 7.653680] pci 0000:00:04.0: setting latency timer to 64
 7.718250] pci 0000:00:05.0: setting latency timer to 64
 7.782821] pci 0000:00:06.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
 7.862988] pci 0000:00:06.0: setting latency timer to 64
 7.927555] pci 0000:00:07.0: setting latency timer to 64
 7.992128] pci 0000:00:1c.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
 8.072292] pci 0000:00:1c.0: setting latency timer to 64
 8.136867] pci 0000:02:00.0: setting latency timer to 64
 8.201439] pci 0000:00:1e.0: setting latency timer to 64
 8.266005] bus: 00 index 0 io port: [0x00-0xffff]
 8.323287] bus: 00 index 1 mmio: [0x000000-0xffffffffffffffff]
 8.394092] bus: 04 index 0 mmio: [0x0-0x0]
 8.444087] bus: 04 index 1 mmio: [0xf2000000-0xf7ffffff]
 8.508650] bus: 04 index 2 mmio: [0x0-0x0]
 8.558651] bus: 04 index 3 mmio: [0x0-0x0]
 8.608649] bus: 05 index 0 mmio: [0x0-0x0]
 8.658646] bus: 05 index 1 mmio: [0xf4000000-0xf7ffffff]
 8.723204] bus: 05 index 2 mmio: [0x0-0x0]
 8.773202] bus: 05 index 3 mmio: [0x0-0x0]
 8.823200] bus: 06 index 0 mmio: [0x0-0x0]
 8.873199] bus: 06 index 1 mmio: [0xf4000000-0xf7ffffff]
 8.937763] bus: 06 index 2 mmio: [0x0-0x0]
 8.987760] bus: 06 index 3 mmio: [0x0-0x0]
 9.037758] bus: 07 index 0 mmio: [0x0-0x0]
 9.087755] bus: 07 index 1 mmio: [0xf4000000-0xf7ffffff]
 9.152316] bus: 07 index 2 mmio: [0x0-0x0]
 9.202311] bus: 07 index 3 mmio: [0x0-0x0]
 9.252309] bus: 08 index 0 mmio: [0x0-0x0]
 9.302307] bus: 08 index 1 mmio: [0x0-0x0]
 9.352305] bus: 08 index 2 mmio: [0x0-0x0]
 9.402303] bus: 08 index 3 mmio: [0x0-0x0]
 9.452300] bus: 09 index 0 mmio: [0x0-0x0]
 9.502300] bus: 09 index 1 mmio: [0x0-0x0]
 9.552296] bus: 09 index 2 mmio: [0x0-0x0]
 9.602294] bus: 09 index 3 mmio: [0x0-0x0]
 9.652292] bus: 01 index 0 io port: [0xe000-0xefff]
 9.711649] bus: 01 index 1 mmio: [0xfc300000-0xfc4fffff]
 9.776209] bus: 01 index 2 mmio: [0x0-0x0]
 9.826205] bus: 01 index 3 mmio: [0x0-0x0]
 9.876203] bus: 0a index 0 mmio: [0x0-0x0]
 9.926201] bus: 0a index 1 mmio: [0x0-0x0]
 9.976199] bus: 0a index 2 mmio: [0x0-0x0]
10.026198] bus: 0a index 3 mmio: [0x0-0x0]
10.076196] bus: 0b index 0 mmio: [0x0-0x0]
10.126194] bus: 0b index 1 mmio: [0x0-0x0]
10.176193] bus: 0b index 2 mmio: [0x0-0x0]
10.226189] bus: 0b index 3 mmio: [0x0-0x0]
10.276187] bus: 0c index 0 mmio: [0x0-0x0]
10.326185] bus: 0c index 1 mmio: [0x0-0x0]
10.376183] bus: 0c index 2 mmio: [0x0-0x0]
10.426181] bus: 0c index 3 mmio: [0x0-0x0]
10.476179] bus: 0d index 0 mmio: [0x0-0x0]
10.526180] bus: 0d index 1 mmio: [0x0-0x0]
10.576180] bus: 0d index 2 mmio: [0x0-0x0]
10.626178] bus: 0d index 3 mmio: [0x0-0x0]
10.676177] bus: 02 index 0 mmio: [0x0-0x0]
10.726173] bus: 02 index 1 mmio: [0xf8000000-0xfbffffff]
10.790733] bus: 02 index 2 mmio: [0x0-0x0]
10.840730] bus: 02 index 3 mmio: [0x0-0x0]
10.890728] bus: 03 index 0 mmio: [0x0-0x0]
10.940726] bus: 03 index 1 mmio: [0xf8000000-0xfbffffff]
11.005291] bus: 03 index 2 mmio: [0x0-0x0]
11.055288] bus: 03 index 3 mmio: [0x0-0x0]
11.105285] bus: 0e index 0 io port: [0xd000-0xdfff]
11.164643] bus: 0e index 1 mmio: [0xfc100000-0xfc2fffff]
11.229204] bus: 0e index 2 mmio: [0xd8000000-0xdfffffff]
11.293767] bus: 0e index 3 io port: [0x00-0xffff]
11.351043] bus: 0e index 4 mmio: [0x000000-0xffffffffffffffff]
11.421870] NET: Registered protocol family 2
11.593570] IP route cache hash table entries: 65536 (order: 7, 524288 bytes)
11.679685] TCP established hash table entries: 262144 (order: 10, 4194304 bytes)
11.771214] TCP bind hash table entries: 32768 (order: 9, 2359296 bytes)
11.854535] TCP: Hash tables configured (established 262144 bind 32768)
11.933700] TCP reno registered
12.013912] NET: Registered protocol family 1
12.076062] Scanning for low memory corruption every 60 seconds
12.188209] Installing knfsd (copyright (C) 1996 okir@monad.swb.de).
12.265327] SGI XFS with security attributes, large block/inode numbers, no debug enabled
12.370452] msgmni has been set to 3909
12.417165] io scheduler noop registered
12.464800] io scheduler cfq registered (default)
12.521851] pci 0000:0e:0d.0: Boot video device
12.576745] pcieport-driver 0000:00:02.0: setting latency timer to 64
12.654172] pcieport-driver 0000:00:02.0: found MSI capability
12.723993] pcieport-driver 0000:00:02.0: irq 47 for MSI/MSI-capability
14.914381] pcieport-driver 0000:00:1c.0: irq 41 for MSI/MSI-X
14.984168] pci_express 0000:00:1c.0:pcie00: allocate port service
15.058283] pci_express 0000:00:1c.0:pcie03: allocate port service
15.132797] pcieport-driver 0000:04:00.0: setting latency timer to 64
15.211223] pci_express 0000:04:00.0:pcie11: allocate port service
15.287468] pcieport-driver 0000:05:00.0: setting latency timer to 64
15.365851] pcieport-driver 0000:05:00.0: found MSI capability
15.436538] pcieport-driver 0000:05:00.0: irq 40 for MSI/MSI-X
15.506678] pci_express 0000:05:00.0:pcie21: allocate port service
15.582824] pcieport-driver 0000:05:01.0: setting latency timer to 64
15.661208] pcieport-driver 0000:05:01.0: found MSI capability
15.731892] pcieport-driver 0000:05:01.0: irq 39 for MSI/MSI-X
15.802029] pci_express 0000:05:01.0:pcie21: allocate port service
15.880442] aer 0000:00:02.0:pcie01: service driver aer loaded
15.952169] aer 0000:00:03.0:pcie01: service driver aer loaded
16.023897] aer 0000:00:04.0:pcie01: service driver aer loaded
16.095598] aer 0000:00:05.0:pcie01: service driver aer loaded
16.167301] aer 0000:00:06.0:pcie01: service driver aer loaded
16.238987] aer 0000:00:07.0:pcie01: service driver aer loaded
16.327636] Non-volatile memory driver v1.2
16.378065] intel_rng: FWH not detected
16.424439] Linux agpgart interface v0.103
16.473629] Hangcheck: starting hangcheck timer 0.9.0 (tick is 180 seconds, margin is 60 seconds).
16.580866] Hangcheck: Using get_cycles().
16.629830] Serial: 8250/16550 driver4 ports, IRQ sharing disabled
16.704141] serial8250: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
16.776402] serial8250: ttyS1 at I/O 0x2f8 (irq = 3) is a 16550A
16.849801] 00:06: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
16.917094] 00:07: ttyS1 at I/O 0x2f8 (irq = 3) is a 16550A
16.989308] loop: module loaded
17.026894] Broadcom NetXtreme II Gigabit Ethernet Driver bnx2 v1.8.2 (Nov 10, 2008)
17.119585] vendor=8086 device=2690
17.161266] bnx2 0000:03:00.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
17.243602] eth0: Broadcom NetXtreme II BCM5708 1000Base-T (B2) PCI-X 64-bit 133MHz found at mem f8000000, IRQ 16, node addr 00:1e:c9:ae:bf:dd
17.403023] vendor=8086 device=3510
17.444705] vendor=8086 device=3500
17.486381] vendor=8086 device=25e2
17.528061] bnx2 0000:07:00.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
17.613121] eth1: Broadcom NetXtreme II BCM5708 1000Base-T (B2) PCI-X 64-bit 133MHz found at mem f4000000, IRQ 16, node addr 00:1e:c9:ae:bf:df
17.766313] netconsole: local port 6665
17.812163] netconsole: local IP x.x.x.x
17.866324] netconsole: interface eth0
17.911123] netconsole: remote port 6666
17.958000] netconsole: remote IP y.y.y.y
18.013205] netconsole: remote ethernet address 08:00:20:ff:e6:ff
18.086098] netconsole: device eth0 not up yet, forcing it
18.151827] bnx2 0000:03:00.0: irq 38 for MSI/MSI-X
18.323353] bnx2: eth0: using MSI
21.541683] bnx2: eth0 NIC Copper Link is Up, 1000 Mbps full duplex, receive & transmit flow control ON
21.687619] console [netcon0] enabled

<....>

 0.796717] pci 0000:00:08.0: reg 10 64bit mmio: [0xfc500400-0xfc5007ff]
 0.800032] pci 0000:00:08.0: PME# supported from D0 D3hot D3cold
 0.803336] pci 0000:00:08.0: PME# disabled
 0.807135] pci 0000:00:1c.0: PME# supported from D0 D3hot D3cold
 0.810003] pci 0000:00:1c.0: PME# disabled
 0.813428] pci 0000:00:1d.0: reg 20 io port: [0xcce0-0xccff]
 0.816740] pci 0000:00:1d.1: reg 20 io port: [0xccc0-0xccdf]
 0.820072] pci 0000:00:1d.2: reg 20 io port: [0xcca0-0xccbf]
 0.823406] pci 0000:00:1d.3: reg 20 io port: [0xcc80-0xcc9f]
 0.826745] pci 0000:00:1d.7: reg 10 32bit mmio: [0xfc500000-0xfc5003ff]
 0.830054] pci 0000:00:1d.7: PME# supported from D0 D3hot D3cold
 0.833337] pci 0000:00:1d.7: PME# disabled
 0.836846] pci 0000:00:1f.1: reg 10 io port: [0x00-0x07]
 0.840007] pci 0000:00:1f.1: reg 14 io port: [0x00-0x03]
 0.843341] pci 0000:00:1f.1: reg 18 io port: [0x00-0x07]
 0.846673] pci 0000:00:1f.1: reg 1c io port: [0x00-0x03]
 0.850007] pci 0000:00:1f.1: reg 20 io port: [0xfc00-0xfc0f]
 0.854757] pci 0000:04:00.0: PME# supported from D0 D3hot D3cold
 0.856714] pci 0000:04:00.0: PME# disabled
 0.863696] pci 0000:04:00.3: PME# supported from D0 D3hot D3cold
 0.866714] pci 0000:04:00.3: PME# disabled
 0.873984] pci 0000:00:02.0: bridge 32bit mmio: [0xf2000000-0xf7ffffff]
 0.878280] pci 0000:05:00.0: PME# supported from D0 D3hot D3cold
 0.880047] pci 0000:05:00.0: PME# disabled
 0.887304] pci 0000:05:01.0: PME# supported from D0 D3hot D3cold
 0.890048] pci 0000:05:01.0: PME# disabled

<< Kernel freezes while transfer process is somewhere here >>

-----
Here is further dump from kernel after netconsole was loaded but not initialized.

megasas: 00.00.04.01 Thu July 24 11:41:51 PST 2008
megasas: 0x1000:0x0060:0x1028:0x1f0c: bus 1:slot 0:func 0
vendor=8086 device=25e3
megaraid_sas 0000:01:00.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
megaraid_sas 0000:01:00.0: setting latency timer to 64
megasas: FW now in Ready state
scsi0 : LSI SAS based MegaRAID driver
Driver 'sd' needs updating - please use bus_type methods
scsi 0:0:0:0: Direct-Access     ATA      SAMSUNG HE160HJ  0-24 PQ: 0 ANSI: 5
scsi 0:0:1:0: Direct-Access     ATA      SAMSUNG HE160HJ  0-24 PQ: 0 ANSI: 5
Driver 'sr' needs updating - please use bus_type methods
ata_piix 0000:00:1f.1: version 2.12
ata_piix 0000:00:1f.1: PCI INT A -> GSI 16 (level, low) -> IRQ 16
ata_piix 0000:00:1f.1: setting latency timer to 64
scsi1 : ata_piix
scsi2 : ata_piix
ata1: PATA max UDMA/100 cmd 0x1f0 ctl 0x3f6 bmdma 0xfc00 irq 14
ata2: PATA max UDMA/100 cmd 0x170 ctl 0x376 bmdma 0xfc08 irq 15
ata1.00: ATAPI: HL-DT-ST  GCR-8240N, 1.10, max UDMA/33
ata1.00: configured for UDMA/33
ata2: port disabled. ignoring.
scsi: waiting for bus probes to complete ...
scsi 0:0:32:0: Enclosure         DP       BACKPLANE        1.05 PQ: 0 ANSI: 5
scsi 0:2:0:0: Direct-Access     DELL     PERC 6/i         1.11 PQ: 0 ANSI: 5
scsi 0:0:32:0: Attached scsi generic sg0 type 13
sd 0:2:0:0: [sda] 311427072 512-byte hardware sectors: (159 GB/148 GiB)
<...>



#
# Automatically generated make config: don't edit
# Linux kernel version: 2.6.28-rc5
# Mon Nov 17 18:23:45 2008
#
CONFIG_64BIT=y
# CONFIG_X86_32 is not set
CONFIG_X86_64=y
CONFIG_X86=y
CONFIG_ARCH_DEFCONFIG="arch/x86/configs/x86_64_defconfig"
CONFIG_GENERIC_TIME=y
CONFIG_GENERIC_CMOS_UPDATE=y
CONFIG_CLOCKSOURCE_WATCHDOG=y
CONFIG_GENERIC_CLOCKEVENTS=y
CONFIG_GENERIC_CLOCKEVENTS_BROADCAST=y
CONFIG_LOCKDEP_SUPPORT=y
CONFIG_STACKTRACE_SUPPORT=y
CONFIG_HAVE_LATENCYTOP_SUPPORT=y
CONFIG_FAST_CMPXCHG_LOCAL=y
CONFIG_MMU=y
CONFIG_ZONE_DMA=y
CONFIG_GENERIC_ISA_DMA=y
CONFIG_GENERIC_IOMAP=y
CONFIG_GENERIC_BUG=y
CONFIG_GENERIC_HWEIGHT=y
CONFIG_ARCH_MAY_HAVE_PC_FDC=y
CONFIG_RWSEM_GENERIC_SPINLOCK=y
# CONFIG_RWSEM_XCHGADD_ALGORITHM is not set
CONFIG_ARCH_HAS_CPU_IDLE_WAIT=y
CONFIG_GENERIC_CALIBRATE_DELAY=y
CONFIG_GENERIC_TIME_VSYSCALL=y
CONFIG_ARCH_HAS_CPU_RELAX=y
CONFIG_ARCH_HAS_DEFAULT_IDLE=y
CONFIG_ARCH_HAS_CACHE_LINE_SIZE=y
CONFIG_HAVE_SETUP_PER_CPU_AREA=y
CONFIG_HAVE_CPUMASK_OF_CPU_MAP=y
CONFIG_ARCH_HIBERNATION_POSSIBLE=y
CONFIG_ARCH_SUSPEND_POSSIBLE=y
CONFIG_ZONE_DMA32=y
CONFIG_ARCH_POPULATES_NODE_MAP=y
CONFIG_AUDIT_ARCH=y
CONFIG_ARCH_SUPPORTS_OPTIMIZED_INLINING=y
CONFIG_GENERIC_HARDIRQS=y
CONFIG_GENERIC_IRQ_PROBE=y
CONFIG_GENERIC_PENDING_IRQ=y
CONFIG_X86_SMP=y
CONFIG_USE_GENERIC_SMP_HELPERS=y
CONFIG_X86_64_SMP=y
CONFIG_X86_HT=y
CONFIG_X86_BIOS_REBOOT=y
CONFIG_X86_TRAMPOLINE=y
# CONFIG_KTIME_SCALAR is not set
CONFIG_DEFCONFIG_LIST="/lib/modules/$UNAME_RELEASE/.config"

#
# General setup
#
CONFIG_EXPERIMENTAL=y
CONFIG_LOCK_KERNEL=y
CONFIG_INIT_ENV_ARG_LIMIT=32
CONFIG_LOCALVERSION=""
CONFIG_LOCALVERSION_AUTO=y
CONFIG_SWAP=y
CONFIG_SYSVIPC=y
CONFIG_SYSVIPC_SYSCTL=y
CONFIG_POSIX_MQUEUE=y
CONFIG_BSD_PROCESS_ACCT=y
# CONFIG_BSD_PROCESS_ACCT_V3 is not set
# CONFIG_TASKSTATS is not set
# CONFIG_AUDIT is not set
CONFIG_IKCONFIG=y
CONFIG_IKCONFIG_PROC=y
CONFIG_LOG_BUF_SHIFT=18
# CONFIG_CGROUPS is not set
CONFIG_HAVE_UNSTABLE_SCHED_CLOCK=y
# CONFIG_GROUP_SCHED is not set
# CONFIG_SYSFS_DEPRECATED_V2 is not set
CONFIG_RELAY=y
CONFIG_NAMESPACES=y
CONFIG_UTS_NS=y
CONFIG_IPC_NS=y
CONFIG_USER_NS=y
CONFIG_PID_NS=y
# CONFIG_BLK_DEV_INITRD is not set
CONFIG_CC_OPTIMIZE_FOR_SIZE=y
CONFIG_SYSCTL=y
# CONFIG_EMBEDDED is not set
CONFIG_UID16=y
CONFIG_SYSCTL_SYSCALL=y
CONFIG_KALLSYMS=y
CONFIG_KALLSYMS_ALL=y
CONFIG_KALLSYMS_EXTRA_PASS=y
CONFIG_HOTPLUG=y
CONFIG_PRINTK=y
CONFIG_BUG=y
CONFIG_ELF_CORE=y
CONFIG_PCSPKR_PLATFORM=y
CONFIG_COMPAT_BRK=y
CONFIG_BASE_FULL=y
CONFIG_FUTEX=y
CONFIG_ANON_INODES=y
CONFIG_EPOLL=y
CONFIG_SIGNALFD=y
CONFIG_TIMERFD=y
CONFIG_EVENTFD=y
CONFIG_SHMEM=y
CONFIG_AIO=y
CONFIG_VM_EVENT_COUNTERS=y
CONFIG_PCI_QUIRKS=y
CONFIG_SLUB_DEBUG=y
# CONFIG_SLAB is not set
CONFIG_SLUB=y
# CONFIG_SLOB is not set
# CONFIG_PROFILING is not set
CONFIG_TRACEPOINTS=y
CONFIG_MARKERS=y
CONFIG_HAVE_OPROFILE=y
# CONFIG_KPROBES is not set
CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS=y
CONFIG_HAVE_IOREMAP_PROT=y
CONFIG_HAVE_KPROBES=y
CONFIG_HAVE_KRETPROBES=y
CONFIG_HAVE_ARCH_TRACEHOOK=y
# CONFIG_HAVE_GENERIC_DMA_COHERENT is not set
CONFIG_SLABINFO=y
CONFIG_RT_MUTEXES=y
# CONFIG_TINY_SHMEM is not set
CONFIG_BASE_SMALL=0
CONFIG_MODULES=y
# CONFIG_MODULE_FORCE_LOAD is not set
CONFIG_MODULE_UNLOAD=y
CONFIG_MODULE_FORCE_UNLOAD=y
# CONFIG_MODVERSIONS is not set
# CONFIG_MODULE_SRCVERSION_ALL is not set
CONFIG_STOP_MACHINE=y
CONFIG_BLOCK=y
CONFIG_BLK_DEV_IO_TRACE=y
# CONFIG_BLK_DEV_BSG is not set
# CONFIG_BLK_DEV_INTEGRITY is not set
CONFIG_BLOCK_COMPAT=y

#
# IO Schedulers
#
CONFIG_IOSCHED_NOOP=y
# CONFIG_IOSCHED_AS is not set
# CONFIG_IOSCHED_DEADLINE is not set
CONFIG_IOSCHED_CFQ=y
# CONFIG_DEFAULT_AS is not set
# CONFIG_DEFAULT_DEADLINE is not set
CONFIG_DEFAULT_CFQ=y
# CONFIG_DEFAULT_NOOP is not set
CONFIG_DEFAULT_IOSCHED="cfq"
# CONFIG_CLASSIC_RCU is not set
# CONFIG_FREEZER is not set

#
# Processor type and features
#
CONFIG_TICK_ONESHOT=y
CONFIG_NO_HZ=y
CONFIG_HIGH_RES_TIMERS=y
CONFIG_GENERIC_CLOCKEVENTS_BUILD=y
CONFIG_SMP=y
CONFIG_X86_FIND_SMP_CONFIG=y
CONFIG_X86_MPPARSE=y
CONFIG_X86_PC=y
# CONFIG_X86_ELAN is not set
# CONFIG_X86_VOYAGER is not set
# CONFIG_X86_GENERICARCH is not set
# CONFIG_X86_VSMP is not set
CONFIG_SCHED_OMIT_FRAME_POINTER=y
# CONFIG_PARAVIRT_GUEST is not set
# CONFIG_MEMTEST is not set
# CONFIG_M386 is not set
# CONFIG_M486 is not set
# CONFIG_M586 is not set
# CONFIG_M586TSC is not set
# CONFIG_M586MMX is not set
# CONFIG_M686 is not set
# CONFIG_MPENTIUMII is not set
# CONFIG_MPENTIUMIII is not set
# CONFIG_MPENTIUMM is not set
# CONFIG_MPENTIUM4 is not set
# CONFIG_MK6 is not set
# CONFIG_MK7 is not set
# CONFIG_MK8 is not set
# CONFIG_MCRUSOE is not set
# CONFIG_MEFFICEON is not set
# CONFIG_MWINCHIPC6 is not set
# CONFIG_MWINCHIP3D is not set
# CONFIG_MGEODEGX1 is not set
# CONFIG_MGEODE_LX is not set
# CONFIG_MCYRIXIII is not set
# CONFIG_MVIAC3_2 is not set
# CONFIG_MVIAC7 is not set
# CONFIG_MPSC is not set
CONFIG_MCORE2=y
# CONFIG_GENERIC_CPU is not set
CONFIG_X86_CPU=y
CONFIG_X86_L1_CACHE_BYTES=64
CONFIG_X86_INTERNODE_CACHE_BYTES=64
CONFIG_X86_CMPXCHG=y
CONFIG_X86_L1_CACHE_SHIFT=6
CONFIG_X86_WP_WORKS_OK=y
CONFIG_X86_INTEL_USERCOPY=y
CONFIG_X86_USE_PPRO_CHECKSUM=y
CONFIG_X86_P6_NOP=y
CONFIG_X86_TSC=y
CONFIG_X86_CMPXCHG64=y
CONFIG_X86_CMOV=y
CONFIG_X86_MINIMUM_CPU_FAMILY=64
CONFIG_X86_DEBUGCTLMSR=y
CONFIG_CPU_SUP_INTEL=y
CONFIG_CPU_SUP_AMD=y
CONFIG_CPU_SUP_CENTAUR_64=y
CONFIG_X86_DS=y
CONFIG_X86_PTRACE_BTS=y
CONFIG_HPET_TIMER=y
CONFIG_HPET_EMULATE_RTC=y
CONFIG_DMI=y
CONFIG_GART_IOMMU=y
# CONFIG_CALGARY_IOMMU is not set
# CONFIG_AMD_IOMMU is not set
CONFIG_SWIOTLB=y
CONFIG_IOMMU_HELPER=y
CONFIG_NR_CPUS=8
# CONFIG_SCHED_SMT is not set
CONFIG_SCHED_MC=y
# CONFIG_PREEMPT_NONE is not set
# CONFIG_PREEMPT_VOLUNTARY is not set
CONFIG_PREEMPT=y
CONFIG_PREEMPT_RCU=y
CONFIG_RCU_TRACE=y
CONFIG_X86_LOCAL_APIC=y
CONFIG_X86_IO_APIC=y
# CONFIG_X86_REROUTE_FOR_BROKEN_BOOT_IRQS is not set
CONFIG_X86_MCE=y
CONFIG_X86_MCE_INTEL=y
# CONFIG_X86_MCE_AMD is not set
# CONFIG_I8K is not set
# CONFIG_MICROCODE is not set
CONFIG_X86_MSR=y
CONFIG_X86_CPUID=y
CONFIG_ARCH_PHYS_ADDR_T_64BIT=y
CONFIG_DIRECT_GBPAGES=y
# CONFIG_NUMA is not set
CONFIG_ARCH_SPARSEMEM_DEFAULT=y
CONFIG_ARCH_SPARSEMEM_ENABLE=y
CONFIG_ARCH_SELECT_MEMORY_MODEL=y
CONFIG_ILLEGAL_POINTER_VALUE=0xdead000000000000
CONFIG_SELECT_MEMORY_MODEL=y
# CONFIG_FLATMEM_MANUAL is not set
# CONFIG_DISCONTIGMEM_MANUAL is not set
CONFIG_SPARSEMEM_MANUAL=y
CONFIG_SPARSEMEM=y
CONFIG_HAVE_MEMORY_PRESENT=y
CONFIG_SPARSEMEM_EXTREME=y
CONFIG_SPARSEMEM_VMEMMAP_ENABLE=y
CONFIG_SPARSEMEM_VMEMMAP=y
# CONFIG_MEMORY_HOTPLUG is not set
CONFIG_PAGEFLAGS_EXTENDED=y
CONFIG_SPLIT_PTLOCK_CPUS=4
CONFIG_RESOURCES_64BIT=y
CONFIG_PHYS_ADDR_T_64BIT=y
CONFIG_ZONE_DMA_FLAG=1
CONFIG_BOUNCE=y
CONFIG_VIRT_TO_BUS=y
CONFIG_UNEVICTABLE_LRU=y
CONFIG_X86_CHECK_BIOS_CORRUPTION=y
CONFIG_X86_BOOTPARAM_MEMORY_CORRUPTION_CHECK=y
CONFIG_X86_RESERVE_LOW_64K=y
CONFIG_MTRR=y
# CONFIG_MTRR_SANITIZER is not set
CONFIG_X86_PAT=y
# CONFIG_EFI is not set
CONFIG_SECCOMP=y
# CONFIG_CC_STACKPROTECTOR is not set
# CONFIG_HZ_100 is not set
# CONFIG_HZ_250 is not set
CONFIG_HZ_300=y
# CONFIG_HZ_1000 is not set
CONFIG_HZ=300
CONFIG_SCHED_HRTICK=y
# CONFIG_KEXEC is not set
# CONFIG_CRASH_DUMP is not set
CONFIG_PHYSICAL_START=0x200000
# CONFIG_RELOCATABLE is not set
CONFIG_PHYSICAL_ALIGN=0x200000
CONFIG_HOTPLUG_CPU=y
# CONFIG_COMPAT_VDSO is not set
# CONFIG_CMDLINE_BOOL is not set

#
# Hardware Performance Monitoring support
#
# CONFIG_PERFMON is not set
CONFIG_ARCH_ENABLE_MEMORY_HOTPLUG=y

#
# Power management and ACPI options
#
CONFIG_PM=y
# CONFIG_PM_DEBUG is not set
# CONFIG_SUSPEND is not set
# CONFIG_HIBERNATION is not set
CONFIG_ACPI=y
# CONFIG_ACPI_PROCFS is not set
# CONFIG_ACPI_PROCFS_POWER is not set
# CONFIG_ACPI_SYSFS_POWER is not set
# CONFIG_ACPI_PROC_EVENT is not set
# CONFIG_ACPI_AC is not set
# CONFIG_ACPI_BATTERY is not set
# CONFIG_ACPI_BUTTON is not set
# CONFIG_ACPI_FAN is not set
CONFIG_ACPI_DOCK=y
# CONFIG_ACPI_PROCESSOR is not set
# CONFIG_ACPI_WMI is not set
# CONFIG_ACPI_ASUS is not set
# CONFIG_ACPI_TOSHIBA is not set
# CONFIG_ACPI_CUSTOM_DSDT is not set
CONFIG_ACPI_BLACKLIST_YEAR=0
# CONFIG_ACPI_DEBUG is not set
# CONFIG_ACPI_PCI_SLOT is not set
CONFIG_ACPI_SYSTEM=y
CONFIG_X86_PM_TIMER=y
# CONFIG_ACPI_CONTAINER is not set
# CONFIG_ACPI_SBS is not set

#
# CPU Frequency scaling
#
# CONFIG_CPU_FREQ is not set
CONFIG_CPU_IDLE=y
CONFIG_CPU_IDLE_GOV_LADDER=y
CONFIG_CPU_IDLE_GOV_MENU=y

#
# Memory power savings
#
CONFIG_I7300_IDLE_IOAT_CHANNEL=y
CONFIG_I7300_IDLE=y

#
# Bus options (PCI etc.)
#
CONFIG_PCI=y
CONFIG_PCI_DIRECT=y
CONFIG_PCI_MMCONFIG=y
CONFIG_PCI_DOMAINS=y
CONFIG_DMAR=y
# CONFIG_DMAR_GFX_WA is not set
CONFIG_DMAR_FLOPPY_WA=y
CONFIG_INTR_REMAP=y
CONFIG_PCIEPORTBUS=y
CONFIG_PCIEAER=y
# CONFIG_PCIEASPM is not set
CONFIG_ARCH_SUPPORTS_MSI=y
CONFIG_PCI_MSI=y
# CONFIG_PCI_LEGACY is not set
# CONFIG_PCI_DEBUG is not set
# CONFIG_HT_IRQ is not set
CONFIG_ISA_DMA_API=y
CONFIG_K8_NB=y
# CONFIG_PCCARD is not set
# CONFIG_HOTPLUG_PCI is not set

#
# Executable file formats / Emulations
#
CONFIG_BINFMT_ELF=y
CONFIG_COMPAT_BINFMT_ELF=y
# CONFIG_CORE_DUMP_DEFAULT_ELF_HEADERS is not set
# CONFIG_HAVE_AOUT is not set
# CONFIG_BINFMT_MISC is not set
CONFIG_IA32_EMULATION=y
# CONFIG_IA32_AOUT is not set
CONFIG_COMPAT=y
CONFIG_COMPAT_FOR_U64_ALIGNMENT=y
CONFIG_SYSVIPC_COMPAT=y
CONFIG_NET=y

#
# Networking options
#
# CONFIG_NET_NS is not set
CONFIG_PACKET=y
# CONFIG_PACKET_MMAP is not set
CONFIG_UNIX=y
# CONFIG_NET_KEY is not set
CONFIG_INET=y
# CONFIG_IP_MULTICAST is not set
# CONFIG_IP_ADVANCED_ROUTER is not set
CONFIG_IP_FIB_HASH=y
# CONFIG_IP_PNP is not set
# CONFIG_NET_IPIP is not set
# CONFIG_NET_IPGRE is not set
# CONFIG_ARPD is not set
# CONFIG_SYN_COOKIES is not set
# CONFIG_INET_AH is not set
# CONFIG_INET_ESP is not set
# CONFIG_INET_IPCOMP is not set
# CONFIG_INET_XFRM_TUNNEL is not set
# CONFIG_INET_TUNNEL is not set
# CONFIG_INET_XFRM_MODE_TRANSPORT is not set
# CONFIG_INET_XFRM_MODE_TUNNEL is not set
# CONFIG_INET_XFRM_MODE_BEET is not set
# CONFIG_INET_LRO is not set
# CONFIG_INET_DIAG is not set
# CONFIG_TCP_CONG_ADVANCED is not set
CONFIG_TCP_CONG_CUBIC=y
CONFIG_DEFAULT_TCP_CONG="cubic"
# CONFIG_TCP_MD5SIG is not set
# CONFIG_IPV6 is not set
# CONFIG_NETWORK_SECMARK is not set
# CONFIG_NETFILTER is not set
# CONFIG_IP_DCCP is not set
# CONFIG_IP_SCTP is not set
# CONFIG_TIPC is not set
# CONFIG_ATM is not set
# CONFIG_BRIDGE is not set
# CONFIG_NET_DSA is not set
# CONFIG_VLAN_8021Q is not set
# CONFIG_DECNET is not set
# CONFIG_LLC2 is not set
# CONFIG_IPX is not set
# CONFIG_ATALK is not set
# CONFIG_X25 is not set
# CONFIG_LAPB is not set
# CONFIG_ECONET is not set
# CONFIG_WAN_ROUTER is not set
# CONFIG_NET_SCHED is not set

#
# Network testing
#
# CONFIG_NET_PKTGEN is not set
# CONFIG_HAMRADIO is not set
# CONFIG_CAN is not set
# CONFIG_IRDA is not set
# CONFIG_BT is not set
# CONFIG_AF_RXRPC is not set
# CONFIG_PHONET is not set
# CONFIG_WIRELESS is not set
# CONFIG_RFKILL is not set
# CONFIG_NET_9P is not set

#
# Device Drivers
#

#
# Generic Driver Options
#
CONFIG_UEVENT_HELPER_PATH="/sbin/hotplug"
CONFIG_STANDALONE=y
# CONFIG_PREVENT_FIRMWARE_BUILD is not set
CONFIG_FW_LOADER=y
# CONFIG_FIRMWARE_IN_KERNEL is not set
CONFIG_EXTRA_FIRMWARE=""
# CONFIG_DEBUG_DRIVER is not set
# CONFIG_DEBUG_DEVRES is not set
# CONFIG_SYS_HYPERVISOR is not set
# CONFIG_CONNECTOR is not set
# CONFIG_MTD is not set
# CONFIG_PARPORT is not set
CONFIG_PNP=y
CONFIG_PNP_DEBUG_MESSAGES=y

#
# Protocols
#
CONFIG_PNPACPI=y
CONFIG_BLK_DEV=y
# CONFIG_BLK_DEV_FD is not set
# CONFIG_BLK_CPQ_DA is not set
# CONFIG_BLK_CPQ_CISS_DA is not set
# CONFIG_BLK_DEV_DAC960 is not set
# CONFIG_BLK_DEV_UMEM is not set
# CONFIG_BLK_DEV_COW_COMMON is not set
CONFIG_BLK_DEV_LOOP=y
# CONFIG_BLK_DEV_CRYPTOLOOP is not set
# CONFIG_BLK_DEV_NBD is not set
# CONFIG_BLK_DEV_SX8 is not set
# CONFIG_BLK_DEV_UB is not set
# CONFIG_BLK_DEV_RAM is not set
# CONFIG_CDROM_PKTCDVD is not set
# CONFIG_ATA_OVER_ETH is not set
# CONFIG_BLK_DEV_HD is not set
# CONFIG_MISC_DEVICES is not set
CONFIG_HAVE_IDE=y
# CONFIG_IDE is not set

#
# SCSI device support
#
CONFIG_RAID_ATTRS=y
CONFIG_SCSI=y
CONFIG_SCSI_DMA=y
CONFIG_SCSI_TGT=y
# CONFIG_SCSI_NETLINK is not set
CONFIG_SCSI_PROC_FS=y

#
# SCSI support type (disk, tape, CD-ROM)
#
CONFIG_BLK_DEV_SD=y
# CONFIG_CHR_DEV_ST is not set
# CONFIG_CHR_DEV_OSST is not set
CONFIG_BLK_DEV_SR=y
CONFIG_BLK_DEV_SR_VENDOR=y
CONFIG_CHR_DEV_SG=y
# CONFIG_CHR_DEV_SCH is not set

#
# Some SCSI devices (e.g. CD jukebox) support multiple LUNs
#
CONFIG_SCSI_MULTI_LUN=y
CONFIG_SCSI_CONSTANTS=y
CONFIG_SCSI_LOGGING=y
CONFIG_SCSI_SCAN_ASYNC=y
CONFIG_SCSI_WAIT_SCAN=m

#
# SCSI Transports
#
# CONFIG_SCSI_SPI_ATTRS is not set
# CONFIG_SCSI_FC_ATTRS is not set
# CONFIG_SCSI_ISCSI_ATTRS is not set
# CONFIG_SCSI_SAS_LIBSAS is not set
# CONFIG_SCSI_SRP_ATTRS is not set
CONFIG_SCSI_LOWLEVEL=y
# CONFIG_ISCSI_TCP is not set
# CONFIG_BLK_DEV_3W_XXXX_RAID is not set
# CONFIG_SCSI_3W_9XXX is not set
# CONFIG_SCSI_ACARD is not set
# CONFIG_SCSI_AACRAID is not set
# CONFIG_SCSI_AIC7XXX is not set
# CONFIG_SCSI_AIC7XXX_OLD is not set
# CONFIG_SCSI_AIC79XX is not set
# CONFIG_SCSI_AIC94XX is not set
# CONFIG_SCSI_DPT_I2O is not set
# CONFIG_SCSI_ADVANSYS is not set
# CONFIG_SCSI_ARCMSR is not set
# CONFIG_MEGARAID_NEWGEN is not set
# CONFIG_MEGARAID_LEGACY is not set
CONFIG_MEGARAID_SAS=y
# CONFIG_SCSI_HPTIOP is not set
# CONFIG_SCSI_BUSLOGIC is not set
# CONFIG_SCSI_DMX3191D is not set
# CONFIG_SCSI_EATA is not set
# CONFIG_SCSI_FUTURE_DOMAIN is not set
# CONFIG_SCSI_GDTH is not set
# CONFIG_SCSI_IPS is not set
# CONFIG_SCSI_INITIO is not set
# CONFIG_SCSI_INIA100 is not set
# CONFIG_SCSI_MVSAS is not set
# CONFIG_SCSI_STEX is not set
# CONFIG_SCSI_SYM53C8XX_2 is not set
# CONFIG_SCSI_IPR is not set
# CONFIG_SCSI_QLOGIC_1280 is not set
# CONFIG_SCSI_QLA_FC is not set
# CONFIG_SCSI_QLA_ISCSI is not set
# CONFIG_SCSI_LPFC is not set
# CONFIG_SCSI_DC395x is not set
# CONFIG_SCSI_DC390T is not set
# CONFIG_SCSI_DEBUG is not set
# CONFIG_SCSI_SRP is not set
# CONFIG_SCSI_DH is not set
# CONFIG_SCSI_OSD_INITIATOR is not set
CONFIG_ATA=y
# CONFIG_ATA_NONSTANDARD is not set
CONFIG_ATA_ACPI=y
CONFIG_SATA_PMP=y
CONFIG_SATA_AHCI=y
# CONFIG_SATA_SIL24 is not set
CONFIG_ATA_SFF=y
# CONFIG_SATA_SVW is not set
CONFIG_ATA_PIIX=y
# CONFIG_SATA_MV is not set
# CONFIG_SATA_NV is not set
# CONFIG_PDC_ADMA is not set
# CONFIG_SATA_QSTOR is not set
# CONFIG_SATA_PROMISE is not set
# CONFIG_SATA_SX4 is not set
# CONFIG_SATA_SIL is not set
# CONFIG_SATA_SIS is not set
# CONFIG_SATA_ULI is not set
# CONFIG_SATA_VIA is not set
# CONFIG_SATA_VITESSE is not set
# CONFIG_SATA_INIC162X is not set
# CONFIG_PATA_ACPI is not set
# CONFIG_PATA_ALI is not set
# CONFIG_PATA_AMD is not set
# CONFIG_PATA_ARTOP is not set
# CONFIG_PATA_ATIIXP is not set
# CONFIG_PATA_CMD640_PCI is not set
# CONFIG_PATA_CMD64X is not set
# CONFIG_PATA_CS5520 is not set
# CONFIG_PATA_CS5530 is not set
# CONFIG_PATA_CYPRESS is not set
# CONFIG_PATA_EFAR is not set
# CONFIG_ATA_GENERIC is not set
# CONFIG_PATA_HPT366 is not set
# CONFIG_PATA_HPT37X is not set
# CONFIG_PATA_HPT3X2N is not set
# CONFIG_PATA_HPT3X3 is not set
# CONFIG_PATA_IT821X is not set
# CONFIG_PATA_IT8213 is not set
# CONFIG_PATA_JMICRON is not set
# CONFIG_PATA_TRIFLEX is not set
# CONFIG_PATA_MARVELL is not set
# CONFIG_PATA_MPIIX is not set
# CONFIG_PATA_OLDPIIX is not set
# CONFIG_PATA_NETCELL is not set
# CONFIG_PATA_NINJA32 is not set
# CONFIG_PATA_NS87410 is not set
# CONFIG_PATA_NS87415 is not set
# CONFIG_PATA_OPTI is not set
# CONFIG_PATA_OPTIDMA is not set
# CONFIG_PATA_PDC_OLD is not set
# CONFIG_PATA_RADISYS is not set
# CONFIG_PATA_RZ1000 is not set
# CONFIG_PATA_SC1200 is not set
# CONFIG_PATA_SERVERWORKS is not set
# CONFIG_PATA_PDC2027X is not set
# CONFIG_PATA_SIL680 is not set
# CONFIG_PATA_SIS is not set
# CONFIG_PATA_VIA is not set
# CONFIG_PATA_WINBOND is not set
# CONFIG_PATA_SCH is not set
# CONFIG_MD is not set
# CONFIG_FUSION is not set

#
# IEEE 1394 (FireWire) support
#

#
# Enable only one of the two stacks, unless you know what you are doing
#
# CONFIG_FIREWIRE is not set
# CONFIG_IEEE1394 is not set
# CONFIG_I2O is not set
# CONFIG_MACINTOSH_DRIVERS is not set
CONFIG_NETDEVICES=y
# CONFIG_DUMMY is not set
# CONFIG_BONDING is not set
# CONFIG_MACVLAN is not set
# CONFIG_EQUALIZER is not set
# CONFIG_TUN is not set
# CONFIG_VETH is not set
# CONFIG_NET_SB1000 is not set
# CONFIG_ARCNET is not set
# CONFIG_NET_ETHERNET is not set
CONFIG_NETDEV_1000=y
# CONFIG_ACENIC is not set
# CONFIG_DL2K is not set
# CONFIG_E1000 is not set
# CONFIG_E1000E is not set
# CONFIG_IP1000 is not set
# CONFIG_IGB is not set
# CONFIG_NS83820 is not set
# CONFIG_HAMACHI is not set
# CONFIG_YELLOWFIN is not set
# CONFIG_R8169 is not set
# CONFIG_SIS190 is not set
# CONFIG_SKGE is not set
# CONFIG_SKY2 is not set
# CONFIG_VIA_VELOCITY is not set
# CONFIG_TIGON3 is not set
CONFIG_BNX2=y
# CONFIG_QLA3XXX is not set
# CONFIG_ATL1 is not set
# CONFIG_ATL1E is not set
# CONFIG_JME is not set
# CONFIG_NETDEV_10000 is not set
# CONFIG_TR is not set

#
# Wireless LAN
#
# CONFIG_WLAN_PRE80211 is not set
# CONFIG_WLAN_80211 is not set
# CONFIG_IWLWIFI_LEDS is not set

#
# USB Network Adapters
#
# CONFIG_USB_CATC is not set
# CONFIG_USB_KAWETH is not set
# CONFIG_USB_PEGASUS is not set
# CONFIG_USB_RTL8150 is not set
# CONFIG_USB_USBNET is not set
# CONFIG_WAN is not set
# CONFIG_FDDI is not set
# CONFIG_HIPPI is not set
# CONFIG_PPP is not set
# CONFIG_SLIP is not set
# CONFIG_NET_FC is not set
CONFIG_NETCONSOLE=y
CONFIG_NETCONSOLE_DYNAMIC=y
CONFIG_NETPOLL=y
CONFIG_NETPOLL_TRAP=y
CONFIG_NET_POLL_CONTROLLER=y
# CONFIG_ISDN is not set
# CONFIG_PHONE is not set

#
# Input device support
#
CONFIG_INPUT=y
CONFIG_INPUT_FF_MEMLESS=y
CONFIG_INPUT_POLLDEV=y

#
# Userland interfaces
#
CONFIG_INPUT_MOUSEDEV=y
# CONFIG_INPUT_MOUSEDEV_PSAUX is not set
CONFIG_INPUT_MOUSEDEV_SCREEN_X=1024
CONFIG_INPUT_MOUSEDEV_SCREEN_Y=768
# CONFIG_INPUT_JOYDEV is not set
CONFIG_INPUT_EVDEV=y
# CONFIG_INPUT_EVBUG is not set

#
# Input Device Drivers
#
CONFIG_INPUT_KEYBOARD=y
CONFIG_KEYBOARD_ATKBD=y
# CONFIG_KEYBOARD_SUNKBD is not set
# CONFIG_KEYBOARD_LKKBD is not set
# CONFIG_KEYBOARD_XTKBD is not set
# CONFIG_KEYBOARD_NEWTON is not set
# CONFIG_KEYBOARD_STOWAWAY is not set
# CONFIG_INPUT_MOUSE is not set
# CONFIG_INPUT_JOYSTICK is not set
# CONFIG_INPUT_TABLET is not set
# CONFIG_INPUT_TOUCHSCREEN is not set
# CONFIG_INPUT_MISC is not set

#
# Hardware I/O ports
#
CONFIG_SERIO=y
CONFIG_SERIO_I8042=y
CONFIG_SERIO_SERPORT=y
# CONFIG_SERIO_CT82C710 is not set
# CONFIG_SERIO_PCIPS2 is not set
CONFIG_SERIO_LIBPS2=y
# CONFIG_SERIO_RAW is not set
# CONFIG_GAMEPORT is not set

#
# Character devices
#
CONFIG_VT=y
CONFIG_CONSOLE_TRANSLATIONS=y
CONFIG_VT_CONSOLE=y
CONFIG_HW_CONSOLE=y
CONFIG_VT_HW_CONSOLE_BINDING=y
CONFIG_DEVKMEM=y
# CONFIG_SERIAL_NONSTANDARD is not set
# CONFIG_NOZOMI is not set

#
# Serial drivers
#
CONFIG_SERIAL_8250=y
CONFIG_SERIAL_8250_CONSOLE=y
CONFIG_FIX_EARLYCON_MEM=y
CONFIG_SERIAL_8250_PCI=y
CONFIG_SERIAL_8250_PNP=y
CONFIG_SERIAL_8250_NR_UARTS=32
CONFIG_SERIAL_8250_RUNTIME_UARTS=4
# CONFIG_SERIAL_8250_EXTENDED is not set

#
# Non-8250 serial port support
#
CONFIG_SERIAL_CORE=y
CONFIG_SERIAL_CORE_CONSOLE=y
# CONFIG_SERIAL_JSM is not set
CONFIG_UNIX98_PTYS=y
# CONFIG_DEVPTS_MULTIPLE_INSTANCES is not set
# CONFIG_LEGACY_PTYS is not set
# CONFIG_IPMI_HANDLER is not set
CONFIG_HW_RANDOM=y
CONFIG_HW_RANDOM_INTEL=y
# CONFIG_HW_RANDOM_AMD is not set
CONFIG_NVRAM=y
# CONFIG_R3964 is not set
# CONFIG_APPLICOM is not set
# CONFIG_MWAVE is not set
# CONFIG_PC8736x_GPIO is not set
# CONFIG_RAW_DRIVER is not set
CONFIG_HPET=y
CONFIG_HPET_MMAP=y
CONFIG_HANGCHECK_TIMER=y
# CONFIG_TCG_TPM is not set
# CONFIG_TELCLOCK is not set
CONFIG_DEVPORT=y
# CONFIG_I2C is not set
# CONFIG_SPI is not set
CONFIG_ARCH_WANT_OPTIONAL_GPIOLIB=y
# CONFIG_GPIOLIB is not set
# CONFIG_W1 is not set
# CONFIG_POWER_SUPPLY is not set
# CONFIG_HWMON is not set
# CONFIG_THERMAL is not set
# CONFIG_THERMAL_HWMON is not set
# CONFIG_WATCHDOG is not set
CONFIG_SSB_POSSIBLE=y

#
# Sonics Silicon Backplane
#
# CONFIG_SSB is not set

#
# Multifunction device drivers
#
# CONFIG_MFD_CORE is not set
# CONFIG_MFD_SM501 is not set
# CONFIG_HTC_PASIC3 is not set
# CONFIG_MFD_TMIO is not set
# CONFIG_REGULATOR is not set

#
# Multimedia devices
#

#
# Multimedia core support
#
# CONFIG_VIDEO_DEV is not set
# CONFIG_DVB_CORE is not set
# CONFIG_VIDEO_MEDIA is not set

#
# Multimedia drivers
#
# CONFIG_DAB is not set

#
# Graphics support
#
CONFIG_AGP=y
CONFIG_AGP_AMD64=y
CONFIG_AGP_INTEL=y
# CONFIG_AGP_SIS is not set
# CONFIG_AGP_VIA is not set
# CONFIG_DRM is not set
# CONFIG_VGASTATE is not set
# CONFIG_VIDEO_OUTPUT_CONTROL is not set
# CONFIG_FB is not set
# CONFIG_BACKLIGHT_LCD_SUPPORT is not set

#
# Display device support
#
# CONFIG_DISPLAY_SUPPORT is not set

#
# Console display driver support
#
CONFIG_VGA_CONSOLE=y
# CONFIG_VGACON_SOFT_SCROLLBACK is not set
CONFIG_DUMMY_CONSOLE=y
# CONFIG_SOUND is not set
CONFIG_HID_SUPPORT=y
CONFIG_HID=y
CONFIG_HID_DEBUG=y
# CONFIG_HIDRAW is not set

#
# USB Input Devices
#
CONFIG_USB_HID=y
# CONFIG_HID_PID is not set
# CONFIG_USB_HIDDEV is not set

#
# Special HID drivers
#
CONFIG_HID_COMPAT=y
CONFIG_HID_A4TECH=y
CONFIG_HID_APPLE=y
CONFIG_HID_BELKIN=y
CONFIG_HID_CHERRY=y
CONFIG_HID_CHICONY=y
CONFIG_HID_CYPRESS=y
CONFIG_HID_EZKEY=y
CONFIG_HID_GYRATION=y
CONFIG_HID_LOGITECH=y
# CONFIG_LOGITECH_FF is not set
# CONFIG_LOGIRUMBLEPAD2_FF is not set
CONFIG_HID_MICROSOFT=y
CONFIG_HID_MONTEREY=y
CONFIG_HID_PANTHERLORD=y
# CONFIG_PANTHERLORD_FF is not set
CONFIG_HID_PETALYNX=y
CONFIG_HID_SAMSUNG=y
CONFIG_HID_SONY=y
CONFIG_HID_SUNPLUS=y
# CONFIG_THRUSTMASTER_FF is not set
# CONFIG_ZEROPLUS_FF is not set
CONFIG_USB_SUPPORT=y
CONFIG_USB_ARCH_HAS_HCD=y
CONFIG_USB_ARCH_HAS_OHCI=y
CONFIG_USB_ARCH_HAS_EHCI=y
CONFIG_USB=y
CONFIG_USB_DEBUG=y
# CONFIG_USB_ANNOUNCE_NEW_DEVICES is not set

#
# Miscellaneous USB options
#
CONFIG_USB_DEVICEFS=y
# CONFIG_USB_DEVICE_CLASS is not set
# CONFIG_USB_DYNAMIC_MINORS is not set
# CONFIG_USB_SUSPEND is not set
# CONFIG_USB_OTG is not set
# CONFIG_USB_MON is not set
# CONFIG_USB_WUSB is not set
# CONFIG_USB_WUSB_CBAF is not set

#
# USB Host Controller Drivers
#
# CONFIG_USB_C67X00_HCD is not set
CONFIG_USB_EHCI_HCD=y
# CONFIG_USB_EHCI_ROOT_HUB_TT is not set
# CONFIG_USB_EHCI_TT_NEWSCHED is not set
# CONFIG_USB_OXU210HP_HCD is not set
# CONFIG_USB_ISP116X_HCD is not set
# CONFIG_USB_ISP1760_HCD is not set
# CONFIG_USB_OHCI_HCD is not set
CONFIG_USB_UHCI_HCD=y
# CONFIG_USB_SL811_HCD is not set
# CONFIG_USB_R8A66597_HCD is not set
# CONFIG_USB_WHCI_HCD is not set
# CONFIG_USB_HWA_HCD is not set

#
# USB Device Class drivers
#
# CONFIG_USB_ACM is not set
# CONFIG_USB_PRINTER is not set
# CONFIG_USB_WDM is not set
# CONFIG_USB_TMC is not set

#
# NOTE: USB_STORAGE depends on SCSI but BLK_DEV_SD may also be needed;
#

#
# see USB_STORAGE Help for more information
#
# CONFIG_USB_STORAGE is not set
# CONFIG_USB_LIBUSUAL is not set

#
# USB Imaging devices
#
# CONFIG_USB_MDC800 is not set
# CONFIG_USB_MICROTEK is not set

#
# USB port drivers
#
# CONFIG_USB_SERIAL is not set

#
# USB Miscellaneous drivers
#
# CONFIG_USB_EMI62 is not set
# CONFIG_USB_EMI26 is not set
# CONFIG_USB_ADUTUX is not set
# CONFIG_USB_SEVSEG is not set
# CONFIG_USB_RIO500 is not set
# CONFIG_USB_LEGOTOWER is not set
# CONFIG_USB_LCD is not set
# CONFIG_USB_BERRY_CHARGE is not set
# CONFIG_USB_LED is not set
# CONFIG_USB_CYPRESS_CY7C63 is not set
# CONFIG_USB_CYTHERM is not set
# CONFIG_USB_PHIDGET is not set
# CONFIG_USB_IDMOUSE is not set
# CONFIG_USB_FTDI_ELAN is not set
# CONFIG_USB_APPLEDISPLAY is not set
# CONFIG_USB_SISUSBVGA is not set
# CONFIG_USB_LD is not set
# CONFIG_USB_TRANCEVIBRATOR is not set
# CONFIG_USB_IOWARRIOR is not set
# CONFIG_USB_TEST is not set
# CONFIG_USB_ISIGHTFW is not set
# CONFIG_USB_VST is not set
# CONFIG_USB_GADGET is not set
# CONFIG_UWB is not set
# CONFIG_MMC is not set
# CONFIG_MEMSTICK is not set
# CONFIG_NEW_LEDS is not set
# CONFIG_ACCESSIBILITY is not set
# CONFIG_INFINIBAND is not set
CONFIG_EDAC=y

#
# Reporting subsystems
#
# CONFIG_EDAC_DEBUG is not set
# CONFIG_EDAC_MM_EDAC is not set
CONFIG_RTC_LIB=y
CONFIG_RTC_CLASS=y
# CONFIG_RTC_HCTOSYS is not set
# CONFIG_RTC_DEBUG is not set

#
# RTC interfaces
#
CONFIG_RTC_INTF_SYSFS=y
CONFIG_RTC_INTF_PROC=y
CONFIG_RTC_INTF_DEV=y
# CONFIG_RTC_INTF_DEV_UIE_EMUL is not set
# CONFIG_RTC_DRV_TEST is not set

#
# SPI RTC drivers
#

#
# Platform RTC drivers
#
CONFIG_RTC_DRV_CMOS=y
# CONFIG_RTC_DRV_DS1286 is not set
# CONFIG_RTC_DRV_DS1511 is not set
# CONFIG_RTC_DRV_DS1553 is not set
# CONFIG_RTC_DRV_DS1742 is not set
# CONFIG_RTC_DRV_STK17TA8 is not set
# CONFIG_RTC_DRV_M48T86 is not set
# CONFIG_RTC_DRV_M48T35 is not set
# CONFIG_RTC_DRV_M48T59 is not set
# CONFIG_RTC_DRV_BQ4802 is not set
# CONFIG_RTC_DRV_V3020 is not set

#
# on-CPU RTC drivers
#
CONFIG_DMADEVICES=y

#
# DMA Devices
#
CONFIG_INTEL_IOATDMA=y
CONFIG_DMA_ENGINE=y

#
# DMA Clients
#
CONFIG_NET_DMA=y
# CONFIG_DMATEST is not set
CONFIG_DCA=y
# CONFIG_UIO is not set
# CONFIG_STAGING is not set
CONFIG_STAGING_EXCLUDE_BUILD=y

#
# Firmware Drivers
#
# CONFIG_EDD is not set
CONFIG_FIRMWARE_MEMMAP=y
# CONFIG_DELL_RBU is not set
# CONFIG_DCDBAS is not set
# CONFIG_DMIID is not set
# CONFIG_ISCSI_IBFT_FIND is not set

#
# File systems
#
CONFIG_EXT2_FS=y
# CONFIG_EXT2_FS_XATTR is not set
# CONFIG_EXT2_FS_XIP is not set
CONFIG_EXT3_FS=y
CONFIG_EXT3_FS_XATTR=y
CONFIG_EXT3_FS_POSIX_ACL=y
CONFIG_EXT3_FS_SECURITY=y
# CONFIG_EXT4_FS is not set
CONFIG_JBD=y
# CONFIG_JBD_DEBUG is not set
CONFIG_FS_MBCACHE=y
CONFIG_REISERFS_FS=y
# CONFIG_REISERFS_CHECK is not set
# CONFIG_REISERFS_PROC_INFO is not set
# CONFIG_REISERFS_FS_XATTR is not set
# CONFIG_JFS_FS is not set
CONFIG_FS_POSIX_ACL=y
CONFIG_FILE_LOCKING=y
CONFIG_XFS_FS=y
# CONFIG_XFS_QUOTA is not set
# CONFIG_XFS_POSIX_ACL is not set
# CONFIG_XFS_RT is not set
# CONFIG_XFS_DEBUG is not set
# CONFIG_GFS2_FS is not set
# CONFIG_OCFS2_FS is not set
CONFIG_DNOTIFY=y
CONFIG_INOTIFY=y
CONFIG_INOTIFY_USER=y
# CONFIG_QUOTA is not set
# CONFIG_AUTOFS_FS is not set
# CONFIG_AUTOFS4_FS is not set
# CONFIG_FUSE_FS is not set
CONFIG_GENERIC_ACL=y

#
# CD-ROM/DVD Filesystems
#
# CONFIG_ISO9660_FS is not set
# CONFIG_UDF_FS is not set

#
# DOS/FAT/NT Filesystems
#
# CONFIG_MSDOS_FS is not set
# CONFIG_VFAT_FS is not set
# CONFIG_NTFS_FS is not set

#
# Pseudo filesystems
#
CONFIG_PROC_FS=y
CONFIG_PROC_KCORE=y
CONFIG_PROC_SYSCTL=y
CONFIG_PROC_PAGE_MONITOR=y
CONFIG_SYSFS=y
CONFIG_TMPFS=y
CONFIG_TMPFS_POSIX_ACL=y
# CONFIG_HUGETLBFS is not set
# CONFIG_HUGETLB_PAGE is not set
CONFIG_CONFIGFS_FS=y

#
# Miscellaneous filesystems
#
# CONFIG_ADFS_FS is not set
# CONFIG_AFFS_FS is not set
# CONFIG_HFS_FS is not set
# CONFIG_HFSPLUS_FS is not set
# CONFIG_BEFS_FS is not set
# CONFIG_BFS_FS is not set
# CONFIG_EFS_FS is not set
# CONFIG_CRAMFS is not set
# CONFIG_VXFS_FS is not set
# CONFIG_MINIX_FS is not set
# CONFIG_OMFS_FS is not set
# CONFIG_HPFS_FS is not set
# CONFIG_QNX4FS_FS is not set
# CONFIG_ROMFS_FS is not set
# CONFIG_SYSV_FS is not set
# CONFIG_UFS_FS is not set
CONFIG_NETWORK_FILESYSTEMS=y
CONFIG_NFS_FS=y
CONFIG_NFS_V3=y
# CONFIG_NFS_V3_ACL is not set
# CONFIG_NFS_V4 is not set
CONFIG_NFSD=y
CONFIG_NFSD_V3=y
# CONFIG_NFSD_V3_ACL is not set
# CONFIG_NFSD_V4 is not set
CONFIG_LOCKD=y
CONFIG_LOCKD_V4=y
CONFIG_EXPORTFS=y
CONFIG_NFS_COMMON=y
CONFIG_SUNRPC=y
# CONFIG_SUNRPC_REGISTER_V4 is not set
# CONFIG_RPCSEC_GSS_KRB5 is not set
# CONFIG_RPCSEC_GSS_SPKM3 is not set
# CONFIG_SMB_FS is not set
# CONFIG_CIFS is not set
# CONFIG_NCP_FS is not set
# CONFIG_CODA_FS is not set
# CONFIG_AFS_FS is not set

#
# Partition Types
#
# CONFIG_PARTITION_ADVANCED is not set
CONFIG_MSDOS_PARTITION=y
# CONFIG_NLS is not set
# CONFIG_DLM is not set

#
# Kernel hacking
#
CONFIG_TRACE_IRQFLAGS_SUPPORT=y
CONFIG_PRINTK_TIME=y
# CONFIG_ENABLE_WARN_DEPRECATED is not set
# CONFIG_ENABLE_MUST_CHECK is not set
CONFIG_FRAME_WARN=2048
CONFIG_MAGIC_SYSRQ=y
# CONFIG_UNUSED_SYMBOLS is not set
CONFIG_DEBUG_FS=y
# CONFIG_HEADERS_CHECK is not set
CONFIG_DEBUG_KERNEL=y
CONFIG_DEBUG_SHIRQ=y
CONFIG_DETECT_SOFTLOCKUP=y
# CONFIG_BOOTPARAM_SOFTLOCKUP_PANIC is not set
CONFIG_BOOTPARAM_SOFTLOCKUP_PANIC_VALUE=0
# CONFIG_SCHED_DEBUG is not set
CONFIG_SCHEDSTATS=y
CONFIG_TIMER_STATS=y
# CONFIG_DEBUG_OBJECTS is not set
CONFIG_SLUB_DEBUG_ON=y
CONFIG_SLUB_STATS=y
CONFIG_DEBUG_PREEMPT=y
CONFIG_DEBUG_RT_MUTEXES=y
CONFIG_DEBUG_PI_LIST=y
# CONFIG_RT_MUTEX_TESTER is not set
CONFIG_DEBUG_SPINLOCK=y
CONFIG_DEBUG_MUTEXES=y
CONFIG_DEBUG_LOCK_ALLOC=y
CONFIG_PROVE_LOCKING=y
CONFIG_LOCKDEP=y
CONFIG_LOCK_STAT=y
CONFIG_DEBUG_LOCKDEP=y
CONFIG_TRACE_IRQFLAGS=y
CONFIG_DEBUG_SPINLOCK_SLEEP=y
# CONFIG_DEBUG_LOCKING_API_SELFTESTS is not set
CONFIG_STACKTRACE=y
# CONFIG_DEBUG_KOBJECT is not set
CONFIG_DEBUG_BUGVERBOSE=y
CONFIG_DEBUG_INFO=y
CONFIG_DEBUG_VM=y
# CONFIG_DEBUG_VIRTUAL is not set
CONFIG_DEBUG_WRITECOUNT=y
CONFIG_DEBUG_MEMORY_INIT=y
CONFIG_DEBUG_LIST=y
CONFIG_DEBUG_SG=y
# CONFIG_DEBUG_NOTIFIERS is not set
CONFIG_FRAME_POINTER=y
# CONFIG_BOOT_PRINTK_DELAY is not set
# CONFIG_RCU_TORTURE_TEST is not set
# CONFIG_BACKTRACE_SELF_TEST is not set
# CONFIG_DEBUG_BLOCK_EXT_DEVT is not set
CONFIG_FAULT_INJECTION=y
CONFIG_FAILSLAB=y
CONFIG_FAIL_PAGE_ALLOC=y
CONFIG_FAIL_MAKE_REQUEST=y
# CONFIG_FAIL_IO_TIMEOUT is not set
CONFIG_FAULT_INJECTION_DEBUG_FS=y
# CONFIG_LATENCYTOP is not set
CONFIG_SYSCTL_SYSCALL_CHECK=y
CONFIG_NOP_TRACER=y
CONFIG_HAVE_FUNCTION_TRACER=y
CONFIG_HAVE_FUNCTION_TRACE_MCOUNT_TEST=y
CONFIG_HAVE_DYNAMIC_FTRACE=y
CONFIG_HAVE_FTRACE_MCOUNT_RECORD=y
CONFIG_TRACER_MAX_TRACE=y
CONFIG_RING_BUFFER=y
CONFIG_TRACING=y

#
# Tracers
#
# CONFIG_FUNCTION_TRACER is not set
CONFIG_IRQSOFF_TRACER=y
CONFIG_PREEMPT_TRACER=y
CONFIG_SYSPROF_TRACER=y
CONFIG_SCHED_TRACER=y
CONFIG_CONTEXT_SWITCH_TRACER=y
# CONFIG_BOOT_TRACER is not set
# CONFIG_STACK_TRACER is not set
# CONFIG_FTRACE_STARTUP_TEST is not set
CONFIG_PROVIDE_OHCI1394_DMA_INIT=y
# CONFIG_KMEMTRACE is not set
CONFIG_DYNAMIC_PRINTK_DEBUG=y
# CONFIG_SAMPLES is not set
CONFIG_HAVE_ARCH_KGDB=y
# CONFIG_KGDB is not set
CONFIG_STRICT_DEVMEM=y
CONFIG_X86_VERBOSE_BOOTUP=y
CONFIG_EARLY_PRINTK=y
# CONFIG_EARLY_PRINTK_DBGP is not set
CONFIG_DEBUG_STACKOVERFLOW=y
CONFIG_DEBUG_STACK_USAGE=y
CONFIG_DEBUG_PAGEALLOC=y
CONFIG_DEBUG_PER_CPU_MAPS=y
CONFIG_X86_PTDUMP=y
CONFIG_DEBUG_RODATA=y
CONFIG_DEBUG_RODATA_TEST=y
# CONFIG_DEBUG_NX_TEST is not set
CONFIG_IOMMU_DEBUG=y
CONFIG_IOMMU_LEAK=y
# CONFIG_MMIOTRACE is not set
CONFIG_IO_DELAY_TYPE_0X80=0
CONFIG_IO_DELAY_TYPE_0XED=1
CONFIG_IO_DELAY_TYPE_UDELAY=2
CONFIG_IO_DELAY_TYPE_NONE=3
CONFIG_IO_DELAY_0X80=y
# CONFIG_IO_DELAY_0XED is not set
# CONFIG_IO_DELAY_UDELAY is not set
# CONFIG_IO_DELAY_NONE is not set
CONFIG_DEFAULT_IO_DELAY_TYPE=0
CONFIG_DEBUG_BOOT_PARAMS=y
CONFIG_CPA_DEBUG=y
CONFIG_OPTIMIZE_INLINING=y

#
# Security options
#
# CONFIG_KEYS is not set
# CONFIG_SECURITY is not set
# CONFIG_SECURITYFS is not set
# CONFIG_SECURITY_FILE_CAPABILITIES is not set
# CONFIG_CRYPTO is not set
CONFIG_HAVE_KVM=y
# CONFIG_VIRTUALIZATION is not set

#
# Library routines
#
CONFIG_BITREVERSE=y
CONFIG_GENERIC_FIND_FIRST_BIT=y
CONFIG_GENERIC_FIND_NEXT_BIT=y
# CONFIG_CRC_CCITT is not set
CONFIG_CRC16=y
CONFIG_CRC_T10DIF=y
# CONFIG_CRC_ITU_T is not set
CONFIG_CRC32=y
# CONFIG_CRC7 is not set
# CONFIG_LIBCRC32C is not set
CONFIG_ZLIB_INFLATE=y
CONFIG_PLIST=y
CONFIG_HAS_IOMEM=y
CONFIG_HAS_IOPORT=y
CONFIG_HAS_DMA=y
