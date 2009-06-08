From: Joerg Roedel <joerg.roedel@amd.com>
Subject: Re: [git pull] dma-debug updates for 2.6.31
Date: Mon, 8 Jun 2009 16:03:40 +0200
Message-ID: <20090608140340.GC5139@amd.com>
References: <20090603082654.GA22359@amd.com> <20090607093758.GD31286@elte.hu> <20090607101454.GA15331@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: iommu@lists.linux-foundation.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tx2ehsobe004.messaging.microsoft.com ([65.55.88.14]:4162 "EHLO
	TX2EHSOBE008.bigfish.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754431AbZFHOEq convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Jun 2009 10:04:46 -0400
Content-Disposition: inline
In-Reply-To: <20090607101454.GA15331@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(CC'ing the netdev people too, it looks like forcedeth has no maintaine=
r
 currently)

On Sun, Jun 07, 2009 at 12:14:54PM +0200, Ingo Molnar wrote:
>=20
> note, i'm getting this warning:
>=20
> [   17.505263] ttyS0: 1 input overrun(s)
> [   18.537568] ------------[ cut here ]------------
> [   18.539366] WARNING: at lib/dma-debug.c:812 check_unmap+0x395/0x5e=
6()
> [   18.539366] Hardware name: System Product Name
> [   18.539366] forcedeth 0000:00:0a.0: DMA-API: device driver frees D=
MA memory with wrong function [device address=3D0x000000003b95296a] [si=
ze=3D90 bytes] [mapped as single] [unmapped as page]
> [   18.539366] Pid: 4316, comm: ifup-eth Not tainted 2.6.30-rc8-tip-0=
1994-g0c51e15-dirty #50306
> [   18.539366] Call Trace:
> [   18.539366]  <IRQ>  [<ffffffff8146c4cc>] ? check_unmap+0x395/0x5e6
> [   18.539366]  [<ffffffff8105ac13>] warn_slowpath_common+0x83/0xc6
> [   18.539366]  [<ffffffff8105acd9>] warn_slowpath_fmt+0x4b/0x61
> [   18.539366]  [<ffffffff8146c234>] ? check_unmap+0xfd/0x5e6
> [   18.539366]  [<ffffffff8146c4cc>] check_unmap+0x395/0x5e6
> [   18.539366]  [<ffffffff8146c99f>] debug_dma_unmap_page+0x5e/0x74
> [   18.539366]  [<ffffffff816b1984>] nv_tx_done_optimized+0xb2/0x28a
> [   18.539366]  [<ffffffff81c9a5d2>] ? _spin_lock_irqsave+0x65/0x85
> [   18.539366]  [<ffffffff816b5aa1>] nv_napi_poll+0x28b/0x2ca
> [   18.539366]  [<ffffffff81a91d03>] net_rx_action+0xbd/0x22b
> [   18.539366]  [<ffffffff81a91e0b>] ? net_rx_action+0x1c5/0x22b
> [   18.539366]  [<ffffffff810a5015>] ? __rcu_process_callbacks+0x163/=
0x216
> [   18.539366]  [<ffffffff8106147b>] __do_softirq+0x85/0x136
> [   18.539366]  [<ffffffff81058362>] ? copy_signal+0x6b/0x39f
> [   18.539366]  [<ffffffff8101536c>] call_softirq+0x1c/0x30
> [   18.539366]  [<ffffffff8101752d>] do_softirq+0x51/0xae
> [   18.539366]  [<ffffffff81081a6d>] ? tick_handle_periodic+0x30/0x97
> [   18.539366]  [<ffffffff81061081>] irq_exit+0x52/0xaf
> [   18.539366]  [<ffffffff81030fff>] smp_apic_timer_interrupt+0x9b/0x=
c1
> [   18.539366]  [<ffffffff81014d53>] apic_timer_interrupt+0x13/0x20
> [   18.539366]  <EOI>  [<ffffffff810e5ac4>] ? kmem_cache_alloc+0x8b/0=
xcb
> [   18.539366]  [<ffffffff81058362>] ? copy_signal+0x6b/0x39f
> [   18.539366]  [<ffffffff811130eb>] ? copy_fs_struct+0xaf/0xd1
> [   18.539366]  [<ffffffff810597f2>] ? copy_process+0x580/0xd99
> [   18.539366]  [<ffffffff8105a174>] ? do_fork+0x169/0x33a
> [   18.539366]  [<ffffffff81457c69>] ? __up_read+0x8f/0xb0
> [   18.539366]  [<ffffffff81078f3a>] ? up_read+0x35/0x50
> [   18.539366]  [<ffffffff810af5bc>] ? perf_swcounter_event+0x30/0x46
> [   18.539366]  [<ffffffff8101264d>] ? sys_clone+0x37/0x52
> [   18.539366]  [<ffffffff810144f3>] ? stub_clone+0x13/0x20
> [   18.539366]  [<ffffffff81014182>] ? system_call_fastpath+0x16/0x1b
> [   18.539366] ---[ end trace 1d4adcfbc3df3215 ]---
> [   18.539366] Mapped at:
> [   18.539366]  [<ffffffff8146ceb0>] debug_dma_map_page+0x8b/0x1b9
> [   18.539366]  [<ffffffff816b0eb0>] nv_start_xmit_optimized+0x2a2/0x=
6c5
> [   18.539366]  [<ffffffff81a9503b>] dev_hard_start_xmit+0xd9/0x163
> [   18.539366]  [<ffffffff81ab0a12>] __qdisc_run+0xfc/0x223
> [   18.539366]  [<ffffffff81a95483>] dev_queue_xmit+0x284/0x3d4
> [   18.544082] ttyS0: 2 input overrun(s)
> [   18.639248] eth1: link down
>=20
> config and full dmesg attached.

This is actually a bug in the forcedeth driver and not a dma-debug
regression.

>=20
> [    0.000000] Initializing cgroup subsys cpuset
> [    0.000000] Linux version 2.6.30-rc8-tip-01994-g0c51e15-dirty (min=
go@sirius) (gcc version 4.3.2 20081105 (Red Hat 4.3.2-7) (GCC) ) #50306=
 SMP PREEMPT Sun Jun 7 11:52:45 CEST 2009
> [    0.000000] Command line: root=3D/dev/sda6 earlyprintk=3Dserial,tt=
yS0,115200 console=3DttyS0,115200 debug initcall_debug apic=3Dverbose s=
ysrq_always_enabled ignore_loglevel selinux=3D0 nmi_watchdog=3D0 panic=3D=
1 3
> [    0.000000] KERNEL supported cpus:
> [    0.000000]   Intel GenuineIntel
> [    0.000000]   AMD AuthenticAMD
> [    0.000000]   Centaur CentaurHauls
> [    0.000000] BIOS-provided physical RAM map:
> [    0.000000]  BIOS-e820: 0000000000000000 - 000000000009f800 (usabl=
e)
> [    0.000000]  BIOS-e820: 000000000009f800 - 00000000000a0000 (reser=
ved)
> [    0.000000]  BIOS-e820: 00000000000f0000 - 0000000000100000 (reser=
ved)
> [    0.000000]  BIOS-e820: 0000000000100000 - 000000003fff0000 (usabl=
e)
> [    0.000000]  BIOS-e820: 000000003fff0000 - 000000003fff3000 (ACPI =
NVS)
> [    0.000000]  BIOS-e820: 000000003fff3000 - 0000000040000000 (ACPI =
data)
> [    0.000000]  BIOS-e820: 00000000e0000000 - 00000000f0000000 (reser=
ved)
> [    0.000000]  BIOS-e820: 00000000fec00000 - 0000000100000000 (reser=
ved)
> [    0.000000] console [earlyser0] enabled
> [    0.000000] debug: ignoring loglevel setting.
> [    0.000000] DMI 2.3 present.
> [    0.000000] Phoenix BIOS detected: BIOS may corrupt low RAM, worki=
ng around it.
> [    0.000000] e820 update range: 0000000000000000 - 0000000000010000=
 (usable) =3D=3D> (reserved)
> [    0.000000] last_pfn =3D 0x3fff0 max_arch_pfn =3D 0x400000000
> [    0.000000] MTRR default type: uncachable
> [    0.000000] MTRR fixed ranges enabled:
> [    0.000000]   00000-9FFFF write-back
> [    0.000000]   A0000-BFFFF uncachable
> [    0.000000]   C0000-C7FFF write-protect
> [    0.000000]   C8000-FFFFF uncachable
> [    0.000000] MTRR variable ranges enabled:
> [    0.000000]   0 base 0000000000 mask FFC0000000 write-back
> [    0.000000]   1 disabled
> [    0.000000]   2 disabled
> [    0.000000]   3 disabled
> [    0.000000]   4 disabled
> [    0.000000]   5 disabled
> [    0.000000]   6 disabled
> [    0.000000]   7 disabled
> [    0.000000] x86 PAT enabled: cpu 0, old 0x7040600070406, new 0x701=
0600070106
> [    0.000000] initial memory mapped : 0 - 20000000
> [    0.000000] init_memory_mapping: 0000000000000000-000000003fff0000
> [    0.000000]  0000000000 - 003fff0000 page 4k
> [    0.000000] kernel direct mapping tables up to 3fff0000 @ 100000-3=
02000
> [    0.000000] No NUMA configuration found
> [    0.000000] Faking a node at 0000000000000000-000000003fff0000
> [    0.000000] Bootmem setup node 0 0000000000000000-000000003fff0000
> [    0.000000]   NODE_DATA [0000000000010000 - 0000000000043fff]
> [    0.000000]   bootmap [0000000000044000 -  000000000004bfff] pages=
 8
> [    0.000000] (6 early reservations) =3D=3D> bootmem [0000000000 - 0=
03fff0000]
> [    0.000000]   #0 [0000000000 - 0000001000]   BIOS data page =3D=3D=
> [0000000000 - 0000001000]
> [    0.000000]   #1 [0000006000 - 0000008000]       TRAMPOLINE =3D=3D=
> [0000006000 - 0000008000]
> [    0.000000]   #2 [0001000000 - 00074ca590]    TEXT DATA BSS =3D=3D=
> [0001000000 - 00074ca590]
> [    0.000000]   #3 [000009f800 - 0000100000]    BIOS reserved =3D=3D=
> [000009f800 - 0000100000]
> [    0.000000]   #4 [00074cb000 - 00074cb149]              BRK =3D=3D=
> [00074cb000 - 00074cb149]
> [    0.000000]   #5 [0000100000 - 0000300000]          PGTABLE =3D=3D=
> [0000100000 - 0000300000]
> [    0.000000] Scan SMP from ffff880000000000 for 1024 bytes.
> [    0.000000] Scan SMP from ffff88000009fc00 for 1024 bytes.
> [    0.000000] Scan SMP from ffff8800000f0000 for 65536 bytes.
> [    0.000000] found SMP MP-table at [ffff8800000f5680] f5680
> [    0.000000]   mpc: f1400-f152c
> [    0.000000] Zone PFN ranges:
> [    0.000000]   DMA      0x00000010 -> 0x00001000
> [    0.000000]   DMA32    0x00001000 -> 0x00100000
> [    0.000000]   Normal   0x00100000 -> 0x00100000
> [    0.000000] Movable zone start PFN for each node
> [    0.000000] early_node_map[2] active PFN ranges
> [    0.000000]     0: 0x00000010 -> 0x0000009f
> [    0.000000]     0: 0x00000100 -> 0x0003fff0
> [    0.000000] On node 0 totalpages: 262015
> [    0.000000]   DMA zone: 88 pages used for memmap
> [    0.000000]   DMA zone: 611 pages reserved
> [    0.000000]   DMA zone: 3284 pages, LIFO batch:0
> [    0.000000]   DMA32 zone: 5544 pages used for memmap
> [    0.000000]   DMA32 zone: 252488 pages, LIFO batch:31
> [    0.000000] Intel MultiProcessor Specification v1.4
> [    0.000000]   mpc: f1400-f152c
> [    0.000000] MPTABLE: OEM ID: OEM00000
> [    0.000000] MPTABLE: Product ID: PROD00000000
> [    0.000000] MPTABLE: APIC at: 0xFEE00000
> [    0.000000] Processor #0 (Bootup-CPU)
> [    0.000000] Processor #1
> [    0.000000] Bus #0 is PCI  =20
> [    0.000000] Bus #1 is PCI  =20
> [    0.000000] Bus #2 is PCI  =20
> [    0.000000] Bus #3 is PCI  =20
> [    0.000000] Bus #4 is PCI  =20
> [    0.000000] Bus #5 is PCI  =20
> [    0.000000] Bus #6 is ISA  =20
> [    0.000000] I/O APIC #2 Version 17 at 0xFEC00000.
> [    0.000000] Int: type 0, pol 3, trig 3, bus 00, IRQ 28, APIC ID 2,=
 APIC INT 0b
> [    0.000000] Int: type 0, pol 3, trig 3, bus 00, IRQ 10, APIC ID 2,=
 APIC INT 03
> [    0.000000] Int: type 0, pol 3, trig 3, bus 01, IRQ 00, APIC ID 2,=
 APIC INT 05
> [    0.000000] Int: type 0, pol 3, trig 3, bus 05, IRQ 1c, APIC ID 2,=
 APIC INT 0b
> [    0.000000] Int: type 3, pol 0, trig 0, bus 06, IRQ 00, APIC ID 2,=
 APIC INT 00
> [    0.000000] Int: type 0, pol 0, trig 0, bus 06, IRQ 01, APIC ID 2,=
 APIC INT 01
> [    0.000000] Int: type 0, pol 0, trig 0, bus 06, IRQ 00, APIC ID 2,=
 APIC INT 02
> [    0.000000] Int: type 0, pol 0, trig 0, bus 06, IRQ 04, APIC ID 2,=
 APIC INT 04
> [    0.000000] Int: type 0, pol 0, trig 0, bus 06, IRQ 06, APIC ID 2,=
 APIC INT 06
> [    0.000000] Int: type 0, pol 0, trig 0, bus 06, IRQ 07, APIC ID 2,=
 APIC INT 07
> [    0.000000] Int: type 0, pol 1, trig 1, bus 06, IRQ 08, APIC ID 2,=
 APIC INT 08
> [    0.000000] Int: type 0, pol 0, trig 0, bus 06, IRQ 09, APIC ID 2,=
 APIC INT 09
> [    0.000000] Int: type 0, pol 0, trig 0, bus 06, IRQ 0a, APIC ID 2,=
 APIC INT 0a
> [    0.000000] Int: type 0, pol 0, trig 0, bus 06, IRQ 0c, APIC ID 2,=
 APIC INT 0c
> [    0.000000] Int: type 0, pol 0, trig 0, bus 06, IRQ 0d, APIC ID 2,=
 APIC INT 0d
> [    0.000000] Int: type 0, pol 0, trig 0, bus 06, IRQ 0e, APIC ID 2,=
 APIC INT 0e
> [    0.000000] Int: type 0, pol 0, trig 0, bus 06, IRQ 0f, APIC ID 2,=
 APIC INT 0f
> [    0.000000] Lint: type 3, pol 0, trig 0, bus 00, IRQ 00, APIC ID f=
f, APIC LINT 00
> [    0.000000] Lint: type 1, pol 0, trig 0, bus 00, IRQ 00, APIC ID f=
f, APIC LINT 01
> [    0.000000] Processors: 2
> [    0.000000] SMP: Allowing 2 CPUs, 0 hotplug CPUs
> [    0.000000] mapped APIC to ffffffffff5fc000 (fee00000)
> [    0.000000] mapped IOAPIC to ffffffffff5fb000 (fec00000)
> [    0.000000] nr_irqs_gsi: 24
> [    0.000000] Allocating PCI resources starting at 40000000 (gap: 40=
000000:a0000000)
> [    0.000000] NR_CPUS:4096 nr_cpumask_bits:2 nr_cpu_ids:2 nr_node_id=
s:1
> [    0.000000] PERCPU: Embedded 30 pages at ffff88000754f000, static =
data 101984 bytes
> [    0.000000] Built 1 zonelists in Node order, mobility grouping on.=
  Total pages: 255772
> [    0.000000] Policy zone: DMA32
> [    0.000000] Kernel command line: root=3D/dev/sda6 earlyprintk=3Dse=
rial,ttyS0,115200 console=3DttyS0,115200 debug initcall_debug apic=3Dve=
rbose sysrq_always_enabled ignore_loglevel selinux=3D0 nmi_watchdog=3D0=
 panic=3D1 3
> [    0.000000] debug: sysrq always enabled.
> [    0.000000] Initializing CPU#0
> [    0.000000] RCU-based detection of stalled CPUs is enabled.
> [    0.000000] NR_IRQS:4352
> [    0.000000] PID hash table entries: 4096 (order: 12, 32768 bytes)
> [    0.000000] Fast TSC calibration using PIT
> [    0.000000] Detected 2010.509 MHz processor.
> [    0.000999] spurious 8259A interrupt: IRQ7.
> [    0.000999] Console: colour VGA+ 80x25
> [    0.000999] console handover: boot [earlyser0] -> real [ttyS0]
> [    0.000999] Lock dependency validator: Copyright (c) 2006 Red Hat,=
 Inc., Ingo Molnar
> [    0.000999] ... MAX_LOCKDEP_SUBCLASSES:  8
> [    0.000999] ... MAX_LOCK_DEPTH:          48
> [    0.000999] ... MAX_LOCKDEP_KEYS:        8191
> [    0.000999] ... CLASSHASH_SIZE:          4096
> [    0.000999] ... MAX_LOCKDEP_ENTRIES:     16384
> [    0.000999] ... MAX_LOCKDEP_CHAINS:      32768
> [    0.000999] ... CHAINHASH_SIZE:          16384
> [    0.000999]  memory used by lock dependency info: 5695 kB
> [    0.000999]  per task-struct memory footprint: 1920 bytes
> [    0.000999] Checking aperture...
> [    0.000999] No AGP bridge found
> [    0.000999] Node 0: aperture @ 20000000 size 32 MB
> [    0.000999] Aperture pointing to e820 RAM. Ignoring.
> [    0.000999] Memory: 910424k/1048512k available (12917k kernel code=
, 452k absent, 137636k reserved, 6858k data, 800k init)
> [    0.000999] SLUB: Genslabs=3D14, HWalign=3D64, Order=3D0-3, MinObj=
ects=3D0, CPUs=3D2, Nodes=3D1
> [    0.000999] ODEBUG: 11 of 11 active objects replaced
> [    0.000999] ODEBUG: selftest passed
> [    0.001011] Calibrating delay loop (skipped), value calculated usi=
ng timer frequency.. 4021.01 BogoMIPS (lpj=3D2010509)
> [    0.004447] Security Framework initialized
> [    0.005008] TOMOYO Linux initialized
> [    0.006711] Dentry cache hash table entries: 131072 (order: 8, 104=
8576 bytes)
> [    0.008938] Inode-cache hash table entries: 65536 (order: 7, 52428=
8 bytes)
> [    0.010278] Mount-cache hash table entries: 256
> [    0.012888] Initializing cgroup subsys debug
> [    0.013004] Initializing cgroup subsys ns
> [    0.014003] Initializing cgroup subsys devices
> [    0.015003] Initializing cgroup subsys freezer
> [    0.016012] Initializing cgroup subsys net_cls
> [    0.017124] CPU: L1 I Cache: 64K (64 bytes/line), D cache 64K (64 =
bytes/line)
> [    0.018000] CPU: L2 Cache: 512K (64 bytes/line)
> [    0.019001] CPU 0/0x0 -> Node 0
> [    0.020000] tseg: 0000000000
> [    0.021009] CPU: Physical Processor ID: 0
> [    0.021999] CPU: Processor Core ID: 0
> [    0.023001] mce: CPU supports 5 MCE banks
> [    0.024008] AMD Performance Monitoring support detected.
> [    0.024998] ... version:         0
> [    0.025998] ... bit width:       48
> [    0.026998] ... num counters:    4
> [    0.027998] ... value mask:      0000ffffffffffff
> [    0.028998] ... max period:      00007fffffffffff
> [    0.029998] ... fixed counters:  0
> [    0.030997] ... counter mask:    000000000000000f
> [    0.033471] Setting APIC routing to flat
> [    0.034002] enabled ExtINT on CPU#0
> [    0.035048] ExtINT not setup in hardware but reported by MP table
> [    0.036086] ENABLING IO-APIC IRQs
> [    0.036997] init IO_APIC IRQs
> [    0.037997]  2-0 (apicid-pin) not connected
> [    0.040013] IOAPIC[0]: Set routing entry (2-1 -> 0x31 -> IRQ 1 Mod=
e:0 Active:0)
> [    0.041997] IOAPIC[0]: Set routing entry (2-2 -> 0x30 -> IRQ 0 Mod=
e:0 Active:0)
> [    0.043006] IOAPIC[0]: Set routing entry (2-3 -> 0x33 -> IRQ 3 Mod=
e:1 Active:1)
> [    0.043993] IOAPIC[0]: Set routing entry (2-4 -> 0x34 -> IRQ 4 Mod=
e:0 Active:0)
> [    0.043993] IOAPIC[0]: Set routing entry (2-5 -> 0x35 -> IRQ 5 Mod=
e:1 Active:1)
> [    0.043993] IOAPIC[0]: Set routing entry (2-6 -> 0x36 -> IRQ 6 Mod=
e:0 Active:0)
> [    0.043993] IOAPIC[0]: Set routing entry (2-7 -> 0x37 -> IRQ 7 Mod=
e:0 Active:0)
> [    0.043993] IOAPIC[0]: Set routing entry (2-8 -> 0x38 -> IRQ 8 Mod=
e:0 Active:0)
> [    0.043993] IOAPIC[0]: Set routing entry (2-9 -> 0x39 -> IRQ 9 Mod=
e:0 Active:0)
> [    0.043993] IOAPIC[0]: Set routing entry (2-10 -> 0x3a -> IRQ 10 M=
ode:0 Active:0)
> [    0.043993] IOAPIC[0]: Set routing entry (2-11 -> 0x3b -> IRQ 11 M=
ode:1 Active:1)
> [    0.043993] IOAPIC[0]: Set routing entry (2-12 -> 0x3c -> IRQ 12 M=
ode:0 Active:0)
> [    0.043993] IOAPIC[0]: Set routing entry (2-13 -> 0x3d -> IRQ 13 M=
ode:0 Active:0)
> [    0.043993] IOAPIC[0]: Set routing entry (2-14 -> 0x3e -> IRQ 14 M=
ode:0 Active:0)
> [    0.043993] IOAPIC[0]: Set routing entry (2-15 -> 0x3f -> IRQ 15 M=
ode:0 Active:0)
> [    0.043993]  2-16 2-17 2-18 2-19 2-20 2-21 2-22 2-23 (apicid-pin) =
not connected
> [    0.043993] ..TIMER: vector=3D0x30 apic1=3D0 pin1=3D2 apic2=3D0 pi=
n2=3D0
> [    0.043993] ..MP-BIOS bug: 8254 timer not connected to IO-APIC
> [    0.043993] ...trying to set up timer (IRQ0) through the 8259A ...
> [    0.043993] ..... (found apic 0 pin 0) ...
> [    0.054393] ....... works.
> [    0.054993] CPU0: AMD Athlon(tm) 64 X2 Dual Core Processor 3800+ s=
tepping 02
> [    0.057993] Using local APIC timer interrupts.
> [    0.057994] calibrating APIC timer ...
> [    0.059990] ... lapic delta =3D 1256243
> [    0.059990] ..... delta 1256243
> [    0.059990] ..... mult: 53963428
> [    0.059990] ..... calibration result: 200998
> [    0.059990] ..... CPU clock speed is 2009.0990 MHz.
> [    0.059990] ..... host bus clock speed is 200.0998 MHz.
> [    0.059990] ... verify APIC timer
> [    0.162664] ... jiffies delta =3D 100
> [    0.162976] ... jiffies result ok
> [    0.163992] calling  migration_init+0x0/0x87 @ 1
> [    0.165106] initcall migration_init+0x0/0x87 returned 1 after 0 us=
ecs
> [    0.165978] initcall migration_init+0x0/0x87 returned with error c=
ode 1=20
> [    0.166977] calling  spawn_ksoftirqd+0x0/0x7f @ 1
> [    0.168043] initcall spawn_ksoftirqd+0x0/0x7f returned 0 after 0 u=
secs
> [    0.168980] calling  init_call_single_data+0x0/0xd0 @ 1
> [    0.169982] initcall init_call_single_data+0x0/0xd0 returned 0 aft=
er 0 usecs
> [    0.170977] calling  spawn_softlockup_task+0x0/0x9b @ 1
> [    0.172037] initcall spawn_softlockup_task+0x0/0x9b returned 0 aft=
er 0 usecs
> [    0.172977] calling  relay_init+0x0/0x3b @ 1
> [    0.173978] initcall relay_init+0x0/0x3b returned 0 after 0 usecs
> [    0.175236] lockdep: fixing up alternatives.
> [    0.176057] Booting processor 1 APIC 0x1 ip 0x6000
> [    0.000999] Initializing CPU#1
> [    0.000999] masked ExtINT on CPU#1
> [    0.000999] Calibrating delay using timer specific routine.. 4019.=
90 BogoMIPS (lpj=3D2009954)
> [    0.000999] CPU: L1 I Cache: 64K (64 bytes/line), D cache 64K (64 =
bytes/line)
> [    0.000999] CPU: L2 Cache: 512K (64 bytes/line)
> [    0.000999] CPU 1/0x1 -> Node 0
> [    0.000999] CPU: Physical Processor ID: 0
> [    0.000999] CPU: Processor Core ID: 1
> [    0.000999] mce: CPU supports 5 MCE banks
> [    0.000999] x86 PAT enabled: cpu 1, old 0x7040600070406, new 0x701=
0600070106
> [    0.248520] CPU1: AMD Athlon(tm) 64 X2 Dual Core Processor 3800+ s=
tepping 02
> [    0.250981] Brought up 2 CPUs
> [    0.251964] Total of 2 processors activated (8040.92 BogoMIPS).
> [    0.255206] khelper used greatest stack depth: 5280 bytes left
> [    0.265143] calling  init_cpufreq_transition_notifier_list+0x0/0x4=
2 @ 1
> [    0.265970] initcall init_cpufreq_transition_notifier_list+0x0/0x4=
2 returned 0 after 0 usecs
> [    0.266962] calling  net_ns_init+0x0/0x115 @ 1
> [    0.267961] net_namespace: 2112 bytes
> [    0.269077] initcall net_ns_init+0x0/0x115 returned 0 after 976 us=
ecs
> [    0.269964] calling  cpufreq_tsc+0x0/0x28 @ 1
> [    0.270981] initcall cpufreq_tsc+0x0/0x28 returned 0 after 0 usecs
> [    0.271962] calling  init_lapic_sysfs+0x0/0x52 @ 1
> [    0.273070] initcall init_lapic_sysfs+0x0/0x52 returned 0 after 0 =
usecs
> [    0.273962] calling  print_banner+0x0/0xe @ 1
> [    0.274964] Booting paravirtualized kernel on bare hardware
> [    0.275961] initcall print_banner+0x0/0xe returned 0 after 976 use=
cs
> [    0.276962] calling  init_smp_flush+0x0/0x63 @ 1
> [    0.277962] initcall init_smp_flush+0x0/0x63 returned 0 after 0 us=
ecs
> [    0.278962] calling  alloc_frozen_cpus+0x0/0x45 @ 1
> [    0.279965] initcall alloc_frozen_cpus+0x0/0x45 returned 0 after 0=
 usecs
> [    0.280960] calling  sysctl_init+0x0/0x3d @ 1
> [    0.281964] initcall sysctl_init+0x0/0x3d returned 0 after 0 usecs
> [    0.282959] calling  ksysfs_init+0x0/0xe4 @ 1
> [    0.284104] initcall ksysfs_init+0x0/0xe4 returned 0 after 0 usecs
> [    0.284960] calling  async_init+0x0/0x69 @ 1
> [    0.285962] initcall async_init+0x0/0x69 returned 0 after 0 usecs
> [    0.286959] calling  init_jiffies_clocksource+0x0/0x39 @ 1
> [    0.287964] initcall init_jiffies_clocksource+0x0/0x39 returned 0 =
after 0 usecs
> [    0.288959] calling  pm_init+0x0/0x5b @ 1
> [    0.289968] initcall pm_init+0x0/0x5b returned 0 after 0 usecs
> [    0.290959] calling  init_hw_breakpoint+0x0/0x39 @ 1
> [    0.291960] initcall init_hw_breakpoint+0x0/0x39 returned 0 after =
0 usecs
> [    0.292958] calling  filelock_init+0x0/0x55 @ 1
> [    0.294000] initcall filelock_init+0x0/0x55 returned 0 after 0 use=
cs
> [    0.294957] calling  init_misc_binfmt+0x0/0x67 @ 1
> [    0.295967] initcall init_misc_binfmt+0x0/0x67 returned 0 after 0 =
usecs
> [    0.296957] calling  init_script_binfmt+0x0/0x3b @ 1
> [    0.297958] initcall init_script_binfmt+0x0/0x3b returned 0 after =
0 usecs
> [    0.298956] calling  init_elf_binfmt+0x0/0x3b @ 1
> [    0.299957] initcall init_elf_binfmt+0x0/0x3b returned 0 after 0 u=
secs
> [    0.300956] calling  init_compat_elf_binfmt+0x0/0x3b @ 1
> [    0.301957] initcall init_compat_elf_binfmt+0x0/0x3b returned 0 af=
ter 0 usecs
> [    0.302957] calling  debugfs_init+0x0/0x80 @ 1
> [    0.303963] initcall debugfs_init+0x0/0x80 returned 0 after 0 usec=
s
> [    0.304957] calling  securityfs_init+0x0/0x77 @ 1
> [    0.305963] initcall securityfs_init+0x0/0x77 returned 0 after 0 u=
secs
> [    0.306957] calling  random32_init+0x0/0xff @ 1
> [    0.307957] initcall random32_init+0x0/0xff returned 0 after 0 use=
cs
> [    0.308957] calling  gnttab_init+0x0/0x1c6 @ 1
> [    0.309956] initcall gnttab_init+0x0/0x1c6 returned -19 after 0 us=
ecs
> [    0.310956] calling  regulator_init+0x0/0x53 @ 1
> [    0.311954] regulator: core version 0.5
> [    0.313047] initcall regulator_init+0x0/0x53 returned 0 after 976 =
usecs
> [    0.313956] calling  cpufreq_core_init+0x0/0xaa @ 1
> [    0.314956] initcall cpufreq_core_init+0x0/0xaa returned 0 after 0=
 usecs
> [    0.315954] calling  cpuidle_init+0x0/0x66 @ 1
> [    0.316985] initcall cpuidle_init+0x0/0x66 returned 0 after 0 usec=
s
> [    0.317994] calling  sock_init+0x0/0x85 @ 1
> [    0.319270] initcall sock_init+0x0/0x85 returned 0 after 0 usecs
> [    0.320002] calling  net_inuse_init+0x0/0x4d @ 1
> [    0.321007] initcall net_inuse_init+0x0/0x4d returned 0 after 0 us=
ecs
> [    0.322002] calling  netpoll_init+0x0/0x69 @ 1
> [    0.323003] initcall netpoll_init+0x0/0x69 returned 0 after 0 usec=
s
> [    0.324006] calling  netlink_proto_init+0x0/0x16b @ 1
> [    0.325050] NET: Registered protocol family 16
> [    0.326054] initcall netlink_proto_init+0x0/0x16b returned 0 after=
 976 usecs
> [    0.327004] calling  bdi_class_init+0x0/0x68 @ 1
> [    0.329192] initcall bdi_class_init+0x0/0x68 returned 0 after 976 =
usecs
> [    0.330007] calling  kobject_uevent_init+0x0/0x7b @ 1
> [    0.331021] initcall kobject_uevent_init+0x0/0x7b returned 0 after=
 0 usecs
> [    0.332002] calling  gpiolib_sysfs_init+0x0/0xbc @ 1
> [    0.333126] initcall gpiolib_sysfs_init+0x0/0xbc returned 0 after =
0 usecs
> [    0.334003] calling  pcibus_class_init+0x0/0x40 @ 1
> [    0.335122] initcall pcibus_class_init+0x0/0x40 returned 0 after 0=
 usecs
> [    0.336003] calling  pci_driver_init+0x0/0x39 @ 1
> [    0.337110] initcall pci_driver_init+0x0/0x39 returned 0 after 0 u=
secs
> [    0.338003] calling  lcd_class_init+0x0/0x74 @ 1
> [    0.339125] initcall lcd_class_init+0x0/0x74 returned 0 after 0 us=
ecs
> [    0.340004] calling  backlight_class_init+0x0/0x84 @ 1
> [    0.341111] initcall backlight_class_init+0x0/0x84 returned 0 afte=
r 0 usecs
> [    0.342003] calling  xenbus_probe_init+0x0/0xe4 @ 1
> [    0.343003] initcall xenbus_probe_init+0x0/0xe4 returned -19 after=
 0 usecs
> [    0.344003] calling  tty_class_init+0x0/0x58 @ 1
> [    0.346102] initcall tty_class_init+0x0/0x58 returned 0 after 976 =
usecs
> [    0.347003] calling  vtconsole_class_init+0x0/0xe8 @ 1
> [    0.349325] initcall vtconsole_class_init+0x0/0xe8 returned 0 afte=
r 976 usecs
> [    0.350005] calling  register_node_type+0x0/0xa4 @ 1
> [    0.351106] initcall register_node_type+0x0/0xa4 returned 0 after =
0 usecs
> [    0.352004] calling  spi_init+0x0/0xa9 @ 1
> [    0.353145] initcall spi_init+0x0/0xa9 returned 0 after 0 usecs
> [    0.354004] calling  i2c_init+0x0/0x8c @ 1
> [    0.356165] i2c-core: driver [dummy] registered
> [    0.357005] initcall i2c_init+0x0/0x8c returned 0 after 1953 usecs
> [    0.358003] calling  amd_postcore_init+0x0/0xa3 @ 1
> [    0.359006] node 0 link 0: io port [1000, fffff]
> [    0.360003] TOM: 0000000040000000 aka 1024M
> [    0.361003] node 0 link 0: mmio [e0000000, efffffff]
> [    0.362198] node 0 link 0: mmio [feb00000, fec0ffff]
> [    0.363198] node 0 link 0: mmio [a0000, bffff]
> [    0.364197] node 0 link 0: mmio [40000000, fed3ffff]
> [    0.365197] bus: [00,ff] on node 0 link 0
> [    0.366002] bus: 00 index 0 io port: [0, ffff]
> [    0.367002] bus: 00 index 1 mmio: [40000000, fcffffffff]
> [    0.368002] bus: 00 index 2 mmio: [feb00000, fec0ffff]
> [    0.369002] bus: 00 index 3 mmio: [a0000, bffff]
> [    0.370003] initcall amd_postcore_init+0x0/0xa3 returned 0 after 1=
0742 usecs
> [    0.371004] calling  arch_kdebugfs_init+0x0/0x55 @ 1
> [    0.372042] initcall arch_kdebugfs_init+0x0/0x55 returned 0 after =
0 usecs
> [    0.373003] calling  mtrr_if_init+0x0/0x8a @ 1
> [    0.374014] initcall mtrr_if_init+0x0/0x8a returned 0 after 0 usec=
s
> [    0.375003] calling  setup_vcpu_hotplug_event+0x0/0x49 @ 1
> [    0.376003] initcall setup_vcpu_hotplug_event+0x0/0x49 returned -1=
9 after 0 usecs
> [    0.377004] calling  dmi_id_init+0x0/0xcc @ 1
> [    0.379279] initcall dmi_id_init+0x0/0xcc returned 0 after 976 use=
cs
> [    0.380010] calling  dma_bus_init+0x0/0x66 @ 1
> [    0.381111] initcall dma_bus_init+0x0/0x66 returned 0 after 0 usec=
s
> [    0.382004] calling  dma_channel_table_init+0x0/0x137 @ 1
> [    0.384009] initcall dma_channel_table_init+0x0/0x137 returned 0 a=
fter 976 usecs
> [    0.385003] calling  dca_init+0x0/0x45 @ 1
> [    0.386002] dca service started, version 1.8
> [    0.387113] initcall dca_init+0x0/0x45 returned 0 after 976 usecs
> [    0.388004] calling  pci_arch_init+0x0/0x67 @ 1
> [    0.389008] PCI: Using configuration type 1 for base access
> [    0.390010] initcall pci_arch_init+0x0/0x67 returned 0 after 976 u=
secs
> [    0.391003] calling  topology_init+0x0/0xc2 @ 1
> [    0.392193] initcall topology_init+0x0/0xc2 returned 0 after 0 use=
cs
> [    0.393004] calling  mtrr_init_finialize+0x0/0x64 @ 1
> [    0.394003] initcall mtrr_init_finialize+0x0/0x64 returned 0 after=
 0 usecs
> [    0.395003] calling  param_sysfs_init+0x0/0xf5 @ 1
> [    0.543278] initcall param_sysfs_init+0x0/0xf5 returned 0 after 14=
3554 usecs
> [    0.544005] calling  pm_sysrq_init+0x0/0x40 @ 1
> [    0.546070] initcall pm_sysrq_init+0x0/0x40 returned 0 after 0 use=
cs
> [    0.547004] calling  init_slow_work+0x0/0x5f @ 1
> [    0.548004] initcall init_slow_work+0x0/0x5f returned 0 after 0 us=
ecs
> [    0.549004] calling  default_bdi_init+0x0/0x5e @ 1
> [    0.550146] initcall default_bdi_init+0x0/0x5e returned 0 after 0 =
usecs
> [    0.551004] calling  init_bio+0x0/0x102 @ 1
> [    0.552405] bio: create slab <bio-0> at 0
> [    0.553099] initcall init_bio+0x0/0x102 returned 0 after 976 usecs
> [    0.554005] calling  cryptomgr_init+0x0/0x57 @ 1
> [    0.555032] initcall cryptomgr_init+0x0/0x57 returned 0 after 0 us=
ecs
> [    0.556004] calling  blk_settings_init+0x0/0x51 @ 1
> [    0.557004] initcall blk_settings_init+0x0/0x51 returned 0 after 0=
 usecs
> [    0.558003] calling  blk_ioc_init+0x0/0x51 @ 1
> [    0.559046] initcall blk_ioc_init+0x0/0x51 returned 0 after 0 usec=
s
> [    0.560004] calling  blk_softirq_init+0x0/0x9b @ 1
> [    0.561006] initcall blk_softirq_init+0x0/0x9b returned 0 after 0 =
usecs
> [    0.562004] calling  genhd_device_init+0x0/0x8c @ 1
> [    0.564060] initcall genhd_device_init+0x0/0x8c returned 0 after 9=
76 usecs
> [    0.565040] calling  gpiolib_debugfs_init+0x0/0x4b @ 1
> [    0.566014] initcall gpiolib_debugfs_init+0x0/0x4b returned 0 afte=
r 0 usecs
> [    0.567003] calling  max7301_init+0x0/0x39 @ 1
> [    0.568128] initcall max7301_init+0x0/0x39 returned 0 after 0 usec=
s
> [    0.570014] calling  max732x_init+0x0/0x3b @ 1
> [    0.571117] i2c-core: driver [max732x] registered
> [    0.572005] initcall max732x_init+0x0/0x3b returned 0 after 976 us=
ecs
> [    0.573009] calling  mcp23s08_init+0x0/0x39 @ 1
> [    0.574127] initcall mcp23s08_init+0x0/0x39 returned 0 after 0 use=
cs
> [    0.575004] calling  gpio_twl4030_init+0x0/0x39 @ 1
> [    0.576129] initcall gpio_twl4030_init+0x0/0x39 returned 0 after 0=
 usecs
> [    0.577005] calling  pci_slot_init+0x0/0x6e @ 1
> [    0.578012] initcall pci_slot_init+0x0/0x6e returned 0 after 0 use=
cs
> [    0.579003] calling  setup_shutdown_event+0x0/0x3b @ 1
> [    0.580005] initcall setup_shutdown_event+0x0/0x3b returned 0 afte=
r 0 usecs
> [    0.581003] calling  balloon_init+0x0/0x18d @ 1
> [    0.582003] initcall balloon_init+0x0/0x18d returned -19 after 0 u=
secs
> [    0.583003] calling  misc_init+0x0/0xc5 @ 1
> [    0.585111] initcall misc_init+0x0/0xc5 returned 0 after 976 usecs
> [    0.586006] calling  cn_init+0x0/0x115 @ 1
> [    0.587051] initcall cn_init+0x0/0x115 returned 0 after 0 usecs
> [    0.588004] calling  tifm_init+0x0/0xab @ 1
> [    0.590086] initcall tifm_init+0x0/0xab returned 0 after 976 usecs
> [    0.591003] calling  tps_init+0x0/0xa4 @ 1
> [    0.592002] tps65010: version 2 May 2005
> [    0.593119] i2c-core: driver [tps65010] registered
> [    0.594126] i2c-core: driver [tps65010] unregistered
> [    0.606176] i2c-core: driver [tps65010] registered
> [    0.608159] i2c-core: driver [tps65010] unregistered
> [    0.620165] i2c-core: driver [tps65010] registered
> [    0.622152] i2c-core: driver [tps65010] unregistered
> [    0.623003] tps65010: no chip?
> [    0.624004] initcall tps_init+0x0/0xa4 returned -19 after 31250 us=
ecs
> [    0.625003] calling  twl4030_init+0x0/0x3b @ 1
> [    0.626117] i2c-core: driver [twl4030] registered
> [    0.627005] initcall twl4030_init+0x0/0x3b returned 0 after 976 us=
ecs
> [    0.628003] calling  init_scsi+0x0/0xb7 @ 1
> [    0.631116] SCSI subsystem initialized
> [    0.632006] initcall init_scsi+0x0/0xb7 returned 0 after 2929 usec=
s
> [    0.633004] calling  ata_init+0x0/0xb4 @ 1
> [    0.634104] libata version 3.00 loaded.
> [    0.635005] initcall ata_init+0x0/0xb4 returned 0 after 976 usecs
> [    0.636003] calling  phy_init+0x0/0x57 @ 1
> [    0.638079] initcall phy_init+0x0/0x57 returned 0 after 976 usecs
> [    0.639004] calling  init_pcmcia_cs+0x0/0x56 @ 1
> [    0.641099] initcall init_pcmcia_cs+0x0/0x56 returned 0 after 976 =
usecs
> [    0.642004] calling  nop_usb_xceiv_init+0x0/0x39 @ 1
> [    0.643118] initcall nop_usb_xceiv_init+0x0/0x39 returned 0 after =
0 usecs
> [    0.644004] calling  usb_init+0x0/0x184 @ 1
> [    0.646155] usbcore: registered new interface driver usbfs
> [    0.647162] usbcore: registered new interface driver hub
> [    0.649027] usbcore: registered new device driver usb
> [    0.650005] initcall usb_init+0x0/0x184 returned 0 after 4882 usec=
s
> [    0.651004] calling  serio_init+0x0/0xb2 @ 1
> [    0.652111] initcall serio_init+0x0/0xb2 returned 0 after 0 usecs
> [    0.653004] calling  gameport_init+0x0/0xb2 @ 1
> [    0.654110] initcall gameport_init+0x0/0xb2 returned 0 after 0 use=
cs
> [    0.655004] calling  input_init+0x0/0x15d @ 1
> [    0.656111] initcall input_init+0x0/0x15d returned 0 after 0 usecs
> [    0.657005] calling  init_dvbdev+0x0/0xf5 @ 1
> [    0.658115] initcall init_dvbdev+0x0/0xf5 returned 0 after 0 usecs
> [    0.659004] calling  power_supply_class_init+0x0/0x5f @ 1
> [    0.660111] initcall power_supply_class_init+0x0/0x5f returned 0 a=
fter 0 usecs
> [    0.661004] calling  thermal_init+0x0/0x7e @ 1
> [    0.663083] initcall thermal_init+0x0/0x7e returned 0 after 976 us=
ecs
> [    0.664004] calling  md_init+0x0/0xf7 @ 1
> [    0.665023] initcall md_init+0x0/0xf7 returned 0 after 0 usecs
> [    0.666003] calling  mmc_init+0x0/0x9c @ 1
> [    0.668121] initcall mmc_init+0x0/0x9c returned 0 after 976 usecs
> [    0.669004] calling  leds_init+0x0/0x67 @ 1
> [    0.670107] initcall leds_init+0x0/0x67 returned 0 after 0 usecs
> [    0.671005] calling  pci_subsys_init+0x0/0x136 @ 1
> [    0.672002] PCI: Probing PCI hardware
> [    0.673027] PCI: Probing PCI hardware (bus 00)
> [    0.675095] HPET not enabled in BIOS. You might try hpet=3Dforce b=
oot option
> [    0.677009] pci 0000:00:01.1: reg 10 io port: [0xdc00-0xdc1f]
> [    0.678013] pci 0000:00:01.1: reg 20 io port: [0x4c00-0x4c3f]
> [    0.679005] pci 0000:00:01.1: reg 24 io port: [0x4c40-0x4c7f]
> [    0.680016] pci 0000:00:01.1: PME# supported from D3hot D3cold
> [    0.681003] pci 0000:00:01.1: PME# disabled
> [    0.682043] pci 0000:00:02.0: reg 10 32bit mmio: [0xda102000-0xda1=
02fff]
> [    0.683030] pci 0000:00:02.0: supports D1 D2
> [    0.684002] pci 0000:00:02.0: PME# supported from D0 D1 D2 D3hot D=
3cold
> [    0.685003] pci 0000:00:02.0: PME# disabled
> [    0.686038] pci 0000:00:02.1: reg 10 32bit mmio: [0xfeb00000-0xfeb=
000ff]
> [    0.687035] pci 0000:00:02.1: supports D1 D2
> [    0.688002] pci 0000:00:02.1: PME# supported from D0 D1 D2 D3hot D=
3cold
> [    0.689004] pci 0000:00:02.1: PME# disabled
> [    0.691029] pci 0000:00:04.0: reg 10 io port: [0xd400-0xd4ff]
> [    0.692005] pci 0000:00:04.0: reg 14 io port: [0xd800-0xd8ff]
> [    0.693005] pci 0000:00:04.0: reg 18 32bit mmio: [0xda101000-0xda1=
01fff]
> [    0.694024] pci 0000:00:04.0: supports D1 D2
> [    0.695044] pci 0000:00:06.0: reg 20 io port: [0xf000-0xf00f]
> [    0.696081] pci 0000:00:0a.0: reg 10 32bit mmio: [0xda100000-0xda1=
00fff]
> [    0.697005] pci 0000:00:0a.0: reg 14 io port: [0xd000-0xd007]
> [    0.698027] pci 0000:00:0a.0: supports D1 D2
> [    0.699002] pci 0000:00:0a.0: PME# supported from D0 D1 D2 D3hot D=
3cold
> [    0.700003] pci 0000:00:0a.0: PME# disabled
> [    0.701058] pci 0000:00:0b.0: PME# supported from D0 D1 D2 D3hot D=
3cold
> [    0.702003] pci 0000:00:0b.0: PME# disabled
> [    0.703061] pci 0000:00:0c.0: PME# supported from D0 D1 D2 D3hot D=
3cold
> [    0.704003] pci 0000:00:0c.0: PME# disabled
> [    0.705116] pci 0000:00:0d.0: PME# supported from D0 D1 D2 D3hot D=
3cold
> [    0.706003] pci 0000:00:0d.0: PME# disabled
> [    0.707060] pci 0000:00:0e.0: PME# supported from D0 D1 D2 D3hot D=
3cold
> [    0.708007] pci 0000:00:0e.0: PME# disabled
> [    0.709240] pci 0000:05:07.0: reg 10 io port: [0xc000-0xc0ff]
> [    0.710007] pci 0000:05:07.0: reg 14 32bit mmio: [0xda000000-0xda0=
000ff]
> [    0.711037] pci 0000:05:07.0: supports D1 D2
> [    0.712002] pci 0000:05:07.0: PME# supported from D1 D2 D3hot
> [    0.713004] pci 0000:05:07.0: PME# disabled
> [    0.714044] pci 0000:00:09.0: transparent bridge
> [    0.715004] pci 0000:00:09.0: bridge io port: [0xc000-0xcfff]
> [    0.716003] pci 0000:00:09.0: bridge 32bit mmio: [0xda000000-0xda0=
fffff]
> [    0.717251] pci 0000:01:00.0: reg 10 32bit mmio: [0xd0000000-0xd7f=
fffff]
> [    0.718006] pci 0000:01:00.0: reg 14 io port: [0xb000-0xb0ff]
> [    0.719006] pci 0000:01:00.0: reg 18 32bit mmio: [0xd9000000-0xd90=
0ffff]
> [    0.720017] pci 0000:01:00.0: reg 30 32bit mmio: [0x000000-0x01fff=
f]
> [    0.721022] pci 0000:01:00.0: supports D1 D2
> [    0.722040] pci 0000:01:00.1: reg 10 32bit mmio: [0xd9010000-0xd90=
1ffff]
> [    0.723042] pci 0000:01:00.1: supports D1 D2
> [    0.724068] pci 0000:00:0e.0: bridge io port: [0xb000-0xbfff]
> [    0.725003] pci 0000:00:0e.0: bridge 32bit mmio: [0xd8000000-0xd9f=
fffff]
> [    0.726005] pci 0000:00:0e.0: bridge 64bit mmio pref: [0xd0000000-=
0xd7ffffff]
> [    0.733318] pci 0000:00:00.0: default IRQ router [10de:005e]
> [    0.734297] initcall pci_subsys_init+0x0/0x136 returned 0 after 60=
546 usecs
> [    0.735136] calling  proto_init+0x0/0x39 @ 1
> [    0.736018] initcall proto_init+0x0/0x39 returned 0 after 0 usecs
> [    0.737003] calling  net_dev_init+0x0/0x1ce @ 1
> [    0.739303] initcall net_dev_init+0x0/0x1ce returned 0 after 976 u=
secs
> [    0.740004] calling  neigh_init+0x0/0x98 @ 1
> [    0.741004] initcall neigh_init+0x0/0x98 returned 0 after 0 usecs
> [    0.742003] calling  fib_rules_init+0x0/0xcc @ 1
> [    0.743005] initcall fib_rules_init+0x0/0xcc returned 0 after 0 us=
ecs
> [    0.744003] calling  pktsched_init+0x0/0xeb @ 1
> [    0.745028] initcall pktsched_init+0x0/0xeb returned 0 after 0 use=
cs
> [    0.746003] calling  tc_filter_init+0x0/0x73 @ 1
> [    0.747003] initcall tc_filter_init+0x0/0x73 returned 0 after 0 us=
ecs
> [    0.748003] calling  tc_action_init+0x0/0x73 @ 1
> [    0.749003] initcall tc_action_init+0x0/0x73 returned 0 after 0 us=
ecs
> [    0.750003] calling  genl_init+0x0/0x100 @ 1
> [    0.755053] initcall genl_init+0x0/0x100 returned 0 after 3906 use=
cs
> [    0.756004] calling  cipso_v4_init+0x0/0xae @ 1
> [    0.757025] initcall cipso_v4_init+0x0/0xae returned 0 after 0 use=
cs
> [    0.758003] calling  wanrouter_init+0x0/0x79 @ 1
> [    0.759003] Sangoma WANPIPE Router v1.1 (c) 1995-2000 Sangoma Tech=
nologies Inc.
> [    0.760026] initcall wanrouter_init+0x0/0x79 returned 0 after 976 =
usecs
> [    0.761003] calling  irda_init+0x0/0xb8 @ 1
> [    0.762072] NET: Registered protocol family 23
> [    0.763107] initcall irda_init+0x0/0xb8 returned 0 after 976 usecs
> [    0.764003] calling  wireless_nlevent_init+0x0/0x69 @ 1
> [    0.765004] initcall wireless_nlevent_init+0x0/0x69 returned 0 aft=
er 0 usecs
> [    0.766003] calling  netlbl_init+0x0/0xa8 @ 1
> [    0.767002] NetLabel: Initializing
> [    0.768002] NetLabel:  domain hash size =3D 128
> [    0.769001] NetLabel:  protocols =3D UNLABELED CIPSOv4
> [    0.770181] NetLabel:  unlabeled traffic allowed by default
> [    0.772003] initcall netlbl_init+0x0/0xa8 returned 0 after 4882 us=
ecs
> [    0.773003] calling  rfkill_init+0x0/0x8a @ 1
> [    0.774116] initcall rfkill_init+0x0/0x8a returned 0 after 0 usecs
> [    0.775004] calling  sysctl_init+0x0/0x6f @ 1
> [    0.776005] initcall sysctl_init+0x0/0x6f returned 0 after 0 usecs
> [    0.777005] calling  xen_mc_debugfs+0x0/0x13f @ 1
> [    0.778098] initcall xen_mc_debugfs+0x0/0x13f returned 0 after 0 u=
secs
> [    0.779004] calling  xen_mmu_debugfs+0x0/0x2e5 @ 1
> [    0.781031] initcall xen_mmu_debugfs+0x0/0x2e5 returned 0 after 97=
6 usecs
> [    0.782003] calling  xen_spinlock_debugfs+0x0/0x275 @ 1
> [    0.783170] initcall xen_spinlock_debugfs+0x0/0x275 returned 0 aft=
er 0 usecs
> [    0.784004] calling  pci_iommu_init+0x0/0x54 @ 1
> [    0.846432] DMA-API: preallocated 32768 debug entries
> [    0.847002] DMA-API: debugging enabled by kernel config
> [    0.849198] initcall pci_iommu_init+0x0/0x54 returned 0 after 6250=
0 usecs
> [    0.850007] calling  print_all_ICs+0x0/0xcc @ 1
> [    0.851002]=20
> [    0.851003] printing PIC contents
> [    0.852004] ... PIC  IMR: fffa
> [    0.853000] ... PIC  IRR: 0001
> [    0.853001] ... PIC  ISR: 0001
> [    0.854003] ... PIC ELCR: 0828
> [    0.855004]=20
> [    0.855004] printing local APIC contents on CPU#0/0:
> [    0.856000] ... APIC ID:      00000000 (0)
> [    0.856000] ... APIC VERSION: 00040010
> [    0.856000] ... APIC TASKPRI: 00000000 (00)
> [    0.856000] ... APIC ARBPRI: 000000e0 (e0)
> [    0.856000] ... APIC PROCPRI: 00000000
> [    0.856000] ... APIC LDR: 01000000
> [    0.856000] ... APIC DFR: ffffffff
> [    0.856000] ... APIC SPIV: 000001ff
> [    0.856000] ... APIC ISR field:
> [    0.856000] 0123456789abcdef0123456789abcdef
> [    0.856000] 00000000000000000000000000000000
> [    0.856000] 00000000000000000000000000000000
> [    0.856000] 00000000000000000000000000000000
> [    0.856000] 00000000000000000000000000000000
> [    0.856000] 00000000000000000000000000000000
> [    0.856000] 00000000000000000000000000000000
> [    0.856000] 00000000000000000000000000000000
> [    0.856000] 00000000000000000000000000000000
> [    0.856000] ... APIC TMR field:
> [    0.856000] 0123456789abcdef0123456789abcdef
> [    0.856000] 00000000000000000000000000000000
> [    0.856000] 00000000000000000000000000000000
> [    0.856000] 00000000000000000000000000000000
> [    0.856000] 00000000000000000000000000000000
> [    0.856000] 00000000000000000000000000000000
> [    0.856000] 00000000000000000000000000000000
> [    0.856000] 00000000000000000000000000000000
> [    0.856000] 00000000000000000000000000000000
> [    0.856000] ... APIC IRR field:
> [    0.856000] 0123456789abcdef0123456789abcdef
> [    0.856000] 00000000000000000000000000000000
> [    0.856000] 00000000000000000000000000000000
> [    0.856000] 00000000000000000000000000000000
> [    0.856000] 00000000000000000000000000000000
> [    0.856000] 00000000000000000000000000000000
> [    0.856000] 00000000000000000000000000000000
> [    0.856000] 00000000000000000000000000000000
> [    0.856000] 00000000000000010000000000000000
> [    0.856000] ... APIC ESR: 00000000
> [    0.856000] ... APIC ICR: 000008fd
> [    0.856000] ... APIC ICR2: 02000000
> [    0.856000] ... APIC LVTT: 000200ef
> [    0.856000] ... APIC LVTPC: 00000400
> [    0.856000] ... APIC LVT0: 00010700
> [    0.856000] ... APIC LVT1: 00000400
> [    0.856000] ... APIC LVTERR: 000000fe
> [    0.856000] ... APIC TMICT: 00003112
> [    0.856000] ... APIC TMCCT: 00000757
> [    0.856000] ... APIC TDCR: 00000003
> [    0.856000]=20
> [    0.855999]=20
> [    0.855999] printing local APIC contents on CPU#1/1:
> [    0.856000] ... APIC ID:      01000000 (1)
> [    0.856000] ... APIC VERSION: 00040010
> [    0.856000] ... APIC TASKPRI: 00000000 (00)
> [    0.856000] ... APIC ARBPRI: 000000e0 (e0)
> [    0.856000] ... APIC PROCPRI: 00000000
> [    0.856000] ... APIC LDR: 02000000
> [    0.856000] ... APIC DFR: ffffffff
> [    0.856000] ... APIC SPIV: 000001ff
> [    0.856000] ... APIC ISR field:
> [    0.856000] 0123456789abcdef0123456789abcdef
> [    0.856000] 00000000000000000000000000000000
> [    0.856000] 00000000000000000000000000000000
> [    0.856000] 00000000000000000000000000000000
> [    0.856000] 00000000000000000000000000000000
> [    0.856000] 00000000000000000000000000000000
> [    0.856000] 00000000000000000000000000000000
> [    0.856000] 00000000000000000000000000000000
> [    0.856000] 00000000000000000000000000000000
> [    0.856000] ... APIC TMR field:
> [    0.856000] 0123456789abcdef0123456789abcdef
> [    0.856000] 00000000000000000000000000000000
> [    0.856000] 00000000000000000000000000000000
> [    0.856000] 00000000000000000000000000000000
> [    0.856000] 00000000000000000000000000000000
> [    0.856000] 00000000000000000000000000000000
> [    0.856000] 00000000000000000000000000000000
> [    0.856000] 00000000000000000000000000000000
> [    0.856000] 00000000000000000000000000000000
> [    0.856000] ... APIC IRR field:
> [    0.856000] 0123456789abcdef0123456789abcdef
> [    0.856000] 00000000000000000000000000000000
> [    0.856000] 00000000000000000000000000000000
> [    0.856000] 00000000000000000000000000000000
> [    0.856000] 00000000000000000000000000000000
> [    0.856000] 00000000000000000000000000000000
> [    0.856000] 00000000000000000000000000000000
> [    0.856000] 00000000000000000000000000000000
> [    0.856000] 00000000000000010000000000000000
> [    0.856000] ... APIC ESR: 00000000
> [    0.856000] ... APIC ICR: 000008fd
> [    0.856000] ... APIC ICR2: 01000000
> [    0.856000] ... APIC LVTT: 000200ef
> [    0.856000] ... APIC LVTPC: 00010400
> [    0.856000] ... APIC LVT0: 00010700
> [    0.856000] ... APIC LVT1: 00010400
> [    0.856000] ... APIC LVTERR: 000000fe
> [    0.856000] ... APIC TMICT: 00003112
> [    0.856000] ... APIC TMCCT: 00001784
> [    0.856000] ... APIC TDCR: 00000003
> [    0.856000]=20
> [    1.071078] number of MP IRQ sources: 17.
> [    1.072002] number of IO-APIC #2 registers: 24.
> [    1.073002] testing the IO APIC.......................
> [    1.074005]=20
> [    1.075002] IO APIC #2......
> [    1.076002] .... register #00: 00000000
> [    1.077002] .......    : physical APIC id: 00
> [    1.078002] .......    : Delivery Type: 0
> [    1.079002] .......    : LTS          : 0
> [    1.080002] .... register #01: 00170011
> [    1.081002] .......     : max redirection entries: 0017
> [    1.082002] .......     : PRQ implemented: 0
> [    1.083002] .......     : IO APIC version: 0011
> [    1.084002] .... register #02: 00000000
> [    1.085002] .......     : arbitration: 00
> [    1.086002] .... IRQ redirection table:
> [    1.087002]  NR Dst Mask Trig IRR Pol Stat Dmod Deli Vect:  =20
> [    1.088004]  00 003 0    0    0   0   0    1    1    30
> [    1.090004]  01 003 0    0    0   0   0    1    1    31
> [    1.092004]  02 000 1    0    0   0   0    0    0    00
> [    1.094004]  03 003 1    1    0   1   0    1    1    33
> [    1.096004]  04 003 0    0    0   0   0    1    1    34
> [    1.098004]  05 003 1    1    0   1   0    1    1    35
> [    1.100004]  06 003 0    0    0   0   0    1    1    36
> [    1.102004]  07 003 1    0    0   0   0    1    1    37
> [    1.104004]  08 003 0    0    0   0   0    1    1    38
> [    1.106004]  09 003 0    0    0   0   0    1    1    39
> [    1.108004]  0a 003 0    0    0   0   0    1    1    3A
> [    1.110004]  0b 003 1    1    0   1   0    1    1    3B
> [    1.112004]  0c 003 0    0    0   0   0    1    1    3C
> [    1.114004]  0d 003 0    0    0   0   0    1    1    3D
> [    1.116004]  0e 003 0    0    0   0   0    1    1    3E
> [    1.118004]  0f 003 0    0    0   0   0    1    1    3F
> [    1.120004]  10 000 1    0    0   0   0    0    0    00
> [    1.122004]  11 000 1    0    0   0   0    0    0    00
> [    1.124004]  12 000 1    0    0   0   0    0    0    00
> [    1.126004]  13 000 1    0    0   0   0    0    0    00
> [    1.128004]  14 000 1    0    0   0   0    0    0    00
> [    1.130004]  15 000 1    0    0   0   0    0    0    00
> [    1.132004]  16 000 1    0    0   0   0    0    0    00
> [    1.134004]  17 000 1    0    0   0   0    0    0    00
> [    1.136002] IRQ to pin mappings:
> [    1.137002] IRQ0 -> 0:0
> [    1.139190] IRQ1 -> 0:1
> [    1.140735] IRQ3 -> 0:3
> [    1.142199] IRQ4 -> 0:4
> [    1.143736] IRQ5 -> 0:5
> [    1.145199] IRQ6 -> 0:6
> [    1.146728] IRQ7 -> 0:7
> [    1.148199] IRQ8 -> 0:8
> [    1.149728] IRQ9 -> 0:9
> [    1.151197] IRQ10 -> 0:10
> [    1.153002] IRQ11 -> 0:11
> [    1.155199] IRQ12 -> 0:12
> [    1.157199] IRQ13 -> 0:13
> [    1.159002] IRQ14 -> 0:14
> [    1.161199] IRQ15 -> 0:15
> [    1.163594] .................................... done.
> [    1.164005] initcall print_all_ICs+0x0/0xcc returned 0 after 30566=
4 usecs
> [    1.165004] calling  hpet_late_init+0x0/0xa0 @ 1
> [    1.166004] initcall hpet_late_init+0x0/0xa0 returned -19 after 0 =
usecs
> [    1.167005] calling  clocksource_done_booting+0x0/0x37 @ 1
> [    1.168004] initcall clocksource_done_booting+0x0/0x37 returned 0 =
after 0 usecs
> [    1.169004] calling  init_pipe_fs+0x0/0x72 @ 1
> [    1.170120] initcall init_pipe_fs+0x0/0x72 returned 0 after 0 usec=
s
> [    1.171004] calling  init_mnt_writers+0x0/0xb7 @ 1
> [    1.172005] initcall init_mnt_writers+0x0/0xb7 returned 0 after 0 =
usecs
> [    1.173003] calling  eventpoll_init+0x0/0x102 @ 1
> [    1.174143] initcall eventpoll_init+0x0/0x102 returned 0 after 0 u=
secs
> [    1.175003] calling  anon_inode_init+0x0/0x147 @ 1
> [    1.176046] initcall anon_inode_init+0x0/0x147 returned 0 after 0 =
usecs
> [    1.177004] calling  fscache_init+0x0/0xd1 @ 1
> [    1.178010] Slow work thread pool: Starting up
> [    1.179082] Slow work thread pool: Ready
> [    1.180085] FS-Cache: Loaded
> [    1.181004] initcall fscache_init+0x0/0xd1 returned 0 after 2929 u=
secs
> [    1.182004] calling  cachefiles_init+0x0/0xb3 @ 1
> [    1.184232] CacheFiles: Loaded
> [    1.185005] initcall cachefiles_init+0x0/0xb3 returned 0 after 195=
3 usecs
> [    1.186004] calling  tomoyo_initerface_init+0x0/0x181 @ 1
> [    1.187166] initcall tomoyo_initerface_init+0x0/0x181 returned 0 a=
fter 0 usecs
> [    1.188004] calling  chr_dev_init+0x0/0xca @ 1
> [    1.191195] initcall chr_dev_init+0x0/0xca returned 0 after 1953 u=
secs
> [    1.192006] calling  firmware_class_init+0x0/0x9f @ 1
> [    1.193108] initcall firmware_class_init+0x0/0x9f returned 0 after=
 0 usecs
> [    1.194006] calling  cpufreq_gov_performance_init+0x0/0x39 @ 1
> [    1.195015] initcall cpufreq_gov_performance_init+0x0/0x39 returne=
d 0 after 0 usecs
> [    1.196004] calling  ssb_modinit+0x0/0x9b @ 1
> [    1.197113] initcall ssb_modinit+0x0/0x9b returned 0 after 0 usecs
> [    1.198005] calling  pcibios_assign_resources+0x0/0xb1 @ 1
> [    1.199112] pci 0000:00:09.0: PCI bridge, secondary bus 0000:05
> [    1.200004] pci 0000:00:09.0:   IO window: 0xc000-0xcfff
> [    1.201005] pci 0000:00:09.0:   MEM window: 0xda000000-0xda0fffff
> [    1.202004] pci 0000:00:09.0:   PREFETCH window: disabled
> [    1.203005] pci 0000:00:0b.0: PCI bridge, secondary bus 0000:04
> [    1.204002] pci 0000:00:0b.0:   IO window: disabled
> [    1.205004] pci 0000:00:0b.0:   MEM window: disabled
> [    1.206003] pci 0000:00:0b.0:   PREFETCH window: disabled
> [    1.207005] pci 0000:00:0c.0: PCI bridge, secondary bus 0000:03
> [    1.208002] pci 0000:00:0c.0:   IO window: disabled
> [    1.209004] pci 0000:00:0c.0:   MEM window: disabled
> [    1.210003] pci 0000:00:0c.0:   PREFETCH window: disabled
> [    1.211005] pci 0000:00:0d.0: PCI bridge, secondary bus 0000:02
> [    1.212002] pci 0000:00:0d.0:   IO window: disabled
> [    1.213004] pci 0000:00:0d.0:   MEM window: disabled
> [    1.214003] pci 0000:00:0d.0:   PREFETCH window: disabled
> [    1.215011] pci 0000:00:0e.0: PCI bridge, secondary bus 0000:01
> [    1.216003] pci 0000:00:0e.0:   IO window: 0xb000-0xbfff
> [    1.217004] pci 0000:00:0e.0:   MEM window: 0xd8000000-0xd9ffffff
> [    1.218004] pci 0000:00:0e.0:   PREFETCH window: 0x000000d0000000-=
0x000000d7ffffff
> [    1.219011] pci 0000:00:09.0: setting latency timer to 64
> [    1.220011] pci 0000:00:0b.0: setting latency timer to 64
> [    1.221007] pci 0000:00:0c.0: setting latency timer to 64
> [    1.222007] pci 0000:00:0d.0: setting latency timer to 64
> [    1.223007] pci 0000:00:0e.0: setting latency timer to 64
> [    1.224005] pci_bus 0000:00: resource 0 io:  [0x00-0xffff]
> [    1.225003] pci_bus 0000:00: resource 1 mem: [0x000000-0xfffffffff=
fffffff]
> [    1.226004] pci_bus 0000:05: resource 0 io:  [0xc000-0xcfff]
> [    1.227003] pci_bus 0000:05: resource 1 mem: [0xda000000-0xda0ffff=
f]
> [    1.228003] pci_bus 0000:05: resource 3 io:  [0x00-0xffff]
> [    1.229003] pci_bus 0000:05: resource 4 mem: [0x000000-0xfffffffff=
fffffff]
> [    1.230004] pci_bus 0000:01: resource 0 io:  [0xb000-0xbfff]
> [    1.231003] pci_bus 0000:01: resource 1 mem: [0xd8000000-0xd9fffff=
f]
> [    1.232003] pci_bus 0000:01: resource 2 pref mem [0xd0000000-0xd7f=
fffff]
> [    1.233005] initcall pcibios_assign_resources+0x0/0xb1 returned 0 =
after 33203 usecs
> [    1.234003] calling  sysctl_core_init+0x0/0x5f @ 1
> [    1.235018] initcall sysctl_core_init+0x0/0x5f returned 0 after 0 =
usecs
> [    1.236004] calling  inet_init+0x0/0x1ff @ 1
> [    1.237321] NET: Registered protocol family 2
> [    1.250338] IP route cache hash table entries: 32768 (order: 6, 26=
2144 bytes)
> [    1.253313] TCP established hash table entries: 131072 (order: 9, =
2097152 bytes)
> [    1.257438] TCP bind hash table entries: 65536 (order: 9, 3670016 =
bytes)
> [    1.261589] TCP: Hash tables configured (established 131072 bind 6=
5536)
> [    1.262042] TCP reno registered
> [    1.266280] initcall inet_init+0x0/0x1ff returned 0 after 28320 us=
ecs
> [    1.267005] calling  af_unix_init+0x0/0x7b @ 1
> [    1.268095] NET: Registered protocol family 1
> [    1.269022] initcall af_unix_init+0x0/0x7b returned 0 after 976 us=
ecs
> [    1.270006] calling  populate_rootfs+0x0/0x131 @ 1
> [    1.272491] initcall populate_rootfs+0x0/0x131 returned 0 after 97=
6 usecs
> [    1.273005] calling  calgary_fixup_tce_spaces+0x0/0x121 @ 1
> [    1.274004] initcall calgary_fixup_tce_spaces+0x0/0x121 returned -=
19 after 0 usecs
> [    1.275004] calling  i8259A_init_sysfs+0x0/0x49 @ 1
> [    1.276178] initcall i8259A_init_sysfs+0x0/0x49 returned 0 after 0=
 usecs
> [    1.277004] calling  vsyscall_init+0x0/0x6c @ 1
> [    1.278014] initcall vsyscall_init+0x0/0x6c returned 0 after 0 use=
cs
> [    1.279003] calling  sbf_init+0x0/0x118 @ 1
> [    1.280004] initcall sbf_init+0x0/0x118 returned 0 after 0 usecs
> [    1.281004] calling  i8237A_init_sysfs+0x0/0x49 @ 1
> [    1.282128] initcall i8237A_init_sysfs+0x0/0x49 returned 0 after 0=
 usecs
> [    1.283004] calling  add_rtc_cmos+0x0/0x68 @ 1
> [    1.285125] platform rtc_cmos: registered platform RTC device (no =
PNP device found)
> [    1.286005] initcall add_rtc_cmos+0x0/0x68 returned 0 after 1953 u=
secs
> [    1.287003] calling  ds_selftest+0x0/0x95 @ 1
> [    1.288004] initcall ds_selftest+0x0/0x95 returned 0 after 0 usecs
> [    1.288005] Clocksource tsc unstable (delta =3D 841293790 ns)
> [    1.289005] calling  cache_sysfs_init+0x0/0x8d @ 1
> [    1.291999] initcall cache_sysfs_init+0x0/0x8d returned 0 after 97=
6 usecs
> [    1.292005] calling  cpu_debug_init+0x0/0x4c @ 1
> [    1.295840] cpu0(2) debug files 130
> [    1.298920] cpu1(2) debug files 130
> [    1.299008] initcall cpu_debug_init+0x0/0x4c returned 0 after 5859=
 usecs
> [    1.300005] calling  mce_init_device+0x0/0xda @ 1
> [    1.302238] initcall mce_init_device+0x0/0xda returned 0 after 976=
 usecs
> [    1.303005] calling  thermal_throttle_init_device+0x0/0xbe @ 1
> [    1.304004] initcall thermal_throttle_init_device+0x0/0xbe returne=
d 0 after 0 usecs
> [    1.305004] calling  msr_init+0x0/0x160 @ 1
> [    1.306132] initcall msr_init+0x0/0x160 returned 0 after 0 usecs
> [    1.307004] calling  cpuid_init+0x0/0x160 @ 1
> [    1.309239] initcall cpuid_init+0x0/0x160 returned 0 after 976 use=
cs
> [    1.310116] calling  ioapic_init_sysfs+0x0/0xd2 @ 1
> [    1.312024] initcall ioapic_init_sysfs+0x0/0xd2 returned 0 after 9=
76 usecs
> [    1.313024] calling  add_pcspkr+0x0/0x4f @ 1
> [    1.314096] initcall add_pcspkr+0x0/0x4f returned 0 after 0 usecs
> [    1.315005] calling  microcode_init+0x0/0x140 @ 1
> [    1.316015] microcode: no support for this CPU vendor
> [    1.317004] initcall microcode_init+0x0/0x140 returned -19 after 9=
76 usecs
> [    1.318006] calling  start_pageattr_test+0x0/0x67 @ 1
> [    1.319068] initcall start_pageattr_test+0x0/0x67 returned 0 after=
 0 usecs
> [    1.320005] calling  pt_dump_init+0x0/0x52 @ 1
> [    1.321022] initcall pt_dump_init+0x0/0x52 returned 0 after 0 usec=
s
> [    1.322004] calling  aes_init+0x0/0x39 @ 1
> [    1.323135] initcall aes_init+0x0/0x39 returned 0 after 0 usecs
> [    1.324004] calling  init+0x0/0x39 @ 1
> [    1.325060] initcall init+0x0/0x39 returned 0 after 0 usecs
> [    1.326004] calling  aesni_init+0x0/0xde @ 1
> [    1.327002] Intel AES-NI instructions are not detected.
> [    1.328004] initcall aesni_init+0x0/0xde returned -19 after 976 us=
ecs
> [    1.329003] calling  init_vdso_vars+0x0/0x272 @ 1
> [    1.330021] initcall init_vdso_vars+0x0/0x272 returned 0 after 0 u=
secs
> [    1.331004] calling  ia32_binfmt_init+0x0/0x3b @ 1
> [    1.332009] initcall ia32_binfmt_init+0x0/0x3b returned 0 after 0 =
usecs
> [    1.333003] calling  sysenter_setup+0x0/0xfb @ 1
> [    1.334011] initcall sysenter_setup+0x0/0xfb returned 0 after 0 us=
ecs
> [    1.335004] calling  proc_execdomains_init+0x0/0x49 @ 1
> [    1.336018] initcall proc_execdomains_init+0x0/0x49 returned 0 aft=
er 0 usecs
> [    1.337004] calling  ioresources_init+0x0/0x63 @ 1
> [    1.338019] initcall ioresources_init+0x0/0x63 returned 0 after 0 =
usecs
> [    1.339004] calling  uid_cache_init+0x0/0xb4 @ 1
> [    1.340068] initcall uid_cache_init+0x0/0xb4 returned 0 after 0 us=
ecs
> [    1.341004] calling  init_posix_timers+0x0/0x103 @ 1
> [    1.342053] initcall init_posix_timers+0x0/0x103 returned 0 after =
0 usecs
> [    1.343004] calling  init_posix_cpu_timers+0x0/0xd6 @ 1
> [    1.344004] initcall init_posix_cpu_timers+0x0/0xd6 returned 0 aft=
er 0 usecs
> [    1.345003] calling  nsproxy_cache_init+0x0/0x54 @ 1
> [    1.346092] initcall nsproxy_cache_init+0x0/0x54 returned 0 after =
0 usecs
> [    1.347006] calling  create_proc_profile+0x0/0x8c @ 1
> [    1.348005] initcall create_proc_profile+0x0/0x8c returned 0 after=
 0 usecs
> [    1.349003] calling  timekeeping_init_device+0x0/0x49 @ 1
> [    1.350118] initcall timekeeping_init_device+0x0/0x49 returned 0 a=
fter 0 usecs
> [    1.351004] calling  init_clocksource_sysfs+0x0/0x77 @ 1
> [    1.352118] initcall init_clocksource_sysfs+0x0/0x77 returned 0 af=
ter 0 usecs
> [    1.353005] calling  init_timer_list_procfs+0x0/0x53 @ 1
> [    1.354013] initcall init_timer_list_procfs+0x0/0x53 returned 0 af=
ter 0 usecs
> [    1.355003] calling  lockdep_proc_init+0x0/0x69 @ 1
> [    1.356019] initcall lockdep_proc_init+0x0/0x69 returned 0 after 0=
 usecs
> [    1.357003] calling  futex_init+0x0/0xac @ 1
> [    1.358024] initcall futex_init+0x0/0xac returned 0 after 0 usecs
> [    1.359005] calling  init_rttest+0x0/0x17f @ 1
> [    1.363142] Initializing RT-Tester: OK
> [    1.364006] initcall init_rttest+0x0/0x17f returned 0 after 3906 u=
secs
> [    1.365005] calling  proc_dma_init+0x0/0x49 @ 1
> [    1.366015] initcall proc_dma_init+0x0/0x49 returned 0 after 0 use=
cs
> [    1.367004] calling  kallsyms_init+0x0/0x4c @ 1
> [    1.368011] initcall kallsyms_init+0x0/0x4c returned 0 after 0 use=
cs
> [    1.369004] calling  crash_save_vmcoreinfo_init+0x0/0x492 @ 1
> [    1.371005] initcall crash_save_vmcoreinfo_init+0x0/0x492 returned=
 0 after 976 usecs
> [    1.372004] calling  crash_notes_memory_init+0x0/0x5f @ 1
> [    1.373010] initcall crash_notes_memory_init+0x0/0x5f returned 0 a=
fter 0 usecs
> [    1.374004] calling  pid_namespaces_init+0x0/0x54 @ 1
> [    1.375057] initcall pid_namespaces_init+0x0/0x54 returned 0 after=
 0 usecs
> [    1.376004] calling  rcu_torture_init+0x0/0x6fb @ 1
> [    1.377033] rcu-torture:--- Start of test: nreaders=3D4 nfakewrite=
rs=3D4 stat_interval=3D0 verbose=3D0 test_no_idle_hz=3D0 shuffle_interv=
al=3D3 stutter=3D5 irqreader=3D1
> [    1.379108] initcall rcu_torture_init+0x0/0x6fb returned 0 after 1=
953 usecs
> [    1.380094] calling  utsname_sysctl_init+0x0/0x3b @ 1
> [    1.381010] initcall utsname_sysctl_init+0x0/0x3b returned 0 after=
 0 usecs
> [    1.382004] calling  perf_counter_sysfs_init+0x0/0x40 @ 1
> [    1.383017] initcall perf_counter_sysfs_init+0x0/0x40 returned 0 a=
fter 0 usecs
> [    1.384004] calling  init_per_zone_pages_min+0x0/0xb2 @ 1
> [    1.385112] initcall init_per_zone_pages_min+0x0/0xb2 returned 0 a=
fter 0 usecs
> [    1.386004] calling  pdflush_init+0x0/0x43 @ 1
> [    1.387053] initcall pdflush_init+0x0/0x43 returned 0 after 0 usec=
s
> [    1.388005] calling  kswapd_init+0x0/0xa1 @ 1
> [    1.389049] initcall kswapd_init+0x0/0xa1 returned 0 after 0 usecs
> [    1.390005] calling  init_tmpfs+0x0/0x105 @ 1
> [    1.392064] initcall init_tmpfs+0x0/0x105 returned 0 after 976 use=
cs
> [    1.393004] calling  setup_vmstat+0x0/0xf0 @ 1
> [    1.394047] initcall setup_vmstat+0x0/0xf0 returned 0 after 0 usec=
s
> [    1.395004] calling  mm_sysfs_init+0x0/0x50 @ 1
> [    1.396015] initcall mm_sysfs_init+0x0/0x50 returned 0 after 0 use=
cs
> [    1.397004] calling  proc_vmalloc_init+0x0/0x4c @ 1
> [    1.398022] initcall proc_vmalloc_init+0x0/0x4c returned 0 after 0=
 usecs
> [    1.399005] calling  hugetlb_init+0x0/0x230 @ 1
> [    1.400009] HugeTLB registered 2 MB page size, pre-allocated 0 pag=
es
> [    1.401030] initcall hugetlb_init+0x0/0x230 returned 0 after 976 u=
secs
> [    1.402003] calling  slab_proc_init+0x0/0x4c @ 1
> [    1.403012] initcall slab_proc_init+0x0/0x4c returned 0 after 0 us=
ecs
> [    1.404003] calling  slab_sysfs_init+0x0/0x11b @ 1
> [    1.434340] initcall slab_sysfs_init+0x0/0x11b returned 0 after 28=
320 usecs
> [    1.435005] calling  fasync_init+0x0/0x51 @ 1
> [    1.436330] initcall fasync_init+0x0/0x51 returned 0 after 0 usecs
> [    1.437004] calling  proc_filesystems_init+0x0/0x49 @ 1
> [    1.438094] initcall proc_filesystems_init+0x0/0x49 returned 0 aft=
er 0 usecs
> [    1.439004] calling  inotify_setup+0x0/0x37 @ 1
> [    1.440004] initcall inotify_setup+0x0/0x37 returned 0 after 0 use=
cs
> [    1.441003] calling  aio_setup+0x0/0x9c @ 1
> [    1.443152] initcall aio_setup+0x0/0x9c returned 0 after 976 usecs
> [    1.444017] calling  proc_locks_init+0x0/0x49 @ 1
> [    1.445014] initcall proc_locks_init+0x0/0x49 returned 0 after 0 u=
secs
> [    1.446004] calling  init_sys32_ioctl+0x0/0xac @ 1
> [    1.447020] initcall init_sys32_ioctl+0x0/0xac returned 0 after 0 =
usecs
> [    1.448003] calling  init_mbcache+0x0/0x3b @ 1
> [    1.449005] initcall init_mbcache+0x0/0x3b returned 0 after 0 usec=
s
> [    1.450003] calling  dquot_init+0x0/0x12a @ 1
> [    1.451003] VFS: Disk quotas dquot_6.5.2
> [    1.452291] Dquot-cache hash table entries: 512 (order 0, 4096 byt=
es)
> [    1.453057] initcall dquot_init+0x0/0x12a returned 0 after 1953 us=
ecs
> [    1.454018] calling  init_v1_quota_format+0x0/0x39 @ 1
> [    1.455005] initcall init_v1_quota_format+0x0/0x39 returned 0 afte=
r 0 usecs
> [    1.456003] calling  init_v2_quota_format+0x0/0x39 @ 1
> [    1.457004] initcall init_v2_quota_format+0x0/0x39 returned 0 afte=
r 0 usecs
> [    1.458004] calling  proc_cmdline_init+0x0/0x49 @ 1
> [    1.459014] initcall proc_cmdline_init+0x0/0x49 returned 0 after 0=
 usecs
> [    1.460003] calling  proc_cpuinfo_init+0x0/0x49 @ 1
> [    1.461012] initcall proc_cpuinfo_init+0x0/0x49 returned 0 after 0=
 usecs
> [    1.462004] calling  proc_devices_init+0x0/0x49 @ 1
> [    1.463011] initcall proc_devices_init+0x0/0x49 returned 0 after 0=
 usecs
> [    1.464003] calling  proc_interrupts_init+0x0/0x49 @ 1
> [    1.465012] initcall proc_interrupts_init+0x0/0x49 returned 0 afte=
r 0 usecs
> [    1.466003] calling  proc_loadavg_init+0x0/0x49 @ 1
> [    1.467011] initcall proc_loadavg_init+0x0/0x49 returned 0 after 0=
 usecs
> [    1.468003] calling  proc_meminfo_init+0x0/0x49 @ 1
> [    1.469012] initcall proc_meminfo_init+0x0/0x49 returned 0 after 0=
 usecs
> [    1.470003] calling  proc_stat_init+0x0/0x49 @ 1
> [    1.471012] initcall proc_stat_init+0x0/0x49 returned 0 after 0 us=
ecs
> [    1.472003] calling  proc_uptime_init+0x0/0x49 @ 1
> [    1.473012] initcall proc_uptime_init+0x0/0x49 returned 0 after 0 =
usecs
> [    1.474004] calling  proc_version_init+0x0/0x49 @ 1
> [    1.475023] initcall proc_version_init+0x0/0x49 returned 0 after 0=
 usecs
> [    1.476007] calling  proc_kcore_init+0x0/0x70 @ 1
> [    1.477012] initcall proc_kcore_init+0x0/0x70 returned 0 after 0 u=
secs
> [    1.478003] calling  vmcore_init+0x0/0x9e @ 1
> [    1.479004] initcall vmcore_init+0x0/0x9e returned 0 after 0 usecs
> [    1.480003] calling  proc_kmsg_init+0x0/0x4c @ 1
> [    1.481012] initcall proc_kmsg_init+0x0/0x4c returned 0 after 0 us=
ecs
> [    1.482004] calling  proc_page_init+0x0/0x69 @ 1
> [    1.483019] initcall proc_page_init+0x0/0x69 returned 0 after 0 us=
ecs
> [    1.484003] calling  configfs_init+0x0/0xfb @ 1
> [    1.485233] initcall configfs_init+0x0/0xfb returned 0 after 0 use=
cs
> [    1.486004] calling  init_devpts_fs+0x0/0x65 @ 1
> [    1.487104] initcall init_devpts_fs+0x0/0x65 returned 0 after 0 us=
ecs
> [    1.488004] calling  init_dlm+0x0/0xbe @ 1
> [    1.490158] DLM (built Jun  7 2009 11:52:11) installed
> [    1.491007] initcall init_dlm+0x0/0xbe returned 0 after 1953 usecs
> [    1.492004] calling  init_ext3_fs+0x0/0x99 @ 1
> [    1.494204] initcall init_ext3_fs+0x0/0x99 returned 0 after 976 us=
ecs
> [    1.495004] calling  init_ext2_fs+0x0/0x89 @ 1
> [    1.496228] initcall init_ext2_fs+0x0/0x89 returned 0 after 0 usec=
s
> [    1.497004] calling  init_ext4_fs+0x0/0x106 @ 1
> [    1.500222] initcall init_ext4_fs+0x0/0x106 returned 0 after 1953 =
usecs
> [    1.501005] calling  journal_init+0x0/0xf5 @ 1
> [    1.504102] initcall journal_init+0x0/0xf5 returned 0 after 1953 u=
secs
> [    1.505004] calling  journal_init+0x0/0x112 @ 1
> [    1.507301] initcall journal_init+0x0/0x112 returned 0 after 976 u=
secs
> [    1.508004] calling  init_ramfs_fs+0x0/0x39 @ 1
> [    1.509006] initcall init_ramfs_fs+0x0/0x39 returned 0 after 0 use=
cs
> [    1.510003] calling  init_hugetlbfs_fs+0x0/0xbe @ 1
> [    1.511243] initcall init_hugetlbfs_fs+0x0/0xbe returned 0 after 0=
 usecs
> [    1.512005] calling  init_fat_fs+0x0/0x75 @ 1
> [    1.514483] initcall init_fat_fs+0x0/0x75 returned 0 after 976 use=
cs
> [    1.515005] calling  init_vfat_fs+0x0/0x39 @ 1
> [    1.516006] initcall init_vfat_fs+0x0/0x39 returned 0 after 0 usec=
s
> [    1.517004] calling  init_nfsd+0x0/0x109 @ 1
> [    1.518003] Installing knfsd (copyright (C) 1996 okir@monad.swb.de=
).
> [    1.522403] initcall init_nfsd+0x0/0x109 returned 0 after 3906 use=
cs
> [    1.523005] calling  init_nlm+0x0/0x49 @ 1
> [    1.524022] initcall init_nlm+0x0/0x49 returned 0 after 0 usecs
> [    1.525004] calling  init_nls_cp737+0x0/0x39 @ 1
> [    1.526012] initcall init_nls_cp737+0x0/0x39 returned 0 after 0 us=
ecs
> [    1.527004] calling  init_nls_cp852+0x0/0x39 @ 1
> [    1.528004] initcall init_nls_cp852+0x0/0x39 returned 0 after 0 us=
ecs
> [    1.529004] calling  init_nls_cp857+0x0/0x39 @ 1
> [    1.530004] initcall init_nls_cp857+0x0/0x39 returned 0 after 0 us=
ecs
> [    1.531004] calling  init_nls_cp860+0x0/0x39 @ 1
> [    1.532004] initcall init_nls_cp860+0x0/0x39 returned 0 after 0 us=
ecs
> [    1.533004] calling  init_nls_cp861+0x0/0x39 @ 1
> [    1.534004] initcall init_nls_cp861+0x0/0x39 returned 0 after 0 us=
ecs
> [    1.535004] calling  init_nls_cp863+0x0/0x39 @ 1
> [    1.536004] initcall init_nls_cp863+0x0/0x39 returned 0 after 0 us=
ecs
> [    1.537004] calling  init_nls_cp864+0x0/0x39 @ 1
> [    1.538004] initcall init_nls_cp864+0x0/0x39 returned 0 after 0 us=
ecs
> [    1.539004] calling  init_nls_cp865+0x0/0x39 @ 1
> [    1.540004] initcall init_nls_cp865+0x0/0x39 returned 0 after 0 us=
ecs
> [    1.541004] calling  init_nls_cp869+0x0/0x39 @ 1
> [    1.542004] initcall init_nls_cp869+0x0/0x39 returned 0 after 0 us=
ecs
> [    1.543004] calling  init_nls_cp874+0x0/0x39 @ 1
> [    1.544004] initcall init_nls_cp874+0x0/0x39 returned 0 after 0 us=
ecs
> [    1.545004] calling  init_nls_cp932+0x0/0x39 @ 1
> [    1.546004] initcall init_nls_cp932+0x0/0x39 returned 0 after 0 us=
ecs
> [    1.547004] calling  init_nls_euc_jp+0x0/0x6f @ 1
> [    1.548005] initcall init_nls_euc_jp+0x0/0x6f returned 0 after 0 u=
secs
> [    1.549004] calling  init_nls_cp936+0x0/0x39 @ 1
> [    1.550004] initcall init_nls_cp936+0x0/0x39 returned 0 after 0 us=
ecs
> [    1.551004] calling  init_nls_cp949+0x0/0x39 @ 1
> [    1.552004] initcall init_nls_cp949+0x0/0x39 returned 0 after 0 us=
ecs
> [    1.553004] calling  init_nls_cp950+0x0/0x39 @ 1
> [    1.554004] initcall init_nls_cp950+0x0/0x39 returned 0 after 0 us=
ecs
> [    1.555004] calling  init_nls_iso8859_1+0x0/0x39 @ 1
> [    1.556004] initcall init_nls_iso8859_1+0x0/0x39 returned 0 after =
0 usecs
> [    1.557004] calling  init_nls_iso8859_4+0x0/0x39 @ 1
> [    1.558004] initcall init_nls_iso8859_4+0x0/0x39 returned 0 after =
0 usecs
> [    1.559004] calling  init_nls_iso8859_5+0x0/0x39 @ 1
> [    1.560004] initcall init_nls_iso8859_5+0x0/0x39 returned 0 after =
0 usecs
> [    1.561004] calling  init_nls_iso8859_6+0x0/0x39 @ 1
> [    1.562004] initcall init_nls_iso8859_6+0x0/0x39 returned 0 after =
0 usecs
> [    1.563004] calling  init_nls_koi8_r+0x0/0x39 @ 1
> [    1.564004] initcall init_nls_koi8_r+0x0/0x39 returned 0 after 0 u=
secs
> [    1.565004] calling  init_nls_utf8+0x0/0x4a @ 1
> [    1.566005] initcall init_nls_utf8+0x0/0x4a returned 0 after 0 use=
cs
> [    1.567004] calling  init_smb_fs+0x0/0x99 @ 1
> [    1.569265] initcall init_smb_fs+0x0/0x99 returned 0 after 976 use=
cs
> [    1.570044] calling  init_cifs+0x0/0x345 @ 1
> [    1.574411] initcall init_cifs+0x0/0x345 returned 0 after 2929 use=
cs
> [    1.575005] calling  init_ntfs_fs+0x0/0x253 @ 1
> [    1.576011] NTFS driver 2.1.29 [Flags: R/W DEBUG].
> [    1.579307] initcall init_ntfs_fs+0x0/0x253 returned 0 after 2929 =
usecs
> [    1.580005] calling  init_autofs_fs+0x0/0x39 @ 1
> [    1.581007] initcall init_autofs_fs+0x0/0x39 returned 0 after 0 us=
ecs
> [    1.582004] calling  init_autofs4_fs+0x0/0x4c @ 1
> [    1.583008] initcall init_autofs4_fs+0x0/0x4c returned -16 after 0=
 usecs
> [    1.584005] initcall init_autofs4_fs+0x0/0x4c returned with error =
code -16=20
> [    1.585004] calling  fuse_init+0x0/0x15c @ 1
> [    1.586003] fuse init (API version 7.11)
> [    1.588305] initcall fuse_init+0x0/0x15c returned 0 after 1953 use=
cs
> [    1.589023] calling  init_xfs_fs+0x0/0xcd @ 1
> [    1.590003] SGI XFS with ACLs, security attributes, realtime, larg=
e block/inode numbers, no debug enabled
> [    1.598189] SGI XFS Quota Management subsystem
> [    1.599048] initcall init_xfs_fs+0x0/0xcd returned 0 after 8789 us=
ecs
> [    1.600004] calling  ocfs2_init+0x0/0x352 @ 1
> [    1.601003] OCFS2 1.5.0
> [    1.604384] initcall ocfs2_init+0x0/0x352 returned 0 after 2929 us=
ecs
> [    1.605006] calling  ocfs2_stack_glue_init+0x0/0xbb @ 1
> [    1.606046] initcall ocfs2_stack_glue_init+0x0/0xbb returned 0 aft=
er 0 usecs
> [    1.607004] calling  o2cb_stack_init+0x0/0x39 @ 1
> [    1.608003] ocfs2: Registered cluster interface o2cb
> [    1.609005] initcall o2cb_stack_init+0x0/0x39 returned 0 after 976=
 usecs
> [    1.610004] calling  ocfs2_user_plugin_init+0x0/0x7c @ 1
> [    1.612215] ocfs2: Registered cluster interface user
> [    1.613026] initcall ocfs2_user_plugin_init+0x0/0x7c returned 0 af=
ter 1953 usecs
> [    1.614004] calling  init_o2nm+0x0/0xcf @ 1
> [    1.615003] OCFS2 Node Manager 1.5.0
> [    1.618069] initcall init_o2nm+0x0/0xcf returned 0 after 2929 usec=
s
> [    1.619004] calling  dlm_init+0x0/0x356 @ 1
> [    1.620003] OCFS2 DLM 1.5.0
> [    1.623051] initcall dlm_init+0x0/0x356 returned 0 after 2929 usec=
s
> [    1.624004] calling  init_dlmfs_fs+0x0/0x106 @ 1
> [    1.625003] OCFS2 DLMFS 1.5.0
> [    1.627275] OCFS2 User DLM kernel interface loaded
> [    1.628006] initcall init_dlmfs_fs+0x0/0x106 returned 0 after 2929=
 usecs
> [    1.629004] calling  init_btrfs_fs+0x0/0xb5 @ 1
> [    1.633297] Btrfs loaded
> [    1.634006] initcall init_btrfs_fs+0x0/0xb5 returned 0 after 3906 =
usecs
> [    1.635004] calling  init_gfs2_fs+0x0/0x1f3 @ 1
> [    1.638290] GFS2 (built Jun  7 2009 11:52:22) installed
> [    1.639009] initcall init_gfs2_fs+0x0/0x1f3 returned 0 after 2929 =
usecs
> [    1.640079] calling  ipc_init+0x0/0x56 @ 1
> [    1.641024] msgmni has been set to 1778
> [    1.642023] initcall ipc_init+0x0/0x56 returned 0 after 976 usecs
> [    1.643004] calling  ipc_sysctl_init+0x0/0x3b @ 1
> [    1.644013] initcall ipc_sysctl_init+0x0/0x3b returned 0 after 0 u=
secs
> [    1.645004] calling  key_proc_init+0x0/0x5a @ 1
> [    1.646013] initcall key_proc_init+0x0/0x5a returned 0 after 0 use=
cs
> [    1.647004] calling  crypto_wq_init+0x0/0x59 @ 1
> [    1.648068] initcall crypto_wq_init+0x0/0x59 returned 0 after 0 us=
ecs
> [    1.649005] calling  crypto_algapi_init+0x0/0x34 @ 1
> [    1.650095] initcall crypto_algapi_init+0x0/0x34 returned 0 after =
0 usecs
> [    1.651005] calling  chainiv_module_init+0x0/0x39 @ 1
> [    1.652008] initcall chainiv_module_init+0x0/0x39 returned 0 after=
 0 usecs
> [    1.653004] calling  eseqiv_module_init+0x0/0x39 @ 1
> [    1.654006] initcall eseqiv_module_init+0x0/0x39 returned 0 after =
0 usecs
> [    1.655004] calling  seqiv_module_init+0x0/0x39 @ 1
> [    1.656006] initcall seqiv_module_init+0x0/0x39 returned 0 after 0=
 usecs
> [    1.657004] calling  hmac_module_init+0x0/0x39 @ 1
> [    1.658006] initcall hmac_module_init+0x0/0x39 returned 0 after 0 =
usecs
> [    1.659004] calling  crypto_xcbc_module_init+0x0/0x39 @ 1
> [    1.660006] initcall crypto_xcbc_module_init+0x0/0x39 returned 0 a=
fter 0 usecs
> [    1.661004] calling  crypto_null_mod_init+0x0/0xa5 @ 1
> [    1.662059] alg: No test for cipher_null (cipher_null-generic)
> [    1.668481] alg: No test for ecb(cipher_null) (ecb-cipher_null)
> [    1.669094] alg: No test for digest_null (digest_null-generic)
> [    1.675427] alg: No test for compress_null (compress_null-generic)
> [    1.676032] initcall crypto_null_mod_init+0x0/0xa5 returned 0 afte=
r 13671 usecs
> [    1.677005] calling  md4_mod_init+0x0/0x39 @ 1
> [    1.678085] initcall md4_mod_init+0x0/0x39 returned 0 after 0 usec=
s
> [    1.679005] calling  md5_mod_init+0x0/0x39 @ 1
> [    1.680057] initcall md5_mod_init+0x0/0x39 returned 0 after 0 usec=
s
> [    1.681005] calling  rmd128_mod_init+0x0/0x39 @ 1
> [    1.682067] initcall rmd128_mod_init+0x0/0x39 returned 0 after 0 u=
secs
> [    1.683005] calling  rmd160_mod_init+0x0/0x39 @ 1
> [    1.684061] initcall rmd160_mod_init+0x0/0x39 returned 0 after 0 u=
secs
> [    1.685005] calling  rmd320_mod_init+0x0/0x39 @ 1
> [    1.686061] initcall rmd320_mod_init+0x0/0x39 returned 0 after 0 u=
secs
> [    1.687005] calling  sha1_generic_mod_init+0x0/0x39 @ 1
> [    1.688060] initcall sha1_generic_mod_init+0x0/0x39 returned 0 aft=
er 0 usecs
> [    1.689005] calling  sha256_generic_mod_init+0x0/0x65 @ 1
> [    1.690061] initcall sha256_generic_mod_init+0x0/0x65 returned 0 a=
fter 0 usecs
> [    1.691005] calling  wp512_mod_init+0x0/0x8a @ 1
> [    1.692100] initcall wp512_mod_init+0x0/0x8a returned 0 after 0 us=
ecs
> [    1.693005] calling  tgr192_mod_init+0x0/0x8a @ 1
> [    1.694060] initcall tgr192_mod_init+0x0/0x8a returned 0 after 0 u=
secs
> [    1.695005] calling  crypto_ecb_module_init+0x0/0x39 @ 1
> [    1.696006] initcall crypto_ecb_module_init+0x0/0x39 returned 0 af=
ter 0 usecs
> [    1.697004] calling  crypto_cbc_module_init+0x0/0x39 @ 1
> [    1.698006] initcall crypto_cbc_module_init+0x0/0x39 returned 0 af=
ter 0 usecs
> [    1.699004] calling  crypto_pcbc_module_init+0x0/0x39 @ 1
> [    1.700006] initcall crypto_pcbc_module_init+0x0/0x39 returned 0 a=
fter 0 usecs
> [    1.701004] calling  crypto_cts_module_init+0x0/0x39 @ 1
> [    1.702006] initcall crypto_cts_module_init+0x0/0x39 returned 0 af=
ter 0 usecs
> [    1.703004] calling  crypto_module_init+0x0/0x39 @ 1
> [    1.704006] initcall crypto_module_init+0x0/0x39 returned 0 after =
0 usecs
> [    1.705004] calling  crypto_module_init+0x0/0x39 @ 1
> [    1.706006] initcall crypto_module_init+0x0/0x39 returned 0 after =
0 usecs
> [    1.707004] calling  crypto_ctr_module_init+0x0/0x69 @ 1
> [    1.708007] initcall crypto_ctr_module_init+0x0/0x69 returned 0 af=
ter 0 usecs
> [    1.709004] calling  crypto_gcm_module_init+0x0/0x87 @ 1
> [    1.710008] initcall crypto_gcm_module_init+0x0/0x87 returned 0 af=
ter 0 usecs
> [    1.711004] calling  crypto_ccm_module_init+0x0/0x87 @ 1
> [    1.712008] initcall crypto_ccm_module_init+0x0/0x87 returned 0 af=
ter 0 usecs
> [    1.713004] calling  cryptd_init+0x0/0x109 @ 1
> [    1.714010] initcall cryptd_init+0x0/0x109 returned 0 after 0 usec=
s
> [    1.715004] calling  des_generic_mod_init+0x0/0x65 @ 1
> [    1.716098] initcall des_generic_mod_init+0x0/0x65 returned 0 afte=
r 0 usecs
> [    1.717005] calling  fcrypt_mod_init+0x0/0x39 @ 1
> [    1.718059] alg: No test for fcrypt (fcrypt-generic)
> [    1.723606] initcall fcrypt_mod_init+0x0/0x39 returned 0 after 488=
2 usecs
> [    1.724004] calling  blowfish_mod_init+0x0/0x39 @ 1
> [    1.726255] initcall blowfish_mod_init+0x0/0x39 returned 0 after 9=
76 usecs
> [    1.727004] calling  twofish_mod_init+0x0/0x39 @ 1
> [    1.729180] initcall twofish_mod_init+0x0/0x39 returned 0 after 97=
6 usecs
> [    1.730004] calling  aes_init+0x0/0x39 @ 1
> [    1.731059] initcall aes_init+0x0/0x39 returned 0 after 0 usecs
> [    1.732008] calling  camellia_init+0x0/0x39 @ 1
> [    1.733059] initcall camellia_init+0x0/0x39 returned 0 after 0 use=
cs
> [    1.734005] calling  cast5_mod_init+0x0/0x39 @ 1
> [    1.735059] initcall cast5_mod_init+0x0/0x39 returned 0 after 0 us=
ecs
> [    1.736005] calling  cast6_mod_init+0x0/0x39 @ 1
> [    1.738070] initcall cast6_mod_init+0x0/0x39 returned 0 after 976 =
usecs
> [    1.739004] calling  arc4_init+0x0/0x39 @ 1
> [    1.741012] initcall arc4_init+0x0/0x39 returned 0 after 976 usecs
> [    1.742004] calling  khazad_mod_init+0x0/0x39 @ 1
> [    1.744062] initcall khazad_mod_init+0x0/0x39 returned 0 after 976=
 usecs
> [    1.745004] calling  anubis_mod_init+0x0/0x39 @ 1
> [    1.746081] initcall anubis_mod_init+0x0/0x39 returned 0 after 0 u=
secs
> [    1.747005] calling  salsa20_generic_mod_init+0x0/0x39 @ 1
> [    1.748060] initcall salsa20_generic_mod_init+0x0/0x39 returned 0 =
after 0 usecs
> [    1.749005] calling  deflate_mod_init+0x0/0x39 @ 1
> [    1.751616] initcall deflate_mod_init+0x0/0x39 returned 0 after 97=
6 usecs
> [    1.752004] calling  michael_mic_init+0x0/0x39 @ 1
> [    1.753060] initcall michael_mic_init+0x0/0x39 returned 0 after 0 =
usecs
> [    1.754005] calling  crc32c_mod_init+0x0/0x39 @ 1
> [    1.755058] initcall crc32c_mod_init+0x0/0x39 returned 0 after 0 u=
secs
> [    1.756005] calling  crypto_authenc_module_init+0x0/0x39 @ 1
> [    1.757006] initcall crypto_authenc_module_init+0x0/0x39 returned =
0 after 0 usecs
> [    1.758004] calling  lzo_mod_init+0x0/0x39 @ 1
> [    1.760124] initcall lzo_mod_init+0x0/0x39 returned 0 after 976 us=
ecs
> [    1.761004] calling  krng_mod_init+0x0/0x39 @ 1
> [    1.762059] alg: No test for stdrng (krng)
> [    1.766295] initcall krng_mod_init+0x0/0x39 returned 0 after 3906 =
usecs
> [    1.767004] calling  prng_mod_init+0x0/0x4e @ 1
> [    1.768061] alg: No test for stdrng (ansi_cprng)
> [    1.773167] initcall prng_mod_init+0x0/0x4e returned 0 after 4882 =
usecs
> [    1.774004] calling  proc_genhd_init+0x0/0x63 @ 1
> [    1.775024] initcall proc_genhd_init+0x0/0x63 returned 0 after 0 u=
secs
> [    1.776004] calling  bsg_init+0x0/0x14d @ 1
> [    1.777334] Block layer SCSI generic (bsg) driver version 0.4 load=
ed (major 254)
> [    1.778006] initcall bsg_init+0x0/0x14d returned 0 after 976 usecs
> [    1.779004] calling  noop_init+0x0/0x3b @ 1
> [    1.780039] io scheduler noop registered
> [    1.781005] initcall noop_init+0x0/0x3b returned 0 after 976 usecs
> [    1.782004] calling  deadline_init+0x0/0x3b @ 1
> [    1.783003] io scheduler deadline registered (default)
> [    1.784004] initcall deadline_init+0x0/0x3b returned 0 after 976 u=
secs
> [    1.785004] calling  cfq_init+0x0/0xbb @ 1
> [    1.786268] io scheduler cfq registered
> [    1.787006] initcall cfq_init+0x0/0xbb returned 0 after 976 usecs
> [    1.788005] calling  debug_objects_init_debugfs+0x0/0x8a @ 1
> [    1.789029] initcall debug_objects_init_debugfs+0x0/0x8a returned =
0 after 0 usecs
> [    1.790004] calling  libcrc32c_mod_init+0x0/0x53 @ 1
> [    1.791010] initcall libcrc32c_mod_init+0x0/0x53 returned 0 after =
0 usecs
> [    1.792003] calling  init_kmp+0x0/0x39 @ 1
> [    1.793014] initcall init_kmp+0x0/0x39 returned 0 after 0 usecs
> [    1.794003] calling  init_bm+0x0/0x39 @ 1
> [    1.795004] initcall init_bm+0x0/0x39 returned 0 after 0 usecs
> [    1.796003] calling  init_fsm+0x0/0x39 @ 1
> [    1.797004] initcall init_fsm+0x0/0x39 returned 0 after 0 usecs
> [    1.798003] calling  percpu_counter_startup+0x0/0x40 @ 1
> [    1.799007] initcall percpu_counter_startup+0x0/0x40 returned 0 af=
ter 0 usecs
> [    1.800006] calling  bt8xxgpio_init+0x0/0x42 @ 1
> [    1.801085] initcall bt8xxgpio_init+0x0/0x42 returned 0 after 0 us=
ecs
> [    1.802007] calling  pci_init+0x0/0x5b @ 1
> [    1.814130] pci 0000:01:00.0: Boot video device
> [    1.815015] initcall pci_init+0x0/0x5b returned 0 after 11718 usec=
s
> [    1.816004] calling  pci_proc_init+0x0/0x90 @ 1
> [    1.817313] initcall pci_proc_init+0x0/0x90 returned 0 after 0 use=
cs
> [    1.818004] calling  pci_stub_init+0x0/0x42 @ 1
> [    1.819077] initcall pci_stub_init+0x0/0x42 returned 0 after 0 use=
cs
> [    1.820004] calling  ltv350qv_init+0x0/0x39 @ 1
> [    1.821067] initcall ltv350qv_init+0x0/0x39 returned 0 after 0 use=
cs
> [    1.822005] calling  platform_lcd_init+0x0/0x39 @ 1
> [    1.823077] initcall platform_lcd_init+0x0/0x39 returned 0 after 0=
 usecs
> [    1.824005] calling  tdo24m_init+0x0/0x39 @ 1
> [    1.825075] initcall tdo24m_init+0x0/0x39 returned 0 after 0 usecs
> [    1.826005] calling  genericbl_init+0x0/0x39 @ 1
> [    1.827064] initcall genericbl_init+0x0/0x39 returned 0 after 0 us=
ecs
> [    1.828005] calling  mbp_init+0x0/0x120 @ 1
> [    1.829006] initcall mbp_init+0x0/0x120 returned -19 after 0 usecs
> [    1.830004] calling  kb3886_init+0x0/0x63 @ 1
> [    1.831005] initcall kb3886_init+0x0/0x63 returned -19 after 0 use=
cs
> [    1.832004] calling  xenfs_init+0x0/0x54 @ 1
> [    1.833003] XENFS: not registering filesystem on non-xen platform
> [    1.834004] initcall xenfs_init+0x0/0x54 returned 0 after 976 usec=
s
> [    1.835004] calling  regulator_fixed_voltage_init+0x0/0x39 @ 1
> [    1.836065] initcall regulator_fixed_voltage_init+0x0/0x39 returne=
d 0 after 0 usecs
> [    1.837005] calling  regulator_virtual_consumer_init+0x0/0x39 @ 1
> [    1.838064] initcall regulator_virtual_consumer_init+0x0/0x39 retu=
rned 0 after 0 usecs
> [    1.839005] calling  bq24022_init+0x0/0x40 @ 1
> [    1.840113] initcall bq24022_init+0x0/0x40 returned -19 after 0 us=
ecs
> [    1.841005] calling  pcf50633_regulator_init+0x0/0x39 @ 1
> [    1.842064] initcall pcf50633_regulator_init+0x0/0x39 returned 0 a=
fter 0 usecs
> [    1.843006] calling  rand_initialize+0x0/0x53 @ 1
> [    1.844033] initcall rand_initialize+0x0/0x53 returned 0 after 0 u=
secs
> [    1.845004] calling  tty_init+0x0/0x11c @ 1
> [    1.862310] initcall tty_init+0x0/0x11c returned 0 after 15625 use=
cs
> [    1.863006] calling  pty_init+0x0/0x39 @ 1
> [    2.002106] initcall pty_init+0x0/0x39 returned 0 after 134765 use=
cs
> [    2.003005] calling  sysrq_init+0x0/0x4c @ 1
> [    2.004023] initcall sysrq_init+0x0/0x4c returned 0 after 0 usecs
> [    2.005004] calling  epca_module_init+0x0/0x32 @ 1
> [    2.006022] DIGI epca driver version 1.3.0.1-LK2.6 loaded.
> [    2.189051] initcall epca_module_init+0x0/0x32 returned 0 after 17=
8711 usecs
> [    2.190006] calling  specialix_init_module+0x0/0xc4 @ 1
> [    2.191059] sx: Specialix IO8+ driver v1.11, (c) R.E.Wolff 1997/19=
98.
> [    2.192003] sx: derived from work (c) D.Gorodchanin 1994-1996.
> [    2.193003] sx: DTR/RTS pin is always RTS.
> [    2.223337] sx0: specialix IO8+ Board at 0x100 not found.
> [    2.224019] sx1: specialix IO8+ Board at 0x180 not found.
> [    2.225164] sx2: specialix IO8+ Board at 0x250 not found.
> [    2.226013] sx3: specialix IO8+ Board at 0x260 not found.
> [    2.278788] sx: No specialix IO8+ boards detected.
> [    2.279011] initcall specialix_init_module+0x0/0xc4 returned -5 af=
ter 85937 usecs
> [    2.280005] initcall specialix_init_module+0x0/0xc4 returned with =
error code -5=20
> [    2.281005] calling  moxa_init+0x0/0x14c @ 1
> [    2.282003] MOXA Intellio family driver version 6.0k
> [    2.344244] initcall moxa_init+0x0/0x14c returned 0 after 60546 us=
ecs
> [    2.345006] calling  ip2_loadmain+0x0/0x9db @ 1
> [    2.346036] Computone IntelliPort Plus multiport driver version 1.=
2.14
> [    2.347126] initcall ip2_loadmain+0x0/0x9db returned 0 after 976 u=
secs
> [    2.348005] calling  riscom8_init_module+0x0/0xb1 @ 1
> [    2.350030] rc: SDL RISCom/8 card driver v1.1, (c) D.Gorodchanin 1=
994-1996.
> [    2.367368] rc0: RISCom/8 Board at 0x220 not found.
> [    2.368046] rc1: RISCom/8 Board at 0x240 not found.
> [    2.369036] rc2: RISCom/8 Board at 0x250 not found.
> [    2.370036] rc3: RISCom/8 Board at 0x260 not found.
> [    2.399691] rc: No RISCom/8 boards detected.
> [    2.400021] initcall riscom8_init_module+0x0/0xb1 returned -5 afte=
r 48828 usecs
> [    2.401005] initcall riscom8_init_module+0x0/0xb1 returned with er=
ror code -5=20
> [    2.402004] calling  synclink_init+0x0/0x160 @ 1
> [    2.403003] SyncLink serial driver $Revision: 4.38 $
> [    2.467406] SyncLink serial driver $Revision: 4.38 $, tty major#25=
3
> [    2.468011] initcall synclink_init+0x0/0x160 returned 0 after 6347=
6 usecs
> [    2.469008] calling  synclinkmp_init+0x0/0x1b7 @ 1
> [    2.470004] SyncLink MultiPort driver $Revision: 4.38 $
> [    2.543524] SyncLink MultiPort driver $Revision: 4.38 $, tty major=
#252
> [    2.544010] initcall synclinkmp_init+0x0/0x1b7 returned 0 after 72=
265 usecs
> [    2.545041] calling  slgt_init+0x0/0x1e7 @ 1
> [    2.546003] SyncLink GT
> [    2.547034] SyncLink GT, tty major#251
> [    2.548086] SyncLink GT no devices found
> [    2.549009] initcall slgt_init+0x0/0x1e7 returned 0 after 2929 use=
cs
> [    2.550032] calling  sx_init+0x0/0x10e @ 1
> [    2.551185] initcall sx_init+0x0/0x10e returned 0 after 0 usecs
> [    2.552006] calling  raw_init+0x0/0x103 @ 1
> [    2.554395] initcall raw_init+0x0/0x103 returned 0 after 976 usecs
> [    2.555013] calling  lp_init_module+0x0/0xec @ 1
> [    2.556093] lp: driver loaded but no devices found
> [    2.557006] initcall lp_init_module+0x0/0xec returned 0 after 976 =
usecs
> [    2.558007] calling  applicom_init+0x0/0x4e9 @ 1
> [    2.559004] Applicom driver: $Id: ac.c,v 1.30 2000/03/22 16:03:57 =
dwmw2 Exp $
> [    2.560016] ac.o: No PCI boards found.
> [    2.561003] ac.o: For an ISA board you must supply memory and irq =
parameters.
> [    2.562005] initcall applicom_init+0x0/0x4e9 returned -6 after 292=
9 usecs
> [    2.563005] initcall applicom_init+0x0/0x4e9 returned with error c=
ode -6=20
> [    2.564004] calling  rtc_generic_init+0x0/0x8a @ 1
> [    2.565004] Generic RTC Driver v1.07
> [    2.566247] initcall rtc_generic_init+0x0/0x8a returned 0 after 97=
6 usecs
> [    2.567007] calling  i8k_init+0x0/0x78 @ 1
> [    2.568076] initcall i8k_init+0x0/0x78 returned -19 after 0 usecs
> [    2.569004] calling  mod_init+0x0/0x201 @ 1
> [    2.570284] initcall mod_init+0x0/0x201 returned -19 after 0 usecs
> [    2.571004] calling  mod_init+0x0/0xdf @ 1
> [    2.572103] initcall mod_init+0x0/0xdf returned -19 after 0 usecs
> [    2.573005] calling  pc8736x_gpio_init+0x0/0x3e4 @ 1
> [    2.575107] platform pc8736x_gpio.0: NatSemi pc8736x GPIO Driver I=
nitializing
> [    2.576012] platform pc8736x_gpio.0: no device found
> [    2.577120] initcall pc8736x_gpio_init+0x0/0x3e4 returned -19 afte=
r 2929 usecs
> [    2.578006] calling  nsc_gpio_init+0x0/0x3b @ 1
> [    2.579030] nsc_gpio initializing
> [    2.580005] initcall nsc_gpio_init+0x0/0x3b returned 0 after 976 u=
secs
> [    2.581004] calling  tlclk_init+0x0/0x1eb @ 1
> [    2.582014] telclk_interrup =3D 0xf non-mcpbl0010 hw.
> [    2.583017] initcall tlclk_init+0x0/0x1eb returned -6 after 976 us=
ecs
> [    2.584005] initcall tlclk_init+0x0/0x1eb returned with error code=
 -6=20
> [    2.585005] calling  mwave_init+0x0/0x2ca @ 1
> [    2.586010] smapi::smapi_init, ERROR invalid usSmapiID
> [    2.587003] mwave: tp3780i::tp3780I_InitializeBoardData: Error: SM=
API is not available on this machine
> [    2.588003] mwave: mwavedd::mwave_init: Error: Failed to initializ=
e board data
> [    2.589006] mwave: mwavedd::mwave_init: Error: Failed to initializ=
e
> [    2.590005] initcall mwave_init+0x0/0x2ca returned -5 after 3906 u=
secs
> [    2.591005] initcall mwave_init+0x0/0x2ca returned with error code=
 -5=20
> [    2.592004] calling  agp_init+0x0/0x4b @ 1
> [    2.593003] Linux agpgart interface v0.103
> [    2.594005] initcall agp_init+0x0/0x4b returned 0 after 976 usecs
> [    2.595004] calling  agp_intel_init+0x0/0x50 @ 1
> [    2.596084] initcall agp_intel_init+0x0/0x50 returned 0 after 0 us=
ecs
> [    2.597005] calling  agp_sis_init+0x0/0x50 @ 1
> [    2.598093] initcall agp_sis_init+0x0/0x50 returned 0 after 0 usec=
s
> [    2.599005] calling  agp_via_init+0x0/0x50 @ 1
> [    2.600085] initcall agp_via_init+0x0/0x50 returned 0 after 0 usec=
s
> [    2.601006] calling  ipmi_init_msghandler_mod+0x0/0x34 @ 1
> [    2.602081] ipmi message handler version 39.2
> [    2.603021] initcall ipmi_init_msghandler_mod+0x0/0x34 returned 0 =
after 976 usecs
> [    2.604005] calling  init_ipmi_devintf+0x0/0x120 @ 1
> [    2.605003] ipmi device interface
> [    2.606063] initcall init_ipmi_devintf+0x0/0x120 returned 0 after =
976 usecs
> [    2.607007] calling  init_ipmi_si+0x0/0x283 @ 1
> [    2.608078] IPMI System Interface driver.
> [    2.622177] ipmi_si: Unable to find any System Interface(s)
> [    2.623007] initcall init_ipmi_si+0x0/0x283 returned -19 after 146=
48 usecs
> [    2.624007] calling  ipmi_poweroff_init+0x0/0xb4 @ 1
> [    2.625004] Copyright (C) 2004 MontaVista Software - IPMI Powerdow=
n via sys_reboot.
> [    2.626015] initcall ipmi_poweroff_init+0x0/0xb4 returned 0 after =
976 usecs
> [    2.627005] calling  hangcheck_init+0x0/0xbf @ 1
> [    2.628004] Hangcheck: starting hangcheck timer 0.9.0 (tick is 180=
 seconds, margin is 60 seconds).
> [    2.629005] Hangcheck: Using get_cycles().
> [    2.630009] initcall hangcheck_init+0x0/0xbf returned 0 after 1953=
 usecs
> [    2.631005] calling  init_nsc+0x0/0x1fb @ 1
> [    2.632016] initcall init_nsc+0x0/0x1fb returned -19 after 0 usecs
> [    2.633005] calling  init_atmel+0x0/0x1af @ 1
> [    2.634114] initcall init_atmel+0x0/0x1af returned -19 after 0 use=
cs
> [    2.635006] calling  serial8250_init+0x0/0x16e @ 1
> [    2.636045] Serial: 8250/16550 driver, 4 ports, IRQ sharing disabl=
ed
> [    2.637124] serial8250: ttyS0 at I/O 0x3f8 (irq =3D 4) is a 16550A
> [    2.641406] initcall serial8250_init+0x0/0x16e returned 0 after 48=
82 usecs
> [    2.642007] calling  serial8250_pci_init+0x0/0x42 @ 1
> [    2.643122] initcall serial8250_pci_init+0x0/0x42 returned 0 after=
 0 usecs
> [    2.644006] calling  jsm_init_module+0x0/0x6e @ 1
> [    2.645198] initcall jsm_init_module+0x0/0x6e returned 0 after 0 u=
secs
> [    2.646006] calling  init_kgdboc+0x0/0x3b @ 1
> [    2.647007] initcall init_kgdboc+0x0/0x3b returned 0 after 0 usecs
> [    2.648005] calling  parport_default_proc_register+0x0/0x42 @ 1
> [    2.649013] initcall parport_default_proc_register+0x0/0x42 return=
ed 0 after 0 usecs
> [    2.650005] calling  parport_pc_init+0x0/0xd2 @ 1
> [    2.652187] parport0: PC-style at 0x378 (0x778)async_waiting @ 1
> [    2.654014] async_continuing @ 1 after 0 usec
> [    2.783012]  [PCSPP(,...)]
> [    2.785287] parport0: irq 7 detected
> [    2.786432] lp0: using parport0 (polling).
> [    2.787007] lp0: console ready
> [    2.788175] initcall parport_pc_init+0x0/0xd2 returned 0 after 133=
789 usecs
> [    2.789010] calling  parport_serial_init+0x0/0x42 @ 1
> [    2.791190] initcall parport_serial_init+0x0/0x42 returned 0 after=
 976 usecs
> [    2.792005] calling  parport_ax88796_init+0x0/0x39 @ 1
> [    2.793069] initcall parport_ax88796_init+0x0/0x39 returned 0 afte=
r 0 usecs
> [    2.794006] calling  topology_sysfs_init+0x0/0x89 @ 1
> [    2.795054] initcall topology_sysfs_init+0x0/0x89 returned 0 after=
 0 usecs
> [    2.796006] calling  floppy_init+0x0/0x59a @ 1
> [    2.798219] Floppy drive(s): fd0 is 1.44M
> [    2.813589] FDC 0 is a post-1991 82077
> [    2.815287] initcall floppy_init+0x0/0x59a returned 0 after 17578 =
usecs
> [    2.816007] calling  loop_init+0x0/0x1bc @ 1
> [    2.822202] loop: module loaded
> [    2.823008] initcall loop_init+0x0/0x1bc returned 0 after 5859 use=
cs
> [    2.824115] calling  cpqarray_init+0x0/0x92 @ 1
> [    2.825004] Compaq SMART2 Driver (v 2.6.0)
> [    2.826119] initcall cpqarray_init+0x0/0x92 returned -19 after 976=
 usecs
> [    2.827008] calling  DAC960_init_module+0x0/0x73 @ 1
> [    2.829373] initcall DAC960_init_module+0x0/0x73 returned 0 after =
976 usecs
> [    2.830038] calling  pkt_init+0x0/0x1fb @ 1
> [    2.832258] initcall pkt_init+0x0/0x1fb returned 0 after 976 usecs
> [    2.833032] calling  nbd_init+0x0/0x304 @ 1
> [    2.835648] nbd: registered device at major 43
> [    2.845242] initcall nbd_init+0x0/0x304 returned 0 after 10742 use=
cs
> [    2.846142] calling  init_cryptoloop+0x0/0x55 @ 1
> [    2.847006] initcall init_cryptoloop+0x0/0x55 returned 0 after 0 u=
secs
> [    2.848005] calling  carm_init+0x0/0x42 @ 1
> [    2.849099] initcall carm_init+0x0/0x42 returned 0 after 0 usecs
> [    2.850006] calling  xlblk_init+0x0/0xa1 @ 1
> [    2.851129] initcall xlblk_init+0x0/0xa1 returned -19 after 0 usec=
s
> [    2.852005] calling  pasic3_base_init+0x0/0x40 @ 1
> [    2.854294] initcall pasic3_base_init+0x0/0x40 returned -19 after =
976 usecs
> [    2.855022] calling  wm8400_module_init+0x0/0x59 @ 1
> [    2.856087] i2c-core: driver [WM8400] registered
> [    2.857008] initcall wm8400_module_init+0x0/0x59 returned 0 after =
976 usecs
> [    2.858047] calling  pcf50633_init+0x0/0x3b @ 1
> [    2.859064] i2c-core: driver [pcf50633] registered
> [    2.860007] initcall pcf50633_init+0x0/0x3b returned 0 after 976 u=
secs
> [    2.861063] calling  scsi_tgt_init+0x0/0xb1 @ 1
> [    2.864019] initcall scsi_tgt_init+0x0/0xb1 returned 0 after 1953 =
usecs
> [    2.865014] calling  raid_init+0x0/0x39 @ 1
> [    2.867095] initcall raid_init+0x0/0x39 returned 0 after 976 usecs
> [    2.868020] calling  spi_transport_init+0x0/0x55 @ 1
> [    2.869118] initcall spi_transport_init+0x0/0x55 returned 0 after =
0 usecs
> [    2.870006] calling  fc_transport_init+0x0/0x73 @ 1
> [    2.872172] initcall fc_transport_init+0x0/0x73 returned 0 after 9=
76 usecs
> [    2.873009] calling  iscsi_transport_init+0x0/0x173 @ 1
> [    2.874004] Loading iSCSI transport class v2.0-870.
> [    2.876310] initcall iscsi_transport_init+0x0/0x173 returned 0 aft=
er 1953 usecs
> [    2.877006] calling  sas_transport_init+0x0/0xe1 @ 1
> [    2.879254] initcall sas_transport_init+0x0/0xe1 returned 0 after =
976 usecs
> [    2.880006] calling  scsi_dh_init+0x0/0x65 @ 1
> [    2.881007] initcall scsi_dh_init+0x0/0x65 returned 0 after 0 usec=
s
> [    2.882005] calling  rdac_init+0x0/0x55 @ 1
> [    2.883017] rdac: device handler registered
> [    2.884006] initcall rdac_init+0x0/0x55 returned 0 after 976 usecs
> [    2.885005] calling  clariion_init+0x0/0x5c @ 1
> [    2.886005] emc: device handler registered
> [    2.887005] initcall clariion_init+0x0/0x5c returned 0 after 976 u=
secs
> [    2.888005] calling  alua_init+0x0/0x5c @ 1
> [    2.889005] alua: device handler registered
> [    2.890006] initcall alua_init+0x0/0x5c returned 0 after 976 usecs
> [    2.891005] calling  ahc_linux_init+0x0/0x8d @ 1
> [    2.892106] initcall ahc_linux_init+0x0/0x8d returned 0 after 0 us=
ecs
> [    2.893006] calling  init_st+0x0/0x129 @ 1
> [    2.894038] st: Version 20081215, fixed bufsize 32768, s/g segs 25=
6
> [    2.895061] Driver 'st' needs updating - please use bus_type metho=
ds
> [    2.896064] initcall init_st+0x0/0x129 returned 0 after 1953 usecs
> [    2.897005] calling  init_sd+0x0/0x106 @ 1
> [    2.898096] Driver 'sd' needs updating - please use bus_type metho=
ds
> [    2.899073] initcall init_sd+0x0/0x106 returned 0 after 976 usecs
> [    2.900015] calling  init_sr+0x0/0x6f @ 1
> [    2.901006] Driver 'sr' needs updating - please use bus_type metho=
ds
> [    2.903010] initcall init_sr+0x0/0x6f returned 0 after 1953 usecs
> [    2.904005] calling  init_sg+0x0/0x170 @ 1
> [    2.905102] initcall init_sg+0x0/0x170 returned 0 after 0 usecs
> [    2.906006] calling  init_ch_module+0x0/0xcd @ 1
> [    2.907006] SCSI Media Changer driver v0.25=20
> [    2.908060] Driver 'ch' needs updating - please use bus_type metho=
ds
> [    2.910104] initcall init_ch_module+0x0/0xcd returned 0 after 2929=
 usecs
> [    2.911006] calling  osd_uld_init+0x0/0xfe @ 1
> [    2.912059] Driver 'osd' needs updating - please use bus_type meth=
ods
> [    2.914110] osd: LOADED open-osd 0.1.0
> [    2.915006] initcall osd_uld_init+0x0/0xfe returned 0 after 2929 u=
secs
> [    2.916005] calling  ahci_init+0x0/0x42 @ 1
> [    2.917087] initcall ahci_init+0x0/0x42 returned 0 after 0 usecs
> [    2.918006] calling  k2_sata_init+0x0/0x42 @ 1
> [    2.919074] initcall k2_sata_init+0x0/0x42 returned 0 after 0 usec=
s
> [    2.920006] calling  piix_init+0x0/0x50 @ 1
> [    2.922171] initcall piix_init+0x0/0x50 returned 0 after 976 usecs
> [    2.923006] calling  pdc_ata_init+0x0/0x42 @ 1
> [    2.925012] initcall pdc_ata_init+0x0/0x42 returned 0 after 976 us=
ecs
> [    2.926005] calling  qs_ata_init+0x0/0x42 @ 1
> [    2.928037] initcall qs_ata_init+0x0/0x42 returned 0 after 976 use=
cs
> [    2.929035] calling  sil_init+0x0/0x42 @ 1
> [    2.930076] initcall sil_init+0x0/0x42 returned 0 after 0 usecs
> [    2.931006] calling  pdc_sata_init+0x0/0x42 @ 1
> [    2.932084] initcall pdc_sata_init+0x0/0x42 returned 0 after 0 use=
cs
> [    2.933006] calling  nv_init+0x0/0x42 @ 1
> [    2.934082] initcall nv_init+0x0/0x42 returned 0 after 0 usecs
> [    2.935006] calling  uli_init+0x0/0x42 @ 1
> [    2.937092] initcall uli_init+0x0/0x42 returned 0 after 976 usecs
> [    2.938006] calling  mv_init+0x0/0x6e @ 1
> [    2.939115] initcall mv_init+0x0/0x6e returned 0 after 0 usecs
> [    2.940006] calling  adma_ata_init+0x0/0x42 @ 1
> [    2.941087] initcall adma_ata_init+0x0/0x42 returned 0 after 0 use=
cs
> [    2.942006] calling  amd_init+0x0/0x42 @ 1
> [    2.943100] pata_amd 0000:00:06.0: version 0.4.1
> [    2.944102] pata_amd 0000:00:06.0: setting latency timer to 64
> [    2.945253] scsi0 : pata_amd
> [    2.947446] scsi1 : pata_amd
> [    2.949031] ata1: PATA max UDMA/133 cmd 0x1f0 ctl 0x3f6 bmdma 0xf0=
00 irq 14
> [    2.950004] ata2: PATA max UDMA/133 cmd 0x170 ctl 0x376 bmdma 0xf0=
08 irq 15
> [    3.109294] ata1.00: ATA-6: HDS722525VLAT80, V36OA60A, max UDMA/10=
0
> [    3.115005] ata1.00: 488397168 sectors, multi 1: LBA48=20
> [    3.121026] ata1: nv_mode_filter: 0x3f39f&0x3f07f->0x3f01f, BIOS=3D=
0x3f000 (0xc60000c0) ACPI=3D0x0
> [    3.138221] ata1.00: configured for UDMA/100
> [    3.142761] async_waiting @ 2890
> [    3.143004] async_continuing @ 2890 after 0 usec
> [    3.144290] scsi 0:0:0:0: Direct-Access     ATA      HDS722525VLAT=
80  V36O PQ: 0 ANSI: 5
> [    3.146273] sd 0:0:0:0: [sda] 488397168 512-byte hardware sectors:=
 (250 GB/232 GiB)
> [    3.147057] sd 0:0:0:0: [sda] Write Protect is off
> [    3.148006] sd 0:0:0:0: [sda] Mode Sense: 00 3a 00 00
> [    3.149100] sd 0:0:0:0: [sda] Write cache: enabled, read cache: en=
abled, doesn't support DPO or FUA
> [    3.150402]  sda: sda1 sda2 sda3 < sda5 sda6 sda7 sda8 sda9 sda10 =
>
> [    3.255278] sd 0:0:0:0: [sda] Attached SCSI disk
> [    3.257409] sd 0:0:0:0: Attached scsi generic sg0 type 0
> [    3.258293] async_waiting @ 2890
> [    3.259010] async_continuing @ 2890 after 0 usec
> [    3.422252] ata2.01: ATAPI: DVDRW IDE 16X, VER A079, max UDMA/66
> [    3.428025] ata2: nv_mode_filter: 0x1f39f&0x707f->0x701f, BIOS=3D0=
x7000 (0xc60000c0) ACPI=3D0x0
> [    3.442196] ata2.01: configured for UDMA/33
> [    3.447067] async_waiting @ 2890
> [    3.448004] async_continuing @ 2890 after 0 usec
> [    3.450290] scsi 1:0:1:0: CD-ROM            DVDRW    IDE 16X      =
    A079 PQ: 0 ANSI: 5
> [    3.456021] sr0: scsi3-mmc drive: 1x/48x writer cd/rw xa/form2 cdd=
a tray
> [    3.457007] Uniform CD-ROM driver Revision: 3.20
> [    3.458181] sr 1:0:1:0: Attached scsi CD-ROM sr0
> [    3.460206] sr 1:0:1:0: Attached scsi generic sg1 type 5
> [    3.462029] work_for_cpu used greatest stack depth: 3288 bytes lef=
t
> [    3.463035] initcall amd_init+0x0/0x42 returned 0 after 507812 use=
cs
> [    3.464006] calling  atiixp_init+0x0/0x42 @ 1
> [    3.465112] initcall atiixp_init+0x0/0x42 returned 0 after 0 usecs
> [    3.466007] calling  cmd64x_init+0x0/0x42 @ 1
> [    3.468033] initcall cmd64x_init+0x0/0x42 returned 0 after 976 use=
cs
> [    3.469027] calling  cs5530_init+0x0/0x42 @ 1
> [    3.470089] initcall cs5530_init+0x0/0x42 returned 0 after 0 usecs
> [    3.471006] calling  cy82c693_init+0x0/0x42 @ 1
> [    3.472076] initcall cy82c693_init+0x0/0x42 returned 0 after 0 use=
cs
> [    3.473006] calling  efar_init+0x0/0x42 @ 1
> [    3.474080] initcall efar_init+0x0/0x42 returned 0 after 0 usecs
> [    3.475006] calling  hpt37x_init+0x0/0x42 @ 1
> [    3.476076] initcall hpt37x_init+0x0/0x42 returned 0 after 0 usecs
> [    3.477006] calling  hpt3x2n_init+0x0/0x42 @ 1
> [    3.479149] initcall hpt3x2n_init+0x0/0x42 returned 0 after 976 us=
ecs
> [    3.480006] calling  hpt3x3_init+0x0/0x42 @ 1
> [    3.482135] initcall hpt3x3_init+0x0/0x42 returned 0 after 976 use=
cs
> [    3.483006] calling  it821x_init+0x0/0x42 @ 1
> [    3.485160] initcall it821x_init+0x0/0x42 returned 0 after 976 use=
cs
> [    3.486006] calling  jmicron_init+0x0/0x42 @ 1
> [    3.488144] initcall jmicron_init+0x0/0x42 returned 0 after 976 us=
ecs
> [    3.489006] calling  ns87410_init+0x0/0x42 @ 1
> [    3.490076] initcall ns87410_init+0x0/0x42 returned 0 after 0 usec=
s
> [    3.491006] calling  ns87415_init+0x0/0x42 @ 1
> [    3.493179] initcall ns87415_init+0x0/0x42 returned 0 after 976 us=
ecs
> [    3.494006] calling  mpiix_init+0x0/0x42 @ 1
> [    3.496187] initcall mpiix_init+0x0/0x42 returned 0 after 976 usec=
s
> [    3.497006] calling  oldpiix_init+0x0/0x42 @ 1
> [    3.499101] initcall oldpiix_init+0x0/0x42 returned 0 after 976 us=
ecs
> [    3.500006] calling  pdc2027x_init+0x0/0x42 @ 1
> [    3.501078] initcall pdc2027x_init+0x0/0x42 returned 0 after 0 use=
cs
> [    3.502006] calling  pdc202xx_init+0x0/0x42 @ 1
> [    3.503111] initcall pdc202xx_init+0x0/0x42 returned 0 after 0 use=
cs
> [    3.504007] calling  radisys_init+0x0/0x42 @ 1
> [    3.505093] initcall radisys_init+0x0/0x42 returned 0 after 0 usec=
s
> [    3.506007] calling  serverworks_init+0x0/0x42 @ 1
> [    3.507082] initcall serverworks_init+0x0/0x42 returned 0 after 0 =
usecs
> [    3.508006] calling  sil680_init+0x0/0x42 @ 1
> [    3.509081] initcall sil680_init+0x0/0x42 returned 0 after 0 usecs
> [    3.510006] calling  via_init+0x0/0x42 @ 1
> [    3.511087] initcall via_init+0x0/0x42 returned 0 after 0 usecs
> [    3.512007] calling  sl82c105_init+0x0/0x42 @ 1
> [    3.514120] initcall sl82c105_init+0x0/0x42 returned 0 after 976 u=
secs
> [    3.515006] calling  sis_init+0x0/0x42 @ 1
> [    3.516077] initcall sis_init+0x0/0x42 returned 0 after 0 usecs
> [    3.517006] calling  sch_init+0x0/0x42 @ 1
> [    3.518077] initcall sch_init+0x0/0x42 returned 0 after 0 usecs
> [    3.519006] calling  ata_generic_init+0x0/0x42 @ 1
> [    3.521140] initcall ata_generic_init+0x0/0x42 returned 0 after 97=
6 usecs
> [    3.522006] calling  e1000_init_module+0x0/0x8f @ 1
> [    3.523004] e1000e: Intel(R) PRO/1000 Network Driver - 0.3.3.4-k4
> [    3.524004] e1000e: Copyright (c) 1999-2008 Intel Corporation.
> [    3.526007] initcall e1000_init_module+0x0/0x8f returned 0 after 2=
929 usecs
> [    3.527005] calling  igb_init_module+0x0/0x7b @ 1
> [    3.528004] Intel(R) Gigabit Ethernet Network Driver - version 1.3=
=2E16-k2
> [    3.529004] Copyright (c) 2007-2009 Intel Corporation.
> [    3.530078] initcall igb_init_module+0x0/0x7b returned 0 after 195=
3 usecs
> [    3.531006] calling  ixgbe_init_module+0x0/0x8b @ 1
> [    3.532005] ixgbe: Intel(R) 10 Gigabit PCI Express Network Driver =
- version 2.0.8-k2
> [    3.533004] ixgbe: Copyright (c) 1999-2009 Intel Corporation.
> [    3.535157] initcall ixgbe_init_module+0x0/0x8b returned 0 after 2=
929 usecs
> [    3.536006] calling  ixgb_init_module+0x0/0x71 @ 1
> [    3.537005] Intel(R) PRO/10GbE Network Driver - version 1.0.135-k2=
-NAPI
> [    3.538004] Copyright (c) 1999-2008 Intel Corporation.
> [    3.539098] initcall ixgb_init_module+0x0/0x71 returned 0 after 19=
53 usecs
> [    3.540006] calling  ipg_init_module+0x0/0x42 @ 1
> [    3.541090] initcall ipg_init_module+0x0/0x42 returned 0 after 0 u=
secs
> [    3.542006] calling  t1_init_module+0x0/0x42 @ 1
> [    3.544118] initcall t1_init_module+0x0/0x42 returned 0 after 976 =
usecs
> [    3.545005] calling  cxgb3_init_module+0x0/0x47 @ 1
> [    3.546079] initcall cxgb3_init_module+0x0/0x47 returned 0 after 0=
 usecs
> [    3.547006] calling  bonding_init+0x0/0x115 @ 1
> [    3.548012] Ethernet Channel Bonding Driver: v3.5.0 (November 4, 2=
008)
> [    3.549007] bonding: Warning: either miimon or arp_interval and ar=
p_ip_target module parameters must be specified, otherwise bonding will=
 not detect link failures! see bonding.txt for details.
> [    3.551233] initcall bonding_init+0x0/0x115 returned 0 after 2929 =
usecs
> [    3.552007] calling  atl1_init_module+0x0/0x42 @ 1
> [    3.554086] initcall atl1_init_module+0x0/0x42 returned 0 after 97=
6 usecs
> [    3.555008] calling  atl2_init_module+0x0/0x71 @ 1
> [    3.556005] Atheros(R) L2 Ethernet Driver - version 2.2.3
> [    3.557004] Copyright (c) 2007 Atheros Corporation.
> [    3.559143] initcall atl2_init_module+0x0/0x71 returned 0 after 29=
29 usecs
> [    3.560006] calling  atl1e_init_module+0x0/0x42 @ 1
> [    3.562112] initcall atl1e_init_module+0x0/0x42 returned 0 after 9=
76 usecs
> [    3.563006] calling  enic_init_module+0x0/0x5c @ 1
> [    3.564004] enic: Cisco 10G Ethernet Driver, ver 1.0.0.933
> [    3.565105] initcall enic_init_module+0x0/0x5c returned 0 after 97=
6 usecs
> [    3.566006] calling  happy_meal_probe+0x0/0x42 @ 1
> [    3.567093] initcall happy_meal_probe+0x0/0x42 returned 0 after 0 =
usecs
> [    3.568006] calling  gem_init+0x0/0x42 @ 1
> [    3.569107] initcall gem_init+0x0/0x42 returned 0 after 0 usecs
> [    3.570006] calling  vortex_init+0x0/0xd8 @ 1
> [    3.571084] initcall vortex_init+0x0/0xd8 returned 0 after 0 usecs
> [    3.572006] calling  ne2k_pci_init+0x0/0x42 @ 1
> [    3.573091] initcall ne2k_pci_init+0x0/0x42 returned 0 after 0 use=
cs
> [    3.574006] calling  e100_init_module+0x0/0x81 @ 1
> [    3.575004] e100: Intel(R) PRO/100 Network Driver, 3.5.24-k2-NAPI
> [    3.576004] e100: Copyright(c) 1999-2006 Intel Corporation
> [    3.577079] initcall e100_init_module+0x0/0x81 returned 0 after 19=
53 usecs
> [    3.578006] calling  tlan_probe+0x0/0x108 @ 1
> [    3.579007] ThunderLAN driver v1.15a
> [    3.580077] TLAN: 0 devices installed, PCI: 0  EISA: 0
> [    3.582098] initcall tlan_probe+0x0/0x108 returned -19 after 2929 =
usecs
> [    3.583006] calling  epic_init+0x0/0x42 @ 1
> [    3.585143] initcall epic_init+0x0/0x42 returned 0 after 976 usecs
> [    3.586005] calling  sis190_init_module+0x0/0x42 @ 1
> [    3.587077] initcall sis190_init_module+0x0/0x42 returned 0 after =
0 usecs
> [    3.588006] calling  r6040_init+0x0/0x42 @ 1
> [    3.589089] initcall r6040_init+0x0/0x42 returned 0 after 0 usecs
> [    3.590006] calling  yellowfin_init+0x0/0x42 @ 1
> [    3.591078] initcall yellowfin_init+0x0/0x42 returned 0 after 0 us=
ecs
> [    3.592006] calling  ns83820_init+0x0/0x4e @ 1
> [    3.593004] ns83820.c: National Semiconductor DP83820 10/100/1000 =
driver.
> [    3.594077] initcall ns83820_init+0x0/0x4e returned 0 after 976 us=
ecs
> [    3.595006] calling  tg3_init+0x0/0x42 @ 1
> [    3.596081] initcall tg3_init+0x0/0x42 returned 0 after 0 usecs
> [    3.597006] calling  bnx2_init+0x0/0x42 @ 1
> [    3.598077] initcall bnx2_init+0x0/0x42 returned 0 after 0 usecs
> [    3.599006] calling  bnx2x_init+0x0/0x80 @ 1
> [    3.601116] initcall bnx2x_init+0x0/0x80 returned 0 after 976 usec=
s
> [    3.602006] calling  starfire_init+0x0/0x42 @ 1
> [    3.603080] initcall starfire_init+0x0/0x42 returned 0 after 0 use=
cs
> [    3.604006] calling  davicom_init+0x0/0x83 @ 1
> [    3.605121] initcall davicom_init+0x0/0x83 returned 0 after 0 usec=
s
> [    3.606006] calling  cicada_init+0x0/0x65 @ 1
> [    3.607116] initcall cicada_init+0x0/0x65 returned 0 after 0 usecs
> [    3.608006] calling  lxt_init+0x0/0x65 @ 1
> [    3.610173] initcall lxt_init+0x0/0x65 returned 0 after 0 usecs
> [    3.611006] calling  smsc_init+0x0/0xbf @ 1
> [    3.613211] initcall smsc_init+0x0/0xbf returned 0 after 976 usecs
> [    3.614006] calling  broadcom_init+0x0/0x125 @ 1
> [    3.617007] initcall broadcom_init+0x0/0x125 returned 0 after 1953=
 usecs
> [    3.618005] calling  ip175c_init+0x0/0x39 @ 1
> [    3.619087] initcall ip175c_init+0x0/0x39 returned 0 after 0 usecs
> [    3.620006] calling  et1011c_init+0x0/0x39 @ 1
> [    3.622131] initcall et1011c_init+0x0/0x39 returned 0 after 976 us=
ecs
> [    3.623006] calling  mdio_gpio_init+0x0/0x39 @ 1
> [    3.624260] initcall mdio_gpio_init+0x0/0x39 returned 0 after 0 us=
ecs
> [    3.625006] calling  ste10Xp_init+0x0/0x49 @ 1
> [    3.626116] initcall ste10Xp_init+0x0/0x49 returned 0 after 0 usec=
s
> [    3.627006] calling  hamachi_init+0x0/0x42 @ 1
> [    3.628108] initcall hamachi_init+0x0/0x42 returned 0 after 0 usec=
s
> [    3.629008] calling  net_olddevs_init+0x0/0x45 @ 1
> [    3.630022] D-Link DE-620 pocket adapter io 0x378, which is busy.
> [    3.632017] initcall net_olddevs_init+0x0/0x45 returned 0 after 19=
53 usecs
> [    3.633005] calling  b44_init+0x0/0x89 @ 1
> [    3.634115] initcall b44_init+0x0/0x89 returned 0 after 0 usecs
> [    3.635006] calling  init_nic+0x0/0x42 @ 1
> [    3.636163] forcedeth: Reverse Engineered nForce ethernet driver. =
Version 0.64.
> [    3.638035] IOAPIC[0]: Set routing entry (2-11 -> 0x3b -> IRQ 11 M=
ode:1 Active:1)
> [    3.639010] forcedeth 0000:00:0a.0: PCI->APIC IRQ transform: INT A=
 -> IRQ 11
> [    3.640007] forcedeth 0000:00:0a.0: setting latency timer to 64
> [    3.641121] nv_probe: set workaround bit for reversed mac addr
> [    4.154458] forcedeth 0000:00:0a.0: ifname eth0, PHY OUI 0x5043 @ =
1, addr 00:13:d4:dc:41:12
> [    4.155007] forcedeth 0000:00:0a.0: highdma csum gbit lnktim desc-=
v3
> [    4.156146] initcall init_nic+0x0/0x42 returned 0 after 507812 use=
cs
> [    4.157007] calling  ql3xxx_init_module+0x0/0x42 @ 1
> [    4.159164] initcall ql3xxx_init_module+0x0/0x42 returned 0 after =
976 usecs
> [    4.160006] calling  qlge_init_module+0x0/0x42 @ 1
> [    4.162189] initcall qlge_init_module+0x0/0x42 returned 0 after 97=
6 usecs
> [    4.163006] calling  ifb_init_module+0x0/0xdd @ 1
> [    4.165386] initcall ifb_init_module+0x0/0xdd returned 0 after 976=
 usecs
> [    4.166011] calling  macvlan_init_module+0x0/0x79 @ 1
> [    4.167009] initcall macvlan_init_module+0x0/0x79 returned 0 after=
 0 usecs
> [    4.168006] calling  de600_init+0x0/0x48 @ 1
> [    4.169018] DE600: port 0x378 busy
> [    4.170013] initcall de600_init+0x0/0x48 returned -16 after 976 us=
ecs
> [    4.171006] initcall de600_init+0x0/0x48 returned with error code =
-16=20
> [    4.172007] calling  dfx_init+0x0/0x42 @ 1
> [    4.173084] initcall dfx_init+0x0/0x42 returned 0 after 0 usecs
> [    4.174006] calling  cp_init+0x0/0x42 @ 1
> [    4.175096] 8139cp: 10/100 PCI Ethernet driver v1.3 (Mar 22, 2004)
> [    4.176007] 8139cp 0000:05:07.0: This (id 10ec:8139 rev 10) is not=
 an 8139C+ compatible chip, use 8139too
> [    4.177119] initcall cp_init+0x0/0x42 returned 0 after 1953 usecs
> [    4.178007] calling  rtl8139_init_module+0x0/0x42 @ 1
> [    4.179082] 8139too Fast Ethernet driver 0.9.28
> [    4.180038] 8139too 0000:05:07.0: PCI->APIC IRQ transform: INT A -=
> IRQ 11
> [    4.182535] eth1: RealTek RTL8139 at 0xffffc90000806000, 00:c0:df:=
03:68:5d, IRQ 11
> [    4.183006] eth1:  Identified 8139 chip type 'RTL-8139B'
> [    4.184091] initcall rtl8139_init_module+0x0/0x42 returned 0 after=
 4882 usecs
> [    4.185007] calling  sc92031_init+0x0/0x42 @ 1
> [    4.186086] initcall sc92031_init+0x0/0x42 returned 0 after 0 usec=
s
> [    4.187007] calling  eql_init_module+0x0/0x89 @ 1
> [    4.188017] Equalizer2002: Simon Janes (simon@ncm.com) and David S=
=2E Miller (davem@redhat.com)
> [    4.189200] initcall eql_init_module+0x0/0x89 returned 0 after 976=
 usecs
> [    4.190006] calling  tun_init+0x0/0xb7 @ 1
> [    4.191007] tun: Universal TUN/TAP device driver, 1.6
> [    4.192004] tun: (C) 1999-2004 Max Krasnyansky <maxk@qualcomm.com>
> [    4.193286] initcall tun_init+0x0/0xb7 returned 0 after 1953 usecs
> [    4.194007] calling  veth_init+0x0/0x39 @ 1
> [    4.195010] initcall veth_init+0x0/0x39 returned 0 after 0 usecs
> [    4.196006] calling  amd8111e_init+0x0/0x42 @ 1
> [    4.198100] initcall amd8111e_init+0x0/0x42 returned 0 after 976 u=
secs
> [    4.199006] calling  s2io_starter+0x0/0x42 @ 1
> [    4.200089] initcall s2io_starter+0x0/0x42 returned 0 after 0 usec=
s
> [    4.201007] calling  myri10ge_init_module+0x0/0xa5 @ 1
> [    4.202007] myri10ge: Version 1.4.4-1.401
> [    4.203082] initcall myri10ge_init_module+0x0/0xa5 returned 0 afte=
r 976 usecs
> [    4.204006] calling  enc28j60_init+0x0/0x4a @ 1
> [    4.205069] initcall enc28j60_init+0x0/0x4a returned 0 after 0 use=
cs
> [    4.206006] calling  dnet_init+0x0/0x39 @ 1
> [    4.207073] initcall dnet_init+0x0/0x39 returned 0 after 0 usecs
> [    4.208007] calling  ipddp_init_module+0x0/0x48 @ 1
> [    4.209015] ipddp.c:v0.01 8/28/97 Bradford W. Johnson <johns393@ma=
roon.tc.umn.edu>
> [    4.210200] ipddp0: Appletalk-IP Decap. mode by Jay Schulist <jsch=
lst@samba.org>
> [    4.211007] initcall ipddp_init_module+0x0/0x48 returned 0 after 1=
953 usecs
> [    4.212006] calling  catc_init+0x0/0x5e @ 1
> [    4.214145] usbcore: registered new interface driver catc
> [    4.215008] catc: v2.8:CATC EL1210A NetMate USB Ethernet driver
> [    4.216006] initcall catc_init+0x0/0x5e returned 0 after 2929 usec=
s
> [    4.217006] calling  kaweth_init+0x0/0x42 @ 1
> [    4.218065] usbcore: registered new interface driver kaweth
> [    4.219010] initcall kaweth_init+0x0/0x42 returned 0 after 976 use=
cs
> [    4.220006] calling  pegasus_init+0x0/0x6d @ 1
> [    4.221005] pegasus: v0.6.14 (2006/09/27), Pegasus/Pegasus II USB =
Ethernet driver
> [    4.222085] usbcore: registered new interface driver pegasus
> [    4.223010] initcall pegasus_init+0x0/0x6d returned 0 after 1953 u=
secs
> [    4.224006] calling  usb_rtl8150_init+0x0/0x4e @ 1
> [    4.225005] rtl8150: v0.6.2 (2004/08/27):rtl8150 based usb-etherne=
t driver
> [    4.226065] usbcore: registered new interface driver rtl8150
> [    4.227010] initcall usb_rtl8150_init+0x0/0x4e returned 0 after 19=
53 usecs
> [    4.228006] calling  hso_init+0x0/0x1ce @ 1
> [    4.229007] hso: drivers/net/usb/hso.c: 1.2 Option Wireless
> [    4.230096] usbcore: registered new interface driver hso
> [    4.231010] initcall hso_init+0x0/0x1ce returned 0 after 1953 usec=
s
> [    4.232006] calling  asix_init+0x0/0x42 @ 1
> [    4.233065] usbcore: registered new interface driver asix
> [    4.234010] initcall asix_init+0x0/0x42 returned 0 after 976 usecs
> [    4.235006] calling  cdc_init+0x0/0x42 @ 1
> [    4.236065] usbcore: registered new interface driver cdc_ether
> [    4.237010] initcall cdc_init+0x0/0x42 returned 0 after 976 usecs
> [    4.238006] calling  smsc95xx_init+0x0/0x42 @ 1
> [    4.239076] usbcore: registered new interface driver smsc95xx
> [    4.240010] initcall smsc95xx_init+0x0/0x42 returned 0 after 976 u=
secs
> [    4.241006] calling  net1080_init+0x0/0x42 @ 1
> [    4.242066] usbcore: registered new interface driver net1080
> [    4.243010] initcall net1080_init+0x0/0x42 returned 0 after 976 us=
ecs
> [    4.244006] calling  plusb_init+0x0/0x42 @ 1
> [    4.245075] usbcore: registered new interface driver plusb
> [    4.246010] initcall plusb_init+0x0/0x42 returned 0 after 976 usec=
s
> [    4.247006] calling  rndis_init+0x0/0x42 @ 1
> [    4.248066] usbcore: registered new interface driver rndis_host
> [    4.249010] initcall rndis_init+0x0/0x42 returned 0 after 976 usec=
s
> [    4.250006] calling  cdc_subset_init+0x0/0x42 @ 1
> [    4.251066] usbcore: registered new interface driver cdc_subset
> [    4.252010] initcall cdc_subset_init+0x0/0x42 returned 0 after 976=
 usecs
> [    4.253006] calling  zaurus_init+0x0/0x42 @ 1
> [    4.254075] usbcore: registered new interface driver zaurus
> [    4.255010] initcall zaurus_init+0x0/0x42 returned 0 after 976 use=
cs
> [    4.256006] calling  usbnet_init+0x0/0x52 @ 1
> [    4.257012] initcall usbnet_init+0x0/0x52 returned 0 after 0 usecs
> [    4.258006] calling  ipw2100_init+0x0/0xa8 @ 1
> [    4.259005] ipw2100: Intel(R) PRO/Wireless 2100 Network Driver, gi=
t-1.2.2
> [    4.260005] ipw2100: Copyright(c) 2003-2006 Intel Corporation
> [    4.262035] initcall ipw2100_init+0x0/0xa8 returned 0 after 2929 u=
secs
> [    4.263007] calling  ipw_init+0x0/0xad @ 1
> [    4.264005] ipw2200: Intel(R) PRO/Wireless 2200/2915 Network Drive=
r, 1.2.2kdmprq
> [    4.265004] ipw2200: Copyright(c) 2003-2006 Intel Corporation
> [    4.267138] initcall ipw_init+0x0/0xad returned 0 after 2929 usecs
> [    4.268006] calling  ieee80211_init+0x0/0x49 @ 1
> [    4.269006] ieee80211: 802.11 data/management/control stack, git-1=
=2E1.13
> [    4.270004] ieee80211: Copyright (C) 2004-2005 Intel Corporation <=
jketreno@linux.intel.com>
> [    4.271006] initcall ieee80211_init+0x0/0x49 returned 0 after 1953=
 usecs
> [    4.272006] calling  init_orinoco+0x0/0x42 @ 1
> [    4.273005] orinoco 0.15 (David Gibson <hermes@gibson.dropbear.id.=
au>, Pavel Roskin <proski@gnu.org>, et al)
> [    4.274006] initcall init_orinoco+0x0/0x42 returned 0 after 976 us=
ecs
> [    4.275006] calling  orinoco_plx_init+0x0/0x55 @ 1
> [    4.276005] orinoco_plx 0.15 (Pavel Roskin <proski@gnu.org>, David=
 Gibson <hermes@gibson.dropbear.id.au>, Daniel Barlow <dan@telent.net>)
> [    4.277079] initcall orinoco_plx_init+0x0/0x55 returned 0 after 97=
6 usecs
> [    4.278006] calling  orinoco_pci_init+0x0/0x55 @ 1
> [    4.279005] orinoco_pci 0.15 (Pavel Roskin <proski@gnu.org>, David=
 Gibson <hermes@gibson.dropbear.id.au> & Jean Tourrilhes <jt@hpl.hp.com=
>)
> [    4.280078] initcall orinoco_pci_init+0x0/0x55 returned 0 after 97=
6 usecs
> [    4.281007] calling  orinoco_nortel_init+0x0/0x55 @ 1
> [    4.282005] orinoco_nortel 0.15 (Tobias Hoffmann & Christoph Junge=
gger <disdos@traum404.de>)
> [    4.283081] initcall orinoco_nortel_init+0x0/0x55 returned 0 after=
 976 usecs
> [    4.284007] calling  airo_init_module+0x0/0x110 @ 1
> [    4.285022] airo(): Probing for PCI adapters
> [    4.286079] airo(): Finished probing for PCI adapters
> [    4.287007] initcall airo_init_module+0x0/0x110 returned 0 after 1=
953 usecs
> [    4.288006] calling  prism54_module_init+0x0/0x5c @ 1
> [    4.289005] Loaded prism54 driver, version 1.2
> [    4.290078] initcall prism54_module_init+0x0/0x5c returned 0 after=
 976 usecs
> [    4.291007] calling  hostap_init+0x0/0x6c @ 1
> [    4.292020] initcall hostap_init+0x0/0x6c returned 0 after 0 usecs
> [    4.293006] calling  init_prism2_pci+0x0/0x42 @ 1
> [    4.295034] initcall init_prism2_pci+0x0/0x42 returned 0 after 976=
 usecs
> [    4.296007] calling  rndis_wlan_init+0x0/0x42 @ 1
> [    4.297076] usbcore: registered new interface driver rndis_wlan
> [    4.298010] initcall rndis_wlan_init+0x0/0x42 returned 0 after 976=
 usecs
> [    4.299006] calling  zd1201_init+0x0/0x42 @ 1
> [    4.300065] usbcore: registered new interface driver zd1201
> [    4.301010] initcall zd1201_init+0x0/0x42 returned 0 after 976 use=
cs
> [    4.302006] calling  lbs_init_module+0x0/0xf3 @ 1
> [    4.303027] initcall lbs_init_module+0x0/0xf3 returned 0 after 0 u=
secs
> [    4.304006] calling  if_usb_init_module+0x0/0xe2 @ 1
> [    4.305067] usbcore: registered new interface driver usb8xxx
> [    4.307008] initcall if_usb_init_module+0x0/0xe2 returned 0 after =
1953 usecs
> [    4.308006] calling  if_sdio_init_module+0x0/0xfd @ 1
> [    4.309006] libertas_sdio: Libertas SDIO driver
> [    4.310004] libertas_sdio: Copyright Pierre Ossman
> [    4.311076] initcall if_sdio_init_module+0x0/0xfd returned 0 after=
 1953 usecs
> [    4.312007] calling  if_spi_init_module+0x0/0xed @ 1
> [    4.313005] libertas_spi: Libertas SPI driver
> [    4.314077] initcall if_spi_init_module+0x0/0xed returned 0 after =
976 usecs
> [    4.315007] calling  usb_irda_init+0x0/0x65 @ 1
> [    4.317018] usbcore: registered new interface driver irda-usb
> [    4.318047] USB IrDA support registered
> [    4.319006] initcall usb_irda_init+0x0/0x65 returned 0 after 2929 =
usecs
> [    4.320006] calling  stir_init+0x0/0x42 @ 1
> [    4.321067] usbcore: registered new interface driver stir4200
> [    4.322010] initcall stir_init+0x0/0x42 returned 0 after 976 usecs
> [    4.323006] calling  nsc_ircc_init+0x0/0x200 @ 1
> [    4.324117] initcall nsc_ircc_init+0x0/0x200 returned -19 after 0 =
usecs
> [    4.325007] calling  w83977af_init+0x0/0x74 @ 1
> [    4.326057] initcall w83977af_init+0x0/0x74 returned -19 after 0 u=
secs
> [    4.327006] calling  ali_ircc_init+0x0/0x18b @ 1
> [    4.329148] initcall ali_ircc_init+0x0/0x18b returned -19 after 97=
6 usecs
> [    4.330007] calling  vlsi_mod_init+0x0/0x151 @ 1
> [    4.332107] initcall vlsi_mod_init+0x0/0x151 returned 0 after 976 =
usecs
> [    4.333006] calling  irtty_sir_init+0x0/0x65 @ 1
> [    4.334007] initcall irtty_sir_init+0x0/0x65 returned 0 after 0 us=
ecs
> [    4.335006] calling  sir_wq_init+0x0/0x5c @ 1
> [    4.336081] initcall sir_wq_init+0x0/0x5c returned 0 after 0 usecs
> [    4.337007] calling  tekram_sir_init+0x0/0x52 @ 1
> [    4.338020] initcall tekram_sir_init+0x0/0x52 returned 0 after 0 u=
secs
> [    4.339006] calling  girbil_sir_init+0x0/0x39 @ 1
> [    4.340006] initcall girbil_sir_init+0x0/0x39 returned 0 after 0 u=
secs
> [    4.341006] calling  old_belkin_sir_init+0x0/0x39 @ 1
> [    4.342006] initcall old_belkin_sir_init+0x0/0x39 returned 0 after=
 0 usecs
> [    4.343006] calling  toim3232_sir_init+0x0/0x52 @ 1
> [    4.344006] initcall toim3232_sir_init+0x0/0x52 returned 0 after 0=
 usecs
> [    4.345006] calling  ksdazzle_init+0x0/0x42 @ 1
> [    4.347168] usbcore: registered new interface driver ksdazzle-sir
> [    4.348010] initcall ksdazzle_init+0x0/0x42 returned 0 after 1953 =
usecs
> [    4.349008] calling  init_netconsole+0x0/0x13f @ 1
> [    4.350009] console [netcon0] enabled
> [    4.351005] netconsole: network logging started
> [    4.352006] initcall init_netconsole+0x0/0x13f returned 0 after 19=
53 usecs
> [    4.353006] calling  niu_init+0x0/0x64 @ 1
> [    4.355081] initcall niu_init+0x0/0x64 returned 0 after 976 usecs
> [    4.356006] calling  efx_init_module+0x0/0xfd @ 1
> [    4.357004] Solarflare NET driver v2.3
> [    4.359149] initcall efx_init_module+0x0/0xfd returned 0 after 195=
3 usecs
> [    4.360040] calling  i2400m_driver_init+0x0/0x2d @ 1
> [    4.361006] initcall i2400m_driver_init+0x0/0x2d returned 0 after =
0 usecs
> [    4.362006] calling  i2400ms_driver_init+0x0/0x39 @ 1
> [    4.363092] initcall i2400ms_driver_init+0x0/0x39 returned 0 after=
 0 usecs
> [    4.364007] calling  i2o_iop_init+0x0/0x6c @ 1
> [    4.365004] I2O subsystem v1.325
> [    4.366005] i2o: max drivers =3D 8
> [    4.368123] initcall i2o_iop_init+0x0/0x6c returned 0 after 2929 u=
secs
> [    4.369041] calling  i2o_bus_init+0x0/0x68 @ 1
> [    4.370004] I2O Bus Adapter OSM v1.317
> [    4.371077] initcall i2o_bus_init+0x0/0x68 returned 0 after 976 us=
ecs
> [    4.372007] calling  i2o_block_init+0x0/0x146 @ 1
> [    4.373004] I2O Block Device OSM v1.325
> [    4.376065] initcall i2o_block_init+0x0/0x146 returned 0 after 292=
9 usecs
> [    4.377007] calling  i2o_scsi_init+0x0/0x68 @ 1
> [    4.378005] I2O SCSI Peripheral OSM v1.316
> [    4.379067] initcall i2o_scsi_init+0x0/0x68 returned 0 after 976 u=
secs
> [    4.380007] calling  i2o_proc_init+0x0/0xb8 @ 1
> [    4.381006] I2O ProcFS OSM v1.316
> [    4.382066] initcall i2o_proc_init+0x0/0xb8 returned 0 after 976 u=
secs
> [    4.383007] calling  fusion_init+0x0/0x164 @ 1
> [    4.384005] Fusion MPT base driver 3.04.07
> [    4.385005] Copyright (c) 1999-2008 LSI Corporation
> [    4.386031] initcall fusion_init+0x0/0x164 returned 0 after 1953 u=
secs
> [    4.387006] calling  mptspi_init+0x0/0x102 @ 1
> [    4.388005] Fusion MPT SPI Host driver 3.04.07
> [    4.389121] initcall mptspi_init+0x0/0x102 returned 0 after 976 us=
ecs
> [    4.390007] calling  mptfc_init+0x0/0x115 @ 1
> [    4.391005] Fusion MPT FC Host driver 3.04.07
> [    4.392105] initcall mptfc_init+0x0/0x115 returned 0 after 976 use=
cs
> [    4.393007] calling  mptsas_init+0x0/0x119 @ 1
> [    4.394005] Fusion MPT SAS Host driver 3.04.07
> [    4.395105] initcall mptsas_init+0x0/0x119 returned 0 after 976 us=
ecs
> [    4.396007] calling  mptctl_init+0x0/0x129 @ 1
> [    4.397005] Fusion MPT misc device (ioctl) driver 3.04.07
> [    4.398335] mptctl: Registered with Fusion MPT base driver
> [    4.399006] mptctl: /dev/mptctl @ (major,minor=3D10,220)
> [    4.400008] initcall mptctl_init+0x0/0x129 returned 0 after 2929 u=
secs
> [    4.401006] calling  mpt_lan_init+0x0/0xa4 @ 1
> [    4.402005] Fusion MPT LAN driver 3.04.07
> [    4.403010] initcall mpt_lan_init+0x0/0xa4 returned 0 after 976 us=
ecs
> [    4.404006] calling  fw_core_init+0x0/0xb0 @ 1
> [    4.405110] initcall fw_core_init+0x0/0xb0 returned 0 after 0 usec=
s
> [    4.406007] calling  fw_ohci_init+0x0/0x42 @ 1
> [    4.407099] initcall fw_ohci_init+0x0/0x42 returned 0 after 0 usec=
s
> [    4.408011] calling  sbp2_init+0x0/0x6d @ 1
> [    4.410114] initcall sbp2_init+0x0/0x6d returned 0 after 976 usecs
> [    4.411006] calling  uio_init+0x0/0x2d @ 1
> [    4.412006] initcall uio_init+0x0/0x2d returned 0 after 0 usecs
> [    4.413006] calling  hilscher_init_module+0x0/0x42 @ 1
> [    4.414092] initcall hilscher_init_module+0x0/0x42 returned 0 afte=
r 0 usecs
> [    4.415007] calling  uio_pdrv_init+0x0/0x39 @ 1
> [    4.416074] initcall uio_pdrv_init+0x0/0x39 returned 0 after 0 use=
cs
> [    4.417007] calling  uio_pdrv_genirq_init+0x0/0x39 @ 1
> [    4.419112] initcall uio_pdrv_genirq_init+0x0/0x39 returned 0 afte=
r 976 usecs
> [    4.420006] calling  aectc_init+0x0/0x42 @ 1
> [    4.421080] initcall aectc_init+0x0/0x42 returned 0 after 0 usecs
> [    4.422007] calling  sercos3_init_module+0x0/0x42 @ 1
> [    4.424158] initcall sercos3_init_module+0x0/0x42 returned 0 after=
 976 usecs
> [    4.425006] calling  cdrom_init+0x0/0x91 @ 1
> [    4.426006] initcall cdrom_init+0x0/0x91 returned 0 after 0 usecs
> [    4.427006] calling  butterfly_init+0x0/0x39 @ 1
> [    4.428034] parport0: powerup/reset Butterfly
> [    4.536134] parport_pc parport_pc.888: registered master spi42
> [    4.537034] spi spi42.1: spi_bitbang_setup, mode 0, 8 bits/w, 66 n=
sec/bit
> [    4.539190] parport_pc parport_pc.888: registered child spi42.1
> [    4.540006] parport0: dataflash at spi42.1
> [    4.541021] parport0: AVR Butterfly
> [    4.542008] initcall butterfly_init+0x0/0x39 returned 0 after 1113=
28 usecs
> [    4.543007] calling  spi_gpio_init+0x0/0x40 @ 1
> [    4.544119] initcall spi_gpio_init+0x0/0x40 returned -19 after 0 u=
secs
> [    4.545007] calling  nonstatic_sysfs_init+0x0/0x39 @ 1
> [    4.546040] initcall nonstatic_sysfs_init+0x0/0x39 returned 0 afte=
r 0 usecs
> [    4.547006] calling  yenta_socket_init+0x0/0x42 @ 1
> [    4.548096] initcall yenta_socket_init+0x0/0x42 returned 0 after 0=
 usecs
> [    4.549009] calling  aoe_init+0x0/0xd5 @ 1
> [    4.552348] aoe: AoE v47 initialised.
> [    4.553176] initcall aoe_init+0x0/0xd5 returned 0 after 2929 usecs
> [    4.554007] calling  uwb_subsys_init+0x0/0x77 @ 1
> [    4.555080] initcall uwb_subsys_init+0x0/0x77 returned 0 after 0 u=
secs
> [    4.556007] calling  hwarc_driver_init+0x0/0x42 @ 1
> [    4.558166] usbcore: registered new interface driver hwa-rc
> [    4.559011] initcall hwarc_driver_init+0x0/0x42 returned 0 after 1=
953 usecs
> [    4.560007] calling  i1480_dfu_driver_init+0x0/0x42 @ 1
> [    4.562085] usbcore: registered new interface driver i1480-dfu-usb
> [    4.563024] initcall i1480_dfu_driver_init+0x0/0x42 returned 0 aft=
er 1953 usecs
> [    4.564007] calling  i1480_est_init+0x0/0xa7 @ 1
> [    4.565012] initcall i1480_est_init+0x0/0xa7 returned 0 after 0 us=
ecs
> [    4.566007] calling  gpio_vbus_init+0x0/0x40 @ 1
> [    4.567118] initcall gpio_vbus_init+0x0/0x40 returned -19 after 0 =
usecs
> [    4.568007] calling  mon_init+0x0/0x141 @ 1
> [    4.570168] initcall mon_init+0x0/0x141 returned 0 after 976 usecs
> [    4.571058] calling  ehci_hcd_init+0x0/0x9e @ 1
> [    4.572005] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Dr=
iver
> [    4.573163] ehci_hcd 0000:00:02.1: can't find IRQ for PCI INT B; p=
robably buggy MP table
> [    4.574007] ehci_hcd 0000:00:02.1: Found HC with no IRQ.  Check BI=
OS/PCI 0000:00:02.1 setup!
> [    4.575013] ehci_hcd 0000:00:02.1: init 0000:00:02.1 fail, -19
> [    4.576119] initcall ehci_hcd_init+0x0/0x9e returned 0 after 3906 =
usecs
> [    4.577007] calling  isp116x_init+0x0/0x67 @ 1
> [    4.578013] 116x: driver isp116x-hcd, 03 Nov 2005
> [    4.579086] initcall isp116x_init+0x0/0x67 returned 0 after 976 us=
ecs
> [    4.580007] calling  ohci_hcd_mod_init+0x0/0xa3 @ 1
> [    4.581017] ohci_hcd: USB 1.1 'Open' Host Controller (OHCI) Driver
> [    4.582075] ohci_hcd 0000:00:02.0: can't find IRQ for PCI INT A; p=
robably buggy MP table
> [    4.583006] ohci_hcd 0000:00:02.0: Found HC with no IRQ.  Check BI=
OS/PCI 0000:00:02.0 setup!
> [    4.584011] ohci_hcd 0000:00:02.0: init 0000:00:02.0 fail, -19
> [    4.585116] initcall ohci_hcd_mod_init+0x0/0xa3 returned 0 after 3=
906 usecs
> [    4.586007] calling  uhci_hcd_init+0x0/0xe6 @ 1
> [    4.587008] uhci_hcd: USB Universal Host Controller Interface driv=
er
> [    4.589175] initcall uhci_hcd_init+0x0/0xe6 returned 0 after 1953 =
usecs
> [    4.590018] calling  sl811h_init+0x0/0x67 @ 1
> [    4.591005] sl811: driver sl811-hcd, 19 May 2005
> [    4.593022] initcall sl811h_init+0x0/0x67 returned 0 after 1953 us=
ecs
> [    4.594008] calling  isp1760_init+0x0/0x76 @ 1
> [    4.597171] initcall isp1760_init+0x0/0x76 returned 0 after 1953 u=
secs
> [    4.598009] calling  hwahc_driver_init+0x0/0x42 @ 1
> [    4.599083] usbcore: registered new interface driver hwa-hc
> [    4.600011] initcall hwahc_driver_init+0x0/0x42 returned 0 after 9=
76 usecs
> [    4.601006] calling  c67x00_init+0x0/0x39 @ 1
> [    4.602067] initcall c67x00_init+0x0/0x39 returned 0 after 0 usecs
> [    4.603010] calling  wusbcore_init+0x0/0x9a @ 1
> [    4.604066] initcall wusbcore_init+0x0/0x9a returned 0 after 0 use=
cs
> [    4.605007] calling  cbaf_driver_init+0x0/0x42 @ 1
> [    4.606078] usbcore: registered new interface driver wusb-cbaf
> [    4.607010] initcall cbaf_driver_init+0x0/0x42 returned 0 after 97=
6 usecs
> [    4.608006] calling  acm_init+0x0/0x128 @ 1
> [    4.610072] usbcore: registered new interface driver cdc_acm
> [    4.611008] cdc_acm: v0.26:USB Abstract Control Model driver for U=
SB modems and ISDN adapters
> [    4.612007] initcall acm_init+0x0/0x128 returned 0 after 2929 usec=
s
> [    4.613006] calling  usblp_init+0x0/0x42 @ 1
> [    4.614065] usbcore: registered new interface driver usblp
> [    4.615010] initcall usblp_init+0x0/0x42 returned 0 after 976 usec=
s
> [    4.616006] calling  wdm_init+0x0/0x42 @ 1
> [    4.618078] usbcore: registered new interface driver cdc_wdm
> [    4.619010] initcall wdm_init+0x0/0x42 returned 0 after 1953 usecs
> [    4.620006] calling  usbtmc_init+0x0/0x5e @ 1
> [    4.621067] usbcore: registered new interface driver usbtmc
> [    4.622011] initcall usbtmc_init+0x0/0x5e returned 0 after 976 use=
cs
> [    4.623006] calling  usb_stor_init+0x0/0x74 @ 1
> [    4.624005] Initializing USB Mass Storage driver...
> [    4.626025] usbcore: registered new interface driver usb-storage
> [    4.627007] USB Mass Storage support registered.
> [    4.628042] initcall usb_stor_init+0x0/0x74 returned 0 after 3906 =
usecs
> [    4.629008] calling  usb_usual_init+0x0/0x66 @ 1
> [    4.631170] usbcore: registered new interface driver libusual
> [    4.632011] initcall usb_usual_init+0x0/0x66 returned 0 after 1953=
 usecs
> [    4.633006] calling  alauda_init+0x0/0x42 @ 1
> [    4.635165] usbcore: registered new interface driver ums-alauda
> [    4.636011] initcall alauda_init+0x0/0x42 returned 0 after 1953 us=
ecs
> [    4.637006] calling  datafab_init+0x0/0x42 @ 1
> [    4.638184] usbcore: registered new interface driver ums-datafab
> [    4.639010] initcall datafab_init+0x0/0x42 returned 0 after 976 us=
ecs
> [    4.640039] calling  freecom_init+0x0/0x42 @ 1
> [    4.641069] usbcore: registered new interface driver ums-freecom
> [    4.642010] initcall freecom_init+0x0/0x42 returned 0 after 976 us=
ecs
> [    4.643006] calling  isd200_init+0x0/0x42 @ 1
> [    4.644076] usbcore: registered new interface driver ums-isd200
> [    4.645010] initcall isd200_init+0x0/0x42 returned 0 after 976 use=
cs
> [    4.646013] calling  karma_init+0x0/0x42 @ 1
> [    4.648156] usbcore: registered new interface driver ums-karma
> [    4.649011] initcall karma_init+0x0/0x42 returned 0 after 1953 use=
cs
> [    4.650006] calling  onetouch_init+0x0/0x42 @ 1
> [    4.652098] usbcore: registered new interface driver ums-onetouch
> [    4.653012] initcall onetouch_init+0x0/0x42 returned 0 after 1953 =
usecs
> [    4.654006] calling  sddr09_init+0x0/0x42 @ 1
> [    4.655069] usbcore: registered new interface driver ums-sddr09
> [    4.656010] initcall sddr09_init+0x0/0x42 returned 0 after 976 use=
cs
> [    4.657033] calling  usbat_init+0x0/0x42 @ 1
> [    4.659086] usbcore: registered new interface driver ums-usbat
> [    4.660011] initcall usbat_init+0x0/0x42 returned 0 after 1953 use=
cs
> [    4.661006] calling  microtek_drv_init+0x0/0x42 @ 1
> [    4.662107] usbcore: registered new interface driver microtekX6
> [    4.663011] initcall microtek_drv_init+0x0/0x42 returned 0 after 9=
76 usecs
> [    4.664027] calling  berry_init+0x0/0x42 @ 1
> [    4.665068] usbcore: registered new interface driver berry_charge
> [    4.666010] initcall berry_init+0x0/0x42 returned 0 after 976 usec=
s
> [    4.667020] calling  cypress_init+0x0/0x60 @ 1
> [    4.668069] usbcore: registered new interface driver cypress_cy7c6=
3
> [    4.669012] initcall cypress_init+0x0/0x60 returned 0 after 976 us=
ecs
> [    4.670013] calling  usb_cytherm_init+0x0/0x70 @ 1
> [    4.671067] usbcore: registered new interface driver cytherm
> [    4.672008] cytherm: v1.0:Cypress USB Thermometer driver
> [    4.673009] initcall usb_cytherm_init+0x0/0x70 returned 0 after 19=
53 usecs
> [    4.674006] calling  emi62_init+0x0/0x5e @ 1
> [    4.675067] usbcore: registered new interface driver emi62 - firmw=
are loader
> [    4.676011] initcall emi62_init+0x0/0x5e returned 0 after 976 usec=
s
> [    4.677006] calling  ftdi_elan_init+0x0/0x192 @ 1
> [    4.678006] driver ftdi-elan built at 11:52:35 on Jun  7 2009
> [    4.680007] usbcore: registered new interface driver ftdi-elan
> [    4.681028] initcall ftdi_elan_init+0x0/0x192 returned 0 after 292=
9 usecs
> [    4.682007] calling  usb_idmouse_init+0x0/0x6c @ 1
> [    4.683005] idmouse: 0.6:Siemens ID Mouse FingerTIP Sensor Driver
> [    4.684068] usbcore: registered new interface driver idmouse
> [    4.685010] initcall usb_idmouse_init+0x0/0x6c returned 0 after 19=
53 usecs
> [    4.686006] calling  iowarrior_init+0x0/0x42 @ 1
> [    4.688121] usbcore: registered new interface driver iowarrior
> [    4.689010] initcall iowarrior_init+0x0/0x42 returned 0 after 1953=
 usecs
> [    4.690006] calling  isight_firmware_init+0x0/0x42 @ 1
> [    4.691076] usbcore: registered new interface driver isight_firmwa=
re
> [    4.692011] initcall isight_firmware_init+0x0/0x42 returned 0 afte=
r 976 usecs
> [    4.693006] calling  usb_lcd_init+0x0/0x60 @ 1
> [    4.695177] usbcore: registered new interface driver usblcd
> [    4.696011] initcall usb_lcd_init+0x0/0x60 returned 0 after 1953 u=
secs
> [    4.697006] calling  tv_init+0x0/0x70 @ 1
> [    4.698090] usbcore: registered new interface driver trancevibrato=
r
> [    4.699009] trancevibrator: v1.1:PlayStation 2 Trance Vibrator dri=
ver
> [    4.700007] initcall tv_init+0x0/0x70 returned 0 after 1953 usecs
> [    4.701007] calling  uss720_init+0x0/0x88 @ 1
> [    4.702078] usbcore: registered new interface driver uss720
> [    4.703011] uss720: v0.6:USB Parport Cable driver for Cables using=
 the Lucent Technologies USS720 Chip
> [    4.704037] uss720: NOTE: this is a special purpose driver to allo=
w nonstandard
> [    4.705005] uss720: protocols (eg. bitbang) over USS720 usb to par=
allel cables
> [    4.706005] uss720: If you just want to connect to a printer, use =
usblp instead
> [    4.707007] initcall uss720_init+0x0/0x88 returned 0 after 4882 us=
ecs
> [    4.708006] calling  vstusb_init+0x0/0x67 @ 1
> [    4.709080] usbcore: registered new interface driver vstusb
> [    4.710011] initcall vstusb_init+0x0/0x67 returned 0 after 976 use=
cs
> [    4.711007] calling  i8042_init+0x0/0x12f @ 1
> [    4.716074] serio: i8042 KBD port at 0x60,0x64 irq 1
> [    4.721014] serio: i8042 AUX port at 0x60,0x64 irq 12
> [    4.726022] initcall i8042_init+0x0/0x12f returned 0 after 13671 u=
secs
> [    4.732008] calling  parkbd_init+0x0/0x1ae @ 1
> [    4.737010] parport0: cannot grant exclusive access for device par=
kbd
> [    4.743014] initcall parkbd_init+0x0/0x1ae returned -19 after 5859=
 usecs
> [    4.750007] calling  serport_init+0x0/0x5a @ 1
> [    4.754008] initcall serport_init+0x0/0x5a returned 0 after 0 usec=
s
> [    4.760007] calling  ct82c710_init+0x0/0xe8 @ 1
> [    4.765018] initcall ct82c710_init+0x0/0xe8 returned -19 after 0 u=
secs
> [    4.772007] calling  serio_raw_init+0x0/0x42 @ 1
> [    4.777460] initcall serio_raw_init+0x0/0x42 returned 0 after 976 =
usecs
> [    4.784057] calling  emu_init+0x0/0x42 @ 1
> [    4.788442] initcall emu_init+0x0/0x42 returned 0 after 0 usecs
> [    4.794008] calling  fm801_gp_init+0x0/0x42 @ 1
> [    4.799114] initcall fm801_gp_init+0x0/0x42 returned 0 after 976 u=
secs
> [    4.805067] calling  l4_init+0x0/0xa8 @ 1
> [    4.809023] initcall l4_init+0x0/0xa8 returned -19 after 0 usecs
> [    4.815007] calling  mousedev_init+0x0/0xb3 @ 1
> [    4.821142] mice: PS/2 mouse device common for all mice
> [    4.826013] initcall mousedev_init+0x0/0xb3 returned 0 after 5859 =
usecs
> [    4.833007] calling  joydev_init+0x0/0x39 @ 1
> [    4.837008] initcall joydev_init+0x0/0x39 returned 0 after 0 usecs
> [    4.843007] calling  atkbd_init+0x0/0x4e @ 1
> [    4.848049] initcall atkbd_init+0x0/0x4e returned 0 after 976 usec=
s
> [    4.854023] calling  sunkbd_init+0x0/0x42 @ 1
> [    4.858885] initcall sunkbd_init+0x0/0x42 returned 0 after 0 usecs
> [    4.865008] calling  lkkbd_init+0x0/0x42 @ 1
> [    4.869660] initcall lkkbd_init+0x0/0x42 returned 0 after 0 usecs
> [    4.875008] calling  nkbd_init+0x0/0x42 @ 1
> [    4.880156] initcall nkbd_init+0x0/0x42 returned 0 after 976 usecs
> [    4.886008] calling  skbd_init+0x0/0x42 @ 1
> [    4.890717] input: AT Translated Set 2 keyboard as /class/input/in=
put0
> [    4.891254] initcall skbd_init+0x0/0x42 returned 0 after 976 usecs
> [    4.897041] calling  gpio_keys_init+0x0/0x39 @ 1
> [    4.902622] initcall gpio_keys_init+0x0/0x39 returned 0 after 0 us=
ecs
> [    4.909008] calling  atp_init+0x0/0x42 @ 1
> [    4.913390] usbcore: registered new interface driver appletouch
> [    4.919021] initcall atp_init+0x0/0x42 returned 0 after 5859 usecs
> [    4.925028] calling  bcm5974_init+0x0/0x42 @ 1
> [    4.930185] usbcore: registered new interface driver bcm5974
> [    4.935011] initcall bcm5974_init+0x0/0x42 returned 0 after 5859 u=
secs
> [    4.942012] calling  sermouse_init+0x0/0x42 @ 1
> [    4.947131] initcall sermouse_init+0x0/0x42 returned 0 after 976 u=
secs
> [    4.953012] calling  vsxxxaa_init+0x0/0x42 @ 1
> [    4.958315] initcall vsxxxaa_init+0x0/0x42 returned 0 after 0 usec=
s
> [    4.964008] calling  a3d_init+0x0/0x42 @ 1
> [    4.968887] initcall a3d_init+0x0/0x42 returned 0 after 0 usecs
> [    4.974008] calling  adi_init+0x0/0x42 @ 1
> [    4.979156] initcall adi_init+0x0/0x42 returned 0 after 976 usecs
> [    4.985008] calling  analog_init+0x0/0x118 @ 1
> [    4.989903] initcall analog_init+0x0/0x118 returned 0 after 0 usec=
s
> [    4.996008] calling  cobra_init+0x0/0x42 @ 1
> [    5.000655] initcall cobra_init+0x0/0x42 returned 0 after 0 usecs
> [    5.006008] calling  db9_init+0x0/0xd4 @ 1
> [    5.010007] initcall db9_init+0x0/0xd4 returned -19 after 0 usecs
> [    5.016007] calling  gc_init+0x0/0xe3 @ 1
> [    5.020007] initcall gc_init+0x0/0xe3 returned -19 after 0 usecs
> [    5.026007] calling  gf2k_init+0x0/0x42 @ 1
> [    5.031354] initcall gf2k_init+0x0/0x42 returned 0 after 0 usecs
> [    5.037008] calling  grip_init+0x0/0x42 @ 1
> [    5.041747] initcall grip_init+0x0/0x42 returned 0 after 0 usecs
> [    5.047008] calling  grip_init+0x0/0x42 @ 1
> [    5.052150] initcall grip_init+0x0/0x42 returned 0 after 976 usecs
> [    5.058008] calling  guillemot_init+0x0/0x42 @ 1
> [    5.063160] initcall guillemot_init+0x0/0x42 returned 0 after 976 =
usecs
> [    5.069010] calling  iforce_init+0x0/0x77 @ 1
> [    5.074336] usbcore: registered new interface driver iforce
> [    5.080158] initcall iforce_init+0x0/0x77 returned 0 after 5859 us=
ecs
> [    5.086008] calling  joydump_init+0x0/0x42 @ 1
> [    5.091251] initcall joydump_init+0x0/0x42 returned 0 after 0 usec=
s
> [    5.097008] calling  sw_init+0x0/0x42 @ 1
> [    5.101757] initcall sw_init+0x0/0x42 returned 0 after 0 usecs
> [    5.107007] calling  spaceorb_init+0x0/0x42 @ 1
> [    5.112349] initcall spaceorb_init+0x0/0x42 returned 0 after 0 use=
cs
> [    5.118007] calling  stinger_init+0x0/0x42 @ 1
> [    5.123356] initcall stinger_init+0x0/0x42 returned 0 after 0 usec=
s
> [    5.129007] calling  tmdc_init+0x0/0x42 @ 1
> [    5.134040] initcall tmdc_init+0x0/0x42 returned 0 after 976 usecs
> [    5.140007] calling  tgfx_init+0x0/0xe3 @ 1
> [    5.144007] initcall tgfx_init+0x0/0xe3 returned -19 after 0 usecs
> [    5.150006] calling  twidjoy_init+0x0/0x42 @ 1
> [    5.155226] initcall twidjoy_init+0x0/0x42 returned 0 after 0 usec=
s
> [    5.161007] calling  warrior_init+0x0/0x42 @ 1
> [    5.166163] initcall warrior_init+0x0/0x42 returned 0 after 976 us=
ecs
> [    5.172007] calling  usb_xpad_init+0x0/0x5e @ 1
> [    5.177334] usbcore: registered new interface driver xpad
> [    5.182009] xpad: X-Box pad driver
> [    5.186007] initcall usb_xpad_init+0x0/0x5e returned 0 after 8789 =
usecs
> [    5.192006] calling  zhenhua_init+0x0/0x42 @ 1
> [    5.197405] initcall zhenhua_init+0x0/0x42 returned 0 after 0 usec=
s
> [    5.203007] calling  walkera0701_init+0x0/0x3f @ 1
> [    5.208006] walkera0701: parport without interrupt
> [    5.213007] initcall walkera0701_init+0x0/0x3f returned -19 after =
4882 usecs
> [    5.220006] calling  aiptek_init+0x0/0x6c @ 1
> [    5.224868] usbcore: registered new interface driver aiptek
> [    5.230009] aiptek: v2.3 (May 2, 2007):Aiptek HyperPen USB Tablet =
Driver (Linux 2.6.x)
> [    5.238005] aiptek: Bryan W. Headley/Chris Atenasio/Cedric Brun/Re=
ne van Paassen
> [    5.245007] initcall aiptek_init+0x0/0x6c returned 0 after 20507 u=
secs
> [    5.252006] calling  gtco_init+0x0/0x77 @ 1
> [    5.256661] usbcore: registered new interface driver gtco
> [    5.262009] GTCO usb driver version: 2.00.0006initcall gtco_init+0=
x0/0x77 returned 0 after 9765 usecs
> [    5.271006] calling  kbtab_init+0x0/0x5e @ 1
> [    5.275778] usbcore: registered new interface driver kbtab
> [    5.281009] kbtab: v0.0.2:USB KB Gear JamStudio Tablet driver
> [    5.287007] initcall kbtab_init+0x0/0x5e returned 0 after 11718 us=
ecs
> [    5.293006] calling  wacom_init+0x0/0x6a @ 1
> [    5.297924] usbcore: registered new interface driver wacom
> [    5.303009] wacom: v1.50:USB Wacom Graphire and Wacom Intuos table=
t driver
> [    5.310007] initcall wacom_init+0x0/0x6a returned 0 after 12695 us=
ecs
> [    5.316006] calling  ad7877_init+0x0/0x39 @ 1
> [    5.321288] initcall ad7877_init+0x0/0x39 returned 0 after 0 usecs
> [    5.327009] calling  ad7879_init+0x0/0x3b @ 1
> [    5.332043] i2c-core: driver [ad7879] registered
> [    5.336008] initcall ad7879_init+0x0/0x3b returned 0 after 4882 us=
ecs
> [    5.343006] calling  ads7846_init+0x0/0x39 @ 1
> [    5.347729] initcall ads7846_init+0x0/0x39 returned 0 after 0 usec=
s
> [    5.354007] calling  fujitsu_init+0x0/0x42 @ 1
> [    5.358653] initcall fujitsu_init+0x0/0x42 returned 0 after 0 usec=
s
> [    5.364007] calling  inexio_init+0x0/0x42 @ 1
> [    5.369489] initcall inexio_init+0x0/0x42 returned 0 after 0 usecs
> [    5.375007] calling  mtouch_init+0x0/0x42 @ 1
> [    5.380236] initcall mtouch_init+0x0/0x42 returned 0 after 0 usecs
> [    5.386007] calling  mk712_init+0x0/0x20a @ 1
> [    5.390009] mk712: device not present
> [    5.394010] initcall mk712_init+0x0/0x20a returned -19 after 3906 =
usecs
> [    5.401006] calling  usbtouch_init+0x0/0x42 @ 1
> [    5.405802] usbcore: registered new interface driver usbtouchscree=
n
> [    5.412011] initcall usbtouch_init+0x0/0x42 returned 0 after 6835 =
usecs
> [    5.418006] calling  pm_init+0x0/0x42 @ 1
> [    5.422903] initcall pm_init+0x0/0x42 returned 0 after 0 usecs
> [    5.428007] calling  tsc2007_init+0x0/0x3b @ 1
> [    5.433392] i2c-core: driver [tsc2007] registered
> [    5.438008] initcall tsc2007_init+0x0/0x3b returned 0 after 4882 u=
secs
> [    5.444007] calling  ati_remote2_init+0x0/0x70 @ 1
> [    5.449618] usbcore: registered new interface driver ati_remote2
> [    5.455009] ati_remote2: ATI/Philips USB RF remote driver 0.3
> [    5.461007] initcall ati_remote2_init+0x0/0x70 returned 0 after 11=
718 usecs
> [    5.468007] calling  cm109_init+0x0/0x69 @ 1
> [    5.472006] cm109: Keymap for Komunikate KIP1000 phone loaded
> [    5.478544] usbcore: registered new interface driver cm109
> [    5.484009] cm109: CM109 phone driver: 20080805 (C) Alfred E. Hegg=
estad
> [    5.490007] initcall cm109_init+0x0/0x69 returned 0 after 17578 us=
ecs
> [    5.497007] calling  usb_keyspan_init+0x0/0x60 @ 1
> [    5.502089] usbcore: registered new interface driver keyspan_remot=
e
> [    5.508010] initcall usb_keyspan_init+0x0/0x60 returned 0 after 68=
35 usecs
> [    5.515007] calling  pcf50633_input_init+0x0/0x39 @ 1
> [    5.520469] initcall pcf50633_input_init+0x0/0x39 returned 0 after=
 0 usecs
> [    5.527007] calling  pcspkr_init+0x0/0x39 @ 1
> [    5.532067] input: PC Speaker as /class/input/input1
> [    5.537229] initcall pcspkr_init+0x0/0x39 returned 0 after 5859 us=
ecs
> [    5.543008] calling  powermate_init+0x0/0x42 @ 1
> [    5.548489] usbcore: registered new interface driver powermate
> [    5.554011] initcall powermate_init+0x0/0x42 returned 0 after 5859=
 usecs
> [    5.561007] calling  rotary_encoder_init+0x0/0x39 @ 1
> [    5.566287] initcall rotary_encoder_init+0x0/0x39 returned 0 after=
 0 usecs
> [    5.573007] calling  uinput_init+0x0/0x39 @ 1
> [    5.577922] initcall uinput_init+0x0/0x39 returned 0 after 0 usecs
> [    5.584010] calling  ali1563_init+0x0/0x42 @ 1
> [    5.588791] initcall ali1563_init+0x0/0x42 returned 0 after 0 usec=
s
> [    5.595008] calling  i2c_ali15x3_init+0x0/0x42 @ 1
> [    5.600131] initcall i2c_ali15x3_init+0x0/0x42 returned 0 after 97=
6 usecs
> [    5.606008] calling  amd756_init+0x0/0x42 @ 1
> [    5.611487] initcall amd756_init+0x0/0x42 returned 0 after 0 usecs
> [    5.617008] calling  i2c_amd8111_init+0x0/0x42 @ 1
> [    5.622689] initcall i2c_amd8111_init+0x0/0x42 returned 0 after 0 =
usecs
> [    5.629008] calling  i2c_i801_init+0x0/0x42 @ 1
> [    5.634113] initcall i2c_i801_init+0x0/0x42 returned 0 after 976 u=
secs
> [    5.640007] calling  i2c_sch_init+0x0/0x42 @ 1
> [    5.645286] initcall i2c_sch_init+0x0/0x42 returned 0 after 0 usec=
s
> [    5.651008] calling  nforce2_init+0x0/0x42 @ 1
> [    5.656362] i2c-adapter i2c-0: adapter [SMBus nForce2 adapter at 4=
c00] registered
> [    5.658010] i2c-adapter i2c-0: nForce2 SMBus adapter at 0x4c00
> [    5.660069] i2c-adapter i2c-1: adapter [SMBus nForce2 adapter at 4=
c40] registered
> [    5.661033] i2c-adapter i2c-1: nForce2 SMBus adapter at 0x4c40
> [    5.662094] initcall nforce2_init+0x0/0x42 returned 0 after 5859 u=
secs
> [    5.669017] calling  i2c_piix4_init+0x0/0x42 @ 1
> [    5.673973] initcall i2c_piix4_init+0x0/0x42 returned 0 after 0 us=
ecs
> [    5.680008] calling  i2c_sis5595_init+0x0/0x42 @ 1
> [    5.685471] initcall i2c_sis5595_init+0x0/0x42 returned 0 after 0 =
usecs
> [    5.692008] calling  i2c_sis96x_init+0x0/0x42 @ 1
> [    5.697073] initcall i2c_sis96x_init+0x0/0x42 returned 0 after 976=
 usecs
> [    5.703038] calling  i2c_vt586b_init+0x0/0x42 @ 1
> [    5.708711] initcall i2c_vt586b_init+0x0/0x42 returned 0 after 0 u=
secs
> [    5.715008] calling  ocores_i2c_init+0x0/0x39 @ 1
> [    5.720165] initcall ocores_i2c_init+0x0/0x39 returned 0 after 976=
 usecs
> [    5.726008] calling  i2c_adap_simtec_init+0x0/0x39 @ 1
> [    5.732209] initcall i2c_adap_simtec_init+0x0/0x39 returned 0 afte=
r 0 usecs
> [    5.739008] calling  i2c_parport_init+0x0/0x171 @ 1
> [    5.744008] i2c-parport-light: adapter type unspecified
> [    5.749007] initcall i2c_parport_init+0x0/0x171 returned -19 after=
 4882 usecs
> [    5.756007] calling  taos_init+0x0/0x42 @ 1
> [    5.760809] initcall taos_init+0x0/0x42 returned 0 after 0 usecs
> [    5.766008] calling  i2c_voodoo3_init+0x0/0x42 @ 1
> [    5.771819] initcall i2c_voodoo3_init+0x0/0x42 returned 0 after 0 =
usecs
> [    5.778008] calling  i2c_pca_pf_init+0x0/0x39 @ 1
> [    5.783354] initcall i2c_pca_pf_init+0x0/0x39 returned 0 after 0 u=
secs
> [    5.789008] calling  ds1682_init+0x0/0x3b @ 1
> [    5.794438] i2c-core: driver [ds1682] registered
> [    5.799011] initcall ds1682_init+0x0/0x3b returned 0 after 4882 us=
ecs
> [    5.805007] calling  pca9539_init+0x0/0x3b @ 1
> [    5.810156] i2c-core: driver [pca9539] registered
> [    5.814031] initcall pca9539_init+0x0/0x3b returned 0 after 4882 u=
secs
> [    5.821007] calling  pcf8574_init+0x0/0x3b @ 1
> [    5.826084] i2c-core: driver [pcf8574] registered
> [    5.830030] initcall pcf8574_init+0x0/0x3b returned 0 after 4882 u=
secs
> [    5.837007] calling  pcf8575_init+0x0/0x3b @ 1
> [    5.841974] i2c-core: driver [pcf8575] registered
> [    5.846031] initcall pcf8575_init+0x0/0x3b returned 0 after 4882 u=
secs
> [    5.853007] calling  tsl2550_init+0x0/0x3b @ 1
> [    5.857879] i2c-core: driver [tsl2550] registered
> [    5.862009] initcall tsl2550_init+0x0/0x3b returned 0 after 4882 u=
secs
> [    5.869007] calling  saa7146_vv_init_module+0x0/0x2d @ 1
> [    5.874007] initcall saa7146_vv_init_module+0x0/0x2d returned 0 af=
ter 0 usecs
> [    5.881007] calling  videodev_init+0x0/0xad @ 1
> [    5.886006] Linux video capture interface: v2.00
> [    5.890908] initcall videodev_init+0x0/0xad returned 0 after 3906 =
usecs
> [    5.897008] calling  v4l2_i2c_drv_init+0x0/0x8b @ 1
> [    5.902607] i2c-core: driver [tuner] registered
> [    5.907010] initcall v4l2_i2c_drv_init+0x0/0x8b returned 0 after 4=
882 usecs
> [    5.914007] calling  ir_init+0x0/0x3b @ 1
> [    5.918307] i2c-core: driver [ir-kbd-i2c] registered
> [    5.923010] initcall ir_init+0x0/0x3b returned 0 after 4882 usecs
> [    5.929007] calling  v4l2_i2c_drv_init+0x0/0x94 @ 1
> [    5.934436] i2c-core: driver [saa6588] registered
> [    5.939010] initcall v4l2_i2c_drv_init+0x0/0x94 returned 0 after 4=
882 usecs
> [    5.946007] calling  v4l2_i2c_drv_init+0x0/0x94 @ 1
> [    5.951178] i2c-core: driver [saa7115] registered
> [    5.955010] initcall v4l2_i2c_drv_init+0x0/0x94 returned 0 after 4=
882 usecs
> [    5.962007] calling  v4l2_i2c_drv_init+0x0/0x94 @ 1
> [    5.967921] i2c-core: driver [saa717x] registered
> [    5.972010] initcall v4l2_i2c_drv_init+0x0/0x94 returned 0 after 4=
882 usecs
> [    5.979007] calling  v4l2_i2c_drv_init+0x0/0x97 @ 1
> [    5.984660] i2c-core: driver [saa7127] registered
> [    5.989010] initcall v4l2_i2c_drv_init+0x0/0x97 returned 0 after 4=
882 usecs
> [    5.996009] calling  saa7134_init+0x0/0x70 @ 1
> [    6.000007] saa7130/34: v4l2 driver version 0.2.15 loaded
> [    6.006405] initcall saa7134_init+0x0/0x70 returned 0 after 5859 u=
secs
> [    6.012008] calling  empress_register+0x0/0x39 @ 1
> [    6.017050] initcall empress_register+0x0/0x39 returned 0 after 0 =
usecs
> [    6.024008] calling  v4l2_i2c_drv_init+0x0/0x94 @ 1
> [    6.029469] i2c-core: driver [saa6752hs] registered
> [    6.034010] initcall v4l2_i2c_drv_init+0x0/0x94 returned 0 after 4=
882 usecs
> [    6.041007] calling  em28xx_module_init+0x0/0x6e @ 1
> [    6.046487] usbcore: registered new interface driver em28xx
> [    6.052010] em28xx driver loaded
> [    6.055008] initcall em28xx_module_init+0x0/0x6e returned 0 after =
8789 usecs
> [    6.062007] calling  cx231xx_module_init+0x0/0x6c @ 1
> [    6.067006] cx231xx v4l2 driver loaded.
> [    6.071433] usbcore: registered new interface driver cx231xx
> [    6.077011] initcall cx231xx_module_init+0x0/0x6c returned 0 after=
 9765 usecs
> [    6.084007] calling  cx231xx_dvb_register+0x0/0x39 @ 1
> [    6.089027] cx231xx: Cx231xx dvb Extension initialized
> [    6.094008] initcall cx231xx_dvb_register+0x0/0x39 returned 0 afte=
r 4882 usecs
> [    6.101009] calling  usbvision_init+0x0/0x128 @ 1
> [    6.106664] usbcore: registered new interface driver usbvision
> [    6.112010] USBVision USB Video Device Driver for Linux : 0.9.10
> [    6.118008] initcall usbvision_init+0x0/0x128 returned 0 after 117=
18 usecs
> [    6.125008] calling  v4l2_i2c_drv_init+0x0/0x94 @ 1
> [    6.130463] i2c-core: driver [tvp5150] registered
> [    6.135010] initcall v4l2_i2c_drv_init+0x0/0x94 returned 0 after 4=
882 usecs
> [    6.142007] calling  v4l2_i2c_drv_init+0x0/0x8e @ 1
> [    6.147219] i2c-core: driver [msp3400] registered
> [    6.151010] initcall v4l2_i2c_drv_init+0x0/0x8e returned 0 after 3=
906 usecs
> [    6.158008] calling  v4l2_i2c_drv_init+0x0/0x94 @ 1
> [    6.163964] i2c-core: driver [cs53l32a] registered
> [    6.168010] initcall v4l2_i2c_drv_init+0x0/0x94 returned 0 after 4=
882 usecs
> [    6.175008] calling  v4l2_i2c_drv_init+0x0/0x94 @ 1
> [    6.180789] i2c-core: driver [m52790] registered
> [    6.185010] initcall v4l2_i2c_drv_init+0x0/0x94 returned 0 after 4=
882 usecs
> [    6.192008] calling  v4l2_i2c_drv_init+0x0/0x94 @ 1
> [    6.197443] i2c-core: driver [wm8775] registered
> [    6.202010] initcall v4l2_i2c_drv_init+0x0/0x94 returned 0 after 4=
882 usecs
> [    6.209008] calling  v4l2_i2c_drv_init+0x0/0x94 @ 1
> [    6.214124] i2c-core: driver [wm8739] registered
> [    6.218010] initcall v4l2_i2c_drv_init+0x0/0x94 returned 0 after 4=
882 usecs
> [    6.225008] calling  v4l2_i2c_drv_init+0x0/0x94 @ 1
> [    6.230764] i2c-core: driver [vp27smpx] registered
> [    6.235010] initcall v4l2_i2c_drv_init+0x0/0x94 returned 0 after 4=
882 usecs
> [    6.242008] calling  v4l2_i2c_drv_init+0x0/0x94 @ 1
> [    6.247608] i2c-core: driver [ovcamchip] registered
> [    6.252010] initcall v4l2_i2c_drv_init+0x0/0x94 returned 0 after 4=
882 usecs
> [    6.259023] calling  cpia2_init+0x0/0x56 @ 1
> [    6.263007] cpia2: V4L-Driver for Vision CPiA2 based cameras v2.0.=
0
> [    6.270207] usbcore: registered new interface driver cpia2
> [    6.275012] initcall cpia2_init+0x0/0x56 returned 0 after 11718 us=
ecs
> [    6.282008] calling  hexium_init_module+0x0/0x7e @ 1
> [    6.287007] saa7146: register extension 'hexium gemini'.
> [    6.292633] initcall hexium_init_module+0x0/0x7e returned 0 after =
4882 usecs
> [    6.299008] calling  v4l2_i2c_drv_init+0x0/0x94 @ 1
> [    6.304771] i2c-core: driver [cx25840] registered
> [    6.309010] initcall v4l2_i2c_drv_init+0x0/0x94 returned 0 after 4=
882 usecs
> [    6.316008] calling  v4l2_i2c_drv_init+0x0/0x94 @ 1
> [    6.321523] i2c-core: driver [upd64031a] registered
> [    6.326010] initcall v4l2_i2c_drv_init+0x0/0x94 returned 0 after 4=
882 usecs
> [    6.333010] calling  v4l2_i2c_drv_init+0x0/0x94 @ 1
> [    6.338438] i2c-core: driver [upd64083] registered
> [    6.343010] initcall v4l2_i2c_drv_init+0x0/0x94 returned 0 after 4=
882 usecs
> [    6.350008] calling  dabusb_init+0x0/0x11b @ 1
> [    6.354957] usbcore: registered new interface driver dabusb
> [    6.360012] dabusb: v1.54:DAB-USB Interface Driver for Linux (c)19=
99
> [    6.366008] initcall dabusb_init+0x0/0x11b returned 0 after 11718 =
usecs
> [    6.373008] calling  usb_ov511_init+0x0/0x5e @ 1
> [    6.378317] usbcore: registered new interface driver ov511
> [    6.383013] ov511: v1.64 for Linux 2.5:ov511 USB Camera Driver
> [    6.389009] initcall usb_ov511_init+0x0/0x5e returned 0 after 1074=
2 usecs
> [    6.396008] calling  usb_stv680_init+0x0/0x96 @ 1
> [    6.401340] usbcore: registered new interface driver stv680
> [    6.406011] stv680 [usb_stv680_init:1550]=20
> [    6.406012] STV(i): usb camera driver version v0.25 registering<6>=
stv680: v0.25:STV0680 USB Camera Driver
> [    6.420008] initcall usb_stv680_init+0x0/0x96 returned 0 after 185=
54 usecs
> [    6.427008] calling  zr364xx_init+0x0/0x65 @ 1
> [    6.432133] usbcore: registered new interface driver zr364xx
> [    6.437010] zr364xx: Zoran 364xx
> [    6.441008] initcall zr364xx_init+0x0/0x65 returned 0 after 9765 u=
secs
> [    6.447008] calling  usb_pwc_init+0x0/0x46b @ 1
> [    6.452007] pwc: Philips webcam module version 10.0.13 loaded.
> [    6.457006] pwc: Supports Philips PCA645/646, PCVC675/680/690, PCV=
C720[40]/730/740/750 & PCVC830/840.
> [    6.467006] pwc: Also supports the Askey VC010, various Logitech Q=
uickcams, Samsung MPC-C10 and MPC-C30,
> [    6.476006] pwc: the Creative WebCam 5 & Pro Ex, SOTEC Afina Eye a=
nd Visionite VCS-UC300 and VCS-UM100.
> [    6.486007] pwc: Trace options: 0x0001
> [    6.489940] usbcore: registered new interface driver Philips webca=
m
> [    6.496012] initcall usb_pwc_init+0x0/0x46b returned 0 after 42968=
 usecs
> [    6.502008] calling  zc0301_module_init+0x0/0x7e @ 1
> [    6.507007] zc0301: V4L2 driver for ZC0301[P] Image Processor and =
Control Chip v1:1.10
> [    6.516008] usbcore: registered new interface driver zc0301
> [    6.521025] initcall zc0301_module_init+0x0/0x7e returned 0 after =
13671 usecs
> [    6.528008] calling  gspca_init+0x0/0x47 @ 1
> [    6.533007] gspca: main v2.5.0 registered
> [    6.537008] initcall gspca_init+0x0/0x47 returned 0 after 3906 use=
cs
> [    6.543008] calling  sd_mod_init+0x0/0x61 @ 1
> [    6.547931] usbcore: registered new interface driver conex
> [    6.553010] conex: registered
> [    6.556008] initcall sd_mod_init+0x0/0x61 returned 0 after 8789 us=
ecs
> [    6.562008] calling  sd_mod_init+0x0/0x61 @ 1
> [    6.567402] usbcore: registered new interface driver etoms
> [    6.572010] etoms: registered
> [    6.575016] initcall sd_mod_init+0x0/0x61 returned 0 after 7812 us=
ecs
> [    6.582008] calling  sd_mod_init+0x0/0x61 @ 1
> [    6.586863] usbcore: registered new interface driver mars
> [    6.592010] mars: registered
> [    6.595008] initcall sd_mod_init+0x0/0x61 returned 0 after 8789 us=
ecs
> [    6.601008] calling  sd_mod_init+0x0/0x66 @ 1
> [    6.606147] usbcore: registered new interface driver mr97310a
> [    6.611010] mr97310a: registered
> [    6.615011] initcall sd_mod_init+0x0/0x66 returned 0 after 9765 us=
ecs
> [    6.621009] calling  sd_mod_init+0x0/0x61 @ 1
> [    6.626139] usbcore: registered new interface driver ov534
> [    6.631010] ov534: registered
> [    6.634008] initcall sd_mod_init+0x0/0x61 returned 0 after 8789 us=
ecs
> [    6.641008] calling  sd_mod_init+0x0/0x61 @ 1
> [    6.645593] usbcore: registered new interface driver pac7311
> [    6.651010] pac7311: registered
> [    6.654008] initcall sd_mod_init+0x0/0x61 returned 0 after 8789 us=
ecs
> [    6.660008] calling  sd_mod_init+0x0/0x61 @ 1
> [    6.665400] usbcore: registered new interface driver sonixb
> [    6.670010] sonixb: registered
> [    6.674008] initcall sd_mod_init+0x0/0x61 returned 0 after 8789 us=
ecs
> [    6.680008] calling  sd_mod_init+0x0/0x61 @ 1
> [    6.685052] usbcore: registered new interface driver spca500
> [    6.690010] spca500: registered
> [    6.693009] initcall sd_mod_init+0x0/0x61 returned 0 after 8789 us=
ecs
> [    6.700008] calling  sd_mod_init+0x0/0x61 @ 1
> [    6.704139] usbcore: registered new interface driver spca508
> [    6.710011] spca508: registered
> [    6.713009] initcall sd_mod_init+0x0/0x61 returned 0 after 8789 us=
ecs
> [    6.720008] calling  sd_mod_init+0x0/0x61 @ 1
> [    6.724678] usbcore: registered new interface driver sq905
> [    6.730010] sq905: registered
> [    6.733009] initcall sd_mod_init+0x0/0x61 returned 0 after 8789 us=
ecs
> [    6.739008] calling  sd_mod_init+0x0/0x61 @ 1
> [    6.744138] usbcore: registered new interface driver sq905c
> [    6.749010] sq905c: registered
> [    6.752009] initcall sd_mod_init+0x0/0x61 returned 0 after 8789 us=
ecs
> [    6.759008] calling  sd_mod_init+0x0/0x61 @ 1
> [    6.763768] usbcore: registered new interface driver t613
> [    6.769010] t613: registered
> [    6.772009] initcall sd_mod_init+0x0/0x61 returned 0 after 8789 us=
ecs
> [    6.778008] calling  sd_mod_init+0x0/0x61 @ 1
> [    6.783082] usbcore: registered new interface driver tv8532
> [    6.788010] tv8532: registered
> [    6.791008] initcall sd_mod_init+0x0/0x61 returned 0 after 8789 us=
ecs
> [    6.798008] calling  sd_mod_init+0x0/0x61 @ 1
> [    6.802733] usbcore: registered new interface driver vc032x
> [    6.808010] vc032x: registered
> [    6.811008] initcall sd_mod_init+0x0/0x61 returned 0 after 8789 us=
ecs
> [    6.817008] calling  sd_mod_init+0x0/0x61 @ 1
> [    6.822368] usbcore: registered new interface driver zc3xx
> [    6.827019] zc3xx: registered
> [    6.830009] initcall sd_mod_init+0x0/0x61 returned 0 after 7812 us=
ecs
> [    6.837008] calling  mod_m5602_init+0x0/0x61 @ 1
> [    6.842109] usbcore: registered new interface driver ALi m5602
> [    6.847011] ALi m5602: registered
> [    6.851009] initcall mod_m5602_init+0x0/0x61 returned 0 after 9765=
 usecs
> [    6.857009] calling  sd_mod_init+0x0/0x61 @ 1
> [    6.862513] usbcore: registered new interface driver STV06xx
> [    6.868011] STV06xx: registered
> [    6.871009] initcall sd_mod_init+0x0/0x61 returned 0 after 8789 us=
ecs
> [    6.877009] calling  hdpvr_init+0x0/0x60 @ 1
> [    6.882231] usbcore: registered new interface driver hdpvr
> [    6.887012] initcall hdpvr_init+0x0/0x60 returned 0 after 4882 use=
cs
> [    6.894022] calling  ibmcam_init+0x0/0xa9 @ 1
> [    6.898699] usbcore: registered new interface driver ibmcam
> [    6.904013] initcall ibmcam_init+0x0/0xa9 returned 0 after 5859 us=
ecs
> [    6.910008] calling  ultracam_init+0x0/0xa9 @ 1
> [    6.915495] usbcore: registered new interface driver ultracam
> [    6.921012] initcall ultracam_init+0x0/0xa9 returned 0 after 5859 =
usecs
> [    6.927015] calling  konicawc_init+0x0/0xbf @ 1
> [    6.932007] konicawc: v1.4:Konica Webcam driver
> [    6.937161] usbcore: registered new interface driver konicawc
> [    6.942012] initcall konicawc_init+0x0/0xbf returned 0 after 9765 =
usecs
> [    6.949008] calling  qcm_init+0x0/0x68 @ 1
> [    6.953007] quickcam_messenger: v0.01:Logitech Quickcam Messenger =
USB
> [    6.960282] usbcore: registered new interface driver QCM
> [    6.965012] initcall qcm_init+0x0/0x68 returned 0 after 11718 usec=
s
> [    6.971012] calling  module_start+0x0/0xc3 @ 1
> [    6.976007] ivtv: Start initialization, version 1.4.1
> [    6.981584] ivtv: End initialization
> [    6.985009] initcall module_start+0x0/0xc3 returned 0 after 8789 u=
secs
> [    6.991009] calling  vivi_init+0x0/0xa7 @ 1
> [    6.996371] vivi-000: V4L2 device registered as /dev/video0
> [    7.001009] Video Technology Magazine Virtual Video Capture Board =
ver 0.6.0 successfully loaded.
> [    7.010010] initcall vivi_init+0x0/0xa7 returned 0 after 14648 use=
cs
> [    7.017010] calling  cx23885_init+0x0/0x57 @ 1
> [    7.021008] cx23885 driver version 0.0.2 loaded
> [    7.026337] initcall cx23885_init+0x0/0x57 returned 0 after 4882 u=
secs
> [    7.032010] calling  maxiradio_radio_init+0x0/0x42 @ 1
> [    7.038285] initcall maxiradio_radio_init+0x0/0x42 returned 0 afte=
r 0 usecs
> [    7.045009] calling  gemtek_pci_init+0x0/0x42 @ 1
> [    7.050183] initcall gemtek_pci_init+0x0/0x42 returned 0 after 976=
 usecs
> [    7.056009] calling  maestro_radio_init+0x0/0x5e @ 1
> [    7.062101] initcall maestro_radio_init+0x0/0x5e returned 0 after =
976 usecs
> [    7.069009] calling  dsbr100_init+0x0/0x5a @ 1
> [    7.073719] usbcore: registered new interface driver dsbr100
> [    7.079011] dsbr100: v0.45:D-Link DSB-R100 USB FM radio driver
> [    7.085009] initcall dsbr100_init+0x0/0x5a returned 0 after 11718 =
usecs
> [    7.091009] calling  si470x_module_init+0x0/0x4e @ 1
> [    7.096007] USB radio driver for Si470x FM Radio Receivers, Versio=
n 1.0.9
> [    7.103785] usbcore: registered new interface driver radio-si470x
> [    7.109013] initcall si470x_module_init+0x0/0x4e returned 0 after =
12695 usecs
> [    7.117009] calling  amradio_init+0x0/0x6e @ 1
> [    7.121657] usbcore: registered new interface driver radio-mr800
> [    7.127011] radio_mr800: version 0.11 AverMedia MR 800 USB FM radi=
o driver
> [    7.134012] initcall amradio_init+0x0/0x6e returned 0 after 12695 =
usecs
> [    7.141009] calling  tea5764_init+0x0/0x53 @ 1
> [    7.145802] i2c-core: driver [radio-tea5764] registered
> [    7.151010] radio_tea5764: v0.01: A driver for the TEA5764 radio c=
hip for EZX Phones.
> [    7.158009] initcall tea5764_init+0x0/0x53 returned 0 after 12695 =
usecs
> [    7.165009] calling  v4l2_i2c_drv_init+0x0/0x94 @ 1
> [    7.170542] i2c-core: driver [au8522] registered
> [    7.175011] initcall v4l2_i2c_drv_init+0x0/0x94 returned 0 after 4=
882 usecs
> [    7.182009] calling  budget_init+0x0/0x39 @ 1
> [    7.186008] saa7146: register extension 'budget dvb'.
> [    7.191745] initcall budget_init+0x0/0x39 returned 0 after 4882 us=
ecs
> [    7.198009] calling  budget_ci_init+0x0/0x39 @ 1
> [    7.202008] saa7146: register extension 'budget_ci dvb'.
> [    7.208345] initcall budget_ci_init+0x0/0x39 returned 0 after 5859=
 usecs
> [    7.215009] calling  ttusb_init+0x0/0x6b @ 1
> [    7.219523] usbcore: registered new interface driver ttusb
> [    7.225013] initcall ttusb_init+0x0/0x6b returned 0 after 5859 use=
cs
> [    7.231010] calling  flexcop_module_init+0x0/0x3b @ 1
> [    7.236007] b2c2-flexcop: B2C2 FlexcopII/II(b)/III digital TV rece=
iver chip loaded successfully
> [    7.245009] initcall flexcop_module_init+0x0/0x3b returned 0 after=
 8789 usecs
> [    7.252009] calling  flexcop_usb_module_init+0x0/0x60 @ 1
> [    7.257853] usbcore: registered new interface driver b2c2_flexcop_=
usb
> [    7.264013] initcall flexcop_usb_module_init+0x0/0x60 returned 0 a=
fter 6835 usecs
> [    7.271009] calling  a800_module_init+0x0/0x60 @ 1
> [    7.276767] usbcore: registered new interface driver dvb_usb_a800
> [    7.282013] initcall a800_module_init+0x0/0x60 returned 0 after 58=
59 usecs
> [    7.289009] calling  dibusb_module_init+0x0/0x60 @ 1
> [    7.294900] usbcore: registered new interface driver dvb_usb_dibus=
b_mb
> [    7.301013] initcall dibusb_module_init+0x0/0x60 returned 0 after =
6835 usecs
> [    7.308009] calling  umt_module_init+0x0/0x60 @ 1
> [    7.313394] usbcore: registered new interface driver dvb_usb_umt_0=
10
> [    7.319013] initcall umt_module_init+0x0/0x60 returned 0 after 585=
9 usecs
> [    7.326009] calling  m920x_module_init+0x0/0x60 @ 1
> [    7.331612] usbcore: registered new interface driver dvb_usb_m920x
> [    7.337013] initcall m920x_module_init+0x0/0x60 returned 0 after 5=
859 usecs
> [    7.344009] calling  au6610_module_init+0x0/0x60 @ 1
> [    7.349920] usbcore: registered new interface driver dvb_usb_au661=
0
> [    7.356013] initcall au6610_module_init+0x0/0x60 returned 0 after =
6835 usecs
> [    7.363009] calling  cxusb_module_init+0x0/0x60 @ 1
> [    7.368332] usbcore: registered new interface driver dvb_usb_cxusb
> [    7.374013] initcall cxusb_module_init+0x0/0x60 returned 0 after 5=
859 usecs
> [    7.381009] calling  ttusb2_module_init+0x0/0x60 @ 1
> [    7.386639] usbcore: registered new interface driver dvb_usb_ttusb=
2
> [    7.392015] initcall ttusb2_module_init+0x0/0x60 returned 0 after =
5859 usecs
> [    7.399009] calling  opera1_module_init+0x0/0x60 @ 1
> [    7.405140] usbcore: registered new interface driver opera1
> [    7.410013] initcall opera1_module_init+0x0/0x60 returned 0 after =
5859 usecs
> [    7.417009] calling  anysee_module_init+0x0/0x67 @ 1
> [    7.422934] usbcore: registered new interface driver dvb_usb_anyse=
e
> [    7.429013] initcall anysee_module_init+0x0/0x67 returned 0 after =
6835 usecs
> [    7.436009] calling  dtv5100_module_init+0x0/0x60 @ 1
> [    7.441508] usbcore: registered new interface driver dvb_usb_dtv51=
00
> [    7.447013] initcall dtv5100_module_init+0x0/0x60 returned 0 after=
 5859 usecs
> [    7.455009] calling  af9015_usb_module_init+0x0/0x60 @ 1
> [    7.460522] usbcore: registered new interface driver dvb_usb_af901=
5
> [    7.466013] initcall af9015_usb_module_init+0x0/0x60 returned 0 af=
ter 5859 usecs
> [    7.474009] calling  cinergyt2_usb_init+0x0/0x60 @ 1
> [    7.479355] usbcore: registered new interface driver cinergyT2
> [    7.485013] initcall cinergyt2_usb_init+0x0/0x60 returned 0 after =
5859 usecs
> [    7.492009] calling  pluto2_init+0x0/0x42 @ 1
> [    7.496818] initcall pluto2_init+0x0/0x42 returned 0 after 0 usecs
> [    7.503010] calling  smscore_module_init+0x0/0xa5 @ 1
> [    7.508010] initcall smscore_module_init+0x0/0xa5 returned 0 after=
 0 usecs
> [    7.514010] calling  smsusb_module_init+0x0/0x8b @ 1
> [    7.520139] usbcore: registered new interface driver smsusb
> [    7.525014] initcall smsusb_module_init+0x0/0x8b returned 0 after =
5859 usecs
> [    7.532010] calling  smsdvb_module_init+0x0/0x91 @ 1
> [    7.537036] initcall smsdvb_module_init+0x0/0x91 returned 0 after =
0 usecs
> [    7.544010] calling  dm1105_init+0x0/0x42 @ 1
> [    7.549115] initcall dm1105_init+0x0/0x42 returned 0 after 976 use=
cs
> [    7.555010] calling  w1_init+0x0/0xc8 @ 1
> [    7.559007] Driver for 1-wire Dallas network protocol.
> [    7.565149] initcall w1_init+0x0/0xc8 returned 0 after 5859 usecs
> [    7.571029] calling  matrox_w1_init+0x0/0x42 @ 1
> [    7.576232] initcall matrox_w1_init+0x0/0x42 returned 0 after 0 us=
ecs
> [    7.582010] calling  sensors_ds2482_init+0x0/0x3b @ 1
> [    7.587984] i2c-core: driver [ds2482] registered
> [    7.592034] initcall sensors_ds2482_init+0x0/0x3b returned 0 after=
 4882 usecs
> [    7.599040] calling  w1_gpio_init+0x0/0x40 @ 1
> [    7.604458] initcall w1_gpio_init+0x0/0x40 returned -19 after 0 us=
ecs
> [    7.611010] calling  w1_smem_init+0x0/0x65 @ 1
> [    7.615047] initcall w1_smem_init+0x0/0x65 returned 0 after 0 usec=
s
> [    7.621009] calling  w1_f23_init+0x0/0x39 @ 1
> [    7.626010] initcall w1_f23_init+0x0/0x39 returned 0 after 0 usecs
> [    7.632009] calling  w1_ds2760_init+0x0/0x51 @ 1
> [    7.637008] 1-Wire driver for the DS2760 battery monitor  chip  - =
(c) 2004-2005, Szabolcs Gyurko
> [    7.645010] initcall w1_ds2760_init+0x0/0x51 returned 0 after 7812=
 usecs
> [    7.652013] calling  w1_bq27000_init+0x0/0x49 @ 1
> [    7.657010] initcall w1_bq27000_init+0x0/0x49 returned -17 after 0=
 usecs
> [    7.663009] initcall w1_bq27000_init+0x0/0x49 returned with error =
code -17=20
> [    7.670009] calling  ds2760_battery_init+0x0/0x39 @ 1
> [    7.676039] initcall ds2760_battery_init+0x0/0x39 returned 0 after=
 976 usecs
> [    7.683016] calling  bq27x00_battery_init+0x0/0x57 @ 1
> [    7.688515] i2c-core: driver [bq27200-battery] registered
> [    7.693012] initcall bq27x00_battery_init+0x0/0x57 returned 0 afte=
r 4882 usecs
> [    7.701033] calling  pcipcwd_init_module+0x0/0x5c @ 1
> [    7.706436] initcall pcipcwd_init_module+0x0/0x5c returned 0 after=
 0 usecs
> [    7.713010] calling  wdtpci_init+0x0/0x42 @ 1
> [    7.717943] initcall wdtpci_init+0x0/0x42 returned 0 after 0 usecs
> [    7.724010] calling  acq_init+0x0/0x83 @ 1
> [    7.728008] WDT driver for Acquire single board computer initialis=
ing.
> [    7.735176] acquirewdt: I/O address 0x0043 already in use
> [    7.740029] acquirewdt: probe of acquirewdt failed with error -5
> [    7.746012] initcall acq_init+0x0/0x83 returned 0 after 17578 usec=
s
> [    7.752009] calling  advwdt_init+0x0/0x83 @ 1
> [    7.757008] WDT driver for Advantech single board computer initial=
ising.
> [    7.764310] advantechwdt: initialized. timeout=3D60 sec (nowayout=3D=
0)
> [    7.770017] initcall advwdt_init+0x0/0x83 returned 0 after 13671 u=
secs
> [    7.777010] calling  sc520_wdt_init+0x0/0x114 @ 1
> [    7.782025] sc520_wdt: cannot register miscdev on minor=3D130 (err=
=3D-16)
> [    7.788024] initcall sc520_wdt_init+0x0/0x114 returned -16 after 5=
859 usecs
> [    7.795010] initcall sc520_wdt_init+0x0/0x114 returned with error =
code -16=20
> [    7.802009] calling  ibwdt_init+0x0/0x83 @ 1
> [    7.806008] ib700wdt: WDT driver for IB700 single board computer i=
nitialising.
> [    7.814325] ib700wdt: START method I/O 443 is not available.
> [    7.820026] ib700wdt: probe of ib700wdt failed with error -5
> [    7.825015] initcall ibwdt_init+0x0/0x83 returned 0 after 18554 us=
ecs
> [    7.832010] calling  wafwdt_init+0x0/0x18e @ 1
> [    7.836008] WDT driver for Wafer 5823 single board computer initia=
lising.
> [    7.843012] Wafer 5823 WDT: I/O address 0x0443 already in use
> [    7.849012] initcall wafwdt_init+0x0/0x18e returned -5 after 12695=
 usecs
> [    7.856010] initcall wafwdt_init+0x0/0x18e returned with error cod=
e -5=20
> [    7.862009] calling  watchdog_init+0x0/0x8a @ 1
> [    7.867008] i6300ESB timer: Intel 6300ESB WatchDog Timer Driver v0=
=2E04
> [    7.874104] initcall watchdog_init+0x0/0x8a returned 0 after 6835 =
usecs
> [    7.880010] calling  iTCO_wdt_init_module+0x0/0x8a @ 1
> [    7.885008] iTCO_wdt: Intel TCO WatchDog Timer Driver v1.05
> [    7.891633] iTCO_wdt: No card detected
> [    7.895025] initcall iTCO_wdt_init_module+0x0/0x8a returned 0 afte=
r 9765 usecs
> [    7.902010] calling  iTCO_vendor_init_module+0x0/0x41 @ 1
> [    7.908011] iTCO_vendor_support: vendor-support=3D0
> [    7.913010] initcall iTCO_vendor_init_module+0x0/0x41 returned 0 a=
fter 4882 usecs
> [    7.920009] calling  it87_wdt_init+0x0/0x4ee @ 1
> [    7.925066] IT87 WDT: Unsupported Chip found, Chip 8712 Revision 0=
7
> [    7.931010] initcall it87_wdt_init+0x0/0x4ee returned -19 after 58=
59 usecs
> [    7.938009] calling  hpwdt_init+0x0/0x42 @ 1
> [    7.942890] initcall hpwdt_init+0x0/0x42 returned 0 after 0 usecs
> [    7.949010] calling  sbc60xxwdt_init+0x0/0x1ab @ 1
> [    7.953013] sbc60xxwdt: I/O address 0x0443 already in use
> [    7.959010] initcall sbc60xxwdt_init+0x0/0x1ab returned -5 after 5=
859 usecs
> [    7.966010] initcall sbc60xxwdt_init+0x0/0x1ab returned with error=
 code -5=20
> [    7.973009] calling  sbc8360_init+0x0/0x1ca @ 1
> [    7.977011] sbc8360: failed to register misc device
> [    7.982014] initcall sbc8360_init+0x0/0x1ca returned -16 after 488=
2 usecs
> [    7.989010] initcall sbc8360_init+0x0/0x1ca returned with error co=
de -16=20
> [    7.996011] calling  cpu5wdt_init_module+0x0/0x32 @ 1
> [    8.001012] cpu5wdt: sorry, was my fault
> [    8.005008] cpu5wdt: misc_register failed
> [    8.009012] initcall cpu5wdt_init_module+0x0/0x32 returned -16 aft=
er 7812 usecs
> [    8.016010] initcall cpu5wdt_init_module+0x0/0x32 returned with er=
ror code -16=20
> [    8.023010] calling  sch311x_wdt_init+0x0/0x176 @ 1
> [    8.028028] initcall sch311x_wdt_init+0x0/0x176 returned -19 after=
 0 usecs
> [    8.035010] calling  wb_smsc_wdt_init+0x0/0x1de @ 1
> [    8.040008] SMsC 37B787 watchdog component driver 1.1 initialising=
=2E..
> [    8.047856] smsc37b787_wdt: Unable to register miscdev on minor 13=
0
> [    8.054013] initcall wb_smsc_wdt_init+0x0/0x1de returned -16 after=
 13671 usecs
> [    8.061010] initcall wb_smsc_wdt_init+0x0/0x1de returned with erro=
r code -16=20
> [    8.068009] calling  wdt_init+0x0/0x142 @ 1
> [    8.072008] WDT driver for the Winbond(TM) W83627HF/THF/HG Super I=
/O chip initialising.
> [    8.080027] w83627hf/thf/hg WDT: Watchdog already running. Resetti=
ng timeout to 60 sec
> [    8.088023] w83627hf/thf/hg WDT: cannot register miscdev on minor=3D=
130 (err=3D-16)
> [    8.095012] initcall wdt_init+0x0/0x142 returned -16 after 22460 u=
secs
> [    8.102010] initcall wdt_init+0x0/0x142 returned with error code -=
16=20
> [    8.108010] calling  w83877f_wdt_init+0x0/0x183 @ 1
> [    8.113013] w83877f_wdt: I/O address 0x0443 already in use
> [    8.119013] initcall w83877f_wdt_init+0x0/0x183 returned -5 after =
5859 usecs
> [    8.126010] initcall w83877f_wdt_init+0x0/0x183 returned with erro=
r code -5=20
> [    8.133010] calling  w83977f_wdt_init+0x0/0x16d @ 1
> [    8.138008] W83977F WDT: W83977F WDT driver, v1.00
> [    8.143010] W83977F WDT: cannot register miscdev on minor=3D130 (e=
rr=3D-16)
> [    8.149012] initcall w83977f_wdt_init+0x0/0x16d returned -16 after=
 10742 usecs
> [    8.156010] initcall w83977f_wdt_init+0x0/0x16d returned with erro=
r code -16=20
> [    8.163010] calling  zf_init+0x0/0x185 @ 1
> [    8.168009] machzwd: MachZ ZF-Logic Watchdog driver initializing.
> [    8.174009] machzwd: no ZF-Logic found
> [    8.177010] initcall zf_init+0x0/0x185 returned -19 after 8789 use=
cs
> [    8.184010] calling  watchdog_init+0x0/0xde @ 1
> [    8.188010] epx_c3: cannot register miscdev on minor=3D130 (err=3D=
-16)
> [    8.194013] initcall watchdog_init+0x0/0xde returned -16 after 683=
5 usecs
> [    8.201010] initcall watchdog_init+0x0/0xde returned with error co=
de -16=20
> [    8.208010] calling  linear_init+0x0/0x39 @ 1
> [    8.212019] md: linear personality registered for level -1
> [    8.218010] initcall linear_init+0x0/0x39 returned 0 after 5859 us=
ecs
> [    8.224010] calling  raid0_init+0x0/0x39 @ 1
> [    8.229009] md: raid0 personality registered for level 0
> [    8.234010] initcall raid0_init+0x0/0x39 returned 0 after 4882 use=
cs
> [    8.240010] calling  raid_init+0x0/0x39 @ 1
> [    8.244009] md: raid1 personality registered for level 1
> [    8.250010] initcall raid_init+0x0/0x39 returned 0 after 5859 usec=
s
> [    8.256010] calling  raid_init+0x0/0x39 @ 1
> [    8.260009] md: raid10 personality registered for level 10
> [    8.266010] initcall raid_init+0x0/0x39 returned 0 after 5859 usec=
s
> [    8.272010] calling  multipath_init+0x0/0x39 @ 1
> [    8.277009] md: multipath personality registered for level -4
> [    8.282010] initcall multipath_init+0x0/0x39 returned 0 after 4882=
 usecs
> [    8.289010] calling  dm_init+0x0/0x6f @ 1
> [    8.295316] device-mapper: uevent: version 1.0.3
> [    8.301192] device-mapper: ioctl: 4.14.0-ioctl (2008-04-23) initia=
lised: dm-devel@redhat.com
> [    8.309014] initcall dm_init+0x0/0x6f returned 0 after 15625 usecs
> [    8.315075] calling  dm_crypt_init+0x0/0x8f @ 1
> [    8.320845] initcall dm_crypt_init+0x0/0x8f returned 0 after 0 use=
cs
> [    8.327011] calling  dm_snapshot_init+0x0/0x240 @ 1
> [    8.333333] initcall dm_snapshot_init+0x0/0x240 returned 0 after 9=
76 usecs
> [    8.340023] calling  dm_mirror_init+0x0/0x9f @ 1
> [    8.345349] initcall dm_mirror_init+0x0/0x9f returned 0 after 976 =
usecs
> [    8.351011] calling  dm_dirty_log_init+0x0/0x7f @ 1
> [    8.356025] initcall dm_dirty_log_init+0x0/0x7f returned 0 after 0=
 usecs
> [    8.363010] calling  dm_zero_init+0x0/0x57 @ 1
> [    8.368011] initcall dm_zero_init+0x0/0x57 returned 0 after 0 usec=
s
> [    8.374010] calling  cpufreq_stats_init+0x0/0xd6 @ 1
> [    8.379025] initcall cpufreq_stats_init+0x0/0xd6 returned 0 after =
0 usecs
> [    8.386010] calling  cpufreq_gov_powersave_init+0x0/0x39 @ 1
> [    8.391011] initcall cpufreq_gov_powersave_init+0x0/0x39 returned =
0 after 0 usecs
> [    8.399010] calling  cpufreq_gov_dbs_init+0x0/0x8e @ 1
> [    8.404403] initcall cpufreq_gov_dbs_init+0x0/0x8e returned 0 afte=
r 0 usecs
> [    8.411011] calling  init_ladder+0x0/0x39 @ 1
> [    8.415025] cpuidle: using governor ladder
> [    8.419011] initcall init_ladder+0x0/0x39 returned 0 after 3906 us=
ecs
> [    8.426014] calling  init_menu+0x0/0x39 @ 1
> [    8.430009] cpuidle: using governor menu
> [    8.434011] initcall init_menu+0x0/0x39 returned 0 after 3906 usec=
s
> [    8.440010] calling  mmc_test_init+0x0/0x39 @ 1
> [    8.445437] initcall mmc_test_init+0x0/0x39 returned 0 after 0 use=
cs
> [    8.451011] calling  sdio_uart_init+0x0/0x11a @ 1
> [    8.456723] initcall sdio_uart_init+0x0/0x11a returned 0 after 0 u=
secs
> [    8.463011] calling  wbsd_drv_init+0x0/0xb5 @ 1
> [    8.467008] wbsd: Winbond W83L51xD SD/MMC card interface driver
> [    8.473008] wbsd: Copyright(c) Pierre Ossman
> [    8.478221] initcall wbsd_drv_init+0x0/0xb5 returned 0 after 10742=
 usecs
> [    8.485011] calling  tifm_sd_init+0x0/0x39 @ 1
> [    8.489950] initcall tifm_sd_init+0x0/0x39 returned 0 after 0 usec=
s
> [    8.496011] calling  mmc_spi_init+0x0/0x39 @ 1
> [    8.500861] initcall mmc_spi_init+0x0/0x39 returned 0 after 0 usec=
s
> [    8.507011] calling  memstick_init+0x0/0xab @ 1
> [    8.512147] initcall memstick_init+0x0/0xab returned 0 after 976 u=
secs
> [    8.518011] calling  jmb38x_ms_init+0x0/0x42 @ 1
> [    8.523534] initcall jmb38x_ms_init+0x0/0x42 returned 0 after 0 us=
ecs
> [    8.529011] calling  bd2802_init+0x0/0x3b @ 1
> [    8.534550] i2c-core: driver [BD2802] registered
> [    8.539014] initcall bd2802_init+0x0/0x3b returned 0 after 4882 us=
ecs
> [    8.545010] calling  pca9532_init+0x0/0x3b @ 1
> [    8.550260] i2c-core: driver [pca9532] registered
> [    8.554013] initcall pca9532_init+0x0/0x3b returned 0 after 3906 u=
secs
> [    8.561010] calling  heartbeat_trig_init+0x0/0x39 @ 1
> [    8.566056] initcall heartbeat_trig_init+0x0/0x39 returned 0 after=
 0 usecs
> [    8.573010] calling  bl_trig_init+0x0/0x39 @ 1
> [    8.577012] initcall bl_trig_init+0x0/0x39 returned 0 after 0 usec=
s
> [    8.584010] calling  gpio_trig_init+0x0/0x39 @ 1
> [    8.588012] initcall gpio_trig_init+0x0/0x39 returned 0 after 0 us=
ecs
> [    8.595010] calling  defon_trig_init+0x0/0x39 @ 1
> [    8.599012] initcall defon_trig_init+0x0/0x39 returned 0 after 0 u=
secs
> [    8.606010] calling  dcdbas_init+0x0/0x8d @ 1
> [    8.611151] dcdbas dcdbas: Dell Systems Management Base Driver (ve=
rsion 5.6.0-3.2)
> [    8.618015] initcall dcdbas_init+0x0/0x8d returned 0 after 7812 us=
ecs
> [    8.625011] calling  ibft_init+0x0/0x1e6 @ 1
> [    8.629025] No iBFT detected.
> [    8.632011] initcall ibft_init+0x0/0x1e6 returned 0 after 2929 use=
cs
> [    8.638010] calling  ioat_init_module+0x0/0x42 @ 1
> [    8.643968] initcall ioat_init_module+0x0/0x42 returned 0 after 0 =
usecs
> [    8.650011] calling  hid_init+0x0/0x55 @ 1
> [    8.654877] initcall hid_init+0x0/0x55 returned 0 after 0 usecs
> [    8.660011] calling  usb_mouse_init+0x0/0x5e @ 1
> [    8.665672] usbcore: registered new interface driver usbmouse
> [    8.671013] usbmouse: v1.6:USB HID Boot Protocol mouse driver
> [    8.677013] initcall usb_mouse_init+0x0/0x5e returned 0 after 1171=
8 usecs
> [    8.683013] calling  flow_cache_init+0x0/0x1d5 @ 1
> [    8.689166] initcall flow_cache_init+0x0/0x1d5 returned 0 after 97=
6 usecs
> [    8.695011] calling  pg_init+0x0/0x178 @ 1
> [    8.700017] pktgen v2.70: Packet Generator for packet performance =
testing.
> [    8.707114] initcall pg_init+0x0/0x178 returned 0 after 6835 usecs
> [    8.713011] calling  llc_init+0x0/0x47 @ 1
> [    8.717011] initcall llc_init+0x0/0x47 returned 0 after 0 usecs
> [    8.723010] calling  snap_init+0x0/0x61 @ 1
> [    8.727047] initcall snap_init+0x0/0x61 returned 0 after 0 usecs
> [    8.733010] calling  blackhole_module_init+0x0/0x39 @ 1
> [    8.738011] initcall blackhole_module_init+0x0/0x39 returned 0 aft=
er 0 usecs
> [    8.745010] calling  police_init_module+0x0/0x39 @ 1
> [    8.750021] initcall police_init_module+0x0/0x39 returned 0 after =
0 usecs
> [    8.757010] calling  gact_init_module+0x0/0x45 @ 1
> [    8.762009] GACT probability on
> [    8.765010] initcall gact_init_module+0x0/0x45 returned 0 after 29=
29 usecs
> [    8.772010] calling  pedit_init_module+0x0/0x39 @ 1
> [    8.777010] initcall pedit_init_module+0x0/0x39 returned 0 after 0=
 usecs
> [    8.784010] calling  simp_init_module+0x0/0x55 @ 1
> [    8.788009] Simple TC action Loaded
> [    8.792010] initcall simp_init_module+0x0/0x55 returned 0 after 39=
06 usecs
> [    8.799010] calling  cbq_module_init+0x0/0x39 @ 1
> [    8.803010] initcall cbq_module_init+0x0/0x39 returned 0 after 0 u=
secs
> [    8.810012] calling  htb_module_init+0x0/0x39 @ 1
> [    8.815011] initcall htb_module_init+0x0/0x39 returned 0 after 0 u=
secs
> [    8.821010] calling  red_module_init+0x0/0x39 @ 1
> [    8.826011] initcall red_module_init+0x0/0x39 returned 0 after 0 u=
secs
> [    8.832010] calling  gred_module_init+0x0/0x39 @ 1
> [    8.837011] initcall gred_module_init+0x0/0x39 returned 0 after 0 =
usecs
> [    8.844010] calling  ingress_module_init+0x0/0x39 @ 1
> [    8.849011] initcall ingress_module_init+0x0/0x39 returned 0 after=
 0 usecs
> [    8.856010] calling  dsmark_module_init+0x0/0x39 @ 1
> [    8.861011] initcall dsmark_module_init+0x0/0x39 returned 0 after =
0 usecs
> [    8.868010] calling  sfq_module_init+0x0/0x39 @ 1
> [    8.872011] initcall sfq_module_init+0x0/0x39 returned 0 after 0 u=
secs
> [    8.879010] calling  tbf_module_init+0x0/0x39 @ 1
> [    8.883011] initcall tbf_module_init+0x0/0x39 returned 0 after 0 u=
secs
> [    8.890010] calling  netem_module_init+0x0/0x45 @ 1
> [    8.895009] netem: version 1.2
> [    8.898011] initcall netem_module_init+0x0/0x45 returned 0 after 2=
929 usecs
> [    8.905010] calling  drr_init+0x0/0x39 @ 1
> [    8.909011] initcall drr_init+0x0/0x39 returned 0 after 0 usecs
> [    8.915010] calling  init_route4+0x0/0x39 @ 1
> [    8.919021] initcall init_route4+0x0/0x39 returned 0 after 0 usecs
> [    8.925010] calling  init_fw+0x0/0x39 @ 1
> [    8.929011] initcall init_fw+0x0/0x39 returned 0 after 0 usecs
> [    8.935010] calling  init_rsvp+0x0/0x39 @ 1
> [    8.939012] initcall init_rsvp+0x0/0x39 returned 0 after 0 usecs
> [    8.945010] calling  cls_flow_init+0x0/0x39 @ 1
> [    8.950011] initcall cls_flow_init+0x0/0x39 returned 0 after 0 use=
cs
> [    8.956010] calling  init_cgroup_cls+0x0/0x39 @ 1
> [    8.961011] initcall init_cgroup_cls+0x0/0x39 returned 0 after 0 u=
secs
> [    8.968011] calling  nfnetlink_init+0x0/0x86 @ 1
> [    8.972009] Netfilter messages via NETLINK v0.30.
> [    8.977058] initcall nfnetlink_init+0x0/0x86 returned 0 after 4882=
 usecs
> [    8.984011] calling  nfnetlink_log_init+0x0/0xfd @ 1
> [    8.989049] initcall nfnetlink_log_init+0x0/0xfd returned 0 after =
0 usecs
> [    8.995011] calling  nf_conntrack_standalone_init+0x0/0x39 @ 1
> [    9.001011] nf_conntrack version 0.5.0 (8191 buckets, 32764 max)
> [    9.008439] CONFIG_NF_CT_ACCT is deprecated and will be removed so=
on. Please use
> [    9.016011] nf_conntrack.acct=3D1 kernel paramater, acct=3D1 nf_co=
nntrack module option or
> [    9.024011] sysctl net.netfilter.nf_conntrack_acct=3D1 to enable i=
t.
> [    9.030068] initcall nf_conntrack_standalone_init+0x0/0x39 returne=
d 0 after 28320 usecs
> [    9.038011] calling  nf_conntrack_proto_dccp_init+0x0/0x94 @ 1
> [    9.044111] initcall nf_conntrack_proto_dccp_init+0x0/0x94 returne=
d 0 after 0 usecs
> [    9.051011] calling  nf_ct_proto_gre_init+0x0/0x6c @ 1
> [    9.057015] initcall nf_ct_proto_gre_init+0x0/0x6c returned 0 afte=
r 0 usecs
> [    9.064010] calling  nf_conntrack_proto_sctp_init+0x0/0x83 @ 1
> [    9.069016] initcall nf_conntrack_proto_sctp_init+0x0/0x83 returne=
d 0 after 0 usecs
> [    9.077010] calling  nf_conntrack_proto_udplite_init+0x0/0x69 @ 1
> [    9.083015] initcall nf_conntrack_proto_udplite_init+0x0/0x69 retu=
rned 0 after 0 usecs
> [    9.091010] calling  ctnetlink_init+0x0/0xf9 @ 1
> [    9.096009] ctnetlink v0.93: registering with nfnetlink.
> [    9.101032] initcall ctnetlink_init+0x0/0xf9 returned 0 after 4882=
 usecs
> [    9.108013] calling  nf_conntrack_irc_init+0x0/0x18e @ 1
> [    9.113028] initcall nf_conntrack_irc_init+0x0/0x18e returned 0 af=
ter 0 usecs
> [    9.120011] calling  nf_conntrack_netbios_ns_init+0x0/0x45 @ 1
> [    9.126012] initcall nf_conntrack_netbios_ns_init+0x0/0x45 returne=
d 0 after 0 usecs
> [    9.134011] calling  nf_conntrack_pptp_init+0x0/0x65 @ 1
> [    9.139012] initcall nf_conntrack_pptp_init+0x0/0x65 returned 0 af=
ter 0 usecs
> [    9.146011] calling  nf_conntrack_sane_init+0x0/0x1c1 @ 1
> [    9.152017] initcall nf_conntrack_sane_init+0x0/0x1c1 returned 0 a=
fter 0 usecs
> [    9.159011] calling  nf_conntrack_tftp_init+0x0/0x1a2 @ 1
> [    9.164012] initcall nf_conntrack_tftp_init+0x0/0x1a2 returned 0 a=
fter 0 usecs
> [    9.171010] calling  xt_init+0x0/0x172 @ 1
> [    9.176016] initcall xt_init+0x0/0x172 returned 0 after 976 usecs
> [    9.182011] calling  tcpudp_mt_init+0x0/0x3e @ 1
> [    9.186027] initcall tcpudp_mt_init+0x0/0x3e returned 0 after 0 us=
ecs
> [    9.193011] calling  connmark_tg_init+0x0/0x3e @ 1
> [    9.197015] initcall connmark_tg_init+0x0/0x3e returned 0 after 0 =
usecs
> [    9.204011] calling  dscp_tg_init+0x0/0x3e @ 1
> [    9.209014] initcall dscp_tg_init+0x0/0x3e returned 0 after 0 usec=
s
> [    9.215011] calling  hl_tg_init+0x0/0x3e @ 1
> [    9.219012] initcall hl_tg_init+0x0/0x3e returned 0 after 0 usecs
> [    9.225011] calling  led_tg_init+0x0/0x39 @ 1
> [    9.230011] initcall led_tg_init+0x0/0x39 returned 0 after 0 usecs
> [    9.236011] calling  mark_tg_init+0x0/0x3e @ 1
> [    9.240013] initcall mark_tg_init+0x0/0x3e returned 0 after 0 usec=
s
> [    9.246011] calling  nflog_tg_init+0x0/0x39 @ 1
> [    9.251011] initcall nflog_tg_init+0x0/0x39 returned 0 after 0 use=
cs
> [    9.257011] calling  nfqueue_tg_init+0x0/0x3e @ 1
> [    9.262013] initcall nfqueue_tg_init+0x0/0x3e returned 0 after 0 u=
secs
> [    9.269011] calling  notrack_tg_init+0x0/0x39 @ 1
> [    9.273012] initcall notrack_tg_init+0x0/0x39 returned 0 after 0 u=
secs
> [    9.280011] calling  xt_rateest_tg_init+0x0/0x64 @ 1
> [    9.285017] initcall xt_rateest_tg_init+0x0/0x64 returned 0 after =
0 usecs
> [    9.292011] calling  tcpmss_tg_init+0x0/0x3e @ 1
> [    9.296012] initcall tcpmss_tg_init+0x0/0x3e returned 0 after 0 us=
ecs
> [    9.303011] calling  tcpoptstrip_tg_init+0x0/0x3e @ 1
> [    9.308012] initcall tcpoptstrip_tg_init+0x0/0x3e returned 0 after=
 0 usecs
> [    9.315011] calling  trace_tg_init+0x0/0x39 @ 1
> [    9.319011] initcall trace_tg_init+0x0/0x39 returned 0 after 0 use=
cs
> [    9.325011] calling  xt_cluster_mt_init+0x0/0x39 @ 1
> [    9.330012] initcall xt_cluster_mt_init+0x0/0x39 returned 0 after =
0 usecs
> [    9.337011] calling  comment_mt_init+0x0/0x39 @ 1
> [    9.342012] initcall comment_mt_init+0x0/0x39 returned 0 after 0 u=
secs
> [    9.348011] calling  connbytes_mt_init+0x0/0x39 @ 1
> [    9.353012] initcall connbytes_mt_init+0x0/0x39 returned 0 after 0=
 usecs
> [    9.360011] calling  connlimit_mt_init+0x0/0x39 @ 1
> [    9.365012] initcall connlimit_mt_init+0x0/0x39 returned 0 after 0=
 usecs
> [    9.372011] calling  connmark_mt_init+0x0/0x3e @ 1
> [    9.376012] initcall connmark_mt_init+0x0/0x3e returned 0 after 0 =
usecs
> [    9.383011] calling  dccp_mt_init+0x0/0x7a @ 1
> [    9.387018] initcall dccp_mt_init+0x0/0x7a returned 0 after 0 usec=
s
> [    9.394011] calling  esp_mt_init+0x0/0x3e @ 1
> [    9.398012] initcall esp_mt_init+0x0/0x3e returned 0 after 0 usecs
> [    9.404011] calling  hl_mt_init+0x0/0x3e @ 1
> [    9.409012] initcall hl_mt_init+0x0/0x3e returned 0 after 0 usecs
> [    9.415011] calling  length_mt_init+0x0/0x3e @ 1
> [    9.419012] initcall length_mt_init+0x0/0x3e returned 0 after 0 us=
ecs
> [    9.426011] calling  multiport_mt_init+0x0/0x3e @ 1
> [    9.431013] initcall multiport_mt_init+0x0/0x3e returned 0 after 0=
 usecs
> [    9.437011] calling  physdev_mt_init+0x0/0x39 @ 1
> [    9.442012] initcall physdev_mt_init+0x0/0x39 returned 0 after 0 u=
secs
> [    9.449011] calling  policy_mt_init+0x0/0x3e @ 1
> [    9.453013] initcall policy_mt_init+0x0/0x3e returned 0 after 0 us=
ecs
> [    9.460011] calling  sctp_mt_init+0x0/0x3e @ 1
> [    9.464012] initcall sctp_mt_init+0x0/0x3e returned 0 after 0 usec=
s
> [    9.470011] calling  statistic_mt_init+0x0/0x39 @ 1
> [    9.475012] initcall statistic_mt_init+0x0/0x39 returned 0 after 0=
 usecs
> [    9.482011] calling  string_mt_init+0x0/0x3e @ 1
> [    9.486012] initcall string_mt_init+0x0/0x3e returned 0 after 0 us=
ecs
> [    9.493011] calling  time_mt_init+0x0/0x74 @ 1
> [    9.497010] xt_time: kernel timezone is -0000
> [    9.502012] initcall time_mt_init+0x0/0x74 returned 0 after 4882 u=
secs
> [    9.508011] calling  u32_mt_init+0x0/0x39 @ 1
> [    9.513012] initcall u32_mt_init+0x0/0x39 returned 0 after 0 usecs
> [    9.519011] calling  ip_vs_init+0x0/0xe3 @ 1
> [    9.523134] IPVS: Registered protocols (AH, ESP)
> [    9.528754] IPVS: Connection hash table configured (size=3D4096, m=
emory=3D64Kbytes)
> [    9.536089] IPVS: ipvs loaded.
> [    9.539012] initcall ip_vs_init+0x0/0xe3 returned 0 after 15625 us=
ecs
> [    9.545011] calling  ip_vs_wrr_init+0x0/0x39 @ 1
> [    9.550021] IPVS: [wrr] scheduler registered.
> [    9.554011] initcall ip_vs_wrr_init+0x0/0x39 returned 0 after 3906=
 usecs
> [    9.561011] calling  ip_vs_wlc_init+0x0/0x39 @ 1
> [    9.565010] IPVS: [wlc] scheduler registered.
> [    9.570011] initcall ip_vs_wlc_init+0x0/0x39 returned 0 after 4882=
 usecs
> [    9.577011] calling  ip_vs_lblcr_init+0x0/0x6d @ 1
> [    9.581020] IPVS: [lblcr] scheduler registered.
> [    9.586011] initcall ip_vs_lblcr_init+0x0/0x6d returned 0 after 48=
82 usecs
> [    9.593011] calling  ip_vs_sh_init+0x0/0x39 @ 1
> [    9.597010] IPVS: [sh] scheduler registered.
> [    9.602011] initcall ip_vs_sh_init+0x0/0x39 returned 0 after 4882 =
usecs
> [    9.608011] calling  ip_vs_sed_init+0x0/0x39 @ 1
> [    9.613010] IPVS: [sed] scheduler registered.
> [    9.617011] initcall ip_vs_sed_init+0x0/0x39 returned 0 after 3906=
 usecs
> [    9.624011] calling  ip_vs_nq_init+0x0/0x39 @ 1
> [    9.628012] IPVS: [nq] scheduler registered.
> [    9.633011] initcall ip_vs_nq_init+0x0/0x39 returned 0 after 4882 =
usecs
> [    9.639012] calling  sysctl_ipv4_init+0x0/0x74 @ 1
> [    9.644029] initcall sysctl_ipv4_init+0x0/0x74 returned 0 after 0 =
usecs
> [    9.651011] calling  ipip_init+0x0/0x95 @ 1
> [    9.655010] IPv4 over IPv4 tunneling driver
> [    9.660020] initcall ipip_init+0x0/0x95 returned 0 after 4882 usec=
s
> [    9.666011] calling  ipgre_init+0x0/0xd7 @ 1
> [    9.670009] GRE over IPv4 tunneling driver
> [    9.675113] initcall ipgre_init+0x0/0xd7 returned 0 after 4882 use=
cs
> [    9.681012] calling  init_syncookies+0x0/0x40 @ 1
> [    9.686043] initcall init_syncookies+0x0/0x40 returned 0 after 0 u=
secs
> [    9.692011] calling  esp4_init+0x0/0x8f @ 1
> [    9.696014] initcall esp4_init+0x0/0x8f returned 0 after 0 usecs
> [    9.702032] calling  xfrm4_beet_init+0x0/0x3e @ 1
> [    9.707012] initcall xfrm4_beet_init+0x0/0x3e returned 0 after 0 u=
secs
> [    9.714015] calling  tunnel4_init+0x0/0x8f @ 1
> [    9.718012] initcall tunnel4_init+0x0/0x8f returned 0 after 0 usec=
s
> [    9.724011] calling  xfrm4_mode_tunnel_init+0x0/0x3e @ 1
> [    9.730012] initcall xfrm4_mode_tunnel_init+0x0/0x3e returned 0 af=
ter 0 usecs
> [    9.737012] calling  ipv4_netfilter_init+0x0/0x39 @ 1
> [    9.742030] initcall ipv4_netfilter_init+0x0/0x39 returned 0 after=
 0 usecs
> [    9.749012] calling  nf_conntrack_l3proto_ipv4_init+0x0/0x153 @ 1
> [    9.755033] initcall nf_conntrack_l3proto_ipv4_init+0x0/0x153 retu=
rned 0 after 0 usecs
> [    9.763013] calling  nf_defrag_init+0x0/0x3e @ 1
> [    9.767013] initcall nf_defrag_init+0x0/0x3e returned 0 after 0 us=
ecs
> [    9.774012] calling  arp_tables_init+0x0/0xb3 @ 1
> [    9.779041] arp_tables: (C) 2002 David S. Miller
> [    9.783012] initcall arp_tables_init+0x0/0xb3 returned 0 after 390=
6 usecs
> [    9.790011] calling  arpt_mangle_init+0x0/0x39 @ 1
> [    9.795012] initcall arpt_mangle_init+0x0/0x39 returned 0 after 0 =
usecs
> [    9.801011] calling  arptable_filter_init+0x0/0x6a @ 1
> [    9.807037] initcall arptable_filter_init+0x0/0x6a returned 0 afte=
r 0 usecs
> [    9.814012] calling  ip_queue_init+0x0/0x162 @ 1
> [    9.818066] initcall ip_queue_init+0x0/0x162 returned 0 after 0 us=
ecs
> [    9.825012] calling  inet_diag_init+0x0/0x94 @ 1
> [    9.829031] initcall inet_diag_init+0x0/0x94 returned 0 after 0 us=
ecs
> [    9.836012] calling  tcp_diag_init+0x0/0x39 @ 1
> [    9.840024] initcall tcp_diag_init+0x0/0x39 returned 0 after 0 use=
cs
> [    9.847012] calling  cubictcp_register+0x0/0x88 @ 1
> [    9.852011] TCP cubic registered
> [    9.855012] initcall cubictcp_register+0x0/0x88 returned 0 after 2=
929 usecs
> [    9.862012] calling  xfrm_user_init+0x0/0x71 @ 1
> [    9.866010] Initializing XFRM netlink socket
> [    9.871041] initcall xfrm_user_init+0x0/0x71 returned 0 after 4882=
 usecs
> [    9.877012] calling  inet6_init+0x0/0x300 @ 1
> [    9.884278] NET: Registered protocol family 10
> [    9.891265] lo: Disabled Privacy Extensions
> [    9.896558] tunl0: Disabled Privacy Extensions
> [    9.901350] initcall inet6_init+0x0/0x300 returned 0 after 18554 u=
secs
> [    9.907013] calling  tunnel6_init+0x0/0x8f @ 1
> [    9.912012] initcall tunnel6_init+0x0/0x8f returned 0 after 0 usec=
s
> [    9.918011] calling  mip6_init+0x0/0xe1 @ 1
> [    9.922009] Mobile IPv6
> [    9.925013] initcall mip6_init+0x0/0xe1 returned 0 after 2929 usec=
s
> [    9.931012] calling  ip6_tables_init+0x0/0xd5 @ 1
> [    9.936050] ip6_tables: (C) 2000-2006 Netfilter Core Team
> [    9.941012] initcall ip6_tables_init+0x0/0xd5 returned 0 after 488=
2 usecs
> [    9.948012] calling  ip6table_mangle_init+0x0/0x6a @ 1
> [    9.953046] initcall ip6table_mangle_init+0x0/0x6a returned 0 afte=
r 0 usecs
> [    9.960012] calling  ip6_queue_init+0x0/0x162 @ 1
> [    9.965050] initcall ip6_queue_init+0x0/0x162 returned 0 after 0 u=
secs
> [    9.971016] calling  ip6table_raw_init+0x0/0x6a @ 1
> [    9.976032] initcall ip6table_raw_init+0x0/0x6a returned 0 after 0=
 usecs
> [    9.983017] calling  nf_conntrack_l3proto_ipv6_init+0x0/0x140 @ 1
> [    9.989051] initcall nf_conntrack_l3proto_ipv6_init+0x0/0x140 retu=
rned 0 after 0 usecs
> [    9.997012] calling  frag_mt6_init+0x0/0x39 @ 1
> [   10.002013] initcall frag_mt6_init+0x0/0x39 returned 0 after 0 use=
cs
> [   10.008012] calling  hbh_mt6_init+0x0/0x3e @ 1
> [   10.012013] initcall hbh_mt6_init+0x0/0x3e returned 0 after 0 usec=
s
> [   10.019012] calling  rt_mt6_init+0x0/0x39 @ 1
> [   10.023013] initcall rt_mt6_init+0x0/0x39 returned 0 after 0 usecs
> [   10.029012] calling  log_tg6_init+0x0/0x50 @ 1
> [   10.034014] initcall log_tg6_init+0x0/0x50 returned 0 after 0 usec=
s
> [   10.040012] calling  ip6_tunnel_init+0x0/0xc8 @ 1
> [   10.045468] ip6tnl0: Disabled Privacy Extensions
> [   10.050095] initcall ip6_tunnel_init+0x0/0xc8 returned 0 after 488=
2 usecs
> [   10.057012] calling  packet_init+0x0/0x6d @ 1
> [   10.061012] NET: Registered protocol family 17
> [   10.065052] initcall packet_init+0x0/0x6d returned 0 after 3906 us=
ecs
> [   10.072012] calling  ipsec_pfkey_init+0x0/0xac @ 1
> [   10.077011] NET: Registered protocol family 15
> [   10.081026] initcall ipsec_pfkey_init+0x0/0xac returned 0 after 39=
06 usecs
> [   10.088012] calling  br_init+0x0/0x100 @ 1
> [   10.093144] Bridge firewalling registered
> [   10.097036] initcall br_init+0x0/0x100 returned 0 after 4882 usecs
> [   10.103023] calling  ebtables_init+0x0/0x77 @ 1
> [   10.107012] Ebtables v2.0 registered
> [   10.111012] initcall ebtables_init+0x0/0x77 returned 0 after 3906 =
usecs
> [   10.118012] calling  ebtable_broute_init+0x0/0x4a @ 1
> [   10.123050] initcall ebtable_broute_init+0x0/0x4a returned 0 after=
 0 usecs
> [   10.130012] calling  ebtable_filter_init+0x0/0x6a @ 1
> [   10.135030] initcall ebtable_filter_init+0x0/0x6a returned 0 after=
 0 usecs
> [   10.142012] calling  ebtable_nat_init+0x0/0x6a @ 1
> [   10.146033] initcall ebtable_nat_init+0x0/0x6a returned 0 after 0 =
usecs
> [   10.153013] calling  ebt_802_3_init+0x0/0x39 @ 1
> [   10.158013] initcall ebt_802_3_init+0x0/0x39 returned 0 after 0 us=
ecs
> [   10.164012] calling  ebt_arp_init+0x0/0x39 @ 1
> [   10.168013] initcall ebt_arp_init+0x0/0x39 returned 0 after 0 usec=
s
> [   10.175012] calling  ebt_ip_init+0x0/0x39 @ 1
> [   10.179013] initcall ebt_ip_init+0x0/0x39 returned 0 after 0 usecs
> [   10.185012] calling  ebt_ip6_init+0x0/0x39 @ 1
> [   10.190013] initcall ebt_ip6_init+0x0/0x39 returned 0 after 0 usec=
s
> [   10.196012] calling  ebt_limit_init+0x0/0x39 @ 1
> [   10.201013] initcall ebt_limit_init+0x0/0x39 returned 0 after 0 us=
ecs
> [   10.207012] calling  ebt_mark_m_init+0x0/0x39 @ 1
> [   10.212013] initcall ebt_mark_m_init+0x0/0x39 returned 0 after 0 u=
secs
> [   10.218012] calling  ebt_pkttype_init+0x0/0x39 @ 1
> [   10.223013] initcall ebt_pkttype_init+0x0/0x39 returned 0 after 0 =
usecs
> [   10.230015] calling  ebt_dnat_init+0x0/0x39 @ 1
> [   10.234013] initcall ebt_dnat_init+0x0/0x39 returned 0 after 0 use=
cs
> [   10.241012] calling  ebt_redirect_init+0x0/0x39 @ 1
> [   10.245013] initcall ebt_redirect_init+0x0/0x39 returned 0 after 0=
 usecs
> [   10.252012] calling  ebt_snat_init+0x0/0x39 @ 1
> [   10.257013] initcall ebt_snat_init+0x0/0x39 returned 0 after 0 use=
cs
> [   10.263012] calling  ebt_log_init+0x0/0x50 @ 1
> [   10.268014] initcall ebt_log_init+0x0/0x50 returned 0 after 0 usec=
s
> [   10.274012] calling  ebt_nflog_init+0x0/0x39 @ 1
> [   10.278013] initcall ebt_nflog_init+0x0/0x39 returned 0 after 0 us=
ecs
> [   10.285012] calling  dsa_init_module+0x0/0x3b @ 1
> [   10.290013] initcall dsa_init_module+0x0/0x3b returned 0 after 0 u=
secs
> [   10.296012] calling  edsa_init_module+0x0/0x3b @ 1
> [   10.301013] initcall edsa_init_module+0x0/0x3b returned 0 after 0 =
usecs
> [   10.307012] calling  trailer_init_module+0x0/0x3b @ 1
> [   10.313013] initcall trailer_init_module+0x0/0x3b returned 0 after=
 0 usecs
> [   10.319012] calling  mv88e6060_init+0x0/0x3b @ 1
> [   10.324024] initcall mv88e6060_init+0x0/0x3b returned 0 after 0 us=
ecs
> [   10.330012] calling  mv88e6123_61_65_init+0x0/0x3b @ 1
> [   10.336013] initcall mv88e6123_61_65_init+0x0/0x3b returned 0 afte=
r 0 usecs
> [   10.343012] calling  mv88e6131_init+0x0/0x3b @ 1
> [   10.347013] initcall mv88e6131_init+0x0/0x3b returned 0 after 0 us=
ecs
> [   10.354011] calling  dsa_init_module+0x0/0x39 @ 1
> [   10.359119] initcall dsa_init_module+0x0/0x39 returned 0 after 976=
 usecs
> [   10.365012] calling  atalk_init+0x0/0xb3 @ 1
> [   10.370011] NET: Registered protocol family 5
> [   10.382069] initcall atalk_init+0x0/0xb3 returned 0 after 11718 us=
ecs
> [   10.388012] calling  ircomm_init+0x0/0xc1 @ 1
> [   10.392031] IrCOMM protocol (Dag Brattli)
> [   10.396012] initcall ircomm_init+0x0/0xc1 returned 0 after 3906 us=
ecs
> [   10.403011] calling  ircomm_tty_init+0x0/0x15a @ 1
> [   10.425488] initcall ircomm_tty_init+0x0/0x15a returned 0 after 16=
601 usecs
> [   10.432037] calling  init_sunrpc+0x0/0x83 @ 1
> [   10.438430] RPC: Registered udp transport module.
> [   10.443022] RPC: Registered tcp transport module.
> [   10.448015] initcall init_sunrpc+0x0/0x83 returned 0 after 10742 u=
secs
> [   10.454012] calling  init_rpcsec_gss+0x0/0x73 @ 1
> [   10.459081] initcall init_rpcsec_gss+0x0/0x73 returned 0 after 0 u=
secs
> [   10.465013] calling  init_kerberos_module+0x0/0x55 @ 1
> [   10.471053] initcall init_kerberos_module+0x0/0x55 returned 0 afte=
r 0 usecs
> [   10.478012] calling  init_spkm3_module+0x0/0x55 @ 1
> [   10.482018] initcall init_spkm3_module+0x0/0x55 returned 0 after 0=
 usecs
> [   10.489015] calling  decnet_init+0x0/0xb4 @ 1
> [   10.494011] NET4: DECnet for Linux: V.2.5.68s (C) 1995-2003 Linux =
DECnet Project Team
> [   10.503243] DECnet: Routing cache hash table of 1024 buckets, 56Kb=
ytes
> [   10.510288] NET: Registered protocol family 12
> [   10.514038] initcall decnet_init+0x0/0xb4 returned 0 after 19531 u=
secs
> [   10.521012] calling  phonet_init+0x0/0x9e @ 1
> [   10.525068] NET: Registered protocol family 35
> [   10.530559] initcall phonet_init+0x0/0x9e returned 0 after 4882 us=
ecs
> [   10.537013] calling  pep_register+0x0/0x3e @ 1
> [   10.541920] initcall pep_register+0x0/0x3e returned 0 after 0 usec=
s
> [   10.548013] calling  vlan_proto_init+0x0/0xdb @ 1
> [   10.552011] 802.1Q VLAN Support v1.8 Ben Greear <greearb@candelate=
ch.com>
> [   10.559010] All bugs added by David S. Miller <davem@redhat.com>
> [   10.565055] initcall vlan_proto_init+0x0/0xdb returned 0 after 126=
95 usecs
> [   10.572012] calling  dccp_init+0x0/0x3e6 @ 1
> [   10.583293] CCID: Activated CCID 2 (TCP-like)
> [   10.588446] CCID: Activated CCID 3 (TCP-Friendly Rate Control)
> [   10.594017] initcall dccp_init+0x0/0x3e6 returned 0 after 17578 us=
ecs
> [   10.601049] calling  dccp_v4_init+0x0/0xae @ 1
> [   10.611112] initcall dccp_v4_init+0x0/0xae returned 0 after 5859 u=
secs
> [   10.617013] calling  dccp_v6_init+0x0/0xae @ 1
> [   10.623259] initcall dccp_v6_init+0x0/0xae returned 0 after 976 us=
ecs
> [   10.629020] calling  dccp_diag_init+0x0/0x39 @ 1
> [   10.634013] initcall dccp_diag_init+0x0/0x39 returned 0 after 0 us=
ecs
> [   10.640011] calling  sctp_init+0x0/0x75b @ 1
> [   10.648245] SCTP: Hash tables configured (established 18724 bind 1=
8724)
> [   10.663330] sctp_init_sock(sk: ffff88003cc28000)
> [   10.668041] initcall sctp_init+0x0/0x75b returned 0 after 22460 us=
ecs
> [   10.674013] calling  lib80211_init+0x0/0x45 @ 1
> [   10.679011] lib80211: common routines for IEEE802.11 drivers
> [   10.684087] lib80211_crypt: registered algorithm 'NULL'
> [   10.690012] initcall lib80211_init+0x0/0x45 returned 0 after 10742=
 usecs
> [   10.696012] calling  lib80211_crypto_wep_init+0x0/0x39 @ 1
> [   10.702016] lib80211_crypt: registered algorithm 'WEP'
> [   10.707015] initcall lib80211_crypto_wep_init+0x0/0x39 returned 0 =
after 4882 usecs
> [   10.714012] calling  lib80211_crypto_ccmp_init+0x0/0x39 @ 1
> [   10.720012] lib80211_crypt: registered algorithm 'CCMP'
> [   10.725012] initcall lib80211_crypto_ccmp_init+0x0/0x39 returned 0=
 after 4882 usecs
> [   10.733012] calling  lib80211_crypto_tkip_init+0x0/0x39 @ 1
> [   10.739012] lib80211_crypt: registered algorithm 'TKIP'
> [   10.744012] initcall lib80211_crypto_tkip_init+0x0/0x39 returned 0=
 after 4882 usecs
> [   10.751016] calling  rfkill_handler_init+0x0/0x6b @ 1
> [   10.756016] initcall rfkill_handler_init+0x0/0x6b returned 0 after=
 0 usecs
> [   10.763012] calling  dcbnl_init+0x0/0x59 @ 1
> [   10.768013] initcall dcbnl_init+0x0/0x59 returned 0 after 0 usecs
> [   10.774012] calling  wimax_subsys_init+0x0/0x220 @ 1
> [   10.783081] initcall wimax_subsys_init+0x0/0x220 returned 0 after =
3906 usecs
> [   10.790014] calling  cpufreq_p4_init+0x0/0x82 @ 1
> [   10.794019] initcall cpufreq_p4_init+0x0/0x82 returned -19 after 0=
 usecs
> [   10.801012] calling  update_mp_table+0x0/0x245 @ 1
> [   10.806013] initcall update_mp_table+0x0/0x245 returned 0 after 0 =
usecs
> [   10.812013] calling  lapic_insert_resource+0x0/0x67 @ 1
> [   10.818015] initcall lapic_insert_resource+0x0/0x67 returned 0 aft=
er 0 usecs
> [   10.825012] calling  init_lapic_nmi_sysfs+0x0/0x60 @ 1
> [   10.830012] initcall init_lapic_nmi_sysfs+0x0/0x60 returned 0 afte=
r 0 usecs
> [   10.837012] calling  ioapic_insert_resources+0x0/0x81 @ 1
> [   10.842013] initcall ioapic_insert_resources+0x0/0x81 returned 0 a=
fter 0 usecs
> [   10.849012] calling  io_apic_bug_finalize+0x0/0x42 @ 1
> [   10.855013] initcall io_apic_bug_finalize+0x0/0x42 returned 0 afte=
r 0 usecs
> [   10.862013] calling  check_early_ioremap_leak+0x0/0x8e @ 1
> [   10.867012] initcall check_early_ioremap_leak+0x0/0x8e returned 0 =
after 0 usecs
> [   10.874012] calling  pat_memtype_list_init+0x0/0x50 @ 1
> [   10.880052] initcall pat_memtype_list_init+0x0/0x50 returned 0 aft=
er 0 usecs
> [   10.887015] calling  init_oops_id+0x0/0x58 @ 1
> [   10.891017] initcall init_oops_id+0x0/0x58 returned 0 after 0 usec=
s
> [   10.897013] calling  disable_boot_consoles+0x0/0x5f @ 1
> [   10.903013] initcall disable_boot_consoles+0x0/0x5f returned 0 aft=
er 0 usecs
> [   10.910013] calling  pm_qos_power_init+0x0/0xf0 @ 1
> [   10.916099] initcall pm_qos_power_init+0x0/0xf0 returned 0 after 9=
76 usecs
> [   10.922017] calling  taskstats_init+0x0/0xbe @ 1
> [   10.927061] registered taskstats version 1
> [   10.931012] initcall taskstats_init+0x0/0xbe returned 0 after 3906=
 usecs
> [   10.938013] calling  fail_io_timeout_debugfs+0x0/0x32 @ 1
> [   10.943013] initcall fail_io_timeout_debugfs+0x0/0x32 returned -19=
 after 0 usecs
> [   10.951013] calling  random32_reseed+0x0/0xce @ 1
> [   10.955026] initcall random32_reseed+0x0/0xce returned 0 after 0 u=
secs
> [   10.962012] calling  pci_resource_alignment_sysfs_init+0x0/0x40 @ =
1
> [   10.968031] initcall pci_resource_alignment_sysfs_init+0x0/0x40 re=
turned 0 after 0 usecs
> [   10.976012] calling  pci_sysfs_init+0x0/0x77 @ 1
> [   10.981314] initcall pci_sysfs_init+0x0/0x77 returned 0 after 0 us=
ecs
> [   10.988013] calling  boot_wait_for_devices+0x0/0x40 @ 1
> [   10.993012] initcall boot_wait_for_devices+0x0/0x40 returned 0 aft=
er 0 usecs
> [   11.000012] calling  regulator_init_complete+0x0/0x166 @ 1
> [   11.006013] initcall regulator_init_complete+0x0/0x166 returned 0 =
after 976 usecs
> [   11.013015] calling  seqgen_init+0x0/0x36 @ 1
> [   11.017032] initcall seqgen_init+0x0/0x36 returned 0 after 0 usecs
> [   11.024013] calling  hd_init+0x0/0x321 @ 1
> [   11.028115] hd: no drives specified - use hd=3Dcyl,head,sectors on=
 kernel command line
> [   11.036100] initcall hd_init+0x0/0x321 returned -1 after 7812 usec=
s
> [   11.042013] initcall hd_init+0x0/0x321 returned with error code -1=
=20
> [   11.048014] calling  scsi_complete_async_scans+0x0/0x115 @ 1
> [   11.054013] initcall scsi_complete_async_scans+0x0/0x115 returned =
0 after 0 usecs
> [   11.061014] calling  edd_init+0x0/0x227 @ 1
> [   11.065012] BIOS EDD facility v0.16 2004-Jun-25, 1 devices found
> [   11.072212] initcall edd_init+0x0/0x227 returned 0 after 6835 usec=
s
> [   11.078014] calling  memmap_init+0x0/0xce @ 1
> [   11.082119] initcall memmap_init+0x0/0xce returned 0 after 0 usecs
> [   11.089013] calling  tcp_congestion_default+0x0/0x39 @ 1
> [   11.094014] initcall tcp_congestion_default+0x0/0x39 returned 0 af=
ter 0 usecs
> [   11.101013] calling  ip_auto_config+0x0/0x304 @ 1
> [   11.106036] initcall ip_auto_config+0x0/0x304 returned 0 after 0 u=
secs
> [   11.112012] calling  initialize_hashrnd+0x0/0x40 @ 1
> [   11.117016] initcall initialize_hashrnd+0x0/0x40 returned 0 after =
0 usecs
> [   11.124061] async_waiting @ 1
> [   11.127012] async_continuing @ 1 after 0 usec
> [   11.132070] md: Waiting for all devices to be available before aut=
odetect
> [   11.138011] md: If you don't use raid, use raid=3Dnoautodetect
> [   11.144011] async_waiting @ 1
> [   11.147011] async_continuing @ 1 after 0 usec
> [   11.152299] md: Autodetecting RAID arrays.
> [   11.156013] md: Scanned 0 and added 0 devices.
> [   11.161014] md: autorun ...
> [   11.163011] md: ... autorun DONE.
> [   11.173994] EXT3-fs: INFO: recovery required on readonly filesyste=
m.
> [   11.180012] EXT3-fs: write access will be enabled during recovery.
> [   11.203570] EXT3-fs: recovery complete.
> [   11.207111] kjournald starting.  Commit interval 5 seconds
> [   11.213130] EXT3-fs: mounted filesystem with ordered data mode.
> [   11.219095] VFS: Mounted root (ext3 filesystem) readonly on device=
 8:6.
> [   11.225106] async_waiting @ 1
> [   11.228012] async_continuing @ 1 after 0 usec
> [   11.233012] debug: unmapping init memory ffffffff8256e000..fffffff=
f82636000
> [   11.240099] Write protecting the kernel read-only data: 17832k
> [   11.246688] Testing CPA: undo ffffffff81009000-ffffffff82173000
> [   11.253373] Testing CPA: again
> [   11.312649] Not activating Mandatory Access Control now since /sbi=
n/tomoyo-init doesn't exist.
> [   17.505263] ttyS0: 1 input overrun(s)
> [   18.537568] ------------[ cut here ]------------
> [   18.539366] WARNING: at lib/dma-debug.c:812 check_unmap+0x395/0x5e=
6()
> [   18.539366] Hardware name: System Product Name
> [   18.539366] forcedeth 0000:00:0a.0: DMA-API: device driver frees D=
MA memory with wrong function [device address=3D0x000000003b95296a] [si=
ze=3D90 bytes] [mapped as single] [unmapped as page]
> [   18.539366] Pid: 4316, comm: ifup-eth Not tainted 2.6.30-rc8-tip-0=
1994-g0c51e15-dirty #50306
> [   18.539366] Call Trace:
> [   18.539366]  <IRQ>  [<ffffffff8146c4cc>] ? check_unmap+0x395/0x5e6
> [   18.539366]  [<ffffffff8105ac13>] warn_slowpath_common+0x83/0xc6
> [   18.539366]  [<ffffffff8105acd9>] warn_slowpath_fmt+0x4b/0x61
> [   18.539366]  [<ffffffff8146c234>] ? check_unmap+0xfd/0x5e6
> [   18.539366]  [<ffffffff8146c4cc>] check_unmap+0x395/0x5e6
> [   18.539366]  [<ffffffff8146c99f>] debug_dma_unmap_page+0x5e/0x74
> [   18.539366]  [<ffffffff816b1984>] nv_tx_done_optimized+0xb2/0x28a
> [   18.539366]  [<ffffffff81c9a5d2>] ? _spin_lock_irqsave+0x65/0x85
> [   18.539366]  [<ffffffff816b5aa1>] nv_napi_poll+0x28b/0x2ca
> [   18.539366]  [<ffffffff81a91d03>] net_rx_action+0xbd/0x22b
> [   18.539366]  [<ffffffff81a91e0b>] ? net_rx_action+0x1c5/0x22b
> [   18.539366]  [<ffffffff810a5015>] ? __rcu_process_callbacks+0x163/=
0x216
> [   18.539366]  [<ffffffff8106147b>] __do_softirq+0x85/0x136
> [   18.539366]  [<ffffffff81058362>] ? copy_signal+0x6b/0x39f
> [   18.539366]  [<ffffffff8101536c>] call_softirq+0x1c/0x30
> [   18.539366]  [<ffffffff8101752d>] do_softirq+0x51/0xae
> [   18.539366]  [<ffffffff81081a6d>] ? tick_handle_periodic+0x30/0x97
> [   18.539366]  [<ffffffff81061081>] irq_exit+0x52/0xaf
> [   18.539366]  [<ffffffff81030fff>] smp_apic_timer_interrupt+0x9b/0x=
c1
> [   18.539366]  [<ffffffff81014d53>] apic_timer_interrupt+0x13/0x20
> [   18.539366]  <EOI>  [<ffffffff810e5ac4>] ? kmem_cache_alloc+0x8b/0=
xcb
> [   18.539366]  [<ffffffff81058362>] ? copy_signal+0x6b/0x39f
> [   18.539366]  [<ffffffff811130eb>] ? copy_fs_struct+0xaf/0xd1
> [   18.539366]  [<ffffffff810597f2>] ? copy_process+0x580/0xd99
> [   18.539366]  [<ffffffff8105a174>] ? do_fork+0x169/0x33a
> [   18.539366]  [<ffffffff81457c69>] ? __up_read+0x8f/0xb0
> [   18.539366]  [<ffffffff81078f3a>] ? up_read+0x35/0x50
> [   18.539366]  [<ffffffff810af5bc>] ? perf_swcounter_event+0x30/0x46
> [   18.539366]  [<ffffffff8101264d>] ? sys_clone+0x37/0x52
> [   18.539366]  [<ffffffff810144f3>] ? stub_clone+0x13/0x20
> [   18.539366]  [<ffffffff81014182>] ? system_call_fastpath+0x16/0x1b
> [   18.539366] ---[ end trace 1d4adcfbc3df3215 ]---
> [   18.539366] Mapped at:
> [   18.539366]  [<ffffffff8146ceb0>] debug_dma_map_page+0x8b/0x1b9
> [   18.539366]  [<ffffffff816b0eb0>] nv_start_xmit_optimized+0x2a2/0x=
6c5
> [   18.539366]  [<ffffffff81a9503b>] dev_hard_start_xmit+0xd9/0x163
> [   18.539366]  [<ffffffff81ab0a12>] __qdisc_run+0xfc/0x223
> [   18.539366]  [<ffffffff81a95483>] dev_queue_xmit+0x284/0x3d4
> [   18.544082] ttyS0: 2 input overrun(s)
> [   18.639248] eth1: link down
> [   18.642331] ADDRCONF(NETDEV_UP): eth1: link is not ready
> [   19.915513] IPv4 FIB: Using LC-trie version 0.408
> [   19.917074] ttyS0: 32 input overrun(s)
> [   29.483023] eth0: no IPv6 routers present
> [   29.487103] ttyS0: 2 input overrun(s)
> [   29.856572] EXT3 FS on sda6, internal journal
> [   29.972720] kjournald starting.  Commit interval 5 seconds
> [   29.978114] EXT3 FS on sda5, internal journal
> [   29.986131] EXT3-fs: mounted filesystem with ordered data mode.
> [   31.319070] CPA self-test:
> [   31.330993]  4k 262128 large 0 gb 0 x 262128[ffff880000000000-ffff=
88003ffef000] miss 0
> [   31.353988]  4k 262128 large 0 gb 0 x 262128[ffff880000000000-ffff=
88003ffef000] miss 0
> [   31.375981]  4k 262128 large 0 gb 0 x 262128[ffff880000000000-ffff=
88003ffef000] miss 0
> [   31.384125] ok.
> [   32.783813] warning: `dbus-daemon' uses 32-bit capabilities (legac=
y support in use)
> [   32.785428] ttyS0: 6 input overrun(s)
> [   35.925082] CPU 1 is now offline
> [   35.926083] lockdep: fixing up alternatives.
> [   35.927081] SMP alternatives: switching to UP code
> [   35.939104] ttyS0: 2 input overrun(s)
> [   35.991548] lockdep: fixing up alternatives.
> [   35.992132] SMP alternatives: switching to SMP code
> [   36.003356] Booting processor 1 APIC 0x1 ip 0x6000
> [   35.938408] Initializing CPU#1
> [   35.938408] masked ExtINT on CPU#1
> [   35.938408] Calibrating delay using timer specific routine.. 4020.=
05 BogoMIPS (lpj=3D2010028)
> [   35.938408] CPU: L1 I Cache: 64K (64 bytes/line), D cache 64K (64 =
bytes/line)
> [   35.938408] CPU: L2 Cache: 512K (64 bytes/line)
> [   35.938408] CPU 1/0x1 -> Node 0
> [   35.938408] CPU: Physical Processor ID: 0
> [   35.938408] CPU: Processor Core ID: 1
> [   35.938408] mce: CPU supports 5 MCE banks
> [   35.938408] x86 PAT enabled: cpu 1, old 0x7040600070406, new 0x701=
0600070106
> [   36.075641] CPU1: AMD Athlon(tm) 64 X2 Dual Core Processor 3800+ s=
tepping 02
> [   36.129106] CPU 1 is now offline
> [   36.130130] lockdep: fixing up alternatives.
> [   36.131082] SMP alternatives: switching to UP code
> [   36.176677] lockdep: fixing up alternatives.
> [   36.177133] SMP alternatives: switching to SMP code
> [   36.187792] Booting processor 1 APIC 0x1 ip 0x6000
> [   36.147275] Initializing CPU#1
> [   36.147275] masked ExtINT on CPU#1
> [   36.147275] Calibrating delay using timer specific routine.. 4019.=
79 BogoMIPS (lpj=3D2009899)
> [   36.147275] CPU: L1 I Cache: 64K (64 bytes/line), D cache 64K (64 =
bytes/line)
> [   36.147275] CPU: L2 Cache: 512K (64 bytes/line)
> [   36.147275] CPU 1/0x1 -> Node 0
> [   36.147275] CPU: Physical Processor ID: 0
> [   36.147275] CPU: Processor Core ID: 1
> [   36.147275] mce: CPU supports 5 MCE banks
> [   36.147275] x86 PAT enabled: cpu 1, old 0x7040600070406, new 0x701=
0600070106
> [   36.300291] CPU1: AMD Athlon(tm) 64 X2 Dual Core Processor 3800+ s=
tepping 02
>=20
> #
> # Automatically generated make config: don't edit
> # Linux kernel version: 2.6.30-rc8
> # Sun Jun  7 11:52:01 2009
> #
> CONFIG_64BIT=3Dy
> # CONFIG_X86_32 is not set
> CONFIG_X86_64=3Dy
> CONFIG_X86=3Dy
> CONFIG_OUTPUT_FORMAT=3D"elf64-x86-64"
> CONFIG_ARCH_DEFCONFIG=3D"arch/x86/configs/x86_64_defconfig"
> CONFIG_GENERIC_TIME=3Dy
> CONFIG_GENERIC_CMOS_UPDATE=3Dy
> CONFIG_CLOCKSOURCE_WATCHDOG=3Dy
> CONFIG_GENERIC_CLOCKEVENTS=3Dy
> CONFIG_GENERIC_CLOCKEVENTS_BROADCAST=3Dy
> CONFIG_LOCKDEP_SUPPORT=3Dy
> CONFIG_STACKTRACE_SUPPORT=3Dy
> CONFIG_HAVE_LATENCYTOP_SUPPORT=3Dy
> CONFIG_FAST_CMPXCHG_LOCAL=3Dy
> CONFIG_MMU=3Dy
> CONFIG_ZONE_DMA=3Dy
> CONFIG_GENERIC_ISA_DMA=3Dy
> CONFIG_GENERIC_IOMAP=3Dy
> CONFIG_GENERIC_BUG=3Dy
> CONFIG_GENERIC_BUG_RELATIVE_POINTERS=3Dy
> CONFIG_GENERIC_HWEIGHT=3Dy
> CONFIG_GENERIC_GPIO=3Dy
> CONFIG_ARCH_MAY_HAVE_PC_FDC=3Dy
> CONFIG_RWSEM_GENERIC_SPINLOCK=3Dy
> # CONFIG_RWSEM_XCHGADD_ALGORITHM is not set
> CONFIG_ARCH_HAS_CPU_IDLE_WAIT=3Dy
> CONFIG_GENERIC_CALIBRATE_DELAY=3Dy
> CONFIG_GENERIC_TIME_VSYSCALL=3Dy
> CONFIG_ARCH_HAS_CPU_RELAX=3Dy
> CONFIG_ARCH_HAS_DEFAULT_IDLE=3Dy
> CONFIG_ARCH_HAS_CACHE_LINE_SIZE=3Dy
> CONFIG_HAVE_SETUP_PER_CPU_AREA=3Dy
> CONFIG_HAVE_DYNAMIC_PER_CPU_AREA=3Dy
> CONFIG_HAVE_CPUMASK_OF_CPU_MAP=3Dy
> CONFIG_ARCH_HIBERNATION_POSSIBLE=3Dy
> CONFIG_ARCH_SUSPEND_POSSIBLE=3Dy
> CONFIG_ZONE_DMA32=3Dy
> CONFIG_ARCH_POPULATES_NODE_MAP=3Dy
> CONFIG_AUDIT_ARCH=3Dy
> CONFIG_ARCH_SUPPORTS_OPTIMIZED_INLINING=3Dy
> CONFIG_ARCH_SUPPORTS_DEBUG_PAGEALLOC=3Dy
> CONFIG_GENERIC_HARDIRQS=3Dy
> CONFIG_GENERIC_HARDIRQS_NO__DO_IRQ=3Dy
> CONFIG_GENERIC_IRQ_PROBE=3Dy
> CONFIG_GENERIC_PENDING_IRQ=3Dy
> CONFIG_USE_GENERIC_SMP_HELPERS=3Dy
> CONFIG_X86_64_SMP=3Dy
> CONFIG_X86_HT=3Dy
> CONFIG_X86_TRAMPOLINE=3Dy
> # CONFIG_KTIME_SCALAR is not set
> CONFIG_BOOTPARAM_SUPPORT_NOT_WANTED=3Dy
> CONFIG_DEFCONFIG_LIST=3D"/lib/modules/$UNAME_RELEASE/.config"
>=20
> #
> # General setup
> #
> CONFIG_EXPERIMENTAL=3Dy
> # CONFIG_BROKEN_BOOT_ALLOWED4 is not set
> CONFIG_BROKEN_BOOT_EUROPE=3Dy
> CONFIG_BROKEN_BOOT_TITAN=3Dy
> CONFIG_LOCK_KERNEL=3Dy
> CONFIG_INIT_ENV_ARG_LIMIT=3D32
> CONFIG_LOCALVERSION=3D""
> CONFIG_LOCALVERSION_AUTO=3Dy
> CONFIG_HAVE_KERNEL_GZIP=3Dy
> CONFIG_HAVE_KERNEL_BZIP2=3Dy
> CONFIG_HAVE_KERNEL_LZMA=3Dy
> # CONFIG_KERNEL_GZIP is not set
> CONFIG_KERNEL_BZIP2=3Dy
> # CONFIG_KERNEL_LZMA is not set
> # CONFIG_SWAP is not set
> CONFIG_SYSVIPC=3Dy
> CONFIG_SYSVIPC_SYSCTL=3Dy
> # CONFIG_POSIX_MQUEUE is not set
> CONFIG_BSD_PROCESS_ACCT=3Dy
> CONFIG_BSD_PROCESS_ACCT_V3=3Dy
> CONFIG_TASKSTATS=3Dy
> # CONFIG_TASK_DELAY_ACCT is not set
> CONFIG_TASK_XACCT=3Dy
> CONFIG_TASK_IO_ACCOUNTING=3Dy
> # CONFIG_AUDIT is not set
>=20
> #
> # RCU Subsystem
> #
> CONFIG_CLASSIC_RCU=3Dy
> # CONFIG_TREE_RCU is not set
> # CONFIG_PREEMPT_RCU is not set
> # CONFIG_TREE_RCU_TRACE is not set
> # CONFIG_PREEMPT_RCU_TRACE is not set
> # CONFIG_IKCONFIG is not set
> CONFIG_LOG_BUF_SHIFT=3D20
> CONFIG_HAVE_UNSTABLE_SCHED_CLOCK=3Dy
> CONFIG_GROUP_SCHED=3Dy
> # CONFIG_FAIR_GROUP_SCHED is not set
> CONFIG_RT_GROUP_SCHED=3Dy
> CONFIG_USER_SCHED=3Dy
> # CONFIG_CGROUP_SCHED is not set
> CONFIG_CGROUPS=3Dy
> CONFIG_CGROUP_DEBUG=3Dy
> CONFIG_CGROUP_NS=3Dy
> CONFIG_CGROUP_FREEZER=3Dy
> CONFIG_CGROUP_DEVICE=3Dy
> CONFIG_CPUSETS=3Dy
> CONFIG_PROC_PID_CPUSET=3Dy
> # CONFIG_CGROUP_CPUACCT is not set
> # CONFIG_RESOURCE_COUNTERS is not set
> CONFIG_SYSFS_DEPRECATED=3Dy
> CONFIG_SYSFS_DEPRECATED_V2=3Dy
> CONFIG_RELAY=3Dy
> CONFIG_NAMESPACES=3Dy
> CONFIG_UTS_NS=3Dy
> CONFIG_IPC_NS=3Dy
> CONFIG_USER_NS=3Dy
> CONFIG_PID_NS=3Dy
> CONFIG_NET_NS=3Dy
> CONFIG_BLK_DEV_INITRD=3Dy
> CONFIG_INITRAMFS_SOURCE=3D""
> CONFIG_RD_GZIP=3Dy
> CONFIG_RD_BZIP2=3Dy
> CONFIG_RD_LZMA=3Dy
> CONFIG_CC_OPTIMIZE_FOR_SIZE=3Dy
> CONFIG_SYSCTL=3Dy
> CONFIG_ANON_INODES=3Dy
> # CONFIG_EMBEDDED is not set
> CONFIG_UID16=3Dy
> CONFIG_SYSCTL_SYSCALL=3Dy
> CONFIG_KALLSYMS=3Dy
> CONFIG_KALLSYMS_ALL=3Dy
> # CONFIG_KALLSYMS_EXTRA_PASS is not set
> CONFIG_STRIP_ASM_SYMS=3Dy
> CONFIG_HOTPLUG=3Dy
> CONFIG_PRINTK=3Dy
> CONFIG_BUG=3Dy
> CONFIG_ELF_CORE=3Dy
> CONFIG_PCSPKR_PLATFORM=3Dy
> CONFIG_BASE_FULL=3Dy
> CONFIG_FUTEX=3Dy
> CONFIG_EPOLL=3Dy
> CONFIG_SIGNALFD=3Dy
> CONFIG_TIMERFD=3Dy
> CONFIG_EVENTFD=3Dy
> CONFIG_SHMEM=3Dy
> CONFIG_AIO=3Dy
> CONFIG_HAVE_PERF_COUNTERS=3Dy
>=20
> #
> # Performance Counters
> #
> CONFIG_PERF_COUNTERS=3Dy
> CONFIG_VM_EVENT_COUNTERS=3Dy
> CONFIG_PCI_QUIRKS=3Dy
> CONFIG_SLUB_DEBUG=3Dy
> # CONFIG_COMPAT_BRK is not set
> # CONFIG_SLAB is not set
> CONFIG_SLUB=3Dy
> # CONFIG_SLOB is not set
> CONFIG_PROFILING=3Dy
> # CONFIG_MARKERS is not set
> # CONFIG_OPROFILE is not set
> CONFIG_HAVE_OPROFILE=3Dy
> CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS=3Dy
> CONFIG_HAVE_IOREMAP_PROT=3Dy
> CONFIG_HAVE_KPROBES=3Dy
> CONFIG_HAVE_KRETPROBES=3Dy
> CONFIG_HAVE_ARCH_TRACEHOOK=3Dy
> CONFIG_HAVE_DMA_API_DEBUG=3Dy
> CONFIG_HAVE_HW_BREAKPOINT=3Dy
> CONFIG_SLOW_WORK=3Dy
> # CONFIG_HAVE_GENERIC_DMA_COHERENT is not set
> CONFIG_SLABINFO=3Dy
> CONFIG_RT_MUTEXES=3Dy
> CONFIG_BASE_SMALL=3D0
> # CONFIG_MODULES is not set
> CONFIG_STOP_MACHINE=3Dy
> CONFIG_BLOCK=3Dy
> CONFIG_BLK_DEV_BSG=3Dy
> # CONFIG_BLK_DEV_INTEGRITY is not set
> CONFIG_BLOCK_COMPAT=3Dy
>=20
> #
> # IO Schedulers
> #
> CONFIG_IOSCHED_NOOP=3Dy
> # CONFIG_IOSCHED_AS is not set
> CONFIG_IOSCHED_DEADLINE=3Dy
> CONFIG_IOSCHED_CFQ=3Dy
> # CONFIG_DEFAULT_AS is not set
> CONFIG_DEFAULT_DEADLINE=3Dy
> # CONFIG_DEFAULT_CFQ is not set
> # CONFIG_DEFAULT_NOOP is not set
> CONFIG_DEFAULT_IOSCHED=3D"deadline"
> CONFIG_FREEZER=3Dy
>=20
> #
> # Processor type and features
> #
> CONFIG_TICK_ONESHOT=3Dy
> CONFIG_NO_HZ=3Dy
> CONFIG_HIGH_RES_TIMERS=3Dy
> CONFIG_GENERIC_CLOCKEVENTS_BUILD=3Dy
> CONFIG_SMP_SUPPORT=3Dy
> # CONFIG_SPARSE_IRQ is not set
> CONFIG_X86_MPPARSE=3Dy
> CONFIG_X86_EXTENDED_PLATFORM=3Dy
> # CONFIG_X86_VSMP is not set
> CONFIG_SCHED_OMIT_FRAME_POINTER=3Dy
> CONFIG_PARAVIRT_GUEST=3Dy
> CONFIG_XEN=3Dy
> CONFIG_XEN_MAX_DOMAIN_MEMORY=3D32
> CONFIG_XEN_SAVE_RESTORE=3Dy
> CONFIG_XEN_DEBUG_FS=3Dy
> CONFIG_KVM_CLOCK=3Dy
> CONFIG_KVM_GUEST=3Dy
> CONFIG_PARAVIRT=3Dy
> CONFIG_PARAVIRT_SPINLOCKS=3Dy
> CONFIG_PARAVIRT_CLOCK=3Dy
> CONFIG_PARAVIRT_DEBUG=3Dy
> CONFIG_MEMTEST=3Dy
> # CONFIG_M386 is not set
> # CONFIG_M486 is not set
> # CONFIG_M586 is not set
> # CONFIG_M586TSC is not set
> # CONFIG_M586MMX is not set
> # CONFIG_M686 is not set
> # CONFIG_MPENTIUMII is not set
> # CONFIG_MPENTIUMIII is not set
> # CONFIG_MPENTIUMM is not set
> # CONFIG_MPENTIUM4 is not set
> # CONFIG_MK6 is not set
> # CONFIG_MK7 is not set
> # CONFIG_MK8 is not set
> # CONFIG_MCRUSOE is not set
> # CONFIG_MEFFICEON is not set
> # CONFIG_MWINCHIPC6 is not set
> # CONFIG_MWINCHIP3D is not set
> # CONFIG_MGEODEGX1 is not set
> # CONFIG_MGEODE_LX is not set
> # CONFIG_MCYRIXIII is not set
> # CONFIG_MVIAC3_2 is not set
> # CONFIG_MVIAC7 is not set
> # CONFIG_MPSC is not set
> # CONFIG_MCORE2 is not set
> CONFIG_GENERIC_CPU=3Dy
> CONFIG_X86_CPU=3Dy
> CONFIG_X86_L1_CACHE_BYTES=3D64
> CONFIG_X86_INTERNODE_CACHE_BYTES=3D64
> CONFIG_X86_CMPXCHG=3Dy
> CONFIG_X86_L1_CACHE_SHIFT=3D6
> CONFIG_X86_WP_WORKS_OK=3Dy
> CONFIG_X86_TSC=3Dy
> CONFIG_X86_CMPXCHG64=3Dy
> CONFIG_X86_CMOV=3Dy
> CONFIG_X86_MINIMUM_CPU_FAMILY=3D64
> CONFIG_X86_DEBUGCTLMSR=3Dy
> CONFIG_CPU_SUP_INTEL=3Dy
> CONFIG_CPU_SUP_AMD=3Dy
> CONFIG_CPU_SUP_CENTAUR=3Dy
> CONFIG_X86_DS=3Dy
> CONFIG_X86_PTRACE_BTS=3Dy
> CONFIG_HPET_TIMER=3Dy
> CONFIG_DMI=3Dy
> CONFIG_GART_IOMMU=3Dy
> CONFIG_CALGARY_IOMMU=3Dy
> # CONFIG_CALGARY_IOMMU_ENABLED_BY_DEFAULT is not set
> CONFIG_SWIOTLB=3Dy
> CONFIG_IOMMU_HELPER=3Dy
> # CONFIG_IOMMU_API is not set
> CONFIG_MAXSMP=3Dy
> CONFIG_NR_CPUS=3D4096
> # CONFIG_SCHED_SMT is not set
> CONFIG_SCHED_MC=3Dy
> # CONFIG_PREEMPT_NONE is not set
> # CONFIG_PREEMPT_VOLUNTARY is not set
> CONFIG_PREEMPT=3Dy
> CONFIG_X86_LOCAL_APIC=3Dy
> CONFIG_X86_IO_APIC=3Dy
> CONFIG_X86_REROUTE_FOR_BROKEN_BOOT_IRQS=3Dy
> CONFIG_X86_MCE=3Dy
> CONFIG_X86_NEW_MCE=3Dy
> CONFIG_X86_MCE_INTEL=3Dy
> # CONFIG_X86_MCE_AMD is not set
> CONFIG_X86_MCE_THRESHOLD=3Dy
> # CONFIG_X86_MCE_INJECT is not set
> CONFIG_X86_THERMAL_VECTOR=3Dy
> CONFIG_I8K=3Dy
> CONFIG_MICROCODE=3Dy
> # CONFIG_MICROCODE_INTEL is not set
> # CONFIG_MICROCODE_AMD is not set
> CONFIG_MICROCODE_OLD_INTERFACE=3Dy
> CONFIG_X86_MSR=3Dy
> CONFIG_X86_CPUID=3Dy
> CONFIG_X86_CPU_DEBUG=3Dy
> CONFIG_UP_WANTED_1=3Dy
> # CONFIG_UP_WANTED_2 is not set
> CONFIG_SMP=3Dy
> CONFIG_ARCH_PHYS_ADDR_T_64BIT=3Dy
> CONFIG_DIRECT_GBPAGES=3Dy
> CONFIG_NUMA=3Dy
> # CONFIG_K8_NUMA is not set
> CONFIG_NUMA_EMU=3Dy
> CONFIG_NODES_SHIFT=3D9
> CONFIG_ARCH_SPARSEMEM_DEFAULT=3Dy
> CONFIG_ARCH_SPARSEMEM_ENABLE=3Dy
> CONFIG_ARCH_SELECT_MEMORY_MODEL=3Dy
> CONFIG_ARCH_MEMORY_PROBE=3Dy
> CONFIG_ILLEGAL_POINTER_VALUE=3D0xdead000000000000
> CONFIG_SELECT_MEMORY_MODEL=3Dy
> # CONFIG_FLATMEM_MANUAL is not set
> # CONFIG_DISCONTIGMEM_MANUAL is not set
> CONFIG_SPARSEMEM_MANUAL=3Dy
> CONFIG_SPARSEMEM=3Dy
> CONFIG_NEED_MULTIPLE_NODES=3Dy
> CONFIG_HAVE_MEMORY_PRESENT=3Dy
> CONFIG_SPARSEMEM_EXTREME=3Dy
> CONFIG_SPARSEMEM_VMEMMAP_ENABLE=3Dy
> # CONFIG_SPARSEMEM_VMEMMAP is not set
> CONFIG_MEMORY_HOTPLUG=3Dy
> CONFIG_MEMORY_HOTPLUG_SPARSE=3Dy
> CONFIG_MEMORY_HOTREMOVE=3Dy
> CONFIG_PAGEFLAGS_EXTENDED=3Dy
> CONFIG_SPLIT_PTLOCK_CPUS=3D4
> CONFIG_MIGRATION=3Dy
> CONFIG_PHYS_ADDR_T_64BIT=3Dy
> CONFIG_ZONE_DMA_FLAG=3D1
> CONFIG_BOUNCE=3Dy
> CONFIG_VIRT_TO_BUS=3Dy
> # CONFIG_UNEVICTABLE_LRU is not set
> CONFIG_HAVE_MLOCK=3Dy
> # CONFIG_X86_CHECK_BIOS_CORRUPTION is not set
> CONFIG_X86_RESERVE_LOW_64K=3Dy
> CONFIG_MTRR=3Dy
> CONFIG_MTRR_SANITIZER=3Dy
> CONFIG_MTRR_SANITIZER_ENABLE_DEFAULT=3D0
> CONFIG_MTRR_SANITIZER_SPARE_REG_NR_DEFAULT=3D1
> CONFIG_X86_PAT=3Dy
> CONFIG_SECCOMP=3Dy
> CONFIG_CC_STACKPROTECTOR_ALL=3Dy
> CONFIG_CC_STACKPROTECTOR=3Dy
> # CONFIG_HZ_100 is not set
> # CONFIG_HZ_250 is not set
> # CONFIG_HZ_300 is not set
> CONFIG_HZ_1000=3Dy
> CONFIG_HZ=3D1000
> CONFIG_SCHED_HRTICK=3Dy
> CONFIG_KEXEC=3Dy
> CONFIG_CRASH_DUMP=3Dy
> CONFIG_PHYSICAL_START=3D0x1000000
> # CONFIG_RELOCATABLE is not set
> CONFIG_PHYSICAL_ALIGN=3D0x1000000
> CONFIG_HOTPLUG_CPU=3Dy
> CONFIG_COMPAT_VDSO=3Dy
> # CONFIG_CMDLINE_BOOL is not set
> CONFIG_ARCH_ENABLE_MEMORY_HOTPLUG=3Dy
> CONFIG_ARCH_ENABLE_MEMORY_HOTREMOVE=3Dy
> CONFIG_HAVE_ARCH_EARLY_PFN_TO_NID=3Dy
>=20
> #
> # Power management and ACPI options
> #
> CONFIG_PM=3Dy
> # CONFIG_PM_DEBUG is not set
> CONFIG_PM_SLEEP_SMP=3Dy
> CONFIG_PM_SLEEP=3Dy
> CONFIG_SUSPEND=3Dy
> CONFIG_SUSPEND_FREEZER=3Dy
> # CONFIG_ACPI is not set
>=20
> #
> # CPU Frequency scaling
> #
> CONFIG_CPU_FREQ=3Dy
> CONFIG_CPU_FREQ_TABLE=3Dy
> # CONFIG_CPU_FREQ_DEBUG is not set
> CONFIG_CPU_FREQ_STAT=3Dy
> CONFIG_CPU_FREQ_STAT_DETAILS=3Dy
> CONFIG_CPU_FREQ_DEFAULT_GOV_PERFORMANCE=3Dy
> # CONFIG_CPU_FREQ_DEFAULT_GOV_POWERSAVE is not set
> # CONFIG_CPU_FREQ_DEFAULT_GOV_USERSPACE is not set
> # CONFIG_CPU_FREQ_DEFAULT_GOV_ONDEMAND is not set
> # CONFIG_CPU_FREQ_DEFAULT_GOV_CONSERVATIVE is not set
> CONFIG_CPU_FREQ_GOV_PERFORMANCE=3Dy
> CONFIG_CPU_FREQ_GOV_POWERSAVE=3Dy
> # CONFIG_CPU_FREQ_GOV_USERSPACE is not set
> # CONFIG_CPU_FREQ_GOV_ONDEMAND is not set
> CONFIG_CPU_FREQ_GOV_CONSERVATIVE=3Dy
>=20
> #
> # CPUFreq processor drivers
> #
> CONFIG_X86_P4_CLOCKMOD=3Dy
>=20
> #
> # shared options
> #
> CONFIG_X86_SPEEDSTEP_LIB=3Dy
> CONFIG_CPU_IDLE=3Dy
> CONFIG_CPU_IDLE_GOV_LADDER=3Dy
> CONFIG_CPU_IDLE_GOV_MENU=3Dy
>=20
> #
> # Memory power savings
> #
> # CONFIG_I7300_IDLE is not set
>=20
> #
> # Bus options (PCI etc.)
> #
> CONFIG_PCI=3Dy
> CONFIG_PCI_DIRECT=3Dy
> CONFIG_PCI_DOMAINS=3Dy
> # CONFIG_PCIEPORTBUS is not set
> CONFIG_ARCH_SUPPORTS_MSI=3Dy
> # CONFIG_PCI_MSI is not set
> CONFIG_PCI_LEGACY=3Dy
> # CONFIG_PCI_DEBUG is not set
> CONFIG_PCI_STUB=3Dy
> CONFIG_HT_IRQ=3Dy
> # CONFIG_PCI_IOV is not set
> CONFIG_ISA_DMA_API=3Dy
> CONFIG_K8_NB=3Dy
> CONFIG_PCCARD=3Dy
> # CONFIG_PCMCIA_DEBUG is not set
> # CONFIG_PCMCIA is not set
> CONFIG_CARDBUS=3Dy
>=20
> #
> # PC-card bridges
> #
> CONFIG_YENTA=3Dy
> CONFIG_YENTA_O2=3Dy
> CONFIG_YENTA_RICOH=3Dy
> CONFIG_YENTA_TI=3Dy
> CONFIG_YENTA_ENE_TUNE=3Dy
> CONFIG_YENTA_TOSHIBA=3Dy
> CONFIG_PCCARD_NONSTATIC=3Dy
> # CONFIG_HOTPLUG_PCI is not set
>=20
> #
> # Executable file formats / Emulations
> #
> CONFIG_BINFMT_ELF=3Dy
> CONFIG_COMPAT_BINFMT_ELF=3Dy
> # CONFIG_CORE_DUMP_DEFAULT_ELF_HEADERS is not set
> # CONFIG_HAVE_AOUT is not set
> CONFIG_BINFMT_MISC=3Dy
> CONFIG_IA32_EMULATION=3Dy
> # CONFIG_IA32_AOUT is not set
> CONFIG_COMPAT=3Dy
> CONFIG_COMPAT_FOR_U64_ALIGNMENT=3Dy
> CONFIG_SYSVIPC_COMPAT=3Dy
> CONFIG_NET=3Dy
>=20
> #
> # Networking options
> #
> CONFIG_PACKET=3Dy
> CONFIG_PACKET_MMAP=3Dy
> CONFIG_UNIX=3Dy
> CONFIG_XFRM=3Dy
> CONFIG_XFRM_USER=3Dy
> CONFIG_XFRM_SUB_POLICY=3Dy
> CONFIG_XFRM_MIGRATE=3Dy
> CONFIG_XFRM_STATISTICS=3Dy
> CONFIG_NET_KEY=3Dy
> # CONFIG_NET_KEY_MIGRATE is not set
> CONFIG_INET=3Dy
> CONFIG_IP_MULTICAST=3Dy
> CONFIG_IP_ADVANCED_ROUTER=3Dy
> # CONFIG_ASK_IP_FIB_HASH is not set
> CONFIG_IP_FIB_TRIE=3Dy
> # CONFIG_IP_FIB_HASH is not set
> # CONFIG_IP_FIB_TRIE_STATS is not set
> CONFIG_IP_MULTIPLE_TABLES=3Dy
> CONFIG_IP_ROUTE_MULTIPATH=3Dy
> CONFIG_IP_ROUTE_VERBOSE=3Dy
> CONFIG_IP_PNP=3Dy
> # CONFIG_IP_PNP_DHCP is not set
> CONFIG_IP_PNP_BOOTP=3Dy
> CONFIG_IP_PNP_RARP=3Dy
> CONFIG_NET_IPIP=3Dy
> CONFIG_NET_IPGRE=3Dy
> # CONFIG_NET_IPGRE_BROADCAST is not set
> CONFIG_IP_MROUTE=3Dy
> CONFIG_IP_PIMSM_V1=3Dy
> CONFIG_IP_PIMSM_V2=3Dy
> CONFIG_ARPD=3Dy
> CONFIG_SYN_COOKIES=3Dy
> # CONFIG_INET_AH is not set
> CONFIG_INET_ESP=3Dy
> # CONFIG_INET_IPCOMP is not set
> # CONFIG_INET_XFRM_TUNNEL is not set
> CONFIG_INET_TUNNEL=3Dy
> # CONFIG_INET_XFRM_MODE_TRANSPORT is not set
> CONFIG_INET_XFRM_MODE_TUNNEL=3Dy
> CONFIG_INET_XFRM_MODE_BEET=3Dy
> CONFIG_INET_LRO=3Dy
> CONFIG_INET_DIAG=3Dy
> CONFIG_INET_TCP_DIAG=3Dy
> # CONFIG_TCP_CONG_ADVANCED is not set
> CONFIG_TCP_CONG_CUBIC=3Dy
> CONFIG_DEFAULT_TCP_CONG=3D"cubic"
> CONFIG_TCP_MD5SIG=3Dy
> CONFIG_IPV6=3Dy
> CONFIG_IPV6_PRIVACY=3Dy
> # CONFIG_IPV6_ROUTER_PREF is not set
> # CONFIG_IPV6_OPTIMISTIC_DAD is not set
> # CONFIG_INET6_AH is not set
> # CONFIG_INET6_ESP is not set
> # CONFIG_INET6_IPCOMP is not set
> CONFIG_IPV6_MIP6=3Dy
> # CONFIG_INET6_XFRM_TUNNEL is not set
> CONFIG_INET6_TUNNEL=3Dy
> # CONFIG_INET6_XFRM_MODE_TRANSPORT is not set
> # CONFIG_INET6_XFRM_MODE_TUNNEL is not set
> # CONFIG_INET6_XFRM_MODE_BEET is not set
> # CONFIG_INET6_XFRM_MODE_ROUTEOPTIMIZATION is not set
> # CONFIG_IPV6_SIT is not set
> CONFIG_IPV6_TUNNEL=3Dy
> # CONFIG_IPV6_MULTIPLE_TABLES is not set
> CONFIG_IPV6_MROUTE=3Dy
> # CONFIG_IPV6_PIMSM_V2 is not set
> CONFIG_NETLABEL=3Dy
> CONFIG_NETWORK_SECMARK=3Dy
> CONFIG_NETFILTER=3Dy
> # CONFIG_NETFILTER_DEBUG is not set
> CONFIG_NETFILTER_ADVANCED=3Dy
> CONFIG_BRIDGE_NETFILTER=3Dy
>=20
> #
> # Core Netfilter Configuration
> #
> CONFIG_NETFILTER_NETLINK=3Dy
> # CONFIG_NETFILTER_NETLINK_QUEUE is not set
> CONFIG_NETFILTER_NETLINK_LOG=3Dy
> CONFIG_NF_CONNTRACK=3Dy
> CONFIG_NF_CT_ACCT=3Dy
> CONFIG_NF_CONNTRACK_MARK=3Dy
> CONFIG_NF_CONNTRACK_SECMARK=3Dy
> CONFIG_NF_CONNTRACK_EVENTS=3Dy
> CONFIG_NF_CT_PROTO_DCCP=3Dy
> CONFIG_NF_CT_PROTO_GRE=3Dy
> CONFIG_NF_CT_PROTO_SCTP=3Dy
> CONFIG_NF_CT_PROTO_UDPLITE=3Dy
> # CONFIG_NF_CONNTRACK_AMANDA is not set
> # CONFIG_NF_CONNTRACK_FTP is not set
> # CONFIG_NF_CONNTRACK_H323 is not set
> CONFIG_NF_CONNTRACK_IRC=3Dy
> CONFIG_NF_CONNTRACK_NETBIOS_NS=3Dy
> CONFIG_NF_CONNTRACK_PPTP=3Dy
> CONFIG_NF_CONNTRACK_SANE=3Dy
> # CONFIG_NF_CONNTRACK_SIP is not set
> CONFIG_NF_CONNTRACK_TFTP=3Dy
> CONFIG_NF_CT_NETLINK=3Dy
> CONFIG_NETFILTER_XTABLES=3Dy
> # CONFIG_NETFILTER_XT_TARGET_CLASSIFY is not set
> CONFIG_NETFILTER_XT_TARGET_CONNMARK=3Dy
> # CONFIG_NETFILTER_XT_TARGET_CONNSECMARK is not set
> CONFIG_NETFILTER_XT_TARGET_DSCP=3Dy
> CONFIG_NETFILTER_XT_TARGET_HL=3Dy
> CONFIG_NETFILTER_XT_TARGET_LED=3Dy
> CONFIG_NETFILTER_XT_TARGET_MARK=3Dy
> CONFIG_NETFILTER_XT_TARGET_NFLOG=3Dy
> CONFIG_NETFILTER_XT_TARGET_NFQUEUE=3Dy
> CONFIG_NETFILTER_XT_TARGET_NOTRACK=3Dy
> CONFIG_NETFILTER_XT_TARGET_RATEEST=3Dy
> CONFIG_NETFILTER_XT_TARGET_TRACE=3Dy
> # CONFIG_NETFILTER_XT_TARGET_SECMARK is not set
> CONFIG_NETFILTER_XT_TARGET_TCPMSS=3Dy
> CONFIG_NETFILTER_XT_TARGET_TCPOPTSTRIP=3Dy
> CONFIG_NETFILTER_XT_MATCH_CLUSTER=3Dy
> CONFIG_NETFILTER_XT_MATCH_COMMENT=3Dy
> CONFIG_NETFILTER_XT_MATCH_CONNBYTES=3Dy
> CONFIG_NETFILTER_XT_MATCH_CONNLIMIT=3Dy
> CONFIG_NETFILTER_XT_MATCH_CONNMARK=3Dy
> # CONFIG_NETFILTER_XT_MATCH_CONNTRACK is not set
> CONFIG_NETFILTER_XT_MATCH_DCCP=3Dy
> # CONFIG_NETFILTER_XT_MATCH_DSCP is not set
> CONFIG_NETFILTER_XT_MATCH_ESP=3Dy
> # CONFIG_NETFILTER_XT_MATCH_HASHLIMIT is not set
> # CONFIG_NETFILTER_XT_MATCH_HELPER is not set
> CONFIG_NETFILTER_XT_MATCH_HL=3Dy
> # CONFIG_NETFILTER_XT_MATCH_IPRANGE is not set
> CONFIG_NETFILTER_XT_MATCH_LENGTH=3Dy
> # CONFIG_NETFILTER_XT_MATCH_LIMIT is not set
> # CONFIG_NETFILTER_XT_MATCH_MAC is not set
> # CONFIG_NETFILTER_XT_MATCH_MARK is not set
> CONFIG_NETFILTER_XT_MATCH_MULTIPORT=3Dy
> # CONFIG_NETFILTER_XT_MATCH_OWNER is not set
> CONFIG_NETFILTER_XT_MATCH_POLICY=3Dy
> CONFIG_NETFILTER_XT_MATCH_PHYSDEV=3Dy
> # CONFIG_NETFILTER_XT_MATCH_PKTTYPE is not set
> # CONFIG_NETFILTER_XT_MATCH_QUOTA is not set
> # CONFIG_NETFILTER_XT_MATCH_RATEEST is not set
> # CONFIG_NETFILTER_XT_MATCH_REALM is not set
> # CONFIG_NETFILTER_XT_MATCH_RECENT is not set
> CONFIG_NETFILTER_XT_MATCH_SCTP=3Dy
> # CONFIG_NETFILTER_XT_MATCH_STATE is not set
> CONFIG_NETFILTER_XT_MATCH_STATISTIC=3Dy
> CONFIG_NETFILTER_XT_MATCH_STRING=3Dy
> # CONFIG_NETFILTER_XT_MATCH_TCPMSS is not set
> CONFIG_NETFILTER_XT_MATCH_TIME=3Dy
> CONFIG_NETFILTER_XT_MATCH_U32=3Dy
> CONFIG_IP_VS=3Dy
> # CONFIG_IP_VS_IPV6 is not set
> # CONFIG_IP_VS_DEBUG is not set
> CONFIG_IP_VS_TAB_BITS=3D12
>=20
> #
> # IPVS transport protocol load balancing support
> #
> # CONFIG_IP_VS_PROTO_TCP is not set
> # CONFIG_IP_VS_PROTO_UDP is not set
> CONFIG_IP_VS_PROTO_AH_ESP=3Dy
> CONFIG_IP_VS_PROTO_ESP=3Dy
> CONFIG_IP_VS_PROTO_AH=3Dy
>=20
> #
> # IPVS scheduler
> #
> # CONFIG_IP_VS_RR is not set
> CONFIG_IP_VS_WRR=3Dy
> # CONFIG_IP_VS_LC is not set
> CONFIG_IP_VS_WLC=3Dy
> # CONFIG_IP_VS_LBLC is not set
> CONFIG_IP_VS_LBLCR=3Dy
> # CONFIG_IP_VS_DH is not set
> CONFIG_IP_VS_SH=3Dy
> CONFIG_IP_VS_SED=3Dy
> CONFIG_IP_VS_NQ=3Dy
>=20
> #
> # IPVS application helper
> #
>=20
> #
> # IP: Netfilter Configuration
> #
> CONFIG_NF_DEFRAG_IPV4=3Dy
> CONFIG_NF_CONNTRACK_IPV4=3Dy
> # CONFIG_NF_CONNTRACK_PROC_COMPAT is not set
> CONFIG_IP_NF_QUEUE=3Dy
> # CONFIG_IP_NF_IPTABLES is not set
> CONFIG_IP_NF_ARPTABLES=3Dy
> CONFIG_IP_NF_ARPFILTER=3Dy
> CONFIG_IP_NF_ARP_MANGLE=3Dy
>=20
> #
> # IPv6: Netfilter Configuration
> #
> CONFIG_NF_CONNTRACK_IPV6=3Dy
> CONFIG_IP6_NF_QUEUE=3Dy
> CONFIG_IP6_NF_IPTABLES=3Dy
> # CONFIG_IP6_NF_MATCH_AH is not set
> # CONFIG_IP6_NF_MATCH_EUI64 is not set
> CONFIG_IP6_NF_MATCH_FRAG=3Dy
> CONFIG_IP6_NF_MATCH_OPTS=3Dy
> CONFIG_IP6_NF_MATCH_HL=3Dy
> # CONFIG_IP6_NF_MATCH_IPV6HEADER is not set
> # CONFIG_IP6_NF_MATCH_MH is not set
> CONFIG_IP6_NF_MATCH_RT=3Dy
> # CONFIG_IP6_NF_TARGET_HL is not set
> CONFIG_IP6_NF_TARGET_LOG=3Dy
> # CONFIG_IP6_NF_FILTER is not set
> CONFIG_IP6_NF_MANGLE=3Dy
> CONFIG_IP6_NF_RAW=3Dy
> # CONFIG_IP6_NF_SECURITY is not set
>=20
> #
> # DECnet: Netfilter Configuration
> #
> # CONFIG_DECNET_NF_GRABULATOR is not set
> CONFIG_BRIDGE_NF_EBTABLES=3Dy
> CONFIG_BRIDGE_EBT_BROUTE=3Dy
> CONFIG_BRIDGE_EBT_T_FILTER=3Dy
> CONFIG_BRIDGE_EBT_T_NAT=3Dy
> CONFIG_BRIDGE_EBT_802_3=3Dy
> # CONFIG_BRIDGE_EBT_AMONG is not set
> CONFIG_BRIDGE_EBT_ARP=3Dy
> CONFIG_BRIDGE_EBT_IP=3Dy
> CONFIG_BRIDGE_EBT_IP6=3Dy
> CONFIG_BRIDGE_EBT_LIMIT=3Dy
> CONFIG_BRIDGE_EBT_MARK=3Dy
> CONFIG_BRIDGE_EBT_PKTTYPE=3Dy
> # CONFIG_BRIDGE_EBT_STP is not set
> # CONFIG_BRIDGE_EBT_VLAN is not set
> # CONFIG_BRIDGE_EBT_ARPREPLY is not set
> CONFIG_BRIDGE_EBT_DNAT=3Dy
> # CONFIG_BRIDGE_EBT_MARK_T is not set
> CONFIG_BRIDGE_EBT_REDIRECT=3Dy
> CONFIG_BRIDGE_EBT_SNAT=3Dy
> CONFIG_BRIDGE_EBT_LOG=3Dy
> # CONFIG_BRIDGE_EBT_ULOG is not set
> CONFIG_BRIDGE_EBT_NFLOG=3Dy
> CONFIG_IP_DCCP=3Dy
> CONFIG_INET_DCCP_DIAG=3Dy
>=20
> #
> # DCCP CCIDs Configuration (EXPERIMENTAL)
> #
> CONFIG_IP_DCCP_CCID2_DEBUG=3Dy
> CONFIG_IP_DCCP_CCID3=3Dy
> CONFIG_IP_DCCP_CCID3_DEBUG=3Dy
> CONFIG_IP_DCCP_CCID3_RTO=3D100
> CONFIG_IP_DCCP_TFRC_LIB=3Dy
> CONFIG_IP_DCCP_TFRC_DEBUG=3Dy
>=20
> #
> # DCCP Kernel Hacking
> #
> CONFIG_IP_DCCP_DEBUG=3Dy
> CONFIG_IP_SCTP=3Dy
> CONFIG_SCTP_DBG_MSG=3Dy
> CONFIG_SCTP_DBG_OBJCNT=3Dy
> # CONFIG_SCTP_HMAC_NONE is not set
> # CONFIG_SCTP_HMAC_SHA1 is not set
> CONFIG_SCTP_HMAC_MD5=3Dy
> # CONFIG_TIPC is not set
> # CONFIG_ATM is not set
> CONFIG_STP=3Dy
> CONFIG_BRIDGE=3Dy
> CONFIG_NET_DSA=3Dy
> CONFIG_NET_DSA_TAG_DSA=3Dy
> CONFIG_NET_DSA_TAG_EDSA=3Dy
> CONFIG_NET_DSA_TAG_TRAILER=3Dy
> CONFIG_NET_DSA_MV88E6XXX=3Dy
> CONFIG_NET_DSA_MV88E6060=3Dy
> CONFIG_NET_DSA_MV88E6XXX_NEED_PPU=3Dy
> CONFIG_NET_DSA_MV88E6131=3Dy
> CONFIG_NET_DSA_MV88E6123_61_65=3Dy
> CONFIG_VLAN_8021Q=3Dy
> # CONFIG_VLAN_8021Q_GVRP is not set
> CONFIG_DECNET=3Dy
> CONFIG_DECNET_ROUTER=3Dy
> CONFIG_LLC=3Dy
> # CONFIG_LLC2 is not set
> # CONFIG_IPX is not set
> CONFIG_ATALK=3Dy
> CONFIG_DEV_APPLETALK=3Dy
> CONFIG_IPDDP=3Dy
> # CONFIG_IPDDP_ENCAP is not set
> CONFIG_IPDDP_DECAP=3Dy
> # CONFIG_X25 is not set
> # CONFIG_LAPB is not set
> # CONFIG_ECONET is not set
> CONFIG_WAN_ROUTER=3Dy
> CONFIG_PHONET=3Dy
> CONFIG_NET_SCHED=3Dy
>=20
> #
> # Queueing/Scheduling
> #
> CONFIG_NET_SCH_CBQ=3Dy
> CONFIG_NET_SCH_HTB=3Dy
> # CONFIG_NET_SCH_HFSC is not set
> # CONFIG_NET_SCH_PRIO is not set
> # CONFIG_NET_SCH_MULTIQ is not set
> CONFIG_NET_SCH_RED=3Dy
> CONFIG_NET_SCH_SFQ=3Dy
> # CONFIG_NET_SCH_TEQL is not set
> CONFIG_NET_SCH_TBF=3Dy
> CONFIG_NET_SCH_GRED=3Dy
> CONFIG_NET_SCH_DSMARK=3Dy
> CONFIG_NET_SCH_NETEM=3Dy
> CONFIG_NET_SCH_DRR=3Dy
> CONFIG_NET_SCH_INGRESS=3Dy
>=20
> #
> # Classification
> #
> CONFIG_NET_CLS=3Dy
> # CONFIG_NET_CLS_BASIC is not set
> # CONFIG_NET_CLS_TCINDEX is not set
> CONFIG_NET_CLS_ROUTE4=3Dy
> CONFIG_NET_CLS_ROUTE=3Dy
> CONFIG_NET_CLS_FW=3Dy
> # CONFIG_NET_CLS_U32 is not set
> CONFIG_NET_CLS_RSVP=3Dy
> # CONFIG_NET_CLS_RSVP6 is not set
> CONFIG_NET_CLS_FLOW=3Dy
> CONFIG_NET_CLS_CGROUP=3Dy
> # CONFIG_NET_EMATCH is not set
> CONFIG_NET_CLS_ACT=3Dy
> CONFIG_NET_ACT_POLICE=3Dy
> CONFIG_NET_ACT_GACT=3Dy
> CONFIG_GACT_PROB=3Dy
> # CONFIG_NET_ACT_MIRRED is not set
> # CONFIG_NET_ACT_NAT is not set
> CONFIG_NET_ACT_PEDIT=3Dy
> CONFIG_NET_ACT_SIMP=3Dy
> # CONFIG_NET_ACT_SKBEDIT is not set
> CONFIG_NET_CLS_IND=3Dy
> CONFIG_NET_SCH_FIFO=3Dy
> CONFIG_DCB=3Dy
>=20
> #
> # Network testing
> #
> CONFIG_NET_PKTGEN=3Dy
> CONFIG_HAMRADIO=3Dy
>=20
> #
> # Packet Radio protocols
> #
> # CONFIG_AX25 is not set
> # CONFIG_CAN is not set
> CONFIG_IRDA=3Dy
>=20
> #
> # IrDA protocols
> #
> # CONFIG_IRLAN is not set
> CONFIG_IRCOMM=3Dy
> # CONFIG_IRDA_ULTRA is not set
>=20
> #
> # IrDA options
> #
> CONFIG_IRDA_CACHE_LAST_LSAP=3Dy
> # CONFIG_IRDA_FAST_RR is not set
> # CONFIG_IRDA_DEBUG is not set
>=20
> #
> # Infrared-port device drivers
> #
>=20
> #
> # SIR device drivers
> #
> CONFIG_IRTTY_SIR=3Dy
>=20
> #
> # Dongle support
> #
> CONFIG_DONGLE=3Dy
> # CONFIG_ESI_DONGLE is not set
> # CONFIG_ACTISYS_DONGLE is not set
> CONFIG_TEKRAM_DONGLE=3Dy
> CONFIG_TOIM3232_DONGLE=3Dy
> # CONFIG_LITELINK_DONGLE is not set
> # CONFIG_MA600_DONGLE is not set
> CONFIG_GIRBIL_DONGLE=3Dy
> # CONFIG_MCP2120_DONGLE is not set
> CONFIG_OLD_BELKIN_DONGLE=3Dy
> # CONFIG_ACT200L_DONGLE is not set
> # CONFIG_KINGSUN_DONGLE is not set
> CONFIG_KSDAZZLE_DONGLE=3Dy
> # CONFIG_KS959_DONGLE is not set
>=20
> #
> # FIR device drivers
> #
> CONFIG_USB_IRDA=3Dy
> CONFIG_SIGMATEL_FIR=3Dy
> CONFIG_NSC_FIR=3Dy
> CONFIG_WINBOND_FIR=3Dy
> # CONFIG_SMC_IRCC_FIR is not set
> CONFIG_ALI_FIR=3Dy
> CONFIG_VLSI_FIR=3Dy
> # CONFIG_VIA_FIR is not set
> # CONFIG_MCS_FIR is not set
> # CONFIG_BT is not set
> # CONFIG_AF_RXRPC is not set
> CONFIG_FIB_RULES=3Dy
> CONFIG_WIRELESS=3Dy
> # CONFIG_CFG80211 is not set
> # CONFIG_WIRELESS_OLD_REGULATORY is not set
> CONFIG_WIRELESS_EXT=3Dy
> CONFIG_WIRELESS_EXT_SYSFS=3Dy
> CONFIG_LIB80211=3Dy
> CONFIG_LIB80211_CRYPT_WEP=3Dy
> CONFIG_LIB80211_CRYPT_CCMP=3Dy
> CONFIG_LIB80211_CRYPT_TKIP=3Dy
> CONFIG_LIB80211_DEBUG=3Dy
> # CONFIG_MAC80211 is not set
> CONFIG_WIMAX=3Dy
> CONFIG_WIMAX_DEBUG_LEVEL=3D8
> CONFIG_RFKILL=3Dy
> CONFIG_RFKILL_INPUT=3Dy
> CONFIG_RFKILL_LEDS=3Dy
>=20
> #
> # Device Drivers
> #
>=20
> #
> # Generic Driver Options
> #
> CONFIG_UEVENT_HELPER_PATH=3D"/sbin/hotplug"
> CONFIG_STANDALONE=3Dy
> CONFIG_PREVENT_FIRMWARE_BUILD=3Dy
> CONFIG_FW_LOADER=3Dy
> # CONFIG_FIRMWARE_IN_KERNEL is not set
> CONFIG_EXTRA_FIRMWARE=3D""
> # CONFIG_DEBUG_DRIVER is not set
> CONFIG_DEBUG_DEVRES=3Dy
> # CONFIG_SYS_HYPERVISOR is not set
> CONFIG_CONNECTOR=3Dy
> # CONFIG_PROC_EVENTS is not set
> CONFIG_PARPORT=3Dy
> CONFIG_PARPORT_PC=3Dy
> CONFIG_PARPORT_SERIAL=3Dy
> CONFIG_PARPORT_PC_FIFO=3Dy
> # CONFIG_PARPORT_PC_SUPERIO is not set
> # CONFIG_PARPORT_GSC is not set
> CONFIG_PARPORT_AX88796=3Dy
> # CONFIG_PARPORT_1284 is not set
> CONFIG_PARPORT_NOT_PC=3Dy
> CONFIG_BLK_DEV=3Dy
> CONFIG_BLK_DEV_FD=3Dy
> CONFIG_BLK_CPQ_DA=3Dy
> # CONFIG_BLK_CPQ_CISS_DA is not set
> CONFIG_BLK_DEV_DAC960=3Dy
> # CONFIG_BLK_DEV_UMEM is not set
> # CONFIG_BLK_DEV_COW_COMMON is not set
> CONFIG_BLK_DEV_LOOP=3Dy
> CONFIG_BLK_DEV_CRYPTOLOOP=3Dy
> CONFIG_BLK_DEV_NBD=3Dy
> CONFIG_BLK_DEV_SX8=3Dy
> # CONFIG_BLK_DEV_UB is not set
> # CONFIG_BLK_DEV_RAM is not set
> CONFIG_CDROM_PKTCDVD=3Dy
> CONFIG_CDROM_PKTCDVD_BUFFERS=3D8
> # CONFIG_CDROM_PKTCDVD_WCACHE is not set
> CONFIG_ATA_OVER_ETH=3Dy
> CONFIG_XEN_BLKDEV_FRONTEND=3Dy
> CONFIG_BLK_DEV_HD=3Dy
> # CONFIG_MISC_DEVICES is not set
> CONFIG_TIFM_CORE=3Dy
> CONFIG_HAVE_IDE=3Dy
>=20
> #
> # SCSI device support
> #
> CONFIG_RAID_ATTRS=3Dy
> CONFIG_SCSI=3Dy
> CONFIG_SCSI_DMA=3Dy
> CONFIG_SCSI_TGT=3Dy
> CONFIG_SCSI_NETLINK=3Dy
> CONFIG_SCSI_PROC_FS=3Dy
>=20
> #
> # SCSI support type (disk, tape, CD-ROM)
> #
> CONFIG_BLK_DEV_SD=3Dy
> CONFIG_CHR_DEV_ST=3Dy
> # CONFIG_CHR_DEV_OSST is not set
> CONFIG_BLK_DEV_SR=3Dy
> CONFIG_BLK_DEV_SR_VENDOR=3Dy
> CONFIG_CHR_DEV_SG=3Dy
> CONFIG_CHR_DEV_SCH=3Dy
>=20
> #
> # Some SCSI devices (e.g. CD jukebox) support multiple LUNs
> #
> CONFIG_SCSI_MULTI_LUN=3Dy
> CONFIG_SCSI_CONSTANTS=3Dy
> # CONFIG_SCSI_LOGGING is not set
> # CONFIG_SCSI_SCAN_ASYNC is not set
>=20
> #
> # SCSI Transports
> #
> CONFIG_SCSI_SPI_ATTRS=3Dy
> CONFIG_SCSI_FC_ATTRS=3Dy
> CONFIG_SCSI_FC_TGT_ATTRS=3Dy
> CONFIG_SCSI_ISCSI_ATTRS=3Dy
> CONFIG_SCSI_SAS_ATTRS=3Dy
> # CONFIG_SCSI_LOWLEVEL is not set
> CONFIG_SCSI_AIC7XXX=3Dy
> CONFIG_SCSI_DH=3Dy
> CONFIG_SCSI_DH_RDAC=3Dy
> # CONFIG_SCSI_DH_HP_SW is not set
> CONFIG_SCSI_DH_EMC=3Dy
> CONFIG_SCSI_DH_ALUA=3Dy
> CONFIG_SCSI_OSD_INITIATOR=3Dy
> CONFIG_SCSI_OSD_ULD=3Dy
> CONFIG_SCSI_OSD_DPRINT_SENSE=3D1
> # CONFIG_SCSI_OSD_DEBUG is not set
> CONFIG_ATA=3Dy
> # CONFIG_ATA_NONSTANDARD is not set
> # CONFIG_SATA_PMP is not set
> CONFIG_SATA_AHCI=3Dy
> # CONFIG_SATA_SIL24 is not set
> CONFIG_ATA_SFF=3Dy
> CONFIG_SATA_SVW=3Dy
> CONFIG_ATA_PIIX=3Dy
> CONFIG_SATA_MV=3Dy
> CONFIG_SATA_NV=3Dy
> CONFIG_PDC_ADMA=3Dy
> CONFIG_SATA_QSTOR=3Dy
> CONFIG_SATA_PROMISE=3Dy
> CONFIG_SATA_SX4=3Dy
> CONFIG_SATA_SIL=3Dy
> # CONFIG_SATA_SIS is not set
> CONFIG_SATA_ULI=3Dy
> # CONFIG_SATA_VIA is not set
> # CONFIG_SATA_VITESSE is not set
> # CONFIG_SATA_INIC162X is not set
> # CONFIG_PATA_ALI is not set
> CONFIG_PATA_AMD=3Dy
> # CONFIG_PATA_ARTOP is not set
> CONFIG_PATA_ATIIXP=3Dy
> # CONFIG_PATA_CMD640_PCI is not set
> CONFIG_PATA_CMD64X=3Dy
> # CONFIG_PATA_CS5520 is not set
> CONFIG_PATA_CS5530=3Dy
> CONFIG_PATA_CYPRESS=3Dy
> CONFIG_PATA_EFAR=3Dy
> CONFIG_ATA_GENERIC=3Dy
> # CONFIG_PATA_HPT366 is not set
> CONFIG_PATA_HPT37X=3Dy
> CONFIG_PATA_HPT3X2N=3Dy
> CONFIG_PATA_HPT3X3=3Dy
> # CONFIG_PATA_HPT3X3_DMA is not set
> CONFIG_PATA_IT821X=3Dy
> # CONFIG_PATA_IT8213 is not set
> CONFIG_PATA_JMICRON=3Dy
> # CONFIG_PATA_TRIFLEX is not set
> # CONFIG_PATA_MARVELL is not set
> CONFIG_PATA_MPIIX=3Dy
> CONFIG_PATA_OLDPIIX=3Dy
> # CONFIG_PATA_NETCELL is not set
> # CONFIG_PATA_NINJA32 is not set
> CONFIG_PATA_NS87410=3Dy
> CONFIG_PATA_NS87415=3Dy
> # CONFIG_PATA_OPTI is not set
> # CONFIG_PATA_OPTIDMA is not set
> CONFIG_PATA_PDC_OLD=3Dy
> CONFIG_PATA_RADISYS=3Dy
> # CONFIG_PATA_RZ1000 is not set
> # CONFIG_PATA_SC1200 is not set
> CONFIG_PATA_SERVERWORKS=3Dy
> CONFIG_PATA_PDC2027X=3Dy
> CONFIG_PATA_SIL680=3Dy
> CONFIG_PATA_SIS=3Dy
> CONFIG_PATA_VIA=3Dy
> CONFIG_PATA_WINBOND=3Dy
> CONFIG_PATA_SCH=3Dy
> CONFIG_MD=3Dy
> CONFIG_BLK_DEV_MD=3Dy
> CONFIG_MD_AUTODETECT=3Dy
> CONFIG_MD_LINEAR=3Dy
> CONFIG_MD_RAID0=3Dy
> CONFIG_MD_RAID1=3Dy
> CONFIG_MD_RAID10=3Dy
> # CONFIG_MD_RAID456 is not set
> CONFIG_MD_MULTIPATH=3Dy
> # CONFIG_MD_FAULTY is not set
> CONFIG_BLK_DEV_DM=3Dy
> # CONFIG_DM_DEBUG is not set
> CONFIG_DM_CRYPT=3Dy
> CONFIG_DM_SNAPSHOT=3Dy
> CONFIG_DM_MIRROR=3Dy
> CONFIG_DM_ZERO=3Dy
> # CONFIG_DM_MULTIPATH is not set
> # CONFIG_DM_DELAY is not set
> CONFIG_DM_UEVENT=3Dy
> CONFIG_FUSION=3Dy
> CONFIG_FUSION_SPI=3Dy
> CONFIG_FUSION_FC=3Dy
> CONFIG_FUSION_SAS=3Dy
> CONFIG_FUSION_MAX_SGE=3D128
> CONFIG_FUSION_CTL=3Dy
> CONFIG_FUSION_LAN=3Dy
> # CONFIG_FUSION_LOGGING is not set
>=20
> #
> # IEEE 1394 (FireWire) support
> #
>=20
> #
> # Enable only one of the two stacks, unless you know what you are doi=
ng
> #
> CONFIG_FIREWIRE=3Dy
> CONFIG_FIREWIRE_OHCI=3Dy
> CONFIG_FIREWIRE_OHCI_DEBUG=3Dy
> CONFIG_FIREWIRE_SBP2=3Dy
> # CONFIG_IEEE1394 is not set
> CONFIG_I2O=3Dy
> CONFIG_I2O_LCT_NOTIFY_ON_CHANGES=3Dy
> CONFIG_I2O_EXT_ADAPTEC=3Dy
> CONFIG_I2O_EXT_ADAPTEC_DMA64=3Dy
> CONFIG_I2O_BUS=3Dy
> CONFIG_I2O_BLOCK=3Dy
> CONFIG_I2O_SCSI=3Dy
> CONFIG_I2O_PROC=3Dy
> # CONFIG_MACINTOSH_DRIVERS is not set
> CONFIG_NETDEVICES=3Dy
> CONFIG_COMPAT_NET_DEV_OPS=3Dy
> CONFIG_IFB=3Dy
> # CONFIG_DUMMY is not set
> CONFIG_BONDING=3Dy
> CONFIG_MACVLAN=3Dy
> CONFIG_EQUALIZER=3Dy
> CONFIG_TUN=3Dy
> CONFIG_VETH=3Dy
> # CONFIG_ARCNET is not set
> CONFIG_PHYLIB=3Dy
>=20
> #
> # MII PHY device drivers
> #
> # CONFIG_MARVELL_PHY is not set
> CONFIG_DAVICOM_PHY=3Dy
> # CONFIG_QSEMI_PHY is not set
> CONFIG_LXT_PHY=3Dy
> CONFIG_CICADA_PHY=3Dy
> # CONFIG_VITESSE_PHY is not set
> CONFIG_SMSC_PHY=3Dy
> CONFIG_BROADCOM_PHY=3Dy
> CONFIG_ICPLUS_PHY=3Dy
> # CONFIG_REALTEK_PHY is not set
> # CONFIG_NATIONAL_PHY is not set
> CONFIG_STE10XP=3Dy
> CONFIG_LSI_ET1011C_PHY=3Dy
> # CONFIG_FIXED_PHY is not set
> CONFIG_MDIO_BITBANG=3Dy
> CONFIG_MDIO_GPIO=3Dy
> CONFIG_NET_ETHERNET=3Dy
> CONFIG_MII=3Dy
> CONFIG_HAPPYMEAL=3Dy
> CONFIG_SUNGEM=3Dy
> # CONFIG_CASSINI is not set
> # CONFIG_NET_VENDOR_3COM is not set
> CONFIG_VORTEX=3Dy
> CONFIG_ENC28J60=3Dy
> CONFIG_ENC28J60_WRITEVERIFY=3Dy
> # CONFIG_ETHOC is not set
> CONFIG_DNET=3Dy
> # CONFIG_NET_TULIP is not set
> # CONFIG_HP100 is not set
> # CONFIG_IBM_NEW_EMAC_ZMII is not set
> # CONFIG_IBM_NEW_EMAC_RGMII is not set
> # CONFIG_IBM_NEW_EMAC_TAH is not set
> # CONFIG_IBM_NEW_EMAC_EMAC4 is not set
> # CONFIG_IBM_NEW_EMAC_NO_FLOW_CTRL is not set
> # CONFIG_IBM_NEW_EMAC_MAL_CLR_ICINTSTAT is not set
> # CONFIG_IBM_NEW_EMAC_MAL_COMMON_ERR is not set
> CONFIG_NET_PCI=3Dy
> # CONFIG_PCNET32 is not set
> CONFIG_AMD8111_ETH=3Dy
> CONFIG_ADAPTEC_STARFIRE=3Dy
> CONFIG_B44=3Dy
> CONFIG_B44_PCI_AUTOSELECT=3Dy
> CONFIG_B44_PCICORE_AUTOSELECT=3Dy
> CONFIG_B44_PCI=3Dy
> CONFIG_FORCEDETH=3Dy
> CONFIG_FORCEDETH_NAPI=3Dy
> CONFIG_E100=3Dy
> # CONFIG_FEALNX is not set
> # CONFIG_NATSEMI is not set
> CONFIG_NE2K_PCI=3Dy
> CONFIG_8139CP=3Dy
> CONFIG_8139TOO=3Dy
> # CONFIG_8139TOO_PIO is not set
> CONFIG_8139TOO_TUNE_TWISTER=3Dy
> # CONFIG_8139TOO_8129 is not set
> CONFIG_8139_OLD_RX_RESET=3Dy
> CONFIG_R6040=3Dy
> # CONFIG_SIS900 is not set
> CONFIG_EPIC100=3Dy
> # CONFIG_SMSC9420 is not set
> # CONFIG_SUNDANCE is not set
> CONFIG_TLAN=3Dy
> # CONFIG_VIA_RHINE is not set
> CONFIG_SC92031=3Dy
> CONFIG_NET_POCKET=3Dy
> # CONFIG_ATP is not set
> CONFIG_DE600=3Dy
> CONFIG_DE620=3Dy
> CONFIG_ATL2=3Dy
> CONFIG_NETDEV_1000=3Dy
> # CONFIG_ACENIC is not set
> # CONFIG_DL2K is not set
> # CONFIG_E1000 is not set
> CONFIG_E1000E=3Dy
> CONFIG_IP1000=3Dy
> CONFIG_IGB=3Dy
> # CONFIG_IGB_DCA is not set
> # CONFIG_IGBVF is not set
> CONFIG_NS83820=3Dy
> CONFIG_HAMACHI=3Dy
> CONFIG_YELLOWFIN=3Dy
> # CONFIG_R8169 is not set
> CONFIG_SIS190=3Dy
> # CONFIG_SKGE is not set
> # CONFIG_SKY2 is not set
> # CONFIG_VIA_VELOCITY is not set
> CONFIG_TIGON3=3Dy
> CONFIG_BNX2=3Dy
> CONFIG_QLA3XXX=3Dy
> CONFIG_ATL1=3Dy
> CONFIG_ATL1E=3Dy
> # CONFIG_ATL1C is not set
> # CONFIG_JME is not set
> CONFIG_NETDEV_10000=3Dy
> CONFIG_CHELSIO_T1=3Dy
> CONFIG_CHELSIO_T1_1G=3Dy
> CONFIG_CHELSIO_T3_DEPENDS=3Dy
> CONFIG_CHELSIO_T3=3Dy
> CONFIG_ENIC=3Dy
> CONFIG_IXGBE=3Dy
> CONFIG_IXGBE_DCA=3Dy
> CONFIG_IXGBE_DCB=3Dy
> CONFIG_IXGB=3Dy
> CONFIG_S2IO=3Dy
> CONFIG_MYRI10GE=3Dy
> CONFIG_MYRI10GE_DCA=3Dy
> CONFIG_NIU=3Dy
> # CONFIG_MLX4_EN is not set
> # CONFIG_MLX4_CORE is not set
> # CONFIG_TEHUTI is not set
> CONFIG_BNX2X=3Dy
> CONFIG_QLGE=3Dy
> CONFIG_SFC=3Dy
> # CONFIG_BE2NET is not set
> # CONFIG_TR is not set
>=20
> #
> # Wireless LAN
> #
> # CONFIG_WLAN_PRE80211 is not set
> CONFIG_WLAN_80211=3Dy
> CONFIG_LIBERTAS=3Dy
> CONFIG_LIBERTAS_USB=3Dy
> CONFIG_LIBERTAS_SDIO=3Dy
> CONFIG_LIBERTAS_SPI=3Dy
> CONFIG_LIBERTAS_DEBUG=3Dy
> CONFIG_AIRO=3Dy
> # CONFIG_ATMEL is not set
> CONFIG_PRISM54=3Dy
> CONFIG_USB_ZD1201=3Dy
> CONFIG_USB_NET_RNDIS_WLAN=3Dy
> CONFIG_IPW2100=3Dy
> CONFIG_IPW2100_MONITOR=3Dy
> CONFIG_IPW2100_DEBUG=3Dy
> CONFIG_IPW2200=3Dy
> CONFIG_IPW2200_MONITOR=3Dy
> CONFIG_IPW2200_RADIOTAP=3Dy
> CONFIG_IPW2200_PROMISCUOUS=3Dy
> CONFIG_IPW2200_QOS=3Dy
> CONFIG_IPW2200_DEBUG=3Dy
> CONFIG_LIBIPW=3Dy
> # CONFIG_LIBIPW_DEBUG is not set
> CONFIG_HOSTAP=3Dy
> CONFIG_HOSTAP_FIRMWARE=3Dy
> # CONFIG_HOSTAP_FIRMWARE_NVRAM is not set
> # CONFIG_HOSTAP_PLX is not set
> CONFIG_HOSTAP_PCI=3Dy
> CONFIG_HERMES=3Dy
> CONFIG_HERMES_CACHE_FW_ON_INIT=3Dy
> CONFIG_PLX_HERMES=3Dy
> # CONFIG_TMD_HERMES is not set
> CONFIG_NORTEL_HERMES=3Dy
> CONFIG_PCI_HERMES=3Dy
>=20
> #
> # WiMAX Wireless Broadband devices
> #
> CONFIG_WIMAX_I2400M=3Dy
> CONFIG_WIMAX_I2400M_SDIO=3Dy
> CONFIG_WIMAX_I2400M_DEBUG_LEVEL=3D8
>=20
> #
> # USB Network Adapters
> #
> CONFIG_USB_CATC=3Dy
> CONFIG_USB_KAWETH=3Dy
> CONFIG_USB_PEGASUS=3Dy
> CONFIG_USB_RTL8150=3Dy
> CONFIG_USB_USBNET=3Dy
> CONFIG_USB_NET_AX8817X=3Dy
> CONFIG_USB_NET_CDCETHER=3Dy
> # CONFIG_USB_NET_CDC_EEM is not set
> # CONFIG_USB_NET_DM9601 is not set
> CONFIG_USB_NET_SMSC95XX=3Dy
> # CONFIG_USB_NET_GL620A is not set
> CONFIG_USB_NET_NET1080=3Dy
> CONFIG_USB_NET_PLUSB=3Dy
> # CONFIG_USB_NET_MCS7830 is not set
> CONFIG_USB_NET_RNDIS_HOST=3Dy
> CONFIG_USB_NET_CDC_SUBSET=3Dy
> CONFIG_USB_ALI_M5632=3Dy
> # CONFIG_USB_AN2720 is not set
> CONFIG_USB_BELKIN=3Dy
> # CONFIG_USB_ARMLINUX is not set
> CONFIG_USB_EPSON2888=3Dy
> CONFIG_USB_KC2190=3Dy
> CONFIG_USB_NET_ZAURUS=3Dy
> CONFIG_USB_HSO=3Dy
> # CONFIG_WAN is not set
> # CONFIG_XEN_NETDEV_FRONTEND is not set
> CONFIG_FDDI=3Dy
> CONFIG_DEFXX=3Dy
> # CONFIG_DEFXX_MMIO is not set
> # CONFIG_SKFP is not set
> # CONFIG_HIPPI is not set
> # CONFIG_PLIP is not set
> # CONFIG_PPP is not set
> # CONFIG_SLIP is not set
> CONFIG_NET_FC=3Dy
> CONFIG_NETCONSOLE=3Dy
> # CONFIG_NETCONSOLE_DYNAMIC is not set
> CONFIG_NETPOLL=3Dy
> CONFIG_NETPOLL_TRAP=3Dy
> CONFIG_NET_POLL_CONTROLLER=3Dy
> # CONFIG_ISDN is not set
> # CONFIG_PHONE is not set
>=20
> #
> # Input device support
> #
> CONFIG_INPUT=3Dy
> CONFIG_INPUT_FF_MEMLESS=3Dy
> CONFIG_INPUT_POLLDEV=3Dy
>=20
> #
> # Userland interfaces
> #
> CONFIG_INPUT_MOUSEDEV=3Dy
> CONFIG_INPUT_MOUSEDEV_PSAUX=3Dy
> CONFIG_INPUT_MOUSEDEV_SCREEN_X=3D1024
> CONFIG_INPUT_MOUSEDEV_SCREEN_Y=3D768
> CONFIG_INPUT_JOYDEV=3Dy
> # CONFIG_INPUT_EVDEV is not set
> # CONFIG_INPUT_EVBUG is not set
>=20
> #
> # Input Device Drivers
> #
> CONFIG_INPUT_KEYBOARD=3Dy
> CONFIG_KEYBOARD_ATKBD=3Dy
> CONFIG_KEYBOARD_SUNKBD=3Dy
> CONFIG_KEYBOARD_LKKBD=3Dy
> # CONFIG_KEYBOARD_XTKBD is not set
> CONFIG_KEYBOARD_NEWTON=3Dy
> CONFIG_KEYBOARD_STOWAWAY=3Dy
> CONFIG_KEYBOARD_GPIO=3Dy
> CONFIG_INPUT_MOUSE=3Dy
> # CONFIG_MOUSE_PS2 is not set
> CONFIG_MOUSE_SERIAL=3Dy
> CONFIG_MOUSE_APPLETOUCH=3Dy
> CONFIG_MOUSE_BCM5974=3Dy
> CONFIG_MOUSE_VSXXXAA=3Dy
> # CONFIG_MOUSE_GPIO is not set
> CONFIG_INPUT_JOYSTICK=3Dy
> CONFIG_JOYSTICK_ANALOG=3Dy
> CONFIG_JOYSTICK_A3D=3Dy
> CONFIG_JOYSTICK_ADI=3Dy
> CONFIG_JOYSTICK_COBRA=3Dy
> CONFIG_JOYSTICK_GF2K=3Dy
> CONFIG_JOYSTICK_GRIP=3Dy
> CONFIG_JOYSTICK_GRIP_MP=3Dy
> CONFIG_JOYSTICK_GUILLEMOT=3Dy
> # CONFIG_JOYSTICK_INTERACT is not set
> CONFIG_JOYSTICK_SIDEWINDER=3Dy
> CONFIG_JOYSTICK_TMDC=3Dy
> CONFIG_JOYSTICK_IFORCE=3Dy
> CONFIG_JOYSTICK_IFORCE_USB=3Dy
> CONFIG_JOYSTICK_IFORCE_232=3Dy
> CONFIG_JOYSTICK_WARRIOR=3Dy
> # CONFIG_JOYSTICK_MAGELLAN is not set
> CONFIG_JOYSTICK_SPACEORB=3Dy
> # CONFIG_JOYSTICK_SPACEBALL is not set
> CONFIG_JOYSTICK_STINGER=3Dy
> CONFIG_JOYSTICK_TWIDJOY=3Dy
> CONFIG_JOYSTICK_ZHENHUA=3Dy
> CONFIG_JOYSTICK_DB9=3Dy
> CONFIG_JOYSTICK_GAMECON=3Dy
> CONFIG_JOYSTICK_TURBOGRAFX=3Dy
> CONFIG_JOYSTICK_JOYDUMP=3Dy
> CONFIG_JOYSTICK_XPAD=3Dy
> CONFIG_JOYSTICK_XPAD_FF=3Dy
> # CONFIG_JOYSTICK_XPAD_LEDS is not set
> CONFIG_JOYSTICK_WALKERA0701=3Dy
> CONFIG_INPUT_TABLET=3Dy
> # CONFIG_TABLET_USB_ACECAD is not set
> CONFIG_TABLET_USB_AIPTEK=3Dy
> CONFIG_TABLET_USB_GTCO=3Dy
> CONFIG_TABLET_USB_KBTAB=3Dy
> CONFIG_TABLET_USB_WACOM=3Dy
> CONFIG_INPUT_TOUCHSCREEN=3Dy
> CONFIG_TOUCHSCREEN_ADS7846=3Dy
> CONFIG_TOUCHSCREEN_AD7877=3Dy
> CONFIG_TOUCHSCREEN_AD7879_I2C=3Dy
> CONFIG_TOUCHSCREEN_AD7879=3Dy
> CONFIG_TOUCHSCREEN_FUJITSU=3Dy
> # CONFIG_TOUCHSCREEN_GUNZE is not set
> # CONFIG_TOUCHSCREEN_ELO is not set
> # CONFIG_TOUCHSCREEN_WACOM_W8001 is not set
> CONFIG_TOUCHSCREEN_MTOUCH=3Dy
> CONFIG_TOUCHSCREEN_INEXIO=3Dy
> CONFIG_TOUCHSCREEN_MK712=3Dy
> CONFIG_TOUCHSCREEN_PENMOUNT=3Dy
> # CONFIG_TOUCHSCREEN_TOUCHRIGHT is not set
> # CONFIG_TOUCHSCREEN_TOUCHWIN is not set
> CONFIG_TOUCHSCREEN_USB_COMPOSITE=3Dy
> CONFIG_TOUCHSCREEN_USB_EGALAX=3Dy
> CONFIG_TOUCHSCREEN_USB_PANJIT=3Dy
> CONFIG_TOUCHSCREEN_USB_3M=3Dy
> CONFIG_TOUCHSCREEN_USB_ITM=3Dy
> CONFIG_TOUCHSCREEN_USB_ETURBO=3Dy
> CONFIG_TOUCHSCREEN_USB_GUNZE=3Dy
> CONFIG_TOUCHSCREEN_USB_DMC_TSC10=3Dy
> CONFIG_TOUCHSCREEN_USB_IRTOUCH=3Dy
> CONFIG_TOUCHSCREEN_USB_IDEALTEK=3Dy
> CONFIG_TOUCHSCREEN_USB_GENERAL_TOUCH=3Dy
> CONFIG_TOUCHSCREEN_USB_GOTOP=3Dy
> # CONFIG_TOUCHSCREEN_TOUCHIT213 is not set
> CONFIG_TOUCHSCREEN_TSC2007=3Dy
> CONFIG_INPUT_MISC=3Dy
> CONFIG_INPUT_PCSPKR=3Dy
> # CONFIG_INPUT_APANEL is not set
> # CONFIG_INPUT_ATI_REMOTE is not set
> CONFIG_INPUT_ATI_REMOTE2=3Dy
> CONFIG_INPUT_KEYSPAN_REMOTE=3Dy
> CONFIG_INPUT_POWERMATE=3Dy
> # CONFIG_INPUT_YEALINK is not set
> CONFIG_INPUT_CM109=3Dy
> CONFIG_INPUT_UINPUT=3Dy
> CONFIG_INPUT_PCF50633_PMU=3Dy
> CONFIG_INPUT_GPIO_ROTARY_ENCODER=3Dy
>=20
> #
> # Hardware I/O ports
> #
> CONFIG_SERIO=3Dy
> CONFIG_SERIO_I8042=3Dy
> CONFIG_SERIO_SERPORT=3Dy
> CONFIG_SERIO_CT82C710=3Dy
> CONFIG_SERIO_PARKBD=3Dy
> # CONFIG_SERIO_PCIPS2 is not set
> CONFIG_SERIO_LIBPS2=3Dy
> CONFIG_SERIO_RAW=3Dy
> CONFIG_GAMEPORT=3Dy
> # CONFIG_GAMEPORT_NS558 is not set
> CONFIG_GAMEPORT_L4=3Dy
> CONFIG_GAMEPORT_EMU10K1=3Dy
> CONFIG_GAMEPORT_FM801=3Dy
>=20
> #
> # Character devices
> #
> CONFIG_VT=3Dy
> CONFIG_CONSOLE_TRANSLATIONS=3Dy
> CONFIG_VT_CONSOLE=3Dy
> CONFIG_HW_CONSOLE=3Dy
> CONFIG_VT_HW_CONSOLE_BINDING=3Dy
> CONFIG_DEVKMEM=3Dy
> CONFIG_SERIAL_NONSTANDARD=3Dy
> CONFIG_COMPUTONE=3Dy
> # CONFIG_ROCKETPORT is not set
> # CONFIG_CYCLADES is not set
> CONFIG_DIGIEPCA=3Dy
> CONFIG_MOXA_INTELLIO=3Dy
> # CONFIG_MOXA_SMARTIO is not set
> # CONFIG_ISI is not set
> CONFIG_SYNCLINK=3Dy
> CONFIG_SYNCLINKMP=3Dy
> CONFIG_SYNCLINK_GT=3Dy
> # CONFIG_N_HDLC is not set
> CONFIG_RISCOM8=3Dy
> CONFIG_SPECIALIX=3Dy
> CONFIG_SX=3Dy
> # CONFIG_RIO is not set
> CONFIG_STALDRV=3Dy
> # CONFIG_STALLION is not set
> # CONFIG_ISTALLION is not set
> # CONFIG_NOZOMI is not set
>=20
> #
> # Serial drivers
> #
> CONFIG_SERIAL_8250=3Dy
> CONFIG_SERIAL_8250_CONSOLE=3Dy
> CONFIG_FIX_EARLYCON_MEM=3Dy
> CONFIG_SERIAL_8250_PCI=3Dy
> CONFIG_SERIAL_8250_NR_UARTS=3D4
> CONFIG_SERIAL_8250_RUNTIME_UARTS=3D4
> # CONFIG_SERIAL_8250_EXTENDED is not set
>=20
> #
> # Non-8250 serial port support
> #
> CONFIG_SERIAL_CORE=3Dy
> CONFIG_SERIAL_CORE_CONSOLE=3Dy
> CONFIG_CONSOLE_POLL=3Dy
> CONFIG_SERIAL_JSM=3Dy
> CONFIG_UNIX98_PTYS=3Dy
> # CONFIG_DEVPTS_MULTIPLE_INSTANCES is not set
> CONFIG_LEGACY_PTYS=3Dy
> CONFIG_LEGACY_PTY_COUNT=3D256
> CONFIG_PRINTER=3Dy
> CONFIG_LP_CONSOLE=3Dy
> # CONFIG_PPDEV is not set
> # CONFIG_HVC_XEN is not set
> CONFIG_IPMI_HANDLER=3Dy
> # CONFIG_IPMI_PANIC_EVENT is not set
> CONFIG_IPMI_DEVICE_INTERFACE=3Dy
> CONFIG_IPMI_SI=3Dy
> # CONFIG_IPMI_WATCHDOG is not set
> CONFIG_IPMI_POWEROFF=3Dy
> CONFIG_HW_RANDOM=3Dy
> # CONFIG_HW_RANDOM_TIMERIOMEM is not set
> CONFIG_HW_RANDOM_INTEL=3Dy
> CONFIG_HW_RANDOM_AMD=3Dy
> # CONFIG_NVRAM is not set
> # CONFIG_RTC is not set
> CONFIG_GEN_RTC=3Dy
> # CONFIG_GEN_RTC_X is not set
> # CONFIG_R3964 is not set
> CONFIG_APPLICOM=3Dy
> CONFIG_MWAVE=3Dy
> CONFIG_PC8736x_GPIO=3Dy
> CONFIG_NSC_GPIO=3Dy
> CONFIG_RAW_DRIVER=3Dy
> CONFIG_MAX_RAW_DEVS=3D256
> CONFIG_HANGCHECK_TIMER=3Dy
> CONFIG_TCG_TPM=3Dy
> CONFIG_TCG_NSC=3Dy
> CONFIG_TCG_ATMEL=3Dy
> CONFIG_TELCLOCK=3Dy
> CONFIG_DEVPORT=3Dy
> CONFIG_I2C=3Dy
> CONFIG_I2C_BOARDINFO=3Dy
> # CONFIG_I2C_CHARDEV is not set
> # CONFIG_I2C_HELPER_AUTO is not set
>=20
> #
> # I2C Algorithms
> #
> CONFIG_I2C_ALGOBIT=3Dy
> CONFIG_I2C_ALGOPCF=3Dy
> CONFIG_I2C_ALGOPCA=3Dy
>=20
> #
> # I2C Hardware Bus support
> #
>=20
> #
> # PC SMBus host controller drivers
> #
> # CONFIG_I2C_ALI1535 is not set
> CONFIG_I2C_ALI1563=3Dy
> CONFIG_I2C_ALI15X3=3Dy
> CONFIG_I2C_AMD756=3Dy
> CONFIG_I2C_AMD8111=3Dy
> CONFIG_I2C_I801=3Dy
> CONFIG_I2C_ISCH=3Dy
> CONFIG_I2C_PIIX4=3Dy
> CONFIG_I2C_NFORCE2=3Dy
> CONFIG_I2C_SIS5595=3Dy
> # CONFIG_I2C_SIS630 is not set
> CONFIG_I2C_SIS96X=3Dy
> CONFIG_I2C_VIA=3Dy
> # CONFIG_I2C_VIAPRO is not set
>=20
> #
> # I2C system bus drivers (mostly embedded / system-on-chip)
> #
> # CONFIG_I2C_GPIO is not set
> CONFIG_I2C_OCORES=3Dy
> CONFIG_I2C_SIMTEC=3Dy
>=20
> #
> # External I2C/SMBus adapter drivers
> #
> # CONFIG_I2C_PARPORT is not set
> CONFIG_I2C_PARPORT_LIGHT=3Dy
> CONFIG_I2C_TAOS_EVM=3Dy
> # CONFIG_I2C_TINY_USB is not set
>=20
> #
> # Graphics adapter I2C/DDC channel drivers
> #
> CONFIG_I2C_VOODOO3=3Dy
>=20
> #
> # Other I2C/SMBus bus drivers
> #
> CONFIG_I2C_PCA_PLATFORM=3Dy
>=20
> #
> # Miscellaneous I2C Chip support
> #
> CONFIG_DS1682=3Dy
> CONFIG_SENSORS_PCF8574=3Dy
> CONFIG_PCF8575=3Dy
> CONFIG_SENSORS_PCA9539=3Dy
> # CONFIG_SENSORS_MAX6875 is not set
> CONFIG_SENSORS_TSL2550=3Dy
> CONFIG_I2C_DEBUG_CORE=3Dy
> CONFIG_I2C_DEBUG_ALGO=3Dy
> CONFIG_I2C_DEBUG_BUS=3Dy
> # CONFIG_I2C_DEBUG_CHIP is not set
> CONFIG_SPI=3Dy
> CONFIG_SPI_DEBUG=3Dy
> CONFIG_SPI_MASTER=3Dy
>=20
> #
> # SPI Master Controller Drivers
> #
> CONFIG_SPI_BITBANG=3Dy
> CONFIG_SPI_BUTTERFLY=3Dy
> CONFIG_SPI_GPIO=3Dy
> # CONFIG_SPI_LM70_LLP is not set
>=20
> #
> # SPI Protocol Masters
> #
> # CONFIG_SPI_SPIDEV is not set
> # CONFIG_SPI_TLE62X0 is not set
> CONFIG_ARCH_WANT_OPTIONAL_GPIOLIB=3Dy
> CONFIG_GPIOLIB=3Dy
> CONFIG_DEBUG_GPIO=3Dy
> CONFIG_GPIO_SYSFS=3Dy
>=20
> #
> # Memory mapped GPIO expanders:
> #
>=20
> #
> # I2C GPIO expanders:
> #
> CONFIG_GPIO_MAX732X=3Dy
> # CONFIG_GPIO_PCA953X is not set
> # CONFIG_GPIO_PCF857X is not set
> CONFIG_GPIO_TWL4030=3Dy
>=20
> #
> # PCI GPIO expanders:
> #
> CONFIG_GPIO_BT8XX=3Dy
>=20
> #
> # SPI GPIO expanders:
> #
> CONFIG_GPIO_MAX7301=3Dy
> CONFIG_GPIO_MCP23S08=3Dy
> CONFIG_W1=3Dy
> CONFIG_W1_CON=3Dy
>=20
> #
> # 1-wire Bus Masters
> #
> CONFIG_W1_MASTER_MATROX=3Dy
> # CONFIG_W1_MASTER_DS2490 is not set
> CONFIG_W1_MASTER_DS2482=3Dy
> CONFIG_W1_MASTER_GPIO=3Dy
>=20
> #
> # 1-wire Slaves
> #
> # CONFIG_W1_SLAVE_THERM is not set
> CONFIG_W1_SLAVE_SMEM=3Dy
> # CONFIG_W1_SLAVE_DS2431 is not set
> CONFIG_W1_SLAVE_DS2433=3Dy
> CONFIG_W1_SLAVE_DS2433_CRC=3Dy
> CONFIG_W1_SLAVE_DS2760=3Dy
> CONFIG_W1_SLAVE_BQ27000=3Dy
> CONFIG_POWER_SUPPLY=3Dy
> # CONFIG_POWER_SUPPLY_DEBUG is not set
> # CONFIG_PDA_POWER is not set
> CONFIG_BATTERY_DS2760=3Dy
> CONFIG_BATTERY_BQ27x00=3Dy
> # CONFIG_CHARGER_PCF50633 is not set
> # CONFIG_HWMON is not set
> CONFIG_THERMAL=3Dy
> CONFIG_WATCHDOG=3Dy
> # CONFIG_WATCHDOG_NOWAYOUT is not set
>=20
> #
> # Watchdog Device Drivers
> #
> # CONFIG_SOFT_WATCHDOG is not set
> CONFIG_ACQUIRE_WDT=3Dy
> CONFIG_ADVANTECH_WDT=3Dy
> # CONFIG_ALIM1535_WDT is not set
> # CONFIG_ALIM7101_WDT is not set
> CONFIG_SC520_WDT=3Dy
> CONFIG_IB700_WDT=3Dy
> # CONFIG_IBMASR is not set
> CONFIG_WAFER_WDT=3Dy
> CONFIG_I6300ESB_WDT=3Dy
> CONFIG_ITCO_WDT=3Dy
> CONFIG_ITCO_VENDOR_SUPPORT=3Dy
> # CONFIG_IT8712F_WDT is not set
> CONFIG_IT87_WDT=3Dy
> CONFIG_HP_WATCHDOG=3Dy
> # CONFIG_SC1200_WDT is not set
> # CONFIG_PC87413_WDT is not set
> CONFIG_60XX_WDT=3Dy
> CONFIG_SBC8360_WDT=3Dy
> CONFIG_CPU5_WDT=3Dy
> CONFIG_SMSC_SCH311X_WDT=3Dy
> CONFIG_SMSC37B787_WDT=3Dy
> CONFIG_W83627HF_WDT=3Dy
> CONFIG_W83877F_WDT=3Dy
> CONFIG_W83977F_WDT=3Dy
> CONFIG_MACHZ_WDT=3Dy
> CONFIG_SBC_EPX_C3_WATCHDOG=3Dy
>=20
> #
> # PCI-based Watchdog Cards
> #
> CONFIG_PCIPCWATCHDOG=3Dy
> CONFIG_WDTPCI=3Dy
> CONFIG_WDT_501_PCI=3Dy
>=20
> #
> # USB-based Watchdog Cards
> #
> # CONFIG_USBPCWATCHDOG is not set
> CONFIG_SSB_POSSIBLE=3Dy
>=20
> #
> # Sonics Silicon Backplane
> #
> CONFIG_SSB=3Dy
> CONFIG_SSB_SPROM=3Dy
> CONFIG_SSB_PCIHOST_POSSIBLE=3Dy
> CONFIG_SSB_PCIHOST=3Dy
> # CONFIG_SSB_B43_PCI_BRIDGE is not set
> CONFIG_SSB_DEBUG=3Dy
> CONFIG_SSB_DRIVER_PCICORE_POSSIBLE=3Dy
> CONFIG_SSB_DRIVER_PCICORE=3Dy
>=20
> #
> # Multifunction device drivers
> #
> CONFIG_MFD_CORE=3Dy
> # CONFIG_MFD_SM501 is not set
> CONFIG_HTC_PASIC3=3Dy
> CONFIG_TPS65010=3Dy
> CONFIG_TWL4030_CORE=3Dy
> # CONFIG_MFD_TMIO is not set
> # CONFIG_PMIC_DA903X is not set
> CONFIG_MFD_WM8400=3Dy
> CONFIG_MFD_PCF50633=3Dy
> # CONFIG_PCF50633_ADC is not set
> CONFIG_PCF50633_GPIO=3Dy
> CONFIG_REGULATOR=3Dy
> # CONFIG_REGULATOR_DEBUG is not set
> CONFIG_REGULATOR_FIXED_VOLTAGE=3Dy
> CONFIG_REGULATOR_VIRTUAL_CONSUMER=3Dy
> CONFIG_REGULATOR_BQ24022=3Dy
> # CONFIG_REGULATOR_TWL4030 is not set
> # CONFIG_REGULATOR_WM8400 is not set
> CONFIG_REGULATOR_PCF50633=3Dy
>=20
> #
> # Multimedia devices
> #
>=20
> #
> # Multimedia core support
> #
> CONFIG_VIDEO_DEV=3Dy
> CONFIG_VIDEO_V4L2_COMMON=3Dy
> CONFIG_VIDEO_ALLOW_V4L1=3Dy
> CONFIG_VIDEO_V4L1_COMPAT=3Dy
> CONFIG_DVB_CORE=3Dy
> CONFIG_VIDEO_MEDIA=3Dy
>=20
> #
> # Multimedia drivers
> #
> CONFIG_VIDEO_SAA7146=3Dy
> CONFIG_VIDEO_SAA7146_VV=3Dy
> CONFIG_MEDIA_TUNER=3Dy
> CONFIG_MEDIA_TUNER_CUSTOMISE=3Dy
> CONFIG_MEDIA_TUNER_SIMPLE=3Dy
> CONFIG_MEDIA_TUNER_TDA8290=3Dy
> CONFIG_MEDIA_TUNER_TDA827X=3Dy
> CONFIG_MEDIA_TUNER_TDA18271=3Dy
> CONFIG_MEDIA_TUNER_TDA9887=3Dy
> CONFIG_MEDIA_TUNER_TEA5761=3Dy
> # CONFIG_MEDIA_TUNER_TEA5767 is not set
> CONFIG_MEDIA_TUNER_MT20XX=3Dy
> CONFIG_MEDIA_TUNER_MT2060=3Dy
> CONFIG_MEDIA_TUNER_MT2266=3Dy
> CONFIG_MEDIA_TUNER_MT2131=3Dy
> CONFIG_MEDIA_TUNER_QT1010=3Dy
> # CONFIG_MEDIA_TUNER_XC2028 is not set
> CONFIG_MEDIA_TUNER_XC5000=3Dy
> # CONFIG_MEDIA_TUNER_MXL5005S is not set
> CONFIG_MEDIA_TUNER_MXL5007T=3Dy
> CONFIG_MEDIA_TUNER_MC44S803=3Dy
> CONFIG_VIDEO_V4L2=3Dy
> CONFIG_VIDEO_V4L1=3Dy
> CONFIG_VIDEOBUF_GEN=3Dy
> CONFIG_VIDEOBUF_DMA_SG=3Dy
> CONFIG_VIDEOBUF_VMALLOC=3Dy
> CONFIG_VIDEOBUF_DVB=3Dy
> CONFIG_VIDEO_BTCX=3Dy
> CONFIG_VIDEO_IR=3Dy
> CONFIG_VIDEO_TVEEPROM=3Dy
> CONFIG_VIDEO_TUNER=3Dy
> CONFIG_VIDEO_CAPTURE_DRIVERS=3Dy
> # CONFIG_VIDEO_ADV_DEBUG is not set
> CONFIG_VIDEO_FIXED_MINOR_RANGES=3Dy
> CONFIG_VIDEO_HELPER_CHIPS_AUTO=3Dy
> CONFIG_VIDEO_IR_I2C=3Dy
> CONFIG_VIDEO_MSP3400=3Dy
> CONFIG_VIDEO_CS53L32A=3Dy
> CONFIG_VIDEO_M52790=3Dy
> CONFIG_VIDEO_WM8775=3Dy
> CONFIG_VIDEO_WM8739=3Dy
> CONFIG_VIDEO_VP27SMPX=3Dy
> CONFIG_VIDEO_SAA6588=3Dy
> CONFIG_VIDEO_SAA711X=3Dy
> CONFIG_VIDEO_SAA717X=3Dy
> CONFIG_VIDEO_TVP5150=3Dy
> CONFIG_VIDEO_CX25840=3Dy
> CONFIG_VIDEO_CX2341X=3Dy
> CONFIG_VIDEO_SAA7127=3Dy
> CONFIG_VIDEO_UPD64031A=3Dy
> CONFIG_VIDEO_UPD64083=3Dy
> CONFIG_VIDEO_VIVI=3Dy
> # CONFIG_VIDEO_BT848 is not set
> # CONFIG_VIDEO_CPIA is not set
> CONFIG_VIDEO_CPIA2=3Dy
> # CONFIG_VIDEO_SAA5246A is not set
> # CONFIG_VIDEO_SAA5249 is not set
> # CONFIG_VIDEO_STRADIS is not set
> # CONFIG_VIDEO_ZORAN is not set
> CONFIG_VIDEO_SAA7134=3Dy
> # CONFIG_VIDEO_SAA7134_DVB is not set
> # CONFIG_VIDEO_MXB is not set
> # CONFIG_VIDEO_HEXIUM_ORION is not set
> CONFIG_VIDEO_HEXIUM_GEMINI=3Dy
> CONFIG_VIDEO_CX23885=3Dy
> CONFIG_VIDEO_IVTV=3Dy
> # CONFIG_VIDEO_CX18 is not set
> # CONFIG_VIDEO_CAFE_CCIC is not set
> # CONFIG_SOC_CAMERA is not set
> CONFIG_V4L_USB_DRIVERS=3Dy
> # CONFIG_USB_VIDEO_CLASS is not set
> CONFIG_USB_VIDEO_CLASS_INPUT_EVDEV=3Dy
> CONFIG_USB_GSPCA=3Dy
> CONFIG_USB_M5602=3Dy
> CONFIG_USB_STV06XX=3Dy
> CONFIG_USB_GSPCA_CONEX=3Dy
> CONFIG_USB_GSPCA_ETOMS=3Dy
> # CONFIG_USB_GSPCA_FINEPIX is not set
> CONFIG_USB_GSPCA_MARS=3Dy
> CONFIG_USB_GSPCA_MR97310A=3Dy
> # CONFIG_USB_GSPCA_OV519 is not set
> CONFIG_USB_GSPCA_OV534=3Dy
> # CONFIG_USB_GSPCA_PAC207 is not set
> CONFIG_USB_GSPCA_PAC7311=3Dy
> CONFIG_USB_GSPCA_SONIXB=3Dy
> # CONFIG_USB_GSPCA_SONIXJ is not set
> CONFIG_USB_GSPCA_SPCA500=3Dy
> # CONFIG_USB_GSPCA_SPCA501 is not set
> # CONFIG_USB_GSPCA_SPCA505 is not set
> # CONFIG_USB_GSPCA_SPCA506 is not set
> CONFIG_USB_GSPCA_SPCA508=3Dy
> # CONFIG_USB_GSPCA_SPCA561 is not set
> CONFIG_USB_GSPCA_SQ905=3Dy
> CONFIG_USB_GSPCA_SQ905C=3Dy
> # CONFIG_USB_GSPCA_STK014 is not set
> # CONFIG_USB_GSPCA_SUNPLUS is not set
> CONFIG_USB_GSPCA_T613=3Dy
> CONFIG_USB_GSPCA_TV8532=3Dy
> CONFIG_USB_GSPCA_VC032X=3Dy
> CONFIG_USB_GSPCA_ZC3XX=3Dy
> # CONFIG_VIDEO_PVRUSB2 is not set
> CONFIG_VIDEO_HDPVR=3Dy
> CONFIG_VIDEO_EM28XX=3Dy
> # CONFIG_VIDEO_EM28XX_DVB is not set
> CONFIG_VIDEO_CX231XX=3Dy
> CONFIG_VIDEO_CX231XX_DVB=3Dy
> CONFIG_VIDEO_USBVISION=3Dy
> CONFIG_VIDEO_USBVIDEO=3Dy
> # CONFIG_USB_VICAM is not set
> CONFIG_USB_IBMCAM=3Dy
> CONFIG_USB_KONICAWC=3Dy
> CONFIG_USB_QUICKCAM_MESSENGER=3Dy
> # CONFIG_USB_ET61X251 is not set
> CONFIG_VIDEO_OVCAMCHIP=3Dy
> # CONFIG_USB_W9968CF is not set
> CONFIG_USB_OV511=3Dy
> # CONFIG_USB_SE401 is not set
> # CONFIG_USB_SN9C102 is not set
> CONFIG_USB_STV680=3Dy
> CONFIG_USB_ZC0301=3Dy
> CONFIG_USB_PWC=3Dy
> CONFIG_USB_PWC_DEBUG=3Dy
> CONFIG_USB_PWC_INPUT_EVDEV=3Dy
> CONFIG_USB_ZR364XX=3Dy
> # CONFIG_USB_STKWEBCAM is not set
> # CONFIG_USB_S2255 is not set
> CONFIG_RADIO_ADAPTERS=3Dy
> CONFIG_RADIO_GEMTEK_PCI=3Dy
> CONFIG_RADIO_MAXIRADIO=3Dy
> CONFIG_RADIO_MAESTRO=3Dy
> CONFIG_USB_DSBR=3Dy
> CONFIG_USB_SI470X=3Dy
> CONFIG_USB_MR800=3Dy
> CONFIG_RADIO_TEA5764=3Dy
> CONFIG_RADIO_TEA5764_XTAL=3Dy
> CONFIG_DVB_DYNAMIC_MINORS=3Dy
> CONFIG_DVB_CAPTURE_DRIVERS=3Dy
>=20
> #
> # Supported SAA7146 based PCI Adapters
> #
> CONFIG_TTPCI_EEPROM=3Dy
> # CONFIG_DVB_AV7110 is not set
> CONFIG_DVB_BUDGET_CORE=3Dy
> CONFIG_DVB_BUDGET=3Dy
> CONFIG_DVB_BUDGET_CI=3Dy
> # CONFIG_DVB_BUDGET_AV is not set
>=20
> #
> # Supported USB Adapters
> #
> CONFIG_DVB_USB=3Dy
> CONFIG_DVB_USB_DEBUG=3Dy
> CONFIG_DVB_USB_A800=3Dy
> CONFIG_DVB_USB_DIBUSB_MB=3Dy
> CONFIG_DVB_USB_DIBUSB_MB_FAULTY=3Dy
> # CONFIG_DVB_USB_DIBUSB_MC is not set
> # CONFIG_DVB_USB_DIB0700 is not set
> CONFIG_DVB_USB_UMT_010=3Dy
> CONFIG_DVB_USB_CXUSB=3Dy
> CONFIG_DVB_USB_M920X=3Dy
> # CONFIG_DVB_USB_GL861 is not set
> CONFIG_DVB_USB_AU6610=3Dy
> # CONFIG_DVB_USB_DIGITV is not set
> # CONFIG_DVB_USB_VP7045 is not set
> # CONFIG_DVB_USB_VP702X is not set
> # CONFIG_DVB_USB_GP8PSK is not set
> # CONFIG_DVB_USB_NOVA_T_USB2 is not set
> CONFIG_DVB_USB_TTUSB2=3Dy
> # CONFIG_DVB_USB_DTT200U is not set
> CONFIG_DVB_USB_OPERA1=3Dy
> # CONFIG_DVB_USB_DW2102 is not set
> CONFIG_DVB_USB_CINERGY_T2=3Dy
> CONFIG_DVB_USB_ANYSEE=3Dy
> CONFIG_DVB_USB_DTV5100=3Dy
> CONFIG_DVB_USB_AF9015=3Dy
> # CONFIG_DVB_USB_CE6230 is not set
> CONFIG_DVB_TTUSB_BUDGET=3Dy
> # CONFIG_DVB_TTUSB_DEC is not set
> CONFIG_DVB_SIANO_SMS1XXX=3Dy
> CONFIG_DVB_SIANO_SMS1XXX_SMS_IDS=3Dy
>=20
> #
> # Supported FlexCopII (B2C2) Adapters
> #
> CONFIG_DVB_B2C2_FLEXCOP=3Dy
> # CONFIG_DVB_B2C2_FLEXCOP_PCI is not set
> CONFIG_DVB_B2C2_FLEXCOP_USB=3Dy
> CONFIG_DVB_B2C2_FLEXCOP_DEBUG=3Dy
>=20
> #
> # Supported BT878 Adapters
> #
>=20
> #
> # Supported Pluto2 Adapters
> #
> CONFIG_DVB_PLUTO2=3Dy
>=20
> #
> # Supported SDMC DM1105 Adapters
> #
> CONFIG_DVB_DM1105=3Dy
>=20
> #
> # Supported DVB Frontends
> #
> CONFIG_DVB_FE_CUSTOMISE=3Dy
>=20
> #
> # Customise DVB Frontends
> #
>=20
> #
> # Multistandard (satellite) frontends
> #
> CONFIG_DVB_STB0899=3Dy
> CONFIG_DVB_STB6100=3Dy
>=20
> #
> # DVB-S (satellite) frontends
> #
> CONFIG_DVB_CX24110=3Dy
> CONFIG_DVB_CX24123=3Dy
> CONFIG_DVB_MT312=3Dy
> CONFIG_DVB_ZL10036=3Dy
> CONFIG_DVB_S5H1420=3Dy
> # CONFIG_DVB_STV0288 is not set
> CONFIG_DVB_STB6000=3Dy
> # CONFIG_DVB_STV0299 is not set
> # CONFIG_DVB_STV6110 is not set
> # CONFIG_DVB_STV0900 is not set
> # CONFIG_DVB_TDA8083 is not set
> CONFIG_DVB_TDA10086=3Dy
> # CONFIG_DVB_TDA8261 is not set
> # CONFIG_DVB_VES1X93 is not set
> CONFIG_DVB_TUNER_ITD1000=3Dy
> # CONFIG_DVB_TUNER_CX24113 is not set
> CONFIG_DVB_TDA826X=3Dy
> CONFIG_DVB_TUA6100=3Dy
> CONFIG_DVB_CX24116=3Dy
> CONFIG_DVB_SI21XX=3Dy
>=20
> #
> # DVB-T (terrestrial) frontends
> #
> # CONFIG_DVB_SP8870 is not set
> CONFIG_DVB_SP887X=3Dy
> # CONFIG_DVB_CX22700 is not set
> # CONFIG_DVB_CX22702 is not set
> # CONFIG_DVB_DRX397XD is not set
> # CONFIG_DVB_L64781 is not set
> CONFIG_DVB_TDA1004X=3Dy
> # CONFIG_DVB_NXT6000 is not set
> CONFIG_DVB_MT352=3Dy
> # CONFIG_DVB_ZL10353 is not set
> CONFIG_DVB_DIB3000MB=3Dy
> CONFIG_DVB_DIB3000MC=3Dy
> CONFIG_DVB_DIB7000M=3Dy
> # CONFIG_DVB_DIB7000P is not set
> CONFIG_DVB_TDA10048=3Dy
> CONFIG_DVB_AF9013=3Dy
>=20
> #
> # DVB-C (cable) frontends
> #
> # CONFIG_DVB_VES1820 is not set
> CONFIG_DVB_TDA10021=3Dy
> CONFIG_DVB_TDA10023=3Dy
> CONFIG_DVB_STV0297=3Dy
>=20
> #
> # ATSC (North American/Korean Terrestrial/Cable DTV) frontends
> #
> CONFIG_DVB_NXT200X=3Dy
> CONFIG_DVB_OR51211=3Dy
> # CONFIG_DVB_OR51132 is not set
> # CONFIG_DVB_BCM3510 is not set
> # CONFIG_DVB_LGDT330X is not set
> CONFIG_DVB_LGDT3304=3Dy
> CONFIG_DVB_LGDT3305=3Dy
> # CONFIG_DVB_S5H1409 is not set
> CONFIG_DVB_AU8522=3Dy
> CONFIG_DVB_S5H1411=3Dy
>=20
> #
> # ISDB-T (terrestrial) frontends
> #
> CONFIG_DVB_S921=3Dy
>=20
> #
> # Digital terrestrial only tuners/PLL
> #
> CONFIG_DVB_PLL=3Dy
> CONFIG_DVB_TUNER_DIB0070=3Dy
>=20
> #
> # SEC control devices for DVB-S
> #
> CONFIG_DVB_LNBP21=3Dy
> # CONFIG_DVB_ISL6405 is not set
> CONFIG_DVB_ISL6421=3Dy
> CONFIG_DVB_LGS8GL5=3Dy
> CONFIG_DVB_LGS8GXX=3Dy
>=20
> #
> # Tools to develop new frontends
> #
> CONFIG_DVB_DUMMY_FE=3Dy
> CONFIG_DAB=3Dy
> CONFIG_USB_DABUSB=3Dy
>=20
> #
> # Graphics support
> #
> CONFIG_AGP=3Dy
> CONFIG_AGP_AMD64=3Dy
> CONFIG_AGP_INTEL=3Dy
> CONFIG_AGP_SIS=3Dy
> CONFIG_AGP_VIA=3Dy
> # CONFIG_DRM is not set
> # CONFIG_VGASTATE is not set
> # CONFIG_VIDEO_OUTPUT_CONTROL is not set
> # CONFIG_FB is not set
> CONFIG_BACKLIGHT_LCD_SUPPORT=3Dy
> CONFIG_LCD_CLASS_DEVICE=3Dy
> CONFIG_LCD_LTV350QV=3Dy
> # CONFIG_LCD_ILI9320 is not set
> CONFIG_LCD_TDO24M=3Dy
> # CONFIG_LCD_VGG2432A4 is not set
> CONFIG_LCD_PLATFORM=3Dy
> CONFIG_BACKLIGHT_CLASS_DEVICE=3Dy
> CONFIG_BACKLIGHT_GENERIC=3Dy
> # CONFIG_BACKLIGHT_PROGEAR is not set
> CONFIG_BACKLIGHT_MBP_NVIDIA=3Dy
> CONFIG_BACKLIGHT_SAHARA=3Dy
>=20
> #
> # Display device support
> #
> # CONFIG_DISPLAY_SUPPORT is not set
>=20
> #
> # Console display driver support
> #
> CONFIG_VGA_CONSOLE=3Dy
> CONFIG_VGACON_SOFT_SCROLLBACK=3Dy
> CONFIG_VGACON_SOFT_SCROLLBACK_SIZE=3D64
> CONFIG_DUMMY_CONSOLE=3Dy
> # CONFIG_SOUND is not set
> CONFIG_HID_SUPPORT=3Dy
> CONFIG_HID=3Dy
> CONFIG_HID_DEBUG=3Dy
> # CONFIG_HIDRAW is not set
>=20
> #
> # USB Input Devices
> #
> # CONFIG_USB_HID is not set
> CONFIG_HID_PID=3Dy
> CONFIG_USB_MOUSE=3Dy
>=20
> #
> # Special HID drivers
> #
> CONFIG_USB_SUPPORT=3Dy
> CONFIG_USB_ARCH_HAS_HCD=3Dy
> CONFIG_USB_ARCH_HAS_OHCI=3Dy
> CONFIG_USB_ARCH_HAS_EHCI=3Dy
> CONFIG_USB=3Dy
> # CONFIG_USB_DEBUG is not set
> CONFIG_USB_ANNOUNCE_NEW_DEVICES=3Dy
>=20
> #
> # Miscellaneous USB options
> #
> CONFIG_USB_DEVICEFS=3Dy
> CONFIG_USB_DEVICE_CLASS=3Dy
> CONFIG_USB_DYNAMIC_MINORS=3Dy
> CONFIG_USB_SUSPEND=3Dy
> # CONFIG_USB_OTG is not set
> CONFIG_USB_MON=3Dy
> CONFIG_USB_WUSB=3Dy
> CONFIG_USB_WUSB_CBAF=3Dy
> CONFIG_USB_WUSB_CBAF_DEBUG=3Dy
>=20
> #
> # USB Host Controller Drivers
> #
> CONFIG_USB_C67X00_HCD=3Dy
> CONFIG_USB_EHCI_HCD=3Dy
> CONFIG_USB_EHCI_ROOT_HUB_TT=3Dy
> # CONFIG_USB_EHCI_TT_NEWSCHED is not set
> # CONFIG_USB_OXU210HP_HCD is not set
> CONFIG_USB_ISP116X_HCD=3Dy
> CONFIG_USB_ISP1760_HCD=3Dy
> CONFIG_USB_OHCI_HCD=3Dy
> CONFIG_USB_OHCI_HCD_SSB=3Dy
> # CONFIG_USB_OHCI_BIG_ENDIAN_DESC is not set
> # CONFIG_USB_OHCI_BIG_ENDIAN_MMIO is not set
> CONFIG_USB_OHCI_LITTLE_ENDIAN=3Dy
> CONFIG_USB_UHCI_HCD=3Dy
> # CONFIG_USB_U132_HCD is not set
> CONFIG_USB_SL811_HCD=3Dy
> # CONFIG_USB_R8A66597_HCD is not set
> CONFIG_USB_HWA_HCD=3Dy
>=20
> #
> # USB Device Class drivers
> #
> CONFIG_USB_ACM=3Dy
> CONFIG_USB_PRINTER=3Dy
> CONFIG_USB_WDM=3Dy
> CONFIG_USB_TMC=3Dy
>=20
> #
> # NOTE: USB_STORAGE depends on SCSI but BLK_DEV_SD may
> #
>=20
> #
> # also be needed; see USB_STORAGE Help for more info
> #
> CONFIG_USB_STORAGE=3Dy
> CONFIG_USB_STORAGE_DEBUG=3Dy
> CONFIG_USB_STORAGE_DATAFAB=3Dy
> CONFIG_USB_STORAGE_FREECOM=3Dy
> CONFIG_USB_STORAGE_ISD200=3Dy
> CONFIG_USB_STORAGE_USBAT=3Dy
> CONFIG_USB_STORAGE_SDDR09=3Dy
> # CONFIG_USB_STORAGE_SDDR55 is not set
> # CONFIG_USB_STORAGE_JUMPSHOT is not set
> CONFIG_USB_STORAGE_ALAUDA=3Dy
> CONFIG_USB_STORAGE_ONETOUCH=3Dy
> CONFIG_USB_STORAGE_KARMA=3Dy
> # CONFIG_USB_STORAGE_CYPRESS_ATACB is not set
> CONFIG_USB_LIBUSUAL=3Dy
>=20
> #
> # USB Imaging devices
> #
> # CONFIG_USB_MDC800 is not set
> CONFIG_USB_MICROTEK=3Dy
>=20
> #
> # USB port drivers
> #
> CONFIG_USB_USS720=3Dy
> # CONFIG_USB_SERIAL is not set
>=20
> #
> # USB Miscellaneous drivers
> #
> CONFIG_USB_EMI62=3Dy
> # CONFIG_USB_EMI26 is not set
> # CONFIG_USB_ADUTUX is not set
> # CONFIG_USB_SEVSEG is not set
> # CONFIG_USB_RIO500 is not set
> # CONFIG_USB_LEGOTOWER is not set
> CONFIG_USB_LCD=3Dy
> CONFIG_USB_BERRY_CHARGE=3Dy
> # CONFIG_USB_LED is not set
> CONFIG_USB_CYPRESS_CY7C63=3Dy
> CONFIG_USB_CYTHERM=3Dy
> CONFIG_USB_IDMOUSE=3Dy
> CONFIG_USB_FTDI_ELAN=3Dy
> # CONFIG_USB_APPLEDISPLAY is not set
> # CONFIG_USB_SISUSBVGA is not set
> # CONFIG_USB_LD is not set
> CONFIG_USB_TRANCEVIBRATOR=3Dy
> CONFIG_USB_IOWARRIOR=3Dy
> # CONFIG_USB_TEST is not set
> CONFIG_USB_ISIGHTFW=3Dy
> CONFIG_USB_VST=3Dy
>=20
> #
> # OTG and related infrastructure
> #
> CONFIG_USB_OTG_UTILS=3Dy
> CONFIG_USB_GPIO_VBUS=3Dy
> CONFIG_NOP_USB_XCEIV=3Dy
> CONFIG_UWB=3Dy
> CONFIG_UWB_HWA=3Dy
> # CONFIG_UWB_WHCI is not set
> # CONFIG_UWB_WLP is not set
> CONFIG_UWB_I1480U=3Dy
> CONFIG_MMC=3Dy
> CONFIG_MMC_DEBUG=3Dy
> CONFIG_MMC_UNSAFE_RESUME=3Dy
>=20
> #
> # MMC/SD/SDIO Card Drivers
> #
> # CONFIG_MMC_BLOCK is not set
> CONFIG_SDIO_UART=3Dy
> CONFIG_MMC_TEST=3Dy
>=20
> #
> # MMC/SD/SDIO Host Controller Drivers
> #
> # CONFIG_MMC_SDHCI is not set
> CONFIG_MMC_WBSD=3Dy
> CONFIG_MMC_TIFM_SD=3Dy
> CONFIG_MMC_SPI=3Dy
> CONFIG_MEMSTICK=3Dy
> CONFIG_MEMSTICK_DEBUG=3Dy
>=20
> #
> # MemoryStick drivers
> #
> CONFIG_MEMSTICK_UNSAFE_RESUME=3Dy
> # CONFIG_MSPRO_BLOCK is not set
>=20
> #
> # MemoryStick Host Controller Drivers
> #
> # CONFIG_MEMSTICK_TIFM_MS is not set
> CONFIG_MEMSTICK_JMICRON_38X=3Dy
> CONFIG_NEW_LEDS=3Dy
> CONFIG_LEDS_CLASS=3Dy
>=20
> #
> # LED drivers
> #
> # CONFIG_LEDS_ALIX2 is not set
> CONFIG_LEDS_PCA9532=3Dy
> # CONFIG_LEDS_GPIO is not set
> CONFIG_LEDS_LP5521=3Dy
> # CONFIG_LEDS_CLEVO_MAIL is not set
> # CONFIG_LEDS_PCA955X is not set
> # CONFIG_LEDS_DAC124S085 is not set
> CONFIG_LEDS_BD2802=3Dy
>=20
> #
> # LED Triggers
> #
> CONFIG_LEDS_TRIGGERS=3Dy
> # CONFIG_LEDS_TRIGGER_TIMER is not set
> CONFIG_LEDS_TRIGGER_HEARTBEAT=3Dy
> CONFIG_LEDS_TRIGGER_BACKLIGHT=3Dy
> CONFIG_LEDS_TRIGGER_GPIO=3Dy
> CONFIG_LEDS_TRIGGER_DEFAULT_ON=3Dy
>=20
> #
> # iptables trigger is under Netfilter config (LED target)
> #
> CONFIG_ACCESSIBILITY=3Dy
> CONFIG_A11Y_BRAILLE_CONSOLE=3Dy
> # CONFIG_EDAC is not set
> # CONFIG_RTC_CLASS is not set
> CONFIG_DMADEVICES=3Dy
>=20
> #
> # DMA Devices
> #
> CONFIG_INTEL_IOATDMA=3Dy
> CONFIG_DMA_ENGINE=3Dy
>=20
> #
> # DMA Clients
> #
> CONFIG_NET_DMA=3Dy
> CONFIG_ASYNC_TX_DMA=3Dy
> # CONFIG_DMATEST is not set
> CONFIG_DCA=3Dy
> CONFIG_AUXDISPLAY=3Dy
> # CONFIG_KS0108 is not set
> CONFIG_UIO=3Dy
> CONFIG_UIO_CIF=3Dy
> CONFIG_UIO_PDRV=3Dy
> CONFIG_UIO_PDRV_GENIRQ=3Dy
> # CONFIG_UIO_SMX is not set
> CONFIG_UIO_AEC=3Dy
> CONFIG_UIO_SERCOS3=3Dy
> CONFIG_XEN_BALLOON=3Dy
> # CONFIG_XEN_SCRUB_PAGES is not set
> # CONFIG_XEN_DEV_EVTCHN is not set
> CONFIG_XENFS=3Dy
> # CONFIG_XEN_COMPAT_XENFS is not set
> # CONFIG_XEN_SYS_HYPERVISOR is not set
> # CONFIG_X86_PLATFORM_DEVICES is not set
>=20
> #
> # Firmware Drivers
> #
> CONFIG_EDD=3Dy
> # CONFIG_EDD_OFF is not set
> CONFIG_FIRMWARE_MEMMAP=3Dy
> # CONFIG_DELL_RBU is not set
> CONFIG_DCDBAS=3Dy
> CONFIG_DMIID=3Dy
> CONFIG_ISCSI_IBFT_FIND=3Dy
> CONFIG_ISCSI_IBFT=3Dy
>=20
> #
> # File systems
> #
> CONFIG_EXT2_FS=3Dy
> # CONFIG_EXT2_FS_XATTR is not set
> # CONFIG_EXT2_FS_XIP is not set
> CONFIG_EXT3_FS=3Dy
> CONFIG_EXT3_DEFAULTS_TO_ORDERED=3Dy
> CONFIG_EXT3_FS_XATTR=3Dy
> CONFIG_EXT3_FS_POSIX_ACL=3Dy
> CONFIG_EXT3_FS_SECURITY=3Dy
> CONFIG_EXT4_FS=3Dy
> CONFIG_EXT4DEV_COMPAT=3Dy
> CONFIG_EXT4_FS_XATTR=3Dy
> CONFIG_EXT4_FS_POSIX_ACL=3Dy
> CONFIG_EXT4_FS_SECURITY=3Dy
> CONFIG_JBD=3Dy
> CONFIG_JBD_DEBUG=3Dy
> CONFIG_JBD2=3Dy
> CONFIG_JBD2_DEBUG=3Dy
> CONFIG_FS_MBCACHE=3Dy
> # CONFIG_REISERFS_FS is not set
> # CONFIG_JFS_FS is not set
> CONFIG_FS_POSIX_ACL=3Dy
> CONFIG_FILE_LOCKING=3Dy
> CONFIG_XFS_FS=3Dy
> CONFIG_XFS_QUOTA=3Dy
> CONFIG_XFS_POSIX_ACL=3Dy
> CONFIG_XFS_RT=3Dy
> # CONFIG_XFS_DEBUG is not set
> CONFIG_GFS2_FS=3Dy
> CONFIG_GFS2_FS_LOCKING_DLM=3Dy
> CONFIG_OCFS2_FS=3Dy
> CONFIG_OCFS2_FS_O2CB=3Dy
> CONFIG_OCFS2_FS_USERSPACE_CLUSTER=3Dy
> # CONFIG_OCFS2_FS_STATS is not set
> # CONFIG_OCFS2_DEBUG_MASKLOG is not set
> CONFIG_OCFS2_DEBUG_FS=3Dy
> CONFIG_OCFS2_FS_POSIX_ACL=3Dy
> CONFIG_BTRFS_FS=3Dy
> CONFIG_BTRFS_FS_POSIX_ACL=3Dy
> # CONFIG_DNOTIFY is not set
> CONFIG_INOTIFY=3Dy
> # CONFIG_INOTIFY_USER is not set
> CONFIG_QUOTA=3Dy
> CONFIG_QUOTA_NETLINK_INTERFACE=3Dy
> CONFIG_PRINT_QUOTA_WARNING=3Dy
> CONFIG_QUOTA_TREE=3Dy
> CONFIG_QFMT_V1=3Dy
> CONFIG_QFMT_V2=3Dy
> CONFIG_QUOTACTL=3Dy
> CONFIG_AUTOFS_FS=3Dy
> CONFIG_AUTOFS4_FS=3Dy
> CONFIG_FUSE_FS=3Dy
> CONFIG_GENERIC_ACL=3Dy
>=20
> #
> # Caches
> #
> CONFIG_FSCACHE=3Dy
> CONFIG_FSCACHE_STATS=3Dy
> # CONFIG_FSCACHE_HISTOGRAM is not set
> CONFIG_FSCACHE_DEBUG=3Dy
> CONFIG_CACHEFILES=3Dy
> CONFIG_CACHEFILES_DEBUG=3Dy
> # CONFIG_CACHEFILES_HISTOGRAM is not set
>=20
> #
> # CD-ROM/DVD Filesystems
> #
> # CONFIG_ISO9660_FS is not set
> # CONFIG_UDF_FS is not set
>=20
> #
> # DOS/FAT/NT Filesystems
> #
> CONFIG_FAT_FS=3Dy
> # CONFIG_MSDOS_FS is not set
> CONFIG_VFAT_FS=3Dy
> CONFIG_FAT_DEFAULT_CODEPAGE=3D437
> CONFIG_FAT_DEFAULT_IOCHARSET=3D"iso8859-1"
> CONFIG_NTFS_FS=3Dy
> CONFIG_NTFS_DEBUG=3Dy
> CONFIG_NTFS_RW=3Dy
>=20
> #
> # Pseudo filesystems
> #
> CONFIG_PROC_FS=3Dy
> CONFIG_PROC_KCORE=3Dy
> CONFIG_PROC_VMCORE=3Dy
> CONFIG_PROC_SYSCTL=3Dy
> CONFIG_PROC_PAGE_MONITOR=3Dy
> CONFIG_SYSFS=3Dy
> CONFIG_TMPFS=3Dy
> CONFIG_TMPFS_POSIX_ACL=3Dy
> CONFIG_HUGETLBFS=3Dy
> CONFIG_HUGETLB_PAGE=3Dy
> CONFIG_CONFIGFS_FS=3Dy
> # CONFIG_MISC_FILESYSTEMS is not set
> CONFIG_NETWORK_FILESYSTEMS=3Dy
> # CONFIG_NFS_FS is not set
> CONFIG_NFSD=3Dy
> CONFIG_NFSD_V2_ACL=3Dy
> CONFIG_NFSD_V3=3Dy
> CONFIG_NFSD_V3_ACL=3Dy
> CONFIG_NFSD_V4=3Dy
> CONFIG_LOCKD=3Dy
> CONFIG_LOCKD_V4=3Dy
> CONFIG_EXPORTFS=3Dy
> CONFIG_NFS_ACL_SUPPORT=3Dy
> CONFIG_NFS_COMMON=3Dy
> CONFIG_SUNRPC=3Dy
> CONFIG_SUNRPC_GSS=3Dy
> CONFIG_RPCSEC_GSS_KRB5=3Dy
> CONFIG_RPCSEC_GSS_SPKM3=3Dy
> CONFIG_SMB_FS=3Dy
> # CONFIG_SMB_NLS_DEFAULT is not set
> CONFIG_CIFS=3Dy
> CONFIG_CIFS_STATS=3Dy
> CONFIG_CIFS_STATS2=3Dy
> # CONFIG_CIFS_WEAK_PW_HASH is not set
> # CONFIG_CIFS_UPCALL is not set
> CONFIG_CIFS_XATTR=3Dy
> CONFIG_CIFS_POSIX=3Dy
> CONFIG_CIFS_DEBUG2=3Dy
> # CONFIG_CIFS_DFS_UPCALL is not set
> CONFIG_CIFS_EXPERIMENTAL=3Dy
> # CONFIG_NCP_FS is not set
> # CONFIG_CODA_FS is not set
> # CONFIG_AFS_FS is not set
>=20
> #
> # Partition Types
> #
> CONFIG_PARTITION_ADVANCED=3Dy
> CONFIG_ACORN_PARTITION=3Dy
> # CONFIG_ACORN_PARTITION_CUMANA is not set
> # CONFIG_ACORN_PARTITION_EESOX is not set
> # CONFIG_ACORN_PARTITION_ICS is not set
> CONFIG_ACORN_PARTITION_ADFS=3Dy
> CONFIG_ACORN_PARTITION_POWERTEC=3Dy
> CONFIG_ACORN_PARTITION_RISCIX=3Dy
> CONFIG_OSF_PARTITION=3Dy
> CONFIG_AMIGA_PARTITION=3Dy
> CONFIG_ATARI_PARTITION=3Dy
> CONFIG_MAC_PARTITION=3Dy
> CONFIG_MSDOS_PARTITION=3Dy
> CONFIG_BSD_DISKLABEL=3Dy
> CONFIG_MINIX_SUBPARTITION=3Dy
> CONFIG_SOLARIS_X86_PARTITION=3Dy
> # CONFIG_UNIXWARE_DISKLABEL is not set
> CONFIG_LDM_PARTITION=3Dy
> CONFIG_LDM_DEBUG=3Dy
> # CONFIG_SGI_PARTITION is not set
> # CONFIG_ULTRIX_PARTITION is not set
> CONFIG_SUN_PARTITION=3Dy
> CONFIG_KARMA_PARTITION=3Dy
> # CONFIG_EFI_PARTITION is not set
> # CONFIG_SYSV68_PARTITION is not set
> CONFIG_NLS=3Dy
> CONFIG_NLS_DEFAULT=3D"iso8859-1"
> # CONFIG_NLS_CODEPAGE_437 is not set
> CONFIG_NLS_CODEPAGE_737=3Dy
> # CONFIG_NLS_CODEPAGE_775 is not set
> # CONFIG_NLS_CODEPAGE_850 is not set
> CONFIG_NLS_CODEPAGE_852=3Dy
> # CONFIG_NLS_CODEPAGE_855 is not set
> CONFIG_NLS_CODEPAGE_857=3Dy
> CONFIG_NLS_CODEPAGE_860=3Dy
> CONFIG_NLS_CODEPAGE_861=3Dy
> # CONFIG_NLS_CODEPAGE_862 is not set
> CONFIG_NLS_CODEPAGE_863=3Dy
> CONFIG_NLS_CODEPAGE_864=3Dy
> CONFIG_NLS_CODEPAGE_865=3Dy
> # CONFIG_NLS_CODEPAGE_866 is not set
> CONFIG_NLS_CODEPAGE_869=3Dy
> CONFIG_NLS_CODEPAGE_936=3Dy
> CONFIG_NLS_CODEPAGE_950=3Dy
> CONFIG_NLS_CODEPAGE_932=3Dy
> CONFIG_NLS_CODEPAGE_949=3Dy
> CONFIG_NLS_CODEPAGE_874=3Dy
> # CONFIG_NLS_ISO8859_8 is not set
> # CONFIG_NLS_CODEPAGE_1250 is not set
> # CONFIG_NLS_CODEPAGE_1251 is not set
> # CONFIG_NLS_ASCII is not set
> CONFIG_NLS_ISO8859_1=3Dy
> # CONFIG_NLS_ISO8859_2 is not set
> # CONFIG_NLS_ISO8859_3 is not set
> CONFIG_NLS_ISO8859_4=3Dy
> CONFIG_NLS_ISO8859_5=3Dy
> CONFIG_NLS_ISO8859_6=3Dy
> # CONFIG_NLS_ISO8859_7 is not set
> # CONFIG_NLS_ISO8859_9 is not set
> # CONFIG_NLS_ISO8859_13 is not set
> # CONFIG_NLS_ISO8859_14 is not set
> # CONFIG_NLS_ISO8859_15 is not set
> CONFIG_NLS_KOI8_R=3Dy
> # CONFIG_NLS_KOI8_U is not set
> CONFIG_NLS_UTF8=3Dy
> CONFIG_DLM=3Dy
> CONFIG_DLM_DEBUG=3Dy
>=20
> #
> # Kernel hacking
> #
> CONFIG_TRACE_IRQFLAGS_SUPPORT=3Dy
> CONFIG_PRINTK_TIME=3Dy
> CONFIG_ALLOW_WARNINGS=3Dy
> # CONFIG_ENABLE_WARN_DEPRECATED is not set
> # CONFIG_ENABLE_MUST_CHECK is not set
> CONFIG_FRAME_WARN=3D2048
> CONFIG_MAGIC_SYSRQ=3Dy
> CONFIG_UNUSED_SYMBOLS=3Dy
> CONFIG_DEBUG_FS=3Dy
> CONFIG_HEADERS_CHECK=3Dy
> CONFIG_DEBUG_SECTION_MISMATCH=3Dy
> CONFIG_DEBUG_KERNEL=3Dy
> CONFIG_DEBUG_SHIRQ=3Dy
> CONFIG_DETECT_SOFTLOCKUP=3Dy
> CONFIG_BOOTPARAM_SOFTLOCKUP_PANIC=3Dy
> CONFIG_BOOTPARAM_SOFTLOCKUP_PANIC_VALUE=3D1
> # CONFIG_DETECT_HUNG_TASK is not set
> # CONFIG_SCHED_DEBUG is not set
> # CONFIG_SCHEDSTATS is not set
> # CONFIG_TIMER_STATS is not set
> CONFIG_DEBUG_OBJECTS=3Dy
> CONFIG_DEBUG_OBJECTS_SELFTEST=3Dy
> CONFIG_DEBUG_OBJECTS_FREE=3Dy
> CONFIG_DEBUG_OBJECTS_TIMERS=3Dy
> CONFIG_DEBUG_OBJECTS_ENABLE_DEFAULT=3D1
> CONFIG_SLUB_DEBUG_ON=3Dy
> CONFIG_SLUB_STATS=3Dy
> # CONFIG_DEBUG_PREEMPT is not set
> CONFIG_DEBUG_RT_MUTEXES=3Dy
> CONFIG_DEBUG_PI_LIST=3Dy
> CONFIG_RT_MUTEX_TESTER=3Dy
> CONFIG_DEBUG_SPINLOCK=3Dy
> CONFIG_DEBUG_MUTEXES=3Dy
> CONFIG_DEBUG_LOCK_ALLOC=3Dy
> # CONFIG_PROVE_LOCKING is not set
> CONFIG_LOCKDEP=3Dy
> # CONFIG_LOCK_STAT is not set
> # CONFIG_DEBUG_LOCKDEP is not set
> # CONFIG_DEBUG_SPINLOCK_SLEEP is not set
> # CONFIG_DEBUG_LOCKING_API_SELFTESTS is not set
> CONFIG_STACKTRACE=3Dy
> CONFIG_DEBUG_BUGVERBOSE=3Dy
> CONFIG_DEBUG_VM=3Dy
> CONFIG_DEBUG_VIRTUAL=3Dy
> # CONFIG_DEBUG_WRITECOUNT is not set
> CONFIG_DEBUG_MEMORY_INIT=3Dy
> CONFIG_DEBUG_LIST=3Dy
> CONFIG_DEBUG_SG=3Dy
> CONFIG_DEBUG_NOTIFIERS=3Dy
> CONFIG_ARCH_WANT_FRAME_POINTERS=3Dy
> CONFIG_FRAME_POINTER=3Dy
> CONFIG_BOOT_PRINTK_DELAY=3Dy
> CONFIG_RCU_TORTURE_TEST=3Dy
> # CONFIG_RCU_TORTURE_TEST_RUNNABLE is not set
> CONFIG_RCU_CPU_STALL_DETECTOR=3Dy
> # CONFIG_BACKTRACE_SELF_TEST is not set
> CONFIG_FAULT_INJECTION=3Dy
> # CONFIG_FAILSLAB is not set
> # CONFIG_FAIL_PAGE_ALLOC is not set
> # CONFIG_FAIL_MAKE_REQUEST is not set
> CONFIG_FAIL_IO_TIMEOUT=3Dy
> # CONFIG_FAULT_INJECTION_DEBUG_FS is not set
> # CONFIG_LATENCYTOP is not set
> # CONFIG_SYSCTL_SYSCALL_CHECK is not set
> CONFIG_DEBUG_PAGEALLOC=3Dy
> CONFIG_USER_STACKTRACE_SUPPORT=3Dy
> CONFIG_HAVE_FUNCTION_TRACER=3Dy
> CONFIG_HAVE_FUNCTION_GRAPH_TRACER=3Dy
> CONFIG_HAVE_FUNCTION_TRACE_MCOUNT_TEST=3Dy
> CONFIG_HAVE_DYNAMIC_FTRACE=3Dy
> CONFIG_HAVE_FTRACE_MCOUNT_RECORD=3Dy
> CONFIG_HAVE_HW_BRANCH_TRACER=3Dy
> CONFIG_HAVE_FTRACE_SYSCALLS=3Dy
> CONFIG_TRACING_SUPPORT=3Dy
> # CONFIG_FTRACE is not set
> CONFIG_PROVIDE_OHCI1394_DMA_INIT=3Dy
> CONFIG_FIREWIRE_OHCI_REMOTE_DMA=3Dy
> CONFIG_BUILD_DOCSRC=3Dy
> # CONFIG_DYNAMIC_DEBUG is not set
> CONFIG_DMA_API_DEBUG=3Dy
> CONFIG_SAMPLES=3Dy
> # CONFIG_SAMPLE_KOBJECT is not set
> CONFIG_HAVE_ARCH_KGDB=3Dy
> CONFIG_KGDB=3Dy
> CONFIG_KGDB_SERIAL_CONSOLE=3Dy
> # CONFIG_KGDB_TESTS is not set
> CONFIG_HAVE_ARCH_KMEMCHECK=3Dy
> # CONFIG_STRICT_DEVMEM is not set
> CONFIG_X86_VERBOSE_BOOTUP=3Dy
> CONFIG_EARLY_PRINTK=3Dy
> # CONFIG_EARLY_PRINTK_DBGP is not set
> CONFIG_DEBUG_STACKOVERFLOW=3Dy
> CONFIG_DEBUG_STACK_USAGE=3Dy
> # CONFIG_DEBUG_PER_CPU_MAPS is not set
> CONFIG_X86_PTDUMP=3Dy
> CONFIG_DEBUG_RODATA=3Dy
> CONFIG_DEBUG_RODATA_TEST=3Dy
> # CONFIG_IOMMU_DEBUG is not set
> CONFIG_IOMMU_STRESS=3Dy
> CONFIG_X86_DS_SELFTEST=3Dy
> CONFIG_HAVE_MMIOTRACE_SUPPORT=3Dy
> CONFIG_IO_DELAY_TYPE_0X80=3D0
> CONFIG_IO_DELAY_TYPE_0XED=3D1
> CONFIG_IO_DELAY_TYPE_UDELAY=3D2
> CONFIG_IO_DELAY_TYPE_NONE=3D3
> CONFIG_IO_DELAY_0X80=3Dy
> # CONFIG_IO_DELAY_0XED is not set
> # CONFIG_IO_DELAY_UDELAY is not set
> # CONFIG_IO_DELAY_NONE is not set
> CONFIG_DEFAULT_IO_DELAY_TYPE=3D0
> CONFIG_DEBUG_BOOT_PARAMS=3Dy
> CONFIG_CPA_DEBUG=3Dy
> # CONFIG_OPTIMIZE_INLINING is not set
>=20
> #
> # Security options
> #
> CONFIG_KEYS=3Dy
> # CONFIG_KEYS_DEBUG_PROC_KEYS is not set
> CONFIG_SECURITY=3Dy
> CONFIG_SECURITYFS=3Dy
> CONFIG_SECURITY_NETWORK=3Dy
> CONFIG_SECURITY_NETWORK_XFRM=3Dy
> CONFIG_SECURITY_PATH=3Dy
> CONFIG_SECURITY_FILE_CAPABILITIES=3Dy
> CONFIG_SECURITY_DEFAULT_MMAP_MIN_ADDR=3D0
> CONFIG_SECURITY_TOMOYO=3Dy
> CONFIG_CRYPTO=3Dy
>=20
> #
> # Crypto core or helper
> #
> CONFIG_CRYPTO_FIPS=3Dy
> CONFIG_CRYPTO_ALGAPI=3Dy
> CONFIG_CRYPTO_ALGAPI2=3Dy
> CONFIG_CRYPTO_AEAD=3Dy
> CONFIG_CRYPTO_AEAD2=3Dy
> CONFIG_CRYPTO_BLKCIPHER=3Dy
> CONFIG_CRYPTO_BLKCIPHER2=3Dy
> CONFIG_CRYPTO_HASH=3Dy
> CONFIG_CRYPTO_HASH2=3Dy
> CONFIG_CRYPTO_RNG=3Dy
> CONFIG_CRYPTO_RNG2=3Dy
> CONFIG_CRYPTO_PCOMP=3Dy
> CONFIG_CRYPTO_MANAGER=3Dy
> CONFIG_CRYPTO_MANAGER2=3Dy
> CONFIG_CRYPTO_GF128MUL=3Dy
> CONFIG_CRYPTO_NULL=3Dy
> CONFIG_CRYPTO_WORKQUEUE=3Dy
> CONFIG_CRYPTO_CRYPTD=3Dy
> CONFIG_CRYPTO_AUTHENC=3Dy
>=20
> #
> # Authenticated Encryption with Associated Data
> #
> CONFIG_CRYPTO_CCM=3Dy
> CONFIG_CRYPTO_GCM=3Dy
> CONFIG_CRYPTO_SEQIV=3Dy
>=20
> #
> # Block modes
> #
> CONFIG_CRYPTO_CBC=3Dy
> CONFIG_CRYPTO_CTR=3Dy
> CONFIG_CRYPTO_CTS=3Dy
> CONFIG_CRYPTO_ECB=3Dy
> CONFIG_CRYPTO_LRW=3Dy
> CONFIG_CRYPTO_PCBC=3Dy
> CONFIG_CRYPTO_XTS=3Dy
>=20
> #
> # Hash modes
> #
> CONFIG_CRYPTO_HMAC=3Dy
> CONFIG_CRYPTO_XCBC=3Dy
>=20
> #
> # Digest
> #
> CONFIG_CRYPTO_CRC32C=3Dy
> # CONFIG_CRYPTO_CRC32C_INTEL is not set
> CONFIG_CRYPTO_MD4=3Dy
> CONFIG_CRYPTO_MD5=3Dy
> CONFIG_CRYPTO_MICHAEL_MIC=3Dy
> CONFIG_CRYPTO_RMD128=3Dy
> CONFIG_CRYPTO_RMD160=3Dy
> # CONFIG_CRYPTO_RMD256 is not set
> CONFIG_CRYPTO_RMD320=3Dy
> CONFIG_CRYPTO_SHA1=3Dy
> CONFIG_CRYPTO_SHA256=3Dy
> # CONFIG_CRYPTO_SHA512 is not set
> CONFIG_CRYPTO_TGR192=3Dy
> CONFIG_CRYPTO_WP512=3Dy
>=20
> #
> # Ciphers
> #
> CONFIG_CRYPTO_AES=3Dy
> CONFIG_CRYPTO_AES_X86_64=3Dy
> CONFIG_CRYPTO_AES_NI_INTEL=3Dy
> CONFIG_CRYPTO_ANUBIS=3Dy
> CONFIG_CRYPTO_ARC4=3Dy
> CONFIG_CRYPTO_BLOWFISH=3Dy
> CONFIG_CRYPTO_CAMELLIA=3Dy
> CONFIG_CRYPTO_CAST5=3Dy
> CONFIG_CRYPTO_CAST6=3Dy
> CONFIG_CRYPTO_DES=3Dy
> CONFIG_CRYPTO_FCRYPT=3Dy
> CONFIG_CRYPTO_KHAZAD=3Dy
> CONFIG_CRYPTO_SALSA20=3Dy
> CONFIG_CRYPTO_SALSA20_X86_64=3Dy
> # CONFIG_CRYPTO_SEED is not set
> # CONFIG_CRYPTO_SERPENT is not set
> # CONFIG_CRYPTO_TEA is not set
> CONFIG_CRYPTO_TWOFISH=3Dy
> CONFIG_CRYPTO_TWOFISH_COMMON=3Dy
> # CONFIG_CRYPTO_TWOFISH_X86_64 is not set
>=20
> #
> # Compression
> #
> CONFIG_CRYPTO_DEFLATE=3Dy
> # CONFIG_CRYPTO_ZLIB is not set
> CONFIG_CRYPTO_LZO=3Dy
>=20
> #
> # Random Number Generation
> #
> CONFIG_CRYPTO_ANSI_CPRNG=3Dy
> # CONFIG_CRYPTO_HW is not set
> CONFIG_HAVE_KVM=3Dy
> CONFIG_HAVE_KVM_IRQCHIP=3Dy
> # CONFIG_VIRTUALIZATION is not set
> # CONFIG_BINARY_PRINTF is not set
>=20
> #
> # Library routines
> #
> CONFIG_BITREVERSE=3Dy
> CONFIG_GENERIC_FIND_FIRST_BIT=3Dy
> CONFIG_GENERIC_FIND_NEXT_BIT=3Dy
> CONFIG_GENERIC_FIND_LAST_BIT=3Dy
> CONFIG_CRC_CCITT=3Dy
> CONFIG_CRC16=3Dy
> CONFIG_CRC_T10DIF=3Dy
> CONFIG_CRC_ITU_T=3Dy
> CONFIG_CRC32=3Dy
> CONFIG_CRC7=3Dy
> CONFIG_LIBCRC32C=3Dy
> CONFIG_ZLIB_INFLATE=3Dy
> CONFIG_ZLIB_DEFLATE=3Dy
> CONFIG_LZO_COMPRESS=3Dy
> CONFIG_LZO_DECOMPRESS=3Dy
> CONFIG_DECOMPRESS_GZIP=3Dy
> CONFIG_DECOMPRESS_BZIP2=3Dy
> CONFIG_DECOMPRESS_LZMA=3Dy
> CONFIG_TEXTSEARCH=3Dy
> CONFIG_TEXTSEARCH_KMP=3Dy
> CONFIG_TEXTSEARCH_BM=3Dy
> CONFIG_TEXTSEARCH_FSM=3Dy
> CONFIG_HAS_IOMEM=3Dy
> CONFIG_HAS_IOPORT=3Dy
> CONFIG_HAS_DMA=3Dy
> CONFIG_CPUMASK_OFFSTACK=3Dy
> CONFIG_NLATTR=3Dy
> CONFIG_FORCE_SUCCESSFUL_BUILD=3Dy
> CONFIG_FORCE_MINIMAL_CONFIG=3Dy
> CONFIG_FORCE_MINIMAL_CONFIG_64=3Dy
> CONFIG_FORCE_MINIMAL_CONFIG_PHYS=3Dy
>=20

--=20
           | Advanced Micro Devices GmbH
 Operating | Karl-Hammerschmidt-Str. 34, 85609 Dornach bei M=FCnchen
 System    |=20
 Research  | Gesch=E4ftsf=FChrer: Thomas M. McCoy, Giuliano Meroni
 Center    | Sitz: Dornach, Gemeinde Aschheim, Landkreis M=FCnchen
           | Registergericht M=FCnchen, HRB Nr. 43632

