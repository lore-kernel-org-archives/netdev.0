From: "Allan W. Nielsen" <allan.nielsen@microsemi.com>
Subject: Re: [lkp] [net]  af1fee9821:
 BUG:spinlock_trylock_failure_on_UP_on_CPU
Date: Mon, 7 Nov 2016 14:27:14 +0100
Message-ID: <20161107132714.GA10669@microsemi.com>
References: <20161107022628.GA21529@yexl-desktop>
 <20161107093148.GA27001@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: 8bit
Cc: kernel test robot <xiaolong.ye@intel.com>,
        Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>,
        "David S. Miller" <davem@davemloft.net>,
        LKML <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
        <lkp@01.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam02on0077.outbound.protection.outlook.com ([104.47.36.77]:47168
        "EHLO NAM02-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750980AbcKGN1e (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 7 Nov 2016 08:27:34 -0500
Content-Disposition: inline
In-Reply-To: <20161107093148.GA27001@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I tried to get this "lkp" up and running, but I had some troubles gettting
these scripts to work.

But it seems like it can be reproduced using th eprovided config file, and qemu.

Here is what I did:

# reproduce original bug
git reset --hard af1fee98219992ba2c12441a447719652ed7e983
mkdir bug-build
cp config-4.8.0-14895-gaf1fee9 bug-build/.config
make O=bug-build oldconfig
make O=bug-build -j8
qemu-system-x86_64 -enable-kvm -cpu host -smp 2 -m 4G -kernel \
    ../net-next/bug-build/arch/x86_64/boot/bzImage -nographic
<see-output-1-below>
# bug seemed to be re-produced


# Try previous version
git reset --hard 32ab0a38f0bd554cc45203ff4fdb6b0fdea6f025
make O=bug-build oldconfig
make O=bug-build -j8
qemu-system-x86_64 -enable-kvm -cpu host -smp 2 -m 4G -kernel \
    ../net-next/bug-build/arch/x86_64/boot/bzImage -nographic
<see-output-2-below>
# bug seemed to disappear


# Try the buggy revision again - but without MICROSEMI_PHY
git reset --hard af1fee98219992ba2c12441a447719652ed7e983
sed -e "/MICROSEMI_PHY/d" -i bug-build/.config
make O=bug-build oldconfig
cat bug-build/.config | grep MICROSEMI_PHY
qemu-system-x86_64 -enable-kvm -cpu host -smp 2 -m 4G -kernel \
    ../net-next/bug-build/arch/x86_64/boot/bzImage -nographic
<see-output-3-below>
# bug still seem to be there...


Not sure what this tells me, any hints are more than welcome.

Best regards
Allan W. Nielsen



Output 1 (af1fee98219992ba2c12441a447719652ed7e983 with bug):
anielsen@lx-anielsen ~/work/opensource-phy/lkp-tests (master) $ sudo qemu-system-x86_64 -enable-kvm -cpu host -smp 2 -m 4G -kernel ../net-next/bug-build/arch/x86_64/boot/bzImage -nographic
[    0.000000] Linux version 4.8.0-14895-gaf1fee9 (anielsen@lx-anielsen) (gcc version 5.2.0 (Gentoo 5.2.0 p1.3, pie-0.6.5) ) #1 PREEMPT Mon Nov 7 12:28:27 CET 2016
[    0.000000] Command line:
[    0.000000] x86/fpu: Legacy x87 FPU detected.
[    0.000000] x86/fpu: Using 'eager' FPU context switches.
[    0.000000] e820: BIOS-provided physical RAM map:
[    0.000000] BIOS-e820: [mem 0x0000000000000000-0x000000000009fbff] usable
[    0.000000] BIOS-e820: [mem 0x000000000009fc00-0x000000000009ffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000000f0000-0x00000000000fffff] reserved
[    0.000000] BIOS-e820: [mem 0x0000000000100000-0x00000000bffdffff] usable
[    0.000000] BIOS-e820: [mem 0x00000000bffe0000-0x00000000bfffffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000feffc000-0x00000000feffffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000fffc0000-0x00000000ffffffff] reserved
[    0.000000] BIOS-e820: [mem 0x0000000100000000-0x000000013fffffff] usable
[    0.000000] NX (Execute Disable) protection: active
[    0.000000] SMBIOS 2.8 present.
[    0.000000] Hypervisor detected: KVM
[    0.000000] e820: last_pfn = 0x140000 max_arch_pfn = 0x400000000
[    0.000000] x86/PAT: Configuration [0-7]: WB  WC  UC- UC  WB  WC  UC- WT
[    0.000000] e820: last_pfn = 0xbffe0 max_arch_pfn = 0x400000000
[    0.000000] ACPI: Early table checksum verification disabled
[    0.000000] ACPI: RSDP 0x00000000000F6970 000014 (v00 BOCHS )
[    0.000000] ACPI: RSDT 0x00000000BFFE1936 000030 (v01 BOCHS  BXPCRSDT 00000001 BXPC 00000001)
[    0.000000] ACPI: FACP 0x00000000BFFE180A 000074 (v01 BOCHS  BXPCFACP 00000001 BXPC 00000001)
[    0.000000] ACPI: DSDT 0x00000000BFFE0040 0017CA (v01 BOCHS  BXPCDSDT 00000001 BXPC 00000001)
[    0.000000] ACPI: FACS 0x00000000BFFE0000 000040
[    0.000000] ACPI: APIC 0x00000000BFFE187E 000080 (v01 BOCHS  BXPCAPIC 00000001 BXPC 00000001)
[    0.000000] ACPI: HPET 0x00000000BFFE18FE 000038 (v01 BOCHS  BXPCHPET 00000001 BXPC 00000001)
[    0.000000] kvm-clock: Using msrs 4b564d01 and 4b564d00
[    0.000000] kvm-clock: cpu 0, msr 1:3f800001, primary cpu clock
[    0.000000] kvm-clock: using sched offset of 691297072 cycles
[    0.000000] clocksource: kvm-clock: mask: 0xffffffffffffffff max_cycles: 0x1cd42e4dffb, max_idle_ns: 881590591483 ns
[    0.000000] Zone ranges:
[    0.000000]   DMA      [mem 0x0000000000001000-0x0000000000ffffff]
[    0.000000]   DMA32    [mem 0x0000000001000000-0x00000000ffffffff]
[    0.000000]   Normal   [mem 0x0000000100000000-0x000000013fffffff]
[    0.000000]   Device   empty
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x0000000000001000-0x000000000009efff]
[    0.000000]   node   0: [mem 0x0000000000100000-0x00000000bffdffff]
[    0.000000]   node   0: [mem 0x0000000100000000-0x000000013fffffff]
[    0.000000] Initmem setup node 0 [mem 0x0000000000001000-0x000000013fffffff]
[    0.000000] ACPI: PM-Timer IO Port: 0x608
[    0.000000] APIC: NR_CPUS/possible_cpus limit of 1 reached. Processor 1/0x1 ignored.
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0xff] dfl dfl lint[0x1])
[    0.000000] IOAPIC[0]: apic_id 0, version 17, address 0xfec00000, GSI 0-23
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 5 global_irq 5 high level)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 10 global_irq 10 high level)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 11 global_irq 11 high level)
[    0.000000] Using ACPI (MADT) for SMP configuration information
[    0.000000] ACPI: HPET id: 0x8086a201 base: 0xfed00000
[    0.000000] KVM setup async PF for cpu 0
[    0.000000] kvm-stealtime: cpu 0, msr 2835b80
[    0.000000] e820: [mem 0xc0000000-0xfeffbfff] available for PCI devices
[    0.000000] Booting paravirtualized kernel on KVM
[    0.000000] clocksource: refined-jiffies: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 1910969940391419 ns
[    0.000000] Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 1032041
[    0.000000] Kernel command line:
[    0.000000] PID hash table entries: 4096 (order: 3, 32768 bytes)
[    0.000000] Dentry cache hash table entries: 524288 (order: 10, 4194304 bytes)
[    0.000000] Inode-cache hash table entries: 262144 (order: 9, 2097152 bytes)
[    0.000000] Memory: 3984728K/4193784K available (14427K kernel code, 5329K rwdata, 6352K rodata, 1188K init, 30876K bss, 209056K reserved, 0K cma-reserved)
[    0.000000] SLUB: HWalign=64, Order=0-3, MinObjects=0, CPUs=1, Nodes=1
[    0.000000] Running RCU self tests
[    0.000000] Preemptible hierarchical RCU implementation.
[    0.000000]  RCU debugfs-based tracing is enabled.
[    0.000000]  RCU lockdep checking is enabled.
[    0.000000]  Build-time adjustment of leaf fanout to 64.
[    0.000000] NR_IRQS:4352 nr_irqs:48 16
[    0.000000] console [ttyS0] enabled
[    0.000000] Lock dependency validator: Copyright (c) 2006 Red Hat, Inc., Ingo Molnar
[    0.000000] ... MAX_LOCKDEP_SUBCLASSES:  8
[    0.000000] ... MAX_LOCK_DEPTH:          48
[    0.000000] ... MAX_LOCKDEP_KEYS:        8191
[    0.000000] ... CLASSHASH_SIZE:          4096
[    0.000000] ... MAX_LOCKDEP_ENTRIES:     32768
[    0.000000] ... MAX_LOCKDEP_CHAINS:      65536
[    0.000000] ... CHAINHASH_SIZE:          32768
[    0.000000]  memory used by lock dependency info: 8671 kB
[    0.000000]  per task-struct memory footprint: 2688 bytes
[    0.000000] ODEBUG: selftest passed
[    0.000000] clocksource: hpet: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 19112604467 ns
[    0.000000] tsc: Detected 3066.410 MHz processor
[    0.937918] Calibrating delay loop (skipped) preset value.. 6132.82 BogoMIPS (lpj=3066410)
[    0.943980] pid_max: default: 32768 minimum: 301
[    0.944789] ACPI: Core revision 20160831
[    0.955550] ACPI: 1 ACPI AML tables successfully acquired and loaded

[    0.959549] Mount-cache hash table entries: 8192 (order: 4, 65536 bytes)
[    0.961595] Mountpoint-cache hash table entries: 8192 (order: 4, 65536 bytes)
[    0.964946] Last level iTLB entries: 4KB 0, 2MB 0, 4MB 0
[    0.966791] Last level dTLB entries: 4KB 0, 2MB 0, 4MB 0, 1GB 0
[    0.969051] CPU: Intel(R) Xeon(R) CPU           W3550  @ 3.07GHz (family: 0x6, model: 0x1a, stepping: 0x5)
[    0.982859] Performance Events: Nehalem events, Intel PMU driver.
[    0.987724] core: CPUID marked event: 'bus cycles' unavailable
[    0.989649] ... version:                2
[    0.991320] ... bit width:              48
[    0.991835] ... generic registers:      4
[    0.993431] ... value mask:             0000ffffffffffff
[    0.994079] ... max period:             000000007fffffff
[    0.996117] ... fixed-purpose events:   3
[    0.997909] ... event mask:             000000070000000f
[    1.007035] ..TIMER: vector=0x30 apic1=0 pin1=2 apic2=-1 pin2=-1
[    1.011621] devtmpfs: initialized
[    1.012676] x86/mm: Memory block size: 128MB
[    1.019820] clocksource: jiffies: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 1911260446275000 ns
[    1.021930] atomic64_test: passed for x86-64 platform with CX8 and with SSE
[    1.023131] pinctrl core: initialized pinctrl subsystem
[    1.028056] regulator-dummy: Failed to create debugfs directory
[    1.030066] NET: Registered protocol family 16
[    1.035298] cpuidle: using governor menu
[    1.036370] ACPI: bus type PCI registered
[    1.037019] acpiphp: ACPI Hot Plug PCI Controller Driver version: 0.5
[    1.038380] PCI: Using configuration type 1 for base access
[    1.098640] HugeTLB registered 2 MB page size, pre-allocated 0 pages
[    1.100990] ACPI: Added _OSI(Module Device)
[    1.101748] ACPI: Added _OSI(Processor Device)
[    1.102528] ACPI: Added _OSI(3.0 _SCP Extensions)
[    1.103300] ACPI: Added _OSI(Processor Aggregator Device)
[    1.113552] ACPI: Interpreter enabled
[    1.114307] ACPI: (supports S0 S5)
[    1.114896] ACPI: Using IOAPIC for interrupt routing
[    1.115813] PCI: Using host bridge windows from ACPI; if necessary, use "pci=nocrs" and report a bug
[    1.145083] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-ff])
[    1.147599] acpi PNP0A03:00: _OSC: OS supports [Segments]
[    1.148733] acpi PNP0A03:00: _OSC failed (AE_NOT_FOUND); disabling ASPM
[    1.150358] acpi PNP0A03:00: fail to add MMCONFIG information, can't access extended PCI configuration space under this bridge.
[    1.154727] acpiphp: Slot [3] registered
[    1.156357] acpiphp: Slot [4] registered
[    1.157125] acpiphp: Slot [5] registered
[    1.157911] acpiphp: Slot [6] registered
[    1.159953] acpiphp: Slot [7] registered
[    1.169975] acpiphp: Slot [8] registered
[    1.175327] acpiphp: Slot [9] registered
[    1.185230] acpiphp: Slot [10] registered
[    1.186133] acpiphp: Slot [11] registered
[    1.186795] acpiphp: Slot [12] registered
[    1.187665] acpiphp: Slot [13] registered
[    1.188529] acpiphp: Slot [14] registered
[    1.189365] acpiphp: Slot [15] registered
[    1.190242] acpiphp: Slot [16] registered
[    1.191102] acpiphp: Slot [17] registered
[    1.191932] acpiphp: Slot [18] registered
[    1.192791] acpiphp: Slot [19] registered
[    1.193665] acpiphp: Slot [20] registered
[    1.194512] acpiphp: Slot [21] registered
[    1.195361] acpiphp: Slot [22] registered
[    1.196269] acpiphp: Slot [23] registered
[    1.197117] acpiphp: Slot [24] registered
[    1.197965] acpiphp: Slot [25] registered
[    1.198791] acpiphp: Slot [26] registered
[    1.199657] acpiphp: Slot [27] registered
[    1.200525] acpiphp: Slot [28] registered
[    1.201400] acpiphp: Slot [29] registered
[    1.202266] acpiphp: Slot [30] registered
[    1.203133] acpiphp: Slot [31] registered
[    1.203871] PCI host bridge to bus 0000:00
[    1.204592] pci_bus 0000:00: root bus resource [io  0x0000-0x0cf7 window]
[    1.205736] pci_bus 0000:00: root bus resource [io  0x0d00-0xffff window]
[    1.206868] pci_bus 0000:00: root bus resource [mem 0x000a0000-0x000bffff window]
[    1.208108] pci_bus 0000:00: root bus resource [mem 0xc0000000-0xfebfffff window]
[    1.209373] pci_bus 0000:00: root bus resource [bus 00-ff]
[    1.219627] pci 0000:00:01.1: legacy IDE quirk: reg 0x10: [io  0x01f0-0x01f7]
[    1.221368] pci 0000:00:01.1: legacy IDE quirk: reg 0x14: [io  0x03f6]
[    1.222534] pci 0000:00:01.1: legacy IDE quirk: reg 0x18: [io  0x0170-0x0177]
[    1.223842] pci 0000:00:01.1: legacy IDE quirk: reg 0x1c: [io  0x0376]
[    1.227041] pci 0000:00:01.3: quirk: [io  0x0600-0x063f] claimed by PIIX4 ACPI
[    1.228211] pci 0000:00:01.3: quirk: [io  0x0700-0x070f] claimed by PIIX4 SMB
[    1.277271] ACPI: PCI Interrupt Link [LNKA] (IRQs 5 *10 11)
[    1.279059] ACPI: PCI Interrupt Link [LNKB] (IRQs 5 *10 11)
[    1.280792] ACPI: PCI Interrupt Link [LNKC] (IRQs 5 10 *11)
[    1.282649] ACPI: PCI Interrupt Link [LNKD] (IRQs 5 10 *11)
[    1.284087] ACPI: PCI Interrupt Link [LNKS] (IRQs *9)
[    1.288543] vgaarb: setting as boot device: PCI:0000:00:02.0
[    1.289527] vgaarb: device added: PCI:0000:00:02.0,decodes=io+mem,owns=io+mem,locks=none
[    1.290880] vgaarb: loaded
[    1.291329] vgaarb: bridge control possible 0000:00:02.0
[    1.293975] ACPI: bus type USB registered
[    1.294791] usbcore: registered new interface driver usbfs
[    1.295594] usbcore: registered new interface driver hub
[    1.296450] usbcore: registered new device driver usb
[    1.297682] pps_core: LinuxPPS API ver. 1 registered
[    1.298499] pps_core: Software ver. 5.3.6 - Copyright 2005-2007 Rodolfo Giometti <giometti@linux.it>
[    1.300110] PTP clock support registered
[    1.301620] FPGA manager framework
[    1.302326] PCI: Using ACPI for IRQ routing
[    1.304647] NET: Registered protocol family 23
[    1.305652] NET: Registered protocol family 8
[    1.306459] NET: Registered protocol family 20
[    1.307817] workqueue: round-robin CPU selection forced, expect performance impact
[    1.309850] nfc: nfc_init: NFC Core ver 0.1
[    1.310760] NET: Registered protocol family 39
[    1.311726] clocksource: Switched to clocksource kvm-clock
[    1.315568] Warning: could not register annotated branches stats
[    1.408770] VFS: Disk quotas dquot_6.6.0
[    1.409623] VFS: Dquot-cache hash table entries: 512 (order 0, 4096 bytes)
[    1.411160] FS-Cache: Loaded
[    1.412175] pnp: PnP ACPI init
[    1.416316] pnp: PnP ACPI: found 6 devices
[    1.423705] clocksource: acpi_pm: mask: 0xffffff max_cycles: 0xffffff, max_idle_ns: 2085701024 ns
[    1.426181] NET: Registered protocol family 2
[    1.427984] TCP established hash table entries: 32768 (order: 6, 262144 bytes)
[    1.431515] TCP bind hash table entries: 32768 (order: 9, 2621440 bytes)
[    1.437331] TCP: Hash tables configured (established 32768 bind 32768)
[    1.438938] UDP hash table entries: 2048 (order: 6, 393216 bytes)
[    1.440827] UDP-Lite hash table entries: 2048 (order: 6, 393216 bytes)
[    1.443075] NET: Registered protocol family 1
[    1.443829] pci 0000:00:00.0: Limiting direct PCI/PCI transfers
[    1.444632] pci 0000:00:01.0: PIIX3: Enabling Passive Release
[    1.445588] pci 0000:00:01.0: Activating ISA DMA hang workarounds
[    1.446681] pci 0000:00:02.0: Video device with shadowed ROM at [mem 0x000c0000-0x000dffff]
[    1.448663] PCI-DMA: Using software bounce buffering for IO (SWIOTLB)
[    1.449953] software IO TLB [mem 0xbbfe0000-0xbffe0000] (64MB) mapped at [ffff8800bbfe0000-ffff8800bffdffff]
[    1.457064] PCLMULQDQ-NI instructions are not detected.
[    1.458609] AVX or AES-NI instructions are not detected.
[    1.459506] CPU feature 'AVX registers' is not supported.
[    1.460429] CPU feature 'AVX registers' is not supported.
[    1.461202] CPU feature 'AVX registers' is not supported.
[    1.462115] AVX2 or AES-NI instructions are not detected.
[    1.463189] AVX2 instructions are not detected.
[    1.464426] spin_lock-torture:--- Start of test [debug]: nwriters_stress=2 nreaders_stress=0 stat_interval=60 verbose=1 shuffle_interval=3 stutter=5 shutdown_secs=0 onoff_interval=0 onoff_holdoff=0
[    1.467086] spin_lock-torture: Creating torture_shuffle task
[    1.468302] spin_lock-torture: Creating torture_stutter task
[    1.469409] spin_lock-torture: torture_shuffle task started
[    1.470460] spin_lock-torture: Creating lock_torture_writer task
[    1.471649] spin_lock-torture: torture_stutter task started
[    1.472755] spin_lock-torture: Creating lock_torture_writer task
[    1.473919] spin_lock-torture: lock_torture_writer task started
[    1.474882] spin_lock-torture: Creating lock_torture_stats task
[    1.475892] spin_lock-torture: lock_torture_writer task started
[    1.477901] torture_init_begin: Refusing rcu init: spin_lock running.
[    1.478825] torture_init_begin: One torture test at a time!
[    1.480840] futex hash table entries: 256 (order: 2, 24576 bytes)
[    1.481784] spin_lock-torture: lock_torture_stats task started
[    1.483657] workingset: timestamp_bits=62 max_order=20 bucket_order=0
[    1.500836] DLM installed
[    1.501403] jffs2: version 2.2. (NAND) © 2001-2006 Red Hat, Inc.
[    1.503533] fuse init (API version 7.26)
[    1.515258] NET: Registered protocol family 38
[    1.525218] test_hexdump: all 1184 tests passed
[    1.526300] test_firmware: interface ready
[    1.534684] test_hash: __hash_32() has no arch implementation to test.
[    1.535887] test_hash: hash_32() has no arch implementation to test.
[    1.536770] test_hash: hash_64() has no arch implementation to test.
[    1.537649] test_hash: 33152 tests passed.
[    1.538398] Running rhashtable test nelem=8, max_size=0, shrinking=0
[    1.539460] Test 00:
[    1.548989]   Adding 50000 keys
[    1.811588]   Traversal complete: counted=50000, nelems=50000, entries=50000, table-jumps=0
[    1.945091]   Traversal complete: counted=50000, nelems=50000, entries=50000, table-jumps=0
[    1.946615]   Deleting 50000 keys
[    2.050045]   Duration of test: 500457293 ns
[    2.051424] Test 01:
[    2.054961]   Adding 50000 keys
[    2.329185]   Traversal complete: counted=50000, nelems=50000, entries=50000, table-jumps=0
[    2.474554]   Traversal complete: counted=50000, nelems=50000, entries=50000, table-jumps=0
[    2.482316]   Deleting 50000 keys
[    2.491859] tsc: Refined TSC clocksource calibration: 3066.640 MHz
[    2.492841] clocksource: tsc: mask: 0xffffffffffffffff max_cycles: 0x2c342dccc31, max_idle_ns: 440795314676 ns
[    2.571084]   Duration of test: 515496549 ns
[    2.572309] Test 02:
[    2.575478]   Adding 50000 keys
[    2.820652]   Traversal complete: counted=50000, nelems=50000, entries=50000, table-jumps=0
[    2.959581]   Traversal complete: counted=50000, nelems=50000, entries=50000, table-jumps=0
[    2.960936]   Deleting 50000 keys
[    3.080226]   Duration of test: 504184373 ns
[    3.086716] Test 03:
[    3.093073]   Adding 50000 keys
[    3.368969]   Traversal complete: counted=50000, nelems=50000, entries=50000, table-jumps=0
[    3.497345]   Traversal complete: counted=50000, nelems=50000, entries=50000, table-jumps=0
[    3.498889]   Deleting 50000 keys
[    3.586285]   Duration of test: 492765990 ns
[    3.587656] Average test time: 503226051
[    3.588329] Testing concurrent rhashtable access from 10 threads
[   13.587662] Started 10 threads, 0 failed
[   13.603476] test_printf: all 260 tests passed
[   13.671488] test_bitmap: all 460506 tests passed
[   13.672297] test_uuid: all 18 tests passed
[   13.674176] crc32: CRC_LE_BITS = 8, CRC_BE BITS = 8
[   13.674989] crc32: self tests passed, processed 225944 bytes in 583784 nsec
[   13.676466] crc32c: CRC_LE_BITS = 8
[   13.677155] crc32c: self tests passed, processed 225944 bytes in 268429 nsec
[   13.710279] crc32_combine: 8373 self tests passed
[   13.743225] crc32c_combine: 8373 self tests passed
[   13.744420] rbtree testing[   14.469840]  -> 22232 cycles
[   14.567013] augmented rbtree testing[   15.545414]  -> 29981 cycles
[   15.675234] gpio-mockup: probe of gpio-mockup failed with error -22
[   15.677093] pci_hotplug: PCI Hot Plug PCI Core version: 0.5
[   15.678025] cpcihp_zt5550: ZT5550 CompactPCI Hot Plug Driver version: 0.2
[   15.685795] acpiphp_ibm: ibm_acpiphp_init: acpi_walk_namespace failed
[   15.687752] cr_bllcd: INTEL CARILLO RANCH LPC not found.
[   15.688667] cr_bllcd: Carillo Ranch Backlight Driver Initialized.
[   15.690631] Could not find Carillo Ranch MCH device.
[   15.691675] no IO addresses supplied
[   15.692852] usbcore: registered new interface driver udlfb
[   15.693702] usbcore: registered new interface driver smscufx
[   15.695714] uvesafb: failed to execute /sbin/v86d
[   15.696415] uvesafb: make sure that the v86d helper is installed and executable
[   15.697490] uvesafb: Getting VBE info block failed (eax=0x4f00, err=-2)
[   15.698617] uvesafb: vbe_init() failed with -22
[   15.699471] uvesafb: probe of uvesafb.0 failed with error -22
[   15.701068] input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/input/input0
[   15.702321] ACPI: Power Button [PWRF]
[   15.703453] button: probe of LNXPWRBN:00 failed with error -22
[   15.704787] Warning: Processor Platform Limit event detected, but not handled.
[   15.706000] Consider compiling CPUfreq support into your kernel.
[   15.708019] EINJ: EINJ table not found.
[   15.708660] ERST DBG: ERST support is disabled.
[   15.762424] Serial: 8250/16550 driver, 4 ports, IRQ sharing enabled
[   15.794904] 00:05: ttyS0 at I/O 0x3f8 (irq = 4, base_baud = 115200) is a 16550A
[   15.798310] console [ttyS0] disabled
[    0.000000] Linux version 4.8.0-14895-gaf1fee9 (anielsen@lx-anielsen) (gcc version 5.2.0 (Gentoo 5.2.0 p1.3, pie-0.6.5) ) #1 PREEMPT Mon Nov 7 12:28:27 CET 2016
[    0.000000] Command line:
[    0.000000] x86/fpu: Legacy x87 FPU detected.
[    0.000000] x86/fpu: Using 'eager' FPU context switches.
[    0.000000] e820: BIOS-provided physical RAM map:
[    0.000000] BIOS-e820: [mem 0x0000000000000000-0x000000000009fbff] usable
[    0.000000] BIOS-e820: [mem 0x000000000009fc00-0x000000000009ffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000000f0000-0x00000000000fffff] reserved
[    0.000000] BIOS-e820: [mem 0x0000000000100000-0x00000000bffdffff] usable
[    0.000000] BIOS-e820: [mem 0x00000000bffe0000-0x00000000bfffffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000feffc000-0x00000000feffffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000fffc0000-0x00000000ffffffff] reserved
[    0.000000] BIOS-e820: [mem 0x0000000100000000-0x000000013fffffff] usable
[    0.000000] NX (Execute Disable) protection: active
[    0.000000] SMBIOS 2.8 present.
[    0.000000] Hypervisor detected: KVM
[    0.000000] e820: last_pfn = 0x140000 max_arch_pfn = 0x400000000
[    0.000000] x86/PAT: Configuration [0-7]: WB  WC  UC- UC  WB  WC  UC- WT
[    0.000000] e820: last_pfn = 0xbffe0 max_arch_pfn = 0x400000000
[    0.000000] ACPI: Early table checksum verification disabled
[    0.000000] ACPI: RSDP 0x00000000000F6970 000014 (v00 BOCHS )
[    0.000000] ACPI: RSDT 0x00000000BFFE1936 000030 (v01 BOCHS  BXPCRSDT 00000001 BXPC 00000001)
[    0.000000] ACPI: FACP 0x00000000BFFE180A 000074 (v01 BOCHS  BXPCFACP 00000001 BXPC 00000001)
[    0.000000] ACPI: DSDT 0x00000000BFFE0040 0017CA (v01 BOCHS  BXPCDSDT 00000001 BXPC 00000001)
[    0.000000] ACPI: FACS 0x00000000BFFE0000 000040
[    0.000000] ACPI: APIC 0x00000000BFFE187E 000080 (v01 BOCHS  BXPCAPIC 00000001 BXPC 00000001)
[    0.000000] ACPI: HPET 0x00000000BFFE18FE 000038 (v01 BOCHS  BXPCHPET 00000001 BXPC 00000001)
[    0.000000] kvm-clock: Using msrs 4b564d01 and 4b564d00
[    0.000000] kvm-clock: cpu 0, msr 1:3f800001, primary cpu clock
[    0.000000] kvm-clock: using sched offset of 691297072 cycles
[    0.000000] clocksource: kvm-clock: mask: 0xffffffffffffffff max_cycles: 0x1cd42e4dffb, max_idle_ns: 881590591483 ns
[    0.000000] Zone ranges:
[    0.000000]   DMA      [mem 0x0000000000001000-0x0000000000ffffff]
[    0.000000]   DMA32    [mem 0x0000000001000000-0x00000000ffffffff]
[    0.000000]   Normal   [mem 0x0000000100000000-0x000000013fffffff]
[    0.000000]   Device   empty
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x0000000000001000-0x000000000009efff]
[    0.000000]   node   0: [mem 0x0000000000100000-0x00000000bffdffff]
[    0.000000]   node   0: [mem 0x0000000100000000-0x000000013fffffff]
[    0.000000] Initmem setup node 0 [mem 0x0000000000001000-0x000000013fffffff]
[    0.000000] ACPI: PM-Timer IO Port: 0x608
[    0.000000] APIC: NR_CPUS/possible_cpus limit of 1 reached. Processor 1/0x1 ignored.
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0xff] dfl dfl lint[0x1])
[    0.000000] IOAPIC[0]: apic_id 0, version 17, address 0xfec00000, GSI 0-23
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 5 global_irq 5 high level)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 10 global_irq 10 high level)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 11 global_irq 11 high level)
[    0.000000] Using ACPI (MADT) for SMP configuration information
[    0.000000] ACPI: HPET id: 0x8086a201 base: 0xfed00000
[    0.000000] KVM setup async PF for cpu 0
[    0.000000] kvm-stealtime: cpu 0, msr 2835b80
[    0.000000] e820: [mem 0xc0000000-0xfeffbfff] available for PCI devices
[    0.000000] Booting paravirtualized kernel on KVM
[    0.000000] clocksource: refined-jiffies: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 1910969940391419 ns
[    0.000000] Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 1032041
[    0.000000] Kernel command line:
[    0.000000] PID hash table entries: 4096 (order: 3, 32768 bytes)
[    0.000000] Dentry cache hash table entries: 524288 (order: 10, 4194304 bytes)
[    0.000000] Inode-cache hash table entries: 262144 (order: 9, 2097152 bytes)
[    0.000000] Memory: 3984728K/4193784K available (14427K kernel code, 5329K rwdata, 6352K rodata, 1188K init, 30876K bss, 209056K reserved, 0K cma-reserved)
[    0.000000] SLUB: HWalign=64, Order=0-3, MinObjects=0, CPUs=1, Nodes=1
[    0.000000] Running RCU self tests
[    0.000000] Preemptible hierarchical RCU implementation.
[    0.000000]  RCU debugfs-based tracing is enabled.
[    0.000000]  RCU lockdep checking is enabled.
[    0.000000]  Build-time adjustment of leaf fanout to 64.
[    0.000000] NR_IRQS:4352 nr_irqs:48 16
[    0.000000] console [ttyS0] enabled
[    0.000000] Lock dependency validator: Copyright (c) 2006 Red Hat, Inc., Ingo Molnar
[    0.000000] ... MAX_LOCKDEP_SUBCLASSES:  8
[    0.000000] ... MAX_LOCK_DEPTH:          48
[    0.000000] ... MAX_LOCKDEP_KEYS:        8191
[    0.000000] ... CLASSHASH_SIZE:          4096
[    0.000000] ... MAX_LOCKDEP_ENTRIES:     32768
[    0.000000] ... MAX_LOCKDEP_CHAINS:      65536
[    0.000000] ... CHAINHASH_SIZE:          32768
[    0.000000]  memory used by lock dependency info: 8671 kB
[    0.000000]  per task-struct memory footprint: 2688 bytes
[    0.000000] ODEBUG: selftest passed
[    0.000000] clocksource: hpet: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 19112604467 ns
[    0.000000] tsc: Detected 3066.410 MHz processor
[    0.937918] Calibrating delay loop (skipped) preset value.. 6132.82 BogoMIPS (lpj=3066410)
[    0.943980] pid_max: default: 32768 minimum: 301
[    0.944789] ACPI: Core revision 20160831
[    0.955550] ACPI: 1 ACPI AML tables successfully acquired and loaded

