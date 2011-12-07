From: Nico Schottelius <nico-linux-20111201@schottelius.org>
Subject: BCM43224 hanging [3.2.0-rc4-00248-gb835c0f] (was: BCM43224:
 00:00:00:00:00:00 address (3.2.0-rc3-00099-g883381d))
Date: Wed, 7 Dec 2011 20:08:21 +0100
Message-ID: <20111207190821.GA1775@schottelius.org>
References: <20111201224851.GB20536@ethz.ch>
 <4ED8B610.2010703@broadcom.com>
 <20111202150128.GC3096@schottelius.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Nico Schottelius <nico-linux-20111201@schottelius.org>,
	Arend van Spriel <arend@broadcom.com>,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	b43-dev@lists.infradead.org, Greg KH <gregkh@suse.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20111202150128.GC3096@schottelius.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Update:

The hang situation always happens, when the nic does *not* have
a connection. And it still covers all network processes (i.e.
including sudo, wpa_supplicant, postfix, etc.).

Starting up the computer, having wpa_supplicant connect successfully,
everything works fine.

Until the connection is lost or I issue "select_network 4", which
changes to another network.

The problem also exists, if I startup wpa_supplicant and there
is no network connection available.

Verified that this bug exists in my pathced 3.1.0-rc6-g443452b
as well as in 3.2.0-rc4-00248-gb835c0f.

This is rather nasty, because it forces me to reboot as soon as
I've started up wlan by accident.

Is there a workaround available somewhere (besides using USB-LAN)?

Attached are output of 3.1.0-rc6-g443452b, which is the same for
all failing versions.

Cheers,

Nico


--------------------------------------------------------------------------------

3.1.0-rc6-g443452b


