From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [GIT]: Networking
Date: Tue, 16 Jun 2009 12:11:32 +0200
Message-ID: <20090616101132.GA28204@elte.hu>
References: <20090616.021955.243374916.davem@davemloft.net> <20090616104417.657d6682@lxorguk.ukuu.org.uk> <20090616094813.GA1686@elte.hu> <20090616.025659.224075454.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: alan@lxorguk.ukuu.org.uk, torvalds@linux-foundation.org,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756152AbZFPKMs@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090616.025659.224075454.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* David Miller <davem@davemloft.net> wrote:

> From: Ingo Molnar <mingo@elte.hu>
> Date: Tue, 16 Jun 2009 11:48:13 +0200
>=20
> > I think David's larger point was that what looked to me like more=20
> > widespread breakage was in fact limited to [a]x25, a comparatively=20
> > rarely used (and rarely tested) corner of the kernel.
> >=20
> > I turned them off and that solved the problems here. (and i suspect=
=20
> > the real fix wont be far away either) Thanks everyone.
>=20
> This code path has been broken, basically, forever.  It does a
> lock_sock() from a timer, which has that might_sleep() check, and
> essentially always has.
>=20
> It would have warned this way years ago if someone had triggered it.
>=20
> The code has been this way forever, so something else changed to star=
t
> triggering this on you.
>=20
> I still am curious what in the world opens those sockets for you,
> nothing normal should be doing so.
>=20
> Can you satisfy my curiosity by turning X25 back on and booting=20
> with this patch?  Thanks.

sure, here you go (i also added a stack dump, just in case it's some=20
kernel-internal socket open):

 [ifconfig:3516]: Creates X25 socket.

so plain ifconfig. Part of the ~1.5 years old net-tools-1.60-84.fc8.

there's nothing intentionally x25 related in the network config:

  mercury:/etc/sysconfig> grep -rli x25 .
  mercury:/etc/sysconfig>=20

odd. I sure would have noticed such a warning+crash - it started=20
triggering today. Maybe something confuses ifconfig into creating=20
some? (the box did come up fine)

=46ull bootlog below.

	Ingo

Linux version 2.6.30-tip (mingo@sirius) (gcc version 4.3.2 20081105 (Re=
d Hat 4.3.2-7) (GCC) ) #54077 SMP Tue Jun 16 12:03:21 CEST 2009
Command line: root=3D/dev/sda6 earlyprintk=3Dserial,ttyS0,115200 consol=
e=3DttyS0,115200 debug initcall_debug apic=3Dverbose sysrq_always_enabl=
ed ignore_loglevel selinux=3D0 nmi_watchdog=3D0 panic=3D1 3
KERNEL supported cpus:
  Intel GenuineIntel
  Centaur CentaurHauls
CPU: vendor_id 'AuthenticAMD' unknown, using generic init.
CPU: Your system may be unstable.
BIOS-provided physical RAM map:
 BIOS-e820: 0000000000000000 - 000000000009f800 (usable)
 BIOS-e820: 000000000009f800 - 00000000000a0000 (reserved)
 BIOS-e820: 00000000000f0000 - 0000000000100000 (reserved)
 BIOS-e820: 0000000000100000 - 000000003fff0000 (usable)
 BIOS-e820: 000000003fff0000 - 000000003fff3000 (ACPI NVS)
 BIOS-e820: 000000003fff3000 - 0000000040000000 (ACPI data)
 BIOS-e820: 00000000e0000000 - 00000000f0000000 (reserved)
 BIOS-e820: 00000000fec00000 - 0000000100000000 (reserved)
console [earlyser0] enabled
debug: ignoring loglevel setting.
DMI 2.3 present.
Phoenix BIOS detected: BIOS may corrupt low RAM, working around it.
e820 update range: 0000000000000000 - 0000000000010000 (usable) =3D=3D>=
 (reserved)
last_pfn =3D 0x3fff0 max_arch_pfn =3D 0x400000000
MTRR default type: uncachable
MTRR fixed ranges enabled:
  00000-9FFFF write-back
  A0000-BFFFF uncachable
  C0000-C7FFF write-protect
  C8000-FFFFF uncachable
MTRR variable ranges enabled:
  0 base 0000000000 mask FFC0000000 write-back
  1 disabled
  2 disabled
  3 disabled
  4 disabled
  5 disabled
  6 disabled
  7 disabled
x86 PAT enabled: cpu 0, old 0x7040600070406, new 0x7010600070106
Scanning 0 areas for low memory corruption
modified physical RAM map:
 modified: 0000000000000000 - 0000000000010000 (reserved)
 modified: 0000000000010000 - 000000000009f800 (usable)
 modified: 000000000009f800 - 00000000000a0000 (reserved)
 modified: 00000000000f0000 - 0000000000100000 (reserved)
 modified: 0000000000100000 - 000000003fff0000 (usable)
 modified: 000000003fff0000 - 000000003fff3000 (ACPI NVS)
 modified: 000000003fff3000 - 0000000040000000 (ACPI data)
 modified: 00000000e0000000 - 00000000f0000000 (reserved)
 modified: 00000000fec00000 - 0000000100000000 (reserved)
initial memory mapped : 0 - 20000000
init_memory_mapping: 0000000000000000-000000003fff0000
 0000000000 - 003fff0000 page 4k
kernel direct mapping tables up to 3fff0000 @ 100000-302000
(6 early reservations) =3D=3D> bootmem [0000000000 - 003fff0000]
  #0 [0000000000 - 0000001000]   BIOS data page =3D=3D> [0000000000 - 0=
000001000]
  #1 [0000006000 - 0000008000]       TRAMPOLINE =3D=3D> [0000006000 - 0=
000008000]
  #2 [0001000000 - 0003241d98]    TEXT DATA BSS =3D=3D> [0001000000 - 0=
003241d98]
  #3 [000009f800 - 0000100000]    BIOS reserved =3D=3D> [000009f800 - 0=
000100000]
  #4 [0003242000 - 0003242149]              BRK =3D=3D> [0003242000 - 0=
003242149]
  #5 [0000100000 - 0000300000]          PGTABLE =3D=3D> [0000100000 - 0=
000300000]
Scan SMP from ffff880000000000 for 1024 bytes.
Scan SMP from ffff88000009fc00 for 1024 bytes.
Scan SMP from ffff8800000f0000 for 65536 bytes.
found SMP MP-table at [ffff8800000f5680] f5680
  mpc: f1400-f152c
 [ffffea0000000000-ffffea00019fffff] PMD -> [ffff880003800000-ffff88000=
51fffff] on node 0
Zone PFN ranges:
  DMA      0x00000010 -> 0x00001000
  DMA32    0x00001000 -> 0x00100000
  Normal   0x00100000 -> 0x00100000
Movable zone start PFN for each node
early_node_map[2] active PFN ranges
    0: 0x00000010 -> 0x0000009f
    0: 0x00000100 -> 0x0003fff0
On node 0 totalpages: 262015
  DMA zone: 104 pages used for memmap
  DMA zone: 611 pages reserved
  DMA zone: 3268 pages, LIFO batch:0
  DMA32 zone: 6552 pages used for memmap
  DMA32 zone: 251480 pages, LIFO batch:31
Intel MultiProcessor Specification v1.4
  mpc: f1400-f152c
MPTABLE: OEM ID: OEM00000
MPTABLE: Product ID: PROD00000000
MPTABLE: APIC at: 0xFEE00000
Processor #0 (Bootup-CPU)
Processor #1
Bus #0 is PCI  =20
Bus #1 is PCI  =20
Bus #2 is PCI  =20
Bus #3 is PCI  =20
Bus #4 is PCI  =20
Bus #5 is PCI  =20
Bus #6 is ISA  =20
I/O APIC #2 Version 17 at 0xFEC00000.
Int: type 0, pol 3, trig 3, bus 00, IRQ 28, APIC ID 2, APIC INT 0b
Int: type 0, pol 3, trig 3, bus 00, IRQ 10, APIC ID 2, APIC INT 03
Int: type 0, pol 3, trig 3, bus 01, IRQ 00, APIC ID 2, APIC INT 05
Int: type 0, pol 3, trig 3, bus 05, IRQ 1c, APIC ID 2, APIC INT 0b
Int: type 3, pol 0, trig 0, bus 06, IRQ 00, APIC ID 2, APIC INT 00
Int: type 0, pol 0, trig 0, bus 06, IRQ 01, APIC ID 2, APIC INT 01
Int: type 0, pol 0, trig 0, bus 06, IRQ 00, APIC ID 2, APIC INT 02
Int: type 0, pol 0, trig 0, bus 06, IRQ 04, APIC ID 2, APIC INT 04
Int: type 0, pol 0, trig 0, bus 06, IRQ 06, APIC ID 2, APIC INT 06
Int: type 0, pol 0, trig 0, bus 06, IRQ 07, APIC ID 2, APIC INT 07
Int: type 0, pol 1, trig 1, bus 06, IRQ 08, APIC ID 2, APIC INT 08
Int: type 0, pol 0, trig 0, bus 06, IRQ 09, APIC ID 2, APIC INT 09
Int: type 0, pol 0, trig 0, bus 06, IRQ 0a, APIC ID 2, APIC INT 0a
Int: type 0, pol 0, trig 0, bus 06, IRQ 0c, APIC ID 2, APIC INT 0c
Int: type 0, pol 0, trig 0, bus 06, IRQ 0d, APIC ID 2, APIC INT 0d
Int: type 0, pol 0, trig 0, bus 06, IRQ 0e, APIC ID 2, APIC INT 0e
Int: type 0, pol 0, trig 0, bus 06, IRQ 0f, APIC ID 2, APIC INT 0f
Lint: type 3, pol 0, trig 0, bus 00, IRQ 00, APIC ID ff, APIC LINT 00
Lint: type 1, pol 0, trig 0, bus 00, IRQ 00, APIC ID ff, APIC LINT 01
Processors: 2
SMP: Allowing 2 CPUs, 0 hotplug CPUs
mapped APIC to ffffffffff5fc000 (fee00000)
mapped IOAPIC to ffffffffff5fb000 (fec00000)
nr_irqs_gsi: 24
Allocating PCI resources starting at 40000000 (gap: 40000000:a0000000)
NR_CPUS:4096 nr_cpumask_bits:2 nr_cpu_ids:2 nr_node_ids:1
PERCPU: Embedded 477 pages at ffff880005200000, static data 1932960 byt=
es
Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 25=
4748
Kernel command line: root=3D/dev/sda6 earlyprintk=3Dserial,ttyS0,115200=
 console=3DttyS0,115200 debug initcall_debug apic=3Dverbose sysrq_alway=
s_enabled ignore_loglevel selinux=3D0 nmi_watchdog=3D0 panic=3D1 3
debug: sysrq always enabled.
PID hash table entries: 4096 (order: 12, 32768 bytes)
Dentry cache hash table entries: 131072 (order: 8, 1048576 bytes)
Inode-cache hash table entries: 65536 (order: 7, 524288 bytes)
Initializing CPU#0
Calgary: detecting Calgary via BIOS EBDA area
Calgary: Unable to locate Rio Grande table in EBDA - bailing!
Memory: 977592k/1048512k available (13593k kernel code, 452k absent, 69=
816k reserved, 7155k data, 2444k init)
SLUB: Genslabs=3D13, HWalign=3D64, Order=3D0-3, MinObjects=3D0, CPUs=3D=
2, Nodes=3D1
NR_IRQS:33024 nr_irqs:424
=46ast TSC calibration using PIT
Detected 2010.653 MHz processor.
spurious 8259A interrupt: IRQ7.
Console: colour VGA+ 80x25
console handover: boot [earlyser0] -> real [ttyS0]
Lock dependency validator: Copyright (c) 2006 Red Hat, Inc., Ingo Molna=
r
=2E.. MAX_LOCKDEP_SUBCLASSES:  8
=2E.. MAX_LOCK_DEPTH:          48
=2E.. MAX_LOCKDEP_KEYS:        8191
=2E.. CLASSHASH_SIZE:          4096
=2E.. MAX_LOCKDEP_ENTRIES:     16384
=2E.. MAX_LOCKDEP_CHAINS:      32768
=2E.. CHAINHASH_SIZE:          16384
 memory used by lock dependency info: 6207 kB
 per task-struct memory footprint: 2688 bytes
------------------------
| Locking API testsuite:
-----------------------------------------------------------------------=
-----
                                 | spin |wlock |rlock |mutex | wsem | r=
sem |
  ---------------------------------------------------------------------=
-----
                     A-A deadlock:failed|failed|  ok  |failed|failed|fa=
iled|
                 A-B-B-A deadlock:failed|failed|  ok  |failed|failed|fa=
iled|
             A-B-B-C-C-A deadlock:failed|failed|  ok  |failed|failed|fa=
iled|
             A-B-C-A-B-C deadlock:failed|failed|  ok  |failed|failed|fa=
iled|
         A-B-B-C-C-D-D-A deadlock:failed|failed|  ok  |failed|failed|fa=
iled|
         A-B-C-D-B-D-D-A deadlock:failed|failed|  ok  |failed|failed|fa=
iled|
         A-B-C-D-B-C-D-A deadlock:failed|failed|  ok  |failed|failed|fa=
iled|
                    double unlock:  ok  |  ok  |  ok  |  ok  |  ok  |  =
ok  |
                  initialize held:  ok  |  ok  |  ok  |  ok  |  ok  |  =
ok  |
                 bad unlock order:  ok  |  ok  |  ok  |  ok  |  ok  |  =
ok  |
  ---------------------------------------------------------------------=
-----
              recursive read-lock:             |  ok  |             |fa=
iled|
           recursive read-lock #2:             |  ok  |             |fa=
iled|
            mixed read-write-lock:             |failed|             |fa=
iled|
            mixed write-read-lock:             |failed|             |fa=
iled|
  ---------------------------------------------------------------------=
-----
     hard-irqs-on + irq-safe-A/12:failed|failed|  ok  |
     soft-irqs-on + irq-safe-A/12:failed|failed|  ok  |
     hard-irqs-on + irq-safe-A/21:failed|failed|  ok  |
     soft-irqs-on + irq-safe-A/21:failed|failed|  ok  |
       sirq-safe-A =3D> hirqs-on/12:failed|failed|  ok  |
       sirq-safe-A =3D> hirqs-on/21:failed|failed|  ok  |
         hard-safe-A + irqs-on/12:failed|failed|  ok  |
         soft-safe-A + irqs-on/12:failed|failed|  ok  |
         hard-safe-A + irqs-on/21:failed|failed|  ok  |
         soft-safe-A + irqs-on/21:failed|failed|  ok  |
    hard-safe-A + unsafe-B #1/123:failed|failed|  ok  |
    soft-safe-A + unsafe-B #1/123:failed|failed|  ok  |
    hard-safe-A + unsafe-B #1/132:failed|failed|  ok  |
    soft-safe-A + unsafe-B #1/132:failed|failed|  ok  |
    hard-safe-A + unsafe-B #1/213:failed|failed|  ok  |
    soft-safe-A + unsafe-B #1/213:failed|failed|  ok  |
    hard-safe-A + unsafe-B #1/231:failed|failed|  ok  |
    soft-safe-A + unsafe-B #1/231:failed|failed|  ok  |
    hard-safe-A + unsafe-B #1/312:failed|failed|  ok  |
    soft-safe-A + unsafe-B #1/312:failed|failed|  ok  |
    hard-safe-A + unsafe-B #1/321:failed|failed|  ok  |
    soft-safe-A + unsafe-B #1/321:failed|failed|  ok  |
    hard-safe-A + unsafe-B #2/123:failed|failed|  ok  |
    soft-safe-A + unsafe-B #2/123:failed|failed|  ok  |
    hard-safe-A + unsafe-B #2/132:failed|failed|  ok  |
    soft-safe-A + unsafe-B #2/132:failed|failed|  ok  |
    hard-safe-A + unsafe-B #2/213:failed|failed|  ok  |
    soft-safe-A + unsafe-B #2/213:failed|failed|  ok  |
    hard-safe-A + unsafe-B #2/231:failed|failed|  ok  |
    soft-safe-A + unsafe-B #2/231:failed|failed|  ok  |
    hard-safe-A + unsafe-B #2/312:failed|failed|  ok  |
    soft-safe-A + unsafe-B #2/312:failed|failed|  ok  |
    hard-safe-A + unsafe-B #2/321:failed|failed|  ok  |
    soft-safe-A + unsafe-B #2/321:failed|failed|  ok  |
      hard-irq lock-inversion/123:failed|failed|  ok  |
      soft-irq lock-inversion/123:failed|failed|  ok  |
      hard-irq lock-inversion/132:failed|failed|  ok  |
      soft-irq lock-inversion/132:failed|failed|  ok  |
      hard-irq lock-inversion/213:failed|failed|  ok  |
      soft-irq lock-inversion/213:failed|failed|  ok  |
      hard-irq lock-inversion/231:failed|failed|  ok  |
      soft-irq lock-inversion/231:failed|failed|  ok  |
      hard-irq lock-inversion/312:failed|failed|  ok  |
      soft-irq lock-inversion/312:failed|failed|  ok  |
      hard-irq lock-inversion/321:failed|failed|  ok  |
      soft-irq lock-inversion/321:failed|failed|  ok  |
      hard-irq read-recursion/123:  ok  |
      soft-irq read-recursion/123:  ok  |
      hard-irq read-recursion/132:  ok  |
      soft-irq read-recursion/132:  ok  |
      hard-irq read-recursion/213:  ok  |
      soft-irq read-recursion/213:  ok  |
      hard-irq read-recursion/231:  ok  |
      soft-irq read-recursion/231:  ok  |
      hard-irq read-recursion/312:  ok  |
      soft-irq read-recursion/312:  ok  |
      hard-irq read-recursion/321:  ok  |
      soft-irq read-recursion/321:  ok  |
--------------------------------------------------------
133 out of 218 testcases failed, as expected. |
----------------------------------------------------
allocated 10485760 bytes of page_cgroup
please try cgroup_disable=3Dmemory option if you don't want
ODEBUG: 9 of 9 active objects replaced
Calibrating delay loop (skipped), value calculated using timer frequenc=
y.. 4022.86 BogoMIPS (lpj=3D6702176)
Security Framework initialized
TOMOYO Linux initialized
Mount-cache hash table entries: 256
Initializing cgroup subsys debug
Initializing cgroup subsys cpuacct
Initializing cgroup subsys memory
Initializing cgroup subsys net_cls
CPU: L1 I Cache: 64K (64 bytes/line), D cache 64K (64 bytes/line)
CPU: L2 Cache: 512K (64 bytes/line)
Performance Counters: <6>Setting APIC routing to flat
enabled ExtINT on CPU#0
ExtINT not setup in hardware but reported by MP table
ENABLING IO-APIC IRQs
init IO_APIC IRQs
 2-0 (apicid-pin) not connected
IOAPIC[0]: Set routing entry (2-1 -> 0x31 -> IRQ 1 Mode:0 Active:0)
IOAPIC[0]: Set routing entry (2-2 -> 0x30 -> IRQ 0 Mode:0 Active:0)
IOAPIC[0]: Set routing entry (2-3 -> 0x33 -> IRQ 3 Mode:1 Active:1)
IOAPIC[0]: Set routing entry (2-4 -> 0x34 -> IRQ 4 Mode:0 Active:0)
IOAPIC[0]: Set routing entry (2-5 -> 0x35 -> IRQ 5 Mode:1 Active:1)
IOAPIC[0]: Set routing entry (2-6 -> 0x36 -> IRQ 6 Mode:0 Active:0)
IOAPIC[0]: Set routing entry (2-7 -> 0x37 -> IRQ 7 Mode:0 Active:0)
IOAPIC[0]: Set routing entry (2-8 -> 0x38 -> IRQ 8 Mode:0 Active:0)
IOAPIC[0]: Set routing entry (2-9 -> 0x39 -> IRQ 9 Mode:0 Active:0)
IOAPIC[0]: Set routing entry (2-10 -> 0x3a -> IRQ 10 Mode:0 Active:0)
IOAPIC[0]: Set routing entry (2-11 -> 0x3b -> IRQ 11 Mode:1 Active:1)
IOAPIC[0]: Set routing entry (2-12 -> 0x3c -> IRQ 12 Mode:0 Active:0)
IOAPIC[0]: Set routing entry (2-13 -> 0x3d -> IRQ 13 Mode:0 Active:0)
IOAPIC[0]: Set routing entry (2-14 -> 0x3e -> IRQ 14 Mode:0 Active:0)
IOAPIC[0]: Set routing entry (2-15 -> 0x3f -> IRQ 15 Mode:0 Active:0)
 2-16 2-17 2-18 2-19 2-20 2-21 2-22 2-23 (apicid-pin) not connected
=2E.TIMER: vector=3D0x30 apic1=3D0 pin1=3D2 apic2=3D0 pin2=3D0
=2E.MP-BIOS bug: 8254 timer not connected to IO-APIC
=2E..trying to set up timer (IRQ0) through the 8259A ...
=2E.... (found apic 0 pin 0) ...
=2E...... works.
CPU0: AuthenticAMD AMD Athlon(tm) 64 X2 Dual Core Processor 3800+ stepp=
ing 02
Using local APIC timer interrupts.
calibrating APIC timer ...
=2E.. lapic delta =3D 1256355
=2E.... delta 1256355
=2E.... mult: 53963554
=2E.... calibration result: 670056
=2E.... CPU clock speed is 2010.1227 MHz.
=2E.... host bus clock speed is 201.0123 MHz.
=2E.. verify APIC timer
=2E.. jiffies delta =3D 30
=2E.. jiffies result ok
calling  migration_init+0x0/0x5c @ 1
initcall migration_init+0x0/0x5c returned 1 after 3255 usecs
initcall migration_init+0x0/0x5c returned with error code 1=20
calling  spawn_ksoftirqd+0x0/0x5c @ 1
initcall spawn_ksoftirqd+0x0/0x5c returned 0 after 0 usecs
calling  init_call_single_data+0x0/0xeb @ 1
initcall init_call_single_data+0x0/0xeb returned 0 after 0 usecs
calling  relay_init+0x0/0x14 @ 1
initcall relay_init+0x0/0x14 returned 0 after 0 usecs
calling  tracer_alloc_buffers+0x0/0x32d @ 1
initcall tracer_alloc_buffers+0x0/0x32d returned 0 after 0 usecs
calling  init_trace_printk+0x0/0x8 @ 1
initcall init_trace_printk+0x0/0x8 returned 0 after 0 usecs
calling  trace_workqueue_early_init+0x0/0x17a @ 1
initcall trace_workqueue_early_init+0x0/0x17a returned 0 after 0 usecs
lockdep: fixing up alternatives.
Booting processor 1 APIC 0x1 ip 0x6000
Initializing CPU#1
masked ExtINT on CPU#1
Calibrating delay using timer specific routine.. 4021.85 BogoMIPS (lpj=3D=
6700573)
CPU: L1 I Cache: 64K (64 bytes/line), D cache 64K (64 bytes/line)
CPU: L2 Cache: 512K (64 bytes/line)
x86 PAT enabled: cpu 1, old 0x7040600070406, new 0x7010600070106
CPU1: AuthenticAMD AMD Athlon(tm) 64 X2 Dual Core Processor 3800+ stepp=
ing 02
Brought up 2 CPUs
Total of 2 processors activated (8044.71 BogoMIPS).
calling  init_cpufreq_transition_notifier_list+0x0/0x1b @ 1
initcall init_cpufreq_transition_notifier_list+0x0/0x1b returned 0 afte=
r 0 usecs
calling  net_ns_init+0x0/0x162 @ 1
initcall net_ns_init+0x0/0x162 returned 0 after 0 usecs
calling  cpufreq_tsc+0x0/0x28 @ 1
initcall cpufreq_tsc+0x0/0x28 returned 0 after 0 usecs
calling  print_banner+0x0/0xe @ 1
Booting paravirtualized kernel on bare hardware
initcall print_banner+0x0/0xe returned 0 after 3255 usecs
calling  init_smp_flush+0x0/0x4f @ 1
initcall init_smp_flush+0x0/0x4f returned 0 after 0 usecs
calling  sysctl_init+0x0/0x32 @ 1
initcall sysctl_init+0x0/0x32 returned 0 after 0 usecs
calling  ksysfs_init+0x0/0xbb @ 1
initcall ksysfs_init+0x0/0xbb returned 0 after 0 usecs
calling  async_init+0x0/0x47 @ 1
initcall async_init+0x0/0x47 returned 0 after 0 usecs
calling  init_jiffies_clocksource+0x0/0x12 @ 1
initcall init_jiffies_clocksource+0x0/0x12 returned 0 after 0 usecs
calling  init_hw_breakpoint+0x0/0x12 @ 1
initcall init_hw_breakpoint+0x0/0x12 returned 0 after 0 usecs
calling  filelock_init+0x0/0x2e @ 1
initcall filelock_init+0x0/0x2e returned 0 after 0 usecs
calling  init_script_binfmt+0x0/0x14 @ 1
initcall init_script_binfmt+0x0/0x14 returned 0 after 0 usecs
calling  init_elf_binfmt+0x0/0x14 @ 1
initcall init_elf_binfmt+0x0/0x14 returned 0 after 0 usecs
calling  init_compat_elf_binfmt+0x0/0x14 @ 1
initcall init_compat_elf_binfmt+0x0/0x14 returned 0 after 0 usecs
calling  debugfs_init+0x0/0x66 @ 1
initcall debugfs_init+0x0/0x66 returned 0 after 0 usecs
calling  securityfs_init+0x0/0x54 @ 1
initcall securityfs_init+0x0/0x54 returned 0 after 0 usecs
calling  random32_init+0x0/0x129 @ 1
initcall random32_init+0x0/0x129 returned 0 after 0 usecs
calling  regulator_init+0x0/0x2e @ 1
regulator: core version 0.5
initcall regulator_init+0x0/0x2e returned 0 after 3255 usecs
calling  cpufreq_core_init+0x0/0xb8 @ 1
initcall cpufreq_core_init+0x0/0xb8 returned 0 after 0 usecs
calling  cpuidle_init+0x0/0x43 @ 1
initcall cpuidle_init+0x0/0x43 returned 0 after 0 usecs
calling  virtio_init+0x0/0x30 @ 1
initcall virtio_init+0x0/0x30 returned 0 after 0 usecs
calling  sock_init+0x0/0x60 @ 1
initcall sock_init+0x0/0x60 returned 0 after 0 usecs
calling  netpoll_init+0x0/0x41 @ 1
initcall netpoll_init+0x0/0x41 returned 0 after 0 usecs
calling  netlink_proto_init+0x0/0x1c3 @ 1
NET: Registered protocol family 16
initcall netlink_proto_init+0x0/0x1c3 returned 0 after 3255 usecs
calling  bdi_class_init+0x0/0x41 @ 1
initcall bdi_class_init+0x0/0x41 returned 0 after 0 usecs
calling  kobject_uevent_init+0x0/0x54 @ 1
initcall kobject_uevent_init+0x0/0x54 returned 0 after 0 usecs
calling  pcibus_class_init+0x0/0x19 @ 1
initcall pcibus_class_init+0x0/0x19 returned 0 after 0 usecs
calling  pci_driver_init+0x0/0x18 @ 1
initcall pci_driver_init+0x0/0x18 returned 0 after 0 usecs
calling  lcd_class_init+0x0/0x4d @ 1
initcall lcd_class_init+0x0/0x4d returned 0 after 3255 usecs
calling  backlight_class_init+0x0/0x5d @ 1
initcall backlight_class_init+0x0/0x5d returned 0 after 0 usecs
calling  video_output_class_init+0x0/0x21 @ 1
initcall video_output_class_init+0x0/0x21 returned 0 after 0 usecs
calling  tty_class_init+0x0/0x31 @ 1
initcall tty_class_init+0x0/0x31 returned 0 after 0 usecs
calling  vtconsole_class_init+0x0/0xcc @ 1
initcall vtconsole_class_init+0x0/0xcc returned 0 after 0 usecs
calling  i2c_init+0x0/0x6b @ 1
initcall i2c_init+0x0/0x6b returned 0 after 3255 usecs
calling  amd_postcore_init+0x0/0xbf @ 1
initcall amd_postcore_init+0x0/0xbf returned 0 after 0 usecs
calling  arch_kdebugfs_init+0x0/0x270 @ 1
initcall arch_kdebugfs_init+0x0/0x270 returned 0 after 0 usecs
calling  mtrr_if_init+0x0/0x6d @ 1
initcall mtrr_if_init+0x0/0x6d returned 0 after 0 usecs
calling  dmi_id_init+0x0/0x36c @ 1
initcall dmi_id_init+0x0/0x36c returned 0 after 0 usecs
calling  pci_arch_init+0x0/0x50 @ 1
PCI: Using configuration type 1 for base access
initcall pci_arch_init+0x0/0x50 returned 0 after 3255 usecs
calling  topology_init+0x0/0x77 @ 1
initcall topology_init+0x0/0x77 returned 0 after 0 usecs
calling  mtrr_init_finialize+0x0/0x3e @ 1
initcall mtrr_init_finialize+0x0/0x3e returned 0 after 0 usecs
calling  param_sysfs_init+0x0/0x395 @ 1
initcall param_sysfs_init+0x0/0x395 returned 0 after 78125 usecs
calling  init_slow_work+0x0/0x38 @ 1
initcall init_slow_work+0x0/0x38 returned 0 after 0 usecs
calling  default_bdi_init+0x0/0x3b @ 1
initcall default_bdi_init+0x0/0x3b returned 0 after 0 usecs
calling  init_bio+0x0/0x143 @ 1
bio: create slab <bio-0> at 0
initcall init_bio+0x0/0x143 returned 0 after 3255 usecs
calling  cryptomgr_init+0x0/0x12 @ 1
initcall cryptomgr_init+0x0/0x12 returned 0 after 0 usecs
calling  blk_settings_init+0x0/0x2c @ 1
initcall blk_settings_init+0x0/0x2c returned 0 after 0 usecs
calling  blk_ioc_init+0x0/0x2a @ 1
initcall blk_ioc_init+0x0/0x2a returned 0 after 0 usecs
calling  blk_softirq_init+0x0/0xb3 @ 1
initcall blk_softirq_init+0x0/0xb3 returned 0 after 0 usecs
calling  genhd_device_init+0x0/0x69 @ 1
initcall genhd_device_init+0x0/0x69 returned 0 after 0 usecs
calling  pci_slot_init+0x0/0x50 @ 1
initcall pci_slot_init+0x0/0x50 returned 0 after 0 usecs
calling  fbmem_init+0x0/0x95 @ 1
initcall fbmem_init+0x0/0x95 returned 0 after 0 usecs
calling  max1586_pmic_init+0x0/0x14 @ 1
initcall max1586_pmic_init+0x0/0x14 returned 0 after 0 usecs
calling  twl4030reg_init+0x0/0x17 @ 1
initcall twl4030reg_init+0x0/0x17 returned 0 after 0 usecs
calling  misc_init+0x0/0xa4 @ 1
initcall misc_init+0x0/0xa4 returned 0 after 0 usecs
calling  cn_init+0x0/0xfb @ 1
initcall cn_init+0x0/0xfb returned 0 after 0 usecs
calling  tifm_init+0x0/0x8a @ 1
initcall tifm_init+0x0/0x8a returned 0 after 0 usecs
calling  twl4030_init+0x0/0x1f @ 1
initcall twl4030_init+0x0/0x1f returned 0 after 0 usecs
calling  init_scsi+0x0/0xa1 @ 1
SCSI subsystem initialized
initcall init_scsi+0x0/0xa1 returned 0 after 3255 usecs
calling  ata_init+0x0/0x405 @ 1
libata version 3.00 loaded.
initcall ata_init+0x0/0x405 returned 0 after 3255 usecs
calling  phy_init+0x0/0x3a @ 1
initcall phy_init+0x0/0x3a returned 0 after 0 usecs
calling  init_pcmcia_cs+0x0/0x2f @ 1
initcall init_pcmcia_cs+0x0/0x2f returned 0 after 0 usecs
calling  twl4030_usb_init+0x0/0x12 @ 1
initcall twl4030_usb_init+0x0/0x12 returned 0 after 0 usecs
calling  nop_usb_xceiv_init+0x0/0x15 @ 1
initcall nop_usb_xceiv_init+0x0/0x15 returned 0 after 0 usecs
calling  usb_init+0x0/0x11f @ 1
usbcore: registered new interface driver usbfs
usbcore: registered new interface driver hub
usbcore: registered new device driver usb
initcall usb_init+0x0/0x11f returned 0 after 13020 usecs
calling  serio_init+0x0/0x92 @ 1
initcall serio_init+0x0/0x92 returned 0 after 0 usecs
calling  gameport_init+0x0/0x92 @ 1
initcall gameport_init+0x0/0x92 returned 0 after 0 usecs
calling  input_init+0x0/0x149 @ 1
initcall input_init+0x0/0x149 returned 0 after 0 usecs
calling  rtc_init+0x0/0x71 @ 1
initcall rtc_init+0x0/0x71 returned 0 after 0 usecs
calling  power_supply_class_init+0x0/0x38 @ 1
initcall power_supply_class_init+0x0/0x38 returned 0 after 0 usecs
calling  thermal_init+0x0/0x68 @ 1
initcall thermal_init+0x0/0x68 returned 0 after 3255 usecs
calling  mmc_init+0x0/0x7b @ 1
initcall mmc_init+0x0/0x7b returned 0 after 0 usecs
calling  pci_subsys_init+0x0/0x150 @ 1
PCI: Probing PCI hardware
PCI: Probing PCI hardware (bus 00)
PCI: Scanning bus 0000:00
pci 0000:00:00.0: found [10de:005e] class 000580 header type 00
pci 0000:00:00.0: calling quirk_resource_alignment+0x0/0x1bd
pci 0000:00:01.0: found [10de:0050] class 000601 header type 00
pci 0000:00:01.0: calling nvidia_force_enable_hpet+0x0/0xd0
HPET not enabled in BIOS. You might try hpet=3Dforce boot option
pci 0000:00:01.0: calling quirk_resource_alignment+0x0/0x1bd
pci 0000:00:01.1: found [10de:0052] class 000c05 header type 00
pci 0000:00:01.1: reg 10 io port: [0xdc00-0xdc1f]
pci 0000:00:01.1: reg 20 io port: [0x4c00-0x4c3f]
pci 0000:00:01.1: reg 24 io port: [0x4c40-0x4c7f]
pci 0000:00:01.1: calling quirk_resource_alignment+0x0/0x1bd
pci 0000:00:01.1: PME# supported from D3hot D3cold
pci 0000:00:01.1: PME# disabled
pci 0000:00:02.0: found [10de:005a] class 000c03 header type 00
pci 0000:00:02.0: reg 10 32bit mmio: [0xda102000-0xda102fff]
pci 0000:00:02.0: calling quirk_resource_alignment+0x0/0x1bd
pci 0000:00:02.0: supports D1 D2
pci 0000:00:02.0: PME# supported from D0 D1 D2 D3hot D3cold
pci 0000:00:02.0: PME# disabled
pci 0000:00:02.1: found [10de:005b] class 000c03 header type 00
pci 0000:00:02.1: reg 10 32bit mmio: [0xfeb00000-0xfeb000ff]
pci 0000:00:02.1: calling quirk_resource_alignment+0x0/0x1bd
pci 0000:00:02.1: supports D1 D2
pci 0000:00:02.1: PME# supported from D0 D1 D2 D3hot D3cold
pci 0000:00:02.1: PME# disabled
pci 0000:00:04.0: found [10de:0059] class 000401 header type 00
pci 0000:00:04.0: reg 10 io port: [0xd400-0xd4ff]
pci 0000:00:04.0: reg 14 io port: [0xd800-0xd8ff]
pci 0000:00:04.0: reg 18 32bit mmio: [0xda101000-0xda101fff]
pci 0000:00:04.0: calling quirk_resource_alignment+0x0/0x1bd
pci 0000:00:04.0: supports D1 D2
pci 0000:00:06.0: found [10de:0053] class 000101 header type 00
pci 0000:00:06.0: reg 20 io port: [0xf000-0xf00f]
pci 0000:00:06.0: calling quirk_resource_alignment+0x0/0x1bd
pci 0000:00:09.0: found [10de:005c] class 000604 header type 01
pci 0000:00:09.0: calling quirk_resource_alignment+0x0/0x1bd
pci 0000:00:0a.0: found [10de:0057] class 000680 header type 00
pci 0000:00:0a.0: reg 10 32bit mmio: [0xda100000-0xda100fff]
pci 0000:00:0a.0: reg 14 io port: [0xd000-0xd007]
pci 0000:00:0a.0: calling quirk_resource_alignment+0x0/0x1bd
pci 0000:00:0a.0: supports D1 D2
pci 0000:00:0a.0: PME# supported from D0 D1 D2 D3hot D3cold
pci 0000:00:0a.0: PME# disabled
pci 0000:00:0b.0: found [10de:005d] class 000604 header type 01
pci 0000:00:0b.0: calling quirk_resource_alignment+0x0/0x1bd
pci 0000:00:0b.0: PME# supported from D0 D1 D2 D3hot D3cold
pci 0000:00:0b.0: PME# disabled
pci 0000:00:0c.0: found [10de:005d] class 000604 header type 01
pci 0000:00:0c.0: calling quirk_resource_alignment+0x0/0x1bd
pci 0000:00:0c.0: PME# supported from D0 D1 D2 D3hot D3cold
pci 0000:00:0c.0: PME# disabled
pci 0000:00:0d.0: found [10de:005d] class 000604 header type 01
pci 0000:00:0d.0: calling quirk_resource_alignment+0x0/0x1bd
pci 0000:00:0d.0: PME# supported from D0 D1 D2 D3hot D3cold
pci 0000:00:0d.0: PME# disabled
pci 0000:00:0e.0: found [10de:005d] class 000604 header type 01
pci 0000:00:0e.0: calling quirk_resource_alignment+0x0/0x1bd
pci 0000:00:0e.0: PME# supported from D0 D1 D2 D3hot D3cold
pci 0000:00:0e.0: PME# disabled
pci 0000:00:18.0: found [1022:1100] class 000600 header type 00
pci 0000:00:18.0: calling quirk_resource_alignment+0x0/0x1bd
pci 0000:00:18.1: found [1022:1101] class 000600 header type 00
pci 0000:00:18.1: calling quirk_resource_alignment+0x0/0x1bd
pci 0000:00:18.2: found [1022:1102] class 000600 header type 00
pci 0000:00:18.2: calling quirk_resource_alignment+0x0/0x1bd
pci 0000:00:18.3: found [1022:1103] class 000600 header type 00
pci 0000:00:18.3: calling quirk_resource_alignment+0x0/0x1bd
PCI: Fixups for bus 0000:00
pci 0000:00:09.0: scanning behind bridge, config 050500, pass 0
PCI: Scanning bus 0000:05
pci 0000:05:07.0: found [10ec:8139] class 000200 header type 00
pci 0000:05:07.0: reg 10 io port: [0xc000-0xc0ff]
pci 0000:05:07.0: reg 14 32bit mmio: [0xda000000-0xda0000ff]
pci 0000:05:07.0: calling quirk_resource_alignment+0x0/0x1bd
pci 0000:05:07.0: supports D1 D2
pci 0000:05:07.0: PME# supported from D1 D2 D3hot
pci 0000:05:07.0: PME# disabled
PCI: Fixups for bus 0000:05
pci 0000:00:09.0: transparent bridge
pci 0000:00:09.0: bridge io port: [0xc000-0xcfff]
pci 0000:00:09.0: bridge 32bit mmio: [0xda000000-0xda0fffff]
PCI: Bus scan for 0000:05 returning with max=3D05
pci 0000:00:0b.0: scanning behind bridge, config 040400, pass 0
PCI: Scanning bus 0000:04
PCI: Fixups for bus 0000:04
PCI: Bus scan for 0000:04 returning with max=3D04
pci 0000:00:0c.0: scanning behind bridge, config 030300, pass 0
PCI: Scanning bus 0000:03
PCI: Fixups for bus 0000:03
PCI: Bus scan for 0000:03 returning with max=3D03
pci 0000:00:0d.0: scanning behind bridge, config 020200, pass 0
PCI: Scanning bus 0000:02
PCI: Fixups for bus 0000:02
PCI: Bus scan for 0000:02 returning with max=3D02
pci 0000:00:0e.0: scanning behind bridge, config 010100, pass 0
PCI: Scanning bus 0000:01
pci 0000:01:00.0: found [1002:5b60] class 000300 header type 00
pci 0000:01:00.0: calling quirk_no_ata_d3+0x0/0x22
pci 0000:01:00.0: reg 10 32bit mmio: [0xd0000000-0xd7ffffff]
pci 0000:01:00.0: reg 14 io port: [0xb000-0xb0ff]
pci 0000:01:00.0: reg 18 32bit mmio: [0xd9000000-0xd900ffff]
pci 0000:01:00.0: reg 30 32bit mmio: [0x000000-0x01ffff]
pci 0000:01:00.0: calling quirk_resource_alignment+0x0/0x1bd
pci 0000:01:00.0: supports D1 D2
pci 0000:01:00.1: found [1002:5b70] class 000380 header type 00
pci 0000:01:00.1: calling quirk_no_ata_d3+0x0/0x22
pci 0000:01:00.1: reg 10 32bit mmio: [0xd9010000-0xd901ffff]
pci 0000:01:00.1: calling quirk_resource_alignment+0x0/0x1bd
pci 0000:01:00.1: supports D1 D2
pci 0000:01:00.0: disabling ASPM on pre-1.1 PCIe device.  You can enabl=
e it with 'pcie_aspm=3Dforce'
PCI: Fixups for bus 0000:01
pci 0000:00:0e.0: bridge io port: [0xb000-0xbfff]
pci 0000:00:0e.0: bridge 32bit mmio: [0xd8000000-0xd9ffffff]
pci 0000:00:0e.0: bridge 64bit mmio pref: [0xd0000000-0xd7ffffff]
PCI: Bus scan for 0000:01 returning with max=3D01
pci 0000:00:09.0: scanning behind bridge, config 050500, pass 1
pci 0000:00:0b.0: scanning behind bridge, config 040400, pass 1
pci 0000:00:0c.0: scanning behind bridge, config 030300, pass 1
pci 0000:00:0d.0: scanning behind bridge, config 020200, pass 1
pci 0000:00:0e.0: scanning behind bridge, config 010100, pass 1
PCI: Bus scan for 0000:00 returning with max=3D05
pci 0000:00:00.0: default IRQ router [10de:005e]
initcall pci_subsys_init+0x0/0x150 returned 0 after 397135 usecs
calling  proto_init+0x0/0x12 @ 1
initcall proto_init+0x0/0x12 returned 0 after 0 usecs
calling  net_dev_init+0x0/0x1ec @ 1
initcall net_dev_init+0x0/0x1ec returned 0 after 3255 usecs
calling  neigh_init+0x0/0x71 @ 1
initcall neigh_init+0x0/0x71 returned 0 after 0 usecs
calling  fib_rules_init+0x0/0xa9 @ 1
initcall fib_rules_init+0x0/0xa9 returned 0 after 0 usecs
calling  pktsched_init+0x0/0xc4 @ 1
initcall pktsched_init+0x0/0xc4 returned 0 after 0 usecs
calling  tc_filter_init+0x0/0x4c @ 1
initcall tc_filter_init+0x0/0x4c returned 0 after 0 usecs
calling  tc_action_init+0x0/0x4c @ 1
initcall tc_action_init+0x0/0x4c returned 0 after 0 usecs
calling  genl_init+0x0/0xe9 @ 1
Clocksource tsc unstable (delta =3D 206294801 ns)
initcall genl_init+0x0/0xe9 returned 0 after 13020 usecs
calling  wanrouter_init+0x0/0x5a @ 1
Sangoma WANPIPE Router v1.1 (c) 1995-2000 Sangoma Technologies Inc.
initcall wanrouter_init+0x0/0x5a returned 0 after 3255 usecs
calling  bt_init+0x0/0x60 @ 1
Bluetooth: Core ver 2.15
NET: Registered protocol family 31
Bluetooth: HCI device and connection manager initialized
Bluetooth: HCI socket layer initialized
initcall bt_init+0x0/0x60 returned 0 after 13020 usecs
calling  atm_init+0x0/0xb9 @ 1
NET: Registered protocol family 8
NET: Registered protocol family 20
initcall atm_init+0x0/0xb9 returned 0 after 6510 usecs
calling  wireless_nlevent_init+0x0/0x41 @ 1
initcall wireless_nlevent_init+0x0/0x41 returned 0 after 0 usecs
calling  rfkill_init+0x0/0x91 @ 1
initcall rfkill_init+0x0/0x91 returned 0 after 0 usecs
calling  sysctl_init+0x0/0x4c @ 1
initcall sysctl_init+0x0/0x4c returned 0 after 0 usecs
calling  pci_iommu_init+0x0/0x2f @ 1
DMA-API: preallocated 32768 debug entries
DMA-API: debugging enabled by kernel config
initcall pci_iommu_init+0x0/0x2f returned 0 after 48828 usecs
calling  print_all_ICs+0x0/0x5bd @ 1

