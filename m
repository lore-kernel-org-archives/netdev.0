From: "Arend van Spriel" <arend@broadcom.com>
Subject: Re: [0/5] bcma/brcmsmac suspend/resume cleanups and fixes
Date: Mon, 16 Jan 2012 15:00:36 +0100
Message-ID: <4F142D84.4060405@broadcom.com>
References: <CA+55aFzm21ZKs7e_ocVA1bQQ=Js2dJpbiycwHR3v8yNvb0MgTw@mail.gmail.com>
 <1326440480-26271-1-git-send-email-zajec5@gmail.com>
 <alpine.LNX.2.00.1201122354430.5860@air.linux-foundation.org>
 <4F101047.4090902@broadcom.com>
 <CA+55aFxtaw+FF8wRf9td1rU0A_vhM8XwgSznzE-ph_4j=t5gWg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-8859-2
Content-Transfer-Encoding: 7bit
Cc: =?ISO-8859-2?Q?Rafa=B3_Mi=B3ecki?= <zajec5@gmail.com>,
	"Larry Finger" <Larry.Finger@lwfinger.net>,
	"Alwin Beukers" <alwin@broadcom.com>,
	"Roland Vossen" <rvossen@broadcom.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	"Network Development" <netdev@vger.kernel.org>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>
To: "Linus Torvalds" <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2174 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751799Ab2APOAx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Jan 2012 09:00:53 -0500
In-Reply-To: <CA+55aFxtaw+FF8wRf9td1rU0A_vhM8XwgSznzE-ph_4j=t5gWg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/14/2012 04:50 AM, Linus Torvalds wrote:
> 2012/1/13 Arend van Spriel <arend@broadcom.com>:
>>
>> Upon suspend my laptop hangs (see trace below pulled from serial
>> console). I do not see the pr_debug in the suspend function (compiled
>> with -DDEBUG). Unfortunately the same happens when I don't insert bcma
>> and brcmsmac. I attached the kernel configuration.
> 
> Ok, I note that you do have MCE enabled.
> 
> The MCE problems should be fixed in current -git, and so it might be
> worth re-testing with that.
> 
>                    Linus
> 

Hi Linus,

I build a kernel with MCE disabled and tested that. It still hung. I
decided run the kernel with nomodeset parameter to avoid framebuffer
issues. Now the suspend worked, but resume failed. Just heard a beep and
that was it. I will refresh the tree and build another kernel with MCE
enabled.

Also observed occasional long delay upon startup:

[    0.000000] Initializing cgroup subsys cpuset
[    0.000000] Initializing cgroup subsys cpu
[    0.000000] Linux version 3.2.0-07331-gb2a1efc (root@arend-vb-linux)
(gcc version 4.6.1 (Ubuntu/Linaro 4.6.1-9ubuntu3) ) #1 SMP Fri Jan 13
21:31:23 CET 2012
[    0.000000] BIOS-provided physical RAM map:
[    0.000000]  BIOS-e820: 0000000000000000 - 000000000009ac00 (usable)
[    0.000000]  BIOS-e820: 000000000009ac00 - 00000000000a0000 (reserved)
[    0.000000]  BIOS-e820: 00000000000e0000 - 0000000000100000 (reserved)
[    0.000000]  BIOS-e820: 0000000000100000 - 00000000cf65f000 (usable)
[    0.000000]  BIOS-e820: 00000000cf65f000 - 00000000cf67f000 (ACPI data)
[    0.000000]  BIOS-e820: 00000000cf67f000 - 00000000cf76f000 (ACPI NVS)
[    0.000000]  BIOS-e820: 00000000cf76f000 - 00000000d0000000 (reserved)
[    0.000000]  BIOS-e820: 00000000f8000000 - 00000000fc000000 (reserved)
[    0.000000]  BIOS-e820: 00000000fec00000 - 00000000fec01000 (reserved)
[    0.000000]  BIOS-e820: 00000000fed10000 - 00000000fed14000 (reserved)
[    0.000000]  BIOS-e820: 00000000fed18000 - 00000000fed1a000 (reserved)
[    0.000000]  BIOS-e820: 00000000fed1c000 - 00000000fed20000 (reserved)
[    0.000000]  BIOS-e820: 00000000fee00000 - 00000000fee01000 (reserved)
[    0.000000]  BIOS-e820: 00000000ff800000 - 0000000100000000 (reserved)
[    0.000000]  BIOS-e820: 0000000100000000 - 000000012c000000 (usable)
[    0.000000] debug: ignoring loglevel setting.
[    0.000000] Notice: NX (Execute Disable) protection cannot be
enabled: non-PAE kernel!
[    0.000000] DMI 2.6 present.
[    0.000000] DMI: Dell Inc. Latitude E6410/07XJP9, BIOS A07 02/15/2011
[    0.000000] e820 update range: 0000000000000000 - 0000000000010000
(usable) ==> (reserved)
[    0.000000] e820 remove range: 00000000000a0000 - 0000000000100000
(usable)
[    0.000000] last_pfn = 0xcf65f max_arch_pfn = 0x100000
[    0.000000] MTRR default type: uncachable
[    0.000000] MTRR fixed ranges enabled:
[    0.000000]   00000-9FFFF write-back
[    0.000000]   A0000-BFFFF uncachable
[    0.000000]   C0000-FFFFF write-protect
[    0.000000] MTRR variable ranges enabled:
[    0.000000]   0 base 000000000 mask F80000000 write-back
[    0.000000]   1 base 080000000 mask FC0000000 write-back
[    0.000000]   2 base 0C0000000 mask FF0000000 write-back
[    0.000000]   3 base 100000000 mask FE0000000 write-back
[    0.000000]   4 base 120000000 mask FF0000000 write-back
[    0.000000]   5 base 12C000000 mask FFC000000 uncachable
[    0.000000]   6 disabled
[    0.000000]   7 disabled
[    0.000000] x86 PAT enabled: cpu 0, old 0x7040600070406, new
0x7010600070106
[    0.000000] e820 update range: 00000000d0000000 - 0000000100000000
(usable) ==> (reserved)
[    0.000000] found SMP MP-table at [c00f2200] f2200
[    0.000000] initial memory mapped : 0 - 01c00000
[    0.000000] Base memory trampoline at [c0096000] 96000 size 16384
[    0.000000] init_memory_mapping: 0000000000000000-00000000377fe000
[    0.000000]  0000000000 - 0000400000 page 4k
[    0.000000]  0000400000 - 0037400000 page 2M
[    0.000000]  0037400000 - 00377fe000 page 4k
[    0.000000] kernel direct mapping tables up to 377fe000 @ 1bfb000-1c00000
[    0.000000] RAMDISK: 37c1a000 - 37ff0000
[    0.000000] Allocated new RAMDISK: 37428000 - 377fd004
[    0.000000] Move RAMDISK from 0000000037c1a000 - 0000000037fef003 to
37428000 - 377fd003
[    0.000000] ACPI: RSDP 000fe300 00024 (v02 DELL  )
[    0.000000] ACPI: XSDT cf67de18 00064 (v01 DELL    E2      06222004
MSFT 00010013)
[    0.000000] ACPI: FACP cf75fc18 000F4 (v04 DELL    E2      06222004
MSFT 00010013)
[    0.000000] ACPI Warning: 32/64 FACS address mismatch in FADT - two
FACS tables! (20110623/tbfadt-369)
[    0.000000] ACPI Warning: 32/64X FACS address mismatch in FADT -
0xCF76BF40/0x00000000CF76ED40, using 32 (20110623/tbfadt-489)
[    0.000000] ACPI: DSDT cf73e018 0A24E (v01 DELL    E2      00001001
INTL 20080729)
[    0.000000] ACPI: FACS cf76bf40 00040
[    0.000000] ACPI: APIC cf67cf18 0008C (v02 DELL    E2      06222004
MSFT 00010013)
[    0.000000] ACPI: TCPA cf76dd18 00032 (v02                 00000000
    00000000)
