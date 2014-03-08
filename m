From: Fengguang Wu <fengguang.wu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: Re: [mac80211_hwsim] BUG: unable to handle kernel paging request at
 ce1db404
Date: Sat, 8 Mar 2014 20:11:38 +0800
Message-ID: <20140308121138.GA8359@localhost>
References: <20140305125703.GA7193@localhost>
 <20140305132317.GB10880@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Martin Pitt <martin.pitt-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20140305132317.GB10880@localhost>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Martin,

These are long term bug and is still showing up in linux-next.
It can be reliably reproduced with the below KVM script.

#!/bin/bash

kvm=3D(
        qemu-system-x86_64 -cpu kvm64 -enable-kvm
        -kernel $1
        -smp 2
        -m 256M
        -net nic,vlan=3D0,macaddr=3D00:00:00:00:00:00,model=3Dvirtio
        -net user,vlan=3D0
        -net nic,vlan=3D1,model=3De1000
        -net user,vlan=3D1
        -boot order=3Dnc
        -no-reboot
        -watchdog i6300esb
        -display none
        -serial stdio
        -monitor null
)

append=3D(
        debug
        sched_debug
        apic=3Ddebug
        ignore_loglevel
        earlyprintk=3DttyS0,115200
        sysrq_always_enabled
        panic=3D10
        prompt_ramdisk=3D0
        console=3DttyS0,115200
        console=3Dtty0
        vga=3Dnormal
        root=3D/dev/ram0
        rcupdate.rcu_cpu_stall_timeout=3D100
        rw
)

"${kvm[@]}" --append "${append[*]}"


% kvm-0day.sh /kernel/i386-randconfig-c5-03010009/b148a42ba7823e34971cd=
4e5b05a5c74fa3311ed/vmlinuz-3.14.0-rc4-next-20140228-05738-gb148a42
early console in setup code
[    0.000000] Initializing cgroup subsys cpuset
[    0.000000] Initializing cgroup subsys cpu
[    0.000000] Linux version 3.14.0-rc4-next-20140228-05738-gb148a42 (k=
build@cairo) (gcc version 4.8.1 (Debian 4.8.1-8) ) #8 SMP PREEMPT Sat M=
ar 1 01:05:21 CST 2014
[    0.000000] KERNEL supported cpus:
[    0.000000]   Intel GenuineIntel
[    0.000000]   Transmeta GenuineTMx86
[    0.000000]   Transmeta TransmetaCPU
[    0.000000] e820: BIOS-provided physical RAM map:
[    0.000000] BIOS-e820: [mem 0x0000000000000000-0x000000000009fbff] u=
sable
[    0.000000] BIOS-e820: [mem 0x000000000009fc00-0x000000000009ffff] r=
eserved
[    0.000000] BIOS-e820: [mem 0x00000000000f0000-0x00000000000fffff] r=
eserved
[    0.000000] BIOS-e820: [mem 0x0000000000100000-0x000000000fffdfff] u=
sable
[    0.000000] BIOS-e820: [mem 0x000000000fffe000-0x000000000fffffff] r=
eserved
[    0.000000] BIOS-e820: [mem 0x00000000feffc000-0x00000000feffffff] r=
eserved
[    0.000000] BIOS-e820: [mem 0x00000000fffc0000-0x00000000ffffffff] r=
eserved
[    0.000000] debug: ignoring loglevel setting.
[    0.000000] NX (Execute Disable) protection: active
[    0.000000] SMBIOS 2.4 present.
[    0.000000] DMI: Bochs Bochs, BIOS Bochs 01/01/2011
[    0.000000] Hypervisor detected: KVM
[    0.000000] e820: update [mem 0x00000000-0x00000fff] usable =3D=3D> =
reserved
[    0.000000] e820: remove [mem 0x000a0000-0x000fffff] usable
[    0.000000] e820: last_pfn =3D 0xfffe max_arch_pfn =3D 0x1000000
[    0.000000] MTRR default type: write-back
[    0.000000] MTRR fixed ranges enabled:
[    0.000000]   00000-9FFFF write-back
[    0.000000]   A0000-BFFFF uncachable
[    0.000000]   C0000-FFFFF write-protect
[    0.000000] MTRR variable ranges enabled:
[    0.000000]   0 base 0080000000 mask FF80000000 uncachable
[    0.000000]   1 disabled
[    0.000000]   2 disabled
[    0.000000]   3 disabled
[    0.000000]   4 disabled
[    0.000000]   5 disabled
[    0.000000]   6 disabled
[    0.000000]   7 disabled
[    0.000000] Scan for SMP in [mem 0x00000000-0x000003ff]
[    0.000000] Scan for SMP in [mem 0x0009fc00-0x0009ffff]
[    0.000000] Scan for SMP in [mem 0x000f0000-0x000fffff]
[    0.000000] found SMP MP-table at [mem 0x000f1840-0x000f184f] mapped=
 at [c00f1840]
