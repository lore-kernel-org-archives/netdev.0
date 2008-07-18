From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [bug] Attempt to release alive inet socket f6fac040
Date: Fri, 18 Jul 2008 21:55:32 +0200
Message-ID: <20080718195532.GA27516@elte.hu>
References: <20080717214222.GA29449@elte.hu> <19f34abd0807171615s5b477d4cr22d3e9444bcf65df@mail.gmail.com> <20080717.190315.186892939.davem@davemloft.net> <19f34abd0807180003m7bdf832g141777751d7ea563@mail.gmail.com> <20080718191037.GA25937@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, penberg@cs.helsinki.fi, rjw@sisk.pl
To: Vegard Nossum <vegard.nossum@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.mail.elte.hu ([157.181.1.138]:53328 "EHLO mx3.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754326AbYGRT4G (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Jul 2008 15:56:06 -0400
Content-Disposition: inline
In-Reply-To: <20080718191037.GA25937@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Ingo Molnar <mingo@elte.hu> wrote:

> Hm, just got another skb related weirdness and crash on that testbox:

Totally weird bug. Using the same bzImage i was able to crash the box 2 
times in a row. Then i tried another (but similarly configured) kernel 
and it wouldnt crash.

Then i tried the original bzImage again (bit for bit equivalent) and it 
wouldnt crash 5 times in a row.

I've attached the second crashlog below - in case it's interesting to 
anyone.

This cannot be random corruption or hw flakiness as the two crashes in a 
row are so similar. One (remote) possibility would be for some hw 
component to be in a weird state that doesnt get proper re-initialized 
after reboot. As long as that condition lingered, it would crash. Once 
that condition was gone, it wouldnt crash.

For now i've given up on this variant of the bug. I'll continue with 
randconfig searching - maybe another config gives us something more 
debuggable ...

And note that this time it was SLAB not SLUB - so any SLUB impact is 
highly unlikely. (i strongly suspect some hw initialization issue.)

	Ingo

-------------------->
[    0.000000] Linux version 2.6.26-tip-03923-g2c96bcb-dirty (mingo@europe) (gcc version 4.2.2) #3134 SMP PREEMPT Fri Jul 18 20:06:13 CEST 2008
[    0.000000] BIOS-provided physical RAM map:
[    0.000000]  BIOS-e820: 0000000000000000 - 000000000009f000 (usable)
[    0.000000]  BIOS-e820: 000000000009f000 - 00000000000a0000 (reserved)
[    0.000000]  BIOS-e820: 00000000000d2000 - 00000000000d4000 (reserved)
[    0.000000]  BIOS-e820: 00000000000dc000 - 0000000000100000 (reserved)
[    0.000000]  BIOS-e820: 0000000000100000 - 000000007f6e0000 (usable)
[    0.000000]  BIOS-e820: 000000007f6e0000 - 000000007f6f3000 (ACPI data)
[    0.000000]  BIOS-e820: 000000007f6f3000 - 000000007f700000 (ACPI NVS)
[    0.000000]  BIOS-e820: 000000007f700000 - 0000000080000000 (reserved)
[    0.000000]  BIOS-e820: 00000000f0000000 - 00000000f4000000 (reserved)
[    0.000000]  BIOS-e820: 00000000fec00000 - 00000000fec10000 (reserved)
[    0.000000]  BIOS-e820: 00000000fed00000 - 00000000fed00400 (reserved)
[    0.000000]  BIOS-e820: 00000000fed14000 - 00000000fed1a000 (reserved)
[    0.000000]  BIOS-e820: 00000000fed1c000 - 00000000fed90000 (reserved)
[    0.000000]  BIOS-e820: 00000000fee00000 - 00000000fee01000 (reserved)
[    0.000000]  BIOS-e820: 00000000ff800000 - 0000000100000000 (reserved)
[    0.000000] debug: ignoring loglevel setting.
[    0.000000] using polling idle threads.
[    0.000000] last_pfn = 0x7f6e0 max_arch_pfn = 0x100000
[    0.000000] kernel direct mapping tables up to 48000000 @ 7000-c000
[    0.000000] ACPI: RSDP 000F68A0, 0024 (r2 LENOVO)
[    0.000000] ACPI: XSDT 7F6E631F, 0074 (r1 LENOVO TP-79        1020  LTP        0)
[    0.000000] ACPI: FACP 7F6E6400, 00F4 (r3 LENOVO TP-79        1020 LNVO        1)
[    0.000000] ACPI Warning (tbfadt-0447): Optional field "Gpe1Block" has zero address or length: 000000000000102C/0 [20080609]
[    0.000000] ACPI: DSDT 7F6E65E7, C765 (r1 LENOVO TP-79        1020 MSFT  100000E)
[    0.000000] ACPI: FACS 7F6F4000, 0040
[    0.000000] ACPI: SSDT 7F6E65B4, 0033 (r1 LENOVO TP-79        1020 MSFT  100000E)
[    0.000000] ACPI: ECDT 7F6F2D4C, 0052 (r1 LENOVO TP-79        1020 LNVO        1)
[    0.000000] ACPI: TCPA 7F6F2D9E, 0032 (r2 LENOVO TP-79        1020 LNVO        1)
[    0.000000] ACPI: APIC 7F6F2DD0, 0068 (r1 LENOVO TP-79        1020 LNVO        1)
[    0.000000] ACPI: MCFG 7F6F2E38, 003E (r1 LENOVO TP-79        1020 LNVO        1)
[    0.000000] ACPI: HPET 7F6F2E76, 0038 (r1 LENOVO TP-79        1020 LNVO        1)
[    0.000000] ACPI: BOOT 7F6F2FD8, 0028 (r1 LENOVO TP-79        1020  LTP        1)
[    0.000000] ACPI: SSDT 7F6E58DA, 0507 (r1 LENOVO TP-79        1020 INTL 20050513)
[    0.000000] ACPI: SSDT 7F6E5702, 01D8 (r1 LENOVO TP-79        1020 INTL 20050513)
[    0.000000] Entering add_active_range(0, 0x0, 0x9f) 0 entries of 256 used
[    0.000000] Entering add_active_range(0, 0x100, 0x7f6e0) 1 entries of 256 used
[    0.000000] 886MB HIGHMEM available.
[    0.000000] 1152MB LOWMEM available.
[    0.000000]   mapped low ram: 0 - 48000000
[    0.000000]   low ram: 00000000 - 48000000
[    0.000000]   bootmap 00008000 - 00011000
[    0.000000] (8 early reservations) ==> bootmem
[    0.000000]   #0 [0000000000 - 0000001000]   BIOS data page ==> [0000000000 - 0000001000]
[    0.000000]   #1 [0000001000 - 0000002000]    EX TRAMPOLINE ==> [0000001000 - 0000002000]
[    0.000000]   #2 [0000006000 - 0000007000]       TRAMPOLINE ==> [0000006000 - 0000007000]
[    0.000000]   #3 [0000100000 - 0000cec520]    TEXT DATA BSS ==> [0000100000 - 0000cec520]
[    0.000000]   #4 [0000ced000 - 0000cf2000]    INIT_PG_TABLE ==> [0000ced000 - 0000cf2000]
[    0.000000]   #5 [000009f000 - 0000100000]    BIOS reserved ==> [000009f000 - 0000100000]
[    0.000000]   #6 [0000007000 - 0000008000]          PGTABLE ==> [0000007000 - 0000008000]
[    0.000000]   #7 [0000008000 - 0000011000]          BOOTMAP ==> [0000008000 - 0000011000]
[    0.000000] Scan SMP from b0000000 for 1024 bytes.
[    0.000000] Scan SMP from b009fc00 for 1024 bytes.
[    0.000000] Scan SMP from b00f0000 for 65536 bytes.
[    0.000000] found SMP MP-table at [b00f68e0] 000f68e0
[    0.000000] Zone PFN ranges:
[    0.000000]   DMA      0x00000000 -> 0x00001000
[    0.000000]   Normal   0x00001000 -> 0x00048000
[    0.000000]   HighMem  0x00048000 -> 0x0007f6e0
[    0.000000] Movable zone start PFN for each node
[    0.000000] early_node_map[2] active PFN ranges
[    0.000000]     0: 0x00000000 -> 0x0000009f
[    0.000000]     0: 0x00000100 -> 0x0007f6e0
[    0.000000] On node 0 totalpages: 521855
[    0.000000] free_area_init_node: node 0, pgdat b088e820, node_mem_map b1000000
[    0.000000]   DMA zone: 56 pages used for memmap
[    0.000000]   DMA zone: 0 pages reserved
[    0.000000]   DMA zone: 3943 pages, LIFO batch:0
[    0.000000]   Normal zone: 3976 pages used for memmap
[    0.000000]   Normal zone: 286840 pages, LIFO batch:31
[    0.000000]   HighMem zone: 3105 pages used for memmap
[    0.000000]   HighMem zone: 223935 pages, LIFO batch:31
[    0.000000]   Movable zone: 0 pages used for memmap
[    0.000000] ACPI: PM-Timer IO Port: 0x1008
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] ACPI: LAPIC (acpi_id[0x00] lapic_id[0x00] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x01] lapic_id[0x01] enabled)
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x00] high edge lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x01] high edge lint[0x1])
[    0.000000] ACPI: IOAPIC (id[0x01] address[0xfec00000] gsi_base[0])
[    0.000000] IOAPIC[0]: apic_id 1, version 32, address 0xfec00000, GSI 0-23
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
[    0.000000] Bus #0 is ISA
[    0.000000] ACPI: IRQ0 used by override.
[    0.000000] ACPI: IRQ2 used by override.
[    0.000000] ACPI: IRQ9 used by override.
[    0.000000] Enabling APIC mode:  Flat.  Using 1 I/O APICs
[    0.000000] Using ACPI (MADT) for SMP configuration information
[    0.000000] SMP: Allowing 2 CPUs, 0 hotplug CPUs
[    0.000000] mapped APIC to ffffb000 (fee00000)
[    0.000000] mapped IOAPIC to ffffa000 (fec00000)
[    0.000000] Allocating PCI resources starting at 88000000 (gap: 80000000:70000000)
[    0.000000] PERCPU: Allocating 323600 bytes of per cpu data
[    0.000000] NR_CPUS: 8, nr_cpu_ids: 2, nr_node_ids 1
[    0.000000] Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 514718
[    0.000000] Kernel command line: root=/dev/sda1 console=tty profile=0 debug initcall_debug enforcing=0 apic=verbose sysrq_always_enabled ignore_loglevel selinux=1 relaxed_check=1 netconsole=4444@10.0.1.15/eth0,4444@10.0.1.16/00:19:d1:01:f5:55 no_hz=off nolapic_timer hpet=disable idle=poll notsc
[    0.000000] kernel profiling enabled (shift: 0)
[    0.000000] debug: sysrq always enabled.
[    0.000000] notsc: Kernel compiled with CONFIG_X86_TSC, cannot disable TSC completely.
[    0.000000] Enabling fast FPU save and restore... done.
[    0.000000] Enabling unmasked SIMD FPU exception support... done.
[    0.000000] Initializing CPU#0
[    0.000000] CPU 0 irqstacks, hard=b09c3000 soft=b09bb000
[    0.000000] PID hash table entries: 4096 (order: 12, 16384 bytes)
[    0.000000] Extended CMOS year: 2000
[    0.000000] TSC calibrated against PM_TIMER
[    0.000000] Detected 1828.742 MHz processor.
[    0.000000] Console: colour VGA+ 80x25
[    0.000000] console [tty0] enabled
[    0.000000] Lock dependency validator: Copyright (c) 2006 Red Hat, Inc., Ingo Molnar
[    0.000000] ... MAX_LOCKDEP_SUBCLASSES:    8
[    0.000000] ... MAX_LOCK_DEPTH:          48
[    0.000000] ... MAX_LOCKDEP_KEYS:        2048
[    0.000000] ... CLASSHASH_SIZE:           1024
[    0.000000] ... MAX_LOCKDEP_ENTRIES:     8192
[    0.000000] ... MAX_LOCKDEP_CHAINS:      16384
[    0.000000] ... CHAINHASH_SIZE:          8192
[    0.000000]  memory used by lock dependency info: 1088 kB
[    0.000000]  per task-struct memory footprint: 2688 bytes
[    0.000000] ------------------------
[    0.000000] | Locking API testsuite:
[    0.000000] ----------------------------------------------------------------------------
[    0.000000]                                  | spin |wlock |rlock |mutex | wsem | rsem |
[    0.000000]   --------------------------------------------------------------------------
[    0.000000]                      A-A deadlock:failed|failed|  ok  |failed|failed|failed|
[    0.000000]                  A-B-B-A deadlock:failed|failed|  ok  |failed|failed|failed|
[    0.000000]              A-B-B-C-C-A deadlock:failed|failed|  ok  |failed|failed|failed|
[    0.000000]              A-B-C-A-B-C deadlock:failed|failed|  ok  |failed|failed|failed|
[    0.000000]          A-B-B-C-C-D-D-A deadlock:failed|failed|  ok  |failed|failed|failed|
[    0.000000]          A-B-C-D-B-D-D-A deadlock:failed|failed|  ok  |failed|failed|failed|
[    0.000000]          A-B-C-D-B-C-D-A deadlock:failed|failed|  ok  |failed|failed|failed|
[    0.000000]                     double unlock:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
[    0.000000]                   initialize held:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
[    0.000000]                  bad unlock order:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
[    0.000000]   --------------------------------------------------------------------------
[    0.000000]               recursive read-lock:             |  ok  |             |failed|
[    0.000000]            recursive read-lock #2:             |  ok  |             |failed|
[    0.000000]             mixed read-write-lock:             |failed|             |failed|
[    0.000000]             mixed write-read-lock:             |failed|             |failed|
[    0.000000]   --------------------------------------------------------------------------
[    0.000000]      hard-irqs-on + irq-safe-A/12:failed|failed|  ok  |
[    0.000000]      soft-irqs-on + irq-safe-A/12:failed|failed|  ok  |
[    0.000000]      hard-irqs-on + irq-safe-A/21:failed|failed|  ok  |
[    0.000000]      soft-irqs-on + irq-safe-A/21:failed|failed|  ok  |
[    0.000000]        sirq-safe-A => hirqs-on/12:failed|failed|  ok  |
[    0.000000]        sirq-safe-A => hirqs-on/21:failed|failed|  ok  |
[    0.000000]          hard-safe-A + irqs-on/12:failed|failed|  ok  |
[    0.000000]          soft-safe-A + irqs-on/12:failed|failed|  ok  |
[    0.000000]          hard-safe-A + irqs-on/21:failed|failed|  ok  |
[    0.000000]          soft-safe-A + irqs-on/21:failed|failed|  ok  |
[    0.000000]     hard-safe-A + unsafe-B #1/123:failed|failed|  ok  |
[    0.000000]     soft-safe-A + unsafe-B #1/123:failed|failed|  ok  |
[    0.000000]     hard-safe-A + unsafe-B #1/132:failed|failed|  ok  |
[    0.000000]     soft-safe-A + unsafe-B #1/132:failed|failed|  ok  |
[    0.000000]     hard-safe-A + unsafe-B #1/213:failed|failed|  ok  |
[    0.000000]     soft-safe-A + unsafe-B #1/213:failed|failed|  ok  |
[    0.000000]     hard-safe-A + unsafe-B #1/231:failed|failed|  ok  |
[    0.000000]     soft-safe-A + unsafe-B #1/231:failed|failed|  ok  |
[    0.000000]     hard-safe-A + unsafe-B #1/312:failed|failed|  ok  |
[    0.000000]     soft-safe-A + unsafe-B #1/312:failed|failed|  ok  |
[    0.000000]     hard-safe-A + unsafe-B #1/321:failed|failed|  ok  |
[    0.000000]     soft-safe-A + unsafe-B #1/321:failed|failed|  ok  |
[    0.000000]     hard-safe-A + unsafe-B #2/123:failed|failed|  ok  |
[    0.000000]     soft-safe-A + unsafe-B #2/123:failed|failed|  ok  |
[    0.000000]     hard-safe-A + unsafe-B #2/132:failed|failed|  ok  |
[    0.000000]     soft-safe-A + unsafe-B #2/132:failed|failed|  ok  |
[    0.000000]     hard-safe-A + unsafe-B #2/213:failed|failed|  ok  |
[    0.000000]     soft-safe-A + unsafe-B #2/213:failed|failed|  ok  |
[    0.000000]     hard-safe-A + unsafe-B #2/231:failed|failed|  ok  |
[    0.000000]     soft-safe-A + unsafe-B #2/231:failed|failed|  ok  |
[    0.000000]     hard-safe-A + unsafe-B #2/312:failed|failed|  ok  |
[    0.000000]     soft-safe-A + unsafe-B #2/312:failed|failed|  ok  |
[    0.000000]     hard-safe-A + unsafe-B #2/321:failed|failed|  ok  |
[    0.000000]     soft-safe-A + unsafe-B #2/321:failed|failed|  ok  |
[    0.000000]       hard-irq lock-inversion/123:failed|failed|  ok  |
[    0.000000]       soft-irq lock-inversion/123:failed|failed|  ok  |
[    0.000000]       hard-irq lock-inversion/132:failed|failed|  ok  |
[    0.000000]       soft-irq lock-inversion/132:failed|failed|  ok  |
[    0.000000]       hard-irq lock-inversion/213:failed|failed|  ok  |
[    0.000000]       soft-irq lock-inversion/213:failed|failed|  ok  |
[    0.000000]       hard-irq lock-inversion/231:failed|failed|  ok  |
[    0.000000]       soft-irq lock-inversion/231:failed|failed|  ok  |
[    0.000000]       hard-irq lock-inversion/312:failed|failed|  ok  |
[    0.000000]       soft-irq lock-inversion/312:failed|failed|  ok  |
[    0.000000]       hard-irq lock-inversion/321:failed|failed|  ok  |
[    0.000000]       soft-irq lock-inversion/321:failed|failed|  ok  |
[    0.000000]       hard-irq read-recursion/123:  ok  |
[    0.000000]       soft-irq read-recursion/123:  ok  |
[    0.000000]       hard-irq read-recursion/132:  ok  |
[    0.000000]       soft-irq read-recursion/132:  ok  |
[    0.000000]       hard-irq read-recursion/213:  ok  |
[    0.000000]       soft-irq read-recursion/213:  ok  |
[    0.000000]       hard-irq read-recursion/231:  ok  |
[    0.000000]       soft-irq read-recursion/231:  ok  |
[    0.000000]       hard-irq read-recursion/312:  ok  |
[    0.000000]       soft-irq read-recursion/312:  ok  |
[    0.000000]       hard-irq read-recursion/321:  ok  |
[    0.000000]       soft-irq read-recursion/321:  ok  |
[    0.000000] --------------------------------------------------------
[    0.000000] 133 out of 218 testcases failed, as expected. |
[    0.000000] ----------------------------------------------------
[    0.000000] Dentry cache hash table entries: 262144 (order: 8, 1048576 bytes)
[    0.000000] Inode-cache hash table entries: 131072 (order: 7, 524288 bytes)
[    0.000000] Memory: 2021684k/2087808k available (5436k kernel code, 64940k reserved, 2813k data, 652k init, 908160k highmem)
[    0.000000] virtual kernel memory layout:
[    0.000000]     fixmap  : 0xffee1000 - 0xfffff000   (1144 kB)
[    0.000000]     pkmap   : 0xff800000 - 0xffc00000   (4096 kB)
[    0.000000]     vmalloc : 0xf8800000 - 0xff7fe000   ( 111 MB)
[    0.000000]     lowmem  : 0xb0000000 - 0xf8000000   (1152 MB)
[    0.000000]       .init : 0xb0915000 - 0xb09b8000   ( 652 kB)
[    0.000000]       .data : 0xb064f021 - 0xb090e534   (2813 kB)
[    0.000000]       .text : 0xb0100000 - 0xb064f021   (5436 kB)
[    0.000000] Checking if this processor honours the WP bit even in supervisor mode...Ok.
[    0.000000] CPA: page pool initialized 1 of 1 pages preallocated
[    0.001000] Calibrating delay loop (skipped), value calculated using timer frequency.. <6>3657.48 BogoMIPS (lpj=1828742)
[    0.001000] Security Framework initialized
[    0.001000] Mount-cache hash table entries: 512
[    0.002000] Initializing cgroup subsys debug
[    0.002000] Initializing cgroup subsys ns
[    0.002000] CPU: L1 I cache: 32K, L1 D cache: 32K
[    0.002000] CPU: L2 cache: 2048K
[    0.002000] CPU: Physical Processor ID: 0
[    0.002000] CPU: Processor Core ID: 0
[    0.002000] Intel machine check architecture supported.
[    0.002000] Intel machine check reporting enabled on CPU#0.
[    0.002000] Checking 'hlt' instruction... OK.
[    0.009000] ACPI: Core revision 20080609
[    0.034000] Parsing all Control Methods:
[    0.036000] Table [DSDT](id 0001) - 1587 Objects with 76 Devices 433 Methods 26 Regions
[    0.037000] Parsing all Control Methods:
[    0.039000] Table [SSDT](id 0002) - 1 Objects with 0 Devices 1 Methods 0 Regions
[    0.039000] Parsing all Control Methods:
[    0.041000] Table [SSDT](id 0003) - 14 Objects with 0 Devices 5 Methods 0 Regions
[    0.042000] Parsing all Control Methods:
[    0.044000] Table [SSDT](id 0004) - 14 Objects with 1 Devices 2 Methods 0 Regions
[    0.044000]  tbxface-0596 [00] tb_load_namespace     : ACPI Tables successfully acquired
[    0.045000] evxfevnt-0091 [00] enable                : Transition to ACPI mode successful
[    0.046000] enabled ExtINT on CPU#0
[    0.046000] ESR value before enabling vector: 0x00000040  after: 0x00000000
[    0.046000] ENABLING IO-APIC IRQs
[    0.046000] init IO_APIC IRQs
[    0.046000]  IO-APIC (apicid-pin) 1-0 not connected.
[    0.047000]  IO-APIC (apicid-pin) 1-16, 1-17, 1-18, 1-19, 1-20, 1-21, 1-22, 1-23 not connected.
[    0.047000] ..TIMER: vector=0x31 apic1=0 pin1=2 apic2=-1 pin2=-1
[    0.059000] CPU0: Intel Genuine Intel(R) CPU           T2400  @ 1.83GHz stepping 08
[    0.060000] ++++++++++++++++++++=_---CPU UP  1
[    0.060000] lockdep: fixing up alternatives.
[    0.060000] CPU 1 irqstacks, hard=b09c4000 soft=b09bc000
[    0.060000] Booting processor 1/1 ip 6000
[    0.060000] Setting warm reset code and vector.
[    0.060000] 1.
[    0.061000] 2.
[    0.061000] 3.
[    0.061000] Asserting INIT.
[    0.061000] Waiting for send to finish...
[    0.072000] Deasserting INIT.
[    0.073000] Waiting for send to finish...
[    0.073000] #startup loops: 2.
[    0.073000] Sending STARTUP #1.
[    0.073000] After apic_write.
[    0.073000] Startup point 1.
[    0.073000] Waiting for send to finish...
[    0.073000] Initializing CPU#1
[    0.073000] CPU#1 (phys ID: 1) waiting for CALLOUT
[    0.074000] Sending STARTUP #2.
[    0.074000] After apic_write.
[    0.074000] Startup point 1.
[    0.074000] Waiting for send to finish...
[    0.075000] After Startup.
[    0.075000] Before Callout 1.
[    0.075000] After Callout 1.
[    0.075000] CALLIN, before setup_local_APIC().
[    0.075000] masked ExtINT on CPU#1
[    0.075000] Calibrating delay loop... <6>3186.68 BogoMIPS (lpj=1593344)
[    0.099000] Stack at about f7c7afac
[    0.099000] CPU: L1 I cache: 32K, L1 D cache: 32K
[    0.099000] CPU: L2 cache: 2048K
[    0.099000] CPU: Physical Processor ID: 0
[    0.099000] CPU: Processor Core ID: 1
[    0.099000] Intel machine check architecture supported.
[    0.099000] Intel machine check reporting enabled on CPU#1.
[    0.099000] OK.
[    0.100000] CPU1: Intel Genuine Intel(R) CPU           T2400  @ 1.83GHz stepping 08
[    0.100000] CPU has booted.
[    0.100000] checking TSC synchronization [CPU#0 -> CPU#1]:
[    0.100000] Measured 580415 cycles TSC warp between CPUs, turning off TSC clock.
[    0.100000] Marking TSC unstable due to check_tsc_sync_source failed
[    0.101000] Brought up 2 CPUs
[    0.101000] Boot done.
[    0.101000] Before bogomips.
[    0.101000] Total of 2 processors activated (6844.17 BogoMIPS).
[    0.101000] Before bogocount - setting activated=1.
[    0.102000] calling  net_ns_init+0x0/0x10a
[    0.102000] net_namespace: 728 bytes
[    0.102000] initcall net_ns_init+0x0/0x10a returned 0 after 0 msecs
[    0.102000] calling  reboot_init+0x0/0xc
[    0.102000] initcall reboot_init+0x0/0xc returned 0 after 0 msecs
[    0.102000] calling  print_banner+0x0/0xd
[    0.103000] Booting paravirtualized kernel on bare hardware
[    0.103000] initcall print_banner+0x0/0xd returned 0 after 0 msecs
[    0.103000] calling  sysctl_init+0x0/0x18
[    0.103000] initcall sysctl_init+0x0/0x18 returned 0 after 0 msecs
[    0.103000] calling  ksysfs_init+0x0/0x9b
[    0.103000] initcall ksysfs_init+0x0/0x9b returned 0 after 0 msecs
[    0.103000] calling  init_jiffies_clocksource+0x0/0x14
[    0.103000] initcall init_jiffies_clocksource+0x0/0x14 returned 0 after 0 msecs
[    0.104000] calling  pm_init+0x0/0x32
[    0.105000] initcall pm_init+0x0/0x32 returned 0 after 0 msecs
[    0.105000] calling  filelock_init+0x0/0x2c
[    0.105000] initcall filelock_init+0x0/0x2c returned 0 after 0 msecs
[    0.105000] calling  init_aout_binfmt+0x0/0x14
[    0.105000] initcall init_aout_binfmt+0x0/0x14 returned 0 after 0 msecs
[    0.105000] calling  init_script_binfmt+0x0/0x14
[    0.105000] initcall init_script_binfmt+0x0/0x14 returned 0 after 0 msecs
[    0.105000] calling  init_elf_binfmt+0x0/0x14
[    0.105000] initcall init_elf_binfmt+0x0/0x14 returned 0 after 0 msecs
[    0.106000] calling  debugfs_init+0x0/0x46
[    0.106000] initcall debugfs_init+0x0/0x46 returned 0 after 0 msecs
[    0.106000] calling  securityfs_init+0x0/0x46
[    0.106000] initcall securityfs_init+0x0/0x46 returned 0 after 0 msecs
[    0.106000] calling  random32_init+0x0/0x3f
[    0.106000] initcall random32_init+0x0/0x3f returned 0 after 0 msecs
[    0.106000] calling  sock_init+0x0/0x56
[    0.106000] initcall sock_init+0x0/0x56 returned 0 after 0 msecs
[    0.107000] calling  netpoll_init+0x0/0x3e
[    0.107000] initcall netpoll_init+0x0/0x3e returned 0 after 0 msecs
[    0.107000] calling  netlink_proto_init+0x0/0x10c
[    0.107000] NET: Registered protocol family 16
[    0.107000] initcall netlink_proto_init+0x0/0x10c returned 0 after 0 msecs
[    0.107000] calling  bdi_class_init+0x0/0x38
[    0.107000] initcall bdi_class_init+0x0/0x38 returned 0 after 0 msecs
[    0.108000] calling  kobject_uevent_init+0x0/0x3f
[    0.108000] initcall kobject_uevent_init+0x0/0x3f returned 0 after 0 msecs
[    0.108000] calling  pcibus_class_init+0x0/0x14
[    0.108000] initcall pcibus_class_init+0x0/0x14 returned 0 after 0 msecs
[    0.108000] calling  pci_driver_init+0x0/0x14
[    0.108000] initcall pci_driver_init+0x0/0x14 returned 0 after 0 msecs
[    0.108000] calling  backlight_class_init+0x0/0x42
[    0.109000] initcall backlight_class_init+0x0/0x42 returned 0 after 0 msecs
[    0.109000] calling  video_output_class_init+0x0/0x14
[    0.109000] initcall video_output_class_init+0x0/0x14 returned 0 after 0 msecs
[    0.109000] calling  dock_init+0x0/0x58
[    0.110000] ACPI: ACPI Dock Station Driver
[    0.110000] initcall dock_init+0x0/0x58 returned 0 after 0 msecs
[    0.111000] calling  tty_class_init+0x0/0x2c
[    0.111000] initcall tty_class_init+0x0/0x2c returned 0 after 0 msecs
[    0.111000] calling  vtconsole_class_init+0x0/0x9f
[    0.111000] initcall vtconsole_class_init+0x0/0x9f returned 0 after 0 msecs
[    0.111000] calling  enable_pci_io_ecs+0x0/0x30
[    0.111000] initcall enable_pci_io_ecs+0x0/0x30 returned 0 after 0 msecs
[    0.112000] calling  rdc_board_setup+0x0/0x1e
[    0.112000] initcall rdc_board_setup+0x0/0x1e returned 0 after 0 msecs
[    0.112000] calling  arch_kdebugfs_init+0x0/0x277
[    0.112000] initcall arch_kdebugfs_init+0x0/0x277 returned 0 after 0 msecs
[    0.112000] calling  init_pit_clocksource+0x0/0x8b
[    0.112000] initcall init_pit_clocksource+0x0/0x8b returned 0 after 0 msecs
[    0.112000] calling  mtrr_if_init+0x0/0x5b
[    0.113000] initcall mtrr_if_init+0x0/0x5b returned 0 after 0 msecs
[    0.113000] calling  acpi_pci_init+0x0/0x3d
[    0.113000] ACPI: bus type pci registered
[    0.113000] initcall acpi_pci_init+0x0/0x3d returned 0 after 0 msecs
[    0.113000] calling  init_acpi_device_notify+0x0/0x48
[    0.113000] initcall init_acpi_device_notify+0x0/0x48 returned 0 after 0 msecs
[    0.113000] calling  pci_arch_init+0x0/0x38
[    0.114000] PCI: PCI BIOS revision 2.10 entry at 0xfd84b, last bus=24
[    0.114000] initcall pci_arch_init+0x0/0x38 returned 0 after 0 msecs
[    0.114000] calling  topology_init+0x0/0x2d
[    0.114000] initcall topology_init+0x0/0x2d returned 0 after 0 msecs
[    0.114000] calling  mtrr_init_finialize+0x0/0x3a
[    0.114000] initcall mtrr_init_finialize+0x0/0x3a returned 0 after 0 msecs
[    0.114000] calling  param_sysfs_init+0x0/0x159
[    0.126000] initcall param_sysfs_init+0x0/0x159 returned 0 after 10 msecs
[    0.126000] calling  pm_sysrq_init+0x0/0x1b
[    0.126000] initcall pm_sysrq_init+0x0/0x1b returned 0 after 0 msecs
[    0.126000] calling  readahead_init+0x0/0x34
[    0.127000] initcall readahead_init+0x0/0x34 returned 0 after 0 msecs
[    0.127000] calling  init_bio+0x0/0xb0
[    0.127000] initcall init_bio+0x0/0xb0 returned 0 after 0 msecs
[    0.127000] calling  integrity_init+0x0/0x39
[    0.127000] initcall integrity_init+0x0/0x39 returned 0 after 0 msecs
[    0.127000] calling  blk_settings_init+0x0/0x22
[    0.127000] initcall blk_settings_init+0x0/0x22 returned 0 after 0 msecs
[    0.128000] calling  blk_ioc_init+0x0/0x29
[    0.128000] initcall blk_ioc_init+0x0/0x29 returned 0 after 0 msecs
[    0.128000] calling  genhd_device_init+0x0/0x37
[    0.128000] initcall genhd_device_init+0x0/0x37 returned 0 after 0 msecs
[    0.128000] calling  blk_dev_integrity_init+0x0/0x29
[    0.128000] initcall blk_dev_integrity_init+0x0/0x29 returned 0 after 0 msecs
[    0.128000] calling  pci_slot_init+0x0/0x40
[    0.129000] initcall pci_slot_init+0x0/0x40 returned 0 after 0 msecs
[    0.129000] calling  fbmem_init+0x0/0x78
[    0.129000] initcall fbmem_init+0x0/0x78 returned 0 after 0 msecs
[    0.129000] calling  acpi_init+0x0/0x21b
[    0.138000] evgpeblk-0957 [00] ev_create_gpe_block   : GPE 00 to 1F [_GPE] 4 regs on int 0x9
[    0.138000] ACPI: EC: EC description table is found, configuring boot EC
[    0.148000] Completing Region/Field/Buffer/Package initialization:.........................................................................................................................................................................................................................................................................................
[    0.168000] Initialized 26/26 Regions 142/142 Fields 64/64 Buffers 49/49 Packages (1625 nodes)
[    0.168000] Initializing Device/Processor/Thermal objects by executing _INI methods:...<6>ACPI: EC: non-query interrupt received, switching to interrupt mode
[    0.179000] ....
[    0.182000] Executed 7 _INI methods requiring 2 _STA executions (examined 83 objects)
[    0.183000] evgpeblk-1054 [00] ev_initialize_gpe_bloc: Found 8 Wake, Enabled 2 Runtime GPEs in this block
[    0.183000] ACPI: Interpreter enabled
[    0.183000] ACPI: (supports S0 S3 S5)
[    0.183000] ACPI: Using IOAPIC for interrupt routing
[    0.184000] initcall acpi_init+0x0/0x21b returned 0 after 52 msecs
[    0.184000] calling  acpi_scan_init+0x0/0xf2
[    0.214000] initcall acpi_scan_init+0x0/0xf2 returned 0 after 28 msecs
[    0.214000] calling  acpi_ec_init+0x0/0x5a
[    0.214000] ACPI: EC: GPE = 0x1c, I/O: command/status = 0x66, data = 0x62
[    0.214000] ACPI: EC: driver started in interrupt mode
[    0.215000] initcall acpi_ec_init+0x0/0x5a returned 0 after 0 msecs
[    0.215000] calling  acpi_pci_root_init+0x0/0x2a
[    0.215000] ACPI: PCI Root Bridge [PCI0] (0000:00)
[    0.215000] PCI: 0000:00:02.0 reg 10 32bit mmio: [ee100000, ee17ffff]
[    0.216000] PCI: 0000:00:02.0 reg 14 io port: [1800, 1807]
[    0.216000] PCI: 0000:00:02.0 reg 18 32bit mmio: [d0000000, dfffffff]
[    0.216000] PCI: 0000:00:02.0 reg 1c 32bit mmio: [ee200000, ee23ffff]
[    0.216000] PCI: 0000:00:02.1 reg 10 32bit mmio: [ee180000, ee1fffff]
[    0.216000] pci 0000:00:1b.0: PME# supported from D0 D3hot D3cold
[    0.216000] pci 0000:00:1b.0: PME# disabled
[    0.217000] pci 0000:00:1c.0: PME# supported from D0 D3hot D3cold
[    0.217000] pci 0000:00:1c.0: PME# disabled
[    0.217000] pci 0000:00:1c.1: PME# supported from D0 D3hot D3cold
[    0.217000] pci 0000:00:1c.1: PME# disabled
[    0.217000] pci 0000:00:1c.2: PME# supported from D0 D3hot D3cold
[    0.217000] pci 0000:00:1c.2: PME# disabled
[    0.218000] pci 0000:00:1c.3: PME# supported from D0 D3hot D3cold
[    0.218000] pci 0000:00:1c.3: PME# disabled
[    0.218000] PCI: 0000:00:1d.0 reg 20 io port: [1820, 183f]
[    0.218000] PCI: 0000:00:1d.1 reg 20 io port: [1840, 185f]
[    0.218000] PCI: 0000:00:1d.2 reg 20 io port: [1860, 187f]
[    0.219000] PCI: 0000:00:1d.3 reg 20 io port: [1880, 189f]
[    0.219000] PCI: 0000:00:1d.7 reg 10 32bit mmio: [ee444000, ee4443ff]
[    0.219000] pci 0000:00:1d.7: PME# supported from D0 D3hot D3cold
[    0.219000] pci 0000:00:1d.7: PME# disabled
[    0.219000] pci 0000:00:1f.0: quirk: region 1000-107f claimed by ICH6 ACPI/GPIO/TCO
[    0.220000] pci 0000:00:1f.0: quirk: region 1180-11bf claimed by ICH6 GPIO
[    0.220000] PCI: 0000:00:1f.1 reg 10 io port: [0, 7]
[    0.220000] PCI: 0000:00:1f.1 reg 14 io port: [0, 3]
[    0.220000] PCI: 0000:00:1f.1 reg 18 io port: [0, 7]
[    0.220000] PCI: 0000:00:1f.1 reg 1c io port: [0, 3]
[    0.220000] PCI: 0000:00:1f.1 reg 20 io port: [1810, 181f]
[    0.220000] PCI: 0000:00:1f.2 reg 10 io port: [18d0, 18d7]
[    0.220000] PCI: 0000:00:1f.2 reg 14 io port: [18c4, 18c7]
[    0.221000] PCI: 0000:00:1f.2 reg 18 io port: [18c8, 18cf]
[    0.221000] PCI: 0000:00:1f.2 reg 1c io port: [18c0, 18c3]
[    0.221000] PCI: 0000:00:1f.2 reg 20 io port: [18b0, 18bf]
[    0.221000] PCI: 0000:00:1f.2 reg 24 32bit mmio: [ee444400, ee4447ff]
[    0.221000] pci 0000:00:1f.2: PME# supported from D3hot
[    0.221000] pci 0000:00:1f.2: PME# disabled
[    0.221000] PCI: 0000:00:1f.3 reg 20 io port: [18e0, 18ff]
[    0.222000] PCI: 0000:02:00.0 reg 10 32bit mmio: [ee000000, ee01ffff]
[    0.222000] PCI: 0000:02:00.0 reg 18 io port: [2000, 201f]
[    0.222000] pci 0000:02:00.0: PME# supported from D0 D3hot D3cold
[    0.222000] pci 0000:02:00.0: PME# disabled
[    0.222000] PCI: bridge 0000:00:1c.0 io port: [2000, 2fff]
[    0.223000] PCI: bridge 0000:00:1c.0 32bit mmio: [ee000000, ee0fffff]
[    0.223000] PCI: 0000:03:00.0 reg 10 32bit mmio: [edf00000, edf00fff]
[    0.223000] pci 0000:03:00.0: PME# supported from D0 D3hot D3cold
[    0.224000] pci 0000:03:00.0: PME# disabled
[    0.224000] PCI: bridge 0000:00:1c.1 io port: [3000, 4fff]
[    0.224000] PCI: bridge 0000:00:1c.1 32bit mmio: [ec000000, edffffff]
[    0.224000] PCI: bridge 0000:00:1c.1 64bit mmio pref: [e4000000, e40fffff]
[    0.224000] PCI: bridge 0000:00:1c.2 io port: [5000, 6fff]
[    0.224000] PCI: bridge 0000:00:1c.2 32bit mmio: [e8000000, e9ffffff]
[    0.224000] PCI: bridge 0000:00:1c.2 64bit mmio pref: [e4100000, e41fffff]
[    0.224000] PCI: bridge 0000:00:1c.3 io port: [7000, 8fff]
[    0.225000] PCI: bridge 0000:00:1c.3 32bit mmio: [ea000000, ebffffff]
[    0.225000] PCI: bridge 0000:00:1c.3 64bit mmio pref: [e4200000, e42fffff]
[    0.225000] PCI: 0000:15:00.0 reg 10 32bit mmio: [e4300000, e4300fff]
[    0.225000] pci 0000:15:00.0: supports D1
[    0.225000] pci 0000:15:00.0: supports D2
[    0.225000] pci 0000:15:00.0: PME# supported from D0 D1 D2 D3hot D3cold
[    0.226000] pci 0000:15:00.0: PME# disabled
[    0.226000] pci 0000:00:1e.0: transparent bridge
[    0.226000] PCI: bridge 0000:00:1e.0 io port: [9000, cfff]
[    0.227000] PCI: bridge 0000:00:1e.0 32bit mmio: [e4300000, e7ffffff]
[    0.227000] PCI: bridge 0000:00:1e.0 64bit mmio pref: [e0000000, e3ffffff]
[    0.227000] bus 00 -> node 0
[    0.227000] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0._PRT]
[    0.227000] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.EXP0._PRT]
[    0.228000] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.EXP1._PRT]
[    0.228000] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.EXP2._PRT]
[    0.229000] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.EXP3._PRT]
[    0.229000] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PCI1._PRT]
[    0.241000] initcall acpi_pci_root_init+0x0/0x2a returned 0 after 24 msecs
[    0.242000] calling  acpi_pci_link_init+0x0/0x48
[    0.242000] ACPI: PCI Interrupt Link [LNKA] (IRQs 3 4 5 6 7 9 10 *11)
[    0.243000] ACPI: PCI Interrupt Link [LNKB] (IRQs 3 4 5 6 7 9 10 *11)
[    0.244000] ACPI: PCI Interrupt Link [LNKC] (IRQs 3 4 5 6 7 9 10 *11)
[    0.245000] ACPI: PCI Interrupt Link [LNKD] (IRQs 3 4 5 6 7 9 10 *11)
[    0.246000] ACPI: PCI Interrupt Link [LNKE] (IRQs 3 4 5 6 7 9 10 *11)
[    0.246000] ACPI: PCI Interrupt Link [LNKF] (IRQs 3 4 5 6 7 9 10 *11)
[    0.247000] ACPI: PCI Interrupt Link [LNKG] (IRQs 3 4 5 6 7 9 10 *11)
[    0.248000] ACPI: PCI Interrupt Link [LNKH] (IRQs 3 4 5 6 7 9 10 *11)
[    0.249000] initcall acpi_pci_link_init+0x0/0x48 returned 0 after 6 msecs
[    0.249000] calling  acpi_power_init+0x0/0x6e
[    0.250000] ACPI: Power Resource [PUBS] (on)
[    0.250000] initcall acpi_power_init+0x0/0x6e returned 0 after 0 msecs
[    0.250000] calling  acpi_system_init+0x0/0x209
[    0.251000] initcall acpi_system_init+0x0/0x209 returned 0 after 0 msecs
[    0.251000] calling  acpi_debug_init+0x0/0x9e
[    0.251000] initcall acpi_debug_init+0x0/0x9e returned 0 after 0 msecs
[    0.251000] calling  acpi_cm_sbs_init+0x0/0xc
[    0.251000] initcall acpi_cm_sbs_init+0x0/0xc returned 0 after 0 msecs
[    0.251000] calling  pnp_init+0x0/0x1e
[    0.251000] Linux Plug and Play Support v0.97 (c) Adam Belay
[    0.252000] initcall pnp_init+0x0/0x1e returned 0 after 0 msecs
[    0.252000] calling  pnpacpi_init+0x0/0x80
[    0.252000] pnp: PnP ACPI init
[    0.252000] ACPI: bus type pnp registered
[    0.262000] pnp: PnP ACPI: found 11 devices
[    0.262000] ACPI: ACPI bus type pnp unregistered
[    0.262000] initcall pnpacpi_init+0x0/0x80 returned 0 after 9 msecs
[    0.262000] calling  pnpbios_init+0x0/0x313
[    0.262000] PnPBIOS: Disabled by ACPI PNP
[    0.262000] initcall pnpbios_init+0x0/0x313 returned -19 after 0 msecs
[    0.262000] calling  misc_init+0x0/0x84
[    0.262000] initcall misc_init+0x0/0x84 returned 0 after 0 msecs
[    0.263000] calling  tifm_init+0x0/0x72
[    0.263000] initcall tifm_init+0x0/0x72 returned 0 after 0 msecs
[    0.263000] calling  phy_init+0x0/0x2e
[    0.263000] initcall phy_init+0x0/0x2e returned 0 after 0 msecs
[    0.263000] calling  init_scsi+0x0/0x7e
[    0.264000] SCSI subsystem initialized
[    0.264000] initcall init_scsi+0x0/0x7e returned 0 after 0 msecs
[    0.264000] calling  ata_init+0x0/0x2a9
[    0.264000] libata version 3.00 loaded.
[    0.265000] initcall ata_init+0x0/0x2a9 returned 0 after 0 msecs
[    0.265000] calling  usb_init+0x0/0x112
[    0.265000] usbcore: registered new interface driver usbfs
[    0.265000] usbcore: registered new interface driver hub
[    0.265000] usbcore: registered new device driver usb
[    0.266000] initcall usb_init+0x0/0x112 returned 0 after 0 msecs
[    0.266000] calling  serio_init+0x0/0x87
[    0.266000] initcall serio_init+0x0/0x87 returned 0 after 0 msecs
[    0.266000] calling  gameport_init+0x0/0x87
[    0.266000] initcall gameport_init+0x0/0x87 returned 0 after 0 msecs
[    0.266000] calling  input_init+0x0/0xe2
[    0.267000] initcall input_init+0x0/0xe2 returned 0 after 0 msecs
[    0.267000] calling  i2c_init+0x0/0x54
[    0.267000] initcall i2c_init+0x0/0x54 returned 0 after 0 msecs
[    0.267000] calling  power_supply_class_init+0x0/0x2e
[    0.267000] initcall power_supply_class_init+0x0/0x2e returned 0 after 0 msecs
[    0.268000] calling  mmc_init+0x0/0x70
[    0.268000] initcall mmc_init+0x0/0x70 returned 0 after 0 msecs
[    0.268000] calling  leds_init+0x0/0x2c
[    0.268000] initcall leds_init+0x0/0x2c returned 0 after 0 msecs
[    0.268000] calling  pci_subsys_init+0x0/0xeb
[    0.268000] PCI: Using ACPI for IRQ routing
[    0.269000] number of MP IRQ sources: 15.
[    0.269000] number of IO-APIC #1 registers: 24.
[    0.269000] testing the IO APIC.......................
[    0.269000] IO APIC #1......
[    0.269000] .... register #00: 02000000
[    0.269000] .......    : physical APIC id: 02
[    0.269000] .......    : Delivery Type: 0
[    0.269000] .......    : LTS          : 0
[    0.269000] .... register #01: 00170020
[    0.269000] .......     : max redirection entries: 0017
[    0.269000] .......     : PRQ implemented: 0
[    0.270000] .......     : IO APIC version: 0020
[    0.270000] .... IRQ redirection table:
[    0.270000]  NR Log Phy Mask Trig IRR Pol Stat Dest Deli Vect:   
[    0.270000]  00 000 00  1    0    0   0   0    0    0    00
[    0.270000]  01 003 03  1    0    0   0   0    1    1    39
[    0.270000]  02 003 03  0    0    0   0   0    1    1    31
[    0.270000]  03 003 03  1    0    0   0   0    1    1    41
[    0.270000]  04 003 03  0    0    0   0   0    1    1    49
[    0.271000]  05 003 03  0    0    0   0   0    1    1    51
[    0.271000]  06 003 03  0    0    0   0   0    1    1    59
[    0.271000]  07 003 03  0    0    0   0   0    1    1    61
[    0.271000]  08 003 03  1    0    0   0   0    1    1    69
[    0.271000]  09 003 03  0    1    0   0   0    1    1    71
[    0.271000]  0a 003 03  0    0    0   0   0    1    1    79
[    0.271000]  0b 003 03  0    0    0   0   0    1    1    81
[    0.271000]  0c 003 03  1    0    0   0   0    1    1    89
[    0.272000]  0d 003 03  1    0    0   0   0    1    1    91
[    0.272000]  0e 003 03  0    0    0   0   0    1    1    99
[    0.272000]  0f 003 03  0    0    0   0   0    1    1    A1
[    0.272000]  10 000 00  1    0    0   0   0    0    0    00
[    0.272000]  11 000 00  1    0    0   0   0    0    0    00
[    0.272000]  12 000 00  1    0    0   0   0    0    0    00
[    0.272000]  13 000 00  1    0    0   0   0    0    0    00
[    0.273000]  14 000 00  1    0    0   0   0    0    0    00
[    0.273000]  15 000 00  1    0    0   0   0    0    0    00
[    0.273000]  16 000 00  1    0    0   0   0    0    0    00
[    0.273000]  17 000 00  1    0    0   0   0    0    0    00
[    0.273000] IRQ to pin mappings:
[    0.273000] IRQ0 -> 0:2
[    0.273000] IRQ1 -> 0:1
[    0.274000] IRQ3 -> 0:3
[    0.274000] IRQ4 -> 0:4
[    0.274000] IRQ5 -> 0:5
[    0.274000] IRQ6 -> 0:6
[    0.274000] IRQ7 -> 0:7
[    0.274000] IRQ8 -> 0:8
[    0.275000] IRQ9 -> 0:9
[    0.275000] IRQ10 -> 0:10
[    0.275000] IRQ11 -> 0:11
[    0.275000] IRQ12 -> 0:12
[    0.275000] IRQ13 -> 0:13
[    0.275000] IRQ14 -> 0:14
[    0.276000] IRQ15 -> 0:15
[    0.276000] .................................... done.
[    0.276000] initcall pci_subsys_init+0x0/0xeb returned 0 after 7 msecs
[    0.276000] calling  proto_init+0x0/0x2c
[    0.277000] initcall proto_init+0x0/0x2c returned 0 after 0 msecs
[    0.277000] calling  net_dev_init+0x0/0x134
[    0.277000] initcall net_dev_init+0x0/0x134 returned 0 after 0 msecs
[    0.277000] calling  neigh_init+0x0/0x6b
[    0.277000] initcall neigh_init+0x0/0x6b returned 0 after 0 msecs
[    0.277000] calling  fib_rules_init+0x0/0x9e
[    0.277000] initcall fib_rules_init+0x0/0x9e returned 0 after 0 msecs
[    0.277000] calling  genl_init+0x0/0xb5
[    0.278000] initcall genl_init+0x0/0xb5 returned 0 after 0 msecs
[    0.278000] calling  cipso_v4_init+0x0/0x72
[    0.278000] initcall cipso_v4_init+0x0/0x72 returned 0 after 0 msecs
[    0.278000] calling  wanrouter_init+0x0/0x47
[    0.278000] Sangoma WANPIPE Router v1.1 (c) 1995-2000 Sangoma Technologies Inc.
[    0.278000] initcall wanrouter_init+0x0/0x47 returned 0 after 0 msecs
[    0.278000] calling  irda_init+0x0/0x8d
[    0.278000] NET: Registered protocol family 23
[    0.279000] initcall irda_init+0x0/0x8d returned 0 after 0 msecs
[    0.279000] calling  atm_init+0x0/0xa1
[    0.279000] NET: Registered protocol family 8
[    0.279000] NET: Registered protocol family 20
[    0.279000] initcall atm_init+0x0/0xa1 returned 0 after 0 msecs
[    0.279000] calling  wireless_nlevent_init+0x0/0x3e
[    0.279000] initcall wireless_nlevent_init+0x0/0x3e returned 0 after 0 msecs
[    0.279000] calling  netlbl_init+0x0/0x72
[    0.280000] NetLabel: Initializing
[    0.280000] NetLabel:  domain hash size = 128
[    0.280000] NetLabel:  protocols = UNLABELED CIPSOv4
[    0.280000] NetLabel:  unlabeled traffic allowed by default
[    0.280000] initcall netlbl_init+0x0/0x72 returned 0 after 0 msecs
[    0.280000] calling  sysctl_init+0x0/0x28
[    0.280000] initcall sysctl_init+0x0/0x28 returned 0 after 0 msecs
[    0.280000] calling  pci_iommu_init+0x0/0x11
[    0.280000] initcall pci_iommu_init+0x0/0x11 returned 0 after 0 msecs
[    0.281000] calling  init_kmmio+0x0/0x28
[    0.281000] initcall init_kmmio+0x0/0x28 returned 0 after 0 msecs
[    0.281000] calling  clocksource_done_booting+0x0/0x16
[    0.281000] initcall clocksource_done_booting+0x0/0x16 returned 0 after 0 msecs
[    0.281000] calling  tracer_alloc_buffers+0x0/0x47b
[    0.283000] tracer: 772 pages allocated for 65536 entries of 48 bytes
[    0.283000]    actual entries 65620
[    0.283000] initcall tracer_alloc_buffers+0x0/0x47b returned 0 after 1 msecs
[    0.283000] calling  init_pipe_fs+0x0/0x46
[    0.283000] initcall init_pipe_fs+0x0/0x46 returned 0 after 0 msecs
[    0.284000] calling  init_mnt_writers+0x0/0x66
[    0.284000] initcall init_mnt_writers+0x0/0x66 returned 0 after 0 msecs
[    0.285000] calling  eventpoll_init+0x0/0x82
[    0.285000] initcall eventpoll_init+0x0/0x82 returned 0 after 0 msecs
[    0.285000] calling  anon_inode_init+0x0/0xe4
[    0.285000] initcall anon_inode_init+0x0/0xe4 returned 0 after 0 msecs
[    0.285000] calling  acpi_event_init+0x0/0x74
[    0.285000] initcall acpi_event_init+0x0/0x74 returned 0 after 0 msecs
[    0.285000] calling  pnp_system_init+0x0/0x14
[    0.286000] system 00:00: iomem range 0x0-0x9ffff could not be reserved
[    0.286000] system 00:00: iomem range 0xc0000-0xc3fff could not be reserved
[    0.286000] system 00:00: iomem range 0xc4000-0xc7fff could not be reserved
[    0.286000] system 00:00: iomem range 0xc8000-0xcbfff has been reserved
[    0.286000] system 00:00: iomem range 0xcc000-0xcffff could not be reserved
[    0.286000] system 00:00: iomem range 0xd0000-0xd3fff could not be reserved
[    0.286000] system 00:00: iomem range 0xdc000-0xdffff could not be reserved
[    0.286000] system 00:00: iomem range 0xe0000-0xe3fff could not be reserved
[    0.286000] system 00:00: iomem range 0xe4000-0xe7fff could not be reserved
[    0.286000] system 00:00: iomem range 0xe8000-0xebfff could not be reserved
[    0.286000] system 00:00: iomem range 0xec000-0xeffff could not be reserved
[    0.287000] system 00:00: iomem range 0xf0000-0xfffff could not be reserved
[    0.287000] system 00:00: iomem range 0x100000-0x7fffffff could not be reserved
[    0.287000] system 00:00: iomem range 0xfec00000-0xffffffff could not be reserved
[    0.287000] system 00:02: ioport range 0x164e-0x164f has been reserved
[    0.287000] system 00:02: ioport range 0x1000-0x107f has been reserved
[    0.287000] system 00:02: ioport range 0x1180-0x11bf has been reserved
[    0.287000] system 00:02: ioport range 0x800-0x80f has been reserved
[    0.287000] system 00:02: ioport range 0x15e0-0x15ef has been reserved
[    0.287000] system 00:02: ioport range 0x1600-0x165f could not be reserved
[    0.288000] system 00:02: iomem range 0xf0000000-0xf3ffffff could not be reserved
[    0.288000] system 00:02: iomem range 0xfed1c000-0xfed1ffff could not be reserved
[    0.288000] system 00:02: iomem range 0xfed14000-0xfed17fff could not be reserved
[    0.288000] system 00:02: iomem range 0xfed18000-0xfed18fff could not be reserved
[    0.288000] system 00:02: iomem range 0xfed19000-0xfed19fff could not be reserved
[    0.288000] initcall pnp_system_init+0x0/0x14 returned 0 after 2 msecs
[    0.289000] calling  chr_dev_init+0x0/0x8b
[    0.289000] initcall chr_dev_init+0x0/0x8b returned 0 after 0 msecs
[    0.290000] calling  firmware_class_init+0x0/0x61
[    0.290000] initcall firmware_class_init+0x0/0x61 returned 0 after 0 msecs
[    0.290000] calling  loopback_init+0x0/0x14
[    0.290000] initcall loopback_init+0x0/0x14 returned 0 after 0 msecs
[    0.290000] calling  init_acpi_pm_clocksource+0x0/0x150
[    0.321000] PM-Timer running at invalid rate: 87% of normal - aborting.
[    0.321000] initcall init_acpi_pm_clocksource+0x0/0x150 returned -19 after 28 msecs
[    0.321000] calling  pcibios_assign_resources+0x0/0x96
[    0.321000] pci 0000:00:1c.0: PCI bridge, secondary bus 0000:02
[    0.321000] pci 0000:00:1c.0:   IO window: 0x2000-0x2fff
[    0.321000] pci 0000:00:1c.0:   MEM window: 0xee000000-0xee0fffff
[    0.321000] pci 0000:00:1c.0:   PREFETCH window: disabled
[    0.321000] pci 0000:00:1c.1: PCI bridge, secondary bus 0000:03
[    0.321000] pci 0000:00:1c.1:   IO window: 0x3000-0x4fff
[    0.322000] pci 0000:00:1c.1:   MEM window: 0xec000000-0xedffffff
[    0.322000] pci 0000:00:1c.1:   PREFETCH window: 0x000000e4000000-0x000000e40fffff
[    0.322000] pci 0000:00:1c.2: PCI bridge, secondary bus 0000:04
[    0.322000] pci 0000:00:1c.2:   IO window: 0x5000-0x6fff
[    0.322000] pci 0000:00:1c.2:   MEM window: 0xe8000000-0xe9ffffff
[    0.322000] pci 0000:00:1c.2:   PREFETCH window: 0x000000e4100000-0x000000e41fffff
[    0.322000] pci 0000:00:1c.3: PCI bridge, secondary bus 0000:0c
[    0.322000] pci 0000:00:1c.3:   IO window: 0x7000-0x8fff
[    0.322000] pci 0000:00:1c.3:   MEM window: 0xea000000-0xebffffff
[    0.323000] pci 0000:00:1c.3:   PREFETCH window: 0x000000e4200000-0x000000e42fffff
[    0.323000] pci 0000:15:00.0: CardBus bridge, secondary bus 0000:16
[    0.323000] pci 0000:15:00.0:   IO window: 0x009000-0x0090ff
[    0.323000] pci 0000:15:00.0:   IO window: 0x009400-0x0094ff
[    0.323000] pci 0000:15:00.0:   PREFETCH window: 0xe0000000-0xe3ffffff
[    0.323000] pci 0000:15:00.0:   MEM window: 0x88000000-0x8bffffff
[    0.323000] pci 0000:00:1e.0: PCI bridge, secondary bus 0000:15
[    0.323000] pci 0000:00:1e.0:   IO window: 0x9000-0xcfff
[    0.323000] pci 0000:00:1e.0:   MEM window: 0xe4300000-0xe7ffffff
[    0.324000] pci 0000:00:1e.0:   PREFETCH window: 0x000000e0000000-0x000000e3ffffff
[    0.324000] pci 0000:00:1c.0: PCI INT A -> GSI 20 (level, low) -> IRQ 20
[    0.324000] PCI: Setting latency timer of device 0000:00:1c.0 to 64
[    0.324000] pci 0000:00:1c.1: PCI INT B -> GSI 21 (level, low) -> IRQ 21
[    0.324000] PCI: Setting latency timer of device 0000:00:1c.1 to 64
[    0.324000] pci 0000:00:1c.2: PCI INT C -> GSI 22 (level, low) -> IRQ 22
[    0.324000] PCI: Setting latency timer of device 0000:00:1c.2 to 64
[    0.324000] pci 0000:00:1c.3: PCI INT D -> GSI 23 (level, low) -> IRQ 23
[    0.324000] PCI: Setting latency timer of device 0000:00:1c.3 to 64
[    0.325000] pci 0000:00:1e.0: enabling device (0005 -> 0007)
[    0.325000] PCI: Setting latency timer of device 0000:00:1e.0 to 64
[    0.325000] vendor=8086 device=2448
[    0.325000] pci 0000:15:00.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
[    0.325000] bus: 00 index 0 io port: [0, ffff]
[    0.325000] bus: 00 index 1 mmio: [0, ffffffffffffffff]
[    0.325000] bus: 02 index 0 io port: [2000, 2fff]
[    0.325000] bus: 02 index 1 mmio: [ee000000, ee0fffff]
[    0.325000] bus: 02 index 2 mmio: [0, 0]
[    0.325000] bus: 02 index 3 mmio: [0, 0]
[    0.326000] bus: 03 index 0 io port: [3000, 4fff]
[    0.326000] bus: 03 index 1 mmio: [ec000000, edffffff]
[    0.326000] bus: 03 index 2 mmio: [e4000000, e40fffff]
[    0.326000] bus: 03 index 3 mmio: [0, 0]
[    0.326000] bus: 04 index 0 io port: [5000, 6fff]
[    0.326000] bus: 04 index 1 mmio: [e8000000, e9ffffff]
[    0.326000] bus: 04 index 2 mmio: [e4100000, e41fffff]
[    0.326000] bus: 04 index 3 mmio: [0, 0]
[    0.326000] bus: 0c index 0 io port: [7000, 8fff]
[    0.326000] bus: 0c index 1 mmio: [ea000000, ebffffff]
[    0.326000] bus: 0c index 2 mmio: [e4200000, e42fffff]
[    0.327000] bus: 0c index 3 mmio: [0, 0]
[    0.327000] bus: 15 index 0 io port: [9000, cfff]
[    0.327000] bus: 15 index 1 mmio: [e4300000, e7ffffff]
[    0.327000] bus: 15 index 2 mmio: [e0000000, e3ffffff]
[    0.327000] bus: 15 index 3 io port: [0, ffff]
[    0.327000] bus: 15 index 4 mmio: [0, ffffffffffffffff]
[    0.327000] bus: 16 index 0 io port: [9000, 90ff]
[    0.327000] bus: 16 index 1 io port: [9400, 94ff]
[    0.327000] bus: 16 index 2 mmio: [e0000000, e3ffffff]
[    0.327000] bus: 16 index 3 mmio: [88000000, 8bffffff]
[    0.327000] initcall pcibios_assign_resources+0x0/0x96 returned 0 after 5 msecs
[    0.328000] calling  inet_init+0x0/0x376
[    0.328000] NET: Registered protocol family 2
[    0.328000] IP route cache hash table entries: 65536 (order: 6, 262144 bytes)
[    0.329000] TCP established hash table entries: 262144 (order: 9, 2097152 bytes)
[    0.331000] TCP bind hash table entries: 65536 (order: 9, 2359296 bytes)
[    0.335000] TCP: Hash tables configured (established 262144 bind 65536)
[    0.336000] TCP reno registered
[    0.336000] initcall inet_init+0x0/0x376 returned 0 after 7 msecs
[    0.336000] calling  af_unix_init+0x0/0x4c
[    0.336000] NET: Registered protocol family 1
[    0.336000] initcall af_unix_init+0x0/0x4c returned 0 after 0 msecs
[    0.336000] calling  default_rootfs+0x0/0x68
[    0.336000] initcall default_rootfs+0x0/0x68 returned 0 after 0 msecs
[    0.337000] calling  vmx_init+0x0/0x1d7
[    0.337000] initcall vmx_init+0x0/0x1d7 returned 0 after 0 msecs
[    0.338000] calling  svm_init+0x0/0x1b
[    0.338000] kvm: already loaded the other module
[    0.338000] initcall svm_init+0x0/0x1b returned -17 after 0 msecs
[    0.338000] initcall svm_init+0x0/0x1b returned with error code -17 
[    0.338000] calling  i8259A_init_sysfs+0x0/0x22
[    0.338000] initcall i8259A_init_sysfs+0x0/0x22 returned 0 after 0 msecs
[    0.339000] calling  sbf_init+0x0/0xc2
[    0.339000] Simple Boot Flag at 0x35 set to 0x1
[    0.339000] initcall sbf_init+0x0/0xc2 returned 0 after 0 msecs
[    0.339000] calling  i8237A_init_sysfs+0x0/0x22
[    0.339000] initcall i8237A_init_sysfs+0x0/0x22 returned 0 after 0 msecs
[    0.339000] calling  add_rtc_cmos+0x0/0x1a
[    0.339000] initcall add_rtc_cmos+0x0/0x1a returned 0 after 0 msecs
[    0.340000] calling  cache_sysfs_init+0x0/0x4c
[    0.340000] initcall cache_sysfs_init+0x0/0x4c returned 0 after 0 msecs
[    0.341000] calling  thermal_throttle_init_device+0x0/0x6e
[    0.341000] initcall thermal_throttle_init_device+0x0/0x6e returned 0 after 0 msecs
[    0.341000] calling  msr_init+0x0/0xcb
[    0.341000] initcall msr_init+0x0/0xcb returned 0 after 0 msecs
[    0.341000] calling  microcode_init+0x0/0xa7
[    0.341000] IA-32 Microcode Update Driver: v1.14a <tigran@aivazian.fsnet.co.uk>
[    0.342000] initcall microcode_init+0x0/0xa7 returned 0 after 0 msecs
[    0.342000] calling  init_lapic_sysfs+0x0/0x2d
[    0.342000] initcall init_lapic_sysfs+0x0/0x2d returned 0 after 0 msecs
[    0.342000] calling  ioapic_init_sysfs+0x0/0x89
[    0.343000] initcall ioapic_init_sysfs+0x0/0x89 returned 0 after 0 msecs
[    0.343000] calling  add_pcspkr+0x0/0x3a
[    0.343000] initcall add_pcspkr+0x0/0x3a returned 0 after 0 msecs
[    0.343000] calling  init+0x0/0x14
[    0.343000] initcall init+0x0/0x14 returned 0 after 0 msecs
[    0.343000] calling  init+0x0/0x14
[    0.343000] initcall init+0x0/0x14 returned 0 after 0 msecs
[    0.344000] calling  create_proc_profile+0x0/0x170
[    0.344000] initcall create_proc_profile+0x0/0x170 returned 0 after 0 msecs
[    0.344000] calling  ioresources_init+0x0/0x36
[    0.344000] initcall ioresources_init+0x0/0x36 returned 0 after 0 msecs
[    0.344000] calling  uid_cache_init+0x0/0x63
[    0.344000] initcall uid_cache_init+0x0/0x63 returned 0 after 0 msecs
[    0.344000] calling  init_posix_timers+0x0/0x81
[    0.345000] initcall init_posix_timers+0x0/0x81 returned 0 after 0 msecs
[    0.345000] calling  init_posix_cpu_timers+0x0/0x95
[    0.346000] initcall init_posix_cpu_timers+0x0/0x95 returned 0 after 0 msecs
[    0.346000] calling  nsproxy_cache_init+0x0/0x2c
[    0.346000] initcall nsproxy_cache_init+0x0/0x2c returned 0 after 0 msecs
[    0.346000] calling  timekeeping_init_device+0x0/0x22
[    0.346000] initcall timekeeping_init_device+0x0/0x22 returned 0 after 0 msecs
[    0.346000] calling  init_clocksource_sysfs+0x0/0x48
[    0.347000] initcall init_clocksource_sysfs+0x0/0x48 returned 0 after 0 msecs
[    0.347000] calling  init_timer_list_procfs+0x0/0x2c
[    0.347000] initcall init_timer_list_procfs+0x0/0x2c returned 0 after 0 msecs
[    0.347000] calling  lockdep_proc_init+0x0/0x4f
[    0.347000] initcall lockdep_proc_init+0x0/0x4f returned 0 after 0 msecs
[    0.347000] calling  futex_init+0x0/0x74
[    0.347000] initcall futex_init+0x0/0x74 returned 0 after 0 msecs
[    0.347000] calling  proc_dma_init+0x0/0x21
[    0.348000] initcall proc_dma_init+0x0/0x21 returned 0 after 0 msecs
[    0.348000] calling  percpu_modinit+0x0/0x69
[    0.348000] initcall percpu_modinit+0x0/0x69 returned 0 after 0 msecs
[    0.348000] calling  kallsyms_init+0x0/0x24
[    0.348000] initcall kallsyms_init+0x0/0x24 returned 0 after 0 msecs
[    0.348000] calling  init_kprobes+0x0/0x101
[    0.353000] Kprobe smoke test started
[    0.356000] Kprobe smoke test passed successfully
[    0.356000] initcall init_kprobes+0x0/0x101 returned 0 after 7 msecs
[    0.356000] calling  rcu_torture_init+0x0/0x562
[    0.356000] rcu-torture:--- Start of test: nreaders=4 nfakewriters=4 stat_interval=0 verbose=0 test_no_idle_hz=0 shuffle_interval=3 stutter=5 irqreader=1
[    0.357000] initcall rcu_torture_init+0x0/0x562 returned 0 after 0 msecs
[    0.357000] calling  relay_init+0x0/0x16
[    0.357000] initcall relay_init+0x0/0x16 returned 0 after 0 msecs
[    0.357000] calling  utsname_sysctl_init+0x0/0x16
[    0.357000] initcall utsname_sysctl_init+0x0/0x16 returned 0 after 0 msecs
[    0.357000] calling  init_sched_switch_trace+0x0/0x38
[    0.357000] Testing tracer sched_switch: PASSED
[    0.459000] initcall init_sched_switch_trace+0x0/0x38 returned 0 after 97 msecs
[    0.459000] calling  init_function_trace+0x0/0xf
[    0.459000] Testing tracer ftrace: PASSED
[    0.565500] initcall init_function_trace+0x0/0xf returned 0 after 101 msecs
[    0.565500] calling  init_irqsoff_tracer+0x0/0x11
[    0.565500] Testing tracer preemptoff: .. no entries found ..FAILED!
[    0.566500] initcall init_irqsoff_tracer+0x0/0x11 returned 0 after 0 msecs
[    0.567500] calling  init_wakeup_tracer+0x0/0xf
[    0.567500] Testing tracer wakeup: .. no entries found ..FAILED!
[    0.769500] initcall init_wakeup_tracer+0x0/0xf returned -1 after 192 msecs
[    0.769500] initcall init_wakeup_tracer+0x0/0xf returned with error code -1 
[    0.769500] calling  init_mmio_trace+0x0/0xf
[    0.769500] initcall init_mmio_trace+0x0/0xf returned 0 after 0 msecs
[    0.769500] calling  init_per_zone_pages_min+0x0/0x4d
[    0.769500] initcall init_per_zone_pages_min+0x0/0x4d returned 0 after 0 msecs
[    0.770500] calling  pdflush_init+0x0/0x1b
[    0.770500] initcall pdflush_init+0x0/0x1b returned 0 after 0 msecs
[    0.770500] calling  kswapd_init+0x0/0x22
[    0.770500] initcall kswapd_init+0x0/0x22 returned 0 after 0 msecs
[    0.770500] calling  setup_vmstat+0x0/0x3c
[    0.770500] initcall setup_vmstat+0x0/0x3c returned 0 after 0 msecs
[    0.770500] calling  init_emergency_pool+0x0/0x5d
[    0.770500] highmem bounce pool size: 64 pages
[    0.771500] initcall init_emergency_pool+0x0/0x5d returned 0 after 0 msecs
[    0.771500] calling  init_tmpfs+0x0/0xbe
[    0.771500] initcall init_tmpfs+0x0/0xbe returned 0 after 0 msecs
[    0.771500] calling  cpucache_init+0x0/0x2d
[    0.771500] initcall cpucache_init+0x0/0x2d returned 0 after 0 msecs
[    0.771500] calling  fasync_init+0x0/0x29
[    0.771500] initcall fasync_init+0x0/0x29 returned 0 after 0 msecs
[    0.771500] calling  aio_setup+0x0/0x69
[    0.772500] initcall aio_setup+0x0/0x69 returned 0 after 0 msecs
[    0.772500] calling  init_mbcache+0x0/0x16
[    0.772500] initcall init_mbcache+0x0/0x16 returned 0 after 0 msecs
[    0.772500] calling  dquot_init+0x0/0xc6
[    0.772500] VFS: Disk quotas dquot_6.5.1
[    0.772500] Dquot-cache hash table entries: 1024 (order 0, 4096 bytes)
[    0.772500] initcall dquot_init+0x0/0xc6 returned 0 after 0 msecs
[    0.772500] calling  init_devpts_fs+0x0/0x38
[    0.773500] initcall init_devpts_fs+0x0/0x38 returned 0 after 0 msecs
[    0.773500] calling  init_ext3_fs+0x0/0x64
[    0.773500] initcall init_ext3_fs+0x0/0x64 returned 0 after 0 msecs
[    0.773500] calling  journal_init+0x0/0x8a
[    0.773500] initcall journal_init+0x0/0x8a returned 0 after 0 msecs
[    0.773500] calling  init_ramfs_fs+0x0/0x14
[    0.773500] initcall init_ramfs_fs+0x0/0x14 returned 0 after 0 msecs
[    0.774500] calling  vxfs_init+0x0/0x52
[    0.774500] initcall vxfs_init+0x0/0x52 returned 0 after 0 msecs
[    0.774500] calling  init_nls_cp855+0x0/0x14
[    0.774500] initcall init_nls_cp855+0x0/0x14 returned 0 after 0 msecs
[    0.774500] calling  init_nls_cp860+0x0/0x14
[    0.774500] initcall init_nls_cp860+0x0/0x14 returned 0 after 0 msecs
[    0.774500] calling  init_nls_cp864+0x0/0x14
[    0.774500] initcall init_nls_cp864+0x0/0x14 returned 0 after 0 msecs
[    0.774500] calling  init_nls_cp869+0x0/0x14
[    0.775500] initcall init_nls_cp869+0x0/0x14 returned 0 after 0 msecs
[    0.775500] calling  init_nls_cp949+0x0/0x14
[    0.775500] initcall init_nls_cp949+0x0/0x14 returned 0 after 0 msecs
[    0.775500] calling  init_nls_cp1251+0x0/0x14
[    0.775500] initcall init_nls_cp1251+0x0/0x14 returned 0 after 0 msecs
[    0.775500] calling  init_nls_iso8859_5+0x0/0x14
[    0.775500] initcall init_nls_iso8859_5+0x0/0x14 returned 0 after 0 msecs
[    0.775500] calling  init_nls_iso8859_7+0x0/0x14
[    0.775500] initcall init_nls_iso8859_7+0x0/0x14 returned 0 after 0 msecs
[    0.776500] calling  init_nls_cp1255+0x0/0x14
[    0.776500] initcall init_nls_cp1255+0x0/0x14 returned 0 after 0 msecs
[    0.776500] calling  init_nls_iso8859_9+0x0/0x14
[    0.776500] initcall init_nls_iso8859_9+0x0/0x14 returned 0 after 0 msecs
[    0.776500] calling  init_nls_utf8+0x0/0x24
[    0.776500] initcall init_nls_utf8+0x0/0x24 returned 0 after 0 msecs
[    0.776500] calling  init_sysv_fs+0x0/0x48
[    0.776500] initcall init_sysv_fs+0x0/0x48 returned 0 after 0 msecs
[    0.777500] calling  init_ufs_fs+0x0/0x54
[    0.777500] initcall init_ufs_fs+0x0/0x54 returned 0 after 0 msecs
[    0.777500] calling  init_jfs_fs+0x0/0x188
[    0.777500] JFS: nTxBlock = 8192, nTxLock = 65536
[    0.782500] initcall init_jfs_fs+0x0/0x188 returned 0 after 4 msecs
[    0.782500] calling  init_xfs_fs+0x0/0x5f
[    0.782500] SGI XFS with ACLs, security attributes, no debug enabled
[    0.783500] SGI XFS Quota Management subsystem
[    0.783500] initcall init_xfs_fs+0x0/0x5f returned 0 after 0 msecs
[    0.783500] calling  ipc_init+0x0/0x25
[    0.783500] msgmni has been set to 2176
[    0.784500] initcall ipc_init+0x0/0x25 returned 0 after 0 msecs
[    0.784500] calling  ipc_sysctl_init+0x0/0x16
[    0.784500] initcall ipc_sysctl_init+0x0/0x16 returned 0 after 0 msecs
[    0.784500] calling  init_mqueue_fs+0x0/0xbb
[    0.784500] initcall init_mqueue_fs+0x0/0xbb returned 0 after 0 msecs
[    0.784500] calling  key_proc_init+0x0/0x53
[    0.784500] initcall key_proc_init+0x0/0x53 returned 0 after 0 msecs
[    0.785500] calling  crypto_algapi_init+0x0/0x11
[    0.785500] initcall crypto_algapi_init+0x0/0x11 returned 0 after 0 msecs
[    0.785500] calling  blkcipher_module_init+0x0/0x29
[    0.785500] initcall blkcipher_module_init+0x0/0x29 returned 0 after 0 msecs
[    0.785500] calling  seqiv_module_init+0x0/0x14
[    0.785500] initcall seqiv_module_init+0x0/0x14 returned 0 after 0 msecs
[    0.785500] calling  cryptomgr_init+0x0/0x14
[    0.785500] initcall cryptomgr_init+0x0/0x14 returned 0 after 0 msecs
[    0.785500] calling  hmac_module_init+0x0/0x14
[    0.786500] initcall hmac_module_init+0x0/0x14 returned 0 after 0 msecs
[    0.786500] calling  crypto_xcbc_module_init+0x0/0x14
[    0.786500] initcall crypto_xcbc_module_init+0x0/0x14 returned 0 after 0 msecs
[    0.786500] calling  crypto_null_mod_init+0x0/0x6c
[    0.786500] initcall crypto_null_mod_init+0x0/0x6c returned 0 after 0 msecs
[    0.786500] calling  md5_mod_init+0x0/0x14
[    0.786500] initcall md5_mod_init+0x0/0x14 returned 0 after 0 msecs
[    0.786500] calling  sha1_generic_mod_init+0x0/0x14
[    0.786500] initcall sha1_generic_mod_init+0x0/0x14 returned 0 after 0 msecs
[    0.787500] calling  sha512_generic_mod_init+0x0/0x38
[    0.787500] initcall sha512_generic_mod_init+0x0/0x38 returned 0 after 0 msecs
[    0.787500] calling  crypto_ecb_module_init+0x0/0x14
[    0.787500] initcall crypto_ecb_module_init+0x0/0x14 returned 0 after 0 msecs
[    0.787500] calling  crypto_cbc_module_init+0x0/0x14
[    0.787500] initcall crypto_cbc_module_init+0x0/0x14 returned 0 after 0 msecs
[    0.787500] calling  crypto_pcbc_module_init+0x0/0x14
[    0.787500] initcall crypto_pcbc_module_init+0x0/0x14 returned 0 after 0 msecs
[    0.788500] calling  crypto_module_init+0x0/0x14
[    0.788500] initcall crypto_module_init+0x0/0x14 returned 0 after 0 msecs
[    0.788500] calling  crypto_ctr_module_init+0x0/0x38
[    0.788500] initcall crypto_ctr_module_init+0x0/0x38 returned 0 after 0 msecs
[    0.788500] calling  crypto_gcm_module_init+0x0/0x52
[    0.788500] initcall crypto_gcm_module_init+0x0/0x52 returned 0 after 0 msecs
[    0.788500] calling  crypto_ccm_module_init+0x0/0x52
[    0.788500] initcall crypto_ccm_module_init+0x0/0x52 returned 0 after 0 msecs
[    0.789500] calling  des_generic_mod_init+0x0/0x38
[    0.789500] initcall des_generic_mod_init+0x0/0x38 returned 0 after 0 msecs
[    0.789500] calling  fcrypt_mod_init+0x0/0x14
[    0.789500] initcall fcrypt_mod_init+0x0/0x14 returned 0 after 0 msecs
[    0.789500] calling  twofish_mod_init+0x0/0x14
[    0.789500] initcall twofish_mod_init+0x0/0x14 returned 0 after 0 msecs
[    0.789500] calling  cast5_mod_init+0x0/0x14
[    0.789500] initcall cast5_mod_init+0x0/0x14 returned 0 after 0 msecs
[    0.789500] calling  deflate_mod_init+0x0/0x14
[    0.790500] initcall deflate_mod_init+0x0/0x14 returned 0 after 0 msecs
[    0.790500] calling  michael_mic_init+0x0/0x14
[    0.790500] initcall michael_mic_init+0x0/0x14 returned 0 after 0 msecs
[    0.790500] calling  crc32c_mod_init+0x0/0x38
[    0.790500] initcall crc32c_mod_init+0x0/0x38 returned 0 after 0 msecs
[    0.790500] calling  crypto_authenc_module_init+0x0/0x14
[    0.791500] initcall crypto_authenc_module_init+0x0/0x14 returned 0 after 0 msecs
[    0.791500] calling  bsg_init+0x0/0x106
[    0.792500] Block layer SCSI generic (bsg) driver version 0.4 loaded (major 254)
[    0.792500] initcall bsg_init+0x0/0x106 returned 0 after 0 msecs
[    0.792500] calling  noop_init+0x0/0x16
[    0.792500] io scheduler noop registered (default)
[    0.792500] initcall noop_init+0x0/0x16 returned 0 after 0 msecs
[    0.792500] calling  percpu_counter_startup+0x0/0x11
[    0.792500] initcall percpu_counter_startup+0x0/0x11 returned 0 after 0 msecs
[    0.792500] calling  pci_init+0x0/0x31
[    0.792500] pci 0000:00:02.0: Boot video device
[    0.793500] pci 0000:00:1d.0: uhci_check_and_reset_hc: legsup = 0x2000
[    0.793500] pci 0000:00:1d.0: Performing full reset
[    0.793500] pci 0000:00:1d.1: uhci_check_and_reset_hc: legsup = 0x2000
[    0.793500] pci 0000:00:1d.1: Performing full reset
[    0.793500] pci 0000:00:1d.2: uhci_check_and_reset_hc: legsup = 0x2000
[    0.793500] pci 0000:00:1d.2: Performing full reset
[    0.793500] pci 0000:00:1d.3: uhci_check_and_reset_hc: legsup = 0x2000
[    0.793500] pci 0000:00:1d.3: Performing full reset
[    0.793500] initcall pci_init+0x0/0x31 returned 0 after 0 msecs
[    0.794500] calling  pci_proc_init+0x0/0x60
[    0.794500] initcall pci_proc_init+0x0/0x60 returned 0 after 0 msecs
[    0.794500] calling  arcfb_init+0x0/0x65
[    0.794500] initcall arcfb_init+0x0/0x65 returned -6 after 0 msecs
[    0.794500] initcall arcfb_init+0x0/0x65 returned with error code -6 
[    0.794500] calling  rivafb_init+0x0/0x1ab
[    0.794500] rivafb_setup START
[    0.795500] initcall rivafb_init+0x0/0x1ab returned 0 after 0 msecs
[    0.795500] calling  kyrofb_init+0x0/0xd0
[    0.795500] initcall kyrofb_init+0x0/0xd0 returned 0 after 0 msecs
[    0.795500] calling  gxfb_init+0x0/0x73
[    0.796500] initcall gxfb_init+0x0/0x73 returned 0 after 0 msecs
[    0.796500] calling  tridentfb_init+0x0/0x1f8
[    0.796500] tridentfb: Trident framebuffer 0.7.8-NEWAPI initializing
[    0.796500] initcall tridentfb_init+0x0/0x1f8 returned 0 after 0 msecs
[    0.796500] calling  hgafb_init+0x0/0x4d
[    0.797500] hgafb: HGA card not detected.
[    0.797500] hgafb: probe of hgafb.0 failed with error -22
[    0.797500] initcall hgafb_init+0x0/0x4d returned 0 after 0 msecs
[    0.797500] calling  sstfb_init+0x0/0x193
[    0.797500] initcall sstfb_init+0x0/0x193 returned 0 after 0 msecs
[    0.797500] calling  s1d13xxxfb_init+0x0/0x2d
[    0.797500] initcall s1d13xxxfb_init+0x0/0x2d returned 0 after 0 msecs
[    0.798500] calling  efifb_init+0x0/0x46
[    0.798500] initcall efifb_init+0x0/0x46 returned -19 after 0 msecs
[    0.798500] calling  acpi_reserve_resources+0x0/0xcd
[    0.798500] initcall acpi_reserve_resources+0x0/0xcd returned 0 after 0 msecs
[    0.798500] calling  acpi_battery_init+0x0/0x42
[    0.842000] ACPI: Battery Slot [BAT0] (battery present)
[    0.842000] initcall acpi_battery_init+0x0/0x42 returned 0 after 41 msecs
[    0.842000] calling  acpi_button_init+0x0/0x56
[    0.843000] input: Power Button (FF) as /class/input/input0
[    0.843000] ACPI: Power Button (FF) [PWRF]
[    0.843000] input: Lid Switch as /class/input/input1
[    0.844000] ACPI: Lid Switch [LID]
[    0.844000] input: Sleep Button (CM) as /class/input/input2
[    0.844000] ACPI: Sleep Button (CM) [SLPB]
[    0.845000] initcall acpi_button_init+0x0/0x56 returned 0 after 2 msecs
[    0.845000] calling  irqrouter_init_sysfs+0x0/0x38
[    0.845000] initcall irqrouter_init_sysfs+0x0/0x38 returned 0 after 0 msecs
[    0.845000] calling  acpi_pci_slot_init+0x0/0x16
[    0.846000] initcall acpi_pci_slot_init+0x0/0x16 returned 0 after 0 msecs
[    0.846000] calling  pnpbios_thread_init+0x0/0x53
[    0.846000] initcall pnpbios_thread_init+0x0/0x53 returned 0 after 0 msecs
[    0.846000] calling  rand_initialize+0x0/0x2a
[    0.846000] initcall rand_initialize+0x0/0x2a returned 0 after 0 msecs
[    0.846000] calling  tty_init+0x0/0x194
[    0.853000] initcall tty_init+0x0/0x194 returned 0 after 6 msecs
[    0.853000] calling  pty_init+0x0/0x1f5
[    0.853000] initcall pty_init+0x0/0x1f5 returned 0 after 0 msecs
[    0.853000] calling  lp_init_module+0x0/0x209
[    0.854000] lp: driver loaded but no devices found
[    0.854000] initcall lp_init_module+0x0/0x209 returned 0 after 0 msecs
[    0.854000] calling  r3964_init+0x0/0x3d
[    0.854000] r3964: Philips r3964 Driver $Revision: 1.10 $
[    0.854000] initcall r3964_init+0x0/0x3d returned 0 after 0 msecs
[    0.854000] calling  sonypi_init+0x0/0x1e
[    0.854000] sonypi: Sony Programmable I/O Controller Driver v1.26.
[    0.854000] initcall sonypi_init+0x0/0x1e returned -19 after 0 msecs
[    0.854000] calling  i8k_init+0x0/0x13c
[    0.855000] initcall i8k_init+0x0/0x13c returned -19 after 0 msecs
[    0.855000] calling  ppdev_init+0x0/0x9a
[    0.855000] ppdev: user-space parallel port driver
[    0.855000] initcall ppdev_init+0x0/0x9a returned 0 after 0 msecs
[    0.855000] calling  nsc_gpio_init+0x0/0x16
[    0.855000] nsc_gpio initializing
[    0.855000] initcall nsc_gpio_init+0x0/0x16 returned 0 after 0 msecs
[    0.855000] calling  cs5535_gpio_init+0x0/0x16c
[    0.855000] cs5535_gpio: DIVIL not found
[    0.856000] initcall cs5535_gpio_init+0x0/0x16c returned -19 after 0 msecs
[    0.856000] calling  agp_init+0x0/0x26
[    0.856000] Linux agpgart interface v0.103
[    0.856000] initcall agp_init+0x0/0x26 returned 0 after 0 msecs
[    0.856000] calling  agp_ali_init+0x0/0x29
[    0.856000] initcall agp_ali_init+0x0/0x29 returned 0 after 0 msecs
[    0.856000] calling  agp_ati_init+0x0/0x29
[    0.857000] initcall agp_ati_init+0x0/0x29 returned 0 after 0 msecs
[    0.857000] calling  agp_amdk7_init+0x0/0x29
[    0.857000] initcall agp_amdk7_init+0x0/0x29 returned 0 after 0 msecs
[    0.857000] calling  agp_efficeon_init+0x0/0x3e
[    0.857000] initcall agp_efficeon_init+0x0/0x3e returned 0 after 0 msecs
[    0.858000] calling  agp_intel_init+0x0/0x29
[    0.858000] agpgart: Detected an Intel 945GM Chipset.
[    0.859000] agpgart: Detected 7932K stolen memory.
[    0.876000] agpgart: AGP aperture is 256M @ 0xd0000000
[    0.876000] initcall agp_intel_init+0x0/0x29 returned 0 after 17 msecs
[    0.876000] calling  agp_serverworks_init+0x0/0x29
[    0.877000] initcall agp_serverworks_init+0x0/0x29 returned 0 after 0 msecs
[    0.877000] calling  ipmi_init_msghandler_mod+0x0/0x11
[    0.877000] ipmi message handler version 39.2
[    0.877000] initcall ipmi_init_msghandler_mod+0x0/0x11 returned 0 after 0 msecs
[    0.877000] calling  init_ipmi_si+0x0/0x53b
[    0.878000] IPMI System Interface driver.
[    0.878000] ipmi_si: Unable to find any System Interface(s)
[    0.878000] initcall init_ipmi_si+0x0/0x53b returned -19 after 0 msecs
[    0.878000] calling  ipmi_wdog_init+0x0/0x103
[    0.878000] IPMI Watchdog: driver initialized
[    0.879000] initcall ipmi_wdog_init+0x0/0x103 returned 0 after 0 msecs
[    0.879000] calling  ipmi_poweroff_init+0x0/0x7b
[    0.879000] Copyright (C) 2004 MontaVista Software - IPMI Powerdown via sys_reboot.
[    0.879000] initcall ipmi_poweroff_init+0x0/0x7b returned 0 after 0 msecs
[    0.879000] calling  intelfb_init+0x0/0x4e6
[    0.879000] intelfb: Framebuffer driver for Intel(R) 830M/845G/852GM/855GM/865G/915G/915GM/945G/945GM/965G/965GM chipsets
[    0.879000] intelfb: Version 0.9.5
[    0.880000] intelfb 0000:00:02.0: power state changed by ACPI to D0
[    0.880000] Pin 1-16 already programmed
[    0.880000] intelfb 0000:00:02.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
[    0.880000] intelfb: 00:02.0: Intel(R) 945GM, aperture size 256MB, stolen memory 7932kB
[    0.884000] intelfb: Non-CRT device is enabled ( LVDS port ).  Disabling mode switching.
[    0.884000] intelfb: Video mode must be programmed at boot time.
[    0.886000] initcall intelfb_init+0x0/0x4e6 returned 0 after 6 msecs
[    0.886000] calling  serial8250_init+0x0/0x111
[    0.886000] Serial: 8250/16550 driver $Revision: 1.90 $ 4 ports, IRQ sharing disabled
[    0.887000] serial8250: ttyS1 at I/O 0x2f8 (irq = 3) is a NS16550A
[    0.887000] initcall serial8250_init+0x0/0x111 returned 0 after 0 msecs
[    0.887000] calling  parport_default_proc_register+0x0/0x1b
[    0.887000] initcall parport_default_proc_register+0x0/0x1b returned 0 after 0 msecs
[    0.888000] calling  isa_bus_init+0x0/0x38
[    0.888000] initcall isa_bus_init+0x0/0x38 returned 0 after 0 msecs
[    0.888000] calling  topology_sysfs_init+0x0/0x3b
[    0.888000] initcall topology_sysfs_init+0x0/0x3b returned 0 after 0 msecs
[    0.888000] calling  floppy_init+0x0/0xdb1
[    3.899000] floppy0: no floppy controllers found
[    3.899000] initcall floppy_init+0x0/0xdb1 returned -19 after 2871 msecs
[    3.899000] calling  brd_init+0x0/0x136
[    3.903000] brd: module loaded
[    3.903000] initcall brd_init+0x0/0x136 returned 0 after 3 msecs
[    3.903000] calling  cpqarray_init+0x0/0x230
[    3.903000] Compaq SMART2 Driver (v 2.6.0)
[    3.904000] initcall cpqarray_init+0x0/0x230 returned 0 after 0 msecs
[    3.904000] calling  cciss_init+0x0/0x25
[    3.904000] HP CISS Driver (v 3.6.20)
[    3.904000] initcall cciss_init+0x0/0x25 returned 0 after 0 msecs
[    3.904000] calling  DAC960_init_module+0x0/0x46
[    3.905000] initcall DAC960_init_module+0x0/0x46 returned 0 after 0 msecs
[    3.905000] calling  mm_init+0x0/0x14b
[    3.905000] MM: desc_per_page = 128
[    3.905000] initcall mm_init+0x0/0x14b returned 0 after 0 msecs
[    3.905000] calling  nbd_init+0x0/0x28f
[    3.906000] nbd: registered device at major 43
[    3.910000] initcall nbd_init+0x0/0x28f returned 0 after 4 msecs
[    3.910000] calling  carm_init+0x0/0x1b
[    3.910000] initcall carm_init+0x0/0x1b returned 0 after 0 msecs
[    3.910000] calling  lkdtm_module_init+0x0/0x1c4
[    3.910000] lkdtm : Invalid command
[    3.911000] initcall lkdtm_module_init+0x0/0x1c4 returned -22 after 0 msecs
[    3.911000] initcall lkdtm_module_init+0x0/0x1c4 returned with error code -22 
[    3.911000] calling  init_kgdbts+0x0/0x1a
[    3.911000] initcall init_kgdbts+0x0/0x1a returned 0 after 0 msecs
[    3.911000] calling  e1000_init_module+0x0/0x58
[    3.912000] e1000e: Intel(R) PRO/1000 Network Driver - 0.3.3.3-k2
[    3.912000] e1000e: Copyright (c) 1999-2008 Intel Corporation.
[    3.912000] e1000e 0000:02:00.0: Disabling L1 ASPM
[    3.913000] vendor=8086 device=27d0
[    3.913000] Pin 1-16 already programmed
[    3.913000] e1000e 0000:02:00.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
[    3.913000] PCI: Setting latency timer of device 0000:02:00.0 to 64
[    3.996000] eth0: (PCI Express:2.5GB/s:Width x1) 00:16:41:17:49:d2
[    3.997000] eth0: Intel(R) PRO/1000 Network Connection
[    3.997000] eth0: MAC: 2, PHY: 2, PBA No: 005301-003
[    3.997000] initcall e1000_init_module+0x0/0x58 returned 0 after 81 msecs
[    3.997000] calling  ixgbe_init_module+0x0/0x48
[    3.997000] ixgbe: Intel(R) 10 Gigabit PCI Express Network Driver - version 1.3.18-k2
[    3.997000] ixgbe: Copyright (c) 1999-2007 Intel Corporation.
[    3.998000] initcall ixgbe_init_module+0x0/0x48 returned 0 after 0 msecs
[    3.998000] calling  ixgb_init_module+0x0/0x3e
[    3.998000] Intel(R) PRO/10GbE Network Driver - version 1.0.126-k4
[    3.998000] Copyright (c) 1999-2006 Intel Corporation.
[    3.998000] initcall ixgb_init_module+0x0/0x3e returned 0 after 0 msecs
[    3.998000] calling  atl1_init_module+0x0/0x1b
[    3.999000] initcall atl1_init_module+0x0/0x1b returned 0 after 0 msecs
[    3.999000] calling  plip_init+0x0/0x57
[    3.999000] initcall plip_init+0x0/0x57 returned 0 after 0 msecs
[    3.999000] calling  happy_meal_probe+0x0/0x1b
[    3.999000] initcall happy_meal_probe+0x0/0x1b returned 0 after 0 msecs
[    3.999000] calling  vortex_init+0x0/0xa1
[    4.000000] initcall vortex_init+0x0/0xa1 returned 0 after 0 msecs
[    4.000000] calling  ne2k_pci_init+0x0/0x1b
[    4.000000] initcall ne2k_pci_init+0x0/0x1b returned 0 after 0 msecs
[    4.000000] calling  e100_init_module+0x0/0x52
[    4.000000] e100: Intel(R) PRO/100 Network Driver, 3.5.23-k4-NAPI
[    4.000000] e100: Copyright(c) 1999-2006 Intel Corporation
[    4.001000] initcall e100_init_module+0x0/0x52 returned 0 after 0 msecs
[    4.001000] calling  epic_init+0x0/0x1b
[    4.001000] initcall epic_init+0x0/0x1b returned 0 after 0 msecs
[    4.001000] calling  acenic_init+0x0/0x1b
[    4.001000] initcall acenic_init+0x0/0x1b returned 0 after 0 msecs
[    4.002000] calling  ns83820_init+0x0/0x25
[    4.002000] ns83820.c: National Semiconductor DP83820 10/100/1000 driver.
[    4.002000] initcall ns83820_init+0x0/0x25 returned 0 after 0 msecs
[    4.002000] calling  tg3_init+0x0/0x1b
[    4.002000] initcall tg3_init+0x0/0x1b returned 0 after 0 msecs
[    4.002000] calling  bnx2x_init+0x0/0x1b
[    4.003000] initcall bnx2x_init+0x0/0x1b returned 0 after 0 msecs
[    4.003000] calling  skfd_init+0x0/0x1b
[    4.003000] initcall skfd_init+0x0/0x1b returned 0 after 0 msecs
[    4.003000] calling  velocity_init_module+0x0/0x34
[    4.003000] initcall velocity_init_module+0x0/0x34 returned 0 after 0 msecs
[    4.004000] calling  cicada_init+0x0/0x38
[    4.004000] initcall cicada_init+0x0/0x38 returned 0 after 0 msecs
[    4.004000] calling  hamachi_init+0x0/0x1b
[    4.004000] initcall hamachi_init+0x0/0x1b returned 0 after 0 msecs
[    4.004000] calling  net_olddevs_init+0x0/0x86
[    4.005000] initcall net_olddevs_init+0x0/0x86 returned 0 after 0 msecs
[    4.005000] calling  sb1000_init+0x0/0x14
[    4.005000] initcall sb1000_init+0x0/0x14 returned 0 after 0 msecs
[    4.005000] calling  hp100_module_init+0x0/0x1b
[    4.005000] initcall hp100_module_init+0x0/0x1b returned 0 after 0 msecs
[    4.005000] calling  init_nic+0x0/0x1b
[    4.006000] initcall init_nic+0x0/0x1b returned 0 after 0 msecs
[    4.006000] calling  dummy_init_module+0x0/0x9a
[    4.006000] initcall dummy_init_module+0x0/0x9a returned 0 after 0 msecs
[    4.006000] calling  macvlan_init_module+0x0/0x4a
[    4.006000] initcall macvlan_init_module+0x0/0x4a returned 0 after 0 msecs
[    4.007000] calling  dfx_init+0x0/0x1b
[    4.007000] initcall dfx_init+0x0/0x1b returned 0 after 0 msecs
[    4.007000] calling  el3_init_module+0x0/0x109
[    4.050000] initcall el3_init_module+0x0/0x109 returned 0 after 41 msecs
[    4.050000] calling  rtl8139_init_module+0x0/0x1b
[    4.050000] initcall rtl8139_init_module+0x0/0x1b returned 0 after 0 msecs
[    4.050000] calling  myri10ge_init_module+0x0/0x30
[    4.050000] myri10ge: Version 1.3.99-1.347
[    4.051000] initcall myri10ge_init_module+0x0/0x30 returned 0 after 0 msecs
[    4.051000] calling  arcnet_init+0x0/0x55
[    4.051000] arcnet loaded.
[    4.051000] initcall arcnet_init+0x0/0x55 returned 0 after 0 msecs
[    4.051000] calling  arcnet_rfc1051_init+0x0/0x42
[    4.051000] arcnet: RFC1051 "simple standard" (`s') encapsulation support loaded.
[    4.051000] initcall arcnet_rfc1051_init+0x0/0x42 returned 0 after 0 msecs
[    4.051000] calling  arcnet_raw_init+0x0/0x57
[    4.051000] arcnet: raw mode (`r') encapsulation support loaded.
[    4.052000] initcall arcnet_raw_init+0x0/0x57 returned 0 after 0 msecs
[    4.052000] calling  kaweth_init+0x0/0x2a
[    4.052000] drivers/net/usb/kaweth.c: Driver loading
[    4.052000] usbcore: registered new interface driver kaweth
[    4.052000] initcall kaweth_init+0x0/0x2a returned 0 after 0 msecs
[    4.052000] calling  cdc_init+0x0/0x1b
[    4.052000] usbcore: registered new interface driver cdc_ether
[    4.052000] initcall cdc_init+0x0/0x1b returned 0 after 0 msecs
[    4.053000] calling  net1080_init+0x0/0x1b
[    4.053000] usbcore: registered new interface driver net1080
[    4.053000] initcall net1080_init+0x0/0x1b returned 0 after 0 msecs
[    4.053000] calling  plusb_init+0x0/0x1b
[    4.053000] usbcore: registered new interface driver plusb
[    4.053000] initcall plusb_init+0x0/0x1b returned 0 after 0 msecs
[    4.053000] calling  rndis_init+0x0/0x1b
[    4.054000] usbcore: registered new interface driver rndis_host
[    4.054000] initcall rndis_init+0x0/0x1b returned 0 after 0 msecs
[    4.054000] calling  mcs7830_init+0x0/0x1b
[    4.054000] usbcore: registered new interface driver MOSCHIP usb-ethernet driver
[    4.054000] initcall mcs7830_init+0x0/0x1b returned 0 after 0 msecs
[    4.054000] calling  usbnet_init+0x0/0x2b
[    4.054000] initcall usbnet_init+0x0/0x2b returned 0 after 0 msecs
[    4.054000] calling  ipw2100_init+0x0/0x5f
[    4.055000] ipw2100: Intel(R) PRO/Wireless 2100 Network Driver, git-1.2.2
[    4.055000] ipw2100: Copyright(c) 2003-2006 Intel Corporation
[    4.055000] initcall ipw2100_init+0x0/0x5f returned 0 after 0 msecs
[    4.055000] calling  ipw_init+0x0/0x73
[    4.055000] ipw2200: Intel(R) PRO/Wireless 2200/2915 Network Driver, 1.2.2kdmprq
[    4.055000] ipw2200: Copyright(c) 2003-2006 Intel Corporation
[    4.056000] initcall ipw_init+0x0/0x73 returned 0 after 0 msecs
[    4.056000] calling  strip_init_driver+0x0/0x5c
[    4.056000] STRIP: Version 1.3A-STUART.CHESHIRE (unlimited channels)
[    4.056000] initcall strip_init_driver+0x0/0x5c returned 0 after 0 msecs
[    4.056000] calling  rndis_wlan_init+0x0/0x1b
[    4.056000] usbcore: registered new interface driver rndis_wlan
[    4.056000] initcall rndis_wlan_init+0x0/0x1b returned 0 after 0 msecs
[    4.056000] calling  zd1201_init+0x0/0x1b
[    4.057000] usbcore: registered new interface driver zd1201
[    4.057000] initcall zd1201_init+0x0/0x1b returned 0 after 0 msecs
[    4.057000] calling  w840_init+0x0/0x25
[    4.057000] winbond-840.c:v1.01-e (2.4 port) Sep-11-2006  Donald Becker <becker@scyld.com>
[    4.057000]   http://www.scyld.com/network/drivers.html
[    4.057000] initcall w840_init+0x0/0x25 returned 0 after 0 msecs
[    4.057000] calling  uli526x_init_module+0x0/0x92
[    4.058000] uli526x: ULi M5261/M5263 net driver, version 0.9.3 (2005-7-29)
[    4.058000] initcall uli526x_init_module+0x0/0x92 returned 0 after 0 msecs
[    4.058000] calling  stir_init+0x0/0x1b
[    4.058000] usbcore: registered new interface driver stir4200
[    4.058000] initcall stir_init+0x0/0x1b returned 0 after 0 msecs
[    4.058000] calling  nsc_ircc_init+0x0/0x1d9
[    4.059000] nsc-ircc, chip->init
[    4.059000] nsc-ircc, Found chip at base=0x164e
[    4.059000] nsc-ircc, driver loaded (Dag Brattli)
[    4.059000] nsc_ircc_open(), can't get iobase of 0x2f8
[    4.059000] nsc-ircc, Found chip at base=0x164e
[    4.059000] nsc-ircc, driver loaded (Dag Brattli)
[    4.059000] nsc_ircc_open(), can't get iobase of 0x2f8
[    4.060000] nsc-ircc 00:0a: disabled
[    4.060000] initcall nsc_ircc_init+0x0/0x1d9 returned -19 after 0 msecs
[    4.060000] calling  w83977af_init+0x0/0x43a
[    4.060000] initcall w83977af_init+0x0/0x43a returned -19 after 0 msecs
[    4.061000] calling  donauboe_init+0x0/0x1b
[    4.061000] initcall donauboe_init+0x0/0x1b returned 0 after 0 msecs
[    4.061000] calling  irtty_sir_init+0x0/0x3b
[    4.061000] initcall irtty_sir_init+0x0/0x3b returned 0 after 0 msecs
[    4.061000] calling  sir_wq_init+0x0/0x34
[    4.061000] initcall sir_wq_init+0x0/0x34 returned 0 after 0 msecs
[    4.061000] calling  ksdazzle_init+0x0/0x1b
[    4.062000] usbcore: registered new interface driver ksdazzle-sir
[    4.062000] initcall ksdazzle_init+0x0/0x1b returned 0 after 0 msecs
[    4.062000] calling  ks959_init+0x0/0x1b
[    4.062000] usbcore: registered new interface driver ks959-sir
[    4.062000] initcall ks959_init+0x0/0x1b returned 0 after 0 msecs
[    4.062000] calling  init_netconsole+0x0/0x16c
[    4.062000] netconsole: local port 4444
[    4.062000] netconsole: local IP 10.0.1.15
[    4.063000] netconsole: interface eth0
[    4.063000] netconsole: remote port 4444
[    4.063000] netconsole: remote IP 10.0.1.16
[    4.063000] netconsole: remote ethernet address 00:19:d1:01:f5:55
[    4.063000] netconsole: device eth0 not up yet, forcing it
[    8.080000] netconsole: timeout waiting for carrier
[    8.081000] eth0: Link is Up 1000 Mbps Full Duplex, Flow Control: RX/TX
[    8.082000] console [netcon0] enabled
[    8.083000] netconsole: network logging started
[    8.083000] initcall init_netconsole+0x0/0x16c returned 0 after 3834 msecs
[    8.084000] calling  niu_init+0x0/0x3b
[    8.084000] initcall niu_init+0x0/0x3b returned 0 after 0 msecs
[    8.084000] calling  videodev_init+0x0/0x73
[    8.084000] Linux video capture interface: v2.00
[    8.084000] initcall videodev_init+0x0/0x73 returned 0 after 0 msecs
[    8.085000] calling  amb_module_init+0x0/0x106
[    8.086000] Madge ATM Ambassador driver version 1.2.4
[    8.086000] initcall amb_module_init+0x0/0x106 returned 0 after 0 msecs
[    8.086000] calling  hrz_module_init+0x0/0xbf
[    8.086000] Madge ATM Horizon [Ultra] driver version 1.2.1
[    8.086000] hrz: debug bitmap is 0
[    8.086000] initcall hrz_module_init+0x0/0xbf returned 0 after 0 msecs
[    8.087000] calling  fore200e_module_init+0x0/0xbc
[    8.087000] fore200e: FORE Systems 200E-series ATM driver - version 0.3e
[    8.087000] initcall fore200e_module_init+0x0/0xbc returned 0 after 0 msecs
[    8.087000] calling  lanai_module_init+0x0/0x32
[    8.087000] initcall lanai_module_init+0x0/0x32 returned 0 after 0 msecs
[    8.088000] calling  scsi_tgt_init+0x0/0x7a
[    8.088000] initcall scsi_tgt_init+0x0/0x7a returned 0 after 0 msecs
[    8.088000] calling  raid_init+0x0/0x14
[    8.088000] initcall raid_init+0x0/0x14 returned 0 after 0 msecs
[    8.089000] calling  spi_transport_init+0x0/0x2c
[    8.089000] initcall spi_transport_init+0x0/0x2c returned 0 after 0 msecs
[    8.089000] calling  fc_transport_init+0x0/0x48
[    8.089000] initcall fc_transport_init+0x0/0x48 returned 0 after 0 msecs
[    8.090000] calling  iscsi_transport_init+0x0/0x11d
[    8.090000] Loading iSCSI transport class v2.0-870.
[    8.090000] initcall iscsi_transport_init+0x0/0x11d returned 0 after 0 msecs
[    8.090000] calling  iscsi_tcp_init+0x0/0x3f
[    8.091000] iscsi: registered transport (tcp)
[    8.091000] initcall iscsi_tcp_init+0x0/0x3f returned 0 after 0 msecs
[    8.091000] calling  aha152x_init+0x0/0x42a
[    8.091000] initcall aha152x_init+0x0/0x42a returned -19 after 0 msecs
[    8.091000] calling  ahc_linux_init+0x0/0x61
[    8.092000] initcall ahc_linux_init+0x0/0x61 returned 0 after 0 msecs
[    8.092000] calling  aac_init+0x0/0x63
[    8.092000] Adaptec aacraid driver 1.1-5[2456]-ms
[    8.092000] initcall aac_init+0x0/0x63 returned 0 after 0 msecs
[    8.092000] calling  init_this_scsi_driver+0x0/0xd0
[    8.093000] initcall init_this_scsi_driver+0x0/0xd0 returned -19 after 0 msecs
[    8.093000] calling  init_this_scsi_driver+0x0/0xd0
[    8.094000] initcall init_this_scsi_driver+0x0/0xd0 returned -19 after 0 msecs
[    8.094000] calling  init_this_scsi_driver+0x0/0xd0
[    8.094000] initcall init_this_scsi_driver+0x0/0xd0 returned -19 after 0 msecs
[    8.094000] calling  init_this_scsi_driver+0x0/0xd0
[    8.094000] sym53c416.c: Version 1.0.0-ac
[    8.094000] initcall init_this_scsi_driver+0x0/0xd0 returned -19 after 0 msecs
[    8.095000] calling  qla1280_init+0x0/0x1b
[    8.095000] initcall qla1280_init+0x0/0x1b returned 0 after 0 msecs
[    8.095000] calling  qla2x00_module_init+0x0/0x102
[    8.095000] QLogic Fibre Channel HBA Driver: 8.02.01-k4
[    8.095000] initcall qla2x00_module_init+0x0/0x102 returned 0 after 0 msecs
[    8.096000] calling  lpfc_init+0x0/0xa9
[    8.096000] Emulex LightPulse Fibre Channel SCSI driver 8.2.7
[    8.096000] Copyright(c) 2004-2008 Emulex.  All rights reserved.
[    8.096000] initcall lpfc_init+0x0/0xa9 returned 0 after 0 msecs
[    8.096000] calling  init_this_scsi_driver+0x0/0xd0
[    8.096000] initcall init_this_scsi_driver+0x0/0xd0 returned -19 after 0 msecs
[    8.097000] calling  init_this_scsi_driver+0x0/0xd0
[    8.097000] initcall init_this_scsi_driver+0x0/0xd0 returned -19 after 0 msecs
[    8.097000] calling  sym2_init+0x0/0xe4
[    8.097000] initcall sym2_init+0x0/0xe4 returned 0 after 0 msecs
[    8.097000] calling  megaraid_init+0x0/0xa2
[    8.098000] initcall megaraid_init+0x0/0xa2 returned 0 after 0 msecs
[    8.098000] calling  mraid_mm_init+0x0/0x76
[    8.098000] megaraid cmm: 2.20.2.7 (Release Date: Sun Jul 16 00:01:03 EST 2006)
[    8.098000] initcall mraid_mm_init+0x0/0x76 returned 0 after 0 msecs
[    8.098000] calling  megaraid_init+0x0/0x8b
[    8.098000] megaraid: 2.20.5.1 (Release Date: Thu Nov 16 15:32:35 EST 2006)
[    8.099000] initcall megaraid_init+0x0/0x8b returned 0 after 0 msecs
[    8.099000] calling  tw_init+0x0/0x2a
[    8.099000] 3ware Storage Controller device driver for Linux v1.26.02.002.
[    8.099000] initcall tw_init+0x0/0x2a returned 0 after 0 msecs
[    8.099000] calling  init_nsp32+0x0/0x31
[    8.099000] nsp32: loading...
[    8.100000] initcall init_nsp32+0x0/0x31 returned 0 after 0 msecs
[    8.100000] calling  hptiop_module_init+0x0/0x2f
[    8.100000] RocketRAID 3xxx/4xxx Controller driver v1.3 (071203)
[    8.100000] initcall hptiop_module_init+0x0/0x2f returned 0 after 0 msecs
[    8.100000] calling  init_sd+0x0/0xb6
[    8.101000] Driver 'sd' needs updating - please use bus_type methods
[    8.101000] initcall init_sd+0x0/0xb6 returned 0 after 0 msecs
[    8.101000] calling  init_sr+0x0/0x42
[    8.101000] Driver 'sr' needs updating - please use bus_type methods
[    8.101000] initcall init_sr+0x0/0x42 returned 0 after 0 msecs
[    8.101000] calling  init_sg+0x0/0xaf
[    8.102000] initcall init_sg+0x0/0xaf returned 0 after 0 msecs
[    8.102000] calling  init_ch_module+0x0/0x8c
[    8.102000] SCSI Media Changer driver v0.25 
[    8.102000] Driver 'ch' needs updating - please use bus_type methods
[    8.102000] initcall init_ch_module+0x0/0x8c returned 0 after 0 msecs
[    8.102000] calling  ahci_init+0x0/0x1b
[    8.103000] ahci 0000:00:1f.2: version 3.0
[    8.103000] Pin 1-16 already programmed
[    8.103000] ahci 0000:00:1f.2: PCI INT B -> GSI 16 (level, low) -> IRQ 16
[    8.103000] ahci 0000:00:1f.2: AHCI 0001.0100 32 slots 4 ports 1.5 Gbps 0x1 impl SATA mode
[    8.103000] ahci 0000:00:1f.2: flags: 64bit ncq pm led clo pio slum part 
[    8.103000] PCI: Setting latency timer of device 0000:00:1f.2 to 64
[    8.104000] scsi0 : ahci
[    8.104000] scsi1 : ahci
[    8.104000] scsi2 : ahci
[    8.105000] scsi3 : ahci
[    8.105000] ata1: SATA max UDMA/133 abar m1024@0xee444400 port 0xee444500 irq 222
[    8.105000] ata2: DUMMY
[    8.105000] ata3: DUMMY
[    8.105000] ata4: DUMMY
[    8.411500] ata1: SATA link up 1.5 Gbps (SStatus 113 SControl 300)
[    8.412000] ata1.00: ACPI cmd ef/02:00:00:00:00:a0 succeeded
[    8.413000] ata1.00: ACPI cmd f5/00:00:00:00:00:a0 filtered out
[    8.413000] ata1.00: ACPI cmd ef/10:03:00:00:00:a0 filtered out
[    8.414000] ata1.00: ATA-7: HTS541080G9SA00, MB4IC60H, max UDMA/100
[    8.414000] ata1.00: 156301488 sectors, multi 16: LBA48 
[    8.416000] ata1.00: ACPI cmd ef/02:00:00:00:00:a0 succeeded
[    8.416000] ata1.00: ACPI cmd f5/00:00:00:00:00:a0 filtered out
[    8.417000] ata1.00: ACPI cmd ef/10:03:00:00:00:a0 filtered out
[    8.418000] ata1.00: configured for UDMA/100
[    8.421000] ata1.00: configured for UDMA/100
[    8.421000] ata1: EH complete
[    8.422000] scsi 0:0:0:0: Direct-Access     ATA      HTS541080G9SA00  MB4I PQ: 0 ANSI: 5
[    8.422000] sd 0:0:0:0: [sda] 156301488 512-byte hardware sectors (80026 MB)
[    8.422000] sd 0:0:0:0: [sda] Write Protect is off
[    8.422000] sd 0:0:0:0: [sda] Mode Sense: 00 3a 00 00
[    8.423000] sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[    8.423000] sd 0:0:0:0: [sda] 156301488 512-byte hardware sectors (80026 MB)
[    8.423000] sd 0:0:0:0: [sda] Write Protect is off
[    8.423000] sd 0:0:0:0: [sda] Mode Sense: 00 3a 00 00
[    8.423000] sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[    8.424000]  sda: sda1 sda2
[    8.843000] sd 0:0:0:0: [sda] Attached SCSI disk
[    8.843000] sd 0:0:0:0: Attached scsi generic sg0 type 0
[    8.844000] initcall ahci_init+0x0/0x1b returned 0 after 707 msecs
[    8.844000] calling  piix_init+0x0/0x29
[    8.844000] ata_piix 0000:00:1f.1: version 2.12
[    8.844000] Pin 1-16 already programmed
[    8.844000] ata_piix 0000:00:1f.1: PCI INT C -> GSI 16 (level, low) -> IRQ 16
[    8.845000] PCI: Setting latency timer of device 0000:00:1f.1 to 64
[    8.845000] scsi4 : ata_piix
[    8.845000] scsi5 : ata_piix
[    8.847000] ata5: PATA max UDMA/100 cmd 0x1f0 ctl 0x3f6 bmdma 0x1810 irq 14
[    8.847000] ata6: PATA max UDMA/100 cmd 0x170 ctl 0x376 bmdma 0x1818 irq 15
[    9.001000] ata5.00: ATAPI: HL-DT-STCD-RW/DVD DRIVE GCC-4246N, 0X05, max UDMA/33
[    9.007000] ata5.00: configured for UDMA/33
[    9.007000] ata6: port disabled. ignoring.
[    9.022000] scsi 4:0:0:0: CD-ROM            HL-DT-ST RW/DVD GCC-4246N 0X05 PQ: 0 ANSI: 5
[    9.036000] sr0: scsi3-mmc drive: 24x/24x writer cd/rw xa/form2 cdda tray
[    9.036000] Uniform CD-ROM driver Revision: 3.20
[    9.036000] sr 4:0:0:0: Attached scsi CD-ROM sr0
[    9.037000] sr 4:0:0:0: Attached scsi generic sg1 type 5
[    9.037000] initcall piix_init+0x0/0x29 returned 0 after 184 msecs
[    9.037000] calling  pdc_ata_init+0x0/0x1b
[    9.037000] initcall pdc_ata_init+0x0/0x1b returned 0 after 0 msecs
[    9.037000] calling  sil24_init+0x0/0x1b
[    9.038000] initcall sil24_init+0x0/0x1b returned 0 after 0 msecs
[    9.038000] calling  pdc_sata_init+0x0/0x1b
[    9.038000] initcall pdc_sata_init+0x0/0x1b returned 0 after 0 msecs
[    9.038000] calling  nv_init+0x0/0x1b
[    9.039000] initcall nv_init+0x0/0x1b returned 0 after 0 msecs
[    9.039000] calling  mv_init+0x0/0x3f
[    9.039000] initcall mv_init+0x0/0x3f returned 0 after 0 msecs
[    9.039000] calling  inic_init+0x0/0x1b
[    9.040000] initcall inic_init+0x0/0x1b returned 0 after 0 msecs
[    9.040000] calling  amd_init+0x0/0x1b
[    9.040000] initcall amd_init+0x0/0x1b returned 0 after 0 msecs
[    9.040000] calling  artop_init+0x0/0x1b
[    9.041000] initcall artop_init+0x0/0x1b returned 0 after 0 msecs
[    9.041000] calling  cs5520_init+0x0/0x1b
[    9.041000] initcall cs5520_init+0x0/0x1b returned 0 after 0 msecs
[    9.041000] calling  cs5535_init+0x0/0x1b
[    9.041000] initcall cs5535_init+0x0/0x1b returned 0 after 0 msecs
[    9.042000] calling  efar_init+0x0/0x1b
[    9.042000] initcall efar_init+0x0/0x1b returned 0 after 0 msecs
[    9.042000] calling  hpt37x_init+0x0/0x1b
[    9.043000] initcall hpt37x_init+0x0/0x1b returned 0 after 0 msecs
[    9.043000] calling  hpt3x2n_init+0x0/0x1b
[    9.044000] initcall hpt3x2n_init+0x0/0x1b returned 0 after 0 msecs
[    9.044000] calling  netcell_init+0x0/0x1b
[    9.044000] initcall netcell_init+0x0/0x1b returned 0 after 0 msecs
[    9.044000] calling  ninja32_init+0x0/0x1b
[    9.044000] initcall ninja32_init+0x0/0x1b returned 0 after 0 msecs
[    9.045000] calling  ns87415_init+0x0/0x1b
[    9.045000] initcall ns87415_init+0x0/0x1b returned 0 after 0 msecs
[    9.045000] calling  optidma_init+0x0/0x1b
[    9.045000] initcall optidma_init+0x0/0x1b returned 0 after 0 msecs
[    9.045000] calling  mpiix_init+0x0/0x1b
[    9.046000] initcall mpiix_init+0x0/0x1b returned 0 after 0 msecs
[    9.046000] calling  oldpiix_init+0x0/0x1b
[    9.046000] initcall oldpiix_init+0x0/0x1b returned 0 after 0 msecs
[    9.046000] calling  sc1200_init+0x0/0x1b
[    9.047000] initcall sc1200_init+0x0/0x1b returned 0 after 0 msecs
[    9.047000] calling  serverworks_init+0x0/0x1b
[    9.047000] initcall serverworks_init+0x0/0x1b returned 0 after 0 msecs
[    9.047000] calling  sil680_init+0x0/0x1b
[    9.047000] initcall sil680_init+0x0/0x1b returned 0 after 0 msecs
[    9.048000] calling  via_init+0x0/0x1b
[    9.048000] initcall via_init+0x0/0x1b returned 0 after 0 msecs
[    9.048000] calling  pata_platform_init+0x0/0x14
[    9.048000] initcall pata_platform_init+0x0/0x14 returned 0 after 0 msecs
[    9.048000] calling  cdrom_init+0x0/0x11
[    9.049000] initcall cdrom_init+0x0/0x11 returned 0 after 0 msecs
[    9.049000] calling  mon_init+0x0/0xf3
[    9.049000] initcall mon_init+0x0/0xf3 returned 0 after 0 msecs
[    9.049000] calling  ehci_hcd_init+0x0/0x75
[    9.049000] ehci_hcd: block sizes: qh 128 qtd 96 itd 160 sitd 96
[    9.050000] ehci_hcd 0000:00:1d.7: power state changed by ACPI to D0
[    9.050000] ehci_hcd 0000:00:1d.7: PCI INT D -> GSI 19 (level, low) -> IRQ 19
[    9.050000] PCI: Setting latency timer of device 0000:00:1d.7 to 64
[    9.050000] ehci_hcd 0000:00:1d.7: EHCI Host Controller
[    9.051000] drivers/usb/core/inode.c: creating file 'devices'
[    9.051000] drivers/usb/core/inode.c: creating file '001'
[    9.051000] ehci_hcd 0000:00:1d.7: new USB bus registered, assigned bus number 1
[    9.051000] ehci_hcd 0000:00:1d.7: reset hcs_params 0x104208 dbg=1 cc=4 pcc=2 ordered !ppc ports=8
[    9.051000] ehci_hcd 0000:00:1d.7: reset hcc_params 6871 thresh 7 uframes 1024 64 bit addr
[    9.052000] ehci_hcd 0000:00:1d.7: reset command 080022 (park)=0 ithresh=8 Async period=1024 Reset HALT
[    9.056000] ehci_hcd 0000:00:1d.7: debug port 1
[    9.056000] ehci_hcd 0000:00:1d.7: cache line size of 32 is not supported
[    9.057000] ehci_hcd 0000:00:1d.7: supports USB remote wakeup
[    9.057000] ehci_hcd 0000:00:1d.7: irq 19, io mem 0xee444000
[    9.057000] ehci_hcd 0000:00:1d.7: reset command 080002 (park)=0 ithresh=8 period=1024 Reset HALT
[    9.061000] ehci_hcd 0000:00:1d.7: init command 010001 (park)=0 ithresh=1 period=1024 RUN
[    9.068000] ehci_hcd 0000:00:1d.7: USB 2.0 started, EHCI 1.00, driver 10 Dec 2004
[    9.068000] usb usb1: default language 0x0409
[    9.068000] usb usb1: uevent
[    9.068000] usb usb1: usb_probe_device
[    9.068000] usb usb1: configuration #1 chosen from 1 choice
[    9.068000] usb usb1: adding 1-0:1.0 (config #1, interface 0)
[    9.069000] usb 1-0:1.0: uevent
[    9.069000] hub 1-0:1.0: usb_probe_interface
[    9.069000] hub 1-0:1.0: usb_probe_interface - got id
[    9.069000] hub 1-0:1.0: USB hub found
[    9.069000] hub 1-0:1.0: 8 ports detected
[    9.069000] hub 1-0:1.0: standalone hub
[    9.069000] hub 1-0:1.0: no power switching (usb 1.0)
[    9.069000] hub 1-0:1.0: individual port over-current protection
[    9.070000] hub 1-0:1.0: power on to power good time: 20ms
[    9.070000] hub 1-0:1.0: local power source is good
[    9.070000] hub 1-0:1.0: trying to enable port power on non-switchable hub
[    9.171500] hub 1-0:1.0: state 7 ports 8 chg 0000 evt 0000
[    9.171000] drivers/usb/core/inode.c: creating file '001'
[    9.171500] ehci_hcd 0000:00:1d.7: GetStatus port 8 status 001803 POWER sig=j CSC CONNECT
[    9.171000] usb usb1: New USB device found, idVendor=1d6b, idProduct=0002
[    9.171000] usb usb1: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    9.171000] usb usb1: Product: EHCI Host Controller
[    9.171000] usb usb1: Manufacturer: Linux 2.6.26-tip-03923-g2c96bcb-dirty ehci_hcd
[    9.171000] usb usb1: SerialNumber: 0000:00:1d.7
[    9.171000] initcall ehci_hcd_init+0x0/0x75 returned 0 after 116 msecs
[    9.171000] calling  ohci_hcd_mod_init+0x0/0x85
[    9.171000] ohci_hcd: 2006 August 04 USB 1.1 'Open' Host Controller (OHCI) Driver
[    9.171000] ohci_hcd: block sizes: ed 64 td 64
[    9.171000] initcall ohci_hcd_mod_init+0x0/0x85 returned 0 after 0 msecs
[    9.171000] calling  uhci_hcd_init+0x0/0xc6
[    9.171000] USB Universal Host Controller Interface driver v3.0
[    9.172500] hub 1-0:1.0: port 8, status 0501, change 0001, 480 Mb/s
[    9.173000] uhci_hcd 0000:00:1d.0: power state changed by ACPI to D0
[    9.173000] Pin 1-16 already programmed
[    9.173000] uhci_hcd 0000:00:1d.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
[    9.173000] PCI: Setting latency timer of device 0000:00:1d.0 to 64
[    9.174000] uhci_hcd 0000:00:1d.0: UHCI Host Controller
[    9.174000] drivers/usb/core/inode.c: creating file '002'
[    9.174000] uhci_hcd 0000:00:1d.0: new USB bus registered, assigned bus number 2
[    9.174000] uhci_hcd 0000:00:1d.0: detected 2 ports
[    9.174000] uhci_hcd 0000:00:1d.0: uhci_check_and_reset_hc: cmd = 0x0000
[    9.174000] uhci_hcd 0000:00:1d.0: Performing full reset
[    9.174000] uhci_hcd 0000:00:1d.0: supports USB remote wakeup
[    9.175000] uhci_hcd 0000:00:1d.0: irq 16, io base 0x00001820
[    9.175000] usb usb2: default language 0x0409
[    9.175000] usb usb2: uevent
[    9.175000] usb usb2: usb_probe_device
[    9.175000] usb usb2: configuration #1 chosen from 1 choice
[    9.175000] usb usb2: adding 2-0:1.0 (config #1, interface 0)
[    9.176000] usb 2-0:1.0: uevent
[    9.176000] hub 2-0:1.0: usb_probe_interface
[    9.176000] hub 2-0:1.0: usb_probe_interface - got id
[    9.176000] hub 2-0:1.0: USB hub found
[    9.176000] hub 2-0:1.0: 2 ports detected
[    9.176000] hub 2-0:1.0: standalone hub
[    9.176000] hub 2-0:1.0: no power switching (usb 1.0)
[    9.176000] hub 2-0:1.0: individual port over-current protection
[    9.177000] hub 2-0:1.0: power on to power good time: 2ms
[    9.177000] hub 2-0:1.0: local power source is good
[    9.177000] hub 2-0:1.0: trying to enable port power on non-switchable hub
[    9.277500] hub 1-0:1.0: debounce: port 8: total 100ms stable 100ms status 0x501
[    9.278000] drivers/usb/core/inode.c: creating file '001'
[    9.278000] usb usb2: New USB device found, idVendor=1d6b, idProduct=0001
[    9.278000] usb usb2: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    9.278000] usb usb2: Product: UHCI Host Controller
[    9.278000] usb usb2: Manufacturer: Linux 2.6.26-tip-03923-g2c96bcb-dirty uhci_hcd
[    9.278000] usb usb2: SerialNumber: 0000:00:1d.0
[    9.279000] uhci_hcd 0000:00:1d.1: PCI INT B -> GSI 17 (level, low) -> IRQ 17
[    9.279000] PCI: Setting latency timer of device 0000:00:1d.1 to 64
[    9.279000] uhci_hcd 0000:00:1d.1: UHCI Host Controller
[    9.279000] drivers/usb/core/inode.c: creating file '003'
[    9.279000] uhci_hcd 0000:00:1d.1: new USB bus registered, assigned bus number 3
[    9.279000] uhci_hcd 0000:00:1d.1: detected 2 ports
[    9.280000] uhci_hcd 0000:00:1d.1: uhci_check_and_reset_hc: cmd = 0x0000
[    9.280000] uhci_hcd 0000:00:1d.1: Performing full reset
[    9.280000] uhci_hcd 0000:00:1d.1: supports USB remote wakeup
[    9.280000] uhci_hcd 0000:00:1d.1: irq 17, io base 0x00001840
[    9.280000] usb usb3: default language 0x0409
[    9.280000] usb usb3: uevent
[    9.281000] usb usb3: usb_probe_device
[    9.281000] usb usb3: configuration #1 chosen from 1 choice
[    9.281000] usb usb3: adding 3-0:1.0 (config #1, interface 0)
[    9.281000] usb 3-0:1.0: uevent
[    9.281000] hub 3-0:1.0: usb_probe_interface
[    9.281000] hub 3-0:1.0: usb_probe_interface - got id
[    9.281000] hub 3-0:1.0: USB hub found
[    9.281000] hub 3-0:1.0: 2 ports detected
[    9.282000] hub 3-0:1.0: standalone hub
[    9.282000] hub 3-0:1.0: no power switching (usb 1.0)
[    9.282000] hub 3-0:1.0: individual port over-current protection
[    9.282000] hub 3-0:1.0: power on to power good time: 2ms
[    9.282000] hub 3-0:1.0: local power source is good
[    9.282000] hub 3-0:1.0: trying to enable port power on non-switchable hub
[    9.328500] ehci_hcd 0000:00:1d.7: port 8 full speed --> companion
[    9.328500] ehci_hcd 0000:00:1d.7: GetStatus port 8 status 003801 POWER OWNER sig=j CONNECT
[    9.328500] hub 1-0:1.0: port 8 not reset yet, waiting 50ms
[    9.379500] ehci_hcd 0000:00:1d.7: GetStatus port 8 status 003002 POWER OWNER sig=se0 CSC
[    9.379500] hub 2-0:1.0: state 7 ports 2 chg 0000 evt 0000
[    9.379500] hub 1-0:1.0: state 7 ports 8 chg 0000 evt 0100
[    9.383500] hub 3-0:1.0: state 7 ports 2 chg 0000 evt 0000
[    9.383000] drivers/usb/core/inode.c: creating file '001'
[    9.383000] usb usb3: New USB device found, idVendor=1d6b, idProduct=0001
[    9.383000] usb usb3: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    9.383000] usb usb3: Product: UHCI Host Controller
[    9.383000] usb usb3: Manufacturer: Linux 2.6.26-tip-03923-g2c96bcb-dirty uhci_hcd
[    9.383000] usb usb3: SerialNumber: 0000:00:1d.1
[    9.384000] uhci_hcd 0000:00:1d.2: power state changed by ACPI to D0
[    9.384000] uhci_hcd 0000:00:1d.2: PCI INT C -> GSI 18 (level, low) -> IRQ 18
[    9.384000] PCI: Setting latency timer of device 0000:00:1d.2 to 64
[    9.385000] uhci_hcd 0000:00:1d.2: UHCI Host Controller
[    9.385000] drivers/usb/core/inode.c: creating file '004'
[    9.385000] uhci_hcd 0000:00:1d.2: new USB bus registered, assigned bus number 4
[    9.386000] uhci_hcd 0000:00:1d.2: detected 2 ports
[    9.386000] uhci_hcd 0000:00:1d.2: uhci_check_and_reset_hc: cmd = 0x0000
[    9.386000] uhci_hcd 0000:00:1d.2: Performing full reset
[    9.387000] uhci_hcd 0000:00:1d.2: supports USB remote wakeup
[    9.387000] uhci_hcd 0000:00:1d.2: irq 18, io base 0x00001860
[    9.387000] usb usb4: default language 0x0409
[    9.387000] usb usb4: uevent
[    9.387000] usb usb4: usb_probe_device
[    9.387000] usb usb4: configuration #1 chosen from 1 choice
[    9.387000] usb usb4: adding 4-0:1.0 (config #1, interface 0)
[    9.388000] usb 4-0:1.0: uevent
[    9.388000] hub 4-0:1.0: usb_probe_interface
[    9.388000] hub 4-0:1.0: usb_probe_interface - got id
[    9.388000] hub 4-0:1.0: USB hub found
[    9.388000] hub 4-0:1.0: 2 ports detected
[    9.388000] hub 4-0:1.0: standalone hub
[    9.388000] hub 4-0:1.0: no power switching (usb 1.0)
[    9.388000] hub 4-0:1.0: individual port over-current protection
[    9.389000] hub 4-0:1.0: power on to power good time: 2ms
[    9.389000] hub 4-0:1.0: local power source is good
[    9.389000] hub 4-0:1.0: trying to enable port power on non-switchable hub
[    9.490500] hub 4-0:1.0: state 7 ports 2 chg 0000 evt 0000
[    9.490000] drivers/usb/core/inode.c: creating file '001'
[    9.490000] usb usb4: New USB device found, idVendor=1d6b, idProduct=0001
[    9.490000] usb usb4: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    9.490000] usb usb4: Product: UHCI Host Controller
[    9.490000] usb usb4: Manufacturer: Linux 2.6.26-tip-03923-g2c96bcb-dirty uhci_hcd
[    9.490000] usb usb4: SerialNumber: 0000:00:1d.2
[    9.491000] Pin 1-19 already programmed
[    9.491000] uhci_hcd 0000:00:1d.3: PCI INT D -> GSI 19 (level, low) -> IRQ 19
[    9.491000] PCI: Setting latency timer of device 0000:00:1d.3 to 64
[    9.491000] uhci_hcd 0000:00:1d.3: UHCI Host Controller
[    9.491000] drivers/usb/core/inode.c: creating file '005'
[    9.491000] uhci_hcd 0000:00:1d.3: new USB bus registered, assigned bus number 5
[    9.492000] uhci_hcd 0000:00:1d.3: detected 2 ports
[    9.492000] uhci_hcd 0000:00:1d.3: uhci_check_and_reset_hc: cmd = 0x0000
[    9.492000] uhci_hcd 0000:00:1d.3: Performing full reset
[    9.492000] uhci_hcd 0000:00:1d.3: irq 19, io base 0x00001880
[    9.492000] usb usb5: default language 0x0409
[    9.492000] usb usb5: uevent
[    9.493000] usb usb5: usb_probe_device
[    9.493000] usb usb5: configuration #1 chosen from 1 choice
[    9.493000] usb usb5: adding 5-0:1.0 (config #1, interface 0)
[    9.493000] usb 5-0:1.0: uevent
[    9.493000] hub 5-0:1.0: usb_probe_interface
[    9.493000] hub 5-0:1.0: usb_probe_interface - got id
[    9.493000] hub 5-0:1.0: USB hub found
[    9.493000] hub 5-0:1.0: 2 ports detected
[    9.494000] hub 5-0:1.0: standalone hub
[    9.494000] hub 5-0:1.0: no power switching (usb 1.0)
[    9.494000] hub 5-0:1.0: individual port over-current protection
[    9.494000] hub 5-0:1.0: power on to power good time: 2ms
[    9.494000] hub 5-0:1.0: local power source is good
[    9.494000] hub 5-0:1.0: trying to enable port power on non-switchable hub
[    9.595500] hub 5-0:1.0: state 7 ports 2 chg 0000 evt 0000
[    9.595000] drivers/usb/core/inode.c: creating file '001'
[    9.595500] uhci_hcd 0000:00:1d.3: port 2 portsc 009b,00
[    9.595500] hub 5-0:1.0: port 2, status 0101, change 0003, 12 Mb/s
[    9.595000] usb usb5: New USB device found, idVendor=1d6b, idProduct=0001
[    9.595000] usb usb5: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    9.595000] usb usb5: Product: UHCI Host Controller
[    9.596000] usb usb5: Manufacturer: Linux 2.6.26-tip-03923-g2c96bcb-dirty uhci_hcd
[    9.596000] usb usb5: SerialNumber: 0000:00:1d.3
[    9.596000] initcall uhci_hcd_init+0x0/0xc6 returned 0 after 405 msecs
[    9.596000] calling  sl811h_init+0x0/0x3d
[    9.596000] sl811: driver sl811-hcd, 19 May 2005
[    9.596000] initcall sl811h_init+0x0/0x3d returned 0 after 0 msecs
[    9.597000] calling  acm_init+0x0/0xd7
[    9.699500] hub 5-0:1.0: debounce: port 2: total 100ms stable 100ms status 0x101
[    9.801500] usb 5-2: new full speed USB device using uhci_hcd and address 2
[    9.922000] usb 5-2: ep0 maxpacket = 8
[    9.949000] usb 5-2: default language 0x0409
[    9.971000] usb 5-2: uevent
[    9.971000] usb 5-2: usb_probe_device
[    9.971000] usb 5-2: configuration #1 chosen from 1 choice
[    9.974000] usb 5-2: adding 5-2:1.0 (config #1, interface 0)
[    9.974000] usb 5-2:1.0: uevent
[    9.975000] drivers/usb/core/inode.c: creating file '002'
[    9.975000] usb 5-2: New USB device found, idVendor=0483, idProduct=2016
[    9.975000] usb 5-2: New USB device strings: Mfr=1, Product=2, SerialNumber=0
[    9.975000] usb 5-2: Product: Biometric Coprocessor
[    9.976000] usb 5-2: Manufacturer: STMicroelectronics
[    9.976000] usbcore: registered new interface driver cdc_acm
[    9.976000] cdc_acm: v0.26:USB Abstract Control Model driver for USB modems and ISDN adapters
[    9.976000] initcall acm_init+0x0/0xd7 returned 0 after 361 msecs
[    9.976000] calling  usblp_init+0x0/0x1b
[    9.976000] usbcore: registered new interface driver usblp
[    9.977000] initcall usblp_init+0x0/0x1b returned 0 after 0 msecs
[    9.977000] calling  adu_init+0x0/0x80
[    9.977000] drivers/usb/misc/adutux.c :  adu_init : enter 
[    9.977000] usbcore: registered new interface driver adutux
[    9.977000] adutux: adutux adutux (see www.ontrak.net) v0.0.13
[    9.977000] adutux: adutux is an experimental driver. Use at your own risk
[    9.977000] drivers/usb/misc/adutux.c :  adu_init : leave, return value 0 
[    9.978000] initcall adu_init+0x0/0x80 returned 0 after 0 msecs
[    9.978000] calling  appledisplay_init+0x0/0x53
[    9.978000] usbcore: registered new interface driver appledisplay
[    9.978000] initcall appledisplay_init+0x0/0x53 returned 0 after 0 msecs
[    9.978000] calling  berry_init+0x0/0x1b
[    9.978000] usbcore: registered new interface driver berry_charge
[    9.979000] initcall berry_init+0x0/0x1b returned 0 after 0 msecs
[    9.979000] calling  usb_cytherm_init+0x0/0x41
[    9.979000] usbcore: registered new interface driver cytherm
[    9.979000] cytherm: v1.0:Cypress USB Thermometer driver
[    9.979000] initcall usb_cytherm_init+0x0/0x41 returned 0 after 0 msecs
[    9.979000] calling  emi62_init+0x0/0x32
[    9.980000] usbcore: registered new interface driver emi62 - firmware loader
[    9.980000] initcall emi62_init+0x0/0x32 returned 0 after 0 msecs
[    9.980000] calling  usb_idmouse_init+0x0/0x3f
[    9.980000] idmouse: Siemens ID Mouse FingerTIP Sensor Driver 0.6
[    9.980000] usbcore: registered new interface driver idmouse
[    9.980000] initcall usb_idmouse_init+0x0/0x3f returned 0 after 0 msecs
[    9.980000] calling  usb_lcd_init+0x0/0x34
[    9.981000] usbcore: registered new interface driver usblcd
[    9.981000] initcall usb_lcd_init+0x0/0x34 returned 0 after 0 msecs
[    9.981000] calling  usb_led_init+0x0/0x34
[    9.981000] usbcore: registered new interface driver usbled
[    9.981000] initcall usb_led_init+0x0/0x34 returned 0 after 0 msecs
[    9.982000] calling  lego_usb_tower_init+0x0/0x7a
[    9.982000] drivers/usb/misc/legousbtower.c: lego_usb_tower_init: enter
[    9.982000] usbcore: registered new interface driver legousbtower
[    9.982000] legousbtower: LEGO USB Tower Driver v0.96
[    9.982000] drivers/usb/misc/legousbtower.c: lego_usb_tower_init: leave, return value 0
[    9.982000] initcall lego_usb_tower_init+0x0/0x7a returned 0 after 0 msecs
[    9.982000] calling  usb_rio_init+0x0/0x32
[    9.983000] usbcore: registered new interface driver rio500
[    9.983000] rio500: v1.1:USB Rio 500 driver
[    9.983000] initcall usb_rio_init+0x0/0x32 returned 0 after 0 msecs
[    9.983000] calling  usbtest_init+0x0/0x40
[    9.983000] usbtest 5-2:1.0: usb_probe_interface
[    9.983000] usbtest 5-2:1.0: usb_probe_interface - got id
[    9.983000] usbcore: registered new interface driver usbtest
[    9.984000] initcall usbtest_init+0x0/0x40 returned 0 after 0 msecs
[    9.984000] calling  cxacru_init+0x0/0x1b
[    9.984000] usbcore: registered new interface driver cxacru
[    9.984000] initcall cxacru_init+0x0/0x1b returned 0 after 0 msecs
[    9.984000] calling  usbatm_usb_init+0x0/0x61
[    9.984000] drivers/usb/atm/usbatm.c: usbatm_usb_init: driver version 1.10
[    9.984000] initcall usbatm_usb_init+0x0/0x61 returned 0 after 0 msecs
[    9.985000] calling  init+0x0/0x1b
[    9.985000] initcall init+0x0/0x1b returned 0 after 0 msecs
[    9.985000] calling  gs_module_init+0x0/0x11c
[    9.985000] gs_module_init: cannot register gadget driver, ret=-19
[    9.985000] initcall gs_module_init+0x0/0x11c returned -19 after 0 msecs
[    9.985000] calling  i8042_init+0x0/0x2db
[    9.986000] PNP: PS/2 Controller [PNP0303:KBD,PNP0f13:MOU] at 0x60,0x64 irq 1,12
[    9.994000] serio: i8042 KBD port at 0x60,0x64 irq 1
[    9.994000] serio: i8042 AUX port at 0x60,0x64 irq 12
[    9.995000] initcall i8042_init+0x0/0x2db returned 0 after 8 msecs
[    9.995000] calling  ct82c710_init+0x0/0x172
[    9.995000] initcall ct82c710_init+0x0/0x172 returned -19 after 0 msecs
[    9.995000] calling  pcips2_init+0x0/0x1b
[    9.995000] initcall pcips2_init+0x0/0x1b returned 0 after 0 msecs
[    9.996000] calling  mousedev_init+0x0/0x7d
[    9.996500] mice: PS/2 mouse device common for all mice
[    9.996500] initcall mousedev_init+0x0/0x7d returned 0 after 0 msecs
[    9.996500] calling  atkbd_init+0x0/0x1b
[    9.996500] initcall atkbd_init+0x0/0x1b returned 0 after 0 msecs
[    9.997500] calling  lkkbd_init+0x0/0x1b
[   10.002000] input: AT Translated Set 2 keyboard as /class/input/input3
[   10.008500] initcall lkkbd_init+0x0/0x1b returned 0 after 10 msecs
[   10.008500] calling  nkbd_init+0x0/0x1b
[   10.008500] initcall nkbd_init+0x0/0x1b returned 0 after 0 msecs
[   10.008500] calling  gpio_keys_init+0x0/0x14
[   10.008500] initcall gpio_keys_init+0x0/0x14 returned 0 after 0 msecs
[   10.008500] calling  joydump_init+0x0/0x18
[   10.009500] initcall joydump_init+0x0/0x18 returned 0 after 0 msecs
[   10.009500] calling  magellan_init+0x0/0x1b
[   10.009500] initcall magellan_init+0x0/0x1b returned 0 after 0 msecs
[   10.009500] calling  stinger_init+0x0/0x1b
[   10.010500] initcall stinger_init+0x0/0x1b returned 0 after 0 msecs
[   10.010500] calling  tgfx_init+0x0/0x38d
[   10.010500] initcall tgfx_init+0x0/0x38d returned -19 after 0 msecs
[   10.011500] calling  usb_xpad_init+0x0/0x32
[   10.011500] usbcore: registered new interface driver xpad
[   10.011500] xpad: X-Box pad driver
[   10.011500] initcall usb_xpad_init+0x0/0x32 returned 0 after 0 msecs
[   10.011500] calling  usb_acecad_init+0x0/0x32
[   10.011500] usbcore: registered new interface driver usb_acecad
[   10.011500] acecad: v3.2:USB Acecad Flair tablet driver
[   10.012500] initcall usb_acecad_init+0x0/0x32 returned 0 after 0 msecs
[   10.012500] calling  aiptek_init+0x0/0x3d
[   10.012500] usbcore: registered new interface driver aiptek
[   10.012500] aiptek: v2.3 (May 2, 2007): Bryan W. Headley/Chris Atenasio/Cedric Brun/Rene van Paassen
[   10.012500] aiptek: Aiptek HyperPen USB Tablet Driver (Linux 2.6.x)
[   10.012500] initcall aiptek_init+0x0/0x3d returned 0 after 0 msecs
[   10.012500] calling  gtco_init+0x0/0x40
[   10.013500] usbcore: registered new interface driver gtco
[   10.013500] GTCO usb driver version: 2.00.0006initcall gtco_init+0x0/0x40 returned 0 after 0 msecs
[   10.013500] calling  kbtab_init+0x0/0x32
[   10.013500] usbcore: registered new interface driver kbtab
[   10.013500] kbtab: v0.0.2:USB KB Gear JamStudio Tablet driver
[   10.013500] initcall kbtab_init+0x0/0x32 returned 0 after 0 msecs
[   10.014500] calling  pcwd_init_module+0x0/0x19
[   10.015500] initcall pcwd_init_module+0x0/0x19 returned -19 after 0 msecs
[   10.015500] calling  acq_init+0x0/0x5b
[   10.015500] WDT driver for Acquire single board computer initialising.
[   10.015500] acquirewdt: I/O address 0x0043 already in use
[   10.015500] acquirewdt: probe of acquirewdt failed with error -5
[   10.015500] initcall acq_init+0x0/0x5b returned 0 after 0 msecs
[   10.015500] calling  sc520_wdt_init+0x0/0xd5
[   10.016500] sc520_wdt: WDT driver for SC520 initialised. timeout=30 sec (nowayout=1)
[   10.016500] initcall sc520_wdt_init+0x0/0xd5 returned 0 after 0 msecs
[   10.016500] calling  ibwdt_init+0x0/0x5b
[   10.016500] ib700wdt: WDT driver for IB700 single board computer initialising.
[   10.016500] ib700wdt: failed to register misc device
[   10.017500] ib700wdt: probe of ib700wdt failed with error -16
[   10.017500] initcall ibwdt_init+0x0/0x5b returned 0 after 0 msecs
[   10.017500] calling  sbc7240_wdt_init+0x0/0xfa
[   10.017500] sbc7240_wdt: timeout set to 30 seconds
[   10.017500] sbc7240_wdt: cannot register miscdev on minor=130 (err=-16)
[   10.017500] initcall sbc7240_wdt_init+0x0/0xfa returned -16 after 0 msecs
[   10.017500] initcall sbc7240_wdt_init+0x0/0xfa returned with error code -16 
[   10.017500] calling  w83877f_wdt_init+0x0/0x13c
[   10.018500] w83877f_wdt: cannot register miscdev on minor=130 (err=-16)
[   10.018500] initcall w83877f_wdt_init+0x0/0x13c returned -16 after 0 msecs
[   10.018500] initcall w83877f_wdt_init+0x0/0x13c returned with error code -16 
[   10.018500] calling  telephony_init+0x0/0x44
[   10.018500] Linux telephony interface: v1.00
[   10.018500] initcall telephony_init+0x0/0x44 returned 0 after 0 msecs
[   10.018500] calling  isdn_init+0x0/0x267
[   10.019500] ISDN subsystem Rev: 1.1.2.3/1.1.2.3/1.1.2.2/none/none/1.1.2.2
[   10.019500] initcall isdn_init+0x0/0x267 returned 0 after 0 msecs
[   10.019500] calling  divert_init+0x0/0x5e
[   10.019500] dss1_divert module successfully installed
[   10.019500] initcall divert_init+0x0/0x5e returned 0 after 0 msecs
[   10.020500] calling  HiSax_init+0x0/0x303
[   10.020500] HiSax: Linux Driver for passive ISDN cards
[   10.020500] HiSax: Version 3.5 (kernel)
[   10.020500] HiSax: Layer1 Revision 2.46.2.5
[   10.020500] HiSax: Layer2 Revision 2.30.2.4
[   10.020500] HiSax: TeiMgr Revision 2.20.2.3
[   10.020500] HiSax: Layer3 Revision 2.22.2.3
[   10.020500] HiSax: LinkLayer Revision 2.59.2.4
[   10.020500] HiSax: Total 1 card defined
[   10.020500] HiSax: Card 1 Protocol EDSS1 Id=HiSax (0)
[   10.021500] HiSax: Niccy driver Rev. 1.21.2.4
[   10.021500] Niccy: io0 0 and NO_PCI_BIOS
[   10.021500] Niccy: unable to config NICCY PCI
[   10.021500] HiSax: Card NICCY not installed !
[   10.021500] initcall HiSax_init+0x0/0x303 returned -19 after 0 msecs
[   10.021500] calling  act2000_init+0x0/0x57
[   10.021500] IBM Active 2000 ISDN driver
[   10.021500] act2000: No cards defined yet
[   10.021500] initcall act2000_init+0x0/0x57 returned 0 after 0 msecs
[   10.022500] calling  init+0x0/0x1e8
[   10.022500] lguest: mapped switcher at ffc00000
[   10.022500] initcall init+0x0/0x1e8 returned 0 after 0 msecs
[   10.022500] calling  mmc_blk_init+0x0/0x27
[   10.022500] initcall mmc_blk_init+0x0/0x27 returned 0 after 0 msecs
[   10.023500] calling  mmc_test_init+0x0/0x14
[   10.023500] initcall mmc_test_init+0x0/0x14 returned 0 after 0 msecs
[   10.023500] calling  sdio_uart_init+0x0/0xcb
[   10.023500] initcall sdio_uart_init+0x0/0xcb returned 0 after 0 msecs
[   10.023500] calling  tifm_sd_init+0x0/0x14
[   10.023500] initcall tifm_sd_init+0x0/0x14 returned 0 after 0 msecs
[   10.024500] calling  memstick_init+0x0/0x72
[   10.024500] initcall memstick_init+0x0/0x72 returned 0 after 0 msecs
[   10.024500] calling  mspro_block_init+0x0/0x68
[   10.024500] initcall mspro_block_init+0x0/0x68 returned 0 after 0 msecs
[   10.024500] calling  tifm_ms_init+0x0/0x14
[   10.025500] initcall tifm_ms_init+0x0/0x14 returned 0 after 0 msecs
[   10.025500] calling  gpio_led_init+0x0/0x14
[   10.025500] Registered led device: rdc:dmz
[   10.025500] initcall gpio_led_init+0x0/0x14 returned 0 after 0 msecs
[   10.025500] calling  dcdbas_init+0x0/0x58
[   10.026500] dcdbas dcdbas: Dell Systems Management Base Driver (version 5.6.0-3.2)
[   10.026500] initcall dcdbas_init+0x0/0x58 returned 0 after 0 msecs
[   10.026500] calling  sysctl_core_init+0x0/0x14
[   10.026500] initcall sysctl_core_init+0x0/0x14 returned 0 after 0 msecs
[   10.026500] calling  flow_cache_init+0x0/0x14d
[   10.026500] initcall flow_cache_init+0x0/0x14d returned 0 after 0 msecs
[   10.027500] calling  pg_init+0x0/0x254
[   10.027500] pktgen v2.69: Packet Generator for packet performance testing.
[   10.027500] initcall pg_init+0x0/0x254 returned 0 after 0 msecs
[   10.027500] calling  llc_init+0x0/0x20
[   10.027500] initcall llc_init+0x0/0x20 returned 0 after 0 msecs
[   10.027500] calling  snap_init+0x0/0x2f
[   10.027500] initcall snap_init+0x0/0x2f returned 0 after 0 msecs
[   10.028500] calling  nfnetlink_init+0x0/0x54
[   10.028500] Netfilter messages via NETLINK v0.30.
[   10.028500] initcall nfnetlink_init+0x0/0x54 returned 0 after 0 msecs
[   10.028500] calling  nfnetlink_queue_init+0x0/0x8c
[   10.028500] initcall nfnetlink_queue_init+0x0/0x8c returned 0 after 0 msecs
[   10.028500] calling  nf_conntrack_standalone_init+0x0/0xa0
[   10.028500] nf_conntrack version 0.5.0 (16384 buckets, 65536 max)
[   10.028500] initcall nf_conntrack_standalone_init+0x0/0xa0 returned 0 after 0 msecs
[   10.029500] calling  nf_conntrack_tftp_init+0x0/0x154
[   10.029500] initcall nf_conntrack_tftp_init+0x0/0x154 returned 0 after 0 msecs
[   10.029500] calling  xt_init+0x0/0x83
[   10.029500] initcall xt_init+0x0/0x83 returned 0 after 0 msecs
[   10.029500] calling  tcpudp_mt_init+0x0/0x19
[   10.029500] initcall tcpudp_mt_init+0x0/0x19 returned 0 after 0 msecs
[   10.030500] calling  xt_rateest_tg_init+0x0/0x3b
[   10.030500] initcall xt_rateest_tg_init+0x0/0x3b returned 0 after 0 msecs
[   10.030500] calling  tcpmss_tg_init+0x0/0x19
[   10.030500] initcall tcpmss_tg_init+0x0/0x19 returned 0 after 0 msecs
[   10.030500] calling  comment_mt_init+0x0/0x19
[   10.030500] initcall comment_mt_init+0x0/0x19 returned 0 after 0 msecs
[   10.030500] calling  connmark_mt_init+0x0/0x19
[   10.030500] initcall connmark_mt_init+0x0/0x19 returned 0 after 0 msecs
[   10.031500] calling  dscp_mt_init+0x0/0x19
[   10.031500] initcall dscp_mt_init+0x0/0x19 returned 0 after 0 msecs
[   10.031500] calling  iprange_mt_init+0x0/0x19
[   10.031500] initcall iprange_mt_init+0x0/0x19 returned 0 after 0 msecs
[   10.031500] calling  xt_rateest_mt_init+0x0/0x19
[   10.031500] initcall xt_rateest_mt_init+0x0/0x19 returned 0 after 0 msecs
[   10.031500] calling  sctp_mt_init+0x0/0x19
[   10.031500] initcall sctp_mt_init+0x0/0x19 returned 0 after 0 msecs
[   10.032500] calling  state_mt_init+0x0/0x19
[   10.032500] initcall state_mt_init+0x0/0x19 returned 0 after 0 msecs
[   10.032500] calling  u32_mt_init+0x0/0x19
[   10.032500] initcall u32_mt_init+0x0/0x19 returned 0 after 0 msecs
[   10.032500] calling  sysctl_ipv4_init+0x0/0x44
[   10.032500] initcall sysctl_ipv4_init+0x0/0x44 returned 0 after 0 msecs
[   10.032500] calling  ah4_init+0x0/0x5f
[   10.032500] initcall ah4_init+0x0/0x5f returned 0 after 0 msecs
[   10.033500] calling  esp4_init+0x0/0x5f
[   10.033500] initcall esp4_init+0x0/0x5f returned 0 after 0 msecs
[   10.033500] calling  ipcomp4_init+0x0/0x5f
[   10.033500] initcall ipcomp4_init+0x0/0x5f returned 0 after 0 msecs
[   10.033500] calling  ipip_init+0x0/0x8d
[   10.033500] initcall ipip_init+0x0/0x8d returned 0 after 0 msecs
[   10.033500] calling  tunnel4_init+0x0/0x5f
[   10.033500] initcall tunnel4_init+0x0/0x5f returned 0 after 0 msecs
[   10.034500] calling  xfrm4_mode_tunnel_init+0x0/0x19
[   10.034500] initcall xfrm4_mode_tunnel_init+0x0/0x19 returned 0 after 0 msecs
[   10.034500] calling  ipv4_netfilter_init+0x0/0x14
[   10.034500] initcall ipv4_netfilter_init+0x0/0x14 returned 0 after 0 msecs
[   10.034500] calling  arp_tables_init+0x0/0x7d
[   10.034500] arp_tables: (C) 2002 David S. Miller
[   10.034500] initcall arp_tables_init+0x0/0x7d returned 0 after 0 msecs
[   10.035500] calling  arpt_mangle_init+0x0/0x14
[   10.035500] initcall arpt_mangle_init+0x0/0x14 returned 0 after 0 msecs
[   10.035500] calling  arptable_filter_init+0x0/0x3d
[   10.035500] initcall arptable_filter_init+0x0/0x3d returned 0 after 0 msecs
[   10.035500] calling  ip_queue_init+0x0/0x111
[   10.035500] initcall ip_queue_init+0x0/0x111 returned 0 after 0 msecs
[   10.035500] calling  cubictcp_register+0x0/0x98
[   10.035500] TCP cubic registered
[   10.036500] initcall cubictcp_register+0x0/0x98 returned 0 after 0 msecs
[   10.036500] calling  xfrm_user_init+0x0/0x56
[   10.036500] Initializing XFRM netlink socket
[   10.037500] initcall xfrm_user_init+0x0/0x56 returned 0 after 0 msecs
[   10.037500] calling  inet6_init+0x0/0x2ee
[   10.037500] NET: Registered protocol family 10
[   10.039500] initcall inet6_init+0x0/0x2ee returned 0 after 1 msecs
[   10.039500] calling  esp6_init+0x0/0x5f
[   10.039500] initcall esp6_init+0x0/0x5f returned 0 after 0 msecs
[   10.039500] calling  ipcomp6_init+0x0/0x5f
[   10.040500] initcall ipcomp6_init+0x0/0x5f returned 0 after 0 msecs
[   10.040500] calling  xfrm6_tunnel_init+0x0/0xe0
[   10.040500] initcall xfrm6_tunnel_init+0x0/0xe0 returned 0 after 0 msecs
[   10.040500] calling  tunnel6_init+0x0/0x5f
[   10.040500] initcall tunnel6_init+0x0/0x5f returned 0 after 0 msecs
[   10.040500] calling  xfrm6_transport_init+0x0/0x19
[   10.040500] initcall xfrm6_transport_init+0x0/0x19 returned 0 after 0 msecs
[   10.040500] calling  ip6_queue_init+0x0/0x111
[   10.041500] initcall ip6_queue_init+0x0/0x111 returned 0 after 0 msecs
[   10.041500] calling  ip6_tunnel_init+0x0/0x91
[   10.041500] ------------[ cut here ]------------
[   10.041500] WARNING: at net/core/dst.c:265 dst_release+0x24/0x2b()
[   10.041500] Modules linked in:
[   10.042500] Pid: 7, comm: ksoftirqd/1 Not tainted 2.6.26-tip-03923-g2c96bcb-dirty #3134
[   10.042500]  [<b0139b2d>] warn_on_slowpath+0x46/0x6a
[   10.042500]  [<b0152c9a>] ? put_lock_stats+0xd/0x21
[   10.042500]  [<b015397b>] ? __lock_acquire+0x5ba/0x618
[   10.042500]  [<b0152c9a>] ? put_lock_stats+0xd/0x21
[   10.042500]  [<b05642f6>] dst_release+0x24/0x2b
[   10.043500]  [<b055bfa3>] skb_release_all+0x13/0x83
[   10.043500]  [<b055b910>] __kfree_skb+0x10/0x6b
[   10.043500]  [<b0561e16>] net_tx_action+0x6e/0xee
[   10.043500]  [<b013e38d>] __do_softirq+0x7a/0xe8
[   10.043500]  [<b013e313>] ? __do_softirq+0x0/0xe8
[   10.043500]  [<b011ccc6>] do_softirq+0x79/0xba
[   10.043500]  [<b013e647>] ksoftirqd+0x88/0x13b
[   10.044500]  [<b013e5bf>] ? ksoftirqd+0x0/0x13b
[   10.044500]  [<b014a365>] kthread+0x40/0x67
[   10.044500]  [<b014a325>] ? kthread+0x0/0x67
[   10.044500]  [<b011b7c7>] kernel_thread_helper+0x7/0x10
[   10.044500]  =======================
[   10.044500] ---[ end trace 96563eea573244e7 ]---
[   10.044500] Attempt to release alive inet socket f6fac040
[   10.045500] initcall ip6_tunnel_init+0x0/0x91 returned 0 after 3 msecs
[   10.045500] calling  packet_init+0x0/0x3e
[   10.045500] NET: Registered protocol family 17
[   10.045500] initcall packet_init+0x0/0x3e returned 0 after 0 msecs
[   10.045500] calling  br_init+0x0/0xb1
[   10.045500] initcall br_init+0x0/0xb1 returned 0 after 0 msecs
[   10.045500] calling  ipx_init+0x0/0xd7
[   10.046500] NET: Registered protocol family 4
[   10.046500] initcall ipx_init+0x0/0xd7 returned 0 after 0 msecs
[   10.046500] calling  atm_clip_init+0x0/0x95
[   10.046500] initcall atm_clip_init+0x0/0x95 returned 0 after 0 msecs
[   10.046500] calling  econet_proto_init+0x0/0x190
[   10.046500] NET: Registered protocol family 19
[   10.046500] initcall econet_proto_init+0x0/0x190 returned 0 after 0 msecs
[   10.046500] calling  ieee80211_init+0x0/0x20
[   10.047500] ieee80211: 802.11 data/management/control stack, git-1.1.13
[   10.047500] ieee80211: Copyright (C) 2004-2005 Intel Corporation <jketreno@linux.intel.com>
[   10.047500] initcall ieee80211_init+0x0/0x20 returned 0 after 0 msecs
[   10.047500] calling  ieee80211_crypto_init+0x0/0x14
[   10.047500] ieee80211_crypt: registered algorithm 'NULL'
[   10.047500] initcall ieee80211_crypto_init+0x0/0x14 returned 0 after 0 msecs
[   10.047500] calling  update_mp_table+0x0/0x400
[   10.047500] initcall update_mp_table+0x0/0x400 returned 0 after 0 msecs
[   10.048500] calling  lapic_insert_resource+0x0/0x49
[   10.048500] initcall lapic_insert_resource+0x0/0x49 returned 0 after 0 msecs
[   10.048500] calling  init_lapic_nmi_sysfs+0x0/0x38
[   10.048500] initcall init_lapic_nmi_sysfs+0x0/0x38 returned 0 after 0 msecs
[   10.048500] calling  io_apic_bug_finalize+0x0/0x1f
[   10.048500] initcall io_apic_bug_finalize+0x0/0x1f returned 0 after 0 msecs
[   10.048500] calling  balanced_irq_init+0x0/0x147
[   10.048500] Starting balanced_irq
[   10.049500] initcall balanced_irq_init+0x0/0x147 returned 0 after 0 msecs
[   10.049500] calling  check_early_ioremap_leak+0x0/0x3d
[   10.049500] initcall check_early_ioremap_leak+0x0/0x3d returned 0 after 0 msecs
[   10.049500] calling  print_ipi_mode+0x0/0x2a
[   10.049500] Using IPI No-Shortcut mode
[   10.049500] initcall print_ipi_mode+0x0/0x2a returned 0 after 0 msecs
[   10.049500] calling  init_oops_id+0x0/0x28
[   10.049500] initcall init_oops_id+0x0/0x28 returned 0 after 0 msecs
[   10.050500] calling  disable_boot_consoles+0x0/0x3b
[   10.050500] initcall disable_boot_consoles+0x0/0x3b returned 0 after 0 msecs
[   10.050500] calling  pm_qos_power_init+0x0/0x59
[   10.050500] initcall pm_qos_power_init+0x0/0x59 returned 0 after 0 msecs
[   10.050500] calling  debugfs_kprobe_init+0x0/0x7d
[   10.050500] initcall debugfs_kprobe_init+0x0/0x7d returned 0 after 0 msecs
[   10.051500] calling  taskstats_init+0x0/0x82
[   10.051500] registered taskstats version 1
[   10.051500] initcall taskstats_init+0x0/0x82 returned 0 after 0 msecs
[   10.051500] calling  fail_page_alloc_debugfs+0x0/0xc6
[   10.051500] initcall fail_page_alloc_debugfs+0x0/0xc6 returned 0 after 0 msecs
[   10.051500] calling  fail_make_request_debugfs+0x0/0x19
[   10.052500] initcall fail_make_request_debugfs+0x0/0x19 returned 0 after 0 msecs
[   10.052500] calling  random32_reseed+0x0/0x4e
[   10.052500] initcall random32_reseed+0x0/0x4e returned 0 after 0 msecs
[   10.052500] calling  pci_sysfs_init+0x0/0x49
[   10.052500] initcall pci_sysfs_init+0x0/0x49 returned 0 after 0 msecs
[   10.052500] calling  acpi_wakeup_device_init+0x0/0x9f
[   10.053500] initcall acpi_wakeup_device_init+0x0/0x9f returned 0 after 0 msecs
[   10.053500] calling  acpi_sleep_proc_init+0x0/0x93
[   10.053500] initcall acpi_sleep_proc_init+0x0/0x93 returned 0 after 0 msecs
[   10.053500] calling  seqgen_init+0x0/0x13
[   10.053500] initcall seqgen_init+0x0/0x13 returned 0 after 0 msecs
[   10.053500] calling  hd_init+0x0/0x2a0
[   10.053500] hd: no drives specified - use hd=cyl,head,sectors on kernel command line
[   10.054500] initcall hd_init+0x0/0x2a0 returned -1 after 0 msecs
[   10.054500] initcall hd_init+0x0/0x2a0 returned with error code -1 
[   10.054500] calling  scsi_complete_async_scans+0x0/0xd2
[   10.054500] initcall scsi_complete_async_scans+0x0/0xd2 returned 0 after 0 msecs
[   10.054500] calling  tcp_congestion_default+0x0/0x14
[   10.054500] initcall tcp_congestion_default+0x0/0x14 returned 0 after 0 msecs
[   10.054500] calling  ip_auto_config+0x0/0xc8b
[   10.054500] initcall ip_auto_config+0x0/0xc8b returned 0 after 0 msecs
[   10.085500] kjournald starting.  Commit interval 5 seconds
[   10.085000] EXT3-fs: mounted filesystem with ordered data mode.
[   10.085000] VFS: Mounted root (ext3 filesystem) readonly.
[   10.086000] Freeing unused kernel memory: 652k freed
[   10.454000] usb usb2: suspend_rh (auto-stop)
[   10.454000] usb usb3: suspend_rh (auto-stop)
[   10.704000] usb usb4: suspend_rh (auto-stop)
[   13.522500] usb usb2: uevent
[   13.522500] usb 2-0:1.0: uevent
[   13.522500] usb usb3: uevent
[   13.522500] usb 3-0:1.0: uevent
[   13.523500] usb usb4: uevent
[   13.523500] usb 4-0:1.0: uevent
[   13.523500] usb usb5: uevent
[   13.523500] usb 5-0:1.0: uevent
[   13.523500] usb 5-2: uevent
[   13.523500] usb 5-2:1.0: uevent
[   13.523500] usb usb1: uevent
[   13.524500] usb 1-0:1.0: uevent
[   19.394000] Attempt to release alive inet socket f6fac040
[   20.389000] EXT3 FS on sda1, internal journal
[   20.764500] eth0: no IPv6 routers present
[   22.460000] warning: process `kudzu' used the deprecated sysctl system call with 1.23.
[   22.933000] ------------[ cut here ]------------
[   22.933000] kernel BUG at mm/slab.c:2927!
[   22.933000] invalid opcode: 0000 [#1] PREEMPT SMP 
[   22.933000] Modules linked in:
[   22.933000] 
[   22.933000] Pid: 1796, comm: ip6tables-resto Tainted: G        W (2.6.26-tip-03923-g2c96bcb-dirty #3134)
[   22.933000] EIP: 0060:[<b01878d2>] EFLAGS: 00010046 CPU: 0
[   22.933000] EIP is at cache_alloc_refill+0xfa/0x431
[   22.933000] EAX: 00000004 EBX: f6684800 ECX: f6f806c0 EDX: f6fa3c40
[   22.933000] ESI: f6fac000 EDI: 0000000b EBP: f6badec4 ESP: f6bade70
[   22.933000]  DS: 007b ES: 007b FS: 00d8 GS: 0033 SS: 0068
[   22.933000] Process ip6tables-resto (pid: 1796, ti=f6bad000 task=f67ac060 task.ti=f6bad000)
[   22.933000] Stack: 00000004 00000004 000000d0 000000d0 f6f806c8 f6f806d0 f6fac01c 000080d0 
[   22.933000]        f6fa3c40 f6fa9800 f6f806c0 00000000 7f430025 b014a3e9 b2bd6a80 00000000 
[   22.933000]        00000000 00000000 00000246 f6fa3c40 f6fa3c40 f6badee4 b0187793 b07c11d6 
[   22.933000] Call Trace:
[   22.933000]  [<b014a3e9>] ? __wake_up_bit+0xc/0x37
[   22.933000]  [<b0187793>] ? kmem_cache_alloc+0x53/0x98
[   22.933000]  [<b05589b5>] ? sk_prot_alloc+0x1e/0xa7
[   22.933000]  [<b026cb86>] ? cap_capable+0xa/0x2b
[   22.933000]  [<b0559fa4>] ? sk_alloc+0x20/0xa3
[   22.933000]  [<b05c4364>] ? inet6_create+0x187/0x316
[   22.933000]  [<b0556e87>] ? __sock_create+0x15b/0x229
[   22.933000]  [<b0556f9c>] ? sock_create+0x29/0x2e
[   22.933000]  [<b0557112>] ? sys_socket+0x1e/0x42
[   22.933000]  [<b05577b6>] ? sys_socketcall+0x56/0x163
[   22.933000]  [<b011a418>] ? resume_userspace+0x8/0x30
[   22.933000]  [<b011a4ff>] ? sysenter_past_esp+0x78/0xb9
[   22.933000]  =======================
[   22.933000] Code: bb 00 00 00 8b 45 d4 8b 30 39 c6 75 13 c7 40 50 01 00 00 00 8b 70 10 3b 75 c0 0f 84 94 00 00 00 8b 55 cc 8b 42 38 39 46 10 72 37 <0f> 0b eb fe 8b 0b 89 4d ac 8b 56 14 8b 45 cc 0f af 50 2c 03 56 
[   22.933000] EIP: [<b01878d2>] cache_alloc_refill+0xfa/0x431 SS:ESP 0068:f6bade70
[   22.933000] Kernel panic - not syncing: Fatal exception
[   22.933000] Pid: 1796, comm: ip6tables-resto Tainted: G      D W 2.6.26-tip-03923-g2c96bcb-dirty #3134
[   22.933000]  [<b0139a3e>] panic+0x4e/0xf7
[   22.933000]  [<b064b7ca>] oops_end+0x70/0x94
[   22.933000]  [<b011bef6>] die+0x5c/0x64
[   22.933000]  [<b064b9cf>] do_trap+0x83/0x8b
[   22.933000]  [<b011bf7a>] ? do_invalid_op+0x0/0x7b
[   22.933000]  [<b011bfeb>] do_invalid_op+0x71/0x7b
[   22.933000]  [<b01878d2>] ? cache_alloc_refill+0xfa/0x431
[   22.933000]  [<b012e2cb>] ? kmap_atomic_prot+0x1f/0x1de
[   22.933000]  [<b019bed2>] ? touch_atime+0xa7/0xc1
[   22.933000]  [<b064b5a2>] error_code+0x72/0x80
[   22.933000]  [<b01878d2>] ? cache_alloc_refill+0xfa/0x431
[   22.933000]  [<b014a3e9>] ? __wake_up_bit+0xc/0x37
[   22.933000]  [<b0187793>] kmem_cache_alloc+0x53/0x98
[   22.933000]  [<b05589b5>] sk_prot_alloc+0x1e/0xa7
[   22.933000]  [<b026cb86>] ? cap_capable+0xa/0x2b
[   22.933000]  [<b0559fa4>] sk_alloc+0x20/0xa3
[   22.933000]  [<b05c4364>] inet6_create+0x187/0x316
[   22.933000]  [<b0556e87>] __sock_create+0x15b/0x229
[   22.933000]  [<b0556f9c>] sock_create+0x29/0x2e
[   22.933000]  [<b0557112>] sys_socket+0x1e/0x42
[   22.933000]  [<b05577b6>] sys_socketcall+0x56/0x163
[   22.933000]  [<b011a418>] ? resume_userspace+0x8/0x30
[   22.933000]  [<b011a4ff>] sysenter_past_esp+0x78/0xb9
[   22.933000]  =======================
[   22.933000] ------------[ cut here ]------------
[   22.933000] WARNING: at kernel/smp.c:288 smp_call_function_mask+0x38/0x131()
[   22.933000] Modules linked in:
[   22.933000] Pid: 1796, comm: ip6tables-resto Tainted: G      D W 2.6.26-tip-03923-g2c96bcb-dirty #3134
[   22.933000]  [<b0139b2d>] warn_on_slowpath+0x46/0x6a
[   22.933000]  [<b0139f0f>] ? wake_up_klogd+0x8/0x36
[   22.933000]  [<b013a0d6>] ? release_console_sem+0x199/0x1a1
[   22.933000]  [<b013a61b>] ? vprintk+0x384/0x3a4
[   22.933000]  [<b064b2a1>] ? _spin_unlock_irqrestore+0x3b/0x51
[   22.933000]  [<b0130020>] ? twofish_dec_blk+0xd9/0x729
[   22.933000]  [<b011a4ff>] ? sysenter_past_esp+0x78/0xb9
[   22.933000]  [<b013a655>] ? printk+0x1a/0x1c
[   22.933000]  [<b0162cc2>] ? touch_softlockup_watchdog+0x8/0x1d
[   22.933000]  [<b015806e>] smp_call_function_mask+0x38/0x131
[   22.933000]  [<b0127d94>] ? stop_this_cpu+0x0/0x48
[   22.933000]  [<b013a655>] ? printk+0x1a/0x1c
[   22.933000]  [<b011bc3e>] ? show_trace_log_lvl+0x25/0x2d
[   22.933000]  [<b011c0e2>] ? show_trace+0x15/0x19
[   22.933000]  [<b0127d94>] ? stop_this_cpu+0x0/0x48
[   22.933000]  [<b0158191>] smp_call_function+0x2a/0x53
[   22.933000]  [<b0127e32>] native_smp_send_stop+0x20/0x4a
[   22.933000]  [<b0139a4b>] panic+0x5b/0xf7
[   22.933000]  [<b064b7ca>] oops_end+0x70/0x94
[   22.933000]  [<b011bef6>] die+0x5c/0x64
[   22.933000]  [<b064b9cf>] do_trap+0x83/0x8b
[   22.933000]  [<b011bf7a>] ? do_invalid_op+0x0/0x7b
[   22.933000]  [<b011bfeb>] do_invalid_op+0x71/0x7b
[   22.933000]  [<b01878d2>] ? cache_alloc_refill+0xfa/0x431
[   22.933000]  [<b012e2cb>] ? kmap_atomic_prot+0x1f/0x1de
[   22.933000]  [<b019bed2>] ? touch_atime+0xa7/0xc1
[   22.933000]  [<b064b5a2>] error_code+0x72/0x80
[   22.933000]  [<b01878d2>] ? cache_alloc_refill+0xfa/0x431
[   22.933000]  [<b014a3e9>] ? __wake_up_bit+0xc/0x37
[   22.933000]  [<b0187793>] kmem_cache_alloc+0x53/0x98
[   22.933000]  [<b05589b5>] sk_prot_alloc+0x1e/0xa7
[   22.933000]  [<b026cb86>] ? cap_capable+0xa/0x2b
[   22.933000]  [<b0559fa4>] sk_alloc+0x20/0xa3
[   22.933000]  [<b05c4364>] inet6_create+0x187/0x316
[   22.933000]  [<b0556e87>] __sock_create+0x15b/0x229
[   22.933000]  [<b0556f9c>] sock_create+0x29/0x2e
[   22.933000]  [<b0557112>] sys_socket+0x1e/0x42
[   22.933000]  [<b05577b6>] sys_socketcall+0x56/0x163
[   22.933000]  [<b011a418>] ? resume_userspace+0x8/0x30
[   22.933000]  [<b011a4ff>] sysenter_past_esp+0x78/0xb9
[   22.933000]  =======================
[   22.933000] ---[ end trace 96563eea573244e7 ]---
[   22.933000] ------------[ cut here ]------------
[   22.933000] WARNING: at kernel/smp.c:214 smp_call_function_single+0x44/0xd5()
[   22.933000] Modules linked in:
[   22.933000] Pid: 1796, comm: ip6tables-resto Tainted: G      D W 2.6.26-tip-03923-g2c96bcb-dirty #3134
[   22.933000]  [<b0139b2d>] warn_on_slowpath+0x46/0x6a
[   22.933000]  [<b0139f0f>] ? wake_up_klogd+0x8/0x36
[   22.933000]  [<b013a0d6>] ? release_console_sem+0x199/0x1a1
[   22.933000]  [<b013a61b>] ? vprintk+0x384/0x3a4
[   22.933000]  [<b064b2a1>] ? _spin_unlock_irqrestore+0x3b/0x51
[   22.933000]  [<b0130020>] ? twofish_dec_blk+0xd9/0x729
[   22.933000]  [<b0157fa5>] smp_call_function_single+0x44/0xd5
[   22.933000]  [<b0127d94>] ? stop_this_cpu+0x0/0x48
[   22.933000]  [<b013a655>] ? printk+0x1a/0x1c
[   22.933000]  [<b0162cc2>] ? touch_softlockup_watchdog+0x8/0x1d
[   22.933000]  [<b01580b8>] smp_call_function_mask+0x82/0x131
[   22.933000]  [<b0127d94>] ? stop_this_cpu+0x0/0x48
[   22.933000]  [<b013a655>] ? printk+0x1a/0x1c
[   22.933000]  [<b011bc3e>] ? show_trace_log_lvl+0x25/0x2d
[   22.933000]  [<b011c0e2>] ? show_trace+0x15/0x19
[   22.933000]  [<b0127d94>] ? stop_this_cpu+0x0/0x48
[   22.933000]  [<b0158191>] smp_call_function+0x2a/0x53
[   22.933000]  [<b0127e32>] native_smp_send_stop+0x20/0x4a
[   22.933000]  [<b0139a4b>] panic+0x5b/0xf7
[   22.933000]  [<b064b7ca>] oops_end+0x70/0x94
[   22.933000]  [<b011bef6>] die+0x5c/0x64
[   22.933000]  [<b064b9cf>] do_trap+0x83/0x8b
[   22.933000]  [<b011bf7a>] ? do_invalid_op+0x0/0x7b
[   22.933000]  [<b011bfeb>] do_invalid_op+0x71/0x7b
[   22.933000]  [<b01878d2>] ? cache_alloc_refill+0xfa/0x431
[   22.933000]  [<b012e2cb>] ? kmap_atomic_prot+0x1f/0x1de
[   22.933000]  [<b019bed2>] ? touch_atime+0xa7/0xc1
[   22.933000]  [<b064b5a2>] error_code+0x72/0x80
[   22.933000]  [<b01878d2>] ? cache_alloc_refill+0xfa/0x431
[   22.933000]  [<b014a3e9>] ? __wake_up_bit+0xc/0x37
[   22.933000]  [<b0187793>] kmem_cache_alloc+0x53/0x98
[   22.933000]  [<b05589b5>] sk_prot_alloc+0x1e/0xa7
[   22.933000]  [<b026cb86>] ? cap_capable+0xa/0x2b
[   22.933000]  [<b0559fa4>] sk_alloc+0x20/0xa3
[   22.933000]  [<b05c4364>] inet6_create+0x187/0x316
[   22.933000]  [<b0556e87>] __sock_create+0x15b/0x229
[   22.933000]  [<b0556f9c>] sock_create+0x29/0x2e
[   22.933000]  [<b0557112>] sys_socket+0x1e/0x42
[   22.933000]  [<b05577b6>] sys_socketcall+0x56/0x163
[   22.933000]  [<b011a418>] ? resume_userspace+0x8/0x30
[   22.933000]  [<b011a4ff>] sysenter_past_esp+0x78/0xb9
[   22.933000]  =======================
[   22.933000] ---[ end trace 96563eea573244e7 ]---
[   22.933000] Rebooting in 1 seconds..[    0.000000] Initializing cgroup subsys cpuset