printing PIC contents
=2E.. PIC  IMR: fffa
=2E.. PIC  IRR: 0001
=2E.. PIC  ISR: 0001
=2E.. PIC ELCR: 0828

printing local APIC contents on CPU#0/0:
=2E.. APIC ID:      00000000 (0)
=2E.. APIC VERSION: 00040010
=2E.. APIC TASKPRI: 00000000 (00)
=2E.. APIC ARBPRI: 000000e0 (e0)
=2E.. APIC PROCPRI: 00000000
=2E.. APIC LDR: 01000000
=2E.. APIC DFR: ffffffff
=2E.. APIC SPIV: 000001ff
=2E.. APIC ISR field:
0123456789abcdef0123456789abcdef
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
=2E.. APIC TMR field:
0123456789abcdef0123456789abcdef
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
=2E.. APIC IRR field:
0123456789abcdef0123456789abcdef
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000010000000000000000
=2E.. APIC ESR: 00000000
=2E.. APIC ICR: 000008fd
=2E.. APIC ICR2: 02000000
=2E.. APIC LVTT: 000200ef
=2E.. APIC LVTPC: 00010000
=2E.. APIC LVT0: 00010700
=2E.. APIC LVT1: 00000400
=2E.. APIC LVTERR: 000000fe
=2E.. APIC TMICT: 0000a396
=2E.. APIC TMCCT: 0000276c
=2E.. APIC TDCR: 00000003


printing local APIC contents on CPU#1/1:
=2E.. APIC ID:      01000000 (1)
=2E.. APIC VERSION: 00040010
=2E.. APIC TASKPRI: 00000000 (00)
=2E.. APIC ARBPRI: 000000e0 (e0)
=2E.. APIC PROCPRI: 00000000
=2E.. APIC LDR: 02000000
=2E.. APIC DFR: ffffffff
=2E.. APIC SPIV: 000001ff
=2E.. APIC ISR field:
0123456789abcdef0123456789abcdef
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
=2E.. APIC TMR field:
0123456789abcdef0123456789abcdef
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
=2E.. APIC IRR field:
0123456789abcdef0123456789abcdef
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000010000000000000000
=2E.. APIC ESR: 00000000
=2E.. APIC ICR: 000008fd
=2E.. APIC ICR2: 01000000
=2E.. APIC LVTT: 000200ef
=2E.. APIC LVTPC: 00010000
=2E.. APIC LVT0: 00010700
=2E.. APIC LVT1: 00010400
=2E.. APIC LVTERR: 000000fe
=2E.. APIC TMICT: 0000a396
=2E.. APIC TMCCT: 00003190
=2E.. APIC TDCR: 00000003

number of MP IRQ sources: 17.
number of IO-APIC #2 registers: 24.
testing the IO APIC.......................

IO APIC #2......
=2E... register #00: 00000000
=2E......    : physical APIC id: 00
=2E......    : Delivery Type: 0
=2E......    : LTS          : 0
=2E... register #01: 00170011
=2E......     : max redirection entries: 0017
=2E......     : PRQ implemented: 0
=2E......     : IO APIC version: 0011
=2E... register #02: 00000000
=2E......     : arbitration: 00
=2E... IRQ redirection table:
 NR Dst Mask Trig IRR Pol Stat Dmod Deli Vect:  =20
 00 003 0    0    0   0   0    1    1    30
 01 003 0    0    0   0   0    1    1    31
 02 000 1    0    0   0   0    0    0    00
 03 003 1    1    0   1   0    1    1    33
 04 003 0    0    0   0   0    1    1    34
 05 003 1    1    0   1   0    1    1    35
 06 003 0    0    0   0   0    1    1    36
 07 003 1    0    0   0   0    1    1    37
 08 003 0    0    0   0   0    1    1    38
 09 003 0    0    0   0   0    1    1    39
 0a 003 0    0    0   0   0    1    1    3A
 0b 003 1    1    0   1   0    1    1    3B
 0c 003 0    0    0   0   0    1    1    3C
 0d 003 0    0    0   0   0    1    1    3D
 0e 003 0    0    0   0   0    1    1    3E
 0f 003 0    0    0   0   0    1    1    3F
 10 000 1    0    0   0   0    0    0    00
 11 000 1    0    0   0   0    0    0    00
 12 000 1    0    0   0   0    0    0    00
 13 000 1    0    0   0   0    0    0    00
 14 000 1    0    0   0   0    0    0    00
 15 000 1    0    0   0   0    0    0    00
 16 000 1    0    0   0   0    0    0    00
 17 000 1    0    0   0   0    0    0    00
IRQ to pin mappings:
IRQ0 -> 0:0
IRQ1 -> 0:1
IRQ3 -> 0:3
IRQ4 -> 0:4
IRQ5 -> 0:5
IRQ6 -> 0:6
IRQ7 -> 0:7
IRQ8 -> 0:8
IRQ9 -> 0:9
IRQ10 -> 0:10
IRQ11 -> 0:11
IRQ12 -> 0:12
IRQ13 -> 0:13
IRQ14 -> 0:14
IRQ15 -> 0:15
=2E................................... done.
initcall print_all_ICs+0x0/0x5bd returned 0 after 315755 usecs
calling  hpet_late_init+0x0/0xf0 @ 1
initcall hpet_late_init+0x0/0xf0 returned -19 after 0 usecs
calling  clocksource_done_booting+0x0/0x12 @ 1
initcall clocksource_done_booting+0x0/0x12 returned 0 after 0 usecs
calling  ftrace_init_debugfs+0x0/0x23f @ 1
initcall ftrace_init_debugfs+0x0/0x23f returned 0 after 0 usecs
calling  rb_init_debugfs+0x0/0x2f @ 1
initcall rb_init_debugfs+0x0/0x2f returned 0 after 0 usecs
calling  tracer_init_debugfs+0x0/0x353 @ 1
initcall tracer_init_debugfs+0x0/0x353 returned 0 after 0 usecs
calling  init_trace_printk_function_export+0x0/0x2f @ 1
initcall init_trace_printk_function_export+0x0/0x2f returned 0 after 0 =
usecs
calling  stat_workqueue_init+0x0/0x2f @ 1
initcall stat_workqueue_init+0x0/0x2f returned 0 after 0 usecs
calling  event_trace_init+0x0/0x557 @ 1
initcall event_trace_init+0x0/0x557 returned 0 after 6510 usecs
calling  init_pipe_fs+0x0/0x51 @ 1
initcall init_pipe_fs+0x0/0x51 returned 0 after 0 usecs
calling  eventpoll_init+0x0/0xfb @ 1
initcall eventpoll_init+0x0/0xfb returned 0 after 0 usecs
calling  anon_inode_init+0x0/0x12e @ 1
initcall anon_inode_init+0x0/0x12e returned 0 after 0 usecs
calling  fscache_init+0x0/0xc0 @ 1
Slow work thread pool: Starting up
Slow work thread pool: Ready
=46S-Cache: Loaded
initcall fscache_init+0x0/0xc0 returned 0 after 6510 usecs
calling  tomoyo_initerface_init+0x0/0x15f @ 1
initcall tomoyo_initerface_init+0x0/0x15f returned 0 after 0 usecs
calling  chr_dev_init+0x0/0xa3 @ 1
initcall chr_dev_init+0x0/0xa3 returned 0 after 0 usecs
calling  firmware_class_init+0x0/0x7f @ 1
initcall firmware_class_init+0x0/0x7f returned 0 after 0 usecs
calling  cpufreq_gov_performance_init+0x0/0x12 @ 1
initcall cpufreq_gov_performance_init+0x0/0x12 returned 0 after 0 usecs
calling  cpufreq_gov_dbs_init+0x0/0x6b @ 1
initcall cpufreq_gov_dbs_init+0x0/0x6b returned 0 after 0 usecs
calling  ssb_modinit+0x0/0x7a @ 1
initcall ssb_modinit+0x0/0x7a returned 0 after 0 usecs
calling  pcibios_assign_resources+0x0/0x8a @ 1
pci 0000:00:09.0: PCI bridge, secondary bus 0000:05
pci 0000:00:09.0:   IO window: 0xc000-0xcfff
pci 0000:00:09.0:   MEM window: 0xda000000-0xda0fffff
pci 0000:00:09.0:   PREFETCH window: disabled
pci 0000:00:0b.0: PCI bridge, secondary bus 0000:04
pci 0000:00:0b.0:   IO window: disabled
pci 0000:00:0b.0:   MEM window: disabled
pci 0000:00:0b.0:   PREFETCH window: disabled
pci 0000:00:0c.0: PCI bridge, secondary bus 0000:03
pci 0000:00:0c.0:   IO window: disabled
pci 0000:00:0c.0:   MEM window: disabled
pci 0000:00:0c.0:   PREFETCH window: disabled
pci 0000:00:0d.0: PCI bridge, secondary bus 0000:02
pci 0000:00:0d.0:   IO window: disabled
pci 0000:00:0d.0:   MEM window: disabled
pci 0000:00:0d.0:   PREFETCH window: disabled
pci 0000:01:00.0: BAR 6: got res [0xd8000000-0xd801ffff] bus [0xd800000=
0-0xd801ffff] flags 0x27200
pci 0000:00:0e.0: PCI bridge, secondary bus 0000:01
pci 0000:00:0e.0:   IO window: 0xb000-0xbfff
pci 0000:00:0e.0:   MEM window: 0xd8000000-0xd9ffffff
pci 0000:00:0e.0:   PREFETCH window: 0x000000d0000000-0x000000d7ffffff
pci 0000:00:09.0: setting latency timer to 64
pci 0000:00:0b.0: setting latency timer to 64
pci 0000:00:0c.0: setting latency timer to 64
pci 0000:00:0d.0: setting latency timer to 64
pci 0000:00:0e.0: setting latency timer to 64
pci_bus 0000:00: resource 0 io:  [0x00-0xffff]
pci_bus 0000:00: resource 1 mem: [0x000000-0xffffffffffffffff]
pci_bus 0000:05: resource 0 io:  [0xc000-0xcfff]
pci_bus 0000:05: resource 1 mem: [0xda000000-0xda0fffff]
pci_bus 0000:05: resource 3 io:  [0x00-0xffff]
pci_bus 0000:05: resource 4 mem: [0x000000-0xffffffffffffffff]
pci_bus 0000:01: resource 0 io:  [0xb000-0xbfff]
pci_bus 0000:01: resource 1 mem: [0xd8000000-0xd9ffffff]
pci_bus 0000:01: resource 2 pref mem [0xd0000000-0xd7ffffff]
initcall pcibios_assign_resources+0x0/0x8a returned 0 after 113932 usec=
s
calling  sysctl_core_init+0x0/0x38 @ 1
initcall sysctl_core_init+0x0/0x38 returned 0 after 0 usecs
calling  inet_init+0x0/0x2a6 @ 1
NET: Registered protocol family 2
IP route cache hash table entries: 32768 (order: 6, 262144 bytes)
TCP established hash table entries: 131072 (order: 9, 2097152 bytes)
TCP bind hash table entries: 32768 (order: 9, 2359296 bytes)
TCP: Hash tables configured (established 131072 bind 32768)
TCP reno registered
initcall inet_init+0x0/0x2a6 returned 0 after 22786 usecs
calling  af_unix_init+0x0/0x58 @ 1
NET: Registered protocol family 1
initcall af_unix_init+0x0/0x58 returned 0 after 3255 usecs
calling  default_rootfs+0x0/0x6e @ 1
initcall default_rootfs+0x0/0x6e returned 0 after 0 usecs
calling  calgary_fixup_tce_spaces+0x0/0xf8 @ 1
initcall calgary_fixup_tce_spaces+0x0/0xf8 returned -19 after 0 usecs
calling  i8259A_init_sysfs+0x0/0x29 @ 1
initcall i8259A_init_sysfs+0x0/0x29 returned 0 after 0 usecs
calling  vsyscall_init+0x0/0x6c @ 1
initcall vsyscall_init+0x0/0x6c returned 0 after 0 usecs
calling  sbf_init+0x0/0x109 @ 1
initcall sbf_init+0x0/0x109 returned 0 after 0 usecs
calling  i8237A_init_sysfs+0x0/0x29 @ 1
initcall i8237A_init_sysfs+0x0/0x29 returned 0 after 0 usecs
calling  add_rtc_cmos+0x0/0x45 @ 1
platform rtc_cmos: registered platform RTC device (no PNP device found)
initcall add_rtc_cmos+0x0/0x45 returned 0 after 3255 usecs
calling  cache_sysfs_init+0x0/0xa4 @ 1
initcall cache_sysfs_init+0x0/0xa4 returned 0 after 0 usecs
calling  cpu_debug_init+0x0/0x297 @ 1
cpu0(2) debug files 137
cpu1(2) debug files 137
initcall cpu_debug_init+0x0/0x297 returned 0 after 9765 usecs
calling  cpuid_init+0x0/0x1c0 @ 1
initcall cpuid_init+0x0/0x1c0 returned 0 after 3255 usecs
calling  ioapic_init_sysfs+0x0/0xd2 @ 1
initcall ioapic_init_sysfs+0x0/0xd2 returned 0 after 0 usecs
calling  add_pcspkr+0x0/0x2a @ 1
initcall add_pcspkr+0x0/0x2a returned 0 after 0 usecs
calling  start_periodic_check_for_corruption+0x0/0x40 @ 1
Scanning for low memory corruption every 60 seconds
initcall start_periodic_check_for_corruption+0x0/0x40 returned 0 after =
3255 usecs
calling  start_pageattr_test+0x0/0x60 @ 1
initcall start_pageattr_test+0x0/0x60 returned 0 after 0 usecs
calling  crypto_fpu_module_init+0x0/0x12 @ 1
initcall crypto_fpu_module_init+0x0/0x12 returned 0 after 0 usecs
calling  aes_init+0x0/0x12 @ 1
initcall aes_init+0x0/0x12 returned 0 after 0 usecs
calling  init+0x0/0x12 @ 1
initcall init+0x0/0x12 returned 0 after 0 usecs
calling  aesni_init+0x0/0x14a @ 1
Intel AES-NI instructions are not detected.
initcall aesni_init+0x0/0x14a returned -19 after 3255 usecs
calling  crc32c_intel_mod_init+0x0/0x30 @ 1
initcall crc32c_intel_mod_init+0x0/0x30 returned -19 after 0 usecs
calling  init_vdso_vars+0x0/0x241 @ 1
initcall init_vdso_vars+0x0/0x241 returned 0 after 0 usecs
calling  ia32_binfmt_init+0x0/0x14 @ 1
initcall ia32_binfmt_init+0x0/0x14 returned 0 after 0 usecs
calling  sysenter_setup+0x0/0x372 @ 1
initcall sysenter_setup+0x0/0x372 returned 0 after 0 usecs
calling  proc_schedstat_init+0x0/0x22 @ 1
initcall proc_schedstat_init+0x0/0x22 returned 0 after 0 usecs
calling  proc_execdomains_init+0x0/0x27 @ 1
initcall proc_execdomains_init+0x0/0x27 returned 0 after 0 usecs
calling  ioresources_init+0x0/0x3c @ 1
initcall ioresources_init+0x0/0x3c returned 0 after 0 usecs
calling  uid_cache_init+0x0/0x8d @ 1
initcall uid_cache_init+0x0/0x8d returned 0 after 0 usecs
calling  init_posix_timers+0x0/0xe8 @ 1
initcall init_posix_timers+0x0/0xe8 returned 0 after 0 usecs
calling  init_posix_cpu_timers+0x0/0xb3 @ 1
initcall init_posix_cpu_timers+0x0/0xb3 returned 0 after 0 usecs
calling  nsproxy_cache_init+0x0/0x33 @ 1
initcall nsproxy_cache_init+0x0/0x33 returned 0 after 0 usecs
calling  create_proc_profile+0x0/0x310 @ 1
initcall create_proc_profile+0x0/0x310 returned 0 after 0 usecs
calling  timekeeping_init_device+0x0/0x29 @ 1
initcall timekeeping_init_device+0x0/0x29 returned 0 after 0 usecs
calling  init_clocksource_sysfs+0x0/0x52 @ 1
initcall init_clocksource_sysfs+0x0/0x52 returned 0 after 0 usecs
calling  init_timer_list_procfs+0x0/0x2c @ 1
initcall init_timer_list_procfs+0x0/0x2c returned 0 after 0 usecs
calling  lockdep_proc_init+0x0/0x5f @ 1
initcall lockdep_proc_init+0x0/0x5f returned 0 after 0 usecs
calling  futex_init+0x0/0xd5 @ 1
initcall futex_init+0x0/0xd5 returned 0 after 0 usecs
calling  proc_dma_init+0x0/0x22 @ 1
initcall proc_dma_init+0x0/0x22 returned 0 after 0 usecs
calling  kallsyms_init+0x0/0x32 @ 1
initcall kallsyms_init+0x0/0x32 returned 0 after 0 usecs
calling  crash_save_vmcoreinfo_init+0x0/0x4a5 @ 1
initcall crash_save_vmcoreinfo_init+0x0/0x4a5 returned 0 after 3255 use=
cs
calling  crash_notes_memory_init+0x0/0x3a @ 1
initcall crash_notes_memory_init+0x0/0x3a returned 0 after 0 usecs
calling  pid_namespaces_init+0x0/0x2d @ 1
initcall pid_namespaces_init+0x0/0x2d returned 0 after 0 usecs
calling  hung_task_init+0x0/0x56 @ 1
initcall hung_task_init+0x0/0x56 returned 0 after 0 usecs
calling  rcu_torture_init+0x0/0x7b8 @ 1
rcu-torture:--- Start of test: nreaders=3D4 nfakewriters=3D4 stat_inter=
val=3D0 verbose=3D0 test_no_idle_hz=3D0 shuffle_interval=3D3 stutter=3D=
5 irqreader=3D1
initcall rcu_torture_init+0x0/0x7b8 returned 0 after 3255 usecs
calling  utsname_sysctl_init+0x0/0x14 @ 1
sysctl table check failed: /kernel/ostype .1.1 No proc_handler
Pid: 1, comm: swapper Not tainted 2.6.30-tip #54077
Call Trace:
 [<ffffffff810782f5>] set_fail+0x65/0x70
 [<ffffffff8107868c>] sysctl_check_table+0x38c/0x710
 [<ffffffff810786a5>] sysctl_check_table+0x3a5/0x710
 [<ffffffff8105d08c>] ? sysctl_set_parent+0xc/0x50
 [<ffffffff8105dc2c>] __register_sysctl_paths+0x10c/0x350
 [<ffffffff8107b019>] ? jiffies_read+0x9/0x20
 [<ffffffff8251630a>] ? utsname_sysctl_init+0x0/0x14
 [<ffffffff8105de9e>] register_sysctl_paths+0x2e/0x30
 [<ffffffff8105deb8>] register_sysctl_table+0x18/0x20
 [<ffffffff8251631a>] utsname_sysctl_init+0x10/0x14
 [<ffffffff8100904f>] do_one_initcall+0x3f/0x1d0
 [<ffffffff8151a441>] ? ida_get_new_above+0x151/0x220
 [<ffffffff810f8e95>] ? check_object+0x265/0x270
 [<ffffffff81014b10>] ? native_sched_clock+0x20/0x80
 [<ffffffff81014b83>] ? sched_clock+0x13/0x30
 [<ffffffff81080e4f>] ? __lock_acquire+0x14f/0xd20
 [<ffffffff8151a441>] ? ida_get_new_above+0x151/0x220
 [<ffffffff8151a441>] ? ida_get_new_above+0x151/0x220
 [<ffffffff81014b10>] ? native_sched_clock+0x20/0x80
 [<ffffffff81014b83>] ? sched_clock+0x13/0x30
 [<ffffffff81080015>] ? lock_release_holdtime+0x35/0x210
 [<ffffffff81533eb5>] ? _raw_spin_unlock+0xa5/0xc0
 [<ffffffff81d4266b>] ? _spin_unlock+0x2b/0x40
 [<ffffffff8115a194>] ? proc_register+0x124/0x210
 [<ffffffff8115a3ae>] ? create_proc_entry+0x5e/0xb0
 [<ffffffff8109df76>] ? register_irq_proc+0xc6/0xe0
 [<ffffffff81150000>] ? dqget+0xa0/0x390
 [<ffffffff8109a939>] ? irq_to_desc+0x9/0x30
 [<ffffffff8250074b>] kernel_init+0x1a8/0x22c
 [<ffffffff8100d50a>] child_rip+0xa/0x20
 [<ffffffff8100ce90>] ? restore_args+0x0/0x30
 [<ffffffff825005a3>] ? kernel_init+0x0/0x22c
 [<ffffffff8100d500>] ? child_rip+0x0/0x20
