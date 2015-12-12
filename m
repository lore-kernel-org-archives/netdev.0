From: Maximilian Engelhardt <maxi@daemonizer.de>
Subject: r8169 nic sometimes doesn't work after changing the mac address
Date: Sat, 12 Dec 2015 22:43:45 +0100
Message-ID: <2484998.nsOrLucHGd@fuchs>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="nextPart5294008.WNS8GduONS"; micalg="pgp-sha512"; protocol="application/pgp-signature"
Cc: netdev@vger.kernel.org
To: Realtek linux nic maintainers <nic_swsd@realtek.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from daemonizer.de ([87.230.18.164]:40886 "EHLO daemonizer.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751199AbbLLVt0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Dec 2015 16:49:26 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--nextPart5294008.WNS8GduONS
Content-Type: multipart/mixed; boundary="nextPart5036767.aVcEzaX8ML"
Content-Transfer-Encoding: quoted-printable

This is a multi-part message in MIME format.

=2D-nextPart5036767.aVcEzaX8ML
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"

Hello,

I'm using a Lenovo TinkPad Edge E135 notebook that has a Realtek wired network 
interface inbuilt. Under some conditions the nic doesn't work after changing 
the mac address.

It took me some time to figure out that it makes a difference if I (re)boot my 
notebook with or without the power supply plugged in. When I boot the system 
with the power supply plugged in everything does work fine as expected. But if 
I boot with the power supply unplugged and I change the mac address the 
network card doesn't work.


This is how I am testing and how I can reproduce the behavior on my system:

* Boot Linux (Debian stable with a newer kernel)
* Network is still turned off, only loopback is enabled by default in my setup.
* I run the following commands:
  ip link set dev eth0 address 00:12:0c:96:a7:2e # a randomly generated mac
  ip link set dev eth0 up
  ip addr add dev eth0 10.0.252.50/24
  ip route add default via 10.0.252.1

When the notebook is booted with the power supply plugged in the network is 
working as expected, e. g. I can ping the gateway.

But when the notebook was booted without the power supply attached the network 
is not working e. g. pinging the gateway doesn't get any replies.

I found two ways to get the network working from this state (beside rebooting 
with power plugged in):

* If I enable promiscous mode the network connections are working again:
  # ip link set dev eth0 promisc on

* Alternatively I can set the same mac address again while the interface is 
up:
  # ip link set dev eth0 address 00:12:0c:96:a7:2e # same mac as before


So it seems like a mac filter in the network card is not set up right.


Attached are dmesg output of a boot with and without power supply attached as 
well as the output of lspci -vvv.


Please let me know If you need more information.

Thanks,
Maxi

=2D-nextPart5036767.aVcEzaX8ML
Content-Disposition: attachment; filename="dmesg_nopower"
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="UTF-8"; name="dmesg_nopowersupply.txt"

[    0.000000] Initializing cgroup subsys cpuset
[    0.000000] Initializing cgroup subsys cpu
[    0.000000] Initializing cgroup subsys cpuacct
[    0.000000] Linux version 4.3.0-trunk-amd64 (debian-kernel@lists.debian.org) (gcc version 5.2.1 20151028 (Debian 5.2.1-23) ) #1 SMP Debian 4.3-1~exp1 (2015-11-04)
[    0.000000] Command line: BOOT_IMAGE=/boot/vmlinuz-4.3.0-trunk-amd64 root=/dev/mapper/fuchs--vg-root ro quiet
[    0.000000] tseg: 00dfc00000
[    0.000000] x86/fpu: Legacy x87 FPU detected.
[    0.000000] x86/fpu: Using 'lazy' FPU context switches.
[    0.000000] e820: BIOS-provided physical RAM map:
[    0.000000] BIOS-e820: [mem 0x0000000000000000-0x000000000009e7ff] usable
[    0.000000] BIOS-e820: [mem 0x000000000009e800-0x000000000009ffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000000e0000-0x00000000000fffff] reserved
[    0.000000] BIOS-e820: [mem 0x0000000000100000-0x00000000d2e1ffff] usable
[    0.000000] BIOS-e820: [mem 0x00000000d2e20000-0x00000000ded02fff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000ded03000-0x00000000dee32fff] ACPI NVS
[    0.000000] BIOS-e820: [mem 0x00000000dee33000-0x00000000deeb2fff] ACPI data
[    0.000000] BIOS-e820: [mem 0x00000000deeb3000-0x00000000dfffffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000fec00000-0x00000000fecfffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000fed80000-0x00000000fed80fff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000ffc00000-0x00000000ffffffff] reserved
[    0.000000] BIOS-e820: [mem 0x0000000100000000-0x0000000206ffffff] usable
[    0.000000] NX (Execute Disable) protection: active
[    0.000000] SMBIOS 2.7 present.
[    0.000000] DMI: LENOVO 335963G/335963G, BIOS HMET93WW (2.53 ) 07/11/2013
[    0.000000] e820: update [mem 0x00000000-0x00000fff] usable ==> reserved
[    0.000000] e820: remove [mem 0x000a0000-0x000fffff] usable
[    0.000000] e820: last_pfn = 0x207000 max_arch_pfn = 0x400000000
[    0.000000] MTRR default type: uncachable
[    0.000000] MTRR fixed ranges enabled:
[    0.000000]   00000-9FFFF write-back
[    0.000000]   A0000-BFFFF uncachable
[    0.000000]   C0000-FFFFF write-protect
[    0.000000] MTRR variable ranges enabled:
[    0.000000]   0 base 000000000 mask F80000000 write-back
[    0.000000]   1 base 080000000 mask FC0000000 write-back
[    0.000000]   2 base 0C0000000 mask FE0000000 write-back
[    0.000000]   3 base 207000000 mask FFF000000 uncachable
[    0.000000]   4 base 208000000 mask FF8000000 uncachable
[    0.000000]   5 base 0FED80000 mask FFFFFF000 uncachable
[    0.000000]   6 disabled
[    0.000000]   7 base 0FFC00000 mask FFFC00000 write-protect
[    0.000000] TOM2: 000000021f000000 aka 8688M
[    0.000000] x86/PAT: Configuration [0-7]: WB  WC  UC- UC  WB  WC  UC- WT  
[    0.000000] e820: last_pfn = 0xd2e20 max_arch_pfn = 0x400000000
[    0.000000] found SMP MP-table at [mem 0x000fa8f0-0x000fa8ff] mapped at [ffff8800000fa8f0]
[    0.000000] Base memory trampoline at [ffff880000098000] 98000 size 24576
[    0.000000] Using GB pages for direct mapping
[    0.000000] init_memory_mapping: [mem 0x00000000-0x000fffff]
[    0.000000]  [mem 0x00000000-0x000fffff] page 4k
[    0.000000] BRK [0x01d20000, 0x01d20fff] PGTABLE
[    0.000000] BRK [0x01d21000, 0x01d21fff] PGTABLE
[    0.000000] BRK [0x01d22000, 0x01d22fff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0x206e00000-0x206ffffff]
[    0.000000]  [mem 0x206e00000-0x206ffffff] page 2M
[    0.000000] BRK [0x01d23000, 0x01d23fff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0x200000000-0x206dfffff]
[    0.000000]  [mem 0x200000000-0x206dfffff] page 2M
[    0.000000] init_memory_mapping: [mem 0x1e0000000-0x1ffffffff]
[    0.000000]  [mem 0x1e0000000-0x1ffffffff] page 1G
[    0.000000] init_memory_mapping: [mem 0x00100000-0xd2e1ffff]
[    0.000000]  [mem 0x00100000-0x001fffff] page 4k
[    0.000000]  [mem 0x00200000-0x3fffffff] page 2M
[    0.000000]  [mem 0x40000000-0xbfffffff] page 1G
[    0.000000]  [mem 0xc0000000-0xd2dfffff] page 2M
[    0.000000]  [mem 0xd2e00000-0xd2e1ffff] page 4k
[    0.000000] init_memory_mapping: [mem 0x100000000-0x1dfffffff]
[    0.000000]  [mem 0x100000000-0x1dfffffff] page 1G
[    0.000000] RAMDISK: [mem 0x35c26000-0x36e0afff]
[    0.000000] ACPI: Early table checksum verification disabled
[    0.000000] ACPI: RSDP 0x00000000000F0120 000024 (v02 LENOVO)
[    0.000000] ACPI: XSDT 0x00000000DEEB2170 00008C (v01 LENOVO TP-HM    06040000 PTL  00000002)
[    0.000000] ACPI: FACP 0x00000000DEE9F000 00010C (v05 LENOVO TP-HM    00002530 PTL  00000002)
[    0.000000] ACPI: DSDT 0x00000000DEEA1000 010AF4 (v01 LENOVO AMD      00001000 INTL 20061109)
[    0.000000] ACPI: FACS 0x00000000DEE1A000 000040
[    0.000000] ACPI: HPET 0x00000000DEE9E000 000038 (v01 LENOVO TP-HM    00002530 PTL  00000002)
[    0.000000] ACPI: APIC 0x00000000DEE9D000 00007A (v02 LENOVO TP-HM    00002530 PTL  00000002)
[    0.000000] ACPI: MCFG 0x00000000DEE9C000 00003C (v01 LENOVO TP-HM    00002530 PTL  00000002)
[    0.000000] ACPI: SBST 0x00000000DEE9B000 000030 (v01 LENOVO TP-HM    00002530 PTL  00000002)
[    0.000000] ACPI: FPDT 0x00000000DEE9A000 000064 (v01 LENOVO TP-HM    00002530 PTL  00000002)
[    0.000000] ACPI: UEFI 0x00000000DEE99000 00003E (v01 LENOVO TP-HM    00002530 PTL  00000002)
[    0.000000] ACPI: UEFI 0x00000000DEE98000 000042 (v01 PTL    COMBUF   00000001 PTL  00000001)
[    0.000000] ACPI: POAT 0x00000000DEDF5000 000055 (v03 LENOVO TP-HM    00002530 PTL  00000002)
[    0.000000] ACPI: SSDT 0x00000000DEE97000 0003DE (v01 AMD    POWERNOW 00000001 AMD  00000001)
[    0.000000] ACPI: SSDT 0x00000000DEE95000 0016E4 (v02 AMD    ALIB     00000001 MSFT 04000000)
[    0.000000] ACPI: UEFI 0x00000000DEE94000 000292 (v01 LENOVO TP-HM    00002530 PTL  00000002)
[    0.000000] ACPI: DBG2 0x00000000DEE93000 00006B (v00 LENOVO TP-HM    00002530 PTL  00000002)
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] No NUMA configuration found
[    0.000000] Faking a node at [mem 0x0000000000000000-0x0000000206ffffff]
[    0.000000] NODE_DATA(0) allocated [mem 0x206ffa000-0x206ffdfff]
[    0.000000]  [ffffea0000000000-ffffea00081fffff] PMD -> [ffff8801fee00000-ffff8802065fffff] on node 0
[    0.000000] Zone ranges:
[    0.000000]   DMA      [mem 0x0000000000001000-0x0000000000ffffff]
[    0.000000]   DMA32    [mem 0x0000000001000000-0x00000000ffffffff]
[    0.000000]   Normal   [mem 0x0000000100000000-0x0000000206ffffff]
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x0000000000001000-0x000000000009dfff]
[    0.000000]   node   0: [mem 0x0000000000100000-0x00000000d2e1ffff]
[    0.000000]   node   0: [mem 0x0000000100000000-0x0000000206ffffff]
[    0.000000] Initmem setup node 0 [mem 0x0000000000001000-0x0000000206ffffff]
[    0.000000] On node 0 totalpages: 1940925
[    0.000000]   DMA zone: 64 pages used for memmap
[    0.000000]   DMA zone: 21 pages reserved
[    0.000000]   DMA zone: 3997 pages, LIFO batch:0
[    0.000000]   DMA32 zone: 13433 pages used for memmap
[    0.000000]   DMA32 zone: 859680 pages, LIFO batch:31
[    0.000000]   Normal zone: 16832 pages used for memmap
[    0.000000]   Normal zone: 1077248 pages, LIFO batch:31
[    0.000000] ACPI: PM-Timer IO Port: 0x808
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x00] high edge lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x01] high edge lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x02] high edge lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x03] high edge lint[0x1])
[    0.000000] IOAPIC[0]: apic_id 2, version 33, address 0xfec00000, GSI 0-23
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
[    0.000000] ACPI: IRQ0 used by override.
[    0.000000] ACPI: IRQ9 used by override.
[    0.000000] Using ACPI (MADT) for SMP configuration information
[    0.000000] ACPI: HPET id: 0x43538210 base: 0xfed00000
[    0.000000] smpboot: Allowing 4 CPUs, 2 hotplug CPUs
[    0.000000] PM: Registered nosave memory: [mem 0x00000000-0x00000fff]
[    0.000000] PM: Registered nosave memory: [mem 0x0009e000-0x0009efff]
[    0.000000] PM: Registered nosave memory: [mem 0x0009f000-0x0009ffff]
[    0.000000] PM: Registered nosave memory: [mem 0x000a0000-0x000dffff]
[    0.000000] PM: Registered nosave memory: [mem 0x000e0000-0x000fffff]
[    0.000000] PM: Registered nosave memory: [mem 0xd2e20000-0xded02fff]
[    0.000000] PM: Registered nosave memory: [mem 0xded03000-0xdee32fff]
[    0.000000] PM: Registered nosave memory: [mem 0xdee33000-0xdeeb2fff]
[    0.000000] PM: Registered nosave memory: [mem 0xdeeb3000-0xdfffffff]
[    0.000000] PM: Registered nosave memory: [mem 0xe0000000-0xfebfffff]
[    0.000000] PM: Registered nosave memory: [mem 0xfec00000-0xfecfffff]
[    0.000000] PM: Registered nosave memory: [mem 0xfed00000-0xfed7ffff]
[    0.000000] PM: Registered nosave memory: [mem 0xfed80000-0xfed80fff]
[    0.000000] PM: Registered nosave memory: [mem 0xfed81000-0xffbfffff]
[    0.000000] PM: Registered nosave memory: [mem 0xffc00000-0xffffffff]
[    0.000000] e820: [mem 0xe0000000-0xfebfffff] available for PCI devices
[    0.000000] Booting paravirtualized kernel on bare hardware
[    0.000000] clocksource: refined-jiffies: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 7645519600211568 ns
[    0.000000] setup_percpu: NR_CPUS:512 nr_cpumask_bits:512 nr_cpu_ids:4 nr_node_ids:1
[    0.000000] PERCPU: Embedded 32 pages/cpu @ffff880206c00000 s92952 r8192 d29928 u524288
[    0.000000] pcpu-alloc: s92952 r8192 d29928 u524288 alloc=1*2097152
[    0.000000] pcpu-alloc: [0] 0 1 2 3 
[    0.000000] Built 1 zonelists in Node order, mobility grouping on.  Total pages: 1910575
[    0.000000] Policy zone: Normal
[    0.000000] Kernel command line: BOOT_IMAGE=/boot/vmlinuz-4.3.0-trunk-amd64 root=/dev/mapper/fuchs--vg-root ro quiet
[    0.000000] PID hash table entries: 4096 (order: 3, 32768 bytes)
[    0.000000] Calgary: detecting Calgary via BIOS EBDA area
[    0.000000] Calgary: Unable to locate Rio Grande table in EBDA - bailing!
[    0.000000] Memory: 7542112K/7763700K available (5474K kernel code, 1047K rwdata, 2772K rodata, 1284K init, 836K bss, 221588K reserved, 0K cma-reserved)
[    0.000000] Hierarchical RCU implementation.
[    0.000000] 	Build-time adjustment of leaf fanout to 64.
[    0.000000] 	RCU restricting CPUs from NR_CPUS=512 to nr_cpu_ids=4.
[    0.000000] RCU: Adjusting geometry for rcu_fanout_leaf=64, nr_cpu_ids=4
[    0.000000] NR_IRQS:33024 nr_irqs:456 16
[    0.000000] spurious 8259A interrupt: IRQ7.
[    0.000000] Console: colour VGA+ 80x25
[    0.000000] console [tty0] enabled
[    0.000000] clocksource: hpet: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 133484873504 ns
[    0.000000] hpet clockevent registered
[    0.000000] tsc: Fast TSC calibration using PIT
[    0.000000] tsc: Detected 1696.807 MHz processor
[    0.000058] Calibrating delay loop (skipped), value calculated using timer frequency.. 3393.61 BogoMIPS (lpj=6787228)
[    0.000065] pid_max: default: 32768 minimum: 301
[    0.000084] ACPI: Core revision 20150818
[    0.029404] ACPI: 3 ACPI AML tables successfully acquired and loaded
[    0.029482] Security Framework initialized
[    0.029489] Yama: disabled by default; enable with sysctl kernel.yama.*
[    0.029505] AppArmor: AppArmor disabled by boot time parameter
[    0.030754] Dentry cache hash table entries: 1048576 (order: 11, 8388608 bytes)
[    0.036005] Inode-cache hash table entries: 524288 (order: 10, 4194304 bytes)
[    0.038324] Mount-cache hash table entries: 16384 (order: 5, 131072 bytes)
[    0.038349] Mountpoint-cache hash table entries: 16384 (order: 5, 131072 bytes)
[    0.038917] Initializing cgroup subsys io
[    0.038937] Initializing cgroup subsys memory
[    0.038952] Initializing cgroup subsys devices
[    0.038959] Initializing cgroup subsys freezer
[    0.038966] Initializing cgroup subsys net_cls
[    0.038974] Initializing cgroup subsys perf_event
[    0.038980] Initializing cgroup subsys net_prio
[    0.039058] CPU: Physical Processor ID: 0
[    0.039061] CPU: Processor Core ID: 0
[    0.039064] mce: CPU supports 6 MCE banks
[    0.039082] Last level iTLB entries: 4KB 512, 2MB 8, 4MB 4
[    0.039085] Last level dTLB entries: 4KB 512, 2MB 8, 4MB 4, 1GB 0
[    0.039778] Freeing SMP alternatives memory: 20K (ffffffff81c48000 - ffffffff81c4d000)
[    0.058242] ftrace: allocating 23497 entries in 92 pages
[    0.262113] ..TIMER: vector=0x30 apic1=0 pin1=2 apic2=-1 pin2=-1
[    0.406728] smpboot: CPU0: AMD E2-1800 APU with Radeon(tm) HD Graphics (family: 0x14, model: 0x2, stepping: 0x0)
[    0.406777] Performance Events: AMD PMU driver.
[    0.406786] ... version:                0
[    0.406789] ... bit width:              48
[    0.406791] ... generic registers:      4
[    0.406794] ... value mask:             0000ffffffffffff
[    0.406796] ... max period:             00007fffffffffff
[    0.406798] ... fixed-purpose events:   0
[    0.406801] ... event mask:             000000000000000f
[    0.407796] NMI watchdog: enabled on all CPUs, permanently consumes one hw-PMU counter.
[    0.408026] x86: Booting SMP configuration:
[    0.408031] .... node  #0, CPUs:      #1
[    0.421087] x86: Booted up 1 node, 2 CPUs
[    0.421091] smpboot: Total of 2 processors activated (6787.22 BogoMIPS)
[    0.421870] devtmpfs: initialized
[    0.429000] PM: Registering ACPI NVS region [mem 0xded03000-0xdee32fff] (1245184 bytes)
[    0.429237] clocksource: jiffies: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 7645041785100000 ns
[    0.429450] pinctrl core: initialized pinctrl subsystem
[    0.432750] NET: Registered protocol family 16
[    0.442910] cpuidle: using governor ladder
[    0.454900] cpuidle: using governor menu
[    0.455191] ACPI: bus type PCI registered
[    0.455197] acpiphp: ACPI Hot Plug PCI Controller Driver version: 0.5
[    0.455443] PCI: MMCONFIG for domain 0000 [bus 00-3f] at [mem 0xf8000000-0xfbffffff] (base 0xf8000000)
[    0.455448] PCI: not using MMCONFIG
[    0.455452] PCI: Using configuration type 1 for base access
[    0.455454] PCI: Using configuration type 1 for extended access
[    0.455967] mtrr: your CPUs had inconsistent variable MTRR settings
[    0.455970] mtrr: probably your BIOS does not setup all CPUs.
[    0.455972] mtrr: corrected configuration.
[    0.468426] ACPI: Added _OSI(Module Device)
[    0.468434] ACPI: Added _OSI(Processor Device)
[    0.468437] ACPI: Added _OSI(3.0 _SCP Extensions)
[    0.468440] ACPI: Added _OSI(Processor Aggregator Device)
[    0.479779] [Firmware Bug]: ACPI: BIOS _OSI(Linux) query ignored
[    0.480729] ACPI : EC: EC started
[    0.488618] ACPI: Interpreter enabled
[    0.488639] ACPI Exception: AE_NOT_FOUND, While evaluating Sleep State [\_S1_] (20150818/hwxface-580)
[    0.488648] ACPI Exception: AE_NOT_FOUND, While evaluating Sleep State [\_S2_] (20150818/hwxface-580)
[    0.488678] ACPI: (supports S0 S3 S4 S5)
[    0.488682] ACPI: Using IOAPIC for interrupt routing
[    0.488961] PCI: MMCONFIG for domain 0000 [bus 00-3f] at [mem 0xf8000000-0xfbffffff] (base 0xf8000000)
[    0.489525] PCI: MMCONFIG at [mem 0xf8000000-0xfbffffff] reserved in ACPI motherboard resources
[    0.489554] PCI: Using host bridge windows from ACPI; if necessary, use "pci=nocrs" and report a bug
[    0.490488] [Firmware Bug]: ACPI: No _BQC method, cannot determine initial brightness
[    0.499401] [Firmware Bug]: ACPI: No _BQC method, cannot determine initial brightness
[    0.506056] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-ff])
[    0.506073] acpi PNP0A08:00: _OSC: OS supports [ExtendedConfig ASPM ClockPM Segments MSI]
[    0.506450] acpi PNP0A08:00: _OSC: platform does not support [PME]
[    0.506841] acpi PNP0A08:00: _OSC: OS now controls [PCIeHotplug AER PCIeCapability]
[    0.507739] acpi PNP0A08:00: ignoring host bridge window [mem 0x000ce000-0x000cffff window] (conflicts with Video ROM [mem 0x000c0000-0x000cedff])
[    0.507749] acpi PNP0A08:00: [Firmware Info]: MMCONFIG for domain 0000 [bus 00-3f] only partially covers this bridge
[    0.508154] PCI host bridge to bus 0000:00
[    0.508161] pci_bus 0000:00: root bus resource [bus 00-ff]
[    0.508166] pci_bus 0000:00: root bus resource [mem 0x000a0000-0x000bffff window]
[    0.508170] pci_bus 0000:00: root bus resource [mem 0x000c0000-0x000c1fff window]
[    0.508174] pci_bus 0000:00: root bus resource [mem 0x000c2000-0x000c3fff window]
[    0.508179] pci_bus 0000:00: root bus resource [mem 0x000c4000-0x000c5fff window]
[    0.508183] pci_bus 0000:00: root bus resource [mem 0x000c6000-0x000c7fff window]
[    0.508187] pci_bus 0000:00: root bus resource [mem 0x000c8000-0x000c9fff window]
[    0.508191] pci_bus 0000:00: root bus resource [mem 0x000ca000-0x000cbfff window]
[    0.508195] pci_bus 0000:00: root bus resource [mem 0x000cc000-0x000cdfff window]
[    0.508199] pci_bus 0000:00: root bus resource [mem 0x000d0000-0x000d1fff window]
[    0.508203] pci_bus 0000:00: root bus resource [mem 0x000d2000-0x000d3fff window]
[    0.508207] pci_bus 0000:00: root bus resource [mem 0x000d4000-0x000d5fff window]
[    0.508211] pci_bus 0000:00: root bus resource [mem 0x000d6000-0x000d7fff window]
[    0.508215] pci_bus 0000:00: root bus resource [mem 0x000d8000-0x000d9fff window]
[    0.508219] pci_bus 0000:00: root bus resource [mem 0x000da000-0x000dbfff window]
[    0.508223] pci_bus 0000:00: root bus resource [mem 0x000dc000-0x000ddfff window]
[    0.508227] pci_bus 0000:00: root bus resource [mem 0x000de000-0x000dffff window]
[    0.508231] pci_bus 0000:00: root bus resource [mem 0x000e0000-0x000e1fff window]
[    0.508235] pci_bus 0000:00: root bus resource [mem 0x000e2000-0x000e3fff window]
[    0.508238] pci_bus 0000:00: root bus resource [mem 0x000e4000-0x000e5fff window]
[    0.508242] pci_bus 0000:00: root bus resource [mem 0x000e6000-0x000e7fff window]
[    0.508246] pci_bus 0000:00: root bus resource [mem 0x000e8000-0x000e9fff window]
[    0.508250] pci_bus 0000:00: root bus resource [mem 0x000ea000-0x000ebfff window]
[    0.508254] pci_bus 0000:00: root bus resource [mem 0x000ec000-0x000edfff window]
[    0.508258] pci_bus 0000:00: root bus resource [mem 0x000ee000-0x000effff window]
[    0.508262] pci_bus 0000:00: root bus resource [mem 0xe0000000-0xf7ffffff window]
[    0.508266] pci_bus 0000:00: root bus resource [mem 0xfc000000-0xfdffffff window]
[    0.508270] pci_bus 0000:00: root bus resource [mem 0xfed40000-0xfed44fff window]
[    0.508274] pci_bus 0000:00: root bus resource [io  0x0000-0x0cf7 window]
[    0.508278] pci_bus 0000:00: root bus resource [io  0x0d00-0xffff window]
[    0.508293] pci 0000:00:00.0: [1022:1510] type 00 class 0x060000
[    0.508481] pci 0000:00:01.0: [1002:9808] type 00 class 0x030000
[    0.508508] pci 0000:00:01.0: reg 0x10: [mem 0xe0000000-0xefffffff pref]
[    0.508519] pci 0000:00:01.0: reg 0x14: [io  0x3000-0x30ff]
[    0.508530] pci 0000:00:01.0: reg 0x18: [mem 0xf0b00000-0xf0b3ffff]
[    0.508580] pci 0000:00:01.0: supports D1 D2
[    0.508730] pci 0000:00:01.1: [1002:1314] type 00 class 0x040300
[    0.508757] pci 0000:00:01.1: reg 0x10: [mem 0xf0b44000-0xf0b47fff]
[    0.508818] pci 0000:00:01.1: supports D1 D2
[    0.508977] pci 0000:00:05.0: [1022:1513] type 01 class 0x060400
[    0.509047] pci 0000:00:05.0: PME# supported from D0 D3hot D3cold
[    0.509134] pci 0000:00:05.0: System wakeup disabled by ACPI
[    0.509222] pci 0000:00:06.0: [1022:1514] type 01 class 0x060400
[    0.509290] pci 0000:00:06.0: PME# supported from D0 D3hot D3cold
[    0.509374] pci 0000:00:06.0: System wakeup disabled by ACPI
[    0.509454] pci 0000:00:07.0: [1022:1515] type 01 class 0x060400
[    0.509522] pci 0000:00:07.0: PME# supported from D0 D3hot D3cold
[    0.509605] pci 0000:00:07.0: System wakeup disabled by ACPI
[    0.509720] pci 0000:00:10.0: [1022:7812] type 00 class 0x0c0330
[    0.509769] pci 0000:00:10.0: reg 0x10: [mem 0xf0b48000-0xf0b49fff 64bit]
[    0.509863] pci 0000:00:10.0: PME# supported from D0 D3hot D3cold
[    0.509979] pci 0000:00:10.0: System wakeup disabled by ACPI
[    0.510084] pci 0000:00:11.0: [1022:7801] type 00 class 0x010601
[    0.510118] pci 0000:00:11.0: reg 0x10: [io  0x3118-0x311f]
[    0.510132] pci 0000:00:11.0: reg 0x14: [io  0x3124-0x3127]
[    0.510145] pci 0000:00:11.0: reg 0x18: [io  0x3110-0x3117]
[    0.510157] pci 0000:00:11.0: reg 0x1c: [io  0x3120-0x3123]
[    0.510170] pci 0000:00:11.0: reg 0x20: [io  0x3100-0x310f]
[    0.510183] pci 0000:00:11.0: reg 0x24: [mem 0xf0b4d000-0xf0b4d7ff]
[    0.510372] pci 0000:00:12.0: [1022:7807] type 00 class 0x0c0310
[    0.510393] pci 0000:00:12.0: reg 0x10: [mem 0xf0b4c000-0xf0b4cfff]
[    0.510556] pci 0000:00:12.0: System wakeup disabled by ACPI
[    0.510669] pci 0000:00:12.2: [1022:7808] type 00 class 0x0c0320
[    0.510703] pci 0000:00:12.2: reg 0x10: [mem 0xf0b4d900-0xf0b4d9ff]
[    0.510785] pci 0000:00:12.2: supports D1 D2
[    0.510789] pci 0000:00:12.2: PME# supported from D0 D1 D2 D3hot
[    0.510963] pci 0000:00:13.0: [1022:7807] type 00 class 0x0c0310
[    0.510984] pci 0000:00:13.0: reg 0x10: [mem 0xf0b4b000-0xf0b4bfff]
[    0.511148] pci 0000:00:13.0: System wakeup disabled by ACPI
[    0.511232] pci 0000:00:13.2: [1022:7808] type 00 class 0x0c0320
[    0.511264] pci 0000:00:13.2: reg 0x10: [mem 0xf0b4d800-0xf0b4d8ff]
[    0.511347] pci 0000:00:13.2: supports D1 D2
[    0.511351] pci 0000:00:13.2: PME# supported from D0 D1 D2 D3hot
[    0.511453] pci 0000:00:13.2: System wakeup disabled by ACPI
[    0.511554] pci 0000:00:14.0: [1022:780b] type 00 class 0x0c0500
[    0.511791] pci 0000:00:14.2: [1022:780d] type 00 class 0x040300
[    0.511825] pci 0000:00:14.2: reg 0x10: [mem 0xf0b40000-0xf0b43fff 64bit]
[    0.511896] pci 0000:00:14.2: PME# supported from D0 D3hot D3cold
[    0.511980] pci 0000:00:14.2: System wakeup disabled by ACPI
[    0.512070] pci 0000:00:14.3: [1022:780e] type 00 class 0x060100
[    0.512291] pci 0000:00:14.4: [1022:780f] type 01 class 0x060401
[    0.512411] pci 0000:00:14.4: System wakeup disabled by ACPI
[    0.512507] pci 0000:00:14.5: [1022:7809] type 00 class 0x0c0310
[    0.512528] pci 0000:00:14.5: reg 0x10: [mem 0xf0b4a000-0xf0b4afff]
[    0.512692] pci 0000:00:14.5: System wakeup disabled by ACPI
[    0.512791] pci 0000:00:18.0: [1022:1700] type 00 class 0x060000
[    0.512958] pci 0000:00:18.1: [1022:1701] type 00 class 0x060000
[    0.513122] pci 0000:00:18.2: [1022:1702] type 00 class 0x060000
[    0.513284] pci 0000:00:18.3: [1022:1703] type 00 class 0x060000
[    0.513455] pci 0000:00:18.4: [1022:1704] type 00 class 0x060000
[    0.513615] pci 0000:00:18.5: [1022:1718] type 00 class 0x060000
[    0.513776] pci 0000:00:18.6: [1022:1716] type 00 class 0x060000
[    0.513937] pci 0000:00:18.7: [1022:1719] type 00 class 0x060000
[    0.514284] pci 0000:02:00.0: [14e4:4359] type 00 class 0x028000
[    0.514333] pci 0000:02:00.0: reg 0x10: [mem 0xf0a00000-0xf0a03fff 64bit]
[    0.514443] pci 0000:02:00.0: supports D1 D2
[    0.514447] pci 0000:02:00.0: PME# supported from D0 D3hot D3cold
[    0.518923] pci 0000:00:05.0: PCI bridge to [bus 02]
[    0.518946] pci 0000:00:05.0:   bridge window [mem 0xf0a00000-0xf0afffff]
[    0.519133] pci 0000:03:00.0: [10ec:8168] type 00 class 0x020000
[    0.519179] pci 0000:03:00.0: reg 0x10: [io  0x2000-0x20ff]
[    0.519210] pci 0000:03:00.0: reg 0x18: [mem 0xf0004000-0xf0004fff 64bit pref]
[    0.519230] pci 0000:03:00.0: reg 0x20: [mem 0xf0000000-0xf0003fff 64bit pref]
[    0.519305] pci 0000:03:00.0: supports D1 D2
[    0.519309] pci 0000:03:00.0: PME# supported from D0 D1 D2 D3hot D3cold
[    0.526877] pci 0000:00:06.0: PCI bridge to [bus 03]
[    0.526903] pci 0000:00:06.0:   bridge window [io  0x2000-0x2fff]
[    0.526915] pci 0000:00:06.0:   bridge window [mem 0xf0200000-0xf09fffff]
[    0.526928] pci 0000:00:06.0:   bridge window [mem 0xf0000000-0xf00fffff 64bit pref]
[    0.527122] pci 0000:04:00.0: [10ec:5209] type 00 class 0xff0000
[    0.527167] pci 0000:04:00.0: reg 0x10: [mem 0xf0100000-0xf0100fff]
[    0.527234] pci 0000:04:00.0: reg 0x30: [mem 0xffff0000-0xffffffff pref]
[    0.527292] pci 0000:04:00.0: supports D1 D2
[    0.527296] pci 0000:04:00.0: PME# supported from D1 D2 D3hot
[    0.534870] pci 0000:00:07.0: PCI bridge to [bus 04]
[    0.534899] pci 0000:00:07.0:   bridge window [mem 0xf0100000-0xf01fffff]
[    0.535105] pci 0000:00:14.4: PCI bridge to [bus 05] (subtractive decode)
[    0.535119] pci 0000:00:14.4:   bridge window [mem 0x000a0000-0x000bffff window] (subtractive decode)
[    0.535124] pci 0000:00:14.4:   bridge window [mem 0x000c0000-0x000c1fff window] (subtractive decode)
[    0.535129] pci 0000:00:14.4:   bridge window [mem 0x000c2000-0x000c3fff window] (subtractive decode)
[    0.535133] pci 0000:00:14.4:   bridge window [mem 0x000c4000-0x000c5fff window] (subtractive decode)
[    0.535138] pci 0000:00:14.4:   bridge window [mem 0x000c6000-0x000c7fff window] (subtractive decode)
[    0.535142] pci 0000:00:14.4:   bridge window [mem 0x000c8000-0x000c9fff window] (subtractive decode)
[    0.535146] pci 0000:00:14.4:   bridge window [mem 0x000ca000-0x000cbfff window] (subtractive decode)
[    0.535150] pci 0000:00:14.4:   bridge window [mem 0x000cc000-0x000cdfff window] (subtractive decode)
[    0.535155] pci 0000:00:14.4:   bridge window [mem 0x000d0000-0x000d1fff window] (subtractive decode)
[    0.535159] pci 0000:00:14.4:   bridge window [mem 0x000d2000-0x000d3fff window] (subtractive decode)
[    0.535163] pci 0000:00:14.4:   bridge window [mem 0x000d4000-0x000d5fff window] (subtractive decode)
[    0.535167] pci 0000:00:14.4:   bridge window [mem 0x000d6000-0x000d7fff window] (subtractive decode)
[    0.535171] pci 0000:00:14.4:   bridge window [mem 0x000d8000-0x000d9fff window] (subtractive decode)
[    0.535175] pci 0000:00:14.4:   bridge window [mem 0x000da000-0x000dbfff window] (subtractive decode)
[    0.535180] pci 0000:00:14.4:   bridge window [mem 0x000dc000-0x000ddfff window] (subtractive decode)
[    0.535184] pci 0000:00:14.4:   bridge window [mem 0x000de000-0x000dffff window] (subtractive decode)
[    0.535188] pci 0000:00:14.4:   bridge window [mem 0x000e0000-0x000e1fff window] (subtractive decode)
[    0.535192] pci 0000:00:14.4:   bridge window [mem 0x000e2000-0x000e3fff window] (subtractive decode)
[    0.535196] pci 0000:00:14.4:   bridge window [mem 0x000e4000-0x000e5fff window] (subtractive decode)
[    0.535200] pci 0000:00:14.4:   bridge window [mem 0x000e6000-0x000e7fff window] (subtractive decode)
[    0.535205] pci 0000:00:14.4:   bridge window [mem 0x000e8000-0x000e9fff window] (subtractive decode)
[    0.535209] pci 0000:00:14.4:   bridge window [mem 0x000ea000-0x000ebfff window] (subtractive decode)
[    0.535213] pci 0000:00:14.4:   bridge window [mem 0x000ec000-0x000edfff window] (subtractive decode)
[    0.535217] pci 0000:00:14.4:   bridge window [mem 0x000ee000-0x000effff window] (subtractive decode)
[    0.535223] pci 0000:00:14.4:   bridge window [mem 0xe0000000-0xf7ffffff window] (subtractive decode)
[    0.535227] pci 0000:00:14.4:   bridge window [mem 0xfc000000-0xfdffffff window] (subtractive decode)
[    0.535231] pci 0000:00:14.4:   bridge window [mem 0xfed40000-0xfed44fff window] (subtractive decode)
[    0.535236] pci 0000:00:14.4:   bridge window [io  0x0000-0x0cf7 window] (subtractive decode)
[    0.535242] pci 0000:00:14.4:   bridge window [io  0x0d00-0xffff window] (subtractive decode)
[    0.535966] ACPI: PCI Interrupt Link [LNKA] (IRQs 10 11) *0
[    0.536121] ACPI: PCI Interrupt Link [LNKB] (IRQs 10 11) *0
[    0.536269] ACPI: PCI Interrupt Link [LNKC] (IRQs 10 11) *0
[    0.536414] ACPI: PCI Interrupt Link [LNKD] (IRQs 10 11) *0
[    0.536540] ACPI: PCI Interrupt Link [LNKE] (IRQs 10 11) *0
[    0.536645] ACPI: PCI Interrupt Link [LNKF] (IRQs 10 11) *0
[    0.536751] ACPI: PCI Interrupt Link [LNKG] (IRQs 10 11) *0
[    0.536856] ACPI: PCI Interrupt Link [LNKH] (IRQs 10 11) *0
[    0.537140] ACPI: IRQ 7 override to edge, high
[    0.539940] ACPI: Enabled 1 GPEs in block 00 to 1F
[    0.540111] ACPI : EC: GPE = 0x3, I/O: command/status = 0x66, data = 0x62
[    0.540453] vgaarb: setting as boot device: PCI:0000:00:01.0
[    0.540461] vgaarb: device added: PCI:0000:00:01.0,decodes=io+mem,owns=io+mem,locks=none
[    0.540473] vgaarb: loaded
[    0.540476] vgaarb: bridge control possible 0000:00:01.0
[    0.540847] PCI: Using ACPI for IRQ routing
[    0.543129] PCI: pci_cache_line_size set to 64 bytes
[    0.543303] e820: reserve RAM buffer [mem 0x0009e800-0x0009ffff]
[    0.543308] e820: reserve RAM buffer [mem 0xd2e20000-0xd3ffffff]
[    0.543312] e820: reserve RAM buffer [mem 0x207000000-0x207ffffff]
[    0.543630] hpet0: at MMIO 0xfed00000, IRQs 2, 8, 0
[    0.543638] hpet0: 3 comparators, 32-bit 14.318180 MHz counter
[    0.545733] clocksource: Switched to clocksource hpet
[    0.558978] pnp: PnP ACPI init
[    0.559275] system 00:00: [io  0x0f50-0x0f51] has been reserved
[    0.559282] system 00:00: [mem 0xfec00000-0xfec00fff] could not be reserved
[    0.559287] system 00:00: [mem 0xfee00000-0xfee00fff] has been reserved
[    0.559292] system 00:00: [mem 0xf8000000-0xfbffffff] has been reserved
[    0.559301] system 00:00: Plug and Play ACPI device, IDs PNP0c02 (active)
[    0.560016] pnp 00:01: Plug and Play ACPI device, IDs PNP0b00 (active)
[    0.560080] pnp 00:02: Plug and Play ACPI device, IDs MSF0001 PNP0303 (active)
[    0.560189] pnp 00:03: Plug and Play ACPI device, IDs LEN0052 PNP0f13 (active)
[    0.560309] system 00:04: [io  0x04d0-0x04d1] has been reserved
[    0.560314] system 00:04: [io  0x0530-0x0537] has been reserved
[    0.560319] system 00:04: [io  0x0800-0x0827] could not be reserved
[    0.560324] system 00:04: [io  0x0830] has been reserved
[    0.560329] system 00:04: [io  0x0840-0x0847] has been reserved
[    0.560333] system 00:04: [io  0x0b00-0x0b1f] has been reserved
[    0.560338] system 00:04: [io  0x0c00-0x0c01] has been reserved
[    0.560343] system 00:04: [io  0x0c14] has been reserved
[    0.560347] system 00:04: [io  0x0c50-0x0c52] has been reserved
[    0.560351] system 00:04: [io  0x0cd0-0x0cd1] has been reserved
[    0.560358] system 00:04: [io  0x0cd2-0x0cd3] has been reserved
[    0.560363] system 00:04: [io  0x0cd4-0x0cd5] has been reserved
[    0.560367] system 00:04: [io  0x0cd6-0x0cd7] has been reserved
[    0.560371] system 00:04: [io  0x0cd8-0x0cdf] has been reserved
[    0.560376] system 00:04: [io  0x0cf9] could not be reserved
[    0.560380] system 00:04: [io  0x8100-0x81ff window] has been reserved
[    0.560385] system 00:04: [io  0x8200-0x82ff window] has been reserved
[    0.560391] system 00:04: Plug and Play ACPI device, IDs PNP0c02 (active)
[    0.560583] system 00:05: [mem 0x000e0000-0x000fffff] could not be reserved
[    0.560589] system 00:05: [mem 0xffe00000-0xffffffff] has been reserved
[    0.560594] system 00:05: [mem 0xfec10000-0xfec1001f] has been reserved
[    0.560598] system 00:05: [mem 0xfed00000-0xfed003ff] has been reserved
[    0.560603] system 00:05: [mem 0xfed61000-0xfed613ff] has been reserved
[    0.560608] system 00:05: [mem 0xfed80000-0xfed80fff] has been reserved
[    0.560613] system 00:05: Plug and Play ACPI device, IDs PNP0c01 (active)
[    0.561948] pnp: PnP ACPI: found 6 devices
[    0.572580] clocksource: acpi_pm: mask: 0xffffff max_cycles: 0xffffff, max_idle_ns: 2085701024 ns
[    0.572601] pci 0000:04:00.0: can't claim BAR 6 [mem 0xffff0000-0xffffffff pref]: no compatible bridge window
[    0.572641] pci 0000:00:07.0: bridge window [io  0x1000-0x0fff] to [bus 04] add_size 1000
[    0.572647] pci 0000:00:07.0: bridge window [mem 0x00100000-0x000fffff 64bit pref] to [bus 04] add_size 200000 add_align 100000
[    0.572680] pci 0000:00:07.0: res[15]=[mem 0x00100000-0x000fffff 64bit pref] res_to_dev_res add_size 200000 min_align 100000
[    0.572685] pci 0000:00:07.0: res[15]=[mem 0x00100000-0x002fffff 64bit pref] res_to_dev_res add_size 200000 min_align 100000
[    0.572690] pci 0000:00:07.0: res[13]=[io  0x1000-0x0fff] res_to_dev_res add_size 1000 min_align 1000
[    0.572695] pci 0000:00:07.0: res[13]=[io  0x1000-0x1fff] res_to_dev_res add_size 1000 min_align 1000
[    0.572740] pci 0000:00:07.0: BAR 15: assigned [mem 0xf0c00000-0xf0dfffff 64bit pref]
[    0.572751] pci 0000:00:07.0: BAR 13: assigned [io  0x1000-0x1fff]
[    0.572757] pci 0000:00:05.0: PCI bridge to [bus 02]
[    0.572765] pci 0000:00:05.0:   bridge window [mem 0xf0a00000-0xf0afffff]
[    0.572775] pci 0000:00:06.0: PCI bridge to [bus 03]
[    0.572779] pci 0000:00:06.0:   bridge window [io  0x2000-0x2fff]
[    0.572786] pci 0000:00:06.0:   bridge window [mem 0xf0200000-0xf09fffff]
[    0.572792] pci 0000:00:06.0:   bridge window [mem 0xf0000000-0xf00fffff 64bit pref]
[    0.572801] pci 0000:04:00.0: BAR 6: assigned [mem 0xf0110000-0xf011ffff pref]
[    0.572806] pci 0000:00:07.0: PCI bridge to [bus 04]
[    0.572810] pci 0000:00:07.0:   bridge window [io  0x1000-0x1fff]
[    0.572816] pci 0000:00:07.0:   bridge window [mem 0xf0100000-0xf01fffff]
[    0.572823] pci 0000:00:07.0:   bridge window [mem 0xf0c00000-0xf0dfffff 64bit pref]
[    0.572830] pci 0000:00:14.4: PCI bridge to [bus 05]
[    0.572861] pci_bus 0000:00: resource 4 [mem 0x000a0000-0x000bffff window]
[    0.572865] pci_bus 0000:00: resource 5 [mem 0x000c0000-0x000c1fff window]
[    0.572869] pci_bus 0000:00: resource 6 [mem 0x000c2000-0x000c3fff window]
[    0.572873] pci_bus 0000:00: resource 7 [mem 0x000c4000-0x000c5fff window]
[    0.572877] pci_bus 0000:00: resource 8 [mem 0x000c6000-0x000c7fff window]
[    0.572880] pci_bus 0000:00: resource 9 [mem 0x000c8000-0x000c9fff window]
[    0.572884] pci_bus 0000:00: resource 10 [mem 0x000ca000-0x000cbfff window]
[    0.572888] pci_bus 0000:00: resource 11 [mem 0x000cc000-0x000cdfff window]
[    0.572891] pci_bus 0000:00: resource 12 [mem 0x000d0000-0x000d1fff window]
[    0.572895] pci_bus 0000:00: resource 13 [mem 0x000d2000-0x000d3fff window]
[    0.572899] pci_bus 0000:00: resource 14 [mem 0x000d4000-0x000d5fff window]
[    0.572902] pci_bus 0000:00: resource 15 [mem 0x000d6000-0x000d7fff window]
[    0.572906] pci_bus 0000:00: resource 16 [mem 0x000d8000-0x000d9fff window]
[    0.572910] pci_bus 0000:00: resource 17 [mem 0x000da000-0x000dbfff window]
[    0.572913] pci_bus 0000:00: resource 18 [mem 0x000dc000-0x000ddfff window]
[    0.572917] pci_bus 0000:00: resource 19 [mem 0x000de000-0x000dffff window]
[    0.572920] pci_bus 0000:00: resource 20 [mem 0x000e0000-0x000e1fff window]
[    0.572924] pci_bus 0000:00: resource 21 [mem 0x000e2000-0x000e3fff window]
[    0.572928] pci_bus 0000:00: resource 22 [mem 0x000e4000-0x000e5fff window]
[    0.572931] pci_bus 0000:00: resource 23 [mem 0x000e6000-0x000e7fff window]
[    0.572935] pci_bus 0000:00: resource 24 [mem 0x000e8000-0x000e9fff window]
[    0.572939] pci_bus 0000:00: resource 25 [mem 0x000ea000-0x000ebfff window]
[    0.572942] pci_bus 0000:00: resource 26 [mem 0x000ec000-0x000edfff window]
[    0.572946] pci_bus 0000:00: resource 27 [mem 0x000ee000-0x000effff window]
[    0.572950] pci_bus 0000:00: resource 28 [mem 0xe0000000-0xf7ffffff window]
[    0.572954] pci_bus 0000:00: resource 29 [mem 0xfc000000-0xfdffffff window]
[    0.572957] pci_bus 0000:00: resource 30 [mem 0xfed40000-0xfed44fff window]
[    0.572961] pci_bus 0000:00: resource 31 [io  0x0000-0x0cf7 window]
[    0.572965] pci_bus 0000:00: resource 32 [io  0x0d00-0xffff window]
[    0.572969] pci_bus 0000:02: resource 1 [mem 0xf0a00000-0xf0afffff]
[    0.572973] pci_bus 0000:03: resource 0 [io  0x2000-0x2fff]
[    0.572977] pci_bus 0000:03: resource 1 [mem 0xf0200000-0xf09fffff]
[    0.572981] pci_bus 0000:03: resource 2 [mem 0xf0000000-0xf00fffff 64bit pref]
[    0.572985] pci_bus 0000:04: resource 0 [io  0x1000-0x1fff]
[    0.572988] pci_bus 0000:04: resource 1 [mem 0xf0100000-0xf01fffff]
[    0.572992] pci_bus 0000:04: resource 2 [mem 0xf0c00000-0xf0dfffff 64bit pref]
[    0.572997] pci_bus 0000:05: resource 4 [mem 0x000a0000-0x000bffff window]
[    0.573000] pci_bus 0000:05: resource 5 [mem 0x000c0000-0x000c1fff window]
[    0.573005] pci_bus 0000:05: resource 6 [mem 0x000c2000-0x000c3fff window]
[    0.573008] pci_bus 0000:05: resource 7 [mem 0x000c4000-0x000c5fff window]
[    0.573012] pci_bus 0000:05: resource 8 [mem 0x000c6000-0x000c7fff window]
[    0.573016] pci_bus 0000:05: resource 9 [mem 0x000c8000-0x000c9fff window]
[    0.573019] pci_bus 0000:05: resource 10 [mem 0x000ca000-0x000cbfff window]
[    0.573023] pci_bus 0000:05: resource 11 [mem 0x000cc000-0x000cdfff window]
[    0.573026] pci_bus 0000:05: resource 12 [mem 0x000d0000-0x000d1fff window]
[    0.573030] pci_bus 0000:05: resource 13 [mem 0x000d2000-0x000d3fff window]
[    0.573034] pci_bus 0000:05: resource 14 [mem 0x000d4000-0x000d5fff window]
[    0.573037] pci_bus 0000:05: resource 15 [mem 0x000d6000-0x000d7fff window]
[    0.573041] pci_bus 0000:05: resource 16 [mem 0x000d8000-0x000d9fff window]
[    0.573045] pci_bus 0000:05: resource 17 [mem 0x000da000-0x000dbfff window]
[    0.573048] pci_bus 0000:05: resource 18 [mem 0x000dc000-0x000ddfff window]
[    0.573052] pci_bus 0000:05: resource 19 [mem 0x000de000-0x000dffff window]
[    0.573055] pci_bus 0000:05: resource 20 [mem 0x000e0000-0x000e1fff window]
[    0.573059] pci_bus 0000:05: resource 21 [mem 0x000e2000-0x000e3fff window]
[    0.573063] pci_bus 0000:05: resource 22 [mem 0x000e4000-0x000e5fff window]
[    0.573066] pci_bus 0000:05: resource 23 [mem 0x000e6000-0x000e7fff window]
[    0.573070] pci_bus 0000:05: resource 24 [mem 0x000e8000-0x000e9fff window]
[    0.573074] pci_bus 0000:05: resource 25 [mem 0x000ea000-0x000ebfff window]
[    0.573077] pci_bus 0000:05: resource 26 [mem 0x000ec000-0x000edfff window]
[    0.573081] pci_bus 0000:05: resource 27 [mem 0x000ee000-0x000effff window]
[    0.573085] pci_bus 0000:05: resource 28 [mem 0xe0000000-0xf7ffffff window]
[    0.573089] pci_bus 0000:05: resource 29 [mem 0xfc000000-0xfdffffff window]
[    0.573092] pci_bus 0000:05: resource 30 [mem 0xfed40000-0xfed44fff window]
[    0.573097] pci_bus 0000:05: resource 31 [io  0x0000-0x0cf7 window]
[    0.573101] pci_bus 0000:05: resource 32 [io  0x0d00-0xffff window]
[    0.573217] NET: Registered protocol family 2
[    0.573633] TCP established hash table entries: 65536 (order: 7, 524288 bytes)
[    0.574062] TCP bind hash table entries: 65536 (order: 8, 1048576 bytes)
[    0.574590] TCP: Hash tables configured (established 65536 bind 65536)
[    0.574707] UDP hash table entries: 4096 (order: 5, 131072 bytes)
[    0.574796] UDP-Lite hash table entries: 4096 (order: 5, 131072 bytes)
[    0.575147] NET: Registered protocol family 1
[    0.575188] pci 0000:00:01.0: Video device with shadowed ROM
[    0.718030] PCI: CLS 32 bytes, default 64
[    0.718165] Unpacking initramfs...
[    1.340620] Freeing initrd memory: 18324K (ffff880035c26000 - ffff880036e0b000)
[    1.340748] PCI-DMA: Using software bounce buffering for IO (SWIOTLB)
[    1.340767] software IO TLB [mem 0xcee20000-0xd2e20000] (64MB) mapped at [ffff8800cee20000-ffff8800d2e1ffff]
[    1.341050] microcode: CPU0: patch_level=0x0500010d
[    1.341065] microcode: CPU1: patch_level=0x0500010d
[    1.341342] microcode: Microcode Update Driver: v2.00 <tigran@aivazian.fsnet.co.uk>, Peter Oruba
[    1.341360] LVT offset 0 assigned for vector 0x400
[    1.341434] perf: AMD IBS detected (0x000000ff)
[    1.342349] futex hash table entries: 1024 (order: 4, 65536 bytes)
[    1.342461] audit: initializing netlink subsys (disabled)
[    1.342506] audit: type=2000 audit(1449954435.044:1): initialized
[    1.343346] HugeTLB registered 2 MB page size, pre-allocated 0 pages
[    1.343400] zbud: loaded
[    1.343787] VFS: Disk quotas dquot_6.6.0
[    1.343848] VFS: Dquot-cache hash table entries: 512 (order 0, 4096 bytes)
[    1.345086] Block layer SCSI generic (bsg) driver version 0.4 loaded (major 250)
[    1.345230] io scheduler noop registered
[    1.345236] io scheduler deadline registered
[    1.345265] io scheduler cfq registered (default)
[    1.346845] pci_hotplug: PCI Hot Plug PCI Core version: 0.5
[    1.346872] pciehp 0000:00:07.0:pcie04: Slot #7 AttnBtn- PwrCtrl- MRL- AttnInd- PwrInd- HotPlug+ Surprise- Interlock- NoCompl+ LLActRep+
[    1.346952] pciehp 0000:00:07.0:pcie04: service driver pciehp loaded
[    1.346964] pciehp: PCI Express Hot Plug Controller Driver version: 0.4
[    1.347071] GHES: HEST is not enabled!
[    1.347317] Serial: 8250/16550 driver, 4 ports, IRQ sharing enabled
[    1.348297] Linux agpgart interface v0.103
[    1.348435] AMD IOMMUv2 driver by Joerg Roedel <jroedel@suse.de>
[    1.348438] AMD IOMMUv2 functionality not available on this system
[    1.349226] i8042: PNP: PS/2 Controller [PNP0303:KBC0,PNP0f13:MSE0] at 0x60,0x64 irq 1,12
[    1.352822] i8042: Detected active multiplexing controller, rev 1.1
[    1.353781] serio: i8042 KBD port at 0x60,0x64 irq 1
[    1.353797] serio: i8042 AUX0 port at 0x60,0x64 irq 12
[    1.353870] serio: i8042 AUX1 port at 0x60,0x64 irq 12
[    1.353931] serio: i8042 AUX2 port at 0x60,0x64 irq 12
[    1.353990] serio: i8042 AUX3 port at 0x60,0x64 irq 12
[    1.354592] mousedev: PS/2 mouse device common for all mice
[    1.354764] rtc_cmos 00:01: RTC can wake from S4
[    1.355093] rtc_cmos 00:01: rtc core: registered rtc_cmos as rtc0
[    1.355157] rtc_cmos 00:01: alarms up to one month, 114 bytes nvram, hpet irqs
[    1.355205] ledtrig-cpu: registered to indicate activity on CPUs
[    1.356057] NET: Registered protocol family 10
[    1.356493] mip6: Mobile IPv6
[    1.356520] NET: Registered protocol family 17
[    1.356534] mpls_gso: MPLS GSO support
[    1.357309] registered taskstats version 1
[    1.357370] zswap: loaded using pool lzo/zbud
[    1.358172] rtc_cmos 00:01: setting system clock to 2015-12-12 21:07:15 UTC (1449954435)
[    1.358307] PM: Hibernation image not present or could not be loaded.
[    1.359244] Freeing unused kernel memory: 1284K (ffffffff81b07000 - ffffffff81c48000)
[    1.359253] Write protecting the kernel read-only data: 10240k
[    1.359965] Freeing unused kernel memory: 660K (ffff88000155b000 - ffff880001600000)
[    1.360915] Freeing unused kernel memory: 1324K (ffff8800018b5000 - ffff880001a00000)
[    1.395474] input: AT Translated Set 2 keyboard as /devices/platform/i8042/serio0/input/input0
[    1.502896] systemd-udevd[68]: starting version 215
[    1.503772] random: systemd-udevd urandom read with 2 bits of entropy available
[    1.550940] r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
[    1.551703] r8169 0000:03:00.0 eth0: RTL8168evl/8111evl at 0xffffc90000018000, 08:9e:01:35:12:25, XID 0c900800 IRQ 25
[    1.551709] r8169 0000:03:00.0 eth0: jumbo features [frames: 9200 bytes, tx checksumming: ko]
[    1.553234] ACPI: bus type USB registered
[    1.553295] usbcore: registered new interface driver usbfs
[    1.553318] usbcore: registered new interface driver hub
[    1.553381] usbcore: registered new device driver usb
[    1.555786] QUIRK: Enable AMD PLL fix
[    1.555840] xhci_hcd 0000:00:10.0: xHCI Host Controller
[    1.555855] xhci_hcd 0000:00:10.0: new USB bus registered, assigned bus number 1
[    1.556069] xhci_hcd 0000:00:10.0: hcc params 0x014042c3 hci version 0x96 quirks 0x00000608
[    1.558273] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
[    1.559017] ohci_hcd: USB 1.1 'Open' Host Controller (OHCI) Driver
[    1.559429] ehci-pci: EHCI PCI platform driver
[    1.561114] usb usb1: New USB device found, idVendor=1d6b, idProduct=0002
[    1.561123] usb usb1: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    1.561128] usb usb1: Product: xHCI Host Controller
[    1.561132] usb usb1: Manufacturer: Linux 4.3.0-trunk-amd64 xhci-hcd
[    1.561135] usb usb1: SerialNumber: 0000:00:10.0
[    1.562384] SCSI subsystem initialized
[    1.565422] rtsx_pci 0000:04:00.0: rtsx_pci_acquire_irq: pcr->msi_en = 1, pci->irq = 29
[    1.566304] libata version 3.00 loaded.
[    1.566648] hub 1-0:1.0: USB hub found
[    1.567410] hub 1-0:1.0: 2 ports detected
[    1.567752] xhci_hcd 0000:00:10.0: xHCI Host Controller
[    1.567763] xhci_hcd 0000:00:10.0: new USB bus registered, assigned bus number 2
[    1.567809] usb usb2: We don't know the algorithms for LPM for this host, disabling LPM.
[    1.568316] usb usb2: New USB device found, idVendor=1d6b, idProduct=0003
[    1.568322] usb usb2: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    1.568325] usb usb2: Product: xHCI Host Controller
[    1.568329] usb usb2: Manufacturer: Linux 4.3.0-trunk-amd64 xhci-hcd
[    1.568333] usb usb2: SerialNumber: 0000:00:10.0
[    1.569128] hub 2-0:1.0: USB hub found
[    1.569164] hub 2-0:1.0: 2 ports detected
[    1.570195] ehci-pci 0000:00:12.2: EHCI Host Controller
[    1.570212] ehci-pci 0000:00:12.2: new USB bus registered, assigned bus number 3
[    1.570222] ehci-pci 0000:00:12.2: applying AMD SB700/SB800/Hudson-2/3 EHCI dummy qh workaround
[    1.570249] ehci-pci 0000:00:12.2: debug port 1
[    1.570317] ehci-pci 0000:00:12.2: irq 17, io mem 0xf0b4d900
[    1.570351] thermal LNXTHERM:00: registered as thermal_zone0
[    1.570359] ACPI: Thermal Zone [THZ0] (61 C)
[    1.581022] ehci-pci 0000:00:12.2: USB 2.0 started, EHCI 1.00
[    1.581195] usb usb3: New USB device found, idVendor=1d6b, idProduct=0002
[    1.581200] usb usb3: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    1.581204] usb usb3: Product: EHCI Host Controller
[    1.581208] usb usb3: Manufacturer: Linux 4.3.0-trunk-amd64 ehci_hcd
[    1.581212] usb usb3: SerialNumber: 0000:00:12.2
[    1.581570] hub 3-0:1.0: USB hub found
[    1.581592] hub 3-0:1.0: 5 ports detected
[    1.582295] ehci-pci 0000:00:13.2: EHCI Host Controller
[    1.582313] ehci-pci 0000:00:13.2: new USB bus registered, assigned bus number 4
[    1.582324] ehci-pci 0000:00:13.2: applying AMD SB700/SB800/Hudson-2/3 EHCI dummy qh workaround
[    1.582338] ehci-pci 0000:00:13.2: debug port 1
[    1.582388] ehci-pci 0000:00:13.2: irq 17, io mem 0xf0b4d800
[    1.593026] ehci-pci 0000:00:13.2: USB 2.0 started, EHCI 1.00
[    1.593144] usb usb4: New USB device found, idVendor=1d6b, idProduct=0002
[    1.593149] usb usb4: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    1.593153] usb usb4: Product: EHCI Host Controller
[    1.593157] usb usb4: Manufacturer: Linux 4.3.0-trunk-amd64 ehci_hcd
[    1.593161] usb usb4: SerialNumber: 0000:00:13.2
[    1.593461] hub 4-0:1.0: USB hub found
[    1.593479] hub 4-0:1.0: 5 ports detected
[    1.594324] ohci-pci: OHCI PCI platform driver
[    1.594712] ohci-pci 0000:00:12.0: OHCI PCI host controller
[    1.594727] ohci-pci 0000:00:12.0: new USB bus registered, assigned bus number 5
[    1.594792] ohci-pci 0000:00:12.0: irq 18, io mem 0xf0b4c000
[    1.653234] usb usb5: New USB device found, idVendor=1d6b, idProduct=0001
[    1.653243] usb usb5: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    1.653247] usb usb5: Product: OHCI PCI host controller
[    1.653251] usb usb5: Manufacturer: Linux 4.3.0-trunk-amd64 ohci_hcd
[    1.653254] usb usb5: SerialNumber: 0000:00:12.0
[    1.653797] hub 5-0:1.0: USB hub found
[    1.653836] hub 5-0:1.0: 5 ports detected
[    1.654451] ahci 0000:00:11.0: version 3.0
[    1.654860] ahci 0000:00:11.0: AHCI 0001.0300 32 slots 1 ports 6 Gbps 0x1 impl SATA mode
[    1.654868] ahci 0000:00:11.0: flags: 64bit ncq sntf ilck pm led clo pmp pio slum part 
[    1.655353] scsi host0: ahci
[    1.655480] ata1: SATA max UDMA/133 abar m2048@0xf0b4d000 port 0xf0b4d100 irq 30
[    1.655903] ohci-pci 0000:00:13.0: OHCI PCI host controller
[    1.655921] ohci-pci 0000:00:13.0: new USB bus registered, assigned bus number 6
[    1.655972] ohci-pci 0000:00:13.0: irq 18, io mem 0xf0b4b000
[    1.713184] usb usb6: New USB device found, idVendor=1d6b, idProduct=0001
[    1.713193] usb usb6: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    1.713197] usb usb6: Product: OHCI PCI host controller
[    1.713201] usb usb6: Manufacturer: Linux 4.3.0-trunk-amd64 ohci_hcd
[    1.713205] usb usb6: SerialNumber: 0000:00:13.0
[    1.713762] hub 6-0:1.0: USB hub found
[    1.713801] hub 6-0:1.0: 5 ports detected
[    1.714496] ohci-pci 0000:00:14.5: OHCI PCI host controller
[    1.714509] ohci-pci 0000:00:14.5: new USB bus registered, assigned bus number 7
[    1.714562] ohci-pci 0000:00:14.5: irq 18, io mem 0xf0b4a000
[    1.773136] usb usb7: New USB device found, idVendor=1d6b, idProduct=0001
[    1.773145] usb usb7: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    1.773150] usb usb7: Product: OHCI PCI host controller
[    1.773153] usb usb7: Manufacturer: Linux 4.3.0-trunk-amd64 ohci_hcd
[    1.773157] usb usb7: SerialNumber: 0000:00:14.5
[    1.773693] hub 7-0:1.0: USB hub found
[    1.773729] hub 7-0:1.0: 2 ports detected
[    2.144800] ata1: SATA link up 6.0 Gbps (SStatus 133 SControl 300)
[    2.146298] ata1.00: READ LOG DMA EXT failed, trying unqueued
[    2.146486] ata1.00: failed to get NCQ Send/Recv Log Emask 0x1
[    2.146495] ata1.00: ATA-9: Samsung SSD 840 PRO Series, DXM06B0Q, max UDMA/133
[    2.146499] ata1.00: 500118192 sectors, multi 16: LBA48 NCQ (depth 31/32), AA
[    2.146831] ata1.00: failed to get NCQ Send/Recv Log Emask 0x1
[    2.146843] ata1.00: configured for UDMA/133
[    2.147422] scsi 0:0:0:0: Direct-Access     ATA      Samsung SSD 840  6B0Q PQ: 0 ANSI: 5
[    2.151457] ata1.00: Enabling discard_zeroes_data
[    2.151582] sd 0:0:0:0: [sda] 500118192 512-byte logical blocks: (256 GB/238 GiB)
[    2.151938] sd 0:0:0:0: [sda] Write Protect is off
[    2.151945] sd 0:0:0:0: [sda] Mode Sense: 00 3a 00 00
[    2.152007] sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[    2.152238] ata1.00: Enabling discard_zeroes_data
[    2.154462]  sda: sda1 sda2 sda3
[    2.155134] ata1.00: Enabling discard_zeroes_data
[    2.155297] sd 0:0:0:0: [sda] Attached SCSI disk
[    2.156391] sd 0:0:0:0: Attached scsi generic sg0 type 0
[    2.164716] usb 6-3: new full-speed USB device number 2 using ohci-pci
[    2.164776] usb 4-4: new high-speed USB device number 3 using ehci-pci
[    2.207146] platform microcode: firmware: direct-loading firmware amd-ucode/microcode_amd.bin
[    2.213141] microcode: CPU0: new patch_level=0x05000119
[    2.219065] microcode: CPU1: new patch_level=0x05000119
[    2.253103] device-mapper: uevent: version 1.0.3
[    2.253636] device-mapper: ioctl: 4.33.0-ioctl (2015-8-18) initialised: dm-devel@redhat.com
[    2.308084] usb 4-4: New USB device found, idVendor=5986, idProduct=0299
[    2.308093] usb 4-4: New USB device strings: Mfr=1, Product=2, SerialNumber=0
[    2.308098] usb 4-4: Product: Integrated Camera
[    2.308101] usb 4-4: Manufacturer: Vimicro corp.
[    2.336441] tsc: Refined TSC clocksource calibration: 1696.914 MHz
[    2.336452] clocksource: tsc: mask: 0xffffffffffffffff max_cycles: 0x1875c420428, max_idle_ns: 440795272528 ns
[    2.338679] usb 6-3: New USB device found, idVendor=0a5c, idProduct=21f3
[    2.338687] usb 6-3: New USB device strings: Mfr=1, Product=2, SerialNumber=3
[    2.338691] usb 6-3: Product: BCM20702A0
[    2.338695] usb 6-3: Manufacturer: Broadcom Corp
[    2.338699] usb 6-3: SerialNumber: 2CD05A80FEA0
[    2.552657] NET: Registered protocol family 38
[    2.586765] sha256_ssse3: Using SSSE3 optimized SHA-256 implementation
[    3.335853] clocksource: Switched to clocksource tsc
[    5.884616] EXT4-fs (dm-1): mounted filesystem with ordered data mode. Opts: (null)
[    6.419521] systemd[1]: Cannot add dependency job for unit NetworkManager.service, ignoring: Unit NetworkManager.service failed to load: No such file or directory.
[    6.419679] systemd[1]: Cannot add dependency job for unit display-manager.service, ignoring: Unit display-manager.service failed to load: No such file or directory.
[    6.527765] lp: driver loaded but no devices found
[    6.537385] ppdev: user-space parallel port driver
[    6.560244] fuse init (API version 7.23)
[    6.573866] loop: module loaded
[    6.588800] systemd-udevd[274]: starting version 215
[    6.954393] ACPI: acpi_idle registered with cpuidle
[    6.962901] acpi-cpufreq: overriding BIOS provided _PSD data
[    6.998527] input: Power Button as /devices/LNXSYSTM:00/LNXSYBUS:00/PNP0C0C:00/input/input5
[    6.998540] ACPI: Power Button [PWRB]
[    6.998683] input: Lid Switch as /devices/LNXSYSTM:00/LNXSYBUS:00/PNP0C0D:00/input/input6
[    6.999419] shpchp: Standard Hot Plug PCI Controller Driver version: 0.4
[    6.999781] ACPI: Lid Switch [LID]
[    6.999921] input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/input/input7
[    6.999929] ACPI: Power Button [PWRF]
[    7.017364] ACPI: Video Device [VGA1] (multi-head: yes  rom: no  post: no)
[    7.017851] [Firmware Bug]: ACPI: No _BQC method, cannot determine initial brightness
[    7.021798] acpi device:3a: registered as cooling_device0
[    7.021955] input: Video Bus as /devices/LNXSYSTM:00/LNXSYBUS:00/PNP0A08:00/LNXVIDEO:01/input/input8
[    7.056824] [drm] Initialized drm 1.1.0 20060810
[    7.089350] Non-volatile memory driver v1.3
[    7.099713] thinkpad_acpi: ThinkPad ACPI Extras v0.25
[    7.099721] thinkpad_acpi: http://ibm-acpi.sf.net/
[    7.099724] thinkpad_acpi: ThinkPad BIOS HMET93WW (2.53 ), EC unknown
[    7.099727] thinkpad_acpi: Lenovo ThinkPad Edge E135, model 335963G
[    7.100015] ACPI: Battery Slot [BAT1] (battery present)
[    7.100653] ACPI: AC Adapter [ACAD] (off-line)
[    7.101068] thinkpad_acpi: Unsupported brightness interface, please contact ibm-acpi-devel@lists.sourceforge.net
[    7.101523] wmi: Mapper loaded
[    7.102166] thinkpad_acpi: radio switch found; radios are enabled
[    7.102183] thinkpad_acpi: possible tablet mode switch found; ThinkPad in laptop mode
[    7.102212] thinkpad_acpi: This ThinkPad has standard ACPI backlight brightness control, supported by the ACPI video driver
[    7.102215] thinkpad_acpi: Disabling thinkpad-acpi brightness events by default...
[    7.109099] thinkpad_acpi: rfkill switch tpacpi_bluetooth_sw: radio is unblocked
[    7.127163] input: ThinkPad Extra Buttons as /devices/platform/thinkpad_acpi/input/input9
[    7.171322] input: HD-Audio Generic HDMI/DP,pcm=3 as /devices/pci0000:00/0000:00:01.1/sound/card0/input10
[    7.179763] ACPI Warning: SystemIO range 0x0000000000000B00-0x0000000000000B07 conflicts with OpRegion 0x0000000000000B00-0x0000000000000B0F (\_SB_.PCI0.SMB_.SMB0) (20150818/utaddress-254)
[    7.179780] ACPI: If an ACPI driver is available for this device, you should use it instead of the native driver
[    7.192728] bcma: bus0: Found chip with id 43228, rev 0x00 and package 0x08
[    7.192759] bcma: bus0: Core 0 found: ChipCommon (manuf 0x4BF, id 0x800, rev 0x25, class 0x0)
[    7.192780] bcma: bus0: Core 1 found: IEEE 802.11 (manuf 0x4BF, id 0x812, rev 0x1E, class 0x0)
[    7.192863] bcma: bus0: Core 2 found: PCIe (manuf 0x4BF, id 0x820, rev 0x12, class 0x0)
[    7.192883] bcma: bus0: Core 3 found: SDIO Device (manuf 0x4BF, id 0x829, rev 0x07, class 0x0)
[    7.201961] snd_hda_codec_realtek hdaudioC1D0: autoconfig for ALC269VC: line_outs=1 (0x14/0x0/0x0/0x0/0x0) type:speaker
[    7.201971] snd_hda_codec_realtek hdaudioC1D0:    speaker_outs=0 (0x0/0x0/0x0/0x0/0x0)
[    7.201976] snd_hda_codec_realtek hdaudioC1D0:    hp_outs=1 (0x15/0x0/0x0/0x0/0x0)
[    7.201980] snd_hda_codec_realtek hdaudioC1D0:    mono: mono_out=0x0
[    7.201984] snd_hda_codec_realtek hdaudioC1D0:    inputs:
[    7.201989] snd_hda_codec_realtek hdaudioC1D0:      Mic=0x18
[    7.201993] snd_hda_codec_realtek hdaudioC1D0:      Internal Mic=0x12
[    7.213135] bcma: bus0: Bus registered
[    7.282615] input: HDA Digital PCBeep as /devices/pci0000:00/0000:00:14.2/sound/card1/input11
[    7.283426] input: HD-Audio Generic Mic as /devices/pci0000:00/0000:00:14.2/sound/card1/input12
[    7.283498] input: HD-Audio Generic Headphone as /devices/pci0000:00/0000:00:14.2/sound/card1/input13
[    7.319365] [drm] radeon kernel modesetting enabled.
[    7.346639] input: PC Speaker as /devices/platform/pcspkr/input/input15
[    7.358472] CRAT table not found
[    7.358480] Finished initializing topology ret=0
[    7.359345] kfd kfd: Initialized module
[    7.363748] [drm] initializing kernel modesetting (PALM 0x1002:0x9808 0x17AA:0x5105).
[    7.363786] [drm] register mmio base: 0xF0B00000
[    7.363789] [drm] register mmio size: 262144
[    7.363886] ATOM BIOS: Lenovo
[    7.363967] radeon 0000:00:01.0: VRAM: 384M 0x0000000000000000 - 0x0000000017FFFFFF (384M used)
[    7.363973] radeon 0000:00:01.0: GTT: 1024M 0x0000000018000000 - 0x0000000057FFFFFF
[    7.363977] [drm] Detected VRAM RAM=384M, BAR=256M
[    7.363979] [drm] RAM width 32bits DDR
[    7.364103] [TTM] Zone  kernel: Available graphics memory: 3781862 kiB
[    7.364107] [TTM] Zone   dma32: Available graphics memory: 2097152 kiB
[    7.364109] [TTM] Initializing pool allocator
[    7.364119] [TTM] Initializing DMA pool allocator
[    7.364163] [drm] radeon: 384M of VRAM memory ready
[    7.364166] [drm] radeon: 1024M of GTT memory ready.
[    7.364188] [drm] Loading PALM Microcode
[    7.372900] radeon 0000:00:01.0: firmware: direct-loading firmware radeon/PALM_pfp.bin
[    7.374037] radeon 0000:00:01.0: firmware: direct-loading firmware radeon/PALM_me.bin
[    7.374327] radeon 0000:00:01.0: firmware: direct-loading firmware radeon/SUMO_rlc.bin
[    7.374337] [drm] Internal thermal controller without fan control
[    7.374441] [drm] Found smc ucode version: 0x00010601
[    7.374527] [drm] radeon: dpm initialized
[    7.380105] radeon 0000:00:01.0: firmware: direct-loading firmware radeon/SUMO_uvd.bin
[    7.380203] [drm] GART: num cpu pages 262144, num gpu pages 262144
[    7.435297] [drm] PCIE GART of 1024M enabled (table at 0x0000000000274000).
[    7.437223] radeon 0000:00:01.0: WB enabled
[    7.437234] radeon 0000:00:01.0: fence driver on ring 0 use gpu addr 0x0000000018000c00 and cpu addr 0xffff8800ceb68c00
[    7.437240] radeon 0000:00:01.0: fence driver on ring 3 use gpu addr 0x0000000018000c0c and cpu addr 0xffff8800ceb68c0c
[    7.438010] radeon 0000:00:01.0: fence driver on ring 5 use gpu addr 0x0000000000072118 and cpu addr 0xffffc90001432118
[    7.438015] [drm] Supports vblank timestamp caching Rev 2 (21.10.2013).
[    7.438017] [drm] Driver supports precise vblank timestamp query.
[    7.438021] radeon 0000:00:01.0: radeon: MSI limited to 32-bit
[    7.438388] radeon 0000:00:01.0: radeon: using MSI.
[    7.438436] [drm] radeon: irq initialized.
[    7.448639] kvm: Nested Virtualization enabled
[    7.448652] kvm: Nested Paging enabled
[    7.457866] [drm] ring test on 0 succeeded in 1 usecs
[    7.457881] [drm] ring test on 3 succeeded in 2 usecs
[    7.510167] [drm] ring test on 5 succeeded in 1 usecs
[    7.534030] [drm] UVD initialized successfully.
[    7.537296] random: nonblocking pool is initialized
[    7.539923] [drm] ib test on ring 0 succeeded in 0 usecs
[    7.540049] [drm] ib test on ring 3 succeeded in 0 usecs
[    7.595788] EXT4-fs (dm-1): re-mounted. Opts: discard,errors=remount-ro
[    7.967304] EXT4-fs (dm-3): mounted filesystem with ordered data mode. Opts: discard
[    8.008079] psmouse serio4: synaptics: queried max coordinates: x [..5768], y [..5236]
[    8.021305] EXT4-fs (dm-2): mounted filesystem with ordered data mode. Opts: discard
[    8.054993] psmouse serio4: synaptics: queried min coordinates: x [1172..], y [616..]
[    8.056597] [drm] ib test on ring 5 succeeded
[    8.118453] EXT4-fs (dm-5): mounted filesystem with ordered data mode. Opts: discard
[    8.139790] psmouse serio4: synaptics: Touchpad model: 1, fw: 8.1, id: 0x1e2b1, caps: 0xd002a3/0x940300/0x126c00/0x0, board id: 2290, fw id: 1212745
[    8.139817] psmouse serio4: synaptics: serio: Synaptics pass-through port at isa0060/serio4/input0
[    8.182433] input: SynPS/2 Synaptics TouchPad as /devices/platform/i8042/serio4/input/input18
[    8.200102] [drm] radeon atom DIG backlight initialized
[    8.200116] [drm] Radeon Display Connectors
[    8.200119] [drm] Connector 0:
[    8.200122] [drm]   LVDS-1
[    8.200125] [drm]   HPD1
[    8.200130] [drm]   DDC: 0x6430 0x6430 0x6434 0x6434 0x6438 0x6438 0x643c 0x643c
[    8.200132] [drm]   Encoders:
[    8.200134] [drm]     LCD1: INTERNAL_UNIPHY
[    8.200138] [drm] Connector 1:
[    8.200140] [drm]   HDMI-A-1
[    8.200142] [drm]   HPD2
[    8.200145] [drm]   DDC: 0x6440 0x6440 0x6444 0x6444 0x6448 0x6448 0x644c 0x644c
[    8.200147] [drm]   Encoders:
[    8.200149] [drm]     DFP1: INTERNAL_UNIPHY
[    8.200151] [drm] Connector 2:
[    8.200153] [drm]   VGA-1
[    8.200157] [drm]   DDC: 0x64d8 0x64d8 0x64dc 0x64dc 0x64e0 0x64e0 0x64e4 0x64e4
[    8.200159] [drm]   Encoders:
[    8.200161] [drm]     CRT1: INTERNAL_KLDSCP_DAC1
[    8.202959] EXT4-fs (dm-4): mounted filesystem with ordered data mode. Opts: discard
[    8.206166] b43-phy0: Broadcom 43228 WLAN found (core revision 30)
[    8.206624] b43-phy0: Found PHY: Analog 9, Type 4 (N), Revision 16
[    8.206634] b43-phy0: Found Radio: Manuf 0x17F, ID 0x2057, Revision 9, Version 1
[    8.207287] Broadcom 43xx driver loaded [ Features: PMNLS ]
[    8.212287] b43 bcma0:1: firmware: direct-loading firmware b43/ucode30_mimo.fw
[    8.217056] b43 bcma0:1: firmware: direct-loading firmware b43/n16initvals30.fw
[    8.224342] b43 bcma0:1: firmware: direct-loading firmware b43/n16bsinitvals30.fw
[    8.276239] ieee80211 phy0: Selected rate control algorithm 'minstrel_ht'
[    8.286686] cfg80211: World regulatory domain updated:
[    8.286698] cfg80211:  DFS Master region: unset
[    8.286702] cfg80211:   (start_freq - end_freq @ bandwidth), (max_antenna_gain, max_eirp), (dfs_cac_time)
[    8.286708] cfg80211:   (2402000 KHz - 2472000 KHz @ 40000 KHz), (N/A, 2000 mBm), (N/A)
[    8.286712] cfg80211:   (2457000 KHz - 2482000 KHz @ 40000 KHz), (N/A, 2000 mBm), (N/A)
[    8.286716] cfg80211:   (2474000 KHz - 2494000 KHz @ 20000 KHz), (N/A, 2000 mBm), (N/A)
[    8.286720] cfg80211:   (5170000 KHz - 5250000 KHz @ 80000 KHz, 160000 KHz AUTO), (N/A, 2000 mBm), (N/A)
[    8.286724] cfg80211:   (5250000 KHz - 5330000 KHz @ 80000 KHz, 160000 KHz AUTO), (N/A, 2000 mBm), (0 s)
[    8.286728] cfg80211:   (5490000 KHz - 5730000 KHz @ 160000 KHz), (N/A, 2000 mBm), (0 s)
[    8.286732] cfg80211:   (5735000 KHz - 5835000 KHz @ 80000 KHz), (N/A, 2000 mBm), (N/A)
[    8.286735] cfg80211:   (57240000 KHz - 63720000 KHz @ 2160000 KHz), (N/A, 0 mBm), (N/A)
[    8.313665] cfg80211: Regulatory domain changed to country: DE
[    8.313676] cfg80211:  DFS Master region: ETSI
[    8.313680] cfg80211:   (start_freq - end_freq @ bandwidth), (max_antenna_gain, max_eirp), (dfs_cac_time)
[    8.313685] cfg80211:   (2400000 KHz - 2483500 KHz @ 40000 KHz), (N/A, 2000 mBm), (N/A)
[    8.313690] cfg80211:   (5150000 KHz - 5250000 KHz @ 80000 KHz, 200000 KHz AUTO), (N/A, 2000 mBm), (N/A)
[    8.313694] cfg80211:   (5250000 KHz - 5350000 KHz @ 80000 KHz, 200000 KHz AUTO), (N/A, 2000 mBm), (0 s)
[    8.313698] cfg80211:   (5470000 KHz - 5725000 KHz @ 160000 KHz), (N/A, 2698 mBm), (0 s)
[    8.313702] cfg80211:   (57000000 KHz - 66000000 KHz @ 2160000 KHz), (N/A, 4000 mBm), (N/A)
[    8.424197] systemd-journald[304]: Received request to flush runtime journal from PID 1
[    8.537682] ip_tables: (C) 2000-2006 Netfilter Core Team
[    8.573937] nf_conntrack version 0.5.0 (65536 buckets, 262144 max)
[    8.626436] [drm] fb mappable at 0xE0478000
[    8.626445] [drm] vram apper at 0xE0000000
[    8.626448] [drm] size 4325376
[    8.626451] [drm] fb depth is 24
[    8.626453] [drm]    pitch is 5632
[    8.628405] media: Linux media interface: v0.10
[    8.629256] fbcon: radeondrmfb (fb0) is primary device
[    8.651320] Linux video capture interface: v2.00
[    8.706945] Bluetooth: Core ver 2.20
[    8.706979] NET: Registered protocol family 31
[    8.706980] Bluetooth: HCI device and connection manager initialized
[    8.707361] Bluetooth: HCI socket layer initialized
[    8.707367] Bluetooth: L2CAP socket layer initialized
[    8.707383] Bluetooth: SCO socket layer initialized
[    8.723106] usbcore: registered new interface driver btusb
[    8.736982] Bluetooth: hci0: BCM: chip id 63
[    8.738995] Bluetooth: hci0: BCM20702A1 (001.002.014) build 0000
[    8.739460] bluetooth hci0: firmware: failed to load brcm/BCM20702A1-0a5c-21f3.hcd (-2)
[    8.739464] bluetooth hci0: Direct firmware load for brcm/BCM20702A1-0a5c-21f3.hcd failed with error -2
[    8.739468] Bluetooth: hci0: BCM: Patch brcm/BCM20702A1-0a5c-21f3.hcd not found
[    8.764952] uvcvideo: Found UVC 1.00 device Integrated Camera (5986:0299)
[    8.768197] input: Integrated Camera as /devices/pci0000:00/0000:00:13.2/usb4/4-4/4-4:1.0/input/input20
[    8.768533] usbcore: registered new interface driver uvcvideo
[    8.768534] USB Video Class driver (1.1.1)
[    8.802826] ip6_tables: (C) 2000-2006 Netfilter Core Team
[    9.205070] r8169 0000:03:00.0 eth0: rtl_counters_cond == 1 (loop: 1000, delay: 10).
[    9.216980] Console: switching to colour frame buffer device 170x48
[    9.223431] radeon 0000:00:01.0: fb0: radeondrmfb frame buffer device
[    9.240386] [drm] Initialized radeon 2.43.0 20080528 for 0000:00:01.0 on minor 0
[    9.312672] RPC: Registered named UNIX socket transport module.
[    9.312683] RPC: Registered udp transport module.
[    9.312685] RPC: Registered tcp transport module.
[    9.312688] RPC: Registered tcp NFSv4.1 backchannel transport module.
[    9.324269] FS-Cache: Loaded
[    9.351097] FS-Cache: Netfs 'nfs' registered for caching
[    9.381813] Installing knfsd (copyright (C) 1996 okir@monad.swb.de).
[   10.016983] Bluetooth: BNEP (Ethernet Emulation) ver 1.3
[   10.016993] Bluetooth: BNEP filters: protocol multicast
[   10.017005] Bluetooth: BNEP socket layer initialized
[   11.688807] r8169 0000:03:00.0 eth0: rtl_counters_cond == 1 (loop: 1000, delay: 10).
[   12.586874] r8169 0000:03:00.0 eth0: rtl_eriar_cond == 1 (loop: 100, delay: 100).
[   12.935385] psmouse serio5: trackpoint: IBM TrackPoint firmware: 0x0e, buttons: 3/3
[   13.159281] input: TPPS/2 IBM TrackPoint as /devices/platform/i8042/serio4/serio5/input/input19
[   36.987435] r8169 0000:03:00.0 eth0: rtl_counters_cond == 1 (loop: 1000, delay: 10).
[   37.102262] r8169 0000:03:00.0 eth0: rtl_counters_cond == 1 (loop: 1000, delay: 10).
[   67.147773] r8169 0000:03:00.0 eth0: rtl_eriar_cond == 1 (loop: 100, delay: 100).
[   67.161132] r8169 0000:03:00.0 eth0: rtl_eriar_cond == 1 (loop: 100, delay: 100).
[   67.174505] r8169 0000:03:00.0 eth0: rtl_eriar_cond == 1 (loop: 100, delay: 100).
[   67.187867] r8169 0000:03:00.0 eth0: rtl_eriar_cond == 1 (loop: 100, delay: 100).
[   67.232408] r8169 0000:03:00.0 eth0: rtl_counters_cond == 1 (loop: 1000, delay: 10).
[   67.250810] r8169 0000:03:00.0: firmware: direct-loading firmware rtl_nic/rtl8168e-3.fw
[   67.350455] r8169 0000:03:00.0 eth0: link down
[   67.350581] IPv6: ADDRCONF(NETDEV_UP): eth0: link is not ready
[   69.671259] r8169 0000:03:00.0 eth0: link up
[   69.671293] IPv6: ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready

=2D-nextPart5036767.aVcEzaX8ML
Content-Disposition: attachment; filename="dmesg_power"
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="UTF-8"; name="dmesg_withpowersupply.txt"

[    0.000000] Initializing cgroup subsys cpuset
[    0.000000] Initializing cgroup subsys cpu
[    0.000000] Initializing cgroup subsys cpuacct
[    0.000000] Linux version 4.3.0-trunk-amd64 (debian-kernel@lists.debian.org) (gcc version 5.2.1 20151028 (Debian 5.2.1-23) ) #1 SMP Debian 4.3-1~exp1 (2015-11-04)
[    0.000000] Command line: BOOT_IMAGE=/boot/vmlinuz-4.3.0-trunk-amd64 root=/dev/mapper/fuchs--vg-root ro quiet
[    0.000000] tseg: 00dfc00000
[    0.000000] x86/fpu: Legacy x87 FPU detected.
[    0.000000] x86/fpu: Using 'lazy' FPU context switches.
[    0.000000] e820: BIOS-provided physical RAM map:
[    0.000000] BIOS-e820: [mem 0x0000000000000000-0x000000000009e7ff] usable
[    0.000000] BIOS-e820: [mem 0x000000000009e800-0x000000000009ffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000000e0000-0x00000000000fffff] reserved
[    0.000000] BIOS-e820: [mem 0x0000000000100000-0x00000000d2e1ffff] usable
[    0.000000] BIOS-e820: [mem 0x00000000d2e20000-0x00000000ded02fff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000ded03000-0x00000000dee32fff] ACPI NVS
[    0.000000] BIOS-e820: [mem 0x00000000dee33000-0x00000000deeb2fff] ACPI data
[    0.000000] BIOS-e820: [mem 0x00000000deeb3000-0x00000000dfffffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000fec00000-0x00000000fecfffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000fed80000-0x00000000fed80fff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000ffc00000-0x00000000ffffffff] reserved
[    0.000000] BIOS-e820: [mem 0x0000000100000000-0x0000000206ffffff] usable
[    0.000000] NX (Execute Disable) protection: active
[    0.000000] SMBIOS 2.7 present.
[    0.000000] DMI: LENOVO 335963G/335963G, BIOS HMET93WW (2.53 ) 07/11/2013
[    0.000000] e820: update [mem 0x00000000-0x00000fff] usable ==> reserved
[    0.000000] e820: remove [mem 0x000a0000-0x000fffff] usable
[    0.000000] e820: last_pfn = 0x207000 max_arch_pfn = 0x400000000
[    0.000000] MTRR default type: uncachable
[    0.000000] MTRR fixed ranges enabled:
[    0.000000]   00000-9FFFF write-back
[    0.000000]   A0000-BFFFF uncachable
[    0.000000]   C0000-FFFFF write-protect
[    0.000000] MTRR variable ranges enabled:
[    0.000000]   0 base 000000000 mask F80000000 write-back
[    0.000000]   1 base 080000000 mask FC0000000 write-back
[    0.000000]   2 base 0C0000000 mask FE0000000 write-back
[    0.000000]   3 base 207000000 mask FFF000000 uncachable
[    0.000000]   4 base 208000000 mask FF8000000 uncachable
[    0.000000]   5 base 0FED80000 mask FFFFFF000 uncachable
[    0.000000]   6 disabled
[    0.000000]   7 base 0FFC00000 mask FFFC00000 write-protect
[    0.000000] TOM2: 000000021f000000 aka 8688M
[    0.000000] x86/PAT: Configuration [0-7]: WB  WC  UC- UC  WB  WC  UC- WT  
[    0.000000] e820: last_pfn = 0xd2e20 max_arch_pfn = 0x400000000
[    0.000000] found SMP MP-table at [mem 0x000fa8f0-0x000fa8ff] mapped at [ffff8800000fa8f0]
[    0.000000] Base memory trampoline at [ffff880000098000] 98000 size 24576
[    0.000000] Using GB pages for direct mapping
[    0.000000] init_memory_mapping: [mem 0x00000000-0x000fffff]
[    0.000000]  [mem 0x00000000-0x000fffff] page 4k
[    0.000000] BRK [0x01d20000, 0x01d20fff] PGTABLE
[    0.000000] BRK [0x01d21000, 0x01d21fff] PGTABLE
[    0.000000] BRK [0x01d22000, 0x01d22fff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0x206e00000-0x206ffffff]
[    0.000000]  [mem 0x206e00000-0x206ffffff] page 2M
[    0.000000] BRK [0x01d23000, 0x01d23fff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0x200000000-0x206dfffff]
[    0.000000]  [mem 0x200000000-0x206dfffff] page 2M
[    0.000000] init_memory_mapping: [mem 0x1e0000000-0x1ffffffff]
[    0.000000]  [mem 0x1e0000000-0x1ffffffff] page 1G
[    0.000000] init_memory_mapping: [mem 0x00100000-0xd2e1ffff]
[    0.000000]  [mem 0x00100000-0x001fffff] page 4k
[    0.000000]  [mem 0x00200000-0x3fffffff] page 2M
[    0.000000]  [mem 0x40000000-0xbfffffff] page 1G
[    0.000000]  [mem 0xc0000000-0xd2dfffff] page 2M
[    0.000000]  [mem 0xd2e00000-0xd2e1ffff] page 4k
[    0.000000] init_memory_mapping: [mem 0x100000000-0x1dfffffff]
[    0.000000]  [mem 0x100000000-0x1dfffffff] page 1G
[    0.000000] RAMDISK: [mem 0x35c26000-0x36e0afff]
[    0.000000] ACPI: Early table checksum verification disabled
[    0.000000] ACPI: RSDP 0x00000000000F0120 000024 (v02 LENOVO)
[    0.000000] ACPI: XSDT 0x00000000DEEB2170 00008C (v01 LENOVO TP-HM    06040000 PTL  00000002)
[    0.000000] ACPI: FACP 0x00000000DEE9F000 00010C (v05 LENOVO TP-HM    00002530 PTL  00000002)
[    0.000000] ACPI: DSDT 0x00000000DEEA1000 010AF4 (v01 LENOVO AMD      00001000 INTL 20061109)
[    0.000000] ACPI: FACS 0x00000000DEE1A000 000040
[    0.000000] ACPI: HPET 0x00000000DEE9E000 000038 (v01 LENOVO TP-HM    00002530 PTL  00000002)
[    0.000000] ACPI: APIC 0x00000000DEE9D000 00007A (v02 LENOVO TP-HM    00002530 PTL  00000002)
[    0.000000] ACPI: MCFG 0x00000000DEE9C000 00003C (v01 LENOVO TP-HM    00002530 PTL  00000002)
[    0.000000] ACPI: SBST 0x00000000DEE9B000 000030 (v01 LENOVO TP-HM    00002530 PTL  00000002)
[    0.000000] ACPI: FPDT 0x00000000DEE9A000 000064 (v01 LENOVO TP-HM    00002530 PTL  00000002)
[    0.000000] ACPI: UEFI 0x00000000DEE99000 00003E (v01 LENOVO TP-HM    00002530 PTL  00000002)
[    0.000000] ACPI: UEFI 0x00000000DEE98000 000042 (v01 PTL    COMBUF   00000001 PTL  00000001)
[    0.000000] ACPI: POAT 0x00000000DEDF5000 000055 (v03 LENOVO TP-HM    00002530 PTL  00000002)
[    0.000000] ACPI: SSDT 0x00000000DEE97000 0003DE (v01 AMD    POWERNOW 00000001 AMD  00000001)
[    0.000000] ACPI: SSDT 0x00000000DEE95000 0016E4 (v02 AMD    ALIB     00000001 MSFT 04000000)
[    0.000000] ACPI: UEFI 0x00000000DEE94000 000292 (v01 LENOVO TP-HM    00002530 PTL  00000002)
[    0.000000] ACPI: DBG2 0x00000000DEE93000 00006B (v00 LENOVO TP-HM    00002530 PTL  00000002)
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] No NUMA configuration found
[    0.000000] Faking a node at [mem 0x0000000000000000-0x0000000206ffffff]
[    0.000000] NODE_DATA(0) allocated [mem 0x206ffa000-0x206ffdfff]
[    0.000000]  [ffffea0000000000-ffffea00081fffff] PMD -> [ffff8801fee00000-ffff8802065fffff] on node 0
[    0.000000] Zone ranges:
[    0.000000]   DMA      [mem 0x0000000000001000-0x0000000000ffffff]
[    0.000000]   DMA32    [mem 0x0000000001000000-0x00000000ffffffff]
[    0.000000]   Normal   [mem 0x0000000100000000-0x0000000206ffffff]
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x0000000000001000-0x000000000009dfff]
[    0.000000]   node   0: [mem 0x0000000000100000-0x00000000d2e1ffff]
[    0.000000]   node   0: [mem 0x0000000100000000-0x0000000206ffffff]
[    0.000000] Initmem setup node 0 [mem 0x0000000000001000-0x0000000206ffffff]
[    0.000000] On node 0 totalpages: 1940925
[    0.000000]   DMA zone: 64 pages used for memmap
[    0.000000]   DMA zone: 21 pages reserved
[    0.000000]   DMA zone: 3997 pages, LIFO batch:0
[    0.000000]   DMA32 zone: 13433 pages used for memmap
[    0.000000]   DMA32 zone: 859680 pages, LIFO batch:31
[    0.000000]   Normal zone: 16832 pages used for memmap
[    0.000000]   Normal zone: 1077248 pages, LIFO batch:31
[    0.000000] ACPI: PM-Timer IO Port: 0x808
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x00] high edge lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x01] high edge lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x02] high edge lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x03] high edge lint[0x1])
[    0.000000] IOAPIC[0]: apic_id 2, version 33, address 0xfec00000, GSI 0-23
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
[    0.000000] ACPI: IRQ0 used by override.
[    0.000000] ACPI: IRQ9 used by override.
[    0.000000] Using ACPI (MADT) for SMP configuration information
[    0.000000] ACPI: HPET id: 0x43538210 base: 0xfed00000
[    0.000000] smpboot: Allowing 4 CPUs, 2 hotplug CPUs
[    0.000000] PM: Registered nosave memory: [mem 0x00000000-0x00000fff]
[    0.000000] PM: Registered nosave memory: [mem 0x0009e000-0x0009efff]
[    0.000000] PM: Registered nosave memory: [mem 0x0009f000-0x0009ffff]
[    0.000000] PM: Registered nosave memory: [mem 0x000a0000-0x000dffff]
[    0.000000] PM: Registered nosave memory: [mem 0x000e0000-0x000fffff]
[    0.000000] PM: Registered nosave memory: [mem 0xd2e20000-0xded02fff]
[    0.000000] PM: Registered nosave memory: [mem 0xded03000-0xdee32fff]
[    0.000000] PM: Registered nosave memory: [mem 0xdee33000-0xdeeb2fff]
[    0.000000] PM: Registered nosave memory: [mem 0xdeeb3000-0xdfffffff]
[    0.000000] PM: Registered nosave memory: [mem 0xe0000000-0xfebfffff]
[    0.000000] PM: Registered nosave memory: [mem 0xfec00000-0xfecfffff]
[    0.000000] PM: Registered nosave memory: [mem 0xfed00000-0xfed7ffff]
[    0.000000] PM: Registered nosave memory: [mem 0xfed80000-0xfed80fff]
[    0.000000] PM: Registered nosave memory: [mem 0xfed81000-0xffbfffff]
[    0.000000] PM: Registered nosave memory: [mem 0xffc00000-0xffffffff]
[    0.000000] e820: [mem 0xe0000000-0xfebfffff] available for PCI devices
[    0.000000] Booting paravirtualized kernel on bare hardware
[    0.000000] clocksource: refined-jiffies: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 7645519600211568 ns
[    0.000000] setup_percpu: NR_CPUS:512 nr_cpumask_bits:512 nr_cpu_ids:4 nr_node_ids:1
[    0.000000] PERCPU: Embedded 32 pages/cpu @ffff880206c00000 s92952 r8192 d29928 u524288
[    0.000000] pcpu-alloc: s92952 r8192 d29928 u524288 alloc=1*2097152
[    0.000000] pcpu-alloc: [0] 0 1 2 3 
[    0.000000] Built 1 zonelists in Node order, mobility grouping on.  Total pages: 1910575
[    0.000000] Policy zone: Normal
[    0.000000] Kernel command line: BOOT_IMAGE=/boot/vmlinuz-4.3.0-trunk-amd64 root=/dev/mapper/fuchs--vg-root ro quiet
[    0.000000] PID hash table entries: 4096 (order: 3, 32768 bytes)
[    0.000000] Calgary: detecting Calgary via BIOS EBDA area
[    0.000000] Calgary: Unable to locate Rio Grande table in EBDA - bailing!
[    0.000000] Memory: 7542112K/7763700K available (5474K kernel code, 1047K rwdata, 2772K rodata, 1284K init, 836K bss, 221588K reserved, 0K cma-reserved)
[    0.000000] Hierarchical RCU implementation.
[    0.000000] 	Build-time adjustment of leaf fanout to 64.
[    0.000000] 	RCU restricting CPUs from NR_CPUS=512 to nr_cpu_ids=4.
[    0.000000] RCU: Adjusting geometry for rcu_fanout_leaf=64, nr_cpu_ids=4
[    0.000000] NR_IRQS:33024 nr_irqs:456 16
[    0.000000] spurious 8259A interrupt: IRQ7.
[    0.000000] Console: colour VGA+ 80x25
[    0.000000] console [tty0] enabled
[    0.000000] clocksource: hpet: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 133484873504 ns
[    0.000000] hpet clockevent registered
[    0.000000] tsc: Fast TSC calibration using PIT
[    0.000000] tsc: Detected 1696.907 MHz processor
[    0.000057] Calibrating delay loop (skipped), value calculated using timer frequency.. 3393.81 BogoMIPS (lpj=6787628)
[    0.000064] pid_max: default: 32768 minimum: 301
[    0.000084] ACPI: Core revision 20150818
[    0.029177] ACPI: 3 ACPI AML tables successfully acquired and loaded
[    0.029254] Security Framework initialized
[    0.029260] Yama: disabled by default; enable with sysctl kernel.yama.*
[    0.029276] AppArmor: AppArmor disabled by boot time parameter
[    0.030479] Dentry cache hash table entries: 1048576 (order: 11, 8388608 bytes)
[    0.035684] Inode-cache hash table entries: 524288 (order: 10, 4194304 bytes)
[    0.037999] Mount-cache hash table entries: 16384 (order: 5, 131072 bytes)
[    0.038024] Mountpoint-cache hash table entries: 16384 (order: 5, 131072 bytes)
[    0.038594] Initializing cgroup subsys io
[    0.038613] Initializing cgroup subsys memory
[    0.038629] Initializing cgroup subsys devices
[    0.038635] Initializing cgroup subsys freezer
[    0.038642] Initializing cgroup subsys net_cls
[    0.038649] Initializing cgroup subsys perf_event
[    0.038656] Initializing cgroup subsys net_prio
[    0.038701] CPU: Physical Processor ID: 0
[    0.038705] CPU: Processor Core ID: 0
[    0.038708] mce: CPU supports 6 MCE banks
[    0.038727] Last level iTLB entries: 4KB 512, 2MB 8, 4MB 4
[    0.038729] Last level dTLB entries: 4KB 512, 2MB 8, 4MB 4, 1GB 0
[    0.039453] Freeing SMP alternatives memory: 20K (ffffffff81c48000 - ffffffff81c4d000)
[    0.059310] ftrace: allocating 23497 entries in 92 pages
[    0.263024] ..TIMER: vector=0x30 apic1=0 pin1=2 apic2=-1 pin2=-1
[    0.406928] smpboot: CPU0: AMD E2-1800 APU with Radeon(tm) HD Graphics (family: 0x14, model: 0x2, stepping: 0x0)
[    0.406977] Performance Events: AMD PMU driver.
[    0.406985] ... version:                0
[    0.406988] ... bit width:              48
[    0.406990] ... generic registers:      4
[    0.406993] ... value mask:             0000ffffffffffff
[    0.406995] ... max period:             00007fffffffffff
[    0.406997] ... fixed-purpose events:   0
[    0.407000] ... event mask:             000000000000000f
[    0.407991] NMI watchdog: enabled on all CPUs, permanently consumes one hw-PMU counter.
[    0.408223] x86: Booting SMP configuration:
[    0.408227] .... node  #0, CPUs:      #1
[    0.421285] x86: Booted up 1 node, 2 CPUs
[    0.421290] smpboot: Total of 2 processors activated (6787.62 BogoMIPS)
[    0.422067] devtmpfs: initialized
[    0.429223] PM: Registering ACPI NVS region [mem 0xded03000-0xdee32fff] (1245184 bytes)
[    0.429463] clocksource: jiffies: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 7645041785100000 ns
[    0.429763] pinctrl core: initialized pinctrl subsystem
[    0.433076] NET: Registered protocol family 16
[    0.443110] cpuidle: using governor ladder
[    0.455101] cpuidle: using governor menu
[    0.455390] ACPI: bus type PCI registered
[    0.455396] acpiphp: ACPI Hot Plug PCI Controller Driver version: 0.5
[    0.455645] PCI: MMCONFIG for domain 0000 [bus 00-3f] at [mem 0xf8000000-0xfbffffff] (base 0xf8000000)
[    0.455650] PCI: not using MMCONFIG
[    0.455653] PCI: Using configuration type 1 for base access
[    0.455655] PCI: Using configuration type 1 for extended access
[    0.456160] mtrr: your CPUs had inconsistent variable MTRR settings
[    0.456163] mtrr: probably your BIOS does not setup all CPUs.
[    0.456165] mtrr: corrected configuration.
[    0.468415] ACPI: Added _OSI(Module Device)
[    0.468422] ACPI: Added _OSI(Processor Device)
[    0.468425] ACPI: Added _OSI(3.0 _SCP Extensions)
[    0.468428] ACPI: Added _OSI(Processor Aggregator Device)
[    0.479888] [Firmware Bug]: ACPI: BIOS _OSI(Linux) query ignored
[    0.480835] ACPI : EC: EC started
[    0.484561] ACPI: Interpreter enabled
[    0.484583] ACPI Exception: AE_NOT_FOUND, While evaluating Sleep State [\_S1_] (20150818/hwxface-580)
[    0.484593] ACPI Exception: AE_NOT_FOUND, While evaluating Sleep State [\_S2_] (20150818/hwxface-580)
[    0.484623] ACPI: (supports S0 S3 S4 S5)
[    0.484627] ACPI: Using IOAPIC for interrupt routing
[    0.484906] PCI: MMCONFIG for domain 0000 [bus 00-3f] at [mem 0xf8000000-0xfbffffff] (base 0xf8000000)
[    0.485472] PCI: MMCONFIG at [mem 0xf8000000-0xfbffffff] reserved in ACPI motherboard resources
[    0.485492] PCI: Using host bridge windows from ACPI; if necessary, use "pci=nocrs" and report a bug
[    0.486442] [Firmware Bug]: ACPI: No _BQC method, cannot determine initial brightness
[    0.495435] [Firmware Bug]: ACPI: No _BQC method, cannot determine initial brightness
[    0.501042] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-ff])
[    0.501060] acpi PNP0A08:00: _OSC: OS supports [ExtendedConfig ASPM ClockPM Segments MSI]
[    0.501444] acpi PNP0A08:00: _OSC: platform does not support [PME]
[    0.501802] acpi PNP0A08:00: _OSC: OS now controls [PCIeHotplug AER PCIeCapability]
[    0.502687] acpi PNP0A08:00: ignoring host bridge window [mem 0x000ce000-0x000cffff window] (conflicts with Video ROM [mem 0x000c0000-0x000cedff])
[    0.502697] acpi PNP0A08:00: [Firmware Info]: MMCONFIG for domain 0000 [bus 00-3f] only partially covers this bridge
[    0.503110] PCI host bridge to bus 0000:00
[    0.503117] pci_bus 0000:00: root bus resource [bus 00-ff]
[    0.503122] pci_bus 0000:00: root bus resource [mem 0x000a0000-0x000bffff window]
[    0.503126] pci_bus 0000:00: root bus resource [mem 0x000c0000-0x000c1fff window]
[    0.503131] pci_bus 0000:00: root bus resource [mem 0x000c2000-0x000c3fff window]
[    0.503135] pci_bus 0000:00: root bus resource [mem 0x000c4000-0x000c5fff window]
[    0.503139] pci_bus 0000:00: root bus resource [mem 0x000c6000-0x000c7fff window]
[    0.503143] pci_bus 0000:00: root bus resource [mem 0x000c8000-0x000c9fff window]
[    0.503147] pci_bus 0000:00: root bus resource [mem 0x000ca000-0x000cbfff window]
[    0.503151] pci_bus 0000:00: root bus resource [mem 0x000cc000-0x000cdfff window]
[    0.503155] pci_bus 0000:00: root bus resource [mem 0x000d0000-0x000d1fff window]
[    0.503159] pci_bus 0000:00: root bus resource [mem 0x000d2000-0x000d3fff window]
[    0.503163] pci_bus 0000:00: root bus resource [mem 0x000d4000-0x000d5fff window]
[    0.503167] pci_bus 0000:00: root bus resource [mem 0x000d6000-0x000d7fff window]
[    0.503171] pci_bus 0000:00: root bus resource [mem 0x000d8000-0x000d9fff window]
[    0.503175] pci_bus 0000:00: root bus resource [mem 0x000da000-0x000dbfff window]
[    0.503179] pci_bus 0000:00: root bus resource [mem 0x000dc000-0x000ddfff window]
[    0.503183] pci_bus 0000:00: root bus resource [mem 0x000de000-0x000dffff window]
[    0.503187] pci_bus 0000:00: root bus resource [mem 0x000e0000-0x000e1fff window]
[    0.503190] pci_bus 0000:00: root bus resource [mem 0x000e2000-0x000e3fff window]
[    0.503194] pci_bus 0000:00: root bus resource [mem 0x000e4000-0x000e5fff window]
[    0.503198] pci_bus 0000:00: root bus resource [mem 0x000e6000-0x000e7fff window]
[    0.503202] pci_bus 0000:00: root bus resource [mem 0x000e8000-0x000e9fff window]
[    0.503206] pci_bus 0000:00: root bus resource [mem 0x000ea000-0x000ebfff window]
[    0.503210] pci_bus 0000:00: root bus resource [mem 0x000ec000-0x000edfff window]
[    0.503214] pci_bus 0000:00: root bus resource [mem 0x000ee000-0x000effff window]
[    0.503218] pci_bus 0000:00: root bus resource [mem 0xe0000000-0xf7ffffff window]
[    0.503222] pci_bus 0000:00: root bus resource [mem 0xfc000000-0xfdffffff window]
[    0.503226] pci_bus 0000:00: root bus resource [mem 0xfed40000-0xfed44fff window]
[    0.503230] pci_bus 0000:00: root bus resource [io  0x0000-0x0cf7 window]
[    0.503234] pci_bus 0000:00: root bus resource [io  0x0d00-0xffff window]
[    0.503250] pci 0000:00:00.0: [1022:1510] type 00 class 0x060000
[    0.503436] pci 0000:00:01.0: [1002:9808] type 00 class 0x030000
[    0.503464] pci 0000:00:01.0: reg 0x10: [mem 0xe0000000-0xefffffff pref]
[    0.503475] pci 0000:00:01.0: reg 0x14: [io  0x3000-0x30ff]
[    0.503485] pci 0000:00:01.0: reg 0x18: [mem 0xf0b00000-0xf0b3ffff]
[    0.503536] pci 0000:00:01.0: supports D1 D2
[    0.503684] pci 0000:00:01.1: [1002:1314] type 00 class 0x040300
[    0.503709] pci 0000:00:01.1: reg 0x10: [mem 0xf0b44000-0xf0b47fff]
[    0.503769] pci 0000:00:01.1: supports D1 D2
[    0.503912] pci 0000:00:05.0: [1022:1513] type 01 class 0x060400
[    0.503981] pci 0000:00:05.0: PME# supported from D0 D3hot D3cold
[    0.504068] pci 0000:00:05.0: System wakeup disabled by ACPI
[    0.504156] pci 0000:00:06.0: [1022:1514] type 01 class 0x060400
[    0.504225] pci 0000:00:06.0: PME# supported from D0 D3hot D3cold
[    0.504308] pci 0000:00:06.0: System wakeup disabled by ACPI
[    0.504389] pci 0000:00:07.0: [1022:1515] type 01 class 0x060400
[    0.504456] pci 0000:00:07.0: PME# supported from D0 D3hot D3cold
[    0.504539] pci 0000:00:07.0: System wakeup disabled by ACPI
[    0.504654] pci 0000:00:10.0: [1022:7812] type 00 class 0x0c0330
[    0.504703] pci 0000:00:10.0: reg 0x10: [mem 0xf0b48000-0xf0b49fff 64bit]
[    0.504797] pci 0000:00:10.0: PME# supported from D0 D3hot D3cold
[    0.504913] pci 0000:00:10.0: System wakeup disabled by ACPI
[    0.505018] pci 0000:00:11.0: [1022:7801] type 00 class 0x010601
[    0.505052] pci 0000:00:11.0: reg 0x10: [io  0x3118-0x311f]
[    0.505065] pci 0000:00:11.0: reg 0x14: [io  0x3124-0x3127]
[    0.505078] pci 0000:00:11.0: reg 0x18: [io  0x3110-0x3117]
[    0.505091] pci 0000:00:11.0: reg 0x1c: [io  0x3120-0x3123]
[    0.505104] pci 0000:00:11.0: reg 0x20: [io  0x3100-0x310f]
[    0.505117] pci 0000:00:11.0: reg 0x24: [mem 0xf0b4d000-0xf0b4d7ff]
[    0.505306] pci 0000:00:12.0: [1022:7807] type 00 class 0x0c0310
[    0.505328] pci 0000:00:12.0: reg 0x10: [mem 0xf0b4c000-0xf0b4cfff]
[    0.505491] pci 0000:00:12.0: System wakeup disabled by ACPI
[    0.505591] pci 0000:00:12.2: [1022:7808] type 00 class 0x0c0320
[    0.505623] pci 0000:00:12.2: reg 0x10: [mem 0xf0b4d900-0xf0b4d9ff]
[    0.505705] pci 0000:00:12.2: supports D1 D2
[    0.505709] pci 0000:00:12.2: PME# supported from D0 D1 D2 D3hot
[    0.505868] pci 0000:00:13.0: [1022:7807] type 00 class 0x0c0310
[    0.505889] pci 0000:00:13.0: reg 0x10: [mem 0xf0b4b000-0xf0b4bfff]
[    0.506052] pci 0000:00:13.0: System wakeup disabled by ACPI
[    0.506149] pci 0000:00:13.2: [1022:7808] type 00 class 0x0c0320
[    0.506181] pci 0000:00:13.2: reg 0x10: [mem 0xf0b4d800-0xf0b4d8ff]
[    0.506263] pci 0000:00:13.2: supports D1 D2
[    0.506267] pci 0000:00:13.2: PME# supported from D0 D1 D2 D3hot
[    0.506370] pci 0000:00:13.2: System wakeup disabled by ACPI
[    0.506471] pci 0000:00:14.0: [1022:780b] type 00 class 0x0c0500
[    0.506708] pci 0000:00:14.2: [1022:780d] type 00 class 0x040300
[    0.506743] pci 0000:00:14.2: reg 0x10: [mem 0xf0b40000-0xf0b43fff 64bit]
[    0.506814] pci 0000:00:14.2: PME# supported from D0 D3hot D3cold
[    0.506914] pci 0000:00:14.2: System wakeup disabled by ACPI
[    0.507006] pci 0000:00:14.3: [1022:780e] type 00 class 0x060100
[    0.507240] pci 0000:00:14.4: [1022:780f] type 01 class 0x060401
[    0.507360] pci 0000:00:14.4: System wakeup disabled by ACPI
[    0.507456] pci 0000:00:14.5: [1022:7809] type 00 class 0x0c0310
[    0.507478] pci 0000:00:14.5: reg 0x10: [mem 0xf0b4a000-0xf0b4afff]
[    0.507644] pci 0000:00:14.5: System wakeup disabled by ACPI
[    0.507743] pci 0000:00:18.0: [1022:1700] type 00 class 0x060000
[    0.507912] pci 0000:00:18.1: [1022:1701] type 00 class 0x060000
[    0.508073] pci 0000:00:18.2: [1022:1702] type 00 class 0x060000
[    0.508236] pci 0000:00:18.3: [1022:1703] type 00 class 0x060000
[    0.508406] pci 0000:00:18.4: [1022:1704] type 00 class 0x060000
[    0.508567] pci 0000:00:18.5: [1022:1718] type 00 class 0x060000
[    0.508728] pci 0000:00:18.6: [1022:1716] type 00 class 0x060000
[    0.508889] pci 0000:00:18.7: [1022:1719] type 00 class 0x060000
[    0.509236] pci 0000:02:00.0: [14e4:4359] type 00 class 0x028000
[    0.509285] pci 0000:02:00.0: reg 0x10: [mem 0xf0a00000-0xf0a03fff 64bit]
[    0.509396] pci 0000:02:00.0: supports D1 D2
[    0.509400] pci 0000:02:00.0: PME# supported from D0 D3hot D3cold
[    0.515129] pci 0000:00:05.0: PCI bridge to [bus 02]
[    0.515151] pci 0000:00:05.0:   bridge window [mem 0xf0a00000-0xf0afffff]
[    0.515337] pci 0000:03:00.0: [10ec:8168] type 00 class 0x020000
[    0.515384] pci 0000:03:00.0: reg 0x10: [io  0x2000-0x20ff]
[    0.515415] pci 0000:03:00.0: reg 0x18: [mem 0xf0004000-0xf0004fff 64bit pref]
[    0.515435] pci 0000:03:00.0: reg 0x20: [mem 0xf0000000-0xf0003fff 64bit pref]
[    0.515513] pci 0000:03:00.0: supports D1 D2
[    0.515517] pci 0000:03:00.0: PME# supported from D0 D1 D2 D3hot D3cold
[    0.523083] pci 0000:00:06.0: PCI bridge to [bus 03]
[    0.523109] pci 0000:00:06.0:   bridge window [io  0x2000-0x2fff]
[    0.523121] pci 0000:00:06.0:   bridge window [mem 0xf0200000-0xf09fffff]
[    0.523133] pci 0000:00:06.0:   bridge window [mem 0xf0000000-0xf00fffff 64bit pref]
[    0.523326] pci 0000:04:00.0: [10ec:5209] type 00 class 0xff0000
[    0.523370] pci 0000:04:00.0: reg 0x10: [mem 0xf0100000-0xf0100fff]
[    0.523438] pci 0000:04:00.0: reg 0x30: [mem 0xffff0000-0xffffffff pref]
[    0.523496] pci 0000:04:00.0: supports D1 D2
[    0.523500] pci 0000:04:00.0: PME# supported from D1 D2 D3hot
[    0.531077] pci 0000:00:07.0: PCI bridge to [bus 04]
[    0.531105] pci 0000:00:07.0:   bridge window [mem 0xf0100000-0xf01fffff]
[    0.531311] pci 0000:00:14.4: PCI bridge to [bus 05] (subtractive decode)
[    0.531325] pci 0000:00:14.4:   bridge window [mem 0x000a0000-0x000bffff window] (subtractive decode)
[    0.531330] pci 0000:00:14.4:   bridge window [mem 0x000c0000-0x000c1fff window] (subtractive decode)
[    0.531335] pci 0000:00:14.4:   bridge window [mem 0x000c2000-0x000c3fff window] (subtractive decode)
[    0.531339] pci 0000:00:14.4:   bridge window [mem 0x000c4000-0x000c5fff window] (subtractive decode)
[    0.531344] pci 0000:00:14.4:   bridge window [mem 0x000c6000-0x000c7fff window] (subtractive decode)
[    0.531348] pci 0000:00:14.4:   bridge window [mem 0x000c8000-0x000c9fff window] (subtractive decode)
[    0.531352] pci 0000:00:14.4:   bridge window [mem 0x000ca000-0x000cbfff window] (subtractive decode)
[    0.531357] pci 0000:00:14.4:   bridge window [mem 0x000cc000-0x000cdfff window] (subtractive decode)
[    0.531361] pci 0000:00:14.4:   bridge window [mem 0x000d0000-0x000d1fff window] (subtractive decode)
[    0.531365] pci 0000:00:14.4:   bridge window [mem 0x000d2000-0x000d3fff window] (subtractive decode)
[    0.531369] pci 0000:00:14.4:   bridge window [mem 0x000d4000-0x000d5fff window] (subtractive decode)
[    0.531373] pci 0000:00:14.4:   bridge window [mem 0x000d6000-0x000d7fff window] (subtractive decode)
[    0.531378] pci 0000:00:14.4:   bridge window [mem 0x000d8000-0x000d9fff window] (subtractive decode)
[    0.531382] pci 0000:00:14.4:   bridge window [mem 0x000da000-0x000dbfff window] (subtractive decode)
[    0.531386] pci 0000:00:14.4:   bridge window [mem 0x000dc000-0x000ddfff window] (subtractive decode)
[    0.531390] pci 0000:00:14.4:   bridge window [mem 0x000de000-0x000dffff window] (subtractive decode)
[    0.531394] pci 0000:00:14.4:   bridge window [mem 0x000e0000-0x000e1fff window] (subtractive decode)
[    0.531399] pci 0000:00:14.4:   bridge window [mem 0x000e2000-0x000e3fff window] (subtractive decode)
[    0.531403] pci 0000:00:14.4:   bridge window [mem 0x000e4000-0x000e5fff window] (subtractive decode)
[    0.531407] pci 0000:00:14.4:   bridge window [mem 0x000e6000-0x000e7fff window] (subtractive decode)
[    0.531411] pci 0000:00:14.4:   bridge window [mem 0x000e8000-0x000e9fff window] (subtractive decode)
[    0.531415] pci 0000:00:14.4:   bridge window [mem 0x000ea000-0x000ebfff window] (subtractive decode)
[    0.531420] pci 0000:00:14.4:   bridge window [mem 0x000ec000-0x000edfff window] (subtractive decode)
[    0.531424] pci 0000:00:14.4:   bridge window [mem 0x000ee000-0x000effff window] (subtractive decode)
[    0.531429] pci 0000:00:14.4:   bridge window [mem 0xe0000000-0xf7ffffff window] (subtractive decode)
[    0.531433] pci 0000:00:14.4:   bridge window [mem 0xfc000000-0xfdffffff window] (subtractive decode)
[    0.531438] pci 0000:00:14.4:   bridge window [mem 0xfed40000-0xfed44fff window] (subtractive decode)
[    0.531442] pci 0000:00:14.4:   bridge window [io  0x0000-0x0cf7 window] (subtractive decode)
[    0.531449] pci 0000:00:14.4:   bridge window [io  0x0d00-0xffff window] (subtractive decode)
[    0.532170] ACPI: PCI Interrupt Link [LNKA] (IRQs 10 11) *0
[    0.532326] ACPI: PCI Interrupt Link [LNKB] (IRQs 10 11) *0
[    0.532474] ACPI: PCI Interrupt Link [LNKC] (IRQs 10 11) *0
[    0.532619] ACPI: PCI Interrupt Link [LNKD] (IRQs 10 11) *0
[    0.532745] ACPI: PCI Interrupt Link [LNKE] (IRQs 10 11) *0
[    0.532850] ACPI: PCI Interrupt Link [LNKF] (IRQs 10 11) *0
[    0.532955] ACPI: PCI Interrupt Link [LNKG] (IRQs 10 11) *0
[    0.533061] ACPI: PCI Interrupt Link [LNKH] (IRQs 10 11) *0
[    0.533342] ACPI: IRQ 7 override to edge, high
[    0.535360] ACPI: Enabled 1 GPEs in block 00 to 1F
[    0.535527] ACPI : EC: GPE = 0x3, I/O: command/status = 0x66, data = 0x62
[    0.535869] vgaarb: setting as boot device: PCI:0000:00:01.0
[    0.535878] vgaarb: device added: PCI:0000:00:01.0,decodes=io+mem,owns=io+mem,locks=none
[    0.535890] vgaarb: loaded
[    0.535893] vgaarb: bridge control possible 0000:00:01.0
[    0.536268] PCI: Using ACPI for IRQ routing
[    0.538524] PCI: pci_cache_line_size set to 64 bytes
[    0.538698] e820: reserve RAM buffer [mem 0x0009e800-0x0009ffff]
[    0.538703] e820: reserve RAM buffer [mem 0xd2e20000-0xd3ffffff]
[    0.538706] e820: reserve RAM buffer [mem 0x207000000-0x207ffffff]
[    0.539048] hpet0: at MMIO 0xfed00000, IRQs 2, 8, 0
[    0.539056] hpet0: 3 comparators, 32-bit 14.318180 MHz counter
[    0.541108] clocksource: Switched to clocksource hpet
[    0.554317] pnp: PnP ACPI init
[    0.554614] system 00:00: [io  0x0f50-0x0f51] has been reserved
[    0.554621] system 00:00: [mem 0xfec00000-0xfec00fff] could not be reserved
[    0.554626] system 00:00: [mem 0xfee00000-0xfee00fff] has been reserved
[    0.554631] system 00:00: [mem 0xf8000000-0xfbffffff] has been reserved
[    0.554640] system 00:00: Plug and Play ACPI device, IDs PNP0c02 (active)
[    0.555351] pnp 00:01: Plug and Play ACPI device, IDs PNP0b00 (active)
[    0.555415] pnp 00:02: Plug and Play ACPI device, IDs MSF0001 PNP0303 (active)
[    0.555522] pnp 00:03: Plug and Play ACPI device, IDs LEN0052 PNP0f13 (active)
[    0.555642] system 00:04: [io  0x04d0-0x04d1] has been reserved
[    0.555647] system 00:04: [io  0x0530-0x0537] has been reserved
[    0.555652] system 00:04: [io  0x0800-0x0827] could not be reserved
[    0.555657] system 00:04: [io  0x0830] has been reserved
[    0.555662] system 00:04: [io  0x0840-0x0847] has been reserved
[    0.555666] system 00:04: [io  0x0b00-0x0b1f] has been reserved
[    0.555671] system 00:04: [io  0x0c00-0x0c01] has been reserved
[    0.555676] system 00:04: [io  0x0c14] has been reserved
[    0.555680] system 00:04: [io  0x0c50-0x0c52] has been reserved
[    0.555687] system 00:04: [io  0x0cd0-0x0cd1] has been reserved
[    0.555691] system 00:04: [io  0x0cd2-0x0cd3] has been reserved
[    0.555696] system 00:04: [io  0x0cd4-0x0cd5] has been reserved
[    0.555700] system 00:04: [io  0x0cd6-0x0cd7] has been reserved
[    0.555705] system 00:04: [io  0x0cd8-0x0cdf] has been reserved
[    0.555709] system 00:04: [io  0x0cf9] could not be reserved
[    0.555714] system 00:04: [io  0x8100-0x81ff window] has been reserved
[    0.555718] system 00:04: [io  0x8200-0x82ff window] has been reserved
[    0.555724] system 00:04: Plug and Play ACPI device, IDs PNP0c02 (active)
[    0.555904] system 00:05: [mem 0x000e0000-0x000fffff] could not be reserved
[    0.555910] system 00:05: [mem 0xffe00000-0xffffffff] has been reserved
[    0.555914] system 00:05: [mem 0xfec10000-0xfec1001f] has been reserved
[    0.555919] system 00:05: [mem 0xfed00000-0xfed003ff] has been reserved
[    0.555923] system 00:05: [mem 0xfed61000-0xfed613ff] has been reserved
[    0.555928] system 00:05: [mem 0xfed80000-0xfed80fff] has been reserved
[    0.555934] system 00:05: Plug and Play ACPI device, IDs PNP0c01 (active)
[    0.557291] pnp: PnP ACPI: found 6 devices
[    0.567478] clocksource: acpi_pm: mask: 0xffffff max_cycles: 0xffffff, max_idle_ns: 2085701024 ns
[    0.567499] pci 0000:04:00.0: can't claim BAR 6 [mem 0xffff0000-0xffffffff pref]: no compatible bridge window
[    0.567538] pci 0000:00:07.0: bridge window [io  0x1000-0x0fff] to [bus 04] add_size 1000
[    0.567545] pci 0000:00:07.0: bridge window [mem 0x00100000-0x000fffff 64bit pref] to [bus 04] add_size 200000 add_align 100000
[    0.567578] pci 0000:00:07.0: res[15]=[mem 0x00100000-0x000fffff 64bit pref] res_to_dev_res add_size 200000 min_align 100000
[    0.567583] pci 0000:00:07.0: res[15]=[mem 0x00100000-0x002fffff 64bit pref] res_to_dev_res add_size 200000 min_align 100000
[    0.567588] pci 0000:00:07.0: res[13]=[io  0x1000-0x0fff] res_to_dev_res add_size 1000 min_align 1000
[    0.567593] pci 0000:00:07.0: res[13]=[io  0x1000-0x1fff] res_to_dev_res add_size 1000 min_align 1000
[    0.567639] pci 0000:00:07.0: BAR 15: assigned [mem 0xf0c00000-0xf0dfffff 64bit pref]
[    0.567649] pci 0000:00:07.0: BAR 13: assigned [io  0x1000-0x1fff]
[    0.567655] pci 0000:00:05.0: PCI bridge to [bus 02]
[    0.567663] pci 0000:00:05.0:   bridge window [mem 0xf0a00000-0xf0afffff]
[    0.567673] pci 0000:00:06.0: PCI bridge to [bus 03]
[    0.567678] pci 0000:00:06.0:   bridge window [io  0x2000-0x2fff]
[    0.567684] pci 0000:00:06.0:   bridge window [mem 0xf0200000-0xf09fffff]
[    0.567690] pci 0000:00:06.0:   bridge window [mem 0xf0000000-0xf00fffff 64bit pref]
[    0.567699] pci 0000:04:00.0: BAR 6: assigned [mem 0xf0110000-0xf011ffff pref]
[    0.567703] pci 0000:00:07.0: PCI bridge to [bus 04]
[    0.567708] pci 0000:00:07.0:   bridge window [io  0x1000-0x1fff]
[    0.567714] pci 0000:00:07.0:   bridge window [mem 0xf0100000-0xf01fffff]
[    0.567720] pci 0000:00:07.0:   bridge window [mem 0xf0c00000-0xf0dfffff 64bit pref]
[    0.567727] pci 0000:00:14.4: PCI bridge to [bus 05]
[    0.567758] pci_bus 0000:00: resource 4 [mem 0x000a0000-0x000bffff window]
[    0.567762] pci_bus 0000:00: resource 5 [mem 0x000c0000-0x000c1fff window]
[    0.567766] pci_bus 0000:00: resource 6 [mem 0x000c2000-0x000c3fff window]
[    0.567770] pci_bus 0000:00: resource 7 [mem 0x000c4000-0x000c5fff window]
[    0.567774] pci_bus 0000:00: resource 8 [mem 0x000c6000-0x000c7fff window]
[    0.567777] pci_bus 0000:00: resource 9 [mem 0x000c8000-0x000c9fff window]
[    0.567781] pci_bus 0000:00: resource 10 [mem 0x000ca000-0x000cbfff window]
[    0.567785] pci_bus 0000:00: resource 11 [mem 0x000cc000-0x000cdfff window]
[    0.567788] pci_bus 0000:00: resource 12 [mem 0x000d0000-0x000d1fff window]
[    0.567792] pci_bus 0000:00: resource 13 [mem 0x000d2000-0x000d3fff window]
[    0.567796] pci_bus 0000:00: resource 14 [mem 0x000d4000-0x000d5fff window]
[    0.567799] pci_bus 0000:00: resource 15 [mem 0x000d6000-0x000d7fff window]
[    0.567803] pci_bus 0000:00: resource 16 [mem 0x000d8000-0x000d9fff window]
[    0.567807] pci_bus 0000:00: resource 17 [mem 0x000da000-0x000dbfff window]
[    0.567810] pci_bus 0000:00: resource 18 [mem 0x000dc000-0x000ddfff window]
[    0.567814] pci_bus 0000:00: resource 19 [mem 0x000de000-0x000dffff window]
[    0.567818] pci_bus 0000:00: resource 20 [mem 0x000e0000-0x000e1fff window]
[    0.567821] pci_bus 0000:00: resource 21 [mem 0x000e2000-0x000e3fff window]
[    0.567825] pci_bus 0000:00: resource 22 [mem 0x000e4000-0x000e5fff window]
[    0.567829] pci_bus 0000:00: resource 23 [mem 0x000e6000-0x000e7fff window]
[    0.567832] pci_bus 0000:00: resource 24 [mem 0x000e8000-0x000e9fff window]
[    0.567836] pci_bus 0000:00: resource 25 [mem 0x000ea000-0x000ebfff window]
[    0.567840] pci_bus 0000:00: resource 26 [mem 0x000ec000-0x000edfff window]
[    0.567843] pci_bus 0000:00: resource 27 [mem 0x000ee000-0x000effff window]
[    0.567847] pci_bus 0000:00: resource 28 [mem 0xe0000000-0xf7ffffff window]
[    0.567851] pci_bus 0000:00: resource 29 [mem 0xfc000000-0xfdffffff window]
[    0.567855] pci_bus 0000:00: resource 30 [mem 0xfed40000-0xfed44fff window]
[    0.567858] pci_bus 0000:00: resource 31 [io  0x0000-0x0cf7 window]
[    0.567862] pci_bus 0000:00: resource 32 [io  0x0d00-0xffff window]
[    0.567867] pci_bus 0000:02: resource 1 [mem 0xf0a00000-0xf0afffff]
[    0.567870] pci_bus 0000:03: resource 0 [io  0x2000-0x2fff]
[    0.567874] pci_bus 0000:03: resource 1 [mem 0xf0200000-0xf09fffff]
[    0.567878] pci_bus 0000:03: resource 2 [mem 0xf0000000-0xf00fffff 64bit pref]
[    0.567882] pci_bus 0000:04: resource 0 [io  0x1000-0x1fff]
[    0.567885] pci_bus 0000:04: resource 1 [mem 0xf0100000-0xf01fffff]
[    0.567889] pci_bus 0000:04: resource 2 [mem 0xf0c00000-0xf0dfffff 64bit pref]
[    0.567893] pci_bus 0000:05: resource 4 [mem 0x000a0000-0x000bffff window]
[    0.567897] pci_bus 0000:05: resource 5 [mem 0x000c0000-0x000c1fff window]
[    0.567901] pci_bus 0000:05: resource 6 [mem 0x000c2000-0x000c3fff window]
[    0.567904] pci_bus 0000:05: resource 7 [mem 0x000c4000-0x000c5fff window]
[    0.567908] pci_bus 0000:05: resource 8 [mem 0x000c6000-0x000c7fff window]
[    0.567912] pci_bus 0000:05: resource 9 [mem 0x000c8000-0x000c9fff window]
[    0.567915] pci_bus 0000:05: resource 10 [mem 0x000ca000-0x000cbfff window]
[    0.567919] pci_bus 0000:05: resource 11 [mem 0x000cc000-0x000cdfff window]
[    0.567923] pci_bus 0000:05: resource 12 [mem 0x000d0000-0x000d1fff window]
[    0.567926] pci_bus 0000:05: resource 13 [mem 0x000d2000-0x000d3fff window]
[    0.567930] pci_bus 0000:05: resource 14 [mem 0x000d4000-0x000d5fff window]
[    0.567933] pci_bus 0000:05: resource 15 [mem 0x000d6000-0x000d7fff window]
[    0.567937] pci_bus 0000:05: resource 16 [mem 0x000d8000-0x000d9fff window]
[    0.567941] pci_bus 0000:05: resource 17 [mem 0x000da000-0x000dbfff window]
[    0.567944] pci_bus 0000:05: resource 18 [mem 0x000dc000-0x000ddfff window]
[    0.567948] pci_bus 0000:05: resource 19 [mem 0x000de000-0x000dffff window]
[    0.567952] pci_bus 0000:05: resource 20 [mem 0x000e0000-0x000e1fff window]
[    0.567955] pci_bus 0000:05: resource 21 [mem 0x000e2000-0x000e3fff window]
[    0.567959] pci_bus 0000:05: resource 22 [mem 0x000e4000-0x000e5fff window]
[    0.567963] pci_bus 0000:05: resource 23 [mem 0x000e6000-0x000e7fff window]
[    0.567966] pci_bus 0000:05: resource 24 [mem 0x000e8000-0x000e9fff window]
[    0.567970] pci_bus 0000:05: resource 25 [mem 0x000ea000-0x000ebfff window]
[    0.567974] pci_bus 0000:05: resource 26 [mem 0x000ec000-0x000edfff window]
[    0.567977] pci_bus 0000:05: resource 27 [mem 0x000ee000-0x000effff window]
[    0.567981] pci_bus 0000:05: resource 28 [mem 0xe0000000-0xf7ffffff window]
[    0.567985] pci_bus 0000:05: resource 29 [mem 0xfc000000-0xfdffffff window]
[    0.567989] pci_bus 0000:05: resource 30 [mem 0xfed40000-0xfed44fff window]
[    0.567993] pci_bus 0000:05: resource 31 [io  0x0000-0x0cf7 window]
[    0.567996] pci_bus 0000:05: resource 32 [io  0x0d00-0xffff window]
[    0.568123] NET: Registered protocol family 2
[    0.568536] TCP established hash table entries: 65536 (order: 7, 524288 bytes)
[    0.568927] TCP bind hash table entries: 65536 (order: 8, 1048576 bytes)
[    0.569500] TCP: Hash tables configured (established 65536 bind 65536)
[    0.569621] UDP hash table entries: 4096 (order: 5, 131072 bytes)
[    0.569709] UDP-Lite hash table entries: 4096 (order: 5, 131072 bytes)
[    0.570063] NET: Registered protocol family 1
[    0.570105] pci 0000:00:01.0: Video device with shadowed ROM
[    0.713405] PCI: CLS 32 bytes, default 64
[    0.713540] Unpacking initramfs...
[    1.336422] Freeing initrd memory: 18324K (ffff880035c26000 - ffff880036e0b000)
[    1.336471] PCI-DMA: Using software bounce buffering for IO (SWIOTLB)
[    1.336477] software IO TLB [mem 0xcee20000-0xd2e20000] (64MB) mapped at [ffff8800cee20000-ffff8800d2e1ffff]
[    1.336785] microcode: CPU0: patch_level=0x0500010d
[    1.336800] microcode: CPU1: patch_level=0x0500010d
[    1.337058] microcode: Microcode Update Driver: v2.00 <tigran@aivazian.fsnet.co.uk>, Peter Oruba
[    1.337076] LVT offset 0 assigned for vector 0x400
[    1.337150] perf: AMD IBS detected (0x000000ff)
[    1.338031] futex hash table entries: 1024 (order: 4, 65536 bytes)
[    1.338112] audit: initializing netlink subsys (disabled)
[    1.338160] audit: type=2000 audit(1449954598.028:1): initialized
[    1.338956] HugeTLB registered 2 MB page size, pre-allocated 0 pages
[    1.339011] zbud: loaded
[    1.339500] VFS: Disk quotas dquot_6.6.0
[    1.339567] VFS: Dquot-cache hash table entries: 512 (order 0, 4096 bytes)
[    1.340985] Block layer SCSI generic (bsg) driver version 0.4 loaded (major 250)
[    1.341078] io scheduler noop registered
[    1.341088] io scheduler deadline registered
[    1.341141] io scheduler cfq registered (default)
[    1.342732] pci_hotplug: PCI Hot Plug PCI Core version: 0.5
[    1.342758] pciehp 0000:00:07.0:pcie04: Slot #7 AttnBtn- PwrCtrl- MRL- AttnInd- PwrInd- HotPlug+ Surprise- Interlock- NoCompl+ LLActRep+
[    1.342845] pciehp 0000:00:07.0:pcie04: service driver pciehp loaded
[    1.342857] pciehp: PCI Express Hot Plug Controller Driver version: 0.4
[    1.342964] GHES: HEST is not enabled!
[    1.343252] Serial: 8250/16550 driver, 4 ports, IRQ sharing enabled
[    1.344301] Linux agpgart interface v0.103
[    1.344436] AMD IOMMUv2 driver by Joerg Roedel <jroedel@suse.de>
[    1.344439] AMD IOMMUv2 functionality not available on this system
[    1.345120] i8042: PNP: PS/2 Controller [PNP0303:KBC0,PNP0f13:MSE0] at 0x60,0x64 irq 1,12
[    1.352539] i8042: Detected active multiplexing controller, rev 1.1
[    1.353610] serio: i8042 KBD port at 0x60,0x64 irq 1
[    1.353624] serio: i8042 AUX0 port at 0x60,0x64 irq 12
[    1.353695] serio: i8042 AUX1 port at 0x60,0x64 irq 12
[    1.353755] serio: i8042 AUX2 port at 0x60,0x64 irq 12
[    1.353814] serio: i8042 AUX3 port at 0x60,0x64 irq 12
[    1.354411] mousedev: PS/2 mouse device common for all mice
[    1.354583] rtc_cmos 00:01: RTC can wake from S4
[    1.354837] rtc_cmos 00:01: rtc core: registered rtc_cmos as rtc0
[    1.354901] rtc_cmos 00:01: alarms up to one month, 114 bytes nvram, hpet irqs
[    1.354949] ledtrig-cpu: registered to indicate activity on CPUs
[    1.355789] NET: Registered protocol family 10
[    1.356231] mip6: Mobile IPv6
[    1.356240] NET: Registered protocol family 17
[    1.356270] mpls_gso: MPLS GSO support
[    1.356974] registered taskstats version 1
[    1.357035] zswap: loaded using pool lzo/zbud
[    1.357828] rtc_cmos 00:01: setting system clock to 2015-12-12 21:09:59 UTC (1449954599)
[    1.357965] PM: Hibernation image not present or could not be loaded.
[    1.358875] Freeing unused kernel memory: 1284K (ffffffff81b07000 - ffffffff81c48000)
[    1.358883] Write protecting the kernel read-only data: 10240k
[    1.359631] Freeing unused kernel memory: 660K (ffff88000155b000 - ffff880001600000)
[    1.360618] Freeing unused kernel memory: 1324K (ffff8800018b5000 - ffff880001a00000)
[    1.395667] input: AT Translated Set 2 keyboard as /devices/platform/i8042/serio0/input/input0
[    1.503110] systemd-udevd[68]: starting version 215
[    1.503995] random: systemd-udevd urandom read with 2 bits of entropy available
[    1.534028] ACPI: bus type USB registered
[    1.534087] usbcore: registered new interface driver usbfs
[    1.534110] usbcore: registered new interface driver hub
[    1.536536] usbcore: registered new device driver usb
[    1.538893] QUIRK: Enable AMD PLL fix
[    1.538947] xhci_hcd 0000:00:10.0: xHCI Host Controller
[    1.538961] xhci_hcd 0000:00:10.0: new USB bus registered, assigned bus number 1
[    1.539170] xhci_hcd 0000:00:10.0: hcc params 0x014042c3 hci version 0x96 quirks 0x00000608
[    1.542049] r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
[    1.542814] r8169 0000:03:00.0 eth0: RTL8168evl/8111evl at 0xffffc90000e68000, 08:9e:01:35:12:25, XID 0c900800 IRQ 28
[    1.542820] r8169 0000:03:00.0 eth0: jumbo features [frames: 9200 bytes, tx checksumming: ko]
[    1.542923] usb usb1: New USB device found, idVendor=1d6b, idProduct=0002
[    1.542929] usb usb1: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    1.542933] usb usb1: Product: xHCI Host Controller
[    1.542937] usb usb1: Manufacturer: Linux 4.3.0-trunk-amd64 xhci-hcd
[    1.542940] usb usb1: SerialNumber: 0000:00:10.0
[    1.543500] hub 1-0:1.0: USB hub found
[    1.543534] hub 1-0:1.0: 2 ports detected
[    1.543767] xhci_hcd 0000:00:10.0: xHCI Host Controller
[    1.543778] xhci_hcd 0000:00:10.0: new USB bus registered, assigned bus number 2
[    1.543822] usb usb2: We don't know the algorithms for LPM for this host, disabling LPM.
[    1.543863] usb usb2: New USB device found, idVendor=1d6b, idProduct=0003
[    1.543868] usb usb2: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    1.543871] usb usb2: Product: xHCI Host Controller
[    1.543875] usb usb2: Manufacturer: Linux 4.3.0-trunk-amd64 xhci-hcd
[    1.543878] usb usb2: SerialNumber: 0000:00:10.0
[    1.544256] hub 2-0:1.0: USB hub found
[    1.544278] hub 2-0:1.0: 2 ports detected
[    1.556841] rtsx_pci 0000:04:00.0: rtsx_pci_acquire_irq: pcr->msi_en = 1, pci->irq = 29
[    1.558404] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
[    1.559180] ohci_hcd: USB 1.1 'Open' Host Controller (OHCI) Driver
[    1.559619] ehci-pci: EHCI PCI platform driver
[    1.560038] ehci-pci 0000:00:12.2: EHCI Host Controller
[    1.560052] ehci-pci 0000:00:12.2: new USB bus registered, assigned bus number 3
[    1.560063] ehci-pci 0000:00:12.2: applying AMD SB700/SB800/Hudson-2/3 EHCI dummy qh workaround
[    1.560090] ehci-pci 0000:00:12.2: debug port 1
[    1.560158] ehci-pci 0000:00:12.2: irq 17, io mem 0xf0b4d900
[    1.561736] SCSI subsystem initialized
[    1.566180] libata version 3.00 loaded.
[    1.566562] thermal LNXTHERM:00: registered as thermal_zone0
[    1.566570] ACPI: Thermal Zone [THZ0] (63 C)
[    1.568397] ehci-pci 0000:00:12.2: USB 2.0 started, EHCI 1.00
[    1.568613] usb usb3: New USB device found, idVendor=1d6b, idProduct=0002
[    1.568622] usb usb3: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    1.568626] usb usb3: Product: EHCI Host Controller
[    1.568630] usb usb3: Manufacturer: Linux 4.3.0-trunk-amd64 ehci_hcd
[    1.568633] usb usb3: SerialNumber: 0000:00:12.2
[    1.568944] hub 3-0:1.0: USB hub found
[    1.568961] hub 3-0:1.0: 5 ports detected
[    1.569639] ehci-pci 0000:00:13.2: EHCI Host Controller
[    1.569652] ehci-pci 0000:00:13.2: new USB bus registered, assigned bus number 4
[    1.569661] ehci-pci 0000:00:13.2: applying AMD SB700/SB800/Hudson-2/3 EHCI dummy qh workaround
[    1.569674] ehci-pci 0000:00:13.2: debug port 1
[    1.569724] ehci-pci 0000:00:13.2: irq 17, io mem 0xf0b4d800
[    1.580401] ehci-pci 0000:00:13.2: USB 2.0 started, EHCI 1.00
[    1.580542] usb usb4: New USB device found, idVendor=1d6b, idProduct=0002
[    1.580547] usb usb4: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    1.580551] usb usb4: Product: EHCI Host Controller
[    1.580555] usb usb4: Manufacturer: Linux 4.3.0-trunk-amd64 ehci_hcd
[    1.580559] usb usb4: SerialNumber: 0000:00:13.2
[    1.580865] hub 4-0:1.0: USB hub found
[    1.580881] hub 4-0:1.0: 5 ports detected
[    1.581805] ohci-pci: OHCI PCI platform driver
[    1.582210] ohci-pci 0000:00:12.0: OHCI PCI host controller
[    1.582224] ohci-pci 0000:00:12.0: new USB bus registered, assigned bus number 5
[    1.582291] ohci-pci 0000:00:12.0: irq 18, io mem 0xf0b4c000
[    1.640680] usb usb5: New USB device found, idVendor=1d6b, idProduct=0001
[    1.640689] usb usb5: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    1.640693] usb usb5: Product: OHCI PCI host controller
[    1.640697] usb usb5: Manufacturer: Linux 4.3.0-trunk-amd64 ohci_hcd
[    1.640701] usb usb5: SerialNumber: 0000:00:12.0
[    1.641226] hub 5-0:1.0: USB hub found
[    1.641264] hub 5-0:1.0: 5 ports detected
[    1.641916] ohci-pci 0000:00:13.0: OHCI PCI host controller
[    1.641929] ohci-pci 0000:00:13.0: new USB bus registered, assigned bus number 6
[    1.641975] ohci-pci 0000:00:13.0: irq 18, io mem 0xf0b4b000
[    1.700574] usb usb6: New USB device found, idVendor=1d6b, idProduct=0001
[    1.700583] usb usb6: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    1.700588] usb usb6: Product: OHCI PCI host controller
[    1.700591] usb usb6: Manufacturer: Linux 4.3.0-trunk-amd64 ohci_hcd
[    1.700595] usb usb6: SerialNumber: 0000:00:13.0
[    1.701168] hub 6-0:1.0: USB hub found
[    1.701205] hub 6-0:1.0: 5 ports detected
[    1.701913] ohci-pci 0000:00:14.5: OHCI PCI host controller
[    1.701927] ohci-pci 0000:00:14.5: new USB bus registered, assigned bus number 7
[    1.701977] ohci-pci 0000:00:14.5: irq 18, io mem 0xf0b4a000
[    1.760518] usb usb7: New USB device found, idVendor=1d6b, idProduct=0001
[    1.760527] usb usb7: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    1.760531] usb usb7: Product: OHCI PCI host controller
[    1.760535] usb usb7: Manufacturer: Linux 4.3.0-trunk-amd64 ohci_hcd
[    1.760539] usb usb7: SerialNumber: 0000:00:14.5
[    1.761073] hub 7-0:1.0: USB hub found
[    1.761110] hub 7-0:1.0: 2 ports detected
[    1.761751] ahci 0000:00:11.0: version 3.0
[    1.762165] ahci 0000:00:11.0: AHCI 0001.0300 32 slots 1 ports 6 Gbps 0x1 impl SATA mode
[    1.762172] ahci 0000:00:11.0: flags: 64bit ncq sntf ilck pm led clo pmp pio slum part 
[    1.763456] scsi host0: ahci
[    1.763621] ata1: SATA max UDMA/133 abar m2048@0xf0b4d000 port 0xf0b4d100 irq 30
[    2.152163] usb 6-3: new full-speed USB device number 2 using ohci-pci
[    2.152172] usb 4-4: new high-speed USB device number 3 using ehci-pci
[    2.248096] ata1: SATA link up 6.0 Gbps (SStatus 133 SControl 300)
[    2.249115] ata1.00: READ LOG DMA EXT failed, trying unqueued
[    2.249163] ata1.00: failed to get NCQ Send/Recv Log Emask 0x1
[    2.249168] ata1.00: ATA-9: Samsung SSD 840 PRO Series, DXM06B0Q, max UDMA/133
[    2.249173] ata1.00: 500118192 sectors, multi 16: LBA48 NCQ (depth 31/32), AA
[    2.249478] ata1.00: failed to get NCQ Send/Recv Log Emask 0x1
[    2.249491] ata1.00: configured for UDMA/133
[    2.250160] scsi 0:0:0:0: Direct-Access     ATA      Samsung SSD 840  6B0Q PQ: 0 ANSI: 5
[    2.253515] ata1.00: Enabling discard_zeroes_data
[    2.253552] sd 0:0:0:0: [sda] 500118192 512-byte logical blocks: (256 GB/238 GiB)
[    2.253925] sd 0:0:0:0: [sda] Write Protect is off
[    2.253931] sd 0:0:0:0: [sda] Mode Sense: 00 3a 00 00
[    2.254004] sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[    2.254289] ata1.00: Enabling discard_zeroes_data
[    2.256786]  sda: sda1 sda2 sda3
[    2.257567] ata1.00: Enabling discard_zeroes_data
[    2.257730] sd 0:0:0:0: [sda] Attached SCSI disk
[    2.258800] sd 0:0:0:0: Attached scsi generic sg0 type 0
[    2.295630] usb 4-4: New USB device found, idVendor=5986, idProduct=0299
[    2.295639] usb 4-4: New USB device strings: Mfr=1, Product=2, SerialNumber=0
[    2.295643] usb 4-4: Product: Integrated Camera
[    2.295646] usb 4-4: Manufacturer: Vimicro corp.
[    2.307974] platform microcode: firmware: direct-loading firmware amd-ucode/microcode_amd.bin
[    2.313914] microcode: CPU0: new patch_level=0x05000119
[    2.319926] microcode: CPU1: new patch_level=0x05000119
[    2.335826] tsc: Refined TSC clocksource calibration: 1696.914 MHz
[    2.335837] clocksource: tsc: mask: 0xffffffffffffffff max_cycles: 0x1875c420428, max_idle_ns: 440795272528 ns
[    2.337126] usb 6-3: New USB device found, idVendor=0a5c, idProduct=21f3
[    2.337135] usb 6-3: New USB device strings: Mfr=1, Product=2, SerialNumber=3
[    2.337139] usb 6-3: Product: BCM20702A0
[    2.337143] usb 6-3: Manufacturer: Broadcom Corp
[    2.337146] usb 6-3: SerialNumber: 2CD05A80FEA0
[    2.355214] device-mapper: uevent: version 1.0.3
[    2.355405] device-mapper: ioctl: 4.33.0-ioctl (2015-8-18) initialised: dm-devel@redhat.com
[    2.650164] NET: Registered protocol family 38
[    2.684724] sha256_ssse3: Using SSSE3 optimized SHA-256 implementation
[    3.335233] clocksource: Switched to clocksource tsc
[    5.978244] EXT4-fs (dm-1): mounted filesystem with ordered data mode. Opts: (null)
[    6.522904] systemd[1]: Cannot add dependency job for unit NetworkManager.service, ignoring: Unit NetworkManager.service failed to load: No such file or directory.
[    6.523068] systemd[1]: Cannot add dependency job for unit display-manager.service, ignoring: Unit display-manager.service failed to load: No such file or directory.
[    6.649415] lp: driver loaded but no devices found
[    6.656418] ppdev: user-space parallel port driver
[    6.672529] fuse init (API version 7.23)
[    6.705685] systemd-udevd[274]: starting version 215
[    6.712950] loop: module loaded
[    7.036809] ACPI: acpi_idle registered with cpuidle
[    7.048394] acpi-cpufreq: overriding BIOS provided _PSD data
[    7.065190] shpchp: Standard Hot Plug PCI Controller Driver version: 0.4
[    7.090011] input: Power Button as /devices/LNXSYSTM:00/LNXSYBUS:00/PNP0C0C:00/input/input5
[    7.090023] ACPI: Power Button [PWRB]
[    7.090277] input: Lid Switch as /devices/LNXSYSTM:00/LNXSYBUS:00/PNP0C0D:00/input/input6
[    7.092942] ACPI: Lid Switch [LID]
[    7.093101] input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/input/input7
[    7.093110] ACPI: Power Button [PWRF]
[    7.093505] wmi: Mapper loaded
[    7.100814] ACPI: Video Device [VGA1] (multi-head: yes  rom: no  post: no)
[    7.101097] [Firmware Bug]: ACPI: No _BQC method, cannot determine initial brightness
[    7.102098] acpi device:3a: registered as cooling_device0
[    7.102233] input: Video Bus as /devices/LNXSYSTM:00/LNXSYBUS:00/PNP0A08:00/LNXVIDEO:01/input/input8
[    7.140388] [drm] Initialized drm 1.1.0 20060810
[    7.176325] input: HD-Audio Generic HDMI/DP,pcm=3 as /devices/pci0000:00/0000:00:01.1/sound/card0/input9
[    7.205219] ACPI: Battery Slot [BAT1] (battery present)
[    7.206805] ACPI: AC Adapter [ACAD] (on-line)
[    7.216842] Non-volatile memory driver v1.3
[    7.219017] snd_hda_codec_realtek hdaudioC1D0: autoconfig for ALC269VC: line_outs=1 (0x14/0x0/0x0/0x0/0x0) type:speaker
[    7.219030] snd_hda_codec_realtek hdaudioC1D0:    speaker_outs=0 (0x0/0x0/0x0/0x0/0x0)
[    7.219035] snd_hda_codec_realtek hdaudioC1D0:    hp_outs=1 (0x15/0x0/0x0/0x0/0x0)
[    7.219039] snd_hda_codec_realtek hdaudioC1D0:    mono: mono_out=0x0
[    7.219043] snd_hda_codec_realtek hdaudioC1D0:    inputs:
[    7.219048] snd_hda_codec_realtek hdaudioC1D0:      Mic=0x18
[    7.219052] snd_hda_codec_realtek hdaudioC1D0:      Internal Mic=0x12
[    7.238830] thinkpad_acpi: ThinkPad ACPI Extras v0.25
[    7.238838] thinkpad_acpi: http://ibm-acpi.sf.net/
[    7.238841] thinkpad_acpi: ThinkPad BIOS HMET93WW (2.53 ), EC unknown
[    7.238844] thinkpad_acpi: Lenovo ThinkPad Edge E135, model 335963G
[    7.252574] thinkpad_acpi: Unsupported brightness interface, please contact ibm-acpi-devel@lists.sourceforge.net
[    7.254299] thinkpad_acpi: radio switch found; radios are enabled
[    7.254369] thinkpad_acpi: possible tablet mode switch found; ThinkPad in laptop mode
[    7.254406] thinkpad_acpi: This ThinkPad has standard ACPI backlight brightness control, supported by the ACPI video driver
[    7.254409] thinkpad_acpi: Disabling thinkpad-acpi brightness events by default...
[    7.260557] thinkpad_acpi: rfkill switch tpacpi_bluetooth_sw: radio is unblocked
[    7.289222] input: ThinkPad Extra Buttons as /devices/platform/thinkpad_acpi/input/input11
[    7.317760] bcma: bus0: Found chip with id 43228, rev 0x00 and package 0x08
[    7.317798] bcma: bus0: Core 0 found: ChipCommon (manuf 0x4BF, id 0x800, rev 0x25, class 0x0)
[    7.317818] bcma: bus0: Core 1 found: IEEE 802.11 (manuf 0x4BF, id 0x812, rev 0x1E, class 0x0)
[    7.317854] bcma: bus0: Core 2 found: PCIe (manuf 0x4BF, id 0x820, rev 0x12, class 0x0)
[    7.317873] bcma: bus0: Core 3 found: SDIO Device (manuf 0x4BF, id 0x829, rev 0x07, class 0x0)
[    7.322109] input: HDA Digital PCBeep as /devices/pci0000:00/0000:00:14.2/sound/card1/input10
[    7.322398] input: HD-Audio Generic Mic as /devices/pci0000:00/0000:00:14.2/sound/card1/input12
[    7.322470] input: HD-Audio Generic Headphone as /devices/pci0000:00/0000:00:14.2/sound/card1/input13
[    7.330453] bcma: bus0: Bus registered
[    7.334325] [drm] radeon kernel modesetting enabled.
[    7.345769] ACPI Warning: SystemIO range 0x0000000000000B00-0x0000000000000B07 conflicts with OpRegion 0x0000000000000B00-0x0000000000000B0F (\_SB_.PCI0.SMB_.SMB0) (20150818/utaddress-254)
[    7.345787] ACPI: If an ACPI driver is available for this device, you should use it instead of the native driver
[    7.368475] CRAT table not found
[    7.368483] Finished initializing topology ret=0
[    7.378026] kfd kfd: Initialized module
[    7.380018] [drm] initializing kernel modesetting (PALM 0x1002:0x9808 0x17AA:0x5105).
[    7.380113] [drm] register mmio base: 0xF0B00000
[    7.380116] [drm] register mmio size: 262144
[    7.380215] ATOM BIOS: Lenovo
[    7.380291] radeon 0000:00:01.0: VRAM: 384M 0x0000000000000000 - 0x0000000017FFFFFF (384M used)
[    7.380296] radeon 0000:00:01.0: GTT: 1024M 0x0000000018000000 - 0x0000000057FFFFFF
[    7.380301] [drm] Detected VRAM RAM=384M, BAR=256M
[    7.380303] [drm] RAM width 32bits DDR
[    7.387560] [TTM] Zone  kernel: Available graphics memory: 3781862 kiB
[    7.387568] [TTM] Zone   dma32: Available graphics memory: 2097152 kiB
[    7.387571] [TTM] Initializing pool allocator
[    7.387585] [TTM] Initializing DMA pool allocator
[    7.387633] [drm] radeon: 384M of VRAM memory ready
[    7.387636] [drm] radeon: 1024M of GTT memory ready.
[    7.387676] [drm] Loading PALM Microcode
[    7.393625] radeon 0000:00:01.0: firmware: direct-loading firmware radeon/PALM_pfp.bin
[    7.394530] radeon 0000:00:01.0: firmware: direct-loading firmware radeon/PALM_me.bin
[    7.395673] radeon 0000:00:01.0: firmware: direct-loading firmware radeon/SUMO_rlc.bin
[    7.395693] [drm] Internal thermal controller without fan control
[    7.395799] [drm] Found smc ucode version: 0x00010601
[    7.395900] [drm] radeon: dpm initialized
[    7.405086] radeon 0000:00:01.0: firmware: direct-loading firmware radeon/SUMO_uvd.bin
[    7.405198] [drm] GART: num cpu pages 262144, num gpu pages 262144
[    7.412931] [drm] PCIE GART of 1024M enabled (table at 0x0000000000274000).
[    7.424180] radeon 0000:00:01.0: WB enabled
[    7.424194] radeon 0000:00:01.0: fence driver on ring 0 use gpu addr 0x0000000018000c00 and cpu addr 0xffff8801fb635c00
[    7.424199] radeon 0000:00:01.0: fence driver on ring 3 use gpu addr 0x0000000018000c0c and cpu addr 0xffff8801fb635c0c
[    7.424971] radeon 0000:00:01.0: fence driver on ring 5 use gpu addr 0x0000000000072118 and cpu addr 0xffffc90001432118
[    7.424976] [drm] Supports vblank timestamp caching Rev 2 (21.10.2013).
[    7.424978] [drm] Driver supports precise vblank timestamp query.
[    7.424982] radeon 0000:00:01.0: radeon: MSI limited to 32-bit
[    7.425346] radeon 0000:00:01.0: radeon: using MSI.
[    7.425392] [drm] radeon: irq initialized.
[    7.443186] [drm] ring test on 0 succeeded in 1 usecs
[    7.443201] [drm] ring test on 3 succeeded in 3 usecs
[    7.454119] input: PC Speaker as /devices/platform/pcspkr/input/input16
[    7.506623] EXT4-fs (dm-1): re-mounted. Opts: discard,errors=remount-ro
[    7.507100] [drm] ring test on 5 succeeded in 1 usecs
[    7.520106] kvm: Nested Virtualization enabled
[    7.520116] kvm: Nested Paging enabled
[    7.530977] [drm] UVD initialized successfully.
[    7.533098] [drm] ib test on ring 0 succeeded in 0 usecs
[    7.533139] [drm] ib test on ring 3 succeeded in 0 usecs
[    7.812715] random: nonblocking pool is initialized
[    8.008159] psmouse serio4: synaptics: queried max coordinates: x [..5768], y [..5236]
[    8.011846] EXT4-fs (dm-2): mounted filesystem with ordered data mode. Opts: discard
[    8.051617] [drm] ib test on ring 5 succeeded
[    8.064298] psmouse serio4: synaptics: queried min coordinates: x [1172..], y [616..]
[    8.142333] psmouse serio4: synaptics: Touchpad model: 1, fw: 8.1, id: 0x1e2b1, caps: 0xd002a3/0x940300/0x126c00/0x0, board id: 2290, fw id: 1212745
[    8.142359] psmouse serio4: synaptics: serio: Synaptics pass-through port at isa0060/serio4/input0
[    8.175468] [drm] radeon atom DIG backlight initialized
[    8.175483] [drm] Radeon Display Connectors
[    8.175486] [drm] Connector 0:
[    8.175489] [drm]   LVDS-1
[    8.175492] [drm]   HPD1
[    8.175496] [drm]   DDC: 0x6430 0x6430 0x6434 0x6434 0x6438 0x6438 0x643c 0x643c
[    8.175499] [drm]   Encoders:
[    8.175501] [drm]     LCD1: INTERNAL_UNIPHY
[    8.175504] [drm] Connector 1:
[    8.175506] [drm]   HDMI-A-1
[    8.175508] [drm]   HPD2
[    8.175511] [drm]   DDC: 0x6440 0x6440 0x6444 0x6444 0x6448 0x6448 0x644c 0x644c
[    8.175513] [drm]   Encoders:
[    8.175515] [drm]     DFP1: INTERNAL_UNIPHY
[    8.175517] [drm] Connector 2:
[    8.175519] [drm]   VGA-1
[    8.175522] [drm]   DDC: 0x64d8 0x64d8 0x64dc 0x64dc 0x64e0 0x64e0 0x64e4 0x64e4
[    8.175524] [drm]   Encoders:
[    8.175526] [drm]     CRT1: INTERNAL_KLDSCP_DAC1
[    8.184710] EXT4-fs (dm-3): mounted filesystem with ordered data mode. Opts: discard
[    8.186145] input: SynPS/2 Synaptics TouchPad as /devices/platform/i8042/serio4/input/input18
[    8.222543] EXT4-fs (dm-5): mounted filesystem with ordered data mode. Opts: discard
[    8.228924] b43-phy0: Broadcom 43228 WLAN found (core revision 30)
[    8.229368] b43-phy0: Found PHY: Analog 9, Type 4 (N), Revision 16
[    8.229378] b43-phy0: Found Radio: Manuf 0x17F, ID 0x2057, Revision 9, Version 1
[    8.230135] Broadcom 43xx driver loaded [ Features: PMNLS ]
[    8.246128] b43 bcma0:1: firmware: direct-loading firmware b43/ucode30_mimo.fw
[    8.249011] b43 bcma0:1: firmware: direct-loading firmware b43/n16initvals30.fw
[    8.253589] b43 bcma0:1: firmware: direct-loading firmware b43/n16bsinitvals30.fw
[    8.273132] cfg80211: World regulatory domain updated:
[    8.273144] cfg80211:  DFS Master region: unset
[    8.273147] cfg80211:   (start_freq - end_freq @ bandwidth), (max_antenna_gain, max_eirp), (dfs_cac_time)
[    8.273153] cfg80211:   (2402000 KHz - 2472000 KHz @ 40000 KHz), (N/A, 2000 mBm), (N/A)
[    8.273157] cfg80211:   (2457000 KHz - 2482000 KHz @ 40000 KHz), (N/A, 2000 mBm), (N/A)
[    8.273161] cfg80211:   (2474000 KHz - 2494000 KHz @ 20000 KHz), (N/A, 2000 mBm), (N/A)
[    8.273165] cfg80211:   (5170000 KHz - 5250000 KHz @ 80000 KHz, 160000 KHz AUTO), (N/A, 2000 mBm), (N/A)
[    8.273169] cfg80211:   (5250000 KHz - 5330000 KHz @ 80000 KHz, 160000 KHz AUTO), (N/A, 2000 mBm), (0 s)
[    8.273173] cfg80211:   (5490000 KHz - 5730000 KHz @ 160000 KHz), (N/A, 2000 mBm), (0 s)
[    8.273176] cfg80211:   (5735000 KHz - 5835000 KHz @ 80000 KHz), (N/A, 2000 mBm), (N/A)
[    8.273180] cfg80211:   (57240000 KHz - 63720000 KHz @ 2160000 KHz), (N/A, 0 mBm), (N/A)
[    8.303276] EXT4-fs (dm-4): mounted filesystem with ordered data mode. Opts: discard
[    8.310238] cfg80211: Regulatory domain changed to country: DE
[    8.310250] cfg80211:  DFS Master region: ETSI
[    8.310253] cfg80211:   (start_freq - end_freq @ bandwidth), (max_antenna_gain, max_eirp), (dfs_cac_time)
[    8.310259] cfg80211:   (2400000 KHz - 2483500 KHz @ 40000 KHz), (N/A, 2000 mBm), (N/A)
[    8.310263] cfg80211:   (5150000 KHz - 5250000 KHz @ 80000 KHz, 200000 KHz AUTO), (N/A, 2000 mBm), (N/A)
[    8.310268] cfg80211:   (5250000 KHz - 5350000 KHz @ 80000 KHz, 200000 KHz AUTO), (N/A, 2000 mBm), (0 s)
[    8.310272] cfg80211:   (5470000 KHz - 5725000 KHz @ 160000 KHz), (N/A, 2698 mBm), (0 s)
[    8.310276] cfg80211:   (57000000 KHz - 66000000 KHz @ 2160000 KHz), (N/A, 4000 mBm), (N/A)
[    8.313561] ieee80211 phy0: Selected rate control algorithm 'minstrel_ht'
[    8.609337] [drm] fb mappable at 0xE0478000
[    8.609346] [drm] vram apper at 0xE0000000
[    8.609350] [drm] size 4325376
[    8.609353] [drm] fb depth is 24
[    8.609355] [drm]    pitch is 5632
[    8.612616] fbcon: radeondrmfb (fb0) is primary device
[    8.649336] Bluetooth: Core ver 2.20
[    8.649373] NET: Registered protocol family 31
[    8.649375] Bluetooth: HCI device and connection manager initialized
[    8.649383] Bluetooth: HCI socket layer initialized
[    8.649388] Bluetooth: L2CAP socket layer initialized
[    8.649399] Bluetooth: SCO socket layer initialized
[    8.663558] media: Linux media interface: v0.10
[    8.671772] usbcore: registered new interface driver btusb
[    8.681347] Bluetooth: hci0: BCM: chip id 63
[    8.683331] Bluetooth: hci0: BCM20702A1 (001.002.014) build 0000
[    8.683798] bluetooth hci0: firmware: failed to load brcm/BCM20702A1-0a5c-21f3.hcd (-2)
[    8.683802] bluetooth hci0: Direct firmware load for brcm/BCM20702A1-0a5c-21f3.hcd failed with error -2
[    8.683806] Bluetooth: hci0: BCM: Patch brcm/BCM20702A1-0a5c-21f3.hcd not found
[    8.684051] Linux video capture interface: v2.00
[    8.783535] uvcvideo: Found UVC 1.00 device Integrated Camera (5986:0299)
[    8.786290] input: Integrated Camera as /devices/pci0000:00/0000:00:13.2/usb4/4-4/4-4:1.0/input/input20
[    8.786798] usbcore: registered new interface driver uvcvideo
[    8.786801] USB Video Class driver (1.1.1)
[    9.195513] Console: switching to colour frame buffer device 170x48
[    9.203366] radeon 0000:00:01.0: fb0: radeondrmfb frame buffer device
[    9.221402] [drm] Initialized radeon 2.43.0 20080528 for 0000:00:01.0 on minor 0
[   10.193223] systemd-journald[303]: Received request to flush runtime journal from PID 1
[   10.262648] ip_tables: (C) 2000-2006 Netfilter Core Team
[   10.285695] nf_conntrack version 0.5.0 (65536 buckets, 262144 max)
[   10.389439] ip6_tables: (C) 2000-2006 Netfilter Core Team
[   10.841601] RPC: Registered named UNIX socket transport module.
[   10.841610] RPC: Registered udp transport module.
[   10.841613] RPC: Registered tcp transport module.
[   10.841616] RPC: Registered tcp NFSv4.1 backchannel transport module.
[   10.855472] FS-Cache: Loaded
[   10.887819] FS-Cache: Netfs 'nfs' registered for caching
[   10.927338] Installing knfsd (copyright (C) 1996 okir@monad.swb.de).
[   11.492474] Bluetooth: BNEP (Ethernet Emulation) ver 1.3
[   11.492487] Bluetooth: BNEP filters: protocol multicast
[   11.492501] Bluetooth: BNEP socket layer initialized
[   12.975640] psmouse serio5: trackpoint: IBM TrackPoint firmware: 0x0e, buttons: 3/3
[   13.205185] input: TPPS/2 IBM TrackPoint as /devices/platform/i8042/serio4/serio5/input/input19
[   59.801018] r8169 0000:03:00.0: firmware: direct-loading firmware rtl_nic/rtl8168e-3.fw
[   59.899380] r8169 0000:03:00.0 eth0: link down
[   59.899503] IPv6: ADDRCONF(NETDEV_UP): eth0: link is not ready
[   62.185500] r8169 0000:03:00.0 eth0: link up
[   62.185535] IPv6: ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready

=2D-nextPart5036767.aVcEzaX8ML
Content-Disposition: attachment; filename="lspci.txt"
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="UTF-8"; name="lspci.txt"

00:00.0 Host bridge: Advanced Micro Devices, Inc. [AMD] Family 14h Processor Root Complex
	Subsystem: Lenovo Device 5105
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap- 66MHz+ UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 64

00:01.0 VGA compatible controller: Advanced Micro Devices, Inc. [AMD/ATI] Wrestler [Radeon HD 7340] (prog-if 00 [VGA controller])
	Subsystem: Lenovo Device 5105
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 32 bytes
	Interrupt: pin A routed to IRQ 32
	Region 0: Memory at e0000000 (32-bit, prefetchable) [size=256M]
	Region 1: I/O ports at 3000 [size=256]
	Region 2: Memory at f0b00000 (32-bit, non-prefetchable) [size=256K]
	Expansion ROM at <unassigned> [disabled]
	Capabilities: [50] Power Management version 3
		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [58] Express (v2) Root Complex Integrated Endpoint, MSI 00
		DevCap:	MaxPayload 128 bytes, PhantFunc 0
			ExtTag+ RBE+
		DevCtl:	Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
			RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop+
			MaxPayload 128 bytes, MaxReadReq 128 bytes
		DevSta:	CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr- TransPend-
		DevCap2: Completion Timeout: Not Supported, TimeoutDis-, LTR-, OBFF Not Supported
		DevCtl2: Completion Timeout: 50us to 50ms, TimeoutDis-, LTR-, OBFF Disabled
	Capabilities: [a0] MSI: Enable+ Count=1/1 Maskable- 64bit+
		Address: 00000000fee0300c  Data: 4172
	Capabilities: [100 v1] Vendor Specific Information: ID=0001 Rev=1 Len=010 <?>
	Kernel driver in use: radeon

00:01.1 Audio device: Advanced Micro Devices, Inc. [AMD/ATI] Wrestler HDMI Audio
	Subsystem: Lenovo Device 5105
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 32 bytes
	Interrupt: pin B routed to IRQ 31
	Region 0: Memory at f0b44000 (32-bit, non-prefetchable) [size=16K]
	Capabilities: [50] Power Management version 3
		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [58] Express (v2) Root Complex Integrated Endpoint, MSI 00
		DevCap:	MaxPayload 128 bytes, PhantFunc 0
			ExtTag+ RBE+
		DevCtl:	Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
			RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop+
			MaxPayload 128 bytes, MaxReadReq 128 bytes
		DevSta:	CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr- TransPend-
		DevCap2: Completion Timeout: Not Supported, TimeoutDis-, LTR-, OBFF Not Supported
		DevCtl2: Completion Timeout: 50us to 50ms, TimeoutDis-, LTR-, OBFF Disabled
	Capabilities: [a0] MSI: Enable+ Count=1/1 Maskable- 64bit+
		Address: 00000000fee0300c  Data: 4152
	Capabilities: [100 v1] Vendor Specific Information: ID=0001 Rev=1 Len=010 <?>
	Kernel driver in use: snd_hda_intel

00:05.0 PCI bridge: Advanced Micro Devices, Inc. [AMD] Family 14h Processor Root Port (prog-if 00 [Normal decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 32 bytes
	Bus: primary=00, secondary=02, subordinate=02, sec-latency=0
	I/O behind bridge: 0000f000-00000fff
	Memory behind bridge: f0a00000-f0afffff
	Prefetchable memory behind bridge: 00000000fff00000-00000000000fffff
	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort+ <SERR- <PERR-
	BridgeCtl: Parity- SERR- NoISA- VGA- MAbort- >Reset- FastB2B-
		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
	Capabilities: [50] Power Management version 3
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [58] Express (v2) Root Port (Slot+), MSI 00
		DevCap:	MaxPayload 128 bytes, PhantFunc 0
			ExtTag+ RBE+
		DevCtl:	Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
			RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop+
			MaxPayload 128 bytes, MaxReadReq 512 bytes
		DevSta:	CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr- TransPend-
		LnkCap:	Port #2, Speed 2.5GT/s, Width x1, ASPM L0s L1, Exit Latency L0s <64ns, L1 <1us
			ClockPM- Surprise- LLActRep+ BwNot+
		LnkCtl:	ASPM Disabled; RCB 64 bytes Disabled- CommClk+
			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
		LnkSta:	Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+ DLActive+ BWMgmt- ABWMgmt-
		SltCap:	AttnBtn- PwrCtrl- MRL- AttnInd- PwrInd- HotPlug- Surprise-
			Slot #5, PowerLimit 75.000W; Interlock- NoCompl+
		SltCtl:	Enable: AttnBtn- PwrFlt- MRL- PresDet- CmdCplt- HPIrq- LinkChg-
			Control: AttnInd Unknown, PwrInd Unknown, Power- Interlock-
		SltSta:	Status: AttnBtn- PowerFlt- MRL- CmdCplt- PresDet+ Interlock-
			Changed: MRL- PresDet+ LinkState+
		RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFatal- PMEIntEna- CRSVisible+
		RootCap: CRSVisible-
		RootSta: PME ReqID 0000, PMEStatus- PMEPending-
		DevCap2: Completion Timeout: Range ABCD, TimeoutDis+, LTR-, OBFF Not Supported ARIFwd-
		DevCtl2: Completion Timeout: 65ms to 210ms, TimeoutDis-, LTR-, OBFF Disabled ARIFwd-
		LnkCtl2: Target Link Speed: 2.5GT/s, EnterCompliance- SpeedDis+
			 Transmit Margin: Normal Operating Range, EnterModifiedCompliance- ComplianceSOS-
			 Compliance De-emphasis: -6dB
		LnkSta2: Current De-emphasis Level: -6dB, EqualizationComplete-, EqualizationPhase1-
			 EqualizationPhase2-, EqualizationPhase3-, LinkEqualizationRequest-
	Capabilities: [a0] MSI: Enable- Count=1/1 Maskable- 64bit-
		Address: 00000000  Data: 0000
	Capabilities: [b0] Subsystem: Advanced Micro Devices, Inc. [AMD] Device 1234
	Capabilities: [b8] HyperTransport: MSI Mapping Enable+ Fixed+
	Capabilities: [100 v1] Vendor Specific Information: ID=0001 Rev=1 Len=010 <?>
	Kernel driver in use: pcieport

00:06.0 PCI bridge: Advanced Micro Devices, Inc. [AMD] Family 14h Processor Root Port (prog-if 00 [Normal decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 32 bytes
	Bus: primary=00, secondary=03, subordinate=03, sec-latency=0
	I/O behind bridge: 00002000-00002fff
	Memory behind bridge: f0200000-f09fffff
	Prefetchable memory behind bridge: 00000000f0000000-00000000f00fffff
	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort+ <SERR- <PERR-
	BridgeCtl: Parity- SERR- NoISA- VGA- MAbort- >Reset- FastB2B-
		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
	Capabilities: [50] Power Management version 3
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [58] Express (v2) Root Port (Slot+), MSI 00
		DevCap:	MaxPayload 128 bytes, PhantFunc 0
			ExtTag+ RBE+
		DevCtl:	Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
			RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop+
			MaxPayload 128 bytes, MaxReadReq 512 bytes
		DevSta:	CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr- TransPend-
		LnkCap:	Port #3, Speed 2.5GT/s, Width x1, ASPM L0s L1, Exit Latency L0s <64ns, L1 <1us
			ClockPM- Surprise- LLActRep+ BwNot+
		LnkCtl:	ASPM Disabled; RCB 64 bytes Disabled- CommClk+
			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
		LnkSta:	Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+ DLActive+ BWMgmt- ABWMgmt-
		SltCap:	AttnBtn- PwrCtrl- MRL- AttnInd- PwrInd- HotPlug- Surprise-
			Slot #6, PowerLimit 75.000W; Interlock- NoCompl+
		SltCtl:	Enable: AttnBtn- PwrFlt- MRL- PresDet- CmdCplt- HPIrq- LinkChg-
			Control: AttnInd Unknown, PwrInd Unknown, Power- Interlock-
		SltSta:	Status: AttnBtn- PowerFlt- MRL- CmdCplt- PresDet+ Interlock-
			Changed: MRL- PresDet+ LinkState+
		RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFatal- PMEIntEna- CRSVisible+
		RootCap: CRSVisible-
		RootSta: PME ReqID 0000, PMEStatus- PMEPending-
		DevCap2: Completion Timeout: Range ABCD, TimeoutDis+, LTR-, OBFF Not Supported ARIFwd-
		DevCtl2: Completion Timeout: 65ms to 210ms, TimeoutDis-, LTR-, OBFF Disabled ARIFwd-
		LnkCtl2: Target Link Speed: 2.5GT/s, EnterCompliance- SpeedDis+
			 Transmit Margin: Normal Operating Range, EnterModifiedCompliance- ComplianceSOS-
			 Compliance De-emphasis: -6dB
		LnkSta2: Current De-emphasis Level: -6dB, EqualizationComplete-, EqualizationPhase1-
			 EqualizationPhase2-, EqualizationPhase3-, LinkEqualizationRequest-
	Capabilities: [a0] MSI: Enable- Count=1/1 Maskable- 64bit-
		Address: 00000000  Data: 0000
	Capabilities: [b0] Subsystem: Advanced Micro Devices, Inc. [AMD] Device 1234
	Capabilities: [b8] HyperTransport: MSI Mapping Enable+ Fixed+
	Capabilities: [100 v1] Vendor Specific Information: ID=0001 Rev=1 Len=010 <?>
	Kernel driver in use: pcieport

00:07.0 PCI bridge: Advanced Micro Devices, Inc. [AMD] Family 14h Processor Root Port (prog-if 00 [Normal decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 32 bytes
	Bus: primary=00, secondary=04, subordinate=04, sec-latency=0
	I/O behind bridge: 00001000-00001fff
	Memory behind bridge: f0100000-f01fffff
	Prefetchable memory behind bridge: 00000000f0c00000-00000000f0dfffff
	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort+ <SERR- <PERR-
	BridgeCtl: Parity- SERR- NoISA- VGA- MAbort- >Reset- FastB2B-
		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
	Capabilities: [50] Power Management version 3
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [58] Express (v2) Root Port (Slot+), MSI 00
		DevCap:	MaxPayload 128 bytes, PhantFunc 0
			ExtTag+ RBE+
		DevCtl:	Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
			RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop+
			MaxPayload 128 bytes, MaxReadReq 512 bytes
		DevSta:	CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr- TransPend-
		LnkCap:	Port #4, Speed 2.5GT/s, Width x1, ASPM L0s L1, Exit Latency L0s <64ns, L1 <1us
			ClockPM- Surprise- LLActRep+ BwNot+
		LnkCtl:	ASPM Disabled; RCB 64 bytes Disabled- CommClk+
			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
		LnkSta:	Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+ DLActive+ BWMgmt- ABWMgmt-
		SltCap:	AttnBtn- PwrCtrl- MRL- AttnInd- PwrInd- HotPlug+ Surprise-
			Slot #7, PowerLimit 75.000W; Interlock- NoCompl+
		SltCtl:	Enable: AttnBtn- PwrFlt- MRL- PresDet+ CmdCplt- HPIrq+ LinkChg+
			Control: AttnInd Unknown, PwrInd Unknown, Power- Interlock-
		SltSta:	Status: AttnBtn- PowerFlt- MRL- CmdCplt- PresDet+ Interlock-
			Changed: MRL- PresDet- LinkState-
		RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFatal- PMEIntEna- CRSVisible+
		RootCap: CRSVisible-
		RootSta: PME ReqID 0000, PMEStatus- PMEPending-
		DevCap2: Completion Timeout: Range ABCD, TimeoutDis+, LTR-, OBFF Not Supported ARIFwd-
		DevCtl2: Completion Timeout: 65ms to 210ms, TimeoutDis-, LTR-, OBFF Disabled ARIFwd-
		LnkCtl2: Target Link Speed: 2.5GT/s, EnterCompliance- SpeedDis+
			 Transmit Margin: Normal Operating Range, EnterModifiedCompliance- ComplianceSOS-
			 Compliance De-emphasis: -6dB
		LnkSta2: Current De-emphasis Level: -6dB, EqualizationComplete-, EqualizationPhase1-
			 EqualizationPhase2-, EqualizationPhase3-, LinkEqualizationRequest-
	Capabilities: [a0] MSI: Enable+ Count=1/1 Maskable- 64bit-
		Address: fee0300c  Data: 4171
	Capabilities: [b0] Subsystem: Advanced Micro Devices, Inc. [AMD] Device 1234
	Capabilities: [b8] HyperTransport: MSI Mapping Enable+ Fixed+
	Capabilities: [100 v1] Vendor Specific Information: ID=0001 Rev=1 Len=010 <?>
	Kernel driver in use: pcieport

00:10.0 USB controller: Advanced Micro Devices, Inc. [AMD] FCH USB XHCI Controller (rev 03) (prog-if 30 [XHCI])
	Subsystem: Lenovo Device 5105
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 32 bytes
	Interrupt: pin A routed to IRQ 0
	Region 0: Memory at f0b48000 (64-bit, non-prefetchable) [size=8K]
	Capabilities: [50] Power Management version 3
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 NoSoftRst+ PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [70] MSI: Enable- Count=1/8 Maskable- 64bit+
		Address: 0000000000000000  Data: 0000
	Capabilities: [90] MSI-X: Enable+ Count=8 Masked-
		Vector table: BAR=0 offset=00001000
		PBA: BAR=0 offset=00001080
	Capabilities: [a0] Express (v2) Root Complex Integrated Endpoint, MSI 00
		DevCap:	MaxPayload 128 bytes, PhantFunc 0
			ExtTag- RBE+
		DevCtl:	Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
			RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop+
			MaxPayload 128 bytes, MaxReadReq 512 bytes
		DevSta:	CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr+ TransPend-
		DevCap2: Completion Timeout: Not Supported, TimeoutDis+, LTR+, OBFF Not Supported
		DevCtl2: Completion Timeout: 50us to 50ms, TimeoutDis-, LTR-, OBFF Disabled
	Capabilities: [100 v1] Latency Tolerance Reporting
		Max snoop latency: 0ns
		Max no snoop latency: 0ns
	Kernel driver in use: xhci_hcd

00:11.0 SATA controller: Advanced Micro Devices, Inc. [AMD] FCH SATA Controller [AHCI mode] (prog-if 01 [AHCI 1.0])
	Subsystem: Lenovo Device 5105
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+
	Status: Cap+ 66MHz+ UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 64
	Interrupt: pin A routed to IRQ 30
	Region 0: I/O ports at 3118 [size=8]
	Region 1: I/O ports at 3124 [size=4]
	Region 2: I/O ports at 3110 [size=8]
	Region 3: I/O ports at 3120 [size=4]
	Region 4: I/O ports at 3100 [size=16]
	Region 5: Memory at f0b4d000 (32-bit, non-prefetchable) [size=2K]
	Capabilities: [50] MSI: Enable+ Count=1/4 Maskable- 64bit+
		Address: 00000000fee0100c  Data: 4122
	Capabilities: [70] SATA HBA v1.0 InCfgSpace
	Kernel driver in use: ahci

00:12.0 USB controller: Advanced Micro Devices, Inc. [AMD] FCH USB OHCI Controller (rev 11) (prog-if 10 [OHCI])
	Subsystem: Lenovo Device 5105
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap- 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 64, Cache Line Size: 32 bytes
	Interrupt: pin A routed to IRQ 18
	Region 0: Memory at f0b4c000 (32-bit, non-prefetchable) [size=4K]
	Kernel driver in use: ohci-pci

00:12.2 USB controller: Advanced Micro Devices, Inc. [AMD] FCH USB EHCI Controller (rev 11) (prog-if 20 [EHCI])
	Subsystem: Lenovo Device 5105
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 64, Cache Line Size: 32 bytes
	Interrupt: pin B routed to IRQ 17
	Region 0: Memory at f0b4d900 (32-bit, non-prefetchable) [size=256]
	Capabilities: [c0] Power Management version 2
		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA PME(D0+,D1+,D2+,D3hot+,D3cold-)
		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
		Bridge: PM- B3+
	Capabilities: [e4] Debug port: BAR=1 offset=00e0
	Kernel driver in use: ehci-pci

00:13.0 USB controller: Advanced Micro Devices, Inc. [AMD] FCH USB OHCI Controller (rev 11) (prog-if 10 [OHCI])
	Subsystem: Lenovo Device 5105
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap- 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 64, Cache Line Size: 32 bytes
	Interrupt: pin A routed to IRQ 18
	Region 0: Memory at f0b4b000 (32-bit, non-prefetchable) [size=4K]
	Kernel driver in use: ohci-pci

00:13.2 USB controller: Advanced Micro Devices, Inc. [AMD] FCH USB EHCI Controller (rev 11) (prog-if 20 [EHCI])
	Subsystem: Lenovo Device 5105
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 64, Cache Line Size: 32 bytes
	Interrupt: pin B routed to IRQ 17
	Region 0: Memory at f0b4d800 (32-bit, non-prefetchable) [size=256]
	Capabilities: [c0] Power Management version 2
		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA PME(D0+,D1+,D2+,D3hot+,D3cold-)
		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
		Bridge: PM- B3+
	Capabilities: [e4] Debug port: BAR=1 offset=00e0
	Kernel driver in use: ehci-pci

00:14.0 SMBus: Advanced Micro Devices, Inc. [AMD] FCH SMBus Controller (rev 14)
	Subsystem: Lenovo Device 5105
	Control: I/O+ Mem+ BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+
	Status: Cap- 66MHz+ UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-

00:14.2 Audio device: Advanced Micro Devices, Inc. [AMD] FCH Azalia Controller (rev 01)
	Subsystem: Lenovo Device 5105
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=slow >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 64, Cache Line Size: 32 bytes
	Interrupt: pin A routed to IRQ 16
	Region 0: Memory at f0b40000 (64-bit, non-prefetchable) [size=16K]
	Capabilities: [50] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=55mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
	Kernel driver in use: snd_hda_intel

00:14.3 ISA bridge: Advanced Micro Devices, Inc. [AMD] FCH LPC Bridge (rev 11)
	Subsystem: Lenovo Device 5105
	Control: I/O+ Mem+ BusMaster+ SpecCycle+ MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap- 66MHz+ UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0

00:14.4 PCI bridge: Advanced Micro Devices, Inc. [AMD] FCH PCI Bridge (rev 40) (prog-if 01 [Subtractive decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap- 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 64
	Bus: primary=00, secondary=05, subordinate=05, sec-latency=64
	I/O behind bridge: 0000f000-00000fff
	Memory behind bridge: fff00000-000fffff
	Prefetchable memory behind bridge: fff00000-000fffff
	Secondary status: 66MHz- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort+ <SERR- <PERR-
	BridgeCtl: Parity- SERR- NoISA- VGA- MAbort- >Reset- FastB2B-
		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-

00:14.5 USB controller: Advanced Micro Devices, Inc. [AMD] FCH USB OHCI Controller (rev 11) (prog-if 10 [OHCI])
	Subsystem: Lenovo Device 5105
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap- 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 64, Cache Line Size: 32 bytes
	Interrupt: pin C routed to IRQ 18
	Region 0: Memory at f0b4a000 (32-bit, non-prefetchable) [size=4K]
	Kernel driver in use: ohci-pci

00:18.0 Host bridge: Advanced Micro Devices, Inc. [AMD] Family 12h/14h Processor Function 0 (rev 43)
	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-

00:18.1 Host bridge: Advanced Micro Devices, Inc. [AMD] Family 12h/14h Processor Function 1
	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-

00:18.2 Host bridge: Advanced Micro Devices, Inc. [AMD] Family 12h/14h Processor Function 2
	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-

00:18.3 Host bridge: Advanced Micro Devices, Inc. [AMD] Family 12h/14h Processor Function 3
	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Capabilities: [f0] Secure device <?>
	Kernel driver in use: k10temp

00:18.4 Host bridge: Advanced Micro Devices, Inc. [AMD] Family 12h/14h Processor Function 4
	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-

00:18.5 Host bridge: Advanced Micro Devices, Inc. [AMD] Family 12h/14h Processor Function 6
	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-

00:18.6 Host bridge: Advanced Micro Devices, Inc. [AMD] Family 12h/14h Processor Function 5
	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-

00:18.7 Host bridge: Advanced Micro Devices, Inc. [AMD] Family 12h/14h Processor Function 7
	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-

02:00.0 Network controller: Broadcom Corporation BCM43228 802.11a/b/g/n
	Subsystem: Broadcom Corporation Device 0607
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 32 bytes
	Interrupt: pin A routed to IRQ 17
	Region 0: Memory at f0a00000 (64-bit, non-prefetchable) [size=16K]
	Capabilities: [40] Power Management version 3
		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 NoSoftRst+ PME-Enable- DSel=0 DScale=2 PME-
	Capabilities: [58] Vendor Specific Information: Len=78 <?>
	Capabilities: [48] MSI: Enable- Count=1/1 Maskable- 64bit+
		Address: 0000000000000000  Data: 0000
	Capabilities: [d0] Express (v1) Endpoint, MSI 00
		DevCap:	MaxPayload 128 bytes, PhantFunc 0, Latency L0s <4us, L1 unlimited
			ExtTag+ AttnBtn- AttnInd- PwrInd- RBE+ FLReset-
		DevCtl:	Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
			RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
			MaxPayload 128 bytes, MaxReadReq 512 bytes
		DevSta:	CorrErr+ UncorrErr- FatalErr- UnsuppReq+ AuxPwr+ TransPend-
		LnkCap:	Port #0, Speed 2.5GT/s, Width x1, ASPM L1, Exit Latency L0s <4us, L1 <64us
			ClockPM+ Surprise- LLActRep+ BwNot-
		LnkCtl:	ASPM Disabled; RCB 64 bytes Disabled- CommClk+
			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
		LnkSta:	Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+ DLActive+ BWMgmt- ABWMgmt-
	Capabilities: [100 v1] Advanced Error Reporting
		UESta:	DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
		UEMsk:	DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
		UESvrt:	DLP+ SDES- TLP- FCP+ CmpltTO- CmpltAbrt- UnxCmplt- RxOF+ MalfTLP+ ECRC- UnsupReq- ACSViol-
		CESta:	RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr+
		CEMsk:	RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr+
		AERCap:	First Error Pointer: 14, GenCap+ CGenEn- ChkCap+ ChkEn-
	Capabilities: [13c v1] Virtual Channel
		Caps:	LPEVC=0 RefClk=100ns PATEntryBits=1
		Arb:	Fixed- WRR32- WRR64- WRR128-
		Ctrl:	ArbSelect=Fixed
		Status:	InProgress-
		VC0:	Caps:	PATOffset=00 MaxTimeSlots=1 RejSnoopTrans-
			Arb:	Fixed- WRR32- WRR64- WRR128- TWRR128- WRR256-
			Ctrl:	Enable+ ID=0 ArbSelect=Fixed TC/VC=ff
			Status:	NegoPending- InProgress-
	Capabilities: [160 v1] Device Serial Number 00-00-52-ff-ff-43-24-fd
	Capabilities: [16c v1] Power Budgeting <?>
	Kernel driver in use: bcma-pci-bridge

03:00.0 Ethernet controller: Realtek Semiconductor Co., Ltd. RTL8111/8168/8411 PCI Express Gigabit Ethernet Controller (rev 07)
	Subsystem: Lenovo Device 5105
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 32 bytes
	Interrupt: pin A routed to IRQ 28
	Region 0: I/O ports at 2000 [size=256]
	Region 2: Memory at f0004000 (64-bit, prefetchable) [size=4K]
	Region 4: Memory at f0000000 (64-bit, prefetchable) [size=16K]
	Capabilities: [40] Power Management version 3
		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=375mA PME(D0+,D1+,D2+,D3hot+,D3cold+)
		Status: D0 NoSoftRst+ PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [50] MSI: Enable+ Count=1/1 Maskable- 64bit+
		Address: 00000000fee0100c  Data: 41b1
	Capabilities: [70] Express (v2) Endpoint, MSI 01
		DevCap:	MaxPayload 128 bytes, PhantFunc 0, Latency L0s <512ns, L1 <64us
			ExtTag- AttnBtn- AttnInd- PwrInd- RBE+ FLReset-
		DevCtl:	Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
			RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop-
			MaxPayload 128 bytes, MaxReadReq 4096 bytes
		DevSta:	CorrErr+ UncorrErr- FatalErr- UnsuppReq+ AuxPwr+ TransPend-
		LnkCap:	Port #0, Speed 2.5GT/s, Width x1, ASPM L0s L1, Exit Latency L0s unlimited, L1 <64us
			ClockPM+ Surprise- LLActRep- BwNot-
		LnkCtl:	ASPM Disabled; RCB 64 bytes Disabled- CommClk+
			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
		LnkSta:	Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+ DLActive- BWMgmt- ABWMgmt-
		DevCap2: Completion Timeout: Range ABCD, TimeoutDis+, LTR-, OBFF Not Supported
		DevCtl2: Completion Timeout: 50us to 50ms, TimeoutDis-, LTR-, OBFF Disabled
		LnkCtl2: Target Link Speed: 2.5GT/s, EnterCompliance- SpeedDis-
			 Transmit Margin: Normal Operating Range, EnterModifiedCompliance- ComplianceSOS-
			 Compliance De-emphasis: -6dB
		LnkSta2: Current De-emphasis Level: -6dB, EqualizationComplete-, EqualizationPhase1-
			 EqualizationPhase2-, EqualizationPhase3-, LinkEqualizationRequest-
	Capabilities: [b0] MSI-X: Enable- Count=4 Masked-
		Vector table: BAR=4 offset=00000000
		PBA: BAR=4 offset=00000800
	Capabilities: [d0] Vital Product Data
		No end tag found
	Capabilities: [100 v1] Advanced Error Reporting
		UESta:	DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq+ ACSViol-
		UEMsk:	DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
		UESvrt:	DLP+ SDES+ TLP- FCP+ CmpltTO- CmpltAbrt- UnxCmplt- RxOF+ MalfTLP+ ECRC- UnsupReq- ACSViol-
		CESta:	RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr+
		CEMsk:	RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr+
		AERCap:	First Error Pointer: 14, GenCap+ CGenEn- ChkCap+ ChkEn-
	Capabilities: [140 v1] Virtual Channel
		Caps:	LPEVC=0 RefClk=100ns PATEntryBits=1
		Arb:	Fixed- WRR32- WRR64- WRR128-
		Ctrl:	ArbSelect=Fixed
		Status:	InProgress-
		VC0:	Caps:	PATOffset=00 MaxTimeSlots=1 RejSnoopTrans-
			Arb:	Fixed- WRR32- WRR64- WRR128- TWRR128- WRR256-
			Ctrl:	Enable+ ID=0 ArbSelect=Fixed TC/VC=ff
			Status:	NegoPending- InProgress-
	Capabilities: [160 v1] Device Serial Number 8a-00-00-00-68-4c-e0-00
	Kernel driver in use: r8169

04:00.0 Unassigned class [ff00]: Realtek Semiconductor Co., Ltd. RTS5209 PCI Express Card Reader (rev 01)
	Subsystem: Lenovo Device 5105
	Physical Slot: 7
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 32 bytes
	Interrupt: pin A routed to IRQ 29
	Region 0: Memory at f0100000 (32-bit, non-prefetchable) [size=4K]
	Expansion ROM at f0110000 [disabled] [size=64K]
	Capabilities: [40] Power Management version 3
		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=375mA PME(D0-,D1+,D2+,D3hot+,D3cold-)
		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [50] MSI: Enable+ Count=1/1 Maskable- 64bit+
		Address: 00000000fee0300c  Data: 41d1
	Capabilities: [70] Express (v2) Endpoint, MSI 00
		DevCap:	MaxPayload 128 bytes, PhantFunc 0, Latency L0s <1us, L1 <8us
			ExtTag- AttnBtn- AttnInd- PwrInd- RBE+ FLReset-
		DevCtl:	Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
			RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop-
			MaxPayload 128 bytes, MaxReadReq 512 bytes
		DevSta:	CorrErr+ UncorrErr- FatalErr- UnsuppReq+ AuxPwr- TransPend-
		LnkCap:	Port #0, Speed 2.5GT/s, Width x1, ASPM L0s L1, Exit Latency L0s unlimited, L1 <64us
			ClockPM+ Surprise- LLActRep- BwNot-
		LnkCtl:	ASPM Disabled; RCB 64 bytes Disabled- CommClk+
			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
		LnkSta:	Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+ DLActive- BWMgmt- ABWMgmt-
		DevCap2: Completion Timeout: Not Supported, TimeoutDis+, LTR-, OBFF Not Supported
		DevCtl2: Completion Timeout: 50us to 50ms, TimeoutDis-, LTR-, OBFF Disabled
		LnkCtl2: Target Link Speed: 2.5GT/s, EnterCompliance- SpeedDis-
			 Transmit Margin: Normal Operating Range, EnterModifiedCompliance- ComplianceSOS-
			 Compliance De-emphasis: -6dB
		LnkSta2: Current De-emphasis Level: -6dB, EqualizationComplete-, EqualizationPhase1-
			 EqualizationPhase2-, EqualizationPhase3-, LinkEqualizationRequest-
	Capabilities: [100 v1] Advanced Error Reporting
		UESta:	DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
		UEMsk:	DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
		UESvrt:	DLP+ SDES+ TLP- FCP+ CmpltTO- CmpltAbrt- UnxCmplt- RxOF+ MalfTLP+ ECRC- UnsupReq- ACSViol-
		CESta:	RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr+
		CEMsk:	RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr+
		AERCap:	First Error Pointer: 00, GenCap+ CGenEn- ChkCap+ ChkEn-
	Capabilities: [140 v1] Device Serial Number 00-00-00-01-00-4c-e0-00
	Kernel driver in use: rtsx_pci


=2D-nextPart5036767.aVcEzaX8ML--
This is a multi-part message in MIME format.

--nextPart5036767.aVcEzaX8ML
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"

Hello,

I'm using a Lenovo TinkPad Edge E135 notebook that has a Realtek wired network 
interface inbuilt. Under some conditions the nic doesn't work after changing 
the mac address.

It took me some time to figure out that it makes a difference if I (re)boot my 
notebook with or without the power supply plugged in. When I boot the system 
with the power supply plugged in everything does work fine as expected. But if 
I boot with the power supply unplugged and I change the mac address the 
network card doesn't work.


This is how I am testing and how I can reproduce the behavior on my system:

* Boot Linux (Debian stable with a newer kernel)
* Network is still turned off, only loopback is enabled by default in my setup.
* I run the following commands:
  ip link set dev eth0 address 00:12:0c:96:a7:2e # a randomly generated mac
  ip link set dev eth0 up
  ip addr add dev eth0 10.0.252.50/24
  ip route add default via 10.0.252.1

When the notebook is booted with the power supply plugged in the network is 
working as expected, e. g. I can ping the gateway.

But when the notebook was booted without the power supply attached the network 
is not working e. g. pinging the gateway doesn't get any replies.

I found two ways to get the network working from this state (beside rebooting 
with power plugged in):

* If I enable promiscous mode the network connections are working again:
  # ip link set dev eth0 promisc on

* Alternatively I can set the same mac address again while the interface is 
up:
  # ip link set dev eth0 address 00:12:0c:96:a7:2e # same mac as before


So it seems like a mac filter in the network card is not set up right.


Attached are dmesg output of a boot with and without power supply attached as 
well as the output of lspci -vvv.


Please let me know If you need more information.

Thanks,
Maxi

--nextPart5036767.aVcEzaX8ML
Content-Disposition: attachment; filename="dmesg_nopower"
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="UTF-8"; name="dmesg_nopowersupply.txt"

[    0.000000] Initializing cgroup subsys cpuset
[    0.000000] Initializing cgroup subsys cpu
[    0.000000] Initializing cgroup subsys cpuacct
[    0.000000] Linux version 4.3.0-trunk-amd64 (debian-kernel@lists.debian.org) (gcc version 5.2.1 20151028 (Debian 5.2.1-23) ) #1 SMP Debian 4.3-1~exp1 (2015-11-04)
[    0.000000] Command line: BOOT_IMAGE=/boot/vmlinuz-4.3.0-trunk-amd64 root=/dev/mapper/fuchs--vg-root ro quiet
[    0.000000] tseg: 00dfc00000
[    0.000000] x86/fpu: Legacy x87 FPU detected.
[    0.000000] x86/fpu: Using 'lazy' FPU context switches.
[    0.000000] e820: BIOS-provided physical RAM map:
[    0.000000] BIOS-e820: [mem 0x0000000000000000-0x000000000009e7ff] usable
[    0.000000] BIOS-e820: [mem 0x000000000009e800-0x000000000009ffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000000e0000-0x00000000000fffff] reserved
[    0.000000] BIOS-e820: [mem 0x0000000000100000-0x00000000d2e1ffff] usable
[    0.000000] BIOS-e820: [mem 0x00000000d2e20000-0x00000000ded02fff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000ded03000-0x00000000dee32fff] ACPI NVS
[    0.000000] BIOS-e820: [mem 0x00000000dee33000-0x00000000deeb2fff] ACPI data
[    0.000000] BIOS-e820: [mem 0x00000000deeb3000-0x00000000dfffffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000fec00000-0x00000000fecfffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000fed80000-0x00000000fed80fff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000ffc00000-0x00000000ffffffff] reserved
[    0.000000] BIOS-e820: [mem 0x0000000100000000-0x0000000206ffffff] usable
[    0.000000] NX (Execute Disable) protection: active
[    0.000000] SMBIOS 2.7 present.
[    0.000000] DMI: LENOVO 335963G/335963G, BIOS HMET93WW (2.53 ) 07/11/2013
[    0.000000] e820: update [mem 0x00000000-0x00000fff] usable ==> reserved
[    0.000000] e820: remove [mem 0x000a0000-0x000fffff] usable
[    0.000000] e820: last_pfn = 0x207000 max_arch_pfn = 0x400000000
[    0.000000] MTRR default type: uncachable
[    0.000000] MTRR fixed ranges enabled:
[    0.000000]   00000-9FFFF write-back
[    0.000000]   A0000-BFFFF uncachable
[    0.000000]   C0000-FFFFF write-protect
[    0.000000] MTRR variable ranges enabled:
[    0.000000]   0 base 000000000 mask F80000000 write-back
[    0.000000]   1 base 080000000 mask FC0000000 write-back
[    0.000000]   2 base 0C0000000 mask FE0000000 write-back
[    0.000000]   3 base 207000000 mask FFF000000 uncachable
[    0.000000]   4 base 208000000 mask FF8000000 uncachable
[    0.000000]   5 base 0FED80000 mask FFFFFF000 uncachable
[    0.000000]   6 disabled
[    0.000000]   7 base 0FFC00000 mask FFFC00000 write-protect
[    0.000000] TOM2: 000000021f000000 aka 8688M
[    0.000000] x86/PAT: Configuration [0-7]: WB  WC  UC- UC  WB  WC  UC- WT  
[    0.000000] e820: last_pfn = 0xd2e20 max_arch_pfn = 0x400000000
[    0.000000] found SMP MP-table at [mem 0x000fa8f0-0x000fa8ff] mapped at [ffff8800000fa8f0]
[    0.000000] Base memory trampoline at [ffff880000098000] 98000 size 24576
[    0.000000] Using GB pages for direct mapping
[    0.000000] init_memory_mapping: [mem 0x00000000-0x000fffff]
[    0.000000]  [mem 0x00000000-0x000fffff] page 4k
[    0.000000] BRK [0x01d20000, 0x01d20fff] PGTABLE
[    0.000000] BRK [0x01d21000, 0x01d21fff] PGTABLE
[    0.000000] BRK [0x01d22000, 0x01d22fff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0x206e00000-0x206ffffff]
[    0.000000]  [mem 0x206e00000-0x206ffffff] page 2M
[    0.000000] BRK [0x01d23000, 0x01d23fff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0x200000000-0x206dfffff]
[    0.000000]  [mem 0x200000000-0x206dfffff] page 2M
[    0.000000] init_memory_mapping: [mem 0x1e0000000-0x1ffffffff]
[    0.000000]  [mem 0x1e0000000-0x1ffffffff] page 1G
[    0.000000] init_memory_mapping: [mem 0x00100000-0xd2e1ffff]
[    0.000000]  [mem 0x00100000-0x001fffff] page 4k
[    0.000000]  [mem 0x00200000-0x3fffffff] page 2M
[    0.000000]  [mem 0x40000000-0xbfffffff] page 1G
[    0.000000]  [mem 0xc0000000-0xd2dfffff] page 2M
[    0.000000]  [mem 0xd2e00000-0xd2e1ffff] page 4k
[    0.000000] init_memory_mapping: [mem 0x100000000-0x1dfffffff]
[    0.000000]  [mem 0x100000000-0x1dfffffff] page 1G
[    0.000000] RAMDISK: [mem 0x35c26000-0x36e0afff]
[    0.000000] ACPI: Early table checksum verification disabled
[    0.000000] ACPI: RSDP 0x00000000000F0120 000024 (v02 LENOVO)
[    0.000000] ACPI: XSDT 0x00000000DEEB2170 00008C (v01 LENOVO TP-HM    06040000 PTL  00000002)
[    0.000000] ACPI: FACP 0x00000000DEE9F000 00010C (v05 LENOVO TP-HM    00002530 PTL  00000002)
[    0.000000] ACPI: DSDT 0x00000000DEEA1000 010AF4 (v01 LENOVO AMD      00001000 INTL 20061109)
[    0.000000] ACPI: FACS 0x00000000DEE1A000 000040
[    0.000000] ACPI: HPET 0x00000000DEE9E000 000038 (v01 LENOVO TP-HM    00002530 PTL  00000002)
[    0.000000] ACPI: APIC 0x00000000DEE9D000 00007A (v02 LENOVO TP-HM    00002530 PTL  00000002)
[    0.000000] ACPI: MCFG 0x00000000DEE9C000 00003C (v01 LENOVO TP-HM    00002530 PTL  00000002)
[    0.000000] ACPI: SBST 0x00000000DEE9B000 000030 (v01 LENOVO TP-HM    00002530 PTL  00000002)
[    0.000000] ACPI: FPDT 0x00000000DEE9A000 000064 (v01 LENOVO TP-HM    00002530 PTL  00000002)
[    0.000000] ACPI: UEFI 0x00000000DEE99000 00003E (v01 LENOVO TP-HM    00002530 PTL  00000002)
[    0.000000] ACPI: UEFI 0x00000000DEE98000 000042 (v01 PTL    COMBUF   00000001 PTL  00000001)
[    0.000000] ACPI: POAT 0x00000000DEDF5000 000055 (v03 LENOVO TP-HM    00002530 PTL  00000002)
[    0.000000] ACPI: SSDT 0x00000000DEE97000 0003DE (v01 AMD    POWERNOW 00000001 AMD  00000001)
[    0.000000] ACPI: SSDT 0x00000000DEE95000 0016E4 (v02 AMD    ALIB     00000001 MSFT 04000000)
[    0.000000] ACPI: UEFI 0x00000000DEE94000 000292 (v01 LENOVO TP-HM    00002530 PTL  00000002)
[    0.000000] ACPI: DBG2 0x00000000DEE93000 00006B (v00 LENOVO TP-HM    00002530 PTL  00000002)
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] No NUMA configuration found
[    0.000000] Faking a node at [mem 0x0000000000000000-0x0000000206ffffff]
[    0.000000] NODE_DATA(0) allocated [mem 0x206ffa000-0x206ffdfff]
[    0.000000]  [ffffea0000000000-ffffea00081fffff] PMD -> [ffff8801fee00000-ffff8802065fffff] on node 0
[    0.000000] Zone ranges:
[    0.000000]   DMA      [mem 0x0000000000001000-0x0000000000ffffff]
[    0.000000]   DMA32    [mem 0x0000000001000000-0x00000000ffffffff]
[    0.000000]   Normal   [mem 0x0000000100000000-0x0000000206ffffff]
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x0000000000001000-0x000000000009dfff]
[    0.000000]   node   0: [mem 0x0000000000100000-0x00000000d2e1ffff]
[    0.000000]   node   0: [mem 0x0000000100000000-0x0000000206ffffff]
[    0.000000] Initmem setup node 0 [mem 0x0000000000001000-0x0000000206ffffff]
[    0.000000] On node 0 totalpages: 1940925
[    0.000000]   DMA zone: 64 pages used for memmap
[    0.000000]   DMA zone: 21 pages reserved
[    0.000000]   DMA zone: 3997 pages, LIFO batch:0
[    0.000000]   DMA32 zone: 13433 pages used for memmap
[    0.000000]   DMA32 zone: 859680 pages, LIFO batch:31
[    0.000000]   Normal zone: 16832 pages used for memmap
[    0.000000]   Normal zone: 1077248 pages, LIFO batch:31
[    0.000000] ACPI: PM-Timer IO Port: 0x808
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x00] high edge lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x01] high edge lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x02] high edge lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x03] high edge lint[0x1])
[    0.000000] IOAPIC[0]: apic_id 2, version 33, address 0xfec00000, GSI 0-23
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
[    0.000000] ACPI: IRQ0 used by override.
[    0.000000] ACPI: IRQ9 used by override.
[    0.000000] Using ACPI (MADT) for SMP configuration information
[    0.000000] ACPI: HPET id: 0x43538210 base: 0xfed00000
[    0.000000] smpboot: Allowing 4 CPUs, 2 hotplug CPUs
[    0.000000] PM: Registered nosave memory: [mem 0x00000000-0x00000fff]
[    0.000000] PM: Registered nosave memory: [mem 0x0009e000-0x0009efff]
[    0.000000] PM: Registered nosave memory: [mem 0x0009f000-0x0009ffff]
[    0.000000] PM: Registered nosave memory: [mem 0x000a0000-0x000dffff]
[    0.000000] PM: Registered nosave memory: [mem 0x000e0000-0x000fffff]
[    0.000000] PM: Registered nosave memory: [mem 0xd2e20000-0xded02fff]
[    0.000000] PM: Registered nosave memory: [mem 0xded03000-0xdee32fff]
[    0.000000] PM: Registered nosave memory: [mem 0xdee33000-0xdeeb2fff]
[    0.000000] PM: Registered nosave memory: [mem 0xdeeb3000-0xdfffffff]
[    0.000000] PM: Registered nosave memory: [mem 0xe0000000-0xfebfffff]
[    0.000000] PM: Registered nosave memory: [mem 0xfec00000-0xfecfffff]
[    0.000000] PM: Registered nosave memory: [mem 0xfed00000-0xfed7ffff]
[    0.000000] PM: Registered nosave memory: [mem 0xfed80000-0xfed80fff]
[    0.000000] PM: Registered nosave memory: [mem 0xfed81000-0xffbfffff]
[    0.000000] PM: Registered nosave memory: [mem 0xffc00000-0xffffffff]
[    0.000000] e820: [mem 0xe0000000-0xfebfffff] available for PCI devices
[    0.000000] Booting paravirtualized kernel on bare hardware
[    0.000000] clocksource: refined-jiffies: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 7645519600211568 ns
[    0.000000] setup_percpu: NR_CPUS:512 nr_cpumask_bits:512 nr_cpu_ids:4 nr_node_ids:1
[    0.000000] PERCPU: Embedded 32 pages/cpu @ffff880206c00000 s92952 r8192 d29928 u524288
[    0.000000] pcpu-alloc: s92952 r8192 d29928 u524288 alloc=1*2097152
[    0.000000] pcpu-alloc: [0] 0 1 2 3 
[    0.000000] Built 1 zonelists in Node order, mobility grouping on.  Total pages: 1910575
[    0.000000] Policy zone: Normal
[    0.000000] Kernel command line: BOOT_IMAGE=/boot/vmlinuz-4.3.0-trunk-amd64 root=/dev/mapper/fuchs--vg-root ro quiet
[    0.000000] PID hash table entries: 4096 (order: 3, 32768 bytes)
[    0.000000] Calgary: detecting Calgary via BIOS EBDA area
[    0.000000] Calgary: Unable to locate Rio Grande table in EBDA - bailing!
[    0.000000] Memory: 7542112K/7763700K available (5474K kernel code, 1047K rwdata, 2772K rodata, 1284K init, 836K bss, 221588K reserved, 0K cma-reserved)
[    0.000000] Hierarchical RCU implementation.
[    0.000000] 	Build-time adjustment of leaf fanout to 64.
[    0.000000] 	RCU restricting CPUs from NR_CPUS=512 to nr_cpu_ids=4.
[    0.000000] RCU: Adjusting geometry for rcu_fanout_leaf=64, nr_cpu_ids=4
[    0.000000] NR_IRQS:33024 nr_irqs:456 16
[    0.000000] spurious 8259A interrupt: IRQ7.
[    0.000000] Console: colour VGA+ 80x25
[    0.000000] console [tty0] enabled
[    0.000000] clocksource: hpet: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 133484873504 ns
[    0.000000] hpet clockevent registered
[    0.000000] tsc: Fast TSC calibration using PIT
[    0.000000] tsc: Detected 1696.807 MHz processor
[    0.000058] Calibrating delay loop (skipped), value calculated using timer frequency.. 3393.61 BogoMIPS (lpj=6787228)
[    0.000065] pid_max: default: 32768 minimum: 301
[    0.000084] ACPI: Core revision 20150818
[    0.029404] ACPI: 3 ACPI AML tables successfully acquired and loaded
[    0.029482] Security Framework initialized
[    0.029489] Yama: disabled by default; enable with sysctl kernel.yama.*
[    0.029505] AppArmor: AppArmor disabled by boot time parameter
[    0.030754] Dentry cache hash table entries: 1048576 (order: 11, 8388608 bytes)
[    0.036005] Inode-cache hash table entries: 524288 (order: 10, 4194304 bytes)
[    0.038324] Mount-cache hash table entries: 16384 (order: 5, 131072 bytes)
[    0.038349] Mountpoint-cache hash table entries: 16384 (order: 5, 131072 bytes)
[    0.038917] Initializing cgroup subsys io
[    0.038937] Initializing cgroup subsys memory
[    0.038952] Initializing cgroup subsys devices
[    0.038959] Initializing cgroup subsys freezer
[    0.038966] Initializing cgroup subsys net_cls
[    0.038974] Initializing cgroup subsys perf_event
[    0.038980] Initializing cgroup subsys net_prio
[    0.039058] CPU: Physical Processor ID: 0
[    0.039061] CPU: Processor Core ID: 0
[    0.039064] mce: CPU supports 6 MCE banks
[    0.039082] Last level iTLB entries: 4KB 512, 2MB 8, 4MB 4
[    0.039085] Last level dTLB entries: 4KB 512, 2MB 8, 4MB 4, 1GB 0
[    0.039778] Freeing SMP alternatives memory: 20K (ffffffff81c48000 - ffffffff81c4d000)
[    0.058242] ftrace: allocating 23497 entries in 92 pages
[    0.262113] ..TIMER: vector=0x30 apic1=0 pin1=2 apic2=-1 pin2=-1
[    0.406728] smpboot: CPU0: AMD E2-1800 APU with Radeon(tm) HD Graphics (family: 0x14, model: 0x2, stepping: 0x0)
[    0.406777] Performance Events: AMD PMU driver.
[    0.406786] ... version:                0
[    0.406789] ... bit width:              48
[    0.406791] ... generic registers:      4
[    0.406794] ... value mask:             0000ffffffffffff
[    0.406796] ... max period:             00007fffffffffff
[    0.406798] ... fixed-purpose events:   0
[    0.406801] ... event mask:             000000000000000f
[    0.407796] NMI watchdog: enabled on all CPUs, permanently consumes one hw-PMU counter.
[    0.408026] x86: Booting SMP configuration:
[    0.408031] .... node  #0, CPUs:      #1
[    0.421087] x86: Booted up 1 node, 2 CPUs
[    0.421091] smpboot: Total of 2 processors activated (6787.22 BogoMIPS)
[    0.421870] devtmpfs: initialized
[    0.429000] PM: Registering ACPI NVS region [mem 0xded03000-0xdee32fff] (1245184 bytes)
[    0.429237] clocksource: jiffies: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 7645041785100000 ns
[    0.429450] pinctrl core: initialized pinctrl subsystem
[    0.432750] NET: Registered protocol family 16
[    0.442910] cpuidle: using governor ladder
[    0.454900] cpuidle: using governor menu
[    0.455191] ACPI: bus type PCI registered
[    0.455197] acpiphp: ACPI Hot Plug PCI Controller Driver version: 0.5
[    0.455443] PCI: MMCONFIG for domain 0000 [bus 00-3f] at [mem 0xf8000000-0xfbffffff] (base 0xf8000000)
[    0.455448] PCI: not using MMCONFIG
[    0.455452] PCI: Using configuration type 1 for base access
[    0.455454] PCI: Using configuration type 1 for extended access
[    0.455967] mtrr: your CPUs had inconsistent variable MTRR settings
[    0.455970] mtrr: probably your BIOS does not setup all CPUs.
[    0.455972] mtrr: corrected configuration.
[    0.468426] ACPI: Added _OSI(Module Device)
[    0.468434] ACPI: Added _OSI(Processor Device)
[    0.468437] ACPI: Added _OSI(3.0 _SCP Extensions)
[    0.468440] ACPI: Added _OSI(Processor Aggregator Device)
[    0.479779] [Firmware Bug]: ACPI: BIOS _OSI(Linux) query ignored
[    0.480729] ACPI : EC: EC started
[    0.488618] ACPI: Interpreter enabled
[    0.488639] ACPI Exception: AE_NOT_FOUND, While evaluating Sleep State [\_S1_] (20150818/hwxface-580)
[    0.488648] ACPI Exception: AE_NOT_FOUND, While evaluating Sleep State [\_S2_] (20150818/hwxface-580)
[    0.488678] ACPI: (supports S0 S3 S4 S5)
[    0.488682] ACPI: Using IOAPIC for interrupt routing
[    0.488961] PCI: MMCONFIG for domain 0000 [bus 00-3f] at [mem 0xf8000000-0xfbffffff] (base 0xf8000000)
[    0.489525] PCI: MMCONFIG at [mem 0xf8000000-0xfbffffff] reserved in ACPI motherboard resources
[    0.489554] PCI: Using host bridge windows from ACPI; if necessary, use "pci=nocrs" and report a bug
[    0.490488] [Firmware Bug]: ACPI: No _BQC method, cannot determine initial brightness
[    0.499401] [Firmware Bug]: ACPI: No _BQC method, cannot determine initial brightness
[    0.506056] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-ff])
[    0.506073] acpi PNP0A08:00: _OSC: OS supports [ExtendedConfig ASPM ClockPM Segments MSI]
[    0.506450] acpi PNP0A08:00: _OSC: platform does not support [PME]
[    0.506841] acpi PNP0A08:00: _OSC: OS now controls [PCIeHotplug AER PCIeCapability]
[    0.507739] acpi PNP0A08:00: ignoring host bridge window [mem 0x000ce000-0x000cffff window] (conflicts with Video ROM [mem 0x000c0000-0x000cedff])
[    0.507749] acpi PNP0A08:00: [Firmware Info]: MMCONFIG for domain 0000 [bus 00-3f] only partially covers this bridge
[    0.508154] PCI host bridge to bus 0000:00
[    0.508161] pci_bus 0000:00: root bus resource [bus 00-ff]
[    0.508166] pci_bus 0000:00: root bus resource [mem 0x000a0000-0x000bffff window]
[    0.508170] pci_bus 0000:00: root bus resource [mem 0x000c0000-0x000c1fff window]
[    0.508174] pci_bus 0000:00: root bus resource [mem 0x000c2000-0x000c3fff window]
[    0.508179] pci_bus 0000:00: root bus resource [mem 0x000c4000-0x000c5fff window]
[    0.508183] pci_bus 0000:00: root bus resource [mem 0x000c6000-0x000c7fff window]
[    0.508187] pci_bus 0000:00: root bus resource [mem 0x000c8000-0x000c9fff window]
[    0.508191] pci_bus 0000:00: root bus resource [mem 0x000ca000-0x000cbfff window]
[    0.508195] pci_bus 0000:00: root bus resource [mem 0x000cc000-0x000cdfff window]
[    0.508199] pci_bus 0000:00: root bus resource [mem 0x000d0000-0x000d1fff window]
[    0.508203] pci_bus 0000:00: root bus resource [mem 0x000d2000-0x000d3fff window]
[    0.508207] pci_bus 0000:00: root bus resource [mem 0x000d4000-0x000d5fff window]
[    0.508211] pci_bus 0000:00: root bus resource [mem 0x000d6000-0x000d7fff window]
[    0.508215] pci_bus 0000:00: root bus resource [mem 0x000d8000-0x000d9fff window]
[    0.508219] pci_bus 0000:00: root bus resource [mem 0x000da000-0x000dbfff window]
[    0.508223] pci_bus 0000:00: root bus resource [mem 0x000dc000-0x000ddfff window]
[    0.508227] pci_bus 0000:00: root bus resource [mem 0x000de000-0x000dffff window]
[    0.508231] pci_bus 0000:00: root bus resource [mem 0x000e0000-0x000e1fff window]
[    0.508235] pci_bus 0000:00: root bus resource [mem 0x000e2000-0x000e3fff window]
[    0.508238] pci_bus 0000:00: root bus resource [mem 0x000e4000-0x000e5fff window]
[    0.508242] pci_bus 0000:00: root bus resource [mem 0x000e6000-0x000e7fff window]
[    0.508246] pci_bus 0000:00: root bus resource [mem 0x000e8000-0x000e9fff window]
[    0.508250] pci_bus 0000:00: root bus resource [mem 0x000ea000-0x000ebfff window]
[    0.508254] pci_bus 0000:00: root bus resource [mem 0x000ec000-0x000edfff window]
[    0.508258] pci_bus 0000:00: root bus resource [mem 0x000ee000-0x000effff window]
[    0.508262] pci_bus 0000:00: root bus resource [mem 0xe0000000-0xf7ffffff window]
[    0.508266] pci_bus 0000:00: root bus resource [mem 0xfc000000-0xfdffffff window]
[    0.508270] pci_bus 0000:00: root bus resource [mem 0xfed40000-0xfed44fff window]
[    0.508274] pci_bus 0000:00: root bus resource [io  0x0000-0x0cf7 window]
[    0.508278] pci_bus 0000:00: root bus resource [io  0x0d00-0xffff window]
[    0.508293] pci 0000:00:00.0: [1022:1510] type 00 class 0x060000
[    0.508481] pci 0000:00:01.0: [1002:9808] type 00 class 0x030000
[    0.508508] pci 0000:00:01.0: reg 0x10: [mem 0xe0000000-0xefffffff pref]
[    0.508519] pci 0000:00:01.0: reg 0x14: [io  0x3000-0x30ff]
[    0.508530] pci 0000:00:01.0: reg 0x18: [mem 0xf0b00000-0xf0b3ffff]
[    0.508580] pci 0000:00:01.0: supports D1 D2
[    0.508730] pci 0000:00:01.1: [1002:1314] type 00 class 0x040300
[    0.508757] pci 0000:00:01.1: reg 0x10: [mem 0xf0b44000-0xf0b47fff]
[    0.508818] pci 0000:00:01.1: supports D1 D2
[    0.508977] pci 0000:00:05.0: [1022:1513] type 01 class 0x060400
[    0.509047] pci 0000:00:05.0: PME# supported from D0 D3hot D3cold
[    0.509134] pci 0000:00:05.0: System wakeup disabled by ACPI
[    0.509222] pci 0000:00:06.0: [1022:1514] type 01 class 0x060400
[    0.509290] pci 0000:00:06.0: PME# supported from D0 D3hot D3cold
[    0.509374] pci 0000:00:06.0: System wakeup disabled by ACPI
[    0.509454] pci 0000:00:07.0: [1022:1515] type 01 class 0x060400
[    0.509522] pci 0000:00:07.0: PME# supported from D0 D3hot D3cold
[    0.509605] pci 0000:00:07.0: System wakeup disabled by ACPI
[    0.509720] pci 0000:00:10.0: [1022:7812] type 00 class 0x0c0330
[    0.509769] pci 0000:00:10.0: reg 0x10: [mem 0xf0b48000-0xf0b49fff 64bit]
[    0.509863] pci 0000:00:10.0: PME# supported from D0 D3hot D3cold
[    0.509979] pci 0000:00:10.0: System wakeup disabled by ACPI
[    0.510084] pci 0000:00:11.0: [1022:7801] type 00 class 0x010601
[    0.510118] pci 0000:00:11.0: reg 0x10: [io  0x3118-0x311f]
[    0.510132] pci 0000:00:11.0: reg 0x14: [io  0x3124-0x3127]
[    0.510145] pci 0000:00:11.0: reg 0x18: [io  0x3110-0x3117]
[    0.510157] pci 0000:00:11.0: reg 0x1c: [io  0x3120-0x3123]
[    0.510170] pci 0000:00:11.0: reg 0x20: [io  0x3100-0x310f]
[    0.510183] pci 0000:00:11.0: reg 0x24: [mem 0xf0b4d000-0xf0b4d7ff]
[    0.510372] pci 0000:00:12.0: [1022:7807] type 00 class 0x0c0310
[    0.510393] pci 0000:00:12.0: reg 0x10: [mem 0xf0b4c000-0xf0b4cfff]
[    0.510556] pci 0000:00:12.0: System wakeup disabled by ACPI
[    0.510669] pci 0000:00:12.2: [1022:7808] type 00 class 0x0c0320
[    0.510703] pci 0000:00:12.2: reg 0x10: [mem 0xf0b4d900-0xf0b4d9ff]
[    0.510785] pci 0000:00:12.2: supports D1 D2
[    0.510789] pci 0000:00:12.2: PME# supported from D0 D1 D2 D3hot
[    0.510963] pci 0000:00:13.0: [1022:7807] type 00 class 0x0c0310
[    0.510984] pci 0000:00:13.0: reg 0x10: [mem 0xf0b4b000-0xf0b4bfff]
[    0.511148] pci 0000:00:13.0: System wakeup disabled by ACPI
[    0.511232] pci 0000:00:13.2: [1022:7808] type 00 class 0x0c0320
[    0.511264] pci 0000:00:13.2: reg 0x10: [mem 0xf0b4d800-0xf0b4d8ff]
[    0.511347] pci 0000:00:13.2: supports D1 D2
[    0.511351] pci 0000:00:13.2: PME# supported from D0 D1 D2 D3hot
[    0.511453] pci 0000:00:13.2: System wakeup disabled by ACPI
[    0.511554] pci 0000:00:14.0: [1022:780b] type 00 class 0x0c0500
[    0.511791] pci 0000:00:14.2: [1022:780d] type 00 class 0x040300
[    0.511825] pci 0000:00:14.2: reg 0x10: [mem 0xf0b40000-0xf0b43fff 64bit]
[    0.511896] pci 0000:00:14.2: PME# supported from D0 D3hot D3cold
[    0.511980] pci 0000:00:14.2: System wakeup disabled by ACPI
[    0.512070] pci 0000:00:14.3: [1022:780e] type 00 class 0x060100
[    0.512291] pci 0000:00:14.4: [1022:780f] type 01 class 0x060401
[    0.512411] pci 0000:00:14.4: System wakeup disabled by ACPI
[    0.512507] pci 0000:00:14.5: [1022:7809] type 00 class 0x0c0310
[    0.512528] pci 0000:00:14.5: reg 0x10: [mem 0xf0b4a000-0xf0b4afff]
[    0.512692] pci 0000:00:14.5: System wakeup disabled by ACPI
[    0.512791] pci 0000:00:18.0: [1022:1700] type 00 class 0x060000
[    0.512958] pci 0000:00:18.1: [1022:1701] type 00 class 0x060000
[    0.513122] pci 0000:00:18.2: [1022:1702] type 00 class 0x060000
[    0.513284] pci 0000:00:18.3: [1022:1703] type 00 class 0x060000
[    0.513455] pci 0000:00:18.4: [1022:1704] type 00 class 0x060000
[    0.513615] pci 0000:00:18.5: [1022:1718] type 00 class 0x060000
[    0.513776] pci 0000:00:18.6: [1022:1716] type 00 class 0x060000
[    0.513937] pci 0000:00:18.7: [1022:1719] type 00 class 0x060000
[    0.514284] pci 0000:02:00.0: [14e4:4359] type 00 class 0x028000
[    0.514333] pci 0000:02:00.0: reg 0x10: [mem 0xf0a00000-0xf0a03fff 64bit]
[    0.514443] pci 0000:02:00.0: supports D1 D2
[    0.514447] pci 0000:02:00.0: PME# supported from D0 D3hot D3cold
[    0.518923] pci 0000:00:05.0: PCI bridge to [bus 02]
[    0.518946] pci 0000:00:05.0:   bridge window [mem 0xf0a00000-0xf0afffff]
[    0.519133] pci 0000:03:00.0: [10ec:8168] type 00 class 0x020000
[    0.519179] pci 0000:03:00.0: reg 0x10: [io  0x2000-0x20ff]
[    0.519210] pci 0000:03:00.0: reg 0x18: [mem 0xf0004000-0xf0004fff 64bit pref]
[    0.519230] pci 0000:03:00.0: reg 0x20: [mem 0xf0000000-0xf0003fff 64bit pref]
[    0.519305] pci 0000:03:00.0: supports D1 D2
[    0.519309] pci 0000:03:00.0: PME# supported from D0 D1 D2 D3hot D3cold
[    0.526877] pci 0000:00:06.0: PCI bridge to [bus 03]
[    0.526903] pci 0000:00:06.0:   bridge window [io  0x2000-0x2fff]
[    0.526915] pci 0000:00:06.0:   bridge window [mem 0xf0200000-0xf09fffff]
[    0.526928] pci 0000:00:06.0:   bridge window [mem 0xf0000000-0xf00fffff 64bit pref]
[    0.527122] pci 0000:04:00.0: [10ec:5209] type 00 class 0xff0000
[    0.527167] pci 0000:04:00.0: reg 0x10: [mem 0xf0100000-0xf0100fff]
[    0.527234] pci 0000:04:00.0: reg 0x30: [mem 0xffff0000-0xffffffff pref]
[    0.527292] pci 0000:04:00.0: supports D1 D2
[    0.527296] pci 0000:04:00.0: PME# supported from D1 D2 D3hot
[    0.534870] pci 0000:00:07.0: PCI bridge to [bus 04]
[    0.534899] pci 0000:00:07.0:   bridge window [mem 0xf0100000-0xf01fffff]
[    0.535105] pci 0000:00:14.4: PCI bridge to [bus 05] (subtractive decode)
[    0.535119] pci 0000:00:14.4:   bridge window [mem 0x000a0000-0x000bffff window] (subtractive decode)
[    0.535124] pci 0000:00:14.4:   bridge window [mem 0x000c0000-0x000c1fff window] (subtractive decode)
[    0.535129] pci 0000:00:14.4:   bridge window [mem 0x000c2000-0x000c3fff window] (subtractive decode)
[    0.535133] pci 0000:00:14.4:   bridge window [mem 0x000c4000-0x000c5fff window] (subtractive decode)
[    0.535138] pci 0000:00:14.4:   bridge window [mem 0x000c6000-0x000c7fff window] (subtractive decode)
[    0.535142] pci 0000:00:14.4:   bridge window [mem 0x000c8000-0x000c9fff window] (subtractive decode)
[    0.535146] pci 0000:00:14.4:   bridge window [mem 0x000ca000-0x000cbfff window] (subtractive decode)
[    0.535150] pci 0000:00:14.4:   bridge window [mem 0x000cc000-0x000cdfff window] (subtractive decode)
[    0.535155] pci 0000:00:14.4:   bridge window [mem 0x000d0000-0x000d1fff window] (subtractive decode)
[    0.535159] pci 0000:00:14.4:   bridge window [mem 0x000d2000-0x000d3fff window] (subtractive decode)
[    0.535163] pci 0000:00:14.4:   bridge window [mem 0x000d4000-0x000d5fff window] (subtractive decode)
[    0.535167] pci 0000:00:14.4:   bridge window [mem 0x000d6000-0x000d7fff window] (subtractive decode)
[    0.535171] pci 0000:00:14.4:   bridge window [mem 0x000d8000-0x000d9fff window] (subtractive decode)
[    0.535175] pci 0000:00:14.4:   bridge window [mem 0x000da000-0x000dbfff window] (subtractive decode)
[    0.535180] pci 0000:00:14.4:   bridge window [mem 0x000dc000-0x000ddfff window] (subtractive decode)
[    0.535184] pci 0000:00:14.4:   bridge window [mem 0x000de000-0x000dffff window] (subtractive decode)
[    0.535188] pci 0000:00:14.4:   bridge window [mem 0x000e0000-0x000e1fff window] (subtractive decode)
[    0.535192] pci 0000:00:14.4:   bridge window [mem 0x000e2000-0x000e3fff window] (subtractive decode)
[    0.535196] pci 0000:00:14.4:   bridge window [mem 0x000e4000-0x000e5fff window] (subtractive decode)
[    0.535200] pci 0000:00:14.4:   bridge window [mem 0x000e6000-0x000e7fff window] (subtractive decode)
[    0.535205] pci 0000:00:14.4:   bridge window [mem 0x000e8000-0x000e9fff window] (subtractive decode)
[    0.535209] pci 0000:00:14.4:   bridge window [mem 0x000ea000-0x000ebfff window] (subtractive decode)
[    0.535213] pci 0000:00:14.4:   bridge window [mem 0x000ec000-0x000edfff window] (subtractive decode)
[    0.535217] pci 0000:00:14.4:   bridge window [mem 0x000ee000-0x000effff window] (subtractive decode)
[    0.535223] pci 0000:00:14.4:   bridge window [mem 0xe0000000-0xf7ffffff window] (subtractive decode)
[    0.535227] pci 0000:00:14.4:   bridge window [mem 0xfc000000-0xfdffffff window] (subtractive decode)
[    0.535231] pci 0000:00:14.4:   bridge window [mem 0xfed40000-0xfed44fff window] (subtractive decode)
[    0.535236] pci 0000:00:14.4:   bridge window [io  0x0000-0x0cf7 window] (subtractive decode)
[    0.535242] pci 0000:00:14.4:   bridge window [io  0x0d00-0xffff window] (subtractive decode)
[    0.535966] ACPI: PCI Interrupt Link [LNKA] (IRQs 10 11) *0
[    0.536121] ACPI: PCI Interrupt Link [LNKB] (IRQs 10 11) *0
[    0.536269] ACPI: PCI Interrupt Link [LNKC] (IRQs 10 11) *0
[    0.536414] ACPI: PCI Interrupt Link [LNKD] (IRQs 10 11) *0
[    0.536540] ACPI: PCI Interrupt Link [LNKE] (IRQs 10 11) *0
[    0.536645] ACPI: PCI Interrupt Link [LNKF] (IRQs 10 11) *0
[    0.536751] ACPI: PCI Interrupt Link [LNKG] (IRQs 10 11) *0
[    0.536856] ACPI: PCI Interrupt Link [LNKH] (IRQs 10 11) *0
[    0.537140] ACPI: IRQ 7 override to edge, high
[    0.539940] ACPI: Enabled 1 GPEs in block 00 to 1F
[    0.540111] ACPI : EC: GPE = 0x3, I/O: command/status = 0x66, data = 0x62
[    0.540453] vgaarb: setting as boot device: PCI:0000:00:01.0
[    0.540461] vgaarb: device added: PCI:0000:00:01.0,decodes=io+mem,owns=io+mem,locks=none
[    0.540473] vgaarb: loaded
[    0.540476] vgaarb: bridge control possible 0000:00:01.0
[    0.540847] PCI: Using ACPI for IRQ routing
[    0.543129] PCI: pci_cache_line_size set to 64 bytes
[    0.543303] e820: reserve RAM buffer [mem 0x0009e800-0x0009ffff]
[    0.543308] e820: reserve RAM buffer [mem 0xd2e20000-0xd3ffffff]
[    0.543312] e820: reserve RAM buffer [mem 0x207000000-0x207ffffff]
[    0.543630] hpet0: at MMIO 0xfed00000, IRQs 2, 8, 0
[    0.543638] hpet0: 3 comparators, 32-bit 14.318180 MHz counter
[    0.545733] clocksource: Switched to clocksource hpet
[    0.558978] pnp: PnP ACPI init
[    0.559275] system 00:00: [io  0x0f50-0x0f51] has been reserved
[    0.559282] system 00:00: [mem 0xfec00000-0xfec00fff] could not be reserved
[    0.559287] system 00:00: [mem 0xfee00000-0xfee00fff] has been reserved
[    0.559292] system 00:00: [mem 0xf8000000-0xfbffffff] has been reserved
[    0.559301] system 00:00: Plug and Play ACPI device, IDs PNP0c02 (active)
[    0.560016] pnp 00:01: Plug and Play ACPI device, IDs PNP0b00 (active)
[    0.560080] pnp 00:02: Plug and Play ACPI device, IDs MSF0001 PNP0303 (active)
[    0.560189] pnp 00:03: Plug and Play ACPI device, IDs LEN0052 PNP0f13 (active)
[    0.560309] system 00:04: [io  0x04d0-0x04d1] has been reserved
[    0.560314] system 00:04: [io  0x0530-0x0537] has been reserved
[    0.560319] system 00:04: [io  0x0800-0x0827] could not be reserved
[    0.560324] system 00:04: [io  0x0830] has been reserved
[    0.560329] system 00:04: [io  0x0840-0x0847] has been reserved
[    0.560333] system 00:04: [io  0x0b00-0x0b1f] has been reserved
[    0.560338] system 00:04: [io  0x0c00-0x0c01] has been reserved
[    0.560343] system 00:04: [io  0x0c14] has been reserved
[    0.560347] system 00:04: [io  0x0c50-0x0c52] has been reserved
[    0.560351] system 00:04: [io  0x0cd0-0x0cd1] has been reserved
[    0.560358] system 00:04: [io  0x0cd2-0x0cd3] has been reserved
[    0.560363] system 00:04: [io  0x0cd4-0x0cd5] has been reserved
[    0.560367] system 00:04: [io  0x0cd6-0x0cd7] has been reserved
[    0.560371] system 00:04: [io  0x0cd8-0x0cdf] has been reserved
[    0.560376] system 00:04: [io  0x0cf9] could not be reserved
[    0.560380] system 00:04: [io  0x8100-0x81ff window] has been reserved
[    0.560385] system 00:04: [io  0x8200-0x82ff window] has been reserved
[    0.560391] system 00:04: Plug and Play ACPI device, IDs PNP0c02 (active)
[    0.560583] system 00:05: [mem 0x000e0000-0x000fffff] could not be reserved
[    0.560589] system 00:05: [mem 0xffe00000-0xffffffff] has been reserved
[    0.560594] system 00:05: [mem 0xfec10000-0xfec1001f] has been reserved
[    0.560598] system 00:05: [mem 0xfed00000-0xfed003ff] has been reserved
[    0.560603] system 00:05: [mem 0xfed61000-0xfed613ff] has been reserved
[    0.560608] system 00:05: [mem 0xfed80000-0xfed80fff] has been reserved
[    0.560613] system 00:05: Plug and Play ACPI device, IDs PNP0c01 (active)
[    0.561948] pnp: PnP ACPI: found 6 devices
[    0.572580] clocksource: acpi_pm: mask: 0xffffff max_cycles: 0xffffff, max_idle_ns: 2085701024 ns
[    0.572601] pci 0000:04:00.0: can't claim BAR 6 [mem 0xffff0000-0xffffffff pref]: no compatible bridge window
[    0.572641] pci 0000:00:07.0: bridge window [io  0x1000-0x0fff] to [bus 04] add_size 1000
[    0.572647] pci 0000:00:07.0: bridge window [mem 0x00100000-0x000fffff 64bit pref] to [bus 04] add_size 200000 add_align 100000
[    0.572680] pci 0000:00:07.0: res[15]=[mem 0x00100000-0x000fffff 64bit pref] res_to_dev_res add_size 200000 min_align 100000
[    0.572685] pci 0000:00:07.0: res[15]=[mem 0x00100000-0x002fffff 64bit pref] res_to_dev_res add_size 200000 min_align 100000
[    0.572690] pci 0000:00:07.0: res[13]=[io  0x1000-0x0fff] res_to_dev_res add_size 1000 min_align 1000
[    0.572695] pci 0000:00:07.0: res[13]=[io  0x1000-0x1fff] res_to_dev_res add_size 1000 min_align 1000
[    0.572740] pci 0000:00:07.0: BAR 15: assigned [mem 0xf0c00000-0xf0dfffff 64bit pref]
[    0.572751] pci 0000:00:07.0: BAR 13: assigned [io  0x1000-0x1fff]
[    0.572757] pci 0000:00:05.0: PCI bridge to [bus 02]
[    0.572765] pci 0000:00:05.0:   bridge window [mem 0xf0a00000-0xf0afffff]
[    0.572775] pci 0000:00:06.0: PCI bridge to [bus 03]
[    0.572779] pci 0000:00:06.0:   bridge window [io  0x2000-0x2fff]
[    0.572786] pci 0000:00:06.0:   bridge window [mem 0xf0200000-0xf09fffff]
[    0.572792] pci 0000:00:06.0:   bridge window [mem 0xf0000000-0xf00fffff 64bit pref]
[    0.572801] pci 0000:04:00.0: BAR 6: assigned [mem 0xf0110000-0xf011ffff pref]
[    0.572806] pci 0000:00:07.0: PCI bridge to [bus 04]
[    0.572810] pci 0000:00:07.0:   bridge window [io  0x1000-0x1fff]
[    0.572816] pci 0000:00:07.0:   bridge window [mem 0xf0100000-0xf01fffff]
[    0.572823] pci 0000:00:07.0:   bridge window [mem 0xf0c00000-0xf0dfffff 64bit pref]
[    0.572830] pci 0000:00:14.4: PCI bridge to [bus 05]
[    0.572861] pci_bus 0000:00: resource 4 [mem 0x000a0000-0x000bffff window]
[    0.572865] pci_bus 0000:00: resource 5 [mem 0x000c0000-0x000c1fff window]
[    0.572869] pci_bus 0000:00: resource 6 [mem 0x000c2000-0x000c3fff window]
[    0.572873] pci_bus 0000:00: resource 7 [mem 0x000c4000-0x000c5fff window]
[    0.572877] pci_bus 0000:00: resource 8 [mem 0x000c6000-0x000c7fff window]
[    0.572880] pci_bus 0000:00: resource 9 [mem 0x000c8000-0x000c9fff window]
[    0.572884] pci_bus 0000:00: resource 10 [mem 0x000ca000-0x000cbfff window]
[    0.572888] pci_bus 0000:00: resource 11 [mem 0x000cc000-0x000cdfff window]
[    0.572891] pci_bus 0000:00: resource 12 [mem 0x000d0000-0x000d1fff window]
[    0.572895] pci_bus 0000:00: resource 13 [mem 0x000d2000-0x000d3fff window]
[    0.572899] pci_bus 0000:00: resource 14 [mem 0x000d4000-0x000d5fff window]
[    0.572902] pci_bus 0000:00: resource 15 [mem 0x000d6000-0x000d7fff window]
[    0.572906] pci_bus 0000:00: resource 16 [mem 0x000d8000-0x000d9fff window]
[    0.572910] pci_bus 0000:00: resource 17 [mem 0x000da000-0x000dbfff window]
[    0.572913] pci_bus 0000:00: resource 18 [mem 0x000dc000-0x000ddfff window]
[    0.572917] pci_bus 0000:00: resource 19 [mem 0x000de000-0x000dffff window]
[    0.572920] pci_bus 0000:00: resource 20 [mem 0x000e0000-0x000e1fff window]
[    0.572924] pci_bus 0000:00: resource 21 [mem 0x000e2000-0x000e3fff window]
[    0.572928] pci_bus 0000:00: resource 22 [mem 0x000e4000-0x000e5fff window]
[    0.572931] pci_bus 0000:00: resource 23 [mem 0x000e6000-0x000e7fff window]
[    0.572935] pci_bus 0000:00: resource 24 [mem 0x000e8000-0x000e9fff window]
[    0.572939] pci_bus 0000:00: resource 25 [mem 0x000ea000-0x000ebfff window]
[    0.572942] pci_bus 0000:00: resource 26 [mem 0x000ec000-0x000edfff window]
[    0.572946] pci_bus 0000:00: resource 27 [mem 0x000ee000-0x000effff window]
[    0.572950] pci_bus 0000:00: resource 28 [mem 0xe0000000-0xf7ffffff window]
[    0.572954] pci_bus 0000:00: resource 29 [mem 0xfc000000-0xfdffffff window]
[    0.572957] pci_bus 0000:00: resource 30 [mem 0xfed40000-0xfed44fff window]
[    0.572961] pci_bus 0000:00: resource 31 [io  0x0000-0x0cf7 window]
[    0.572965] pci_bus 0000:00: resource 32 [io  0x0d00-0xffff window]
[    0.572969] pci_bus 0000:02: resource 1 [mem 0xf0a00000-0xf0afffff]
[    0.572973] pci_bus 0000:03: resource 0 [io  0x2000-0x2fff]
[    0.572977] pci_bus 0000:03: resource 1 [mem 0xf0200000-0xf09fffff]
[    0.572981] pci_bus 0000:03: resource 2 [mem 0xf0000000-0xf00fffff 64bit pref]
[    0.572985] pci_bus 0000:04: resource 0 [io  0x1000-0x1fff]
[    0.572988] pci_bus 0000:04: resource 1 [mem 0xf0100000-0xf01fffff]
[    0.572992] pci_bus 0000:04: resource 2 [mem 0xf0c00000-0xf0dfffff 64bit pref]
[    0.572997] pci_bus 0000:05: resource 4 [mem 0x000a0000-0x000bffff window]
[    0.573000] pci_bus 0000:05: resource 5 [mem 0x000c0000-0x000c1fff window]
[    0.573005] pci_bus 0000:05: resource 6 [mem 0x000c2000-0x000c3fff window]
[    0.573008] pci_bus 0000:05: resource 7 [mem 0x000c4000-0x000c5fff window]
[    0.573012] pci_bus 0000:05: resource 8 [mem 0x000c6000-0x000c7fff window]
[    0.573016] pci_bus 0000:05: resource 9 [mem 0x000c8000-0x000c9fff window]
[    0.573019] pci_bus 0000:05: resource 10 [mem 0x000ca000-0x000cbfff window]
[    0.573023] pci_bus 0000:05: resource 11 [mem 0x000cc000-0x000cdfff window]
[    0.573026] pci_bus 0000:05: resource 12 [mem 0x000d0000-0x000d1fff window]
[    0.573030] pci_bus 0000:05: resource 13 [mem 0x000d2000-0x000d3fff window]
[    0.573034] pci_bus 0000:05: resource 14 [mem 0x000d4000-0x000d5fff window]
[    0.573037] pci_bus 0000:05: resource 15 [mem 0x000d6000-0x000d7fff window]
[    0.573041] pci_bus 0000:05: resource 16 [mem 0x000d8000-0x000d9fff window]
[    0.573045] pci_bus 0000:05: resource 17 [mem 0x000da000-0x000dbfff window]
[    0.573048] pci_bus 0000:05: resource 18 [mem 0x000dc000-0x000ddfff window]
[    0.573052] pci_bus 0000:05: resource 19 [mem 0x000de000-0x000dffff window]
[    0.573055] pci_bus 0000:05: resource 20 [mem 0x000e0000-0x000e1fff window]
[    0.573059] pci_bus 0000:05: resource 21 [mem 0x000e2000-0x000e3fff window]
[    0.573063] pci_bus 0000:05: resource 22 [mem 0x000e4000-0x000e5fff window]
[    0.573066] pci_bus 0000:05: resource 23 [mem 0x000e6000-0x000e7fff window]
[    0.573070] pci_bus 0000:05: resource 24 [mem 0x000e8000-0x000e9fff window]
[    0.573074] pci_bus 0000:05: resource 25 [mem 0x000ea000-0x000ebfff window]
[    0.573077] pci_bus 0000:05: resource 26 [mem 0x000ec000-0x000edfff window]
[    0.573081] pci_bus 0000:05: resource 27 [mem 0x000ee000-0x000effff window]
[    0.573085] pci_bus 0000:05: resource 28 [mem 0xe0000000-0xf7ffffff window]
[    0.573089] pci_bus 0000:05: resource 29 [mem 0xfc000000-0xfdffffff window]
[    0.573092] pci_bus 0000:05: resource 30 [mem 0xfed40000-0xfed44fff window]
[    0.573097] pci_bus 0000:05: resource 31 [io  0x0000-0x0cf7 window]
[    0.573101] pci_bus 0000:05: resource 32 [io  0x0d00-0xffff window]
[    0.573217] NET: Registered protocol family 2
[    0.573633] TCP established hash table entries: 65536 (order: 7, 524288 bytes)
[    0.574062] TCP bind hash table entries: 65536 (order: 8, 1048576 bytes)
[    0.574590] TCP: Hash tables configured (established 65536 bind 65536)
[    0.574707] UDP hash table entries: 4096 (order: 5, 131072 bytes)
[    0.574796] UDP-Lite hash table entries: 4096 (order: 5, 131072 bytes)
[    0.575147] NET: Registered protocol family 1
[    0.575188] pci 0000:00:01.0: Video device with shadowed ROM
[    0.718030] PCI: CLS 32 bytes, default 64
[    0.718165] Unpacking initramfs...
[    1.340620] Freeing initrd memory: 18324K (ffff880035c26000 - ffff880036e0b000)
[    1.340748] PCI-DMA: Using software bounce buffering for IO (SWIOTLB)
[    1.340767] software IO TLB [mem 0xcee20000-0xd2e20000] (64MB) mapped at [ffff8800cee20000-ffff8800d2e1ffff]
[    1.341050] microcode: CPU0: patch_level=0x0500010d
[    1.341065] microcode: CPU1: patch_level=0x0500010d
[    1.341342] microcode: Microcode Update Driver: v2.00 <tigran@aivazian.fsnet.co.uk>, Peter Oruba
[    1.341360] LVT offset 0 assigned for vector 0x400
[    1.341434] perf: AMD IBS detected (0x000000ff)
[    1.342349] futex hash table entries: 1024 (order: 4, 65536 bytes)
[    1.342461] audit: initializing netlink subsys (disabled)
[    1.342506] audit: type=2000 audit(1449954435.044:1): initialized
[    1.343346] HugeTLB registered 2 MB page size, pre-allocated 0 pages
[    1.343400] zbud: loaded
[    1.343787] VFS: Disk quotas dquot_6.6.0
[    1.343848] VFS: Dquot-cache hash table entries: 512 (order 0, 4096 bytes)
[    1.345086] Block layer SCSI generic (bsg) driver version 0.4 loaded (major 250)
[    1.345230] io scheduler noop registered
[    1.345236] io scheduler deadline registered
[    1.345265] io scheduler cfq registered (default)
[    1.346845] pci_hotplug: PCI Hot Plug PCI Core version: 0.5
[    1.346872] pciehp 0000:00:07.0:pcie04: Slot #7 AttnBtn- PwrCtrl- MRL- AttnInd- PwrInd- HotPlug+ Surprise- Interlock- NoCompl+ LLActRep+
[    1.346952] pciehp 0000:00:07.0:pcie04: service driver pciehp loaded
[    1.346964] pciehp: PCI Express Hot Plug Controller Driver version: 0.4
[    1.347071] GHES: HEST is not enabled!
[    1.347317] Serial: 8250/16550 driver, 4 ports, IRQ sharing enabled
[    1.348297] Linux agpgart interface v0.103
[    1.348435] AMD IOMMUv2 driver by Joerg Roedel <jroedel@suse.de>
[    1.348438] AMD IOMMUv2 functionality not available on this system
[    1.349226] i8042: PNP: PS/2 Controller [PNP0303:KBC0,PNP0f13:MSE0] at 0x60,0x64 irq 1,12
[    1.352822] i8042: Detected active multiplexing controller, rev 1.1
[    1.353781] serio: i8042 KBD port at 0x60,0x64 irq 1
[    1.353797] serio: i8042 AUX0 port at 0x60,0x64 irq 12
[    1.353870] serio: i8042 AUX1 port at 0x60,0x64 irq 12
[    1.353931] serio: i8042 AUX2 port at 0x60,0x64 irq 12
[    1.353990] serio: i8042 AUX3 port at 0x60,0x64 irq 12
[    1.354592] mousedev: PS/2 mouse device common for all mice
[    1.354764] rtc_cmos 00:01: RTC can wake from S4
[    1.355093] rtc_cmos 00:01: rtc core: registered rtc_cmos as rtc0
[    1.355157] rtc_cmos 00:01: alarms up to one month, 114 bytes nvram, hpet irqs
[    1.355205] ledtrig-cpu: registered to indicate activity on CPUs
[    1.356057] NET: Registered protocol family 10
[    1.356493] mip6: Mobile IPv6
[    1.356520] NET: Registered protocol family 17
[    1.356534] mpls_gso: MPLS GSO support
[    1.357309] registered taskstats version 1
[    1.357370] zswap: loaded using pool lzo/zbud
[    1.358172] rtc_cmos 00:01: setting system clock to 2015-12-12 21:07:15 UTC (1449954435)
[    1.358307] PM: Hibernation image not present or could not be loaded.
[    1.359244] Freeing unused kernel memory: 1284K (ffffffff81b07000 - ffffffff81c48000)
[    1.359253] Write protecting the kernel read-only data: 10240k
[    1.359965] Freeing unused kernel memory: 660K (ffff88000155b000 - ffff880001600000)
[    1.360915] Freeing unused kernel memory: 1324K (ffff8800018b5000 - ffff880001a00000)
[    1.395474] input: AT Translated Set 2 keyboard as /devices/platform/i8042/serio0/input/input0
[    1.502896] systemd-udevd[68]: starting version 215
[    1.503772] random: systemd-udevd urandom read with 2 bits of entropy available
[    1.550940] r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
[    1.551703] r8169 0000:03:00.0 eth0: RTL8168evl/8111evl at 0xffffc90000018000, 08:9e:01:35:12:25, XID 0c900800 IRQ 25
[    1.551709] r8169 0000:03:00.0 eth0: jumbo features [frames: 9200 bytes, tx checksumming: ko]
[    1.553234] ACPI: bus type USB registered
[    1.553295] usbcore: registered new interface driver usbfs
[    1.553318] usbcore: registered new interface driver hub
[    1.553381] usbcore: registered new device driver usb
[    1.555786] QUIRK: Enable AMD PLL fix
[    1.555840] xhci_hcd 0000:00:10.0: xHCI Host Controller
[    1.555855] xhci_hcd 0000:00:10.0: new USB bus registered, assigned bus number 1
[    1.556069] xhci_hcd 0000:00:10.0: hcc params 0x014042c3 hci version 0x96 quirks 0x00000608
[    1.558273] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
[    1.559017] ohci_hcd: USB 1.1 'Open' Host Controller (OHCI) Driver
[    1.559429] ehci-pci: EHCI PCI platform driver
[    1.561114] usb usb1: New USB device found, idVendor=1d6b, idProduct=0002
[    1.561123] usb usb1: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    1.561128] usb usb1: Product: xHCI Host Controller
[    1.561132] usb usb1: Manufacturer: Linux 4.3.0-trunk-amd64 xhci-hcd
[    1.561135] usb usb1: SerialNumber: 0000:00:10.0
[    1.562384] SCSI subsystem initialized
[    1.565422] rtsx_pci 0000:04:00.0: rtsx_pci_acquire_irq: pcr->msi_en = 1, pci->irq = 29
[    1.566304] libata version 3.00 loaded.
[    1.566648] hub 1-0:1.0: USB hub found
[    1.567410] hub 1-0:1.0: 2 ports detected
[    1.567752] xhci_hcd 0000:00:10.0: xHCI Host Controller
[    1.567763] xhci_hcd 0000:00:10.0: new USB bus registered, assigned bus number 2
[    1.567809] usb usb2: We don't know the algorithms for LPM for this host, disabling LPM.
[    1.568316] usb usb2: New USB device found, idVendor=1d6b, idProduct=0003
[    1.568322] usb usb2: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    1.568325] usb usb2: Product: xHCI Host Controller
[    1.568329] usb usb2: Manufacturer: Linux 4.3.0-trunk-amd64 xhci-hcd
[    1.568333] usb usb2: SerialNumber: 0000:00:10.0
[    1.569128] hub 2-0:1.0: USB hub found
[    1.569164] hub 2-0:1.0: 2 ports detected
[    1.570195] ehci-pci 0000:00:12.2: EHCI Host Controller
[    1.570212] ehci-pci 0000:00:12.2: new USB bus registered, assigned bus number 3
[    1.570222] ehci-pci 0000:00:12.2: applying AMD SB700/SB800/Hudson-2/3 EHCI dummy qh workaround
[    1.570249] ehci-pci 0000:00:12.2: debug port 1
[    1.570317] ehci-pci 0000:00:12.2: irq 17, io mem 0xf0b4d900
[    1.570351] thermal LNXTHERM:00: registered as thermal_zone0
[    1.570359] ACPI: Thermal Zone [THZ0] (61 C)
[    1.581022] ehci-pci 0000:00:12.2: USB 2.0 started, EHCI 1.00
[    1.581195] usb usb3: New USB device found, idVendor=1d6b, idProduct=0002
[    1.581200] usb usb3: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    1.581204] usb usb3: Product: EHCI Host Controller
[    1.581208] usb usb3: Manufacturer: Linux 4.3.0-trunk-amd64 ehci_hcd
[    1.581212] usb usb3: SerialNumber: 0000:00:12.2
[    1.581570] hub 3-0:1.0: USB hub found
[    1.581592] hub 3-0:1.0: 5 ports detected
[    1.582295] ehci-pci 0000:00:13.2: EHCI Host Controller
[    1.582313] ehci-pci 0000:00:13.2: new USB bus registered, assigned bus number 4
[    1.582324] ehci-pci 0000:00:13.2: applying AMD SB700/SB800/Hudson-2/3 EHCI dummy qh workaround
[    1.582338] ehci-pci 0000:00:13.2: debug port 1
[    1.582388] ehci-pci 0000:00:13.2: irq 17, io mem 0xf0b4d800
[    1.593026] ehci-pci 0000:00:13.2: USB 2.0 started, EHCI 1.00
[    1.593144] usb usb4: New USB device found, idVendor=1d6b, idProduct=0002
[    1.593149] usb usb4: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    1.593153] usb usb4: Product: EHCI Host Controller
[    1.593157] usb usb4: Manufacturer: Linux 4.3.0-trunk-amd64 ehci_hcd
[    1.593161] usb usb4: SerialNumber: 0000:00:13.2
[    1.593461] hub 4-0:1.0: USB hub found
[    1.593479] hub 4-0:1.0: 5 ports detected
[    1.594324] ohci-pci: OHCI PCI platform driver
[    1.594712] ohci-pci 0000:00:12.0: OHCI PCI host controller
[    1.594727] ohci-pci 0000:00:12.0: new USB bus registered, assigned bus number 5
[    1.594792] ohci-pci 0000:00:12.0: irq 18, io mem 0xf0b4c000
[    1.653234] usb usb5: New USB device found, idVendor=1d6b, idProduct=0001
[    1.653243] usb usb5: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    1.653247] usb usb5: Product: OHCI PCI host controller
[    1.653251] usb usb5: Manufacturer: Linux 4.3.0-trunk-amd64 ohci_hcd
[    1.653254] usb usb5: SerialNumber: 0000:00:12.0
[    1.653797] hub 5-0:1.0: USB hub found
[    1.653836] hub 5-0:1.0: 5 ports detected
[    1.654451] ahci 0000:00:11.0: version 3.0
[    1.654860] ahci 0000:00:11.0: AHCI 0001.0300 32 slots 1 ports 6 Gbps 0x1 impl SATA mode
[    1.654868] ahci 0000:00:11.0: flags: 64bit ncq sntf ilck pm led clo pmp pio slum part 
[    1.655353] scsi host0: ahci
[    1.655480] ata1: SATA max UDMA/133 abar m2048@0xf0b4d000 port 0xf0b4d100 irq 30
[    1.655903] ohci-pci 0000:00:13.0: OHCI PCI host controller
[    1.655921] ohci-pci 0000:00:13.0: new USB bus registered, assigned bus number 6
[    1.655972] ohci-pci 0000:00:13.0: irq 18, io mem 0xf0b4b000
[    1.713184] usb usb6: New USB device found, idVendor=1d6b, idProduct=0001
[    1.713193] usb usb6: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    1.713197] usb usb6: Product: OHCI PCI host controller
[    1.713201] usb usb6: Manufacturer: Linux 4.3.0-trunk-amd64 ohci_hcd
[    1.713205] usb usb6: SerialNumber: 0000:00:13.0
[    1.713762] hub 6-0:1.0: USB hub found
[    1.713801] hub 6-0:1.0: 5 ports detected
[    1.714496] ohci-pci 0000:00:14.5: OHCI PCI host controller
[    1.714509] ohci-pci 0000:00:14.5: new USB bus registered, assigned bus number 7
[    1.714562] ohci-pci 0000:00:14.5: irq 18, io mem 0xf0b4a000
[    1.773136] usb usb7: New USB device found, idVendor=1d6b, idProduct=0001
[    1.773145] usb usb7: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    1.773150] usb usb7: Product: OHCI PCI host controller
[    1.773153] usb usb7: Manufacturer: Linux 4.3.0-trunk-amd64 ohci_hcd
[    1.773157] usb usb7: SerialNumber: 0000:00:14.5
[    1.773693] hub 7-0:1.0: USB hub found
[    1.773729] hub 7-0:1.0: 2 ports detected
[    2.144800] ata1: SATA link up 6.0 Gbps (SStatus 133 SControl 300)
[    2.146298] ata1.00: READ LOG DMA EXT failed, trying unqueued
[    2.146486] ata1.00: failed to get NCQ Send/Recv Log Emask 0x1
[    2.146495] ata1.00: ATA-9: Samsung SSD 840 PRO Series, DXM06B0Q, max UDMA/133
[    2.146499] ata1.00: 500118192 sectors, multi 16: LBA48 NCQ (depth 31/32), AA
[    2.146831] ata1.00: failed to get NCQ Send/Recv Log Emask 0x1
[    2.146843] ata1.00: configured for UDMA/133
[    2.147422] scsi 0:0:0:0: Direct-Access     ATA      Samsung SSD 840  6B0Q PQ: 0 ANSI: 5
[    2.151457] ata1.00: Enabling discard_zeroes_data
[    2.151582] sd 0:0:0:0: [sda] 500118192 512-byte logical blocks: (256 GB/238 GiB)
[    2.151938] sd 0:0:0:0: [sda] Write Protect is off
[    2.151945] sd 0:0:0:0: [sda] Mode Sense: 00 3a 00 00
[    2.152007] sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[    2.152238] ata1.00: Enabling discard_zeroes_data
[    2.154462]  sda: sda1 sda2 sda3
[    2.155134] ata1.00: Enabling discard_zeroes_data
[    2.155297] sd 0:0:0:0: [sda] Attached SCSI disk
[    2.156391] sd 0:0:0:0: Attached scsi generic sg0 type 0
[    2.164716] usb 6-3: new full-speed USB device number 2 using ohci-pci
[    2.164776] usb 4-4: new high-speed USB device number 3 using ehci-pci
[    2.207146] platform microcode: firmware: direct-loading firmware amd-ucode/microcode_amd.bin
[    2.213141] microcode: CPU0: new patch_level=0x05000119
[    2.219065] microcode: CPU1: new patch_level=0x05000119
[    2.253103] device-mapper: uevent: version 1.0.3
[    2.253636] device-mapper: ioctl: 4.33.0-ioctl (2015-8-18) initialised: dm-devel@redhat.com
[    2.308084] usb 4-4: New USB device found, idVendor=5986, idProduct=0299
[    2.308093] usb 4-4: New USB device strings: Mfr=1, Product=2, SerialNumber=0
[    2.308098] usb 4-4: Product: Integrated Camera
[    2.308101] usb 4-4: Manufacturer: Vimicro corp.
[    2.336441] tsc: Refined TSC clocksource calibration: 1696.914 MHz
[    2.336452] clocksource: tsc: mask: 0xffffffffffffffff max_cycles: 0x1875c420428, max_idle_ns: 440795272528 ns
[    2.338679] usb 6-3: New USB device found, idVendor=0a5c, idProduct=21f3
[    2.338687] usb 6-3: New USB device strings: Mfr=1, Product=2, SerialNumber=3
[    2.338691] usb 6-3: Product: BCM20702A0
[    2.338695] usb 6-3: Manufacturer: Broadcom Corp
[    2.338699] usb 6-3: SerialNumber: 2CD05A80FEA0
[    2.552657] NET: Registered protocol family 38
[    2.586765] sha256_ssse3: Using SSSE3 optimized SHA-256 implementation
[    3.335853] clocksource: Switched to clocksource tsc
[    5.884616] EXT4-fs (dm-1): mounted filesystem with ordered data mode. Opts: (null)
[    6.419521] systemd[1]: Cannot add dependency job for unit NetworkManager.service, ignoring: Unit NetworkManager.service failed to load: No such file or directory.
[    6.419679] systemd[1]: Cannot add dependency job for unit display-manager.service, ignoring: Unit display-manager.service failed to load: No such file or directory.
[    6.527765] lp: driver loaded but no devices found
[    6.537385] ppdev: user-space parallel port driver
[    6.560244] fuse init (API version 7.23)
[    6.573866] loop: module loaded
[    6.588800] systemd-udevd[274]: starting version 215
[    6.954393] ACPI: acpi_idle registered with cpuidle
[    6.962901] acpi-cpufreq: overriding BIOS provided _PSD data
[    6.998527] input: Power Button as /devices/LNXSYSTM:00/LNXSYBUS:00/PNP0C0C:00/input/input5
[    6.998540] ACPI: Power Button [PWRB]
[    6.998683] input: Lid Switch as /devices/LNXSYSTM:00/LNXSYBUS:00/PNP0C0D:00/input/input6
[    6.999419] shpchp: Standard Hot Plug PCI Controller Driver version: 0.4
[    6.999781] ACPI: Lid Switch [LID]
[    6.999921] input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/input/input7
[    6.999929] ACPI: Power Button [PWRF]
[    7.017364] ACPI: Video Device [VGA1] (multi-head: yes  rom: no  post: no)
[    7.017851] [Firmware Bug]: ACPI: No _BQC method, cannot determine initial brightness
[    7.021798] acpi device:3a: registered as cooling_device0
[    7.021955] input: Video Bus as /devices/LNXSYSTM:00/LNXSYBUS:00/PNP0A08:00/LNXVIDEO:01/input/input8
[    7.056824] [drm] Initialized drm 1.1.0 20060810
[    7.089350] Non-volatile memory driver v1.3
[    7.099713] thinkpad_acpi: ThinkPad ACPI Extras v0.25
[    7.099721] thinkpad_acpi: http://ibm-acpi.sf.net/
[    7.099724] thinkpad_acpi: ThinkPad BIOS HMET93WW (2.53 ), EC unknown
[    7.099727] thinkpad_acpi: Lenovo ThinkPad Edge E135, model 335963G
[    7.100015] ACPI: Battery Slot [BAT1] (battery present)
[    7.100653] ACPI: AC Adapter [ACAD] (off-line)
[    7.101068] thinkpad_acpi: Unsupported brightness interface, please contact ibm-acpi-devel@lists.sourceforge.net
[    7.101523] wmi: Mapper loaded
[    7.102166] thinkpad_acpi: radio switch found; radios are enabled
[    7.102183] thinkpad_acpi: possible tablet mode switch found; ThinkPad in laptop mode
[    7.102212] thinkpad_acpi: This ThinkPad has standard ACPI backlight brightness control, supported by the ACPI video driver
[    7.102215] thinkpad_acpi: Disabling thinkpad-acpi brightness events by default...
[    7.109099] thinkpad_acpi: rfkill switch tpacpi_bluetooth_sw: radio is unblocked
[    7.127163] input: ThinkPad Extra Buttons as /devices/platform/thinkpad_acpi/input/input9
[    7.171322] input: HD-Audio Generic HDMI/DP,pcm=3 as /devices/pci0000:00/0000:00:01.1/sound/card0/input10
[    7.179763] ACPI Warning: SystemIO range 0x0000000000000B00-0x0000000000000B07 conflicts with OpRegion 0x0000000000000B00-0x0000000000000B0F (\_SB_.PCI0.SMB_.SMB0) (20150818/utaddress-254)
[    7.179780] ACPI: If an ACPI driver is available for this device, you should use it instead of the native driver
[    7.192728] bcma: bus0: Found chip with id 43228, rev 0x00 and package 0x08
[    7.192759] bcma: bus0: Core 0 found: ChipCommon (manuf 0x4BF, id 0x800, rev 0x25, class 0x0)
[    7.192780] bcma: bus0: Core 1 found: IEEE 802.11 (manuf 0x4BF, id 0x812, rev 0x1E, class 0x0)
[    7.192863] bcma: bus0: Core 2 found: PCIe (manuf 0x4BF, id 0x820, rev 0x12, class 0x0)
[    7.192883] bcma: bus0: Core 3 found: SDIO Device (manuf 0x4BF, id 0x829, rev 0x07, class 0x0)
[    7.201961] snd_hda_codec_realtek hdaudioC1D0: autoconfig for ALC269VC: line_outs=1 (0x14/0x0/0x0/0x0/0x0) type:speaker
[    7.201971] snd_hda_codec_realtek hdaudioC1D0:    speaker_outs=0 (0x0/0x0/0x0/0x0/0x0)
[    7.201976] snd_hda_codec_realtek hdaudioC1D0:    hp_outs=1 (0x15/0x0/0x0/0x0/0x0)
[    7.201980] snd_hda_codec_realtek hdaudioC1D0:    mono: mono_out=0x0
[    7.201984] snd_hda_codec_realtek hdaudioC1D0:    inputs:
[    7.201989] snd_hda_codec_realtek hdaudioC1D0:      Mic=0x18
[    7.201993] snd_hda_codec_realtek hdaudioC1D0:      Internal Mic=0x12
[    7.213135] bcma: bus0: Bus registered
[    7.282615] input: HDA Digital PCBeep as /devices/pci0000:00/0000:00:14.2/sound/card1/input11
[    7.283426] input: HD-Audio Generic Mic as /devices/pci0000:00/0000:00:14.2/sound/card1/input12
[    7.283498] input: HD-Audio Generic Headphone as /devices/pci0000:00/0000:00:14.2/sound/card1/input13
[    7.319365] [drm] radeon kernel modesetting enabled.
[    7.346639] input: PC Speaker as /devices/platform/pcspkr/input/input15
[    7.358472] CRAT table not found
[    7.358480] Finished initializing topology ret=0
[    7.359345] kfd kfd: Initialized module
[    7.363748] [drm] initializing kernel modesetting (PALM 0x1002:0x9808 0x17AA:0x5105).
[    7.363786] [drm] register mmio base: 0xF0B00000
[    7.363789] [drm] register mmio size: 262144
[    7.363886] ATOM BIOS: Lenovo
[    7.363967] radeon 0000:00:01.0: VRAM: 384M 0x0000000000000000 - 0x0000000017FFFFFF (384M used)
[    7.363973] radeon 0000:00:01.0: GTT: 1024M 0x0000000018000000 - 0x0000000057FFFFFF
[    7.363977] [drm] Detected VRAM RAM=384M, BAR=256M
[    7.363979] [drm] RAM width 32bits DDR
[    7.364103] [TTM] Zone  kernel: Available graphics memory: 3781862 kiB
[    7.364107] [TTM] Zone   dma32: Available graphics memory: 2097152 kiB
[    7.364109] [TTM] Initializing pool allocator
[    7.364119] [TTM] Initializing DMA pool allocator
[    7.364163] [drm] radeon: 384M of VRAM memory ready
[    7.364166] [drm] radeon: 1024M of GTT memory ready.
[    7.364188] [drm] Loading PALM Microcode
[    7.372900] radeon 0000:00:01.0: firmware: direct-loading firmware radeon/PALM_pfp.bin
[    7.374037] radeon 0000:00:01.0: firmware: direct-loading firmware radeon/PALM_me.bin
[    7.374327] radeon 0000:00:01.0: firmware: direct-loading firmware radeon/SUMO_rlc.bin
[    7.374337] [drm] Internal thermal controller without fan control
[    7.374441] [drm] Found smc ucode version: 0x00010601
[    7.374527] [drm] radeon: dpm initialized
[    7.380105] radeon 0000:00:01.0: firmware: direct-loading firmware radeon/SUMO_uvd.bin
[    7.380203] [drm] GART: num cpu pages 262144, num gpu pages 262144
[    7.435297] [drm] PCIE GART of 1024M enabled (table at 0x0000000000274000).
[    7.437223] radeon 0000:00:01.0: WB enabled
[    7.437234] radeon 0000:00:01.0: fence driver on ring 0 use gpu addr 0x0000000018000c00 and cpu addr 0xffff8800ceb68c00
[    7.437240] radeon 0000:00:01.0: fence driver on ring 3 use gpu addr 0x0000000018000c0c and cpu addr 0xffff8800ceb68c0c
[    7.438010] radeon 0000:00:01.0: fence driver on ring 5 use gpu addr 0x0000000000072118 and cpu addr 0xffffc90001432118
[    7.438015] [drm] Supports vblank timestamp caching Rev 2 (21.10.2013).
[    7.438017] [drm] Driver supports precise vblank timestamp query.
[    7.438021] radeon 0000:00:01.0: radeon: MSI limited to 32-bit
[    7.438388] radeon 0000:00:01.0: radeon: using MSI.
[    7.438436] [drm] radeon: irq initialized.
[    7.448639] kvm: Nested Virtualization enabled
[    7.448652] kvm: Nested Paging enabled
[    7.457866] [drm] ring test on 0 succeeded in 1 usecs
[    7.457881] [drm] ring test on 3 succeeded in 2 usecs
[    7.510167] [drm] ring test on 5 succeeded in 1 usecs
[    7.534030] [drm] UVD initialized successfully.
[    7.537296] random: nonblocking pool is initialized
[    7.539923] [drm] ib test on ring 0 succeeded in 0 usecs
[    7.540049] [drm] ib test on ring 3 succeeded in 0 usecs
[    7.595788] EXT4-fs (dm-1): re-mounted. Opts: discard,errors=remount-ro
[    7.967304] EXT4-fs (dm-3): mounted filesystem with ordered data mode. Opts: discard
[    8.008079] psmouse serio4: synaptics: queried max coordinates: x [..5768], y [..5236]
[    8.021305] EXT4-fs (dm-2): mounted filesystem with ordered data mode. Opts: discard
[    8.054993] psmouse serio4: synaptics: queried min coordinates: x [1172..], y [616..]
[    8.056597] [drm] ib test on ring 5 succeeded
[    8.118453] EXT4-fs (dm-5): mounted filesystem with ordered data mode. Opts: discard
[    8.139790] psmouse serio4: synaptics: Touchpad model: 1, fw: 8.1, id: 0x1e2b1, caps: 0xd002a3/0x940300/0x126c00/0x0, board id: 2290, fw id: 1212745
[    8.139817] psmouse serio4: synaptics: serio: Synaptics pass-through port at isa0060/serio4/input0
[    8.182433] input: SynPS/2 Synaptics TouchPad as /devices/platform/i8042/serio4/input/input18
[    8.200102] [drm] radeon atom DIG backlight initialized
[    8.200116] [drm] Radeon Display Connectors
[    8.200119] [drm] Connector 0:
[    8.200122] [drm]   LVDS-1
[    8.200125] [drm]   HPD1
[    8.200130] [drm]   DDC: 0x6430 0x6430 0x6434 0x6434 0x6438 0x6438 0x643c 0x643c
[    8.200132] [drm]   Encoders:
[    8.200134] [drm]     LCD1: INTERNAL_UNIPHY
[    8.200138] [drm] Connector 1:
[    8.200140] [drm]   HDMI-A-1
[    8.200142] [drm]   HPD2
[    8.200145] [drm]   DDC: 0x6440 0x6440 0x6444 0x6444 0x6448 0x6448 0x644c 0x644c
[    8.200147] [drm]   Encoders:
[    8.200149] [drm]     DFP1: INTERNAL_UNIPHY
[    8.200151] [drm] Connector 2:
[    8.200153] [drm]   VGA-1
[    8.200157] [drm]   DDC: 0x64d8 0x64d8 0x64dc 0x64dc 0x64e0 0x64e0 0x64e4 0x64e4
[    8.200159] [drm]   Encoders:
[    8.200161] [drm]     CRT1: INTERNAL_KLDSCP_DAC1
[    8.202959] EXT4-fs (dm-4): mounted filesystem with ordered data mode. Opts: discard
[    8.206166] b43-phy0: Broadcom 43228 WLAN found (core revision 30)
[    8.206624] b43-phy0: Found PHY: Analog 9, Type 4 (N), Revision 16
[    8.206634] b43-phy0: Found Radio: Manuf 0x17F, ID 0x2057, Revision 9, Version 1
[    8.207287] Broadcom 43xx driver loaded [ Features: PMNLS ]
[    8.212287] b43 bcma0:1: firmware: direct-loading firmware b43/ucode30_mimo.fw
[    8.217056] b43 bcma0:1: firmware: direct-loading firmware b43/n16initvals30.fw
[    8.224342] b43 bcma0:1: firmware: direct-loading firmware b43/n16bsinitvals30.fw
[    8.276239] ieee80211 phy0: Selected rate control algorithm 'minstrel_ht'
[    8.286686] cfg80211: World regulatory domain updated:
[    8.286698] cfg80211:  DFS Master region: unset
[    8.286702] cfg80211:   (start_freq - end_freq @ bandwidth), (max_antenna_gain, max_eirp), (dfs_cac_time)
[    8.286708] cfg80211:   (2402000 KHz - 2472000 KHz @ 40000 KHz), (N/A, 2000 mBm), (N/A)
[    8.286712] cfg80211:   (2457000 KHz - 2482000 KHz @ 40000 KHz), (N/A, 2000 mBm), (N/A)
[    8.286716] cfg80211:   (2474000 KHz - 2494000 KHz @ 20000 KHz), (N/A, 2000 mBm), (N/A)
[    8.286720] cfg80211:   (5170000 KHz - 5250000 KHz @ 80000 KHz, 160000 KHz AUTO), (N/A, 2000 mBm), (N/A)
[    8.286724] cfg80211:   (5250000 KHz - 5330000 KHz @ 80000 KHz, 160000 KHz AUTO), (N/A, 2000 mBm), (0 s)
[    8.286728] cfg80211:   (5490000 KHz - 5730000 KHz @ 160000 KHz), (N/A, 2000 mBm), (0 s)
[    8.286732] cfg80211:   (5735000 KHz - 5835000 KHz @ 80000 KHz), (N/A, 2000 mBm), (N/A)
[    8.286735] cfg80211:   (57240000 KHz - 63720000 KHz @ 2160000 KHz), (N/A, 0 mBm), (N/A)
[    8.313665] cfg80211: Regulatory domain changed to country: DE
[    8.313676] cfg80211:  DFS Master region: ETSI
[    8.313680] cfg80211:   (start_freq - end_freq @ bandwidth), (max_antenna_gain, max_eirp), (dfs_cac_time)
[    8.313685] cfg80211:   (2400000 KHz - 2483500 KHz @ 40000 KHz), (N/A, 2000 mBm), (N/A)
[    8.313690] cfg80211:   (5150000 KHz - 5250000 KHz @ 80000 KHz, 200000 KHz AUTO), (N/A, 2000 mBm), (N/A)
[    8.313694] cfg80211:   (5250000 KHz - 5350000 KHz @ 80000 KHz, 200000 KHz AUTO), (N/A, 2000 mBm), (0 s)
[    8.313698] cfg80211:   (5470000 KHz - 5725000 KHz @ 160000 KHz), (N/A, 2698 mBm), (0 s)
[    8.313702] cfg80211:   (57000000 KHz - 66000000 KHz @ 2160000 KHz), (N/A, 4000 mBm), (N/A)
[    8.424197] systemd-journald[304]: Received request to flush runtime journal from PID 1
[    8.537682] ip_tables: (C) 2000-2006 Netfilter Core Team
[    8.573937] nf_conntrack version 0.5.0 (65536 buckets, 262144 max)
[    8.626436] [drm] fb mappable at 0xE0478000
[    8.626445] [drm] vram apper at 0xE0000000
[    8.626448] [drm] size 4325376
[    8.626451] [drm] fb depth is 24
[    8.626453] [drm]    pitch is 5632
[    8.628405] media: Linux media interface: v0.10
[    8.629256] fbcon: radeondrmfb (fb0) is primary device
[    8.651320] Linux video capture interface: v2.00
[    8.706945] Bluetooth: Core ver 2.20
[    8.706979] NET: Registered protocol family 31
[    8.706980] Bluetooth: HCI device and connection manager initialized
[    8.707361] Bluetooth: HCI socket layer initialized
[    8.707367] Bluetooth: L2CAP socket layer initialized
[    8.707383] Bluetooth: SCO socket layer initialized
[    8.723106] usbcore: registered new interface driver btusb
[    8.736982] Bluetooth: hci0: BCM: chip id 63
[    8.738995] Bluetooth: hci0: BCM20702A1 (001.002.014) build 0000
[    8.739460] bluetooth hci0: firmware: failed to load brcm/BCM20702A1-0a5c-21f3.hcd (-2)
[    8.739464] bluetooth hci0: Direct firmware load for brcm/BCM20702A1-0a5c-21f3.hcd failed with error -2
[    8.739468] Bluetooth: hci0: BCM: Patch brcm/BCM20702A1-0a5c-21f3.hcd not found
[    8.764952] uvcvideo: Found UVC 1.00 device Integrated Camera (5986:0299)
[    8.768197] input: Integrated Camera as /devices/pci0000:00/0000:00:13.2/usb4/4-4/4-4:1.0/input/input20
[    8.768533] usbcore: registered new interface driver uvcvideo
[    8.768534] USB Video Class driver (1.1.1)
[    8.802826] ip6_tables: (C) 2000-2006 Netfilter Core Team
[    9.205070] r8169 0000:03:00.0 eth0: rtl_counters_cond == 1 (loop: 1000, delay: 10).
[    9.216980] Console: switching to colour frame buffer device 170x48
[    9.223431] radeon 0000:00:01.0: fb0: radeondrmfb frame buffer device
[    9.240386] [drm] Initialized radeon 2.43.0 20080528 for 0000:00:01.0 on minor 0
[    9.312672] RPC: Registered named UNIX socket transport module.
[    9.312683] RPC: Registered udp transport module.
[    9.312685] RPC: Registered tcp transport module.
[    9.312688] RPC: Registered tcp NFSv4.1 backchannel transport module.
[    9.324269] FS-Cache: Loaded
[    9.351097] FS-Cache: Netfs 'nfs' registered for caching
[    9.381813] Installing knfsd (copyright (C) 1996 okir@monad.swb.de).
[   10.016983] Bluetooth: BNEP (Ethernet Emulation) ver 1.3
[   10.016993] Bluetooth: BNEP filters: protocol multicast
[   10.017005] Bluetooth: BNEP socket layer initialized
[   11.688807] r8169 0000:03:00.0 eth0: rtl_counters_cond == 1 (loop: 1000, delay: 10).
[   12.586874] r8169 0000:03:00.0 eth0: rtl_eriar_cond == 1 (loop: 100, delay: 100).
[   12.935385] psmouse serio5: trackpoint: IBM TrackPoint firmware: 0x0e, buttons: 3/3
[   13.159281] input: TPPS/2 IBM TrackPoint as /devices/platform/i8042/serio4/serio5/input/input19
[   36.987435] r8169 0000:03:00.0 eth0: rtl_counters_cond == 1 (loop: 1000, delay: 10).
[   37.102262] r8169 0000:03:00.0 eth0: rtl_counters_cond == 1 (loop: 1000, delay: 10).
[   67.147773] r8169 0000:03:00.0 eth0: rtl_eriar_cond == 1 (loop: 100, delay: 100).
[   67.161132] r8169 0000:03:00.0 eth0: rtl_eriar_cond == 1 (loop: 100, delay: 100).
[   67.174505] r8169 0000:03:00.0 eth0: rtl_eriar_cond == 1 (loop: 100, delay: 100).
[   67.187867] r8169 0000:03:00.0 eth0: rtl_eriar_cond == 1 (loop: 100, delay: 100).
[   67.232408] r8169 0000:03:00.0 eth0: rtl_counters_cond == 1 (loop: 1000, delay: 10).
[   67.250810] r8169 0000:03:00.0: firmware: direct-loading firmware rtl_nic/rtl8168e-3.fw
[   67.350455] r8169 0000:03:00.0 eth0: link down
[   67.350581] IPv6: ADDRCONF(NETDEV_UP): eth0: link is not ready
[   69.671259] r8169 0000:03:00.0 eth0: link up
[   69.671293] IPv6: ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready

--nextPart5036767.aVcEzaX8ML
Content-Disposition: attachment; filename="dmesg_power"
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="UTF-8"; name="dmesg_withpowersupply.txt"

[    0.000000] Initializing cgroup subsys cpuset
[    0.000000] Initializing cgroup subsys cpu
[    0.000000] Initializing cgroup subsys cpuacct
[    0.000000] Linux version 4.3.0-trunk-amd64 (debian-kernel@lists.debian.org) (gcc version 5.2.1 20151028 (Debian 5.2.1-23) ) #1 SMP Debian 4.3-1~exp1 (2015-11-04)
[    0.000000] Command line: BOOT_IMAGE=/boot/vmlinuz-4.3.0-trunk-amd64 root=/dev/mapper/fuchs--vg-root ro quiet
[    0.000000] tseg: 00dfc00000
[    0.000000] x86/fpu: Legacy x87 FPU detected.
[    0.000000] x86/fpu: Using 'lazy' FPU context switches.
[    0.000000] e820: BIOS-provided physical RAM map:
[    0.000000] BIOS-e820: [mem 0x0000000000000000-0x000000000009e7ff] usable
[    0.000000] BIOS-e820: [mem 0x000000000009e800-0x000000000009ffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000000e0000-0x00000000000fffff] reserved
[    0.000000] BIOS-e820: [mem 0x0000000000100000-0x00000000d2e1ffff] usable
[    0.000000] BIOS-e820: [mem 0x00000000d2e20000-0x00000000ded02fff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000ded03000-0x00000000dee32fff] ACPI NVS
[    0.000000] BIOS-e820: [mem 0x00000000dee33000-0x00000000deeb2fff] ACPI data
[    0.000000] BIOS-e820: [mem 0x00000000deeb3000-0x00000000dfffffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000fec00000-0x00000000fecfffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000fed80000-0x00000000fed80fff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000ffc00000-0x00000000ffffffff] reserved
[    0.000000] BIOS-e820: [mem 0x0000000100000000-0x0000000206ffffff] usable
[    0.000000] NX (Execute Disable) protection: active
[    0.000000] SMBIOS 2.7 present.
[    0.000000] DMI: LENOVO 335963G/335963G, BIOS HMET93WW (2.53 ) 07/11/2013
[    0.000000] e820: update [mem 0x00000000-0x00000fff] usable ==> reserved
[    0.000000] e820: remove [mem 0x000a0000-0x000fffff] usable
[    0.000000] e820: last_pfn = 0x207000 max_arch_pfn = 0x400000000
[    0.000000] MTRR default type: uncachable
[    0.000000] MTRR fixed ranges enabled:
[    0.000000]   00000-9FFFF write-back
[    0.000000]   A0000-BFFFF uncachable
[    0.000000]   C0000-FFFFF write-protect
[    0.000000] MTRR variable ranges enabled:
[    0.000000]   0 base 000000000 mask F80000000 write-back
[    0.000000]   1 base 080000000 mask FC0000000 write-back
[    0.000000]   2 base 0C0000000 mask FE0000000 write-back
[    0.000000]   3 base 207000000 mask FFF000000 uncachable
[    0.000000]   4 base 208000000 mask FF8000000 uncachable
[    0.000000]   5 base 0FED80000 mask FFFFFF000 uncachable
[    0.000000]   6 disabled
[    0.000000]   7 base 0FFC00000 mask FFFC00000 write-protect
[    0.000000] TOM2: 000000021f000000 aka 8688M
[    0.000000] x86/PAT: Configuration [0-7]: WB  WC  UC- UC  WB  WC  UC- WT  
[    0.000000] e820: last_pfn = 0xd2e20 max_arch_pfn = 0x400000000
[    0.000000] found SMP MP-table at [mem 0x000fa8f0-0x000fa8ff] mapped at [ffff8800000fa8f0]
[    0.000000] Base memory trampoline at [ffff880000098000] 98000 size 24576
[    0.000000] Using GB pages for direct mapping
[    0.000000] init_memory_mapping: [mem 0x00000000-0x000fffff]
[    0.000000]  [mem 0x00000000-0x000fffff] page 4k
[    0.000000] BRK [0x01d20000, 0x01d20fff] PGTABLE
[    0.000000] BRK [0x01d21000, 0x01d21fff] PGTABLE
[    0.000000] BRK [0x01d22000, 0x01d22fff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0x206e00000-0x206ffffff]
[    0.000000]  [mem 0x206e00000-0x206ffffff] page 2M
[    0.000000] BRK [0x01d23000, 0x01d23fff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0x200000000-0x206dfffff]
[    0.000000]  [mem 0x200000000-0x206dfffff] page 2M
[    0.000000] init_memory_mapping: [mem 0x1e0000000-0x1ffffffff]
[    0.000000]  [mem 0x1e0000000-0x1ffffffff] page 1G
[    0.000000] init_memory_mapping: [mem 0x00100000-0xd2e1ffff]
[    0.000000]  [mem 0x00100000-0x001fffff] page 4k
[    0.000000]  [mem 0x00200000-0x3fffffff] page 2M
[    0.000000]  [mem 0x40000000-0xbfffffff] page 1G
[    0.000000]  [mem 0xc0000000-0xd2dfffff] page 2M
[    0.000000]  [mem 0xd2e00000-0xd2e1ffff] page 4k
[    0.000000] init_memory_mapping: [mem 0x100000000-0x1dfffffff]
[    0.000000]  [mem 0x100000000-0x1dfffffff] page 1G
[    0.000000] RAMDISK: [mem 0x35c26000-0x36e0afff]
[    0.000000] ACPI: Early table checksum verification disabled
[    0.000000] ACPI: RSDP 0x00000000000F0120 000024 (v02 LENOVO)
[    0.000000] ACPI: XSDT 0x00000000DEEB2170 00008C (v01 LENOVO TP-HM    06040000 PTL  00000002)
[    0.000000] ACPI: FACP 0x00000000DEE9F000 00010C (v05 LENOVO TP-HM    00002530 PTL  00000002)
[    0.000000] ACPI: DSDT 0x00000000DEEA1000 010AF4 (v01 LENOVO AMD      00001000 INTL 20061109)
[    0.000000] ACPI: FACS 0x00000000DEE1A000 000040
[    0.000000] ACPI: HPET 0x00000000DEE9E000 000038 (v01 LENOVO TP-HM    00002530 PTL  00000002)
[    0.000000] ACPI: APIC 0x00000000DEE9D000 00007A (v02 LENOVO TP-HM    00002530 PTL  00000002)
[    0.000000] ACPI: MCFG 0x00000000DEE9C000 00003C (v01 LENOVO TP-HM    00002530 PTL  00000002)
[    0.000000] ACPI: SBST 0x00000000DEE9B000 000030 (v01 LENOVO TP-HM    00002530 PTL  00000002)
[    0.000000] ACPI: FPDT 0x00000000DEE9A000 000064 (v01 LENOVO TP-HM    00002530 PTL  00000002)
[    0.000000] ACPI: UEFI 0x00000000DEE99000 00003E (v01 LENOVO TP-HM    00002530 PTL  00000002)
[    0.000000] ACPI: UEFI 0x00000000DEE98000 000042 (v01 PTL    COMBUF   00000001 PTL  00000001)
[    0.000000] ACPI: POAT 0x00000000DEDF5000 000055 (v03 LENOVO TP-HM    00002530 PTL  00000002)
[    0.000000] ACPI: SSDT 0x00000000DEE97000 0003DE (v01 AMD    POWERNOW 00000001 AMD  00000001)
[    0.000000] ACPI: SSDT 0x00000000DEE95000 0016E4 (v02 AMD    ALIB     00000001 MSFT 04000000)
[    0.000000] ACPI: UEFI 0x00000000DEE94000 000292 (v01 LENOVO TP-HM    00002530 PTL  00000002)
[    0.000000] ACPI: DBG2 0x00000000DEE93000 00006B (v00 LENOVO TP-HM    00002530 PTL  00000002)
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] No NUMA configuration found
[    0.000000] Faking a node at [mem 0x0000000000000000-0x0000000206ffffff]
[    0.000000] NODE_DATA(0) allocated [mem 0x206ffa000-0x206ffdfff]
[    0.000000]  [ffffea0000000000-ffffea00081fffff] PMD -> [ffff8801fee00000-ffff8802065fffff] on node 0
[    0.000000] Zone ranges:
[    0.000000]   DMA      [mem 0x0000000000001000-0x0000000000ffffff]
[    0.000000]   DMA32    [mem 0x0000000001000000-0x00000000ffffffff]
[    0.000000]   Normal   [mem 0x0000000100000000-0x0000000206ffffff]
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x0000000000001000-0x000000000009dfff]
[    0.000000]   node   0: [mem 0x0000000000100000-0x00000000d2e1ffff]
[    0.000000]   node   0: [mem 0x0000000100000000-0x0000000206ffffff]
[    0.000000] Initmem setup node 0 [mem 0x0000000000001000-0x0000000206ffffff]
[    0.000000] On node 0 totalpages: 1940925
[    0.000000]   DMA zone: 64 pages used for memmap
[    0.000000]   DMA zone: 21 pages reserved
[    0.000000]   DMA zone: 3997 pages, LIFO batch:0
[    0.000000]   DMA32 zone: 13433 pages used for memmap
[    0.000000]   DMA32 zone: 859680 pages, LIFO batch:31
[    0.000000]   Normal zone: 16832 pages used for memmap
[    0.000000]   Normal zone: 1077248 pages, LIFO batch:31
[    0.000000] ACPI: PM-Timer IO Port: 0x808
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x00] high edge lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x01] high edge lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x02] high edge lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x03] high edge lint[0x1])
[    0.000000] IOAPIC[0]: apic_id 2, version 33, address 0xfec00000, GSI 0-23
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
[    0.000000] ACPI: IRQ0 used by override.
[    0.000000] ACPI: IRQ9 used by override.
[    0.000000] Using ACPI (MADT) for SMP configuration information
[    0.000000] ACPI: HPET id: 0x43538210 base: 0xfed00000
[    0.000000] smpboot: Allowing 4 CPUs, 2 hotplug CPUs
[    0.000000] PM: Registered nosave memory: [mem 0x00000000-0x00000fff]
[    0.000000] PM: Registered nosave memory: [mem 0x0009e000-0x0009efff]
[    0.000000] PM: Registered nosave memory: [mem 0x0009f000-0x0009ffff]
[    0.000000] PM: Registered nosave memory: [mem 0x000a0000-0x000dffff]
[    0.000000] PM: Registered nosave memory: [mem 0x000e0000-0x000fffff]
[    0.000000] PM: Registered nosave memory: [mem 0xd2e20000-0xded02fff]
[    0.000000] PM: Registered nosave memory: [mem 0xded03000-0xdee32fff]
[    0.000000] PM: Registered nosave memory: [mem 0xdee33000-0xdeeb2fff]
[    0.000000] PM: Registered nosave memory: [mem 0xdeeb3000-0xdfffffff]
[    0.000000] PM: Registered nosave memory: [mem 0xe0000000-0xfebfffff]
[    0.000000] PM: Registered nosave memory: [mem 0xfec00000-0xfecfffff]
[    0.000000] PM: Registered nosave memory: [mem 0xfed00000-0xfed7ffff]
[    0.000000] PM: Registered nosave memory: [mem 0xfed80000-0xfed80fff]
[    0.000000] PM: Registered nosave memory: [mem 0xfed81000-0xffbfffff]
[    0.000000] PM: Registered nosave memory: [mem 0xffc00000-0xffffffff]
[    0.000000] e820: [mem 0xe0000000-0xfebfffff] available for PCI devices
[    0.000000] Booting paravirtualized kernel on bare hardware
[    0.000000] clocksource: refined-jiffies: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 7645519600211568 ns
[    0.000000] setup_percpu: NR_CPUS:512 nr_cpumask_bits:512 nr_cpu_ids:4 nr_node_ids:1
[    0.000000] PERCPU: Embedded 32 pages/cpu @ffff880206c00000 s92952 r8192 d29928 u524288
[    0.000000] pcpu-alloc: s92952 r8192 d29928 u524288 alloc=1*2097152
[    0.000000] pcpu-alloc: [0] 0 1 2 3 
[    0.000000] Built 1 zonelists in Node order, mobility grouping on.  Total pages: 1910575
[    0.000000] Policy zone: Normal
[    0.000000] Kernel command line: BOOT_IMAGE=/boot/vmlinuz-4.3.0-trunk-amd64 root=/dev/mapper/fuchs--vg-root ro quiet
[    0.000000] PID hash table entries: 4096 (order: 3, 32768 bytes)
[    0.000000] Calgary: detecting Calgary via BIOS EBDA area
[    0.000000] Calgary: Unable to locate Rio Grande table in EBDA - bailing!
[    0.000000] Memory: 7542112K/7763700K available (5474K kernel code, 1047K rwdata, 2772K rodata, 1284K init, 836K bss, 221588K reserved, 0K cma-reserved)
[    0.000000] Hierarchical RCU implementation.
[    0.000000] 	Build-time adjustment of leaf fanout to 64.
[    0.000000] 	RCU restricting CPUs from NR_CPUS=512 to nr_cpu_ids=4.
[    0.000000] RCU: Adjusting geometry for rcu_fanout_leaf=64, nr_cpu_ids=4
[    0.000000] NR_IRQS:33024 nr_irqs:456 16
[    0.000000] spurious 8259A interrupt: IRQ7.
[    0.000000] Console: colour VGA+ 80x25
[    0.000000] console [tty0] enabled
[    0.000000] clocksource: hpet: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 133484873504 ns
[    0.000000] hpet clockevent registered
[    0.000000] tsc: Fast TSC calibration using PIT
[    0.000000] tsc: Detected 1696.907 MHz processor
[    0.000057] Calibrating delay loop (skipped), value calculated using timer frequency.. 3393.81 BogoMIPS (lpj=6787628)
[    0.000064] pid_max: default: 32768 minimum: 301
[    0.000084] ACPI: Core revision 20150818
[    0.029177] ACPI: 3 ACPI AML tables successfully acquired and loaded
[    0.029254] Security Framework initialized
[    0.029260] Yama: disabled by default; enable with sysctl kernel.yama.*
[    0.029276] AppArmor: AppArmor disabled by boot time parameter
[    0.030479] Dentry cache hash table entries: 1048576 (order: 11, 8388608 bytes)
[    0.035684] Inode-cache hash table entries: 524288 (order: 10, 4194304 bytes)
[    0.037999] Mount-cache hash table entries: 16384 (order: 5, 131072 bytes)
[    0.038024] Mountpoint-cache hash table entries: 16384 (order: 5, 131072 bytes)
[    0.038594] Initializing cgroup subsys io
[    0.038613] Initializing cgroup subsys memory
[    0.038629] Initializing cgroup subsys devices
[    0.038635] Initializing cgroup subsys freezer
[    0.038642] Initializing cgroup subsys net_cls
[    0.038649] Initializing cgroup subsys perf_event
[    0.038656] Initializing cgroup subsys net_prio
[    0.038701] CPU: Physical Processor ID: 0
[    0.038705] CPU: Processor Core ID: 0
[    0.038708] mce: CPU supports 6 MCE banks
[    0.038727] Last level iTLB entries: 4KB 512, 2MB 8, 4MB 4
[    0.038729] Last level dTLB entries: 4KB 512, 2MB 8, 4MB 4, 1GB 0
[    0.039453] Freeing SMP alternatives memory: 20K (ffffffff81c48000 - ffffffff81c4d000)
[    0.059310] ftrace: allocating 23497 entries in 92 pages
[    0.263024] ..TIMER: vector=0x30 apic1=0 pin1=2 apic2=-1 pin2=-1
[    0.406928] smpboot: CPU0: AMD E2-1800 APU with Radeon(tm) HD Graphics (family: 0x14, model: 0x2, stepping: 0x0)
[    0.406977] Performance Events: AMD PMU driver.
[    0.406985] ... version:                0
[    0.406988] ... bit width:              48
[    0.406990] ... generic registers:      4
[    0.406993] ... value mask:             0000ffffffffffff
[    0.406995] ... max period:             00007fffffffffff
[    0.406997] ... fixed-purpose events:   0
[    0.407000] ... event mask:             000000000000000f
[    0.407991] NMI watchdog: enabled on all CPUs, permanently consumes one hw-PMU counter.
[    0.408223] x86: Booting SMP configuration:
[    0.408227] .... node  #0, CPUs:      #1
[    0.421285] x86: Booted up 1 node, 2 CPUs
[    0.421290] smpboot: Total of 2 processors activated (6787.62 BogoMIPS)
[    0.422067] devtmpfs: initialized
[    0.429223] PM: Registering ACPI NVS region [mem 0xded03000-0xdee32fff] (1245184 bytes)
[    0.429463] clocksource: jiffies: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 7645041785100000 ns
[    0.429763] pinctrl core: initialized pinctrl subsystem
[    0.433076] NET: Registered protocol family 16
[    0.443110] cpuidle: using governor ladder
[    0.455101] cpuidle: using governor menu
[    0.455390] ACPI: bus type PCI registered
[    0.455396] acpiphp: ACPI Hot Plug PCI Controller Driver version: 0.5
[    0.455645] PCI: MMCONFIG for domain 0000 [bus 00-3f] at [mem 0xf8000000-0xfbffffff] (base 0xf8000000)
[    0.455650] PCI: not using MMCONFIG
[    0.455653] PCI: Using configuration type 1 for base access
[    0.455655] PCI: Using configuration type 1 for extended access
[    0.456160] mtrr: your CPUs had inconsistent variable MTRR settings
[    0.456163] mtrr: probably your BIOS does not setup all CPUs.
[    0.456165] mtrr: corrected configuration.
[    0.468415] ACPI: Added _OSI(Module Device)
[    0.468422] ACPI: Added _OSI(Processor Device)
[    0.468425] ACPI: Added _OSI(3.0 _SCP Extensions)
[    0.468428] ACPI: Added _OSI(Processor Aggregator Device)
[    0.479888] [Firmware Bug]: ACPI: BIOS _OSI(Linux) query ignored
[    0.480835] ACPI : EC: EC started
[    0.484561] ACPI: Interpreter enabled
[    0.484583] ACPI Exception: AE_NOT_FOUND, While evaluating Sleep State [\_S1_] (20150818/hwxface-580)
[    0.484593] ACPI Exception: AE_NOT_FOUND, While evaluating Sleep State [\_S2_] (20150818/hwxface-580)
[    0.484623] ACPI: (supports S0 S3 S4 S5)
[    0.484627] ACPI: Using IOAPIC for interrupt routing
[    0.484906] PCI: MMCONFIG for domain 0000 [bus 00-3f] at [mem 0xf8000000-0xfbffffff] (base 0xf8000000)
[    0.485472] PCI: MMCONFIG at [mem 0xf8000000-0xfbffffff] reserved in ACPI motherboard resources
[    0.485492] PCI: Using host bridge windows from ACPI; if necessary, use "pci=nocrs" and report a bug
[    0.486442] [Firmware Bug]: ACPI: No _BQC method, cannot determine initial brightness
[    0.495435] [Firmware Bug]: ACPI: No _BQC method, cannot determine initial brightness
[    0.501042] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-ff])
[    0.501060] acpi PNP0A08:00: _OSC: OS supports [ExtendedConfig ASPM ClockPM Segments MSI]
[    0.501444] acpi PNP0A08:00: _OSC: platform does not support [PME]
[    0.501802] acpi PNP0A08:00: _OSC: OS now controls [PCIeHotplug AER PCIeCapability]
[    0.502687] acpi PNP0A08:00: ignoring host bridge window [mem 0x000ce000-0x000cffff window] (conflicts with Video ROM [mem 0x000c0000-0x000cedff])
[    0.502697] acpi PNP0A08:00: [Firmware Info]: MMCONFIG for domain 0000 [bus 00-3f] only partially covers this bridge
[    0.503110] PCI host bridge to bus 0000:00
[    0.503117] pci_bus 0000:00: root bus resource [bus 00-ff]
[    0.503122] pci_bus 0000:00: root bus resource [mem 0x000a0000-0x000bffff window]
[    0.503126] pci_bus 0000:00: root bus resource [mem 0x000c0000-0x000c1fff window]
[    0.503131] pci_bus 0000:00: root bus resource [mem 0x000c2000-0x000c3fff window]
[    0.503135] pci_bus 0000:00: root bus resource [mem 0x000c4000-0x000c5fff window]
[    0.503139] pci_bus 0000:00: root bus resource [mem 0x000c6000-0x000c7fff window]
[    0.503143] pci_bus 0000:00: root bus resource [mem 0x000c8000-0x000c9fff window]
[    0.503147] pci_bus 0000:00: root bus resource [mem 0x000ca000-0x000cbfff window]
[    0.503151] pci_bus 0000:00: root bus resource [mem 0x000cc000-0x000cdfff window]
[    0.503155] pci_bus 0000:00: root bus resource [mem 0x000d0000-0x000d1fff window]
[    0.503159] pci_bus 0000:00: root bus resource [mem 0x000d2000-0x000d3fff window]
[    0.503163] pci_bus 0000:00: root bus resource [mem 0x000d4000-0x000d5fff window]
[    0.503167] pci_bus 0000:00: root bus resource [mem 0x000d6000-0x000d7fff window]
[    0.503171] pci_bus 0000:00: root bus resource [mem 0x000d8000-0x000d9fff window]
[    0.503175] pci_bus 0000:00: root bus resource [mem 0x000da000-0x000dbfff window]
[    0.503179] pci_bus 0000:00: root bus resource [mem 0x000dc000-0x000ddfff window]
[    0.503183] pci_bus 0000:00: root bus resource [mem 0x000de000-0x000dffff window]
[    0.503187] pci_bus 0000:00: root bus resource [mem 0x000e0000-0x000e1fff window]
[    0.503190] pci_bus 0000:00: root bus resource [mem 0x000e2000-0x000e3fff window]
[    0.503194] pci_bus 0000:00: root bus resource [mem 0x000e4000-0x000e5fff window]
[    0.503198] pci_bus 0000:00: root bus resource [mem 0x000e6000-0x000e7fff window]
[    0.503202] pci_bus 0000:00: root bus resource [mem 0x000e8000-0x000e9fff window]
[    0.503206] pci_bus 0000:00: root bus resource [mem 0x000ea000-0x000ebfff window]
[    0.503210] pci_bus 0000:00: root bus resource [mem 0x000ec000-0x000edfff window]
[    0.503214] pci_bus 0000:00: root bus resource [mem 0x000ee000-0x000effff window]
[    0.503218] pci_bus 0000:00: root bus resource [mem 0xe0000000-0xf7ffffff window]
[    0.503222] pci_bus 0000:00: root bus resource [mem 0xfc000000-0xfdffffff window]
[    0.503226] pci_bus 0000:00: root bus resource [mem 0xfed40000-0xfed44fff window]
[    0.503230] pci_bus 0000:00: root bus resource [io  0x0000-0x0cf7 window]
[    0.503234] pci_bus 0000:00: root bus resource [io  0x0d00-0xffff window]
[    0.503250] pci 0000:00:00.0: [1022:1510] type 00 class 0x060000
[    0.503436] pci 0000:00:01.0: [1002:9808] type 00 class 0x030000
[    0.503464] pci 0000:00:01.0: reg 0x10: [mem 0xe0000000-0xefffffff pref]
[    0.503475] pci 0000:00:01.0: reg 0x14: [io  0x3000-0x30ff]
[    0.503485] pci 0000:00:01.0: reg 0x18: [mem 0xf0b00000-0xf0b3ffff]
[    0.503536] pci 0000:00:01.0: supports D1 D2
[    0.503684] pci 0000:00:01.1: [1002:1314] type 00 class 0x040300
[    0.503709] pci 0000:00:01.1: reg 0x10: [mem 0xf0b44000-0xf0b47fff]
[    0.503769] pci 0000:00:01.1: supports D1 D2
[    0.503912] pci 0000:00:05.0: [1022:1513] type 01 class 0x060400
[    0.503981] pci 0000:00:05.0: PME# supported from D0 D3hot D3cold
[    0.504068] pci 0000:00:05.0: System wakeup disabled by ACPI
[    0.504156] pci 0000:00:06.0: [1022:1514] type 01 class 0x060400
[    0.504225] pci 0000:00:06.0: PME# supported from D0 D3hot D3cold
[    0.504308] pci 0000:00:06.0: System wakeup disabled by ACPI
[    0.504389] pci 0000:00:07.0: [1022:1515] type 01 class 0x060400
[    0.504456] pci 0000:00:07.0: PME# supported from D0 D3hot D3cold
[    0.504539] pci 0000:00:07.0: System wakeup disabled by ACPI
[    0.504654] pci 0000:00:10.0: [1022:7812] type 00 class 0x0c0330
[    0.504703] pci 0000:00:10.0: reg 0x10: [mem 0xf0b48000-0xf0b49fff 64bit]
[    0.504797] pci 0000:00:10.0: PME# supported from D0 D3hot D3cold
[    0.504913] pci 0000:00:10.0: System wakeup disabled by ACPI
[    0.505018] pci 0000:00:11.0: [1022:7801] type 00 class 0x010601
[    0.505052] pci 0000:00:11.0: reg 0x10: [io  0x3118-0x311f]
[    0.505065] pci 0000:00:11.0: reg 0x14: [io  0x3124-0x3127]
[    0.505078] pci 0000:00:11.0: reg 0x18: [io  0x3110-0x3117]
[    0.505091] pci 0000:00:11.0: reg 0x1c: [io  0x3120-0x3123]
[    0.505104] pci 0000:00:11.0: reg 0x20: [io  0x3100-0x310f]
[    0.505117] pci 0000:00:11.0: reg 0x24: [mem 0xf0b4d000-0xf0b4d7ff]
[    0.505306] pci 0000:00:12.0: [1022:7807] type 00 class 0x0c0310
[    0.505328] pci 0000:00:12.0: reg 0x10: [mem 0xf0b4c000-0xf0b4cfff]
[    0.505491] pci 0000:00:12.0: System wakeup disabled by ACPI
[    0.505591] pci 0000:00:12.2: [1022:7808] type 00 class 0x0c0320
[    0.505623] pci 0000:00:12.2: reg 0x10: [mem 0xf0b4d900-0xf0b4d9ff]
[    0.505705] pci 0000:00:12.2: supports D1 D2
[    0.505709] pci 0000:00:12.2: PME# supported from D0 D1 D2 D3hot
[    0.505868] pci 0000:00:13.0: [1022:7807] type 00 class 0x0c0310
[    0.505889] pci 0000:00:13.0: reg 0x10: [mem 0xf0b4b000-0xf0b4bfff]
[    0.506052] pci 0000:00:13.0: System wakeup disabled by ACPI
[    0.506149] pci 0000:00:13.2: [1022:7808] type 00 class 0x0c0320
[    0.506181] pci 0000:00:13.2: reg 0x10: [mem 0xf0b4d800-0xf0b4d8ff]
[    0.506263] pci 0000:00:13.2: supports D1 D2
[    0.506267] pci 0000:00:13.2: PME# supported from D0 D1 D2 D3hot
[    0.506370] pci 0000:00:13.2: System wakeup disabled by ACPI
[    0.506471] pci 0000:00:14.0: [1022:780b] type 00 class 0x0c0500
[    0.506708] pci 0000:00:14.2: [1022:780d] type 00 class 0x040300
[    0.506743] pci 0000:00:14.2: reg 0x10: [mem 0xf0b40000-0xf0b43fff 64bit]
[    0.506814] pci 0000:00:14.2: PME# supported from D0 D3hot D3cold
[    0.506914] pci 0000:00:14.2: System wakeup disabled by ACPI
[    0.507006] pci 0000:00:14.3: [1022:780e] type 00 class 0x060100
[    0.507240] pci 0000:00:14.4: [1022:780f] type 01 class 0x060401
[    0.507360] pci 0000:00:14.4: System wakeup disabled by ACPI
[    0.507456] pci 0000:00:14.5: [1022:7809] type 00 class 0x0c0310
[    0.507478] pci 0000:00:14.5: reg 0x10: [mem 0xf0b4a000-0xf0b4afff]
[    0.507644] pci 0000:00:14.5: System wakeup disabled by ACPI
[    0.507743] pci 0000:00:18.0: [1022:1700] type 00 class 0x060000
[    0.507912] pci 0000:00:18.1: [1022:1701] type 00 class 0x060000
[    0.508073] pci 0000:00:18.2: [1022:1702] type 00 class 0x060000
[    0.508236] pci 0000:00:18.3: [1022:1703] type 00 class 0x060000
[    0.508406] pci 0000:00:18.4: [1022:1704] type 00 class 0x060000
[    0.508567] pci 0000:00:18.5: [1022:1718] type 00 class 0x060000
[    0.508728] pci 0000:00:18.6: [1022:1716] type 00 class 0x060000
[    0.508889] pci 0000:00:18.7: [1022:1719] type 00 class 0x060000
[    0.509236] pci 0000:02:00.0: [14e4:4359] type 00 class 0x028000
[    0.509285] pci 0000:02:00.0: reg 0x10: [mem 0xf0a00000-0xf0a03fff 64bit]
[    0.509396] pci 0000:02:00.0: supports D1 D2
[    0.509400] pci 0000:02:00.0: PME# supported from D0 D3hot D3cold
[    0.515129] pci 0000:00:05.0: PCI bridge to [bus 02]
[    0.515151] pci 0000:00:05.0:   bridge window [mem 0xf0a00000-0xf0afffff]
[    0.515337] pci 0000:03:00.0: [10ec:8168] type 00 class 0x020000
[    0.515384] pci 0000:03:00.0: reg 0x10: [io  0x2000-0x20ff]
[    0.515415] pci 0000:03:00.0: reg 0x18: [mem 0xf0004000-0xf0004fff 64bit pref]
[    0.515435] pci 0000:03:00.0: reg 0x20: [mem 0xf0000000-0xf0003fff 64bit pref]
[    0.515513] pci 0000:03:00.0: supports D1 D2
[    0.515517] pci 0000:03:00.0: PME# supported from D0 D1 D2 D3hot D3cold
[    0.523083] pci 0000:00:06.0: PCI bridge to [bus 03]
[    0.523109] pci 0000:00:06.0:   bridge window [io  0x2000-0x2fff]
[    0.523121] pci 0000:00:06.0:   bridge window [mem 0xf0200000-0xf09fffff]
[    0.523133] pci 0000:00:06.0:   bridge window [mem 0xf0000000-0xf00fffff 64bit pref]
[    0.523326] pci 0000:04:00.0: [10ec:5209] type 00 class 0xff0000
[    0.523370] pci 0000:04:00.0: reg 0x10: [mem 0xf0100000-0xf0100fff]
[    0.523438] pci 0000:04:00.0: reg 0x30: [mem 0xffff0000-0xffffffff pref]
[    0.523496] pci 0000:04:00.0: supports D1 D2
[    0.523500] pci 0000:04:00.0: PME# supported from D1 D2 D3hot
[    0.531077] pci 0000:00:07.0: PCI bridge to [bus 04]
[    0.531105] pci 0000:00:07.0:   bridge window [mem 0xf0100000-0xf01fffff]
[    0.531311] pci 0000:00:14.4: PCI bridge to [bus 05] (subtractive decode)
[    0.531325] pci 0000:00:14.4:   bridge window [mem 0x000a0000-0x000bffff window] (subtractive decode)
[    0.531330] pci 0000:00:14.4:   bridge window [mem 0x000c0000-0x000c1fff window] (subtractive decode)
[    0.531335] pci 0000:00:14.4:   bridge window [mem 0x000c2000-0x000c3fff window] (subtractive decode)
[    0.531339] pci 0000:00:14.4:   bridge window [mem 0x000c4000-0x000c5fff window] (subtractive decode)
[    0.531344] pci 0000:00:14.4:   bridge window [mem 0x000c6000-0x000c7fff window] (subtractive decode)
[    0.531348] pci 0000:00:14.4:   bridge window [mem 0x000c8000-0x000c9fff window] (subtractive decode)
[    0.531352] pci 0000:00:14.4:   bridge window [mem 0x000ca000-0x000cbfff window] (subtractive decode)
[    0.531357] pci 0000:00:14.4:   bridge window [mem 0x000cc000-0x000cdfff window] (subtractive decode)
[    0.531361] pci 0000:00:14.4:   bridge window [mem 0x000d0000-0x000d1fff window] (subtractive decode)
[    0.531365] pci 0000:00:14.4:   bridge window [mem 0x000d2000-0x000d3fff window] (subtractive decode)
[    0.531369] pci 0000:00:14.4:   bridge window [mem 0x000d4000-0x000d5fff window] (subtractive decode)
[    0.531373] pci 0000:00:14.4:   bridge window [mem 0x000d6000-0x000d7fff window] (subtractive decode)
[    0.531378] pci 0000:00:14.4:   bridge window [mem 0x000d8000-0x000d9fff window] (subtractive decode)
[    0.531382] pci 0000:00:14.4:   bridge window [mem 0x000da000-0x000dbfff window] (subtractive decode)
[    0.531386] pci 0000:00:14.4:   bridge window [mem 0x000dc000-0x000ddfff window] (subtractive decode)
[    0.531390] pci 0000:00:14.4:   bridge window [mem 0x000de000-0x000dffff window] (subtractive decode)
[    0.531394] pci 0000:00:14.4:   bridge window [mem 0x000e0000-0x000e1fff window] (subtractive decode)
[    0.531399] pci 0000:00:14.4:   bridge window [mem 0x000e2000-0x000e3fff window] (subtractive decode)
[    0.531403] pci 0000:00:14.4:   bridge window [mem 0x000e4000-0x000e5fff window] (subtractive decode)
[    0.531407] pci 0000:00:14.4:   bridge window [mem 0x000e6000-0x000e7fff window] (subtractive decode)
[    0.531411] pci 0000:00:14.4:   bridge window [mem 0x000e8000-0x000e9fff window] (subtractive decode)
[    0.531415] pci 0000:00:14.4:   bridge window [mem 0x000ea000-0x000ebfff window] (subtractive decode)
[    0.531420] pci 0000:00:14.4:   bridge window [mem 0x000ec000-0x000edfff window] (subtractive decode)
[    0.531424] pci 0000:00:14.4:   bridge window [mem 0x000ee000-0x000effff window] (subtractive decode)
[    0.531429] pci 0000:00:14.4:   bridge window [mem 0xe0000000-0xf7ffffff window] (subtractive decode)
[    0.531433] pci 0000:00:14.4:   bridge window [mem 0xfc000000-0xfdffffff window] (subtractive decode)
[    0.531438] pci 0000:00:14.4:   bridge window [mem 0xfed40000-0xfed44fff window] (subtractive decode)
[    0.531442] pci 0000:00:14.4:   bridge window [io  0x0000-0x0cf7 window] (subtractive decode)
[    0.531449] pci 0000:00:14.4:   bridge window [io  0x0d00-0xffff window] (subtractive decode)
[    0.532170] ACPI: PCI Interrupt Link [LNKA] (IRQs 10 11) *0
[    0.532326] ACPI: PCI Interrupt Link [LNKB] (IRQs 10 11) *0
[    0.532474] ACPI: PCI Interrupt Link [LNKC] (IRQs 10 11) *0
[    0.532619] ACPI: PCI Interrupt Link [LNKD] (IRQs 10 11) *0
[    0.532745] ACPI: PCI Interrupt Link [LNKE] (IRQs 10 11) *0
[    0.532850] ACPI: PCI Interrupt Link [LNKF] (IRQs 10 11) *0
[    0.532955] ACPI: PCI Interrupt Link [LNKG] (IRQs 10 11) *0
[    0.533061] ACPI: PCI Interrupt Link [LNKH] (IRQs 10 11) *0
[    0.533342] ACPI: IRQ 7 override to edge, high
[    0.535360] ACPI: Enabled 1 GPEs in block 00 to 1F
[    0.535527] ACPI : EC: GPE = 0x3, I/O: command/status = 0x66, data = 0x62
[    0.535869] vgaarb: setting as boot device: PCI:0000:00:01.0
[    0.535878] vgaarb: device added: PCI:0000:00:01.0,decodes=io+mem,owns=io+mem,locks=none
[    0.535890] vgaarb: loaded
[    0.535893] vgaarb: bridge control possible 0000:00:01.0
[    0.536268] PCI: Using ACPI for IRQ routing
[    0.538524] PCI: pci_cache_line_size set to 64 bytes
[    0.538698] e820: reserve RAM buffer [mem 0x0009e800-0x0009ffff]
[    0.538703] e820: reserve RAM buffer [mem 0xd2e20000-0xd3ffffff]
[    0.538706] e820: reserve RAM buffer [mem 0x207000000-0x207ffffff]
[    0.539048] hpet0: at MMIO 0xfed00000, IRQs 2, 8, 0
[    0.539056] hpet0: 3 comparators, 32-bit 14.318180 MHz counter
[    0.541108] clocksource: Switched to clocksource hpet
[    0.554317] pnp: PnP ACPI init
[    0.554614] system 00:00: [io  0x0f50-0x0f51] has been reserved
[    0.554621] system 00:00: [mem 0xfec00000-0xfec00fff] could not be reserved
[    0.554626] system 00:00: [mem 0xfee00000-0xfee00fff] has been reserved
[    0.554631] system 00:00: [mem 0xf8000000-0xfbffffff] has been reserved
[    0.554640] system 00:00: Plug and Play ACPI device, IDs PNP0c02 (active)
[    0.555351] pnp 00:01: Plug and Play ACPI device, IDs PNP0b00 (active)
[    0.555415] pnp 00:02: Plug and Play ACPI device, IDs MSF0001 PNP0303 (active)
[    0.555522] pnp 00:03: Plug and Play ACPI device, IDs LEN0052 PNP0f13 (active)
[    0.555642] system 00:04: [io  0x04d0-0x04d1] has been reserved
[    0.555647] system 00:04: [io  0x0530-0x0537] has been reserved
[    0.555652] system 00:04: [io  0x0800-0x0827] could not be reserved
[    0.555657] system 00:04: [io  0x0830] has been reserved
[    0.555662] system 00:04: [io  0x0840-0x0847] has been reserved
[    0.555666] system 00:04: [io  0x0b00-0x0b1f] has been reserved
[    0.555671] system 00:04: [io  0x0c00-0x0c01] has been reserved
[    0.555676] system 00:04: [io  0x0c14] has been reserved
[    0.555680] system 00:04: [io  0x0c50-0x0c52] has been reserved
[    0.555687] system 00:04: [io  0x0cd0-0x0cd1] has been reserved
[    0.555691] system 00:04: [io  0x0cd2-0x0cd3] has been reserved
[    0.555696] system 00:04: [io  0x0cd4-0x0cd5] has been reserved
[    0.555700] system 00:04: [io  0x0cd6-0x0cd7] has been reserved
[    0.555705] system 00:04: [io  0x0cd8-0x0cdf] has been reserved
[    0.555709] system 00:04: [io  0x0cf9] could not be reserved
[    0.555714] system 00:04: [io  0x8100-0x81ff window] has been reserved
[    0.555718] system 00:04: [io  0x8200-0x82ff window] has been reserved
[    0.555724] system 00:04: Plug and Play ACPI device, IDs PNP0c02 (active)
[    0.555904] system 00:05: [mem 0x000e0000-0x000fffff] could not be reserved
[    0.555910] system 00:05: [mem 0xffe00000-0xffffffff] has been reserved
[    0.555914] system 00:05: [mem 0xfec10000-0xfec1001f] has been reserved
[    0.555919] system 00:05: [mem 0xfed00000-0xfed003ff] has been reserved
[    0.555923] system 00:05: [mem 0xfed61000-0xfed613ff] has been reserved
[    0.555928] system 00:05: [mem 0xfed80000-0xfed80fff] has been reserved
[    0.555934] system 00:05: Plug and Play ACPI device, IDs PNP0c01 (active)
[    0.557291] pnp: PnP ACPI: found 6 devices
[    0.567478] clocksource: acpi_pm: mask: 0xffffff max_cycles: 0xffffff, max_idle_ns: 2085701024 ns
[    0.567499] pci 0000:04:00.0: can't claim BAR 6 [mem 0xffff0000-0xffffffff pref]: no compatible bridge window
[    0.567538] pci 0000:00:07.0: bridge window [io  0x1000-0x0fff] to [bus 04] add_size 1000
[    0.567545] pci 0000:00:07.0: bridge window [mem 0x00100000-0x000fffff 64bit pref] to [bus 04] add_size 200000 add_align 100000
[    0.567578] pci 0000:00:07.0: res[15]=[mem 0x00100000-0x000fffff 64bit pref] res_to_dev_res add_size 200000 min_align 100000
[    0.567583] pci 0000:00:07.0: res[15]=[mem 0x00100000-0x002fffff 64bit pref] res_to_dev_res add_size 200000 min_align 100000
[    0.567588] pci 0000:00:07.0: res[13]=[io  0x1000-0x0fff] res_to_dev_res add_size 1000 min_align 1000
[    0.567593] pci 0000:00:07.0: res[13]=[io  0x1000-0x1fff] res_to_dev_res add_size 1000 min_align 1000
[    0.567639] pci 0000:00:07.0: BAR 15: assigned [mem 0xf0c00000-0xf0dfffff 64bit pref]
[    0.567649] pci 0000:00:07.0: BAR 13: assigned [io  0x1000-0x1fff]
[    0.567655] pci 0000:00:05.0: PCI bridge to [bus 02]
[    0.567663] pci 0000:00:05.0:   bridge window [mem 0xf0a00000-0xf0afffff]
[    0.567673] pci 0000:00:06.0: PCI bridge to [bus 03]
[    0.567678] pci 0000:00:06.0:   bridge window [io  0x2000-0x2fff]
[    0.567684] pci 0000:00:06.0:   bridge window [mem 0xf0200000-0xf09fffff]
[    0.567690] pci 0000:00:06.0:   bridge window [mem 0xf0000000-0xf00fffff 64bit pref]
[    0.567699] pci 0000:04:00.0: BAR 6: assigned [mem 0xf0110000-0xf011ffff pref]
[    0.567703] pci 0000:00:07.0: PCI bridge to [bus 04]
[    0.567708] pci 0000:00:07.0:   bridge window [io  0x1000-0x1fff]
[    0.567714] pci 0000:00:07.0:   bridge window [mem 0xf0100000-0xf01fffff]
[    0.567720] pci 0000:00:07.0:   bridge window [mem 0xf0c00000-0xf0dfffff 64bit pref]
[    0.567727] pci 0000:00:14.4: PCI bridge to [bus 05]
[    0.567758] pci_bus 0000:00: resource 4 [mem 0x000a0000-0x000bffff window]
[    0.567762] pci_bus 0000:00: resource 5 [mem 0x000c0000-0x000c1fff window]
[    0.567766] pci_bus 0000:00: resource 6 [mem 0x000c2000-0x000c3fff window]
[    0.567770] pci_bus 0000:00: resource 7 [mem 0x000c4000-0x000c5fff window]
[    0.567774] pci_bus 0000:00: resource 8 [mem 0x000c6000-0x000c7fff window]
[    0.567777] pci_bus 0000:00: resource 9 [mem 0x000c8000-0x000c9fff window]
[    0.567781] pci_bus 0000:00: resource 10 [mem 0x000ca000-0x000cbfff window]
[    0.567785] pci_bus 0000:00: resource 11 [mem 0x000cc000-0x000cdfff window]
[    0.567788] pci_bus 0000:00: resource 12 [mem 0x000d0000-0x000d1fff window]
[    0.567792] pci_bus 0000:00: resource 13 [mem 0x000d2000-0x000d3fff window]
[    0.567796] pci_bus 0000:00: resource 14 [mem 0x000d4000-0x000d5fff window]
[    0.567799] pci_bus 0000:00: resource 15 [mem 0x000d6000-0x000d7fff window]
[    0.567803] pci_bus 0000:00: resource 16 [mem 0x000d8000-0x000d9fff window]
[    0.567807] pci_bus 0000:00: resource 17 [mem 0x000da000-0x000dbfff window]
[    0.567810] pci_bus 0000:00: resource 18 [mem 0x000dc000-0x000ddfff window]
[    0.567814] pci_bus 0000:00: resource 19 [mem 0x000de000-0x000dffff window]
[    0.567818] pci_bus 0000:00: resource 20 [mem 0x000e0000-0x000e1fff window]
[    0.567821] pci_bus 0000:00: resource 21 [mem 0x000e2000-0x000e3fff window]
[    0.567825] pci_bus 0000:00: resource 22 [mem 0x000e4000-0x000e5fff window]
[    0.567829] pci_bus 0000:00: resource 23 [mem 0x000e6000-0x000e7fff window]
[    0.567832] pci_bus 0000:00: resource 24 [mem 0x000e8000-0x000e9fff window]
[    0.567836] pci_bus 0000:00: resource 25 [mem 0x000ea000-0x000ebfff window]
[    0.567840] pci_bus 0000:00: resource 26 [mem 0x000ec000-0x000edfff window]
[    0.567843] pci_bus 0000:00: resource 27 [mem 0x000ee000-0x000effff window]
[    0.567847] pci_bus 0000:00: resource 28 [mem 0xe0000000-0xf7ffffff window]
[    0.567851] pci_bus 0000:00: resource 29 [mem 0xfc000000-0xfdffffff window]
[    0.567855] pci_bus 0000:00: resource 30 [mem 0xfed40000-0xfed44fff window]
[    0.567858] pci_bus 0000:00: resource 31 [io  0x0000-0x0cf7 window]
[    0.567862] pci_bus 0000:00: resource 32 [io  0x0d00-0xffff window]
[    0.567867] pci_bus 0000:02: resource 1 [mem 0xf0a00000-0xf0afffff]
[    0.567870] pci_bus 0000:03: resource 0 [io  0x2000-0x2fff]
[    0.567874] pci_bus 0000:03: resource 1 [mem 0xf0200000-0xf09fffff]
[    0.567878] pci_bus 0000:03: resource 2 [mem 0xf0000000-0xf00fffff 64bit pref]
[    0.567882] pci_bus 0000:04: resource 0 [io  0x1000-0x1fff]
[    0.567885] pci_bus 0000:04: resource 1 [mem 0xf0100000-0xf01fffff]
[    0.567889] pci_bus 0000:04: resource 2 [mem 0xf0c00000-0xf0dfffff 64bit pref]
[    0.567893] pci_bus 0000:05: resource 4 [mem 0x000a0000-0x000bffff window]
[    0.567897] pci_bus 0000:05: resource 5 [mem 0x000c0000-0x000c1fff window]
[    0.567901] pci_bus 0000:05: resource 6 [mem 0x000c2000-0x000c3fff window]
[    0.567904] pci_bus 0000:05: resource 7 [mem 0x000c4000-0x000c5fff window]
[    0.567908] pci_bus 0000:05: resource 8 [mem 0x000c6000-0x000c7fff window]
[    0.567912] pci_bus 0000:05: resource 9 [mem 0x000c8000-0x000c9fff window]
[    0.567915] pci_bus 0000:05: resource 10 [mem 0x000ca000-0x000cbfff window]
[    0.567919] pci_bus 0000:05: resource 11 [mem 0x000cc000-0x000cdfff window]
[    0.567923] pci_bus 0000:05: resource 12 [mem 0x000d0000-0x000d1fff window]
[    0.567926] pci_bus 0000:05: resource 13 [mem 0x000d2000-0x000d3fff window]
[    0.567930] pci_bus 0000:05: resource 14 [mem 0x000d4000-0x000d5fff window]
[    0.567933] pci_bus 0000:05: resource 15 [mem 0x000d6000-0x000d7fff window]
[    0.567937] pci_bus 0000:05: resource 16 [mem 0x000d8000-0x000d9fff window]
[    0.567941] pci_bus 0000:05: resource 17 [mem 0x000da000-0x000dbfff window]
[    0.567944] pci_bus 0000:05: resource 18 [mem 0x000dc000-0x000ddfff window]
[    0.567948] pci_bus 0000:05: resource 19 [mem 0x000de000-0x000dffff window]
[    0.567952] pci_bus 0000:05: resource 20 [mem 0x000e0000-0x000e1fff window]
[    0.567955] pci_bus 0000:05: resource 21 [mem 0x000e2000-0x000e3fff window]
[    0.567959] pci_bus 0000:05: resource 22 [mem 0x000e4000-0x000e5fff window]
[    0.567963] pci_bus 0000:05: resource 23 [mem 0x000e6000-0x000e7fff window]
[    0.567966] pci_bus 0000:05: resource 24 [mem 0x000e8000-0x000e9fff window]
[    0.567970] pci_bus 0000:05: resource 25 [mem 0x000ea000-0x000ebfff window]
[    0.567974] pci_bus 0000:05: resource 26 [mem 0x000ec000-0x000edfff window]
[    0.567977] pci_bus 0000:05: resource 27 [mem 0x000ee000-0x000effff window]
[    0.567981] pci_bus 0000:05: resource 28 [mem 0xe0000000-0xf7ffffff window]
[    0.567985] pci_bus 0000:05: resource 29 [mem 0xfc000000-0xfdffffff window]
[    0.567989] pci_bus 0000:05: resource 30 [mem 0xfed40000-0xfed44fff window]
[    0.567993] pci_bus 0000:05: resource 31 [io  0x0000-0x0cf7 window]
[    0.567996] pci_bus 0000:05: resource 32 [io  0x0d00-0xffff window]
[    0.568123] NET: Registered protocol family 2
[    0.568536] TCP established hash table entries: 65536 (order: 7, 524288 bytes)
[    0.568927] TCP bind hash table entries: 65536 (order: 8, 1048576 bytes)
[    0.569500] TCP: Hash tables configured (established 65536 bind 65536)
[    0.569621] UDP hash table entries: 4096 (order: 5, 131072 bytes)
[    0.569709] UDP-Lite hash table entries: 4096 (order: 5, 131072 bytes)
[    0.570063] NET: Registered protocol family 1
[    0.570105] pci 0000:00:01.0: Video device with shadowed ROM
[    0.713405] PCI: CLS 32 bytes, default 64
[    0.713540] Unpacking initramfs...
[    1.336422] Freeing initrd memory: 18324K (ffff880035c26000 - ffff880036e0b000)
[    1.336471] PCI-DMA: Using software bounce buffering for IO (SWIOTLB)
[    1.336477] software IO TLB [mem 0xcee20000-0xd2e20000] (64MB) mapped at [ffff8800cee20000-ffff8800d2e1ffff]
[    1.336785] microcode: CPU0: patch_level=0x0500010d
[    1.336800] microcode: CPU1: patch_level=0x0500010d
[    1.337058] microcode: Microcode Update Driver: v2.00 <tigran@aivazian.fsnet.co.uk>, Peter Oruba
[    1.337076] LVT offset 0 assigned for vector 0x400
[    1.337150] perf: AMD IBS detected (0x000000ff)
[    1.338031] futex hash table entries: 1024 (order: 4, 65536 bytes)
[    1.338112] audit: initializing netlink subsys (disabled)
[    1.338160] audit: type=2000 audit(1449954598.028:1): initialized
[    1.338956] HugeTLB registered 2 MB page size, pre-allocated 0 pages
[    1.339011] zbud: loaded
[    1.339500] VFS: Disk quotas dquot_6.6.0
[    1.339567] VFS: Dquot-cache hash table entries: 512 (order 0, 4096 bytes)
[    1.340985] Block layer SCSI generic (bsg) driver version 0.4 loaded (major 250)
[    1.341078] io scheduler noop registered
[    1.341088] io scheduler deadline registered
[    1.341141] io scheduler cfq registered (default)
[    1.342732] pci_hotplug: PCI Hot Plug PCI Core version: 0.5
[    1.342758] pciehp 0000:00:07.0:pcie04: Slot #7 AttnBtn- PwrCtrl- MRL- AttnInd- PwrInd- HotPlug+ Surprise- Interlock- NoCompl+ LLActRep+
[    1.342845] pciehp 0000:00:07.0:pcie04: service driver pciehp loaded
[    1.342857] pciehp: PCI Express Hot Plug Controller Driver version: 0.4
[    1.342964] GHES: HEST is not enabled!
[    1.343252] Serial: 8250/16550 driver, 4 ports, IRQ sharing enabled
[    1.344301] Linux agpgart interface v0.103
[    1.344436] AMD IOMMUv2 driver by Joerg Roedel <jroedel@suse.de>
[    1.344439] AMD IOMMUv2 functionality not available on this system
[    1.345120] i8042: PNP: PS/2 Controller [PNP0303:KBC0,PNP0f13:MSE0] at 0x60,0x64 irq 1,12
[    1.352539] i8042: Detected active multiplexing controller, rev 1.1
[    1.353610] serio: i8042 KBD port at 0x60,0x64 irq 1
[    1.353624] serio: i8042 AUX0 port at 0x60,0x64 irq 12
[    1.353695] serio: i8042 AUX1 port at 0x60,0x64 irq 12
[    1.353755] serio: i8042 AUX2 port at 0x60,0x64 irq 12
[    1.353814] serio: i8042 AUX3 port at 0x60,0x64 irq 12
[    1.354411] mousedev: PS/2 mouse device common for all mice
[    1.354583] rtc_cmos 00:01: RTC can wake from S4
[    1.354837] rtc_cmos 00:01: rtc core: registered rtc_cmos as rtc0
[    1.354901] rtc_cmos 00:01: alarms up to one month, 114 bytes nvram, hpet irqs
[    1.354949] ledtrig-cpu: registered to indicate activity on CPUs
[    1.355789] NET: Registered protocol family 10
[    1.356231] mip6: Mobile IPv6
[    1.356240] NET: Registered protocol family 17
[    1.356270] mpls_gso: MPLS GSO support
[    1.356974] registered taskstats version 1
[    1.357035] zswap: loaded using pool lzo/zbud
[    1.357828] rtc_cmos 00:01: setting system clock to 2015-12-12 21:09:59 UTC (1449954599)
[    1.357965] PM: Hibernation image not present or could not be loaded.
[    1.358875] Freeing unused kernel memory: 1284K (ffffffff81b07000 - ffffffff81c48000)
[    1.358883] Write protecting the kernel read-only data: 10240k
[    1.359631] Freeing unused kernel memory: 660K (ffff88000155b000 - ffff880001600000)
[    1.360618] Freeing unused kernel memory: 1324K (ffff8800018b5000 - ffff880001a00000)
[    1.395667] input: AT Translated Set 2 keyboard as /devices/platform/i8042/serio0/input/input0
[    1.503110] systemd-udevd[68]: starting version 215
[    1.503995] random: systemd-udevd urandom read with 2 bits of entropy available
[    1.534028] ACPI: bus type USB registered
[    1.534087] usbcore: registered new interface driver usbfs
[    1.534110] usbcore: registered new interface driver hub
[    1.536536] usbcore: registered new device driver usb
[    1.538893] QUIRK: Enable AMD PLL fix
[    1.538947] xhci_hcd 0000:00:10.0: xHCI Host Controller
[    1.538961] xhci_hcd 0000:00:10.0: new USB bus registered, assigned bus number 1
[    1.539170] xhci_hcd 0000:00:10.0: hcc params 0x014042c3 hci version 0x96 quirks 0x00000608
[    1.542049] r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
[    1.542814] r8169 0000:03:00.0 eth0: RTL8168evl/8111evl at 0xffffc90000e68000, 08:9e:01:35:12:25, XID 0c900800 IRQ 28
[    1.542820] r8169 0000:03:00.0 eth0: jumbo features [frames: 9200 bytes, tx checksumming: ko]
[    1.542923] usb usb1: New USB device found, idVendor=1d6b, idProduct=0002
[    1.542929] usb usb1: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    1.542933] usb usb1: Product: xHCI Host Controller
[    1.542937] usb usb1: Manufacturer: Linux 4.3.0-trunk-amd64 xhci-hcd
[    1.542940] usb usb1: SerialNumber: 0000:00:10.0
[    1.543500] hub 1-0:1.0: USB hub found
[    1.543534] hub 1-0:1.0: 2 ports detected
[    1.543767] xhci_hcd 0000:00:10.0: xHCI Host Controller
[    1.543778] xhci_hcd 0000:00:10.0: new USB bus registered, assigned bus number 2
[    1.543822] usb usb2: We don't know the algorithms for LPM for this host, disabling LPM.
[    1.543863] usb usb2: New USB device found, idVendor=1d6b, idProduct=0003
[    1.543868] usb usb2: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    1.543871] usb usb2: Product: xHCI Host Controller
[    1.543875] usb usb2: Manufacturer: Linux 4.3.0-trunk-amd64 xhci-hcd
[    1.543878] usb usb2: SerialNumber: 0000:00:10.0
[    1.544256] hub 2-0:1.0: USB hub found
[    1.544278] hub 2-0:1.0: 2 ports detected
[    1.556841] rtsx_pci 0000:04:00.0: rtsx_pci_acquire_irq: pcr->msi_en = 1, pci->irq = 29
[    1.558404] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
[    1.559180] ohci_hcd: USB 1.1 'Open' Host Controller (OHCI) Driver
[    1.559619] ehci-pci: EHCI PCI platform driver
[    1.560038] ehci-pci 0000:00:12.2: EHCI Host Controller
[    1.560052] ehci-pci 0000:00:12.2: new USB bus registered, assigned bus number 3
[    1.560063] ehci-pci 0000:00:12.2: applying AMD SB700/SB800/Hudson-2/3 EHCI dummy qh workaround
[    1.560090] ehci-pci 0000:00:12.2: debug port 1
[    1.560158] ehci-pci 0000:00:12.2: irq 17, io mem 0xf0b4d900
[    1.561736] SCSI subsystem initialized
[    1.566180] libata version 3.00 loaded.
[    1.566562] thermal LNXTHERM:00: registered as thermal_zone0
[    1.566570] ACPI: Thermal Zone [THZ0] (63 C)
[    1.568397] ehci-pci 0000:00:12.2: USB 2.0 started, EHCI 1.00
[    1.568613] usb usb3: New USB device found, idVendor=1d6b, idProduct=0002
[    1.568622] usb usb3: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    1.568626] usb usb3: Product: EHCI Host Controller
[    1.568630] usb usb3: Manufacturer: Linux 4.3.0-trunk-amd64 ehci_hcd
[    1.568633] usb usb3: SerialNumber: 0000:00:12.2
[    1.568944] hub 3-0:1.0: USB hub found
[    1.568961] hub 3-0:1.0: 5 ports detected
[    1.569639] ehci-pci 0000:00:13.2: EHCI Host Controller
[    1.569652] ehci-pci 0000:00:13.2: new USB bus registered, assigned bus number 4
[    1.569661] ehci-pci 0000:00:13.2: applying AMD SB700/SB800/Hudson-2/3 EHCI dummy qh workaround
[    1.569674] ehci-pci 0000:00:13.2: debug port 1
[    1.569724] ehci-pci 0000:00:13.2: irq 17, io mem 0xf0b4d800
[    1.580401] ehci-pci 0000:00:13.2: USB 2.0 started, EHCI 1.00
[    1.580542] usb usb4: New USB device found, idVendor=1d6b, idProduct=0002
[    1.580547] usb usb4: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    1.580551] usb usb4: Product: EHCI Host Controller
[    1.580555] usb usb4: Manufacturer: Linux 4.3.0-trunk-amd64 ehci_hcd
[    1.580559] usb usb4: SerialNumber: 0000:00:13.2
[    1.580865] hub 4-0:1.0: USB hub found
[    1.580881] hub 4-0:1.0: 5 ports detected
[    1.581805] ohci-pci: OHCI PCI platform driver
[    1.582210] ohci-pci 0000:00:12.0: OHCI PCI host controller
[    1.582224] ohci-pci 0000:00:12.0: new USB bus registered, assigned bus number 5
[    1.582291] ohci-pci 0000:00:12.0: irq 18, io mem 0xf0b4c000
[    1.640680] usb usb5: New USB device found, idVendor=1d6b, idProduct=0001
[    1.640689] usb usb5: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    1.640693] usb usb5: Product: OHCI PCI host controller
[    1.640697] usb usb5: Manufacturer: Linux 4.3.0-trunk-amd64 ohci_hcd
[    1.640701] usb usb5: SerialNumber: 0000:00:12.0
[    1.641226] hub 5-0:1.0: USB hub found
[    1.641264] hub 5-0:1.0: 5 ports detected
[    1.641916] ohci-pci 0000:00:13.0: OHCI PCI host controller
[    1.641929] ohci-pci 0000:00:13.0: new USB bus registered, assigned bus number 6
[    1.641975] ohci-pci 0000:00:13.0: irq 18, io mem 0xf0b4b000
[    1.700574] usb usb6: New USB device found, idVendor=1d6b, idProduct=0001
[    1.700583] usb usb6: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    1.700588] usb usb6: Product: OHCI PCI host controller
[    1.700591] usb usb6: Manufacturer: Linux 4.3.0-trunk-amd64 ohci_hcd
[    1.700595] usb usb6: SerialNumber: 0000:00:13.0
[    1.701168] hub 6-0:1.0: USB hub found
[    1.701205] hub 6-0:1.0: 5 ports detected
[    1.701913] ohci-pci 0000:00:14.5: OHCI PCI host controller
[    1.701927] ohci-pci 0000:00:14.5: new USB bus registered, assigned bus number 7
[    1.701977] ohci-pci 0000:00:14.5: irq 18, io mem 0xf0b4a000
[    1.760518] usb usb7: New USB device found, idVendor=1d6b, idProduct=0001
[    1.760527] usb usb7: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    1.760531] usb usb7: Product: OHCI PCI host controller
[    1.760535] usb usb7: Manufacturer: Linux 4.3.0-trunk-amd64 ohci_hcd
[    1.760539] usb usb7: SerialNumber: 0000:00:14.5
[    1.761073] hub 7-0:1.0: USB hub found
[    1.761110] hub 7-0:1.0: 2 ports detected
[    1.761751] ahci 0000:00:11.0: version 3.0
[    1.762165] ahci 0000:00:11.0: AHCI 0001.0300 32 slots 1 ports 6 Gbps 0x1 impl SATA mode
[    1.762172] ahci 0000:00:11.0: flags: 64bit ncq sntf ilck pm led clo pmp pio slum part 
[    1.763456] scsi host0: ahci
[    1.763621] ata1: SATA max UDMA/133 abar m2048@0xf0b4d000 port 0xf0b4d100 irq 30
[    2.152163] usb 6-3: new full-speed USB device number 2 using ohci-pci
[    2.152172] usb 4-4: new high-speed USB device number 3 using ehci-pci
[    2.248096] ata1: SATA link up 6.0 Gbps (SStatus 133 SControl 300)
[    2.249115] ata1.00: READ LOG DMA EXT failed, trying unqueued
[    2.249163] ata1.00: failed to get NCQ Send/Recv Log Emask 0x1
[    2.249168] ata1.00: ATA-9: Samsung SSD 840 PRO Series, DXM06B0Q, max UDMA/133
[    2.249173] ata1.00: 500118192 sectors, multi 16: LBA48 NCQ (depth 31/32), AA
[    2.249478] ata1.00: failed to get NCQ Send/Recv Log Emask 0x1
[    2.249491] ata1.00: configured for UDMA/133
[    2.250160] scsi 0:0:0:0: Direct-Access     ATA      Samsung SSD 840  6B0Q PQ: 0 ANSI: 5
[    2.253515] ata1.00: Enabling discard_zeroes_data
[    2.253552] sd 0:0:0:0: [sda] 500118192 512-byte logical blocks: (256 GB/238 GiB)
[    2.253925] sd 0:0:0:0: [sda] Write Protect is off
[    2.253931] sd 0:0:0:0: [sda] Mode Sense: 00 3a 00 00
[    2.254004] sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[    2.254289] ata1.00: Enabling discard_zeroes_data
[    2.256786]  sda: sda1 sda2 sda3
[    2.257567] ata1.00: Enabling discard_zeroes_data
[    2.257730] sd 0:0:0:0: [sda] Attached SCSI disk
[    2.258800] sd 0:0:0:0: Attached scsi generic sg0 type 0
[    2.295630] usb 4-4: New USB device found, idVendor=5986, idProduct=0299
[    2.295639] usb 4-4: New USB device strings: Mfr=1, Product=2, SerialNumber=0
[    2.295643] usb 4-4: Product: Integrated Camera
[    2.295646] usb 4-4: Manufacturer: Vimicro corp.
[    2.307974] platform microcode: firmware: direct-loading firmware amd-ucode/microcode_amd.bin
[    2.313914] microcode: CPU0: new patch_level=0x05000119
[    2.319926] microcode: CPU1: new patch_level=0x05000119
[    2.335826] tsc: Refined TSC clocksource calibration: 1696.914 MHz
[    2.335837] clocksource: tsc: mask: 0xffffffffffffffff max_cycles: 0x1875c420428, max_idle_ns: 440795272528 ns
[    2.337126] usb 6-3: New USB device found, idVendor=0a5c, idProduct=21f3
[    2.337135] usb 6-3: New USB device strings: Mfr=1, Product=2, SerialNumber=3
[    2.337139] usb 6-3: Product: BCM20702A0
[    2.337143] usb 6-3: Manufacturer: Broadcom Corp
[    2.337146] usb 6-3: SerialNumber: 2CD05A80FEA0
[    2.355214] device-mapper: uevent: version 1.0.3
[    2.355405] device-mapper: ioctl: 4.33.0-ioctl (2015-8-18) initialised: dm-devel@redhat.com
[    2.650164] NET: Registered protocol family 38
[    2.684724] sha256_ssse3: Using SSSE3 optimized SHA-256 implementation
[    3.335233] clocksource: Switched to clocksource tsc
[    5.978244] EXT4-fs (dm-1): mounted filesystem with ordered data mode. Opts: (null)
[    6.522904] systemd[1]: Cannot add dependency job for unit NetworkManager.service, ignoring: Unit NetworkManager.service failed to load: No such file or directory.
[    6.523068] systemd[1]: Cannot add dependency job for unit display-manager.service, ignoring: Unit display-manager.service failed to load: No such file or directory.
[    6.649415] lp: driver loaded but no devices found
[    6.656418] ppdev: user-space parallel port driver
[    6.672529] fuse init (API version 7.23)
[    6.705685] systemd-udevd[274]: starting version 215
[    6.712950] loop: module loaded
[    7.036809] ACPI: acpi_idle registered with cpuidle
[    7.048394] acpi-cpufreq: overriding BIOS provided _PSD data
[    7.065190] shpchp: Standard Hot Plug PCI Controller Driver version: 0.4
[    7.090011] input: Power Button as /devices/LNXSYSTM:00/LNXSYBUS:00/PNP0C0C:00/input/input5
[    7.090023] ACPI: Power Button [PWRB]
[    7.090277] input: Lid Switch as /devices/LNXSYSTM:00/LNXSYBUS:00/PNP0C0D:00/input/input6
[    7.092942] ACPI: Lid Switch [LID]
[    7.093101] input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/input/input7
[    7.093110] ACPI: Power Button [PWRF]
[    7.093505] wmi: Mapper loaded
[    7.100814] ACPI: Video Device [VGA1] (multi-head: yes  rom: no  post: no)
[    7.101097] [Firmware Bug]: ACPI: No _BQC method, cannot determine initial brightness
[    7.102098] acpi device:3a: registered as cooling_device0
[    7.102233] input: Video Bus as /devices/LNXSYSTM:00/LNXSYBUS:00/PNP0A08:00/LNXVIDEO:01/input/input8
[    7.140388] [drm] Initialized drm 1.1.0 20060810
[    7.176325] input: HD-Audio Generic HDMI/DP,pcm=3 as /devices/pci0000:00/0000:00:01.1/sound/card0/input9
[    7.205219] ACPI: Battery Slot [BAT1] (battery present)
[    7.206805] ACPI: AC Adapter [ACAD] (on-line)
[    7.216842] Non-volatile memory driver v1.3
[    7.219017] snd_hda_codec_realtek hdaudioC1D0: autoconfig for ALC269VC: line_outs=1 (0x14/0x0/0x0/0x0/0x0) type:speaker
[    7.219030] snd_hda_codec_realtek hdaudioC1D0:    speaker_outs=0 (0x0/0x0/0x0/0x0/0x0)
[    7.219035] snd_hda_codec_realtek hdaudioC1D0:    hp_outs=1 (0x15/0x0/0x0/0x0/0x0)
[    7.219039] snd_hda_codec_realtek hdaudioC1D0:    mono: mono_out=0x0
[    7.219043] snd_hda_codec_realtek hdaudioC1D0:    inputs:
[    7.219048] snd_hda_codec_realtek hdaudioC1D0:      Mic=0x18
[    7.219052] snd_hda_codec_realtek hdaudioC1D0:      Internal Mic=0x12
[    7.238830] thinkpad_acpi: ThinkPad ACPI Extras v0.25
[    7.238838] thinkpad_acpi: http://ibm-acpi.sf.net/
[    7.238841] thinkpad_acpi: ThinkPad BIOS HMET93WW (2.53 ), EC unknown
[    7.238844] thinkpad_acpi: Lenovo ThinkPad Edge E135, model 335963G
[    7.252574] thinkpad_acpi: Unsupported brightness interface, please contact ibm-acpi-devel@lists.sourceforge.net
[    7.254299] thinkpad_acpi: radio switch found; radios are enabled
[    7.254369] thinkpad_acpi: possible tablet mode switch found; ThinkPad in laptop mode
[    7.254406] thinkpad_acpi: This ThinkPad has standard ACPI backlight brightness control, supported by the ACPI video driver
[    7.254409] thinkpad_acpi: Disabling thinkpad-acpi brightness events by default...
[    7.260557] thinkpad_acpi: rfkill switch tpacpi_bluetooth_sw: radio is unblocked
[    7.289222] input: ThinkPad Extra Buttons as /devices/platform/thinkpad_acpi/input/input11
[    7.317760] bcma: bus0: Found chip with id 43228, rev 0x00 and package 0x08
[    7.317798] bcma: bus0: Core 0 found: ChipCommon (manuf 0x4BF, id 0x800, rev 0x25, class 0x0)
[    7.317818] bcma: bus0: Core 1 found: IEEE 802.11 (manuf 0x4BF, id 0x812, rev 0x1E, class 0x0)
[    7.317854] bcma: bus0: Core 2 found: PCIe (manuf 0x4BF, id 0x820, rev 0x12, class 0x0)
[    7.317873] bcma: bus0: Core 3 found: SDIO Device (manuf 0x4BF, id 0x829, rev 0x07, class 0x0)
[    7.322109] input: HDA Digital PCBeep as /devices/pci0000:00/0000:00:14.2/sound/card1/input10
[    7.322398] input: HD-Audio Generic Mic as /devices/pci0000:00/0000:00:14.2/sound/card1/input12
[    7.322470] input: HD-Audio Generic Headphone as /devices/pci0000:00/0000:00:14.2/sound/card1/input13
[    7.330453] bcma: bus0: Bus registered
[    7.334325] [drm] radeon kernel modesetting enabled.
[    7.345769] ACPI Warning: SystemIO range 0x0000000000000B00-0x0000000000000B07 conflicts with OpRegion 0x0000000000000B00-0x0000000000000B0F (\_SB_.PCI0.SMB_.SMB0) (20150818/utaddress-254)
[    7.345787] ACPI: If an ACPI driver is available for this device, you should use it instead of the native driver
[    7.368475] CRAT table not found
[    7.368483] Finished initializing topology ret=0
[    7.378026] kfd kfd: Initialized module
[    7.380018] [drm] initializing kernel modesetting (PALM 0x1002:0x9808 0x17AA:0x5105).
[    7.380113] [drm] register mmio base: 0xF0B00000
[    7.380116] [drm] register mmio size: 262144
[    7.380215] ATOM BIOS: Lenovo
[    7.380291] radeon 0000:00:01.0: VRAM: 384M 0x0000000000000000 - 0x0000000017FFFFFF (384M used)
[    7.380296] radeon 0000:00:01.0: GTT: 1024M 0x0000000018000000 - 0x0000000057FFFFFF
[    7.380301] [drm] Detected VRAM RAM=384M, BAR=256M
[    7.380303] [drm] RAM width 32bits DDR
[    7.387560] [TTM] Zone  kernel: Available graphics memory: 3781862 kiB
[    7.387568] [TTM] Zone   dma32: Available graphics memory: 2097152 kiB
[    7.387571] [TTM] Initializing pool allocator
[    7.387585] [TTM] Initializing DMA pool allocator
[    7.387633] [drm] radeon: 384M of VRAM memory ready
[    7.387636] [drm] radeon: 1024M of GTT memory ready.
[    7.387676] [drm] Loading PALM Microcode
[    7.393625] radeon 0000:00:01.0: firmware: direct-loading firmware radeon/PALM_pfp.bin
[    7.394530] radeon 0000:00:01.0: firmware: direct-loading firmware radeon/PALM_me.bin
[    7.395673] radeon 0000:00:01.0: firmware: direct-loading firmware radeon/SUMO_rlc.bin
[    7.395693] [drm] Internal thermal controller without fan control
[    7.395799] [drm] Found smc ucode version: 0x00010601
[    7.395900] [drm] radeon: dpm initialized
[    7.405086] radeon 0000:00:01.0: firmware: direct-loading firmware radeon/SUMO_uvd.bin
[    7.405198] [drm] GART: num cpu pages 262144, num gpu pages 262144
[    7.412931] [drm] PCIE GART of 1024M enabled (table at 0x0000000000274000).
[    7.424180] radeon 0000:00:01.0: WB enabled
[    7.424194] radeon 0000:00:01.0: fence driver on ring 0 use gpu addr 0x0000000018000c00 and cpu addr 0xffff8801fb635c00
[    7.424199] radeon 0000:00:01.0: fence driver on ring 3 use gpu addr 0x0000000018000c0c and cpu addr 0xffff8801fb635c0c
[    7.424971] radeon 0000:00:01.0: fence driver on ring 5 use gpu addr 0x0000000000072118 and cpu addr 0xffffc90001432118
[    7.424976] [drm] Supports vblank timestamp caching Rev 2 (21.10.2013).
[    7.424978] [drm] Driver supports precise vblank timestamp query.
[    7.424982] radeon 0000:00:01.0: radeon: MSI limited to 32-bit
[    7.425346] radeon 0000:00:01.0: radeon: using MSI.
[    7.425392] [drm] radeon: irq initialized.
[    7.443186] [drm] ring test on 0 succeeded in 1 usecs
[    7.443201] [drm] ring test on 3 succeeded in 3 usecs
[    7.454119] input: PC Speaker as /devices/platform/pcspkr/input/input16
[    7.506623] EXT4-fs (dm-1): re-mounted. Opts: discard,errors=remount-ro
[    7.507100] [drm] ring test on 5 succeeded in 1 usecs
[    7.520106] kvm: Nested Virtualization enabled
[    7.520116] kvm: Nested Paging enabled
[    7.530977] [drm] UVD initialized successfully.
[    7.533098] [drm] ib test on ring 0 succeeded in 0 usecs
[    7.533139] [drm] ib test on ring 3 succeeded in 0 usecs
[    7.812715] random: nonblocking pool is initialized
[    8.008159] psmouse serio4: synaptics: queried max coordinates: x [..5768], y [..5236]
[    8.011846] EXT4-fs (dm-2): mounted filesystem with ordered data mode. Opts: discard
[    8.051617] [drm] ib test on ring 5 succeeded
[    8.064298] psmouse serio4: synaptics: queried min coordinates: x [1172..], y [616..]
[    8.142333] psmouse serio4: synaptics: Touchpad model: 1, fw: 8.1, id: 0x1e2b1, caps: 0xd002a3/0x940300/0x126c00/0x0, board id: 2290, fw id: 1212745
[    8.142359] psmouse serio4: synaptics: serio: Synaptics pass-through port at isa0060/serio4/input0
[    8.175468] [drm] radeon atom DIG backlight initialized
[    8.175483] [drm] Radeon Display Connectors
[    8.175486] [drm] Connector 0:
[    8.175489] [drm]   LVDS-1
[    8.175492] [drm]   HPD1
[    8.175496] [drm]   DDC: 0x6430 0x6430 0x6434 0x6434 0x6438 0x6438 0x643c 0x643c
[    8.175499] [drm]   Encoders:
[    8.175501] [drm]     LCD1: INTERNAL_UNIPHY
[    8.175504] [drm] Connector 1:
[    8.175506] [drm]   HDMI-A-1
[    8.175508] [drm]   HPD2
[    8.175511] [drm]   DDC: 0x6440 0x6440 0x6444 0x6444 0x6448 0x6448 0x644c 0x644c
[    8.175513] [drm]   Encoders:
[    8.175515] [drm]     DFP1: INTERNAL_UNIPHY
[    8.175517] [drm] Connector 2:
[    8.175519] [drm]   VGA-1
[    8.175522] [drm]   DDC: 0x64d8 0x64d8 0x64dc 0x64dc 0x64e0 0x64e0 0x64e4 0x64e4
[    8.175524] [drm]   Encoders:
[    8.175526] [drm]     CRT1: INTERNAL_KLDSCP_DAC1
[    8.184710] EXT4-fs (dm-3): mounted filesystem with ordered data mode. Opts: discard
[    8.186145] input: SynPS/2 Synaptics TouchPad as /devices/platform/i8042/serio4/input/input18
[    8.222543] EXT4-fs (dm-5): mounted filesystem with ordered data mode. Opts: discard
[    8.228924] b43-phy0: Broadcom 43228 WLAN found (core revision 30)
[    8.229368] b43-phy0: Found PHY: Analog 9, Type 4 (N), Revision 16
[    8.229378] b43-phy0: Found Radio: Manuf 0x17F, ID 0x2057, Revision 9, Version 1
[    8.230135] Broadcom 43xx driver loaded [ Features: PMNLS ]
[    8.246128] b43 bcma0:1: firmware: direct-loading firmware b43/ucode30_mimo.fw
[    8.249011] b43 bcma0:1: firmware: direct-loading firmware b43/n16initvals30.fw
[    8.253589] b43 bcma0:1: firmware: direct-loading firmware b43/n16bsinitvals30.fw
[    8.273132] cfg80211: World regulatory domain updated:
[    8.273144] cfg80211:  DFS Master region: unset
[    8.273147] cfg80211:   (start_freq - end_freq @ bandwidth), (max_antenna_gain, max_eirp), (dfs_cac_time)
[    8.273153] cfg80211:   (2402000 KHz - 2472000 KHz @ 40000 KHz), (N/A, 2000 mBm), (N/A)
[    8.273157] cfg80211:   (2457000 KHz - 2482000 KHz @ 40000 KHz), (N/A, 2000 mBm), (N/A)
[    8.273161] cfg80211:   (2474000 KHz - 2494000 KHz @ 20000 KHz), (N/A, 2000 mBm), (N/A)
[    8.273165] cfg80211:   (5170000 KHz - 5250000 KHz @ 80000 KHz, 160000 KHz AUTO), (N/A, 2000 mBm), (N/A)
[    8.273169] cfg80211:   (5250000 KHz - 5330000 KHz @ 80000 KHz, 160000 KHz AUTO), (N/A, 2000 mBm), (0 s)
[    8.273173] cfg80211:   (5490000 KHz - 5730000 KHz @ 160000 KHz), (N/A, 2000 mBm), (0 s)
[    8.273176] cfg80211:   (5735000 KHz - 5835000 KHz @ 80000 KHz), (N/A, 2000 mBm), (N/A)
[    8.273180] cfg80211:   (57240000 KHz - 63720000 KHz @ 2160000 KHz), (N/A, 0 mBm), (N/A)
[    8.303276] EXT4-fs (dm-4): mounted filesystem with ordered data mode. Opts: discard
[    8.310238] cfg80211: Regulatory domain changed to country: DE
[    8.310250] cfg80211:  DFS Master region: ETSI
[    8.310253] cfg80211:   (start_freq - end_freq @ bandwidth), (max_antenna_gain, max_eirp), (dfs_cac_time)
[    8.310259] cfg80211:   (2400000 KHz - 2483500 KHz @ 40000 KHz), (N/A, 2000 mBm), (N/A)
[    8.310263] cfg80211:   (5150000 KHz - 5250000 KHz @ 80000 KHz, 200000 KHz AUTO), (N/A, 2000 mBm), (N/A)
[    8.310268] cfg80211:   (5250000 KHz - 5350000 KHz @ 80000 KHz, 200000 KHz AUTO), (N/A, 2000 mBm), (0 s)
[    8.310272] cfg80211:   (5470000 KHz - 5725000 KHz @ 160000 KHz), (N/A, 2698 mBm), (0 s)
[    8.310276] cfg80211:   (57000000 KHz - 66000000 KHz @ 2160000 KHz), (N/A, 4000 mBm), (N/A)
[    8.313561] ieee80211 phy0: Selected rate control algorithm 'minstrel_ht'
[    8.609337] [drm] fb mappable at 0xE0478000
[    8.609346] [drm] vram apper at 0xE0000000
[    8.609350] [drm] size 4325376
[    8.609353] [drm] fb depth is 24
[    8.609355] [drm]    pitch is 5632
[    8.612616] fbcon: radeondrmfb (fb0) is primary device
[    8.649336] Bluetooth: Core ver 2.20
[    8.649373] NET: Registered protocol family 31
[    8.649375] Bluetooth: HCI device and connection manager initialized
[    8.649383] Bluetooth: HCI socket layer initialized
[    8.649388] Bluetooth: L2CAP socket layer initialized
[    8.649399] Bluetooth: SCO socket layer initialized
[    8.663558] media: Linux media interface: v0.10
[    8.671772] usbcore: registered new interface driver btusb
[    8.681347] Bluetooth: hci0: BCM: chip id 63
[    8.683331] Bluetooth: hci0: BCM20702A1 (001.002.014) build 0000
[    8.683798] bluetooth hci0: firmware: failed to load brcm/BCM20702A1-0a5c-21f3.hcd (-2)
[    8.683802] bluetooth hci0: Direct firmware load for brcm/BCM20702A1-0a5c-21f3.hcd failed with error -2
[    8.683806] Bluetooth: hci0: BCM: Patch brcm/BCM20702A1-0a5c-21f3.hcd not found
[    8.684051] Linux video capture interface: v2.00
[    8.783535] uvcvideo: Found UVC 1.00 device Integrated Camera (5986:0299)
[    8.786290] input: Integrated Camera as /devices/pci0000:00/0000:00:13.2/usb4/4-4/4-4:1.0/input/input20
[    8.786798] usbcore: registered new interface driver uvcvideo
[    8.786801] USB Video Class driver (1.1.1)
[    9.195513] Console: switching to colour frame buffer device 170x48
[    9.203366] radeon 0000:00:01.0: fb0: radeondrmfb frame buffer device
[    9.221402] [drm] Initialized radeon 2.43.0 20080528 for 0000:00:01.0 on minor 0
[   10.193223] systemd-journald[303]: Received request to flush runtime journal from PID 1
[   10.262648] ip_tables: (C) 2000-2006 Netfilter Core Team
[   10.285695] nf_conntrack version 0.5.0 (65536 buckets, 262144 max)
[   10.389439] ip6_tables: (C) 2000-2006 Netfilter Core Team
[   10.841601] RPC: Registered named UNIX socket transport module.
[   10.841610] RPC: Registered udp transport module.
[   10.841613] RPC: Registered tcp transport module.
[   10.841616] RPC: Registered tcp NFSv4.1 backchannel transport module.
[   10.855472] FS-Cache: Loaded
[   10.887819] FS-Cache: Netfs 'nfs' registered for caching
[   10.927338] Installing knfsd (copyright (C) 1996 okir@monad.swb.de).
[   11.492474] Bluetooth: BNEP (Ethernet Emulation) ver 1.3
[   11.492487] Bluetooth: BNEP filters: protocol multicast
[   11.492501] Bluetooth: BNEP socket layer initialized
[   12.975640] psmouse serio5: trackpoint: IBM TrackPoint firmware: 0x0e, buttons: 3/3
[   13.205185] input: TPPS/2 IBM TrackPoint as /devices/platform/i8042/serio4/serio5/input/input19
[   59.801018] r8169 0000:03:00.0: firmware: direct-loading firmware rtl_nic/rtl8168e-3.fw
[   59.899380] r8169 0000:03:00.0 eth0: link down
[   59.899503] IPv6: ADDRCONF(NETDEV_UP): eth0: link is not ready
[   62.185500] r8169 0000:03:00.0 eth0: link up
[   62.185535] IPv6: ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready

--nextPart5036767.aVcEzaX8ML
Content-Disposition: attachment; filename="lspci.txt"
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="UTF-8"; name="lspci.txt"

00:00.0 Host bridge: Advanced Micro Devices, Inc. [AMD] Family 14h Processor Root Complex
	Subsystem: Lenovo Device 5105
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap- 66MHz+ UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 64

00:01.0 VGA compatible controller: Advanced Micro Devices, Inc. [AMD/ATI] Wrestler [Radeon HD 7340] (prog-if 00 [VGA controller])
	Subsystem: Lenovo Device 5105
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 32 bytes
	Interrupt: pin A routed to IRQ 32
	Region 0: Memory at e0000000 (32-bit, prefetchable) [size=256M]
	Region 1: I/O ports at 3000 [size=256]
	Region 2: Memory at f0b00000 (32-bit, non-prefetchable) [size=256K]
	Expansion ROM at <unassigned> [disabled]
	Capabilities: [50] Power Management version 3
		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [58] Express (v2) Root Complex Integrated Endpoint, MSI 00
		DevCap:	MaxPayload 128 bytes, PhantFunc 0
			ExtTag+ RBE+
		DevCtl:	Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
			RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop+
			MaxPayload 128 bytes, MaxReadReq 128 bytes
		DevSta:	CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr- TransPend-
		DevCap2: Completion Timeout: Not Supported, TimeoutDis-, LTR-, OBFF Not Supported
		DevCtl2: Completion Timeout: 50us to 50ms, TimeoutDis-, LTR-, OBFF Disabled
	Capabilities: [a0] MSI: Enable+ Count=1/1 Maskable- 64bit+
		Address: 00000000fee0300c  Data: 4172
	Capabilities: [100 v1] Vendor Specific Information: ID=0001 Rev=1 Len=010 <?>
	Kernel driver in use: radeon

00:01.1 Audio device: Advanced Micro Devices, Inc. [AMD/ATI] Wrestler HDMI Audio
	Subsystem: Lenovo Device 5105
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 32 bytes
	Interrupt: pin B routed to IRQ 31
	Region 0: Memory at f0b44000 (32-bit, non-prefetchable) [size=16K]
	Capabilities: [50] Power Management version 3
		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [58] Express (v2) Root Complex Integrated Endpoint, MSI 00
		DevCap:	MaxPayload 128 bytes, PhantFunc 0
			ExtTag+ RBE+
		DevCtl:	Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
			RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop+
			MaxPayload 128 bytes, MaxReadReq 128 bytes
		DevSta:	CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr- TransPend-
		DevCap2: Completion Timeout: Not Supported, TimeoutDis-, LTR-, OBFF Not Supported
		DevCtl2: Completion Timeout: 50us to 50ms, TimeoutDis-, LTR-, OBFF Disabled
	Capabilities: [a0] MSI: Enable+ Count=1/1 Maskable- 64bit+
		Address: 00000000fee0300c  Data: 4152
	Capabilities: [100 v1] Vendor Specific Information: ID=0001 Rev=1 Len=010 <?>
	Kernel driver in use: snd_hda_intel

00:05.0 PCI bridge: Advanced Micro Devices, Inc. [AMD] Family 14h Processor Root Port (prog-if 00 [Normal decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 32 bytes
	Bus: primary=00, secondary=02, subordinate=02, sec-latency=0
	I/O behind bridge: 0000f000-00000fff
	Memory behind bridge: f0a00000-f0afffff
	Prefetchable memory behind bridge: 00000000fff00000-00000000000fffff
	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort+ <SERR- <PERR-
	BridgeCtl: Parity- SERR- NoISA- VGA- MAbort- >Reset- FastB2B-
		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
	Capabilities: [50] Power Management version 3
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [58] Express (v2) Root Port (Slot+), MSI 00
		DevCap:	MaxPayload 128 bytes, PhantFunc 0
			ExtTag+ RBE+
		DevCtl:	Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
			RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop+
			MaxPayload 128 bytes, MaxReadReq 512 bytes
		DevSta:	CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr- TransPend-
		LnkCap:	Port #2, Speed 2.5GT/s, Width x1, ASPM L0s L1, Exit Latency L0s <64ns, L1 <1us
			ClockPM- Surprise- LLActRep+ BwNot+
		LnkCtl:	ASPM Disabled; RCB 64 bytes Disabled- CommClk+
			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
		LnkSta:	Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+ DLActive+ BWMgmt- ABWMgmt-
		SltCap:	AttnBtn- PwrCtrl- MRL- AttnInd- PwrInd- HotPlug- Surprise-
			Slot #5, PowerLimit 75.000W; Interlock- NoCompl+
		SltCtl:	Enable: AttnBtn- PwrFlt- MRL- PresDet- CmdCplt- HPIrq- LinkChg-
			Control: AttnInd Unknown, PwrInd Unknown, Power- Interlock-
		SltSta:	Status: AttnBtn- PowerFlt- MRL- CmdCplt- PresDet+ Interlock-
			Changed: MRL- PresDet+ LinkState+
		RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFatal- PMEIntEna- CRSVisible+
		RootCap: CRSVisible-
		RootSta: PME ReqID 0000, PMEStatus- PMEPending-
		DevCap2: Completion Timeout: Range ABCD, TimeoutDis+, LTR-, OBFF Not Supported ARIFwd-
		DevCtl2: Completion Timeout: 65ms to 210ms, TimeoutDis-, LTR-, OBFF Disabled ARIFwd-
		LnkCtl2: Target Link Speed: 2.5GT/s, EnterCompliance- SpeedDis+
			 Transmit Margin: Normal Operating Range, EnterModifiedCompliance- ComplianceSOS-
			 Compliance De-emphasis: -6dB
		LnkSta2: Current De-emphasis Level: -6dB, EqualizationComplete-, EqualizationPhase1-
			 EqualizationPhase2-, EqualizationPhase3-, LinkEqualizationRequest-
	Capabilities: [a0] MSI: Enable- Count=1/1 Maskable- 64bit-
		Address: 00000000  Data: 0000
	Capabilities: [b0] Subsystem: Advanced Micro Devices, Inc. [AMD] Device 1234
	Capabilities: [b8] HyperTransport: MSI Mapping Enable+ Fixed+
	Capabilities: [100 v1] Vendor Specific Information: ID=0001 Rev=1 Len=010 <?>
	Kernel driver in use: pcieport

00:06.0 PCI bridge: Advanced Micro Devices, Inc. [AMD] Family 14h Processor Root Port (prog-if 00 [Normal decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 32 bytes
	Bus: primary=00, secondary=03, subordinate=03, sec-latency=0
	I/O behind bridge: 00002000-00002fff
	Memory behind bridge: f0200000-f09fffff
	Prefetchable memory behind bridge: 00000000f0000000-00000000f00fffff
	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort+ <SERR- <PERR-
	BridgeCtl: Parity- SERR- NoISA- VGA- MAbort- >Reset- FastB2B-
		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
	Capabilities: [50] Power Management version 3
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [58] Express (v2) Root Port (Slot+), MSI 00
		DevCap:	MaxPayload 128 bytes, PhantFunc 0
			ExtTag+ RBE+
		DevCtl:	Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
			RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop+
			MaxPayload 128 bytes, MaxReadReq 512 bytes
		DevSta:	CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr- TransPend-
		LnkCap:	Port #3, Speed 2.5GT/s, Width x1, ASPM L0s L1, Exit Latency L0s <64ns, L1 <1us
			ClockPM- Surprise- LLActRep+ BwNot+
		LnkCtl:	ASPM Disabled; RCB 64 bytes Disabled- CommClk+
			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
		LnkSta:	Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+ DLActive+ BWMgmt- ABWMgmt-
		SltCap:	AttnBtn- PwrCtrl- MRL- AttnInd- PwrInd- HotPlug- Surprise-
			Slot #6, PowerLimit 75.000W; Interlock- NoCompl+
		SltCtl:	Enable: AttnBtn- PwrFlt- MRL- PresDet- CmdCplt- HPIrq- LinkChg-
			Control: AttnInd Unknown, PwrInd Unknown, Power- Interlock-
		SltSta:	Status: AttnBtn- PowerFlt- MRL- CmdCplt- PresDet+ Interlock-
			Changed: MRL- PresDet+ LinkState+
		RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFatal- PMEIntEna- CRSVisible+
		RootCap: CRSVisible-
		RootSta: PME ReqID 0000, PMEStatus- PMEPending-
		DevCap2: Completion Timeout: Range ABCD, TimeoutDis+, LTR-, OBFF Not Supported ARIFwd-
		DevCtl2: Completion Timeout: 65ms to 210ms, TimeoutDis-, LTR-, OBFF Disabled ARIFwd-
		LnkCtl2: Target Link Speed: 2.5GT/s, EnterCompliance- SpeedDis+
			 Transmit Margin: Normal Operating Range, EnterModifiedCompliance- ComplianceSOS-
			 Compliance De-emphasis: -6dB
		LnkSta2: Current De-emphasis Level: -6dB, EqualizationComplete-, EqualizationPhase1-
			 EqualizationPhase2-, EqualizationPhase3-, LinkEqualizationRequest-
	Capabilities: [a0] MSI: Enable- Count=1/1 Maskable- 64bit-
		Address: 00000000  Data: 0000
	Capabilities: [b0] Subsystem: Advanced Micro Devices, Inc. [AMD] Device 1234
	Capabilities: [b8] HyperTransport: MSI Mapping Enable+ Fixed+
	Capabilities: [100 v1] Vendor Specific Information: ID=0001 Rev=1 Len=010 <?>
	Kernel driver in use: pcieport

00:07.0 PCI bridge: Advanced Micro Devices, Inc. [AMD] Family 14h Processor Root Port (prog-if 00 [Normal decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 32 bytes
	Bus: primary=00, secondary=04, subordinate=04, sec-latency=0
	I/O behind bridge: 00001000-00001fff
	Memory behind bridge: f0100000-f01fffff
	Prefetchable memory behind bridge: 00000000f0c00000-00000000f0dfffff
	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort+ <SERR- <PERR-
	BridgeCtl: Parity- SERR- NoISA- VGA- MAbort- >Reset- FastB2B-
		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
	Capabilities: [50] Power Management version 3
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [58] Express (v2) Root Port (Slot+), MSI 00
		DevCap:	MaxPayload 128 bytes, PhantFunc 0
			ExtTag+ RBE+
		DevCtl:	Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
			RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop+
			MaxPayload 128 bytes, MaxReadReq 512 bytes
		DevSta:	CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr- TransPend-
		LnkCap:	Port #4, Speed 2.5GT/s, Width x1, ASPM L0s L1, Exit Latency L0s <64ns, L1 <1us
			ClockPM- Surprise- LLActRep+ BwNot+
		LnkCtl:	ASPM Disabled; RCB 64 bytes Disabled- CommClk+
			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
		LnkSta:	Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+ DLActive+ BWMgmt- ABWMgmt-
		SltCap:	AttnBtn- PwrCtrl- MRL- AttnInd- PwrInd- HotPlug+ Surprise-
			Slot #7, PowerLimit 75.000W; Interlock- NoCompl+
		SltCtl:	Enable: AttnBtn- PwrFlt- MRL- PresDet+ CmdCplt- HPIrq+ LinkChg+
			Control: AttnInd Unknown, PwrInd Unknown, Power- Interlock-
		SltSta:	Status: AttnBtn- PowerFlt- MRL- CmdCplt- PresDet+ Interlock-
			Changed: MRL- PresDet- LinkState-
		RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFatal- PMEIntEna- CRSVisible+
		RootCap: CRSVisible-
		RootSta: PME ReqID 0000, PMEStatus- PMEPending-
		DevCap2: Completion Timeout: Range ABCD, TimeoutDis+, LTR-, OBFF Not Supported ARIFwd-
		DevCtl2: Completion Timeout: 65ms to 210ms, TimeoutDis-, LTR-, OBFF Disabled ARIFwd-
		LnkCtl2: Target Link Speed: 2.5GT/s, EnterCompliance- SpeedDis+
			 Transmit Margin: Normal Operating Range, EnterModifiedCompliance- ComplianceSOS-
			 Compliance De-emphasis: -6dB
		LnkSta2: Current De-emphasis Level: -6dB, EqualizationComplete-, EqualizationPhase1-
			 EqualizationPhase2-, EqualizationPhase3-, LinkEqualizationRequest-
	Capabilities: [a0] MSI: Enable+ Count=1/1 Maskable- 64bit-
		Address: fee0300c  Data: 4171
	Capabilities: [b0] Subsystem: Advanced Micro Devices, Inc. [AMD] Device 1234
	Capabilities: [b8] HyperTransport: MSI Mapping Enable+ Fixed+
	Capabilities: [100 v1] Vendor Specific Information: ID=0001 Rev=1 Len=010 <?>
	Kernel driver in use: pcieport

00:10.0 USB controller: Advanced Micro Devices, Inc. [AMD] FCH USB XHCI Controller (rev 03) (prog-if 30 [XHCI])
	Subsystem: Lenovo Device 5105
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 32 bytes
	Interrupt: pin A routed to IRQ 0
	Region 0: Memory at f0b48000 (64-bit, non-prefetchable) [size=8K]
	Capabilities: [50] Power Management version 3
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 NoSoftRst+ PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [70] MSI: Enable- Count=1/8 Maskable- 64bit+
		Address: 0000000000000000  Data: 0000
	Capabilities: [90] MSI-X: Enable+ Count=8 Masked-
		Vector table: BAR=0 offset=00001000
		PBA: BAR=0 offset=00001080
	Capabilities: [a0] Express (v2) Root Complex Integrated Endpoint, MSI 00
		DevCap:	MaxPayload 128 bytes, PhantFunc 0
			ExtTag- RBE+
		DevCtl:	Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
			RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop+
			MaxPayload 128 bytes, MaxReadReq 512 bytes
		DevSta:	CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr+ TransPend-
		DevCap2: Completion Timeout: Not Supported, TimeoutDis+, LTR+, OBFF Not Supported
		DevCtl2: Completion Timeout: 50us to 50ms, TimeoutDis-, LTR-, OBFF Disabled
	Capabilities: [100 v1] Latency Tolerance Reporting
		Max snoop latency: 0ns
		Max no snoop latency: 0ns
	Kernel driver in use: xhci_hcd

00:11.0 SATA controller: Advanced Micro Devices, Inc. [AMD] FCH SATA Controller [AHCI mode] (prog-if 01 [AHCI 1.0])
	Subsystem: Lenovo Device 5105
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+
	Status: Cap+ 66MHz+ UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 64
	Interrupt: pin A routed to IRQ 30
	Region 0: I/O ports at 3118 [size=8]
	Region 1: I/O ports at 3124 [size=4]
	Region 2: I/O ports at 3110 [size=8]
	Region 3: I/O ports at 3120 [size=4]
	Region 4: I/O ports at 3100 [size=16]
	Region 5: Memory at f0b4d000 (32-bit, non-prefetchable) [size=2K]
	Capabilities: [50] MSI: Enable+ Count=1/4 Maskable- 64bit+
		Address: 00000000fee0100c  Data: 4122
	Capabilities: [70] SATA HBA v1.0 InCfgSpace
	Kernel driver in use: ahci

00:12.0 USB controller: Advanced Micro Devices, Inc. [AMD] FCH USB OHCI Controller (rev 11) (prog-if 10 [OHCI])
	Subsystem: Lenovo Device 5105
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap- 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 64, Cache Line Size: 32 bytes
	Interrupt: pin A routed to IRQ 18
	Region 0: Memory at f0b4c000 (32-bit, non-prefetchable) [size=4K]
	Kernel driver in use: ohci-pci

00:12.2 USB controller: Advanced Micro Devices, Inc. [AMD] FCH USB EHCI Controller (rev 11) (prog-if 20 [EHCI])
	Subsystem: Lenovo Device 5105
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 64, Cache Line Size: 32 bytes
	Interrupt: pin B routed to IRQ 17
	Region 0: Memory at f0b4d900 (32-bit, non-prefetchable) [size=256]
	Capabilities: [c0] Power Management version 2
		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA PME(D0+,D1+,D2+,D3hot+,D3cold-)
		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
		Bridge: PM- B3+
	Capabilities: [e4] Debug port: BAR=1 offset=00e0
	Kernel driver in use: ehci-pci

00:13.0 USB controller: Advanced Micro Devices, Inc. [AMD] FCH USB OHCI Controller (rev 11) (prog-if 10 [OHCI])
	Subsystem: Lenovo Device 5105
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap- 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 64, Cache Line Size: 32 bytes
	Interrupt: pin A routed to IRQ 18
	Region 0: Memory at f0b4b000 (32-bit, non-prefetchable) [size=4K]
	Kernel driver in use: ohci-pci

00:13.2 USB controller: Advanced Micro Devices, Inc. [AMD] FCH USB EHCI Controller (rev 11) (prog-if 20 [EHCI])
	Subsystem: Lenovo Device 5105
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 64, Cache Line Size: 32 bytes
	Interrupt: pin B routed to IRQ 17
	Region 0: Memory at f0b4d800 (32-bit, non-prefetchable) [size=256]
	Capabilities: [c0] Power Management version 2
		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA PME(D0+,D1+,D2+,D3hot+,D3cold-)
		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
		Bridge: PM- B3+
	Capabilities: [e4] Debug port: BAR=1 offset=00e0
	Kernel driver in use: ehci-pci

00:14.0 SMBus: Advanced Micro Devices, Inc. [AMD] FCH SMBus Controller (rev 14)
	Subsystem: Lenovo Device 5105
	Control: I/O+ Mem+ BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+
	Status: Cap- 66MHz+ UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-

00:14.2 Audio device: Advanced Micro Devices, Inc. [AMD] FCH Azalia Controller (rev 01)
	Subsystem: Lenovo Device 5105
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=slow >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 64, Cache Line Size: 32 bytes
	Interrupt: pin A routed to IRQ 16
	Region 0: Memory at f0b40000 (64-bit, non-prefetchable) [size=16K]
	Capabilities: [50] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=55mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
	Kernel driver in use: snd_hda_intel

00:14.3 ISA bridge: Advanced Micro Devices, Inc. [AMD] FCH LPC Bridge (rev 11)
	Subsystem: Lenovo Device 5105
	Control: I/O+ Mem+ BusMaster+ SpecCycle+ MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap- 66MHz+ UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0

00:14.4 PCI bridge: Advanced Micro Devices, Inc. [AMD] FCH PCI Bridge (rev 40) (prog-if 01 [Subtractive decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap- 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 64
	Bus: primary=00, secondary=05, subordinate=05, sec-latency=64
	I/O behind bridge: 0000f000-00000fff
	Memory behind bridge: fff00000-000fffff
	Prefetchable memory behind bridge: fff00000-000fffff
	Secondary status: 66MHz- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort+ <SERR- <PERR-
	BridgeCtl: Parity- SERR- NoISA- VGA- MAbort- >Reset- FastB2B-
		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-

00:14.5 USB controller: Advanced Micro Devices, Inc. [AMD] FCH USB OHCI Controller (rev 11) (prog-if 10 [OHCI])
	Subsystem: Lenovo Device 5105
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap- 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 64, Cache Line Size: 32 bytes
	Interrupt: pin C routed to IRQ 18
	Region 0: Memory at f0b4a000 (32-bit, non-prefetchable) [size=4K]
	Kernel driver in use: ohci-pci

00:18.0 Host bridge: Advanced Micro Devices, Inc. [AMD] Family 12h/14h Processor Function 0 (rev 43)
	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-

00:18.1 Host bridge: Advanced Micro Devices, Inc. [AMD] Family 12h/14h Processor Function 1
	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-

00:18.2 Host bridge: Advanced Micro Devices, Inc. [AMD] Family 12h/14h Processor Function 2
	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-

00:18.3 Host bridge: Advanced Micro Devices, Inc. [AMD] Family 12h/14h Processor Function 3
	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Capabilities: [f0] Secure device <?>
	Kernel driver in use: k10temp

00:18.4 Host bridge: Advanced Micro Devices, Inc. [AMD] Family 12h/14h Processor Function 4
	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-

00:18.5 Host bridge: Advanced Micro Devices, Inc. [AMD] Family 12h/14h Processor Function 6
	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-

00:18.6 Host bridge: Advanced Micro Devices, Inc. [AMD] Family 12h/14h Processor Function 5
	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-

00:18.7 Host bridge: Advanced Micro Devices, Inc. [AMD] Family 12h/14h Processor Function 7
	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-

02:00.0 Network controller: Broadcom Corporation BCM43228 802.11a/b/g/n
	Subsystem: Broadcom Corporation Device 0607
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 32 bytes
	Interrupt: pin A routed to IRQ 17
	Region 0: Memory at f0a00000 (64-bit, non-prefetchable) [size=16K]
	Capabilities: [40] Power Management version 3
		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 NoSoftRst+ PME-Enable- DSel=0 DScale=2 PME-
	Capabilities: [58] Vendor Specific Information: Len=78 <?>
	Capabilities: [48] MSI: Enable- Count=1/1 Maskable- 64bit+
		Address: 0000000000000000  Data: 0000
	Capabilities: [d0] Express (v1) Endpoint, MSI 00
		DevCap:	MaxPayload 128 bytes, PhantFunc 0, Latency L0s <4us, L1 unlimited
			ExtTag+ AttnBtn- AttnInd- PwrInd- RBE+ FLReset-
		DevCtl:	Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
			RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
			MaxPayload 128 bytes, MaxReadReq 512 bytes
		DevSta:	CorrErr+ UncorrErr- FatalErr- UnsuppReq+ AuxPwr+ TransPend-
		LnkCap:	Port #0, Speed 2.5GT/s, Width x1, ASPM L1, Exit Latency L0s <4us, L1 <64us
			ClockPM+ Surprise- LLActRep+ BwNot-
		LnkCtl:	ASPM Disabled; RCB 64 bytes Disabled- CommClk+
			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
		LnkSta:	Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+ DLActive+ BWMgmt- ABWMgmt-
	Capabilities: [100 v1] Advanced Error Reporting
		UESta:	DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
		UEMsk:	DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
		UESvrt:	DLP+ SDES- TLP- FCP+ CmpltTO- CmpltAbrt- UnxCmplt- RxOF+ MalfTLP+ ECRC- UnsupReq- ACSViol-
		CESta:	RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr+
		CEMsk:	RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr+
		AERCap:	First Error Pointer: 14, GenCap+ CGenEn- ChkCap+ ChkEn-
	Capabilities: [13c v1] Virtual Channel
		Caps:	LPEVC=0 RefClk=100ns PATEntryBits=1
		Arb:	Fixed- WRR32- WRR64- WRR128-
		Ctrl:	ArbSelect=Fixed
		Status:	InProgress-
		VC0:	Caps:	PATOffset=00 MaxTimeSlots=1 RejSnoopTrans-
			Arb:	Fixed- WRR32- WRR64- WRR128- TWRR128- WRR256-
			Ctrl:	Enable+ ID=0 ArbSelect=Fixed TC/VC=ff
			Status:	NegoPending- InProgress-
	Capabilities: [160 v1] Device Serial Number 00-00-52-ff-ff-43-24-fd
	Capabilities: [16c v1] Power Budgeting <?>
	Kernel driver in use: bcma-pci-bridge

03:00.0 Ethernet controller: Realtek Semiconductor Co., Ltd. RTL8111/8168/8411 PCI Express Gigabit Ethernet Controller (rev 07)
	Subsystem: Lenovo Device 5105
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 32 bytes
	Interrupt: pin A routed to IRQ 28
	Region 0: I/O ports at 2000 [size=256]
	Region 2: Memory at f0004000 (64-bit, prefetchable) [size=4K]
	Region 4: Memory at f0000000 (64-bit, prefetchable) [size=16K]
	Capabilities: [40] Power Management version 3
		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=375mA PME(D0+,D1+,D2+,D3hot+,D3cold+)
		Status: D0 NoSoftRst+ PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [50] MSI: Enable+ Count=1/1 Maskable- 64bit+
		Address: 00000000fee0100c  Data: 41b1
	Capabilities: [70] Express (v2) Endpoint, MSI 01
		DevCap:	MaxPayload 128 bytes, PhantFunc 0, Latency L0s <512ns, L1 <64us
			ExtTag- AttnBtn- AttnInd- PwrInd- RBE+ FLReset-
		DevCtl:	Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
			RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop-
			MaxPayload 128 bytes, MaxReadReq 4096 bytes
		DevSta:	CorrErr+ UncorrErr- FatalErr- UnsuppReq+ AuxPwr+ TransPend-
		LnkCap:	Port #0, Speed 2.5GT/s, Width x1, ASPM L0s L1, Exit Latency L0s unlimited, L1 <64us
			ClockPM+ Surprise- LLActRep- BwNot-
		LnkCtl:	ASPM Disabled; RCB 64 bytes Disabled- CommClk+
			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
		LnkSta:	Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+ DLActive- BWMgmt- ABWMgmt-
		DevCap2: Completion Timeout: Range ABCD, TimeoutDis+, LTR-, OBFF Not Supported
		DevCtl2: Completion Timeout: 50us to 50ms, TimeoutDis-, LTR-, OBFF Disabled
		LnkCtl2: Target Link Speed: 2.5GT/s, EnterCompliance- SpeedDis-
			 Transmit Margin: Normal Operating Range, EnterModifiedCompliance- ComplianceSOS-
			 Compliance De-emphasis: -6dB
		LnkSta2: Current De-emphasis Level: -6dB, EqualizationComplete-, EqualizationPhase1-
			 EqualizationPhase2-, EqualizationPhase3-, LinkEqualizationRequest-
	Capabilities: [b0] MSI-X: Enable- Count=4 Masked-
		Vector table: BAR=4 offset=00000000
		PBA: BAR=4 offset=00000800
	Capabilities: [d0] Vital Product Data
		No end tag found
	Capabilities: [100 v1] Advanced Error Reporting
		UESta:	DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq+ ACSViol-
		UEMsk:	DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
		UESvrt:	DLP+ SDES+ TLP- FCP+ CmpltTO- CmpltAbrt- UnxCmplt- RxOF+ MalfTLP+ ECRC- UnsupReq- ACSViol-
		CESta:	RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr+
		CEMsk:	RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr+
		AERCap:	First Error Pointer: 14, GenCap+ CGenEn- ChkCap+ ChkEn-
	Capabilities: [140 v1] Virtual Channel
		Caps:	LPEVC=0 RefClk=100ns PATEntryBits=1
		Arb:	Fixed- WRR32- WRR64- WRR128-
		Ctrl:	ArbSelect=Fixed
		Status:	InProgress-
		VC0:	Caps:	PATOffset=00 MaxTimeSlots=1 RejSnoopTrans-
			Arb:	Fixed- WRR32- WRR64- WRR128- TWRR128- WRR256-
			Ctrl:	Enable+ ID=0 ArbSelect=Fixed TC/VC=ff
			Status:	NegoPending- InProgress-
	Capabilities: [160 v1] Device Serial Number 8a-00-00-00-68-4c-e0-00
	Kernel driver in use: r8169

04:00.0 Unassigned class [ff00]: Realtek Semiconductor Co., Ltd. RTS5209 PCI Express Card Reader (rev 01)
	Subsystem: Lenovo Device 5105
	Physical Slot: 7
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 32 bytes
	Interrupt: pin A routed to IRQ 29
	Region 0: Memory at f0100000 (32-bit, non-prefetchable) [size=4K]
	Expansion ROM at f0110000 [disabled] [size=64K]
	Capabilities: [40] Power Management version 3
		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=375mA PME(D0-,D1+,D2+,D3hot+,D3cold-)
		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [50] MSI: Enable+ Count=1/1 Maskable- 64bit+
		Address: 00000000fee0300c  Data: 41d1
	Capabilities: [70] Express (v2) Endpoint, MSI 00
		DevCap:	MaxPayload 128 bytes, PhantFunc 0, Latency L0s <1us, L1 <8us
			ExtTag- AttnBtn- AttnInd- PwrInd- RBE+ FLReset-
		DevCtl:	Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
			RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop-
			MaxPayload 128 bytes, MaxReadReq 512 bytes
		DevSta:	CorrErr+ UncorrErr- FatalErr- UnsuppReq+ AuxPwr- TransPend-
		LnkCap:	Port #0, Speed 2.5GT/s, Width x1, ASPM L0s L1, Exit Latency L0s unlimited, L1 <64us
			ClockPM+ Surprise- LLActRep- BwNot-
		LnkCtl:	ASPM Disabled; RCB 64 bytes Disabled- CommClk+
			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
		LnkSta:	Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+ DLActive- BWMgmt- ABWMgmt-
		DevCap2: Completion Timeout: Not Supported, TimeoutDis+, LTR-, OBFF Not Supported
		DevCtl2: Completion Timeout: 50us to 50ms, TimeoutDis-, LTR-, OBFF Disabled
		LnkCtl2: Target Link Speed: 2.5GT/s, EnterCompliance- SpeedDis-
			 Transmit Margin: Normal Operating Range, EnterModifiedCompliance- ComplianceSOS-
			 Compliance De-emphasis: -6dB
		LnkSta2: Current De-emphasis Level: -6dB, EqualizationComplete-, EqualizationPhase1-
			 EqualizationPhase2-, EqualizationPhase3-, LinkEqualizationRequest-
	Capabilities: [100 v1] Advanced Error Reporting
		UESta:	DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
		UEMsk:	DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
		UESvrt:	DLP+ SDES+ TLP- FCP+ CmpltTO- CmpltAbrt- UnxCmplt- RxOF+ MalfTLP+ ECRC- UnsupReq- ACSViol-
		CESta:	RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr+
		CEMsk:	RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr+
		AERCap:	First Error Pointer: 00, GenCap+ CGenEn- ChkCap+ ChkEn-
	Capabilities: [140 v1] Device Serial Number 00-00-00-01-00-4c-e0-00
	Kernel driver in use: rtsx_pci


--nextPart5036767.aVcEzaX8ML--

--nextPart5294008.WNS8GduONS
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part.
Content-Transfer-Encoding: 7Bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJWbJUWAAoJEIHqZH0kK9IVGdcP/iXnIZTvj7nKhjhZJevche79
CK9dzHKVtCzmUXByLTCvletH1bo/mOI2g65KVorIGaYsBMxihd6dcgQUErqEOsPr
cP+SrMsKyHvH5Nturl1gSDRdSfTuvbVlzvvreK7gbg4mhb2TBln8I8hC5BGYnFkU
xIOAiwg6uc5FocVbyBpLduCknJQs0XK51iMenWVXR84ywZ1tjTdlRH4xH7gltNwa
uC2bawcjFHXI1kENghd72a4QgzPFP2VvNWJkWeOtU9vKpVAsoNun4UUDMboreht0
Uef1Yb7tXMugyv+TPO+pgWvS05TH6Pe6pUPI23gfM93+d73sCLI9CyoDsZEGmTOD
F0qSBkax5nd4FP4UWTEt33Zkr/4+0nPcrbQsHRDv/PuGNWXMF03Wa/gKHl6sroWt
UvD6+keJ++qByTpEPgQOzEOmUG7MdDpymyUCzEtcpwoNflYdIH7izHN9eaLhv05z
5XKANkcSN8T1i85ZOYiVxobrmK2DV8NffkAdEv++8fz6UujyRJMy09e3rsaEWXHH
XLxW3UEE6BBqvpA6NyUHf2pYOKIA78WFRXI4TikJ16OtV7z3yBXfAAdFY/l0yWKe
ZDgnB8ZwC5cXP289qPLvasS9ZmwKfr4Ro5GcE2NxkBYg3XySzIGULG9xbJgkmoB5
GRGq3VmmAYgmVojndaNK
=yb1c
-----END PGP SIGNATURE-----

--nextPart5294008.WNS8GduONS--
