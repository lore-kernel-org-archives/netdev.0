From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [bug, netconsole, SLUB] BUG skbuff_head_cache: Poison
	overwritten
Date: Mon, 21 Jul 2008 13:13:22 +0200
Message-ID: <20080721111322.GA17251@elte.hu>
References: <20080717214222.GA29449@elte.hu> <Pine.LNX.4.64.0807181149460.3852@sbz-30.cs.Helsinki.FI> <20080718091146.GQ6875@elte.hu> <20080721094110.GA16029@elte.hu> <84144f020807210252k68d5cf65i8c7ae3c11cecc046@mail.gmail.com> <20080721100627.GA5953@2ka.mipt.ru> <20080721105051.GA5830@elte.hu> <19f34abd0807210403n1bca348fn83773b55a08b7993@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	Pekka Enberg <penberg@cs.helsinki.fi>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"Rafael J. Wysocki" <rjw@sisk.pl>, cl@linux-foundation.org,
	davem@davemloft.net
To: Vegard Nossum <vegard.nossum@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.mail.elte.hu ([157.181.1.138]:57667 "EHLO mx3.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751835AbYGULOC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Jul 2008 07:14:02 -0400
Content-Disposition: inline
In-Reply-To: <19f34abd0807210403n1bca348fn83773b55a08b7993@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Vegard Nossum <vegard.nossum@gmail.com> wrote:

> On Mon, Jul 21, 2008 at 12:50 PM, Ingo Molnar <mingo@elte.hu> wrote:
> > the problem is, most of the crashes dont come with any usable dump.=
 This
> > is a laptop so netconsole is the only reliable route out - and if
> > something in networking crashes chances are that it hoses netconsol=
e
> > before it can get anything out.
> >
> > Another thing is that i'm activating netconsole on this box via a k=
ernel
> > boot line and from within a bzImage (to get it activated as early a=
s
> > possible) - maybe that's a tad too early for certain initialization
> > sequences?
> >
> > I could try run tests with netconsole deactivated, if you think=20
> > that's a worthwile line of probing this problem. (although that=20
> > would make me do blind tests in essence - having kernel log output=20
> > is really essential.)
>=20
> How about posting your custom patches for public review? :-D

I changed nothing in that area - being able to enable the netconsole=20
like that has been a years-old feature. Otherwise it's just tip/master,=
=20
but the weirdnesses were reproducible under plain linus/master as well.

> (There was recently an odd case of kzalloc() succeeding even though i=
t=20
> was called before the slab caches were initialized -- and it only=20
> generated a warning about irqs-on happening too early. I just mean to=
=20
> say that it _can_ happen. On another machine, it crashed=20
> spectacularly. I guess you're not enabling the netconsole before slab=
=20
> allocator is up?)

if i had any changes in that area i'd have declared them. Find below th=
e=20
full bootlog of the last crash - can you see any init order weirdness i=
n=20
it?

Btw., i disabled netconsole now and got 3 successful bootups in a row.=20
(which is still not significant statistically - i had a series of 40=20
bootups in a row before. Then again i had like 5 failures in a row=20
earlier this morning, before disabling netconsole.)

Btw. #2, in the log below you can see this partial line:

 initcall pm_qos_power_init+0x0/0x54Linux version 2.6.26-tip (mingo@eur=
ope) (gcc version 4.2.2) #3261 SMP Mon Jul 21 11:17:45 CEST 2008

That was a previous bootup with another failure but which came without=20
any log output.

Hey, if you find this report frustrating, dont worry, i almost never=20
report easy bugs - i can fix them just fine ;-)

	Ingo

--------------->
initcall pm_qos_power_init+0x0/0x54Linux version 2.6.26-tip (mingo@euro=
pe) (gcc version 4.2.2) #3261 SMP Mon Jul 21 11:17:45 CEST 2008
BIOS-provided physical RAM map:
 BIOS-e820: 0000000000000000 - 000000000009f000 (usable)
 BIOS-e820: 000000000009f000 - 00000000000a0000 (reserved)
 BIOS-e820: 00000000000d2000 - 00000000000d4000 (reserved)
 BIOS-e820: 00000000000dc000 - 0000000000100000 (reserved)
 BIOS-e820: 0000000000100000 - 000000007f6e0000 (usable)
 BIOS-e820: 000000007f6e0000 - 000000007f6f3000 (ACPI data)
 BIOS-e820: 000000007f6f3000 - 000000007f700000 (ACPI NVS)
 BIOS-e820: 000000007f700000 - 0000000080000000 (reserved)
 BIOS-e820: 00000000f0000000 - 00000000f4000000 (reserved)
 BIOS-e820: 00000000fec00000 - 00000000fec10000 (reserved)
 BIOS-e820: 00000000fed00000 - 00000000fed00400 (reserved)
 BIOS-e820: 00000000fed14000 - 00000000fed1a000 (reserved)
 BIOS-e820: 00000000fed1c000 - 00000000fed90000 (reserved)
 BIOS-e820: 00000000fee00000 - 00000000fee01000 (reserved)
 BIOS-e820: 00000000ff800000 - 0000000100000000 (reserved)
debug: ignoring loglevel setting.
using polling idle threads.
using polling idle threads.
last_pfn =3D 0x7f6e0 max_arch_pfn =3D 0x1000000
Warning only 896MB will be used.
Use a HIGHMEM enabled kernel.
kernel direct mapping tables up to 38000000 @ 7000-c000
NX (Execute Disable) protection: active
DMI present.
ACPI: RSDP 000F68A0, 0024 (r2 LENOVO)
ACPI: XSDT 7F6E631F, 0074 (r1 LENOVO TP-79        1020  LTP        0)
ACPI: FACP 7F6E6400, 00F4 (r3 LENOVO TP-79        1020 LNVO        1)
ACPI Warning (tbfadt-0447): Optional field "Gpe1Block" has zero address=
 or length: 000000000000102C/0 [20080609]
ACPI: DSDT 7F6E65E7, C765 (r1 LENOVO TP-79        1020 MSFT  100000E)
ACPI: FACS 7F6F4000, 0040
ACPI: SSDT 7F6E65B4, 0033 (r1 LENOVO TP-79        1020 MSFT  100000E)
ACPI: ECDT 7F6F2D4C, 0052 (r1 LENOVO TP-79        1020 LNVO        1)
ACPI: TCPA 7F6F2D9E, 0032 (r2 LENOVO TP-79        1020 LNVO        1)
ACPI: APIC 7F6F2DD0, 0068 (r1 LENOVO TP-79        1020 LNVO        1)
ACPI: MCFG 7F6F2E38, 003E (r1 LENOVO TP-79        1020 LNVO        1)
ACPI: HPET 7F6F2E76, 0038 (r1 LENOVO TP-79        1020 LNVO        1)
ACPI: BOOT 7F6F2FD8, 0028 (r1 LENOVO TP-79        1020  LTP        1)
ACPI: SSDT 7F6E58DA, 0507 (r1 LENOVO TP-79        1020 INTL 20050513)
ACPI: SSDT 7F6E5702, 01D8 (r1 LENOVO TP-79        1020 INTL 20050513)
Entering add_active_range(0, 0x0, 0x9f) 0 entries of 256 used
Entering add_active_range(0, 0x100, 0x38000) 1 entries of 256 used
896MB LOWMEM available.
  mapped low ram: 0 - 38000000
  low ram: 00000000 - 38000000
  bootmap 00009000 - 00010000
(8 early reservations) =3D=3D> bootmem [0000000000 - 0038000000]
  #0 [0000000000 - 0000001000]   BIOS data page =3D=3D> [0000000000 - 0=
000001000]
  #1 [0000001000 - 0000002000]    EX TRAMPOLINE =3D=3D> [0000001000 - 0=
000002000]
  #2 [0000006000 - 0000007000]       TRAMPOLINE =3D=3D> [0000006000 - 0=
000007000]
  #3 [0000100000 - 0000ccbc50]    TEXT DATA BSS =3D=3D> [0000100000 - 0=
000ccbc50]
  #4 [0000ccc000 - 0000d18000]    INIT_PG_TABLE =3D=3D> [0000ccc000 - 0=
000d18000]
  #5 [000009f000 - 0000100000]    BIOS reserved =3D=3D> [000009f000 - 0=
000100000]
  #6 [0000007000 - 0000009000]          PGTABLE =3D=3D> [0000007000 - 0=
000009000]
  #7 [0000009000 - 0000010000]          BOOTMAP =3D=3D> [0000009000 - 0=
000010000]
Zone PFN ranges:
  DMA      0x00000000 -> 0x00001000
  Normal   0x00001000 -> 0x00038000
Movable zone start PFN for each node
early_node_map[2] active PFN ranges
    0: 0x00000000 -> 0x0000009f
    0: 0x00000100 -> 0x00038000
On node 0 totalpages: 229279
free_area_init_node: node 0, pgdat c081bf80, node_mem_map c1000000
  DMA zone: 56 pages used for memmap
  DMA zone: 0 pages reserved
  DMA zone: 3943 pages, LIFO batch:0
  Normal zone: 3080 pages used for memmap
  Normal zone: 222200 pages, LIFO batch:31
  Movable zone: 0 pages used for memmap
ACPI: PM-Timer IO Port: 0x1008
ACPI: Local APIC address 0xfee00000
ACPI: LAPIC (acpi_id[0x00] lapic_id[0x00] enabled)
ACPI: LAPIC (acpi_id[0x01] lapic_id[0x01] enabled)
ACPI: LAPIC_NMI (acpi_id[0x00] high edge lint[0x1])
ACPI: LAPIC_NMI (acpi_id[0x01] high edge lint[0x1])
ACPI: IOAPIC (id[0x01] address[0xfec00000] gsi_base[0])
IOAPIC[0]: apic_id 1, version 32, address 0xfec00000, GSI 0-23
ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
Bus #0 is ISA
ACPI: IRQ0 used by override.
ACPI: IRQ2 used by override.
ACPI: IRQ9 used by override.
Enabling APIC mode:  Flat.  Using 1 I/O APICs
ACPI: HPET id: 0x8086a201 base: 0xfed00000
SMP: Allowing 2 CPUs, 0 hotplug CPUs
mapped APIC to ffffb000 (fee00000)
mapped IOAPIC to ffffa000 (fec00000)
Allocating PCI resources starting at 88000000 (gap: 80000000:70000000)
PERCPU: Allocating 332592 bytes of per cpu data
NR_CPUS: 8, nr_cpu_ids: 2, nr_node_ids 1
Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 22=
6143
Kernel command line: root=3D/dev/sda1 console=3Dtty profile=3D0 debug i=
nitcall_debug enforcing=3D0 apic=3Dverbose sysrq_always_enabled ignore_=
loglevel selinux=3D1 relaxed_check=3D1 netconsole=3D4444@10.0.1.15/eth0=
,4444@10.0.1.16/00:19:d1:01:f5:55 nmi_watchdog=3D2 idle=3Dpoll no_hz=3D=
off nmi_watchdog=3D0 nolapic_timer hpet=3Ddisable idle=3Dmwait idle=3Dp=
oll nopat
kernel profiling enabled (shift: 0)
debug: sysrq always enabled.
Enabling fast FPU save and restore... done.
Enabling unmasked SIMD FPU exception support... done.
Initializing CPU#0
CPU 0 irqstacks, hard=3Dc0941000 soft=3Dc0939000
PID hash table entries: 4096 (order: 12, 16384 bytes)
Extended CMOS year: 2000
TSC calibrated against PM_TIMER
Detected 1828.742 MHz processor.
Console: colour VGA+ 80x25
console [tty0] enabled
Lock dependency validator: Copyright (c) 2006 Red Hat, Inc., Ingo Molna=
r
=2E.. MAX_LOCKDEP_SUBCLASSES:    8
=2E.. MAX_LOCK_DEPTH:          48
=2E.. MAX_LOCKDEP_KEYS:        2048
=2E.. CLASSHASH_SIZE:           1024
=2E.. MAX_LOCKDEP_ENTRIES:     8192
=2E.. MAX_LOCKDEP_CHAINS:      16384
=2E.. CHAINHASH_SIZE:          8192
 memory used by lock dependency info: 1088 kB
 per task-struct memory footprint: 2688 bytes
------------------------
| Locking API testsuite:
-----------------------------------------------------------------------=
-----
                                 | spin |wlock |rlock |mutex | wsem | r=
sem |
  ---------------------------------------------------------------------=
-----
                     A-A deadlock:  ok  |  ok  |  ok  |  ok  |  ok  |  =
ok  |
                 A-B-B-A deadlock:  ok  |  ok  |  ok  |  ok  |  ok  |  =
ok  |
             A-B-B-C-C-A deadlock:  ok  |  ok  |  ok  |  ok  |  ok  |  =
ok  |
             A-B-C-A-B-C deadlock:  ok  |  ok  |  ok  |  ok  |  ok  |  =
ok  |
         A-B-B-C-C-D-D-A deadlock:  ok  |  ok  |  ok  |  ok  |  ok  |  =
ok  |
         A-B-C-D-B-D-D-A deadlock:  ok  |  ok  |  ok  |  ok  |  ok  |  =
ok  |
         A-B-C-D-B-C-D-A deadlock:  ok  |  ok  |  ok  |  ok  |  ok  |  =
ok  |
                    double unlock:  ok  |  ok  |  ok  |  ok  |  ok  |  =
ok  |
                  initialize held:  ok  |  ok  |  ok  |  ok  |  ok  |  =
ok  |
                 bad unlock order:  ok  |  ok  |  ok  |  ok  |  ok  |  =
ok  |
  ---------------------------------------------------------------------=
-----
              recursive read-lock:             |  ok  |             |  =
ok  |
           recursive read-lock #2:             |  ok  |             |  =
ok  |
            mixed read-write-lock:             |  ok  |             |  =
ok  |
            mixed write-read-lock:             |  ok  |             |  =
ok  |
  ---------------------------------------------------------------------=
-----
     hard-irqs-on + irq-safe-A/12:  ok  |  ok  |  ok  |
     soft-irqs-on + irq-safe-A/12:  ok  |  ok  |  ok  |
     hard-irqs-on + irq-safe-A/21:  ok  |  ok  |  ok  |
     soft-irqs-on + irq-safe-A/21:  ok  |  ok  |  ok  |
       sirq-safe-A =3D> hirqs-on/12:  ok  |  ok  |  ok  |
       sirq-safe-A =3D> hirqs-on/21:  ok  |  ok  |  ok  |
         hard-safe-A + irqs-on/12:  ok  |  ok  |  ok  |
         soft-safe-A + irqs-on/12:  ok  |  ok  |  ok  |
         hard-safe-A + irqs-on/21:  ok  |  ok  |  ok  |
         soft-safe-A + irqs-on/21:  ok  |  ok  |  ok  |
    hard-safe-A + unsafe-B #1/123:  ok  |  ok  |  ok  |
    soft-safe-A + unsafe-B #1/123:  ok  |  ok  |  ok  |
    hard-safe-A + unsafe-B #1/132:  ok  |  ok  |  ok  |
    soft-safe-A + unsafe-B #1/132:  ok  |  ok  |  ok  |
    hard-safe-A + unsafe-B #1/213:  ok  |  ok  |  ok  |
    soft-safe-A + unsafe-B #1/213:  ok  |  ok  |  ok  |
    hard-safe-A + unsafe-B #1/231:  ok  |  ok  |  ok  |
    soft-safe-A + unsafe-B #1/231:  ok  |  ok  |  ok  |
    hard-safe-A + unsafe-B #1/312:  ok  |  ok  |  ok  |
    soft-safe-A + unsafe-B #1/312:  ok  |  ok  |  ok  |
    hard-safe-A + unsafe-B #1/321:  ok  |  ok  |  ok  |
    soft-safe-A + unsafe-B #1/321:  ok  |  ok  |  ok  |
    hard-safe-A + unsafe-B #2/123:  ok  |  ok  |  ok  |
    soft-safe-A + unsafe-B #2/123:  ok  |  ok  |  ok  |
    hard-safe-A + unsafe-B #2/132:  ok  |  ok  |  ok  |
    soft-safe-A + unsafe-B #2/132:  ok  |  ok  |  ok  |
    hard-safe-A + unsafe-B #2/213:  ok  |  ok  |  ok  |
    soft-safe-A + unsafe-B #2/213:  ok  |  ok  |  ok  |
    hard-safe-A + unsafe-B #2/231:  ok  |  ok  |  ok  |
    soft-safe-A + unsafe-B #2/231:  ok  |  ok  |  ok  |
    hard-safe-A + unsafe-B #2/312:  ok  |  ok  |  ok  |
    soft-safe-A + unsafe-B #2/312:  ok  |  ok  |  ok  |
    hard-safe-A + unsafe-B #2/321:  ok  |  ok  |  ok  |
    soft-safe-A + unsafe-B #2/321:  ok  |  ok  |  ok  |
      hard-irq lock-inversion/123:  ok  |  ok  |  ok  |
      soft-irq lock-inversion/123:  ok  |  ok  |  ok  |
      hard-irq lock-inversion/132:  ok  |  ok  |  ok  |
      soft-irq lock-inversion/132:  ok  |  ok  |  ok  |
      hard-irq lock-inversion/213:  ok  |  ok  |  ok  |
      soft-irq lock-inversion/213:  ok  |  ok  |  ok  |
      hard-irq lock-inversion/231:  ok  |  ok  |  ok  |
      soft-irq lock-inversion/231:  ok  |  ok  |  ok  |
      hard-irq lock-inversion/312:  ok  |  ok  |  ok  |
      soft-irq lock-inversion/312:  ok  |  ok  |  ok  |
      hard-irq lock-inversion/321:  ok  |  ok  |  ok  |
      soft-irq lock-inversion/321:  ok  |  ok  |  ok  |
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
-------------------------------------------------------
Good, all 218 testcases passed! |
---------------------------------
Dentry cache hash table entries: 131072 (order: 7, 524288 bytes)
Inode-cache hash table entries: 65536 (order: 6, 262144 bytes)
Memory: 872052k/917504k available (4655k kernel code, 45060k reserved, =
3079k data, 656k init, 0k highmem)
virtual kernel memory layout:
    fixmap  : 0xfffb8000 - 0xfffff000   ( 284 kB)
    vmalloc : 0xf8800000 - 0xfffb6000   ( 119 MB)
    lowmem  : 0xc0000000 - 0xf8000000   ( 896 MB)
      .init : 0xc0892000 - 0xc0936000   ( 656 kB)
      .data : 0xc058bc52 - 0xc088dacc   (3079 kB)
      .text : 0xc0100000 - 0xc058bc52   (4655 kB)
