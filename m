From: David Witbrodt <dawitbro@sbcglobal.net>
Subject: Re: HPET regression in 2.6.26 versus 2.6.25 -- found another user with the same regression
Date: Sat, 23 Aug 2008 16:09:11 -0700 (PDT)
Message-ID: <725399.45305.qm@web82102.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ingo Molnar <mingo@elte.hu>, Vivek Goyal <vgoyal@redhat.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	"H. Peter Anvin" <hpa@zytor.com>, netdev <netdev@vger.kernel.org>,
	Rufus & Azrael <rufus-azrael@numericable.fr>
To: Yinghai Lu <yhlu.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from web82102.mail.mud.yahoo.com ([209.191.84.215]:44037 "HELO
	web82102.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751810AbYHWXJM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Aug 2008 19:09:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> dmesg and lspci -vvxxx with hpet=disable?
> 
> please boot with "debug initcall_debug hpet=disable"

Sorry, Yinghai.  I decided to shutdown for a time because of bad
thunderstorms.  Here is the requested output:

$ dmesg
Linux version 2.6.27-rc4.080823.hpet+bar1 (dawitbro@fileserver) (gcc version 4.3.1 (Debian 4.3.1-2) ) #1 SMP Sat Aug 23 15:40:47 EDT 2008
Command line: root=/dev/hda1 ro video=uvesafb:1280x1024-16@60,mtrr:3 fbcon=scrollback:256k,font:10x18 debug initcall_debug hpet=disable
KERNEL supported cpus:
  Intel GenuineIntel
  AMD AuthenticAMD
  Centaur CentaurHauls
BIOS-provided physical RAM map:
 BIOS-e820: 0000000000000000 - 000000000009f400 (usable)
 BIOS-e820: 000000000009f400 - 00000000000a0000 (reserved)
 BIOS-e820: 00000000000f0000 - 0000000000100000 (reserved)
 BIOS-e820: 0000000000100000 - 0000000077fe0000 (usable)
 BIOS-e820: 0000000077fe0000 - 0000000077fe3000 (ACPI NVS)
 BIOS-e820: 0000000077fe3000 - 0000000077ff0000 (ACPI data)
 BIOS-e820: 0000000077ff0000 - 0000000078000000 (reserved)
 BIOS-e820: 00000000e0000000 - 00000000f0000000 (reserved)
 BIOS-e820: 00000000fec00000 - 0000000100000000 (reserved)
last_pfn = 0x77fe0 max_arch_pfn = 0x3ffffffff
init_memory_mapping
 0000000000 - 0077e00000 page 2M
 0077e00000 - 0077fe0000 page 4k
kernel direct mapping tables up to 77fe0000 @ 8000-c000
last_map_addr: 77fe0000 end: 77fe0000
DMI 2.5 present.
ACPI: RSDP 000F7B80, 0024 (r2 RS690 )
ACPI: RSDT 77FE3040, 0038 (r1 RS690  AWRDACPI 42302E31 AWRD        0)
ACPI: FACP 77FE30C0, 0074 (r1 RS690  AWRDACPI 42302E31 AWRD        0)
ACPI: DSDT 77FE3180, 4B0B (r1 RS690  AWRDACPI     1000 MSFT  3000000)
ACPI: FACS 77FE0000, 0040
ACPI: SSDT 77FE7DC0, 028A (r1 PTLTD  POWERNOW        1  LTP        1)
ACPI: HPET 77FE80C0, 0038 (r1 RS690  AWRDACPI 42302E31 AWRD       98)
ACPI: MCFG 77FE8140, 003C (r1 RS690  AWRDACPI 42302E31 AWRD        0)
ACPI: APIC 77FE7D00, 0068 (r1 RS690  AWRDACPI 42302E31 AWRD        0)
No NUMA configuration found
Faking a node at 0000000000000000-0000000077fe0000
Bootmem setup node 0 0000000000000000-0000000077fe0000
  NODE_DATA [0000000000001000 - 0000000000004fff]
  bootmap [000000000000a000 -  0000000000018fff] pages f
(5 early reservations) ==> bootmem [0000000000 - 0077fe0000]
  #0 [0000000000 - 0000001000]   BIOS data page ==> [0000000000 - 0000001000]
  #1 [0000006000 - 0000008000]       TRAMPOLINE ==> [0000006000 - 0000008000]
  #2 [0000200000 - 0000f3db48]    TEXT DATA BSS ==> [0000200000 - 0000f3db48]
  #3 [000009f000 - 0000100000]    BIOS reserved ==> [000009f000 - 0000100000]
  #4 [0000008000 - 000000a000]          PGTABLE ==> [0000008000 - 000000a000]
found SMP MP-table at [ffff8800000f3c80] 000f3c80
 [ffffe20000000000-ffffe200029fffff] PMD -> [ffff880001200000-ffff880003bfffff] on node 0
Zone PFN ranges:
  DMA      0x00000000 -> 0x00001000
  DMA32    0x00001000 -> 0x00100000
  Normal   0x00100000 -> 0x00100000
Movable zone start PFN for each node
early_node_map[2] active PFN ranges
    0: 0x00000000 -> 0x0000009f
    0: 0x00000100 -> 0x00077fe0
On node 0 totalpages: 491391
  DMA zone: 418 pages, LIFO batch:0
  DMA32 zone: 476920 pages, LIFO batch:31
Detected use of extended apic ids on hypertransport bus
ACPI: PM-Timer IO Port: 0x4008
ACPI: Local APIC address 0xfee00000
ACPI: LAPIC (acpi_id[0x00] lapic_id[0x00] enabled)
ACPI: LAPIC (acpi_id[0x01] lapic_id[0x01] enabled)
ACPI: LAPIC_NMI (acpi_id[0x00] high edge lint[0x1])
ACPI: LAPIC_NMI (acpi_id[0x01] high edge lint[0x1])
ACPI: IOAPIC (id[0x02] address[0xfec00000] gsi_base[0])
IOAPIC[0]: apic_id 2, version 0, address 0xfec00000, GSI 0-23
ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 low level)
ACPI: IRQ0 used by override.
ACPI: IRQ2 used by override.
ACPI: IRQ9 used by override.
Setting APIC routing to flat
ACPI: HPET id: 0x10b9a201 base: 0xfed00000
Using ACPI (MADT) for SMP configuration information
Allocating PCI resources starting at 80000000 (gap: 78000000:68000000)
PERCPU: Allocating 45800 bytes of per cpu data
NR_CPUS: 4, nr_cpu_ids: 4, nr_node_ids 1
Built 1 zonelists in Node order, mobility grouping on.  Total pages: 477338
Policy zone: DMA32
Kernel command line: root=/dev/hda1 ro video=uvesafb:1280x1024-16@60,mtrr:3 fbcon=scrollback:256k,font:10x18 debug initcall_debug hpet=disable
Initializing CPU#0
PID hash table entries: 4096 (order: 12, 32768 bytes)
TSC calibrated against PM_TIMER
Detected 2499.714 MHz processor.
Console: colour VGA+ 80x25
console [tty0] enabled
Lock dependency validator: Copyright (c) 2006 Red Hat, Inc., Ingo Molnar
... MAX_LOCKDEP_SUBCLASSES:    8
... MAX_LOCK_DEPTH:          48
... MAX_LOCKDEP_KEYS:        8191
... CLASSHASH_SIZE:           4096
... MAX_LOCKDEP_ENTRIES:     8192
... MAX_LOCKDEP_CHAINS:      16384
... CHAINHASH_SIZE:          8192
 memory used by lock dependency info: 3839 kB
 per task-struct memory footprint: 1920 bytes
Checking aperture...
No AGP bridge found
Node 0: aperture @ 2ecc000000 size 32 MB
Aperture beyond 4GB. Ignoring.
Memory: 1908672k/1965952k available (3610k kernel code, 56892k reserved, 1809k data, 512k init)
CPA: page pool initialized 1 of 1 pages preallocated
SLUB: Genslabs=13, HWalign=64, Order=0-3, MinObjects=0, CPUs=2, Nodes=1
Calibrating delay loop (skipped), value calculated using timer frequency.. 5001.73 BogoMIPS (lpj=8332380)
Dentry cache hash table entries: 262144 (order: 9, 2097152 bytes)
Inode-cache hash table entries: 131072 (order: 8, 1048576 bytes)
Mount-cache hash table entries: 256
CPU: L1 I Cache: 64K (64 bytes/line), D cache 64K (64 bytes/line)
CPU: L2 Cache: 512K (64 bytes/line)
CPU 0/0 -> Node 0
tseg: 0000000000
CPU: Physical Processor ID: 0
CPU: Processor Core ID: 0
using C1E aware idle routine
Freeing SMP alternatives: 25k freed
ACPI: Core revision 20080609
..TIMER: vector=0x30 apic1=0 pin1=2 apic2=-1 pin2=-1
CPU0: AMD Processor model unknown stepping 02
Using local APIC timer interrupts.
APIC timer calibration result 12498565
Detected 12.498 MHz APIC timer.
calling  migration_init+0x0/0x5b
initcall migration_init+0x0/0x5b returned 1 after 0 msecs
initcall migration_init+0x0/0x5b returned with error code 1 
calling  spawn_ksoftirqd+0x0/0x4e
initcall spawn_ksoftirqd+0x0/0x4e returned 0 after 0 msecs
calling  init_call_single_data+0x0/0x65
initcall init_call_single_data+0x0/0x65 returned 0 after 0 msecs
calling  spawn_softlockup_task+0x0/0x6d
initcall spawn_softlockup_task+0x0/0x6d returned 0 after 0 msecs
lockdep: fixing up alternatives.
Booting processor 1/1 ip 6000
Initializing CPU#1
Calibrating delay using timer specific routine.. 5001.71 BogoMIPS (lpj=8332342)
CPU: L1 I Cache: 64K (64 bytes/line), D cache 64K (64 bytes/line)
CPU: L2 Cache: 512K (64 bytes/line)
CPU 1/1 -> Node 0
CPU: Physical Processor ID: 0
CPU: Processor Core ID: 1
CPU1: AMD Processor model unknown stepping 02
Brought up 2 CPUs
Total of 2 processors activated (10002.45 BogoMIPS).
CPU0 attaching sched-domain:
 domain 0: span 0-1 level CPU
  groups: 0 1
  domain 1: span 0-1 level NODE
   groups: 0-1
CPU1 attaching sched-domain:
 domain 0: span 0-1 level CPU
  groups: 1 0
  domain 1: span 0-1 level NODE
   groups: 0-1