[    0.000000] Initializing cgroup subsys cpuset
[    0.000000] Initializing cgroup subsys cpu
[    0.000000] Linux version 3.1.0-rc6-g443452b (nico@brief) (gcc version 4.6.1 20110819 (prerelease) (GCC) ) #5 SMP PREEMPT Wed Oct 19 23:39:31 CEST 2011
[    0.000000] Command line: root=/dev/mapper/root cryptdevice=/dev/sda5:root ro initrd=../initramfs-nico.img BOOT_IMAGE=../vmlinuz-nico 
[    0.000000] BIOS-provided physical RAM map:
[    0.000000]  BIOS-e820: 0000000000000000 - 000000000008f000 (usable)
[    0.000000]  BIOS-e820: 000000000008f000 - 0000000000090000 (reserved)
[    0.000000]  BIOS-e820: 0000000000090000 - 000000000009fc00 (usable)
[    0.000000]  BIOS-e820: 000000000009fc00 - 0000000000100000 (reserved)
[    0.000000]  BIOS-e820: 0000000000100000 - 0000000020000000 (usable)
[    0.000000]  BIOS-e820: 0000000020000000 - 0000000020200000 (reserved)
[    0.000000]  BIOS-e820: 0000000020200000 - 0000000040000000 (usable)
[    0.000000]  BIOS-e820: 0000000040000000 - 0000000040200000 (reserved)
[    0.000000]  BIOS-e820: 0000000040200000 - 000000008ad34000 (usable)
[    0.000000]  BIOS-e820: 000000008ad34000 - 000000008ad5f000 (ACPI NVS)
[    0.000000]  BIOS-e820: 000000008ad5f000 - 000000008afa2000 (ACPI data)
[    0.000000]  BIOS-e820: 000000008afa2000 - 000000008afff000 (reserved)
[    0.000000]  BIOS-e820: 000000008afff000 - 000000008b000000 (ACPI data)
[    0.000000]  BIOS-e820: 000000008b000000 - 000000008fa00000 (reserved)
[    0.000000]  BIOS-e820: 00000000e0000000 - 00000000f0000000 (reserved)
[    0.000000]  BIOS-e820: 00000000fec00000 - 00000000fec01000 (reserved)
[    0.000000]  BIOS-e820: 00000000fed00000 - 00000000fed04000 (reserved)
[    0.000000]  BIOS-e820: 00000000fed10000 - 00000000fed14000 (reserved)
[    0.000000]  BIOS-e820: 00000000fed18000 - 00000000fed1a000 (reserved)
[    0.000000]  BIOS-e820: 00000000fed1c000 - 00000000fed20000 (reserved)
[    0.000000]  BIOS-e820: 00000000fee00000 - 00000000fee01000 (reserved)
[    0.000000]  BIOS-e820: 00000000ff800000 - 0000000100000000 (reserved)
[    0.000000]  BIOS-e820: 0000000100000000 - 000000016fe00000 (usable)
[    0.000000] NX (Execute Disable) protection: active
[    0.000000] DMI 2.4 present.
[    0.000000] DMI: Apple Inc. MacBookAir4,2/Mac-742912EFDBEE19B3, BIOS MBA41.88Z.0077.B0E.1110141154 10/14/2011
[    0.000000] e820 update range: 0000000000000000 - 0000000000010000 (usable) ==> (reserved)
[    0.000000] e820 remove range: 00000000000a0000 - 0000000000100000 (usable)
[    0.000000] No AGP bridge found
[    0.000000] last_pfn = 0x16fe00 max_arch_pfn = 0x400000000
[    0.000000] MTRR default type: write-back
[    0.000000] MTRR fixed ranges enabled:
[    0.000000]   00000-9FFFF write-back
[    0.000000]   A0000-BFFFF uncachable
[    0.000000]   C0000-DFFFF write-protect
[    0.000000]   E0000-FFFFF uncachable
[    0.000000] MTRR variable ranges enabled:
[    0.000000]   0 base 0C0000000 mask FC0000000 uncachable
[    0.000000]   1 base 0A0000000 mask FE0000000 uncachable
[    0.000000]   2 base 090000000 mask FF0000000 uncachable
[    0.000000]   3 base 08C000000 mask FFC000000 uncachable
[    0.000000]   4 base 08B800000 mask FFF800000 uncachable
[    0.000000]   5 disabled
[    0.000000]   6 disabled
[    0.000000]   7 disabled
[    0.000000]   8 disabled
[    0.000000]   9 disabled
[    0.000000] x86 PAT enabled: cpu 0, old 0x7040600070406, new 0x7010600070106
[    0.000000] last_pfn = 0x8ad34 max_arch_pfn = 0x400000000
[    0.000000] initial memory mapped : 0 - 20000000
[    0.000000] Base memory trampoline at [ffff88000009a000] 9a000 size 20480
[    0.000000] init_memory_mapping: 0000000000000000-000000008ad34000
[    0.000000]  0000000000 - 008ac00000 page 2M
[    0.000000]  008ac00000 - 008ad34000 page 4k
[    0.000000] kernel direct mapping tables up to 8ad34000 @ 8ad2f000-8ad34000
[    0.000000] init_memory_mapping: 0000000100000000-000000016fe00000
[    0.000000]  0100000000 - 016fe00000 page 2M
[    0.000000] kernel direct mapping tables up to 16fe00000 @ 16fdf9000-16fe00000
[    0.000000] RAMDISK: 1fd14000 - 1ffff000
[    0.000000] ACPI: RSDP 00000000000fe020 00024 (v02 APPLE )
[    0.000000] ACPI: XSDT 000000008ad8e1c0 000AC (v01 APPLE   Apple00 00000060      01000013)
[    0.000000] ACPI: FACP 000000008ad8c000 000F4 (v04 APPLE   Apple00 00000060 Loki 0000005F)
[    0.000000] ACPI: DSDT 000000008ad81000 05050 (v01 APPLE  MacBookA 00040001 INTL 20100915)
[    0.000000] ACPI: FACS 000000008ad3e000 00040
[    0.000000] ACPI: HPET 000000008ad8b000 00038 (v01 APPLE   Apple00 00000001 Loki 0000005F)
[    0.000000] ACPI: APIC 000000008ad8a000 000BC (v02 APPLE   Apple00 00000001 Loki 0000005F)
[    0.000000] ACPI: SBST 000000008ad88000 00030 (v01 APPLE   Apple00 00000001 Loki 0000005F)
[    0.000000] ACPI: ECDT 000000008ad87000 00053 (v01 APPLE   Apple00 00000001 Loki 0000005F)
[    0.000000] ACPI: SSDT 000000008ad7d000 00024 (v01 APPLE   SmcDppt 00001000 INTL 20100915)
[    0.000000] ACPI: SSDT 000000008ad7b000 006CA (v01 APPLE     UsbSD 00001000 INTL 20100915)
[    0.000000] ACPI: SSDT 000000008ad77000 00159 (v02 APPLE     IGHda 00001000 INTL 20100915)
[    0.000000] ACPI: SSDT 000000008ad73000 015EB (v02 APPLE  SsdtIGPU 00001000 INTL 20100915)
[    0.000000] ACPI: SSDT 000000008ad72000 00569 (v01  PmRef  Cpu0Ist 00003000 INTL 20100915)
[    0.000000] ACPI: SSDT 000000008ad71000 009B1 (v01  PmRef    CpuPm 00003000 INTL 20100915)
[    0.000000] ACPI: SSDT 000000008ad70000 00315 (v01  PmRef  Cpu0Tst 00003000 INTL 20100915)
[    0.000000] ACPI: SSDT 000000008ad6f000 0037A (v01  PmRef    ApTst 00003000 INTL 20100915)
[    0.000000] ACPI: MCFG 000000008ad89000 0003C (v01 APPLE   Apple00 00000001 Loki 0000005F)
[    0.000000] ACPI: SSDT 000000008ad80000 000FA (v01 SataRe  SataPri 00001000 INTL 20100915)
[    0.000000] ACPI: SSDT 000000008ad7f000 000D0 (v01 SataRe  SataSec 00001000 INTL 20100915)
[    0.000000] ACPI: SSDT 000000008ad7e000 00032 (v01  Apple   SsdtS3 00001000 INTL 20100915)
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] No NUMA configuration found
[    0.000000] Faking a node at 0000000000000000-000000016fe00000
[    0.000000] Initmem setup node 0 0000000000000000-000000016fe00000
[    0.000000]   NODE_DATA [000000016fdfb000 - 000000016fdfffff]
[    0.000000]  [ffffea0000000000-ffffea0005bfffff] PMD -> [ffff88016b400000-ffff88016f3fffff] on node 0
[    0.000000] Zone PFN ranges:
[    0.000000]   DMA      0x00000010 -> 0x00001000
[    0.000000]   DMA32    0x00001000 -> 0x00100000
[    0.000000]   Normal   0x00100000 -> 0x0016fe00
[    0.000000] Movable zone start PFN for each node
[    0.000000] early_node_map[6] active PFN ranges
[    0.000000]     0: 0x00000010 -> 0x0000008f
[    0.000000]     0: 0x00000090 -> 0x0000009f
[    0.000000]     0: 0x00000100 -> 0x00020000
[    0.000000]     0: 0x00020200 -> 0x00040000
[    0.000000]     0: 0x00040200 -> 0x0008ad34
[    0.000000]     0: 0x00100000 -> 0x0016fe00
[    0.000000] On node 0 totalpages: 1025730
[    0.000000]   DMA zone: 64 pages used for memmap
[    0.000000]   DMA zone: 5 pages reserved
[    0.000000]   DMA zone: 3913 pages, LIFO batch:0
[    0.000000]   DMA32 zone: 16320 pages used for memmap
[    0.000000]   DMA32 zone: 547188 pages, LIFO batch:31
[    0.000000]   Normal zone: 7160 pages used for memmap
[    0.000000]   Normal zone: 451080 pages, LIFO batch:31
[    0.000000] ACPI: PM-Timer IO Port: 0x408
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] ACPI: LAPIC (acpi_id[0x01] lapic_id[0x00] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x02] lapic_id[0x02] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x03] lapic_id[0x01] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x04] lapic_id[0x03] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x05] lapic_id[0xff] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x06] lapic_id[0xff] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x07] lapic_id[0xff] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x08] lapic_id[0xff] disabled)
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x01] high edge lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x02] high edge lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x03] high edge lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x04] high edge lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x05] high edge lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x06] high edge lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x07] high edge lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x08] high edge lint[0x1])
[    0.000000] ACPI: IOAPIC (id[0x02] address[0xfec00000] gsi_base[0])
[    0.000000] IOAPIC[0]: apic_id 2, version 32, address 0xfec00000, GSI 0-23
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
[    0.000000] ACPI: IRQ0 used by override.
[    0.000000] ACPI: IRQ2 used by override.
[    0.000000] ACPI: IRQ9 used by override.
[    0.000000] Using ACPI (MADT) for SMP configuration information
[    0.000000] ACPI: HPET id: 0x8086a201 base: 0xfed00000
[    0.000000] SMP: Allowing 8 CPUs, 4 hotplug CPUs
[    0.000000] nr_irqs_gsi: 40
[    0.000000] PM: Registered nosave memory: 000000000008f000 - 0000000000090000
[    0.000000] PM: Registered nosave memory: 000000000009f000 - 00000000000a0000
[    0.000000] PM: Registered nosave memory: 00000000000a0000 - 0000000000100000
[    0.000000] PM: Registered nosave memory: 0000000020000000 - 0000000020200000
[    0.000000] PM: Registered nosave memory: 0000000040000000 - 0000000040200000
[    0.000000] PM: Registered nosave memory: 000000008ad34000 - 000000008ad5f000
[    0.000000] PM: Registered nosave memory: 000000008ad5f000 - 000000008afa2000
[    0.000000] PM: Registered nosave memory: 000000008afa2000 - 000000008afff000
[    0.000000] PM: Registered nosave memory: 000000008afff000 - 000000008b000000
[    0.000000] PM: Registered nosave memory: 000000008b000000 - 000000008fa00000
[    0.000000] PM: Registered nosave memory: 000000008fa00000 - 00000000e0000000
[    0.000000] PM: Registered nosave memory: 00000000e0000000 - 00000000f0000000
[    0.000000] PM: Registered nosave memory: 00000000f0000000 - 00000000fec00000
[    0.000000] PM: Registered nosave memory: 00000000fec00000 - 00000000fec01000
[    0.000000] PM: Registered nosave memory: 00000000fec01000 - 00000000fed00000
[    0.000000] PM: Registered nosave memory: 00000000fed00000 - 00000000fed04000
[    0.000000] PM: Registered nosave memory: 00000000fed04000 - 00000000fed10000
[    0.000000] PM: Registered nosave memory: 00000000fed10000 - 00000000fed14000
[    0.000000] PM: Registered nosave memory: 00000000fed14000 - 00000000fed18000
[    0.000000] PM: Registered nosave memory: 00000000fed18000 - 00000000fed1a000
[    0.000000] PM: Registered nosave memory: 00000000fed1a000 - 00000000fed1c000
[    0.000000] PM: Registered nosave memory: 00000000fed1c000 - 00000000fed20000
[    0.000000] PM: Registered nosave memory: 00000000fed20000 - 00000000fee00000
[    0.000000] PM: Registered nosave memory: 00000000fee00000 - 00000000fee01000
[    0.000000] PM: Registered nosave memory: 00000000fee01000 - 00000000ff800000
[    0.000000] PM: Registered nosave memory: 00000000ff800000 - 0000000100000000
[    0.000000] Allocating PCI resources starting at 8fa00000 (gap: 8fa00000:50600000)
[    0.000000] Booting paravirtualized kernel on bare hardware
[    0.000000] setup_percpu: NR_CPUS:64 nr_cpumask_bits:64 nr_cpu_ids:8 nr_node_ids:1
[    0.000000] PERCPU: Embedded 28 pages/cpu @ffff88016fa00000 s82048 r8192 d24448 u262144
[    0.000000] pcpu-alloc: s82048 r8192 d24448 u262144 alloc=1*2097152
[    0.000000] pcpu-alloc: [0] 0 1 2 3 4 5 6 7 
[    0.000000] Built 1 zonelists in Node order, mobility grouping on.  Total pages: 1002181
[    0.000000] Policy zone: Normal
[    0.000000] Kernel command line: root=/dev/mapper/root cryptdevice=/dev/sda5:root ro initrd=../initramfs-nico.img BOOT_IMAGE=../vmlinuz-nico 
[    0.000000] PID hash table entries: 4096 (order: 3, 32768 bytes)
[    0.000000] xsave/xrstor: enabled xstate_bv 0x7, cntxt size 0x340
[    0.000000] Checking aperture...
[    0.000000] No AGP bridge found
[    0.000000] Calgary: detecting Calgary via BIOS EBDA area
[    0.000000] Calgary: Unable to locate Rio Grande table in EBDA - bailing!
[    0.000000] Memory: 3946436k/6027264k available (4294k kernel code, 1924344k absent, 156484k reserved, 5506k data, 724k init)
[    0.000000] SLUB: Genslabs=15, HWalign=64, Order=0-3, MinObjects=0, CPUs=8, Nodes=1
[    0.000000] Preemptible hierarchical RCU implementation.
[    0.000000] 	Verbose stalled-CPUs detection is disabled.
[    0.000000] NR_IRQS:2304
[    0.000000] Extended CMOS year: 2000
[    0.000000] Console: colour VGA+ 80x25
[    0.000000] console [tty0] enabled
[    0.000000] Lock dependency validator: Copyright (c) 2006 Red Hat, Inc., Ingo Molnar
[    0.000000] ... MAX_LOCKDEP_SUBCLASSES:  8
[    0.000000] ... MAX_LOCK_DEPTH:          48
[    0.000000] ... MAX_LOCKDEP_KEYS:        8191
[    0.000000] ... CLASSHASH_SIZE:          4096
[    0.000000] ... MAX_LOCKDEP_ENTRIES:     16384
[    0.000000] ... MAX_LOCKDEP_CHAINS:      32768
[    0.000000] ... CHAINHASH_SIZE:          16384
[    0.000000]  memory used by lock dependency info: 5855 kB
[    0.000000]  per task-struct memory footprint: 1920 bytes
[    0.000000] allocated 33554432 bytes of page_cgroup
[    0.000000] please try 'cgroup_disable=memory' option if you don't want memory cgroups
[    0.000000] hpet clockevent registered
[    0.000000] Fast TSC calibration using PIT
[    0.003333] Detected 1800.216 MHz processor.
[    0.000003] Calibrating delay loop (skipped), value calculated using timer frequency.. 3601.45 BogoMIPS (lpj=6000720)
[    0.000137] pid_max: default: 32768 minimum: 301
[    0.000380] Security Framework initialized
[    0.000447] AppArmor: AppArmor disabled by boot time parameter
[    0.001095] Dentry cache hash table entries: 524288 (order: 10, 4194304 bytes)
[    0.002388] Inode-cache hash table entries: 262144 (order: 9, 2097152 bytes)
[    0.002943] Mount-cache hash table entries: 256
[    0.004398] Initializing cgroup subsys cpuacct
[    0.004498] Initializing cgroup subsys memory
[    0.004615] Initializing cgroup subsys devices
[    0.004680] Initializing cgroup subsys freezer
[    0.004747] Initializing cgroup subsys net_cls
[    0.004812] Initializing cgroup subsys blkio
[    0.004982] CPU: Physical Processor ID: 0
[    0.005047] CPU: Processor Core ID: 0
[    0.005113] mce: CPU supports 7 MCE banks
[    0.005189] CPU0: Thermal monitoring enabled (TM1)
[    0.005271] using mwait in idle threads.
[    0.007101] ACPI: Core revision 20110623
[    0.028691] ftrace: allocating 16325 entries in 65 pages
[    0.037334] ..TIMER: vector=0x30 apic1=0 pin1=2 apic2=-1 pin2=-1
[    0.070360] CPU0: Intel(R) Core(TM) i7-2677M CPU @ 1.80GHz stepping 07
[    0.173903] Performance Events: PEBS fmt1+, SandyBridge events, Intel PMU driver.
[    0.174114] ... version:                3
[    0.174176] ... bit width:              48
[    0.174240] ... generic registers:      4
[    0.174302] ... value mask:             0000ffffffffffff
[    0.174368] ... max period:             000000007fffffff
[    0.174433] ... fixed-purpose events:   3
[    0.174496] ... event mask:             000000070000000f
[    0.194470] NMI watchdog enabled, takes one hw-pmu counter.
[    0.213912] lockdep: fixing up alternatives.
[    0.220658] Booting Node   0, Processors  #1
[    0.220750] smpboot cpu 1: start_ip = 9a000
[    0.333896] NMI watchdog enabled, takes one hw-pmu counter.
[    0.353657] lockdep: fixing up alternatives.
[    0.353766]  #2
[    0.353813] smpboot cpu 2: start_ip = 9a000
[    0.466972] NMI watchdog enabled, takes one hw-pmu counter.
[    0.486775] lockdep: fixing up alternatives.
[    0.486884]  #3
[    0.486930] smpboot cpu 3: start_ip = 9a000
[    0.600006] NMI watchdog enabled, takes one hw-pmu counter.
[    0.606574] Brought up 4 CPUs
[    0.606652] Total of 4 processors activated (14406.37 BogoMIPS).
[    0.611141] devtmpfs: initialized
[    0.612655] PM: Registering ACPI NVS region at 8ad34000 (176128 bytes)
[    0.614167] print_constraints: dummy: 
[    0.614503] NET: Registered protocol family 16
[    0.614848] ACPI: bus type pci registered
[    0.615152] PCI: MMCONFIG for domain 0000 [bus 00-97] at [mem 0xe0000000-0xe97fffff] (base 0xe0000000)
[    0.615242] PCI: MMCONFIG at [mem 0xe0000000-0xe97fffff] reserved in E820
[    0.674736] PCI: Using configuration type 1 for base access
[    0.675979] bio: create slab <bio-0> at 0
[    0.676235] ACPI: Added _OSI(Module Device)
[    0.676300] ACPI: Added _OSI(Processor Device)
[    0.676365] ACPI: Added _OSI(3.0 _SCP Extensions)
[    0.676430] ACPI: Added _OSI(Processor Aggregator Device)
[    0.682371] ACPI: EC: EC description table is found, configuring boot EC
[    0.696857] [Firmware Bug]: ACPI: BIOS _OSI(Linux) query ignored
[    0.697746] ACPI: SSDT 000000008ad39190 00781 (v01  PmRef  Cpu0Cst 00003001 INTL 20100915)
[    0.699408] ACPI: Dynamic OEM Table Load:
[    0.699554] ACPI: SSDT           (null) 00781 (v01  PmRef  Cpu0Cst 00003001 INTL 20100915)
[    0.710207] ACPI: SSDT 000000008ad3a710 003A4 (v01  PmRef    ApIst 00003000 INTL 20100915)
[    0.711973] ACPI: Dynamic OEM Table Load:
[    0.712118] ACPI: SSDT           (null) 003A4 (v01  PmRef    ApIst 00003000 INTL 20100915)
[    0.719903] ACPI: SSDT 000000008ad38d90 00119 (v01  PmRef    ApCst 00003000 INTL 20100915)
[    0.721578] ACPI: Dynamic OEM Table Load:
[    0.721724] ACPI: SSDT           (null) 00119 (v01  PmRef    ApCst 00003000 INTL 20100915)
[    0.730697] ACPI: Interpreter enabled
[    0.730763] ACPI: (supports S0 S3 S4 S5)
[    0.731035] ACPI: Using IOAPIC for interrupt routing
[    0.758034] ACPI: EC: GPE = 0x17, I/O: command/status = 0x66, data = 0x62
[    0.758561] ACPI: No dock devices found.
[    0.758626] HEST: Table not found.
[    0.758689] PCI: Using host bridge windows from ACPI; if necessary, use "pci=nocrs" and report a bug
[    0.759452] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-ff])
[    0.760567] pci_root PNP0A08:00: host bridge window [io  0x0000-0x0cf7]
[    0.760637] pci_root PNP0A08:00: host bridge window [io  0x0d00-0xffff]
[    0.760707] pci_root PNP0A08:00: host bridge window [mem 0x000a0000-0x000bffff]
[    0.760792] pci_root PNP0A08:00: host bridge window [mem 0x8fa00000-0xfeafffff]
[    0.760876] pci_root PNP0A08:00: host bridge window [mem 0xfed40000-0xfed44fff]
[    0.760995] pci 0000:00:00.0: [8086:0104] type 0 class 0x000600
[    0.761091] pci 0000:00:01.0: [8086:0101] type 1 class 0x000604
[    0.761146] pci 0000:00:01.0: PME# supported from D0 D3hot D3cold
[    0.761150] pci 0000:00:01.0: PME# disabled
[    0.761191] pci 0000:00:02.0: [8086:0116] type 0 class 0x000300
[    0.761212] pci 0000:00:02.0: reg 10: [mem 0xa0000000-0xa03fffff 64bit]
[    0.761225] pci 0000:00:02.0: reg 18: [mem 0x90000000-0x9fffffff 64bit pref]
[    0.761234] pci 0000:00:02.0: reg 20: [io  0x2000-0x203f]
[    0.761346] pci 0000:00:16.0: [8086:1c3a] type 0 class 0x000780
[    0.761391] pci 0000:00:16.0: reg 10: [mem 0xa0607100-0xa060710f 64bit]
[    0.761511] pci 0000:00:16.0: PME# supported from D0 D3hot D3cold
[    0.761517] pci 0000:00:16.0: PME# disabled
[    0.761575] pci 0000:00:1a.0: [8086:1c2c] type 0 class 0x000c03
[    0.761666] pci 0000:00:1a.0: reg 20: [io  0x2140-0x215f]
[    0.761778] pci 0000:00:1a.7: [8086:1c2d] type 0 class 0x000c03
[    0.761818] pci 0000:00:1a.7: reg 10: [mem 0xa0606c00-0xa0606fff]
[    0.761961] pci 0000:00:1a.7: PME# supported from D0 D3hot D3cold
[    0.761968] pci 0000:00:1a.7: PME# disabled
[    0.762014] pci 0000:00:1b.0: [8086:1c20] type 0 class 0x000403
[    0.762047] pci 0000:00:1b.0: reg 10: [mem 0xa0600000-0xa0603fff 64bit]
[    0.762172] pci 0000:00:1b.0: PME# supported from D0 D3hot D3cold
[    0.762178] pci 0000:00:1b.0: PME# disabled
[    0.762221] pci 0000:00:1c.0: [8086:1c10] type 1 class 0x000604
[    0.762359] pci 0000:00:1c.0: PME# supported from D0 D3hot D3cold
[    0.762366] pci 0000:00:1c.0: PME# disabled
[    0.762415] pci 0000:00:1c.1: [8086:1c12] type 1 class 0x000604
[    0.762549] pci 0000:00:1c.1: PME# supported from D0 D3hot D3cold
[    0.762556] pci 0000:00:1c.1: PME# disabled
[    0.762615] pci 0000:00:1d.0: [8086:1c27] type 0 class 0x000c03
[    0.762706] pci 0000:00:1d.0: reg 20: [io  0x20e0-0x20ff]
[    0.762821] pci 0000:00:1d.7: [8086:1c26] type 0 class 0x000c03
[    0.762860] pci 0000:00:1d.7: reg 10: [mem 0xa0606800-0xa0606bff]
[    0.763012] pci 0000:00:1d.7: PME# supported from D0 D3hot D3cold
[    0.763018] pci 0000:00:1d.7: PME# disabled
[    0.763059] pci 0000:00:1f.0: [8086:1c4d] type 0 class 0x000601
[    0.763258] pci 0000:00:1f.2: [8086:1c01] type 0 class 0x000101
[    0.763294] pci 0000:00:1f.2: reg 10: [io  0x2168-0x216f]
[    0.763312] pci 0000:00:1f.2: reg 14: [io  0x217c-0x217f]
[    0.763330] pci 0000:00:1f.2: reg 18: [io  0x2160-0x2167]
[    0.763348] pci 0000:00:1f.2: reg 1c: [io  0x2178-0x217b]
[    0.763365] pci 0000:00:1f.2: reg 20: [io  0x2060-0x206f]
[    0.763382] pci 0000:00:1f.2: reg 24: [io  0xffe0-0xffef]
[    0.763467] pci 0000:00:1f.3: [8086:1c22] type 0 class 0x000c05
[    0.763501] pci 0000:00:1f.3: reg 10: [mem 0xa0607000-0xa06070ff 64bit]
[    0.763549] pci 0000:00:1f.3: reg 20: [io  0xefa0-0xefbf]
[    0.763667] pci 0000:03:00.0: [8086:151a] type 1 class 0x000604
[    0.763740] pci 0000:03:00.0: supports D1 D2
[    0.763742] pci 0000:03:00.0: PME# supported from D0 D1 D2 D3hot D3cold
[    0.763747] pci 0000:03:00.0: PME# disabled
[    0.769692] pci 0000:00:01.0: PCI bridge to [bus 03-97]
[    0.769762] pci 0000:00:01.0:   bridge window [io  0x3000-0x3fff]
[    0.769766] pci 0000:00:01.0:   bridge window [mem 0xa0700000-0xa49fffff]
[    0.769772] pci 0000:00:01.0:   bridge window [mem 0xa4a00000-0xa89fffff 64bit pref]
[    0.769845] pci 0000:04:00.0: [8086:151a] type 1 class 0x000604
[    0.769921] pci 0000:04:00.0: supports D1 D2
[    0.769924] pci 0000:04:00.0: PME# supported from D0 D1 D2 D3hot D3cold
[    0.769928] pci 0000:04:00.0: PME# disabled
[    0.769976] pci 0000:04:03.0: [8086:151a] type 1 class 0x000604
[    0.770052] pci 0000:04:03.0: supports D1 D2
[    0.770054] pci 0000:04:03.0: PME# supported from D0 D1 D2 D3hot D3cold
[    0.770059] pci 0000:04:03.0: PME# disabled
[    0.770097] pci 0000:04:04.0: [8086:151a] type 1 class 0x000604
[    0.770173] pci 0000:04:04.0: supports D1 D2
[    0.770175] pci 0000:04:04.0: PME# supported from D0 D1 D2 D3hot D3cold
[    0.770180] pci 0000:04:04.0: PME# disabled
[    0.770244] pci 0000:03:00.0: PCI bridge to [bus 04-67]
[    0.770319] pci 0000:03:00.0:   bridge window [mem 0xa0700000-0xa09fffff]
[    0.770405] pci 0000:05:00.0: [8086:151a] type 0 class 0x000880
[    0.770425] pci 0000:05:00.0: reg 10: [mem 0xa0700000-0xa073ffff]
[    0.770439] pci 0000:05:00.0: reg 14: [mem 0xa0740000-0xa0740fff]
[    0.770543] pci 0000:05:00.0: supports D1 D2
[    0.770545] pci 0000:05:00.0: PME# supported from D0 D1 D2 D3hot D3cold
[    0.770551] pci 0000:05:00.0: PME# disabled
[    0.776328] pci 0000:04:00.0: PCI bridge to [bus 05-05]
[    0.776414] pci 0000:04:00.0:   bridge window [mem 0xa0700000-0xa07fffff]
[    0.776479] pci 0000:04:03.0: PCI bridge to [bus 06-36]
[    0.776553] pci 0000:04:03.0:   bridge window [mem 0xa0800000-0xa08fffff]
[    0.776617] pci 0000:04:04.0: PCI bridge to [bus 37-67]
[    0.776690] pci 0000:04:04.0:   bridge window [mem 0xa0900000-0xa09fffff]
[    0.776816] pci 0000:00:1c.0: PCI bridge to [bus 01-01]
[    0.776892] pci 0000:00:1c.0:   bridge window [mem 0xa0500000-0xa05fffff]
[    0.777090] pci 0000:02:00.0: [14e4:4353] type 0 class 0x000280
[    0.777153] pci 0000:02:00.0: reg 10: [mem 0xa0400000-0xa0403fff 64bit]
[    0.777432] pci 0000:02:00.0: supports D1 D2
[    0.777434] pci 0000:02:00.0: PME# supported from D0 D3hot D3cold
[    0.777445] pci 0000:02:00.0: PME# disabled
[    0.783030] pci 0000:00:1c.1: PCI bridge to [bus 02-02]
[    0.783105] pci 0000:00:1c.1:   bridge window [mem 0xa0400000-0xa04fffff]
[    0.783172] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0._PRT]
[    0.783454] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.P0P2._PRT]
[    0.783694] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.RP02._PRT]
[    0.783915]  pci0000:00: Requesting ACPI _OSC control (0x1d)
[    0.784240]  pci0000:00: ACPI _OSC control (0x19) granted
[    0.792333] ACPI: PCI Interrupt Link [LNKA] (IRQs 1 3 4 5 6 7 10 12 14 15) *11
[    0.793038] ACPI: PCI Interrupt Link [LNKB] (IRQs 1 3 4 5 6 7 *11 12 14 15)
[    0.793677] ACPI: PCI Interrupt Link [LNKC] (IRQs 1 3 4 5 6 7 10 12 14 15) *11
[    0.794364] ACPI: PCI Interrupt Link [LNKD] (IRQs 1 3 4 5 6 7 *11 12 14 15)
[    0.794997] ACPI: PCI Interrupt Link [LNKE] (IRQs 1 3 4 5 6 7 10 12 14 15) *0, disabled.
[    0.795727] ACPI: PCI Interrupt Link [LNKF] (IRQs 1 3 4 5 6 7 11 12 14 15) *10
[    0.796421] ACPI: PCI Interrupt Link [LNKG] (IRQs 1 3 4 5 6 7 10 12 14 15) *11
[    0.797110] ACPI: PCI Interrupt Link [LNKH] (IRQs 1 3 4 5 6 7 *11 12 14 15)
[    0.798024] vgaarb: device added: PCI:0000:00:02.0,decodes=io+mem,owns=io+mem,locks=none
[    0.798134] vgaarb: loaded
[    0.798193] vgaarb: bridge control possible 0000:00:02.0
[    0.798416] PCI: Using ACPI for IRQ routing
[    0.803533] PCI: pci_cache_line_size set to 64 bytes
[    0.803716] reserve RAM buffer: 000000000008f000 - 000000000008ffff 
[    0.803719] reserve RAM buffer: 000000000009fc00 - 000000000009ffff 
[    0.803722] reserve RAM buffer: 000000008ad34000 - 000000008bffffff 
[    0.803726] reserve RAM buffer: 000000016fe00000 - 000000016fffffff 
[    0.804105] NetLabel: Initializing
[    0.804167] NetLabel:  domain hash size = 128
[    0.804230] NetLabel:  protocols = UNLABELED CIPSOv4
[    0.804340] NetLabel:  unlabeled traffic allowed by default
[    0.804428] hpet0: at MMIO 0xfed00000, IRQs 2, 8, 0, 0, 0, 0, 0, 0
[    0.804866] hpet0: 8 comparators, 64-bit 14.318180 MHz counter
[    0.806972] Switching to clocksource hpet
[    0.809602] Switched to NOHz mode on CPU #0
[    0.809670] Switched to NOHz mode on CPU #3
[    0.809743] Switched to NOHz mode on CPU #1
[    0.809752] Switched to NOHz mode on CPU #2
[    0.828246] pnp: PnP ACPI init
[    0.828348] ACPI: bus type pnp registered
[    0.828862] pnp 00:00: [bus 00-ff]
[    0.828866] pnp 00:00: [io  0x0000-0x0cf7 window]
[    0.828869] pnp 00:00: [io  0x0cf8-0x0cff]
[    0.828871] pnp 00:00: [io  0x0d00-0xffff window]
[    0.828873] pnp 00:00: [mem 0x000a0000-0x000bffff window]
[    0.828876] pnp 00:00: [mem 0x000c0000-0x000c3fff window]
[    0.828878] pnp 00:00: [mem 0x000c4000-0x000c7fff window]
[    0.828881] pnp 00:00: [mem 0x000c8000-0x000cbfff window]
[    0.828883] pnp 00:00: [mem 0x000cc000-0x000cffff window]
[    0.828885] pnp 00:00: [mem 0x000d0000-0x000d3fff window]
[    0.828888] pnp 00:00: [mem 0x000d4000-0x000d7fff window]
[    0.828890] pnp 00:00: [mem 0x000d8000-0x000dbfff window]
[    0.828892] pnp 00:00: [mem 0x000dc000-0x000dffff window]
[    0.828895] pnp 00:00: [mem 0x000e0000-0x000e3fff window]
[    0.828897] pnp 00:00: [mem 0x000e4000-0x000e7fff window]
[    0.828899] pnp 00:00: [mem 0x000e8000-0x000ebfff window]
[    0.828902] pnp 00:00: [mem 0x000ec000-0x000effff window]
[    0.828904] pnp 00:00: [mem 0x000f0000-0x000fffff window]
[    0.828907] pnp 00:00: [mem 0x8fa00000-0xfeafffff window]
[    0.828909] pnp 00:00: [mem 0xfed40000-0xfed44fff window]
[    0.829050] pnp 00:00: Plug and Play ACPI device, IDs PNP0a08 PNP0a03 (active)
[    0.829242] pnp 00:01: [io  0x0000-0x001f]
[    0.829244] pnp 00:01: [io  0x0081-0x0091]
[    0.829246] pnp 00:01: [io  0x0093-0x009f]
[    0.829249] pnp 00:01: [io  0x00c0-0x00df]
[    0.829251] pnp 00:01: [dma 4]
[    0.829324] pnp 00:01: Plug and Play ACPI device, IDs PNP0200 (active)
[    0.829338] pnp 00:02: [mem 0xff000000-0xffffffff]
[    0.829407] pnp 00:02: Plug and Play ACPI device, IDs INT0800 (active)
[    0.829516] pnp 00:03: [irq 0 disabled]
[    0.829530] pnp 00:03: [irq 8]
[    0.829532] pnp 00:03: [mem 0xfed00000-0xfed003ff]
[    0.829664] system 00:03: [mem 0xfed00000-0xfed003ff] has been reserved
[    0.829737] system 00:03: Plug and Play ACPI device, IDs PNP0103 PNP0c01 (active)
[    0.829757] pnp 00:04: [io  0x00f0]
[    0.829765] pnp 00:04: [irq 13]
[    0.829837] pnp 00:04: Plug and Play ACPI device, IDs PNP0c04 (active)
[    0.829853] pnp 00:05: [io  0x002e-0x002f]
[    0.829855] pnp 00:05: [io  0x004e-0x004f]
[    0.829857] pnp 00:05: [io  0x0061]
[    0.829859] pnp 00:05: [io  0x0063]
[    0.829861] pnp 00:05: [io  0x0065]
[    0.829863] pnp 00:05: [io  0x0067]
[    0.829865] pnp 00:05: [io  0x0080]
[    0.829866] pnp 00:05: [io  0x0092]
[    0.829868] pnp 00:05: [io  0x00b2-0x00b3]
[    0.829872] pnp 00:05: [io  0x1000-0x100f]
[    0.829874] pnp 00:05: [io  0x0400-0x047f]
[    0.829876] pnp 00:05: [io  0x0500-0x057f]
[    0.829989] system 00:05: [io  0x1000-0x100f] has been reserved
[    0.830059] system 00:05: [io  0x0400-0x047f] has been reserved
[    0.830127] system 00:05: [io  0x0500-0x057f] has been reserved
[    0.830198] system 00:05: Plug and Play ACPI device, IDs PNP0c02 (active)
[    0.830212] pnp 00:06: [io  0x0070-0x0077]
[    0.830285] pnp 00:06: Plug and Play ACPI device, IDs PNP0b00 (active)
[    0.830305] pnp 00:07: [io  0x0300-0x031f]
[    0.830313] pnp 00:07: [irq 6]
[    0.830390] pnp 00:07: Plug and Play ACPI device, IDs APP0001 (active)
[    0.830671] pnp 00:08: [mem 0xfed1c000-0xfed1ffff]
[    0.830673] pnp 00:08: [mem 0xfed10000-0xfed17fff]
[    0.830676] pnp 00:08: [mem 0xfed18000-0xfed18fff]
[    0.830678] pnp 00:08: [mem 0xfed19000-0xfed19fff]
[    0.830680] pnp 00:08: [mem 0xe0000000-0xefffffff]
[    0.830682] pnp 00:08: [mem 0xfed20000-0xfed3ffff]
[    0.830684] pnp 00:08: [mem 0xfed90000-0xfed93fff]
[    0.830686] pnp 00:08: [mem 0xfed45000-0xfed8ffff]
[    0.830689] pnp 00:08: [mem 0xff000000-0xffffffff]
[    0.830691] pnp 00:08: [mem 0xfee00000-0xfeefffff]
[    0.830693] pnp 00:08: [mem 0x00000000-0xffffffffffffffff disabled]
[    0.830819] system 00:08: [mem 0xfed1c000-0xfed1ffff] has been reserved
[    0.830891] system 00:08: [mem 0xfed10000-0xfed17fff] could not be reserved
[    0.830962] system 00:08: [mem 0xfed18000-0xfed18fff] has been reserved
[    0.831032] system 00:08: [mem 0xfed19000-0xfed19fff] has been reserved
[    0.831102] system 00:08: [mem 0xe0000000-0xefffffff] has been reserved
[    0.831172] system 00:08: [mem 0xfed20000-0xfed3ffff] has been reserved
[    0.831242] system 00:08: [mem 0xfed90000-0xfed93fff] has been reserved
[    0.831312] system 00:08: [mem 0xfed45000-0xfed8ffff] has been reserved
[    0.831383] system 00:08: [mem 0xff000000-0xffffffff] could not be reserved
[    0.831452] system 00:08: [mem 0xfee00000-0xfeefffff] could not be reserved
[    0.831525] system 00:08: Plug and Play ACPI device, IDs PNP0c02 (active)
[    0.838717] pnp 00:09: [mem 0x20000000-0x201fffff]
[    0.838720] pnp 00:09: [mem 0x40000000-0x401fffff]
[    0.838875] system 00:09: [mem 0x20000000-0x201fffff] has been reserved
[    0.838946] system 00:09: [mem 0x40000000-0x401fffff] has been reserved
[    0.839018] system 00:09: Plug and Play ACPI device, IDs PNP0c01 (active)
[    0.839032] pnp: PnP ACPI: found 10 devices
[    0.839096] ACPI: ACPI bus type pnp unregistered
[    0.848149] PCI: max bus depth: 3 pci_try_num: 4
[    0.848227] pci 0000:04:00.0: PCI bridge to [bus 05-05]
[    0.848298] pci 0000:04:00.0:   bridge window [mem 0xa0700000-0xa07fffff]
[    0.848377] pci 0000:04:03.0: PCI bridge to [bus 06-36]
[    0.848447] pci 0000:04:03.0:   bridge window [mem 0xa0800000-0xa08fffff]
[    0.848525] pci 0000:04:04.0: PCI bridge to [bus 37-67]
[    0.848595] pci 0000:04:04.0:   bridge window [mem 0xa0900000-0xa09fffff]
[    0.848673] pci 0000:03:00.0: PCI bridge to [bus 04-67]
[    0.848743] pci 0000:03:00.0:   bridge window [mem 0xa0700000-0xa09fffff]
[    0.848821] pci 0000:00:01.0: PCI bridge to [bus 03-97]
[    0.848888] pci 0000:00:01.0:   bridge window [io  0x3000-0x3fff]
[    0.848958] pci 0000:00:01.0:   bridge window [mem 0xa0700000-0xa49fffff]
[    0.849031] pci 0000:00:01.0:   bridge window [mem 0xa4a00000-0xa89fffff 64bit pref]
[    0.849119] pci 0000:00:1c.0: PCI bridge to [bus 01-01]
[    0.849193] pci 0000:00:1c.0:   bridge window [mem 0xa0500000-0xa05fffff]
[    0.849276] pci 0000:00:1c.1: PCI bridge to [bus 02-02]
[    0.849349] pci 0000:00:1c.1:   bridge window [mem 0xa0400000-0xa04fffff]
[    0.849447] pci 0000:00:01.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
[    0.849519] pci 0000:00:01.0: setting latency timer to 64
[    0.849527] pci 0000:03:00.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
[    0.849599] pci 0000:03:00.0: setting latency timer to 64
[    0.849608] pci 0000:04:00.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
[    0.849680] pci 0000:04:00.0: setting latency timer to 64
[    0.849688] pci 0000:04:03.0: enabling device (0000 -> 0002)
[    0.849761] pci 0000:04:03.0: PCI INT A -> GSI 19 (level, low) -> IRQ 19
[    0.850330] pci 0000:04:03.0: setting latency timer to 64
[    0.850338] pci 0000:04:04.0: enabling device (0000 -> 0002)
[    0.850419] pci 0000:04:04.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
[    0.850493] pci 0000:04:04.0: setting latency timer to 64
[    0.850502] pci 0000:00:1c.0: enabling device (0000 -> 0002)
[    0.850572] pci 0000:00:1c.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
[    0.850648] pci 0000:00:1c.0: setting latency timer to 64
[    0.850730] pci 0000:00:1c.1: power state changed by ACPI to D0
[    0.850802] pci 0000:00:1c.1: power state changed by ACPI to D0
[    0.850880] pci 0000:00:1c.1: PCI INT B -> GSI 17 (level, low) -> IRQ 17
[    0.850954] pci 0000:00:1c.1: setting latency timer to 64
[    0.850960] pci_bus 0000:00: resource 4 [io  0x0000-0x0cf7]
[    0.850963] pci_bus 0000:00: resource 5 [io  0x0d00-0xffff]
[    0.850965] pci_bus 0000:00: resource 6 [mem 0x000a0000-0x000bffff]
[    0.850968] pci_bus 0000:00: resource 7 [mem 0x8fa00000-0xfeafffff]
[    0.850970] pci_bus 0000:00: resource 8 [mem 0xfed40000-0xfed44fff]
[    0.850973] pci_bus 0000:03: resource 0 [io  0x3000-0x3fff]
[    0.850975] pci_bus 0000:03: resource 1 [mem 0xa0700000-0xa49fffff]
[    0.850978] pci_bus 0000:03: resource 2 [mem 0xa4a00000-0xa89fffff 64bit pref]
[    0.850981] pci_bus 0000:04: resource 1 [mem 0xa0700000-0xa09fffff]
[    0.850984] pci_bus 0000:05: resource 1 [mem 0xa0700000-0xa07fffff]
[    0.850986] pci_bus 0000:06: resource 1 [mem 0xa0800000-0xa08fffff]
[    0.850989] pci_bus 0000:37: resource 1 [mem 0xa0900000-0xa09fffff]
[    0.850992] pci_bus 0000:01: resource 1 [mem 0xa0500000-0xa05fffff]
[    0.850994] pci_bus 0000:02: resource 1 [mem 0xa0400000-0xa04fffff]
[    0.851105] NET: Registered protocol family 2
[    0.851483] IP route cache hash table entries: 131072 (order: 8, 1048576 bytes)
[    0.853180] TCP established hash table entries: 524288 (order: 11, 8388608 bytes)
[    0.855325] TCP bind hash table entries: 65536 (order: 10, 4194304 bytes)
[    0.860908] TCP: Hash tables configured (established 524288 bind 65536)
[    0.861002] TCP reno registered
[    0.861113] UDP hash table entries: 2048 (order: 6, 327680 bytes)
[    0.861570] UDP-Lite hash table entries: 2048 (order: 6, 327680 bytes)
[    0.862227] NET: Registered protocol family 1
[    0.862317] pci 0000:00:02.0: Boot video device
[    0.862732] PCI: CLS 256 bytes, default 64
[    0.862875] Unpacking initramfs...
[    0.936120] Freeing initrd memory: 2988k freed
[    0.936688] PCI-DMA: Using software bounce buffering for IO (SWIOTLB)
[    0.936759] Placing 64MB software IO TLB between ffff880086d2f000 - ffff88008ad2f000
[    0.936843] software IO TLB at phys 0x86d2f000 - 0x8ad2f000
[    0.937848] audit: initializing netlink socket (disabled)
[    0.937951] type=2000 audit(1323283955.783:1): initialized
[    0.944031] HugeTLB registered 2 MB page size, pre-allocated 0 pages
[    0.958256] VFS: Disk quotas dquot_6.5.2
[    0.958527] Dquot-cache hash table entries: 512 (order 0, 4096 bytes)
[    0.959059] msgmni has been set to 7713
[    0.959604] Block layer SCSI generic (bsg) driver version 0.4 loaded (major 253)
[    0.959758] io scheduler noop registered
[    0.959822] io scheduler deadline registered
[    0.959961] io scheduler cfq registered (default)
[    0.960315] pcieport 0000:00:01.0: setting latency timer to 64
[    0.960382] pcieport 0000:00:01.0: irq 40 for MSI/MSI-X
[    0.960674] pcieport 0000:03:00.0: setting latency timer to 64
[    0.960725] pcieport 0000:03:00.0: irq 41 for MSI/MSI-X
[    0.960850] pcieport 0000:04:00.0: setting latency timer to 64
[    0.960902] pcieport 0000:04:00.0: irq 42 for MSI/MSI-X
[    0.961027] pcieport 0000:04:03.0: setting latency timer to 64
[    0.961079] pcieport 0000:04:03.0: irq 43 for MSI/MSI-X
[    0.961207] pcieport 0000:04:04.0: setting latency timer to 64
[    0.961259] pcieport 0000:04:04.0: irq 44 for MSI/MSI-X
[    0.961810] intel_idle: MWAIT substates: 0x21120
[    0.961812] intel_idle: v0.4 model 0x2A
[    0.961813] intel_idle: lapic_timer_reliable_states 0xffffffff
[    0.961958] ERST: Table is not found!
[    0.962021] GHES: HEST is not enabled!
[    0.962191] Serial: 8250/16550 driver, 4 ports, IRQ sharing disabled
[    1.183707] Linux agpgart interface v0.103
[    1.184007] i8042: PNP: No PS/2 controller found. Probing ports directly.
[    1.184966] i8042: No controller found
[    1.185208] mousedev: PS/2 mouse device common for all mice
[    1.185445] rtc_cmos 00:06: RTC can wake from S4
[    1.185809] rtc_cmos 00:06: rtc core: registered rtc_cmos as rtc0
[    1.185921] rtc0: alarms up to one month, y3k, 242 bytes nvram, hpet irqs
[    1.186253] cpuidle: using governor ladder
[    1.186968] cpuidle: using governor menu
[    1.187665] TCP cubic registered
[    1.187729] NET: Registered protocol family 17
[    1.187802] Registering the dns_resolver key type
[    1.188201] PM: Hibernation image not present or could not be loaded.
[    1.188209] registered taskstats version 1
[    1.194441] rtc_cmos 00:06: setting system clock to 2011-12-07 18:52:36 UTC (1323283956)
[    1.194653] Initializing network drop monitor service
[    1.196898] Freeing unused kernel memory: 724k freed
[    1.197088] Write protecting the kernel read-only data: 8192k
[    1.204306] Freeing unused kernel memory: 1832k freed
[    1.205677] Freeing unused kernel memory: 232k freed
[    1.220090] udevd[45]: starting version 174
[    1.310589] usbcore: registered new interface driver usbfs
[    1.311656] usbcore: registered new interface driver hub
[    1.312201] usbcore: registered new device driver usb
[    1.312885] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
[    1.313174] ehci_hcd 0000:00:1a.7: PCI INT A -> GSI 23 (level, low) -> IRQ 23
[    1.313305] ehci_hcd 0000:00:1a.7: setting latency timer to 64
[    1.313313] ehci_hcd 0000:00:1a.7: EHCI Host Controller
[    1.313969] ehci_hcd 0000:00:1a.7: new USB bus registered, assigned bus number 1
[    1.314166] ehci_hcd 0000:00:1a.7: debug port 2
[    1.317490] SCSI subsystem initialized
[    1.318125] ehci_hcd 0000:00:1a.7: cache line size of 256 is not supported
[    1.318170] ehci_hcd 0000:00:1a.7: irq 23, io mem 0xa0606c00
[    1.319952] libata version 3.00 loaded.
[    1.329773] ehci_hcd 0000:00:1a.7: USB 2.0 started, EHCI 1.00
[    1.330750] hub 1-0:1.0: USB hub found
[    1.330874] hub 1-0:1.0: 6 ports detected
[    1.331483] ehci_hcd 0000:00:1d.7: PCI INT A -> GSI 22 (level, low) -> IRQ 22
[    1.331612] ehci_hcd 0000:00:1d.7: setting latency timer to 64
[    1.331620] ehci_hcd 0000:00:1d.7: EHCI Host Controller
[    1.331735] ehci_hcd 0000:00:1d.7: new USB bus registered, assigned bus number 2
[    1.331875] ehci_hcd 0000:00:1d.7: debug port 2
[    1.335825] ehci_hcd 0000:00:1d.7: cache line size of 256 is not supported
[    1.335857] ehci_hcd 0000:00:1d.7: irq 22, io mem 0xa0606800
[    1.349713] ehci_hcd 0000:00:1d.7: USB 2.0 started, EHCI 1.00
[    1.350135] hub 2-0:1.0: USB hub found
[    1.350208] hub 2-0:1.0: 8 ports detected
[    1.350520] ata_piix 0000:00:1f.2: version 2.13
[    1.350548] ata_piix 0000:00:1f.2: PCI INT B -> GSI 19 (level, low) -> IRQ 19
[    1.350636] ata_piix 0000:00:1f.2: MAP [ P0 P2 P1 P3 ]
[    1.412487] uhci_hcd: USB Universal Host Controller Interface driver
[    1.502871] ata_piix 0000:00:1f.2: setting latency timer to 64
[    1.504036] scsi0 : ata_piix
[    1.504484] scsi1 : ata_piix
[    1.504963] ata1: SATA max UDMA/133 cmd 0x2168 ctl 0x217c bmdma 0x2060 irq 19
[    1.505040] ata2: SATA max UDMA/133 cmd 0x2160 ctl 0x2178 bmdma 0x2068 irq 19
[    1.505187] uhci_hcd 0000:00:1a.0: PCI INT B -> GSI 21 (level, low) -> IRQ 21
[    1.505279] uhci_hcd 0000:00:1a.0: setting latency timer to 64
[    1.505287] uhci_hcd 0000:00:1a.0: UHCI Host Controller
[    1.505400] uhci_hcd 0000:00:1a.0: new USB bus registered, assigned bus number 3
[    1.505537] uhci_hcd 0000:00:1a.0: irq 21, io base 0x00002140
[    1.506181] hub 3-0:1.0: USB hub found
[    1.506270] hub 3-0:1.0: 2 ports detected
[    1.506526] uhci_hcd 0000:00:1d.0: PCI INT B -> GSI 19 (level, low) -> IRQ 19
[    1.506605] uhci_hcd 0000:00:1d.0: setting latency timer to 64
[    1.506610] uhci_hcd 0000:00:1d.0: UHCI Host Controller
[    1.506691] uhci_hcd 0000:00:1d.0: new USB bus registered, assigned bus number 4
[    1.506806] uhci_hcd 0000:00:1d.0: irq 19, io base 0x000020e0
[    1.507168] hub 4-0:1.0: USB hub found
[    1.507242] hub 4-0:1.0: 2 ports detected
[    1.639284] usb 1-1: new high speed USB device number 2 using ehci_hcd
[    1.763916] hub 1-1:1.0: USB hub found
[    1.764127] hub 1-1:1.0: 3 ports detected
[    1.868922] usb 1-2: new high speed USB device number 3 using ehci_hcd
[    1.938886] Refined TSC clocksource calibration: 1800.012 MHz.
[    1.938979] Switching to clocksource tsc
[    2.111868] usb 2-1: new high speed USB device number 2 using ehci_hcd
[    2.236286] hub 2-1:1.0: USB hub found
[    2.236501] hub 2-1:1.0: 2 ports detected
[    2.315072] usb 1-1.1: new full speed USB device number 4 using ehci_hcd
[    2.414290] hub 1-1.1:1.0: USB hub found
[    2.414562] hub 1-1.1:1.0: 3 ports detected
[    2.494779] usb 1-1.2: new full speed USB device number 5 using ehci_hcd
[    2.524579] ata2.00: failed to resume link (SControl 0)
[    2.616251] usbcore: registered new interface driver usbhid
[    2.616327] usbhid: USB HID core driver
[    2.681275] usb 2-1.1: new high speed USB device number 3 using ehci_hcd
[    2.786708] Initializing USB Mass Storage driver...
[    2.787047] scsi2 : usb-storage 2-1.1:1.0
[    2.787289] usbcore: registered new interface driver usb-storage
[    2.787371] USB Mass Storage support registered.
[    2.844048] ata1.01: failed to resume link (SControl 0)
[    2.860971] usb 1-1.1.1: new full speed USB device number 6 using ehci_hcd
[    2.949339] input: HID 05ac:820a as /devices/pci0000:00/0000:00:1a.7/usb1/1-1/1-1.1/1-1.1.1/1-1.1.1:1.0/input/input0
[    2.950161] generic-usb 0003:05AC:820A.0003: input,hidraw0: USB HID v1.11 Keyboard [HID 05ac:820a] on usb-0000:00:1a.7-1.1.1/input0
[    2.997205] ata1.00: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
[    2.997290] ata1.01: SATA link down (SStatus 0 SControl 0)
[    3.004199] ata1.00: ATA-8: APPLE SSD SM256C, AXM09A1Q, max UDMA/133
[    3.004273] ata1.00: 490234752 sectors, multi 16: LBA48 NCQ (depth 0/32)
[    3.010716] ata1.00: configured for UDMA/133
[    3.011488] scsi 0:0:0:0: Direct-Access     ATA      APPLE SSD SM256C AXM0 PQ: 0 ANSI: 5
[    3.017349] usb 1-1.1.2: new full speed USB device number 7 using ehci_hcd
[    3.105109] input: HID 05ac:820b as /devices/pci0000:00/0000:00:1a.7/usb1/1-1/1-1.1/1-1.1.2/1-1.1.2:1.0/input/input1
[    3.105824] generic-usb 0003:05AC:820B.0004: input,hidraw1: USB HID v1.11 Mouse [HID 05ac:820b] on usb-0000:00:1a.7-1.1.2/input0
[    3.183705] usb 1-1.1.3: new full speed USB device number 8 using ehci_hcd
[    3.546329] ata2.01: failed to resume link (SControl 0)
[    3.557997] ata2.00: SATA link down (SStatus 0 SControl 0)
[    3.558079] ata2.01: SATA link down (SStatus 0 SControl 0)
[    3.568240] sd 0:0:0:0: [sda] 490234752 512-byte logical blocks: (251 GB/233 GiB)
[    3.568589] sd 0:0:0:0: [sda] Write Protect is off
[    3.568628] input: Apple Inc. Apple Internal Keyboard / Trackpad as /devices/pci0000:00/0000:00:1a.7/usb1/1-1/1-1.2/1-1.2:1.0/input/input2
[    3.568747] sd 0:0:0:0: [sda] Mode Sense: 00 3a 00 00
[    3.568805] sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[    3.569040] apple 0003:05AC:024D.0001: input,hidraw2: USB HID v1.11 Keyboard [Apple Inc. Apple Internal Keyboard / Trackpad] on usb-0000:00:1a.7-1.2/input0
[    3.573493] apple 0003:05AC:024D.0002: hidraw3: USB HID v1.11 Device [Apple Inc. Apple Internal Keyboard / Trackpad] on usb-0000:00:1a.7-1.2/input1
[    3.575039]  sda: sda1 sda2 sda3 sda4 sda5
[    3.576348] sd 0:0:0:0: [sda] Attached SCSI disk
[    3.770461] device-mapper: uevent: version 1.0.3
[    3.771242] device-mapper: ioctl: 4.21.0-ioctl (2011-07-06) initialised: dm-devel@redhat.com
[    3.805053] scsi 2:0:0:0: Direct-Access     APPLE    SD Card Reader   2.00 PQ: 0 ANSI: 0
[    3.808150] sd 2:0:0:0: [sdb] Attached SCSI removable disk
[   10.829013] padlock_aes: VIA PadLock not detected.
[   17.877617] JFS: nTxBlock = 8192, nTxLock = 65536
[   18.341860] udevd[320]: starting version 175
[   18.429875] ACPI: acpi_idle yielding to intel_idle
[   18.435148] agpgart-intel 0000:00:00.0: Intel Sandybridge Chipset
[   18.435575] agpgart-intel 0000:00:00.0: detected gtt size: 2097152K total, 262144K mappable
[   18.437852] agpgart-intel 0000:00:00.0: detected 65536K stolen memory
[   18.438245] agpgart-intel 0000:00:00.0: AGP aperture is 256M @ 0x90000000
[   18.446278] input: Lid Switch as /devices/LNXSYSTM:00/device:00/PNP0C0D:00/input/input3
[   18.446753] ACPI: Lid Switch [LID0]
[   18.446971] input: Power Button as /devices/LNXSYSTM:00/device:00/PNP0C0C:00/input/input4
[   18.447629] ACPI: Power Button [PWRB]
[   18.453544] mei: module is from the staging directory, the quality is unknown, you have been warned.
[   18.456648] input: Sleep Button as /devices/LNXSYSTM:00/device:00/PNP0C0E:00/input/input5
[   18.456755] ACPI: Sleep Button [SLPB]
[   18.460900] mei 0000:00:16.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
[   18.460991] mei 0000:00:16.0: setting latency timer to 64
[   18.462754] ACPI: AC Adapter [ADP1] (off-line)
[   18.476464] input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/input/input6
[   18.476563] ACPI: Power Button [PWRF]
[   18.538886] iTCO_vendor_support: vendor-support=0
[   18.554127] input: PC Speaker as /devices/platform/pcspkr/input/input7
[   18.554402] i801_smbus 0000:00:1f.3: PCI INT C -> GSI 18 (level, low) -> IRQ 18
[   18.584855] ACPI: Battery Slot [BAT0] (battery present)
[   18.589556] iTCO_wdt: Intel TCO WatchDog Timer Driver v1.06
[   18.600442] iTCO_wdt: unable to reset NO_REBOOT flag, device disabled by hardware/BIOS
[   18.609594] cfg80211: Calling CRDA to update world regulatory domain
[   18.611779] brcmutil: module is from the staging directory, the quality is unknown, you have been warned.
[   18.615683] [drm] Initialized drm 1.1.0 20060810
[   18.647569] brcmsmac: module is from the staging directory, the quality is unknown, you have been warned.
[   18.648655] snd_hda_intel 0000:00:1b.0: PCI INT A -> GSI 22 (level, low) -> IRQ 22
[   18.648900] snd_hda_intel 0000:00:1b.0: irq 45 for MSI/MSI-X
[   18.648992] snd_hda_intel 0000:00:1b.0: setting latency timer to 64
[   18.651806] brcmsmac 0000:02:00.0: bus 2 slot 0 func 0 irq 11
[   18.651930] brcmsmac 0000:02:00.0: PCI INT A -> GSI 17 (level, low) -> IRQ 17
[   18.652014] brcmsmac 0000:02:00.0: setting latency timer to 64
[   18.673646] applesmc: key=349 fan=1 temp=25 acc=0 lux=2 kbd=1
[   18.690091] Registered led device: smc::kbd_backlight
[   18.745401] input: bcm5974 as /devices/pci0000:00/0000:00:1a.7/usb1/1-1/1-1.2/1-1.2:1.2/input/input8
[   18.752878] Linux media interface: v0.10
[   18.752957] usbcore: registered new interface driver bcm5974
[   18.761950] Linux video capture interface: v2.00
[   18.801509] uvcvideo: Found UVC 1.00 device FaceTime Camera (Built-in) (05ac:850a)
[   18.832756] input: FaceTime Camera (Built-in) as /devices/pci0000:00/0000:00:1a.7/usb1/1-2/1-2:1.0/input/input9
[   18.836134] usbcore: registered new interface driver uvcvideo
[   18.836284] USB Video Class driver (1.1.1)
[   18.853704] ieee80211 phy0: Selected rate control algorithm 'minstrel_ht'
[   19.207357] HDMI status: Codec=3 Pin=5 Presence_Detect=0 ELD_Valid=0
[   19.207772] HDMI status: Codec=3 Pin=6 Presence_Detect=0 ELD_Valid=0
[   19.208167] HDMI status: Codec=3 Pin=7 Presence_Detect=0 ELD_Valid=0
[   19.213016] input: HDA Intel PCH HDMI/DP as /devices/pci0000:00/0000:00:1b.0/sound/card0/input10
[   19.213258] input: HDA Intel PCH HDMI/DP as /devices/pci0000:00/0000:00:1b.0/sound/card0/input11
[   19.213488] input: HDA Intel PCH HDMI/DP as /devices/pci0000:00/0000:00:1b.0/sound/card0/input12
[   19.214213] i915 0000:00:02.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
[   19.214298] i915 0000:00:02.0: setting latency timer to 64
[   19.348569] i915 0000:00:02.0: irq 46 for MSI/MSI-X
[   19.348580] [drm] Supports vblank timestamp caching Rev 1 (10.10.2010).
[   19.348654] [drm] Driver supports precise vblank timestamp query.
[   19.348834] [drm:intel_dsm_platform_mux_info] *ERROR* MUX INFO call failed
[   19.349166] vgaarb: device changed decodes: PCI:0000:00:02.0,olddecodes=io+mem,decodes=io+mem:owns=io+mem
[   20.549597] fbcon: inteldrmfb (fb0) is primary device
[   21.539134] [drm:intel_dp_complete_link_train] *ERROR* failed to train DP, aborting
[   21.565344] Console: switching to colour frame buffer device 180x56
[   21.568908] fb0: inteldrmfb frame buffer device
[   21.568910] drm: registered panic notifier
[   21.600401] acpi device:0d: registered as cooling_device4
[   21.600920] input: Video Bus as /devices/LNXSYSTM:00/device:00/PNP0A08:00/LNXVIDEO:00/input/input13
[   21.601207] ACPI: Video Device [IGPU] (multi-head: yes  rom: no  post: no)
[   21.601394] [drm] Initialized i915 1.6.0 20080730 for 0000:00:02.0 on minor 0
[   23.095084] EXT4-fs (sda4): mounted filesystem with ordered data mode. Opts: (null)
[   23.980273] NET: Registered protocol family 10
[   41.326466] ieee80211 phy0: brcms_ops_config: change monitor mode: false (implement)
[   41.326471] ieee80211 phy0: brcms_ops_config: change power-save mode: false (implement)
[   41.332881] ieee80211 phy0: brcms_ops_bss_info_changed: qos enabled: false (implement)
[   41.333617] ADDRCONF(NETDEV_UP): wlan0: link is not ready
[   43.479975] wlan0: authenticate with 00:18:39:50:07:f3 (try 1)
[   43.481733] wlan0: authenticated
[   43.481968] wlan0: associate with 00:18:39:50:07:f3 (try 1)
[   43.484579] wlan0: RX AssocResp from 00:18:39:50:07:f3 (capab=0x421 status=0 aid=2)
[   43.484583] wlan0: associated
[   43.485664] ieee80211 phy0: brcms_ops_bss_info_changed: qos enabled: false (implement)
[   43.485672] ieee80211 phy0: brcmsmac: brcms_ops_bss_info_changed: associated
[   43.485697] ieee80211 phy0: brcms_ops_bss_info_changed: arp filtering: enabled true, count 0 (implement)
[   43.486139] ADDRCONF(NETDEV_CHANGE): wlan0: link becomes ready
[   52.833049] ieee80211 phy0: brcms_ops_bss_info_changed: arp filtering: enabled true, count 1 (implement)
[   54.060834] wlan0: no IPv6 routers present
[  156.662187] ieee80211 phy0: brcms_ops_bss_info_changed: qos enabled: false (implement)
[  156.662284] ieee80211 phy0: brcmsmac: brcms_ops_bss_info_changed: disassociated
[  156.662296] ieee80211 phy0: brcms_ops_bss_info_changed: arp filtering: enabled false, count 1 (implement)
[  156.662431] wlan0: deauthenticating from 00:18:39:50:07:f3 by local choice (reason=3)
[  156.738525] cfg80211: Calling CRDA for country: X3
[  158.739984] wlan0: direct probe to c8:6c:87:a9:df:a9 (try 1/3)
[  158.937442] wlan0: direct probe to c8:6c:87:a9:df:a9 (try 2/3)
[  159.137132] wlan0: direct probe to c8:6c:87:a9:df:a9 (try 3/3)
[  159.336825] wlan0: direct probe to c8:6c:87:a9:df:a9 timed out