Checking if this processor honours the WP bit even in supervisor mode..=
=2EOk.
CPA: page pool initialized 16 of 16 pages preallocated
SLUB: Genslabs=3D12, HWalign=3D64, Order=3D0-3, MinObjects=3D0, CPUs=3D=
2, Nodes=3D1
Calibrating delay loop (skipped), value calculated using timer frequenc=
y.. <6>3657.48 BogoMIPS (lpj=3D1828742)
Security Framework initialized
SELinux:  Initializing.
SELinux:  Starting in permissive mode
Mount-cache hash table entries: 512
CPU: L1 I cache: 32K, L1 D cache: 32K
CPU: L2 cache: 2048K
CPU: Physical Processor ID: 0
CPU: Processor Core ID: 0
Checking 'hlt' instruction... OK.
ACPI: Core revision 20080609
enabled ExtINT on CPU#0
ESR value before enabling vector: 0x00000040  after: 0x00000000
ENABLING IO-APIC IRQs
init IO_APIC IRQs
 IO-APIC (apicid-pin) 1-0 not connected.
 IO-APIC (apicid-pin) 1-16, 1-17, 1-18, 1-19, 1-20, 1-21, 1-22, 1-23 no=
t connected.
=2E.TIMER: vector=3D0x31 apic1=3D0 pin1=3D2 apic2=3D-1 pin2=3D-1
CPU0: Intel Genuine Intel(R) CPU           T2400  @ 1.83GHz stepping 08
++++++++++++++++++++=3D_---CPU UP  1
lockdep: fixing up alternatives.
CPU 1 irqstacks, hard=3Dc0942000 soft=3Dc093a000
Booting processor 1/1 ip 6000
Setting warm reset code and vector.
1.
2.
3.
Asserting INIT.
Waiting for send to finish...
Deasserting INIT.
Waiting for send to finish...
#startup loops: 2.
Sending STARTUP #1.
After apic_write.
Initializing CPU#1
Startup point 1.
CPU#1 (phys ID: 1) waiting for CALLOUT
Waiting for send to finish...
Sending STARTUP #2.
After apic_write.
Startup point 1.
Waiting for send to finish...
After Startup.
Before Callout 1.
After Callout 1.
CALLIN, before setup_local_APIC().
masked ExtINT on CPU#1
Calibrating delay using timer specific routine.. <6>3194.05 BogoMIPS (l=
pj=3D1597026)
Stack at about f7c7efb0
CPU: L1 I cache: 32K, L1 D cache: 32K
CPU: L2 cache: 2048K
CPU: Physical Processor ID: 0
CPU: Processor Core ID: 1
OK.
CPU1: Intel Genuine Intel(R) CPU           T2400  @ 1.83GHz stepping 08
CPU has booted.
checking TSC synchronization [CPU#0 -> CPU#1]:
Measured 580129 cycles TSC warp between CPUs, turning off TSC clock.
Marking TSC unstable due to check_tsc_sync_source failed
Brought up 2 CPUs
Boot done.
Before bogomips.
Total of 2 processors activated (6851.53 BogoMIPS).
Before bogocount - setting activated=3D1.
khelper used greatest stack depth: 3052 bytes left
khelper used greatest stack depth: 2684 bytes left
calling  init_cpufreq_transition_notifier_list+0x0/0x18
initcall init_cpufreq_transition_notifier_list+0x0/0x18 returned 0 afte=
r 0 msecs
calling  net_ns_init+0x0/0x10f
net_namespace: 800 bytes
initcall net_ns_init+0x0/0x10f returned 0 after 0 msecs
calling  cpufreq_tsc+0x0/0x13
initcall cpufreq_tsc+0x0/0x13 returned 0 after 0 msecs
calling  reboot_init+0x0/0x11
initcall reboot_init+0x0/0x11 returned 0 after 0 msecs
calling  sysctl_init+0x0/0x29
initcall sysctl_init+0x0/0x29 returned 0 after 0 msecs
calling  ksysfs_init+0x0/0x96
initcall ksysfs_init+0x0/0x96 returned 0 after 0 msecs
calling  init_jiffies_clocksource+0x0/0xf
initcall init_jiffies_clocksource+0x0/0xf returned 0 after 0 msecs
calling  pm_init+0x0/0x2d
initcall pm_init+0x0/0x2d returned 0 after 0 msecs
calling  filelock_init+0x0/0x27
initcall filelock_init+0x0/0x27 returned 0 after 0 msecs
calling  init_aout_binfmt+0x0/0xf
initcall init_aout_binfmt+0x0/0xf returned 0 after 0 msecs
calling  init_misc_binfmt+0x0/0x33
initcall init_misc_binfmt+0x0/0x33 returned 0 after 0 msecs
calling  init_script_binfmt+0x0/0xf
initcall init_script_binfmt+0x0/0xf returned 0 after 0 msecs
calling  init_elf_binfmt+0x0/0xf
initcall init_elf_binfmt+0x0/0xf returned 0 after 0 msecs
calling  debugfs_init+0x0/0x41
initcall debugfs_init+0x0/0x41 returned 0 after 0 msecs
calling  securityfs_init+0x0/0x41
initcall securityfs_init+0x0/0x41 returned 0 after 0 msecs
calling  random32_init+0x0/0x3f
initcall random32_init+0x0/0x3f returned 0 after 0 msecs
calling  cpufreq_core_init+0x0/0x51
initcall cpufreq_core_init+0x0/0x51 returned 0 after 0 msecs
calling  virtio_init+0x0/0x1f
initcall virtio_init+0x0/0x1f returned 0 after 0 msecs
calling  sock_init+0x0/0x51
initcall sock_init+0x0/0x51 returned 0 after 0 msecs
calling  netpoll_init+0x0/0x11
initcall netpoll_init+0x0/0x11 returned 0 after 0 msecs
calling  netlink_proto_init+0x0/0x107
NET: Registered protocol family 16
initcall netlink_proto_init+0x0/0x107 returned 0 after 0 msecs
calling  bdi_class_init+0x0/0x33
initcall bdi_class_init+0x0/0x33 returned 0 after 0 msecs
calling  kobject_uevent_init+0x0/0x3f
initcall kobject_uevent_init+0x0/0x3f returned 0 after 0 msecs
calling  pcibus_class_init+0x0/0xf
initcall pcibus_class_init+0x0/0xf returned 0 after 0 msecs
calling  pci_driver_init+0x0/0xf
initcall pci_driver_init+0x0/0xf returned 0 after 0 msecs
calling  lcd_class_init+0x0/0x3d
initcall lcd_class_init+0x0/0x3d returned 0 after 0 msecs
calling  backlight_class_init+0x0/0x3d
initcall backlight_class_init+0x0/0x3d returned 0 after 0 msecs
calling  tty_class_init+0x0/0x27
initcall tty_class_init+0x0/0x27 returned 0 after 0 msecs
calling  vtconsole_class_init+0x0/0x9a
initcall vtconsole_class_init+0x0/0x9a returned 0 after 0 msecs
calling  eisa_init+0x0/0x26
EISA bus registered
initcall eisa_init+0x0/0x26 returned 0 after 0 msecs
calling  enable_pci_io_ecs+0x0/0x2b
initcall enable_pci_io_ecs+0x0/0x2b returned 0 after 0 msecs
calling  rdc_board_setup+0x0/0x19
initcall rdc_board_setup+0x0/0x19 returned 0 after 0 msecs
calling  arch_kdebugfs_init+0x0/0x1de
initcall arch_kdebugfs_init+0x0/0x1de returned 0 after 0 msecs
calling  init_pit_clocksource+0x0/0x8f
initcall init_pit_clocksource+0x0/0x8f returned 0 after 0 msecs
calling  ffh_cstate_init+0x0/0x2c
initcall ffh_cstate_init+0x0/0x2c returned 0 after 0 msecs
calling  acpi_pci_init+0x0/0x38
ACPI: bus type pci registered
initcall acpi_pci_init+0x0/0x38 returned 0 after 0 msecs
calling  init_acpi_device_notify+0x0/0x43
initcall init_acpi_device_notify+0x0/0x43 returned 0 after 0 msecs
calling  pci_arch_init+0x0/0x4a
PCI: MCFG configuration 0: base f0000000 segment 0 buses 0 - 63
PCI: MCFG area at f0000000 reserved in E820
PCI: Using MMCONFIG for extended config space
PCI: Using configuration type 1 for base access
initcall pci_arch_init+0x0/0x4a returned 0 after 0 msecs
calling  topology_init+0x0/0x28
initcall topology_init+0x0/0x28 returned 0 after 0 msecs
calling  param_sysfs_init+0x0/0x154
initcall param_sysfs_init+0x0/0x154 returned 0 after 21 msecs
calling  pm_sysrq_init+0x0/0x16
initcall pm_sysrq_init+0x0/0x16 returned 0 after 0 msecs
calling  readahead_init+0x0/0x2f
initcall readahead_init+0x0/0x2f returned 0 after 0 msecs
calling  init_bio+0x0/0xa6
initcall init_bio+0x0/0xa6 returned 0 after 0 msecs
calling  blk_settings_init+0x0/0x1d
initcall blk_settings_init+0x0/0x1d returned 0 after 0 msecs
calling  blk_ioc_init+0x0/0x24
initcall blk_ioc_init+0x0/0x24 returned 0 after 0 msecs
calling  genhd_device_init+0x0/0x32
initcall genhd_device_init+0x0/0x32 returned 0 after 0 msecs
calling  pci_slot_init+0x0/0x3b
initcall pci_slot_init+0x0/0x3b returned 0 after 0 msecs
calling  fbmem_init+0x0/0x73
initcall fbmem_init+0x0/0x73 returned 0 after 0 msecs
calling  acpi_init+0x0/0x21b
ACPI: EC: EC description table is found, configuring boot EC
ACPI: EC: non-query interrupt received, switching to interrupt mode
ACPI: Interpreter enabled
ACPI: (supports S0 S3 S5)
ACPI: Using IOAPIC for interrupt routing
initcall acpi_init+0x0/0x21b returned 0 after 67 msecs
calling  acpi_scan_init+0x0/0xed
initcall acpi_scan_init+0x0/0xed returned 0 after 49 msecs
calling  acpi_ec_init+0x0/0x55
ACPI: EC: GPE =3D 0x1c, I/O: command/status =3D 0x66, data =3D 0x62
ACPI: EC: driver started in interrupt mode
initcall acpi_ec_init+0x0/0x55 returned 0 after 0 msecs
calling  acpi_pci_root_init+0x0/0x25
ACPI: PCI Root Bridge [PCI0] (0000:00)
PCI: 0000:00:02.0 reg 10 32bit mmio: [ee100000, ee17ffff]
PCI: 0000:00:02.0 reg 14 io port: [1800, 1807]
PCI: 0000:00:02.0 reg 18 32bit mmio: [d0000000, dfffffff]
PCI: 0000:00:02.0 reg 1c 32bit mmio: [ee200000, ee23ffff]
PCI: 0000:00:02.1 reg 10 32bit mmio: [ee180000, ee1fffff]
pci 0000:00:1b.0: PME# supported from D0 D3hot D3cold
pci 0000:00:1b.0: PME# disabled
pci 0000:00:1c.0: PME# supported from D0 D3hot D3cold
pci 0000:00:1c.0: PME# disabled
pci 0000:00:1c.1: PME# supported from D0 D3hot D3cold
pci 0000:00:1c.1: PME# disabled
pci 0000:00:1c.2: PME# supported from D0 D3hot D3cold
pci 0000:00:1c.2: PME# disabled
pci 0000:00:1c.3: PME# supported from D0 D3hot D3cold
pci 0000:00:1c.3: PME# disabled
PCI: 0000:00:1d.0 reg 20 io port: [1820, 183f]
PCI: 0000:00:1d.1 reg 20 io port: [1840, 185f]
PCI: 0000:00:1d.2 reg 20 io port: [1860, 187f]
PCI: 0000:00:1d.3 reg 20 io port: [1880, 189f]
PCI: 0000:00:1d.7 reg 10 32bit mmio: [ee444000, ee4443ff]
pci 0000:00:1d.7: PME# supported from D0 D3hot D3cold
pci 0000:00:1d.7: PME# disabled
pci 0000:00:1f.0: quirk: region 1000-107f claimed by ICH6 ACPI/GPIO/TCO
pci 0000:00:1f.0: quirk: region 1180-11bf claimed by ICH6 GPIO
PCI: 0000:00:1f.1 reg 10 io port: [0, 7]
PCI: 0000:00:1f.1 reg 14 io port: [0, 3]
PCI: 0000:00:1f.1 reg 18 io port: [0, 7]
PCI: 0000:00:1f.1 reg 1c io port: [0, 3]
PCI: 0000:00:1f.1 reg 20 io port: [1810, 181f]
PCI: 0000:00:1f.2 reg 10 io port: [18d0, 18d7]
PCI: 0000:00:1f.2 reg 14 io port: [18c4, 18c7]
PCI: 0000:00:1f.2 reg 18 io port: [18c8, 18cf]
PCI: 0000:00:1f.2 reg 1c io port: [18c0, 18c3]
PCI: 0000:00:1f.2 reg 20 io port: [18b0, 18bf]
PCI: 0000:00:1f.2 reg 24 32bit mmio: [ee444400, ee4447ff]
pci 0000:00:1f.2: PME# supported from D3hot
pci 0000:00:1f.2: PME# disabled
PCI: 0000:00:1f.3 reg 20 io port: [18e0, 18ff]
PCI: 0000:02:00.0 reg 10 32bit mmio: [ee000000, ee01ffff]
PCI: 0000:02:00.0 reg 18 io port: [2000, 201f]
pci 0000:02:00.0: PME# supported from D0 D3hot D3cold
pci 0000:02:00.0: PME# disabled
PCI: bridge 0000:00:1c.0 io port: [2000, 2fff]
PCI: bridge 0000:00:1c.0 32bit mmio: [ee000000, ee0fffff]
PCI: 0000:03:00.0 reg 10 32bit mmio: [edf00000, edf00fff]
pci 0000:03:00.0: PME# supported from D0 D3hot D3cold
pci 0000:03:00.0: PME# disabled
PCI: bridge 0000:00:1c.1 io port: [3000, 4fff]
PCI: bridge 0000:00:1c.1 32bit mmio: [ec000000, edffffff]
PCI: bridge 0000:00:1c.1 64bit mmio pref: [e4000000, e40fffff]
PCI: bridge 0000:00:1c.2 io port: [5000, 6fff]
PCI: bridge 0000:00:1c.2 32bit mmio: [e8000000, e9ffffff]
PCI: bridge 0000:00:1c.2 64bit mmio pref: [e4100000, e41fffff]
PCI: bridge 0000:00:1c.3 io port: [7000, 8fff]
PCI: bridge 0000:00:1c.3 32bit mmio: [ea000000, ebffffff]
PCI: bridge 0000:00:1c.3 64bit mmio pref: [e4200000, e42fffff]
PCI: 0000:15:00.0 reg 10 32bit mmio: [e4300000, e4300fff]
pci 0000:15:00.0: supports D1
pci 0000:15:00.0: supports D2
pci 0000:15:00.0: PME# supported from D0 D1 D2 D3hot D3cold
pci 0000:15:00.0: PME# disabled
pci 0000:00:1e.0: transparent bridge
PCI: bridge 0000:00:1e.0 io port: [9000, cfff]
PCI: bridge 0000:00:1e.0 32bit mmio: [e4300000, e7ffffff]
PCI: bridge 0000:00:1e.0 64bit mmio pref: [e0000000, e3ffffff]
bus 00 -> node 0
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.EXP0._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.EXP1._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.EXP2._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.EXP3._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PCI1._PRT]
initcall acpi_pci_root_init+0x0/0x25 returned 0 after 43 msecs
calling  acpi_pci_link_init+0x0/0x43
ACPI: PCI Interrupt Link [LNKA] (IRQs 3 4 5 6 7 9 10 *11)
ACPI: PCI Interrupt Link [LNKB] (IRQs 3 4 5 6 7 9 10 *11)
ACPI: PCI Interrupt Link [LNKC] (IRQs 3 4 5 6 7 9 10 *11)
ACPI: PCI Interrupt Link [LNKD] (IRQs 3 4 5 6 7 9 10 *11)
ACPI: PCI Interrupt Link [LNKE] (IRQs 3 4 5 6 7 9 10 *11)
ACPI: PCI Interrupt Link [LNKF] (IRQs 3 4 5 6 7 9 10 *11)
ACPI: PCI Interrupt Link [LNKG] (IRQs 3 4 5 6 7 9 10 *11)
ACPI: PCI Interrupt Link [LNKH] (IRQs 3 4 5 6 7 9 10 *11)
initcall acpi_pci_link_init+0x0/0x43 returned 0 after 10 msecs
calling  acpi_power_init+0x0/0x69
ACPI: Power Resource [PUBS] (on)
initcall acpi_power_init+0x0/0x69 returned 0 after 1 msecs
calling  acpi_system_init+0x0/0x167
initcall acpi_system_init+0x0/0x167 returned 0 after 0 msecs
calling  acpi_cm_sbs_init+0x0/0x7
initcall acpi_cm_sbs_init+0x0/0x7 returned 0 after 0 msecs
calling  pnp_init+0x0/0x19
Linux Plug and Play Support v0.97 (c) Adam Belay
initcall pnp_init+0x0/0x19 returned 0 after 0 msecs
calling  pnpacpi_init+0x0/0x7b
pnp: PnP ACPI init
ACPI: bus type pnp registered
pnp 00:00: parse allocated resources
pnp 00:00:   add mem 0x0-0x9ffff flags 0x1
pnp 00:00:   add mem 0xc0000-0xc3fff flags 0x0
pnp 00:00:   add mem 0xc4000-0xc7fff flags 0x0
pnp 00:00:   add mem 0xc8000-0xcbfff flags 0x0
pnp 00:00:   add mem 0xcc000-0xcffff flags 0x0
pnp 00:00:   add mem 0xd0000-0xd3fff flags 0x0
pnp 00:00:   add mem 0xd4000-0xd3fff flags 0x10000000
pnp 00:00:   add mem 0xd8000-0xd7fff flags 0x10000000
pnp 00:00:   add mem 0xdc000-0xdffff flags 0x1
pnp 00:00:   add mem 0xe0000-0xe3fff flags 0x0
pnp 00:00:   add mem 0xe4000-0xe7fff flags 0x0
pnp 00:00:   add mem 0xe8000-0xebfff flags 0x0
pnp 00:00:   add mem 0xec000-0xeffff flags 0x0
pnp 00:00:   add mem 0xf0000-0xfffff flags 0x0
pnp 00:00:   add mem 0x100000-0x7fffffff flags 0x1
pnp 00:00:   add mem 0xfec00000-0xffffffff flags 0x0
pnp 00:00:   add mem 0xfed41000-0xfed40fff flags 0x10000000
pnp 00:00: PNP0c01: calling quirk_system_pci_resources+0x0/0x188
pnp 00:00: Plug and Play ACPI device, IDs PNP0c01 (active)
pnp 00:01: parse allocated resources
pnp 00:01:   add io  0xcf8-0xcff flags 0x1
pnp 00:01: Plug and Play ACPI device, IDs PNP0a08 PNP0a03 (active)
pnp 00:02: parse allocated resources
pnp 00:02:   add io  0x10-0x1f flags 0x1
pnp 00:02:   add io  0x90-0x9f flags 0x1
pnp 00:02:   add io  0x24-0x25 flags 0x1
pnp 00:02:   add io  0x28-0x29 flags 0x1
pnp 00:02:   add io  0x2c-0x2d flags 0x1
pnp 00:02:   add io  0x30-0x31 flags 0x1
pnp 00:02:   add io  0x34-0x35 flags 0x1
pnp 00:02:   add io  0x38-0x39 flags 0x1
pnp 00:02:   add io  0x3c-0x3d flags 0x1
pnp 00:02:   add io  0xa4-0xa5 flags 0x1
pnp 00:02:   add io  0xa8-0xa9 flags 0x1
pnp 00:02:   add io  0xac-0xad flags 0x1
pnp 00:02:   add io  0xb0-0xb5 flags 0x1
pnp 00:02:   add io  0xb8-0xb9 flags 0x1
pnp 00:02:   add io  0xbc-0xbd flags 0x1
pnp 00:02:   add io  0x50-0x53 flags 0x1
pnp 00:02:   add io  0x72-0x77 flags 0x1
pnp 00:02:   add io  0x164e-0x164f flags 0x1
pnp 00:02:   add io  0x2e-0x2f flags 0x1
pnp 00:02:   add io  0x1000-0x107f flags 0x1
pnp 00:02:   add io  0x1180-0x11bf flags 0x1
pnp 00:02:   add io  0x800-0x80f flags 0x1
pnp 00:02:   add io  0x15e0-0x15ef flags 0x1
pnp 00:02:   add io  0x1600-0x165f flags 0x1
pnp 00:02:   add mem 0xf0000000-0xf3ffffff flags 0x1
pnp 00:02:   add mem 0xfed1c000-0xfed1ffff flags 0x1
pnp 00:02:   add mem 0xfed14000-0xfed17fff flags 0x1
pnp 00:02:   add mem 0xfed18000-0xfed18fff flags 0x1
pnp 00:02:   add mem 0xfed19000-0xfed19fff flags 0x1
pnp 00:02: PNP0c02: calling quirk_system_pci_resources+0x0/0x188
pnp 00:02: Plug and Play ACPI device, IDs PNP0c02 (active)
pnp 00:03: parse allocated resources
pnp 00:03:   add mem 0xfed00000-0xfed003ff flags 0x0
pnp 00:03: Plug and Play ACPI device, IDs PNP0103 (active)
pnp 00:04: parse allocated resources
pnp 00:04:   add io  0x0-0xf flags 0x1
pnp 00:04:   add io  0x80-0x8f flags 0x1
pnp 00:04:   add io  0xc0-0xdf flags 0x1
pnp 00:04:   add dma 4 flags 0x5
pnp 00:04: Plug and Play ACPI device, IDs PNP0200 (active)
pnp 00:05: parse allocated resources
pnp 00:05:   add io  0x61-0x61 flags 0x1
pnp 00:05: Plug and Play ACPI device, IDs PNP0800 (active)
pnp 00:06: parse allocated resources
pnp 00:06:   add io  0xf0-0xf0 flags 0x1
pnp 00:06:   add irq 13 flags 0x1
pnp 00:06: Plug and Play ACPI device, IDs PNP0c04 (active)
pnp 00:07: parse allocated resources
pnp 00:07:   add io  0x70-0x71 flags 0x1
pnp 00:07:   add irq 8 flags 0x1
pnp 00:07: Plug and Play ACPI device, IDs PNP0b00 (active)
pnp 00:08: parse allocated resources
pnp 00:08:   add io  0x60-0x60 flags 0x1
pnp 00:08:   add io  0x64-0x64 flags 0x1
pnp 00:08:   add irq 1 flags 0x1
pnp 00:08: Plug and Play ACPI device, IDs PNP0303 (active)
pnp 00:09: parse allocated resources
pnp 00:09:   add irq 12 flags 0x1
pnp 00:09: Plug and Play ACPI device, IDs IBM0057 PNP0f13 (active)
pnp 00:0a: parse allocated resources
pnp 00:0a:   add io  0x2f8-0x2ff flags 0x1
pnp 00:0a:   add irq 3 flags 0x1
pnp 00:0a:   add dma 3 flags 0x0
pnp 00:0a: parse resource options
pnp 00:0a:   dependent set 0 (preferred) io  min 0x2f8 max 0x2f8 align =
1 size 8 flags 0x1
pnp 00:0a:   dependent set 0 (preferred) irq 3 flags 0x1
pnp 00:0a:   dependent set 0 (preferred) dma 0 1 3 (bitmask 0xb) flags =
0x0
pnp 00:0a:   dependent set 1 (acceptable) io  min 0x3f8 max 0x3f8 align=
 1 size 8 flags 0x1
