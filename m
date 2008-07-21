From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [crash] BUG: unable to handle kernel NULL pointer dereference
	at 0000000000000370
Date: Mon, 21 Jul 2008 16:30:23 +0200
Message-ID: <20080721143023.GA32451@elte.hu>
References: <20080720.104411.81744468.davem@davemloft.net> <20080721133059.GA30637@elte.hu> <20080721134506.GA27598@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:50074 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751860AbYGUOar (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Jul 2008 10:30:47 -0400
Content-Disposition: inline
In-Reply-To: <20080721134506.GA27598@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Ingo Molnar <mingo@elte.hu> wrote:

> Pid: 1, comm: swapper Not tainted 2.6.26-tip-00013-g6de15c6-dirty #21=
290

some more information: find below the same crash with vanilla=20
linus/master and no extra patches. The crash site is:

(gdb) list *0xffffffff808be0c2
0xffffffff808be0c2 is in rollback_registered (net/core/dev.c:3793).
3788    {
3789            BUG_ON(dev_boot_phase);
3790            ASSERT_RTNL();
3791
3792            /* Some devices call without registering for initializa=
tion unwind. */
3793            if (dev->reg_state =3D=3D NETREG_UNINITIALIZED) {
3794                    printk(KERN_DEBUG "unregister_netdevice: device=
 %s/%p never "
3795                                      "was registered\n", dev->name=
, dev);
3796
3797                    WARN_ON(1);
(gdb)

Thanks,

	Ingo

----------------------------------->
Linux version 2.6.26-05253-g14b395e (mingo@dione) (gcc version 4.2.3) #=
21308 SMP Mon Jul 21 16:14:51 CEST 2008
Command line: root=3D/dev/sda1 earlyprintk=3Dvga console=3DttyS0,115200=
 console=3Dtty 5 profile=3D0 debug initcall_debug apic=3Ddebug apic=3Dv=
erbose ignore_loglevel sysrq_always_enabled pci=3Dnomsi
BIOS-provided physical RAM map:
 BIOS-e820: 0000000000000000 - 000000000009fc00 (usable)
 BIOS-e820: 000000000009fc00 - 00000000000a0000 (reserved)
 BIOS-e820: 00000000000e0000 - 0000000000100000 (reserved)
 BIOS-e820: 0000000000100000 - 000000003ed94000 (usable)
 BIOS-e820: 000000003ed94000 - 000000003ee4e000 (ACPI NVS)
 BIOS-e820: 000000003ee4e000 - 000000003fea2000 (usable)
 BIOS-e820: 000000003fea2000 - 000000003fee9000 (ACPI NVS)
 BIOS-e820: 000000003fee9000 - 000000003feed000 (usable)
 BIOS-e820: 000000003feed000 - 000000003feff000 (ACPI data)
 BIOS-e820: 000000003feff000 - 000000003ff00000 (usable)
KERNEL supported cpus:
  Intel GenuineIntel
  AMD AuthenticAMD
  Centaur CentaurHauls
console [earlyvga0] enabled
debug: ignoring loglevel setting.
last_pfn =3D 0x3ff00 max_arch_pfn =3D 0x3ffffffff
init_memory_mapping
 0000000000 - 003fe00000 page 2M
 003fe00000 - 003ff00000 page 4k
kernel direct mapping tables up to 3ff00000 @ 8000-b000
last_map_addr: 3ff00000 end: 3ff00000
ACPI: RSDP 000FE020, 0014 (r0 INTEL )
ACPI: RSDT 3FEFDE48, 0050 (r1 INTEL  D975XBX       4B9 MSFT  1000013)
ACPI: FACP 3FEFCF10, 0074 (r1 INTEL  D975XBX       4B9 MSFT  1000013)
ACPI: DSDT 3FEF8010, 3E70 (r1 INTEL  D975XBX       4B9 MSFT  1000013)
ACPI: FACS 3FEDFC40, 0040
ACPI: APIC 3FEFCE10, 0078 (r1 INTEL  D975XBX       4B9 MSFT  1000013)
ACPI: WDDT 3FEF7F90, 0040 (r1 INTEL  D975XBX       4B9 MSFT  1000013)
ACPI: MCFG 3FEF7F10, 003C (r1 INTEL  D975XBX       4B9 MSFT  1000013)
ACPI: ASF! 3FEFCD10, 00A6 (r32 INTEL  D975XBX       4B9 MSFT  1000013)
ACPI: HPET 3FEF7E90, 0038 (r1 INTEL  D975XBX       4B9 MSFT  1000013)
ACPI: SSDT 3FEFDC10, 01BC (r1 INTEL     CpuPm      4B9 MSFT  1000013)
ACPI: SSDT 3FEFDA10, 01B7 (r1 INTEL   Cpu0Ist      4B9 MSFT  1000013)
ACPI: SSDT 3FEFD810, 01B7 (r1 INTEL   Cpu1Ist      4B9 MSFT  1000013)
ACPI: SSDT 3FEFD610, 01B7 (r1 INTEL   Cpu2Ist      4B9 MSFT  1000013)
ACPI: SSDT 3FEFD410, 01B7 (r1 INTEL   Cpu3Ist      4B9 MSFT  1000013)
Entering add_active_range(0, 0x0, 0x9f) 0 entries of 25600 used
Entering add_active_range(0, 0x100, 0x3ed94) 1 entries of 25600 used
Entering add_active_range(0, 0x3ee4e, 0x3fea2) 2 entries of 25600 used
Entering add_active_range(0, 0x3fee9, 0x3feed) 3 entries of 25600 used
Entering add_active_range(0, 0x3feff, 0x3ff00) 4 entries of 25600 used
(5 early reservations) =3D=3D> bootmem
  #0 [0000000000 - 0000001000]   BIOS data page =3D=3D> [0000000000 - 0=
000001000]
  #1 [0000006000 - 0000008000]       TRAMPOLINE =3D=3D> [0000006000 - 0=
000008000]
  #2 [0000200000 - 0001484b34]    TEXT DATA BSS =3D=3D> [0000200000 - 0=
001484b34]
  #3 [000009fc00 - 0000100000]    BIOS reserved =3D=3D> [000009fc00 - 0=
000100000]
  #4 [0000008000 - 0000009000]          PGTABLE =3D=3D> [0000008000 - 0=
000009000]
Zone PFN ranges:
  DMA      0x00000000 -> 0x00001000
  DMA32    0x00001000 -> 0x00100000
  Normal   0x00100000 -> 0x00100000
Movable zone start PFN for each node
early_node_map[5] active PFN ranges
    0: 0x00000000 -> 0x0000009f
    0: 0x00000100 -> 0x0003ed94
    0: 0x0003ee4e -> 0x0003fea2
    0: 0x0003fee9 -> 0x0003feed
    0: 0x0003feff -> 0x0003ff00
On node 0 totalpages: 261516
  DMA zone: 56 pages used for memmap
  DMA zone: 100 pages reserved
  DMA zone: 3843 pages, LIFO batch:0
  DMA32 zone: 3525 pages used for memmap
  DMA32 zone: 253992 pages, LIFO batch:31
  Normal zone: 0 pages used for memmap
  Movable zone: 0 pages used for memmap
ACPI: Local APIC address 0xfee00000
ACPI: LAPIC (acpi_id[0x01] lapic_id[0x00] enabled)
ACPI: LAPIC (acpi_id[0x02] lapic_id[0x01] enabled)
ACPI: LAPIC (acpi_id[0x03] lapic_id[0x82] disabled)
ACPI: LAPIC (acpi_id[0x04] lapic_id[0x83] disabled)
ACPI: LAPIC_NMI (acpi_id[0x01] dfl dfl lint[0x1])
ACPI: LAPIC_NMI (acpi_id[0x02] dfl dfl lint[0x1])
ACPI: IOAPIC (id[0x02] address[0xfec00000] gsi_base[0])
IOAPIC[0]: apic_id 2, version 0, address 0xfec00000, GSI 0-23
ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
ACPI: IRQ0 used by override.
ACPI: IRQ2 used by override.
ACPI: IRQ9 used by override.
Setting APIC routing to flat
ACPI: HPET id: 0x8086a201 base: 0xfed00000
SMP: Allowing 4 CPUs, 2 hotplug CPUs
mapped APIC to ffffffffff5fc000 (        fee00000)
mapped IOAPIC to ffffffffff5fb000 (00000000fec00000)
Allocating PCI resources starting at 40000000 (gap: 3ff00000:c0100000)
PERCPU: Allocating 40256 bytes of per cpu data
NR_CPUS: 4096, nr_cpu_ids: 4, nr_node_ids 512
Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 25=
7835
Kernel command line: root=3D/dev/sda1 earlyprintk=3Dvga console=3DttyS0=
,115200 console=3Dtty 5 profile=3D0 debug initcall_debug apic=3Ddebug a=
pic=3Dverbose ignore_loglevel sysrq_always_enabled pci=3Dnomsi
kernel profiling enabled (shift: 0)
debug: sysrq always enabled.
Initializing CPU#0
PID hash table entries: 4096 (order: 12, 32768 bytes)
TSC calibrated against PIT
Detected 2933.406 MHz processor.
Console: colour VGA+ 80x25
console handover: boot [earlyvga0] -> real [tty0]
console [ttyS0] enabled
Dentry cache hash table entries: 131072 (order: 8, 1048576 bytes)
Inode-cache hash table entries: 65536 (order: 7, 524288 bytes)
Checking aperture...
No AGP bridge found
Memory: 978020k/1047552k available (8071k kernel code, 67476k reserved,=
 6822k data, 540k init)
CPA: page pool initialized 1 of 1 pages preallocated
hpet clockevent registered
Calibrating delay loop (skipped), value calculated using timer frequenc=
y.. <6>5866.81 BogoMIPS (lpj=3D11733624)
Security Framework initialized
SELinux:  Initializing.
SELinux:  Starting in permissive mode
Mount-cache hash table entries: 256
CPU: L1 I cache: 32K, L1 D cache: 32K
CPU: L2 cache: 4096K
CPU: Physical Processor ID: 0
CPU: Processor Core ID: 0
CPU0: Thermal monitoring enabled (TM2)
using mwait in idle threads.
ACPI: Core revision 20080609
enabled ExtINT on CPU#0
ENABLING IO-APIC IRQs
init IO_APIC IRQs
 IO-APIC (apicid-pin) 2-0 not connected.