[    0.000000]   mpc: f1850-f193c
[    0.000000] Scanning 1 areas for low memory corruption
[    0.000000] initial memory mapped: [mem 0x00000000-0x027fffff]
[    0.000000] Base memory trampoline at [c009b000] 9b000 size 16384
[    0.000000] init_memory_mapping: [mem 0x00000000-0x000fffff]
[    0.000000]  [mem 0x00000000-0x000fffff] page 4k
[    0.000000] init_memory_mapping: [mem 0x0fc00000-0x0fdfffff]
[    0.000000]  [mem 0x0fc00000-0x0fdfffff] page 4k
[    0.000000] BRK [0x023ac000, 0x023acfff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0x0c000000-0x0fbfffff]
[    0.000000]  [mem 0x0c000000-0x0fbfffff] page 4k
[    0.000000] BRK [0x023ad000, 0x023adfff] PGTABLE
[    0.000000] BRK [0x023ae000, 0x023aefff] PGTABLE
[    0.000000] BRK [0x023af000, 0x023affff] PGTABLE
[    0.000000] BRK [0x023b0000, 0x023b0fff] PGTABLE
[    0.000000] BRK [0x023b1000, 0x023b1fff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0x00100000-0x0bffffff]
[    0.000000]  [mem 0x00100000-0x0bffffff] page 4k
[    0.000000] init_memory_mapping: [mem 0x0fe00000-0x0fffdfff]
[    0.000000]  [mem 0x0fe00000-0x0fffdfff] page 4k
[    0.000000] ACPI: RSDP 0x000F16B0 000014 (v00 BOCHS )
[    0.000000] ACPI: RSDT 0x0FFFE3F0 000034 (v01 BOCHS  BXPCRSDT 000000=
01 BXPC 00000001)
[    0.000000] ACPI: FACP 0x0FFFFF80 000074 (v01 BOCHS  BXPCFACP 000000=
01 BXPC 00000001)
[    0.000000] ACPI: DSDT 0x0FFFE430 001137 (v01 BXPC   BXDSDT   000000=
01 INTL 20100528)
[    0.000000] ACPI: FACS 0x0FFFFF40 000040
[    0.000000] ACPI: SSDT 0x0FFFF6A0 000899 (v01 BOCHS  BXPCSSDT 000000=
01 BXPC 00000001)
[    0.000000] ACPI: APIC 0x0FFFF5B0 000080 (v01 BOCHS  BXPCAPIC 000000=
01 BXPC 00000001)
[    0.000000] ACPI: HPET 0x0FFFF570 000038 (v01 BOCHS  BXPCHPET 000000=
01 BXPC 00000001)
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to         ffffb000 (        fee00000)
[    0.000000] 255MB LOWMEM available.
[    0.000000]   mapped low ram: 0 - 0fffe000
[    0.000000]   low ram: 0 - 0fffe000
[    0.000000] kvm-clock: Using msrs 4b564d01 and 4b564d00
[    0.000000] kvm-clock: cpu 0, msr 0:fffd001, primary cpu clock
[    0.000000] Zone ranges:
[    0.000000]   Normal   [mem 0x00001000-0x0fffdfff]
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x00001000-0x0009efff]
[    0.000000]   node   0: [mem 0x00100000-0x0fffdfff]
[    0.000000] On node 0 totalpages: 65436
[    0.000000] free_area_init_node: node 0, pgdat c1c14660, node_mem_ma=
p cfb5a024
[    0.000000]   Normal zone: 576 pages used for memmap
[    0.000000]   Normal zone: 0 pages reserved
[    0.000000]   Normal zone: 65436 pages, LIFO batch:15
[    0.000000] Using APIC driver default
[    0.000000] ACPI: PM-Timer IO Port: 0xb008
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to         ffffb000 (        fee00000)
[    0.000000] ACPI: LAPIC (acpi_id[0x00] lapic_id[0x00] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x01] lapic_id[0x01] enabled)
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0xff] dfl dfl lint[0x1])
[    0.000000] ACPI: IOAPIC (id[0x00] address[0xfec00000] gsi_base[0])
[    0.000000] IOAPIC[0]: apic_id 0, version 17, address 0xfec00000, GS=
I 0-23
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 00, APIC ID 0, A=
PIC INT 02
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 5 global_irq 5 high lev=
el)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 05, APIC ID 0, A=
PIC INT 05
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high lev=
el)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 09, APIC ID 0, A=
PIC INT 09
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 10 global_irq 10 high l=
evel)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 0a, APIC ID 0, A=
PIC INT 0a
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 11 global_irq 11 high l=
evel)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 0b, APIC ID 0, A=
PIC INT 0b
[    0.000000] ACPI: IRQ0 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 01, APIC ID 0, A=
PIC INT 01
[    0.000000] ACPI: IRQ2 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 03, APIC ID 0, A=
PIC INT 03
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 04, APIC ID 0, A=
PIC INT 04
[    0.000000] ACPI: IRQ5 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 06, APIC ID 0, A=
PIC INT 06
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 07, APIC ID 0, A=
PIC INT 07
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 08, APIC ID 0, A=
PIC INT 08
[    0.000000] ACPI: IRQ9 used by override.
[    0.000000] ACPI: IRQ10 used by override.
[    0.000000] ACPI: IRQ11 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0c, APIC ID 0, A=
PIC INT 0c
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0d, APIC ID 0, A=
PIC INT 0d
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0e, APIC ID 0, A=
PIC INT 0e
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0f, APIC ID 0, A=
PIC INT 0f
[    0.000000] Using ACPI (MADT) for SMP configuration information
[    0.000000] ACPI: HPET id: 0x8086a201 base: 0xfed00000
[    0.000000] smpboot: Allowing 2 CPUs, 0 hotplug CPUs
[    0.000000] mapped IOAPIC to ffffa000 (fec00000)
[    0.000000] nr_irqs_gsi: 40
[    0.000000] e820: [mem 0x10000000-0xfeffbfff] available for PCI devi=
ces
[    0.000000] Booting paravirtualized kernel on KVM
[    0.000000] setup_percpu: NR_CPUS:8 nr_cpumask_bits:8 nr_cpu_ids:2 n=
r_node_ids:1
[    0.000000] PERCPU: Embedded 331 pages/cpu @cf8c4000 s1340104 r0 d15=
672 u1355776
[    0.000000] pcpu-alloc: s1340104 r0 d15672 u1355776 alloc=3D331*4096
[    0.000000] pcpu-alloc: [0] 0 [0] 1
[    0.000000] KVM setup async PF for cpu 0
[    0.000000] kvm-stealtime: cpu 0, msr f8c6600
[    0.000000] Built 1 zonelists in Zone order, mobility grouping on.  =
Total pages: 64860
[    0.000000] Kernel command line: debug sched_debug apic=3Ddebug igno=
re_loglevel earlyprintk=3DttyS0,115200 sysrq_always_enabled panic=3D10 =
prompt_ramdisk=3D0 console=3DttyS0,115200 console=3Dtty0 vga=3Dnormal r=
oot=3D/dev/ram0 rcupdate.rcu_cpu_stall_timeout=3D100 rw
[    0.000000] PID hash table entries: 1024 (order: 0, 4096 bytes)
[    0.000000] Dentry cache hash table entries: 32768 (order: 5, 131072=
 bytes)