calling  init_cpufreq_transition_notifier_list+0x0/0x1e
initcall init_cpufreq_transition_notifier_list+0x0/0x1e returned 0 after 0 msecs
calling  net_ns_init+0x0/0x180
net_namespace: 904 bytes
initcall net_ns_init+0x0/0x180 returned 0 after 0 msecs
calling  cpufreq_tsc+0x0/0x19
initcall cpufreq_tsc+0x0/0x19 returned 0 after 0 msecs
calling  init_smp_flush+0x0/0x66
initcall init_smp_flush+0x0/0x66 returned 0 after 0 msecs
calling  sysctl_init+0x0/0x35
initcall sysctl_init+0x0/0x35 returned 0 after 0 msecs
calling  ksysfs_init+0x0/0xbd
initcall ksysfs_init+0x0/0xbd returned 0 after 0 msecs
calling  init_jiffies_clocksource+0x0/0xc
initcall init_jiffies_clocksource+0x0/0xc returned 0 after 0 msecs
calling  pm_init+0x0/0x3b
initcall pm_init+0x0/0x3b returned 0 after 0 msecs
calling  filelock_init+0x0/0x31
initcall filelock_init+0x0/0x31 returned 0 after 0 msecs
calling  init_script_binfmt+0x0/0xc
initcall init_script_binfmt+0x0/0xc returned 0 after 0 msecs
calling  init_elf_binfmt+0x0/0xc
initcall init_elf_binfmt+0x0/0xc returned 0 after 0 msecs
calling  init_compat_elf_binfmt+0x0/0xc
initcall init_compat_elf_binfmt+0x0/0xc returned 0 after 0 msecs
calling  random32_init+0x0/0xc9
initcall random32_init+0x0/0xc9 returned 0 after 0 msecs
calling  cpufreq_core_init+0x0/0x74
initcall cpufreq_core_init+0x0/0x74 returned 0 after 0 msecs
calling  cpuidle_init+0x0/0x36
initcall cpuidle_init+0x0/0x36 returned 0 after 0 msecs
calling  sock_init+0x0/0x60
initcall sock_init+0x0/0x60 returned 0 after 0 msecs
calling  netlink_proto_init+0x0/0x16d
NET: Registered protocol family 16
initcall netlink_proto_init+0x0/0x16d returned 0 after 0 msecs
calling  bdi_class_init+0x0/0x2f
initcall bdi_class_init+0x0/0x2f returned 0 after 0 msecs
calling  kobject_uevent_init+0x0/0x4c
initcall kobject_uevent_init+0x0/0x4c returned 0 after 0 msecs
calling  pcibus_class_init+0x0/0x13
initcall pcibus_class_init+0x0/0x13 returned 0 after 0 msecs
calling  pci_driver_init+0x0/0x12
initcall pci_driver_init+0x0/0x12 returned 0 after 0 msecs
calling  dock_init+0x0/0x5c
No dock devices found.
initcall dock_init+0x0/0x5c returned 0 after 0 msecs
calling  tty_class_init+0x0/0x34
initcall tty_class_init+0x0/0x34 returned 0 after 0 msecs
calling  vtconsole_class_init+0x0/0xc4
initcall vtconsole_class_init+0x0/0xc4 returned 0 after 0 msecs
calling  register_node_type+0x0/0xb9
initcall register_node_type+0x0/0xb9 returned 0 after 0 msecs
calling  enable_pci_io_ecs+0x0/0x3c
initcall enable_pci_io_ecs+0x0/0x3c returned 0 after 0 msecs
calling  early_fill_mp_bus_info+0x0/0x83e
node 0 link 0: io port [d000, ffff]
TOM: 0000000080000000 aka 2048M
node 0 link 0: mmio [a0000, bffff]
node 0 link 0: mmio [d8000000, dfffffff]
node 0 link 0: mmio [80000000, d7ffffff]
node 0 link 0: mmio [f0000000, fe02ffff]
node 0 link 0: mmio [e0000000, e02fffff]
bus: [00,02] on node 0 link 0
bus: 00 index 0 io port: [0, ffff]
bus: 00 index 1 mmio: [a0000, bffff]
bus: 00 index 2 mmio: [80000000, efffffff]
bus: 00 index 3 mmio: [f0000000, fcffffffff]
initcall early_fill_mp_bus_info+0x0/0x83e returned 0 after 0 msecs
calling  arch_kdebugfs_init+0x0/0xe
initcall arch_kdebugfs_init+0x0/0xe returned 0 after 0 msecs
calling  mtrr_if_init+0x0/0x84
initcall mtrr_if_init+0x0/0x84 returned 0 after 0 msecs
calling  ffh_cstate_init+0x0/0x3c
initcall ffh_cstate_init+0x0/0x3c returned -1 after 0 msecs
initcall ffh_cstate_init+0x0/0x3c returned with error code -1 
calling  acpi_pci_init+0x0/0x65
ACPI: bus type pci registered
initcall acpi_pci_init+0x0/0x65 returned 0 after 0 msecs
calling  init_acpi_device_notify+0x0/0x4b
initcall init_acpi_device_notify+0x0/0x4b returned 0 after 0 msecs
calling  pci_arch_init+0x0/0x4b
PCI: MCFG configuration 0: base e0000000 segment 0 buses 0 - 255
PCI: MCFG area at e0000000 reserved in E820
PCI: Using MMCONFIG at e0000000 - efffffff
PCI: Using configuration type 1 for base access
initcall pci_arch_init+0x0/0x4b returned 0 after 3 msecs
calling  topology_init+0x0/0xa1
initcall topology_init+0x0/0xa1 returned 0 after 0 msecs
calling  mtrr_init_finialize+0x0/0x41
initcall mtrr_init_finialize+0x0/0x41 returned 0 after 0 msecs
calling  param_sysfs_init+0x0/0x24b
initcall param_sysfs_init+0x0/0x24b returned 0 after 3 msecs
calling  pm_sysrq_init+0x0/0x20
initcall pm_sysrq_init+0x0/0x20 returned 0 after 0 msecs
calling  readahead_init+0x0/0x2e
initcall readahead_init+0x0/0x2e returned 0 after 0 msecs
calling  init_bio+0x0/0xbb
initcall init_bio+0x0/0xbb returned 0 after 0 msecs
calling  blk_settings_init+0x0/0x25
initcall blk_settings_init+0x0/0x25 returned 0 after 0 msecs
calling  blk_ioc_init+0x0/0x2d
initcall blk_ioc_init+0x0/0x2d returned 0 after 0 msecs
calling  genhd_device_init+0x0/0x4b
initcall genhd_device_init+0x0/0x4b returned 0 after 0 msecs
calling  pci_slot_init+0x0/0x50
initcall pci_slot_init+0x0/0x50 returned 0 after 0 msecs
calling  fbmem_init+0x0/0x98
initcall fbmem_init+0x0/0x98 returned 0 after 0 msecs
calling  acpi_init+0x0/0x21b
ACPI: EC: Look up EC in DSDT
ACPI: Interpreter enabled
ACPI: (supports S0 S5)
ACPI: Using IOAPIC for interrupt routing
initcall acpi_init+0x0/0x21b returned 0 after 9 msecs
calling  acpi_scan_init+0x0/0x110
initcall acpi_scan_init+0x0/0x110 returned 0 after 6 msecs
calling  acpi_ec_init+0x0/0x61
initcall acpi_ec_init+0x0/0x61 returned 0 after 0 msecs
calling  acpi_pci_root_init+0x0/0x28
ACPI: PCI Root Bridge [PCI0] (0000:00)
pci 0000:00:13.5: supports D1
pci 0000:00:13.5: supports D2
pci 0000:00:13.5: PME# supported from D0 D1 D2 D3hot
pci 0000:00:13.5: PME# disabled
pci 0000:00:14.2: PME# supported from D0 D3hot D3cold
pci 0000:00:14.2: PME# disabled
pci 0000:01:05.0: supports D1
pci 0000:01:05.0: supports D2
PCI: bridge 0000:00:01.0 io port: [e000, efff]
PCI: bridge 0000:00:01.0 32bit mmio: [fdd00000, fdefffff]
PCI: bridge 0000:00:01.0 64bit mmio pref: [d8000000, dfffffff]
pci 0000:02:05.0: supports D1
pci 0000:02:05.0: supports D2
pci 0000:02:05.0: PME# supported from D1 D2 D3hot D3cold
pci 0000:02:05.0: PME# disabled
pci 0000:00:14.4: transparent bridge
PCI: bridge 0000:00:14.4 io port: [d000, dfff]
PCI: bridge 0000:00:14.4 32bit mmio: [fdc00000, fdcfffff]
PCI: bridge 0000:00:14.4 32bit mmio pref: [fdf00000, fdffffff]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.P2P_._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.AGP_._PRT]
initcall acpi_pci_root_init+0x0/0x28 returned 0 after 19 msecs
calling  acpi_pci_link_init+0x0/0x48
ACPI: PCI Interrupt Link [LNKA] (IRQs 3 4 5 6 7 10 11) *0, disabled.
ACPI: PCI Interrupt Link [LNKB] (IRQs 3 4 5 6 7 10 11) *0, disabled.
ACPI: PCI Interrupt Link [LNKC] (IRQs 3 4 5 6 7 10 11) *0, disabled.
ACPI: PCI Interrupt Link [LNKD] (IRQs 3 4 5 6 7 10 11) *0, disabled.
ACPI: PCI Interrupt Link [LNKE] (IRQs 3 4 5 6 7 10 11) *0, disabled.
ACPI: PCI Interrupt Link [LNKF] (IRQs 3 4 5 6 7 10 11) *0, disabled.
ACPI: PCI Interrupt Link [LNK0] (IRQs 3 4 5 6 7 10 11) *0, disabled.
ACPI: PCI Interrupt Link [LNK1] (IRQs 3 4 5 6 7 10 11) *0, disabled.
initcall acpi_pci_link_init+0x0/0x48 returned 0 after 3 msecs
calling  acpi_power_init+0x0/0x77
initcall acpi_power_init+0x0/0x77 returned 0 after 0 msecs
calling  acpi_system_init+0x0/0x263
initcall acpi_system_init+0x0/0x263 returned 0 after 0 msecs
calling  pnp_init+0x0/0x22
Linux Plug and Play Support v0.97 (c) Adam Belay
initcall pnp_init+0x0/0x22 returned 0 after 0 msecs
calling  pnpacpi_init+0x0/0x91
pnp: PnP ACPI init
ACPI: bus type pnp registered
pnp 00:0d: mem resource (0xfed00000-0xfed000ff) overlaps 0000:00:14.0 BAR 1 (0xfed00000-0xfed003ff), disabling
pnp: PnP ACPI: found 14 devices
ACPI: ACPI bus type pnp unregistered
initcall pnpacpi_init+0x0/0x91 returned 0 after 3 msecs
calling  misc_init+0x0/0x97
initcall misc_init+0x0/0x97 returned 0 after 0 msecs
calling  cn_init+0x0/0xf4
initcall cn_init+0x0/0xf4 returned 0 after 0 msecs
calling  init_scsi+0x0/0x81
SCSI subsystem initialized
initcall init_scsi+0x0/0x81 returned 0 after 0 msecs
calling  ata_init+0x0/0x3dd
libata version 3.00 loaded.
initcall ata_init+0x0/0x3dd returned 0 after 0 msecs
calling  usb_init+0x0/0x12d
usbcore: registered new interface driver usbfs
usbcore: registered new interface driver hub
usbcore: registered new device driver usb
initcall usb_init+0x0/0x12d returned 0 after 3 msecs
calling  serio_init+0x0/0x90
initcall serio_init+0x0/0x90 returned 0 after 0 msecs
calling  input_init+0x0/0x10c
initcall input_init+0x0/0x10c returned 0 after 0 msecs
calling  i2c_init+0x0/0x5e
initcall i2c_init+0x0/0x5e returned 0 after 0 msecs
calling  power_supply_class_init+0x0/0x3b
initcall power_supply_class_init+0x0/0x3b returned 0 after 0 msecs
calling  hwmon_init+0x0/0x47
initcall hwmon_init+0x0/0x47 returned 0 after 0 msecs
calling  thermal_init+0x0/0x4e
initcall thermal_init+0x0/0x4e returned 0 after 0 msecs
calling  pci_subsys_init+0x0/0x120
PCI: Using ACPI for IRQ routing
pci 0000:00:14.0: BAR 1: can't allocate resource
initcall pci_subsys_init+0x0/0x120 returned 0 after 0 msecs
calling  proto_init+0x0/0x31
initcall proto_init+0x0/0x31 returned 0 after 0 msecs
calling  net_dev_init+0x0/0x157
initcall net_dev_init+0x0/0x157 returned 0 after 0 msecs
calling  neigh_init+0x0/0x74
initcall neigh_init+0x0/0x74 returned 0 after 0 msecs
calling  genl_init+0x0/0xd5
initcall genl_init+0x0/0xd5 returned 0 after 12 msecs
calling  sysctl_init+0x0/0x46
initcall sysctl_init+0x0/0x46 returned 0 after 0 msecs
calling  pci_iommu_init+0x0/0x15
initcall pci_iommu_init+0x0/0x15 returned 0 after 0 msecs
calling  hpet_late_init+0x0/0xf7
initcall hpet_late_init+0x0/0xf7 returned -19 after 0 msecs
calling  clocksource_done_booting+0x0/0xd
initcall clocksource_done_booting+0x0/0xd returned 0 after 0 msecs
calling  init_pipe_fs+0x0/0x44
initcall init_pipe_fs+0x0/0x44 returned 0 after 0 msecs
calling  init_mnt_writers+0x0/0x77
initcall init_mnt_writers+0x0/0x77 returned 0 after 0 msecs
calling  eventpoll_init+0x0/0x98
initcall eventpoll_init+0x0/0x98 returned 0 after 0 msecs
calling  anon_inode_init+0x0/0x119
initcall anon_inode_init+0x0/0x119 returned 0 after 0 msecs
calling  acpi_event_init+0x0/0x80
initcall acpi_event_init+0x0/0x80 returned 0 after 9 msecs
calling  pnp_system_init+0x0/0x16
system 00:01: ioport range 0x4100-0x411f has been reserved
system 00:01: ioport range 0x228-0x22f has been reserved
system 00:01: ioport range 0x40b-0x40b has been reserved
system 00:01: ioport range 0x4d6-0x4d6 has been reserved
system 00:01: ioport range 0xc00-0xc01 has been reserved
system 00:01: ioport range 0xc14-0xc14 has been reserved
system 00:01: ioport range 0xc50-0xc52 has been reserved
system 00:01: ioport range 0xc6c-0xc6d has been reserved
system 00:01: ioport range 0xc6f-0xc6f has been reserved
system 00:01: ioport range 0xcd0-0xcd1 has been reserved
system 00:01: ioport range 0xcd2-0xcd3 has been reserved
system 00:01: ioport range 0xcd4-0xcdf has been reserved
system 00:01: ioport range 0x4000-0x40fe has been reserved
system 00:01: ioport range 0x4210-0x4217 has been reserved
system 00:01: ioport range 0xb10-0xb1f has been reserved
system 00:07: ioport range 0x4d0-0x4d1 has been reserved
system 00:07: ioport range 0x220-0x225 has been reserved
system 00:07: ioport range 0xb00-0xb0f has been reserved
system 00:0c: iomem range 0xe0000000-0xefffffff could not be reserved
system 00:0d: iomem range 0xf0000-0xfffff could not be reserved
system 00:0d: iomem range 0x77fe0000-0x77ffffff could not be reserved
system 00:0d: iomem range 0xffff0000-0xffffffff could not be reserved
system 00:0d: iomem range 0x0-0x9ffff could not be reserved
system 00:0d: iomem range 0x100000-0x77fdffff could not be reserved
system 00:0d: iomem range 0x78000000-0x7fffffff has been reserved
system 00:0d: iomem range 0xfec00000-0xfec00fff could not be reserved
system 00:0d: iomem range 0xfee00000-0xfee00fff could not be reserved
system 00:0d: iomem range 0xfff80000-0xfffeffff could not be reserved
initcall pnp_system_init+0x0/0x16 returned 0 after 0 msecs
calling  chr_dev_init+0x0/0xa2
initcall chr_dev_init+0x0/0xa2 returned 0 after 0 msecs
calling  firmware_class_init+0x0/0x71
initcall firmware_class_init+0x0/0x71 returned 0 after 0 msecs
calling  loopback_init+0x0/0xc
initcall loopback_init+0x0/0xc returned 0 after 0 msecs
calling  cpufreq_gov_performance_init+0x0/0xc
initcall cpufreq_gov_performance_init+0x0/0xc returned 0 after 0 msecs
calling  init_acpi_pm_clocksource+0x0/0xb4
initcall init_acpi_pm_clocksource+0x0/0xb4 returned 0 after 0 msecs
calling  pcibios_assign_resources+0x0/0x8b
pci 0000:00:01.0: PCI bridge, secondary bus 0000:01
pci 0000:00:01.0:   IO window: 0xe000-0xefff
pci 0000:00:01.0:   MEM window: 0xfdd00000-0xfdefffff
pci 0000:00:01.0:   PREFETCH window: 0x000000d8000000-0x000000dfffffff
pci 0000:00:14.4: PCI bridge, secondary bus 0000:02
pci 0000:00:14.4:   IO window: 0xd000-0xdfff
pci 0000:00:14.4:   MEM window: 0xfdc00000-0xfdcfffff
pci 0000:00:14.4:   PREFETCH window: 0x000000fdf00000-0x000000fdffffff
bus: 00 index 0 io port: [0, ffff]
bus: 00 index 1 mmio: [0, ffffffffffffffff]
bus: 01 index 0 io port: [e000, efff]
bus: 01 index 1 mmio: [fdd00000, fdefffff]
bus: 01 index 2 mmio: [d8000000, dfffffff]
bus: 01 index 3 mmio: [0, 0]
bus: 02 index 0 io port: [d000, dfff]
bus: 02 index 1 mmio: [fdc00000, fdcfffff]
bus: 02 index 2 mmio: [fdf00000, fdffffff]
bus: 02 index 3 io port: [0, ffff]
bus: 02 index 4 mmio: [0, ffffffffffffffff]
initcall pcibios_assign_resources+0x0/0x8b returned 0 after 0 msecs
calling  inet_init+0x0/0x250
Switched to high resolution mode on CPU 0
NET: Registered protocol family 2
Switched to high resolution mode on CPU 1
IP route cache hash table entries: 65536 (order: 7, 524288 bytes)
TCP established hash table entries: 262144 (order: 10, 4194304 bytes)
TCP bind hash table entries: 65536 (order: 9, 3670016 bytes)
TCP: Hash tables configured (established 262144 bind 65536)
TCP reno registered
initcall inet_init+0x0/0x250 returned 0 after 47 msecs
calling  af_unix_init+0x0/0x4b
NET: Registered protocol family 1
initcall af_unix_init+0x0/0x4b returned 0 after 0 msecs
calling  populate_rootfs+0x0/0xaf
initcall populate_rootfs+0x0/0xaf returned 0 after 1 msecs
calling  i8259A_init_sysfs+0x0/0x29
initcall i8259A_init_sysfs+0x0/0x29 returned 0 after 0 msecs
calling  vsyscall_init+0x0/0x63
initcall vsyscall_init+0x0/0x63 returned 0 after 0 msecs
calling  sbf_init+0x0/0x103
initcall sbf_init+0x0/0x103 returned 0 after 0 msecs
calling  i8237A_init_sysfs+0x0/0x29
initcall i8237A_init_sysfs+0x0/0x29 returned 0 after 0 msecs
calling  add_rtc_cmos+0x0/0x21
initcall add_rtc_cmos+0x0/0x21 returned 0 after 0 msecs
calling  cache_sysfs_init+0x0/0x5a3
initcall cache_sysfs_init+0x0/0x5a3 returned 0 after 0 msecs
calling  mce_init_device+0x0/0x1f6
initcall mce_init_device+0x0/0x1f6 returned 0 after 0 msecs
calling  periodic_mcheck_init+0x0/0x44
initcall periodic_mcheck_init+0x0/0x44 returned 0 after 0 msecs
calling  thermal_throttle_init_device+0x0/0x59
initcall thermal_throttle_init_device+0x0/0x59 returned 0 after 0 msecs
calling  threshold_init_device+0x0/0x465
initcall threshold_init_device+0x0/0x465 returned 0 after 0 msecs
calling  msr_init+0x0/0x120
initcall msr_init+0x0/0x120 returned 0 after 0 msecs
calling  cpuid_init+0x0/0x120
initcall cpuid_init+0x0/0x120 returned 0 after 0 msecs
calling  init_lapic_sysfs+0x0/0x34
initcall init_lapic_sysfs+0x0/0x34 returned 0 after 0 msecs
calling  ioapic_init_sysfs+0x0/0xb7
initcall ioapic_init_sysfs+0x0/0xb7 returned 0 after 0 msecs
calling  add_pcspkr+0x0/0x43
initcall add_pcspkr+0x0/0x43 returned 0 after 0 msecs
calling  uv_ptc_init+0x0/0x7a
initcall uv_ptc_init+0x0/0x7a returned 0 after 0 msecs
calling  uv_bau_init+0x0/0x62a
initcall uv_bau_init+0x0/0x62a returned 0 after 0 msecs
calling  init_vdso_vars+0x0/0x23f
initcall init_vdso_vars+0x0/0x23f returned 0 after 0 msecs
calling  ia32_binfmt_init+0x0/0x17
initcall ia32_binfmt_init+0x0/0x17 returned 0 after 0 msecs
calling  sysenter_setup+0x0/0x35c
initcall sysenter_setup+0x0/0x35c returned 0 after 0 msecs
calling  init_sched_debug_procfs+0x0/0x2c
initcall init_sched_debug_procfs+0x0/0x2c returned 0 after 0 msecs
calling  ioresources_init+0x0/0x3f
initcall ioresources_init+0x0/0x3f returned 0 after 0 msecs
calling  uid_cache_init+0x0/0x90
initcall uid_cache_init+0x0/0x90 returned 0 after 0 msecs
calling  init_posix_timers+0x0/0x95
initcall init_posix_timers+0x0/0x95 returned 0 after 0 msecs
calling  init_posix_cpu_timers+0x0/0xb5
initcall init_posix_cpu_timers+0x0/0xb5 returned 0 after 0 msecs
calling  nsproxy_cache_init+0x0/0x3d
initcall nsproxy_cache_init+0x0/0x3d returned 0 after 0 msecs
calling  timekeeping_init_device+0x0/0x29
initcall timekeeping_init_device+0x0/0x29 returned 0 after 0 msecs
calling  init_clocksource_sysfs+0x0/0x57
initcall init_clocksource_sysfs+0x0/0x57 returned 0 after 0 msecs
calling  init_timer_list_procfs+0x0/0x2f
initcall init_timer_list_procfs+0x0/0x2f returned 0 after 0 msecs
calling  lockdep_proc_init+0x0/0x62
initcall lockdep_proc_init+0x0/0x62 returned 0 after 0 msecs
calling  futex_init+0x0/0xce
initcall futex_init+0x0/0xce returned 0 after 0 msecs
calling  proc_dma_init+0x0/0x25
initcall proc_dma_init+0x0/0x25 returned 0 after 0 msecs
calling  percpu_modinit+0x0/0x80
initcall percpu_modinit+0x0/0x80 returned 0 after 0 msecs
calling  kallsyms_init+0x0/0x28
initcall kallsyms_init+0x0/0x28 returned 0 after 0 msecs
calling  ikconfig_init+0x0/0x3c
initcall ikconfig_init+0x0/0x3c returned 0 after 0 msecs
calling  utsname_sysctl_init+0x0/0x24
initcall utsname_sysctl_init+0x0/0x24 returned 0 after 0 msecs
calling  init_per_zone_pages_min+0x0/0x52
initcall init_per_zone_pages_min+0x0/0x52 returned 0 after 0 msecs
calling  pdflush_init+0x0/0x15
initcall pdflush_init+0x0/0x15 returned 0 after 0 msecs
calling  kswapd_init+0x0/0x6f
initcall kswapd_init+0x0/0x6f returned 0 after 0 msecs
calling  setup_vmstat+0x0/0x3a
initcall setup_vmstat+0x0/0x3a returned 0 after 0 msecs
calling  mm_sysfs_init+0x0/0x2c
initcall mm_sysfs_init+0x0/0x2c returned 0 after 0 msecs
calling  procswaps_init+0x0/0x25
initcall procswaps_init+0x0/0x25 returned 0 after 0 msecs
calling  init_tmpfs+0x0/0xd8
initcall init_tmpfs+0x0/0xd8 returned 0 after 0 msecs
calling  slab_sysfs_init+0x0/0xf4
initcall slab_sysfs_init+0x0/0xf4 returned 0 after 3 msecs
calling  fasync_init+0x0/0x2d
initcall fasync_init+0x0/0x2d returned 0 after 0 msecs
calling  aio_setup+0x0/0x76
initcall aio_setup+0x0/0x76 returned 0 after 0 msecs
calling  inotify_setup+0x0/0xd
initcall inotify_setup+0x0/0xd returned 0 after 0 msecs
calling  inotify_user_setup+0x0/0xbf
initcall inotify_user_setup+0x0/0xbf returned 0 after 0 msecs
calling  init_sys32_ioctl+0x0/0x8a
initcall init_sys32_ioctl+0x0/0x8a returned 0 after 0 msecs
calling  dnotify_init+0x0/0x2d
initcall dnotify_init+0x0/0x2d returned 0 after 0 msecs
calling  init_devpts_fs+0x0/0x35
initcall init_devpts_fs+0x0/0x35 returned 0 after 0 msecs
calling  init_ext3_fs+0x0/0x56
initcall init_ext3_fs+0x0/0x56 returned 0 after 0 msecs
calling  journal_init+0x0/0x9e
initcall journal_init+0x0/0x9e returned 0 after 0 msecs
calling  init_ext2_fs+0x0/0x55
initcall init_ext2_fs+0x0/0x55 returned 0 after 0 msecs
calling  init_ramfs_fs+0x0/0xc
initcall init_ramfs_fs+0x0/0xc returned 0 after 0 msecs
calling  init_fat_fs+0x0/0x47
initcall init_fat_fs+0x0/0x47 returned 0 after 0 msecs
calling  init_msdos_fs+0x0/0xc
initcall init_msdos_fs+0x0/0xc returned 0 after 0 msecs
calling  init_vfat_fs+0x0/0xf
initcall init_vfat_fs+0x0/0xf returned 0 after 0 msecs
calling  init_iso9660_fs+0x0/0x6b
initcall init_iso9660_fs+0x0/0x6b returned 0 after 0 msecs
calling  init_nfs_fs+0x0/0x148
initcall init_nfs_fs+0x0/0x148 returned 0 after 0 msecs
calling  init_nfsd+0x0/0xc2
Installing knfsd (copyright (C) 1996 okir@monad.swb.de).
initcall init_nfsd+0x0/0xc2 returned 0 after 0 msecs
calling  init_nlm+0x0/0x25
initcall init_nlm+0x0/0x25 returned 0 after 0 msecs
calling  init_nls_cp437+0x0/0xc
initcall init_nls_cp437+0x0/0xc returned 0 after 0 msecs
calling  init_nls_iso8859_1+0x0/0xc
initcall init_nls_iso8859_1+0x0/0xc returned 0 after 0 msecs
calling  init_udf_fs+0x0/0x55
initcall init_udf_fs+0x0/0x55 returned 0 after 0 msecs
calling  ipc_init+0x0/0x26
msgmni has been set to 3727
initcall ipc_init+0x0/0x26 returned 0 after 0 msecs
calling  ipc_sysctl_init+0x0/0x17
initcall ipc_sysctl_init+0x0/0x17 returned 0 after 0 msecs
calling  crypto_algapi_init+0x0/0x10
initcall crypto_algapi_init+0x0/0x10 returned 0 after 0 msecs
calling  cryptomgr_init+0x0/0xc
initcall cryptomgr_init+0x0/0xc returned 0 after 0 msecs
calling  hmac_module_init+0x0/0xc
initcall hmac_module_init+0x0/0xc returned 0 after 0 msecs
calling  md5_mod_init+0x0/0xc
initcall md5_mod_init+0x0/0xc returned 0 after 0 msecs
calling  sha1_generic_mod_init+0x0/0xc
initcall sha1_generic_mod_init+0x0/0xc returned 0 after 0 msecs
calling  des_generic_mod_init+0x0/0x37
initcall des_generic_mod_init+0x0/0x37 returned 0 after 0 msecs
calling  deflate_mod_init+0x0/0x11
initcall deflate_mod_init+0x0/0x11 returned 0 after 0 msecs
calling  noop_init+0x0/0x17
io scheduler noop registered
initcall noop_init+0x0/0x17 returned 0 after 0 msecs
calling  deadline_init+0x0/0x19
io scheduler deadline registered
initcall deadline_init+0x0/0x19 returned 0 after 0 msecs
calling  cfq_init+0x0/0x9a
io scheduler cfq registered (default)
initcall cfq_init+0x0/0x9a returned 0 after 0 msecs
calling  pci_init+0x0/0x2f
pci 0000:01:05.0: Boot video device
initcall pci_init+0x0/0x2f returned 0 after 111 msecs
calling  pci_proc_init+0x0/0x63
initcall pci_proc_init+0x0/0x63 returned 0 after 0 msecs
calling  pcie_portdrv_init+0x0/0x43
initcall pcie_portdrv_init+0x0/0x43 returned 0 after 0 msecs
calling  aer_service_init+0x0/0x1c
initcall aer_service_init+0x0/0x1c returned 0 after 0 msecs
calling  fb_console_init+0x0/0x153
initcall fb_console_init+0x0/0x153 returned 0 after 0 msecs
calling  uvesafb_init+0x0/0x3d6
uvesafb: (C) 1988-2005, ATI Technologies Inc. RS69001.00, RS69001.00, 01.00, OEM: ATI ATOMBIOS(C) 1988-2005, ATI Technologies Inc. RS69001.00, VBE v3.0
uvesafb: VBIOS/hardware supports DDC2 transfers
uvesafb: no monitor limits have been set, default refresh rate will be used
uvesafb: scrolling: redraw
Console: switching to colour frame buffer device 128x56
uvesafb: framebuffer at 0xd8000000, mapped to 0xffffc20010c00000, using 16384k, total 16384k
fb0: VESA VGA frame buffer device
initcall uvesafb_init+0x0/0x3d6 returned 0 after 329 msecs
calling  acpi_reserve_resources+0x0/0xeb
initcall acpi_reserve_resources+0x0/0xeb returned 0 after 0 msecs
calling  acpi_button_init+0x0/0x5e
input: Power Button (FF) as /class/input/input0
ACPI: Power Button (FF) [PWRF]
input: Power Button (CM) as /class/input/input1
ACPI: Power Button (CM) [PWRB]
initcall acpi_button_init+0x0/0x5e returned 0 after 0 msecs
calling  acpi_fan_init+0x0/0x5e
fan PNP0C0B:00: registered as cooling_device0
ACPI: Fan [FAN] (on)
initcall acpi_fan_init+0x0/0x5e returned 0 after 0 msecs
calling  irqrouter_init_sysfs+0x0/0x39
initcall irqrouter_init_sysfs+0x0/0x39 returned 0 after 0 msecs
calling  acpi_processor_init+0x0/0xcd
processor ACPI0007:00: registered as cooling_device1
processor ACPI0007:01: registered as cooling_device2
initcall acpi_processor_init+0x0/0xcd returned 0 after 0 msecs
calling  acpi_thermal_init+0x0/0x84
thermal LNXTHERM:01: registered as thermal_zone0
ACPI: Thermal Zone [THRM] (17 C)
initcall acpi_thermal_init+0x0/0x84 returned 0 after 1 msecs
calling  rand_initialize+0x0/0x30
initcall rand_initialize+0x0/0x30 returned 0 after 0 msecs
calling  tty_init+0x0/0x1dc
initcall tty_init+0x0/0x1dc returned 0 after 25 msecs
calling  pty_init+0x0/0x2eb
initcall pty_init+0x0/0x2eb returned 0 after 0 msecs
calling  hpet_init+0x0/0x6f
hpet_acpi_add: no address or irqs in _CRS
initcall hpet_init+0x0/0x6f returned 0 after 1 msecs
calling  agp_init+0x0/0x2d
Linux agpgart interface v0.103
initcall agp_init+0x0/0x2d returned 0 after 1 msecs
calling  cn_proc_init+0x0/0x3f
initcall cn_proc_init+0x0/0x3f returned 0 after 0 msecs
calling  topology_sysfs_init+0x0/0x50
initcall topology_sysfs_init+0x0/0x50 returned 0 after 0 msecs
calling  loop_init+0x0/0x1ca
loop: module loaded
initcall loop_init+0x0/0x1ca returned 0 after 2 msecs
calling  pkt_init+0x0/0x1a9
initcall pkt_init+0x0/0x1a9 returned 0 after 0 msecs
calling  net_olddevs_init+0x0/0x97
initcall net_olddevs_init+0x0/0x97 returned 0 after 0 msecs
calling  rtl8169_init_module+0x0/0x1a
r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
r8169 0000:02:05.0: PCI INT A -> GSI 22 (level, low) -> IRQ 22
eth0: RTL8169sc/8110sc at 0xffffc20000336000, 00:1b:b9:f4:88:d0, XID 18000000 IRQ 22
initcall rtl8169_init_module+0x0/0x1a returned 0 after 7 msecs
calling  ide_init+0x0/0x72
Uniform Multi-Platform E-IDE driver
initcall ide_init+0x0/0x72 returned 0 after 2 msecs
calling  atiixp_ide_init+0x0/0x15
atiixp 0000:00:14.1: IDE controller (0x1002:0x438c rev 0x00)
ATIIXP_IDE 0000:00:14.1: PCI INT A -> GSI 16 (level, low) -> IRQ 16
atiixp 0000:00:14.1: not 100% native mode: will probe irqs later
    ide0: BM-DMA at 0xf900-0xf907