IOAPIC[0]: Set routing entry (2-1 -> 0x31 -> IRQ 1 Mode:0 Active:0)
IOAPIC[0]: Set routing entry (2-2 -> 0x30 -> IRQ 0 Mode:0 Active:0)
IOAPIC[0]: Set routing entry (2-3 -> 0x33 -> IRQ 3 Mode:0 Active:0)
IOAPIC[0]: Set routing entry (2-4 -> 0x34 -> IRQ 4 Mode:0 Active:0)
IOAPIC[0]: Set routing entry (2-5 -> 0x35 -> IRQ 5 Mode:0 Active:0)
IOAPIC[0]: Set routing entry (2-6 -> 0x36 -> IRQ 6 Mode:0 Active:0)
IOAPIC[0]: Set routing entry (2-7 -> 0x37 -> IRQ 7 Mode:0 Active:0)
IOAPIC[0]: Set routing entry (2-8 -> 0x38 -> IRQ 8 Mode:0 Active:0)
IOAPIC[0]: Set routing entry (2-9 -> 0x39 -> IRQ 9 Mode:1 Active:0)
IOAPIC[0]: Set routing entry (2-10 -> 0x3a -> IRQ 10 Mode:0 Active:0)
IOAPIC[0]: Set routing entry (2-11 -> 0x3b -> IRQ 11 Mode:0 Active:0)
IOAPIC[0]: Set routing entry (2-12 -> 0x3c -> IRQ 12 Mode:0 Active:0)
IOAPIC[0]: Set routing entry (2-13 -> 0x3d -> IRQ 13 Mode:0 Active:0)
IOAPIC[0]: Set routing entry (2-14 -> 0x3e -> IRQ 14 Mode:0 Active:0)
IOAPIC[0]: Set routing entry (2-15 -> 0x3f -> IRQ 15 Mode:0 Active:0)
 IO-APIC (apicid-pin) 2-16, 2-17, 2-18, 2-19, 2-20, 2-21, 2-22, 2-23 no=
