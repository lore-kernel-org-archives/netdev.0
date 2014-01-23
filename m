From: Craig Small <csmall@enc.com.au>
Subject: Re: r8169 won't transmit with 3.12
Date: Thu, 23 Jan 2014 18:57:08 +1100
Message-ID: <20140123075708.GA9172@enc.com.au>
References: <20140121000615.GA30495@enc.com.au>
 <20140121233630.GA3214@electric-eye.fr.zoreil.com>
 <20140122004119.GA28174@enc.com.au>
 <20140122233135.GA800@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="NzB8fVQJ5HfG6fxh"
Cc: Realtek linux nic maintainers <nic_swsd@realtek.com>,
	netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ipmail04.adl6.internode.on.net ([150.101.137.141]:65302 "EHLO
	ipmail04.adl6.internode.on.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751157AbaAWICT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jan 2014 03:02:19 -0500
Content-Disposition: inline
In-Reply-To: <20140122233135.GA800@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--NzB8fVQJ5HfG6fxh
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Thu, Jan 23, 2014 at 12:31:35AM +0100, Francois Romieu wrote:
> Should I understand that the LOM fails on Linux with a naked motherboard ?
Not sure what you mean by LOM. There is no Lights Out Module. I have
now removed the two ethernet cards and enabled the motherboard NIC.
I'll leave it like this. There is one ethernet card that uses a 
8139too module.
The relevant interface is:
03:00.0 Ethernet controller: Realtek Semiconductor Co., Ltd. RTL8111/8168/8411 PCI Express Gigabit Ethernet Controller (rev 06)
	Subsystem: Gigabyte Technology Co., Ltd Motherboard
	Flags: bus master, fast devsel, latency 0, IRQ 72
	I/O ports at d000 [size=256]
	Memory at fdd00000 (64-bit, non-prefetchable) [size=4K]
	Memory at d2100000 (64-bit, prefetchable) [size=16K]
	Capabilities: [40] Power Management version 3
	Capabilities: [50] MSI: Enable+ Count=1/1 Maskable- 64bit+
	Capabilities: [70] Express Endpoint, MSI 01
	Capabilities: [b0] MSI-X: Enable- Count=4 Masked-
	Capabilities: [d0] Vital Product Data
	Capabilities: [100] Advanced Error Reporting
	Capabilities: [140] Virtual Channel
	Capabilities: [160] Device Serial Number 01-00-00-00-68-4c-e0-00
	Kernel driver in use: r8169

eth5 is the working r8139
eth6 is the r8169 that we're interested in.

> Please check if runtime resume is disabled (/sys/bus/pci/devices/.../power/control
$ cat /sys/bus/pci/devices/0000\:03\:00.0/power/control 
on

> Please don't switch between the r8168 and the r8169 modules at runtime.
> I saw it in your dmesg and I won't claim it's supported.
That's fine. I was doing it to see if it would work. I'll stay with the r8169
for now. I got a watchdog notice now, not sure if that is better or worse.

 - Craig

-- 
Craig Small (@smallsees)   http://enc.com.au/       csmall at : enc.com.au
Debian GNU/Linux           http://www.debian.org/   csmall at : debian.org
GPG fingerprint:        5D2F B320 B825 D939 04D2  0519 3938 F96B DF50 FEA5

--NzB8fVQJ5HfG6fxh
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="r8169dmesg2.txt"
Content-Transfer-Encoding: quoted-printable

[    0.000000] Initializing cgroup subsys cpuset
[    0.000000] Initializing cgroup subsys cpu
[    0.000000] Initializing cgroup subsys cpuacct
[    0.000000] Linux version 3.12-1-amd64 (debian-kernel@lists.debian.org) =
(gcc version 4.8.2 (Debian 4.8.2-10) ) #1 SMP Debian 3.12.6-2 (2013-12-29)
[    0.000000] Command line: BOOT_IMAGE=3D/boot/vmlinuz-3.12-1-amd64 root=
=3DUUID=3Da273d5f8-984b-4ce4-87dd-d6885f488b80 ro quiet
[    0.000000] e820: BIOS-provided physical RAM map:
[    0.000000] BIOS-e820: [mem 0x0000000000000000-0x000000000009e7ff] usable
[    0.000000] BIOS-e820: [mem 0x000000000009e800-0x000000000009ffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000000e0000-0x00000000000fffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x0000000000100000-0x00000000be866fff] usable
[    0.000000] BIOS-e820: [mem 0x00000000be867000-0x00000000bea3efff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000bea3f000-0x00000000bee33fff] ACPI =
NVS
[    0.000000] BIOS-e820: [mem 0x00000000bee34000-0x00000000bf15efff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000bf15f000-0x00000000bf15ffff] usable
[    0.000000] BIOS-e820: [mem 0x00000000bf160000-0x00000000bf365fff] ACPI =
NVS
[    0.000000] BIOS-e820: [mem 0x00000000bf366000-0x00000000bf7fffff] usable
[    0.000000] BIOS-e820: [mem 0x00000000f8000000-0x00000000fbffffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000fec00000-0x00000000fec00fff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000fec10000-0x00000000fec10fff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000fec20000-0x00000000fec20fff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000fed00000-0x00000000fed00fff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000fed61000-0x00000000fed70fff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000fed80000-0x00000000fed8ffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000fef00000-0x00000000ffffffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x0000000100001000-0x000000043effffff] usable
[    0.000000] NX (Execute Disable) protection: active
[    0.000000] SMBIOS 2.7 present.
[    0.000000] DMI: Gigabyte Technology Co., Ltd. To be filled by O.E.M./97=
0A-D3P, BIOS F3 05/24/2013
[    0.000000] e820: update [mem 0x00000000-0x00000fff] usable =3D=3D> rese=
rved
[    0.000000] e820: remove [mem 0x000a0000-0x000fffff] usable
[    0.000000] No AGP bridge found
[    0.000000] e820: last_pfn =3D 0x43f000 max_arch_pfn =3D 0x400000000
[    0.000000] MTRR default type: uncachable
[    0.000000] MTRR fixed ranges enabled:
[    0.000000]   00000-9FFFF write-back
[    0.000000]   A0000-BFFFF write-through
[    0.000000]   C0000-CEFFF write-protect
[    0.000000]   CF000-EBFFF uncachable
[    0.000000]   EC000-FFFFF write-protect
[    0.000000] MTRR variable ranges enabled:
[    0.000000]   0 base 000000000000 mask FFFF80000000 write-back
[    0.000000]   1 base 000080000000 mask FFFFC0000000 write-back
[    0.000000]   2 base 0000BF800000 mask FFFFFF800000 uncachable
[    0.000000]   3 disabled
[    0.000000]   4 disabled
[    0.000000]   5 disabled
[    0.000000]   6 disabled
[    0.000000]   7 disabled
[    0.000000] TOM2: 000000043f000000 aka 17392M
[    0.000000] x86 PAT enabled: cpu 0, old 0x7040600070406, new 0x701060007=
0106
[    0.000000] e820: update [mem 0xbf800000-0xffffffff] usable =3D=3D> rese=
rved
[    0.000000] e820: last_pfn =3D 0xbf800 max_arch_pfn =3D 0x400000000
[    0.000000] found SMP MP-table at [mem 0x000fd820-0x000fd82f] mapped at =
[ffff8800000fd820]
[    0.000000] Base memory trampoline at [ffff880000098000] 98000 size 24576
[    0.000000] Using GB pages for direct mapping
[    0.000000] init_memory_mapping: [mem 0x00000000-0x000fffff]
[    0.000000]  [mem 0x00000000-0x000fffff] page 4k
[    0.000000] BRK [0x01a91000, 0x01a91fff] PGTABLE
[    0.000000] BRK [0x01a92000, 0x01a92fff] PGTABLE
[    0.000000] BRK [0x01a93000, 0x01a93fff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0x43ee00000-0x43effffff]
[    0.000000]  [mem 0x43ee00000-0x43effffff] page 2M
[    0.000000] BRK [0x01a94000, 0x01a94fff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0x43c000000-0x43edfffff]
[    0.000000]  [mem 0x43c000000-0x43edfffff] page 2M
[    0.000000] init_memory_mapping: [mem 0x400000000-0x43bffffff]
[    0.000000]  [mem 0x400000000-0x43bffffff] page 2M
[    0.000000] init_memory_mapping: [mem 0x00100000-0xbe866fff]
[    0.000000]  [mem 0x00100000-0x001fffff] page 4k
[    0.000000]  [mem 0x00200000-0x3fffffff] page 2M
[    0.000000]  [mem 0x40000000-0x7fffffff] page 1G
[    0.000000]  [mem 0x80000000-0xbe7fffff] page 2M
[    0.000000]  [mem 0xbe800000-0xbe866fff] page 4k
[    0.000000] init_memory_mapping: [mem 0xbf15f000-0xbf15ffff]
[    0.000000]  [mem 0xbf15f000-0xbf15ffff] page 4k
[    0.000000] BRK [0x01a95000, 0x01a95fff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0xbf366000-0xbf7fffff]
[    0.000000]  [mem 0xbf366000-0xbf3fffff] page 4k
[    0.000000]  [mem 0xbf400000-0xbf7fffff] page 2M
[    0.000000] BRK [0x01a96000, 0x01a96fff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0x100001000-0x3ffffffff]
[    0.000000]  [mem 0x100001000-0x1001fffff] page 4k
[    0.000000]  [mem 0x100200000-0x13fffffff] page 2M
[    0.000000]  [mem 0x140000000-0x3ffffffff] page 1G
[    0.000000] RAMDISK: [mem 0x363bc000-0x371d5fff]
[    0.000000] ACPI: RSDP 00000000000f0490 00024 (v02 ALASKA)
[    0.000000] ACPI: XSDT 00000000bee19068 00054 (v01 ALASKA    A M I 01072=
009 AMI  00010013)
[    0.000000] ACPI: FACP 00000000bee1eba0 000F4 (v04 ALASKA    A M I 01072=
009 AMI  00010013)
[    0.000000] ACPI BIOS Warning (bug): Optional FADT field Pm2ControlBlock=
 has zero address or length: 0x0000000000000000/0x1 (20130725/tbfadt-603)
[    0.000000] ACPI: DSDT 00000000bee19158 05A42 (v02 ALASKA    A M I 00000=
000 INTL 20051117)
[    0.000000] ACPI: FACS 00000000bee2ef80 00040
[    0.000000] ACPI: APIC 00000000bee1ec98 0008E (v03 ALASKA    A M I 01072=
009 AMI  00010013)
[    0.000000] ACPI: FPDT 00000000bee1ed28 00044 (v01 ALASKA    A M I 01072=
009 AMI  00010013)
[    0.000000] ACPI: MCFG 00000000bee1ed70 0003C (v01 ALASKA    A M I 01072=
009 MSFT 00010013)
[    0.000000] ACPI: HPET 00000000bee1edb0 00038 (v01 ALASKA    A M I 01072=
009 AMI  00000005)
[    0.000000] ACPI: SSDT 00000000bee1ede8 01158 (v01 AMD    POWERNOW 00000=
001 AMD  00000001)
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] No NUMA configuration found
[    0.000000] Faking a node at [mem 0x0000000000000000-0x000000043effffff]
[    0.000000] Initmem setup node 0 [mem 0x00000000-0x43effffff]
[    0.000000]   NODE_DATA [mem 0x43eff8000-0x43effbfff]
[    0.000000]  [ffffea0000000000-ffffea000edfffff] PMD -> [ffff88042e60000=
0-ffff88043c5fffff] on node 0
[    0.000000] Zone ranges:
[    0.000000]   DMA      [mem 0x00001000-0x00ffffff]
[    0.000000]   DMA32    [mem 0x01000000-0xffffffff]
[    0.000000]   Normal   [mem 0x100000000-0x43effffff]
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x00001000-0x0009dfff]
[    0.000000]   node   0: [mem 0x00100000-0xbe866fff]
[    0.000000]   node   0: [mem 0xbf15f000-0xbf15ffff]
[    0.000000]   node   0: [mem 0xbf366000-0xbf7fffff]
[    0.000000]   node   0: [mem 0x100001000-0x43effffff]
[    0.000000] On node 0 totalpages: 4185246
[    0.000000]   DMA zone: 56 pages used for memmap
[    0.000000]   DMA zone: 21 pages reserved
[    0.000000]   DMA zone: 3997 pages, LIFO batch:0
[    0.000000]   DMA32 zone: 10630 pages used for memmap
[    0.000000]   DMA32 zone: 777474 pages, LIFO batch:31
[    0.000000]   Normal zone: 46536 pages used for memmap
[    0.000000]   Normal zone: 3403775 pages, LIFO batch:31
[    0.000000] ACPI: PM-Timer IO Port: 0x808
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] ACPI: LAPIC (acpi_id[0x01] lapic_id[0x10] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x02] lapic_id[0x11] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x03] lapic_id[0x12] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x04] lapic_id[0x13] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x05] lapic_id[0x14] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x06] lapic_id[0x15] enabled)
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0xff] high edge lint[0x1])
[    0.000000] ACPI: IOAPIC (id[0x07] address[0xfec00000] gsi_base[0])
[    0.000000] IOAPIC[0]: apic_id 7, version 33, address 0xfec00000, GSI 0-=
23
[    0.000000] ACPI: IOAPIC (id[0x08] address[0xfec20000] gsi_base[24])
[    0.000000] IOAPIC[1]: apic_id 8, version 33, address 0xfec20000, GSI 24=
-55
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 low level)
[    0.000000] ACPI: IRQ0 used by override.
[    0.000000] ACPI: IRQ2 used by override.
[    0.000000] ACPI: IRQ9 used by override.
[    0.000000] Using ACPI (MADT) for SMP configuration information
[    0.000000] ACPI: HPET id: 0x43538210 base: 0xfed00000
[    0.000000] smpboot: Allowing 6 CPUs, 0 hotplug CPUs
[    0.000000] nr_irqs_gsi: 72
[    0.000000] PM: Registered nosave memory: [mem 0x0009e000-0x0009efff]
[    0.000000] PM: Registered nosave memory: [mem 0x0009f000-0x0009ffff]
[    0.000000] PM: Registered nosave memory: [mem 0x000a0000-0x000dffff]
[    0.000000] PM: Registered nosave memory: [mem 0x000e0000-0x000fffff]
[    0.000000] PM: Registered nosave memory: [mem 0xbe867000-0xbea3efff]
[    0.000000] PM: Registered nosave memory: [mem 0xbea3f000-0xbee33fff]
[    0.000000] PM: Registered nosave memory: [mem 0xbee34000-0xbf15efff]
[    0.000000] PM: Registered nosave memory: [mem 0xbf160000-0xbf365fff]
[    0.000000] PM: Registered nosave memory: [mem 0xbf800000-0xf7ffffff]
[    0.000000] PM: Registered nosave memory: [mem 0xf8000000-0xfbffffff]
[    0.000000] PM: Registered nosave memory: [mem 0xfc000000-0xfebfffff]
[    0.000000] PM: Registered nosave memory: [mem 0xfec00000-0xfec00fff]
[    0.000000] PM: Registered nosave memory: [mem 0xfec01000-0xfec0ffff]
[    0.000000] PM: Registered nosave memory: [mem 0xfec10000-0xfec10fff]
[    0.000000] PM: Registered nosave memory: [mem 0xfec11000-0xfec1ffff]
[    0.000000] PM: Registered nosave memory: [mem 0xfec20000-0xfec20fff]
[    0.000000] PM: Registered nosave memory: [mem 0xfec21000-0xfecfffff]
[    0.000000] PM: Registered nosave memory: [mem 0xfed00000-0xfed00fff]
[    0.000000] PM: Registered nosave memory: [mem 0xfed01000-0xfed60fff]
[    0.000000] PM: Registered nosave memory: [mem 0xfed61000-0xfed70fff]
[    0.000000] PM: Registered nosave memory: [mem 0xfed71000-0xfed7ffff]
[    0.000000] PM: Registered nosave memory: [mem 0xfed80000-0xfed8ffff]
[    0.000000] PM: Registered nosave memory: [mem 0xfed90000-0xfeefffff]
[    0.000000] PM: Registered nosave memory: [mem 0xfef00000-0xffffffff]
[    0.000000] PM: Registered nosave memory: [mem 0x100000000-0x100000fff]
[    0.000000] e820: [mem 0xbf800000-0xf7ffffff] available for PCI devices
[    0.000000] Booting paravirtualized kernel on bare hardware
[    0.000000] setup_percpu: NR_CPUS:512 nr_cpumask_bits:512 nr_cpu_ids:6 n=
r_node_ids:1
[    0.000000] PERCPU: Embedded 28 pages/cpu @ffff88043ec00000 s85888 r8192=
 d20608 u262144