pnp 00:0a:   dependent set 1 (acceptable) irq 4 flags 0x1
pnp 00:0a:   dependent set 1 (acceptable) dma 0 1 3 (bitmask 0xb) flags=
 0x0
pnp 00:0a:   dependent set 2 (acceptable) io  min 0x2e8 max 0x2e8 align=
 1 size 8 flags 0x1
pnp 00:0a:   dependent set 2 (acceptable) irq 3 flags 0x1
pnp 00:0a:   dependent set 2 (acceptable) dma 0 1 3 (bitmask 0xb) flags=
 0x0
pnp 00:0a:   dependent set 3 (acceptable) io  min 0x3e8 max 0x3e8 align=
 1 size 8 flags 0x1
pnp 00:0a:   dependent set 3 (acceptable) irq 4 flags 0x1
pnp 00:0a:   dependent set 3 (acceptable) dma 0 1 3 (bitmask 0xb) flags=
 0x0
pnp 00:0a:   dependent set 4 (functional) io  min 0x2f8 max 0x2f8 align=
 1 size 8 flags 0x1
pnp 00:0a:   dependent set 4 (functional) irq 4 5 7 flags 0x1
pnp 00:0a:   dependent set 4 (functional) dma 0 1 3 (bitmask 0xb) flags=
 0x0
pnp 00:0a:   dependent set 5 (functional) io  min 0x3f8 max 0x3f8 align=
 1 size 8 flags 0x1
pnp 00:0a:   dependent set 5 (functional) irq 3 5 7 flags 0x1
pnp 00:0a:   dependent set 5 (functional) dma 0 1 3 (bitmask 0xb) flags=
 0x0
pnp 00:0a:   dependent set 6 (functional) io  min 0x2e8 max 0x2e8 align=
 1 size 8 flags 0x1
pnp 00:0a:   dependent set 6 (functional) irq 4 5 7 flags 0x1
pnp 00:0a:   dependent set 6 (functional) dma 0 1 3 (bitmask 0xb) flags=
 0x0
pnp 00:0a:   dependent set 7 (functional) io  min 0x3e8 max 0x3e8 align=
 1 size 8 flags 0x1
pnp 00:0a:   dependent set 7 (functional) irq 3 5 7 flags 0x1
pnp 00:0a:   dependent set 7 (functional) dma 0 1 3 (bitmask 0xb) flags=
 0x0
pnp 00:0a: Plug and Play ACPI device, IDs IBM0071 PNP0511 (active)
pnp: PnP ACPI: found 11 devices
ACPI: ACPI bus type pnp unregistered
initcall pnpacpi_init+0x0/0x7b returned 0 after 26 msecs
calling  misc_init+0x0/0x7f
initcall misc_init+0x0/0x7f returned 0 after 0 msecs
calling  cn_init+0x0/0xcb
initcall cn_init+0x0/0xcb returned 0 after 0 msecs
calling  tifm_init+0x0/0x6d
initcall tifm_init+0x0/0x6d returned 0 after 0 msecs
calling  phy_init+0x0/0x29
initcall phy_init+0x0/0x29 returned 0 after 0 msecs
calling  init_scsi+0x0/0x79
SCSI subsystem initialized
initcall init_scsi+0x0/0x79 returned 0 after 0 msecs
calling  ata_init+0x0/0x2a4
libata version 3.00 loaded.
initcall ata_init+0x0/0x2a4 returned 0 after 0 msecs
calling  spi_init+0x0/0x68
initcall spi_init+0x0/0x68 returned 0 after 0 msecs
calling  usb_init+0x0/0xfd
usbcore: registered new interface driver usbfs
usbcore: registered new interface driver hub
usbcore: registered new device driver usb
initcall usb_init+0x0/0xfd returned 0 after 1 msecs
calling  serio_init+0x0/0x82
initcall serio_init+0x0/0x82 returned 0 after 0 msecs
calling  gameport_init+0x0/0x82
initcall gameport_init+0x0/0x82 returned 0 after 0 msecs
calling  input_init+0x0/0xd7
initcall input_init+0x0/0xd7 returned 0 after 0 msecs
calling  i2c_init+0x0/0x4f
i2c-core: driver [dummy] registered
initcall i2c_init+0x0/0x4f returned 0 after 0 msecs
calling  power_supply_class_init+0x0/0x29
initcall power_supply_class_init+0x0/0x29 returned 0 after 0 msecs
calling  thermal_init+0x0/0x41
initcall thermal_init+0x0/0x41 returned 0 after 0 msecs
calling  mmc_init+0x0/0x6b
initcall mmc_init+0x0/0x6b returned 0 after 0 msecs
calling  leds_init+0x0/0x27
initcall leds_init+0x0/0x27 returned 0 after 0 msecs
calling  dma_bus_init+0x0/0x23
initcall dma_bus_init+0x0/0x23 returned 0 after 0 msecs
calling  pci_subsys_init+0x0/0xe6
PCI: Using ACPI for IRQ routing
number of MP IRQ sources: 15.
number of IO-APIC #1 registers: 24.
testing the IO APIC.......................
IO APIC #1......
=2E... register #00: 02000000
=2E......    : physical APIC id: 02
=2E......    : Delivery Type: 0
=2E......    : LTS          : 0
=2E... register #01: 00170020
=2E......     : max redirection entries: 0017
=2E......     : PRQ implemented: 0
=2E......     : IO APIC version: 0020
=2E... IRQ redirection table:
 NR Log Phy Mask Trig IRR Pol Stat Dest Deli Vect:  =20
 00 000 00  1    0    0   0   0    0    0    00
 01 003 03  1    0    0   0   0    1    1    39
 02 003 03  0    0    0   0   0    1    1    31
 03 003 03  1    0    0   0   0    1    1    41
 04 003 03  0    0    0   0   0    1    1    49
 05 003 03  0    0    0   0   0    1    1    51
 06 003 03  0    0    0   0   0    1    1    59
 07 003 03  0    0    0   0   0    1    1    61
 08 003 03  1    0    0   0   0    1    1    69
 09 003 03  0    1    0   0   0    1    1    71
 0a 003 03  0    0    0   0   0    1    1    79
 0b 003 03  0    0    0   0   0    1    1    81
 0c 003 03  1    0    0   0   0    1    1    89
 0d 003 03  1    0    0   0   0    1    1    91
 0e 003 03  0    0    0   0   0    1    1    99
 0f 003 03  0    0    0   0   0    1    1    A1
 10 000 00  1    0    0   0   0    0    0    00
 11 000 00  1    0    0   0   0    0    0    00
 12 000 00  1    0    0   0   0    0    0    00
 13 000 00  1    0    0   0   0    0    0    00
 14 000 00  1    0    0   0   0    0    0    00
 15 000 00  1    0    0   0   0    0    0    00
 16 000 00  1    0    0   0   0    0    0    00
 17 000 00  1    0    0   0   0    0    0    00