t connected.
=2E.TIMER: vector=3D0x30 apic1=3D0 pin1=3D2 apic2=3D-1 pin2=3D-1
CPU0: Intel(R) Core(TM)2 CPU         E6800  @ 2.93GHz stepping 05
Using local APIC timer interrupts.
APIC timer calibration result 16667083
Detected 16.667 MHz APIC timer.
Booting processor 1/1 ip 6000
Initializing CPU#1
masked ExtINT on CPU#1
Calibrating delay using timer specific routine.. <6>5866.88 BogoMIPS (l=
pj=3D11733771)
CPU: L1 I cache: 32K, L1 D cache: 32K
CPU: L2 cache: 4096K
CPU: Physical Processor ID: 0
CPU: Processor Core ID: 1
CPU1: Thermal monitoring enabled (TM2)
CPU1: Intel(R) Core(TM)2 CPU         E6800  @ 2.93GHz stepping 05
checking TSC synchronization [CPU#0 -> CPU#1]: passed.
Brought up 2 CPUs
Total of 2 processors activated (11733.69 BogoMIPS).
calling  init_cpufreq_transition_notifier_list+0x0/0x1b
initcall init_cpufreq_transition_notifier_list+0x0/0x1b returned 0 afte=
r 0 msecs
calling  net_ns_init+0x0/0x133
net_namespace: 1120 bytes
initcall net_ns_init+0x0/0x133 returned 0 after 0 msecs
calling  cpufreq_tsc+0x0/0x16
initcall cpufreq_tsc+0x0/0x16 returned 0 after 0 msecs
calling  init_smp_flush+0x0/0x51
initcall init_smp_flush+0x0/0x51 returned 0 after 0 msecs
calling  print_banner+0x0/0xf
Booting paravirtualized kernel on bare hardware
initcall print_banner+0x0/0xf returned 0 after 3 msecs
calling  sysctl_init+0x0/0x32
initcall sysctl_init+0x0/0x32 returned 0 after 0 msecs
calling  ksysfs_init+0x0/0xb9
initcall ksysfs_init+0x0/0xb9 returned 0 after 0 msecs
calling  init_jiffies_clocksource+0x0/0xc
initcall init_jiffies_clocksource+0x0/0xc returned 0 after 0 msecs
calling  pm_init+0x0/0x35
initcall pm_init+0x0/0x35 returned 0 after 0 msecs
calling  filelock_init+0x0/0x2e
initcall filelock_init+0x0/0x2e returned 0 after 0 msecs
calling  init_script_binfmt+0x0/0xc
initcall init_script_binfmt+0x0/0xc returned 0 after 0 msecs
calling  init_elf_binfmt+0x0/0xc
initcall init_elf_binfmt+0x0/0xc returned 0 after 0 msecs
calling  init_compat_elf_binfmt+0x0/0xc
initcall init_compat_elf_binfmt+0x0/0xc returned 0 after 0 msecs
calling  debugfs_init+0x0/0x47
initcall debugfs_init+0x0/0x47 returned 0 after 0 msecs
calling  securityfs_init+0x0/0x47
initcall securityfs_init+0x0/0x47 returned 0 after 0 msecs
calling  random32_init+0x0/0x5f
initcall random32_init+0x0/0x5f returned 0 after 0 msecs
calling  cpufreq_core_init+0x0/0x84
initcall cpufreq_core_init+0x0/0x84 returned 0 after 0 msecs
calling  cpuidle_init+0x0/0x36
initcall cpuidle_init+0x0/0x36 returned 0 after 0 msecs
calling  virtio_init+0x0/0x26
initcall virtio_init+0x0/0x26 returned 0 after 0 msecs
calling  sock_init+0x0/0x5e
initcall sock_init+0x0/0x5e returned 0 after 0 msecs
calling  netpoll_init+0x0/0x2c
initcall netpoll_init+0x0/0x2c returned 0 after 0 msecs
calling  netlink_proto_init+0x0/0x13e
NET: Registered protocol family 16
initcall netlink_proto_init+0x0/0x13e returned 0 after 3 msecs
calling  bdi_class_init+0x0/0x3d
initcall bdi_class_init+0x0/0x3d returned 0 after 0 msecs
calling  kobject_uevent_init+0x0/0x45
initcall kobject_uevent_init+0x0/0x45 returned 0 after 0 msecs
calling  pcibus_class_init+0x0/0xc
initcall pcibus_class_init+0x0/0xc returned 0 after 0 msecs
calling  pci_driver_init+0x0/0xc
initcall pci_driver_init+0x0/0xc returned 0 after 0 msecs
calling  lcd_class_init+0x0/0x49
initcall lcd_class_init+0x0/0x49 returned 0 after 0 msecs
calling  backlight_class_init+0x0/0x4a
initcall backlight_class_init+0x0/0x4a returned 0 after 0 msecs
calling  dock_init+0x0/0x5c
No dock devices found.
initcall dock_init+0x0/0x5c returned 0 after 0 msecs
calling  tty_class_init+0x0/0x2a
initcall tty_class_init+0x0/0x2a returned 0 after 0 msecs
calling  vtconsole_class_init+0x0/0xaf
initcall vtconsole_class_init+0x0/0xaf returned 0 after 0 msecs
calling  enable_pci_io_ecs+0x0/0x2e
initcall enable_pci_io_ecs+0x0/0x2e returned 0 after 0 msecs
calling  early_fill_mp_bus_info+0x0/0x763
initcall early_fill_mp_bus_info+0x0/0x763 returned 0 after 0 msecs
calling  arch_kdebugfs_init+0x0/0x3
initcall arch_kdebugfs_init+0x0/0x3 returned 0 after 0 msecs
calling  ffh_cstate_init+0x0/0x31
initcall ffh_cstate_init+0x0/0x31 returned 0 after 0 msecs
calling  acpi_pci_init+0x0/0x3b
ACPI: bus type pci registered
initcall acpi_pci_init+0x0/0x3b returned 0 after 0 msecs
calling  init_acpi_device_notify+0x0/0x4b
initcall init_acpi_device_notify+0x0/0x4b returned 0 after 0 msecs
calling  pci_arch_init+0x0/0x44
PCI: MCFG configuration 0: base f0000000 segment 0 buses 0 - 127
PCI: Not using MMCONFIG.
PCI: Using configuration type 1 for base access
initcall pci_arch_init+0x0/0x44 returned 0 after 11 msecs
calling  topology_init+0x0/0x31
initcall topology_init+0x0/0x31 returned 0 after 0 msecs
calling  param_sysfs_init+0x0/0x1c1
initcall param_sysfs_init+0x0/0x1c1 returned 0 after 11 msecs
calling  pm_sysrq_init+0x0/0x19
initcall pm_sysrq_init+0x0/0x19 returned 0 after 0 msecs
calling  readahead_init+0x0/0x2e
initcall readahead_init+0x0/0x2e returned 0 after 3 msecs
calling  init_bio+0x0/0xc0
initcall init_bio+0x0/0xc0 returned 0 after 0 msecs
calling  integrity_init+0x0/0x35
initcall integrity_init+0x0/0x35 returned 0 after 0 msecs
calling  blk_settings_init+0x0/0x25
initcall blk_settings_init+0x0/0x25 returned 0 after 0 msecs
calling  blk_ioc_init+0x0/0x2a
initcall blk_ioc_init+0x0/0x2a returned 0 after 0 msecs
calling  genhd_device_init+0x0/0x36
initcall genhd_device_init+0x0/0x36 returned 0 after 0 msecs
calling  blk_dev_integrity_init+0x0/0x2a
initcall blk_dev_integrity_init+0x0/0x2a returned 0 after 0 msecs
calling  pci_slot_init+0x0/0x45
initcall pci_slot_init+0x0/0x45 returned 0 after 0 msecs
calling  acpi_init+0x0/0x21b
ACPI: EC: Look up EC in DSDT
ACPI: Interpreter enabled
ACPI: (supports S0 S5)
ACPI: Using IOAPIC for interrupt routing
PCI: MCFG configuration 0: base f0000000 segment 0 buses 0 - 127
PCI: BIOS Bug: MCFG area at f0000000 is not reserved in ACPI motherboar=
d resources
PCI: Not using MMCONFIG.
initcall acpi_init+0x0/0x21b returned 0 after 26 msecs
calling  acpi_scan_init+0x0/0x113
initcall acpi_scan_init+0x0/0x113 returned 0 after 3 msecs
calling  acpi_ec_init+0x0/0x61
initcall acpi_ec_init+0x0/0x61 returned 0 after 0 msecs
calling  acpi_pci_root_init+0x0/0x28
ACPI: PCI Root Bridge [PCI0] (0000:00)
pci 0000:00:01.0: PME# supported from D0 D3hot D3cold
pci 0000:00:01.0: PME# disabled
pci 0000:00:1b.0: PME# supported from D0 D3hot D3cold
pci 0000:00:1b.0: PME# disabled
pci 0000:00:1c.0: PME# supported from D0 D3hot D3cold
pci 0000:00:1c.0: PME# disabled
pci 0000:00:1c.4: PME# supported from D0 D3hot D3cold
pci 0000:00:1c.4: PME# disabled
pci 0000:00:1c.5: PME# supported from D0 D3hot D3cold
pci 0000:00:1c.5: PME# disabled
pci 0000:00:1d.7: PME# supported from D0 D3hot D3cold
pci 0000:00:1d.7: PME# disabled
pci 0000:00:1f.2: PME# supported from D3hot
pci 0000:00:1f.2: PME# disabled
pci 0000:01:00.0: supports D1
pci 0000:01:00.0: supports D2
pci 0000:01:00.1: supports D1
pci 0000:01:00.1: supports D2
pci 0000:02:00.0: supports D1
pci 0000:02:00.0: supports D2
pci 0000:02:00.0: PME# supported from D0 D1 D2
pci 0000:02:00.0: PME# disabled
pci 0000:04:00.0: PME# supported from D0 D3hot D3cold
pci 0000:04:00.0: PME# disabled
pci 0000:05:04.0: supports D1
pci 0000:05:04.0: supports D2
pci 0000:05:04.0: PME# supported from D0 D1 D2 D3hot
pci 0000:05:04.0: PME# disabled
pci 0000:05:05.0: supports D1
pci 0000:05:05.0: supports D2
pci 0000:00:1e.0: transparent bridge
bus 00 -> node 0
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.P32_._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PEX0._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PEX4._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PEX5._PRT]
initcall acpi_pci_root_init+0x0/0x28 returned 0 after 110 msecs
calling  acpi_pci_link_init+0x0/0x48
ACPI: PCI Interrupt Link [LNKA] (IRQs 3 4 5 7 9 10 *11 12)
ACPI: PCI Interrupt Link [LNKB] (IRQs 3 4 5 7 9 *10 11 12)
ACPI: PCI Interrupt Link [LNKC] (IRQs 3 4 5 7 9 *10 11 12)
ACPI: PCI Interrupt Link [LNKD] (IRQs 3 4 5 7 *9 10 11 12)
ACPI: PCI Interrupt Link [LNKE] (IRQs 3 4 5 7 9 10 11 12) *0, disabled.
ACPI: PCI Interrupt Link [LNKF] (IRQs 3 4 5 7 9 10 11 12) *0, disabled.
ACPI: PCI Interrupt Link [LNKG] (IRQs 3 4 5 7 *9 10 11 12)
ACPI: PCI Interrupt Link [LNKH] (IRQs 3 4 5 7 9 10 *11 12)
initcall acpi_pci_link_init+0x0/0x48 returned 0 after 49 msecs
calling  acpi_power_init+0x0/0x77
initcall acpi_power_init+0x0/0x77 returned 0 after 0 msecs
calling  acpi_system_init+0x0/0x264
initcall acpi_system_init+0x0/0x264 returned 0 after 0 msecs
calling  pnp_init+0x0/0x1f
Linux Plug and Play Support v0.97 (c) Adam Belay
initcall pnp_init+0x0/0x1f returned 0 after 3 msecs
calling  pnpacpi_init+0x0/0x8c
pnp: PnP ACPI init
ACPI: bus type pnp registered
IOAPIC[0]: Set routing entry (2-8 -> 0x38 -> IRQ 8 Mode:0 Active:0)
IOAPIC[0]: Set routing entry (2-13 -> 0x3d -> IRQ 13 Mode:0 Active:0)
IOAPIC[0]: Set routing entry (2-6 -> 0x36 -> IRQ 6 Mode:0 Active:0)
IOAPIC[0]: Set routing entry (2-7 -> 0x37 -> IRQ 7 Mode:0 Active:0)
IOAPIC[0]: Set routing entry (2-12 -> 0x3c -> IRQ 12 Mode:0 Active:0)
IOAPIC[0]: Set routing entry (2-1 -> 0x31 -> IRQ 1 Mode:0 Active:0)
IOAPIC[0]: Set routing entry (2-4 -> 0x34 -> IRQ 4 Mode:0 Active:0)
pnp: PnP ACPI: found 13 devices
ACPI: ACPI bus type pnp unregistered
initcall pnpacpi_init+0x0/0x8c returned 0 after 38 msecs
calling  misc_init+0x0/0x8e
initcall misc_init+0x0/0x8e returned 0 after 0 msecs
calling  cn_init+0x0/0xee
initcall cn_init+0x0/0xee returned 0 after 0 msecs
calling  tifm_init+0x0/0x6d
initcall tifm_init+0x0/0x6d returned 0 after 0 msecs
calling  phy_init+0x0/0x27
initcall phy_init+0x0/0x27 returned 0 after 0 msecs
calling  init_dvbdev+0x0/0xaf
initcall init_dvbdev+0x0/0xaf returned 0 after 0 msecs
calling  init_scsi+0x0/0x72
SCSI subsystem initialized
initcall init_scsi+0x0/0x72 returned 0 after 3 msecs
calling  ata_init+0x0/0x32a
libata version 3.00 loaded.
initcall ata_init+0x0/0x32a returned 0 after 3 msecs
calling  spi_init+0x0/0x73
initcall spi_init+0x0/0x73 returned 0 after 0 msecs
calling  init_pcmcia_cs+0x0/0x27
initcall init_pcmcia_cs+0x0/0x27 returned 0 after 0 msecs
calling  usb_init+0x0/0x104
usbcore: registered new interface driver usbfs
usbcore: registered new interface driver hub
usbcore: registered new device driver usb
initcall usb_init+0x0/0x104 returned 0 after 11 msecs
calling  serio_init+0x0/0x8b
initcall serio_init+0x0/0x8b returned 0 after 0 msecs
calling  gameport_init+0x0/0x8b
initcall gameport_init+0x0/0x8b returned 0 after 0 msecs
calling  input_init+0x0/0xfc
initcall input_init+0x0/0xfc returned 0 after 0 msecs
calling  i2c_init+0x0/0x55
initcall i2c_init+0x0/0x55 returned 0 after 0 msecs
calling  power_supply_class_init+0x0/0x34
initcall power_supply_class_init+0x0/0x34 returned 0 after 0 msecs
calling  thermal_init+0x0/0x2f
initcall thermal_init+0x0/0x2f returned 0 after 0 msecs
calling  mmc_init+0x0/0x65
initcall mmc_init+0x0/0x65 returned 0 after 0 msecs
calling  leds_init+0x0/0x2a
initcall leds_init+0x0/0x2a returned 0 after 0 msecs
calling  dma_bus_init+0x0/0x2b
initcall dma_bus_init+0x0/0x2b returned 0 after 0 msecs
calling  ac97_bus_init+0x0/0xc
initcall ac97_bus_init+0x0/0xc returned 0 after 0 msecs
calling  pci_subsys_init+0x0/0x116
PCI: Using ACPI for IRQ routing
number of MP IRQ sources: 15.
number of IO-APIC #2 registers: 24.
testing the IO APIC.......................

IO APIC #2......
=2E... register #00: 00000000
=2E......    : physical APIC id: 00
=2E... register #01: 00170020
=2E......     : max redirection entries: 0017
=2E......     : PRQ implemented: 0
=2E......     : IO APIC version: 0020
=2E... register #02: 00170020
=2E......     : arbitration: 00
=2E... IRQ redirection table:
 NR Dst Mask Trig IRR Pol Stat Dmod Deli Vect:  =20
 00 000 1    0    0   0   0    0    0    00
 01 003 0    0    0   0   0    1    1    31
 02 003 0    0    0   0   0    1    1    30
 03 003 0    0    0   0   0    1    1    33
 04 003 0    0    0   0   0    1    1    34
 05 003 0    0    0   0   0    1    1    35
 06 003 0    0    0   0   0    1    1    36
 07 003 0    0    0   0   0    1    1    37
 08 003 0    0    0   0   0    1    1    38
 09 003 0    1    0   0   0    1    1    39
 0a 003 0    0    0   0   0    1    1    3A
 0b 003 0    0    0   0   0    1    1    3B
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
initcall pci_subsys_init+0x0/0x116 returned 0 after 164 msecs
calling  proto_init+0x0/0x2e
initcall proto_init+0x0/0x2e returned 0 after 0 msecs
calling  net_dev_init+0x0/0x158
initcall net_dev_init+0x0/0x158 returned 0 after 0 msecs
calling  neigh_init+0x0/0x71
initcall neigh_init+0x0/0x71 returned 0 after 0 msecs
calling  fib_rules_init+0x0/0x9c
initcall fib_rules_init+0x0/0x9c returned 0 after 0 msecs
calling  genl_init+0x0/0xce
initcall genl_init+0x0/0xce returned 0 after 15 msecs
calling  cipso_v4_init+0x0/0x67
initcall cipso_v4_init+0x0/0x67 returned 0 after 0 msecs
calling  wireless_nlevent_init+0x0/0x2c
initcall wireless_nlevent_init+0x0/0x2c returned 0 after 0 msecs
calling  cfg80211_init+0x0/0x55
initcall cfg80211_init+0x0/0x55 returned 0 after 11 msecs
calling  ieee80211_init+0x0/0xd
initcall ieee80211_init+0x0/0xd returned 0 after 0 msecs
calling  netlbl_init+0x0/0x83
NetLabel: Initializing
NetLabel:  domain hash size =3D 128
NetLabel:  protocols =3D UNLABELED CIPSOv4
NetLabel:  unlabeled traffic allowed by default
initcall netlbl_init+0x0/0x83 returned 0 after 11 msecs
calling  sysctl_init+0x0/0x2f
initcall sysctl_init+0x0/0x2f returned 0 after 0 msecs
calling  pci_iommu_init+0x0/0x12
PCI-GART: No AMD northbridge found.
initcall pci_iommu_init+0x0/0x12 returned 0 after 3 msecs
calling  hpet_late_init+0x0/0xfc
hpet0: at MMIO 0xfed00000, IRQs 2, 8, 0
hpet0: 3 64-bit timers, 14318180 Hz
initcall hpet_late_init+0x0/0xfc returned 0 after 7 msecs
calling  clocksource_done_booting+0x0/0xd
initcall clocksource_done_booting+0x0/0xd<7>Switched to high resolution=
 mode on CPU 0