[    0.000000] pcpu-alloc: s85888 r8192 d20608 u262144 alloc=3D1*2097152
[    0.000000] pcpu-alloc: [0] 0 1 2 3 4 5 - -=20
[    0.000000] Built 1 zonelists in Zone order, mobility grouping on.  Tota=
l pages: 4128003
[    0.000000] Policy zone: Normal
[    0.000000] Kernel command line: BOOT_IMAGE=3D/boot/vmlinuz-3.12-1-amd64=
 root=3DUUID=3Da273d5f8-984b-4ce4-87dd-d6885f488b80 ro quiet
[    0.000000] PID hash table entries: 4096 (order: 3, 32768 bytes)
[    0.000000] xsave: enabled xstate_bv 0x7, cntxt size 0x340
[    0.000000] Checking aperture...
[    0.000000] No AGP bridge found
[    0.000000] Node 0: aperture @ f8000000 size 64 MB
[    0.000000] Memory: 16419228K/16740984K available (4726K kernel code, 67=
9K rwdata, 1596K rodata, 972K init, 944K bss, 321756K reserved)
[    0.000000] Hierarchical RCU implementation.
[    0.000000] 	RCU dyntick-idle grace-period acceleration is enabled.
[    0.000000] 	RCU restricting CPUs from NR_CPUS=3D512 to nr_cpu_ids=3D6.
[    0.000000] NR_IRQS:33024 nr_irqs:1272 16
[    0.000000] spurious 8259A interrupt: IRQ7.
[    0.000000] Console: colour VGA+ 80x25
[    0.000000] console [tty0] enabled
[    0.000000] hpet clockevent registered
[    0.000000] tsc: Fast TSC calibration using PIT
[    0.004000] tsc: Detected 3516.208 MHz processor
[    0.000003] Calibrating delay loop (skipped), value calculated using tim=
er frequency.. 7032.41 BogoMIPS (lpj=3D14064832)
[    0.000005] pid_max: default: 32768 minimum: 301
[    0.000028] Security Framework initialized
[    0.000032] AppArmor: AppArmor disabled by boot time parameter
[    0.000033] Yama: disabled by default; enable with sysctl kernel.yama.*
[    0.000936] Dentry cache hash table entries: 2097152 (order: 12, 1677721=
6 bytes)
[    0.005763] Inode-cache hash table entries: 1048576 (order: 11, 8388608 =
bytes)
[    0.007979] Mount-cache hash table entries: 256
[    0.008135] Initializing cgroup subsys memory
[    0.008150] Initializing cgroup subsys devices
[    0.008151] Initializing cgroup subsys freezer
[    0.008153] Initializing cgroup subsys net_cls
[    0.008154] Initializing cgroup subsys blkio
[    0.008156] Initializing cgroup subsys perf_event
[    0.008175] tseg: 00bf800000
[    0.008176] CPU: Physical Processor ID: 0
[    0.008177] CPU: Processor Core ID: 0
[    0.008179] mce: CPU supports 7 MCE banks
[    0.008185] LVT offset 1 assigned for vector 0xf9
[    0.008190] Last level iTLB entries: 4KB 512, 2MB 1024, 4MB 512
[    0.008190] Last level dTLB entries: 4KB 1024, 2MB 1024, 4MB 512
[    0.008190] tlb_flushall_shift: 5
[    0.008255] Freeing SMP alternatives memory: 20K (ffffffff8199e000 - fff=
fffff819a3000)
[    0.008909] ACPI: Core revision 20130725
[    0.010692] ACPI: All ACPI Tables successfully acquired
[    0.011266] ..TIMER: vector=3D0x30 apic1=3D0 pin1=3D2 apic2=3D-1 pin2=3D=
-1
[    0.050920] smpboot: CPU0: AMD FX(tm)-6300 Six-Core Processor (fam: 15, =
model: 02, stepping: 00)
[    0.155558] Performance Events: Fam15h core perfctr, AMD PMU driver.
[    0.155562] ... version:                0
[    0.155563] ... bit width:              48
[    0.155564] ... generic registers:      6
[    0.155565] ... value mask:             0000ffffffffffff
[    0.155566] ... max period:             00007fffffffffff
[    0.155567] ... fixed-purpose events:   0
[    0.155568] ... event mask:             000000000000003f
[    0.155769] NMI watchdog: enabled on all CPUs, permanently consumes one =
hw-PMU counter.
[    0.155852] smpboot: Booting Node   0, Processors  #   1 #   2 #   3 #  =
 4 #   5 OK
