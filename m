From: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
Subject: Re: asix, setting MAC broken in v3.2. Bisected to "NET: fix phy
 init for AX88772 USB ethernet".
Date: Sun, 08 Jan 2012 17:18:02 +0200
Message-ID: <20120108171802.287811bpiixnymys@www.81.fi>
References: <20120106131051.92814bd4b7x0nmqs@www.81.fi>
 <CANEJEGvXST4YzDL4kuF=kjZBN=ng-bC5UptCU2zk6JUmhpVjmg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="=_yqp6qfwgddw"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Freddy Xin <freddy@asix.com.tw>,
	Olof Johansson <olofj@chromium.org>,
	"David S. Miller" <davem@davemloft.net>,
	David Hollis <dhollis@davehollis.com>,
	Allan Chou <allan@asix.com.tw>
To: Grant Grundler <grundler@chromium.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sd-mail-sa-01.sanoma.fi ([158.127.18.161]:41781 "EHLO
	sd-mail-sa-01.sanoma.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751305Ab2AHPSM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Jan 2012 10:18:12 -0500
In-Reply-To: <CANEJEGvXST4YzDL4kuF=kjZBN=ng-bC5UptCU2zk6JUmhpVjmg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This message is in MIME format.

--=_yqp6qfwgddw
Content-Type: text/plain;
 charset=UTF-8;
 DelSp="Yes";
 format="flowed"
Content-Disposition: inline
Content-Transfer-Encoding: 7bit

Quoting Grant Grundler <grundler@chromium.org>:

> On Fri, Jan 6, 2012 at 3:10 AM, Jussi Kivilinna
> <jussi.kivilinna@mbnet.fi> wrote:
>> Hello,
>>
>> I have asix adapter plugged to mini-server
>
> Which Asix adapter do you have? (Vendor/model)

It's Wii Ethernet adapter,
Bus 001 Device 008: ID 0b95:7720 ASIX Electronics Corp. AX88772

>
> Can you please provide:
> 1) dmesg output from asix driver
> 2) lsusb output for the device

Both attached.

>> and have to change MAC address
>> before DHCP because of ISP. This worked fine, until v3.2. Now I have to set
>> interface in promisc mode to have custom MAC working.
>
> Sorry - I didn't test this but I also would not expect this to break
> with the changes in 3.2.
>
> I'll see if Freddy or Allan (ASIX) need my help with this.

I found out that setting MAC in ax88722_reset() solves the issue for  
me. Maybe changes to init/reset sequence causes hardware to be reseted  
after set_mac_address call and revert to default MAC?

Patch attached.

-Jussi


--=_yqp6qfwgddw
Content-Type: text/plain;
 charset=UTF-8;
 name="dmesg.txt"
Content-Disposition: attachment;
 filename="dmesg.txt"
Content-Transfer-Encoding: 7bit

