From: Markus Trippelsdorf <markus@trippelsdorf.de>
Subject: Re: ATL1E 0000:02:00.0: swiotlb buffer is full (sz: 529461 bytes)
Date: Fri, 18 Sep 2015 18:55:37 +0200
Message-ID: <20150918165537.GC411@x4>
References: <20150912065155.GA421@x4>
 <20150918062133.GA411@x4>
 <CAMXMK6tfDdrA8su0ZO-Y=ewU-juNN4PjfTo-7cxsJ-tY=JVB9A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="jI8keyz6grp/JLjh"
Cc: linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Jay Cliburn <jcliburn@gmail.com>, netdev@vger.kernel.org
To: Chris Snook <chris.snook@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ud10.udmedia.de ([194.117.254.50]:56155 "EHLO
	mail.ud10.udmedia.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752265AbbIRQzl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Sep 2015 12:55:41 -0400
Content-Disposition: inline
In-Reply-To: <CAMXMK6tfDdrA8su0ZO-Y=ewU-juNN4PjfTo-7cxsJ-tY=JVB9A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--jI8keyz6grp/JLjh
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On 2015.09.18 at 16:42 +0000, Chris Snook wrote:
> I think atl1e is the victim here, not the cause. It's probably the last
> device being brought up that wants to use the swiotlb, so you haven't seen
> other devices failing for the same reason. Can you post your dmesg or boot
> log from both a boot where it works and one where it doesn't, as well as
> lspci -vvv? You may be able to work around it by passing swiotlb=32768 on
> the kernel command line, which doubles the size of that buffer from the
> default.
> 
> The size of that attempted allocation is strange though. It's slightly
> larger than 512K, and it's odd, which suggests we may have a bug in
> calculating the size of that allocation, though we may be faithfully
> working with what we get from the hardware.

The requested files are attached.

-- 
Markus

--jI8keyz6grp/JLjh
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=dmesg_good

 Linux version 4.3.0-rc1-00131-ga7d5c1897198-dirty (markus@x4) (gcc version 6.0.0 20150917 (experimental) (GCC) ) #119 SMP Fri Sep 18 08:07:44 CEST 2015
 Command line: BOOT_IMAGE=/bzImage root=PARTUUID=c591cae0-c996-4910-a15a-fb9556df395e init=/sbin/minit fbcon=rotate:3 radeon.dpm=1 radeon.audio=0 drm_kms_helper.poll=0 quiet
 KERNEL supported cpus:
 AMD AuthenticAMD
 tseg: 0000000000
 x86/fpu: Legacy x87 FPU detected.
 x86/fpu: Using 'lazy' FPU context switches.
 e820: BIOS-provided physical RAM map:
 BIOS-e820: [mem 0x0000000000000000-0x000000000009fbff] usable
 BIOS-e820: [mem 0x000000000009fc00-0x000000000009ffff] reserved
 BIOS-e820: [mem 0x00000000000e6000-0x00000000000fffff] reserved
 BIOS-e820: [mem 0x0000000000100000-0x00000000dfe8ffff] usable
 BIOS-e820: [mem 0x00000000dfe90000-0x00000000dfea7fff] ACPI data
 BIOS-e820: [mem 0x00000000dfea8000-0x00000000dfecffff] ACPI NVS
 BIOS-e820: [mem 0x00000000dfed0000-0x00000000dfefffff] reserved
 BIOS-e820: [mem 0x00000000fff00000-0x00000000ffffffff] reserved
 BIOS-e820: [mem 0x0000000100000000-0x000000021fffffff] usable
 NX (Execute Disable) protection: active
 SMBIOS 2.5 present.
 DMI: System manufacturer System Product Name/M4A78T-E, BIOS 3503    04/13/2011
 e820: update [mem 0x00000000-0x00000fff] usable ==> reserved
 e820: remove [mem 0x000a0000-0x000fffff] usable
 e820: last_pfn = 0x220000 max_arch_pfn = 0x400000000
 MTRR default type: uncachable
 MTRR fixed ranges enabled:
 00000-9FFFF write-back
 A0000-EFFFF uncachable
 F0000-FFFFF write-protect
 MTRR variable ranges enabled:
 0 base 000000000000 mask FFFF80000000 write-back
 1 base 000080000000 mask FFFFC0000000 write-back
 2 base 0000C0000000 mask FFFFE0000000 write-back
 3 disabled
 4 disabled
 5 disabled
 6 disabled
 7 disabled
 TOM2: 0000000220000000 aka 8704M
 x86/PAT: Configuration [0-7]: WB  WC  UC- UC  WB  WC  UC- WT  
 e820: update [mem 0xe0000000-0xffffffff] usable ==> reserved
 e820: last_pfn = 0xdfe90 max_arch_pfn = 0x400000000
 Base memory trampoline at [ffff880000099000] 99000 size 24576
 Using GB pages for direct mapping
 init_memory_mapping: [mem 0x00000000-0x000fffff]
 [mem 0x00000000-0x000fffff] page 4k
 BRK [0x021da000, 0x021dafff] PGTABLE
 BRK [0x021db000, 0x021dbfff] PGTABLE
 BRK [0x021dc000, 0x021dcfff] PGTABLE
 init_memory_mapping: [mem 0x21fe00000-0x21fffffff]
 [mem 0x21fe00000-0x21fffffff] page 2M
 BRK [0x021dd000, 0x021ddfff] PGTABLE
 init_memory_mapping: [mem 0x200000000-0x21fdfffff]
 [mem 0x200000000-0x21fdfffff] page 2M
 init_memory_mapping: [mem 0x00100000-0xdfe8ffff]
 [mem 0x00100000-0x001fffff] page 4k
 [mem 0x00200000-0x3fffffff] page 2M
 [mem 0x40000000-0xbfffffff] page 1G
 [mem 0xc0000000-0xdfdfffff] page 2M
 [mem 0xdfe00000-0xdfe8ffff] page 4k
 init_memory_mapping: [mem 0x100000000-0x1ffffffff]
 [mem 0x100000000-0x1ffffffff] page 1G
 ACPI: Early table checksum verification disabled
 ACPI: RSDP 0x00000000000FB880 000024 (v02 ACPIAM)
 ACPI: XSDT 0x00000000DFE90100 00005C (v01 041311 XSDT1656 20110413 MSFT 00000097)
 ACPI: FACP 0x00000000DFE90290 0000F4 (v03 041311 FACP1656 20110413 MSFT 00000097)
 ACPI BIOS Warning (bug): Optional FADT field Pm2ControlBlock has zero address or length: 0x0000000000000000/0x1 (20150818/tbfadt-654)
 ACPI BIOS Warning (bug): 32/64X length mismatch in FADT/Gpe0Block: 64/32 (20150818/tbfadt-623)
 ACPI: DSDT 0x00000000DFE90450 00E6FE (v01 A1152  A1152000 00000000 INTL 20060113)
 ACPI: FACS 0x00000000DFEA8000 000040
 ACPI: FACS 0x00000000DFEA8000 000040
 ACPI: APIC 0x00000000DFE90390 00007C (v01 041311 APIC1656 20110413 MSFT 00000097)
 ACPI: MCFG 0x00000000DFE90410 00003C (v01 041311 OEMMCFG  20110413 MSFT 00000097)
 ACPI: OEMB 0x00000000DFEA8040 000072 (v01 041311 OEMB1656 20110413 MSFT 00000097)
 ACPI: SRAT 0x00000000DFE9F450 0000E8 (v01 AMD    FAM_F_10 00000002 AMD  00000001)
 ACPI: HPET 0x00000000DFE9F540 000038 (v01 041311 OEMHPET  20110413 MSFT 00000097)
 ACPI: SSDT 0x00000000DFE9F580 00088C (v01 A M I  POWERNOW 00000001 AMD  00000001)
 ACPI: Local APIC address 0xfee00000
 [ffffea0000000000-ffffea00087fffff] PMD -> [ffff880217600000-ffff88021f5fffff] on node 0
 Zone ranges:
 DMA      [mem 0x0000000000001000-0x0000000000ffffff]
 DMA32    [mem 0x0000000001000000-0x00000000ffffffff]
 Normal   [mem 0x0000000100000000-0x000000021fffffff]
 Movable zone start for each node
 Early memory node ranges
 node   0: [mem 0x0000000000001000-0x000000000009efff]
 node   0: [mem 0x0000000000100000-0x00000000dfe8ffff]
 node   0: [mem 0x0000000100000000-0x000000021fffffff]
 Initmem setup node 0 [mem 0x0000000000001000-0x000000021fffffff]
 On node 0 totalpages: 2096686
 DMA zone: 64 pages used for memmap
 DMA zone: 21 pages reserved
 DMA zone: 3998 pages, LIFO batch:0
 DMA32 zone: 14267 pages used for memmap
 DMA32 zone: 913040 pages, LIFO batch:31
 Normal zone: 18432 pages used for memmap
 Normal zone: 1179648 pages, LIFO batch:31
 ACPI: PM-Timer IO Port: 0x808
 ACPI: Local APIC address 0xfee00000
 IOAPIC[0]: apic_id 4, version 33, address 0xfec00000, GSI 0-23
 ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
 ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 low level)
 ACPI: IRQ0 used by override.
 ACPI: IRQ9 used by override.
 Using ACPI (MADT) for SMP configuration information
 ACPI: HPET id: 0x8300 base: 0xfed00000
 smpboot: Allowing 4 CPUs, 0 hotplug CPUs
 e820: [mem 0xdff00000-0xffefffff] available for PCI devices
 clocksource: refined-jiffies: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 6370452778343963 ns
 setup_percpu: NR_CPUS:4 nr_cpumask_bits:4 nr_cpu_ids:4 nr_node_ids:1
 PERCPU: Embedded 28 pages/cpu @ffff88021fc00000 s84504 r0 d30184 u524288
 pcpu-alloc: s84504 r0 d30184 u524288 alloc=1*2097152
 pcpu-alloc: [0] 0 1 2 3 
 Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 2063902
 Kernel command line: BOOT_IMAGE=/bzImage root=PARTUUID=c591cae0-c996-4910-a15a-fb9556df395e init=/sbin/minit fbcon=rotate:3 radeon.dpm=1 radeon.audio=0 drm_kms_helper.poll=0 quiet
 PID hash table entries: 4096 (order: 3, 32768 bytes)
 Dentry cache hash table entries: 1048576 (order: 11, 8388608 bytes)
 Inode-cache hash table entries: 524288 (order: 10, 4194304 bytes)
 Memory: 8158340K/8386744K available (10635K kernel code, 446K rwdata, 2124K rodata, 744K init, 656K bss, 228404K reserved, 0K cma-reserved)
 SLUB: HWalign=64, Order=0-3, MinObjects=0, CPUs=4, Nodes=1
 Hierarchical RCU implementation.
 	Build-time adjustment of leaf fanout to 64.
 NR_IRQS:4352 nr_irqs:456 16
 spurious 8259A interrupt: IRQ7.
 Console: colour VGA+ 80x25
 console [tty0] enabled
 clocksource: hpet: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 133484873504 ns
 hpet clockevent registered
 tsc: Fast TSC calibration using PIT
 tsc: Detected 3210.517 MHz processor
 Calibrating delay loop (skipped), value calculated using timer frequency.. 6423.57 BogoMIPS (lpj=10701723)
 pid_max: default: 32768 minimum: 301
 ACPI: Core revision 20150818
 ACPI: 2 ACPI AML tables successfully acquired and loaded
 Mount-cache hash table entries: 16384 (order: 5, 131072 bytes)
 Mountpoint-cache hash table entries: 16384 (order: 5, 131072 bytes)
 CPU: Physical Processor ID: 0
 CPU: Processor Core ID: 0
 mce: CPU supports 6 MCE banks
 LVT offset 0 assigned for vector 0xf9
 process: using AMD E400 aware idle routine
 Last level iTLB entries: 4KB 512, 2MB 16, 4MB 8
 Last level dTLB entries: 4KB 512, 2MB 128, 4MB 64, 1GB 0
 Freeing SMP alternatives memory: 40K (ffffffff8212b000 - ffffffff82135000)
 ..TIMER: vector=0x30 apic1=0 pin1=2 apic2=-1 pin2=-1
 smpboot: CPU0: AMD Phenom(tm) II X4 955 Processor (family: 0x10, model: 0x4, stepping: 0x2)
 Performance Events: AMD PMU driver.
 ... version:                0
 ... bit width:              48
 ... generic registers:      4
 ... value mask:             0000ffffffffffff
 ... max period:             00007fffffffffff
 ... fixed-purpose events:   0
 ... event mask:             000000000000000f
 MCE: In-kernel MCE decoding enabled.
 x86: Booting SMP configuration:
 .... node  #0, CPUs:      #1
 process: System has AMD C1E enabled
 process: Switch to broadcast mode on CPU1
 #2
 process: Switch to broadcast mode on CPU2
 #3
 x86: Booted up 1 node, 4 CPUs
 smpboot: Total of 4 processors activated (25694.30 BogoMIPS)
 process: Switch to broadcast mode on CPU3
 process: Switch to broadcast mode on CPU0
 devtmpfs: initialized
 clocksource: jiffies: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 6370867519511994 ns
 xor: measuring software checksum speed
 prefetch64-sse: 13339.200 MB/sec
 generic_sse: 12679.200 MB/sec
 xor: using function: prefetch64-sse (13339.200 MB/sec)
 NET: Registered protocol family 16
 cpuidle: using governor ladder
 cpuidle: using governor menu
 node 0 link 0: io port [1000, ffffff]
 TOM: 00000000e0000000 aka 3584M
 Fam 10h mmconf [mem 0xe0000000-0xefffffff]
 node 0 link 0: mmio [a0000, bffff]
 node 0 link 0: mmio [e0000000, efffffff] ==> none
 node 0 link 0: mmio [f0000000, fbcfffff]
 node 0 link 0: mmio [fbd00000, fbefffff]
 node 0 link 0: mmio [fbf00000, ffefffff]
 TOM2: 0000000220000000 aka 8704M
 bus: [bus 00-07] on node 0 link 0
 bus: 00 [io  0x0000-0xffff]
 bus: 00 [mem 0x000a0000-0x000bffff]
 bus: 00 [mem 0xf0000000-0xffffffff]
 bus: 00 [mem 0x220000000-0xfcffffffff]
 ACPI: bus type PCI registered
 PCI: Using configuration type 1 for base access
 PCI: Using configuration type 1 for extended access
 raid6: sse2x1   gen()  5511 MB/s
 raid6: sse2x1   xor()  4340 MB/s
 raid6: sse2x2   gen()  8711 MB/s
 raid6: sse2x2   xor()  7282 MB/s
 raid6: sse2x4   gen()  8094 MB/s
 raid6: sse2x4   xor()  3599 MB/s
 raid6: using algorithm sse2x2 gen() 8711 MB/s
 raid6: .... xor() 7282 MB/s, rmw enabled
 raid6: using intx1 recovery algorithm
 ACPI: Added _OSI(Module Device)
 ACPI: Added _OSI(Processor Device)
 ACPI: Added _OSI(3.0 _SCP Extensions)
 ACPI: Added _OSI(Processor Aggregator Device)
 ACPI: Executed 3 blocks of module-level executable AML code
 ACPI: Interpreter enabled
 ACPI: (supports S0 S5)
 ACPI: Using IOAPIC for interrupt routing
 PCI: Using host bridge windows from ACPI; if necessary, use "pci=nocrs" and report a bug
 ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-ff])
 acpi PNP0A03:00: _OSC: OS supports [ExtendedConfig Segments MSI]
 acpi PNP0A03:00: _OSC failed (AE_NOT_FOUND); disabling ASPM
 PCI host bridge to bus 0000:00
 pci_bus 0000:00: root bus resource [bus 00-ff]
 pci_bus 0000:00: root bus resource [io  0x0000-0x0cf7 window]
 pci_bus 0000:00: root bus resource [io  0x0d00-0xffff window]
 pci_bus 0000:00: root bus resource [mem 0x000a0000-0x000bffff window]
 pci_bus 0000:00: root bus resource [mem 0x000d0000-0x000dffff window]
 pci_bus 0000:00: root bus resource [mem 0xdff00000-0xdfffffff window]
 pci_bus 0000:00: root bus resource [mem 0xf0000000-0xfebfffff window]
 pci 0000:00:00.0: [1022:9600] type 00 class 0x060000
 pci 0000:00:01.0: [1022:9602] type 01 class 0x060400
 pci 0000:00:06.0: [1022:9606] type 01 class 0x060400
 pci 0000:00:06.0: PME# supported from D0 D3hot D3cold
 pci 0000:00:11.0: [1002:4391] type 00 class 0x010601
 pci 0000:00:11.0: reg 0x10: [io  0xc000-0xc007]
 pci 0000:00:11.0: reg 0x14: [io  0xb000-0xb003]
 pci 0000:00:11.0: reg 0x18: [io  0xa000-0xa007]
 pci 0000:00:11.0: reg 0x1c: [io  0x9000-0x9003]
 pci 0000:00:11.0: reg 0x20: [io  0x8000-0x800f]
 pci 0000:00:11.0: reg 0x24: [mem 0xfbcffc00-0xfbcfffff]
 pci 0000:00:12.0: [1002:4397] type 00 class 0x0c0310
 pci 0000:00:12.0: reg 0x10: [mem 0xfbcfd000-0xfbcfdfff]
 pci 0000:00:12.1: [1002:4398] type 00 class 0x0c0310
 pci 0000:00:12.1: reg 0x10: [mem 0xfbcfe000-0xfbcfefff]
 pci 0000:00:12.2: [1002:4396] type 00 class 0x0c0320
 pci 0000:00:12.2: reg 0x10: [mem 0xfbcff800-0xfbcff8ff]
 pci 0000:00:12.2: supports D1 D2
 pci 0000:00:12.2: PME# supported from D0 D1 D2 D3hot
 pci 0000:00:13.0: [1002:4397] type 00 class 0x0c0310
 pci 0000:00:13.0: reg 0x10: [mem 0xfbcfb000-0xfbcfbfff]
 pci 0000:00:13.1: [1002:4398] type 00 class 0x0c0310
 pci 0000:00:13.1: reg 0x10: [mem 0xfbcfc000-0xfbcfcfff]
 pci 0000:00:13.2: [1002:4396] type 00 class 0x0c0320
 pci 0000:00:13.2: reg 0x10: [mem 0xfbcff400-0xfbcff4ff]
 pci 0000:00:13.2: supports D1 D2
 pci 0000:00:13.2: PME# supported from D0 D1 D2 D3hot
 pci 0000:00:14.0: [1002:4385] type 00 class 0x0c0500
 pci 0000:00:14.1: [1002:439c] type 00 class 0x01018a
 pci 0000:00:14.1: reg 0x10: [io  0x0000-0x0007]
 pci 0000:00:14.1: reg 0x14: [io  0x0000-0x0003]
 pci 0000:00:14.1: reg 0x18: [io  0x0000-0x0007]
 pci 0000:00:14.1: reg 0x1c: [io  0x0000-0x0003]
 pci 0000:00:14.1: reg 0x20: [io  0xff00-0xff0f]
 pci 0000:00:14.1: legacy IDE quirk: reg 0x10: [io  0x01f0-0x01f7]
 pci 0000:00:14.1: legacy IDE quirk: reg 0x14: [io  0x03f6]
 pci 0000:00:14.1: legacy IDE quirk: reg 0x18: [io  0x0170-0x0177]
 pci 0000:00:14.1: legacy IDE quirk: reg 0x1c: [io  0x0376]
 pci 0000:00:14.2: [1002:4383] type 00 class 0x040300
 pci 0000:00:14.2: reg 0x10: [mem 0xfbcf4000-0xfbcf7fff 64bit]
 pci 0000:00:14.2: PME# supported from D0 D3hot D3cold
 pci 0000:00:14.3: [1002:439d] type 00 class 0x060100
 pci 0000:00:14.4: [1002:4384] type 01 class 0x060401
 pci 0000:00:14.5: [1002:4399] type 00 class 0x0c0310
 pci 0000:00:14.5: reg 0x10: [mem 0xfbcfa000-0xfbcfafff]
 pci 0000:00:18.0: [1022:1200] type 00 class 0x060000
 pci 0000:00:18.1: [1022:1201] type 00 class 0x060000
 pci 0000:00:18.2: [1022:1202] type 00 class 0x060000
 pci 0000:00:18.3: [1022:1203] type 00 class 0x060000
 pci 0000:00:18.4: [1022:1204] type 00 class 0x060000
 pci 0000:00:01.0: PCI bridge to [bus 01]
 pci 0000:00:01.0:   bridge window [io  0xd000-0xdfff]
 pci 0000:00:01.0:   bridge window [mem 0xfbd00000-0xfbefffff]
 pci 0000:00:01.0:   bridge window [mem 0xf0000000-0xf7ffffff 64bit pref]
 pci 0000:01:05.0: [1002:9614] type 00 class 0x030000
 pci 0000:01:05.0: reg 0x10: [mem 0xf0000000-0xf7ffffff pref]
 pci 0000:01:05.0: reg 0x14: [io  0xd000-0xd0ff]
 pci 0000:01:05.0: reg 0x18: [mem 0xfbee0000-0xfbeeffff]
 pci 0000:01:05.0: reg 0x24: [mem 0xfbd00000-0xfbdfffff]
 pci 0000:01:05.0: supports D1 D2
 pci 0000:01:05.1: [1002:960f] type 00 class 0x040300
 pci 0000:01:05.1: reg 0x10: [mem 0xfbefc000-0xfbefffff]
 pci 0000:01:05.1: supports D1 D2
 pci 0000:00:06.0: PCI bridge to [bus 02]
 pci 0000:00:06.0:   bridge window [io  0xe000-0xefff]
 pci 0000:00:06.0:   bridge window [mem 0xfbf00000-0xfbffffff]
 pci 0000:02:00.0: [1969:1026] type 00 class 0x020000
 pci 0000:02:00.0: reg 0x10: [mem 0xfbfc0000-0xfbffffff 64bit]
 pci 0000:02:00.0: reg 0x18: [io  0xec00-0xec7f]
 pci 0000:02:00.0: PME# supported from D3hot D3cold
 pci 0000:00:14.4: PCI bridge to [bus 03] (subtractive decode)
 pci 0000:00:14.4:   bridge window [io  0x0000-0x0cf7 window] (subtractive decode)
 pci 0000:00:14.4:   bridge window [io  0x0d00-0xffff window] (subtractive decode)
 pci 0000:00:14.4:   bridge window [mem 0x000a0000-0x000bffff window] (subtractive decode)
 pci 0000:00:14.4:   bridge window [mem 0x000d0000-0x000dffff window] (subtractive decode)
 pci 0000:00:14.4:   bridge window [mem 0xdff00000-0xdfffffff window] (subtractive decode)
 pci 0000:00:14.4:   bridge window [mem 0xf0000000-0xfebfffff window] (subtractive decode)
 pci_bus 0000:00: on NUMA node 0
 ACPI: PCI Interrupt Link [LNKA] (IRQs 4 7 10 *11 12 14 15)
 ACPI: PCI Interrupt Link [LNKB] (IRQs *4 7 10 11 12 14 15)
 ACPI: PCI Interrupt Link [LNKC] (IRQs 4 7 *10 11 12 14 15)
 ACPI: PCI Interrupt Link [LNKD] (IRQs 4 *7 10 11 12 14 15)
 ACPI: PCI Interrupt Link [LNKE] (IRQs 4 7 10 11 12 14 15) *0, disabled.
 ACPI: PCI Interrupt Link [LNKF] (IRQs 4 7 10 11 12 14 15) *0, disabled.
 ACPI: PCI Interrupt Link [LNKG] (IRQs 4 7 *10 11 12 14 15)
 ACPI: PCI Interrupt Link [LNKH] (IRQs 4 7 10 11 12 14 15) *0, disabled.
 ACPI: Enabled 1 GPEs in block 00 to 1F
 SCSI subsystem initialized
 libata version 3.00 loaded.
 ACPI: bus type USB registered
 usbcore: registered new interface driver usbfs
 usbcore: registered new interface driver hub
 usbcore: registered new device driver usb
 EDAC MC: Ver: 3.0.0
 Advanced Linux Sound Architecture Driver Initialized.
 PCI: Using ACPI for IRQ routing
 PCI: pci_cache_line_size set to 64 bytes
 e820: reserve RAM buffer [mem 0x0009fc00-0x0009ffff]
 e820: reserve RAM buffer [mem 0xdfe90000-0xdfffffff]
 hpet0: at MMIO 0xfed00000, IRQs 2, 8, 0, 0
 hpet0: 4 comparators, 32-bit 14.318180 MHz counter
 clocksource: Switched to clocksource hpet
 pnp: PnP ACPI init
 system 00:00: Plug and Play ACPI device, IDs PNP0c02 (active)
 pnp 00:01: Plug and Play ACPI device, IDs PNP0b00 (active)
 system 00:02: [mem 0xfec00000-0xfec00fff] could not be reserved
 system 00:02: [mem 0xfee00000-0xfee00fff] has been reserved
 system 00:02: Plug and Play ACPI device, IDs PNP0c02 (active)
 system 00:03: [io  0x04d0-0x04d1] has been reserved
 system 00:03: [io  0x040b] has been reserved
 system 00:03: [io  0x04d6] has been reserved
 system 00:03: [io  0x0c00-0x0c01] has been reserved
 system 00:03: [io  0x0c14] has been reserved
 system 00:03: [io  0x0c50-0x0c51] has been reserved
 system 00:03: [io  0x0c52] has been reserved
 system 00:03: [io  0x0c6c] has been reserved
 system 00:03: [io  0x0c6f] has been reserved
 system 00:03: [io  0x0cd0-0x0cd1] has been reserved
 system 00:03: [io  0x0cd2-0x0cd3] has been reserved
 system 00:03: [io  0x0cd4-0x0cd5] has been reserved
 system 00:03: [io  0x0cd6-0x0cd7] has been reserved
 system 00:03: [io  0x0cd8-0x0cdf] has been reserved
 system 00:03: [io  0x0b00-0x0b3f] has been reserved
 system 00:03: [io  0x0800-0x089f] could not be reserved
 system 00:03: [io  0x0b00-0x0b0f] has been reserved
 system 00:03: [io  0x0b20-0x0b3f] has been reserved
 system 00:03: [io  0x0900-0x090f] has been reserved
 system 00:03: [io  0x0910-0x091f] has been reserved
 system 00:03: [io  0xfe00-0xfefe] has been reserved
 system 00:03: [mem 0xdff00000-0xdfffffff] has been reserved
 system 00:03: [mem 0xffb80000-0xffbfffff] has been reserved
 system 00:03: [mem 0xfec10000-0xfec1001f] has been reserved
 system 00:03: Plug and Play ACPI device, IDs PNP0c02 (active)
 system 00:04: [io  0x0230-0x023f] has been reserved
 system 00:04: [io  0x0290-0x029f] has been reserved
 system 00:04: [io  0x0f40-0x0f4f] has been reserved
 system 00:04: [io  0x0a30-0x0a3f] has been reserved
 system 00:04: Plug and Play ACPI device, IDs PNP0c02 (active)
 system 00:05: [mem 0xe0000000-0xefffffff] has been reserved
 system 00:05: Plug and Play ACPI device, IDs PNP0c02 (active)
 system 00:06: [mem 0x00000000-0x0009ffff] could not be reserved
 system 00:06: [mem 0x000c0000-0x000cffff] could not be reserved
 system 00:06: [mem 0x000e0000-0x000fffff] could not be reserved
 system 00:06: [mem 0x00100000-0xdfefffff] could not be reserved
 system 00:06: [mem 0xfec00000-0xffffffff] could not be reserved
 system 00:06: Plug and Play ACPI device, IDs PNP0c01 (active)
 pnp: PnP ACPI: found 7 devices
 clocksource: acpi_pm: mask: 0xffffff max_cycles: 0xffffff, max_idle_ns: 2085701024 ns
 pci 0000:00:01.0: PCI bridge to [bus 01]
 pci 0000:00:01.0:   bridge window [io  0xd000-0xdfff]
 pci 0000:00:01.0:   bridge window [mem 0xfbd00000-0xfbefffff]
 pci 0000:00:01.0:   bridge window [mem 0xf0000000-0xf7ffffff 64bit pref]
 pci 0000:00:06.0: PCI bridge to [bus 02]
 pci 0000:00:06.0:   bridge window [io  0xe000-0xefff]
 pci 0000:00:06.0:   bridge window [mem 0xfbf00000-0xfbffffff]
 pci 0000:00:14.4: PCI bridge to [bus 03]
 pci_bus 0000:00: resource 4 [io  0x0000-0x0cf7 window]
 pci_bus 0000:00: resource 5 [io  0x0d00-0xffff window]
 pci_bus 0000:00: resource 6 [mem 0x000a0000-0x000bffff window]
 pci_bus 0000:00: resource 7 [mem 0x000d0000-0x000dffff window]
 pci_bus 0000:00: resource 8 [mem 0xdff00000-0xdfffffff window]
 pci_bus 0000:00: resource 9 [mem 0xf0000000-0xfebfffff window]
 pci_bus 0000:01: resource 0 [io  0xd000-0xdfff]
 pci_bus 0000:01: resource 1 [mem 0xfbd00000-0xfbefffff]
 pci_bus 0000:01: resource 2 [mem 0xf0000000-0xf7ffffff 64bit pref]
 pci_bus 0000:02: resource 0 [io  0xe000-0xefff]
 pci_bus 0000:02: resource 1 [mem 0xfbf00000-0xfbffffff]
 pci_bus 0000:03: resource 4 [io  0x0000-0x0cf7 window]
 pci_bus 0000:03: resource 5 [io  0x0d00-0xffff window]
 pci_bus 0000:03: resource 6 [mem 0x000a0000-0x000bffff window]
 pci_bus 0000:03: resource 7 [mem 0x000d0000-0x000dffff window]
 pci_bus 0000:03: resource 8 [mem 0xdff00000-0xdfffffff window]
 pci_bus 0000:03: resource 9 [mem 0xf0000000-0xfebfffff window]
 NET: Registered protocol family 2
 TCP established hash table entries: 65536 (order: 7, 524288 bytes)
 TCP bind hash table entries: 65536 (order: 8, 1048576 bytes)
 TCP: Hash tables configured (established 65536 bind 65536)
 UDP hash table entries: 4096 (order: 5, 131072 bytes)
 UDP-Lite hash table entries: 4096 (order: 5, 131072 bytes)
 NET: Registered protocol family 1
 pci 0000:00:01.0: MSI quirk detected; subordinate MSI disabled
 pci 0000:01:05.0: Video device with shadowed ROM
 PCI: CLS 64 bytes, default 64
 PCI-DMA: Using software bounce buffering for IO (SWIOTLB)
 software IO TLB [mem 0xdbe90000-0xdfe90000] (64MB) mapped at [ffff8800dbe90000-ffff8800dfe8ffff]
 kvm: Nested Virtualization enabled
 kvm: Nested Paging enabled
 microcode: CPU0: patch_level=0x010000c6
 microcode: CPU1: patch_level=0x010000c6
 microcode: CPU2: patch_level=0x010000c6
 microcode: CPU3: patch_level=0x010000c6
 microcode: Microcode Update Driver: v2.00 <tigran@aivazian.fsnet.co.uk>, Peter Oruba
 LVT offset 1 assigned for vector 0x400
 IBS: LVT offset 1 assigned
 perf: AMD IBS detected (0x0000001f)
 futex hash table entries: 1024 (order: 4, 65536 bytes)
 9p: Installing v9fs 9p2000 file system support
 Block layer SCSI generic (bsg) driver version 0.4 loaded (major 253)
 io scheduler noop registered
 io scheduler deadline registered (default)
 io scheduler cfq registered
 ACPI: processor limited to max C-state 1
 Serial: 8250/16550 driver, 4 ports, IRQ sharing disabled
 [drm] Initialized drm 1.1.0 20060810
 [drm] radeon kernel modesetting enabled.
 [drm] initializing kernel modesetting (RS780 0x1002:0x9614 0x1043:0x834D).
 [drm] register mmio base: 0xFBEE0000
 [drm] register mmio size: 65536
 ATOM BIOS: 113
 radeon 0000:01:05.0: VRAM: 128M 0x00000000C0000000 - 0x00000000C7FFFFFF (128M used)
 radeon 0000:01:05.0: GTT: 512M 0x00000000A0000000 - 0x00000000BFFFFFFF
 [drm] Detected VRAM RAM=128M, BAR=128M
 [drm] RAM width 32bits DDR
 [TTM] Zone  kernel: Available graphics memory: 4079190 kiB
 [TTM] Zone   dma32: Available graphics memory: 2097152 kiB
 [TTM] Initializing pool allocator
 [TTM] Initializing DMA pool allocator
 [drm] radeon: 128M of VRAM memory ready
 [drm] radeon: 512M of GTT memory ready.
 [drm] Loading RS780 Microcode
 == power state 0 ==
 	ui class: none
 	internal class: boot 
 	caps: video 
 	uvd    vclk: 0 dclk: 0
 		power level 0    sclk: 50000 vddc_index: 2
 		power level 1    sclk: 50000 vddc_index: 2
 	status: c r b 
 == power state 1 ==
 	ui class: performance
 	internal class: none
 	caps: video 
 	uvd    vclk: 0 dclk: 0
 		power level 0    sclk: 50000 vddc_index: 1
 		power level 1    sclk: 70000 vddc_index: 2
 	status: 
 == power state 2 ==
 	ui class: none
 	internal class: uvd 
 	caps: video 
 	uvd    vclk: 53300 dclk: 40000
 		power level 0    sclk: 50000 vddc_index: 1
 		power level 1    sclk: 50000 vddc_index: 1
 	status: 
 [drm] radeon: dpm initialized
 [drm] GART: num cpu pages 131072, num gpu pages 131072
 [drm] PCIE GART of 512M enabled (table at 0x00000000C0040000).
 radeon 0000:01:05.0: WB enabled
 radeon 0000:01:05.0: fence driver on ring 0 use gpu addr 0x00000000a0000c00 and cpu addr 0xffff88021638ac00
 [drm] Supports vblank timestamp caching Rev 2 (21.10.2013).
 [drm] Driver supports precise vblank timestamp query.
 radeon 0000:01:05.0: radeon: MSI limited to 32-bit
 [drm] radeon: irq initialized.
 [drm] ring test on 0 succeeded in 1 usecs
 [drm] ib test on ring 0 succeeded in 0 usecs
 [drm] Radeon Display Connectors
 [drm] Connector 0:
 [drm]   VGA-1
 [drm]   DDC: 0x7e40 0x7e40 0x7e44 0x7e44 0x7e48 0x7e48 0x7e4c 0x7e4c
 [drm]   Encoders:
 [drm]     CRT1: INTERNAL_KLDSCP_DAC1
 [drm] Connector 1:
 [drm]   DVI-D-1
 [drm]   HPD3
 [drm]   DDC: 0x7e50 0x7e50 0x7e54 0x7e54 0x7e58 0x7e58 0x7e5c 0x7e5c
 [drm]   Encoders:
 [drm]     DFP3: INTERNAL_KLDSCP_LVTMA
 switching from power state:
 	ui class: none
 	internal class: boot 
 	caps: video 
 	uvd    vclk: 0 dclk: 0
 		power level 0    sclk: 50000 vddc_index: 2
 		power level 1    sclk: 50000 vddc_index: 2
 	status: c b 
 switching to power state:
 	ui class: performance
 	internal class: none
 	caps: video 
 	uvd    vclk: 0 dclk: 0
 		power level 0    sclk: 50000 vddc_index: 1
 		power level 1    sclk: 70000 vddc_index: 2
 	status: r 
 [drm] fb mappable at 0xF0141000
 [drm] vram apper at 0xF0000000
 [drm] size 7299072
 [drm] fb depth is 24
 [drm]    pitch is 6912
 fbcon: radeondrmfb (fb0) is primary device
 Console: switching to colour frame buffer device 131x105
 radeon 0000:01:05.0: fb0: radeondrmfb frame buffer device
 [drm] Initialized radeon 2.43.0 20080528 for 0000:01:05.0 on minor 0
 loop: module loaded
 ahci 0000:00:11.0: version 3.0
 ahci 0000:00:11.0: AHCI 0001.0100 32 slots 6 ports 3 Gbps 0x3f impl SATA mode
 ahci 0000:00:11.0: flags: 64bit ncq sntf ilck pm led clo pmp pio slum part ccc 
 scsi host0: ahci
 scsi host1: ahci
 scsi host2: ahci
 scsi host3: ahci
 scsi host4: ahci
 scsi host5: ahci
 ata1: SATA max UDMA/133 abar m1024@0xfbcffc00 port 0xfbcffd00 irq 22
 ata2: SATA max UDMA/133 abar m1024@0xfbcffc00 port 0xfbcffd80 irq 22
 ata3: SATA max UDMA/133 abar m1024@0xfbcffc00 port 0xfbcffe00 irq 22
 ata4: SATA max UDMA/133 abar m1024@0xfbcffc00 port 0xfbcffe80 irq 22
 ata5: SATA max UDMA/133 abar m1024@0xfbcffc00 port 0xfbcfff00 irq 22
 ata6: SATA max UDMA/133 abar m1024@0xfbcffc00 port 0xfbcfff80 irq 22
 tun: Universal TUN/TAP device driver, 1.6
 tun: (C) 1999-2004 Max Krasnyansky <maxk@qualcomm.com>
 ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
 ehci-pci: EHCI PCI platform driver
 QUIRK: Enable AMD PLL fix
 ehci-pci 0000:00:12.2: EHCI Host Controller
 ehci-pci 0000:00:12.2: new USB bus registered, assigned bus number 1
 ehci-pci 0000:00:12.2: applying AMD SB700/SB800/Hudson-2/3 EHCI dummy qh workaround
 ehci-pci 0000:00:12.2: applying AMD SB600/SB700 USB freeze workaround
 ehci-pci 0000:00:12.2: debug port 1
 ehci-pci 0000:00:12.2: irq 17, io mem 0xfbcff800
 ehci-pci 0000:00:12.2: USB 2.0 started, EHCI 1.00
 hub 1-0:1.0: USB hub found
 hub 1-0:1.0: 6 ports detected
 ehci-pci 0000:00:13.2: EHCI Host Controller
 ehci-pci 0000:00:13.2: new USB bus registered, assigned bus number 2
 ehci-pci 0000:00:13.2: applying AMD SB700/SB800/Hudson-2/3 EHCI dummy qh workaround
 ehci-pci 0000:00:13.2: applying AMD SB600/SB700 USB freeze workaround
 ehci-pci 0000:00:13.2: debug port 1
 ehci-pci 0000:00:13.2: irq 19, io mem 0xfbcff400
 ehci-pci 0000:00:13.2: USB 2.0 started, EHCI 1.00
 hub 2-0:1.0: USB hub found
 hub 2-0:1.0: 6 ports detected
 ohci_hcd: USB 1.1 'Open' Host Controller (OHCI) Driver
 ohci-pci: OHCI PCI platform driver
 ohci-pci 0000:00:12.0: OHCI PCI host controller
 ohci-pci 0000:00:12.0: new USB bus registered, assigned bus number 3
 ohci-pci 0000:00:12.0: irq 16, io mem 0xfbcfd000
 hub 3-0:1.0: USB hub found
 hub 3-0:1.0: 3 ports detected
 ohci-pci 0000:00:12.1: OHCI PCI host controller
 ohci-pci 0000:00:12.1: new USB bus registered, assigned bus number 4
 ohci-pci 0000:00:12.1: irq 16, io mem 0xfbcfe000
 hub 4-0:1.0: USB hub found
 hub 4-0:1.0: 3 ports detected
 ohci-pci 0000:00:13.0: OHCI PCI host controller
 ohci-pci 0000:00:13.0: new USB bus registered, assigned bus number 5
 ohci-pci 0000:00:13.0: irq 18, io mem 0xfbcfb000
 hub 5-0:1.0: USB hub found
 hub 5-0:1.0: 3 ports detected
 ohci-pci 0000:00:13.1: OHCI PCI host controller
 ohci-pci 0000:00:13.1: new USB bus registered, assigned bus number 6
 ohci-pci 0000:00:13.1: irq 18, io mem 0xfbcfc000
 hub 6-0:1.0: USB hub found
 hub 6-0:1.0: 3 ports detected
 ohci-pci 0000:00:14.5: OHCI PCI host controller
 ohci-pci 0000:00:14.5: new USB bus registered, assigned bus number 7
 ohci-pci 0000:00:14.5: irq 18, io mem 0xfbcfa000
 ata1: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
 ata2: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
 ata3: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
 ata5: SATA link down (SStatus 0 SControl 300)
 ata6: SATA link down (SStatus 0 SControl 300)
 ata4: SATA link down (SStatus 0 SControl 300)
 ata1.00: ATA-8: OCZ VERTEX-TURBO, 1.7, max UDMA/133
 ata1.00: 62533296 sectors, multi 1: LBA48 NCQ (depth 31/32), AA
 ata3.00: ATA-9: M4-CT128M4SSD2, 0309, max UDMA/100
 ata3.00: 250069680 sectors, multi 16: LBA48 NCQ (depth 31/32), AA
 ata3.00: configured for UDMA/100
 ata2.00: ATA-9: ST2000DM001-1CH164, CC29, max UDMA/133
 ata2.00: 3907029168 sectors, multi 16: LBA48 NCQ (depth 31/32), AA
 ata1.00: configured for UDMA/133
 scsi 0:0:0:0: Direct-Access     ATA      OCZ VERTEX-TURBO 1.7  PQ: 0 ANSI: 5
 sd 0:0:0:0: Attached scsi generic sg0 type 0
 sd 0:0:0:0: [sda] 62533296 512-byte logical blocks: (32.0 GB/29.8 GiB)
 sd 0:0:0:0: [sda] Write Protect is off
 sd 0:0:0:0: [sda] Mode Sense: 00 3a 00 00
 sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
 ata2.00: configured for UDMA/133
 scsi 1:0:0:0: Direct-Access     ATA      ST2000DM001-1CH1 CC29 PQ: 0 ANSI: 5
 sd 1:0:0:0: Attached scsi generic sg1 type 0
 sd 1:0:0:0: [sdb] 3907029168 512-byte logical blocks: (2.00 TB/1.81 TiB)
 sd 1:0:0:0: [sdb] 4096-byte physical blocks
 sd 1:0:0:0: [sdb] Write Protect is off
 sd 1:0:0:0: [sdb] Mode Sense: 00 3a 00 00
 sd 1:0:0:0: [sdb] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
 scsi 2:0:0:0: Direct-Access     ATA      M4-CT128M4SSD2   0309 PQ: 0 ANSI: 5
 sd 2:0:0:0: [sdc] 250069680 512-byte logical blocks: (128 GB/119 GiB)
 sd 2:0:0:0: Attached scsi generic sg2 type 0
 sd 2:0:0:0: [sdc] Write Protect is off
 sd 2:0:0:0: [sdc] Mode Sense: 00 3a 00 00
 sd 2:0:0:0: [sdc] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
 sda: sda1 sda2 sda3
 sd 0:0:0:0: [sda] Attached SCSI disk
 sdc: sdc1 sdc2 sdc3
 sd 2:0:0:0: [sdc] Attached SCSI disk
 hub 7-0:1.0: USB hub found
 hub 7-0:1.0: 2 ports detected
 usbcore: registered new interface driver usblp
 usbcore: registered new interface driver usb-storage
 i8042: PNP: No PS/2 controller found. Probing ports directly.
 serio: i8042 KBD port at 0x60,0x64 irq 1
 serio: i8042 AUX port at 0x60,0x64 irq 12
 mousedev: PS/2 mouse device common for all mice
 rtc_cmos 00:01: RTC can wake from S4
 rtc_cmos 00:01: rtc core: registered rtc_cmos as rtc0
 rtc_cmos 00:01: alarms up to one month, y3k, 114 bytes nvram, hpet irqs
 i2c /dev entries driver
 AMD64 EDAC driver v3.4.0
 EDAC amd64: DRAM ECC enabled.
 EDAC amd64: F10h detected (node 0).
 EDAC MC: DCT0 chip selects:
 EDAC amd64: MC: 0:  1024MB 1:  1024MB
 EDAC amd64: MC: 2:  1024MB 3:  1024MB
 EDAC amd64: MC: 4:     0MB 5:     0MB
 EDAC amd64: MC: 6:     0MB 7:     0MB
 EDAC MC: DCT1 chip selects:
 EDAC amd64: MC: 0:  1024MB 1:  1024MB
 EDAC amd64: MC: 2:  1024MB 3:  1024MB
 EDAC amd64: MC: 4:     0MB 5:     0MB
 EDAC amd64: MC: 6:     0MB 7:     0MB
 EDAC amd64: using x4 syndromes.
 EDAC amd64: MCT channel count: 2
 EDAC MC0: Giving out device to module amd64_edac controller F10h: DEV 0000:00:18.2 (INTERRUPT)
 EDAC PCI0: Giving out device to module amd64_edac controller EDAC PCI controller: DEV 0000:00:18.2 (POLLED)
 hidraw: raw HID events driver (C) Jiri Kosina
 usbcore: registered new interface driver usbhid
 usbhid: USB HID core driver
 usbcore: registered new interface driver snd-usb-audio
 Netfilter messages via NETLINK v0.30.
 nf_conntrack version 0.5.0 (65536 buckets, 262144 max)
 ctnetlink v0.93: registering with nfnetlink.
 ip_tables: (C) 2000-2006 Netfilter Core Team
 NET: Registered protocol family 17
 9pnet: Installing 9P2000 support
 registered taskstats version 1
 Btrfs loaded
 rtc_cmos 00:01: setting system clock to 2015-09-18 06:11:49 UTC (1442556709)
 acpi-cpufreq: overriding BIOS provided _PSD data
 ALSA device list:
 No soundcards found.
 snd_hda_codec_via hdaudioC0D0: autoconfig for VT1708S: line_outs=4 (0x1c/0x19/0x22/0x23/0x0) type:line
 snd_hda_codec_via hdaudioC0D0:    speaker_outs=0 (0x0/0x0/0x0/0x0/0x0)
 snd_hda_codec_via hdaudioC0D0:    hp_outs=1 (0x1d/0x0/0x0/0x0/0x0)
 snd_hda_codec_via hdaudioC0D0:    mono: mono_out=0x0
 snd_hda_codec_via hdaudioC0D0:    dig-out=0x20/0x21
 snd_hda_codec_via hdaudioC0D0:    inputs:
 snd_hda_codec_via hdaudioC0D0:      Rear Mic=0x1a
 snd_hda_codec_via hdaudioC0D0:      Front Mic=0x1e
 snd_hda_codec_via hdaudioC0D0:      Line=0x1b
 snd_hda_codec_via hdaudioC0D0:      CD=0x1f
 snd_hda_codec_generic hdaudioC1D0: autoconfig for ID 791a: line_outs=0 (0x0/0x0/0x0/0x0/0x0) type:line
 snd_hda_codec_generic hdaudioC1D0:    speaker_outs=0 (0x0/0x0/0x0/0x0/0x0)
 snd_hda_codec_generic hdaudioC1D0:    hp_outs=0 (0x0/0x0/0x0/0x0/0x0)
 snd_hda_codec_generic hdaudioC1D0:    mono: mono_out=0x0
 snd_hda_codec_generic hdaudioC1D0:    dig-out=0x3/0x0
 snd_hda_codec_generic hdaudioC1D0:    inputs:
 input: HDA ATI HDMI HDMI as /devices/pci0000:00/0000:00:01.0/0000:01:05.1/sound/card1/input1
 input: HDA ATI SB Rear Mic as /devices/pci0000:00/0000:00:14.2/sound/card0/input2
 input: HDA ATI SB Front Mic as /devices/pci0000:00/0000:00:14.2/sound/card0/input3
 input: HDA ATI SB Line as /devices/pci0000:00/0000:00:14.2/sound/card0/input4
 input: HDA ATI SB Line Out Front as /devices/pci0000:00/0000:00:14.2/sound/card0/input5
 input: HDA ATI SB Line Out Surround as /devices/pci0000:00/0000:00:14.2/sound/card0/input6
 input: HDA ATI SB Line Out CLFE as /devices/pci0000:00/0000:00:14.2/sound/card0/input7
 input: HDA ATI SB Line Out Side as /devices/pci0000:00/0000:00:14.2/sound/card0/input8
 input: HDA ATI SB Front Headphone as /devices/pci0000:00/0000:00:14.2/sound/card0/input9
 sdb: sdb1 sdb2
 sd 1:0:0:0: [sdb] Attached SCSI disk
 UDF-fs: warning (device sdc3): udf_fill_super: No partition found (2)
 BTRFS: device fsid 7ef56edc-673e-452e-9e05-3fabf074168b devid 1 transid 25153 /dev/root
 BTRFS info (device sdc3): disk space caching is enabled
 BTRFS: has skinny extents
 BTRFS: detected SSD devices, enabling SSD mode
 VFS: Mounted root (btrfs filesystem) readonly on device 0:15.
 devtmpfs: mounted
 Freeing unused kernel memory: 744K (ffffffff82071000 - ffffffff8212b000)
 Write protecting the kernel read-only data: 16384k
 Freeing unused kernel memory: 1644K (ffff880001a65000 - ffff880001c00000)
 Freeing unused kernel memory: 1972K (ffff880001e13000 - ffff880002000000)
 usb 3-1: new low-speed USB device number 2 using ohci-pci
 usb 4-2: new full-speed USB device number 2 using ohci-pci
 input: HID 046a:0011 as /devices/pci0000:00/0000:00:12.0/usb3/3-1/3-1:1.0/0003:046A:0011.0001/input/input11
 BTRFS: device fsid 6b7d75bf-3d12-409c-88ed-500ac6b78510 devid 1 transid 396337 /dev/sdb2
 BTRFS info (device sdb2): disk space caching is enabled
 hid-generic 0003:046A:0011.0001: input,hidraw0: USB HID v1.10 Keyboard [HID 046a:0011] on usb-0000:00:12.0-1/input0
 tsc: Refined TSC clocksource calibration: 3210.826 MHz
 clocksource: tsc: mask: 0xffffffffffffffff max_cycles: 0x2e483d1f2ca, max_idle_ns: 440795239699 ns
 logitech-djreceiver 0003:046D:C52B.0004: hiddev0,hidraw1: USB HID v1.11 Device [Logitech USB Receiver] on usb-0000:00:12.1-2/input2
 input: Logitech T400 as /devices/pci0000:00/0000:00:12.1/usb4/4-2/4-2:1.2/0003:046D:C52B.0004/0003:046D:4026.0005/input/input12
 logitech-hidpp-device 0003:046D:4026.0005: input,hidraw2: USB HID v1.11 Keyboard [Logitech T400] on usb-0000:00:12.1-2:1
 clocksource: Switched to clocksource tsc
 random: nonblocking pool is initialized
 BTRFS: device fsid 24cee7e4-9093-4f86-aa73-d8a59d7f3c6c devid 1 transid 16527 /dev/sda3
 BTRFS info (device sda3): disk space caching is enabled
 BTRFS: has skinny extents
 BTRFS: detected SSD devices, enabling SSD mode
 ATL1E 0000:02:00.0 eth0: NIC Link is Up <1000 Mbps Full Duplex>
 BTRFS info (device sdc3): disk space caching is enabled
 microcode: CPU0: new patch_level=0x010000db
 microcode: CPU1: new patch_level=0x010000db
 microcode: CPU2: new patch_level=0x010000db
 microcode: CPU3: new patch_level=0x010000db
 Adding 4095996k swap on /dev/sdb1.  Priority:-1 extents:1 across:4095996k 