Probing IDE interface ide0...
hda: Maxtor 6H500R0, ATA DISK drive
hdb: SAMSUNG DVD-ROM SD-616E, ATAPI CD/DVD-ROM drive
hda: host max PIO4 wanted PIO255(auto-tune) selected PIO4
hda: UDMA/100 mode selected
hdb: host max PIO4 wanted PIO255(auto-tune) selected PIO4
hdb: UDMA/33 mode selected
ide0 at 0x1f0-0x1f7,0x3f6 on irq 14
isa bounce pool size: 16 pages
initcall atiixp_ide_init+0x0/0x15 returned 0 after 762 msecs
calling  generic_ide_init+0x0/0x15
initcall generic_ide_init+0x0/0x15 returned 0 after 0 msecs
calling  ide_generic_init+0x0/0x253
ide_generic: please use "probe_mask=0x3f" module parameter for probing all legacy ISA IDE ports
ide_generic: I/O resource 0x1F0-0x1F7 not free.
Probing IDE interface ide1...
ide1 at 0x170-0x177,0x376 on irq 15
initcall ide_generic_init+0x0/0x253 returned 0 after 518 msecs
calling  idedisk_init+0x0/0xc
hda: max request size: 512KiB
hda: 976773168 sectors (500107 MB) w/16384KiB Cache, CHS=60801/255/63
hda: cache flushes supported
 hda: hda1 hda2 hda3 < hda5 hda6 hda7 hda8 hda9 >