[    0.959549] Mount-cache hash table entries: 8192 (order: 4, 65536 bytes)
[    0.961595] Mountpoint-cache hash table entries: 8192 (order: 4, 65536 bytes)
[    0.964946] Last level iTLB entries: 4KB 0, 2MB 0, 4MB 0
[    0.966791] Last level dTLB entries: 4KB 0, 2MB 0, 4MB 0, 1GB 0
[    0.969051] CPU: Intel(R) Xeon(R) CPU           W3550  @ 3.07GHz (family: 0x6, model: 0x1a, stepping: 0x5)
[    0.982859] Performance Events: Nehalem events, Intel PMU driver.
[    0.987724] core: CPUID marked event: 'bus cycles' unavailable
[    0.989649] ... version:                2
[    0.991320] ... bit width:              48
[    0.991835] ... generic registers:      4
[    0.993431] ... value mask:             0000ffffffffffff
[    0.994079] ... max period:             000000007fffffff
[    0.996117] ... fixed-purpose events:   3
[    0.997909] ... event mask:             000000070000000f
[    1.007035] ..TIMER: vector=0x30 apic1=0 pin1=2 apic2=-1 pin2=-1
[    1.011621] devtmpfs: initialized
[    1.012676] x86/mm: Memory block size: 128MB
[    1.019820] clocksource: jiffies: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 1911260446275000 ns
[    1.021930] atomic64_test: passed for x86-64 platform with CX8 and with SSE
[    1.023131] pinctrl core: initialized pinctrl subsystem
[    1.028056] regulator-dummy: Failed to create debugfs directory
[    1.030066] NET: Registered protocol family 16
[    1.035298] cpuidle: using governor menu
[    1.036370] ACPI: bus type PCI registered
[    1.037019] acpiphp: ACPI Hot Plug PCI Controller Driver version: 0.5
[    1.038380] PCI: Using configuration type 1 for base access
[    1.098640] HugeTLB registered 2 MB page size, pre-allocated 0 pages
[    1.100990] ACPI: Added _OSI(Module Device)
[    1.101748] ACPI: Added _OSI(Processor Device)
[    1.102528] ACPI: Added _OSI(3.0 _SCP Extensions)
[    1.103300] ACPI: Added _OSI(Processor Aggregator Device)
[    1.113552] ACPI: Interpreter enabled
[    1.114307] ACPI: (supports S0 S5)
[    1.114896] ACPI: Using IOAPIC for interrupt routing
[    1.115813] PCI: Using host bridge windows from ACPI; if necessary, use "pci=nocrs" and report a bug
[    1.145083] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-ff])
[    1.147599] acpi PNP0A03:00: _OSC: OS supports [Segments]
[    1.148733] acpi PNP0A03:00: _OSC failed (AE_NOT_FOUND); disabling ASPM
[    1.150358] acpi PNP0A03:00: fail to add MMCONFIG information, can't access extended PCI configuration space under this bridge.
[    1.154727] acpiphp: Slot [3] registered
[    1.156357] acpiphp: Slot [4] registered
[    1.157125] acpiphp: Slot [5] registered
[    1.157911] acpiphp: Slot [6] registered
[    1.159953] acpiphp: Slot [7] registered
[    1.169975] acpiphp: Slot [8] registered
[    1.175327] acpiphp: Slot [9] registered
[    1.185230] acpiphp: Slot [10] registered
[    1.186133] acpiphp: Slot [11] registered
[    1.186795] acpiphp: Slot [12] registered
[    1.187665] acpiphp: Slot [13] registered
[    1.188529] acpiphp: Slot [14] registered
[    1.189365] acpiphp: Slot [15] registered
[    1.190242] acpiphp: Slot [16] registered
[    1.191102] acpiphp: Slot [17] registered
[    1.191932] acpiphp: Slot [18] registered
[    1.192791] acpiphp: Slot [19] registered
[    1.193665] acpiphp: Slot [20] registered
[    1.194512] acpiphp: Slot [21] registered
[    1.195361] acpiphp: Slot [22] registered
[    1.196269] acpiphp: Slot [23] registered
[    1.197117] acpiphp: Slot [24] registered
[    1.197965] acpiphp: Slot [25] registered
[    1.198791] acpiphp: Slot [26] registered
[    1.199657] acpiphp: Slot [27] registered
[    1.200525] acpiphp: Slot [28] registered
[    1.201400] acpiphp: Slot [29] registered
[    1.202266] acpiphp: Slot [30] registered
[    1.203133] acpiphp: Slot [31] registered
[    1.203871] PCI host bridge to bus 0000:00
[    1.204592] pci_bus 0000:00: root bus resource [io  0x0000-0x0cf7 window]
[    1.205736] pci_bus 0000:00: root bus resource [io  0x0d00-0xffff window]
[    1.206868] pci_bus 0000:00: root bus resource [mem 0x000a0000-0x000bffff window]
[    1.208108] pci_bus 0000:00: root bus resource [mem 0xc0000000-0xfebfffff window]
[    1.209373] pci_bus 0000:00: root bus resource [bus 00-ff]
[    1.219627] pci 0000:00:01.1: legacy IDE quirk: reg 0x10: [io  0x01f0-0x01f7]
[    1.221368] pci 0000:00:01.1: legacy IDE quirk: reg 0x14: [io  0x03f6]
[    1.222534] pci 0000:00:01.1: legacy IDE quirk: reg 0x18: [io  0x0170-0x0177]
[    1.223842] pci 0000:00:01.1: legacy IDE quirk: reg 0x1c: [io  0x0376]
[    1.227041] pci 0000:00:01.3: quirk: [io  0x0600-0x063f] claimed by PIIX4 ACPI
[    1.228211] pci 0000:00:01.3: quirk: [io  0x0700-0x070f] claimed by PIIX4 SMB
[    1.277271] ACPI: PCI Interrupt Link [LNKA] (IRQs 5 *10 11)
[    1.279059] ACPI: PCI Interrupt Link [LNKB] (IRQs 5 *10 11)
[    1.280792] ACPI: PCI Interrupt Link [LNKC] (IRQs 5 10 *11)
[    1.282649] ACPI: PCI Interrupt Link [LNKD] (IRQs 5 10 *11)
[    1.284087] ACPI: PCI Interrupt Link [LNKS] (IRQs *9)
[    1.288543] vgaarb: setting as boot device: PCI:0000:00:02.0
[    1.289527] vgaarb: device added: PCI:0000:00:02.0,decodes=io+mem,owns=io+mem,locks=none
[    1.290880] vgaarb: loaded
[    1.291329] vgaarb: bridge control possible 0000:00:02.0
[    1.293975] ACPI: bus type USB registered
[    1.294791] usbcore: registered new interface driver usbfs
[    1.295594] usbcore: registered new interface driver hub
[    1.296450] usbcore: registered new device driver usb
[    1.297682] pps_core: LinuxPPS API ver. 1 registered
[    1.298499] pps_core: Software ver. 5.3.6 - Copyright 2005-2007 Rodolfo Giometti <giometti@linux.it>
[    1.300110] PTP clock support registered
[    1.301620] FPGA manager framework
[    1.302326] PCI: Using ACPI for IRQ routing
[    1.304647] NET: Registered protocol family 23
[    1.305652] NET: Registered protocol family 8
[    1.306459] NET: Registered protocol family 20
[    1.307817] workqueue: round-robin CPU selection forced, expect performance impact
[    1.309850] nfc: nfc_init: NFC Core ver 0.1
[    1.310760] NET: Registered protocol family 39
[    1.311726] clocksource: Switched to clocksource kvm-clock
[    1.315568] Warning: could not register annotated branches stats
[    1.408770] VFS: Disk quotas dquot_6.6.0
[    1.409623] VFS: Dquot-cache hash table entries: 512 (order 0, 4096 bytes)
[    1.411160] FS-Cache: Loaded
[    1.412175] pnp: PnP ACPI init
[    1.416316] pnp: PnP ACPI: found 6 devices
[    1.423705] clocksource: acpi_pm: mask: 0xffffff max_cycles: 0xffffff, max_idle_ns: 2085701024 ns
[    1.426181] NET: Registered protocol family 2
[    1.427984] TCP established hash table entries: 32768 (order: 6, 262144 bytes)
[    1.431515] TCP bind hash table entries: 32768 (order: 9, 2621440 bytes)
[    1.437331] TCP: Hash tables configured (established 32768 bind 32768)
[    1.438938] UDP hash table entries: 2048 (order: 6, 393216 bytes)
[    1.440827] UDP-Lite hash table entries: 2048 (order: 6, 393216 bytes)
[    1.443075] NET: Registered protocol family 1
[    1.443829] pci 0000:00:00.0: Limiting direct PCI/PCI transfers
[    1.444632] pci 0000:00:01.0: PIIX3: Enabling Passive Release
[    1.445588] pci 0000:00:01.0: Activating ISA DMA hang workarounds
[    1.446681] pci 0000:00:02.0: Video device with shadowed ROM at [mem 0x000c0000-0x000dffff]
[    1.448663] PCI-DMA: Using software bounce buffering for IO (SWIOTLB)
[    1.449953] software IO TLB [mem 0xbbfe0000-0xbffe0000] (64MB) mapped at [ffff8800bbfe0000-ffff8800bffdffff]
[    1.457064] PCLMULQDQ-NI instructions are not detected.
[    1.458609] AVX or AES-NI instructions are not detected.
[    1.459506] CPU feature 'AVX registers' is not supported.
[    1.460429] CPU feature 'AVX registers' is not supported.
[    1.461202] CPU feature 'AVX registers' is not supported.
[    1.462115] AVX2 or AES-NI instructions are not detected.
[    1.463189] AVX2 instructions are not detected.
[    1.464426] spin_lock-torture:--- Start of test [debug]: nwriters_stress=2 nreaders_stress=0 stat_interval=60 verbose=1 shuffle_interval=3 stutter=5 shutdown_secs=0 onoff_interval=0 onoff_holdoff=0
[    1.467086] spin_lock-torture: Creating torture_shuffle task
[    1.468302] spin_lock-torture: Creating torture_stutter task
[    1.469409] spin_lock-torture: torture_shuffle task started
[    1.470460] spin_lock-torture: Creating lock_torture_writer task
[    1.471649] spin_lock-torture: torture_stutter task started
[    1.472755] spin_lock-torture: Creating lock_torture_writer task
[    1.473919] spin_lock-torture: lock_torture_writer task started
[    1.474882] spin_lock-torture: Creating lock_torture_stats task
[    1.475892] spin_lock-torture: lock_torture_writer task started
[    1.477901] torture_init_begin: Refusing rcu init: spin_lock running.
[    1.478825] torture_init_begin: One torture test at a time!
[    1.480840] futex hash table entries: 256 (order: 2, 24576 bytes)
[    1.481784] spin_lock-torture: lock_torture_stats task started
[    1.483657] workingset: timestamp_bits=62 max_order=20 bucket_order=0
[    1.500836] DLM installed
[    1.501403] jffs2: version 2.2. (NAND) © 2001-2006 Red Hat, Inc.
[    1.503533] fuse init (API version 7.26)
[    1.515258] NET: Registered protocol family 38
[    1.525218] test_hexdump: all 1184 tests passed
[    1.526300] test_firmware: interface ready
[    1.534684] test_hash: __hash_32() has no arch implementation to test.
[    1.535887] test_hash: hash_32() has no arch implementation to test.
[    1.536770] test_hash: hash_64() has no arch implementation to test.
[    1.537649] test_hash: 33152 tests passed.
[    1.538398] Running rhashtable test nelem=8, max_size=0, shrinking=0
[    1.539460] Test 00:
[    1.548989]   Adding 50000 keys
[    1.811588]   Traversal complete: counted=50000, nelems=50000, entries=50000, table-jumps=0
[    1.945091]   Traversal complete: counted=50000, nelems=50000, entries=50000, table-jumps=0
[    1.946615]   Deleting 50000 keys
[    2.050045]   Duration of test: 500457293 ns
[    2.051424] Test 01:
[    2.054961]   Adding 50000 keys
[    2.329185]   Traversal complete: counted=50000, nelems=50000, entries=50000, table-jumps=0
[    2.474554]   Traversal complete: counted=50000, nelems=50000, entries=50000, table-jumps=0
[    2.482316]   Deleting 50000 keys
[    2.491859] tsc: Refined TSC clocksource calibration: 3066.640 MHz
[    2.492841] clocksource: tsc: mask: 0xffffffffffffffff max_cycles: 0x2c342dccc31, max_idle_ns: 440795314676 ns
[    2.571084]   Duration of test: 515496549 ns
[    2.572309] Test 02:
[    2.575478]   Adding 50000 keys
[    2.820652]   Traversal complete: counted=50000, nelems=50000, entries=50000, table-jumps=0
[    2.959581]   Traversal complete: counted=50000, nelems=50000, entries=50000, table-jumps=0
[    2.960936]   Deleting 50000 keys
[    3.080226]   Duration of test: 504184373 ns
[    3.086716] Test 03:
[    3.093073]   Adding 50000 keys
[    3.368969]   Traversal complete: counted=50000, nelems=50000, entries=50000, table-jumps=0
[    3.497345]   Traversal complete: counted=50000, nelems=50000, entries=50000, table-jumps=0
[    3.498889]   Deleting 50000 keys
[    3.586285]   Duration of test: 492765990 ns
[    3.587656] Average test time: 503226051
[    3.588329] Testing concurrent rhashtable access from 10 threads
[   13.587662] Started 10 threads, 0 failed
[   13.603476] test_printf: all 260 tests passed
[   13.671488] test_bitmap: all 460506 tests passed
[   13.672297] test_uuid: all 18 tests passed
[   13.674176] crc32: CRC_LE_BITS = 8, CRC_BE BITS = 8
[   13.674989] crc32: self tests passed, processed 225944 bytes in 583784 nsec
[   13.676466] crc32c: CRC_LE_BITS = 8
[   13.677155] crc32c: self tests passed, processed 225944 bytes in 268429 nsec
[   13.710279] crc32_combine: 8373 self tests passed
[   13.743225] crc32c_combine: 8373 self tests passed
[   13.744420] rbtree testing
[   14.469840]  -> 22232 cycles
[   14.567013] augmented rbtree testing
[   15.545414]  -> 29981 cycles
[   15.675234] gpio-mockup: probe of gpio-mockup failed with error -22
[   15.677093] pci_hotplug: PCI Hot Plug PCI Core version: 0.5
[   15.678025] cpcihp_zt5550: ZT5550 CompactPCI Hot Plug Driver version: 0.2
[   15.685795] acpiphp_ibm: ibm_acpiphp_init: acpi_walk_namespace failed
[   15.687752] cr_bllcd: INTEL CARILLO RANCH LPC not found.
[   15.688667] cr_bllcd: Carillo Ranch Backlight Driver Initialized.
[   15.690631] Could not find Carillo Ranch MCH device.
[   15.691675] no IO addresses supplied
[   15.692852] usbcore: registered new interface driver udlfb
[   15.693702] usbcore: registered new interface driver smscufx
[   15.695714] uvesafb: failed to execute /sbin/v86d
[   15.696415] uvesafb: make sure that the v86d helper is installed and executable
[   15.697490] uvesafb: Getting VBE info block failed (eax=0x4f00, err=-2)
[   15.698617] uvesafb: vbe_init() failed with -22
[   15.699471] uvesafb: probe of uvesafb.0 failed with error -22
[   15.701068] input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/input/input0
[   15.702321] ACPI: Power Button [PWRF]
[   15.703453] button: probe of LNXPWRBN:00 failed with error -22
[   15.704787] Warning: Processor Platform Limit event detected, but not handled.
[   15.706000] Consider compiling CPUfreq support into your kernel.
[   15.708019] EINJ: EINJ table not found.
[   15.708660] ERST DBG: ERST support is disabled.
[   15.762424] Serial: 8250/16550 driver, 4 ports, IRQ sharing enabled
[   15.794904] 00:05: ttyS0 at I/O 0x3f8 (irq = 4, base_baud = 115200) is a 16550A
[   15.798310] console [ttyS0] disabled
[   15.833862] 00:05: ttyS0 at I/O 0x3f8 (irq = 4, base_baud = 115200) is a 16550A
[   16.236583] console [ttyS0] enabled
[   16.243090] Initializing Nozomi driver 2.1d
[   16.244654] Applicom driver: $Id: ac.c,v 1.30 2000/03/22 16:03:57 dwmw2 Exp $
[   16.246571] ac.o: No PCI boards found.
[   16.247575] ac.o: For an ISA board you must supply memory and irq parameters.
[   16.249533] Non-volatile memory driver v1.3
[   16.250706] smapi::smapi_init, ERROR invalid usSmapiID
[   16.251921] mwave: tp3780i::tp3780I_InitializeBoardData: Error: SMAPI is not available on this machine
[   16.254345] mwave: mwavedd::mwave_init: Error: Failed to initialize board data
[   16.256263] mwave: mwavedd::mwave_init: Error: Failed to initialize
[   16.257925] Linux agpgart interface v0.103
[   16.259908] Hangcheck: starting hangcheck timer 0.9.1 (tick is 180 seconds, margin is 60 seconds).
[   16.262923] intelfb: Framebuffer driver for Intel(R) 830M/845G/852GM/855GM/865G/915G/915GM/945G/945GM/945GME/965G/965GM chipsets
[   16.265919] intelfb: Version 0.9.6
[   16.267430] ibmasm: IBM ASM Service Processor Driver version 1.0 loaded
[   16.269296] dummy-irq: no IRQ given.  Use irq=N
[   16.270786] Phantom Linux Driver, version n0.9.8, init OK
[   16.272546] Silicon Labs C2 port support v. 0.51.0 - (C) 2007 Rodolfo Giometti
[   16.274925] c2port c2port0: C2 port uc added
[   16.276083] c2port c2port0: uc flash has 30 blocks x 512 bytes (15360 bytes total)
[   16.280508] usbcore: registered new interface driver viperboard
[   16.282187] usbcore: registered new interface driver dln2
[   16.284084] usbcore: registered new interface driver nfcmrvl
[   16.286176] mtdoops: mtd device (mtddev=name/number) must be supplied
[   16.287952] SBC-GXx flash: IO:0x258-0x259 MEM:0xdc000-0xdffff
[   16.289889] slram: not enough parameters.
[   16.321311] No valid DiskOnChip devices found
[   16.322608] [nandsim] warning: read_byte: unexpected data output cycle, state is STATE_READY return 0x0
[   16.325392] [nandsim] warning: read_byte: unexpected data output cycle, state is STATE_READY return 0x0
[   16.327778] [nandsim] warning: read_byte: unexpected data output cycle, state is STATE_READY return 0x0
[   16.330211] [nandsim] warning: read_byte: unexpected data output cycle, state is STATE_READY return 0x0
[   16.332671] [nandsim] warning: read_byte: unexpected data output cycle, state is STATE_READY return 0x0
[   16.336037] [nandsim] warning: read_byte: unexpected data output cycle, state is STATE_READY return 0x0
[   16.338526] nand: device found, Manufacturer ID: 0x98, Chip ID: 0x39
[   16.340217] nand: Toshiba NAND 128MiB 1,8V 8-bit
[   16.341332] nand: 128 MiB, SLC, erase size: 16 KiB, page size: 512, OOB size: 16
[   16.343339] flash size: 128 MiB
[   16.344177] page size: 512 bytes
[   16.344973] OOB area size: 16 bytes
[   16.345869] sector size: 16 KiB
[   16.346641] pages number: 262144
[   16.347435] pages per sector: 32
[   16.348311] bus width: 8
[   16.348995] bits in sector size: 14
[   16.349915] bits in page size: 9
[   16.350780] bits in OOB size: 4
[   16.351613] flash size with OOB: 135168 KiB
[   16.352719] page address bytes: 4
[   16.353610] sector address bytes: 3
[   16.354536] options: 0x42
[   16.358176] Scanning device for bad blocks
[   16.403200] Creating 1 MTD partitions on "NAND 128MiB 1,8V 8-bit":
[   16.404847] 0x000000000000-0x000008000000 : "NAND simulator partition 0"
[   16.421180] Ethernet Channel Bonding Driver: v3.7.1 (April 27, 2011)
[   16.425687] MACsec IEEE 802.1AE
[   16.431227] libphy: mdio_driver_register: xgmiitorgmii
[   16.432629] tun: Universal TUN/TAP device driver, 1.6
[   16.433895] tun: (C) 1999-2004 Max Krasnyansky <maxk@qualcomm.com>
[   16.435661] arcnet: arcnet loaded
[   16.436532] arcnet:rfc1201: RFC1201 "standard" (`a') encapsulation support loaded
[   16.437788] arcnet:rfc1051: RFC1051 "simple standard" (`s') encapsulation support loaded
[   16.438980] arcnet:arc_rawmode: raw mode (`r') encapsulation support loaded
[   16.439996] arcnet:capmode: cap mode (`c') encapsulation support loaded
[   16.441013] arcnet:com90xx: COM90xx chipset support
[   16.743532] S3: No ARCnet cards found.
[   16.744339] arcnet:com20020_pci: COM20020 PCI support
[   16.745648] libphy: mdio_driver_register: bcm53xx
[   16.746668] libphy: mdio_driver_register: mv88e6085
[   16.747579] e1000: Intel(R) PRO/1000 Network Driver - version 7.3.21-k8-NAPI
[   16.748824] e1000: Copyright (c) 1999-2006 Intel Corporation.
[   17.179867] ACPI: PCI Interrupt Link [LNKC] enabled at IRQ 11
[   17.539804] e1000 0000:00:03.0 eth0: (PCI:33MHz:32-bit) 52:54:00:12:34:56
[   17.541026] e1000 0000:00:03.0 eth0: Intel(R) PRO/1000 Network Connection
[   18.751605] e1000 0000:00:03.0 eth0: (PCI:33MHz:32-bit) 52:54:00:12:34:56
[   18.752857] e1000 0000:00:03.0 eth0: Intel(R) PRO/1000 Network Connection
[   18.754181] e1000e: Intel(R) PRO/1000 Network Driver - 3.2.6-k
[   18.755228] e1000e: Copyright(c) 1999 - 2015 Intel Corporation.
[   18.756373] igb: Intel(R) Gigabit Ethernet Network Driver - version 5.4.0-k
[   18.757637] igb: Copyright (c) 2007-2014 Intel Corporation.
[   18.758785] ixgbe: Intel(R) 10 Gigabit PCI Express Network Driver - version 4.4.0-k
[   18.760164] ixgbe: Copyright (c) 1999-2016 Intel Corporation.
[   18.761824] usbcore: registered new interface driver irda-usb
[   18.762899] usbcore: registered new interface driver stir4200
[   18.764991] usbcore: registered new interface driver mcs7780
[   18.766248] usbcore: registered new interface driver ks959-sir
[   18.771392] PPP generic driver version 2.4.2
[   18.772594] PPP BSD Compression module registered
[   18.773367] PPP Deflate Compression module registered
[   18.774278] PPP MPPE Compression module registered
[   18.775104] NET: Registered protocol family 24
[   18.775868] ipw2100: Intel(R) PRO/Wireless 2100 Network Driver, git-1.2.2
[   18.776993] ipw2100: Copyright(c) 2003-2006 Intel Corporation
[   18.778261] ipw2200: Intel(R) PRO/Wireless 2200/2915 Network Driver, 1.2.2kd
[   18.779633] ipw2200: Copyright(c) 2003-2006 Intel Corporation
[   18.780834] libipw: 802.11 data/management/control stack, git-1.1.13
[   18.782042] libipw: Copyright (C) 2004-2005 Intel Corporation <jketreno@linux.intel.com>
[   18.783550] iwl4965: Intel(R) Wireless WiFi 4965 driver for Linux, in-tree:d
[   18.784852] iwl4965: Copyright(c) 2003-2011 Intel Corporation
[   18.786064] iwl3945: Intel(R) PRO/Wireless 3945ABG/BG Network Connection driver for Linux, in-tree:ds
[   18.787768] iwl3945: Copyright(c) 2003-2011 Intel Corporation
[   18.791964] Intel(R) Wireless WiFi driver for Linux
[   18.792794] Copyright(c) 2003- 2015 Intel Corporation
[   18.794030] usbcore: registered new interface driver rt2500usb
[   18.795014] usbcore: registered new interface driver rt2800usb
[   18.796237] usbcore: registered new interface driver rtl8187
[   18.797322] usbcore: registered new interface driver rtl8192cu
[   18.798987] usbcore: registered new interface driver rtl8xxxu
[   18.800160] usbcore: registered new interface driver RSI-USB WLAN
[   18.801279] usbcore: registered new interface driver zd1201
[   18.802435] usbcore: registered new interface driver rndis_wlan
[   18.803648] mac80211_hwsim: initializing netlink
[   18.810009] usbcore: registered new interface driver i2400m_usb
[   18.811188] usbcore: registered new interface driver kaweth
[   18.812318] usbcore: registered new interface driver rtl8150
[   18.813364] usbcore: registered new interface driver r8152
[   18.814443] usbcore: registered new interface driver lan78xx
[   18.815569] usbcore: registered new interface driver ax88179_178a
[   18.816721] usbcore: registered new interface driver cdc_ether
[   18.817902] usbcore: registered new interface driver cdc_eem
[   18.819005] usbcore: registered new interface driver CoreChips
[   18.820094] usbcore: registered new interface driver smsc75xx
[   18.821139] usbcore: registered new interface driver smsc95xx
[   18.822163] usbcore: registered new interface driver net1080
[   18.823227] usbcore: registered new interface driver plusb
[   18.824389] usbcore: registered new interface driver rndis_host
[   18.825533] usbcore: registered new interface driver zaurus
[   18.826550] usbcore: registered new interface driver MOSCHIP usb-ethernet driver
[   18.828017] usbcore: registered new interface driver int51x1
[   18.829125] usbcore: registered new interface driver kalmia
[   18.830153] usbcore: registered new interface driver ipheth
[   18.831210] usbcore: registered new interface driver cdc_ncm
[   18.832281] usbcore: registered new interface driver huawei_cdc_ncm
[   18.833504] usbcore: registered new interface driver lg-vl600
[   18.834573] usbcore: registered new interface driver qmi_wwan
[   18.835602] usbcore: registered new interface driver ch9200
[   18.836597] FUJITSU Extended Socket Network Device Driver - version 1.2 - Copyright (c) 2015 FUJITSU LIMITED
[   18.838640] Madge ATM Horizon [Ultra] driver version 1.2.1
[   18.839656] hrz: debug bitmap is 0
[   18.840451] idt77252_init: at ffffffff82d87285
[   18.841324] Solos PCI Driver Version 1.04
[   18.843630] usbcore: registered new interface driver hwa-rc
[   18.844788] usbcore: registered new interface driver i1480-dfu-usb
[   18.846908] uhci_hcd: USB Universal Host Controller Interface driver
[   18.848372] driver u132_hcd
[   18.849194] usbcore: registered new interface driver hwa-hc
[   18.850476] usbcore: registered new interface driver cdc_acm
[   18.851473] cdc_acm: USB Abstract Control Model driver for USB modems and ISDN adapters
[   18.852992] usbcore: registered new interface driver cdc_wdm
[   18.854083] usbcore: registered new interface driver mdc800
[   18.855068] mdc800: v0.7.5 (30/10/2000):USB Driver for Mustek MDC800 Digital Camera
[   18.856549] usbcore: registered new interface driver adutux
[   18.857672] usbcore: registered new interface driver appledisplay
[   18.858869] usbcore: registered new interface driver emi26 - firmware loader
[   18.860218] usbcore: registered new interface driver emi62 - firmware loader
[   18.861515] ftdi_elan: driver ftdi-elan
[   18.862279] usbcore: registered new interface driver ftdi-elan
[   18.863414] usbcore: registered new interface driver idmouse
[   18.864519] usbcore: registered new interface driver iowarrior
[   18.865680] usbcore: registered new interface driver isight_firmware
[   18.866821] usbcore: registered new interface driver usblcd
[   18.867884] usbcore: registered new interface driver usbtest
[   18.868979] usbcore: registered new interface driver trancevibrator
[   18.870164] usbcore: registered new interface driver usbsevseg
[   18.871263] usbcore: registered new interface driver yurex
[   18.872511] usbcore: registered new interface driver chaoskey
[   18.873626] usbcore: registered new interface driver sisusb
[   18.875091] dummy_hcd dummy_hcd.0: USB Host+Gadget Emulator, driver 02 May 2005
[   18.876319] dummy_hcd dummy_hcd.0: Dummy host controller
[   18.877769] dummy_hcd dummy_hcd.0: new USB bus registered, assigned bus number 1
[   18.880635] hub 1-0:1.0: USB hub found
[   18.881539] hub 1-0:1.0: 1 port detected
[   18.882860] hub 1-0:1.0: USB hub found
[   18.883605] hub 1-0:1.0: 1 port detected
[   18.885792] hub 1-0:1.0: USB hub found
[   18.886508] hub 1-0:1.0: 1 port detected
[   18.887548] hub 1-0:1.0: USB hub found
[   18.888325] hub 1-0:1.0: 1 port detected
[   18.889449] dummy_hcd dummy_hcd.0: remove, state 1
[   18.890409] usb usb1: USB disconnect, device number 1
[   18.892976] dummy_hcd dummy_hcd.0: stopped
[   18.893694] dummy_hcd dummy_hcd.0: USB bus 1 deregistered
[   18.895329] dummy_hcd dummy_hcd.0: USB Host+Gadget Emulator, driver 02 May 2005
[   18.896688] dummy_hcd dummy_hcd.0: Dummy host controller
[   18.898008] dummy_hcd dummy_hcd.0: new USB bus registered, assigned bus number 1
[   18.900321] hub 1-0:1.0: USB hub found
[   18.901040] hub 1-0:1.0: 1 port detected
[   18.901974] hub 1-0:1.0: USB hub found
[   18.902700] hub 1-0:1.0: 1 port detected
[   18.904205] hub 1-0:1.0: USB hub found
[   18.904949] hub 1-0:1.0: 1 port detected
[   18.905950] hub 1-0:1.0: USB hub found
[   18.906672] hub 1-0:1.0: 1 port detected
[   18.909089] kobject (ffff880139844f78): tried to init an initialized object, something is seriously wrong.
[   18.910801] CPU: 0 PID: 1 Comm: swapper Not tainted 4.8.0-14895-gaf1fee9 #1
[   18.912050] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS rel-1.9.3-0-ge2fc41e-prebuilt.qemu-project.org 04/01/2014
[   18.914091]  ffff88013a8f3ba0 ffffffff812cf3c2 ffff88013a8f3bc0 ffffffff812d1719
[   18.915488]  ffff880139844f68 ffff880139844ed8 ffff88013a8f3bd8 ffffffff81453f4f
[   18.917004]  ffff880139844f68 ffff88013a8f3bf0 ffffffff814547a5 ffff880139163c00
[   18.918428] Call Trace:
[   18.918921]  [<ffffffff812cf3c2>] dump_stack+0x19/0x1b
[   18.919866]  [<ffffffff812d1719>] kobject_init+0x31/0x7f
[   18.920878]  [<ffffffff81453f4f>] device_initialize+0x23/0xd2
[   18.921964]  [<ffffffff814547a5>] device_register+0xd/0x18
[   18.922978]  [<ffffffff8188ad4b>] usb_add_gadget_udc_release+0xc5/0x2c9
[   18.924237]  [<ffffffff8188afc8>] usb_add_gadget_udc+0xb/0xd
[   18.925338]  [<ffffffff8188dd59>] dummy_udc_probe+0x19e/0x1df
[   18.926446]  [<ffffffff814590da>] platform_drv_probe+0x23/0x4e
[   18.927481]  [<ffffffff81457daa>] driver_probe_device+0x1d6/0x407
[   18.928543]  [<ffffffff81458153>] __device_attach_driver+0x90/0xd0
[   18.929645]  [<ffffffff814580c3>] ? driver_allows_async_probing+0xd/0xd
[   18.930828]  [<ffffffff81456623>] bus_for_each_drv+0x7a/0x84
[   18.931934]  [<ffffffff81457aae>] __device_attach+0x89/0xe7
[   18.932939]  [<ffffffff814582a3>] device_initial_probe+0xe/0x10
[   18.934015]  [<ffffffff814567de>] bus_probe_device+0x2e/0x99
[   18.935035]  [<ffffffff814546a2>] device_add+0x3f0/0x4e6
[   18.935981]  [<ffffffff814596f6>] platform_device_add+0x16d/0x1c6
[   18.937190]  [<ffffffff82d89e70>] init+0x264/0x366
[   18.938050]  [<ffffffff82d89c0c>] ? trace_event_define_fields_udc_log_req+0x205/0x205
[   18.939391]  [<ffffffff82d3706c>] do_one_initcall+0x88/0x145
[   18.940505]  [<ffffffff82d368c1>] ? set_debug_rodata+0x12/0x12
[   18.941603]  [<ffffffff82d37243>] kernel_init_freeable+0x11a/0x19b
[   18.942705]  [<ffffffff81e03c65>] ? rest_init+0x12c/0x12c
[   18.943672]  [<ffffffff81e03c6e>] kernel_init+0x9/0xeb
[   18.944587]  [<ffffffff81e142ca>] ret_from_fork+0x2a/0x40
[   18.947017] using random self ethernet address
[   18.947869] using random host ethernet address
[   18.949687] usb0: HOST MAC 72:f9:56:11:d6:0c
[   18.950493] usb0: MAC e2:24:cb:ad:87:87
[   18.951259] g_ether gadget: Ethernet Gadget, version: Memorial Day 2008
[   18.952520] g_ether gadget: g_ether ready
[   18.953345] usbip_core: USB/IP Core v1.0.0
[   18.954593] vhci_hcd vhci_hcd: USB/IP Virtual Host Controller
[   18.955878] vhci_hcd vhci_hcd: new USB bus registered, assigned bus number 2
[   18.957229] BUG: key ffff8801398dc558 not in .data!
[   18.958180] ------------[ cut here ]------------
[   18.959076] WARNING: CPU: 0 PID: 1 at ../kernel/locking/lockdep.c:3131 lockdep_init_map+0x119/0x1ca
[   18.960744] DEBUG_LOCKS_WARN_ON(1)[   18.961303] CPU: 0 PID: 1 Comm: swapper Not tainted 4.8.0-14895-gaf1fee9 #1
[   18.962498] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS rel-1.9.3-0-ge2fc41e-prebuilt.qemu-project.org 04/01/2014
[   18.964392]  ffff88013a8f39e0 ffffffff812cf3c2 ffff88013a8f3a20 ffffffff8109dd32
[   18.965705]  00000c3b3a8f3a98 ffff880139169bd8 ffff8801398dc558 0000000000001000
[   18.967055]  0000000000000000 0000000000000000 ffff88013a8f3a88 ffffffff8109dd93
[   18.968474] Call Trace:
[   18.968939]  [<ffffffff812cf3c2>] dump_stack+0x19/0x1b
[   18.969830]  [<ffffffff8109dd32>] __warn+0xb6/0xd1
[   18.970648]  [<ffffffff8109dd93>] warn_slowpath_fmt+0x46/0x4e
[   18.971641]  [<ffffffff810d2b6f>] lockdep_init_map+0x119/0x1ca
[   18.972658]  [<ffffffff8123c4e1>] __kernfs_create_file+0x75/0xc3
[   18.973741]  [<ffffffff8123cc8f>] sysfs_add_file_mode_ns+0xf3/0x1c8
[   18.974923]  [<ffffffff8123d8da>] internal_create_group+0x210/0x364
[   18.976011]  [<ffffffff8123da3c>] sysfs_create_group+0xe/0x10
[   18.977079]  [<ffffffff818be744>] vhci_start+0x193/0x1e8
[   18.978026]  [<ffffffff817fe2a9>] usb_add_hcd+0x57b/0x8a7
[   18.978991]  [<ffffffff818bd600>] vhci_hcd_probe+0x63/0xcd
[   18.979980]  [<ffffffff814590da>] platform_drv_probe+0x23/0x4e
[   18.980956]  [<ffffffff81457daa>] driver_probe_device+0x1d6/0x407
[   18.982065]  [<ffffffff81458153>] __device_attach_driver+0x90/0xd0
[   18.983211]  [<ffffffff814580c3>] ? driver_allows_async_probing+0xd/0xd
[   18.984454]  [<ffffffff81456623>] bus_for_each_drv+0x7a/0x84
[   18.985471]  [<ffffffff81457aae>] __device_attach+0x89/0xe7
[   18.986474]  [<ffffffff814582a3>] device_initial_probe+0xe/0x10
[   18.987561]  [<ffffffff814567de>] bus_probe_device+0x2e/0x99
[   18.988658]  [<ffffffff814546a2>] device_add+0x3f0/0x4e6
[   18.989587]  [<ffffffff811b8cfa>] ? kfree+0xfe/0x3b1
[   18.990486]  [<ffffffff814596f6>] platform_device_add+0x16d/0x1c6
[   18.991576]  [<ffffffff814598fb>] platform_device_register_full+0xae/0x104
[   18.992842]  [<ffffffff82d8a1ce>] vhci_hcd_init+0xbc/0x144
[   18.993850]  [<ffffffff82d8a112>] ? usbip_core_init+0x17/0x17
[   18.994922]  [<ffffffff82d3706c>] do_one_initcall+0x88/0x145
[   18.996070]  [<ffffffff82d368c1>] ? set_debug_rodata+0x12/0x12
[   18.997154]  [<ffffffff82d37243>] kernel_init_freeable+0x11a/0x19b
[   18.998307]  [<ffffffff81e03c65>] ? rest_init+0x12c/0x12c
[   18.999341]  [<ffffffff81e03c6e>] kernel_init+0x9/0xeb
[   19.000260]  [<ffffffff81e142ca>] ret_from_fork+0x2a/0x40
[   19.001279] ---[ end trace ea3992dbfd3d2f66 ]---
[   19.002163] vhci_hcd: created sysfs vhci_hcd
[   19.003479] hub 2-0:1.0: USB hub found
[   19.004247] hub 2-0:1.0: 8 ports detected
[   19.005337] hub 2-0:1.0: USB hub found
[   19.006057] hub 2-0:1.0: 8 ports detected
[   19.007425] hub 2-0:1.0: USB hub found
[   19.008121] hub 2-0:1.0: 8 ports detected
[   19.009223] hub 2-0:1.0: USB hub found
[   19.009962] hub 2-0:1.0: 8 ports detected
[   19.011091] vhci_hcd vhci_hcd: remove, state 1
[   19.011988] dummy_hcd dummy_hcd.0: port status 0x00010101 has changes
[   19.013265] usb usb2: USB disconnect, device number 1
[   19.014686] vhci_hcd: stop threads
[   19.015335] vhci_hcd: release socket
[   19.015963] vhci_hcd: disconnect device
[   19.016623] vhci_hcd: stop threads
[   19.017219] vhci_hcd: release socket
[   19.017850] vhci_hcd: disconnect device
[   19.018556] vhci_hcd: stop threads
[   19.019196] vhci_hcd: release socket
[   19.019839] vhci_hcd: disconnect device
[   19.020516] vhci_hcd: stop threads
[   19.021157] vhci_hcd: release socket
[   19.021806] vhci_hcd: disconnect device
[   19.022497] vhci_hcd: stop threads
[   19.023148] vhci_hcd: release socket
[   19.023794] vhci_hcd: disconnect device
[   19.024571] vhci_hcd: stop threads
[   19.025213] vhci_hcd: release socket
[   19.025888] vhci_hcd: disconnect device
[   19.026615] vhci_hcd: stop threads
[   19.027243] vhci_hcd: release socket
[   19.027893] vhci_hcd: disconnect device
[   19.028598] vhci_hcd: stop threads
[   19.029224] vhci_hcd: release socket
[   19.029897] vhci_hcd: disconnect device
[   19.030611] vhci_hcd vhci_hcd: USB bus 2 deregistered
[   19.031793] vhci_hcd vhci_hcd: USB/IP Virtual Host Controller
[   19.033040] vhci_hcd vhci_hcd: new USB bus registered, assigned bus number 2
[   19.034372] BUG: key ffff8801398dc558 not in .data!
[   19.035270] vhci_hcd: created sysfs vhci_hcd
[   19.036549] hub 2-0:1.0: USB hub found
[   19.037267] hub 2-0:1.0: 8 ports detected
[   19.038436] hub 2-0:1.0: USB hub found
[   19.039140] hub 2-0:1.0: 8 ports detected
[   19.040565] hub 2-0:1.0: USB hub found
[   19.041291] hub 2-0:1.0: 8 ports detected
[   19.042403] hub 2-0:1.0: USB hub found
[   19.043159] hub 2-0:1.0: 8 ports detected
[   19.044289] vhci_hcd: USB/IP 'Virtual' Host Controller (VHCI) Driver v1.0.0
[   19.046140] udc usbip-vudc.0: releasing 'usbip-vudc.0'
[   19.047448] i8042: PNP: PS/2 Controller [PNP0303:KBD,PNP0f13:MOU] at 0x60,0x64 irq 1,12
[   19.049837] serio: i8042 KBD port at 0x60,0x64 irq 1
[   19.050863] serio: i8042 AUX port at 0x60,0x64 irq 12
[   19.052865] serio: i8042 KBD port at 0x60,0x64 irq 1
[   19.053841] serio: i8042 AUX port at 0x60,0x64 irq 12
[   19.126355] mousedev: PS/2 mouse device common for all mice
[   19.128177] input: AT Translated Set 2 keyboard as /devices/platform/i8042/serio2/input/input1
[   19.129805] evbug: Connected device: input1 (AT Translated Set 2 keyboard at isa0060/serio0/input0)
[   19.132040] usbcore: registered new interface driver bcm5974
[   19.132200] usbcore: registered new interface driver synaptics_usb
[   19.132240] usbcore: registered new interface driver usb_acecad
[   19.132278] usbcore: registered new interface driver gtco
[   19.132313] usbcore: registered new interface driver kbtab
[   19.132778] piix4_smbus 0000:00:01.3: SMBus Host Controller at 0x700, revision 0
[   19.145771] evbug: Disconnected device: input1
[   19.148543] input: AT Translated Set 2 keyboard as /devices/platform/i8042/serio2/input/input2
[   19.150431] evbug: Connected device: input2 (AT Translated Set 2 keyboard at isa0060/serio0/input0)
smbus: error: Unexpected recv start condition in state 3
smbus: error: Unexpected read in state -1
smbus: error: Unexpected NACK in state -1
smbus: error: Unexpected NACK in state -1
smbus: error: Unexpected recv start condition in state 3
smbus: error: Unexpected read in state -1
smbus: error: Unexpected NACK in state -1
smbus: error: Unexpected NACK in state -1
[   19.167811] g_ether gadget: resume
[   19.168538] dummy_hcd dummy_hcd.0: port status 0x00100503 has changes
smbus: error: Unexpected recv start condition in state 3
smbus: error: Unexpected read in state -1
smbus: error: Unexpected NACK in state -1
smbus: error: Unexpected NACK in state -1
smbus: error: Unexpected recv start condition in state 3
smbus: error: Unexpected read in state -1
smbus: error: Unexpected NACK in state -1
smbus: error: Unexpected NACK in state -1
smbus: error: Unexpected recv start condition in state 3
smbus: error: Unexpected read in state -1
smbus: error: Unexpected NACK in state -1
smbus: error: Unexpected NACK in state -1
smbus: error: Unexpected recv start condition in state 3
smbus: error: Unexpected read in state -1
smbus: error: Unexpected NACK in state -1
smbus: error: Unexpected NACK in state -1
smbus: error: Unexpected recv start condition in state 3
smbus: error: Unexpected read in state -1
smbus: error: Unexpected NACK in state -1
smbus: error: Unexpected NACK in state -1
smbus: error: Unexpected recv start condition in state 3
smbus: error: Unexpected read in state -1
smbus: error: Unexpected NACK in state -1
smbus: error: Unexpected NACK in state -1
[   19.188324] piix4_smbus 0000:00:01.3: SMBus Host Controller at 0x700, revision 0
smbus: error: Unexpected recv start condition in state 3
smbus: error: Unexpected read in state -1
smbus: error: Unexpected NACK in state -1
smbus: error: Unexpected NACK in state -1
smbus: error: Unexpected recv start condition in state 3
smbus: error: Unexpected read in state -1
smbus: error: Unexpected NACK in state -1
smbus: error: Unexpected NACK in state -1
[   19.221792] usb 1-1: new high-speed USB device number 2 using dummy_hcd
smbus: error: Unexpected recv start condition in state 3
smbus: error: Unexpected read in state -1
smbus: error: Unexpected NACK in state -1
smbus: error: Unexpected NACK in state -1
smbus: error: Unexpected recv start condition in state 3
smbus: error: Unexpected read in state -1
smbus: error: Unexpected NACK in state -1
smbus: error: Unexpected NACK in state -1
smbus: error: Unexpected recv start condition in state 3[udc dummy_udc.0: set_address = 2
[   30.949372] i2c-parport-light: adapter type unspecified
[   30.950268] usbcore: registered new interface driver RobotFuzz Open Source InterFace, OSIF
[   30.951850] usbcore: registered new interface driver i2c-tiny-usb
[   30.953176] Driver for 1-wire Dallas network protocol.
[   30.954333] usbcore: registered new interface driver DS9490R
[   30.955471] DS1WM w1 busmaster driver - (c) 2004 Szabolcs Gyurko
[   30.956793] __power_supply_register: Expected proper parent device for 'test_ac'
[   30.958237] __power_supply_register: Expected proper parent device for 'test_battery'
[   30.959990] __power_supply_register: Expected proper parent device for 'test_usb'
[   30.969771] g_ether gadget: high-speed config #1: CDC Ethernet (ECM)
[   30.970918] dummy_udc dummy_udc.0: enabled ep5in-int (ep5in-intr) maxpacket 16 stream disabled
[   30.972368] g_ether gadget: init ecm
[   30.972998] g_ether gadget: notify connect false
[   30.973799] g_ether gadget: notify speed 425984000
[   30.978769] g_ether gadget: activate ecm
[   30.979513] dummy_udc dummy_udc.0: enabled ep1in-bulk (ep1in-bulk) maxpacket 512 stream disabled
[   30.980978] dummy_udc dummy_udc.0: enabled ep2out-bulk (ep2out-bulk) maxpacket 512 stream disabled
[   30.982538] usb0: qlen 10
[   30.983004] g_ether gadget: ecm_close
[   30.985786] g_ether gadget: packet filter 0c
[   30.986538] g_ether gadget: ecm req21.43 v000c i0000 l0
[   30.989266] cdc_ether 1-1:1.0 usb1: register 'cdc_ether' at usb-dummy_hcd.0-1, CDC Ethernet Device, 72:f9:56:11:d6:0c
[   30.991240] cdc_ether 1-1:1.0 usb1: unregister 'cdc_ether' usb-dummy_hcd.0-1, CDC Ethernet Device
[   30.997781] g_ether gadget: reset ecm
[   30.998451] usb0: gether_disconnect
[   30.999089] dummy_udc dummy_udc.0: disabled ep1in-bulk
[   30.999978] dummy_udc dummy_udc.0: disabled ep2out-bulk
[   31.000859] g_ether gadget: init ecm
[   31.003119] g_ether gadget: activate ecm
[   31.003896] dummy_udc dummy_udc.0: enabled ep1in-bulk (ep1in-bulk) maxpacket 512 stream disabled
[   31.005544] dummy_udc dummy_udc.0: enabled ep2out-bulk (ep2out-bulk) maxpacket 512 stream disabled
[   31.007192] usb0: qlen 10
[   31.007716] g_ether gadget: ecm_close
[   31.009765] g_ether gadget: packet filter 0c
[   31.010580] g_ether gadget: ecm req21.43 v000c i0000 l0
[   31.014330] cdc_ether 1-1:1.0 usb1: register 'cdc_ether' at usb-dummy_hcd.0-1, CDC Ethernet Device, 72:f9:56:11:d6:0c
[   31.018071] cdc_ether 1-1:1.0 usb1: unregister 'cdc_ether' usb-dummy_hcd.0-1, CDC Ethernet Device
[   31.024766] g_ether gadget: reset config
[   31.025276] g_ether gadget: ecm deactivated
[   31.025758] usb0: gether_disconnect
[   31.026210] dummy_udc dummy_udc.0: disabled ep1in-bulk
[   31.026905] dummy_udc dummy_udc.0: disabled ep2out-bulk
[   31.027527] dummy_udc dummy_udc.0: disabled ep5in-int
[   31.028154] g_ether gadget: high-speed config #0: unconfigured
[   31.030764] g_ether gadget: high-speed config #1: CDC Ethernet (ECM)
[   31.032244] dummy_udc dummy_udc.0: enabled ep5in-int (ep5in-intr) maxpacket 16 stream disabled
[   31.034073] g_ether gadget: init ecm
[   31.034854] g_ether gadget: notify connect false
[   31.035822] g_ether gadget: notify speed 425984000
[   31.038766] g_ether gadget: activate ecm
[   31.039551] dummy_udc dummy_udc.0: enabled ep1in-bulk (ep1in-bulk) maxpacket 512 stream disabled
[   31.041405] dummy_udc dummy_udc.0: enabled ep2out-bulk (ep2out-bulk) maxpacket 512 stream disabled
[   31.043444] usb0: qlen 10
[   31.043994] g_ether gadget: ecm_close
[   31.046765] g_ether gadget: packet filter 0c
[   31.047631] g_ether gadget: ecm req21.43 v000c i0000 l0
[   31.051201] cdc_ether 1-1:1.0 usb1: register 'cdc_ether' at usb-dummy_hcd.0-1, CDC Ethernet Device, 72:f9:56:11:d6:0c
[   31.052975] cdc_ether 1-1:1.0 usb1: unregister 'cdc_ether' usb-dummy_hcd.0-1, CDC Ethernet Device
[   31.058759] g_ether gadget: reset ecm
[   31.059264] usb0: gether_disconnect
[   31.059679] dummy_udc dummy_udc.0: disabled ep1in-bulk
[   31.060301] dummy_udc dummy_udc.0: disabled ep2out-bulk
[   31.060925] g_ether gadget: init ecm
[   31.062757] g_ether gadget: activate ecm
[   31.063317] dummy_udc dummy_udc.0: enabled ep1in-bulk (ep1in-bulk) maxpacket 512 stream disabled
[   31.064496] dummy_udc dummy_udc.0: enabled ep2out-bulk (ep2out-bulk) maxpacket 512 stream disabled
[   31.065656] usb0: qlen 10
[   31.066002] g_ether gadget: ecm_close
[   31.072820] g_ether gadget: packet filter 0c
[   31.078250] g_ether gadget: ecm req21.43 v000c i0000 l0
[   31.086230] cdc_ether 1-1:1.0 usb1: register 'cdc_ether' at usb-dummy_hcd.0-1, CDC Ethernet Device, 72:f9:56:11:d6:0c
[   31.175839] applesmc: supported laptop not found!
[   31.176472] applesmc: driver init failed (ret=-19)!
[   31.448872] pc87360: PC8736x not detected, module not inserted
[   31.498253] sdhci: Secure Digital Host Controller Interface driver
[   31.499215] sdhci: Copyright(c) Pierre Ossman
[   31.500175] usbcore: registered new interface driver ushc
[   31.501034] sdhci-pltfm: SDHCI platform and OF driver helper
[   31.502332] leds_ss4200: no LED devices found
[   31.509665] dcdbas dcdbas: Dell Systems Management Base Driver (version 5.6.0-3.2)
[   31.517046] dcdbas dcdbas: Dell Systems Management Base Driver (version 5.6.0-3.2)
[   31.525111] fw_cfg: probe of QEMU0002:00 failed with error -16
[   31.531188] CHRDEV "qat_adf_ctl" major number 233 goes below the dynamic allocation range
[   31.538984] CHRDEV "hidraw" major number 232 goes below the dynamic allocation range
[   31.543667] hidraw: raw HID events driver (C) Jiri Kosina
[   31.547164] CHRDEV "roccat" major number 230 goes below the dynamic allocation range
[   31.554103] usbcore: registered new interface driver usbhid
[   31.558548] usbhid: USB HID core driver
[   31.559631] usbcore: registered new interface driver prism2_usb
[   31.562225] usbcore: registered new interface driver r8712u
[   31.563210] usbcore: registered new interface driver r8188eu
[   31.564156] vme_user: VME User Space Access Driver
[   31.564957] vme_user: No cards, skipping registration
[   31.565801] vme_pio2: No cards, skipping registration
[   31.566627] no options.
[   31.567205] CHRDEV "fwtty" major number 229 goes below the dynamic allocation range
[   31.568501] CHRDEV "fwloop" major number 228 goes below the dynamic allocation range
[   31.569984] FPGA DOWNLOAD --->
[   31.570501] FPGA image file name: xlinx_fpga_firmware.bit
[   31.571524] GPIO INIT FAIL!!
[   31.573345] mostcore: init()
[   31.573993] aim_cdev: init()
[   31.574482] CHRDEV "cdev" major number 227 goes below the dynamic allocation range
[   31.575795] mostcore: registered new application interfacing module cdev
[   31.576919] aim_network: most_net_init()
[   31.577601] mostcore: registered new application interfacing module networking
[   31.578878] hdm_usb: hdm_usb_init()
[   31.579513] usbcore: registered new interface driver hdm_usb
[   31.580783] Board is not the VME system controller
[   31.581583] VME geographical address is set to 0
[   31.582819] CR/CSR Offset: 0
[   31.583484] Software Queue-Pair Transport over NTB, version 4
[   31.585139] Audio Excel DSP 16 init driver Copyright (C) Riccardo Facchetti 1995-98
[   31.586394] aedsp16: I/O, IRQ and DMA are mandatory
[   31.587237] pss: mss_io, mss_dma, mss_irq and pss_io must be set.
[   31.588240] ad1848/cs4248 codec driver Copyright (C) by Hannu Savolainen 1993-1996
[   31.589488] ad1848: No ISAPnP cards found, trying standard ones...
[   31.590548] MediaTrix audio driver Copyright (C) by Hannu Savolainen 1993-1996
[   31.591760] I/O, IRQ, DMA and type are mandatory
[   31.592515] Pro Audio Spectrum driver Copyright (C) by Hannu Savolainen 1993-1996
[   31.593595] I/O, IRQ, DMA and type are mandatory
[   31.594359] sb: Init: Starting Probe...
[   31.595107] sb: Init: Done
[   31.595617] uart6850: irq and io must be set.
[   31.596370] YM3812 and OPL-3 driver Copyright (C) by Hannu Savolainen, Rob Hooft 1993-1996
[   31.597775] MIDI Loopback device driver
[   31.598762] ipip: IPv4 and MPLS over IPv4 tunneling driver
[   31.599765] gre: GRE over IPv4 demultiplexor driver
[   31.600365] ip_gre: GRE over IPv4 tunneling driver
[   31.601445] Initializing XFRM netlink socket
[   31.602806] NET: Registered protocol family 10
[   31.604846] ip6_gre: GRE over IPv6 tunneling driver
[   31.605671] NET: Registered protocol family 15
[   31.606408] NET: Registered protocol family 4
[   31.606961] NET: Registered protocol family 5
[   31.607723] NET: Registered protocol family 9
[   31.608462] X25: Linux Version 0.2
[   31.609470] NET: Registered protocol family 41
[   31.610402] l2tp_core: L2TP core driver, V2.0
[   31.611154] l2tp_ppp: PPPoL2TP kernel driver, V2.0
[   31.611953] l2tp_ip: L2TP IP encapsulation support (L2TPv3)
[   31.612791] l2tp_netlink: L2TP netlink interface
[   31.613664] l2tp_debugfs: L2TP debugfs support
[   31.614466] l2tp_ip6: L2TP IP encapsulation support for IPv6 (L2TPv3)
[   31.624258] DCCP: Activated CCID 2 (TCP-like)
[   31.625716] sctp: Hash tables configured (bind 32/51)
[   31.626777] lib80211: common routines for IEEE802.11 drivers
[   31.627607] lib80211_crypt: registered algorithm 'NULL'
[   31.628372] lib80211_crypt: registered algorithm 'WEP'
[   31.629128] lib80211_crypt: registered algorithm 'CCMP'
[   31.629973] lib80211_crypt: registered algorithm 'TKIP'
[   31.630939] NET: Registered protocol family 37
[   31.632364] batman_adv: B.A.T.M.A.N. advanced 2016.5 (compatibility version 15) loaded
[   31.633764] openvswitch: Open vSwitch switching datapath
[   31.634998] mpls_gso: MPLS GSO support
[   31.636301] registered taskstats version 1
[   31.638264] gtp: GTP module loaded (pdp ctx size 80 bytes)
[   31.639220] BIOS EDD facility v0.16 2004-Jun-25, 0 devices found
[   31.640239] EDD information not available.
[   31.649190] debug: unmapping init [mem 0xffffffff82d36000-0xffffffff82e5efff]
[   31.650465] Write protecting the kernel read-only data: 24576k
[   31.652119] debug: unmapping init [mem 0xffff880001e19000-0xffff880001ffffff]
[   31.653381] debug: unmapping init [mem 0xffff880002634000-0xffff8800027fffff]
[   31.672476] x86/mm: Checked W+X mappings: passed, no W+X pages found.
[   31.673676] Kernel panic - not syncing: No working init found.  Try passing init= option to kernel. See Linux Documentation/init.txt for guidance.
[   31.675665] CPU: 0 PID: 1 Comm: swapper Tainted: G        W       4.8.0-14895-gaf1fee9 #1
[   31.676867] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS rel-1.9.3-0-ge2fc41e-prebuilt.qemu-project.org 04/01/2014
[   31.678679]  ffff88013a8f3eb8 ffffffff812cf3c2 ffff88013a8f3f38 ffffffff8115cf6a
[   31.679997]  ffffffff00000008 ffff88013a8f3f48 ffff88013a8f3ee0 0000000000000000
[   31.681324]  0000000000000000 0000000000000000 0000000000001c16 0000000000000001
[   31.682627] Call Trace:
[   31.683059]  [<ffffffff812cf3c2>] dump_stack+0x19/0x1b
[   31.683925]  [<ffffffff8115cf6a>] panic+0xd0/0x20c
[   31.684739]  [<ffffffff81e03c65>] ? rest_init+0x12c/0x12c
[   31.685628]  [<ffffffff81e03d4c>] kernel_init+0xe7/0xeb
[   31.686508]  [<ffffffff81e142ca>] ret_from_fork+0x2a/0x40
[   31.687411] Kernel Offset: disabled
[   31.688008] ---[ end Kernel panic - not syncing: No working init found.  Try passing init= option to kernel. See Linux Documentation/init.txt for guidance.
[   63.483779] Writes:  Total: 2  Max/Min: 0/0   Fail: 0

[  124.923777] Writes:  Total: 2  Max/Min: 0/0   Fail: 0
QEMU: Terminated


Output 2 (32ab0a38f0bd554cc45203ff4fdb6b0fdea6f025 without bug):
anielsen@lx-anielsen ~/work/opensource-phy/lkp-tests (master) $ sudo qemu-system-x86_64 -enable-kvm -cpu host -smp 2 -m 4G -kernel ../net-next/bug-build/arch/x86_64/boot/bzImage -nographic
[    0.000000] Linux version 4.8.0-14894-g32ab0a38 (anielsen@lx-anielsen) (gcc version 5.2.0 (Gentoo 5.2.0 p1.3, pie-0.6.5) ) #2 PREEMPT Mon Nov 7 12:46:39 CET 2016
[    0.000000] Command line:
[    0.000000] x86/fpu: Legacy x87 FPU detected.
[    0.000000] x86/fpu: Using 'eager' FPU context switches.
[    0.000000] e820: BIOS-provided physical RAM map:
[    0.000000] BIOS-e820: [mem 0x0000000000000000-0x000000000009fbff] usable
[    0.000000] BIOS-e820: [mem 0x000000000009fc00-0x000000000009ffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000000f0000-0x00000000000fffff] reserved
[    0.000000] BIOS-e820: [mem 0x0000000000100000-0x00000000bffdffff] usable
[    0.000000] BIOS-e820: [mem 0x00000000bffe0000-0x00000000bfffffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000feffc000-0x00000000feffffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000fffc0000-0x00000000ffffffff] reserved
[    0.000000] BIOS-e820: [mem 0x0000000100000000-0x000000013fffffff] usable
[    0.000000] NX (Execute Disable) protection: active
[    0.000000] SMBIOS 2.8 present.
[    0.000000] Hypervisor detected: KVM
[    0.000000] e820: last_pfn = 0x140000 max_arch_pfn = 0x400000000
[    0.000000] x86/PAT: Configuration [0-7]: WB  WC  UC- UC  WB  WC  UC- WT
[    0.000000] e820: last_pfn = 0xbffe0 max_arch_pfn = 0x400000000
[    0.000000] ACPI: Early table checksum verification disabled
[    0.000000] ACPI: RSDP 0x00000000000F6970 000014 (v00 BOCHS )
[    0.000000] ACPI: RSDT 0x00000000BFFE1936 000030 (v01 BOCHS  BXPCRSDT 00000001 BXPC 00000001)
[    0.000000] ACPI: FACP 0x00000000BFFE180A 000074 (v01 BOCHS  BXPCFACP 00000001 BXPC 00000001)
[    0.000000] ACPI: DSDT 0x00000000BFFE0040 0017CA (v01 BOCHS  BXPCDSDT 00000001 BXPC 00000001)
[    0.000000] ACPI: FACS 0x00000000BFFE0000 000040
[    0.000000] ACPI: APIC 0x00000000BFFE187E 000080 (v01 BOCHS  BXPCAPIC 00000001 BXPC 00000001)
[    0.000000] ACPI: HPET 0x00000000BFFE18FE 000038 (v01 BOCHS  BXPCHPET 00000001 BXPC 00000001)
[    0.000000] kvm-clock: Using msrs 4b564d01 and 4b564d00
[    0.000000] kvm-clock: cpu 0, msr 1:3f800001, primary cpu clock
[    0.000000] kvm-clock: using sched offset of 692389337 cycles
[    0.000000] clocksource: kvm-clock: mask: 0xffffffffffffffff max_cycles: 0x1cd42e4dffb, max_idle_ns: 881590591483 ns
[    0.000000] Zone ranges:
[    0.000000]   DMA      [mem 0x0000000000001000-0x0000000000ffffff]
[    0.000000]   DMA32    [mem 0x0000000001000000-0x00000000ffffffff]
[    0.000000]   Normal   [mem 0x0000000100000000-0x000000013fffffff]
[    0.000000]   Device   empty
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x0000000000001000-0x000000000009efff]
[    0.000000]   node   0: [mem 0x0000000000100000-0x00000000bffdffff]
[    0.000000]   node   0: [mem 0x0000000100000000-0x000000013fffffff]
[    0.000000] Initmem setup node 0 [mem 0x0000000000001000-0x000000013fffffff]
[    0.000000] ACPI: PM-Timer IO Port: 0x608
[    0.000000] APIC: NR_CPUS/possible_cpus limit of 1 reached. Processor 1/0x1 ignored.
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0xff] dfl dfl lint[0x1])
[    0.000000] IOAPIC[0]: apic_id 0, version 17, address 0xfec00000, GSI 0-23
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 5 global_irq 5 high level)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 10 global_irq 10 high level)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 11 global_irq 11 high level)
[    0.000000] Using ACPI (MADT) for SMP configuration information
[    0.000000] ACPI: HPET id: 0x8086a201 base: 0xfed00000
[    0.000000] KVM setup async PF for cpu 0
[    0.000000] kvm-stealtime: cpu 0, msr 2835b80
[    0.000000] e820: [mem 0xc0000000-0xfeffbfff] available for PCI devices
[    0.000000] Booting paravirtualized kernel on KVM
[    0.000000] clocksource: refined-jiffies: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 1910969940391419 ns
[    0.000000] Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 1032041
[    0.000000] Kernel command line:
[    0.000000] PID hash table entries: 4096 (order: 3, 32768 bytes)
[    0.000000] Dentry cache hash table entries: 524288 (order: 10, 4194304 bytes)
[    0.000000] Inode-cache hash table entries: 262144 (order: 9, 2097152 bytes)
[    0.000000] Memory: 3984728K/4193784K available (14427K kernel code, 5328K rwdata, 6352K rodata, 1188K init, 30876K bss, 209056K reserved, 0K cma-reserved)
[    0.000000] SLUB: HWalign=64, Order=0-3, MinObjects=0, CPUs=1, Nodes=1
[    0.000000] Running RCU self tests
[    0.000000] Preemptible hierarchical RCU implementation.
[    0.000000]  RCU debugfs-based tracing is enabled.
[    0.000000]  RCU lockdep checking is enabled.
[    0.000000]  Build-time adjustment of leaf fanout to 64.
[    0.000000] NR_IRQS:4352 nr_irqs:48 16
[    0.000000] console [ttyS0] enabled
[    0.000000] Lock dependency validator: Copyright (c) 2006 Red Hat, Inc., Ingo Molnar
[    0.000000] ... MAX_LOCKDEP_SUBCLASSES:  8
[    0.000000] ... MAX_LOCK_DEPTH:          48
[    0.000000] ... MAX_LOCKDEP_KEYS:        8191
[    0.000000] ... CLASSHASH_SIZE:          4096
[    0.000000] ... MAX_LOCKDEP_ENTRIES:     32768
[    0.000000] ... MAX_LOCKDEP_CHAINS:      65536
[    0.000000] ... CHAINHASH_SIZE:          32768
[    0.000000]  memory used by lock dependency info: 8671 kB
[    0.000000]  per task-struct memory footprint: 2688 bytes
[    0.000000] ODEBUG: selftest passed
[    0.000000] clocksource: hpet: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 19112604467 ns
[    0.000000] tsc: Detected 3066.410 MHz processor
[    0.948122] Calibrating delay loop (skipped) preset value.. 6132.82 BogoMIPS (lpj=3066410)
[    0.952806] pid_max: default: 32768 minimum: 301
[    0.953604] ACPI: Core revision 20160831
[    0.964638] ACPI: 1 ACPI AML tables successfully acquired and loaded