[    0.000000] Inode-cache hash table entries: 16384 (order: 4, 65536 b=
ytes)
[    0.000000] Initializing CPU#0
[    0.000000] Memory: 235920K/261744K available (7426K kernel code, 86=
5K rwdata, 4108K rodata, 1900K init, 5736K bss, 25824K reserved)
[    0.000000] virtual kernel memory layout:
[    0.000000]     fixmap  : 0xfff15000 - 0xfffff000   ( 936 kB)
[    0.000000]     vmalloc : 0xd07fe000 - 0xfff13000   ( 759 MB)
[    0.000000]     lowmem  : 0xc0000000 - 0xcfffe000   ( 255 MB)
[    0.000000]       .init : 0xc1c1e000 - 0xc1df9000   (1900 kB)
[    0.000000]       .data : 0xc1740d21 - 0xc1c1d600   (4978 kB)
[    0.000000]       .text : 0xc1000000 - 0xc1740d21   (7427 kB)
[    0.000000] Checking if this processor honours the WP bit even in su=
pervisor mode...Ok.
[    0.000000] Preemptible hierarchical RCU implementation.
[    0.000000]  RCU debugfs-based tracing is enabled.
[    0.000000]  RCU lockdep checking is enabled.
[    0.000000]  RCU restricting CPUs from NR_CPUS=3D8 to nr_cpu_ids=3D2=
=2E
[    0.000000]  Offload RCU callbacks from CPU 0
[    0.000000]  Offload RCU callbacks from CPUs: 0.
[    0.000000] RCU: Adjusting geometry for rcu_fanout_leaf=3D16, nr_cpu=
_ids=3D2
[    0.000000] NR_IRQS:2304 nr_irqs:512 16
[    0.000000] CPU 0 irqstacks, hard=3Dc0090000 soft=3Dc0092000
[    0.000000] ACPI: Core revision 20140114
[    0.000000] ACPI: All ACPI Tables successfully acquired
[    0.000000] console [ttyS0] enabled
[    0.000000] Lock dependency validator: Copyright (c) 2006 Red Hat, I=
nc., Ingo Molnar
[    0.000000] ... MAX_LOCKDEP_SUBCLASSES:  8
[    0.000000] ... MAX_LOCK_DEPTH:          48
[    0.000000] ... MAX_LOCKDEP_KEYS:        8191
[    0.000000] ... CLASSHASH_SIZE:          4096
[    0.000000] ... MAX_LOCKDEP_ENTRIES:     16384
[    0.000000] ... MAX_LOCKDEP_CHAINS:      32768
[    0.000000] ... CHAINHASH_SIZE:          16384
[    0.000000]  memory used by lock dependency info: 3823 kB
[    0.000000]  per task-struct memory footprint: 1920 bytes
[    0.000000] hpet clockevent registered
[    0.000000] tsc: Detected 2693.508 MHz processor
[    0.003000] Calibrating delay loop (skipped) preset value.. 5387.01 =
BogoMIPS (lpj=3D2693508)
[    0.004011] pid_max: default: 4096 minimum: 301
[    0.005105] Security Framework initialized
[    0.005797] SELinux:  Initializing.
[    0.006070] SELinux:  Starting in enforcing mode
[    0.007054] Mount-cache hash table entries: 512
[    0.009101] Initializing cgroup subsys debug
[    0.009831] Initializing cgroup subsys freezer
[    0.010024] Initializing cgroup subsys net_cls
[    0.011013] Initializing cgroup subsys perf_event
[    0.012021] Initializing cgroup subsys net_prio
[    0.013124] Last level iTLB entries: 4KB 0, 2MB 0, 4MB 0
[    0.013124] Last level dTLB entries: 4KB 0, 2MB 0, 4MB 0, 1GB 0
[    0.013124] tlb_flushall_shift: 6
[    0.015182] debug: unmapping init [mem 0xc1df9000-0xc1dfcfff]
[    0.017692] Getting VERSION: 50014
[    0.018016] Getting VERSION: 50014
[    0.018572] Getting ID: 0
[    0.019015] Getting ID: f000000
[    0.020014] Getting LVT0: 8700
[    0.020526] Getting LVT1: 8400
[    0.021010] Enabling APIC mode:  Flat.  Using 1 I/O APICs
[    0.022070] enabled ExtINT on CPU#0
[    0.023742] ENABLING IO-APIC IRQs
[    0.024014] init IO_APIC IRQs
[    0.025008]  apic 0 pin 0 not connected
[    0.025665] IOAPIC[0]: Set routing entry (0-1 -> 0x31 -> IRQ 1 Mode:=
0 Active:0 Dest:1)
[    0.026033] IOAPIC[0]: Set routing entry (0-2 -> 0x30 -> IRQ 0 Mode:=
0 Active:0 Dest:1)
[    0.027029] IOAPIC[0]: Set routing entry (0-3 -> 0x33 -> IRQ 3 Mode:=
0 Active:0 Dest:1)
[    0.028030] IOAPIC[0]: Set routing entry (0-4 -> 0x34 -> IRQ 4 Mode:=
0 Active:0 Dest:1)
[    0.029028] IOAPIC[0]: Set routing entry (0-5 -> 0x35 -> IRQ 5 Mode:=
1 Active:0 Dest:1)
[    0.030029] IOAPIC[0]: Set routing entry (0-6 -> 0x36 -> IRQ 6 Mode:=
0 Active:0 Dest:1)
[    0.031028] IOAPIC[0]: Set routing entry (0-7 -> 0x37 -> IRQ 7 Mode:=
0 Active:0 Dest:1)
[    0.032047] IOAPIC[0]: Set routing entry (0-8 -> 0x38 -> IRQ 8 Mode:=
0 Active:0 Dest:1)
[    0.033041] IOAPIC[0]: Set routing entry (0-9 -> 0x39 -> IRQ 9 Mode:=
1 Active:0 Dest:1)
[    0.034045] IOAPIC[0]: Set routing entry (0-10 -> 0x3a -> IRQ 10 Mod=
e:1 Active:0 Dest:1)
[    0.035041] IOAPIC[0]: Set routing entry (0-11 -> 0x3b -> IRQ 11 Mod=
e:1 Active:0 Dest:1)
[    0.036046] IOAPIC[0]: Set routing entry (0-12 -> 0x3c -> IRQ 12 Mod=
e:0 Active:0 Dest:1)
[    0.037042] IOAPIC[0]: Set routing entry (0-13 -> 0x3d -> IRQ 13 Mod=
e:0 Active:0 Dest:1)
[    0.038041] IOAPIC[0]: Set routing entry (0-14 -> 0x3e -> IRQ 14 Mod=
e:0 Active:0 Dest:1)
[    0.039042] IOAPIC[0]: Set routing entry (0-15 -> 0x3f -> IRQ 15 Mod=
e:0 Active:0 Dest:1)
[    0.040034]  apic 0 pin 16 not connected
[    0.041008]  apic 0 pin 17 not connected
[    0.042008]  apic 0 pin 18 not connected
[    0.043008]  apic 0 pin 19 not connected
[    0.044009]  apic 0 pin 20 not connected
[    0.045008]  apic 0 pin 21 not connected
[    0.046008]  apic 0 pin 22 not connected
[    0.047008]  apic 0 pin 23 not connected
[    0.048165] ..TIMER: vector=3D0x30 apic1=3D0 pin1=3D2 apic2=3D-1 pin=
2=3D-1
[    0.049009] smpboot: CPU0: Intel Common KVM processor (fam: 0f, mode=
l: 06, stepping: 01)
[    0.051009] Using local APIC timer interrupts.
[    0.051009] calibrating APIC timer ...
[    0.053000] ... lapic delta =3D 6250096
[    0.053000] ... PM-Timer delta =3D 357998
[    0.053000] ... PM-Timer result ok
[    0.053000] ..... delta 6250096
[    0.053000] ..... mult: 268439579
[    0.053000] ..... calibration result: 1000015
[    0.053000] ..... CPU clock speed is 2693.0692 MHz.
[    0.053000] ..... host bus clock speed is 1000.0015 MHz.
[    0.053100] Performance Events: unsupported Netburst CPU model 6 no =
PMU driver, software events only.
[    0.062433] CPU 1 irqstacks, hard=3Dc0104000 soft=3Dc0106000
[    0.063011] x86: Booting SMP configuration:
[    0.064008] .... node  #0, CPUs:      #1
[    0.003000] Initializing CPU#1
[    0.003000] kvm-clock: cpu 1, msr 0:fffd021, secondary cpu clock
[    0.003000] masked ExtINT on CPU#1
[    0.079215] KVM setup async PF for cpu 1
[    0.079304] x86: Booted up 1 node, 2 CPUs
[    0.079311] ----------------
[    0.079312] | NMI testsuite:
[    0.079312] --------------------
[    0.079215]   remote IPI:
[    0.079215] kvm-stealtime: cpu 1, msr fa11600
[    0.084190]   ok  |
[    0.084582]    local IPI:  ok  |
[    0.089162] --------------------
[    0.089782] Good, all   2 testcases passed! |
[    0.090006] ---------------------------------
[    0.091006] smpboot: Total of 2 processors activated (10774.03 BogoM=
IPS)
[    0.092491] CPU0 attaching sched-domain:
[    0.093007]  domain 0: span 0-1 level CPU
[    0.094004]   groups: 0 (cpu_power =3D 1011) 1 (cpu_power =3D 1016)
[    0.095074] CPU1 attaching sched-domain:
[    0.095722]  domain 0: span 0-1 level CPU
[    0.096299]   groups: 1 (cpu_power =3D 1016) 0 (cpu_power =3D 1011)
[    0.098882] devtmpfs: initialized
[    0.101039] EVM: security.selinux
[    0.101677] EVM: security.capability
[    0.103098] atomic64 test passed for i586+ platform with CX8 and wit=
h SSE
[    0.104677] regulator-dummy: no parameters
[    0.106035] NET: Registered protocol family 16
[    0.107747] EISA bus registered
[    0.108016] cpuidle: using governor ladder
[    0.109466] ACPI: bus type PCI registered
[    0.110506] PCI : PCI BIOS area is rw and x. Use pci=3Dnobios if you=
 want it NX.