[    0.222129] Brought up 6 CPUs
[    0.222132] smpboot: Total of 6 processors activated (42194.49 BogoMIPS)
[    0.229791] devtmpfs: initialized
[    0.233032] PM: Registering ACPI NVS region [mem 0xbea3f000-0xbee33fff] =
(4149248 bytes)
[    0.233103] PM: Registering ACPI NVS region [mem 0xbf160000-0xbf365fff] =
(2121728 bytes)
[    0.233298] NET: Registered protocol family 16
[    0.233372] cpuidle: using governor ladder
[    0.233373] cpuidle: using governor menu
[    0.233406] ACPI: bus type PCI registered
[    0.233408] acpiphp: ACPI Hot Plug PCI Controller Driver version: 0.5
[    0.233450] PCI: MMCONFIG for domain 0000 [bus 00-ff] at [mem 0xe0000000=
-0xefffffff] (base 0xe0000000)
[    0.233452] PCI: not using MMCONFIG
[    0.233453] PCI: Using configuration type 1 for base access
[    0.233454] PCI: Using configuration type 1 for extended access
[    0.233712] mtrr: your CPUs had inconsistent variable MTRR settings
[    0.233713] mtrr: probably your BIOS does not setup all CPUs.
[    0.233713] mtrr: corrected configuration.
[    0.234147] bio: create slab <bio-0> at 0
[    0.234289] ACPI: Added _OSI(Module Device)
[    0.234290] ACPI: Added _OSI(Processor Device)
[    0.234291] ACPI: Added _OSI(3.0 _SCP Extensions)
[    0.234292] ACPI: Added _OSI(Processor Aggregator Device)
[    0.234779] ACPI: EC: Look up EC in DSDT
[    0.235592] ACPI: Executed 3 blocks of module-level executable AML code
[    0.243903] ACPI: Interpreter enabled
[    0.243910] ACPI Exception: AE_NOT_FOUND, While evaluating Sleep State [=
\_S1_] (20130725/hwxface-571)
[    0.243914] ACPI Exception: AE_NOT_FOUND, While evaluating Sleep State [=
\_S2_] (20130725/hwxface-571)
[    0.243925] ACPI: (supports S0 S3 S4 S5)
[    0.243926] ACPI: Using IOAPIC for interrupt routing
[    0.244039] PCI: MMCONFIG for domain 0000 [bus 00-ff] at [mem 0xe0000000=
-0xefffffff] (base 0xe0000000)
[    0.244072] PCI: MMCONFIG at [mem 0xe0000000-0xefffffff] reserved in ACP=
I motherboard resources
[    0.256483] PCI: Using host bridge windows from ACPI; if necessary, use =
"pci=3Dnocrs" and report a bug
[    0.256559] ACPI: No dock devices found.
[    0.269107] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-ff])
[    0.269112] acpi PNP0A08:00: ACPI _OSC support notification failed, disa=
bling PCIe ASPM
[    0.269113] acpi PNP0A08:00: Unable to request _OSC control (_OSC suppor=
t mask: 0x08)
[    0.269344] ACPI: \_SB_.PCI0.AMDN: can't evaluate _ADR (0x5)
[    0.269412] ACPI: \_SB_.PCI0.UMEM: can't evaluate _ADR (0x5)
[    0.269460] ACPI: \_SB_.PCI0.ITPM: can't evaluate _ADR (0x5)
[    0.269462] PCI host bridge to bus 0000:00
[    0.269464] pci_bus 0000:00: root bus resource [bus 00-ff]
[    0.269465] pci_bus 0000:00: root bus resource [io  0x0000-0x03af]
[    0.269467] pci_bus 0000:00: root bus resource [io  0x03e0-0x0cf7]
[    0.269468] pci_bus 0000:00: root bus resource [io  0x03b0-0x03df]
[    0.269470] pci_bus 0000:00: root bus resource [io  0x0d00-0xffff]
[    0.269471] pci_bus 0000:00: root bus resource [mem 0x000a0000-0x000bfff=
f]
[    0.269472] pci_bus 0000:00: root bus resource [mem 0x000c0000-0x000dfff=
f]
[    0.269474] pci_bus 0000:00: root bus resource [mem 0xc0000000-0xfffffff=
f]
[    0.269483] pci 0000:00:00.0: [1002:5a14] type 00 class 0x060000
[    0.269610] pci 0000:00:02.0: [1002:5a16] type 01 class 0x060400
[    0.269640] pci 0000:00:02.0: PME# supported from D0 D3hot D3cold
[    0.269680] pci 0000:00:02.0: System wakeup disabled by ACPI
[    0.269705] pci 0000:00:04.0: [1002:5a18] type 01 class 0x060400
[    0.269733] pci 0000:00:04.0: PME# supported from D0 D3hot D3cold
[    0.269779] pci 0000:00:04.0: System wakeup disabled by ACPI
[    0.269806] pci 0000:00:09.0: [1002:5a1c] type 01 class 0x060400
[    0.269834] pci 0000:00:09.0: PME# supported from D0 D3hot D3cold
[    0.269873] pci 0000:00:09.0: System wakeup disabled by ACPI
[    0.269896] pci 0000:00:0a.0: [1002:5a1d] type 01 class 0x060400
[    0.269924] pci 0000:00:0a.0: PME# supported from D0 D3hot D3cold
[    0.269964] pci 0000:00:0a.0: System wakeup disabled by ACPI
[    0.269995] pci 0000:00:11.0: [1002:4391] type 00 class 0x010601
[    0.270010] pci 0000:00:11.0: reg 0x10: [io  0xf040-0xf047]
[    0.270017] pci 0000:00:11.0: reg 0x14: [io  0xf030-0xf033]
[    0.270024] pci 0000:00:11.0: reg 0x18: [io  0xf020-0xf027]
[    0.270031] pci 0000:00:11.0: reg 0x1c: [io  0xf010-0xf013]
[    0.270038] pci 0000:00:11.0: reg 0x20: [io  0xf000-0xf00f]
[    0.270045] pci 0000:00:11.0: reg 0x24: [mem 0xfd10b000-0xfd10b3ff]
[    0.270135] pci 0000:00:12.0: [1002:4397] type 00 class 0x0c0310
[    0.270145] pci 0000:00:12.0: reg 0x10: [mem 0xfd10a000-0xfd10afff]
[    0.270219] pci 0000:00:12.0: System wakeup disabled by ACPI
[    0.270246] pci 0000:00:12.2: [1002:4396] type 00 class 0x0c0320
[    0.270260] pci 0000:00:12.2: reg 0x10: [mem 0xfd109000-0xfd1090ff]
[    0.270319] pci 0000:00:12.2: supports D1 D2
[    0.270321] pci 0000:00:12.2: PME# supported from D0 D1 D2 D3hot
[    0.270361] pci 0000:00:12.2: System wakeup disabled by ACPI
[    0.270386] pci 0000:00:13.0: [1002:4397] type 00 class 0x0c0310
[    0.270396] pci 0000:00:13.0: reg 0x10: [mem 0xfd108000-0xfd108fff]
[    0.270470] pci 0000:00:13.0: System wakeup disabled by ACPI
[    0.270497] pci 0000:00:13.2: [1002:4396] type 00 class 0x0c0320
[    0.270510] pci 0000:00:13.2: reg 0x10: [mem 0xfd107000-0xfd1070ff]
[    0.270570] pci 0000:00:13.2: supports D1 D2
[    0.270571] pci 0000:00:13.2: PME# supported from D0 D1 D2 D3hot
[    0.270612] pci 0000:00:13.2: System wakeup disabled by ACPI
[    0.270638] pci 0000:00:14.0: [1002:4385] type 00 class 0x0c0500
[    0.270737] pci 0000:00:14.2: [1002:4383] type 00 class 0x040300
[    0.270753] pci 0000:00:14.2: reg 0x10: [mem 0xfd100000-0xfd103fff 64bit]
[    0.270828] pci 0000:00:14.2: PME# supported from D0 D3hot D3cold
[    0.270867] pci 0000:00:14.2: System wakeup disabled by ACPI
[    0.270888] pci 0000:00:14.3: [1002:439d] type 00 class 0x060100
[    0.270987] pci 0000:00:14.4: [1002:4384] type 01 class 0x060401
[    0.271046] pci 0000:00:14.4: System wakeup disabled by ACPI
[    0.271067] pci 0000:00:14.5: [1002:4399] type 00 class 0x0c0310
[    0.271077] pci 0000:00:14.5: reg 0x10: [mem 0xfd106000-0xfd106fff]
[    0.271152] pci 0000:00:14.5: System wakeup disabled by ACPI
[    0.271176] pci 0000:00:16.0: [1002:4397] type 00 class 0x0c0310
[    0.271186] pci 0000:00:16.0: reg 0x10: [mem 0xfd105000-0xfd105fff]
[    0.271261] pci 0000:00:16.0: System wakeup disabled by ACPI
[    0.271288] pci 0000:00:16.2: [1002:4396] type 00 class 0x0c0320
[    0.271302] pci 0000:00:16.2: reg 0x10: [mem 0xfd104000-0xfd1040ff]
[    0.271362] pci 0000:00:16.2: supports D1 D2
[    0.271363] pci 0000:00:16.2: PME# supported from D0 D1 D2 D3hot
[    0.271403] pci 0000:00:16.2: System wakeup disabled by ACPI
[    0.271428] pci 0000:00:18.0: [1022:1600] type 00 class 0x060000
[    0.271487] pci 0000:00:18.1: [1022:1601] type 00 class 0x060000
[    0.271541] pci 0000:00:18.2: [1022:1602] type 00 class 0x060000
[    0.271596] pci 0000:00:18.3: [1022:1603] type 00 class 0x060000
[    0.271654] pci 0000:00:18.4: [1022:1604] type 00 class 0x060000
[    0.271709] pci 0000:00:18.5: [1022:1605] type 00 class 0x060000
[    0.271806] pci 0000:01:00.0: [10de:0a65] type 00 class 0x030000
[    0.271814] pci 0000:01:00.0: reg 0x10: [mem 0xfc000000-0xfcffffff]
[    0.271823] pci 0000:01:00.0: reg 0x14: [mem 0xc0000000-0xcfffffff 64bit=
 pref]