--jI8keyz6grp/JLjh
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=dmesg_bad

 Linux version 4.3.0-rc1-00131-ga7d5c1897198-dirty (markus@x4) (gcc version 6.0.0 20150917 (experimental) (GCC) ) #119 SMP Fri Sep 18 08:07:44 CEST 2015
 Command line: BOOT_IMAGE=/bzImage root=PARTUUID=c591cae0-c996-4910-a15a-fb9556df395e init=/sbin/minit fbcon=rotate:3 radeon.dpm=1 radeon.audio=0 drm_kms_helper.poll=0 quiet
 KERNEL supported cpus:
 AMD AuthenticAMD
 tseg: 0000000000
 x86/fpu: Legacy x87 FPU detected.
 x86/fpu: Using 'lazy' FPU context switches.
 e820: BIOS-provided physical RAM map:
 BIOS-e820: [mem 0x0000000000000000-0x000000000009fbff] usable
 BIOS-e820: [mem 0x000000000009fc00-0x000000000009ffff] reserved
 BIOS-e820: [mem 0x00000000000e6000-0x00000000000fffff] reserved
 BIOS-e820: [mem 0x0000000000100000-0x00000000dfe8ffff] usable
 BIOS-e820: [mem 0x00000000dfe90000-0x00000000dfea7fff] ACPI data
 BIOS-e820: [mem 0x00000000dfea8000-0x00000000dfecffff] ACPI NVS
 BIOS-e820: [mem 0x00000000dfed0000-0x00000000dfefffff] reserved
 BIOS-e820: [mem 0x00000000fff00000-0x00000000ffffffff] reserved
 BIOS-e820: [mem 0x0000000100000000-0x000000021fffffff] usable
 NX (Execute Disable) protection: active
 SMBIOS 2.5 present.
 DMI: System manufacturer System Product Name/M4A78T-E, BIOS 3503    04/13/2011
 e820: update [mem 0x00000000-0x00000fff] usable ==> reserved
 e820: remove [mem 0x000a0000-0x000fffff] usable
 e820: last_pfn = 0x220000 max_arch_pfn = 0x400000000
 MTRR default type: uncachable
 MTRR fixed ranges enabled:
 00000-9FFFF write-back
 A0000-EFFFF uncachable
 F0000-FFFFF write-protect
 MTRR variable ranges enabled:
 0 base 000000000000 mask FFFF80000000 write-back
 1 base 000080000000 mask FFFFC0000000 write-back
 2 base 0000C0000000 mask FFFFE0000000 write-back
 3 disabled
 4 disabled
 5 disabled
 6 disabled
 7 disabled
 TOM2: 0000000220000000 aka 8704M
 x86/PAT: Configuration [0-7]: WB  WC  UC- UC  WB  WC  UC- WT  
 e820: update [mem 0xe0000000-0xffffffff] usable ==> reserved
 e820: last_pfn = 0xdfe90 max_arch_pfn = 0x400000000
 Base memory trampoline at [ffff880000099000] 99000 size 24576
 Using GB pages for direct mapping
 init_memory_mapping: [mem 0x00000000-0x000fffff]
 [mem 0x00000000-0x000fffff] page 4k
 BRK [0x021da000, 0x021dafff] PGTABLE
 BRK [0x021db000, 0x021dbfff] PGTABLE
 BRK [0x021dc000, 0x021dcfff] PGTABLE
 init_memory_mapping: [mem 0x21fe00000-0x21fffffff]
 [mem 0x21fe00000-0x21fffffff] page 2M
 BRK [0x021dd000, 0x021ddfff] PGTABLE
 init_memory_mapping: [mem 0x200000000-0x21fdfffff]
 [mem 0x200000000-0x21fdfffff] page 2M
 init_memory_mapping: [mem 0x00100000-0xdfe8ffff]
 [mem 0x00100000-0x001fffff] page 4k
 [mem 0x00200000-0x3fffffff] page 2M
 [mem 0x40000000-0xbfffffff] page 1G
 [mem 0xc0000000-0xdfdfffff] page 2M
 [mem 0xdfe00000-0xdfe8ffff] page 4k
 init_memory_mapping: [mem 0x100000000-0x1ffffffff]
 [mem 0x100000000-0x1ffffffff] page 1G
 ACPI: Early table checksum verification disabled
 ACPI: RSDP 0x00000000000FB880 000024 (v02 ACPIAM)
 ACPI: XSDT 0x00000000DFE90100 00005C (v01 041311 XSDT1656 20110413 MSFT 00000097)
 ACPI: FACP 0x00000000DFE90290 0000F4 (v03 041311 FACP1656 20110413 MSFT 00000097)
 ACPI BIOS Warning (bug): Optional FADT field Pm2ControlBlock has zero address or length: 0x0000000000000000/0x1 (20150818/tbfadt-654)
 ACPI BIOS Warning (bug): 32/64X length mismatch in FADT/Gpe0Block: 64/32 (20150818/tbfadt-623)
 ACPI: DSDT 0x00000000DFE90450 00E6FE (v01 A1152  A1152000 00000000 INTL 20060113)
 ACPI: FACS 0x00000000DFEA8000 000040
 ACPI: FACS 0x00000000DFEA8000 000040
 ACPI: APIC 0x00000000DFE90390 00007C (v01 041311 APIC1656 20110413 MSFT 00000097)
 ACPI: MCFG 0x00000000DFE90410 00003C (v01 041311 OEMMCFG  20110413 MSFT 00000097)
 ACPI: OEMB 0x00000000DFEA8040 000072 (v01 041311 OEMB1656 20110413 MSFT 00000097)
 ACPI: SRAT 0x00000000DFE9F450 0000E8 (v01 AMD    FAM_F_10 00000002 AMD  00000001)
 ACPI: HPET 0x00000000DFE9F540 000038 (v01 041311 OEMHPET  20110413 MSFT 00000097)
 ACPI: SSDT 0x00000000DFE9F580 00088C (v01 A M I  POWERNOW 00000001 AMD  00000001)
 ACPI: Local APIC address 0xfee00000
 [ffffea0000000000-ffffea00087fffff] PMD -> [ffff880217600000-ffff88021f5fffff] on node 0
 Zone ranges:
 DMA      [mem 0x0000000000001000-0x0000000000ffffff]
 DMA32    [mem 0x0000000001000000-0x00000000ffffffff]
 Normal   [mem 0x0000000100000000-0x000000021fffffff]
 Movable zone start for each node
 Early memory node ranges
 node   0: [mem 0x0000000000001000-0x000000000009efff]
 node   0: [mem 0x0000000000100000-0x00000000dfe8ffff]
 node   0: [mem 0x0000000100000000-0x000000021fffffff]
 Initmem setup node 0 [mem 0x0000000000001000-0x000000021fffffff]
 On node 0 totalpages: 2096686
 DMA zone: 64 pages used for memmap
 DMA zone: 21 pages reserved
 DMA zone: 3998 pages, LIFO batch:0
 DMA32 zone: 14267 pages used for memmap
 DMA32 zone: 913040 pages, LIFO batch:31
 Normal zone: 18432 pages used for memmap
 Normal zone: 1179648 pages, LIFO batch:31
 ACPI: PM-Timer IO Port: 0x808
 ACPI: Local APIC address 0xfee00000
 IOAPIC[0]: apic_id 4, version 33, address 0xfec00000, GSI 0-23
 ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
 ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 low level)
 ACPI: IRQ0 used by override.
 ACPI: IRQ9 used by override.
 Using ACPI (MADT) for SMP configuration information
 ACPI: HPET id: 0x8300 base: 0xfed00000
 smpboot: Allowing 4 CPUs, 0 hotplug CPUs
 e820: [mem 0xdff00000-0xffefffff] available for PCI devices
 clocksource: refined-jiffies: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 6370452778343963 ns
 setup_percpu: NR_CPUS:4 nr_cpumask_bits:4 nr_cpu_ids:4 nr_node_ids:1
 PERCPU: Embedded 28 pages/cpu @ffff88021fc00000 s84504 r0 d30184 u524288
 pcpu-alloc: s84504 r0 d30184 u524288 alloc=1*2097152
 pcpu-alloc: [0] 0 1 2 3 
 Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 2063902
 Kernel command line: BOOT_IMAGE=/bzImage root=PARTUUID=c591cae0-c996-4910-a15a-fb9556df395e init=/sbin/minit fbcon=rotate:3 radeon.dpm=1 radeon.audio=0 drm_kms_helper.poll=0 quiet
 PID hash table entries: 4096 (order: 3, 32768 bytes)
 Dentry cache hash table entries: 1048576 (order: 11, 8388608 bytes)
 Inode-cache hash table entries: 524288 (order: 10, 4194304 bytes)
 Memory: 8158340K/8386744K available (10635K kernel code, 446K rwdata, 2124K rodata, 744K init, 656K bss, 228404K reserved, 0K cma-reserved)
 SLUB: HWalign=64, Order=0-3, MinObjects=0, CPUs=4, Nodes=1
 Hierarchical RCU implementation.
 	Build-time adjustment of leaf fanout to 64.
 NR_IRQS:4352 nr_irqs:456 16
 spurious 8259A interrupt: IRQ7.
 Console: colour VGA+ 80x25
 console [tty0] enabled
 clocksource: hpet: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 133484873504 ns
 hpet clockevent registered
 tsc: Fast TSC calibration using PIT
 tsc: Detected 3210.870 MHz processor
 Calibrating delay loop (skipped), value calculated using timer frequency.. 6424.31 BogoMIPS (lpj=10702900)
 pid_max: default: 32768 minimum: 301
 ACPI: Core revision 20150818
 ACPI: 2 ACPI AML tables successfully acquired and loaded
 Mount-cache hash table entries: 16384 (order: 5, 131072 bytes)
 Mountpoint-cache hash table entries: 16384 (order: 5, 131072 bytes)
 CPU: Physical Processor ID: 0
 CPU: Processor Core ID: 0
 mce: CPU supports 6 MCE banks
 LVT offset 0 assigned for vector 0xf9
 process: using AMD E400 aware idle routine
 Last level iTLB entries: 4KB 512, 2MB 16, 4MB 8
 Last level dTLB entries: 4KB 512, 2MB 128, 4MB 64, 1GB 0
 Freeing SMP alternatives memory: 40K (ffffffff8212b000 - ffffffff82135000)
 ..TIMER: vector=0x30 apic1=0 pin1=2 apic2=-1 pin2=-1
 smpboot: CPU0: AMD Phenom(tm) II X4 955 Processor (family: 0x10, model: 0x4, stepping: 0x2)
 Performance Events: AMD PMU driver.
 ... version:                0
 ... bit width:              48
 ... generic registers:      4
 ... value mask:             0000ffffffffffff
 ... max period:             00007fffffffffff
 ... fixed-purpose events:   0
 ... event mask:             000000000000000f
 MCE: In-kernel MCE decoding enabled.
 x86: Booting SMP configuration:
 .... node  #0, CPUs:      #1
 process: System has AMD C1E enabled
 process: Switch to broadcast mode on CPU1
 #2
 process: Switch to broadcast mode on CPU2
 #3
 x86: Booted up 1 node, 4 CPUs
 smpboot: Total of 4 processors activated (25697.25 BogoMIPS)
 process: Switch to broadcast mode on CPU3
 process: Switch to broadcast mode on CPU0
 devtmpfs: initialized
 clocksource: jiffies: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 6370867519511994 ns
 xor: measuring software checksum speed
 prefetch64-sse: 13340.400 MB/sec
 generic_sse: 12678.000 MB/sec
 xor: using function: prefetch64-sse (13340.400 MB/sec)
 NET: Registered protocol family 16
 cpuidle: using governor ladder
 cpuidle: using governor menu
 node 0 link 0: io port [1000, ffffff]
 TOM: 00000000e0000000 aka 3584M
 Fam 10h mmconf [mem 0xe0000000-0xefffffff]
 node 0 link 0: mmio [a0000, bffff]
 node 0 link 0: mmio [e0000000, efffffff] ==> none
 node 0 link 0: mmio [f0000000, fbcfffff]
 node 0 link 0: mmio [fbd00000, fbefffff]
 node 0 link 0: mmio [fbf00000, ffefffff]
 TOM2: 0000000220000000 aka 8704M
 bus: [bus 00-07] on node 0 link 0
 bus: 00 [io  0x0000-0xffff]
 bus: 00 [mem 0x000a0000-0x000bffff]
 bus: 00 [mem 0xf0000000-0xffffffff]
 bus: 00 [mem 0x220000000-0xfcffffffff]
 ACPI: bus type PCI registered
 PCI: Using configuration type 1 for base access
 PCI: Using configuration type 1 for extended access
 raid6: sse2x1   gen()  5582 MB/s
 raid6: sse2x1   xor()  4349 MB/s
 raid6: sse2x2   gen()  8666 MB/s
 raid6: sse2x2   xor()  7323 MB/s
 raid6: sse2x4   gen()  8136 MB/s
 raid6: sse2x4   xor()  3675 MB/s
 raid6: using algorithm sse2x2 gen() 8666 MB/s
 raid6: .... xor() 7323 MB/s, rmw enabled
 raid6: using intx1 recovery algorithm
 ACPI: Added _OSI(Module Device)
 ACPI: Added _OSI(Processor Device)
 ACPI: Added _OSI(3.0 _SCP Extensions)
 ACPI: Added _OSI(Processor Aggregator Device)
 ACPI: Executed 3 blocks of module-level executable AML code
 ACPI: Interpreter enabled
 ACPI: (supports S0 S5)
 ACPI: Using IOAPIC for interrupt routing
 PCI: Using host bridge windows from ACPI; if necessary, use "pci=nocrs" and report a bug
 ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-ff])
 acpi PNP0A03:00: _OSC: OS supports [ExtendedConfig Segments MSI]
 acpi PNP0A03:00: _OSC failed (AE_NOT_FOUND); disabling ASPM
 PCI host bridge to bus 0000:00
 pci_bus 0000:00: root bus resource [bus 00-ff]
 pci_bus 0000:00: root bus resource [io  0x0000-0x0cf7 window]
 pci_bus 0000:00: root bus resource [io  0x0d00-0xffff window]
 pci_bus 0000:00: root bus resource [mem 0x000a0000-0x000bffff window]
 pci_bus 0000:00: root bus resource [mem 0x000d0000-0x000dffff window]
 pci_bus 0000:00: root bus resource [mem 0xdff00000-0xdfffffff window]
 pci_bus 0000:00: root bus resource [mem 0xf0000000-0xfebfffff window]
 pci 0000:00:00.0: [1022:9600] type 00 class 0x060000
 pci 0000:00:01.0: [1022:9602] type 01 class 0x060400
 pci 0000:00:06.0: [1022:9606] type 01 class 0x060400
 pci 0000:00:06.0: PME# supported from D0 D3hot D3cold
 pci 0000:00:11.0: [1002:4391] type 00 class 0x010601
 pci 0000:00:11.0: reg 0x10: [io  0xc000-0xc007]
 pci 0000:00:11.0: reg 0x14: [io  0xb000-0xb003]
 pci 0000:00:11.0: reg 0x18: [io  0xa000-0xa007]
 pci 0000:00:11.0: reg 0x1c: [io  0x9000-0x9003]
 pci 0000:00:11.0: reg 0x20: [io  0x8000-0x800f]
 pci 0000:00:11.0: reg 0x24: [mem 0xfbcffc00-0xfbcfffff]
 pci 0000:00:12.0: [1002:4397] type 00 class 0x0c0310
 pci 0000:00:12.0: reg 0x10: [mem 0xfbcfd000-0xfbcfdfff]
 pci 0000:00:12.1: [1002:4398] type 00 class 0x0c0310
 pci 0000:00:12.1: reg 0x10: [mem 0xfbcfe000-0xfbcfefff]
 pci 0000:00:12.2: [1002:4396] type 00 class 0x0c0320
 pci 0000:00:12.2: reg 0x10: [mem 0xfbcff800-0xfbcff8ff]
 pci 0000:00:12.2: supports D1 D2
 pci 0000:00:12.2: PME# supported from D0 D1 D2 D3hot
 pci 0000:00:13.0: [1002:4397] type 00 class 0x0c0310
 pci 0000:00:13.0: reg 0x10: [mem 0xfbcfb000-0xfbcfbfff]
 pci 0000:00:13.1: [1002:4398] type 00 class 0x0c0310
 pci 0000:00:13.1: reg 0x10: [mem 0xfbcfc000-0xfbcfcfff]
 pci 0000:00:13.2: [1002:4396] type 00 class 0x0c0320
 pci 0000:00:13.2: reg 0x10: [mem 0xfbcff400-0xfbcff4ff]
 pci 0000:00:13.2: supports D1 D2
 pci 0000:00:13.2: PME# supported from D0 D1 D2 D3hot
 pci 0000:00:14.0: [1002:4385] type 00 class 0x0c0500
 pci 0000:00:14.1: [1002:439c] type 00 class 0x01018a
 pci 0000:00:14.1: reg 0x10: [io  0x0000-0x0007]
 pci 0000:00:14.1: reg 0x14: [io  0x0000-0x0003]
 pci 0000:00:14.1: reg 0x18: [io  0x0000-0x0007]
 pci 0000:00:14.1: reg 0x1c: [io  0x0000-0x0003]
 pci 0000:00:14.1: reg 0x20: [io  0xff00-0xff0f]
 pci 0000:00:14.1: legacy IDE quirk: reg 0x10: [io  0x01f0-0x01f7]
 pci 0000:00:14.1: legacy IDE quirk: reg 0x14: [io  0x03f6]
 pci 0000:00:14.1: legacy IDE quirk: reg 0x18: [io  0x0170-0x0177]
 pci 0000:00:14.1: legacy IDE quirk: reg 0x1c: [io  0x0376]
 pci 0000:00:14.2: [1002:4383] type 00 class 0x040300
 pci 0000:00:14.2: reg 0x10: [mem 0xfbcf4000-0xfbcf7fff 64bit]
 pci 0000:00:14.2: PME# supported from D0 D3hot D3cold
 pci 0000:00:14.3: [1002:439d] type 00 class 0x060100
 pci 0000:00:14.4: [1002:4384] type 01 class 0x060401
 pci 0000:00:14.5: [1002:4399] type 00 class 0x0c0310
 pci 0000:00:14.5: reg 0x10: [mem 0xfbcfa000-0xfbcfafff]
 pci 0000:00:18.0: [1022:1200] type 00 class 0x060000
 pci 0000:00:18.1: [1022:1201] type 00 class 0x060000
 pci 0000:00:18.2: [1022:1202] type 00 class 0x060000
 pci 0000:00:18.3: [1022:1203] type 00 class 0x060000
 pci 0000:00:18.4: [1022:1204] type 00 class 0x060000
 pci 0000:00:01.0: PCI bridge to [bus 01]
 pci 0000:00:01.0:   bridge window [io  0xd000-0xdfff]
 pci 0000:00:01.0:   bridge window [mem 0xfbd00000-0xfbefffff]
 pci 0000:00:01.0:   bridge window [mem 0xf0000000-0xf7ffffff 64bit pref]
 pci 0000:01:05.0: [1002:9614] type 00 class 0x030000
 pci 0000:01:05.0: reg 0x10: [mem 0xf0000000-0xf7ffffff pref]
 pci 0000:01:05.0: reg 0x14: [io  0xd000-0xd0ff]
 pci 0000:01:05.0: reg 0x18: [mem 0xfbee0000-0xfbeeffff]
 pci 0000:01:05.0: reg 0x24: [mem 0xfbd00000-0xfbdfffff]
 pci 0000:01:05.0: supports D1 D2
 pci 0000:01:05.1: [1002:960f] type 00 class 0x040300
 pci 0000:01:05.1: reg 0x10: [mem 0xfbefc000-0xfbefffff]
 pci 0000:01:05.1: supports D1 D2
 pci 0000:00:06.0: PCI bridge to [bus 02]
 pci 0000:00:06.0:   bridge window [io  0xe000-0xefff]
 pci 0000:00:06.0:   bridge window [mem 0xfbf00000-0xfbffffff]
 pci 0000:02:00.0: [1969:1026] type 00 class 0x020000
 pci 0000:02:00.0: reg 0x10: [mem 0xfbfc0000-0xfbffffff 64bit]
 pci 0000:02:00.0: reg 0x18: [io  0xec00-0xec7f]
 pci 0000:02:00.0: PME# supported from D3hot D3cold
 pci 0000:00:14.4: PCI bridge to [bus 03] (subtractive decode)
 pci 0000:00:14.4:   bridge window [io  0x0000-0x0cf7 window] (subtractive decode)
 pci 0000:00:14.4:   bridge window [io  0x0d00-0xffff window] (subtractive decode)
 pci 0000:00:14.4:   bridge window [mem 0x000a0000-0x000bffff window] (subtractive decode)
 pci 0000:00:14.4:   bridge window [mem 0x000d0000-0x000dffff window] (subtractive decode)
 pci 0000:00:14.4:   bridge window [mem 0xdff00000-0xdfffffff window] (subtractive decode)
 pci 0000:00:14.4:   bridge window [mem 0xf0000000-0xfebfffff window] (subtractive decode)
 pci_bus 0000:00: on NUMA node 0
 ACPI: PCI Interrupt Link [LNKA] (IRQs 4 7 10 *11 12 14 15)
 ACPI: PCI Interrupt Link [LNKB] (IRQs *4 7 10 11 12 14 15)
 ACPI: PCI Interrupt Link [LNKC] (IRQs 4 7 *10 11 12 14 15)
 ACPI: PCI Interrupt Link [LNKD] (IRQs 4 *7 10 11 12 14 15)
 ACPI: PCI Interrupt Link [LNKE] (IRQs 4 7 10 11 12 14 15) *0, disabled.
 ACPI: PCI Interrupt Link [LNKF] (IRQs 4 7 10 11 12 14 15) *0, disabled.
 ACPI: PCI Interrupt Link [LNKG] (IRQs 4 7 *10 11 12 14 15)
 ACPI: PCI Interrupt Link [LNKH] (IRQs 4 7 10 11 12 14 15) *0, disabled.
 ACPI: Enabled 1 GPEs in block 00 to 1F
 SCSI subsystem initialized
 libata version 3.00 loaded.
 ACPI: bus type USB registered
 usbcore: registered new interface driver usbfs
 usbcore: registered new interface driver hub
 usbcore: registered new device driver usb
 EDAC MC: Ver: 3.0.0
 Advanced Linux Sound Architecture Driver Initialized.
 PCI: Using ACPI for IRQ routing
 PCI: pci_cache_line_size set to 64 bytes
 e820: reserve RAM buffer [mem 0x0009fc00-0x0009ffff]
 e820: reserve RAM buffer [mem 0xdfe90000-0xdfffffff]
 hpet0: at MMIO 0xfed00000, IRQs 2, 8, 0, 0
 hpet0: 4 comparators, 32-bit 14.318180 MHz counter
 clocksource: Switched to clocksource hpet
 pnp: PnP ACPI init
 system 00:00: Plug and Play ACPI device, IDs PNP0c02 (active)
 pnp 00:01: Plug and Play ACPI device, IDs PNP0b00 (active)
 system 00:02: [mem 0xfec00000-0xfec00fff] could not be reserved
 system 00:02: [mem 0xfee00000-0xfee00fff] has been reserved
 system 00:02: Plug and Play ACPI device, IDs PNP0c02 (active)
 system 00:03: [io  0x04d0-0x04d1] has been reserved
 system 00:03: [io  0x040b] has been reserved
 system 00:03: [io  0x04d6] has been reserved
 system 00:03: [io  0x0c00-0x0c01] has been reserved
 system 00:03: [io  0x0c14] has been reserved
 system 00:03: [io  0x0c50-0x0c51] has been reserved
 system 00:03: [io  0x0c52] has been reserved
 system 00:03: [io  0x0c6c] has been reserved
 system 00:03: [io  0x0c6f] has been reserved
 system 00:03: [io  0x0cd0-0x0cd1] has been reserved
 system 00:03: [io  0x0cd2-0x0cd3] has been reserved
 system 00:03: [io  0x0cd4-0x0cd5] has been reserved
 system 00:03: [io  0x0cd6-0x0cd7] has been reserved
 system 00:03: [io  0x0cd8-0x0cdf] has been reserved
 system 00:03: [io  0x0b00-0x0b3f] has been reserved
 system 00:03: [io  0x0800-0x089f] could not be reserved
 system 00:03: [io  0x0b00-0x0b0f] has been reserved
 system 00:03: [io  0x0b20-0x0b3f] has been reserved
 system 00:03: [io  0x0900-0x090f] has been reserved
 system 00:03: [io  0x0910-0x091f] has been reserved
 system 00:03: [io  0xfe00-0xfefe] has been reserved
 system 00:03: [mem 0xdff00000-0xdfffffff] has been reserved
 system 00:03: [mem 0xffb80000-0xffbfffff] has been reserved
 system 00:03: [mem 0xfec10000-0xfec1001f] has been reserved
 system 00:03: Plug and Play ACPI device, IDs PNP0c02 (active)
 system 00:04: [io  0x0230-0x023f] has been reserved
 system 00:04: [io  0x0290-0x029f] has been reserved
 system 00:04: [io  0x0f40-0x0f4f] has been reserved
 system 00:04: [io  0x0a30-0x0a3f] has been reserved
 system 00:04: Plug and Play ACPI device, IDs PNP0c02 (active)
 system 00:05: [mem 0xe0000000-0xefffffff] has been reserved
 system 00:05: Plug and Play ACPI device, IDs PNP0c02 (active)
 system 00:06: [mem 0x00000000-0x0009ffff] could not be reserved
 system 00:06: [mem 0x000c0000-0x000cffff] could not be reserved
 system 00:06: [mem 0x000e0000-0x000fffff] could not be reserved
 system 00:06: [mem 0x00100000-0xdfefffff] could not be reserved
 system 00:06: [mem 0xfec00000-0xffffffff] could not be reserved
 system 00:06: Plug and Play ACPI device, IDs PNP0c01 (active)
 pnp: PnP ACPI: found 7 devices
 clocksource: acpi_pm: mask: 0xffffff max_cycles: 0xffffff, max_idle_ns: 2085701024 ns
 pci 0000:00:01.0: PCI bridge to [bus 01]
 pci 0000:00:01.0:   bridge window [io  0xd000-0xdfff]
 pci 0000:00:01.0:   bridge window [mem 0xfbd00000-0xfbefffff]
 pci 0000:00:01.0:   bridge window [mem 0xf0000000-0xf7ffffff 64bit pref]
 pci 0000:00:06.0: PCI bridge to [bus 02]
 pci 0000:00:06.0:   bridge window [io  0xe000-0xefff]
 pci 0000:00:06.0:   bridge window [mem 0xfbf00000-0xfbffffff]
 pci 0000:00:14.4: PCI bridge to [bus 03]
 pci_bus 0000:00: resource 4 [io  0x0000-0x0cf7 window]
 pci_bus 0000:00: resource 5 [io  0x0d00-0xffff window]
 pci_bus 0000:00: resource 6 [mem 0x000a0000-0x000bffff window]
 pci_bus 0000:00: resource 7 [mem 0x000d0000-0x000dffff window]
 pci_bus 0000:00: resource 8 [mem 0xdff00000-0xdfffffff window]
 pci_bus 0000:00: resource 9 [mem 0xf0000000-0xfebfffff window]
 pci_bus 0000:01: resource 0 [io  0xd000-0xdfff]
 pci_bus 0000:01: resource 1 [mem 0xfbd00000-0xfbefffff]
 pci_bus 0000:01: resource 2 [mem 0xf0000000-0xf7ffffff 64bit pref]
 pci_bus 0000:02: resource 0 [io  0xe000-0xefff]
 pci_bus 0000:02: resource 1 [mem 0xfbf00000-0xfbffffff]
 pci_bus 0000:03: resource 4 [io  0x0000-0x0cf7 window]
 pci_bus 0000:03: resource 5 [io  0x0d00-0xffff window]
 pci_bus 0000:03: resource 6 [mem 0x000a0000-0x000bffff window]
 pci_bus 0000:03: resource 7 [mem 0x000d0000-0x000dffff window]
 pci_bus 0000:03: resource 8 [mem 0xdff00000-0xdfffffff window]
 pci_bus 0000:03: resource 9 [mem 0xf0000000-0xfebfffff window]
 NET: Registered protocol family 2
 TCP established hash table entries: 65536 (order: 7, 524288 bytes)
 TCP bind hash table entries: 65536 (order: 8, 1048576 bytes)
 TCP: Hash tables configured (established 65536 bind 65536)
 UDP hash table entries: 4096 (order: 5, 131072 bytes)
 UDP-Lite hash table entries: 4096 (order: 5, 131072 bytes)
 NET: Registered protocol family 1
 pci 0000:00:01.0: MSI quirk detected; subordinate MSI disabled
 pci 0000:01:05.0: Video device with shadowed ROM
 PCI: CLS 64 bytes, default 64
 PCI-DMA: Using software bounce buffering for IO (SWIOTLB)
 software IO TLB [mem 0xdbe90000-0xdfe90000] (64MB) mapped at [ffff8800dbe90000-ffff8800dfe8ffff]
 kvm: Nested Virtualization enabled
 kvm: Nested Paging enabled
 microcode: CPU0: patch_level=0x010000c6
 microcode: CPU1: patch_level=0x010000c6
 microcode: CPU2: patch_level=0x010000c6
 microcode: CPU3: patch_level=0x010000c6
 microcode: Microcode Update Driver: v2.00 <tigran@aivazian.fsnet.co.uk>, Peter Oruba
 LVT offset 1 assigned for vector 0x400
 IBS: LVT offset 1 assigned
 perf: AMD IBS detected (0x0000001f)
 futex hash table entries: 1024 (order: 4, 65536 bytes)
 9p: Installing v9fs 9p2000 file system support
 Block layer SCSI generic (bsg) driver version 0.4 loaded (major 253)
 io scheduler noop registered
 io scheduler deadline registered (default)
 io scheduler cfq registered
 ACPI: processor limited to max C-state 1
 Serial: 8250/16550 driver, 4 ports, IRQ sharing disabled
 [drm] Initialized drm 1.1.0 20060810
 [drm] radeon kernel modesetting enabled.
 [drm] initializing kernel modesetting (RS780 0x1002:0x9614 0x1043:0x834D).
 [drm] register mmio base: 0xFBEE0000
 [drm] register mmio size: 65536
 ATOM BIOS: 113
 radeon 0000:01:05.0: VRAM: 128M 0x00000000C0000000 - 0x00000000C7FFFFFF (128M used)
 radeon 0000:01:05.0: GTT: 512M 0x00000000A0000000 - 0x00000000BFFFFFFF
 [drm] Detected VRAM RAM=128M, BAR=128M
 [drm] RAM width 32bits DDR
 [TTM] Zone  kernel: Available graphics memory: 4079190 kiB
 [TTM] Zone   dma32: Available graphics memory: 2097152 kiB
 [TTM] Initializing pool allocator
 [TTM] Initializing DMA pool allocator
 [drm] radeon: 128M of VRAM memory ready
 [drm] radeon: 512M of GTT memory ready.
 [drm] Loading RS780 Microcode
 == power state 0 ==
 	ui class: none
 	internal class: boot 
 	caps: video 
 	uvd    vclk: 0 dclk: 0
 		power level 0    sclk: 50000 vddc_index: 2
 		power level 1    sclk: 50000 vddc_index: 2
 	status: c r b 
 == power state 1 ==
 	ui class: performance
 	internal class: none
 	caps: video 
 	uvd    vclk: 0 dclk: 0
 		power level 0    sclk: 50000 vddc_index: 1
 		power level 1    sclk: 70000 vddc_index: 2
 	status: 
 == power state 2 ==
 	ui class: none
 	internal class: uvd 
 	caps: video 
 	uvd    vclk: 53300 dclk: 40000
 		power level 0    sclk: 50000 vddc_index: 1
 		power level 1    sclk: 50000 vddc_index: 1
 	status: 
 [drm] radeon: dpm initialized
 [drm] GART: num cpu pages 131072, num gpu pages 131072
 [drm] PCIE GART of 512M enabled (table at 0x00000000C0040000).
 radeon 0000:01:05.0: WB enabled
 radeon 0000:01:05.0: fence driver on ring 0 use gpu addr 0x00000000a0000c00 and cpu addr 0xffff8800db929c00
 [drm] Supports vblank timestamp caching Rev 2 (21.10.2013).
 [drm] Driver supports precise vblank timestamp query.
 radeon 0000:01:05.0: radeon: MSI limited to 32-bit
 [drm] radeon: irq initialized.
 [drm] ring test on 0 succeeded in 1 usecs
 [drm] ib test on ring 0 succeeded in 0 usecs
 [drm] Radeon Display Connectors
 [drm] Connector 0:
 [drm]   VGA-1
 [drm]   DDC: 0x7e40 0x7e40 0x7e44 0x7e44 0x7e48 0x7e48 0x7e4c 0x7e4c
 [drm]   Encoders:
 [drm]     CRT1: INTERNAL_KLDSCP_DAC1
 [drm] Connector 1:
 [drm]   DVI-D-1
 [drm]   HPD3
 [drm]   DDC: 0x7e50 0x7e50 0x7e54 0x7e54 0x7e58 0x7e58 0x7e5c 0x7e5c
 [drm]   Encoders:
 [drm]     DFP3: INTERNAL_KLDSCP_LVTMA
 switching from power state:
 	ui class: none
 	internal class: boot 
 	caps: video 
 	uvd    vclk: 0 dclk: 0
 		power level 0    sclk: 50000 vddc_index: 2
 		power level 1    sclk: 50000 vddc_index: 2
 	status: c b 
 switching to power state:
 	ui class: performance
 	internal class: none
 	caps: video 
 	uvd    vclk: 0 dclk: 0
 		power level 0    sclk: 50000 vddc_index: 1
 		power level 1    sclk: 70000 vddc_index: 2
 	status: r 
 [drm] fb mappable at 0xF0141000
 [drm] vram apper at 0xF0000000
 [drm] size 7299072
 [drm] fb depth is 24
 [drm]    pitch is 6912
 fbcon: radeondrmfb (fb0) is primary device
 Console: switching to colour frame buffer device 131x105
 radeon 0000:01:05.0: fb0: radeondrmfb frame buffer device
 [drm] Initialized radeon 2.43.0 20080528 for 0000:01:05.0 on minor 0
 loop: module loaded
 ahci 0000:00:11.0: version 3.0
 ahci 0000:00:11.0: AHCI 0001.0100 32 slots 6 ports 3 Gbps 0x3f impl SATA mode
 ahci 0000:00:11.0: flags: 64bit ncq sntf ilck pm led clo pmp pio slum part ccc 
 scsi host0: ahci
 scsi host1: ahci
 scsi host2: ahci
 scsi host3: ahci
 scsi host4: ahci
 scsi host5: ahci
 ata1: SATA max UDMA/133 abar m1024@0xfbcffc00 port 0xfbcffd00 irq 22
 ata2: SATA max UDMA/133 abar m1024@0xfbcffc00 port 0xfbcffd80 irq 22
 ata3: SATA max UDMA/133 abar m1024@0xfbcffc00 port 0xfbcffe00 irq 22
 ata4: SATA max UDMA/133 abar m1024@0xfbcffc00 port 0xfbcffe80 irq 22
 ata5: SATA max UDMA/133 abar m1024@0xfbcffc00 port 0xfbcfff00 irq 22
 ata6: SATA max UDMA/133 abar m1024@0xfbcffc00 port 0xfbcfff80 irq 22
 tun: Universal TUN/TAP device driver, 1.6
 tun: (C) 1999-2004 Max Krasnyansky <maxk@qualcomm.com>
 ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
 ehci-pci: EHCI PCI platform driver
 QUIRK: Enable AMD PLL fix
 ehci-pci 0000:00:12.2: EHCI Host Controller
 ehci-pci 0000:00:12.2: new USB bus registered, assigned bus number 1
 ehci-pci 0000:00:12.2: applying AMD SB700/SB800/Hudson-2/3 EHCI dummy qh workaround
 ehci-pci 0000:00:12.2: applying AMD SB600/SB700 USB freeze workaround
 ehci-pci 0000:00:12.2: debug port 1
 ehci-pci 0000:00:12.2: irq 17, io mem 0xfbcff800
 ehci-pci 0000:00:12.2: USB 2.0 started, EHCI 1.00
 hub 1-0:1.0: USB hub found
 hub 1-0:1.0: 6 ports detected
 ehci-pci 0000:00:13.2: EHCI Host Controller
 ehci-pci 0000:00:13.2: new USB bus registered, assigned bus number 2
 ehci-pci 0000:00:13.2: applying AMD SB700/SB800/Hudson-2/3 EHCI dummy qh workaround
 ehci-pci 0000:00:13.2: applying AMD SB600/SB700 USB freeze workaround
 ehci-pci 0000:00:13.2: debug port 1
 ehci-pci 0000:00:13.2: irq 19, io mem 0xfbcff400
 ehci-pci 0000:00:13.2: USB 2.0 started, EHCI 1.00
 hub 2-0:1.0: USB hub found
 hub 2-0:1.0: 6 ports detected
 ohci_hcd: USB 1.1 'Open' Host Controller (OHCI) Driver
 ohci-pci: OHCI PCI platform driver
 ohci-pci 0000:00:12.0: OHCI PCI host controller
 ohci-pci 0000:00:12.0: new USB bus registered, assigned bus number 3
 ohci-pci 0000:00:12.0: irq 16, io mem 0xfbcfd000
 hub 3-0:1.0: USB hub found
 hub 3-0:1.0: 3 ports detected
 ohci-pci 0000:00:12.1: OHCI PCI host controller
 ohci-pci 0000:00:12.1: new USB bus registered, assigned bus number 4
 ohci-pci 0000:00:12.1: irq 16, io mem 0xfbcfe000
 hub 4-0:1.0: USB hub found
 hub 4-0:1.0: 3 ports detected
 ohci-pci 0000:00:13.0: OHCI PCI host controller
 ohci-pci 0000:00:13.0: new USB bus registered, assigned bus number 5
 ohci-pci 0000:00:13.0: irq 18, io mem 0xfbcfb000
 hub 5-0:1.0: USB hub found
 hub 5-0:1.0: 3 ports detected
 ohci-pci 0000:00:13.1: OHCI PCI host controller
 ohci-pci 0000:00:13.1: new USB bus registered, assigned bus number 6
 ohci-pci 0000:00:13.1: irq 18, io mem 0xfbcfc000
 hub 6-0:1.0: USB hub found
 hub 6-0:1.0: 3 ports detected
 ohci-pci 0000:00:14.5: OHCI PCI host controller
 ohci-pci 0000:00:14.5: new USB bus registered, assigned bus number 7
 ohci-pci 0000:00:14.5: irq 18, io mem 0xfbcfa000
 ata1: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
 ata3: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
 ata6: SATA link down (SStatus 0 SControl 300)
 ata4: SATA link down (SStatus 0 SControl 300)
 ata5: SATA link down (SStatus 0 SControl 300)
 ata2: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
 ata1.00: ATA-8: OCZ VERTEX-TURBO, 1.7, max UDMA/133
 ata1.00: 62533296 sectors, multi 1: LBA48 NCQ (depth 31/32), AA
 ata3.00: ATA-9: M4-CT128M4SSD2, 0309, max UDMA/100
 ata3.00: 250069680 sectors, multi 16: LBA48 NCQ (depth 31/32), AA
 ata2.00: ATA-9: ST2000DM001-1CH164, CC29, max UDMA/133
 ata2.00: 3907029168 sectors, multi 16: LBA48 NCQ (depth 31/32), AA
 ata3.00: configured for UDMA/100
 ata2.00: configured for UDMA/133
 ata1.00: configured for UDMA/133
 scsi 0:0:0:0: Direct-Access     ATA      OCZ VERTEX-TURBO 1.7  PQ: 0 ANSI: 5
 sd 0:0:0:0: Attached scsi generic sg0 type 0
 sd 0:0:0:0: [sda] 62533296 512-byte logical blocks: (32.0 GB/29.8 GiB)
 scsi 1:0:0:0: Direct-Access     ATA      ST2000DM001-1CH1 CC29 PQ: 0 ANSI: 5
 sd 0:0:0:0: [sda] Write Protect is off
 sd 0:0:0:0: [sda] Mode Sense: 00 3a 00 00
 sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
 sd 1:0:0:0: [sdb] 3907029168 512-byte logical blocks: (2.00 TB/1.81 TiB)
 sd 1:0:0:0: [sdb] 4096-byte physical blocks
 sd 1:0:0:0: Attached scsi generic sg1 type 0
 sd 1:0:0:0: [sdb] Write Protect is off
 sd 1:0:0:0: [sdb] Mode Sense: 00 3a 00 00
 sd 1:0:0:0: [sdb] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
 scsi 2:0:0:0: Direct-Access     ATA      M4-CT128M4SSD2   0309 PQ: 0 ANSI: 5
 sd 2:0:0:0: [sdc] 250069680 512-byte logical blocks: (128 GB/119 GiB)
 sd 2:0:0:0: Attached scsi generic sg2 type 0
 sd 2:0:0:0: [sdc] Write Protect is off
 sd 2:0:0:0: [sdc] Mode Sense: 00 3a 00 00
 sd 2:0:0:0: [sdc] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
 sda: sda1 sda2 sda3
 sd 0:0:0:0: [sda] Attached SCSI disk
 sdc: sdc1 sdc2 sdc3
 sd 2:0:0:0: [sdc] Attached SCSI disk
 hub 7-0:1.0: USB hub found
 hub 7-0:1.0: 2 ports detected
 usbcore: registered new interface driver usblp
 usbcore: registered new interface driver usb-storage
 i8042: PNP: No PS/2 controller found. Probing ports directly.
 serio: i8042 KBD port at 0x60,0x64 irq 1
 serio: i8042 AUX port at 0x60,0x64 irq 12
 mousedev: PS/2 mouse device common for all mice
 rtc_cmos 00:01: RTC can wake from S4
 rtc_cmos 00:01: rtc core: registered rtc_cmos as rtc0
 rtc_cmos 00:01: alarms up to one month, y3k, 114 bytes nvram, hpet irqs
 i2c /dev entries driver
 AMD64 EDAC driver v3.4.0
 EDAC amd64: DRAM ECC enabled.
 EDAC amd64: F10h detected (node 0).
 EDAC MC: DCT0 chip selects:
 EDAC amd64: MC: 0:  1024MB 1:  1024MB
 EDAC amd64: MC: 2:  1024MB 3:  1024MB
 EDAC amd64: MC: 4:     0MB 5:     0MB
 EDAC amd64: MC: 6:     0MB 7:     0MB
 EDAC MC: DCT1 chip selects:
 EDAC amd64: MC: 0:  1024MB 1:  1024MB
 EDAC amd64: MC: 2:  1024MB 3:  1024MB
 EDAC amd64: MC: 4:     0MB 5:     0MB
 EDAC amd64: MC: 6:     0MB 7:     0MB
 EDAC amd64: using x4 syndromes.
 EDAC amd64: MCT channel count: 2
 EDAC MC0: Giving out device to module amd64_edac controller F10h: DEV 0000:00:18.2 (INTERRUPT)
 EDAC PCI0: Giving out device to module amd64_edac controller EDAC PCI controller: DEV 0000:00:18.2 (POLLED)
 hidraw: raw HID events driver (C) Jiri Kosina
 usbcore: registered new interface driver usbhid
 usbhid: USB HID core driver
 usbcore: registered new interface driver snd-usb-audio
 Netfilter messages via NETLINK v0.30.
 nf_conntrack version 0.5.0 (65536 buckets, 262144 max)
 ctnetlink v0.93: registering with nfnetlink.
 ip_tables: (C) 2000-2006 Netfilter Core Team
 NET: Registered protocol family 17
 9pnet: Installing 9P2000 support
 registered taskstats version 1
 Btrfs loaded
 rtc_cmos 00:01: setting system clock to 2015-09-18 06:10:55 UTC (1442556655)
 acpi-cpufreq: overriding BIOS provided _PSD data
 ALSA device list:
 No soundcards found.
 snd_hda_codec_generic hdaudioC1D0: autoconfig for ID 791a: line_outs=0 (0x0/0x0/0x0/0x0/0x0) type:line
 snd_hda_codec_generic hdaudioC1D0:    speaker_outs=0 (0x0/0x0/0x0/0x0/0x0)
 snd_hda_codec_generic hdaudioC1D0:    hp_outs=0 (0x0/0x0/0x0/0x0/0x0)
 snd_hda_codec_generic hdaudioC1D0:    mono: mono_out=0x0
 snd_hda_codec_generic hdaudioC1D0:    dig-out=0x3/0x0
 snd_hda_codec_generic hdaudioC1D0:    inputs:
 snd_hda_codec_via hdaudioC0D0: autoconfig for VT1708S: line_outs=4 (0x1c/0x19/0x22/0x23/0x0) type:line
 snd_hda_codec_via hdaudioC0D0:    speaker_outs=0 (0x0/0x0/0x0/0x0/0x0)
 snd_hda_codec_via hdaudioC0D0:    hp_outs=1 (0x1d/0x0/0x0/0x0/0x0)
 snd_hda_codec_via hdaudioC0D0:    mono: mono_out=0x0
 snd_hda_codec_via hdaudioC0D0:    dig-out=0x20/0x21
 snd_hda_codec_via hdaudioC0D0:    inputs:
 snd_hda_codec_via hdaudioC0D0:      Rear Mic=0x1a
 snd_hda_codec_via hdaudioC0D0:      Front Mic=0x1e
 snd_hda_codec_via hdaudioC0D0:      Line=0x1b
 snd_hda_codec_via hdaudioC0D0:      CD=0x1f
 input: HDA ATI HDMI HDMI as /devices/pci0000:00/0000:00:01.0/0000:01:05.1/sound/card1/input1
 input: HDA ATI SB Rear Mic as /devices/pci0000:00/0000:00:14.2/sound/card0/input2
 input: HDA ATI SB Front Mic as /devices/pci0000:00/0000:00:14.2/sound/card0/input3
 input: HDA ATI SB Line as /devices/pci0000:00/0000:00:14.2/sound/card0/input4
 input: HDA ATI SB Line Out Front as /devices/pci0000:00/0000:00:14.2/sound/card0/input5
 input: HDA ATI SB Line Out Surround as /devices/pci0000:00/0000:00:14.2/sound/card0/input6
 input: HDA ATI SB Line Out CLFE as /devices/pci0000:00/0000:00:14.2/sound/card0/input7
 input: HDA ATI SB Line Out Side as /devices/pci0000:00/0000:00:14.2/sound/card0/input8
 input: HDA ATI SB Front Headphone as /devices/pci0000:00/0000:00:14.2/sound/card0/input9
 sdb: sdb1 sdb2
 sd 1:0:0:0: [sdb] Attached SCSI disk
 UDF-fs: warning (device sdc3): udf_fill_super: No partition found (2)
 BTRFS: device fsid 7ef56edc-673e-452e-9e05-3fabf074168b devid 1 transid 25151 /dev/root
 BTRFS info (device sdc3): disk space caching is enabled
 BTRFS: has skinny extents
 BTRFS: detected SSD devices, enabling SSD mode
 VFS: Mounted root (btrfs filesystem) readonly on device 0:15.
 devtmpfs: mounted
 Freeing unused kernel memory: 744K (ffffffff82071000 - ffffffff8212b000)
 Write protecting the kernel read-only data: 16384k
 Freeing unused kernel memory: 1644K (ffff880001a65000 - ffff880001c00000)
 Freeing unused kernel memory: 1972K (ffff880001e13000 - ffff880002000000)
 usb 3-1: new low-speed USB device number 2 using ohci-pci
 usb 4-2: new full-speed USB device number 2 using ohci-pci
 input: HID 046a:0011 as /devices/pci0000:00/0000:00:12.0/usb3/3-1/3-1:1.0/0003:046A:0011.0001/input/input11
 BTRFS: device fsid 6b7d75bf-3d12-409c-88ed-500ac6b78510 devid 1 transid 396334 /dev/sdb2
 BTRFS info (device sdb2): disk space caching is enabled
 hid-generic 0003:046A:0011.0001: input,hidraw0: USB HID v1.10 Keyboard [HID 046a:0011] on usb-0000:00:12.0-1/input0
 tsc: Refined TSC clocksource calibration: 3210.826 MHz
 clocksource: tsc: mask: 0xffffffffffffffff max_cycles: 0x2e483d1f2ca, max_idle_ns: 440795239699 ns
 logitech-djreceiver 0003:046D:C52B.0004: hiddev0,hidraw1: USB HID v1.11 Device [Logitech USB Receiver] on usb-0000:00:12.1-2/input2
 input: Logitech T400 as /devices/pci0000:00/0000:00:12.1/usb4/4-2/4-2:1.2/0003:046D:C52B.0004/0003:046D:4026.0005/input/input12
 logitech-hidpp-device 0003:046D:4026.0005: input,hidraw2: USB HID v1.11 Keyboard [Logitech T400] on usb-0000:00:12.1-2:1
 random: nonblocking pool is initialized
 clocksource: Switched to clocksource tsc
 BTRFS: device fsid 24cee7e4-9093-4f86-aa73-d8a59d7f3c6c devid 1 transid 16525 /dev/sda3
 BTRFS info (device sda3): disk space caching is enabled
 BTRFS: has skinny extents
 BTRFS: detected SSD devices, enabling SSD mode
 ATL1E 0000:02:00.0: swiotlb buffer is full (sz: 529461 bytes)
 swiotlb: coherent allocation failed for device 0000:02:00.0 size=529461
 CPU: 1 PID: 201 Comm: ifconfig Not tainted 4.3.0-rc1-00131-ga7d5c1897198-dirty #119
 Hardware name: System manufacturer System Product Name/M4A78T-E, BIOS 3503    04/13/2011
 0000000000081434 ffffffff81428dd3 0000000000000000 ffffffff8146e31b
 ffffffff00000008 ffff880216bca000 ffff880216bca740 ffff880216b46800
 0000000000081435 ffffffff820163c0 0000000000000000 ffffffff817dd982
 Call Trace:
 [<ffffffff81428dd3>] ? dump_stack+0x40/0x6d
 [<ffffffff8146e31b>] ? swiotlb_alloc_coherent+0x17b/0x1a0
 [<ffffffff817dd982>] ? atl1e_open+0x362/0x540
 [<ffffffff817dd620>] ? atl1e_resume+0x120/0x120
 [<ffffffff8199c5e0>] ? eth_change_mtu+0x20/0x20
 [<ffffffff81970dde>] ? __dev_open+0x9e/0x1c0
 [<ffffffff81979df7>] ? __dev_change_flags+0x2f7/0x440
 [<ffffffff8197a0a0>] ? dev_change_flags+0x20/0x180
 [<ffffffff81a22f63>] ? devinet_ioctl+0x683/0x7e0
 [<ffffffff8194f40a>] ? sock_ioctl+0x16a/0x200
 [<ffffffff811db28a>] ? SyS_ioctl+0x2ca/0x500
 [<ffffffff8109a847>] ? __do_page_fault+0x147/0x420
 [<ffffffff810a80d7>] ? entry_SYSCALL_64_fastpath+0x12/0x66
 ATL1E 0000:02:00.0 eth0: pci_alloc_consistent failed, size = D529461
 BTRFS info (device sdc3): disk space caching is enabled
 microcode: CPU0: new patch_level=0x010000db
 microcode: CPU1: new patch_level=0x010000db
 microcode: CPU2: new patch_level=0x010000db
 microcode: CPU3: new patch_level=0x010000db
 Adding 4095996k swap on /dev/sdb1.  Priority:-1 extents:1 across:4095996k 