[    0.111007] PCI: PCI BIOS revision 2.10 entry at 0xfd4e3, last bus=3D=
0
[    0.112005] PCI: Using configuration type 1 for base access
[    0.137799] gpio-f7188x: Not a Fintek device at 0x0000002e
[    0.139036] gpio-f7188x: Not a Fintek device at 0x0000004e
[    0.140875] ACPI: Added _OSI(Module Device)
[    0.141007] ACPI: Added _OSI(Processor Device)
[    0.142006] ACPI: Added _OSI(3.0 _SCP Extensions)
[    0.143008] ACPI: Added _OSI(Processor Aggregator Device)
[    0.159907] ACPI: Interpreter enabled
[    0.160016] ACPI Exception: AE_NOT_FOUND, While evaluating Sleep Sta=
te [\_S1_] (20140114/hwxface-580)
[    0.162011] ACPI Exception: AE_NOT_FOUND, While evaluating Sleep Sta=
te [\_S2_] (20140114/hwxface-580)
[    0.163415] ACPI: (supports S0 S3 S5)
[    0.164006] ACPI: Using IOAPIC for interrupt routing
[    0.165243] PCI: Using host bridge windows from ACPI; if necessary, =
use "pci=3Dnocrs" and report a bug
[    0.189539] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-ff])
[    0.190015] acpi PNP0A03:00: _OSC: OS supports [Segments]
[    0.191064] acpi PNP0A03:00: _OSC failed (AE_NOT_FOUND); disabling A=
SPM
[    0.193407] acpi PNP0A03:00: fail to add MMCONFIG information, can't=
 access extended PCI configuration space under this bridge.