[    0.271831] pci 0000:01:00.0: reg 0x1c: [mem 0xd0000000-0xd1ffffff 64bit=
 pref]
[    0.271837] pci 0000:01:00.0: reg 0x24: [io  0xe000-0xe07f]
[    0.271843] pci 0000:01:00.0: reg 0x30: [mem 0xfd000000-0xfd07ffff pref]
[    0.271910] pci 0000:01:00.1: [10de:0be3] type 00 class 0x040300
[    0.271918] pci 0000:01:00.1: reg 0x10: [mem 0xfd080000-0xfd083fff]
[    0.281011] pci 0000:00:02.0: PCI bridge to [bus 01]
[    0.281015] pci 0000:00:02.0:   bridge window [io  0xe000-0xefff]
[    0.281017] pci 0000:00:02.0:   bridge window [mem 0xfc000000-0xfd0fffff]
[    0.281020] pci 0000:00:02.0:   bridge window [mem 0xc0000000-0xd1ffffff=
 64bit pref]
[    0.281060] pci 0000:02:00.0: [1106:3483] type 00 class 0x0c0330
[    0.281072] pci 0000:02:00.0: reg 0x10: [mem 0xfde00000-0xfde00fff 64bit]
[    0.281122] pci 0000:02:00.0: PME# supported from D0 D1 D2 D3hot D3cold
[    0.289027] pci 0000:00:04.0: PCI bridge to [bus 02]
[    0.289031] pci 0000:00:04.0:   bridge window [mem 0xfde00000-0xfdefffff]
[    0.289086] pci 0000:03:00.0: [10ec:8168] type 00 class 0x020000
[    0.289099] pci 0000:03:00.0: reg 0x10: [io  0xd000-0xd0ff]
[    0.289117] pci 0000:03:00.0: reg 0x18: [mem 0xfdd00000-0xfdd00fff 64bit]
[    0.289129] pci 0000:03:00.0: reg 0x20: [mem 0xd2100000-0xd2103fff 64bit=
 pref]
[    0.289179] pci 0000:03:00.0: supports D1 D2
[    0.289180] pci 0000:03:00.0: PME# supported from D0 D1 D2 D3hot D3cold
[    0.289206] pci 0000:03:00.0: System wakeup disabled by ACPI
[    0.296996] pci 0000:00:09.0: PCI bridge to [bus 03]
[    0.296999] pci 0000:00:09.0:   bridge window [io  0xd000-0xdfff]
[    0.297002] pci 0000:00:09.0:   bridge window [mem 0xfdd00000-0xfddfffff]
[    0.297005] pci 0000:00:09.0:   bridge window [mem 0xd2100000-0xd21fffff=
 64bit pref]
[    0.297051] pci 0000:04:00.0: [1131:7164] type 00 class 0x048000
[    0.297070] pci 0000:04:00.0: reg 0x10: [mem 0xfd800000-0xfdbfffff 64bit]
[    0.297085] pci 0000:04:00.0: reg 0x18: [mem 0xfd400000-0xfd7fffff 64bit]
[    0.297161] pci 0000:04:00.0: supports D1 D2
[    0.297163] pci 0000:04:00.0: PME# supported from D0 D1 D2
[    0.304990] pci 0000:00:0a.0: PCI bridge to [bus 04]
[    0.304994] pci 0000:00:0a.0:   bridge window [mem 0xfd400000-0xfdbfffff]
[    0.305036] pci 0000:05:07.0: [1113:1211] type 00 class 0x020000
[    0.305053] pci 0000:05:07.0: reg 0x10: [io  0xc000-0xc0ff]
[    0.305063] pci 0000:05:07.0: reg 0x14: [mem 0xfdc10000-0xfdc100ff]
[    0.305105] pci 0000:05:07.0: reg 0x30: [mem 0xfdc00000-0xfdc0ffff pref]
[    0.305134] pci 0000:05:07.0: supports D1 D2
[    0.305135] pci 0000:05:07.0: PME# supported from D0 D1 D2 D3hot D3cold
[    0.305190] pci 0000:00:14.4: PCI bridge to [bus 05] (subtractive decode)
[    0.305193] pci 0000:00:14.4:   bridge window [io  0xc000-0xcfff]
[    0.305196] pci 0000:00:14.4:   bridge window [mem 0xfdc00000-0xfdcfffff]
[    0.305199] pci 0000:00:14.4:   bridge window [io  0x0000-0x03af] (subtr=
active decode)
[    0.305200] pci 0000:00:14.4:   bridge window [io  0x03e0-0x0cf7] (subtr=
active decode)
[    0.305202] pci 0000:00:14.4:   bridge window [io  0x03b0-0x03df] (subtr=
active decode)
[    0.305203] pci 0000:00:14.4:   bridge window [io  0x0d00-0xffff] (subtr=
active decode)
[    0.305205] pci 0000:00:14.4:   bridge window [mem 0x000a0000-0x000bffff=
] (subtractive decode)
[    0.305206] pci 0000:00:14.4:   bridge window [mem 0x000c0000-0x000dffff=
] (subtractive decode)
[    0.305207] pci 0000:00:14.4:   bridge window [mem 0xc0000000-0xffffffff=
] (subtractive decode)
[    0.305522] ACPI: PCI Interrupt Link [LNKA] (IRQs 4 7 10 11 14 15) *0
[    0.305573] ACPI: PCI Interrupt Link [LNKB] (IRQs 4 7 10 11 14 15) *0
[    0.305625] ACPI: PCI Interrupt Link [LNKC] (IRQs 4 7 10 11 14 15) *0
[    0.305676] ACPI: PCI Interrupt Link [LNKD] (IRQs 4 7 10 11 14 15) *0
[    0.305717] ACPI: PCI Interrupt Link [LNKE] (IRQs 4 10 11 14 15) *0
[    0.305750] ACPI: PCI Interrupt Link [LNKF] (IRQs 4 10 11 14 15) *0
[    0.305782] ACPI: PCI Interrupt Link [LNKG] (IRQs 4 10 11 14 15) *0
[    0.305815] ACPI: PCI Interrupt Link [LNKH] (IRQs 4 10 11 14 15) *0
[    0.305881] ACPI: \_SB_.PCI0: notify handler is installed
[    0.305902] Found 1 acpi root devices
[    0.305975] vgaarb: device added: PCI:0000:01:00.0,decodes=3Dio+mem,owns=
=3Dio+mem,locks=3Dnone
[    0.305977] vgaarb: loaded
[    0.305978] vgaarb: bridge control possible 0000:01:00.0
[    0.306009] PCI: Using ACPI for IRQ routing
[    0.312306] PCI: pci_cache_line_size set to 64 bytes
[    0.312355] e820: reserve RAM buffer [mem 0x0009e800-0x0009ffff]
[    0.312356] e820: reserve RAM buffer [mem 0xbe867000-0xbfffffff]
[    0.312357] e820: reserve RAM buffer [mem 0xbf160000-0xbfffffff]
[    0.312358] e820: reserve RAM buffer [mem 0xbf800000-0xbfffffff]
[    0.312359] e820: reserve RAM buffer [mem 0x43f000000-0x43fffffff]
[    0.312432] hpet0: at MMIO 0xfed00000, IRQs 2, 8, 0
[    0.312435] hpet0: 3 comparators, 32-bit 14.318180 MHz counter
[    0.314477] Switched to clocksource hpet
[    0.315829] pnp: PnP ACPI init
[    0.315837] ACPI: bus type PNP registered
[    0.315898] system 00:00: [mem 0xe0000000-0xefffffff] has been reserved
[    0.315901] system 00:00: Plug and Play ACPI device, IDs PNP0c01 (active)
[    0.316107] system 00:01: [io  0x040b] has been reserved
[    0.316109] system 00:01: [io  0x04d6] has been reserved
[    0.316111] system 00:01: [io  0x0c00-0x0c01] has been reserved
[    0.316112] system 00:01: [io  0x0c14] has been reserved
[    0.316114] system 00:01: [io  0x0c50-0x0c51] has been reserved
[    0.316115] system 00:01: [io  0x0c52] has been reserved
[    0.316117] system 00:01: [io  0x0c6c] has been reserved
[    0.316118] system 00:01: [io  0x0c6f] has been reserved
[    0.316120] system 00:01: [io  0x0cd0-0x0cd1] has been reserved
[    0.316121] system 00:01: [io  0x0cd2-0x0cd3] has been reserved
[    0.316123] system 00:01: [io  0x0cd4-0x0cd5] has been reserved
[    0.316124] system 00:01: [io  0x0cd6-0x0cd7] has been reserved
[    0.316125] system 00:01: [io  0x0cd8-0x0cdf] has been reserved
[    0.316127] system 00:01: [io  0x0800-0x089f] could not be reserved
[    0.316129] system 00:01: [io  0x0b20-0x0b3f] has been reserved
[    0.316130] system 00:01: [io  0x0900-0x090f] has been reserved
[    0.316132] system 00:01: [io  0x0910-0x091f] has been reserved
[    0.316134] system 00:01: [io  0xfe00-0xfefe] has been reserved
[    0.316136] system 00:01: [mem 0xfec00000-0xfec00fff] could not be reser=
ved
[    0.316138] system 00:01: [mem 0xfee00000-0xfee00fff] has been reserved
[    0.316139] system 00:01: [mem 0xfed80000-0xfed8ffff] has been reserved
[    0.316141] system 00:01: [mem 0xfed61000-0xfed70fff] has been reserved
[    0.316144] system 00:01: [mem 0xfec10000-0xfec10fff] has been reserved
[    0.316145] system 00:01: [mem 0xfed00000-0xfed00fff] has been reserved
[    0.316147] system 00:01: [mem 0xffc00000-0xffffffff] has been reserved
[    0.316149] system 00:01: Plug and Play ACPI device, IDs PNP0c02 (active)
[    0.316264] system 00:02: [io  0x0220-0x0227] has been reserved
[    0.316266] system 00:02: [io  0x0228-0x0237] has been reserved
[    0.316267] system 00:02: [io  0x0a20-0x0a2f] has been reserved
[    0.316269] system 00:02: Plug and Play ACPI device, IDs PNP0c02 (active)
[    0.316465] pnp 00:03: [dma 0 disabled]
[    0.316498] pnp 00:03: Plug and Play ACPI device, IDs PNP0501 (active)
[    0.316507] pnp 00:04: [dma 4]
[    0.316520] pnp 00:04: Plug and Play ACPI device, IDs PNP0200 (active)
[    0.316539] pnp 00:05: Plug and Play ACPI device, IDs PNP0b00 (active)
[    0.316557] pnp 00:06: Plug and Play ACPI device, IDs PNP0800 (active)
[    0.316595] system 00:07: [io  0x04d0-0x04d1] has been reserved
[    0.316597] system 00:07: Plug and Play ACPI device, IDs PNP0c02 (active)
[    0.316616] pnp 00:08: Plug and Play ACPI device, IDs PNP0c04 (active)
[    0.316642] system 00:09: Plug and Play ACPI device, IDs PNP0c02 (active)
[    0.316742] system 00:0a: Plug and Play ACPI device, IDs PNP0c02 (active)
[    0.316830] system 00:0b: [mem 0xfec20000-0xfec200ff] could not be reser=
ved
[    0.316832] system 00:0b: Plug and Play ACPI device, IDs PNP0c02 (active)
[    0.316936] pnp 00:0c: Plug and Play ACPI device, IDs PNP0103 (active)
[    0.316938] pnp: PnP ACPI: found 13 devices
[    0.316939] ACPI: bus type PNP unregistered
[    0.323035] pci 0000:00:02.0: PCI bridge to [bus 01]
[    0.323038] pci 0000:00:02.0:   bridge window [io  0xe000-0xefff]
[    0.323040] pci 0000:00:02.0:   bridge window [mem 0xfc000000-0xfd0fffff]
[    0.323043] pci 0000:00:02.0:   bridge window [mem 0xc0000000-0xd1ffffff=
 64bit pref]