[    0.965934] Mount-cache hash table entries: 8192 (order: 4, 65536 bytes)
[    0.966955] Mountpoint-cache hash table entries: 8192 (order: 4, 65536 bytes)
[    0.972807] Last level iTLB entries: 4KB 0, 2MB 0, 4MB 0
[    0.973632] Last level dTLB entries: 4KB 0, 2MB 0, 4MB 0, 1GB 0
[    0.974529] CPU: Intel(R) Xeon(R) CPU           W3550  @ 3.07GHz (family: 0x6, model: 0x1a, stepping: 0x5)
[    0.981250] Performance Events: Nehalem events, Intel PMU driver.
[    0.982250] core: CPUID marked event: 'bus cycles' unavailable
[    0.983009] ... version:                2
[    0.983583] ... bit width:              48
[    0.984210] ... generic registers:      4
[    0.984773] ... value mask:             0000ffffffffffff
[    0.985488] ... max period:             000000007fffffff
[    0.986155] ... fixed-purpose events:   3
[    0.986755] ... event mask:             000000070000000f
[    0.993590] ..TIMER: vector=0x30 apic1=0 pin1=2 apic2=-1 pin2=-1
[    0.995703] devtmpfs: initialized
[    0.997029] x86/mm: Memory block size: 128MB
[    1.005124] clocksource: jiffies: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 1911260446275000 ns
[    1.007597] atomic64_test: passed for x86-64 platform with CX8 and with SSE
[    1.009212] pinctrl core: initialized pinctrl subsystem
[    1.011590] regulator-dummy: Failed to create debugfs directory
[    1.014001] NET: Registered protocol family 16
[    1.019160] cpuidle: using governor menu
[    1.020365] ACPI: bus type PCI registered
[    1.021235] acpiphp: ACPI Hot Plug PCI Controller Driver version: 0.5
[    1.023109] PCI: Using configuration type 1 for base access
[    1.088601] HugeTLB registered 2 MB page size, pre-allocated 0 pages
[    1.091587] ACPI: Added _OSI(Module Device)
[    1.092663] ACPI: Added _OSI(Processor Device)
[    1.093750] ACPI: Added _OSI(3.0 _SCP Extensions)
[    1.095464] ACPI: Added _OSI(Processor Aggregator Device)
[    1.105794] ACPI: Interpreter enabled
[    1.106733] ACPI: (supports S0 S5)
[    1.107399] ACPI: Using IOAPIC for interrupt routing
[    1.108470] PCI: Using host bridge windows from ACPI; if necessary, use "pci=nocrs" and report a bug
[    1.141812] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-ff])
[    1.146491] acpi PNP0A03:00: _OSC: OS supports [Segments]
[    1.147642] acpi PNP0A03:00: _OSC failed (AE_NOT_FOUND); disabling ASPM
[    1.149079] acpi PNP0A03:00: fail to add MMCONFIG information, can't access extended PCI configuration space under this bridge.
[    1.152629] acpiphp: Slot [3] registered
[    1.153838] acpiphp: Slot [4] registered
[    1.154901] acpiphp: Slot [5] registered
[    1.155968] acpiphp: Slot [6] registered
[    1.157017] acpiphp: Slot [7] registered
[    1.158105] acpiphp: Slot [8] registered
[    1.159184] acpiphp: Slot [9] registered
[    1.160255] acpiphp: Slot [10] registered
[    1.161367] acpiphp: Slot [11] registered
[    1.162445] acpiphp: Slot [12] registered
[    1.163563] acpiphp: Slot [13] registered
[    1.164672] acpiphp: Slot [14] registered
[    1.165759] acpiphp: Slot [15] registered
[    1.166887] acpiphp: Slot [16] registered
[    1.167954] acpiphp: Slot [17] registered
[    1.169029] acpiphp: Slot [18] registered
[    1.170168] acpiphp: Slot [19] registered
[    1.171271] acpiphp: Slot [20] registered
[    1.172409] acpiphp: Slot [21] registered
[    1.173479] acpiphp: Slot [22] registered
[    1.174602] acpiphp: Slot [23] registered
[    1.175698] acpiphp: Slot [24] registered
[    1.176770] acpiphp: Slot [25] registered
[    1.177850] acpiphp: Slot [26] registered
[    1.178963] acpiphp: Slot [27] registered
[    1.180035] acpiphp: Slot [28] registered
[    1.181146] acpiphp: Slot [29] registered
[    1.182244] acpiphp: Slot [30] registered
[    1.183350] acpiphp: Slot [31] registered
[    1.184327] PCI host bridge to bus 0000:00
[    1.185234] pci_bus 0000:00: root bus resource [io  0x0000-0x0cf7 window]
[    1.186748] pci_bus 0000:00: root bus resource [io  0x0d00-0xffff window]
[    1.188300] pci_bus 0000:00: root bus resource [mem 0x000a0000-0x000bffff window]
[    1.190028] pci_bus 0000:00: root bus resource [mem 0xc0000000-0xfebfffff window]
[    1.191743] pci_bus 0000:00: root bus resource [bus 00-ff]
[    1.202185] pci 0000:00:01.1: legacy IDE quirk: reg 0x10: [io  0x01f0-0x01f7]
[    1.203949] pci 0000:00:01.1: legacy IDE quirk: reg 0x14: [io  0x03f6]
[    1.205290] pci 0000:00:01.1: legacy IDE quirk: reg 0x18: [io  0x0170-0x0177]
[    1.207154] pci 0000:00:01.1: legacy IDE quirk: reg 0x1c: [io  0x0376]
[    1.210147] pci 0000:00:01.3: quirk: [io  0x0600-0x063f] claimed by PIIX4 ACPI
[    1.211960] pci 0000:00:01.3: quirk: [io  0x0700-0x070f] claimed by PIIX4 SMB
[    1.257524] ACPI: PCI Interrupt Link [LNKA] (IRQs 5 *10 11)
[    1.259689] ACPI: PCI Interrupt Link [LNKB] (IRQs 5 *10 11)
[    1.261736] ACPI: PCI Interrupt Link [LNKC] (IRQs 5 10 *11)
[    1.263829] ACPI: PCI Interrupt Link [LNKD] (IRQs 5 10 *11)
[    1.265683] ACPI: PCI Interrupt Link [LNKS] (IRQs *9)
[    1.270430] vgaarb: setting as boot device: PCI:0000:00:02.0
[    1.271834] vgaarb: device added: PCI:0000:00:02.0,decodes=io+mem,owns=io+mem,locks=none
[    1.273531] vgaarb: loaded
[    1.273967] vgaarb: bridge control possible 0000:00:02.0
[    1.276309] ACPI: bus type USB registered
[    1.277249] usbcore: registered new interface driver usbfs
[    1.278246] usbcore: registered new interface driver hub
[    1.279264] usbcore: registered new device driver usb
[    1.280509] pps_core: LinuxPPS API ver. 1 registered
[    1.281371] pps_core: Software ver. 5.3.6 - Copyright 2005-2007 Rodolfo Giometti <giometti@linux.it>
[    1.282949] PTP clock support registered
[    1.284364] FPGA manager framework
[    1.285022] PCI: Using ACPI for IRQ routing
[    1.287327] NET: Registered protocol family 23
[    1.288268] NET: Registered protocol family 8
[    1.289007] NET: Registered protocol family 20
[    1.290254] workqueue: round-robin CPU selection forced, expect performance impact
[    1.292152] nfc: nfc_init: NFC Core ver 0.1
[    1.292777] NET: Registered protocol family 39
[    1.293426] clocksource: Switched to clocksource kvm-clock
[    1.296984] Warning: could not register annotated branches stats
[    1.391851] VFS: Disk quotas dquot_6.6.0
[    1.393068] VFS: Dquot-cache hash table entries: 512 (order 0, 4096 bytes)
[    1.394983] FS-Cache: Loaded
[    1.396045] pnp: PnP ACPI init
[    1.399208] pnp: PnP ACPI: found 6 devices
[    1.405996] clocksource: acpi_pm: mask: 0xffffff max_cycles: 0xffffff, max_idle_ns: 2085701024 ns
[    1.408468] NET: Registered protocol family 2
[    1.410331] TCP established hash table entries: 32768 (order: 6, 262144 bytes)
[    1.414017] TCP bind hash table entries: 32768 (order: 9, 2621440 bytes)
[    1.420112] TCP: Hash tables configured (established 32768 bind 32768)
[    1.421844] UDP hash table entries: 2048 (order: 6, 393216 bytes)
[    1.423762] UDP-Lite hash table entries: 2048 (order: 6, 393216 bytes)
[    1.425991] NET: Registered protocol family 1
[    1.426607] pci 0000:00:00.0: Limiting direct PCI/PCI transfers
[    1.427322] pci 0000:00:01.0: PIIX3: Enabling Passive Release
[    1.428133] pci 0000:00:01.0: Activating ISA DMA hang workarounds
[    1.429067] pci 0000:00:02.0: Video device with shadowed ROM at [mem 0x000c0000-0x000dffff]
[    1.430833] PCI-DMA: Using software bounce buffering for IO (SWIOTLB)
[    1.431870] software IO TLB [mem 0xbbfe0000-0xbffe0000] (64MB) mapped at [ffff8800bbfe0000-ffff8800bffdffff]
[    1.438854] PCLMULQDQ-NI instructions are not detected.
[    1.440388] AVX or AES-NI instructions are not detected.
[    1.441280] CPU feature 'AVX registers' is not supported.
[    1.442202] CPU feature 'AVX registers' is not supported.
[    1.443207] CPU feature 'AVX registers' is not supported.
[    1.444305] AVX2 or AES-NI instructions are not detected.
[    1.445084] AVX2 instructions are not detected.
[    1.446201] spin_lock-torture:--- Start of test [debug]: nwriters_stress=2 nreaders_stress=0 stat_interval=60 verbose=1 shuffle_interval=3 stutter=5 shutdown_secs=0 onoff_interval=0 onoff_holdoff=0
[    1.448600] spin_lock-torture: Creating torture_shuffle task
[    1.449718] spin_lock-torture: Creating torture_stutter task
[    1.450804] spin_lock-torture: torture_shuffle task started
[    1.451889] spin_lock-torture: Creating lock_torture_writer task
[    1.453067] spin_lock-torture: torture_stutter task started
[    1.454101] spin_lock-torture: Creating lock_torture_writer task
[    1.455303] spin_lock-torture: lock_torture_writer task started
[    1.456411] spin_lock-torture: Creating lock_torture_stats task
[    1.457562] spin_lock-torture: lock_torture_writer task started
[    1.459599] torture_init_begin: Refusing rcu init: spin_lock running.
[    1.460778] torture_init_begin: One torture test at a time!
[    1.462735] futex hash table entries: 256 (order: 2, 24576 bytes)
[    1.463590] spin_lock-torture: lock_torture_stats task started
[    1.465416] workingset: timestamp_bits=62 max_order=20 bucket_order=0
[    1.482780] DLM installed
[    1.483211] jffs2: version 2.2. (NAND) © 2001-2006 Red Hat, Inc.
[    1.485312] fuse init (API version 7.26)
[    1.496648] NET: Registered protocol family 38
[    1.511207] test_hexdump: all 1184 tests passed
[    1.512371] test_firmware: interface ready
[    1.520837] test_hash: __hash_32() has no arch implementation to test.
[    1.522053] test_hash: hash_32() has no arch implementation to test.
[    1.523120] test_hash: hash_64() has no arch implementation to test.
[    1.524158] test_hash: 33152 tests passed.
[    1.524937] Running rhashtable test nelem=8, max_size=0, shrinking=0
[    1.526067] Test 00:
[    1.535628]   Adding 50000 keys
[    1.812656]   Traversal complete: counted=50000, nelems=50000, entries=50000, table-jumps=0
[    1.959787]   Traversal complete: counted=50000, nelems=50000, entries=50000, table-jumps=0
[    1.961259]   Deleting 50000 keys
[    2.066583]   Duration of test: 530340967 ns
[    2.069188] Test 01:
[    2.073715]   Adding 50000 keys
[    2.362563]   Traversal complete: counted=50000, nelems=50000, entries=50000, table-jumps=0
[    2.461584] tsc: Refined TSC clocksource calibration: 3066.637 MHz
[    2.462674] clocksource: tsc: mask: 0xffffffffffffffff max_cycles: 0x2c342af0056, max_idle_ns: 440795241274 ns
[    2.512604]   Traversal complete: counted=50000, nelems=50000, entries=50000, table-jumps=0
[    2.514056]   Deleting 50000 keys
[    2.617677]   Duration of test: 542516314 ns
[    2.620192] Test 02:
[    2.624106]   Adding 50000 keys
[    2.913672]   Traversal complete: counted=50000, nelems=50000, entries=50000, table-jumps=0
[    3.049063]   Traversal complete: counted=50000, nelems=50000, entries=50000, table-jumps=0
[    3.053005]   Deleting 50000 keys
[    3.163582]   Duration of test: 537947108 ns
[    3.165360] Test 03:
[    3.168682]   Adding 50000 keys
[    3.448304]   Traversal complete: counted=50000, nelems=50000, entries=50000, table-jumps=0
[    3.580376]   Traversal complete: counted=50000, nelems=50000, entries=50000, table-jumps=0
[    3.582470]   Deleting 50000 keys
[    3.686080]   Duration of test: 513522954 ns
[    3.687786] Average test time: 531081835
[    3.688677] Testing concurrent rhashtable access from 10 threads
[   14.586294] Started 10 threads, 0 failed
[   14.602467] test_printf: all 260 tests passed
[   14.672914] test_bitmap: all 460506 tests passed
[   14.674156] test_uuid: all 18 tests passed
[   14.676516] crc32: CRC_LE_BITS = 8, CRC_BE BITS = 8
[   14.677745] crc32: self tests passed, processed 225944 bytes in 615565 nsec
[   14.680004] crc32c: CRC_LE_BITS = 8
[   14.680934] crc32c: self tests passed, processed 225944 bytes in 278977 nsec
[   14.715243] crc32_combine: 8373 self tests passed
[   14.757929] crc32c_combine: 8373 self tests passed
[   14.759709] rbtree testing[   15.511564]  -> 23042 cycles
[   15.627994] augmented rbtree testing[   16.687697]  -> 32472 cycles
[   16.843107] gpio-mockup: probe of gpio-mockup failed with error -22
[   16.845452] pci_hotplug: PCI Hot Plug PCI Core version: 0.5
[   16.846901] cpcihp_zt5550: ZT5550 CompactPCI Hot Plug Driver version: 0.2
[   16.855701] acpiphp_ibm: ibm_acpiphp_init: acpi_walk_namespace failed
[   16.858087] cr_bllcd: INTEL CARILLO RANCH LPC not found.
[   16.859341] cr_bllcd: Carillo Ranch Backlight Driver Initialized.
[   16.862544] Could not find Carillo Ranch MCH device.
[   16.863949] no IO addresses supplied
[   16.865517] usbcore: registered new interface driver udlfb
[   16.866910] usbcore: registered new interface driver smscufx
[   16.869738] uvesafb: failed to execute /sbin/v86d
[   16.871062] uvesafb: make sure that the v86d helper is installed and executable
[   16.873019] uvesafb: Getting VBE info block failed (eax=0x4f00, err=-2)
[   16.874789] uvesafb: vbe_init() failed with -22
[   16.876082] uvesafb: probe of uvesafb.0 failed with error -22
[   16.878135] input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/input/input0
[   16.879919] ACPI: Power Button [PWRF]
[   16.881323] button: probe of LNXPWRBN:00 failed with error -22
[   16.883403] Warning: Processor Platform Limit event detected, but not handled.
[   16.886251] Consider compiling CPUfreq support into your kernel.
[   16.889546] EINJ: EINJ table not found.
[   16.891401] ERST DBG: ERST support is disabled.
[   16.957261] Serial: 8250/16550 driver, 4 ports, IRQ sharing enabled
[   16.988846] 00:05: ttyS0 at I/O 0x3f8 (irq = 4, base_baud = 115200) is a 16550A
[   16.992293] console [ttyS0] disabled
[    0.000000] Linux version 4.8.0-14894-g32ab0a38 (anielsen@lx-anielsen) (gcc version 5.2.0 (Gentoo 5.2.0 p1.3, pie-0.6.5) ) #2 PREEMPT Mon Nov 7 12:46:39 CET 2016
[    0.000000] Command line:
[    0.000000] x86/fpu: Legacy x87 FPU detected.
[    0.000000] x86/fpu: Using 'eager' FPU context switches.
[    0.000000] e820: BIOS-provided physical RAM map:
[    0.000000] BIOS-e820: [mem 0x0000000000000000-0x000000000009fbff] usable
[    0.000000] BIOS-e820: [mem 0x000000000009fc00-0x000000000009ffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000000f0000-0x00000000000fffff] reserved
[    0.000000] BIOS-e820: [mem 0x0000000000100000-0x00000000bffdffff] usable
[    0.000000] BIOS-e820: [mem 0x00000000bffe0000-0x00000000bfffffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000feffc000-0x00000000feffffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000fffc0000-0x00000000ffffffff] reserved
[    0.000000] BIOS-e820: [mem 0x0000000100000000-0x000000013fffffff] usable
[    0.000000] NX (Execute Disable) protection: active
[    0.000000] SMBIOS 2.8 present.
[    0.000000] Hypervisor detected: KVM
[    0.000000] e820: last_pfn = 0x140000 max_arch_pfn = 0x400000000
[    0.000000] x86/PAT: Configuration [0-7]: WB  WC  UC- UC  WB  WC  UC- WT
[    0.000000] e820: last_pfn = 0xbffe0 max_arch_pfn = 0x400000000
[    0.000000] ACPI: Early table checksum verification disabled
[    0.000000] ACPI: RSDP 0x00000000000F6970 000014 (v00 BOCHS )
[    0.000000] ACPI: RSDT 0x00000000BFFE1936 000030 (v01 BOCHS  BXPCRSDT 00000001 BXPC 00000001)
[    0.000000] ACPI: FACP 0x00000000BFFE180A 000074 (v01 BOCHS  BXPCFACP 00000001 BXPC 00000001)
[    0.000000] ACPI: DSDT 0x00000000BFFE0040 0017CA (v01 BOCHS  BXPCDSDT 00000001 BXPC 00000001)
[    0.000000] ACPI: FACS 0x00000000BFFE0000 000040
[    0.000000] ACPI: APIC 0x00000000BFFE187E 000080 (v01 BOCHS  BXPCAPIC 00000001 BXPC 00000001)
[    0.000000] ACPI: HPET 0x00000000BFFE18FE 000038 (v01 BOCHS  BXPCHPET 00000001 BXPC 00000001)
[    0.000000] kvm-clock: Using msrs 4b564d01 and 4b564d00
[    0.000000] kvm-clock: cpu 0, msr 1:3f800001, primary cpu clock
[    0.000000] kvm-clock: using sched offset of 692389337 cycles
[    0.000000] clocksource: kvm-clock: mask: 0xffffffffffffffff max_cycles: 0x1cd42e4dffb, max_idle_ns: 881590591483 ns
[    0.000000] Zone ranges:
[    0.000000]   DMA      [mem 0x0000000000001000-0x0000000000ffffff]
[    0.000000]   DMA32    [mem 0x0000000001000000-0x00000000ffffffff]
[    0.000000]   Normal   [mem 0x0000000100000000-0x000000013fffffff]
[    0.000000]   Device   empty
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x0000000000001000-0x000000000009efff]
[    0.000000]   node   0: [mem 0x0000000000100000-0x00000000bffdffff]
[    0.000000]   node   0: [mem 0x0000000100000000-0x000000013fffffff]
[    0.000000] Initmem setup node 0 [mem 0x0000000000001000-0x000000013fffffff]
[    0.000000] ACPI: PM-Timer IO Port: 0x608
[    0.000000] APIC: NR_CPUS/possible_cpus limit of 1 reached. Processor 1/0x1 ignored.
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0xff] dfl dfl lint[0x1])
[    0.000000] IOAPIC[0]: apic_id 0, version 17, address 0xfec00000, GSI 0-23
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 5 global_irq 5 high level)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 10 global_irq 10 high level)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 11 global_irq 11 high level)
[    0.000000] Using ACPI (MADT) for SMP configuration information
[    0.000000] ACPI: HPET id: 0x8086a201 base: 0xfed00000
[    0.000000] KVM setup async PF for cpu 0
[    0.000000] kvm-stealtime: cpu 0, msr 2835b80
[    0.000000] e820: [mem 0xc0000000-0xfeffbfff] available for PCI devices
[    0.000000] Booting paravirtualized kernel on KVM
[    0.000000] clocksource: refined-jiffies: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 1910969940391419 ns
[    0.000000] Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 1032041
[    0.000000] Kernel command line:
[    0.000000] PID hash table entries: 4096 (order: 3, 32768 bytes)
[    0.000000] Dentry cache hash table entries: 524288 (order: 10, 4194304 bytes)
[    0.000000] Inode-cache hash table entries: 262144 (order: 9, 2097152 bytes)
[    0.000000] Memory: 3984728K/4193784K available (14427K kernel code, 5328K rwdata, 6352K rodata, 1188K init, 30876K bss, 209056K reserved, 0K cma-reserved)
[    0.000000] SLUB: HWalign=64, Order=0-3, MinObjects=0, CPUs=1, Nodes=1
[    0.000000] Running RCU self tests
[    0.000000] Preemptible hierarchical RCU implementation.
[    0.000000]  RCU debugfs-based tracing is enabled.
[    0.000000]  RCU lockdep checking is enabled.
[    0.000000]  Build-time adjustment of leaf fanout to 64.
[    0.000000] NR_IRQS:4352 nr_irqs:48 16
[    0.000000] console [ttyS0] enabled
[    0.000000] Lock dependency validator: Copyright (c) 2006 Red Hat, Inc., Ingo Molnar
[    0.000000] ... MAX_LOCKDEP_SUBCLASSES:  8
[    0.000000] ... MAX_LOCK_DEPTH:          48
[    0.000000] ... MAX_LOCKDEP_KEYS:        8191
[    0.000000] ... CLASSHASH_SIZE:          4096
[    0.000000] ... MAX_LOCKDEP_ENTRIES:     32768
[    0.000000] ... MAX_LOCKDEP_CHAINS:      65536
[    0.000000] ... CHAINHASH_SIZE:          32768
[    0.000000]  memory used by lock dependency info: 8671 kB
[    0.000000]  per task-struct memory footprint: 2688 bytes
[    0.000000] ODEBUG: selftest passed
[    0.000000] clocksource: hpet: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 19112604467 ns
[    0.000000] tsc: Detected 3066.410 MHz processor
[    0.948122] Calibrating delay loop (skipped) preset value.. 6132.82 BogoMIPS (lpj=3066410)
[    0.952806] pid_max: default: 32768 minimum: 301
[    0.953604] ACPI: Core revision 20160831
[    0.964638] ACPI: 1 ACPI AML tables successfully acquired and loaded