[    0.000000] Initializing cgroup subsys cpuset
[    0.000000] Initializing cgroup subsys cpu
[    0.000000] Linux version 3.2.0-jk1-imqmq-fixmtrr-atom32 (root@fate) (gcc version 4.4.5 (Debian 4.4.5-8) ) #4 SMP PREEMPT Fri Jan 6 12:13:26 EET 2012
[    0.000000] Disabled fast string operations
[    0.000000] BIOS-provided physical RAM map:
[    0.000000]  BIOS-e820: 0000000000000000 - 000000000009fc00 (usable)
[    0.000000]  BIOS-e820: 000000000009fc00 - 00000000000a0000 (reserved)
[    0.000000]  BIOS-e820: 00000000000e0000 - 0000000000100000 (reserved)
[    0.000000]  BIOS-e820: 0000000000100000 - 000000003f376000 (usable)
[    0.000000]  BIOS-e820: 000000003f376000 - 000000003f3bf000 (reserved)
[    0.000000]  BIOS-e820: 000000003f3bf000 - 000000003f46d000 (usable)
[    0.000000]  BIOS-e820: 000000003f46d000 - 000000003f4bf000 (ACPI NVS)
[    0.000000]  BIOS-e820: 000000003f4bf000 - 000000003f4f0000 (usable)
[    0.000000]  BIOS-e820: 000000003f4f0000 - 000000003f4ff000 (ACPI data)
[    0.000000]  BIOS-e820: 000000003f4ff000 - 000000003f500000 (usable)
[    0.000000]  BIOS-e820: 000000003f500000 - 0000000040000000 (reserved)
[    0.000000]  BIOS-e820: 00000000e0000000 - 00000000f0000000 (reserved)
[    0.000000]  BIOS-e820: 00000000fec00000 - 00000000fec01000 (reserved)
[    0.000000]  BIOS-e820: 00000000fed14000 - 00000000fed1a000 (reserved)
[    0.000000]  BIOS-e820: 00000000fed1c000 - 00000000fed20000 (reserved)
[    0.000000]  BIOS-e820: 00000000fee00000 - 00000000fee01000 (reserved)
[    0.000000]  BIOS-e820: 00000000fff00000 - 0000000100000000 (reserved)
[    0.000000] NX (Execute Disable) protection: active
[    0.000000] DMI 2.4 present.
[    0.000000] DMI: Gateway AOA150/        , BIOS v0.3103 12/09/2008
[    0.000000] e820 update range: 0000000000000000 - 0000000000010000 (usable) ==> (reserved)
[    0.000000] e820 remove range: 00000000000a0000 - 0000000000100000 (usable)
[    0.000000] last_pfn = 0x3f500 max_arch_pfn = 0x1000000
[    0.000000] MTRR default type: uncachable
[    0.000000] MTRR fixed ranges enabled:
[    0.000000]   00000-9FFFF write-back
[    0.000000]   A0000-BFFFF uncachable
[    0.000000]   C0000-C7FFF write-protect
[    0.000000]   C8000-EFFFF uncachable
[    0.000000]   F0000-FFFFF write-protect
[    0.000000] MTRR variable ranges enabled:
[    0.000000]   0 base 0FFFE0000 mask 0FFFE0000 write-protect
[    0.000000]   1 base 0FFFC0000 mask 0FFFE0000 uncachable
[    0.000000]   2 base 000000000 mask 0E0000000 write-back
[    0.000000]   3 base 020000000 mask 0E0000000 write-back
[    0.000000]   4 base 03F800000 mask 0FF800000 uncachable
[    0.000000]   5 base 03F600000 mask 0FFE00000 uncachable
[    0.000000]   6 base 03F500000 mask 0FFF00000 uncachable
[    0.000000]   7 base 000000000 mask 0FFFE0000 uncachable
[    0.000000] x86 PAT enabled: cpu 0, old 0x7040600070406, new 0x7010600070106
[    0.000000] original variable MTRRs
[    0.000000] reg 0, base: 4194176KB, range: 128KB, type WP
[    0.000000] reg 1, base: 4194048KB, range: 128KB, type UC
[    0.000000] reg 2, base: 0GB, range: 512MB, type WB
[    0.000000] reg 3, base: 512MB, range: 512MB, type WB
[    0.000000] reg 4, base: 1016MB, range: 8MB, type UC
[    0.000000] reg 5, base: 1014MB, range: 2MB, type UC
[    0.000000] reg 6, base: 1013MB, range: 1MB, type UC
[    0.000000] reg 7, base: 0GB, range: 128KB, type UC
[    0.000000] WARNING: BIOS bug: VAR MTRR 7 contains strange UC entry under 1M, check with your system vendor!
[    0.000000] total RAM covered: 1013M
[    0.000000] Found optimal setting for mtrr clean up
[    0.000000]  gran_size: 64K 	chunk_size: 16M 	num_reg: 4  	lose cover RAM: 0G
[    0.000000] New variable MTRRs
[    0.000000] reg 0, base: 0GB, range: 1GB, type WB
[    0.000000] reg 1, base: 1013MB, range: 1MB, type UC
[    0.000000] reg 2, base: 1014MB, range: 2MB, type UC
[    0.000000] reg 3, base: 1016MB, range: 8MB, type UC
[    0.000000] initial memory mapped : 0 - 01c00000
[    0.000000] Base memory trampoline at [c009b000] 9b000 size 16384
[    0.000000] init_memory_mapping: 0000000000000000-0000000037bfe000
[    0.000000]  0000000000 - 0000200000 page 4k
[    0.000000]  0000200000 - 0037a00000 page 2M
[    0.000000]  0037a00000 - 0037bfe000 page 4k
[    0.000000] kernel direct mapping tables up to 37bfe000 @ 1bfb000-1c00000
[    0.000000] RAMDISK: 2f47c000 - 2f6d9000
[    0.000000] ACPI: RSDP 000fe020 00024 (v02 ACER  )
[    0.000000] ACPI: XSDT 3f4fe120 00064 (v01 ACER   ACER     00000001      01000013)
[    0.000000] ACPI: FACP 3f4fc000 000F4 (v04 ACER   ACER     00000001 1025 01000013)
[    0.000000] ACPI: DSDT 3f4f2000 05DE6 (v01 ACER   ACER     00000001 1025 01000013)
[    0.000000] ACPI: FACS 3f488000 00040
[    0.000000] ACPI: SSDT 3f4fd000 004C4 (v02  PmRef    CpuPm 00003000 INTL 20051117)
[    0.000000] ACPI: HPET 3f4fb000 00038 (v01 ACER   ACER     00000001 1025 01000013)
[    0.000000] ACPI: APIC 3f4fa000 00068 (v02 ACER   ACER     00000001 1025 01000013)
[    0.000000] ACPI: MCFG 3f4f9000 0003C (v01 ACER   ACER     00000001 1025 01000013)
[    0.000000] ACPI: ASF! 3f4f8000 000A5 (v32 ACER   ACER     00000001 1025 01000013)
[    0.000000] ACPI: SLIC 3f4f1000 00180 (v01 ACER   ACER     00000001 1025 01000013)
[    0.000000] ACPI: BOOT 3f4f0000 00028 (v01 ACER   ACER     00000001 1025 01000013)
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] 121MB HIGHMEM available.
[    0.000000] 891MB LOWMEM available.
[    0.000000]   mapped low ram: 0 - 37bfe000
[    0.000000]   low ram: 0 - 37bfe000
[    0.000000] Zone PFN ranges:
[    0.000000]   DMA      0x00000010 -> 0x00001000
[    0.000000]   Normal   0x00001000 -> 0x00037bfe
[    0.000000]   HighMem  0x00037bfe -> 0x0003f500
[    0.000000] Movable zone start PFN for each node
[    0.000000] early_node_map[5] active PFN ranges
[    0.000000]     0: 0x00000010 -> 0x0000009f
[    0.000000]     0: 0x00000100 -> 0x0003f376
[    0.000000]     0: 0x0003f3bf -> 0x0003f46d
[    0.000000]     0: 0x0003f4bf -> 0x0003f4f0
[    0.000000]     0: 0x0003f4ff -> 0x0003f500
[    0.000000] On node 0 totalpages: 259045
[    0.000000] free_area_init_node: node 0, pgdat c1599d40, node_mem_map f740d200
[    0.000000]   DMA zone: 32 pages used for memmap
[    0.000000]   DMA zone: 0 pages reserved
[    0.000000]   DMA zone: 3951 pages, LIFO batch:0
[    0.000000]   Normal zone: 1752 pages used for memmap
[    0.000000]   Normal zone: 222502 pages, LIFO batch:31
[    0.000000]   HighMem zone: 243 pages used for memmap
[    0.000000]   HighMem zone: 30565 pages, LIFO batch:7
[    0.000000] Using APIC driver default
[    0.000000] ACPI: PM-Timer IO Port: 0x408
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] ACPI: LAPIC (acpi_id[0x01] lapic_id[0x00] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x02] lapic_id[0x01] enabled)
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x01] high edge lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x02] high edge lint[0x1])
[    0.000000] ACPI: IOAPIC (id[0x04] address[0xfec00000] gsi_base[0])
[    0.000000] IOAPIC[0]: apic_id 4, version 32, address 0xfec00000, GSI 0-23
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
[    0.000000] ACPI: IRQ0 used by override.
[    0.000000] ACPI: IRQ2 used by override.
[    0.000000] ACPI: IRQ9 used by override.
[    0.000000] Using ACPI (MADT) for SMP configuration information
[    0.000000] ACPI: HPET id: 0x8086a201 base: 0xfed00000
[    0.000000] SMP: Allowing 2 CPUs, 0 hotplug CPUs
[    0.000000] nr_irqs_gsi: 40
[    0.000000] PM: Registered nosave memory: 000000000009f000 - 00000000000a0000
[    0.000000] PM: Registered nosave memory: 00000000000a0000 - 00000000000e0000
[    0.000000] PM: Registered nosave memory: 00000000000e0000 - 0000000000100000
[    0.000000] Allocating PCI resources starting at 40000000 (gap: 40000000:a0000000)
[    0.000000] setup_percpu: NR_CPUS:2 nr_cpumask_bits:2 nr_cpu_ids:2 nr_node_ids:1
[    0.000000] PERCPU: Embedded 13 pages/cpu @f7200000 s29696 r0 d23552 u1048576
[    0.000000] pcpu-alloc: s29696 r0 d23552 u1048576 alloc=1*2097152
[    0.000000] pcpu-alloc: [0] 0 1 
[    0.000000] Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 257018
[    0.000000] Kernel command line: BOOT_IMAGE=/vmlinuz-3.2.0-jk1-imqmq-fixmtrr-atom32 root=UUID=b72744a7-0167-4590-986d-f3bfe1f84689 ro rootfstype=ext4 lockd.nlm_udpport=4003 lockd.nlm_tcpport=4003 noquiet reboot=k zcache
[    0.000000] PID hash table entries: 4096 (order: 2, 16384 bytes)
[    0.000000] Dentry cache hash table entries: 131072 (order: 7, 524288 bytes)
[    0.000000] Inode-cache hash table entries: 65536 (order: 6, 262144 bytes)
[    0.000000] Initializing CPU#0
[    0.000000] Initializing HighMem for node 0 (00037bfe:0003f500)
[    0.000000] Memory: 1017924k/1037312k available (4006k kernel code, 18256k reserved, 1761k data, 404k init, 123232k highmem)
[    0.000000] virtual kernel memory layout:
[    0.000000]     fixmap  : 0xfff8f000 - 0xfffff000   ( 448 kB)
[    0.000000]     pkmap   : 0xffc00000 - 0xffe00000   (2048 kB)
[    0.000000]     vmalloc : 0xf83fe000 - 0xffbfe000   ( 120 MB)
[    0.000000]     lowmem  : 0xc0000000 - 0xf7bfe000   ( 891 MB)
[    0.000000]       .init : 0xc15a2000 - 0xc1607000   ( 404 kB)
[    0.000000]       .data : 0xc13e9ac5 - 0xc15a1fc0   (1761 kB)
[    0.000000]       .text : 0xc1000000 - 0xc13e9ac5   (4006 kB)
[    0.000000] Checking if this processor honours the WP bit even in supervisor mode...Ok.
[    0.000000] SLUB: Genslabs=15, HWalign=64, Order=0-3, MinObjects=0, CPUs=2, Nodes=1
[    0.000000] Preemptible hierarchical RCU implementation.
[    0.000000] NR_IRQS:2304 nr_irqs:512 16
[    0.000000] CPU 0 irqstacks, hard=f6c08000 soft=f6c0a000
[    0.000000] Console: colour VGA+ 80x25
[    0.000000] console [tty0] enabled
[    0.000000] hpet clockevent registered
[    0.000000] Fast TSC calibration using PIT
[    0.000000] Detected 1595.737 MHz processor.
[    0.003336] Calibrating delay loop (skipped), value calculated using timer frequency.. 3192.45 BogoMIPS (lpj=5319123)
[    0.003470] pid_max: default: 32768 minimum: 301
[    0.003611] Mount-cache hash table entries: 512
[    0.003911] Initializing cgroup subsys cpuacct
[    0.003985] Initializing cgroup subsys blkio
[    0.004093] Disabled fast string operations
[    0.004158] CPU: Physical Processor ID: 0
[    0.004219] CPU: Processor Core ID: 0
[    0.004280] mce: CPU supports 5 MCE banks
[    0.004352] CPU0: Thermal monitoring enabled (TM1)
[    0.004418] using mwait in idle threads.
[    0.004557] ACPI: Core revision 20110623
[    0.013434] Enabling APIC mode:  Flat.  Using 1 I/O APICs
[    0.013999] ..TIMER: vector=0x30 apic1=0 pin1=2 apic2=-1 pin2=-1
[    0.049462] CPU0: Intel(R) Atom(TM) CPU N270   @ 1.60GHz stepping 02
[    0.049997] Performance Events: PEBS fmt0+, Atom events, Intel PMU driver.
[    0.049997] ... version:                3
[    0.049997] ... bit width:              40
[    0.049997] ... generic registers:      2
[    0.049997] ... value mask:             000000ffffffffff
[    0.049997] ... max period:             000000007fffffff
[    0.049997] ... fixed-purpose events:   3
[    0.049997] ... event mask:             0000000700000003
[    0.086704] CPU 1 irqstacks, hard=f6c7e000 soft=f6c80000
[    0.086712] Booting Node   0, Processors  #1 Ok.
[    0.086815] smpboot cpu 1: start_ip = 9b000
[    0.006666] Initializing CPU#1
[    0.006666] Disabled fast string operations
[    0.183352] Brought up 2 CPUs
[    0.183534] Total of 2 processors activated (6385.42 BogoMIPS).
[    0.184035] PM: Registering ACPI NVS region at 3f46d000 (335872 bytes)
[    0.184035] RTC time: 10:34:39, date: 01/06/12
[    0.184035] NET: Registered protocol family 16
[    0.184035] ACPI: bus type pci registered
[    0.184035] PCI: MMCONFIG for domain 0000 [bus 00-ff] at [mem 0xe0000000-0xefffffff] (base 0xe0000000)
[    0.184035] PCI: MMCONFIG at [mem 0xe0000000-0xefffffff] reserved in E820
[    0.184035] PCI: Using MMCONFIG for extended config space
[    0.184035] PCI: Using configuration type 1 for base access
[    0.193414] bio: create slab <bio-0> at 0
[    0.193491] ACPI: Added _OSI(Module Device)
[    0.193491] ACPI: Added _OSI(Processor Device)
[    0.193517] ACPI: Added _OSI(3.0 _SCP Extensions)
[    0.193583] ACPI: Added _OSI(Processor Aggregator Device)
[    0.199704] ACPI: EC: Look up EC in DSDT
[    0.202855] ACPI: Executed 1 blocks of module-level executable AML code
[    0.206627] [Firmware Bug]: ACPI: BIOS _OSI(Linux) query ignored
[    0.207535] ACPI: SSDT 3f380c90 00239 (v02  PmRef  Cpu0Ist 00003000 INTL 20051117)
[    0.208457] ACPI: Dynamic OEM Table Load:
[    0.208587] ACPI: SSDT   (null) 00239 (v02  PmRef  Cpu0Ist 00003000 INTL 20051117)
[    0.208993] ACPI: SSDT 3f37fe10 001C7 (v02  PmRef  Cpu0Cst 00003001 INTL 20051117)
[    0.209871] ACPI: Dynamic OEM Table Load:
[    0.210101] ACPI: SSDT   (null) 001C7 (v02  PmRef  Cpu0Cst 00003001 INTL 20051117)
[    0.233893] ACPI: SSDT 3f380f10 000D0 (v02  PmRef  Cpu1Ist 00003000 INTL 20051117)
[    0.234794] ACPI: Dynamic OEM Table Load:
[    0.234924] ACPI: SSDT   (null) 000D0 (v02  PmRef  Cpu1Ist 00003000 INTL 20051117)
[    0.235325] ACPI: SSDT 3f37ef10 00083 (v02  PmRef  Cpu1Cst 00003000 INTL 20051117)
[    0.236207] ACPI: Dynamic OEM Table Load:
[    0.236337] ACPI: SSDT   (null) 00083 (v02  PmRef  Cpu1Cst 00003000 INTL 20051117)
[    0.261223] ACPI: Interpreter enabled
[    0.261295] ACPI: (supports S0 S3 S4 S5)
[    0.261533] ACPI: Using IOAPIC for interrupt routing
[    0.287028] ACPI: EC: GPE = 0x17, I/O: command/status = 0x66, data = 0x62
[    0.287048] ACPI: No dock devices found.
[    0.287114] HEST: Table not found.
[    0.287181] PCI: Using host bridge windows from ACPI; if necessary, use "pci=nocrs" and report a bug
[    0.288263] ACPI Error: [CAPB] Namespace lookup failure, AE_ALREADY_EXISTS (20110623/dsfield-143)
[    0.288462] ACPI Error: Method parse/execution failed [\_SB_.PCI0._OSC] (Node f6c25ca8), AE_ALREADY_EXISTS (20110623/psparse-536)
[    0.288702] ACPI: Marking method _OSC as Serialized because of AE_ALREADY_EXISTS error
[    0.290108] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-ff])
[    0.291569] pci_root PNP0A08:00: host bridge window [io  0x0000-0x0cf7]
[    0.291644] pci_root PNP0A08:00: host bridge window [io  0x0d00-0xffff]
[    0.291714] pci_root PNP0A08:00: host bridge window [mem 0x000a0000-0x000bffff]
[    0.291805] pci_root PNP0A08:00: host bridge window [mem 0x40000000-0xfebfffff]
[    0.291918] pci 0000:00:00.0: [8086:27ac] type 0 class 0x000600
[    0.292001] pci 0000:00:02.0: [8086:27ae] type 0 class 0x000300
[    0.292023] pci 0000:00:02.0: reg 10: [mem 0x58480000-0x584fffff]
[    0.292036] pci 0000:00:02.0: reg 14: [io  0x60c0-0x60c7]
[    0.293326] pci 0000:00:02.0: reg 18: [mem 0x40000000-0x4fffffff pref]
[    0.293338] pci 0000:00:02.0: reg 1c: [mem 0x58500000-0x5853ffff]
[    0.293399] pci 0000:00:02.1: [8086:27a6] type 0 class 0x000380
[    0.293416] pci 0000:00:02.1: reg 10: [mem 0x58400000-0x5847ffff]
[    0.293551] pci 0000:00:1b.0: [8086:27d8] type 0 class 0x000403
[    0.293583] pci 0000:00:1b.0: reg 10: [mem 0x58540000-0x58543fff 64bit]
[    0.293685] pci 0000:00:1b.0: PME# supported from D0 D3hot D3cold
[    0.293696] pci 0000:00:1b.0: PME# disabled
[    0.293739] pci 0000:00:1c.0: [8086:27d0] type 1 class 0x000604
[    0.293845] pci 0000:00:1c.0: PME# supported from D0 D3hot D3cold
[    0.293855] pci 0000:00:1c.0: PME# disabled
[    0.293901] pci 0000:00:1c.1: [8086:27d2] type 1 class 0x000604
[    0.294007] pci 0000:00:1c.1: PME# supported from D0 D3hot D3cold
[    0.294017] pci 0000:00:1c.1: PME# disabled
[    0.294063] pci 0000:00:1c.2: [8086:27d4] type 1 class 0x000604
[    0.294169] pci 0000:00:1c.2: PME# supported from D0 D3hot D3cold
[    0.294179] pci 0000:00:1c.2: PME# disabled
[    0.294225] pci 0000:00:1c.3: [8086:27d6] type 1 class 0x000604
[    0.294331] pci 0000:00:1c.3: PME# supported from D0 D3hot D3cold
[    0.294341] pci 0000:00:1c.3: PME# disabled
[    0.294388] pci 0000:00:1d.0: [8086:27c8] type 0 class 0x000c03
[    0.294457] pci 0000:00:1d.0: reg 20: [io  0x6080-0x609f]
[    0.294514] pci 0000:00:1d.1: [8086:27c9] type 0 class 0x000c03
[    0.294584] pci 0000:00:1d.1: reg 20: [io  0x6060-0x607f]
[    0.294640] pci 0000:00:1d.2: [8086:27ca] type 0 class 0x000c03
[    0.294710] pci 0000:00:1d.2: reg 20: [io  0x6040-0x605f]
[    0.294766] pci 0000:00:1d.3: [8086:27cb] type 0 class 0x000c03
[    0.294836] pci 0000:00:1d.3: reg 20: [io  0x6020-0x603f]
[    0.294906] pci 0000:00:1d.7: [8086:27cc] type 0 class 0x000c03
[    0.294938] pci 0000:00:1d.7: reg 10: [mem 0x58544400-0x585447ff]
[    0.295047] pci 0000:00:1d.7: PME# supported from D0 D3hot D3cold
[    0.295057] pci 0000:00:1d.7: PME# disabled
[    0.295092] pci 0000:00:1e.0: [8086:2448] type 1 class 0x000604
[    0.295202] pci 0000:00:1f.0: [8086:27b9] type 0 class 0x000601
[    0.295347] pci 0000:00:1f.0: ICH7 LPC Generic IO decode 4 PIO at 0068 (mask 0007)
[    0.295500] pci 0000:00:1f.2: [8086:27c4] type 0 class 0x000101
[    0.295530] pci 0000:00:1f.2: reg 10: [io  0x0000-0x0007]
[    0.295548] pci 0000:00:1f.2: reg 14: [io  0x0000-0x0003]
[    0.295566] pci 0000:00:1f.2: reg 18: [io  0x0000-0x0007]
[    0.295584] pci 0000:00:1f.2: reg 1c: [io  0x0000-0x0003]
[    0.295602] pci 0000:00:1f.2: reg 20: [io  0x60a0-0x60af]
[    0.295659] pci 0000:00:1f.2: PME# supported from D3hot
[    0.295669] pci 0000:00:1f.2: PME# disabled
[    0.295698] pci 0000:00:1f.3: [8086:27da] type 0 class 0x000c05
[    0.295785] pci 0000:00:1f.3: reg 20: [io  0x6000-0x601f]
[    0.295917] pci 0000:00:1c.0: PCI bridge to [bus 01-01]
[    0.295987] pci 0000:00:1c.0:   bridge window [io  0x5000-0x5fff]
[    0.295997] pci 0000:00:1c.0:   bridge window [mem 0x57300000-0x583fffff]
[    0.296011] pci 0000:00:1c.0:   bridge window [mem 0x50000000-0x50ffffff 64bit pref]
[    0.296121] pci 0000:02:00.0: [10ec:8136] type 0 class 0x000200
[    0.296152] pci 0000:02:00.0: reg 10: [io  0x3000-0x30ff]
[    0.296200] pci 0000:02:00.0: reg 18: [mem 0x51010000-0x51010fff 64bit pref]
[    0.296233] pci 0000:02:00.0: reg 20: [mem 0x51000000-0x5100ffff 64bit pref]
[    0.296256] pci 0000:02:00.0: reg 30: [mem 0xfffe0000-0xffffffff pref]
[    0.296323] pci 0000:02:00.0: supports D1 D2
[    0.296329] pci 0000:02:00.0: PME# supported from D0 D1 D2 D3hot D3cold
[    0.296339] pci 0000:02:00.0: PME# disabled
[    0.300031] pci 0000:00:1c.1: PCI bridge to [bus 02-02]
[    0.300105] pci 0000:00:1c.1:   bridge window [io  0x3000-0x4fff]
[    0.300116] pci 0000:00:1c.1:   bridge window [mem 0x56300000-0x572fffff]
[    0.300130] pci 0000:00:1c.1:   bridge window [mem 0x51000000-0x520fffff 64bit pref]
[    0.300265] pci 0000:03:00.0: [168c:001c] type 0 class 0x000200
[    0.300327] pci 0000:03:00.0: reg 10: [mem 0x55200000-0x5520ffff 64bit]
[    0.300613] pci 0000:03:00.0: disabling ASPM on pre-1.1 PCIe device.  You can enable it with 'pcie_aspm=force'
[    0.300728] pci 0000:00:1c.2: PCI bridge to [bus 03-03]
[    0.300798] pci 0000:00:1c.2:   bridge window [io  0x2000-0x2fff]
[    0.300808] pci 0000:00:1c.2:   bridge window [mem 0x55200000-0x562fffff]
[    0.300822] pci 0000:00:1c.2:   bridge window [mem 0x52100000-0x530fffff 64bit pref]
[    0.300900] pci 0000:00:1c.3: PCI bridge to [bus 04-04]
[    0.300969] pci 0000:00:1c.3:   bridge window [io  0x1000-0x1fff]
[    0.300979] pci 0000:00:1c.3:   bridge window [mem 0x54100000-0x551fffff]
[    0.300993] pci 0000:00:1c.3:   bridge window [mem 0x53100000-0x540fffff 64bit pref]
[    0.301100] pci 0000:00:1e.0: PCI bridge to [bus 05-05] (subtractive decode)
[    0.301187] pci 0000:00:1e.0:   bridge window [io  0x0000-0x0cf7] (subtractive decode)
[    0.301194] pci 0000:00:1e.0:   bridge window [io  0x0d00-0xffff] (subtractive decode)
[    0.301202] pci 0000:00:1e.0:   bridge window [mem 0x000a0000-0x000bffff] (subtractive decode)
[    0.301209] pci 0000:00:1e.0:   bridge window [mem 0x40000000-0xfebfffff] (subtractive decode)
[    0.301253] pci_bus 0000:00: on NUMA node 0
[    0.301265] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0._PRT]
[    0.301575] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.P32_._PRT]
[    0.301826] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.EXP1._PRT]
[    0.301986] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.EXP2._PRT]
[    0.302116] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.EXP3._PRT]
[    0.302245] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.EXP4._PRT]
[    0.302589] ACPI Error: [CAPB] Namespace lookup failure, AE_ALREADY_EXISTS (20110623/dsfield-143)
[    0.302789] ACPI Error: Method parse/execution failed [\_SB_.PCI0._OSC] (Node f6c25ca8), AE_ALREADY_EXISTS (20110623/psparse-536)
[    0.303038]  pci0000:00: Requesting ACPI _OSC control (0x1d)
[    0.303247] ACPI Error: [CAPB] Namespace lookup failure, AE_ALREADY_EXISTS (20110623/dsfield-143)
[    0.303471] ACPI Error: Method parse/execution failed [\_SB_.PCI0._OSC] (Node f6c25ca8), AE_ALREADY_EXISTS (20110623/psparse-536)
[    0.303720]  pci0000:00: ACPI _OSC request failed (AE_ALREADY_EXISTS), returned control mask: 0x1d
[    0.303812] ACPI _OSC control for PCIe not granted, disabling ASPM
[    0.313842] ACPI: PCI Interrupt Link [LNKA] (IRQs 3 4 5 7 9 10 *11 12)
[    0.314057] ACPI: PCI Interrupt Link [LNKB] (IRQs 3 4 5 7 9 10 *11 12)
[    0.314595] ACPI: PCI Interrupt Link [LNKC] (IRQs 3 4 5 7 9 10 *11 12)
[    0.316782] ACPI: PCI Interrupt Link [LNKD] (IRQs 3 4 5 7 9 10 *11 12)
[    0.317322] ACPI: PCI Interrupt Link [LNKE] (IRQs 3 4 5 7 9 10 11 12) *0, disabled.
[    0.317946] ACPI: PCI Interrupt Link [LNKF] (IRQs 3 4 5 7 9 10 11 12) *0, disabled.
[    0.318567] ACPI: PCI Interrupt Link [LNKG] (IRQs 3 4 5 7 9 10 11 12) *0, disabled.
[    0.319188] ACPI: PCI Interrupt Link [LNKH] (IRQs 3 4 5 7 9 10 11 12) *0, disabled.
[    0.320096] vgaarb: device added: PCI:0000:00:02.0,decodes=io+mem,owns=io+mem,locks=none
[    0.320146] vgaarb: loaded
[    0.320205] vgaarb: bridge control possible 0000:00:02.0
[    0.320455] SCSI subsystem initialized
[    0.320455] libata version 3.00 loaded.
[    0.323463] wmi: Mapper loaded
[    0.323463] PCI: Using ACPI for IRQ routing
[    0.335902] PCI: pci_cache_line_size set to 64 bytes
[    0.336054] reserve RAM buffer: 000000000009fc00 - 000000000009ffff 
[    0.336062] reserve RAM buffer: 000000003f376000 - 000000003fffffff 
[    0.336071] reserve RAM buffer: 000000003f46d000 - 000000003fffffff 
[    0.336078] reserve RAM buffer: 000000003f4f0000 - 000000003fffffff 
[    0.336085] reserve RAM buffer: 000000003f500000 - 000000003fffffff 
[    0.336723] HPET: 3 timers in total, 0 timers will be used for per-cpu timer
[    0.336807] hpet0: at MMIO 0xfed00000, IRQs 2, 8, 0
[    0.337006] hpet0: 3 comparators, 64-bit 14.318180 MHz counter
[    0.346763] Switching to clocksource hpet
[    0.352271] pnp: PnP ACPI init
[    0.352379] ACPI: bus type pnp registered
[    0.353416] pnp 00:00: [bus 00-ff]
[    0.353424] pnp 00:00: [io  0x0000-0x0cf7 window]
[    0.353431] pnp 00:00: [io  0x0cf8-0x0cff]
[    0.353437] pnp 00:00: [io  0x0d00-0xffff window]
[    0.353444] pnp 00:00: [mem 0x000a0000-0x000bffff window]
[    0.353451] pnp 00:00: [mem 0x000c0000-0x000c3fff window]
[    0.353457] pnp 00:00: [mem 0x000c4000-0x000c7fff window]
[    0.353464] pnp 00:00: [mem 0x000c8000-0x000cbfff window]
[    0.353470] pnp 00:00: [mem 0x000cc000-0x000cffff window]
[    0.353477] pnp 00:00: [mem 0x000d0000-0x000d3fff window]
[    0.353483] pnp 00:00: [mem 0x000d4000-0x000d7fff window]
[    0.353490] pnp 00:00: [mem 0x000d8000-0x000dbfff window]
[    0.353496] pnp 00:00: [mem 0x000dc000-0x000dffff window]
[    0.353502] pnp 00:00: [mem 0x000e0000-0x000e3fff window]
[    0.353509] pnp 00:00: [mem 0x000e4000-0x000e7fff window]
[    0.353515] pnp 00:00: [mem 0x000e8000-0x000ebfff window]
[    0.353522] pnp 00:00: [mem 0x000ec000-0x000effff window]
[    0.353528] pnp 00:00: [mem 0x000f0000-0x000fffff window]
[    0.353535] pnp 00:00: [mem 0x40000000-0xfebfffff window]
[    0.353811] pnp 00:00: Plug and Play ACPI device, IDs PNP0a08 PNP0a03 (active)
[    0.354153] pnp 00:01: [io  0x002e-0x002f]
[    0.354161] pnp 00:01: [io  0x0068-0x006f]
[    0.354167] pnp 00:01: [io  0x0200-0x020f]
[    0.354173] pnp 00:01: [io  0x164e-0x164f]
[    0.354178] pnp 00:01: [io  0x0061]
[    0.354183] pnp 00:01: [io  0x0070]
[    0.354189] pnp 00:01: [io  0x0080]
[    0.354194] pnp 00:01: [io  0x0092]
[    0.354199] pnp 00:01: [io  0x00b2-0x00b3]
[    0.354205] pnp 00:01: [io  0x0063]
[    0.354210] pnp 00:01: [io  0x0065]
[    0.354216] pnp 00:01: [io  0x0067]
[    0.354221] pnp 00:01: [io  0x0600-0x060f]
[    0.354227] pnp 00:01: [io  0x0610]
[    0.354232] pnp 00:01: [io  0x0800-0x080f]
[    0.354242] pnp 00:01: [io  0x0400-0x047f]
[    0.354248] pnp 00:01: [io  0x0500-0x053f]
[    0.354254] pnp 00:01: [mem 0xe0000000-0xefffffff]
[    0.354261] pnp 00:01: [mem 0xfed1c000-0xfed1ffff]
[    0.354267] pnp 00:01: [mem 0xfed14000-0xfed17fff]
[    0.354273] pnp 00:01: [mem 0xfed18000-0xfed18fff]
[    0.354279] pnp 00:01: [mem 0xfed19000-0xfed19fff]
[    0.354285] pnp 00:01: [mem 0xfec00000-0xfec00fff]
[    0.354290] pnp 00:01: [mem 0xfee00000-0xfee00fff]
[    0.354339] pnp 00:01: disabling [io  0x164e-0x164f] because it overlaps 0000:00:1c.3 BAR 13 [io  0x1000-0x1fff]
[    0.354691] system 00:01: [io  0x0200-0x020f] has been reserved
[    0.354764] system 00:01: [io  0x0600-0x060f] has been reserved
[    0.354834] system 00:01: [io  0x0610] has been reserved
[    0.354902] system 00:01: [io  0x0800-0x080f] has been reserved
[    0.354972] system 00:01: [io  0x0400-0x047f] has been reserved
[    0.355042] system 00:01: [io  0x0500-0x053f] has been reserved
[    0.355113] system 00:01: [mem 0xe0000000-0xefffffff] has been reserved
[    0.355185] system 00:01: [mem 0xfed1c000-0xfed1ffff] has been reserved
[    0.355255] system 00:01: [mem 0xfed14000-0xfed17fff] has been reserved
[    0.355327] system 00:01: [mem 0xfed18000-0xfed18fff] has been reserved
[    0.355398] system 00:01: [mem 0xfed19000-0xfed19fff] has been reserved
[    0.355469] system 00:01: [mem 0xfec00000-0xfec00fff] could not be reserved
[    0.355541] system 00:01: [mem 0xfee00000-0xfee00fff] has been reserved
[    0.355616] system 00:01: Plug and Play ACPI device, IDs PNP0c02 (active)
[    0.355651] pnp 00:02: [io  0x0000-0x001f]
[    0.355658] pnp 00:02: [io  0x0081-0x0091]
[    0.355663] pnp 00:02: [io  0x0093-0x009f]
[    0.355669] pnp 00:02: [io  0x00c0-0x00df]
[    0.355675] pnp 00:02: [dma 4]
[    0.355861] pnp 00:02: Plug and Play ACPI device, IDs PNP0200 (active)
[    0.355942] pnp 00:03: [io  0x0070-0x0077]
[    0.356121] pnp 00:03: Plug and Play ACPI device, IDs PNP0b00 (active)
[    0.356296] pnp 00:04: [irq 0 disabled]
[    0.356319] pnp 00:04: [irq 8]
[    0.356325] pnp 00:04: [mem 0xfed00000-0xfed003ff]
[    0.356512] pnp 00:04: Plug and Play ACPI device, IDs PNP0103 (active)
[    0.356549] pnp 00:05: [io  0x00f0]
[    0.356563] pnp 00:05: [irq 13]
[    0.356778] pnp 00:05: Plug and Play ACPI device, IDs PNP0c04 (active)
[    0.356815] pnp 00:06: [mem 0xff800000-0xffffffff]
[    0.356994] pnp 00:06: Plug and Play ACPI device, IDs INT0800 (active)
[    0.357049] pnp 00:07: [io  0x0060]
[    0.357056] pnp 00:07: [io  0x0064]
[    0.357072] pnp 00:07: [irq 1]
[    0.357251] pnp 00:07: Plug and Play ACPI device, IDs PNP0303 (active)
[    0.357310] pnp 00:08: [irq 12]
[    0.357489] pnp 00:08: Plug and Play ACPI device, IDs PNP0f13 (active)
[    0.357710] pnp: PnP ACPI: found 9 devices
[    0.357778] ACPI: ACPI bus type pnp unregistered
[    0.403832] pci 0000:02:00.0: no compatible bridge window for [mem 0xfffe0000-0xffffffff pref]
[    0.403936] PCI: max bus depth: 1 pci_try_num: 2
[    0.404013] pci 0000:00:1c.0: PCI bridge to [bus 01-01]
[    0.404083] pci 0000:00:1c.0:   bridge window [io  0x5000-0x5fff]
[    0.404158] pci 0000:00:1c.0:   bridge window [mem 0x57300000-0x583fffff]
[    0.404233] pci 0000:00:1c.0:   bridge window [mem 0x50000000-0x50ffffff 64bit pref]
[    0.404337] pci 0000:02:00.0: BAR 6: assigned [mem 0x51020000-0x5103ffff pref]
[    0.404426] pci 0000:00:1c.1: PCI bridge to [bus 02-02]
[    0.404495] pci 0000:00:1c.1:   bridge window [io  0x3000-0x4fff]
[    0.404569] pci 0000:00:1c.1:   bridge window [mem 0x56300000-0x572fffff]
[    0.404643] pci 0000:00:1c.1:   bridge window [mem 0x51000000-0x520fffff 64bit pref]
[    0.404741] pci 0000:00:1c.2: PCI bridge to [bus 03-03]
[    0.404809] pci 0000:00:1c.2:   bridge window [io  0x2000-0x2fff]
[    0.404884] pci 0000:00:1c.2:   bridge window [mem 0x55200000-0x562fffff]
[    0.404958] pci 0000:00:1c.2:   bridge window [mem 0x52100000-0x530fffff 64bit pref]
[    0.405055] pci 0000:00:1c.3: PCI bridge to [bus 04-04]
[    0.405123] pci 0000:00:1c.3:   bridge window [io  0x1000-0x1fff]
[    0.405196] pci 0000:00:1c.3:   bridge window [mem 0x54100000-0x551fffff]
[    0.405271] pci 0000:00:1c.3:   bridge window [mem 0x53100000-0x540fffff 64bit pref]
[    0.405367] pci 0000:00:1e.0: PCI bridge to [bus 05-05]
[    0.405487] pci 0000:00:1c.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
[    0.405564] pci 0000:00:1c.0: setting latency timer to 64
[    0.405589] pci 0000:00:1c.1: PCI INT B -> GSI 17 (level, low) -> IRQ 17
[    0.405664] pci 0000:00:1c.1: setting latency timer to 64
[    0.405688] pci 0000:00:1c.2: PCI INT C -> GSI 18 (level, low) -> IRQ 18
[    0.405761] pci 0000:00:1c.2: setting latency timer to 64
[    0.405785] pci 0000:00:1c.3: PCI INT D -> GSI 19 (level, low) -> IRQ 19
[    0.405859] pci 0000:00:1c.3: setting latency timer to 64
[    0.405875] pci 0000:00:1e.0: setting latency timer to 64
[    0.405885] pci_bus 0000:00: resource 4 [io  0x0000-0x0cf7]
[    0.405891] pci_bus 0000:00: resource 5 [io  0x0d00-0xffff]
[    0.405898] pci_bus 0000:00: resource 6 [mem 0x000a0000-0x000bffff]
[    0.405905] pci_bus 0000:00: resource 7 [mem 0x40000000-0xfebfffff]
[    0.405914] pci_bus 0000:01: resource 0 [io  0x5000-0x5fff]
[    0.405920] pci_bus 0000:01: resource 1 [mem 0x57300000-0x583fffff]
[    0.405927] pci_bus 0000:01: resource 2 [mem 0x50000000-0x50ffffff 64bit pref]
[    0.405935] pci_bus 0000:02: resource 0 [io  0x3000-0x4fff]
[    0.405941] pci_bus 0000:02: resource 1 [mem 0x56300000-0x572fffff]
[    0.405948] pci_bus 0000:02: resource 2 [mem 0x51000000-0x520fffff 64bit pref]
[    0.405955] pci_bus 0000:03: resource 0 [io  0x2000-0x2fff]
[    0.405962] pci_bus 0000:03: resource 1 [mem 0x55200000-0x562fffff]
[    0.405969] pci_bus 0000:03: resource 2 [mem 0x52100000-0x530fffff 64bit pref]
[    0.405976] pci_bus 0000:04: resource 0 [io  0x1000-0x1fff]
[    0.405983] pci_bus 0000:04: resource 1 [mem 0x54100000-0x551fffff]
[    0.405990] pci_bus 0000:04: resource 2 [mem 0x53100000-0x540fffff 64bit pref]
[    0.405997] pci_bus 0000:05: resource 4 [io  0x0000-0x0cf7]
[    0.406004] pci_bus 0000:05: resource 5 [io  0x0d00-0xffff]
[    0.406010] pci_bus 0000:05: resource 6 [mem 0x000a0000-0x000bffff]
[    0.406017] pci_bus 0000:05: resource 7 [mem 0x40000000-0xfebfffff]
[    0.406079] NET: Registered protocol family 2
[    0.406226] IP route cache hash table entries: 32768 (order: 5, 131072 bytes)
[    0.406586] TCP established hash table entries: 131072 (order: 8, 1048576 bytes)
[    0.407698] TCP bind hash table entries: 65536 (order: 7, 524288 bytes)
[    0.408227] TCP: Hash tables configured (established 131072 bind 65536)
[    0.408299] TCP reno registered
[    0.408366] UDP hash table entries: 512 (order: 2, 16384 bytes)
[    0.408450] UDP-Lite hash table entries: 512 (order: 2, 16384 bytes)
[    0.408704] NET: Registered protocol family 1
[    0.408819] pci 0000:00:02.0: Boot video device
[    0.409120] PCI: CLS 0 bytes, default 64
[    0.409273] Trying to unpack rootfs image as initramfs...
[    1.566772] Freeing initrd memory: 2420k freed
[    1.569104] Simple Boot Flag value 0x5 read from CMOS RAM was invalid
[    1.569177] Simple Boot Flag at 0x44 set to 0x1
[    1.571842] audit: initializing netlink socket (disabled)
[    1.571934] type=2000 audit(1325846079.569:1): initialized
[    1.609608] highmem bounce pool size: 64 pages
[    1.609686] HugeTLB registered 2 MB page size, pre-allocated 0 pages
[    1.626137] VFS: Disk quotas dquot_6.5.2
[    1.626420] Dquot-cache hash table entries: 1024 (order 0, 4096 bytes)
[    1.628626] fuse init (API version 7.17)
[    1.629185] msgmni has been set to 1752
[    1.630120] Block layer SCSI generic (bsg) driver version 0.4 loaded (major 253)
[    1.630272] io scheduler noop registered
[    1.630339] io scheduler deadline registered
[    1.630424] io scheduler cfq registered (default)
[    1.630769] pcieport 0000:00:1c.0: setting latency timer to 64
[    1.630853] pcieport 0000:00:1c.0: irq 40 for MSI/MSI-X
[    1.631072] pcieport 0000:00:1c.1: setting latency timer to 64
[    1.631149] pcieport 0000:00:1c.1: irq 41 for MSI/MSI-X
[    1.631361] pcieport 0000:00:1c.2: setting latency timer to 64
[    1.631436] pcieport 0000:00:1c.2: irq 42 for MSI/MSI-X
[    1.631646] pcieport 0000:00:1c.3: setting latency timer to 64
[    1.631721] pcieport 0000:00:1c.3: irq 43 for MSI/MSI-X
[    1.632346] intel_idle: MWAIT substates: 0x20220
[    1.632367] intel_idle: v0.4 model 0x1C
[    1.632372] intel_idle: lapic_timer_reliable_states 0x2
[    1.632378] Marking TSC unstable due to TSC halts in idle states deeper than C2
[    1.632898] input: Power Button as /devices/LNXSYSTM:00/device:00/PNP0C0C:00/input/input0
[    1.632997] ACPI: Power Button [PWRB]
[    1.633271] input: Lid Switch as /devices/LNXSYSTM:00/device:00/PNP0C0D:00/input/input1
[    1.633955] ACPI: Lid Switch [LID0]
[    1.634283] input: Sleep Button as /devices/LNXSYSTM:00/device:00/PNP0C0E:00/input/input2
[    1.634382] ACPI: Sleep Button [SLPB]
[    1.634692] input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/input/input3
[    1.634787] ACPI: Power Button [PWRF]
[    1.634964] ERST: Table is not found!
[    1.704225] Serial: 8250/16550 driver, 4 ports, IRQ sharing enabled
[    1.780716] brd: module loaded
[    1.784122] loop: module loaded
[    1.784622] ata_piix 0000:00:1f.2: version 2.13
[    1.784655] ata_piix 0000:00:1f.2: PCI INT B -> GSI 17 (level, low) -> IRQ 17
[    1.784735] ata_piix 0000:00:1f.2: MAP [ P0 P2 IDE IDE ]
[    1.785001] ata_piix 0000:00:1f.2: setting latency timer to 64
[    1.786462] scsi0 : ata_piix
[    1.786922] scsi1 : ata_piix
[    1.788734] ata1: SATA max UDMA/133 cmd 0x1f0 ctl 0x3f6 bmdma 0x60a0 irq 14
[    1.788809] ata2: PATA max UDMA/100 cmd 0x170 ctl 0x376 bmdma 0x60a8 irq 15
[    1.789301] tun: Universal TUN/TAP device driver, 1.6
[    1.789369] tun: (C) 1999-2004 Max Krasnyansky <maxk@qualcomm.com>
[    1.789616] r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
[    1.789723] r8169 0000:02:00.0: PCI INT A -> GSI 17 (level, low) -> IRQ 17
[    1.789849] r8169 0000:02:00.0: setting latency timer to 64
[    1.789944] r8169 0000:02:00.0: irq 44 for MSI/MSI-X
[    1.790492] r8169 0000:02:00.0: eth0: RTL8102e at 0xf841c000, yy:yy:yy:yy:yy:yy, XID 04a00000 IRQ 44
[    1.790999] i8042: PNP: PS/2 Controller [PNP0303:KBC,PNP0f13:MOUE] at 0x60,0x64 irq 1,12
[    1.792180] i8042: Warning: Keylock active
[    1.802024] i8042: Detected active multiplexing controller, rev 1.1
[    1.807648] serio: i8042 KBD port at 0x60,0x64 irq 1
[    1.807809] serio: i8042 AUX0 port at 0x60,0x64 irq 12
[    1.808026] serio: i8042 AUX1 port at 0x60,0x64 irq 12
[    1.808197] serio: i8042 AUX2 port at 0x60,0x64 irq 12
[    1.808356] serio: i8042 AUX3 port at 0x60,0x64 irq 12
[    1.809065] mousedev: PS/2 mouse device common for all mice
[    1.809991] input: PC Speaker as /devices/platform/pcspkr/input/input4
[    1.810397] rtc_cmos 00:03: RTC can wake from S4
[    1.810735] rtc_cmos 00:03: rtc core: registered rtc_cmos as rtc0
[    1.810854] rtc0: alarms up to one month, 242 bytes nvram, hpet irqs
[    1.811387] device-mapper: ioctl: 4.22.0-ioctl (2011-10-19) initialised: dm-devel@redhat.com
[    1.812329] cpuidle: using governor ladder
[    1.814056] cpuidle: using governor menu
[    1.814124] EFI Variables Facility v0.08 2004-May-17
[    1.814236] nf_conntrack version 0.5.0 (15942 buckets, 63768 max)
[    1.815005] ip_tables: (C) 2000-2006 Netfilter Core Team
[    1.815126] TCP cubic registered
[    1.816078] NET: Registered protocol family 10
[    1.816567] ip6_tables: (C) 2000-2006 Netfilter Core Team
[    1.817840] NET: Registered protocol family 17
[    1.817915] lib80211: common routines for IEEE802.11 drivers
[    1.817983] lib80211_crypt: registered algorithm 'NULL'
[    1.817988] Registering the dns_resolver key type
[    1.818091] Using IPI No-Shortcut mode
[    1.818671] PM: Hibernation image not present or could not be loaded.
[    1.818702] registered taskstats version 1
[    1.822202]   Magic number: 12:506:577
[    1.822361] tty ptyb9: hash matches
[    1.822589] rtc_cmos 00:03: setting system clock to 2012-01-06 10:34:40 UTC (1325846080)
[    1.822684] BIOS EDD facility v0.16 2004-Jun-25, 0 devices found
[    1.822751] EDD information not available.
[    1.833660] input: AT Translated Set 2 keyboard as /devices/platform/i8042/serio0/input/input5
[    1.996077] ata1.00: ATA-8: WDC WD1200BEVS-22UST0, 01.01A01, max UDMA/133
[    1.996174] ata1.00: 234441648 sectors, multi 16: LBA48 NCQ (depth 0/32)
[    2.007850] ata1.00: configured for UDMA/133
[    2.008281] scsi 0:0:0:0: Direct-Access     ATA      WDC WD1200BEVS-2 01.0 PQ: 0 ANSI: 5
[    2.009138] sd 0:0:0:0: [sda] 234441648 512-byte logical blocks: (120 GB/111 GiB)
[    2.009449] sd 0:0:0:0: [sda] Write Protect is off
[    2.009486] sd 0:0:0:0: Attached scsi generic sg0 type 0
[    2.009591] sd 0:0:0:0: [sda] Mode Sense: 00 3a 00 00
[    2.009675] sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[    2.023477]  sda: sda1 sda2 sda3
[    2.024832] sd 0:0:0:0: [sda] Attached SCSI disk
[    2.025049] Freeing unused kernel memory: 404k freed
[    2.025524] Write protecting the kernel text: 4008k
[    2.025695] Write protecting the kernel read-only data: 1528k
[    2.025764] NX-protecting the kernel data: 4184k
[    2.308896] usbcore: registered new interface driver usbfs
[    2.309041] usbcore: registered new interface driver hub
[    2.313472] usbcore: registered new device driver usb
[    2.315274] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
[    2.315432] ehci_hcd 0000:00:1d.7: PCI INT A -> GSI 16 (level, low) -> IRQ 16
[    2.315567] ehci_hcd 0000:00:1d.7: setting latency timer to 64
[    2.315581] ehci_hcd 0000:00:1d.7: EHCI Host Controller
[    2.315749] ehci_hcd 0000:00:1d.7: new USB bus registered, assigned bus number 1
[    2.315905] ehci_hcd 0000:00:1d.7: using broken periodic workaround
[    2.316005] ehci_hcd 0000:00:1d.7: debug port 1
[    2.332637] ehci_hcd 0000:00:1d.7: cache line size of 64 is not supported
[    2.332699] ehci_hcd 0000:00:1d.7: irq 16, io mem 0x58544400
[    2.366746] ehci_hcd 0000:00:1d.7: USB 2.0 started, EHCI 1.00
[    2.367281] hub 1-0:1.0: USB hub found
[    2.367371] hub 1-0:1.0: 8 ports detected
[    2.369400] uhci_hcd: USB Universal Host Controller Interface driver
[    2.369580] uhci_hcd 0000:00:1d.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
[    2.369684] uhci_hcd 0000:00:1d.0: setting latency timer to 64
[    2.369696] uhci_hcd 0000:00:1d.0: UHCI Host Controller
[    2.369802] uhci_hcd 0000:00:1d.0: new USB bus registered, assigned bus number 2
[    2.371254] uhci_hcd 0000:00:1d.0: irq 16, io base 0x00006080
[    2.371814] hub 2-0:1.0: USB hub found
[    2.371903] hub 2-0:1.0: 2 ports detected
[    2.372237] uhci_hcd 0000:00:1d.1: PCI INT B -> GSI 17 (level, low) -> IRQ 17
[    2.372340] uhci_hcd 0000:00:1d.1: setting latency timer to 64
[    2.372352] uhci_hcd 0000:00:1d.1: UHCI Host Controller
[    2.372468] uhci_hcd 0000:00:1d.1: new USB bus registered, assigned bus number 3
[    2.372660] uhci_hcd 0000:00:1d.1: irq 17, io base 0x00006060
[    2.373212] hub 3-0:1.0: USB hub found
[    2.373302] hub 3-0:1.0: 2 ports detected
[    2.374064] uhci_hcd 0000:00:1d.2: PCI INT C -> GSI 18 (level, low) -> IRQ 18
[    2.374168] uhci_hcd 0000:00:1d.2: setting latency timer to 64
[    2.374180] uhci_hcd 0000:00:1d.2: UHCI Host Controller
[    2.374283] uhci_hcd 0000:00:1d.2: new USB bus registered, assigned bus number 4
[    2.374473] uhci_hcd 0000:00:1d.2: irq 18, io base 0x00006040
[    2.375052] hub 4-0:1.0: USB hub found
[    2.375139] hub 4-0:1.0: 2 ports detected
[    2.375488] uhci_hcd 0000:00:1d.3: PCI INT D -> GSI 19 (level, low) -> IRQ 19
[    2.375592] uhci_hcd 0000:00:1d.3: setting latency timer to 64
[    2.375605] uhci_hcd 0000:00:1d.3: UHCI Host Controller
[    2.375712] uhci_hcd 0000:00:1d.3: new USB bus registered, assigned bus number 5
[    2.375901] uhci_hcd 0000:00:1d.3: irq 19, io base 0x00006020
[    2.376456] hub 5-0:1.0: USB hub found
[    2.376548] hub 5-0:1.0: 2 ports detected
[    2.673433] usb 1-1: new high-speed USB device number 2 using ehci_hcd
[    2.916812] usb 1-5: new high-speed USB device number 3 using ehci_hcd
[    3.606046] EXT4-fs (sda3): mounted filesystem with ordered data mode. Opts: (null)
[    5.490999] udev[1420]: starting version 164
[    5.975585] ACPI: Deprecated procfs I/F for battery is loaded, please retry with CONFIG_ACPI_PROCFS_POWER cleared
[    5.975717] ACPI: Battery Slot [BAT1] (battery present)
[    6.133969] ACPI: Deprecated procfs I/F for AC is loaded, please retry with CONFIG_ACPI_PROCFS_POWER cleared
[    6.135177] ACPI: AC Adapter [ACAD] (on-line)
[    6.287334] i801_smbus 0000:00:1f.3: PCI INT B -> GSI 17 (level, low) -> IRQ 17
[    6.331887] Linux agpgart interface v0.103
[    6.407795] Linux video capture interface: v2.00
[    6.590396] agpgart-intel 0000:00:00.0: Intel 945GME Chipset
[    6.592213] agpgart-intel 0000:00:00.0: detected gtt size: 262144K total, 262144K mappable
[    6.592559] agpgart-intel 0000:00:00.0: detected 8192K stolen memory
[    6.593028] agpgart-intel 0000:00:00.0: AGP aperture is 256M @ 0x40000000
[    6.626306] uvcvideo: Found UVC 1.00 device Acer Crystal Eye webcam (064e:d101)
[    6.626653] input: Video Bus as /devices/LNXSYSTM:00/device:00/PNP0A08:00/LNXVIDEO:00/input/input6
[    6.626899] ACPI: Video Device [OVGA] (multi-head: yes  rom: yes  post: no)
[    6.630791] input: Acer Crystal Eye webcam as /devices/pci0000:00/0000:00:1d.7/usb1/1-5/1-5:1.0/input/input7
[    6.631098] usbcore: registered new interface driver uvcvideo
[    6.631178] USB Video Class driver (1.1.1)
[    6.651533] acerhdf: Acer Aspire One Fan driver, v.0.5.24
[    6.651617] acerhdf: Fan control off, to enable do:
[    6.651682] acerhdf: echo -n "enabled" > /sys/class/thermal/thermal_zone0/mode
[    6.808000] acer_wmi: Acer Laptop ACPI-WMI Extras
[    6.808425] acer_wmi: Function bitmap for Communication Device: 0x0
[    6.898382] asix 1-1:1.0: eth1: register 'asix' at usb-0000:00:1d.7-1, ASIX AX88772 USB 2.0 Ethernet, xx:xx:xx:xx:xx:xx
[    6.898613] usbcore: registered new interface driver asix
[    6.958092] cfg80211: Calling CRDA to update world regulatory domain
[    7.153010] snd_hda_intel 0000:00:1b.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
[    7.153257] snd_hda_intel 0000:00:1b.0: irq 45 for MSI/MSI-X
[    7.153343] snd_hda_intel 0000:00:1b.0: setting latency timer to 64
[    7.190380] udev[1445]: renamed network interface eth0 to lan1
[    7.302785] [drm] Initialized drm 1.1.0 20060810
[    7.543255] ath5k 0000:03:00.0: PCI INT A -> GSI 18 (level, low) -> IRQ 18
[    7.543404] ath5k 0000:03:00.0: setting latency timer to 64
[    7.543542] ath5k 0000:03:00.0: registered as 'phy0'
[    7.626229] input: HDA Digital PCBeep as /devices/pci0000:00/0000:00:1b.0/input/input8
[    7.628994] input: HDA Intel Mic as /devices/pci0000:00/0000:00:1b.0/sound/card0/input9
[    7.629510] input: HDA Intel Headphone as /devices/pci0000:00/0000:00:1b.0/sound/card0/input10
[    7.630328] i915 0000:00:02.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
[    7.630419] i915 0000:00:02.0: setting latency timer to 64
[    7.757939] [drm] Supports vblank timestamp caching Rev 1 (10.10.2010).
[    7.758028] [drm] Driver supports precise vblank timestamp query.
[    7.758310] vgaarb: device changed decodes: PCI:0000:00:02.0,olddecodes=io+mem,decodes=io+mem:owns=io+mem
[    7.983660] udev[1431]: renamed network interface eth1 to wan1
[    8.088249] [drm] initialized overlay support
[    8.111182] fbcon: inteldrmfb (fb0) is primary device
[    8.149307] ath: EEPROM regdomain: 0x65
[    8.149314] ath: EEPROM indicates we should expect a direct regpair map
[    8.149322] ath: Country alpha2 being used: 00
[    8.149325] ath: Regpair used: 0x65
[    8.149332] cfg80211: Updating information on frequency 2412 MHz for a 20 MHz width channel with regulatory rule:
[    8.149340] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (N/A mBi, 2000 mBm)
[    8.149345] cfg80211: Updating information on frequency 2417 MHz for a 20 MHz width channel with regulatory rule:
[    8.149352] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (N/A mBi, 2000 mBm)
[    8.149357] cfg80211: Updating information on frequency 2422 MHz for a 20 MHz width channel with regulatory rule:
[    8.149364] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (N/A mBi, 2000 mBm)
[    8.149369] cfg80211: Updating information on frequency 2427 MHz for a 20 MHz width channel with regulatory rule:
[    8.149376] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (N/A mBi, 2000 mBm)
[    8.149381] cfg80211: Updating information on frequency 2432 MHz for a 20 MHz width channel with regulatory rule:
[    8.149388] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (N/A mBi, 2000 mBm)
[    8.149393] cfg80211: Updating information on frequency 2437 MHz for a 20 MHz width channel with regulatory rule:
[    8.149400] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (N/A mBi, 2000 mBm)
[    8.149405] cfg80211: Updating information on frequency 2442 MHz for a 20 MHz width channel with regulatory rule:
[    8.149412] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (N/A mBi, 2000 mBm)
[    8.149417] cfg80211: Updating information on frequency 2447 MHz for a 20 MHz width channel with regulatory rule:
[    8.149424] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (N/A mBi, 2000 mBm)
[    8.149429] cfg80211: Updating information on frequency 2452 MHz for a 20 MHz width channel with regulatory rule:
[    8.149436] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (N/A mBi, 2000 mBm)
[    8.149441] cfg80211: Updating information on frequency 2457 MHz for a 20 MHz width channel with regulatory rule:
[    8.149448] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (N/A mBi, 2000 mBm)
[    8.149453] cfg80211: Updating information on frequency 2462 MHz for a 20 MHz width channel with regulatory rule:
[    8.149460] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (N/A mBi, 2000 mBm)
[    8.149465] cfg80211: Updating information on frequency 2467 MHz for a 20 MHz width channel with regulatory rule:
[    8.149471] cfg80211: 2457000 KHz - 2482000 KHz @ 40000 KHz), (N/A mBi, 2000 mBm)
[    8.149477] cfg80211: Updating information on frequency 2472 MHz for a 20 MHz width channel with regulatory rule:
[    8.149483] cfg80211: 2457000 KHz - 2482000 KHz @ 40000 KHz), (N/A mBi, 2000 mBm)
[    8.149489] cfg80211: Disabling freq 2484 MHz as custom regd has no rule that fits a 20 MHz wide channel
[    8.149592] cfg80211: Ignoring regulatory request Set by core since the driver uses its own custom regulatory domain
[    8.149953] ieee80211 phy0: Selected rate control algorithm 'minstrel_ht'
[    8.151017] Registered led device: ath5k-phy0::rx
[    8.151094] Registered led device: ath5k-phy0::tx
[    8.151130] ath5k phy0: Atheros AR2425 chip found (MAC: 0xe2, PHY: 0x70)
[    8.177067] udev[1433]: renamed network interface wlan0 to wlan2
[    8.472668] cfg80211: Ignoring regulatory request Set by core since the driver uses its own custom regulatory domain
[    8.472677] cfg80211: World regulatory domain updated:
[    8.472681] cfg80211:     (start_freq - end_freq @ bandwidth), (max_antenna_gain, max_eirp)
[    8.472689] cfg80211:     (2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    8.472695] cfg80211:     (2457000 KHz - 2482000 KHz @ 20000 KHz), (300 mBi, 2000 mBm)
[    8.472701] cfg80211:     (2474000 KHz - 2494000 KHz @ 20000 KHz), (300 mBi, 2000 mBm)
[    8.472708] cfg80211:     (5170000 KHz - 5250000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    8.472714] cfg80211:     (5735000 KHz - 5835000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    8.490914] Console: switching to colour frame buffer device 128x37
[    8.500103] fb0: inteldrmfb frame buffer device
[    8.500109] drm: registered panic notifier
[    8.500203] [drm] Initialized i915 1.6.0 20080730 for 0000:00:02.0 on minor 0
[    9.617160] EXT4-fs (sda3): re-mounted. Opts: (null)
[    9.924940] EXT4-fs (sda3): re-mounted. Opts: errors=remount-ro
[   11.088560] RPC: Registered named UNIX socket transport module.
[   11.094016] RPC: Registered udp transport module.
[   11.098147] RPC: Registered tcp transport module.
[   11.102196] RPC: Registered tcp NFSv4.1 backchannel transport module.
[   11.185077] FS-Cache: Loaded
[   11.233957] FS-Cache: Netfs 'nfs' registered for caching
[   11.291976] Installing knfsd (copyright (C) 1996 okir@monad.swb.de).
[   11.378500] Adding 1952764k swap on /dev/mapper/cswap.  Priority:-1 extents:1 across:1952764k 
[   11.778839] EXT4-fs (sda1): mounting ext3 file system using the ext4 subsystem
[   11.832610] EXT4-fs (sda1): mounted filesystem with ordered data mode. Opts: (null)
[   15.392549] r8169 0000:02:00.0: lan1: link down
[   15.395970] r8169 0000:02:00.0: lan1: link down
[   15.399677] ADDRCONF(NETDEV_UP): lan1: link is not ready
[   15.634049] device lan1 entered promiscuous mode
[   15.645826] device tap0 entered promiscuous mode
[   15.651542] ADDRCONF(NETDEV_UP): tap0: link is not ready
[   15.660784] ADDRCONF(NETDEV_UP): lanbr0: link is not ready
[   17.029230] r8169 0000:02:00.0: lan1: link up
[   17.032342] ADDRCONF(NETDEV_CHANGE): lan1: link becomes ready
[   17.035590] lanbr0: port 1(lan1) entering forwarding state
[   17.038222] lanbr0: port 1(lan1) entering forwarding state
[   17.043477] ADDRCONF(NETDEV_CHANGE): lanbr0: link becomes ready
[   18.248040] device wan1 entered promiscuous mode
[   19.030188] ADDRCONF(NETDEV_UP): wan1: link is not ready
[   19.826630] ADDRCONF(NETDEV_UP): wan1: link is not ready
[   21.687278] ADDRCONF(NETDEV_CHANGE): wan1: link becomes ready
[   21.691557] asix 1-1:1.0: wan1: link up, 100Mbps, full-duplex, lpa 0x41E1
[   29.011137] PPP generic driver version 2.4.2
[   29.235737] NET: Registered protocol family 24
[   31.673620] device wlan2 entered promiscuous mode
[   31.680369] lanbr0: port 3(wlan2) entering forwarding state
[   31.684335] lanbr0: port 3(wlan2) entering forwarding state
[   31.688481] cfg80211: Calling CRDA for country: FI
[   31.712948] cfg80211: Ignoring regulatory request Set by user since the driver requires its own regulatory domain to be set first
[   31.712965] cfg80211: Regulatory domain changed to country: FI
[   31.720981] cfg80211:     (start_freq - end_freq @ bandwidth), (max_antenna_gain, max_eirp)
[   31.724975] cfg80211:     (2402000 KHz - 2482000 KHz @ 40000 KHz), (N/A, 2000 mBm)
[   31.728980] cfg80211:     (5170000 KHz - 5250000 KHz @ 40000 KHz), (N/A, 2000 mBm)
[   31.732962] cfg80211:     (5250000 KHz - 5330000 KHz @ 40000 KHz), (N/A, 2000 mBm)
[   31.736914] cfg80211:     (5490000 KHz - 5710000 KHz @ 40000 KHz), (N/A, 2700 mBm)
[   33.170897] microcode: CPU0 sig=0x106c2, pf=0x4, revision=0x218
[   33.281550] microcode: CPU1 sig=0x106c2, pf=0x4, revision=0x218
[   33.294644] microcode: Microcode Update Driver: v2.00 <tigran@aivazian.fsnet.co.uk>, Peter Oruba
[   34.070048] input: ACPI Virtual Keyboard Device as /devices/virtual/input/input11
[   34.811466] svc: failed to register lockdv1 RPC service (errno 97).
[   34.814539] NFSD: Using /var/lib/nfs/v4recovery as the NFSv4 state recovery directory
[   34.840889] NFSD: starting 90-second grace period
[   37.592881] IPv6 over IPv4 tunneling driver
[   51.625701] ADDRCONF(NETDEV_CHANGE): tap0: link becomes ready
[   51.630188] lanbr0: port 2(tap0) entering forwarding state
[   51.634157] lanbr0: port 2(tap0) entering forwarding state
[   53.040749] sshd (4203): /proc/4203/oom_adj is deprecated, please use /proc/4203/oom_score_adj instead.
[   63.023399] IMQ driver loaded successfully. (numdevs = 16, numqueues = 2)
[   63.031765] 	Hooking IMQ after NAT on PREROUTING.
[   63.036012] 	Hooking IMQ before NAT on POSTROUTING.