[    0.323045] pci 0000:00:04.0: PCI bridge to [bus 02]
[    0.323048] pci 0000:00:04.0:   bridge window [mem 0xfde00000-0xfdefffff]
[    0.323051] pci 0000:00:09.0: PCI bridge to [bus 03]
[    0.323053] pci 0000:00:09.0:   bridge window [io  0xd000-0xdfff]
[    0.323055] pci 0000:00:09.0:   bridge window [mem 0xfdd00000-0xfddfffff]
[    0.323057] pci 0000:00:09.0:   bridge window [mem 0xd2100000-0xd21fffff=
 64bit pref]
[    0.323060] pci 0000:00:0a.0: PCI bridge to [bus 04]
[    0.323062] pci 0000:00:0a.0:   bridge window [mem 0xfd400000-0xfdbfffff]
[    0.323065] pci 0000:00:14.4: PCI bridge to [bus 05]
[    0.323067] pci 0000:00:14.4:   bridge window [io  0xc000-0xcfff]
[    0.323071] pci 0000:00:14.4:   bridge window [mem 0xfdc00000-0xfdcfffff]
[    0.323077] pci_bus 0000:00: resource 4 [io  0x0000-0x03af]
[    0.323079] pci_bus 0000:00: resource 5 [io  0x03e0-0x0cf7]
[    0.323080] pci_bus 0000:00: resource 6 [io  0x03b0-0x03df]
[    0.323081] pci_bus 0000:00: resource 7 [io  0x0d00-0xffff]
[    0.323083] pci_bus 0000:00: resource 8 [mem 0x000a0000-0x000bffff]
[    0.323084] pci_bus 0000:00: resource 9 [mem 0x000c0000-0x000dffff]
[    0.323086] pci_bus 0000:00: resource 10 [mem 0xc0000000-0xffffffff]
[    0.323087] pci_bus 0000:01: resource 0 [io  0xe000-0xefff]
[    0.323088] pci_bus 0000:01: resource 1 [mem 0xfc000000-0xfd0fffff]
[    0.323090] pci_bus 0000:01: resource 2 [mem 0xc0000000-0xd1ffffff 64bit=
 pref]
[    0.323091] pci_bus 0000:02: resource 1 [mem 0xfde00000-0xfdefffff]
[    0.323092] pci_bus 0000:03: resource 0 [io  0xd000-0xdfff]
[    0.323094] pci_bus 0000:03: resource 1 [mem 0xfdd00000-0xfddfffff]
[    0.323095] pci_bus 0000:03: resource 2 [mem 0xd2100000-0xd21fffff 64bit=
 pref]
[    0.323096] pci_bus 0000:04: resource 1 [mem 0xfd400000-0xfdbfffff]
[    0.323098] pci_bus 0000:05: resource 0 [io  0xc000-0xcfff]
[    0.323099] pci_bus 0000:05: resource 1 [mem 0xfdc00000-0xfdcfffff]
[    0.323100] pci_bus 0000:05: resource 4 [io  0x0000-0x03af]
[    0.323102] pci_bus 0000:05: resource 5 [io  0x03e0-0x0cf7]
[    0.323103] pci_bus 0000:05: resource 6 [io  0x03b0-0x03df]
[    0.323104] pci_bus 0000:05: resource 7 [io  0x0d00-0xffff]
[    0.323105] pci_bus 0000:05: resource 8 [mem 0x000a0000-0x000bffff]
[    0.323107] pci_bus 0000:05: resource 9 [mem 0x000c0000-0x000dffff]
[    0.323108] pci_bus 0000:05: resource 10 [mem 0xc0000000-0xffffffff]
[    0.323188] NET: Registered protocol family 2
[    0.323466] TCP established hash table entries: 131072 (order: 9, 209715=
2 bytes)
[    0.323874] TCP bind hash table entries: 65536 (order: 8, 1048576 bytes)
[    0.324041] TCP: Hash tables configured (established 131072 bind 65536)
[    0.324065] TCP: reno registered
[    0.324083] UDP hash table entries: 8192 (order: 6, 262144 bytes)
[    0.324144] UDP-Lite hash table entries: 8192 (order: 6, 262144 bytes)
[    0.324292] NET: Registered protocol family 1
[    0.646409] pci 0000:01:00.0: Boot video device
[    0.646625] PCI: CLS 64 bytes, default 64
[    0.646654] Unpacking initramfs...
[    0.863943] Freeing initrd memory: 14440K (ffff8800363bc000 - ffff880037=
1d6000)
[    0.864306] PCI-DMA: Disabling AGP.
[    0.864374] PCI-DMA: aperture base @ f8000000 size 65536 KB
[    0.864375] init_memory_mapping: [mem 0xf8000000-0xfbffffff]
[    0.864377]  [mem 0xf8000000-0xfbffffff] page 2M
[    0.864384] PCI-DMA: using GART IOMMU.
[    0.864386] PCI-DMA: Reserving 64MB of IOMMU area in the AGP aperture
[    0.868899] perf: AMD NB counters detected
[    0.868922] LVT offset 0 assigned for vector 0x400
[    0.868941] perf: AMD IBS detected (0x000000ff)
[    0.868975] microcode: CPU0: patch_level=3D0x06000822
[    0.868982] microcode: CPU1: patch_level=3D0x06000822
[    0.868990] microcode: CPU2: patch_level=3D0x06000822
[    0.868997] microcode: CPU3: patch_level=3D0x06000822
[    0.869001] microcode: CPU4: patch_level=3D0x06000822
[    0.869006] microcode: CPU5: patch_level=3D0x06000822
[    0.869069] microcode: Microcode Update Driver: v2.00 <tigran@aivazian.f=
snet.co.uk>, Peter Oruba
[    0.869301] audit: initializing netlink socket (disabled)
[    0.869315] type=3D2000 audit(1390461592.756:1): initialized
[    0.878684] HugeTLB registered 2 MB page size, pre-allocated 0 pages
[    0.879658] VFS: Disk quotas dquot_6.5.2
[    0.879681] Dquot-cache hash table entries: 512 (order 0, 4096 bytes)
[    0.879744] msgmni has been set to 32225
[    0.879999] alg: No test for stdrng (krng)
[    0.880023] Block layer SCSI generic (bsg) driver version 0.4 loaded (ma=
jor 252)
[    0.880062] io scheduler noop registered
[    0.880064] io scheduler deadline registered
[    0.880086] io scheduler cfq registered (default)
[    0.880360] pci_hotplug: PCI Hot Plug PCI Core version: 0.5
[    0.880371] pciehp: PCI Express Hot Plug Controller Driver version: 0.4
[    0.880406] GHES: HEST is not enabled!
[    0.880444] Serial: 8250/16550 driver, 4 ports, IRQ sharing enabled
[    0.900773] 00:03: ttyS0 at I/O 0x3f8 (irq =3D 4, base_baud =3D 115200) =
is a 16550A
[    0.901061] Linux agpgart interface v0.103
[    0.901123] i8042: PNP: No PS/2 controller found. Probing ports directly.
[    0.901470] serio: i8042 KBD port at 0x60,0x64 irq 1
[    0.901476] serio: i8042 AUX port at 0x60,0x64 irq 12
[    0.901588] mousedev: PS/2 mouse device common for all mice
[    0.901614] rtc_cmos 00:05: RTC can wake from S4
[    0.901704] rtc_cmos 00:05: rtc core: registered rtc_cmos as rtc0
[    0.901724] rtc_cmos 00:05: alarms up to one month, y3k, 114 bytes nvram=
, hpet irqs
[    0.901733] AMD IOMMUv2 driver by Joerg Roedel <joerg.roedel@amd.com>
[    0.901734] AMD IOMMUv2 functionality not available on this system
[    0.901795] TCP: cubic registered
[    0.901860] NET: Registered protocol family 10
[    0.902003] mip6: Mobile IPv6
[    0.902004] NET: Registered protocol family 17
[    0.902007] mpls_gso: MPLS GSO support
[    0.902382] registered taskstats version 1
[    0.903410] rtc_cmos 00:05: setting system clock to 2014-01-23 07:19:53 =
UTC (1390461593)
[    0.903443] PM: Hibernation image not present or could not be loaded.
[    0.904021] Freeing unused kernel memory: 972K (ffffffff818ab000 - fffff=
fff8199e000)
[    0.904023] Write protecting the kernel read-only data: 8192k
[    0.906309] Freeing unused kernel memory: 1408K (ffff8800014a0000 - ffff=
880001600000)
[    0.907026] Freeing unused kernel memory: 452K (ffff88000178f000 - ffff8=
80001800000)
[    0.915094] systemd-udevd[78]: starting version 204
[    0.927238] ACPI: bus type USB registered
[    0.927265] usbcore: registered new interface driver usbfs
[    0.927275] usbcore: registered new interface driver hub
[    0.928722] SCSI subsystem initialized
[    0.932320] libata version 3.00 loaded.
[    0.932522] r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
[    0.932535] r8169 0000:03:00.0: can't disable ASPM; OS doesn't have ASPM=
 control