[    0.965934] Mount-cache hash table entries: 8192 (order: 4, 65536 bytes)
[    0.966955] Mountpoint-cache hash table entries: 8192 (order: 4, 65536 bytes)
[    0.972807] Last level iTLB entries: 4KB 0, 2MB 0, 4MB 0
[    0.973632] Last level dTLB entries: 4KB 0, 2MB 0, 4MB 0, 1GB 0
[    0.974529] CPU: Intel(R) Xeon(R) CPU           W3550  @ 3.07GHz (family: 0x6, model: 0x1a, stepping: 0x5)
[    0.981250] Performance Events: Nehalem events, Intel PMU driver.
[    0.982250] core: CPUID marked event: 'bus cycles' unavailable
[    0.983009] ... version:                2
[    0.983583] ... bit width:              48
[    0.984210] ... generic registers:      4
[    0.984773] ... value mask:             0000ffffffffffff
[    0.985488] ... max period:             000000007fffffff
[    0.986155] ... fixed-purpose events:   3
[    0.986755] ... event mask:             000000070000000f
[    0.993590] ..TIMER: vector=0x30 apic1=0 pin1=2 apic2=-1 pin2=-1
[    0.995703] devtmpfs: initialized
[    0.997029] x86/mm: Memory block size: 128MB
[    1.005124] clocksource: jiffies: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 1911260446275000 ns
[    1.007597] atomic64_test: passed for x86-64 platform with CX8 and with SSE
[    1.009212] pinctrl core: initialized pinctrl subsystem
[    1.011590] regulator-dummy: Failed to create debugfs directory
[    1.014001] NET: Registered protocol family 16
[    1.019160] cpuidle: using governor menu
[    1.020365] ACPI: bus type PCI registered
[    1.021235] acpiphp: ACPI Hot Plug PCI Controller Driver version: 0.5
[    1.023109] PCI: Using configuration type 1 for base access
[    1.088601] HugeTLB registered 2 MB page size, pre-allocated 0 pages
[    1.091587] ACPI: Added _OSI(Module Device)
[    1.092663] ACPI: Added _OSI(Processor Device)
[    1.093750] ACPI: Added _OSI(3.0 _SCP Extensions)
[    1.095464] ACPI: Added _OSI(Processor Aggregator Device)
[    1.105794] ACPI: Interpreter enabled
[    1.106733] ACPI: (supports S0 S5)
[    1.107399] ACPI: Using IOAPIC for interrupt routing
[    1.108470] PCI: Using host bridge windows from ACPI; if necessary, use "pci=nocrs" and report a bug
[    1.141812] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-ff])
[    1.146491] acpi PNP0A03:00: _OSC: OS supports [Segments]
[    1.147642] acpi PNP0A03:00: _OSC failed (AE_NOT_FOUND); disabling ASPM
[    1.149079] acpi PNP0A03:00: fail to add MMCONFIG information, can't access extended PCI configuration space under this bridge.
[    1.152629] acpiphp: Slot [3] registered
[    1.153838] acpiphp: Slot [4] registered
[    1.154901] acpiphp: Slot [5] registered
[    1.155968] acpiphp: Slot [6] registered
[    1.157017] acpiphp: Slot [7] registered
[    1.158105] acpiphp: Slot [8] registered
[    1.159184] acpiphp: Slot [9] registered
[    1.160255] acpiphp: Slot [10] registered
[    1.161367] acpiphp: Slot [11] registered
[    1.162445] acpiphp: Slot [12] registered
[    1.163563] acpiphp: Slot [13] registered
[    1.164672] acpiphp: Slot [14] registered
[    1.165759] acpiphp: Slot [15] registered
[    1.166887] acpiphp: Slot [16] registered
[    1.167954] acpiphp: Slot [17] registered
[    1.169029] acpiphp: Slot [18] registered
[    1.170168] acpiphp: Slot [19] registered
[    1.171271] acpiphp: Slot [20] registered
[    1.172409] acpiphp: Slot [21] registered
[    1.173479] acpiphp: Slot [22] registered
[    1.174602] acpiphp: Slot [23] registered
[    1.175698] acpiphp: Slot [24] registered
[    1.176770] acpiphp: Slot [25] registered
[    1.177850] acpiphp: Slot [26] registered
[    1.178963] acpiphp: Slot [27] registered
[    1.180035] acpiphp: Slot [28] registered
[    1.181146] acpiphp: Slot [29] registered
[    1.182244] acpiphp: Slot [30] registered
[    1.183350] acpiphp: Slot [31] registered
[    1.184327] PCI host bridge to bus 0000:00
[    1.185234] pci_bus 0000:00: root bus resource [io  0x0000-0x0cf7 window]
[    1.186748] pci_bus 0000:00: root bus resource [io  0x0d00-0xffff window]
[    1.188300] pci_bus 0000:00: root bus resource [mem 0x000a0000-0x000bffff window]
[    1.190028] pci_bus 0000:00: root bus resource [mem 0xc0000000-0xfebfffff window]
[    1.191743] pci_bus 0000:00: root bus resource [bus 00-ff]
[    1.202185] pci 0000:00:01.1: legacy IDE quirk: reg 0x10: [io  0x01f0-0x01f7]
[    1.203949] pci 0000:00:01.1: legacy IDE quirk: reg 0x14: [io  0x03f6]
[    1.205290] pci 0000:00:01.1: legacy IDE quirk: reg 0x18: [io  0x0170-0x0177]
[    1.207154] pci 0000:00:01.1: legacy IDE quirk: reg 0x1c: [io  0x0376]
[    1.210147] pci 0000:00:01.3: quirk: [io  0x0600-0x063f] claimed by PIIX4 ACPI
[    1.211960] pci 0000:00:01.3: quirk: [io  0x0700-0x070f] claimed by PIIX4 SMB
[    1.257524] ACPI: PCI Interrupt Link [LNKA] (IRQs 5 *10 11)
[    1.259689] ACPI: PCI Interrupt Link [LNKB] (IRQs 5 *10 11)
[    1.261736] ACPI: PCI Interrupt Link [LNKC] (IRQs 5 10 *11)
[    1.263829] ACPI: PCI Interrupt Link [LNKD] (IRQs 5 10 *11)
[    1.265683] ACPI: PCI Interrupt Link [LNKS] (IRQs *9)
[    1.270430] vgaarb: setting as boot device: PCI:0000:00:02.0
[    1.271834] vgaarb: device added: PCI:0000:00:02.0,decodes=io+mem,owns=io+mem,locks=none
[    1.273531] vgaarb: loaded
[    1.273967] vgaarb: bridge control possible 0000:00:02.0
[    1.276309] ACPI: bus type USB registered
[    1.277249] usbcore: registered new interface driver usbfs
[    1.278246] usbcore: registered new interface driver hub
[    1.279264] usbcore: registered new device driver usb
[    1.280509] pps_core: LinuxPPS API ver. 1 registered
[    1.281371] pps_core: Software ver. 5.3.6 - Copyright 2005-2007 Rodolfo Giometti <giometti@linux.it>
[    1.282949] PTP clock support registered
[    1.284364] FPGA manager framework
[    1.285022] PCI: Using ACPI for IRQ routing
[    1.287327] NET: Registered protocol family 23
[    1.288268] NET: Registered protocol family 8
[    1.289007] NET: Registered protocol family 20
[    1.290254] workqueue: round-robin CPU selection forced, expect performance impact
[    1.292152] nfc: nfc_init: NFC Core ver 0.1
[    1.292777] NET: Registered protocol family 39
[    1.293426] clocksource: Switched to clocksource kvm-clock
[    1.296984] Warning: could not register annotated branches stats
[    1.391851] VFS: Disk quotas dquot_6.6.0
[    1.393068] VFS: Dquot-cache hash table entries: 512 (order 0, 4096 bytes)
[    1.394983] FS-Cache: Loaded
[    1.396045] pnp: PnP ACPI init
[    1.399208] pnp: PnP ACPI: found 6 devices
[    1.405996] clocksource: acpi_pm: mask: 0xffffff max_cycles: 0xffffff, max_idle_ns: 2085701024 ns
[    1.408468] NET: Registered protocol family 2
[    1.410331] TCP established hash table entries: 32768 (order: 6, 262144 bytes)
[    1.414017] TCP bind hash table entries: 32768 (order: 9, 2621440 bytes)
[    1.420112] TCP: Hash tables configured (established 32768 bind 32768)
[    1.421844] UDP hash table entries: 2048 (order: 6, 393216 bytes)
[    1.423762] UDP-Lite hash table entries: 2048 (order: 6, 393216 bytes)
[    1.425991] NET: Registered protocol family 1
[    1.426607] pci 0000:00:00.0: Limiting direct PCI/PCI transfers
[    1.427322] pci 0000:00:01.0: PIIX3: Enabling Passive Release
[    1.428133] pci 0000:00:01.0: Activating ISA DMA hang workarounds
[    1.429067] pci 0000:00:02.0: Video device with shadowed ROM at [mem 0x000c0000-0x000dffff]
[    1.430833] PCI-DMA: Using software bounce buffering for IO (SWIOTLB)
[    1.431870] software IO TLB [mem 0xbbfe0000-0xbffe0000] (64MB) mapped at [ffff8800bbfe0000-ffff8800bffdffff]
[    1.438854] PCLMULQDQ-NI instructions are not detected.
[    1.440388] AVX or AES-NI instructions are not detected.
[    1.441280] CPU feature 'AVX registers' is not supported.
[    1.442202] CPU feature 'AVX registers' is not supported.
[    1.443207] CPU feature 'AVX registers' is not supported.
[    1.444305] AVX2 or AES-NI instructions are not detected.
[    1.445084] AVX2 instructions are not detected.
[    1.446201] spin_lock-torture:--- Start of test [debug]: nwriters_stress=2 nreaders_stress=0 stat_interval=60 verbose=1 shuffle_interval=3 stutter=5 shutdown_secs=0 onoff_interval=0 onoff_holdoff=0
[    1.448600] spin_lock-torture: Creating torture_shuffle task
[    1.449718] spin_lock-torture: Creating torture_stutter task
[    1.450804] spin_lock-torture: torture_shuffle task started
[    1.451889] spin_lock-torture: Creating lock_torture_writer task
[    1.453067] spin_lock-torture: torture_stutter task started
[    1.454101] spin_lock-torture: Creating lock_torture_writer task
[    1.455303] spin_lock-torture: lock_torture_writer task started
[    1.456411] spin_lock-torture: Creating lock_torture_stats task
[    1.457562] spin_lock-torture: lock_torture_writer task started
[    1.459599] torture_init_begin: Refusing rcu init: spin_lock running.
[    1.460778] torture_init_begin: One torture test at a time!
[    1.462735] futex hash table entries: 256 (order: 2, 24576 bytes)
[    1.463590] spin_lock-torture: lock_torture_stats task started
[    1.465416] workingset: timestamp_bits=62 max_order=20 bucket_order=0
[    1.482780] DLM installed
[    1.483211] jffs2: version 2.2. (NAND) © 2001-2006 Red Hat, Inc.
[    1.485312] fuse init (API version 7.26)
[    1.496648] NET: Registered protocol family 38
[    1.511207] test_hexdump: all 1184 tests passed
[    1.512371] test_firmware: interface ready
[    1.520837] test_hash: __hash_32() has no arch implementation to test.
[    1.522053] test_hash: hash_32() has no arch implementation to test.
[    1.523120] test_hash: hash_64() has no arch implementation to test.
[    1.524158] test_hash: 33152 tests passed.
[    1.524937] Running rhashtable test nelem=8, max_size=0, shrinking=0
[    1.526067] Test 00:
[    1.535628]   Adding 50000 keys
[    1.812656]   Traversal complete: counted=50000, nelems=50000, entries=50000, table-jumps=0
[    1.959787]   Traversal complete: counted=50000, nelems=50000, entries=50000, table-jumps=0
[    1.961259]   Deleting 50000 keys
[    2.066583]   Duration of test: 530340967 ns
[    2.069188] Test 01:
[    2.073715]   Adding 50000 keys
[    2.362563]   Traversal complete: counted=50000, nelems=50000, entries=50000, table-jumps=0
[    2.461584] tsc: Refined TSC clocksource calibration: 3066.637 MHz
[    2.462674] clocksource: tsc: mask: 0xffffffffffffffff max_cycles: 0x2c342af0056, max_idle_ns: 440795241274 ns
[    2.512604]   Traversal complete: counted=50000, nelems=50000, entries=50000, table-jumps=0
[    2.514056]   Deleting 50000 keys
[    2.617677]   Duration of test: 542516314 ns
[    2.620192] Test 02:
[    2.624106]   Adding 50000 keys
[    2.913672]   Traversal complete: counted=50000, nelems=50000, entries=50000, table-jumps=0
[    3.049063]   Traversal complete: counted=50000, nelems=50000, entries=50000, table-jumps=0
[    3.053005]   Deleting 50000 keys
[    3.163582]   Duration of test: 537947108 ns
[    3.165360] Test 03:
[    3.168682]   Adding 50000 keys
[    3.448304]   Traversal complete: counted=50000, nelems=50000, entries=50000, table-jumps=0
[    3.580376]   Traversal complete: counted=50000, nelems=50000, entries=50000, table-jumps=0
[    3.582470]   Deleting 50000 keys
[    3.686080]   Duration of test: 513522954 ns
[    3.687786] Average test time: 531081835
[    3.688677] Testing concurrent rhashtable access from 10 threads
[   14.586294] Started 10 threads, 0 failed
[   14.602467] test_printf: all 260 tests passed
[   14.672914] test_bitmap: all 460506 tests passed
[   14.674156] test_uuid: all 18 tests passed
[   14.676516] crc32: CRC_LE_BITS = 8, CRC_BE BITS = 8
[   14.677745] crc32: self tests passed, processed 225944 bytes in 615565 nsec
[   14.680004] crc32c: CRC_LE_BITS = 8
[   14.680934] crc32c: self tests passed, processed 225944 bytes in 278977 nsec
[   14.715243] crc32_combine: 8373 self tests passed
[   14.757929] crc32c_combine: 8373 self tests passed
[   14.759709] rbtree testing
[   15.511564]  -> 23042 cycles
[   15.627994] augmented rbtree testing
[   16.687697]  -> 32472 cycles
[   16.843107] gpio-mockup: probe of gpio-mockup failed with error -22
[   16.845452] pci_hotplug: PCI Hot Plug PCI Core version: 0.5
[   16.846901] cpcihp_zt5550: ZT5550 CompactPCI Hot Plug Driver version: 0.2
[   16.855701] acpiphp_ibm: ibm_acpiphp_init: acpi_walk_namespace failed
[   16.858087] cr_bllcd: INTEL CARILLO RANCH LPC not found.
[   16.859341] cr_bllcd: Carillo Ranch Backlight Driver Initialized.
[   16.862544] Could not find Carillo Ranch MCH device.
[   16.863949] no IO addresses supplied
[   16.865517] usbcore: registered new interface driver udlfb
[   16.866910] usbcore: registered new interface driver smscufx
[   16.869738] uvesafb: failed to execute /sbin/v86d
[   16.871062] uvesafb: make sure that the v86d helper is installed and executable
[   16.873019] uvesafb: Getting VBE info block failed (eax=0x4f00, err=-2)
[   16.874789] uvesafb: vbe_init() failed with -22
[   16.876082] uvesafb: probe of uvesafb.0 failed with error -22
[   16.878135] input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/input/input0
[   16.879919] ACPI: Power Button [PWRF]
[   16.881323] button: probe of LNXPWRBN:00 failed with error -22
[   16.883403] Warning: Processor Platform Limit event detected, but not handled.
[   16.886251] Consider compiling CPUfreq support into your kernel.
[   16.889546] EINJ: EINJ table not found.
[   16.891401] ERST DBG: ERST support is disabled.
[   16.957261] Serial: 8250/16550 driver, 4 ports, IRQ sharing enabled
[   16.988846] 00:05: ttyS0 at I/O 0x3f8 (irq = 4, base_baud = 115200) is a 16550A
[   16.992293] console [ttyS0] disabled
[   17.021709] 00:05: ttyS0 at I/O 0x3f8 (irq = 4, base_baud = 115200) is a 16550A
[   17.400058] console [ttyS0] enabled
[   17.406735] Initializing Nozomi driver 2.1d
[   17.407990] Applicom driver: $Id: ac.c,v 1.30 2000/03/22 16:03:57 dwmw2 Exp $
[   17.409368] ac.o: No PCI boards found.
[   17.410105] ac.o: For an ISA board you must supply memory and irq parameters.
[   17.411642] Non-volatile memory driver v1.3
[   17.412760] smapi::smapi_init, ERROR invalid usSmapiID
[   17.413774] mwave: tp3780i::tp3780I_InitializeBoardData: Error: SMAPI is not available on this machine
[   17.415579] mwave: mwavedd::mwave_init: Error: Failed to initialize board data
[   17.416931] mwave: mwavedd::mwave_init: Error: Failed to initialize
[   17.418138] Linux agpgart interface v0.103
[   17.419834] Hangcheck: starting hangcheck timer 0.9.1 (tick is 180 seconds, margin is 60 seconds).
[   17.422093] intelfb: Framebuffer driver for Intel(R) 830M/845G/852GM/855GM/865G/915G/915GM/945G/945GM/945GME/965G/965GM chipsets
[   17.424258] intelfb: Version 0.9.6
[   17.425571] ibmasm: IBM ASM Service Processor Driver version 1.0 loaded
[   17.426939] dummy-irq: no IRQ given.  Use irq=N
[   17.428073] Phantom Linux Driver, version n0.9.8, init OK
[   17.429397] Silicon Labs C2 port support v. 0.51.0 - (C) 2007 Rodolfo Giometti
[   17.431062] c2port c2port0: C2 port uc added
[   17.431779] c2port c2port0: uc flash has 30 blocks x 512 bytes (15360 bytes total)
[   17.435470] usbcore: registered new interface driver viperboard
[   17.436664] usbcore: registered new interface driver dln2
[   17.438093] usbcore: registered new interface driver nfcmrvl
[   17.439799] mtdoops: mtd device (mtddev=name/number) must be supplied
[   17.441117] SBC-GXx flash: IO:0x258-0x259 MEM:0xdc000-0xdffff
[   17.442678] slram: not enough parameters.
[   17.473915] No valid DiskOnChip devices found
[   17.475152] [nandsim] warning: read_byte: unexpected data output cycle, state is STATE_READY return 0x0
[   17.477472] [nandsim] warning: read_byte: unexpected data output cycle, state is STATE_READY return 0x0
[   17.479725] [nandsim] warning: read_byte: unexpected data output cycle, state is STATE_READY return 0x0
[   17.482089] [nandsim] warning: read_byte: unexpected data output cycle, state is STATE_READY return 0x0
[   17.484330] [nandsim] warning: read_byte: unexpected data output cycle, state is STATE_READY return 0x0
[   17.486608] [nandsim] warning: read_byte: unexpected data output cycle, state is STATE_READY return 0x0
[   17.492094] nand: device found, Manufacturer ID: 0x98, Chip ID: 0x39
[   17.493472] nand: Toshiba NAND 128MiB 1,8V 8-bit
[   17.494522] nand: 128 MiB, SLC, erase size: 16 KiB, page size: 512, OOB size: 16
[   17.496342] flash size: 128 MiB
[   17.497161] page size: 512 bytes
[   17.497911] OOB area size: 16 bytes
[   17.498737] sector size: 16 KiB
[   17.499401] pages number: 262144
[   17.500167] pages per sector: 32
[   17.500946] bus width: 8
[   17.501553] bits in sector size: 14
[   17.502358] bits in page size: 9
[   17.503130] bits in OOB size: 4
[   17.503896] flash size with OOB: 135168 KiB
[   17.504920] page address bytes: 4
[   17.505693] sector address bytes: 3
[   17.506503] options: 0x42
[   17.509790] Scanning device for bad blocks
[   17.554369] Creating 1 MTD partitions on "NAND 128MiB 1,8V 8-bit":
[   17.555933] 0x000000000000-0x000008000000 : "NAND simulator partition 0"
[   17.572412] Ethernet Channel Bonding Driver: v3.7.1 (April 27, 2011)
[   17.577002] MACsec IEEE 802.1AE
[   17.582419] libphy: mdio_driver_register: xgmiitorgmii
[   17.583759] tun: Universal TUN/TAP device driver, 1.6
[   17.584963] tun: (C) 1999-2004 Max Krasnyansky <maxk@qualcomm.com>
[   17.586683] arcnet: arcnet loaded
[   17.587551] arcnet:rfc1201: RFC1201 "standard" (`a') encapsulation support loaded
[   17.589409] arcnet:rfc1051: RFC1051 "simple standard" (`s') encapsulation support loaded
[   17.591417] arcnet:arc_rawmode: raw mode (`r') encapsulation support loaded
[   17.593177] arcnet:capmode: cap mode (`c') encapsulation support loaded
[   17.594729] arcnet:com90xx: COM90xx chipset support
[   17.901810] S3: No ARCnet cards found.
[   17.902837] arcnet:com20020_pci: COM20020 PCI support
[   17.904645] libphy: mdio_driver_register: bcm53xx
[   17.906104] libphy: mdio_driver_register: mv88e6085
[   17.907489] e1000: Intel(R) PRO/1000 Network Driver - version 7.3.21-k8-NAPI
[   17.909444] e1000: Copyright (c) 1999-2006 Intel Corporation.
[   18.359616] ACPI: PCI Interrupt Link [LNKC] enabled at IRQ 11
[   18.722288] e1000 0000:00:03.0 eth0: (PCI:33MHz:32-bit) 52:54:00:12:34:56
[   18.723665] e1000 0000:00:03.0 eth0: Intel(R) PRO/1000 Network Connection
[   20.048137] e1000 0000:00:03.0 eth0: (PCI:33MHz:32-bit) 52:54:00:12:34:56
[   20.049933] e1000 0000:00:03.0 eth0: Intel(R) PRO/1000 Network Connection
[   20.051733] e1000e: Intel(R) PRO/1000 Network Driver - 3.2.6-k
[   20.053165] e1000e: Copyright(c) 1999 - 2015 Intel Corporation.
[   20.054750] igb: Intel(R) Gigabit Ethernet Network Driver - version 5.4.0-k
[   20.056584] igb: Copyright (c) 2007-2014 Intel Corporation.
[   20.058092] ixgbe: Intel(R) 10 Gigabit PCI Express Network Driver - version 4.4.0-k
[   20.060085] ixgbe: Copyright (c) 1999-2016 Intel Corporation.
[   20.062183] usbcore: registered new interface driver irda-usb
[   20.063781] usbcore: registered new interface driver stir4200
[   20.066916] usbcore: registered new interface driver mcs7780
[   20.068693] usbcore: registered new interface driver ks959-sir
[   20.070200] PPP generic driver version 2.4.2
[   20.071696] PPP BSD Compression module registered
[   20.072933] PPP Deflate Compression module registered
[   20.074243] PPP MPPE Compression module registered
[   20.075504] NET: Registered protocol family 24
[   20.076732] ipw2100: Intel(R) PRO/Wireless 2100 Network Driver, git-1.2.2
[   20.078480] ipw2100: Copyright(c) 2003-2006 Intel Corporation
[   20.080138] ipw2200: Intel(R) PRO/Wireless 2200/2915 Network Driver, 1.2.2kd
[   20.081977] ipw2200: Copyright(c) 2003-2006 Intel Corporation
[   20.083517] libipw: 802.11 data/management/control stack, git-1.1.13
[   20.085051] libipw: Copyright (C) 2004-2005 Intel Corporation <jketreno@linux.intel.com>
[   20.086932] iwl4965: Intel(R) Wireless WiFi 4965 driver for Linux, in-tree:d
[   20.088702] iwl4965: Copyright(c) 2003-2011 Intel Corporation
[   20.090335] iwl3945: Intel(R) PRO/Wireless 3945ABG/BG Network Connection driver for Linux, in-tree:ds
[   20.092706] iwl3945: Copyright(c) 2003-2011 Intel Corporation
[   20.094334] Intel(R) Wireless WiFi driver for Linux
[   20.095605] Copyright(c) 2003- 2015 Intel Corporation
[   20.097344] usbcore: registered new interface driver rt2500usb
[   20.098929] usbcore: registered new interface driver rt2800usb
[   20.100495] usbcore: registered new interface driver rtl8187
[   20.101898] usbcore: registered new interface driver rtl8192cu
[   20.103842] usbcore: registered new interface driver rtl8xxxu
[   20.105528] usbcore: registered new interface driver RSI-USB WLAN
[   20.107146] usbcore: registered new interface driver zd1201
[   20.108824] usbcore: registered new interface driver rndis_wlan
[   20.110489] mac80211_hwsim: initializing netlink
[   20.117683] usbcore: registered new interface driver i2400m_usb
[   20.119271] usbcore: registered new interface driver kaweth
[   20.120660] usbcore: registered new interface driver rtl8150
[   20.122080] usbcore: registered new interface driver r8152
[   20.123486] usbcore: registered new interface driver lan78xx
[   20.124912] usbcore: registered new interface driver ax88179_178a
[   20.126526] usbcore: registered new interface driver cdc_ether
[   20.127961] usbcore: registered new interface driver cdc_eem
[   20.129523] usbcore: registered new interface driver CoreChips
[   20.131084] usbcore: registered new interface driver smsc75xx
[   20.132689] usbcore: registered new interface driver smsc95xx
[   20.134236] usbcore: registered new interface driver net1080
[   20.135761] usbcore: registered new interface driver plusb
[   20.137281] usbcore: registered new interface driver rndis_host
[   20.138843] usbcore: registered new interface driver zaurus
[   20.140341] usbcore: registered new interface driver MOSCHIP usb-ethernet driver
[   20.142292] usbcore: registered new interface driver int51x1
[   20.143810] usbcore: registered new interface driver kalmia
[   20.145320] usbcore: registered new interface driver ipheth
[   20.146834] usbcore: registered new interface driver cdc_ncm
[   20.148342] usbcore: registered new interface driver huawei_cdc_ncm
[   20.150015] usbcore: registered new interface driver lg-vl600
[   20.151589] usbcore: registered new interface driver qmi_wwan
[   20.153152] usbcore: registered new interface driver ch9200
[   20.154607] FUJITSU Extended Socket Network Device Driver - version 1.2 - Copyright (c) 2015 FUJITSU LIMITED
[   20.157471] Madge ATM Horizon [Ultra] driver version 1.2.1
[   20.158743] hrz: debug bitmap is 0
[   20.159722] idt77252_init: at ffffffff82d87285
[   20.160973] Solos PCI Driver Version 1.04
[   20.163689] usbcore: registered new interface driver hwa-rc
[   20.165208] usbcore: registered new interface driver i1480-dfu-usb
[   20.167800] uhci_hcd: USB Universal Host Controller Interface driver
[   20.169799] driver u132_hcd
[   20.170871] usbcore: registered new interface driver hwa-hc
[   20.172633] usbcore: registered new interface driver cdc_acm
[   20.174110] cdc_acm: USB Abstract Control Model driver for USB modems and ISDN adapters
[   20.176212] usbcore: registered new interface driver cdc_wdm
[   20.177777] usbcore: registered new interface driver mdc800
[   20.179097] mdc800: v0.7.5 (30/10/2000):USB Driver for Mustek MDC800 Digital Camera
[   20.180973] usbcore: registered new interface driver adutux
[   20.182510] usbcore: registered new interface driver appledisplay
[   20.184143] usbcore: registered new interface driver emi26 - firmware loader
[   20.186045] usbcore: registered new interface driver emi62 - firmware loader
[   20.187879] ftdi_elan: driver ftdi-elan
[   20.188937] usbcore: registered new interface driver ftdi-elan
[   20.190526] usbcore: registered new interface driver idmouse
[   20.192060] usbcore: registered new interface driver iowarrior
[   20.193645] usbcore: registered new interface driver isight_firmware
[   20.195317] usbcore: registered new interface driver usblcd
[   20.196711] usbcore: registered new interface driver usbtest
[   20.198110] usbcore: registered new interface driver trancevibrator
[   20.199800] usbcore: registered new interface driver usbsevseg
[   20.201373] usbcore: registered new interface driver yurex
[   20.203052] usbcore: registered new interface driver chaoskey
[   20.204026] usbcore: registered new interface driver sisusb
[   20.205067] dummy_hcd dummy_hcd.0: USB Host+Gadget Emulator, driver 02 May 2005
[   20.206145] dummy_hcd dummy_hcd.0: Dummy host controller
[   20.207168] dummy_hcd dummy_hcd.0: new USB bus registered, assigned bus number 1
[   20.209781] hub 1-0:1.0: USB hub found
[   20.210621] hub 1-0:1.0: 1 port detected
[   20.211841] hub 1-0:1.0: USB hub found
[   20.212572] hub 1-0:1.0: 1 port detected
[   20.214726] hub 1-0:1.0: USB hub found
[   20.215523] hub 1-0:1.0: 1 port detected
[   20.216568] hub 1-0:1.0: USB hub found
[   20.217249] hub 1-0:1.0: 1 port detected
[   20.218315] dummy_hcd dummy_hcd.0: remove, state 1
[   20.219245] usb usb1: USB disconnect, device number 1
[   20.221859] dummy_hcd dummy_hcd.0: stopped
[   20.222698] dummy_hcd dummy_hcd.0: USB bus 1 deregistered
[   20.224374] dummy_hcd dummy_hcd.0: USB Host+Gadget Emulator, driver 02 May 2005
[   20.225791] dummy_hcd dummy_hcd.0: Dummy host controller
[   20.227055] dummy_hcd dummy_hcd.0: new USB bus registered, assigned bus number 1
[   20.229504] hub 1-0:1.0: USB hub found
[   20.230273] hub 1-0:1.0: 1 port detected
[   20.231322] hub 1-0:1.0: USB hub found
[   20.232108] hub 1-0:1.0: 1 port detected
[   20.233717] hub 1-0:1.0: USB hub found
[   20.234515] hub 1-0:1.0: 1 port detected
[   20.235551] hub 1-0:1.0: USB hub found
[   20.236284] hub 1-0:1.0: 1 port detected
[   20.238731] kobject (ffff880139f64f78): tried to init an initialized object, something is seriously wrong.
[   20.240375] CPU: 0 PID: 1 Comm: swapper Not tainted 4.8.0-14894-g32ab0a38 #2
[   20.241586] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS rel-1.9.3-0-ge2fc41e-prebuilt.qemu-project.org 04/01/2014
[   20.245481]  ffff88013a8f3ba0 ffffffff812cf3c2 ffff88013a8f3bc0 ffffffff812d1719
[   20.246952]  ffff880139f64f68 ffff880139f64ed8 ffff88013a8f3bd8 ffffffff81453f4f
[   20.248460]  ffff880139f64f68 ffff88013a8f3bf0 ffffffff814547a5 ffff8801390e7c00
[   20.249961] Call Trace:
[   20.250486]  [<ffffffff812cf3c2>] dump_stack+0x19/0x1b
[   20.251428]  [<ffffffff812d1719>] kobject_init+0x31/0x7f
[   20.252444]  [<ffffffff81453f4f>] device_initialize+0x23/0xd2
[   20.253580]  [<ffffffff814547a5>] device_register+0xd/0x18
[   20.254626]  [<ffffffff8188ad4b>] usb_add_gadget_udc_release+0xc5/0x2c9
[   20.255752]  [<ffffffff8188afc8>] usb_add_gadget_udc+0xb/0xd
[   20.256718]  [<ffffffff8188dd59>] dummy_udc_probe+0x19e/0x1df
[   20.257719]  [<ffffffff814590da>] platform_drv_probe+0x23/0x4e
[   20.258710]  [<ffffffff81457daa>] driver_probe_device+0x1d6/0x407
[   20.259805]  [<ffffffff81458153>] __device_attach_driver+0x90/0xd0
[   20.260982]  [<ffffffff814580c3>] ? driver_allows_async_probing+0xd/0xd
[   20.262242]  [<ffffffff81456623>] bus_for_each_drv+0x7a/0x84
[   20.263307]  [<ffffffff81457aae>] __device_attach+0x89/0xe7
[   20.264352]  [<ffffffff814582a3>] device_initial_probe+0xe/0x10
[   20.265496]  [<ffffffff814567de>] bus_probe_device+0x2e/0x99
[   20.266560]  [<ffffffff814546a2>] device_add+0x3f0/0x4e6
[   20.267588]  [<ffffffff814596f6>] platform_device_add+0x16d/0x1c6
[   20.268768]  [<ffffffff82d89e70>] init+0x264/0x366
[   20.269702]  [<ffffffff82d89c0c>] ? trace_event_define_fields_udc_log_req+0x205/0x205
[   20.271159]  [<ffffffff82d3706c>] do_one_initcall+0x88/0x145
[   20.272216]  [<ffffffff82d37243>] kernel_init_freeable+0x11a/0x19b
[   20.273305]  [<ffffffff81e03c65>] ? rest_init+0x12c/0x12c
[   20.274244]  [<ffffffff81e03c6e>] kernel_init+0x9/0xeb
[   20.275124]  [<ffffffff81e142ca>] ret_from_fork+0x2a/0x40
[   20.277393] using random self ethernet address
[   20.278274] using random host ethernet address
[   20.280161] usb0: HOST MAC 7e:16:00:29:cc:08
[   20.281125] usb0: MAC d2:ad:92:79:e2:71
[   20.281920] g_ether gadget: Ethernet Gadget, version: Memorial Day 2008
[   20.283156] g_ether gadget: g_ether ready
[   20.283960] usbip_core: USB/IP Core v1.0.0
[   20.285287] vhci_hcd vhci_hcd: USB/IP Virtual Host Controller
[   20.286717] vhci_hcd vhci_hcd: new USB bus registered, assigned bus number 2
[   20.288114] BUG: key ffff8801398d7198 not in .data!
[   20.289039] ------------[ cut here ]------------
[   20.289955] WARNING: CPU: 0 PID: 1 at ../kernel/locking/lockdep.c:3131 lockdep_init_map+0x119/0x1ca
[   20.291641] DEBUG_LOCKS_WARN_ON(1)[   20.292254] CPU: 0 PID: 1 Comm: swapper Not tainted 4.8.0-14894-g32ab0a38 #2
[   20.293597] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS rel-1.9.3-0-ge2fc41e-prebuilt.qemu-project.org 04/01/2014
[   20.295623]  ffff88013a8f39e0 ffffffff812cf3c2 ffff88013a8f3a20 ffffffff8109dd32
[   20.296953]  00000c3b3a8f3a98 ffff8801390ee158 ffff8801398d7198 0000000000001000
[   20.298293]  0000000000000000 0000000000000000 ffff88013a8f3a88 ffffffff8109dd93
[   20.299668] Call Trace:
[   20.300135]  [<ffffffff812cf3c2>] dump_stack+0x19/0x1b
[   20.301109]  [<ffffffff8109dd32>] __warn+0xb6/0xd1
[   20.302040]  [<ffffffff8109dd93>] warn_slowpath_fmt+0x46/0x4e
[   20.303105]  [<ffffffff810d2b6f>] lockdep_init_map+0x119/0x1ca
[   20.304218]  [<ffffffff8123c4e1>] __kernfs_create_file+0x75/0xc3
[   20.305362]  [<ffffffff8123cc8f>] sysfs_add_file_mode_ns+0xf3/0x1c8
[   20.306552]  [<ffffffff8123d8da>] internal_create_group+0x210/0x364
[   20.307703]  [<ffffffff8123da3c>] sysfs_create_group+0xe/0x10
[   20.308779]  [<ffffffff818be744>] vhci_start+0x193/0x1e8
[   20.309799]  [<ffffffff817fe2a9>] usb_add_hcd+0x57b/0x8a7
[   20.310833]  [<ffffffff818bd600>] vhci_hcd_probe+0x63/0xcd
[   20.311854]  [<ffffffff814590da>] platform_drv_probe+0x23/0x4e
[   20.312849]  [<ffffffff81457daa>] driver_probe_device+0x1d6/0x407
[   20.313872]  [<ffffffff81458153>] __device_attach_driver+0x90/0xd0
[   20.314927]  [<ffffffff814580c3>] ? driver_allows_async_probing+0xd/0xd
[   20.316066]  [<ffffffff81456623>] bus_for_each_drv+0x7a/0x84
[   20.317025]  [<ffffffff81457aae>] __device_attach+0x89/0xe7
[   20.318136]  [<ffffffff814582a3>] device_initial_probe+0xe/0x10
[   20.319248]  [<ffffffff814567de>] bus_probe_device+0x2e/0x99
[   20.320337]  [<ffffffff814546a2>] device_add+0x3f0/0x4e6
[   20.321357]  [<ffffffff811b8cfa>] ? kfree+0xfe/0x3b1
[   20.322292]  [<ffffffff814596f6>] platform_device_add+0x16d/0x1c6
[   20.323459]  [<ffffffff814598fb>] platform_device_register_full+0xae/0x104
[   20.324718]  [<ffffffff82d8a1ce>] vhci_hcd_init+0xbc/0x144
[   20.325811]  [<ffffffff82d8a112>] ? usbip_core_init+0x17/0x17
[   20.326882]  [<ffffffff82d3706c>] do_one_initcall+0x88/0x145
[   20.327962]  [<ffffffff82d37243>] kernel_init_freeable+0x11a/0x19b
[   20.329118]  [<ffffffff81e03c65>] ? rest_init+0x12c/0x12c
[   20.330165]  [<ffffffff81e03c6e>] kernel_init+0x9/0xeb
[   20.331136]  [<ffffffff81e142ca>] ret_from_fork+0x2a/0x40
[   20.332182] ---[ end trace 157455cd37a65d5a ]---
[   20.333080] vhci_hcd: created sysfs vhci_hcd
[   20.334499] hub 2-0:1.0: USB hub found
[   20.335229] hub 2-0:1.0: 8 ports detected
[   20.336467] hub 2-0:1.0: USB hub found
[   20.337198] hub 2-0:1.0: 8 ports detected
[   20.338659] hub 2-0:1.0: USB hub found
[   20.339396] hub 2-0:1.0: 8 ports detected
[   20.340611] hub 2-0:1.0: USB hub found
[   20.341374] hub 2-0:1.0: 8 ports detected
[   20.342167] dummy_hcd dummy_hcd.0: port status 0x00010101 has changes
[   20.343926] vhci_hcd vhci_hcd: remove, state 1
[   20.344802] usb usb2: USB disconnect, device number 1
[   20.346274] vhci_hcd: stop threads
[   20.346954] vhci_hcd: release socket
[   20.347682] vhci_hcd: disconnect device
[   20.348462] vhci_hcd: stop threads
[   20.349112] vhci_hcd: release socket
[   20.349825] vhci_hcd: disconnect device
[   20.350589] vhci_hcd: stop threads
[   20.351244] vhci_hcd: release socket
[   20.351960] vhci_hcd: disconnect device
[   20.352729] vhci_hcd: stop threads
[   20.353375] vhci_hcd: release socket
[   20.354067] vhci_hcd: disconnect device
[   20.354835] vhci_hcd: stop threads
[   20.355487] vhci_hcd: release socket
[   20.356144] vhci_hcd: disconnect device
[   20.356885] vhci_hcd: stop threads
[   20.357534] vhci_hcd: release socket
[   20.358191] vhci_hcd: disconnect device
[   20.358944] vhci_hcd: stop threads
[   20.359616] vhci_hcd: release socket
[   20.360290] vhci_hcd: disconnect device
[   20.361032] vhci_hcd: stop threads
[   20.361682] vhci_hcd: release socket
[   20.362335] vhci_hcd: disconnect device
[   20.363065] vhci_hcd vhci_hcd: USB bus 2 deregistered
[   20.364218] vhci_hcd vhci_hcd: USB/IP Virtual Host Controller
[   20.365380] vhci_hcd vhci_hcd: new USB bus registered, assigned bus number 2
[   20.366627] BUG: key ffff8801398d7198 not in .data!
[   20.367470] vhci_hcd: created sysfs vhci_hcd
[   20.368673] hub 2-0:1.0: USB hub found
[   20.369390] hub 2-0:1.0: 8 ports detected
[   20.370632] hub 2-0:1.0: USB hub found
[   20.371365] hub 2-0:1.0: 8 ports detected
[   20.372791] hub 2-0:1.0: USB hub found
[   20.373546] hub 2-0:1.0: 8 ports detected
[   20.374687] hub 2-0:1.0: USB hub found
[   20.375415] hub 2-0:1.0: 8 ports detected
[   20.376611] vhci_hcd: USB/IP 'Virtual' Host Controller (VHCI) Driver v1.0.0
[   20.378399] udc usbip-vudc.0: releasing 'usbip-vudc.0'
[   20.379738] i8042: PNP: PS/2 Controller [PNP0303:KBD,PNP0f13:MOU] at 0x60,0x64 irq 1,12
[   20.382372] serio: i8042 KBD port at 0x60,0x64 irq 1
[   20.383350] serio: i8042 AUX port at 0x60,0x64 irq 12
[   20.385350] serio: i8042 KBD port at 0x60,0x64 irq 1
[   20.386383] serio: i8042 AUX port at 0x60,0x64 irq 12
[   20.450952] mousedev: PS/2 mouse device common for all mice
[   20.453312] input: AT Translated Set 2 keyboard as /devices/platform/i8042/serio2/input/input1
[   20.455501] evbug: Connected device: input1 (AT Translated Set 2 keyboard at isa0060/serio0/input0)
[   20.458291] usbcore: registered new interface driver bcm5974
[   20.459972] usbcore: registered new interface driver synaptics_usb
[   20.461671] usbcore: registered new interface driver usb_acecad
[   20.463217] evbug: Disconnected device: input1
[   20.464490] usbcore: registered new interface driver gtco
[   20.466705] input: AT Translated Set 2 keyboard as /devices/platform/i8042/serio2/input/input2
[   20.466716] evbug: Connected device: input2 (AT Translated Set 2 keyboard at isa0060/serio0/input0)
[   20.470489] usbcore: registered new interface driver kbtab
[   20.471979] piix4_smbus 0000:00:01.3: SMBus Host Controller at 0x700, revision 0
[   20.497538] g_ether gadget: resume
[   20.498275] dummy_hcd dummy_hcd.0: port status 0x00100503 has changes
smbus: error: Unexpected recv start condition in state 3
smbus: error: Unexpected read in state -1
smbus: error: Unexpected NACK in state -1
smbus: error: Unexpected NACK in state -1
smbus: error: Unexpected recv start condition in state 3
smbus: error: Unexpected read in state -1
smbus: error: Unexpected NACK in state -1
smbus: error: Unexpected NACK in state -1
smbus: error: Unexpected recv start condition in state 3
smbus: error: Unexpected read in state -1
smbus: error: Unexpected NACK in state -1
smbus: error: Unexpected NACK in state -1
smbus: error: Unexpected recv start condition in state 3
smbus: error: Unexpected read in state -1
smbus: error: Unexpected NACK in state -1
smbus: error: Unexpected NACK in state -1
smbus: error: Unexpected recv start condition in state 3
smbus: error: Unexpected read in state -1
smbus: error: Unexpected NACK in state -1
smbus: error: Unexpected NACK in state -1
smbus: error: Unexpected recv start condition in state 3
smbus: error: Unexpected read in state -1
smbus: error: Unexpected NACK in state -1
smbus: error: Unexpected NACK in state -1
smbus: error: Unexpected recv start condition in state 3
smbus: error: Unexpected read in state -1
smbus: error: Unexpected NACK in state -1
smbus: error: Unexpected NACK in state -1
smbus: error: Unexpected recv start condition in state 3
smbus: error: Unexpected read in state -1
smbus: error: Unexpected NACK in state -1
smbus: error: Unexpected NACK in state -1
[   20.527028] piix4_smbus 0000:00:01.3: SMBus Host Controller at 0x700, revision 0
[   20.551497] usb 1-1: new high-speed USB device number 2 using dummy_hcd
smbus: error: Unexpected recv start condition in state 3
smbus: error: Unexpected read in state -1
smbus: error: Unexpected NACK in state -1
smbus: error: Unexpected NACK in state -1
smbus: error: Unexpected recv start condition in state 3
smbus: error: Unexpected read in state -1
smbus: error: Unexpected NACK in state -1
smbus: error: Unexpected NACK in state -1
smbus: error: Unexpected recv start condition in state 3
smbus: error: Unexpected read in state -1
smbus: error: Unexpected NACK in state -1
smbus: error: Unexpected NACK in state -1
smbus: error: Unexpected recv start condition in state 3
smbus: error: Unexpected read in state -1
smbus: error: Unexpected NACK in state -1
smbus: error: Unexpected NACK in state -1
smbus: error: Unexpected recv start condition in state 3
smbus: error: Unexpected read in state -1
smbus: error: Unexpected NACK in state -1
smbus: error: Unexpected NACK in state -1
smbus: error: Unexpected recv start condition in state 3
smbus: error: Unexpected read in state -1
smbus: error: Unexpected NACK in state -1
smbus: error: Unexpected NACK in state -1
smbus: error: Unexpected recv start condition in state 3
smbus: error: Unexpected read in state -1
smbus: error: Unexpected NACK in state -1
smbus: error: Unexpected NACK in state -1
smbus: error: Unexpected recv start condition in state 3
smbus: error: Unexpected read in state -1
smbus: error: Unexpected NACK in state -1
smbus: error: Unexpected NACK in state -1
[   20.580052] usbcore: registered new interface driver i2c-diolan-u2c
[   20.581445] i2c-parport-light: adapter type unspecified
[   20.582548] usbcore: registered new interface driver RobotFuzz Open Source InterFace, OSIF
[   20.584317] usbcore: registered new interface driver i2c-tiny-usb
[   20.585866] Driver for 1-wire Dallas network protocol.
[   20.587055] usbcore: registered new interface driver DS9490R
[   20.588179] DS1WM w1 busmaster driver - (c) 2004 Szabolcs Gyurko
[   20.589631] __power_supply_register: Expected proper parent device for 'test_ac'
[   20.591250] __power_supply_register: Expected proper parent device for 'test_battery'
[   20.593130] __power_supply_register: Expected proper parent device for 'test_usb'
[   20.606486] g_ether gadget: resume
[   20.607210] dummy_hcd dummy_hcd.0: port status 0x00100503 has changes
[   20.662471] dummy_udc dummy_udc.0: set_address = 2
[   20.693476] g_ether gadget: high-speed config #1: CDC Ethernet (ECM)
[   20.694779] dummy_udc dummy_udc.0: enabled ep5in-int (ep5in-intr) maxpacket 16 stream disabled
[   20.696403] g_ether gadget: init ecm
[   20.697072] g_ether gadget: notify connect false
[   20.697954] g_ether gadget: notify speed 425984000
[   20.702466] g_ether gadget: activate ecm
[   20.703288] dummy_udc dummy_udc.0: enabled ep1in-bulk (ep1in-bulk) maxpacket 512 stream disabled
[   20.704978] dummy_udc dummy_udc.0: enabled ep2out-bulk (ep2out-bulk) maxpacket 512 stream disabled
[   20.706705] usb0: qlen 10
[   20.707207] g_ether gadget: ecm_close
[   20.709466] g_ether gadget: packet filter 0c
[   20.710366] g_ether gadget: ecm req21.43 v000c i0000 l0
[   20.713935] cdc_ether 1-1:1.0 usb1: register 'cdc_ether' at usb-dummy_hcd.0-1, CDC Ethernet Device, 7e:16:00:29:cc:08
[   20.716021] cdc_ether 1-1:1.0 usb1: unregister 'cdc_ether' usb-dummy_hcd.0-1, CDC Ethernet Device
[   20.722466] g_ether gadget: reset ecm
[   20.723227] usb0: gether_disconnect
[   20.723904] dummy_udc dummy_udc.0: disabled ep1in-bulk
[   20.724894] dummy_udc dummy_udc.0: disabled ep2out-bulk
[   20.725895] g_ether gadget: init ecm
[   20.728474] g_ether gadget: activate ecm
[   20.729277] dummy_udc dummy_udc.0: enabled ep1in-bulk (ep1in-bulk) maxpacket 512 stream disabled
[   20.730957] dummy_udc dummy_udc.0: enabled ep2out-bulk (ep2out-bulk) maxpacket 512 stream disabled
[   20.732668] usb0: qlen 10
[   20.733184] g_ether gadget: ecm_close
[   20.735477] g_ether gadget: packet filter 0c
[   20.736325] g_ether gadget: ecm req21.43 v000c i0000 l0
[   20.738896] cdc_ether 1-1:1.0 usb1: register 'cdc_ether' at usb-dummy_hcd.0-1, CDC Ethernet Device, 7e:16:00:29:cc:08
[   20.742743] cdc_ether 1-1:1.0 usb1: unregister 'cdc_ether' usb-dummy_hcd.0-1, CDC Ethernet Device
[   20.749461] g_ether gadget: reset config
[   20.750289] g_ether gadget: ecm deactivated
[   20.751102] usb0: gether_disconnect
[   20.751788] dummy_udc dummy_udc.0: disabled ep1in-bulk
[   20.752789] dummy_udc dummy_udc.0: disabled ep2out-bulk
[   20.753814] dummy_udc dummy_udc.0: disabled ep5in-int
[   20.754783] g_ether gadget: high-speed config #0: unconfigured
[   20.757470] g_ether gadget: high-speed config #1: CDC Ethernet (ECM)
[   20.758751] dummy_udc dummy_udc.0: enabled ep5in-int (ep5in-intr) maxpacket 16 stream disabled
[   20.760414] g_ether gadget: init ecm
[   20.761156] g_ether gadget: notify connect false
[   20.762096] g_ether gadget: notify speed 425984000
[   20.765474] g_ether gadget: activate ecm
[   20.766305] dummy_udc dummy_udc.0: enabled ep1in-bulk (ep1in-bulk) maxpacket 512 stream disabled
[   20.767960] dummy_udc dummy_udc.0: enabled ep2out-bulk (ep2out-bulk) maxpacket 512 stream disabled
[   20.769682] usb0: qlen 10
[   20.770181] g_ether gadget: ecm_close
[   20.772462] g_ether gadget: packet filter 0c
[   20.773299] g_ether gadget: ecm req21.43 v000c i0000 l0
[   20.775889] cdc_ether 1-1:1.0 usb1: register 'cdc_ether' at usb-dummy_hcd.0-1, CDC Ethernet Device, 7e:16:00:29:cc:08
[   20.778189] cdc_ether 1-1:1.0 usb1: unregister 'cdc_ether' usb-dummy_hcd.0-1, CDC Ethernet Device
[   20.784465] g_ether gadget: reset ecm
[   20.785257] usb0: gether_disconnect
[   20.786009] dummy_udc dummy_udc.0: disabled ep1in-bulk
[   20.787107] dummy_udc dummy_udc.0: disabled ep2out-bulk
[   20.788400] g_ether gadget: init ecm
[   20.791464] g_ether gadget: activate ecm
[   20.792430] dummy_udc dummy_udc.0: enabled ep1in-bulk (ep1in-bulk) maxpacket 512 stream disabled
[   20.794568] dummy_udc dummy_udc.0: enabled ep2out-bulk (ep2out-bulk) maxpacket 512 stream disabled
[   20.796766] usb0: qlen 10
[   20.797428] g_ether gadget: ecm_close
[   20.798526] applesmc: supported laptop not found!
[   20.799695] applesmc: driver init failed (ret=-19)!
[   20.802465] g_ether gadget: packet filter 0c
[   20.803481] g_ether gadget: ecm req21.43 v000c i0000 l0
[   20.806924] cdc_ether 1-1:1.0 usb1: register 'cdc_ether' at usb-dummy_hcd.0-1, CDC Ethernet Device, 7e:16:00:29:cc:08
[   21.073600] pc87360: PC8736x not detected, module not inserted
[   21.124038] sdhci: Secure Digital Host Controller Interface driver
[   21.125552] sdhci: Copyright(c) Pierre Ossman
[   21.126875] usbcore: registered new interface driver ushc
[   21.128105] sdhci-pltfm: SDHCI platform and OF driver helper
[   21.129967] leds_ss4200: no LED devices found
[   21.137679] dcdbas dcdbas: Dell Systems Management Base Driver (version 5.6.0-3.2)
[   21.139568] dcdbas dcdbas: Dell Systems Management Base Driver (version 5.6.0-3.2)
[   21.142218] fw_cfg: probe of QEMU0002:00 failed with error -16
[   21.143582] CHRDEV "qat_adf_ctl" major number 233 goes below the dynamic allocation range
[   21.145954] CHRDEV "hidraw" major number 232 goes below the dynamic allocation range
[   21.147765] hidraw: raw HID events driver (C) Jiri Kosina
[   21.149914] CHRDEV "roccat" major number 230 goes below the dynamic allocation range
[   21.152620] usbcore: registered new interface driver usbhid
[   21.154061] usbhid: USB HID core driver
[   21.158500] usbcore: registered new interface driver prism2_usb
[   21.159985] usbcore: registered new interface driver r8712u
[   21.161329] usbcore: registered new interface driver r8188eu
[   21.162551] vme_user: VME User Space Access Driver
[   21.163649] vme_user: No cards, skipping registration
[   21.164754] vme_pio2: No cards, skipping registration
[   21.165884] no options.
[   21.166624] CHRDEV "fwtty" major number 229 goes below the dynamic allocation range
[   21.168346] CHRDEV "fwloop" major number 228 goes below the dynamic allocation range
[   21.170643] FPGA DOWNLOAD --->
[   21.171454] FPGA image file name: xlinx_fpga_firmware.bit
[   21.172976] GPIO INIT FAIL!!
[   21.175217] mostcore: init()
[   21.176122] aim_cdev: init()
[   21.176833] CHRDEV "cdev" major number 227 goes below the dynamic allocation range
[   21.178640] mostcore: registered new application interfacing module cdev
[   21.180336] aim_network: most_net_init()
[   21.181369] mostcore: registered new application interfacing module networking
[   21.183107] hdm_usb: hdm_usb_init()
[   21.184018] usbcore: registered new interface driver hdm_usb
[   21.185678] Board is not the VME system controller
[   21.186821] VME geographical address is set to 0
[   21.187974] CR/CSR Offset: 0
[   21.188848] Software Queue-Pair Transport over NTB, version 4
[   21.190965] Audio Excel DSP 16 init driver Copyright (C) Riccardo Facchetti 1995-98
[   21.195865] aedsp16: I/O, IRQ and DMA are mandatory
[   21.196962] pss: mss_io, mss_dma, mss_irq and pss_io must be set.
[   21.198341] ad1848/cs4248 codec driver Copyright (C) by Hannu Savolainen 1993-1996
[   21.199976] ad1848: No ISAPnP cards found, trying standard ones...
[   21.201451] MediaTrix audio driver Copyright (C) by Hannu Savolainen 1993-1996
[   21.203198] I/O, IRQ, DMA and type are mandatory
[   21.204368] Pro Audio Spectrum driver Copyright (C) by Hannu Savolainen 1993-1996
[   21.206266] I/O, IRQ, DMA and type are mandatory
[   21.207473] sb: Init: Starting Probe...
[   21.208543] sb: Init: Done
[   21.209208] uart6850: irq and io must be set.
[   21.210234] YM3812 and OPL-3 driver Copyright (C) by Hannu Savolainen, Rob Hooft 1993-1996
[   21.215536] MIDI Loopback device driver
[   21.216851] ipip: IPv4 and MPLS over IPv4 tunneling driver
[   21.218643] gre: GRE over IPv4 demultiplexor driver
[   21.219781] ip_gre: GRE over IPv4 tunneling driver
[   21.221679] Initializing XFRM netlink socket
[   21.223220] NET: Registered protocol family 10
[   21.226343] ip6_gre: GRE over IPv6 tunneling driver
[   21.228114] NET: Registered protocol family 15
[   21.229473] NET: Registered protocol family 4
[   21.230521] NET: Registered protocol family 5
[   21.231590] NET: Registered protocol family 9
[   21.232650] X25: Linux Version 0.2
[   21.234078] NET: Registered protocol family 41
[   21.235207] l2tp_core: L2TP core driver, V2.0
[   21.236157] l2tp_ppp: PPPoL2TP kernel driver, V2.0
[   21.237177] l2tp_ip: L2TP IP encapsulation support (L2TPv3)
[   21.238296] l2tp_netlink: L2TP netlink interface
[   21.239259] l2tp_debugfs: L2TP debugfs support
[   21.240121] l2tp_ip6: L2TP IP encapsulation support for IPv6 (L2TPv3)
[   21.250542] DCCP: Activated CCID 2 (TCP-like)
[   21.252412] sctp: Hash tables configured (bind 32/51)
[   21.253806] lib80211: common routines for IEEE802.11 drivers
[   21.255024] lib80211_crypt: registered algorithm 'NULL'
[   21.256145] lib80211_crypt: registered algorithm 'WEP'
[   21.257150] lib80211_crypt: registered algorithm 'CCMP'
[   21.258122] lib80211_crypt: registered algorithm 'TKIP'
[   21.259158] NET: Registered protocol family 37
[   21.260645] batman_adv: B.A.T.M.A.N. advanced 2016.5 (compatibility version 15) loaded
[   21.262482] openvswitch: Open vSwitch switching datapath
[   21.264022] mpls_gso: MPLS GSO support
[   21.265602] registered taskstats version 1
[   21.267924] gtp: GTP module loaded (pdp ctx size 80 bytes)
[   21.269143] BIOS EDD facility v0.16 2004-Jun-25, 0 devices found
[   21.270660] EDD information not available.
[   21.272671] debug: unmapping init [mem 0xffffffff82d36000-0xffffffff82e5efff]
[   21.274402] Write protecting the kernel read-only data: 24576k
[   21.276373] debug: unmapping init [mem 0xffff880001e19000-0xffff880001ffffff]
[   21.278124] debug: unmapping init [mem 0xffff880002634000-0xffff8800027fffff]
[   21.296841] x86/mm: Checked W+X mappings: passed, no W+X pages found.
[   21.298485] Kernel panic - not syncing: No working init found.  Try passing init= option to kernel. See Linux Documentation/init.txt for guidance.
[   21.301375] CPU: 0 PID: 1 Comm: swapper Tainted: G        W       4.8.0-14894-g32ab0a38 #2
[   21.303262] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS rel-1.9.3-0-ge2fc41e-prebuilt.qemu-project.org 04/01/2014
[   21.305932]  ffff88013a8f3eb8 ffffffff812cf3c2 ffff88013a8f3f38 ffffffff8115cf6a
[   21.307705]  ffffffff00000008 ffff88013a8f3f48 ffff88013a8f3ee0 0000000000000000
[   21.309442]  0000000000000000 0000000000000000 0000000000001c0e 0000000000000001
[   21.311175] Call Trace:
[   21.311781]  [<ffffffff812cf3c2>] dump_stack+0x19/0x1b
[   21.312935]  [<ffffffff8115cf6a>] panic+0xd0/0x20c
[   21.314009]  [<ffffffff81e03c65>] ? rest_init+0x12c/0x12c
[   21.315119]  [<ffffffff81e03d4c>] kernel_init+0xe7/0xeb
[   21.316196]  [<ffffffff81e142ca>] ret_from_fork+0x2a/0x40
[   21.317321] Kernel Offset: disabled
[   21.318060] ---[ end Kernel panic - not syncing: No working init found.  Try passing init= option to kernel. See Linux Documentation/init.txt for guidance.

[   63.453500] Writes:  Total: 2  Max/Min: 0/0   Fail: 0
QEMU: Terminated
anielsen@lx-anielsen ~/work/opensource-phy/lkp-tests (master) $

Output 3 (af1fee98219992ba2c12441a447719652ed7e983 with bug):
anielsen@lx-anielsen ~/work/opensource-phy/lkp-tests (master) $ sudo qemu-system-x86_64 -enable-kvm -cpu host -smp 2 -m 4G -kernel ../net-next/bug-build/arch/x86_64/boot/bzImage -nographic
[    0.000000] Linux version 4.8.0-14895-gaf1fee9 (anielsen@lx-anielsen) (gcc version 5.2.0 (Gentoo 5.2.0 p1.3, pie-0.6.5) ) #4 PREEMPT Mon Nov 7 13:21:09 CET 2016
[    0.000000] Command line:
[    0.000000] x86/fpu: Legacy x87 FPU detected.
[    0.000000] x86/fpu: Using 'eager' FPU context switches.
[    0.000000] e820: BIOS-provided physical RAM map:
[    0.000000] BIOS-e820: [mem 0x0000000000000000-0x000000000009fbff] usable
[    0.000000] BIOS-e820: [mem 0x000000000009fc00-0x000000000009ffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000000f0000-0x00000000000fffff] reserved
[    0.000000] BIOS-e820: [mem 0x0000000000100000-0x00000000bffdffff] usable
[    0.000000] BIOS-e820: [mem 0x00000000bffe0000-0x00000000bfffffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000feffc000-0x00000000feffffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000fffc0000-0x00000000ffffffff] reserved
[    0.000000] BIOS-e820: [mem 0x0000000100000000-0x000000013fffffff] usable
[    0.000000] NX (Execute Disable) protection: active
[    0.000000] SMBIOS 2.8 present.
[    0.000000] Hypervisor detected: KVM
[    0.000000] e820: last_pfn = 0x140000 max_arch_pfn = 0x400000000
[    0.000000] x86/PAT: Configuration [0-7]: WB  WC  UC- UC  WB  WC  UC- WT
[    0.000000] e820: last_pfn = 0xbffe0 max_arch_pfn = 0x400000000
[    0.000000] ACPI: Early table checksum verification disabled
[    0.000000] ACPI: RSDP 0x00000000000F6970 000014 (v00 BOCHS )
[    0.000000] ACPI: RSDT 0x00000000BFFE1936 000030 (v01 BOCHS  BXPCRSDT 00000001 BXPC 00000001)
[    0.000000] ACPI: FACP 0x00000000BFFE180A 000074 (v01 BOCHS  BXPCFACP 00000001 BXPC 00000001)
[    0.000000] ACPI: DSDT 0x00000000BFFE0040 0017CA (v01 BOCHS  BXPCDSDT 00000001 BXPC 00000001)
[    0.000000] ACPI: FACS 0x00000000BFFE0000 000040
[    0.000000] ACPI: APIC 0x00000000BFFE187E 000080 (v01 BOCHS  BXPCAPIC 00000001 BXPC 00000001)
[    0.000000] ACPI: HPET 0x00000000BFFE18FE 000038 (v01 BOCHS  BXPCHPET 00000001 BXPC 00000001)
[    0.000000] kvm-clock: Using msrs 4b564d01 and 4b564d00
[    0.000000] kvm-clock: cpu 0, msr 1:3f800001, primary cpu clock
[    0.000000] kvm-clock: using sched offset of 392391616 cycles
[    0.000000] clocksource: kvm-clock: mask: 0xffffffffffffffff max_cycles: 0x1cd42e4dffb, max_idle_ns: 881590591483 ns
[    0.000000] Zone ranges:
[    0.000000]   DMA      [mem 0x0000000000001000-0x0000000000ffffff]
[    0.000000]   DMA32    [mem 0x0000000001000000-0x00000000ffffffff]
[    0.000000]   Normal   [mem 0x0000000100000000-0x000000013fffffff]
[    0.000000]   Device   empty
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x0000000000001000-0x000000000009efff]
[    0.000000]   node   0: [mem 0x0000000000100000-0x00000000bffdffff]
[    0.000000]   node   0: [mem 0x0000000100000000-0x000000013fffffff]
[    0.000000] Initmem setup node 0 [mem 0x0000000000001000-0x000000013fffffff]
[    0.000000] ACPI: PM-Timer IO Port: 0x608
[    0.000000] APIC: NR_CPUS/possible_cpus limit of 1 reached. Processor 1/0x1 ignored.
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0xff] dfl dfl lint[0x1])
[    0.000000] IOAPIC[0]: apic_id 0, version 17, address 0xfec00000, GSI 0-23
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 5 global_irq 5 high level)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 10 global_irq 10 high level)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 11 global_irq 11 high level)
[    0.000000] Using ACPI (MADT) for SMP configuration information
[    0.000000] ACPI: HPET id: 0x8086a201 base: 0xfed00000
[    0.000000] KVM setup async PF for cpu 0
[    0.000000] kvm-stealtime: cpu 0, msr 2835b80
[    0.000000] e820: [mem 0xc0000000-0xfeffbfff] available for PCI devices
[    0.000000] Booting paravirtualized kernel on KVM
[    0.000000] clocksource: refined-jiffies: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 1910969940391419 ns
[    0.000000] Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 1032041
[    0.000000] Kernel command line:
[    0.000000] PID hash table entries: 4096 (order: 3, 32768 bytes)
[    0.000000] Dentry cache hash table entries: 524288 (order: 10, 4194304 bytes)
[    0.000000] Inode-cache hash table entries: 262144 (order: 9, 2097152 bytes)
[    0.000000] Memory: 3984732K/4193784K available (14425K kernel code, 5327K rwdata, 6352K rodata, 1188K init, 30876K bss, 209052K reserved, 0K cma-reserved)
[    0.000000] SLUB: HWalign=64, Order=0-3, MinObjects=0, CPUs=1, Nodes=1
[    0.000000] Running RCU self tests
[    0.000000] Preemptible hierarchical RCU implementation.
[    0.000000]  RCU debugfs-based tracing is enabled.
[    0.000000]  RCU lockdep checking is enabled.
[    0.000000]  Build-time adjustment of leaf fanout to 64.
[    0.000000] NR_IRQS:4352 nr_irqs:48 16
[    0.000000] console [ttyS0] enabled
[    0.000000] Lock dependency validator: Copyright (c) 2006 Red Hat, Inc., Ingo Molnar
[    0.000000] ... MAX_LOCKDEP_SUBCLASSES:  8
[    0.000000] ... MAX_LOCK_DEPTH:          48
[    0.000000] ... MAX_LOCKDEP_KEYS:        8191
[    0.000000] ... CLASSHASH_SIZE:          4096
[    0.000000] ... MAX_LOCKDEP_ENTRIES:     32768
[    0.000000] ... MAX_LOCKDEP_CHAINS:      65536
[    0.000000] ... CHAINHASH_SIZE:          32768
[    0.000000]  memory used by lock dependency info: 8671 kB
[    0.000000]  per task-struct memory footprint: 2688 bytes
[    0.000000] ODEBUG: selftest passed
[    0.000000] clocksource: hpet: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 19112604467 ns
[    0.000000] tsc: Detected 3066.410 MHz processor
[    0.536791] Calibrating delay loop (skipped) preset value.. 6132.82 BogoMIPS (lpj=3066410)
[    0.537681] pid_max: default: 32768 minimum: 301
[    0.538229] ACPI: Core revision 20160831
[    0.544467] ACPI: 1 ACPI AML tables successfully acquired and loaded