[    0.000000] ACPI: MCFG cf76dc98 0003C (v01 A M I  GMCH945. 06222004
MSFT 00000097)
[    0.000000] ACPI: HPET cf76dc18 00038 (v01 DELL    E2      00000001
ASL  00000061)
[    0.000000] ACPI: BOOT cf76db98 00028 (v01 DELL   E2       06222004
AMI  00010013)
[    0.000000] ACPI: SLIC cf766818 00176 (v03 DELL    E2      06222004
MSFT 00010013)
[    0.000000] ACPI: SSDT cf74d018 009F1 (v01  PmRef    CpuPm 00003000
INTL 20080729)
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] 2430MB HIGHMEM available.
[    0.000000] 887MB LOWMEM available.
[    0.000000]   mapped low ram: 0 - 377fe000
[    0.000000]   low ram: 0 - 377fe000
[    0.000000] Zone PFN ranges:
[    0.000000]   DMA      0x00000010 -> 0x00001000
[    0.000000]   Normal   0x00001000 -> 0x000377fe
[    0.000000]   HighMem  0x000377fe -> 0x000cf65f
[    0.000000] Movable zone start PFN for each node
[    0.000000] Early memory PFN ranges
[    0.000000]     0: 0x00000010 -> 0x0000009a
[    0.000000]     0: 0x00000100 -> 0x000cf65f
[    0.000000] On node 0 totalpages: 849385
[    0.000000]   DMA zone: 32 pages used for memmap
[    0.000000]   DMA zone: 0 pages reserved
[    0.000000]   DMA zone: 3946 pages, LIFO batch:0
[    0.000000]   Normal zone: 1744 pages used for memmap
[    0.000000]   Normal zone: 221486 pages, LIFO batch:31
[    0.000000]   HighMem zone: 4861 pages used for memmap
[    0.000000]   HighMem zone: 617316 pages, LIFO batch:31
[    0.000000] Using APIC driver default
[    0.000000] ACPI: PM-Timer IO Port: 0x408
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] ACPI: LAPIC (acpi_id[0x01] lapic_id[0x00] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x02] lapic_id[0x04] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x03] lapic_id[0x01] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x04] lapic_id[0x05] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x05] lapic_id[0x04] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x06] lapic_id[0x05] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x07] lapic_id[0x06] disabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x08] lapic_id[0x07] disabled)
[    0.000000] ACPI: IOAPIC (id[0x02] address[0xfec00000] gsi_base[0])
[    0.000000] IOAPIC[0]: apic_id 2, version 32, address 0xfec00000, GSI
0-23
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
[    0.000000] ACPI: IRQ0 used by override.
[    0.000000] ACPI: IRQ2 used by override.
[    0.000000] ACPI: IRQ9 used by override.
[    0.000000] Using ACPI (MADT) for SMP configuration information
[    0.000000] ACPI: HPET id: 0x8086a701 base: 0xfed00000
[    0.000000] SMP: Allowing 8 CPUs, 4 hotplug CPUs
[    0.000000] nr_irqs_gsi: 40
[    0.000000] PM: Registered nosave memory: 000000000009a000 -
000000000009b000
[    0.000000] PM: Registered nosave memory: 000000000009b000 -
00000000000a0000
[    0.000000] PM: Registered nosave memory: 00000000000a0000 -
00000000000e0000
[    0.000000] PM: Registered nosave memory: 00000000000e0000 -
0000000000100000
[    0.000000] Allocating PCI resources starting at d0000000 (gap:
d0000000:28000000)
[    0.000000] Booting paravirtualized kernel on bare hardware
[    0.000000] setup_percpu: NR_CPUS:8 nr_cpumask_bits:8 nr_cpu_ids:8
nr_node_ids:1
[    0.000000] PERCPU: Embedded 13 pages/cpu @f5400000 s29952 r0 d23296
u524288
[    0.000000] pcpu-alloc: s29952 r0 d23296 u524288 alloc=1*4194304
[    0.000000] pcpu-alloc: [0] 0 1 2 3 4 5 6 7
[    0.000000] Built 1 zonelists in Zone order, mobility grouping on.
Total pages: 842748
[    0.000000] Kernel command line:
BOOT_IMAGE=/boot/vmlinuz-3.2.0-07331-gb2a1efc
root=UUID=7051116f-03ec-4df3-a8ff-813fb03aec9f ro ignore_loglevel
console=tty0 console=ttyS0,115200 nomodeset no_console_suspend
[    0.000000] PID hash table entries: 4096 (order: 2, 16384 bytes)
[    0.000000] Dentry cache hash table entries: 131072 (order: 7, 524288
bytes)
[    0.000000] Inode-cache hash table entries: 65536 (order: 6, 262144
bytes)
[    0.000000] Initializing CPU#0
[    0.000000] Initializing HighMem for node 0 (000377fe:000cf65f)
[    0.000000] Memory: 3357116k/3398012k available (4841k kernel code,
40424k reserved, 2278k data, 556k init, 2488708k highmem)
[    0.000000] virtual kernel memory layout:
[    0.000000]     fixmap  : 0xfff16000 - 0xfffff000   ( 932 kB)
[    0.000000]     pkmap   : 0xff800000 - 0xffc00000   (4096 kB)
[    0.000000]     vmalloc : 0xf7ffe000 - 0xff7fe000   ( 120 MB)
[    0.000000]     lowmem  : 0xc0000000 - 0xf77fe000   ( 887 MB)
[    0.000000]       .init : 0xc16f4000 - 0xc177f000   ( 556 kB)
[    0.000000]       .data : 0xc14ba50e - 0xc16f3fc0   (2278 kB)
[    0.000000]       .text : 0xc1000000 - 0xc14ba50e   (4841 kB)
[    0.000000] Checking if this processor honours the WP bit even in
supervisor mode...Ok.
[    0.000000] SLUB: Genslabs=15, HWalign=64, Order=0-3, MinObjects=0,
CPUs=8, Nodes=1
[    0.000000] Hierarchical RCU implementation.
[    0.000000]  RCU dyntick-idle grace-period acceleration is enabled.
[    0.000000] NR_IRQS:2304 nr_irqs:744 16
[    0.000000] CPU 0 irqstacks, hard=f500a000 soft=f500c000
[    0.000000] Extended CMOS year: 2000
[    0.000000] spurious 8259A interrupt: IRQ7.
[    0.000000] Console: colour VGA+ 80x25
[    0.000000] console [tty0] enabled
[    0.000000] console [ttyS0] enabled
[    0.000000] allocated 6815744 bytes of page_cgroup
[    0.000000] please try 'cgroup_disable=memory' option if you don't
want memory cgroups
[    0.000000] hpet clockevent registered
[    0.000000] Fast TSC calibration using PIT
[    0.004000] Detected 2793.229 MHz processor.
[    0.000001] Calibrating delay loop (skipped), value calculated using
timer frequency.. 5586.45 BogoMIPS (lpj=11172916)
[    0.010817] pid_max: default: 32768 minimum: 301
[    0.015520] Security Framework initialized
[    0.019689] AppArmor: AppArmor initialized
[    0.023878] Mount-cache hash table entries: 512
[    0.028574] Initializing cgroup subsys cpuacct
[    0.033081] Initializing cgroup subsys memory
[    0.037503] Initializing cgroup subsys devices
[    0.042011] Initializing cgroup subsys freezer
[    0.046518] Initializing cgroup subsys net_cls
[    0.051042] CPU: Physical Processor ID: 0
[    0.055116] CPU: Processor Core ID: 0
[    0.058827] using mwait in idle threads.
[    0.064089] ACPI: Core revision 20110623
[    0.073049] ftrace: allocating 20190 entries in 40 pages
[    0.083048] Enabling APIC mode:  Flat.  Using 1 I/O APICs
[    0.088911] ..TIMER: vector=0x30 apic1=0 pin1=2 apic2=0 pin2=0
[    0.134409] CPU0: Intel(R) Core(TM) i7 CPU       M 640  @ 2.80GHz
stepping 05
[    0.246713] Performance Events: PEBS fmt1+, Westmere events, Intel
PMU driver.
[    0.254187] CPUID marked event: 'bus cycles' unavailable
[    0.259547] ... version:                3
[    0.263743] ... bit width:              48
[    0.267890] ... generic registers:      4
[    0.271949] ... value mask:             0000ffffffffffff
[    0.279011] ... max period:             000000007fffffff
[    0.284369] ... fixed-purpose events:   3
[    0.288428] ... event mask:             000000070000000f
[    0.293915] CPU 1 irqstacks, hard=f4b4e000 soft=f4b58000
[    0.299274] Booting Node   0, Processors  #1
[    0.303474] smpboot cpu 1: start_ip = 96000
[    0.318218] Initializing CPU#1
[    0.341383] CPU 2 irqstacks, hard=f4b62000 soft=f4b64000
[    0.346745]  #2
[    0.348370] smpboot cpu 2: start_ip = 96000
[    0.362989] Initializing CPU#2
[    0.386195] CPU 3 irqstacks, hard=f4b6e000 soft=f4b70000
[    0.391557]  #3
[    0.393180] smpboot cpu 3: start_ip = 96000
[    0.407801] Initializing CPU#3
[    0.430931] Brought up 4 CPUs
[    0.433952] Total of 4 processors activated (22345.83 BogoMIPS).
[    0.442574] devtmpfs: initialized
[    0.446052] PM: Registering ACPI NVS region at cf67f000 (983040 bytes)
[    0.453333] print_constraints: dummy:
[    0.457165] RTC time: 13:52:08, date: 01/16/12
[    0.461685] NET: Registered protocol family 16
[    0.466229] ACPI FADT declares the system doesn't support PCIe ASPM,
so disable it
[    0.473852] ACPI: bus type pci registered
[    0.477960] PCI: MMCONFIG for domain 0000 [bus 00-3f] at [mem
0xf8000000-0xfbffffff] (base 0xf8000000)
[    0.487317] PCI: MMCONFIG at [mem 0xf8000000-0xfbffffff] reserved in E820
[    0.494149] PCI: Using MMCONFIG for extended config space
[    0.499596] PCI: Using configuration type 1 for base access
[    0.505220] dmi type 0xB1 record - unknown flag
[    0.510288] bio: create slab <bio-0> at 0
[    0.514393] ACPI: Added _OSI(Module Device)
[    0.518628] ACPI: Added _OSI(Processor Device)
[    0.523122] ACPI: Added _OSI(3.0 _SCP Extensions)
[    0.527876] ACPI: Added _OSI(Processor Aggregator Device)
[    0.534434] ACPI: EC: Look up EC in DSDT
[    0.542573] [Firmware Bug]: ACPI: BIOS _OSI(Linux) query ignored
[    0.555797] ACPI: SSDT cf7eaa18 004B6 (v01  PmRef  Cpu0Ist 00003000
INTL 20080729)
[    0.563813] ACPI: Dynamic OEM Table Load:
[    0.568000] ACPI: SSDT   (null) 004B6 (v01  PmRef  Cpu0Ist 00003000
INTL 20080729)
[    0.575855] ACPI: SSDT cf7e8018 00891 (v01  PmRef  Cpu0Cst 00003001
INTL 20080729)
[    0.583852] ACPI: Dynamic OEM Table Load:
[    0.588039] ACPI: SSDT   (null) 00891 (v01  PmRef  Cpu0Cst 00003001
INTL 20080729)
[    0.595979] ACPI: SSDT cf7e9a98 00303 (v01  PmRef    ApIst 00003000
INTL 20080729)
[    0.604029] ACPI: Dynamic OEM Table Load:
[    0.608216] ACPI: SSDT   (null) 00303 (v01  PmRef    ApIst 00003000
INTL 20080729)
[    0.616042] ACPI: SSDT cf7e7d98 00119 (v01  PmRef    ApCst 00003000
INTL 20080729)
[    0.624061] ACPI: Dynamic OEM Table Load:
[    0.628245] ACPI: SSDT   (null) 00119 (v01  PmRef    ApCst 00003000
INTL 20080729)
[    0.637407] ACPI: Interpreter enabled
[    0.641126] ACPI: (supports S0 S3 S4 S5)
[    0.645374] ACPI: Using IOAPIC for interrupt routing
[    0.661754] ACPI: EC: GPE = 0x10, I/O: command/status = 0x934, data =
0x930
[    0.669313] ACPI: No dock devices found.
[    0.673288] HEST: Table not found.
[    0.676743] PCI: Using host bridge windows from ACPI; if necessary,
use "pci=nocrs" and report a bug
[    0.686201] \_SB_.PCI0:_OSC invalid UUID
[    0.690175] _OSC request data:1 8 1f
[    0.694136] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-3e])
[    0.700798] pci_root PNP0A08:00: host bridge window [io  0x0000-0x0cf7]
[    0.707457] pci_root PNP0A08:00: host bridge window [io  0x0d00-0xffff]
[    0.714115] pci_root PNP0A08:00: host bridge window [mem
0x000a0000-0x000bffff]
[    0.721479] pci_root PNP0A08:00: host bridge window [mem
0xd0000000-0xfeafffff]
[    0.728865] PCI host bridge to bus 0000:00
[    0.733014] pci_bus 0000:00: root bus resource [io  0x0000-0x0cf7]
[    0.739241] pci_bus 0000:00: root bus resource [io  0x0d00-0xffff]
[    0.745467] pci_bus 0000:00: root bus resource [mem
0x000a0000-0x000bffff]
[    0.752385] pci_bus 0000:00: root bus resource [mem
0xd0000000-0xfeafffff]
[    0.759309] pci 0000:00:00.0: [8086:0044] type 0 class 0x000600
[    0.765305] pci 0000:00:01.0: [8086:0045] type 1 class 0x000604
[    0.771296] pci 0000:00:01.0: PME# supported from D0 D3hot D3cold
[    0.777484] pci 0000:00:19.0: [8086:10ea] type 0 class 0x000200
[    0.783473] pci 0000:00:19.0: reg 10: [mem 0xe9600000-0xe961ffff]
[    0.789624] pci 0000:00:19.0: reg 14: [mem 0xe9680000-0xe9680fff]
[    0.795772] pci 0000:00:19.0: reg 18: [io  0x8040-0x805f]
[    0.801302] pci 0000:00:19.0: PME# supported from D0 D3hot D3cold
[    0.807470] pci 0000:00:1a.0: [8086:3b3c] type 0 class 0x000c03
[    0.813460] pci 0000:00:1a.0: reg 10: [mem 0xe9670000-0xe96703ff]
[    0.819703] pci 0000:00:1a.0: PME# supported from D0 D3hot D3cold
[    0.825873] pci 0000:00:1b.0: [8086:3b56] type 0 class 0x000403
[    0.831857] pci 0000:00:1b.0: reg 10: [mem 0xe9660000-0xe9663fff 64bit]
[    0.838609] pci 0000:00:1b.0: PME# supported from D0 D3hot D3cold
[    0.844774] pci 0000:00:1c.0: [8086:3b42] type 1 class 0x000604
[    0.850834] pci 0000:00:1c.0: PME# supported from D0 D3hot D3cold
[    0.857003] pci 0000:00:1c.1: [8086:3b44] type 1 class 0x000604
[    0.863065] pci 0000:00:1c.1: PME# supported from D0 D3hot D3cold
[    0.869233] pci 0000:00:1c.2: [8086:3b46] type 1 class 0x000604
[    0.875295] pci 0000:00:1c.2: PME# supported from D0 D3hot D3cold
[    0.881465] pci 0000:00:1c.3: [8086:3b48] type 1 class 0x000604
[    0.887526] pci 0000:00:1c.3: PME# supported from D0 D3hot D3cold
[    0.893704] pci 0000:00:1d.0: [8086:3b34] type 0 class 0x000c03
[    0.899692] pci 0000:00:1d.0: reg 10: [mem 0xe9650000-0xe96503ff]
[    0.905934] pci 0000:00:1d.0: PME# supported from D0 D3hot D3cold
[    0.912097] pci 0000:00:1e.0: [8086:2448] type 1 class 0x000604
[    0.918144] pci 0000:00:1f.0: [8086:3b07] type 0 class 0x000601
[    0.924232] pci 0000:00:1f.2: [8086:3b2f] type 0 class 0x000106
[    0.930223] pci 0000:00:1f.2: reg 10: [io  0x8090-0x8097]
[    0.935678] pci 0000:00:1f.2: reg 14: [io  0x8080-0x8083]
[    0.941133] pci 0000:00:1f.2: reg 18: [io  0x8070-0x8077]
[    0.946589] pci 0000:00:1f.2: reg 1c: [io  0x8060-0x8063]
[    0.952045] pci 0000:00:1f.2: reg 20: [io  0x8020-0x803f]
[    0.957501] pci 0000:00:1f.2: reg 24: [mem 0xe9640000-0xe96407ff]
[    0.963703] pci 0000:00:1f.2: PME# supported from D3hot
[    0.968997] pci 0000:00:1f.3: [8086:3b30] type 0 class 0x000c05
[    0.974982] pci 0000:00:1f.3: reg 10: [mem 0xe9630000-0xe96300ff 64bit]
[    0.981669] pci 0000:00:1f.3: reg 20: [io  0x8000-0x801f]
[    0.987162] pci 0000:00:1f.6: [8086:3b32] type 0 class 0x001180
[    0.993153] pci 0000:00:1f.6: reg 10: [mem 0xe9620000-0xe9620fff 64bit]
[    0.999935] pci 0000:01:00.0: [10de:0a6c] type 0 class 0x000300
[    1.005906] pci 0000:01:00.0: reg 10: [mem 0xe2000000-0xe2ffffff]
[    1.012054] pci 0000:01:00.0: reg 14: [mem 0xd0000000-0xdfffffff
64bit pref]
[    1.019153] pci 0000:01:00.0: reg 1c: [mem 0xe0000000-0xe1ffffff
64bit pref]
[    1.026249] pci 0000:01:00.0: reg 24: [io  0x7000-0x707f]
[    1.031701] pci 0000:01:00.0: reg 30: [mem 0xe3000000-0xe307ffff pref]
[    1.038317] pci 0000:01:00.1: [10de:0be3] type 0 class 0x000403
[    1.044290] pci 0000:01:00.1: reg 10: [mem 0xe3080000-0xe3083fff]
[    1.050504] pci 0000:00:01.0: PCI bridge to [bus 01-01]
[    1.055777] pci 0000:00:01.0:   bridge window [io  0x7000-0x7fff]
[    1.061916] pci 0000:00:01.0:   bridge window [mem 0xd0000000-0xe30fffff]
[    1.068802] pci 0000:00:1c.0: PCI bridge to [bus 02-02]
[    1.074079] pci 0000:00:1c.0:   bridge window [io  0x6000-0x6fff]
[    1.080220] pci 0000:00:1c.0:   bridge window [mem 0xe8200000-0xe95fffff]
[    1.087179] pci 0000:03:00.0: [14e4:4353] type 0 class 0x000280
[    1.093213] pci 0000:03:00.0: reg 10: [mem 0xe6e00000-0xe6e03fff 64bit]
[    1.100131] pci 0000:03:00.0: supports D1 D2
[    1.104450] pci 0000:03:00.0: PME# supported from D0 D3hot D3cold
[    1.110764] pci 0000:00:1c.1: PCI bridge to [bus 03-03]
[    1.116039] pci 0000:00:1c.1:   bridge window [io  0x5000-0x5fff]
[    1.122181] pci 0000:00:1c.1:   bridge window [mem 0xe6e00000-0xe81fffff]
[    1.129141] pci 0000:04:00.0: [1180:e476] type 2 class 0x000607
[    1.135172] pci 0000:04:00.0: reg 10: [mem 0xe5940000-0xe5940fff]
[    1.141431] pci 0000:04:00.0: supports D1 D2
[    1.145753] pci 0000:04:00.0: PME# supported from D0 D1 D2 D3hot D3cold
[    1.152508] pci 0000:04:00.1: [1180:e822] type 0 class 0x000805
[    1.158542] pci 0000:04:00.1: reg 10: [mem 0xe5930000-0xe59300ff]
[    1.164884] pci 0000:04:00.1: supports D1 D2
[    1.169204] pci 0000:04:00.1: PME# supported from D0 D1 D2 D3hot D3cold
[    1.175960] pci 0000:04:00.4: [1180:e832] type 0 class 0x000c00
[    1.181991] pci 0000:04:00.4: reg 10: [mem 0xe5900000-0xe59007ff]
[    1.188331] pci 0000:04:00.4: supports D1 D2
[    1.192652] pci 0000:04:00.4: PME# supported from D0 D1 D2 D3hot D3cold
[    1.207903] pci 0000:00:1c.2: PCI bridge to [bus 04-05]
[    1.213185] pci 0000:00:1c.2:   bridge window [io  0x2000-0x3fff]
[    1.219328] pci 0000:00:1c.2:   bridge window [mem 0xe3100000-0xe59fffff]
[    1.226255] pci_bus 0000:05: [bus 05-08] partially hidden behind
bridge 0000:04 [bus 04-05]
[    1.234712] pci 0000:00:1c.3: PCI bridge to [bus 06-0b]
[    1.239989] pci 0000:00:1c.3:   bridge window [io  0x4000-0x4fff]
[    1.246132] pci 0000:00:1c.3:   bridge window [mem 0xe5a00000-0xe6dfffff]
[    1.253165] pci 0000:00:1e.0: PCI bridge to [bus 0c-0c] (subtractive
decode)
[    1.260268] pci 0000:00:1e.0:   bridge window [io  0x0000-0x0cf7]
(subtractive decode)
[    1.268236] pci 0000:00:1e.0:   bridge window [io  0x0d00-0xffff]
(subtractive decode)
[    1.276203] pci 0000:00:1e.0:   bridge window [mem
0x000a0000-0x000bffff] (subtractive decode)
[    1.284867] pci 0000:00:1e.0:   bridge window [mem
0xd0000000-0xfeafffff] (subtractive decode)
[    1.293558] pci_bus 0000:00: on NUMA node 0
[    1.297792] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0._PRT]
[    1.303885] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.AGP_._PRT]
[    1.310325] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.P0P1._PRT]
[    1.316805] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.RP01._PRT]
[    1.323240] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.RP02._PRT]
[    1.329677] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.RP03._PRT]
[    1.336114] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.RP04._PRT]
[    1.342600] \_SB_.PCI0:_OSC invalid UUID
[    1.346574] _OSC request data:1 1f 1f
[    1.350627]  pci0000:00: Requesting ACPI _OSC control (0x1d)
[    1.356358] \_SB_.PCI0:_OSC invalid UUID
[    1.360332] _OSC request data:1 0 1d
[    1.366005]  pci0000:00: ACPI _OSC request failed (AE_ERROR),
returned control mask: 0x1d
[    1.374233] ACPI _OSC control for PCIe not granted, disabling ASPM
[    1.383094] ACPI: PCI Root Bridge [CPBG] (domain 0000 [bus 3f])
[    1.389084] PCI: root bus 3f: using default resources
[    1.394200] PCI host bridge to bus 0000:3f
[    1.398349] pci_bus 0000:3f: root bus resource [io  0x0000-0xffff]
[    1.404575] pci_bus 0000:3f: root bus resource [mem
0x00000000-0xffffffff]
[    1.411498] pci 0000:3f:00.0: [8086:2c62] type 0 class 0x000600
[    1.417477] pci 0000:3f:00.1: [8086:2d01] type 0 class 0x000600
[    1.423458] pci 0000:3f:02.0: [8086:2d10] type 0 class 0x000600
[    1.429436] pci 0000:3f:02.1: [8086:2d11] type 0 class 0x000600
[    1.435414] pci 0000:3f:02.2: [8086:2d12] type 0 class 0x000600
[    1.441392] pci 0000:3f:02.3: [8086:2d13] type 0 class 0x000600
[    1.447378] pci_bus 0000:3f: on NUMA node 0
[    1.451617]  pci0000:3f: Requesting ACPI _OSC control (0x1d)
[    1.457322]  pci0000:3f: ACPI _OSC request failed (AE_NOT_FOUND),
returned control mask: 0x1d
[    1.465896] ACPI _OSC control for PCIe not granted, disabling ASPM
[    1.472273] ACPI: PCI Interrupt Link [LNKA] (IRQs 1 3 4 5 6 7 10 12
14 15) *11
[    1.480406] ACPI: PCI Interrupt Link [LNKB] (IRQs 1 3 4 5 6 7 11 12
14 15) *10
[    1.488543] ACPI: PCI Interrupt Link [LNKC] (IRQs 1 3 4 *5 6 7 10 12
14 15)
[    1.496341] ACPI: PCI Interrupt Link [LNKD] (IRQs 1 3 4 5 6 7 11 12
14 15) *10
[    1.504473] ACPI: PCI Interrupt Link [LNKE] (IRQs 1 *3 4 5 6 7 10 12
14 15)
[    1.512267] ACPI: PCI Interrupt Link [LNKF] (IRQs 1 3 4 5 6 7 11 12
14 15) *0, disabled.
[    1.521326] ACPI: PCI Interrupt Link [LNKG] (IRQs 1 3 4 5 6 7 10 12
14 15) *11
[    1.529455] ACPI: PCI Interrupt Link [LNKH] (IRQs 1 3 4 5 6 7 11 12
14 15) *0, disabled.
[    1.538538] vgaarb: device added:
PCI:0000:01:00.0,decodes=io+mem,owns=io+mem,locks=none
[    1.546683] vgaarb: loaded
[    1.549442] vgaarb: bridge control possible 0000:01:00.0
[    1.554860] SCSI subsystem initialized
[    1.558688] libata version 3.00 loaded.
[    1.562602] usbcore: registered new interface driver usbfs
[    1.568142] usbcore: registered new interface driver hub
[    1.573515] usbcore: registered new device driver usb
[    1.578698] wmi: Mapper loaded
[    1.581805] PCI: Using ACPI for IRQ routing
[    1.588192] PCI: pci_cache_line_size set to 64 bytes
[    1.593319] reserve RAM buffer: 000000000009ac00 - 000000000009ffff
[    1.599537] reserve RAM buffer: 00000000cf65f000 - 00000000cfffffff
[    1.606060] NetLabel: Initializing
[    1.609760] NetLabel:  domain hash size = 128
[    1.614168] NetLabel:  protocols = UNLABELED CIPSOv4
[    1.619188] NetLabel:  unlabeled traffic allowed by default
[    1.624837] hpet0: at MMIO 0xfed00000, IRQs 2, 8, 0, 0, 0, 0, 0, 0
[    1.631639] hpet0: 8 comparators, 64-bit 14.318180 MHz counter
[    1.639532] Switching to clocksource hpet
[    1.648052] AppArmor: AppArmor Filesystem Enabled
[    1.652837] pnp: PnP ACPI init
[    1.655960] ACPI: bus type pnp registered
[    1.660275] pnp 00:00: [bus 00-3e]
[    1.663738] pnp 00:00: [io  0x0000-0x0cf7 window]
[    1.668500] pnp 00:00: [io  0x0cf8-0x0cff]
[    1.672652] pnp 00:00: [io  0x0d00-0xffff window]
[    1.677412] pnp 00:00: [mem 0x000a0000-0x000bffff window]
[    1.682865] pnp 00:00: [mem 0x000c0000-0x000c3fff window]
[    1.688316] pnp 00:00: [mem 0x000c4000-0x000c7fff window]
[    1.693768] pnp 00:00: [mem 0x000c8000-0x000cbfff window]
[    1.699219] pnp 00:00: [mem 0x000cc000-0x000cffff window]
[    1.704669] pnp 00:00: [mem 0x000d0000-0x000d3fff window]
[    1.710121] pnp 00:00: [mem 0x000d4000-0x000d7fff window]
[    1.715570] pnp 00:00: [mem 0x000d8000-0x000dbfff window]
[    1.721021] pnp 00:00: [mem 0x000dc000-0x000dffff window]
[    1.726473] pnp 00:00: [mem 0x000e0000-0x000e3fff window]
[    1.731926] pnp 00:00: [mem 0x000e4000-0x000e7fff window]
[    1.737377] pnp 00:00: [mem 0x000e8000-0x000ebfff window]
[    1.742827] pnp 00:00: [mem 0x000ec000-0x000effff window]
[    1.748280] pnp 00:00: [mem 0x000f0000-0x000fffff window]
[    1.753733] pnp 00:00: [mem 0xd0000000-0xfeafffff window]
[    1.759184] pnp 00:00: [mem 0xfed40000-0xfed44fff window]
[    1.764682] pnp 00:00: Plug and Play ACPI device, IDs PNP0a08 PNP0a03
(active)
[    1.771981] pnp 00:01: [io  0x0000-0x001f]
[    1.776135] pnp 00:01: [io  0x0081-0x0091]
[    1.780287] pnp 00:01: [io  0x0093-0x009f]
[    1.784440] pnp 00:01: [io  0x00c0-0x00df]
[    1.788593] pnp 00:01: [dma 4]
[    1.791717] pnp 00:01: Plug and Play ACPI device, IDs PNP0200 (active)
[    1.798299] pnp 00:02: [mem 0xff000000-0xffffffff]
[    1.803153] pnp 00:02: Plug and Play ACPI device, IDs INT0800 (active)
[    1.809783] pnp 00:03: [mem 0xfed00000-0xfed003ff]
[    1.814643] pnp 00:03: Plug and Play ACPI device, IDs PNP0103 (active)
[    1.821226] pnp 00:04: [io  0x00f0]
[    1.824779] pnp 00:04: [irq 13]
[    1.827992] pnp 00:04: Plug and Play ACPI device, IDs PNP0c04 (active)
[    1.834574] pnp 00:05: [io  0x002e-0x002f]
[    1.838726] pnp 00:05: [io  0x004e-0x004f]
[    1.842878] pnp 00:05: [io  0x0061]
[    1.846420] pnp 00:05: [io  0x0063]
[    1.849963] pnp 00:05: [io  0x0065]
[    1.853508] pnp 00:05: [io  0x0067]
[    1.857054] pnp 00:05: [io  0x0070]
[    1.860600] pnp 00:05: [io  0x0080]
[    1.864146] pnp 00:05: [io  0x0092]
[    1.867691] pnp 00:05: [io  0x00b2-0x00b3]
[    1.871843] pnp 00:05: [io  0x0680-0x069f]
[    1.875995] pnp 00:05: [io  0x1000-0x1003]
[    1.880144] pnp 00:05: [io  0x1004-0x1013]
[    1.884296] pnp 00:05: [io  0xffff]
[    1.887842] pnp 00:05: [io  0x0400-0x047f]
[    1.891992] pnp 00:05: [io  0x0500-0x057f]
[    1.896144] pnp 00:05: [io  0x164e-0x164f]
[    1.900330] system 00:05: [io  0x0680-0x069f] has been reserved
[    1.906304] system 00:05: [io  0x1000-0x1003] has been reserved
[    1.912276] system 00:05: [io  0x1004-0x1013] has been reserved
[    1.918248] system 00:05: [io  0xffff] has been reserved
[    1.923611] system 00:05: [io  0x0400-0x047f] has been reserved
[    1.929582] system 00:05: [io  0x0500-0x057f] has been reserved
[    1.935552] system 00:05: [io  0x164e-0x164f] has been reserved
[    1.941522] system 00:05: Plug and Play ACPI device, IDs PNP0c02 (active)
[    1.948367] pnp 00:06: [io  0x0070-0x0077]
[    1.952523] pnp 00:06: [irq 8]
[    1.955648] pnp 00:06: Plug and Play ACPI device, IDs PNP0b00 (active)
[    1.962230] pnp 00:07: [io  0x0060]
[    1.965777] pnp 00:07: [io  0x0064]
[    1.969325] pnp 00:07: [irq 1]
[    1.972450] pnp 00:07: Plug and Play ACPI device, IDs PNP0303 (active)
[    1.980087] pnp 00:08: [io  0x03f8-0x03ff]
[    1.984244] pnp 00:08: [irq 4]
[    1.987398] pnp 00:08: Plug and Play ACPI device, IDs PNP0501 (active)
[    1.994883] pnp 00:09: [io  0x0378-0x037b]
[    1.999041] pnp 00:09: [irq 7]
[    2.002181] pnp 00:09: Plug and Play ACPI device, IDs PNP0401 (active)
[    2.008768] pnp 00:0a: [irq 12]
[    2.011984] pnp 00:0a: Plug and Play ACPI device, IDs DLL040a PNP0f13
(active)
[    2.019424] pnp 00:0b: [mem 0xfed1c000-0xfed1ffff]
[    2.024273] pnp 00:0b: [mem 0xfed10000-0xfed13fff]
[    2.029118] pnp 00:0b: [mem 0xfed18000-0xfed18fff]
[    2.033964] pnp 00:0b: [mem 0xfed19000-0xfed19fff]
[    2.038810] pnp 00:0b: [mem 0xf8000000-0xfbffffff]
[    2.043654] pnp 00:0b: [mem 0xfed20000-0xfed3ffff]
[    2.048499] pnp 00:0b: [mem 0xfed90000-0xfed8ffff disabled]
[    2.054122] pnp 00:0b: [mem 0xfed45000-0xfed8ffff]
[    2.058965] pnp 00:0b: [mem 0xff000000-0xffffffff]
[    2.063810] pnp 00:0b: [mem 0xfee00000-0xfeefffff]
[    2.068654] pnp 00:0b: [mem 0xe96c0000-0xe96c0fff]
[    2.073532] system 00:0b: [mem 0xfed1c000-0xfed1ffff] has been reserved
[    2.080199] system 00:0b: [mem 0xfed10000-0xfed13fff] has been reserved
[    2.086864] system 00:0b: [mem 0xfed18000-0xfed18fff] has been reserved
[    2.093526] system 00:0b: [mem 0xfed19000-0xfed19fff] has been reserved
[    2.100190] system 00:0b: [mem 0xf8000000-0xfbffffff] has been reserved
[    2.106853] system 00:0b: [mem 0xfed20000-0xfed3ffff] has been reserved
[    2.113515] system 00:0b: [mem 0xfed45000-0xfed8ffff] has been reserved
[    2.120178] system 00:0b: [mem 0xff000000-0xffffffff] could not be
reserved
[    2.127191] system 00:0b: [mem 0xfee00000-0xfeefffff] could not be
reserved
[    2.134202] system 00:0b: [mem 0xe96c0000-0xe96c0fff] has been reserved
[    2.140866] system 00:0b: Plug and Play ACPI device, IDs PNP0c02 (active)
[    2.147756] pnp 00:0c: [irq 23]
[    2.150977] pnp 00:0c: Plug and Play ACPI device, IDs SMO8800 (active)
[    2.158645] pnp 00:0d: [bus 3f]
[    2.161874] pnp 00:0d: Plug and Play ACPI device, IDs PNP0a03 (active)
[  118.756113] pnp: PnP ACPI: found 14 devices
[  118.760526] ACPI: ACPI bus type pnp unregistered
[  118.801225] PCI: max bus depth: 2 pci_try_num: 3
[  118.805957] pci 0000:00:1c.3: BAR 15: assigned [mem
0xe9700000-0xe98fffff 64bit pref]
[  118.813845] pci 0000:00:1c.2: BAR 15: assigned [mem
0xec000000-0xefffffff pref]
[  118.821214] pci 0000:00:1c.1: BAR 15: assigned [mem
0xe9900000-0xe9afffff 64bit pref]
[  118.829103] pci 0000:00:1c.0: BAR 15: assigned [mem
0xe9b00000-0xe9cfffff 64bit pref]
[  118.836989] pci 0000:00:01.0: PCI bridge to [bus 01-01]
[  118.842266] pci 0000:00:01.0:   bridge window [io  0x7000-0x7fff]
[  118.848411] pci 0000:00:01.0:   bridge window [mem 0xd0000000-0xe30fffff]
[  118.855248] pci 0000:00:1c.0: PCI bridge to [bus 02-02]
[  118.860526] pci 0000:00:1c.0:   bridge window [io  0x6000-0x6fff]
[  118.866673] pci 0000:00:1c.0:   bridge window [mem 0xe8200000-0xe95fffff]
[  118.873514] pci 0000:00:1c.0:   bridge window [mem
0xe9b00000-0xe9cfffff 64bit pref]
[  118.881320] pci 0000:00:1c.1: PCI bridge to [bus 03-03]
[  118.886601] pci 0000:00:1c.1:   bridge window [io  0x5000-0x5fff]
[  118.894453] pci 0000:00:1c.1:   bridge window [mem 0xe6e00000-0xe81fffff]
[  118.901292] pci 0000:00:1c.1:   bridge window [mem
0xe9900000-0xe9afffff 64bit pref]
[  118.909098] pci 0000:04:00.0: BAR 16: can't assign mem (size 0x4000000)
[  118.915764] pci 0000:04:00.0: BAR 15: assigned [mem
0xec000000-0xefffffff pref]
[  118.923133] pci 0000:04:00.0: BAR 14: assigned [io  0x2000-0x20ff]
[  118.929363] pci 0000:04:00.0: BAR 13: assigned [io  0x2400-0x24ff]
[  118.935595] pci 0000:04:00.0: CardBus bridge to [bus 05-08]
[  118.941220] pci 0000:04:00.0:   bridge window [io  0x2400-0x24ff]
[  118.947370] pci 0000:04:00.0:   bridge window [io  0x2000-0x20ff]
[  118.953517] pci 0000:04:00.0:   bridge window [mem
0xec000000-0xefffffff pref]