[    0.195529] PCI host bridge to bus 0000:00
[    0.196010] pci_bus 0000:00: root bus resource [bus 00-ff]
[    0.197009] pci_bus 0000:00: root bus resource [io  0x0000-0x0cf7]
[    0.198007] pci_bus 0000:00: root bus resource [io  0x0d00-0xffff]
[    0.199008] pci_bus 0000:00: root bus resource [mem 0x000a0000-0x000=
bffff]
[    0.200009] pci_bus 0000:00: root bus resource [mem 0x80000000-0xfeb=
fffff]
[    0.202092] pci 0000:00:00.0: [8086:1237] type 00 class 0x060000
[    0.204033] pci 0000:00:01.0: [8086:7000] type 00 class 0x060100
[    0.206115] pci 0000:00:01.1: [8086:7010] type 00 class 0x010180
[    0.209734] pci 0000:00:01.1: reg 0x20: [io  0xc060-0xc06f]
[    0.212687] pci 0000:00:01.3: [8086:7113] type 00 class 0x068000
[    0.214247] pci 0000:00:01.3: quirk: [io  0xb000-0xb03f] claimed by =
PIIX4 ACPI
[    0.215017] pci 0000:00:01.3: quirk: [io  0xb100-0xb10f] claimed by =
PIIX4 SMB
[    0.217477] pci 0000:00:02.0: [1013:00b8] type 00 class 0x030000
[    0.220865] pci 0000:00:02.0: reg 0x10: [mem 0xfc000000-0xfdffffff p=
ref]
[    0.224030] pci 0000:00:02.0: reg 0x14: [mem 0xfebe2000-0xfebe2fff]
[    0.233034] pci 0000:00:02.0: reg 0x30: [mem 0xfebd0000-0xfebdffff p=
ref]
[    0.235379] pci 0000:00:03.0: [1af4:1000] type 00 class 0x020000
[    0.237008] pci 0000:00:03.0: reg 0x10: [io  0xc040-0xc05f]
[    0.239008] pci 0000:00:03.0: reg 0x14: [mem 0xfebe1000-0xfebe1fff]
[    0.244464] pci 0000:00:03.0: reg 0x30: [mem 0xfebc0000-0xfebcffff p=
ref]
[    0.247342] pci 0000:00:04.0: [8086:100e] type 00 class 0x020000
[    0.249008] pci 0000:00:04.0: reg 0x10: [mem 0xfeb80000-0xfeb9ffff]
[    0.251008] pci 0000:00:04.0: reg 0x14: [io  0xc000-0xc03f]
[    0.256477] pci 0000:00:04.0: reg 0x30: [mem 0xfeba0000-0xfebbffff p=
ref]
[    0.259007] pci 0000:00:05.0: [8086:25ab] type 00 class 0x088000
[    0.260515] pci 0000:00:05.0: reg 0x10: [mem 0xfebe0000-0xfebe000f]
[    0.265501] pci_bus 0000:00: on NUMA node 0
[    0.267900] ACPI: PCI Interrupt Link [LNKA] (IRQs 5 *10 11)
[    0.269317] ACPI: PCI Interrupt Link [LNKB] (IRQs 5 *10 11)
[    0.270631] ACPI: PCI Interrupt Link [LNKC] (IRQs 5 10 *11)
[    0.272120] ACPI: PCI Interrupt Link [LNKD] (IRQs 5 10 *11)
[    0.273242] ACPI: PCI Interrupt Link [LNKS] (IRQs *9)
[    0.275860] ACPI: Enabled 16 GPEs in block 00 to 0F
[    0.279488] vgaarb: device added: PCI:0000:00:02.0,decodes=3Dio+mem,=
owns=3Dio+mem,locks=3Dnone
[    0.280010] vgaarb: loaded
[    0.281005] vgaarb: bridge control possible 0000:00:02.0
[    0.284335] ACPI: bus type USB registered
[    0.285192] usbcore: registered new interface driver usbfs
[    0.286179] usbcore: registered new interface driver hub
[    0.287280] usbcore: registered new device driver usb
[    0.288359] Linux video capture interface: v2.00
[    0.289040] pps_core: LinuxPPS API ver. 1 registered
[    0.290005] pps_core: Software ver. 5.3.6 - Copyright 2005-2007 Rodo=
lfo Giometti <giometti-k2GhghHVRtY@public.gmane.org>
[    0.291030] PTP clock support registered
[    0.293376] Advanced Linux Sound Architecture Driver Initialized.
[    0.294012] PCI: Using ACPI for IRQ routing
[    0.295009] PCI: pci_cache_line_size set to 64 bytes
[    0.296095] e820: reserve RAM buffer [mem 0x0009fc00-0x0009ffff]
[    0.297019] e820: reserve RAM buffer [mem 0x0fffe000-0x0fffffff]
[    0.299481] NET: Registered protocol family 23
[    0.300100] Bluetooth: Core ver 2.19
[    0.301074] NET: Registered protocol family 31
[    0.301818] Bluetooth: HCI device and connection manager initialized
[    0.302035] Bluetooth: HCI socket layer initialized
[    0.303134] Bluetooth: L2CAP socket layer initialized
[    0.304072] Bluetooth: SCO socket layer initialized
[    0.306303] cfg80211: Calling CRDA to update world regulatory domain
[    0.307099] NetLabel: Initializing
[    0.308006] NetLabel:  domain hash size =3D 128
[    0.308707] NetLabel:  protocols =3D UNLABELED CIPSOv4
[    0.309300] NetLabel:  unlabeled traffic allowed by default
[    0.311402] nfc: nfc_init: NFC Core ver 0.1
[    0.312090] NET: Registered protocol family 39
[    0.313582] Switched to clocksource kvm-clock
[    0.314277] pnp: PnP ACPI init
[    0.314874] ACPI: bus type PNP registered
[    0.315701] IOAPIC[0]: Set routing entry (0-8 -> 0x38 -> IRQ 8 Mode:=
0 Active:0 Dest:3)
[    0.317303] pnp 00:00: Plug and Play ACPI device, IDs PNP0b00 (activ=
e)
[    0.318478] IOAPIC[0]: Set routing entry (0-1 -> 0x31 -> IRQ 1 Mode:=
0 Active:0 Dest:3)
[    0.319936] pnp 00:01: Plug and Play ACPI device, IDs PNP0303 (activ=
e)
[    0.321075] IOAPIC[0]: Set routing entry (0-12 -> 0x3c -> IRQ 12 Mod=
e:0 Active:0 Dest:3)
[    0.322702] pnp 00:02: Plug and Play ACPI device, IDs PNP0f13 (activ=
e)
[    0.323924] IOAPIC[0]: Set routing entry (0-6 -> 0x36 -> IRQ 6 Mode:=
0 Active:0 Dest:3)
[    0.325271] pnp 00:03: [dma 2]
[    0.325956] pnp 00:03: Plug and Play ACPI device, IDs PNP0700 (activ=
e)
[    0.327327] IOAPIC[0]: Set routing entry (0-7 -> 0x37 -> IRQ 7 Mode:=
0 Active:0 Dest:3)
[    0.328923] pnp 00:04: Plug and Play ACPI device, IDs PNP0400 (activ=
e)
[    0.330134] IOAPIC[0]: Set routing entry (0-4 -> 0x34 -> IRQ 4 Mode:=
0 Active:0 Dest:3)
[    0.331614] pnp 00:05: Plug and Play ACPI device, IDs PNP0501 (activ=
e)
[    0.333751] pnp 00:06: Plug and Play ACPI device, IDs PNP0103 (activ=
e)
[    0.335398] pnp: PnP ACPI: found 7 devices
[    0.336084] ACPI: bus type PNP unregistered
[    0.374955] pci_bus 0000:00: resource 4 [io  0x0000-0x0cf7]
[    0.376040] pci_bus 0000:00: resource 5 [io  0x0d00-0xffff]
[    0.376958] pci_bus 0000:00: resource 6 [mem 0x000a0000-0x000bffff]
[    0.378006] pci_bus 0000:00: resource 7 [mem 0x80000000-0xfebfffff]
[    0.379157] NET: Registered protocol family 2
[    0.380963] TCP established hash table entries: 2048 (order: 1, 8192=
 bytes)
