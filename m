From: "John Stoffel" <john-HgN6juyGXH5AfugRpC6u6w@public.gmane.org>
Subject: Re: usb_mon oops Re: tcpdump crashes 2.6.29.1 (and 2.6.29-rc5)
Date: Thu, 9 Apr 2009 09:59:31 -0400
Message-ID: <18909.65347.234817.29689@stoffel.org>
References: <18906.49779.243047.207639@stoffel.org>
	<20090407120022.GA6519@ff.dom.local>
	<18907.28788.965069.573489@stoffel.org>
	<20090407130403.e0061a8d.zaitcev@redhat.com>
	<18908.42166.404232.721757@stoffel.org>
	<20090408232344.afed8103.zaitcev@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "John Stoffel" <john-HgN6juyGXH5AfugRpC6u6w@public.gmane.org>,
	Jarek Poplawski <jarkao2-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Pete Zaitcev <zaitcev-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20090408232344.afed8103.zaitcev-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


Pete> On Wed, 8 Apr 2009 09:20:54 -0400, "John Stoffel" <john-HgN6juyGXH5AfugRpC6u6w@public.gmane.org> wrote:
>> Well I think that usbmon is probably at fault here for trusting
>> drivers too much and not doing any sanity checking. []

Pete> By the way, please send me a full dmesg from the affected system
Pete> and kernel. Any post-boot dmesg will do: I only want to see if
Pete> IOMMU is active, where the aperture is, and if 0x20a15cc0 is a
Pete> valid physical address.

I didn't get a chance to play with this last night, but since I'm now
running 2.6.29.1 with USB_MON turned off in the config, it hasn't
crashed when running tcpdump at all.

I'll recompile the kernel with USB_MON as a module and test it out
some more.

Here's a dmesg of bootup:

[    0.000000] Linux version 2.6.29.1 (john@sail) (gcc version 4.3.3 (Ubuntu 4.3.3-5ubuntu4) ) #24 SMP PREEMPT Tue Apr 7 11:30:52 EDT 2009
[    0.000000] Command line: root=/dev/sda2 ro earlyprintk=vga
[    0.000000] KERNEL supported cpus:
[    0.000000]   Intel GenuineIntel
[    0.000000]   AMD AuthenticAMD
[    0.000000]   Centaur CentaurHauls
[    0.000000] BIOS-provided physical RAM map:
[    0.000000]  BIOS-e820: 0000000000000000 - 000000000009f000 (usable)
[    0.000000]  BIOS-e820: 000000000009f000 - 00000000000a0000 (reserved)
[    0.000000]  BIOS-e820: 00000000000f0000 - 0000000000100000 (reserved)
[    0.000000]  BIOS-e820: 0000000000100000 - 00000000dfee0000 (usable)
[    0.000000]  BIOS-e820: 00000000dfee0000 - 00000000dfee3000 (ACPI NVS)
[    0.000000]  BIOS-e820: 00000000dfee3000 - 00000000dfef0000 (ACPI data)
[    0.000000]  BIOS-e820: 00000000dfef0000 - 00000000dff00000 (reserved)
[    0.000000]  BIOS-e820: 00000000f0000000 - 00000000f4000000 (reserved)
[    0.000000]  BIOS-e820: 00000000fec00000 - 0000000100000000 (reserved)
[    0.000000]  BIOS-e820: 0000000100000000 - 0000000120000000 (usable)
[    0.000000] console [earlyvga0] enabled
[    0.000000] DMI 2.4 present.
[    0.000000] Phoenix BIOS detected: BIOS may corrupt low RAM, working around it.
[    0.000000] last_pfn = 0x120000 max_arch_pfn = 0x100000000
[    0.000000] last_pfn = 0xdfee0 max_arch_pfn = 0x100000000
[    0.000000] init_memory_mapping: 0000000000000000-00000000dfee0000
[    0.000000]  0000000000 - 00dfe00000 page 2M
[    0.000000]  00dfe00000 - 00dfee0000 page 4k
[    0.000000] kernel direct mapping tables up to dfee0000 @ 10000-16000
[    0.000000] last_map_addr: dfee0000 end: dfee0000
[    0.000000] init_memory_mapping: 0000000100000000-0000000120000000
[    0.000000]  0100000000 - 0120000000 page 2M
[    0.000000] kernel direct mapping tables up to 120000000 @ 14000-1a000
[    0.000000] last_map_addr: 120000000 end: 120000000
[    0.000000] ACPI: RSDP 000F7C80, 0024 (r2 Nvidia)
[    0.000000] ACPI: XSDT DFEE3100, 004C (r1 Nvidia ASUSACPI 42302E31 AWRD        0)
[    0.000000] ACPI: FACP DFEEAD40, 00F4 (r3 Nvidia ASUSACPI 42302E31 AWRD        0)
[    0.000000] ACPI Warning (tbfadt-0568): 32/64X length mismatch in Pm1aEventBlock: 32/8 [20081204]
[    0.000000] ACPI Warning (tbfadt-0568): 32/64X length mismatch in Pm1aControlBlock: 16/8 [20081204]
[    0.000000] ACPI Warning (tbfadt-0568): 32/64X length mismatch in PmTimerBlock: 32/8 [20081204]
[    0.000000] ACPI Warning (tbfadt-0568): 32/64X length mismatch in Gpe0Block: 64/8 [20081204]
[    0.000000] ACPI Warning (tbfadt-0568): 32/64X length mismatch in Gpe1Block: 128/8 [20081204]
[    0.000000] ACPI Warning (tbfadt-0412): Invalid length for Pm1aEventBlock: 8, using default 32 [20081204]
[    0.000000] ACPI Warning (tbfadt-0412): Invalid length for Pm1aControlBlock: 8, using default 16 [20081204]
[    0.000000] ACPI Warning (tbfadt-0412): Invalid length for PmTimerBlock: 8, using default 32 [20081204]
[    0.000000] FADT: X_PM1a_EVT_BLK.bit_width (16) does not match PM1_EVT_LEN (4)
[    0.000000] ACPI: DSDT DFEE3280, 7A51 (r1 NVIDIA AWRDACPI     1000 MSFT  3000000)
[    0.000000] ACPI: FACS DFEE0000, 0040
[    0.000000] ACPI: SSDT DFEEAF80, 028A (r1 PTLTD  POWERNOW        1  LTP        1)
[    0.000000] ACPI: HPET DFEEB280, 0038 (r1 Nvidia ASUSACPI 42302E31 AWRD       98)
[    0.000000] ACPI: MCFG DFEEB300, 003C (r1 Nvidia ASUSACPI 42302E31 AWRD        0)
[    0.000000] ACPI: APIC DFEEAE80, 0098 (r1 Nvidia ASUSACPI 42302E31 AWRD        0)
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] Scanning NUMA topology in Northbridge 24
[    0.000000] No NUMA configuration found
[    0.000000] Faking a node at 0000000000000000-0000000120000000
[    0.000000] Bootmem setup node 0 0000000000000000-0000000120000000
[    0.000000]   NODE_DATA [0000000000015000 - 0000000000048fff]
[    0.000000]   bootmap [0000000000049000 -  000000000006cfff] pages 24
[    0.000000] (6 early reservations) ==> bootmem [0000000000 - 0120000000]
[    0.000000]   #0 [0000000000 - 0000001000]   BIOS data page ==> [0000000000 - 0000001000]
[    0.000000]   #1 [0000006000 - 0000008000]       TRAMPOLINE ==> [0000006000 - 0000008000]
[    0.000000]   #2 [0000200000 - 00012c7394]    TEXT DATA BSS ==> [0000200000 - 00012c7394]
[    0.000000]   #3 [000009f000 - 0000100000]    BIOS reserved ==> [000009f000 - 0000100000]
[    0.000000]   #4 [0000010000 - 0000014000]          PGTABLE ==> [0000010000 - 0000014000]
[    0.000000]   #5 [0000014000 - 0000015000]          PGTABLE ==> [0000014000 - 0000015000]
[    0.000000] found SMP MP-table at [ffff8800000f5bd0] 000f5bd0
[    0.000000]  [ffffe20000000000-ffffe20003ffffff] PMD -> [ffff880028200000-ffff88002bbfffff] on node 0
[    0.000000] Zone PFN ranges:
[    0.000000]   DMA      0x00000010 -> 0x00001000
[    0.000000]   DMA32    0x00001000 -> 0x00100000
[    0.000000]   Normal   0x00100000 -> 0x00120000
[    0.000000] Movable zone start PFN for each node
[    0.000000] early_node_map[3] active PFN ranges
[    0.000000]     0: 0x00000010 -> 0x0000009f
[    0.000000]     0: 0x00000100 -> 0x000dfee0
[    0.000000]     0: 0x00100000 -> 0x00120000
[    0.000000] On node 0 totalpages: 1048175
[    0.000000]   DMA zone: 56 pages used for memmap
[    0.000000]   DMA zone: 107 pages reserved
[    0.000000]   DMA zone: 3820 pages, LIFO batch:0
[    0.000000]   DMA32 zone: 14280 pages used for memmap
[    0.000000]   DMA32 zone: 898840 pages, LIFO batch:31
[    0.000000]   Normal zone: 1792 pages used for memmap
[    0.000000]   Normal zone: 129280 pages, LIFO batch:31
[    0.000000] Detected use of extended apic ids on hypertransport bus
[    0.000000] ACPI: PM-Timer IO Port: 0x1008
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] ACPI: LAPIC (acpi_id[0x00] lapic_id[0x00] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x01] lapic_id[0x01] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x02] lapic_id[0x02] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x03] lapic_id[0x03] disabled)
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x00] high edge lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x01] high edge lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x02] high edge lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x03] high edge lint[0x1])
[    0.000000] ACPI: IOAPIC (id[0x04] address[0xfec00000] gsi_base[0])
[    0.000000] IOAPIC[0]: apic_id 4, version 0, address 0xfec00000, GSI 0-23
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 14 global_irq 14 high edge)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 15 global_irq 15 high edge)
[    0.000000] ACPI: IRQ0 used by override.
[    0.000000] ACPI: IRQ2 used by override.
[    0.000000] ACPI: IRQ9 used by override.
[    0.000000] ACPI: IRQ14 used by override.
[    0.000000] ACPI: IRQ15 used by override.
[    0.000000] Using ACPI (MADT) for SMP configuration information
[    0.000000] ACPI: HPET id: 0x10de8201 base: 0xfefff000
[    0.000000] SMP: Allowing 4 CPUs, 2 hotplug CPUs
[    0.000000] nr_irqs_gsi: 24
[    0.000000] Allocating PCI resources starting at e0000000 (gap: dff00000:10100000)
[    0.000000] NR_CPUS:4096 nr_cpumask_bits:4 nr_cpu_ids:4 nr_node_ids:1
[    0.000000] PERCPU: Allocating 77824 bytes of per cpu data
[    0.000000] Built 1 zonelists in Node order, mobility grouping on.  Total pages: 1031940
[    0.000000] Policy zone: Normal
[    0.000000] Kernel command line: root=/dev/sda2 ro earlyprintk=vga
[    0.000000] Initializing CPU#0
[    0.000000] PID hash table entries: 4096 (order: 12, 32768 bytes)
[    0.000000] Extended CMOS year: 2000
[    0.000000] Fast TSC calibration using PIT
[    0.000000] Detected 2611.994 MHz processor.
[    0.000999] spurious 8259A interrupt: IRQ7.
[    0.000999] Console: colour VGA+ 80x25
[    0.000999] console handover: boot [earlyvga0] -> real [tty0]
[    0.000999] Checking aperture...
[    0.000999] No AGP bridge found
[    0.000999] Node 0: aperture @ 20000000 size 32 MB
[    0.000999] Aperture pointing to e820 RAM. Ignoring.
[    0.000999] Your BIOS doesn't leave a aperture memory hole
[    0.000999] Please enable the IOMMU option in the BIOS setup
[    0.000999] This costs you 64 MB of RAM
[    0.000999] Mapping aperture over 65536 KB of RAM @ 20000000
[    0.000999] Memory: 4045464k/4718592k available (4507k kernel code, 525892k absent, 147236k reserved, 2599k data, 1356k init)
[    0.000999] hpet clockevent registered
[    0.000999] HPET: 3 timers in total, 0 timers will be used for per-cpu timer
[    0.000999] Calibrating delay loop (skipped), value calculated using timer frequency.. 5223.98 BogoMIPS (lpj=2611994)
[    0.000999] Dentry cache hash table entries: 524288 (order: 10, 4194304 bytes)
[    0.003061] Inode-cache hash table entries: 262144 (order: 9, 2097152 bytes)
[    0.004131] Mount-cache hash table entries: 256
[    0.004422] CPU: L1 I Cache: 64K (64 bytes/line), D cache 64K (64 bytes/line)
[    0.004460] CPU: L2 Cache: 1024K (64 bytes/line)
[    0.004497] CPU 0/0x0 -> Node 0
[    0.004532] tseg: 00dff00000
[    0.004534] CPU: Physical Processor ID: 0
[    0.004572] CPU: Processor Core ID: 0
[    0.004615] using C1E aware idle routine
[    0.005197] ACPI: Core revision 20081204
[    0.015063] Setting APIC routing to flat
[    0.016387] ..TIMER: vector=0x30 apic1=0 pin1=2 apic2=-1 pin2=-1
[    0.026430] CPU0: AMD Athlon(tm) 64 X2 Dual Core Processor 5200+ stepping 03
[    0.026995] Testing tracer nop: PASSED
[    0.026995] Booting processor 1 APIC 0x1 ip 0x6000
[    0.000999] Initializing CPU#1
[    0.000999] Calibrating delay using timer specific routine.. 5223.79 BogoMIPS (lpj=2611899)
[    0.000999] CPU: L1 I Cache: 64K (64 bytes/line), D cache 64K (64 bytes/line)
[    0.000999] CPU: L2 Cache: 1024K (64 bytes/line)
[    0.000999] CPU 1/0x1 -> Node 0
[    0.000999] CPU: Physical Processor ID: 0
[    0.000999] CPU: Processor Core ID: 1
[    0.097154] CPU1: AMD Athlon(tm) 64 X2 Dual Core Processor 5200+ stepping 03
[    0.097537] Brought up 2 CPUs
[    0.097576] Total of 2 processors activated (10447.78 BogoMIPS).
[    0.097759] CPU0 attaching sched-domain:
[    0.097762]  domain 0: span 0-1 level CPU
[    0.097764]   groups: 0 1
[    0.097768] CPU1 attaching sched-domain:
[    0.097769]  domain 0: span 0-1 level CPU
[    0.097771]   groups: 1 0
[    0.098164] net_namespace: 1384 bytes
[    0.098205] Booting paravirtualized kernel on bare hardware
[    0.098391] xor: automatically using best checksumming function: generic_sse
[    0.102985]    generic_sse:  7964.000 MB/sec
[    0.103024] xor: using function: generic_sse (7964.000 MB/sec)
[    0.103159] NET: Registered protocol family 16
[    0.103215] node 0 link 0: io port [7000, ffff]
[    0.103215] TOM: 00000000e0000000 aka 3584M
[    0.103215] node 0 link 0: mmio [a0000, bffff]
[    0.103215] node 0 link 0: mmio [e0000000, efffffff]
[    0.103215] node 0 link 0: mmio [f4000000, fe02ffff]
[    0.103215] node 0 link 0: mmio [f0000000, f03fffff]
[    0.103215] TOM2: 0000000120000000 aka 4608M
[    0.103215] bus: [00,03] on node 0 link 0
[    0.103215] bus: 00 index 0 io port: [0, ffff]
[    0.103215] bus: 00 index 1 mmio: [a0000, bffff]
[    0.103215] bus: 00 index 2 mmio: [e0000000, f3ffffff]
[    0.103215] bus: 00 index 3 mmio: [f4000000, ffffffff]
[    0.103215] bus: 00 index 4 mmio: [120000000, fcffffffff]
[    0.103215] ACPI: bus type pci registered
[    0.103215] PCI: MCFG configuration 0: base f0000000 segment 0 buses 0 - 63
[    0.103215] PCI: MCFG area at f0000000 reserved in E820
[    0.106694] PCI: Using MMCONFIG at f0000000 - f3ffffff
[    0.106733] PCI: Using configuration type 1 for base access
[    0.110165] bio: create slab <bio-0> at 0
[    0.111552] ACPI: EC: Look up EC in DSDT
[    0.123204] ACPI: Interpreter enabled
[    0.123247] ACPI: (supports S0 S5)
[    0.123363] ACPI: Using IOAPIC for interrupt routing
[    0.135150] ACPI: No dock devices found.
[    0.135202] ACPI: PCI Root Bridge [PCI0] (0000:00)
[    0.135272] PCI: Scanning bus 0000:00
[    0.135272] pci 0000:00:00.0: found [10de:0369] class 000500 header type 00
[    0.136004] pci 0000:00:01.0: found [10de:0360] class 000601 header type 00
[    0.136021] pci 0000:00:01.0: calling nvidia_force_enable_hpet+0x0/0xd0
[    0.136040] pci 0000:00:01.1: found [10de:0368] class 000c05 header type 00
[    0.136046] pci 0000:00:01.1: reg 10 io port: [0xfc00-0xfc3f]
[    0.136055] pci 0000:00:01.1: reg 20 io port: [0x1c00-0x1c3f]
[    0.136058] pci 0000:00:01.1: reg 24 io port: [0x1c40-0x1c7f]
[    0.136077] pci 0000:00:01.1: PME# supported from D3hot D3cold
[    0.136120] pci 0000:00:01.1: PME# disabled
[    0.136176] pci 0000:00:02.0: found [10de:036c] class 000c03 header type 00
[    0.136181] pci 0000:00:02.0: reg 10 32bit mmio: [0xfe02f000-0xfe02ffff]
[    0.136198] pci 0000:00:02.0: supports D1 D2
[    0.136199] pci 0000:00:02.0: PME# supported from D0 D1 D2 D3hot D3cold
[    0.136240] pci 0000:00:02.0: PME# disabled
[    0.136290] pci 0000:00:02.1: found [10de:036d] class 000c03 header type 00
[    0.136294] pci 0000:00:02.1: reg 10 32bit mmio: [0xfe02e000-0xfe02e0ff]
[    0.136311] pci 0000:00:02.1: supports D1 D2
[    0.136313] pci 0000:00:02.1: PME# supported from D0 D1 D2 D3hot D3cold
[    0.136354] pci 0000:00:02.1: PME# disabled
[    0.136406] pci 0000:00:04.0: found [10de:036e] class 000101 header type 00
[    0.136415] pci 0000:00:04.0: reg 20 io port: [0xf000-0xf00f]
[    0.136436] pci 0000:00:05.0: found [10de:037f] class 000101 header type 00
[    0.136440] pci 0000:00:05.0: reg 10 io port: [0x9f0-0x9f7]
[    0.136442] pci 0000:00:05.0: reg 14 io port: [0xbf0-0xbf3]
[    0.136445] pci 0000:00:05.0: reg 18 io port: [0x970-0x977]
[    0.136448] pci 0000:00:05.0: reg 1c io port: [0xb70-0xb73]
[    0.136451] pci 0000:00:05.0: reg 20 io port: [0xdc00-0xdc0f]
[    0.136454] pci 0000:00:05.0: reg 24 32bit mmio: [0xfe02d000-0xfe02dfff]
[    0.136478] pci 0000:00:05.1: found [10de:037f] class 000101 header type 00
[    0.136482] pci 0000:00:05.1: reg 10 io port: [0x9e0-0x9e7]
[    0.136484] pci 0000:00:05.1: reg 14 io port: [0xbe0-0xbe3]
[    0.136487] pci 0000:00:05.1: reg 18 io port: [0x960-0x967]
[    0.136490] pci 0000:00:05.1: reg 1c io port: [0xb60-0xb63]
[    0.136493] pci 0000:00:05.1: reg 20 io port: [0xc800-0xc80f]
[    0.136496] pci 0000:00:05.1: reg 24 32bit mmio: [0xfe02c000-0xfe02cfff]
[    0.136519] pci 0000:00:05.2: found [10de:037f] class 000101 header type 00
[    0.136523] pci 0000:00:05.2: reg 10 io port: [0xc400-0xc407]
[    0.136526] pci 0000:00:05.2: reg 14 io port: [0xc000-0xc003]
[    0.136529] pci 0000:00:05.2: reg 18 io port: [0xbc00-0xbc07]
[    0.136531] pci 0000:00:05.2: reg 1c io port: [0xb800-0xb803]
[    0.136534] pci 0000:00:05.2: reg 20 io port: [0xb400-0xb40f]
[    0.136537] pci 0000:00:05.2: reg 24 32bit mmio: [0xfe02b000-0xfe02bfff]
[    0.136561] pci 0000:00:06.0: found [10de:0370] class 000604 header type 01
[    0.136585] pci 0000:00:06.1: found [10de:0371] class 000403 header type 00
[    0.136590] pci 0000:00:06.1: reg 10 32bit mmio: [0xfe020000-0xfe023fff]
[    0.136610] pci 0000:00:06.1: PME# supported from D3hot D3cold
[    0.136651] pci 0000:00:06.1: PME# disabled
[    0.136714] pci 0000:00:08.0: found [10de:0373] class 000680 header type 00
[    0.136718] pci 0000:00:08.0: calling nvenet_msi_disable+0x0/0x50
[    0.136723] pci 0000:00:08.0: reg 10 32bit mmio: [0xfe02a000-0xfe02afff]
[    0.136726] pci 0000:00:08.0: reg 14 io port: [0xb000-0xb007]
[    0.136729] pci 0000:00:08.0: reg 18 32bit mmio: [0xfe029000-0xfe0290ff]
[    0.136732] pci 0000:00:08.0: reg 1c 32bit mmio: [0xfe028000-0xfe02800f]
[    0.136750] pci 0000:00:08.0: supports D1 D2
[    0.136751] pci 0000:00:08.0: PME# supported from D0 D1 D2 D3hot D3cold
[    0.136793] pci 0000:00:08.0: PME# disabled
[    0.136852] pci 0000:00:09.0: found [10de:0373] class 000680 header type 00
[    0.136855] pci 0000:00:09.0: calling nvenet_msi_disable+0x0/0x50
[    0.136859] pci 0000:00:09.0: reg 10 32bit mmio: [0xfe027000-0xfe027fff]
[    0.136862] pci 0000:00:09.0: reg 14 io port: [0xac00-0xac07]
[    0.136865] pci 0000:00:09.0: reg 18 32bit mmio: [0xfe026000-0xfe0260ff]
[    0.136868] pci 0000:00:09.0: reg 1c 32bit mmio: [0xfe025000-0xfe02500f]
[    0.136886] pci 0000:00:09.0: supports D1 D2
[    0.136888] pci 0000:00:09.0: PME# supported from D0 D1 D2 D3hot D3cold
[    0.136929] pci 0000:00:09.0: PME# disabled
[    0.136988] pci 0000:00:0e.0: found [10de:0375] class 000604 header type 01
[    0.137001] pci 0000:00:0e.0: PME# supported from D0 D1 D2 D3hot D3cold
[    0.137042] pci 0000:00:0e.0: PME# disabled
[    0.137091] pci 0000:00:0f.0: found [10de:0377] class 000604 header type 01
[    0.137105] pci 0000:00:0f.0: PME# supported from D0 D1 D2 D3hot D3cold
[    0.137145] pci 0000:00:0f.0: PME# disabled
[    0.137197] pci 0000:00:18.0: found [1022:1100] class 000600 header type 00
[    0.137210] pci 0000:00:18.1: found [1022:1101] class 000600 header type 00
[    0.137221] pci 0000:00:18.2: found [1022:1102] class 000600 header type 00
[    0.137233] pci 0000:00:18.3: found [1022:1103] class 000600 header type 00
[    0.137249] PCI: Fixups for bus 0000:00
[    0.137251] pci 0000:00:06.0: scanning behind bridge, config 010100, pass 0
[    0.137254] PCI: Scanning bus 0000:01
[    0.137274] pci 0000:01:0b.0: found [104c:8023] class 000c00 header type 00
[    0.137279] pci 0000:01:0b.0: reg 10 32bit mmio: [0xfdeff000-0xfdeff7ff]
[    0.137284] pci 0000:01:0b.0: reg 14 32bit mmio: [0xfdef8000-0xfdefbfff]
[    0.137308] pci 0000:01:0b.0: supports D1 D2
[    0.137309] pci 0000:01:0b.0: PME# supported from D0 D1 D2 D3hot
[    0.137350] pci 0000:01:0b.0: PME# disabled
[    0.137403] PCI: Fixups for bus 0000:01
[    0.137404] pci 0000:00:06.0: transparent bridge
[    0.137445] pci 0000:00:06.0: bridge 32bit mmio: [0xfde00000-0xfdefffff]
[    0.137447] PCI: Bus scan for 0000:01 returning with max=01
[    0.137450] pci 0000:00:0e.0: scanning behind bridge, config 020200, pass 0
[    0.137453] PCI: Scanning bus 0000:02
[    0.137472] pci 0000:02:00.0: found [197b:2363] class 000101 header type 00
[    0.137475] pci 0000:02:00.0: calling quirk_jmicron_ata+0x0/0x150
[    0.137512] pci 0000:02:00.0: reg 24 32bit mmio: [0xfddfe000-0xfddfffff]
[    0.137518] pci 0000:02:00.0: reg 30 32bit mmio: [0xfdde0000-0xfddeffff]
[    0.137539] pci 0000:02:00.0: PME# supported from D3hot
[    0.137581] pci 0000:02:00.0: PME# disabled
[    0.137645] pci 0000:02:00.1: found [197b:2363] class 000101 header type 00
[    0.137648] pci 0000:02:00.1: calling quirk_jmicron_ata+0x0/0x150
[    0.137656] pci 0000:02:00.1: reg 10 io port: [0x9c00-0x9c07]
[    0.137662] pci 0000:02:00.1: reg 14 io port: [0x9800-0x9803]
[    0.137668] pci 0000:02:00.1: reg 18 io port: [0x9400-0x9407]
[    0.137674] pci 0000:02:00.1: reg 1c io port: [0x9000-0x9003]
[    0.137680] pci 0000:02:00.1: reg 20 io port: [0x8c00-0x8c0f]
[    0.137737] PCI: Fixups for bus 0000:02
[    0.137740] pci 0000:00:0e.0: bridge io port: [0x8000-0x9fff]
[    0.137742] pci 0000:00:0e.0: bridge 32bit mmio: [0xfdd00000-0xfddfffff]
[    0.137744] PCI: Bus scan for 0000:02 returning with max=02
[    0.137747] pci 0000:00:0f.0: scanning behind bridge, config 030300, pass 0
[    0.137750] PCI: Scanning bus 0000:03
[    0.137760] pci 0000:03:00.0: found [1002:71c3] class 000300 header type 00
[    0.137763] pci 0000:03:00.0: calling quirk_no_ata_d3+0x0/0x1d
[    0.137771] pci 0000:03:00.0: reg 10 64bit mmio: [0xe0000000-0xefffffff]
[    0.137777] pci 0000:03:00.0: reg 18 64bit mmio: [0xfdcf0000-0xfdcfffff]
[    0.137781] pci 0000:03:00.0: reg 20 io port: [0x7c00-0x7cff]
[    0.137787] pci 0000:03:00.0: reg 30 32bit mmio: [0xfdcc0000-0xfdcdffff]
[    0.137799] pci 0000:03:00.0: supports D1 D2
[    0.137815] pci 0000:03:00.1: found [1002:71e3] class 000380 header type 00
[    0.137818] pci 0000:03:00.1: calling quirk_no_ata_d3+0x0/0x1d
[    0.137824] pci 0000:03:00.1: reg 10 64bit mmio: [0xfdce0000-0xfdceffff]
[    0.137846] pci 0000:03:00.1: supports D1 D2
[    0.137874] PCI: Fixups for bus 0000:03
[    0.137876] pci 0000:00:0f.0: bridge io port: [0x7000-0x7fff]
[    0.137879] pci 0000:00:0f.0: bridge 32bit mmio: [0xfdc00000-0xfdcfffff]
[    0.137882] pci 0000:00:0f.0: bridge 64bit mmio pref: [0xe0000000-0xefffffff]
[    0.137883] PCI: Bus scan for 0000:03 returning with max=03
[    0.137886] pci 0000:00:06.0: scanning behind bridge, config 010100, pass 1
[    0.137888] pci 0000:00:0e.0: scanning behind bridge, config 020200, pass 1
[    0.137891] pci 0000:00:0f.0: scanning behind bridge, config 030300, pass 1
[    0.137894] PCI: Bus scan for 0000:00 returning with max=03
[    0.137900] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0._PRT]
[    0.138183] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.HUB0._PRT]
[    0.198420] ACPI: PCI Interrupt Link [LNK1] (IRQs 5 7 9 10 11 14 15) *0, disabled.
[    0.199521] ACPI: PCI Interrupt Link [LNK2] (IRQs 5 7 9 10 11 14 15) *0, disabled.
[    0.200155] ACPI: PCI Interrupt Link [LNK3] (IRQs 5 7 9 10 11 14 15) *0, disabled.
[    0.200775] ACPI: PCI Interrupt Link [LNK4] (IRQs 5 7 9 10 11 14 15) *0, disabled.
[    0.201384] ACPI: PCI Interrupt Link [LNK5] (IRQs 5 7 9 10 11 14 15) *0, disabled.
[    0.202021] ACPI: PCI Interrupt Link [LNK6] (IRQs 5 7 9 10 *11 14 15)
[    0.202571] ACPI: PCI Interrupt Link [LNK7] (IRQs 5 *7 9 10 11 14 15)
[    0.203123] ACPI: PCI Interrupt Link [LNK8] (IRQs 5 7 9 10 11 14 15) *0, disabled.
[    0.203744] ACPI: PCI Interrupt Link [LP2P] (IRQs 5 7 9 10 11 14 15) *0, disabled.
[    0.204349] ACPI: PCI Interrupt Link [LUBA] (IRQs 5 7 9 10 11 14 15) *0, disabled.
[    0.204991] ACPI: PCI Interrupt Link [LMAC] (IRQs 5 7 9 *10 11 14 15)
[    0.205541] ACPI: PCI Interrupt Link [LMC1] (IRQs 5 7 9 *10 11 14 15)
[    0.206094] ACPI: PCI Interrupt Link [LAZA] (IRQs 5 7 9 *10 11 14 15)
[    0.206643] ACPI: PCI Interrupt Link [LPMU] (IRQs 5 7 9 10 11 14 15) *0, disabled.
[    0.207249] ACPI: PCI Interrupt Link [LSMB] (IRQs 5 7 9 10 11 14 15) *0, disabled.
[    0.207870] ACPI: PCI Interrupt Link [LUB2] (IRQs 5 7 9 10 11 14 15) *0, disabled.
[    0.208487] ACPI: PCI Interrupt Link [LIDE] (IRQs 5 7 9 10 11 14 15) *0, disabled.
[    0.209142] ACPI: PCI Interrupt Link [LSID] (IRQs 5 7 9 *10 11 14 15)
[    0.209693] ACPI: PCI Interrupt Link [LFID] (IRQs 5 7 9 10 *11 14 15)
[    0.210245] ACPI: PCI Interrupt Link [LSA2] (IRQs *5 7 9 10 11 14 15)
[    0.210841] ACPI: PCI Interrupt Link [APC1] (IRQs 16) *0, disabled.
[    0.211288] ACPI: PCI Interrupt Link [APC2] (IRQs 17) *0, disabled.
[    0.211745] ACPI: PCI Interrupt Link [APC3] (IRQs 18) *0, disabled.
[    0.212216] ACPI: PCI Interrupt Link [APC4] (IRQs 19) *0, disabled.
[    0.212673] ACPI: PCI Interrupt Link [APC5] (IRQs 16) *0, disabled.
[    0.213135] ACPI: PCI Interrupt Link [APC6] (IRQs 16) *0
[    0.213557] ACPI: PCI Interrupt Link [APC7] (IRQs 16) *0
[    0.213981] ACPI: PCI Interrupt Link [APC8] (IRQs 16) *0, disabled.
[    0.214439] ACPI: PCI Interrupt Link [APCF] (IRQs 20 21 22 23) *0, disabled.
[    0.214998] ACPI: PCI Interrupt Link [APCH] (IRQs 20 21 22 23) *0
[    0.215522] ACPI: PCI Interrupt Link [AMC1] (IRQs 20 21 22 23) *0
[    0.216048] ACPI: PCI Interrupt Link [APMU] (IRQs 20 21 22 23) *0, disabled.
[    0.216608] ACPI: PCI Interrupt Link [AAZA] (IRQs 20 21 22 23) *0
[    0.217134] ACPI: PCI Interrupt Link [APCS] (IRQs 20 21 22 23) *0, disabled.
[    0.217693] ACPI: PCI Interrupt Link [APCL] (IRQs 20 21 22 23) *0, disabled.
[    0.218252] ACPI: PCI Interrupt Link [APCM] (IRQs 20 21 22 23) *0, disabled.
[    0.218810] ACPI: PCI Interrupt Link [APCZ] (IRQs 20 21 22 23) *0, disabled.
[    0.219356] ACPI: PCI Interrupt Link [APSI] (IRQs 20 21 22 23) *0
[    0.219882] ACPI: PCI Interrupt Link [APSJ] (IRQs 20 21 22 23) *0
[    0.220421] ACPI: PCI Interrupt Link [ASA2] (IRQs 20 21 22 23) *0
[    0.221215] SCSI subsystem initialized
[    0.221215] libata version 3.00 loaded.
[    0.221215] usbcore: registered new interface driver usbfs
[    0.221215] usbcore: registered new interface driver hub
[    0.221215] usbcore: registered new device driver usb
[    0.221215] PCI: Using ACPI for IRQ routing
[    0.226066] PCI-DMA: Disabling AGP.
[    0.226165] PCI-DMA: aperture base @ 20000000 size 65536 KB
[    0.226165] PCI-DMA: using GART IOMMU.
[    0.226165] PCI-DMA: Reserving 64MB of IOMMU area in the AGP aperture
[    0.226601] hpet0: at MMIO 0xfefff000, IRQs 2, 8, 31
[    0.227077] hpet0: 3 comparators, 32-bit 25.000000 MHz counter
[    0.229976] Switched to high resolution mode on CPU 0
[    0.230422] Switched to high resolution mode on CPU 1
[    0.233015] pnp: PnP ACPI init
[    0.233067] ACPI: bus type pnp registered
[    0.238903] pnp: PnP ACPI: found 12 devices
[    0.238942] ACPI: ACPI bus type pnp unregistered
[    0.238989] system 00:01: ioport range 0x1000-0x107f has been reserved
[    0.239037] system 00:01: ioport range 0x1080-0x10ff has been reserved
[    0.239078] system 00:01: ioport range 0x1400-0x147f has been reserved
[    0.239118] system 00:01: ioport range 0x1480-0x14ff has been reserved
[    0.239164] system 00:01: ioport range 0x1800-0x187f has been reserved
[    0.239204] system 00:01: ioport range 0x1880-0x18ff has been reserved
[    0.239247] system 00:02: ioport range 0x4d0-0x4d1 has been reserved
[    0.239288] system 00:02: ioport range 0x800-0x801 has been reserved
[    0.239329] system 00:02: ioport range 0x290-0x297 has been reserved
[    0.239373] system 00:0a: iomem range 0xf0000000-0xf3ffffff has been reserved
[    0.239417] system 00:0b: iomem range 0xd4800-0xd7fff has been reserved
[    0.239458] system 00:0b: iomem range 0xf0000-0xf7fff could not be reserved
[    0.239499] system 00:0b: iomem range 0xf8000-0xfbfff could not be reserved
[    0.239539] system 00:0b: iomem range 0xfc000-0xfffff could not be reserved
[    0.239580] system 00:0b: iomem range 0xfefff000-0xfefff0ff has been reserved
[    0.239622] system 00:0b: iomem range 0xdfee0000-0xdfefffff could not be reserved
[    0.239665] system 00:0b: iomem range 0xffff0000-0xffffffff has been reserved
[    0.239706] system 00:0b: iomem range 0x0-0x9ffff could not be reserved
[    0.239747] system 00:0b: iomem range 0x100000-0xdfedffff could not be reserved
[    0.239790] system 00:0b: iomem range 0xfec00000-0xfec00fff has been reserved
[    0.239831] system 00:0b: iomem range 0xfee00000-0xfeefffff has been reserved
[    0.239872] system 00:0b: iomem range 0xfefff000-0xfeffffff could not be reserved
[    0.239915] system 00:0b: iomem range 0xfff80000-0xfff80fff has been reserved
[    0.239956] system 00:0b: iomem range 0xfff90000-0xfffbffff has been reserved
[    0.239997] system 00:0b: iomem range 0xfffed000-0xfffeffff has been reserved
[    0.245173] pci 0000:00:06.0: PCI bridge, secondary bus 0000:01
[    0.245213] pci 0000:00:06.0:   IO window: disabled
[    0.245253] pci 0000:00:06.0:   MEM window: 0xfde00000-0xfdefffff
[    0.245293] pci 0000:00:06.0:   PREFETCH window: disabled
[    0.245334] pci 0000:00:0e.0: PCI bridge, secondary bus 0000:02
[    0.245374] pci 0000:00:0e.0:   IO window: 0x8000-0x9fff
[    0.245414] pci 0000:00:0e.0:   MEM window: 0xfdd00000-0xfddfffff
[    0.245454] pci 0000:00:0e.0:   PREFETCH window: disabled
[    0.245494] pci 0000:00:0f.0: PCI bridge, secondary bus 0000:03
[    0.245534] pci 0000:00:0f.0:   IO window: 0x7000-0x7fff
[    0.245574] pci 0000:00:0f.0:   MEM window: 0xfdc00000-0xfdcfffff
[    0.245614] pci 0000:00:0f.0:   PREFETCH window: 0x000000e0000000-0x000000efffffff
[    0.245661] pci 0000:00:06.0: setting latency timer to 64
[    0.245665] pci 0000:00:0e.0: setting latency timer to 64
[    0.245668] pci 0000:00:0f.0: setting latency timer to 64
[    0.245671] pci_bus 0000:00: resource 0 io:  [0x00-0xffff]
[    0.245673] pci_bus 0000:00: resource 1 mem: [0x000000-0xffffffffffffffff]
[    0.245675] pci_bus 0000:01: resource 0 mem: [0x0-0x0]
[    0.245676] pci_bus 0000:01: resource 1 mem: [0xfde00000-0xfdefffff]
[    0.245678] pci_bus 0000:01: resource 2 mem: [0x0-0x0]
[    0.245679] pci_bus 0000:01: resource 3 io:  [0x00-0xffff]
[    0.245681] pci_bus 0000:01: resource 4 mem: [0x000000-0xffffffffffffffff]
[    0.245683] pci_bus 0000:02: resource 0 io:  [0x8000-0x9fff]
[    0.245684] pci_bus 0000:02: resource 1 mem: [0xfdd00000-0xfddfffff]
[    0.245686] pci_bus 0000:02: resource 2 mem: [0x0-0x0]
[    0.245687] pci_bus 0000:02: resource 3 mem: [0x0-0x0]
[    0.245689] pci_bus 0000:03: resource 0 io:  [0x7000-0x7fff]
[    0.245690] pci_bus 0000:03: resource 1 mem: [0xfdc00000-0xfdcfffff]
[    0.245692] pci_bus 0000:03: resource 2 mem: [0xe0000000-0xefffffff]
[    0.245693] pci_bus 0000:03: resource 3 mem: [0x0-0x0]
[    0.245845] NET: Registered protocol family 2
[    0.256202] IP route cache hash table entries: 131072 (order: 8, 1048576 bytes)
[    0.257646] TCP established hash table entries: 524288 (order: 11, 8388608 bytes)
[    0.261449] TCP bind hash table entries: 65536 (order: 8, 1048576 bytes)
[    0.261953] TCP: Hash tables configured (established 524288 bind 65536)
[    0.261993] TCP reno registered
[    0.265160] NET: Registered protocol family 1
[    0.266456] audit: initializing netlink socket (disabled)
[    0.266502] type=2000 audit(1239127326.266:1): initialized
[    0.268675] Testing tracer sched_switch: PASSED
[    0.369649] Testing tracer sysprof: PASSED
[    0.471045] Installing knfsd (copyright (C) 1996 okir-pn4DOG8n3UYbFoVRYvo4fw@public.gmane.org).
[    0.471400] msgmni has been set to 7901
[    0.471727] alg: No test for stdrng (krng)
[    0.471777] async_tx: api initialized (async)
[    0.471820] io scheduler noop registered
[    0.471858] io scheduler anticipatory registered
[    0.471896] io scheduler deadline registered
[    0.471990] io scheduler cfq registered (default)
[    0.472046] pci 0000:00:00.0: calling nv_msi_ht_cap_quirk+0x0/0x22c
[    0.472074] pci 0000:00:00.0: calling quirk_cardbus_legacy+0x0/0x30
[    0.472077] pci 0000:00:00.0: calling quirk_usb_early_handoff+0x0/0x441
[    0.472079] pci 0000:00:00.0: calling pci_fixup_video+0x0/0xc9
[    0.472083] pci 0000:00:01.0: calling nv_msi_ht_cap_quirk+0x0/0x22c
[    0.472086] pci 0000:00:01.0: calling quirk_cardbus_legacy+0x0/0x30
[    0.472088] pci 0000:00:01.0: calling quirk_usb_early_handoff+0x0/0x441
[    0.472090] pci 0000:00:01.0: calling pci_fixup_video+0x0/0xc9
[    0.472094] pci 0000:00:01.1: calling nv_msi_ht_cap_quirk+0x0/0x22c
[    0.472100] pci 0000:00:01.1: calling quirk_cardbus_legacy+0x0/0x30
[    0.472103] pci 0000:00:01.1: calling quirk_usb_early_handoff+0x0/0x441
[    0.472105] pci 0000:00:01.1: calling pci_fixup_video+0x0/0xc9
[    0.472108] pci 0000:00:02.0: calling nv_msi_ht_cap_quirk+0x0/0x22c
[    0.472113] pci 0000:00:02.0: calling quirk_cardbus_legacy+0x0/0x30
[    0.472115] pci 0000:00:02.0: calling quirk_usb_early_handoff+0x0/0x441
[    0.484594] pci 0000:00:02.0: calling pci_fixup_video+0x0/0xc9
[    0.484604] pci 0000:00:02.1: calling nv_msi_ht_cap_quirk+0x0/0x22c
[    0.484612] pci 0000:00:02.1: calling quirk_cardbus_legacy+0x0/0x30
[    0.484615] pci 0000:00:02.1: calling quirk_usb_early_handoff+0x0/0x441
[    0.484638] pci 0000:00:02.1: calling pci_fixup_video+0x0/0xc9
[    0.484641] pci 0000:00:04.0: calling nv_msi_ht_cap_quirk+0x0/0x22c
[    0.484645] pci 0000:00:04.0: calling quirk_cardbus_legacy+0x0/0x30
[    0.484648] pci 0000:00:04.0: calling quirk_usb_early_handoff+0x0/0x441
[    0.484650] pci 0000:00:04.0: calling pci_fixup_video+0x0/0xc9
[    0.484653] pci 0000:00:05.0: calling nv_msi_ht_cap_quirk+0x0/0x22c
[    0.484698] pci 0000:00:00.0: Found enabled HT MSI Mapping
[    0.484740] pci 0000:00:05.0: calling quirk_cardbus_legacy+0x0/0x30
[    0.484743] pci 0000:00:05.0: calling quirk_usb_early_handoff+0x0/0x441
[    0.484744] pci 0000:00:05.0: calling pci_fixup_video+0x0/0xc9
[    0.484748] pci 0000:00:05.1: calling nv_msi_ht_cap_quirk+0x0/0x22c
[    0.484790] pci 0000:00:00.0: Found enabled HT MSI Mapping
[    0.484830] pci 0000:00:05.1: calling quirk_cardbus_legacy+0x0/0x30
[    0.484832] pci 0000:00:05.1: calling quirk_usb_early_handoff+0x0/0x441
[    0.484834] pci 0000:00:05.1: calling pci_fixup_video+0x0/0xc9
[    0.484837] pci 0000:00:05.2: calling nv_msi_ht_cap_quirk+0x0/0x22c
[    0.484880] pci 0000:00:00.0: Found enabled HT MSI Mapping
[    0.484919] pci 0000:00:05.2: calling quirk_cardbus_legacy+0x0/0x30
[    0.484921] pci 0000:00:05.2: calling quirk_usb_early_handoff+0x0/0x441
[    0.484923] pci 0000:00:05.2: calling pci_fixup_video+0x0/0xc9
[    0.484926] pci 0000:00:06.0: calling nv_msi_ht_cap_quirk+0x0/0x22c
[    0.484969] pci 0000:00:00.0: Found enabled HT MSI Mapping
[    0.485016] pci 0000:00:06.0: calling quirk_cardbus_legacy+0x0/0x30
[    0.485019] pci 0000:00:06.0: calling quirk_usb_early_handoff+0x0/0x441
[    0.485021] pci 0000:00:06.0: calling pci_fixup_video+0x0/0xc9
[    0.485024] pci 0000:00:06.1: calling nv_msi_ht_cap_quirk+0x0/0x22c
[    0.485069] pci 0000:00:00.0: Found enabled HT MSI Mapping
[    0.485108] pci 0000:00:06.1: calling quirk_cardbus_legacy+0x0/0x30
[    0.485111] pci 0000:00:06.1: calling quirk_usb_early_handoff+0x0/0x441
[    0.485113] pci 0000:00:06.1: calling pci_fixup_video+0x0/0xc9
[    0.485116] pci 0000:00:08.0: calling nv_msi_ht_cap_quirk+0x0/0x22c
[    0.485172] pci 0000:00:00.0: Found enabled HT MSI Mapping
[    0.485212] pci 0000:00:08.0: calling quirk_cardbus_legacy+0x0/0x30
[    0.485214] pci 0000:00:08.0: calling quirk_usb_early_handoff+0x0/0x441
[    0.485216] pci 0000:00:08.0: calling pci_fixup_video+0x0/0xc9
[    0.485219] pci 0000:00:09.0: calling nv_msi_ht_cap_quirk+0x0/0x22c
[    0.485275] pci 0000:00:00.0: Found enabled HT MSI Mapping
[    0.485315] pci 0000:00:09.0: calling quirk_cardbus_legacy+0x0/0x30
[    0.485317] pci 0000:00:09.0: calling quirk_usb_early_handoff+0x0/0x441
[    0.485319] pci 0000:00:09.0: calling pci_fixup_video+0x0/0xc9
[    0.485322] pci 0000:00:0e.0: calling nv_msi_ht_cap_quirk+0x0/0x22c
[    0.485381] pci 0000:00:00.0: Found enabled HT MSI Mapping
[    0.485420] pci 0000:00:0e.0: calling quirk_cardbus_legacy+0x0/0x30
[    0.485422] pci 0000:00:0e.0: calling quirk_usb_early_handoff+0x0/0x441
[    0.485424] pci 0000:00:0e.0: calling pci_fixup_video+0x0/0xc9
[    0.485427] pci 0000:00:0f.0: calling nv_msi_ht_cap_quirk+0x0/0x22c
[    0.485489] pci 0000:00:00.0: Found enabled HT MSI Mapping
[    0.485528] pci 0000:00:0f.0: calling quirk_cardbus_legacy+0x0/0x30
[    0.485531] pci 0000:00:0f.0: calling quirk_usb_early_handoff+0x0/0x441
[    0.485533] pci 0000:00:0f.0: calling pci_fixup_video+0x0/0xc9
[    0.485536] pci 0000:00:18.0: calling quirk_cardbus_legacy+0x0/0x30
[    0.485539] pci 0000:00:18.0: calling quirk_usb_early_handoff+0x0/0x441
[    0.485540] pci 0000:00:18.0: calling pci_fixup_video+0x0/0xc9
[    0.485543] pci 0000:00:18.1: calling quirk_cardbus_legacy+0x0/0x30
[    0.485546] pci 0000:00:18.1: calling quirk_usb_early_handoff+0x0/0x441
[    0.485548] pci 0000:00:18.1: calling pci_fixup_video+0x0/0xc9
[    0.485551] pci 0000:00:18.2: calling quirk_cardbus_legacy+0x0/0x30
[    0.485554] pci 0000:00:18.2: calling quirk_usb_early_handoff+0x0/0x441
[    0.485555] pci 0000:00:18.2: calling pci_fixup_video+0x0/0xc9
[    0.485559] pci 0000:00:18.3: calling quirk_cardbus_legacy+0x0/0x30
[    0.485561] pci 0000:00:18.3: calling quirk_usb_early_handoff+0x0/0x441
[    0.485563] pci 0000:00:18.3: calling pci_fixup_video+0x0/0xc9
[    0.485566] pci 0000:01:0b.0: calling quirk_cardbus_legacy+0x0/0x30
[    0.485569] pci 0000:01:0b.0: calling quirk_usb_early_handoff+0x0/0x441
[    0.485571] pci 0000:01:0b.0: calling pci_fixup_video+0x0/0xc9
[    0.485574] pci 0000:02:00.0: calling quirk_cardbus_legacy+0x0/0x30
[    0.485576] pci 0000:02:00.0: calling quirk_usb_early_handoff+0x0/0x441
[    0.485578] pci 0000:02:00.0: calling pci_fixup_video+0x0/0xc9
[    0.485581] pci 0000:02:00.1: calling quirk_cardbus_legacy+0x0/0x30
[    0.485584] pci 0000:02:00.1: calling quirk_usb_early_handoff+0x0/0x441
[    0.485586] pci 0000:02:00.1: calling pci_fixup_video+0x0/0xc9
[    0.485589] pci 0000:03:00.0: calling quirk_cardbus_legacy+0x0/0x30
[    0.485591] pci 0000:03:00.0: calling quirk_usb_early_handoff+0x0/0x441
[    0.485593] pci 0000:03:00.0: calling pci_fixup_video+0x0/0xc9
[    0.485596] pci 0000:03:00.0: Boot video device
[    0.485599] pci 0000:03:00.1: calling quirk_cardbus_legacy+0x0/0x30
[    0.485601] pci 0000:03:00.1: calling quirk_usb_early_handoff+0x0/0x441
[    0.485603] pci 0000:03:00.1: calling pci_fixup_video+0x0/0xc9
[    0.485728] pcieport-driver 0000:00:0e.0: setting latency timer to 64
[    0.485759] pcieport-driver 0000:00:0e.0: irq 24 for MSI/MSI-X
[    0.485857] pcieport-driver 0000:00:0f.0: setting latency timer to 64
[    0.485884] pcieport-driver 0000:00:0f.0: irq 25 for MSI/MSI-X
[    0.486177] input: Power Button (FF) as /devices/LNXSYSTM:00/LNXPWRBN:00/input/input0
[    0.486219] ACPI: Power Button (FF) [PWRF]
[    0.486322] input: Power Button (CM) as /devices/LNXSYSTM:00/device:00/PNP0C0C:00/input/input1
[    0.486365] ACPI: Power Button (CM) [PWRB]
[    0.486502] fan PNP0C0B:00: registered as cooling_device0
[    0.486546] ACPI: Fan [FAN] (on)
[    0.487099] processor ACPI_CPU:00: registered as cooling_device1
[    0.487204] processor ACPI_CPU:01: registered as cooling_device2
[    0.493124] ACPI Warning (nspredef-0940): \_TZ_.THRM._PSL: Return Package type mismatch at index 0 - found [NULL Object Descriptor], expected Reference [20081204]
[    0.493250] ACPI: Expecting a [Reference] package element, found type 0
[    0.493290] ACPI: Invalid passive threshold
[    0.493602] thermal LNXTHERM:01: registered as thermal_zone0
[    0.494129] ACPI: Thermal Zone [THRM] (40 C)
[    0.494200] XENFS: not registering filesystem on non-xen platform
[    0.534600] Linux agpgart interface v0.103
[    0.534642] Serial: 8250/16550 driver, 4 ports, IRQ sharing enabled
[    0.534797] serial8250: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
[    0.535444] 00:08: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
[    0.537302] brd: module loaded
[    0.537432] Fixed MDIO Bus: probed
[    0.537487] forcedeth: Reverse Engineered nForce ethernet driver. Version 0.62.
[    0.537878] ACPI: PCI Interrupt Link [APCH] enabled at IRQ 23
[    0.537925] forcedeth 0000:00:08.0: PCI INT A -> Link[APCH] -> GSI 23 (level, low) -> IRQ 23
[    0.537970] forcedeth 0000:00:08.0: setting latency timer to 64
[    0.538015] nv_probe: set workaround bit for reversed mac addr
[    1.050465] forcedeth 0000:00:08.0: ifname eth0, PHY OUI 0x5043 @ 1, addr 00:1e:8c:45:f3:e5
[    1.050508] forcedeth 0000:00:08.0: highdma csum vlan pwrctl mgmt timirq gbit lnktim msi desc-v3
[    1.050866] ACPI: PCI Interrupt Link [AMC1] enabled at IRQ 22
[    1.050911] forcedeth 0000:00:09.0: PCI INT A -> Link[AMC1] -> GSI 22 (level, low) -> IRQ 22
[    1.050954] forcedeth 0000:00:09.0: setting latency timer to 64
[    1.050973] nv_probe: set workaround bit for reversed mac addr
[    1.563453] forcedeth 0000:00:09.0: ifname eth1, PHY OUI 0x5043 @ 1, addr 00:1e:8c:46:0e:74
[    1.563496] forcedeth 0000:00:09.0: highdma csum vlan pwrctl mgmt timirq gbit lnktim msi desc-v3
[    1.563605] console [netcon0] enabled
[    1.563644] netconsole: network logging started
[    1.563682] st: Version 20081215, fixed bufsize 32768, s/g segs 256
[    1.563763] Driver 'st' needs updating - please use bus_type methods
[    1.563885] Driver 'sd' needs updating - please use bus_type methods
[    1.563964] Driver 'sr' needs updating - please use bus_type methods
[    1.564084] SCSI Media Changer driver v0.25 
[    1.564167] Driver 'ch' needs updating - please use bus_type methods
[    1.564254] sata_nv 0000:00:05.0: version 3.5
[    1.564557] ACPI: PCI Interrupt Link [APSI] enabled at IRQ 21
[    1.564602] sata_nv 0000:00:05.0: PCI INT A -> Link[APSI] -> GSI 21 (level, low) -> IRQ 21
[    1.564644] sata_nv 0000:00:05.0: Using SWNCQ mode
[    1.565087] sata_nv 0000:00:05.0: setting latency timer to 64
[    1.565216] scsi0 : sata_nv
[    1.565457] scsi1 : sata_nv
[    1.565726] ata1: SATA max UDMA/133 cmd 0x9f0 ctl 0xbf0 bmdma 0xdc00 irq 21
[    1.565767] ata2: SATA max UDMA/133 cmd 0x970 ctl 0xb70 bmdma 0xdc08 irq 21
[    2.439051] ata1: SATA link up 1.5 Gbps (SStatus 113 SControl 300)
[    2.442205] ata1.00: ATA-7: ST3250410AS, 3.AAC, max UDMA/133
[    2.442245] ata1.00: 488397168 sectors, multi 1: LBA48 NCQ (depth 31/32)
[    2.448207] ata1.00: configured for UDMA/133
[    2.448326] scsi 0:0:0:0: Direct-Access     ATA      ST3250410AS      3.AA PQ: 0 ANSI: 5
[    2.448556] sd 0:0:0:0: [sda] 488397168 512-byte hardware sectors: (250 GB/232 GiB)
[    2.448608] sd 0:0:0:0: [sda] Write Protect is off
[    2.448646] sd 0:0:0:0: [sda] Mode Sense: 00 3a 00 00
[    2.448663] sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[    2.448752] sd 0:0:0:0: [sda] 488397168 512-byte hardware sectors: (250 GB/232 GiB)
[    2.448801] sd 0:0:0:0: [sda] Write Protect is off
[    2.448840] sd 0:0:0:0: [sda] Mode Sense: 00 3a 00 00
[    2.448855] sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[    2.448898]  sda: sda1 sda2 sda3 < sda5 >
[    2.485496] sd 0:0:0:0: [sda] Attached SCSI disk
[    2.485679] sd 0:0:0:0: Attached scsi generic sg0 type 0
[    3.218293] ata2: SATA link down (SStatus 0 SControl 300)
[    3.218679] ACPI: PCI Interrupt Link [APSJ] enabled at IRQ 20
[    3.218727] sata_nv 0000:00:05.1: PCI INT B -> Link[APSJ] -> GSI 20 (level, low) -> IRQ 20
[    3.218769] sata_nv 0000:00:05.1: Using SWNCQ mode
[    3.219202] sata_nv 0000:00:05.1: setting latency timer to 64
[    3.219311] scsi2 : sata_nv
[    3.219468] scsi3 : sata_nv
[    3.219741] ata3: SATA max UDMA/133 cmd 0x9e0 ctl 0xbe0 bmdma 0xc800 irq 20
[    3.219781] ata4: SATA max UDMA/133 cmd 0x960 ctl 0xb60 bmdma 0xc808 irq 20
[    3.952293] ata3: SATA link down (SStatus 0 SControl 300)
[    4.696295] ata4: SATA link down (SStatus 0 SControl 300)
[    4.707391] ACPI: PCI Interrupt Link [ASA2] enabled at IRQ 23
[    4.707431] sata_nv 0000:00:05.2: PCI INT C -> Link[ASA2] -> GSI 23 (level, low) -> IRQ 23
[    4.707474] sata_nv 0000:00:05.2: Using SWNCQ mode
[    4.707870] sata_nv 0000:00:05.2: setting latency timer to 64
[    4.707997] scsi4 : sata_nv
[    4.708178] scsi5 : sata_nv
[    4.708445] ata5: SATA max UDMA/133 cmd 0xc400 ctl 0xc000 bmdma 0xb400 irq 23
[    4.708485] ata6: SATA max UDMA/133 cmd 0xbc00 ctl 0xb800 bmdma 0xb408 irq 23
[    5.441293] ata5: SATA link down (SStatus 0 SControl 300)
[    6.315049] ata6: SATA link up 1.5 Gbps (SStatus 113 SControl 300)
[    6.318109] ata6.00: ATAPI: TSSTcorpCD/DVDW SH-S183L, SB01, max UDMA/33
[    6.318162] ata6.00: applying bridge limits
[    6.324119] ata6.00: configured for UDMA/33
[    6.326469] scsi 5:0:0:0: CD-ROM            TSSTcorp CD/DVDW SH-S183L SB01 PQ: 0 ANSI: 5
[    6.333277] sr0: scsi3-mmc drive: 48x/48x writer dvd-ram cd/rw xa/form2 cdda tray
[    6.333320] Uniform CD-ROM driver Revision: 3.20
[    6.333520] sr 5:0:0:0: Attached scsi CD-ROM sr0
[    6.333668] sr 5:0:0:0: Attached scsi generic sg1 type 5
[    6.333782] pata_amd 0000:00:04.0: version 0.4.1
[    6.333811] pata_amd 0000:00:04.0: setting latency timer to 64
[    6.333876] scsi6 : pata_amd
[    6.334054] scsi7 : pata_amd
[    6.334685] ata7: PATA max UDMA/133 cmd 0x1f0 ctl 0x3f6 bmdma 0xf000 irq 14
[    6.334725] ata8: PATA max UDMA/133 cmd 0x170 ctl 0x376 bmdma 0xf008 irq 15
[    6.495879] ata8: port disabled. ignoring.
[    6.495937] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
[    6.495976] ehci_hcd: block sizes: qh 160 qtd 96 itd 192 sitd 96
[    6.496307] ACPI: PCI Interrupt Link [APCL] enabled at IRQ 22
[    6.496347] ehci_hcd 0000:00:02.1: PCI INT B -> Link[APCL] -> GSI 22 (level, low) -> IRQ 22
[    6.496403] ehci_hcd 0000:00:02.1: setting latency timer to 64
[    6.496405] ehci_hcd 0000:00:02.1: EHCI Host Controller
[    6.496497] drivers/usb/core/inode.c: creating file 'devices'
[    6.496500] drivers/usb/core/inode.c: creating file '001'
[    6.496503] ehci_hcd 0000:00:02.1: new USB bus registered, assigned bus number 1
[    6.496547] ehci_hcd 0000:00:02.1: reset hcs_params 0x101a8a dbg=1 cc=1 pcc=10 !ppc ports=10
[    6.496554] ehci_hcd 0000:00:02.1: reset portroute 0 0 0 0 0 0 0 0 0 0 
[    6.496557] ehci_hcd 0000:00:02.1: reset hcc_params a086 caching frame 256/512/1024 park
[    6.496571] ehci_hcd 0000:00:02.1: park 0
[    6.496574] ehci_hcd 0000:00:02.1: reset command 080b02 park=3 ithresh=8 period=1024 Reset HALT
[    6.496580] ehci_hcd 0000:00:02.1: debug port 1
[    6.496619] ehci_hcd 0000:00:02.1: cache line size of 64 is not supported
[    6.496621] ehci_hcd 0000:00:02.1: supports USB remote wakeup
[    6.496635] ehci_hcd 0000:00:02.1: irq 22, io mem 0xfe02e000
[    6.496675] ehci_hcd 0000:00:02.1: reset command 080b02 park=3 ithresh=8 period=1024 Reset HALT
[    6.496680] ehci_hcd 0000:00:02.1: init command 010009 (park)=0 ithresh=1 period=256 RUN
[    6.502010] ehci_hcd 0000:00:02.1: USB 2.0 started, EHCI 1.00
[    6.502065] usb usb1: default language 0x0409
[    6.502070] usb usb1: New USB device found, idVendor=1d6b, idProduct=0002
[    6.502110] usb usb1: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    6.502154] usb usb1: Product: EHCI Host Controller
[    6.502192] usb usb1: Manufacturer: Linux 2.6.29.1 ehci_hcd
[    6.502229] usb usb1: SerialNumber: 0000:00:02.1
[    6.502319] usb usb1: uevent
[    6.502360] usb usb1: usb_probe_device
[    6.502362] usb usb1: configuration #1 chosen from 1 choice
[    6.502405] usb usb1: adding 1-0:1.0 (config #1, interface 0)
[    6.502417] usb 1-0:1.0: uevent
[    6.502458] hub 1-0:1.0: usb_probe_interface
[    6.502459] hub 1-0:1.0: usb_probe_interface - got id
[    6.502461] hub 1-0:1.0: USB hub found
[    6.502504] hub 1-0:1.0: 10 ports detected
[    6.502542] hub 1-0:1.0: standalone hub
[    6.502543] hub 1-0:1.0: no power switching (usb 1.0)
[    6.502545] hub 1-0:1.0: individual port over-current protection
[    6.502546] hub 1-0:1.0: power on to power good time: 20ms
[    6.502550] hub 1-0:1.0: local power source is good
[    6.502552] hub 1-0:1.0: trying to enable port power on non-switchable hub
[    6.502679] drivers/usb/core/inode.c: creating file '001'
[    6.502793] ohci_hcd: USB 1.1 'Open' Host Controller (OHCI) Driver
[    6.502833] ohci_hcd: block sizes: ed 80 td 96
[    6.503158] ACPI: PCI Interrupt Link [APCF] enabled at IRQ 21
[    6.503198] ohci_hcd 0000:00:02.0: PCI INT A -> Link[APCF] -> GSI 21 (level, low) -> IRQ 21
[    6.503247] ohci_hcd 0000:00:02.0: setting latency timer to 64
[    6.503249] ohci_hcd 0000:00:02.0: OHCI Host Controller
[    6.503328] drivers/usb/core/inode.c: creating file '002'
[    6.503331] ohci_hcd 0000:00:02.0: new USB bus registered, assigned bus number 2
[    6.503382] ohci_hcd 0000:00:02.0: created debug files
[    6.503383] ohci_hcd 0000:00:02.0: supports USB remote wakeup
[    6.503387] ohci_hcd 0000:00:02.0: irq 21, io mem 0xfe02f000
[    6.556027] ohci_hcd 0000:00:02.0: OHCI controller state
[    6.556029] ohci_hcd 0000:00:02.0: OHCI 1.0, NO legacy support registers
[    6.556031] ohci_hcd 0000:00:02.0: control 0x683 RWE RWC HCFS=operational CBSR=3
[    6.556033] ohci_hcd 0000:00:02.0: cmdstatus 0x00000 SOC=0
[    6.556036] ohci_hcd 0000:00:02.0: intrstatus 0x00000004 SF
[    6.556038] ohci_hcd 0000:00:02.0: intrenable 0x8000004a MIE RHSC RD WDH
[    6.556043] ohci_hcd 0000:00:02.0: hcca frame #0003
[    6.556046] ohci_hcd 0000:00:02.0: roothub.a 0100120a POTPGT=1 NOCP NPS NDP=10(10)
[    6.556048] ohci_hcd 0000:00:02.0: roothub.b 00000000 PPCM=0000 DR=0000
[    6.556051] ohci_hcd 0000:00:02.0: roothub.status 00008000 DRWE
[    6.556054] ohci_hcd 0000:00:02.0: roothub.portstatus [0] 0x00000100 PPS
[    6.556056] ohci_hcd 0000:00:02.0: roothub.portstatus [1] 0x00000100 PPS
[    6.556059] ohci_hcd 0000:00:02.0: roothub.portstatus [2] 0x00000100 PPS
[    6.556062] ohci_hcd 0000:00:02.0: roothub.portstatus [3] 0x00000100 PPS
[    6.556064] ohci_hcd 0000:00:02.0: roothub.portstatus [4] 0x00000100 PPS
[    6.556067] ohci_hcd 0000:00:02.0: roothub.portstatus [5] 0x00000100 PPS
[    6.556070] ohci_hcd 0000:00:02.0: roothub.portstatus [6] 0x00000100 PPS
[    6.556072] ohci_hcd 0000:00:02.0: roothub.portstatus [7] 0x00000100 PPS
[    6.556075] ohci_hcd 0000:00:02.0: roothub.portstatus [8] 0x00000100 PPS
[    6.556078] ohci_hcd 0000:00:02.0: roothub.portstatus [9] 0x00000100 PPS
[    6.556084] usb usb2: default language 0x0409
[    6.556090] usb usb2: New USB device found, idVendor=1d6b, idProduct=0001
[    6.556132] usb usb2: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    6.556174] usb usb2: Product: OHCI Host Controller
[    6.556212] usb usb2: Manufacturer: Linux 2.6.29.1 ohci_hcd
[    6.556251] usb usb2: SerialNumber: 0000:00:02.0
[    6.556331] usb usb2: uevent
[    6.556364] usb usb2: usb_probe_device
[    6.556365] usb usb2: configuration #1 chosen from 1 choice
[    6.556406] usb usb2: adding 2-0:1.0 (config #1, interface 0)
[    6.556417] usb 2-0:1.0: uevent
[    6.556458] hub 2-0:1.0: usb_probe_interface
[    6.556460] hub 2-0:1.0: usb_probe_interface - got id
[    6.556461] hub 2-0:1.0: USB hub found
[    6.556504] hub 2-0:1.0: 10 ports detected
[    6.556542] hub 2-0:1.0: standalone hub
[    6.556543] hub 2-0:1.0: no power switching (usb 1.0)
[    6.556544] hub 2-0:1.0: no over-current protection
[    6.556545] hub 2-0:1.0: power on to power good time: 2ms
[    6.556549] hub 2-0:1.0: local power source is good
[    6.556550] hub 2-0:1.0: trying to enable port power on non-switchable hub
[    6.556620] drivers/usb/core/inode.c: creating file '001'
[    6.556731] Initializing USB Mass Storage driver...
[    6.556818] usbcore: registered new interface driver usb-storage
[    6.556857] USB Mass Storage support registered.
[    6.556938] usbcore: registered new interface driver libusual
[    6.557066] PNP: PS/2 Controller [PNP0303:PS2K] at 0x60,0x64 irq 1
[    6.557105] PNP: PS/2 appears to have AUX port disabled, if this is incorrect please boot with i8042.nopnp
[    6.557267] serio: i8042 KBD port at 0x60,0x64 irq 1
[    6.557408] mice: PS/2 mouse device common for all mice
[    6.566113] md: linear personality registered for level -1
[    6.566156] md: raid0 personality registered for level 0
[    6.566195] md: raid1 personality registered for level 1
[    6.566234] md: raid10 personality registered for level 10
[    6.583007] raid6: int64x1   2195 MB/s
[    6.597930] input: AT Translated Set 2 keyboard as /devices/platform/i8042/serio0/input/input2
[    6.600027] raid6: int64x2   2996 MB/s
[    6.617024] raid6: int64x4   2417 MB/s
[    6.634017] raid6: int64x8   2164 MB/s
[    6.651017] raid6: sse2x1    3636 MB/s
[    6.668008] raid6: sse2x2    4863 MB/s
[    6.685011] raid6: sse2x4    5039 MB/s
[    6.685050] raid6: using algorithm sse2x4 (5039 MB/s)
[    6.685089] md: raid6 personality registered for level 6
[    6.685129] md: raid5 personality registered for level 5
[    6.685171] md: raid4 personality registered for level 4
[    6.685210] md: multipath personality registered for level -4
[    6.685249] md: faulty personality registered for level -5
[    6.685446] device-mapper: uevent: version 1.0.3
[    6.685507] ehci_hcd 0000:00:02.1: GetStatus port 3 status 001403 POWER sig=k CSC CONNECT
[    6.685510] hub 1-0:1.0: port 3: status 0501 change 0001
[    6.685516] ehci_hcd 0000:00:02.1: GetStatus port 4 status 001803 POWER sig=j CSC CONNECT
[    6.685518] hub 1-0:1.0: port 4: status 0501 change 0001
[    6.685523] ehci_hcd 0000:00:02.1: GetStatus port 6 status 001803 POWER sig=j CSC CONNECT
[    6.685526] hub 1-0:1.0: port 6: status 0501 change 0001
[    6.685553] hub 2-0:1.0: state 7 ports 10 chg 0000 evt 0000
[    6.685655] device-mapper: ioctl: 4.14.0-ioctl (2008-04-23) initialised: dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
[    6.685874] device-mapper: multipath: version 1.0.5 loaded
[    6.685916] device-mapper: multipath round-robin: version 1.0.0 loaded
[    6.686077] cpuidle: using governor ladder
[    6.686116] cpuidle: using governor menu
[    6.686880] usbcore: registered new interface driver hiddev
[    6.686955] usbcore: registered new interface driver usbhid
[    6.686994] usbhid: v2.6:USB HID core driver
[    6.687095] Advanced Linux Sound Architecture Driver Version 1.0.18a.
[    6.687779] ACPI: PCI Interrupt Link [AAZA] enabled at IRQ 20
[    6.687820] HDA Intel 0000:00:06.1: PCI INT B -> Link[AAZA] -> GSI 20 (level, low) -> IRQ 20
[    6.687881] HDA Intel 0000:00:06.1: setting latency timer to 64
[    6.785018] hub 1-0:1.0: state 7 ports 10 chg 0058 evt 0000
[    6.785023] hub 1-0:1.0: port 3, status 0501, change 0000, 480 Mb/s
[    6.785030] ehci_hcd 0000:00:02.1: port 3 low speed --> companion
[    6.836015] ehci_hcd 0000:00:02.1: GetStatus port 3 status 003402 POWER OWNER sig=k CSC
[    6.836027] hub 1-0:1.0: port 4, status 0501, change 0000, 480 Mb/s
[    6.887230] ehci_hcd 0000:00:02.1: port 4 high speed
[    6.887232] ehci_hcd 0000:00:02.1: GetStatus port 4 status 001005 POWER sig=se0 PE CONNECT
[    6.938016] usb 1-4: new high speed USB device using ehci_hcd and address 3
[    6.992227] ehci_hcd 0000:00:02.1: port 4 high speed
[    6.992231] ehci_hcd 0000:00:02.1: GetStatus port 4 status 001005 POWER sig=se0 PE CONNECT
[    7.167948] usb 1-4: skipped 1 descriptor after configuration
[    7.167950] usb 1-4: skipped 10 descriptors after interface
[    7.167952] usb 1-4: skipped 1 descriptor after endpoint
[    7.167954] usb 1-4: skipped 20 descriptors after interface
[    7.167958] usb 1-4: skipped 1 descriptor after endpoint
[    7.167960] usb 1-4: skipped 4 descriptors after interface
[    7.167961] usb 1-4: skipped 2 descriptors after interface
[    7.167963] usb 1-4: skipped 1 descriptor after endpoint
[    7.169695] usb 1-4: default language 0x0409
[    7.172696] usb 1-4: New USB device found, idVendor=046d, idProduct=09a1
[    7.172737] usb 1-4: New USB device strings: Mfr=0, Product=0, SerialNumber=2
[    7.172778] usb 1-4: SerialNumber: 2EAA8910
[    7.172863] usb 1-4: uevent
[    7.172906] usb 1-4: usb_probe_device
[    7.172908] usb 1-4: configuration #1 chosen from 1 choice
[    7.173070] usb 1-4: adding 1-4:1.0 (config #1, interface 0)
[    7.173088] usb 1-4:1.0: uevent
[    7.173196] usb 1-4: adding 1-4:1.1 (config #1, interface 1)
[    7.173212] usb 1-4:1.1: uevent
[    7.173248] usb 1-4: adding 1-4:1.2 (config #1, interface 2)
[    7.173265] usb 1-4:1.2: uevent
[    7.173301] usb 1-4: adding 1-4:1.3 (config #1, interface 3)
[    7.173319] usb 1-4:1.3: uevent
[    7.173357] drivers/usb/core/inode.c: creating file '003'
[    7.173428] hub 1-0:1.0: port 6, status 0501, change 0000, 480 Mb/s
[    7.224250] ehci_hcd 0000:00:02.1: port 6 high speed
[    7.224252] ehci_hcd 0000:00:02.1: GetStatus port 6 status 001005 POWER sig=se0 PE CONNECT
[    7.275024] usb 1-6: new high speed USB device using ehci_hcd and address 4
[    7.307496] ALSA device list:
[    7.307534]   #0: HDA NVidia at 0xfe020000 irq 20
[    7.307925] NET: Registered protocol family 15
[    7.308149] RPC: Registered udp transport module.
[    7.308187] RPC: Registered tcp transport module.
[    7.308250] powernow-k8: Found 1 AMD Athlon(tm) 64 X2 Dual Core Processor 5200+ processors (2 cpu cores) (version 2.20.00)
[    7.308353] powernow-k8:    0 : fid 0x12 (2600 MHz), vid 0xc
[    7.308394] powernow-k8:    1 : fid 0x10 (2400 MHz), vid 0xe
[    7.308432] powernow-k8:    2 : fid 0xe (2200 MHz), vid 0x10
[    7.308470] powernow-k8:    3 : fid 0xc (2000 MHz), vid 0x10
[    7.308509] powernow-k8:    4 : fid 0xa (1800 MHz), vid 0x10
[    7.308549] powernow-k8:    5 : fid 0x2 (1000 MHz), vid 0x12
[    7.308836] registered taskstats version 1
[    7.309033] drivers/rtc/hctosys.c: unable to open rtc device (rtc0)
[    7.309073] BIOS EDD facility v0.16 2004-Jun-25, 0 devices found
[    7.309112] EDD information not available.
[    7.309200] md: Waiting for all devices to be available before autodetect
[    7.309239] md: If you don't use raid, use raid=noautodetect
[    7.309415] md: Autodetecting RAID arrays.
[    7.309453] md: Scanned 0 and added 0 devices.
[    7.309491] md: autorun ...
[    7.309528] md: ... autorun DONE.
[    7.326259] ehci_hcd 0000:00:02.1: port 6 high speed
[    7.326262] ehci_hcd 0000:00:02.1: GetStatus port 6 status 001005 POWER sig=se0 PE CONNECT
[    7.339384] kjournald starting.  Commit interval 5 seconds
[    7.339392] EXT3-fs: mounted filesystem with ordered data mode.
[    7.339403] VFS: Mounted root (ext3 filesystem) readonly on device 8:2.
[    7.339415] Freeing unused kernel memory: 1356k freed
[    7.390704] usb 1-6: default language 0x0409
[    7.391703] usb 1-6: New USB device found, idVendor=058f, idProduct=6362
[    7.391757] usb 1-6: New USB device strings: Mfr=1, Product=2, SerialNumber=3
[    7.391805] usb 1-6: Product: Mass Storage Device
[    7.391851] usb 1-6: Manufacturer: Generic
[    7.391895] usb 1-6: SerialNumber: 058F312D81B1
[    7.392062] usb 1-6: uevent
[    7.392159] usb 1-6: usb_probe_device
[    7.392164] usb 1-6: configuration #1 chosen from 1 choice
[    7.392328] usb 1-6: adding 1-6:1.0 (config #1, interface 0)
[    7.392364] usb 1-6:1.0: uevent
[    7.392451] usb-storage 1-6:1.0: usb_probe_interface
[    7.392463] usb-storage 1-6:1.0: usb_probe_interface - got id
[    7.392590] scsi8 : SCSI emulation for USB Mass Storage devices
[    7.392885] usb-storage: device found at 4
[    7.392889] usb-storage: waiting for device to settle before scanning
[    7.393190] drivers/usb/core/inode.c: creating file '004'
[    7.393338] hub 2-0:1.0: state 7 ports 10 chg 0000 evt 0008
[    7.393350] ohci_hcd 0000:00:02.0: GetStatus roothub.portstatus [2] = 0x00010301 CSC LSDA PPS CCS
[    7.393360] hub 2-0:1.0: port 3, status 0301, change 0001, 1.5 Mb/s
[    7.497028] hub 2-0:1.0: debounce: port 3: total 100ms stable 100ms status 0x301
[    7.500019] Clocksource tsc unstable (delta = -78034892 ns)
[    7.603031] ohci_hcd 0000:00:02.0: GetStatus roothub.portstatus [2] = 0x00100303 PRSC LSDA PPS PES CCS
[    7.654030] usb 2-3: new low speed USB device using ohci_hcd and address 2
[    7.762035] ohci_hcd 0000:00:02.0: GetStatus roothub.portstatus [2] = 0x00100303 PRSC LSDA PPS PES CCS
[    7.835047] usb 2-3: skipped 1 descriptor after interface
[    7.838048] usb 2-3: default language 0x0409
[    7.845044] usb 2-3: New USB device found, idVendor=047d, idProduct=102d
[    7.845100] usb 2-3: New USB device strings: Mfr=1, Product=2, SerialNumber=0
[    7.845163] usb 2-3: Product: Kensington USB/PS2 Wheel Mouse
[    7.845211] usb 2-3: Manufacturer: Kensington     
[    7.845447] usb 2-3: uevent
[    7.845552] usb 2-3: usb_probe_device
[    7.845557] usb 2-3: configuration #1 chosen from 1 choice
[    7.848044] usb 2-3: adding 2-3:1.0 (config #1, interface 0)
[    7.848093] usb 2-3:1.0: uevent
[    7.848201] usbhid 2-3:1.0: usb_probe_interface
[    7.848206] usbhid 2-3:1.0: usb_probe_interface - got id
[    7.855703] input: Kensington      Kensington USB/PS2 Wheel Mouse as /devices/pci0000:00/0000:00:02.0/usb2/2-3/2-3:1.0/input/input3
[    7.861381] generic-usb 0003:047D:102D.0001: input,hidraw0: USB HID v1.10 Mouse [Kensington      Kensington USB/PS2 Wheel Mouse] on usb-0000:00:02.0-3/input0
[    7.861596] drivers/usb/core/inode.c: creating file '002'
[    7.861825] hub 1-0:1.0: state 7 ports 10 chg 0000 evt 0008
[    7.861838] hub 2-0:1.0: state 7 ports 10 chg 0000 evt 0008
[   12.392288] usb-storage: device scan complete
[   12.393985] scsi 8:0:0:0: Direct-Access     Generic  USB SD Reader    1.00 PQ: 0 ANSI: 0
[   12.394729] scsi 8:0:0:1: Direct-Access     Generic  USB CF Reader    1.01 PQ: 0 ANSI: 0
[   12.395354] scsi 8:0:0:2: Direct-Access     Generic  USB SM Reader    1.02 PQ: 0 ANSI: 0
[   12.395978] scsi 8:0:0:3: Direct-Access     Generic  USB MS Reader    1.03 PQ: 0 ANSI: 0
[   12.397880] sd 8:0:0:0: [sdb] Attached SCSI removable disk
[   12.398239] sd 8:0:0:0: Attached scsi generic sg2 type 0
[   12.399460] sd 8:0:0:1: [sdc] Attached SCSI removable disk
[   12.399740] sd 8:0:0:1: Attached scsi generic sg3 type 0
[   12.400949] sd 8:0:0:2: [sdd] Attached SCSI removable disk
[   12.401230] sd 8:0:0:2: Attached scsi generic sg4 type 0
[   12.402341] sd 8:0:0:3: [sde] Attached SCSI removable disk
[   12.402624] sd 8:0:0:3: Attached scsi generic sg5 type 0
[   13.430865] usb usb2: uevent
[   13.430956] usb 2-0:1.0: uevent
[   13.431135] usb 2-3: uevent
[   13.431224] usb 2-3:1.0: uevent
[   13.432218] usb usb1: uevent
[   13.432305] usb 1-0:1.0: uevent
[   13.432467] usb 1-4: uevent
[   13.432554] usb 1-4:1.0: uevent
[   13.432732] usb 1-4:1.1: uevent
[   13.432819] usb 1-4:1.2: uevent
[   13.432902] usb 1-4:1.3: uevent
[   13.433071] usb 1-6: uevent
[   13.433159] usb 1-6:1.0: uevent
[   13.630913] Linux video capture interface: v2.00
[   13.642303] i2c-adapter i2c-0: nForce2 SMBus adapter at 0x1c00
[   13.642353] ACPI: I/O resource nForce2_smbus [0x1c40-0x1c7f] conflicts with ACPI region SM01 [0x1c40-0x1c45]
[   13.642356] ACPI: Device needs an ACPI driver
[   13.642386] i2c-adapter i2c-1: nForce2 SMBus adapter at 0x1c40
[   13.650589] uvcvideo 1-4:1.0: usb_probe_interface
[   13.650592] uvcvideo 1-4:1.0: usb_probe_interface - got id
[   13.650619] uvcvideo: Found UVC 1.00 device <unnamed> (046d:09a1)
[   13.654747] input: UVC Camera (046d:09a1) as /devices/pci0000:00/0000:00:02.1/usb1/1-4/1-4:1.0/input/input4
[   13.662126] usb 1-4: link qh16-0001/ffff8800df808320 start 15 [1/0 us]
[   13.662171] usbcore: registered new interface driver uvcvideo
[   13.662174] USB Video Class driver (v0.1.0)
[   13.797975] usb 2-3:1.0: uevent
[   13.798463] usb 2-3: uevent
[   13.808010] usb 2-3:1.0: uevent
[   13.808521] usb 2-3: uevent
[   13.881489] usb 1-6:1.0: uevent
[   13.883235] usb 1-6: uevent
[   13.889204] usb 1-6:1.0: uevent
[   13.890313] usb 1-6: uevent
[   13.965989] usb 1-6:1.0: uevent
[   13.966525] usb 1-6: uevent
[   13.976840] usb 1-6:1.0: uevent
[   13.977355] usb 1-6: uevent
[   14.379940] ACPI: PCI Interrupt Link [APC4] enabled at IRQ 19
[   14.379953] ohci1394 0000:01:0b.0: PCI INT A -> Link[APC4] -> GSI 19 (level, low) -> IRQ 19
[   14.432073] ohci1394: fw-host0: OHCI-1394 1.1 (PCI): IRQ=[19]  MMIO=[fdeff000-fdeff7ff]  Max Packet=[2048]  IR/IT contexts=[4/8]
[   14.441546] k8temp 0000:00:18.3: Temperature readouts might be wrong - check erratum #141
[   14.473880] pata_jmicron 0000:02:00.1: enabling device (0000 -> 0001)
[   14.474465] ACPI: PCI Interrupt Link [APC8] enabled at IRQ 16
[   14.474477] pata_jmicron 0000:02:00.1: PCI INT B -> Link[APC8] -> GSI 16 (level, low) -> IRQ 16
[   14.474514] pata_jmicron 0000:02:00.1: enabling bus mastering
[   14.474518] pata_jmicron 0000:02:00.1: setting latency timer to 64
[   14.474604] scsi9 : pata_jmicron
[   14.474861] scsi10 : pata_jmicron
[   14.474910] ata9: PATA max UDMA/100 cmd 0x9c00 ctl 0x9800 bmdma 0x8c00 irq 16
[   14.474912] ata10: PATA max UDMA/100 cmd 0x9400 ctl 0x9000 bmdma 0x8c08 irq 16
[   14.513572] forcedeth 0000:00:08.0: irq 26 for MSI/MSI-X
[   14.513785] eth0: no link during initialization.
[   14.520606] forcedeth 0000:00:09.0: irq 27 for MSI/MSI-X
[   14.520837] eth1: no link during initialization.
[   15.687164] ieee1394: Host added: ID:BUS[0-00:1023]  GUID[001e8c00000e5437]
[   16.939677] eth0: link up.
[   17.480218] usb 1-4:1.0: uevent
[   17.480741] usb 1-4: uevent
[   17.500690] usb 1-4:1.0: uevent
[   17.502150] usb 1-4: uevent
[   17.731101] usbcore: registered new interface driver usbserial
[   17.731149] USB Serial support registered for generic
[   17.731175] usbserial_generic 1-4:1.2: usb_probe_interface
[   17.731179] usbserial_generic 1-4:1.2: usb_probe_interface - got id
[   17.731204] usbserial_generic 1-4:1.3: usb_probe_interface
[   17.731223] usbserial_generic 1-4:1.3: usb_probe_interface - got id
[   17.731430] usbcore: registered new interface driver usbserial_generic
[   17.731437] usbserial: USB Serial Driver core
[   17.743081] USB Serial support registered for FTDI USB Serial Device
[   17.743268] usbcore: registered new interface driver ftdi_sio
[   17.743318] ftdi_sio: v1.4.3:USB FTDI Serial Converters Driver
[   18.243566] EXT3 FS on sda2, internal journal
[   18.718713] kjournald starting.  Commit interval 5 seconds
[   18.726199] EXT3 FS on sda1, internal journal
[   18.726210] EXT3-fs: mounted filesystem with ordered data mode.
[   29.633181] usb usb2: uevent
[   29.633327] usb 2-0:1.0: uevent
[   29.633538] usb 2-3: uevent
[   29.633697] usb 2-3:1.0: uevent
[   29.635208] usb usb1: uevent
[   29.635351] usb 1-0:1.0: uevent
[   29.635572] usb 1-4: uevent
[   29.635715] usb 1-4:1.0: uevent
[   29.636420] usb 1-4:1.1: uevent
[   29.636507] usb 1-4:1.2: uevent
[   29.636593] usb 1-4:1.3: uevent
[   29.636801] usb 1-6: uevent
[   29.636943] usb 1-6:1.0: uevent
[   30.609114] warning: `dhcpd3' uses 32-bit capabilities (legacy support in use)
[   30.894271] NET: Registered protocol family 17
[   31.143719] ACPI: PCI Interrupt Link [APC6] enabled at IRQ 16
[   31.143730] pci 0000:03:00.0: PCI INT A -> Link[APC6] -> GSI 16 (level, low) -> IRQ 16
[   31.225856] [drm] Initialized drm 1.1.0 20060810
[   31.241316] pci 0000:03:00.0: setting latency timer to 64
[   31.241626] [drm] Initialized radeon 1.29.0 20080528 on minor 0
[   31.580193] [drm] Setting GART location based on new memory map
[   31.580999] [drm] Loading R500 Microcode
[   31.581029] [drm] Num pipes: 1
[   31.697313] [drm] writeback test failed
[   37.169214] usb 1-6:1.0: uevent
[   37.169570] usb 1-6: uevent
[   37.171109] usb 1-6:1.0: uevent
[   37.171609] usb 1-6: uevent
[   37.187124] usb 1-6:1.0: uevent
[   37.187450] usb 1-6: uevent
[   37.214158] usb 1-6:1.0: uevent
[   37.214375] usb 1-6: uevent
[  315.235156] device eth0 entered promiscuous mode
[  315.245149] device eth0 left promiscuous mode
[  318.644027] device eth0 entered promiscuous mode
[158091.895015] device eth0 left promiscuous mode

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