--=_yqp6qfwgddw
Content-Type: text/plain;
 charset=UTF-8;
 name="lsusb.txt"
Content-Disposition: attachment;
 filename="lsusb.txt"
Content-Transfer-Encoding: 7bit


Bus 001 Device 002: ID 0b95:7720 ASIX Electronics Corp. AX88772
Device Descriptor:
  bLength                18
  bDescriptorType         1
  bcdUSB               2.00
  bDeviceClass          255 Vendor Specific Class
  bDeviceSubClass       255 Vendor Specific Subclass
  bDeviceProtocol         0 
  bMaxPacketSize0        64
  idVendor           0x0b95 ASIX Electronics Corp.
  idProduct          0x7720 AX88772
  bcdDevice            0.01
  iManufacturer           1 ASIX Elec. Corp.
  iProduct                2 AX88772 
  iSerial                 3 000001
  bNumConfigurations      1
  Configuration Descriptor:
    bLength                 9
    bDescriptorType         2
    wTotalLength           39
    bNumInterfaces          1
    bConfigurationValue     1
    iConfiguration          4 0
    bmAttributes         0xe0
      Self Powered
      Remote Wakeup
    MaxPower              250mA
    Interface Descriptor:
      bLength                 9
      bDescriptorType         4
      bInterfaceNumber        0
      bAlternateSetting       0
      bNumEndpoints           3
      bInterfaceClass       255 Vendor Specific Class
      bInterfaceSubClass    255 Vendor Specific Subclass
      bInterfaceProtocol      0 
      iInterface              7 0
      Endpoint Descriptor:
        bLength                 7
        bDescriptorType         5
        bEndpointAddress     0x81  EP 1 IN
        bmAttributes            3
          Transfer Type            Interrupt
          Synch Type               None
          Usage Type               Data
        wMaxPacketSize     0x0008  1x 8 bytes
        bInterval              11
      Endpoint Descriptor:
        bLength                 7
        bDescriptorType         5
        bEndpointAddress     0x82  EP 2 IN
        bmAttributes            2
          Transfer Type            Bulk
          Synch Type               None
          Usage Type               Data
        wMaxPacketSize     0x0200  1x 512 bytes
        bInterval               0
      Endpoint Descriptor:
        bLength                 7
        bDescriptorType         5
        bEndpointAddress     0x03  EP 3 OUT
        bmAttributes            2
          Transfer Type            Bulk
          Synch Type               None
          Usage Type               Data
        wMaxPacketSize     0x0200  1x 512 bytes
        bInterval               0
