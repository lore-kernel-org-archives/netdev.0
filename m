From: Fengguang Wu <fengguang.wu@intel.com>
Subject: xt_nat_init: BUG: unable to handle kernel NULL pointer dereference
 at 00000000000000e0
Date: Thu, 13 Sep 2012 17:16:29 +0800
Message-ID: <20120913091629.GA28022@localhost>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="EVF5PPMfhYS0aIcm"
Cc: networking <netdev@vger.kernel.org>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	"Netfilter Development Maili..." <netfilter-devel@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--EVF5PPMfhYS0aIcm
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Patrick,

This happens in today's linux-next tree and is pretty reproducible.
Bisection has been started.

[    1.834544] nf_conntrack version 0.5.0 (1786 buckets, 7144 max)
[    1.835406] ctnetlink v0.93: registering with nfnetlink.
[    1.836202] BUG: unable to handle kernel NULL pointer dereference at 00000000000000e0
[    1.837539] IP: [<ffffffff81a19123>] mutex_lock_interruptible+0x23/0x70
[    1.838493] PGD 0 
[    1.838983] Oops: 0002 [#1] PREEMPT SMP 
[    1.839786] CPU 0 
[    1.840050] Pid: 1, comm: swapper/0 Not tainted 3.6.0-rc5-07686-gdbf978b #58 Bochs Bochs
[    1.840172] RIP: 0010:[<ffffffff81a19123>]  [<ffffffff81a19123>] mutex_lock_interruptible+0x23/0x70
[    1.840172] RSP: 0018:ffff88000d845e40  EFLAGS: 00010202
[    1.840172] RAX: 0000000000000246 RBX: 00000000000000e0 RCX: ffff88000d848000
[    1.840172] RDX: 0000000000000000 RSI: 0000000000000175 RDI: ffffffff81e6bc88
[    1.840172] RBP: ffff88000d845e50 R08: ffffffff821bd170 R09: 0000000000000000
[    1.840172] R10: 0000000000000000 R11: dead000000200200 R12: 00000000ffffffff
[    1.840172] R13: 0000000000000004 R14: ffffffff821c1ce0 R15: 0000000000000000
[    1.840172] FS:  0000000000000000(0000) GS:ffff88000de00000(0000) knlGS:0000000000000000
[    1.840172] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[    1.840172] CR2: 00000000000000e0 CR3: 000000000200b000 CR4: 00000000000006f0
[    1.840172] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[    1.840172] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[    1.840172] Process swapper/0 (pid: 1, threadinfo ffff88000d844000, task ffff88000d848000)
[    1.840172] Stack:
[    1.840172]  00000000000000e0 ffffffff821c1ce0 ffff88000d845e80 ffffffff8187c204
[    1.840172]  0000000000000000 ffffffff820f7ea0 0000000000000000 ffffffff821c1ce0
[    1.840172]  ffff88000d845ec0 ffffffff8187c334 ffff88000d845eb0 0000000000000000
[    1.840172] Call Trace:
[    1.840172]  [<ffffffff8187c204>] xt_register_target+0x34/0x70
[    1.840172]  [<ffffffff8187c334>] xt_register_targets+0x34/0x70
[    1.840172]  [<ffffffff8221f336>] ? nf_nat_init+0x12c/0x12c
[    1.840172]  [<ffffffff8221f34b>] xt_nat_init+0x15/0x17
[    1.840172]  [<ffffffff821dcc3e>] do_one_initcall+0x7a/0x134
[    1.840172]  [<ffffffff821dcdfb>] kernel_init+0x103/0x187
[    1.864014]  [<ffffffff821dc615>] ? do_early_param+0x8d/0x8d
[    1.864014]  [<ffffffff81a1dc44>] kernel_thread_helper+0x4/0x10
[    1.864014]  [<ffffffff821dccf8>] ? do_one_initcall+0x134/0x134
[    1.864014]  [<ffffffff81a1dc40>] ? gs_change+0x13/0x13
[    1.864014] Code: 8b 65 f8 c9 c3 0f 1f 00 55 31 d2 be 75 01 00 00 48 89 e5 41 54 41 bc ff ff ff ff 53 48 89 fb 48 c7 c7 88 bc e6 81 e8 dd 73 6e ff <f0> 44 0f c1 23 41 83 ec 01 31 d2 48 c7 c7 c8 b7 13 82 41 c1 ec 
[    1.864014] RIP  [<ffffffff81a19123>] mutex_lock_interruptible+0x23/0x70
[    1.864014]  RSP <ffff88000d845e40>
[    1.864014] CR2: 00000000000000e0

Thanks,
Fengguang

--EVF5PPMfhYS0aIcm
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="dmesg-kvm-fat-3546-2012-09-13-16-57-49-3.6.0-rc5-07686-gdbf978b-58"
Content-Transfer-Encoding: quoted-printable

[    0.000000] Initializing cgroup subsys cpu
[    0.000000] Linux version 3.6.0-rc5-07686-gdbf978b (kbuild@snb) (gcc ver=
sion 4.7.1 (Debian 4.7.1-6) ) #58 SMP PREEMPT Thu Sep 13 16:56:38 CST 2012
[    0.000000] Command line: trinity=3D2m hung_task_panic=3D1 rcutree.rcu_c=
pu_stall_timeout=3D100 branch=3Dnext/akpm log_buf_len=3D8M ignore_loglevel =
debug sched_debug apic=3Ddebug dynamic_printk sysrq_always_enabled panic=3D=
10  prompt_ramdisk=3D0 console=3DttyS0,115200 console=3Dtty0 vga=3Dnormal  =
root=3D/dev/ram0 rw link=3Dvmlinuz-2012-09-13-16-57-27-next:akpm:d660ebb-db=
f978b-x86_64-randconfig-s311-1-fat BOOT_IMAGE=3Dkernel-tests/kernels/x86_64=
-randconfig-s311/dbf978b/vmlinuz-3.6.0-rc5-07686-gdbf978b
[    0.000000] e820: BIOS-provided physical RAM map:
[    0.000000] BIOS-e820: [mem 0x0000000000000000-0x0000000000093bff] usable
[    0.000000] BIOS-e820: [mem 0x0000000000093c00-0x000000000009ffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000000f0000-0x00000000000fffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x0000000000100000-0x000000000fffdfff] usable
[    0.000000] BIOS-e820: [mem 0x000000000fffe000-0x000000000fffffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000feffc000-0x00000000feffffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000fffc0000-0x00000000ffffffff] reser=
ved
[    0.000000] debug: ignoring loglevel setting.
[    0.000000] NX (Execute Disable) protection: active
[    0.000000] DMI 2.4 present.
[    0.000000] DMI: Bochs Bochs, BIOS Bochs 01/01/2007
[    0.000000] Hypervisor detected: KVM
[    0.000000] e820: update [mem 0x00000000-0x0000ffff] usable =3D=3D> rese=
rved
[    0.000000] e820: remove [mem 0x000a0000-0x000fffff] usable
[    0.000000] No AGP bridge found
[    0.000000] e820: last_pfn =3D 0xfffe max_arch_pfn =3D 0x400000000
[    0.000000] MTRR default type: write-back
[    0.000000] MTRR fixed ranges enabled:
[    0.000000]   00000-9FFFF write-back
[    0.000000]   A0000-BFFFF uncachable
[    0.000000]   C0000-FFFFF write-protect
[    0.000000] MTRR variable ranges enabled:
[    0.000000]   0 base 00E0000000 mask FFE0000000 uncachable
[    0.000000]   1 disabled
[    0.000000]   2 disabled
[    0.000000]   3 disabled
[    0.000000]   4 disabled
[    0.000000]   5 disabled
[    0.000000]   6 disabled
[    0.000000]   7 disabled
[    0.000000] x86 PAT enabled: cpu 0, old 0x70406, new 0x7010600070106
[    0.000000] initial memory mapped: [mem 0x00000000-0x1fffffff]
[    0.000000] Base memory trampoline at [ffff88000008d000] 8d000 size 24576
[    0.000000] init_memory_mapping: [mem 0x00000000-0x0fffdfff]
[    0.000000]  [mem 0x00000000-0x0fdfffff] page 2M
[    0.000000]  [mem 0x0fe00000-0x0fffdfff] page 4k
[    0.000000] kernel direct mapping tables up to 0xfffdfff @ [mem 0x0e8540=
00-0x0e8d5fff]
[    0.000000] log_buf_len: 8388608
[    0.000000] early log buf free: 128292(97%)
[    0.000000] RAMDISK: [mem 0x0e8d6000-0x0ffeffff]
[    0.000000] ACPI: RSDP 00000000000fd920 00014 (v00 BOCHS )
[    0.000000] ACPI: RSDT 000000000fffe550 00038 (v01 BOCHS  BXPCRSDT 00000=
001 BXPC 00000001)
[    0.000000] ACPI: FACP 000000000fffff80 00074 (v01 BOCHS  BXPCFACP 00000=
001 BXPC 00000001)
[    0.000000] ACPI: DSDT 000000000fffe590 01121 (v01   BXPC   BXDSDT 00000=
001 INTL 20100528)
[    0.000000] ACPI: FACS 000000000fffff40 00040
[    0.000000] ACPI: SSDT 000000000ffffe40 000FF (v01 BOCHS  BXPCSSDT 00000=
001 BXPC 00000001)
[    0.000000] ACPI: APIC 000000000ffffd50 00080 (v01 BOCHS  BXPCAPIC 00000=
001 BXPC 00000001)
[    0.000000] ACPI: HPET 000000000ffffd10 00038 (v01 BOCHS  BXPCHPET 00000=
001 BXPC 00000001)
[    0.000000] ACPI: SSDT 000000000ffff6c0 00644 (v01   BXPC BXSSDTPC 00000=
001 INTL 20100528)
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to ffffffffff5fa000 (        fee00000)
[    0.000000] kvm-clock: Using msrs 4b564d01 and 4b564d00
[    0.000000] kvm-clock: cpu 0, msr 0:21da9c1, boot clock
[    0.000000]  [ffffea0000000000-ffffea00003fffff] PMD -> [ffff88000d40000=
0-ffff88000d7fffff] on node 0
[    0.000000] Zone ranges:
[    0.000000]   DMA      [mem 0x00010000-0x00ffffff]
[    0.000000]   DMA32    [mem 0x01000000-0xffffffff]
[    0.000000]   Normal   empty
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x00010000-0x00092fff]
[    0.000000]   node   0: [mem 0x00100000-0x0fffdfff]
[    0.000000] On node 0 totalpages: 65409
[    0.000000]   DMA zone: 64 pages used for memmap
[    0.000000]   DMA zone: 6 pages reserved
[    0.000000]   DMA zone: 3901 pages, LIFO batch:0
[    0.000000]   DMA32 zone: 960 pages used for memmap
[    0.000000]   DMA32 zone: 60478 pages, LIFO batch:15
[    0.000000] ACPI: PM-Timer IO Port: 0xb008
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to ffffffffff5fa000 (        fee00000)
[    0.000000] ACPI: LAPIC (acpi_id[0x00] lapic_id[0x00] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x01] lapic_id[0x01] enabled)
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0xff] dfl dfl lint[0x1])
[    0.000000] ACPI: IOAPIC (id[0x02] address[0xfec00000] gsi_base[0])
[    0.000000] IOAPIC[0]: apic_id 2, version 17, address 0xfec00000, GSI 0-=
23
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 00, APIC ID 2, APIC =
INT 02
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 5 global_irq 5 high level)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 05, APIC ID 2, APIC =
INT 05
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 09, APIC ID 2, APIC =
INT 09
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 10 global_irq 10 high level)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 0a, APIC ID 2, APIC =
INT 0a
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 11 global_irq 11 high level)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 0b, APIC ID 2, APIC =
INT 0b
[    0.000000] ACPI: IRQ0 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 01, APIC ID 2, APIC =
INT 01
[    0.000000] ACPI: IRQ2 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 03, APIC ID 2, APIC =
INT 03
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 04, APIC ID 2, APIC =
INT 04
[    0.000000] ACPI: IRQ5 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 06, APIC ID 2, APIC =
INT 06
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 07, APIC ID 2, APIC =
INT 07
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 08, APIC ID 2, APIC =
INT 08
[    0.000000] ACPI: IRQ9 used by override.
[    0.000000] ACPI: IRQ10 used by override.
[    0.000000] ACPI: IRQ11 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0c, APIC ID 2, APIC =
INT 0c
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0d, APIC ID 2, APIC =
INT 0d
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0e, APIC ID 2, APIC =
INT 0e
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0f, APIC ID 2, APIC =
INT 0f
[    0.000000] Using ACPI (MADT) for SMP configuration information
[    0.000000] ACPI: HPET id: 0x8086a201 base: 0xfed00000
[    0.000000] smpboot: Allowing 2 CPUs, 0 hotplug CPUs
[    0.000000] mapped IOAPIC to ffffffffff5f9000 (fec00000)
[    0.000000] nr_irqs_gsi: 40
[    0.000000] PM: Registered nosave memory: 0000000000093000 - 00000000000=
94000
[    0.000000] PM: Registered nosave memory: 0000000000094000 - 00000000000=
a0000
[    0.000000] PM: Registered nosave memory: 00000000000a0000 - 00000000000=
f0000
[    0.000000] PM: Registered nosave memory: 00000000000f0000 - 00000000001=
00000
[    0.000000] e820: [mem 0x10000000-0xfeffbfff] available for PCI devices
[    0.000000] Booting paravirtualized kernel on KVM
[    0.000000] setup_percpu: NR_CPUS:8 nr_cpumask_bits:8 nr_cpu_ids:2 nr_no=
de_ids:1
[    0.000000] PERCPU: Embedded 26 pages/cpu @ffff88000de00000 s83520 r0 d2=
2976 u1048576
[    0.000000] pcpu-alloc: s83520 r0 d22976 u1048576 alloc=3D1*2097152
[    0.000000] pcpu-alloc: [0] 0 1=20
[    0.000000] kvm-clock: cpu 0, msr 0:de139c1, primary cpu clock
[    0.000000] KVM setup async PF for cpu 0
[    0.000000] kvm-stealtime: cpu 0, msr de0dd80
[    0.000000] Built 1 zonelists in Zone order, mobility grouping on.  Tota=
l pages: 64379
[    0.000000] Kernel command line: trinity=3D2m hung_task_panic=3D1 rcutre=
e.rcu_cpu_stall_timeout=3D100 branch=3Dnext/akpm log_buf_len=3D8M ignore_lo=
glevel debug sched_debug apic=3Ddebug dynamic_printk sysrq_always_enabled p=
anic=3D10  prompt_ramdisk=3D0 console=3DttyS0,115200 console=3Dtty0 vga=3Dn=
ormal  root=3D/dev/ram0 rw link=3Dvmlinuz-2012-09-13-16-57-27-next:akpm:d66=
0ebb-dbf978b-x86_64-randconfig-s311-1-fat BOOT_IMAGE=3Dkernel-tests/kernels=
/x86_64-randconfig-s311/dbf978b/vmlinuz-3.6.0-rc5-07686-gdbf978b
[    0.000000] sysrq: sysrq always enabled.
[    0.000000] PID hash table entries: 1024 (order: 1, 8192 bytes)
[    0.000000] Dentry cache hash table entries: 32768 (order: 6, 262144 byt=
es)
[    0.000000] Inode-cache hash table entries: 16384 (order: 5, 131072 byte=
s)
[    0.000000] __ex_table already sorted, skipping sort
[    0.000000] Checking aperture...
[    0.000000] No AGP bridge found
[    0.000000] Memory: 204968k/262136k available (10375k kernel code, 500k =
absent, 56668k reserved, 7821k data, 660k init)
[    0.000000] SLUB: Genslabs=3D15, HWalign=3D64, Order=3D0-3, MinObjects=
=3D0, CPUs=3D2, Nodes=3D1
[    0.000000] Preemptible hierarchical RCU implementation.
[    0.000000]=20
[    0.000000]=20
[    0.000000]=20
[    0.000000] NR_IRQS:4352 nr_irqs:512 16
[    0.000000] Console: colour VGA+ 80x25
[    0.000000] console [tty0] enabled
[    0.000000] console [ttyS0] enabled
[    0.000000] hpet clockevent registered
[    0.000000] tsc: Detected 3200.304 MHz processor
[    0.008000] Calibrating delay loop (skipped) preset value.. 6400.60 Bogo=
MIPS (lpj=3D12801216)
[    0.008000] pid_max: default: 32768 minimum: 301
[    0.008000] Mount-cache hash table entries: 256
[    0.008205] Initializing cgroup subsys debug
[    0.008846] Initializing cgroup subsys cpuacct
[    0.012005] Initializing cgroup subsys freezer
[    0.012665] Initializing cgroup subsys blkio
[    0.013292] Initializing cgroup subsys perf_event
[    0.014044] Initializing cgroup subsys net_prio
[    0.014755] mce: CPU supports 10 MCE banks
[    0.015401] Last level iTLB entries: 4KB 0, 2MB 0, 4MB 0
[    0.015401] Last level dTLB entries: 4KB 0, 2MB 0, 4MB 0
[    0.015401] tlb_flushall_shift: 6
[    0.016065] Freeing SMP alternatives: 28k freed
[    0.020448] ACPI: Core revision 20120711
[    0.022739] Getting VERSION: 50014
[    0.023297] Getting VERSION: 50014
[    0.023912] Getting ID: 0
[    0.024010] Getting ID: ff000000
[    0.024543] Getting LVT0: 8700
[    0.025052] Getting LVT1: 8400
[    0.025673] enabled ExtINT on CPU#0
[    0.026826] ENABLING IO-APIC IRQs
[    0.027362] init IO_APIC IRQs
[    0.028006]  apic 2 pin 0 not connected
[    0.028597] IOAPIC[0]: Set routing entry (2-1 -> 0x31 -> IRQ 1 Mode:0 Ac=
tive:0 Dest:1)
[    0.029822] IOAPIC[0]: Set routing entry (2-2 -> 0x30 -> IRQ 0 Mode:0 Ac=
tive:0 Dest:1)
[    0.030975] IOAPIC[0]: Set routing entry (2-3 -> 0x33 -> IRQ 3 Mode:0 Ac=
tive:0 Dest:1)
[    0.032016] IOAPIC[0]: Set routing entry (2-4 -> 0x34 -> IRQ 4 Mode:0 Ac=
tive:0 Dest:1)
[    0.033145] IOAPIC[0]: Set routing entry (2-5 -> 0x35 -> IRQ 5 Mode:1 Ac=
tive:0 Dest:1)
[    0.034357] IOAPIC[0]: Set routing entry (2-6 -> 0x36 -> IRQ 6 Mode:0 Ac=
tive:0 Dest:1)
[    0.036016] IOAPIC[0]: Set routing entry (2-7 -> 0x37 -> IRQ 7 Mode:0 Ac=
tive:0 Dest:1)
[    0.037150] IOAPIC[0]: Set routing entry (2-8 -> 0x38 -> IRQ 8 Mode:0 Ac=
tive:0 Dest:1)
[    0.038351] IOAPIC[0]: Set routing entry (2-9 -> 0x39 -> IRQ 9 Mode:1 Ac=
tive:0 Dest:1)
[    0.039486] IOAPIC[0]: Set routing entry (2-10 -> 0x3a -> IRQ 10 Mode:1 =
Active:0 Dest:1)
[    0.040016] IOAPIC[0]: Set routing entry (2-11 -> 0x3b -> IRQ 11 Mode:1 =
Active:0 Dest:1)
[    0.041245] IOAPIC[0]: Set routing entry (2-12 -> 0x3c -> IRQ 12 Mode:0 =
Active:0 Dest:1)
[    0.042402] IOAPIC[0]: Set routing entry (2-13 -> 0x3d -> IRQ 13 Mode:0 =
Active:0 Dest:1)
[    0.044017] IOAPIC[0]: Set routing entry (2-14 -> 0x3e -> IRQ 14 Mode:0 =
Active:0 Dest:1)
[    0.045166] IOAPIC[0]: Set routing entry (2-15 -> 0x3f -> IRQ 15 Mode:0 =
Active:0 Dest:1)
[    0.046386]  apic 2 pin 16 not connected
[    0.046971]  apic 2 pin 17 not connected
[    0.048006]  apic 2 pin 18 not connected
[    0.048595]  apic 2 pin 19 not connected
[    0.049181]  apic 2 pin 20 not connected
[    0.049850]  apic 2 pin 21 not connected
[    0.050432]  apic 2 pin 22 not connected
[    0.051020]  apic 2 pin 23 not connected
[    0.051815] ..TIMER: vector=3D0x30 apic1=3D0 pin1=3D2 apic2=3D-1 pin2=3D=
-1
[    0.052007] smpboot: CPU0: Intel Common KVM processor stepping 01
[    0.053494] Using local APIC timer interrupts.
[    0.053494] calibrating APIC timer ...
[    0.060003] ... lapic delta =3D 6249987
[    0.060003] ... PM-Timer delta =3D 357951
[    0.060003] ... PM-Timer result ok
[    0.060003] ..... delta 6249987
[    0.060003] ..... mult: 268418121
[    0.060003] ..... calibration result: 3999991
[    0.060003] ..... CPU clock speed is 3200.0285 MHz.
[    0.060003] ..... host bus clock speed is 999.3991 MHz.
[    0.060046] Performance Events: unsupported Netburst CPU model 6 no PMU =
driver, software events only.
[    0.072063] ftrace: Allocated trace_printk buffers
[    0.073167] Testing tracer nop: PASSED
[    0.076075] smpboot: Booting Node   0, Processors  #1 OK
[    0.008000] kvm-clock: cpu 1, msr 0:df139c1, secondary cpu clock
[    0.008000] masked ExtINT on CPU#1
[    0.096045] Brought up 2 CPUs
[    0.096045] KVM setup async PF for cpu 1
[    0.096045] kvm-stealtime: cpu 1, msr df0dd80
[    0.097945] smpboot: Total of 2 processors activated (12801.21 BogoMIPS)
[    0.100274] CPU0 attaching sched-domain:
[    0.100934]  domain 0: span 0-1 level CPU
[    0.101744]   groups: 0 (cpu_power =3D 987) 1
[    0.102611] CPU1 attaching sched-domain:
[    0.103270]  domain 0: span 0-1 level CPU
[    0.104015]   groups: 1 0 (cpu_power =3D 987)
[    0.105002] devtmpfs: initialized
[    0.105393] regulator-dummy: no parameters
[    0.108062] NET: Registered protocol family 16
[    0.109247] ACPI: bus type pci registered
[    0.109951] PCI: Using configuration type 1 for base access
[    0.112766] bio: create slab <bio-0> at 0
[    0.112766] ACPI: Added _OSI(Module Device)
[    0.112766] ACPI: Added _OSI(Processor Device)
[    0.113371] ACPI: Added _OSI(3.0 _SCP Extensions)
[    0.114119] ACPI: Added _OSI(Processor Aggregator Device)
[    0.116786] ACPI: EC: Look up EC in DSDT
[    0.120857] ACPI: Interpreter enabled
[    0.121507] ACPI: (supports S0 S3 S4 S5)
[    0.122378] ACPI: Using IOAPIC for interrupt routing
[    0.126802] PCI: Ignoring host bridge windows from ACPI; if necessary, u=
se "pci=3Duse_crs" and report a bug
[    0.128032] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-ff])
[    0.129036] pci_root PNP0A03:00: host bridge window [io  0x0000-0x0cf7] =
(ignored)
[    0.130121] pci_root PNP0A03:00: host bridge window [io  0x0d00-0xffff] =
(ignored)
[    0.131266] pci_root PNP0A03:00: host bridge window [mem 0x000a0000-0x00=
0bffff] (ignored)
[    0.132012] pci_root PNP0A03:00: host bridge window [mem 0xe0000000-0xfe=
bfffff] (ignored)
[    0.133237] PCI: root bus 00: using default resources
[    0.134040] PCI host bridge to bus 0000:00
[    0.134643] pci_bus 0000:00: busn_res: [bus 00-ff] is inserted under dom=
ain [bus 00-ff]
[    0.136012] pci_bus 0000:00: root bus resource [bus 00-ff]
[    0.136917] pci_bus 0000:00: root bus resource [io  0x0000-0xffff]
[    0.137729] pci_bus 0000:00: root bus resource [mem 0x00000000-0xfffffff=
fff]
[    0.138732] pci 0000:00:00.0: [8086:1237] type 00 class 0x060000
[    0.140246] pci 0000:00:01.0: [8086:7000] type 00 class 0x060100
[    0.141547] pci 0000:00:01.1: [8086:7010] type 00 class 0x010180
[    0.144182] pci 0000:00:01.1: reg 20: [io  0xc1c0-0xc1cf]
[    0.145810] pci 0000:00:01.3: [8086:7113] type 00 class 0x068000
[    0.146980] pci 0000:00:01.3: quirk: [io  0xb000-0xb03f] claimed by PIIX=
4 ACPI
[    0.148022] pci 0000:00:01.3: quirk: [io  0xb100-0xb10f] claimed by PIIX=
4 SMB
[    0.149217] pci 0000:00:02.0: [1013:00b8] type 00 class 0x030000
[    0.152050] pci 0000:00:02.0: reg 10: [mem 0xfc000000-0xfdffffff pref]
[    0.153901] pci 0000:00:02.0: reg 14: [mem 0xfebf4000-0xfebf4fff]
[    0.158857] pci 0000:00:02.0: reg 30: [mem 0xfebe0000-0xfebeffff pref]
[    0.160160] pci 0000:00:03.0: [8086:100e] type 00 class 0x020000
[    0.161731] pci 0000:00:03.0: reg 10: [mem 0xfeba0000-0xfebbffff]
[    0.163203] pci 0000:00:03.0: reg 14: [io  0xc000-0xc03f]
[    0.167187] pci 0000:00:03.0: reg 30: [mem 0xfebc0000-0xfebdffff pref]
[    0.168114] pci 0000:00:04.0: [8086:2668] type 00 class 0x040300
[    0.169423] pci 0000:00:04.0: reg 10: [mem 0xfebf0000-0xfebf3fff]
[    0.172775] pci 0000:00:05.0: [1af4:1001] type 00 class 0x010000
[    0.174292] pci 0000:00:05.0: reg 10: [io  0xc040-0xc07f]
[    0.175790] pci 0000:00:05.0: reg 14: [mem 0xfebf5000-0xfebf5fff]
[    0.180168] pci 0000:00:06.0: [1af4:1001] type 00 class 0x010000
[    0.181767] pci 0000:00:06.0: reg 10: [io  0xc080-0xc0bf]
[    0.183195] pci 0000:00:06.0: reg 14: [mem 0xfebf6000-0xfebf6fff]
[    0.187450] pci 0000:00:07.0: [1af4:1001] type 00 class 0x010000
[    0.188815] pci 0000:00:07.0: reg 10: [io  0xc0c0-0xc0ff]
[    0.190156] pci 0000:00:07.0: reg 14: [mem 0xfebf7000-0xfebf7fff]
[    0.194855] pci 0000:00:08.0: [1af4:1001] type 00 class 0x010000
[    0.196326] pci 0000:00:08.0: reg 10: [io  0xc100-0xc13f]
[    0.197829] pci 0000:00:08.0: reg 14: [mem 0xfebf8000-0xfebf8fff]
[    0.202165] pci 0000:00:09.0: [1af4:1001] type 00 class 0x010000
[    0.203761] pci 0000:00:09.0: reg 10: [io  0xc140-0xc17f]
[    0.204697] pci 0000:00:09.0: reg 14: [mem 0xfebf9000-0xfebf9fff]
[    0.209580] pci 0000:00:0a.0: [1af4:1001] type 00 class 0x010000
[    0.211094] pci 0000:00:0a.0: reg 10: [io  0xc180-0xc1bf]
[    0.212700] pci 0000:00:0a.0: reg 14: [mem 0xfebfa000-0xfebfafff]
[    0.216967] pci 0000:00:0b.0: [8086:25ab] type 00 class 0x088000
[    0.218109] pci 0000:00:0b.0: reg 10: [mem 0xfebfb000-0xfebfb00f]
[    0.221458] pci_bus 0000:00: on NUMA node 0
[    0.222190] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0._PRT]
[    0.223758]  pci0000:00: ACPI _OSC support notification failed, disablin=
g PCIe ASPM
[    0.224018]  pci0000:00: Unable to request _OSC control (_OSC support ma=
sk: 0x08)
[    0.233537] ACPI: PCI Interrupt Link [LNKA] (IRQs 5 *10 11)
[    0.234814] ACPI: PCI Interrupt Link [LNKB] (IRQs 5 *10 11)
[    0.236091] ACPI: PCI Interrupt Link [LNKC] (IRQs 5 10 *11)
[    0.237449] ACPI: PCI Interrupt Link [LNKD] (IRQs 5 10 *11)
[    0.238718] ACPI: PCI Interrupt Link [LNKS] (IRQs 9) *0
[    0.240091] vgaarb: device added: PCI:0000:00:02.0,decodes=3Dio+mem,owns=
=3Dio+mem,locks=3Dnone
[    0.241331] vgaarb: loaded
[    0.241793] vgaarb: bridge control possible 0000:00:02.0
[    0.242750] wmi: Mapper loaded
[    0.243282] PCI: Using ACPI for IRQ routing
[    0.244022] PCI: pci_cache_line_size set to 64 bytes
[    0.245069] e820: reserve RAM buffer [mem 0x00093c00-0x0009ffff]
[    0.245865] e820: reserve RAM buffer [mem 0x0fffe000-0x0fffffff]
[    0.247116] HPET: 3 timers in total, 0 timers will be used for per-cpu t=
imer
[    0.252056] Switching to clocksource kvm-clock
[    0.253065] Warning: could not register annotated branches stats
[    0.267014] FS-Cache: Loaded
[    0.267542] pnp: PnP ACPI init
[    0.268143] ACPI: bus type pnp registered
[    0.268772] pnp 00:00: [bus 00-ff]
[    0.269303] pnp 00:00: [io  0x0cf8-0x0cff]
[    0.269981] pnp 00:00: [io  0x0000-0x0cf7 window]
[    0.270644] pnp 00:00: [io  0x0d00-0xffff window]
[    0.271305] pnp 00:00: [mem 0x000a0000-0x000bffff window]
[    0.272130] pnp 00:00: [mem 0xe0000000-0xfebfffff window]
[    0.272901] pnp 00:00: Plug and Play ACPI device, IDs PNP0a03 (active)
[    0.273856] pnp 00:01: [io  0x0070-0x0071]
[    0.274473] IOAPIC[0]: Set routing entry (2-8 -> 0x38 -> IRQ 8 Mode:0 Ac=
tive:0 Dest:3)
[    0.275677] pnp 00:01: [irq 8]
[    0.276188] pnp 00:01: [io  0x0072-0x0077]
[    0.276823] pnp 00:01: Plug and Play ACPI device, IDs PNP0b00 (active)
[    0.277791] pnp 00:02: [io  0x0060]
[    0.278334] pnp 00:02: [io  0x0064]
[    0.278876] IOAPIC[0]: Set routing entry (2-1 -> 0x31 -> IRQ 1 Mode:0 Ac=
tive:0 Dest:3)
[    0.280093] pnp 00:02: [irq 1]
[    0.280623] pnp 00:02: Plug and Play ACPI device, IDs PNP0303 (active)
[    0.281509] IOAPIC[0]: Set routing entry (2-12 -> 0x3c -> IRQ 12 Mode:0 =
Active:0 Dest:3)
[    0.282735] pnp 00:03: [irq 12]
[    0.283256] pnp 00:03: Plug and Play ACPI device, IDs PNP0f13 (active)
[    0.284239] pnp 00:04: [io  0x03f2-0x03f5]
[    0.284855] pnp 00:04: [io  0x03f7]
[    0.285397] IOAPIC[0]: Set routing entry (2-6 -> 0x36 -> IRQ 6 Mode:0 Ac=
tive:0 Dest:3)
[    0.286601] pnp 00:04: [irq 6]
[    0.287097] pnp 00:04: [dma 2]
[    0.287691] pnp 00:04: Plug and Play ACPI device, IDs PNP0700 (active)
[    0.288628] pnp 00:05: [io  0x0378-0x037f]
[    0.289238] IOAPIC[0]: Set routing entry (2-7 -> 0x37 -> IRQ 7 Mode:0 Ac=
tive:0 Dest:3)
[    0.290440] pnp 00:05: [irq 7]
[    0.290957] pnp 00:05: Plug and Play ACPI device, IDs PNP0400 (active)
[    0.291951] pnp 00:06: [io  0x03f8-0x03ff]
[    0.292575] IOAPIC[0]: Set routing entry (2-4 -> 0x34 -> IRQ 4 Mode:0 Ac=
tive:0 Dest:3)
[    0.293775] pnp 00:06: [irq 4]
[    0.294294] pnp 00:06: Plug and Play ACPI device, IDs PNP0501 (active)
[    0.295343] pnp 00:07: [mem 0xfed00000-0xfed003ff]
[    0.296133] pnp 00:07: Plug and Play ACPI device, IDs PNP0103 (active)
[    0.297180] pnp: PnP ACPI: found 8 devices
[    0.297864] ACPI: ACPI bus type pnp unregistered
[    0.307787] pci_bus 0000:00: resource 4 [io  0x0000-0xffff]
[    0.308630] pci_bus 0000:00: resource 5 [mem 0x00000000-0xffffffffff]
[    0.309535] NET: Registered protocol family 2
[    0.310339] TCP established hash table entries: 8192 (order: 5, 131072 b=
ytes)
[    0.311370] TCP bind hash table entries: 8192 (order: 5, 131072 bytes)
[    0.312323] TCP: Hash tables configured (established 8192 bind 8192)
[    0.313258] TCP: reno registered
[    0.313798] UDP hash table entries: 256 (order: 1, 8192 bytes)
[    0.314639] UDP-Lite hash table entries: 256 (order: 1, 8192 bytes)
[    0.315550] NET: Registered protocol family 1
[    0.316386] RPC: Registered named UNIX socket transport module.
[    0.317242] RPC: Registered udp transport module.
[    0.317933] RPC: Registered tcp transport module.
[    0.318652] RPC: Registered tcp NFSv4.1 backchannel transport module.
[    0.319532] pci 0000:00:00.0: Limiting direct PCI/PCI transfers
[    0.320382] pci 0000:00:01.0: PIIX3: Enabling Passive Release
[    0.321222] pci 0000:00:01.0: Activating ISA DMA hang workarounds
[    0.322084] pci 0000:00:02.0: Boot video device
[    0.322867] PCI: CLS 0 bytes, default 64
[    0.323531] Unpacking initramfs...
[    0.814141] Freeing initrd memory: 23656k freed
[    0.818613] kvm: no hardware support
[    0.819182] has_svm: not amd
[    0.819666] kvm: no hardware support
[    0.820988] camellia-x86_64: performance on this CPU would be suboptimal=
: disabling camellia-x86_64.
[    0.823292] AVX instructions are not detected.
[    0.896057] Testing tracer preemptoff: PASSED
[    1.112580] HugeTLB registered 2 MB page size, pre-allocated 0 pages
[    1.117150] VFS: Disk quotas dquot_6.5.2
[    1.117818] Dquot-cache hash table entries: 512 (order 0, 4096 bytes)
[    1.120295] NTFS driver 2.1.30 [Flags: R/W].
[    1.121035] fuse init (API version 7.20)
[    1.121830] JFS: nTxBlock =3D 1786, nTxLock =3D 14290
[    1.132045] SGI XFS with ACLs, security attributes, realtime, large bloc=
k/inode numbers, no debug enabled
[    1.140050] 9p: Installing v9fs 9p2000 file system support
[    1.144204] GFS2 installed
[    1.148039] alg: No test for cipher_null (cipher_null-generic)
[    1.152046] alg: No test for ecb(cipher_null) (ecb-cipher_null)
[    1.156039] alg: No test for compress_null (compress_null-generic)
[    1.160045] alg: No test for digest_null (digest_null-generic)
[    1.272045] alg: No test for stdrng (krng)
[    1.284071] io scheduler noop registered (default)
[    1.285121] crc32: CRC_LE_BITS =3D 64, CRC_BE BITS =3D 64
[    1.285851] crc32: self tests passed, processed 225944 bytes in 131888 n=
sec
[    1.286904] crc32c: CRC_LE_BITS =3D 64
[    1.287469] crc32c: self tests passed, processed 225944 bytes in 65994 n=
sec
[    1.288465] xz_dec_test: module loaded
[    1.289092] xz_dec_test: Create a device node with 'mknod xz_dec_test c =
251 0' and write .xz files to it.
[    1.290478] pci_hotplug: PCI Hot Plug PCI Core version: 0.5
[    1.291271] shpchp: Standard Hot Plug PCI Controller Driver version: 0.4
[    1.292191] acpiphp: ACPI Hot Plug PCI Controller Driver version: 0.5
[    1.293216] acpiphp: Slot [3] registered
[    1.293856] acpiphp: Slot [4] registered
[    1.294486] acpiphp: Slot [5] registered
[    1.295122] acpiphp: Slot [6] registered
[    1.295753] acpiphp: Slot [7] registered
[    1.300048] acpiphp: Slot [8] registered
[    1.300727] acpiphp: Slot [9] registered
[    1.301357] acpiphp: Slot [10] registered
[    1.302003] acpiphp: Slot [11] registered
[    1.302651] acpiphp: Slot [12] registered
[    1.303292] acpiphp: Slot [13] registered
[    1.303937] acpiphp: Slot [14] registered
[    1.304638] acpiphp: Slot [15] registered
[    1.305281] acpiphp: Slot [16] registered
[    1.305927] acpiphp: Slot [17] registered
[    1.306576] acpiphp: Slot [18] registered
[    1.307219] acpiphp: Slot [19] registered
[    1.307866] acpiphp: Slot [20] registered
[    1.308516] acpiphp: Slot [21] registered
[    1.309185] acpiphp: Slot [22] registered
[    1.309830] acpiphp: Slot [23] registered
[    1.310467] acpiphp: Slot [24] registered
[    1.311112] acpiphp: Slot [25] registered
[    1.311760] acpiphp: Slot [26] registered
[    1.312418] acpiphp: Slot [27] registered
[    1.313092] acpiphp: Slot [28] registered
[    1.313739] acpiphp: Slot [29] registered
[    1.314385] acpiphp: Slot [30] registered
[    1.315031] acpiphp: Slot [31] registered
[    1.315838] i2c-core: driver [adp8860_bl] using legacy suspend method
[    1.316772] i2c-core: driver [adp8860_bl] using legacy resume method
[    1.317645] i2c-core: driver [adp8870_bl] using legacy suspend method
[    1.318515] i2c-core: driver [adp8870_bl] using legacy resume method
[    1.319410] rivafb_setup START
[    1.319991] vmlfb: initializing
[    1.320580] Could not find Carillo Ranch MCH device.
[    1.321301] no IO addresses supplied
[    1.321925] hgafb: HGA card not detected.
[    1.322558] hgafb: probe of hgafb.0 failed with error -22
[    1.323421] input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/inpu=
t/input0
[    1.324579] ACPI: Power Button [PWRF]
[    1.326481] r3964: Philips r3964 Driver $Revision: 1.10 $
[    1.327288] Serial: 8250/16550 driver, 4 ports, IRQ sharing disabled