initcall idedisk_init+0x0/0xc returned 0 after 84 msecs
calling  ide_cdrom_init+0x0/0x15
hdb: ATAPI 48X DVD-ROM drive, 512kB Cache
Uniform CD-ROM driver Revision: 3.20
initcall ide_cdrom_init+0x0/0x15 returned 0 after 6 msecs
calling  init_sd+0x0/0x119
Driver 'sd' needs updating - please use bus_type methods
initcall init_sd+0x0/0x119 returned 0 after 2 msecs
calling  ahci_init+0x0/0x15
ahci 0000:00:12.0: version 3.0
ahci 0000:00:12.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
ahci 0000:00:12.0: controller can't do 64bit DMA, forcing 32bit
ahci 0000:00:12.0: AHCI 0001.0100 32 slots 4 ports 3 Gbps 0xf impl SATA mode
ahci 0000:00:12.0: flags: ncq sntf ilck led clo pmp pio 
scsi0 : ahci
scsi1 : ahci
scsi2 : ahci
scsi3 : ahci
ata1: SATA max UDMA/133 abar m1024@0xfe02f000 port 0xfe02f100 irq 16
ata2: SATA max UDMA/133 abar m1024@0xfe02f000 port 0xfe02f180 irq 16
ata3: SATA max UDMA/133 abar m1024@0xfe02f000 port 0xfe02f200 irq 16
ata4: SATA max UDMA/133 abar m1024@0xfe02f000 port 0xfe02f280 irq 16
ata1: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
ata1.00: ATA-8: WDC WD5000AACS-00ZUB0, 01.01B01, max UDMA/133
ata1.00: 976773168 sectors, multi 16: LBA48 NCQ (depth 31/32)
ata1.00: SB600 AHCI: limiting to 255 sectors per cmd
ata1.00: SB600 AHCI: limiting to 255 sectors per cmd
ata1.00: configured for UDMA/133
ata2: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
ata2.00: ATA-8: WDC WD5000AACS-00ZUB0, 01.01B01, max UDMA/133
ata2.00: 976773168 sectors, multi 16: LBA48 NCQ (depth 31/32)
ata2.00: SB600 AHCI: limiting to 255 sectors per cmd
ata2.00: SB600 AHCI: limiting to 255 sectors per cmd
ata2.00: configured for UDMA/133
ata3: SATA link down (SStatus 0 SControl 300)
ata4: SATA link down (SStatus 0 SControl 300)
scsi 0:0:0:0: Direct-Access     ATA      WDC WD5000AACS-0 01.0 PQ: 0 ANSI: 5
sd 0:0:0:0: [sda] 976773168 512-byte hardware sectors (500108 MB)
sd 0:0:0:0: [sda] Write Protect is off
sd 0:0:0:0: [sda] Mode Sense: 00 3a 00 00
sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
sd 0:0:0:0: [sda] 976773168 512-byte hardware sectors (500108 MB)
sd 0:0:0:0: [sda] Write Protect is off
sd 0:0:0:0: [sda] Mode Sense: 00 3a 00 00
sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
 sda: unknown partition table