[    0.932541] pcieport 0000:00:09.0: driver skip pci_set_master, fix it!
[    0.932808] r8169 0000:03:00.0: irq 72 for MSI/MSI-X
[    0.932985] r8169 0000:03:00.0 eth0: RTL8168evl/8111evl at 0xffffc900018=
20000, 94:de:80:bf:e9:8b, XID 0c900800 IRQ 72
[    0.932988] r8169 0000:03:00.0 eth0: jumbo features [frames: 9200 bytes,=
 tx checksumming: ko]
[    0.933068] usbcore: registered new device driver usb
[    0.933167] ahci 0000:00:11.0: version 3.0
[    0.933343] ahci 0000:00:11.0: AHCI 0001.0200 32 slots 6 ports 6 Gbps 0x=
3f impl SATA mode
[    0.933346] ahci 0000:00:11.0: flags: 64bit ncq sntf ilck pm led clo pmp=
 pio slum part=20
[    0.933759] xhci_hcd 0000:02:00.0: xHCI Host Controller
[    0.933768] xhci_hcd 0000:02:00.0: new USB bus registered, assigned bus =
number 1
[    0.933857] xhci_hcd 0000:02:00.0: irq 73 for MSI/MSI-X
[    0.933914] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
[    0.934155] ehci-pci: EHCI PCI platform driver
[    0.934322] ohci_hcd: USB 1.1 'Open' Host Controller (OHCI) Driver
[    0.934492] usb usb1: New USB device found, idVendor=3D1d6b, idProduct=
=3D0002
[    0.934494] usb usb1: New USB device strings: Mfr=3D3, Product=3D2, Seri=
alNumber=3D1
[    0.934496] usb usb1: Product: xHCI Host Controller
[    0.934498] usb usb1: Manufacturer: Linux 3.12-1-amd64 xhci_hcd
[    0.934500] usb usb1: SerialNumber: 0000:02:00.0
[    0.934570] ohci-pci: OHCI PCI platform driver
[    0.934648] hub 1-0:1.0: USB hub found
[    0.934657] hub 1-0:1.0: 1 port detected
[    0.934758] xhci_hcd 0000:02:00.0: xHCI Host Controller
[    0.934761] xhci_hcd 0000:02:00.0: new USB bus registered, assigned bus =
number 2
[    0.934806] usb usb2: New USB device found, idVendor=3D1d6b, idProduct=
=3D0003
[    0.934808] usb usb2: New USB device strings: Mfr=3D3, Product=3D2, Seri=
alNumber=3D1
[    0.934810] usb usb2: Product: xHCI Host Controller
[    0.934812] usb usb2: Manufacturer: Linux 3.12-1-amd64 xhci_hcd
[    0.934814] usb usb2: SerialNumber: 0000:02:00.0
[    0.934935] hub 2-0:1.0: USB hub found
[    0.934944] hub 2-0:1.0: 4 ports detected
[    0.935295] scsi0 : ahci
[    0.935596] scsi1 : ahci
[    0.935667] scsi2 : ahci
[    0.935744] scsi3 : ahci
[    0.935807] scsi4 : ahci
[    0.935897] scsi5 : ahci
[    0.935941] ata1: SATA max UDMA/133 abar m1024@0xfd10b000 port 0xfd10b10=
0 irq 19
[    0.935944] ata2: SATA max UDMA/133 abar m1024@0xfd10b000 port 0xfd10b18=
0 irq 19
[    0.935946] ata3: SATA max UDMA/133 abar m1024@0xfd10b000 port 0xfd10b20=
0 irq 19
[    0.935949] ata4: SATA max UDMA/133 abar m1024@0xfd10b000 port 0xfd10b28=
0 irq 19
[    0.935951] ata5: SATA max UDMA/133 abar m1024@0xfd10b000 port 0xfd10b30=
0 irq 19
[    0.935954] ata6: SATA max UDMA/133 abar m1024@0xfd10b000 port 0xfd10b38=
0 irq 19
[    0.936069] ehci-pci 0000:00:12.2: EHCI Host Controller
[    0.936076] ehci-pci 0000:00:12.2: new USB bus registered, assigned bus =
number 3
[    0.936087] QUIRK: Enable AMD PLL fix
[    0.936089] ehci-pci 0000:00:12.2: applying AMD SB700/SB800/Hudson-2/3 E=
HCI dummy qh workaround
[    0.936099] ehci-pci 0000:00:12.2: debug port 1
[    0.936131] ehci-pci 0000:00:12.2: irq 17, io mem 0xfd109000
[    0.940175] 8139too: 8139too Fast Ethernet driver 0.9.28
[    0.940761] 8139too 0000:05:07.0 eth1: RealTek RTL8139 at 0xffffc90011bc=
c000, 00:04:e2:12:1c:ea, IRQ 21
[    0.946006] ehci-pci 0000:00:12.2: USB 2.0 started, EHCI 1.00
[    0.946050] usb usb3: New USB device found, idVendor=3D1d6b, idProduct=
=3D0002
[    0.946052] usb usb3: New USB device strings: Mfr=3D3, Product=3D2, Seri=
alNumber=3D1
[    0.946054] usb usb3: Product: EHCI Host Controller
[    0.946056] usb usb3: Manufacturer: Linux 3.12-1-amd64 ehci_hcd
[    0.946058] usb usb3: SerialNumber: 0000:00:12.2
[    0.946218] hub 3-0:1.0: USB hub found
[    0.946227] hub 3-0:1.0: 5 ports detected
[    0.946495] ehci-pci 0000:00:13.2: EHCI Host Controller
[    0.946507] ehci-pci 0000:00:13.2: new USB bus registered, assigned bus =
number 4
[    0.946511] ehci-pci 0000:00:13.2: applying AMD SB700/SB800/Hudson-2/3 E=
HCI dummy qh workaround
[    0.946521] ehci-pci 0000:00:13.2: debug port 1
[    0.946543] ehci-pci 0000:00:13.2: irq 17, io mem 0xfd107000
[    0.958033] ehci-pci 0000:00:13.2: USB 2.0 started, EHCI 1.00
[    0.958134] usb usb4: New USB device found, idVendor=3D1d6b, idProduct=
=3D0002
[    0.958137] usb usb4: New USB device strings: Mfr=3D3, Product=3D2, Seri=
alNumber=3D1
[    0.958139] usb usb4: Product: EHCI Host Controller
[    0.958140] usb usb4: Manufacturer: Linux 3.12-1-amd64 ehci_hcd
[    0.958141] usb usb4: SerialNumber: 0000:00:13.2
[    0.958238] hub 4-0:1.0: USB hub found
[    0.958252] hub 4-0:1.0: 5 ports detected
[    0.958465] ehci-pci 0000:00:16.2: EHCI Host Controller
[    0.958469] ehci-pci 0000:00:16.2: new USB bus registered, assigned bus =
number 5
[    0.958472] ehci-pci 0000:00:16.2: applying AMD SB700/SB800/Hudson-2/3 E=
HCI dummy qh workaround
[    0.958480] ehci-pci 0000:00:16.2: debug port 1
[    0.958500] ehci-pci 0000:00:16.2: irq 17, io mem 0xfd104000
[    0.970058] ehci-pci 0000:00:16.2: USB 2.0 started, EHCI 1.00
[    0.970137] usb usb5: New USB device found, idVendor=3D1d6b, idProduct=
=3D0002
[    0.970139] usb usb5: New USB device strings: Mfr=3D3, Product=3D2, Seri=
alNumber=3D1
[    0.970141] usb usb5: Product: EHCI Host Controller
[    0.970142] usb usb5: Manufacturer: Linux 3.12-1-amd64 ehci_hcd
[    0.970143] usb usb5: SerialNumber: 0000:00:16.2
[    0.970233] hub 5-0:1.0: USB hub found
[    0.970245] hub 5-0:1.0: 4 ports detected
[    0.970448] ohci-pci 0000:00:12.0: OHCI PCI host controller
[    0.970453] ohci-pci 0000:00:12.0: new USB bus registered, assigned bus =
number 6
[    0.970476] ohci-pci 0000:00:12.0: irq 18, io mem 0xfd10a000
[    1.029982] usb usb6: New USB device found, idVendor=3D1d6b, idProduct=
=3D0001
[    1.029984] usb usb6: New USB device strings: Mfr=3D3, Product=3D2, Seri=
alNumber=3D1
[    1.029986] usb usb6: Product: OHCI PCI host controller
[    1.029987] usb usb6: Manufacturer: Linux 3.12-1-amd64 ohci_hcd
[    1.029988] usb usb6: SerialNumber: 0000:00:12.0
[    1.030076] hub 6-0:1.0: USB hub found
[    1.030084] hub 6-0:1.0: 5 ports detected
[    1.030222] ohci-pci 0000:00:13.0: OHCI PCI host controller
[    1.030227] ohci-pci 0000:00:13.0: new USB bus registered, assigned bus =
number 7
[    1.030239] ohci-pci 0000:00:13.0: irq 18, io mem 0xfd108000
[    1.089918] usb usb7: New USB device found, idVendor=3D1d6b, idProduct=
=3D0001
[    1.089920] usb usb7: New USB device strings: Mfr=3D3, Product=3D2, Seri=
alNumber=3D1
[    1.089921] usb usb7: Product: OHCI PCI host controller
[    1.089923] usb usb7: Manufacturer: Linux 3.12-1-amd64 ohci_hcd
[    1.089924] usb usb7: SerialNumber: 0000:00:13.0
[    1.090009] hub 7-0:1.0: USB hub found
[    1.090016] hub 7-0:1.0: 5 ports detected
[    1.090145] ohci-pci 0000:00:14.5: OHCI PCI host controller
[    1.090149] ohci-pci 0000:00:14.5: new USB bus registered, assigned bus =
number 8
[    1.090160] ohci-pci 0000:00:14.5: irq 18, io mem 0xfd106000
[    1.149873] usb usb8: New USB device found, idVendor=3D1d6b, idProduct=
=3D0001
[    1.149875] usb usb8: New USB device strings: Mfr=3D3, Product=3D2, Seri=
alNumber=3D1
[    1.149876] usb usb8: Product: OHCI PCI host controller
[    1.149877] usb usb8: Manufacturer: Linux 3.12-1-amd64 ohci_hcd
[    1.149879] usb usb8: SerialNumber: 0000:00:14.5
[    1.149961] hub 8-0:1.0: USB hub found
[    1.149967] hub 8-0:1.0: 2 ports detected
[    1.150078] ohci-pci 0000:00:16.0: OHCI PCI host controller
[    1.150082] ohci-pci 0000:00:16.0: new USB bus registered, assigned bus =
number 9
[    1.150092] ohci-pci 0000:00:16.0: irq 18, io mem 0xfd105000
[    1.209844] usb usb9: New USB device found, idVendor=3D1d6b, idProduct=
=3D0001
[    1.209847] usb usb9: New USB device strings: Mfr=3D3, Product=3D2, Seri=
alNumber=3D1
[    1.209849] usb usb9: Product: OHCI PCI host controller
[    1.209850] usb usb9: Manufacturer: Linux 3.12-1-amd64 ohci_hcd
[    1.209851] usb usb9: SerialNumber: 0000:00:16.0
[    1.209936] hub 9-0:1.0: USB hub found
[    1.209944] hub 9-0:1.0: 4 ports detected
[    1.245819] usb 1-1: new high-speed USB device number 2 using xhci_hcd
[    1.253828] ata5: SATA link down (SStatus 0 SControl 300)
[    1.253868] ata6: SATA link down (SStatus 0 SControl 300)
[    1.262996] usb 1-1: New USB device found, idVendor=3D2109, idProduct=3D=
3431
[    1.262999] usb 1-1: New USB device strings: Mfr=3D0, Product=3D1, Seria=
lNumber=3D0
[    1.263001] usb 1-1: Product: USB2.0 Hub
[    1.263429] hub 1-1:1.0: USB hub found
[    1.263524] hub 1-1:1.0: 4 ports detected
[    1.425671] ata1: SATA link up 6.0 Gbps (SStatus 133 SControl 300)
[    1.425691] ata3: SATA link up 6.0 Gbps (SStatus 133 SControl 300)
[    1.425708] ata4: SATA link up 1.5 Gbps (SStatus 113 SControl 300)
[    1.425725] ata2: SATA link up 6.0 Gbps (SStatus 133 SControl 300)
[    1.426210] ata3.00: ATA-9: WDC WD30EFRX-68EUZN0, 80.00A80, max UDMA/133
[    1.426212] ata3.00: 5860533168 sectors, multi 16: LBA48 NCQ (depth 31/3=
2), AA
[    1.426285] ata2.00: ATA-9: WDC WD30EFRX-68EUZN0, 80.00A80, max UDMA/133
[    1.426288] ata2.00: 5860533168 sectors, multi 16: LBA48 NCQ (depth 31/3=
2), AA
[    1.426539] ata1.00: ATA-8: SanDisk SDSSDHP128G, X2306RL, max UDMA/133
[    1.426541] ata1.00: 250069680 sectors, multi 1: LBA48 NCQ (depth 31/32)=
, AA
[    1.426793] ata3.00: configured for UDMA/133
[    1.426839] ata2.00: configured for UDMA/133
[    1.427276] ata4.00: ATAPI: ATAPI   iHAS324   Y, BL1Y, max UDMA/100
[    1.427430] ata1.00: configured for UDMA/133
[    1.427557] scsi 0:0:0:0: Direct-Access     ATA      SanDisk SDSSDHP1 X2=
30 PQ: 0 ANSI: 5
[    1.427744] scsi 1:0:0:0: Direct-Access     ATA      WDC WD30EFRX-68E 80=
=2E0 PQ: 0 ANSI: 5
[    1.427879] scsi 2:0:0:0: Direct-Access     ATA      WDC WD30EFRX-68E 80=
=2E0 PQ: 0 ANSI: 5
[    1.429123] ata4.00: configured for UDMA/100
[    1.430910] scsi 3:0:0:0: CD-ROM            ATAPI    iHAS324   Y      BL=
1Y PQ: 0 ANSI: 5
[    1.434995] sd 0:0:0:0: [sda] 250069680 512-byte logical blocks: (128 GB=
/119 GiB)
[    1.435025] sd 2:0:0:0: [sdc] 5860533168 512-byte logical blocks: (3.00 =
TB/2.72 TiB)
[    1.435029] sd 2:0:0:0: [sdc] 4096-byte physical blocks
[    1.435040] sd 1:0:0:0: [sdb] 5860533168 512-byte logical blocks: (3.00 =
TB/2.72 TiB)
[    1.435042] sd 1:0:0:0: [sdb] 4096-byte physical blocks
[    1.435101] sd 0:0:0:0: [sda] Write Protect is off
[    1.435104] sd 0:0:0:0: [sda] Mode Sense: 00 3a 00 00
[    1.435114] sd 2:0:0:0: [sdc] Write Protect is off
[    1.435116] sd 2:0:0:0: [sdc] Mode Sense: 00 3a 00 00
[    1.435126] sd 1:0:0:0: [sdb] Write Protect is off
[    1.435128] sd 1:0:0:0: [sdb] Mode Sense: 00 3a 00 00
[    1.435133] sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled,=
 doesn't support DPO or FUA