IRQ to pin mappings:
IRQ0 -> 0:2
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
initcall pci_subsys_init+0x0/0xe6 returned 0 after 6 msecs
calling  proto_init+0x0/0x27
initcall proto_init+0x0/0x27 returned 0 after 0 msecs
calling  net_dev_init+0x0/0x12f
initcall net_dev_init+0x0/0x12f returned 0 after 0 msecs
calling  neigh_init+0x0/0x66
initcall neigh_init+0x0/0x66 returned 0 after 0 msecs
calling  fib_rules_init+0x0/0x99
initcall fib_rules_init+0x0/0x99 returned 0 after 0 msecs
calling  genl_init+0x0/0xb0
initcall genl_init+0x0/0xb0 returned 0 after 0 msecs
calling  cipso_v4_init+0x0/0x6d
initcall cipso_v4_init+0x0/0x6d returned 0 after 0 msecs
calling  bt_init+0x0/0x50
Bluetooth: Core ver 2.12
NET: Registered protocol family 31
Bluetooth: HCI device and connection manager initialized
Bluetooth: HCI socket layer initialized
initcall bt_init+0x0/0x50 returned 0 after 0 msecs
calling  atm_init+0x0/0x9c
NET: Registered protocol family 8
NET: Registered protocol family 20
initcall atm_init+0x0/0x9c returned 0 after 0 msecs
calling  wireless_nlevent_init+0x0/0x39
initcall wireless_nlevent_init+0x0/0x39 returned 0 after 0 msecs
calling  netlbl_init+0x0/0x6d
NetLabel: Initializing
NetLabel:  domain hash size =3D 128
NetLabel:  protocols =3D UNLABELED CIPSOv4
NetLabel:  unlabeled traffic allowed by default
initcall netlbl_init+0x0/0x6d returned 0 after 0 msecs
calling  rfkill_init+0x0/0x5a
initcall rfkill_init+0x0/0x5a returned 0 after 0 msecs
calling  sysctl_init+0x0/0x2d
initcall sysctl_init+0x0/0x2d returned 0 after 0 msecs
calling  pci_iommu_init+0x0/0xc
initcall pci_iommu_init+0x0/0xc returned 0 after 0 msecs
calling  hpet_late_init+0x0/0xfb
initcall hpet_late_init+0x0/0xfb returned -19 after 0 msecs
calling  clocksource_done_booting+0x0/0x11
initcall clocksource_done_booting+0x0/0x11 returned 0 after 0 msecs
calling  init_pipe_fs+0x0/0x41
initcall init_pipe_fs+0x0/0x41 returned 0 after 0 msecs
calling  init_mnt_writers+0x0/0x61
initcall init_mnt_writers+0x0/0x61 returned 0 after 0 msecs
calling  eventpoll_init+0x0/0x7d
initcall eventpoll_init+0x0/0x7d returned 0 after 0 msecs
calling  anon_inode_init+0x0/0xdf
initcall anon_inode_init+0x0/0xdf returned 0 after 0 msecs
calling  acpi_rtc_init+0x0/0xd4
ACPI: RTC can wake from S4
initcall acpi_rtc_init+0x0/0xd4 returned 0 after 0 msecs
calling  acpi_event_init+0x0/0x46
initcall acpi_event_init+0x0/0x46 returned 0 after 0 msecs
calling  pnp_system_init+0x0/0xf
pnp: the driver 'system' has been registered
system 00:00: iomem range 0x0-0x9ffff could not be reserved
system 00:00: iomem range 0xc0000-0xc3fff could not be reserved
system 00:00: iomem range 0xc4000-0xc7fff could not be reserved
system 00:00: iomem range 0xc8000-0xcbfff has been reserved
system 00:00: iomem range 0xcc000-0xcffff could not be reserved
system 00:00: iomem range 0xd0000-0xd3fff could not be reserved
system 00:00: iomem range 0xdc000-0xdffff could not be reserved
system 00:00: iomem range 0xe0000-0xe3fff could not be reserved
system 00:00: iomem range 0xe4000-0xe7fff could not be reserved
system 00:00: iomem range 0xe8000-0xebfff could not be reserved
system 00:00: iomem range 0xec000-0xeffff could not be reserved
system 00:00: iomem range 0xf0000-0xfffff could not be reserved
system 00:00: iomem range 0x100000-0x7fffffff could not be reserved
system 00:00: iomem range 0xfec00000-0xffffffff could not be reserved
system 00:00: driver attached
system 00:02: ioport range 0x164e-0x164f has been reserved
system 00:02: ioport range 0x1000-0x107f has been reserved
system 00:02: ioport range 0x1180-0x11bf has been reserved
system 00:02: ioport range 0x800-0x80f has been reserved
system 00:02: ioport range 0x15e0-0x15ef has been reserved
system 00:02: ioport range 0x1600-0x165f could not be reserved
system 00:02: iomem range 0xf0000000-0xf3ffffff could not be reserved
system 00:02: iomem range 0xfed1c000-0xfed1ffff could not be reserved
system 00:02: iomem range 0xfed14000-0xfed17fff could not be reserved
system 00:02: iomem range 0xfed18000-0xfed18fff could not be reserved
system 00:02: iomem range 0xfed19000-0xfed19fff could not be reserved
system 00:02: driver attached
initcall pnp_system_init+0x0/0xf returned 0 after 1 msecs
calling  chr_dev_init+0x0/0x86
initcall chr_dev_init+0x0/0x86 returned 0 after 1 msecs
calling  firmware_class_init+0x0/0x5c
initcall firmware_class_init+0x0/0x5c returned 0 after 0 msecs
calling  loopback_init+0x0/0xf
initcall loopback_init+0x0/0xf returned 0 after 0 msecs
calling  cpufreq_gov_performance_init+0x0/0xf
initcall cpufreq_gov_performance_init+0x0/0xf returned 0 after 0 msecs
calling  cpufreq_gov_dbs_init+0x0/0xf
initcall cpufreq_gov_dbs_init+0x0/0xf returned 0 after 0 msecs
calling  init_acpi_pm_clocksource+0x0/0x152
PM-Timer running at invalid rate: 87% of normal - aborting.
initcall init_acpi_pm_clocksource+0x0/0x152 returned -19 after 28 msecs
calling  ssb_modinit+0x0/0x41
initcall ssb_modinit+0x0/0x41 returned 0 after 0 msecs
calling  pcibios_assign_resources+0x0/0x91
pci 0000:00:1c.0: PCI bridge, secondary bus 0000:02
pci 0000:00:1c.0:   IO window: 0x2000-0x2fff
pci 0000:00:1c.0:   MEM window: 0xee000000-0xee0fffff
pci 0000:00:1c.0:   PREFETCH window: disabled
pci 0000:00:1c.1: PCI bridge, secondary bus 0000:03
pci 0000:00:1c.1:   IO window: 0x3000-0x4fff
pci 0000:00:1c.1:   MEM window: 0xec000000-0xedffffff
pci 0000:00:1c.1:   PREFETCH window: 0x000000e4000000-0x000000e40fffff
pci 0000:00:1c.2: PCI bridge, secondary bus 0000:04
pci 0000:00:1c.2:   IO window: 0x5000-0x6fff
pci 0000:00:1c.2:   MEM window: 0xe8000000-0xe9ffffff
pci 0000:00:1c.2:   PREFETCH window: 0x000000e4100000-0x000000e41fffff
pci 0000:00:1c.3: PCI bridge, secondary bus 0000:0c
pci 0000:00:1c.3:   IO window: 0x7000-0x8fff
pci 0000:00:1c.3:   MEM window: 0xea000000-0xebffffff
pci 0000:00:1c.3:   PREFETCH window: 0x000000e4200000-0x000000e42fffff
pci 0000:15:00.0: CardBus bridge, secondary bus 0000:16
pci 0000:15:00.0:   IO window: 0x009000-0x0090ff
pci 0000:15:00.0:   IO window: 0x009400-0x0094ff
pci 0000:15:00.0:   PREFETCH window: 0xe0000000-0xe3ffffff
pci 0000:15:00.0:   MEM window: 0x88000000-0x8bffffff
pci 0000:00:1e.0: PCI bridge, secondary bus 0000:15
pci 0000:00:1e.0:   IO window: 0x9000-0xcfff
pci 0000:00:1e.0:   MEM window: 0xe4300000-0xe7ffffff
pci 0000:00:1e.0:   PREFETCH window: 0x000000e0000000-0x000000e3ffffff
pci 0000:00:1c.0: PCI INT A -> GSI 20 (level, low) -> IRQ 20
PCI: Setting latency timer of device 0000:00:1c.0 to 64
pci 0000:00:1c.1: PCI INT B -> GSI 21 (level, low) -> IRQ 21
PCI: Setting latency timer of device 0000:00:1c.1 to 64
pci 0000:00:1c.2: PCI INT C -> GSI 22 (level, low) -> IRQ 22
PCI: Setting latency timer of device 0000:00:1c.2 to 64
pci 0000:00:1c.3: PCI INT D -> GSI 23 (level, low) -> IRQ 23
PCI: Setting latency timer of device 0000:00:1c.3 to 64
pci 0000:00:1e.0: enabling device (0005 -> 0007)
PCI: Setting latency timer of device 0000:00:1e.0 to 64
vendor=3D8086 device=3D2448
pci 0000:15:00.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
bus: 00 index 0 io port: [0, ffff]
bus: 00 index 1 mmio: [0, ffffffffffffffff]
bus: 02 index 0 io port: [2000, 2fff]
bus: 02 index 1 mmio: [ee000000, ee0fffff]
bus: 02 index 2 mmio: [0, 0]
bus: 02 index 3 mmio: [0, 0]
bus: 03 index 0 io port: [3000, 4fff]
bus: 03 index 1 mmio: [ec000000, edffffff]
bus: 03 index 2 mmio: [e4000000, e40fffff]
bus: 03 index 3 mmio: [0, 0]
bus: 04 index 0 io port: [5000, 6fff]
bus: 04 index 1 mmio: [e8000000, e9ffffff]
bus: 04 index 2 mmio: [e4100000, e41fffff]
bus: 04 index 3 mmio: [0, 0]
bus: 0c index 0 io port: [7000, 8fff]
bus: 0c index 1 mmio: [ea000000, ebffffff]
bus: 0c index 2 mmio: [e4200000, e42fffff]
bus: 0c index 3 mmio: [0, 0]
bus: 15 index 0 io port: [9000, cfff]
bus: 15 index 1 mmio: [e4300000, e7ffffff]
bus: 15 index 2 mmio: [e0000000, e3ffffff]
bus: 15 index 3 io port: [0, ffff]
bus: 15 index 4 mmio: [0, ffffffffffffffff]
bus: 16 index 0 io port: [9000, 90ff]
bus: 16 index 1 io port: [9400, 94ff]
bus: 16 index 2 mmio: [e0000000, e3ffffff]
bus: 16 index 3 mmio: [88000000, 8bffffff]
initcall pcibios_assign_resources+0x0/0x91 returned 0 after 4 msecs
calling  inet_init+0x0/0x1be
NET: Registered protocol family 2
IP route cache hash table entries: 32768 (order: 5, 131072 bytes)
TCP established hash table entries: 131072 (order: 8, 1048576 bytes)
TCP bind hash table entries: 65536 (order: 9, 2359296 bytes)
TCP: Hash tables configured (established 131072 bind 65536)
TCP reno registered
initcall inet_init+0x0/0x1be returned 0 after 11 msecs
calling  af_unix_init+0x0/0x47
NET: Registered protocol family 1
initcall af_unix_init+0x0/0x47 returned 0 after 0 msecs
calling  populate_rootfs+0x0/0x102
initcall populate_rootfs+0x0/0x102 returned 0 after 1 msecs
calling  pci_init+0x0/0x2c
pci 0000:00:02.0: Boot video device
pci 0000:00:1d.0: uhci_check_and_reset_hc: legsup =3D 0x2000
pci 0000:00:1d.0: Performing full reset
pci 0000:00:1d.1: uhci_check_and_reset_hc: legsup =3D 0x2000
pci 0000:00:1d.1: Performing full reset
pci 0000:00:1d.2: uhci_check_and_reset_hc: legsup =3D 0x2000
pci 0000:00:1d.2: Performing full reset
pci 0000:00:1d.3: uhci_check_and_reset_hc: legsup =3D 0x2000
pci 0000:00:1d.3: Performing full reset
initcall pci_init+0x0/0x2c returned 0 after 0 msecs
calling  ehci_hcd_init+0x0/0x70
ehci_hcd: block sizes: qh 128 qtd 96 itd 160 sitd 96
ehci_hcd 0000:00:1d.7: power state changed by ACPI to D0
ehci_hcd 0000:00:1d.7: PCI INT D -> GSI 19 (level, low) -> IRQ 19
PCI: Setting latency timer of device 0000:00:1d.7 to 64
ehci_hcd 0000:00:1d.7: EHCI Host Controller
ehci_hcd 0000:00:1d.7: new USB bus registered, assigned bus number 1
ehci_hcd 0000:00:1d.7: reset hcs_params 0x104208 dbg=3D1 cc=3D4 pcc=3D2=
 ordered !ppc ports=3D8