sd 0:0:0:0: [sda] Attached SCSI disk
scsi 1:0:0:0: Direct-Access     ATA      WDC WD5000AACS-0 01.0 PQ: 0 ANSI: 5
sd 1:0:0:0: [sdb] 976773168 512-byte hardware sectors (500108 MB)
sd 1:0:0:0: [sdb] Write Protect is off
sd 1:0:0:0: [sdb] Mode Sense: 00 3a 00 00
sd 1:0:0:0: [sdb] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
sd 1:0:0:0: [sdb] 976773168 512-byte hardware sectors (500108 MB)
sd 1:0:0:0: [sdb] Write Protect is off
sd 1:0:0:0: [sdb] Mode Sense: 00 3a 00 00
sd 1:0:0:0: [sdb] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
 sdb: unknown partition table
sd 1:0:0:0: [sdb] Attached SCSI disk
initcall ahci_init+0x0/0x15 returned 0 after 2060 msecs
calling  cdrom_init+0x0/0x75
initcall cdrom_init+0x0/0x75 returned 0 after 0 msecs
calling  ehci_hcd_init+0x0/0x15
ehci_hcd 0000:00:13.5: PCI INT D -> GSI 19 (level, low) -> IRQ 19
ehci_hcd 0000:00:13.5: EHCI Host Controller
ehci_hcd 0000:00:13.5: new USB bus registered, assigned bus number 1
ehci_hcd 0000:00:13.5: debug port 1
ehci_hcd 0000:00:13.5: irq 19, io mem 0xfe029000
ehci_hcd 0000:00:13.5: USB 2.0 started, EHCI 1.00, driver 10 Dec 2004
usb usb1: configuration #1 chosen from 1 choice
hub 1-0:1.0: USB hub found
hub 1-0:1.0: 10 ports detected
initcall ehci_hcd_init+0x0/0x15 returned 0 after 122 msecs
calling  ohci_hcd_mod_init+0x0/0x45
ohci_hcd: 2006 August 04 USB 1.1 'Open' Host Controller (OHCI) Driver
ohci_hcd 0000:00:13.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
ohci_hcd 0000:00:13.0: OHCI Host Controller
ohci_hcd 0000:00:13.0: new USB bus registered, assigned bus number 2
ohci_hcd 0000:00:13.0: irq 16, io mem 0xfe02e000
usb usb2: configuration #1 chosen from 1 choice
hub 2-0:1.0: USB hub found
hub 2-0:1.0: 2 ports detected
ohci_hcd 0000:00:13.1: PCI INT B -> GSI 17 (level, low) -> IRQ 17
ohci_hcd 0000:00:13.1: OHCI Host Controller
ohci_hcd 0000:00:13.1: new USB bus registered, assigned bus number 3
ohci_hcd 0000:00:13.1: irq 17, io mem 0xfe02d000
usb usb3: configuration #1 chosen from 1 choice
hub 3-0:1.0: USB hub found
hub 3-0:1.0: 2 ports detected
ohci_hcd 0000:00:13.2: PCI INT C -> GSI 18 (level, low) -> IRQ 18
ohci_hcd 0000:00:13.2: OHCI Host Controller
ohci_hcd 0000:00:13.2: new USB bus registered, assigned bus number 4
ohci_hcd 0000:00:13.2: irq 18, io mem 0xfe02c000
usb usb4: configuration #1 chosen from 1 choice
hub 4-0:1.0: USB hub found
hub 4-0:1.0: 2 ports detected
ohci_hcd 0000:00:13.3: PCI INT B -> GSI 17 (level, low) -> IRQ 17
ohci_hcd 0000:00:13.3: OHCI Host Controller
ohci_hcd 0000:00:13.3: new USB bus registered, assigned bus number 5
ohci_hcd 0000:00:13.3: irq 17, io mem 0xfe02b000
usb usb5: configuration #1 chosen from 1 choice
hub 5-0:1.0: USB hub found
hub 5-0:1.0: 2 ports detected
ohci_hcd 0000:00:13.4: PCI INT C -> GSI 18 (level, low) -> IRQ 18
ohci_hcd 0000:00:13.4: OHCI Host Controller
ohci_hcd 0000:00:13.4: new USB bus registered, assigned bus number 6
ohci_hcd 0000:00:13.4: irq 18, io mem 0xfe02a000
usb usb6: configuration #1 chosen from 1 choice
hub 6-0:1.0: USB hub found
hub 6-0:1.0: 2 ports detected
initcall ohci_hcd_mod_init+0x0/0x45 returned 0 after 828 msecs
calling  usb_stor_init+0x0/0x4d
Initializing USB Mass Storage driver...
usbcore: registered new interface driver usb-storage
USB Mass Storage support registered.
initcall usb_stor_init+0x0/0x4d returned 0 after 6 msecs
calling  i8042_init+0x0/0x40b
PNP: PS/2 Controller [PNP0303:PS2K,PNP0f13:PS2M] at 0x60,0x64 irq 1,12
serio: i8042 KBD port at 0x60,0x64 irq 1
serio: i8042 AUX port at 0x60,0x64 irq 12
initcall i8042_init+0x0/0x40b returned 0 after 7 msecs
calling  mousedev_init+0x0/0x59
mice: PS/2 mouse device common for all mice
initcall mousedev_init+0x0/0x59 returned 0 after 2 msecs
calling  atkbd_init+0x0/0x29
initcall atkbd_init+0x0/0x29 returned 0 after 0 msecs
calling  psmouse_init+0x0/0x68
initcall psmouse_init+0x0/0x68 returned 0 after 0 msecs
calling  i2c_dev_init+0x0/0x9d
i2c /dev entries driver
initcall i2c_dev_init+0x0/0x9d returned 0 after 2 msecs
calling  i2c_piix4_init+0x0/0x15
piix4_smbus 0000:00:14.0: SMBus Host Controller at 0xfa00, revision 0
initcall i2c_piix4_init+0x0/0x15 returned 0 after 2 msecs
calling  k8temp_init+0x0/0x15
initcall k8temp_init+0x0/0x15 returned 0 after 0 msecs
calling  init_ladder+0x0/0xc
cpuidle: using governor ladder
initcall init_ladder+0x0/0xc returned 0 after 2 msecs
calling  init_menu+0x0/0xe
cpuidle: using governor menu
initcall init_menu+0x0/0xe returned 0 after 0 msecs
calling  hid_init+0x0/0x10
initcall hid_init+0x0/0x10 returned 0 after 0 msecs
calling  hid_init+0x0/0x62
usbcore: registered new interface driver hiddev
usbcore: registered new interface driver usbhid
usbhid: v2.6:USB HID core driver
initcall hid_init+0x0/0x62 returned 0 after 21 msecs
calling  init_soundcore+0x0/0x70
initcall init_soundcore+0x0/0x70 returned 0 after 0 msecs
calling  alsa_sound_init+0x0/0x90
Advanced Linux Sound Architecture Driver Version 1.0.17.
initcall alsa_sound_init+0x0/0x90 returned 0 after 2 msecs
calling  alsa_timer_init+0x0/0x195
initcall alsa_timer_init+0x0/0x195 returned 0 after 0 msecs
calling  alsa_pcm_init+0x0/0x64
initcall alsa_pcm_init+0x0/0x64 returned 0 after 0 msecs
calling  snd_mem_init+0x0/0x2f
initcall snd_mem_init+0x0/0x2f returned 0 after 0 msecs
calling  alsa_mixer_oss_init+0x0/0x33
initcall alsa_mixer_oss_init+0x0/0x33 returned 0 after 0 msecs
calling  alsa_pcm_oss_init+0x0/0x85
initcall alsa_pcm_oss_init+0x0/0x85 returned 0 after 0 msecs
calling  alsa_seq_oss_init+0x0/0x194
initcall alsa_seq_oss_init+0x0/0x194 returned 0 after 0 msecs
calling  alsa_seq_init+0x0/0x50
initcall alsa_seq_init+0x0/0x50 returned 0 after 0 msecs
calling  alsa_seq_device_init+0x0/0x60
initcall alsa_seq_device_init+0x0/0x60 returned 0 after 0 msecs
calling  alsa_seq_midi_event_init+0x0/0x3
initcall alsa_seq_midi_event_init+0x0/0x3 returned 0 after 0 msecs
calling  alsa_card_azx_init+0x0/0x15
HDA Intel 0000:00:14.2: PCI INT A -> GSI 16 (level, low) -> IRQ 16
hda_codec: Unknown model for ALC883, trying auto-probe from BIOS...
HDA Intel 0000:01:05.2: PCI INT B -> GSI 19 (level, low) -> IRQ 19
initcall alsa_card_azx_init+0x0/0x15 returned 0 after 94 msecs
calling  alsa_sound_last_init+0x0/0x6b
ALSA device list:
  #0: HDA ATI SB at 0xfe020000 irq 16
  #1: HDA ATI HDMI at 0xfdefc000 irq 19