[    1.435148] sd 2:0:0:0: [sdc] Write cache: enabled, read cache: enabled,=
 doesn't support DPO or FUA
[    1.435159] sd 1:0:0:0: [sdb] Write cache: enabled, read cache: enabled,=
 doesn't support DPO or FUA
[    1.435675]  sda: sda1
[    1.435795] sr0: scsi3-mmc drive: 48x/48x writer dvd-ram cd/rw xa/form2 =
cdda tray
[    1.435797] cdrom: Uniform CD-ROM driver Revision: 3.20
[    1.435882] sr 3:0:0:0: Attached scsi CD-ROM sr0
[    1.435918] sd 0:0:0:0: [sda] Attached SCSI disk
[    1.437160] sd 0:0:0:0: Attached scsi generic sg0 type 0
[    1.437201] sd 1:0:0:0: Attached scsi generic sg1 type 0
[    1.437237] sd 2:0:0:0: Attached scsi generic sg2 type 0
[    1.437274] sr 3:0:0:0: Attached scsi generic sg3 type 5
[    1.490606]  sdc: sdc1 sdc2
[    1.490896] sd 2:0:0:0: [sdc] Attached SCSI disk
[    1.492053]  sdb: sdb1 sdb2
[    1.492299] sd 1:0:0:0: [sdb] Attached SCSI disk
[    1.541695] usb 1-1.1: new low-speed USB device number 3 using xhci_hcd
[    1.623456] platform microcode: firmware: direct-loading firmware amd-uc=
ode/microcode_amd_fam15h.bin
[    1.626436] device-mapper: uevent: version 1.0.3
[    1.626502] device-mapper: ioctl: 4.26.0-ioctl (2013-08-15) initialised:=
 dm-devel@redhat.com
[    1.632063] PM: Starting manual resume from disk
[    1.632065] PM: Hibernation image partition 8:17 present
[    1.632066] PM: Looking for hibernation image.
[    1.632182] PM: Image not found (code -22)
[    1.632184] PM: Hibernation image not present or could not be loaded.
[    1.639695] EXT4-fs (sda1): mounted filesystem with ordered data mode. O=
pts: (null)
[    1.809802] systemd-udevd[411]: starting version 204
[    1.862820] input: Power Button as /devices/LNXSYSTM:00/device:00/PNP0C0=
C:00/input/input2
[    1.862827] ACPI: Power Button [PWRB]
[    1.862993] input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/inpu=
t/input3
[    1.862996] ACPI: Power Button [PWRF]
[    1.863781] ACPI: acpi_idle registered with cpuidle
[    1.865297] tsc: Refined TSC clocksource calibration: 3516.188 MHz
[    1.868024] acpi-cpufreq: overriding BIOS provided _PSD data
[    1.869655] media: Linux media interface: v0.10
[    1.871791] Linux video capture interface: v2.00
[    1.879732] [drm] Initialized drm 1.1.0 20060810
[    1.879905] saa7164 driver loaded
[    1.879987] pcieport 0000:00:0a.0: driver skip pci_set_master, fix it!
[    1.880578] CORE saa7164[0]: subsystem: 0070:8940, board: Hauppauge WinT=
V-HVR2200 [card=3D9,autodetected]
[    1.880583] saa7164[0]/0: found at 0000:04:00.0, rev: 129, irq: 47, late=
ncy: 0, mmio: 0xfd800000
[    1.885771] wmi: Mapper loaded
[    1.890877] systemd-udevd[450]: renamed network interface eth0 to eth6
[    1.895100] EDAC MC: Ver: 3.0.0
[    1.895900] MCE: In-kernel MCE decoding enabled.
[    1.897849] AMD64 EDAC driver v3.4.0
[    1.898460] input: PC Speaker as /devices/platform/pcspkr/input/input4
[    1.898850] pcieport 0000:00:02.0: driver skip pci_set_master, fix it!
[    1.899182] nouveau  [  DEVICE][0000:01:00.0] BOOT0  : 0x0a8280b1
[    1.899185] nouveau  [  DEVICE][0000:01:00.0] Chipset: GT218 (NVA8)
[    1.899187] nouveau  [  DEVICE][0000:01:00.0] Family : NV50
[    1.900135] Error: Driver 'pcspkr' is already registered, aborting...
[    1.900572] nouveau  [   VBIOS][0000:01:00.0] checking PRAMIN for image.=
=2E.
[    1.906763] input: HDA ATI SB Front Headphone as /devices/pci0000:00/000=
0:00:14.2/sound/card0/input13
[    1.906798] input: HDA ATI SB Line Out Side as /devices/pci0000:00/0000:=
00:14.2/sound/card0/input12
[    1.906821] input: HDA ATI SB Line Out CLFE as /devices/pci0000:00/0000:=
00:14.2/sound/card0/input11
[    1.906846] input: HDA ATI SB Line Out Surround as /devices/pci0000:00/0=
000:00:14.2/sound/card0/input10
[    1.906869] input: HDA ATI SB Line Out Front as /devices/pci0000:00/0000=
:00:14.2/sound/card0/input9
[    1.906893] input: HDA ATI SB Line as /devices/pci0000:00/0000:00:14.2/s=
ound/card0/input8
[    1.906915] input: HDA ATI SB Rear Mic as /devices/pci0000:00/0000:00:14=
=2E2/sound/card0/input7
[    1.906939] input: HDA ATI SB Front Mic as /devices/pci0000:00/0000:00:1=
4.2/sound/card0/input6
[    1.907238] piix4_smbus 0000:00:14.0: SMBus Host Controller at 0xb00, re=
vision 0
[    1.907276] piix4_smbus 0000:00:14.0: SMBus Host Controller at 0xb20
[    1.909335] EDAC amd64: DRAM ECC disabled.
[    1.909386] EDAC amd64: ECC disabled in the BIOS or no ECC capability, m=
odule will not load.
[    1.909386]  Either enable ECC checking or force module loading by setti=
ng 'ecc_enable_override'.
[    1.909386]  (Note that use of the override may cause unknown side effec=
ts.)
[    1.909746] sp5100_tco: SP5100/SB800 TCO WatchDog Timer Driver v0.05
[    1.909788] sp5100_tco: PCI Revision ID: 0x42
[    1.909832] sp5100_tco: Using 0xfed80b00 for watchdog MMIO address
[    1.909852] sp5100_tco: Last reboot was not triggered by watchdog.
[    1.909882] sp5100_tco: initialized (0xffffc90001872b00). heartbeat=3D60=
 sec (nowayout=3D0)