--jI8keyz6grp/JLjh
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=lspci

00:00.0 Host bridge: Advanced Micro Devices, Inc. [AMD] RS780 Host Bridge
	Subsystem: Advanced Micro Devices, Inc. [AMD] RS780 Host Bridge
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz+ UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort+ >SERR- <PERR- INTx-
	Latency: 0
	Capabilities: [c4] HyperTransport: Slave or Primary Interface
		Command: BaseUnitID=0 UnitCnt=12 MastHost- DefDir- DUL-
		Link Control 0: CFlE- CST- CFE- <LkFail- Init+ EOC- TXO- <CRCErr=0 IsocEn+ LSEn- ExtCTL- 64b-
		Link Config 0: MLWI=16bit DwFcIn- MLWO=16bit DwFcOut- LWI=16bit DwFcInEn- LWO=16bit DwFcOutEn-
		Link Control 1: CFlE- CST- CFE- <LkFail+ Init- EOC+ TXO+ <CRCErr=0 IsocEn- LSEn- ExtCTL- 64b-
		Link Config 1: MLWI=8bit DwFcIn- MLWO=8bit DwFcOut- LWI=8bit DwFcInEn- LWO=8bit DwFcOutEn-
		Revision ID: 3.00
		Link Frequency 0: [b]
		Link Error 0: <Prot- <Ovfl- <EOC- CTLTm-
		Link Frequency Capability 0: 200MHz+ 300MHz- 400MHz+ 500MHz- 600MHz+ 800MHz+ 1.0GHz+ 1.2GHz- 1.4GHz- 1.6GHz- Vend-
		Feature Capability: IsocFC- LDTSTOP+ CRCTM- ECTLT- 64bA- UIDRD-
		Link Frequency 1: 200MHz
		Link Error 1: <Prot- <Ovfl- <EOC- CTLTm-
		Link Frequency Capability 1: 200MHz- 300MHz- 400MHz- 500MHz- 600MHz- 800MHz- 1.0GHz- 1.2GHz- 1.4GHz- 1.6GHz- Vend-
		Error Handling: PFlE- OFlE- PFE- OFE- EOCFE- RFE- CRCFE- SERRFE- CF- RE- PNFE- ONFE- EOCNFE- RNFE- CRCNFE- SERRNFE-
		Prefetchable memory behind bridge Upper: 00-00
		Bus Number: 00
	Capabilities: [54] HyperTransport: UnitID Clumping
	Capabilities: [40] HyperTransport: Retry Mode
	Capabilities: [9c] HyperTransport: #1a
	Capabilities: [f8] HyperTransport: #1c