[    0.382341] TCP bind hash table entries: 2048 (order: 4, 90112 bytes=
)
[    0.384677] TCP: Hash tables configured (established 2048 bind 2048)
[    0.385920] TCP: reno registered
[    0.386495] UDP hash table entries: 128 (order: 1, 12288 bytes)
[    0.387602] UDP-Lite hash table entries: 128 (order: 1, 12288 bytes)
[    0.389257] NET: Registered protocol family 1
[    0.390020] pci 0000:00:00.0: Limiting direct PCI/PCI transfers
[    0.391008] pci 0000:00:01.0: PIIX3: Enabling Passive Release
[    0.391976] pci 0000:00:01.0: Activating ISA DMA hang workarounds
[    0.393033] pci 0000:00:02.0: Boot video device
[    0.393819] PCI: CLS 0 bytes, default 64
[    0.396285] microcode: CPU0 sig=3D0xf61, pf=3D0x1, revision=3D0x1
[    0.397423] microcode: CPU1 sig=3D0xf61, pf=3D0x1, revision=3D0x1
[    0.398684] microcode: Microcode Update Driver: v2.00 <tigran@aivazi=
an.fsnet.co.uk>, Peter Oruba
[    0.401004] Scanning for low memory corruption every 60 seconds
[    0.406347] PCLMULQDQ-NI instructions are not detected.
[    0.407424] The force parameter has not been set to 1. The Iris powe=
roff handler will not be installed.
[    0.409006] NatSemi SCx200 Driver
[    0.412226] Initializing RT-Tester: OK
[    0.414389] futex hash table entries: 16 (order: -2, 1024 bytes)
[    0.415543] Initialise system trusted keyring
[    0.416337] audit: initializing netlink subsys (disabled)
[    0.417331] audit: type=3D2000 audit(1394067047.252:1): initialized
[    0.419205] HugeTLB registered 2 MB page size, pre-allocated 0 pages
[    0.420622] VFS: Disk quotas dquot_6.5.2
[    0.421309] Dquot-cache hash table entries: 1024 (order 0, 4096 byte=
s)
[    0.423589] jffs2: version 2.2. =C2=A9 2001-2006 Red Hat, Inc.
[    0.424788] fuse init (API version 7.22)
[    0.426241] SELinux:  Registering netfilter hooks
[    0.444720] alg: No test for crc32 (crc32-table)
[    0.446093] alg: No test for lz4 (lz4-generic)
[    0.446983] alg: No test for stdrng (krng)
[    0.457375] alg: No test for fips(ansi_cprng) (fips_ansi_cprng)
[    0.458883] NET: Registered protocol family 38
[    0.459744] Key type asymmetric registered
[    0.460485] list_sort_test: start testing list_sort()
[    0.468103] crc32: CRC_LE_BITS =3D 1, CRC_BE BITS =3D 1
[    0.469085] crc32: self tests passed, processed 225944 bytes in 2646=
431 nsec
[    0.473281] crc32c: CRC_LE_BITS =3D 1
[    0.474060] crc32c: self tests passed, processed 225944 bytes in 149=
5319 nsec
[    0.832926] crc32_combine: 8373 self tests passed
[    1.398637] tsc: Refined TSC clocksource calibration: 2693.422 MHz
[    1.458227] crc32c_combine: 8373 self tests passed
[    1.461824] xz_dec_test: module loaded
[    1.463588] xz_dec_test: Create a device node with 'mknod xz_dec_tes=
t c 252 0' and write .xz files to it.
[    1.467222] rbtree testing -> 22292 cycles
[    2.372809] augmented rbtree testing -> 34475 cycles
[    3.758989] input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/=
input/input0
[    3.762060] ACPI: Power Button [PWRF]
[    3.860138] HDLC line discipline maxframe=3D4096
[    3.860950] N_HDLC line discipline registered.
[    3.861778] r3964: Philips r3964 Driver $Revision: 1.10 $
[    3.862597] Serial: 8250/16550 driver, 4 ports, IRQ sharing disabled
[    3.885581] 00:05: ttyS0 at I/O 0x3f8 (irq =3D 4, base_baud =3D 1152=
00) is a 16550A
[    3.891756] serial: Freescale lpuart driver
[    3.892610] Cyclades driver 2.6
[    3.914550] MOXA Intellio family driver version 6.0k
[    3.915964] MOXA Smartio/Industio family driver version 2.0.5
[    3.916918] RocketPort device driver module, version 2.09, 12-June-2=
003
[    3.917906] No rocketport ports found; unloading driver
[    3.919295] DoubleTalk PC - not found
[    3.920150] Non-volatile memory driver v1.3
[    3.920791] scx200_gpio: no SCx200 gpio present
[    3.921897] platform pc8736x_gpio.0: NatSemi pc8736x GPIO Driver Ini=
tializing
[    3.922977] platform pc8736x_gpio.0: no device found
[    3.924041] nsc_gpio initializing
[    3.924718] telclk_interrupt =3D 0xf non-mcpbl0010 hw.
[    3.925446] smapi::smapi_init, ERROR invalid usSmapiID
[    3.926181] mwave: tp3780i::tp3780I_InitializeBoardData: Error: SMAP=
I is not available on this machine
[    3.927538] mwave: mwavedd::mwave_init: Error: Failed to initialize =
board data
[    3.928581] mwave: mwavedd::mwave_init: Error: Failed to initialize
[    3.930558] [drm] Initialized drm 1.1.0 20060810
[    3.932137] dummy-irq: no IRQ given.  Use irq=3DN
[    3.935236] usbcore: registered new interface driver viperboard
[    3.937701] usbcore: registered new interface driver port100
[    3.939376] mtdoops: mtd device (mtddev=3Dname/number) must be suppl=
ied
[    3.940363] L440GX flash mapping: failed to find PIIX4 ISA bridge, c=
annot continue
[    3.941448] scx200_docflash: NatSemi SCx200 DOCCS Flash Driver
[    3.942362] slram: not enough parameters.
[    4.160609] No valid DiskOnChip devices found
[    4.167287] libphy: Fixed MDIO Bus: probed
[    4.169974] arcnet loaded.
[    4.170440] arcnet: RFC1201 "standard" (`a') encapsulation support l=
oaded.
[    4.171435] arcnet: raw mode (`r') encapsulation support loaded.
[    4.172285] arcnet: cap mode (`c') encapsulation support loaded.
[    4.173404] arcnet: RIM I (entirely mem-mapped) support
[    4.175536] E-mail me if you actually test the RIM I driver, please!
[    4.178060] Given: node 00h, shmem 0h, irq 0
[    4.179692] No autoprobe for RIM I; you must specify the shmem and i=
rq!
[    4.181629] ipddp.c:v0.01 8/28/97 Bradford W. Johnson <johns393@maro=
on.tc.umn.edu>
[    4.186977] ipddp0: Appletalk-IP Decap. mode by Jay Schulist <jschls=
t@samba.org>
[    4.189538] slcan: serial line CAN interface driver
[    4.191146] slcan: 10 dynamic interface channels.
[    4.192939] CAN device driver interface
[    4.194257] usbcore: registered new interface driver ems_usb
[    4.196381] usbcore: registered new interface driver esd_usb2
[    4.198659] usbcore: registered new interface driver kvaser_usb
[    4.201037] usbcore: registered new interface driver usb_8dev
[    4.254865] AX.25: Z8530 SCC driver version 3.0.dl1bke
[    4.259137] AX.25: 6pack driver, Revision: 0.3.0
[    4.260938] YAM driver version 0.8 by F1OAT/F6FBB
[    4.272115] AX.25: bpqether driver version 004
[    4.274022] baycom_ser_fdx: (C) 1996-2000 Thomas Sailer, HB9JNX/AE4W=
A
[    4.274022] baycom_ser_fdx: version 0.10
[    4.287488] hdlcdrv: (C) 1996-2000 Thomas Sailer HB9JNX/AE4WA
[    4.289781] hdlcdrv: version 0.8
[    4.290996] baycom_ser_hdx: (C) 1996-2000 Thomas Sailer, HB9JNX/AE4W=
A
[    4.290996] baycom_ser_hdx: version 0.10
[    4.304517] usbcore: registered new interface driver stir4200
[    4.308489] usbcore: registered new interface driver mcs7780
[    4.310686] usbcore: registered new interface driver kingsun-sir
[    4.312987] usbcore: registered new interface driver ks959-sir
[    4.315148] PPP generic driver version 2.4.2
[    4.317677] PPP BSD Compression module registered
[    4.319090] NET: Registered protocol family 24
[    4.320445] PPTP driver version 0.8.5
[    4.322146] hdlc: HDLC support module revision 1.22
[    4.323499] DLCI driver v0.35, 4 Jan 1997, mike.mclagan-Xh+NVF5n0LIEbZ0PF+XxCw@public.gmane.org
[    4.324809] orinoco 0.15 (David Gibson <hermes-xT8FGy+AXnRB3Ne2BGzF6laj5H9X9Tb+@public.gmane.org=
>, Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>, et al)
[    4.326875] usbcore: registered new interface driver orinoco_usb
[    4.327927] Broadcom 43xx-legacy driver loaded [ Features: PLD ]
[    4.328832] zd1211rw usb_init()
[    4.329760] usbcore: registered new interface driver zd1211rw
[    4.330647] zd1211rw initialized
[    4.331701] usbcore: registered new interface driver rndis_wlan
[    4.332661] usbcore: registered new interface driver zd1201
[    4.333574] usbcore: registered new interface driver usb8xxx
[    4.334432] libertas_sdio: Libertas SDIO driver
[    4.335102] libertas_sdio: Copyright Pierre Ossman
[    4.336331] libertas_spi: Libertas SPI driver
[    4.337110] usbcore: registered new interface driver rt73usb
[    4.338110] usbcore: registered new interface driver ath9k_htc
[    4.339280] usbcore: registered new interface driver carl9170
[    4.340953] cfg80211: Updating information on frequency 2412 MHz wit=
h regulatory rule:
[    4.342088] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (600 m=
Bi, 2000 mBm)
[    4.343137] cfg80211: Updating information on frequency 2417 MHz wit=
h regulatory rule:
[    4.344272] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (600 m=
Bi, 2000 mBm)
[    4.345325] cfg80211: Updating information on frequency 2422 MHz wit=
h regulatory rule:
[    4.346631] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (600 m=
Bi, 2000 mBm)
[    4.347737] cfg80211: Updating information on frequency 2427 MHz wit=
h regulatory rule:
[    4.348848] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (600 m=
Bi, 2000 mBm)
[    4.349902] cfg80211: Updating information on frequency 2432 MHz wit=
h regulatory rule:
[    4.351050] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (600 m=
Bi, 2000 mBm)
[    4.352145] cfg80211: Updating information on frequency 2437 MHz wit=
h regulatory rule:
[    4.353300] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (600 m=
Bi, 2000 mBm)
[    4.354359] cfg80211: Updating information on frequency 2442 MHz wit=
h regulatory rule:
[    4.355593] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (600 m=
Bi, 2000 mBm)
[    4.356743] cfg80211: Updating information on frequency 2447 MHz wit=
h regulatory rule:
[    4.358019] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (600 m=
Bi, 2000 mBm)
[    4.359268] cfg80211: Updating information on frequency 2452 MHz wit=
h regulatory rule:
[    4.360637] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (600 m=
Bi, 2000 mBm)
[    4.361883] cfg80211: Updating information on frequency 2457 MHz wit=
h regulatory rule:
[    4.363167] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (600 m=
Bi, 2000 mBm)
[    4.364802] cfg80211: Updating information on frequency 2462 MHz wit=
h regulatory rule:
[    4.366426] cfg80211: 2402000 KHz - 2472000 KHz @ 40000 KHz), (600 m=
Bi, 2000 mBm)
[    4.367531] cfg80211: Updating information on frequency 2467 MHz wit=
h regulatory rule:
[    4.368736] cfg80211: 2457000 KHz - 2482000 KHz @ 40000 KHz), (600 m=
Bi, 2000 mBm)
[    4.370161] cfg80211: Updating information on frequency 2472 MHz wit=
h regulatory rule:
[    4.371332] cfg80211: 2457000 KHz - 2482000 KHz @ 40000 KHz), (600 m=
Bi, 2000 mBm)
[    4.372512] cfg80211: Updating information on frequency 2484 MHz wit=
h regulatory rule:
[    4.373664] cfg80211: 2474000 KHz - 2494000 KHz @ 20000 KHz), (600 m=
Bi, 2000 mBm)
[    4.374945] cfg80211: Updating information on frequency 5180 MHz wit=
h regulatory rule:
[    4.376169] cfg80211: 5170000 KHz - 5250000 KHz @ 160000 KHz), (600 =
mBi, 2000 mBm)
[    4.377351] cfg80211: Updating information on frequency 5200 MHz wit=
h regulatory rule:
[    4.378759] cfg80211: 5170000 KHz - 5250000 KHz @ 160000 KHz), (600 =
mBi, 2000 mBm)
[    4.380436] cfg80211: Updating information on frequency 5220 MHz wit=
h regulatory rule:
[    4.381729] cfg80211: 5170000 KHz - 5250000 KHz @ 160000 KHz), (600 =
mBi, 2000 mBm)
[    4.382790] cfg80211: Updating information on frequency 5240 MHz wit=
h regulatory rule:
[    4.383996] cfg80211: 5170000 KHz - 5250000 KHz @ 160000 KHz), (600 =
mBi, 2000 mBm)
[    4.385175] cfg80211: Updating information on frequency 5260 MHz wit=
h regulatory rule:
[    4.386339] cfg80211: 5250000 KHz - 5330000 KHz @ 160000 KHz), (600 =
mBi, 2000 mBm)
[    4.387539] cfg80211: Updating information on frequency 5280 MHz wit=
h regulatory rule:
[    4.388742] cfg80211: 5250000 KHz - 5330000 KHz @ 160000 KHz), (600 =
mBi, 2000 mBm)
[    4.389895] cfg80211: Updating information on frequency 5300 MHz wit=
h regulatory rule:
[    4.391090] cfg80211: 5250000 KHz - 5330000 KHz @ 160000 KHz), (600 =
mBi, 2000 mBm)
[    4.392177] cfg80211: Updating information on frequency 5320 MHz wit=
h regulatory rule:
[    4.393288] cfg80211: 5250000 KHz - 5330000 KHz @ 160000 KHz), (600 =
mBi, 2000 mBm)
[    4.394428] cfg80211: Updating information on frequency 5500 MHz wit=
h regulatory rule:
[    4.395600] cfg80211: 5490000 KHz - 5730000 KHz @ 160000 KHz), (600 =
mBi, 2000 mBm)
[    4.396762] cfg80211: Updating information on frequency 5520 MHz wit=
h regulatory rule:
[    4.397917] cfg80211: 5490000 KHz - 5730000 KHz @ 160000 KHz), (600 =
mBi, 2000 mBm)
[    4.399032] cfg80211: Updating information on frequency 5540 MHz wit=
h regulatory rule:
[    4.400292] cfg80211: 5490000 KHz - 5730000 KHz @ 160000 KHz), (600 =
mBi, 2000 mBm)
[    4.401359] cfg80211: Updating information on frequency 5560 MHz wit=
h regulatory rule:
[    4.402535] cfg80211: 5490000 KHz - 5730000 KHz @ 160000 KHz), (600 =
mBi, 2000 mBm)
[    4.403786] cfg80211: Updating information on frequency 5580 MHz wit=
h regulatory rule:
[    4.405032] cfg80211: 5490000 KHz - 5730000 KHz @ 160000 KHz), (600 =
mBi, 2000 mBm)
[    4.406104] cfg80211: Updating information on frequency 5600 MHz wit=
h regulatory rule:
[    4.407261] cfg80211: 5490000 KHz - 5730000 KHz @ 160000 KHz), (600 =
mBi, 2000 mBm)
[    4.408336] cfg80211: Updating information on frequency 5620 MHz wit=
h regulatory rule:
[    4.409509] cfg80211: 5490000 KHz - 5730000 KHz @ 160000 KHz), (600 =
mBi, 2000 mBm)
[    4.410635] cfg80211: Updating information on frequency 5640 MHz wit=
h regulatory rule:
[    4.411771] cfg80211: 5490000 KHz - 5730000 KHz @ 160000 KHz), (600 =
mBi, 2000 mBm)
[    4.412887] cfg80211: Updating information on frequency 5660 MHz wit=
h regulatory rule:
[    4.414024] cfg80211: 5490000 KHz - 5730000 KHz @ 160000 KHz), (600 =
mBi, 2000 mBm)
[    4.415105] cfg80211: Updating information on frequency 5680 MHz wit=
h regulatory rule:
[    4.416367] cfg80211: 5490000 KHz - 5730000 KHz @ 160000 KHz), (600 =
mBi, 2000 mBm)
[    4.417438] cfg80211: Updating information on frequency 5700 MHz wit=
h regulatory rule:
[    4.418578] cfg80211: 5490000 KHz - 5730000 KHz @ 160000 KHz), (600 =
mBi, 2000 mBm)
[    4.419682] cfg80211: Disabling freq 5745 MHz
[    4.420296] cfg80211: Disabling freq 5765 MHz
[    4.420928] cfg80211: Disabling freq 5785 MHz
[    4.421577] cfg80211: Disabling freq 5805 MHz
[    4.422199] cfg80211: Disabling freq 5825 MHz
[    4.424386] ieee80211 phy0: Failed to select rate control algorithm
[    4.425487] ieee80211 phy0: Failed to initialize rate control algori=
thm
[    4.429993] mac80211_hwsim: ieee80211_register_hw failed (-2)
[    4.431132] BUG: unable to handle kernel paging request at cf3d7404
[    4.431924] IP: [<c1179574>] kobject_get+0xf/0x3c
[    4.431924] *pdpt =3D 0000000001dfd001 *pde =3D 000000000fdeb067 *pt=
e =3D 800000000f3d7060
[    4.431924] Oops: 0002 [#1] PREEMPT SMP DEBUG_PAGEALLOC
[    4.431924] CPU: 1 PID: 1 Comm: swapper/0 Not tainted 3.14.0-rc4-nex=
t-20140228-05738-gb148a42 #8
[    4.431924] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    4.431924] task: c0020000 ti: c0022000 task.ti: c0022000
[    4.431924] EIP: 0060:[<c1179574>] EFLAGS: 00010286 CPU: 1
[    4.431924] EIP is at kobject_get+0xf/0x3c
[    4.431924] EAX: 00000001 EBX: cf3d73e8 ECX: c123a140 EDX: cf3d60b4
[    4.431924] ESI: c1ba75bc EDI: 00000000 EBP: c0023ee4 ESP: c0023ee0
[    4.431924]  DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
[    4.431924] CR0: 8005003b CR2: cf3d7404 CR3: 01e00000 CR4: 000006b0
[    4.431924] Stack:
[    4.431924]  cf3d73e0 c0023eec c12377de c0023f00 c123a165 c1ba75bc f=
ffffffe 00000000
[    4.431924]  c0023f0c c1239433 c1ba75bc c0023f18 c123a535 00000000 c=
0023f20 c123b3aa
[    4.431924]  c0023f34 c1c4ac9f c1c4a8fa 00000000 c1ca3f34 c0023f90 c=
1c1e9d4 00000000
[    4.431924] Call Trace:
[    4.431924]  [<c12377de>] get_device+0xf/0x17
[    4.431924]  [<c123a165>] driver_detach+0x38/0x8f
[    4.431924]  [<c1239433>] bus_remove_driver+0x53/0x66
[    4.431924]  [<c123a535>] driver_unregister+0x38/0x3d
[    4.431924]  [<c123b3aa>] platform_driver_unregister+0xb/0xd
[    4.431924]  [<c1c4ac9f>] init_mac80211_hwsim+0x3a5/0x3b6
[    4.431924]  [<c1c4a8fa>] ? carl9170_driver_init+0x16/0x16
[    4.431924]  [<c1c1e9d4>] do_one_initcall+0x6e/0xec
[    4.431924]  [<c1047c00>] ? param_set_charp+0x7/0x9f
[    4.431924]  [<c1047e61>] ? parse_args+0x16d/0x207
[    4.431924]  [<c1c1ebd9>] kernel_init_freeable+0x187/0x1ff
[    4.431924]  [<c172f2e1>] kernel_init+0x8/0xb8
[    4.431924]  [<c173ff37>] ret_from_kernel_thread+0x1b/0x28
[    4.431924]  [<c172f2d9>] ? rest_init+0x10d/0x10d
[    4.431924] Code: c1 50 53 68 54 80 a7 c1 e8 b6 a6 5b 00 e8 4c ca 5b=
 00 83 c4 0c 8d 65 f8 5b 5e 5d c3 55 85 c0 89 e5 53 89 c3 74 2d b8 01 0=
0 00 00 <f0> 0f c1 43 1c 40 48 7f 1f 80 3d 87 5c c1 c1 00 75 16 ba 2f 0=
0
[    4.431924] EIP: [<c1179574>] kobject_get+0xf/0x3c SS:ESP 0068:c0023=
ee0
[    4.431924] CR2: 00000000cf3d7404
[    4.431924] ---[ end trace 794d003dd7f4bf37 ]---
[    4.431924] Kernel panic - not syncing: Fatal exception
[    4.431924] Kernel Offset: 0x0 from 0xc1000000 (relocation range: 0x=
c0000000-0xd07fdfff)
[    4.431924] Rebooting in 10 seconds...
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
