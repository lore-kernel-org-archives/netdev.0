From: Sander Eikelenboom <linux@eikelenboom.it>
Subject: Re: [cfg80211 / iwlwifi] setting wireless regulatory domain doesn't work.
Date: Wed, 11 Dec 2013 17:53:50 +0100
Message-ID: <1818324675.20131211175350@eikelenboom.it>
References: <1507831110.20131018194349@eikelenboom.it> <792757788.20131023142849@eikelenboom.it> <1819533168.20131211161710@eikelenboom.it> <CAB=NE6V-RSnqbAC-0tfYK=WGJLp1aPC2UpFDurs49h+wXr9UfQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "Berg, Johannes" <johannes.berg@intel.com>,
	"Grumbach, Emmanuel" <emmanuel.grumbach@intel.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"ilw@linux.intel.com" <ilw@linux.intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"John W. Linville" <linville@tuxdriver.com>
To: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAB=NE6V-RSnqbAC-0tfYK=WGJLp1aPC2UpFDurs49h+wXr9UfQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Wednesday, December 11, 2013, 4:38:13 PM, you wrote:

> On Wed, Dec 11, 2013 at 4:17 PM, Sander Eikelenboom
> <linux@eikelenboom.it> wrote:
>> Since i haven't got a response to this yet and after having the troubled machine back:
>> The problem is still present in linux 3.13-rc3

> Keep in mind regulatory hints for Intel or Atheros cards do nothing
> other than help compliance further given that the cards already have
> their own regulatory data, the user input / hint is only going to
> reduce the card's channels further.

So in essence what you are saying is that the firmware/eeprom already dictates the limited channels available based on .. errr .. yeah based on what ...
And setting the regulatory domain yourself only limits this list of limited channels available only further ?

I now spotted this from the dmesg:
[    4.818467] cfg80211: Ignoring regulatory request set by core since the driver uses its own custom regulatory domain

Joy o joy who ever came up with that great idea ..
Would be nice it that error came up again when you would try to set the domain, instead of silently ignoring it.

So now the only thing left is to try to find out if some one has hacked these bloody cards, what a mess.

Do other cards like broadcom or whatever have the same issue ?

>  That said the fact that you are
> not seeing a regulatory domain being set is an issue provided you have
> CRDA installed or use CONFIG_CFG80211_INTERNAL_REGDB. Keep in mind
> that the latest version of wireless-regdb had a signature issue
> reported by users and not sure if that is cleared yet, so that would
> also prevent the wireless-regdb being read even if CRDA was present.
> To rule that out try putting the db.txt into net/wireless/db.txt and
> compile with CONFIG_CFG80211_INTERNAL_REGDB for now.

I did have CRDA installed (debian).
And also compiled the db.txt in.

> Then send the dmesg output, no need for all that fluffy intel debug
> log as its not useful in this case.

Compiled with db.txt in:

~# iw reg set US
~# iw reg get
country 00:
        (2402 - 2472 @ 40), (6, 20)
        (2457 - 2482 @ 40), (6, 20), PASSIVE-SCAN, NO-IBSS
        (2474 - 2494 @ 20), (6, 20), NO-OFDM, PASSIVE-SCAN, NO-IBSS
        (5170 - 5250 @ 160), (6, 20), PASSIVE-SCAN, NO-IBSS
        (5250 - 5330 @ 160), (6, 20), DFS, PASSIVE-SCAN, NO-IBSS
        (5490 - 5730 @ 160), (6, 20), DFS, PASSIVE-SCAN, NO-IBSS