00:01.0 PCI bridge: Advanced Micro Devices, Inc. [AMD] RS780/RS880 PCI to PCI bridge (int gfx) (prog-if 00 [Normal decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B- DisINTx-
	Status: Cap+ 66MHz+ UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 64
	Bus: primary=00, secondary=01, subordinate=01, sec-latency=64
	I/O behind bridge: 0000d000-0000dfff
	Memory behind bridge: fbd00000-fbefffff
	Prefetchable memory behind bridge: 00000000f0000000-00000000f7ffffff
	Secondary status: 66MHz+ FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort+ <SERR- <PERR-
	BridgeCtl: Parity- SERR+ NoISA- VGA+ MAbort- >Reset- FastB2B-
		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
	Capabilities: [44] HyperTransport: MSI Mapping Enable+ Fixed+
	Capabilities: [b0] Subsystem: Advanced Micro Devices, Inc. [AMD] RS780/RS880 PCI to PCI bridge (int gfx)

00:06.0 PCI bridge: Advanced Micro Devices, Inc. [AMD] RS780 PCI to PCI bridge (PCIE port 2) (prog-if 00 [Normal decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 64 bytes
	Interrupt: pin A routed to IRQ 10
	Bus: primary=00, secondary=02, subordinate=02, sec-latency=0
	I/O behind bridge: 0000e000-0000efff
	Memory behind bridge: fbf00000-fbffffff
	Prefetchable memory behind bridge: 00000000fff00000-00000000000fffff
	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort+ <SERR- <PERR-
	BridgeCtl: Parity+ SERR+ NoISA+ VGA- MAbort- >Reset- FastB2B-
		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
	Capabilities: [50] Power Management version 3
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [58] Express (v2) Root Port (Slot+), MSI 00
		DevCap:	MaxPayload 128 bytes, PhantFunc 0
			ExtTag+ RBE+
		DevCtl:	Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
			RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop+
			MaxPayload 128 bytes, MaxReadReq 128 bytes
		DevSta:	CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr- TransPend-
		LnkCap:	Port #3, Speed 5GT/s, Width x1, ASPM L0s L1, Exit Latency L0s <64ns, L1 <1us
			ClockPM- Surprise- LLActRep+ BwNot+ ASPMOptComp-
		LnkCtl:	ASPM Disabled; RCB 64 bytes Disabled- CommClk+
			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
		LnkSta:	Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+ DLActive+ BWMgmt+ ABWMgmt-
		SltCap:	AttnBtn- PwrCtrl- MRL- AttnInd- PwrInd- HotPlug- Surprise-
			Slot #6, PowerLimit 25.000W; Interlock- NoCompl+
		SltCtl:	Enable: AttnBtn- PwrFlt- MRL- PresDet- CmdCplt- HPIrq- LinkChg-
			Control: AttnInd Unknown, PwrInd Unknown, Power- Interlock-
		SltSta:	Status: AttnBtn- PowerFlt- MRL- CmdCplt- PresDet+ Interlock-
			Changed: MRL- PresDet+ LinkState+
		RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFatal- PMEIntEna- CRSVisible+
		RootCap: CRSVisible+
		RootSta: PME ReqID 0000, PMEStatus- PMEPending-
		DevCap2: Completion Timeout: Not Supported, TimeoutDis-, LTR-, OBFF Not Supported ARIFwd-
		DevCtl2: Completion Timeout: 50us to 50ms, TimeoutDis-, LTR-, OBFF Disabled ARIFwd-
		LnkCtl2: Target Link Speed: 2.5GT/s, EnterCompliance- SpeedDis-
			 Transmit Margin: Normal Operating Range, EnterModifiedCompliance- ComplianceSOS-
			 Compliance De-emphasis: -6dB
		LnkSta2: Current De-emphasis Level: -6dB, EqualizationComplete-, EqualizationPhase1-
			 EqualizationPhase2-, EqualizationPhase3-, LinkEqualizationRequest-
	Capabilities: [a0] MSI: Enable- Count=1/1 Maskable- 64bit-
		Address: 00000000  Data: 0000
	Capabilities: [b0] Subsystem: Advanced Micro Devices, Inc. [AMD] RS780 PCI to PCI bridge (PCIE port 2)
	Capabilities: [b8] HyperTransport: MSI Mapping Enable+ Fixed+
	Capabilities: [100 v1] Vendor Specific Information: ID=0001 Rev=1 Len=010 <?>
	Capabilities: [110 v1] Virtual Channel
		Caps:	LPEVC=0 RefClk=100ns PATEntryBits=1
		Arb:	Fixed- WRR32- WRR64- WRR128-
		Ctrl:	ArbSelect=Fixed
		Status:	InProgress-
		VC0:	Caps:	PATOffset=00 MaxTimeSlots=1 RejSnoopTrans-
			Arb:	Fixed+ WRR32- WRR64- WRR128- TWRR128- WRR256-
			Ctrl:	Enable+ ID=0 ArbSelect=Fixed TC/VC=ff
			Status:	NegoPending- InProgress-

00:11.0 SATA controller: Advanced Micro Devices, Inc. [AMD/ATI] SB7x0/SB8x0/SB9x0 SATA Controller [AHCI mode] (prog-if 01 [AHCI 1.0])
	Subsystem: Advanced Micro Devices, Inc. [AMD/ATI] SB7x0/SB8x0/SB9x0 SATA Controller [AHCI mode]
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B- DisINTx-
	Status: Cap+ 66MHz+ UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 64, Cache Line Size: 64 bytes
	Interrupt: pin A routed to IRQ 22
	Region 0: I/O ports at c000 [size=8]
	Region 1: I/O ports at b000 [size=4]
	Region 2: I/O ports at a000 [size=8]
	Region 3: I/O ports at 9000 [size=4]
	Region 4: I/O ports at 8000 [size=16]
	Region 5: Memory at fbcffc00 (32-bit, non-prefetchable) [size=1K]
	Capabilities: [70] SATA HBA v1.0 InCfgSpace
	Kernel driver in use: ahci

00:12.0 USB controller: Advanced Micro Devices, Inc. [AMD/ATI] SB7x0/SB8x0/SB9x0 USB OHCI0 Controller (prog-if 10 [OHCI])
	Subsystem: Advanced Micro Devices, Inc. [AMD/ATI] SB7x0/SB8x0/SB9x0 USB OHCI0 Controller
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B- DisINTx-
	Status: Cap- 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 64, Cache Line Size: 64 bytes
	Interrupt: pin A routed to IRQ 16
	Region 0: Memory at fbcfd000 (32-bit, non-prefetchable) [size=4K]
	Kernel driver in use: ohci-pci

00:12.1 USB controller: Advanced Micro Devices, Inc. [AMD/ATI] SB7x0 USB OHCI1 Controller (prog-if 10 [OHCI])
	Subsystem: Advanced Micro Devices, Inc. [AMD/ATI] SB7x0 USB OHCI1 Controller
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- Stepping- SERR+ FastB2B- DisINTx-
	Status: Cap- 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 64, Cache Line Size: 64 bytes
	Interrupt: pin A routed to IRQ 16
	Region 0: Memory at fbcfe000 (32-bit, non-prefetchable) [size=4K]
	Kernel driver in use: ohci-pci

00:12.2 USB controller: Advanced Micro Devices, Inc. [AMD/ATI] SB7x0/SB8x0/SB9x0 USB EHCI Controller (prog-if 20 [EHCI])
	Subsystem: Advanced Micro Devices, Inc. [AMD/ATI] SB7x0/SB8x0/SB9x0 USB EHCI Controller
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- Stepping- SERR+ FastB2B- DisINTx-
	Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 64, Cache Line Size: 64 bytes
	Interrupt: pin B routed to IRQ 17
	Region 0: Memory at fbcff800 (32-bit, non-prefetchable) [size=256]
	Capabilities: [c0] Power Management version 2
		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA PME(D0+,D1+,D2+,D3hot+,D3cold-)
		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME+
		Bridge: PM- B3+
	Capabilities: [e4] Debug port: BAR=1 offset=00e0
	Kernel driver in use: ehci-pci

00:13.0 USB controller: Advanced Micro Devices, Inc. [AMD/ATI] SB7x0/SB8x0/SB9x0 USB OHCI0 Controller (prog-if 10 [OHCI])
	Subsystem: Advanced Micro Devices, Inc. [AMD/ATI] SB7x0/SB8x0/SB9x0 USB OHCI0 Controller
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B- DisINTx-
	Status: Cap- 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 64, Cache Line Size: 64 bytes
	Interrupt: pin A routed to IRQ 18
	Region 0: Memory at fbcfb000 (32-bit, non-prefetchable) [size=4K]
	Kernel driver in use: ohci-pci

00:13.1 USB controller: Advanced Micro Devices, Inc. [AMD/ATI] SB7x0 USB OHCI1 Controller (prog-if 10 [OHCI])
	Subsystem: Advanced Micro Devices, Inc. [AMD/ATI] SB7x0 USB OHCI1 Controller
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- Stepping- SERR+ FastB2B- DisINTx-
	Status: Cap- 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 64, Cache Line Size: 64 bytes
	Interrupt: pin A routed to IRQ 18
	Region 0: Memory at fbcfc000 (32-bit, non-prefetchable) [size=4K]
	Kernel driver in use: ohci-pci

00:13.2 USB controller: Advanced Micro Devices, Inc. [AMD/ATI] SB7x0/SB8x0/SB9x0 USB EHCI Controller (prog-if 20 [EHCI])
	Subsystem: Advanced Micro Devices, Inc. [AMD/ATI] SB7x0/SB8x0/SB9x0 USB EHCI Controller
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- Stepping- SERR+ FastB2B- DisINTx-
	Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 64, Cache Line Size: 64 bytes
	Interrupt: pin B routed to IRQ 19
	Region 0: Memory at fbcff400 (32-bit, non-prefetchable) [size=256]
	Capabilities: [c0] Power Management version 2
		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA PME(D0+,D1+,D2+,D3hot+,D3cold-)
		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
		Bridge: PM- B3+
	Capabilities: [e4] Debug port: BAR=1 offset=00e0
	Kernel driver in use: ehci-pci

00:14.0 SMBus: Advanced Micro Devices, Inc. [AMD/ATI] SBx00 SMBus Controller (rev 3a)
	Subsystem: Advanced Micro Devices, Inc. [AMD/ATI] SBx00 SMBus Controller
	Control: I/O+ Mem+ BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+
	Status: Cap+ 66MHz+ UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Capabilities: [b0] HyperTransport: MSI Mapping Enable- Fixed+

00:14.1 IDE interface: Advanced Micro Devices, Inc. [AMD/ATI] SB7x0/SB8x0/SB9x0 IDE Controller (prog-if 8a [Master SecP PriP])
	Subsystem: Advanced Micro Devices, Inc. [AMD/ATI] SB7x0/SB8x0/SB9x0 IDE Controller
	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz+ UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin A routed to IRQ 0
	Region 0: I/O ports at 01f0 [size=8]
	Region 1: I/O ports at 03f4
	Region 2: I/O ports at 0170 [size=8]
	Region 3: I/O ports at 0374
	Region 4: I/O ports at ff00 [size=16]
	Capabilities: [70] MSI: Enable- Count=1/1 Maskable- 64bit-
		Address: 00000000  Data: 0000

00:14.2 Audio device: Advanced Micro Devices, Inc. [AMD/ATI] SBx00 Azalia (Intel HDA)
	Subsystem: ASUSTeK Computer Inc. SBx00 Azalia (Intel HDA)
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=slow >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 64, Cache Line Size: 64 bytes
	Interrupt: pin A routed to IRQ 16
	Region 0: Memory at fbcf4000 (64-bit, non-prefetchable) [size=16K]
	Capabilities: [50] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=55mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
	Kernel driver in use: snd_hda_intel

00:14.3 ISA bridge: Advanced Micro Devices, Inc. [AMD/ATI] SB7x0/SB8x0/SB9x0 LPC host controller
	Subsystem: Advanced Micro Devices, Inc. [AMD/ATI] SB7x0/SB8x0/SB9x0 LPC host controller
	Control: I/O+ Mem+ BusMaster+ SpecCycle+ MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap- 66MHz+ UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0

00:14.4 PCI bridge: Advanced Micro Devices, Inc. [AMD/ATI] SBx00 PCI to PCI Bridge (prog-if 01 [Subtractive decode])
	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B- DisINTx-
	Status: Cap- 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 64
	Bus: primary=00, secondary=03, subordinate=03, sec-latency=64
	I/O behind bridge: 0000f000-00000fff
	Memory behind bridge: fff00000-000fffff
	Prefetchable memory behind bridge: fff00000-000fffff
	Secondary status: 66MHz- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort+ <SERR- <PERR-
	BridgeCtl: Parity+ SERR+ NoISA+ VGA- MAbort- >Reset- FastB2B-
		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-

00:14.5 USB controller: Advanced Micro Devices, Inc. [AMD/ATI] SB7x0/SB8x0/SB9x0 USB OHCI2 Controller (prog-if 10 [OHCI])
	Subsystem: Advanced Micro Devices, Inc. [AMD/ATI] SB7x0/SB8x0/SB9x0 USB OHCI2 Controller
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B- DisINTx-
	Status: Cap- 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 64, Cache Line Size: 64 bytes
	Interrupt: pin C routed to IRQ 18
	Region 0: Memory at fbcfa000 (32-bit, non-prefetchable) [size=4K]
	Kernel driver in use: ohci-pci

00:18.0 Host bridge: Advanced Micro Devices, Inc. [AMD] Family 10h Processor HyperTransport Configuration
	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Capabilities: [80] HyperTransport: Host or Secondary Interface
		Command: WarmRst+ DblEnd- DevNum=0 ChainSide- HostHide+ Slave- <EOCErr- DUL-
		Link Control: CFlE- CST- CFE- <LkFail- Init+ EOC- TXO- <CRCErr=0 IsocEn+ LSEn+ ExtCTL- 64b-
		Link Config: MLWI=16bit DwFcIn- MLWO=16bit DwFcOut- LWI=16bit DwFcInEn- LWO=16bit DwFcOutEn-
		Revision ID: 3.00
		Link Frequency: [b]
		Link Error: <Prot- <Ovfl- <EOC- CTLTm-
		Link Frequency Capability: 200MHz+ 300MHz- 400MHz+ 500MHz- 600MHz+ 800MHz+ 1.0GHz+ 1.2GHz+ 1.4GHz- 1.6GHz- Vend-
		Feature Capability: IsocFC+ LDTSTOP+ CRCTM- ECTLT- 64bA+ UIDRD- ExtRS- UCnfE-

00:18.1 Host bridge: Advanced Micro Devices, Inc. [AMD] Family 10h Processor Address Map
	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-

00:18.2 Host bridge: Advanced Micro Devices, Inc. [AMD] Family 10h Processor DRAM Controller
	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Kernel driver in use: amd64_edac

00:18.3 Host bridge: Advanced Micro Devices, Inc. [AMD] Family 10h Processor Miscellaneous Control
	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Capabilities: [f0] Secure device <?>
	Kernel driver in use: k10temp

00:18.4 Host bridge: Advanced Micro Devices, Inc. [AMD] Family 10h Processor Link Control
	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-

01:05.0 VGA compatible controller: Advanced Micro Devices, Inc. [AMD/ATI] RS780D [Radeon HD 3300] (prog-if 00 [VGA controller])
	Subsystem: ASUSTeK Computer Inc. RS780D [Radeon HD 3300]
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 64 bytes
	Interrupt: pin A routed to IRQ 18
	Region 0: Memory at f0000000 (32-bit, prefetchable) [size=128M]
	Region 1: I/O ports at d000 [size=256]
	Region 2: Memory at fbee0000 (32-bit, non-prefetchable) [size=64K]
	Region 5: Memory at fbd00000 (32-bit, non-prefetchable) [size=1M]
	Expansion ROM at <unassigned> [disabled]
	Capabilities: [50] Power Management version 3
		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [a0] MSI: Enable- Count=1/1 Maskable- 64bit+
		Address: 0000000000000000  Data: 0000
	Kernel driver in use: radeon

01:05.1 Audio device: Advanced Micro Devices, Inc. [AMD/ATI] RS780 HDMI Audio [Radeon (HD) 3000 Series]
	Subsystem: Advanced Micro Devices, Inc. [AMD/ATI] RS780 HDMI Audio [Radeon (HD) 3000 Series]
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 64 bytes
	Interrupt: pin B routed to IRQ 19
	Region 0: Memory at fbefc000 (32-bit, non-prefetchable) [size=16K]
	Capabilities: [50] Power Management version 3
		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [a0] MSI: Enable- Count=1/1 Maskable- 64bit+
		Address: 0000000000000000  Data: 0000
	Kernel driver in use: snd_hda_intel

02:00.0 Ethernet controller: Qualcomm Atheros AR8121/AR8113/AR8114 Gigabit or Fast Ethernet (rev b0)
	Subsystem: ASUSTeK Computer Inc. AR8121/AR8113/AR8114 Gigabit or Fast Ethernet
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 64 bytes
	Interrupt: pin A routed to IRQ 18
	Region 0: Memory at fbfc0000 (64-bit, non-prefetchable) [size=256K]
	Region 2: I/O ports at ec00 [size=128]
	Capabilities: [40] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot+,D3cold+)
		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [48] MSI: Enable- Count=1/1 Maskable- 64bit+
		Address: 0000000000000000  Data: 0000
	Capabilities: [58] Express (v1) Endpoint, MSI 00
		DevCap:	MaxPayload 4096 bytes, PhantFunc 0, Latency L0s <4us, L1 unlimited
			ExtTag- AttnBtn+ AttnInd+ PwrInd+ RBE- FLReset-
		DevCtl:	Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
			RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
			MaxPayload 128 bytes, MaxReadReq 512 bytes
		DevSta:	CorrErr- UncorrErr+ FatalErr- UnsuppReq+ AuxPwr+ TransPend-
		LnkCap:	Port #0, Speed 2.5GT/s, Width x1, ASPM L0s, Exit Latency L0s unlimited, L1 unlimited
			ClockPM- Surprise- LLActRep- BwNot- ASPMOptComp-
		LnkCtl:	ASPM Disabled; RCB 64 bytes Disabled- CommClk+
			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
		LnkSta:	Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+ DLActive- BWMgmt- ABWMgmt-
	Capabilities: [100 v1] Advanced Error Reporting
		UESta:	DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq+ ACSViol-
		UEMsk:	DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
		UESvrt:	DLP+ SDES- TLP- FCP+ CmpltTO- CmpltAbrt- UnxCmplt- RxOF+ MalfTLP+ ECRC- UnsupReq- ACSViol-
		CESta:	RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr-
		CEMsk:	RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr-
		AERCap:	First Error Pointer: 14, GenCap+ CGenEn- ChkCap+ ChkEn-
	Capabilities: [180 v1] Device Serial Number ff-85-cb-a6-00-24-8c-ff
	Kernel driver in use: ATL1E


--jI8keyz6grp/JLjh--