--------------------------------------------------------------------------------
<2>CTRL-EVENT-BSS-ADDED 6 c8:6c:87:a9:df:a9
> <2>CTRL-EVENT-BSS-ADDED 7 00:24:93:27:1f:b0
> <2>CTRL-EVENT-SCAN-RESULTS 
> <2>WPS-AP-AVAILABLE 
> <2>Trying to associate with c8:6c:87:a9:df:a9 (SSID='weisserose' freq=2472 MHz)
> 'PING' command timed out.
Connection to wpa_supplicant lost - trying to reconnect
Warning: Failed to attach to wpa_supplicant.

> 
> 
> 'PING' command timed out.
Connection to wpa_supplicant lost - trying to reconnect
Warning: Failed to attach to wpa_supplicant.
'PING' command timed out.
Connection to wpa_supplicant lost - trying to reconnect
Warning: Failed to attach to wpa_supplicant.
'PING' command timed out.
Connection to wpa_supplicant lost - trying to reconnect
Warning: Failed to attach to wpa_supplicant.
'PING' command timed out.
Connection to wpa_supplicant lost - trying to reconnect
Warning: Failed to attach to wpa_supplicant.



-- 
PGP key: 7ED9 F7D3 6B10 81D7 0EC5  5C09 D7DC C8E4 3187 7DF0