[    0.000000] Initializing cgroup subsys cpuset
[    0.000000] Initializing cgroup subsys cpu
[    0.000000] Initializing cgroup subsys cpuacct
[    0.000000] Linux version 3.13.0-rc3-20131211b+ (root@creabox) (gcc version 4.7.2 (Debian 4.7.2-5) ) #1 SMP Wed Dec 11 19:30:50 CET 2013
[    0.000000] Command line: placeholder root=/dev/mapper/creabox-creabox_dom0 ro vga=794 nomodeset quiet
[    0.000000] Freeing 9d-100 pfn range: 99 pages freed
[    0.000000] 1-1 mapping on 9d->100
[    0.000000] Freeing 20000-20200 pfn range: 512 pages freed
[    0.000000] 1-1 mapping on 20000->20200
[    0.000000] Freeing 40004-40005 pfn range: 1 pages freed
[    0.000000] 1-1 mapping on 40004->40005
[    0.000000] 1-1 mapping on db9f1->dc20d
[    0.000000] 1-1 mapping on dc20e->dc251
[    0.000000] 1-1 mapping on dd000->100000
[    0.000000] Released 612 pages of unused memory
[    0.000000] Set 146115 page(s) to 1-1 mapping
[    0.000000] Populating 60000-60264 pfn range: 612 pages added
[    0.000000] e820: BIOS-provided physical RAM map:
[    0.000000] Xen: [mem 0x0000000000000000-0x000000000009cfff] usable
[    0.000000] Xen: [mem 0x000000000009d800-0x00000000000fffff] reserved
[    0.000000] Xen: [mem 0x0000000000100000-0x000000001fffffff] usable
[    0.000000] Xen: [mem 0x0000000020000000-0x00000000201fffff] reserved
[    0.000000] Xen: [mem 0x0000000020200000-0x0000000040003fff] usable
[    0.000000] Xen: [mem 0x0000000040004000-0x0000000040004fff] reserved
[    0.000000] Xen: [mem 0x0000000040005000-0x0000000060263fff] usable
[    0.000000] Xen: [mem 0x0000000060264000-0x00000000db9f0fff] unusable
[    0.000000] Xen: [mem 0x00000000db9f1000-0x00000000dbe6ffff] reserved
[    0.000000] Xen: [mem 0x00000000dbe70000-0x00000000dbe7ffff] ACPI data
[    0.000000] Xen: [mem 0x00000000dbe80000-0x00000000dbf9dfff] ACPI NVS
[    0.000000] Xen: [mem 0x00000000dbf9e000-0x00000000dc20cfff] reserved
[    0.000000] Xen: [mem 0x00000000dc20d000-0x00000000dc20dfff] unusable
[    0.000000] Xen: [mem 0x00000000dc20e000-0x00000000dc250fff] ACPI NVS
[    0.000000] Xen: [mem 0x00000000dc251000-0x00000000dcffffff] unusable
[    0.000000] Xen: [mem 0x00000000dd000000-0x00000000df9fffff] reserved
[    0.000000] Xen: [mem 0x00000000f8000000-0x00000000fbffffff] reserved
[    0.000000] Xen: [mem 0x00000000fec00000-0x00000000fec00fff] reserved
[    0.000000] Xen: [mem 0x00000000fed00000-0x00000000fed03fff] reserved
[    0.000000] Xen: [mem 0x00000000fed1c000-0x00000000fed1ffff] reserved
[    0.000000] Xen: [mem 0x00000000fee00000-0x00000000fee00fff] reserved
[    0.000000] Xen: [mem 0x00000000ff000000-0x00000000ffffffff] reserved
[    0.000000] Xen: [mem 0x0000000100000000-0x000000021e5fffff] unusable
[    0.000000] NX (Execute Disable) protection: active
[    0.000000] SMBIOS 2.7 present.
[    0.000000] DMI:                  /D53427RKE, BIOS RKPPT10H.86A.0017.2013.0425.1251 04/25/2013
[    0.000000] e820: update [mem 0x00000000-0x00000fff] usable ==> reserved
[    0.000000] e820: remove [mem 0x000a0000-0x000fffff] usable
[    0.000000] No AGP bridge found
[    0.000000] e820: last_pfn = 0x60264 max_arch_pfn = 0x400000000
[    0.000000] Base memory trampoline at [ffff880000097000] 97000 size 24576
[    0.000000] init_memory_mapping: [mem 0x00000000-0x000fffff]
[    0.000000]  [mem 0x00000000-0x000fffff] page 4k
[    0.000000] init_memory_mapping: [mem 0x60000000-0x601fffff]
[    0.000000]  [mem 0x60000000-0x601fffff] page 4k
[    0.000000] BRK [0x02133000, 0x02133fff] PGTABLE
[    0.000000] BRK [0x02134000, 0x02134fff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0x5c000000-0x5fffffff]
[    0.000000]  [mem 0x5c000000-0x5fffffff] page 4k
[    0.000000] BRK [0x02135000, 0x02135fff] PGTABLE
[    0.000000] BRK [0x02136000, 0x02136fff] PGTABLE
[    0.000000] BRK [0x02137000, 0x02137fff] PGTABLE
[    0.000000] BRK [0x02138000, 0x02138fff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0x00100000-0x1fffffff]
[    0.000000]  [mem 0x00100000-0x1fffffff] page 4k
[    0.000000] init_memory_mapping: [mem 0x20200000-0x40003fff]
[    0.000000]  [mem 0x20200000-0x40003fff] page 4k
[    0.000000] init_memory_mapping: [mem 0x40005000-0x5bffffff]
[    0.000000]  [mem 0x40005000-0x5bffffff] page 4k
[    0.000000] init_memory_mapping: [mem 0x60200000-0x60263fff]
[    0.000000]  [mem 0x60200000-0x60263fff] page 4k
[    0.000000] RAMDISK: [mem 0x02541000-0x03792fff]
[    0.000000] ACPI: RSDP 00000000000f0490 000024 (v02  Intel)
[    0.000000] ACPI: XSDT 00000000dbe74080 00007C (v01  Intel D53427RK 00000011 AMI  00010013)
[    0.000000] ACPI: FACP 00000000dbe7e100 00010C (v05  Intel D53427RK 00000011 AMI  00010013)
[    0.000000] ACPI: DSDT 00000000dbe74188 009F72 (v02  Intel D53427RK 00000011 INTL 20051117)
[    0.000000] ACPI: FACS 00000000dbf9c080 000040
[    0.000000] ACPI: APIC 00000000dbe7e210 000072 (v03  Intel D53427RK 00000011 AMI  00010013)
[    0.000000] ACPI: FPDT 00000000dbe7e288 000044 (v01  Intel D53427RK 00000011 AMI  00010013)
[    0.000000] ACPI: TCPA 00000000dbe7e2d0 000032 (v02 APTIO4  NAPAASF 00000011 MSFT 01000013)
[    0.000000] ACPI: MCFG 00000000dbe7e308 00003C (v01  Intel D53427RK 00000011 MSFT 00000097)
[    0.000000] ACPI: HPET 00000000dbe7e348 000038 (v01  Intel D53427RK 00000011 AMI. 00000005)
[    0.000000] ACPI: SSDT 00000000dbe7e380 000315 (v01 SataRe SataTabl 00000011 INTL 20091112)
[    0.000000] ACPI: SSDT 00000000dbe7e698 0009AA (v01  PmRef  Cpu0Ist 00000011 INTL 20051117)
[    0.000000] ACPI: SSDT 00000000dbe7f048 000B22 (v01  PmRef    CpuPm 00000011 INTL 20051117)
[    0.000000] ACPI: XMAR 00000000dbe7fb70 0000B8 (v01 INTEL      SNB  00000011 INTL 00000001)
[    0.000000] ACPI: ASF! 00000000dbe7fc28 0000A5 (v32 INTEL       HCG 00000011 TFSM 000F4240)
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] NUMA turned off
[    0.000000] Faking a node at [mem 0x0000000000000000-0x0000000060263fff]
[    0.000000] Initmem setup node 0 [mem 0x00000000-0x60263fff]
[    0.000000]   NODE_DATA [mem 0x60260000-0x60263fff]
[    0.000000] Zone ranges:
[    0.000000]   DMA      [mem 0x00001000-0x00ffffff]
[    0.000000]   DMA32    [mem 0x01000000-0xffffffff]
[    0.000000]   Normal   empty
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x00001000-0x0009cfff]
[    0.000000]   node   0: [mem 0x00100000-0x1fffffff]
[    0.000000]   node   0: [mem 0x20200000-0x40003fff]
[    0.000000]   node   0: [mem 0x40005000-0x60263fff]
[    0.000000] On node 0 totalpages: 393215
[    0.000000]   DMA zone: 56 pages used for memmap
[    0.000000]   DMA zone: 21 pages reserved
[    0.000000]   DMA zone: 3996 pages, LIFO batch:0
[    0.000000]   DMA32 zone: 5329 pages used for memmap
[    0.000000]   DMA32 zone: 389219 pages, LIFO batch:31
[    0.000000] ACPI: PM-Timer IO Port: 0x408
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] ACPI: LAPIC (acpi_id[0x01] lapic_id[0x00] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x02] lapic_id[0x02] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x03] lapic_id[0x01] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x04] lapic_id[0x03] enabled)
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0xff] high edge lint[0x1])
[    0.000000] ACPI: IOAPIC (id[0x02] address[0xfec00000] gsi_base[0])
[    0.000000] IOAPIC[0]: apic_id 2, version 32, address 0xfec00000, GSI 0-23
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
[    0.000000] ACPI: IRQ0 used by override.
[    0.000000] ACPI: IRQ2 used by override.
[    0.000000] ACPI: IRQ9 used by override.
[    0.000000] Using ACPI (MADT) for SMP configuration information
[    0.000000] ACPI: HPET id: 0x8086a701 base: 0xfed00000
[    0.000000] smpboot: Allowing 4 CPUs, 0 hotplug CPUs
[    0.000000] nr_irqs_gsi: 40
[    0.000000] e820: [mem 0xdfa00000-0xf7ffffff] available for PCI devices
[    0.000000] Booting paravirtualized kernel on Xen
[    0.000000] Xen version: 4.3.0 (preserve-AD)
[    0.000000] setup_percpu: NR_CPUS:16 nr_cpumask_bits:16 nr_cpu_ids:4 nr_node_ids:1
[    0.000000] PERCPU: Embedded 28 pages/cpu @ffff88005fa00000 s84800 r8192 d21696 u524288
[    0.000000] pcpu-alloc: s84800 r8192 d21696 u524288 alloc=1*2097152
[    0.000000] pcpu-alloc: [0] 0 1 2 3 
[    3.455877] Built 1 zonelists in Node order, mobility grouping on.  Total pages: 387809
[    3.455879] Policy zone: DMA32
[    3.455881] Kernel command line: placeholder root=/dev/mapper/creabox-creabox_dom0 ro vga=794 nomodeset quiet
[    3.456148] PID hash table entries: 4096 (order: 3, 32768 bytes)
[    3.456200] xsave: enabled xstate_bv 0x7, cntxt size 0x340
[    3.485246] software IO TLB [mem 0x59c00000-0x5dc00000] (64MB) mapped at [ffff880059c00000-ffff88005dbfffff]
[    3.490516] Memory: 1440360K/1572860K available (9180K kernel code, 1152K rwdata, 3720K rodata, 1148K init, 868K bss, 132500K reserved)
[    3.490597] Hierarchical RCU implementation.
[    3.490598]  RCU dyntick-idle grace-period acceleration is enabled.
[    3.490600]  RCU restricting CPUs from NR_CPUS=16 to nr_cpu_ids=4.
[    3.490607] NR_IRQS:4352 nr_irqs:712 16
[    3.490690] xen: sci override: global_irq=9 trigger=0 polarity=0
[    3.490692] xen: registering gsi 9 triggering 0 polarity 0
[    3.490705] xen: --> pirq=9 -> irq=9 (gsi=9)
[    3.490731] xen: acpi sci 9
[    3.490735] xen: --> pirq=1 -> irq=1 (gsi=1)
[    3.490739] xen: --> pirq=2 -> irq=2 (gsi=2)
[    3.490742] xen: --> pirq=3 -> irq=3 (gsi=3)
[    3.490745] xen: --> pirq=4 -> irq=4 (gsi=4)
[    3.490749] xen: --> pirq=5 -> irq=5 (gsi=5)
[    3.490752] xen: --> pirq=6 -> irq=6 (gsi=6)
[    3.490756] xen: --> pirq=7 -> irq=7 (gsi=7)
[    3.490759] xen: --> pirq=8 -> irq=8 (gsi=8)
[    3.490763] xen: --> pirq=10 -> irq=10 (gsi=10)
[    3.490766] xen: --> pirq=11 -> irq=11 (gsi=11)
[    3.490770] xen: --> pirq=12 -> irq=12 (gsi=12)
[    3.490773] xen: --> pirq=13 -> irq=13 (gsi=13)
[    3.490776] xen: --> pirq=14 -> irq=14 (gsi=14)
[    3.490780] xen: --> pirq=15 -> irq=15 (gsi=15)
[    3.490868] Console: colour dummy device 80x25
[    3.490973] console [tty0] enabled
[    3.491005] Xen: using vcpuop timer interface
[    3.491010] installing Xen timer for CPU 0
[    3.491035] tsc: Detected 2294.840 MHz processor
[    3.491040] Calibrating delay loop (skipped), value calculated using timer frequency.. 4589.68 BogoMIPS (lpj=9179360)
[    3.491043] pid_max: default: 32768 minimum: 301
[    3.491073] Security Framework initialized
[    3.491505] Dentry cache hash table entries: 262144 (order: 9, 2097152 bytes)
[    3.492350] Inode-cache hash table entries: 131072 (order: 8, 1048576 bytes)
[    3.492678] Mount-cache hash table entries: 256
[    3.492891] Initializing cgroup subsys devices
[    3.492894] Initializing cgroup subsys freezer
[    3.492896] Initializing cgroup subsys net_cls
[    3.492898] Initializing cgroup subsys blkio
[    3.492900] Initializing cgroup subsys perf_event
[    3.492973] ENERGY_PERF_BIAS: Set to 'normal', was 'performance'
[    3.492973] ENERGY_PERF_BIAS: View and update with x86_energy_perf_policy(8)
[    3.492978] CPU: Physical Processor ID: 0
[    3.492980] CPU: Processor Core ID: 0
[    3.493501] mce: CPU supports 2 MCE banks
[    3.493522] Last level iTLB entries: 4KB 512, 2MB 0, 4MB 0
[    3.493522] Last level dTLB entries: 4KB 512, 2MB 32, 4MB 32
[    3.493522] tlb_flushall_shift: 1
[    3.493675] Freeing SMP alternatives memory: 20K (ffffffff82040000 - ffffffff82045000)
[    3.494393] ACPI: Core revision 20131115
[    3.501663] ACPI: All ACPI Tables successfully acquired
[    3.503034] Performance Events: unsupported p6 CPU model 58 no PMU driver, software events only.
[    3.503318] NMI watchdog: disabled (cpu0): hardware events not enabled
[    3.503426] installing Xen timer for CPU 1
[    3.504376] installing Xen timer for CPU 2
[    3.505272] installing Xen timer for CPU 3
[    3.506059] x86: Booted up 1 node, 4 CPUs
[    3.506492] devtmpfs: initialized
[    3.507507] xor: automatically using best checksumming function:
[    3.547815]    avx       : 12277.000 MB/sec
[    3.547837] xen:grant_table: Grant tables using version 2 layout
[    3.547854] Grant table initialized
[    3.547975] NET: Registered protocol family 16
[    3.548581] ACPI: bus type PCI registered
[    3.548584] acpiphp: ACPI Hot Plug PCI Controller Driver version: 0.5
[    3.548792] dca service started, version 1.12.1
[    3.548831] PCI: MMCONFIG for domain 0000 [bus 00-3f] at [mem 0xf8000000-0xfbffffff] (base 0xf8000000)
[    3.548834] PCI: MMCONFIG at [mem 0xf8000000-0xfbffffff] reserved in E820
[    3.559456] PCI: Using configuration type 1 for base access
[    3.562760] bio: create slab <bio-0> at 0
[    3.628910] raid6: sse2x1    4631 MB/s
[    3.697825] raid6: sse2x2    5833 MB/s
[    3.766734] raid6: sse2x4    6582 MB/s
[    3.766736] raid6: using algorithm sse2x4 (6582 MB/s)
[    3.766738] raid6: using ssse3x2 recovery algorithm
[    3.766799] ACPI: Added _OSI(Module Device)
[    3.766802] ACPI: Added _OSI(Processor Device)
[    3.766805] ACPI: Added _OSI(3.0 _SCP Extensions)
[    3.766807] ACPI: Added _OSI(Processor Aggregator Device)
[    3.770647] ACPI: Executed 1 blocks of module-level executable AML code
[    3.783867] ACPI: SSDT 00000000dbe1d018 00083B (v01  PmRef  Cpu0Cst 00003001 INTL 20051117)
[    3.784350] ACPI: Dynamic OEM Table Load:
[    3.784354] ACPI: SSDT           (null) 00083B (v01  PmRef  Cpu0Cst 00003001 INTL 20051117)
[    3.795839] ACPI: SSDT 00000000dbe1ea98 000303 (v01  PmRef    ApIst 00003000 INTL 20051117)
[    3.796365] ACPI: Dynamic OEM Table Load:
[    3.796369] ACPI: SSDT           (null) 000303 (v01  PmRef    ApIst 00003000 INTL 20051117)
[    3.807973] ACPI: SSDT 00000000dbe1fc18 000119 (v01  PmRef    ApCst 00003000 INTL 20051117)
[    3.808452] ACPI: Dynamic OEM Table Load:
[    3.808455] ACPI: SSDT           (null) 000119 (v01  PmRef    ApCst 00003000 INTL 20051117)
[    3.821033] ACPI: Interpreter enabled
[    3.821047] ACPI: (supports S0 S5)
[    3.821050] ACPI: Using IOAPIC for interrupt routing
[    3.821113] PCI: Using host bridge windows from ACPI; if necessary, use "pci=nocrs" and report a bug
[    3.821325] ACPI: No dock devices found.
[    3.831643] ACPI: Power Resource [FN00] (off)
[    3.831758] ACPI: Power Resource [FN01] (off)
[    3.831871] ACPI: Power Resource [FN02] (off)
[    3.831981] ACPI: Power Resource [FN03] (off)
[    3.832090] ACPI: Power Resource [FN04] (off)
[    3.832983] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-3e])
[    3.832991] acpi PNP0A08:00: _OSC: OS supports [ExtendedConfig ASPM ClockPM Segments MSI]
[    3.834077] acpi PNP0A08:00: _OSC: OS now controls [PCIeHotplug PME AER PCIeCapability]
[    3.834837] ACPI: \_SB_.PCI0.TPMX: can't evaluate _ADR (0x5)
[    3.835133] ACPI: \_SB_.PCI0.PDRC: can't evaluate _ADR (0x5)
[    3.835136] ACPI: \_SB_.PCI0.ITPM: can't evaluate _ADR (0x5)
[    3.835139] ACPI: \_SB_.PCI0.DOCK: can't evaluate _ADR (0x5)
[    3.835141] PCI host bridge to bus 0000:00
[    3.835144] pci_bus 0000:00: root bus resource [bus 00-3e]
[    3.835147] pci_bus 0000:00: root bus resource [io  0x0000-0x0cf7]
[    3.835150] pci_bus 0000:00: root bus resource [io  0x0d00-0xffff]
[    3.835153] pci_bus 0000:00: root bus resource [mem 0x000a0000-0x000bffff]
[    3.835155] pci_bus 0000:00: root bus resource [mem 0x000d0000-0x000d3fff]
[    3.835158] pci_bus 0000:00: root bus resource [mem 0x000d4000-0x000d7fff]
[    3.835160] pci_bus 0000:00: root bus resource [mem 0x000d8000-0x000dbfff]
[    3.835163] pci_bus 0000:00: root bus resource [mem 0x000dc000-0x000dffff]
[    3.835165] pci_bus 0000:00: root bus resource [mem 0x000e0000-0x000e3fff]
[    3.835168] pci_bus 0000:00: root bus resource [mem 0x000e4000-0x000e7fff]
[    3.835171] pci_bus 0000:00: root bus resource [mem 0xdfa00000-0xfeafffff]
[    3.835191] pci 0000:00:00.0: [8086:0154] type 00 class 0x060000
[    3.835444] pci 0000:00:02.0: [8086:0166] type 00 class 0x030000
[    3.835485] pci 0000:00:02.0: reg 0x10: [mem 0xf7800000-0xf7bfffff 64bit]
[    3.835508] pci 0000:00:02.0: reg 0x18: [mem 0xe0000000-0xefffffff 64bit pref]
[    3.835523] pci 0000:00:02.0: reg 0x20: [io  0xf000-0xf03f]
[    3.835813] pci 0000:00:14.0: [8086:1e31] type 00 class 0x0c0330
[    3.835876] pci 0000:00:14.0: reg 0x10: [mem 0xf7d20000-0xf7d2ffff 64bit]
[    3.836089] pci 0000:00:14.0: PME# supported from D3hot D3cold
[    3.836178] pci 0000:00:14.0: System wakeup disabled by ACPI
[    3.836263] pci 0000:00:16.0: [8086:1e3a] type 00 class 0x078000
[    3.836327] pci 0000:00:16.0: reg 0x10: [mem 0xf7d3c000-0xf7d3c00f 64bit]
[    3.836552] pci 0000:00:16.0: PME# supported from D0 D3hot D3cold
[    3.836720] pci 0000:00:16.3: [8086:1e3d] type 00 class 0x070002
[    3.836772] pci 0000:00:16.3: reg 0x10: [io  0xf0e0-0xf0e7]
[    3.836798] pci 0000:00:16.3: reg 0x14: [mem 0xf7d3a000-0xf7d3afff]
[    3.837174] pci 0000:00:19.0: [8086:1502] type 00 class 0x020000
[    3.837229] pci 0000:00:19.0: reg 0x10: [mem 0xf7d00000-0xf7d1ffff]
[    3.837252] pci 0000:00:19.0: reg 0x14: [mem 0xf7d39000-0xf7d39fff]
[    3.837276] pci 0000:00:19.0: reg 0x18: [io  0xf080-0xf09f]
[    3.837474] pci 0000:00:19.0: PME# supported from D0 D3hot D3cold
[    3.837567] pci 0000:00:19.0: System wakeup disabled by ACPI
[    3.837650] pci 0000:00:1a.0: [8086:1e2d] type 00 class 0x0c0320
[    3.837705] pci 0000:00:1a.0: reg 0x10: [mem 0xf7d38000-0xf7d383ff]
[    3.837953] pci 0000:00:1a.0: PME# supported from D0 D3hot D3cold
[    3.838067] pci 0000:00:1a.0: System wakeup disabled by ACPI
[    3.838147] pci 0000:00:1b.0: [8086:1e20] type 00 class 0x040300
[    3.838193] pci 0000:00:1b.0: reg 0x10: [mem 0xf7d30000-0xf7d33fff 64bit]
[    3.838415] pci 0000:00:1b.0: PME# supported from D0 D3hot D3cold
[    3.838511] pci 0000:00:1b.0: System wakeup disabled by ACPI
[    3.838589] pci 0000:00:1c.0: [8086:1e10] type 01 class 0x060400
[    3.838831] pci 0000:00:1c.0: PME# supported from D0 D3hot D3cold
[    3.838933] pci 0000:00:1c.0: System wakeup disabled by ACPI
[    3.839012] pci 0000:00:1c.2: [8086:1e14] type 01 class 0x060400
[    3.839250] pci 0000:00:1c.2: PME# supported from D0 D3hot D3cold
[    3.839353] pci 0000:00:1c.2: System wakeup disabled by ACPI
[    3.839470] pci 0000:00:1d.0: [8086:1e26] type 00 class 0x0c0320
[    3.839528] pci 0000:00:1d.0: reg 0x10: [mem 0xf7d37000-0xf7d373ff]
[    3.839781] pci 0000:00:1d.0: PME# supported from D0 D3hot D3cold
[    3.839901] pci 0000:00:1d.0: System wakeup disabled by ACPI
[    3.839975] pci 0000:00:1f.0: [8086:1e56] type 00 class 0x060100
[    3.840380] pci 0000:00:1f.2: [8086:1e03] type 00 class 0x010601
[    3.840457] pci 0000:00:1f.2: reg 0x10: [io  0xf0d0-0xf0d7]
[    3.840483] pci 0000:00:1f.2: reg 0x14: [io  0xf0c0-0xf0c3]
[    3.840506] pci 0000:00:1f.2: reg 0x18: [io  0xf0b0-0xf0b7]
[    3.840530] pci 0000:00:1f.2: reg 0x1c: [io  0xf0a0-0xf0a3]
[    3.840554] pci 0000:00:1f.2: reg 0x20: [io  0xf060-0xf07f]
[    3.840578] pci 0000:00:1f.2: reg 0x24: [mem 0xf7d36000-0xf7d367ff]
[    3.840737] pci 0000:00:1f.2: PME# supported from D3hot
[    3.840890] pci 0000:00:1f.3: [8086:1e22] type 00 class 0x0c0500
[    3.840939] pci 0000:00:1f.3: reg 0x10: [mem 0xf7d35000-0xf7d350ff 64bit]
[    3.841005] pci 0000:00:1f.3: reg 0x20: [io  0xf040-0xf05f]
[    3.841341] pci 0000:00:1c.0: PCI bridge to [bus 01]
[    3.841855] pci 0000:02:00.0: [8086:088e] type 00 class 0x028000
[    3.842214] pci 0000:02:00.0: reg 0x10: [mem 0xf7c00000-0xf7c01fff 64bit]
[    3.844029] pci 0000:02:00.0: PME# supported from D0 D3hot D3cold
[    3.844333] pci 0000:02:00.0: System wakeup disabled by ACPI
[    3.852928] pci 0000:00:1c.2: PCI bridge to [bus 02]
[    3.852952] pci 0000:00:1c.2:   bridge window [mem 0xf7c00000-0xf7cfffff]
[    3.853762] ACPI: PCI Interrupt Link [LNKA] (IRQs 3 4 5 6 10 *11 12 14 15)
[    3.853856] ACPI: PCI Interrupt Link [LNKB] (IRQs 3 4 5 6 10 11 12 14 15) *0, disabled.
[    3.853944] ACPI: PCI Interrupt Link [LNKC] (IRQs 3 *4 5 6 10 11 12 14 15)
[    3.854032] ACPI: PCI Interrupt Link [LNKD] (IRQs 3 4 5 6 *10 11 12 14 15)
[    3.854119] ACPI: PCI Interrupt Link [LNKE] (IRQs 3 4 *5 6 10 11 12 14 15)
[    3.854207] ACPI: PCI Interrupt Link [LNKF] (IRQs 3 4 5 6 10 11 12 14 15) *0, disabled.
[    3.854295] ACPI: PCI Interrupt Link [LNKG] (IRQs *3 4 5 6 10 11 12 14 15)
[    3.854381] ACPI: PCI Interrupt Link [LNKH] (IRQs 3 4 5 6 10 *11 12 14 15)
[    3.854738] ACPI: Enabled 6 GPEs in block 00 to 3F
[    3.854749] ACPI: \_SB_.PCI0: notify handler is installed
[    3.854814] Found 1 acpi root devices
[    3.854878] xen:balloon: Initialising balloon driver
[    3.855020] xen_balloon: Initialising balloon driver
[    3.855150] vgaarb: device added: PCI:0000:00:02.0,decodes=io+mem,owns=io+mem,locks=none
[    3.855156] vgaarb: loaded
[    3.855157] vgaarb: bridge control possible 0000:00:02.0
[    3.855370] SCSI subsystem initialized
[    3.855435] libata version 3.00 loaded.
[    3.855463] ACPI: bus type USB registered
[    3.855491] usbcore: registered new interface driver usbfs
[    3.855503] usbcore: registered new interface driver hub
[    3.855560] usbcore: registered new device driver usb
[    3.855588] pps_core: LinuxPPS API ver. 1 registered
[    3.855590] pps_core: Software ver. 5.3.6 - Copyright 2005-2007 Rodolfo Giometti <giometti@linux.it>
[    3.855597] PTP clock support registered
[    3.855638] wmi: Mapper loaded
[    3.855661] Advanced Linux Sound Architecture Driver Initialized.
[    3.855663] PCI: Using ACPI for IRQ routing
[    3.861714] PCI: pci_cache_line_size set to 64 bytes
[    3.861873] e820: reserve RAM buffer [mem 0x0009d000-0x0009ffff]
[    3.861877] e820: reserve RAM buffer [mem 0x40004000-0x43ffffff]
[    3.861879] e820: reserve RAM buffer [mem 0x60264000-0x63ffffff]
[    3.862108] cfg80211: Calling CRDA to update world regulatory domain
[    3.862596] Switched to clocksource xen
[    3.868179] FS-Cache: Loaded
[    3.868304] CacheFiles: Loaded
[    3.868328] pnp: PnP ACPI init
[    3.868341] ACPI: bus type PNP registered
[    3.868411] pnp 00:00: [dma 4]
[    3.868439] pnp 00:00: Plug and Play ACPI device, IDs PNP0200 (active)
[    3.868468] pnp 00:01: Plug and Play ACPI device, IDs INT0800 (active)
[    3.868605] pnp 00:02: Plug and Play ACPI device, IDs PNP0103 (active)
[    3.868666] system 00:03: [io  0x0680-0x069f] has been reserved
[    3.868671] system 00:03: [io  0x1000-0x100f] has been reserved
[    3.868674] system 00:03: [io  0xffff] has been reserved
[    3.868677] system 00:03: [io  0xffff] has been reserved
[    3.868680] system 00:03: [io  0x0400-0x0453] could not be reserved
[    3.868683] system 00:03: [io  0x0458-0x047f] has been reserved
[    3.868686] system 00:03: [io  0x0500-0x057f] has been reserved
[    3.868688] system 00:03: [io  0x164e-0x164f] has been reserved
[    3.868692] system 00:03: Plug and Play ACPI device, IDs PNP0c02 (active)
[    3.868704] xen: registering gsi 8 triggering 1 polarity 0
[    3.868755] pnp 00:04: Plug and Play ACPI device, IDs PNP0b00 (active)
[    3.868818] system 00:05: [io  0x0454-0x0457] has been reserved
[    3.868821] system 00:05: Plug and Play ACPI device, IDs INT3f0d PNP0c02 (active)
[    3.868994] system 00:06: [io  0x0a00-0x0a1f] has been reserved
[    3.868997] system 00:06: [io  0x0a30-0x0a3f] has been reserved
[    3.869000] system 00:06: [io  0x0a20-0x0a2f] has been reserved
[    3.869003] system 00:06: Plug and Play ACPI device, IDs PNP0c02 (active)
[    3.869096] system 00:07: [io  0x04d0-0x04d1] has been reserved
[    3.869100] system 00:07: Plug and Play ACPI device, IDs PNP0c02 (active)
[    3.869110] xen: registering gsi 13 triggering 1 polarity 0
[    3.869160] pnp 00:08: Plug and Play ACPI device, IDs PNP0c04 (active)
[    3.869218] pnp 00:09: Plug and Play ACPI device, IDs PNP0c31 (active)
[    3.869549] system 00:0a: [mem 0xfed1c000-0xfed1ffff] has been reserved
[    3.869552] system 00:0a: [mem 0xfed10000-0xfed17fff] has been reserved
[    3.869555] system 00:0a: [mem 0xfed18000-0xfed18fff] has been reserved
[    3.869558] system 00:0a: [mem 0xfed19000-0xfed19fff] has been reserved
[    3.869561] system 00:0a: [mem 0xf8000000-0xfbffffff] has been reserved
[    3.869564] system 00:0a: [mem 0xfed20000-0xfed3ffff] has been reserved
[    3.869567] system 00:0a: [mem 0xfed90000-0xfed93fff] has been reserved
[    3.869570] system 00:0a: [mem 0xfed45000-0xfed8ffff] has been reserved
[    3.869573] system 00:0a: [mem 0xff000000-0xffffffff] has been reserved
[    3.869576] system 00:0a: [mem 0xfee00000-0xfeefffff] could not be reserved
[    3.869579] system 00:0a: [mem 0xdfa00000-0xdfa00fff] has been reserved
[    3.869582] system 00:0a: Plug and Play ACPI device, IDs PNP0c02 (active)
[    3.869860] system 00:0b: [mem 0x20000000-0x201fffff] has been reserved
[    3.869863] system 00:0b: [mem 0x40004000-0x40004fff] has been reserved
[    3.869866] system 00:0b: Plug and Play ACPI device, IDs PNP0c01 (active)
[    3.869892] pnp: PnP ACPI: found 12 devices
[    3.869893] ACPI: bus type PNP unregistered
[    3.880399] PM-Timer failed consistency check  (0xffffff) - aborting.
[    3.880455] pci 0000:00:1c.0: PCI bridge to [bus 01]
[    3.880491] pci 0000:00:1c.2: PCI bridge to [bus 02]
[    3.880504] pci 0000:00:1c.2:   bridge window [mem 0xf7c00000-0xf7cfffff]
[    3.880528] pci_bus 0000:00: resource 4 [io  0x0000-0x0cf7]
[    3.880530] pci_bus 0000:00: resource 5 [io  0x0d00-0xffff]
[    3.880533] pci_bus 0000:00: resource 6 [mem 0x000a0000-0x000bffff]
[    3.880536] pci_bus 0000:00: resource 7 [mem 0x000d0000-0x000d3fff]
[    3.880538] pci_bus 0000:00: resource 8 [mem 0x000d4000-0x000d7fff]
[    3.880540] pci_bus 0000:00: resource 9 [mem 0x000d8000-0x000dbfff]
[    3.880543] pci_bus 0000:00: resource 10 [mem 0x000dc000-0x000dffff]
[    3.880545] pci_bus 0000:00: resource 11 [mem 0x000e0000-0x000e3fff]
[    3.880548] pci_bus 0000:00: resource 12 [mem 0x000e4000-0x000e7fff]
[    3.880550] pci_bus 0000:00: resource 13 [mem 0xdfa00000-0xfeafffff]
[    3.880553] pci_bus 0000:02: resource 1 [mem 0xf7c00000-0xf7cfffff]
[    3.880677] NET: Registered protocol family 2
[    3.880981] TCP established hash table entries: 16384 (order: 5, 131072 bytes)
[    3.881065] TCP bind hash table entries: 16384 (order: 6, 262144 bytes)
[    3.881110] TCP: Hash tables configured (established 16384 bind 16384)
[    3.881132] TCP: reno registered
[    3.881143] UDP hash table entries: 1024 (order: 3, 32768 bytes)
[    3.881159] UDP-Lite hash table entries: 1024 (order: 3, 32768 bytes)
[    3.881248] NET: Registered protocol family 1
[    3.881270] pci 0000:00:02.0: Boot video device
[    3.881395] xen: registering gsi 16 triggering 0 polarity 1
[    3.881410] xen: --> pirq=16 -> irq=16 (gsi=16)
[    3.881755] xen: registering gsi 16 triggering 0 polarity 1
[    3.881758] Already setup the GSI :16
[    3.898924] xen: registering gsi 23 triggering 0 polarity 1
[    3.898934] xen: --> pirq=23 -> irq=23 (gsi=23)
[    3.918993] PCI: CLS 64 bytes, default 64
[    3.919072] Trying to unpack rootfs image as initramfs...
[    3.942014] Freeing initrd memory: 18760K (ffff880002541000 - ffff880003793000)
[    3.943150] microcode: CPU0 sig=0x306a9, pf=0x10, revision=0x17
[    3.943199] microcode: CPU1 sig=0x306a9, pf=0x10, revision=0x17
[    3.943221] microcode: CPU2 sig=0x306a9, pf=0x10, revision=0x17
[    3.943238] microcode: CPU3 sig=0x306a9, pf=0x10, revision=0x17
[    3.943307] microcode: Microcode Update Driver: v2.00 <tigran@aivazian.fsnet.co.uk>, Peter Oruba
[    3.953861] alg: No test for __gcm-aes-aesni (__driver-gcm-aes-aesni)
[    3.958651] sha1_ssse3: Using AVX optimized SHA-1 implementation
[    3.959037] audit: initializing netlink socket (disabled)
[    3.959053] type=2000 audit(1386787513.951:1): initialized
[    4.003787] bounce pool size: 64 pages
[    4.003794] HugeTLB registered 2 MB page size, pre-allocated 0 pages
[    4.004264] VFS: Disk quotas dquot_6.5.2
[    4.004301] Dquot-cache hash table entries: 512 (order 0, 4096 bytes)
[    4.004851] FS-Cache: Netfs 'cifs' registered for caching
[    4.004926] Key type cifs.spnego registered
[    4.004936] Key type cifs.idmap registered
[    4.004940] NTFS driver 2.1.30 [Flags: R/W].
[    4.005082] fuse init (API version 7.22)
[    4.005294] bio: create slab <bio-1> at 1
[    4.005544] Btrfs loaded
[    4.005557] msgmni has been set to 2849
[    4.011893] alg: No test for stdrng (krng)
[    4.018059] alg: No test for fips(ansi_cprng) (fips_ansi_cprng)
[    4.018164] NET: Registered protocol family 38
[    4.018198] Block layer SCSI generic (bsg) driver version 0.4 loaded (major 249)
[    4.018201] io scheduler noop registered
[    4.018203] io scheduler deadline registered
[    4.018234] io scheduler cfq registered (default)
[    4.018465] xen: registering gsi 16 triggering 0 polarity 1
[    4.018470] Already setup the GSI :16
[    4.018845] xen: registering gsi 18 triggering 0 polarity 1
[    4.018858] xen: --> pirq=18 -> irq=18 (gsi=18)
[    4.019173] pcieport 0000:00:1c.0: Signaling PME through PCIe PME interrupt
[    4.019186] pcie_pme 0000:00:1c.0:pcie01: service driver pcie_pme loaded
[    4.019229] pcieport 0000:00:1c.2: Signaling PME through PCIe PME interrupt
[    4.019231] pci 0000:02:00.0: Signaling PME through PCIe PME interrupt
[    4.019243] pcie_pme 0000:00:1c.2:pcie01: service driver pcie_pme loaded
[    4.019260] pci_hotplug: PCI Hot Plug PCI Core version: 0.5
[    4.019277] pciehp: PCI Express Hot Plug Controller Driver version: 0.4
[    4.019279] cpcihp_zt5550: ZT5550 CompactPCI Hot Plug Driver version: 0.2
[    4.019294] cpcihp_generic: Generic port I/O CompactPCI Hot Plug Driver version: 0.1
[    4.019296] cpcihp_generic: not configured, disabling.
[    4.019312] shpchp: Standard Hot Plug PCI Controller Driver version: 0.4
[    4.021097] acpiphp_ibm: ibm_acpiphp_init: acpi_walk_namespace failed
[    4.021148] vmlfb: initializing
[    4.021332] uvesafb: failed to execute /sbin/v86d
[    4.021336] uvesafb: make sure that the v86d helper is installed and executable
[    4.021340] uvesafb: Getting VBE info block failed (eax=0x4f00, err=-2)
[    4.021343] uvesafb: vbe_init() failed with -22
[    4.021349] uvesafb: probe of uvesafb.0 failed with error -22
[    4.021363] vesafb: mode is 1280x1024x32, linelength=5120, pages=0
[    4.021365] vesafb: scrolling: redraw
[    4.021367] vesafb: Truecolor: size=8:8:8:8, shift=24:16:8:0
[    4.023186] vesafb: framebuffer at 0xe0000000, mapped to 0xffffc90004480000, using 10240k, total 32704k
[    4.142774] Console: switching to colour frame buffer device 160x64
[    4.262244] fb0: VESA VGA frame buffer device
[    4.262360] vga16fb: initializing
[    4.262365] vga16fb: mapped to 0xffff8800000a0000
[    4.262370] checking generic (e0000000 1ff0000) vs hw (a0000 10000)
[    4.262453] fb1: VGA16 VGA frame buffer device
[    4.262461] intel_idle: MWAIT substates: 0x21120
[    4.262463] intel_idle: v0.4 model 0x3A
[    4.262464] intel_idle: lapic_timer_reliable_states 0xffffffff
[    4.262537] intel_idle: intel_idle yielding to none
[    4.262548] ipmi message handler version 39.2
[    4.262554] ipmi device interface
[    4.262569] IPMI System Interface driver.
[    4.262597] ipmi_si: Adding default-specified kcs state machine
[    4.262601] ipmi_si: Trying default-specified kcs state machine at i/o address 0xca2, slave address 0x0, irq 0
[    4.262610] ipmi_si: Interface detection failed
[    4.294780] ipmi_si: Adding default-specified smic state machine
[    4.294790] ipmi_si: Trying default-specified smic state machine at i/o address 0xca9, slave address 0x0, irq 0
[    4.294806] ipmi_si: Interface detection failed
[    4.342773] ipmi_si: Adding default-specified bt state machine
[    4.342781] ipmi_si: Trying default-specified bt state machine at i/o address 0xe4, slave address 0x0, irq 0
[    4.342797] ipmi_si: Interface detection failed
[    4.390804] ipmi_si: Unable to find any System Interface(s)
[    4.390812] IPMI Watchdog: driver initialized
[    4.390813] Copyright (C) 2004 MontaVista Software - IPMI Powerdown via sys_reboot.
[    4.391795] input: Power Button as /devices/LNXSYSTM:00/device:00/PNP0C0C:00/input/input0
[    4.391804] ACPI: Power Button [PWRB]
[    4.391861] input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/input/input1
[    4.391866] ACPI: Power Button [PWRF]
[    4.391986] ACPI: Fan [FAN0] (off)
[    4.392031] ACPI: Fan [FAN1] (off)
[    4.392074] ACPI: Fan [FAN2] (off)
[    4.392115] ACPI: Fan [FAN3] (off)
[    4.392154] ACPI: Fan [FAN4] (off)
[    4.439122] Monitor-Mwait will be used to enter C-1 state
[    4.439134] Monitor-Mwait will be used to enter C-2 state
[    4.440269] Warning: Processor Platform Limit not supported.
[    4.487195] thermal LNXTHERM:00: registered as thermal_zone0
[    4.487199] ACPI: Thermal Zone [TZ00] (28 C)
[    4.487491] thermal LNXTHERM:01: registered as thermal_zone1
[    4.487493] ACPI: Thermal Zone [TZ01] (30 C)
[    4.487574] Error: Driver 'processor_aggregator' is already registered, aborting...
[    4.488608] GHES: HEST is not enabled!
[    4.488610] ioatdma: Intel(R) QuickData Technology Driver 4.00
[    4.488942] xen:xen_evtchn: Event-channel device installed
[    4.489146] xen_pciback: backend is vpci
[    4.489771] xen_acpi_processor: Uploading Xen processor PM info
[    4.491569] Serial: 8250/16550 driver, 4 ports, IRQ sharing enabled
[    4.492239] xen: registering gsi 19 triggering 0 polarity 1
[    4.492254] xen: --> pirq=19 -> irq=19 (gsi=19)
[    4.513108] 0000:00:16.3: ttyS0 at I/O 0xf0e0 (irq = 19, base_baud = 115200) is a 16550A
[    4.513299] hpet_acpi_add: no address or irqs in _CRS
[    4.513353] Non-volatile memory driver v1.3
[    4.513420] Linux agpgart interface v0.103
[    4.513460] Hangcheck: starting hangcheck timer 0.9.1 (tick is 180 seconds, margin is 60 seconds).
[    4.513461] Hangcheck: Using getrawmonotonic().
[    4.513557] tpm_tis 00:09: 1.2 TPM (device-id 0x0, rev-id 78)
[    4.571021] [drm] Initialized drm 1.1.0 20060810
[    4.571078] drm/i810 does not support SMP
[    4.572597] xen: registering gsi 16 triggering 0 polarity 1
[    4.572608] Already setup the GSI :16
[    4.572618] [drm:drm_pci_agp_init] *ERROR* Cannot initialize the agpgart module.
[    4.579164] brd: module loaded
[    4.580489] loop: module loaded
[    4.580701] nbd: registered device at major 43
[    4.584499] drbd: initialized. Version: 8.4.3 (api:1/proto:86-101)
[    4.584502] drbd: built-in
[    4.584504] drbd: registered as block device major 147
[    4.584617] xen: registering gsi 16 triggering 0 polarity 1
[    4.584620] Already setup the GSI :16
[    4.588781] ACPI Warning: 0x0000000000000428-0x000000000000042f SystemIO conflicts with Region \PMIO 1 (20131115/utaddress-251)
[    4.588785] ACPI: If an ACPI driver is available for this device, you should use it instead of the native driver
[    4.588792] ACPI Warning: 0x0000000000000530-0x000000000000053f SystemIO conflicts with Region \GPIO 1 (20131115/utaddress-251)
[    4.588795] ACPI: If an ACPI driver is available for this device, you should use it instead of the native driver
[    4.588796] ACPI Warning: 0x0000000000000500-0x000000000000052f SystemIO conflicts with Region \GPIO 1 (20131115/utaddress-251)
[    4.588798] ACPI: If an ACPI driver is available for this device, you should use it instead of the native driver
[    4.588799] lpc_ich: Resource conflict(s) found affecting gpio_ich
[    4.588825] Loading iSCSI transport class v2.0-870.
[    4.588945] hv_vmbus: registering driver hv_storvsc
[    4.589015] ahci 0000:00:1f.2: version 3.0
[    4.589085] xen: registering gsi 19 triggering 0 polarity 1
[    4.589087] Already setup the GSI :19
[    4.589192] ahci 0000:00:1f.2: AHCI 0001.0300 32 slots 6 ports 6 Gbps 0x1 impl SATA mode
[    4.589196] ahci 0000:00:1f.2: flags: 64bit ncq pm led clo pio slum part ems apst 
[    4.589627] scsi0 : ahci
[    4.589756] scsi1 : ahci
[    4.589826] scsi2 : ahci
[    4.589944] scsi3 : ahci
[    4.590024] scsi4 : ahci
[    4.590093] scsi5 : ahci
[    4.590136] ata1: SATA max UDMA/133 abar m2048@0xf7d36000 port 0xf7d36100 irq 70
[    4.590138] ata2: DUMMY
[    4.590139] ata3: DUMMY
[    4.590140] ata4: DUMMY
[    4.590141] ata5: DUMMY
[    4.590141] ata6: DUMMY
[    4.590256] bonding: Ethernet Channel Bonding Driver: v3.7.1 (April 27, 2011)
[    4.590696] eql: Equalizer2002: Simon Janes (simon@ncm.com) and David S. Miller (davem@redhat.com)
[    4.591102] libphy: Fixed MDIO Bus: probed
[    4.591176] tun: Universal TUN/TAP device driver, 1.6
[    4.591177] tun: (C) 1999-2004 Max Krasnyansky <maxk@qualcomm.com>
[    4.591277] e100: Intel(R) PRO/100 Network Driver, 3.5.24-k2-NAPI
[    4.591278] e100: Copyright(c) 1999-2006 Intel Corporation
[    4.591296] e1000: Intel(R) PRO/1000 Network Driver - version 7.3.21-k8-NAPI
[    4.591297] e1000: Copyright (c) 1999-2006 Intel Corporation.
[    4.591309] e1000e: Intel(R) PRO/1000 Network Driver - 2.3.2-k
[    4.591310] e1000e: Copyright(c) 1999 - 2013 Intel Corporation.
[    4.591404] xen: registering gsi 20 triggering 0 polarity 1
[    4.591417] xen: --> pirq=20 -> irq=20 (gsi=20)
[    4.591541] e1000e 0000:00:19.0: Interrupt Throttling Rate (ints/sec) set to dynamic conservative mode
[    4.799346] e1000e 0000:00:19.0 eth0: registered PHC clock
[    4.799350] e1000e 0000:00:19.0 eth0: (PCI Express:2.5GT/s:Width x1) ec:a8:6b:fa:7b:3c
[    4.799351] e1000e 0000:00:19.0 eth0: Intel(R) PRO/1000 Network Connection
[    4.799403] e1000e 0000:00:19.0 eth0: MAC: 10, PHY: 11, PBA No: FFFFFF-0FF
[    4.799418] igb: Intel(R) Gigabit Ethernet Network Driver - version 5.0.5-k
[    4.799419] igb: Copyright (c) 2007-2013 Intel Corporation.
[    4.799431] igbvf: Intel(R) Gigabit Virtual Function Network Driver - version 2.0.2-k
[    4.799432] igbvf: Copyright (c) 2009 - 2012 Intel Corporation.
[    4.799441] ixgbe: Intel(R) 10 Gigabit PCI Express Network Driver - version 3.15.1-k
[    4.799442] ixgbe: Copyright (c) 1999-2013 Intel Corporation.
[    4.799457] ixgbevf: Intel(R) 10 Gigabit PCI Express Virtual Function Network Driver - version 2.11.3-k
[    4.799458] ixgbevf: Copyright (c) 2009 - 2012 Intel Corporation.
[    4.799467] ixgb: Intel(R) PRO/10GbE Network Driver - version 1.0.135-k2-NAPI
[    4.799468] ixgb: Copyright (c) 1999-2008 Intel Corporation.
[    4.799501] ipw2100: Intel(R) PRO/Wireless 2100 Network Driver, git-1.2.2
[    4.799502] ipw2100: Copyright(c) 2003-2006 Intel Corporation
[    4.799513] ipw2200: Intel(R) PRO/Wireless 2200/2915 Network Driver, 1.2.2kq
[    4.799514] ipw2200: Copyright(c) 2003-2006 Intel Corporation
[    4.799527] libipw: 802.11 data/management/control stack, git-1.1.13
[    4.799528] libipw: Copyright (C) 2004-2005 Intel Corporation <jketreno@linux.intel.com>
[    4.799529] Intel(R) Wireless WiFi driver for Linux, in-tree:
[    4.799530] Copyright(c) 2003-2013 Intel Corporation
[    4.799644] xen: registering gsi 18 triggering 0 polarity 1
[    4.799647] Already setup the GSI :18
[    4.800479] iwlwifi 0000:02:00.0: loaded firmware version 18.168.6.1 op_mode iwldvm
[    4.800532] iwlwifi 0000:02:00.0: CONFIG_IWLWIFI_DEBUG disabled
[    4.800534] iwlwifi 0000:02:00.0: CONFIG_IWLWIFI_DEBUGFS disabled
[    4.800536] iwlwifi 0000:02:00.0: CONFIG_IWLWIFI_DEVICE_TRACING disabled
[    4.800539] iwlwifi 0000:02:00.0: Detected Intel(R) Centrino(R) Advanced-N 6235 AGN, REV=0xB0
[    4.800794] iwlwifi 0000:02:00.0: L1 Disabled; Enabling L0S
[    4.818467] cfg80211: Ignoring regulatory request set by core since the driver uses its own custom regulatory domain
[    4.818566] ieee80211 phy0: Selected rate control algorithm 'iwl-agn-rs'
[    4.818709] iwl4965: Intel(R) Wireless WiFi 4965 driver for Linux, in-tree:
[    4.818710] iwl4965: Copyright(c) 2003-2011 Intel Corporation
[    4.818727] iwl3945: Intel(R) PRO/Wireless 3945ABG/BG Network Connection driver for Linux, in-tree:s
[    4.818728] iwl3945: Copyright(c) 2003-2011 Intel Corporation
[    4.818737] xen_netfront: Initialising Xen virtual ethernet driver
[    4.818805] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
[    4.818806] ehci-pci: EHCI PCI platform driver
[    4.818905] xen: registering gsi 16 triggering 0 polarity 1
[    4.818908] Already setup the GSI :16
[    4.818939] ehci-pci 0000:00:1a.0: EHCI Host Controller
[    4.819035] ehci-pci 0000:00:1a.0: new USB bus registered, assigned bus number 1
[    4.819058] ehci-pci 0000:00:1a.0: debug port 2
[    4.822983] ehci-pci 0000:00:1a.0: cache line size of 64 is not supported
[    4.823030] ehci-pci 0000:00:1a.0: irq 16, io mem 0xf7d38000
[    4.834795] ehci-pci 0000:00:1a.0: USB 2.0 started, EHCI 1.00
[    4.834867] usb usb1: New USB device found, idVendor=1d6b, idProduct=0002
[    4.834870] usb usb1: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    4.834872] usb usb1: Product: EHCI Host Controller
[    4.834873] usb usb1: Manufacturer: Linux 3.13.0-rc3-20131211b+ ehci_hcd
[    4.834875] usb usb1: SerialNumber: 0000:00:1a.0
[    4.835158] hub 1-0:1.0: USB hub found
[    4.835168] hub 1-0:1.0: 3 ports detected
[    4.835421] xen: registering gsi 23 triggering 0 polarity 1
[    4.835426] Already setup the GSI :23
[    4.835465] ehci-pci 0000:00:1d.0: EHCI Host Controller
[    4.835635] ehci-pci 0000:00:1d.0: new USB bus registered, assigned bus number 2
[    4.835659] ehci-pci 0000:00:1d.0: debug port 2
[    4.839615] ehci-pci 0000:00:1d.0: cache line size of 64 is not supported
[    4.839662] ehci-pci 0000:00:1d.0: irq 23, io mem 0xf7d37000
[    4.850709] ehci-pci 0000:00:1d.0: USB 2.0 started, EHCI 1.00
[    4.850811] usb usb2: New USB device found, idVendor=1d6b, idProduct=0002
[    4.850816] usb usb2: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    4.850820] usb usb2: Product: EHCI Host Controller
[    4.850824] usb usb2: Manufacturer: Linux 3.13.0-rc3-20131211b+ ehci_hcd
[    4.850828] usb usb2: SerialNumber: 0000:00:1d.0
[    4.851134] hub 2-0:1.0: USB hub found
[    4.851150] hub 2-0:1.0: 3 ports detected
[    4.851453] ohci_hcd: USB 1.1 'Open' Host Controller (OHCI) Driver
[    4.851456] ohci-pci: OHCI PCI platform driver
[    4.851483] ohci-platform: OHCI generic platform driver
[    4.851503] uhci_hcd: USB Universal Host Controller Interface driver
[    4.851806] xen: registering gsi 16 triggering 0 polarity 1
[    4.851812] Already setup the GSI :16
[    4.851942] xhci_hcd 0000:00:14.0: xHCI Host Controller
[    4.852117] xhci_hcd 0000:00:14.0: new USB bus registered, assigned bus number 3
[    4.852270] xhci_hcd 0000:00:14.0: cache line size of 64 is not supported
[    4.852524] usb usb3: New USB device found, idVendor=1d6b, idProduct=0002
[    4.852529] usb usb3: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    4.852533] usb usb3: Product: xHCI Host Controller
[    4.852537] usb usb3: Manufacturer: Linux 3.13.0-rc3-20131211b+ xhci_hcd
[    4.852540] usb usb3: SerialNumber: 0000:00:14.0
[    4.852833] hub 3-0:1.0: USB hub found
[    4.852854] hub 3-0:1.0: 4 ports detected
[    4.853612] xhci_hcd 0000:00:14.0: xHCI Host Controller
[    4.853742] xhci_hcd 0000:00:14.0: new USB bus registered, assigned bus number 4
[    4.853837] usb usb4: New USB device found, idVendor=1d6b, idProduct=0003
[    4.853842] usb usb4: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    4.853845] usb usb4: Product: xHCI Host Controller
[    4.853849] usb usb4: Manufacturer: Linux 3.13.0-rc3-20131211b+ xhci_hcd
[    4.853853] usb usb4: SerialNumber: 0000:00:14.0
[    4.854135] hub 4-0:1.0: USB hub found
[    4.854157] hub 4-0:1.0: 4 ports detected
[    4.886974] usbcore: registered new interface driver usb-storage
[    4.887087] i8042: PNP: No PS/2 controller found. Probing ports directly.
[    4.906670] ata1: SATA link up 6.0 Gbps (SStatus 133 SControl 300)
[    5.934234] ata1.00: ACPI cmd ef/10:06:00:00:00:00 (SET FEATURES) succeeded
[    5.934239] ata1.00: ACPI cmd f5/00:00:00:00:00:00 (SECURITY FREEZE LOCK) filtered out
[    5.934242] ata1.00: ACPI cmd b1/c1:00:00:00:00:00 (DEVICE CONFIGURATION OVERLAY) filtered out
[    5.935137] i8042: No controller found
[    5.935486] hv_vmbus: registering driver hyperv_keyboard
[    5.935493] ata1.00: supports DRM functions and may not be fully accessible
[    5.935663] mousedev: PS/2 mouse device common for all mice
[    5.935863] rtc_cmos 00:04: RTC can wake from S4
[    5.936179] rtc_cmos 00:04: rtc core: registered rtc_cmos as rtc0
[    5.936294] rtc_cmos 00:04: alarms up to one month, y3k, 242 bytes nvram
[    5.936636] i2c /dev entries driver
[    5.937084] xen: registering gsi 18 triggering 0 polarity 1
[    5.937094] Already setup the GSI :18
[    5.937102] ACPI Warning: 0x000000000000f040-0x000000000000f05f SystemIO conflicts with Region \_SB_.PCI0.SBUS.SMBI 1 (20131115/utaddress-251)
[    5.937115] ACPI: If an ACPI driver is available for this device, you should use it instead of the native driver
[    5.937342] pps_ldisc: PPS line discipline registered
[    5.938291] w83627ehf: Found NCT6776F chip at 0xa30
[    5.938473] ata1.00: ATA-9: Crucial_CT120M500SSD3, MU03, max UDMA/133
[    5.938475] ata1.00: 234441648 sectors, multi 16: LBA48 NCQ (depth 31/32), AA
[    5.939454] sp5100_tco: SP5100/SB800 TCO WatchDog Timer Driver v0.05
[    5.939561] iTCO_wdt: Intel TCO WatchDog Timer Driver v1.10
[    5.939624] iTCO_wdt: Found a Panther Point TCO device (Version=2, TCOBASE=0x0460)
[    5.939747] iTCO_wdt: initialized. heartbeat=30 sec (nowayout=0)
[    5.939761] iTCO_vendor_support: vendor-support=0
[    5.939764] xen_wdt: Xen WatchDog Timer Driver v0.01
[    5.939821] xen_wdt: cannot register miscdev on minor=130 (-16)
[    5.940566] wdt: probe of wdt failed with error -16
[    5.940586] softdog: Software Watchdog Timer: 0.08 initialized. soft_noboot=0 soft_margin=60 sec soft_panic=0 (nowayout=0)
[    5.940647] device-mapper: uevent: version 1.0.3
[    5.940696] device-mapper: ioctl: 4.27.0-ioctl (2013-10-30) initialised: dm-devel@redhat.com
[    5.940799] Intel P-state driver initializing.
[    5.940832] leds_ss4200: no LED devices found
[    5.940851] hidraw: raw HID events driver (C) Jiri Kosina
[    5.940934] usbcore: registered new interface driver usbhid
[    5.940935] usbhid: USB HID core driver
[    5.940938] hv_utils: Registering HyperV Utility Driver
[    5.940939] hv_vmbus: registering driver hv_util
[    5.940992] usbcore: registered new interface driver snd-usb-audio
[    5.941002] usbcore: registered new interface driver snd-ua101
[    5.941011] usbcore: registered new interface driver snd-usb-usx2y
[    5.941020] usbcore: registered new interface driver snd-usb-us122l
[    5.941030] usbcore: registered new interface driver snd-usb-caiaq
[    5.941039] usbcore: registered new interface driver snd-usb-6fire
[    5.941048] usbcore: registered new interface driver snd-usb-hiface
[    5.941076] drop_monitor: Initializing network drop monitor service
[    5.941096] GACT probability on
[    5.941098] Mirror/redirect action on
[    5.941099] Simple TC action Loaded
[    5.941181] netem: version 1.3
[    5.941183] u32 classifier
[    5.941184]     Performance counters on
[    5.941185]     input device check on
[    5.941186]     Actions configured
[    5.941189] Netfilter messages via NETLINK v0.30.
[    5.941192] nfnl_acct: registering with nfnetlink.
[    5.941201] nf_conntrack version 0.5.0 (16384 buckets, 65536 max)
[    5.941274] ctnetlink v0.93: registering with nfnetlink.
[    5.941325] xt_time: kernel timezone is -0000
[    5.941328] ip_set: protocol 6
[    5.941334] IPVS: Registered protocols (TCP, UDP, SCTP, AH, ESP)
[    5.941352] IPVS: Connection hash table configured (size=4096, memory=64Kbytes)
[    5.941387] IPVS: Creating netns size=2048 id=0
[    5.941395] IPVS: ipvs loaded.
[    5.941396] IPVS: [rr] scheduler registered.
[    5.941398] IPVS: [wrr] scheduler registered.
[    5.941399] IPVS: [lc] scheduler registered.
[    5.941400] IPVS: [wlc] scheduler registered.
[    5.941403] IPVS: [lblc] scheduler registered.
[    5.941405] IPVS: [lblcr] scheduler registered.
[    5.941406] IPVS: [dh] scheduler registered.
[    5.941407] IPVS: [sh] scheduler registered.
[    5.941408] IPVS: [sed] scheduler registered.
[    5.941409] IPVS: [nq] scheduler registered.
[    5.941479] ip_tables: (C) 2000-2006 Netfilter Core Team
[    5.941511] ipt_CLUSTERIP: ClusterIP Version 0.8 loaded successfully
[    5.941520] arp_tables: (C) 2002 David S. Miller
[    5.941529] TCP: cubic registered
[    5.941530] Initializing XFRM netlink socket
[    5.941534] NET: Registered protocol family 17
[    5.941539] NET: Registered protocol family 15
[    5.941557] Ebtables v2.0 registered
[    5.942238] ata1.00: ACPI cmd ef/10:06:00:00:00:00 (SET FEATURES) succeeded
[    5.942241] ata1.00: ACPI cmd f5/00:00:00:00:00:00 (SECURITY FREEZE LOCK) filtered out
[    5.942243] ata1.00: ACPI cmd b1/c1:00:00:00:00:00 (DEVICE CONFIGURATION OVERLAY) filtered out
[    5.942512] ata1.00: supports DRM functions and may not be fully accessible
[    5.948733] ata1.00: configured for UDMA/133
[    5.948845] scsi 0:0:0:0: Direct-Access     ATA      Crucial_CT120M50 MU03 PQ: 0 ANSI: 5
[    5.948951] sd 0:0:0:0: [sda] 234441648 512-byte logical blocks: (120 GB/111 GiB)
[    5.948954] sd 0:0:0:0: [sda] 4096-byte physical blocks
[    5.948987] sd 0:0:0:0: Attached scsi generic sg0 type 0
[    5.948999] sd 0:0:0:0: [sda] Write Protect is off
[    5.949001] sd 0:0:0:0: [sda] Mode Sense: 00 3a 00 00
[    5.949017] sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[    5.949565]  sda: sda1
[    5.949754] sd 0:0:0:0: [sda] Attached SCSI disk
[    5.974854] NET: Registered protocol family 33
[    5.974862] Key type rxrpc registered
[    5.974866] Key type rxrpc_s registered
[    5.974881] 8021q: 802.1Q VLAN Support v1.8
[    5.974898] lib80211: common routines for IEEE802.11 drivers
[    5.974903] lib80211_crypt: registered algorithm 'NULL'
[    5.974906] lib80211_crypt: registered algorithm 'WEP'
[    5.974910] lib80211_crypt: registered algorithm 'CCMP'
[    5.974913] lib80211_crypt: registered algorithm 'TKIP'
[    5.974931] Key type dns_resolver registered
[    5.975833] registered taskstats version 1
[    5.976952] console [netcon0] enabled
[    5.976956] netconsole: network logging started
[    5.977102] rtc_cmos 00:04: setting system clock to 2013-12-11 18:45:15 UTC (1386787515)
[    5.977134] BIOS EDD facility v0.16 2004-Jun-25, 1 devices found
[    5.977300] ALSA device list:
[    5.977303]   No soundcards found.
[    5.978750] Freeing unused kernel memory: 1148K (ffffffff81f21000 - ffffffff82040000)
[    5.978755] Write protecting the kernel read-only data: 14336k
[    5.983817] Freeing unused kernel memory: 1048K (ffff8800018fa000 - ffff880001a00000)
[    5.983994] Freeing unused kernel memory: 376K (ffff880001da2000 - ffff880001e00000)
[    6.017549] udevd[193]: starting version 175
[    6.146730] usb 1-1: new high-speed USB device number 2 using ehci-pci
[    6.279084] usb 1-1: New USB device found, idVendor=8087, idProduct=0024
[    6.279094] usb 1-1: New USB device strings: Mfr=0, Product=0, SerialNumber=0
[    6.279587] hub 1-1:1.0: USB hub found
[    6.279726] hub 1-1:1.0: 6 ports detected
[    6.319191] microcode: CPU0 sig=0x306a9, pf=0x10, revision=0x17
[    6.319238] microcode: CPU0 update to revision 0x19 failed
[    6.320942] microcode: CPU1 sig=0x306a9, pf=0x10, revision=0x17
[    6.320976] microcode: CPU1 update to revision 0x19 failed
[    6.322440] microcode: CPU2 sig=0x306a9, pf=0x10, revision=0x17
[    6.322470] microcode: CPU2 update to revision 0x19 failed
[    6.324069] microcode: CPU3 sig=0x306a9, pf=0x10, revision=0x17
[    6.324100] microcode: CPU3 update to revision 0x19 failed
[    6.347692] random: lvm urandom read with 60 bits of entropy available
[    6.383370] bio: create slab <bio-2> at 2
[    6.390728] usb 2-1: new high-speed USB device number 2 using ehci-pci
[    6.506026] EXT4-fs (dm-0): mounted filesystem with ordered data mode. Opts: (null)
[    6.523081] usb 2-1: New USB device found, idVendor=8087, idProduct=0024
[    6.523085] usb 2-1: New USB device strings: Mfr=0, Product=0, SerialNumber=0
[    6.523351] hub 2-1:1.0: USB hub found
[    6.523451] hub 2-1:1.0: 8 ports detected
[    6.638729] usb 3-3: new full-speed USB device number 2 using xhci_hcd
[    6.655338] usb 3-3: New USB device found, idVendor=0d8c, idProduct=000e
[    6.655341] usb 3-3: New USB device strings: Mfr=0, Product=1, SerialNumber=0
[    6.655343] usb 3-3: Product: Generic USB Audio Device   
[    6.730881] usb 1-1.1: new full-speed USB device number 3 using ehci-pci
[    6.815349] udevd[479]: starting version 175
[    6.827654] usb 1-1.1: New USB device found, idVendor=8087, idProduct=07da
[    6.827666] usb 1-1.1: New USB device strings: Mfr=0, Product=0, SerialNumber=0
[    6.899735] random: nonblocking pool is initialized
[    7.819809] EXT4-fs (dm-0): re-mounted. Opts: (null)
[    7.919273] EXT4-fs (dm-0): re-mounted. Opts: discard,errors=remount-ro
[    8.863934] Adding 1949692k swap on /dev/mapper/creabox-creabox_swap.  Priority:-1 extents:1 across:1949692k SS
[   11.540793] e1000e: eth0 NIC Link is Up 100 Mbps Full Duplex, Flow Control: Rx/Tx
[   11.540799] e1000e 0000:00:19.0 eth0: 10/100 speed: disabling TSO
[   20.131091] iwlwifi 0000:02:00.0: L1 Disabled; Enabling L0S
[   20.138074] iwlwifi 0000:02:00.0: Radio type=0x2-0x1-0x0
[   20.412347] iwlwifi 0000:02:00.0: L1 Disabled; Enabling L0S
[   20.419122] iwlwifi 0000:02:00.0: Radio type=0x2-0x1-0x0
[   20.499225] device wlan0 entered promiscuous mode
[   20.502148] xen_bridge: port 1(wlan0) entered forwarding state
[   20.502156] xen_bridge: port 1(wlan0) entered forwarding state
[   20.502235] cfg80211: Pending regulatory request, waiting for it to be processed...
[   21.282880] device vif1.0 entered promiscuous mode
[   21.380304] device vif1.0-emu entered promiscuous mode
[   21.382287] xen_bridge: port 3(vif1.0-emu) entered forwarding state
[   21.382292] xen_bridge: port 3(vif1.0-emu) entered forwarding state
[   34.093695] xen-blkback:ring-ref 8, event-channel 25, protocol 2 (x86_32-abi) persistent grants
[   34.108097] xen-blkback:ring-ref 9, event-channel 26, protocol 2 (x86_32-abi) persistent grants
[   34.254371] xen_bridge: port 2(vif1.0) entered forwarding state
[   34.254405] xen_bridge: port 2(vif1.0) entered forwarding state
[  126.454516] cfg80211: Pending regulatory request, waiting for it to be processed...



>   Luis