sysctl table check failed: /kernel/osrelease .1.2 No proc_handler
Pid: 1, comm: swapper Not tainted 2.6.30-tip #54077
Call Trace:
 [<ffffffff810782f5>] set_fail+0x65/0x70
 [<ffffffff8107868c>] sysctl_check_table+0x38c/0x710
 [<ffffffff810786a5>] sysctl_check_table+0x3a5/0x710
 [<ffffffff8105d08c>] ? sysctl_set_parent+0xc/0x50
 [<ffffffff8105dc2c>] __register_sysctl_paths+0x10c/0x350
 [<ffffffff8107b019>] ? jiffies_read+0x9/0x20
 [<ffffffff8251630a>] ? utsname_sysctl_init+0x0/0x14
 [<ffffffff8105de9e>] register_sysctl_paths+0x2e/0x30
 [<ffffffff8105deb8>] register_sysctl_table+0x18/0x20
 [<ffffffff8251631a>] utsname_sysctl_init+0x10/0x14
 [<ffffffff8100904f>] do_one_initcall+0x3f/0x1d0
 [<ffffffff8151a441>] ? ida_get_new_above+0x151/0x220
 [<ffffffff810f8e95>] ? check_object+0x265/0x270
 [<ffffffff81014b10>] ? native_sched_clock+0x20/0x80
 [<ffffffff81014b83>] ? sched_clock+0x13/0x30
 [<ffffffff81080e4f>] ? __lock_acquire+0x14f/0xd20
 [<ffffffff8151a441>] ? ida_get_new_above+0x151/0x220
 [<ffffffff8151a441>] ? ida_get_new_above+0x151/0x220
 [<ffffffff81014b10>] ? native_sched_clock+0x20/0x80
 [<ffffffff81014b83>] ? sched_clock+0x13/0x30
 [<ffffffff81080015>] ? lock_release_holdtime+0x35/0x210
 [<ffffffff81533eb5>] ? _raw_spin_unlock+0xa5/0xc0
 [<ffffffff81d4266b>] ? _spin_unlock+0x2b/0x40
 [<ffffffff8115a194>] ? proc_register+0x124/0x210
 [<ffffffff8115a3ae>] ? create_proc_entry+0x5e/0xb0
 [<ffffffff8109df76>] ? register_irq_proc+0xc6/0xe0
 [<ffffffff81150000>] ? dqget+0xa0/0x390
 [<ffffffff8109a939>] ? irq_to_desc+0x9/0x30
 [<ffffffff8250074b>] kernel_init+0x1a8/0x22c
 [<ffffffff8100d50a>] child_rip+0xa/0x20
 [<ffffffff8100ce90>] ? restore_args+0x0/0x30
 [<ffffffff825005a3>] ? kernel_init+0x0/0x22c
 [<ffffffff8100d500>] ? child_rip+0x0/0x20
sysctl table check failed: /kernel/version .1.4 No proc_handler
Pid: 1, comm: swapper Not tainted 2.6.30-tip #54077
Call Trace:
 [<ffffffff810782f5>] set_fail+0x65/0x70
 [<ffffffff8107868c>] sysctl_check_table+0x38c/0x710
 [<ffffffff810786a5>] sysctl_check_table+0x3a5/0x710
 [<ffffffff8105d08c>] ? sysctl_set_parent+0xc/0x50
 [<ffffffff8105dc2c>] __register_sysctl_paths+0x10c/0x350
 [<ffffffff8107b019>] ? jiffies_read+0x9/0x20
 [<ffffffff8251630a>] ? utsname_sysctl_init+0x0/0x14
 [<ffffffff8105de9e>] register_sysctl_paths+0x2e/0x30
 [<ffffffff8105deb8>] register_sysctl_table+0x18/0x20
 [<ffffffff8251631a>] utsname_sysctl_init+0x10/0x14
 [<ffffffff8100904f>] do_one_initcall+0x3f/0x1d0
 [<ffffffff8151a441>] ? ida_get_new_above+0x151/0x220
 [<ffffffff810f8e95>] ? check_object+0x265/0x270
 [<ffffffff81014b10>] ? native_sched_clock+0x20/0x80
 [<ffffffff81014b83>] ? sched_clock+0x13/0x30
 [<ffffffff81080e4f>] ? __lock_acquire+0x14f/0xd20
 [<ffffffff8151a441>] ? ida_get_new_above+0x151/0x220
 [<ffffffff8151a441>] ? ida_get_new_above+0x151/0x220
 [<ffffffff81014b10>] ? native_sched_clock+0x20/0x80
 [<ffffffff81014b83>] ? sched_clock+0x13/0x30
 [<ffffffff81080015>] ? lock_release_holdtime+0x35/0x210
 [<ffffffff81533eb5>] ? _raw_spin_unlock+0xa5/0xc0
 [<ffffffff81d4266b>] ? _spin_unlock+0x2b/0x40
 [<ffffffff8115a194>] ? proc_register+0x124/0x210
 [<ffffffff8115a3ae>] ? create_proc_entry+0x5e/0xb0
 [<ffffffff8109df76>] ? register_irq_proc+0xc6/0xe0
 [<ffffffff81150000>] ? dqget+0xa0/0x390
 [<ffffffff8109a939>] ? irq_to_desc+0x9/0x30
 [<ffffffff8250074b>] kernel_init+0x1a8/0x22c
 [<ffffffff8100d50a>] child_rip+0xa/0x20
 [<ffffffff8100ce90>] ? restore_args+0x0/0x30
 [<ffffffff825005a3>] ? kernel_init+0x0/0x22c
 [<ffffffff8100d500>] ? child_rip+0x0/0x20
sysctl table check failed: /kernel/hostname .1.7 No proc_handler
Pid: 1, comm: swapper Not tainted 2.6.30-tip #54077
Call Trace:
 [<ffffffff810782f5>] set_fail+0x65/0x70
 [<ffffffff8107868c>] sysctl_check_table+0x38c/0x710
 [<ffffffff810786a5>] sysctl_check_table+0x3a5/0x710
 [<ffffffff8105d08c>] ? sysctl_set_parent+0xc/0x50
 [<ffffffff8105dc2c>] __register_sysctl_paths+0x10c/0x350
 [<ffffffff8107b019>] ? jiffies_read+0x9/0x20
 [<ffffffff8251630a>] ? utsname_sysctl_init+0x0/0x14
 [<ffffffff8105de9e>] register_sysctl_paths+0x2e/0x30
 [<ffffffff8105deb8>] register_sysctl_table+0x18/0x20
 [<ffffffff8251631a>] utsname_sysctl_init+0x10/0x14
 [<ffffffff8100904f>] do_one_initcall+0x3f/0x1d0
 [<ffffffff8151a441>] ? ida_get_new_above+0x151/0x220
 [<ffffffff810f8e95>] ? check_object+0x265/0x270
 [<ffffffff81014b10>] ? native_sched_clock+0x20/0x80
 [<ffffffff81014b83>] ? sched_clock+0x13/0x30
 [<ffffffff81080e4f>] ? __lock_acquire+0x14f/0xd20
 [<ffffffff8151a441>] ? ida_get_new_above+0x151/0x220
 [<ffffffff8151a441>] ? ida_get_new_above+0x151/0x220
 [<ffffffff81014b10>] ? native_sched_clock+0x20/0x80
 [<ffffffff81014b83>] ? sched_clock+0x13/0x30
 [<ffffffff81080015>] ? lock_release_holdtime+0x35/0x210
 [<ffffffff81533eb5>] ? _raw_spin_unlock+0xa5/0xc0
 [<ffffffff81d4266b>] ? _spin_unlock+0x2b/0x40
 [<ffffffff8115a194>] ? proc_register+0x124/0x210
 [<ffffffff8115a3ae>] ? create_proc_entry+0x5e/0xb0
 [<ffffffff8109df76>] ? register_irq_proc+0xc6/0xe0
 [<ffffffff81150000>] ? dqget+0xa0/0x390
 [<ffffffff8109a939>] ? irq_to_desc+0x9/0x30
 [<ffffffff8250074b>] kernel_init+0x1a8/0x22c
 [<ffffffff8100d50a>] child_rip+0xa/0x20
 [<ffffffff8100ce90>] ? restore_args+0x0/0x30
 [<ffffffff825005a3>] ? kernel_init+0x0/0x22c
 [<ffffffff8100d500>] ? child_rip+0x0/0x20
sysctl table check failed: /kernel/domainname .1.8 No proc_handler
Pid: 1, comm: swapper Not tainted 2.6.30-tip #54077
Call Trace:
 [<ffffffff810782f5>] set_fail+0x65/0x70
 [<ffffffff8107868c>] sysctl_check_table+0x38c/0x710
 [<ffffffff810786a5>] sysctl_check_table+0x3a5/0x710
 [<ffffffff8105d08c>] ? sysctl_set_parent+0xc/0x50
 [<ffffffff8105dc2c>] __register_sysctl_paths+0x10c/0x350
 [<ffffffff8107b019>] ? jiffies_read+0x9/0x20
 [<ffffffff8251630a>] ? utsname_sysctl_init+0x0/0x14
 [<ffffffff8105de9e>] register_sysctl_paths+0x2e/0x30
 [<ffffffff8105deb8>] register_sysctl_table+0x18/0x20
 [<ffffffff8251631a>] utsname_sysctl_init+0x10/0x14
 [<ffffffff8100904f>] do_one_initcall+0x3f/0x1d0
 [<ffffffff8151a441>] ? ida_get_new_above+0x151/0x220
 [<ffffffff810f8e95>] ? check_object+0x265/0x270
 [<ffffffff81014b10>] ? native_sched_clock+0x20/0x80
 [<ffffffff81014b83>] ? sched_clock+0x13/0x30
 [<ffffffff81080e4f>] ? __lock_acquire+0x14f/0xd20
 [<ffffffff8151a441>] ? ida_get_new_above+0x151/0x220
 [<ffffffff8151a441>] ? ida_get_new_above+0x151/0x220
 [<ffffffff81014b10>] ? native_sched_clock+0x20/0x80
 [<ffffffff81014b83>] ? sched_clock+0x13/0x30
 [<ffffffff81080015>] ? lock_release_holdtime+0x35/0x210
 [<ffffffff81533eb5>] ? _raw_spin_unlock+0xa5/0xc0
 [<ffffffff81d4266b>] ? _spin_unlock+0x2b/0x40
 [<ffffffff8115a194>] ? proc_register+0x124/0x210
 [<ffffffff8115a3ae>] ? create_proc_entry+0x5e/0xb0
 [<ffffffff8109df76>] ? register_irq_proc+0xc6/0xe0
 [<ffffffff81150000>] ? dqget+0xa0/0x390
 [<ffffffff8109a939>] ? irq_to_desc+0x9/0x30
 [<ffffffff8250074b>] kernel_init+0x1a8/0x22c
 [<ffffffff8100d50a>] child_rip+0xa/0x20
 [<ffffffff8100ce90>] ? restore_args+0x0/0x30
 [<ffffffff825005a3>] ? kernel_init+0x0/0x22c
 [<ffffffff8100d500>] ? child_rip+0x0/0x20
initcall utsname_sysctl_init+0x0/0x14 returned 0 after 585937 usecs
calling  ftrace_nodyn_init+0x0/0x12 @ 1
initcall ftrace_nodyn_init+0x0/0x12 returned 0 after 0 usecs
calling  init_events+0x0/0x70 @ 1
initcall init_events+0x0/0x70 returned 0 after 0 usecs
calling  init_sched_switch_trace+0x0/0x12 @ 1
initcall init_sched_switch_trace+0x0/0x12 returned 0 after 0 usecs
calling  init_function_trace+0x0/0x12 @ 1
initcall init_function_trace+0x0/0x12 returned 0 after 0 usecs
calling  init_irqsoff_tracer+0x0/0x1e @ 1
initcall init_irqsoff_tracer+0x0/0x1e returned 0 after 0 usecs
calling  init_wakeup_tracer+0x0/0x29 @ 1
initcall init_wakeup_tracer+0x0/0x29 returned 0 after 0 usecs
calling  stack_trace_init+0x0/0x6f @ 1
initcall stack_trace_init+0x0/0x6f returned 0 after 0 usecs
calling  init_mmio_trace+0x0/0x12 @ 1
initcall init_mmio_trace+0x0/0x12 returned 0 after 0 usecs
calling  init_graph_trace+0x0/0x12 @ 1
initcall init_graph_trace+0x0/0x12 returned 0 after 0 usecs
calling  init_blk_tracer+0x0/0x6c @ 1
initcall init_blk_tracer+0x0/0x6c returned 0 after 0 usecs
calling  register_ftrace_syscalls+0x0/0xa4 @ 1
initcall register_ftrace_syscalls+0x0/0xa4 returned 0 after 0 usecs
calling  perf_counter_sysfs_init+0x0/0x19 @ 1
initcall perf_counter_sysfs_init+0x0/0x19 returned 0 after 0 usecs
calling  init_per_zone_pages_min+0x0/0x96 @ 1
initcall init_per_zone_pages_min+0x0/0x96 returned 0 after 0 usecs
calling  pdflush_init+0x0/0x1c @ 1
initcall pdflush_init+0x0/0x1c returned 0 after 0 usecs
calling  kswapd_init+0x0/0x20 @ 1
initcall kswapd_init+0x0/0x20 returned 0 after 0 usecs
calling  init_tmpfs+0x0/0x3d @ 1
initcall init_tmpfs+0x0/0x3d returned 0 after 0 usecs
calling  setup_vmstat+0x0/0x108 @ 1
initcall setup_vmstat+0x0/0x108 returned 0 after 0 usecs
calling  mm_sysfs_init+0x0/0x29 @ 1
initcall mm_sysfs_init+0x0/0x29 returned 0 after 0 usecs
calling  proc_vmalloc_init+0x0/0x25 @ 1
initcall proc_vmalloc_init+0x0/0x25 returned 0 after 0 usecs
calling  procswaps_init+0x0/0x25 @ 1
initcall procswaps_init+0x0/0x25 returned 0 after 0 usecs
calling  hugetlb_init+0x0/0x458 @ 1
HugeTLB registered 2 MB page size, pre-allocated 0 pages
initcall hugetlb_init+0x0/0x458 returned 0 after 3255 usecs
calling  slab_proc_init+0x0/0x25 @ 1
initcall slab_proc_init+0x0/0x25 returned 0 after 0 usecs
calling  slab_sysfs_init+0x0/0x104 @ 1
initcall slab_sysfs_init+0x0/0x104 returned 0 after 22786 usecs
calling  fasync_init+0x0/0x37 @ 1
initcall fasync_init+0x0/0x37 returned 0 after 0 usecs
calling  proc_filesystems_init+0x0/0x22 @ 1
initcall proc_filesystems_init+0x0/0x22 returned 0 after 0 usecs
calling  inotify_setup+0x0/0x12 @ 1
initcall inotify_setup+0x0/0x12 returned 0 after 0 usecs
calling  proc_locks_init+0x0/0x22 @ 1
initcall proc_locks_init+0x0/0x22 returned 0 after 0 usecs
calling  init_sys32_ioctl+0x0/0x88 @ 1
initcall init_sys32_ioctl+0x0/0x88 returned 0 after 0 usecs
calling  init_mbcache+0x0/0x14 @ 1
initcall init_mbcache+0x0/0x14 returned 0 after 0 usecs
calling  dquot_init+0x0/0xe6 @ 1
VFS: Disk quotas dquot_6.5.2
Dquot-cache hash table entries: 512 (order 0, 4096 bytes)
initcall dquot_init+0x0/0xe6 returned 0 after 6510 usecs
calling  init_v2_quota_format+0x0/0x14 @ 1
initcall init_v2_quota_format+0x0/0x14 returned 0 after 0 usecs
calling  proc_cmdline_init+0x0/0x22 @ 1
initcall proc_cmdline_init+0x0/0x22 returned 0 after 0 usecs
calling  proc_cpuinfo_init+0x0/0x22 @ 1
initcall proc_cpuinfo_init+0x0/0x22 returned 0 after 0 usecs
calling  proc_devices_init+0x0/0x22 @ 1
initcall proc_devices_init+0x0/0x22 returned 0 after 0 usecs
calling  proc_interrupts_init+0x0/0x22 @ 1
initcall proc_interrupts_init+0x0/0x22 returned 0 after 0 usecs
calling  proc_loadavg_init+0x0/0x22 @ 1
initcall proc_loadavg_init+0x0/0x22 returned 0 after 0 usecs
calling  proc_meminfo_init+0x0/0x22 @ 1
initcall proc_meminfo_init+0x0/0x22 returned 0 after 0 usecs
calling  proc_stat_init+0x0/0x22 @ 1
initcall proc_stat_init+0x0/0x22 returned 0 after 0 usecs
calling  proc_uptime_init+0x0/0x22 @ 1
initcall proc_uptime_init+0x0/0x22 returned 0 after 0 usecs
calling  proc_version_init+0x0/0x22 @ 1
initcall proc_version_init+0x0/0x22 returned 0 after 0 usecs
calling  vmcore_init+0x0/0xa70 @ 1
initcall vmcore_init+0x0/0xa70 returned 0 after 0 usecs
calling  proc_kmsg_init+0x0/0x25 @ 1
initcall proc_kmsg_init+0x0/0x25 returned 0 after 0 usecs
calling  configfs_init+0x0/0xd6 @ 1
initcall configfs_init+0x0/0xd6 returned 0 after 0 usecs
calling  init_devpts_fs+0x0/0x5d @ 1
initcall init_devpts_fs+0x0/0x5d returned 0 after 0 usecs
calling  init_dlm+0x0/0xb3 @ 1
DLM (built Jun 16 2009 12:02:48) installed
initcall init_dlm+0x0/0xb3 returned 0 after 3255 usecs
calling  init_reiserfs_fs+0x0/0x8b @ 1
initcall init_reiserfs_fs+0x0/0x8b returned 0 after 0 usecs
calling  init_ext3_fs+0x0/0x72 @ 1
initcall init_ext3_fs+0x0/0x72 returned 0 after 0 usecs
calling  init_ext4_fs+0x0/0x10d @ 1
initcall init_ext4_fs+0x0/0x10d returned 0 after 3255 usecs
calling  journal_init+0x0/0xea @ 1
initcall journal_init+0x0/0xea returned 0 after 3255 usecs
calling  journal_init+0x0/0xfb @ 1
initcall journal_init+0x0/0xfb returned 0 after 3255 usecs
calling  init_squashfs_fs+0x0/0x70 @ 1
squashfs: version 4.0 (2009/01/31) Phillip Lougher
initcall init_squashfs_fs+0x0/0x70 returned 0 after 3255 usecs
calling  init_ramfs_fs+0x0/0x12 @ 1
initcall init_ramfs_fs+0x0/0x12 returned 0 after 0 usecs
calling  init_hugetlbfs_fs+0x0/0xad @ 1
initcall init_hugetlbfs_fs+0x0/0xad returned 0 after 0 usecs
calling  init_fat_fs+0x0/0x54 @ 1
initcall init_fat_fs+0x0/0x54 returned 0 after 0 usecs
calling  init_vfat_fs+0x0/0x12 @ 1
initcall init_vfat_fs+0x0/0x12 returned 0 after 0 usecs
calling  init_bfs_fs+0x0/0x62 @ 1
initcall init_bfs_fs+0x0/0x62 returned 0 after 0 usecs
calling  init_iso9660_fs+0x0/0x72 @ 1
initcall init_iso9660_fs+0x0/0x72 returned 0 after 0 usecs
calling  init_hfsplus_fs+0x0/0x60 @ 1
initcall init_hfsplus_fs+0x0/0x60 returned 0 after 0 usecs
calling  init_hfs_fs+0x0/0x60 @ 1
initcall init_hfs_fs+0x0/0x60 returned 0 after 0 usecs
calling  ecryptfs_init+0x0/0x1db @ 1
initcall ecryptfs_init+0x0/0x1db returned 0 after 3255 usecs
calling  vxfs_init+0x0/0x66 @ 1
initcall vxfs_init+0x0/0x66 returned 0 after 0 usecs
calling  init_nfs_fs+0x0/0x158 @ 1
initcall init_nfs_fs+0x0/0x158 returned 0 after 3255 usecs
calling  init_nfsd+0x0/0x10a @ 1
Installing knfsd (copyright (C) 1996 okir@monad.swb.de).
initcall init_nfsd+0x0/0x10a returned 0 after 6510 usecs
calling  init_nlm+0x0/0x22 @ 1
initcall init_nlm+0x0/0x22 returned 0 after 0 usecs
calling  init_nls_cp775+0x0/0x12 @ 1
initcall init_nls_cp775+0x0/0x12 returned 0 after 0 usecs
calling  init_nls_cp850+0x0/0x12 @ 1
initcall init_nls_cp850+0x0/0x12 returned 0 after 0 usecs
calling  init_nls_cp852+0x0/0x12 @ 1
initcall init_nls_cp852+0x0/0x12 returned 0 after 0 usecs
calling  init_nls_cp855+0x0/0x12 @ 1
initcall init_nls_cp855+0x0/0x12 returned 0 after 0 usecs
calling  init_nls_cp857+0x0/0x12 @ 1
initcall init_nls_cp857+0x0/0x12 returned 0 after 0 usecs
calling  init_nls_cp860+0x0/0x12 @ 1
initcall init_nls_cp860+0x0/0x12 returned 0 after 0 usecs
calling  init_nls_cp861+0x0/0x12 @ 1
initcall init_nls_cp861+0x0/0x12 returned 0 after 0 usecs
calling  init_nls_cp863+0x0/0x12 @ 1
initcall init_nls_cp863+0x0/0x12 returned 0 after 0 usecs
calling  init_nls_cp864+0x0/0x12 @ 1
initcall init_nls_cp864+0x0/0x12 returned 0 after 0 usecs
calling  init_nls_cp865+0x0/0x12 @ 1
initcall init_nls_cp865+0x0/0x12 returned 0 after 0 usecs
calling  init_nls_cp866+0x0/0x12 @ 1
initcall init_nls_cp866+0x0/0x12 returned 0 after 0 usecs
calling  init_nls_cp869+0x0/0x12 @ 1
initcall init_nls_cp869+0x0/0x12 returned 0 after 0 usecs
calling  init_nls_cp874+0x0/0x12 @ 1
initcall init_nls_cp874+0x0/0x12 returned 0 after 0 usecs
calling  init_nls_cp932+0x0/0x12 @ 1
initcall init_nls_cp932+0x0/0x12 returned 0 after 0 usecs
calling  init_nls_euc_jp+0x0/0x48 @ 1
initcall init_nls_euc_jp+0x0/0x48 returned 0 after 0 usecs
calling  init_nls_cp950+0x0/0x12 @ 1
initcall init_nls_cp950+0x0/0x12 returned 0 after 0 usecs
calling  init_nls_cp1251+0x0/0x12 @ 1
initcall init_nls_cp1251+0x0/0x12 returned 0 after 0 usecs
calling  init_nls_ascii+0x0/0x12 @ 1
initcall init_nls_ascii+0x0/0x12 returned 0 after 0 usecs
calling  init_nls_iso8859_4+0x0/0x12 @ 1
initcall init_nls_iso8859_4+0x0/0x12 returned 0 after 0 usecs
calling  init_nls_iso8859_14+0x0/0x12 @ 1
initcall init_nls_iso8859_14+0x0/0x12 returned 0 after 0 usecs
calling  init_nls_iso8859_15+0x0/0x12 @ 1
initcall init_nls_iso8859_15+0x0/0x12 returned 0 after 0 usecs
calling  init_nls_koi8_u+0x0/0x12 @ 1
initcall init_nls_koi8_u+0x0/0x12 returned 0 after 0 usecs
calling  init_nls_koi8_ru+0x0/0x48 @ 1
initcall init_nls_koi8_ru+0x0/0x48 returned 0 after 0 usecs
calling  init_nls_utf8+0x0/0x26 @ 1
initcall init_nls_utf8+0x0/0x26 returned 0 after 0 usecs
calling  init_sysv_fs+0x0/0x54 @ 1
initcall init_sysv_fs+0x0/0x54 returned 0 after 0 usecs
calling  init_cifs+0x0/0x509 @ 1
initcall init_cifs+0x0/0x509 returned 0 after 0 usecs
calling  init_ncp_fs+0x0/0x62 @ 1
initcall init_ncp_fs+0x0/0x62 returned 0 after 0 usecs
calling  init_hpfs_fs+0x0/0x62 @ 1
initcall init_hpfs_fs+0x0/0x62 returned 0 after 0 usecs
calling  init_ntfs_fs+0x0/0x247 @ 1
NTFS driver 2.1.29 [Flags: R/W DEBUG].
initcall init_ntfs_fs+0x0/0x247 returned 0 after 3255 usecs
calling  init_efs_fs+0x0/0x70 @ 1
EFS: 1.0a - http://aeschi.ch.eu.org/efs/
initcall init_efs_fs+0x0/0x70 returned 0 after 3255 usecs
calling  init_affs_fs+0x0/0x62 @ 1
initcall init_affs_fs+0x0/0x62 returned 0 after 0 usecs
calling  init_romfs_fs+0x0/0x8c @ 1
ROMFS MTD (C) 2007 Red Hat, Inc.
initcall init_romfs_fs+0x0/0x8c returned 0 after 3255 usecs
calling  init_qnx4_fs+0x0/0x70 @ 1
QNX4 filesystem 0.2.3 registered.
initcall init_qnx4_fs+0x0/0x70 returned 0 after 3255 usecs
calling  init_autofs_fs+0x0/0x12 @ 1
initcall init_autofs_fs+0x0/0x12 returned 0 after 0 usecs
calling  init_autofs4_fs+0x0/0x29 @ 1
initcall init_autofs4_fs+0x0/0x29 returned -16 after 0 usecs
initcall init_autofs4_fs+0x0/0x29 returned with error code -16=20
calling  init_adfs_fs+0x0/0x6e @ 1
initcall init_adfs_fs+0x0/0x6e returned 0 after 0 usecs
calling  fuse_init+0x0/0x152 @ 1
fuse init (API version 7.11)
initcall fuse_init+0x0/0x152 returned 0 after 3255 usecs
calling  init_udf_fs+0x0/0x6c @ 1
initcall init_udf_fs+0x0/0x6c returned 0 after 0 usecs
calling  init_jfs_fs+0x0/0x29d @ 1
JFS: nTxBlock =3D 7642, nTxLock =3D 61140
initcall init_jfs_fs+0x0/0x29d returned 0 after 9765 usecs
calling  init_nilfs_fs+0x0/0x9a @ 1
initcall init_nilfs_fs+0x0/0x9a returned 0 after 3255 usecs
calling  init_befs_fs+0x0/0x8a @ 1
BeFS version: 0.9.3
initcall init_befs_fs+0x0/0x8a returned 0 after 3255 usecs
calling  ocfs2_init+0x0/0x2a6 @ 1
OCFS2 1.5.0
initcall ocfs2_init+0x0/0x2a6 returned 0 after 3255 usecs
calling  ocfs2_stack_glue_init+0x0/0x9a @ 1
initcall ocfs2_stack_glue_init+0x0/0x9a returned 0 after 0 usecs
calling  o2cb_stack_init+0x0/0x16 @ 1
ocfs2: Registered cluster interface o2cb
initcall o2cb_stack_init+0x0/0x16 returned 0 after 3255 usecs
calling  init_o2nm+0x0/0xc0 @ 1
OCFS2 Node Manager 1.5.0
initcall init_o2nm+0x0/0xc0 returned 0 after 3255 usecs
calling  dlm_init+0x0/0x29d @ 1
OCFS2 DLM 1.5.0
initcall dlm_init+0x0/0x29d returned 0 after 3255 usecs
calling  init_dlmfs_fs+0x0/0xf3 @ 1
OCFS2 DLMFS 1.5.0
OCFS2 User DLM kernel interface loaded
initcall init_dlmfs_fs+0x0/0xf3 returned 0 after 6510 usecs
calling  init_btrfs_fs+0x0/0xbc @ 1
Btrfs loaded
initcall init_btrfs_fs+0x0/0xbc returned 0 after 3255 usecs
calling  init_gfs2_fs+0x0/0x1fe @ 1
GFS2 (built Jun 16 2009 12:02:59) installed
initcall init_gfs2_fs+0x0/0x1fe returned 0 after 6510 usecs
calling  ipc_init+0x0/0x2f @ 1
msgmni has been set to 1910
initcall ipc_init+0x0/0x2f returned 0 after 0 usecs
calling  ipc_sysctl_init+0x0/0x14 @ 1
sysctl table check failed: /kernel/shmmax .1.34 No proc_handler
Pid: 1, comm: swapper Not tainted 2.6.30-tip #54077
Call Trace:
 [<ffffffff810782f5>] set_fail+0x65/0x70
 [<ffffffff8107868c>] sysctl_check_table+0x38c/0x710
 [<ffffffff810786a5>] sysctl_check_table+0x3a5/0x710
 [<ffffffff8105d08c>] ? sysctl_set_parent+0xc/0x50
 [<ffffffff8105dc2c>] __register_sysctl_paths+0x10c/0x350
 [<ffffffff8115a2f7>] ? proc_create_data+0x77/0xd0
 [<ffffffff8107b019>] ? jiffies_read+0x9/0x20
 [<ffffffff82521111>] ? ipc_sysctl_init+0x0/0x14
 [<ffffffff8105de9e>] register_sysctl_paths+0x2e/0x30
 [<ffffffff8105deb8>] register_sysctl_table+0x18/0x20
 [<ffffffff82521121>] ipc_sysctl_init+0x10/0x14
 [<ffffffff8100904f>] do_one_initcall+0x3f/0x1d0
 [<ffffffff8151a441>] ? ida_get_new_above+0x151/0x220
 [<ffffffff810f8e95>] ? check_object+0x265/0x270
 [<ffffffff81014b10>] ? native_sched_clock+0x20/0x80
 [<ffffffff81014b83>] ? sched_clock+0x13/0x30
 [<ffffffff81080e4f>] ? __lock_acquire+0x14f/0xd20
 [<ffffffff8151a441>] ? ida_get_new_above+0x151/0x220
 [<ffffffff8151a441>] ? ida_get_new_above+0x151/0x220
 [<ffffffff81014b10>] ? native_sched_clock+0x20/0x80
 [<ffffffff81014b83>] ? sched_clock+0x13/0x30
 [<ffffffff81080015>] ? lock_release_holdtime+0x35/0x210
 [<ffffffff81533eb5>] ? _raw_spin_unlock+0xa5/0xc0
 [<ffffffff81d4266b>] ? _spin_unlock+0x2b/0x40
 [<ffffffff8115a194>] ? proc_register+0x124/0x210
 [<ffffffff8115a3ae>] ? create_proc_entry+0x5e/0xb0
 [<ffffffff81150000>] ? dqget+0xa0/0x390
 [<ffffffff8109a939>] ? irq_to_desc+0x9/0x30
 [<ffffffff8250074b>] kernel_init+0x1a8/0x22c
 [<ffffffff8100d50a>] child_rip+0xa/0x20
 [<ffffffff8100ce90>] ? restore_args+0x0/0x30
 [<ffffffff825005a3>] ? kernel_init+0x0/0x22c
 [<ffffffff8100d500>] ? child_rip+0x0/0x20
sysctl table check failed: /kernel/shmall .1.41 No proc_handler
Pid: 1, comm: swapper Not tainted 2.6.30-tip #54077
Call Trace:
 [<ffffffff810782f5>] set_fail+0x65/0x70
 [<ffffffff8107868c>] sysctl_check_table+0x38c/0x710
 [<ffffffff810786a5>] sysctl_check_table+0x3a5/0x710
 [<ffffffff8105d08c>] ? sysctl_set_parent+0xc/0x50
 [<ffffffff8105dc2c>] __register_sysctl_paths+0x10c/0x350
 [<ffffffff8115a2f7>] ? proc_create_data+0x77/0xd0
 [<ffffffff8107b019>] ? jiffies_read+0x9/0x20
 [<ffffffff82521111>] ? ipc_sysctl_init+0x0/0x14
 [<ffffffff8105de9e>] register_sysctl_paths+0x2e/0x30
 [<ffffffff8105deb8>] register_sysctl_table+0x18/0x20
 [<ffffffff82521121>] ipc_sysctl_init+0x10/0x14
 [<ffffffff8100904f>] do_one_initcall+0x3f/0x1d0
 [<ffffffff8151a441>] ? ida_get_new_above+0x151/0x220
 [<ffffffff810f8e95>] ? check_object+0x265/0x270
 [<ffffffff81014b10>] ? native_sched_clock+0x20/0x80
 [<ffffffff81014b83>] ? sched_clock+0x13/0x30
 [<ffffffff81080e4f>] ? __lock_acquire+0x14f/0xd20
 [<ffffffff8151a441>] ? ida_get_new_above+0x151/0x220
 [<ffffffff8151a441>] ? ida_get_new_above+0x151/0x220
 [<ffffffff81014b10>] ? native_sched_clock+0x20/0x80
 [<ffffffff81014b83>] ? sched_clock+0x13/0x30
 [<ffffffff81080015>] ? lock_release_holdtime+0x35/0x210
 [<ffffffff81533eb5>] ? _raw_spin_unlock+0xa5/0xc0
 [<ffffffff81d4266b>] ? _spin_unlock+0x2b/0x40
 [<ffffffff8115a194>] ? proc_register+0x124/0x210
 [<ffffffff8115a3ae>] ? create_proc_entry+0x5e/0xb0
 [<ffffffff81150000>] ? dqget+0xa0/0x390
 [<ffffffff8109a939>] ? irq_to_desc+0x9/0x30
 [<ffffffff8250074b>] kernel_init+0x1a8/0x22c
 [<ffffffff8100d50a>] child_rip+0xa/0x20
 [<ffffffff8100ce90>] ? restore_args+0x0/0x30
 [<ffffffff825005a3>] ? kernel_init+0x0/0x22c
 [<ffffffff8100d500>] ? child_rip+0x0/0x20