ehci_hcd 0000:00:1d.7: reset hcc_params 6871 thresh 7 uframes 1024 64 b=
it addr
ehci_hcd 0000:00:1d.7: reset command 080022 (park)=3D0 ithresh=3D8 Asyn=
c period=3D1024 Reset HALT
ehci_hcd 0000:00:1d.7: debug port 1
ehci_hcd 0000:00:1d.7: cache line size of 32 is not supported
ehci_hcd 0000:00:1d.7: supports USB remote wakeup
ehci_hcd 0000:00:1d.7: irq 19, io mem 0xee444000
ehci_hcd 0000:00:1d.7: reset command 080002 (park)=3D0 ithresh=3D8 peri=
od=3D1024 Reset HALT
ehci_hcd 0000:00:1d.7: init command 010001 (park)=3D0 ithresh=3D1 perio=
d=3D1024 RUN
ehci_hcd 0000:00:1d.7: USB 2.0 started, EHCI 1.00, driver 10 Dec 2004
usb usb1: default language 0x0409
usb usb1: uevent
usb usb1: usb_probe_device
usb usb1: configuration #1 chosen from 1 choice
usb usb1: adding 1-0:1.0 (config #1, interface 0)
usb 1-0:1.0: uevent
hub 1-0:1.0: usb_probe_interface
hub 1-0:1.0: usb_probe_interface - got id
hub 1-0:1.0: USB hub found
hub 1-0:1.0: 8 ports detected
hub 1-0:1.0: standalone hub
hub 1-0:1.0: no power switching (usb 1.0)
hub 1-0:1.0: individual port over-current protection
hub 1-0:1.0: power on to power good time: 20ms
hub 1-0:1.0: local power source is good
hub 1-0:1.0: trying to enable port power on non-switchable hub
hub 1-0:1.0: state 7 ports 8 chg 0000 evt 0000
ehci_hcd 0000:00:1d.7: GetStatus port 8 status 001803 POWER sig=3Dj CSC=
 CONNECT
hub 1-0:1.0: port 8, status 0501, change 0001, 480 Mb/s
usb usb1: New USB device found, idVendor=3D1d6b, idProduct=3D0002
usb usb1: New USB device strings: Mfr=3D3, Product=3D2, SerialNumber=3D=
1
usb usb1: Product: EHCI Host Controller
usb usb1: Manufacturer: Linux 2.6.26-tip ehci_hcd
usb usb1: SerialNumber: 0000:00:1d.7
initcall ehci_hcd_init+0x0/0x70 returned 0 after 116 msecs
calling  ohci_hcd_mod_init+0x0/0xb0
ohci_hcd: 2006 August 04 USB 1.1 'Open' Host Controller (OHCI) Driver
ohci_hcd: block sizes: ed 64 td 64
initcall ohci_hcd_mod_init+0x0/0xb0 returned 0 after 0 msecs
calling  uhci_hcd_init+0x0/0xc7
USB Universal Host Controller Interface driver v3.0
uhci_hcd 0000:00:1d.0: power state changed by ACPI to D0
Pin 1-16 already programmed
uhci_hcd 0000:00:1d.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
PCI: Setting latency timer of device 0000:00:1d.0 to 64
uhci_hcd 0000:00:1d.0: UHCI Host Controller
uhci_hcd 0000:00:1d.0: new USB bus registered, assigned bus number 2
uhci_hcd 0000:00:1d.0: detected 2 ports
uhci_hcd 0000:00:1d.0: uhci_check_and_reset_hc: cmd =3D 0x0000
uhci_hcd 0000:00:1d.0: Performing full reset
uhci_hcd 0000:00:1d.0: supports USB remote wakeup
uhci_hcd 0000:00:1d.0: irq 16, io base 0x00001820
usb usb2: default language 0x0409
usb usb2: uevent
usb usb2: usb_probe_device
usb usb2: configuration #1 chosen from 1 choice
usb usb2: adding 2-0:1.0 (config #1, interface 0)
usb 2-0:1.0: uevent
hub 2-0:1.0: usb_probe_interface
hub 2-0:1.0: usb_probe_interface - got id
hub 2-0:1.0: USB hub found
hub 2-0:1.0: 2 ports detected
hub 2-0:1.0: standalone hub
hub 2-0:1.0: no power switching (usb 1.0)
hub 2-0:1.0: individual port over-current protection
hub 2-0:1.0: power on to power good time: 2ms
hub 2-0:1.0: local power source is good
hub 2-0:1.0: trying to enable port power on non-switchable hub
hub 1-0:1.0: debounce: port 8: total 100ms stable 100ms status 0x501
usb usb2: New USB device found, idVendor=3D1d6b, idProduct=3D0001
usb usb2: New USB device strings: Mfr=3D3, Product=3D2, SerialNumber=3D=
1
usb usb2: Product: UHCI Host Controller
usb usb2: Manufacturer: Linux 2.6.26-tip uhci_hcd
usb usb2: SerialNumber: 0000:00:1d.0
uhci_hcd 0000:00:1d.1: PCI INT B -> GSI 17 (level, low) -> IRQ 17
PCI: Setting latency timer of device 0000:00:1d.1 to 64
uhci_hcd 0000:00:1d.1: UHCI Host Controller
uhci_hcd 0000:00:1d.1: new USB bus registered, assigned bus number 3
uhci_hcd 0000:00:1d.1: detected 2 ports
uhci_hcd 0000:00:1d.1: uhci_check_and_reset_hc: cmd =3D 0x0000
uhci_hcd 0000:00:1d.1: Performing full reset
uhci_hcd 0000:00:1d.1: supports USB remote wakeup
uhci_hcd 0000:00:1d.1: irq 17, io base 0x00001840
usb usb3: default language 0x0409
usb usb3: uevent
usb usb3: usb_probe_device
usb usb3: configuration #1 chosen from 1 choice
usb usb3: adding 3-0:1.0 (config #1, interface 0)
usb 3-0:1.0: uevent
hub 3-0:1.0: usb_probe_interface
hub 3-0:1.0: usb_probe_interface - got id
hub 3-0:1.0: USB hub found
hub 3-0:1.0: 2 ports detected
hub 3-0:1.0: standalone hub
hub 3-0:1.0: no power switching (usb 1.0)
hub 3-0:1.0: individual port over-current protection
hub 3-0:1.0: power on to power good time: 2ms
hub 3-0:1.0: local power source is good
hub 3-0:1.0: trying to enable port power on non-switchable hub
ehci_hcd 0000:00:1d.7: port 8 full speed --> companion
ehci_hcd 0000:00:1d.7: GetStatus port 8 status 003801 POWER OWNER sig=3D=
j CONNECT
hub 1-0:1.0: port 8 not reset yet, waiting 50ms
ehci_hcd 0000:00:1d.7: GetStatus port 8 status 003002 POWER OWNER sig=3D=
se0 CSC
hub 2-0:1.0: state 7 ports 2 chg 0000 evt 0000
hub 1-0:1.0: state 7 ports 8 chg 0000 evt 0100
hub 3-0:1.0: state 7 ports 2 chg 0000 evt 0000
usb usb3: New USB device found, idVendor=3D1d6b, idProduct=3D0001
usb usb3: New USB device strings: Mfr=3D3, Product=3D2, SerialNumber=3D=
1
usb usb3: Product: UHCI Host Controller
usb usb3: Manufacturer: Linux 2.6.26-tip uhci_hcd
usb usb3: SerialNumber: 0000:00:1d.1
uhci_hcd 0000:00:1d.2: power state changed by ACPI to D0
uhci_hcd 0000:00:1d.2: PCI INT C -> GSI 18 (level, low) -> IRQ 18
PCI: Setting latency timer of device 0000:00:1d.2 to 64
uhci_hcd 0000:00:1d.2: UHCI Host Controller
uhci_hcd 0000:00:1d.2: new USB bus registered, assigned bus number 4
uhci_hcd 0000:00:1d.2: detected 2 ports
uhci_hcd 0000:00:1d.2: uhci_check_and_reset_hc: cmd =3D 0x0000
uhci_hcd 0000:00:1d.2: Performing full reset
uhci_hcd 0000:00:1d.2: supports USB remote wakeup
uhci_hcd 0000:00:1d.2: irq 18, io base 0x00001860
usb usb4: default language 0x0409
usb usb4: uevent
usb usb4: usb_probe_device
usb usb4: configuration #1 chosen from 1 choice
usb usb4: adding 4-0:1.0 (config #1, interface 0)
usb 4-0:1.0: uevent
hub 4-0:1.0: usb_probe_interface
hub 4-0:1.0: usb_probe_interface - got id
hub 4-0:1.0: USB hub found
hub 4-0:1.0: 2 ports detected
hub 4-0:1.0: standalone hub
hub 4-0:1.0: no power switching (usb 1.0)
hub 4-0:1.0: individual port over-current protection
hub 4-0:1.0: power on to power good time: 2ms
hub 4-0:1.0: local power source is good
hub 4-0:1.0: trying to enable port power on non-switchable hub
hub 4-0:1.0: state 7 ports 2 chg 0000 evt 0000
usb usb4: New USB device found, idVendor=3D1d6b, idProduct=3D0001
usb usb4: New USB device strings: Mfr=3D3, Product=3D2, SerialNumber=3D=
1
usb usb4: Product: UHCI Host Controller
usb usb4: Manufacturer: Linux 2.6.26-tip uhci_hcd
usb usb4: SerialNumber: 0000:00:1d.2
Pin 1-19 already programmed
uhci_hcd 0000:00:1d.3: PCI INT D -> GSI 19 (level, low) -> IRQ 19
PCI: Setting latency timer of device 0000:00:1d.3 to 64
uhci_hcd 0000:00:1d.3: UHCI Host Controller
uhci_hcd 0000:00:1d.3: new USB bus registered, assigned bus number 5
uhci_hcd 0000:00:1d.3: detected 2 ports
uhci_hcd 0000:00:1d.3: uhci_check_and_reset_hc: cmd =3D 0x0000
uhci_hcd 0000:00:1d.3: Performing full reset
uhci_hcd 0000:00:1d.3: irq 19, io base 0x00001880
usb usb5: default language 0x0409
usb usb5: uevent
usb usb5: usb_probe_device
usb usb5: configuration #1 chosen from 1 choice
usb usb5: adding 5-0:1.0 (config #1, interface 0)
usb 5-0:1.0: uevent
hub 5-0:1.0: usb_probe_interface
hub 5-0:1.0: usb_probe_interface - got id
hub 5-0:1.0: USB hub found
hub 5-0:1.0: 2 ports detected
hub 5-0:1.0: standalone hub
hub 5-0:1.0: no power switching (usb 1.0)
hub 5-0:1.0: individual port over-current protection
hub 5-0:1.0: power on to power good time: 2ms
hub 5-0:1.0: local power source is good
hub 5-0:1.0: trying to enable port power on non-switchable hub
hub 5-0:1.0: state 7 ports 2 chg 0000 evt 0000
uhci_hcd 0000:00:1d.3: port 2 portsc 009b,00
hub 5-0:1.0: port 2, status 0101, change 0003, 12 Mb/s
usb usb5: New USB device found, idVendor=3D1d6b, idProduct=3D0001
usb usb5: New USB device strings: Mfr=3D3, Product=3D2, SerialNumber=3D=
1
usb usb5: Product: UHCI Host Controller
usb usb5: Manufacturer: Linux 2.6.26-tip uhci_hcd
usb usb5: SerialNumber: 0000:00:1d.3
initcall uhci_hcd_init+0x0/0xc7 returned 0 after 402 msecs
calling  i8259A_init_sysfs+0x0/0x1d
initcall i8259A_init_sysfs+0x0/0x1d returned 0 after 0 msecs
calling  sbf_init+0x0/0xbd
Simple Boot Flag at 0x35 set to 0x1
initcall sbf_init+0x0/0xbd returned 0 after 0 msecs
calling  i8237A_init_sysfs+0x0/0x1d
initcall i8237A_init_sysfs+0x0/0x1d returned 0 after 0 msecs
calling  add_rtc_cmos+0x0/0x1a
initcall add_rtc_cmos+0x0/0x1a returned 0 after 0 msecs
calling  cache_sysfs_init+0x0/0x47
initcall cache_sysfs_init+0x0/0x47 returned 0 after 0 msecs
calling  eps_init+0x0/0x3e
initcall eps_init+0x0/0x3e returned -19 after 0 msecs
calling  nforce2_init+0x0/0x5e
cpufreq: No nForce2 chipset.
initcall nforce2_init+0x0/0x5e returned -19 after 0 msecs
calling  microcode_init+0x0/0xa2
IA-32 Microcode Update Driver: v1.14a <tigran@aivazian.fsnet.co.uk>
initcall microcode_init+0x0/0xa2 returned 0 after 0 msecs
calling  init_lapic_sysfs+0x0/0x38
initcall init_lapic_sysfs+0x0/0x38 returned 0 after 0 msecs
calling  ioapic_init_sysfs+0x0/0x84
initcall ioapic_init_sysfs+0x0/0x84 returned 0 after 0 msecs
calling  add_pcspkr+0x0/0x35
initcall add_pcspkr+0x0/0x35 returned 0 after 0 msecs
calling  start_pageattr_test+0x0/0x38
initcall start_pageattr_test+0x0/0x38 returned 0 after 0 msecs
calling  debug_pagealloc_proc_init+0x0/0x27
initcall debug_pagealloc_proc_init+0x0/0x27 returned 0 after 0 msecs
calling  aes_init+0x0/0xf
initcall aes_init+0x0/0xf returned 0 after 0 msecs
calling  init+0x0/0xf
initcall init+0x0/0xf returned 0 after 0 msecs
calling  init+0x0/0xf
initcall init+0x0/0xf returned 0 after 0 msecs
calling  create_proc_profile+0x0/0x19f
initcall create_proc_profile+0x0/0x19f returned 0 after 0 msecs
calling  ioresources_init+0x0/0x2d
initcall ioresources_init+0x0/0x2d returned 0 after 0 msecs
calling  uid_cache_init+0x0/0x5e
initcall uid_cache_init+0x0/0x5e returned 0 after 0 msecs
calling  init_posix_timers+0x0/0x7c
initcall init_posix_timers+0x0/0x7c returned 0 after 0 msecs
calling  init_posix_cpu_timers+0x0/0x90
initcall init_posix_cpu_timers+0x0/0x90 returned 0 after 0 msecs
calling  nsproxy_cache_init+0x0/0x27
initcall nsproxy_cache_init+0x0/0x27 returned 0 after 0 msecs
calling  timekeeping_init_device+0x0/0x1d
initcall timekeeping_init_device+0x0/0x1d returned 0 after 0 msecs
calling  init_clocksource_sysfs+0x0/0x43
initcall init_clocksource_sysfs+0x0/0x43 returned 0 after 0 msecs
calling  init_timer_list_procfs+0x0/0x27
initcall init_timer_list_procfs+0x0/0x27 returned 0 after 0 msecs
calling  lockdep_proc_init+0x0/0x5f
initcall lockdep_proc_init+0x0/0x5f returned 0 after 0 msecs
calling  futex_init+0x0/0x6f
initcall futex_init+0x0/0x6f returned 0 after 0 msecs
calling  init_rttest+0x0/0x102
Initializing RT-Tester: OK
initcall init_rttest+0x0/0x102 returned 0 after 1 msecs
calling  proc_dma_init+0x0/0x1c
initcall proc_dma_init+0x0/0x1c returned 0 after 0 msecs
calling  percpu_modinit+0x0/0x64
initcall percpu_modinit+0x0/0x64 returned 0 after 0 msecs
calling  kallsyms_init+0x0/0x1f
initcall kallsyms_init+0x0/0x1f returned 0 after 0 msecs
calling  crash_save_vmcoreinfo_init+0x0/0x316
initcall crash_save_vmcoreinfo_init+0x0/0x316 returned 0 after 0 msecs
calling  crash_notes_memory_init+0x0/0x36
initcall crash_notes_memory_init+0x0/0x36 returned 0 after 0 msecs
calling  pid_namespaces_init+0x0/0x27
initcall pid_namespaces_init+0x0/0x27 returned 0 after 0 msecs
calling  audit_init+0x0/0xc4
audit: initializing netlink socket (disabled)
type=3D2000 audit(1216632057.064:1): initialized
initcall audit_init+0x0/0xc4 returned 0 after 0 msecs
calling  init_kprobes+0x0/0xfc
Kprobe smoke test started
Kprobe smoke test passed successfully
initcall init_kprobes+0x0/0xfc returned 0 after 14 msecs
calling  relay_init+0x0/0x11
initcall relay_init+0x0/0x11 returned 0 after 0 msecs
calling  utsname_sysctl_init+0x0/0x11
initcall utsname_sysctl_init+0x0/0x11 returned 0 after 0 msecs
calling  init_per_zone_pages_min+0x0/0x48
initcall init_per_zone_pages_min+0x0/0x48 returned 0 after 0 msecs
calling  pdflush_init+0x0/0x16
initcall pdflush_init+0x0/0x16 returned 0 after 0 msecs
calling  kswapd_init+0x0/0x1d
initcall kswapd_init+0x0/0x1d returned 0 after 0 msecs
calling  setup_vmstat+0x0/0x37
initcall setup_vmstat+0x0/0x37 returned 0 after 0 msecs
calling  init_tmpfs+0x0/0xb9
initcall init_tmpfs+0x0/0xb9 returned 0 after 0 msecs
calling  slab_sysfs_init+0x0/0xb7
initcall slab_sysfs_init+0x0/0xb7 returned 0 after 30 msecs
calling  fasync_init+0x0/0x24
initcall fasync_init+0x0/0x24 returned 0 after 0 msecs
calling  aio_setup+0x0/0x64
initcall aio_setup+0x0/0x64 returned 0 after 0 msecs
calling  init_mbcache+0x0/0x11
initcall init_mbcache+0x0/0x11 returned 0 after 0 msecs
calling  dquot_init+0x0/0xdd
VFS: Disk quotas dquot_6.5.1
Dquot-cache hash table entries: 1024 (order 0, 4096 bytes)
initcall dquot_init+0x0/0xdd returned 0 after 0 msecs
calling  init_v1_quota_format+0x0/0xf
initcall init_v1_quota_format+0x0/0xf returned 0 after 0 msecs
calling  dnotify_init+0x0/0x24
initcall dnotify_init+0x0/0x24 returned 0 after 0 msecs
calling  configfs_init+0x0/0xbb
initcall configfs_init+0x0/0xbb returned 0 after 0 msecs
calling  init_devpts_fs+0x0/0x33
initcall init_devpts_fs+0x0/0x33 returned 0 after 0 msecs
calling  init_reiserfs_fs+0x0/0x72
initcall init_reiserfs_fs+0x0/0x72 returned 0 after 0 msecs
calling  init_ext3_fs+0x0/0x5f
initcall init_ext3_fs+0x0/0x5f returned 0 after 0 msecs
calling  init_ext4_fs+0x0/0x5f
initcall init_ext4_fs+0x0/0x5f returned 0 after 0 msecs
calling  journal_init+0x0/0xb6
initcall journal_init+0x0/0xb6 returned 0 after 1 msecs
calling  journal_init+0x0/0xd3
initcall journal_init+0x0/0xd3 returned 0 after 1 msecs
calling  init_ramfs_fs+0x0/0xf
initcall init_ramfs_fs+0x0/0xf returned 0 after 0 msecs
calling  init_fat_fs+0x0/0x46
initcall init_fat_fs+0x0/0x46 returned 0 after 0 msecs
calling  init_msdos_fs+0x0/0xf
initcall init_msdos_fs+0x0/0xf returned 0 after 0 msecs
calling  init_bfs_fs+0x0/0x4f
initcall init_bfs_fs+0x0/0x4f returned 0 after 0 msecs
calling  init_hfsplus_fs+0x0/0x50
initcall init_hfsplus_fs+0x0/0x50 returned 0 after 0 msecs
calling  vxfs_init+0x0/0x4d
initcall vxfs_init+0x0/0x4d returned 0 after 0 msecs
calling  init_nfs_fs+0x0/0xfc
initcall init_nfs_fs+0x0/0xfc returned 0 after 1 msecs
calling  init_nlm+0x0/0x1c
initcall init_nlm+0x0/0x1c returned 0 after 0 msecs
calling  init_nls_cp437+0x0/0xf
initcall init_nls_cp437+0x0/0xf returned 0 after 0 msecs
calling  init_nls_cp865+0x0/0xf
initcall init_nls_cp865+0x0/0xf returned 0 after 0 msecs
calling  init_nls_cp932+0x0/0xf
initcall init_nls_cp932+0x0/0xf returned 0 after 0 msecs
calling  init_nls_euc_jp+0x0/0x39
initcall init_nls_euc_jp+0x0/0x39 returned 0 after 0 msecs
calling  init_nls_cp936+0x0/0xf
initcall init_nls_cp936+0x0/0xf returned 0 after 0 msecs
calling  init_nls_cp949+0x0/0xf
initcall init_nls_cp949+0x0/0xf returned 0 after 0 msecs
calling  init_nls_cp1251+0x0/0xf
initcall init_nls_cp1251+0x0/0xf returned 0 after 0 msecs
calling  init_nls_ascii+0x0/0xf
initcall init_nls_ascii+0x0/0xf returned 0 after 0 msecs
calling  init_nls_iso8859_1+0x0/0xf
initcall init_nls_iso8859_1+0x0/0xf returned 0 after 0 msecs
calling  init_nls_iso8859_13+0x0/0xf
initcall init_nls_iso8859_13+0x0/0xf returned 0 after 0 msecs
calling  init_nls_iso8859_14+0x0/0xf
initcall init_nls_iso8859_14+0x0/0xf returned 0 after 0 msecs
calling  init_nls_koi8_u+0x0/0xf
initcall init_nls_koi8_u+0x0/0xf returned 0 after 0 msecs
calling  init_nls_koi8_ru+0x0/0x39
initcall init_nls_koi8_ru+0x0/0x39 returned 0 after 0 msecs
calling  init_nls_utf8+0x0/0x1f
initcall init_nls_utf8+0x0/0x1f returned 0 after 0 msecs
calling  init_sysv_fs+0x0/0x43
initcall init_sysv_fs+0x0/0x43 returned 0 after 0 msecs
calling  init_ncp_fs+0x0/0x4f
initcall init_ncp_fs+0x0/0x4f returned 0 after 0 msecs
calling  init_ntfs_fs+0x0/0x199
NTFS driver 2.1.29 [Flags: R/O].
initcall init_ntfs_fs+0x0/0x199 returned 0 after 0 msecs
calling  init_autofs4_fs+0x0/0xf
initcall init_autofs4_fs+0x0/0xf returned 0 after 0 msecs
calling  fuse_init+0x0/0xf8
fuse init (API version 7.9)
initcall fuse_init+0x0/0xf8 returned 0 after 0 msecs
calling  ipc_init+0x0/0x20
msgmni has been set to 1703
initcall ipc_init+0x0/0x20 returned 0 after 0 msecs
calling  ipc_sysctl_init+0x0/0x11
initcall ipc_sysctl_init+0x0/0x11 returned 0 after 0 msecs
calling  key_proc_init+0x0/0x2c
initcall key_proc_init+0x0/0x2c returned 0 after 0 msecs
calling  selinux_nf_ip_init+0x0/0x68
SELinux:  Registering netfilter hooks
initcall selinux_nf_ip_init+0x0/0x68 returned 0 after 0 msecs
calling  init_sel_fs+0x0/0x5a
initcall init_sel_fs+0x0/0x5a returned 0 after 0 msecs
calling  selnl_init+0x0/0x46
initcall selnl_init+0x0/0x46 returned 0 after 0 msecs
calling  sel_netif_init+0x0/0x57
initcall sel_netif_init+0x0/0x57 returned 0 after 0 msecs
calling  sel_netnode_init+0x0/0x68
initcall sel_netnode_init+0x0/0x68 returned 0 after 0 msecs
calling  sel_netport_init+0x0/0x68
initcall sel_netport_init+0x0/0x68 returned 0 after 0 msecs
calling  aurule_init+0x0/0x30
initcall aurule_init+0x0/0x30 returned 0 after 0 msecs
calling  crypto_algapi_init+0x0/0xc
initcall crypto_algapi_init+0x0/0xc returned 0 after 0 msecs
calling  blkcipher_module_init+0x0/0x24
initcall blkcipher_module_init+0x0/0x24 returned 0 after 0 msecs
calling  seqiv_module_init+0x0/0xf
initcall seqiv_module_init+0x0/0xf returned 0 after 0 msecs
calling  cryptomgr_init+0x0/0xf
initcall cryptomgr_init+0x0/0xf returned 0 after 0 msecs
calling  hmac_module_init+0x0/0xf
initcall hmac_module_init+0x0/0xf returned 0 after 0 msecs
calling  crypto_xcbc_module_init+0x0/0xf
initcall crypto_xcbc_module_init+0x0/0xf returned 0 after 0 msecs
calling  crypto_null_mod_init+0x0/0x67
initcall crypto_null_mod_init+0x0/0x67 returned 0 after 0 msecs
calling  md5_mod_init+0x0/0xf
initcall md5_mod_init+0x0/0xf returned 0 after 0 msecs
calling  rmd128_mod_init+0x0/0xf
initcall rmd128_mod_init+0x0/0xf returned 0 after 0 msecs
calling  sha1_generic_mod_init+0x0/0xf
initcall sha1_generic_mod_init+0x0/0xf returned 0 after 0 msecs
calling  tgr192_mod_init+0x0/0x52
initcall tgr192_mod_init+0x0/0x52 returned 0 after 0 msecs
calling  crypto_cbc_module_init+0x0/0xf
initcall crypto_cbc_module_init+0x0/0xf returned 0 after 0 msecs
calling  crypto_pcbc_module_init+0x0/0xf
initcall crypto_pcbc_module_init+0x0/0xf returned 0 after 0 msecs
calling  crypto_module_init+0x0/0xf
initcall crypto_module_init+0x0/0xf returned 0 after 0 msecs
calling  crypto_ctr_module_init+0x0/0x33
initcall crypto_ctr_module_init+0x0/0x33 returned 0 after 0 msecs
calling  des_generic_mod_init+0x0/0x33
initcall des_generic_mod_init+0x0/0x33 returned 0 after 0 msecs
calling  fcrypt_mod_init+0x0/0xf
initcall fcrypt_mod_init+0x0/0xf returned 0 after 0 msecs
calling  twofish_mod_init+0x0/0xf
initcall twofish_mod_init+0x0/0xf returned 0 after 0 msecs
calling  aes_init+0x0/0x2ac
initcall aes_init+0x0/0x2ac returned 0 after 0 msecs
calling  cast5_mod_init+0x0/0xf
initcall cast5_mod_init+0x0/0xf returned 0 after 0 msecs
calling  anubis_mod_init+0x0/0xf
initcall anubis_mod_init+0x0/0xf returned 0 after 0 msecs
calling  deflate_mod_init+0x0/0xf
initcall deflate_mod_init+0x0/0xf returned 0 after 0 msecs
calling  crypto_authenc_module_init+0x0/0xf
initcall crypto_authenc_module_init+0x0/0xf returned 0 after 0 msecs
calling  noop_init+0x0/0x11
io scheduler noop registered (default)
initcall noop_init+0x0/0x11 returned 0 after 0 msecs
calling  init_kmp+0x0/0xf
initcall init_kmp+0x0/0xf returned 0 after 0 msecs
calling  init_bm+0x0/0xf
initcall init_bm+0x0/0xf returned 0 after 0 msecs
calling  init_fsm+0x0/0xf
initcall init_fsm+0x0/0xf returned 0 after 0 msecs
calling  percpu_counter_startup+0x0/0x11
initcall percpu_counter_startup+0x0/0x11 returned 0 after 0 msecs
calling  audit_classes_init+0x0/0x4f
initcall audit_classes_init+0x0/0x4f returned 0 after 0 msecs
calling  pci_proc_init+0x0/0x5b
initcall pci_proc_init+0x0/0x5b returned 0 after 0 msecs
calling  progearbl_init+0x0/0x53
ALI M7101 PMU not found.
initcall progearbl_init+0x0/0x53 returned 0 after 0 msecs
calling  cr_backlight_init+0x0/0x60
INTEL CARILLO RANCH LPC not found.
Carillo Ranch Backlight Driver Initialized.
initcall cr_backlight_init+0x0/0x60 returned 0 after 0 msecs
calling  tdfxfb_init+0x0/0xe3
initcall tdfxfb_init+0x0/0xe3 returned 0 after 0 msecs
calling  vmlfb_init+0x0/0x81
vmlfb: initializing
initcall vmlfb_init+0x0/0x81 returned 0 after 0 msecs
calling  arkfb_init+0x0/0x4b
initcall arkfb_init+0x0/0x4b returned 0 after 0 msecs
calling  sstfb_init+0x0/0x18e
initcall sstfb_init+0x0/0x18e returned 0 after 0 msecs
calling  uvesafb_init+0x0/0x360
hub 5-0:1.0: debounce: port 2: total 100ms stable 100ms status 0x101
uvesafb: failed to execute /sbin/v86d
uvesafb: make sure that the v86d helper is installed and executable
uvesafb: Getting VBE info block failed (eax=3D0x4f00, err=3D-2)
uvesafb: vbe_init() failed with -22
uvesafb: probe of uvesafb.0 failed with error -22
initcall uvesafb_init+0x0/0x360 returned 0 after 0 msecs
calling  efifb_init+0x0/0x41
initcall efifb_init+0x0/0x41 returned -19 after 0 msecs
calling  acpi_reserve_resources+0x0/0xc8
initcall acpi_reserve_resources+0x0/0xc8 returned 0 after 0 msecs
calling  acpi_fan_init+0x0/0x2c
initcall acpi_fan_init+0x0/0x2c returned 0 after 0 msecs
calling  irqrouter_init_sysfs+0x0/0x33
initcall irqrouter_init_sysfs+0x0/0x33 returned 0 after 0 msecs
calling  acpi_pci_slot_init+0x0/0x1b
initcall acpi_pci_slot_init+0x0/0x1b returned 0 after 0 msecs
calling  acpi_container_init+0x0/0x3d
Clocksource tsc unstable (delta =3D -63036542 ns)
initcall acpi_container_init+0x0/0x3d returned 0 after 14 msecs
calling  asus_acpi_init+0x0/0xe2
initcall asus_acpi_init+0x0/0xe2 returned -19 after 0 msecs
calling  toshiba_acpi_init+0x0/0x159
initcall toshiba_acpi_init+0x0/0x159 returned -19 after 0 msecs
calling  rand_initialize+0x0/0x25
initcall rand_initialize+0x0/0x25 returned 0 after 0 msecs
calling  tty_init+0x0/0x18f
initcall tty_init+0x0/0x18f returned 0 after 15 msecs
calling  pty_init+0x0/0x37d
usb 5-2: new full speed USB device using uhci_hcd and address 2
initcall pty_init+0x0/0x37d returned 0 after 113 msecs
calling  moxa_init+0x0/0xf3
MOXA Intellio family driver version 6.0k
initcall moxa_init+0x0/0xf3 returned 0 after 30 msecs
calling  mxser_module_init+0x0/0x5f8
MOXA Smartio/Industio family driver version 2.0.3
initcall mxser_module_init+0x0/0x5f8 returned 0 after 0 msecs
calling  ip2_init+0x0/0x45
Computone IntelliPort Plus multiport driver version 1.2.14
initcall ip2_init+0x0/0x45 returned 0 after 0 msecs
calling  riscom8_init_module+0x0/0x3bd
rc: SDL RISCom/8 card driver v1.1, (c) D.Gorodchanin 1994-1996.
rc0: RISCom/8 Board at 0x220 not found.
rc1: RISCom/8 Board at 0x240 not found.
rc2: RISCom/8 Board at 0x250 not found.
rc3: RISCom/8 Board at 0x260 not found.
rc: No RISCom/8 boards detected.
initcall riscom8_init_module+0x0/0x3bd returned -5 after 19 msecs
initcall riscom8_init_module+0x0/0x3bd returned with error code -5=20
calling  applicom_init+0x0/0x42c
Applicom driver: $Id: ac.c,v 1.30 2000/03/22 16:03:57 dwmw2 Exp $
ac.o: No PCI boards found.
ac.o: For an ISA board you must supply memory and irq parameters.
initcall applicom_init+0x0/0x42c returned -6 after 0 msecs
initcall applicom_init+0x0/0x42c returned with error code -6=20
calling  hpet_init+0x0/0x57
hpet_acpi_add: no address or irqs in _CRS
initcall hpet_init+0x0/0x57 returned 0 after 0 msecs
calling  nvram_init+0x0/0x75
Non-volatile memory driver v1.2
initcall nvram_init+0x0/0x75 returned 0 after 0 msecs
calling  toshiba_init+0x0/0x31a
toshiba: not a supported Toshiba laptop
initcall toshiba_init+0x0/0x31a returned -19 after 0 msecs
calling  i8k_init+0x0/0x174
initcall i8k_init+0x0/0x174 returned -19 after 0 msecs
calling  cs5535_gpio_init+0x0/0x147
cs5535_gpio: DIVIL not found
initcall cs5535_gpio_init+0x0/0x147 returned -19 after 0 msecs
calling  agp_init+0x0/0x21
Linux agpgart interface v0.103
initcall agp_init+0x0/0x21 returned 0 after 0 msecs
calling  agp_ati_init+0x0/0x24
initcall agp_ati_init+0x0/0x24 returned 0 after 0 msecs
calling  agp_intel_init+0x0/0x24
agpgart: Detected an Intel 945GM Chipset.
agpgart: Detected 7932K stolen memory.
usb 5-2: ep0 maxpacket =3D 8
agpgart: AGP aperture is 256M @ 0xd0000000
initcall agp_intel_init+0x0/0x24 returned 0 after 18 msecs
calling  agp_sis_init+0x0/0x24
initcall agp_sis_init+0x0/0x24 returned 0 after 0 msecs
calling  agp_via_init+0x0/0x24
initcall agp_via_init+0x0/0x24 returned 0 after 0 msecs
calling  ipmi_init_msghandler_mod+0x0/0xc
ipmi message handler version 39.2
initcall ipmi_init_msghandler_mod+0x0/0xc returned 0 after 0 msecs
calling  init_ipmi_si+0x0/0x6ee
IPMI System Interface driver.
ipmi_si: Unable to find any System Interface(s)
initcall init_ipmi_si+0x0/0x6ee returned -19 after 1 msecs
calling  ipmi_wdog_init+0x0/0xfe
IPMI Watchdog: driver initialized
initcall ipmi_wdog_init+0x0/0xfe returned 0 after 0 msecs
calling  init_atmel+0x0/0x167
initcall init_atmel+0x0/0x167 returned -19 after 0 msecs
calling  drm_core_init+0x0/0xcc
[drm] Initialized drm 1.1.0 20060810
initcall drm_core_init+0x0/0xcc returned 0 after 0 msecs
calling  i810_init+0x0/0x19
initcall i810_init+0x0/0x19 returned 0 after 0 msecs
calling  i915_init+0x0/0x19
pci 0000:00:02.0: power state changed by ACPI to D0
Pin 1-16 already programmed
pci 0000:00:02.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
PCI: Setting latency timer of device 0000:00:02.0 to 64
[drm] Initialized i915 1.6.0 20060119 on minor 0
initcall i915_init+0x0/0x19 returned 0 after 0 msecs
calling  cn_proc_init+0x0/0x30
initcall cn_proc_init+0x0/0x30 returned 0 after 0 msecs
calling  i810fb_init+0x0/0x35a
initcall i810fb_init+0x0/0x35a returned 0 after 0 msecs
calling  serial8250_init+0x0/0x10c
Serial: 8250/16550 driver4 ports, IRQ sharing disabled
serial8250: ttyS1 at I/O 0x2f8 (irq =3D 3) is a NS16550A
initcall serial8250_init+0x0/0x10c returned 0 after 2 msecs
calling  serial8250_pnp_init+0x0/0xf
pnp: the driver 'serial' has been registered
initcall serial8250_pnp_init+0x0/0xf returned 0 after 0 msecs
calling  serial8250_pci_init+0x0/0x16
initcall serial8250_pci_init+0x0/0x16 returned 0 after 0 msecs
calling  fourport_init+0x0/0xf
initcall fourport_init+0x0/0xf returned 0 after 6 msecs
calling  accent_init+0x0/0xf
initcall accent_init+0x0/0xf returned 0 after 0 msecs
calling  exar_init+0x0/0xf
initcall exar_init+0x0/0xf returned 0 after 2 msecs
calling  hub6_init+0x0/0xf
usb 5-2: default language 0x0409
initcall hub6_init+0x0/0xf returned 0 after 8 msecs
calling  jsm_init_module+0x0/0x3a
initcall jsm_init_module+0x0/0x3a returned 0 after 0 msecs
calling  isa_bus_init+0x0/0x33
initcall isa_bus_init+0x0/0x33 returned 0 after 0 msecs
calling  topology_sysfs_init+0x0/0x36
initcall topology_sysfs_init+0x0/0x36 returned 0 after 0 msecs
calling  xd_init+0x0/0x47a
xd: Out of memory.
initcall xd_init+0x0/0x47a returned -12 after 0 msecs
initcall xd_init+0x0/0x47a returned with error code -12=20
calling  cpqarray_init+0x0/0x22b
Compaq SMART2 Driver (v 2.6.0)
initcall cpqarray_init+0x0/0x22b returned 0 after 0 msecs
calling  mm_init+0x0/0x146
MM: desc_per_page =3D 128
initcall mm_init+0x0/0x146 returned 0 after 0 msecs
calling  nbd_init+0x0/0x28a
nbd: registered device at major 43
initcall nbd_init+0x0/0x28a returned 0 after 10 msecs
calling  carm_init+0x0/0x16
initcall carm_init+0x0/0x16 returned 0 after 0 msecs
calling  compal_init+0x0/0xed
initcall compal_init+0x0/0xed returned -19 after 0 msecs
calling  lkdtm_module_init+0x0/0x1bf
lkdtm : Invalid command
initcall lkdtm_module_init+0x0/0x1bf returned -22 after 0 msecs
initcall lkdtm_module_init+0x0/0x1bf returned with error code -22=20
calling  ioc4_init+0x0/0x16
initcall ioc4_init+0x0/0x16 returned 0 after 0 msecs
calling  sm501_base_init+0x0/0x20
usb 5-2: uevent
usb 5-2: usb_probe_device
usb 5-2: configuration #1 chosen from 1 choice
initcall sm501_base_init+0x0/0x20 returned 0 after 0 msecs
calling  pasic3_base_init+0x0/0x14
initcall pasic3_base_init+0x0/0x14 returned -19 after 0 msecs
calling  e1000_init_module+0x0/0x53
e1000e: Intel(R) PRO/1000 Network Driver - 0.3.3.3-k2
e1000e: Copyright (c) 1999-2008 Intel Corporation.
e1000e 0000:02:00.0: Disabling L1 ASPM
vendor=3D8086 device=3D27d0
Pin 1-16 already programmed
e1000e 0000:02:00.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
PCI: Setting latency timer of device 0000:02:00.0 to 64
usb 5-2: adding 5-2:1.0 (config #1, interface 0)
usb 5-2:1.0: uevent
usb 5-2: New USB device found, idVendor=3D0483, idProduct=3D2016
usb 5-2: New USB device strings: Mfr=3D1, Product=3D2, SerialNumber=3D0
usb 5-2: Product: Biometric Coprocessor
usb 5-2: Manufacturer: STMicroelectronics
eth0: (PCI Express:2.5GB/s:Width x1) 00:16:41:17:49:d2
eth0: Intel(R) PRO/1000 Network Connection
eth0: MAC: 2, PHY: 2, PBA No: 005301-003
initcall e1000_init_module+0x0/0x53 returned 0 after 82 msecs
calling  ixgb_init_module+0x0/0x39
Intel(R) PRO/10GbE Network Driver - version 1.0.135-k2-NAPI
Copyright (c) 1999-2008 Intel Corporation.
initcall ixgb_init_module+0x0/0x39 returned 0 after 0 msecs
calling  t1_init_module+0x0/0x16
initcall t1_init_module+0x0/0x16 returned 0 after 0 msecs
calling  cxgb3_init_module+0x0/0x1b
initcall cxgb3_init_module+0x0/0x1b returned 0 after 0 msecs
calling  vcan_init_module+0x0/0x2e
vcan: Virtual CAN interface driver
initcall vcan_init_module+0x0/0x2e returned 0 after 0 msecs
calling  happy_meal_probe+0x0/0x16
initcall happy_meal_probe+0x0/0x16 returned 0 after 0 msecs
calling  vortex_init+0x0/0xbf
initcall vortex_init+0x0/0xbf returned 0 after 0 msecs
calling  pcnet32_init_module+0x0/0x118
pcnet32.c:v1.35 21.Apr.2008 tsbogend@alpha.franken.de
initcall pcnet32_init_module+0x0/0x118 returned 0 after 0 msecs
calling  eepro100_init_module+0x0/0x16
initcall eepro100_init_module+0x0/0x16 returned 0 after 0 msecs
calling  e100_init_module+0x0/0x4d
e100: Intel(R) PRO/100 Network Driver, 3.5.23-k4-NAPI
e100: Copyright(c) 1999-2006 Intel Corporation
initcall e100_init_module+0x0/0x4d returned 0 after 0 msecs
calling  epic_init+0x0/0x16
initcall epic_init+0x0/0x16 returned 0 after 0 msecs
calling  r6040_init+0x0/0x16
initcall r6040_init+0x0/0x16 returned 0 after 0 msecs
calling  yellowfin_init+0x0/0x16
initcall yellowfin_init+0x0/0x16 returned 0 after 0 msecs
calling  ns83820_init+0x0/0x20
ns83820.c: National Semiconductor DP83820 10/100/1000 driver.
initcall ns83820_init+0x0/0x20 returned 0 after 0 msecs
calling  tg3_init+0x0/0x16
initcall tg3_init+0x0/0x16 returned 0 after 0 msecs
calling  bnx2_init+0x0/0x16
initcall bnx2_init+0x0/0x16 returned 0 after 0 msecs
calling  bnx2x_init+0x0/0x16
initcall bnx2x_init+0x0/0x16 returned 0 after 0 msecs
calling  skfd_init+0x0/0x16
initcall skfd_init+0x0/0x16 returned 0 after 0 msecs
calling  net_olddevs_init+0x0/0x81
initcall net_olddevs_init+0x0/0x81 returned 0 after 8 msecs
calling  init_nic+0x0/0x16
initcall init_nic+0x0/0x16 returned 0 after 0 msecs
calling  ppp_init+0x0/0x83
PPP generic driver version 2.4.2
initcall ppp_init+0x0/0x83 returned 0 after 0 msecs
calling  deflate_init+0x0/0x30
PPP Deflate Compression module registered
initcall deflate_init+0x0/0x30 returned 0 after 0 msecs
calling  pppox_init+0x0/0xf
NET: Registered protocol family 24
initcall pppox_init+0x0/0xf returned 0 after 0 msecs
calling  pppoe_init+0x0/0x81
initcall pppoe_init+0x0/0x81 returned 0 after 0 msecs
calling  slip_init+0x0/0x98
SLIP: version 0.8.4-NET3.019-NEWTTY (dynamic channels, max=3D256) (6 bi=
t encapsulation enabled).
CSLIP: code copyright 1989 Regents of the University of California.
initcall slip_init+0x0/0x98 returned 0 after 0 msecs
calling  dummy_init_module+0x0/0x95
initcall dummy_init_module+0x0/0x95 returned 0 after 0 msecs
calling  macvlan_init_module+0x0/0x45
initcall macvlan_init_module+0x0/0x45 returned 0 after 0 msecs
calling  rtl8139_init_module+0x0/0x16
initcall rtl8139_init_module+0x0/0x16 returned 0 after 0 msecs
calling  znet_probe+0x0/0x2bd
initcall znet_probe+0x0/0x2bd returned -19 after 0 msecs
calling  depca_module_init+0x0/0xd4
initcall depca_module_init+0x0/0xd4 returned 0 after 0 msecs
calling  lp486e_init_module+0x0/0x240
eth%d: i82596 initialization timed out
initcall lp486e_init_module+0x0/0x240 returned -19 after 0 msecs
calling  s2io_starter+0x0/0x16
initcall s2io_starter+0x0/0x16 returned 0 after 0 msecs
calling  enc28j60_init+0x0/0x1e
initcall enc28j60_init+0x0/0x1e returned 0 after 0 msecs
calling  arcnet_init+0x0/0x50
arcnet loaded.
initcall arcnet_init+0x0/0x50 returned 0 after 0 msecs
calling  arcnet_rfc1201_init+0x0/0x65
arcnet: RFC1201 "standard" (`a') encapsulation support loaded.
initcall arcnet_rfc1201_init+0x0/0x65 returned 0 after 0 msecs
calling  kaweth_init+0x0/0x25
drivers/net/usb/kaweth.c: Driver loading
usbcore: registered new interface driver kaweth
initcall kaweth_init+0x0/0x25 returned 0 after 0 msecs
calling  pegasus_init+0x0/0x150
pegasus: v0.6.14 (2006/09/27), Pegasus/Pegasus II USB Ethernet driver
usbcore: registered new interface driver pegasus
initcall pegasus_init+0x0/0x150 returned 0 after 0 msecs
calling  tulip_init+0x0/0x2a
initcall tulip_init+0x0/0x2a returned 0 after 0 msecs
calling  uli526x_init_module+0x0/0x8d
uli526x: ULi M5261/M5263 net driver, version 0.9.3 (2005-7-29)
initcall uli526x_init_module+0x0/0x8d returned 0 after 0 msecs
calling  init_netconsole+0x0/0x1bb
netconsole: local port 4444
netconsole: local IP 10.0.1.15
netconsole: interface eth0
netconsole: remote port 4444
netconsole: remote IP 10.0.1.16
netconsole: remote ethernet address 00:19:d1:01:f5:55
netconsole: device eth0 not up yet, forcing it
usb usb2: suspend_rh (auto-stop)
usb usb3: suspend_rh (auto-stop)
usb usb4: suspend_rh (auto-stop)
hub 2-0:1.0: hub_suspend
usb usb2: bus auto-suspend
usb usb2: suspend_rh
hub 1-0:1.0: hub_suspend
usb usb1: bus auto-suspend
ehci_hcd 0000:00:1d.7: suspend root hub
hub 3-0:1.0: hub_suspend
usb usb3: bus auto-suspend
usb usb3: suspend_rh
hub 4-0:1.0: hub_suspend
usb usb4: bus auto-suspend
usb usb4: suspend_rh
netconsole: timeout waiting for carrier
eth0: Link is Up 1000 Mbps Full Duplex, Flow Control: RX/TX
console [netcon0] enabled
netconsole: network logging started
initcall init_netconsole+0x0/0x1bb returned 0 after 3837 msecs
calling  scsi_tgt_init+0x0/0x75
initcall scsi_tgt_init+0x0/0x75 returned 0 after 0 msecs
calling  spi_transport_init+0x0/0x27
initcall spi_transport_init+0x0/0x27 returned 0 after 0 msecs
calling  hp_sw_init+0x0/0xf
initcall hp_sw_init+0x0/0xf returned 0 after 0 msecs
calling  clariion_init+0x0/0x26
initcall clariion_init+0x0/0x26 returned 0 after 0 msecs
calling  ahc_linux_init+0x0/0x61
initcall ahc_linux_init+0x0/0x61 returned 0 after 0 msecs
calling  init_st+0x0/0x146
st: Version 20080224, fixed bufsize 32768, s/g segs 256
Driver 'st' needs updating - please use bus_type methods
initcall init_st+0x0/0x146 returned 0 after 0 msecs
calling  init_sd+0x0/0xb1
Driver 'sd' needs updating - please use bus_type methods
initcall init_sd+0x0/0xb1 returned 0 after 0 msecs
calling  init_ch_module+0x0/0x87
SCSI Media Changer driver v0.25=20
Driver 'ch' needs updating - please use bus_type methods
initcall init_ch_module+0x0/0x87 returned 0 after 0 msecs
calling  ahci_init+0x0/0x16
ahci 0000:00:1f.2: version 3.0
Pin 1-16 already programmed
ahci 0000:00:1f.2: PCI INT B -> GSI 16 (level, low) -> IRQ 16
ahci 0000:00:1f.2: AHCI 0001.0100 32 slots 4 ports 1.5 Gbps 0x1 impl SA=
TA mode
ahci 0000:00:1f.2: flags: 64bit ncq pm led clo pio slum part=20
PCI: Setting latency timer of device 0000:00:1f.2 to 64
scsi0 : ahci
scsi1 : ahci
scsi2 : ahci
scsi3 : ahci
ata1: SATA max UDMA/133 abar m1024@0xee444400 port 0xee444500 irq 222
ata2: DUMMY
ata3: DUMMY
ata4: DUMMY
ata1: SATA link up 1.5 Gbps (SStatus 113 SControl 300)
ata1.00: ATA-7: HTS541080G9SA00, MB4IC60H, max UDMA/100
ata1.00: 156301488 sectors, multi 16: LBA48=20
ata1.00: configured for UDMA/100
scsi 0:0:0:0: Direct-Access     ATA      HTS541080G9SA00  MB4I PQ: 0 AN=
SI: 5
sd 0:0:0:0: [sda] 156301488 512-byte hardware sectors (80026 MB)
sd 0:0:0:0: [sda] Write Protect is off
sd 0:0:0:0: [sda] Mode Sense: 00 3a 00 00
sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't su=
pport DPO or FUA
sd 0:0:0:0: [sda] 156301488 512-byte hardware sectors (80026 MB)
sd 0:0:0:0: [sda] Write Protect is off
sd 0:0:0:0: [sda] Mode Sense: 00 3a 00 00
sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't su=
pport DPO or FUA
 sda: sda1 sda2
sd 0:0:0:0: [sda] Attached SCSI disk
initcall ahci_init+0x0/0x16 returned 0 after 1021 msecs
calling  piix_init+0x0/0x24
ata_piix 0000:00:1f.1: version 2.12
Pin 1-16 already programmed
ata_piix 0000:00:1f.1: PCI INT C -> GSI 16 (level, low) -> IRQ 16
PCI: Setting latency timer of device 0000:00:1f.1 to 64
scsi4 : ata_piix
scsi5 : ata_piix
ata5: PATA max UDMA/100 cmd 0x1f0 ctl 0x3f6 bmdma 0x1810 irq 14
ata6: PATA max UDMA/100 cmd 0x170 ctl 0x376 bmdma 0x1818 irq 15
ata5.00: ATAPI: HL-DT-STCD-RW/DVD DRIVE GCC-4246N, 0X05, max UDMA/33
ata5.00: configured for UDMA/33
ata6: port disabled. ignoring.
scsi 4:0:0:0: CD-ROM            HL-DT-ST RW/DVD GCC-4246N 0X05 PQ: 0 AN=
SI: 5
initcall piix_init+0x0/0x24 returned 0 after 161 msecs
calling  qs_ata_init+0x0/0x16
initcall qs_ata_init+0x0/0x16 returned 0 after 0 msecs
calling  svia_init+0x0/0x16
initcall svia_init+0x0/0x16 returned 0 after 0 msecs
calling  vsc_sata_init+0x0/0x16
initcall vsc_sata_init+0x0/0x16 returned 0 after 0 msecs
calling  pdc_sata_init+0x0/0x16
initcall pdc_sata_init+0x0/0x16 returned 0 after 0 msecs
calling  nv_init+0x0/0x16
initcall nv_init+0x0/0x16 returned 0 after 0 msecs
calling  amd_init+0x0/0x16
initcall amd_init+0x0/0x16 returned 0 after 0 msecs
calling  artop_init+0x0/0x16
initcall artop_init+0x0/0x16 returned 0 after 0 msecs
calling  atiixp_init+0x0/0x16
initcall atiixp_init+0x0/0x16 returned 0 after 0 msecs
calling  cmd64x_init+0x0/0x16
initcall cmd64x_init+0x0/0x16 returned 0 after 0 msecs
calling  efar_init+0x0/0x16
initcall efar_init+0x0/0x16 returned 0 after 0 msecs
calling  hpt3x2n_init+0x0/0x16
initcall hpt3x2n_init+0x0/0x16 returned 0 after 0 msecs
calling  it8213_init+0x0/0x16
initcall it8213_init+0x0/0x16 returned 0 after 0 msecs
calling  ninja32_init+0x0/0x16
initcall ninja32_init+0x0/0x16 returned 0 after 0 msecs
calling  mpiix_init+0x0/0x16
initcall mpiix_init+0x0/0x16 returned 0 after 0 msecs
calling  oldpiix_init+0x0/0x16
initcall oldpiix_init+0x0/0x16 returned 0 after 0 msecs
calling  via_init+0x0/0x16
initcall via_init+0x0/0x16 returned 0 after 0 msecs
calling  sl82c105_init+0x0/0x16
initcall sl82c105_init+0x0/0x16 returned 0 after 0 msecs
calling  sis_init+0x0/0x16
initcall sis_init+0x0/0x16 returned 0 after 0 msecs
calling  triflex_init+0x0/0x16
initcall triflex_init+0x0/0x16 returned 0 after 0 msecs
calling  ata_generic_init+0x0/0x16
initcall ata_generic_init+0x0/0x16 returned 0 after 0 msecs
calling  legacy_init+0x0/0x865
initcall legacy_init+0x0/0x865 returned -19 after 0 msecs
calling  i2o_iop_init+0x0/0x41
I2O subsystem v1.325
i2o: max drivers =3D 8
initcall i2o_iop_init+0x0/0x41 returned 0 after 0 msecs
calling  i2o_block_init+0x0/0xf7
I2O Block Device OSM v1.325
initcall i2o_block_init+0x0/0xf7 returned 0 after 0 msecs
calling  i2o_proc_init+0x0/0x14e
I2O ProcFS OSM v1.316
initcall i2o_proc_init+0x0/0x14e returned 0 after 0 msecs
calling  uio_init+0x0/0x7
initcall uio_init+0x0/0x7 returned 0 after 0 msecs
calling  smx_ce_init_module+0x0/0xf
initcall smx_ce_init_module+0x0/0xf returned 0 after 0 msecs
calling  mon_init+0x0/0xee
initcall mon_init+0x0/0xee returned 0 after 1 msecs
calling  isp116x_init+0x0/0x38
116x: driver isp116x-hcd, 03 Nov 2005
initcall isp116x_init+0x0/0x38 returned 0 after 0 msecs
calling  r8a66597_init+0x0/0x38
r8a66597_hcd: driver r8a66597_hcd, 10 Apr 2008
initcall r8a66597_init+0x0/0x38 returned 0 after 0 msecs
calling  c67x00_init+0x0/0xf
initcall c67x00_init+0x0/0xf returned 0 after 0 msecs
calling  usb_stor_init+0x0/0x42
Initializing USB Mass Storage driver...
usbcore: registered new interface driver usb-storage
USB Mass Storage support registered.
initcall usb_stor_init+0x0/0x42 returned 0 after 0 msecs
calling  usb_usual_init+0x0/0x32
usbcore: registered new interface driver libusual
initcall usb_usual_init+0x0/0x32 returned 0 after 0 msecs
calling  appledisplay_init+0x0/0x4e
usbcore: registered new interface driver appledisplay
initcall appledisplay_init+0x0/0x4e returned 0 after 0 msecs
calling  cypress_init+0x0/0x2f
usbcore: registered new interface driver cypress_cy7c63
initcall cypress_init+0x0/0x2f returned 0 after 0 msecs
calling  usb_cytherm_init+0x0/0x3c
usbcore: registered new interface driver cytherm
cytherm: v1.0:Cypress USB Thermometer driver
initcall usb_cytherm_init+0x0/0x3c returned 0 after 0 msecs
calling  isight_firmware_init+0x0/0x16
usbcore: registered new interface driver isight_firmware
initcall isight_firmware_init+0x0/0x16 returned 0 after 0 msecs
calling  usb_lcd_init+0x0/0x2f
usbcore: registered new interface driver usblcd
initcall usb_lcd_init+0x0/0x2f returned 0 after 0 msecs
calling  usb_sisusb_init+0x0/0x1b
usbcore: registered new interface driver sisusb
initcall usb_sisusb_init+0x0/0x1b returned 0 after 0 msecs
calling  usbatm_usb_init+0x0/0x5c
drivers/usb/atm/usbatm.c: usbatm_usb_init: driver version 1.10
initcall usbatm_usb_init+0x0/0x5c returned 0 after 0 msecs
calling  init+0x0/0x16
initcall init+0x0/0x16 returned 0 after 0 msecs
calling  init+0x0/0xa7
Printer Gadget: usb_gadget_register_driver ffffffed
initcall init+0x0/0xa7 returned -19 after 0 msecs
calling  i8042_init+0x0/0x31e
pnp: the driver 'i8042 kbd' has been registered
i8042 kbd 00:08: driver attached
pnp: the driver 'i8042 aux' has been registered
i8042 aux 00:09: driver attached
PNP: PS/2 Controller [PNP0303:KBD,PNP0f13:MOU] at 0x60,0x64 irq 1,12
serio: i8042 KBD port at 0x60,0x64 irq 1
serio: i8042 AUX port at 0x60,0x64 irq 12
initcall i8042_init+0x0/0x31e returned 0 after 9 msecs
calling  mousedev_init+0x0/0x51
mice: PS/2 mouse device common for all mice
initcall mousedev_init+0x0/0x51 returned 0 after 0 msecs
calling  joydev_init+0x0/0xf
initcall joydev_init+0x0/0xf returned 0 after 0 msecs
calling  evdev_init+0x0/0xf
initcall evdev_init+0x0/0xf returned 0 after 0 msecs
calling  atkbd_init+0x0/0x20
initcall atkbd_init+0x0/0x20 returned 0 after 0 msecs
calling  lkkbd_init+0x0/0x16
input: AT Translated Set 2 keyboard as /class/input/input0
initcall lkkbd_init+0x0/0x16 returned 0 after 11 msecs
calling  skbd_init+0x0/0x16
initcall skbd_init+0x0/0x16 returned 0 after 0 msecs
calling  inport_init+0x0/0x122
inport.c: Didn't find InPort mouse at 0x23c
initcall inport_init+0x0/0x122 returned -19 after 0 msecs
calling  gpio_mouse_init+0x0/0x14
initcall gpio_mouse_init+0x0/0x14 returned -19 after 0 msecs
calling  cobra_init+0x0/0x13
initcall cobra_init+0x0/0x13 returned 0 after 0 msecs
calling  gf2k_init+0x0/0x13
initcall gf2k_init+0x0/0x13 returned 0 after 0 msecs
calling  grip_init+0x0/0x13
initcall grip_init+0x0/0x13 returned 0 after 0 msecs
calling  iforce_init+0x0/0x7
initcall iforce_init+0x0/0x7 returned 0 after 0 msecs
calling  stinger_init+0x0/0x16
initcall stinger_init+0x0/0x16 returned 0 after 0 msecs
calling  warrior_init+0x0/0x16
initcall warrior_init+0x0/0x16 returned 0 after 0 msecs
calling  zhenhua_init+0x0/0x16
initcall zhenhua_init+0x0/0x16 returned 0 after 0 msecs
calling  aiptek_init+0x0/0x38
usbcore: registered new interface driver aiptek
aiptek: v2.3 (May 2, 2007): Bryan W. Headley/Chris Atenasio/Cedric Brun=
/Rene van Paassen
aiptek: Aiptek HyperPen USB Tablet Driver (Linux 2.6.x)
initcall aiptek_init+0x0/0x38 returned 0 after 0 msecs
calling  kbtab_init+0x0/0x2d
usbcore: registered new interface driver kbtab
kbtab: v0.0.2:USB KB Gear JamStudio Tablet driver
initcall kbtab_init+0x0/0x2d returned 0 after 0 msecs
calling  wacom_init+0x0/0x37
usbcore: registered new interface driver wacom
wacom: v1.48:USB Wacom Graphire and Wacom Intuos tablet driver
initcall wacom_init+0x0/0x37 returned 0 after 0 msecs
calling  ati_remote_init+0x0/0x3c
usbcore: registered new interface driver ati_remote
ati_remote: Registered USB driver ATI/X10 RF USB Remote Control v. 2.2.=
1
initcall ati_remote_init+0x0/0x3c returned 0 after 0 msecs
calling  ati_remote2_init+0x0/0x3c
usbcore: registered new interface driver ati_remote2
ati_remote2: ATI/Philips USB RF remote driver 0.2
initcall ati_remote2_init+0x0/0x3c returned 0 after 0 msecs
calling  powermate_init+0x0/0x16
usbcore: registered new interface driver powermate
initcall powermate_init+0x0/0x16 returned 0 after 0 msecs
calling  uinput_init+0x0/0xf
initcall uinput_init+0x0/0xf returned 0 after 0 msecs
calling  i2c_amd8111_init+0x0/0x16
initcall i2c_amd8111_init+0x0/0x16 returned 0 after 0 msecs
calling  i2c_sis96x_init+0x0/0x16
initcall i2c_sis96x_init+0x0/0x16 returned 0 after 0 msecs
calling  i2c_vt586b_init+0x0/0x16
initcall i2c_vt586b_init+0x0/0x16 returned 0 after 0 msecs
calling  i2c_vt596_init+0x0/0x16
initcall i2c_vt596_init+0x0/0x16 returned 0 after 0 msecs
calling  i2c_gpio_init+0x0/0x2d
i2c-gpio: probe failed: -19
initcall i2c_gpio_init+0x0/0x2d returned -19 after 0 msecs
calling  i2c_parport_init+0x0/0x144
i2c-parport-light: adapter type unspecified
initcall i2c_parport_init+0x0/0x144 returned -19 after 0 msecs
calling  i2c_voodoo3_init+0x0/0x16
initcall i2c_voodoo3_init+0x0/0x16 returned 0 after 0 msecs
calling  scx200_acb_init+0x0/0x204
scx200_acb: NatSemi SCx200 ACCESS.bus Driver
initcall scx200_acb_init+0x0/0x204 returned -19 after 0 msecs
calling  ds1682_init+0x0/0x11
i2c-core: driver [ds1682] registered
initcall ds1682_init+0x0/0x11 returned 0 after 0 msecs
calling  eeprom_init+0x0/0x11
i2c-core: driver [eeprom] registered
initcall eeprom_init+0x0/0x11 returned 0 after 0 msecs
calling  max6875_init+0x0/0x11
i2c-core: driver [max6875] registered
initcall max6875_init+0x0/0x11 returned 0 after 0 msecs
calling  pcf8591_init+0x0/0x32
i2c-core: driver [pcf8591] registered
initcall pcf8591_init+0x0/0x32 returned 0 after 0 msecs
calling  w1_init+0x0/0xe4
Driver for 1-wire Dallas network protocol.
initcall w1_init+0x0/0xe4 returned 0 after 0 msecs
calling  w1_gpio_init+0x0/0x14
initcall w1_gpio_init+0x0/0x14 returned -19 after 0 msecs
calling  w1_smem_init+0x0/0x33
initcall w1_smem_init+0x0/0x33 returned 0 after 0 msecs
calling  w1_ds2760_init+0x0/0x23
1-Wire driver for the DS2760 battery monitor  chip  - (c) 2004-2005, Sz=
abolcs Gyurko
initcall w1_ds2760_init+0x0/0x23 returned 0 after 0 msecs
calling  ds2760_battery_init+0x0/0xf
initcall ds2760_battery_init+0x0/0xf returned 0 after 0 msecs
calling  bpa10x_init+0x0/0x25
Bluetooth: Digianswer Bluetooth USB driver ver 0.9
usbcore: registered new interface driver bpa10x
initcall bpa10x_init+0x0/0x25 returned 0 after 0 msecs
calling  btsdio_init+0x0/0x1e
Bluetooth: Generic Bluetooth SDIO driver ver 0.1
initcall btsdio_init+0x0/0x1e returned 0 after 0 msecs
calling  pci_eisa_init_module+0x0/0x16
initcall pci_eisa_init_module+0x0/0x16 returned 0 after 0 msecs
calling  cpufreq_stats_init+0x0/0x80
initcall cpufreq_stats_init+0x0/0x80 returned 0 after 0 msecs
calling  mmc_test_init+0x0/0xf
initcall mmc_test_init+0x0/0xf returned 0 after 0 msecs
calling  tifm_sd_init+0x0/0xf
initcall tifm_sd_init+0x0/0xf returned 0 after 0 msecs
calling  gpio_led_init+0x0/0xf
Registered led device: rdc:dmz
initcall gpio_led_init+0x0/0xf returned 0 after 0 msecs
calling  ioat_init_module+0x0/0x16
initcall ioat_init_module+0x0/0x16 returned 0 after 0 msecs
calling  dca_init+0x0/0xa
initcall dca_init+0x0/0xa returned 0 after 0 msecs
calling  virtio_pci_init+0x0/0x3a
initcall virtio_pci_init+0x0/0x3a returned 0 after 0 msecs
calling  oprofile_init+0x0/0x47
oprofile: using NMI interrupt.
initcall oprofile_init+0x0/0x47 returned 0 after 0 msecs
calling  sysctl_core_init+0x0/0x1e
initcall sysctl_core_init+0x0/0x1e returned 0 after 0 msecs
calling  flow_cache_init+0x0/0x139
initcall flow_cache_init+0x0/0x139 returned 0 after 0 msecs
calling  llc_init+0x0/0x1b
initcall llc_init+0x0/0x1b returned 0 after 0 msecs
calling  snap_init+0x0/0x2a
initcall snap_init+0x0/0x2a returned 0 after 0 msecs
calling  xt_init+0x0/0x7e
initcall xt_init+0x0/0x7e returned 0 after 0 msecs
calling  tcpudp_mt_init+0x0/0x14
initcall tcpudp_mt_init+0x0/0x14 returned 0 after 0 msecs
calling  classify_tg_init+0x0/0x14
initcall classify_tg_init+0x0/0x14 returned 0 after 0 msecs
calling  dccp_mt_init+0x0/0x45
initcall dccp_mt_init+0x0/0x45 returned 0 after 0 msecs
calling  dscp_mt_init+0x0/0x14
initcall dscp_mt_init+0x0/0x14 returned 0 after 0 msecs
calling  iprange_mt_init+0x0/0x14
initcall iprange_mt_init+0x0/0x14 returned 0 after 0 msecs
calling  pkttype_mt_init+0x0/0x14
initcall pkttype_mt_init+0x0/0x14 returned 0 after 0 msecs
calling  sctp_mt_init+0x0/0x14
initcall sctp_mt_init+0x0/0x14 returned 0 after 0 msecs
calling  string_mt_init+0x0/0x14
initcall string_mt_init+0x0/0x14 returned 0 after 0 msecs
calling  tcpmss_mt_init+0x0/0x14
initcall tcpmss_mt_init+0x0/0x14 returned 0 after 0 msecs
calling  sysctl_ipv4_init+0x0/0x3f
initcall sysctl_ipv4_init+0x0/0x3f returned 0 after 1 msecs
calling  xfrm4_mode_tunnel_init+0x0/0x14
initcall xfrm4_mode_tunnel_init+0x0/0x14 returned 0 after 0 msecs
calling  ipv4_netfilter_init+0x0/0xf
initcall ipv4_netfilter_init+0x0/0xf returned 0 after 0 msecs
calling  arp_tables_init+0x0/0x78
arp_tables: (C) 2002 David S. Miller
initcall arp_tables_init+0x0/0x78 returned 0 after 0 msecs
calling  arpt_mangle_init+0x0/0xf
initcall arpt_mangle_init+0x0/0xf returned 0 after 0 msecs
calling  cubictcp_register+0x0/0x93
TCP cubic registered
initcall cubictcp_register+0x0/0x93 returned 0 after 0 msecs
calling  inet6_init+0x0/0x2e4
NET: Registered protocol family 10
initcall inet6_init+0x0/0x2e4 returned 0 after 11 msecs
calling  ah6_init+0x0/0x5a
initcall ah6_init+0x0/0x5a returned 0 after 0 msecs
calling  esp6_init+0x0/0x5a
initcall esp6_init+0x0/0x5a returned 0 after 0 msecs
calling  ipcomp6_init+0x0/0x5a
initcall ipcomp6_init+0x0/0x5a returned 0 after 0 msecs
calling  xfrm6_tunnel_init+0x0/0xdb
initcall xfrm6_tunnel_init+0x0/0xdb returned 0 after 0 msecs
calling  tunnel6_init+0x0/0x5a
initcall tunnel6_init+0x0/0x5a returned 0 after 0 msecs
calling  xfrm6_mode_tunnel_init+0x0/0x14
initcall xfrm6_mode_tunnel_init+0x0/0x14 returned 0 after 0 msecs
calling  mip6_init+0x0/0xa7
Mobile IPv6
initcall mip6_init+0x0/0xa7 returned 0 after 0 msecs
calling  packet_init+0x0/0x39
NET: Registered protocol family 17
initcall packet_init+0x0/0x39 returned 0 after 0 msecs
calling  ipsec_pfkey_init+0x0/0x7a
NET: Registered protocol family 15
initcall ipsec_pfkey_init+0x0/0x7a returned 0 after 0 msecs
calling  br_init+0x0/0xa1
Bridge firewalling registered
initcall br_init+0x0/0xa1 returned 0 after 0 msecs
calling  lapb_init+0x0/0x7
initcall lapb_init+0x0/0x7 returned 0 after 0 msecs
calling  can_init+0x0/0xd1
can: controller area network core (rev 20071116 abi 8)
NET: Registered protocol family 29
initcall can_init+0x0/0xd1 returned 0 after 0 msecs
calling  sco_init+0x0/0xc2
Bluetooth: SCO (Voice Link) ver 0.6
Bluetooth: SCO socket layer initialized
initcall sco_init+0x0/0xc2 returned 0 after 0 msecs
calling  init_sunrpc+0x0/0x53
RPC: Registered udp transport module.
RPC: Registered tcp transport module.
initcall init_sunrpc+0x0/0x53 returned 0 after 1 msecs
calling  init_rpcsec_gss+0x0/0x2e
initcall init_rpcsec_gss+0x0/0x2e returned 0 after 0 msecs
calling  init_kerberos_module+0x0/0x26
initcall init_kerberos_module+0x0/0x26 returned 0 after 0 msecs
calling  lane_module_init+0x0/0x4f
lec.c: Jul 21 2008 11:15:34 initialized
initcall lane_module_init+0x0/0x4f returned 0 after 0 msecs
calling  econet_proto_init+0x0/0x186
NET: Registered protocol family 19
initcall econet_proto_init+0x0/0x186 returned 0 after 0 msecs
calling  sctp_init+0x0/0x697
SCTP: Hash tables configured (established 26214 bind 29127)
sctp_init_sock(sk: f720c000)
initcall sctp_init+0x0/0x697 returned 0 after 9 msecs
calling  powernowk8_init+0x0/0x6e
initcall powernowk8_init+0x0/0x6e returned -19 after 0 msecs
calling  hpet_insert_resource+0x0/0x1e
initcall hpet_insert_resource+0x0/0x1e returned 0 after 0 msecs
calling  lapic_insert_resource+0x0/0x44
initcall lapic_insert_resource+0x0/0x44 returned 0 after 0 msecs
calling  init_lapic_nmi_sysfs+0x0/0x33
initcall init_lapic_nmi_sysfs+0x0/0x33 returned 0 after 0 msecs
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D
BUG skbuff_head_cache: Poison overwritten
-----------------------------------------------------------------------=
------

INFO: 0xf7ccc100-0xf7ccc103. First byte 0x0 instead of 0x6b
INFO: Allocated in __alloc_skb+0x30/0x10e age=3D1 cpu=3D1 pid=3D1
INFO: Freed in __kfree_skb+0x63/0x66 age=3D1 cpu=3D0 pid=3D0
INFO: Slab 0xc1c34ca0 objects=3D16 used=3D1 fp=3D0xf7ccc100 flags=3D0x4=
00000c3
INFO: Object 0xf7ccc100 @offset=3D256 fp=3D0xf7ccc200

Bytes b4 0xf7ccc0f0:  5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a Z=
ZZZZZZZZZZZZZZZ
  Object 0xf7ccc100:  00 00 00 00 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b .=
=2E..kkkkkkkkkkkk
  Object 0xf7ccc110:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b k=
kkkkkkkkkkkkkkk
  Object 0xf7ccc120:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b k=
kkkkkkkkkkkkkkk
  Object 0xf7ccc130:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b k=
kkkkkkkkkkkkkkk
  Object 0xf7ccc140:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b k=
kkkkkkkkkkkkkkk
  Object 0xf7ccc150:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b k=
kkkkkkkkkkkkkkk
  Object 0xf7ccc160:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b k=
kkkkkkkkkkkkkkk
  Object 0xf7ccc170:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b k=
kkkkkkkkkkkkkkk
  Object 0xf7ccc180:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b k=
kkkkkkkkkkkkkkk
  Object 0xf7ccc190:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b k=
kkkkkkkkkkkkkkk
  Object 0xf7ccc1a0:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b a5 k=
kkkkkkkkkkkkkk=EF=BF=BD
 Redzone 0xf7ccc1b0:  bb bb bb bb                                     =EF=
=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD           =20
 Padding 0xf7ccc1d8:  5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a Z=
ZZZZZZZZZZZZZZZ
 Padding 0xf7ccc1e8:  5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a Z=
ZZZZZZZZZZZZZZZ
 Padding 0xf7ccc1f8:  5a 5a 5a 5a 5a 5a 5a 5a                         Z=
ZZZZZZZ       =20
Pid: 1, comm: swapper Not tainted 2.6.26-tip #3261
 [<c01673ad>] print_trailer+0xd1/0xd9
 [<c0167428>] check_bytes_and_report+0x73/0x8f
 [<c0167664>] check_object+0xa5/0x15a
 [<c016824c>] __slab_alloc+0x2fb/0x3c8
 [<c0168364>] kmem_cache_alloc+0x4b/0xa8
 [<c0497376>] ? __alloc_skb+0x30/0x10e
 [<c0497376>] ? __alloc_skb+0x30/0x10e
 [<c0497376>] __alloc_skb+0x30/0x10e
 [<c04a6678>] alloc_skb+0xc/0xe
 [<c04a6ce5>] find_skb+0x28/0x66
 [<c04a6f5f>] netpoll_send_udp+0x2b/0x1cf
 [<c058800f>] ? _spin_lock_irqsave+0x4b/0x55
 [<c03db399>] write_msg+0x79/0xac
 [<c03db320>] ? write_msg+0x0/0xac
 [<c0122f96>] __call_console_drivers+0x56/0x63
 [<c0122ffa>] _call_console_drivers+0x57/0x5b
 [<c0123386>] release_console_sem+0x112/0x1a5
 [<c01238f3>] vprintk+0x344/0x35e