Switched to high resolution mode on CPU 1
 returned 0 after 0 msecs
calling  tracer_alloc_buffers+0x0/0x4ec
tracer: 1286 pages allocated for 65536 entries of 80 bytes
   actual entries 65586
initcall tracer_alloc_buffers+0x0/0x4ec returned 0 after 8 msecs
calling  init_pipe_fs+0x0/0x42
initcall init_pipe_fs+0x0/0x42 returned 0 after 0 msecs
calling  init_mnt_writers+0x0/0x58
initcall init_mnt_writers+0x0/0x58 returned 0 after 0 msecs
calling  anon_inode_init+0x0/0x10b
initcall anon_inode_init+0x0/0x10b returned 0 after 0 msecs
calling  acpi_event_init+0x0/0x52
initcall acpi_event_init+0x0/0x52 returned 0 after 10 msecs
calling  pnp_system_init+0x0/0xc
system 00:01: iomem range 0xf0000000-0xf3ffffff has been reserved
system 00:01: iomem range 0xfed13000-0xfed13fff has been reserved
system 00:01: iomem range 0xfed14000-0xfed17fff has been reserved
system 00:01: iomem range 0xfed18000-0xfed18fff has been reserved
system 00:01: iomem range 0xfed19000-0xfed19fff has been reserved
system 00:01: iomem range 0xfed1c000-0xfed1ffff has been reserved
system 00:01: iomem range 0xfed20000-0xfed3ffff has been reserved
system 00:01: iomem range 0xfed45000-0xfed99fff has been reserved
system 00:01: iomem range 0xc0000-0xdffff has been reserved
system 00:01: iomem range 0xe0000-0xfffff could not be reserved
system 00:06: ioport range 0x500-0x53f has been reserved
system 00:06: ioport range 0x400-0x47f has been reserved
system 00:06: ioport range 0x680-0x6ff has been reserved
initcall pnp_system_init+0x0/0xc returned 0 after 70 msecs
calling  chr_dev_init+0x0/0x9a
initcall chr_dev_init+0x0/0x9a returned 0 after 0 msecs
calling  firmware_class_init+0x0/0x68
initcall firmware_class_init+0x0/0x68 returned 0 after 0 msecs
calling  loopback_init+0x0/0xc
initcall loopback_init+0x0/0xc returned 0 after 0 msecs
calling  cpufreq_gov_performance_init+0x0/0xc
initcall cpufreq_gov_performance_init+0x0/0xc returned 0 after 0 msecs
calling  cpufreq_gov_dbs_init+0x0/0x47
initcall cpufreq_gov_dbs_init+0x0/0x47 returned 0 after 0 msecs
calling  ssb_modinit+0x0/0x4b
initcall ssb_modinit+0x0/0x4b returned 0 after 0 msecs
calling  pcibios_assign_resources+0x0/0x86
pci 0000:00:01.0: PCI bridge, secondary bus 0000:01
pci 0000:00:01.0:   IO window: 0x3000-0x3fff
pci 0000:00:01.0:   MEM window: 0x50300000-0x503fffff
pci 0000:00:01.0:   PREFETCH window: 0x00000040000000-0x0000004fffffff
pci 0000:00:1c.0: PCI bridge, secondary bus 0000:02
pci 0000:00:1c.0:   IO window: disabled
pci 0000:00:1c.0:   MEM window: 0x50200000-0x502fffff
pci 0000:00:1c.0:   PREFETCH window: disabled
pci 0000:00:1c.4: PCI bridge, secondary bus 0000:03
pci 0000:00:1c.4:   IO window: disabled
pci 0000:00:1c.4:   MEM window: disabled
pci 0000:00:1c.4:   PREFETCH window: disabled
pci 0000:00:1c.5: PCI bridge, secondary bus 0000:04
pci 0000:00:1c.5:   IO window: 0x2000-0x2fff
pci 0000:00:1c.5:   MEM window: 0x50100000-0x501fffff
pci 0000:00:1c.5:   PREFETCH window: disabled
pci 0000:00:1e.0: PCI bridge, secondary bus 0000:05
pci 0000:00:1e.0:   IO window: 0x1000-0x1fff
pci 0000:00:1e.0:   MEM window: 0x50000000-0x500fffff
pci 0000:00:1e.0:   PREFETCH window: disabled
IOAPIC[0]: Set routing entry (2-16 -> 0x49 -> IRQ 16 Mode:1 Active:1)
pci 0000:00:01.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
PCI: Setting latency timer of device 0000:00:01.0 to 64
IOAPIC[0]: Set routing entry (2-17 -> 0x51 -> IRQ 17 Mode:1 Active:1)
pci 0000:00:1c.0: PCI INT A -> GSI 17 (level, low) -> IRQ 17
PCI: Setting latency timer of device 0000:00:1c.0 to 64
pci 0000:00:1c.4: PCI INT A -> GSI 17 (level, low) -> IRQ 17
PCI: Setting latency timer of device 0000:00:1c.4 to 64
pci 0000:00:1c.5: PCI INT B -> GSI 16 (level, low) -> IRQ 16
PCI: Setting latency timer of device 0000:00:1c.5 to 64
PCI: Setting latency timer of device 0000:00:1e.0 to 64
initcall pcibios_assign_resources+0x0/0x86 returned 0 after 147 msecs
calling  inet_init+0x0/0x1df
NET: Registered protocol family 2
IP route cache hash table entries: 32768 (order: 6, 262144 bytes)
TCP established hash table entries: 131072 (order: 9, 2097152 bytes)
TCP bind hash table entries: 65536 (order: 8, 1048576 bytes)
TCP: Hash tables configured (established 131072 bind 65536)
TCP reno registered
initcall inet_init+0x0/0x1df returned 0 after 75 msecs
calling  af_unix_init+0x0/0x4b
NET: Registered protocol family 1
initcall af_unix_init+0x0/0x4b returned 0 after 3 msecs
calling  default_rootfs+0x0/0x61
initcall default_rootfs+0x0/0x61 returned 0 after 0 msecs
calling  i8259A_init_sysfs+0x0/0x23
initcall i8259A_init_sysfs+0x0/0x23 returned 0 after 0 msecs
calling  vsyscall_init+0x0/0x6c
initcall vsyscall_init+0x0/0x6c returned 0 after 0 msecs
calling  sbf_init+0x0/0xd5
initcall sbf_init+0x0/0xd5 returned 0 after 0 msecs
calling  i8237A_init_sysfs+0x0/0x23
initcall i8237A_init_sysfs+0x0/0x23 returned 0 after 0 msecs
calling  add_rtc_cmos+0x0/0x1d
initcall add_rtc_cmos+0x0/0x1d returned 0 after 0 msecs
calling  cache_sysfs_init+0x0/0x55
initcall cache_sysfs_init+0x0/0x55 returned 0 after 0 msecs
calling  mce_init_device+0x0/0x7f
initcall mce_init_device+0x0/0x7f returned 0 after 0 msecs
calling  periodic_mcheck_init+0x0/0x3f
initcall periodic_mcheck_init+0x0/0x3f returned 0 after 0 msecs
calling  thermal_throttle_init_device+0x0/0x7b
initcall thermal_throttle_init_device+0x0/0x7b returned 0 after 0 msecs
calling  microcode_init+0x0/0xaf
IA-32 Microcode Update Driver: v1.14a <tigran@aivazian.fsnet.co.uk>
initcall microcode_init+0x0/0xaf returned 0 after 5 msecs
calling  init_lapic_sysfs+0x0/0x2f
initcall init_lapic_sysfs+0x0/0x2f returned 0 after 0 msecs
calling  ioapic_init_sysfs+0x0/0x99
initcall ioapic_init_sysfs+0x0/0x99 returned 0 after 0 msecs
calling  uv_ptc_init+0x0/0x75
initcall uv_ptc_init+0x0/0x75 returned 0 after 0 msecs
calling  uv_bau_init+0x0/0x5d0
initcall uv_bau_init+0x0/0x5d0 returned 0 after 0 msecs
calling  audit_classes_init+0x0/0xaf
initcall audit_classes_init+0x0/0xaf returned 0 after 0 msecs
calling  aes_init+0x0/0xc
initcall aes_init+0x0/0xc returned 0 after 0 msecs
calling  init+0x0/0xc
initcall init+0x0/0xc returned 0 after 0 msecs
calling  init_vdso_vars+0x0/0x224
initcall init_vdso_vars+0x0/0x224 returned 0 after 0 msecs
calling  ia32_binfmt_init+0x0/0x14
initcall ia32_binfmt_init+0x0/0x14 returned 0 after 0 msecs
calling  sysenter_setup+0x0/0x2ac
initcall sysenter_setup+0x0/0x2ac returned 0 after 0 msecs
calling  init_aout_binfmt+0x0/0xc
initcall init_aout_binfmt+0x0/0xc returned 0 after 0 msecs
calling  create_proc_profile+0x0/0x319
initcall create_proc_profile+0x0/0x319 returned 0 after 0 msecs
calling  ioresources_init+0x0/0x3c
initcall ioresources_init+0x0/0x3c returned 0 after 0 msecs
calling  uid_cache_init+0x0/0x6f
initcall uid_cache_init+0x0/0x6f returned 0 after 0 msecs
calling  init_posix_timers+0x0/0xa6
initcall init_posix_timers+0x0/0xa6 returned 0 after 0 msecs
calling  init_posix_cpu_timers+0x0/0xc6
initcall init_posix_cpu_timers+0x0/0xc6 returned 0 after 0 msecs
calling  nsproxy_cache_init+0x0/0x2d
initcall nsproxy_cache_init+0x0/0x2d returned 0 after 0 msecs
calling  timekeeping_init_device+0x0/0x23
initcall timekeeping_init_device+0x0/0x23 returned 0 after 0 msecs
calling  init_clocksource_sysfs+0x0/0x51
initcall init_clocksource_sysfs+0x0/0x51 returned 0 after 0 msecs
calling  init_timer_list_procfs+0x0/0x2c
initcall init_timer_list_procfs+0x0/0x2c returned 0 after 0 msecs
calling  futex_init+0x0/0x67
initcall futex_init+0x0/0x67 returned 0 after 0 msecs
calling  proc_dma_init+0x0/0x22
initcall proc_dma_init+0x0/0x22 returned 0 after 0 msecs
calling  kallsyms_init+0x0/0x25
initcall kallsyms_init+0x0/0x25 returned 0 after 0 msecs
calling  pid_namespaces_init+0x0/0x2d
initcall pid_namespaces_init+0x0/0x2d returned 0 after 0 msecs
calling  audit_init+0x0/0x126
audit: initializing netlink socket (disabled)
type=3D2000 audit(1216650963.392:1): initialized
initcall audit_init+0x0/0x126 returned 0 after 8 msecs
calling  relay_init+0x0/0x14
initcall relay_init+0x0/0x14 returned 0 after 0 msecs
calling  utsname_sysctl_init+0x0/0x14
initcall utsname_sysctl_init+0x0/0x14 returned 0 after 0 msecs
calling  init_stack_trace+0x0/0xc
Testing tracer sysprof: PASSED
initcall init_stack_trace+0x0/0xc returned 0 after 98 msecs
calling  init_per_zone_pages_min+0x0/0x45
initcall init_per_zone_pages_min+0x0/0x45 returned 0 after 0 msecs
calling  pdflush_init+0x0/0x13
initcall pdflush_init+0x0/0x13 returned 0 after 0 msecs
calling  kswapd_init+0x0/0x5e
initcall kswapd_init+0x0/0x5e returned 0 after 0 msecs
calling  setup_vmstat+0x0/0x42
initcall setup_vmstat+0x0/0x42 returned 0 after 0 msecs
calling  init_tmpfs+0x0/0x3d
initcall init_tmpfs+0x0/0x3d returned 0 after 0 msecs
calling  fasync_init+0x0/0x2a
initcall fasync_init+0x0/0x2a returned 0 after 0 msecs
calling  aio_setup+0x0/0x6e
initcall aio_setup+0x0/0x6e returned 0 after 0 msecs
calling  inotify_setup+0x0/0xd
initcall inotify_setup+0x0/0xd returned 0 after 0 msecs
calling  inotify_user_setup+0x0/0xb8
initcall inotify_user_setup+0x0/0xb8 returned 0 after 0 msecs
calling  init_sys32_ioctl+0x0/0x85
initcall init_sys32_ioctl+0x0/0x85 returned 0 after 0 msecs
calling  init_mbcache+0x0/0x14
initcall init_mbcache+0x0/0x14 returned 0 after 0 msecs
calling  dquot_init+0x0/0xde
VFS: Disk quotas dquot_6.5.1
Dquot-cache hash table entries: 512 (order 0, 4096 bytes)
initcall dquot_init+0x0/0xde returned 0 after 7 msecs
calling  init_v2_quota_format+0x0/0xc
initcall init_v2_quota_format+0x0/0xc returned 0 after 0 msecs
calling  dnotify_init+0x0/0x2a
initcall dnotify_init+0x0/0x2a returned 0 after 0 msecs
calling  configfs_init+0x0/0xa9
initcall configfs_init+0x0/0xa9 returned 0 after 0 msecs
calling  init_devpts_fs+0x0/0x35
initcall init_devpts_fs+0x0/0x35 returned 0 after 0 msecs
calling  init_ext3_fs+0x0/0x60
initcall init_ext3_fs+0x0/0x60 returned 0 after 0 msecs
calling  journal_init+0x0/0xc5
initcall journal_init+0x0/0xc5 returned 0 after 0 msecs
calling  init_ext2_fs+0x0/0x60
initcall init_ext2_fs+0x0/0x60 returned 0 after 0 msecs
calling  init_ramfs_fs+0x0/0xc
initcall init_ramfs_fs+0x0/0xc returned 0 after 0 msecs
calling  init_fat_fs+0x0/0x45
initcall init_fat_fs+0x0/0x45 returned 0 after 0 msecs
calling  init_msdos_fs+0x0/0xc
initcall init_msdos_fs+0x0/0xc returned 0 after 0 msecs
calling  init_vfat_fs+0x0/0xc
initcall init_vfat_fs+0x0/0xc returned 0 after 0 msecs
calling  init_iso9660_fs+0x0/0x50
initcall init_iso9660_fs+0x0/0x50 returned 0 after 0 msecs
calling  init_hfsplus_fs+0x0/0x53
initcall init_hfsplus_fs+0x0/0x53 returned 0 after 0 msecs
calling  init_hfs_fs+0x0/0x53
initcall init_hfs_fs+0x0/0x53 returned 0 after 0 msecs
calling  vxfs_init+0x0/0x4f
initcall vxfs_init+0x0/0x4f returned 0 after 0 msecs
calling  init_nls_cp437+0x0/0xc
initcall init_nls_cp437+0x0/0xc returned 0 after 0 msecs
calling  init_nls_cp775+0x0/0xc
initcall init_nls_cp775+0x0/0xc returned 0 after 0 msecs
calling  init_nls_cp850+0x0/0xc
initcall init_nls_cp850+0x0/0xc returned 0 after 0 msecs
calling  init_nls_cp852+0x0/0xc
initcall init_nls_cp852+0x0/0xc returned 0 after 0 msecs
calling  init_nls_cp855+0x0/0xc
initcall init_nls_cp855+0x0/0xc returned 0 after 0 msecs
calling  init_nls_cp857+0x0/0xc
initcall init_nls_cp857+0x0/0xc returned 0 after 0 msecs
calling  init_nls_cp860+0x0/0xc
initcall init_nls_cp860+0x0/0xc returned 0 after 0 msecs
calling  init_nls_cp863+0x0/0xc
initcall init_nls_cp863+0x0/0xc returned 0 after 0 msecs
calling  init_nls_cp874+0x0/0xc
initcall init_nls_cp874+0x0/0xc returned 0 after 0 msecs
calling  init_nls_cp932+0x0/0xc
initcall init_nls_cp932+0x0/0xc returned 0 after 0 msecs
calling  init_nls_euc_jp+0x0/0x4a
initcall init_nls_euc_jp+0x0/0x4a returned 0 after 0 msecs
calling  init_nls_cp936+0x0/0xc
initcall init_nls_cp936+0x0/0xc returned 0 after 0 msecs
calling  init_nls_ascii+0x0/0xc
initcall init_nls_ascii+0x0/0xc returned 0 after 0 msecs
calling  init_nls_iso8859_1+0x0/0xc
initcall init_nls_iso8859_1+0x0/0xc returned 0 after 0 msecs
calling  init_nls_iso8859_5+0x0/0xc
initcall init_nls_iso8859_5+0x0/0xc returned 0 after 0 msecs
calling  init_nls_iso8859_13+0x0/0xc
initcall init_nls_iso8859_13+0x0/0xc returned 0 after 0 msecs
calling  init_nls_iso8859_14+0x0/0xc
initcall init_nls_iso8859_14+0x0/0xc returned 0 after 0 msecs
calling  init_nls_koi8_r+0x0/0xc
initcall init_nls_koi8_r+0x0/0xc returned 0 after 0 msecs
calling  init_nls_utf8+0x0/0x1f
initcall init_nls_utf8+0x0/0x1f returned 0 after 0 msecs
calling  init_sysv_fs+0x0/0x45
initcall init_sysv_fs+0x0/0x45 returned 0 after 0 msecs
calling  init_hpfs_fs+0x0/0x50
initcall init_hpfs_fs+0x0/0x50 returned 0 after 0 msecs
calling  init_ntfs_fs+0x0/0x1c7
NTFS driver 2.1.29 [Flags: R/O].
initcall init_ntfs_fs+0x0/0x1c7 returned 0 after 2 msecs
calling  init_qnx4_fs+0x0/0x62
QNX4 filesystem 0.2.3 registered.
initcall init_qnx4_fs+0x0/0x62 returned 0 after 3 msecs
calling  init_adfs_fs+0x0/0x50
initcall init_adfs_fs+0x0/0x50 returned 0 after 0 msecs
calling  fuse_init+0x0/0x11b
fuse init (API version 7.9)
initcall fuse_init+0x0/0x11b returned 0 after 2 msecs
calling  init_jfs_fs+0x0/0x1db
JFS: nTxBlock =3D 7645, nTxLock =3D 61161
initcall init_jfs_fs+0x0/0x1db returned 0 after 8 msecs
calling  init_befs_fs+0x0/0x71
BeFS version: 0.9.3
initcall init_befs_fs+0x0/0x71 returned 0 after 1 msecs
calling  ocfs2_init+0x0/0x28b
OCFS2 1.5.0
initcall ocfs2_init+0x0/0x28b returned 0 after 1 msecs
calling  ocfs2_stack_glue_init+0x0/0x8b
initcall ocfs2_stack_glue_init+0x0/0x8b returned 0 after 0 msecs
calling  init_o2nm+0x0/0x90
OCFS2 Node Manager 1.5.0
initcall init_o2nm+0x0/0x90 returned 0 after 2 msecs
calling  init_gfs2_fs+0x0/0x16e
GFS2 (built Jul 21 2008 16:13:18) installed
initcall init_gfs2_fs+0x0/0x16e returned 0 after 5 msecs
calling  init_mqueue_fs+0x0/0xbc
initcall init_mqueue_fs+0x0/0xbc returned 0 after 0 msecs
calling  key_proc_init+0x0/0x59
initcall key_proc_init+0x0/0x59 returned 0 after 0 msecs
calling  selinux_nf_ip_init+0x0/0x4c
SELinux:  Registering netfilter hooks
initcall selinux_nf_ip_init+0x0/0x4c returned 0 after 3 msecs
calling  init_sel_fs+0x0/0x5e
initcall init_sel_fs+0x0/0x5e returned 0 after 0 msecs
calling  selnl_init+0x0/0x4d
initcall selnl_init+0x0/0x4d returned 0 after 0 msecs
calling  sel_netif_init+0x0/0x66
initcall sel_netif_init+0x0/0x66 returned 0 after 0 msecs
calling  sel_netnode_init+0x0/0x78
initcall sel_netnode_init+0x0/0x78 returned 0 after 0 msecs
calling  sel_netport_init+0x0/0x78
initcall sel_netport_init+0x0/0x78 returned 0 after 0 msecs
calling  aurule_init+0x0/0x37
initcall aurule_init+0x0/0x37 returned 0 after 0 msecs
calling  crypto_algapi_init+0x0/0xd
initcall crypto_algapi_init+0x0/0xd returned 0 after 0 msecs
calling  blkcipher_module_init+0x0/0x20
initcall blkcipher_module_init+0x0/0x20 returned 0 after 0 msecs
calling  seqiv_module_init+0x0/0xc
initcall seqiv_module_init+0x0/0xc returned 0 after 0 msecs
calling  cryptomgr_init+0x0/0xc
initcall cryptomgr_init+0x0/0xc returned 0 after 0 msecs
calling  hmac_module_init+0x0/0xc
initcall hmac_module_init+0x0/0xc returned 0 after 0 msecs
calling  md5_mod_init+0x0/0xc
initcall md5_mod_init+0x0/0xc returned 0 after 0 msecs
calling  rmd128_mod_init+0x0/0xc
initcall rmd128_mod_init+0x0/0xc returned 0 after 0 msecs
calling  rmd160_mod_init+0x0/0xc
initcall rmd160_mod_init+0x0/0xc returned 0 after 0 msecs
calling  rmd256_mod_init+0x0/0xc
initcall rmd256_mod_init+0x0/0xc returned 0 after 0 msecs
calling  rmd320_mod_init+0x0/0xc
initcall rmd320_mod_init+0x0/0xc returned 0 after 0 msecs
calling  sha1_generic_mod_init+0x0/0xc
initcall sha1_generic_mod_init+0x0/0xc returned 0 after 0 msecs
calling  sha256_generic_mod_init+0x0/0x35
initcall sha256_generic_mod_init+0x0/0x35 returned 0 after 0 msecs
calling  sha512_generic_mod_init+0x0/0x35
initcall sha512_generic_mod_init+0x0/0x35 returned 0 after 0 msecs
calling  crypto_ecb_module_init+0x0/0xc
initcall crypto_ecb_module_init+0x0/0xc returned 0 after 0 msecs
calling  crypto_cbc_module_init+0x0/0xc
initcall crypto_cbc_module_init+0x0/0xc returned 0 after 0 msecs
calling  crypto_module_init+0x0/0xc
initcall crypto_module_init+0x0/0xc returned 0 after 0 msecs
calling  crypto_ctr_module_init+0x0/0x35
initcall crypto_ctr_module_init+0x0/0x35 returned 0 after 0 msecs
calling  crypto_ccm_module_init+0x0/0x53
initcall crypto_ccm_module_init+0x0/0x53 returned 0 after 0 msecs
calling  cryptd_init+0x0/0xa8
initcall cryptd_init+0x0/0xa8 returned 0 after 0 msecs
calling  des_generic_mod_init+0x0/0x35
initcall des_generic_mod_init+0x0/0x35 returned 0 after 0 msecs
calling  fcrypt_mod_init+0x0/0xc
initcall fcrypt_mod_init+0x0/0xc returned 0 after 0 msecs
calling  serpent_mod_init+0x0/0x35
initcall serpent_mod_init+0x0/0x35 returned 0 after 0 msecs
calling  aes_init+0x0/0x2c5
initcall aes_init+0x0/0x2c5 returned 0 after 0 msecs
calling  cast5_mod_init+0x0/0xc
initcall cast5_mod_init+0x0/0xc returned 0 after 0 msecs
calling  arc4_init+0x0/0xc
initcall arc4_init+0x0/0xc returned 0 after 0 msecs
calling  khazad_mod_init+0x0/0xc
initcall khazad_mod_init+0x0/0xc returned 0 after 0 msecs
calling  seed_init+0x0/0xc
initcall seed_init+0x0/0xc returned 0 after 0 msecs
calling  salsa20_generic_mod_init+0x0/0xc
initcall salsa20_generic_mod_init+0x0/0xc returned 0 after 0 msecs
calling  deflate_mod_init+0x0/0xc
initcall deflate_mod_init+0x0/0xc returned 0 after 0 msecs
calling  crc32c_mod_init+0x0/0x35
initcall crc32c_mod_init+0x0/0x35 returned 0 after 0 msecs
calling  crypto_authenc_module_init+0x0/0xc
initcall crypto_authenc_module_init+0x0/0xc returned 0 after 0 msecs
calling  bsg_init+0x0/0x11a
Block layer SCSI generic (bsg) driver version 0.4 loaded (major 254)
initcall bsg_init+0x0/0x11a returned 0 after 5 msecs
calling  noop_init+0x0/0x14
io scheduler noop registered (default)
initcall noop_init+0x0/0x14 returned 0 after 3 msecs
calling  percpu_counter_startup+0x0/0x14
initcall percpu_counter_startup+0x0/0x14 returned 0 after 0 msecs
calling  pci_init+0x0/0x2b
pci 0000:01:00.0: Boot video device
initcall pci_init+0x0/0x2b returned 0 after 3 msecs
calling  pci_proc_init+0x0/0x60
initcall pci_proc_init+0x0/0x60 returned 0 after 0 msecs
calling  ltv350qv_init+0x0/0xc
initcall ltv350qv_init+0x0/0xc returned 0 after 0 msecs
calling  corgibl_init+0x0/0xc
initcall corgibl_init+0x0/0xc returned 0 after 0 msecs
calling  acpi_reserve_resources+0x0/0xeb
initcall acpi_reserve_resources+0x0/0xeb returned 0 after 0 msecs
calling  acpi_ac_init+0x0/0x28
initcall acpi_ac_init+0x0/0x28 returned 0 after 0 msecs
calling  acpi_battery_init+0x0/0x28
initcall acpi_battery_init+0x0/0x28 returned 0 after 0 msecs
calling  acpi_button_init+0x0/0x5e
input: Power Button (FF) as /class/input/input0
ACPI: Power Button (FF) [PWRF]
input: Sleep Button (CM) as /class/input/input1
ACPI: Sleep Button (CM) [SLPB]
initcall acpi_button_init+0x0/0x5e returned 0 after 14 msecs
calling  acpi_fan_init+0x0/0x5e
initcall acpi_fan_init+0x0/0x5e returned 0 after 0 msecs
calling  irqrouter_init_sysfs+0x0/0x37
initcall irqrouter_init_sysfs+0x0/0x37 returned 0 after 0 msecs
calling  acpi_processor_init+0x0/0xf6
ACPI: ACPI0007:00 is registered as cooling_device0
ACPI: ACPI0007:01 is registered as cooling_device1
initcall acpi_processor_init+0x0/0xf6 returned 0 after 9 msecs
calling  acpi_container_init+0x0/0x43
initcall acpi_container_init+0x0/0x43 returned 0 after 1 msecs
calling  toshiba_acpi_init+0x0/0x17d
initcall toshiba_acpi_init+0x0/0x17d returned -19 after 0 msecs
calling  acpi_smb_hc_init+0x0/0x18
initcall acpi_smb_hc_init+0x0/0x18 returned 0 after 0 msecs
calling  acpi_sbs_init+0x0/0x28
initcall acpi_sbs_init+0x0/0x28 returned 0 after 0 msecs
calling  rand_initialize+0x0/0x2c
initcall rand_initialize+0x0/0x2c returned 0 after 0 msecs
calling  tty_init+0x0/0x1c5
initcall tty_init+0x0/0x1c5 returned 0 after 25 msecs
calling  pty_init+0x0/0x46e
initcall pty_init+0x0/0x46e returned 0 after 25 msecs
calling  raw_init+0x0/0xca
initcall raw_init+0x0/0xca returned 0 after 0 msecs
calling  r3964_init+0x0/0x3a
r3964: Philips r3964 Driver $Revision: 1.10 $
initcall r3964_init+0x0/0x3a returned 0 after 3 msecs
calling  applicom_init+0x0/0x4cc
Applicom driver: $Id: ac.c,v 1.30 2000/03/22 16:03:57 dwmw2 Exp $
ac.o: No PCI boards found.
ac.o: For an ISA board you must supply memory and irq parameters.
initcall applicom_init+0x0/0x4cc returned -6 after 13 msecs
initcall applicom_init+0x0/0x4cc returned with error code -6=20
calling  rtc_init+0x0/0xa6
Real Time Clock Driver v1.12ac
initcall rtc_init+0x0/0xa6 returned 0 after 2 msecs
calling  hpet_init+0x0/0x60
initcall hpet_init+0x0/0x60 returned 0 after 0 msecs
calling  nvram_init+0x0/0x80
Non-volatile memory driver v1.2
initcall nvram_init+0x0/0x80 returned 0 after 2 msecs
calling  i8k_init+0x0/0x154
initcall i8k_init+0x0/0x154 returned -19 after 0 msecs
calling  mod_init+0x0/0x1da
initcall mod_init+0x0/0x1da returned -19 after 0 msecs
calling  ppdev_init+0x0/0xa7
ppdev: user-space parallel port driver
initcall ppdev_init+0x0/0xa7 returned 0 after 3 msecs
calling  tlclk_init+0x0/0x1ae
telclk_interrup =3D 0xf non-mcpbl0010 hw.
initcall tlclk_init+0x0/0x1ae returned -6 after 3 msecs
initcall tlclk_init+0x0/0x1ae returned with error code -6=20
calling  agp_init+0x0/0x26
Linux agpgart interface v0.103
initcall agp_init+0x0/0x26 returned 0 after 2 msecs
calling  agp_intel_init+0x0/0x24
initcall agp_intel_init+0x0/0x24 returned 0 after 0 msecs
calling  agp_via_init+0x0/0x24
initcall agp_via_init+0x0/0x24 returned 0 after 0 msecs
calling  init_atmel+0x0/0x17c
initcall init_atmel+0x0/0x17c returned -19 after 0 msecs
calling  drm_core_init+0x0/0xef
[drm] Initialized drm 1.1.0 20060810
initcall drm_core_init+0x0/0xef returned 0 after 3 msecs
calling  tdfx_init+0x0/0xc
initcall tdfx_init+0x0/0xc returned 0 after 0 msecs
calling  radeon_init+0x0/0x18
pci 0000:01:00.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
PCI: Setting latency timer of device 0000:01:00.0 to 64
[drm] Initialized radeon 1.29.0 20080528 on minor 0
initcall radeon_init+0x0/0x18 returned 0 after 15 msecs
calling  i810_init+0x0/0x18
initcall i810_init+0x0/0x18 returned 0 after 0 msecs
calling  i915_init+0x0/0x18
initcall i915_init+0x0/0x18 returned 0 after 0 msecs
calling  sis_init+0x0/0x18
initcall sis_init+0x0/0x18 returned 0 after 0 msecs
calling  via_init+0x0/0x22
initcall via_init+0x0/0x22 returned 0 after 0 msecs
calling  serial8250_init+0x0/0x122
Serial: 8250/16550 driver4 ports, IRQ sharing disabled
=EF=BF=BDserial8250: ttyS0 at I/O 0x3f8 (irq =3D 4) is a 16550A
initcall serial8250_init+0x0/0x122 returned 0 after 251 msecs
calling  jsm_init_module+0x0/0x3e
initcall jsm_init_module+0x0/0x3e returned 0 after 0 msecs
calling  parport_default_proc_register+0x0/0x1b
initcall parport_default_proc_register+0x0/0x1b returned 0 after 0 msec=
s
calling  parport_pc_init+0x0/0x338
parport_pc 00:08: reported by Plug and Play ACPI
parport0: PC-style at 0x378 (0x778), irq 7 [PCSPP(,...)]
initcall parport_pc_init+0x0/0x338 returned 0 after 10 msecs
calling  parport_ax88796_init+0x0/0xc
initcall parport_ax88796_init+0x0/0xc returned 0 after 0 msecs
calling  topology_sysfs_init+0x0/0x41
initcall topology_sysfs_init+0x0/0x41 returned 0 after 0 msecs
calling  loop_init+0x0/0x196
loop: module loaded
initcall loop_init+0x0/0x196 returned 0 after 2 msecs
calling  cpqarray_init+0x0/0x251
Compaq SMART2 Driver (v 2.6.0)
initcall cpqarray_init+0x0/0x251 returned 0 after 2 msecs
calling  cciss_init+0x0/0x28
HP CISS Driver (v 3.6.20)
initcall cciss_init+0x0/0x28 returned 0 after 2 msecs
calling  ub_init+0x0/0x6a
usbcore: registered new interface driver ub
initcall ub_init+0x0/0x6a returned 0 after 3 msecs
calling  pasic3_base_init+0x0/0x13
initcall pasic3_base_init+0x0/0x13 returned -19 after 0 msecs
calling  e1000_init_module+0x0/0x61
e1000e: Intel(R) PRO/1000 Network Driver - 0.3.3.3-k2
e1000e: Copyright (c) 1999-2008 Intel Corporation.
e1000e 0000:04:00.0: PCI INT A -> GSI 17 (level, low) -> IRQ 17
PCI: Setting latency timer of device 0000:04:00.0 to 64
eth0: (PCI Express:2.5GB/s:Width x1) 00:16:76:ab:6e:84
eth0: Intel(R) PRO/1000 Network Connection
eth0: MAC: 2, PHY: 2, PBA No: ffffff-0ff
initcall e1000_init_module+0x0/0x61 returned 0 after 141 msecs
calling  ixgb_init_module+0x0/0x4b
Intel(R) PRO/10GbE Network Driver - version 1.0.135-k2-NAPI
Copyright (c) 1999-2008 Intel Corporation.
initcall ixgb_init_module+0x0/0x4b returned 0 after 8 msecs
calling  ipg_init_module+0x0/0x15
initcall ipg_init_module+0x0/0x15 returned 0 after 0 msecs
calling  cxgb3_init_module+0x0/0x20
initcall cxgb3_init_module+0x0/0x20 returned 0 after 0 msecs
calling  vcan_init_module+0x0/0x36
vcan: Virtual CAN interface driver
initcall vcan_init_module+0x0/0x36 returned 0 after 3 msecs
calling  atl1_init_module+0x0/0x15
initcall atl1_init_module+0x0/0x15 returned 0 after 0 msecs
calling  plip_init+0x0/0x5d
NET3 PLIP version 2.4-parport gniibe@mri.co.jp
plip0: Parallel port at 0x378, using IRQ 7.
initcall plip_init+0x0/0x5d returned 0 after 8 msecs
calling  gem_init+0x0/0x15
initcall gem_init+0x0/0x15 returned 0 after 0 msecs
calling  vortex_init+0x0/0xa9
initcall vortex_init+0x0/0xa9 returned 0 after 0 msecs
calling  ne2k_pci_init+0x0/0x15
initcall ne2k_pci_init+0x0/0x15 returned 0 after 0 msecs
calling  e100_init_module+0x0/0x5c
e100: Intel(R) PRO/100 Network Driver, 3.5.23-k4-NAPI
e100: Copyright(c) 1999-2006 Intel Corporation
initcall e100_init_module+0x0/0x5c returned 0 after 8 msecs
calling  tlan_probe+0x0/0xda
ThunderLAN driver v1.15
TLAN: 0 devices installed, PCI: 0  EISA: 0
initcall tlan_probe+0x0/0xda returned -19 after 5 msecs
calling  epic_init+0x0/0x15
initcall epic_init+0x0/0x15 returned 0 after 0 msecs
calling  sis190_init_module+0x0/0x15
initcall sis190_init_module+0x0/0x15 returned 0 after 0 msecs
calling  r6040_init+0x0/0x15
initcall r6040_init+0x0/0x15 returned 0 after 0 msecs
calling  yellowfin_init+0x0/0x15
initcall yellowfin_init+0x0/0x15 returned 0 after 0 msecs
calling  natsemi_init_mod+0x0/0x15
initcall natsemi_init_mod+0x0/0x15 returned 0 after 0 msecs
calling  ns83820_init+0x0/0x28
ns83820.c: National Semiconductor DP83820 10/100/1000 driver.
initcall ns83820_init+0x0/0x28 returned 0 after 5 msecs
calling  tg3_init+0x0/0x15
initcall tg3_init+0x0/0x15 returned 0 after 0 msecs
calling  bnx2_init+0x0/0x15
initcall bnx2_init+0x0/0x15 returned 0 after 0 msecs
calling  bnx2x_init+0x0/0x15
initcall bnx2x_init+0x0/0x15 returned 0 after 0 msecs
calling  skge_init_module+0x0/0x15
initcall skge_init_module+0x0/0x15 returned 0 after 0 msecs
calling  sky2_init_module+0x0/0x49
initcall sky2_init_module+0x0/0x49 returned 0 after 0 msecs
calling  rhine_init+0x0/0x39
initcall rhine_init+0x0/0x39 returned 0 after 0 msecs
calling  starfire_init+0x0/0x15
initcall starfire_init+0x0/0x15 returned 0 after 0 msecs
calling  marvell_init+0x0/0x5e
initcall marvell_init+0x0/0x5e returned 0 after 0 msecs
calling  cicada_init+0x0/0x35
initcall cicada_init+0x0/0x35 returned 0 after 0 msecs
calling  lxt_init+0x0/0x35
initcall lxt_init+0x0/0x35 returned 0 after 0 msecs
calling  qs6612_init+0x0/0xc
initcall qs6612_init+0x0/0xc returned 0 after 0 msecs
calling  ip175c_init+0x0/0xc
initcall ip175c_init+0x0/0xc returned 0 after 0 msecs
calling  fixed_mdio_bus_init+0x0/0x9e
=46ixed MDIO Bus: probed
initcall fixed_mdio_bus_init+0x0/0x9e returned 0 after 2 msecs
calling  sundance_init+0x0/0x15
initcall sundance_init+0x0/0x15 returned 0 after 0 msecs
calling  hamachi_init+0x0/0x15
initcall hamachi_init+0x0/0x15 returned 0 after 0 msecs
calling  net_olddevs_init+0x0/0x95
initcall net_olddevs_init+0x0/0x95 returned 0 after 0 msecs
calling  b44_init+0x0/0x59
initcall b44_init+0x0/0x59 returned 0 after 0 msecs
calling  init_nic+0x0/0x15
initcall init_nic+0x0/0x15 returned 0 after 0 msecs
calling  ql3xxx_init_module+0x0/0x15
initcall ql3xxx_init_module+0x0/0x15 returned 0 after 0 msecs
calling  dummy_init_module+0x0/0xb2
initcall dummy_init_module+0x0/0xb2 returned 0 after 0 msecs
calling  macvlan_init_module+0x0/0x49
initcall macvlan_init_module+0x0/0x49 returned 0 after 0 msecs
calling  dfx_init+0x0/0x15
initcall dfx_init+0x0/0x15 returned 0 after 0 msecs
calling  rtl8139_init_module+0x0/0x15
initcall rtl8139_init_module+0x0/0x15 returned 0 after 0 msecs
calling  atp_init_module+0x0/0x93
atp.c:v1.09=3Dac 2002/10/01 Donald Becker <becker@scyld.com>
initcall atp_init_module+0x0/0x93 returned -19 after 5 msecs
calling  eql_init_module+0x0/0x5b
Equalizer2002: Simon Janes (simon@ncm.com) and David S. Miller (davem@r=
edhat.com)
initcall eql_init_module+0x0/0x5b returned 0 after 7 msecs
calling  tun_init+0x0/0x96
tun: Universal TUN/TAP device driver, 1.6
tun: (C) 1999-2004 Max Krasnyansky <maxk@qualcomm.com>
initcall tun_init+0x0/0x96 returned 0 after 8 msecs
calling  rio_init+0x0/0x15
initcall rio_init+0x0/0x15 returned 0 after 0 msecs
calling  s2io_starter+0x0/0x15
initcall s2io_starter+0x0/0x15 returned 0 after 0 msecs
calling  xl_pci_init+0x0/0x15
initcall xl_pci_init+0x0/0x15 returned 0 after 0 msecs
calling  init_dlci+0x0/0x35
DLCI driver v0.35, 4 Jan 1997, mike.mclagan@linux.org.
initcall init_dlci+0x0/0x35 returned 0 after 4 msecs
calling  usb_rtl8150_init+0x0/0x28
rtl8150: rtl8150 based usb-ethernet driver v0.6.2 (2004/08/27)
usbcore: registered new interface driver rtl8150
initcall usb_rtl8150_init+0x0/0x28 returned 0 after 9 msecs
calling  cdc_init+0x0/0x15
usbcore: registered new interface driver cdc_ether
initcall cdc_init+0x0/0x15 returned 0 after 4 msecs
calling  dm9601_init+0x0/0x15
usbcore: registered new interface driver dm9601
initcall dm9601_init+0x0/0x15 returned 0 after 4 msecs
calling  usbnet_init+0x0/0x15
usbcore: registered new interface driver gl620a
initcall usbnet_init+0x0/0x15 returned 0 after 4 msecs
calling  plusb_init+0x0/0x15
usbcore: registered new interface driver plusb
initcall plusb_init+0x0/0x15 returned 0 after 4 msecs
calling  rndis_init+0x0/0x15
usbcore: registered new interface driver rndis_host
initcall rndis_init+0x0/0x15 returned 0 after 4 msecs
calling  cdc_subset_init+0x0/0x15
usbcore: registered new interface driver cdc_subset
initcall cdc_subset_init+0x0/0x15 returned 0 after 4 msecs
calling  mcs7830_init+0x0/0x15
usbcore: registered new interface driver MOSCHIP usb-ethernet driver
initcall mcs7830_init+0x0/0x15 returned 0 after 5 msecs
calling  usbnet_init+0x0/0x2b
initcall usbnet_init+0x0/0x2b returned 0 after 0 msecs
calling  ipw2100_init+0x0/0x65
ipw2100: Intel(R) PRO/Wireless 2100 Network Driver, git-1.2.2
ipw2100: Copyright(c) 2003-2006 Intel Corporation
initcall ipw2100_init+0x0/0x65 returned 0 after 9 msecs
calling  ipw_init+0x0/0x7f
ipw2200: Intel(R) PRO/Wireless 2200/2915 Network Driver, 1.2.2kd
ipw2200: Copyright(c) 2003-2006 Intel Corporation
initcall ipw_init+0x0/0x7f returned 0 after 9 msecs
calling  init_orinoco+0x0/0x1d
orinoco 0.15 (David Gibson <hermes@gibson.dropbear.id.au>, Pavel Roskin=
 <proski@gnu.org>, et al)