sysctl table check failed: /kernel/shmmni .1.45 No proc_handler
Pid: 1, comm: swapper Not tainted 2.6.30-tip #54077
Call Trace:
 [<ffffffff810782f5>] set_fail+0x65/0x70
 [<ffffffff8107868c>] sysctl_check_table+0x38c/0x710
 [<ffffffff810786a5>] sysctl_check_table+0x3a5/0x710
 [<ffffffff8105d08c>] ? sysctl_set_parent+0xc/0x50
 [<ffffffff8105dc2c>] __register_sysctl_paths+0x10c/0x350
 [<ffffffff8115a2f7>] ? proc_create_data+0x77/0xd0
 [<ffffffff8107b019>] ? jiffies_read+0x9/0x20
 [<ffffffff82521111>] ? ipc_sysctl_init+0x0/0x14
 [<ffffffff8105de9e>] register_sysctl_paths+0x2e/0x30
 [<ffffffff8105deb8>] register_sysctl_table+0x18/0x20
 [<ffffffff82521121>] ipc_sysctl_init+0x10/0x14
 [<ffffffff8100904f>] do_one_initcall+0x3f/0x1d0
 [<ffffffff8151a441>] ? ida_get_new_above+0x151/0x220
 [<ffffffff810f8e95>] ? check_object+0x265/0x270
 [<ffffffff81014b10>] ? native_sched_clock+0x20/0x80
 [<ffffffff81014b83>] ? sched_clock+0x13/0x30
 [<ffffffff81080e4f>] ? __lock_acquire+0x14f/0xd20
 [<ffffffff8151a441>] ? ida_get_new_above+0x151/0x220
 [<ffffffff8151a441>] ? ida_get_new_above+0x151/0x220
 [<ffffffff81014b10>] ? native_sched_clock+0x20/0x80
 [<ffffffff81014b83>] ? sched_clock+0x13/0x30
 [<ffffffff81080015>] ? lock_release_holdtime+0x35/0x210
 [<ffffffff81533eb5>] ? _raw_spin_unlock+0xa5/0xc0
 [<ffffffff81d4266b>] ? _spin_unlock+0x2b/0x40
 [<ffffffff8115a194>] ? proc_register+0x124/0x210
 [<ffffffff8115a3ae>] ? create_proc_entry+0x5e/0xb0
 [<ffffffff81150000>] ? dqget+0xa0/0x390
 [<ffffffff8109a939>] ? irq_to_desc+0x9/0x30
 [<ffffffff8250074b>] kernel_init+0x1a8/0x22c
 [<ffffffff8100d50a>] child_rip+0xa/0x20
 [<ffffffff8100ce90>] ? restore_args+0x0/0x30
 [<ffffffff825005a3>] ? kernel_init+0x0/0x22c
 [<ffffffff8100d500>] ? child_rip+0x0/0x20
sysctl table check failed: /kernel/msgmax .1.35 No proc_handler
Pid: 1, comm: swapper Not tainted 2.6.30-tip #54077
Call Trace:
 [<ffffffff810782f5>] set_fail+0x65/0x70
 [<ffffffff8107868c>] sysctl_check_table+0x38c/0x710
 [<ffffffff810786a5>] sysctl_check_table+0x3a5/0x710
 [<ffffffff8105d08c>] ? sysctl_set_parent+0xc/0x50
 [<ffffffff8105dc2c>] __register_sysctl_paths+0x10c/0x350
 [<ffffffff8115a2f7>] ? proc_create_data+0x77/0xd0
 [<ffffffff8107b019>] ? jiffies_read+0x9/0x20
 [<ffffffff82521111>] ? ipc_sysctl_init+0x0/0x14
 [<ffffffff8105de9e>] register_sysctl_paths+0x2e/0x30
 [<ffffffff8105deb8>] register_sysctl_table+0x18/0x20
 [<ffffffff82521121>] ipc_sysctl_init+0x10/0x14
 [<ffffffff8100904f>] do_one_initcall+0x3f/0x1d0
 [<ffffffff8151a441>] ? ida_get_new_above+0x151/0x220
 [<ffffffff810f8e95>] ? check_object+0x265/0x270
 [<ffffffff81014b10>] ? native_sched_clock+0x20/0x80
 [<ffffffff81014b83>] ? sched_clock+0x13/0x30
 [<ffffffff81080e4f>] ? __lock_acquire+0x14f/0xd20
 [<ffffffff8151a441>] ? ida_get_new_above+0x151/0x220
 [<ffffffff8151a441>] ? ida_get_new_above+0x151/0x220
 [<ffffffff81014b10>] ? native_sched_clock+0x20/0x80
 [<ffffffff81014b83>] ? sched_clock+0x13/0x30
 [<ffffffff81080015>] ? lock_release_holdtime+0x35/0x210
 [<ffffffff81533eb5>] ? _raw_spin_unlock+0xa5/0xc0
 [<ffffffff81d4266b>] ? _spin_unlock+0x2b/0x40
 [<ffffffff8115a194>] ? proc_register+0x124/0x210
 [<ffffffff8115a3ae>] ? create_proc_entry+0x5e/0xb0
 [<ffffffff81150000>] ? dqget+0xa0/0x390
 [<ffffffff8109a939>] ? irq_to_desc+0x9/0x30
 [<ffffffff8250074b>] kernel_init+0x1a8/0x22c
 [<ffffffff8100d50a>] child_rip+0xa/0x20
 [<ffffffff8100ce90>] ? restore_args+0x0/0x30
 [<ffffffff825005a3>] ? kernel_init+0x0/0x22c
 [<ffffffff8100d500>] ? child_rip+0x0/0x20
sysctl table check failed: /kernel/msgmni .1.42 No proc_handler
Pid: 1, comm: swapper Not tainted 2.6.30-tip #54077
Call Trace:
 [<ffffffff810782f5>] set_fail+0x65/0x70
 [<ffffffff8107868c>] sysctl_check_table+0x38c/0x710
 [<ffffffff810786a5>] sysctl_check_table+0x3a5/0x710
 [<ffffffff8105d08c>] ? sysctl_set_parent+0xc/0x50
 [<ffffffff8105dc2c>] __register_sysctl_paths+0x10c/0x350
 [<ffffffff8115a2f7>] ? proc_create_data+0x77/0xd0
 [<ffffffff8107b019>] ? jiffies_read+0x9/0x20
 [<ffffffff82521111>] ? ipc_sysctl_init+0x0/0x14
 [<ffffffff8105de9e>] register_sysctl_paths+0x2e/0x30
 [<ffffffff8105deb8>] register_sysctl_table+0x18/0x20
 [<ffffffff82521121>] ipc_sysctl_init+0x10/0x14
 [<ffffffff8100904f>] do_one_initcall+0x3f/0x1d0
 [<ffffffff8151a441>] ? ida_get_new_above+0x151/0x220
 [<ffffffff810f8e95>] ? check_object+0x265/0x270
 [<ffffffff81014b10>] ? native_sched_clock+0x20/0x80
 [<ffffffff81014b83>] ? sched_clock+0x13/0x30
 [<ffffffff81080e4f>] ? __lock_acquire+0x14f/0xd20
 [<ffffffff8151a441>] ? ida_get_new_above+0x151/0x220
 [<ffffffff8151a441>] ? ida_get_new_above+0x151/0x220
 [<ffffffff81014b10>] ? native_sched_clock+0x20/0x80
 [<ffffffff81014b83>] ? sched_clock+0x13/0x30
 [<ffffffff81080015>] ? lock_release_holdtime+0x35/0x210
 [<ffffffff81533eb5>] ? _raw_spin_unlock+0xa5/0xc0
 [<ffffffff81d4266b>] ? _spin_unlock+0x2b/0x40
 [<ffffffff8115a194>] ? proc_register+0x124/0x210
 [<ffffffff8115a3ae>] ? create_proc_entry+0x5e/0xb0
 [<ffffffff81150000>] ? dqget+0xa0/0x390
 [<ffffffff8109a939>] ? irq_to_desc+0x9/0x30
 [<ffffffff8250074b>] kernel_init+0x1a8/0x22c
 [<ffffffff8100d50a>] child_rip+0xa/0x20
 [<ffffffff8100ce90>] ? restore_args+0x0/0x30
 [<ffffffff825005a3>] ? kernel_init+0x0/0x22c
 [<ffffffff8100d500>] ? child_rip+0x0/0x20
sysctl table check failed: /kernel/msgmnb .1.36 No proc_handler
Pid: 1, comm: swapper Not tainted 2.6.30-tip #54077
Call Trace:
 [<ffffffff810782f5>] set_fail+0x65/0x70
 [<ffffffff8107868c>] sysctl_check_table+0x38c/0x710
 [<ffffffff810786a5>] sysctl_check_table+0x3a5/0x710
 [<ffffffff8105d08c>] ? sysctl_set_parent+0xc/0x50
 [<ffffffff8105dc2c>] __register_sysctl_paths+0x10c/0x350
 [<ffffffff8115a2f7>] ? proc_create_data+0x77/0xd0
 [<ffffffff8107b019>] ? jiffies_read+0x9/0x20
 [<ffffffff82521111>] ? ipc_sysctl_init+0x0/0x14
 [<ffffffff8105de9e>] register_sysctl_paths+0x2e/0x30
 [<ffffffff8105deb8>] register_sysctl_table+0x18/0x20
 [<ffffffff82521121>] ipc_sysctl_init+0x10/0x14
 [<ffffffff8100904f>] do_one_initcall+0x3f/0x1d0
 [<ffffffff8151a441>] ? ida_get_new_above+0x151/0x220
 [<ffffffff810f8e95>] ? check_object+0x265/0x270
 [<ffffffff81014b10>] ? native_sched_clock+0x20/0x80
 [<ffffffff81014b83>] ? sched_clock+0x13/0x30
 [<ffffffff81080e4f>] ? __lock_acquire+0x14f/0xd20
 [<ffffffff8151a441>] ? ida_get_new_above+0x151/0x220
 [<ffffffff8151a441>] ? ida_get_new_above+0x151/0x220
 [<ffffffff81014b10>] ? native_sched_clock+0x20/0x80
 [<ffffffff81014b83>] ? sched_clock+0x13/0x30
 [<ffffffff81080015>] ? lock_release_holdtime+0x35/0x210
 [<ffffffff81533eb5>] ? _raw_spin_unlock+0xa5/0xc0
 [<ffffffff81d4266b>] ? _spin_unlock+0x2b/0x40
 [<ffffffff8115a194>] ? proc_register+0x124/0x210
 [<ffffffff8115a3ae>] ? create_proc_entry+0x5e/0xb0
 [<ffffffff81150000>] ? dqget+0xa0/0x390
 [<ffffffff8109a939>] ? irq_to_desc+0x9/0x30
 [<ffffffff8250074b>] kernel_init+0x1a8/0x22c
 [<ffffffff8100d50a>] child_rip+0xa/0x20
 [<ffffffff8100ce90>] ? restore_args+0x0/0x30
 [<ffffffff825005a3>] ? kernel_init+0x0/0x22c
 [<ffffffff8100d500>] ? child_rip+0x0/0x20
sysctl table check failed: /kernel/sem .1.43 No proc_handler
Pid: 1, comm: swapper Not tainted 2.6.30-tip #54077
Call Trace:
 [<ffffffff810782f5>] set_fail+0x65/0x70
 [<ffffffff8107868c>] sysctl_check_table+0x38c/0x710
 [<ffffffff810786a5>] sysctl_check_table+0x3a5/0x710
 [<ffffffff8105d08c>] ? sysctl_set_parent+0xc/0x50
 [<ffffffff8105dc2c>] __register_sysctl_paths+0x10c/0x350
 [<ffffffff8115a2f7>] ? proc_create_data+0x77/0xd0
 [<ffffffff8107b019>] ? jiffies_read+0x9/0x20
 [<ffffffff82521111>] ? ipc_sysctl_init+0x0/0x14
 [<ffffffff8105de9e>] register_sysctl_paths+0x2e/0x30
 [<ffffffff8105deb8>] register_sysctl_table+0x18/0x20
 [<ffffffff82521121>] ipc_sysctl_init+0x10/0x14
 [<ffffffff8100904f>] do_one_initcall+0x3f/0x1d0
 [<ffffffff8151a441>] ? ida_get_new_above+0x151/0x220
 [<ffffffff810f8e95>] ? check_object+0x265/0x270
 [<ffffffff81014b10>] ? native_sched_clock+0x20/0x80
 [<ffffffff81014b83>] ? sched_clock+0x13/0x30
 [<ffffffff81080e4f>] ? __lock_acquire+0x14f/0xd20
 [<ffffffff8151a441>] ? ida_get_new_above+0x151/0x220
 [<ffffffff8151a441>] ? ida_get_new_above+0x151/0x220
 [<ffffffff81014b10>] ? native_sched_clock+0x20/0x80
 [<ffffffff81014b83>] ? sched_clock+0x13/0x30
 [<ffffffff81080015>] ? lock_release_holdtime+0x35/0x210
 [<ffffffff81533eb5>] ? _raw_spin_unlock+0xa5/0xc0
 [<ffffffff81d4266b>] ? _spin_unlock+0x2b/0x40
 [<ffffffff8115a194>] ? proc_register+0x124/0x210
 [<ffffffff8115a3ae>] ? create_proc_entry+0x5e/0xb0
 [<ffffffff81150000>] ? dqget+0xa0/0x390
 [<ffffffff8109a939>] ? irq_to_desc+0x9/0x30
 [<ffffffff8250074b>] kernel_init+0x1a8/0x22c
 [<ffffffff8100d50a>] child_rip+0xa/0x20
 [<ffffffff8100ce90>] ? restore_args+0x0/0x30
 [<ffffffff825005a3>] ? kernel_init+0x0/0x22c
 [<ffffffff8100d500>] ? child_rip+0x0/0x20
sysctl table check failed: /kernel/auto_msgmni  No proc_handler
Pid: 1, comm: swapper Not tainted 2.6.30-tip #54077
Call Trace:
 [<ffffffff810782f5>] set_fail+0x65/0x70
 [<ffffffff8107868c>] sysctl_check_table+0x38c/0x710
 [<ffffffff810786a5>] sysctl_check_table+0x3a5/0x710
 [<ffffffff8105d08c>] ? sysctl_set_parent+0xc/0x50
 [<ffffffff8105dc2c>] __register_sysctl_paths+0x10c/0x350
 [<ffffffff8115a2f7>] ? proc_create_data+0x77/0xd0
 [<ffffffff8107b019>] ? jiffies_read+0x9/0x20
 [<ffffffff82521111>] ? ipc_sysctl_init+0x0/0x14
 [<ffffffff8105de9e>] register_sysctl_paths+0x2e/0x30
 [<ffffffff8105deb8>] register_sysctl_table+0x18/0x20
 [<ffffffff82521121>] ipc_sysctl_init+0x10/0x14
 [<ffffffff8100904f>] do_one_initcall+0x3f/0x1d0
 [<ffffffff8151a441>] ? ida_get_new_above+0x151/0x220
 [<ffffffff810f8e95>] ? check_object+0x265/0x270
 [<ffffffff81014b10>] ? native_sched_clock+0x20/0x80
 [<ffffffff81014b83>] ? sched_clock+0x13/0x30
 [<ffffffff81080e4f>] ? __lock_acquire+0x14f/0xd20
 [<ffffffff8151a441>] ? ida_get_new_above+0x151/0x220
 [<ffffffff8151a441>] ? ida_get_new_above+0x151/0x220
 [<ffffffff81014b10>] ? native_sched_clock+0x20/0x80
 [<ffffffff81014b83>] ? sched_clock+0x13/0x30
 [<ffffffff81080015>] ? lock_release_holdtime+0x35/0x210
 [<ffffffff81533eb5>] ? _raw_spin_unlock+0xa5/0xc0
 [<ffffffff81d4266b>] ? _spin_unlock+0x2b/0x40
 [<ffffffff8115a194>] ? proc_register+0x124/0x210
 [<ffffffff8115a3ae>] ? create_proc_entry+0x5e/0xb0
 [<ffffffff81150000>] ? dqget+0xa0/0x390
 [<ffffffff8109a939>] ? irq_to_desc+0x9/0x30
 [<ffffffff8250074b>] kernel_init+0x1a8/0x22c
 [<ffffffff8100d50a>] child_rip+0xa/0x20
 [<ffffffff8100ce90>] ? restore_args+0x0/0x30
 [<ffffffff825005a3>] ? kernel_init+0x0/0x22c
 [<ffffffff8100d500>] ? child_rip+0x0/0x20
initcall ipc_sysctl_init+0x0/0x14 returned 0 after 930989 usecs
calling  key_proc_init+0x0/0x5e @ 1
initcall key_proc_init+0x0/0x5e returned 0 after 0 usecs
calling  crypto_wq_init+0x0/0x32 @ 1
initcall crypto_wq_init+0x0/0x32 returned 0 after 0 usecs
calling  crypto_algapi_init+0x0/0xd @ 1
initcall crypto_algapi_init+0x0/0xd returned 0 after 0 usecs
calling  chainiv_module_init+0x0/0x12 @ 1
initcall chainiv_module_init+0x0/0x12 returned 0 after 0 usecs
calling  eseqiv_module_init+0x0/0x12 @ 1
initcall eseqiv_module_init+0x0/0x12 returned 0 after 0 usecs
calling  seqiv_module_init+0x0/0x12 @ 1
initcall seqiv_module_init+0x0/0x12 returned 0 after 0 usecs
calling  hmac_module_init+0x0/0x12 @ 1
initcall hmac_module_init+0x0/0x12 returned 0 after 0 usecs
calling  md5_mod_init+0x0/0x12 @ 1
initcall md5_mod_init+0x0/0x12 returned 0 after 0 usecs
calling  rmd128_mod_init+0x0/0x12 @ 1
initcall rmd128_mod_init+0x0/0x12 returned 0 after 0 usecs
calling  rmd160_mod_init+0x0/0x12 @ 1
initcall rmd160_mod_init+0x0/0x12 returned 0 after 0 usecs
calling  rmd256_mod_init+0x0/0x12 @ 1
initcall rmd256_mod_init+0x0/0x12 returned 0 after 0 usecs
calling  rmd320_mod_init+0x0/0x12 @ 1
initcall rmd320_mod_init+0x0/0x12 returned 0 after 0 usecs
calling  sha1_generic_mod_init+0x0/0x12 @ 1
initcall sha1_generic_mod_init+0x0/0x12 returned 0 after 0 usecs
calling  sha256_generic_mod_init+0x0/0x48 @ 1
initcall sha256_generic_mod_init+0x0/0x48 returned 0 after 3255 usecs
calling  wp512_mod_init+0x0/0x80 @ 1
initcall wp512_mod_init+0x0/0x80 returned 0 after 0 usecs
calling  tgr192_mod_init+0x0/0x72 @ 1
initcall tgr192_mod_init+0x0/0x72 returned 0 after 0 usecs
calling  crypto_ecb_module_init+0x0/0x12 @ 1
initcall crypto_ecb_module_init+0x0/0x12 returned 0 after 0 usecs
calling  crypto_cbc_module_init+0x0/0x12 @ 1
initcall crypto_cbc_module_init+0x0/0x12 returned 0 after 0 usecs
calling  crypto_pcbc_module_init+0x0/0x12 @ 1
initcall crypto_pcbc_module_init+0x0/0x12 returned 0 after 0 usecs
calling  crypto_cts_module_init+0x0/0x12 @ 1
initcall crypto_cts_module_init+0x0/0x12 returned 0 after 0 usecs
calling  crypto_module_init+0x0/0x12 @ 1
initcall crypto_module_init+0x0/0x12 returned 0 after 0 usecs
calling  crypto_ctr_module_init+0x0/0x44 @ 1
initcall crypto_ctr_module_init+0x0/0x44 returned 0 after 0 usecs
calling  crypto_gcm_module_init+0x0/0x62 @ 1
initcall crypto_gcm_module_init+0x0/0x62 returned 0 after 0 usecs
calling  crypto_ccm_module_init+0x0/0x62 @ 1
initcall crypto_ccm_module_init+0x0/0x62 returned 0 after 0 usecs
calling  cryptd_init+0x0/0x126 @ 1
initcall cryptd_init+0x0/0x126 returned 0 after 0 usecs
calling  des_generic_mod_init+0x0/0x44 @ 1
initcall des_generic_mod_init+0x0/0x44 returned 0 after 0 usecs
calling  blowfish_mod_init+0x0/0x12 @ 1
initcall blowfish_mod_init+0x0/0x12 returned 0 after 0 usecs
calling  twofish_mod_init+0x0/0x12 @ 1
initcall twofish_mod_init+0x0/0x12 returned 0 after 0 usecs
calling  aes_init+0x0/0x12 @ 1
initcall aes_init+0x0/0x12 returned 0 after 0 usecs
calling  camellia_init+0x0/0x12 @ 1
initcall camellia_init+0x0/0x12 returned 0 after 0 usecs
calling  cast5_mod_init+0x0/0x12 @ 1
initcall cast5_mod_init+0x0/0x12 returned 0 after 0 usecs
calling  arc4_init+0x0/0x12 @ 1
initcall arc4_init+0x0/0x12 returned 0 after 0 usecs
calling  khazad_mod_init+0x0/0x12 @ 1
initcall khazad_mod_init+0x0/0x12 returned 0 after 0 usecs
calling  anubis_mod_init+0x0/0x12 @ 1
initcall anubis_mod_init+0x0/0x12 returned 0 after 0 usecs
calling  seed_init+0x0/0x12 @ 1
initcall seed_init+0x0/0x12 returned 0 after 0 usecs
calling  deflate_mod_init+0x0/0x12 @ 1
initcall deflate_mod_init+0x0/0x12 returned 0 after 0 usecs
calling  michael_mic_init+0x0/0x12 @ 1
initcall michael_mic_init+0x0/0x12 returned 0 after 0 usecs
calling  crc32c_mod_init+0x0/0x12 @ 1
initcall crc32c_mod_init+0x0/0x12 returned 0 after 0 usecs
calling  crypto_authenc_module_init+0x0/0x12 @ 1
initcall crypto_authenc_module_init+0x0/0x12 returned 0 after 0 usecs
calling  krng_mod_init+0x0/0x12 @ 1
alg: No test for stdrng (krng)
initcall krng_mod_init+0x0/0x12 returned 0 after 0 usecs
calling  prng_mod_init+0x0/0x36 @ 1
alg: No test for stdrng (ansi_cprng)
initcall prng_mod_init+0x0/0x36 returned 0 after 3255 usecs
calling  proc_genhd_init+0x0/0x3c @ 1
initcall proc_genhd_init+0x0/0x3c returned 0 after 0 usecs
calling  bsg_init+0x0/0x12f @ 1
Block layer SCSI generic (bsg) driver version 0.4 loaded (major 253)
initcall bsg_init+0x0/0x12f returned 0 after 3255 usecs
calling  noop_init+0x0/0x14 @ 1
io scheduler noop registered (default)
initcall noop_init+0x0/0x14 returned 0 after 3255 usecs
calling  as_init+0x0/0x14 @ 1
io scheduler anticipatory registered
initcall as_init+0x0/0x14 returned 0 after 3255 usecs
calling  deadline_init+0x0/0x19 @ 1
io scheduler deadline registered
initcall deadline_init+0x0/0x19 returned 0 after 3255 usecs
calling  cfq_init+0x0/0x99 @ 1
io scheduler cfq registered
initcall cfq_init+0x0/0x99 returned 0 after 0 usecs
calling  debug_objects_init_debugfs+0x0/0x6e @ 1
initcall debug_objects_init_debugfs+0x0/0x6e returned 0 after 0 usecs
calling  libcrc32c_mod_init+0x0/0x2c @ 1
initcall libcrc32c_mod_init+0x0/0x2c returned 0 after 0 usecs
calling  init_kmp+0x0/0x12 @ 1
initcall init_kmp+0x0/0x12 returned 0 after 0 usecs
calling  percpu_counter_startup+0x0/0x19 @ 1
initcall percpu_counter_startup+0x0/0x19 returned 0 after 0 usecs
calling  pci_init+0x0/0x47 @ 1
pci 0000:00:00.0: calling nv_msi_ht_cap_quirk_leaf+0x0/0x12
pci 0000:00:00.0: calling quirk_cardbus_legacy+0x0/0x30
pci 0000:00:00.0: calling quirk_usb_early_handoff+0x0/0x410
pci 0000:00:00.0: calling pci_fixup_video+0x0/0xce
pci 0000:00:01.0: calling nv_msi_ht_cap_quirk_leaf+0x0/0x12
pci 0000:00:01.0: calling quirk_cardbus_legacy+0x0/0x30
pci 0000:00:01.0: calling quirk_usb_early_handoff+0x0/0x410
pci 0000:00:01.0: calling pci_fixup_video+0x0/0xce
pci 0000:00:01.1: calling nv_msi_ht_cap_quirk_leaf+0x0/0x12
pci 0000:00:01.1: calling quirk_cardbus_legacy+0x0/0x30
pci 0000:00:01.1: calling quirk_usb_early_handoff+0x0/0x410
pci 0000:00:01.1: calling pci_fixup_video+0x0/0xce
pci 0000:00:02.0: calling nv_msi_ht_cap_quirk_leaf+0x0/0x12
pci 0000:00:02.0: calling quirk_cardbus_legacy+0x0/0x30
pci 0000:00:02.0: calling quirk_usb_early_handoff+0x0/0x410
pci 0000:00:02.0: calling pci_fixup_video+0x0/0xce
pci 0000:00:02.1: calling nv_msi_ht_cap_quirk_leaf+0x0/0x12
pci 0000:00:02.1: calling quirk_cardbus_legacy+0x0/0x30
pci 0000:00:02.1: calling quirk_usb_early_handoff+0x0/0x410
pci 0000:00:02.1: calling pci_fixup_video+0x0/0xce
pci 0000:00:04.0: calling nv_msi_ht_cap_quirk_leaf+0x0/0x12
pci 0000:00:04.0: calling quirk_cardbus_legacy+0x0/0x30
pci 0000:00:04.0: calling quirk_usb_early_handoff+0x0/0x410
pci 0000:00:04.0: calling pci_fixup_video+0x0/0xce
pci 0000:00:06.0: calling nv_msi_ht_cap_quirk_leaf+0x0/0x12
pci 0000:00:06.0: calling quirk_cardbus_legacy+0x0/0x30
pci 0000:00:06.0: calling quirk_usb_early_handoff+0x0/0x410
pci 0000:00:06.0: calling pci_fixup_video+0x0/0xce
pci 0000:00:09.0: calling nv_msi_ht_cap_quirk_leaf+0x0/0x12
pci 0000:00:09.0: calling quirk_cardbus_legacy+0x0/0x30
pci 0000:00:09.0: calling quirk_usb_early_handoff+0x0/0x410
pci 0000:00:09.0: calling pci_fixup_video+0x0/0xce
pci 0000:00:0a.0: calling nv_msi_ht_cap_quirk_leaf+0x0/0x12
pci 0000:00:0a.0: calling quirk_cardbus_legacy+0x0/0x30
pci 0000:00:0a.0: calling quirk_usb_early_handoff+0x0/0x410
pci 0000:00:0a.0: calling pci_fixup_video+0x0/0xce
pci 0000:00:0b.0: calling nv_msi_ht_cap_quirk_leaf+0x0/0x12
pci 0000:00:00.0: Found enabled HT MSI Mapping
pci 0000:00:0b.0: calling quirk_nvidia_ck804_msi_ht_cap+0x0/0x98
pci 0000:00:0b.0: Found disabled HT MSI Mapping
pci 0000:00:00.0: Found enabled HT MSI Mapping
pci 0000:00:0b.0: calling quirk_nvidia_ck804_pcie_aer_ext_cap+0x0/0x90
pci 0000:00:0b.0: calling quirk_cardbus_legacy+0x0/0x30
pci 0000:00:0b.0: calling quirk_usb_early_handoff+0x0/0x410
pci 0000:00:0b.0: calling pci_fixup_video+0x0/0xce
pci 0000:00:0c.0: calling nv_msi_ht_cap_quirk_leaf+0x0/0x12
pci 0000:00:00.0: Found enabled HT MSI Mapping
pci 0000:00:0c.0: calling quirk_nvidia_ck804_msi_ht_cap+0x0/0x98
pci 0000:00:0c.0: Found disabled HT MSI Mapping
pci 0000:00:00.0: Found enabled HT MSI Mapping
pci 0000:00:0c.0: calling quirk_nvidia_ck804_pcie_aer_ext_cap+0x0/0x90
pci 0000:00:0c.0: calling quirk_cardbus_legacy+0x0/0x30
pci 0000:00:0c.0: calling quirk_usb_early_handoff+0x0/0x410
pci 0000:00:0c.0: calling pci_fixup_video+0x0/0xce
pci 0000:00:0d.0: calling nv_msi_ht_cap_quirk_leaf+0x0/0x12
pci 0000:00:00.0: Found enabled HT MSI Mapping
pci 0000:00:0d.0: calling quirk_nvidia_ck804_msi_ht_cap+0x0/0x98
pci 0000:00:0d.0: Found disabled HT MSI Mapping
pci 0000:00:00.0: Found enabled HT MSI Mapping
pci 0000:00:0d.0: calling quirk_nvidia_ck804_pcie_aer_ext_cap+0x0/0x90
pci 0000:00:0d.0: calling quirk_cardbus_legacy+0x0/0x30
pci 0000:00:0d.0: calling quirk_usb_early_handoff+0x0/0x410
pci 0000:00:0d.0: calling pci_fixup_video+0x0/0xce
pci 0000:00:0e.0: calling nv_msi_ht_cap_quirk_leaf+0x0/0x12
pci 0000:00:00.0: Found enabled HT MSI Mapping
pci 0000:00:0e.0: calling quirk_nvidia_ck804_msi_ht_cap+0x0/0x98
pci 0000:00:0e.0: Found disabled HT MSI Mapping
pci 0000:00:00.0: Found enabled HT MSI Mapping
pci 0000:00:0e.0: calling quirk_nvidia_ck804_pcie_aer_ext_cap+0x0/0x90
pci 0000:00:0e.0: calling quirk_cardbus_legacy+0x0/0x30
pci 0000:00:0e.0: calling quirk_usb_early_handoff+0x0/0x410
pci 0000:00:0e.0: calling pci_fixup_video+0x0/0xce
pci 0000:00:18.0: calling quirk_cardbus_legacy+0x0/0x30
pci 0000:00:18.0: calling quirk_usb_early_handoff+0x0/0x410
pci 0000:00:18.0: calling pci_fixup_video+0x0/0xce
pci 0000:00:18.1: calling quirk_cardbus_legacy+0x0/0x30
pci 0000:00:18.1: calling quirk_usb_early_handoff+0x0/0x410
pci 0000:00:18.1: calling pci_fixup_video+0x0/0xce
pci 0000:00:18.2: calling quirk_cardbus_legacy+0x0/0x30
pci 0000:00:18.2: calling quirk_usb_early_handoff+0x0/0x410
pci 0000:00:18.2: calling pci_fixup_video+0x0/0xce
pci 0000:00:18.3: calling quirk_cardbus_legacy+0x0/0x30
pci 0000:00:18.3: calling quirk_usb_early_handoff+0x0/0x410
pci 0000:00:18.3: calling pci_fixup_video+0x0/0xce
pci 0000:05:07.0: calling quirk_cardbus_legacy+0x0/0x30
pci 0000:05:07.0: calling quirk_usb_early_handoff+0x0/0x410
pci 0000:05:07.0: calling pci_fixup_video+0x0/0xce
pci 0000:01:00.0: calling quirk_cardbus_legacy+0x0/0x30
pci 0000:01:00.0: calling quirk_usb_early_handoff+0x0/0x410
pci 0000:01:00.0: calling pci_fixup_video+0x0/0xce
pci 0000:01:00.0: Boot video device
pci 0000:01:00.1: calling quirk_cardbus_legacy+0x0/0x30
pci 0000:01:00.1: calling quirk_usb_early_handoff+0x0/0x410
pci 0000:01:00.1: calling pci_fixup_video+0x0/0xce
initcall pci_init+0x0/0x47 returned 0 after 319010 usecs
calling  pci_proc_init+0x0/0x7b @ 1
initcall pci_proc_init+0x0/0x7b returned 0 after 0 usecs
calling  pcie_portdrv_init+0x0/0x58 @ 1
  alloc irq_desc for 24 on node -1
  alloc kstat_irqs on node -1
pcieport-driver 0000:00:0b.0: irq 24 for MSI/MSI-X
pcieport-driver 0000:00:0b.0: setting latency timer to 64
  alloc irq_desc for 25 on node -1
  alloc kstat_irqs on node -1
pcieport-driver 0000:00:0c.0: irq 25 for MSI/MSI-X
pcieport-driver 0000:00:0c.0: setting latency timer to 64
  alloc irq_desc for 26 on node -1
  alloc kstat_irqs on node -1
pcieport-driver 0000:00:0d.0: irq 26 for MSI/MSI-X
pcieport-driver 0000:00:0d.0: setting latency timer to 64
  alloc irq_desc for 27 on node -1
  alloc kstat_irqs on node -1