[    1.668015] 00:06: ttyS0 at I/O 0x3f8 (irq =3D 4) is a 16550A
[    1.668976] MOXA Smartio/Industio family driver version 2.0.5
[    1.669806] RocketPort device driver module, version 2.09, 12-June-2003
[    1.670706] No rocketport ports found; unloading driver
[    1.671448] SyncLink GT
[    1.671906] SyncLink GT, tty major#247
[    1.672570] SyncLink GT no devices found
[    1.673176] SyncLink MultiPort driver $Revision: 4.38 $
[    1.678394] SyncLink MultiPort driver $Revision: 4.38 $, tty major#246
[    1.679331] SyncLink serial driver $Revision: 4.38 $
[    1.684595] SyncLink serial driver $Revision: 4.38 $, tty major#245
[    1.685540] smapi::smapi_init, ERROR invalid usSmapiID
[    1.686268] mwave: tp3780i::tp3780I_InitializeBoardData: Error: SMAPI is=
 not available on this machine
[    1.687559] mwave: mwavedd::mwave_init: Error: Failed to initialize boar=
d data
[    1.688707] mwave: mwavedd::mwave_init: Error: Failed to initialize
[    1.689561] Linux agpgart interface v0.103
[    1.690214] Hangcheck: starting hangcheck timer 0.9.1 (tick is 180 secon=
ds, margin is 60 seconds).
[    1.691483] Hangcheck: Using getrawmonotonic().
[    1.692184] [drm] Initialized drm 1.1.0 20060810
[    1.692939] [drm] radeon defaulting to userspace modesetting.
[    1.694465] Phantom Linux Driver, version n0.9.8, init OK
[    1.695248] i2c-core: driver [apds9802als] using legacy suspend method
[    1.696142] i2c-core: driver [apds9802als] using legacy resume method
[    1.697063] i2c-core: driver [isl29003] using legacy suspend method
[    1.697913] i2c-core: driver [isl29003] using legacy resume method
[    1.698761] i2c-core: driver [tsl2550] using legacy suspend method
[    1.699607] i2c-core: driver [tsl2550] using legacy resume method
[    1.704031] i2c-core: driver [fsa9480] using legacy suspend method
[    1.704930] i2c-core: driver [fsa9480] using legacy resume method
[    1.705852] i8042: PNP: PS/2 Controller [PNP0303:KBD,PNP0f13:MOU] at 0x6=
0,0x64 irq 1,12
[    1.710312] serio: i8042 KBD port at 0x60,0x64 irq 1
[    1.711105] serio: i8042 AUX port at 0x60,0x64 irq 12
[    1.757810] mousedev: PS/2 mouse device common for all mice
[    1.758785] apanel: Fujitsu BIOS signature 'FJKEYINF' not found...
[    1.759679] I2O subsystem v1.325
[    1.760225] i2o: max drivers =3D 8
[    1.760972] I2O Bus Adapter OSM v1.317
[    1.761577] I2O Block Device OSM v1.325
[    1.762362] Driver for 1-wire Dallas network protocol.
[    1.763170] 1-Wire driver for the DS2760 battery monitor  chip  - (c) 20=
04-2005, Szabolcs Gyurko
[    1.764566] i2c-core: driver [max17040] using legacy suspend method
[    1.765430] i2c-core: driver [max17040] using legacy resume method
[    1.766427] f71882fg: Not a Fintek device
[    1.767070] f71882fg: Not a Fintek device
[    1.767798] sch56xx_common: Unsupported device id: 0xff
[    1.768745] input: AT Translated Set 2 keyboard as /devices/platform/i80=
42/serio0/input/input1
[    1.770194] sch56xx_common: Unsupported device id: 0xff
[    1.771064] sp5100_tco: SP5100 TCO WatchDog Timer Driver v0.01
[    1.771909] wafer5823wdt: WDT driver for Wafer 5823 single board compute=
r initialising
[    1.776022] wafer5823wdt: initialized. timeout=3D60 sec (nowayout=3D1)
[    1.776936] i6300esb: Intel 6300ESB WatchDog Timer Driver v0.05
[    1.777859] i6300esb: cannot register miscdev on minor=3D130 (err=3D-16)
[    1.778733] i6300ESB timer: probe of 0000:00:0b.0 failed with error -16
[    1.779634] iTCO_wdt: Intel TCO WatchDog Timer Driver v1.10
[    1.780453] sc1200wdt: build 20020303
[    1.781044] sc1200wdt: io parameter must be specified
[    1.781778] pc87413_wdt: Version 1.1 at io 0x2E
[    1.782446] pc87413_wdt: cannot register miscdev on minor=3D130 (err=3D-=
16)
[    1.783338] nv_tco: NV TCO WatchDog Timer Driver v0.01
[    1.784116] sbc60xxwdt: I/O address 0x0443 already in use
[    1.784939] sbc8360: failed to register misc device
[    1.785651] cpu5wdt: misc_register failed
[    1.786303] smsc37b787_wdt: SMsC 37B787 watchdog component driver 1.1 in=
itialising...
[    1.788480] smsc37b787_wdt: Unable to register miscdev on minor 130
[    1.789393] w83627hf_wdt: WDT driver for the Winbond(TM) W83627HF/THF/HG=
/DHG Super I/O chip initialising
[    1.790792] w83627hf_wdt: Watchdog already running. Resetting timeout to=
 60 sec