[    0.545432] Mount-cache hash table entries: 8192 (order: 4, 65536 bytes)
[    0.546161] Mountpoint-cache hash table entries: 8192 (order: 4, 65536 bytes)
[    0.547747] Last level iTLB entries: 4KB 0, 2MB 0, 4MB 0
[    0.548330] Last level dTLB entries: 4KB 0, 2MB 0, 4MB 0, 1GB 0
[    0.548963] CPU: Intel(R) Xeon(R) CPU           W3550  @ 3.07GHz (family: 0x6, model: 0x1a, stepping: 0x5)
[    0.554043] Performance Events: Nehalem events, Intel PMU driver.
[    0.554913] core: CPUID marked event: 'bus cycles' unavailable
[    0.555592] ... version:                2
[    0.555987] ... bit width:              48
[    0.556399] ... generic registers:      4
[    0.556794] ... value mask:             0000ffffffffffff
[    0.557283] ... max period:             000000007fffffff
[    0.557803] ... fixed-purpose events:   3
[    0.558217] ... event mask:             000000070000000f
[    0.562333] ..TIMER: vector=0x30 apic1=0 pin1=2 apic2=-1 pin2=-1
[    0.563535] devtmpfs: initialized
[    0.564173] x86/mm: Memory block size: 128MB
[    0.568480] clocksource: jiffies: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 1911260446275000 ns
[    0.569661] atomic64_test: passed for x86-64 platform with CX8 and with SSE
[    0.570383] pinctrl core: initialized pinctrl subsystem
[    0.571539] regulator-dummy: Failed to create debugfs directory
[    0.572738] NET: Registered protocol family 16
[    0.577282] cpuidle: using governor menu
[    0.577836] ACPI: bus type PCI registered
[    0.578251] acpiphp: ACPI Hot Plug PCI Controller Driver version: 0.5
[    0.579116] PCI: Using configuration type 1 for base access
[    0.614842] HugeTLB registered 2 MB page size, pre-allocated 0 pages
[    0.616190] ACPI: Added _OSI(Module Device)
[    0.616644] ACPI: Added _OSI(Processor Device)
[    0.617109] ACPI: Added _OSI(3.0 _SCP Extensions)
[    0.617586] ACPI: Added _OSI(Processor Aggregator Device)
[    0.623687] ACPI: Interpreter enabled
[    0.624110] ACPI: (supports S0 S5)
[    0.624459] ACPI: Using IOAPIC for interrupt routing
[    0.625043] PCI: Using host bridge windows from ACPI; if necessary, use "pci=nocrs" and report a bug
[    0.641620] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-ff])
[    0.642306] acpi PNP0A03:00: _OSC: OS supports [Segments]
[    0.642910] acpi PNP0A03:00: _OSC failed (AE_NOT_FOUND); disabling ASPM
[    0.643598] acpi PNP0A03:00: fail to add MMCONFIG information, can't access extended PCI configuration space under this bridge.
[    0.645212] acpiphp: Slot [3] registered
[    0.645723] acpiphp: Slot [4] registered
[    0.646249] acpiphp: Slot [5] registered
[    0.646768] acpiphp: Slot [6] registered
[    0.647280] acpiphp: Slot [7] registered
[    0.647795] acpiphp: Slot [8] registered
[    0.648309] acpiphp: Slot [9] registered
[    0.648809] acpiphp: Slot [10] registered
[    0.649350] acpiphp: Slot [11] registered
[    0.649863] acpiphp: Slot [12] registered
[    0.650396] acpiphp: Slot [13] registered
[    0.650913] acpiphp: Slot [14] registered
[    0.651434] acpiphp: Slot [15] registered
[    0.651957] acpiphp: Slot [16] registered
[    0.652478] acpiphp: Slot [17] registered
[    0.652993] acpiphp: Slot [18] registered
[    0.653526] acpiphp: Slot [19] registered
[    0.654037] acpiphp: Slot [20] registered
[    0.654564] acpiphp: Slot [21] registered
[    0.655071] acpiphp: Slot [22] registered
[    0.655600] acpiphp: Slot [23] registered
[    0.656126] acpiphp: Slot [24] registered
[    0.656649] acpiphp: Slot [25] registered
[    0.657159] acpiphp: Slot [26] registered
[    0.657693] acpiphp: Slot [27] registered
[    0.658212] acpiphp: Slot [28] registered
[    0.658754] acpiphp: Slot [29] registered
[    0.659270] acpiphp: Slot [30] registered
[    0.659794] acpiphp: Slot [31] registered
[    0.660228] PCI host bridge to bus 0000:00
[    0.660640] pci_bus 0000:00: root bus resource [io  0x0000-0x0cf7 window]
[    0.661334] pci_bus 0000:00: root bus resource [io  0x0d00-0xffff window]
[    0.662006] pci_bus 0000:00: root bus resource [mem 0x000a0000-0x000bffff window]
[    0.662798] pci_bus 0000:00: root bus resource [mem 0xc0000000-0xfebfffff window]
[    0.663559] pci_bus 0000:00: root bus resource [bus 00-ff]
[    0.669631] pci 0000:00:01.1: legacy IDE quirk: reg 0x10: [io  0x01f0-0x01f7]
[    0.670368] pci 0000:00:01.1: legacy IDE quirk: reg 0x14: [io  0x03f6]
[    0.671033] pci 0000:00:01.1: legacy IDE quirk: reg 0x18: [io  0x0170-0x0177]
[    0.671739] pci 0000:00:01.1: legacy IDE quirk: reg 0x1c: [io  0x0376]
[    0.673320] pci 0000:00:01.3: quirk: [io  0x0600-0x063f] claimed by PIIX4 ACPI
[    0.674074] pci 0000:00:01.3: quirk: [io  0x0700-0x070f] claimed by PIIX4 SMB
[    0.704243] ACPI: PCI Interrupt Link [LNKA] (IRQs 5 *10 11)
[    0.705282] ACPI: PCI Interrupt Link [LNKB] (IRQs 5 *10 11)
[    0.706965] ACPI: PCI Interrupt Link [LNKC] (IRQs 5 10 *11)
[    0.708079] ACPI: PCI Interrupt Link [LNKD] (IRQs 5 10 *11)
[    0.708916] ACPI: PCI Interrupt Link [LNKS] (IRQs *9)
[    0.711431] vgaarb: setting as boot device: PCI:0000:00:02.0
[    0.712022] vgaarb: device added: PCI:0000:00:02.0,decodes=io+mem,owns=io+mem,locks=none
[    0.712860] vgaarb: loaded
[    0.713144] vgaarb: bridge control possible 0000:00:02.0
[    0.714679] ACPI: bus type USB registered
[    0.715206] usbcore: registered new interface driver usbfs
[    0.715814] usbcore: registered new interface driver hub
[    0.716444] usbcore: registered new device driver usb
[    0.717175] pps_core: LinuxPPS API ver. 1 registered
[    0.717700] pps_core: Software ver. 5.3.6 - Copyright 2005-2007 Rodolfo Giometti <giometti@linux.it>
[    0.718627] PTP clock support registered
[    0.719434] FPGA manager framework
[    0.719825] PCI: Using ACPI for IRQ routing
[    0.721098] NET: Registered protocol family 23
[    0.721651] NET: Registered protocol family 8
[    0.722109] NET: Registered protocol family 20
[    0.722857] workqueue: round-robin CPU selection forced, expect performance impact
[    0.723973] nfc: nfc_init: NFC Core ver 0.1
[    0.724461] NET: Registered protocol family 39
[    0.725002] clocksource: Switched to clocksource kvm-clock
[    0.727501] Warning: could not register annotated branches stats
[    0.778806] VFS: Disk quotas dquot_6.6.0
[    0.779326] VFS: Dquot-cache hash table entries: 512 (order 0, 4096 bytes)
[    0.780221] FS-Cache: Loaded
[    0.780775] pnp: PnP ACPI init
[    0.783057] pnp: PnP ACPI: found 6 devices
[    0.789020] clocksource: acpi_pm: mask: 0xffffff max_cycles: 0xffffff, max_idle_ns: 2085701024 ns
[    0.790375] NET: Registered protocol family 2
[    0.791521] TCP established hash table entries: 32768 (order: 6, 262144 bytes)
[    0.793882] TCP bind hash table entries: 32768 (order: 9, 2621440 bytes)
[    0.797484] TCP: Hash tables configured (established 32768 bind 32768)
[    0.798458] UDP hash table entries: 2048 (order: 6, 393216 bytes)
[    0.799584] UDP-Lite hash table entries: 2048 (order: 6, 393216 bytes)
[    0.800866] NET: Registered protocol family 1
[    0.801357] pci 0000:00:00.0: Limiting direct PCI/PCI transfers
[    0.801983] pci 0000:00:01.0: PIIX3: Enabling Passive Release
[    0.802604] pci 0000:00:01.0: Activating ISA DMA hang workarounds
[    0.803291] pci 0000:00:02.0: Video device with shadowed ROM at [mem 0x000c0000-0x000dffff]
[    0.804490] PCI-DMA: Using software bounce buffering for IO (SWIOTLB)
[    0.805200] software IO TLB [mem 0xbbfe0000-0xbffe0000] (64MB) mapped at [ffff8800bbfe0000-ffff8800bffdffff]
[    0.809208] PCLMULQDQ-NI instructions are not detected.
[    0.810244] AVX or AES-NI instructions are not detected.
[    0.810793] CPU feature 'AVX registers' is not supported.
[    0.811356] CPU feature 'AVX registers' is not supported.
[    0.811898] CPU feature 'AVX registers' is not supported.
[    0.812449] AVX2 or AES-NI instructions are not detected.
[    0.812997] AVX2 instructions are not detected.
[    0.813748] spin_lock-torture:--- Start of test [debug]: nwriters_stress=2 nreaders_stress=0 stat_interval=60 verbose=1 shuffle_interval=3 stutter=5 shutdown_secs=0 onoff_interval=0 onoff_holdoff=0
[    0.815524] spin_lock-torture: Creating torture_shuffle task
[    0.816195] spin_lock-torture: Creating torture_stutter task
[    0.816810] spin_lock-torture: torture_shuffle task started
[    0.817444] spin_lock-torture: Creating lock_torture_writer task
[    0.818119] spin_lock-torture: torture_stutter task started
[    0.818699] spin_lock-torture: Creating lock_torture_writer task
[    0.819375] spin_lock-torture: lock_torture_writer task started
[    0.819990] spin_lock-torture: Creating lock_torture_stats task
[    0.820648] spin_lock-torture: lock_torture_writer task started
[    0.821332] torture_init_begin: Refusing rcu init: spin_lock running.
[    0.821982] torture_init_begin: One torture test at a time!
[    0.823277] futex hash table entries: 256 (order: 2, 24576 bytes)
[    0.824492] spin_lock-torture: lock_torture_stats task started
[    0.825173] workingset: timestamp_bits=62 max_order=20 bucket_order=0
[    0.834987] DLM installed
[    0.835333] jffs2: version 2.2. (NAND) © 2001-2006 Red Hat, Inc.
[    0.836561] fuse init (API version 7.26)
[    0.842399] NET: Registered protocol family 38
[    0.851293] test_hexdump: all 1184 tests passed
[    0.851977] test_firmware: interface ready
[    0.857079] test_hash: __hash_32() has no arch implementation to test.
[    0.857745] test_hash: hash_32() has no arch implementation to test.
[    0.858393] test_hash: hash_64() has no arch implementation to test.
[    0.859049] test_hash: 33152 tests passed.
[    0.859523] Running rhashtable test nelem=8, max_size=0, shrinking=0
[    0.860170] Test 00:
[    0.866634]   Adding 50000 keys
[    1.021610]   Traversal complete: counted=50000, nelems=50000, entries=50000, table-jumps=0
[    1.102033]   Traversal complete: counted=50000, nelems=50000, entries=50000, table-jumps=0
[    1.102969]   Deleting 50000 keys
[    1.165948]   Duration of test: 298904999 ns
[    1.166886] Test 01:
[    1.169132]   Adding 50000 keys
[    1.326776]   Traversal complete: counted=50000, nelems=50000, entries=50000, table-jumps=0
[    1.409811]   Traversal complete: counted=50000, nelems=50000, entries=50000, table-jumps=0
[    1.410716]   Deleting 50000 keys
[    1.473728]   Duration of test: 304225252 ns
[    1.474643] Test 02:
[    1.476793]   Adding 50000 keys
[    1.633313]   Traversal complete: counted=50000, nelems=50000, entries=50000, table-jumps=0
[    1.716856]   Traversal complete: counted=50000, nelems=50000, entries=50000, table-jumps=0
[    1.717751]   Deleting 50000 keys
[    1.778047]   Duration of test: 300851231 ns
[    1.778901] Test 03:
[    1.780666]   Adding 50000 keys
[    1.811687] tsc: Refined TSC clocksource calibration: 3066.645 MHz
[    1.814050] clocksource: tsc: mask: 0xffffffffffffffff max_cycles: 0x2c343292001, max_idle_ns: 440795316307 ns
[    1.935093]   Traversal complete: counted=50000, nelems=50000, entries=50000, table-jumps=0
[    2.011217]   Traversal complete: counted=50000, nelems=50000, entries=50000, table-jumps=0
[    2.012075]   Deleting 50000 keys
[    2.072037]   Duration of test: 290956402 ns
[    2.072895] Average test time: 298734471
[    2.073316] Testing concurrent rhashtable access from 10 threads
[    8.052590] Started 10 threads, 0 failed
[    8.063120] test_printf: all 260 tests passed
[    8.111388] test_bitmap: all 460506 tests passed
[    8.111909] test_uuid: all 18 tests passed
[    8.113554] crc32: CRC_LE_BITS = 8, CRC_BE BITS = 8
[    8.114075] crc32: self tests passed, processed 225944 bytes in 555434 nsec
[    8.115294] crc32c: CRC_LE_BITS = 8
[    8.115650] crc32c: self tests passed, processed 225944 bytes in 251011 nsec
[    8.143783] crc32_combine: 8373 self tests passed
[    8.171662] crc32c_combine: 8373 self tests passed
[    8.172431] rbtree testing[    8.791825]  -> 18984 cycles
[    8.873434] augmented rbtree testing[    9.690889]  -> 25055 cycles
[    9.795388] gpio-mockup: probe of gpio-mockup failed with error -22
[    9.796434] pci_hotplug: PCI Hot Plug PCI Core version: 0.5
[    9.796999] cpcihp_zt5550: ZT5550 CompactPCI Hot Plug Driver version: 0.2
[    9.801677] acpiphp_ibm: ibm_acpiphp_init: acpi_walk_namespace failed
[    9.802793] cr_bllcd: INTEL CARILLO RANCH LPC not found.
[    9.803373] cr_bllcd: Carillo Ranch Backlight Driver Initialized.
[    9.804628] Could not find Carillo Ranch MCH device.
[    9.805224] no IO addresses supplied
[    9.805918] usbcore: registered new interface driver udlfb
[    9.806529] usbcore: registered new interface driver smscufx
[    9.807783] uvesafb: failed to execute /sbin/v86d
[    9.808291] uvesafb: make sure that the v86d helper is installed and executable
[    9.809057] uvesafb: Getting VBE info block failed (eax=0x4f00, err=-2)
[    9.809736] uvesafb: vbe_init() failed with -22
[    9.810238] uvesafb: probe of uvesafb.0 failed with error -22
[    9.811183] input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/input/input0
[    9.811935] ACPI: Power Button [PWRF]
[    9.812625] button: probe of LNXPWRBN:00 failed with error -22
[    9.813401] Warning: Processor Platform Limit event detected, but not handled.
[    9.814175] Consider compiling CPUfreq support into your kernel.
[    9.815382] EINJ: EINJ table not found.
[    9.815789] ERST DBG: ERST support is disabled.
[    9.851332] Serial: 8250/16550 driver, 4 ports, IRQ sharing enabled
[    9.875170] 00:05: ttyS0 at I/O 0x3f8 (irq = 4, base_baud = 115200) is a 16550A
[    9.876733] console [ttyS0] disabled
[    0.000000] Linux version 4.8.0-14895-gaf1fee9 (anielsen@lx-anielsen) (gcc version 5.2.0 (Gentoo 5.2.0 p1.3, pie-0.6.5) ) #4 PREEMPT Mon Nov 7 13:21:09 CET 2016
[    0.000000] Command line:
[    0.000000] x86/fpu: Legacy x87 FPU detected.
[    0.000000] x86/fpu: Using 'eager' FPU context switches.
[    0.000000] e820: BIOS-provided physical RAM map:
[    0.000000] BIOS-e820: [mem 0x0000000000000000-0x000000000009fbff] usable
[    0.000000] BIOS-e820: [mem 0x000000000009fc00-0x000000000009ffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000000f0000-0x00000000000fffff] reserved
[    0.000000] BIOS-e820: [mem 0x0000000000100000-0x00000000bffdffff] usable
[    0.000000] BIOS-e820: [mem 0x00000000bffe0000-0x00000000bfffffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000feffc000-0x00000000feffffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000fffc0000-0x00000000ffffffff] reserved
[    0.000000] BIOS-e820: [mem 0x0000000100000000-0x000000013fffffff] usable
[    0.000000] NX (Execute Disable) protection: active
[    0.000000] SMBIOS 2.8 present.
[    0.000000] Hypervisor detected: KVM
[    0.000000] e820: last_pfn = 0x140000 max_arch_pfn = 0x400000000
[    0.000000] x86/PAT: Configuration [0-7]: WB  WC  UC- UC  WB  WC  UC- WT
[    0.000000] e820: last_pfn = 0xbffe0 max_arch_pfn = 0x400000000
[    0.000000] ACPI: Early table checksum verification disabled
[    0.000000] ACPI: RSDP 0x00000000000F6970 000014 (v00 BOCHS )
[    0.000000] ACPI: RSDT 0x00000000BFFE1936 000030 (v01 BOCHS  BXPCRSDT 00000001 BXPC 00000001)
[    0.000000] ACPI: FACP 0x00000000BFFE180A 000074 (v01 BOCHS  BXPCFACP 00000001 BXPC 00000001)
[    0.000000] ACPI: DSDT 0x00000000BFFE0040 0017CA (v01 BOCHS  BXPCDSDT 00000001 BXPC 00000001)
[    0.000000] ACPI: FACS 0x00000000BFFE0000 000040
[    0.000000] ACPI: APIC 0x00000000BFFE187E 000080 (v01 BOCHS  BXPCAPIC 00000001 BXPC 00000001)
[    0.000000] ACPI: HPET 0x00000000BFFE18FE 000038 (v01 BOCHS  BXPCHPET 00000001 BXPC 00000001)
[    0.000000] kvm-clock: Using msrs 4b564d01 and 4b564d00
[    0.000000] kvm-clock: cpu 0, msr 1:3f800001, primary cpu clock
[    0.000000] kvm-clock: using sched offset of 392391616 cycles
[    0.000000] clocksource: kvm-clock: mask: 0xffffffffffffffff max_cycles: 0x1cd42e4dffb, max_idle_ns: 881590591483 ns
[    0.000000] Zone ranges:
[    0.000000]   DMA      [mem 0x0000000000001000-0x0000000000ffffff]
[    0.000000]   DMA32    [mem 0x0000000001000000-0x00000000ffffffff]
[    0.000000]   Normal   [mem 0x0000000100000000-0x000000013fffffff]
[    0.000000]   Device   empty
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x0000000000001000-0x000000000009efff]
[    0.000000]   node   0: [mem 0x0000000000100000-0x00000000bffdffff]
[    0.000000]   node   0: [mem 0x0000000100000000-0x000000013fffffff]
[    0.000000] Initmem setup node 0 [mem 0x0000000000001000-0x000000013fffffff]
[    0.000000] ACPI: PM-Timer IO Port: 0x608
[    0.000000] APIC: NR_CPUS/possible_cpus limit of 1 reached. Processor 1/0x1 ignored.
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0xff] dfl dfl lint[0x1])
[    0.000000] IOAPIC[0]: apic_id 0, version 17, address 0xfec00000, GSI 0-23
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 5 global_irq 5 high level)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 10 global_irq 10 high level)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 11 global_irq 11 high level)
[    0.000000] Using ACPI (MADT) for SMP configuration information
[    0.000000] ACPI: HPET id: 0x8086a201 base: 0xfed00000
[    0.000000] KVM setup async PF for cpu 0
[    0.000000] kvm-stealtime: cpu 0, msr 2835b80
[    0.000000] e820: [mem 0xc0000000-0xfeffbfff] available for PCI devices
[    0.000000] Booting paravirtualized kernel on KVM
[    0.000000] clocksource: refined-jiffies: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 1910969940391419 ns
[    0.000000] Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 1032041
[    0.000000] Kernel command line:
[    0.000000] PID hash table entries: 4096 (order: 3, 32768 bytes)
[    0.000000] Dentry cache hash table entries: 524288 (order: 10, 4194304 bytes)
[    0.000000] Inode-cache hash table entries: 262144 (order: 9, 2097152 bytes)
[    0.000000] Memory: 3984732K/4193784K available (14425K kernel code, 5327K rwdata, 6352K rodata, 1188K init, 30876K bss, 209052K reserved, 0K cma-reserved)
[    0.000000] SLUB: HWalign=64, Order=0-3, MinObjects=0, CPUs=1, Nodes=1
[    0.000000] Running RCU self tests
[    0.000000] Preemptible hierarchical RCU implementation.
[    0.000000]  RCU debugfs-based tracing is enabled.
[    0.000000]  RCU lockdep checking is enabled.
[    0.000000]  Build-time adjustment of leaf fanout to 64.
[    0.000000] NR_IRQS:4352 nr_irqs:48 16
[    0.000000] console [ttyS0] enabled
[    0.000000] Lock dependency validator: Copyright (c) 2006 Red Hat, Inc., Ingo Molnar
[    0.000000] ... MAX_LOCKDEP_SUBCLASSES:  8
[    0.000000] ... MAX_LOCK_DEPTH:          48
[    0.000000] ... MAX_LOCKDEP_KEYS:        8191
[    0.000000] ... CLASSHASH_SIZE:          4096
[    0.000000] ... MAX_LOCKDEP_ENTRIES:     32768
[    0.000000] ... MAX_LOCKDEP_CHAINS:      65536
[    0.000000] ... CHAINHASH_SIZE:          32768
[    0.000000]  memory used by lock dependency info: 8671 kB
[    0.000000]  per task-struct memory footprint: 2688 bytes
[    0.000000] ODEBUG: selftest passed
[    0.000000] clocksource: hpet: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 19112604467 ns
[    0.000000] tsc: Detected 3066.410 MHz processor
[    0.536791] Calibrating delay loop (skipped) preset value.. 6132.82 BogoMIPS (lpj=3066410)
[    0.537681] pid_max: default: 32768 minimum: 301
[    0.538229] ACPI: Core revision 20160831
[    0.544467] ACPI: 1 ACPI AML tables successfully acquired and loaded