pcieport-driver 0000:00:0e.0: irq 27 for MSI/MSI-X
pcieport-driver 0000:00:0e.0: setting latency timer to 64
initcall pcie_portdrv_init+0x0/0x58 returned 0 after 42317 usecs
calling  aer_service_init+0x0/0x29 @ 1
initcall aer_service_init+0x0/0x29 returned 0 after 0 usecs
calling  pci_hotplug_init+0x0/0x51 @ 1
pci_hotplug: PCI Hot Plug PCI Core version: 0.5
initcall pci_hotplug_init+0x0/0x51 returned 0 after 3255 usecs
calling  pcied_init+0x0/0x7d @ 1
pciehp: PCI Express Hot Plug Controller Driver version: 0.4
initcall pcied_init+0x0/0x7d returned 0 after 3255 usecs
calling  zt5550_init+0x0/0x84 @ 1
cpcihp_zt5550: ZT5550 CompactPCI Hot Plug Driver version: 0.2
initcall zt5550_init+0x0/0x84 returned 0 after 3255 usecs
calling  cpcihp_generic_init+0x0/0x4f2 @ 1
cpcihp_generic: Generic port I/O CompactPCI Hot Plug Driver version: 0.=
1
cpcihp_generic: not configured, disabling.
initcall cpcihp_generic_init+0x0/0x4f2 returned -22 after 6510 usecs
initcall cpcihp_generic_init+0x0/0x4f2 returned with error code -22=20
calling  shpcd_init+0x0/0x68 @ 1
shpchp: Standard Hot Plug PCI Controller Driver version: 0.4
initcall shpcd_init+0x0/0x68 returned 0 after 3255 usecs
calling  pci_stub_init+0x0/0x24 @ 1
initcall pci_stub_init+0x0/0x24 returned 0 after 0 usecs
calling  platform_lcd_init+0x0/0x12 @ 1
initcall platform_lcd_init+0x0/0x12 returned 0 after 0 usecs
calling  genericbl_init+0x0/0x12 @ 1
initcall genericbl_init+0x0/0x12 returned 0 after 0 usecs
calling  progearbl_init+0x0/0x5c @ 1
ALI M7101 PMU not found.
initcall progearbl_init+0x0/0x5c returned 0 after 3255 usecs
calling  cr_backlight_init+0x0/0x76 @ 1
INTEL CARILLO RANCH LPC not found.
Carillo Ranch Backlight Driver Initialized.
initcall cr_backlight_init+0x0/0x76 returned 0 after 6510 usecs
calling  mbp_init+0x0/0xfa @ 1
initcall mbp_init+0x0/0xfa returned -19 after 0 usecs
calling  kb3886_init+0x0/0x3c @ 1
initcall kb3886_init+0x0/0x3c returned -19 after 0 usecs
calling  display_class_init+0x0/0x7e @ 1
initcall display_class_init+0x0/0x7e returned 0 after 0 usecs
calling  arcfb_init+0x0/0x7a @ 1
initcall arcfb_init+0x0/0x7a returned -6 after 0 usecs
initcall arcfb_init+0x0/0x7a returned with error code -6=20
calling  cyber2000fb_init+0x0/0xdb @ 1
initcall cyber2000fb_init+0x0/0xdb returned 0 after 3255 usecs
calling  pm2fb_init+0x0/0x154 @ 1
initcall pm2fb_init+0x0/0x154 returned 0 after 0 usecs
calling  pm3fb_init+0x0/0x110 @ 1
initcall pm3fb_init+0x0/0x110 returned 0 after 0 usecs
calling  nvidiafb_init+0x0/0x2bb @ 1
nvidiafb_setup START
initcall nvidiafb_init+0x0/0x2bb returned 0 after 3255 usecs
calling  atyfb_init+0x0/0x1f9 @ 1
initcall atyfb_init+0x0/0x1f9 returned 0 after 0 usecs
calling  sisfb_init+0x0/0x825 @ 1
initcall sisfb_init+0x0/0x825 returned 0 after 0 usecs
calling  viafb_init+0x0/0x1259 @ 1
VIA Graphics Intergration Chipset framebuffer 2.4 initializing
ioremap failed
initcall viafb_init+0x0/0x1259 returned -1 after 7659505 usecs
initcall viafb_init+0x0/0x1259 returned with error code -1=20
calling  savagefb_init+0x0/0x77 @ 1
initcall savagefb_init+0x0/0x77 returned 0 after 0 usecs
calling  gx1fb_init+0x0/0x14e @ 1
initcall gx1fb_init+0x0/0x14e returned 0 after 0 usecs
calling  gxfb_init+0x0/0x94 @ 1
initcall gxfb_init+0x0/0x94 returned 0 after 0 usecs
calling  lxfb_init+0x0/0x104 @ 1
initcall lxfb_init+0x0/0x104 returned 0 after 0 usecs
calling  neofb_init+0x0/0x14b @ 1
initcall neofb_init+0x0/0x14b returned 0 after 0 usecs
calling  tdfxfb_init+0x0/0x13d @ 1
initcall tdfxfb_init+0x0/0x13d returned 0 after 0 usecs
calling  imsttfb_init+0x0/0x131 @ 1
initcall imsttfb_init+0x0/0x131 returned 0 after 0 usecs
calling  vt8623fb_init+0x0/0x59 @ 1
initcall vt8623fb_init+0x0/0x59 returned 0 after 0 usecs
calling  tridentfb_init+0x0/0x1f9 @ 1
initcall tridentfb_init+0x0/0x1f9 returned 0 after 0 usecs
calling  vmlfb_init+0x0/0x9a @ 1
vmlfb: initializing
initcall vmlfb_init+0x0/0x9a returned 0 after 3255 usecs
calling  cr_pll_init+0x0/0x10a @ 1
Could not find Carillo Ranch MCH device.
initcall cr_pll_init+0x0/0x10a returned -19 after 3255 usecs
calling  s3fb_init+0x0/0xfb @ 1
initcall s3fb_init+0x0/0xfb returned 0 after 0 usecs
calling  sstfb_init+0x0/0x1ce @ 1
initcall sstfb_init+0x0/0x1ce returned 0 after 0 usecs
calling  s1d13xxxfb_init+0x0/0x2d @ 1
initcall s1d13xxxfb_init+0x0/0x2d returned 0 after 0 usecs
calling  mb862xxfb_init+0x0/0x20 @ 1
initcall mb862xxfb_init+0x0/0x20 returned 0 after 0 usecs
calling  uvesafb_init+0x0/0x3d0 @ 1
uvesafb: failed to execute /sbin/v86d
uvesafb: make sure that the v86d helper is installed and executable
uvesafb: Getting VBE info block failed (eax=3D0x4f00, err=3D-2)
uvesafb: vbe_init() failed with -22
uvesafb: probe of uvesafb.0 failed with error -22
initcall uvesafb_init+0x0/0x3d0 returned 0 after 22786 usecs
calling  regulator_virtual_consumer_init+0x0/0x12 @ 1
initcall regulator_virtual_consumer_init+0x0/0x12 returned 0 after 0 us=
ecs
calling  regulator_userspace_consumer_init+0x0/0x12 @ 1
initcall regulator_userspace_consumer_init+0x0/0x12 returned 0 after 0 =
usecs
calling  bq24022_init+0x0/0x19 @ 1
initcall bq24022_init+0x0/0x19 returned -19 after 0 usecs
calling  lp3971_module_init+0x0/0x38 @ 1
initcall lp3971_module_init+0x0/0x38 returned 0 after 0 usecs
calling  rand_initialize+0x0/0x40 @ 1
initcall rand_initialize+0x0/0x40 returned 0 after 0 usecs
calling  tty_init+0x0/0xfa @ 1
initcall tty_init+0x0/0xfa returned 0 after 13020 usecs
calling  pty_init+0x0/0x3cb @ 1
initcall pty_init+0x0/0x3cb returned 0 after 0 usecs
calling  sysrq_init+0x0/0x25 @ 1
initcall sysrq_init+0x0/0x25 returned 0 after 0 usecs
calling  nozomi_init+0x0/0x162 @ 1
Initializing Nozomi driver 2.1d (build date: Jun 16 2009 12:02:45)
initcall nozomi_init+0x0/0x162 returned 0 after 6510 usecs
calling  raw_init+0x0/0xdf @ 1
initcall raw_init+0x0/0xdf returned 0 after 0 usecs
calling  lp_init_module+0x0/0x275 @ 1
lp: driver loaded but no devices found
initcall lp_init_module+0x0/0x275 returned 0 after 3255 usecs
calling  applicom_init+0x0/0x525 @ 1
Applicom driver: $Id: ac.c,v 1.30 2000/03/22 16:03:57 dwmw2 Exp $
ac.o: No PCI boards found.
ac.o: For an ISA board you must supply memory and irq parameters.
initcall applicom_init+0x0/0x525 returned -6 after 9765 usecs
initcall applicom_init+0x0/0x525 returned with error code -6=20
calling  nvram_init+0x0/0x8b @ 1
Non-volatile memory driver v1.3
initcall nvram_init+0x0/0x8b returned 0 after 3255 usecs
calling  i8k_init+0x0/0x3ed @ 1
initcall i8k_init+0x0/0x3ed returned -19 after 0 usecs
calling  pc8736x_gpio_init+0x0/0x419 @ 1
platform pc8736x_gpio.0: NatSemi pc8736x GPIO Driver Initializing
platform pc8736x_gpio.0: no device found
initcall pc8736x_gpio_init+0x0/0x419 returned -19 after 6510 usecs
calling  nsc_gpio_init+0x0/0x16 @ 1
nsc_gpio initializing
initcall nsc_gpio_init+0x0/0x16 returned 0 after 0 usecs
calling  tlclk_init+0x0/0x22f @ 1
telclk_interrup =3D 0xf non-mcpbl0010 hw.
initcall tlclk_init+0x0/0x22f returned -6 after 3255 usecs
initcall tlclk_init+0x0/0x22f returned with error code -6=20
calling  ipmi_init_msghandler_mod+0x0/0xd @ 1
ipmi message handler version 39.2
initcall ipmi_init_msghandler_mod+0x0/0xd returned 0 after 3255 usecs
calling  init_ipmi_devintf+0x0/0x107 @ 1
ipmi device interface
initcall init_ipmi_devintf+0x0/0x107 returned 0 after 3255 usecs
calling  init_ipmi_si+0x0/0x7a0 @ 1
IPMI System Interface driver.
ipmi_si: Unable to find any System Interface(s)
initcall init_ipmi_si+0x0/0x7a0 returned -19 after 48828 usecs
calling  ipmi_poweroff_init+0x0/0xa0 @ 1
Copyright (C) 2004 MontaVista Software - IPMI Powerdown via sys_reboot.
initcall ipmi_poweroff_init+0x0/0xa0 returned 0 after 3255 usecs
calling  hangcheck_init+0x0/0x9f @ 1
Hangcheck: starting hangcheck timer 0.9.0 (tick is 180 seconds, margin =
is 60 seconds).
Hangcheck: Using get_cycles().
initcall hangcheck_init+0x0/0x9f returned 0 after 6510 usecs
calling  init_nsc+0x0/0x1fa @ 1
initcall init_nsc+0x0/0x1fa returned -19 after 0 usecs
calling  init_atmel+0x0/0x17a @ 1
Platform driver 'tpm_atmel' needs updating - please use dev_pm_ops
initcall init_atmel+0x0/0x17a returned -19 after 3255 usecs
calling  drm_core_init+0x0/0x136 @ 1
[drm] Initialized drm 1.1.0 20060810
initcall drm_core_init+0x0/0x136 returned 0 after 6510 usecs
calling  tdfx_init+0x0/0x12 @ 1
initcall tdfx_init+0x0/0x12 returned 0 after 0 usecs
calling  r128_init+0x0/0x1e @ 1
initcall r128_init+0x0/0x1e returned 0 after 3255 usecs
calling  radeon_init+0x0/0x1e @ 1
IOAPIC[0]: Set routing entry (2-5 -> 0x35 -> IRQ 5 Mode:1 Active:1)
pci 0000:01:00.0: PCI->APIC IRQ transform: INT A -> IRQ 5
pci 0000:01:00.0: setting latency timer to 64
[drm] Initialized radeon 1.30.0 20080528 for 0000:01:00.0 on minor 0
initcall radeon_init+0x0/0x1e returned 0 after 16276 usecs
calling  mga_init+0x0/0x1e @ 1
initcall mga_init+0x0/0x1e returned 0 after 0 usecs
calling  savage_init+0x0/0x1e @ 1
initcall savage_init+0x0/0x1e returned 0 after 0 usecs
calling  cn_proc_init+0x0/0x4a @ 1
initcall cn_proc_init+0x0/0x4a returned 0 after 0 usecs
calling  serial8250_init+0x0/0x155 @ 1
Serial: 8250/16550 driver, 4 ports, IRQ sharing disabled
async_waiting @ 1
async_continuing @ 1 after 0 usec
async_waiting @ 1
async_continuing @ 1 after 0 usec
=EF=BF=BDserial8250: ttyS0 at I/O 0x3f8 (irq =3D 4) is a 16550A
Platform driver 'serial8250' needs updating - please use dev_pm_ops
initcall serial8250_init+0x0/0x155 returned 0 after 263671 usecs
calling  serial8250_pci_init+0x0/0x26 @ 1
initcall serial8250_pci_init+0x0/0x26 returned 0 after 0 usecs
calling  jsm_init_module+0x0/0x4d @ 1
initcall jsm_init_module+0x0/0x4d returned 0 after 0 usecs
calling  init_kgdboc+0x0/0x1b @ 1
initcall init_kgdboc+0x0/0x1b returned 0 after 0 usecs
calling  parport_default_proc_register+0x0/0x20 @ 1
initcall parport_default_proc_register+0x0/0x20 returned 0 after 0 usec=
s
calling  parport_pc_init+0x0/0x188 @ 1
parport0: PC-style at 0x378 (0x778)async_waiting @ 1
async_continuing @ 1 after 0 usec
 [PCSPP,TRISTATE]
parport0: irq 7 detected
lp0: using parport0 (polling).
lp0: console ready
initcall parport_pc_init+0x0/0x188 returned 0 after 218098 usecs
calling  parport_serial_init+0x0/0x27 @ 1
initcall parport_serial_init+0x0/0x27 returned 0 after 0 usecs
calling  topology_sysfs_init+0x0/0xac @ 1
initcall topology_sysfs_init+0x0/0xac returned 0 after 0 usecs
calling  cpqarray_init+0x0/0x2c7 @ 1
Compaq SMART2 Driver (v 2.6.0)
initcall cpqarray_init+0x0/0x2c7 returned -19 after 3255 usecs
calling  pkt_init+0x0/0x222 @ 1
initcall pkt_init+0x0/0x222 returned 0 after 0 usecs
calling  mm_init+0x0/0x1ca @ 1
MM: desc_per_page =3D 128
initcall mm_init+0x0/0x1ca returned 0 after 3255 usecs
calling  nbd_init+0x0/0x340 @ 1
nbd: registered device at major 43
initcall nbd_init+0x0/0x340 returned 0 after 13020 usecs
calling  ub_init+0x0/0x92 @ 1
usbcore: registered new interface driver ub
initcall ub_init+0x0/0x92 returned 0 after 3255 usecs
calling  ioc4_init+0x0/0x20 @ 1
initcall ioc4_init+0x0/0x20 returned 0 after 0 usecs
calling  enclosure_init+0x0/0x19 @ 1
initcall enclosure_init+0x0/0x19 returned 0 after 0 usecs
calling  ilo_init+0x0/0x97 @ 1
initcall ilo_init+0x0/0x97 returned 0 after 0 usecs
calling  isl29003_init+0x0/0x14 @ 1
initcall isl29003_init+0x0/0x14 returned 0 after 0 usecs
calling  c2port_init+0x0/0x52 @ 1
Silicon Labs C2 port support v. 0.51.0 - (C) 2007 Rodolfo Giometti
initcall c2port_init+0x0/0x52 returned 0 after 3255 usecs
calling  duramar2150_c2port_init+0x0/0x72 @ 1
c2port c2port0: C2 port uc added
c2port c2port0: uc flash has 30 blocks x 512 bytes (15360 bytes total)
initcall duramar2150_c2port_init+0x0/0x72 returned 0 after 6510 usecs
calling  at24_init+0x0/0x33 @ 1
initcall at24_init+0x0/0x33 returned 0 after 0 usecs
calling  eeprom_init+0x0/0x14 @ 1
initcall eeprom_init+0x0/0x14 returned 0 after 3255 usecs
calling  cb710_init_module+0x0/0x1b @ 1
initcall cb710_init_module+0x0/0x1b returned 0 after 0 usecs
calling  scsi_tgt_init+0x0/0x90 @ 1
initcall scsi_tgt_init+0x0/0x90 returned 0 after 0 usecs
calling  spi_transport_init+0x0/0x30 @ 1
initcall spi_transport_init+0x0/0x30 returned 0 after 0 usecs
calling  fc_transport_init+0x0/0x4e @ 1
initcall fc_transport_init+0x0/0x4e returned 0 after 0 usecs
calling  iscsi_transport_init+0x0/0x157 @ 1
Loading iSCSI transport class v2.0-870.
initcall iscsi_transport_init+0x0/0x157 returned 0 after 3255 usecs
calling  sas_transport_init+0x0/0xbf @ 1
initcall sas_transport_init+0x0/0xbf returned 0 after 0 usecs
calling  sas_class_init+0x0/0x31 @ 1
initcall sas_class_init+0x0/0x31 returned 0 after 0 usecs
calling  scsi_dh_init+0x0/0x42 @ 1
initcall scsi_dh_init+0x0/0x42 returned 0 after 0 usecs
calling  rdac_init+0x0/0x34 @ 1
rdac: device handler registered
initcall rdac_init+0x0/0x34 returned 0 after 3255 usecs
calling  ahc_linux_init+0x0/0x74 @ 1
initcall ahc_linux_init+0x0/0x74 returned 0 after 0 usecs
calling  init_st+0x0/0x1c8 @ 1
st: Version 20081215, fixed bufsize 32768, s/g segs 256
Driver 'st' needs updating - please use bus_type methods
initcall init_st+0x0/0x1c8 returned 0 after 6510 usecs
calling  init_sd+0x0/0x140 @ 1
Driver 'sd' needs updating - please use bus_type methods
initcall init_sd+0x0/0x140 returned 0 after 3255 usecs
calling  init_sg+0x0/0x14d @ 1
initcall init_sg+0x0/0x14d returned 0 after 0 usecs
calling  osd_uld_init+0x0/0xd6 @ 1
Driver 'osd' needs updating - please use bus_type methods
osd: LOADED open-osd 0.1.0
initcall osd_uld_init+0x0/0xd6 returned 0 after 3255 usecs
calling  ahci_init+0x0/0x1b @ 1
initcall ahci_init+0x0/0x1b returned 0 after 0 usecs
calling  k2_sata_init+0x0/0x1b @ 1
initcall k2_sata_init+0x0/0x1b returned 0 after 0 usecs
calling  piix_init+0x0/0x29 @ 1
initcall piix_init+0x0/0x29 returned 0 after 0 usecs
calling  qs_ata_init+0x0/0x1b @ 1
initcall qs_ata_init+0x0/0x1b returned 0 after 0 usecs
calling  sil24_init+0x0/0x1b @ 1
initcall sil24_init+0x0/0x1b returned 0 after 0 usecs
calling  svia_init+0x0/0x1b @ 1
initcall svia_init+0x0/0x1b returned 0 after 0 usecs
calling  vsc_sata_init+0x0/0x1b @ 1
initcall vsc_sata_init+0x0/0x1b returned 0 after 0 usecs
calling  sis_init+0x0/0x1b @ 1
initcall sis_init+0x0/0x1b returned 0 after 0 usecs
calling  pdc_sata_init+0x0/0x1b @ 1
initcall pdc_sata_init+0x0/0x1b returned 0 after 0 usecs
calling  nv_init+0x0/0x1b @ 1
initcall nv_init+0x0/0x1b returned 0 after 0 usecs
calling  uli_init+0x0/0x1b @ 1
initcall uli_init+0x0/0x1b returned 0 after 3255 usecs
calling  ali_init+0x0/0x53 @ 1
initcall ali_init+0x0/0x53 returned 0 after 0 usecs
calling  amd_init+0x0/0x1b @ 1
pata_amd 0000:00:06.0: version 0.4.1
pata_amd 0000:00:06.0: setting latency timer to 64
scsi0 : pata_amd
scsi1 : pata_amd
ata1: PATA max UDMA/133 cmd 0x1f0 ctl 0x3f6 bmdma 0xf000 irq 14
ata2: PATA max UDMA/133 cmd 0x170 ctl 0x376 bmdma 0xf008 irq 15
ata1.00: ATA-6: HDS722525VLAT80, V36OA60A, max UDMA/100
ata1.00: 488397168 sectors, multi 1: LBA48=20
ata1: nv_mode_filter: 0x3f39f&0x3f07f->0x3f01f, BIOS=3D0x3f000 (0xc6000=
0c0) ACPI=3D0x0
ata1.00: configured for UDMA/100
async_waiting @ 1
async_continuing @ 1 after 0 usec
scsi 0:0:0:0: Direct-Access     ATA      HDS722525VLAT80  V36O PQ: 0 AN=
SI: 5
sd 0:0:0:0: [sda] 488397168 512-byte hardware sectors: (250 GB/232 GiB)
sd 0:0:0:0: [sda] Write Protect is off
sd 0:0:0:0: [sda] Mode Sense: 00 3a 00 00
sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't su=
pport DPO or FUA
 sda: sda1 sda2 sda3 < sda5 sda6 sda7 sda8 sda9 sda10 >
sd 0:0:0:0: [sda] Attached SCSI disk
sd 0:0:0:0: Attached scsi generic sg0 type 0
async_waiting @ 1
async_continuing @ 1 after 0 usec
ata2.01: ATAPI: DVDRW IDE 16X, VER A079, max UDMA/66
ata2: nv_mode_filter: 0x1f39f&0x707f->0x701f, BIOS=3D0x7000 (0xc60000c0=
) ACPI=3D0x0
ata2.01: configured for UDMA/33
async_waiting @ 1
async_continuing @ 1 after 0 usec
scsi 1:0:1:0: CD-ROM            DVDRW    IDE 16X          A079 PQ: 0 AN=
SI: 5
scsi 1:0:1:0: Attached scsi generic sg1 type 5
initcall amd_init+0x0/0x1b returned 0 after 533854 usecs
calling  artop_init+0x0/0x1b @ 1
initcall artop_init+0x0/0x1b returned 0 after 0 usecs
calling  atiixp_init+0x0/0x1b @ 1
initcall atiixp_init+0x0/0x1b returned 0 after 0 usecs
calling  cmd640_init+0x0/0x1b @ 1
initcall cmd640_init+0x0/0x1b returned 0 after 0 usecs
calling  cmd64x_init+0x0/0x1b @ 1
initcall cmd64x_init+0x0/0x1b returned 0 after 0 usecs
calling  cs5520_init+0x0/0x1b @ 1
initcall cs5520_init+0x0/0x1b returned 0 after 0 usecs
calling  cs5530_init+0x0/0x1b @ 1
initcall cs5530_init+0x0/0x1b returned 0 after 0 usecs
calling  efar_init+0x0/0x1b @ 1
initcall efar_init+0x0/0x1b returned 0 after 3255 usecs
calling  hpt36x_init+0x0/0x1b @ 1
initcall hpt36x_init+0x0/0x1b returned 0 after 0 usecs
calling  hpt3x2n_init+0x0/0x1b @ 1
initcall hpt3x2n_init+0x0/0x1b returned 0 after 0 usecs
calling  it821x_init+0x0/0x1b @ 1
initcall it821x_init+0x0/0x1b returned 0 after 0 usecs
calling  it8213_init+0x0/0x1b @ 1
initcall it8213_init+0x0/0x1b returned 0 after 0 usecs
calling  netcell_init+0x0/0x1b @ 1
initcall netcell_init+0x0/0x1b returned 0 after 0 usecs
calling  ninja32_init+0x0/0x1b @ 1
initcall ninja32_init+0x0/0x1b returned 0 after 3255 usecs
calling  ns87410_init+0x0/0x1b @ 1
initcall ns87410_init+0x0/0x1b returned 0 after 0 usecs
calling  ns87415_init+0x0/0x1b @ 1
initcall ns87415_init+0x0/0x1b returned 0 after 0 usecs
calling  opti_init+0x0/0x1b @ 1
initcall opti_init+0x0/0x1b returned 0 after 0 usecs
calling  marvell_init+0x0/0x1b @ 1
initcall marvell_init+0x0/0x1b returned 0 after 0 usecs
calling  oldpiix_init+0x0/0x1b @ 1
initcall oldpiix_init+0x0/0x1b returned 0 after 0 usecs
calling  pdc2027x_init+0x0/0x1b @ 1
initcall pdc2027x_init+0x0/0x1b returned 0 after 0 usecs
calling  pdc202xx_init+0x0/0x1b @ 1
initcall pdc202xx_init+0x0/0x1b returned 0 after 0 usecs
calling  radisys_init+0x0/0x1b @ 1
initcall radisys_init+0x0/0x1b returned 0 after 0 usecs
calling  rz1000_init+0x0/0x1b @ 1
initcall rz1000_init+0x0/0x1b returned 0 after 0 usecs
calling  sc1200_init+0x0/0x1b @ 1
initcall sc1200_init+0x0/0x1b returned 0 after 0 usecs
calling  serverworks_init+0x0/0x1b @ 1
initcall serverworks_init+0x0/0x1b returned 0 after 0 usecs
calling  sil680_init+0x0/0x1b @ 1
initcall sil680_init+0x0/0x1b returned 0 after 0 usecs
calling  via_init+0x0/0x1b @ 1
initcall via_init+0x0/0x1b returned 0 after 0 usecs
calling  sis_init+0x0/0x1b @ 1
initcall sis_init+0x0/0x1b returned 0 after 3255 usecs
calling  pata_platform_init+0x0/0x1a @ 1
initcall pata_platform_init+0x0/0x1a returned 0 after 0 usecs
calling  e1000_init_module+0x0/0x70 @ 1
e1000e: Intel(R) PRO/1000 Network Driver - 1.0.2-k2
e1000e: Copyright (c) 1999-2008 Intel Corporation.
initcall e1000_init_module+0x0/0x70 returned 0 after 6510 usecs
calling  igbvf_init_module+0x0/0x70 @ 1
Intel(R) Virtual Function Network Driver - version 1.0.0-k0
Copyright (c) 2009 Intel Corporation.
initcall igbvf_init_module+0x0/0x70 returned 0 after 6510 usecs
calling  ixgbe_init_module+0x0/0x5a @ 1
ixgbe: Intel(R) 10 Gigabit PCI Express Network Driver - version 2.0.34-=
k2
ixgbe: Copyright (c) 1999-2009 Intel Corporation.
initcall ixgbe_init_module+0x0/0x5a returned 0 after 6510 usecs
calling  ixgb_init_module+0x0/0x4c @ 1
Intel(R) PRO/10GbE Network Driver - version 1.0.135-k2-NAPI
Copyright (c) 1999-2008 Intel Corporation.
initcall ixgb_init_module+0x0/0x4c returned 0 after 6510 usecs
calling  ipg_init_module+0x0/0x1b @ 1
initcall ipg_init_module+0x0/0x1b returned 0 after 0 usecs
calling  cxgb3_init_module+0x0/0x20 @ 1
initcall cxgb3_init_module+0x0/0x20 returned 0 after 0 usecs
calling  vcan_init_module+0x0/0x3a @ 1
vcan: Virtual CAN interface driver
initcall vcan_init_module+0x0/0x3a returned 0 after 3255 usecs
calling  can_dev_init+0x0/0x34 @ 1
CAN device driver interface
initcall can_dev_init+0x0/0x34 returned 0 after 0 usecs
calling  sja1000_init+0x0/0x1d @ 1
sja1000 CAN netdevice driver
initcall sja1000_init+0x0/0x1d returned 0 after 0 usecs
calling  sp_init+0x0/0x12 @ 1
initcall sp_init+0x0/0x12 returned 0 after 0 usecs
calling  kvaser_pci_init+0x0/0x1b @ 1
initcall kvaser_pci_init+0x0/0x1b returned 0 after 0 usecs
calling  atl1_init_module+0x0/0x1b @ 1
initcall atl1_init_module+0x0/0x1b returned 0 after 0 usecs
calling  atl1e_init_module+0x0/0x1b @ 1
initcall atl1e_init_module+0x0/0x1b returned 0 after 0 usecs
calling  enic_init_module+0x0/0x37 @ 1
enic: Cisco 10G Ethernet Driver, ver 1.0.0.933
initcall enic_init_module+0x0/0x37 returned 0 after 3255 usecs
calling  plip_init+0x0/0x61 @ 1
plip: parport0 has no IRQ. Using IRQ-less mode,which is fairly ineffici=
ent!
NET3 PLIP version 2.4-parport gniibe@mri.co.jp
plip0: Parallel port at 0x378, not using IRQ.
initcall plip_init+0x0/0x61 returned 0 after 13020 usecs
calling  happy_meal_probe+0x0/0x1b @ 1
initcall happy_meal_probe+0x0/0x1b returned 0 after 0 usecs
calling  cas_init+0x0/0x3d @ 1
initcall cas_init+0x0/0x3d returned 0 after 0 usecs
calling  vortex_init+0x0/0xc3 @ 1
initcall vortex_init+0x0/0xc3 returned 0 after 0 usecs
calling  typhoon_init+0x0/0x1b @ 1
initcall typhoon_init+0x0/0x1b returned 0 after 0 usecs
calling  ne2k_pci_init+0x0/0x1b @ 1
initcall ne2k_pci_init+0x0/0x1b returned 0 after 0 usecs
calling  e100_init_module+0x0/0x5f @ 1
e100: Intel(R) PRO/100 Network Driver, 3.5.24-k2-NAPI
e100: Copyright(c) 1999-2006 Intel Corporation
initcall e100_init_module+0x0/0x5f returned 0 after 6510 usecs
calling  tlan_probe+0x0/0xec @ 1
ThunderLAN driver v1.15a
TLAN: 0 devices installed, PCI: 0  EISA: 0
initcall tlan_probe+0x0/0xec returned -19 after 6510 usecs
calling  epic_init+0x0/0x1b @ 1
initcall epic_init+0x0/0x1b returned 0 after 0 usecs
calling  sis190_init_module+0x0/0x1b @ 1
initcall sis190_init_module+0x0/0x1b returned 0 after 0 usecs
calling  sis900_init_module+0x0/0x1b @ 1
initcall sis900_init_module+0x0/0x1b returned 0 after 0 usecs
calling  yellowfin_init+0x0/0x1b @ 1
initcall yellowfin_init+0x0/0x1b returned 0 after 0 usecs
calling  acenic_init+0x0/0x1b @ 1
initcall acenic_init+0x0/0x1b returned 0 after 3255 usecs
calling  ns83820_init+0x0/0x29 @ 1
ns83820.c: National Semiconductor DP83820 10/100/1000 driver.
initcall ns83820_init+0x0/0x29 returned 0 after 3255 usecs
calling  fealnx_init+0x0/0x1b @ 1
initcall fealnx_init+0x0/0x1b returned 0 after 0 usecs
calling  tg3_init+0x0/0x1b @ 1
initcall tg3_init+0x0/0x1b returned 0 after 0 usecs
calling  bnx2_init+0x0/0x1b @ 1
initcall bnx2_init+0x0/0x1b returned 0 after 0 usecs
calling  bnx2x_init+0x0/0x87 @ 1
initcall bnx2x_init+0x0/0x87 returned 0 after 0 usecs
calling  skge_init_module+0x0/0x59 @ 1
initcall skge_init_module+0x0/0x59 returned 0 after 0 usecs
calling  sky2_init_module+0x0/0x57 @ 1
sky2 driver version 1.22
initcall sky2_init_module+0x0/0x57 returned 0 after 0 usecs
calling  skfd_init+0x0/0x1b @ 1
initcall skfd_init+0x0/0x1b returned 0 after 0 usecs
calling  rhine_init+0x0/0x6d @ 1
initcall rhine_init+0x0/0x6d returned 0 after 0 usecs
calling  starfire_init+0x0/0x1d @ 1
initcall starfire_init+0x0/0x1d returned 0 after 0 usecs
calling  davicom_init+0x0/0x62 @ 1
initcall davicom_init+0x0/0x62 returned 0 after 0 usecs
calling  cicada_init+0x0/0x44 @ 1
initcall cicada_init+0x0/0x44 returned 0 after 0 usecs
calling  realtek_init+0x0/0x12 @ 1
initcall realtek_init+0x0/0x12 returned 0 after 0 usecs
calling  fixed_mdio_bus_init+0x0/0xd8 @ 1
=46ixed MDIO Bus: probed
initcall fixed_mdio_bus_init+0x0/0xd8 returned 0 after 3255 usecs
calling  ste10Xp_init+0x0/0x22 @ 1
initcall ste10Xp_init+0x0/0x22 returned 0 after 0 usecs
calling  sundance_init+0x0/0x1b @ 1
initcall sundance_init+0x0/0x1b returned 0 after 0 usecs
calling  hamachi_init+0x0/0x1e @ 1
initcall hamachi_init+0x0/0x1e returned 0 after 0 usecs
calling  net_olddevs_init+0x0/0x9d @ 1
initcall net_olddevs_init+0x0/0x9d returned 0 after 0 usecs
calling  hp100_module_init+0x0/0x1b @ 1
initcall hp100_module_init+0x0/0x1b returned 0 after 0 usecs
calling  init_nic+0x0/0x1b @ 1
forcedeth: Reverse Engineered nForce ethernet driver. Version 0.64.
IOAPIC[0]: Set routing entry (2-11 -> 0x3b -> IRQ 11 Mode:1 Active:1)
forcedeth 0000:00:0a.0: PCI->APIC IRQ transform: INT A -> IRQ 11
forcedeth 0000:00:0a.0: setting latency timer to 64
nv_probe: set workaround bit for reversed mac addr
forcedeth 0000:00:0a.0: ifname eth0, PHY OUI 0x5043 @ 1, addr 00:13:d4:=
dc:41:12
forcedeth 0000:00:0a.0: highdma csum gbit lnktim desc-v3
initcall init_nic+0x0/0x1b returned 0 after 530598 usecs
calling  qlge_init_module+0x0/0x1b @ 1
initcall qlge_init_module+0x0/0x1b returned 0 after 0 usecs
calling  ppp_init+0x0/0xe4 @ 1
PPP generic driver version 2.4.2
initcall ppp_init+0x0/0xe4 returned 0 after 3255 usecs
calling  ppp_async_init+0x0/0x3b @ 1
initcall ppp_async_init+0x0/0x3b returned 0 after 0 usecs
calling  ppp_sync_init+0x0/0x3b @ 1
initcall ppp_sync_init+0x0/0x3b returned 0 after 0 usecs
calling  bsdcomp_init+0x0/0x34 @ 1
PPP BSD Compression module registered
initcall bsdcomp_init+0x0/0x34 returned 0 after 3255 usecs
calling  pppox_init+0x0/0x12 @ 1
NET: Registered protocol family 24
initcall pppox_init+0x0/0x12 returned 0 after 3255 usecs
calling  pppoe_init+0x0/0x8e @ 1
initcall pppoe_init+0x0/0x8e returned 0 after 0 usecs
calling  pppol2tp_init+0x0/0x85 @ 1
PPPoL2TP kernel driver, V1.0
initcall pppol2tp_init+0x0/0x85 returned 0 after 3255 usecs
calling  slip_init+0x0/0xbf @ 1
SLIP: version 0.8.4-NET3.019-NEWTTY (dynamic channels, max=3D256).
SLIP linefill/keepalive option.
initcall slip_init+0x0/0xbf returned 0 after 6510 usecs
calling  dummy_init_module+0x0/0x100 @ 1
initcall dummy_init_module+0x0/0x100 returned 0 after 0 usecs
calling  ifb_init_module+0x0/0xed @ 1
initcall ifb_init_module+0x0/0xed returned 0 after 0 usecs
calling  macvlan_init_module+0x0/0x56 @ 1
initcall macvlan_init_module+0x0/0x56 returned 0 after 0 usecs
calling  dfx_init+0x0/0x20 @ 1
initcall dfx_init+0x0/0x20 returned 0 after 0 usecs
calling  cp_init+0x0/0x1b @ 1
<6>8139cp: 10/100 PCI Ethernet driver v1.3 (Mar 22, 2004)
8139cp 0000:05:07.0: This (id 10ec:8139 rev 10) is not an 8139C+ compat=
ible chip, use 8139too
initcall cp_init+0x0/0x1b returned 0 after 6510 usecs
calling  rtl8139_init_module+0x0/0x1b @ 1
8139too Fast Ethernet driver 0.9.28
8139too 0000:05:07.0: PCI->APIC IRQ transform: INT A -> IRQ 11
eth1: RealTek RTL8139 at 0xc000, 00:c0:df:03:68:5d, IRQ 11
initcall rtl8139_init_module+0x0/0x1b returned 0 after 13020 usecs
calling  sc92031_init+0x0/0x1b @ 1
initcall sc92031_init+0x0/0x1b returned 0 after 0 usecs
calling  tun_init+0x0/0x98 @ 1
tun: Universal TUN/TAP device driver, 1.6
tun: (C) 1999-2004 Max Krasnyansky <maxk@qualcomm.com>
initcall tun_init+0x0/0x98 returned 0 after 6510 usecs
calling  veth_init+0x0/0x12 @ 1
initcall veth_init+0x0/0x12 returned 0 after 0 usecs
calling  rio_init+0x0/0x1b @ 1
initcall rio_init+0x0/0x1b returned 0 after 0 usecs
calling  amd8111e_init+0x0/0x1b @ 1
initcall amd8111e_init+0x0/0x1b returned 0 after 0 usecs
calling  s2io_starter+0x0/0x1b @ 1
initcall s2io_starter+0x0/0x1b returned 0 after 3255 usecs
calling  myri10ge_init_module+0x0/0x76 @ 1
myri10ge: Version 1.5.0-1.418
initcall myri10ge_init_module+0x0/0x76 returned 0 after 3255 usecs
calling  ethoc_init+0x0/0x12 @ 1
initcall ethoc_init+0x0/0x12 returned 0 after 0 usecs
calling  dnet_init+0x0/0x12 @ 1
initcall dnet_init+0x0/0x12 returned 0 after 0 usecs
calling  hdlc_module_init+0x0/0x45 @ 1
HDLC support module revision 1.22
initcall hdlc_module_init+0x0/0x45 returned 0 after 3255 usecs
calling  mod_init+0x0/0x14 @ 1
initcall mod_init+0x0/0x14 returned 0 after 0 usecs
calling  mod_init+0x0/0x14 @ 1
initcall mod_init+0x0/0x14 returned 0 after 0 usecs
calling  fst_init+0x0/0x4f @ 1
initcall fst_init+0x0/0x4f returned 0 after 0 usecs
calling  wanxl_init_module+0x0/0x1b @ 1
initcall wanxl_init_module+0x0/0x1b returned 0 after 0 usecs
calling  pci200_init_module+0x0/0x42 @ 1
initcall pci200_init_module+0x0/0x42 returned 0 after 0 usecs
calling  pc300_init_module+0x0/0x73 @ 1
initcall pc300_init_module+0x0/0x73 returned 0 after 0 usecs
calling  catc_init+0x0/0x3d @ 1
usbcore: registered new interface driver catc
catc: v2.8:CATC EL1210A NetMate USB Ethernet driver
initcall catc_init+0x0/0x3d returned 0 after 6510 usecs
calling  pegasus_init+0x0/0x18d @ 1
pegasus: v0.6.14 (2006/09/27), Pegasus/Pegasus II USB Ethernet driver
usbcore: registered new interface driver pegasus
initcall pegasus_init+0x0/0x18d returned 0 after 6510 usecs
calling  usb_rtl8150_init+0x0/0x29 @ 1
rtl8150: v0.6.2 (2004/08/27):rtl8150 based usb-ethernet driver
usbcore: registered new interface driver rtl8150
initcall usb_rtl8150_init+0x0/0x29 returned 0 after 6510 usecs
calling  hso_init+0x0/0x1ec @ 1
hso: drivers/net/usb/hso.c: 1.2 Option Wireless
usbcore: registered new interface driver hso
initcall hso_init+0x0/0x1ec returned 0 after 6510 usecs
calling  cdc_init+0x0/0x1b @ 1
usbcore: registered new interface driver cdc_ether
initcall cdc_init+0x0/0x1b returned 0 after 3255 usecs
calling  dm9601_init+0x0/0x1b @ 1
usbcore: registered new interface driver dm9601
initcall dm9601_init+0x0/0x1b returned 0 after 3255 usecs
calling  smsc95xx_init+0x0/0x1b @ 1
usbcore: registered new interface driver smsc95xx
initcall smsc95xx_init+0x0/0x1b returned 0 after 3255 usecs
calling  usbnet_init+0x0/0x1b @ 1
usbcore: registered new interface driver gl620a
initcall usbnet_init+0x0/0x1b returned 0 after 3255 usecs
calling  net1080_init+0x0/0x1b @ 1
usbcore: registered new interface driver net1080
initcall net1080_init+0x0/0x1b returned 0 after 3255 usecs
calling  plusb_init+0x0/0x1b @ 1
usbcore: registered new interface driver plusb
initcall plusb_init+0x0/0x1b returned 0 after 3255 usecs
calling  rndis_init+0x0/0x1b @ 1
usbcore: registered new interface driver rndis_host
initcall rndis_init+0x0/0x1b returned 0 after 3255 usecs
calling  mcs7830_init+0x0/0x1b @ 1
usbcore: registered new interface driver MOSCHIP usb-ethernet driver
initcall mcs7830_init+0x0/0x1b returned 0 after 3255 usecs
calling  usbnet_init+0x0/0x2c @ 1
initcall usbnet_init+0x0/0x2c returned 0 after 0 usecs
calling  ipw2100_init+0x0/0x87 @ 1
ipw2100: Intel(R) PRO/Wireless 2100 Network Driver, git-1.2.2
ipw2100: Copyright(c) 2003-2006 Intel Corporation
initcall ipw2100_init+0x0/0x87 returned 0 after 6510 usecs
calling  ieee80211_init+0x0/0xb8 @ 1
ieee80211: 802.11 data/management/control stack, git-1.1.13
ieee80211: Copyright (C) 2004-2005 Intel Corporation <jketreno@linux.in=
tel.com>
initcall ieee80211_init+0x0/0xb8 returned 0 after 6510 usecs
calling  strip_init_driver+0x0/0x6f @ 1
STRIP: Version 1.3A-STUART.CHESHIRE (unlimited channels)
initcall strip_init_driver+0x0/0x6f returned 0 after 3255 usecs
calling  init_orinoco+0x0/0x1d @ 1
orinoco 0.15 (David Gibson <hermes@gibson.dropbear.id.au>, Pavel Roskin=
 <proski@gnu.org>, et al)