initcall init_orinoco+0x0/0x1d returned 0 after 8 msecs
calling  init_hermes+0x0/0x3
initcall init_hermes+0x0/0x3 returned 0 after 0 msecs
calling  orinoco_plx_init+0x0/0x2f
orinoco_plx 0.15 (Pavel Roskin <proski@gnu.org>, David Gibson <hermes@g=
ibson.dropbear.id.au>, Daniel Barlow <dan@telent.net>)
initcall orinoco_plx_init+0x0/0x2f returned 0 after 10 msecs
calling  orinoco_nortel_init+0x0/0x2f
orinoco_nortel 0.15 (Tobias Hoffmann & Christoph Jungegger <disdos@trau=
m404.de>)
initcall orinoco_nortel_init+0x0/0x2f returned 0 after 6 msecs
calling  airo_init_module+0x0/0xe3
airo(): Probing for PCI adapters
airo(): Finished probing for PCI adapters
initcall airo_init_module+0x0/0xe3 returned 0 after 6 msecs
calling  prism54_module_init+0x0/0x36
Loaded prism54 driver, version 1.2
initcall prism54_module_init+0x0/0x36 returned 0 after 3 msecs
calling  b43_init+0x0/0x42
Broadcom 43xx driver loaded [ Features: PL, Firmware-ID: FW13 ]
initcall b43_init+0x0/0x42 returned 0 after 5 msecs
calling  usb_init+0x0/0xad
zd1211rw usb_init()
usbcore: registered new interface driver zd1211rw
zd1211rw initialized
initcall usb_init+0x0/0xad returned 0 after 8 msecs
calling  rndis_wlan_init+0x0/0x15
usbcore: registered new interface driver rndis_wlan
initcall rndis_wlan_init+0x0/0x15 returned 0 after 4 msecs
calling  zd1201_init+0x0/0x15
usbcore: registered new interface driver zd1201
initcall zd1201_init+0x0/0x15 returned 0 after 4 msecs
calling  lbs_init_module+0x0/0x38
initcall lbs_init_module+0x0/0x38 returned 0 after 0 msecs
calling  if_sdio_init_module+0x0/0x2d
libertas_sdio: Libertas SDIO driver
libertas_sdio: Copyright Pierre Ossman
initcall if_sdio_init_module+0x0/0x2d returned 0 after 6 msecs
calling  rtl8180_init+0x0/0x15
initcall rtl8180_init+0x0/0x15 returned 0 after 0 msecs
calling  rtl8187_init+0x0/0x15
usbcore: registered new interface driver rtl8187
initcall rtl8187_init+0x0/0x15 returned 0 after 4 msecs
calling  iwl4965_init+0x0/0x6c
iwl4965: Intel(R) Wireless WiFi Link 4965AGN driver for Linux, 1.3.27kd
iwl4965: Copyright(c) 2003-2008 Intel Corporation
initcall iwl4965_init+0x0/0x6c returned 0 after 10 msecs
calling  init_mac80211_hwsim+0x0/0x2f0
mac80211_hwsim: Initializing radio 0
phy0: Failed to select rate control algorithm
phy0: Failed to initialize rate control algorithm
mac80211_hwsim: ieee80211_register_hw failed (-2)
BUG: unable to handle kernel NULL pointer dereference at 00000000000003=
70
IP: [<ffffffff808be0c2>] rollback_registered+0x37/0xfb
PGD 0=20
Oops: 0000 [1] SMP=20
CPU 1=20
Pid: 1, comm: swapper Not tainted 2.6.26-05253-g14b395e #21308
RIP: 0010:[<ffffffff808be0c2>]  [<ffffffff808be0c2>] rollback_registere=
d+0x37/0xfb
RSP: 0018:ffff88003f83fe00  EFLAGS: 00010212
RAX: 0000000000000001 RBX: 0000000000000000 RCX: ffff88003d078ed8
RDX: ffffffff8095de3d RSI: 0000000000000046 RDI: 0000000000000000
RBP: 0000000000000000 R08: 0000000000000000 R09: ffff8800042facc0
R10: 0000000000000000 R11: ffffffff804021ae R12: 0000000000000000
R13: ffff88003d0799a0 R14: 0000000000000000 R15: 0000000000000008
=46S:  0000000000000000(0000) GS:ffff88003f829160(0000) knlGS:000000000=
0000000
CS:  0010 DS: 0018 ES: 0018 CR0: 000000008005003b
CR2: 0000000000000370 CR3: 0000000000201000 CR4: 00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process swapper (pid: 1, threadinfo ffff88003f83e000, task ffff88003f82=
4000)
Stack:  0000000000000000 ffffffff808be1b8 ffff88003d0782c0 ffffffff8096=
21ab
 ffff88003d0799a0 ffffffff805f1e5d 00000000fffffffe ffff88003d0782c0
 ffff88003d0799e0 ffffffff811e83e4 ffff88003f83fea0 ffffffff80248f12