initcall alsa_sound_last_init+0x0/0x6b returned 0 after 6 msecs
calling  sysctl_core_init+0x0/0x27
initcall sysctl_core_init+0x0/0x27 returned 0 after 0 msecs
calling  flow_cache_init+0x0/0x1b5
initcall flow_cache_init+0x0/0x1b5 returned 0 after 0 msecs
calling  sysctl_ipv4_init+0x0/0x4a
initcall sysctl_ipv4_init+0x0/0x4a returned 0 after 0 msecs
calling  cubictcp_register+0x0/0x6b
TCP cubic registered
initcall cubictcp_register+0x0/0x6b returned 0 after 2 msecs
calling  xfrm_user_init+0x0/0x5c
Initializing XFRM netlink socket
initcall xfrm_user_init+0x0/0x5c returned 0 after 2 msecs
calling  packet_init+0x0/0x49
NET: Registered protocol family 17
initcall packet_init+0x0/0x49 returned 0 after 2 msecs
calling  init_sunrpc+0x0/0x6a
RPC: Registered udp transport module.
RPC: Registered tcp transport module.
initcall init_sunrpc+0x0/0x6a returned 0 after 4 msecs
calling  powernowk8_init+0x0/0x94
powernow-k8: Found 1 AMD Processor model unknown processors (2 cpu cores) (version 2.20.00)
powernow-k8:    0 : fid 0x11 (2500 MHz), vid 0xc
powernow-k8:    1 : fid 0x10 (2400 MHz), vid 0xd
powernow-k8:    2 : fid 0xe (2200 MHz), vid 0xf
powernow-k8:    3 : fid 0xc (2000 MHz), vid 0x11
powernow-k8:    4 : fid 0xa (1800 MHz), vid 0x13
powernow-k8:    5 : fid 0x2 (1000 MHz), vid 0x16
initcall powernowk8_init+0x0/0x94 returned 0 after 14 msecs
calling  hpet_insert_resource+0x0/0x1e
initcall hpet_insert_resource+0x0/0x1e returned 0 after 0 msecs
calling  update_mp_table+0x0/0x68e
initcall update_mp_table+0x0/0x68e returned 0 after 0 msecs
calling  lapic_insert_resource+0x0/0x45
initcall lapic_insert_resource+0x0/0x45 returned 0 after 0 msecs
calling  init_lapic_nmi_sysfs+0x0/0x3e
initcall init_lapic_nmi_sysfs+0x0/0x3e returned 0 after 0 msecs
calling  ioapic_insert_resources+0x0/0x59
initcall ioapic_insert_resources+0x0/0x59 returned 0 after 0 msecs
calling  check_early_ioremap_leak+0x0/0x49
initcall check_early_ioremap_leak+0x0/0x49 returned 0 after 0 msecs
calling  sched_init_debug+0x0/0x8
initcall sched_init_debug+0x0/0x8 returned 0 after 0 msecs
calling  init_oops_id+0x0/0x30
initcall init_oops_id+0x0/0x30 returned 0 after 0 msecs
calling  disable_boot_consoles+0x0/0x3f
initcall disable_boot_consoles+0x0/0x3f returned 0 after 0 msecs
calling  pm_qos_power_init+0x0/0xd4
initcall pm_qos_power_init+0x0/0xd4 returned 0 after 0 msecs
calling  random32_reseed+0x0/0x99
initcall random32_reseed+0x0/0x99 returned 0 after 0 msecs
calling  pci_sysfs_init+0x0/0x4d
initcall pci_sysfs_init+0x0/0x4d returned 0 after 0 msecs
calling  acpi_wakeup_device_init+0x0/0xaf
initcall acpi_wakeup_device_init+0x0/0xaf returned 0 after 0 msecs
calling  seqgen_init+0x0/0x1e
initcall seqgen_init+0x0/0x1e returned 0 after 0 msecs
calling  scsi_complete_async_scans+0x0/0x120
initcall scsi_complete_async_scans+0x0/0x120 returned 0 after 0 msecs
calling  memmap_init+0x0/0xa7
initcall memmap_init+0x0/0xa7 returned 0 after 0 msecs
calling  pci_mmcfg_late_insert_resources+0x0/0x47
initcall pci_mmcfg_late_insert_resources+0x0/0x47 returned 0 after 0 msecs
calling  tcp_congestion_default+0x0/0xc
initcall tcp_congestion_default+0x0/0xc returned 0 after 0 msecs
input: ImExPS/2 Generic Explorer Mouse as /class/input/input2
input: AT Translated Set 2 keyboard as /class/input/input3
VFS: Mounted root (ext2 filesystem) readonly.
Freeing unused kernel memory: 512k freed
Write protecting the kernel read-only data: 4972k
calling  evdev_init+0x0/0xc [evdev]
initcall evdev_init+0x0/0xc [evdev] returned 0 after 95 msecs
calling  pcspkr_init+0x0/0xc [pcspkr]
input: PC Speaker as /class/input/input4
initcall pcspkr_init+0x0/0xc [pcspkr] returned 0 after 29 msecs
Adding 1951888k swap on /dev/hda2.  Priority:-1 extents:1 across:1951888k
calling  cpufreq_gov_userspace_init+0x0/0xc [cpufreq_userspace]
initcall cpufreq_gov_userspace_init+0x0/0xc [cpufreq_userspace] returned 0 after 0 msecs
kjournald starting.  Commit interval 5 seconds
EXT3 FS on hda9, internal journal
EXT3-fs: mounted filesystem with ordered data mode.
kjournald starting.  Commit interval 5 seconds
EXT3 FS on hda8, internal journal
EXT3-fs: mounted filesystem with ordered data mode.
kjournald starting.  Commit interval 5 seconds
EXT3 FS on hda6, internal journal
EXT3-fs: mounted filesystem with ordered data mode.
kjournald starting.  Commit interval 5 seconds
EXT3 FS on hda7, internal journal
EXT3-fs: mounted filesystem with ordered data mode.
r8169: eth0: link up
calling  inet6_init+0x0/0x360 [ipv6]
NET: Registered protocol family 10
initcall inet6_init+0x0/0x360 [ipv6] returned 0 after 4 msecs
Clocksource tsc unstable (delta = -85223910 ns)
eth0: no IPv6 routers present
warning: `ntpd' uses 32-bit capabilities (legacy support in use)


$ lspci -vvxxx
00:00.0 Host bridge: ATI Technologies Inc RS690 Host Bridge
    Subsystem: ATI Technologies Inc RS690 Host Bridge
    Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
    Status: Cap- 66MHz+ UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort+ >SERR- <PERR- INTx-
    Latency: 64
00: 02 10 10 79 06 00 20 22 00 00 00 06 00 40 00 00
10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 02 10 10 79
30: 00 00 00 00 c4 00 00 00 00 00 00 00 00 00 00 00
40: 00 00 00 00 00 00 00 00 00 00 00 00 42 20 05 00
50: 02 10 10 79 ff 00 00 00 00 00 00 00 00 00 00 00
60: 5f 00 00 00 00 00 00 00 00 02 20 00 98 f8 01 00
70: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
80: 40 44 00 00 95 00 00 03 20 01 10 00 02 27 00 00
90: 00 00 00 78 40 c4 40 e3 00 00 00 00 01 00 00 00
a0: 00 00 00 00 00 00 00 00 07 01 00 00 49 01 10 07
b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
c0: 00 00 00 00 08 00 94 01 60 00 11 11 d0 00 00 00
d0: 25 06 65 00 02 00 00 00 00 00 00 00 00 00 00 00
e0: 00 00 00 00 00 00 00 00 7f 00 00 00 00 00 00 00
f0: 00 00 00 00 00 80 80 00 00 00 00 00 00 00 00 00

00:01.0 PCI bridge: ATI Technologies Inc RS690 PCI to PCI Bridge (Internal gfx)
    Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
    Status: Cap+ 66MHz+ UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
    Latency: 99
    Bus: primary=00, secondary=01, subordinate=01, sec-latency=68
    I/O behind bridge: 0000e000-0000efff
    Memory behind bridge: fdd00000-fdefffff
    Prefetchable memory behind bridge: 00000000d8000000-00000000dfffffff
    Secondary status: 66MHz+ FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- <SERR- <PERR-
    BridgeCtl: Parity- SERR- NoISA- VGA+ MAbort- >Reset- FastB2B-
        PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
    Capabilities: [44] HyperTransport: MSI Mapping Enable+ Fixed+
    Capabilities: [b0] Subsystem: ATI Technologies Inc RS690 PCI to PCI Bridge (Internal gfx)
00: 02 10 12 79 07 00 30 02 00 00 04 06 00 63 01 00
10: 00 00 00 00 00 00 00 00 00 01 01 44 e1 e1 20 02
20: d0 fd e0 fd 01 d8 f1 df 00 00 00 00 00 00 00 00
30: 00 00 00 00 44 00 00 00 00 00 00 00 ff 00 08 00
40: 00 00 00 00 08 b0 03 a8 00 00 00 00 02 10 12 79
50: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
60: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
70: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
90: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
b0: 0d 00 00 00 02 10 12 79 00 00 00 00 00 00 00 00
c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
d0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
f0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

00:12.0 SATA controller: ATI Technologies Inc SB600 Non-Raid-5 SATA (prog-if 01)
    Subsystem: Elitegroup Computer Systems Device 4382
    Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
    Status: Cap+ 66MHz+ UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
    Latency: 64
    Interrupt: pin A routed to IRQ 16
    Region 0: I/O ports at ff00 [size=8]
    Region 1: I/O ports at fe00 [size=4]
    Region 2: I/O ports at fd00 [size=8]
    Region 3: I/O ports at fc00 [size=4]
    Region 4: I/O ports at fb00 [size=16]
    Region 5: Memory at fe02f000 (32-bit, non-prefetchable) [size=1K]
    Capabilities: [60] Power Management version 2
        Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
        Status: D0 PME-Enable- DSel=0 DScale=0 PME-
    Capabilities: [70] SATA HBA <?>
    Kernel driver in use: ahci
00: 02 10 80 43 07 00 30 02 00 01 06 01 00 40 00 00
10: 01 ff 00 00 01 fe 00 00 01 fd 00 00 01 fc 00 00
20: 01 fb 00 00 00 f0 02 fe 00 00 00 00 19 10 82 43
30: 00 00 00 00 60 00 00 00 00 00 00 00 0b 01 00 00
40: 10 00 80 02 01 00 10 00 01 00 00 00 00 00 00 00
50: 05 70 84 00 00 00 00 00 00 00 00 00 00 00 00 00
60: 01 70 22 00 00 00 00 00 00 00 00 00 00 00 00 00
70: 12 00 10 00 0f 00 00 00 00 00 00 00 00 00 00 00
80: 00 00 00 00 06 00 00 2c d5 00 b4 00 d5 00 b4 00
90: d5 00 b4 00 d5 00 b4 00 00 00 00 00 00 00 00 00
a0: 00 00 00 00 00 78 00 00 00 00 00 00 00 78 00 00
b0: 00 00 00 00 00 78 00 00 00 00 00 00 00 78 00 00
c0: 00 20 00 00 80 00 00 00 00 00 00 00 00 00 00 00
d0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
f0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

00:13.0 USB Controller: ATI Technologies Inc SB600 USB (OHCI0) (prog-if 10)
    Subsystem: Elitegroup Computer Systems Device 2621
    Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
    Status: Cap- 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
    Latency: 64, Cache Line Size: 4 bytes
    Interrupt: pin A routed to IRQ 16
    Region 0: Memory at fe02e000 (32-bit, non-prefetchable) [size=4K]
    Kernel driver in use: ohci_hcd
00: 02 10 87 43 07 00 a0 02 00 10 03 0c 01 40 80 00
10: 00 e0 02 fe 00 00 00 00 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 19 10 21 26
30: 00 00 00 00 00 00 00 00 00 00 00 00 0b 01 00 00
40: 80 1f 00 00 0a 84 b7 18 07 35 00 00 00 00 00 00
50: 00 1c 00 00 00 00 00 00 ff ff ff ff ff 00 00 00
60: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
70: 00 00 00 00 ff 00 00 80 00 00 00 00 00 00 00 00
80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
90: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
d0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
f0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

00:13.1 USB Controller: ATI Technologies Inc SB600 USB (OHCI1) (prog-if 10)
    Subsystem: Elitegroup Computer Systems Device 2621
    Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
    Status: Cap- 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
    Latency: 64, Cache Line Size: 4 bytes
    Interrupt: pin B routed to IRQ 17
    Region 0: Memory at fe02d000 (32-bit, non-prefetchable) [size=4K]
    Kernel driver in use: ohci_hcd
00: 02 10 88 43 07 00 a0 02 00 10 03 0c 01 40 00 00
10: 00 d0 02 fe 00 00 00 00 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 19 10 21 26
30: 00 00 00 00 00 00 00 00 00 00 00 00 0b 02 00 00
40: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
50: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
60: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
70: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
90: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
d0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
f0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

00:13.2 USB Controller: ATI Technologies Inc SB600 USB (OHCI2) (prog-if 10)
    Subsystem: Elitegroup Computer Systems Device 2621
    Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
    Status: Cap- 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
    Latency: 64, Cache Line Size: 4 bytes
    Interrupt: pin C routed to IRQ 18
    Region 0: Memory at fe02c000 (32-bit, non-prefetchable) [size=4K]
    Kernel driver in use: ohci_hcd
00: 02 10 89 43 07 00 a0 02 00 10 03 0c 01 40 00 00
10: 00 c0 02 fe 00 00 00 00 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 19 10 21 26
30: 00 00 00 00 00 00 00 00 00 00 00 00 0b 03 00 00
40: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
50: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
60: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
70: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
90: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
d0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
f0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

00:13.3 USB Controller: ATI Technologies Inc SB600 USB (OHCI3) (prog-if 10)
    Subsystem: Elitegroup Computer Systems Device 2621
    Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
    Status: Cap- 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
    Latency: 64, Cache Line Size: 4 bytes
    Interrupt: pin B routed to IRQ 17
    Region 0: Memory at fe02b000 (32-bit, non-prefetchable) [size=4K]
    Kernel driver in use: ohci_hcd
00: 02 10 8a 43 07 00 a0 02 00 10 03 0c 01 40 00 00
10: 00 b0 02 fe 00 00 00 00 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 19 10 21 26
30: 00 00 00 00 00 00 00 00 00 00 00 00 0b 02 00 00
40: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
50: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
60: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
70: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
90: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
d0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
f0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

00:13.4 USB Controller: ATI Technologies Inc SB600 USB (OHCI4) (prog-if 10)
    Subsystem: Elitegroup Computer Systems Device 2621
    Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
    Status: Cap- 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
    Latency: 64, Cache Line Size: 4 bytes
    Interrupt: pin C routed to IRQ 18
    Region 0: Memory at fe02a000 (32-bit, non-prefetchable) [size=4K]
    Kernel driver in use: ohci_hcd
00: 02 10 8b 43 07 00 a0 02 00 10 03 0c 01 40 00 00
10: 00 a0 02 fe 00 00 00 00 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 19 10 21 26
30: 00 00 00 00 00 00 00 00 00 00 00 00 0b 03 00 00
40: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
50: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
60: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
70: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
90: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
d0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
f0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

00:13.5 USB Controller: ATI Technologies Inc SB600 USB Controller (EHCI) (prog-if 20)
    Subsystem: Elitegroup Computer Systems Device 2621
    Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
    Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
    Latency: 64, Cache Line Size: 64 bytes
    Interrupt: pin D routed to IRQ 19
    Region 0: Memory at fe029000 (32-bit, non-prefetchable) [size=256]
    Capabilities: [c0] Power Management version 2
        Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA PME(D0+,D1+,D2+,D3hot+,D3cold-)
        Status: D0 PME-Enable- DSel=0 DScale=0 PME-
        Bridge: PM- B3+
    Capabilities: [e4] Debug port: BAR=1 offset=00e0
    Kernel driver in use: ehci_hcd
00: 02 10 86 43 17 00 b0 02 00 20 03 0c 10 40 00 00
10: 00 90 02 fe 00 00 00 00 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 19 10 21 26
30: 00 00 00 00 c0 00 00 00 00 00 00 00 0b 04 00 00
40: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
50: 40 00 0e 00 00 00 00 00 00 00 00 00 00 00 00 00
60: 20 20 00 00 00 00 00 00 00 00 00 00 00 00 00 00
70: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
90: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
a0: 01 00 00 01 00 00 08 c0 00 00 00 00 00 00 00 00
b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
c0: 01 e4 02 7e 00 00 40 00 00 00 00 00 00 00 00 00
d0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
e0: 00 00 00 00 0a 00 e0 20 00 00 00 00 00 00 00 00
f0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

00:14.0 SMBus: ATI Technologies Inc SBx00 SMBus Controller (rev 13)
    Subsystem: Elitegroup Computer Systems Device 2621
    Control: I/O+ Mem+ BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+
    Status: Cap+ 66MHz+ UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
    Region 0: I/O ports at fa00 [size=16]
    Region 1: Memory at 80000000 (32-bit, non-prefetchable) [size=1K]
    Capabilities: [b0] HyperTransport: MSI Mapping Enable- Fixed+
    Kernel driver in use: piix4_smbus
00: 02 10 85 43 03 04 30 02 13 00 05 0c 00 00 80 00
10: 01 fa 00 00 00 00 00 80 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 19 10 21 26
30: 00 00 00 00 b0 00 00 00 00 00 00 00 00 00 00 00
40: d4 3b 00 05 00 00 00 00 0f ff 00 00 00 00 00 00
50: f0 01 f0 0e f0 0f f0 07 11 0b f0 0f 00 00 00 00
60: 01 00 24 00 bf fd de 8f 3f 90 00 00 20 00 00 00
70: 00 01 00 00 08 00 c0 fe ff 6e 00 00 00 00 f0 0f
80: f0 0a f0 0f 00 00 00 00 00 00 00 00 8c 00 00 80
90: 01 fa 00 00 fa de ff 00 00 00 00 00 00 00 00 00
a0: 00 00 ff ff ff ff f0 08 ff fd 12 02 16 7b 20 00
b0: 08 00 02 a8 00 00 00 00 00 00 00 00 f0 0f 08 1a
c0: ff ff ff ff 00 00 00 00 00 00 00 00 00 00 00 00
d0: 00 00 01 00 00 00 00 00 00 00 00 00 00 00 00 00
e0: 20 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
f0: d8 0c 00 00 00 00 44 00 00 00 00 00 aa 00 10 01

00:14.1 IDE interface: ATI Technologies Inc SB600 IDE (prog-if 8a [Master SecP PriP])
    Subsystem: Elitegroup Computer Systems Device 2621
    Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
    Status: Cap+ 66MHz+ UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
    Latency: 64
    Interrupt: pin A routed to IRQ 16
    Region 0: I/O ports at 01f0 [size=8]
    Region 1: I/O ports at 03f4 [size=1]
    Region 2: I/O ports at 0170 [size=8]
    Region 3: I/O ports at 0374 [size=1]
    Region 4: I/O ports at f900 [size=16]
    Capabilities: [70] Message Signalled Interrupts: Mask- 64bit- Queue=0/0 Enable-
        Address: 00000000  Data: 0000
    Kernel driver in use: ATIIXP_IDE
00: 02 10 8c 43 05 00 30 02 00 8a 01 01 00 40 00 00
10: 01 00 00 00 01 00 00 00 01 00 00 00 01 00 00 00
20: 01 f9 00 00 00 00 00 00 00 00 00 00 19 10 21 26
30: 00 00 00 00 70 00 00 00 00 00 00 00 ff 01 00 00
40: 20 20 00 00 20 20 00 00 00 00 44 00 00 00 00 00
50: 00 00 00 00 03 00 25 00 00 00 00 00 00 00 00 00
60: 00 00 40 00 10 2c 01 07 01 00 00 00 ff ff 0f 00
70: 05 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
90: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
d0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
f0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

00:14.2 Audio device: ATI Technologies Inc SBx00 Azalia
    Subsystem: Elitegroup Computer Systems Device 2621
    Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
    Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=slow >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
    Latency: 64, Cache Line Size: 4 bytes
    Interrupt: pin ? routed to IRQ 16
    Region 0: Memory at fe020000 (64-bit, non-prefetchable) [size=16K]
    Capabilities: [50] Power Management version 2
        Flags: PMEClk- DSI- D1- D2- AuxCurrent=55mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
        Status: D0 PME-Enable- DSel=0 DScale=0 PME-
    Capabilities: [60] Message Signalled Interrupts: Mask- 64bit+ Queue=0/0 Enable-
        Address: 0000000000000000  Data: 0000
    Kernel driver in use: HDA Intel
00: 02 10 83 43 06 00 10 04 00 00 03 04 01 40 00 00
10: 04 00 02 fe 00 00 00 00 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 19 10 21 26
30: 00 00 00 00 50 00 00 00 00 00 00 00 03 00 00 00
40: 00 00 02 00 00 00 00 00 00 00 00 00 01 00 00 00
50: 01 60 42 c8 00 00 00 00 00 00 00 00 00 00 00 00
60: 05 00 80 00 00 00 00 00 00 00 00 00 00 00 00 00
70: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
90: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
d0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
f0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

00:14.3 ISA bridge: ATI Technologies Inc SB600 PCI to LPC Bridge
    Subsystem: Elitegroup Computer Systems Device 2621
    Control: I/O+ Mem+ BusMaster+ SpecCycle+ MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
    Status: Cap- 66MHz+ UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
    Latency: 0
00: 02 10 8d 43 0f 00 20 02 00 00 01 06 00 00 80 00
10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 19 10 21 26
30: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
40: 04 00 00 00 ff ff c3 ff 3f ff 42 00 00 00 00 00
50: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
60: 00 00 00 00 00 0a 00 00 0e 00 0f 00 f8 ff ff ff
70: 67 45 23 01 00 00 00 00 01 00 00 00 05 00 00 00
80: 08 00 03 a8 00 00 00 00 00 00 00 00 00 00 00 00
90: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
b0: 01 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
d0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
f0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

00:14.4 PCI bridge: ATI Technologies Inc SBx00 PCI to PCI Bridge (prog-if 01)
    Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop+ ParErr- Stepping- SERR- FastB2B- DisINTx-
    Status: Cap- 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
    Latency: 64
    Bus: primary=00, secondary=02, subordinate=02, sec-latency=64
    I/O behind bridge: 0000d000-0000dfff
    Memory behind bridge: fdc00000-fdcfffff
    Prefetchable memory behind bridge: fdf00000-fdffffff
    Secondary status: 66MHz- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort+ <SERR- <PERR-
    BridgeCtl: Parity- SERR- NoISA- VGA- MAbort- >Reset- FastB2B-
        PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
00: 02 10 84 43 27 00 a0 02 00 01 04 06 00 40 81 00
10: 00 00 00 00 00 00 00 00 00 02 02 40 d0 d0 80 22
20: c0 fd c0 fd f0 fd f0 fd 00 00 00 00 00 00 00 00
30: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
40: 26 00 30 ff 00 00 00 00 0c 01 3e d1 00 00 00 00
50: 01 00 00 00 08 00 03 a8 00 00 00 00 85 00 ff ff
60: ca 0e 17 00 8a 18 10 00 00 00 00 00 00 00 00 00
70: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
90: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
d0: 00 00 00 00 00 00 00 00 00 00 00 00 01 00 02 06
e0: 00 00 80 00 00 00 00 00 00 00 00 00 00 00 00 00
f0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

00:18.0 Host bridge: Advanced Micro Devices [AMD] K8 [Athlon64/Opteron] HyperTransport Technology Configuration
    Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
    Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
    Capabilities: [80] HyperTransport: Host or Secondary Interface
        !!! Possibly incomplete decoding
        Command: WarmRst+ DblEnd-
        Link Control: CFlE- CST- CFE- <LkFail- Init+ EOC- TXO- <CRCErr=0
        Link Config: MLWI=16bit MLWO=16bit LWI=16bit LWO=16bit
        Revision ID: 1.02
00: 22 10 00 11 00 00 10 00 00 00 00 06 00 00 80 00
10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
30: 00 00 00 00 80 00 00 00 00 00 00 00 00 00 00 00
40: 01 01 01 00 01 01 01 00 01 01 01 00 01 01 01 00
50: 01 01 01 00 01 01 01 00 01 01 01 00 01 01 01 00
60: 00 00 01 00 e4 00 00 00 20 c8 2f 0f 0c 00 00 00
70: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
80: 08 00 01 21 20 00 11 11 22 06 75 80 02 00 00 00
90: 78 01 70 01 00 00 02 00 07 00 00 00 00 00 00 00
a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
d0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
f0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

00:18.1 Host bridge: Advanced Micro Devices [AMD] K8 [Athlon64/Opteron] Address Map
    Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
    Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
00: 22 10 01 11 00 00 00 00 00 00 00 06 00 00 80 00
10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
30: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
40: 03 00 00 00 00 00 7f 00 00 00 00 00 01 00 00 00
50: 00 00 00 00 02 00 00 00 00 00 00 00 03 00 00 00
60: 00 00 00 00 04 00 00 00 00 00 00 00 05 00 00 00
70: 00 00 00 00 06 00 00 00 00 00 00 00 07 00 00 00
80: 03 0a 00 00 00 0b 00 00 03 00 d8 00 80 ff df 00
90: 03 00 80 00 00 ff d7 00 00 00 00 00 00 00 00 00
a0: 00 00 00 00 00 00 00 00 03 00 f0 00 00 02 fe 00
b0: 03 00 e0 00 80 2f e0 00 00 00 00 00 00 00 00 00
c0: 13 d0 00 00 00 f0 00 00 00 00 00 00 00 00 00 00
d0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
e0: 03 00 00 02 00 00 00 00 00 00 00 00 00 00 00 00
f0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

00:18.2 Host bridge: Advanced Micro Devices [AMD] K8 [Athlon64/Opteron] DRAM Controller
    Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
    Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
00: 22 10 02 11 00 00 00 00 00 00 00 06 00 00 80 00
10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
30: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
40: 01 00 00 00 01 01 00 00 00 00 00 00 00 00 00 00
50: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
60: e0 3e 78 00 00 00 00 00 00 00 00 00 00 00 00 00
70: 00 00 00 00 00 00 00 00 46 00 00 00 00 00 00 00
80: 02 00 00 00 00 00 00 00 24 f2 7d 5d 20 13 12 00
90: 10 0c 01 00 6b 00 10 b7 39 00 00 80 00 00 00 00
a0: ef 02 00 5d 00 00 00 00 00 00 00 00 00 00 00 00
b0: d8 5d 43 fe 4d 00 00 00 ed d5 00 62 f8 21 b8 41
c0: 00 00 02 00 00 00 00 00 00 00 00 00 00 00 00 00
d0: 27 c5 01 68 fb 35 0d c9 ea 15 0b c9 6f 93 01 89
e0: c7 d5 01 09 e3 14 c8 69 ff 16 0f 4d ce d5 80 48
f0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

00:18.3 Host bridge: Advanced Micro Devices [AMD] K8 [Athlon64/Opteron] Miscellaneous Control
    Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
    Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
    Capabilities: [f0] Secure device <?>
    Kernel driver in use: k8temp
00: 22 10 03 11 00 00 10 00 00 00 00 06 00 00 80 00
10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
30: 00 00 00 00 f0 00 00 00 00 00 00 00 00 00 00 00
40: ff 3b 04 00 40 00 10 0a 00 00 00 00 00 00 00 00
50: 20 48 0a 88 d0 00 00 00 00 00 00 00 c0 1e 0a 2b
60: 9c 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
70: 11 01 32 51 21 40 30 50 00 2a 00 08 17 21 00 00
80: 00 00 07 23 13 21 13 21 00 00 00 00 00 00 00 00
90: 00 00 00 00 66 17 00 00 a0 76 19 0b 00 00 00 00
a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
d0: 00 00 00 00 01 a7 0d 00 00 00 a0 08 25 26 26 00
e0: 00 00 00 00 3e 21 36 00 19 17 00 00 00 00 00 00
f0: 0f 00 10 00 00 00 00 00 00 00 00 00 b2 0f 06 00

01:05.0 VGA compatible controller: ATI Technologies Inc RS690 [Radeon X1200 Series]
    Subsystem: Elitegroup Computer Systems Device 2621
    Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
    Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
    Latency: 64, Cache Line Size: 4 bytes
    Interrupt: pin A routed to IRQ 5
    Region 0: Memory at d8000000 (64-bit, prefetchable) [size=128M]
    Region 2: Memory at fdee0000 (64-bit, non-prefetchable) [size=64K]
    Region 4: I/O ports at ee00 [size=256]
    Region 5: Memory at fdd00000 (32-bit, non-prefetchable) [size=1M]
    Capabilities: [50] Power Management version 2
        Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
        Status: D0 PME-Enable- DSel=0 DScale=0 PME-
    Capabilities: [80] Message Signalled Interrupts: Mask- 64bit+ Queue=0/0 Enable-
        Address: 0000000000000000  Data: 0000
00: 02 10 1e 79 07 00 10 00 00 00 00 03 01 40 80 00
10: 0c 00 00 d8 00 00 00 00 04 00 ee fd 00 00 00 00
20: 01 ee 00 00 00 00 d0 fd 00 00 00 00 19 10 21 26
30: 00 00 00 00 50 00 00 00 00 00 00 00 05 01 00 00
40: 00 00 00 00 00 00 00 00 00 00 00 00 19 10 21 26
50: 01 80 02 06 00 00 00 00 00 00 00 00 00 00 00 00
60: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
70: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
80: 05 00 80 00 00 00 00 00 00 00 00 00 00 00 00 00
90: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
d0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
f0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

01:05.2 Audio device: ATI Technologies Inc Radeon X1200 Series Audio Controller
    Subsystem: ATI Technologies Inc Radeon X1200 Series Audio Controller
    Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
    Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
    Latency: 64, Cache Line Size: 4 bytes
    Interrupt: pin B routed to IRQ 19
    Region 0: Memory at fdefc000 (64-bit, non-prefetchable) [size=16K]
    Capabilities: [50] Power Management version 2
        Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
        Status: D0 PME-Enable- DSel=0 DScale=0 PME-
    Capabilities: [60] Message Signalled Interrupts: Mask- 64bit+ Queue=0/0 Enable-
        Address: 0000000000000000  Data: 0000
    Kernel driver in use: HDA Intel
00: 02 10 19 79 06 00 10 00 00 00 03 04 01 40 00 00
10: 04 c0 ef fd 00 00 00 00 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 02 10 19 79
30: 00 00 00 00 50 00 00 00 00 00 00 00 0b 02 00 00
40: 00 00 00 00 00 00 00 00 00 00 00 00 02 10 19 79
50: 01 60 02 00 00 00 00 00 00 00 00 00 00 00 00 00
60: 05 00 80 00 00 00 00 00 00 00 00 00 00 00 00 00
70: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
90: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
d0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
f0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

02:05.0 Ethernet controller: Realtek Semiconductor Co., Ltd. RTL-8110SC/8169SC Gigabit Ethernet (rev 10)
    Subsystem: Elitegroup Computer Systems Device 8167
    Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
    Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
    Latency: 64 (8000ns min, 16000ns max), Cache Line Size: 32 bytes
    Interrupt: pin A routed to IRQ 22
    Region 0: I/O ports at de00 [size=256]
    Region 1: Memory at fdcff000 (32-bit, non-prefetchable) [size=256]
    [virtual] Expansion ROM at fdf00000 [disabled] [size=128K]
    Capabilities: [dc] Power Management version 2
        Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=375mA PME(D0-,D1+,D2+,D3hot+,D3cold+)
        Status: D0 PME-Enable- DSel=0 DScale=0 PME-
    Kernel driver in use: r8169
00: ec 10 67 81 17 00 b0 02 10 00 00 02 08 40 00 00
10: 01 de 00 00 00 f0 cf fd 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 19 10 67 81
30: 00 00 00 00 dc 00 00 00 00 00 00 00 0a 01 20 40
40: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
50: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
60: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
70: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
90: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
d0: 00 00 00 00 00 00 00 00 00 00 00 00 01 00 c2 f7
e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
f0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00


DW