initcall init_orinoco+0x0/0x1d returned 0 after 3255 usecs
calling  orinoco_plx_init+0x0/0x30 @ 1
orinoco_plx 0.15 (Pavel Roskin <proski@gnu.org>, David Gibson <hermes@g=
ibson.dropbear.id.au>, Daniel Barlow <dan@telent.net>)
initcall orinoco_plx_init+0x0/0x30 returned 0 after 3255 usecs
calling  airo_init_module+0x0/0xf4 @ 1
airo(): Probing for PCI adapters
airo(): Finished probing for PCI adapters
initcall airo_init_module+0x0/0xf4 returned 0 after 6510 usecs
calling  atmel_init_module+0x0/0x1b @ 1
initcall atmel_init_module+0x0/0x1b returned 0 after 0 usecs
calling  hostap_init+0x0/0x47 @ 1
initcall hostap_init+0x0/0x47 returned 0 after 0 usecs
calling  init_prism2_plx+0x0/0x1b @ 1
initcall init_prism2_plx+0x0/0x1b returned 0 after 0 usecs
calling  init_prism2_pci+0x0/0x1b @ 1
initcall init_prism2_pci+0x0/0x1b returned 0 after 0 usecs
calling  zd1201_init+0x0/0x1b @ 1
usbcore: registered new interface driver zd1201
initcall zd1201_init+0x0/0x1b returned 0 after 3255 usecs
calling  lbs_init_module+0x0/0xe5 @ 1
initcall lbs_init_module+0x0/0xe5 returned 0 after 0 usecs
calling  if_sdio_init_module+0x0/0xeb @ 1
libertas_sdio: Libertas SDIO driver
libertas_sdio: Copyright Pierre Ossman
initcall if_sdio_init_module+0x0/0xeb returned 0 after 6510 usecs
calling  w840_init+0x0/0x29 @ 1
winbond-840.c:v1.01-e (2.4 port) Sep-11-2006  Donald Becker <becker@scy=
ld.com>
  http://www.scyld.com/network/drivers.html
initcall w840_init+0x0/0x29 returned 0 after 3255 usecs
calling  de_init+0x0/0x1b @ 1
initcall de_init+0x0/0x1b returned 0 after 0 usecs
calling  de4x5_module_init+0x0/0x1b @ 1
initcall de4x5_module_init+0x0/0x1b returned 0 after 0 usecs
calling  init_netconsole+0x0/0x2a5 @ 1
console [netcon0] enabled
netconsole: network logging started
initcall init_netconsole+0x0/0x2a5 returned 0 after 3255 usecs
calling  niu_init+0x0/0x41 @ 1
initcall niu_init+0x0/0x41 returned 0 after 0 usecs
calling  init+0x0/0x12 @ 1
initcall init+0x0/0x12 returned 0 after 0 usecs
calling  efx_init_module+0x0/0xd7 @ 1
Solarflare NET driver v2.3
initcall efx_init_module+0x0/0xd7 returned 0 after 3255 usecs
calling  i2400m_driver_init+0x0/0x8 @ 1
initcall i2400m_driver_init+0x0/0x8 returned 0 after 0 usecs
calling  i2400ms_driver_init+0x0/0x12 @ 1
initcall i2400ms_driver_init+0x0/0x12 returned 0 after 0 usecs
calling  zatm_init_module+0x0/0x1b @ 1
initcall zatm_init_module+0x0/0x1b returned 0 after 0 usecs
calling  uPD98402_module_init+0x0/0x8 @ 1
initcall uPD98402_module_init+0x0/0x8 returned 0 after 0 usecs
calling  amb_module_init+0x0/0x1da @ 1
Madge ATM Ambassador driver version 1.2.4
amb: debug bitmap is 0
initcall amb_module_init+0x0/0x1da returned 0 after 6510 usecs
calling  eni_init+0x0/0x1b @ 1
initcall eni_init+0x0/0x1b returned 0 after 0 usecs
calling  idt77252_init+0x0/0x37 @ 1
idt77252_init: at ffffffff82532799
initcall idt77252_init+0x0/0x37 returned 0 after 3255 usecs
calling  solos_pci_init+0x0/0x30 @ 1
Solos PCI Driver Version 0.07
initcall solos_pci_init+0x0/0x30 returned 0 after 3255 usecs
calling  adummy_init+0x0/0x105 @ 1
adummy: version 1.0
initcall adummy_init+0x0/0x105 returned 0 after 0 usecs
calling  atmtcp_init+0x0/0x14 @ 1
initcall atmtcp_init+0x0/0x14 returned 0 after 0 usecs
calling  lanai_module_init+0x0/0x47 @ 1
initcall lanai_module_init+0x0/0x47 returned 0 after 0 usecs
calling  i2o_iop_init+0x0/0x62 @ 1
I2O subsystem v1.325
i2o: max drivers =3D 8
initcall i2o_iop_init+0x0/0x62 returned 0 after 6510 usecs
calling  i2o_block_init+0x0/0x126 @ 1
I2O Block Device OSM v1.325
initcall i2o_block_init+0x0/0x126 returned 0 after 3255 usecs
calling  i2o_scsi_init+0x0/0x49 @ 1
I2O SCSI Peripheral OSM v1.316
initcall i2o_scsi_init+0x0/0x49 returned 0 after 3255 usecs
calling  i2o_proc_init+0x0/0x20c @ 1
I2O ProcFS OSM v1.316
initcall i2o_proc_init+0x0/0x20c returned 0 after 3255 usecs
calling  fusion_init+0x0/0x140 @ 1
=46usion MPT base driver 3.04.10
Copyright (c) 1999-2008 LSI Corporation
initcall fusion_init+0x0/0x140 returned 0 after 3255 usecs
calling  mptsas_init+0x0/0x10f @ 1
=46usion MPT SAS Host driver 3.04.10
initcall mptsas_init+0x0/0x10f returned 0 after 3255 usecs
calling  mptctl_init+0x0/0x122 @ 1
=46usion MPT misc device (ioctl) driver 3.04.10
mptctl: Registered with Fusion MPT base driver
mptctl: /dev/mptctl @ (major,minor=3D10,220)
initcall mptctl_init+0x0/0x122 returned 0 after 9765 usecs
calling  fw_core_init+0x0/0x89 @ 1
initcall fw_core_init+0x0/0x89 returned 0 after 0 usecs
calling  fw_ohci_init+0x0/0x1b @ 1
initcall fw_ohci_init+0x0/0x1b returned 0 after 0 usecs
calling  sbp2_init+0x0/0x46 @ 1
initcall sbp2_init+0x0/0x46 returned 0 after 0 usecs
calling  uio_init+0x0/0x8 @ 1
initcall uio_init+0x0/0x8 returned 0 after 0 usecs
calling  hilscher_init_module+0x0/0x1b @ 1
initcall hilscher_init_module+0x0/0x1b returned 0 after 0 usecs
calling  uio_pdrv_genirq_init+0x0/0x12 @ 1
initcall uio_pdrv_genirq_init+0x0/0x12 returned 0 after 0 usecs
calling  smx_ce_init_module+0x0/0x12 @ 1
initcall smx_ce_init_module+0x0/0x12 returned 0 after 0 usecs
calling  cdrom_init+0x0/0x6a @ 1
initcall cdrom_init+0x0/0x6a returned 0 after 0 usecs
calling  nonstatic_sysfs_init+0x0/0x12 @ 1
initcall nonstatic_sysfs_init+0x0/0x12 returned 0 after 0 usecs
calling  yenta_socket_init+0x0/0x24 @ 1
initcall yenta_socket_init+0x0/0x24 returned 0 after 3255 usecs
calling  aoe_init+0x0/0xb1 @ 1
aoe: AoE v47 initialised.
initcall aoe_init+0x0/0xb1 returned 0 after 3255 usecs
calling  uwb_subsys_init+0x0/0x5a @ 1
initcall uwb_subsys_init+0x0/0x5a returned 0 after 0 usecs
calling  wlp_subsys_init+0x0/0x8 @ 1
initcall wlp_subsys_init+0x0/0x8 returned 0 after 0 usecs
calling  umc_bus_init+0x0/0x12 @ 1
initcall umc_bus_init+0x0/0x12 returned 0 after 0 usecs
calling  whci_init+0x0/0x1b @ 1
initcall whci_init+0x0/0x1b returned 0 after 0 usecs
calling  whcrc_driver_init+0x0/0x1b @ 1
initcall whcrc_driver_init+0x0/0x1b returned 0 after 0 usecs
calling  hwarc_driver_init+0x0/0x1b @ 1
usbcore: registered new interface driver hwa-rc
initcall hwarc_driver_init+0x0/0x1b returned 0 after 3255 usecs
calling  i1480_dfu_driver_init+0x0/0x1b @ 1
usbcore: registered new interface driver i1480-dfu-usb
initcall i1480_dfu_driver_init+0x0/0x1b returned 0 after 3255 usecs
calling  i1480_est_init+0x0/0xa0 @ 1
initcall i1480_est_init+0x0/0xa0 returned 0 after 0 usecs
calling  mon_init+0x0/0x11d @ 1
initcall mon_init+0x0/0x11d returned 0 after 3255 usecs
calling  ehci_hcd_init+0x0/0x79 @ 1
ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
ehci_hcd 0000:00:02.1: can't find IRQ for PCI INT B; probably buggy MP =
table
ehci_hcd 0000:00:02.1: Found HC with no IRQ.  Check BIOS/PCI 0000:00:02=
=2E1 setup!
ehci_hcd 0000:00:02.1: init 0000:00:02.1 fail, -19
initcall ehci_hcd_init+0x0/0x79 returned 0 after 13020 usecs
calling  isp116x_init+0x0/0x42 @ 1
116x: driver isp116x-hcd, 03 Nov 2005
initcall isp116x_init+0x0/0x42 returned 0 after 3255 usecs
calling  ohci_hcd_mod_init+0x0/0x82 @ 1
ohci_hcd: USB 1.1 'Open' Host Controller (OHCI) Driver
ohci_hcd 0000:00:02.0: can't find IRQ for PCI INT A; probably buggy MP =
table
ohci_hcd 0000:00:02.0: Found HC with no IRQ.  Check BIOS/PCI 0000:00:02=
=2E0 setup!
ohci_hcd 0000:00:02.0: init 0000:00:02.0 fail, -19
initcall ohci_hcd_mod_init+0x0/0x82 returned 0 after 16276 usecs
calling  uhci_hcd_init+0x0/0xd3 @ 1
uhci_hcd: USB Universal Host Controller Interface driver
initcall uhci_hcd_init+0x0/0xd3 returned 0 after 3255 usecs
calling  u132_hcd_init+0x0/0xba @ 1
driver u132_hcd built at 12:03:09 on Jun 16 2009
initcall u132_hcd_init+0x0/0xba returned 0 after 3255 usecs
calling  r8a66597_init+0x0/0x42 @ 1
r8a66597_hcd: driver r8a66597_hcd, 10 Apr 2008
initcall r8a66597_init+0x0/0x42 returned 0 after 3255 usecs
calling  isp1760_init+0x0/0x5a @ 1
initcall isp1760_init+0x0/0x5a returned 0 after 3255 usecs
calling  hwahc_driver_init+0x0/0x1b @ 1
usbcore: registered new interface driver hwa-hc
initcall hwahc_driver_init+0x0/0x1b returned 0 after 3255 usecs
calling  c67x00_init+0x0/0x12 @ 1
initcall c67x00_init+0x0/0x12 returned 0 after 0 usecs
calling  wusbcore_init+0x0/0x73 @ 1
initcall wusbcore_init+0x0/0x73 returned 0 after 0 usecs
calling  usblp_init+0x0/0x1b @ 1
usbcore: registered new interface driver usblp
initcall usblp_init+0x0/0x1b returned 0 after 3255 usecs
calling  usbtmc_init+0x0/0x3d @ 1
usbcore: registered new interface driver usbtmc
initcall usbtmc_init+0x0/0x3d returned 0 after 3255 usecs
calling  usb_usual_init+0x0/0x43 @ 1
usbcore: registered new interface driver libusual
initcall usb_usual_init+0x0/0x43 returned 0 after 3255 usecs
calling  usb_mdc800_init+0x0/0x3db @ 1
usbcore: registered new interface driver mdc800
mdc800: v0.7.5 (30/10/2000):USB Driver for Mustek MDC800 Digital Camera
initcall usb_mdc800_init+0x0/0x3db returned 0 after 6510 usecs
calling  usb_serial_init+0x0/0x281 @ 1
usbcore: registered new interface driver usbserial
usbserial: USB Serial Driver core
initcall usb_serial_init+0x0/0x281 returned 0 after 6510 usecs
calling  aircable_init+0x0/0x4d @ 1
USB Serial support registered for aircable
usbcore: registered new interface driver aircable
initcall aircable_init+0x0/0x4d returned 0 after 6510 usecs
calling  ark3116_init+0x0/0x4d @ 1
USB Serial support registered for ark3116
usbcore: registered new interface driver ark3116
initcall ark3116_init+0x0/0x4d returned 0 after 6510 usecs
calling  belkin_sa_init+0x0/0x5d @ 1
USB Serial support registered for Belkin / Peracom / GoHubs USB Serial =
Adapter
usbcore: registered new interface driver belkin
belkin_sa: v1.2:USB Belkin Serial converter driver
initcall belkin_sa_init+0x0/0x5d returned 0 after 9765 usecs
calling  ch341_init+0x0/0x4d @ 1
USB Serial support registered for ch341-uart
usbcore: registered new interface driver ch341
initcall ch341_init+0x0/0x4d returned 0 after 6510 usecs
calling  cp210x_init+0x0/0x5d @ 1
USB Serial support registered for cp210x
usbcore: registered new interface driver cp210x
cp210x: v0.09:Silicon Labs CP210x RS232 serial adaptor driver
initcall cp210x_init+0x0/0x5d returned 0 after 13020 usecs
calling  cyberjack_init+0x0/0x6b @ 1
USB Serial support registered for Reiner SCT Cyberjack USB card reader
usbcore: registered new interface driver cyberjack
cyberjack: v1.01 Matthias Bruestle
cyberjack: REINER SCT cyberJack pinpad/e-com USB Chipcard Reader Driver
initcall cyberjack_init+0x0/0x6b returned 0 after 13020 usecs
calling  cypress_init+0x0/0xc9 @ 1
drivers/usb/serial/cypress_m8.c: cypress_init
USB Serial support registered for DeLorme Earthmate USB
USB Serial support registered for HID->COM RS232 Adapter
USB Serial support registered for Nokia CA-42 V2 Adapter
usbcore: registered new interface driver cypress
cypress_m8: v1.09:Cypress USB to Serial Driver
initcall cypress_init+0x0/0xc9 returned 0 after 19531 usecs
calling  debug_init+0x0/0x4d @ 1
USB Serial support registered for debug
usbcore: registered new interface driver debug
initcall debug_init+0x0/0x4d returned 0 after 6510 usecs
calling  digi_init+0x0/0x7b @ 1
USB Serial support registered for Digi 2 port USB adapter
USB Serial support registered for Digi 4 port USB adapter
usbcore: registered new interface driver digi_acceleport
digi_acceleport: v1.80.1.2:Digi AccelePort USB-2/USB-4 Serial Converter=
 driver
