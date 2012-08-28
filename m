From: Pavel Roskin <proski@gnu.org>
Subject: route.c:645 suspicious rcu_dereference_check()
Date: Tue, 28 Aug 2012 17:57:34 -0400
Message-ID: <20120828175734.41b17a6c@mj>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="MP_/LgctS8_YzoCXyr=r_doHFj6"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from c60.cesmail.net ([216.154.195.49]:13962 "EHLO c60.cesmail.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753477Ab2H1WHQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Aug 2012 18:07:16 -0400
Received: from mj (static-72-92-88-10.phlapa.fios.verizon.net [72.92.88.10])
	by smtprelay1.cesmail.net (Postfix) with ESMTPSA id 1347A34C93
	for <netdev@vger.kernel.org>; Tue, 28 Aug 2012 17:57:40 -0400 (EDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--MP_/LgctS8_YzoCXyr=r_doHFj6
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hello!

I've got a warning in the kernel log starting with

[ 1570.586223] ===============================
[ 1570.586225] [ INFO: suspicious RCU usage. ]
[ 1570.586228] 3.6.0-rc3-wl-main #98 Not tainted
[ 1570.586229] -------------------------------
[ 1570.586231] /home/proski/src/linux/net/ipv4/route.c:645 suspicious
rcu_dereference_check() usage! [ 1570.586233] 
[ 1570.586233] other info that might help us debug this:
[ 1570.586233] 
[ 1570.586236] 
[ 1570.586236] rcu_scheduler_active = 1, debug_locks = 0
[ 1570.586238] 2 locks held by Chrome_IOThread/4467:
[ 1570.586240]  #0:  (slock-AF_INET){+.-...}, at: [<ffffffff814f2c0c>]
release_sock+0x2c/0xa0 [ 1570.586253]  #1:  (fnhe_lock){+.-...}, at:
[<ffffffff815302fc>] update_or_create_fnhe+0x2c/0x270 [ 1570.586260] 
[ 1570.586260] stack backtrace:
[ 1570.586263] Pid: 4467, comm: Chrome_IOThread Not tainted
3.6.0-rc3-wl-main #98 [ 1570.586265] Call Trace:
[ 1570.586271]  [<ffffffff810976ed>] lockdep_rcu_suspicious+0xfd/0x130
[ 1570.586275]  [<ffffffff8153042c>] update_or_create_fnhe+0x15c/0x270

The dmesg output and the .config file are attached.

I'm using the current wireless-testing.git, commit
46e3e1c03e88a8de28c2f0ab641a0d9a6a63893e.

The warning was apparently triggered by Google Chromium.  I'm running
Fedora 16 x64_64 with chromium-20.0.1132.47-2.

I ran Skype before that, not sure it's related.  I'm also experiencing
a problem with USB sound.  There is no sound and some programs hand if
they try to produce sound.  I also get a crash if I disconnect the USB
headset.  But I don't see anything about USB in the backtrace.

-- 
Regards,
Pavel Roskin

--MP_/LgctS8_YzoCXyr=r_doHFj6
Content-Type: text/x-log
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename=kernel.log

[    0.000000] Initializing cgroup subsys cpuset
[    0.000000] Initializing cgroup subsys cpu
[    0.000000] Linux version 3.6.0-rc3-wl-main (proski@mj) (gcc version 4.6.3 20120306 (Red Hat 4.6.3-2) (GCC) ) #98 SMP Tue Aug 28 11:03:00 EDT 2012
[    0.000000] Command line: BOOT_IMAGE=/boot/vmlinuz-3.6.0-rc3-wl-main root=UUID=69ea49b8-e1c0-494e-a5b2-3e0f4850decf ro
[    0.000000] e820: BIOS-provided physical RAM map:
[    0.000000] BIOS-e820: [mem 0x0000000000000000-0x000000000009fbff] usable
[    0.000000] BIOS-e820: [mem 0x000000000009fc00-0x000000000009ffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000000e0000-0x00000000000fffff] reserved
[    0.000000] BIOS-e820: [mem 0x0000000000100000-0x00000000cf69ffff] usable
[    0.000000] BIOS-e820: [mem 0x00000000cf6a0000-0x00000000cf6adfff] ACPI data
[    0.000000] BIOS-e820: [mem 0x00000000cf6ae000-0x00000000cf6effff] ACPI NVS
[    0.000000] BIOS-e820: [mem 0x00000000cf6f0000-0x00000000cf6fdfff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000fee00000-0x00000000fee00fff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000ffb80000-0x00000000ffffffff] reserved
[    0.000000] BIOS-e820: [mem 0x0000000100000000-0x000000012fffffff] usable
[    0.000000] NX (Execute Disable) protection: active
[    0.000000] DMI present.
[    0.000000] DMI: ECS G31T-M/G31T-M, BIOS 080014  01/07/2009
[    0.000000] e820: update [mem 0x00000000-0x0000ffff] usable ==> reserved
[    0.000000] e820: remove [mem 0x000a0000-0x000fffff] usable
[    0.000000] No AGP bridge found
[    0.000000] e820: last_pfn = 0x130000 max_arch_pfn = 0x400000000
[    0.000000] MTRR default type: uncachable
[    0.000000] MTRR fixed ranges enabled:
[    0.000000]   00000-9FFFF write-back
[    0.000000]   A0000-BFFFF uncachable
[    0.000000]   C0000-CBFFF write-protect
[    0.000000]   CC000-DFFFF uncachable
[    0.000000]   E0000-EFFFF write-through
[    0.000000]   F0000-FFFFF write-protect
[    0.000000] MTRR variable ranges enabled:
[    0.000000]   0 base 000000000 mask F00000000 write-back
[    0.000000]   1 base 100000000 mask FE0000000 write-back
[    0.000000]   2 base 120000000 mask FF0000000 write-back
[    0.000000]   3 base 0D0000000 mask FF0000000 uncachable
[    0.000000]   4 base 0E0000000 mask FE0000000 uncachable
[    0.000000]   5 base 0CF700000 mask FFFF00000 uncachable
[    0.000000]   6 base 0CF800000 mask FFF800000 uncachable
[    0.000000]   7 disabled
[    0.000000] x86 PAT enabled: cpu 0, old 0x7040600070406, new 0x7010600070106
[    0.000000] e820: update [mem 0xcf700000-0xffffffff] usable ==> reserved
[    0.000000] e820: last_pfn = 0xcf6a0 max_arch_pfn = 0x400000000
[    0.000000] initial memory mapped: [mem 0x00000000-0x1fffffff]
[    0.000000] Base memory trampoline at [ffff880000099000] 99000 size 24576
[    0.000000] init_memory_mapping: [mem 0x00000000-0xcf69ffff]
[    0.000000]  [mem 0x00000000-0xcf69ffff] page 4k
[    0.000000] kernel direct mapping tables up to 0xcf69ffff @ [mem 0x1f97f000-0x1fffffff]
[    0.000000] init_memory_mapping: [mem 0x100000000-0x12fffffff]
[    0.000000]  [mem 0x100000000-0x12fffffff] page 4k
[    0.000000] kernel direct mapping tables up to 0x12fffffff @ [mem 0xced1a000-0xcf69ffff]
[    0.000000] RAMDISK: [mem 0x375f2000-0x37af0fff]
[    0.000000] ACPI: RSDP 00000000000f9c40 00014 (v00 ACPIAM)
[    0.000000] ACPI: RSDT 00000000cf6a0000 00040 (v01 010709 RSDT1731 20090107 MSFT 00000097)
[    0.000000] ACPI: FACP 00000000cf6a0200 00084 (v01 010709 FACP1731 20090107 MSFT 00000097)
[    0.000000] ACPI: DSDT 00000000cf6a0440 05AF2 (v01  1AAAA 1AAAA000 00000000 INTL 20051117)
[    0.000000] ACPI: FACS 00000000cf6ae000 00040
[    0.000000] ACPI: APIC 00000000cf6a0390 0006C (v01 010709 APIC1731 20090107 MSFT 00000097)
[    0.000000] ACPI: MCFG 00000000cf6a0400 0003C (v01 010709 OEMMCFG  20090107 MSFT 00000097)
[    0.000000] ACPI: OEMB 00000000cf6ae040 00071 (v01 010709 OEMB1731 20090107 MSFT 00000097)
[    0.000000] ACPI: HPET 00000000cf6a5f40 00038 (v01 010709 OEMHPET  20090107 MSFT 00000097)
[    0.000000] ACPI: GSCI 00000000cf6ae0c0 02024 (v01 010709 GMCHSCI  20090107 MSFT 00000097)
[    0.000000] ACPI: SSDT 00000000cf6b1330 00A7C (v01 DpgPmm    CpuPm 00000012 INTL 20051117)
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000]  [ffffea0000000000-ffffea0004bfffff] PMD -> [ffff88012b600000-ffff88012f5fffff] on node 0
[    0.000000] Zone ranges:
[    0.000000]   DMA      [mem 0x00010000-0x00ffffff]
[    0.000000]   DMA32    [mem 0x01000000-0xffffffff]
[    0.000000]   Normal   [mem 0x100000000-0x12fffffff]
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x00010000-0x0009efff]
[    0.000000]   node   0: [mem 0x00100000-0xcf69ffff]
[    0.000000]   node   0: [mem 0x100000000-0x12fffffff]
[    0.000000] On node 0 totalpages: 1046063
[    0.000000]   DMA zone: 64 pages used for memmap
[    0.000000]   DMA zone: 6 pages reserved
[    0.000000]   DMA zone: 3913 pages, LIFO batch:0
[    0.000000]   DMA32 zone: 16320 pages used for memmap
[    0.000000]   DMA32 zone: 829152 pages, LIFO batch:31
[    0.000000]   Normal zone: 3072 pages used for memmap
[    0.000000]   Normal zone: 193536 pages, LIFO batch:31
[    0.000000] ACPI: PM-Timer IO Port: 0x808
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] ACPI: LAPIC (acpi_id[0x01] lapic_id[0x00] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x02] lapic_id[0x01] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x03] lapic_id[0x02] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x04] lapic_id[0x03] enabled)
[    0.000000] ACPI: IOAPIC (id[0x04] address[0xfec00000] gsi_base[0])
[    0.000000] IOAPIC[0]: apic_id 4, version 32, address 0xfec00000, GSI 0-23
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
[    0.000000] ACPI: IRQ0 used by override.
[    0.000000] ACPI: IRQ2 used by override.
[    0.000000] ACPI: IRQ9 used by override.
[    0.000000] Using ACPI (MADT) for SMP configuration information
[    0.000000] ACPI: HPET id: 0xffffffff base: 0xfed00000
[    0.000000] smpboot: Allowing 4 CPUs, 0 hotplug CPUs
[    0.000000] nr_irqs_gsi: 40
[    0.000000] e820: [mem 0xcf6fe000-0xfedfffff] available for PCI devices
[    0.000000] setup_percpu: NR_CPUS:4 nr_cpumask_bits:4 nr_cpu_ids:4 nr_node_ids:1
[    0.000000] PERCPU: Embedded 27 pages/cpu @ffff88012fc00000 s80512 r8192 d21888 u524288
[    0.000000] pcpu-alloc: s80512 r8192 d21888 u524288 alloc=1*2097152
[    0.000000] pcpu-alloc: [0] 0 1 2 3 
[    0.000000] Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 1026601
[    0.000000] Kernel command line: BOOT_IMAGE=/boot/vmlinuz-3.6.0-rc3-wl-main root=UUID=69ea49b8-e1c0-494e-a5b2-3e0f4850decf ro
[    0.000000] PID hash table entries: 4096 (order: 3, 32768 bytes)
[    0.000000] Dentry cache hash table entries: 524288 (order: 10, 4194304 bytes)
[    0.000000] Inode-cache hash table entries: 262144 (order: 9, 2097152 bytes)
[    0.000000] __ex_table already sorted, skipping sort
[    0.000000] Checking aperture...
[    0.000000] No AGP bridge found
[    0.000000] Memory: 4010132k/4980736k available (5978k kernel code, 796484k absent, 174120k reserved, 4864k data, 520k init)
[    0.000000] SLUB: Genslabs=15, HWalign=64, Order=0-3, MinObjects=0, CPUs=4, Nodes=1
[    0.000000] Hierarchical RCU implementation.
[    0.000000] 	RCU lockdep checking is enabled.
[    0.000000] NR_IRQS:4352 nr_irqs:712 16
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
[    0.000000] ------------------------
[    0.000000] | Locking API testsuite:
[    0.000000] ----------------------------------------------------------------------------
[    0.000000]                                  | spin |wlock |rlock |mutex | wsem | rsem |
[    0.000000]   --------------------------------------------------------------------------
[    0.000000]                      A-A deadlock:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
[    0.000000]                  A-B-B-A deadlock:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
[    0.000000]              A-B-B-C-C-A deadlock:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
[    0.000000]              A-B-C-A-B-C deadlock:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
[    0.000000]          A-B-B-C-C-D-D-A deadlock:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
[    0.000000]          A-B-C-D-B-D-D-A deadlock:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
[    0.000000]          A-B-C-D-B-C-D-A deadlock:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
[    0.000000]                     double unlock:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
[    0.000000]                   initialize held:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
[    0.000000]                  bad unlock order:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
[    0.000000]   --------------------------------------------------------------------------
[    0.000000]               recursive read-lock:             |  ok  |             |  ok  |
[    0.000000]            recursive read-lock #2:             |  ok  |             |  ok  |
[    0.000000]             mixed read-write-lock:             |  ok  |             |  ok  |
[    0.000000]             mixed write-read-lock:             |  ok  |             |  ok  |
[    0.000000]   --------------------------------------------------------------------------
[    0.000000]      hard-irqs-on + irq-safe-A/12:  ok  |  ok  |  ok  |
[    0.000000]      soft-irqs-on + irq-safe-A/12:  ok  |  ok  |  ok  |
[    0.000000]      hard-irqs-on + irq-safe-A/21:  ok  |  ok  |  ok  |
[    0.000000]      soft-irqs-on + irq-safe-A/21:  ok  |  ok  |  ok  |
[    0.000000]        sirq-safe-A => hirqs-on/12:  ok  |  ok  |  ok  |
[    0.000000]        sirq-safe-A => hirqs-on/21:  ok  |  ok  |  ok  |
[    0.000000]          hard-safe-A + irqs-on/12:  ok  |  ok  |  ok  |
[    0.000000]          soft-safe-A + irqs-on/12:  ok  |  ok  |  ok  |
[    0.000000]          hard-safe-A + irqs-on/21:  ok  |  ok  |  ok  |
[    0.000000]          soft-safe-A + irqs-on/21:  ok  |  ok  |  ok  |
[    0.000000]     hard-safe-A + unsafe-B #1/123:  ok  |  ok  |  ok  |
[    0.000000]     soft-safe-A + unsafe-B #1/123:  ok  |  ok  |  ok  |
[    0.000000]     hard-safe-A + unsafe-B #1/132:  ok  |  ok  |  ok  |
[    0.000000]     soft-safe-A + unsafe-B #1/132:  ok  |  ok  |  ok  |
[    0.000000]     hard-safe-A + unsafe-B #1/213:  ok  |  ok  |  ok  |
[    0.000000]     soft-safe-A + unsafe-B #1/213:  ok  |  ok  |  ok  |
[    0.000000]     hard-safe-A + unsafe-B #1/231:  ok  |  ok  |  ok  |
[    0.000000]     soft-safe-A + unsafe-B #1/231:  ok  |  ok  |  ok  |
[    0.000000]     hard-safe-A + unsafe-B #1/312:  ok  |  ok  |  ok  |
[    0.000000]     soft-safe-A + unsafe-B #1/312:  ok  |  ok  |  ok  |
[    0.000000]     hard-safe-A + unsafe-B #1/321:  ok  |  ok  |  ok  |
[    0.000000]     soft-safe-A + unsafe-B #1/321:  ok  |  ok  |  ok  |
[    0.000000]     hard-safe-A + unsafe-B #2/123:  ok  |  ok  |  ok  |
[    0.000000]     soft-safe-A + unsafe-B #2/123:  ok  |  ok  |  ok  |
[    0.000000]     hard-safe-A + unsafe-B #2/132:  ok  |  ok  |  ok  |
[    0.000000]     soft-safe-A + unsafe-B #2/132:  ok  |  ok  |  ok  |
[    0.000000]     hard-safe-A + unsafe-B #2/213:  ok  |  ok  |  ok  |
[    0.000000]     soft-safe-A + unsafe-B #2/213:  ok  |  ok  |  ok  |
[    0.000000]     hard-safe-A + unsafe-B #2/231:  ok  |  ok  |  ok  |
[    0.000000]     soft-safe-A + unsafe-B #2/231:  ok  |  ok  |  ok  |
[    0.000000]     hard-safe-A + unsafe-B #2/312:  ok  |  ok  |  ok  |
[    0.000000]     soft-safe-A + unsafe-B #2/312:  ok  |  ok  |  ok  |
[    0.000000]     hard-safe-A + unsafe-B #2/321:  ok  |  ok  |  ok  |
[    0.000000]     soft-safe-A + unsafe-B #2/321:  ok  |  ok  |  ok  |
[    0.000000]       hard-irq lock-inversion/123:  ok  |  ok  |  ok  |
[    0.000000]       soft-irq lock-inversion/123:  ok  |  ok  |  ok  |
[    0.000000]       hard-irq lock-inversion/132:  ok  |  ok  |  ok  |
[    0.000000]       soft-irq lock-inversion/132:  ok  |  ok  |  ok  |
[    0.000000]       hard-irq lock-inversion/213:  ok  |  ok  |  ok  |
[    0.000000]       soft-irq lock-inversion/213:  ok  |  ok  |  ok  |
[    0.000000]       hard-irq lock-inversion/231:  ok  |  ok  |  ok  |
[    0.000000]       soft-irq lock-inversion/231:  ok  |  ok  |  ok  |
[    0.000000]       hard-irq lock-inversion/312:  ok  |  ok  |  ok  |
[    0.000000]       soft-irq lock-inversion/312:  ok  |  ok  |  ok  |
[    0.000000]       hard-irq lock-inversion/321:  ok  |  ok  |  ok  |
[    0.000000]       soft-irq lock-inversion/321:  ok  |  ok  |  ok  |
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
[    0.000000] -------------------------------------------------------
[    0.000000] Good, all 218 testcases passed! |
[    0.000000] ---------------------------------
[    0.000000] ODEBUG: 17 of 17 active objects replaced
[    0.000000] ODEBUG: selftest passed
[    0.000000] hpet clockevent registered
[    0.000000] tsc: Fast TSC calibration using PIT
[    0.000000] tsc: Detected 2394.053 MHz processor
[    0.001003] Calibrating delay loop (skipped), value calculated using timer frequency.. 4788.10 BogoMIPS (lpj=2394053)
[    0.001127] pid_max: default: 32768 minimum: 301
[    0.002087] Mount-cache hash table entries: 256
[    0.004071] Initializing cgroup subsys cpuacct
[    0.004134] Initializing cgroup subsys freezer
[    0.004434] CPU: Physical Processor ID: 0
[    0.004493] CPU: Processor Core ID: 0
[    0.004552] mce: CPU supports 6 MCE banks
[    0.004619] CPU0: Thermal monitoring enabled (TM2)
[    0.004685] process: using mwait in idle threads
[    0.004748] Last level iTLB entries: 4KB 128, 2MB 4, 4MB 4
[    0.004748] Last level dTLB entries: 4KB 256, 2MB 0, 4MB 32
[    0.004748] tlb_flushall_shift is 0xffffffff
[    0.004947] ACPI: Core revision 20120711
[    0.087586] ..TIMER: vector=0x30 apic1=0 pin1=2 apic2=-1 pin2=-1
[    0.097658] smpboot: CPU0: Intel(R) Core(TM)2 Quad CPU    Q6600  @ 2.40GHz stepping 0b
[    0.097985] Performance Events: PEBS fmt0+, 4-deep LBR, Core2 events, Intel PMU driver.
[    0.097985] perf_event_intel: PEBS disabled due to CPU errata
[    0.097985] ... version:                2
[    0.097985] ... bit width:              40
[    0.097985] ... generic registers:      2
[    0.097985] ... value mask:             000000ffffffffff
[    0.097985] ... max period:             000000007fffffff
[    0.097985] ... fixed-purpose events:   3
[    0.097985] ... event mask:             0000000700000003
[    0.098884] NMI watchdog: enabled on all CPUs, permanently consumes one hw-PMU counter.
[    0.099919] SMP alternatives: lockdep: fixing up alternatives
[    0.099995] smpboot: Booting Node   0, Processors  #1
[    0.113113] SMP alternatives: lockdep: fixing up alternatives
[    0.113234]  #2
[    0.126091] SMP alternatives: lockdep: fixing up alternatives
[    0.126207]  #3 OK
[    0.138152] Brought up 4 CPUs
[    0.138225] ----------------
[    0.138281] | NMI testsuite:
[    0.138337] --------------------
[    0.138394]   remote IPI:  ok  |
[    0.141112]    local IPI:  ok  |
[    0.146989] --------------------
[    0.147052] Good, all   2 testcases passed! |
[    0.147116] ---------------------------------
[    0.147185] smpboot: Total of 4 processors activated (19152.42 BogoMIPS)
[    0.149984] devtmpfs: initialized
[    0.152576] PM: Registering ACPI NVS region [mem 0xcf6ae000-0xcf6effff] (270336 bytes)
[    0.153834] NET: Registered protocol family 16
[    0.154252] kworker/u:0 (30) used greatest stack depth: 4952 bytes left
[    0.157206] ACPI: bus type pci registered
[    0.158441] PCI: Using configuration type 1 for base access
[    0.226223] bio: create slab <bio-0> at 0
[    0.227207] ACPI: Added _OSI(Module Device)
[    0.227207] ACPI: Added _OSI(Processor Device)
[    0.227207] ACPI: Added _OSI(3.0 _SCP Extensions)
[    0.227266] ACPI: Added _OSI(Processor Aggregator Device)
[    0.232975] ACPI: EC: Look up EC in DSDT
[    0.285705] ACPI: Executed 1 blocks of module-level executable AML code
[    0.383709] ACPI: SSDT 00000000cf6b00f0 00277 (v01 DpgPmm  P001Ist 00000011 INTL 20051117)
[    0.386160] ACPI: Dynamic OEM Table Load:
[    0.386259] ACPI: SSDT           (null) 00277 (v01 DpgPmm  P001Ist 00000011 INTL 20051117)
[    0.398063] ACPI: SSDT 00000000cf6b0580 00277 (v01 DpgPmm  P002Ist 00000012 INTL 20051117)
[    0.400484] ACPI: Dynamic OEM Table Load:
[    0.400582] ACPI: SSDT           (null) 00277 (v01 DpgPmm  P002Ist 00000012 INTL 20051117)
[    0.412351] ACPI: SSDT 00000000cf6b0a10 00277 (v01 DpgPmm  P003Ist 00000012 INTL 20051117)
[    0.414777] ACPI: Dynamic OEM Table Load:
[    0.414875] ACPI: SSDT           (null) 00277 (v01 DpgPmm  P003Ist 00000012 INTL 20051117)
[    0.426636] ACPI: SSDT 00000000cf6b0ea0 00277 (v01 DpgPmm  P004Ist 00000012 INTL 20051117)
[    0.429107] ACPI: Dynamic OEM Table Load:
[    0.429205] ACPI: SSDT           (null) 00277 (v01 DpgPmm  P004Ist 00000012 INTL 20051117)
[    0.473376] ACPI: Interpreter enabled
[    0.473436] ACPI: (supports S0 S3 S5)
[    0.473857] ACPI: Using IOAPIC for interrupt routing
[    0.733943] ACPI: No dock devices found.
[    0.734009] PCI: Using host bridge windows from ACPI; if necessary, use "pci=nocrs" and report a bug
[    0.741143] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-ff])
[    0.746893] PCI host bridge to bus 0000:00
[    0.746971] pci_bus 0000:00: busn_res: [bus 00-ff] is inserted under domain [bus 00-ff]
[    0.746974] pci_bus 0000:00: root bus resource [bus 00-ff]
[    0.747052] pci_bus 0000:00: root bus resource [io  0x0000-0x0cf7]
[    0.747124] pci_bus 0000:00: root bus resource [io  0x0d00-0xffff]
[    0.747195] pci_bus 0000:00: root bus resource [mem 0x000a0000-0x000bffff]
[    0.747269] pci_bus 0000:00: root bus resource [mem 0x000d0000-0x000dffff]
[    0.747347] pci_bus 0000:00: root bus resource [mem 0xcf700000-0xdfffffff]
[    0.747435] pci_bus 0000:00: root bus resource [mem 0xf0000000-0xffffffff]
[    0.747560] pci 0000:00:00.0: [8086:29c0] type 00 class 0x060000
[    0.747683] pci 0000:00:02.0: [8086:29c2] type 00 class 0x030000
[    0.747701] pci 0000:00:02.0: reg 10: [mem 0xfe180000-0xfe1fffff]
[    0.747711] pci 0000:00:02.0: reg 14: [io  0xcc00-0xcc07]
[    0.747720] pci 0000:00:02.0: reg 18: [mem 0xd0000000-0xdfffffff pref]
[    0.747730] pci 0000:00:02.0: reg 1c: [mem 0xfe000000-0xfe0fffff]
[    0.747822] pci 0000:00:02.1: [8086:29c3] type 00 class 0x038000
[    0.747836] pci 0000:00:02.1: reg 10: [mem 0xfdf80000-0xfdffffff]
[    0.748025] pci 0000:00:1b.0: [8086:27d8] type 00 class 0x040300
[    0.748045] pci 0000:00:1b.0: reg 10: [mem 0xfe178000-0xfe17bfff 64bit]
[    0.748160] pci 0000:00:1b.0: PME# supported from D0 D3hot D3cold
[    0.748232] pci 0000:00:1c.0: [8086:27d0] type 01 class 0x060400
[    0.748348] pci 0000:00:1c.0: PME# supported from D0 D3hot D3cold
[    0.748423] pci 0000:00:1d.0: [8086:27c8] type 00 class 0x0c0300
[    0.748479] pci 0000:00:1d.0: reg 20: [io  0xc880-0xc89f]
[    0.748543] pci 0000:00:1d.1: [8086:27c9] type 00 class 0x0c0300
[    0.748599] pci 0000:00:1d.1: reg 20: [io  0xc800-0xc81f]
[    0.748663] pci 0000:00:1d.2: [8086:27ca] type 00 class 0x0c0300
[    0.748719] pci 0000:00:1d.2: reg 20: [io  0xc480-0xc49f]
[    0.748782] pci 0000:00:1d.3: [8086:27cb] type 00 class 0x0c0300
[    0.748839] pci 0000:00:1d.3: reg 20: [io  0xc400-0xc41f]
[    0.748924] pci 0000:00:1d.7: [8086:27cc] type 00 class 0x0c0320
[    0.748949] pci 0000:00:1d.7: reg 10: [mem 0xfe177c00-0xfe177fff]
[    0.749070] pci 0000:00:1d.7: PME# supported from D0 D3hot D3cold
[    0.749123] pci 0000:00:1e.0: [8086:244e] type 01 class 0x060401
[    0.749234] pci 0000:00:1f.0: [8086:27b8] type 00 class 0x060100
[    0.749348] pci 0000:00:1f.0: ICH7 LPC Generic IO decode 1 PIO at 0a00 (mask 00ff)
[    0.749538] pci 0000:00:1f.1: [8086:27df] type 00 class 0x01018a
[    0.749555] pci 0000:00:1f.1: reg 10: [io  0x0000-0x0007]
[    0.749568] pci 0000:00:1f.1: reg 14: [io  0x0000-0x0003]
[    0.749581] pci 0000:00:1f.1: reg 18: [io  0x08f0-0x08f7]
[    0.749593] pci 0000:00:1f.1: reg 1c: [io  0x08f8-0x08fb]
[    0.749606] pci 0000:00:1f.1: reg 20: [io  0xffa0-0xffaf]
[    0.749675] pci 0000:00:1f.2: [8086:27c0] type 00 class 0x01018f
[    0.749694] pci 0000:00:1f.2: reg 10: [io  0xc080-0xc087]
[    0.749706] pci 0000:00:1f.2: reg 14: [io  0xc000-0xc003]
[    0.749718] pci 0000:00:1f.2: reg 18: [io  0xbc00-0xbc07]
[    0.749729] pci 0000:00:1f.2: reg 1c: [io  0xb880-0xb883]
[    0.749741] pci 0000:00:1f.2: reg 20: [io  0xb800-0xb80f]
[    0.749807] pci 0000:00:1f.2: PME# supported from D3hot
[    0.749842] pci 0000:00:1f.3: [8086:27da] type 00 class 0x0c0500
[    0.749918] pci 0000:00:1f.3: reg 20: [io  0x0400-0x041f]
[    0.750059] pci_bus 0000:01: busn_res: [bus 01] is inserted under [bus 00-ff]
[    0.750108] pci 0000:01:00.0: [10ec:8136] type 00 class 0x020000
[    0.750128] pci 0000:01:00.0: reg 10: [io  0xd800-0xd8ff]
[    0.750168] pci 0000:01:00.0: reg 18: [mem 0xfe2ff000-0xfe2fffff 64bit]
[    0.750215] pci 0000:01:00.0: reg 30: [mem 0xfe2c0000-0xfe2dffff pref]
[    0.750345] pci 0000:01:00.0: supports D1 D2
[    0.750347] pci 0000:01:00.0: PME# supported from D1 D2 D3hot D3cold
[    0.750376] pci 0000:01:00.0: disabling ASPM on pre-1.1 PCIe device.  You can enable it with 'pcie_aspm=force'
[    0.750575] pci 0000:00:1c.0: PCI bridge to [bus 01]
[    0.750640] pci 0000:00:1c.0:   bridge window [io  0xd000-0xdfff]
[    0.750646] pci 0000:00:1c.0:   bridge window [mem 0xfe200000-0xfe2fffff]
[    0.750698] pci_bus 0000:02: busn_res: [bus 02-04] is inserted under [bus 00-ff]
[    0.750737] pci 0000:02:01.0: [3388:0021] type 01 class 0x060400
[    0.750878] pci 0000:02:01.0: supports D1 D2
[    0.750880] pci 0000:02:01.0: PME# supported from D0 D1 D2 D3hot
[    0.750957] pci 0000:02:02.0: [1180:0475] type 02 class 0x060700
[    0.750979] pci 0000:02:02.0: reg 10: [mem 0x00000000-0x00000fff]
[    0.751044] pci 0000:02:02.0: supports D1 D2
[    0.751047] pci 0000:02:02.0: PME# supported from D0 D1 D2 D3hot D3cold
[    0.751122] pci 0000:00:1e.0: PCI bridge to [bus 02-04] (subtractive decode)
[    0.751193] pci 0000:00:1e.0:   bridge window [io  0xe000-0xefff]
[    0.751198] pci 0000:00:1e.0:   bridge window [mem 0xfe300000-0xfebfffff]
[    0.751206] pci 0000:00:1e.0:   bridge window [mem 0xfb000000-0xfcffffff 64bit pref]
[    0.751216] pci 0000:00:1e.0:   bridge window [io  0x0000-0x0cf7] (subtractive decode)
[    0.751225] pci 0000:00:1e.0:   bridge window [io  0x0d00-0xffff] (subtractive decode)
[    0.751234] pci 0000:00:1e.0:   bridge window [mem 0x000a0000-0x000bffff] (subtractive decode)
[    0.751243] pci 0000:00:1e.0:   bridge window [mem 0x000d0000-0x000dffff] (subtractive decode)
[    0.751252] pci 0000:00:1e.0:   bridge window [mem 0xcf700000-0xdfffffff] (subtractive decode)
[    0.751260] pci 0000:00:1e.0:   bridge window [mem 0xf0000000-0xffffffff] (subtractive decode)
[    0.751337] pci_bus 0000:03: busn_res: [bus 03] is inserted under [bus 02-04]
[    0.751392] pci 0000:03:08.0: [168c:0013] type 00 class 0x028000
[    0.751425] pci 0000:03:08.0: reg 10: [mem 0xfe3f0000-0xfe3fffff]
[    0.751613] pci 0000:03:09.0: [168c:0013] type 00 class 0x028000
[    0.751640] pci 0000:03:09.0: reg 10: [mem 0xfe3e0000-0xfe3effff]
[    0.751823] pci 0000:03:0b.0: [168c:0013] type 00 class 0x028000
[    0.751851] pci 0000:03:0b.0: reg 10: [mem 0xfe3d0000-0xfe3dffff]
[    0.752061] pci 0000:02:01.0: PCI bridge to [bus 03]
[    0.752134] pci 0000:02:01.0:   bridge window [mem 0xfe300000-0xfe3fffff]
[    0.752221] pci_bus 0000:04: busn_res: can not insert [bus 04-ff] under [bus 02-04] (conflicts with (null) [bus 02-04])
[    0.752229] pci_bus 0000:04: busn_res: [bus 04-ff] end is updated to 07
[    0.752233] pci_bus 0000:04: busn_res: can not insert [bus 04-07] under [bus 02-04] (conflicts with (null) [bus 02-04])
[    0.752238] pci_bus 0000:04: [bus 04-07] partially hidden behind transparent bridge 0000:02 [bus 02-04]
[    0.752355] pci_bus 0000:00: on NUMA node 0
[    0.752378] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0._PRT]
[    0.758096] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.P0P1._PRT]
[    0.761446] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.P0P4._PRT]
[    0.767933]  pci0000:00: Unable to request _OSC control (_OSC support mask: 0x1e)
[    1.035444] ACPI: PCI Interrupt Link [LNKA] (IRQs 3 4 5 6 7 *10 11 12 14 15)
[    1.036912] ACPI: PCI Interrupt Link [LNKB] (IRQs 3 4 5 6 7 10 11 12 14 15) *0, disabled.
[    1.038457] ACPI: PCI Interrupt Link [LNKC] (IRQs *3 4 5 6 7 10 11 12 14 15)
[    1.039906] ACPI: PCI Interrupt Link [LNKD] (IRQs 3 4 5 6 7 10 *11 12 14 15)
[    1.041366] ACPI: PCI Interrupt Link [LNKE] (IRQs 3 4 5 6 7 10 11 12 14 15) *0, disabled.
[    1.042879] ACPI: PCI Interrupt Link [LNKF] (IRQs 3 4 5 6 *7 10 11 12 14 15)
[    1.044320] ACPI: PCI Interrupt Link [LNKG] (IRQs 3 4 5 6 7 10 11 12 14 15) *0, disabled.
[    1.045815] ACPI: PCI Interrupt Link [LNKH] (IRQs 3 4 *5 6 7 10 11 12 14 15)
[    1.047946] vgaarb: device added: PCI:0000:00:02.0,decodes=io+mem,owns=io+mem,locks=none
[    1.048229] vgaarb: loaded
[    1.048285] vgaarb: bridge control possible 0000:00:02.0
[    1.049990] SCSI subsystem initialized
[    1.049990] ACPI: bus type scsi registered
[    1.051034] libata version 3.00 loaded.
[    1.052001] kworker/u:0 (353) used greatest stack depth: 4520 bytes left
[    1.052001] ACPI: bus type usb registered
[    1.053229] usbcore: registered new interface driver usbfs
[    1.053911] usbcore: registered new interface driver hub
[    1.053951] usbcore: registered new device driver usb
[    1.055227] Linux video capture interface: v2.00
[    1.057053] Advanced Linux Sound Architecture Driver Version 1.0.25.
[    1.057119] PCI: Using ACPI for IRQ routing
[    1.057186] PCI: pci_cache_line_size set to 64 bytes
[    1.057697] e820: reserve RAM buffer [mem 0x0009fc00-0x0009ffff]
[    1.057722] e820: reserve RAM buffer [mem 0xcf6a0000-0xcfffffff]
[    1.060917] HPET: 3 timers in total, 0 timers will be used for per-cpu timer
[    1.060990] hpet0: at MMIO 0xfed00000, IRQs 2, 8, 0
[    1.061134] hpet0: 3 comparators, 64-bit 14.318180 MHz counter
[    1.066078] Switching to clocksource hpet
[    1.111609] pnp: PnP ACPI init
[    1.111795] ACPI: bus type pnp registered
[    1.114267] pnp 00:00: [bus 00-ff]
[    1.114276] pnp 00:00: [io  0x0cf8-0x0cff]
[    1.114292] pnp 00:00: [io  0x0000-0x0cf7 window]
[    1.114301] pnp 00:00: [io  0x0d00-0xffff window]
[    1.114309] pnp 00:00: [mem 0x000a0000-0x000bffff window]
[    1.114318] pnp 00:00: [mem 0x000d0000-0x000dffff window]
[    1.114326] pnp 00:00: [mem 0xcf700000-0xdfffffff window]
[    1.114334] pnp 00:00: [mem 0xf0000000-0xffffffff window]
[    1.114874] pnp 00:00: Plug and Play ACPI device, IDs PNP0a08 PNP0a03 (active)
[    1.115030] pnp 00:01: [mem 0xfed14000-0xfed19fff]
[    1.115849] system 00:01: [mem 0xfed14000-0xfed19fff] has been reserved
[    1.115925] system 00:01: Plug and Play ACPI device, IDs PNP0c01 (active)
[    1.116517] pnp 00:02: [dma 4]
[    1.116525] pnp 00:02: [io  0x0000-0x000f]
[    1.116533] pnp 00:02: [io  0x0081-0x0083]
[    1.116541] pnp 00:02: [io  0x0087]
[    1.116548] pnp 00:02: [io  0x0089-0x008b]
[    1.116556] pnp 00:02: [io  0x008f]
[    1.116563] pnp 00:02: [io  0x00c0-0x00df]
[    1.117040] pnp 00:02: Plug and Play ACPI device, IDs PNP0200 (active)
[    1.117212] pnp 00:03: [io  0x0070-0x0071]
[    1.117234] pnp 00:03: [irq 8]
[    1.117702] pnp 00:03: Plug and Play ACPI device, IDs PNP0b00 (active)
[    1.117845] pnp 00:04: [io  0x0061]
[    1.118322] pnp 00:04: Plug and Play ACPI device, IDs PNP0800 (active)
[    1.118478] pnp 00:05: [io  0x00f0-0x00ff]
[    1.118494] pnp 00:05: [irq 13]
[    1.118962] pnp 00:05: Plug and Play ACPI device, IDs PNP0c04 (active)
[    1.147602] pnp 00:06: [io  0x03f8-0x03ff]
[    1.147619] pnp 00:06: [irq 4]
[    1.147628] pnp 00:06: [dma 0 disabled]
[    1.148533] pnp 00:06: Plug and Play ACPI device, IDs PNP0501 (active)
[    1.207500] pnp 00:07: [io  0x0000-0xffffffffffffffff disabled]
[    1.207509] pnp 00:07: [io  0x0a00-0x0a0f]
[    1.207517] pnp 00:07: [io  0x0a10-0x0a1f]
[    1.207524] pnp 00:07: [io  0x0a20-0x0a2f]
[    1.207532] pnp 00:07: [io  0x0a30-0x0a3f]
[    1.208346] system 00:07: [io  0x0a00-0x0a0f] has been reserved
[    1.208428] system 00:07: [io  0x0a10-0x0a1f] has been reserved
[    1.208508] system 00:07: [io  0x0a20-0x0a2f] has been reserved
[    1.208587] system 00:07: [io  0x0a30-0x0a3f] has been reserved
[    1.208657] system 00:07: Plug and Play ACPI device, IDs PNP0c02 (active)
[    1.210958] pnp 00:08: [io  0x0010-0x001f]
[    1.210967] pnp 00:08: [io  0x0022-0x003f]
[    1.210974] pnp 00:08: [io  0x0044-0x005f]
[    1.210990] pnp 00:08: [io  0x0062-0x0063]
[    1.210998] pnp 00:08: [io  0x0065-0x006f]
[    1.211024] pnp 00:08: [io  0x0072-0x007f]
[    1.211033] pnp 00:08: [io  0x0080]
[    1.211041] pnp 00:08: [io  0x0084-0x0086]
[    1.211048] pnp 00:08: [io  0x0088]
[    1.211056] pnp 00:08: [io  0x008c-0x008e]
[    1.211064] pnp 00:08: [io  0x0090-0x009f]
[    1.211071] pnp 00:08: [io  0x00a2-0x00bf]
[    1.211079] pnp 00:08: [io  0x00e0-0x00ef]
[    1.211087] pnp 00:08: [io  0x04d0-0x04d1]
[    1.211094] pnp 00:08: [io  0x0800-0x087f]
[    1.211102] pnp 00:08: [io  0x0000-0xffffffffffffffff disabled]
[    1.211109] pnp 00:08: [io  0x0480-0x04bf]
[    1.211117] pnp 00:08: [mem 0xfed1c000-0xfed1ffff]
[    1.211125] pnp 00:08: [mem 0xfed20000-0xfed8ffff]
[    1.211939] system 00:08: [io  0x04d0-0x04d1] has been reserved
[    1.212033] system 00:08: [io  0x0800-0x087f] has been reserved
[    1.212116] system 00:08: [io  0x0480-0x04bf] has been reserved
[    1.212196] system 00:08: [mem 0xfed1c000-0xfed1ffff] has been reserved
[    1.212286] system 00:08: [mem 0xfed20000-0xfed8ffff] has been reserved
[    1.212358] system 00:08: Plug and Play ACPI device, IDs PNP0c02 (active)
[    1.213975] pnp 00:09: [mem 0xfed00000-0xfed003ff]
[    1.214475] pnp 00:09: Plug and Play ACPI device, IDs PNP0103 (active)
[    1.216723] pnp 00:0a: [mem 0xffb80000-0xffbfffff]
[    1.216731] pnp 00:0a: [mem 0xfff80000-0xffffffff]
[    1.217247] pnp 00:0a: Plug and Play ACPI device, IDs INT0800 (active)
[    1.218475] pnp 00:0b: [mem 0xffc00000-0xfff7ffff]
[    1.219294] system 00:0b: [mem 0xffc00000-0xfff7ffff] has been reserved
[    1.219367] system 00:0b: Plug and Play ACPI device, IDs PNP0c02 (active)
[    1.222330] pnp 00:0c: [io  0x0060]
[    1.222339] pnp 00:0c: [io  0x0064]
[    1.222347] pnp 00:0c: [mem 0xfec00000-0xfec00fff]
[    1.222355] pnp 00:0c: [mem 0xfee00000-0xfee00fff]
[    1.223190] system 00:0c: [mem 0xfec00000-0xfec00fff] could not be reserved
[    1.223274] system 00:0c: [mem 0xfee00000-0xfee00fff] has been reserved
[    1.223345] system 00:0c: Plug and Play ACPI device, IDs PNP0c02 (active)
[    1.224518] pnp 00:0d: [mem 0xe0000000-0xefffffff]
[    1.225351] system 00:0d: [mem 0xe0000000-0xefffffff] has been reserved
[    1.225424] system 00:0d: Plug and Play ACPI device, IDs PNP0c02 (active)
[    1.230467] pnp 00:0e: [mem 0x00000000-0x0009ffff]
[    1.230476] pnp 00:0e: [mem 0x000c0000-0x000cffff]
[    1.230484] pnp 00:0e: [mem 0x000e0000-0x000fffff]
[    1.230492] pnp 00:0e: [mem 0x00100000-0xcf6fffff]
[    1.230500] pnp 00:0e: [mem 0x00000000-0xffffffffffffffff disabled]
[    1.231386] system 00:0e: [mem 0x00000000-0x0009ffff] could not be reserved
[    1.231484] system 00:0e: [mem 0x000c0000-0x000cffff] could not be reserved
[    1.231582] system 00:0e: [mem 0x000e0000-0x000fffff] could not be reserved
[    1.231678] system 00:0e: [mem 0x00100000-0xcf6fffff] could not be reserved
[    1.231752] system 00:0e: Plug and Play ACPI device, IDs PNP0c01 (active)
[    1.235305] pnp: PnP ACPI: found 15 devices
[    1.235366] ACPI: ACPI bus type pnp unregistered
[    1.286121] pci 0000:00:1c.0: bridge window [mem 0x00100000-0x000fffff 64bit pref] to [bus 01] add_size 200000
[    1.286187] pci 0000:00:1c.0: res[15]=[mem 0x00100000-0x000fffff 64bit pref] get_res_add_size add_size 200000
[    1.286193] pci 0000:00:1c.0: BAR 15: assigned [mem 0xcf700000-0xcf8fffff 64bit pref]
[    1.286311] pci 0000:00:1c.0: PCI bridge to [bus 01]
[    1.286375] pci 0000:00:1c.0:   bridge window [io  0xd000-0xdfff]
[    1.286445] pci 0000:00:1c.0:   bridge window [mem 0xfe200000-0xfe2fffff]
[    1.286514] pci 0000:00:1c.0:   bridge window [mem 0xcf700000-0xcf8fffff 64bit pref]
[    1.286667] pci 0000:02:02.0: res[15]=[mem 0x04000000-0x03ffffff pref] get_res_add_size add_size 4000000
[    1.286670] pci 0000:02:02.0: res[16]=[mem 0x04000000-0x03ffffff] get_res_add_size add_size 4000000
[    1.286673] pci 0000:02:02.0: res[13]=[io  0x0100-0x00ff] get_res_add_size add_size 100
[    1.286675] pci 0000:02:02.0: res[14]=[io  0x0100-0x00ff] get_res_add_size add_size 100
[    1.286681] pci 0000:02:02.0: BAR 0: assigned [mem 0xf0000000-0xf0000fff]
[    1.286754] pci 0000:02:02.0: BAR 15: assigned [mem 0xf4000000-0xf7ffffff pref]
[    1.286856] pci 0000:02:02.0: BAR 16: can't assign mem (size 0x4000000)
[    1.286939] pci 0000:02:02.0: BAR 13: assigned [io  0xe000-0xe0ff]
[    1.287024] pci 0000:02:02.0: BAR 14: assigned [io  0xe400-0xe4ff]
[    1.287124] pci 0000:02:02.0: BAR 0: assigned [mem 0xf0000000-0xf0000fff]
[    1.287196] pci 0000:02:02.0: BAR 16: assigned [mem 0xf4000000-0xf7ffffff]
[    1.287808] pci 0000:02:02.0: BAR 15: can't assign mem pref (size 0x4000000)
[    1.287882] pci 0000:02:02.0: BAR 14: assigned [io  0xe000-0xe0ff]
[    1.287952] pci 0000:02:02.0: BAR 13: assigned [io  0xe400-0xe4ff]
[    1.288064] pci 0000:02:01.0: PCI bridge to [bus 03]
[    1.288133] pci 0000:02:01.0:   bridge window [mem 0xfe300000-0xfe3fffff]
[    1.288211] pci 0000:02:02.0: CardBus bridge to [bus 04-07]
[    1.288276] pci 0000:02:02.0:   bridge window [io  0xe400-0xe4ff]
[    1.288345] pci 0000:02:02.0:   bridge window [io  0xe000-0xe0ff]
[    1.288414] pci 0000:02:02.0:   bridge window [mem 0xf4000000-0xf7ffffff]
[    1.288492] pci 0000:00:1e.0: PCI bridge to [bus 02-04]
[    1.288555] pci 0000:00:1e.0:   bridge window [io  0xe000-0xefff]
[    1.288624] pci 0000:00:1e.0:   bridge window [mem 0xfe300000-0xfebfffff]
[    1.288693] pci 0000:00:1e.0:   bridge window [mem 0xfb000000-0xfcffffff 64bit pref]
[    1.288849] pci 0000:00:1e.0: setting latency timer to 64
[    1.288894] pci_bus 0000:00: resource 4 [io  0x0000-0x0cf7]
[    1.288896] pci_bus 0000:00: resource 5 [io  0x0d00-0xffff]
[    1.288899] pci_bus 0000:00: resource 6 [mem 0x000a0000-0x000bffff]
[    1.288901] pci_bus 0000:00: resource 7 [mem 0x000d0000-0x000dffff]
[    1.288903] pci_bus 0000:00: resource 8 [mem 0xcf700000-0xdfffffff]
[    1.288906] pci_bus 0000:00: resource 9 [mem 0xf0000000-0xffffffff]
[    1.288909] pci_bus 0000:01: resource 0 [io  0xd000-0xdfff]
[    1.288911] pci_bus 0000:01: resource 1 [mem 0xfe200000-0xfe2fffff]
[    1.288913] pci_bus 0000:01: resource 2 [mem 0xcf700000-0xcf8fffff 64bit pref]
[    1.288916] pci_bus 0000:02: resource 0 [io  0xe000-0xefff]
[    1.288918] pci_bus 0000:02: resource 1 [mem 0xfe300000-0xfebfffff]
[    1.288921] pci_bus 0000:02: resource 2 [mem 0xfb000000-0xfcffffff 64bit pref]
[    1.288923] pci_bus 0000:02: resource 4 [io  0x0000-0x0cf7]
[    1.288925] pci_bus 0000:02: resource 5 [io  0x0d00-0xffff]
[    1.288928] pci_bus 0000:02: resource 6 [mem 0x000a0000-0x000bffff]
[    1.288930] pci_bus 0000:02: resource 7 [mem 0x000d0000-0x000dffff]
[    1.288933] pci_bus 0000:02: resource 8 [mem 0xcf700000-0xdfffffff]
[    1.288935] pci_bus 0000:02: resource 9 [mem 0xf0000000-0xffffffff]
[    1.288938] pci_bus 0000:03: resource 1 [mem 0xfe300000-0xfe3fffff]
[    1.288940] pci_bus 0000:04: resource 0 [io  0xe400-0xe4ff]
[    1.288943] pci_bus 0000:04: resource 1 [io  0xe000-0xe0ff]
[    1.288945] pci_bus 0000:04: resource 3 [mem 0xf4000000-0xf7ffffff]
[    1.289190] NET: Registered protocol family 2
[    1.290277] TCP established hash table entries: 262144 (order: 10, 4194304 bytes)
[    1.291780] TCP bind hash table entries: 65536 (order: 10, 4194304 bytes)
[    1.297765] TCP: Hash tables configured (established 262144 bind 65536)
[    1.297949] TCP: reno registered
[    1.298116] UDP hash table entries: 2048 (order: 6, 327680 bytes)
[    1.298629] UDP-Lite hash table entries: 2048 (order: 6, 327680 bytes)
[    1.299585] NET: Registered protocol family 1
[    1.299726] pci 0000:00:02.0: Boot video device
[    1.299827] pci 0000:00:1d.0: uhci_check_and_reset_hc: legsup = 0x0f30
[    1.299829] pci 0000:00:1d.0: Performing full reset
[    1.299866] pci 0000:00:1d.1: uhci_check_and_reset_hc: legsup = 0x0030
[    1.299868] pci 0000:00:1d.1: Performing full reset
[    1.299928] pci 0000:00:1d.2: uhci_check_and_reset_hc: legsup = 0x0030
[    1.299930] pci 0000:00:1d.2: Performing full reset
[    1.299965] pci 0000:00:1d.3: uhci_check_and_reset_hc: legsup = 0x0030
[    1.299967] pci 0000:00:1d.3: Performing full reset
[    1.300254] PCI: CLS 32 bytes, default 64
[    1.300771] Unpacking initramfs...
[    1.449017] debug: unmapping init [mem 0xffff8800375f2000-0xffff880037af0fff]
[    1.449251] PCI-DMA: Using software bounce buffering for IO (SWIOTLB)
[    1.449322] software IO TLB [mem 0xcad1a000-0xced19fff] (64MB) mapped at [ffff8800cad1a000-ffff8800ced19fff]
[    1.456695] microcode: CPU0 sig=0x6fb, pf=0x10, revision=0xb6
[    1.456803] microcode: CPU1 sig=0x6fb, pf=0x10, revision=0xb6
[    1.456907] microcode: CPU2 sig=0x6fb, pf=0x10, revision=0xb6
[    1.457019] microcode: CPU3 sig=0x6fb, pf=0x10, revision=0xb6
[    1.457798] microcode: Microcode Update Driver: v2.00 <tigran@aivazian.fsnet.co.uk>, Peter Oruba
[    1.458090] sha1_ssse3: Using SSSE3 optimized SHA-1 implementation
[    1.460254] audit: initializing netlink socket (disabled)
[    1.460398] type=2000 audit(1250396328.459:1): initialized
[    1.463190] HugeTLB registered 2 MB page size, pre-allocated 0 pages
[    1.535927] fuse init (API version 7.20)
[    1.537946] msgmni has been set to 7832
[    1.542513] Block layer SCSI generic (bsg) driver version 0.4 loaded (major 252)
[    1.542629] io scheduler noop registered
[    1.543680] io scheduler cfq registered (default)
[    1.543747] start plist test
[    1.544884] end plist test
[    1.544940] list_sort_test: start testing list_sort()
[    1.553362] intel_idle: does not run on family 6 model 15
[    1.554180] input: Power Button as /devices/LNXSYSTM:00/device:00/PNP0C0C:00/input/input0
[    1.554349] ACPI: Power Button [PWRB]
[    1.555114] input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/input/input1
[    1.555229] ACPI: Power Button [PWRF]
[    1.557534] ACPI: Requesting acpi_cpufreq
[    1.863945] thermal LNXTHERM:00: registered as thermal_zone0
[    1.864039] ACPI: Thermal Zone [THRM] (30 C)
[    1.864989] GHES: HEST is not enabled!
[    1.865631] Serial: 8250/16550 driver, 4 ports, IRQ sharing disabled
[    1.886803] serial8250: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
[    1.912061] 00:06: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
[    1.915550] Linux agpgart interface v0.103
[    1.916833] agpgart-intel 0000:00:00.0: Intel G33 Chipset
[    1.917096] agpgart-intel 0000:00:00.0: detected gtt size: 524288K total, 262144K mappable
[    1.918127] agpgart-intel 0000:00:00.0: detected 8192K stolen memory
[    1.919008] agpgart-intel 0000:00:00.0: AGP aperture is 256M @ 0xd0000000
[    1.919758] [drm] Initialized drm 1.1.0 20060810
[    1.924831] i915 0000:00:02.0: setting latency timer to 64
[    1.970502] i915 0000:00:02.0: irq 40 for MSI/MSI-X
[    1.970650] [drm] Supports vblank timestamp caching Rev 1 (10.10.2010).
[    1.970718] [drm] Driver supports precise vblank timestamp query.
[    1.971198] vgaarb: device changed decodes: PCI:0000:00:02.0,olddecodes=io+mem,decodes=io+mem:owns=io+mem
[    2.083383] [drm] initialized overlay support
[    2.179944] fbcon: inteldrmfb (fb0) is primary device
[    2.220366] [drm] Setting output timings on SDVOB failed
[    2.234122] [drm] Setting input timings on SDVOB failed
[    2.306415] Console: switching to colour frame buffer device 240x67
[    2.312360] fb0: inteldrmfb frame buffer device
[    2.312384] drm: registered panic notifier
[    2.312503] i915: No ACPI video bus found
[    2.312932] [drm] Initialized i915 1.6.0 20080730 for 0000:00:02.0 on minor 0
[    2.326199] loop: module loaded
[    2.328723] ata_piix 0000:00:1f.1: version 2.13
[    2.328921] ata_piix 0000:00:1f.1: setting latency timer to 64
[    2.334885] scsi0 : ata_piix
[    2.339100] scsi1 : ata_piix
[    2.341326] ata1: PATA max UDMA/100 cmd 0x1f0 ctl 0x3f6 bmdma 0xffa0 irq 14
[    2.341363] ata2: PATA max UDMA/100 cmd 0x170 ctl 0x376 bmdma 0xffa8 irq 15
[    2.341528] ata_piix 0000:00:1f.2: MAP [
[    2.341558]  P0 P2 P1 P3 ]
[    2.341749] ata_piix 0000:00:1f.2: setting latency timer to 64
[    2.348302] scsi2 : ata_piix
[    2.350723] scsi3 : ata_piix
[    2.352962] ata3: SATA max UDMA/133 cmd 0xc080 ctl 0xc000 bmdma 0xb800 irq 19
[    2.352999] ata4: SATA max UDMA/133 cmd 0xbc00 ctl 0xb880 bmdma 0xb808 irq 19
[    2.353781] r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
[    2.354182] r8169 0000:01:00.0: irq 41 for MSI/MSI-X
[    2.356299] r8169 0000:01:00.0: eth0: RTL8101e at 0xffffc9000002e000, 00:1e:90:a5:f6:e2, XID 94200000 IRQ 41
[    2.357012] yenta_cardbus 0000:02:02.0: CardBus bridge found [0000:0000]
[    2.357079] yenta_cardbus 0000:02:02.0: CardBus bridge to [bus 04-07]
[    2.357113] yenta_cardbus 0000:02:02.0:   bridge window [io  0xe400-0xe4ff]
[    2.357151] yenta_cardbus 0000:02:02.0:   bridge window [io  0xe000-0xe0ff]
[    2.357189] yenta_cardbus 0000:02:02.0:   bridge window [mem 0xfb000000-0xfb3fffff pref]
[    2.357233] yenta_cardbus 0000:02:02.0:   bridge window [mem 0xf4000000-0xf7ffffff]
[    2.452142] tsc: Refined TSC clocksource calibration: 2393.999 MHz
[    2.452251] Switching to clocksource tsc
[    2.504370] ata4.01: NODEV after polling detection
[    2.508323] ata3.00: ATA-7: INTEL SSDSA2M080G2GN, 2CV102HD, max UDMA/133
[    2.508376] ata3.00: 156301488 sectors, multi 16: LBA48 NCQ (depth 0/32)
[    2.512313] ata3.00: configured for UDMA/133
[    2.513581] scsi 2:0:0:0: Direct-Access     ATA      INTEL SSDSA2M080 2CV1 PQ: 0 ANSI: 5
[    2.517301] sd 2:0:0:0: [sda] 156301488 512-byte logical blocks: (80.0 GB/74.5 GiB)
[    2.518277] sd 2:0:0:0: Attached scsi generic sg0 type 0
[    2.518312] sd 2:0:0:0: [sda] Write Protect is off
[    2.518342] sd 2:0:0:0: [sda] Mode Sense: 00 3a 00 00
[    2.518636] sd 2:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[    2.522604]  sda: sda1 sda2
[    2.524703] ata4.00: ATAPI: TSSTcorpCD/DVDW SH-S183L, SB03, max UDMA/33
[    2.524742] ata4.00: applying bridge limits
[    2.526756] sd 2:0:0:0: [sda] Attached SCSI disk
[    2.531205] ata4.00: configured for UDMA/33
[    2.533264] scsi 3:0:0:0: CD-ROM            TSSTcorp CD/DVDW SH-S183L SB03 PQ: 0 ANSI: 5
[    2.541208] sr0: scsi3-mmc drive: 48x/48x writer dvd-ram cd/rw xa/form2 cdda tray
[    2.542745] cdrom: Uniform CD-ROM driver Revision: 3.20
[    2.546216] sr 3:0:0:0: Attached scsi CD-ROM sr0
[    2.547589] sr 3:0:0:0: Attached scsi generic sg1 type 5
[    2.521241] ACPI: Invalid Power Resource to register!
[    2.551557] ACPI: Invalid Power Resource to register!<6>[    2.675984] yenta_cardbus 0000:02:02.0: ISA IRQ mask 0x0000, PCI irq 19
[    2.677554] yenta_cardbus 0000:02:02.0: Socket status: 30000820
[    2.679117] pci_bus 0000:02: Raising subordinate bus# of parent bus (#02) from #04 to #07
[    2.680792] yenta_cardbus 0000:02:02.0: pcmcia: parent PCI bridge window: [io  0xe000-0xefff]
[    2.682390] yenta_cardbus 0000:02:02.0: pcmcia: parent PCI bridge window: [mem 0xfe300000-0xfebfffff]
[    2.683979] pcmcia_socket pcmcia_socket0: cs: memory probe 0xfe300000-0xfebfffff:
[    2.685654]  excluding 0xfe300000-0xfe41ffff
[    2.687588] yenta_cardbus 0000:02:02.0: pcmcia: parent PCI bridge window: [mem 0xfb000000-0xfcffffff 64bit pref]
[    2.689215] pcmcia_socket pcmcia_socket0: cs: memory probe 0xfb000000-0xfcffffff:
[    2.691261]  excluding 0xfb000000-0xfcffffff
[    2.694457] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
[    2.696125] ehci_hcd: block sizes: qh 104 qtd 96 itd 192 sitd 96
[    2.696296] ehci_hcd 0000:00:1d.7: setting latency timer to 64
[    2.696302] ehci_hcd 0000:00:1d.7: EHCI Host Controller
[    2.698075] ehci_hcd 0000:00:1d.7: new USB bus registered, assigned bus number 1
[    2.699690] ehci_hcd 0000:00:1d.7: reset hcs_params 0x104208 dbg=1 cc=4 pcc=2 ordered !ppc ports=8
[    2.699694] ehci_hcd 0000:00:1d.7: reset hcc_params 6871 thresh 7 uframes 1024 64 bit addr
[    2.699823] ehci_hcd 0000:00:1d.7: reset command 0080002 (park)=0 ithresh=8 period=1024 Reset HALT
[    2.703702] ehci_hcd 0000:00:1d.7: debug port 1
[    2.705287] ehci_hcd 0000:00:1d.7: cache line size of 32 is not supported
[    2.705289] ehci_hcd 0000:00:1d.7: supports USB remote wakeup
[    2.705487] ehci_hcd 0000:00:1d.7: irq 23, io mem 0xfe177c00
[    2.707070] ehci_hcd 0000:00:1d.7: init command 0010001 (park)=0 ithresh=1 period=1024 RUN
[    2.713110] ehci_hcd 0000:00:1d.7: USB 2.0 started, EHCI 1.00
[    2.715175] usb usb1: default language 0x0409
[    2.715354] usb usb1: udev 1, busnum 1, minor = 0
[    2.715358] usb usb1: New USB device found, idVendor=1d6b, idProduct=0002
[    2.716897] usb usb1: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    2.718418] usb usb1: Product: EHCI Host Controller
[    2.719927] usb usb1: Manufacturer: Linux 3.6.0-rc3-wl-main ehci_hcd
[    2.721455] usb usb1: SerialNumber: 0000:00:1d.7
[    2.724283] usb usb1: usb_probe_device
[    2.724287] usb usb1: configuration #1 chosen from 1 choice
[    2.724505] usb usb1: adding 1-0:1.0 (config #1, interface 0)
[    2.725096] hub 1-0:1.0: usb_probe_interface
[    2.725099] hub 1-0:1.0: usb_probe_interface - got id
[    2.725108] hub 1-0:1.0: USB hub found
[    2.726774] hub 1-0:1.0: 8 ports detected
[    2.728302] hub 1-0:1.0: standalone hub
[    2.728305] hub 1-0:1.0: no power switching (usb 1.0)
[    2.728307] hub 1-0:1.0: individual port over-current protection
[    2.728311] hub 1-0:1.0: power on to power good time: 20ms
[    2.728519] hub 1-0:1.0: local power source is good
[    2.728531] hub 1-0:1.0: trying to enable port power on non-switchable hub
[    2.730187] uhci_hcd: USB Universal Host Controller Interface driver
[    2.732367] uhci_hcd 0000:00:1d.0: setting latency timer to 64
[    2.732372] uhci_hcd 0000:00:1d.0: UHCI Host Controller
[    2.733952] uhci_hcd 0000:00:1d.0: new USB bus registered, assigned bus number 2
[    2.735491] uhci_hcd 0000:00:1d.0: detected 2 ports
[    2.737015] uhci_hcd 0000:00:1d.0: uhci_check_and_reset_hc: cmd = 0x0000
[    2.737017] uhci_hcd 0000:00:1d.0: Performing full reset
[    2.737031] uhci_hcd 0000:00:1d.0: supports USB remote wakeup
[    2.737069] uhci_hcd 0000:00:1d.0: irq 23, io base 0x0000c880
[    2.738904] usb usb2: default language 0x0409
[    2.739095] usb usb2: udev 1, busnum 2, minor = 128
[    2.739098] usb usb2: New USB device found, idVendor=1d6b, idProduct=0001
[    2.740637] usb usb2: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    2.742200] usb usb2: Product: UHCI Host Controller
[    2.743751] usb usb2: Manufacturer: Linux 3.6.0-rc3-wl-main uhci_hcd
[    2.745305] usb usb2: SerialNumber: 0000:00:1d.0
[    2.747870] usb usb2: usb_probe_device
[    2.747873] usb usb2: configuration #1 chosen from 1 choice
[    2.747955] usb usb2: adding 2-0:1.0 (config #1, interface 0)
[    2.748480] hub 2-0:1.0: usb_probe_interface
[    2.748483] hub 2-0:1.0: usb_probe_interface - got id
[    2.748487] hub 2-0:1.0: USB hub found
[    2.750152] hub 2-0:1.0: 2 ports detected
[    2.751704] hub 2-0:1.0: standalone hub
[    2.751706] hub 2-0:1.0: no power switching (usb 1.0)
[    2.751709] hub 2-0:1.0: individual port over-current protection
[    2.751712] hub 2-0:1.0: power on to power good time: 2ms
[    2.751833] hub 2-0:1.0: local power source is good
[    2.751845] hub 2-0:1.0: trying to enable port power on non-switchable hub
[    2.752562] ehci_hcd 0000:00:1d.7: HS companion for 0000:00:1d.0
[    2.752792] uhci_hcd 0000:00:1d.1: setting latency timer to 64
[    2.752797] uhci_hcd 0000:00:1d.1: UHCI Host Controller
[    2.754352] uhci_hcd 0000:00:1d.1: new USB bus registered, assigned bus number 3
[    2.755889] uhci_hcd 0000:00:1d.1: detected 2 ports
[    2.757406] uhci_hcd 0000:00:1d.1: uhci_check_and_reset_hc: cmd = 0x0000
[    2.757409] uhci_hcd 0000:00:1d.1: Performing full reset
[    2.757422] uhci_hcd 0000:00:1d.1: supports USB remote wakeup
[    2.757461] uhci_hcd 0000:00:1d.1: irq 19, io base 0x0000c800
[    2.759280] usb usb3: default language 0x0409
[    2.759453] usb usb3: udev 1, busnum 3, minor = 256
[    2.759456] usb usb3: New USB device found, idVendor=1d6b, idProduct=0001
[    2.760994] usb usb3: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    2.762551] usb usb3: Product: UHCI Host Controller
[    2.764087] usb usb3: Manufacturer: Linux 3.6.0-rc3-wl-main uhci_hcd
[    2.765629] usb usb3: SerialNumber: 0000:00:1d.1
[    2.768181] usb usb3: usb_probe_device
[    2.768185] usb usb3: configuration #1 chosen from 1 choice
[    2.768291] usb usb3: adding 3-0:1.0 (config #1, interface 0)
[    2.768838] hub 3-0:1.0: usb_probe_interface
[    2.768841] hub 3-0:1.0: usb_probe_interface - got id
[    2.768846] hub 3-0:1.0: USB hub found
[    2.770500] hub 3-0:1.0: 2 ports detected
[    2.772055] hub 3-0:1.0: standalone hub
[    2.772058] hub 3-0:1.0: no power switching (usb 1.0)
[    2.772060] hub 3-0:1.0: individual port over-current protection
[    2.772063] hub 3-0:1.0: power on to power good time: 2ms
[    2.772172] hub 3-0:1.0: local power source is good
[    2.772184] hub 3-0:1.0: trying to enable port power on non-switchable hub
[    2.772898] ehci_hcd 0000:00:1d.7: HS companion for 0000:00:1d.1
[    2.773150] uhci_hcd 0000:00:1d.2: setting latency timer to 64
[    2.773155] uhci_hcd 0000:00:1d.2: UHCI Host Controller
[    2.774719] uhci_hcd 0000:00:1d.2: new USB bus registered, assigned bus number 4
[    2.776262] uhci_hcd 0000:00:1d.2: detected 2 ports
[    2.777760] uhci_hcd 0000:00:1d.2: uhci_check_and_reset_hc: cmd = 0x0000
[    2.777763] uhci_hcd 0000:00:1d.2: Performing full reset
[    2.777776] uhci_hcd 0000:00:1d.2: supports USB remote wakeup
[    2.777961] uhci_hcd 0000:00:1d.2: irq 18, io base 0x0000c480
[    2.779743] usb usb4: default language 0x0409
[    2.779915] usb usb4: udev 1, busnum 4, minor = 384
[    2.779918] usb usb4: New USB device found, idVendor=1d6b, idProduct=0001
[    2.781427] usb usb4: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    2.782899] usb usb4: Product: UHCI Host Controller
[    2.784363] usb usb4: Manufacturer: Linux 3.6.0-rc3-wl-main uhci_hcd
[    2.785838] usb usb4: SerialNumber: 0000:00:1d.2
[    2.788335] usb usb4: usb_probe_device
[    2.788338] usb usb4: configuration #1 chosen from 1 choice
[    2.788431] usb usb4: adding 4-0:1.0 (config #1, interface 0)
[    2.788962] hub 4-0:1.0: usb_probe_interface
[    2.788965] hub 4-0:1.0: usb_probe_interface - got id
[    2.788970] hub 4-0:1.0: USB hub found
[    2.790578] hub 4-0:1.0: 2 ports detected
[    2.792049] hub 4-0:1.0: standalone hub
[    2.792052] hub 4-0:1.0: no power switching (usb 1.0)
[    2.792054] hub 4-0:1.0: individual port over-current protection
[    2.792067] hub 4-0:1.0: power on to power good time: 2ms
[    2.792175] hub 4-0:1.0: local power source is good
[    2.792187] hub 4-0:1.0: trying to enable port power on non-switchable hub
[    2.792917] ehci_hcd 0000:00:1d.7: HS companion for 0000:00:1d.2
[    2.793160] uhci_hcd 0000:00:1d.3: setting latency timer to 64
[    2.793165] uhci_hcd 0000:00:1d.3: UHCI Host Controller
[    2.794638] uhci_hcd 0000:00:1d.3: new USB bus registered, assigned bus number 5
[    2.796116] uhci_hcd 0000:00:1d.3: detected 2 ports
[    2.797544] uhci_hcd 0000:00:1d.3: uhci_check_and_reset_hc: cmd = 0x0000
[    2.797546] uhci_hcd 0000:00:1d.3: Performing full reset
[    2.797560] uhci_hcd 0000:00:1d.3: supports USB remote wakeup
[    2.797738] uhci_hcd 0000:00:1d.3: irq 16, io base 0x0000c400
[    2.799490] usb usb5: default language 0x0409
[    2.799670] usb usb5: udev 1, busnum 5, minor = 512
[    2.799673] usb usb5: New USB device found, idVendor=1d6b, idProduct=0001
[    2.801085] usb usb5: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    2.802458] usb usb5: Product: UHCI Host Controller
[    2.803802] usb usb5: Manufacturer: Linux 3.6.0-rc3-wl-main uhci_hcd
[    2.805152] usb usb5: SerialNumber: 0000:00:1d.3
[    2.807557] usb usb5: usb_probe_device
[    2.807560] usb usb5: configuration #1 chosen from 1 choice
[    2.807669] usb usb5: adding 5-0:1.0 (config #1, interface 0)
[    2.808328] hub 5-0:1.0: usb_probe_interface
[    2.808331] hub 5-0:1.0: usb_probe_interface - got id
[    2.808336] hub 5-0:1.0: USB hub found
[    2.809756] hub 5-0:1.0: 2 ports detected
[    2.811104] hub 5-0:1.0: standalone hub
[    2.811106] hub 5-0:1.0: no power switching (usb 1.0)
[    2.811108] hub 5-0:1.0: individual port over-current protection
[    2.811112] hub 5-0:1.0: power on to power good time: 2ms
[    2.811224] hub 5-0:1.0: local power source is good
[    2.811237] hub 5-0:1.0: trying to enable port power on non-switchable hub
[    2.811946] ehci_hcd 0000:00:1d.7: HS companion for 0000:00:1d.3
[    2.812899] usbcore: registered new interface driver cdc_acm
[    2.814208] cdc_acm: USB Abstract Control Model driver for USB modems and ISDN adapters
[    2.815848] usbcore: registered new interface driver uas
[    2.817123] Initializing USB Mass Storage driver...
[    2.818817] usbcore: registered new interface driver usb-storage
[    2.820111] USB Mass Storage support registered.
[    2.821934] usbcore: registered new interface driver libusual
[    2.824614] i8042: PNP: No PS/2 controller found. Probing ports directly.
[    2.826992] serio: i8042 KBD port at 0x60,0x64 irq 1
[    2.828201] ehci_hcd 0000:00:1d.7: GetStatus port:2 status 001403 0  ACK POWER sig=k CSC CONNECT
[    2.828217] hub 1-0:1.0: port 2: status 0501 change 0001
[    2.828294] ehci_hcd 0000:00:1d.7: GetStatus port:3 status 001803 0  ACK POWER sig=j CSC CONNECT
[    2.828310] hub 1-0:1.0: port 3: status 0501 change 0001
[    2.828439] ehci_hcd 0000:00:1d.7: GetStatus port:7 status 001803 0  ACK POWER sig=j CSC CONNECT
[    2.828457] hub 1-0:1.0: port 7: status 0501 change 0001
[    2.828521] serio: i8042 AUX port at 0x60,0x64 irq 12
[    2.831432] mousedev: PS/2 mouse device common for all mice
[    2.834783] rtc_cmos 00:03: RTC can wake from S4
[    2.837087] rtc_cmos 00:03: rtc core: registered rtc_cmos as rtc0
[    2.838460] rtc0: alarms up to one month, y3k, 114 bytes nvram, hpet irqs
[    2.840193] i801_smbus 0000:00:1f.3: SMBus using PCI Interrupt
[    2.842686] usbcore: registered new interface driver uvcvideo
[    2.844006] USB Video Class driver (1.1.1)
[    2.846864] coretemp coretemp.0: Using relative temperature scale!
[    2.848267] coretemp coretemp.0: Using relative temperature scale!
[    2.849624] coretemp coretemp.0: Using relative temperature scale!
[    2.850954] coretemp coretemp.0: Using relative temperature scale!
[    2.851251] uhci_hcd 0000:00:1d.0: port 2 portsc 008a,00
[    2.852321] it87: Found IT8718F chip at 0xa10, revision 4
[    2.853591] it87: VID is disabled (pins used for GPIO)
[    2.857459] it87_wdt: Chip IT8718 revision 4 initialized. timeout=60 sec (nowayout=0 testmode=0 exclusive=1 nogameport=0)
[    2.858803] cpuidle: using governor ladder
[    2.860113] cpuidle: using governor menu
[    2.869203] usbcore: registered new interface driver usbhid
[    2.870520] usbhid: USB HID core driver
[    2.872493] uhci_hcd 0000:00:1d.1: port 1 portsc 008a,00
[    2.874202] snd_hda_intel 0000:00:1b.0: irq 42 for MSI/MSI-X
[    2.892136] hub 4-0:1.0: state 7 ports 2 chg 0000 evt 0000
[    2.901415] TCP: cubic registered
[    2.902719] Initializing XFRM netlink socket
[    2.904084] NET: Registered protocol family 17
[    2.909492] registered taskstats version 1
[    2.911573] uhci_hcd 0000:00:1d.3: port 1 portsc 008a,00
[    2.913397] rtc_cmos 00:03: setting system clock to 2009-08-16 04:18:50 UTC (1250396330)
[    2.928240] hub 1-0:1.0: state 7 ports 8 chg 008c evt 0000
[    2.928293] hub 1-0:1.0: port 2, status 0501, change 0000, 480 Mb/s
[    2.928399] ehci_hcd 0000:00:1d.7: port 2 low speed --> companion
[    2.949707] ALSA device list:
[    2.951020]   #0: HDA Intel at 0xfe178000 irq 42
[    2.952832] debug: unmapping init [mem 0xffffffff81a98000-0xffffffff81b19fff]
[    2.954231] Write protecting the kernel read-only data: 10240k
[    2.955733] Testing CPA: undo ffffffff81000000-ffffffff81a00000
[    2.957217] Testing CPA: again
[    2.958692] debug: unmapping init [mem 0xffff8800015d9000-0xffff8800015fffff]
[    2.960061] debug: unmapping init [mem 0xffff880001895000-0xffff8800019fffff]
[    2.979094] ehci_hcd 0000:00:1d.7: GetStatus port:2 status 003002 0  ACK POWER OWNER sig=se0 CSC
[    2.979311] hub 1-0:1.0: port 3, status 0501, change 0000, 480 Mb/s
[    3.030223] ehci_hcd 0000:00:1d.7: port 3 full speed --> companion
[    3.030231] ehci_hcd 0000:00:1d.7: GetStatus port:3 status 003801 0  ACK POWER OWNER sig=j CONNECT
[    3.030252] hub 1-0:1.0: port 3 not reset yet, waiting 50ms
[    3.081060] ehci_hcd 0000:00:1d.7: GetStatus port:3 status 003002 0  ACK POWER OWNER sig=se0 CSC
[    3.081227] hub 1-0:1.0: port 7, status 0501, change 0000, 480 Mb/s
[    3.102717] dracut: dracut-018-55.git20120606.fc16
[    3.132348] ehci_hcd 0000:00:1d.7: port 7 full speed --> companion
[    3.132355] ehci_hcd 0000:00:1d.7: GetStatus port:7 status 003801 0  ACK POWER OWNER sig=j CONNECT
[    3.132381] hub 1-0:1.0: port 7 not reset yet, waiting 50ms
[    3.157021] udevd[937]: starting version 173
[    3.183098] ehci_hcd 0000:00:1d.7: GetStatus port:7 status 003002 0  ACK POWER OWNER sig=se0 CSC
[    3.183277] hub 1-0:1.0: state 7 ports 8 chg 0000 evt fe8c
[    3.183299] ehci_hcd 0000:00:1d.7: GetStatus port:2 status 003002 0  ACK POWER OWNER sig=se0 CSC
[    3.183343] hub 1-0:1.0: port 2, status 0100, change 0001, 12 Mb/s
[    3.288123] hub 1-0:1.0: debounce: port 2: total 100ms stable 100ms status 0x100
[    3.288150] ehci_hcd 0000:00:1d.7: GetStatus port:3 status 003002 0  ACK POWER OWNER sig=se0 CSC
[    3.288194] hub 1-0:1.0: port 3, status 0100, change 0001, 12 Mb/s
[    3.342090] dracut: Starting plymouth daemon
[    3.392194] hub 1-0:1.0: debounce: port 3: total 100ms stable 100ms status 0x100
[    3.392219] ehci_hcd 0000:00:1d.7: GetStatus port:7 status 003002 0  ACK POWER OWNER sig=se0 CSC
[    3.392265] hub 1-0:1.0: port 7, status 0100, change 0001, 12 Mb/s
[    3.496049] hub 1-0:1.0: debounce: port 7: total 100ms stable 100ms status 0x100
[    3.496057] hub 2-0:1.0: state 7 ports 2 chg 0000 evt 0004
[    3.496082] uhci_hcd 0000:00:1d.0: port 2 portsc 01a3,00
[    3.496131] hub 2-0:1.0: port 2, status 0301, change 0001, 1.5 Mb/s
[    3.568041] pcmcia_socket pcmcia_socket0: pccard: CardBus card inserted into slot 0
[    3.569673] pci 0000:04:00.0: [168c:0013] type 00 class 0x028000
[    3.569708] pci 0000:04:00.0: reg 10: [mem 0x00000000-0x0000ffff]
[    3.569905] pci 0000:04:00.0: BAR 0: assigned [mem 0xf4000000-0xf400ffff]
[    3.600079] hub 2-0:1.0: debounce: port 2: total 100ms stable 100ms status 0x301
[    3.702077] usb 2-2: new low-speed USB device number 2 using uhci_hcd
[    3.706993] modprobe (1263) used greatest stack depth: 4208 bytes left
[    3.851053] usb 2-2: skipped 1 descriptor after interface
[    3.851066] usb 2-2: skipped 1 descriptor after interface
[    3.855752] usb 2-2: default language 0x0409
[    3.856137] ata_id (1483) used greatest stack depth: 3696 bytes left
[    3.872782] usb 2-2: udev 2, busnum 2, minor = 129
[    3.872787] usb 2-2: New USB device found, idVendor=046d, idProduct=c312
[    3.874924] usb 2-2: New USB device strings: Mfr=1, Product=2, SerialNumber=0
[    3.876574] usb 2-2: Product: USB Multimedia Keyboard
[    3.878178] usb 2-2: Manufacturer: BTC
[    3.883083] usb 2-2: usb_probe_device
[    3.883089] usb 2-2: configuration #1 chosen from 1 choice
[    3.885974] usb 2-2: adding 2-2:1.0 (config #1, interface 0)
[    3.887753] usbhid 2-2:1.0: usb_probe_interface
[    3.887758] usbhid 2-2:1.0: usb_probe_interface - got id
[    3.905848] input: BTC USB Multimedia Keyboard as /devices/pci0000:00/0000:00:1d.0/usb2/2-2/2-2:1.0/input/input2
[    3.908120] uhci_hcd 0000:00:1d.0: reserve dev 2 ep81-INT, period 8, phase 4, 118 us
[    3.920319] hid-generic 0003:046D:C312.0001: input,hidraw0: USB HID v1.10 Keyboard [BTC USB Multimedia Keyboard] on usb-0000:00:1d.0-2/input0
[    3.922798] usb 2-2: adding 2-2:1.1 (config #1, interface 1)
[    3.925487] usbhid 2-2:1.1: usb_probe_interface
[    3.925493] usbhid 2-2:1.1: usb_probe_interface - got id
[    3.954034] usb usb4: suspend_rh (auto-stop)
[    3.970054] input: BTC USB Multimedia Keyboard as /devices/pci0000:00/0000:00:1d.0/usb2/2-2/2-2:1.1/input/input3
[    3.971913] uhci_hcd 0000:00:1d.0: reserve dev 2 ep82-INT, period 8, phase 4, 118 us
[    3.973332] usbhid 2-2:1.1: looking for a minor, starting at 0
[    3.976847] hid-generic 0003:046D:C312.0002: input,hiddev0,hidraw1: USB HID v1.10 Device [BTC USB Multimedia Keyboard] on usb-0000:00:1d.0-2/input1
[    3.979180] hub 3-0:1.0: state 7 ports 2 chg 0000 evt 0002
[    3.979212] uhci_hcd 0000:00:1d.1: port 1 portsc 0093,00
[    3.979261] hub 3-0:1.0: port 1, status 0101, change 0001, 12 Mb/s
[    4.071786] EXT4-fs (sda1): INFO: recovery required on readonly filesystem
[    4.073547] EXT4-fs (sda1): write access will be enabled during recovery
[    4.085243] hub 3-0:1.0: debounce: port 1: total 100ms stable 100ms status 0x101
[    4.187231] usb 3-1: new full-speed USB device number 2 using uhci_hcd
[    4.273908] EXT4-fs (sda1): recovery complete
[    4.276449] EXT4-fs (sda1): mounted filesystem with ordered data mode. Opts: (null)
[    4.312035] usb 3-1: ep0 maxpacket = 8
[    4.344172] usb 3-1: skipped 1 descriptor after interface
[    4.344184] usb 3-1: skipped 1 descriptor after interface
[    4.344192] usb 3-1: skipped 1 descriptor after interface
[    4.349158] usb 3-1: default language 0x0409
[    4.364161] usb 3-1: udev 2, busnum 3, minor = 257
[    4.364165] usb 3-1: New USB device found, idVendor=046d, idProduct=c52b
[    4.365841] usb 3-1: New USB device strings: Mfr=1, Product=2, SerialNumber=0
[    4.367783] usb 3-1: Product: USB Receiver
[    4.369471] usb 3-1: Manufacturer: Logitech
[    4.370274] dracut: Checking ext4: /dev/disk/by-uuid/69ea49b8-e1c0-494e-a5b2-3e0f4850decf
[    4.370493] dracut: issuing e2fsck -a  /dev/disk/by-uuid/69ea49b8-e1c0-494e-a5b2-3e0f4850decf
[    4.375493] usb 3-1: usb_probe_device
[    4.375498] usb 3-1: configuration #1 chosen from 1 choice
[    4.381234] usb 3-1: adding 3-1:1.0 (config #1, interface 0)
[    4.381870] usbhid 3-1:1.0: usb_probe_interface
[    4.381875] usbhid 3-1:1.0: usb_probe_interface - got id
[    4.384454] usb 3-1: adding 3-1:1.1 (config #1, interface 1)
[    4.384985] usbhid 3-1:1.1: usb_probe_interface
[    4.384989] usbhid 3-1:1.1: usb_probe_interface - got id
[    4.388307] dracut: /dev/disk/by-uuid/69ea49b8-e1c0-494e-a5b2-3e0f4850decf: clean, 1449525/4505600 files, 9390645/18001664 blocks
[    4.389259] usb 3-1: adding 3-1:1.2 (config #1, interface 2)
[    4.389776] usbhid 3-1:1.2: usb_probe_interface
[    4.389779] usbhid 3-1:1.2: usb_probe_interface - got id
[    4.391686] dracut: Remounting /dev/disk/by-uuid/69ea49b8-e1c0-494e-a5b2-3e0f4850decf with -o ro
[    4.397191] usbhid 3-1:1.2: looking for a minor, starting at 0
[    4.398927] logitech-djreceiver 0003:046D:C52B.0005: hiddev0,hidraw2: USB HID v1.11 Device [Logitech USB Receiver] on usb-0000:00:1d.1-1/input2
[    4.402259] uhci_hcd 0000:00:1d.1: reserve dev 2 ep83-INT, period 2, phase 1, 36 us
[    4.403872] hub 5-0:1.0: state 7 ports 2 chg 0000 evt 0002
[    4.403900] uhci_hcd 0000:00:1d.3: port 1 portsc 0093,00
[    4.403951] hub 5-0:1.0: port 1, status 0101, change 0001, 12 Mb/s
[    4.412740] input: Logitech Unifying Device. Wireless PID:101b as /devices/pci0000:00/0000:00:1d.1/usb3/3-1/3-1:1.2/0003:046D:C52B.0005/input/input4
[    4.419105] logitech-djdevice 0003:046D:C52B.0006: input,hidraw3: USB HID v1.11 Mouse [Logitech Unifying Device. Wireless PID:101b] on usb-0000:00:1d.1-1:1
[    4.427745] EXT4-fs (sda1): mounted filesystem with ordered data mode. Opts: (null)
[    4.447247] dracut: Mounted root filesystem /dev/sda1
[    4.494420] readlink (1732) used greatest stack depth: 3216 bytes left
[    4.507070] hub 5-0:1.0: debounce: port 1: total 100ms stable 100ms status 0x101
[    4.560953] dracut: Switching root
[    4.609096] usb 5-1: new full-speed USB device number 2 using uhci_hcd
[    4.691355] systemd[1]: systemd 37 running in system mode. (+PAM +LIBWRAP +AUDIT +SELINUX +SYSVINIT +LIBCRYPTSETUP; fedora)
[    4.732889] systemd[1]: /sbin/modprobe failed with error code 1.
[    4.738568] systemd[1]: Set hostname to <mj>.
[    4.747345] usb 5-1: default language 0x0409
[    4.757355] usb 5-1: udev 2, busnum 5, minor = 513
[    4.757359] usb 5-1: New USB device found, idVendor=1004, idProduct=607f
[    4.759290] usb 5-1: New USB device strings: Mfr=1, Product=2, SerialNumber=0
[    4.761207] usb 5-1: Product: USB Autorun
[    4.763121] usb 5-1: Manufacturer: LG Electronics, Inc
[    4.765893] usb 5-1: usb_probe_device
[    4.765898] usb 5-1: configuration #1 chosen from 1 choice
[    4.768377] usb 5-1: adding 5-1:1.0 (config #1, interface 0)
[    4.768915] uas 5-1:1.0: usb_probe_interface
[    4.768918] uas 5-1:1.0: usb_probe_interface - got id
[    4.769099] usb-storage 5-1:1.0: usb_probe_interface
[    4.769104] usb-storage 5-1:1.0: usb_probe_interface - got id
[    4.769394] scsi4 : usb-storage 5-1:1.0
[    4.773146] hub 3-0:1.0: state 7 ports 2 chg 0000 evt 0002
[    5.057675] systemd-readahead-replay[1753]: Bumped block_nr parameter of 259:0 to 16384. This is a temporary hack and should be removed one day.
[    5.121701] mount (1756) used greatest stack depth: 2880 bytes left
[    5.191512] udevd[1763]: starting version 173
[    5.364816] EXT4-fs (sda1): re-mounted. Opts: (null)
[    5.779525] scsi 4:0:0:0: CD-ROM            LG       Autorun          1.00 PQ: 0 ANSI: 0
[    5.795411] sr1: scsi3-mmc drive: 48x/48x tray
[    5.807283] sr 4:0:0:0: Attached scsi CD-ROM sr1
[    5.810857] sr 4:0:0:0: Attached scsi generic sg2 type 5
[    5.861139] pcmcia_socket pcmcia_socket0: cs: memory probe 0x0c0000-0x0fffff:
[    5.863053]  excluding 0xc0000-0xcffff 0xe0000-0xfffff
[    5.869975] cfg80211: Calling CRDA to update world regulatory domain
[    5.870787] pcmcia_socket pcmcia_socket0: cs: memory probe 0xa0000000-0xa0ffffff:
[    5.874024]  excluding 0xa0000000-0xa0ffffff
[    5.879186] mtp-probe[2259]: checking bus 2, device 2: "/sys/devices/pci0000:00/0000:00:1d.0/usb2/2-2"
[    5.886548] pcmcia_socket pcmcia_socket0: cs: memory probe 0x60000000-0x60ffffff:
[    5.888587]  excluding 0x60000000-0x60ffffff
[    6.001081] mtp-probe[2338]: checking bus 3, device 2: "/sys/devices/pci0000:00/0000:00:1d.1/usb3/3-1"
[    6.019597] mtp-probe[2346]: checking bus 5, device 2: "/sys/devices/pci0000:00/0000:00:1d.3/usb5/5-1"
[    6.022925] mtp-probe[2259]: bus: 2, device: 2 was not an MTP device
[    6.034827] mtp-probe[2338]: bus: 3, device: 2 was not an MTP device
[    6.067694] cfg80211: World regulatory domain updated:
[    6.069423] cfg80211:   (start_freq - end_freq @ bandwidth), (max_antenna_gain, max_eirp)
[    6.070974] cfg80211:   (2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    6.072560] cfg80211:   (2457000 KHz - 2482000 KHz @ 20000 KHz), (300 mBi, 2000 mBm)
[    6.074128] cfg80211:   (2474000 KHz - 2494000 KHz @ 20000 KHz), (300 mBi, 2000 mBm)
[    6.075812] cfg80211:   (5170000 KHz - 5250000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    6.077235] cfg80211:   (5735000 KHz - 5835000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    6.082090] ath5k 0000:03:08.0: registered as 'phy0'
[    6.109943] mtp-probe[2346]: bus: 5, device: 2 was not an MTP device
[    6.519727] Adding 6142972k swap on /dev/sda2.  Priority:0 extents:1 across:6142972k SS
[    6.736465] ath: EEPROM regdomain: 0x0
[    6.736470] ath: EEPROM indicates default country code should be used
[    6.736471] ath: doing EEPROM country->regdmn map search
[    6.736474] ath: country maps to regdmn code: 0x3a
[    6.736476] ath: Country alpha2 being used: US
[    6.736477] ath: Regpair used: 0x3a
[    6.736514] cfg80211: Updating information on frequency 2412 MHz for a 20 MHz width channel with regulatory rule:
[    6.736517] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (N/A mBi, 2000 mBm)
[    6.736519] cfg80211: Updating information on frequency 2417 MHz for a 20 MHz width channel with regulatory rule:
[    6.736522] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (N/A mBi, 2000 mBm)
[    6.736524] cfg80211: Updating information on frequency 2422 MHz for a 20 MHz width channel with regulatory rule:
[    6.736526] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (N/A mBi, 2000 mBm)
[    6.736528] cfg80211: Updating information on frequency 2427 MHz for a 20 MHz width channel with regulatory rule:
[    6.736531] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (N/A mBi, 2000 mBm)
[    6.736533] cfg80211: Updating information on frequency 2432 MHz for a 20 MHz width channel with regulatory rule:
[    6.736535] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (N/A mBi, 2000 mBm)
[    6.736537] cfg80211: Updating information on frequency 2437 MHz for a 20 MHz width channel with regulatory rule:
[    6.736539] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (N/A mBi, 2000 mBm)
[    6.736541] cfg80211: Updating information on frequency 2442 MHz for a 20 MHz width channel with regulatory rule:
[    6.736544] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (N/A mBi, 2000 mBm)
[    6.736546] cfg80211: Updating information on frequency 2447 MHz for a 20 MHz width channel with regulatory rule:
[    6.736548] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (N/A mBi, 2000 mBm)
[    6.736550] cfg80211: Updating information on frequency 2452 MHz for a 20 MHz width channel with regulatory rule:
[    6.736553] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (N/A mBi, 2000 mBm)
[    6.736555] cfg80211: Updating information on frequency 2457 MHz for a 20 MHz width channel with regulatory rule:
[    6.736557] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (N/A mBi, 2000 mBm)
[    6.736559] cfg80211: Updating information on frequency 2462 MHz for a 20 MHz width channel with regulatory rule:
[    6.736562] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (N/A mBi, 2000 mBm)
[    6.736564] cfg80211: Disabling freq 2467 MHz as custom regd has no rule that fits a 20 MHz wide channel
[    6.736566] cfg80211: Disabling freq 2472 MHz as custom regd has no rule that fits a 20 MHz wide channel
[    6.736568] cfg80211: Disabling freq 2484 MHz as custom regd has no rule that fits a 20 MHz wide channel
[    6.736570] cfg80211: Disabling freq 5040 MHz as custom regd has no rule that fits a 20 MHz wide channel
[    6.736571] cfg80211: Disabling freq 5060 MHz as custom regd has no rule that fits a 20 MHz wide channel
[    6.736573] cfg80211: Disabling freq 5080 MHz as custom regd has no rule that fits a 20 MHz wide channel
[    6.736575] cfg80211: Updating information on frequency 5180 MHz for a 20 MHz width channel with regulatory rule:
[    6.736577] cfg80211: 5140000 KHz - 5360000 KHz @ 40000 KHz), (N/A mBi, 3000 mBm)
[    6.736580] cfg80211: Updating information on frequency 5200 MHz for a 20 MHz width channel with regulatory rule:
[    6.736582] cfg80211: 5140000 KHz - 5360000 KHz @ 40000 KHz), (N/A mBi, 3000 mBm)
[    6.736584] cfg80211: Updating information on frequency 5220 MHz for a 20 MHz width channel with regulatory rule:
[    6.736586] cfg80211: 5140000 KHz - 5360000 KHz @ 40000 KHz), (N/A mBi, 3000 mBm)
[    6.736588] cfg80211: Updating information on frequency 5240 MHz for a 20 MHz width channel with regulatory rule:
[    6.736590] cfg80211: 5140000 KHz - 5360000 KHz @ 40000 KHz), (N/A mBi, 3000 mBm)
[    6.736592] cfg80211: Updating information on frequency 5260 MHz for a 20 MHz width channel with regulatory rule:
[    6.736595] cfg80211: 5140000 KHz - 5360000 KHz @ 40000 KHz), (N/A mBi, 3000 mBm)
[    6.736597] cfg80211: Updating information on frequency 5280 MHz for a 20 MHz width channel with regulatory rule:
[    6.736599] cfg80211: 5140000 KHz - 5360000 KHz @ 40000 KHz), (N/A mBi, 3000 mBm)
[    6.736601] cfg80211: Updating information on frequency 5300 MHz for a 20 MHz width channel with regulatory rule:
[    6.736603] cfg80211: 5140000 KHz - 5360000 KHz @ 40000 KHz), (N/A mBi, 3000 mBm)
[    6.736605] cfg80211: Updating information on frequency 5320 MHz for a 20 MHz width channel with regulatory rule:
[    6.736608] cfg80211: 5140000 KHz - 5360000 KHz @ 40000 KHz), (N/A mBi, 3000 mBm)
[    6.736610] cfg80211: Disabling freq 5500 MHz as custom regd has no rule that fits a 20 MHz wide channel
[    6.736612] cfg80211: Disabling freq 5520 MHz as custom regd has no rule that fits a 20 MHz wide channel
[    6.736614] cfg80211: Disabling freq 5540 MHz as custom regd has no rule that fits a 20 MHz wide channel
[    6.736615] cfg80211: Disabling freq 5560 MHz as custom regd has no rule that fits a 20 MHz wide channel
[    6.736617] cfg80211: Disabling freq 5580 MHz as custom regd has no rule that fits a 20 MHz wide channel
[    6.736619] cfg80211: Disabling freq 5600 MHz as custom regd has no rule that fits a 20 MHz wide channel
[    6.736621] cfg80211: Disabling freq 5620 MHz as custom regd has no rule that fits a 20 MHz wide channel
[    6.736623] cfg80211: Disabling freq 5640 MHz as custom regd has no rule that fits a 20 MHz wide channel
[    6.736625] cfg80211: Disabling freq 5660 MHz as custom regd has no rule that fits a 20 MHz wide channel
[    6.736627] cfg80211: Disabling freq 5680 MHz as custom regd has no rule that fits a 20 MHz wide channel
[    6.736629] cfg80211: Disabling freq 5700 MHz as custom regd has no rule that fits a 20 MHz wide channel
[    6.736631] cfg80211: Updating information on frequency 5745 MHz for a 20 MHz width channel with regulatory rule:
[    6.736633] cfg80211: 5715000 KHz - 5860000 KHz @ 40000 KHz), (N/A mBi, 3000 mBm)
[    6.736635] cfg80211: Updating information on frequency 5765 MHz for a 20 MHz width channel with regulatory rule:
[    6.736637] cfg80211: 5715000 KHz - 5860000 KHz @ 40000 KHz), (N/A mBi, 3000 mBm)
[    6.736639] cfg80211: Updating information on frequency 5785 MHz for a 20 MHz width channel with regulatory rule:
[    6.736642] cfg80211: 5715000 KHz - 5860000 KHz @ 40000 KHz), (N/A mBi, 3000 mBm)
[    6.736644] cfg80211: Updating information on frequency 5805 MHz for a 20 MHz width channel with regulatory rule:
[    6.736646] cfg80211: 5715000 KHz - 5860000 KHz @ 40000 KHz), (N/A mBi, 3000 mBm)
[    6.736648] cfg80211: Updating information on frequency 5825 MHz for a 20 MHz width channel with regulatory rule:
[    6.736650] cfg80211: 5715000 KHz - 5860000 KHz @ 40000 KHz), (N/A mBi, 3000 mBm)
[    6.738236] cfg80211: Updating information on frequency 2412 MHz for a 20 MHz width channel with regulatory rule:
[    6.738240] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    6.738242] cfg80211: Updating information on frequency 2417 MHz for a 20 MHz width channel with regulatory rule:
[    6.738245] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    6.738247] cfg80211: Updating information on frequency 2422 MHz for a 20 MHz width channel with regulatory rule:
[    6.738249] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    6.738251] cfg80211: Updating information on frequency 2427 MHz for a 20 MHz width channel with regulatory rule:
[    6.738254] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    6.738256] cfg80211: Updating information on frequency 2432 MHz for a 20 MHz width channel with regulatory rule:
[    6.738258] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    6.738261] cfg80211: Updating information on frequency 2437 MHz for a 20 MHz width channel with regulatory rule:
[    6.738263] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    6.738265] cfg80211: Updating information on frequency 2442 MHz for a 20 MHz width channel with regulatory rule:
[    6.738267] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    6.738270] cfg80211: Updating information on frequency 2447 MHz for a 20 MHz width channel with regulatory rule:
[    6.738272] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    6.738274] cfg80211: Updating information on frequency 2452 MHz for a 20 MHz width channel with regulatory rule:
[    6.738277] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    6.738279] cfg80211: Updating information on frequency 2457 MHz for a 20 MHz width channel with regulatory rule:
[    6.738281] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    6.738283] cfg80211: Updating information on frequency 2462 MHz for a 20 MHz width channel with regulatory rule:
[    6.738286] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    6.738288] cfg80211: Updating information on frequency 2467 MHz for a 20 MHz width channel with regulatory rule:
[    6.738290] cfg80211: 2457000 KHz - 2482000 KHz @ 20000 KHz), (300 mBi, 2000 mBm)
[    6.738293] cfg80211: Updating information on frequency 2472 MHz for a 20 MHz width channel with regulatory rule:
[    6.738295] cfg80211: 2457000 KHz - 2482000 KHz @ 20000 KHz), (300 mBi, 2000 mBm)
[    6.738297] cfg80211: Updating information on frequency 2484 MHz for a 20 MHz width channel with regulatory rule:
[    6.738300] cfg80211: 2474000 KHz - 2494000 KHz @ 20000 KHz), (300 mBi, 2000 mBm)
[    6.738302] cfg80211: Disabling freq 5040 MHz
[    6.738304] cfg80211: Disabling freq 5060 MHz
[    6.738305] cfg80211: Disabling freq 5080 MHz
[    6.738308] cfg80211: Updating information on frequency 5180 MHz for a 20 MHz width channel with regulatory rule:
[    6.738310] cfg80211: 5170000 KHz - 5250000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    6.738312] cfg80211: Updating information on frequency 5200 MHz for a 20 MHz width channel with regulatory rule:
[    6.738315] cfg80211: 5170000 KHz - 5250000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    6.738317] cfg80211: Updating information on frequency 5220 MHz for a 20 MHz width channel with regulatory rule:
[    6.738319] cfg80211: 5170000 KHz - 5250000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    6.738321] cfg80211: Updating information on frequency 5240 MHz for a 20 MHz width channel with regulatory rule:
[    6.738324] cfg80211: 5170000 KHz - 5250000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    6.738326] cfg80211: Disabling freq 5260 MHz
[    6.738327] cfg80211: Disabling freq 5280 MHz
[    6.738329] cfg80211: Disabling freq 5300 MHz
[    6.738331] cfg80211: Disabling freq 5320 MHz
[    6.738333] cfg80211: Disabling freq 5500 MHz
[    6.738334] cfg80211: Disabling freq 5520 MHz
[    6.738336] cfg80211: Disabling freq 5540 MHz
[    6.738338] cfg80211: Disabling freq 5560 MHz
[    6.738340] cfg80211: Disabling freq 5580 MHz
[    6.738341] cfg80211: Disabling freq 5600 MHz
[    6.738343] cfg80211: Disabling freq 5620 MHz
[    6.738345] cfg80211: Disabling freq 5640 MHz
[    6.738347] cfg80211: Disabling freq 5660 MHz
[    6.738349] cfg80211: Disabling freq 5680 MHz
[    6.738350] cfg80211: Disabling freq 5700 MHz
[    6.738353] cfg80211: Updating information on frequency 5745 MHz for a 20 MHz width channel with regulatory rule:
[    6.738355] cfg80211: 5735000 KHz - 5835000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    6.738357] cfg80211: Updating information on frequency 5765 MHz for a 20 MHz width channel with regulatory rule:
[    6.738360] cfg80211: 5735000 KHz - 5835000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    6.738362] cfg80211: Updating information on frequency 5785 MHz for a 20 MHz width channel with regulatory rule:
[    6.738364] cfg80211: 5735000 KHz - 5835000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    6.738366] cfg80211: Updating information on frequency 5805 MHz for a 20 MHz width channel with regulatory rule:
[    6.738369] cfg80211: 5735000 KHz - 5835000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    6.738371] cfg80211: Updating information on frequency 5825 MHz for a 20 MHz width channel with regulatory rule:
[    6.738373] cfg80211: 5735000 KHz - 5835000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    6.741323] ieee80211 phy0: Selected rate control algorithm 'minstrel_ht'
[    6.746590] ath5k: phy0: Atheros AR5213A chip found (MAC: 0x59, PHY: 0x43)
[    6.748104] ath5k: phy0: RF5112B multiband radio found (0x36)
[    6.749592] cfg80211: Calling CRDA for country: US
[    6.752395] ath5k 0000:03:09.0: registered as 'phy1'
[    6.763622] cfg80211: Updating information on frequency 2412 MHz for a 20 MHz width channel with regulatory rule:
[    6.763627] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2700 mBm)
[    6.763630] cfg80211: Updating information on frequency 2417 MHz for a 20 MHz width channel with regulatory rule:
[    6.763632] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2700 mBm)
[    6.763635] cfg80211: Updating information on frequency 2422 MHz for a 20 MHz width channel with regulatory rule:
[    6.763637] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2700 mBm)
[    6.763639] cfg80211: Updating information on frequency 2427 MHz for a 20 MHz width channel with regulatory rule:
[    6.763642] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2700 mBm)
[    6.763644] cfg80211: Updating information on frequency 2432 MHz for a 20 MHz width channel with regulatory rule:
[    6.763646] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2700 mBm)
[    6.763649] cfg80211: Updating information on frequency 2437 MHz for a 20 MHz width channel with regulatory rule:
[    6.763651] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2700 mBm)
[    6.763653] cfg80211: Updating information on frequency 2442 MHz for a 20 MHz width channel with regulatory rule:
[    6.763656] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2700 mBm)
[    6.763658] cfg80211: Updating information on frequency 2447 MHz for a 20 MHz width channel with regulatory rule:
[    6.763660] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2700 mBm)
[    6.763662] cfg80211: Updating information on frequency 2452 MHz for a 20 MHz width channel with regulatory rule:
[    6.763665] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2700 mBm)
[    6.763667] cfg80211: Updating information on frequency 2457 MHz for a 20 MHz width channel with regulatory rule:
[    6.763669] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2700 mBm)
[    6.763672] cfg80211: Updating information on frequency 2462 MHz for a 20 MHz width channel with regulatory rule:
[    6.763674] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2700 mBm)
[    6.763676] cfg80211: Disabling freq 2467 MHz
[    6.763678] cfg80211: Disabling freq 2472 MHz
[    6.763680] cfg80211: Disabling freq 2484 MHz
[    6.763682] cfg80211: Disabling freq 5040 MHz
[    6.763683] cfg80211: Disabling freq 5060 MHz
[    6.763685] cfg80211: Disabling freq 5080 MHz
[    6.763687] cfg80211: Updating information on frequency 5180 MHz for a 20 MHz width channel with regulatory rule:
[    6.763690] cfg80211: 5170000 KHz - 5250000 KHz @ 40000 KHz), (300 mBi, 1700 mBm)
[    6.763692] cfg80211: Updating information on frequency 5200 MHz for a 20 MHz width channel with regulatory rule:
[    6.763694] cfg80211: 5170000 KHz - 5250000 KHz @ 40000 KHz), (300 mBi, 1700 mBm)
[    6.763697] cfg80211: Updating information on frequency 5220 MHz for a 20 MHz width channel with regulatory rule:
[    6.763699] cfg80211: 5170000 KHz - 5250000 KHz @ 40000 KHz), (300 mBi, 1700 mBm)
[    6.763701] cfg80211: Updating information on frequency 5240 MHz for a 20 MHz width channel with regulatory rule:
[    6.763704] cfg80211: 5170000 KHz - 5250000 KHz @ 40000 KHz), (300 mBi, 1700 mBm)
[    6.763706] cfg80211: Updating information on frequency 5260 MHz for a 20 MHz width channel with regulatory rule:
[    6.763708] cfg80211: 5250000 KHz - 5330000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    6.763710] cfg80211: Updating information on frequency 5280 MHz for a 20 MHz width channel with regulatory rule:
[    6.763713] cfg80211: 5250000 KHz - 5330000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    6.763715] cfg80211: Updating information on frequency 5300 MHz for a 20 MHz width channel with regulatory rule:
[    6.763717] cfg80211: 5250000 KHz - 5330000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    6.763720] cfg80211: Updating information on frequency 5320 MHz for a 20 MHz width channel with regulatory rule:
[    6.763722] cfg80211: 5250000 KHz - 5330000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    6.763724] cfg80211: Updating information on frequency 5500 MHz for a 20 MHz width channel with regulatory rule:
[    6.763727] cfg80211: 5490000 KHz - 5600000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    6.763729] cfg80211: Updating information on frequency 5520 MHz for a 20 MHz width channel with regulatory rule:
[    6.763731] cfg80211: 5490000 KHz - 5600000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    6.763734] cfg80211: Updating information on frequency 5540 MHz for a 20 MHz width channel with regulatory rule:
[    6.763736] cfg80211: 5490000 KHz - 5600000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    6.763738] cfg80211: Updating information on frequency 5560 MHz for a 20 MHz width channel with regulatory rule:
[    6.763741] cfg80211: 5490000 KHz - 5600000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    6.763743] cfg80211: Updating information on frequency 5580 MHz for a 20 MHz width channel with regulatory rule:
[    6.763745] cfg80211: 5490000 KHz - 5600000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    6.763747] cfg80211: Disabling freq 5600 MHz
[    6.763749] cfg80211: Disabling freq 5620 MHz
[    6.763751] cfg80211: Disabling freq 5640 MHz
[    6.763753] cfg80211: Updating information on frequency 5660 MHz for a 20 MHz width channel with regulatory rule:
[    6.763780] cfg80211: 5650000 KHz - 5710000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    6.763782] cfg80211: Updating information on frequency 5680 MHz for a 20 MHz width channel with regulatory rule:
[    6.763785] cfg80211: 5650000 KHz - 5710000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    6.763787] cfg80211: Updating information on frequency 5700 MHz for a 20 MHz width channel with regulatory rule:
[    6.763789] cfg80211: 5650000 KHz - 5710000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    6.763791] cfg80211: Updating information on frequency 5745 MHz for a 20 MHz width channel with regulatory rule:
[    6.763793] cfg80211: 5735000 KHz - 5835000 KHz @ 40000 KHz), (300 mBi, 3000 mBm)
[    6.763796] cfg80211: Updating information on frequency 5765 MHz for a 20 MHz width channel with regulatory rule:
[    6.763798] cfg80211: 5735000 KHz - 5835000 KHz @ 40000 KHz), (300 mBi, 3000 mBm)
[    6.763800] cfg80211: Updating information on frequency 5785 MHz for a 20 MHz width channel with regulatory rule:
[    6.763803] cfg80211: 5735000 KHz - 5835000 KHz @ 40000 KHz), (300 mBi, 3000 mBm)
[    6.763805] cfg80211: Updating information on frequency 5805 MHz for a 20 MHz width channel with regulatory rule:
[    6.763807] cfg80211: 5735000 KHz - 5835000 KHz @ 40000 KHz), (300 mBi, 3000 mBm)
[    6.763809] cfg80211: Updating information on frequency 5825 MHz for a 20 MHz width channel with regulatory rule:
[    6.763812] cfg80211: 5735000 KHz - 5835000 KHz @ 40000 KHz), (300 mBi, 3000 mBm)
[    6.763819] cfg80211: Regulatory domain changed to country: US
[    6.765256] cfg80211:   (start_freq - end_freq @ bandwidth), (max_antenna_gain, max_eirp)
[    6.766716] cfg80211:   (2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2700 mBm)
[    6.768179] cfg80211:   (5170000 KHz - 5250000 KHz @ 40000 KHz), (300 mBi, 1700 mBm)
[    6.769791] cfg80211:   (5250000 KHz - 5330000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    6.771238] cfg80211:   (5490000 KHz - 5600000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    6.772693] cfg80211:   (5650000 KHz - 5710000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    6.774153] cfg80211:   (5735000 KHz - 5835000 KHz @ 40000 KHz), (300 mBi, 3000 mBm)
[    6.887281] logger[2598]: usb_modeswitch: using overriding config file /etc/usb_modeswitch.d/1004:607f; make sure this is intended
[    6.891029] logger[2599]: usb_modeswitch: please report any new or corrected settings; otherwise, check for outdated files
[    6.923668] usb-storage 5-1:1.0: disconnect by usbfs
[    6.923700] usb_modeswitch[2600]: switching device 1004:607f on 005/002
[    7.250253] ath: EEPROM regdomain: 0x0
[    7.250258] ath: EEPROM indicates default country code should be used
[    7.250260] ath: doing EEPROM country->regdmn map search
[    7.250264] ath: country maps to regdmn code: 0x3a
[    7.250266] ath: Country alpha2 being used: US
[    7.250268] ath: Regpair used: 0x3a
[    7.250275] cfg80211: Updating information on frequency 2412 MHz for a 20 MHz width channel with regulatory rule:
[    7.250279] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (N/A mBi, 2000 mBm)
[    7.250282] cfg80211: Updating information on frequency 2417 MHz for a 20 MHz width channel with regulatory rule:
[    7.250285] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (N/A mBi, 2000 mBm)
[    7.250288] cfg80211: Updating information on frequency 2422 MHz for a 20 MHz width channel with regulatory rule:
[    7.250292] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (N/A mBi, 2000 mBm)
[    7.250295] cfg80211: Updating information on frequency 2427 MHz for a 20 MHz width channel with regulatory rule:
[    7.250298] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (N/A mBi, 2000 mBm)
[    7.250301] cfg80211: Updating information on frequency 2432 MHz for a 20 MHz width channel with regulatory rule:
[    7.250305] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (N/A mBi, 2000 mBm)
[    7.250307] cfg80211: Updating information on frequency 2437 MHz for a 20 MHz width channel with regulatory rule:
[    7.250311] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (N/A mBi, 2000 mBm)
[    7.250314] cfg80211: Updating information on frequency 2442 MHz for a 20 MHz width channel with regulatory rule:
[    7.250317] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (N/A mBi, 2000 mBm)
[    7.250320] cfg80211: Updating information on frequency 2447 MHz for a 20 MHz width channel with regulatory rule:
[    7.250323] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (N/A mBi, 2000 mBm)
[    7.250326] cfg80211: Updating information on frequency 2452 MHz for a 20 MHz width channel with regulatory rule:
[    7.250329] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (N/A mBi, 2000 mBm)
[    7.250332] cfg80211: Updating information on frequency 2457 MHz for a 20 MHz width channel with regulatory rule:
[    7.250336] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (N/A mBi, 2000 mBm)
[    7.250339] cfg80211: Updating information on frequency 2462 MHz for a 20 MHz width channel with regulatory rule:
[    7.250342] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (N/A mBi, 2000 mBm)
[    7.250345] cfg80211: Disabling freq 2467 MHz as custom regd has no rule that fits a 20 MHz wide channel
[    7.250348] cfg80211: Disabling freq 2472 MHz as custom regd has no rule that fits a 20 MHz wide channel
[    7.250351] cfg80211: Disabling freq 2484 MHz as custom regd has no rule that fits a 20 MHz wide channel
[    7.250353] cfg80211: Disabling freq 5040 MHz as custom regd has no rule that fits a 20 MHz wide channel
[    7.250356] cfg80211: Disabling freq 5060 MHz as custom regd has no rule that fits a 20 MHz wide channel
[    7.250359] cfg80211: Disabling freq 5080 MHz as custom regd has no rule that fits a 20 MHz wide channel
[    7.250362] cfg80211: Updating information on frequency 5180 MHz for a 20 MHz width channel with regulatory rule:
[    7.250365] cfg80211: 5140000 KHz - 5360000 KHz @ 40000 KHz), (N/A mBi, 3000 mBm)
[    7.250368] cfg80211: Updating information on frequency 5200 MHz for a 20 MHz width channel with regulatory rule:
[    7.250371] cfg80211: 5140000 KHz - 5360000 KHz @ 40000 KHz), (N/A mBi, 3000 mBm)
[    7.250374] cfg80211: Updating information on frequency 5220 MHz for a 20 MHz width channel with regulatory rule:
[    7.250378] cfg80211: 5140000 KHz - 5360000 KHz @ 40000 KHz), (N/A mBi, 3000 mBm)
[    7.250380] cfg80211: Updating information on frequency 5240 MHz for a 20 MHz width channel with regulatory rule:
[    7.250384] cfg80211: 5140000 KHz - 5360000 KHz @ 40000 KHz), (N/A mBi, 3000 mBm)
[    7.250387] cfg80211: Updating information on frequency 5260 MHz for a 20 MHz width channel with regulatory rule:
[    7.250390] cfg80211: 5140000 KHz - 5360000 KHz @ 40000 KHz), (N/A mBi, 3000 mBm)
[    7.250393] cfg80211: Updating information on frequency 5280 MHz for a 20 MHz width channel with regulatory rule:
[    7.250396] cfg80211: 5140000 KHz - 5360000 KHz @ 40000 KHz), (N/A mBi, 3000 mBm)
[    7.250399] cfg80211: Updating information on frequency 5300 MHz for a 20 MHz width channel with regulatory rule:
[    7.250403] cfg80211: 5140000 KHz - 5360000 KHz @ 40000 KHz), (N/A mBi, 3000 mBm)
[    7.250405] cfg80211: Updating information on frequency 5320 MHz for a 20 MHz width channel with regulatory rule:
[    7.250414] cfg80211: 5140000 KHz - 5360000 KHz @ 40000 KHz), (N/A mBi, 3000 mBm)
[    7.250416] cfg80211: Disabling freq 5500 MHz as custom regd has no rule that fits a 20 MHz wide channel
[    7.250418] cfg80211: Disabling freq 5520 MHz as custom regd has no rule that fits a 20 MHz wide channel
[    7.250420] cfg80211: Disabling freq 5540 MHz as custom regd has no rule that fits a 20 MHz wide channel
[    7.250422] cfg80211: Disabling freq 5560 MHz as custom regd has no rule that fits a 20 MHz wide channel
[    7.250424] cfg80211: Disabling freq 5580 MHz as custom regd has no rule that fits a 20 MHz wide channel
[    7.250425] cfg80211: Disabling freq 5600 MHz as custom regd has no rule that fits a 20 MHz wide channel
[    7.250427] cfg80211: Disabling freq 5620 MHz as custom regd has no rule that fits a 20 MHz wide channel
[    7.250429] cfg80211: Disabling freq 5640 MHz as custom regd has no rule that fits a 20 MHz wide channel
[    7.250431] cfg80211: Disabling freq 5660 MHz as custom regd has no rule that fits a 20 MHz wide channel
[    7.250433] cfg80211: Disabling freq 5680 MHz as custom regd has no rule that fits a 20 MHz wide channel
[    7.250434] cfg80211: Disabling freq 5700 MHz as custom regd has no rule that fits a 20 MHz wide channel
[    7.250436] cfg80211: Updating information on frequency 5745 MHz for a 20 MHz width channel with regulatory rule:
[    7.250439] cfg80211: 5715000 KHz - 5860000 KHz @ 40000 KHz), (N/A mBi, 3000 mBm)
[    7.250441] cfg80211: Updating information on frequency 5765 MHz for a 20 MHz width channel with regulatory rule:
[    7.250443] cfg80211: 5715000 KHz - 5860000 KHz @ 40000 KHz), (N/A mBi, 3000 mBm)
[    7.250445] cfg80211: Updating information on frequency 5785 MHz for a 20 MHz width channel with regulatory rule:
[    7.250447] cfg80211: 5715000 KHz - 5860000 KHz @ 40000 KHz), (N/A mBi, 3000 mBm)
[    7.250449] cfg80211: Updating information on frequency 5805 MHz for a 20 MHz width channel with regulatory rule:
[    7.250451] cfg80211: 5715000 KHz - 5860000 KHz @ 40000 KHz), (N/A mBi, 3000 mBm)
[    7.250453] cfg80211: Updating information on frequency 5825 MHz for a 20 MHz width channel with regulatory rule:
[    7.250455] cfg80211: 5715000 KHz - 5860000 KHz @ 40000 KHz), (N/A mBi, 3000 mBm)
[    7.251195] cfg80211: Ignoring regulatory request Set by core since the driver requires its own regulatory domain to be set first
[    7.253414] ieee80211 phy1: Selected rate control algorithm 'minstrel_ht'
[    7.257595] cfg80211: Updating information on frequency 2412 MHz for a 20 MHz width channel with regulatory rule:
[    7.257598] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2700 mBm)
[    7.257601] cfg80211: Updating information on frequency 2417 MHz for a 20 MHz width channel with regulatory rule:
[    7.257603] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2700 mBm)
[    7.257605] cfg80211: Updating information on frequency 2422 MHz for a 20 MHz width channel with regulatory rule:
[    7.257608] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2700 mBm)
[    7.257610] cfg80211: Updating information on frequency 2427 MHz for a 20 MHz width channel with regulatory rule:
[    7.257612] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2700 mBm)
[    7.257614] cfg80211: Updating information on frequency 2432 MHz for a 20 MHz width channel with regulatory rule:
[    7.257617] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2700 mBm)
[    7.257619] cfg80211: Updating information on frequency 2437 MHz for a 20 MHz width channel with regulatory rule:
[    7.257621] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2700 mBm)
[    7.257623] cfg80211: Updating information on frequency 2442 MHz for a 20 MHz width channel with regulatory rule:
[    7.257625] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2700 mBm)
[    7.257628] cfg80211: Updating information on frequency 2447 MHz for a 20 MHz width channel with regulatory rule:
[    7.257630] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2700 mBm)
[    7.257632] cfg80211: Updating information on frequency 2452 MHz for a 20 MHz width channel with regulatory rule:
[    7.257634] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2700 mBm)
[    7.257636] cfg80211: Updating information on frequency 2457 MHz for a 20 MHz width channel with regulatory rule:
[    7.257639] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2700 mBm)
[    7.257641] cfg80211: Updating information on frequency 2462 MHz for a 20 MHz width channel with regulatory rule:
[    7.257643] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2700 mBm)
[    7.257645] cfg80211: Disabling freq 2467 MHz
[    7.257647] cfg80211: Disabling freq 2472 MHz
[    7.257649] cfg80211: Disabling freq 2484 MHz
[    7.257650] cfg80211: Disabling freq 5040 MHz
[    7.257652] cfg80211: Disabling freq 5060 MHz
[    7.257654] cfg80211: Disabling freq 5080 MHz
[    7.257656] cfg80211: Updating information on frequency 5180 MHz for a 20 MHz width channel with regulatory rule:
[    7.257658] cfg80211: 5170000 KHz - 5250000 KHz @ 40000 KHz), (300 mBi, 1700 mBm)
[    7.257660] cfg80211: Updating information on frequency 5200 MHz for a 20 MHz width channel with regulatory rule:
[    7.257663] cfg80211: 5170000 KHz - 5250000 KHz @ 40000 KHz), (300 mBi, 1700 mBm)
[    7.257665] cfg80211: Updating information on frequency 5220 MHz for a 20 MHz width channel with regulatory rule:
[    7.257667] cfg80211: 5170000 KHz - 5250000 KHz @ 40000 KHz), (300 mBi, 1700 mBm)
[    7.257669] cfg80211: Updating information on frequency 5240 MHz for a 20 MHz width channel with regulatory rule:
[    7.257672] cfg80211: 5170000 KHz - 5250000 KHz @ 40000 KHz), (300 mBi, 1700 mBm)
[    7.257674] cfg80211: Updating information on frequency 5260 MHz for a 20 MHz width channel with regulatory rule:
[    7.257676] cfg80211: 5250000 KHz - 5330000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    7.257678] cfg80211: Updating information on frequency 5280 MHz for a 20 MHz width channel with regulatory rule:
[    7.257681] cfg80211: 5250000 KHz - 5330000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    7.257683] cfg80211: Updating information on frequency 5300 MHz for a 20 MHz width channel with regulatory rule:
[    7.257685] cfg80211: 5250000 KHz - 5330000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    7.257687] cfg80211: Updating information on frequency 5320 MHz for a 20 MHz width channel with regulatory rule:
[    7.257690] cfg80211: 5250000 KHz - 5330000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    7.257692] cfg80211: Updating information on frequency 5500 MHz for a 20 MHz width channel with regulatory rule:
[    7.257694] cfg80211: 5490000 KHz - 5600000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    7.257696] cfg80211: Updating information on frequency 5520 MHz for a 20 MHz width channel with regulatory rule:
[    7.257699] cfg80211: 5490000 KHz - 5600000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    7.257701] cfg80211: Updating information on frequency 5540 MHz for a 20 MHz width channel with regulatory rule:
[    7.257703] cfg80211: 5490000 KHz - 5600000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    7.257705] cfg80211: Updating information on frequency 5560 MHz for a 20 MHz width channel with regulatory rule:
[    7.257708] cfg80211: 5490000 KHz - 5600000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    7.257710] cfg80211: Updating information on frequency 5580 MHz for a 20 MHz width channel with regulatory rule:
[    7.257712] cfg80211: 5490000 KHz - 5600000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    7.257714] cfg80211: Disabling freq 5600 MHz
[    7.257716] cfg80211: Disabling freq 5620 MHz
[    7.257717] cfg80211: Disabling freq 5640 MHz
[    7.257719] cfg80211: Updating information on frequency 5660 MHz for a 20 MHz width channel with regulatory rule:
[    7.257722] cfg80211: 5650000 KHz - 5710000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    7.257724] cfg80211: Updating information on frequency 5680 MHz for a 20 MHz width channel with regulatory rule:
[    7.257727] cfg80211: 5650000 KHz - 5710000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    7.257729] cfg80211: Updating information on frequency 5700 MHz for a 20 MHz width channel with regulatory rule:
[    7.257731] cfg80211: 5650000 KHz - 5710000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    7.257733] cfg80211: Updating information on frequency 5745 MHz for a 20 MHz width channel with regulatory rule:
[    7.257736] cfg80211: 5735000 KHz - 5835000 KHz @ 40000 KHz), (300 mBi, 3000 mBm)
[    7.257738] cfg80211: Updating information on frequency 5765 MHz for a 20 MHz width channel with regulatory rule:
[    7.257740] cfg80211: 5735000 KHz - 5835000 KHz @ 40000 KHz), (300 mBi, 3000 mBm)
[    7.257742] cfg80211: Updating information on frequency 5785 MHz for a 20 MHz width channel with regulatory rule:
[    7.257745] cfg80211: 5735000 KHz - 5835000 KHz @ 40000 KHz), (300 mBi, 3000 mBm)
[    7.257747] cfg80211: Updating information on frequency 5805 MHz for a 20 MHz width channel with regulatory rule:
[    7.257749] cfg80211: 5735000 KHz - 5835000 KHz @ 40000 KHz), (300 mBi, 3000 mBm)
[    7.257751] cfg80211: Updating information on frequency 5825 MHz for a 20 MHz width channel with regulatory rule:
[    7.257754] cfg80211: 5735000 KHz - 5835000 KHz @ 40000 KHz), (300 mBi, 3000 mBm)
[    7.257889] ath5k: phy1: Atheros AR5213A chip found (MAC: 0x59, PHY: 0x43)
[    7.259400] ath5k: phy1: RF5112B multiband radio found (0x36)
[    7.261582] ath5k 0000:03:0b.0: registered as 'phy2'
[    7.755367] ath: EEPROM regdomain: 0x0
[    7.755370] ath: EEPROM indicates default country code should be used
[    7.755371] ath: doing EEPROM country->regdmn map search
[    7.755373] ath: country maps to regdmn code: 0x3a
[    7.755375] ath: Country alpha2 being used: US
[    7.755376] ath: Regpair used: 0x3a
[    7.755380] cfg80211: Updating information on frequency 2412 MHz for a 20 MHz width channel with regulatory rule:
[    7.755382] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (N/A mBi, 2000 mBm)
[    7.755385] cfg80211: Updating information on frequency 2417 MHz for a 20 MHz width channel with regulatory rule:
[    7.755387] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (N/A mBi, 2000 mBm)
[    7.755389] cfg80211: Updating information on frequency 2422 MHz for a 20 MHz width channel with regulatory rule:
[    7.755391] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (N/A mBi, 2000 mBm)
[    7.755393] cfg80211: Updating information on frequency 2427 MHz for a 20 MHz width channel with regulatory rule:
[    7.755395] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (N/A mBi, 2000 mBm)
[    7.755397] cfg80211: Updating information on frequency 2432 MHz for a 20 MHz width channel with regulatory rule:
[    7.755399] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (N/A mBi, 2000 mBm)
[    7.755401] cfg80211: Updating information on frequency 2437 MHz for a 20 MHz width channel with regulatory rule:
[    7.755404] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (N/A mBi, 2000 mBm)
[    7.755405] cfg80211: Updating information on frequency 2442 MHz for a 20 MHz width channel with regulatory rule:
[    7.755408] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (N/A mBi, 2000 mBm)
[    7.755410] cfg80211: Updating information on frequency 2447 MHz for a 20 MHz width channel with regulatory rule:
[    7.755412] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (N/A mBi, 2000 mBm)
[    7.755414] cfg80211: Updating information on frequency 2452 MHz for a 20 MHz width channel with regulatory rule:
[    7.755416] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (N/A mBi, 2000 mBm)
[    7.755418] cfg80211: Updating information on frequency 2457 MHz for a 20 MHz width channel with regulatory rule:
[    7.755420] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (N/A mBi, 2000 mBm)
[    7.755422] cfg80211: Updating information on frequency 2462 MHz for a 20 MHz width channel with regulatory rule:
[    7.755424] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (N/A mBi, 2000 mBm)
[    7.755426] cfg80211: Disabling freq 2467 MHz as custom regd has no rule that fits a 20 MHz wide channel
[    7.755428] cfg80211: Disabling freq 2472 MHz as custom regd has no rule that fits a 20 MHz wide channel
[    7.755430] cfg80211: Disabling freq 2484 MHz as custom regd has no rule that fits a 20 MHz wide channel
[    7.755432] cfg80211: Disabling freq 5040 MHz as custom regd has no rule that fits a 20 MHz wide channel
[    7.755434] cfg80211: Disabling freq 5060 MHz as custom regd has no rule that fits a 20 MHz wide channel
[    7.755435] cfg80211: Disabling freq 5080 MHz as custom regd has no rule that fits a 20 MHz wide channel
[    7.755437] cfg80211: Updating information on frequency 5180 MHz for a 20 MHz width channel with regulatory rule:
[    7.755440] cfg80211: 5140000 KHz - 5360000 KHz @ 40000 KHz), (N/A mBi, 3000 mBm)
[    7.755442] cfg80211: Updating information on frequency 5200 MHz for a 20 MHz width channel with regulatory rule:
[    7.755444] cfg80211: 5140000 KHz - 5360000 KHz @ 40000 KHz), (N/A mBi, 3000 mBm)
[    7.755446] cfg80211: Updating information on frequency 5220 MHz for a 20 MHz width channel with regulatory rule:
[    7.755448] cfg80211: 5140000 KHz - 5360000 KHz @ 40000 KHz), (N/A mBi, 3000 mBm)
[    7.755450] cfg80211: Updating information on frequency 5240 MHz for a 20 MHz width channel with regulatory rule:
[    7.755452] cfg80211: 5140000 KHz - 5360000 KHz @ 40000 KHz), (N/A mBi, 3000 mBm)
[    7.755454] cfg80211: Updating information on frequency 5260 MHz for a 20 MHz width channel with regulatory rule:
[    7.755456] cfg80211: 5140000 KHz - 5360000 KHz @ 40000 KHz), (N/A mBi, 3000 mBm)
[    7.755458] cfg80211: Updating information on frequency 5280 MHz for a 20 MHz width channel with regulatory rule:
[    7.755460] cfg80211: 5140000 KHz - 5360000 KHz @ 40000 KHz), (N/A mBi, 3000 mBm)
[    7.755462] cfg80211: Updating information on frequency 5300 MHz for a 20 MHz width channel with regulatory rule:
[    7.755465] cfg80211: 5140000 KHz - 5360000 KHz @ 40000 KHz), (N/A mBi, 3000 mBm)
[    7.755466] cfg80211: Updating information on frequency 5320 MHz for a 20 MHz width channel with regulatory rule:
[    7.755469] cfg80211: 5140000 KHz - 5360000 KHz @ 40000 KHz), (N/A mBi, 3000 mBm)
[    7.755471] cfg80211: Disabling freq 5500 MHz as custom regd has no rule that fits a 20 MHz wide channel
[    7.755472] cfg80211: Disabling freq 5520 MHz as custom regd has no rule that fits a 20 MHz wide channel
[    7.755474] cfg80211: Disabling freq 5540 MHz as custom regd has no rule that fits a 20 MHz wide channel
[    7.755476] cfg80211: Disabling freq 5560 MHz as custom regd has no rule that fits a 20 MHz wide channel
[    7.755478] cfg80211: Disabling freq 5580 MHz as custom regd has no rule that fits a 20 MHz wide channel
[    7.755480] cfg80211: Disabling freq 5600 MHz as custom regd has no rule that fits a 20 MHz wide channel
[    7.755481] cfg80211: Disabling freq 5620 MHz as custom regd has no rule that fits a 20 MHz wide channel
[    7.755483] cfg80211: Disabling freq 5640 MHz as custom regd has no rule that fits a 20 MHz wide channel
[    7.755485] cfg80211: Disabling freq 5660 MHz as custom regd has no rule that fits a 20 MHz wide channel
[    7.755487] cfg80211: Disabling freq 5680 MHz as custom regd has no rule that fits a 20 MHz wide channel
[    7.755489] cfg80211: Disabling freq 5700 MHz as custom regd has no rule that fits a 20 MHz wide channel
[    7.755491] cfg80211: Updating information on frequency 5745 MHz for a 20 MHz width channel with regulatory rule:
[    7.755493] cfg80211: 5715000 KHz - 5860000 KHz @ 40000 KHz), (N/A mBi, 3000 mBm)
[    7.755495] cfg80211: Updating information on frequency 5765 MHz for a 20 MHz width channel with regulatory rule:
[    7.755497] cfg80211: 5715000 KHz - 5860000 KHz @ 40000 KHz), (N/A mBi, 3000 mBm)
[    7.755499] cfg80211: Updating information on frequency 5785 MHz for a 20 MHz width channel with regulatory rule:
[    7.755502] cfg80211: 5715000 KHz - 5860000 KHz @ 40000 KHz), (N/A mBi, 3000 mBm)
[    7.755504] cfg80211: Updating information on frequency 5805 MHz for a 20 MHz width channel with regulatory rule:
[    7.755506] cfg80211: 5715000 KHz - 5860000 KHz @ 40000 KHz), (N/A mBi, 3000 mBm)
[    7.755508] cfg80211: Updating information on frequency 5825 MHz for a 20 MHz width channel with regulatory rule:
[    7.755510] cfg80211: 5715000 KHz - 5860000 KHz @ 40000 KHz), (N/A mBi, 3000 mBm)
[    7.756210] cfg80211: Ignoring regulatory request Set by core since the driver requires its own regulatory domain to be set first
[    7.758438] ieee80211 phy2: Selected rate control algorithm 'minstrel_ht'
[    7.762643] cfg80211: Updating information on frequency 2412 MHz for a 20 MHz width channel with regulatory rule:
[    7.762647] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2700 mBm)
[    7.762649] cfg80211: Updating information on frequency 2417 MHz for a 20 MHz width channel with regulatory rule:
[    7.762652] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2700 mBm)
[    7.762654] cfg80211: Updating information on frequency 2422 MHz for a 20 MHz width channel with regulatory rule:
[    7.762656] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2700 mBm)
[    7.762658] cfg80211: Updating information on frequency 2427 MHz for a 20 MHz width channel with regulatory rule:
[    7.762661] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2700 mBm)
[    7.762663] cfg80211: Updating information on frequency 2432 MHz for a 20 MHz width channel with regulatory rule:
[    7.762665] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2700 mBm)
[    7.762667] cfg80211: Updating information on frequency 2437 MHz for a 20 MHz width channel with regulatory rule:
[    7.762669] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2700 mBm)
[    7.762672] cfg80211: Updating information on frequency 2442 MHz for a 20 MHz width channel with regulatory rule:
[    7.762674] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2700 mBm)
[    7.762676] cfg80211: Updating information on frequency 2447 MHz for a 20 MHz width channel with regulatory rule:
[    7.762678] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2700 mBm)
[    7.762680] cfg80211: Updating information on frequency 2452 MHz for a 20 MHz width channel with regulatory rule:
[    7.762683] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2700 mBm)
[    7.762685] cfg80211: Updating information on frequency 2457 MHz for a 20 MHz width channel with regulatory rule:
[    7.762687] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2700 mBm)
[    7.762689] cfg80211: Updating information on frequency 2462 MHz for a 20 MHz width channel with regulatory rule:
[    7.762692] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2700 mBm)
[    7.762694] cfg80211: Disabling freq 2467 MHz
[    7.762695] cfg80211: Disabling freq 2472 MHz
[    7.762697] cfg80211: Disabling freq 2484 MHz
[    7.762699] cfg80211: Disabling freq 5040 MHz
[    7.762701] cfg80211: Disabling freq 5060 MHz
[    7.762702] cfg80211: Disabling freq 5080 MHz
[    7.762704] cfg80211: Updating information on frequency 5180 MHz for a 20 MHz width channel with regulatory rule:
[    7.762707] cfg80211: 5170000 KHz - 5250000 KHz @ 40000 KHz), (300 mBi, 1700 mBm)
[    7.762709] cfg80211: Updating information on frequency 5200 MHz for a 20 MHz width channel with regulatory rule:
[    7.762711] cfg80211: 5170000 KHz - 5250000 KHz @ 40000 KHz), (300 mBi, 1700 mBm)
[    7.762713] cfg80211: Updating information on frequency 5220 MHz for a 20 MHz width channel with regulatory rule:
[    7.762716] cfg80211: 5170000 KHz - 5250000 KHz @ 40000 KHz), (300 mBi, 1700 mBm)
[    7.762718] cfg80211: Updating information on frequency 5240 MHz for a 20 MHz width channel with regulatory rule:
[    7.762720] cfg80211: 5170000 KHz - 5250000 KHz @ 40000 KHz), (300 mBi, 1700 mBm)
[    7.762723] cfg80211: Updating information on frequency 5260 MHz for a 20 MHz width channel with regulatory rule:
[    7.762725] cfg80211: 5250000 KHz - 5330000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    7.762727] cfg80211: Updating information on frequency 5280 MHz for a 20 MHz width channel with regulatory rule:
[    7.762729] cfg80211: 5250000 KHz - 5330000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    7.762732] cfg80211: Updating information on frequency 5300 MHz for a 20 MHz width channel with regulatory rule:
[    7.762734] cfg80211: 5250000 KHz - 5330000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    7.762736] cfg80211: Updating information on frequency 5320 MHz for a 20 MHz width channel with regulatory rule:
[    7.762738] cfg80211: 5250000 KHz - 5330000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    7.762741] cfg80211: Updating information on frequency 5500 MHz for a 20 MHz width channel with regulatory rule:
[    7.762743] cfg80211: 5490000 KHz - 5600000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    7.762745] cfg80211: Updating information on frequency 5520 MHz for a 20 MHz width channel with regulatory rule:
[    7.762747] cfg80211: 5490000 KHz - 5600000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    7.762749] cfg80211: Updating information on frequency 5540 MHz for a 20 MHz width channel with regulatory rule:
[    7.762752] cfg80211: 5490000 KHz - 5600000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    7.762754] cfg80211: Updating information on frequency 5560 MHz for a 20 MHz width channel with regulatory rule:
[    7.762756] cfg80211: 5490000 KHz - 5600000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    7.762758] cfg80211: Updating information on frequency 5580 MHz for a 20 MHz width channel with regulatory rule:
[    7.762761] cfg80211: 5490000 KHz - 5600000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    7.762763] cfg80211: Disabling freq 5600 MHz
[    7.762764] cfg80211: Disabling freq 5620 MHz
[    7.762766] cfg80211: Disabling freq 5640 MHz
[    7.762768] cfg80211: Updating information on frequency 5660 MHz for a 20 MHz width channel with regulatory rule:
[    7.762770] cfg80211: 5650000 KHz - 5710000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    7.762773] cfg80211: Updating information on frequency 5680 MHz for a 20 MHz width channel with regulatory rule:
[    7.762775] cfg80211: 5650000 KHz - 5710000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    7.762777] cfg80211: Updating information on frequency 5700 MHz for a 20 MHz width channel with regulatory rule:
[    7.762779] cfg80211: 5650000 KHz - 5710000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    7.762782] cfg80211: Updating information on frequency 5745 MHz for a 20 MHz width channel with regulatory rule:
[    7.762784] cfg80211: 5735000 KHz - 5835000 KHz @ 40000 KHz), (300 mBi, 3000 mBm)
[    7.762786] cfg80211: Updating information on frequency 5765 MHz for a 20 MHz width channel with regulatory rule:
[    7.762788] cfg80211: 5735000 KHz - 5835000 KHz @ 40000 KHz), (300 mBi, 3000 mBm)
[    7.762790] cfg80211: Updating information on frequency 5785 MHz for a 20 MHz width channel with regulatory rule:
[    7.762793] cfg80211: 5735000 KHz - 5835000 KHz @ 40000 KHz), (300 mBi, 3000 mBm)
[    7.762795] cfg80211: Updating information on frequency 5805 MHz for a 20 MHz width channel with regulatory rule:
[    7.762797] cfg80211: 5735000 KHz - 5835000 KHz @ 40000 KHz), (300 mBi, 3000 mBm)
[    7.762799] cfg80211: Updating information on frequency 5825 MHz for a 20 MHz width channel with regulatory rule:
[    7.762801] cfg80211: 5735000 KHz - 5835000 KHz @ 40000 KHz), (300 mBi, 3000 mBm)
[    7.762929] ath5k: phy2: Atheros AR5213A chip found (MAC: 0x59, PHY: 0x43)
[    7.764453] ath5k: phy2: RF5112B multiband radio found (0x36)
[    7.766319] ath5k 0000:04:00.0: enabling device (0000 -> 0002)
[    7.768087] ath5k 0000:04:00.0: registered as 'phy3'
[    8.235678] ath: EEPROM regdomain: 0x13
[    8.235681] ath: EEPROM indicates we should expect a direct regpair map
[    8.235684] ath: Country alpha2 being used: 00
[    8.235687] ath: Regpair used: 0x13
[    8.235697] cfg80211: Updating information on frequency 2412 MHz for a 20 MHz width channel with regulatory rule:
[    8.235700] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (N/A mBi, 2000 mBm)
[    8.235702] cfg80211: Updating information on frequency 2417 MHz for a 20 MHz width channel with regulatory rule:
[    8.235704] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (N/A mBi, 2000 mBm)
[    8.235706] cfg80211: Updating information on frequency 2422 MHz for a 20 MHz width channel with regulatory rule:
[    8.235708] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (N/A mBi, 2000 mBm)
[    8.235710] cfg80211: Updating information on frequency 2427 MHz for a 20 MHz width channel with regulatory rule:
[    8.235712] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (N/A mBi, 2000 mBm)
[    8.235714] cfg80211: Updating information on frequency 2432 MHz for a 20 MHz width channel with regulatory rule:
[    8.235716] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (N/A mBi, 2000 mBm)
[    8.235718] cfg80211: Updating information on frequency 2437 MHz for a 20 MHz width channel with regulatory rule:
[    8.235721] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (N/A mBi, 2000 mBm)
[    8.235723] cfg80211: Updating information on frequency 2442 MHz for a 20 MHz width channel with regulatory rule:
[    8.235725] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (N/A mBi, 2000 mBm)
[    8.235727] cfg80211: Updating information on frequency 2447 MHz for a 20 MHz width channel with regulatory rule:
[    8.235729] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (N/A mBi, 2000 mBm)
[    8.235731] cfg80211: Updating information on frequency 2452 MHz for a 20 MHz width channel with regulatory rule:
[    8.235733] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (N/A mBi, 2000 mBm)
[    8.235735] cfg80211: Updating information on frequency 2457 MHz for a 20 MHz width channel with regulatory rule:
[    8.235737] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (N/A mBi, 2000 mBm)
[    8.235739] cfg80211: Updating information on frequency 2462 MHz for a 20 MHz width channel with regulatory rule:
[    8.235741] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (N/A mBi, 2000 mBm)
[    8.235743] cfg80211: Disabling freq 2467 MHz as custom regd has no rule that fits a 20 MHz wide channel
[    8.235745] cfg80211: Disabling freq 2472 MHz as custom regd has no rule that fits a 20 MHz wide channel
[    8.235747] cfg80211: Disabling freq 2484 MHz as custom regd has no rule that fits a 20 MHz wide channel
[    8.235749] cfg80211: Disabling freq 5040 MHz as custom regd has no rule that fits a 20 MHz wide channel
[    8.235751] cfg80211: Disabling freq 5060 MHz as custom regd has no rule that fits a 20 MHz wide channel
[    8.235752] cfg80211: Disabling freq 5080 MHz as custom regd has no rule that fits a 20 MHz wide channel
[    8.235754] cfg80211: Updating information on frequency 5180 MHz for a 20 MHz width channel with regulatory rule:
[    8.235757] cfg80211: 5140000 KHz - 5360000 KHz @ 40000 KHz), (N/A mBi, 3000 mBm)
[    8.235759] cfg80211: Updating information on frequency 5200 MHz for a 20 MHz width channel with regulatory rule:
[    8.235761] cfg80211: 5140000 KHz - 5360000 KHz @ 40000 KHz), (N/A mBi, 3000 mBm)
[    8.235763] cfg80211: Updating information on frequency 5220 MHz for a 20 MHz width channel with regulatory rule:
[    8.235765] cfg80211: 5140000 KHz - 5360000 KHz @ 40000 KHz), (N/A mBi, 3000 mBm)
[    8.235767] cfg80211: Updating information on frequency 5240 MHz for a 20 MHz width channel with regulatory rule:
[    8.235769] cfg80211: 5140000 KHz - 5360000 KHz @ 40000 KHz), (N/A mBi, 3000 mBm)
[    8.235771] cfg80211: Updating information on frequency 5260 MHz for a 20 MHz width channel with regulatory rule:
[    8.235773] cfg80211: 5140000 KHz - 5360000 KHz @ 40000 KHz), (N/A mBi, 3000 mBm)
[    8.235775] cfg80211: Updating information on frequency 5280 MHz for a 20 MHz width channel with regulatory rule:
[    8.235777] cfg80211: 5140000 KHz - 5360000 KHz @ 40000 KHz), (N/A mBi, 3000 mBm)
[    8.235779] cfg80211: Updating information on frequency 5300 MHz for a 20 MHz width channel with regulatory rule:
[    8.235781] cfg80211: 5140000 KHz - 5360000 KHz @ 40000 KHz), (N/A mBi, 3000 mBm)
[    8.235783] cfg80211: Updating information on frequency 5320 MHz for a 20 MHz width channel with regulatory rule:
[    8.235785] cfg80211: 5140000 KHz - 5360000 KHz @ 40000 KHz), (N/A mBi, 3000 mBm)
[    8.235787] cfg80211: Disabling freq 5500 MHz as custom regd has no rule that fits a 20 MHz wide channel
[    8.235789] cfg80211: Disabling freq 5520 MHz as custom regd has no rule that fits a 20 MHz wide channel
[    8.235791] cfg80211: Disabling freq 5540 MHz as custom regd has no rule that fits a 20 MHz wide channel
[    8.235793] cfg80211: Disabling freq 5560 MHz as custom regd has no rule that fits a 20 MHz wide channel
[    8.235795] cfg80211: Disabling freq 5580 MHz as custom regd has no rule that fits a 20 MHz wide channel
[    8.235796] cfg80211: Disabling freq 5600 MHz as custom regd has no rule that fits a 20 MHz wide channel
[    8.235798] cfg80211: Disabling freq 5620 MHz as custom regd has no rule that fits a 20 MHz wide channel
[    8.235800] cfg80211: Disabling freq 5640 MHz as custom regd has no rule that fits a 20 MHz wide channel
[    8.235802] cfg80211: Disabling freq 5660 MHz as custom regd has no rule that fits a 20 MHz wide channel
[    8.235804] cfg80211: Disabling freq 5680 MHz as custom regd has no rule that fits a 20 MHz wide channel
[    8.235805] cfg80211: Disabling freq 5700 MHz as custom regd has no rule that fits a 20 MHz wide channel
[    8.235807] cfg80211: Updating information on frequency 5745 MHz for a 20 MHz width channel with regulatory rule:
[    8.235810] cfg80211: 5715000 KHz - 5860000 KHz @ 40000 KHz), (N/A mBi, 3000 mBm)
[    8.235812] cfg80211: Updating information on frequency 5765 MHz for a 20 MHz width channel with regulatory rule:
[    8.235814] cfg80211: 5715000 KHz - 5860000 KHz @ 40000 KHz), (N/A mBi, 3000 mBm)
[    8.235816] cfg80211: Updating information on frequency 5785 MHz for a 20 MHz width channel with regulatory rule:
[    8.235818] cfg80211: 5715000 KHz - 5860000 KHz @ 40000 KHz), (N/A mBi, 3000 mBm)
[    8.235820] cfg80211: Updating information on frequency 5805 MHz for a 20 MHz width channel with regulatory rule:
[    8.235822] cfg80211: 5715000 KHz - 5860000 KHz @ 40000 KHz), (N/A mBi, 3000 mBm)
[    8.235824] cfg80211: Updating information on frequency 5825 MHz for a 20 MHz width channel with regulatory rule:
[    8.235826] cfg80211: 5715000 KHz - 5860000 KHz @ 40000 KHz), (N/A mBi, 3000 mBm)
[    8.236516] cfg80211: Ignoring regulatory request Set by core since the driver requires its own regulatory domain to be set first
[    8.238742] ieee80211 phy3: Selected rate control algorithm 'minstrel_ht'
[    8.242850] cfg80211: Calling CRDA to update world regulatory domain
[    8.244585] ath5k: phy3: Atheros AR5213A chip found (MAC: 0x59, PHY: 0x43)
[    8.246192] ath5k: phy3: RF5112B multiband radio found (0x36)
[    8.257650] cfg80211: Updating information on frequency 2412 MHz for a 20 MHz width channel with regulatory rule:
[    8.257655] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2700 mBm)
[    8.257658] cfg80211: Updating information on frequency 2417 MHz for a 20 MHz width channel with regulatory rule:
[    8.257660] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2700 mBm)
[    8.257662] cfg80211: Updating information on frequency 2422 MHz for a 20 MHz width channel with regulatory rule:
[    8.257665] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2700 mBm)
[    8.257667] cfg80211: Updating information on frequency 2427 MHz for a 20 MHz width channel with regulatory rule:
[    8.257669] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2700 mBm)
[    8.257672] cfg80211: Updating information on frequency 2432 MHz for a 20 MHz width channel with regulatory rule:
[    8.257674] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2700 mBm)
[    8.257676] cfg80211: Updating information on frequency 2437 MHz for a 20 MHz width channel with regulatory rule:
[    8.257678] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2700 mBm)
[    8.257681] cfg80211: Updating information on frequency 2442 MHz for a 20 MHz width channel with regulatory rule:
[    8.257683] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2700 mBm)
[    8.257685] cfg80211: Updating information on frequency 2447 MHz for a 20 MHz width channel with regulatory rule:
[    8.257687] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2700 mBm)
[    8.257690] cfg80211: Updating information on frequency 2452 MHz for a 20 MHz width channel with regulatory rule:
[    8.257692] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2700 mBm)
[    8.257694] cfg80211: Updating information on frequency 2457 MHz for a 20 MHz width channel with regulatory rule:
[    8.257696] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2700 mBm)
[    8.257699] cfg80211: Updating information on frequency 2462 MHz for a 20 MHz width channel with regulatory rule:
[    8.257701] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2700 mBm)
[    8.257703] cfg80211: Disabling freq 2467 MHz
[    8.257705] cfg80211: Disabling freq 2472 MHz
[    8.257707] cfg80211: Disabling freq 2484 MHz
[    8.257709] cfg80211: Disabling freq 5040 MHz
[    8.257710] cfg80211: Disabling freq 5060 MHz
[    8.257712] cfg80211: Disabling freq 5080 MHz
[    8.257714] cfg80211: Updating information on frequency 5180 MHz for a 20 MHz width channel with regulatory rule:
[    8.257717] cfg80211: 5170000 KHz - 5250000 KHz @ 40000 KHz), (300 mBi, 1700 mBm)
[    8.257719] cfg80211: Updating information on frequency 5200 MHz for a 20 MHz width channel with regulatory rule:
[    8.257721] cfg80211: 5170000 KHz - 5250000 KHz @ 40000 KHz), (300 mBi, 1700 mBm)
[    8.257724] cfg80211: Updating information on frequency 5220 MHz for a 20 MHz width channel with regulatory rule:
[    8.257726] cfg80211: 5170000 KHz - 5250000 KHz @ 40000 KHz), (300 mBi, 1700 mBm)
[    8.257728] cfg80211: Updating information on frequency 5240 MHz for a 20 MHz width channel with regulatory rule:
[    8.257730] cfg80211: 5170000 KHz - 5250000 KHz @ 40000 KHz), (300 mBi, 1700 mBm)
[    8.257733] cfg80211: Updating information on frequency 5260 MHz for a 20 MHz width channel with regulatory rule:
[    8.257735] cfg80211: 5250000 KHz - 5330000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    8.257737] cfg80211: Updating information on frequency 5280 MHz for a 20 MHz width channel with regulatory rule:
[    8.257740] cfg80211: 5250000 KHz - 5330000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    8.257742] cfg80211: Updating information on frequency 5300 MHz for a 20 MHz width channel with regulatory rule:
[    8.257744] cfg80211: 5250000 KHz - 5330000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    8.257746] cfg80211: Updating information on frequency 5320 MHz for a 20 MHz width channel with regulatory rule:
[    8.257749] cfg80211: 5250000 KHz - 5330000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    8.257751] cfg80211: Updating information on frequency 5500 MHz for a 20 MHz width channel with regulatory rule:
[    8.257753] cfg80211: 5490000 KHz - 5600000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    8.257755] cfg80211: Updating information on frequency 5520 MHz for a 20 MHz width channel with regulatory rule:
[    8.257758] cfg80211: 5490000 KHz - 5600000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    8.257760] cfg80211: Updating information on frequency 5540 MHz for a 20 MHz width channel with regulatory rule:
[    8.257762] cfg80211: 5490000 KHz - 5600000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    8.257765] cfg80211: Updating information on frequency 5560 MHz for a 20 MHz width channel with regulatory rule:
[    8.257767] cfg80211: 5490000 KHz - 5600000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    8.257770] cfg80211: Updating information on frequency 5580 MHz for a 20 MHz width channel with regulatory rule:
[    8.257772] cfg80211: 5490000 KHz - 5600000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    8.257774] cfg80211: Disabling freq 5600 MHz
[    8.257776] cfg80211: Disabling freq 5620 MHz
[    8.257778] cfg80211: Disabling freq 5640 MHz
[    8.257780] cfg80211: Updating information on frequency 5660 MHz for a 20 MHz width channel with regulatory rule:
[    8.257782] cfg80211: 5650000 KHz - 5710000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    8.257784] cfg80211: Updating information on frequency 5680 MHz for a 20 MHz width channel with regulatory rule:
[    8.257787] cfg80211: 5650000 KHz - 5710000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    8.257789] cfg80211: Updating information on frequency 5700 MHz for a 20 MHz width channel with regulatory rule:
[    8.257791] cfg80211: 5650000 KHz - 5710000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    8.257794] cfg80211: Updating information on frequency 5745 MHz for a 20 MHz width channel with regulatory rule:
[    8.257796] cfg80211: 5735000 KHz - 5835000 KHz @ 40000 KHz), (300 mBi, 3000 mBm)
[    8.257798] cfg80211: Updating information on frequency 5765 MHz for a 20 MHz width channel with regulatory rule:
[    8.257801] cfg80211: 5735000 KHz - 5835000 KHz @ 40000 KHz), (300 mBi, 3000 mBm)
[    8.257803] cfg80211: Updating information on frequency 5785 MHz for a 20 MHz width channel with regulatory rule:
[    8.257805] cfg80211: 5735000 KHz - 5835000 KHz @ 40000 KHz), (300 mBi, 3000 mBm)
[    8.257807] cfg80211: Updating information on frequency 5805 MHz for a 20 MHz width channel with regulatory rule:
[    8.257810] cfg80211: 5735000 KHz - 5835000 KHz @ 40000 KHz), (300 mBi, 3000 mBm)
[    8.257812] cfg80211: Updating information on frequency 5825 MHz for a 20 MHz width channel with regulatory rule:
[    8.257814] cfg80211: 5735000 KHz - 5835000 KHz @ 40000 KHz), (300 mBi, 3000 mBm)
[    8.257824] cfg80211: Updating information on frequency 2412 MHz for a 20 MHz width channel with regulatory rule:
[    8.257826] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2700 mBm)
[    8.257829] cfg80211: Updating information on frequency 2417 MHz for a 20 MHz width channel with regulatory rule:
[    8.257831] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2700 mBm)
[    8.257833] cfg80211: Updating information on frequency 2422 MHz for a 20 MHz width channel with regulatory rule:
[    8.257836] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2700 mBm)
[    8.257838] cfg80211: Updating information on frequency 2427 MHz for a 20 MHz width channel with regulatory rule:
[    8.257840] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2700 mBm)
[    8.257843] cfg80211: Updating information on frequency 2432 MHz for a 20 MHz width channel with regulatory rule:
[    8.257845] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2700 mBm)
[    8.257847] cfg80211: Updating information on frequency 2437 MHz for a 20 MHz width channel with regulatory rule:
[    8.257849] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2700 mBm)
[    8.257852] cfg80211: Updating information on frequency 2442 MHz for a 20 MHz width channel with regulatory rule:
[    8.257854] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2700 mBm)
[    8.257857] cfg80211: Updating information on frequency 2447 MHz for a 20 MHz width channel with regulatory rule:
[    8.257859] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2700 mBm)
[    8.257861] cfg80211: Updating information on frequency 2452 MHz for a 20 MHz width channel with regulatory rule:
[    8.257863] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2700 mBm)
[    8.257866] cfg80211: Updating information on frequency 2457 MHz for a 20 MHz width channel with regulatory rule:
[    8.257868] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2700 mBm)
[    8.257870] cfg80211: Updating information on frequency 2462 MHz for a 20 MHz width channel with regulatory rule:
[    8.257873] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2700 mBm)
[    8.257875] cfg80211: Disabling freq 2467 MHz
[    8.257877] cfg80211: Disabling freq 2472 MHz
[    8.257878] cfg80211: Disabling freq 2484 MHz
[    8.257880] cfg80211: Disabling freq 5040 MHz
[    8.257882] cfg80211: Disabling freq 5060 MHz
[    8.257884] cfg80211: Disabling freq 5080 MHz
[    8.257886] cfg80211: Updating information on frequency 5180 MHz for a 20 MHz width channel with regulatory rule:
[    8.257888] cfg80211: 5170000 KHz - 5250000 KHz @ 40000 KHz), (300 mBi, 1700 mBm)
[    8.257890] cfg80211: Updating information on frequency 5200 MHz for a 20 MHz width channel with regulatory rule:
[    8.257893] cfg80211: 5170000 KHz - 5250000 KHz @ 40000 KHz), (300 mBi, 1700 mBm)
[    8.257895] cfg80211: Updating information on frequency 5220 MHz for a 20 MHz width channel with regulatory rule:
[    8.257897] cfg80211: 5170000 KHz - 5250000 KHz @ 40000 KHz), (300 mBi, 1700 mBm)
[    8.257900] cfg80211: Updating information on frequency 5240 MHz for a 20 MHz width channel with regulatory rule:
[    8.257902] cfg80211: 5170000 KHz - 5250000 KHz @ 40000 KHz), (300 mBi, 1700 mBm)
[    8.257904] cfg80211: Updating information on frequency 5260 MHz for a 20 MHz width channel with regulatory rule:
[    8.257907] cfg80211: 5250000 KHz - 5330000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    8.257909] cfg80211: Updating information on frequency 5280 MHz for a 20 MHz width channel with regulatory rule:
[    8.257911] cfg80211: 5250000 KHz - 5330000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    8.257914] cfg80211: Updating information on frequency 5300 MHz for a 20 MHz width channel with regulatory rule:
[    8.257916] cfg80211: 5250000 KHz - 5330000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    8.257918] cfg80211: Updating information on frequency 5320 MHz for a 20 MHz width channel with regulatory rule:
[    8.257920] cfg80211: 5250000 KHz - 5330000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    8.257923] cfg80211: Updating information on frequency 5500 MHz for a 20 MHz width channel with regulatory rule:
[    8.257925] cfg80211: 5490000 KHz - 5600000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    8.257927] cfg80211: Updating information on frequency 5520 MHz for a 20 MHz width channel with regulatory rule:
[    8.257930] cfg80211: 5490000 KHz - 5600000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    8.257932] cfg80211: Updating information on frequency 5540 MHz for a 20 MHz width channel with regulatory rule:
[    8.257934] cfg80211: 5490000 KHz - 5600000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    8.257936] cfg80211: Updating information on frequency 5560 MHz for a 20 MHz width channel with regulatory rule:
[    8.257939] cfg80211: 5490000 KHz - 5600000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    8.257941] cfg80211: Updating information on frequency 5580 MHz for a 20 MHz width channel with regulatory rule:
[    8.257943] cfg80211: 5490000 KHz - 5600000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    8.257945] cfg80211: Disabling freq 5600 MHz
[    8.257947] cfg80211: Disabling freq 5620 MHz
[    8.257949] cfg80211: Disabling freq 5640 MHz
[    8.257951] cfg80211: Updating information on frequency 5660 MHz for a 20 MHz width channel with regulatory rule:
[    8.257953] cfg80211: 5650000 KHz - 5710000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    8.257956] cfg80211: Updating information on frequency 5680 MHz for a 20 MHz width channel with regulatory rule:
[    8.257958] cfg80211: 5650000 KHz - 5710000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    8.257960] cfg80211: Updating information on frequency 5700 MHz for a 20 MHz width channel with regulatory rule:
[    8.257962] cfg80211: 5650000 KHz - 5710000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    8.257965] cfg80211: Updating information on frequency 5745 MHz for a 20 MHz width channel with regulatory rule:
[    8.257967] cfg80211: 5735000 KHz - 5835000 KHz @ 40000 KHz), (300 mBi, 3000 mBm)
[    8.257969] cfg80211: Updating information on frequency 5765 MHz for a 20 MHz width channel with regulatory rule:
[    8.257971] cfg80211: 5735000 KHz - 5835000 KHz @ 40000 KHz), (300 mBi, 3000 mBm)
[    8.257974] cfg80211: Updating information on frequency 5785 MHz for a 20 MHz width channel with regulatory rule:
[    8.257976] cfg80211: 5735000 KHz - 5835000 KHz @ 40000 KHz), (300 mBi, 3000 mBm)
[    8.257978] cfg80211: Updating information on frequency 5805 MHz for a 20 MHz width channel with regulatory rule:
[    8.257981] cfg80211: 5735000 KHz - 5835000 KHz @ 40000 KHz), (300 mBi, 3000 mBm)
[    8.257983] cfg80211: Updating information on frequency 5825 MHz for a 20 MHz width channel with regulatory rule:
[    8.257985] cfg80211: 5735000 KHz - 5835000 KHz @ 40000 KHz), (300 mBi, 3000 mBm)
[    8.257992] cfg80211: Updating information on frequency 2412 MHz for a 20 MHz width channel with regulatory rule:
[    8.257995] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2700 mBm)
[    8.257997] cfg80211: Updating information on frequency 2417 MHz for a 20 MHz width channel with regulatory rule:
[    8.258010] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2700 mBm)
[    8.258013] cfg80211: Updating information on frequency 2422 MHz for a 20 MHz width channel with regulatory rule:
[    8.258015] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2700 mBm)
[    8.258018] cfg80211: Updating information on frequency 2427 MHz for a 20 MHz width channel with regulatory rule:
[    8.258020] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2700 mBm)
[    8.258022] cfg80211: Updating information on frequency 2432 MHz for a 20 MHz width channel with regulatory rule:
[    8.258024] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2700 mBm)
[    8.258027] cfg80211: Updating information on frequency 2437 MHz for a 20 MHz width channel with regulatory rule:
[    8.258029] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2700 mBm)
[    8.258031] cfg80211: Updating information on frequency 2442 MHz for a 20 MHz width channel with regulatory rule:
[    8.258033] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2700 mBm)
[    8.258036] cfg80211: Updating information on frequency 2447 MHz for a 20 MHz width channel with regulatory rule:
[    8.258038] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2700 mBm)
[    8.258040] cfg80211: Updating information on frequency 2452 MHz for a 20 MHz width channel with regulatory rule:
[    8.258043] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2700 mBm)
[    8.258045] cfg80211: Updating information on frequency 2457 MHz for a 20 MHz width channel with regulatory rule:
[    8.258047] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2700 mBm)
[    8.258049] cfg80211: Updating information on frequency 2462 MHz for a 20 MHz width channel with regulatory rule:
[    8.258052] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2700 mBm)
[    8.258054] cfg80211: Disabling freq 2467 MHz
[    8.258056] cfg80211: Disabling freq 2472 MHz
[    8.258058] cfg80211: Disabling freq 2484 MHz
[    8.258059] cfg80211: Disabling freq 5040 MHz
[    8.258061] cfg80211: Disabling freq 5060 MHz
[    8.258063] cfg80211: Disabling freq 5080 MHz
[    8.258065] cfg80211: Updating information on frequency 5180 MHz for a 20 MHz width channel with regulatory rule:
[    8.258068] cfg80211: 5170000 KHz - 5250000 KHz @ 40000 KHz), (300 mBi, 1700 mBm)
[    8.258070] cfg80211: Updating information on frequency 5200 MHz for a 20 MHz width channel with regulatory rule:
[    8.258072] cfg80211: 5170000 KHz - 5250000 KHz @ 40000 KHz), (300 mBi, 1700 mBm)
[    8.258074] cfg80211: Updating information on frequency 5220 MHz for a 20 MHz width channel with regulatory rule:
[    8.258077] cfg80211: 5170000 KHz - 5250000 KHz @ 40000 KHz), (300 mBi, 1700 mBm)
[    8.258079] cfg80211: Updating information on frequency 5240 MHz for a 20 MHz width channel with regulatory rule:
[    8.258081] cfg80211: 5170000 KHz - 5250000 KHz @ 40000 KHz), (300 mBi, 1700 mBm)
[    8.258083] cfg80211: Updating information on frequency 5260 MHz for a 20 MHz width channel with regulatory rule:
[    8.258086] cfg80211: 5250000 KHz - 5330000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    8.258088] cfg80211: Updating information on frequency 5280 MHz for a 20 MHz width channel with regulatory rule:
[    8.258090] cfg80211: 5250000 KHz - 5330000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    8.258092] cfg80211: Updating information on frequency 5300 MHz for a 20 MHz width channel with regulatory rule:
[    8.258095] cfg80211: 5250000 KHz - 5330000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    8.258097] cfg80211: Updating information on frequency 5320 MHz for a 20 MHz width channel with regulatory rule:
[    8.258099] cfg80211: 5250000 KHz - 5330000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    8.258101] cfg80211: Updating information on frequency 5500 MHz for a 20 MHz width channel with regulatory rule:
[    8.258104] cfg80211: 5490000 KHz - 5600000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    8.258106] cfg80211: Updating information on frequency 5520 MHz for a 20 MHz width channel with regulatory rule:
[    8.258108] cfg80211: 5490000 KHz - 5600000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    8.258111] cfg80211: Updating information on frequency 5540 MHz for a 20 MHz width channel with regulatory rule:
[    8.258113] cfg80211: 5490000 KHz - 5600000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    8.258115] cfg80211: Updating information on frequency 5560 MHz for a 20 MHz width channel with regulatory rule:
[    8.258118] cfg80211: 5490000 KHz - 5600000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    8.258120] cfg80211: Updating information on frequency 5580 MHz for a 20 MHz width channel with regulatory rule:
[    8.258122] cfg80211: 5490000 KHz - 5600000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    8.258124] cfg80211: Disabling freq 5600 MHz
[    8.258126] cfg80211: Disabling freq 5620 MHz
[    8.258128] cfg80211: Disabling freq 5640 MHz
[    8.258130] cfg80211: Updating information on frequency 5660 MHz for a 20 MHz width channel with regulatory rule:
[    8.258132] cfg80211: 5650000 KHz - 5710000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    8.258135] cfg80211: Updating information on frequency 5680 MHz for a 20 MHz width channel with regulatory rule:
[    8.258137] cfg80211: 5650000 KHz - 5710000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    8.258139] cfg80211: Updating information on frequency 5700 MHz for a 20 MHz width channel with regulatory rule:
[    8.258142] cfg80211: 5650000 KHz - 5710000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    8.258144] cfg80211: Updating information on frequency 5745 MHz for a 20 MHz width channel with regulatory rule:
[    8.258146] cfg80211: 5735000 KHz - 5835000 KHz @ 40000 KHz), (300 mBi, 3000 mBm)
[    8.258149] cfg80211: Updating information on frequency 5765 MHz for a 20 MHz width channel with regulatory rule:
[    8.258151] cfg80211: 5735000 KHz - 5835000 KHz @ 40000 KHz), (300 mBi, 3000 mBm)
[    8.258153] cfg80211: Updating information on frequency 5785 MHz for a 20 MHz width channel with regulatory rule:
[    8.258156] cfg80211: 5735000 KHz - 5835000 KHz @ 40000 KHz), (300 mBi, 3000 mBm)
[    8.258158] cfg80211: Updating information on frequency 5805 MHz for a 20 MHz width channel with regulatory rule:
[    8.258161] cfg80211: 5735000 KHz - 5835000 KHz @ 40000 KHz), (300 mBi, 3000 mBm)
[    8.258163] cfg80211: Updating information on frequency 5825 MHz for a 20 MHz width channel with regulatory rule:
[    8.258165] cfg80211: 5735000 KHz - 5835000 KHz @ 40000 KHz), (300 mBi, 3000 mBm)
[    8.258172] cfg80211: Updating information on frequency 2412 MHz for a 20 MHz width channel with regulatory rule:
[    8.258175] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2700 mBm)
[    8.258177] cfg80211: Updating information on frequency 2417 MHz for a 20 MHz width channel with regulatory rule:
[    8.258179] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2700 mBm)
[    8.258182] cfg80211: Updating information on frequency 2422 MHz for a 20 MHz width channel with regulatory rule:
[    8.258184] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2700 mBm)
[    8.258186] cfg80211: Updating information on frequency 2427 MHz for a 20 MHz width channel with regulatory rule:
[    8.258188] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2700 mBm)
[    8.258191] cfg80211: Updating information on frequency 2432 MHz for a 20 MHz width channel with regulatory rule:
[    8.258193] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2700 mBm)
[    8.258195] cfg80211: Updating information on frequency 2437 MHz for a 20 MHz width channel with regulatory rule:
[    8.258198] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2700 mBm)
[    8.258200] cfg80211: Updating information on frequency 2442 MHz for a 20 MHz width channel with regulatory rule:
[    8.258202] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2700 mBm)
[    8.258204] cfg80211: Updating information on frequency 2447 MHz for a 20 MHz width channel with regulatory rule:
[    8.258207] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2700 mBm)
[    8.258209] cfg80211: Updating information on frequency 2452 MHz for a 20 MHz width channel with regulatory rule:
[    8.258211] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2700 mBm)
[    8.258214] cfg80211: Updating information on frequency 2457 MHz for a 20 MHz width channel with regulatory rule:
[    8.258216] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2700 mBm)
[    8.258218] cfg80211: Updating information on frequency 2462 MHz for a 20 MHz width channel with regulatory rule:
[    8.258221] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2700 mBm)
[    8.258223] cfg80211: Disabling freq 2467 MHz
[    8.258225] cfg80211: Disabling freq 2472 MHz
[    8.258226] cfg80211: Disabling freq 2484 MHz
[    8.258228] cfg80211: Disabling freq 5040 MHz
[    8.258230] cfg80211: Disabling freq 5060 MHz
[    8.258232] cfg80211: Disabling freq 5080 MHz
[    8.258234] cfg80211: Updating information on frequency 5180 MHz for a 20 MHz width channel with regulatory rule:
[    8.258236] cfg80211: 5170000 KHz - 5250000 KHz @ 40000 KHz), (300 mBi, 1700 mBm)
[    8.258238] cfg80211: Updating information on frequency 5200 MHz for a 20 MHz width channel with regulatory rule:
[    8.258240] cfg80211: 5170000 KHz - 5250000 KHz @ 40000 KHz), (300 mBi, 1700 mBm)
[    8.258243] cfg80211: Updating information on frequency 5220 MHz for a 20 MHz width channel with regulatory rule:
[    8.258245] cfg80211: 5170000 KHz - 5250000 KHz @ 40000 KHz), (300 mBi, 1700 mBm)
[    8.258247] cfg80211: Updating information on frequency 5240 MHz for a 20 MHz width channel with regulatory rule:
[    8.258250] cfg80211: 5170000 KHz - 5250000 KHz @ 40000 KHz), (300 mBi, 1700 mBm)
[    8.258252] cfg80211: Updating information on frequency 5260 MHz for a 20 MHz width channel with regulatory rule:
[    8.258254] cfg80211: 5250000 KHz - 5330000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    8.258257] cfg80211: Updating information on frequency 5280 MHz for a 20 MHz width channel with regulatory rule:
[    8.258259] cfg80211: 5250000 KHz - 5330000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    8.258262] cfg80211: Updating information on frequency 5300 MHz for a 20 MHz width channel with regulatory rule:
[    8.258264] cfg80211: 5250000 KHz - 5330000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    8.258266] cfg80211: Updating information on frequency 5320 MHz for a 20 MHz width channel with regulatory rule:
[    8.258269] cfg80211: 5250000 KHz - 5330000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    8.258271] cfg80211: Updating information on frequency 5500 MHz for a 20 MHz width channel with regulatory rule:
[    8.258273] cfg80211: 5490000 KHz - 5600000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    8.258276] cfg80211: Updating information on frequency 5520 MHz for a 20 MHz width channel with regulatory rule:
[    8.258278] cfg80211: 5490000 KHz - 5600000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    8.258280] cfg80211: Updating information on frequency 5540 MHz for a 20 MHz width channel with regulatory rule:
[    8.258283] cfg80211: 5490000 KHz - 5600000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    8.258285] cfg80211: Updating information on frequency 5560 MHz for a 20 MHz width channel with regulatory rule:
[    8.258287] cfg80211: 5490000 KHz - 5600000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    8.258290] cfg80211: Updating information on frequency 5580 MHz for a 20 MHz width channel with regulatory rule:
[    8.258292] cfg80211: 5490000 KHz - 5600000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    8.258294] cfg80211: Disabling freq 5600 MHz
[    8.258296] cfg80211: Disabling freq 5620 MHz
[    8.258298] cfg80211: Disabling freq 5640 MHz
[    8.258300] cfg80211: Updating information on frequency 5660 MHz for a 20 MHz width channel with regulatory rule:
[    8.258302] cfg80211: 5650000 KHz - 5710000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    8.258304] cfg80211: Updating information on frequency 5680 MHz for a 20 MHz width channel with regulatory rule:
[    8.258307] cfg80211: 5650000 KHz - 5710000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    8.258309] cfg80211: Updating information on frequency 5700 MHz for a 20 MHz width channel with regulatory rule:
[    8.258311] cfg80211: 5650000 KHz - 5710000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    8.258313] cfg80211: Updating information on frequency 5745 MHz for a 20 MHz width channel with regulatory rule:
[    8.258316] cfg80211: 5735000 KHz - 5835000 KHz @ 40000 KHz), (300 mBi, 3000 mBm)
[    8.258318] cfg80211: Updating information on frequency 5765 MHz for a 20 MHz width channel with regulatory rule:
[    8.258320] cfg80211: 5735000 KHz - 5835000 KHz @ 40000 KHz), (300 mBi, 3000 mBm)
[    8.258322] cfg80211: Updating information on frequency 5785 MHz for a 20 MHz width channel with regulatory rule:
[    8.258325] cfg80211: 5735000 KHz - 5835000 KHz @ 40000 KHz), (300 mBi, 3000 mBm)
[    8.258327] cfg80211: Updating information on frequency 5805 MHz for a 20 MHz width channel with regulatory rule:
[    8.258329] cfg80211: 5735000 KHz - 5835000 KHz @ 40000 KHz), (300 mBi, 3000 mBm)
[    8.258331] cfg80211: Updating information on frequency 5825 MHz for a 20 MHz width channel with regulatory rule:
[    8.258334] cfg80211: 5735000 KHz - 5835000 KHz @ 40000 KHz), (300 mBi, 3000 mBm)
[    8.258340] cfg80211: World regulatory domain updated:
[    8.260032] cfg80211:   (start_freq - end_freq @ bandwidth), (max_antenna_gain, max_eirp)
[    8.261749] cfg80211:   (2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    8.263474] cfg80211:   (2457000 KHz - 2482000 KHz @ 20000 KHz), (300 mBi, 2000 mBm)
[    8.265168] cfg80211:   (2474000 KHz - 2494000 KHz @ 20000 KHz), (300 mBi, 2000 mBm)
[    8.266837] cfg80211:   (5170000 KHz - 5250000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    8.268492] cfg80211:   (5735000 KHz - 5835000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    8.293994] cfg80211: Calling CRDA for country: US
[    8.313532] cfg80211: Updating information on frequency 2412 MHz for a 20 MHz width channel with regulatory rule:
[    8.313537] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2700 mBm)
[    8.313540] cfg80211: Updating information on frequency 2417 MHz for a 20 MHz width channel with regulatory rule:
[    8.313542] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2700 mBm)
[    8.313545] cfg80211: Updating information on frequency 2422 MHz for a 20 MHz width channel with regulatory rule:
[    8.313547] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2700 mBm)
[    8.313549] cfg80211: Updating information on frequency 2427 MHz for a 20 MHz width channel with regulatory rule:
[    8.313551] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2700 mBm)
[    8.313553] cfg80211: Updating information on frequency 2432 MHz for a 20 MHz width channel with regulatory rule:
[    8.313556] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2700 mBm)
[    8.313558] cfg80211: Updating information on frequency 2437 MHz for a 20 MHz width channel with regulatory rule:
[    8.313560] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2700 mBm)
[    8.313562] cfg80211: Updating information on frequency 2442 MHz for a 20 MHz width channel with regulatory rule:
[    8.313564] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2700 mBm)
[    8.313566] cfg80211: Updating information on frequency 2447 MHz for a 20 MHz width channel with regulatory rule:
[    8.313569] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2700 mBm)
[    8.313571] cfg80211: Updating information on frequency 2452 MHz for a 20 MHz width channel with regulatory rule:
[    8.313573] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2700 mBm)
[    8.313575] cfg80211: Updating information on frequency 2457 MHz for a 20 MHz width channel with regulatory rule:
[    8.313577] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2700 mBm)
[    8.313579] cfg80211: Updating information on frequency 2462 MHz for a 20 MHz width channel with regulatory rule:
[    8.313582] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2700 mBm)
[    8.313584] cfg80211: Disabling freq 2467 MHz
[    8.313585] cfg80211: Disabling freq 2472 MHz
[    8.313587] cfg80211: Disabling freq 2484 MHz
[    8.313589] cfg80211: Disabling freq 5040 MHz
[    8.313590] cfg80211: Disabling freq 5060 MHz
[    8.313592] cfg80211: Disabling freq 5080 MHz
[    8.313594] cfg80211: Updating information on frequency 5180 MHz for a 20 MHz width channel with regulatory rule:
[    8.313596] cfg80211: 5170000 KHz - 5250000 KHz @ 40000 KHz), (300 mBi, 1700 mBm)
[    8.313598] cfg80211: Updating information on frequency 5200 MHz for a 20 MHz width channel with regulatory rule:
[    8.313600] cfg80211: 5170000 KHz - 5250000 KHz @ 40000 KHz), (300 mBi, 1700 mBm)
[    8.313602] cfg80211: Updating information on frequency 5220 MHz for a 20 MHz width channel with regulatory rule:
[    8.313605] cfg80211: 5170000 KHz - 5250000 KHz @ 40000 KHz), (300 mBi, 1700 mBm)
[    8.313607] cfg80211: Updating information on frequency 5240 MHz for a 20 MHz width channel with regulatory rule:
[    8.313609] cfg80211: 5170000 KHz - 5250000 KHz @ 40000 KHz), (300 mBi, 1700 mBm)
[    8.313611] cfg80211: Updating information on frequency 5260 MHz for a 20 MHz width channel with regulatory rule:
[    8.313614] cfg80211: 5250000 KHz - 5330000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    8.313616] cfg80211: Updating information on frequency 5280 MHz for a 20 MHz width channel with regulatory rule:
[    8.313618] cfg80211: 5250000 KHz - 5330000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    8.313620] cfg80211: Updating information on frequency 5300 MHz for a 20 MHz width channel with regulatory rule:
[    8.313622] cfg80211: 5250000 KHz - 5330000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    8.313625] cfg80211: Updating information on frequency 5320 MHz for a 20 MHz width channel with regulatory rule:
[    8.313627] cfg80211: 5250000 KHz - 5330000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    8.313629] cfg80211: Updating information on frequency 5500 MHz for a 20 MHz width channel with regulatory rule:
[    8.313631] cfg80211: 5490000 KHz - 5600000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    8.313633] cfg80211: Updating information on frequency 5520 MHz for a 20 MHz width channel with regulatory rule:
[    8.313636] cfg80211: 5490000 KHz - 5600000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    8.313638] cfg80211: Updating information on frequency 5540 MHz for a 20 MHz width channel with regulatory rule:
[    8.313640] cfg80211: 5490000 KHz - 5600000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    8.313642] cfg80211: Updating information on frequency 5560 MHz for a 20 MHz width channel with regulatory rule:
[    8.313644] cfg80211: 5490000 KHz - 5600000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    8.313647] cfg80211: Updating information on frequency 5580 MHz for a 20 MHz width channel with regulatory rule:
[    8.313649] cfg80211: 5490000 KHz - 5600000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    8.313651] cfg80211: Disabling freq 5600 MHz
[    8.313652] cfg80211: Disabling freq 5620 MHz
[    8.313654] cfg80211: Disabling freq 5640 MHz
[    8.313656] cfg80211: Updating information on frequency 5660 MHz for a 20 MHz width channel with regulatory rule:
[    8.313658] cfg80211: 5650000 KHz - 5710000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    8.313660] cfg80211: Updating information on frequency 5680 MHz for a 20 MHz width channel with regulatory rule:
[    8.313663] cfg80211: 5650000 KHz - 5710000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    8.313665] cfg80211: Updating information on frequency 5700 MHz for a 20 MHz width channel with regulatory rule:
[    8.313667] cfg80211: 5650000 KHz - 5710000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    8.313669] cfg80211: Updating information on frequency 5745 MHz for a 20 MHz width channel with regulatory rule:
[    8.313671] cfg80211: 5735000 KHz - 5835000 KHz @ 40000 KHz), (300 mBi, 3000 mBm)
[    8.313673] cfg80211: Updating information on frequency 5765 MHz for a 20 MHz width channel with regulatory rule:
[    8.313676] cfg80211: 5735000 KHz - 5835000 KHz @ 40000 KHz), (300 mBi, 3000 mBm)
[    8.313678] cfg80211: Updating information on frequency 5785 MHz for a 20 MHz width channel with regulatory rule:
[    8.313680] cfg80211: 5735000 KHz - 5835000 KHz @ 40000 KHz), (300 mBi, 3000 mBm)
[    8.313682] cfg80211: Updating information on frequency 5805 MHz for a 20 MHz width channel with regulatory rule:
[    8.313684] cfg80211: 5735000 KHz - 5835000 KHz @ 40000 KHz), (300 mBi, 3000 mBm)
[    8.313686] cfg80211: Updating information on frequency 5825 MHz for a 20 MHz width channel with regulatory rule:
[    8.313689] cfg80211: 5735000 KHz - 5835000 KHz @ 40000 KHz), (300 mBi, 3000 mBm)
[    8.313697] cfg80211: Updating information on frequency 2412 MHz for a 20 MHz width channel with regulatory rule:
[    8.313699] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2700 mBm)
[    8.313701] cfg80211: Updating information on frequency 2417 MHz for a 20 MHz width channel with regulatory rule:
[    8.313704] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2700 mBm)
[    8.313706] cfg80211: Updating information on frequency 2422 MHz for a 20 MHz width channel with regulatory rule:
[    8.313708] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2700 mBm)
[    8.313710] cfg80211: Updating information on frequency 2427 MHz for a 20 MHz width channel with regulatory rule:
[    8.313712] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2700 mBm)
[    8.313714] cfg80211: Updating information on frequency 2432 MHz for a 20 MHz width channel with regulatory rule:
[    8.313717] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2700 mBm)
[    8.313719] cfg80211: Updating information on frequency 2437 MHz for a 20 MHz width channel with regulatory rule:
[    8.313721] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2700 mBm)
[    8.313723] cfg80211: Updating information on frequency 2442 MHz for a 20 MHz width channel with regulatory rule:
[    8.313725] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2700 mBm)
[    8.313727] cfg80211: Updating information on frequency 2447 MHz for a 20 MHz width channel with regulatory rule:
[    8.313730] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2700 mBm)
[    8.313732] cfg80211: Updating information on frequency 2452 MHz for a 20 MHz width channel with regulatory rule:
[    8.313734] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2700 mBm)
[    8.313736] cfg80211: Updating information on frequency 2457 MHz for a 20 MHz width channel with regulatory rule:
[    8.313738] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2700 mBm)
[    8.313740] cfg80211: Updating information on frequency 2462 MHz for a 20 MHz width channel with regulatory rule:
[    8.313742] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2700 mBm)
[    8.313744] cfg80211: Disabling freq 2467 MHz
[    8.313746] cfg80211: Disabling freq 2472 MHz
[    8.313748] cfg80211: Disabling freq 2484 MHz
[    8.313749] cfg80211: Disabling freq 5040 MHz
[    8.313751] cfg80211: Disabling freq 5060 MHz
[    8.313752] cfg80211: Disabling freq 5080 MHz
[    8.313754] cfg80211: Updating information on frequency 5180 MHz for a 20 MHz width channel with regulatory rule:
[    8.313757] cfg80211: 5170000 KHz - 5250000 KHz @ 40000 KHz), (300 mBi, 1700 mBm)
[    8.313759] cfg80211: Updating information on frequency 5200 MHz for a 20 MHz width channel with regulatory rule:
[    8.313761] cfg80211: 5170000 KHz - 5250000 KHz @ 40000 KHz), (300 mBi, 1700 mBm)
[    8.313763] cfg80211: Updating information on frequency 5220 MHz for a 20 MHz width channel with regulatory rule:
[    8.313765] cfg80211: 5170000 KHz - 5250000 KHz @ 40000 KHz), (300 mBi, 1700 mBm)
[    8.313768] cfg80211: Updating information on frequency 5240 MHz for a 20 MHz width channel with regulatory rule:
[    8.313770] cfg80211: 5170000 KHz - 5250000 KHz @ 40000 KHz), (300 mBi, 1700 mBm)
[    8.313772] cfg80211: Updating information on frequency 5260 MHz for a 20 MHz width channel with regulatory rule:
[    8.313774] cfg80211: 5250000 KHz - 5330000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    8.313777] cfg80211: Updating information on frequency 5280 MHz for a 20 MHz width channel with regulatory rule:
[    8.313779] cfg80211: 5250000 KHz - 5330000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    8.313781] cfg80211: Updating information on frequency 5300 MHz for a 20 MHz width channel with regulatory rule:
[    8.313783] cfg80211: 5250000 KHz - 5330000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    8.313785] cfg80211: Updating information on frequency 5320 MHz for a 20 MHz width channel with regulatory rule:
[    8.313787] cfg80211: 5250000 KHz - 5330000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    8.313790] cfg80211: Updating information on frequency 5500 MHz for a 20 MHz width channel with regulatory rule:
[    8.313792] cfg80211: 5490000 KHz - 5600000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    8.313794] cfg80211: Updating information on frequency 5520 MHz for a 20 MHz width channel with regulatory rule:
[    8.313796] cfg80211: 5490000 KHz - 5600000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    8.313798] cfg80211: Updating information on frequency 5540 MHz for a 20 MHz width channel with regulatory rule:
[    8.313801] cfg80211: 5490000 KHz - 5600000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    8.313803] cfg80211: Updating information on frequency 5560 MHz for a 20 MHz width channel with regulatory rule:
[    8.313805] cfg80211: 5490000 KHz - 5600000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    8.313807] cfg80211: Updating information on frequency 5580 MHz for a 20 MHz width channel with regulatory rule:
[    8.313809] cfg80211: 5490000 KHz - 5600000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    8.313811] cfg80211: Disabling freq 5600 MHz
[    8.313813] cfg80211: Disabling freq 5620 MHz
[    8.313814] cfg80211: Disabling freq 5640 MHz
[    8.313816] cfg80211: Updating information on frequency 5660 MHz for a 20 MHz width channel with regulatory rule:
[    8.313819] cfg80211: 5650000 KHz - 5710000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    8.313821] cfg80211: Updating information on frequency 5680 MHz for a 20 MHz width channel with regulatory rule:
[    8.313823] cfg80211: 5650000 KHz - 5710000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    8.313825] cfg80211: Updating information on frequency 5700 MHz for a 20 MHz width channel with regulatory rule:
[    8.313827] cfg80211: 5650000 KHz - 5710000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    8.313830] cfg80211: Updating information on frequency 5745 MHz for a 20 MHz width channel with regulatory rule:
[    8.313832] cfg80211: 5735000 KHz - 5835000 KHz @ 40000 KHz), (300 mBi, 3000 mBm)
[    8.313834] cfg80211: Updating information on frequency 5765 MHz for a 20 MHz width channel with regulatory rule:
[    8.313836] cfg80211: 5735000 KHz - 5835000 KHz @ 40000 KHz), (300 mBi, 3000 mBm)
[    8.313839] cfg80211: Updating information on frequency 5785 MHz for a 20 MHz width channel with regulatory rule:
[    8.313841] cfg80211: 5735000 KHz - 5835000 KHz @ 40000 KHz), (300 mBi, 3000 mBm)
[    8.313843] cfg80211: Updating information on frequency 5805 MHz for a 20 MHz width channel with regulatory rule:
[    8.313845] cfg80211: 5735000 KHz - 5835000 KHz @ 40000 KHz), (300 mBi, 3000 mBm)
[    8.313847] cfg80211: Updating information on frequency 5825 MHz for a 20 MHz width channel with regulatory rule:
[    8.313850] cfg80211: 5735000 KHz - 5835000 KHz @ 40000 KHz), (300 mBi, 3000 mBm)
[    8.313857] cfg80211: Updating information on frequency 2412 MHz for a 20 MHz width channel with regulatory rule:
[    8.313859] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2700 mBm)
[    8.313861] cfg80211: Updating information on frequency 2417 MHz for a 20 MHz width channel with regulatory rule:
[    8.313863] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2700 mBm)
[    8.313866] cfg80211: Updating information on frequency 2422 MHz for a 20 MHz width channel with regulatory rule:
[    8.313868] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2700 mBm)
[    8.313870] cfg80211: Updating information on frequency 2427 MHz for a 20 MHz width channel with regulatory rule:
[    8.313872] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2700 mBm)
[    8.313874] cfg80211: Updating information on frequency 2432 MHz for a 20 MHz width channel with regulatory rule:
[    8.313877] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2700 mBm)
[    8.313879] cfg80211: Updating information on frequency 2437 MHz for a 20 MHz width channel with regulatory rule:
[    8.313881] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2700 mBm)
[    8.313883] cfg80211: Updating information on frequency 2442 MHz for a 20 MHz width channel with regulatory rule:
[    8.313886] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2700 mBm)
[    8.313888] cfg80211: Updating information on frequency 2447 MHz for a 20 MHz width channel with regulatory rule:
[    8.313890] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2700 mBm)
[    8.313892] cfg80211: Updating information on frequency 2452 MHz for a 20 MHz width channel with regulatory rule:
[    8.313894] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2700 mBm)
[    8.313897] cfg80211: Updating information on frequency 2457 MHz for a 20 MHz width channel with regulatory rule:
[    8.313899] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2700 mBm)
[    8.313901] cfg80211: Updating information on frequency 2462 MHz for a 20 MHz width channel with regulatory rule:
[    8.313903] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2700 mBm)
[    8.313905] cfg80211: Disabling freq 2467 MHz
[    8.313907] cfg80211: Disabling freq 2472 MHz
[    8.313909] cfg80211: Disabling freq 2484 MHz
[    8.313910] cfg80211: Disabling freq 5040 MHz
[    8.313912] cfg80211: Disabling freq 5060 MHz
[    8.313914] cfg80211: Disabling freq 5080 MHz
[    8.313916] cfg80211: Updating information on frequency 5180 MHz for a 20 MHz width channel with regulatory rule:
[    8.313918] cfg80211: 5170000 KHz - 5250000 KHz @ 40000 KHz), (300 mBi, 1700 mBm)
[    8.313920] cfg80211: Updating information on frequency 5200 MHz for a 20 MHz width channel with regulatory rule:
[    8.313922] cfg80211: 5170000 KHz - 5250000 KHz @ 40000 KHz), (300 mBi, 1700 mBm)
[    8.313924] cfg80211: Updating information on frequency 5220 MHz for a 20 MHz width channel with regulatory rule:
[    8.313927] cfg80211: 5170000 KHz - 5250000 KHz @ 40000 KHz), (300 mBi, 1700 mBm)
[    8.313929] cfg80211: Updating information on frequency 5240 MHz for a 20 MHz width channel with regulatory rule:
[    8.313931] cfg80211: 5170000 KHz - 5250000 KHz @ 40000 KHz), (300 mBi, 1700 mBm)
[    8.313933] cfg80211: Updating information on frequency 5260 MHz for a 20 MHz width channel with regulatory rule:
[    8.313936] cfg80211: 5250000 KHz - 5330000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    8.313938] cfg80211: Updating information on frequency 5280 MHz for a 20 MHz width channel with regulatory rule:
[    8.313940] cfg80211: 5250000 KHz - 5330000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    8.313942] cfg80211: Updating information on frequency 5300 MHz for a 20 MHz width channel with regulatory rule:
[    8.313944] cfg80211: 5250000 KHz - 5330000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    8.313947] cfg80211: Updating information on frequency 5320 MHz for a 20 MHz width channel with regulatory rule:
[    8.313949] cfg80211: 5250000 KHz - 5330000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    8.313951] cfg80211: Updating information on frequency 5500 MHz for a 20 MHz width channel with regulatory rule:
[    8.313953] cfg80211: 5490000 KHz - 5600000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    8.313956] cfg80211: Updating information on frequency 5520 MHz for a 20 MHz width channel with regulatory rule:
[    8.313958] cfg80211: 5490000 KHz - 5600000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    8.313960] cfg80211: Updating information on frequency 5540 MHz for a 20 MHz width channel with regulatory rule:
[    8.313962] cfg80211: 5490000 KHz - 5600000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    8.313965] cfg80211: Updating information on frequency 5560 MHz for a 20 MHz width channel with regulatory rule:
[    8.313967] cfg80211: 5490000 KHz - 5600000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    8.313969] cfg80211: Updating information on frequency 5580 MHz for a 20 MHz width channel with regulatory rule:
[    8.313971] cfg80211: 5490000 KHz - 5600000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    8.313973] cfg80211: Disabling freq 5600 MHz
[    8.313975] cfg80211: Disabling freq 5620 MHz
[    8.313977] cfg80211: Disabling freq 5640 MHz
[    8.313979] cfg80211: Updating information on frequency 5660 MHz for a 20 MHz width channel with regulatory rule:
[    8.313981] cfg80211: 5650000 KHz - 5710000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    8.313983] cfg80211: Updating information on frequency 5680 MHz for a 20 MHz width channel with regulatory rule:
[    8.313986] cfg80211: 5650000 KHz - 5710000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    8.313988] cfg80211: Updating information on frequency 5700 MHz for a 20 MHz width channel with regulatory rule:
[    8.313990] cfg80211: 5650000 KHz - 5710000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    8.313992] cfg80211: Updating information on frequency 5745 MHz for a 20 MHz width channel with regulatory rule:
[    8.313994] cfg80211: 5735000 KHz - 5835000 KHz @ 40000 KHz), (300 mBi, 3000 mBm)
[    8.313996] cfg80211: Updating information on frequency 5765 MHz for a 20 MHz width channel with regulatory rule:
[    8.313999] cfg80211: 5735000 KHz - 5835000 KHz @ 40000 KHz), (300 mBi, 3000 mBm)
[    8.314011] cfg80211: Updating information on frequency 5785 MHz for a 20 MHz width channel with regulatory rule:
[    8.314014] cfg80211: 5735000 KHz - 5835000 KHz @ 40000 KHz), (300 mBi, 3000 mBm)
[    8.314016] cfg80211: Updating information on frequency 5805 MHz for a 20 MHz width channel with regulatory rule:
[    8.314018] cfg80211: 5735000 KHz - 5835000 KHz @ 40000 KHz), (300 mBi, 3000 mBm)
[    8.314020] cfg80211: Updating information on frequency 5825 MHz for a 20 MHz width channel with regulatory rule:
[    8.314022] cfg80211: 5735000 KHz - 5835000 KHz @ 40000 KHz), (300 mBi, 3000 mBm)
[    8.314030] cfg80211: Updating information on frequency 2412 MHz for a 20 MHz width channel with regulatory rule:
[    8.314032] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2700 mBm)
[    8.314034] cfg80211: Updating information on frequency 2417 MHz for a 20 MHz width channel with regulatory rule:
[    8.314036] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2700 mBm)
[    8.314038] cfg80211: Updating information on frequency 2422 MHz for a 20 MHz width channel with regulatory rule:
[    8.314040] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2700 mBm)
[    8.314043] cfg80211: Updating information on frequency 2427 MHz for a 20 MHz width channel with regulatory rule:
[    8.314045] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2700 mBm)
[    8.314047] cfg80211: Updating information on frequency 2432 MHz for a 20 MHz width channel with regulatory rule:
[    8.314049] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2700 mBm)
[    8.314051] cfg80211: Updating information on frequency 2437 MHz for a 20 MHz width channel with regulatory rule:
[    8.314053] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2700 mBm)
[    8.314056] cfg80211: Updating information on frequency 2442 MHz for a 20 MHz width channel with regulatory rule:
[    8.314058] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2700 mBm)
[    8.314060] cfg80211: Updating information on frequency 2447 MHz for a 20 MHz width channel with regulatory rule:
[    8.314062] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2700 mBm)
[    8.314064] cfg80211: Updating information on frequency 2452 MHz for a 20 MHz width channel with regulatory rule:
[    8.314066] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2700 mBm)
[    8.314069] cfg80211: Updating information on frequency 2457 MHz for a 20 MHz width channel with regulatory rule:
[    8.314071] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2700 mBm)
[    8.314073] cfg80211: Updating information on frequency 2462 MHz for a 20 MHz width channel with regulatory rule:
[    8.314075] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2700 mBm)
[    8.314077] cfg80211: Disabling freq 2467 MHz
[    8.314079] cfg80211: Disabling freq 2472 MHz
[    8.314080] cfg80211: Disabling freq 2484 MHz
[    8.314082] cfg80211: Disabling freq 5040 MHz
[    8.314084] cfg80211: Disabling freq 5060 MHz
[    8.314085] cfg80211: Disabling freq 5080 MHz
[    8.314087] cfg80211: Updating information on frequency 5180 MHz for a 20 MHz width channel with regulatory rule:
[    8.314089] cfg80211: 5170000 KHz - 5250000 KHz @ 40000 KHz), (300 mBi, 1700 mBm)
[    8.314092] cfg80211: Updating information on frequency 5200 MHz for a 20 MHz width channel with regulatory rule:
[    8.314094] cfg80211: 5170000 KHz - 5250000 KHz @ 40000 KHz), (300 mBi, 1700 mBm)
[    8.314096] cfg80211: Updating information on frequency 5220 MHz for a 20 MHz width channel with regulatory rule:
[    8.314098] cfg80211: 5170000 KHz - 5250000 KHz @ 40000 KHz), (300 mBi, 1700 mBm)
[    8.314100] cfg80211: Updating information on frequency 5240 MHz for a 20 MHz width channel with regulatory rule:
[    8.314103] cfg80211: 5170000 KHz - 5250000 KHz @ 40000 KHz), (300 mBi, 1700 mBm)
[    8.314105] cfg80211: Updating information on frequency 5260 MHz for a 20 MHz width channel with regulatory rule:
[    8.314107] cfg80211: 5250000 KHz - 5330000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    8.314109] cfg80211: Updating information on frequency 5280 MHz for a 20 MHz width channel with regulatory rule:
[    8.314112] cfg80211: 5250000 KHz - 5330000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    8.314114] cfg80211: Updating information on frequency 5300 MHz for a 20 MHz width channel with regulatory rule:
[    8.314116] cfg80211: 5250000 KHz - 5330000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    8.314118] cfg80211: Updating information on frequency 5320 MHz for a 20 MHz width channel with regulatory rule:
[    8.314120] cfg80211: 5250000 KHz - 5330000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    8.314122] cfg80211: Updating information on frequency 5500 MHz for a 20 MHz width channel with regulatory rule:
[    8.314125] cfg80211: 5490000 KHz - 5600000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    8.314127] cfg80211: Updating information on frequency 5520 MHz for a 20 MHz width channel with regulatory rule:
[    8.314129] cfg80211: 5490000 KHz - 5600000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    8.314131] cfg80211: Updating information on frequency 5540 MHz for a 20 MHz width channel with regulatory rule:
[    8.314133] cfg80211: 5490000 KHz - 5600000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    8.314135] cfg80211: Updating information on frequency 5560 MHz for a 20 MHz width channel with regulatory rule:
[    8.314138] cfg80211: 5490000 KHz - 5600000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    8.314140] cfg80211: Updating information on frequency 5580 MHz for a 20 MHz width channel with regulatory rule:
[    8.314142] cfg80211: 5490000 KHz - 5600000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    8.314144] cfg80211: Disabling freq 5600 MHz
[    8.314146] cfg80211: Disabling freq 5620 MHz
[    8.314147] cfg80211: Disabling freq 5640 MHz
[    8.314149] cfg80211: Updating information on frequency 5660 MHz for a 20 MHz width channel with regulatory rule:
[    8.314152] cfg80211: 5650000 KHz - 5710000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    8.314154] cfg80211: Updating information on frequency 5680 MHz for a 20 MHz width channel with regulatory rule:
[    8.314156] cfg80211: 5650000 KHz - 5710000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    8.314158] cfg80211: Updating information on frequency 5700 MHz for a 20 MHz width channel with regulatory rule:
[    8.314160] cfg80211: 5650000 KHz - 5710000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    8.314163] cfg80211: Updating information on frequency 5745 MHz for a 20 MHz width channel with regulatory rule:
[    8.314165] cfg80211: 5735000 KHz - 5835000 KHz @ 40000 KHz), (300 mBi, 3000 mBm)
[    8.314167] cfg80211: Updating information on frequency 5765 MHz for a 20 MHz width channel with regulatory rule:
[    8.314169] cfg80211: 5735000 KHz - 5835000 KHz @ 40000 KHz), (300 mBi, 3000 mBm)
[    8.314171] cfg80211: Updating information on frequency 5785 MHz for a 20 MHz width channel with regulatory rule:
[    8.314174] cfg80211: 5735000 KHz - 5835000 KHz @ 40000 KHz), (300 mBi, 3000 mBm)
[    8.314176] cfg80211: Updating information on frequency 5805 MHz for a 20 MHz width channel with regulatory rule:
[    8.314178] cfg80211: 5735000 KHz - 5835000 KHz @ 40000 KHz), (300 mBi, 3000 mBm)
[    8.314180] cfg80211: Updating information on frequency 5825 MHz for a 20 MHz width channel with regulatory rule:
[    8.314182] cfg80211: 5735000 KHz - 5835000 KHz @ 40000 KHz), (300 mBi, 3000 mBm)
[    8.314189] cfg80211: Regulatory domain changed to country: US
[    8.315880] cfg80211:   (start_freq - end_freq @ bandwidth), (max_antenna_gain, max_eirp)
[    8.317596] cfg80211:   (2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2700 mBm)
[    8.319293] cfg80211:   (5170000 KHz - 5250000 KHz @ 40000 KHz), (300 mBi, 1700 mBm)
[    8.320918] cfg80211:   (5250000 KHz - 5330000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    8.322510] cfg80211:   (5490000 KHz - 5600000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    8.324075] cfg80211:   (5650000 KHz - 5710000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[    8.325705] cfg80211:   (5735000 KHz - 5835000 KHz @ 40000 KHz), (300 mBi, 3000 mBm)
[    8.589085] fedora-storage-init[2716]: Setting up Logical Volume Management:   /dev/mapper/control: open failed: No such device
[    8.590869] fedora-storage-init[2716]: Failure to communicate with kernel device-mapper driver.
[    8.592663] fedora-storage-init[2716]: Check that device-mapper is available in the kernel.
[    8.612108] fedora-storage-init[2716]: No volume groups found
[    8.613840] fedora-storage-init[2716]: [  OK  ]
[    8.703850] fedora-storage-init[2724]: Setting up Logical Volume Management:   /dev/mapper/control: open failed: No such device
[    8.705554] fedora-storage-init[2724]: Failure to communicate with kernel device-mapper driver.
[    8.707174] fedora-storage-init[2724]: Check that device-mapper is available in the kernel.
[    8.723503] fedora-storage-init[2724]: No volume groups found
[    8.725328] fedora-storage-init[2724]: [  OK  ]
[    8.772643] lvm[2732]: /dev/mapper/control: open failed: No such device
[    8.774456] lvm[2732]: Failure to communicate with kernel device-mapper driver.
[    8.776105] lvm[2732]: Check that device-mapper is available in the kernel.
[    8.791921] lvm[2732]: No volume groups found
[    9.064970] iptables.init[2747]: iptables: Applying firewall rules: FATAL: Module ip_tables not found.
[    9.065091] iptables.init[2747]: iptables-restore v1.4.12: iptables-restore: unable to initialize table 'filter'
[    9.065130] iptables.init[2747]: Error occurred at line: 3
[    9.065177] iptables.init[2747]: Try `iptables-restore -h' or 'iptables-restore --help' for more information.
[    9.070127] /usr/sbin/crond[2764]: (CRON) INFO (Syslog will be used instead of sendmail.): No such file or directory
[    9.074241] /usr/sbin/crond[2764]: (CRON) INFO (running with inotify support)
[    9.083936] iptables.init[2747]: [FAILED]
[    9.124900] acpid[2782]: starting up with netlink and the input layer
[    9.125503] acpid[2782]: skipping incomplete file /etc/acpi/events/videoconf
[    9.125646] acpid[2782]: 1 rule loaded
[    9.125898] acpid[2782]: waiting for events: event logging is off
[    9.159698] abrtd[2783]: Init complete, entering main loop
[    9.221438] /usr/sbin/gpm[2795]: *** info [daemon/startup.c(136)]:
[    9.223125] /usr/sbin/gpm[2795]: Started gpm successfully. Entered daemon mode.
[    9.268804] ntpd[2799]: ntpd 4.2.6p4@1.2324-o Thu Oct  6 15:37:57 UTC 2011 (1)
[    9.274324] ntpd[2799]: proto: precision = 0.079 usec
[    9.274419] ntpd[2799]: 0.0.0.0 c01d 0d kern kernel time sync enabled
[    9.274748] ntpd[2799]: ntp_io: estimated max descriptors: 1024, initial socket boundary: 16
[    9.278672] ntpd[2799]: Listen and drop on 0 v4wildcard 0.0.0.0 UDP 123
[    9.280347] ntpd[2799]: Listen normally on 1 lo 127.0.0.1 UDP 123
[    9.282017] ntpd[2799]: peers refreshed
[    9.283669] ntpd[2799]: Listening on routing socket on fd #18 for interface updates
[    9.285308] ntpd[2799]: restrict: error in address '::' on line 10. Ignoring...
[    9.286989] ntpd[2799]: restrict: error in address '::1' on line 16. Ignoring...
[    9.288643] ntpd[2799]: Deferring DNS for 0.fedora.pool.ntp.org 1
[    9.290223] ntpd[2799]: Deferring DNS for 1.fedora.pool.ntp.org 1
[    9.291860] ntpd[2799]: Deferring DNS for 2.fedora.pool.ntp.org 1
[    9.293490] ntpd[2799]: Deferring DNS for 3.fedora.pool.ntp.org 1
[    9.296346] ntpd[2799]: 0.0.0.0 c016 06 restart
[    9.296382] ntpd[2799]: 0.0.0.0 c012 02 freq_set kernel 8.297 PPM
[    9.296417] ntpd[2804]: signal_no_reset: signal 17 had flags 4000000
[    9.337907] avahi-daemon[2806]: Found user 'avahi' (UID 70) and group 'avahi' (GID 70).
[    9.339456] avahi-daemon[2806]: Successfully dropped root privileges.
[    9.340999] avahi-daemon[2806]: avahi-daemon 0.6.30 starting up.
[    9.408035] systemd[1]: iptables.service: main process exited, code=exited, status=1
[    9.421103] systemd[1]: Unit iptables.service entered failed state.
[    9.469776] tcsd[2807]: insmod: can't read '/lib/modules/3.6.0-rc3-wl-main/kernel/drivers/char/tpm/tpm_*': No such file or directory
[    9.478832] tcsd[2821]: TCSD TDDL[2821]: TrouSerS ERROR: Could not find a device to open!
[    9.490278] tcsd[2807]: Starting tcsd: [FAILED]
[    9.520655] systemd[1]: tcsd.service: control process exited, code=exited status=137
[    9.541929] systemd[1]: Unit tcsd.service entered failed state.
[    9.630929] dbus[2832]: [system] Activating systemd to hand-off: service name='org.freedesktop.NetworkManager' unit='dbus-org.freedesktop.NetworkManager.service'
[    9.633125] dbus-daemon[2832]: dbus[2832]: [system] Activating systemd to hand-off: service name='org.freedesktop.NetworkManager' unit='dbus-org.freedesktop.NetworkManager.service'
[    9.637183] avahi-daemon[2806]: Successfully called chroot().
[    9.639744] avahi-daemon[2806]: Successfully dropped remaining capabilities.
[    9.643909] avahi-daemon[2806]: Loading service file /services/ssh.service.
[    9.643945] avahi-daemon[2806]: Loading service file /services/udisks.service.
[    9.643981] avahi-daemon[2806]: Network interface enumeration completed.
[    9.644028] avahi-daemon[2806]: Registering HINFO record with values 'X86_64'/'LINUX'.
[    9.644064] avahi-daemon[2806]: Server startup complete. Host name is mj.local. Local service cookie is 2976784327.
[    9.644102] avahi-daemon[2806]: Service "mj" (/services/udisks.service) successfully established.
[    9.644138] avahi-daemon[2806]: Service "mj" (/services/ssh.service) successfully established.
[   10.189339] r8169 0000:01:00.0: p32p1: link down
[   10.191205] r8169 0000:01:00.0: p32p1: link down
[   11.822382] r8169 0000:01:00.0: p32p1: link up
[   22.204081] hub 5-0:1.0: state 7 ports 2 chg 0000 evt 0002
[   22.204113] uhci_hcd 0000:00:1d.3: port 1 portsc 008a,00
[   22.204182] hub 5-0:1.0: port 1, status 0100, change 0003, 12 Mb/s
[   22.204187] usb 5-1: USB disconnect, device number 2
[   22.204191] usb 5-1: unregistering device
[   22.204194] usb 5-1: unregistering interface 5-1:1.0
[   22.207596] usb 5-1: usb_disable_device nuking all URBs
[   22.320079] hub 5-0:1.0: debounce: port 1: total 100ms stable 100ms status 0x100
[   23.128398] hub 1-0:1.0: state 7 ports 8 chg 0000 evt ff80
[   23.128430] ehci_hcd 0000:00:1d.7: GetStatus port:7 status 001803 0  ACK POWER sig=j CSC CONNECT
[   23.128475] hub 1-0:1.0: port 7, status 0501, change 0001, 480 Mb/s
[   23.232101] hub 1-0:1.0: debounce: port 7: total 100ms stable 100ms status 0x501
[   23.283361] ehci_hcd 0000:00:1d.7: port 7 full speed --> companion
[   23.283366] ehci_hcd 0000:00:1d.7: GetStatus port:7 status 003801 0  ACK POWER OWNER sig=j CONNECT
[   23.283385] hub 1-0:1.0: port 7 not reset yet, waiting 50ms
[   23.334083] ehci_hcd 0000:00:1d.7: GetStatus port:7 status 003002 0  ACK POWER OWNER sig=se0 CSC
[   23.334279] hub 1-0:1.0: state 7 ports 8 chg 0000 evt fe80
[   23.334299] ehci_hcd 0000:00:1d.7: GetStatus port:7 status 003002 0  ACK POWER OWNER sig=se0 CSC
[   23.334340] hub 1-0:1.0: port 7, status 0100, change 0001, 12 Mb/s
[   23.438087] hub 1-0:1.0: debounce: port 7: total 100ms stable 100ms status 0x100
[   23.454207] hub 5-0:1.0: state 7 ports 2 chg 0000 evt 0002
[   23.454237] uhci_hcd 0000:00:1d.3: port 1 portsc 0093,00
[   23.454280] hub 5-0:1.0: port 1, status 0101, change 0001, 12 Mb/s
[   23.558061] hub 5-0:1.0: debounce: port 1: total 100ms stable 100ms status 0x101
[   23.660071] usb 5-1: new full-speed USB device number 3 using uhci_hcd
[   23.792496] usb 5-1: config 1 has an invalid interface number: 3 but max is 2
[   23.792503] usb 5-1: config 1 has 4 interfaces, different from the descriptor's value: 3
[   23.792548] usb 5-1: skipped 4 descriptors after interface
[   23.797491] usb 5-1: default language 0x0409
[   23.807513] usb 5-1: udev 3, busnum 5, minor = 514
[   23.807520] usb 5-1: New USB device found, idVendor=1004, idProduct=6000
[   23.807525] usb 5-1: New USB device strings: Mfr=1, Product=2, SerialNumber=0
[   23.807530] usb 5-1: Product: LG CDMA USB Modem
[   23.807534] usb 5-1: Manufacturer: LG CDMA USB Modem
[   23.808410] usb 5-1: usb_probe_device
[   23.808415] usb 5-1: configuration #1 chosen from 1 choice
[   23.811542] usb 5-1: adding 5-1:1.0 (config #1, interface 0)
[   23.812030] cdc_acm 5-1:1.0: usb_probe_interface
[   23.812039] cdc_acm 5-1:1.0: usb_probe_interface - got id
[   23.812659] cdc_acm 5-1:1.0: ttyACM0: USB ACM device
[   23.816502] usb 5-1: adding 5-1:1.1 (config #1, interface 1)
[   23.819353] usb 5-1: adding 5-1:1.2 (config #1, interface 2)
[   23.820227] usb 5-1: adding 5-1:1.3 (config #1, interface 3)
[   23.821312] hub 5-0:1.0: state 7 ports 2 chg 0000 evt 0002
[   31.458085] CPA self-test:
[   31.476512]  4k 1046528 large 0 gb 0 x 262491[ffff880000000000-ffff8800cf7ff000] miss 198656
[   31.496475]  4k 1046528 large 0 gb 0 x 262491[ffff880000000000-ffff8800cf7ff000] miss 198656
[   31.515980]  4k 1046528 large 0 gb 0 x 262491[ffff880000000000-ffff8800cf7ff000] miss 198656
[   31.515985] ok.
[ 1375.285808] chromium-browse (3732) used greatest stack depth: 2672 bytes left
[ 1399.805510] sock: process `skype' is using obsolete setsockopt SO_BSDCOMPAT
[ 1570.586216] 
[ 1570.586223] ===============================
[ 1570.586225] [ INFO: suspicious RCU usage. ]
[ 1570.586228] 3.6.0-rc3-wl-main #98 Not tainted
[ 1570.586229] -------------------------------
[ 1570.586231] /home/proski/src/linux/net/ipv4/route.c:645 suspicious rcu_dereference_check() usage!
[ 1570.586233] 
[ 1570.586233] other info that might help us debug this:
[ 1570.586233] 
[ 1570.586236] 
[ 1570.586236] rcu_scheduler_active = 1, debug_locks = 0
[ 1570.586238] 2 locks held by Chrome_IOThread/4467:
[ 1570.586240]  #0:  (slock-AF_INET){+.-...}, at: [<ffffffff814f2c0c>] release_sock+0x2c/0xa0
[ 1570.586253]  #1:  (fnhe_lock){+.-...}, at: [<ffffffff815302fc>] update_or_create_fnhe+0x2c/0x270
[ 1570.586260] 
[ 1570.586260] stack backtrace:
[ 1570.586263] Pid: 4467, comm: Chrome_IOThread Not tainted 3.6.0-rc3-wl-main #98
[ 1570.586265] Call Trace:
[ 1570.586271]  [<ffffffff810976ed>] lockdep_rcu_suspicious+0xfd/0x130
[ 1570.586275]  [<ffffffff8153042c>] update_or_create_fnhe+0x15c/0x270
[ 1570.586278]  [<ffffffff815305b3>] __ip_rt_update_pmtu+0x73/0xb0
[ 1570.586282]  [<ffffffff81530619>] ip_rt_update_pmtu+0x29/0x90
[ 1570.586285]  [<ffffffff815411dc>] inet_csk_update_pmtu+0x2c/0x80
[ 1570.586290]  [<ffffffff81558d1e>] tcp_v4_mtu_reduced+0x2e/0xc0
[ 1570.586293]  [<ffffffff81553bc4>] tcp_release_cb+0xa4/0xb0
[ 1570.586296]  [<ffffffff814f2c35>] release_sock+0x55/0xa0
[ 1570.586300]  [<ffffffff815442ef>] tcp_sendmsg+0x4af/0xf50
[ 1570.586305]  [<ffffffff8156fc60>] inet_sendmsg+0x120/0x230
[ 1570.586308]  [<ffffffff8156fb40>] ? inet_sk_rebuild_header+0x40/0x40
[ 1570.586312]  [<ffffffff814f4bdd>] ? sock_update_classid+0xbd/0x3b0
[ 1570.586315]  [<ffffffff814f4c50>] ? sock_update_classid+0x130/0x3b0
[ 1570.586320]  [<ffffffff814ec435>] do_sock_write+0xc5/0xe0
[ 1570.586323]  [<ffffffff814ec4a3>] sock_aio_write+0x53/0x80
[ 1570.586328]  [<ffffffff8114bc83>] do_sync_write+0xa3/0xe0
[ 1570.586332]  [<ffffffff8114c5a5>] vfs_write+0x165/0x180
[ 1570.586335]  [<ffffffff8114c805>] sys_write+0x45/0x90
[ 1570.586340]  [<ffffffff815d2722>] system_call_fastpath+0x16/0x1b
[11429.704104] hub 5-0:1.0: state 7 ports 2 chg 0000 evt 0002
[11429.704138] uhci_hcd 0000:00:1d.3: port 1 portsc 009a,00
[11429.704219] hub 5-0:1.0: port 1, status 0100, change 0003, 12 Mb/s
[11429.704225] usb 5-1: USB disconnect, device number 3
[11429.704234] usb 5-1: unregistering device
[11429.704237] usb 5-1: unregistering interface 5-1:1.0
[11429.705455] usb 5-1: unregistering interface 5-1:1.1
[11429.706114] usb 5-1: unregistering interface 5-1:1.2
[11429.708292] usb 5-1: unregistering interface 5-1:1.3
[11429.708941] usb 5-1: usb_disable_device nuking all URBs
[11429.813072] hub 5-0:1.0: debounce: port 1: total 100ms stable 100ms status 0x100
[11430.954049] usb usb5: suspend_rh (auto-stop)

--MP_/LgctS8_YzoCXyr=r_doHFj6
Content-Type: application/octet-stream; name=.config
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename=.config

IwojIEF1dG9tYXRpY2FsbHkgZ2VuZXJhdGVkIGZpbGU7IERPIE5PVCBFRElULgojIExpbnV4L3g4
Nl82NCAzLjYuMC1yYzMgS2VybmVsIENvbmZpZ3VyYXRpb24KIwpDT05GSUdfNjRCSVQ9eQojIENP
TkZJR19YODZfMzIgaXMgbm90IHNldApDT05GSUdfWDg2XzY0PXkKQ09ORklHX1g4Nj15CkNPTkZJ
R19JTlNUUlVDVElPTl9ERUNPREVSPXkKQ09ORklHX09VVFBVVF9GT1JNQVQ9ImVsZjY0LXg4Ni02
NCIKQ09ORklHX0FSQ0hfREVGQ09ORklHPSJhcmNoL3g4Ni9jb25maWdzL3g4Nl82NF9kZWZjb25m
aWciCkNPTkZJR19MT0NLREVQX1NVUFBPUlQ9eQpDT05GSUdfU1RBQ0tUUkFDRV9TVVBQT1JUPXkK
Q09ORklHX0hBVkVfTEFURU5DWVRPUF9TVVBQT1JUPXkKQ09ORklHX01NVT15CkNPTkZJR19ORUVE
X0RNQV9NQVBfU1RBVEU9eQpDT05GSUdfTkVFRF9TR19ETUFfTEVOR1RIPXkKQ09ORklHX0dFTkVS
SUNfSVNBX0RNQT15CkNPTkZJR19HRU5FUklDX0JVRz15CkNPTkZJR19HRU5FUklDX0JVR19SRUxB
VElWRV9QT0lOVEVSUz15CkNPTkZJR19HRU5FUklDX0hXRUlHSFQ9eQpDT05GSUdfQVJDSF9NQVlf
SEFWRV9QQ19GREM9eQojIENPTkZJR19SV1NFTV9HRU5FUklDX1NQSU5MT0NLIGlzIG5vdCBzZXQK
Q09ORklHX1JXU0VNX1hDSEdBRERfQUxHT1JJVEhNPXkKQ09ORklHX0dFTkVSSUNfQ0FMSUJSQVRF
X0RFTEFZPXkKQ09ORklHX0FSQ0hfSEFTX0NQVV9SRUxBWD15CkNPTkZJR19BUkNIX0hBU19ERUZB
VUxUX0lETEU9eQpDT05GSUdfQVJDSF9IQVNfQ0FDSEVfTElORV9TSVpFPXkKQ09ORklHX0FSQ0hf
SEFTX0NQVV9BVVRPUFJPQkU9eQpDT05GSUdfSEFWRV9TRVRVUF9QRVJfQ1BVX0FSRUE9eQpDT05G
SUdfTkVFRF9QRVJfQ1BVX0VNQkVEX0ZJUlNUX0NIVU5LPXkKQ09ORklHX05FRURfUEVSX0NQVV9Q
QUdFX0ZJUlNUX0NIVU5LPXkKQ09ORklHX0FSQ0hfSElCRVJOQVRJT05fUE9TU0lCTEU9eQpDT05G
SUdfQVJDSF9TVVNQRU5EX1BPU1NJQkxFPXkKQ09ORklHX1pPTkVfRE1BMzI9eQpDT05GSUdfQVVE
SVRfQVJDSD15CkNPTkZJR19BUkNIX1NVUFBPUlRTX09QVElNSVpFRF9JTkxJTklORz15CkNPTkZJ
R19BUkNIX1NVUFBPUlRTX0RFQlVHX1BBR0VBTExPQz15CkNPTkZJR19YODZfNjRfU01QPXkKQ09O
RklHX1g4Nl9IVD15CkNPTkZJR19BUkNIX0hXRUlHSFRfQ0ZMQUdTPSItZmNhbGwtc2F2ZWQtcmRp
IC1mY2FsbC1zYXZlZC1yc2kgLWZjYWxsLXNhdmVkLXJkeCAtZmNhbGwtc2F2ZWQtcmN4IC1mY2Fs
bC1zYXZlZC1yOCAtZmNhbGwtc2F2ZWQtcjkgLWZjYWxsLXNhdmVkLXIxMCAtZmNhbGwtc2F2ZWQt
cjExIgpDT05GSUdfQVJDSF9DUFVfUFJPQkVfUkVMRUFTRT15CkNPTkZJR19BUkNIX1NVUFBPUlRT
X1VQUk9CRVM9eQpDT05GSUdfREVGQ09ORklHX0xJU1Q9Ii9saWIvbW9kdWxlcy8kVU5BTUVfUkVM
RUFTRS8uY29uZmlnIgpDT05GSUdfSEFWRV9JUlFfV09SSz15CkNPTkZJR19JUlFfV09SSz15CkNP
TkZJR19CVUlMRFRJTUVfRVhUQUJMRV9TT1JUPXkKCiMKIyBHZW5lcmFsIHNldHVwCiMKQ09ORklH
X0VYUEVSSU1FTlRBTD15CkNPTkZJR19JTklUX0VOVl9BUkdfTElNSVQ9MzIKQ09ORklHX0NST1NT
X0NPTVBJTEU9IiIKQ09ORklHX0xPQ0FMVkVSU0lPTj0iLW1haW4iCiMgQ09ORklHX0xPQ0FMVkVS
U0lPTl9BVVRPIGlzIG5vdCBzZXQKQ09ORklHX0hBVkVfS0VSTkVMX0daSVA9eQpDT05GSUdfSEFW
RV9LRVJORUxfQlpJUDI9eQpDT05GSUdfSEFWRV9LRVJORUxfTFpNQT15CkNPTkZJR19IQVZFX0tF
Uk5FTF9YWj15CkNPTkZJR19IQVZFX0tFUk5FTF9MWk89eQojIENPTkZJR19LRVJORUxfR1pJUCBp
cyBub3Qgc2V0CiMgQ09ORklHX0tFUk5FTF9CWklQMiBpcyBub3Qgc2V0CiMgQ09ORklHX0tFUk5F
TF9MWk1BIGlzIG5vdCBzZXQKQ09ORklHX0tFUk5FTF9YWj15CiMgQ09ORklHX0tFUk5FTF9MWk8g
aXMgbm90IHNldApDT05GSUdfREVGQVVMVF9IT1NUTkFNRT0iKG5vbmUpIgpDT05GSUdfU1dBUD15
CkNPTkZJR19TWVNWSVBDPXkKQ09ORklHX1NZU1ZJUENfU1lTQ1RMPXkKQ09ORklHX1BPU0lYX01R
VUVVRT15CkNPTkZJR19QT1NJWF9NUVVFVUVfU1lTQ1RMPXkKQ09ORklHX0JTRF9QUk9DRVNTX0FD
Q1Q9eQpDT05GSUdfQlNEX1BST0NFU1NfQUNDVF9WMz15CkNPTkZJR19GSEFORExFPXkKQ09ORklH
X1RBU0tTVEFUUz15CkNPTkZJR19UQVNLX0RFTEFZX0FDQ1Q9eQpDT05GSUdfVEFTS19YQUNDVD15
CkNPTkZJR19UQVNLX0lPX0FDQ09VTlRJTkc9eQpDT05GSUdfQVVESVQ9eQpDT05GSUdfQVVESVRT
WVNDQUxMPXkKQ09ORklHX0FVRElUX1dBVENIPXkKQ09ORklHX0FVRElUX1RSRUU9eQojIENPTkZJ
R19BVURJVF9MT0dJTlVJRF9JTU1VVEFCTEUgaXMgbm90IHNldApDT05GSUdfSEFWRV9HRU5FUklD
X0hBUkRJUlFTPXkKCiMKIyBJUlEgc3Vic3lzdGVtCiMKQ09ORklHX0dFTkVSSUNfSEFSRElSUVM9
eQpDT05GSUdfR0VORVJJQ19JUlFfUFJPQkU9eQpDT05GSUdfR0VORVJJQ19JUlFfU0hPVz15CkNP
TkZJR19HRU5FUklDX1BFTkRJTkdfSVJRPXkKQ09ORklHX0lSUV9GT1JDRURfVEhSRUFESU5HPXkK
Q09ORklHX1NQQVJTRV9JUlE9eQpDT05GSUdfQ0xPQ0tTT1VSQ0VfV0FUQ0hET0c9eQpDT05GSUdf
QVJDSF9DTE9DS1NPVVJDRV9EQVRBPXkKQ09ORklHX0dFTkVSSUNfVElNRV9WU1lTQ0FMTD15CkNP
TkZJR19HRU5FUklDX0NMT0NLRVZFTlRTPXkKQ09ORklHX0dFTkVSSUNfQ0xPQ0tFVkVOVFNfQlVJ
TEQ9eQpDT05GSUdfR0VORVJJQ19DTE9DS0VWRU5UU19CUk9BRENBU1Q9eQpDT05GSUdfR0VORVJJ
Q19DTE9DS0VWRU5UU19NSU5fQURKVVNUPXkKQ09ORklHX0dFTkVSSUNfQ01PU19VUERBVEU9eQoK
IwojIFRpbWVycyBzdWJzeXN0ZW0KIwpDT05GSUdfVElDS19PTkVTSE9UPXkKQ09ORklHX05PX0ha
PXkKQ09ORklHX0hJR0hfUkVTX1RJTUVSUz15CgojCiMgUkNVIFN1YnN5c3RlbQojCkNPTkZJR19U
UkVFX1JDVT15CiMgQ09ORklHX1BSRUVNUFRfUkNVIGlzIG5vdCBzZXQKQ09ORklHX1JDVV9GQU5P
VVQ9NjQKQ09ORklHX1JDVV9GQU5PVVRfTEVBRj0xNgojIENPTkZJR19SQ1VfRkFOT1VUX0VYQUNU
IGlzIG5vdCBzZXQKIyBDT05GSUdfUkNVX0ZBU1RfTk9fSFogaXMgbm90IHNldAojIENPTkZJR19U
UkVFX1JDVV9UUkFDRSBpcyBub3Qgc2V0CiMgQ09ORklHX0lLQ09ORklHIGlzIG5vdCBzZXQKQ09O
RklHX0xPR19CVUZfU0hJRlQ9MjAKQ09ORklHX0hBVkVfVU5TVEFCTEVfU0NIRURfQ0xPQ0s9eQpD
T05GSUdfQ0dST1VQUz15CiMgQ09ORklHX0NHUk9VUF9ERUJVRyBpcyBub3Qgc2V0CkNPTkZJR19D
R1JPVVBfRlJFRVpFUj15CiMgQ09ORklHX0NHUk9VUF9ERVZJQ0UgaXMgbm90IHNldApDT05GSUdf
Q1BVU0VUUz15CkNPTkZJR19QUk9DX1BJRF9DUFVTRVQ9eQpDT05GSUdfQ0dST1VQX0NQVUFDQ1Q9
eQpDT05GSUdfUkVTT1VSQ0VfQ09VTlRFUlM9eQojIENPTkZJR19NRU1DRyBpcyBub3Qgc2V0CiMg
Q09ORklHX0NHUk9VUF9IVUdFVExCIGlzIG5vdCBzZXQKIyBDT05GSUdfQ0dST1VQX1BFUkYgaXMg
bm90IHNldApDT05GSUdfQ0dST1VQX1NDSEVEPXkKQ09ORklHX0ZBSVJfR1JPVVBfU0NIRUQ9eQoj
IENPTkZJR19DRlNfQkFORFdJRFRIIGlzIG5vdCBzZXQKIyBDT05GSUdfUlRfR1JPVVBfU0NIRUQg
aXMgbm90IHNldAojIENPTkZJR19CTEtfQ0dST1VQIGlzIG5vdCBzZXQKIyBDT05GSUdfQ0hFQ0tQ
T0lOVF9SRVNUT1JFIGlzIG5vdCBzZXQKQ09ORklHX05BTUVTUEFDRVM9eQpDT05GSUdfVVRTX05T
PXkKQ09ORklHX0lQQ19OUz15CkNPTkZJR19QSURfTlM9eQpDT05GSUdfTkVUX05TPXkKQ09ORklH
X1NDSEVEX0FVVE9HUk9VUD15CiMgQ09ORklHX1NZU0ZTX0RFUFJFQ0FURUQgaXMgbm90IHNldApD
T05GSUdfUkVMQVk9eQpDT05GSUdfQkxLX0RFVl9JTklUUkQ9eQpDT05GSUdfSU5JVFJBTUZTX1NP
VVJDRT0iIgpDT05GSUdfUkRfR1pJUD15CkNPTkZJR19SRF9CWklQMj15CkNPTkZJR19SRF9MWk1B
PXkKQ09ORklHX1JEX1haPXkKQ09ORklHX1JEX0xaTz15CiMgQ09ORklHX0NDX09QVElNSVpFX0ZP
Ul9TSVpFIGlzIG5vdCBzZXQKQ09ORklHX1NZU0NUTD15CkNPTkZJR19BTk9OX0lOT0RFUz15CkNP
TkZJR19FWFBFUlQ9eQpDT05GSUdfVUlEMTY9eQpDT05GSUdfU1lTQ1RMX1NZU0NBTEw9eQpDT05G
SUdfS0FMTFNZTVM9eQpDT05GSUdfS0FMTFNZTVNfQUxMPXkKQ09ORklHX0hPVFBMVUc9eQpDT05G
SUdfUFJJTlRLPXkKQ09ORklHX0JVRz15CkNPTkZJR19FTEZfQ09SRT15CkNPTkZJR19QQ1NQS1Jf
UExBVEZPUk09eQpDT05GSUdfSEFWRV9QQ1NQS1JfUExBVEZPUk09eQpDT05GSUdfQkFTRV9GVUxM
PXkKQ09ORklHX0ZVVEVYPXkKQ09ORklHX0VQT0xMPXkKQ09ORklHX1NJR05BTEZEPXkKQ09ORklH
X1RJTUVSRkQ9eQpDT05GSUdfRVZFTlRGRD15CkNPTkZJR19TSE1FTT15CkNPTkZJR19BSU89eQoj
IENPTkZJR19FTUJFRERFRCBpcyBub3Qgc2V0CkNPTkZJR19IQVZFX1BFUkZfRVZFTlRTPXkKCiMK
IyBLZXJuZWwgUGVyZm9ybWFuY2UgRXZlbnRzIEFuZCBDb3VudGVycwojCkNPTkZJR19QRVJGX0VW
RU5UUz15CiMgQ09ORklHX0RFQlVHX1BFUkZfVVNFX1ZNQUxMT0MgaXMgbm90IHNldApDT05GSUdf
Vk1fRVZFTlRfQ09VTlRFUlM9eQpDT05GSUdfUENJX1FVSVJLUz15CkNPTkZJR19TTFVCX0RFQlVH
PXkKIyBDT05GSUdfQ09NUEFUX0JSSyBpcyBub3Qgc2V0CiMgQ09ORklHX1NMQUIgaXMgbm90IHNl
dApDT05GSUdfU0xVQj15CiMgQ09ORklHX1NMT0IgaXMgbm90IHNldAojIENPTkZJR19QUk9GSUxJ
TkcgaXMgbm90IHNldApDT05GSUdfVFJBQ0VQT0lOVFM9eQpDT05GSUdfSEFWRV9PUFJPRklMRT15
CkNPTkZJR19PUFJPRklMRV9OTUlfVElNRVI9eQojIENPTkZJR19LUFJPQkVTIGlzIG5vdCBzZXQK
Q09ORklHX0pVTVBfTEFCRUw9eQpDT05GSUdfSEFWRV9FRkZJQ0lFTlRfVU5BTElHTkVEX0FDQ0VT
Uz15CkNPTkZJR19IQVZFX0lPUkVNQVBfUFJPVD15CkNPTkZJR19IQVZFX0tQUk9CRVM9eQpDT05G
SUdfSEFWRV9LUkVUUFJPQkVTPXkKQ09ORklHX0hBVkVfT1BUUFJPQkVTPXkKQ09ORklHX0hBVkVf
QVJDSF9UUkFDRUhPT0s9eQpDT05GSUdfSEFWRV9ETUFfQVRUUlM9eQpDT05GSUdfVVNFX0dFTkVS
SUNfU01QX0hFTFBFUlM9eQpDT05GSUdfR0VORVJJQ19TTVBfSURMRV9USFJFQUQ9eQpDT05GSUdf
SEFWRV9SRUdTX0FORF9TVEFDS19BQ0NFU1NfQVBJPXkKQ09ORklHX0hBVkVfRE1BX0FQSV9ERUJV
Rz15CkNPTkZJR19IQVZFX0hXX0JSRUFLUE9JTlQ9eQpDT05GSUdfSEFWRV9NSVhFRF9CUkVBS1BP
SU5UU19SRUdTPXkKQ09ORklHX0hBVkVfVVNFUl9SRVRVUk5fTk9USUZJRVI9eQpDT05GSUdfSEFW
RV9QRVJGX0VWRU5UU19OTUk9eQpDT05GSUdfSEFWRV9BUkNIX0pVTVBfTEFCRUw9eQpDT05GSUdf
QVJDSF9IQVZFX05NSV9TQUZFX0NNUFhDSEc9eQpDT05GSUdfSEFWRV9BTElHTkVEX1NUUlVDVF9Q
QUdFPXkKQ09ORklHX0hBVkVfQ01QWENIR19MT0NBTD15CkNPTkZJR19IQVZFX0NNUFhDSEdfRE9V
QkxFPXkKQ09ORklHX0FSQ0hfV0FOVF9DT01QQVRfSVBDX1BBUlNFX1ZFUlNJT049eQpDT05GSUdf
QVJDSF9XQU5UX09MRF9DT01QQVRfSVBDPXkKQ09ORklHX0hBVkVfQVJDSF9TRUNDT01QX0ZJTFRF
Uj15CkNPTkZJR19TRUNDT01QX0ZJTFRFUj15CgojCiMgR0NPVi1iYXNlZCBrZXJuZWwgcHJvZmls
aW5nCiMKIyBDT05GSUdfR0NPVl9LRVJORUwgaXMgbm90IHNldAojIENPTkZJR19IQVZFX0dFTkVS
SUNfRE1BX0NPSEVSRU5UIGlzIG5vdCBzZXQKQ09ORklHX1NMQUJJTkZPPXkKQ09ORklHX1JUX01V
VEVYRVM9eQpDT05GSUdfQkFTRV9TTUFMTD0wCkNPTkZJR19NT0RVTEVTPXkKIyBDT05GSUdfTU9E
VUxFX0ZPUkNFX0xPQUQgaXMgbm90IHNldApDT05GSUdfTU9EVUxFX1VOTE9BRD15CkNPTkZJR19N
T0RVTEVfRk9SQ0VfVU5MT0FEPXkKQ09ORklHX01PRFZFUlNJT05TPXkKIyBDT05GSUdfTU9EVUxF
X1NSQ1ZFUlNJT05fQUxMIGlzIG5vdCBzZXQKQ09ORklHX1NUT1BfTUFDSElORT15CkNPTkZJR19C
TE9DSz15CkNPTkZJR19CTEtfREVWX0JTRz15CiMgQ09ORklHX0JMS19ERVZfQlNHTElCIGlzIG5v
dCBzZXQKIyBDT05GSUdfQkxLX0RFVl9JTlRFR1JJVFkgaXMgbm90IHNldAoKIwojIFBhcnRpdGlv
biBUeXBlcwojCiMgQ09ORklHX1BBUlRJVElPTl9BRFZBTkNFRCBpcyBub3Qgc2V0CkNPTkZJR19N
U0RPU19QQVJUSVRJT049eQpDT05GSUdfQkxPQ0tfQ09NUEFUPXkKCiMKIyBJTyBTY2hlZHVsZXJz
CiMKQ09ORklHX0lPU0NIRURfTk9PUD15CiMgQ09ORklHX0lPU0NIRURfREVBRExJTkUgaXMgbm90
IHNldApDT05GSUdfSU9TQ0hFRF9DRlE9eQpDT05GSUdfREVGQVVMVF9DRlE9eQojIENPTkZJR19E
RUZBVUxUX05PT1AgaXMgbm90IHNldApDT05GSUdfREVGQVVMVF9JT1NDSEVEPSJjZnEiCiMgQ09O
RklHX0lOTElORV9TUElOX1RSWUxPQ0sgaXMgbm90IHNldAojIENPTkZJR19JTkxJTkVfU1BJTl9U
UllMT0NLX0JIIGlzIG5vdCBzZXQKIyBDT05GSUdfSU5MSU5FX1NQSU5fTE9DSyBpcyBub3Qgc2V0
CiMgQ09ORklHX0lOTElORV9TUElOX0xPQ0tfQkggaXMgbm90IHNldAojIENPTkZJR19JTkxJTkVf
U1BJTl9MT0NLX0lSUSBpcyBub3Qgc2V0CiMgQ09ORklHX0lOTElORV9TUElOX0xPQ0tfSVJRU0FW
RSBpcyBub3Qgc2V0CkNPTkZJR19VTklOTElORV9TUElOX1VOTE9DSz15CiMgQ09ORklHX0lOTElO
RV9TUElOX1VOTE9DS19CSCBpcyBub3Qgc2V0CiMgQ09ORklHX0lOTElORV9TUElOX1VOTE9DS19J
UlEgaXMgbm90IHNldAojIENPTkZJR19JTkxJTkVfU1BJTl9VTkxPQ0tfSVJRUkVTVE9SRSBpcyBu
b3Qgc2V0CiMgQ09ORklHX0lOTElORV9SRUFEX1RSWUxPQ0sgaXMgbm90IHNldAojIENPTkZJR19J
TkxJTkVfUkVBRF9MT0NLIGlzIG5vdCBzZXQKIyBDT05GSUdfSU5MSU5FX1JFQURfTE9DS19CSCBp
cyBub3Qgc2V0CiMgQ09ORklHX0lOTElORV9SRUFEX0xPQ0tfSVJRIGlzIG5vdCBzZXQKIyBDT05G
SUdfSU5MSU5FX1JFQURfTE9DS19JUlFTQVZFIGlzIG5vdCBzZXQKIyBDT05GSUdfSU5MSU5FX1JF
QURfVU5MT0NLIGlzIG5vdCBzZXQKIyBDT05GSUdfSU5MSU5FX1JFQURfVU5MT0NLX0JIIGlzIG5v
dCBzZXQKIyBDT05GSUdfSU5MSU5FX1JFQURfVU5MT0NLX0lSUSBpcyBub3Qgc2V0CiMgQ09ORklH
X0lOTElORV9SRUFEX1VOTE9DS19JUlFSRVNUT1JFIGlzIG5vdCBzZXQKIyBDT05GSUdfSU5MSU5F
X1dSSVRFX1RSWUxPQ0sgaXMgbm90IHNldAojIENPTkZJR19JTkxJTkVfV1JJVEVfTE9DSyBpcyBu
b3Qgc2V0CiMgQ09ORklHX0lOTElORV9XUklURV9MT0NLX0JIIGlzIG5vdCBzZXQKIyBDT05GSUdf
SU5MSU5FX1dSSVRFX0xPQ0tfSVJRIGlzIG5vdCBzZXQKIyBDT05GSUdfSU5MSU5FX1dSSVRFX0xP
Q0tfSVJRU0FWRSBpcyBub3Qgc2V0CiMgQ09ORklHX0lOTElORV9XUklURV9VTkxPQ0sgaXMgbm90
IHNldAojIENPTkZJR19JTkxJTkVfV1JJVEVfVU5MT0NLX0JIIGlzIG5vdCBzZXQKIyBDT05GSUdf
SU5MSU5FX1dSSVRFX1VOTE9DS19JUlEgaXMgbm90IHNldAojIENPTkZJR19JTkxJTkVfV1JJVEVf
VU5MT0NLX0lSUVJFU1RPUkUgaXMgbm90IHNldAojIENPTkZJR19NVVRFWF9TUElOX09OX09XTkVS
IGlzIG5vdCBzZXQKQ09ORklHX0ZSRUVaRVI9eQoKIwojIFByb2Nlc3NvciB0eXBlIGFuZCBmZWF0
dXJlcwojCkNPTkZJR19aT05FX0RNQT15CkNPTkZJR19TTVA9eQojIENPTkZJR19YODZfWDJBUElD
IGlzIG5vdCBzZXQKIyBDT05GSUdfWDg2X01QUEFSU0UgaXMgbm90IHNldAojIENPTkZJR19YODZf
RVhURU5ERURfUExBVEZPUk0gaXMgbm90IHNldApDT05GSUdfWDg2X1NVUFBPUlRTX01FTU9SWV9G
QUlMVVJFPXkKQ09ORklHX1NDSEVEX09NSVRfRlJBTUVfUE9JTlRFUj15CiMgQ09ORklHX1BBUkFW
SVJUX0dVRVNUIGlzIG5vdCBzZXQKQ09ORklHX05PX0JPT1RNRU09eQojIENPTkZJR19NRU1URVNU
IGlzIG5vdCBzZXQKIyBDT05GSUdfTUs4IGlzIG5vdCBzZXQKIyBDT05GSUdfTVBTQyBpcyBub3Qg
c2V0CkNPTkZJR19NQ09SRTI9eQojIENPTkZJR19NQVRPTSBpcyBub3Qgc2V0CiMgQ09ORklHX0dF
TkVSSUNfQ1BVIGlzIG5vdCBzZXQKQ09ORklHX1g4Nl9JTlRFUk5PREVfQ0FDSEVfU0hJRlQ9NgpD
T05GSUdfWDg2X0NNUFhDSEc9eQpDT05GSUdfWDg2X0wxX0NBQ0hFX1NISUZUPTYKQ09ORklHX1g4
Nl9YQUREPXkKQ09ORklHX1g4Nl9XUF9XT1JLU19PSz15CkNPTkZJR19YODZfSU5URUxfVVNFUkNP
UFk9eQpDT05GSUdfWDg2X1VTRV9QUFJPX0NIRUNLU1VNPXkKQ09ORklHX1g4Nl9QNl9OT1A9eQpD
T05GSUdfWDg2X1RTQz15CkNPTkZJR19YODZfQ01QWENIRzY0PXkKQ09ORklHX1g4Nl9DTU9WPXkK
Q09ORklHX1g4Nl9NSU5JTVVNX0NQVV9GQU1JTFk9NjQKQ09ORklHX1g4Nl9ERUJVR0NUTE1TUj15
CiMgQ09ORklHX1BST0NFU1NPUl9TRUxFQ1QgaXMgbm90IHNldApDT05GSUdfQ1BVX1NVUF9JTlRF
TD15CkNPTkZJR19DUFVfU1VQX0FNRD15CkNPTkZJR19DUFVfU1VQX0NFTlRBVVI9eQpDT05GSUdf
SFBFVF9USU1FUj15CkNPTkZJR19IUEVUX0VNVUxBVEVfUlRDPXkKQ09ORklHX0RNST15CkNPTkZJ
R19HQVJUX0lPTU1VPXkKIyBDT05GSUdfQ0FMR0FSWV9JT01NVSBpcyBub3Qgc2V0CkNPTkZJR19T
V0lPVExCPXkKQ09ORklHX0lPTU1VX0hFTFBFUj15CiMgQ09ORklHX01BWFNNUCBpcyBub3Qgc2V0
CkNPTkZJR19OUl9DUFVTPTQKIyBDT05GSUdfU0NIRURfU01UIGlzIG5vdCBzZXQKQ09ORklHX1ND
SEVEX01DPXkKIyBDT05GSUdfSVJRX1RJTUVfQUNDT1VOVElORyBpcyBub3Qgc2V0CiMgQ09ORklH
X1BSRUVNUFRfTk9ORSBpcyBub3Qgc2V0CkNPTkZJR19QUkVFTVBUX1ZPTFVOVEFSWT15CiMgQ09O
RklHX1BSRUVNUFQgaXMgbm90IHNldApDT05GSUdfUFJFRU1QVF9DT1VOVD15CkNPTkZJR19YODZf
TE9DQUxfQVBJQz15CkNPTkZJR19YODZfSU9fQVBJQz15CkNPTkZJR19YODZfUkVST1VURV9GT1Jf
QlJPS0VOX0JPT1RfSVJRUz15CkNPTkZJR19YODZfTUNFPXkKQ09ORklHX1g4Nl9NQ0VfSU5URUw9
eQojIENPTkZJR19YODZfTUNFX0FNRCBpcyBub3Qgc2V0CkNPTkZJR19YODZfTUNFX1RIUkVTSE9M
RD15CiMgQ09ORklHX1g4Nl9NQ0VfSU5KRUNUIGlzIG5vdCBzZXQKQ09ORklHX1g4Nl9USEVSTUFM
X1ZFQ1RPUj15CiMgQ09ORklHX0k4SyBpcyBub3Qgc2V0CkNPTkZJR19NSUNST0NPREU9eQpDT05G
SUdfTUlDUk9DT0RFX0lOVEVMPXkKIyBDT05GSUdfTUlDUk9DT0RFX0FNRCBpcyBub3Qgc2V0CkNP
TkZJR19NSUNST0NPREVfT0xEX0lOVEVSRkFDRT15CkNPTkZJR19YODZfTVNSPXkKQ09ORklHX1g4
Nl9DUFVJRD15CkNPTkZJR19BUkNIX1BIWVNfQUREUl9UXzY0QklUPXkKQ09ORklHX0FSQ0hfRE1B
X0FERFJfVF82NEJJVD15CkNPTkZJR19ESVJFQ1RfR0JQQUdFUz15CiMgQ09ORklHX05VTUEgaXMg
bm90IHNldApDT05GSUdfQVJDSF9TUEFSU0VNRU1fRU5BQkxFPXkKQ09ORklHX0FSQ0hfU1BBUlNF
TUVNX0RFRkFVTFQ9eQpDT05GSUdfQVJDSF9TRUxFQ1RfTUVNT1JZX01PREVMPXkKQ09ORklHX0FS
Q0hfUFJPQ19LQ09SRV9URVhUPXkKQ09ORklHX0lMTEVHQUxfUE9JTlRFUl9WQUxVRT0weGRlYWQw
MDAwMDAwMDAwMDAKQ09ORklHX1NFTEVDVF9NRU1PUllfTU9ERUw9eQpDT05GSUdfU1BBUlNFTUVN
X01BTlVBTD15CkNPTkZJR19TUEFSU0VNRU09eQpDT05GSUdfSEFWRV9NRU1PUllfUFJFU0VOVD15
CkNPTkZJR19TUEFSU0VNRU1fRVhUUkVNRT15CkNPTkZJR19TUEFSU0VNRU1fVk1FTU1BUF9FTkFC
TEU9eQpDT05GSUdfU1BBUlNFTUVNX0FMTE9DX01FTV9NQVBfVE9HRVRIRVI9eQpDT05GSUdfU1BB
UlNFTUVNX1ZNRU1NQVA9eQpDT05GSUdfSEFWRV9NRU1CTE9DSz15CkNPTkZJR19IQVZFX01FTUJM
T0NLX05PREVfTUFQPXkKQ09ORklHX0FSQ0hfRElTQ0FSRF9NRU1CTE9DSz15CiMgQ09ORklHX01F
TU9SWV9IT1RQTFVHIGlzIG5vdCBzZXQKQ09ORklHX1BBR0VGTEFHU19FWFRFTkRFRD15CkNPTkZJ
R19TUExJVF9QVExPQ0tfQ1BVUz05OTk5OTkKQ09ORklHX0NPTVBBQ1RJT049eQpDT05GSUdfTUlH
UkFUSU9OPXkKQ09ORklHX1BIWVNfQUREUl9UXzY0QklUPXkKQ09ORklHX1pPTkVfRE1BX0ZMQUc9
MQpDT05GSUdfQk9VTkNFPXkKQ09ORklHX1ZJUlRfVE9fQlVTPXkKQ09ORklHX0tTTT15CkNPTkZJ
R19ERUZBVUxUX01NQVBfTUlOX0FERFI9NjU1MzYKQ09ORklHX0FSQ0hfU1VQUE9SVFNfTUVNT1JZ
X0ZBSUxVUkU9eQojIENPTkZJR19NRU1PUllfRkFJTFVSRSBpcyBub3Qgc2V0CkNPTkZJR19UUkFO
U1BBUkVOVF9IVUdFUEFHRT15CkNPTkZJR19UUkFOU1BBUkVOVF9IVUdFUEFHRV9BTFdBWVM9eQoj
IENPTkZJR19UUkFOU1BBUkVOVF9IVUdFUEFHRV9NQURWSVNFIGlzIG5vdCBzZXQKQ09ORklHX0NS
T1NTX01FTU9SWV9BVFRBQ0g9eQpDT05GSUdfQ0xFQU5DQUNIRT15CiMgQ09ORklHX0ZST05UU1dB
UCBpcyBub3Qgc2V0CkNPTkZJR19YODZfQ0hFQ0tfQklPU19DT1JSVVBUSU9OPXkKQ09ORklHX1g4
Nl9CT09UUEFSQU1fTUVNT1JZX0NPUlJVUFRJT05fQ0hFQ0s9eQpDT05GSUdfWDg2X1JFU0VSVkVf
TE9XPTY0CkNPTkZJR19NVFJSPXkKQ09ORklHX01UUlJfU0FOSVRJWkVSPXkKQ09ORklHX01UUlJf
U0FOSVRJWkVSX0VOQUJMRV9ERUZBVUxUPTAKQ09ORklHX01UUlJfU0FOSVRJWkVSX1NQQVJFX1JF
R19OUl9ERUZBVUxUPTEKQ09ORklHX1g4Nl9QQVQ9eQpDT05GSUdfQVJDSF9VU0VTX1BHX1VOQ0FD
SEVEPXkKQ09ORklHX0FSQ0hfUkFORE9NPXkKIyBDT05GSUdfRUZJIGlzIG5vdCBzZXQKQ09ORklH
X1NFQ0NPTVA9eQpDT05GSUdfQ0NfU1RBQ0tQUk9URUNUT1I9eQojIENPTkZJR19IWl8xMDAgaXMg
bm90IHNldAojIENPTkZJR19IWl8yNTAgaXMgbm90IHNldAojIENPTkZJR19IWl8zMDAgaXMgbm90
IHNldApDT05GSUdfSFpfMTAwMD15CkNPTkZJR19IWj0xMDAwCkNPTkZJR19TQ0hFRF9IUlRJQ0s9
eQojIENPTkZJR19LRVhFQyBpcyBub3Qgc2V0CiMgQ09ORklHX0NSQVNIX0RVTVAgaXMgbm90IHNl
dApDT05GSUdfUEhZU0lDQUxfU1RBUlQ9MHgxMDAwMDAwCiMgQ09ORklHX1JFTE9DQVRBQkxFIGlz
IG5vdCBzZXQKQ09ORklHX1BIWVNJQ0FMX0FMSUdOPTB4MTAwMDAwMApDT05GSUdfSE9UUExVR19D
UFU9eQojIENPTkZJR19DT01QQVRfVkRTTyBpcyBub3Qgc2V0CiMgQ09ORklHX0NNRExJTkVfQk9P
TCBpcyBub3Qgc2V0CkNPTkZJR19BUkNIX0VOQUJMRV9NRU1PUllfSE9UUExVRz15CgojCiMgUG93
ZXIgbWFuYWdlbWVudCBhbmQgQUNQSSBvcHRpb25zCiMKQ09ORklHX1NVU1BFTkQ9eQpDT05GSUdf
U1VTUEVORF9GUkVFWkVSPXkKIyBDT05GSUdfSElCRVJOQVRJT04gaXMgbm90IHNldApDT05GSUdf
UE1fU0xFRVA9eQpDT05GSUdfUE1fU0xFRVBfU01QPXkKIyBDT05GSUdfUE1fQVVUT1NMRUVQIGlz
IG5vdCBzZXQKIyBDT05GSUdfUE1fV0FLRUxPQ0tTIGlzIG5vdCBzZXQKQ09ORklHX1BNX1JVTlRJ
TUU9eQpDT05GSUdfUE09eQpDT05GSUdfUE1fREVCVUc9eQojIENPTkZJR19QTV9BRFZBTkNFRF9E
RUJVRyBpcyBub3Qgc2V0CiMgQ09ORklHX1BNX1RFU1RfU1VTUEVORCBpcyBub3Qgc2V0CkNPTkZJ
R19QTV9TTEVFUF9ERUJVRz15CiMgQ09ORklHX1BNX1RSQUNFX1JUQyBpcyBub3Qgc2V0CkNPTkZJ
R19BQ1BJPXkKQ09ORklHX0FDUElfU0xFRVA9eQojIENPTkZJR19BQ1BJX1BST0NGUyBpcyBub3Qg
c2V0CiMgQ09ORklHX0FDUElfUFJPQ0ZTX1BPV0VSIGlzIG5vdCBzZXQKIyBDT05GSUdfQUNQSV9F
Q19ERUJVR0ZTIGlzIG5vdCBzZXQKIyBDT05GSUdfQUNQSV9QUk9DX0VWRU5UIGlzIG5vdCBzZXQK
IyBDT05GSUdfQUNQSV9BQyBpcyBub3Qgc2V0CiMgQ09ORklHX0FDUElfQkFUVEVSWSBpcyBub3Qg
c2V0CkNPTkZJR19BQ1BJX0JVVFRPTj15CkNPTkZJR19BQ1BJX1ZJREVPPXkKQ09ORklHX0FDUElf
RkFOPXkKQ09ORklHX0FDUElfRE9DSz15CkNPTkZJR19BQ1BJX1BST0NFU1NPUj15CkNPTkZJR19B
Q1BJX0hPVFBMVUdfQ1BVPXkKQ09ORklHX0FDUElfUFJPQ0VTU09SX0FHR1JFR0FUT1I9eQpDT05G
SUdfQUNQSV9USEVSTUFMPXkKIyBDT05GSUdfQUNQSV9DVVNUT01fRFNEVCBpcyBub3Qgc2V0CkNP
TkZJR19BQ1BJX0JMQUNLTElTVF9ZRUFSPTAKIyBDT05GSUdfQUNQSV9ERUJVRyBpcyBub3Qgc2V0
CiMgQ09ORklHX0FDUElfUENJX1NMT1QgaXMgbm90IHNldApDT05GSUdfWDg2X1BNX1RJTUVSPXkK
Q09ORklHX0FDUElfQ09OVEFJTkVSPXkKIyBDT05GSUdfQUNQSV9TQlMgaXMgbm90IHNldApDT05G
SUdfQUNQSV9IRUQ9eQojIENPTkZJR19BQ1BJX0NVU1RPTV9NRVRIT0QgaXMgbm90IHNldAojIENP
TkZJR19BQ1BJX0JHUlQgaXMgbm90IHNldApDT05GSUdfQUNQSV9BUEVJPXkKQ09ORklHX0FDUElf
QVBFSV9HSEVTPXkKQ09ORklHX0FDUElfQVBFSV9QQ0lFQUVSPXkKIyBDT05GSUdfQUNQSV9BUEVJ
X0VJTkogaXMgbm90IHNldAojIENPTkZJR19BQ1BJX0FQRUlfRVJTVF9ERUJVRyBpcyBub3Qgc2V0
CiMgQ09ORklHX1NGSSBpcyBub3Qgc2V0CgojCiMgQ1BVIEZyZXF1ZW5jeSBzY2FsaW5nCiMKQ09O
RklHX0NQVV9GUkVRPXkKQ09ORklHX0NQVV9GUkVRX1RBQkxFPXkKIyBDT05GSUdfQ1BVX0ZSRVFf
U1RBVCBpcyBub3Qgc2V0CiMgQ09ORklHX0NQVV9GUkVRX0RFRkFVTFRfR09WX1BFUkZPUk1BTkNF
IGlzIG5vdCBzZXQKIyBDT05GSUdfQ1BVX0ZSRVFfREVGQVVMVF9HT1ZfUE9XRVJTQVZFIGlzIG5v
dCBzZXQKQ09ORklHX0NQVV9GUkVRX0RFRkFVTFRfR09WX1VTRVJTUEFDRT15CiMgQ09ORklHX0NQ
VV9GUkVRX0RFRkFVTFRfR09WX09OREVNQU5EIGlzIG5vdCBzZXQKIyBDT05GSUdfQ1BVX0ZSRVFf
REVGQVVMVF9HT1ZfQ09OU0VSVkFUSVZFIGlzIG5vdCBzZXQKQ09ORklHX0NQVV9GUkVRX0dPVl9Q
RVJGT1JNQU5DRT15CiMgQ09ORklHX0NQVV9GUkVRX0dPVl9QT1dFUlNBVkUgaXMgbm90IHNldApD
T05GSUdfQ1BVX0ZSRVFfR09WX1VTRVJTUEFDRT15CkNPTkZJR19DUFVfRlJFUV9HT1ZfT05ERU1B
TkQ9eQojIENPTkZJR19DUFVfRlJFUV9HT1ZfQ09OU0VSVkFUSVZFIGlzIG5vdCBzZXQKCiMKIyB4
ODYgQ1BVIGZyZXF1ZW5jeSBzY2FsaW5nIGRyaXZlcnMKIwojIENPTkZJR19YODZfUENDX0NQVUZS
RVEgaXMgbm90IHNldApDT05GSUdfWDg2X0FDUElfQ1BVRlJFUT15CiMgQ09ORklHX1g4Nl9QT1dF
Uk5PV19LOCBpcyBub3Qgc2V0CiMgQ09ORklHX1g4Nl9TUEVFRFNURVBfQ0VOVFJJTk8gaXMgbm90
IHNldAojIENPTkZJR19YODZfUDRfQ0xPQ0tNT0QgaXMgbm90IHNldAoKIwojIHNoYXJlZCBvcHRp
b25zCiMKIyBDT05GSUdfWDg2X1NQRUVEU1RFUF9MSUIgaXMgbm90IHNldApDT05GSUdfQ1BVX0lE
TEU9eQpDT05GSUdfQ1BVX0lETEVfR09WX0xBRERFUj15CkNPTkZJR19DUFVfSURMRV9HT1ZfTUVO
VT15CiMgQ09ORklHX0FSQ0hfTkVFRFNfQ1BVX0lETEVfQ09VUExFRCBpcyBub3Qgc2V0CkNPTkZJ
R19JTlRFTF9JRExFPXkKCiMKIyBNZW1vcnkgcG93ZXIgc2F2aW5ncwojCiMgQ09ORklHX0k3MzAw
X0lETEUgaXMgbm90IHNldAoKIwojIEJ1cyBvcHRpb25zIChQQ0kgZXRjLikKIwpDT05GSUdfUENJ
PXkKQ09ORklHX1BDSV9ESVJFQ1Q9eQojIENPTkZJR19QQ0lfTU1DT05GSUcgaXMgbm90IHNldApD
T05GSUdfUENJX0RPTUFJTlM9eQojIENPTkZJR19QQ0lfQ05CMjBMRV9RVUlSSyBpcyBub3Qgc2V0
CkNPTkZJR19QQ0lFUE9SVEJVUz15CkNPTkZJR19QQ0lFQUVSPXkKIyBDT05GSUdfUENJRV9FQ1JD
IGlzIG5vdCBzZXQKIyBDT05GSUdfUENJRUFFUl9JTkpFQ1QgaXMgbm90IHNldApDT05GSUdfUENJ
RUFTUE09eQpDT05GSUdfUENJRUFTUE1fREVCVUc9eQpDT05GSUdfUENJRUFTUE1fREVGQVVMVD15
CiMgQ09ORklHX1BDSUVBU1BNX1BPV0VSU0FWRSBpcyBub3Qgc2V0CiMgQ09ORklHX1BDSUVBU1BN
X1BFUkZPUk1BTkNFIGlzIG5vdCBzZXQKQ09ORklHX1BDSUVfUE1FPXkKQ09ORklHX0FSQ0hfU1VQ
UE9SVFNfTVNJPXkKQ09ORklHX1BDSV9NU0k9eQojIENPTkZJR19QQ0lfREVCVUcgaXMgbm90IHNl
dAojIENPTkZJR19QQ0lfUkVBTExPQ19FTkFCTEVfQVVUTyBpcyBub3Qgc2V0CiMgQ09ORklHX1BD
SV9TVFVCIGlzIG5vdCBzZXQKQ09ORklHX0hUX0lSUT15CkNPTkZJR19QQ0lfQVRTPXkKQ09ORklH
X1BDSV9JT1Y9eQojIENPTkZJR19QQ0lfUFJJIGlzIG5vdCBzZXQKIyBDT05GSUdfUENJX1BBU0lE
IGlzIG5vdCBzZXQKQ09ORklHX1BDSV9JT0FQSUM9eQpDT05GSUdfUENJX0xBQkVMPXkKQ09ORklH
X0lTQV9ETUFfQVBJPXkKQ09ORklHX0FNRF9OQj15CkNPTkZJR19QQ0NBUkQ9eQpDT05GSUdfUENN
Q0lBPXkKIyBDT05GSUdfUENNQ0lBX0xPQURfQ0lTIGlzIG5vdCBzZXQKQ09ORklHX0NBUkRCVVM9
eQoKIwojIFBDLWNhcmQgYnJpZGdlcwojCkNPTkZJR19ZRU5UQT15CkNPTkZJR19ZRU5UQV9PMj15
CkNPTkZJR19ZRU5UQV9SSUNPSD15CkNPTkZJR19ZRU5UQV9UST15CkNPTkZJR19ZRU5UQV9FTkVf
VFVORT15CkNPTkZJR19ZRU5UQV9UT1NISUJBPXkKIyBDT05GSUdfUEQ2NzI5IGlzIG5vdCBzZXQK
IyBDT05GSUdfSTgyMDkyIGlzIG5vdCBzZXQKQ09ORklHX1BDQ0FSRF9OT05TVEFUSUM9eQojIENP
TkZJR19IT1RQTFVHX1BDSSBpcyBub3Qgc2V0CiMgQ09ORklHX1JBUElESU8gaXMgbm90IHNldAoK
IwojIEV4ZWN1dGFibGUgZmlsZSBmb3JtYXRzIC8gRW11bGF0aW9ucwojCkNPTkZJR19CSU5GTVRf
RUxGPXkKQ09ORklHX0NPTVBBVF9CSU5GTVRfRUxGPXkKQ09ORklHX0FSQ0hfQklORk1UX0VMRl9S
QU5ET01JWkVfUElFPXkKQ09ORklHX0NPUkVfRFVNUF9ERUZBVUxUX0VMRl9IRUFERVJTPXkKIyBD
T05GSUdfSEFWRV9BT1VUIGlzIG5vdCBzZXQKQ09ORklHX0JJTkZNVF9NSVNDPXkKQ09ORklHX0lB
MzJfRU1VTEFUSU9OPXkKIyBDT05GSUdfSUEzMl9BT1VUIGlzIG5vdCBzZXQKIyBDT05GSUdfWDg2
X1gzMiBpcyBub3Qgc2V0CkNPTkZJR19DT01QQVQ9eQpDT05GSUdfQ09NUEFUX0ZPUl9VNjRfQUxJ
R05NRU5UPXkKQ09ORklHX1NZU1ZJUENfQ09NUEFUPXkKQ09ORklHX0hBVkVfVEVYVF9QT0tFX1NN
UD15CkNPTkZJR19YODZfREVWX0RNQV9PUFM9eQpDT05GSUdfTkVUPXkKQ09ORklHX0NPTVBBVF9O
RVRMSU5LX01FU1NBR0VTPXkKCiMKIyBOZXR3b3JraW5nIG9wdGlvbnMKIwpDT05GSUdfUEFDS0VU
PXkKQ09ORklHX1VOSVg9eQpDT05GSUdfVU5JWF9ESUFHPXkKQ09ORklHX1hGUk09eQpDT05GSUdf
WEZSTV9BTEdPPXkKQ09ORklHX1hGUk1fVVNFUj15CiMgQ09ORklHX1hGUk1fU1VCX1BPTElDWSBp
cyBub3Qgc2V0CiMgQ09ORklHX1hGUk1fTUlHUkFURSBpcyBub3Qgc2V0CiMgQ09ORklHX1hGUk1f
U1RBVElTVElDUyBpcyBub3Qgc2V0CiMgQ09ORklHX05FVF9LRVkgaXMgbm90IHNldApDT05GSUdf
SU5FVD15CkNPTkZJR19JUF9NVUxUSUNBU1Q9eQojIENPTkZJR19JUF9BRFZBTkNFRF9ST1VURVIg
aXMgbm90IHNldAojIENPTkZJR19JUF9QTlAgaXMgbm90IHNldAojIENPTkZJR19ORVRfSVBJUCBp
cyBub3Qgc2V0CiMgQ09ORklHX05FVF9JUEdSRV9ERU1VWCBpcyBub3Qgc2V0CiMgQ09ORklHX0lQ
X01ST1VURSBpcyBub3Qgc2V0CiMgQ09ORklHX0FSUEQgaXMgbm90IHNldAojIENPTkZJR19TWU5f
Q09PS0lFUyBpcyBub3Qgc2V0CiMgQ09ORklHX0lORVRfQUggaXMgbm90IHNldAojIENPTkZJR19J
TkVUX0VTUCBpcyBub3Qgc2V0CiMgQ09ORklHX0lORVRfSVBDT01QIGlzIG5vdCBzZXQKIyBDT05G
SUdfSU5FVF9YRlJNX1RVTk5FTCBpcyBub3Qgc2V0CiMgQ09ORklHX0lORVRfVFVOTkVMIGlzIG5v
dCBzZXQKIyBDT05GSUdfSU5FVF9YRlJNX01PREVfVFJBTlNQT1JUIGlzIG5vdCBzZXQKIyBDT05G
SUdfSU5FVF9YRlJNX01PREVfVFVOTkVMIGlzIG5vdCBzZXQKIyBDT05GSUdfSU5FVF9YRlJNX01P
REVfQkVFVCBpcyBub3Qgc2V0CkNPTkZJR19JTkVUX0xSTz15CiMgQ09ORklHX0lORVRfRElBRyBp
cyBub3Qgc2V0CiMgQ09ORklHX1RDUF9DT05HX0FEVkFOQ0VEIGlzIG5vdCBzZXQKQ09ORklHX1RD
UF9DT05HX0NVQklDPXkKQ09ORklHX0RFRkFVTFRfVENQX0NPTkc9ImN1YmljIgojIENPTkZJR19U
Q1BfTUQ1U0lHIGlzIG5vdCBzZXQKIyBDT05GSUdfSVBWNiBpcyBub3Qgc2V0CkNPTkZJR19ORVRX
T1JLX1NFQ01BUks9eQojIENPTkZJR19ORVRXT1JLX1BIWV9USU1FU1RBTVBJTkcgaXMgbm90IHNl
dAojIENPTkZJR19ORVRGSUxURVIgaXMgbm90IHNldAojIENPTkZJR19JUF9EQ0NQIGlzIG5vdCBz
ZXQKIyBDT05GSUdfSVBfU0NUUCBpcyBub3Qgc2V0CiMgQ09ORklHX1JEUyBpcyBub3Qgc2V0CiMg
Q09ORklHX1RJUEMgaXMgbm90IHNldAojIENPTkZJR19BVE0gaXMgbm90IHNldAojIENPTkZJR19M
MlRQIGlzIG5vdCBzZXQKIyBDT05GSUdfQlJJREdFIGlzIG5vdCBzZXQKIyBDT05GSUdfTkVUX0RT
QSBpcyBub3Qgc2V0CiMgQ09ORklHX1ZMQU5fODAyMVEgaXMgbm90IHNldAojIENPTkZJR19ERUNO
RVQgaXMgbm90IHNldAojIENPTkZJR19MTEMyIGlzIG5vdCBzZXQKIyBDT05GSUdfSVBYIGlzIG5v
dCBzZXQKIyBDT05GSUdfQVRBTEsgaXMgbm90IHNldAojIENPTkZJR19YMjUgaXMgbm90IHNldAoj
IENPTkZJR19MQVBCIGlzIG5vdCBzZXQKIyBDT05GSUdfV0FOX1JPVVRFUiBpcyBub3Qgc2V0CiMg
Q09ORklHX1BIT05FVCBpcyBub3Qgc2V0CiMgQ09ORklHX0lFRUU4MDIxNTQgaXMgbm90IHNldAoj
IENPTkZJR19ORVRfU0NIRUQgaXMgbm90IHNldAojIENPTkZJR19EQ0IgaXMgbm90IHNldAojIENP
TkZJR19CQVRNQU5fQURWIGlzIG5vdCBzZXQKIyBDT05GSUdfT1BFTlZTV0lUQ0ggaXMgbm90IHNl
dApDT05GSUdfUlBTPXkKQ09ORklHX1JGU19BQ0NFTD15CkNPTkZJR19YUFM9eQojIENPTkZJR19O
RVRQUklPX0NHUk9VUCBpcyBub3Qgc2V0CkNPTkZJR19CUUw9eQojIENPTkZJR19CUEZfSklUIGlz
IG5vdCBzZXQKCiMKIyBOZXR3b3JrIHRlc3RpbmcKIwojIENPTkZJR19ORVRfUEtUR0VOIGlzIG5v
dCBzZXQKIyBDT05GSUdfTkVUX0RST1BfTU9OSVRPUiBpcyBub3Qgc2V0CiMgQ09ORklHX0hBTVJB
RElPIGlzIG5vdCBzZXQKIyBDT05GSUdfQ0FOIGlzIG5vdCBzZXQKIyBDT05GSUdfSVJEQSBpcyBu
b3Qgc2V0CiMgQ09ORklHX0JUIGlzIG5vdCBzZXQKIyBDT05GSUdfQUZfUlhSUEMgaXMgbm90IHNl
dApDT05GSUdfV0lSRUxFU1M9eQpDT05GSUdfV0lSRUxFU1NfRVhUPXkKQ09ORklHX1dFWFRfQ09S
RT15CkNPTkZJR19XRVhUX1BST0M9eQpDT05GSUdfV0VYVF9TUFk9eQpDT05GSUdfV0VYVF9QUklW
PXkKQ09ORklHX0NGRzgwMjExPW0KIyBDT05GSUdfTkw4MDIxMV9URVNUTU9ERSBpcyBub3Qgc2V0
CkNPTkZJR19DRkc4MDIxMV9ERVZFTE9QRVJfV0FSTklOR1M9eQpDT05GSUdfQ0ZHODAyMTFfUkVH
X0RFQlVHPXkKIyBDT05GSUdfQ0ZHODAyMTFfQ0VSVElGSUNBVElPTl9PTlVTIGlzIG5vdCBzZXQK
Q09ORklHX0NGRzgwMjExX0RFRkFVTFRfUFM9eQpDT05GSUdfQ0ZHODAyMTFfREVCVUdGUz15CiMg
Q09ORklHX0NGRzgwMjExX0lOVEVSTkFMX1JFR0RCIGlzIG5vdCBzZXQKQ09ORklHX0NGRzgwMjEx
X1dFWFQ9eQpDT05GSUdfTElCODAyMTE9bQpDT05GSUdfTElCODAyMTFfQ1JZUFRfV0VQPW0KQ09O
RklHX0xJQjgwMjExX0NSWVBUX0NDTVA9bQpDT05GSUdfTElCODAyMTFfQ1JZUFRfVEtJUD1tCiMg
Q09ORklHX0xJQjgwMjExX0RFQlVHIGlzIG5vdCBzZXQKQ09ORklHX01BQzgwMjExPW0KQ09ORklH
X01BQzgwMjExX0hBU19SQz15CkNPTkZJR19NQUM4MDIxMV9SQ19QSUQ9eQpDT05GSUdfTUFDODAy
MTFfUkNfTUlOU1RSRUw9eQpDT05GSUdfTUFDODAyMTFfUkNfTUlOU1RSRUxfSFQ9eQojIENPTkZJ
R19NQUM4MDIxMV9SQ19ERUZBVUxUX1BJRCBpcyBub3Qgc2V0CkNPTkZJR19NQUM4MDIxMV9SQ19E
RUZBVUxUX01JTlNUUkVMPXkKQ09ORklHX01BQzgwMjExX1JDX0RFRkFVTFQ9Im1pbnN0cmVsX2h0
IgojIENPTkZJR19NQUM4MDIxMV9NRVNIIGlzIG5vdCBzZXQKQ09ORklHX01BQzgwMjExX0xFRFM9
eQpDT05GSUdfTUFDODAyMTFfREVCVUdGUz15CiMgQ09ORklHX01BQzgwMjExX01FU1NBR0VfVFJB
Q0lORyBpcyBub3Qgc2V0CkNPTkZJR19NQUM4MDIxMV9ERUJVR19NRU5VPXkKQ09ORklHX01BQzgw
MjExX05PSU5MSU5FPXkKQ09ORklHX01BQzgwMjExX1ZFUkJPU0VfREVCVUc9eQojIENPTkZJR19N
QUM4MDIxMV9NTE1FX0RFQlVHIGlzIG5vdCBzZXQKIyBDT05GSUdfTUFDODAyMTFfU1RBX0RFQlVH
IGlzIG5vdCBzZXQKQ09ORklHX01BQzgwMjExX0hUX0RFQlVHPXkKQ09ORklHX01BQzgwMjExX0lC
U1NfREVCVUc9eQojIENPTkZJR19NQUM4MDIxMV9QU19ERUJVRyBpcyBub3Qgc2V0CiMgQ09ORklH
X01BQzgwMjExX1RETFNfREVCVUcgaXMgbm90IHNldApDT05GSUdfTUFDODAyMTFfREVCVUdfQ09V
TlRFUlM9eQojIENPTkZJR19XSU1BWCBpcyBub3Qgc2V0CkNPTkZJR19SRktJTEw9eQpDT05GSUdf
UkZLSUxMX0xFRFM9eQpDT05GSUdfUkZLSUxMX0lOUFVUPXkKIyBDT05GSUdfTkVUXzlQIGlzIG5v
dCBzZXQKIyBDT05GSUdfQ0FJRiBpcyBub3Qgc2V0CiMgQ09ORklHX0NFUEhfTElCIGlzIG5vdCBz
ZXQKIyBDT05GSUdfTkZDIGlzIG5vdCBzZXQKQ09ORklHX0hBVkVfQlBGX0pJVD15CgojCiMgRGV2
aWNlIERyaXZlcnMKIwoKIwojIEdlbmVyaWMgRHJpdmVyIE9wdGlvbnMKIwpDT05GSUdfVUVWRU5U
X0hFTFBFUl9QQVRIPSIvc2Jpbi9ob3RwbHVnIgpDT05GSUdfREVWVE1QRlM9eQpDT05GSUdfREVW
VE1QRlNfTU9VTlQ9eQpDT05GSUdfU1RBTkRBTE9ORT15CkNPTkZJR19QUkVWRU5UX0ZJUk1XQVJF
X0JVSUxEPXkKQ09ORklHX0ZXX0xPQURFUj15CkNPTkZJR19GSVJNV0FSRV9JTl9LRVJORUw9eQpD
T05GSUdfRVhUUkFfRklSTVdBUkU9IiIKIyBDT05GSUdfREVCVUdfRFJJVkVSIGlzIG5vdCBzZXQK
Q09ORklHX0RFQlVHX0RFVlJFUz15CiMgQ09ORklHX1NZU19IWVBFUlZJU09SIGlzIG5vdCBzZXQK
IyBDT05GSUdfR0VORVJJQ19DUFVfREVWSUNFUyBpcyBub3Qgc2V0CkNPTkZJR19ETUFfU0hBUkVE
X0JVRkZFUj15CkNPTkZJR19DT05ORUNUT1I9eQpDT05GSUdfUFJPQ19FVkVOVFM9eQojIENPTkZJ
R19NVEQgaXMgbm90IHNldAojIENPTkZJR19QQVJQT1JUIGlzIG5vdCBzZXQKQ09ORklHX1BOUD15
CkNPTkZJR19QTlBfREVCVUdfTUVTU0FHRVM9eQoKIwojIFByb3RvY29scwojCkNPTkZJR19QTlBB
Q1BJPXkKQ09ORklHX0JMS19ERVY9eQojIENPTkZJR19CTEtfREVWX0ZEIGlzIG5vdCBzZXQKIyBD
T05GSUdfQkxLX0RFVl9QQ0lFU1NEX01USVAzMlhYIGlzIG5vdCBzZXQKIyBDT05GSUdfQkxLX0NQ
UV9EQSBpcyBub3Qgc2V0CiMgQ09ORklHX0JMS19DUFFfQ0lTU19EQSBpcyBub3Qgc2V0CiMgQ09O
RklHX0JMS19ERVZfREFDOTYwIGlzIG5vdCBzZXQKIyBDT05GSUdfQkxLX0RFVl9VTUVNIGlzIG5v
dCBzZXQKIyBDT05GSUdfQkxLX0RFVl9DT1dfQ09NTU9OIGlzIG5vdCBzZXQKQ09ORklHX0JMS19E
RVZfTE9PUD15CkNPTkZJR19CTEtfREVWX0xPT1BfTUlOX0NPVU5UPTgKIyBDT05GSUdfQkxLX0RF
Vl9DUllQVE9MT09QIGlzIG5vdCBzZXQKIyBDT05GSUdfQkxLX0RFVl9EUkJEIGlzIG5vdCBzZXQK
IyBDT05GSUdfQkxLX0RFVl9OQkQgaXMgbm90IHNldAojIENPTkZJR19CTEtfREVWX05WTUUgaXMg
bm90IHNldAojIENPTkZJR19CTEtfREVWX1NYOCBpcyBub3Qgc2V0CiMgQ09ORklHX0JMS19ERVZf
VUIgaXMgbm90IHNldAojIENPTkZJR19CTEtfREVWX1JBTSBpcyBub3Qgc2V0CiMgQ09ORklHX0NE
Uk9NX1BLVENEVkQgaXMgbm90IHNldAojIENPTkZJR19BVEFfT1ZFUl9FVEggaXMgbm90IHNldAoj
IENPTkZJR19CTEtfREVWX0hEIGlzIG5vdCBzZXQKIyBDT05GSUdfQkxLX0RFVl9SQkQgaXMgbm90
IHNldAoKIwojIE1pc2MgZGV2aWNlcwojCiMgQ09ORklHX1NFTlNPUlNfTElTM0xWMDJEIGlzIG5v
dCBzZXQKIyBDT05GSUdfQUQ1MjVYX0RQT1QgaXMgbm90IHNldAojIENPTkZJR19JQk1fQVNNIGlz
IG5vdCBzZXQKIyBDT05GSUdfUEhBTlRPTSBpcyBub3Qgc2V0CiMgQ09ORklHX0lOVEVMX01JRF9Q
VEkgaXMgbm90IHNldAojIENPTkZJR19TR0lfSU9DNCBpcyBub3Qgc2V0CiMgQ09ORklHX1RJRk1f
Q09SRSBpcyBub3Qgc2V0CiMgQ09ORklHX0lDUzkzMlM0MDEgaXMgbm90IHNldAojIENPTkZJR19F
TkNMT1NVUkVfU0VSVklDRVMgaXMgbm90IHNldAojIENPTkZJR19IUF9JTE8gaXMgbm90IHNldAoj
IENPTkZJR19BUERTOTgwMkFMUyBpcyBub3Qgc2V0CiMgQ09ORklHX0lTTDI5MDAzIGlzIG5vdCBz
ZXQKIyBDT05GSUdfSVNMMjkwMjAgaXMgbm90IHNldAojIENPTkZJR19TRU5TT1JTX1RTTDI1NTAg
aXMgbm90IHNldAojIENPTkZJR19TRU5TT1JTX0JIMTc4MCBpcyBub3Qgc2V0CiMgQ09ORklHX1NF
TlNPUlNfQkgxNzcwIGlzIG5vdCBzZXQKIyBDT05GSUdfU0VOU09SU19BUERTOTkwWCBpcyBub3Qg
c2V0CiMgQ09ORklHX0hNQzYzNTIgaXMgbm90IHNldAojIENPTkZJR19EUzE2ODIgaXMgbm90IHNl
dAojIENPTkZJR19WTVdBUkVfQkFMTE9PTiBpcyBub3Qgc2V0CiMgQ09ORklHX0JNUDA4NV9JMkMg
aXMgbm90IHNldAojIENPTkZJR19QQ0hfUEhVQiBpcyBub3Qgc2V0CiMgQ09ORklHX1VTQl9TV0lU
Q0hfRlNBOTQ4MCBpcyBub3Qgc2V0CiMgQ09ORklHX0MyUE9SVCBpcyBub3Qgc2V0CgojCiMgRUVQ
Uk9NIHN1cHBvcnQKIwojIENPTkZJR19FRVBST01fQVQyNCBpcyBub3Qgc2V0CiMgQ09ORklHX0VF
UFJPTV9MRUdBQ1kgaXMgbm90IHNldAojIENPTkZJR19FRVBST01fTUFYNjg3NSBpcyBub3Qgc2V0
CiMgQ09ORklHX0VFUFJPTV85M0NYNiBpcyBub3Qgc2V0CiMgQ09ORklHX0NCNzEwX0NPUkUgaXMg
bm90IHNldAoKIwojIFRleGFzIEluc3RydW1lbnRzIHNoYXJlZCB0cmFuc3BvcnQgbGluZSBkaXNj
aXBsaW5lCiMKIyBDT05GSUdfU0VOU09SU19MSVMzX0kyQyBpcyBub3Qgc2V0CgojCiMgQWx0ZXJh
IEZQR0EgZmlybXdhcmUgZG93bmxvYWQgbW9kdWxlCiMKIyBDT05GSUdfQUxURVJBX1NUQVBMIGlz
IG5vdCBzZXQKIyBDT05GSUdfSU5URUxfTUVJIGlzIG5vdCBzZXQKQ09ORklHX0hBVkVfSURFPXkK
IyBDT05GSUdfSURFIGlzIG5vdCBzZXQKCiMKIyBTQ1NJIGRldmljZSBzdXBwb3J0CiMKQ09ORklH
X1NDU0lfTU9EPXkKIyBDT05GSUdfUkFJRF9BVFRSUyBpcyBub3Qgc2V0CkNPTkZJR19TQ1NJPXkK
Q09ORklHX1NDU0lfRE1BPXkKIyBDT05GSUdfU0NTSV9UR1QgaXMgbm90IHNldAojIENPTkZJR19T
Q1NJX05FVExJTksgaXMgbm90IHNldAojIENPTkZJR19TQ1NJX1BST0NfRlMgaXMgbm90IHNldAoK
IwojIFNDU0kgc3VwcG9ydCB0eXBlIChkaXNrLCB0YXBlLCBDRC1ST00pCiMKQ09ORklHX0JMS19E
RVZfU0Q9eQojIENPTkZJR19DSFJfREVWX1NUIGlzIG5vdCBzZXQKIyBDT05GSUdfQ0hSX0RFVl9P
U1NUIGlzIG5vdCBzZXQKQ09ORklHX0JMS19ERVZfU1I9eQpDT05GSUdfQkxLX0RFVl9TUl9WRU5E
T1I9eQpDT05GSUdfQ0hSX0RFVl9TRz15CiMgQ09ORklHX0NIUl9ERVZfU0NIIGlzIG5vdCBzZXQK
IyBDT05GSUdfU0NTSV9NVUxUSV9MVU4gaXMgbm90IHNldApDT05GSUdfU0NTSV9DT05TVEFOVFM9
eQojIENPTkZJR19TQ1NJX0xPR0dJTkcgaXMgbm90IHNldAojIENPTkZJR19TQ1NJX1NDQU5fQVNZ
TkMgaXMgbm90IHNldAoKIwojIFNDU0kgVHJhbnNwb3J0cwojCkNPTkZJR19TQ1NJX1NQSV9BVFRS
Uz15CiMgQ09ORklHX1NDU0lfRkNfQVRUUlMgaXMgbm90IHNldAojIENPTkZJR19TQ1NJX0lTQ1NJ
X0FUVFJTIGlzIG5vdCBzZXQKIyBDT05GSUdfU0NTSV9TQVNfQVRUUlMgaXMgbm90IHNldAojIENP
TkZJR19TQ1NJX1NBU19MSUJTQVMgaXMgbm90IHNldAojIENPTkZJR19TQ1NJX1NSUF9BVFRSUyBp
cyBub3Qgc2V0CiMgQ09ORklHX1NDU0lfTE9XTEVWRUwgaXMgbm90IHNldAojIENPTkZJR19TQ1NJ
X0xPV0xFVkVMX1BDTUNJQSBpcyBub3Qgc2V0CiMgQ09ORklHX1NDU0lfREggaXMgbm90IHNldAoj
IENPTkZJR19TQ1NJX09TRF9JTklUSUFUT1IgaXMgbm90IHNldApDT05GSUdfQVRBPXkKIyBDT05G
SUdfQVRBX05PTlNUQU5EQVJEIGlzIG5vdCBzZXQKQ09ORklHX0FUQV9WRVJCT1NFX0VSUk9SPXkK
Q09ORklHX0FUQV9BQ1BJPXkKIyBDT05GSUdfU0FUQV9QTVAgaXMgbm90IHNldAoKIwojIENvbnRy
b2xsZXJzIHdpdGggbm9uLVNGRiBuYXRpdmUgaW50ZXJmYWNlCiMKIyBDT05GSUdfU0FUQV9BSENJ
IGlzIG5vdCBzZXQKIyBDT05GSUdfU0FUQV9BSENJX1BMQVRGT1JNIGlzIG5vdCBzZXQKIyBDT05G
SUdfU0FUQV9JTklDMTYyWCBpcyBub3Qgc2V0CiMgQ09ORklHX1NBVEFfQUNBUkRfQUhDSSBpcyBu
b3Qgc2V0CiMgQ09ORklHX1NBVEFfU0lMMjQgaXMgbm90IHNldApDT05GSUdfQVRBX1NGRj15Cgoj
CiMgU0ZGIGNvbnRyb2xsZXJzIHdpdGggY3VzdG9tIERNQSBpbnRlcmZhY2UKIwojIENPTkZJR19Q
RENfQURNQSBpcyBub3Qgc2V0CiMgQ09ORklHX1NBVEFfUVNUT1IgaXMgbm90IHNldAojIENPTkZJ
R19TQVRBX1NYNCBpcyBub3Qgc2V0CkNPTkZJR19BVEFfQk1ETUE9eQoKIwojIFNBVEEgU0ZGIGNv
bnRyb2xsZXJzIHdpdGggQk1ETUEKIwpDT05GSUdfQVRBX1BJSVg9eQojIENPTkZJR19TQVRBX01W
IGlzIG5vdCBzZXQKIyBDT05GSUdfU0FUQV9OViBpcyBub3Qgc2V0CiMgQ09ORklHX1NBVEFfUFJP
TUlTRSBpcyBub3Qgc2V0CiMgQ09ORklHX1NBVEFfU0lMIGlzIG5vdCBzZXQKIyBDT05GSUdfU0FU
QV9TSVMgaXMgbm90IHNldAojIENPTkZJR19TQVRBX1NWVyBpcyBub3Qgc2V0CiMgQ09ORklHX1NB
VEFfVUxJIGlzIG5vdCBzZXQKIyBDT05GSUdfU0FUQV9WSUEgaXMgbm90IHNldAojIENPTkZJR19T
QVRBX1ZJVEVTU0UgaXMgbm90IHNldAoKIwojIFBBVEEgU0ZGIGNvbnRyb2xsZXJzIHdpdGggQk1E
TUEKIwojIENPTkZJR19QQVRBX0FMSSBpcyBub3Qgc2V0CiMgQ09ORklHX1BBVEFfQU1EIGlzIG5v
dCBzZXQKIyBDT05GSUdfUEFUQV9BUlRPUCBpcyBub3Qgc2V0CiMgQ09ORklHX1BBVEFfQVRJSVhQ
IGlzIG5vdCBzZXQKIyBDT05GSUdfUEFUQV9BVFA4NjdYIGlzIG5vdCBzZXQKIyBDT05GSUdfUEFU
QV9DTUQ2NFggaXMgbm90IHNldAojIENPTkZJR19QQVRBX0NTNTUyMCBpcyBub3Qgc2V0CiMgQ09O
RklHX1BBVEFfQ1M1NTMwIGlzIG5vdCBzZXQKIyBDT05GSUdfUEFUQV9DUzU1MzYgaXMgbm90IHNl
dAojIENPTkZJR19QQVRBX0NZUFJFU1MgaXMgbm90IHNldAojIENPTkZJR19QQVRBX0VGQVIgaXMg
bm90IHNldAojIENPTkZJR19QQVRBX0hQVDM2NiBpcyBub3Qgc2V0CiMgQ09ORklHX1BBVEFfSFBU
MzdYIGlzIG5vdCBzZXQKIyBDT05GSUdfUEFUQV9IUFQzWDJOIGlzIG5vdCBzZXQKIyBDT05GSUdf
UEFUQV9IUFQzWDMgaXMgbm90IHNldAojIENPTkZJR19QQVRBX0lUODIxMyBpcyBub3Qgc2V0CiMg
Q09ORklHX1BBVEFfSVQ4MjFYIGlzIG5vdCBzZXQKIyBDT05GSUdfUEFUQV9KTUlDUk9OIGlzIG5v
dCBzZXQKIyBDT05GSUdfUEFUQV9NQVJWRUxMIGlzIG5vdCBzZXQKIyBDT05GSUdfUEFUQV9ORVRD
RUxMIGlzIG5vdCBzZXQKIyBDT05GSUdfUEFUQV9OSU5KQTMyIGlzIG5vdCBzZXQKIyBDT05GSUdf
UEFUQV9OUzg3NDE1IGlzIG5vdCBzZXQKIyBDT05GSUdfUEFUQV9PTERQSUlYIGlzIG5vdCBzZXQK
IyBDT05GSUdfUEFUQV9PUFRJRE1BIGlzIG5vdCBzZXQKIyBDT05GSUdfUEFUQV9QREMyMDI3WCBp
cyBub3Qgc2V0CiMgQ09ORklHX1BBVEFfUERDX09MRCBpcyBub3Qgc2V0CiMgQ09ORklHX1BBVEFf
UkFESVNZUyBpcyBub3Qgc2V0CiMgQ09ORklHX1BBVEFfUkRDIGlzIG5vdCBzZXQKIyBDT05GSUdf
UEFUQV9TQzEyMDAgaXMgbm90IHNldAojIENPTkZJR19QQVRBX1NDSCBpcyBub3Qgc2V0CiMgQ09O
RklHX1BBVEFfU0VSVkVSV09SS1MgaXMgbm90IHNldAojIENPTkZJR19QQVRBX1NJTDY4MCBpcyBu
b3Qgc2V0CiMgQ09ORklHX1BBVEFfU0lTIGlzIG5vdCBzZXQKIyBDT05GSUdfUEFUQV9UT1NISUJB
IGlzIG5vdCBzZXQKIyBDT05GSUdfUEFUQV9UUklGTEVYIGlzIG5vdCBzZXQKIyBDT05GSUdfUEFU
QV9WSUEgaXMgbm90IHNldAojIENPTkZJR19QQVRBX1dJTkJPTkQgaXMgbm90IHNldAoKIwojIFBJ
Ty1vbmx5IFNGRiBjb250cm9sbGVycwojCiMgQ09ORklHX1BBVEFfQ01ENjQwX1BDSSBpcyBub3Qg
c2V0CiMgQ09ORklHX1BBVEFfTVBJSVggaXMgbm90IHNldAojIENPTkZJR19QQVRBX05TODc0MTAg
aXMgbm90IHNldAojIENPTkZJR19QQVRBX09QVEkgaXMgbm90IHNldAojIENPTkZJR19QQVRBX1BD
TUNJQSBpcyBub3Qgc2V0CiMgQ09ORklHX1BBVEFfUExBVEZPUk0gaXMgbm90IHNldAojIENPTkZJ
R19QQVRBX1JaMTAwMCBpcyBub3Qgc2V0CgojCiMgR2VuZXJpYyBmYWxsYmFjayAvIGxlZ2FjeSBk
cml2ZXJzCiMKIyBDT05GSUdfUEFUQV9BQ1BJIGlzIG5vdCBzZXQKIyBDT05GSUdfQVRBX0dFTkVS
SUMgaXMgbm90IHNldAojIENPTkZJR19QQVRBX0xFR0FDWSBpcyBub3Qgc2V0CiMgQ09ORklHX01E
IGlzIG5vdCBzZXQKIyBDT05GSUdfVEFSR0VUX0NPUkUgaXMgbm90IHNldAojIENPTkZJR19GVVNJ
T04gaXMgbm90IHNldAoKIwojIElFRUUgMTM5NCAoRmlyZVdpcmUpIHN1cHBvcnQKIwojIENPTkZJ
R19GSVJFV0lSRSBpcyBub3Qgc2V0CiMgQ09ORklHX0ZJUkVXSVJFX05PU1kgaXMgbm90IHNldAoj
IENPTkZJR19JMk8gaXMgbm90IHNldAojIENPTkZJR19NQUNJTlRPU0hfRFJJVkVSUyBpcyBub3Qg
c2V0CkNPTkZJR19ORVRERVZJQ0VTPXkKQ09ORklHX05FVF9DT1JFPXkKIyBDT05GSUdfQk9ORElO
RyBpcyBub3Qgc2V0CiMgQ09ORklHX0RVTU1ZIGlzIG5vdCBzZXQKIyBDT05GSUdfRVFVQUxJWkVS
IGlzIG5vdCBzZXQKIyBDT05GSUdfTkVUX0ZDIGlzIG5vdCBzZXQKQ09ORklHX01JST15CiMgQ09O
RklHX05FVF9URUFNIGlzIG5vdCBzZXQKIyBDT05GSUdfTUFDVkxBTiBpcyBub3Qgc2V0CiMgQ09O
RklHX05FVENPTlNPTEUgaXMgbm90IHNldAojIENPTkZJR19ORVRQT0xMIGlzIG5vdCBzZXQKIyBD
T05GSUdfTkVUX1BPTExfQ09OVFJPTExFUiBpcyBub3Qgc2V0CiMgQ09ORklHX1RVTiBpcyBub3Qg
c2V0CiMgQ09ORklHX1ZFVEggaXMgbm90IHNldAojIENPTkZJR19BUkNORVQgaXMgbm90IHNldAoK
IwojIENBSUYgdHJhbnNwb3J0IGRyaXZlcnMKIwpDT05GSUdfRVRIRVJORVQ9eQojIENPTkZJR19O
RVRfVkVORE9SXzNDT00gaXMgbm90IHNldAojIENPTkZJR19ORVRfVkVORE9SX0FEQVBURUMgaXMg
bm90IHNldAojIENPTkZJR19ORVRfVkVORE9SX0FMVEVPTiBpcyBub3Qgc2V0CiMgQ09ORklHX05F
VF9WRU5ET1JfQU1EIGlzIG5vdCBzZXQKIyBDT05GSUdfTkVUX1ZFTkRPUl9BVEhFUk9TIGlzIG5v
dCBzZXQKIyBDT05GSUdfTkVUX1ZFTkRPUl9CUk9BRENPTSBpcyBub3Qgc2V0CiMgQ09ORklHX05F
VF9WRU5ET1JfQlJPQ0FERSBpcyBub3Qgc2V0CiMgQ09ORklHX05FVF9DQUxYRURBX1hHTUFDIGlz
IG5vdCBzZXQKIyBDT05GSUdfTkVUX1ZFTkRPUl9DSEVMU0lPIGlzIG5vdCBzZXQKIyBDT05GSUdf
TkVUX1ZFTkRPUl9DSVNDTyBpcyBub3Qgc2V0CiMgQ09ORklHX0RORVQgaXMgbm90IHNldAojIENP
TkZJR19ORVRfVkVORE9SX0RFQyBpcyBub3Qgc2V0CiMgQ09ORklHX05FVF9WRU5ET1JfRExJTksg
aXMgbm90IHNldAojIENPTkZJR19ORVRfVkVORE9SX0VNVUxFWCBpcyBub3Qgc2V0CiMgQ09ORklH
X05FVF9WRU5ET1JfRVhBUiBpcyBub3Qgc2V0CiMgQ09ORklHX05FVF9WRU5ET1JfRlVKSVRTVSBp
cyBub3Qgc2V0CiMgQ09ORklHX05FVF9WRU5ET1JfSFAgaXMgbm90IHNldAojIENPTkZJR19ORVRf
VkVORE9SX0lOVEVMIGlzIG5vdCBzZXQKIyBDT05GSUdfSVAxMDAwIGlzIG5vdCBzZXQKIyBDT05G
SUdfSk1FIGlzIG5vdCBzZXQKIyBDT05GSUdfTkVUX1ZFTkRPUl9NQVJWRUxMIGlzIG5vdCBzZXQK
IyBDT05GSUdfTkVUX1ZFTkRPUl9NRUxMQU5PWCBpcyBub3Qgc2V0CiMgQ09ORklHX05FVF9WRU5E
T1JfTUlDUkVMIGlzIG5vdCBzZXQKIyBDT05GSUdfTkVUX1ZFTkRPUl9NWVJJIGlzIG5vdCBzZXQK
IyBDT05GSUdfRkVBTE5YIGlzIG5vdCBzZXQKIyBDT05GSUdfTkVUX1ZFTkRPUl9OQVRTRU1JIGlz
IG5vdCBzZXQKIyBDT05GSUdfTkVUX1ZFTkRPUl9OVklESUEgaXMgbm90IHNldAojIENPTkZJR19O
RVRfVkVORE9SX09LSSBpcyBub3Qgc2V0CiMgQ09ORklHX0VUSE9DIGlzIG5vdCBzZXQKIyBDT05G
SUdfTkVUX1BBQ0tFVF9FTkdJTkUgaXMgbm90IHNldAojIENPTkZJR19ORVRfVkVORE9SX1FMT0dJ
QyBpcyBub3Qgc2V0CkNPTkZJR19ORVRfVkVORE9SX1JFQUxURUs9eQojIENPTkZJR184MTM5Q1Ag
aXMgbm90IHNldApDT05GSUdfODEzOVRPTz1tCkNPTkZJR184MTM5VE9PX1BJTz15CiMgQ09ORklH
XzgxMzlUT09fVFVORV9UV0lTVEVSIGlzIG5vdCBzZXQKIyBDT05GSUdfODEzOVRPT184MTI5IGlz
IG5vdCBzZXQKIyBDT05GSUdfODEzOV9PTERfUlhfUkVTRVQgaXMgbm90IHNldApDT05GSUdfUjgx
Njk9eQojIENPTkZJR19ORVRfVkVORE9SX1JEQyBpcyBub3Qgc2V0CiMgQ09ORklHX05FVF9WRU5E
T1JfU0VFUSBpcyBub3Qgc2V0CiMgQ09ORklHX05FVF9WRU5ET1JfU0lMQU4gaXMgbm90IHNldAoj
IENPTkZJR19ORVRfVkVORE9SX1NJUyBpcyBub3Qgc2V0CiMgQ09ORklHX1NGQyBpcyBub3Qgc2V0
CiMgQ09ORklHX05FVF9WRU5ET1JfU01TQyBpcyBub3Qgc2V0CiMgQ09ORklHX05FVF9WRU5ET1Jf
U1RNSUNSTyBpcyBub3Qgc2V0CiMgQ09ORklHX05FVF9WRU5ET1JfU1VOIGlzIG5vdCBzZXQKIyBD
T05GSUdfTkVUX1ZFTkRPUl9URUhVVEkgaXMgbm90IHNldAojIENPTkZJR19ORVRfVkVORE9SX1RJ
IGlzIG5vdCBzZXQKIyBDT05GSUdfTkVUX1ZFTkRPUl9WSUEgaXMgbm90IHNldAojIENPTkZJR19O
RVRfVkVORE9SX1dJWk5FVCBpcyBub3Qgc2V0CiMgQ09ORklHX05FVF9WRU5ET1JfWElSQ09NIGlz
IG5vdCBzZXQKIyBDT05GSUdfRkRESSBpcyBub3Qgc2V0CiMgQ09ORklHX0hJUFBJIGlzIG5vdCBz
ZXQKIyBDT05GSUdfTkVUX1NCMTAwMCBpcyBub3Qgc2V0CkNPTkZJR19QSFlMSUI9eQoKIwojIE1J
SSBQSFkgZGV2aWNlIGRyaXZlcnMKIwojIENPTkZJR19BTURfUEhZIGlzIG5vdCBzZXQKIyBDT05G
SUdfTUFSVkVMTF9QSFkgaXMgbm90IHNldAojIENPTkZJR19EQVZJQ09NX1BIWSBpcyBub3Qgc2V0
CiMgQ09ORklHX1FTRU1JX1BIWSBpcyBub3Qgc2V0CiMgQ09ORklHX0xYVF9QSFkgaXMgbm90IHNl
dAojIENPTkZJR19DSUNBREFfUEhZIGlzIG5vdCBzZXQKIyBDT05GSUdfVklURVNTRV9QSFkgaXMg
bm90IHNldAojIENPTkZJR19TTVNDX1BIWSBpcyBub3Qgc2V0CiMgQ09ORklHX0JST0FEQ09NX1BI
WSBpcyBub3Qgc2V0CiMgQ09ORklHX0JDTTg3WFhfUEhZIGlzIG5vdCBzZXQKIyBDT05GSUdfSUNQ
TFVTX1BIWSBpcyBub3Qgc2V0CiMgQ09ORklHX1JFQUxURUtfUEhZIGlzIG5vdCBzZXQKIyBDT05G
SUdfTkFUSU9OQUxfUEhZIGlzIG5vdCBzZXQKIyBDT05GSUdfU1RFMTBYUCBpcyBub3Qgc2V0CiMg
Q09ORklHX0xTSV9FVDEwMTFDX1BIWSBpcyBub3Qgc2V0CiMgQ09ORklHX01JQ1JFTF9QSFkgaXMg
bm90IHNldAojIENPTkZJR19GSVhFRF9QSFkgaXMgbm90IHNldAojIENPTkZJR19NRElPX0JJVEJB
TkcgaXMgbm90IHNldAojIENPTkZJR19QUFAgaXMgbm90IHNldAojIENPTkZJR19TTElQIGlzIG5v
dCBzZXQKCiMKIyBVU0IgTmV0d29yayBBZGFwdGVycwojCiMgQ09ORklHX1VTQl9DQVRDIGlzIG5v
dCBzZXQKIyBDT05GSUdfVVNCX0tBV0VUSCBpcyBub3Qgc2V0CiMgQ09ORklHX1VTQl9QRUdBU1VT
IGlzIG5vdCBzZXQKIyBDT05GSUdfVVNCX1JUTDgxNTAgaXMgbm90IHNldAojIENPTkZJR19VU0Jf
VVNCTkVUIGlzIG5vdCBzZXQKIyBDT05GSUdfVVNCX0hTTyBpcyBub3Qgc2V0CiMgQ09ORklHX1VT
Ql9JUEhFVEggaXMgbm90IHNldApDT05GSUdfV0xBTj15CiMgQ09ORklHX1BDTUNJQV9SQVlDUyBp
cyBub3Qgc2V0CiMgQ09ORklHX0xJQkVSVEFTX1RISU5GSVJNIGlzIG5vdCBzZXQKQ09ORklHX0FJ
Uk89bQojIENPTkZJR19BVE1FTCBpcyBub3Qgc2V0CkNPTkZJR19BVDc2QzUwWF9VU0I9bQojIENP
TkZJR19BSVJPX0NTIGlzIG5vdCBzZXQKIyBDT05GSUdfUENNQ0lBX1dMMzUwMSBpcyBub3Qgc2V0
CiMgQ09ORklHX1BSSVNNNTQgaXMgbm90IHNldAojIENPTkZJR19VU0JfWkQxMjAxIGlzIG5vdCBz
ZXQKIyBDT05GSUdfVVNCX05FVF9STkRJU19XTEFOIGlzIG5vdCBzZXQKIyBDT05GSUdfUlRMODE4
MCBpcyBub3Qgc2V0CiMgQ09ORklHX1JUTDgxODcgaXMgbm90IHNldAojIENPTkZJR19BRE04MjEx
IGlzIG5vdCBzZXQKIyBDT05GSUdfTUFDODAyMTFfSFdTSU0gaXMgbm90IHNldAojIENPTkZJR19N
V0w4SyBpcyBub3Qgc2V0CkNPTkZJR19BVEhfQ09NTU9OPW0KQ09ORklHX0FUSF9ERUJVRz15CkNP
TkZJR19BVEg1Sz1tCkNPTkZJR19BVEg1S19ERUJVRz15CkNPTkZJR19BVEg1S19UUkFDRVI9eQpD
T05GSUdfQVRINUtfUENJPXkKQ09ORklHX0FUSDlLX0hXPW0KQ09ORklHX0FUSDlLX0NPTU1PTj1t
CiMgQ09ORklHX0FUSDlLX0JUQ09FWF9TVVBQT1JUIGlzIG5vdCBzZXQKQ09ORklHX0FUSDlLPW0K
Q09ORklHX0FUSDlLX1BDST15CiMgQ09ORklHX0FUSDlLX0FIQiBpcyBub3Qgc2V0CkNPTkZJR19B
VEg5S19ERUJVR0ZTPXkKQ09ORklHX0FUSDlLX01BQ19ERUJVRz15CkNPTkZJR19BVEg5S19SQVRF
X0NPTlRST0w9eQpDT05GSUdfQVRIOUtfSFRDPW0KQ09ORklHX0FUSDlLX0hUQ19ERUJVR0ZTPXkK
Q09ORklHX0NBUkw5MTcwPW0KQ09ORklHX0NBUkw5MTcwX0xFRFM9eQpDT05GSUdfQ0FSTDkxNzBf
REVCVUdGUz15CkNPTkZJR19DQVJMOTE3MF9XUEM9eQojIENPTkZJR19DQVJMOTE3MF9IV1JORyBp
cyBub3Qgc2V0CiMgQ09ORklHX0FUSDZLTCBpcyBub3Qgc2V0CkNPTkZJR19CNDM9bQpDT05GSUdf
QjQzX1NTQj15CkNPTkZJR19CNDNfUENJX0FVVE9TRUxFQ1Q9eQpDT05GSUdfQjQzX1BDSUNPUkVf
QVVUT1NFTEVDVD15CiMgQ09ORklHX0I0M19QQ01DSUEgaXMgbm90IHNldApDT05GSUdfQjQzX1BJ
Tz15CiMgQ09ORklHX0I0M19QSFlfTiBpcyBub3Qgc2V0CiMgQ09ORklHX0I0M19QSFlfTFAgaXMg
bm90IHNldApDT05GSUdfQjQzX1BIWV9IVD15CkNPTkZJR19CNDNfTEVEUz15CkNPTkZJR19CNDNf
SFdSTkc9eQpDT05GSUdfQjQzX0RFQlVHPXkKQ09ORklHX0I0M0xFR0FDWT1tCkNPTkZJR19CNDNM
RUdBQ1lfUENJX0FVVE9TRUxFQ1Q9eQpDT05GSUdfQjQzTEVHQUNZX1BDSUNPUkVfQVVUT1NFTEVD
VD15CkNPTkZJR19CNDNMRUdBQ1lfTEVEUz15CkNPTkZJR19CNDNMRUdBQ1lfSFdSTkc9eQpDT05G
SUdfQjQzTEVHQUNZX0RFQlVHPXkKQ09ORklHX0I0M0xFR0FDWV9ETUE9eQpDT05GSUdfQjQzTEVH
QUNZX1BJTz15CkNPTkZJR19CNDNMRUdBQ1lfRE1BX0FORF9QSU9fTU9ERT15CiMgQ09ORklHX0I0
M0xFR0FDWV9ETUFfTU9ERSBpcyBub3Qgc2V0CiMgQ09ORklHX0I0M0xFR0FDWV9QSU9fTU9ERSBp
cyBub3Qgc2V0CiMgQ09ORklHX0JSQ01GTUFDIGlzIG5vdCBzZXQKQ09ORklHX0hPU1RBUD1tCiMg
Q09ORklHX0hPU1RBUF9GSVJNV0FSRSBpcyBub3Qgc2V0CiMgQ09ORklHX0hPU1RBUF9QTFggaXMg
bm90IHNldApDT05GSUdfSE9TVEFQX1BDST1tCkNPTkZJR19IT1NUQVBfQ1M9bQojIENPTkZJR19J
UFcyMTAwIGlzIG5vdCBzZXQKIyBDT05GSUdfSVBXMjIwMCBpcyBub3Qgc2V0CiMgQ09ORklHX0lX
TFdJRkkgaXMgbm90IHNldAojIENPTkZJR19JV0w0OTY1IGlzIG5vdCBzZXQKIyBDT05GSUdfSVdM
Mzk0NSBpcyBub3Qgc2V0CiMgQ09ORklHX0xJQkVSVEFTIGlzIG5vdCBzZXQKQ09ORklHX0hFUk1F
Uz1tCiMgQ09ORklHX0hFUk1FU19QUklTTSBpcyBub3Qgc2V0CkNPTkZJR19IRVJNRVNfQ0FDSEVf
RldfT05fSU5JVD15CiMgQ09ORklHX1BMWF9IRVJNRVMgaXMgbm90IHNldAojIENPTkZJR19UTURf
SEVSTUVTIGlzIG5vdCBzZXQKIyBDT05GSUdfTk9SVEVMX0hFUk1FUyBpcyBub3Qgc2V0CkNPTkZJ
R19QQ01DSUFfSEVSTUVTPW0KIyBDT05GSUdfUENNQ0lBX1NQRUNUUlVNIGlzIG5vdCBzZXQKIyBD
T05GSUdfT1JJTk9DT19VU0IgaXMgbm90IHNldAojIENPTkZJR19QNTRfQ09NTU9OIGlzIG5vdCBz
ZXQKIyBDT05GSUdfUlQyWDAwIGlzIG5vdCBzZXQKIyBDT05GSUdfUlRMODE5MkNFIGlzIG5vdCBz
ZXQKIyBDT05GSUdfUlRMODE5MlNFIGlzIG5vdCBzZXQKIyBDT05GSUdfUlRMODE5MkRFIGlzIG5v
dCBzZXQKIyBDT05GSUdfUlRMODE5MkNVIGlzIG5vdCBzZXQKIyBDT05GSUdfV0xfVEkgaXMgbm90
IHNldAojIENPTkZJR19aRDEyMTFSVyBpcyBub3Qgc2V0CiMgQ09ORklHX01XSUZJRVggaXMgbm90
IHNldAoKIwojIEVuYWJsZSBXaU1BWCAoTmV0d29ya2luZyBvcHRpb25zKSB0byBzZWUgdGhlIFdp
TUFYIGRyaXZlcnMKIwojIENPTkZJR19XQU4gaXMgbm90IHNldAojIENPTkZJR19WTVhORVQzIGlz
IG5vdCBzZXQKIyBDT05GSUdfSVNETiBpcyBub3Qgc2V0CgojCiMgSW5wdXQgZGV2aWNlIHN1cHBv
cnQKIwpDT05GSUdfSU5QVVQ9eQpDT05GSUdfSU5QVVRfRkZfTUVNTEVTUz15CiMgQ09ORklHX0lO
UFVUX1BPTExERVYgaXMgbm90IHNldAojIENPTkZJR19JTlBVVF9TUEFSU0VLTUFQIGlzIG5vdCBz
ZXQKIyBDT05GSUdfSU5QVVRfTUFUUklYS01BUCBpcyBub3Qgc2V0CgojCiMgVXNlcmxhbmQgaW50
ZXJmYWNlcwojCkNPTkZJR19JTlBVVF9NT1VTRURFVj15CiMgQ09ORklHX0lOUFVUX01PVVNFREVW
X1BTQVVYIGlzIG5vdCBzZXQKQ09ORklHX0lOUFVUX01PVVNFREVWX1NDUkVFTl9YPTE5MjAKQ09O
RklHX0lOUFVUX01PVVNFREVWX1NDUkVFTl9ZPTEwODAKIyBDT05GSUdfSU5QVVRfSk9ZREVWIGlz
IG5vdCBzZXQKQ09ORklHX0lOUFVUX0VWREVWPXkKIyBDT05GSUdfSU5QVVRfRVZCVUcgaXMgbm90
IHNldAoKIwojIElucHV0IERldmljZSBEcml2ZXJzCiMKQ09ORklHX0lOUFVUX0tFWUJPQVJEPXkK
IyBDT05GSUdfS0VZQk9BUkRfQURQNTU4OCBpcyBub3Qgc2V0CiMgQ09ORklHX0tFWUJPQVJEX0FE
UDU1ODkgaXMgbm90IHNldApDT05GSUdfS0VZQk9BUkRfQVRLQkQ9eQojIENPTkZJR19LRVlCT0FS
RF9RVDEwNzAgaXMgbm90IHNldAojIENPTkZJR19LRVlCT0FSRF9RVDIxNjAgaXMgbm90IHNldAoj
IENPTkZJR19LRVlCT0FSRF9MS0tCRCBpcyBub3Qgc2V0CiMgQ09ORklHX0tFWUJPQVJEX1RDQTY0
MTYgaXMgbm90IHNldAojIENPTkZJR19LRVlCT0FSRF9UQ0E4NDE4IGlzIG5vdCBzZXQKIyBDT05G
SUdfS0VZQk9BUkRfTE04MzIzIGlzIG5vdCBzZXQKIyBDT05GSUdfS0VZQk9BUkRfTE04MzMzIGlz
IG5vdCBzZXQKIyBDT05GSUdfS0VZQk9BUkRfTUFYNzM1OSBpcyBub3Qgc2V0CiMgQ09ORklHX0tF
WUJPQVJEX01DUyBpcyBub3Qgc2V0CiMgQ09ORklHX0tFWUJPQVJEX01QUjEyMSBpcyBub3Qgc2V0
CiMgQ09ORklHX0tFWUJPQVJEX05FV1RPTiBpcyBub3Qgc2V0CiMgQ09ORklHX0tFWUJPQVJEX09Q
RU5DT1JFUyBpcyBub3Qgc2V0CiMgQ09ORklHX0tFWUJPQVJEX1NUT1dBV0FZIGlzIG5vdCBzZXQK
IyBDT05GSUdfS0VZQk9BUkRfU1VOS0JEIGlzIG5vdCBzZXQKIyBDT05GSUdfS0VZQk9BUkRfT01B
UDQgaXMgbm90IHNldAojIENPTkZJR19LRVlCT0FSRF9YVEtCRCBpcyBub3Qgc2V0CkNPTkZJR19J
TlBVVF9NT1VTRT15CiMgQ09ORklHX01PVVNFX1BTMiBpcyBub3Qgc2V0CiMgQ09ORklHX01PVVNF
X1NFUklBTCBpcyBub3Qgc2V0CiMgQ09ORklHX01PVVNFX0FQUExFVE9VQ0ggaXMgbm90IHNldAoj
IENPTkZJR19NT1VTRV9CQ001OTc0IGlzIG5vdCBzZXQKIyBDT05GSUdfTU9VU0VfVlNYWFhBQSBp
cyBub3Qgc2V0CiMgQ09ORklHX01PVVNFX1NZTkFQVElDU19JMkMgaXMgbm90IHNldAojIENPTkZJ
R19NT1VTRV9TWU5BUFRJQ1NfVVNCIGlzIG5vdCBzZXQKIyBDT05GSUdfSU5QVVRfSk9ZU1RJQ0sg
aXMgbm90IHNldAojIENPTkZJR19JTlBVVF9UQUJMRVQgaXMgbm90IHNldAojIENPTkZJR19JTlBV
VF9UT1VDSFNDUkVFTiBpcyBub3Qgc2V0CiMgQ09ORklHX0lOUFVUX01JU0MgaXMgbm90IHNldAoK
IwojIEhhcmR3YXJlIEkvTyBwb3J0cwojCkNPTkZJR19TRVJJTz15CkNPTkZJR19TRVJJT19JODA0
Mj15CiMgQ09ORklHX1NFUklPX1NFUlBPUlQgaXMgbm90IHNldAojIENPTkZJR19TRVJJT19DVDgy
QzcxMCBpcyBub3Qgc2V0CiMgQ09ORklHX1NFUklPX1BDSVBTMiBpcyBub3Qgc2V0CkNPTkZJR19T
RVJJT19MSUJQUzI9eQojIENPTkZJR19TRVJJT19SQVcgaXMgbm90IHNldAojIENPTkZJR19TRVJJ
T19BTFRFUkFfUFMyIGlzIG5vdCBzZXQKIyBDT05GSUdfU0VSSU9fUFMyTVVMVCBpcyBub3Qgc2V0
CiMgQ09ORklHX0dBTUVQT1JUIGlzIG5vdCBzZXQKCiMKIyBDaGFyYWN0ZXIgZGV2aWNlcwojCkNP
TkZJR19WVD15CkNPTkZJR19DT05TT0xFX1RSQU5TTEFUSU9OUz15CkNPTkZJR19WVF9DT05TT0xF
PXkKQ09ORklHX1ZUX0NPTlNPTEVfU0xFRVA9eQpDT05GSUdfSFdfQ09OU09MRT15CiMgQ09ORklH
X1ZUX0hXX0NPTlNPTEVfQklORElORyBpcyBub3Qgc2V0CkNPTkZJR19VTklYOThfUFRZUz15CiMg
Q09ORklHX0RFVlBUU19NVUxUSVBMRV9JTlNUQU5DRVMgaXMgbm90IHNldAojIENPTkZJR19MRUdB
Q1lfUFRZUyBpcyBub3Qgc2V0CiMgQ09ORklHX1NFUklBTF9OT05TVEFOREFSRCBpcyBub3Qgc2V0
CiMgQ09ORklHX05PWk9NSSBpcyBub3Qgc2V0CiMgQ09ORklHX05fR1NNIGlzIG5vdCBzZXQKIyBD
T05GSUdfVFJBQ0VfU0lOSyBpcyBub3Qgc2V0CkNPTkZJR19ERVZLTUVNPXkKCiMKIyBTZXJpYWwg
ZHJpdmVycwojCkNPTkZJR19TRVJJQUxfODI1MD15CkNPTkZJR19TRVJJQUxfODI1MF9DT05TT0xF
PXkKQ09ORklHX0ZJWF9FQVJMWUNPTl9NRU09eQpDT05GSUdfU0VSSUFMXzgyNTBfUENJPXkKQ09O
RklHX1NFUklBTF84MjUwX1BOUD15CiMgQ09ORklHX1NFUklBTF84MjUwX0NTIGlzIG5vdCBzZXQK
Q09ORklHX1NFUklBTF84MjUwX05SX1VBUlRTPTQKQ09ORklHX1NFUklBTF84MjUwX1JVTlRJTUVf
VUFSVFM9NAojIENPTkZJR19TRVJJQUxfODI1MF9FWFRFTkRFRCBpcyBub3Qgc2V0CgojCiMgTm9u
LTgyNTAgc2VyaWFsIHBvcnQgc3VwcG9ydAojCiMgQ09ORklHX1NFUklBTF9NRkRfSFNVIGlzIG5v
dCBzZXQKQ09ORklHX1NFUklBTF9DT1JFPXkKQ09ORklHX1NFUklBTF9DT1JFX0NPTlNPTEU9eQoj
IENPTkZJR19TRVJJQUxfSlNNIGlzIG5vdCBzZXQKIyBDT05GSUdfU0VSSUFMX1RJTUJFUkRBTEUg
aXMgbm90IHNldAojIENPTkZJR19TRVJJQUxfQUxURVJBX0pUQUdVQVJUIGlzIG5vdCBzZXQKIyBD
T05GSUdfU0VSSUFMX0FMVEVSQV9VQVJUIGlzIG5vdCBzZXQKIyBDT05GSUdfU0VSSUFMX1BDSF9V
QVJUIGlzIG5vdCBzZXQKIyBDT05GSUdfU0VSSUFMX1hJTElOWF9QU19VQVJUIGlzIG5vdCBzZXQK
IyBDT05GSUdfVFRZX1BSSU5USyBpcyBub3Qgc2V0CiMgQ09ORklHX0lQTUlfSEFORExFUiBpcyBu
b3Qgc2V0CkNPTkZJR19IV19SQU5ET009eQojIENPTkZJR19IV19SQU5ET01fVElNRVJJT01FTSBp
cyBub3Qgc2V0CiMgQ09ORklHX0hXX1JBTkRPTV9JTlRFTCBpcyBub3Qgc2V0CiMgQ09ORklHX0hX
X1JBTkRPTV9BTUQgaXMgbm90IHNldAojIENPTkZJR19IV19SQU5ET01fVklBIGlzIG5vdCBzZXQK
IyBDT05GSUdfTlZSQU0gaXMgbm90IHNldAojIENPTkZJR19SMzk2NCBpcyBub3Qgc2V0CiMgQ09O
RklHX0FQUExJQ09NIGlzIG5vdCBzZXQKCiMKIyBQQ01DSUEgY2hhcmFjdGVyIGRldmljZXMKIwoj
IENPTkZJR19TWU5DTElOS19DUyBpcyBub3Qgc2V0CiMgQ09ORklHX0NBUkRNQU5fNDAwMCBpcyBu
b3Qgc2V0CiMgQ09ORklHX0NBUkRNQU5fNDA0MCBpcyBub3Qgc2V0CiMgQ09ORklHX0lQV0lSRUxF
U1MgaXMgbm90IHNldAojIENPTkZJR19NV0FWRSBpcyBub3Qgc2V0CiMgQ09ORklHX1JBV19EUklW
RVIgaXMgbm90IHNldApDT05GSUdfSFBFVD15CiMgQ09ORklHX0hQRVRfTU1BUCBpcyBub3Qgc2V0
CiMgQ09ORklHX0hBTkdDSEVDS19USU1FUiBpcyBub3Qgc2V0CiMgQ09ORklHX1RDR19UUE0gaXMg
bm90IHNldAojIENPTkZJR19URUxDTE9DSyBpcyBub3Qgc2V0CkNPTkZJR19ERVZQT1JUPXkKQ09O
RklHX0kyQz15CkNPTkZJR19JMkNfQk9BUkRJTkZPPXkKIyBDT05GSUdfSTJDX0NPTVBBVCBpcyBu
b3Qgc2V0CiMgQ09ORklHX0kyQ19DSEFSREVWIGlzIG5vdCBzZXQKIyBDT05GSUdfSTJDX01VWCBp
cyBub3Qgc2V0CkNPTkZJR19JMkNfSEVMUEVSX0FVVE89eQpDT05GSUdfSTJDX0FMR09CSVQ9eQoK
IwojIEkyQyBIYXJkd2FyZSBCdXMgc3VwcG9ydAojCgojCiMgUEMgU01CdXMgaG9zdCBjb250cm9s
bGVyIGRyaXZlcnMKIwojIENPTkZJR19JMkNfQUxJMTUzNSBpcyBub3Qgc2V0CiMgQ09ORklHX0ky
Q19BTEkxNTYzIGlzIG5vdCBzZXQKIyBDT05GSUdfSTJDX0FMSTE1WDMgaXMgbm90IHNldAojIENP
TkZJR19JMkNfQU1ENzU2IGlzIG5vdCBzZXQKIyBDT05GSUdfSTJDX0FNRDgxMTEgaXMgbm90IHNl
dApDT05GSUdfSTJDX0k4MDE9eQojIENPTkZJR19JMkNfSVNDSCBpcyBub3Qgc2V0CiMgQ09ORklH
X0kyQ19QSUlYNCBpcyBub3Qgc2V0CiMgQ09ORklHX0kyQ19ORk9SQ0UyIGlzIG5vdCBzZXQKIyBD
T05GSUdfSTJDX1NJUzU1OTUgaXMgbm90IHNldAojIENPTkZJR19JMkNfU0lTNjMwIGlzIG5vdCBz
ZXQKIyBDT05GSUdfSTJDX1NJUzk2WCBpcyBub3Qgc2V0CiMgQ09ORklHX0kyQ19WSUEgaXMgbm90
IHNldAojIENPTkZJR19JMkNfVklBUFJPIGlzIG5vdCBzZXQKCiMKIyBBQ1BJIGRyaXZlcnMKIwoj
IENPTkZJR19JMkNfU0NNSSBpcyBub3Qgc2V0CgojCiMgSTJDIHN5c3RlbSBidXMgZHJpdmVycyAo
bW9zdGx5IGVtYmVkZGVkIC8gc3lzdGVtLW9uLWNoaXApCiMKIyBDT05GSUdfSTJDX0RFU0lHTldB
UkVfUENJIGlzIG5vdCBzZXQKIyBDT05GSUdfSTJDX0VHMjBUIGlzIG5vdCBzZXQKIyBDT05GSUdf
STJDX0lOVEVMX01JRCBpcyBub3Qgc2V0CiMgQ09ORklHX0kyQ19PQ09SRVMgaXMgbm90IHNldAoj
IENPTkZJR19JMkNfUENBX1BMQVRGT1JNIGlzIG5vdCBzZXQKIyBDT05GSUdfSTJDX1BYQV9QQ0kg
aXMgbm90IHNldAojIENPTkZJR19JMkNfU0lNVEVDIGlzIG5vdCBzZXQKIyBDT05GSUdfSTJDX1hJ
TElOWCBpcyBub3Qgc2V0CgojCiMgRXh0ZXJuYWwgSTJDL1NNQnVzIGFkYXB0ZXIgZHJpdmVycwoj
CiMgQ09ORklHX0kyQ19ESU9MQU5fVTJDIGlzIG5vdCBzZXQKIyBDT05GSUdfSTJDX1BBUlBPUlRf
TElHSFQgaXMgbm90IHNldAojIENPTkZJR19JMkNfVEFPU19FVk0gaXMgbm90IHNldAojIENPTkZJ
R19JMkNfVElOWV9VU0IgaXMgbm90IHNldAoKIwojIE90aGVyIEkyQy9TTUJ1cyBidXMgZHJpdmVy
cwojCiMgQ09ORklHX0kyQ19TVFVCIGlzIG5vdCBzZXQKIyBDT05GSUdfSTJDX0RFQlVHX0NPUkUg
aXMgbm90IHNldAojIENPTkZJR19JMkNfREVCVUdfQUxHTyBpcyBub3Qgc2V0CiMgQ09ORklHX0ky
Q19ERUJVR19CVVMgaXMgbm90IHNldAojIENPTkZJR19TUEkgaXMgbm90IHNldAojIENPTkZJR19I
U0kgaXMgbm90IHNldAoKIwojIFBQUyBzdXBwb3J0CiMKIyBDT05GSUdfUFBTIGlzIG5vdCBzZXQK
CiMKIyBQUFMgZ2VuZXJhdG9ycyBzdXBwb3J0CiMKCiMKIyBQVFAgY2xvY2sgc3VwcG9ydAojCgoj
CiMgRW5hYmxlIERldmljZSBEcml2ZXJzIC0+IFBQUyB0byBzZWUgdGhlIFBUUCBjbG9jayBvcHRp
b25zLgojCkNPTkZJR19BUkNIX1dBTlRfT1BUSU9OQUxfR1BJT0xJQj15CiMgQ09ORklHX0dQSU9M
SUIgaXMgbm90IHNldAojIENPTkZJR19XMSBpcyBub3Qgc2V0CiMgQ09ORklHX1BPV0VSX1NVUFBM
WSBpcyBub3Qgc2V0CiMgQ09ORklHX1BPV0VSX0FWUyBpcyBub3Qgc2V0CkNPTkZJR19IV01PTj15
CkNPTkZJR19IV01PTl9WSUQ9eQojIENPTkZJR19IV01PTl9ERUJVR19DSElQIGlzIG5vdCBzZXQK
CiMKIyBOYXRpdmUgZHJpdmVycwojCiMgQ09ORklHX1NFTlNPUlNfQUJJVFVHVVJVIGlzIG5vdCBz
ZXQKIyBDT05GSUdfU0VOU09SU19BQklUVUdVUlUzIGlzIG5vdCBzZXQKIyBDT05GSUdfU0VOU09S
U19BRDc0MTQgaXMgbm90IHNldAojIENPTkZJR19TRU5TT1JTX0FENzQxOCBpcyBub3Qgc2V0CiMg
Q09ORklHX1NFTlNPUlNfQURNMTAyMSBpcyBub3Qgc2V0CiMgQ09ORklHX1NFTlNPUlNfQURNMTAy
NSBpcyBub3Qgc2V0CiMgQ09ORklHX1NFTlNPUlNfQURNMTAyNiBpcyBub3Qgc2V0CiMgQ09ORklH
X1NFTlNPUlNfQURNMTAyOSBpcyBub3Qgc2V0CiMgQ09ORklHX1NFTlNPUlNfQURNMTAzMSBpcyBu
b3Qgc2V0CiMgQ09ORklHX1NFTlNPUlNfQURNOTI0MCBpcyBub3Qgc2V0CiMgQ09ORklHX1NFTlNP
UlNfQURUNzQxMSBpcyBub3Qgc2V0CiMgQ09ORklHX1NFTlNPUlNfQURUNzQ2MiBpcyBub3Qgc2V0
CiMgQ09ORklHX1NFTlNPUlNfQURUNzQ3MCBpcyBub3Qgc2V0CiMgQ09ORklHX1NFTlNPUlNfQURU
NzQ3NSBpcyBub3Qgc2V0CiMgQ09ORklHX1NFTlNPUlNfQVNDNzYyMSBpcyBub3Qgc2V0CiMgQ09O
RklHX1NFTlNPUlNfSzhURU1QIGlzIG5vdCBzZXQKIyBDT05GSUdfU0VOU09SU19LMTBURU1QIGlz
IG5vdCBzZXQKIyBDT05GSUdfU0VOU09SU19GQU0xNUhfUE9XRVIgaXMgbm90IHNldAojIENPTkZJ
R19TRU5TT1JTX0FTQjEwMCBpcyBub3Qgc2V0CiMgQ09ORklHX1NFTlNPUlNfQVRYUDEgaXMgbm90
IHNldAojIENPTkZJR19TRU5TT1JTX0RTNjIwIGlzIG5vdCBzZXQKIyBDT05GSUdfU0VOU09SU19E
UzE2MjEgaXMgbm90IHNldAojIENPTkZJR19TRU5TT1JTX0k1S19BTUIgaXMgbm90IHNldAojIENP
TkZJR19TRU5TT1JTX0Y3MTgwNUYgaXMgbm90IHNldAojIENPTkZJR19TRU5TT1JTX0Y3MTg4MkZH
IGlzIG5vdCBzZXQKIyBDT05GSUdfU0VOU09SU19GNzUzNzVTIGlzIG5vdCBzZXQKIyBDT05GSUdf
U0VOU09SU19GU0NITUQgaXMgbm90IHNldAojIENPTkZJR19TRU5TT1JTX0c3NjBBIGlzIG5vdCBz
ZXQKIyBDT05GSUdfU0VOU09SU19HTDUxOFNNIGlzIG5vdCBzZXQKIyBDT05GSUdfU0VOU09SU19H
TDUyMFNNIGlzIG5vdCBzZXQKIyBDT05GSUdfU0VOU09SU19ISUg2MTMwIGlzIG5vdCBzZXQKQ09O
RklHX1NFTlNPUlNfQ09SRVRFTVA9eQpDT05GSUdfU0VOU09SU19JVDg3PXkKIyBDT05GSUdfU0VO
U09SU19KQzQyIGlzIG5vdCBzZXQKIyBDT05GSUdfU0VOU09SU19MSU5FQUdFIGlzIG5vdCBzZXQK
IyBDT05GSUdfU0VOU09SU19MTTYzIGlzIG5vdCBzZXQKIyBDT05GSUdfU0VOU09SU19MTTczIGlz
IG5vdCBzZXQKIyBDT05GSUdfU0VOU09SU19MTTc1IGlzIG5vdCBzZXQKIyBDT05GSUdfU0VOU09S
U19MTTc3IGlzIG5vdCBzZXQKIyBDT05GSUdfU0VOU09SU19MTTc4IGlzIG5vdCBzZXQKIyBDT05G
SUdfU0VOU09SU19MTTgwIGlzIG5vdCBzZXQKIyBDT05GSUdfU0VOU09SU19MTTgzIGlzIG5vdCBz
ZXQKIyBDT05GSUdfU0VOU09SU19MTTg1IGlzIG5vdCBzZXQKIyBDT05GSUdfU0VOU09SU19MTTg3
IGlzIG5vdCBzZXQKIyBDT05GSUdfU0VOU09SU19MTTkwIGlzIG5vdCBzZXQKIyBDT05GSUdfU0VO
U09SU19MTTkyIGlzIG5vdCBzZXQKIyBDT05GSUdfU0VOU09SU19MTTkzIGlzIG5vdCBzZXQKIyBD
T05GSUdfU0VOU09SU19MVEM0MTUxIGlzIG5vdCBzZXQKIyBDT05GSUdfU0VOU09SU19MVEM0MjE1
IGlzIG5vdCBzZXQKIyBDT05GSUdfU0VOU09SU19MVEM0MjQ1IGlzIG5vdCBzZXQKIyBDT05GSUdf
U0VOU09SU19MVEM0MjYxIGlzIG5vdCBzZXQKIyBDT05GSUdfU0VOU09SU19MTTk1MjQxIGlzIG5v
dCBzZXQKIyBDT05GSUdfU0VOU09SU19MTTk1MjQ1IGlzIG5vdCBzZXQKIyBDT05GSUdfU0VOU09S
U19NQVgxNjA2NSBpcyBub3Qgc2V0CiMgQ09ORklHX1NFTlNPUlNfTUFYMTYxOSBpcyBub3Qgc2V0
CiMgQ09ORklHX1NFTlNPUlNfTUFYMTY2OCBpcyBub3Qgc2V0CiMgQ09ORklHX1NFTlNPUlNfTUFY
NjYzOSBpcyBub3Qgc2V0CiMgQ09ORklHX1NFTlNPUlNfTUFYNjY0MiBpcyBub3Qgc2V0CiMgQ09O
RklHX1NFTlNPUlNfTUFYNjY1MCBpcyBub3Qgc2V0CiMgQ09ORklHX1NFTlNPUlNfTUNQMzAyMSBp
cyBub3Qgc2V0CiMgQ09ORklHX1NFTlNPUlNfTlRDX1RIRVJNSVNUT1IgaXMgbm90IHNldAojIENP
TkZJR19TRU5TT1JTX1BDODczNjAgaXMgbm90IHNldAojIENPTkZJR19TRU5TT1JTX1BDODc0Mjcg
aXMgbm90IHNldAojIENPTkZJR19TRU5TT1JTX1BDRjg1OTEgaXMgbm90IHNldAojIENPTkZJR19Q
TUJVUyBpcyBub3Qgc2V0CiMgQ09ORklHX1NFTlNPUlNfU0hUMjEgaXMgbm90IHNldAojIENPTkZJ
R19TRU5TT1JTX1NJUzU1OTUgaXMgbm90IHNldAojIENPTkZJR19TRU5TT1JTX1NNTTY2NSBpcyBu
b3Qgc2V0CiMgQ09ORklHX1NFTlNPUlNfRE1FMTczNyBpcyBub3Qgc2V0CiMgQ09ORklHX1NFTlNP
UlNfRU1DMTQwMyBpcyBub3Qgc2V0CiMgQ09ORklHX1NFTlNPUlNfRU1DMjEwMyBpcyBub3Qgc2V0
CiMgQ09ORklHX1NFTlNPUlNfRU1DNlcyMDEgaXMgbm90IHNldAojIENPTkZJR19TRU5TT1JTX1NN
U0M0N00xIGlzIG5vdCBzZXQKIyBDT05GSUdfU0VOU09SU19TTVNDNDdNMTkyIGlzIG5vdCBzZXQK
IyBDT05GSUdfU0VOU09SU19TTVNDNDdCMzk3IGlzIG5vdCBzZXQKIyBDT05GSUdfU0VOU09SU19T
Q0g1NlhYX0NPTU1PTiBpcyBub3Qgc2V0CiMgQ09ORklHX1NFTlNPUlNfU0NINTYyNyBpcyBub3Qg
c2V0CiMgQ09ORklHX1NFTlNPUlNfU0NINTYzNiBpcyBub3Qgc2V0CiMgQ09ORklHX1NFTlNPUlNf
QURTMTAxNSBpcyBub3Qgc2V0CiMgQ09ORklHX1NFTlNPUlNfQURTNzgyOCBpcyBub3Qgc2V0CiMg
Q09ORklHX1NFTlNPUlNfQU1DNjgyMSBpcyBub3Qgc2V0CiMgQ09ORklHX1NFTlNPUlNfSU5BMlhY
IGlzIG5vdCBzZXQKIyBDT05GSUdfU0VOU09SU19USE1DNTAgaXMgbm90IHNldAojIENPTkZJR19T
RU5TT1JTX1RNUDEwMiBpcyBub3Qgc2V0CiMgQ09ORklHX1NFTlNPUlNfVE1QNDAxIGlzIG5vdCBz
ZXQKIyBDT05GSUdfU0VOU09SU19UTVA0MjEgaXMgbm90IHNldAojIENPTkZJR19TRU5TT1JTX1ZJ
QV9DUFVURU1QIGlzIG5vdCBzZXQKIyBDT05GSUdfU0VOU09SU19WSUE2ODZBIGlzIG5vdCBzZXQK
IyBDT05GSUdfU0VOU09SU19WVDEyMTEgaXMgbm90IHNldAojIENPTkZJR19TRU5TT1JTX1ZUODIz
MSBpcyBub3Qgc2V0CiMgQ09ORklHX1NFTlNPUlNfVzgzNzgxRCBpcyBub3Qgc2V0CiMgQ09ORklH
X1NFTlNPUlNfVzgzNzkxRCBpcyBub3Qgc2V0CiMgQ09ORklHX1NFTlNPUlNfVzgzNzkyRCBpcyBu
b3Qgc2V0CiMgQ09ORklHX1NFTlNPUlNfVzgzNzkzIGlzIG5vdCBzZXQKIyBDT05GSUdfU0VOU09S
U19XODM3OTUgaXMgbm90IHNldAojIENPTkZJR19TRU5TT1JTX1c4M0w3ODVUUyBpcyBub3Qgc2V0
CiMgQ09ORklHX1NFTlNPUlNfVzgzTDc4Nk5HIGlzIG5vdCBzZXQKIyBDT05GSUdfU0VOU09SU19X
ODM2MjdIRiBpcyBub3Qgc2V0CiMgQ09ORklHX1NFTlNPUlNfVzgzNjI3RUhGIGlzIG5vdCBzZXQK
IyBDT05GSUdfU0VOU09SU19BUFBMRVNNQyBpcyBub3Qgc2V0CgojCiMgQUNQSSBkcml2ZXJzCiMK
IyBDT05GSUdfU0VOU09SU19BQ1BJX1BPV0VSIGlzIG5vdCBzZXQKIyBDT05GSUdfU0VOU09SU19B
VEswMTEwIGlzIG5vdCBzZXQKQ09ORklHX1RIRVJNQUw9eQpDT05GSUdfVEhFUk1BTF9IV01PTj15
CkNPTkZJR19XQVRDSERPRz15CkNPTkZJR19XQVRDSERPR19DT1JFPXkKIyBDT05GSUdfV0FUQ0hE
T0dfTk9XQVlPVVQgaXMgbm90IHNldAoKIwojIFdhdGNoZG9nIERldmljZSBEcml2ZXJzCiMKIyBD
T05GSUdfU09GVF9XQVRDSERPRyBpcyBub3Qgc2V0CiMgQ09ORklHX0FDUVVJUkVfV0RUIGlzIG5v
dCBzZXQKIyBDT05GSUdfQURWQU5URUNIX1dEVCBpcyBub3Qgc2V0CiMgQ09ORklHX0FMSU0xNTM1
X1dEVCBpcyBub3Qgc2V0CiMgQ09ORklHX0FMSU03MTAxX1dEVCBpcyBub3Qgc2V0CiMgQ09ORklH
X0Y3MTgwOEVfV0RUIGlzIG5vdCBzZXQKIyBDT05GSUdfU1A1MTAwX1RDTyBpcyBub3Qgc2V0CiMg
Q09ORklHX1NDNTIwX1dEVCBpcyBub3Qgc2V0CiMgQ09ORklHX1NCQ19GSVRQQzJfV0FUQ0hET0cg
aXMgbm90IHNldAojIENPTkZJR19FVVJPVEVDSF9XRFQgaXMgbm90IHNldAojIENPTkZJR19JQjcw
MF9XRFQgaXMgbm90IHNldAojIENPTkZJR19JQk1BU1IgaXMgbm90IHNldAojIENPTkZJR19XQUZF
Ul9XRFQgaXMgbm90IHNldAojIENPTkZJR19JNjMwMEVTQl9XRFQgaXMgbm90IHNldAojIENPTkZJ
R19JRTZYWF9XRFQgaXMgbm90IHNldAojIENPTkZJR19JVENPX1dEVCBpcyBub3Qgc2V0CiMgQ09O
RklHX0lUODcxMkZfV0RUIGlzIG5vdCBzZXQKQ09ORklHX0lUODdfV0RUPXkKIyBDT05GSUdfSFBf
V0FUQ0hET0cgaXMgbm90IHNldAojIENPTkZJR19TQzEyMDBfV0RUIGlzIG5vdCBzZXQKIyBDT05G
SUdfUEM4NzQxM19XRFQgaXMgbm90IHNldAojIENPTkZJR19OVl9UQ08gaXMgbm90IHNldAojIENP
TkZJR182MFhYX1dEVCBpcyBub3Qgc2V0CiMgQ09ORklHX1NCQzgzNjBfV0RUIGlzIG5vdCBzZXQK
IyBDT05GSUdfQ1BVNV9XRFQgaXMgbm90IHNldAojIENPTkZJR19TTVNDX1NDSDMxMVhfV0RUIGlz
IG5vdCBzZXQKIyBDT05GSUdfU01TQzM3Qjc4N19XRFQgaXMgbm90IHNldAojIENPTkZJR19WSUFf
V0RUIGlzIG5vdCBzZXQKIyBDT05GSUdfVzgzNjI3SEZfV0RUIGlzIG5vdCBzZXQKIyBDT05GSUdf
VzgzNjk3SEZfV0RUIGlzIG5vdCBzZXQKIyBDT05GSUdfVzgzNjk3VUdfV0RUIGlzIG5vdCBzZXQK
IyBDT05GSUdfVzgzODc3Rl9XRFQgaXMgbm90IHNldAojIENPTkZJR19XODM5NzdGX1dEVCBpcyBu
b3Qgc2V0CiMgQ09ORklHX01BQ0haX1dEVCBpcyBub3Qgc2V0CiMgQ09ORklHX1NCQ19FUFhfQzNf
V0FUQ0hET0cgaXMgbm90IHNldAoKIwojIFBDSS1iYXNlZCBXYXRjaGRvZyBDYXJkcwojCiMgQ09O
RklHX1BDSVBDV0FUQ0hET0cgaXMgbm90IHNldAojIENPTkZJR19XRFRQQ0kgaXMgbm90IHNldAoK
IwojIFVTQi1iYXNlZCBXYXRjaGRvZyBDYXJkcwojCiMgQ09ORklHX1VTQlBDV0FUQ0hET0cgaXMg
bm90IHNldApDT05GSUdfU1NCX1BPU1NJQkxFPXkKCiMKIyBTb25pY3MgU2lsaWNvbiBCYWNrcGxh
bmUKIwpDT05GSUdfU1NCPW0KQ09ORklHX1NTQl9TUFJPTT15CkNPTkZJR19TU0JfQkxPQ0tJTz15
CkNPTkZJR19TU0JfUENJSE9TVF9QT1NTSUJMRT15CkNPTkZJR19TU0JfUENJSE9TVD15CkNPTkZJ
R19TU0JfQjQzX1BDSV9CUklER0U9eQpDT05GSUdfU1NCX1BDTUNJQUhPU1RfUE9TU0lCTEU9eQoj
IENPTkZJR19TU0JfUENNQ0lBSE9TVCBpcyBub3Qgc2V0CiMgQ09ORklHX1NTQl9TSUxFTlQgaXMg
bm90IHNldApDT05GSUdfU1NCX0RFQlVHPXkKQ09ORklHX1NTQl9EUklWRVJfUENJQ09SRV9QT1NT
SUJMRT15CkNPTkZJR19TU0JfRFJJVkVSX1BDSUNPUkU9eQpDT05GSUdfQkNNQV9QT1NTSUJMRT15
CgojCiMgQnJvYWRjb20gc3BlY2lmaWMgQU1CQQojCiMgQ09ORklHX0JDTUEgaXMgbm90IHNldAoK
IwojIE11bHRpZnVuY3Rpb24gZGV2aWNlIGRyaXZlcnMKIwojIENPTkZJR19NRkRfQ09SRSBpcyBu
b3Qgc2V0CiMgQ09ORklHX01GRF84OFBNODYwWCBpcyBub3Qgc2V0CiMgQ09ORklHX01GRF84OFBN
ODAwIGlzIG5vdCBzZXQKIyBDT05GSUdfTUZEXzg4UE04MDUgaXMgbm90IHNldAojIENPTkZJR19N
RkRfU001MDEgaXMgbm90IHNldAojIENPTkZJR19IVENfUEFTSUMzIGlzIG5vdCBzZXQKIyBDT05G
SUdfTUZEX0xNMzUzMyBpcyBub3Qgc2V0CiMgQ09ORklHX1RQUzYxMDVYIGlzIG5vdCBzZXQKIyBD
T05GSUdfVFBTNjUwN1ggaXMgbm90IHNldAojIENPTkZJR19NRkRfVFBTNjUyMTcgaXMgbm90IHNl
dAojIENPTkZJR19UV0w0MDMwX0NPUkUgaXMgbm90IHNldAojIENPTkZJR19UV0w2MDQwX0NPUkUg
aXMgbm90IHNldAojIENPTkZJR19NRkRfU1RNUEUgaXMgbm90IHNldAojIENPTkZJR19NRkRfVEMz
NTg5WCBpcyBub3Qgc2V0CiMgQ09ORklHX01GRF9UTUlPIGlzIG5vdCBzZXQKIyBDT05GSUdfUE1J
Q19EQTkwM1ggaXMgbm90IHNldAojIENPTkZJR19NRkRfREE5MDUyX0kyQyBpcyBub3Qgc2V0CiMg
Q09ORklHX1BNSUNfQURQNTUyMCBpcyBub3Qgc2V0CiMgQ09ORklHX01GRF9NQVg3NzY4NiBpcyBu
b3Qgc2V0CiMgQ09ORklHX01GRF9NQVg3NzY5MyBpcyBub3Qgc2V0CiMgQ09ORklHX01GRF9NQVg4
OTI1IGlzIG5vdCBzZXQKIyBDT05GSUdfTUZEX01BWDg5OTcgaXMgbm90IHNldAojIENPTkZJR19N
RkRfTUFYODk5OCBpcyBub3Qgc2V0CiMgQ09ORklHX01GRF9TRUNfQ09SRSBpcyBub3Qgc2V0CiMg
Q09ORklHX01GRF9BUklaT05BX0kyQyBpcyBub3Qgc2V0CiMgQ09ORklHX01GRF9XTTg0MDAgaXMg
bm90IHNldAojIENPTkZJR19NRkRfV004MzFYX0kyQyBpcyBub3Qgc2V0CiMgQ09ORklHX01GRF9X
TTgzNTBfSTJDIGlzIG5vdCBzZXQKIyBDT05GSUdfTUZEX1dNODk5NCBpcyBub3Qgc2V0CiMgQ09O
RklHX01GRF9QQ0Y1MDYzMyBpcyBub3Qgc2V0CiMgQ09ORklHX01GRF9NQzEzWFhYX0kyQyBpcyBu
b3Qgc2V0CiMgQ09ORklHX0FCWDUwMF9DT1JFIGlzIG5vdCBzZXQKIyBDT05GSUdfTUZEX0NTNTUz
NSBpcyBub3Qgc2V0CiMgQ09ORklHX0xQQ19TQ0ggaXMgbm90IHNldAojIENPTkZJR19MUENfSUNI
IGlzIG5vdCBzZXQKIyBDT05GSUdfTUZEX1JEQzMyMVggaXMgbm90IHNldAojIENPTkZJR19NRkRf
SkFOWl9DTU9ESU8gaXMgbm90IHNldAojIENPTkZJR19NRkRfVlg4NTUgaXMgbm90IHNldAojIENP
TkZJR19NRkRfV0wxMjczX0NPUkUgaXMgbm90IHNldAojIENPTkZJR19NRkRfVFBTNjUwOTAgaXMg
bm90IHNldAojIENPTkZJR19NRkRfUkM1VDU4MyBpcyBub3Qgc2V0CiMgQ09ORklHX01GRF9QQUxN
QVMgaXMgbm90IHNldAojIENPTkZJR19SRUdVTEFUT1IgaXMgbm90IHNldApDT05GSUdfTUVESUFf
U1VQUE9SVD15CgojCiMgTXVsdGltZWRpYSBjb3JlIHN1cHBvcnQKIwpDT05GSUdfTUVESUFfQ0FN
RVJBX1NVUFBPUlQ9eQojIENPTkZJR19NRURJQV9BTkFMT0dfVFZfU1VQUE9SVCBpcyBub3Qgc2V0
CiMgQ09ORklHX01FRElBX0RJR0lUQUxfVFZfU1VQUE9SVCBpcyBub3Qgc2V0CiMgQ09ORklHX01F
RElBX1JBRElPX1NVUFBPUlQgaXMgbm90IHNldAojIENPTkZJR19NRURJQV9SQ19TVVBQT1JUIGlz
IG5vdCBzZXQKIyBDT05GSUdfTUVESUFfQ09OVFJPTExFUiBpcyBub3Qgc2V0CkNPTkZJR19WSURF
T19ERVY9eQpDT05GSUdfVklERU9fVjRMMl9DT01NT049eQoKIwojIE1lZGlhIGRyaXZlcnMKIwpD
T05GSUdfVklERU9fVjRMMj15CkNPTkZJR19WSURFT0JVRjJfQ09SRT15CkNPTkZJR19WSURFT0JV
RjJfTUVNT1BTPXkKQ09ORklHX1ZJREVPQlVGMl9WTUFMTE9DPXkKQ09ORklHX1ZJREVPX0NBUFRV
UkVfRFJJVkVSUz15CiMgQ09ORklHX1ZJREVPX0FEVl9ERUJVRyBpcyBub3Qgc2V0CiMgQ09ORklH
X1ZJREVPX0ZJWEVEX01JTk9SX1JBTkdFUyBpcyBub3Qgc2V0CiMgQ09ORklHX1ZJREVPX0hFTFBF
Ul9DSElQU19BVVRPIGlzIG5vdCBzZXQKCiMKIyBFbmNvZGVycywgZGVjb2RlcnMsIHNlbnNvcnMg
YW5kIG90aGVyIGhlbHBlciBjaGlwcwojCgojCiMgQXVkaW8gZGVjb2RlcnMsIHByb2Nlc3NvcnMg
YW5kIG1peGVycwojCiMgQ09ORklHX1ZJREVPX1RWQVVESU8gaXMgbm90IHNldAojIENPTkZJR19W
SURFT19UREE3NDMyIGlzIG5vdCBzZXQKIyBDT05GSUdfVklERU9fVERBOTg0MCBpcyBub3Qgc2V0
CiMgQ09ORklHX1ZJREVPX1RFQTY0MTVDIGlzIG5vdCBzZXQKIyBDT05GSUdfVklERU9fVEVBNjQy
MCBpcyBub3Qgc2V0CiMgQ09ORklHX1ZJREVPX01TUDM0MDAgaXMgbm90IHNldAojIENPTkZJR19W
SURFT19DUzUzNDUgaXMgbm90IHNldAojIENPTkZJR19WSURFT19DUzUzTDMyQSBpcyBub3Qgc2V0
CiMgQ09ORklHX1ZJREVPX1RMVjMyMEFJQzIzQiBpcyBub3Qgc2V0CiMgQ09ORklHX1ZJREVPX1dN
ODc3NSBpcyBub3Qgc2V0CiMgQ09ORklHX1ZJREVPX1dNODczOSBpcyBub3Qgc2V0CiMgQ09ORklH
X1ZJREVPX1ZQMjdTTVBYIGlzIG5vdCBzZXQKCiMKIyBSRFMgZGVjb2RlcnMKIwojIENPTkZJR19W
SURFT19TQUE2NTg4IGlzIG5vdCBzZXQKCiMKIyBWaWRlbyBkZWNvZGVycwojCiMgQ09ORklHX1ZJ
REVPX0FEVjcxODAgaXMgbm90IHNldAojIENPTkZJR19WSURFT19BRFY3MTgzIGlzIG5vdCBzZXQK
IyBDT05GSUdfVklERU9fQlQ4MTkgaXMgbm90IHNldAojIENPTkZJR19WSURFT19CVDg1NiBpcyBu
b3Qgc2V0CiMgQ09ORklHX1ZJREVPX0JUODY2IGlzIG5vdCBzZXQKIyBDT05GSUdfVklERU9fS1Mw
MTI3IGlzIG5vdCBzZXQKIyBDT05GSUdfVklERU9fU0FBNzExMCBpcyBub3Qgc2V0CiMgQ09ORklH
X1ZJREVPX1NBQTcxMVggaXMgbm90IHNldAojIENPTkZJR19WSURFT19TQUE3MTkxIGlzIG5vdCBz
ZXQKIyBDT05GSUdfVklERU9fVFZQNTE0WCBpcyBub3Qgc2V0CiMgQ09ORklHX1ZJREVPX1RWUDUx
NTAgaXMgbm90IHNldAojIENPTkZJR19WSURFT19UVlA3MDAyIGlzIG5vdCBzZXQKIyBDT05GSUdf
VklERU9fVlBYMzIyMCBpcyBub3Qgc2V0CgojCiMgVmlkZW8gYW5kIGF1ZGlvIGRlY29kZXJzCiMK
IyBDT05GSUdfVklERU9fU0FBNzE3WCBpcyBub3Qgc2V0CiMgQ09ORklHX1ZJREVPX0NYMjU4NDAg
aXMgbm90IHNldAoKIwojIE1QRUcgdmlkZW8gZW5jb2RlcnMKIwojIENPTkZJR19WSURFT19DWDIz
NDFYIGlzIG5vdCBzZXQKCiMKIyBWaWRlbyBlbmNvZGVycwojCiMgQ09ORklHX1ZJREVPX1NBQTcx
MjcgaXMgbm90IHNldAojIENPTkZJR19WSURFT19TQUE3MTg1IGlzIG5vdCBzZXQKIyBDT05GSUdf
VklERU9fQURWNzE3MCBpcyBub3Qgc2V0CiMgQ09ORklHX1ZJREVPX0FEVjcxNzUgaXMgbm90IHNl
dAojIENPTkZJR19WSURFT19BRFY3MzQzIGlzIG5vdCBzZXQKIyBDT05GSUdfVklERU9fQURWNzM5
MyBpcyBub3Qgc2V0CiMgQ09ORklHX1ZJREVPX0FLODgxWCBpcyBub3Qgc2V0CgojCiMgQ2FtZXJh
IHNlbnNvciBkZXZpY2VzCiMKIyBDT05GSUdfVklERU9fT1Y3NjcwIGlzIG5vdCBzZXQKIyBDT05G
SUdfVklERU9fVlM2NjI0IGlzIG5vdCBzZXQKIyBDT05GSUdfVklERU9fTVQ5VjAxMSBpcyBub3Qg
c2V0CiMgQ09ORklHX1ZJREVPX1RDTTgyNVggaXMgbm90IHNldAojIENPTkZJR19WSURFT19TUjAz
MFBDMzAgaXMgbm90IHNldAoKIwojIEZsYXNoIGRldmljZXMKIwoKIwojIFZpZGVvIGltcHJvdmVt
ZW50IGNoaXBzCiMKIyBDT05GSUdfVklERU9fVVBENjQwMzFBIGlzIG5vdCBzZXQKIyBDT05GSUdf
VklERU9fVVBENjQwODMgaXMgbm90IHNldAoKIwojIE1pc2NlbGFuZW91cyBoZWxwZXIgY2hpcHMK
IwojIENPTkZJR19WSURFT19USFM3MzAzIGlzIG5vdCBzZXQKIyBDT05GSUdfVklERU9fTTUyNzkw
IGlzIG5vdCBzZXQKIyBDT05GSUdfVklERU9fVklWSSBpcyBub3Qgc2V0CkNPTkZJR19WNExfVVNC
X0RSSVZFUlM9eQoKIwojIFdlYmNhbSBkZXZpY2VzCiMKQ09ORklHX1VTQl9WSURFT19DTEFTUz15
CiMgQ09ORklHX1VTQl9WSURFT19DTEFTU19JTlBVVF9FVkRFViBpcyBub3Qgc2V0CiMgQ09ORklH
X1VTQl9HU1BDQSBpcyBub3Qgc2V0CiMgQ09ORklHX1VTQl9QV0MgaXMgbm90IHNldAojIENPTkZJ
R19WSURFT19DUElBMiBpcyBub3Qgc2V0CiMgQ09ORklHX1VTQl9aUjM2NFhYIGlzIG5vdCBzZXQK
IyBDT05GSUdfVVNCX1NUS1dFQkNBTSBpcyBub3Qgc2V0CiMgQ09ORklHX1VTQl9TMjI1NSBpcyBu
b3Qgc2V0CiMgQ09ORklHX1VTQl9TTjlDMTAyIGlzIG5vdCBzZXQKCiMKIyBXZWJjYW0gYW5kL29y
IFRWIFVTQiBkZXZpY2VzCiMKIyBDT05GSUdfVklERU9fRU0yOFhYIGlzIG5vdCBzZXQKIyBDT05G
SUdfVjRMX1BMQVRGT1JNX0RSSVZFUlMgaXMgbm90IHNldAojIENPTkZJR19WNExfTUVNMk1FTV9E
UklWRVJTIGlzIG5vdCBzZXQKCiMKIyBHcmFwaGljcyBzdXBwb3J0CiMKQ09ORklHX0FHUD15CkNP
TkZJR19BR1BfQU1ENjQ9eQpDT05GSUdfQUdQX0lOVEVMPXkKIyBDT05GSUdfQUdQX1NJUyBpcyBu
b3Qgc2V0CiMgQ09ORklHX0FHUF9WSUEgaXMgbm90IHNldApDT05GSUdfVkdBX0FSQj15CkNPTkZJ
R19WR0FfQVJCX01BWF9HUFVTPTE2CiMgQ09ORklHX1ZHQV9TV0lUQ0hFUk9PIGlzIG5vdCBzZXQK
Q09ORklHX0RSTT15CkNPTkZJR19EUk1fS01TX0hFTFBFUj15CiMgQ09ORklHX0RSTV9MT0FEX0VE
SURfRklSTVdBUkUgaXMgbm90IHNldAojIENPTkZJR19EUk1fVERGWCBpcyBub3Qgc2V0CiMgQ09O
RklHX0RSTV9SMTI4IGlzIG5vdCBzZXQKIyBDT05GSUdfRFJNX1JBREVPTiBpcyBub3Qgc2V0CiMg
Q09ORklHX0RSTV9OT1VWRUFVIGlzIG5vdCBzZXQKCiMKIyBJMkMgZW5jb2RlciBvciBoZWxwZXIg
Y2hpcHMKIwojIENPTkZJR19EUk1fSTJDX0NINzAwNiBpcyBub3Qgc2V0CiMgQ09ORklHX0RSTV9J
MkNfU0lMMTY0IGlzIG5vdCBzZXQKIyBDT05GSUdfRFJNX0k4MTAgaXMgbm90IHNldApDT05GSUdf
RFJNX0k5MTU9eQpDT05GSUdfRFJNX0k5MTVfS01TPXkKIyBDT05GSUdfRFJNX01HQSBpcyBub3Qg
c2V0CiMgQ09ORklHX0RSTV9TSVMgaXMgbm90IHNldAojIENPTkZJR19EUk1fVklBIGlzIG5vdCBz
ZXQKIyBDT05GSUdfRFJNX1NBVkFHRSBpcyBub3Qgc2V0CiMgQ09ORklHX0RSTV9WTVdHRlggaXMg
bm90IHNldAojIENPTkZJR19EUk1fR01BNTAwIGlzIG5vdCBzZXQKIyBDT05GSUdfRFJNX1VETCBp
cyBub3Qgc2V0CiMgQ09ORklHX0RSTV9BU1QgaXMgbm90IHNldAojIENPTkZJR19EUk1fTUdBRzIw
MCBpcyBub3Qgc2V0CiMgQ09ORklHX0RSTV9DSVJSVVNfUUVNVSBpcyBub3Qgc2V0CiMgQ09ORklH
X1NUVUJfUE9VTFNCTyBpcyBub3Qgc2V0CiMgQ09ORklHX1ZHQVNUQVRFIGlzIG5vdCBzZXQKQ09O
RklHX1ZJREVPX09VVFBVVF9DT05UUk9MPXkKQ09ORklHX0ZCPXkKIyBDT05GSUdfRklSTVdBUkVf
RURJRCBpcyBub3Qgc2V0CiMgQ09ORklHX0ZCX0REQyBpcyBub3Qgc2V0CiMgQ09ORklHX0ZCX0JP
T1RfVkVTQV9TVVBQT1JUIGlzIG5vdCBzZXQKQ09ORklHX0ZCX0NGQl9GSUxMUkVDVD15CkNPTkZJ
R19GQl9DRkJfQ09QWUFSRUE9eQpDT05GSUdfRkJfQ0ZCX0lNQUdFQkxJVD15CiMgQ09ORklHX0ZC
X0NGQl9SRVZfUElYRUxTX0lOX0JZVEUgaXMgbm90IHNldAojIENPTkZJR19GQl9TWVNfRklMTFJF
Q1QgaXMgbm90IHNldAojIENPTkZJR19GQl9TWVNfQ09QWUFSRUEgaXMgbm90IHNldAojIENPTkZJ
R19GQl9TWVNfSU1BR0VCTElUIGlzIG5vdCBzZXQKIyBDT05GSUdfRkJfRk9SRUlHTl9FTkRJQU4g
aXMgbm90IHNldAojIENPTkZJR19GQl9TWVNfRk9QUyBpcyBub3Qgc2V0CiMgQ09ORklHX0ZCX1dN
VF9HRV9ST1BTIGlzIG5vdCBzZXQKIyBDT05GSUdfRkJfU1ZHQUxJQiBpcyBub3Qgc2V0CiMgQ09O
RklHX0ZCX01BQ01PREVTIGlzIG5vdCBzZXQKIyBDT05GSUdfRkJfQkFDS0xJR0hUIGlzIG5vdCBz
ZXQKQ09ORklHX0ZCX01PREVfSEVMUEVSUz15CkNPTkZJR19GQl9USUxFQkxJVFRJTkc9eQoKIwoj
IEZyYW1lIGJ1ZmZlciBoYXJkd2FyZSBkcml2ZXJzCiMKIyBDT05GSUdfRkJfQ0lSUlVTIGlzIG5v
dCBzZXQKIyBDT05GSUdfRkJfUE0yIGlzIG5vdCBzZXQKIyBDT05GSUdfRkJfQ1lCRVIyMDAwIGlz
IG5vdCBzZXQKIyBDT05GSUdfRkJfQVJDIGlzIG5vdCBzZXQKIyBDT05GSUdfRkJfQVNJTElBTlQg
aXMgbm90IHNldAojIENPTkZJR19GQl9JTVNUVCBpcyBub3Qgc2V0CiMgQ09ORklHX0ZCX1ZHQTE2
IGlzIG5vdCBzZXQKIyBDT05GSUdfRkJfVVZFU0EgaXMgbm90IHNldAojIENPTkZJR19GQl9WRVNB
IGlzIG5vdCBzZXQKIyBDT05GSUdfRkJfTjQxMSBpcyBub3Qgc2V0CiMgQ09ORklHX0ZCX0hHQSBp
cyBub3Qgc2V0CiMgQ09ORklHX0ZCX1MxRDEzWFhYIGlzIG5vdCBzZXQKIyBDT05GSUdfRkJfTlZJ
RElBIGlzIG5vdCBzZXQKIyBDT05GSUdfRkJfUklWQSBpcyBub3Qgc2V0CiMgQ09ORklHX0ZCX0k3
NDAgaXMgbm90IHNldAojIENPTkZJR19GQl9MRTgwNTc4IGlzIG5vdCBzZXQKIyBDT05GSUdfRkJf
TUFUUk9YIGlzIG5vdCBzZXQKIyBDT05GSUdfRkJfUkFERU9OIGlzIG5vdCBzZXQKIyBDT05GSUdf
RkJfQVRZMTI4IGlzIG5vdCBzZXQKIyBDT05GSUdfRkJfQVRZIGlzIG5vdCBzZXQKIyBDT05GSUdf
RkJfUzMgaXMgbm90IHNldAojIENPTkZJR19GQl9TQVZBR0UgaXMgbm90IHNldAojIENPTkZJR19G
Ql9TSVMgaXMgbm90IHNldAojIENPTkZJR19GQl9WSUEgaXMgbm90IHNldAojIENPTkZJR19GQl9O
RU9NQUdJQyBpcyBub3Qgc2V0CiMgQ09ORklHX0ZCX0tZUk8gaXMgbm90IHNldAojIENPTkZJR19G
Ql8zREZYIGlzIG5vdCBzZXQKIyBDT05GSUdfRkJfVk9PRE9PMSBpcyBub3Qgc2V0CiMgQ09ORklH
X0ZCX1ZUODYyMyBpcyBub3Qgc2V0CiMgQ09ORklHX0ZCX1RSSURFTlQgaXMgbm90IHNldAojIENP
TkZJR19GQl9BUksgaXMgbm90IHNldAojIENPTkZJR19GQl9QTTMgaXMgbm90IHNldAojIENPTkZJ
R19GQl9DQVJNSU5FIGlzIG5vdCBzZXQKIyBDT05GSUdfRkJfR0VPREUgaXMgbm90IHNldAojIENP
TkZJR19GQl9TTVNDVUZYIGlzIG5vdCBzZXQKIyBDT05GSUdfRkJfVURMIGlzIG5vdCBzZXQKIyBD
T05GSUdfRkJfVklSVFVBTCBpcyBub3Qgc2V0CiMgQ09ORklHX0ZCX01FVFJPTk9NRSBpcyBub3Qg
c2V0CiMgQ09ORklHX0ZCX01CODYyWFggaXMgbm90IHNldAojIENPTkZJR19GQl9CUk9BRFNIRUVU
IGlzIG5vdCBzZXQKIyBDT05GSUdfRkJfQVVPX0sxOTBYIGlzIG5vdCBzZXQKIyBDT05GSUdfRVhZ
Tk9TX1ZJREVPIGlzIG5vdCBzZXQKQ09ORklHX0JBQ0tMSUdIVF9MQ0RfU1VQUE9SVD15CiMgQ09O
RklHX0xDRF9DTEFTU19ERVZJQ0UgaXMgbm90IHNldApDT05GSUdfQkFDS0xJR0hUX0NMQVNTX0RF
VklDRT15CkNPTkZJR19CQUNLTElHSFRfR0VORVJJQz15CiMgQ09ORklHX0JBQ0tMSUdIVF9QUk9H
RUFSIGlzIG5vdCBzZXQKIyBDT05GSUdfQkFDS0xJR0hUX0FQUExFIGlzIG5vdCBzZXQKIyBDT05G
SUdfQkFDS0xJR0hUX1NBSEFSQSBpcyBub3Qgc2V0CiMgQ09ORklHX0JBQ0tMSUdIVF9BRFA4ODYw
IGlzIG5vdCBzZXQKIyBDT05GSUdfQkFDS0xJR0hUX0FEUDg4NzAgaXMgbm90IHNldAojIENPTkZJ
R19CQUNLTElHSFRfTFA4NTVYIGlzIG5vdCBzZXQKCiMKIyBDb25zb2xlIGRpc3BsYXkgZHJpdmVy
IHN1cHBvcnQKIwpDT05GSUdfVkdBX0NPTlNPTEU9eQpDT05GSUdfVkdBQ09OX1NPRlRfU0NST0xM
QkFDSz15CkNPTkZJR19WR0FDT05fU09GVF9TQ1JPTExCQUNLX1NJWkU9NjQKQ09ORklHX0RVTU1Z
X0NPTlNPTEU9eQpDT05GSUdfRlJBTUVCVUZGRVJfQ09OU09MRT15CkNPTkZJR19GUkFNRUJVRkZF
Ul9DT05TT0xFX0RFVEVDVF9QUklNQVJZPXkKIyBDT05GSUdfRlJBTUVCVUZGRVJfQ09OU09MRV9S
T1RBVElPTiBpcyBub3Qgc2V0CiMgQ09ORklHX0ZPTlRTIGlzIG5vdCBzZXQKQ09ORklHX0ZPTlRf
OHg4PXkKQ09ORklHX0ZPTlRfOHgxNj15CkNPTkZJR19MT0dPPXkKIyBDT05GSUdfTE9HT19MSU5V
WF9NT05PIGlzIG5vdCBzZXQKIyBDT05GSUdfTE9HT19MSU5VWF9WR0ExNiBpcyBub3Qgc2V0CkNP
TkZJR19MT0dPX0xJTlVYX0NMVVQyMjQ9eQpDT05GSUdfU09VTkQ9eQojIENPTkZJR19TT1VORF9P
U1NfQ09SRSBpcyBub3Qgc2V0CkNPTkZJR19TTkQ9eQpDT05GSUdfU05EX1RJTUVSPXkKQ09ORklH
X1NORF9QQ009eQpDT05GSUdfU05EX0hXREVQPXkKQ09ORklHX1NORF9SQVdNSURJPW0KQ09ORklH
X1NORF9TRVFVRU5DRVI9eQojIENPTkZJR19TTkRfU0VRX0RVTU1ZIGlzIG5vdCBzZXQKIyBDT05G
SUdfU05EX01JWEVSX09TUyBpcyBub3Qgc2V0CiMgQ09ORklHX1NORF9QQ01fT1NTIGlzIG5vdCBz
ZXQKIyBDT05GSUdfU05EX1NFUVVFTkNFUl9PU1MgaXMgbm90IHNldApDT05GSUdfU05EX0hSVElN
RVI9eQpDT05GSUdfU05EX1NFUV9IUlRJTUVSX0RFRkFVTFQ9eQpDT05GSUdfU05EX0RZTkFNSUNf
TUlOT1JTPXkKIyBDT05GSUdfU05EX1NVUFBPUlRfT0xEX0FQSSBpcyBub3Qgc2V0CkNPTkZJR19T
TkRfVkVSQk9TRV9QUk9DRlM9eQojIENPTkZJR19TTkRfVkVSQk9TRV9QUklOVEsgaXMgbm90IHNl
dAojIENPTkZJR19TTkRfREVCVUcgaXMgbm90IHNldApDT05GSUdfU05EX1ZNQVNURVI9eQpDT05G
SUdfU05EX0tDVExfSkFDSz15CkNPTkZJR19TTkRfRE1BX1NHQlVGPXkKQ09ORklHX1NORF9SQVdN
SURJX1NFUT1tCiMgQ09ORklHX1NORF9PUEwzX0xJQl9TRVEgaXMgbm90IHNldAojIENPTkZJR19T
TkRfT1BMNF9MSUJfU0VRIGlzIG5vdCBzZXQKIyBDT05GSUdfU05EX1NCQVdFX1NFUSBpcyBub3Qg
c2V0CiMgQ09ORklHX1NORF9FTVUxMEsxX1NFUSBpcyBub3Qgc2V0CiMgQ09ORklHX1NORF9EUklW
RVJTIGlzIG5vdCBzZXQKQ09ORklHX1NORF9QQ0k9eQojIENPTkZJR19TTkRfQUQxODg5IGlzIG5v
dCBzZXQKIyBDT05GSUdfU05EX0FMUzMwMCBpcyBub3Qgc2V0CiMgQ09ORklHX1NORF9BTFM0MDAw
IGlzIG5vdCBzZXQKIyBDT05GSUdfU05EX0FMSTU0NTEgaXMgbm90IHNldAojIENPTkZJR19TTkRf
QVNJSFBJIGlzIG5vdCBzZXQKIyBDT05GSUdfU05EX0FUSUlYUCBpcyBub3Qgc2V0CiMgQ09ORklH
X1NORF9BVElJWFBfTU9ERU0gaXMgbm90IHNldAojIENPTkZJR19TTkRfQVU4ODEwIGlzIG5vdCBz
ZXQKIyBDT05GSUdfU05EX0FVODgyMCBpcyBub3Qgc2V0CiMgQ09ORklHX1NORF9BVTg4MzAgaXMg
bm90IHNldAojIENPTkZJR19TTkRfQVcyIGlzIG5vdCBzZXQKIyBDT05GSUdfU05EX0FaVDMzMjgg
aXMgbm90IHNldAojIENPTkZJR19TTkRfQlQ4N1ggaXMgbm90IHNldAojIENPTkZJR19TTkRfQ0Ew
MTA2IGlzIG5vdCBzZXQKIyBDT05GSUdfU05EX0NNSVBDSSBpcyBub3Qgc2V0CiMgQ09ORklHX1NO
RF9PWFlHRU4gaXMgbm90IHNldAojIENPTkZJR19TTkRfQ1M0MjgxIGlzIG5vdCBzZXQKIyBDT05G
SUdfU05EX0NTNDZYWCBpcyBub3Qgc2V0CiMgQ09ORklHX1NORF9DUzU1MzAgaXMgbm90IHNldAoj
IENPTkZJR19TTkRfQ1M1NTM1QVVESU8gaXMgbm90IHNldAojIENPTkZJR19TTkRfQ1RYRkkgaXMg
bm90IHNldAojIENPTkZJR19TTkRfREFSTEEyMCBpcyBub3Qgc2V0CiMgQ09ORklHX1NORF9HSU5B
MjAgaXMgbm90IHNldAojIENPTkZJR19TTkRfTEFZTEEyMCBpcyBub3Qgc2V0CiMgQ09ORklHX1NO
RF9EQVJMQTI0IGlzIG5vdCBzZXQKIyBDT05GSUdfU05EX0dJTkEyNCBpcyBub3Qgc2V0CiMgQ09O
RklHX1NORF9MQVlMQTI0IGlzIG5vdCBzZXQKIyBDT05GSUdfU05EX01PTkEgaXMgbm90IHNldAoj
IENPTkZJR19TTkRfTUlBIGlzIG5vdCBzZXQKIyBDT05GSUdfU05EX0VDSE8zRyBpcyBub3Qgc2V0
CiMgQ09ORklHX1NORF9JTkRJR08gaXMgbm90IHNldAojIENPTkZJR19TTkRfSU5ESUdPSU8gaXMg
bm90IHNldAojIENPTkZJR19TTkRfSU5ESUdPREogaXMgbm90IHNldAojIENPTkZJR19TTkRfSU5E
SUdPSU9YIGlzIG5vdCBzZXQKIyBDT05GSUdfU05EX0lORElHT0RKWCBpcyBub3Qgc2V0CiMgQ09O
RklHX1NORF9FTVUxMEsxIGlzIG5vdCBzZXQKIyBDT05GSUdfU05EX0VNVTEwSzFYIGlzIG5vdCBz
ZXQKIyBDT05GSUdfU05EX0VOUzEzNzAgaXMgbm90IHNldAojIENPTkZJR19TTkRfRU5TMTM3MSBp
cyBub3Qgc2V0CiMgQ09ORklHX1NORF9FUzE5MzggaXMgbm90IHNldAojIENPTkZJR19TTkRfRVMx
OTY4IGlzIG5vdCBzZXQKIyBDT05GSUdfU05EX0ZNODAxIGlzIG5vdCBzZXQKQ09ORklHX1NORF9I
REFfSU5URUw9eQpDT05GSUdfU05EX0hEQV9QUkVBTExPQ19TSVpFPTY0CkNPTkZJR19TTkRfSERB
X0hXREVQPXkKIyBDT05GSUdfU05EX0hEQV9SRUNPTkZJRyBpcyBub3Qgc2V0CiMgQ09ORklHX1NO
RF9IREFfSU5QVVRfQkVFUCBpcyBub3Qgc2V0CiMgQ09ORklHX1NORF9IREFfSU5QVVRfSkFDSyBp
cyBub3Qgc2V0CiMgQ09ORklHX1NORF9IREFfUEFUQ0hfTE9BREVSIGlzIG5vdCBzZXQKQ09ORklH
X1NORF9IREFfQ09ERUNfUkVBTFRFSz15CiMgQ09ORklHX1NORF9IREFfQ09ERUNfQU5BTE9HIGlz
IG5vdCBzZXQKIyBDT05GSUdfU05EX0hEQV9DT0RFQ19TSUdNQVRFTCBpcyBub3Qgc2V0CiMgQ09O
RklHX1NORF9IREFfQ09ERUNfVklBIGlzIG5vdCBzZXQKIyBDT05GSUdfU05EX0hEQV9DT0RFQ19I
RE1JIGlzIG5vdCBzZXQKIyBDT05GSUdfU05EX0hEQV9DT0RFQ19DSVJSVVMgaXMgbm90IHNldAoj
IENPTkZJR19TTkRfSERBX0NPREVDX0NPTkVYQU5UIGlzIG5vdCBzZXQKIyBDT05GSUdfU05EX0hE
QV9DT0RFQ19DQTAxMTAgaXMgbm90IHNldAojIENPTkZJR19TTkRfSERBX0NPREVDX0NBMDEzMiBp
cyBub3Qgc2V0CiMgQ09ORklHX1NORF9IREFfQ09ERUNfQ01FRElBIGlzIG5vdCBzZXQKIyBDT05G
SUdfU05EX0hEQV9DT0RFQ19TSTMwNTQgaXMgbm90IHNldAojIENPTkZJR19TTkRfSERBX0dFTkVS
SUMgaXMgbm90IHNldAojIENPTkZJR19TTkRfSERBX1BPV0VSX1NBVkUgaXMgbm90IHNldAojIENP
TkZJR19TTkRfSERTUCBpcyBub3Qgc2V0CiMgQ09ORklHX1NORF9IRFNQTSBpcyBub3Qgc2V0CiMg
Q09ORklHX1NORF9JQ0UxNzEyIGlzIG5vdCBzZXQKIyBDT05GSUdfU05EX0lDRTE3MjQgaXMgbm90
IHNldAojIENPTkZJR19TTkRfSU5URUw4WDAgaXMgbm90IHNldAojIENPTkZJR19TTkRfSU5URUw4
WDBNIGlzIG5vdCBzZXQKIyBDT05GSUdfU05EX0tPUkcxMjEyIGlzIG5vdCBzZXQKIyBDT05GSUdf
U05EX0xPTEEgaXMgbm90IHNldAojIENPTkZJR19TTkRfTFg2NDY0RVMgaXMgbm90IHNldAojIENP
TkZJR19TTkRfTUFFU1RSTzMgaXMgbm90IHNldAojIENPTkZJR19TTkRfTUlYQVJUIGlzIG5vdCBz
ZXQKIyBDT05GSUdfU05EX05NMjU2IGlzIG5vdCBzZXQKIyBDT05GSUdfU05EX1BDWEhSIGlzIG5v
dCBzZXQKIyBDT05GSUdfU05EX1JJUFRJREUgaXMgbm90IHNldAojIENPTkZJR19TTkRfUk1FMzIg
aXMgbm90IHNldAojIENPTkZJR19TTkRfUk1FOTYgaXMgbm90IHNldAojIENPTkZJR19TTkRfUk1F
OTY1MiBpcyBub3Qgc2V0CiMgQ09ORklHX1NORF9TT05JQ1ZJQkVTIGlzIG5vdCBzZXQKIyBDT05G
SUdfU05EX1RSSURFTlQgaXMgbm90IHNldAojIENPTkZJR19TTkRfVklBODJYWCBpcyBub3Qgc2V0
CiMgQ09ORklHX1NORF9WSUE4MlhYX01PREVNIGlzIG5vdCBzZXQKIyBDT05GSUdfU05EX1ZJUlRV
T1NPIGlzIG5vdCBzZXQKIyBDT05GSUdfU05EX1ZYMjIyIGlzIG5vdCBzZXQKIyBDT05GSUdfU05E
X1lNRlBDSSBpcyBub3Qgc2V0CkNPTkZJR19TTkRfVVNCPXkKQ09ORklHX1NORF9VU0JfQVVESU89
bQojIENPTkZJR19TTkRfVVNCX1VBMTAxIGlzIG5vdCBzZXQKIyBDT05GSUdfU05EX1VTQl9VU1gy
WSBpcyBub3Qgc2V0CiMgQ09ORklHX1NORF9VU0JfQ0FJQVEgaXMgbm90IHNldAojIENPTkZJR19T
TkRfVVNCX1VTMTIyTCBpcyBub3Qgc2V0CiMgQ09ORklHX1NORF9VU0JfNkZJUkUgaXMgbm90IHNl
dAojIENPTkZJR19TTkRfUENNQ0lBIGlzIG5vdCBzZXQKIyBDT05GSUdfU05EX1NPQyBpcyBub3Qg
c2V0CiMgQ09ORklHX1NPVU5EX1BSSU1FIGlzIG5vdCBzZXQKCiMKIyBISUQgc3VwcG9ydAojCkNP
TkZJR19ISUQ9eQpDT05GSUdfSElEUkFXPXkKIyBDT05GSUdfVUhJRCBpcyBub3Qgc2V0CkNPTkZJ
R19ISURfR0VORVJJQz15CgojCiMgU3BlY2lhbCBISUQgZHJpdmVycwojCkNPTkZJR19ISURfQTRU
RUNIPXkKIyBDT05GSUdfSElEX0FDUlVYIGlzIG5vdCBzZXQKQ09ORklHX0hJRF9BUFBMRT15CiMg
Q09ORklHX0hJRF9BVVJFQUwgaXMgbm90IHNldApDT05GSUdfSElEX0JFTEtJTj15CkNPTkZJR19I
SURfQ0hFUlJZPXkKQ09ORklHX0hJRF9DSElDT05ZPXkKIyBDT05GSUdfSElEX1BST0RJS0VZUyBp
cyBub3Qgc2V0CkNPTkZJR19ISURfQ1lQUkVTUz15CiMgQ09ORklHX0hJRF9EUkFHT05SSVNFIGlz
IG5vdCBzZXQKIyBDT05GSUdfSElEX0VNU19GRiBpcyBub3Qgc2V0CkNPTkZJR19ISURfRVpLRVk9
eQojIENPTkZJR19ISURfSE9MVEVLIGlzIG5vdCBzZXQKIyBDT05GSUdfSElEX0tFWVRPVUNIIGlz
IG5vdCBzZXQKQ09ORklHX0hJRF9LWUU9eQojIENPTkZJR19ISURfVUNMT0dJQyBpcyBub3Qgc2V0
CiMgQ09ORklHX0hJRF9XQUxUT1AgaXMgbm90IHNldAojIENPTkZJR19ISURfR1lSQVRJT04gaXMg
bm90IHNldAojIENPTkZJR19ISURfVFdJTkhBTiBpcyBub3Qgc2V0CkNPTkZJR19ISURfS0VOU0lO
R1RPTj15CiMgQ09ORklHX0hJRF9MQ1BPV0VSIGlzIG5vdCBzZXQKIyBDT05GSUdfSElEX0xFTk9W
T19UUEtCRCBpcyBub3Qgc2V0CkNPTkZJR19ISURfTE9HSVRFQ0g9eQpDT05GSUdfSElEX0xPR0lU
RUNIX0RKPXkKIyBDT05GSUdfTE9HSVRFQ0hfRkYgaXMgbm90IHNldAojIENPTkZJR19MT0dJUlVN
QkxFUEFEMl9GRiBpcyBub3Qgc2V0CiMgQ09ORklHX0xPR0lHOTQwX0ZGIGlzIG5vdCBzZXQKIyBD
T05GSUdfTE9HSVdIRUVMU19GRiBpcyBub3Qgc2V0CkNPTkZJR19ISURfTUlDUk9TT0ZUPXkKQ09O
RklHX0hJRF9NT05URVJFWT15CiMgQ09ORklHX0hJRF9NVUxUSVRPVUNIIGlzIG5vdCBzZXQKIyBD
T05GSUdfSElEX05UUklHIGlzIG5vdCBzZXQKIyBDT05GSUdfSElEX09SVEVLIGlzIG5vdCBzZXQK
IyBDT05GSUdfSElEX1BBTlRIRVJMT1JEIGlzIG5vdCBzZXQKIyBDT05GSUdfSElEX1BFVEFMWU5Y
IGlzIG5vdCBzZXQKIyBDT05GSUdfSElEX1BJQ09MQ0QgaXMgbm90IHNldAojIENPTkZJR19ISURf
UFJJTUFYIGlzIG5vdCBzZXQKIyBDT05GSUdfSElEX1JPQ0NBVCBpcyBub3Qgc2V0CiMgQ09ORklH
X0hJRF9TQUlURUsgaXMgbm90IHNldAojIENPTkZJR19ISURfU0FNU1VORyBpcyBub3Qgc2V0CiMg
Q09ORklHX0hJRF9TT05ZIGlzIG5vdCBzZXQKIyBDT05GSUdfSElEX1NQRUVETElOSyBpcyBub3Qg
c2V0CiMgQ09ORklHX0hJRF9TVU5QTFVTIGlzIG5vdCBzZXQKIyBDT05GSUdfSElEX0dSRUVOQVNJ
QSBpcyBub3Qgc2V0CiMgQ09ORklHX0hJRF9TTUFSVEpPWVBMVVMgaXMgbm90IHNldAojIENPTkZJ
R19ISURfVElWTyBpcyBub3Qgc2V0CiMgQ09ORklHX0hJRF9UT1BTRUVEIGlzIG5vdCBzZXQKIyBD
T05GSUdfSElEX1RIUlVTVE1BU1RFUiBpcyBub3Qgc2V0CiMgQ09ORklHX0hJRF9aRVJPUExVUyBp
cyBub3Qgc2V0CiMgQ09ORklHX0hJRF9aWURBQ1JPTiBpcyBub3Qgc2V0CgojCiMgVVNCIEhJRCBz
dXBwb3J0CiMKQ09ORklHX1VTQl9ISUQ9eQojIENPTkZJR19ISURfUElEIGlzIG5vdCBzZXQKQ09O
RklHX1VTQl9ISURERVY9eQpDT05GSUdfVVNCX0FSQ0hfSEFTX09IQ0k9eQpDT05GSUdfVVNCX0FS
Q0hfSEFTX0VIQ0k9eQpDT05GSUdfVVNCX0FSQ0hfSEFTX1hIQ0k9eQpDT05GSUdfVVNCX1NVUFBP
UlQ9eQpDT05GSUdfVVNCX0NPTU1PTj15CkNPTkZJR19VU0JfQVJDSF9IQVNfSENEPXkKQ09ORklH
X1VTQj15CkNPTkZJR19VU0JfREVCVUc9eQpDT05GSUdfVVNCX0FOTk9VTkNFX05FV19ERVZJQ0VT
PXkKCiMKIyBNaXNjZWxsYW5lb3VzIFVTQiBvcHRpb25zCiMKQ09ORklHX1VTQl9EWU5BTUlDX01J
Tk9SUz15CiMgQ09ORklHX1VTQl9TVVNQRU5EIGlzIG5vdCBzZXQKIyBDT05GSUdfVVNCX09UR19X
SElURUxJU1QgaXMgbm90IHNldAojIENPTkZJR19VU0JfT1RHX0JMQUNLTElTVF9IVUIgaXMgbm90
IHNldAojIENPTkZJR19VU0JfTU9OIGlzIG5vdCBzZXQKIyBDT05GSUdfVVNCX1dVU0JfQ0JBRiBp
cyBub3Qgc2V0CgojCiMgVVNCIEhvc3QgQ29udHJvbGxlciBEcml2ZXJzCiMKIyBDT05GSUdfVVNC
X0M2N1gwMF9IQ0QgaXMgbm90IHNldAojIENPTkZJR19VU0JfWEhDSV9IQ0QgaXMgbm90IHNldApD
T05GSUdfVVNCX0VIQ0lfSENEPXkKIyBDT05GSUdfVVNCX0VIQ0lfUk9PVF9IVUJfVFQgaXMgbm90
IHNldAojIENPTkZJR19VU0JfRUhDSV9UVF9ORVdTQ0hFRCBpcyBub3Qgc2V0CiMgQ09ORklHX1VT
Ql9PWFUyMTBIUF9IQ0QgaXMgbm90IHNldAojIENPTkZJR19VU0JfSVNQMTE2WF9IQ0QgaXMgbm90
IHNldAojIENPTkZJR19VU0JfSVNQMTc2MF9IQ0QgaXMgbm90IHNldAojIENPTkZJR19VU0JfSVNQ
MTM2Ml9IQ0QgaXMgbm90IHNldAojIENPTkZJR19VU0JfT0hDSV9IQ0QgaXMgbm90IHNldAojIENP
TkZJR19VU0JfRUhDSV9IQ0RfUExBVEZPUk0gaXMgbm90IHNldApDT05GSUdfVVNCX1VIQ0lfSENE
PXkKIyBDT05GSUdfVVNCX1NMODExX0hDRCBpcyBub3Qgc2V0CiMgQ09ORklHX1VTQl9SOEE2NjU5
N19IQ0QgaXMgbm90IHNldAojIENPTkZJR19VU0JfSENEX1NTQiBpcyBub3Qgc2V0CiMgQ09ORklH
X1VTQl9DSElQSURFQSBpcyBub3Qgc2V0CgojCiMgVVNCIERldmljZSBDbGFzcyBkcml2ZXJzCiMK
Q09ORklHX1VTQl9BQ009eQojIENPTkZJR19VU0JfUFJJTlRFUiBpcyBub3Qgc2V0CiMgQ09ORklH
X1VTQl9XRE0gaXMgbm90IHNldAojIENPTkZJR19VU0JfVE1DIGlzIG5vdCBzZXQKCiMKIyBOT1RF
OiBVU0JfU1RPUkFHRSBkZXBlbmRzIG9uIFNDU0kgYnV0IEJMS19ERVZfU0QgbWF5CiMKCiMKIyBh
bHNvIGJlIG5lZWRlZDsgc2VlIFVTQl9TVE9SQUdFIEhlbHAgZm9yIG1vcmUgaW5mbwojCkNPTkZJ
R19VU0JfU1RPUkFHRT15CiMgQ09ORklHX1VTQl9TVE9SQUdFX0RFQlVHIGlzIG5vdCBzZXQKIyBD
T05GSUdfVVNCX1NUT1JBR0VfUkVBTFRFSyBpcyBub3Qgc2V0CiMgQ09ORklHX1VTQl9TVE9SQUdF
X0RBVEFGQUIgaXMgbm90IHNldAojIENPTkZJR19VU0JfU1RPUkFHRV9GUkVFQ09NIGlzIG5vdCBz
ZXQKIyBDT05GSUdfVVNCX1NUT1JBR0VfSVNEMjAwIGlzIG5vdCBzZXQKIyBDT05GSUdfVVNCX1NU
T1JBR0VfVVNCQVQgaXMgbm90IHNldAojIENPTkZJR19VU0JfU1RPUkFHRV9TRERSMDkgaXMgbm90
IHNldAojIENPTkZJR19VU0JfU1RPUkFHRV9TRERSNTUgaXMgbm90IHNldAojIENPTkZJR19VU0Jf
U1RPUkFHRV9KVU1QU0hPVCBpcyBub3Qgc2V0CiMgQ09ORklHX1VTQl9TVE9SQUdFX0FMQVVEQSBp
cyBub3Qgc2V0CiMgQ09ORklHX1VTQl9TVE9SQUdFX09ORVRPVUNIIGlzIG5vdCBzZXQKIyBDT05G
SUdfVVNCX1NUT1JBR0VfS0FSTUEgaXMgbm90IHNldAojIENPTkZJR19VU0JfU1RPUkFHRV9DWVBS
RVNTX0FUQUNCIGlzIG5vdCBzZXQKIyBDT05GSUdfVVNCX1NUT1JBR0VfRU5FX1VCNjI1MCBpcyBu
b3Qgc2V0CkNPTkZJR19VU0JfVUFTPXkKQ09ORklHX1VTQl9MSUJVU1VBTD15CgojCiMgVVNCIElt
YWdpbmcgZGV2aWNlcwojCiMgQ09ORklHX1VTQl9NREM4MDAgaXMgbm90IHNldAojIENPTkZJR19V
U0JfTUlDUk9URUsgaXMgbm90IHNldAoKIwojIFVTQiBwb3J0IGRyaXZlcnMKIwpDT05GSUdfVVNC
X1NFUklBTD1tCiMgQ09ORklHX1VTQl9FWlVTQiBpcyBub3Qgc2V0CiMgQ09ORklHX1VTQl9TRVJJ
QUxfR0VORVJJQyBpcyBub3Qgc2V0CiMgQ09ORklHX1VTQl9TRVJJQUxfQUlSQ0FCTEUgaXMgbm90
IHNldAojIENPTkZJR19VU0JfU0VSSUFMX0FSSzMxMTYgaXMgbm90IHNldAojIENPTkZJR19VU0Jf
U0VSSUFMX0JFTEtJTiBpcyBub3Qgc2V0CiMgQ09ORklHX1VTQl9TRVJJQUxfQ0gzNDEgaXMgbm90
IHNldAojIENPTkZJR19VU0JfU0VSSUFMX1dISVRFSEVBVCBpcyBub3Qgc2V0CiMgQ09ORklHX1VT
Ql9TRVJJQUxfRElHSV9BQ0NFTEVQT1JUIGlzIG5vdCBzZXQKIyBDT05GSUdfVVNCX1NFUklBTF9D
UDIxMFggaXMgbm90IHNldAojIENPTkZJR19VU0JfU0VSSUFMX0NZUFJFU1NfTTggaXMgbm90IHNl
dAojIENPTkZJR19VU0JfU0VSSUFMX0VNUEVHIGlzIG5vdCBzZXQKQ09ORklHX1VTQl9TRVJJQUxf
RlRESV9TSU89bQojIENPTkZJR19VU0JfU0VSSUFMX0ZVTlNPRlQgaXMgbm90IHNldAojIENPTkZJ
R19VU0JfU0VSSUFMX1ZJU09SIGlzIG5vdCBzZXQKIyBDT05GSUdfVVNCX1NFUklBTF9JUEFRIGlz
IG5vdCBzZXQKIyBDT05GSUdfVVNCX1NFUklBTF9JUiBpcyBub3Qgc2V0CiMgQ09ORklHX1VTQl9T
RVJJQUxfRURHRVBPUlQgaXMgbm90IHNldAojIENPTkZJR19VU0JfU0VSSUFMX0VER0VQT1JUX1RJ
IGlzIG5vdCBzZXQKIyBDT05GSUdfVVNCX1NFUklBTF9GODEyMzIgaXMgbm90IHNldAojIENPTkZJ
R19VU0JfU0VSSUFMX0dBUk1JTiBpcyBub3Qgc2V0CiMgQ09ORklHX1VTQl9TRVJJQUxfSVBXIGlz
IG5vdCBzZXQKIyBDT05GSUdfVVNCX1NFUklBTF9JVVUgaXMgbm90IHNldAojIENPTkZJR19VU0Jf
U0VSSUFMX0tFWVNQQU5fUERBIGlzIG5vdCBzZXQKIyBDT05GSUdfVVNCX1NFUklBTF9LRVlTUEFO
IGlzIG5vdCBzZXQKIyBDT05GSUdfVVNCX1NFUklBTF9LTFNJIGlzIG5vdCBzZXQKIyBDT05GSUdf
VVNCX1NFUklBTF9LT0JJTF9TQ1QgaXMgbm90IHNldAojIENPTkZJR19VU0JfU0VSSUFMX01DVF9V
MjMyIGlzIG5vdCBzZXQKIyBDT05GSUdfVVNCX1NFUklBTF9NRVRSTyBpcyBub3Qgc2V0CiMgQ09O
RklHX1VTQl9TRVJJQUxfTU9TNzcyMCBpcyBub3Qgc2V0CiMgQ09ORklHX1VTQl9TRVJJQUxfTU9T
Nzg0MCBpcyBub3Qgc2V0CiMgQ09ORklHX1VTQl9TRVJJQUxfTU9UT1JPTEEgaXMgbm90IHNldAoj
IENPTkZJR19VU0JfU0VSSUFMX05BVk1BTiBpcyBub3Qgc2V0CiMgQ09ORklHX1VTQl9TRVJJQUxf
UEwyMzAzIGlzIG5vdCBzZXQKIyBDT05GSUdfVVNCX1NFUklBTF9PVEk2ODU4IGlzIG5vdCBzZXQK
IyBDT05GSUdfVVNCX1NFUklBTF9RQ0FVWCBpcyBub3Qgc2V0CiMgQ09ORklHX1VTQl9TRVJJQUxf
UVVBTENPTU0gaXMgbm90IHNldAojIENPTkZJR19VU0JfU0VSSUFMX1NQQ1A4WDUgaXMgbm90IHNl
dAojIENPTkZJR19VU0JfU0VSSUFMX0hQNFggaXMgbm90IHNldAojIENPTkZJR19VU0JfU0VSSUFM
X1NBRkUgaXMgbm90IHNldAojIENPTkZJR19VU0JfU0VSSUFMX1NJRU1FTlNfTVBJIGlzIG5vdCBz
ZXQKIyBDT05GSUdfVVNCX1NFUklBTF9TSUVSUkFXSVJFTEVTUyBpcyBub3Qgc2V0CiMgQ09ORklH
X1VTQl9TRVJJQUxfU1lNQk9MIGlzIG5vdCBzZXQKIyBDT05GSUdfVVNCX1NFUklBTF9USSBpcyBu
b3Qgc2V0CiMgQ09ORklHX1VTQl9TRVJJQUxfQ1lCRVJKQUNLIGlzIG5vdCBzZXQKIyBDT05GSUdf
VVNCX1NFUklBTF9YSVJDT00gaXMgbm90IHNldAojIENPTkZJR19VU0JfU0VSSUFMX09QVElPTiBp
cyBub3Qgc2V0CiMgQ09ORklHX1VTQl9TRVJJQUxfT01OSU5FVCBpcyBub3Qgc2V0CiMgQ09ORklH
X1VTQl9TRVJJQUxfT1BUSUNPTiBpcyBub3Qgc2V0CiMgQ09ORklHX1VTQl9TRVJJQUxfVklWT1BB
WV9TRVJJQUwgaXMgbm90IHNldAojIENPTkZJR19VU0JfU0VSSUFMX1pJTyBpcyBub3Qgc2V0CiMg
Q09ORklHX1VTQl9TRVJJQUxfU1NVMTAwIGlzIG5vdCBzZXQKIyBDT05GSUdfVVNCX1NFUklBTF9R
VDIgaXMgbm90IHNldAojIENPTkZJR19VU0JfU0VSSUFMX0RFQlVHIGlzIG5vdCBzZXQKCiMKIyBV
U0IgTWlzY2VsbGFuZW91cyBkcml2ZXJzCiMKIyBDT05GSUdfVVNCX0VNSTYyIGlzIG5vdCBzZXQK
IyBDT05GSUdfVVNCX0VNSTI2IGlzIG5vdCBzZXQKIyBDT05GSUdfVVNCX0FEVVRVWCBpcyBub3Qg
c2V0CiMgQ09ORklHX1VTQl9TRVZTRUcgaXMgbm90IHNldAojIENPTkZJR19VU0JfUklPNTAwIGlz
IG5vdCBzZXQKIyBDT05GSUdfVVNCX0xFR09UT1dFUiBpcyBub3Qgc2V0CiMgQ09ORklHX1VTQl9M
Q0QgaXMgbm90IHNldAojIENPTkZJR19VU0JfTEVEIGlzIG5vdCBzZXQKIyBDT05GSUdfVVNCX0NZ
UFJFU1NfQ1k3QzYzIGlzIG5vdCBzZXQKIyBDT05GSUdfVVNCX0NZVEhFUk0gaXMgbm90IHNldAoj
IENPTkZJR19VU0JfSURNT1VTRSBpcyBub3Qgc2V0CiMgQ09ORklHX1VTQl9GVERJX0VMQU4gaXMg
bm90IHNldAojIENPTkZJR19VU0JfQVBQTEVESVNQTEFZIGlzIG5vdCBzZXQKIyBDT05GSUdfVVNC
X1NJU1VTQlZHQSBpcyBub3Qgc2V0CiMgQ09ORklHX1VTQl9MRCBpcyBub3Qgc2V0CiMgQ09ORklH
X1VTQl9UUkFOQ0VWSUJSQVRPUiBpcyBub3Qgc2V0CiMgQ09ORklHX1VTQl9JT1dBUlJJT1IgaXMg
bm90IHNldAojIENPTkZJR19VU0JfVEVTVCBpcyBub3Qgc2V0CiMgQ09ORklHX1VTQl9JU0lHSFRG
VyBpcyBub3Qgc2V0CiMgQ09ORklHX1VTQl9ZVVJFWCBpcyBub3Qgc2V0CgojCiMgVVNCIFBoeXNp
Y2FsIExheWVyIGRyaXZlcnMKIwojIENPTkZJR19VU0JfSVNQMTMwMSBpcyBub3Qgc2V0CiMgQ09O
RklHX1VTQl9HQURHRVQgaXMgbm90IHNldAoKIwojIE9URyBhbmQgcmVsYXRlZCBpbmZyYXN0cnVj
dHVyZQojCiMgQ09ORklHX05PUF9VU0JfWENFSVYgaXMgbm90IHNldAojIENPTkZJR19VV0IgaXMg
bm90IHNldAojIENPTkZJR19NTUMgaXMgbm90IHNldAojIENPTkZJR19NRU1TVElDSyBpcyBub3Qg
c2V0CkNPTkZJR19ORVdfTEVEUz15CkNPTkZJR19MRURTX0NMQVNTPXkKCiMKIyBMRUQgZHJpdmVy
cwojCiMgQ09ORklHX0xFRFNfTE0zNTMwIGlzIG5vdCBzZXQKIyBDT05GSUdfTEVEU19QQ0E5NTMy
IGlzIG5vdCBzZXQKIyBDT05GSUdfTEVEU19MUDM5NDQgaXMgbm90IHNldAojIENPTkZJR19MRURT
X0xQNTUyMSBpcyBub3Qgc2V0CiMgQ09ORklHX0xFRFNfTFA1NTIzIGlzIG5vdCBzZXQKIyBDT05G
SUdfTEVEU19DTEVWT19NQUlMIGlzIG5vdCBzZXQKIyBDT05GSUdfTEVEU19QQ0E5NTVYIGlzIG5v
dCBzZXQKIyBDT05GSUdfTEVEU19QQ0E5NjMzIGlzIG5vdCBzZXQKIyBDT05GSUdfTEVEU19CRDI4
MDIgaXMgbm90IHNldAojIENPTkZJR19MRURTX0lOVEVMX1NTNDIwMCBpcyBub3Qgc2V0CiMgQ09O
RklHX0xFRFNfVENBNjUwNyBpcyBub3Qgc2V0CiMgQ09ORklHX0xFRFNfTE0zNTU2IGlzIG5vdCBz
ZXQKIyBDT05GSUdfTEVEU19PVDIwMCBpcyBub3Qgc2V0CiMgQ09ORklHX0xFRFNfQkxJTktNIGlz
IG5vdCBzZXQKQ09ORklHX0xFRFNfVFJJR0dFUlM9eQoKIwojIExFRCBUcmlnZ2VycwojCiMgQ09O
RklHX0xFRFNfVFJJR0dFUl9USU1FUiBpcyBub3Qgc2V0CiMgQ09ORklHX0xFRFNfVFJJR0dFUl9P
TkVTSE9UIGlzIG5vdCBzZXQKIyBDT05GSUdfTEVEU19UUklHR0VSX0hFQVJUQkVBVCBpcyBub3Qg
c2V0CiMgQ09ORklHX0xFRFNfVFJJR0dFUl9CQUNLTElHSFQgaXMgbm90IHNldAojIENPTkZJR19M
RURTX1RSSUdHRVJfREVGQVVMVF9PTiBpcyBub3Qgc2V0CgojCiMgaXB0YWJsZXMgdHJpZ2dlciBp
cyB1bmRlciBOZXRmaWx0ZXIgY29uZmlnIChMRUQgdGFyZ2V0KQojCiMgQ09ORklHX0xFRFNfVFJJ
R0dFUl9UUkFOU0lFTlQgaXMgbm90IHNldAojIENPTkZJR19BQ0NFU1NJQklMSVRZIGlzIG5vdCBz
ZXQKIyBDT05GSUdfSU5GSU5JQkFORCBpcyBub3Qgc2V0CkNPTkZJR19FREFDPXkKCiMKIyBSZXBv
cnRpbmcgc3Vic3lzdGVtcwojCkNPTkZJR19FREFDX0xFR0FDWV9TWVNGUz15CiMgQ09ORklHX0VE
QUNfREVCVUcgaXMgbm90IHNldAojIENPTkZJR19FREFDX01NX0VEQUMgaXMgbm90IHNldApDT05G
SUdfUlRDX0xJQj15CkNPTkZJR19SVENfQ0xBU1M9eQpDT05GSUdfUlRDX0hDVE9TWVM9eQpDT05G
SUdfUlRDX0hDVE9TWVNfREVWSUNFPSJydGMwIgojIENPTkZJR19SVENfREVCVUcgaXMgbm90IHNl
dAoKIwojIFJUQyBpbnRlcmZhY2VzCiMKQ09ORklHX1JUQ19JTlRGX1NZU0ZTPXkKQ09ORklHX1JU
Q19JTlRGX1BST0M9eQpDT05GSUdfUlRDX0lOVEZfREVWPXkKIyBDT05GSUdfUlRDX0lOVEZfREVW
X1VJRV9FTVVMIGlzIG5vdCBzZXQKIyBDT05GSUdfUlRDX0RSVl9URVNUIGlzIG5vdCBzZXQKCiMK
IyBJMkMgUlRDIGRyaXZlcnMKIwojIENPTkZJR19SVENfRFJWX0RTMTMwNyBpcyBub3Qgc2V0CiMg
Q09ORklHX1JUQ19EUlZfRFMxMzc0IGlzIG5vdCBzZXQKIyBDT05GSUdfUlRDX0RSVl9EUzE2NzIg
aXMgbm90IHNldAojIENPTkZJR19SVENfRFJWX0RTMzIzMiBpcyBub3Qgc2V0CiMgQ09ORklHX1JU
Q19EUlZfTUFYNjkwMCBpcyBub3Qgc2V0CiMgQ09ORklHX1JUQ19EUlZfUlM1QzM3MiBpcyBub3Qg
c2V0CiMgQ09ORklHX1JUQ19EUlZfSVNMMTIwOCBpcyBub3Qgc2V0CiMgQ09ORklHX1JUQ19EUlZf
SVNMMTIwMjIgaXMgbm90IHNldAojIENPTkZJR19SVENfRFJWX1gxMjA1IGlzIG5vdCBzZXQKIyBD
T05GSUdfUlRDX0RSVl9QQ0Y4NTYzIGlzIG5vdCBzZXQKIyBDT05GSUdfUlRDX0RSVl9QQ0Y4NTgz
IGlzIG5vdCBzZXQKIyBDT05GSUdfUlRDX0RSVl9NNDFUODAgaXMgbm90IHNldAojIENPTkZJR19S
VENfRFJWX0JRMzJLIGlzIG5vdCBzZXQKIyBDT05GSUdfUlRDX0RSVl9TMzUzOTBBIGlzIG5vdCBz
ZXQKIyBDT05GSUdfUlRDX0RSVl9GTTMxMzAgaXMgbm90IHNldAojIENPTkZJR19SVENfRFJWX1JY
ODU4MSBpcyBub3Qgc2V0CiMgQ09ORklHX1JUQ19EUlZfUlg4MDI1IGlzIG5vdCBzZXQKIyBDT05G
SUdfUlRDX0RSVl9FTTMwMjcgaXMgbm90IHNldAojIENPTkZJR19SVENfRFJWX1JWMzAyOUMyIGlz
IG5vdCBzZXQKCiMKIyBTUEkgUlRDIGRyaXZlcnMKIwoKIwojIFBsYXRmb3JtIFJUQyBkcml2ZXJz
CiMKQ09ORklHX1JUQ19EUlZfQ01PUz15CiMgQ09ORklHX1JUQ19EUlZfRFMxMjg2IGlzIG5vdCBz
ZXQKIyBDT05GSUdfUlRDX0RSVl9EUzE1MTEgaXMgbm90IHNldAojIENPTkZJR19SVENfRFJWX0RT
MTU1MyBpcyBub3Qgc2V0CiMgQ09ORklHX1JUQ19EUlZfRFMxNzQyIGlzIG5vdCBzZXQKIyBDT05G
SUdfUlRDX0RSVl9TVEsxN1RBOCBpcyBub3Qgc2V0CiMgQ09ORklHX1JUQ19EUlZfTTQ4VDg2IGlz
IG5vdCBzZXQKIyBDT05GSUdfUlRDX0RSVl9NNDhUMzUgaXMgbm90IHNldAojIENPTkZJR19SVENf
RFJWX000OFQ1OSBpcyBub3Qgc2V0CiMgQ09ORklHX1JUQ19EUlZfTVNNNjI0MiBpcyBub3Qgc2V0
CiMgQ09ORklHX1JUQ19EUlZfQlE0ODAyIGlzIG5vdCBzZXQKIyBDT05GSUdfUlRDX0RSVl9SUDVD
MDEgaXMgbm90IHNldAojIENPTkZJR19SVENfRFJWX1YzMDIwIGlzIG5vdCBzZXQKCiMKIyBvbi1D
UFUgUlRDIGRyaXZlcnMKIwojIENPTkZJR19ETUFERVZJQ0VTIGlzIG5vdCBzZXQKIyBDT05GSUdf
QVVYRElTUExBWSBpcyBub3Qgc2V0CiMgQ09ORklHX1VJTyBpcyBub3Qgc2V0CgojCiMgVmlydGlv
IGRyaXZlcnMKIwojIENPTkZJR19WSVJUSU9fUENJIGlzIG5vdCBzZXQKIyBDT05GSUdfVklSVElP
X0JBTExPT04gaXMgbm90IHNldAojIENPTkZJR19WSVJUSU9fTU1JTyBpcyBub3Qgc2V0CgojCiMg
TWljcm9zb2Z0IEh5cGVyLVYgZ3Vlc3Qgc3VwcG9ydAojCiMgQ09ORklHX0hZUEVSViBpcyBub3Qg
c2V0CkNPTkZJR19TVEFHSU5HPXkKIyBDT05GSUdfRVQxMzFYIGlzIG5vdCBzZXQKIyBDT05GSUdf
U0xJQ09TUyBpcyBub3Qgc2V0CiMgQ09ORklHX1VTQklQX0NPUkUgaXMgbm90IHNldAojIENPTkZJ
R19XMzVVTkQgaXMgbm90IHNldApDT05GSUdfUFJJU00yX1VTQj1tCiMgQ09ORklHX0VDSE8gaXMg
bm90IHNldAojIENPTkZJR19DT01FREkgaXMgbm90IHNldAojIENPTkZJR19BU1VTX09MRUQgaXMg
bm90IHNldAojIENPTkZJR19SODE4N1NFIGlzIG5vdCBzZXQKIyBDT05GSUdfUlRMODE5MlUgaXMg
bm90IHNldAojIENPTkZJR19SVExMSUIgaXMgbm90IHNldAojIENPTkZJR19SODcxMlUgaXMgbm90
IHNldAojIENPTkZJR19SVFNfUFNUT1IgaXMgbm90IHNldAojIENPTkZJR19SVFM1MTM5IGlzIG5v
dCBzZXQKIyBDT05GSUdfVFJBTlpQT1JUIGlzIG5vdCBzZXQKIyBDT05GSUdfSURFX1BISVNPTiBp
cyBub3Qgc2V0CiMgQ09ORklHX0xJTkU2X1VTQiBpcyBub3Qgc2V0CiMgQ09ORklHX1VTQl9TRVJJ
QUxfUVVBVEVDSDIgaXMgbm90IHNldAojIENPTkZJR19WVDY2NTUgaXMgbm90IHNldAojIENPTkZJ
R19WVDY2NTYgaXMgbm90IHNldAojIENPTkZJR19EWF9TRVAgaXMgbm90IHNldAojIENPTkZJR19a
U01BTExPQyBpcyBub3Qgc2V0CiMgQ09ORklHX1dMQUdTNDlfSDIgaXMgbm90IHNldAojIENPTkZJ
R19XTEFHUzQ5X0gyNSBpcyBub3Qgc2V0CiMgQ09ORklHX0ZCX1NNN1hYIGlzIG5vdCBzZXQKIyBD
T05GSUdfQ1JZU1RBTEhEIGlzIG5vdCBzZXQKIyBDT05GSUdfRkJfWEdJIGlzIG5vdCBzZXQKIyBD
T05GSUdfQUNQSV9RVUlDS1NUQVJUIGlzIG5vdCBzZXQKIyBDT05GSUdfVVNCX0VORVNUT1JBR0Ug
aXMgbm90IHNldAojIENPTkZJR19CQ01fV0lNQVggaXMgbm90IHNldAojIENPTkZJR19GVDEwMDAg
aXMgbm90IHNldAoKIwojIFNwZWFrdXAgY29uc29sZSBzcGVlY2gKIwojIENPTkZJR19TUEVBS1VQ
IGlzIG5vdCBzZXQKIyBDT05GSUdfVE9VQ0hTQ1JFRU5fU1lOQVBUSUNTX0kyQ19STUk0IGlzIG5v
dCBzZXQKIyBDT05GSUdfU1RBR0lOR19NRURJQSBpcyBub3Qgc2V0CgojCiMgQW5kcm9pZAojCiMg
Q09ORklHX0FORFJPSUQgaXMgbm90IHNldAojIENPTkZJR19QSE9ORSBpcyBub3Qgc2V0CiMgQ09O
RklHX1JBTVNURVIgaXMgbm90IHNldAojIENPTkZJR19VU0JfV1BBTl9IQ0QgaXMgbm90IHNldAoj
IENPTkZJR19JUEFDS19CVVMgaXMgbm90IHNldAojIENPTkZJR19XSU1BWF9HRE03MlhYIGlzIG5v
dCBzZXQKIyBDT05GSUdfWDg2X1BMQVRGT1JNX0RFVklDRVMgaXMgbm90IHNldAoKIwojIEhhcmR3
YXJlIFNwaW5sb2NrIGRyaXZlcnMKIwpDT05GSUdfQ0xLRVZUX0k4MjUzPXkKQ09ORklHX0k4MjUz
X0xPQ0s9eQpDT05GSUdfQ0xLQkxEX0k4MjUzPXkKQ09ORklHX0lPTU1VX1NVUFBPUlQ9eQojIENP
TkZJR19BTURfSU9NTVUgaXMgbm90IHNldApDT05GSUdfRE1BUl9UQUJMRT15CiMgQ09ORklHX0lO
VEVMX0lPTU1VIGlzIG5vdCBzZXQKQ09ORklHX0lSUV9SRU1BUD15CgojCiMgUmVtb3RlcHJvYyBk
cml2ZXJzIChFWFBFUklNRU5UQUwpCiMKCiMKIyBScG1zZyBkcml2ZXJzIChFWFBFUklNRU5UQUwp
CiMKIyBDT05GSUdfVklSVF9EUklWRVJTIGlzIG5vdCBzZXQKIyBDT05GSUdfUE1fREVWRlJFUSBp
cyBub3Qgc2V0CiMgQ09ORklHX0VYVENPTiBpcyBub3Qgc2V0CiMgQ09ORklHX01FTU9SWSBpcyBu
b3Qgc2V0CiMgQ09ORklHX0lJTyBpcyBub3Qgc2V0CiMgQ09ORklHX1ZNRV9CVVMgaXMgbm90IHNl
dAojIENPTkZJR19QV00gaXMgbm90IHNldAoKIwojIEZpcm13YXJlIERyaXZlcnMKIwojIENPTkZJ
R19FREQgaXMgbm90IHNldApDT05GSUdfRklSTVdBUkVfTUVNTUFQPXkKIyBDT05GSUdfREVMTF9S
QlUgaXMgbm90IHNldAojIENPTkZJR19EQ0RCQVMgaXMgbm90IHNldApDT05GSUdfRE1JSUQ9eQpD
T05GSUdfRE1JX1NZU0ZTPXkKIyBDT05GSUdfSVNDU0lfSUJGVF9GSU5EIGlzIG5vdCBzZXQKIyBD
T05GSUdfR09PR0xFX0ZJUk1XQVJFIGlzIG5vdCBzZXQKCiMKIyBGaWxlIHN5c3RlbXMKIwpDT05G
SUdfRENBQ0hFX1dPUkRfQUNDRVNTPXkKIyBDT05GSUdfRVhUMl9GUyBpcyBub3Qgc2V0CiMgQ09O
RklHX0VYVDNfRlMgaXMgbm90IHNldApDT05GSUdfRVhUNF9GUz15CkNPTkZJR19FWFQ0X1VTRV9G
T1JfRVhUMjM9eQpDT05GSUdfRVhUNF9GU19YQVRUUj15CkNPTkZJR19FWFQ0X0ZTX1BPU0lYX0FD
TD15CkNPTkZJR19FWFQ0X0ZTX1NFQ1VSSVRZPXkKIyBDT05GSUdfRVhUNF9ERUJVRyBpcyBub3Qg
c2V0CkNPTkZJR19KQkQyPXkKIyBDT05GSUdfSkJEMl9ERUJVRyBpcyBub3Qgc2V0CkNPTkZJR19G
U19NQkNBQ0hFPXkKIyBDT05GSUdfUkVJU0VSRlNfRlMgaXMgbm90IHNldAojIENPTkZJR19KRlNf
RlMgaXMgbm90IHNldAojIENPTkZJR19YRlNfRlMgaXMgbm90IHNldAojIENPTkZJR19HRlMyX0ZT
IGlzIG5vdCBzZXQKIyBDT05GSUdfT0NGUzJfRlMgaXMgbm90IHNldAojIENPTkZJR19CVFJGU19G
UyBpcyBub3Qgc2V0CiMgQ09ORklHX05JTEZTMl9GUyBpcyBub3Qgc2V0CkNPTkZJR19GU19QT1NJ
WF9BQ0w9eQpDT05GSUdfRVhQT1JURlM9eQpDT05GSUdfRklMRV9MT0NLSU5HPXkKQ09ORklHX0ZT
Tk9USUZZPXkKQ09ORklHX0ROT1RJRlk9eQpDT05GSUdfSU5PVElGWV9VU0VSPXkKQ09ORklHX0ZB
Tk9USUZZPXkKIyBDT05GSUdfUVVPVEEgaXMgbm90IHNldAojIENPTkZJR19RVU9UQUNUTCBpcyBu
b3Qgc2V0CkNPTkZJR19BVVRPRlM0X0ZTPXkKQ09ORklHX0ZVU0VfRlM9eQojIENPTkZJR19DVVNF
IGlzIG5vdCBzZXQKQ09ORklHX0dFTkVSSUNfQUNMPXkKCiMKIyBDYWNoZXMKIwojIENPTkZJR19G
U0NBQ0hFIGlzIG5vdCBzZXQKCiMKIyBDRC1ST00vRFZEIEZpbGVzeXN0ZW1zCiMKQ09ORklHX0lT
Tzk2NjBfRlM9eQpDT05GSUdfSk9MSUVUPXkKIyBDT05GSUdfWklTT0ZTIGlzIG5vdCBzZXQKIyBD
T05GSUdfVURGX0ZTIGlzIG5vdCBzZXQKCiMKIyBET1MvRkFUL05UIEZpbGVzeXN0ZW1zCiMKQ09O
RklHX0ZBVF9GUz15CiMgQ09ORklHX01TRE9TX0ZTIGlzIG5vdCBzZXQKQ09ORklHX1ZGQVRfRlM9
eQpDT05GSUdfRkFUX0RFRkFVTFRfQ09ERVBBR0U9NDM3CkNPTkZJR19GQVRfREVGQVVMVF9JT0NI
QVJTRVQ9Imlzbzg4NTktMSIKIyBDT05GSUdfTlRGU19GUyBpcyBub3Qgc2V0CgojCiMgUHNldWRv
IGZpbGVzeXN0ZW1zCiMKQ09ORklHX1BST0NfRlM9eQpDT05GSUdfUFJPQ19LQ09SRT15CkNPTkZJ
R19QUk9DX1NZU0NUTD15CkNPTkZJR19QUk9DX1BBR0VfTU9OSVRPUj15CkNPTkZJR19TWVNGUz15
CkNPTkZJR19UTVBGUz15CkNPTkZJR19UTVBGU19QT1NJWF9BQ0w9eQpDT05GSUdfVE1QRlNfWEFU
VFI9eQpDT05GSUdfSFVHRVRMQkZTPXkKQ09ORklHX0hVR0VUTEJfUEFHRT15CkNPTkZJR19DT05G
SUdGU19GUz15CkNPTkZJR19NSVNDX0ZJTEVTWVNURU1TPXkKIyBDT05GSUdfQURGU19GUyBpcyBu
b3Qgc2V0CiMgQ09ORklHX0FGRlNfRlMgaXMgbm90IHNldAojIENPTkZJR19IRlNfRlMgaXMgbm90
IHNldAojIENPTkZJR19IRlNQTFVTX0ZTIGlzIG5vdCBzZXQKIyBDT05GSUdfQkVGU19GUyBpcyBu
b3Qgc2V0CiMgQ09ORklHX0JGU19GUyBpcyBub3Qgc2V0CiMgQ09ORklHX0VGU19GUyBpcyBub3Qg
c2V0CiMgQ09ORklHX0xPR0ZTIGlzIG5vdCBzZXQKIyBDT05GSUdfQ1JBTUZTIGlzIG5vdCBzZXQK
IyBDT05GSUdfU1FVQVNIRlMgaXMgbm90IHNldAojIENPTkZJR19WWEZTX0ZTIGlzIG5vdCBzZXQK
IyBDT05GSUdfTUlOSVhfRlMgaXMgbm90IHNldAojIENPTkZJR19PTUZTX0ZTIGlzIG5vdCBzZXQK
IyBDT05GSUdfSFBGU19GUyBpcyBub3Qgc2V0CiMgQ09ORklHX1FOWDRGU19GUyBpcyBub3Qgc2V0
CiMgQ09ORklHX1FOWDZGU19GUyBpcyBub3Qgc2V0CiMgQ09ORklHX1JPTUZTX0ZTIGlzIG5vdCBz
ZXQKQ09ORklHX1BTVE9SRT15CiMgQ09ORklHX1BTVE9SRV9DT05TT0xFIGlzIG5vdCBzZXQKIyBD
T05GSUdfUFNUT1JFX1JBTSBpcyBub3Qgc2V0CiMgQ09ORklHX1NZU1ZfRlMgaXMgbm90IHNldAoj
IENPTkZJR19VRlNfRlMgaXMgbm90IHNldAojIENPTkZJR19ORVRXT1JLX0ZJTEVTWVNURU1TIGlz
IG5vdCBzZXQKQ09ORklHX05MUz15CkNPTkZJR19OTFNfREVGQVVMVD0idXRmOCIKQ09ORklHX05M
U19DT0RFUEFHRV80Mzc9eQojIENPTkZJR19OTFNfQ09ERVBBR0VfNzM3IGlzIG5vdCBzZXQKIyBD
T05GSUdfTkxTX0NPREVQQUdFXzc3NSBpcyBub3Qgc2V0CiMgQ09ORklHX05MU19DT0RFUEFHRV84
NTAgaXMgbm90IHNldAojIENPTkZJR19OTFNfQ09ERVBBR0VfODUyIGlzIG5vdCBzZXQKIyBDT05G
SUdfTkxTX0NPREVQQUdFXzg1NSBpcyBub3Qgc2V0CiMgQ09ORklHX05MU19DT0RFUEFHRV84NTcg
aXMgbm90IHNldAojIENPTkZJR19OTFNfQ09ERVBBR0VfODYwIGlzIG5vdCBzZXQKIyBDT05GSUdf
TkxTX0NPREVQQUdFXzg2MSBpcyBub3Qgc2V0CiMgQ09ORklHX05MU19DT0RFUEFHRV84NjIgaXMg
bm90IHNldAojIENPTkZJR19OTFNfQ09ERVBBR0VfODYzIGlzIG5vdCBzZXQKIyBDT05GSUdfTkxT
X0NPREVQQUdFXzg2NCBpcyBub3Qgc2V0CiMgQ09ORklHX05MU19DT0RFUEFHRV84NjUgaXMgbm90
IHNldAojIENPTkZJR19OTFNfQ09ERVBBR0VfODY2IGlzIG5vdCBzZXQKIyBDT05GSUdfTkxTX0NP
REVQQUdFXzg2OSBpcyBub3Qgc2V0CiMgQ09ORklHX05MU19DT0RFUEFHRV85MzYgaXMgbm90IHNl
dAojIENPTkZJR19OTFNfQ09ERVBBR0VfOTUwIGlzIG5vdCBzZXQKIyBDT05GSUdfTkxTX0NPREVQ
QUdFXzkzMiBpcyBub3Qgc2V0CiMgQ09ORklHX05MU19DT0RFUEFHRV85NDkgaXMgbm90IHNldAoj
IENPTkZJR19OTFNfQ09ERVBBR0VfODc0IGlzIG5vdCBzZXQKIyBDT05GSUdfTkxTX0lTTzg4NTlf
OCBpcyBub3Qgc2V0CiMgQ09ORklHX05MU19DT0RFUEFHRV8xMjUwIGlzIG5vdCBzZXQKIyBDT05G
SUdfTkxTX0NPREVQQUdFXzEyNTEgaXMgbm90IHNldApDT05GSUdfTkxTX0FTQ0lJPXkKQ09ORklH
X05MU19JU084ODU5XzE9eQojIENPTkZJR19OTFNfSVNPODg1OV8yIGlzIG5vdCBzZXQKIyBDT05G
SUdfTkxTX0lTTzg4NTlfMyBpcyBub3Qgc2V0CiMgQ09ORklHX05MU19JU084ODU5XzQgaXMgbm90
IHNldAojIENPTkZJR19OTFNfSVNPODg1OV81IGlzIG5vdCBzZXQKIyBDT05GSUdfTkxTX0lTTzg4
NTlfNiBpcyBub3Qgc2V0CiMgQ09ORklHX05MU19JU084ODU5XzcgaXMgbm90IHNldAojIENPTkZJ
R19OTFNfSVNPODg1OV85IGlzIG5vdCBzZXQKIyBDT05GSUdfTkxTX0lTTzg4NTlfMTMgaXMgbm90
IHNldAojIENPTkZJR19OTFNfSVNPODg1OV8xNCBpcyBub3Qgc2V0CiMgQ09ORklHX05MU19JU084
ODU5XzE1IGlzIG5vdCBzZXQKIyBDT05GSUdfTkxTX0tPSThfUiBpcyBub3Qgc2V0CiMgQ09ORklH
X05MU19LT0k4X1UgaXMgbm90IHNldAojIENPTkZJR19OTFNfTUFDX1JPTUFOIGlzIG5vdCBzZXQK
IyBDT05GSUdfTkxTX01BQ19DRUxUSUMgaXMgbm90IHNldAojIENPTkZJR19OTFNfTUFDX0NFTlRF
VVJPIGlzIG5vdCBzZXQKIyBDT05GSUdfTkxTX01BQ19DUk9BVElBTiBpcyBub3Qgc2V0CiMgQ09O
RklHX05MU19NQUNfQ1lSSUxMSUMgaXMgbm90IHNldAojIENPTkZJR19OTFNfTUFDX0dBRUxJQyBp
cyBub3Qgc2V0CiMgQ09ORklHX05MU19NQUNfR1JFRUsgaXMgbm90IHNldAojIENPTkZJR19OTFNf
TUFDX0lDRUxBTkQgaXMgbm90IHNldAojIENPTkZJR19OTFNfTUFDX0lOVUlUIGlzIG5vdCBzZXQK
IyBDT05GSUdfTkxTX01BQ19ST01BTklBTiBpcyBub3Qgc2V0CiMgQ09ORklHX05MU19NQUNfVFVS
S0lTSCBpcyBub3Qgc2V0CkNPTkZJR19OTFNfVVRGOD15CiMgQ09ORklHX0RMTSBpcyBub3Qgc2V0
CgojCiMgS2VybmVsIGhhY2tpbmcKIwpDT05GSUdfVFJBQ0VfSVJRRkxBR1NfU1VQUE9SVD15CkNP
TkZJR19QUklOVEtfVElNRT15CkNPTkZJR19ERUZBVUxUX01FU1NBR0VfTE9HTEVWRUw9NApDT05G
SUdfRU5BQkxFX1dBUk5fREVQUkVDQVRFRD15CkNPTkZJR19FTkFCTEVfTVVTVF9DSEVDSz15CkNP
TkZJR19GUkFNRV9XQVJOPTIwNDgKQ09ORklHX01BR0lDX1NZU1JRPXkKIyBDT05GSUdfU1RSSVBf
QVNNX1NZTVMgaXMgbm90IHNldAojIENPTkZJR19SRUFEQUJMRV9BU00gaXMgbm90IHNldAojIENP
TkZJR19VTlVTRURfU1lNQk9MUyBpcyBub3Qgc2V0CkNPTkZJR19ERUJVR19GUz15CkNPTkZJR19I
RUFERVJTX0NIRUNLPXkKQ09ORklHX0RFQlVHX1NFQ1RJT05fTUlTTUFUQ0g9eQpDT05GSUdfREVC
VUdfS0VSTkVMPXkKQ09ORklHX0RFQlVHX1NISVJRPXkKQ09ORklHX0xPQ0tVUF9ERVRFQ1RPUj15
CkNPTkZJR19IQVJETE9DS1VQX0RFVEVDVE9SPXkKIyBDT05GSUdfQk9PVFBBUkFNX0hBUkRMT0NL
VVBfUEFOSUMgaXMgbm90IHNldApDT05GSUdfQk9PVFBBUkFNX0hBUkRMT0NLVVBfUEFOSUNfVkFM
VUU9MAojIENPTkZJR19CT09UUEFSQU1fU09GVExPQ0tVUF9QQU5JQyBpcyBub3Qgc2V0CkNPTkZJ
R19CT09UUEFSQU1fU09GVExPQ0tVUF9QQU5JQ19WQUxVRT0wCiMgQ09ORklHX1BBTklDX09OX09P
UFMgaXMgbm90IHNldApDT05GSUdfUEFOSUNfT05fT09QU19WQUxVRT0wCkNPTkZJR19ERVRFQ1Rf
SFVOR19UQVNLPXkKQ09ORklHX0RFRkFVTFRfSFVOR19UQVNLX1RJTUVPVVQ9MTIwCiMgQ09ORklH
X0JPT1RQQVJBTV9IVU5HX1RBU0tfUEFOSUMgaXMgbm90IHNldApDT05GSUdfQk9PVFBBUkFNX0hV
TkdfVEFTS19QQU5JQ19WQUxVRT0wCiMgQ09ORklHX1NDSEVEX0RFQlVHIGlzIG5vdCBzZXQKQ09O
RklHX1NDSEVEU1RBVFM9eQpDT05GSUdfVElNRVJfU1RBVFM9eQpDT05GSUdfREVCVUdfT0JKRUNU
Uz15CkNPTkZJR19ERUJVR19PQkpFQ1RTX1NFTEZURVNUPXkKQ09ORklHX0RFQlVHX09CSkVDVFNf
RlJFRT15CkNPTkZJR19ERUJVR19PQkpFQ1RTX1RJTUVSUz15CkNPTkZJR19ERUJVR19PQkpFQ1RT
X1dPUks9eQpDT05GSUdfREVCVUdfT0JKRUNUU19SQ1VfSEVBRD15CkNPTkZJR19ERUJVR19PQkpF
Q1RTX1BFUkNQVV9DT1VOVEVSPXkKQ09ORklHX0RFQlVHX09CSkVDVFNfRU5BQkxFX0RFRkFVTFQ9
MQpDT05GSUdfU0xVQl9ERUJVR19PTj15CiMgQ09ORklHX1NMVUJfU1RBVFMgaXMgbm90IHNldAoj
IENPTkZJR19ERUJVR19LTUVNTEVBSyBpcyBub3Qgc2V0CkNPTkZJR19ERUJVR19SVF9NVVRFWEVT
PXkKQ09ORklHX0RFQlVHX1BJX0xJU1Q9eQojIENPTkZJR19SVF9NVVRFWF9URVNURVIgaXMgbm90
IHNldApDT05GSUdfREVCVUdfU1BJTkxPQ0s9eQpDT05GSUdfREVCVUdfTVVURVhFUz15CkNPTkZJ
R19ERUJVR19MT0NLX0FMTE9DPXkKQ09ORklHX1BST1ZFX0xPQ0tJTkc9eQpDT05GSUdfUFJPVkVf
UkNVPXkKIyBDT05GSUdfUFJPVkVfUkNVX1JFUEVBVEVETFkgaXMgbm90IHNldApDT05GSUdfU1BB
UlNFX1JDVV9QT0lOVEVSPXkKQ09ORklHX0xPQ0tERVA9eQojIENPTkZJR19MT0NLX1NUQVQgaXMg
bm90IHNldApDT05GSUdfREVCVUdfTE9DS0RFUD15CkNPTkZJR19UUkFDRV9JUlFGTEFHUz15CkNP
TkZJR19ERUJVR19BVE9NSUNfU0xFRVA9eQpDT05GSUdfREVCVUdfTE9DS0lOR19BUElfU0VMRlRF
U1RTPXkKQ09ORklHX1NUQUNLVFJBQ0U9eQpDT05GSUdfREVCVUdfU1RBQ0tfVVNBR0U9eQojIENP
TkZJR19ERUJVR19LT0JKRUNUIGlzIG5vdCBzZXQKQ09ORklHX0RFQlVHX0JVR1ZFUkJPU0U9eQpD
T05GSUdfREVCVUdfSU5GTz15CkNPTkZJR19ERUJVR19JTkZPX1JFRFVDRUQ9eQpDT05GSUdfREVC
VUdfVk09eQpDT05GSUdfREVCVUdfVklSVFVBTD15CkNPTkZJR19ERUJVR19XUklURUNPVU5UPXkK
Q09ORklHX0RFQlVHX01FTU9SWV9JTklUPXkKQ09ORklHX0RFQlVHX0xJU1Q9eQpDT05GSUdfVEVT
VF9MSVNUX1NPUlQ9eQpDT05GSUdfREVCVUdfU0c9eQpDT05GSUdfREVCVUdfTk9USUZJRVJTPXkK
Q09ORklHX0RFQlVHX0NSRURFTlRJQUxTPXkKQ09ORklHX0FSQ0hfV0FOVF9GUkFNRV9QT0lOVEVS
Uz15CkNPTkZJR19GUkFNRV9QT0lOVEVSPXkKIyBDT05GSUdfQk9PVF9QUklOVEtfREVMQVkgaXMg
bm90IHNldAojIENPTkZJR19SQ1VfVE9SVFVSRV9URVNUIGlzIG5vdCBzZXQKQ09ORklHX1JDVV9D
UFVfU1RBTExfVElNRU9VVD02MAojIENPTkZJR19SQ1VfQ1BVX1NUQUxMX0lORk8gaXMgbm90IHNl
dAojIENPTkZJR19SQ1VfVFJBQ0UgaXMgbm90IHNldAojIENPTkZJR19CQUNLVFJBQ0VfU0VMRl9U
RVNUIGlzIG5vdCBzZXQKQ09ORklHX0RFQlVHX0JMT0NLX0VYVF9ERVZUPXkKQ09ORklHX0RFQlVH
X0ZPUkNFX1dFQUtfUEVSX0NQVT15CkNPTkZJR19ERUJVR19QRVJfQ1BVX01BUFM9eQojIENPTkZJ
R19MS0RUTSBpcyBub3Qgc2V0CiMgQ09ORklHX05PVElGSUVSX0VSUk9SX0lOSkVDVElPTiBpcyBu
b3Qgc2V0CiMgQ09ORklHX0ZBVUxUX0lOSkVDVElPTiBpcyBub3Qgc2V0CiMgQ09ORklHX0xBVEVO
Q1lUT1AgaXMgbm90IHNldApDT05GSUdfREVCVUdfUEFHRUFMTE9DPXkKQ09ORklHX1dBTlRfUEFH
RV9ERUJVR19GTEFHUz15CkNPTkZJR19QQUdFX0dVQVJEPXkKQ09ORklHX1VTRVJfU1RBQ0tUUkFD
RV9TVVBQT1JUPXkKQ09ORklHX05PUF9UUkFDRVI9eQpDT05GSUdfSEFWRV9GVU5DVElPTl9UUkFD
RVI9eQpDT05GSUdfSEFWRV9GVU5DVElPTl9HUkFQSF9UUkFDRVI9eQpDT05GSUdfSEFWRV9GVU5D
VElPTl9HUkFQSF9GUF9URVNUPXkKQ09ORklHX0hBVkVfRlVOQ1RJT05fVFJBQ0VfTUNPVU5UX1RF
U1Q9eQpDT05GSUdfSEFWRV9EWU5BTUlDX0ZUUkFDRT15CkNPTkZJR19IQVZFX0ZUUkFDRV9NQ09V
TlRfUkVDT1JEPXkKQ09ORklHX0hBVkVfU1lTQ0FMTF9UUkFDRVBPSU5UUz15CkNPTkZJR19IQVZF
X0NfUkVDT1JETUNPVU5UPXkKQ09ORklHX1JJTkdfQlVGRkVSPXkKQ09ORklHX0VWRU5UX1RSQUNJ
Tkc9eQojIENPTkZJR19FVkVOVF9QT1dFUl9UUkFDSU5HX0RFUFJFQ0FURUQgaXMgbm90IHNldApD
T05GSUdfQ09OVEVYVF9TV0lUQ0hfVFJBQ0VSPXkKQ09ORklHX1RSQUNJTkc9eQpDT05GSUdfR0VO
RVJJQ19UUkFDRVI9eQpDT05GSUdfVFJBQ0lOR19TVVBQT1JUPXkKQ09ORklHX0ZUUkFDRT15CiMg
Q09ORklHX0ZVTkNUSU9OX1RSQUNFUiBpcyBub3Qgc2V0CiMgQ09ORklHX0lSUVNPRkZfVFJBQ0VS
IGlzIG5vdCBzZXQKIyBDT05GSUdfU0NIRURfVFJBQ0VSIGlzIG5vdCBzZXQKIyBDT05GSUdfRlRS
QUNFX1NZU0NBTExTIGlzIG5vdCBzZXQKQ09ORklHX0JSQU5DSF9QUk9GSUxFX05PTkU9eQojIENP
TkZJR19QUk9GSUxFX0FOTk9UQVRFRF9CUkFOQ0hFUyBpcyBub3Qgc2V0CiMgQ09ORklHX1BST0ZJ
TEVfQUxMX0JSQU5DSEVTIGlzIG5vdCBzZXQKIyBDT05GSUdfU1RBQ0tfVFJBQ0VSIGlzIG5vdCBz
ZXQKIyBDT05GSUdfQkxLX0RFVl9JT19UUkFDRSBpcyBub3Qgc2V0CiMgQ09ORklHX1VQUk9CRV9F
VkVOVCBpcyBub3Qgc2V0CiMgQ09ORklHX1BST0JFX0VWRU5UUyBpcyBub3Qgc2V0CiMgQ09ORklH
X0ZUUkFDRV9TVEFSVFVQX1RFU1QgaXMgbm90IHNldApDT05GSUdfTU1JT1RSQUNFPXkKQ09ORklH
X01NSU9UUkFDRV9URVNUPW0KIyBDT05GSUdfUklOR19CVUZGRVJfQkVOQ0hNQVJLIGlzIG5vdCBz
ZXQKIyBDT05GSUdfUFJPVklERV9PSENJMTM5NF9ETUFfSU5JVCBpcyBub3Qgc2V0CiMgQ09ORklH
X0JVSUxEX0RPQ1NSQyBpcyBub3Qgc2V0CiMgQ09ORklHX0RZTkFNSUNfREVCVUcgaXMgbm90IHNl
dAojIENPTkZJR19ETUFfQVBJX0RFQlVHIGlzIG5vdCBzZXQKIyBDT05GSUdfQVRPTUlDNjRfU0VM
RlRFU1QgaXMgbm90IHNldAojIENPTkZJR19TQU1QTEVTIGlzIG5vdCBzZXQKQ09ORklHX0hBVkVf
QVJDSF9LR0RCPXkKIyBDT05GSUdfS0dEQiBpcyBub3Qgc2V0CkNPTkZJR19IQVZFX0FSQ0hfS01F
TUNIRUNLPXkKIyBDT05GSUdfS01FTUNIRUNLIGlzIG5vdCBzZXQKIyBDT05GSUdfVEVTVF9LU1RS
VE9YIGlzIG5vdCBzZXQKQ09ORklHX1NUUklDVF9ERVZNRU09eQpDT05GSUdfWDg2X1ZFUkJPU0Vf
Qk9PVFVQPXkKQ09ORklHX0VBUkxZX1BSSU5USz15CkNPTkZJR19FQVJMWV9QUklOVEtfREJHUD15
CkNPTkZJR19ERUJVR19TVEFDS09WRVJGTE9XPXkKIyBDT05GSUdfWDg2X1BURFVNUCBpcyBub3Qg
c2V0CkNPTkZJR19ERUJVR19ST0RBVEE9eQojIENPTkZJR19ERUJVR19ST0RBVEFfVEVTVCBpcyBu
b3Qgc2V0CiMgQ09ORklHX0RFQlVHX1NFVF9NT0RVTEVfUk9OWCBpcyBub3Qgc2V0CiMgQ09ORklH
X0RFQlVHX05YX1RFU1QgaXMgbm90IHNldAojIENPTkZJR19ERUJVR19UTEJGTFVTSCBpcyBub3Qg
c2V0CkNPTkZJR19JT01NVV9ERUJVRz15CiMgQ09ORklHX0lPTU1VX1NUUkVTUyBpcyBub3Qgc2V0
CkNPTkZJR19IQVZFX01NSU9UUkFDRV9TVVBQT1JUPXkKQ09ORklHX0lPX0RFTEFZX1RZUEVfMFg4
MD0wCkNPTkZJR19JT19ERUxBWV9UWVBFXzBYRUQ9MQpDT05GSUdfSU9fREVMQVlfVFlQRV9VREVM
QVk9MgpDT05GSUdfSU9fREVMQVlfVFlQRV9OT05FPTMKQ09ORklHX0lPX0RFTEFZXzBYODA9eQoj
IENPTkZJR19JT19ERUxBWV8wWEVEIGlzIG5vdCBzZXQKIyBDT05GSUdfSU9fREVMQVlfVURFTEFZ
IGlzIG5vdCBzZXQKIyBDT05GSUdfSU9fREVMQVlfTk9ORSBpcyBub3Qgc2V0CkNPTkZJR19ERUZB
VUxUX0lPX0RFTEFZX1RZUEU9MApDT05GSUdfREVCVUdfQk9PVF9QQVJBTVM9eQpDT05GSUdfQ1BB
X0RFQlVHPXkKQ09ORklHX09QVElNSVpFX0lOTElOSU5HPXkKQ09ORklHX0RFQlVHX1NUUklDVF9V
U0VSX0NPUFlfQ0hFQ0tTPXkKQ09ORklHX0RFQlVHX05NSV9TRUxGVEVTVD15CgojCiMgU2VjdXJp
dHkgb3B0aW9ucwojCiMgQ09ORklHX0tFWVMgaXMgbm90IHNldAojIENPTkZJR19TRUNVUklUWV9E
TUVTR19SRVNUUklDVCBpcyBub3Qgc2V0CiMgQ09ORklHX1NFQ1VSSVRZIGlzIG5vdCBzZXQKIyBD
T05GSUdfU0VDVVJJVFlGUyBpcyBub3Qgc2V0CkNPTkZJR19ERUZBVUxUX1NFQ1VSSVRZX0RBQz15
CkNPTkZJR19ERUZBVUxUX1NFQ1VSSVRZPSIiCkNPTkZJR19DUllQVE89eQoKIwojIENyeXB0byBj
b3JlIG9yIGhlbHBlcgojCkNPTkZJR19DUllQVE9fQUxHQVBJPXkKQ09ORklHX0NSWVBUT19BTEdB
UEkyPXkKQ09ORklHX0NSWVBUT19BRUFEPXkKQ09ORklHX0NSWVBUT19BRUFEMj15CkNPTkZJR19D
UllQVE9fQkxLQ0lQSEVSPXkKQ09ORklHX0NSWVBUT19CTEtDSVBIRVIyPXkKQ09ORklHX0NSWVBU
T19IQVNIPXkKQ09ORklHX0NSWVBUT19IQVNIMj15CkNPTkZJR19DUllQVE9fUk5HMj15CkNPTkZJ
R19DUllQVE9fUENPTVAyPXkKQ09ORklHX0NSWVBUT19NQU5BR0VSPXkKQ09ORklHX0NSWVBUT19N
QU5BR0VSMj15CiMgQ09ORklHX0NSWVBUT19VU0VSIGlzIG5vdCBzZXQKQ09ORklHX0NSWVBUT19N
QU5BR0VSX0RJU0FCTEVfVEVTVFM9eQojIENPTkZJR19DUllQVE9fR0YxMjhNVUwgaXMgbm90IHNl
dAojIENPTkZJR19DUllQVE9fTlVMTCBpcyBub3Qgc2V0CiMgQ09ORklHX0NSWVBUT19QQ1JZUFQg
aXMgbm90IHNldApDT05GSUdfQ1JZUFRPX1dPUktRVUVVRT15CiMgQ09ORklHX0NSWVBUT19DUllQ
VEQgaXMgbm90IHNldApDT05GSUdfQ1JZUFRPX0FVVEhFTkM9eQojIENPTkZJR19DUllQVE9fVEVT
VCBpcyBub3Qgc2V0CgojCiMgQXV0aGVudGljYXRlZCBFbmNyeXB0aW9uIHdpdGggQXNzb2NpYXRl
ZCBEYXRhCiMKIyBDT05GSUdfQ1JZUFRPX0NDTSBpcyBub3Qgc2V0CiMgQ09ORklHX0NSWVBUT19H
Q00gaXMgbm90IHNldAojIENPTkZJR19DUllQVE9fU0VRSVYgaXMgbm90IHNldAoKIwojIEJsb2Nr
IG1vZGVzCiMKQ09ORklHX0NSWVBUT19DQkM9eQojIENPTkZJR19DUllQVE9fQ1RSIGlzIG5vdCBz
ZXQKIyBDT05GSUdfQ1JZUFRPX0NUUyBpcyBub3Qgc2V0CkNPTkZJR19DUllQVE9fRUNCPXkKIyBD
T05GSUdfQ1JZUFRPX0xSVyBpcyBub3Qgc2V0CiMgQ09ORklHX0NSWVBUT19QQ0JDIGlzIG5vdCBz
ZXQKIyBDT05GSUdfQ1JZUFRPX1hUUyBpcyBub3Qgc2V0CgojCiMgSGFzaCBtb2RlcwojCkNPTkZJ
R19DUllQVE9fSE1BQz15CiMgQ09ORklHX0NSWVBUT19YQ0JDIGlzIG5vdCBzZXQKIyBDT05GSUdf
Q1JZUFRPX1ZNQUMgaXMgbm90IHNldAoKIwojIERpZ2VzdAojCkNPTkZJR19DUllQVE9fQ1JDMzJD
PXkKIyBDT05GSUdfQ1JZUFRPX0NSQzMyQ19JTlRFTCBpcyBub3Qgc2V0CiMgQ09ORklHX0NSWVBU
T19HSEFTSCBpcyBub3Qgc2V0CiMgQ09ORklHX0NSWVBUT19NRDQgaXMgbm90IHNldApDT05GSUdf
Q1JZUFRPX01ENT15CkNPTkZJR19DUllQVE9fTUlDSEFFTF9NSUM9eQojIENPTkZJR19DUllQVE9f
Uk1EMTI4IGlzIG5vdCBzZXQKIyBDT05GSUdfQ1JZUFRPX1JNRDE2MCBpcyBub3Qgc2V0CiMgQ09O
RklHX0NSWVBUT19STUQyNTYgaXMgbm90IHNldAojIENPTkZJR19DUllQVE9fUk1EMzIwIGlzIG5v
dCBzZXQKQ09ORklHX0NSWVBUT19TSEExPXkKQ09ORklHX0NSWVBUT19TSEExX1NTU0UzPXkKIyBD
T05GSUdfQ1JZUFRPX1NIQTI1NiBpcyBub3Qgc2V0CiMgQ09ORklHX0NSWVBUT19TSEE1MTIgaXMg
bm90IHNldAojIENPTkZJR19DUllQVE9fVEdSMTkyIGlzIG5vdCBzZXQKIyBDT05GSUdfQ1JZUFRP
X1dQNTEyIGlzIG5vdCBzZXQKIyBDT05GSUdfQ1JZUFRPX0dIQVNIX0NMTVVMX05JX0lOVEVMIGlz
IG5vdCBzZXQKCiMKIyBDaXBoZXJzCiMKQ09ORklHX0NSWVBUT19BRVM9eQojIENPTkZJR19DUllQ
VE9fQUVTX1g4Nl82NCBpcyBub3Qgc2V0CiMgQ09ORklHX0NSWVBUT19BRVNfTklfSU5URUwgaXMg
bm90IHNldAojIENPTkZJR19DUllQVE9fQU5VQklTIGlzIG5vdCBzZXQKQ09ORklHX0NSWVBUT19B
UkM0PXkKIyBDT05GSUdfQ1JZUFRPX0JMT1dGSVNIIGlzIG5vdCBzZXQKIyBDT05GSUdfQ1JZUFRP
X0JMT1dGSVNIX1g4Nl82NCBpcyBub3Qgc2V0CiMgQ09ORklHX0NSWVBUT19DQU1FTExJQSBpcyBu
b3Qgc2V0CiMgQ09ORklHX0NSWVBUT19DQU1FTExJQV9YODZfNjQgaXMgbm90IHNldAojIENPTkZJ
R19DUllQVE9fQ0FTVDUgaXMgbm90IHNldAojIENPTkZJR19DUllQVE9fQ0FTVDYgaXMgbm90IHNl
dApDT05GSUdfQ1JZUFRPX0RFUz15CiMgQ09ORklHX0NSWVBUT19GQ1JZUFQgaXMgbm90IHNldAoj
IENPTkZJR19DUllQVE9fS0hBWkFEIGlzIG5vdCBzZXQKIyBDT05GSUdfQ1JZUFRPX1NBTFNBMjAg
aXMgbm90IHNldAojIENPTkZJR19DUllQVE9fU0FMU0EyMF9YODZfNjQgaXMgbm90IHNldAojIENP
TkZJR19DUllQVE9fU0VFRCBpcyBub3Qgc2V0CiMgQ09ORklHX0NSWVBUT19TRVJQRU5UIGlzIG5v
dCBzZXQKIyBDT05GSUdfQ1JZUFRPX1NFUlBFTlRfU1NFMl9YODZfNjQgaXMgbm90IHNldAojIENP
TkZJR19DUllQVE9fU0VSUEVOVF9BVlhfWDg2XzY0IGlzIG5vdCBzZXQKIyBDT05GSUdfQ1JZUFRP
X1RFQSBpcyBub3Qgc2V0CiMgQ09ORklHX0NSWVBUT19UV09GSVNIIGlzIG5vdCBzZXQKIyBDT05G
SUdfQ1JZUFRPX1RXT0ZJU0hfWDg2XzY0IGlzIG5vdCBzZXQKIyBDT05GSUdfQ1JZUFRPX1RXT0ZJ
U0hfWDg2XzY0XzNXQVkgaXMgbm90IHNldAojIENPTkZJR19DUllQVE9fVFdPRklTSF9BVlhfWDg2
XzY0IGlzIG5vdCBzZXQKCiMKIyBDb21wcmVzc2lvbgojCiMgQ09ORklHX0NSWVBUT19ERUZMQVRF
IGlzIG5vdCBzZXQKIyBDT05GSUdfQ1JZUFRPX1pMSUIgaXMgbm90IHNldAojIENPTkZJR19DUllQ
VE9fTFpPIGlzIG5vdCBzZXQKCiMKIyBSYW5kb20gTnVtYmVyIEdlbmVyYXRpb24KIwojIENPTkZJ
R19DUllQVE9fQU5TSV9DUFJORyBpcyBub3Qgc2V0CiMgQ09ORklHX0NSWVBUT19VU0VSX0FQSV9I
QVNIIGlzIG5vdCBzZXQKIyBDT05GSUdfQ1JZUFRPX1VTRVJfQVBJX1NLQ0lQSEVSIGlzIG5vdCBz
ZXQKIyBDT05GSUdfQ1JZUFRPX0hXIGlzIG5vdCBzZXQKQ09ORklHX0hBVkVfS1ZNPXkKIyBDT05G
SUdfVklSVFVBTElaQVRJT04gaXMgbm90IHNldApDT05GSUdfQklOQVJZX1BSSU5URj15CgojCiMg
TGlicmFyeSByb3V0aW5lcwojCkNPTkZJR19CSVRSRVZFUlNFPXkKQ09ORklHX0dFTkVSSUNfU1RS
TkNQWV9GUk9NX1VTRVI9eQpDT05GSUdfR0VORVJJQ19TVFJOTEVOX1VTRVI9eQpDT05GSUdfR0VO
RVJJQ19GSU5EX0ZJUlNUX0JJVD15CkNPTkZJR19HRU5FUklDX1BDSV9JT01BUD15CkNPTkZJR19H
RU5FUklDX0lPTUFQPXkKQ09ORklHX0dFTkVSSUNfSU89eQojIENPTkZJR19DUkNfQ0NJVFQgaXMg
bm90IHNldApDT05GSUdfQ1JDMTY9eQojIENPTkZJR19DUkNfVDEwRElGIGlzIG5vdCBzZXQKIyBD
T05GSUdfQ1JDX0lUVV9UIGlzIG5vdCBzZXQKQ09ORklHX0NSQzMyPXkKIyBDT05GSUdfQ1JDMzJf
U0VMRlRFU1QgaXMgbm90IHNldApDT05GSUdfQ1JDMzJfU0xJQ0VCWTg9eQojIENPTkZJR19DUkMz
Ml9TTElDRUJZNCBpcyBub3Qgc2V0CiMgQ09ORklHX0NSQzMyX1NBUldBVEUgaXMgbm90IHNldAoj
IENPTkZJR19DUkMzMl9CSVQgaXMgbm90IHNldAojIENPTkZJR19DUkM3IGlzIG5vdCBzZXQKIyBD
T05GSUdfTElCQ1JDMzJDIGlzIG5vdCBzZXQKIyBDT05GSUdfQ1JDOCBpcyBub3Qgc2V0CkNPTkZJ
R19aTElCX0lORkxBVEU9eQpDT05GSUdfTFpPX0RFQ09NUFJFU1M9eQpDT05GSUdfWFpfREVDPXkK
Q09ORklHX1haX0RFQ19YODY9eQpDT05GSUdfWFpfREVDX1BPV0VSUEM9eQpDT05GSUdfWFpfREVD
X0lBNjQ9eQpDT05GSUdfWFpfREVDX0FSTT15CkNPTkZJR19YWl9ERUNfQVJNVEhVTUI9eQpDT05G
SUdfWFpfREVDX1NQQVJDPXkKQ09ORklHX1haX0RFQ19CQ0o9eQojIENPTkZJR19YWl9ERUNfVEVT
VCBpcyBub3Qgc2V0CkNPTkZJR19ERUNPTVBSRVNTX0daSVA9eQpDT05GSUdfREVDT01QUkVTU19C
WklQMj15CkNPTkZJR19ERUNPTVBSRVNTX0xaTUE9eQpDT05GSUdfREVDT01QUkVTU19YWj15CkNP
TkZJR19ERUNPTVBSRVNTX0xaTz15CkNPTkZJR19HRU5FUklDX0FMTE9DQVRPUj15CkNPTkZJR19I
QVNfSU9NRU09eQpDT05GSUdfSEFTX0lPUE9SVD15CkNPTkZJR19IQVNfRE1BPXkKQ09ORklHX0NI
RUNLX1NJR05BVFVSRT15CiMgQ09ORklHX0NQVU1BU0tfT0ZGU1RBQ0sgaXMgbm90IHNldApDT05G
SUdfQ1BVX1JNQVA9eQpDT05GSUdfRFFMPXkKQ09ORklHX05MQVRUUj15CkNPTkZJR19BUkNIX0hB
U19BVE9NSUM2NF9ERUNfSUZfUE9TSVRJVkU9eQpDT05GSUdfQVZFUkFHRT15CiMgQ09ORklHX0NP
UkRJQyBpcyBub3Qgc2V0CiMgQ09ORklHX0REUiBpcyBub3Qgc2V0Cg==

--MP_/LgctS8_YzoCXyr=r_doHFj6--