[    1.791917] w83627hf_wdt: cannot register miscdev on minor=3D130 (err=3D=
-16)
[    1.792886] w83697hf_wdt: WDT driver for W83697HF/HG initializing
[    1.793741] w83697hf_wdt: watchdog not found at address 0x2e
[    1.794511] w83697hf_wdt: No W83697HF/HG could be found
[    1.795275] w83977f_wdt: driver v1.00
[    1.795855] w83977f_wdt: cannot register miscdev on minor=3D130 (err=3D-=
16)
[    1.796868] cpuidle: using governor ladder
[    1.797497] cpuidle: using governor menu
[    1.798159] leds_ss4200: no LED devices found
[    1.816119] asus_wmi: Asus Management GUID not found
[    1.816775] asus_wmi: Management GUID not found
[    1.817722] asus_wmi: Management GUID not found
[    1.818463] dell_wmi_aio: No known WMI GUID found
[    1.819155] acer_wmi: Acer Laptop ACPI-WMI Extras
[    1.819844] acer_wmi: No or unsupported WMI interface, unable to load
[    1.820794] tsc: Refined TSC clocksource calibration: 3200.107 MHz
[    1.821641] acerhdf: Acer Aspire One Fan driver, v.0.5.26
[    1.822406] acerhdf: unknown (unsupported) BIOS version Bochs/Bochs/Boch=
s, please report, aborting!
[    1.823781] FUJ02B1: call_fext_func: FUNC interface is not present
[    1.824691] fujitsu_laptop: driver 0.6.0 successfully loaded
[    1.825494] topstar_laptop: ACPI extras driver loaded
[    1.826307] pktgen: Packet Generator for packet performance testing. Ver=
sion: 2.74
[    1.832057] GACT probability on
[    1.832605] Mirror/redirect action on
[    1.833183] Simple TC action Loaded
[    1.833824] Netfilter messages via NETLINK v0.30.
[    1.834544] nf_conntrack version 0.5.0 (1786 buckets, 7144 max)
[    1.835406] ctnetlink v0.93: registering with nfnetlink.
[    1.836202] BUG: unable to handle kernel NULL pointer dereference at 000=
00000000000e0
[    1.837539] IP: [<ffffffff81a19123>] mutex_lock_interruptible+0x23/0x70
[    1.838493] PGD 0=20
[    1.838983] Oops: 0002 [#1] PREEMPT SMP=20
[    1.839786] CPU 0=20
[    1.840050] Pid: 1, comm: swapper/0 Not tainted 3.6.0-rc5-07686-gdbf978b=
 #58 Bochs Bochs
[    1.840172] RIP: 0010:[<ffffffff81a19123>]  [<ffffffff81a19123>] mutex_l=
ock_interruptible+0x23/0x70
[    1.840172] RSP: 0018:ffff88000d845e40  EFLAGS: 00010202
[    1.840172] RAX: 0000000000000246 RBX: 00000000000000e0 RCX: ffff88000d8=
48000
[    1.840172] RDX: 0000000000000000 RSI: 0000000000000175 RDI: ffffffff81e=
6bc88
[    1.840172] RBP: ffff88000d845e50 R08: ffffffff821bd170 R09: 00000000000=
00000
[    1.840172] R10: 0000000000000000 R11: dead000000200200 R12: 00000000fff=
fffff
[    1.840172] R13: 0000000000000004 R14: ffffffff821c1ce0 R15: 00000000000=
00000
[    1.840172] FS:  0000000000000000(0000) GS:ffff88000de00000(0000) knlGS:=
0000000000000000
[    1.840172] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[    1.840172] CR2: 00000000000000e0 CR3: 000000000200b000 CR4: 00000000000=
006f0
[    1.840172] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 00000000000=
00000
[    1.840172] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 00000000000=
00400
[    1.840172] Process swapper/0 (pid: 1, threadinfo ffff88000d844000, task=
 ffff88000d848000)
[    1.840172] Stack:
[    1.840172]  00000000000000e0 ffffffff821c1ce0 ffff88000d845e80 ffffffff=
8187c204
[    1.840172]  0000000000000000 ffffffff820f7ea0 0000000000000000 ffffffff=
821c1ce0
[    1.840172]  ffff88000d845ec0 ffffffff8187c334 ffff88000d845eb0 00000000=
00000000
[    1.840172] Call Trace:
[    1.840172]  [<ffffffff8187c204>] xt_register_target+0x34/0x70
[    1.840172]  [<ffffffff8187c334>] xt_register_targets+0x34/0x70
[    1.840172]  [<ffffffff8221f336>] ? nf_nat_init+0x12c/0x12c
[    1.840172]  [<ffffffff8221f34b>] xt_nat_init+0x15/0x17
[    1.840172]  [<ffffffff821dcc3e>] do_one_initcall+0x7a/0x134
[    1.840172]  [<ffffffff821dcdfb>] kernel_init+0x103/0x187
[    1.864014]  [<ffffffff821dc615>] ? do_early_param+0x8d/0x8d
[    1.864014]  [<ffffffff81a1dc44>] kernel_thread_helper+0x4/0x10
[    1.864014]  [<ffffffff821dccf8>] ? do_one_initcall+0x134/0x134
[    1.864014]  [<ffffffff81a1dc40>] ? gs_change+0x13/0x13
[    1.864014] Code: 8b 65 f8 c9 c3 0f 1f 00 55 31 d2 be 75 01 00 00 48 89 =
e5 41 54 41 bc ff ff ff ff 53 48 89 fb 48 c7 c7 88 bc e6 81 e8 dd 73 6e ff =
<f0> 44 0f c1 23 41 83 ec 01 31 d2 48 c7 c7 c8 b7 13 82 41 c1 ec=20
[    1.864014] RIP  [<ffffffff81a19123>] mutex_lock_interruptible+0x23/0x70
[    1.864014]  RSP <ffff88000d845e40>
[    1.864014] CR2: 00000000000000e0
[    1.876782] ---[ end trace 055f1b25ef43ed65 ]---
[    1.877467] Kernel panic - not syncing: Attempted to kill init! exitcode=
=3D0x00000009
[    1.877467]=20
[    1.878902] Rebooting in 10 seconds..
--EVF5PPMfhYS0aIcm
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="config-3.6.0-rc5-07686-gdbf978b"

#
# Automatically generated file; DO NOT EDIT.
# Linux/x86_64 3.6.0-rc5 Kernel Configuration
#
CONFIG_64BIT=y
# CONFIG_X86_32 is not set
CONFIG_X86_64=y
CONFIG_X86=y
CONFIG_INSTRUCTION_DECODER=y
CONFIG_OUTPUT_FORMAT="elf64-x86-64"
CONFIG_ARCH_DEFCONFIG="arch/x86/configs/x86_64_defconfig"
CONFIG_LOCKDEP_SUPPORT=y
CONFIG_STACKTRACE_SUPPORT=y
CONFIG_HAVE_LATENCYTOP_SUPPORT=y
CONFIG_MMU=y
CONFIG_NEED_DMA_MAP_STATE=y
CONFIG_NEED_SG_DMA_LENGTH=y
CONFIG_GENERIC_ISA_DMA=y
CONFIG_GENERIC_BUG=y
CONFIG_GENERIC_BUG_RELATIVE_POINTERS=y
CONFIG_GENERIC_HWEIGHT=y
CONFIG_GENERIC_GPIO=y
CONFIG_ARCH_MAY_HAVE_PC_FDC=y
# CONFIG_RWSEM_GENERIC_SPINLOCK is not set
CONFIG_RWSEM_XCHGADD_ALGORITHM=y
CONFIG_GENERIC_CALIBRATE_DELAY=y
CONFIG_ARCH_HAS_CPU_RELAX=y
CONFIG_ARCH_HAS_DEFAULT_IDLE=y
CONFIG_ARCH_HAS_CACHE_LINE_SIZE=y
CONFIG_ARCH_HAS_CPU_AUTOPROBE=y
CONFIG_HAVE_SETUP_PER_CPU_AREA=y
CONFIG_NEED_PER_CPU_EMBED_FIRST_CHUNK=y
CONFIG_NEED_PER_CPU_PAGE_FIRST_CHUNK=y
CONFIG_ARCH_HIBERNATION_POSSIBLE=y
CONFIG_ARCH_SUSPEND_POSSIBLE=y
CONFIG_ZONE_DMA32=y
CONFIG_AUDIT_ARCH=y
CONFIG_ARCH_SUPPORTS_OPTIMIZED_INLINING=y
CONFIG_ARCH_SUPPORTS_DEBUG_PAGEALLOC=y
CONFIG_X86_64_SMP=y
CONFIG_X86_HT=y
CONFIG_ARCH_HWEIGHT_CFLAGS="-fcall-saved-rdi -fcall-saved-rsi -fcall-saved-rdx -fcall-saved-rcx -fcall-saved-r8 -fcall-saved-r9 -fcall-saved-r10 -fcall-saved-r11"
CONFIG_ARCH_CPU_PROBE_RELEASE=y
CONFIG_ARCH_SUPPORTS_UPROBES=y
CONFIG_DEFCONFIG_LIST="/lib/modules/$UNAME_RELEASE/.config"
CONFIG_HAVE_IRQ_WORK=y
CONFIG_IRQ_WORK=y
CONFIG_BUILDTIME_EXTABLE_SORT=y

#
# General setup
#
# CONFIG_EXPERIMENTAL is not set
CONFIG_INIT_ENV_ARG_LIMIT=32
CONFIG_CROSS_COMPILE=""
CONFIG_LOCALVERSION=""
CONFIG_LOCALVERSION_AUTO=y
CONFIG_HAVE_KERNEL_GZIP=y
CONFIG_HAVE_KERNEL_BZIP2=y
CONFIG_HAVE_KERNEL_LZMA=y
CONFIG_HAVE_KERNEL_XZ=y
CONFIG_HAVE_KERNEL_LZO=y
# CONFIG_KERNEL_GZIP is not set
# CONFIG_KERNEL_BZIP2 is not set
CONFIG_KERNEL_LZMA=y
# CONFIG_KERNEL_XZ is not set
# CONFIG_KERNEL_LZO is not set
CONFIG_DEFAULT_HOSTNAME="(none)"
CONFIG_SWAP=y
# CONFIG_SYSVIPC is not set
CONFIG_BSD_PROCESS_ACCT=y
CONFIG_BSD_PROCESS_ACCT_V3=y
CONFIG_FHANDLE=y
CONFIG_TASKSTATS=y
CONFIG_TASK_DELAY_ACCT=y
CONFIG_TASK_XACCT=y
CONFIG_TASK_IO_ACCOUNTING=y
# CONFIG_AUDIT is not set
CONFIG_HAVE_GENERIC_HARDIRQS=y

#
# IRQ subsystem
#
CONFIG_GENERIC_HARDIRQS=y
CONFIG_GENERIC_IRQ_PROBE=y
CONFIG_GENERIC_IRQ_SHOW=y
CONFIG_GENERIC_PENDING_IRQ=y
CONFIG_GENERIC_IRQ_CHIP=y
CONFIG_IRQ_DOMAIN=y
# CONFIG_IRQ_DOMAIN_DEBUG is not set
CONFIG_IRQ_FORCED_THREADING=y
CONFIG_SPARSE_IRQ=y
CONFIG_CLOCKSOURCE_WATCHDOG=y
CONFIG_ARCH_CLOCKSOURCE_DATA=y
CONFIG_GENERIC_TIME_VSYSCALL=y
CONFIG_GENERIC_CLOCKEVENTS=y
CONFIG_GENERIC_CLOCKEVENTS_BUILD=y
CONFIG_GENERIC_CLOCKEVENTS_BROADCAST=y
CONFIG_GENERIC_CLOCKEVENTS_MIN_ADJUST=y
CONFIG_GENERIC_CMOS_UPDATE=y

#
# Timers subsystem
#
CONFIG_TICK_ONESHOT=y
CONFIG_NO_HZ=y
CONFIG_HIGH_RES_TIMERS=y

#
# RCU Subsystem
#
CONFIG_TREE_PREEMPT_RCU=y
CONFIG_PREEMPT_RCU=y
# CONFIG_RCU_USER_QS is not set
CONFIG_RCU_FANOUT=64
CONFIG_RCU_FANOUT_LEAF=16
CONFIG_RCU_FANOUT_EXACT=y
# CONFIG_RCU_FAST_NO_HZ is not set
# CONFIG_TREE_RCU_TRACE is not set
# CONFIG_RCU_BOOST is not set
CONFIG_IKCONFIG=y
# CONFIG_IKCONFIG_PROC is not set
CONFIG_LOG_BUF_SHIFT=17
CONFIG_HAVE_UNSTABLE_SCHED_CLOCK=y
CONFIG_CGROUPS=y
CONFIG_CGROUP_DEBUG=y
CONFIG_CGROUP_FREEZER=y
# CONFIG_CGROUP_DEVICE is not set
# CONFIG_CPUSETS is not set
CONFIG_CGROUP_CPUACCT=y
CONFIG_RESOURCE_COUNTERS=y
# CONFIG_MEMCG is not set
CONFIG_CGROUP_PERF=y
CONFIG_CGROUP_SCHED=y
CONFIG_FAIR_GROUP_SCHED=y
CONFIG_BLK_CGROUP=y
CONFIG_DEBUG_BLK_CGROUP=y
# CONFIG_CHECKPOINT_RESTORE is not set
CONFIG_NAMESPACES=y
CONFIG_UTS_NS=y
# CONFIG_PID_NS is not set
CONFIG_NET_NS=y
CONFIG_SCHED_AUTOGROUP=y
# CONFIG_SYSFS_DEPRECATED is not set
# CONFIG_RELAY is not set
CONFIG_BLK_DEV_INITRD=y
CONFIG_INITRAMFS_SOURCE=""
CONFIG_RD_GZIP=y
CONFIG_RD_BZIP2=y
CONFIG_RD_LZMA=y
CONFIG_RD_XZ=y
CONFIG_RD_LZO=y
# CONFIG_CC_OPTIMIZE_FOR_SIZE is not set
CONFIG_SYSCTL=y
CONFIG_ANON_INODES=y
# CONFIG_EXPERT is not set
CONFIG_UID16=y
# CONFIG_SYSCTL_SYSCALL is not set
CONFIG_KALLSYMS=y
# CONFIG_KALLSYMS_ALL is not set
CONFIG_HOTPLUG=y
CONFIG_PRINTK=y
CONFIG_BUG=y
CONFIG_ELF_CORE=y
CONFIG_PCSPKR_PLATFORM=y
CONFIG_HAVE_PCSPKR_PLATFORM=y
CONFIG_BASE_FULL=y
CONFIG_FUTEX=y
CONFIG_EPOLL=y
CONFIG_SIGNALFD=y
CONFIG_TIMERFD=y
CONFIG_EVENTFD=y
CONFIG_SHMEM=y
CONFIG_AIO=y
# CONFIG_EMBEDDED is not set
CONFIG_HAVE_PERF_EVENTS=y

#
# Kernel Performance Events And Counters
#
CONFIG_PERF_EVENTS=y
# CONFIG_DEBUG_PERF_USE_VMALLOC is not set
CONFIG_VM_EVENT_COUNTERS=y
CONFIG_PCI_QUIRKS=y
CONFIG_SLUB_DEBUG=y
# CONFIG_COMPAT_BRK is not set
# CONFIG_SLAB is not set
CONFIG_SLUB=y
CONFIG_PROFILING=y
CONFIG_TRACEPOINTS=y
# CONFIG_OPROFILE is not set
CONFIG_HAVE_OPROFILE=y
CONFIG_OPROFILE_NMI_TIMER=y
# CONFIG_JUMP_LABEL is not set
CONFIG_UPROBES=y
CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS=y
CONFIG_USER_RETURN_NOTIFIER=y
CONFIG_HAVE_IOREMAP_PROT=y
CONFIG_HAVE_KPROBES=y
CONFIG_HAVE_KRETPROBES=y
CONFIG_HAVE_OPTPROBES=y
CONFIG_HAVE_ARCH_TRACEHOOK=y
CONFIG_HAVE_DMA_ATTRS=y
CONFIG_USE_GENERIC_SMP_HELPERS=y
CONFIG_GENERIC_SMP_IDLE_THREAD=y
CONFIG_HAVE_REGS_AND_STACK_ACCESS_API=y
CONFIG_HAVE_DMA_API_DEBUG=y
CONFIG_HAVE_HW_BREAKPOINT=y
CONFIG_HAVE_MIXED_BREAKPOINTS_REGS=y
CONFIG_HAVE_USER_RETURN_NOTIFIER=y
CONFIG_HAVE_PERF_EVENTS_NMI=y
CONFIG_HAVE_PERF_REGS=y
CONFIG_HAVE_PERF_USER_STACK_DUMP=y
CONFIG_HAVE_ARCH_JUMP_LABEL=y
CONFIG_ARCH_HAVE_NMI_SAFE_CMPXCHG=y
CONFIG_HAVE_ALIGNED_STRUCT_PAGE=y
CONFIG_HAVE_CMPXCHG_LOCAL=y
CONFIG_HAVE_CMPXCHG_DOUBLE=y
CONFIG_ARCH_WANT_COMPAT_IPC_PARSE_VERSION=y
CONFIG_ARCH_WANT_OLD_COMPAT_IPC=y
CONFIG_HAVE_ARCH_SECCOMP_FILTER=y
CONFIG_SECCOMP_FILTER=y
CONFIG_MODULES_USE_ELF_RELA=y
CONFIG_HAVE_RCU_USER_QS=y

#
# GCOV-based kernel profiling
#
# CONFIG_GCOV_KERNEL is not set
# CONFIG_HAVE_GENERIC_DMA_COHERENT is not set
CONFIG_SLABINFO=y
CONFIG_RT_MUTEXES=y
CONFIG_BASE_SMALL=0
# CONFIG_MODULES is not set
CONFIG_STOP_MACHINE=y
CONFIG_BLOCK=y
# CONFIG_BLK_DEV_BSG is not set
# CONFIG_BLK_DEV_BSGLIB is not set
CONFIG_BLK_DEV_INTEGRITY=y

#
# Partition Types
#
# CONFIG_PARTITION_ADVANCED is not set
CONFIG_MSDOS_PARTITION=y
CONFIG_BLOCK_COMPAT=y

#
# IO Schedulers
#
CONFIG_IOSCHED_NOOP=y
# CONFIG_IOSCHED_DEADLINE is not set
# CONFIG_IOSCHED_CFQ is not set
CONFIG_DEFAULT_NOOP=y
CONFIG_DEFAULT_IOSCHED="noop"
CONFIG_PREEMPT_NOTIFIERS=y
# CONFIG_INLINE_SPIN_TRYLOCK is not set
# CONFIG_INLINE_SPIN_TRYLOCK_BH is not set
# CONFIG_INLINE_SPIN_LOCK is not set
# CONFIG_INLINE_SPIN_LOCK_BH is not set
# CONFIG_INLINE_SPIN_LOCK_IRQ is not set
# CONFIG_INLINE_SPIN_LOCK_IRQSAVE is not set
CONFIG_UNINLINE_SPIN_UNLOCK=y
# CONFIG_INLINE_SPIN_UNLOCK_BH is not set
# CONFIG_INLINE_SPIN_UNLOCK_IRQ is not set
# CONFIG_INLINE_SPIN_UNLOCK_IRQRESTORE is not set
# CONFIG_INLINE_READ_TRYLOCK is not set
# CONFIG_INLINE_READ_LOCK is not set
# CONFIG_INLINE_READ_LOCK_BH is not set
# CONFIG_INLINE_READ_LOCK_IRQ is not set
# CONFIG_INLINE_READ_LOCK_IRQSAVE is not set
# CONFIG_INLINE_READ_UNLOCK is not set
# CONFIG_INLINE_READ_UNLOCK_BH is not set
# CONFIG_INLINE_READ_UNLOCK_IRQ is not set
# CONFIG_INLINE_READ_UNLOCK_IRQRESTORE is not set
# CONFIG_INLINE_WRITE_TRYLOCK is not set
# CONFIG_INLINE_WRITE_LOCK is not set
# CONFIG_INLINE_WRITE_LOCK_BH is not set
# CONFIG_INLINE_WRITE_LOCK_IRQ is not set
# CONFIG_INLINE_WRITE_LOCK_IRQSAVE is not set
# CONFIG_INLINE_WRITE_UNLOCK is not set
# CONFIG_INLINE_WRITE_UNLOCK_BH is not set
# CONFIG_INLINE_WRITE_UNLOCK_IRQ is not set
# CONFIG_INLINE_WRITE_UNLOCK_IRQRESTORE is not set
CONFIG_MUTEX_SPIN_ON_OWNER=y
CONFIG_FREEZER=y

#
# Processor type and features
#
CONFIG_ZONE_DMA=y
CONFIG_SMP=y
# CONFIG_X86_MPPARSE is not set
CONFIG_X86_EXTENDED_PLATFORM=y
# CONFIG_X86_VSMP is not set
CONFIG_X86_SUPPORTS_MEMORY_FAILURE=y
# CONFIG_SCHED_OMIT_FRAME_POINTER is not set
# CONFIG_KVMTOOL_TEST_ENABLE is not set
CONFIG_PARAVIRT_GUEST=y
CONFIG_PARAVIRT_TIME_ACCOUNTING=y
CONFIG_XEN=y
CONFIG_XEN_DOM0=y
CONFIG_XEN_PRIVILEGED_GUEST=y
CONFIG_XEN_PVHVM=y
CONFIG_XEN_MAX_DOMAIN_MEMORY=500
CONFIG_XEN_SAVE_RESTORE=y
CONFIG_XEN_DEBUG_FS=y
CONFIG_KVM_GUEST=y
CONFIG_PARAVIRT=y
CONFIG_PARAVIRT_CLOCK=y
# CONFIG_PARAVIRT_DEBUG is not set
CONFIG_NO_BOOTMEM=y
CONFIG_MEMTEST=y
# CONFIG_MK8 is not set
# CONFIG_MPSC is not set
# CONFIG_MCORE2 is not set
# CONFIG_MATOM is not set
CONFIG_GENERIC_CPU=y
CONFIG_X86_INTERNODE_CACHE_SHIFT=6
CONFIG_X86_CMPXCHG=y
CONFIG_X86_L1_CACHE_SHIFT=6
CONFIG_X86_XADD=y
CONFIG_X86_WP_WORKS_OK=y
CONFIG_X86_TSC=y
CONFIG_X86_CMPXCHG64=y
CONFIG_X86_CMOV=y
CONFIG_X86_MINIMUM_CPU_FAMILY=64
CONFIG_X86_DEBUGCTLMSR=y
CONFIG_CPU_SUP_INTEL=y
CONFIG_CPU_SUP_AMD=y
CONFIG_CPU_SUP_CENTAUR=y
CONFIG_HPET_TIMER=y
CONFIG_DMI=y
CONFIG_GART_IOMMU=y
CONFIG_SWIOTLB=y
CONFIG_IOMMU_HELPER=y
CONFIG_NR_CPUS=8
CONFIG_SCHED_SMT=y
# CONFIG_SCHED_MC is not set
CONFIG_IRQ_TIME_ACCOUNTING=y
# CONFIG_PREEMPT_NONE is not set
# CONFIG_PREEMPT_VOLUNTARY is not set
CONFIG_PREEMPT=y
CONFIG_PREEMPT_COUNT=y
CONFIG_X86_LOCAL_APIC=y
CONFIG_X86_IO_APIC=y
CONFIG_X86_REROUTE_FOR_BROKEN_BOOT_IRQS=y
CONFIG_X86_MCE=y
# CONFIG_X86_MCE_INTEL is not set
CONFIG_X86_MCE_AMD=y
CONFIG_X86_MCE_THRESHOLD=y
# CONFIG_X86_MCE_INJECT is not set
# CONFIG_I8K is not set
# CONFIG_MICROCODE is not set
# CONFIG_X86_MSR is not set
CONFIG_X86_CPUID=y
CONFIG_ARCH_PHYS_ADDR_T_64BIT=y
CONFIG_ARCH_DMA_ADDR_T_64BIT=y
CONFIG_DIRECT_GBPAGES=y
# CONFIG_NUMA is not set
CONFIG_ARCH_SPARSEMEM_ENABLE=y
CONFIG_ARCH_SPARSEMEM_DEFAULT=y
CONFIG_ARCH_SELECT_MEMORY_MODEL=y
CONFIG_ARCH_MEMORY_PROBE=y
CONFIG_ILLEGAL_POINTER_VALUE=0xdead000000000000
CONFIG_SELECT_MEMORY_MODEL=y
CONFIG_SPARSEMEM_MANUAL=y
CONFIG_SPARSEMEM=y
CONFIG_HAVE_MEMORY_PRESENT=y
CONFIG_SPARSEMEM_EXTREME=y
CONFIG_SPARSEMEM_VMEMMAP_ENABLE=y
CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER=y
CONFIG_SPARSEMEM_VMEMMAP=y
CONFIG_HAVE_MEMBLOCK=y
CONFIG_HAVE_MEMBLOCK_NODE_MAP=y
CONFIG_ARCH_DISCARD_MEMBLOCK=y
CONFIG_MEMORY_ISOLATION=y
CONFIG_MEMORY_HOTPLUG=y
CONFIG_MEMORY_HOTPLUG_SPARSE=y
# CONFIG_MEMORY_HOTREMOVE is not set
CONFIG_PAGEFLAGS_EXTENDED=y
CONFIG_SPLIT_PTLOCK_CPUS=4
# CONFIG_COMPACTION is not set
CONFIG_MIGRATION=y
CONFIG_PHYS_ADDR_T_64BIT=y
CONFIG_ZONE_DMA_FLAG=1
CONFIG_BOUNCE=y
CONFIG_VIRT_TO_BUS=y
CONFIG_MMU_NOTIFIER=y
CONFIG_KSM=y
CONFIG_DEFAULT_MMAP_MIN_ADDR=4096
CONFIG_ARCH_SUPPORTS_MEMORY_FAILURE=y
CONFIG_MEMORY_FAILURE=y
# CONFIG_HWPOISON_INJECT is not set
# CONFIG_TRANSPARENT_HUGEPAGE is not set
# CONFIG_CROSS_MEMORY_ATTACH is not set
CONFIG_CLEANCACHE=y
CONFIG_FRONTSWAP=y
# CONFIG_X86_CHECK_BIOS_CORRUPTION is not set
CONFIG_X86_RESERVE_LOW=64
CONFIG_MTRR=y
# CONFIG_MTRR_SANITIZER is not set
CONFIG_X86_PAT=y
CONFIG_ARCH_USES_PG_UNCACHED=y
CONFIG_ARCH_RANDOM=y
CONFIG_EFI=y
# CONFIG_EFI_STUB is not set
CONFIG_SECCOMP=y
# CONFIG_CC_STACKPROTECTOR is not set
# CONFIG_HZ_100 is not set
CONFIG_HZ_250=y
# CONFIG_HZ_300 is not set
# CONFIG_HZ_1000 is not set
CONFIG_HZ=250
CONFIG_SCHED_HRTICK=y
CONFIG_KEXEC=y
CONFIG_CRASH_DUMP=y
CONFIG_PHYSICAL_START=0x1000000
# CONFIG_RELOCATABLE is not set
CONFIG_PHYSICAL_ALIGN=0x1000000
CONFIG_HOTPLUG_CPU=y
CONFIG_COMPAT_VDSO=y
# CONFIG_CMDLINE_BOOL is not set
CONFIG_ARCH_ENABLE_MEMORY_HOTPLUG=y
CONFIG_ARCH_ENABLE_MEMORY_HOTREMOVE=y

#
# Power management and ACPI options
#
CONFIG_ARCH_HIBERNATION_HEADER=y
CONFIG_SUSPEND=y
CONFIG_SUSPEND_FREEZER=y
CONFIG_HIBERNATE_CALLBACKS=y
CONFIG_HIBERNATION=y
CONFIG_PM_STD_PARTITION=""
CONFIG_PM_SLEEP=y
CONFIG_PM_SLEEP_SMP=y
# CONFIG_PM_AUTOSLEEP is not set
CONFIG_PM_WAKELOCKS=y
CONFIG_PM_WAKELOCKS_LIMIT=100
# CONFIG_PM_WAKELOCKS_GC is not set
CONFIG_PM_RUNTIME=y
CONFIG_PM=y
# CONFIG_PM_DEBUG is not set
CONFIG_ACPI=y
CONFIG_ACPI_SLEEP=y
CONFIG_ACPI_PROCFS=y
# CONFIG_ACPI_PROCFS_POWER is not set
CONFIG_ACPI_EC_DEBUGFS=y
# CONFIG_ACPI_PROC_EVENT is not set
CONFIG_ACPI_AC=y
# CONFIG_ACPI_BATTERY is not set
CONFIG_ACPI_BUTTON=y
CONFIG_ACPI_VIDEO=y
CONFIG_ACPI_FAN=y
# CONFIG_ACPI_PROCESSOR is not set
# CONFIG_ACPI_CUSTOM_DSDT is not set
CONFIG_ACPI_BLACKLIST_YEAR=0
CONFIG_ACPI_DEBUG=y
CONFIG_ACPI_DEBUG_FUNC_TRACE=y
# CONFIG_ACPI_PCI_SLOT is not set
CONFIG_X86_PM_TIMER=y
CONFIG_ACPI_HOTPLUG_MEMORY=y
CONFIG_ACPI_SBS=y
CONFIG_ACPI_HED=y
# CONFIG_ACPI_CUSTOM_METHOD is not set
CONFIG_ACPI_BGRT=y
# CONFIG_ACPI_APEI is not set
CONFIG_SFI=y

#
# CPU Frequency scaling
#
# CONFIG_CPU_FREQ is not set
CONFIG_CPU_IDLE=y
CONFIG_CPU_IDLE_GOV_LADDER=y
CONFIG_CPU_IDLE_GOV_MENU=y
# CONFIG_ARCH_NEEDS_CPU_IDLE_COUPLED is not set
# CONFIG_INTEL_IDLE is not set

#
# Memory power savings
#

#
# Bus options (PCI etc.)
#
CONFIG_PCI=y
CONFIG_PCI_DIRECT=y
# CONFIG_PCI_MMCONFIG is not set
CONFIG_PCI_XEN=y
CONFIG_PCI_DOMAINS=y
CONFIG_PCIEPORTBUS=y
# CONFIG_HOTPLUG_PCI_PCIE is not set
CONFIG_PCIEAER=y
# CONFIG_PCIE_ECRC is not set
# CONFIG_PCIEAER_INJECT is not set
CONFIG_PCIEASPM=y
# CONFIG_PCIEASPM_DEBUG is not set
CONFIG_PCIEASPM_DEFAULT=y
# CONFIG_PCIEASPM_POWERSAVE is not set
# CONFIG_PCIEASPM_PERFORMANCE is not set
CONFIG_ARCH_SUPPORTS_MSI=y
CONFIG_PCI_MSI=y
# CONFIG_PCI_DEBUG is not set
# CONFIG_PCI_REALLOC_ENABLE_AUTO is not set
# CONFIG_PCI_STUB is not set
# CONFIG_XEN_PCIDEV_FRONTEND is not set
# CONFIG_HT_IRQ is not set
CONFIG_PCI_ATS=y
CONFIG_PCI_IOV=y
CONFIG_PCI_PRI=y
CONFIG_PCI_PASID=y
# CONFIG_PCI_IOAPIC is not set
CONFIG_PCI_LABEL=y
CONFIG_ISA_DMA_API=y
CONFIG_AMD_NB=y
# CONFIG_PCCARD is not set
CONFIG_HOTPLUG_PCI=y
CONFIG_HOTPLUG_PCI_ACPI=y
# CONFIG_HOTPLUG_PCI_ACPI_IBM is not set
# CONFIG_HOTPLUG_PCI_CPCI is not set
CONFIG_HOTPLUG_PCI_SHPC=y
CONFIG_RAPIDIO=y
CONFIG_RAPIDIO_TSI721=y
CONFIG_RAPIDIO_DISC_TIMEOUT=30
CONFIG_RAPIDIO_ENABLE_RX_TX_PORTS=y
CONFIG_RAPIDIO_DMA_ENGINE=y
CONFIG_RAPIDIO_DEBUG=y
CONFIG_RAPIDIO_TSI57X=y
# CONFIG_RAPIDIO_CPS_XX is not set
CONFIG_RAPIDIO_TSI568=y
CONFIG_RAPIDIO_CPS_GEN2=y
# CONFIG_RAPIDIO_TSI500 is not set

#
# Executable file formats / Emulations
#
CONFIG_BINFMT_ELF=y
CONFIG_COMPAT_BINFMT_ELF=y
CONFIG_ARCH_BINFMT_ELF_RANDOMIZE_PIE=y
CONFIG_CORE_DUMP_DEFAULT_ELF_HEADERS=y
# CONFIG_HAVE_AOUT is not set
CONFIG_BINFMT_MISC=y
CONFIG_IA32_EMULATION=y
CONFIG_IA32_AOUT=y
CONFIG_COMPAT=y
CONFIG_COMPAT_FOR_U64_ALIGNMENT=y
CONFIG_HAVE_TEXT_POKE_SMP=y
CONFIG_X86_DEV_DMA_OPS=y
CONFIG_NET=y

#
# Networking options
#
CONFIG_PACKET=y
# CONFIG_PACKET_DIAG is not set
CONFIG_UNIX=y
# CONFIG_UNIX_DIAG is not set
CONFIG_XFRM=y
CONFIG_XFRM_ALGO=y
# CONFIG_XFRM_USER is not set
CONFIG_XFRM_IPCOMP=y
CONFIG_NET_KEY=y
CONFIG_INET=y
CONFIG_IP_MULTICAST=y
# CONFIG_IP_ADVANCED_ROUTER is not set
CONFIG_IP_PNP=y
CONFIG_IP_PNP_DHCP=y
CONFIG_IP_PNP_BOOTP=y
CONFIG_IP_PNP_RARP=y
# CONFIG_NET_IPIP is not set
CONFIG_NET_IPGRE_DEMUX=y
CONFIG_NET_IPGRE=y
# CONFIG_NET_IPGRE_BROADCAST is not set
CONFIG_IP_MROUTE=y
CONFIG_IP_PIMSM_V1=y
# CONFIG_IP_PIMSM_V2 is not set
# CONFIG_ARPD is not set
CONFIG_SYN_COOKIES=y
CONFIG_INET_AH=y
# CONFIG_INET_ESP is not set
CONFIG_INET_IPCOMP=y
CONFIG_INET_XFRM_TUNNEL=y
CONFIG_INET_TUNNEL=y
# CONFIG_INET_XFRM_MODE_TRANSPORT is not set
# CONFIG_INET_XFRM_MODE_TUNNEL is not set
CONFIG_INET_XFRM_MODE_BEET=y
# CONFIG_INET_LRO is not set
CONFIG_INET_DIAG=y
CONFIG_INET_TCP_DIAG=y
CONFIG_INET_UDP_DIAG=y
# CONFIG_TCP_CONG_ADVANCED is not set
CONFIG_TCP_CONG_CUBIC=y
CONFIG_DEFAULT_TCP_CONG="cubic"
CONFIG_IPV6=y
# CONFIG_IPV6_PRIVACY is not set
# CONFIG_IPV6_ROUTER_PREF is not set
CONFIG_INET6_AH=y
CONFIG_INET6_ESP=y
# CONFIG_INET6_IPCOMP is not set
# CONFIG_INET6_XFRM_TUNNEL is not set
CONFIG_INET6_TUNNEL=y
CONFIG_INET6_XFRM_MODE_TRANSPORT=y
CONFIG_INET6_XFRM_MODE_TUNNEL=y
# CONFIG_INET6_XFRM_MODE_BEET is not set
CONFIG_IPV6_SIT=y
CONFIG_IPV6_NDISC_NODETYPE=y
CONFIG_IPV6_TUNNEL=y
# CONFIG_IPV6_GRE is not set
CONFIG_NETWORK_SECMARK=y
CONFIG_NETFILTER=y
CONFIG_NETFILTER_DEBUG=y
# CONFIG_NETFILTER_ADVANCED is not set

#
# Core Netfilter Configuration
#
CONFIG_NETFILTER_NETLINK=y
CONFIG_NETFILTER_NETLINK_LOG=y
CONFIG_NF_CONNTRACK=y
# CONFIG_NF_CONNTRACK_SECMARK is not set
# CONFIG_NF_CONNTRACK_PROCFS is not set
CONFIG_NF_CONNTRACK_FTP=y
CONFIG_NF_CONNTRACK_IRC=y
# CONFIG_NF_CONNTRACK_NETBIOS_NS is not set
# CONFIG_NF_CONNTRACK_SIP is not set
CONFIG_NF_CT_NETLINK=y
CONFIG_NF_NAT=y
CONFIG_NF_NAT_NEEDED=y
# CONFIG_NF_NAT_AMANDA is not set
CONFIG_NF_NAT_FTP=y
CONFIG_NF_NAT_IRC=y
# CONFIG_NF_NAT_SIP is not set
# CONFIG_NF_NAT_TFTP is not set
CONFIG_NETFILTER_XTABLES=y

#
# Xtables combined modules
#
# CONFIG_NETFILTER_XT_MARK is not set

#
# Xtables targets
#
CONFIG_NETFILTER_XT_TARGET_LOG=y
CONFIG_NETFILTER_XT_TARGET_NFLOG=y
CONFIG_NETFILTER_XT_TARGET_SECMARK=y
CONFIG_NETFILTER_XT_TARGET_TCPMSS=y

#
# Xtables matches
#
# CONFIG_NETFILTER_XT_MATCH_CONNTRACK is not set
CONFIG_NETFILTER_XT_MATCH_POLICY=y
# CONFIG_NETFILTER_XT_MATCH_STATE is not set
# CONFIG_IP_SET is not set
# CONFIG_IP_VS is not set

#
# IP: Netfilter Configuration
#
CONFIG_NF_DEFRAG_IPV4=y
CONFIG_NF_CONNTRACK_IPV4=y
CONFIG_IP_NF_IPTABLES=y
# CONFIG_IP_NF_FILTER is not set
# CONFIG_IP_NF_TARGET_ULOG is not set
CONFIG_NF_NAT_IPV4=y
# CONFIG_IP_NF_TARGET_MASQUERADE is not set
# CONFIG_NF_NAT_PPTP is not set
# CONFIG_NF_NAT_H323 is not set
# CONFIG_IP_NF_MANGLE is not set
# CONFIG_IP_NF_RAW is not set

#
# IPv6: Netfilter Configuration
#
CONFIG_NF_DEFRAG_IPV6=y
CONFIG_NF_CONNTRACK_IPV6=y
CONFIG_IP6_NF_IPTABLES=y
CONFIG_IP6_NF_MATCH_IPV6HEADER=y
# CONFIG_IP6_NF_FILTER is not set
CONFIG_IP6_NF_MANGLE=y
CONFIG_IP6_NF_RAW=y
# CONFIG_BRIDGE_NF_EBTABLES is not set
# CONFIG_ATM is not set
CONFIG_L2TP=y
# CONFIG_L2TP_DEBUGFS is not set
CONFIG_STP=y
CONFIG_BRIDGE=y
CONFIG_BRIDGE_IGMP_SNOOPING=y
CONFIG_VLAN_8021Q=y
# CONFIG_VLAN_8021Q_GVRP is not set
CONFIG_DECNET=y
CONFIG_LLC=y
# CONFIG_LLC2 is not set
CONFIG_IPX=y
CONFIG_IPX_INTERN=y
# CONFIG_ATALK is not set
CONFIG_PHONET=y
CONFIG_NET_SCHED=y

#
# Queueing/Scheduling
#
CONFIG_NET_SCH_CBQ=y
CONFIG_NET_SCH_HTB=y
CONFIG_NET_SCH_HFSC=y
CONFIG_NET_SCH_PRIO=y
# CONFIG_NET_SCH_MULTIQ is not set
# CONFIG_NET_SCH_RED is not set
# CONFIG_NET_SCH_SFB is not set
CONFIG_NET_SCH_SFQ=y
CONFIG_NET_SCH_TEQL=y
# CONFIG_NET_SCH_TBF is not set
# CONFIG_NET_SCH_GRED is not set
# CONFIG_NET_SCH_DSMARK is not set
# CONFIG_NET_SCH_NETEM is not set
# CONFIG_NET_SCH_DRR is not set
CONFIG_NET_SCH_MQPRIO=y
CONFIG_NET_SCH_CHOKE=y
CONFIG_NET_SCH_QFQ=y
CONFIG_NET_SCH_CODEL=y
CONFIG_NET_SCH_FQ_CODEL=y
# CONFIG_NET_SCH_INGRESS is not set
CONFIG_NET_SCH_PLUG=y

#
# Classification
#
CONFIG_NET_CLS=y
# CONFIG_NET_CLS_BASIC is not set
CONFIG_NET_CLS_TCINDEX=y
# CONFIG_NET_CLS_ROUTE4 is not set
CONFIG_NET_CLS_FW=y
# CONFIG_NET_CLS_U32 is not set
# CONFIG_NET_CLS_RSVP is not set
# CONFIG_NET_CLS_RSVP6 is not set
# CONFIG_NET_CLS_FLOW is not set
# CONFIG_NET_CLS_CGROUP is not set
# CONFIG_NET_EMATCH is not set
CONFIG_NET_CLS_ACT=y
# CONFIG_NET_ACT_POLICE is not set
CONFIG_NET_ACT_GACT=y
CONFIG_GACT_PROB=y
CONFIG_NET_ACT_MIRRED=y
CONFIG_NET_ACT_IPT=y
# CONFIG_NET_ACT_NAT is not set
CONFIG_NET_ACT_PEDIT=y
CONFIG_NET_ACT_SIMP=y
# CONFIG_NET_ACT_SKBEDIT is not set
# CONFIG_NET_ACT_CSUM is not set
# CONFIG_NET_CLS_IND is not set
CONFIG_NET_SCH_FIFO=y
# CONFIG_DCB is not set
CONFIG_BATMAN_ADV=y
CONFIG_BATMAN_ADV_BLA=y
CONFIG_BATMAN_ADV_DEBUG=y
CONFIG_OPENVSWITCH=y
CONFIG_RPS=y
CONFIG_RFS_ACCEL=y
CONFIG_XPS=y
CONFIG_NETPRIO_CGROUP=y
CONFIG_BQL=y

#
# Network testing
#
CONFIG_NET_PKTGEN=y
CONFIG_HAMRADIO=y

#
# Packet Radio protocols
#
# CONFIG_AX25 is not set
# CONFIG_CAN is not set
# CONFIG_IRDA is not set
# CONFIG_BT is not set
CONFIG_WIRELESS=y
# CONFIG_CFG80211 is not set
# CONFIG_LIB80211 is not set

#
# CFG80211 needs to be enabled for MAC80211
#
# CONFIG_WIMAX is not set
# CONFIG_RFKILL is not set
CONFIG_RFKILL_REGULATOR=y
CONFIG_NET_9P=y
CONFIG_NET_9P_DEBUG=y
# CONFIG_CAIF is not set
CONFIG_HAVE_BPF_JIT=y

#
# Device Drivers
#

#
# Generic Driver Options
#
CONFIG_UEVENT_HELPER_PATH=""
CONFIG_DEVTMPFS=y
CONFIG_DEVTMPFS_MOUNT=y
CONFIG_STANDALONE=y
CONFIG_PREVENT_FIRMWARE_BUILD=y
CONFIG_FW_LOADER=y
# CONFIG_FIRMWARE_IN_KERNEL is not set
CONFIG_EXTRA_FIRMWARE=""
# CONFIG_DEBUG_DRIVER is not set
# CONFIG_DEBUG_DEVRES is not set
# CONFIG_SYS_HYPERVISOR is not set
# CONFIG_GENERIC_CPU_DEVICES is not set
CONFIG_REGMAP=y
CONFIG_REGMAP_I2C=y
CONFIG_REGMAP_IRQ=y
CONFIG_DMA_SHARED_BUFFER=y

#
# Bus devices
#
# CONFIG_OMAP_OCP2SCP is not set
# CONFIG_CONNECTOR is not set
# CONFIG_MTD is not set
# CONFIG_PARPORT is not set
CONFIG_PNP=y
# CONFIG_PNP_DEBUG_MESSAGES is not set

#
# Protocols
#
CONFIG_PNPACPI=y
CONFIG_BLK_DEV=y
# CONFIG_BLK_DEV_FD is not set
# CONFIG_BLK_DEV_PCIESSD_MTIP32XX is not set
# CONFIG_BLK_CPQ_DA is not set
# CONFIG_BLK_CPQ_CISS_DA is not set
# CONFIG_BLK_DEV_DAC960 is not set
# CONFIG_BLK_DEV_COW_COMMON is not set
# CONFIG_BLK_DEV_LOOP is not set

#
# DRBD disabled because PROC_FS, INET or CONNECTOR not selected
#
# CONFIG_BLK_DEV_NBD is not set
# CONFIG_BLK_DEV_NVME is not set
# CONFIG_BLK_DEV_SX8 is not set
# CONFIG_BLK_DEV_RAM is not set
# CONFIG_CDROM_PKTCDVD is not set
# CONFIG_ATA_OVER_ETH is not set
CONFIG_XEN_BLKDEV_FRONTEND=y
# CONFIG_XEN_BLKDEV_BACKEND is not set
# CONFIG_BLK_DEV_HD is not set

#
# Misc devices
#
CONFIG_SENSORS_LIS3LV02D=y
CONFIG_AD525X_DPOT=y
# CONFIG_AD525X_DPOT_I2C is not set
CONFIG_PHANTOM=y
CONFIG_INTEL_MID_PTI=y
CONFIG_SGI_IOC4=y
# CONFIG_ENCLOSURE_SERVICES is not set
# CONFIG_HP_ILO is not set
CONFIG_APDS9802ALS=y
CONFIG_ISL29003=y
# CONFIG_ISL29020 is not set
CONFIG_SENSORS_TSL2550=y
# CONFIG_SENSORS_BH1780 is not set
# CONFIG_SENSORS_BH1770 is not set
# CONFIG_SENSORS_APDS990X is not set
# CONFIG_HMC6352 is not set
# CONFIG_VMWARE_BALLOON is not set
CONFIG_BMP085=y
CONFIG_BMP085_I2C=y
# CONFIG_PCH_PHUB is not set
CONFIG_USB_SWITCH_FSA9480=y

#
# EEPROM support
#
# CONFIG_EEPROM_AT24 is not set
CONFIG_EEPROM_LEGACY=y
# CONFIG_EEPROM_93CX6 is not set
# CONFIG_CB710_CORE is not set

#
# Texas Instruments shared transport line discipline
#
CONFIG_TI_ST=y
CONFIG_SENSORS_LIS3_I2C=y

#
# Altera FPGA firmware download module
#
# CONFIG_ALTERA_STAPL is not set
CONFIG_HAVE_IDE=y
# CONFIG_IDE is not set

#
# SCSI device support
#
CONFIG_SCSI_MOD=y
CONFIG_RAID_ATTRS=y
# CONFIG_SCSI is not set
# CONFIG_SCSI_DMA is not set
# CONFIG_SCSI_NETLINK is not set
# CONFIG_ATA is not set
# CONFIG_MD is not set
# CONFIG_FUSION is not set

#
# IEEE 1394 (FireWire) support
#
# CONFIG_FIREWIRE is not set
# CONFIG_FIREWIRE_NOSY is not set
CONFIG_I2O=y
CONFIG_I2O_LCT_NOTIFY_ON_CHANGES=y
CONFIG_I2O_EXT_ADAPTEC=y
# CONFIG_I2O_EXT_ADAPTEC_DMA64 is not set
# CONFIG_I2O_CONFIG is not set
CONFIG_I2O_BUS=y
CONFIG_I2O_BLOCK=y
# CONFIG_I2O_PROC is not set
# CONFIG_MACINTOSH_DRIVERS is not set
# CONFIG_NETDEVICES is not set
# CONFIG_ISDN is not set

#
# Input device support
#
CONFIG_INPUT=y
CONFIG_INPUT_FF_MEMLESS=y
CONFIG_INPUT_POLLDEV=y
CONFIG_INPUT_SPARSEKMAP=y
CONFIG_INPUT_MATRIXKMAP=y

#
# Userland interfaces
#
CONFIG_INPUT_MOUSEDEV=y
CONFIG_INPUT_MOUSEDEV_PSAUX=y
CONFIG_INPUT_MOUSEDEV_SCREEN_X=1024
CONFIG_INPUT_MOUSEDEV_SCREEN_Y=768
CONFIG_INPUT_JOYDEV=y
CONFIG_INPUT_EVDEV=y
# CONFIG_INPUT_EVBUG is not set

#
# Input Device Drivers
#
CONFIG_INPUT_KEYBOARD=y
CONFIG_KEYBOARD_ADP5520=y
CONFIG_KEYBOARD_ADP5588=y
CONFIG_KEYBOARD_ADP5589=y
CONFIG_KEYBOARD_ATKBD=y
# CONFIG_KEYBOARD_QT1070 is not set
CONFIG_KEYBOARD_LKKBD=y
# CONFIG_KEYBOARD_GPIO is not set
CONFIG_KEYBOARD_GPIO_POLLED=y
# CONFIG_KEYBOARD_TCA6416 is not set
# CONFIG_KEYBOARD_TCA8418 is not set
CONFIG_KEYBOARD_MATRIX=y
# CONFIG_KEYBOARD_LM8323 is not set
CONFIG_KEYBOARD_LM8333=y
CONFIG_KEYBOARD_MAX7359=y
CONFIG_KEYBOARD_MCS=y
# CONFIG_KEYBOARD_MPR121 is not set
# CONFIG_KEYBOARD_NEWTON is not set
# CONFIG_KEYBOARD_OPENCORES is not set
# CONFIG_KEYBOARD_STOWAWAY is not set
CONFIG_KEYBOARD_SUNKBD=y
# CONFIG_KEYBOARD_OMAP4 is not set
# CONFIG_KEYBOARD_XTKBD is not set
# CONFIG_INPUT_MOUSE is not set
# CONFIG_INPUT_JOYSTICK is not set
CONFIG_INPUT_TABLET=y
# CONFIG_TABLET_USB_ACECAD is not set
# CONFIG_TABLET_USB_AIPTEK is not set
# CONFIG_TABLET_USB_HANWANG is not set
# CONFIG_TABLET_USB_KBTAB is not set
# CONFIG_TABLET_USB_WACOM is not set
# CONFIG_INPUT_TOUCHSCREEN is not set
CONFIG_INPUT_MISC=y
CONFIG_INPUT_88PM860X_ONKEY=y
CONFIG_INPUT_AD714X=y
# CONFIG_INPUT_AD714X_I2C is not set
# CONFIG_INPUT_BMA150 is not set
# CONFIG_INPUT_PCSPKR is not set
# CONFIG_INPUT_MAX8925_ONKEY is not set
CONFIG_INPUT_MMA8450=y
CONFIG_INPUT_MPU3050=y
CONFIG_INPUT_APANEL=y
CONFIG_INPUT_GP2A=y
CONFIG_INPUT_GPIO_TILT_POLLED=y
# CONFIG_INPUT_ATLAS_BTNS is not set
# CONFIG_INPUT_ATI_REMOTE2 is not set
# CONFIG_INPUT_KXTJ9 is not set
# CONFIG_INPUT_POWERMATE is not set
CONFIG_INPUT_TWL6040_VIBRA=y
# CONFIG_INPUT_UINPUT is not set
CONFIG_INPUT_PCF50633_PMU=y
# CONFIG_INPUT_GPIO_ROTARY_ENCODER is not set
# CONFIG_INPUT_DA9052_ONKEY is not set
CONFIG_INPUT_WM831X_ON=y
# CONFIG_INPUT_ADXL34X is not set
CONFIG_INPUT_CMA3000=y
CONFIG_INPUT_CMA3000_I2C=y
CONFIG_INPUT_XEN_KBDDEV_FRONTEND=y

#
# Hardware I/O ports
#
CONFIG_SERIO=y
CONFIG_SERIO_I8042=y
CONFIG_SERIO_SERPORT=y
CONFIG_SERIO_CT82C710=y
CONFIG_SERIO_PCIPS2=y
CONFIG_SERIO_LIBPS2=y
# CONFIG_SERIO_RAW is not set
# CONFIG_SERIO_ALTERA_PS2 is not set
# CONFIG_SERIO_PS2MULT is not set
CONFIG_GAMEPORT=y
CONFIG_GAMEPORT_NS558=y
CONFIG_GAMEPORT_L4=y
# CONFIG_GAMEPORT_EMU10K1 is not set
# CONFIG_GAMEPORT_FM801 is not set

#
# Character devices
#
CONFIG_VT=y
CONFIG_CONSOLE_TRANSLATIONS=y
CONFIG_VT_CONSOLE=y
CONFIG_VT_CONSOLE_SLEEP=y
CONFIG_HW_CONSOLE=y
CONFIG_VT_HW_CONSOLE_BINDING=y
CONFIG_UNIX98_PTYS=y
CONFIG_DEVPTS_MULTIPLE_INSTANCES=y
# CONFIG_LEGACY_PTYS is not set
CONFIG_SERIAL_NONSTANDARD=y
CONFIG_ROCKETPORT=y
# CONFIG_CYCLADES is not set
# CONFIG_MOXA_INTELLIO is not set
CONFIG_MOXA_SMARTIO=y
CONFIG_SYNCLINK=y
CONFIG_SYNCLINKMP=y
CONFIG_SYNCLINK_GT=y
# CONFIG_ISI is not set
# CONFIG_N_HDLC is not set
# CONFIG_TRACE_SINK is not set
# CONFIG_DEVKMEM is not set
CONFIG_STALDRV=y

#
# Serial drivers
#
CONFIG_SERIAL_8250=y
CONFIG_SERIAL_8250_CONSOLE=y
CONFIG_FIX_EARLYCON_MEM=y
CONFIG_SERIAL_8250_PCI=y
CONFIG_SERIAL_8250_PNP=y
CONFIG_SERIAL_8250_NR_UARTS=4
CONFIG_SERIAL_8250_RUNTIME_UARTS=4
CONFIG_SERIAL_8250_EXTENDED=y
# CONFIG_SERIAL_8250_MANY_PORTS is not set
# CONFIG_SERIAL_8250_SHARE_IRQ is not set
CONFIG_SERIAL_8250_DETECT_IRQ=y
CONFIG_SERIAL_8250_RSA=y

#
# Non-8250 serial port support
#
# CONFIG_SERIAL_MFD_HSU is not set
CONFIG_SERIAL_CORE=y
CONFIG_SERIAL_CORE_CONSOLE=y
CONFIG_SERIAL_JSM=y
# CONFIG_SERIAL_SCCNXP is not set
CONFIG_SERIAL_TIMBERDALE=y
CONFIG_SERIAL_ALTERA_JTAGUART=y
CONFIG_SERIAL_ALTERA_JTAGUART_CONSOLE=y
# CONFIG_SERIAL_ALTERA_JTAGUART_CONSOLE_BYPASS is not set
# CONFIG_SERIAL_ALTERA_UART is not set
CONFIG_SERIAL_PCH_UART=y
CONFIG_SERIAL_PCH_UART_CONSOLE=y
CONFIG_SERIAL_XILINX_PS_UART=y
CONFIG_SERIAL_XILINX_PS_UART_CONSOLE=y
CONFIG_HVC_DRIVER=y
CONFIG_HVC_IRQ=y
CONFIG_HVC_XEN=y
# CONFIG_HVC_XEN_FRONTEND is not set
# CONFIG_IPMI_HANDLER is not set
CONFIG_HW_RANDOM=y
CONFIG_HW_RANDOM_TIMERIOMEM=y
CONFIG_HW_RANDOM_INTEL=y
# CONFIG_HW_RANDOM_AMD is not set
# CONFIG_HW_RANDOM_VIA is not set
# CONFIG_NVRAM is not set
CONFIG_R3964=y
# CONFIG_APPLICOM is not set
CONFIG_MWAVE=y
# CONFIG_RAW_DRIVER is not set
# CONFIG_HPET is not set
CONFIG_HANGCHECK_TIMER=y
# CONFIG_TCG_TPM is not set
CONFIG_DEVPORT=y
CONFIG_I2C=y
CONFIG_I2C_BOARDINFO=y
CONFIG_I2C_COMPAT=y
# CONFIG_I2C_CHARDEV is not set
CONFIG_I2C_MUX=y

#
# Multiplexer I2C Chip support
#
CONFIG_I2C_MUX_GPIO=y
CONFIG_I2C_HELPER_AUTO=y
CONFIG_I2C_ALGOBIT=y
CONFIG_I2C_ALGOPCA=y

#
# I2C Hardware Bus support
#

#
# PC SMBus host controller drivers
#
CONFIG_I2C_ALI1535=y
# CONFIG_I2C_ALI15X3 is not set
# CONFIG_I2C_AMD756 is not set
# CONFIG_I2C_AMD8111 is not set
CONFIG_I2C_I801=y
# CONFIG_I2C_ISCH is not set
# CONFIG_I2C_PIIX4 is not set
# CONFIG_I2C_NFORCE2 is not set
# CONFIG_I2C_SIS5595 is not set
CONFIG_I2C_SIS630=y
CONFIG_I2C_SIS96X=y
CONFIG_I2C_VIAPRO=y

#
# ACPI drivers
#
# CONFIG_I2C_SCMI is not set

#
# I2C system bus drivers (mostly embedded / system-on-chip)
#
# CONFIG_I2C_DESIGNWARE_PCI is not set
# CONFIG_I2C_EG20T is not set
# CONFIG_I2C_GPIO is not set
CONFIG_I2C_INTEL_MID=y
CONFIG_I2C_PCA_PLATFORM=y
# CONFIG_I2C_PXA_PCI is not set
# CONFIG_I2C_SIMTEC is not set

#
# External I2C/SMBus adapter drivers
#
# CONFIG_I2C_PARPORT_LIGHT is not set

#
# Other I2C/SMBus bus drivers
#
# CONFIG_I2C_DEBUG_CORE is not set
# CONFIG_I2C_DEBUG_ALGO is not set
# CONFIG_I2C_DEBUG_BUS is not set
# CONFIG_SPI is not set
# CONFIG_HSI is not set

#
# PPS support
#

#
# PPS generators support
#

#
# PTP clock support
#

#
# Enable Device Drivers -> PPS to see the PTP clock options.
#
CONFIG_ARCH_WANT_OPTIONAL_GPIOLIB=y
CONFIG_GPIOLIB=y
# CONFIG_DEBUG_GPIO is not set
# CONFIG_GPIO_DA9052 is not set

#
# Memory mapped GPIO drivers:
#
# CONFIG_GPIO_GENERIC_PLATFORM is not set
# CONFIG_GPIO_IT8761E is not set
# CONFIG_GPIO_SCH is not set
# CONFIG_GPIO_ICH is not set
# CONFIG_GPIO_VX855 is not set

#
# I2C GPIO expanders:
#
# CONFIG_GPIO_MAX7300 is not set
# CONFIG_GPIO_MAX732X is not set
CONFIG_GPIO_PCA953X=y
CONFIG_GPIO_PCA953X_IRQ=y
CONFIG_GPIO_PCF857X=y
# CONFIG_GPIO_SX150X is not set
# CONFIG_GPIO_WM831X is not set
CONFIG_GPIO_WM8350=y
CONFIG_GPIO_WM8994=y
# CONFIG_GPIO_ADP5520 is not set
CONFIG_GPIO_ADP5588=y
# CONFIG_GPIO_ADP5588_IRQ is not set

#
# PCI GPIO expanders:
#
CONFIG_GPIO_BT8XX=y
# CONFIG_GPIO_AMD8111 is not set
# CONFIG_GPIO_LANGWELL is not set
# CONFIG_GPIO_PCH is not set
CONFIG_GPIO_ML_IOH=y
# CONFIG_GPIO_RDC321X is not set

#
# SPI GPIO expanders:
#
# CONFIG_GPIO_MCP23S08 is not set

#
# AC97 GPIO expanders:
#

#
# MODULbus GPIO expanders:
#
# CONFIG_GPIO_TPS6586X is not set
CONFIG_W1=y

#
# 1-wire Bus Masters
#
# CONFIG_W1_MASTER_MATROX is not set
# CONFIG_W1_MASTER_DS1WM is not set
# CONFIG_W1_MASTER_GPIO is not set
# CONFIG_HDQ_MASTER_OMAP is not set

#
# 1-wire Slaves
#
CONFIG_W1_SLAVE_THERM=y
# CONFIG_W1_SLAVE_SMEM is not set
# CONFIG_W1_SLAVE_DS2408 is not set
CONFIG_W1_SLAVE_DS2423=y
# CONFIG_W1_SLAVE_DS2431 is not set
# CONFIG_W1_SLAVE_DS2433 is not set
CONFIG_W1_SLAVE_DS2760=y
CONFIG_W1_SLAVE_DS2780=y
CONFIG_W1_SLAVE_DS2781=y
CONFIG_W1_SLAVE_DS28E04=y
# CONFIG_W1_SLAVE_BQ27000 is not set
CONFIG_POWER_SUPPLY=y
# CONFIG_POWER_SUPPLY_DEBUG is not set
# CONFIG_PDA_POWER is not set
CONFIG_MAX8925_POWER=y
# CONFIG_WM831X_BACKUP is not set
CONFIG_WM831X_POWER=y
CONFIG_WM8350_POWER=y
CONFIG_TEST_POWER=y
CONFIG_BATTERY_DS2760=y
CONFIG_BATTERY_DS2780=y
# CONFIG_BATTERY_DS2781 is not set
# CONFIG_BATTERY_DS2782 is not set
# CONFIG_BATTERY_SBS is not set
# CONFIG_BATTERY_BQ27x00 is not set
# CONFIG_BATTERY_DA9030 is not set
# CONFIG_BATTERY_DA9052 is not set
CONFIG_BATTERY_MAX17040=y
# CONFIG_BATTERY_MAX17042 is not set
CONFIG_CHARGER_PCF50633=y
# CONFIG_CHARGER_MAX8903 is not set
# CONFIG_CHARGER_LP8727 is not set
CONFIG_CHARGER_GPIO=y
# CONFIG_CHARGER_MANAGER is not set
CONFIG_CHARGER_SMB347=y
CONFIG_POWER_AVS=y
CONFIG_HWMON=y
CONFIG_HWMON_VID=y
CONFIG_HWMON_DEBUG_CHIP=y

#
# Native drivers
#
CONFIG_SENSORS_ADM1021=y
# CONFIG_SENSORS_ADM1025 is not set
CONFIG_SENSORS_ADM1026=y
CONFIG_SENSORS_ADM1029=y
# CONFIG_SENSORS_ADM1031 is not set
# CONFIG_SENSORS_ADM9240 is not set
CONFIG_SENSORS_ADT7475=y
CONFIG_SENSORS_ASC7621=y
# CONFIG_SENSORS_K10TEMP is not set
CONFIG_SENSORS_FAM15H_POWER=y
# CONFIG_SENSORS_DS620 is not set
CONFIG_SENSORS_DS1621=y
CONFIG_SENSORS_DA9052_ADC=y
CONFIG_SENSORS_F71805F=y
CONFIG_SENSORS_F71882FG=y
# CONFIG_SENSORS_F75375S is not set
CONFIG_SENSORS_FSCHMD=y
# CONFIG_SENSORS_G760A is not set
CONFIG_SENSORS_GL518SM=y
CONFIG_SENSORS_GL520SM=y
CONFIG_SENSORS_GPIO_FAN=y
CONFIG_SENSORS_IT87=y
CONFIG_SENSORS_JC42=y
CONFIG_SENSORS_LM63=y
# CONFIG_SENSORS_LM73 is not set
# CONFIG_SENSORS_LM75 is not set
# CONFIG_SENSORS_LM77 is not set
# CONFIG_SENSORS_LM78 is not set
# CONFIG_SENSORS_LM80 is not set
CONFIG_SENSORS_LM83=y
# CONFIG_SENSORS_LM85 is not set
# CONFIG_SENSORS_LM87 is not set
# CONFIG_SENSORS_LM90 is not set
CONFIG_SENSORS_LM92=y
# CONFIG_SENSORS_LM93 is not set
CONFIG_SENSORS_LTC4151=y
# CONFIG_SENSORS_LM95241 is not set
CONFIG_SENSORS_MAX16065=y
CONFIG_SENSORS_MAX1619=y
# CONFIG_SENSORS_MAX197 is not set
# CONFIG_SENSORS_PC87360 is not set
# CONFIG_SENSORS_PC87427 is not set
CONFIG_SENSORS_PCF8591=y
# CONFIG_SENSORS_SHT15 is not set
# CONFIG_SENSORS_SHT21 is not set
# CONFIG_SENSORS_SIS5595 is not set
CONFIG_SENSORS_EMC1403=y
# CONFIG_SENSORS_EMC2103 is not set
# CONFIG_SENSORS_EMC6W201 is not set
# CONFIG_SENSORS_SMSC47M1 is not set
CONFIG_SENSORS_SMSC47M192=y
CONFIG_SENSORS_SCH56XX_COMMON=y
CONFIG_SENSORS_SCH5627=y
# CONFIG_SENSORS_SCH5636 is not set
CONFIG_SENSORS_ADS1015=y
CONFIG_SENSORS_ADS7828=y
CONFIG_SENSORS_THMC50=y
CONFIG_SENSORS_VIA_CPUTEMP=y
CONFIG_SENSORS_VIA686A=y
CONFIG_SENSORS_VT1211=y
# CONFIG_SENSORS_VT8231 is not set
CONFIG_SENSORS_W83781D=y
# CONFIG_SENSORS_W83791D is not set
CONFIG_SENSORS_W83792D=y
# CONFIG_SENSORS_W83627HF is not set
# CONFIG_SENSORS_W83627EHF is not set
CONFIG_SENSORS_WM831X=y
CONFIG_SENSORS_WM8350=y
# CONFIG_SENSORS_APPLESMC is not set

#
# ACPI drivers
#
CONFIG_SENSORS_ACPI_POWER=y
CONFIG_THERMAL=y
CONFIG_THERMAL_HWMON=y
CONFIG_WATCHDOG=y
CONFIG_WATCHDOG_CORE=y
CONFIG_WATCHDOG_NOWAYOUT=y

#
# Watchdog Device Drivers
#
# CONFIG_SOFT_WATCHDOG is not set
# CONFIG_DA9052_WATCHDOG is not set
CONFIG_WM831X_WATCHDOG=y
# CONFIG_WM8350_WATCHDOG is not set
# CONFIG_ACQUIRE_WDT is not set
# CONFIG_ADVANTECH_WDT is not set
# CONFIG_ALIM1535_WDT is not set
# CONFIG_ALIM7101_WDT is not set
CONFIG_SP5100_TCO=y
# CONFIG_SC520_WDT is not set
# CONFIG_SBC_FITPC2_WATCHDOG is not set
# CONFIG_EUROTECH_WDT is not set
# CONFIG_IB700_WDT is not set
# CONFIG_IBMASR is not set
CONFIG_WAFER_WDT=y
CONFIG_I6300ESB_WDT=y
CONFIG_IE6XX_WDT=y
CONFIG_ITCO_WDT=y
# CONFIG_ITCO_VENDOR_SUPPORT is not set
# CONFIG_IT8712F_WDT is not set
CONFIG_HP_WATCHDOG=y
CONFIG_HPWDT_NMI_DECODING=y
CONFIG_SC1200_WDT=y
CONFIG_PC87413_WDT=y
CONFIG_NV_TCO=y
CONFIG_60XX_WDT=y
CONFIG_SBC8360_WDT=y
CONFIG_CPU5_WDT=y
CONFIG_SMSC_SCH311X_WDT=y
CONFIG_SMSC37B787_WDT=y
CONFIG_VIA_WDT=y
CONFIG_W83627HF_WDT=y
CONFIG_W83697HF_WDT=y
# CONFIG_W83697UG_WDT is not set
# CONFIG_W83877F_WDT is not set
CONFIG_W83977F_WDT=y
# CONFIG_MACHZ_WDT is not set
# CONFIG_SBC_EPX_C3_WATCHDOG is not set
CONFIG_XEN_WDT=y

#
# PCI-based Watchdog Cards
#
# CONFIG_PCIPCWATCHDOG is not set
# CONFIG_WDTPCI is not set
CONFIG_SSB_POSSIBLE=y

#
# Sonics Silicon Backplane
#
CONFIG_SSB=y
CONFIG_SSB_PCIHOST_POSSIBLE=y
# CONFIG_SSB_PCIHOST is not set
CONFIG_SSB_SDIOHOST_POSSIBLE=y
CONFIG_SSB_SDIOHOST=y
# CONFIG_SSB_DEBUG is not set
CONFIG_BCMA_POSSIBLE=y

#
# Broadcom specific AMBA
#
# CONFIG_BCMA is not set

#
# Multifunction device drivers
#
CONFIG_MFD_CORE=y
CONFIG_MFD_88PM860X=y
# CONFIG_MFD_88PM800 is not set
# CONFIG_MFD_88PM805 is not set
CONFIG_MFD_SM501=y
# CONFIG_MFD_SM501_GPIO is not set
CONFIG_HTC_PASIC3=y
# CONFIG_HTC_I2CPLD is not set
CONFIG_MFD_LM3533=y
CONFIG_TPS6105X=y
# CONFIG_TPS65010 is not set
CONFIG_TPS6507X=y
# CONFIG_MFD_TPS65217 is not set
CONFIG_MFD_TPS6586X=y
# CONFIG_MFD_TPS65910 is not set
# CONFIG_MFD_TPS65912_I2C is not set
# CONFIG_TWL4030_CORE is not set
CONFIG_TWL6040_CORE=y
# CONFIG_MFD_STMPE is not set
# CONFIG_MFD_TC3589X is not set
# CONFIG_MFD_TMIO is not set
CONFIG_PMIC_DA903X=y
CONFIG_PMIC_DA9052=y
CONFIG_MFD_DA9052_I2C=y
CONFIG_PMIC_ADP5520=y
# CONFIG_MFD_MAX77686 is not set
CONFIG_MFD_MAX77693=y
CONFIG_MFD_MAX8925=y
# CONFIG_MFD_MAX8997 is not set
CONFIG_MFD_MAX8998=y
# CONFIG_MFD_SEC_CORE is not set
# CONFIG_MFD_ARIZONA_I2C is not set
CONFIG_MFD_WM8400=y
CONFIG_MFD_WM831X=y
CONFIG_MFD_WM831X_I2C=y
CONFIG_MFD_WM8350=y
CONFIG_MFD_WM8350_I2C=y
CONFIG_MFD_WM8994=y
CONFIG_MFD_PCF50633=y
# CONFIG_PCF50633_ADC is not set
# CONFIG_PCF50633_GPIO is not set
# CONFIG_MFD_MC13XXX_I2C is not set
# CONFIG_ABX500_CORE is not set
# CONFIG_MFD_CS5535 is not set
# CONFIG_MFD_TIMBERDALE is not set
CONFIG_LPC_SCH=y
CONFIG_LPC_ICH=y
# CONFIG_MFD_RDC321X is not set
# CONFIG_MFD_JANZ_CMODIO is not set
CONFIG_MFD_VX855=y
CONFIG_MFD_WL1273_CORE=y
# CONFIG_MFD_TPS65090 is not set
# CONFIG_MFD_AAT2870_CORE is not set
# CONFIG_MFD_RC5T583 is not set
# CONFIG_MFD_PALMAS is not set
CONFIG_REGULATOR=y
CONFIG_REGULATOR_DEBUG=y
# CONFIG_REGULATOR_DUMMY is not set
CONFIG_REGULATOR_FIXED_VOLTAGE=y
# CONFIG_REGULATOR_VIRTUAL_CONSUMER is not set
CONFIG_REGULATOR_USERSPACE_CONSUMER=y
# CONFIG_REGULATOR_GPIO is not set
# CONFIG_REGULATOR_AD5398 is not set
CONFIG_REGULATOR_DA903X=y
CONFIG_REGULATOR_DA9052=y
# CONFIG_REGULATOR_FAN53555 is not set
# CONFIG_REGULATOR_ISL6271A is not set
# CONFIG_REGULATOR_88PM8607 is not set
# CONFIG_REGULATOR_MAX1586 is not set
# CONFIG_REGULATOR_MAX8649 is not set
# CONFIG_REGULATOR_MAX8660 is not set
CONFIG_REGULATOR_MAX8925=y
# CONFIG_REGULATOR_MAX8952 is not set
# CONFIG_REGULATOR_MAX8998 is not set
# CONFIG_REGULATOR_LP3971 is not set
CONFIG_REGULATOR_LP3972=y
# CONFIG_REGULATOR_LP872X is not set
CONFIG_REGULATOR_PCF50633=y
CONFIG_REGULATOR_TPS6105X=y
CONFIG_REGULATOR_TPS62360=y
# CONFIG_REGULATOR_TPS65023 is not set
CONFIG_REGULATOR_TPS6507X=y
# CONFIG_REGULATOR_TPS6586X is not set
# CONFIG_REGULATOR_WM831X is not set
CONFIG_REGULATOR_WM8350=y
# CONFIG_REGULATOR_WM8400 is not set
CONFIG_REGULATOR_WM8994=y
# CONFIG_MEDIA_SUPPORT is not set

#
# Graphics support
#
CONFIG_AGP=y
CONFIG_AGP_AMD64=y
# CONFIG_AGP_INTEL is not set
CONFIG_AGP_SIS=y
# CONFIG_AGP_VIA is not set
CONFIG_VGA_ARB=y
CONFIG_VGA_ARB_MAX_GPUS=16
CONFIG_VGA_SWITCHEROO=y
CONFIG_DRM=y
CONFIG_DRM_KMS_HELPER=y
# CONFIG_DRM_LOAD_EDID_FIRMWARE is not set
CONFIG_DRM_TTM=y
# CONFIG_DRM_TDFX is not set
CONFIG_DRM_R128=y
CONFIG_DRM_RADEON=y
# CONFIG_DRM_RADEON_KMS is not set
# CONFIG_DRM_NOUVEAU is not set

#
# I2C encoder or helper chips
#
CONFIG_DRM_I2C_CH7006=y
CONFIG_DRM_I2C_SIL164=y
CONFIG_DRM_MGA=y
# CONFIG_DRM_SIS is not set
CONFIG_DRM_VIA=y
# CONFIG_DRM_SAVAGE is not set
CONFIG_DRM_VMWGFX=y
# CONFIG_DRM_VMWGFX_FBCON is not set
CONFIG_STUB_POULSBO=y
CONFIG_VGASTATE=y
CONFIG_VIDEO_OUTPUT_CONTROL=y
CONFIG_FB=y
# CONFIG_FIRMWARE_EDID is not set
CONFIG_FB_DDC=y
CONFIG_FB_BOOT_VESA_SUPPORT=y
CONFIG_FB_CFB_FILLRECT=y
CONFIG_FB_CFB_COPYAREA=y
CONFIG_FB_CFB_IMAGEBLIT=y
# CONFIG_FB_CFB_REV_PIXELS_IN_BYTE is not set
CONFIG_FB_SYS_FILLRECT=y
CONFIG_FB_SYS_COPYAREA=y
CONFIG_FB_SYS_IMAGEBLIT=y
# CONFIG_FB_FOREIGN_ENDIAN is not set
CONFIG_FB_SYS_FOPS=y
# CONFIG_FB_WMT_GE_ROPS is not set
CONFIG_FB_DEFERRED_IO=y
CONFIG_FB_HECUBA=y
CONFIG_FB_SVGALIB=y
# CONFIG_FB_MACMODES is not set
CONFIG_FB_BACKLIGHT=y
CONFIG_FB_MODE_HELPERS=y
CONFIG_FB_TILEBLITTING=y

#
# Frame buffer hardware drivers
#
# CONFIG_FB_CIRRUS is not set
CONFIG_FB_PM2=y
# CONFIG_FB_PM2_FIFO_DISCONNECT is not set
# CONFIG_FB_CYBER2000 is not set
CONFIG_FB_ARC=y
CONFIG_FB_ASILIANT=y
# CONFIG_FB_IMSTT is not set
# CONFIG_FB_VGA16 is not set
# CONFIG_FB_VESA is not set
CONFIG_FB_EFI=y
CONFIG_FB_N411=y
CONFIG_FB_HGA=y
# CONFIG_FB_S1D13XXX is not set
# CONFIG_FB_NVIDIA is not set
CONFIG_FB_RIVA=y
CONFIG_FB_RIVA_I2C=y
CONFIG_FB_RIVA_DEBUG=y
# CONFIG_FB_RIVA_BACKLIGHT is not set
CONFIG_FB_LE80578=y
CONFIG_FB_CARILLO_RANCH=y
CONFIG_FB_MATROX=y
CONFIG_FB_MATROX_MILLENIUM=y
CONFIG_FB_MATROX_MYSTIQUE=y
# CONFIG_FB_MATROX_G is not set
# CONFIG_FB_MATROX_I2C is not set
CONFIG_FB_RADEON=y
# CONFIG_FB_RADEON_I2C is not set
CONFIG_FB_RADEON_BACKLIGHT=y
CONFIG_FB_RADEON_DEBUG=y
CONFIG_FB_ATY128=y
# CONFIG_FB_ATY128_BACKLIGHT is not set
# CONFIG_FB_ATY is not set
# CONFIG_FB_S3 is not set
CONFIG_FB_SIS=y
CONFIG_FB_SIS_300=y
# CONFIG_FB_SIS_315 is not set
# CONFIG_FB_VIA is not set
CONFIG_FB_NEOMAGIC=y
CONFIG_FB_KYRO=y
# CONFIG_FB_3DFX is not set
# CONFIG_FB_VOODOO1 is not set
CONFIG_FB_VT8623=y
# CONFIG_FB_TRIDENT is not set
# CONFIG_FB_ARK is not set
CONFIG_FB_CARMINE=y
CONFIG_FB_CARMINE_DRAM_EVAL=y
# CONFIG_CARMINE_DRAM_CUSTOM is not set
CONFIG_FB_TMIO=y
# CONFIG_FB_TMIO_ACCELL is not set
CONFIG_FB_SM501=y
# CONFIG_FB_VIRTUAL is not set
CONFIG_XEN_FBDEV_FRONTEND=y
CONFIG_FB_METRONOME=y
# CONFIG_FB_MB862XX is not set
# CONFIG_FB_BROADSHEET is not set
CONFIG_FB_AUO_K190X=y
CONFIG_FB_AUO_K1900=y
CONFIG_FB_AUO_K1901=y
CONFIG_EXYNOS_VIDEO=y
CONFIG_BACKLIGHT_LCD_SUPPORT=y
CONFIG_LCD_CLASS_DEVICE=y
# CONFIG_LCD_PLATFORM is not set
CONFIG_BACKLIGHT_CLASS_DEVICE=y
# CONFIG_BACKLIGHT_GENERIC is not set
CONFIG_BACKLIGHT_LM3533=y
# CONFIG_BACKLIGHT_PROGEAR is not set
# CONFIG_BACKLIGHT_CARILLO_RANCH is not set
CONFIG_BACKLIGHT_DA903X=y
# CONFIG_BACKLIGHT_DA9052 is not set
CONFIG_BACKLIGHT_MAX8925=y
# CONFIG_BACKLIGHT_APPLE is not set
# CONFIG_BACKLIGHT_SAHARA is not set
CONFIG_BACKLIGHT_WM831X=y
# CONFIG_BACKLIGHT_ADP5520 is not set
CONFIG_BACKLIGHT_ADP8860=y
CONFIG_BACKLIGHT_ADP8870=y
CONFIG_BACKLIGHT_88PM860X=y
# CONFIG_BACKLIGHT_PCF50633 is not set
CONFIG_BACKLIGHT_LP855X=y

#
# Console display driver support
#
CONFIG_VGA_CONSOLE=y
# CONFIG_VGACON_SOFT_SCROLLBACK is not set
CONFIG_DUMMY_CONSOLE=y
CONFIG_FRAMEBUFFER_CONSOLE=y
CONFIG_FRAMEBUFFER_CONSOLE_DETECT_PRIMARY=y
CONFIG_FRAMEBUFFER_CONSOLE_ROTATION=y
CONFIG_FONTS=y
# CONFIG_FONT_8x8 is not set
CONFIG_FONT_8x16=y
# CONFIG_FONT_6x11 is not set
CONFIG_FONT_7x14=y
# CONFIG_FONT_PEARL_8x8 is not set
CONFIG_FONT_ACORN_8x8=y
CONFIG_FONT_MINI_4x6=y
CONFIG_FONT_SUN8x16=y
# CONFIG_FONT_SUN12x22 is not set
CONFIG_FONT_10x18=y
# CONFIG_LOGO is not set
# CONFIG_SOUND is not set

#
# HID support
#
# CONFIG_HID is not set
CONFIG_USB_ARCH_HAS_OHCI=y
CONFIG_USB_ARCH_HAS_EHCI=y
CONFIG_USB_ARCH_HAS_XHCI=y
CONFIG_USB_SUPPORT=y
CONFIG_USB_ARCH_HAS_HCD=y
# CONFIG_USB is not set

#
# NOTE: USB_STORAGE depends on SCSI but BLK_DEV_SD may
#
# CONFIG_OMAP_USB2 is not set
# CONFIG_USB_GADGET is not set

#
# OTG and related infrastructure
#
CONFIG_MMC=y
CONFIG_MMC_DEBUG=y
# CONFIG_MMC_UNSAFE_RESUME is not set

#
# MMC/SD/SDIO Card Drivers
#
CONFIG_MMC_BLOCK=y
CONFIG_MMC_BLOCK_MINORS=8
# CONFIG_MMC_BLOCK_BOUNCE is not set
CONFIG_SDIO_UART=y
CONFIG_MMC_TEST=y

#
# MMC/SD/SDIO Host Controller Drivers
#
# CONFIG_MMC_SDHCI is not set
# CONFIG_MMC_WBSD is not set
# CONFIG_MMC_CB710 is not set
# CONFIG_MMC_VIA_SDMMC is not set
# CONFIG_MEMSTICK is not set
CONFIG_NEW_LEDS=y
CONFIG_LEDS_CLASS=y

#
# LED drivers
#
# CONFIG_LEDS_88PM860X is not set
CONFIG_LEDS_LM3530=y
CONFIG_LEDS_LM3533=y
CONFIG_LEDS_GPIO=y
# CONFIG_LEDS_LP3944 is not set
# CONFIG_LEDS_LP5521 is not set
CONFIG_LEDS_LP5523=y
# CONFIG_LEDS_CLEVO_MAIL is not set
# CONFIG_LEDS_PCA955X is not set
# CONFIG_LEDS_PCA9633 is not set
# CONFIG_LEDS_WM831X_STATUS is not set
# CONFIG_LEDS_WM8350 is not set
CONFIG_LEDS_DA903X=y
CONFIG_LEDS_DA9052=y
CONFIG_LEDS_REGULATOR=y
CONFIG_LEDS_BD2802=y
CONFIG_LEDS_INTEL_SS4200=y
CONFIG_LEDS_LT3593=y
CONFIG_LEDS_ADP5520=y
CONFIG_LEDS_DELL_NETBOOKS=y
# CONFIG_LEDS_TCA6507 is not set
# CONFIG_LEDS_LM355x is not set
# CONFIG_LEDS_OT200 is not set
CONFIG_LEDS_BLINKM=y
# CONFIG_LEDS_TRIGGERS is not set

#
# LED Triggers
#
# CONFIG_ACCESSIBILITY is not set
CONFIG_INFINIBAND=y
# CONFIG_INFINIBAND_USER_MAD is not set
# CONFIG_INFINIBAND_USER_ACCESS is not set
CONFIG_INFINIBAND_ADDR_TRANS=y
# CONFIG_INFINIBAND_MTHCA is not set
CONFIG_INFINIBAND_QIB=y
# CONFIG_INFINIBAND_AMSO1100 is not set
# CONFIG_INFINIBAND_NES is not set
# CONFIG_EDAC is not set
CONFIG_RTC_LIB=y
CONFIG_RTC_CLASS=y
CONFIG_RTC_HCTOSYS=y
CONFIG_RTC_HCTOSYS_DEVICE="rtc0"
# CONFIG_RTC_DEBUG is not set

#
# RTC interfaces
#
CONFIG_RTC_INTF_SYSFS=y
# CONFIG_RTC_INTF_PROC is not set
CONFIG_RTC_INTF_DEV=y
CONFIG_RTC_INTF_DEV_UIE_EMUL=y
# CONFIG_RTC_DRV_TEST is not set

#
# I2C RTC drivers
#
# CONFIG_RTC_DRV_88PM860X is not set
CONFIG_RTC_DRV_DS1307=y
# CONFIG_RTC_DRV_DS1374 is not set
# CONFIG_RTC_DRV_DS1672 is not set
# CONFIG_RTC_DRV_DS3232 is not set
CONFIG_RTC_DRV_MAX6900=y
# CONFIG_RTC_DRV_MAX8925 is not set
CONFIG_RTC_DRV_MAX8998=y
# CONFIG_RTC_DRV_RS5C372 is not set
# CONFIG_RTC_DRV_ISL1208 is not set
CONFIG_RTC_DRV_ISL12022=y
# CONFIG_RTC_DRV_X1205 is not set
# CONFIG_RTC_DRV_PCF8563 is not set
# CONFIG_RTC_DRV_PCF8583 is not set
# CONFIG_RTC_DRV_M41T80 is not set
# CONFIG_RTC_DRV_BQ32K is not set
# CONFIG_RTC_DRV_S35390A is not set
# CONFIG_RTC_DRV_FM3130 is not set
CONFIG_RTC_DRV_RX8581=y
# CONFIG_RTC_DRV_RX8025 is not set
# CONFIG_RTC_DRV_EM3027 is not set
CONFIG_RTC_DRV_RV3029C2=y

#
# SPI RTC drivers
#

#
# Platform RTC drivers
#
# CONFIG_RTC_DRV_CMOS is not set
CONFIG_RTC_DRV_DS1286=y
# CONFIG_RTC_DRV_DS1511 is not set
CONFIG_RTC_DRV_DS1553=y
# CONFIG_RTC_DRV_DS1742 is not set
CONFIG_RTC_DRV_DA9052=y
CONFIG_RTC_DRV_STK17TA8=y
CONFIG_RTC_DRV_M48T86=y
CONFIG_RTC_DRV_M48T35=y
# CONFIG_RTC_DRV_M48T59 is not set
# CONFIG_RTC_DRV_MSM6242 is not set
# CONFIG_RTC_DRV_BQ4802 is not set
# CONFIG_RTC_DRV_RP5C01 is not set
# CONFIG_RTC_DRV_V3020 is not set
# CONFIG_RTC_DRV_WM831X is not set
CONFIG_RTC_DRV_WM8350=y
# CONFIG_RTC_DRV_PCF50633 is not set

#
# on-CPU RTC drivers
#
CONFIG_DMADEVICES=y
# CONFIG_DMADEVICES_DEBUG is not set

#
# DMA Devices
#
CONFIG_INTEL_MID_DMAC=y
# CONFIG_INTEL_IOATDMA is not set
# CONFIG_TIMB_DMA is not set
CONFIG_PCH_DMA=y
CONFIG_DMA_ENGINE=y

#
# DMA Clients
#
CONFIG_NET_DMA=y
# CONFIG_ASYNC_TX_DMA is not set
CONFIG_DMATEST=y
CONFIG_AUXDISPLAY=y
# CONFIG_UIO is not set

#
# Virtio drivers
#

#
# Microsoft Hyper-V guest support
#
# CONFIG_HYPERV is not set

#
# Xen driver support
#
CONFIG_XEN_BALLOON=y
# CONFIG_XEN_SELFBALLOONING is not set
# CONFIG_XEN_BALLOON_MEMORY_HOTPLUG is not set
CONFIG_XEN_SCRUB_PAGES=y
# CONFIG_XEN_DEV_EVTCHN is not set
CONFIG_XEN_BACKEND=y
# CONFIG_XENFS is not set
# CONFIG_XEN_SYS_HYPERVISOR is not set
CONFIG_XEN_XENBUS_FRONTEND=y
CONFIG_XEN_GNTDEV=y
# CONFIG_XEN_GRANT_DEV_ALLOC is not set
CONFIG_SWIOTLB_XEN=y
CONFIG_XEN_TMEM=y
# CONFIG_XEN_PCIDEV_BACKEND is not set
CONFIG_XEN_PRIVCMD=y
CONFIG_XEN_MCE_LOG=y
# CONFIG_STAGING is not set
CONFIG_X86_PLATFORM_DEVICES=y
CONFIG_ACER_WMI=y
CONFIG_ACERHDF=y
CONFIG_ASUS_LAPTOP=y
# CONFIG_DELL_WMI is not set
CONFIG_DELL_WMI_AIO=y
CONFIG_FUJITSU_LAPTOP=y
CONFIG_FUJITSU_LAPTOP_DEBUG=y
# CONFIG_FUJITSU_TABLET is not set
# CONFIG_HP_ACCEL is not set
# CONFIG_HP_WMI is not set
# CONFIG_PANASONIC_LAPTOP is not set
# CONFIG_THINKPAD_ACPI is not set
# CONFIG_SENSORS_HDAPS is not set
CONFIG_EEEPC_LAPTOP=y
CONFIG_ASUS_WMI=y
CONFIG_ASUS_NB_WMI=y
CONFIG_EEEPC_WMI=y
CONFIG_ACPI_WMI=y
# CONFIG_MSI_WMI is not set
CONFIG_TOPSTAR_LAPTOP=y
CONFIG_ACPI_TOSHIBA=y
CONFIG_TOSHIBA_BT_RFKILL=y
CONFIG_ACPI_CMPC=y
# CONFIG_INTEL_IPS is not set
# CONFIG_IBM_RTL is not set
CONFIG_XO15_EBOOK=y
# CONFIG_SAMSUNG_LAPTOP is not set
CONFIG_MXM_WMI=y
CONFIG_SAMSUNG_Q10=y
# CONFIG_APPLE_GMUX is not set

#
# Hardware Spinlock drivers
#
CONFIG_CLKEVT_I8253=y
CONFIG_I8253_LOCK=y
CONFIG_CLKBLD_I8253=y
# CONFIG_IOMMU_SUPPORT is not set

#
# Remoteproc drivers (EXPERIMENTAL)
#

#
# Rpmsg drivers (EXPERIMENTAL)
#
# CONFIG_VIRT_DRIVERS is not set
# CONFIG_PM_DEVFREQ is not set
# CONFIG_EXTCON is not set
CONFIG_MEMORY=y
CONFIG_IIO=y
CONFIG_IIO_BUFFER=y
# CONFIG_IIO_KFIFO_BUF is not set
CONFIG_IIO_TRIGGER=y
CONFIG_IIO_CONSUMERS_PER_TRIGGER=2

#
# Accelerometers
#

#
# Analog to digital converters
#

#
# Amplifiers
#

#
# Light sensors
#
# CONFIG_ADJD_S311 is not set
CONFIG_SENSORS_LM3533=y
# CONFIG_VCNL4000 is not set

#
# Frequency Synthesizers DDS/PLL
#

#
# Clock Generator/Distribution
#

#
# Phase-Locked Loop (PLL) frequency synthesizers
#

#
# Digital to analog converters
#
CONFIG_AD5064=y
# CONFIG_AD5380 is not set
# CONFIG_AD5446 is not set
# CONFIG_MCP4725 is not set

#
# Hid Sensor IIO Common
#

#
# Digital gyroscope sensors
#

#
# Light sensors
#

#
# Magnetometer sensors
#
# CONFIG_VME_BUS is not set
# CONFIG_PWM is not set

#
# Firmware Drivers
#
CONFIG_EDD=y
# CONFIG_EDD_OFF is not set
CONFIG_FIRMWARE_MEMMAP=y
# CONFIG_EFI_VARS is not set
# CONFIG_DELL_RBU is not set
# CONFIG_DCDBAS is not set
# CONFIG_DMIID is not set
CONFIG_DMI_SYSFS=y
# CONFIG_ISCSI_IBFT_FIND is not set
# CONFIG_GOOGLE_FIRMWARE is not set

#
# File systems
#
CONFIG_DCACHE_WORD_ACCESS=y
CONFIG_EXT2_FS=y
CONFIG_EXT2_FS_XATTR=y
# CONFIG_EXT2_FS_POSIX_ACL is not set
# CONFIG_EXT2_FS_SECURITY is not set
# CONFIG_EXT2_FS_XIP is not set
CONFIG_EXT3_FS=y
CONFIG_EXT3_DEFAULTS_TO_ORDERED=y
# CONFIG_EXT3_FS_XATTR is not set
# CONFIG_EXT4_FS is not set
CONFIG_JBD=y
CONFIG_JBD_DEBUG=y
CONFIG_FS_MBCACHE=y
CONFIG_REISERFS_FS=y
# CONFIG_REISERFS_CHECK is not set
# CONFIG_REISERFS_PROC_INFO is not set
CONFIG_REISERFS_FS_XATTR=y
# CONFIG_REISERFS_FS_POSIX_ACL is not set
# CONFIG_REISERFS_FS_SECURITY is not set
CONFIG_JFS_FS=y
# CONFIG_JFS_POSIX_ACL is not set
# CONFIG_JFS_SECURITY is not set
# CONFIG_JFS_DEBUG is not set
CONFIG_JFS_STATISTICS=y
CONFIG_XFS_FS=y
# CONFIG_XFS_QUOTA is not set
CONFIG_XFS_POSIX_ACL=y
CONFIG_XFS_RT=y
CONFIG_GFS2_FS=y
CONFIG_FS_POSIX_ACL=y
CONFIG_EXPORTFS=y
CONFIG_FILE_LOCKING=y
CONFIG_FSNOTIFY=y
CONFIG_DNOTIFY=y
# CONFIG_INOTIFY_USER is not set
# CONFIG_FANOTIFY is not set
CONFIG_QUOTA=y
CONFIG_QUOTA_NETLINK_INTERFACE=y
# CONFIG_PRINT_QUOTA_WARNING is not set
CONFIG_QUOTA_DEBUG=y
CONFIG_QFMT_V1=y
# CONFIG_QFMT_V2 is not set
CONFIG_QUOTACTL=y
CONFIG_QUOTACTL_COMPAT=y
# CONFIG_AUTOFS4_FS is not set
CONFIG_FUSE_FS=y
CONFIG_CUSE=y
CONFIG_GENERIC_ACL=y

#
# Caches
#
CONFIG_FSCACHE=y
CONFIG_FSCACHE_STATS=y
CONFIG_FSCACHE_HISTOGRAM=y
# CONFIG_FSCACHE_DEBUG is not set
# CONFIG_FSCACHE_OBJECT_LIST is not set
# CONFIG_CACHEFILES is not set

#
# CD-ROM/DVD Filesystems
#
# CONFIG_ISO9660_FS is not set
# CONFIG_UDF_FS is not set

#
# DOS/FAT/NT Filesystems
#
CONFIG_FAT_FS=y
CONFIG_MSDOS_FS=y
CONFIG_VFAT_FS=y
CONFIG_FAT_DEFAULT_CODEPAGE=437
CONFIG_FAT_DEFAULT_IOCHARSET="iso8859-1"
CONFIG_NTFS_FS=y
# CONFIG_NTFS_DEBUG is not set
CONFIG_NTFS_RW=y

#
# Pseudo filesystems
#
CONFIG_PROC_FS=y
# CONFIG_PROC_KCORE is not set
# CONFIG_PROC_VMCORE is not set
CONFIG_PROC_SYSCTL=y
CONFIG_PROC_PAGE_MONITOR=y
CONFIG_SYSFS=y
CONFIG_TMPFS=y
CONFIG_TMPFS_POSIX_ACL=y
CONFIG_TMPFS_XATTR=y
CONFIG_HUGETLBFS=y
CONFIG_HUGETLB_PAGE=y
# CONFIG_CONFIGFS_FS is not set
# CONFIG_MISC_FILESYSTEMS is not set
CONFIG_NETWORK_FILESYSTEMS=y
CONFIG_NFS_FS=y
# CONFIG_NFS_V2 is not set
# CONFIG_NFS_V3 is not set
# CONFIG_NFS_V4 is not set
# CONFIG_NFS_SWAP is not set
# CONFIG_ROOT_NFS is not set
# CONFIG_NFS_FSCACHE is not set
CONFIG_NFS_DEBUG=y
# CONFIG_NFSD is not set
CONFIG_LOCKD=y
CONFIG_NFS_COMMON=y
CONFIG_SUNRPC=y
CONFIG_SUNRPC_DEBUG=y
CONFIG_CIFS=y
CONFIG_CIFS_STATS=y
CONFIG_CIFS_STATS2=y
# CONFIG_CIFS_WEAK_PW_HASH is not set
# CONFIG_CIFS_XATTR is not set
# CONFIG_CIFS_DEBUG2 is not set
# CONFIG_CIFS_FSCACHE is not set
CONFIG_NCP_FS=y
CONFIG_NCPFS_PACKET_SIGNING=y
# CONFIG_NCPFS_IOCTL_LOCKING is not set
# CONFIG_NCPFS_STRONG is not set
CONFIG_NCPFS_NFS_NS=y
CONFIG_NCPFS_OS2_NS=y
# CONFIG_NCPFS_SMALLDOS is not set
# CONFIG_NCPFS_NLS is not set
# CONFIG_NCPFS_EXTRAS is not set
CONFIG_CODA_FS=y
CONFIG_9P_FS=y
# CONFIG_9P_FS_POSIX_ACL is not set
CONFIG_NLS=y
CONFIG_NLS_DEFAULT="iso8859-1"
CONFIG_NLS_CODEPAGE_437=y
CONFIG_NLS_CODEPAGE_737=y
CONFIG_NLS_CODEPAGE_775=y
CONFIG_NLS_CODEPAGE_850=y
# CONFIG_NLS_CODEPAGE_852 is not set
CONFIG_NLS_CODEPAGE_855=y
CONFIG_NLS_CODEPAGE_857=y
# CONFIG_NLS_CODEPAGE_860 is not set
CONFIG_NLS_CODEPAGE_861=y
# CONFIG_NLS_CODEPAGE_862 is not set
# CONFIG_NLS_CODEPAGE_863 is not set
# CONFIG_NLS_CODEPAGE_864 is not set
CONFIG_NLS_CODEPAGE_865=y
CONFIG_NLS_CODEPAGE_866=y
# CONFIG_NLS_CODEPAGE_869 is not set
CONFIG_NLS_CODEPAGE_936=y
CONFIG_NLS_CODEPAGE_950=y
# CONFIG_NLS_CODEPAGE_932 is not set
CONFIG_NLS_CODEPAGE_949=y
CONFIG_NLS_CODEPAGE_874=y
CONFIG_NLS_ISO8859_8=y
CONFIG_NLS_CODEPAGE_1250=y
CONFIG_NLS_CODEPAGE_1251=y
# CONFIG_NLS_ASCII is not set
# CONFIG_NLS_ISO8859_1 is not set
# CONFIG_NLS_ISO8859_2 is not set
CONFIG_NLS_ISO8859_3=y
# CONFIG_NLS_ISO8859_4 is not set
CONFIG_NLS_ISO8859_5=y
# CONFIG_NLS_ISO8859_6 is not set
# CONFIG_NLS_ISO8859_7 is not set
# CONFIG_NLS_ISO8859_9 is not set
# CONFIG_NLS_ISO8859_13 is not set
CONFIG_NLS_ISO8859_14=y
# CONFIG_NLS_ISO8859_15 is not set
# CONFIG_NLS_KOI8_R is not set
CONFIG_NLS_KOI8_U=y
CONFIG_NLS_MAC_ROMAN=y
# CONFIG_NLS_MAC_CELTIC is not set
CONFIG_NLS_MAC_CENTEURO=y
CONFIG_NLS_MAC_CROATIAN=y
CONFIG_NLS_MAC_CYRILLIC=y
# CONFIG_NLS_MAC_GAELIC is not set
CONFIG_NLS_MAC_GREEK=y
CONFIG_NLS_MAC_ICELAND=y
CONFIG_NLS_MAC_INUIT=y
CONFIG_NLS_MAC_ROMANIAN=y
CONFIG_NLS_MAC_TURKISH=y
# CONFIG_NLS_UTF8 is not set

#
# Kernel hacking
#
CONFIG_TRACE_IRQFLAGS_SUPPORT=y
CONFIG_PRINTK_TIME=y
CONFIG_DEFAULT_MESSAGE_LOGLEVEL=4
# CONFIG_ENABLE_WARN_DEPRECATED is not set
# CONFIG_ENABLE_MUST_CHECK is not set
CONFIG_FRAME_WARN=2048
CONFIG_MAGIC_SYSRQ=y
# CONFIG_STRIP_ASM_SYMS is not set
# CONFIG_READABLE_ASM is not set
CONFIG_UNUSED_SYMBOLS=y
CONFIG_DEBUG_FS=y
CONFIG_HEADERS_CHECK=y
CONFIG_DEBUG_SECTION_MISMATCH=y
CONFIG_DEBUG_KERNEL=y
# CONFIG_DEBUG_SHIRQ is not set
# CONFIG_LOCKUP_DETECTOR is not set
# CONFIG_HARDLOCKUP_DETECTOR is not set
# CONFIG_PANIC_ON_OOPS is not set
CONFIG_PANIC_ON_OOPS_VALUE=0
# CONFIG_DETECT_HUNG_TASK is not set
CONFIG_SCHED_DEBUG=y
# CONFIG_SCHEDSTATS is not set
# CONFIG_TIMER_STATS is not set
# CONFIG_DEBUG_OBJECTS is not set
# CONFIG_SLUB_DEBUG_ON is not set
# CONFIG_SLUB_STATS is not set
CONFIG_DEBUG_PREEMPT=y
# CONFIG_DEBUG_RT_MUTEXES is not set
# CONFIG_RT_MUTEX_TESTER is not set
# CONFIG_DEBUG_SPINLOCK is not set
# CONFIG_DEBUG_MUTEXES is not set
# CONFIG_DEBUG_LOCK_ALLOC is not set
# CONFIG_PROVE_LOCKING is not set
# CONFIG_PROVE_RCU_DELAY is not set
# CONFIG_SPARSE_RCU_POINTER is not set
# CONFIG_LOCK_STAT is not set
CONFIG_DEBUG_ATOMIC_SLEEP=y
# CONFIG_DEBUG_LOCKING_API_SELFTESTS is not set
CONFIG_STACKTRACE=y
# CONFIG_DEBUG_STACK_USAGE is not set
# CONFIG_DEBUG_KOBJECT is not set
CONFIG_DEBUG_BUGVERBOSE=y
# CONFIG_DEBUG_INFO is not set
# CONFIG_DEBUG_VM is not set
# CONFIG_DEBUG_VIRTUAL is not set
# CONFIG_DEBUG_WRITECOUNT is not set
CONFIG_DEBUG_MEMORY_INIT=y
# CONFIG_DEBUG_LIST is not set
# CONFIG_TEST_LIST_SORT is not set
# CONFIG_DEBUG_SG is not set
# CONFIG_DEBUG_NOTIFIERS is not set
# CONFIG_DEBUG_CREDENTIALS is not set
CONFIG_ARCH_WANT_FRAME_POINTERS=y
CONFIG_FRAME_POINTER=y
# CONFIG_BOOT_PRINTK_DELAY is not set
# CONFIG_RCU_TORTURE_TEST is not set
CONFIG_RCU_CPU_STALL_TIMEOUT=60
# CONFIG_RCU_CPU_STALL_VERBOSE is not set
# CONFIG_RCU_CPU_STALL_INFO is not set
# CONFIG_RCU_TRACE is not set
# CONFIG_BACKTRACE_SELF_TEST is not set
# CONFIG_DEBUG_BLOCK_EXT_DEVT is not set
# CONFIG_DEBUG_FORCE_WEAK_PER_CPU is not set
# CONFIG_DEBUG_PER_CPU_MAPS is not set
# CONFIG_LKDTM is not set
# CONFIG_NOTIFIER_ERROR_INJECTION is not set
# CONFIG_FAULT_INJECTION is not set
# CONFIG_LATENCYTOP is not set
# CONFIG_DEBUG_PAGEALLOC is not set
CONFIG_USER_STACKTRACE_SUPPORT=y
CONFIG_NOP_TRACER=y
CONFIG_HAVE_FUNCTION_TRACER=y
CONFIG_HAVE_FUNCTION_GRAPH_TRACER=y
CONFIG_HAVE_FUNCTION_GRAPH_FP_TEST=y
CONFIG_HAVE_FUNCTION_TRACE_MCOUNT_TEST=y
CONFIG_HAVE_DYNAMIC_FTRACE=y
CONFIG_HAVE_FTRACE_MCOUNT_RECORD=y
CONFIG_HAVE_SYSCALL_TRACEPOINTS=y
CONFIG_HAVE_FENTRY=y
CONFIG_HAVE_C_RECORDMCOUNT=y
CONFIG_TRACER_MAX_TRACE=y
CONFIG_RING_BUFFER=y
CONFIG_EVENT_TRACING=y
CONFIG_EVENT_POWER_TRACING_DEPRECATED=y
CONFIG_CONTEXT_SWITCH_TRACER=y
CONFIG_RING_BUFFER_ALLOW_SWAP=y
CONFIG_TRACING=y
CONFIG_GENERIC_TRACER=y
CONFIG_TRACING_SUPPORT=y
CONFIG_FTRACE=y
# CONFIG_FUNCTION_TRACER is not set
# CONFIG_IRQSOFF_TRACER is not set
CONFIG_PREEMPT_TRACER=y
# CONFIG_SCHED_TRACER is not set
CONFIG_FTRACE_SYSCALLS=y
CONFIG_TRACE_BRANCH_PROFILING=y
# CONFIG_BRANCH_PROFILE_NONE is not set
CONFIG_PROFILE_ANNOTATED_BRANCHES=y
# CONFIG_PROFILE_ALL_BRANCHES is not set
# CONFIG_BRANCH_TRACER is not set
# CONFIG_STACK_TRACER is not set
# CONFIG_BLK_DEV_IO_TRACE is not set
CONFIG_UPROBE_EVENT=y
CONFIG_PROBE_EVENTS=y
CONFIG_FTRACE_SELFTEST=y
CONFIG_FTRACE_STARTUP_TEST=y
CONFIG_EVENT_TRACE_TEST_SYSCALLS=y
# CONFIG_MMIOTRACE is not set
CONFIG_RING_BUFFER_BENCHMARK=y
CONFIG_PROVIDE_OHCI1394_DMA_INIT=y
# CONFIG_BUILD_DOCSRC is not set
CONFIG_DYNAMIC_DEBUG=y
# CONFIG_DMA_API_DEBUG is not set
# CONFIG_ATOMIC64_SELFTEST is not set
# CONFIG_SAMPLES is not set
CONFIG_HAVE_ARCH_KGDB=y
CONFIG_HAVE_ARCH_KMEMCHECK=y
# CONFIG_KMEMCHECK is not set
CONFIG_TEST_KSTRTOX=y
CONFIG_STRICT_DEVMEM=y
CONFIG_X86_VERBOSE_BOOTUP=y
CONFIG_EARLY_PRINTK=y
CONFIG_EARLY_PRINTK_DBGP=y
# CONFIG_DEBUG_STACKOVERFLOW is not set
# CONFIG_X86_PTDUMP is not set
CONFIG_DEBUG_RODATA=y
CONFIG_DEBUG_RODATA_TEST=y
# CONFIG_DEBUG_TLBFLUSH is not set
# CONFIG_IOMMU_DEBUG is not set
# CONFIG_IOMMU_STRESS is not set
CONFIG_HAVE_MMIOTRACE_SUPPORT=y
CONFIG_IO_DELAY_TYPE_0X80=0
CONFIG_IO_DELAY_TYPE_0XED=1
CONFIG_IO_DELAY_TYPE_UDELAY=2
CONFIG_IO_DELAY_TYPE_NONE=3
# CONFIG_IO_DELAY_0X80 is not set
CONFIG_IO_DELAY_0XED=y
# CONFIG_IO_DELAY_UDELAY is not set
# CONFIG_IO_DELAY_NONE is not set
CONFIG_DEFAULT_IO_DELAY_TYPE=1
# CONFIG_DEBUG_BOOT_PARAMS is not set
# CONFIG_CPA_DEBUG is not set
CONFIG_OPTIMIZE_INLINING=y
# CONFIG_DEBUG_NMI_SELFTEST is not set

#
# Security options
#
# CONFIG_KEYS is not set
# CONFIG_SECURITY_DMESG_RESTRICT is not set
# CONFIG_SECURITY is not set
CONFIG_SECURITYFS=y
CONFIG_DEFAULT_SECURITY_DAC=y
CONFIG_DEFAULT_SECURITY=""
CONFIG_CRYPTO=y

#
# Crypto core or helper
#
# CONFIG_CRYPTO_FIPS is not set
CONFIG_CRYPTO_ALGAPI=y
CONFIG_CRYPTO_ALGAPI2=y
CONFIG_CRYPTO_AEAD=y
CONFIG_CRYPTO_AEAD2=y
CONFIG_CRYPTO_BLKCIPHER=y
CONFIG_CRYPTO_BLKCIPHER2=y
CONFIG_CRYPTO_HASH=y
CONFIG_CRYPTO_HASH2=y
CONFIG_CRYPTO_RNG=y
CONFIG_CRYPTO_RNG2=y
CONFIG_CRYPTO_PCOMP2=y
CONFIG_CRYPTO_MANAGER=y
CONFIG_CRYPTO_MANAGER2=y
CONFIG_CRYPTO_USER=y
# CONFIG_CRYPTO_MANAGER_DISABLE_TESTS is not set
CONFIG_CRYPTO_GF128MUL=y
CONFIG_CRYPTO_NULL=y
CONFIG_CRYPTO_WORKQUEUE=y
CONFIG_CRYPTO_CRYPTD=y
CONFIG_CRYPTO_AUTHENC=y
CONFIG_CRYPTO_ABLK_HELPER_X86=y
CONFIG_CRYPTO_GLUE_HELPER_X86=y

#
# Authenticated Encryption with Associated Data
#
CONFIG_CRYPTO_CCM=y
CONFIG_CRYPTO_GCM=y
CONFIG_CRYPTO_SEQIV=y

#
# Block modes
#
CONFIG_CRYPTO_CBC=y
CONFIG_CRYPTO_CTR=y
# CONFIG_CRYPTO_CTS is not set
CONFIG_CRYPTO_ECB=y
CONFIG_CRYPTO_LRW=y
# CONFIG_CRYPTO_PCBC is not set
CONFIG_CRYPTO_XTS=y

#
# Hash modes
#
CONFIG_CRYPTO_HMAC=y

#
# Digest
#
CONFIG_CRYPTO_CRC32C=y
# CONFIG_CRYPTO_CRC32C_INTEL is not set
CONFIG_CRYPTO_GHASH=y
CONFIG_CRYPTO_MD4=y
CONFIG_CRYPTO_MD5=y
# CONFIG_CRYPTO_MICHAEL_MIC is not set
CONFIG_CRYPTO_RMD128=y
CONFIG_CRYPTO_RMD160=y
CONFIG_CRYPTO_RMD256=y
# CONFIG_CRYPTO_RMD320 is not set
CONFIG_CRYPTO_SHA1=y
# CONFIG_CRYPTO_SHA1_SSSE3 is not set
CONFIG_CRYPTO_SHA256=y
# CONFIG_CRYPTO_SHA512 is not set
CONFIG_CRYPTO_TGR192=y
# CONFIG_CRYPTO_WP512 is not set
CONFIG_CRYPTO_GHASH_CLMUL_NI_INTEL=y

#
# Ciphers
#
CONFIG_CRYPTO_AES=y
CONFIG_CRYPTO_AES_X86_64=y
CONFIG_CRYPTO_AES_NI_INTEL=y
# CONFIG_CRYPTO_ANUBIS is not set
CONFIG_CRYPTO_ARC4=y
# CONFIG_CRYPTO_BLOWFISH is not set
# CONFIG_CRYPTO_BLOWFISH_X86_64 is not set
CONFIG_CRYPTO_CAMELLIA=y
CONFIG_CRYPTO_CAMELLIA_X86_64=y
CONFIG_CRYPTO_CAST5=y
# CONFIG_CRYPTO_CAST5_AVX_X86_64 is not set
CONFIG_CRYPTO_CAST6=y
# CONFIG_CRYPTO_CAST6_AVX_X86_64 is not set
CONFIG_CRYPTO_DES=y
# CONFIG_CRYPTO_DES_SPARC64 is not set
# CONFIG_CRYPTO_FCRYPT is not set
# CONFIG_CRYPTO_KHAZAD is not set
# CONFIG_CRYPTO_SEED is not set
CONFIG_CRYPTO_SERPENT=y
CONFIG_CRYPTO_SERPENT_SSE2_X86_64=y
CONFIG_CRYPTO_SERPENT_AVX_X86_64=y
CONFIG_CRYPTO_TEA=y
# CONFIG_CRYPTO_TWOFISH is not set
# CONFIG_CRYPTO_TWOFISH_X86_64 is not set
# CONFIG_CRYPTO_TWOFISH_X86_64_3WAY is not set
# CONFIG_CRYPTO_TWOFISH_AVX_X86_64 is not set

#
# Compression
#
CONFIG_CRYPTO_DEFLATE=y
# CONFIG_CRYPTO_ZLIB is not set
# CONFIG_CRYPTO_LZO is not set

#
# Random Number Generation
#
CONFIG_CRYPTO_ANSI_CPRNG=y
# CONFIG_CRYPTO_USER_API_HASH is not set
# CONFIG_CRYPTO_USER_API_SKCIPHER is not set
# CONFIG_CRYPTO_HW is not set
CONFIG_HAVE_KVM=y
CONFIG_HAVE_KVM_IRQCHIP=y
CONFIG_HAVE_KVM_EVENTFD=y
CONFIG_KVM_APIC_ARCHITECTURE=y
CONFIG_KVM_MMIO=y
CONFIG_KVM_ASYNC_PF=y
CONFIG_HAVE_KVM_MSI=y
CONFIG_HAVE_KVM_CPU_RELAX_INTERCEPT=y
CONFIG_VIRTUALIZATION=y
CONFIG_KVM=y
CONFIG_KVM_INTEL=y
CONFIG_KVM_AMD=y
CONFIG_KVM_MMU_AUDIT=y
CONFIG_BINARY_PRINTF=y

#
# Library routines
#
CONFIG_BITREVERSE=y
CONFIG_GENERIC_STRNCPY_FROM_USER=y
CONFIG_GENERIC_STRNLEN_USER=y
CONFIG_GENERIC_FIND_FIRST_BIT=y
CONFIG_GENERIC_PCI_IOMAP=y
CONFIG_GENERIC_IOMAP=y
CONFIG_GENERIC_IO=y
# CONFIG_CRC_CCITT is not set
CONFIG_CRC16=y
# CONFIG_CRC_T10DIF is not set
# CONFIG_CRC_ITU_T is not set
CONFIG_CRC32=y
CONFIG_CRC32_SELFTEST=y
CONFIG_CRC32_SLICEBY8=y
# CONFIG_CRC32_SLICEBY4 is not set
# CONFIG_CRC32_SARWATE is not set
# CONFIG_CRC32_BIT is not set
CONFIG_CRC7=y
CONFIG_LIBCRC32C=y
CONFIG_CRC8=y
CONFIG_ZLIB_INFLATE=y
CONFIG_ZLIB_DEFLATE=y
CONFIG_LZO_COMPRESS=y
CONFIG_LZO_DECOMPRESS=y
CONFIG_XZ_DEC=y
CONFIG_XZ_DEC_X86=y
CONFIG_XZ_DEC_POWERPC=y
CONFIG_XZ_DEC_IA64=y
CONFIG_XZ_DEC_ARM=y
CONFIG_XZ_DEC_ARMTHUMB=y
CONFIG_XZ_DEC_SPARC=y
CONFIG_XZ_DEC_BCJ=y
CONFIG_XZ_DEC_TEST=y
CONFIG_DECOMPRESS_GZIP=y
CONFIG_DECOMPRESS_BZIP2=y
CONFIG_DECOMPRESS_LZMA=y
CONFIG_DECOMPRESS_XZ=y
CONFIG_DECOMPRESS_LZO=y
CONFIG_HAS_IOMEM=y
CONFIG_HAS_IOPORT=y
CONFIG_HAS_DMA=y
CONFIG_CHECK_SIGNATURE=y
CONFIG_CPU_RMAP=y
CONFIG_DQL=y
CONFIG_NLATTR=y
CONFIG_ARCH_HAS_ATOMIC64_DEC_IF_POSITIVE=y
# CONFIG_AVERAGE is not set
# CONFIG_CORDIC is not set
# CONFIG_DDR is not set

--EVF5PPMfhYS0aIcm--