initcall digi_init+0x0/0x7b returned 0 after 13020 usecs
calling  edgeport_init+0x0/0xc7 @ 1
USB Serial support registered for Edgeport 2 port adapter
USB Serial support registered for Edgeport 4 port adapter
USB Serial support registered for Edgeport 8 port adapter
USB Serial support registered for EPiC device
usbcore: registered new interface driver io_edgeport
io_edgeport: v2.7:Edgeport USB Serial Driver
initcall edgeport_init+0x0/0xc7 returned 0 after 22786 usecs
calling  empeg_init+0x0/0x172 @ 1
USB Serial support registered for empeg
usbcore: registered new interface driver empeg
empeg: v1.2:USB Empeg Mark I/II Driver
initcall empeg_init+0x0/0x172 returned 0 after 9765 usecs
calling  ftdi_init+0x0/0xe3 @ 1
USB Serial support registered for FTDI USB Serial Device
usbcore: registered new interface driver ftdi_sio
ftdi_sio: v1.4.3:USB FTDI Serial Converters Driver
initcall ftdi_init+0x0/0xe3 returned 0 after 9765 usecs
calling  funsoft_init+0x0/0x4d @ 1
USB Serial support registered for funsoft
usbcore: registered new interface driver funsoft
initcall funsoft_init+0x0/0x4d returned 0 after 6510 usecs
calling  garmin_init+0x0/0x5d @ 1
USB Serial support registered for Garmin GPS usb/tty
usbcore: registered new interface driver garmin_gps
garmin_gps: v0.31:garmin gps driver
initcall garmin_init+0x0/0x5d returned 0 after 9765 usecs
calling  hp49gp_init+0x0/0x5d @ 1
USB Serial support registered for hp4X
usbcore: registered new interface driver hp4X
hp4x: v1.00:HP4x (48/49) Generic Serial driver
initcall hp49gp_init+0x0/0x5d returned 0 after 9765 usecs
calling  ipaq_init+0x0/0x96 @ 1
USB Serial support registered for PocketPC PDA
usbcore: registered new interface driver ipaq
ipaq: v0.5:USB PocketPC PDA driver
initcall ipaq_init+0x0/0x96 returned 0 after 9765 usecs
calling  usb_ipw_init+0x0/0x5d @ 1
USB Serial support registered for IPWireless converter
usbcore: registered new interface driver ipwtty
ipw: v0.3:IPWireless tty driver
initcall usb_ipw_init+0x0/0x5d returned 0 after 9765 usecs
calling  iuu_init+0x0/0x5d @ 1
USB Serial support registered for iuu_phoenix
usbcore: registered new interface driver iuu_phoenix
iuu_phoenix: v0.10:Infinity USB Unlimited Phoenix driver
initcall iuu_init+0x0/0x5d returned 0 after 9765 usecs
calling  keyspan_pda_init+0x0/0x99 @ 1
USB Serial support registered for Keyspan PDA
USB Serial support registered for Keyspan PDA - (prerenumeration)
USB Serial support registered for Xircom / Entregra PGS - (prerenumerat=
ion)
usbcore: registered new interface driver keyspan_pda
keyspan_pda: v1.1:USB Keyspan PDA Converter driver
initcall keyspan_pda_init+0x0/0x99 returned 0 after 16276 usecs
calling  kobil_init+0x0/0x5d @ 1
USB Serial support registered for KOBIL USB smart card terminal
usbcore: registered new interface driver kobil
kobil_sct: 21/05/2004:KOBIL USB Smart Card Terminal Driver (experimenta=
l)
initcall kobil_init+0x0/0x5d returned 0 after 9765 usecs
calling  moschip7720_init+0x0/0x89 @ 1
USB Serial support registered for Moschip 2 port adapter
mos7720: 1.0.0.4F:Moschip USB Serial Driver
usbcore: registered new interface driver moschip7720
initcall moschip7720_init+0x0/0x89 returned 0 after 9765 usecs
calling  moschip7840_init+0x0/0xdd @ 1
USB Serial support registered for Moschip 7840/7820 USB Serial Driver
mos7840: 1.3.2:Moschip 7840/7820 USB Serial Driver
usbcore: registered new interface driver mos7840
initcall moschip7840_init+0x0/0xdd returned 0 after 9765 usecs
calling  navman_init+0x0/0x4d @ 1
USB Serial support registered for navman
usbcore: registered new interface driver navman
initcall navman_init+0x0/0x4d returned 0 after 6510 usecs
calling  omninet_init+0x0/0x5d @ 1
USB Serial support registered for ZyXEL - omni.net lcd plus usb
usbcore: registered new interface driver omninet
omninet: v1.1:USB ZyXEL omni.net LCD PLUS Driver
initcall omninet_init+0x0/0x5d returned 0 after 9765 usecs
calling  opticon_init+0x0/0x4d @ 1
USB Serial support registered for opticon
usbcore: registered new interface driver opticon
initcall opticon_init+0x0/0x4d returned 0 after 6510 usecs
calling  option_init+0x0/0x5d @ 1
USB Serial support registered for GSM modem (1-port)
usbcore: registered new interface driver option
option: v0.7.2:USB Driver for GSM modems
initcall option_init+0x0/0x5d returned 0 after 9765 usecs
calling  oti6858_init+0x0/0x4d @ 1
USB Serial support registered for oti6858
usbcore: registered new interface driver oti6858
initcall oti6858_init+0x0/0x4d returned 0 after 6510 usecs
calling  qcinit+0x0/0x4d @ 1
USB Serial support registered for Qualcomm USB modem
usbcore: registered new interface driver qcserial
initcall qcinit+0x0/0x4d returned 0 after 6510 usecs
calling  sierra_init+0x0/0x5d @ 1
USB Serial support registered for Sierra USB modem
usbcore: registered new interface driver sierra
sierra: v.1.3.3:USB Driver for Sierra Wireless USB modems
initcall sierra_init+0x0/0x5d returned 0 after 9765 usecs
calling  symbol_init+0x0/0x4d @ 1
USB Serial support registered for symbol
usbcore: registered new interface driver symbol
initcall symbol_init+0x0/0x4d returned 0 after 6510 usecs
calling  ti_init+0x0/0x16d @ 1
USB Serial support registered for TI USB 3410 1 port adapter
USB Serial support registered for TI USB 5052 2 port adapter
usbcore: registered new interface driver ti_usb_3410_5052
ti_usb_3410_5052: v0.9:TI USB 3410/5052 Serial Driver
initcall ti_init+0x0/0x16d returned 0 after 13020 usecs
calling  visor_init+0x0/0x1d0 @ 1
USB Serial support registered for Handspring Visor / Palm OS
USB Serial support registered for Sony Clie 3.5
USB Serial support registered for Sony Clie 5.0
usbcore: registered new interface driver visor
visor: USB HandSpring Visor / Palm OS driver
initcall visor_init+0x0/0x1d0 returned 0 after 16276 usecs
calling  whiteheat_init+0x0/0x7b @ 1
USB Serial support registered for Connect Tech - WhiteHEAT - (prerenume=
ration)
USB Serial support registered for Connect Tech - WhiteHEAT
usbcore: registered new interface driver whiteheat
whiteheat: v2.0:USB ConnectTech WhiteHEAT driver
initcall whiteheat_init+0x0/0x7b returned 0 after 16276 usecs
calling  adu_init+0x0/0x9d @ 1
usbcore: registered new interface driver adutux
adutux adutux (see www.ontrak.net) v0.0.13
adutux is an experimental driver. Use at your own risk
initcall adu_init+0x0/0x9d returned 0 after 13020 usecs
calling  berry_init+0x0/0x1b @ 1
usbcore: registered new interface driver berry_charge
initcall berry_init+0x0/0x1b returned 0 after 3255 usecs
calling  cypress_init+0x0/0x3f @ 1
usbcore: registered new interface driver cypress_cy7c63
initcall cypress_init+0x0/0x3f returned 0 after 3255 usecs
calling  ftdi_elan_init+0x0/0x16f @ 1
driver ftdi-elan built at 12:03:08 on Jun 16 2009
usbcore: registered new interface driver ftdi-elan
initcall ftdi_elan_init+0x0/0x16f returned 0 after 6510 usecs
calling  usb_idmouse_init+0x0/0x4d @ 1
idmouse: 0.6:Siemens ID Mouse FingerTIP Sensor Driver
usbcore: registered new interface driver idmouse
initcall usb_idmouse_init+0x0/0x4d returned 0 after 6510 usecs
calling  iowarrior_init+0x0/0x1b @ 1
usbcore: registered new interface driver iowarrior
initcall iowarrior_init+0x0/0x1b returned 0 after 3255 usecs
calling  isight_firmware_init+0x0/0x1b @ 1
usbcore: registered new interface driver isight_firmware
initcall isight_firmware_init+0x0/0x1b returned 0 after 3255 usecs
calling  usb_lcd_init+0x0/0x3f @ 1
usbcore: registered new interface driver usblcd
initcall usb_lcd_init+0x0/0x3f returned 0 after 3255 usecs
calling  usb_led_init+0x0/0x3f @ 1
usbcore: registered new interface driver usbled
initcall usb_led_init+0x0/0x3f returned 0 after 3255 usecs
calling  usb_rio_init+0x0/0x3d @ 1
usbcore: registered new interface driver rio500
rio500: v1.1:USB Rio 500 driver
initcall usb_rio_init+0x0/0x3d returned 0 after 6510 usecs
calling  tv_init+0x0/0x4d @ 1
usbcore: registered new interface driver trancevibrator
trancevibrator: v1.1:PlayStation 2 Trance Vibrator driver
initcall tv_init+0x0/0x4d returned 0 after 6510 usecs
calling  uss720_init+0x0/0x67 @ 1
usbcore: registered new interface driver uss720
uss720: v0.6:USB Parport Cable driver for Cables using the Lucent Techn=
ologies USS720 Chip
uss720: NOTE: this is a special purpose driver to allow nonstandard
uss720: protocols (eg. bitbang) over USS720 usb to parallel cables
uss720: If you just want to connect to a printer, use usblp instead
initcall uss720_init+0x0/0x67 returned 0 after 16276 usecs
calling  usb_sevseg_init+0x0/0x3f @ 1
usbcore: registered new interface driver usbsevseg
initcall usb_sevseg_init+0x0/0x3f returned 0 after 3255 usecs
calling  usb_sisusb_init+0x0/0x1b @ 1
usbcore: registered new interface driver sisusb
initcall usb_sisusb_init+0x0/0x1b returned 0 after 3255 usecs
calling  i8042_init+0x0/0x124 @ 1
serio: i8042 KBD port at 0x60,0x64 irq 1
serio: i8042 AUX port at 0x60,0x64 irq 12
initcall i8042_init+0x0/0x124 returned 0 after 9765 usecs
calling  parkbd_init+0x0/0x1ed @ 1
parport0: cannot grant exclusive access for device parkbd
initcall parkbd_init+0x0/0x1ed returned -19 after 6510 usecs
calling  serport_init+0x0/0x39 @ 1
initcall serport_init+0x0/0x39 returned 0 after 0 usecs
calling  ct82c710_init+0x0/0x1b8 @ 1
initcall ct82c710_init+0x0/0x1b8 returned -19 after 0 usecs
calling  emu_init+0x0/0x1b @ 1
initcall emu_init+0x0/0x1b returned 0 after 3255 usecs
calling  mousedev_init+0x0/0x92 @ 1
mice: PS/2 mouse device common for all mice
initcall mousedev_init+0x0/0x92 returned 0 after 3255 usecs
calling  joydev_init+0x0/0x12 @ 1
initcall joydev_init+0x0/0x12 returned 0 after 0 usecs
calling  atkbd_init+0x0/0x27 @ 1
initcall atkbd_init+0x0/0x27 returned 0 after 0 usecs
calling  sunkbd_init+0x0/0x1b @ 1
initcall sunkbd_init+0x0/0x1b returned 0 after 0 usecs
calling  lkkbd_init+0x0/0x1b @ 1
initcall lkkbd_init+0x0/0x1b returned 0 after 0 usecs
calling  skbd_init+0x0/0x1b @ 1
input: AT Translated Set 2 keyboard as /class/input/input0
initcall skbd_init+0x0/0x1b returned 0 after 0 usecs
calling  atp_init+0x0/0x1b @ 1
usbcore: registered new interface driver appletouch
initcall atp_init+0x0/0x1b returned 0 after 3255 usecs
calling  psmouse_init+0x0/0x77 @ 1
initcall psmouse_init+0x0/0x77 returned 0 after 0 usecs
calling  sermouse_init+0x0/0x28 @ 1
initcall sermouse_init+0x0/0x28 returned 0 after 0 usecs
calling  a3d_init+0x0/0x1b @ 1
initcall a3d_init+0x0/0x1b returned 0 after 0 usecs
calling  adi_init+0x0/0x1b @ 1
initcall adi_init+0x0/0x1b returned 0 after 0 usecs
calling  analog_init+0x0/0x124 @ 1
initcall analog_init+0x0/0x124 returned 0 after 0 usecs
calling  cobra_init+0x0/0x26 @ 1
initcall cobra_init+0x0/0x26 returned 0 after 0 usecs
calling  gc_init+0x0/0x8f7 @ 1
initcall gc_init+0x0/0x8f7 returned -19 after 0 usecs
calling  gf2k_init+0x0/0x1b @ 1
initcall gf2k_init+0x0/0x1b returned 0 after 0 usecs
calling  grip_init+0x0/0x1b @ 1
initcall grip_init+0x0/0x1b returned 0 after 0 usecs
calling  grip_init+0x0/0x1b @ 1
initcall grip_init+0x0/0x1b returned 0 after 0 usecs
calling  guillemot_init+0x0/0x1b @ 1
initcall guillemot_init+0x0/0x1b returned 0 after 0 usecs
calling  iforce_init+0x0/0x1b @ 1
usbcore: registered new interface driver iforce
initcall iforce_init+0x0/0x1b returned 0 after 0 usecs
calling  interact_init+0x0/0x1b @ 1
initcall interact_init+0x0/0x1b returned 0 after 0 usecs
calling  joydump_init+0x0/0x1b @ 1
initcall joydump_init+0x0/0x1b returned 0 after 0 usecs
calling  magellan_init+0x0/0x1b @ 1
initcall magellan_init+0x0/0x1b returned 0 after 0 usecs
calling  sw_init+0x0/0x1b @ 1
initcall sw_init+0x0/0x1b returned 0 after 0 usecs
calling  spaceball_init+0x0/0x1b @ 1
initcall spaceball_init+0x0/0x1b returned 0 after 0 usecs
calling  stinger_init+0x0/0x1b @ 1
initcall stinger_init+0x0/0x1b returned 0 after 0 usecs
calling  tgfx_init+0x0/0x5b1 @ 1
initcall tgfx_init+0x0/0x5b1 returned -19 after 0 usecs
calling  twidjoy_init+0x0/0x1b @ 1
initcall twidjoy_init+0x0/0x1b returned 0 after 3255 usecs
calling  warrior_init+0x0/0x1b @ 1
initcall warrior_init+0x0/0x1b returned 0 after 0 usecs
calling  usb_xpad_init+0x0/0x3d @ 1
usbcore: registered new interface driver xpad
xpad: X-Box pad driver
initcall usb_xpad_init+0x0/0x3d returned 0 after 0 usecs
calling  zhenhua_init+0x0/0x1b @ 1
initcall zhenhua_init+0x0/0x1b returned 0 after 0 usecs
calling  walkera0701_init+0x0/0x333 @ 1
walkera0701: parport without interrupt
initcall walkera0701_init+0x0/0x333 returned -19 after 0 usecs
calling  usb_acecad_init+0x0/0x3d @ 1
usbcore: registered new interface driver usb_acecad
acecad: v3.2:USB Acecad Flair tablet driver
initcall usb_acecad_init+0x0/0x3d returned 0 after 0 usecs
calling  aiptek_init+0x0/0x4b @ 1
usbcore: registered new interface driver aiptek
aiptek: v2.3 (May 2, 2007):Aiptek HyperPen USB Tablet Driver (Linux 2.6=
=2Ex)
aiptek: Bryan W. Headley/Chris Atenasio/Cedric Brun/Rene van Paassen
initcall aiptek_init+0x0/0x4b returned 0 after 0 usecs
calling  gtco_init+0x0/0x54 @ 1
usbcore: registered new interface driver gtco
GTCO usb driver version: 2.00.0006initcall gtco_init+0x0/0x54 returned =
0 after 0 usecs
calling  wacom_init+0x0/0x49 @ 1
usbcore: registered new interface driver wacom
wacom: v1.50:USB Wacom Graphire and Wacom Intuos tablet driver
initcall wacom_init+0x0/0x49 returned 0 after 0 usecs
calling  ati_remote_init+0x0/0x4d @ 1
usbcore: registered new interface driver ati_remote
ati_remote: 2.2.1:ATI/X10 RF USB Remote Control
initcall ati_remote_init+0x0/0x4d returned 0 after 0 usecs
calling  cm109_init+0x0/0x115 @ 1
cm109: Keymap for Komunikate KIP1000 phone loaded
usbcore: registered new interface driver cm109
cm109: CM109 phone driver: 20080805 (C) Alfred E. Heggestad
initcall cm109_init+0x0/0x115 returned 0 after 0 usecs
calling  usb_keyspan_init+0x0/0x3f @ 1
usbcore: registered new interface driver keyspan_remote
initcall usb_keyspan_init+0x0/0x3f returned 0 after 0 usecs
calling  pcspkr_init+0x0/0x12 @ 1
Platform driver 'pcspkr' needs updating - please use dev_pm_ops
input: PC Speaker as /class/input/input1
initcall pcspkr_init+0x0/0x12 returned 0 after 0 usecs
calling  uinput_init+0x0/0x12 @ 1
initcall uinput_init+0x0/0x12 returned 0 after 0 usecs
calling  yealink_dev_init+0x0/0x3d @ 1
usbcore: registered new interface driver yealink
yealink: yld-20051230:Yealink phone driver
initcall yealink_dev_init+0x0/0x3d returned 0 after 0 usecs
calling  cmos_init+0x0/0x27 @ 1
rtc_cmos: dev (254:0)
rtc_cmos rtc_cmos: rtc core: registered rtc_cmos as rtc0
rtc0: alarms up to one day, 114 bytes nvram
initcall cmos_init+0x0/0x27 returned 0 after 3255 usecs
calling  ds1286_init+0x0/0x12 @ 1
initcall ds1286_init+0x0/0x12 returned 0 after 0 usecs
calling  ds1374_init+0x0/0x14 @ 1
initcall ds1374_init+0x0/0x14 returned 0 after 0 usecs
calling  ds1511_rtc_init+0x0/0x12 @ 1
initcall ds1511_rtc_init+0x0/0x12 returned 0 after 0 usecs
calling  ds1553_init+0x0/0x12 @ 1
initcall ds1553_init+0x0/0x12 returned 0 after 0 usecs
calling  ds1742_init+0x0/0x12 @ 1
initcall ds1742_init+0x0/0x12 returned 0 after 0 usecs
calling  fm3130_init+0x0/0x14 @ 1
initcall fm3130_init+0x0/0x14 returned 0 after 0 usecs
calling  isl1208_init+0x0/0x14 @ 1
initcall isl1208_init+0x0/0x14 returned 0 after 0 usecs
calling  m48t35_init+0x0/0x12 @ 1
initcall m48t35_init+0x0/0x12 returned 0 after 0 usecs
calling  bq4802_init+0x0/0x12 @ 1
initcall bq4802_init+0x0/0x12 returned 0 after 0 usecs
calling  max6900_init+0x0/0x14 @ 1
initcall max6900_init+0x0/0x14 returned 0 after 0 usecs
calling  pcf8563_init+0x0/0x14 @ 1
initcall pcf8563_init+0x0/0x14 returned 0 after 0 usecs
calling  pcf8583_init+0x0/0x14 @ 1
initcall pcf8583_init+0x0/0x14 returned 0 after 0 usecs
calling  test_init+0x0/0xbe @ 1
test: dev (254:1)
rtc-test rtc-test.0: rtc core: registered test as rtc1
test: dev (254:2)
rtc-test rtc-test.1: rtc core: registered test as rtc2
initcall test_init+0x0/0xbe returned 0 after 0 usecs
calling  twl4030_rtc_init+0x0/0x12 @ 1
initcall twl4030_rtc_init+0x0/0x12 returned 0 after 0 usecs
calling  v3020_init+0x0/0x12 @ 1
initcall v3020_init+0x0/0x12 returned 0 after 3255 usecs
calling  x1205_init+0x0/0x14 @ 1
initcall x1205_init+0x0/0x14 returned 0 after 0 usecs
calling  i2c_dev_init+0x0/0xac @ 1
i2c /dev entries driver
initcall i2c_dev_init+0x0/0xac returned 0 after 0 usecs
calling  i2c_ali1535_init+0x0/0x1b @ 1
initcall i2c_ali1535_init+0x0/0x1b returned 0 after 0 usecs
calling  i2c_ali15x3_init+0x0/0x1b @ 1
initcall i2c_ali15x3_init+0x0/0x1b returned 0 after 0 usecs
calling  i2c_amd8111_init+0x0/0x1b @ 1
initcall i2c_amd8111_init+0x0/0x1b returned 0 after 0 usecs
calling  i2c_i801_init+0x0/0x1b @ 1
initcall i2c_i801_init+0x0/0x1b returned 0 after 0 usecs
calling  i2c_sch_init+0x0/0x1b @ 1
initcall i2c_sch_init+0x0/0x1b returned 0 after 0 usecs
calling  i2c_sis5595_init+0x0/0x1b @ 1
initcall i2c_sis5595_init+0x0/0x1b returned 0 after 0 usecs
calling  i2c_sis630_init+0x0/0x1b @ 1
initcall i2c_sis630_init+0x0/0x1b returned 0 after 0 usecs
calling  i2c_sis96x_init+0x0/0x1b @ 1
initcall i2c_sis96x_init+0x0/0x1b returned 0 after 0 usecs
calling  i2c_vt586b_init+0x0/0x1b @ 1
initcall i2c_vt586b_init+0x0/0x1b returned 0 after 0 usecs
calling  i2c_vt596_init+0x0/0x1b @ 1
initcall i2c_vt596_init+0x0/0x1b returned 0 after 0 usecs
calling  ocores_i2c_init+0x0/0x12 @ 1
initcall ocores_i2c_init+0x0/0x12 returned 0 after 0 usecs
calling  taos_init+0x0/0x1b @ 1
initcall taos_init+0x0/0x1b returned 0 after 0 usecs
calling  i2c_voodoo3_init+0x0/0x1b @ 1
initcall i2c_voodoo3_init+0x0/0x1b returned 0 after 3255 usecs
calling  i2c_pca_pf_init+0x0/0x12 @ 1
initcall i2c_pca_pf_init+0x0/0x12 returned 0 after 0 usecs
calling  ds1682_init+0x0/0x14 @ 1
initcall ds1682_init+0x0/0x14 returned 0 after 0 usecs
calling  pca9539_init+0x0/0x14 @ 1
initcall pca9539_init+0x0/0x14 returned 0 after 0 usecs
calling  pcf8574_init+0x0/0x14 @ 1
initcall pcf8574_init+0x0/0x14 returned 0 after 0 usecs
calling  pcf8575_init+0x0/0x14 @ 1
initcall pcf8575_init+0x0/0x14 returned 0 after 0 usecs
calling  w1_init+0x0/0xb0 @ 1
Driver for 1-wire Dallas network protocol.
initcall w1_init+0x0/0xb0 returned 0 after 0 usecs
calling  matrox_w1_init+0x0/0x1b @ 1
initcall matrox_w1_init+0x0/0x1b returned 0 after 0 usecs
calling  ds_init+0x0/0x50 @ 1
usbcore: registered new interface driver DS9490R
initcall ds_init+0x0/0x50 returned 0 after 0 usecs
calling  w1_therm_init+0x0/0x4d @ 1
initcall w1_therm_init+0x0/0x4d returned 0 after 0 usecs
calling  w1_smem_init+0x0/0x44 @ 1
initcall w1_smem_init+0x0/0x44 returned 0 after 0 usecs
calling  w1_ds2760_init+0x0/0x2c @ 1
1-Wire driver for the DS2760 battery monitor  chip  - (c) 2004-2005, Sz=
abolcs Gyurko
initcall w1_ds2760_init+0x0/0x2c returned 0 after 0 usecs
calling  bq27x00_battery_init+0x0/0x36 @ 1
initcall bq27x00_battery_init+0x0/0x36 returned 0 after 0 usecs
calling  pcipcwd_init_module+0x0/0x35 @ 1
initcall pcipcwd_init_module+0x0/0x35 returned 0 after 0 usecs
calling  acq_init+0x0/0x66 @ 1
WDT driver for Acquire single board computer initialising.
acquirewdt: I/O address 0x0043 already in use
acquirewdt: probe of acquirewdt failed with error -5
initcall acq_init+0x0/0x66 returned 0 after 0 usecs
calling  advwdt_init+0x0/0x75 @ 1
WDT driver for Advantech single board computer initialising.
advantechwdt: initialized. timeout=3D60 sec (nowayout=3D1)
initcall advwdt_init+0x0/0x75 returned 0 after 3255 usecs
calling  watchdog_init+0x0/0x182 @ 1
initcall watchdog_init+0x0/0x182 returned -19 after 0 usecs
calling  alim7101_wdt_init+0x0/0x1d0 @ 1
alim7101_wdt: Steve Hill <steve@navaho.co.uk>.
alim7101_wdt: ALi M7101 PMU not present - WDT not set
initcall alim7101_wdt_init+0x0/0x1d0 returned -16 after 0 usecs
initcall alim7101_wdt_init+0x0/0x1d0 returned with error code -16=20
calling  sc520_wdt_init+0x0/0xec @ 1
sc520_wdt: cannot register miscdev on minor=3D130 (err=3D-16)
initcall sc520_wdt_init+0x0/0xec returned -16 after 843098 usecs
initcall sc520_wdt_init+0x0/0xec returned with error code -16=20
calling  ibwdt_init+0x0/0x66 @ 1
ib700wdt: WDT driver for IB700 single board computer initialising.
ib700wdt: START method I/O 443 is not available.
ib700wdt: probe of ib700wdt failed with error -5
initcall ibwdt_init+0x0/0x66 returned 0 after 9765 usecs
calling  ibmasr_init+0x0/0x286 @ 1
initcall ibmasr_init+0x0/0x286 returned -19 after 0 usecs
calling  wafwdt_init+0x0/0x184 @ 1
WDT driver for Wafer 5823 single board computer initialising.
Wafer 5823 WDT: I/O address 0x0443 already in use
initcall wafwdt_init+0x0/0x184 returned -5 after 6510 usecs
initcall wafwdt_init+0x0/0x184 returned with error code -5=20
calling  watchdog_init+0x0/0x6d @ 1
i6300ESB timer: Intel 6300ESB WatchDog Timer Driver v0.04
initcall watchdog_init+0x0/0x6d returned 0 after 3255 usecs
calling  iTCO_wdt_init_module+0x0/0x6d @ 1
iTCO_wdt: Intel TCO WatchDog Timer Driver v1.05
iTCO_wdt: No card detected
initcall iTCO_wdt_init_module+0x0/0x6d returned 0 after 6510 usecs
calling  iTCO_vendor_init_module+0x0/0x28 @ 1
iTCO_vendor_support: vendor-support=3D0
initcall iTCO_vendor_init_module+0x0/0x28 returned 0 after 3255 usecs
calling  it87_wdt_init+0x0/0x5ea @ 1
IT87 WDT: Unsupported Chip found, Chip 8712 Revision 07
initcall it87_wdt_init+0x0/0x5ea returned -19 after 3255 usecs
calling  sc1200wdt_init+0x0/0x11a @ 1
sc1200wdt: build 20020303
sc1200wdt: io parameter must be specified
initcall sc1200wdt_init+0x0/0x11a returned -22 after 6510 usecs
initcall sc1200wdt_init+0x0/0x11a returned with error code -22=20
calling  sbc60xxwdt_init+0x0/0x19c @ 1
sbc60xxwdt: I/O address 0x0443 already in use
initcall sbc60xxwdt_init+0x0/0x19c returned -5 after 3255 usecs
initcall sbc60xxwdt_init+0x0/0x19c returned with error code -5=20
calling  sbc8360_init+0x0/0x1c1 @ 1
sbc8360: failed to register misc device
initcall sbc8360_init+0x0/0x1c1 returned -16 after 3255 usecs
initcall sbc8360_init+0x0/0x1c1 returned with error code -16=20
calling  cpu5wdt_init_module+0x0/0x157 @ 1
cpu5wdt: sorry, was my fault
cpu5wdt: misc_register failed
initcall cpu5wdt_init_module+0x0/0x157 returned -16 after 3255 usecs
initcall cpu5wdt_init_module+0x0/0x157 returned with error code -16=20
calling  sch311x_wdt_init+0x0/0x177 @ 1
initcall sch311x_wdt_init+0x0/0x177 returned -19 after 0 usecs
calling  wb_smsc_wdt_init+0x0/0x1ce @ 1
SMsC 37B787 watchdog component driver 1.1 initialising...
smsc37b787_wdt: Unable to register miscdev on minor 130
initcall wb_smsc_wdt_init+0x0/0x1ce returned -16 after 6510 usecs
initcall wb_smsc_wdt_init+0x0/0x1ce returned with error code -16=20
calling  wdt_init+0x0/0x204 @ 1
WDT driver for the Winbond(TM) W83627HF/THF/HG Super I/O chip initialis=
ing.
w83627hf/thf/hg WDT: Watchdog already running. Resetting timeout to 60 =
sec
w83627hf/thf/hg WDT: cannot register miscdev on minor=3D130 (err=3D-16)
initcall wdt_init+0x0/0x204 returned -16 after 9765 usecs
initcall wdt_init+0x0/0x204 returned with error code -16=20
calling  w83877f_wdt_init+0x0/0x177 @ 1
w83877f_wdt: I/O address 0x0443 already in use
initcall w83877f_wdt_init+0x0/0x177 returned -5 after 3255 usecs
initcall w83877f_wdt_init+0x0/0x177 returned with error code -5=20
calling  zf_init+0x0/0x188 @ 1
machzwd: MachZ ZF-Logic Watchdog driver initializing.
machzwd: no ZF-Logic found
initcall zf_init+0x0/0x188 returned -19 after 6510 usecs
calling  telephony_init+0x0/0x57 @ 1
Linux telephony interface: v1.00
initcall telephony_init+0x0/0x57 returned 0 after 0 usecs
calling  hci_uart_init+0x0/0xef @ 1
Bluetooth: HCI UART driver ver 2.2
Bluetooth: HCI H4 protocol initialized
Bluetooth: HCI BCSP protocol initialized
Bluetooth: HCILL protocol initialized
initcall hci_uart_init+0x0/0xef returned 0 after 13020 usecs
calling  bcm203x_init+0x0/0x59 @ 1
Bluetooth: Broadcom Blutonium firmware driver ver 1.2
usbcore: registered new interface driver bcm203x
initcall bcm203x_init+0x0/0x59 returned 0 after 6510 usecs
calling  bfusb_init+0x0/0x68 @ 1
Bluetooth: BlueFRITZ! USB driver ver 1.2
usbcore: registered new interface driver bfusb
initcall bfusb_init+0x0/0x68 returned 0 after 6510 usecs
calling  isdn_init+0x0/0x35b @ 1
ISDN subsystem Rev: 1.1.2.3/1.1.2.3/1.1.2.2/1.1.2.3/none/1.1.2.2
initcall isdn_init+0x0/0x35b returned 0 after 6510 usecs
calling  isdn_bsdcomp_init+0x0/0x35 @ 1
PPP BSD Compression module registered
initcall isdn_bsdcomp_init+0x0/0x35 returned 0 after 3255 usecs
calling  kcapi_init+0x0/0x92 @ 1
CAPI Subsystem Rev 1.1.2.8
initcall kcapi_init+0x0/0x92 returned 0 after 3255 usecs
calling  capidrv_init+0x0/0x180 @ 1
capidrv: Rev 1.1.2.2: loaded
initcall capidrv_init+0x0/0x180 returned 0 after 0 usecs
calling  divadidd_init+0x0/0x110 @ 1
Eicon DIVA - DIDD table (http://www.melware.net)
divadidd: Rel:2.0  Rev:1.13.6.4  Build:102-51(local)
initcall divadidd_init+0x0/0x110 returned 0 after 9765 usecs
calling  divas_init+0x0/0x180 @ 1
Eicon DIVA Server driver (http://www.melware.net)
divas: Rel:2.0  Rev:1.55.4.6  Build: 102-52(local)
divas: support for: BRI/PCI adapters
divas: started with major 245
initcall divas_init+0x0/0x180 returned 0 after 16276 usecs
calling  divasi_init+0x0/0x180 @ 1
Eicon DIVA - User IDI (http://www.melware.net)
diva_idi: Rel:2.0  Rev:1.25.6.2  Build: local
diva_idi: started with major 244
initcall divasi_init+0x0/0x180 returned 0 after 9765 usecs
calling  divert_init+0x0/0x6e @ 1
dss1_divert module successfully installed
initcall divert_init+0x0/0x6e returned 0 after 3255 usecs
calling  HiSax_init+0x0/0x3eb @ 1
HiSax: Linux Driver for passive ISDN cards
HiSax: Version 3.5 (kernel)
HiSax: Layer1 Revision 2.46.2.5
HiSax: Layer2 Revision 2.30.2.4
HiSax: TeiMgr Revision 2.20.2.3
HiSax: Layer3 Revision 2.22.2.3
HiSax: LinkLayer Revision 2.59.2.4
HiSax: Total 1 card defined
HiSax: Card 1 Protocol EDSS1 Id=3DHiSax (0)
HiSax: S0Box IO driver Rev. 2.6.2.4
HiSax: S0Box ports 378-37f already in use
HiSax: Card S0Box not installed !
initcall HiSax_init+0x0/0x3eb returned -19 after 35807 usecs
calling  st5481_usb_init+0x0/0x5b @ 1
hisax_st5481: ST5481 USB ISDN driver $Revision: 2.4.2.3 $
usbcore: registered new interface driver st5481_usb
initcall st5481_usb_init+0x0/0x5b returned 0 after 6510 usecs
calling  hfc4s8s_module_init+0x0/0x64 @ 1
HFC-4S/8S: Layer 1 driver module for HFC-4S/8S isdn chips, Revision: 1.=
10
HFC-4S/8S: (C) 2003 Cornelius Consult, www.cornelius-consult.de
HFC-4S/8S: found 0 cards
initcall hfc4s8s_module_init+0x0/0x64 returned 0 after 9765 usecs
calling  gigaset_init_module+0x0/0x29 @ 1
gigaset: Driver for Gigaset 307x
initcall gigaset_init_module+0x0/0x29 returned 0 after 3255 usecs
calling  usb_gigaset_init+0x0/0x97 @ 1
usbcore: registered new interface driver usb_gigaset
usb_gigaset: USB Driver for Gigaset 307x using M105
initcall usb_gigaset_init+0x0/0x97 returned 0 after 6510 usecs
calling  cpufreq_stats_init+0x0/0xed @ 1
initcall cpufreq_stats_init+0x0/0xed returned 0 after 0 usecs
calling  cpufreq_gov_powersave_init+0x0/0x12 @ 1
initcall cpufreq_gov_powersave_init+0x0/0x12 returned 0 after 0 usecs
calling  cpufreq_gov_userspace_init+0x0/0x12 @ 1
initcall cpufreq_gov_userspace_init+0x0/0x12 returned 0 after 0 usecs
calling  cpufreq_gov_dbs_init+0x0/0x6b @ 1
initcall cpufreq_gov_dbs_init+0x0/0x6b returned 0 after 0 usecs
calling  init_ladder+0x0/0x21 @ 1
cpuidle: using governor ladder
initcall init_ladder+0x0/0x21 returned 0 after 3255 usecs
calling  i7300_idle_init+0x0/0x705 @ 1
initcall i7300_idle_init+0x0/0x705 returned -19 after 0 usecs
calling  sdio_uart_init+0x0/0x124 @ 1
initcall sdio_uart_init+0x0/0x124 returned 0 after 0 usecs
calling  wbsd_drv_init+0x0/0x96 @ 1
wbsd: Winbond W83L51xD SD/MMC card interface driver
wbsd: Copyright(c) Pierre Ossman
initcall wbsd_drv_init+0x0/0x96 returned 0 after 6510 usecs
calling  cb710_mmc_init_module+0x0/0x12 @ 1
initcall cb710_mmc_init_module+0x0/0x12 returned 0 after 0 usecs
calling  memstick_init+0x0/0x8a @ 1
initcall memstick_init+0x0/0x8a returned 0 after 0 usecs
calling  mspro_block_init+0x0/0x76 @ 1
initcall mspro_block_init+0x0/0x76 returned 0 after 0 usecs
calling  tifm_ms_init+0x0/0x12 @ 1
initcall tifm_ms_init+0x0/0x12 returned 0 after 0 usecs
calling  jmb38x_ms_init+0x0/0x22 @ 1
initcall jmb38x_ms_init+0x0/0x22 returned 0 after 0 usecs
calling  dcdrbu_init+0x0/0x149 @ 1
initcall dcdrbu_init+0x0/0x149 returned 0 after 0 usecs
calling  dcdbas_init+0x0/0x6e @ 1
dcdbas dcdbas: Dell Systems Management Base Driver (version 5.6.0-3.2)
initcall dcdbas_init+0x0/0x6e returned 0 after 3255 usecs
calling  ibft_init+0x0/0x712 @ 1
No iBFT detected.
initcall ibft_init+0x0/0x712 returned 0 after 0 usecs
calling  padlock_init+0x0/0xcb @ 1
padlock: VIA PadLock not detected.
initcall padlock_init+0x0/0xcb returned -19 after 3255 usecs
calling  hifn_init+0x0/0x1f @ 1
HIFN supports only 32-bit addresses.
initcall hifn_init+0x0/0x1f returned -22 after 3255 usecs
initcall hifn_init+0x0/0x1f returned with error code -22=20
calling  hid_init+0x0/0x4b @ 1
initcall hid_init+0x0/0x4b returned 0 after 0 usecs
calling  a4_init+0x0/0x20 @ 1
initcall a4_init+0x0/0x20 returned 0 after 0 usecs
calling  apple_init+0x0/0x50 @ 1
initcall apple_init+0x0/0x50 returned 0 after 0 usecs
calling  ch_init+0x0/0x20 @ 1
initcall ch_init+0x0/0x20 returned 0 after 0 usecs
calling  ch_init+0x0/0x20 @ 1
initcall ch_init+0x0/0x20 returned 0 after 0 usecs
calling  dr_init+0x0/0x1b @ 1
initcall dr_init+0x0/0x1b returned 0 after 0 usecs
calling  ez_init+0x0/0x20 @ 1
initcall ez_init+0x0/0x20 returned 0 after 0 usecs
calling  kye_init+0x0/0x20 @ 1
initcall kye_init+0x0/0x20 returned 0 after 0 usecs
calling  lg_init+0x0/0x20 @ 1
initcall lg_init+0x0/0x20 returned 0 after 0 usecs
calling  ms_init+0x0/0x20 @ 1
initcall ms_init+0x0/0x20 returned 0 after 0 usecs
calling  ntrig_init+0x0/0x20 @ 1
initcall ntrig_init+0x0/0x20 returned 0 after 0 usecs
calling  pl_init+0x0/0x20 @ 1
initcall pl_init+0x0/0x20 returned 0 after 0 usecs
calling  pl_init+0x0/0x20 @ 1
initcall pl_init+0x0/0x20 returned 0 after 0 usecs
calling  samsung_init+0x0/0x20 @ 1
initcall samsung_init+0x0/0x20 returned 0 after 3255 usecs
calling  ga_init+0x0/0x1c @ 1
initcall ga_init+0x0/0x1c returned 0 after 0 usecs
calling  tm_init+0x0/0x20 @ 1
initcall tm_init+0x0/0x20 returned 0 after 0 usecs
calling  ts_init+0x0/0x20 @ 1
initcall ts_init+0x0/0x20 returned 0 after 0 usecs
calling  zp_init+0x0/0x20 @ 1
initcall zp_init+0x0/0x20 returned 0 after 0 usecs
calling  hid_init+0x0/0xd2 @ 1
usbcore: registered new interface driver hiddev
usbcore: registered new interface driver usbhid
usbhid: v2.6:USB HID core driver
initcall hid_init+0x0/0xd2 returned 0 after 6510 usecs
calling  usb_mouse_init+0x0/0x43 @ 1
usbcore: registered new interface driver usbmouse
usbmouse: v1.6:USB HID Boot Protocol mouse driver
initcall usb_mouse_init+0x0/0x43 returned 0 after 6510 usecs
calling  virtio_pci_init+0x0/0x5a @ 1
initcall virtio_pci_init+0x0/0x5a returned 0 after 0 usecs
calling  init+0x0/0x1c @ 1
initcall init+0x0/0x1c returned 0 after 0 usecs
calling  oprofile_init+0x0/0x56 @ 1
oprofile: using timer interrupt.
initcall oprofile_init+0x0/0x56 returned 0 after 3255 usecs
calling  flow_cache_init+0x0/0x20c @ 1
initcall flow_cache_init+0x0/0x20c returned 0 after 0 usecs
calling  llc_init+0x0/0x20 @ 1
initcall llc_init+0x0/0x20 returned 0 after 0 usecs
calling  snap_init+0x0/0x44 @ 1
initcall snap_init+0x0/0x44 returned 0 after 0 usecs
calling  blackhole_module_init+0x0/0x12 @ 1
initcall blackhole_module_init+0x0/0x12 returned 0 after 0 usecs
calling  police_init_module+0x0/0x12 @ 1
initcall police_init_module+0x0/0x12 returned 0 after 0 usecs
calling  gact_init_module+0x0/0x20 @ 1
GACT probability on
initcall gact_init_module+0x0/0x20 returned 0 after 3255 usecs
calling  mirred_init_module+0x0/0x20 @ 1
Mirror/redirect action on
initcall mirred_init_module+0x0/0x20 returned 0 after 0 usecs
calling  ipt_init_module+0x0/0x12 @ 1
initcall ipt_init_module+0x0/0x12 returned 0 after 0 usecs
calling  nat_init_module+0x0/0x12 @ 1
initcall nat_init_module+0x0/0x12 returned 0 after 0 usecs
calling  pedit_init_module+0x0/0x12 @ 1
initcall pedit_init_module+0x0/0x12 returned 0 after 0 usecs
calling  simp_init_module+0x0/0x34 @ 1
Simple TC action Loaded
initcall simp_init_module+0x0/0x34 returned 0 after 3255 usecs
calling  hfsc_init+0x0/0x12 @ 1
initcall hfsc_init+0x0/0x12 returned 0 after 0 usecs
calling  red_module_init+0x0/0x12 @ 1
initcall red_module_init+0x0/0x12 returned 0 after 0 usecs
calling  gred_module_init+0x0/0x12 @ 1
initcall gred_module_init+0x0/0x12 returned 0 after 0 usecs
calling  dsmark_module_init+0x0/0x12 @ 1
initcall dsmark_module_init+0x0/0x12 returned 0 after 0 usecs
calling  sfq_module_init+0x0/0x12 @ 1
initcall sfq_module_init+0x0/0x12 returned 0 after 0 usecs
input: PS/2 Generic Mouse as /class/input/input2
calling  tbf_module_init+0x0/0x1c @ 1
initcall tbf_module_init+0x0/0x1c returned 0 after 0 usecs
calling  teql_init+0x0/0xe2 @ 1
initcall teql_init+0x0/0xe2 returned 0 after 0 usecs
calling  prio_module_init+0x0/0x12 @ 1
initcall prio_module_init+0x0/0x12 returned 0 after 0 usecs
calling  atm_init+0x0/0x12 @ 1
initcall atm_init+0x0/0x12 returned 0 after 0 usecs
calling  netem_module_init+0x0/0x20 @ 1
netem: version 1.2
initcall netem_module_init+0x0/0x20 returned 0 after 0 usecs
calling  init_u32+0x0/0x4a @ 1
u32 classifier
    Performance counters on
    input device check on=20
    Actions configured=20
initcall init_u32+0x0/0x4a returned 0 after 6510 usecs
calling  init_route4+0x0/0x12 @ 1
initcall init_route4+0x0/0x12 returned 0 after 0 usecs
calling  init_fw+0x0/0x12 @ 1
initcall init_fw+0x0/0x12 returned 0 after 0 usecs
calling  init_tcindex+0x0/0x12 @ 1
initcall init_tcindex+0x0/0x12 returned 0 after 0 usecs
calling  init_rsvp+0x0/0x12 @ 1
initcall init_rsvp+0x0/0x12 returned 0 after 0 usecs
calling  init_basic+0x0/0x12 @ 1
initcall init_basic+0x0/0x12 returned 0 after 0 usecs
calling  cls_flow_init+0x0/0x12 @ 1
initcall cls_flow_init+0x0/0x12 returned 0 after 0 usecs
calling  init_cgroup_cls+0x0/0x15 @ 1
initcall init_cgroup_cls+0x0/0x15 returned 0 after 0 usecs
calling  nfnetlink_init+0x0/0x6e @ 1
Netfilter messages via NETLINK v0.30.
initcall nfnetlink_init+0x0/0x6e returned 0 after 3255 usecs
calling  nfnetlink_queue_init+0x0/0xaa @ 1
initcall nfnetlink_queue_init+0x0/0xaa returned 0 after 0 usecs
calling  nfnetlink_log_init+0x0/0xdc @ 1
initcall nfnetlink_log_init+0x0/0xdc returned 0 after 0 usecs
calling  nf_conntrack_standalone_init+0x0/0x12 @ 1
nf_conntrack version 0.5.0 (8191 buckets, 32764 max)
initcall nf_conntrack_standalone_init+0x0/0x12 returned 0 after 6510 us=
ecs
calling  nf_ct_proto_gre_init+0x0/0x4b @ 1
initcall nf_ct_proto_gre_init+0x0/0x4b returned 0 after 0 usecs
calling  nf_conntrack_proto_udplite_init+0x0/0x46 @ 1
initcall nf_conntrack_proto_udplite_init+0x0/0x46 returned 0 after 0 us=
ecs
calling  nf_conntrack_amanda_init+0x0/0xbf @ 1
initcall nf_conntrack_amanda_init+0x0/0xbf returned 0 after 0 usecs
calling  nf_conntrack_h323_init+0x0/0x110 @ 1
initcall nf_conntrack_h323_init+0x0/0x110 returned 0 after 0 usecs
calling  nf_conntrack_irc_init+0x0/0x1ab @ 1
initcall nf_conntrack_irc_init+0x0/0x1ab returned 0 after 0 usecs
calling  nf_conntrack_netbios_ns_init+0x0/0x1e @ 1
initcall nf_conntrack_netbios_ns_init+0x0/0x1e returned 0 after 0 usecs
calling  nf_conntrack_pptp_init+0x0/0x44 @ 1
initcall nf_conntrack_pptp_init+0x0/0x44 returned 0 after 0 usecs
calling  nf_conntrack_sip_init+0x0/0x1b2 @ 1
initcall nf_conntrack_sip_init+0x0/0x1b2 returned 0 after 0 usecs
calling  nf_conntrack_tftp_init+0x0/0x1ae @ 1
initcall nf_conntrack_tftp_init+0x0/0x1ae returned 0 after 0 usecs
calling  xt_init+0x0/0x1cf @ 1
initcall xt_init+0x0/0x1cf returned 0 after 0 usecs
calling  tcpudp_mt_init+0x0/0x17 @ 1
initcall tcpudp_mt_init+0x0/0x17 returned 0 after 0 usecs
calling  connmark_tg_init+0x0/0x17 @ 1
initcall connmark_tg_init+0x0/0x17 returned 0 after 0 usecs
calling  connsecmark_tg_init+0x0/0x12 @ 1
initcall connsecmark_tg_init+0x0/0x12 returned 0 after 0 usecs
calling  hl_tg_init+0x0/0x17 @ 1
initcall hl_tg_init+0x0/0x17 returned 0 after 0 usecs
calling  mark_tg_init+0x0/0x17 @ 1
initcall mark_tg_init+0x0/0x17 returned 0 after 0 usecs
calling  nflog_tg_init+0x0/0x12 @ 1
initcall nflog_tg_init+0x0/0x12 returned 0 after 0 usecs
calling  nfqueue_tg_init+0x0/0x28 @ 1
initcall nfqueue_tg_init+0x0/0x28 returned 0 after 0 usecs
calling  xt_rateest_tg_init+0x0/0x3d @ 1
initcall xt_rateest_tg_init+0x0/0x3d returned 0 after 0 usecs
calling  tcpmss_tg_init+0x0/0x17 @ 1
initcall tcpmss_tg_init+0x0/0x17 returned 0 after 0 usecs
calling  tcpoptstrip_tg_init+0x0/0x17 @ 1
initcall tcpoptstrip_tg_init+0x0/0x17 returned 0 after 0 usecs
calling  xt_cluster_mt_init+0x0/0x12 @ 1
initcall xt_cluster_mt_init+0x0/0x12 returned 0 after 0 usecs
calling  comment_mt_init+0x0/0x12 @ 1
initcall comment_mt_init+0x0/0x12 returned 0 after 0 usecs
calling  conntrack_mt_init+0x0/0x17 @ 1
initcall conntrack_mt_init+0x0/0x17 returned 0 after 0 usecs
calling  esp_mt_init+0x0/0x17 @ 1
initcall esp_mt_init+0x0/0x17 returned 0 after 0 usecs
calling  helper_mt_init+0x0/0x12 @ 1
initcall helper_mt_init+0x0/0x12 returned 0 after 0 usecs
calling  hl_mt_init+0x0/0x17 @ 1
initcall hl_mt_init+0x0/0x17 returned 0 after 0 usecs
calling  iprange_mt_init+0x0/0x17 @ 1
initcall iprange_mt_init+0x0/0x17 returned 0 after 0 usecs
calling  length_mt_init+0x0/0x17 @ 1
initcall length_mt_init+0x0/0x17 returned 0 after 0 usecs
calling  limit_mt_init+0x0/0x12 @ 1
initcall limit_mt_init+0x0/0x12 returned 0 after 0 usecs
calling  mac_mt_init+0x0/0x12 @ 1
initcall mac_mt_init+0x0/0x12 returned 0 after 0 usecs
calling  multiport_mt_init+0x0/0x17 @ 1
initcall multiport_mt_init+0x0/0x17 returned 0 after 0 usecs
calling  pkttype_mt_init+0x0/0x12 @ 1
initcall pkttype_mt_init+0x0/0x12 returned 0 after 0 usecs
calling  policy_mt_init+0x0/0x17 @ 1
initcall policy_mt_init+0x0/0x17 returned 0 after 0 usecs
calling  xt_rateest_mt_init+0x0/0x12 @ 1
initcall xt_rateest_mt_init+0x0/0x12 returned 0 after 0 usecs
calling  realm_mt_init+0x0/0x12 @ 1
initcall realm_mt_init+0x0/0x12 returned 0 after 0 usecs
calling  sctp_mt_init+0x0/0x17 @ 1
initcall sctp_mt_init+0x0/0x17 returned 0 after 0 usecs
calling  state_mt_init+0x0/0x17 @ 1
initcall state_mt_init+0x0/0x17 returned 0 after 0 usecs
calling  statistic_mt_init+0x0/0x12 @ 1
initcall statistic_mt_init+0x0/0x12 returned 0 after 0 usecs
calling  time_mt_init+0x0/0x90 @ 1
xt_time: kernel timezone is -0000
initcall time_mt_init+0x0/0x90 returned 0 after 3255 usecs
calling  sysctl_ipv4_init+0x0/0x53 @ 1
initcall sysctl_ipv4_init+0x0/0x53 returned 0 after 0 usecs
calling  ipip_init+0x0/0x74 @ 1
IPv4 over IPv4 tunneling driver
initcall ipip_init+0x0/0x74 returned 0 after 3255 usecs
calling  init_syncookies+0x0/0x19 @ 1
initcall init_syncookies+0x0/0x19 returned 0 after 0 usecs
calling  ah4_init+0x0/0x6f @ 1
initcall ah4_init+0x0/0x6f returned 0 after 0 usecs
calling  esp4_init+0x0/0x6f @ 1
initcall esp4_init+0x0/0x6f returned 0 after 0 usecs
calling  xfrm4_beet_init+0x0/0x17 @ 1
initcall xfrm4_beet_init+0x0/0x17 returned 0 after 0 usecs
calling  tunnel4_init+0x0/0x34 @ 1
initcall tunnel4_init+0x0/0x34 returned 0 after 0 usecs
calling  xfrm4_transport_init+0x0/0x1f @ 1
initcall xfrm4_transport_init+0x0/0x1f returned 0 after 0 usecs
calling  ipv4_netfilter_init+0x0/0x20 @ 1
initcall ipv4_netfilter_init+0x0/0x20 returned 0 after 0 usecs
calling  ip_tables_init+0x0/0xae @ 1
ip_tables: (C) 2000-2006 Netfilter Core Team
initcall ip_tables_init+0x0/0xae returned 0 after 3255 usecs
calling  iptable_filter_init+0x0/0x72 @ 1
initcall iptable_filter_init+0x0/0x72 returned 0 after 0 usecs
calling  iptable_mangle_init+0x0/0x49 @ 1
initcall iptable_mangle_init+0x0/0x49 returned 0 after 0 usecs
calling  iptable_security_init+0x0/0x49 @ 1
initcall iptable_security_init+0x0/0x49 returned 0 after 0 usecs
calling  ah_mt_init+0x0/0x12 @ 1
initcall ah_mt_init+0x0/0x12 returned 0 after 0 usecs
calling  ecn_tg_init+0x0/0x12 @ 1
initcall ecn_tg_init+0x0/0x12 returned 0 after 0 usecs
calling  log_tg_init+0x0/0x29 @ 1
initcall log_tg_init+0x0/0x29 returned 0 after 0 usecs
calling  arp_tables_init+0x0/0x90 @ 1
arp_tables: (C) 2002 David S. Miller
initcall arp_tables_init+0x0/0x90 returned 0 after 3255 usecs
calling  arpt_mangle_init+0x0/0x12 @ 1
initcall arpt_mangle_init+0x0/0x12 returned 0 after 0 usecs
calling  arptable_filter_init+0x0/0x49 @ 1
initcall arptable_filter_init+0x0/0x49 returned 0 after 0 usecs
calling  ip_queue_init+0x0/0x142 @ 1
initcall ip_queue_init+0x0/0x142 returned 0 after 0 usecs
calling  bictcp_register+0x0/0x12 @ 1
TCP bic registered
initcall bictcp_register+0x0/0x12 returned 0 after 3255 usecs
calling  cubictcp_register+0x0/0x6f @ 1
TCP cubic registered
initcall cubictcp_register+0x0/0x6f returned 0 after 0 usecs
calling  tcp_westwood_register+0x0/0x12 @ 1
TCP westwood registered
initcall tcp_westwood_register+0x0/0x12 returned 0 after 3255 usecs
calling  hstcp_register+0x0/0x12 @ 1
TCP highspeed registered
initcall hstcp_register+0x0/0x12 returned 0 after 3255 usecs
calling  hybla_register+0x0/0x12 @ 1
TCP hybla registered
initcall hybla_register+0x0/0x12 returned 0 after 0 usecs
calling  htcp_register+0x0/0x12 @ 1
TCP htcp registered
initcall htcp_register+0x0/0x12 returned 0 after 0 usecs
calling  tcp_vegas_register+0x0/0x14 @ 1
TCP vegas registered
initcall tcp_vegas_register+0x0/0x14 returned 0 after 0 usecs
calling  tcp_veno_register+0x0/0x14 @ 1
TCP veno registered
initcall tcp_veno_register+0x0/0x14 returned 0 after 3255 usecs
calling  tcp_scalable_register+0x0/0x12 @ 1
TCP scalable registered
initcall tcp_scalable_register+0x0/0x12 returned 0 after 0 usecs
calling  tcp_yeah_register+0x0/0x14 @ 1
TCP yeah registered
initcall tcp_yeah_register+0x0/0x14 returned 0 after 3255 usecs
calling  tcp_illinois_register+0x0/0x12 @ 1
TCP illinois registered
initcall tcp_illinois_register+0x0/0x12 returned 0 after 0 usecs
calling  packet_init+0x0/0x4a @ 1
NET: Registered protocol family 17
initcall packet_init+0x0/0x4a returned 0 after 3255 usecs
calling  ipsec_pfkey_init+0x0/0x87 @ 1
NET: Registered protocol family 15
initcall ipsec_pfkey_init+0x0/0x87 returned 0 after 3255 usecs
calling  br_init+0x0/0xc0 @ 1
Bridge firewalling registered
initcall br_init+0x0/0xc0 returned 0 after 3255 usecs
calling  edsa_init_module+0x0/0x14 @ 1
initcall edsa_init_module+0x0/0x14 returned 0 after 0 usecs
calling  mv88e6123_61_65_init+0x0/0x14 @ 1
initcall mv88e6123_61_65_init+0x0/0x14 returned 0 after 0 usecs
calling  dsa_init_module+0x0/0x12 @ 1
initcall dsa_init_module+0x0/0x12 returned 0 after 0 usecs
calling  x25_init+0x0/0x6a @ 1
NET: Registered protocol family 9
X.25 for Linux Version 0.2
initcall x25_init+0x0/0x6a returned 0 after 6510 usecs
calling  can_init+0x0/0x125 @ 1
can: controller area network core (rev 20090105 abi 8)
NET: Registered protocol family 29
initcall can_init+0x0/0x125 returned 0 after 6510 usecs
calling  bcm_module_init+0x0/0x5e @ 1
can: broadcast manager protocol (rev 20090105 t)
initcall bcm_module_init+0x0/0x5e returned 0 after 3255 usecs
calling  l2cap_init+0x0/0xe4 @ 1
Bluetooth: L2CAP ver 2.13
Bluetooth: L2CAP socket layer initialized
initcall l2cap_init+0x0/0xe4 returned 0 after 6510 usecs
calling  sco_init+0x0/0xea @ 1
Bluetooth: SCO (Voice Link) ver 0.6
Bluetooth: SCO socket layer initialized
initcall sco_init+0x0/0xea returned 0 after 6510 usecs
calling  bnep_init+0x0/0xb3 @ 1
Bluetooth: BNEP (Ethernet Emulation) ver 1.3
Bluetooth: BNEP filters: multicast
initcall bnep_init+0x0/0xb3 returned 0 after 6510 usecs
calling  cmtp_init+0x0/0x35 @ 1
Bluetooth: CMTP (CAPI Emulation) ver 1.0
initcall cmtp_init+0x0/0x35 returned 0 after 3255 usecs
calling  init_sunrpc+0x0/0x72 @ 1
RPC: Registered udp transport module.
RPC: Registered tcp transport module.
initcall init_sunrpc+0x0/0x72 returned 0 after 6510 usecs
calling  init_rpcsec_gss+0x0/0x52 @ 1
initcall init_rpcsec_gss+0x0/0x52 returned 0 after 0 usecs
calling  init_kerberos_module+0x0/0x34 @ 1
initcall init_kerberos_module+0x0/0x34 returned 0 after 0 usecs
calling  init_spkm3_module+0x0/0x34 @ 1
initcall init_spkm3_module+0x0/0x34 returned 0 after 0 usecs
calling  af_rxrpc_init+0x0/0x1b4 @ 1
NET: Registered protocol family 33
initcall af_rxrpc_init+0x0/0x1b4 returned 0 after 3255 usecs
calling  atm_clip_init+0x0/0xb6 @ 1
initcall atm_clip_init+0x0/0xb6 returned 0 after 0 usecs
calling  br2684_init+0x0/0x3f @ 1
initcall br2684_init+0x0/0x3f returned 0 after 0 usecs
calling  pppoatm_init+0x0/0x19 @ 1
initcall pppoatm_init+0x0/0x19 returned 0 after 0 usecs
calling  decnet_init+0x0/0x96 @ 1
NET4: DECnet for Linux: V.2.5.68s (C) 1995-2003 Linux DECnet Project Te=
am
DECnet: Routing cache hash table of 512 buckets, 36Kbytes
NET: Registered protocol family 12
initcall decnet_init+0x0/0x96 returned 0 after 9765 usecs
calling  dn_rtmsg_init+0x0/0x7f @ 1
initcall dn_rtmsg_init+0x0/0x7f returned 0 after 0 usecs
calling  phonet_init+0x0/0x7d @ 1
NET: Registered protocol family 35
initcall phonet_init+0x0/0x7d returned 0 after 3255 usecs
calling  pep_register+0x0/0x17 @ 1
initcall pep_register+0x0/0x17 returned 0 after 0 usecs
calling  vlan_proto_init+0x0/0xca @ 1
802.1Q VLAN Support v1.8 Ben Greear <greearb@candelatech.com>
All bugs added by David S. Miller <davem@redhat.com>
initcall vlan_proto_init+0x0/0xca returned 0 after 6510 usecs
calling  sctp_init+0x0/0x852 @ 1
SCTP: Hash tables configured (established 14563 bind 14563)
sctp_init_sock(sk: ffff88003c160000)
initcall sctp_init+0x0/0x852 returned 0 after 13020 usecs
calling  lib80211_init+0x0/0x20 @ 1
lib80211: common routines for IEEE802.11 drivers
lib80211_crypt: registered algorithm 'NULL'
initcall lib80211_init+0x0/0x20 returned 0 after 6510 usecs
calling  lib80211_crypto_wep_init+0x0/0x12 @ 1
lib80211_crypt: registered algorithm 'WEP'
initcall lib80211_crypto_wep_init+0x0/0x12 returned 0 after 3255 usecs
calling  lib80211_crypto_ccmp_init+0x0/0x12 @ 1
lib80211_crypt: registered algorithm 'CCMP'
initcall lib80211_crypto_ccmp_init+0x0/0x12 returned 0 after 3255 usecs
calling  lib80211_crypto_tkip_init+0x0/0x12 @ 1
lib80211_crypt: registered algorithm 'TKIP'
initcall lib80211_crypto_tkip_init+0x0/0x12 returned 0 after 3255 usecs
calling  tipc_init+0x0/0xc2 @ 1
TIPC: Activated (version 1.6.4 compiled Jun 16 2009 12:02:48)
NET: Registered protocol family 30
TIPC: Started in single node mode
initcall tipc_init+0x0/0xc2 returned 0 after 9765 usecs
calling  ieee802154_nl_init+0x0/0x90 @ 1
initcall ieee802154_nl_init+0x0/0x90 returned 0 after 26041 usecs
calling  af_ieee802154_init+0x0/0x7a @ 1
NET: Registered protocol family 36
initcall af_ieee802154_init+0x0/0x7a returned 0 after 3255 usecs
calling  wimax_subsys_init+0x0/0x20c @ 1
initcall wimax_subsys_init+0x0/0x20c returned 0 after 13020 usecs
calling  cpufreq_p4_init+0x0/0x63 @ 1
initcall cpufreq_p4_init+0x0/0x63 returned -19 after 0 usecs
calling  update_mp_table+0x0/0x6d3 @ 1
initcall update_mp_table+0x0/0x6d3 returned 0 after 0 usecs
calling  lapic_insert_resource+0x0/0x42 @ 1
initcall lapic_insert_resource+0x0/0x42 returned 0 after 0 usecs
calling  ioapic_insert_resources+0x0/0x63 @ 1
initcall ioapic_insert_resources+0x0/0x63 returned 0 after 0 usecs
calling  io_apic_bug_finalize+0x0/0x1b @ 1
initcall io_apic_bug_finalize+0x0/0x1b returned 0 after 0 usecs
calling  check_early_ioremap_leak+0x0/0x6d @ 1
initcall check_early_ioremap_leak+0x0/0x6d returned 0 after 0 usecs
calling  pat_memtype_list_init+0x0/0x29 @ 1
initcall pat_memtype_list_init+0x0/0x29 returned 0 after 0 usecs
calling  init_oops_id+0x0/0x40 @ 1
initcall init_oops_id+0x0/0x40 returned 0 after 0 usecs
calling  disable_boot_consoles+0x0/0x3a @ 1
initcall disable_boot_consoles+0x0/0x3a returned 0 after 0 usecs
calling  pm_qos_power_init+0x0/0xe1 @ 1
initcall pm_qos_power_init+0x0/0xe1 returned 0 after 0 usecs
calling  taskstats_init+0x0/0x98 @ 1
registered taskstats version 1
initcall taskstats_init+0x0/0x98 returned 0 after 3255 usecs
calling  clear_boot_tracer+0x0/0x2f @ 1
initcall clear_boot_tracer+0x0/0x2f returned 0 after 0 usecs
calling  fail_page_alloc_debugfs+0x0/0xe9 @ 1
initcall fail_page_alloc_debugfs+0x0/0xe9 returned 0 after 0 usecs
calling  max_swapfiles_check+0x0/0x8 @ 1
initcall max_swapfiles_check+0x0/0x8 returned 0 after 0 usecs
calling  afs_init+0x0/0x1e5 @ 1
kAFS: Red Hat AFS client v0.1 registering.
initcall afs_init+0x0/0x1e5 returned 0 after 6510 usecs
calling  fail_make_request_debugfs+0x0/0x19 @ 1
initcall fail_make_request_debugfs+0x0/0x19 returned 0 after 3255 usecs
calling  fail_io_timeout_debugfs+0x0/0x1b @ 1
initcall fail_io_timeout_debugfs+0x0/0x1b returned 0 after 0 usecs
calling  random32_reseed+0x0/0xf0 @ 1
initcall random32_reseed+0x0/0xf0 returned 0 after 0 usecs
calling  pci_resource_alignment_sysfs_init+0x0/0x19 @ 1
initcall pci_resource_alignment_sysfs_init+0x0/0x19 returned 0 after 0 =
usecs
calling  pci_sysfs_init+0x0/0x55 @ 1
initcall pci_sysfs_init+0x0/0x55 returned 0 after 0 usecs
calling  regulator_init_complete+0x0/0x14b @ 1
initcall regulator_init_complete+0x0/0x14b returned 0 after 0 usecs
calling  seqgen_init+0x0/0xf @ 1
initcall seqgen_init+0x0/0xf returned 0 after 0 usecs
calling  hd_init+0x0/0x343 @ 1
hd: no drives specified - use hd=3Dcyl,head,sectors on kernel command l=
ine
initcall hd_init+0x0/0x343 returned -1 after 3255 usecs
initcall hd_init+0x0/0x343 returned with error code -1=20
calling  scsi_complete_async_scans+0x0/0x180 @ 1
initcall scsi_complete_async_scans+0x0/0x180 returned 0 after 0 usecs
calling  tcp_congestion_default+0x0/0x12 @ 1
initcall tcp_congestion_default+0x0/0x12 returned 0 after 0 usecs
calling  ip_auto_config+0x0/0x10db @ 1
initcall ip_auto_config+0x0/0x10db returned 0 after 0 usecs
calling  initialize_hashrnd+0x0/0x19 @ 1
initcall initialize_hashrnd+0x0/0x19 returned 0 after 0 usecs
async_waiting @ 1
async_continuing @ 1 after 0 usec
EXT3-fs: INFO: recovery required on readonly filesystem.
EXT3-fs: write access will be enabled during recovery.
kjournald starting.  Commit interval 5 seconds
EXT3-fs: recovery complete.
EXT3-fs: mounted filesystem with ordered data mode.
VFS: Mounted root (ext3 filesystem) readonly on device 8:6.
async_waiting @ 1
async_continuing @ 1 after 0 usec
debug: unmapping init memory ffffffff82500000..ffffffff82763000
Not activating Mandatory Access Control now since /sbin/tomoyo-init doe=
sn't exist.
Mount failed for selinuxfs on /selinux:  No such device
INIT: version 2.86 booting
		Welcome to Fedora=20
		Press 'I' to enter interactive startup.
Cannot access the Hardware Clock via any known method.
Use the --debug option to see the details of our search for an access m=
ethod.
Setting clock  (localtime): Tue Jun 16 18:05:23 CEST 2009 [  OK  ]
Starting udev: /sbin/start_udev: line 85: cannot redirect standard inpu=
t from /dev/null: No such file or directory
/sbin/start_udev: line 85: cannot redirect standard input from /dev/nul=
l: No such file or directory
/sbin/start_udev: line 187: /proc/sys/kernel/hotplug: No such file or d=
irectory
scsi_id[2596]: scsi_id: unable to access parent device of '/bus/usb/dri=
vers/st5481_usb'
eth1: link down
------------[ cut here ]------------
WARNING: at lib/dma-debug.c:812 check_unmap+0x1c9/0x6b0()
Hardware name: System Product Name
forcedeth 0000:00:0a.0: DMA-API: device driver frees DMA memory with wr=
ong function [device address=3D0x000000003b13b7aa] [size=3D42 bytes] [m=
apped as single] [unmapped as page]
Pid: 3435, comm: arping Not tainted 2.6.30-tip #54077
Call Trace:
 <IRQ>  [<ffffffff81540019>] ? check_unmap+0x1c9/0x6b0
 [<ffffffff8105427b>] warn_slowpath_common+0x7b/0xd0
 [<ffffffff81054331>] warn_slowpath_fmt+0x41/0x50
 [<ffffffff81d429e2>] ? _spin_lock_irqsave+0x82/0xa0
 [<ffffffff8153ff14>] ? check_unmap+0xc4/0x6b0
 [<ffffffff81540019>] check_unmap+0x1c9/0x6b0
 [<ffffffff81080e4f>] ? __lock_acquire+0x14f/0xd20
 [<ffffffff81014b83>] ? sched_clock+0x13/0x30
 [<ffffffff81540721>] debug_dma_unmap_page+0x51/0x60
 [<ffffffff817f7533>] nv_tx_done_optimized+0x1b3/0x2e0
 [<ffffffff817fcbc2>] nv_napi_poll+0x72/0x690
 [<ffffffff81b45f6f>] net_rx_action+0x19f/0x2a0
 [<ffffffff81b45ee0>] ? net_rx_action+0x110/0x2a0
 [<ffffffff8105b932>] __do_softirq+0xd2/0x1c0
 [<ffffffff8100d60c>] call_softirq+0x1c/0x30
 [<ffffffff8100f855>] do_softirq+0x95/0xd0
 [<ffffffff8105ac7d>] irq_exit+0x5d/0x70
 [<ffffffff81d43588>] do_IRQ+0x78/0xf0
 [<ffffffff810c8cf9>] ? perf_swcounter_event+0x119/0x180
 [<ffffffff8100cdd3>] ret_from_intr+0x0/0x16
 <EOI>  [<ffffffff810833fb>] ? lock_release+0xbb/0x230
 [<ffffffff810c8d11>] ? perf_swcounter_event+0x131/0x180
 [<ffffffff810c8c84>] ? perf_swcounter_event+0xa4/0x180
 [<ffffffff8103105c>] ? do_page_fault+0xac/0x360
 [<ffffffff81d43135>] ? page_fault+0x25/0x30
---[ end trace d56a5dadc3150dbb ]---
Mapped at:
 [<ffffffff81540b25>] debug_dma_map_page+0x85/0x170
 [<ffffffff817f91b6>] nv_start_xmit_optimized+0x1f6/0x700
 [<ffffffff81b491ec>] dev_hard_start_xmit+0x2dc/0x3a0
 [<ffffffff81b605ae>] __qdisc_run+0x25e/0x2b0
 [<ffffffff81b49718>] dev_queue_xmit+0x328/0x500
IPv4 FIB: Using LC-trie version 0.408
[ifconfig:3516]: Creates X25 socket.
Pid: 3516, comm: ifconfig Tainted: G        W  2.6.30-tip #54077
Call Trace:
 [<ffffffff81c1a1ab>] x25_create+0x4b/0x1b0
 [<ffffffff81b37148>] __sock_create+0x118/0x220
 [<ffffffff81b370d4>] ? __sock_create+0xa4/0x220
 [<ffffffff81b372b2>] sock_create+0x32/0x40
 [<ffffffff81b3753c>] sys_socket+0x3c/0x80
 [<ffffffff8100c3d2>] system_call_fastpath+0x16/0x1b
[  OK  ]
Loading default keymap (us): [  OK  ]
Setting hostname mercury:  [  OK  ]
CPA self-test:
 4k 262128 large 0 gb 0 x 262128[ffff880000000000-ffff88003ffef000] mis=
s 0
 4k 262128 large 0 gb 0 x 262128[ffff880000000000-ffff88003ffef000] mis=
s 0
Checking filesystems
 4k 262128 large 0 gb 0 x 262128[ffff880000000000-ffff88003ffef000] mis=
s 0
ok.
Checking all file systems.
[/sbin/fsck.ext3 (1) -- /] fsck.ext3 -a /dev/sda6=20
/1: clean, 379384/7325696 files, 3515098/7325632 blocks
[/sbin/fsck.ext3 (1) -- /home] fsck.ext3 -a /dev/sda5=20
/home: recovering journal
/home: clean, 134060/6111232 files, 2480753/12209392 blocks
[  OK  ]
Remounting root filesystem in read-write mode:  EXT3 FS on sda6, intern=
al journal
[  OK  ]
Mounting local filesystems:  kjournald starting.  Commit interval 5 sec=
onds
EXT3 FS on sda5, internal journal
EXT3-fs: mounted filesystem with ordered data mode.
[  OK  ]
Enabling local filesystem quotas:  [  OK  ]
Enabling /etc/fstab swaps:  Adding 3911816k swap on /dev/sda2.  Priorit=
y:-1 extents:1 across:3911816k=20
[  OK  ]
INIT: Entering runlevel: 3
Entering non-interactive startup
=46ATAL: Could not load /lib/modules/2.6.30-tip/modules.dep: No such fi=
le or directory
Bringing up loopback interface:  [ifconfig:3798]: Creates X25 socket.
Pid: 3798, comm: ifconfig Tainted: G        W  2.6.30-tip #54077
Call Trace:
 [<ffffffff81c1a1ab>] x25_create+0x4b/0x1b0
 [<ffffffff81b37148>] __sock_create+0x118/0x220
 [<ffffffff81b370d4>] ? __sock_create+0xa4/0x220
 [<ffffffff81b372b2>] sock_create+0x32/0x40
 [<ffffffff81b3753c>] sys_socket+0x3c/0x80
 [<ffffffff8100c3d2>] system_call_fastpath+0x16/0x1b
[  OK  ]
Bringing up interface eth0:  [ifconfig:3889]: Creates X25 socket.
Pid: 3889, comm: ifconfig Tainted: G        W  2.6.30-tip #54077
Call Trace:
 [<ffffffff81c1a1ab>] x25_create+0x4b/0x1b0
 [<ffffffff81b37148>] __sock_create+0x118/0x220
 [<ffffffff81b370d4>] ? __sock_create+0xa4/0x220
 [<ffffffff81b372b2>] sock_create+0x32/0x40
 [<ffffffff81b3753c>] sys_socket+0x3c/0x80
 [<ffffffff8100c3d2>] system_call_fastpath+0x16/0x1b
[  OK  ]
=46ATAL: Could not load /lib/modules/2.6.30-tip/modules.dep: No such fi=
le or directory
Starting system message bus: warning: `dbus-daemon' uses 32-bit capabil=
ities (legacy support in use)
[  OK  ]
Starting sshd: [  OK  ]
Starting postgresql service:=20