[    1.927727] alg: No test for __gcm-aes-aesni (__driver-gcm-aes-aesni)
[    1.932359] alg: No test for crc32 (crc32-pclmul)
[    1.940239] kvm: Nested Virtualization enabled
[    1.940244] kvm: Nested Paging enabled
[    1.941607] md: bind<sdc2>
[    1.964425] md: bind<sdb2>
[    1.966264] md: raid1 personality registered for level 1
[    1.966533] md/raid1:md0: active with 2 out of 2 mirrors
[    1.966613] created bitmap (22 pages) for device md0
[    1.966977] md0: bitmap initialized from disk: read 2 pages, set 0 of 44=
583 bits
[    1.978680] nouveau  [   VBIOS][0000:01:00.0] ... appears to be valid
[    1.978682] nouveau  [   VBIOS][0000:01:00.0] using image from PRAMIN
[    1.978778] nouveau  [   VBIOS][0000:01:00.0] BIT signature found
[    1.978780] nouveau  [   VBIOS][0000:01:00.0] version 70.18.5f.00.06
[    1.979013] nouveau  [     PFB][0000:01:00.0] RAM type: DDR3
[    1.979015] nouveau  [     PFB][0000:01:00.0] RAM size: 1024 MiB
[    1.979016] nouveau  [     PFB][0000:01:00.0]    ZCOMP: 960 tags
[    1.979685] md0: detected capacity change from 0 to 2991867756544
[    1.985049]  md0: unknown partition table
[    1.999120] systemd-udevd[453]: renamed network interface eth1 to eth5
[    2.045224] saa7164_downloadfirmware() no first image
[    2.045303] saa7164_downloadfirmware() Waiting for firmware upload (NXP7=
164-2010-03-10.1.fw)
[    2.056245] saa7164 0000:04:00.0: firmware: direct-loading firmware NXP7=
164-2010-03-10.1.fw
[    2.056254] saa7164_downloadfirmware() firmware read 4019072 bytes.
[    2.056257] saa7164_downloadfirmware() firmware loaded.
[    2.056259] Firmware file header part 1:
[    2.056261]  .FirmwareSize =3D 0x0
[    2.056263]  .BSLSize =3D 0x0
[    2.056265]  .Reserved =3D 0x3d538
[    2.056267]  .Version =3D 0x3
[    2.056270] saa7164_downloadfirmware() SecBootLoader.FileSize =3D 4019072
[    2.056277] saa7164_downloadfirmware() FirmwareSize =3D 0x1fd6
[    2.056279] saa7164_downloadfirmware() BSLSize =3D 0x0
[    2.056281] saa7164_downloadfirmware() Reserved =3D 0x0
[    2.056283] saa7164_downloadfirmware() Version =3D 0x1661c00
[    2.876553] Switched to clocksource tsc
[    3.260222] nouveau  [  PTHERM][0000:01:00.0] FAN control: none / extern=
al
[    3.260228] nouveau  [  PTHERM][0000:01:00.0] fan management: disabled
[    3.260231] nouveau  [  PTHERM][0000:01:00.0] internal sensor: yes
[    3.260398] [TTM] Zone  kernel: Available graphics memory: 8251236 kiB
[    3.260400] [TTM] Zone   dma32: Available graphics memory: 2097152 kiB
[    3.260401] [TTM] Initializing pool allocator
[    3.260404] [TTM] Initializing DMA pool allocator
[   18.669471] it87: Found IT8728F chip at 0x228, revision 1
[   18.669486] it87: Beeping is supported
[   19.975949] 8139too 0000:05:07.0 eth5: link up, 100Mbps, full-duplex, lp=
a 0xC5E1
[   83.447039] r8169 0000:03:00.0: firmware: direct-loading firmware rtl_ni=
c/rtl8168e-3.fw
[   83.564436] r8169 0000:03:00.0 eth6: link down
[   83.564468] r8169 0000:03:00.0 eth6: link down
[   83.564484] IPv6: ADDRCONF(NETDEV_UP): eth6: link is not ready
[   86.701238] r8169 0000:03:00.0 eth6: link up
[   86.701249] IPv6: ADDRCONF(NETDEV_CHANGE): eth6: link becomes ready
[  866.212244] ------------[ cut here ]------------
[  866.212258] WARNING: CPU: 5 PID: 0 at /build/linux-xS3nxO/linux-3.12.6/n=
et/sched/sch_generic.c:264 dev_watchdog+0x226/0x230()
[  866.212262] NETDEV WATCHDOG: eth6 (r8169): transmit queue 0 timed out
[  866.212264] Modules linked in: bnep rfcomm bluetooth rfkill vhost_net vh=
ost macvtap macvlan tun xt_multiport ipt_MASQUERADE xt_CHECKSUM iptable_man=
gle bridge stp llc ebtable_nat ebtables parport_pc ppdev lp parport binfmt_=
misc ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 ip6table_filter ip6_table=
s xt_REDIRECT iptable_nat nf_nat_ipv4 nf_nat ipt_REJECT xt_tcpudp xt_LOG xt=
_mac nf_conntrack_ipv4 nf_defrag_ipv4 xt_conntrack nf_conntrack iptable_fil=
ter ip_tables x_tables fuse it87 hwmon_vid loop tda18271 tda10048 joydev hi=
d_generic snd_hda_codec_hdmi usbhid hid raid1 evdev kvm_amd md_mod kvm crc3=
2_pclmul crc32c_intel ghash_clmulni_intel aesni_intel aes_x86_64 ablk_helpe=
r cryptd lrw sp5100_tco gf128mul glue_helper fam15h_power k10temp psmouse p=
cspkr serio_raw nouveau edac_mce_amd edac_core i2c_piix4 snd_hda_codec_via =
mxm_wmi wmi video ttm drm_kms_helper saa7164 snd_hda_intel tveeprom dvb_cor=
e drm snd_hda_codec v4l2_common videodev snd_hwdep media snd_pcm i2c_algo_b=
it acpi_cpufreq snd_page_alloc i2c_core snd_timer snd processor soundcore b=
utton thermal_sys ext4 crc16 mbcache jbd2 dm_mod sg sd_mod sr_mod cdrom crc=
_t10dif crct10dif_common 8139too ohci_pci ohci_hcd ehci_pci ehci_hcd xhci_h=
cd ahci libahci r8169 mii libata scsi_mod usbcore usb_common
[  866.212380] CPU: 5 PID: 0 Comm: swapper/5 Not tainted 3.12-1-amd64 #1 De=
bian 3.12.6-2
[  866.212383] Hardware name: Gigabyte Technology Co., Ltd. To be filled by=
 O.E.M./970A-D3P, BIOS F3 05/24/2013
[  866.212386]  0000000000000009 ffffffff8148c9d5 ffff88043ed43df0 ffffffff=
8105b572
[  866.212392]  0000000000000000 ffff88043ed43e40 0000000000000001 00000000=
00000005
[  866.212397]  ffff88042a4d4000 ffffffff8105b5d7 ffffffff81742f20 ffff8804=
00000030
[  866.212402] Call Trace:
[  866.212405]  <IRQ>  [<ffffffff8148c9d5>] ? dump_stack+0x41/0x51
[  866.212419]  [<ffffffff8105b572>] ? warn_slowpath_common+0x72/0x90
[  866.212425]  [<ffffffff8105b5d7>] ? warn_slowpath_fmt+0x47/0x50
[  866.212437]  [<ffffffff813c86d6>] ? dev_watchdog+0x226/0x230
[  866.212442]  [<ffffffff813c84b0>] ? dev_graft_qdisc+0x70/0x70
[  866.212447]  [<ffffffff81066a3c>] ? call_timer_fn+0x2c/0x100
[  866.212452]  [<ffffffff813c84b0>] ? dev_graft_qdisc+0x70/0x70
[  866.212457]  [<ffffffff81067879>] ? run_timer_softirq+0x1f9/0x2b0
[  866.212466]  [<ffffffff8106071d>] ? __do_softirq+0xed/0x230
[  866.212476]  [<ffffffff8149b3dc>] ? call_softirq+0x1c/0x30
[  866.212482]  [<ffffffff810143b5>] ? do_softirq+0x55/0x90
[  866.212487]  [<ffffffff810609b5>] ? irq_exit+0x95/0xa0
[  866.212493]  [<ffffffff8103debb>] ? smp_apic_timer_interrupt+0x3b/0x50
[  866.212498]  [<ffffffff8149a71d>] ? apic_timer_interrupt+0x6d/0x80
[  866.212500]  <EOI>  [<ffffffff81377efa>] ? cpuidle_enter_state+0x4a/0xc0
[  866.212514]  [<ffffffff81378026>] ? cpuidle_idle_call+0xb6/0x1f0
[  866.212520]  [<ffffffff8101ae95>] ? arch_cpu_idle+0x5/0x30
[  866.212525]  [<ffffffff810a453e>] ? cpu_startup_entry+0xde/0x270
[  866.212531]  [<ffffffff8103c354>] ? start_secondary+0x1d4/0x230
[  866.212534] ---[ end trace cd522523d6e120ac ]---
[  866.230696] r8169 0000:03:00.0 eth6: link up
[ 1729.580858] r8169 0000:03:00.0 eth6: link up

--NzB8fVQJ5HfG6fxh--