Call Trace:
 [<ffffffff808be1b8>] unregister_netdevice+0x32/0x71
 [<ffffffff809621ab>] ieee80211_unregister_hw+0x35/0xd4
 [<ffffffff805f1e5d>] mac80211_hwsim_free+0x1d/0x6a
 [<ffffffff811e83e4>] init_mac80211_hwsim+0x2df/0x2f0
 [<ffffffff80248f12>] getnstimeofday+0x38/0x95
 [<ffffffff80246f48>] ktime_get_ts+0x21/0x49
 [<ffffffff811e8105>] init_mac80211_hwsim+0x0/0x2f0
 [<ffffffff811cb8c9>] kernel_init+0x143/0x295
 [<ffffffff80209b79>] __switch_to+0xb6/0x3bb
 [<ffffffff8020c399>] child_rip+0xa/0x11
 [<ffffffff811cb786>] kernel_init+0x0/0x295
 [<ffffffff8020c38f>] child_rip+0x0/0x11


Code: 04 0f 0b eb fe e8 e3 78 00 00 85 c0 75 1d ba ce 0e 00 00 48 c7 c6=
 b8 e1 d8 80 48 c7 c7 3b 6c ce 80 e8 24 65 97 ff e8 0e f8 94 ff <8b> 83=
 70 03 00 00 85 c0 75 24 48 89 de 48 89 da 48 c7 c7 e4 e4=20
RIP  [<ffffffff808be0c2>] rollback_registered+0x37/0xfb
 RSP <ffff88003f83fe00>
CR2: 0000000000000370
---[ end trace 4b01b4c1a97dbebf ]---
Kernel panic - not syncing: Attempted to kill init!