Device Qualifier (for other device speed):
  bLength                10
  bDescriptorType         6
  bcdUSB               2.00
  bDeviceClass          255 Vendor Specific Class
  bDeviceSubClass       255 Vendor Specific Subclass
  bDeviceProtocol         0 
  bMaxPacketSize0         8
  bNumConfigurations      1
Device Status:     0x0001
  Self Powered

--=_yqp6qfwgddw
Content-Type: text/x-patch;
 charset=UTF-8;
 name="set-mac-address-in-ax88772_link_reset.patch"
Content-Disposition: attachment;
 filename="set-mac-address-in-ax88772_link_reset.patch"
Content-Transfer-Encoding: 7bit

asix: set mac address in ax88722_reset

From: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>

Signed-off-by: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
---
 drivers/net/usb/asix.c |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/drivers/net/usb/asix.c b/drivers/net/usb/asix.c
index e95f0e6..eb6b4c1 100644
--- a/drivers/net/usb/asix.c
+++ b/drivers/net/usb/asix.c
@@ -974,6 +974,7 @@ static int ax88772_link_reset(struct usbnet *dev)
 
 static int ax88772_reset(struct usbnet *dev)
 {
+	struct asix_data *data = (struct asix_data *)&dev->data;
 	int ret, embd_phy;
 	u16 rx_ctl;
 
@@ -1051,6 +1052,13 @@ static int ax88772_reset(struct usbnet *dev)
 		goto out;
 	}
 
+	/* Rewrite MAC address */
+	memcpy(data->mac_addr, dev->net->dev_addr, ETH_ALEN);
+	ret = asix_write_cmd(dev, AX_CMD_WRITE_NODE_ID, 0, 0, ETH_ALEN,
+							data->mac_addr);
+	if (ret < 0)
+		goto out;
+
 	/* Set RX_CTL to default values with 2k buffer, and enable cactus */
 	ret = asix_write_rx_ctl(dev, AX_DEFAULT_RX_CTL);
 	if (ret < 0)

--=_yqp6qfwgddw--