[    0.545432] Mount-cache hash table entries: 8192 (order: 4, 65536 bytes)
[    0.546161] Mountpoint-cache hash table entries: 8192 (order: 4, 65536 bytes)
[    0.547747] Last level iTLB entries: 4KB 0, 2MB 0, 4MB 0
[    0.548330] Last level dTLB entries: 4KB 0, 2MB 0, 4MB 0, 1GB 0
[    0.548963] CPU: Intel(R) Xeon(R) CPU           W3550  @ 3.07GHz (family: 0x6, model: 0x1a, stepping: 0x5)
[    0.554043] Performance Events: Nehalem events, Intel PMU driver.
[    0.554913] core: CPUID marked event: 'bus cycles' unavailable
[    0.555592] ... version:                2
[    0.555987] ... bit width:              48
[    0.556399] ... generic registers:      4
[    0.556794] ... value mask:             0000ffffffffffff
[    0.557283] ... max period:             000000007fffffff
[    0.557803] ... fixed-purpose events:   3
[    0.558217] ... event mask:             000000070000000f
[    0.562333] ..TIMER: vector=0x30 apic1=0 pin1=2 apic2=-1 pin2=-1
[    0.563535] devtmpfs: initialized
[    0.564173] x86/mm: Memory block size: 128MB
[    0.568480] clocksource: jiffies: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 1911260446275000 ns
[    0.569661] atomic64_test: passed for x86-64 platform with CX8 and with SSE
[    0.570383] pinctrl core: initialized pinctrl subsystem
[    0.571539] regulator-dummy: Failed to create debugfs directory
[    0.572738] NET: Registered protocol family 16
[    0.577282] cpuidle: using governor menu
[    0.577836] ACPI: bus type PCI registered
[    0.578251] acpiphp: ACPI Hot Plug PCI Controller Driver version: 0.5
[    0.579116] PCI: Using configuration type 1 for base access
[    0.614842] HugeTLB registered 2 MB page size, pre-allocated 0 pages
[    0.616190] ACPI: Added _OSI(Module Device)
[    0.616644] ACPI: Added _OSI(Processor Device)
[    0.617109] ACPI: Added _OSI(3.0 _SCP Extensions)
[    0.617586] ACPI: Added _OSI(Processor Aggregator Device)
[    0.623687] ACPI: Interpreter enabled
[    0.624110] ACPI: (supports S0 S5)
[    0.624459] ACPI: Using IOAPIC for interrupt routing
[    0.625043] PCI: Using host bridge windows from ACPI; if necessary, use "pci=nocrs" and report a bug
[    0.641620] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-ff])
[    0.642306] acpi PNP0A03:00: _OSC: OS supports [Segments]
[    0.642910] acpi PNP0A03:00: _OSC failed (AE_NOT_FOUND); disabling ASPM
[    0.643598] acpi PNP0A03:00: fail to add MMCONFIG information, can't access extended PCI configuration space under this bridge.
[    0.645212] acpiphp: Slot [3] registered
[    0.645723] acpiphp: Slot [4] registered
[    0.646249] acpiphp: Slot [5] registered
[    0.646768] acpiphp: Slot [6] registered
[    0.647280] acpiphp: Slot [7] registered
[    0.647795] acpiphp: Slot [8] registered
[    0.648309] acpiphp: Slot [9] registered
[    0.648809] acpiphp: Slot [10] registered
[    0.649350] acpiphp: Slot [11] registered
[    0.649863] acpiphp: Slot [12] registered
[    0.650396] acpiphp: Slot [13] registered
[    0.650913] acpiphp: Slot [14] registered
[    0.651434] acpiphp: Slot [15] registered
[    0.651957] acpiphp: Slot [16] registered
[    0.652478] acpiphp: Slot [17] registered
[    0.652993] acpiphp: Slot [18] registered
[    0.653526] acpiphp: Slot [19] registered
[    0.654037] acpiphp: Slot [20] registered
[    0.654564] acpiphp: Slot [21] registered
[    0.655071] acpiphp: Slot [22] registered
[    0.655600] acpiphp: Slot [23] registered
[    0.656126] acpiphp: Slot [24] registered
[    0.656649] acpiphp: Slot [25] registered
[    0.657159] acpiphp: Slot [26] registered
[    0.657693] acpiphp: Slot [27] registered
[    0.658212] acpiphp: Slot [28] registered
[    0.658754] acpiphp: Slot [29] registered
[    0.659270] acpiphp: Slot [30] registered
[    0.659794] acpiphp: Slot [31] registered
[    0.660228] PCI host bridge to bus 0000:00
[    0.660640] pci_bus 0000:00: root bus resource [io  0x0000-0x0cf7 window]
[    0.661334] pci_bus 0000:00: root bus resource [io  0x0d00-0xffff window]
[    0.662006] pci_bus 0000:00: root bus resource [mem 0x000a0000-0x000bffff window]
[    0.662798] pci_bus 0000:00: root bus resource [mem 0xc0000000-0xfebfffff window]
[    0.663559] pci_bus 0000:00: root bus resource [bus 00-ff]
[    0.669631] pci 0000:00:01.1: legacy IDE quirk: reg 0x10: [io  0x01f0-0x01f7]
[    0.670368] pci 0000:00:01.1: legacy IDE quirk: reg 0x14: [io  0x03f6]
[    0.671033] pci 0000:00:01.1: legacy IDE quirk: reg 0x18: [io  0x0170-0x0177]
[    0.671739] pci 0000:00:01.1: legacy IDE quirk: reg 0x1c: [io  0x0376]
[    0.673320] pci 0000:00:01.3: quirk: [io  0x0600-0x063f] claimed by PIIX4 ACPI
[    0.674074] pci 0000:00:01.3: quirk: [io  0x0700-0x070f] claimed by PIIX4 SMB
[    0.704243] ACPI: PCI Interrupt Link [LNKA] (IRQs 5 *10 11)
[    0.705282] ACPI: PCI Interrupt Link [LNKB] (IRQs 5 *10 11)
[    0.706965] ACPI: PCI Interrupt Link [LNKC] (IRQs 5 10 *11)
[    0.708079] ACPI: PCI Interrupt Link [LNKD] (IRQs 5 10 *11)
[    0.708916] ACPI: PCI Interrupt Link [LNKS] (IRQs *9)
[    0.711431] vgaarb: setting as boot device: PCI:0000:00:02.0
[    0.712022] vgaarb: device added: PCI:0000:00:02.0,decodes=io+mem,owns=io+mem,locks=none
[    0.712860] vgaarb: loaded
[    0.713144] vgaarb: bridge control possible 0000:00:02.0
[    0.714679] ACPI: bus type USB registered
[    0.715206] usbcore: registered new interface driver usbfs
[    0.715814] usbcore: registered new interface driver hub
[    0.716444] usbcore: registered new device driver usb
[    0.717175] pps_core: LinuxPPS API ver. 1 registered
[    0.717700] pps_core: Software ver. 5.3.6 - Copyright 2005-2007 Rodolfo Giometti <giometti@linux.it>
[    0.718627] PTP clock support registered
[    0.719434] FPGA manager framework
[    0.719825] PCI: Using ACPI for IRQ routing
[    0.721098] NET: Registered protocol family 23
[    0.721651] NET: Registered protocol family 8
[    0.722109] NET: Registered protocol family 20
[    0.722857] workqueue: round-robin CPU selection forced, expect performance impact
[    0.723973] nfc: nfc_init: NFC Core ver 0.1
[    0.724461] NET: Registered protocol family 39
[    0.725002] clocksource: Switched to clocksource kvm-clock
[    0.727501] Warning: could not register annotated branches stats
[    0.778806] VFS: Disk quotas dquot_6.6.0
[    0.779326] VFS: Dquot-cache hash table entries: 512 (order 0, 4096 bytes)
[    0.780221] FS-Cache: Loaded
[    0.780775] pnp: PnP ACPI init
[    0.783057] pnp: PnP ACPI: found 6 devices
[    0.789020] clocksource: acpi_pm: mask: 0xffffff max_cycles: 0xffffff, max_idle_ns: 2085701024 ns
[    0.790375] NET: Registered protocol family 2
[    0.791521] TCP established hash table entries: 32768 (order: 6, 262144 bytes)
[    0.793882] TCP bind hash table entries: 32768 (order: 9, 2621440 bytes)
[    0.797484] TCP: Hash tables configured (established 32768 bind 32768)
[    0.798458] UDP hash table entries: 2048 (order: 6, 393216 bytes)
[    0.799584] UDP-Lite hash table entries: 2048 (order: 6, 393216 bytes)
[    0.800866] NET: Registered protocol family 1
[    0.801357] pci 0000:00:00.0: Limiting direct PCI/PCI transfers
[    0.801983] pci 0000:00:01.0: PIIX3: Enabling Passive Release
[    0.802604] pci 0000:00:01.0: Activating ISA DMA hang workarounds
[    0.803291] pci 0000:00:02.0: Video device with shadowed ROM at [mem 0x000c0000-0x000dffff]
[    0.804490] PCI-DMA: Using software bounce buffering for IO (SWIOTLB)
[    0.805200] software IO TLB [mem 0xbbfe0000-0xbffe0000] (64MB) mapped at [ffff8800bbfe0000-ffff8800bffdffff]
[    0.809208] PCLMULQDQ-NI instructions are not detected.
[    0.810244] AVX or AES-NI instructions are not detected.
[    0.810793] CPU feature 'AVX registers' is not supported.
[    0.811356] CPU feature 'AVX registers' is not supported.
[    0.811898] CPU feature 'AVX registers' is not supported.
[    0.812449] AVX2 or AES-NI instructions are not detected.
[    0.812997] AVX2 instructions are not detected.
[    0.813748] spin_lock-torture:--- Start of test [debug]: nwriters_stress=2 nreaders_stress=0 stat_interval=60 verbose=1 shuffle_interval=3 stutter=5 shutdown_secs=0 onoff_interval=0 onoff_holdoff=0
[    0.815524] spin_lock-torture: Creating torture_shuffle task
[    0.816195] spin_lock-torture: Creating torture_stutter task
[    0.816810] spin_lock-torture: torture_shuffle task started
[    0.817444] spin_lock-torture: Creating lock_torture_writer task
[    0.818119] spin_lock-torture: torture_stutter task started
[    0.818699] spin_lock-torture: Creating lock_torture_writer task
[    0.819375] spin_lock-torture: lock_torture_writer task started
[    0.819990] spin_lock-torture: Creating lock_torture_stats task
[    0.820648] spin_lock-torture: lock_torture_writer task started
[    0.821332] torture_init_begin: Refusing rcu init: spin_lock running.
[    0.821982] torture_init_begin: One torture test at a time!
[    0.823277] futex hash table entries: 256 (order: 2, 24576 bytes)
[    0.824492] spin_lock-torture: lock_torture_stats task started
[    0.825173] workingset: timestamp_bits=62 max_order=20 bucket_order=0
[    0.834987] DLM installed
[    0.835333] jffs2: version 2.2. (NAND) © 2001-2006 Red Hat, Inc.
[    0.836561] fuse init (API version 7.26)
[    0.842399] NET: Registered protocol family 38
[    0.851293] test_hexdump: all 1184 tests passed
[    0.851977] test_firmware: interface ready
[    0.857079] test_hash: __hash_32() has no arch implementation to test.
[    0.857745] test_hash: hash_32() has no arch implementation to test.
[    0.858393] test_hash: hash_64() has no arch implementation to test.
[    0.859049] test_hash: 33152 tests passed.
[    0.859523] Running rhashtable test nelem=8, max_size=0, shrinking=0
[    0.860170] Test 00:
[    0.866634]   Adding 50000 keys
[    1.021610]   Traversal complete: counted=50000, nelems=50000, entries=50000, table-jumps=0
[    1.102033]   Traversal complete: counted=50000, nelems=50000, entries=50000, table-jumps=0
[    1.102969]   Deleting 50000 keys
[    1.165948]   Duration of test: 298904999 ns
[    1.166886] Test 01:
[    1.169132]   Adding 50000 keys
[    1.326776]   Traversal complete: counted=50000, nelems=50000, entries=50000, table-jumps=0
[    1.409811]   Traversal complete: counted=50000, nelems=50000, entries=50000, table-jumps=0
[    1.410716]   Deleting 50000 keys
[    1.473728]   Duration of test: 304225252 ns
[    1.474643] Test 02:
[    1.476793]   Adding 50000 keys
[    1.633313]   Traversal complete: counted=50000, nelems=50000, entries=50000, table-jumps=0
[    1.716856]   Traversal complete: counted=50000, nelems=50000, entries=50000, table-jumps=0
[    1.717751]   Deleting 50000 keys
[    1.778047]   Duration of test: 300851231 ns
[    1.778901] Test 03:
[    1.780666]   Adding 50000 keys
[    1.811687] tsc: Refined TSC clocksource calibration: 3066.645 MHz
[    1.814050] clocksource: tsc: mask: 0xffffffffffffffff max_cycles: 0x2c343292001, max_idle_ns: 440795316307 ns
[    1.935093]   Traversal complete: counted=50000, nelems=50000, entries=50000, table-jumps=0
[    2.011217]   Traversal complete: counted=50000, nelems=50000, entries=50000, table-jumps=0
[    2.012075]   Deleting 50000 keys
[    2.072037]   Duration of test: 290956402 ns
[    2.072895] Average test time: 298734471
[    2.073316] Testing concurrent rhashtable access from 10 threads
[    8.052590] Started 10 threads, 0 failed
[    8.063120] test_printf: all 260 tests passed
[    8.111388] test_bitmap: all 460506 tests passed
[    8.111909] test_uuid: all 18 tests passed
[    8.113554] crc32: CRC_LE_BITS = 8, CRC_BE BITS = 8
[    8.114075] crc32: self tests passed, processed 225944 bytes in 555434 nsec
[    8.115294] crc32c: CRC_LE_BITS = 8
[    8.115650] crc32c: self tests passed, processed 225944 bytes in 251011 nsec
[    8.143783] crc32_combine: 8373 self tests passed
[    8.171662] crc32c_combine: 8373 self tests passed
[    8.172431] rbtree testing
[    8.791825]  -> 18984 cycles
[    8.873434] augmented rbtree testing
[    9.690889]  -> 25055 cycles
[    9.795388] gpio-mockup: probe of gpio-mockup failed with error -22
[    9.796434] pci_hotplug: PCI Hot Plug PCI Core version: 0.5
[    9.796999] cpcihp_zt5550: ZT5550 CompactPCI Hot Plug Driver version: 0.2
[    9.801677] acpiphp_ibm: ibm_acpiphp_init: acpi_walk_namespace failed
[    9.802793] cr_bllcd: INTEL CARILLO RANCH LPC not found.
[    9.803373] cr_bllcd: Carillo Ranch Backlight Driver Initialized.
[    9.804628] Could not find Carillo Ranch MCH device.
[    9.805224] no IO addresses supplied
[    9.805918] usbcore: registered new interface driver udlfb
[    9.806529] usbcore: registered new interface driver smscufx
[    9.807783] uvesafb: failed to execute /sbin/v86d
[    9.808291] uvesafb: make sure that the v86d helper is installed and executable
[    9.809057] uvesafb: Getting VBE info block failed (eax=0x4f00, err=-2)
[    9.809736] uvesafb: vbe_init() failed with -22
[    9.810238] uvesafb: probe of uvesafb.0 failed with error -22
[    9.811183] input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/input/input0
[    9.811935] ACPI: Power Button [PWRF]
[    9.812625] button: probe of LNXPWRBN:00 failed with error -22
[    9.813401] Warning: Processor Platform Limit event detected, but not handled.
[    9.814175] Consider compiling CPUfreq support into your kernel.
[    9.815382] EINJ: EINJ table not found.
[    9.815789] ERST DBG: ERST support is disabled.
[    9.851332] Serial: 8250/16550 driver, 4 ports, IRQ sharing enabled
[    9.875170] 00:05: ttyS0 at I/O 0x3f8 (irq = 4, base_baud = 115200) is a 16550A
[    9.876733] console [ttyS0] disabled
[    9.900211] 00:05: ttyS0 at I/O 0x3f8 (irq = 4, base_baud = 115200) is a 16550A
[   10.080592] console [ttyS0] enabled
[   10.084322] Initializing Nozomi driver 2.1d
[   10.084992] Applicom driver: $Id: ac.c,v 1.30 2000/03/22 16:03:57 dwmw2 Exp $
[   10.085764] ac.o: No PCI boards found.
[   10.086172] ac.o: For an ISA board you must supply memory and irq parameters.
[   10.086984] Non-volatile memory driver v1.3
[   10.087618] smapi::smapi_init, ERROR invalid usSmapiID
[   10.088151] mwave: tp3780i::tp3780I_InitializeBoardData: Error: SMAPI is not available on this machine
[   10.089119] mwave: mwavedd::mwave_init: Error: Failed to initialize board data
[   10.089843] mwave: mwavedd::mwave_init: Error: Failed to initialize
[   10.090505] Linux agpgart interface v0.103
[   10.091408] Hangcheck: starting hangcheck timer 0.9.1 (tick is 180 seconds, margin is 60 seconds).
[   10.092636] intelfb: Framebuffer driver for Intel(R) 830M/845G/852GM/855GM/865G/915G/915GM/945G/945GM/945GME/965G/965GM chipsets
[   10.093856] intelfb: Version 0.9.6
[   10.094549] ibmasm: IBM ASM Service Processor Driver version 1.0 loaded
[   10.095289] dummy-irq: no IRQ given.  Use irq=N
[   10.095874] Phantom Linux Driver, version n0.9.8, init OK
[   10.096602] Silicon Labs C2 port support v. 0.51.0 - (C) 2007 Rodolfo Giometti
[   10.097502] c2port c2port0: C2 port uc added
[   10.097937] c2port c2port0: uc flash has 30 blocks x 512 bytes (15360 bytes total)
[   10.100098] usbcore: registered new interface driver viperboard
[   10.100807] usbcore: registered new interface driver dln2
[   10.101639] usbcore: registered new interface driver nfcmrvl
[   10.102519] mtdoops: mtd device (mtddev=name/number) must be supplied
[   10.103240] SBC-GXx flash: IO:0x258-0x259 MEM:0xdc000-0xdffff
[   10.104054] slram: not enough parameters.
[   10.134629] No valid DiskOnChip devices found
[   10.135151] [nandsim] warning: read_byte: unexpected data output cycle, state is STATE_READY return 0x0
[   10.136109] [nandsim] warning: read_byte: unexpected data output cycle, state is STATE_READY return 0x0
[   10.137063] [nandsim] warning: read_byte: unexpected data output cycle, state is STATE_READY return 0x0
[   10.137997] [nandsim] warning: read_byte: unexpected data output cycle, state is STATE_READY return 0x0
[   10.138977] [nandsim] warning: read_byte: unexpected data output cycle, state is STATE_READY return 0x0
[   10.139940] [nandsim] warning: read_byte: unexpected data output cycle, state is STATE_READY return 0x0
[   10.140911] nand: device found, Manufacturer ID: 0x98, Chip ID: 0x39
[   10.141568] nand: Toshiba NAND 128MiB 1,8V 8-bit
[   10.142045] nand: 128 MiB, SLC, erase size: 16 KiB, page size: 512, OOB size: 16
[   10.142842] flash size: 128 MiB
[   10.143184] page size: 512 bytes
[   10.143517] OOB area size: 16 bytes
[   10.143868] sector size: 16 KiB
[   10.144196] pages number: 262144
[   10.144532] pages per sector: 32
[   10.144862] bus width: 8
[   10.145139] bits in sector size: 14
[   10.145498] bits in page size: 9
[   10.145822] bits in OOB size: 4
[   10.146150] flash size with OOB: 135168 KiB
[   10.146571] page address bytes: 4
[   10.146925] sector address bytes: 3
[   10.147297] options: 0x42
[   10.149421] Scanning device for bad blocks
[   10.175870] Creating 1 MTD partitions on "NAND 128MiB 1,8V 8-bit":
[   10.176553] 0x000000000000-0x000008000000 : "NAND simulator partition 0"
[   10.186483] Ethernet Channel Bonding Driver: v3.7.1 (April 27, 2011)
[   10.188865] MACsec IEEE 802.1AE
[   10.191840] libphy: mdio_driver_register: xgmiitorgmii
[   10.192447] tun: Universal TUN/TAP device driver, 1.6
[   10.192966] tun: (C) 1999-2004 Max Krasnyansky <maxk@qualcomm.com>
[   10.193776] arcnet: arcnet loaded
[   10.194175] arcnet:rfc1201: RFC1201 "standard" (`a') encapsulation support loaded
[   10.194962] arcnet:rfc1051: RFC1051 "simple standard" (`s') encapsulation support loaded
[   10.195887] arcnet:arc_rawmode: raw mode (`r') encapsulation support loaded
[   10.196674] arcnet:capmode: cap mode (`c') encapsulation support loaded
[   10.197362] arcnet:com90xx: COM90xx chipset support
[   10.501754] S3: No ARCnet cards found.
[   10.502196] arcnet:com20020_pci: COM20020 PCI support
[   10.502999] libphy: mdio_driver_register: bcm53xx
[   10.503605] libphy: mdio_driver_register: mv88e6085
[   10.504154] e1000: Intel(R) PRO/1000 Network Driver - version 7.3.21-k8-NAPI
[   10.504862] e1000: Copyright (c) 1999-2006 Intel Corporation.
[   10.755199] ACPI: PCI Interrupt Link [LNKC] enabled at IRQ 11
[   11.062352] e1000 0000:00:03.0 eth0: (PCI:33MHz:32-bit) 52:54:00:12:34:56
[   11.063106] e1000 0000:00:03.0 eth0: Intel(R) PRO/1000 Network Connection
[   11.911843] e1000 0000:00:03.0 eth0: (PCI:33MHz:32-bit) 52:54:00:12:34:56
[   11.912870] e1000 0000:00:03.0 eth0: Intel(R) PRO/1000 Network Connection
[   11.913903] e1000e: Intel(R) PRO/1000 Network Driver - 3.2.6-k
[   11.914721] e1000e: Copyright(c) 1999 - 2015 Intel Corporation.
[   11.915643] igb: Intel(R) Gigabit Ethernet Network Driver - version 5.4.0-k
[   11.916636] igb: Copyright (c) 2007-2014 Intel Corporation.
[   11.917525] ixgbe: Intel(R) 10 Gigabit PCI Express Network Driver - version 4.4.0-k
[   11.918613] ixgbe: Copyright (c) 1999-2016 Intel Corporation.
[   11.919920] usbcore: registered new interface driver irda-usb
[   11.920833] usbcore: registered new interface driver stir4200
[   11.922565] usbcore: registered new interface driver mcs7780
[   11.923573] usbcore: registered new interface driver ks959-sir
[   11.924407] PPP generic driver version 2.4.2
[   11.925319] PPP BSD Compression module registered
[   11.925994] PPP Deflate Compression module registered
[   11.926718] PPP MPPE Compression module registered
[   11.927389] NET: Registered protocol family 24
[   11.928055] ipw2100: Intel(R) PRO/Wireless 2100 Network Driver, git-1.2.2
[   11.928984] ipw2100: Copyright(c) 2003-2006 Intel Corporation
[   11.929928] ipw2200: Intel(R) PRO/Wireless 2200/2915 Network Driver, 1.2.2kd
[   11.930941] ipw2200: Copyright(c) 2003-2006 Intel Corporation
[   11.931873] libipw: 802.11 data/management/control stack, git-1.1.13
[   11.932839] libipw: Copyright (C) 2004-2005 Intel Corporation <jketreno@linux.intel.com>
[   11.933988] iwl4965: Intel(R) Wireless WiFi 4965 driver for Linux, in-tree:d
[   11.934978] iwl4965: Copyright(c) 2003-2011 Intel Corporation
[   11.935908] iwl3945: Intel(R) PRO/Wireless 3945ABG/BG Network Connection driver for Linux, in-tree:ds
[   11.937187] iwl3945: Copyright(c) 2003-2011 Intel Corporation
[   11.938078] Intel(R) Wireless WiFi driver for Linux
[   11.938754] Copyright(c) 2003- 2015 Intel Corporation
[   11.939806] usbcore: registered new interface driver rt2500usb
[   11.940677] usbcore: registered new interface driver rt2800usb
[   11.941627] usbcore: registered new interface driver rtl8187
[   11.942488] usbcore: registered new interface driver rtl8192cu
[   11.943728] usbcore: registered new interface driver rtl8xxxu
[   11.944585] usbcore: registered new interface driver RSI-USB WLAN
[   11.945249] usbcore: registered new interface driver zd1201
[   11.945920] usbcore: registered new interface driver rndis_wlan
[   11.946619] mac80211_hwsim: initializing netlink
[   11.950718] usbcore: registered new interface driver i2400m_usb
[   11.951433] usbcore: registered new interface driver kaweth
[   11.952097] usbcore: registered new interface driver rtl8150
[   11.952731] usbcore: registered new interface driver r8152
[   11.953371] usbcore: registered new interface driver lan78xx
[   11.953987] usbcore: registered new interface driver ax88179_178a
[   11.954714] usbcore: registered new interface driver cdc_ether
[   11.955693] usbcore: registered new interface driver cdc_eem
[   11.956553] usbcore: registered new interface driver CoreChips
[   11.957425] usbcore: registered new interface driver smsc75xx
[   11.958268] usbcore: registered new interface driver smsc95xx
[   11.959147] usbcore: registered new interface driver net1080
[   11.959992] usbcore: registered new interface driver plusb
[   11.960819] usbcore: registered new interface driver rndis_host
[   11.961726] usbcore: registered new interface driver zaurus
[   11.962608] usbcore: registered new interface driver MOSCHIP usb-ethernet driver
[   11.963716] usbcore: registered new interface driver int51x1
[   11.964552] usbcore: registered new interface driver kalmia
[   11.965402] usbcore: registered new interface driver ipheth
[   11.966255] usbcore: registered new interface driver cdc_ncm
[   11.967095] usbcore: registered new interface driver huawei_cdc_ncm
[   11.967999] usbcore: registered new interface driver lg-vl600
[   11.968868] usbcore: registered new interface driver qmi_wwan
[   11.969763] usbcore: registered new interface driver ch9200
[   11.970543] FUJITSU Extended Socket Network Device Driver - version 1.2 - Copyright (c) 2015 FUJITSU LIMITED
[   11.972291] Madge ATM Horizon [Ultra] driver version 1.2.1
[   11.973078] hrz: debug bitmap is 0
[   11.973703] idt77252_init: at ffffffff82d8626c
[   11.974395] Solos PCI Driver Version 1.04
[   11.976453] usbcore: registered new interface driver hwa-rc
[   11.977335] usbcore: registered new interface driver i1480-dfu-usb
[   11.979042] uhci_hcd: USB Universal Host Controller Interface driver
[   11.980257] driver u132_hcd
[   11.980932] usbcore: registered new interface driver hwa-hc
[   11.982059] usbcore: registered new interface driver cdc_acm
[   11.982882] cdc_acm: USB Abstract Control Model driver for USB modems and ISDN adapters
[   11.983937] usbcore: registered new interface driver cdc_wdm
[   11.984599] usbcore: registered new interface driver mdc800
[   11.985182] mdc800: v0.7.5 (30/10/2000):USB Driver for Mustek MDC800 Digital Camera
[   11.986021] usbcore: registered new interface driver adutux
[   11.986620] usbcore: registered new interface driver appledisplay
[   11.987282] usbcore: registered new interface driver emi26 - firmware loader
[   11.988068] usbcore: registered new interface driver emi62 - firmware loader
[   11.988786] ftdi_elan: driver ftdi-elan
[   11.989239] usbcore: registered new interface driver ftdi-elan
[   11.989873] usbcore: registered new interface driver idmouse
[   11.990502] usbcore: registered new interface driver iowarrior
[   11.991162] usbcore: registered new interface driver isight_firmware
[   11.991842] usbcore: registered new interface driver usblcd
[   11.992465] usbcore: registered new interface driver usbtest
[   11.993098] usbcore: registered new interface driver trancevibrator
[   11.993783] usbcore: registered new interface driver usbsevseg
[   11.994429] usbcore: registered new interface driver yurex
[   11.995187] usbcore: registered new interface driver chaoskey
[   11.995825] usbcore: registered new interface driver sisusb
[   11.996715] dummy_hcd dummy_hcd.0: USB Host+Gadget Emulator, driver 02 May 2005
[   11.997541] dummy_hcd dummy_hcd.0: Dummy host controller
[   11.998366] dummy_hcd dummy_hcd.0: new USB bus registered, assigned bus number 1
[   12.000128] hub 1-0:1.0: USB hub found
[   12.000606] hub 1-0:1.0: 1 port detected
[   12.001315] hub 1-0:1.0: USB hub found
[   12.001724] hub 1-0:1.0: 1 port detected
[   12.002893] hub 1-0:1.0: USB hub found
[   12.003331] hub 1-0:1.0: 1 port detected
[   12.003896] hub 1-0:1.0: USB hub found
[   12.004327] hub 1-0:1.0: 1 port detected
[   12.004941] dummy_hcd dummy_hcd.0: remove, state 1
[   12.005512] usb usb1: USB disconnect, device number 1
[   12.006932] dummy_hcd dummy_hcd.0: stopped
[   12.007390] dummy_hcd dummy_hcd.0: USB bus 1 deregistered
[   12.008315] dummy_hcd dummy_hcd.0: USB Host+Gadget Emulator, driver 02 May 2005
[   12.009090] dummy_hcd dummy_hcd.0: Dummy host controller
[   12.009749] dummy_hcd dummy_hcd.0: new USB bus registered, assigned bus number 1
[   12.011074] hub 1-0:1.0: USB hub found
[   12.011491] hub 1-0:1.0: 1 port detected
[   12.012062] hub 1-0:1.0: USB hub found
[   12.012478] hub 1-0:1.0: 1 port detected
[   12.013387] hub 1-0:1.0: USB hub found
[   12.013802] hub 1-0:1.0: 1 port detected
[   12.014386] hub 1-0:1.0: USB hub found
[   12.014813] hub 1-0:1.0: 1 port detected
[   12.016189] kobject (ffff880139f60f78): tried to init an initialized object, something is seriously wrong.
[   12.017218] CPU: 0 PID: 1 Comm: swapper Not tainted 4.8.0-14895-gaf1fee9 #4
[   12.017925] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS rel-1.9.3-0-ge2fc41e-prebuilt.qemu-project.org 04/01/2014
[   12.019116]  ffff88013a8f3ba0 ffffffff812cf3c2 ffff88013a8f3bc0 ffffffff812d1719
[   12.019917]  ffff880139f60f68 ffff880139f60ed8 ffff88013a8f3bd8 ffffffff81453f4f
[   12.020734]  ffff880139f60f68 ffff88013a8f3bf0 ffffffff814547a5 ffff880138fea000
[   12.021547] Call Trace:
[   12.021825]  [<ffffffff812cf3c2>] dump_stack+0x19/0x1b
[   12.022359]  [<ffffffff812d1719>] kobject_init+0x31/0x7f
[   12.022913]  [<ffffffff81453f4f>] device_initialize+0x23/0xd2
[   12.023501]  [<ffffffff814547a5>] device_register+0xd/0x18
[   12.024079]  [<ffffffff8188a707>] usb_add_gadget_udc_release+0xc5/0x2c9
[   12.024738]  [<ffffffff8188a984>] usb_add_gadget_udc+0xb/0xd
[   12.025338]  [<ffffffff8188d715>] dummy_udc_probe+0x19e/0x1df
[   12.025922]  [<ffffffff814590da>] platform_drv_probe+0x23/0x4e
[   12.026514]  [<ffffffff81457daa>] driver_probe_device+0x1d6/0x407
[   12.027146]  [<ffffffff81458153>] __device_attach_driver+0x90/0xd0
[   12.027763]  [<ffffffff814580c3>] ? driver_allows_async_probing+0xd/0xd
[   12.028445]  [<ffffffff81456623>] bus_for_each_drv+0x7a/0x84
[   12.029035]  [<ffffffff81457aae>] __device_attach+0x89/0xe7
[   12.029599]  [<ffffffff814582a3>] device_initial_probe+0xe/0x10
[   12.030207]  [<ffffffff814567de>] bus_probe_device+0x2e/0x99
[   12.030796]  [<ffffffff814546a2>] device_add+0x3f0/0x4e6
[   12.031336]  [<ffffffff814596f6>] platform_device_add+0x16d/0x1c6
[   12.031965]  [<ffffffff82d88e57>] init+0x264/0x366
[   12.032466]  [<ffffffff82d88bf3>] ? trace_event_define_fields_udc_log_req+0x205/0x205
[   12.033291]  [<ffffffff82d3606c>] do_one_initcall+0x88/0x145
[   12.033867]  [<ffffffff82d36243>] kernel_init_freeable+0x11a/0x19b
[   12.034533]  [<ffffffff81e03615>] ? rest_init+0x12c/0x12c
[   12.035094]  [<ffffffff81e0361e>] kernel_init+0x9/0xeb
[   12.035615]  [<ffffffff81e13c4a>] ret_from_fork+0x2a/0x40
[   12.037044] using random self ethernet address
[   12.037535] using random host ethernet address
[   12.038591] usb0: HOST MAC c2:67:1d:81:f8:d0
[   12.039090] usb0: MAC 2e:61:a3:83:46:0a
[   12.039523] g_ether gadget: Ethernet Gadget, version: Memorial Day 2008
[   12.040221] g_ether gadget: g_ether ready
[   12.040655] usbip_core: USB/IP Core v1.0.0
[   12.041399] vhci_hcd vhci_hcd: USB/IP Virtual Host Controller
[   12.042152] vhci_hcd vhci_hcd: new USB bus registered, assigned bus number 2
[   12.042921] BUG: key ffff880139658eb8 not in .data!
[   12.043465] ------------[ cut here ]------------
[   12.043967] WARNING: CPU: 0 PID: 1 at ../kernel/locking/lockdep.c:3131 lockdep_init_map+0x119/0x1ca
[   12.044864] DEBUG_LOCKS_WARN_ON(1)[   12.045220] CPU: 0 PID: 1 Comm: swapper Not tainted 4.8.0-14895-gaf1fee9 #4
[   12.045956] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS rel-1.9.3-0-ge2fc41e-prebuilt.qemu-project.org 04/01/2014
[   12.047165]  ffff88013a8f39e0 ffffffff812cf3c2 ffff88013a8f3a20 ffffffff8109dd32
[   12.047957]  00000c3b3a8f3a98 ffff880138ff04a0 ffff880139658eb8 0000000000001000
[   12.048768]  0000000000000000 0000000000000000 ffff88013a8f3a88 ffffffff8109dd93
[   12.049570] Call Trace:
[   12.049835]  [<ffffffff812cf3c2>] dump_stack+0x19/0x1b
[   12.050369]  [<ffffffff8109dd32>] __warn+0xb6/0xd1
[   12.050865]  [<ffffffff8109dd93>] warn_slowpath_fmt+0x46/0x4e
[   12.051448]  [<ffffffff810d2b6f>] lockdep_init_map+0x119/0x1ca
[   12.052077]  [<ffffffff8123c4e1>] __kernfs_create_file+0x75/0xc3
[   12.052685]  [<ffffffff8123cc8f>] sysfs_add_file_mode_ns+0xf3/0x1c8
[   12.053327]  [<ffffffff8123d8da>] internal_create_group+0x210/0x364
[   12.053963]  [<ffffffff8123da3c>] sysfs_create_group+0xe/0x10
[   12.054561]  [<ffffffff818be100>] vhci_start+0x193/0x1e8
[   12.055120]  [<ffffffff817fdc65>] usb_add_hcd+0x57b/0x8a7
[   12.055681]  [<ffffffff818bcfbc>] vhci_hcd_probe+0x63/0xcd
[   12.056244]  [<ffffffff814590da>] platform_drv_probe+0x23/0x4e
[   12.056836]  [<ffffffff81457daa>] driver_probe_device+0x1d6/0x407
[   12.057472]  [<ffffffff81458153>] __device_attach_driver+0x90/0xd0
[   12.058138]  [<ffffffff814580c3>] ? driver_allows_async_probing+0xd/0xd
[   12.058818]  [<ffffffff81456623>] bus_for_each_drv+0x7a/0x84
[   12.059417]  [<ffffffff81457aae>] __device_attach+0x89/0xe7
[   12.059982]  [<ffffffff814582a3>] device_initial_probe+0xe/0x10
[   12.060625]  [<ffffffff814567de>] bus_probe_device+0x2e/0x99
[   12.061216]  [<ffffffff814546a2>] device_add+0x3f0/0x4e6
[   12.061757]  [<ffffffff811b8cfa>] ? kfree+0xfe/0x3b1
[   12.062272]  [<ffffffff814596f6>] platform_device_add+0x16d/0x1c6
[   12.062899]  [<ffffffff814598fb>] platform_device_register_full+0xae/0x104
[   12.063600]  [<ffffffff82d891b5>] vhci_hcd_init+0xbc/0x144
[   12.064160]  [<ffffffff82d890f9>] ? usbip_core_init+0x17/0x17
[   12.064748]  [<ffffffff82d3606c>] do_one_initcall+0x88/0x145
[   12.065343]  [<ffffffff82d36243>] kernel_init_freeable+0x11a/0x19b
[   12.065971]  [<ffffffff81e03615>] ? rest_init+0x12c/0x12c
[   12.066525]  [<ffffffff81e0361e>] kernel_init+0x9/0xeb
[   12.067076]  [<ffffffff81e13c4a>] ret_from_fork+0x2a/0x40
[   12.067633] ---[ end trace 1b4df49b38ba0f1b ]---
[   12.068132] vhci_hcd: created sysfs vhci_hcd
[   12.068925] hub 2-0:1.0: USB hub found
[   12.069369] hub 2-0:1.0: 8 ports detected
[   12.070049] hub 2-0:1.0: USB hub found
[   12.070451] hub 2-0:1.0: 8 ports detected
[   12.071235] hub 2-0:1.0: USB hub found
[   12.071637] hub 2-0:1.0: 8 ports detected
[   12.072284] hub 2-0:1.0: USB hub found
[   12.072699] hub 2-0:1.0: 8 ports detected
[   12.073336] vhci_hcd vhci_hcd: remove, state 1
[   12.073808] usb usb2: USB disconnect, device number 1
[   12.074598] vhci_hcd: stop threads
[   12.074954] vhci_hcd: release socket
[   12.075343] vhci_hcd: disconnect device
[   12.075751] vhci_hcd: stop threads
[   12.076120] vhci_hcd: release socket
[   12.076481] vhci_hcd: disconnect device
[   12.076886] vhci_hcd: stop threads
[   12.077261] vhci_hcd: release socket
[   12.077642] vhci_hcd: disconnect device
[   12.078053] vhci_hcd: stop threads
[   12.078398] vhci_hcd: release socket
[   12.078772] vhci_hcd: disconnect device
[   12.079183] vhci_hcd: stop threads
[   12.079544] vhci_hcd: release socket
[   12.079906] vhci_hcd: disconnect device
[   12.080318] vhci_hcd: stop threads
[   12.080667] vhci_hcd: release socket
[   12.081054] vhci_hcd: disconnect device
[   12.081457] vhci_hcd: stop threads
[   12.081808] vhci_hcd: release socket
[   12.082187] vhci_hcd: disconnect device
[   12.082598] vhci_hcd: stop threads
[   12.082945] vhci_hcd: release socket
[   12.083327] vhci_hcd: disconnect device
[   12.083737] vhci_hcd vhci_hcd: USB bus 2 deregistered
[   12.084397] vhci_hcd vhci_hcd: USB/IP Virtual Host Controller
[   12.085132] vhci_hcd vhci_hcd: new USB bus registered, assigned bus number 2
[   12.085881] BUG: key ffff880139658eb8 not in .data!
[   12.086407] vhci_hcd: created sysfs vhci_hcd
[   12.087153] hub 2-0:1.0: USB hub found
[   12.087567] hub 2-0:1.0: 8 ports detected
[   12.088214] hub 2-0:1.0: USB hub found
[   12.088661] hub 2-0:1.0: 8 ports detected
[   12.089426] hub 2-0:1.0: USB hub found
[   12.089834] hub 2-0:1.0: 8 ports detected
[   12.090471] hub 2-0:1.0: USB hub found
[   12.090906] hub 2-0:1.0: 8 ports detected
[   12.091547] vhci_hcd: USB/IP 'Virtual' Host Controller (VHCI) Driver v1.0.0
[   12.092569] udc usbip-vudc.0: releasing 'usbip-vudc.0'
[   12.093337] i8042: PNP: PS/2 Controller [PNP0303:KBD,PNP0f13:MOU] at 0x60,0x64 irq 1,12
[   12.094879] serio: i8042 KBD port at 0x60,0x64 irq 1
[   12.095460] serio: i8042 AUX port at 0x60,0x64 irq 12
[   12.096694] serio: i8042 KBD port at 0x60,0x64 irq 1
[   12.097279] serio: i8042 AUX port at 0x60,0x64 irq 12
[   12.123046] dummy_hcd dummy_hcd.0: port status 0x00010101 has changes
[   12.137485] mousedev: PS/2 mouse device common for all mice
[   12.138543] input: AT Translated Set 2 keyboard as /devices/platform/i8042/serio2/input/input1
[   12.139452] evbug: Connected device: input1 (AT Translated Set 2 keyboard at isa0060/serio0/input0)
[   12.140682] usbcore: registered new interface driver bcm5974
[   12.141389] usbcore: registered new interface driver synaptics_usb
[   12.142066] usbcore: registered new interface driver usb_acecad
[   12.142700] usbcore: registered new interface driver gtco
[   12.143276] evbug: Disconnected device: input1
[   12.143765] usbcore: registered new interface driver kbtab
[   12.144637] piix4_smbus 0000:00:01.3: SMBus Host Controller at 0x700, revision 0
[   12.146557] input: AT Translated Set 2 keyboard as /devices/platform/i8042/serio2/input/input2
[   12.147451] evbug: Connected device: input2 (AT Translated Set 2 keyboard at isa0060/serio0/input0)
smbus: error: Unexpected recv start condition in state 3
smbus: error: Unexpected read in state -1
smbus: error: Unexpected NACK in state -1
smbus: error: Unexpected NACK in state -1
smbus: error: Unexpected recv start condition in state 3
smbus: error: Unexpected read in state -1
smbus: error: Unexpected NACK in state -1
smbus: error: Unexpected NACK in state -1
smbus: error: Unexpected recv start condition in state 3
smbus: error: Unexpected read in state -1
smbus: error: Unexpected NACK in state -1
smbus: error: Unexpected NACK in state -1
smbus: error: Unexpected recv start condition in state 3
smbus: error: Unexpected read in state -1
smbus: error: Unexpected NACK in state -1
smbus: error: Unexpected NACK in state -1
smbus: error: Unexpected recv start condition in state 3
smbus: error: Unexpected read in state -1
smbus: error: Unexpected NACK in state -1
smbus: error: Unexpected NACK in state -1
smbus: error: Unexpected recv start condition in state 3
smbus: error: Unexpected read in state -1
smbus: error: Unexpected NACK in state -1
smbus: error: Unexpected NACK in state -1
smbus: error: Unexpected recv start condition in state 3
smbus: error: Unexpected read in state -1
smbus: error: Unexpected NACK in state -1
smbus: error: Unexpected NACK in state -1
smbus: error: Unexpected recv start condition in state 3
smbus: error: Unexpected read in state -1
smbus: error: Unexpected NACK in state -1
smbus: error: Unexpected NACK in state -1
[   12.196453] piix4_smbus 0000:00:01.3: SMBus Host Controller at 0x700, revision 0
smbus: error: Unexpected recv start condition in state 3
smbus: error: Unexpected read in state -1
smbus: error: Unexpected NACK in state -1
smbus: error: Unexpected NACK in state -1
smbus: error: Unexpected recv start condition in state 3
smbus: error: Unexpected read in state -1
smbus: error: Unexpected NACK in state -1
smbus: error: Unexpected NACK in state -1
smbus: error: Unexpected recv start condition in state 3
smbus: error: Unexpected read in state -1
smbus: error: Unexpected NACK in state -1
smbus: error: Unexpected NACK in state -1
smbus: error: Unexpected recv start condition in state 3
smbus: error: Unexpected read in state -1
smbus: error: Unexpected NACK in state -1
smbus: error: Unexpected NACK in state -1
smbus: error: Unexpected recv start condition in state 3
smbus: error: Unexpected read in state -1
smbus: error: Unexpected NACK in state -1
smbus: error: Unexpected NACK in state -1
smbus: error: Unexpected recv start condition in state 3
smbus: error: Unexpected read in state -1
smbus: error: Unexpected NACK in state -1
smbus: error: Unexpected NACK in state -1
smbus: error: Unexpected recv start condition in state 3
smbus: error: Unexpected read in state -1
smbus: error: Unexpected NACK in state -1
smbus: error: Unexpected NACK in state -1
smbus: error: Unexpected recv start condition in state 3
smbus: error: Unexpected read in state -1
smbus: error: Unexpected NACK in state -1
smbus: error: Unexpected NACK in state -1
[   12.248489] usbcore: registered new interface driver i2c-diolan-u2c
[   12.249180] i2c-parport-light: adapter type unspecified
[   12.249739] usbcore: registered new interface driver RobotFuzz Open Source InterFace, OSIF
[   12.250635] usbcore: registered new interface driver i2c-tiny-usb
[   12.251393] Driver for 1-wire Dallas network protocol.
[   12.252018] usbcore: registered new interface driver DS9490R
[   12.252593] DS1WM w1 busmaster driver - (c) 2004 Szabolcs Gyurko
[   12.253289] __power_supply_register: Expected proper parent device for 'test_ac'
[   12.254099] __power_supply_register: Expected proper parent device for 'test_battery'
[   12.255026] __power_supply_register: Expected proper parent device for 'test_usb'
[   12.279158] g_ether gadget: resume
[   12.279536] dummy_hcd dummy_hcd.0: port status 0x00100503 has changes
[   12.332076] usb 1-1: new high-speed USB device number 2 using dummy_hcd
[   12.386071] g_ether gadget: resume
[   12.386435] dummy_hcd dummy_hcd.0: port status 0x00100503 has changes
[   12.412132] applesmc: supported laptop not found!
[   12.412625] applesmc: driver init failed (ret=-19)!
[   12.441071] dummy_udc dummy_udc.0: set_address = 2
[   12.471131] g_ether gadget: high-speed config #1: CDC Ethernet (ECM)
[   12.471788] dummy_udc dummy_udc.0: enabled ep5in-int (ep5in-intr) maxpacket 16 stream disabled
[   12.472657] g_ether gadget: init ecm
[   12.473026] g_ether gadget: notify connect false
[   12.473500] g_ether gadget: notify speed 425984000
[   12.478066] g_ether gadget: activate ecm
[   12.478489] dummy_udc dummy_udc.0: enabled ep1in-bulk (ep1in-bulk) maxpacket 512 stream disabled
[   12.479388] dummy_udc dummy_udc.0: enabled ep2out-bulk (ep2out-bulk) maxpacket 512 stream disabled
[   12.480309] usb0: qlen 10
[   12.480585] g_ether gadget: ecm_close
[   12.482065] g_ether gadget: packet filter 0c
[   12.482519] g_ether gadget: ecm req21.43 v000c i0000 l0
[   12.485355] cdc_ether 1-1:1.0 usb1: register 'cdc_ether' at usb-dummy_hcd.0-1, CDC Ethernet Device, c2:67:1d:81:f8:d0
[   12.486451] cdc_ether 1-1:1.0 usb1: unregister 'cdc_ether' usb-dummy_hcd.0-1, CDC Ethernet Device
[   12.492091] g_ether gadget: reset ecm
[   12.492515] usb0: gether_disconnect
[   12.492883] dummy_udc dummy_udc.0: disabled ep1in-bulk
[   12.493409] dummy_udc dummy_udc.0: disabled ep2out-bulk
[   12.493946] g_ether gadget: init ecm
[   12.496069] g_ether gadget: activate ecm
[   12.496491] dummy_udc dummy_udc.0: enabled ep1in-bulk (ep1in-bulk) maxpacket 512 stream disabled
[   12.497381] dummy_udc dummy_udc.0: enabled ep2out-bulk (ep2out-bulk) maxpacket 512 stream disabled
[   12.498290] usb0: qlen 10
[   12.498563] g_ether gadget: ecm_close
[   12.500089] g_ether gadget: packet filter 0c
[   12.500546] g_ether gadget: ecm req21.43 v000c i0000 l0
[   12.503281] cdc_ether 1-1:1.0 usb1: register 'cdc_ether' at usb-dummy_hcd.0-1, CDC Ethernet Device, c2:67:1d:81:f8:d0
[   12.506200] cdc_ether 1-1:1.0 usb1: unregister 'cdc_ether' usb-dummy_hcd.0-1, CDC Ethernet Device
[   12.512067] g_ether gadget: reset config
[   12.512492] g_ether gadget: ecm deactivated
[   12.512930] usb0: gether_disconnect
[   12.513292] dummy_udc dummy_udc.0: disabled ep1in-bulk
[   12.513819] dummy_udc dummy_udc.0: disabled ep2out-bulk
[   12.514350] dummy_udc dummy_udc.0: disabled ep5in-int
[   12.514869] g_ether gadget: high-speed config #0: unconfigured
[   12.517136] g_ether gadget: high-speed config #1: CDC Ethernet (ECM)
[   12.517808] dummy_udc dummy_udc.0: enabled ep5in-int (ep5in-intr) maxpacket 16 stream disabled
[   12.518675] g_ether gadget: init ecm
[   12.519038] g_ether gadget: notify connect false
[   12.519504] g_ether gadget: notify speed 425984000
[   12.522091] g_ether gadget: activate ecm
[   12.522519] dummy_udc dummy_udc.0: enabled ep1in-bulk (ep1in-bulk) maxpacket 512 stream disabled
[   12.523411] dummy_udc dummy_udc.0: enabled ep2out-bulk (ep2out-bulk) maxpacket 512 stream disabled
[   12.524314] usb0: qlen 10
[   12.524583] g_ether gadget: ecm_close
[   12.526090] g_ether gadget: packet filter 0c
[   12.526549] g_ether gadget: ecm req21.43 v000c i0000 l0
[   12.529278] cdc_ether 1-1:1.0 usb1: register 'cdc_ether' at usb-dummy_hcd.0-1, CDC Ethernet Device, c2:67:1d:81:f8:d0
[   12.530369] cdc_ether 1-1:1.0 usb1: unregister 'cdc_ether' usb-dummy_hcd.0-1, CDC Ethernet Device
[   12.536088] g_ether gadget: reset ecm
[   12.536483] usb0: gether_disconnect
[   12.536849] dummy_udc dummy_udc.0: disabled ep1in-bulk
[   12.537368] dummy_udc dummy_udc.0: disabled ep2out-bulk
[   12.537898] g_ether gadget: init ecm
[   12.540065] g_ether gadget: activate ecm
[   12.540490] dummy_udc dummy_udc.0: enabled ep1in-bulk (ep1in-bulk) maxpacket 512 stream disabled
[   12.541372] dummy_udc dummy_udc.0: enabled ep2out-bulk (ep2out-bulk) maxpacket 512 stream disabled
[   12.542271] usb0: qlen 10
[   12.542541] g_ether gadget: ecm_close
[   12.544090] g_ether gadget: packet filter 0c
[   12.544548] g_ether gadget: ecm req21.43 v000c i0000 l0
[   12.547293] cdc_ether 1-1:1.0 usb1: register 'cdc_ether' at usb-dummy_hcd.0-1, CDC Ethernet Device, c2:67:1d:81:f8:d0
[   12.695211] pc87360: PC8736x not detected, module not inserted
[   12.744386] sdhci: Secure Digital Host Controller Interface driver
[   12.745236] sdhci: Copyright(c) Pierre Ossman
[   12.745974] usbcore: registered new interface driver ushc
[   12.746712] sdhci-pltfm: SDHCI platform and OF driver helper
[   12.747708] leds_ss4200: no LED devices found
[   12.753226] dcdbas dcdbas: Dell Systems Management Base Driver (version 5.6.0-3.2)
[   12.754259] dcdbas dcdbas: Dell Systems Management Base Driver (version 5.6.0-3.2)
[   12.755775] fw_cfg: probe of QEMU0002:00 failed with error -16
[   12.756563] CHRDEV "qat_adf_ctl" major number 233 goes below the dynamic allocation range
[   12.757865] CHRDEV "hidraw" major number 232 goes below the dynamic allocation range
[   12.758887] hidraw: raw HID events driver (C) Jiri Kosina
[   12.760133] CHRDEV "roccat" major number 230 goes below the dynamic allocation range
[   12.761600] usbcore: registered new interface driver usbhid
[   12.762333] usbhid: USB HID core driver
[   12.762990] usbcore: registered new interface driver prism2_usb
[   12.763805] usbcore: registered new interface driver r8712u
[   12.764563] usbcore: registered new interface driver r8188eu
[   12.765305] vme_user: VME User Space Access Driver
[   12.765923] vme_user: No cards, skipping registration
[   12.766576] vme_pio2: No cards, skipping registration
[   12.767240] no options.
[   12.767628] CHRDEV "fwtty" major number 229 goes below the dynamic allocation range
[   12.768620] CHRDEV "fwloop" major number 228 goes below the dynamic allocation range
[   12.769752] FPGA DOWNLOAD --->
[   12.770167] FPGA image file name: xlinx_fpga_firmware.bit
[   12.770942] GPIO INIT FAIL!!
[   12.772164] mostcore: init()
[   12.772617] aim_cdev: init()
[   12.773003] CHRDEV "cdev" major number 227 goes below the dynamic allocation range
[   12.773995] mostcore: registered new application interfacing module cdev
[   12.774862] aim_network: most_net_init()
[   12.775393] mostcore: registered new application interfacing module networking
[   12.776352] hdm_usb: hdm_usb_init()
[   12.776834] usbcore: registered new interface driver hdm_usb
[   12.777751] Board is not the VME system controller
[   12.778376] VME geographical address is set to 0
[   12.779063] CR/CSR Offset: 0
[   12.779547] Software Queue-Pair Transport over NTB, version 4
[   12.780730] Audio Excel DSP 16 init driver Copyright (C) Riccardo Facchetti 1995-98
[   12.781721] aedsp16: I/O, IRQ and DMA are mandatory
[   12.782361] pss: mss_io, mss_dma, mss_irq and pss_io must be set.
[   12.783153] ad1848/cs4248 codec driver Copyright (C) by Hannu Savolainen 1993-1996
[   12.784122] ad1848: No ISAPnP cards found, trying standard ones...
[   12.784906] MediaTrix audio driver Copyright (C) by Hannu Savolainen 1993-1996
[   12.785834] I/O, IRQ, DMA and type are mandatory
[   12.786438] Pro Audio Spectrum driver Copyright (C) by Hannu Savolainen 1993-1996
[   12.787406] I/O, IRQ, DMA and type are mandatory
[   12.787999] sb: Init: Starting Probe...
[   12.788525] sb: Init: Done
[   12.788900] uart6850: irq and io must be set.
[   12.789471] YM3812 and OPL-3 driver Copyright (C) by Hannu Savolainen, Rob Hooft 1993-1996
[   12.790526] MIDI Loopback device driver
[   12.791237] ipip: IPv4 and MPLS over IPv4 tunneling driver
[   12.792238] gre: GRE over IPv4 demultiplexor driver
[   12.792875] ip_gre: GRE over IPv4 tunneling driver
[   12.793948] Initializing XFRM netlink socket
[   12.794859] NET: Registered protocol family 10
[   12.796718] ip6_gre: GRE over IPv6 tunneling driver
[   12.797619] NET: Registered protocol family 15
[   12.798354] NET: Registered protocol family 4
[   12.798945] NET: Registered protocol family 5
[   12.799553] NET: Registered protocol family 9
[   12.800142] X25: Linux Version 0.2
[   12.800848] NET: Registered protocol family 41
[   12.801511] l2tp_core: L2TP core driver, V2.0
[   12.802117] l2tp_ppp: PPPoL2TP kernel driver, V2.0
[   12.802738] l2tp_ip: L2TP IP encapsulation support (L2TPv3)
[   12.803484] l2tp_netlink: L2TP netlink interface
[   12.804140] l2tp_debugfs: L2TP debugfs support
[   12.804726] l2tp_ip6: L2TP IP encapsulation support for IPv6 (L2TPv3)
[   12.811744] DCCP: Activated CCID 2 (TCP-like)
[   12.812804] sctp: Hash tables configured (bind 32/51)
[   12.813526] lib80211: common routines for IEEE802.11 drivers
[   12.814126] lib80211_crypt: registered algorithm 'NULL'
[   12.814662] lib80211_crypt: registered algorithm 'WEP'
[   12.815196] lib80211_crypt: registered algorithm 'CCMP'
[   12.815732] lib80211_crypt: registered algorithm 'TKIP'
[   12.816308] NET: Registered protocol family 37
[   12.817164] batman_adv: B.A.T.M.A.N. advanced 2016.5 (compatibility version 15) loaded
[   12.817976] openvswitch: Open vSwitch switching datapath
[   12.818682] mpls_gso: MPLS GSO support
[   12.819475] registered taskstats version 1
[   12.820719] gtp: GTP module loaded (pdp ctx size 80 bytes)
[   12.821297] BIOS EDD facility v0.16 2004-Jun-25, 0 devices found
[   12.821905] EDD information not available.
[   12.822932] debug: unmapping init [mem 0xffffffff82d35000-0xffffffff82e5dfff]
[   12.823738] Write protecting the kernel read-only data: 24576k
[   12.824760] debug: unmapping init [mem 0xffff880001e19000-0xffff880001ffffff]
[   12.825549] debug: unmapping init [mem 0xffff880002634000-0xffff8800027fffff]
[   12.839353] x86/mm: Checked W+X mappings: passed, no W+X pages found.
[   12.840137] Kernel panic - not syncing: No working init found.  Try passing init= option to kernel. See Linux Documentation/init.txt for guidance.
[   12.841447] CPU: 0 PID: 1 Comm: swapper Tainted: G        W       4.8.0-14895-gaf1fee9 #4
[   12.842259] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS rel-1.9.3-0-ge2fc41e-prebuilt.qemu-project.org 04/01/2014
[   12.843406]  ffff88013a8f3eb8 ffffffff812cf3c2 ffff88013a8f3f38 ffffffff8115cf6a
[   12.844210]  ffffffff00000008 ffff88013a8f3f48 ffff88013a8f3ee0 0000000000000000
[   12.845008]  0000000000000000 0000000000000000 0000000000001c06 0000000000000001
[   12.845796] Call Trace:
[   12.846052]  [<ffffffff812cf3c2>] dump_stack+0x19/0x1b
[   12.846571]  [<ffffffff8115cf6a>] panic+0xd0/0x20c
[   12.847069]  [<ffffffff81e03615>] ? rest_init+0x12c/0x12c
[   12.847626]  [<ffffffff81e036fc>] kernel_init+0xe7/0xeb
[   12.848135]  [<ffffffff81e13c4a>] ret_from_fork+0x2a/0x40
[   12.848696] Kernel Offset: disabled
[   12.849062] ---[ end Kernel panic - not syncing: No working init found.  Try passing init= option to kernel. See Linux Documentation/init.txt for guidance.

[   62.995030] Writes:  Total: 2  Max/Min: 0/0   Fail: 0




On 07/11/16 10:31, Andrew Lunn wrote:
> EXTERNAL EMAIL
> 
> 
> On Mon, Nov 07, 2016 at 10:26:28AM +0800, kernel test robot wrote:
> >
> > FYI, we noticed the following commit:
> >
> > https://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git master
> > commit af1fee98219992ba2c12441a447719652ed7e983 ("net: phy: Add support for Microsemi VSC 8530/40 Fast Ethernet PHY")
> 
> Humm, interesting. I've no idea how this patch can trigger such a
> warning. The USB gadget does not have an Ethernet PHY, let alone a
> Microsemi 8530/40 Fast Ethernet PHY this patch adds.
> 
> However, it seems nicely documented how to reproduce this. Allan, can
> you setup such a system? Reproduce it, then revert the change and see
> if it still happens.
> 
>    Andrew
