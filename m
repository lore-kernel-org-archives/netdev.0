From: Fengguang Wu <fengguang.wu@intel.com>
Subject: [genetlink] WARNING: CPU: 0 PID: 109 at net/netlink/genetlink.c:1011
 genl_bind()
Date: Sat, 27 Dec 2014 16:38:38 -0800
Message-ID: <20141228003838.GA21557@wfg-t540p.sh.intel.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="OgqxwSJOaUobr8KG"
Cc: LKP <lkp@01.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Johannes Berg <johannes.berg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:8861 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751425AbaL1Aiy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 27 Dec 2014 19:38:54 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--OgqxwSJOaUobr8KG
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Greetings,

0day kernel testing robot got the below dmesg and the first bad commit is

commit c380d9a7afff0e4c2e5f3c1c2dc7d2f4214dd962
Author:     Johannes Berg <johannes.berg@intel.com>
AuthorDate: Tue Dec 23 20:54:40 2014 +0100
Commit:     David S. Miller <davem@davemloft.net>
CommitDate: Sat Dec 27 02:20:23 2014 -0500

    genetlink: pass multicast bind/unbind to families
    
    In order to make the newly fixed multicast bind/unbind
    functionality in generic netlink, pass them down to the
    appropriate family.
    
    Signed-off-by: Johannes Berg <johannes.berg@intel.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

+---------------------------------------------------+------------+------------+------------+
|                                                   | 7d68536bed | c380d9a7af | bdf7b239ea |
+---------------------------------------------------+------------+------------+------------+
| boot_successes                                    | 279        | 34         | 0          |
| boot_failures                                     | 0          | 59         | 12         |
| WARNING:at_net/netlink/genetlink.c:#genl_bind()   | 0          | 59         | 12         |
| WARNING:at_net/netlink/genetlink.c:#genl_unbind() | 0          | 59         | 12         |
| backtrace:netlink_bind                            | 0          | 59         | 12         |
| backtrace:SyS_bind                                | 0          | 59         | 12         |
| backtrace:do_group_exit                           | 0          | 59         | 12         |
| backtrace:SyS_exit_group                          | 0          | 59         | 12         |
| backtrace:netlink_setsockopt                      | 0          | 15         | 4          |
| backtrace:SyS_setsockopt                          | 0          | 15         | 4          |
+---------------------------------------------------+------------+------------+------------+

/bin/sh: /proc/self/fd/9: No such file or directory
/bin/sh: /proc/self/fd/9: No such file or directory
[   17.673482] ------------[ cut here ]------------
[   17.674874] WARNING: CPU: 0 PID: 109 at net/netlink/genetlink.c:1011 genl_bind+0x142/0x15e()
[   17.676682] CPU: 0 PID: 109 Comm: trinity-main Not tainted 3.18.0-11169-gc380d9a #9
[   17.678005]  0000000000000009 ffff88000b44fdd8 ffffffff8175b593 ffff88000b44fe18
[   17.679450]  ffffffff810b55aa 0000000000000000 ffffffff8174d931 ffffffff834a3400
[   17.680929]  0000000000000000 0000000000000000 0000000000000000 ffff88000b44fe28
[   17.682377] Call Trace:
[   17.682820]  [<ffffffff8175b593>] dump_stack+0x2e/0x3e
[   17.683753]  [<ffffffff810b55aa>] warn_slowpath_common+0xb6/0xe5
[   17.684801]  [<ffffffff8174d931>] ? genl_bind+0x142/0x15e
[   17.685797]  [<ffffffff810b56db>] warn_slowpath_null+0x23/0x2c
[   17.686930]  [<ffffffff8174d931>] genl_bind+0x142/0x15e
[   17.688149]  [<ffffffff8174ab86>] netlink_bind+0x155/0x2ce
[   17.689413]  [<ffffffff8170e512>] SyS_bind+0xc1/0x117
[   17.690564]  [<ffffffff81769058>] ? _raw_spin_unlock+0x38/0x50
[   17.691875]  [<ffffffff8114553f>] ? context_tracking_user_exit+0xe2/0x101
[   17.693471]  [<ffffffff810eafbd>] ? trace_hardirqs_on+0x1b/0x24
[   17.694823]  [<ffffffff8176a2e7>] system_call_fastpath+0x12/0x17
[   17.696182] ---[ end trace f8ae22d84a926b3f ]---
[   17.697267] ------------[ cut here ]------------

git bisect start bdf7b239ea04ec0372de511b630858d31ce0a27d 97bf6af1f928216fd6c5a66e8a57bfa95a659672 --
git bisect good 353ffe5824fadf421e54334766749a621875bf25  # 17:12     85+      0  Merge 'iio/testing' into devel-lkp-nhm1-smoke-201412271621
git bisect  bad e110b301867f3479fe39b036cd25c8dd9587a348  # 17:12      0-      9  Merge 'vfs/for-linus' into devel-lkp-nhm1-smoke-201412271621
git bisect  bad b15800a33d77b5efeb46467961694acc3b9a86f5  # 17:17      9-      5  Merge 'net/master' into devel-lkp-nhm1-smoke-201412271621
git bisect good e88bf5beea5b1cf596aec20cbe298080ee5c56ba  # 17:20     93+      0  Merge 'arm-integrator/realview-dt' into devel-lkp-nhm1-smoke-201412271621
git bisect good ec449f40bb3e19c77f62ddabf7c1fe3ccefece6f  # 17:25     93+      0  openvswitch: Fix MPLS action validation.
git bisect good 5f35227ea34bb616c436d9da47fc325866c428f3  # 17:31     93+      0  net: Generalize ndo_gso_check to ndo_features_check
git bisect good b63a2a1ff1f7cde479aef091a4b9a9f7238a0657  # 17:37     93+      0  Merge tag 'wireless-drivers-for-davem-2014-12-26' of git://git.kernel.org/pub/scm/linux/kernel/git/kvalo/wireless-drivers
git bisect good b10dcb3b94010e3ac3951f68789400b1665effb1  # 17:42     93+      0  netlink: update listeners directly when removing socket
git bisect  bad 24f626d3439f61d87fca0c0c07f614fba41a4e92  # 17:45     15-     10  Merge branch 'netlink_multicast'
git bisect  bad c380d9a7afff0e4c2e5f3c1c2dc7d2f4214dd962  # 17:49     13-     33  genetlink: pass multicast bind/unbind to families
git bisect good 7d68536bed72b09de03b07479dd707c5831b3b94  # 17:56     93+      0  netlink: call unbind when releasing socket
# first bad commit: [c380d9a7afff0e4c2e5f3c1c2dc7d2f4214dd962] genetlink: pass multicast bind/unbind to families
git bisect good 7d68536bed72b09de03b07479dd707c5831b3b94  # 17:59    279+      0  netlink: call unbind when releasing socket
# extra tests with DEBUG_INFO
git bisect good c380d9a7afff0e4c2e5f3c1c2dc7d2f4214dd962  # 18:08    279+      0  genetlink: pass multicast bind/unbind to families
# extra tests on HEAD of linux-devel/devel-lkp-nhm1-smoke-201412271621
git bisect  bad bdf7b239ea04ec0372de511b630858d31ce0a27d  # 18:08      0-     12  0day head guard for 'devel-lkp-nhm1-smoke-201412271621'
# extra tests on tree/branch linux-devel/devel-hourly-2014122715
git bisect  bad 462a586c1d24c1935547379c98d99e96d83c7b8f  # 18:55      7-     29  0day head guard for 'devel-hourly-2014122715'
# extra tests on tree/branch linus/master
git bisect good 58628a7831edac5f7a13baa9d9320c758c5204c8  # 19:02    279+      0  Merge branch 'parisc-3.19-1' of git://git.kernel.org/pub/scm/linux/kernel/git/deller/parisc-linux
# extra tests on tree/branch next/master
git bisect good 2fb8bdb2ca2808ce901fdfc1eda31bcb488156d0  # 19:07    279+      0  Add linux-next specific files for 20141226


This script may reproduce the error.

----------------------------------------------------------------------------
#!/bin/bash

kernel=$1
initrd=quantal-core-x86_64.cgz

wget --no-clobber https://github.com/fengguang/reproduce-kernel-bug/raw/master/initrd/$initrd

kvm=(
	qemu-system-x86_64
	-cpu kvm64
	-enable-kvm
	-kernel $kernel
	-initrd $initrd
	-m 320
	-smp 2
	-net nic,vlan=1,model=e1000
	-net user,vlan=1
	-boot order=nc
	-no-reboot
	-watchdog i6300esb
	-rtc base=localtime
	-serial stdio
	-display none
	-monitor null 
)

append=(
	hung_task_panic=1
	earlyprintk=ttyS0,115200
	debug
	apic=debug
	sysrq_always_enabled
	rcupdate.rcu_cpu_stall_timeout=100
	panic=-1
	softlockup_panic=1
	nmi_watchdog=panic
	oops=panic
	load_ramdisk=2
	prompt_ramdisk=0
	console=ttyS0,115200
	console=tty0
	vga=normal
	root=/dev/ram0
	rw
	drbd.minor_count=8
)

"${kvm[@]}" --append "${append[*]}"
----------------------------------------------------------------------------

Thanks,
Fengguang

--OgqxwSJOaUobr8KG
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="dmesg-quantal-client7-25:20141227174912:x86_64-randconfig-n0-12271619:3.18.0-11169-gc380d9a:9"
Content-Transfer-Encoding: quoted-printable

early console in setup code
early console in decompress_kernel

Decompressing Linux... Parsing ELF... done.
Booting the kernel.
[    0.000000] Initializing cgroup subsys cpuset
[    0.000000] Initializing cgroup subsys cpu
[    0.000000] Linux version 3.18.0-11169-gc380d9a (kbuild@lkp-nhm1) (gcc v=
ersion 4.9.1 (Debian 4.9.1-19) ) #9 Sat Dec 27 17:44:15 CST 2014
[    0.000000] Command line: hung_task_panic=3D1 earlyprintk=3DttyS0,115200=
 debug apic=3Ddebug sysrq_always_enabled rcupdate.rcu_cpu_stall_timeout=3D1=
00 panic=3D-1 softlockup_panic=3D1 nmi_watchdog=3Dpanic oops=3Dpanic load_r=
amdisk=3D2 prompt_ramdisk=3D0 console=3DttyS0,115200 console=3Dtty0 vga=3Dn=
ormal  root=3D/dev/ram0 rw link=3D/kbuild-tests/run-queue/kvm/x86_64-randco=
nfig-n0-12271619/linux-devel:devel-lkp-nhm1-smoke-201412271621:c380d9a7afff=
0e4c2e5f3c1c2dc7d2f4214dd962:bisect-linux-1/.vmlinuz-c380d9a7afff0e4c2e5f3c=
1c2dc7d2f4214dd962-20141227174430-26-client7 branch=3Dlinux-devel/devel-lkp=
-nhm1-smoke-201412271621 BOOT_IMAGE=3D/kernel/x86_64-randconfig-n0-12271619=
/c380d9a7afff0e4c2e5f3c1c2dc7d2f4214dd962/vmlinuz-3.18.0-11169-gc380d9a drb=
d.minor_count=3D8
[    0.000000] e820: BIOS-provided physical RAM map:
[    0.000000] BIOS-e820: [mem 0x0000000000000000-0x000000000009fbff] usable
[    0.000000] BIOS-e820: [mem 0x000000000009fc00-0x000000000009ffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000000f0000-0x00000000000fffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x0000000000100000-0x0000000013fdffff] usable
[    0.000000] BIOS-e820: [mem 0x0000000013fe0000-0x0000000013ffffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000feffc000-0x00000000feffffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000fffc0000-0x00000000ffffffff] reser=
ved
[    0.000000] bootconsole [earlyser0] enabled
[    0.000000] NX (Execute Disable) protection: active
[    0.000000] Hypervisor detected: KVM
[    0.000000] e820: update [mem 0x00000000-0x00000fff] usable =3D=3D> rese=
rved
[    0.000000] e820: remove [mem 0x000a0000-0x000fffff] usable
[    0.000000] e820: last_pfn =3D 0x13fe0 max_arch_pfn =3D 0x400000000
[    0.000000] Scan for SMP in [mem 0x00000000-0x000003ff]
[    0.000000] Scan for SMP in [mem 0x0009fc00-0x0009ffff]
[    0.000000] Scan for SMP in [mem 0x000f0000-0x000fffff]
[    0.000000] found SMP MP-table at [mem 0x000f0eb0-0x000f0ebf] mapped at =
[ffff8800000f0eb0]
[    0.000000]   mpc: f0ec0-f0fa4
[    0.000000] Base memory trampoline at [ffff880000099000] 99000 size 24576
[    0.000000] init_memory_mapping: [mem 0x00000000-0x000fffff]
[    0.000000]  [mem 0x00000000-0x000fffff] page 4k
[    0.000000] BRK [0x034a8000, 0x034a8fff] PGTABLE
[    0.000000] BRK [0x034a9000, 0x034a9fff] PGTABLE
[    0.000000] BRK [0x034aa000, 0x034aafff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0x12600000-0x127fffff]
[    0.000000]  [mem 0x12600000-0x127fffff] page 4k
[    0.000000] BRK [0x034ab000, 0x034abfff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0x10000000-0x125fffff]
[    0.000000]  [mem 0x10000000-0x125fffff] page 4k
[    0.000000] BRK [0x034ac000, 0x034acfff] PGTABLE
[    0.000000] BRK [0x034ad000, 0x034adfff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0x00100000-0x0fffffff]
[    0.000000]  [mem 0x00100000-0x0fffffff] page 4k
[    0.000000] init_memory_mapping: [mem 0x12800000-0x13fdffff]
[    0.000000]  [mem 0x12800000-0x13fdffff] page 4k
[    0.000000] RAMDISK: [mem 0x12925000-0x13fd7fff]
[    0.000000] ACPI: Early table checksum verification disabled
[    0.000000] ACPI: RSDP 0x00000000000F0C90 000014 (v00 BOCHS )
[    0.000000] ACPI: RSDT 0x0000000013FE18BD 000034 (v01 BOCHS  BXPCRSDT 00=
000001 BXPC 00000001)
[    0.000000] ACPI: FACP 0x0000000013FE0B37 000074 (v01 BOCHS  BXPCFACP 00=
000001 BXPC 00000001)
[    0.000000] ACPI: DSDT 0x0000000013FE0040 000AF7 (v01 BOCHS  BXPCDSDT 00=
000001 BXPC 00000001)
[    0.000000] ACPI: FACS 0x0000000013FE0000 000040
[    0.000000] ACPI: SSDT 0x0000000013FE0BAB 000C5A (v01 BOCHS  BXPCSSDT 00=
000001 BXPC 00000001)
[    0.000000] ACPI: APIC 0x0000000013FE1805 000080 (v01 BOCHS  BXPCAPIC 00=
000001 BXPC 00000001)
[    0.000000] ACPI: HPET 0x0000000013FE1885 000038 (v01 BOCHS  BXPCHPET 00=
000001 BXPC 00000001)
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to ffffffffff5fc000 (        fee00000)
[    0.000000] kvm-clock: Using msrs 4b564d01 and 4b564d00
[    0.000000] kvm-clock: cpu 0, msr 0:13fdf001, primary cpu clock
[    0.000000]  [ffffea0000000000-ffffea00005fffff] PMD -> [ffff88001180000=
0-ffff880011dfffff] on node 0
[    0.000000] Zone ranges:
[    0.000000]   DMA      [mem 0x00001000-0x00ffffff]
[    0.000000]   DMA32    [mem 0x01000000-0x13fdffff]
[    0.000000]   Normal   empty
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x00001000-0x0009efff]
[    0.000000]   node   0: [mem 0x00100000-0x13fdffff]
[    0.000000] Initmem setup node 0 [mem 0x00001000-0x13fdffff]
[    0.000000] On node 0 totalpages: 81790
[    0.000000]   DMA zone: 64 pages used for memmap
[    0.000000]   DMA zone: 21 pages reserved
[    0.000000]   DMA zone: 3998 pages, LIFO batch:0
[    0.000000]   DMA32 zone: 1216 pages used for memmap
[    0.000000]   DMA32 zone: 77792 pages, LIFO batch:15
[    0.000000] ACPI: PM-Timer IO Port: 0x608
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to ffffffffff5fc000 (        fee00000)
[    0.000000] ACPI: LAPIC (acpi_id[0x00] lapic_id[0x00] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x01] lapic_id[0x01] enabled)
[    0.000000] ACPI: NR_CPUS/possible_cpus limit of 1 reached.  Processor 1=
/0x1 ignored.
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0xff] dfl dfl lint[0x1])
[    0.000000] ACPI: IOAPIC (id[0x00] address[0xfec00000] gsi_base[0])
[    0.000000] IOAPIC[0]: apic_id 0, version 17, address 0xfec00000, GSI 0-=
23
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 00, APIC ID 0, APIC =
INT 02
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 5 global_irq 5 high level)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 05, APIC ID 0, APIC =
INT 05
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 09, APIC ID 0, APIC =
INT 09
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 10 global_irq 10 high level)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 0a, APIC ID 0, APIC =
INT 0a
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 11 global_irq 11 high level)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 0b, APIC ID 0, APIC =
INT 0b
[    0.000000] ACPI: IRQ0 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 01, APIC ID 0, APIC =
INT 01
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 03, APIC ID 0, APIC =
INT 03
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 04, APIC ID 0, APIC =
INT 04
[    0.000000] ACPI: IRQ5 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 06, APIC ID 0, APIC =
INT 06
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 07, APIC ID 0, APIC =
INT 07
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 08, APIC ID 0, APIC =
INT 08
[    0.000000] ACPI: IRQ9 used by override.
[    0.000000] ACPI: IRQ10 used by override.
[    0.000000] ACPI: IRQ11 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0c, APIC ID 0, APIC =
INT 0c
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0d, APIC ID 0, APIC =
INT 0d
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0e, APIC ID 0, APIC =
INT 0e
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0f, APIC ID 0, APIC =
INT 0f
[    0.000000] Using ACPI (MADT) for SMP configuration information
[    0.000000] ACPI: HPET id: 0x8086a201 base: 0xfed00000
[    0.000000] mapped IOAPIC to ffffffffff5fb000 (fec00000)
[    0.000000] KVM setup async PF for cpu 0
[    0.000000] kvm-stealtime: cpu 0, msr 1e4c040
[    0.000000] e820: [mem 0x14000000-0xfeffbfff] available for PCI devices
[    0.000000] Booting paravirtualized kernel on KVM
[    0.000000] pcpu-alloc: s0 r0 d32768 u32768 alloc=3D1*32768
[    0.000000] pcpu-alloc: [0] 0=20
[    0.000000] Built 1 zonelists in Zone order, mobility grouping on.  Tota=
l pages: 80489
[    0.000000] Kernel command line: hung_task_panic=3D1 earlyprintk=3DttyS0=
,115200 debug apic=3Ddebug sysrq_always_enabled rcupdate.rcu_cpu_stall_time=
out=3D100 panic=3D-1 softlockup_panic=3D1 nmi_watchdog=3Dpanic oops=3Dpanic=
 load_ramdisk=3D2 prompt_ramdisk=3D0 console=3DttyS0,115200 console=3Dtty0 =
vga=3Dnormal  root=3D/dev/ram0 rw link=3D/kbuild-tests/run-queue/kvm/x86_64=
-randconfig-n0-12271619/linux-devel:devel-lkp-nhm1-smoke-201412271621:c380d=
9a7afff0e4c2e5f3c1c2dc7d2f4214dd962:bisect-linux-1/.vmlinuz-c380d9a7afff0e4=
c2e5f3c1c2dc7d2f4214dd962-20141227174430-26-client7 branch=3Dlinux-devel/de=
vel-lkp-nhm1-smoke-201412271621 BOOT_IMAGE=3D/kernel/x86_64-randconfig-n0-1=
2271619/c380d9a7afff0e4c2e5f3c1c2dc7d2f4214dd962/vmlinuz-3.18.0-11169-gc380=
d9a drbd.minor_count=3D8
[    0.000000] PID hash table entries: 2048 (order: 2, 16384 bytes)
[    0.000000] Dentry cache hash table entries: 65536 (order: 7, 524288 byt=
es)
[    0.000000] Inode-cache hash table entries: 32768 (order: 6, 262144 byte=
s)
[    0.000000] Memory: 258612K/327160K available (7600K kernel code, 5127K =
rwdata, 4848K rodata, 824K init, 17244K bss, 68548K reserved, 0K cma-reserv=
ed)
[    0.000000] SLUB: HWalign=3D64, Order=3D0-3, MinObjects=3D0, CPUs=3D1, N=
odes=3D1
[    0.000000] NR_IRQS:4352 nr_irqs:256 0
[    0.000000] Initializing cgroup subsys cpuset
[    0.000000] Initializing cgroup subsys cpu
[    0.000000] Linux version 3.18.0-11169-gc380d9a (kbuild@lkp-nhm1) (gcc v=
ersion 4.9.1 (Debian 4.9.1-19) ) #9 Sat Dec 27 17:44:15 CST 2014
[    0.000000] Command line: hung_task_panic=3D1 earlyprintk=3DttyS0,115200=
 debug apic=3Ddebug sysrq_always_enabled rcupdate.rcu_cpu_stall_timeout=3D1=
00 panic=3D-1 softlockup_panic=3D1 nmi_watchdog=3Dpanic oops=3Dpanic load_r=
amdisk=3D2 prompt_ramdisk=3D0 console=3DttyS0,115200 console=3Dtty0 vga=3Dn=
ormal  root=3D/dev/ram0 rw link=3D/kbuild-tests/run-queue/kvm/x86_64-randco=
nfig-n0-12271619/linux-devel:devel-lkp-nhm1-smoke-201412271621:c380d9a7afff=
0e4c2e5f3c1c2dc7d2f4214dd962:bisect-linux-1/.vmlinuz-c380d9a7afff0e4c2e5f3c=
1c2dc7d2f4214dd962-20141227174430-26-client7 branch=3Dlinux-devel/devel-lkp=
-nhm1-smoke-201412271621 BOOT_IMAGE=3D/kernel/x86_64-randconfig-n0-12271619=
/c380d9a7afff0e4c2e5f3c1c2dc7d2f4214dd962/vmlinuz-3.18.0-11169-gc380d9a drb=
d.minor_count=3D8
[    0.000000] e820: BIOS-provided physical RAM map:
[    0.000000] BIOS-e820: [mem 0x0000000000000000-0x000000000009fbff] usable
[    0.000000] BIOS-e820: [mem 0x000000000009fc00-0x000000000009ffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000000f0000-0x00000000000fffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x0000000000100000-0x0000000013fdffff] usable
[    0.000000] BIOS-e820: [mem 0x0000000013fe0000-0x0000000013ffffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000feffc000-0x00000000feffffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000fffc0000-0x00000000ffffffff] reser=
ved
[    0.000000] bootconsole [earlyser0] enabled
[    0.000000] NX (Execute Disable) protection: active
[    0.000000] Hypervisor detected: KVM
[    0.000000] e820: update [mem 0x00000000-0x00000fff] usable =3D=3D> rese=
rved
[    0.000000] e820: remove [mem 0x000a0000-0x000fffff] usable
[    0.000000] e820: last_pfn =3D 0x13fe0 max_arch_pfn =3D 0x400000000
[    0.000000] Scan for SMP in [mem 0x00000000-0x000003ff]
[    0.000000] Scan for SMP in [mem 0x0009fc00-0x0009ffff]
[    0.000000] Scan for SMP in [mem 0x000f0000-0x000fffff]
[    0.000000] found SMP MP-table at [mem 0x000f0eb0-0x000f0ebf] mapped at =
[ffff8800000f0eb0]
[    0.000000]   mpc: f0ec0-f0fa4
[    0.000000] Base memory trampoline at [ffff880000099000] 99000 size 24576
[    0.000000] init_memory_mapping: [mem 0x00000000-0x000fffff]
[    0.000000]  [mem 0x00000000-0x000fffff] page 4k
[    0.000000] BRK [0x034a8000, 0x034a8fff] PGTABLE
[    0.000000] BRK [0x034a9000, 0x034a9fff] PGTABLE
[    0.000000] BRK [0x034aa000, 0x034aafff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0x12600000-0x127fffff]
[    0.000000]  [mem 0x12600000-0x127fffff] page 4k
[    0.000000] BRK [0x034ab000, 0x034abfff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0x10000000-0x125fffff]
[    0.000000]  [mem 0x10000000-0x125fffff] page 4k
[    0.000000] BRK [0x034ac000, 0x034acfff] PGTABLE
[    0.000000] BRK [0x034ad000, 0x034adfff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0x00100000-0x0fffffff]
[    0.000000]  [mem 0x00100000-0x0fffffff] page 4k
[    0.000000] init_memory_mapping: [mem 0x12800000-0x13fdffff]
[    0.000000]  [mem 0x12800000-0x13fdffff] page 4k
[    0.000000] RAMDISK: [mem 0x12925000-0x13fd7fff]
[    0.000000] ACPI: Early table checksum verification disabled
[    0.000000] ACPI: RSDP 0x00000000000F0C90 000014 (v00 BOCHS )
[    0.000000] ACPI: RSDT 0x0000000013FE18BD 000034 (v01 BOCHS  BXPCRSDT 00=
000001 BXPC 00000001)
[    0.000000] ACPI: FACP 0x0000000013FE0B37 000074 (v01 BOCHS  BXPCFACP 00=
000001 BXPC 00000001)
[    0.000000] ACPI: DSDT 0x0000000013FE0040 000AF7 (v01 BOCHS  BXPCDSDT 00=
000001 BXPC 00000001)
[    0.000000] ACPI: FACS 0x0000000013FE0000 000040
[    0.000000] ACPI: SSDT 0x0000000013FE0BAB 000C5A (v01 BOCHS  BXPCSSDT 00=
000001 BXPC 00000001)
[    0.000000] ACPI: APIC 0x0000000013FE1805 000080 (v01 BOCHS  BXPCAPIC 00=
000001 BXPC 00000001)
[    0.000000] ACPI: HPET 0x0000000013FE1885 000038 (v01 BOCHS  BXPCHPET 00=
000001 BXPC 00000001)
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to ffffffffff5fc000 (        fee00000)
[    0.000000] kvm-clock: Using msrs 4b564d01 and 4b564d00
[    0.000000] kvm-clock: cpu 0, msr 0:13fdf001, primary cpu clock
[    0.000000]  [ffffea0000000000-ffffea00005fffff] PMD -> [ffff88001180000=
0-ffff880011dfffff] on node 0
[    0.000000] Zone ranges:
[    0.000000]   DMA      [mem 0x00001000-0x00ffffff]
[    0.000000]   DMA32    [mem 0x01000000-0x13fdffff]
[    0.000000]   Normal   empty
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x00001000-0x0009efff]
[    0.000000]   node   0: [mem 0x00100000-0x13fdffff]
[    0.000000] Initmem setup node 0 [mem 0x00001000-0x13fdffff]
[    0.000000] On node 0 totalpages: 81790
[    0.000000]   DMA zone: 64 pages used for memmap
[    0.000000]   DMA zone: 21 pages reserved
[    0.000000]   DMA zone: 3998 pages, LIFO batch:0
[    0.000000]   DMA32 zone: 1216 pages used for memmap
[    0.000000]   DMA32 zone: 77792 pages, LIFO batch:15
[    0.000000] ACPI: PM-Timer IO Port: 0x608
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to ffffffffff5fc000 (        fee00000)
[    0.000000] ACPI: LAPIC (acpi_id[0x00] lapic_id[0x00] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x01] lapic_id[0x01] enabled)
[    0.000000] ACPI: NR_CPUS/possible_cpus limit of 1 reached.  Processor 1=
/0x1 ignored.
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0xff] dfl dfl lint[0x1])
[    0.000000] ACPI: IOAPIC (id[0x00] address[0xfec00000] gsi_base[0])
[    0.000000] IOAPIC[0]: apic_id 0, version 17, address 0xfec00000, GSI 0-=
23
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 00, APIC ID 0, APIC =
INT 02
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 5 global_irq 5 high level)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 05, APIC ID 0, APIC =
INT 05
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 09, APIC ID 0, APIC =
INT 09
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 10 global_irq 10 high level)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 0a, APIC ID 0, APIC =
INT 0a
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 11 global_irq 11 high level)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 0b, APIC ID 0, APIC =
INT 0b
[    0.000000] ACPI: IRQ0 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 01, APIC ID 0, APIC =
INT 01
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 03, APIC ID 0, APIC =
INT 03
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 04, APIC ID 0, APIC =
INT 04
[    0.000000] ACPI: IRQ5 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 06, APIC ID 0, APIC =
INT 06
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 07, APIC ID 0, APIC =
INT 07
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 08, APIC ID 0, APIC =
INT 08
[    0.000000] ACPI: IRQ9 used by override.
[    0.000000] ACPI: IRQ10 used by override.
[    0.000000] ACPI: IRQ11 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0c, APIC ID 0, APIC =
INT 0c
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0d, APIC ID 0, APIC =
INT 0d
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0e, APIC ID 0, APIC =
INT 0e
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0f, APIC ID 0, APIC =
INT 0f
[    0.000000] Using ACPI (MADT) for SMP configuration information
[    0.000000] ACPI: HPET id: 0x8086a201 base: 0xfed00000
[    0.000000] mapped IOAPIC to ffffffffff5fb000 (fec00000)
[    0.000000] KVM setup async PF for cpu 0
[    0.000000] kvm-stealtime: cpu 0, msr 1e4c040
[    0.000000] e820: [mem 0x14000000-0xfeffbfff] available for PCI devices
[    0.000000] Booting paravirtualized kernel on KVM
[    0.000000] pcpu-alloc: s0 r0 d32768 u32768 alloc=3D1*32768
[    0.000000] pcpu-alloc: [0] 0=20
[    0.000000] Built 1 zonelists in Zone order, mobility grouping on.  Tota=
l pages: 80489
[    0.000000] Kernel command line: hung_task_panic=3D1 earlyprintk=3DttyS0=
,115200 debug apic=3Ddebug sysrq_always_enabled rcupdate.rcu_cpu_stall_time=
out=3D100 panic=3D-1 softlockup_panic=3D1 nmi_watchdog=3Dpanic oops=3Dpanic=
 load_ramdisk=3D2 prompt_ramdisk=3D0 console=3DttyS0,115200 console=3Dtty0 =
vga=3Dnormal  root=3D/dev/ram0 rw link=3D/kbuild-tests/run-queue/kvm/x86_64=
-randconfig-n0-12271619/linux-devel:devel-lkp-nhm1-smoke-201412271621:c380d=
9a7afff0e4c2e5f3c1c2dc7d2f4214dd962:bisect-linux-1/.vmlinuz-c380d9a7afff0e4=
c2e5f3c1c2dc7d2f4214dd962-20141227174430-26-client7 branch=3Dlinux-devel/de=
vel-lkp-nhm1-smoke-201412271621 BOOT_IMAGE=3D/kernel/x86_64-randconfig-n0-1=
2271619/c380d9a7afff0e4c2e5f3c1c2dc7d2f4214dd962/vmlinuz-3.18.0-11169-gc380=
d9a drbd.minor_count=3D8
[    0.000000] PID hash table entries: 2048 (order: 2, 16384 bytes)
[    0.000000] Dentry cache hash table entries: 65536 (order: 7, 524288 byt=
es)
[    0.000000] Inode-cache hash table entries: 32768 (order: 6, 262144 byte=
s)
[    0.000000] Memory: 258612K/327160K available (7600K kernel code, 5127K =
rwdata, 4848K rodata, 824K init, 17244K bss, 68548K reserved, 0K cma-reserv=
ed)
[    0.000000] SLUB: HWalign=3D64, Order=3D0-3, MinObjects=3D0, CPUs=3D1, N=
odes=3D1
[    0.000000] NR_IRQS:4352 nr_irqs:256 0
[    0.000000] console [ttyS0] enabled
[    0.000000] console [ttyS0] enabled
[    0.000000] Lock dependency validator: Copyright (c) 2006 Red Hat, Inc.,=
 Ingo Molnar
[    0.000000] Lock dependency validator: Copyright (c) 2006 Red Hat, Inc.,=
 Ingo Molnar
[    0.000000] ... MAX_LOCKDEP_SUBCLASSES:  8
[    0.000000] ... MAX_LOCKDEP_SUBCLASSES:  8
[    0.000000] ... MAX_LOCK_DEPTH:          48
[    0.000000] ... MAX_LOCK_DEPTH:          48
[    0.000000] ... MAX_LOCKDEP_KEYS:        8191
[    0.000000] ... MAX_LOCKDEP_KEYS:        8191
[    0.000000] ... CLASSHASH_SIZE:          4096
[    0.000000] ... CLASSHASH_SIZE:          4096
[    0.000000] ... MAX_LOCKDEP_ENTRIES:     32768
[    0.000000] ... MAX_LOCKDEP_ENTRIES:     32768
[    0.000000] ... MAX_LOCKDEP_CHAINS:      65536
[    0.000000] ... MAX_LOCKDEP_CHAINS:      65536
[    0.000000] ... CHAINHASH_SIZE:          32768
[    0.000000] ... CHAINHASH_SIZE:          32768
[    0.000000]  memory used by lock dependency info: 8671 kB
[    0.000000]  memory used by lock dependency info: 8671 kB
[    0.000000]  per task-struct memory footprint: 2688 bytes
[    0.000000]  per task-struct memory footprint: 2688 bytes
[    0.000000] ------------------------
[    0.000000] ------------------------
[    0.000000] | Locking API testsuite:
[    0.000000] | Locking API testsuite:
[    0.000000] ------------------------------------------------------------=
----------------
[    0.000000] ------------------------------------------------------------=
----------------
[    0.000000]                                  | spin |wlock |rlock |mutex=
 | wsem | rsem |
[    0.000000]                                  | spin |wlock |rlock |mutex=
 | wsem | rsem |
[    0.000000]   ----------------------------------------------------------=
----------------
[    0.000000]   ----------------------------------------------------------=
----------------
[    0.000000]                      A-A deadlock:
[    0.000000]                      A-A deadlock:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |

[    0.000000]                  A-B-B-A deadlock:
[    0.000000]                  A-B-B-A deadlock:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |

[    0.000000]              A-B-B-C-C-A deadlock:
[    0.000000]              A-B-B-C-C-A deadlock:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |

[    0.000000]              A-B-C-A-B-C deadlock:
[    0.000000]              A-B-C-A-B-C deadlock:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |

[    0.000000]          A-B-B-C-C-D-D-A deadlock:
[    0.000000]          A-B-B-C-C-D-D-A deadlock:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |

[    0.000000]          A-B-C-D-B-D-D-A deadlock:
[    0.000000]          A-B-C-D-B-D-D-A deadlock:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |

[    0.000000]          A-B-C-D-B-C-D-A deadlock:
[    0.000000]          A-B-C-D-B-C-D-A deadlock:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |

[    0.000000]                     double unlock:
[    0.000000]                     double unlock:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |

[    0.000000]                   initialize held:
[    0.000000]                   initialize held:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |

[    0.000000]                  bad unlock order:
[    0.000000]                  bad unlock order:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |

[    0.000000]   ----------------------------------------------------------=
----------------
[    0.000000]   ----------------------------------------------------------=
----------------
[    0.000000]               recursive read-lock:
[    0.000000]               recursive read-lock:             |            =
 |  ok  |  ok  |             |             |  ok  |  ok  |

[    0.000000]            recursive read-lock #2:
[    0.000000]            recursive read-lock #2:             |            =
 |  ok  |  ok  |             |             |  ok  |  ok  |

[    0.000000]             mixed read-write-lock:
[    0.000000]             mixed read-write-lock:             |            =
 |  ok  |  ok  |             |             |  ok  |  ok  |

[    0.000000]             mixed write-read-lock:
[    0.000000]             mixed write-read-lock:             |            =
 |  ok  |  ok  |             |             |  ok  |  ok  |

[    0.000000]   ----------------------------------------------------------=
----------------
[    0.000000]   ----------------------------------------------------------=
----------------
[    0.000000]      hard-irqs-on + irq-safe-A/12:
[    0.000000]      hard-irqs-on + irq-safe-A/12:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]      soft-irqs-on + irq-safe-A/12:
[    0.000000]      soft-irqs-on + irq-safe-A/12:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]      hard-irqs-on + irq-safe-A/21:
[    0.000000]      hard-irqs-on + irq-safe-A/21:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]      soft-irqs-on + irq-safe-A/21:
[    0.000000]      soft-irqs-on + irq-safe-A/21:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]        sirq-safe-A =3D> hirqs-on/12:
[    0.000000]        sirq-safe-A =3D> hirqs-on/12:  ok  |  ok  |  ok  |  o=
k  |  ok  |  ok  |

[    0.000000]        sirq-safe-A =3D> hirqs-on/21:
[    0.000000]        sirq-safe-A =3D> hirqs-on/21:  ok  |  ok  |  ok  |  o=
k  |  ok  |  ok  |

[    0.000000]          hard-safe-A + irqs-on/12:
[    0.000000]          hard-safe-A + irqs-on/12:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]          soft-safe-A + irqs-on/12:
[    0.000000]          soft-safe-A + irqs-on/12:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]          hard-safe-A + irqs-on/21:
[    0.000000]          hard-safe-A + irqs-on/21:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]          soft-safe-A + irqs-on/21:
[    0.000000]          soft-safe-A + irqs-on/21:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]     hard-safe-A + unsafe-B #1/123:
[    0.000000]     hard-safe-A + unsafe-B #1/123:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]     soft-safe-A + unsafe-B #1/123:
[    0.000000]     soft-safe-A + unsafe-B #1/123:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]     hard-safe-A + unsafe-B #1/132:
[    0.000000]     hard-safe-A + unsafe-B #1/132:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]     soft-safe-A + unsafe-B #1/132:
[    0.000000]     soft-safe-A + unsafe-B #1/132:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]     hard-safe-A + unsafe-B #1/213:
[    0.000000]     hard-safe-A + unsafe-B #1/213:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]     soft-safe-A + unsafe-B #1/213:
[    0.000000]     soft-safe-A + unsafe-B #1/213:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]     hard-safe-A + unsafe-B #1/231:
[    0.000000]     hard-safe-A + unsafe-B #1/231:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]     soft-safe-A + unsafe-B #1/231:
[    0.000000]     soft-safe-A + unsafe-B #1/231:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]     hard-safe-A + unsafe-B #1/312:
[    0.000000]     hard-safe-A + unsafe-B #1/312:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]     soft-safe-A + unsafe-B #1/312:
[    0.000000]     soft-safe-A + unsafe-B #1/312:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]     hard-safe-A + unsafe-B #1/321:
[    0.000000]     hard-safe-A + unsafe-B #1/321:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]     soft-safe-A + unsafe-B #1/321:
[    0.000000]     soft-safe-A + unsafe-B #1/321:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]     hard-safe-A + unsafe-B #2/123:
[    0.000000]     hard-safe-A + unsafe-B #2/123:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]     soft-safe-A + unsafe-B #2/123:
[    0.000000]     soft-safe-A + unsafe-B #2/123:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]     hard-safe-A + unsafe-B #2/132:
[    0.000000]     hard-safe-A + unsafe-B #2/132:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]     soft-safe-A + unsafe-B #2/132:
[    0.000000]     soft-safe-A + unsafe-B #2/132:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]     hard-safe-A + unsafe-B #2/213:
[    0.000000]     hard-safe-A + unsafe-B #2/213:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]     soft-safe-A + unsafe-B #2/213:
[    0.000000]     soft-safe-A + unsafe-B #2/213:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]     hard-safe-A + unsafe-B #2/231:
[    0.000000]     hard-safe-A + unsafe-B #2/231:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]     soft-safe-A + unsafe-B #2/231:
[    0.000000]     soft-safe-A + unsafe-B #2/231:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]     hard-safe-A + unsafe-B #2/312:
[    0.000000]     hard-safe-A + unsafe-B #2/312:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]     soft-safe-A + unsafe-B #2/312:
[    0.000000]     soft-safe-A + unsafe-B #2/312:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]     hard-safe-A + unsafe-B #2/321:
[    0.000000]     hard-safe-A + unsafe-B #2/321:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]     soft-safe-A + unsafe-B #2/321:
[    0.000000]     soft-safe-A + unsafe-B #2/321:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]       hard-irq lock-inversion/123:
[    0.000000]       hard-irq lock-inversion/123:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]       soft-irq lock-inversion/123:
[    0.000000]       soft-irq lock-inversion/123:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]       hard-irq lock-inversion/132:
[    0.000000]       hard-irq lock-inversion/132:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]       soft-irq lock-inversion/132:
[    0.000000]       soft-irq lock-inversion/132:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]       hard-irq lock-inversion/213:
[    0.000000]       hard-irq lock-inversion/213:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]       soft-irq lock-inversion/213:
[    0.000000]       soft-irq lock-inversion/213:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]       hard-irq lock-inversion/231:
[    0.000000]       hard-irq lock-inversion/231:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]       soft-irq lock-inversion/231:
[    0.000000]       soft-irq lock-inversion/231:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]       hard-irq lock-inversion/312:
[    0.000000]       hard-irq lock-inversion/312:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]       soft-irq lock-inversion/312:
[    0.000000]       soft-irq lock-inversion/312:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]       hard-irq lock-inversion/321:
[    0.000000]       hard-irq lock-inversion/321:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]       soft-irq lock-inversion/321:
[    0.000000]       soft-irq lock-inversion/321:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]       hard-irq read-recursion/123:
[    0.000000]       hard-irq read-recursion/123:  ok  |  ok  |

[    0.000000]       soft-irq read-recursion/123:
[    0.000000]       soft-irq read-recursion/123:  ok  |  ok  |

[    0.000000]       hard-irq read-recursion/132:
[    0.000000]       hard-irq read-recursion/132:  ok  |  ok  |

[    0.000000]       soft-irq read-recursion/132:
[    0.000000]       soft-irq read-recursion/132:  ok  |  ok  |

[    0.000000]       hard-irq read-recursion/213:
[    0.000000]       hard-irq read-recursion/213:  ok  |  ok  |

[    0.000000]       soft-irq read-recursion/213:
[    0.000000]       soft-irq read-recursion/213:  ok  |  ok  |

[    0.000000]       hard-irq read-recursion/231:
[    0.000000]       hard-irq read-recursion/231:  ok  |  ok  |

[    0.000000]       soft-irq read-recursion/231:
[    0.000000]       soft-irq read-recursion/231:  ok  |  ok  |

[    0.000000]       hard-irq read-recursion/312:
[    0.000000]       hard-irq read-recursion/312:  ok  |  ok  |

[    0.000000]       soft-irq read-recursion/312:
[    0.000000]       soft-irq read-recursion/312:  ok  |  ok  |

[    0.000000]       hard-irq read-recursion/321:
[    0.000000]       hard-irq read-recursion/321:  ok  |  ok  |

[    0.000000]       soft-irq read-recursion/321:
[    0.000000]       soft-irq read-recursion/321:  ok  |  ok  |

[    0.000000]   ----------------------------------------------------------=
----------------
[    0.000000]   ----------------------------------------------------------=
----------------
[    0.000000]   | Wound/wait tests |
[    0.000000]   | Wound/wait tests |
[    0.000000]   ---------------------
[    0.000000]   ---------------------
[    0.000000]                   ww api failures:
[    0.000000]                   ww api failures:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]                ww contexts mixing:
[    0.000000]                ww contexts mixing:  ok  |  ok  |  ok  |  ok =
 |

[    0.000000]              finishing ww context:
[    0.000000]              finishing ww context:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |  ok  |  ok  |

[    0.000000]                locking mismatches:
[    0.000000]                locking mismatches:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]                  EDEADLK handling:
[    0.000000]                  EDEADLK handling:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  o=
k  |  ok  |  ok  |  ok  |  ok  |  ok  |

[    0.000000]            spinlock nest unlocked:
[    0.000000]            spinlock nest unlocked:  ok  |  ok  |

[    0.000000]   -----------------------------------------------------
[    0.000000]   -----------------------------------------------------
[    0.000000]                                  |block | try  |context|
[    0.000000]                                  |block | try  |context|
[    0.000000]   -----------------------------------------------------
[    0.000000]   -----------------------------------------------------
[    0.000000]                           context:
[    0.000000]                           context:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]                               try:
[    0.000000]                               try:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]                             block:
[    0.000000]                             block:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]                          spinlock:
[    0.000000]                          spinlock:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000] -------------------------------------------------------
[    0.000000] -------------------------------------------------------
[    0.000000] Good, all 253 testcases passed! |
[    0.000000] Good, all 253 testcases passed! |
[    0.000000] ---------------------------------
[    0.000000] ---------------------------------
[    0.000000] hpet clockevent registered
[    0.000000] hpet clockevent registered
[    0.000000] tsc: Detected 2925.998 MHz processor
[    0.000000] tsc: Detected 2925.998 MHz processor
[    0.008000] Calibrating delay loop (skipped) preset value..=20
[    0.008000] Calibrating delay loop (skipped) preset value.. 5851.99 Bogo=
MIPS (lpj=3D11703992)
5851.99 BogoMIPS (lpj=3D11703992)
[    0.008832] pid_max: default: 32768 minimum: 301
[    0.008832] pid_max: default: 32768 minimum: 301
[    0.010369] ACPI: Core revision 20141107
[    0.010369] ACPI: Core revision 20141107
[    0.018143] ACPI:=20
[    0.018143] ACPI: All ACPI Tables successfully acquiredAll ACPI Tables s=
uccessfully acquired

[    0.020061] Security Framework initialized
[    0.020061] Security Framework initialized
[    0.021315] Mount-cache hash table entries: 1024 (order: 1, 8192 bytes)
[    0.021315] Mount-cache hash table entries: 1024 (order: 1, 8192 bytes)
[    0.023255] Mountpoint-cache hash table entries: 1024 (order: 1, 8192 by=
tes)
[    0.023255] Mountpoint-cache hash table entries: 1024 (order: 1, 8192 by=
tes)
[    0.024922] Initializing cgroup subsys devices
[    0.024922] Initializing cgroup subsys devices
[    0.026207] Initializing cgroup subsys perf_event
[    0.026207] Initializing cgroup subsys perf_event
[    0.028036] Initializing cgroup subsys debug
[    0.028036] Initializing cgroup subsys debug
[    0.029543] Last level iTLB entries: 4KB 0, 2MB 0, 4MB 0
[    0.029543] Last level dTLB entries: 4KB 0, 2MB 0, 4MB 0, 1GB 0
[    0.029543] Last level iTLB entries: 4KB 0, 2MB 0, 4MB 0
[    0.029543] Last level dTLB entries: 4KB 0, 2MB 0, 4MB 0, 1GB 0
[    0.032011] CPU:=20
[    0.032011] CPU: Intel Intel Common KVM processorCommon KVM processor (f=
am: 0f, model: 06 (fam: 0f, model: 06, stepping: 01)
, stepping: 01)
[    0.040588] Performance Events:=20
[    0.040588] Performance Events: unsupported Netburst CPU model 6 unsuppo=
rted Netburst CPU model 6 no PMU driver, software events only.
no PMU driver, software events only.
[    0.044396] Getting VERSION: 1050014
[    0.044396] Getting VERSION: 1050014
[    0.045468] Getting VERSION: 1050014
[    0.045468] Getting VERSION: 1050014
[    0.046737] Getting ID: 0
[    0.046737] Getting ID: 0
[    0.047532] Getting ID: ff000000
[    0.047532] Getting ID: ff000000
[    0.048034] Getting LVT0: 8700
[    0.048034] Getting LVT0: 8700
[    0.048980] Getting LVT1: 8400
[    0.048980] Getting LVT1: 8400
[    0.050115] enabled ExtINT on CPU#0
[    0.050115] enabled ExtINT on CPU#0
[    0.053076] ENABLING IO-APIC IRQs
[    0.053076] ENABLING IO-APIC IRQs
[    0.054139] NMI watchdog: disabled (cpu0): hardware events not enabled
[    0.054139] NMI watchdog: disabled (cpu0): hardware events not enabled
[    0.056139] init IO_APIC IRQs
[    0.056139] init IO_APIC IRQs
[    0.056993]  apic 0 pin 0 not connected
[    0.056993]  apic 0 pin 0 not connected
[    0.058130] IOAPIC[0]: Set routing entry (0-1 -> 0x31 -> IRQ 1 Mode:0 Ac=
tive:0 Dest:1)
[    0.058130] IOAPIC[0]: Set routing entry (0-1 -> 0x31 -> IRQ 1 Mode:0 Ac=
tive:0 Dest:1)
[    0.060073] IOAPIC[0]: Set routing entry (0-2 -> 0x30 -> IRQ 0 Mode:0 Ac=
tive:0 Dest:1)
[    0.060073] IOAPIC[0]: Set routing entry (0-2 -> 0x30 -> IRQ 0 Mode:0 Ac=
tive:0 Dest:1)
[    0.062407] IOAPIC[0]: Set routing entry (0-2 -> 0x30 -> IRQ 0 Mode:0 Ac=
tive:0 Dest:1)
[    0.062407] IOAPIC[0]: Set routing entry (0-2 -> 0x30 -> IRQ 0 Mode:0 Ac=
tive:0 Dest:1)
[    0.064055] IOAPIC[0]: Set routing entry (0-3 -> 0x33 -> IRQ 3 Mode:0 Ac=
tive:0 Dest:1)
[    0.064055] IOAPIC[0]: Set routing entry (0-3 -> 0x33 -> IRQ 3 Mode:0 Ac=
tive:0 Dest:1)
[    0.068037] IOAPIC[0]: Set routing entry (0-4 -> 0x34 -> IRQ 4 Mode:0 Ac=
tive:0 Dest:1)
[    0.068037] IOAPIC[0]: Set routing entry (0-4 -> 0x34 -> IRQ 4 Mode:0 Ac=
tive:0 Dest:1)
[    0.070616] IOAPIC[0]: Set routing entry (0-5 -> 0x35 -> IRQ 5 Mode:1 Ac=
tive:0 Dest:1)
[    0.070616] IOAPIC[0]: Set routing entry (0-5 -> 0x35 -> IRQ 5 Mode:1 Ac=
tive:0 Dest:1)
[    0.072045] IOAPIC[0]: Set routing entry (0-6 -> 0x36 -> IRQ 6 Mode:0 Ac=
tive:0 Dest:1)
[    0.072045] IOAPIC[0]: Set routing entry (0-6 -> 0x36 -> IRQ 6 Mode:0 Ac=
tive:0 Dest:1)
[    0.076035] IOAPIC[0]: Set routing entry (0-7 -> 0x37 -> IRQ 7 Mode:0 Ac=
tive:0 Dest:1)
[    0.076035] IOAPIC[0]: Set routing entry (0-7 -> 0x37 -> IRQ 7 Mode:0 Ac=
tive:0 Dest:1)
[    0.078395] IOAPIC[0]: Set routing entry (0-8 -> 0x38 -> IRQ 8 Mode:0 Ac=
tive:0 Dest:1)
[    0.078395] IOAPIC[0]: Set routing entry (0-8 -> 0x38 -> IRQ 8 Mode:0 Ac=
tive:0 Dest:1)
[    0.080045] IOAPIC[0]: Set routing entry (0-9 -> 0x39 -> IRQ 9 Mode:1 Ac=
tive:0 Dest:1)
[    0.080045] IOAPIC[0]: Set routing entry (0-9 -> 0x39 -> IRQ 9 Mode:1 Ac=
tive:0 Dest:1)
[    0.084040] IOAPIC[0]: Set routing entry (0-10 -> 0x3a -> IRQ 10 Mode:1 =
Active:0 Dest:1)
[    0.084040] IOAPIC[0]: Set routing entry (0-10 -> 0x3a -> IRQ 10 Mode:1 =
Active:0 Dest:1)
[    0.086728] IOAPIC[0]: Set routing entry (0-11 -> 0x3b -> IRQ 11 Mode:1 =
Active:0 Dest:1)
[    0.086728] IOAPIC[0]: Set routing entry (0-11 -> 0x3b -> IRQ 11 Mode:1 =
Active:0 Dest:1)
[    0.088041] IOAPIC[0]: Set routing entry (0-12 -> 0x3c -> IRQ 12 Mode:0 =
Active:0 Dest:1)
[    0.088041] IOAPIC[0]: Set routing entry (0-12 -> 0x3c -> IRQ 12 Mode:0 =
Active:0 Dest:1)
[    0.092047] IOAPIC[0]: Set routing entry (0-13 -> 0x3d -> IRQ 13 Mode:0 =
Active:0 Dest:1)
[    0.092047] IOAPIC[0]: Set routing entry (0-13 -> 0x3d -> IRQ 13 Mode:0 =
Active:0 Dest:1)
[    0.096045] IOAPIC[0]: Set routing entry (0-14 -> 0x3e -> IRQ 14 Mode:0 =
Active:0 Dest:1)
[    0.096045] IOAPIC[0]: Set routing entry (0-14 -> 0x3e -> IRQ 14 Mode:0 =
Active:0 Dest:1)
[    0.098600] IOAPIC[0]: Set routing entry (0-15 -> 0x3f -> IRQ 15 Mode:0 =
Active:0 Dest:1)
[    0.098600] IOAPIC[0]: Set routing entry (0-15 -> 0x3f -> IRQ 15 Mode:0 =
Active:0 Dest:1)
[    0.100040]  apic 0 pin 16 not connected
[    0.100040]  apic 0 pin 16 not connected
[    0.101265]  apic 0 pin 17 not connected
[    0.101265]  apic 0 pin 17 not connected
[    0.102493]  apic 0 pin 18 not connected
[    0.102493]  apic 0 pin 18 not connected
[    0.104008]  apic 0 pin 19 not connected
[    0.104008]  apic 0 pin 19 not connected
[    0.105436]  apic 0 pin 20 not connected
[    0.105436]  apic 0 pin 20 not connected
[    0.106703]  apic 0 pin 21 not connected
[    0.106703]  apic 0 pin 21 not connected
[    0.108006]  apic 0 pin 22 not connected
[    0.108006]  apic 0 pin 22 not connected
[    0.109181]  apic 0 pin 23 not connected
[    0.109181]  apic 0 pin 23 not connected
[    0.110556] ..TIMER: vector=3D0x30 apic1=3D0 pin1=3D2 apic2=3D-1 pin2=3D=
-1
[    0.110556] ..TIMER: vector=3D0x30 apic1=3D0 pin1=3D2 apic2=3D-1 pin2=3D=
-1
[    0.112023] Using local APIC timer interrupts.
[    0.112023] calibrating APIC timer ...
[    0.112023] Using local APIC timer interrupts.
[    0.112023] calibrating APIC timer ...
[    0.120000] ... lapic delta =3D 6248603
[    0.120000] ... lapic delta =3D 6248603
[    0.120000] ... PM-Timer delta =3D 357857
[    0.120000] ... PM-Timer delta =3D 357857
[    0.120000] ... PM-Timer result ok
[    0.120000] ... PM-Timer result ok
[    0.120000] ..... delta 6248603
[    0.120000] ..... delta 6248603
[    0.120000] ..... mult: 268375455
[    0.120000] ..... mult: 268375455
[    0.120000] ..... calibration result: 3999105
[    0.120000] ..... calibration result: 3999105
[    0.120000] ..... CPU clock speed is 2925.0865 MHz.
[    0.120000] ..... CPU clock speed is 2925.0865 MHz.
[    0.120000] ..... host bus clock speed is 999.3105 MHz.
[    0.120000] ..... host bus clock speed is 999.3105 MHz.
[    0.120915] gcov: version magic: 0x3430392a
[    0.120915] gcov: version magic: 0x3430392a
[    0.126240] prandom: seed boundary self test passed
[    0.126240] prandom: seed boundary self test passed
[    0.131106] prandom: 100 self tests passed
[    0.131106] prandom: 100 self tests passed
[    0.132049] atomic64_test: passed for x86-64 platform with CX8 and with =
SSE
[    0.132049] atomic64_test: passed for x86-64 platform with CX8 and with =
SSE
[    0.137075] RTC time: 17:47:56, date: 12/27/14
[    0.137075] RTC time: 17:47:56, date: 12/27/14
[    0.139495] NET: Registered protocol family 16
[    0.139495] NET: Registered protocol family 16
[    0.144054] cpuidle: using governor ladder
[    0.144054] cpuidle: using governor ladder
[    0.145685] cpuidle: using governor menu
[    0.145685] cpuidle: using governor menu
[    0.147839] ACPI: bus type PCI registered
[    0.147839] ACPI: bus type PCI registered
[    0.148135] PCI: Using configuration type 1 for base access
[    0.148135] PCI: Using configuration type 1 for base access
[    0.173353] Running resizable hashtable tests...
[    0.173353] Running resizable hashtable tests...
[    0.175618]   Adding 2048 keys
[    0.175618]   Adding 2048 keys
[    0.177129]   Traversal complete: counted=3D2048, nelems=3D2048, entries=
=3D2048
[    0.177129]   Traversal complete: counted=3D2048, nelems=3D2048, entries=
=3D2048
[    0.180233]   Table expansion iteration 0...
[    0.180233]   Table expansion iteration 0...
[    0.182598]   Verifying lookups...
[    0.182598]   Verifying lookups...
[    0.184191]   Table expansion iteration 1...
[    0.184191]   Table expansion iteration 1...
[    0.186416]   Verifying lookups...
[    0.186416]   Verifying lookups...
[    0.188251]   Table expansion iteration 2...
[    0.188251]   Table expansion iteration 2...
[    0.192269]   Verifying lookups...
[    0.192269]   Verifying lookups...
[    0.193943]   Table expansion iteration 3...
[    0.193943]   Table expansion iteration 3...
[    0.196931]   Verifying lookups...
[    0.196931]   Verifying lookups...
[    0.198673]   Table shrinkage iteration 0...
[    0.198673]   Table shrinkage iteration 0...
[    0.200269]   Verifying lookups...
[    0.200269]   Verifying lookups...
[    0.201907]   Table shrinkage iteration 1...
[    0.201907]   Table shrinkage iteration 1...
[    0.204156]   Verifying lookups...
[    0.204156]   Verifying lookups...
[    0.205683]   Table shrinkage iteration 2...
[    0.205683]   Table shrinkage iteration 2...
[    0.207496]   Verifying lookups...
[    0.207496]   Verifying lookups...
[    0.208208]   Table shrinkage iteration 3...
[    0.208208]   Table shrinkage iteration 3...
[    0.210051]   Verifying lookups...
[    0.210051]   Verifying lookups...
[    0.212359]   Traversal complete: counted=3D2048, nelems=3D2048, entries=
=3D2048
[    0.212359]   Traversal complete: counted=3D2048, nelems=3D2048, entries=
=3D2048
[    0.216008]   Deleting 2048 keys
[    0.216008]   Deleting 2048 keys
[    0.218545] ACPI: Added _OSI(Module Device)
[    0.218545] ACPI: Added _OSI(Module Device)
[    0.220010] ACPI: Added _OSI(Processor Device)
[    0.220010] ACPI: Added _OSI(Processor Device)
[    0.221995] ACPI: Added _OSI(3.0 _SCP Extensions)
[    0.221995] ACPI: Added _OSI(3.0 _SCP Extensions)
[    0.224010] ACPI: Added _OSI(Processor Aggregator Device)
[    0.224010] ACPI: Added _OSI(Processor Aggregator Device)
[    0.232104] IOAPIC[0]: Set routing entry (0-9 -> 0x39 -> IRQ 9 Mode:1 Ac=
tive:0 Dest:1)
[    0.232104] IOAPIC[0]: Set routing entry (0-9 -> 0x39 -> IRQ 9 Mode:1 Ac=
tive:0 Dest:1)
[    0.243274] ACPI: Interpreter enabled
[    0.243274] ACPI: Interpreter enabled
[    0.244018] ACPI Exception: AE_NOT_FOUND,=20
[    0.244018] ACPI Exception: AE_NOT_FOUND, While evaluating Sleep State [=
\_S1_]While evaluating Sleep State [\_S1_] (20141107/hwxface-580)
 (20141107/hwxface-580)
[    0.248016] ACPI Exception: AE_NOT_FOUND,=20
[    0.248016] ACPI Exception: AE_NOT_FOUND, While evaluating Sleep State [=
\_S2_]While evaluating Sleep State [\_S2_] (20141107/hwxface-580)
 (20141107/hwxface-580)
[    0.252099] ACPI: (supports S0 S3 S5)
[    0.252099] ACPI: (supports S0 S3 S5)
[    0.253596] ACPI: Using IOAPIC for interrupt routing
[    0.253596] ACPI: Using IOAPIC for interrupt routing
[    0.256100] PCI: Using host bridge windows from ACPI; if necessary, use =
"pci=3Dnocrs" and report a bug
[    0.256100] PCI: Using host bridge windows from ACPI; if necessary, use =
"pci=3Dnocrs" and report a bug
[    0.281651] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-ff])
[    0.281651] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-ff])
[    0.284038] acpi PNP0A03:00: _OSC: OS supports [Segments]
[    0.284038] acpi PNP0A03:00: _OSC: OS supports [Segments]
[    0.286299] acpi PNP0A03:00: _OSC failed (AE_NOT_FOUND); disabling ASPM
[    0.286299] acpi PNP0A03:00: _OSC failed (AE_NOT_FOUND); disabling ASPM
[    0.288859] PCI host bridge to bus 0000:00
[    0.288859] PCI host bridge to bus 0000:00
[    0.292010] pci_bus 0000:00: root bus resource [bus 00-ff]
[    0.292010] pci_bus 0000:00: root bus resource [bus 00-ff]
[    0.294502] pci_bus 0000:00: root bus resource [io  0x0000-0x0cf7]
[    0.294502] pci_bus 0000:00: root bus resource [io  0x0000-0x0cf7]
[    0.296018] pci_bus 0000:00: root bus resource [io  0x0d00-0xadff]
[    0.296018] pci_bus 0000:00: root bus resource [io  0x0d00-0xadff]
[    0.300018] pci_bus 0000:00: root bus resource [io  0xae0f-0xaeff]
[    0.300018] pci_bus 0000:00: root bus resource [io  0xae0f-0xaeff]
[    0.302660] pci_bus 0000:00: root bus resource [io  0xaf20-0xafdf]
[    0.302660] pci_bus 0000:00: root bus resource [io  0xaf20-0xafdf]
[    0.304011] pci_bus 0000:00: root bus resource [io  0xafe4-0xffff]
[    0.304011] pci_bus 0000:00: root bus resource [io  0xafe4-0xffff]
[    0.308016] pci_bus 0000:00: root bus resource [mem 0x000a0000-0x000bfff=
f]
[    0.308016] pci_bus 0000:00: root bus resource [mem 0x000a0000-0x000bfff=
f]
[    0.312011] pci_bus 0000:00: root bus resource [mem 0x14000000-0xfebffff=
f]
[    0.312011] pci_bus 0000:00: root bus resource [mem 0x14000000-0xfebffff=
f]
[    0.316061] pci 0000:00:00.0: [8086:1237] type 00 class 0x060000
[    0.316061] pci 0000:00:00.0: [8086:1237] type 00 class 0x060000
[    0.319878] pci 0000:00:01.0: [8086:7000] type 00 class 0x060100
[    0.319878] pci 0000:00:01.0: [8086:7000] type 00 class 0x060100
[    0.324928] pci 0000:00:01.1: [8086:7010] type 00 class 0x010180
[    0.324928] pci 0000:00:01.1: [8086:7010] type 00 class 0x010180
[    0.330718] pci 0000:00:01.1: reg 0x20: [io  0xc040-0xc04f]
[    0.330718] pci 0000:00:01.1: reg 0x20: [io  0xc040-0xc04f]
[    0.333234] pci 0000:00:01.1: legacy IDE quirk: reg 0x10: [io  0x01f0-0x=
01f7]
[    0.333234] pci 0000:00:01.1: legacy IDE quirk: reg 0x10: [io  0x01f0-0x=
01f7]
[    0.336019] pci 0000:00:01.1: legacy IDE quirk: reg 0x14: [io  0x03f6]
[    0.336019] pci 0000:00:01.1: legacy IDE quirk: reg 0x14: [io  0x03f6]
[    0.340016] pci 0000:00:01.1: legacy IDE quirk: reg 0x18: [io  0x0170-0x=
0177]
[    0.340016] pci 0000:00:01.1: legacy IDE quirk: reg 0x18: [io  0x0170-0x=
0177]
[    0.343112] pci 0000:00:01.1: legacy IDE quirk: reg 0x1c: [io  0x0376]
[    0.343112] pci 0000:00:01.1: legacy IDE quirk: reg 0x1c: [io  0x0376]
[    0.344755] pci 0000:00:01.3: [8086:7113] type 00 class 0x068000
[    0.344755] pci 0000:00:01.3: [8086:7113] type 00 class 0x068000
[    0.348645] pci 0000:00:01.3: quirk: [io  0x0600-0x063f] claimed by PIIX=
4 ACPI
[    0.348645] pci 0000:00:01.3: quirk: [io  0x0600-0x063f] claimed by PIIX=
4 ACPI
[    0.352042] pci 0000:00:01.3: quirk: [io  0x0700-0x070f] claimed by PIIX=
4 SMB
[    0.352042] pci 0000:00:01.3: quirk: [io  0x0700-0x070f] claimed by PIIX=
4 SMB
[    0.357728] pci 0000:00:02.0: [1013:00b8] type 00 class 0x030000
[    0.357728] pci 0000:00:02.0: [1013:00b8] type 00 class 0x030000
[    0.361686] pci 0000:00:02.0: reg 0x10: [mem 0xfc000000-0xfdffffff pref]
[    0.361686] pci 0000:00:02.0: reg 0x10: [mem 0xfc000000-0xfdffffff pref]
[    0.365378] pci 0000:00:02.0: reg 0x14: [mem 0xfebf0000-0xfebf0fff]
[    0.365378] pci 0000:00:02.0: reg 0x14: [mem 0xfebf0000-0xfebf0fff]
[    0.377410] pci 0000:00:02.0: reg 0x30: [mem 0xfebe0000-0xfebeffff pref]
[    0.377410] pci 0000:00:02.0: reg 0x30: [mem 0xfebe0000-0xfebeffff pref]
[    0.380845] pci 0000:00:03.0: [8086:100e] type 00 class 0x020000
[    0.380845] pci 0000:00:03.0: [8086:100e] type 00 class 0x020000
[    0.385187] pci 0000:00:03.0: reg 0x10: [mem 0xfebc0000-0xfebdffff]
[    0.385187] pci 0000:00:03.0: reg 0x10: [mem 0xfebc0000-0xfebdffff]
[    0.388564] pci 0000:00:03.0: reg 0x14: [io  0xc000-0xc03f]
[    0.388564] pci 0000:00:03.0: reg 0x14: [io  0xc000-0xc03f]
[    0.397161] pci 0000:00:03.0: reg 0x30: [mem 0xfeb80000-0xfebbffff pref]
[    0.397161] pci 0000:00:03.0: reg 0x30: [mem 0xfeb80000-0xfebbffff pref]
[    0.400730] pci 0000:00:04.0: [8086:25ab] type 00 class 0x088000
[    0.400730] pci 0000:00:04.0: [8086:25ab] type 00 class 0x088000
[    0.404015] pci 0000:00:04.0: reg 0x10: [mem 0xfebf1000-0xfebf100f]
[    0.404015] pci 0000:00:04.0: reg 0x10: [mem 0xfebf1000-0xfebf100f]
[    0.411335] pci_bus 0000:00: on NUMA node 0
[    0.411335] pci_bus 0000:00: on NUMA node 0
[    0.413724] ACPI: PCI Interrupt Link [LNKA] (IRQs
[    0.413724] ACPI: PCI Interrupt Link [LNKA] (IRQs 5 5 *10 *10 11 11))

[    0.416971] ACPI: PCI Interrupt Link [LNKB] (IRQs
[    0.416971] ACPI: PCI Interrupt Link [LNKB] (IRQs 5 5 *10 *10 11 11))

[    0.420939] ACPI: PCI Interrupt Link [LNKC] (IRQs
[    0.420939] ACPI: PCI Interrupt Link [LNKC] (IRQs 5 5 10 10 *11 *11))

[    0.424642] ACPI: PCI Interrupt Link [LNKD] (IRQs
[    0.424642] ACPI: PCI Interrupt Link [LNKD] (IRQs 5 5 10 10 *11 *11))

[    0.427143] ACPI: PCI Interrupt Link [LNKS] (IRQs
[    0.427143] ACPI: PCI Interrupt Link [LNKS] (IRQs *9 *9))

[    0.429618] ACPI:=20
[    0.429618] ACPI: Enabled 16 GPEs in block 00 to 0FEnabled 16 GPEs in bl=
ock 00 to 0F

[    0.433712] vgaarb: setting as boot device: PCI:0000:00:02.0
[    0.433712] vgaarb: setting as boot device: PCI:0000:00:02.0
[    0.435913] vgaarb: device added: PCI:0000:00:02.0,decodes=3Dio+mem,owns=
=3Dio+mem,locks=3Dnone
[    0.435913] vgaarb: device added: PCI:0000:00:02.0,decodes=3Dio+mem,owns=
=3Dio+mem,locks=3Dnone
[    0.436023] vgaarb: loaded
[    0.436023] vgaarb: loaded
[    0.437093] vgaarb: bridge control possible 0000:00:02.0
[    0.437093] vgaarb: bridge control possible 0000:00:02.0
[    0.440673] Linux video capture interface: v2.00
[    0.440673] Linux video capture interface: v2.00
[    0.442671] EDAC MC: Ver: 3.0.0
[    0.442671] EDAC MC: Ver: 3.0.0
[    0.444395] EDAC DEBUG: edac_mc_sysfs_init: device mc created
[    0.444395] EDAC DEBUG: edac_mc_sysfs_init: device mc created
[    0.447649] Advanced Linux Sound Architecture Driver Initialized.
[    0.447649] Advanced Linux Sound Architecture Driver Initialized.
[    0.448071] PCI: Using ACPI for IRQ routing
[    0.448071] PCI: Using ACPI for IRQ routing
[    0.452009] PCI: pci_cache_line_size set to 64 bytes
[    0.452009] PCI: pci_cache_line_size set to 64 bytes
[    0.454381] e820: reserve RAM buffer [mem 0x0009fc00-0x0009ffff]
[    0.454381] e820: reserve RAM buffer [mem 0x0009fc00-0x0009ffff]
[    0.456025] e820: reserve RAM buffer [mem 0x13fe0000-0x13ffffff]
[    0.456025] e820: reserve RAM buffer [mem 0x13fe0000-0x13ffffff]
[    0.461659] Switched to clocksource kvm-clock
[    0.461659] Switched to clocksource kvm-clock
[    0.463610] FS-Cache: Loaded
[    0.463610] FS-Cache: Loaded
[    0.463731] pnp: PnP ACPI init
[    0.463731] pnp: PnP ACPI init
[    0.465150] IOAPIC[0]: Set routing entry (0-8 -> 0x38 -> IRQ 8 Mode:0 Ac=
tive:0 Dest:1)
[    0.465150] IOAPIC[0]: Set routing entry (0-8 -> 0x38 -> IRQ 8 Mode:0 Ac=
tive:0 Dest:1)
[    0.468676] pnp 00:00: Plug and Play ACPI device, IDs PNP0b00 (active)
[    0.468676] pnp 00:00: Plug and Play ACPI device, IDs PNP0b00 (active)
[    0.471309] IOAPIC[0]: Set routing entry (0-1 -> 0x31 -> IRQ 1 Mode:0 Ac=
tive:0 Dest:1)
[    0.471309] IOAPIC[0]: Set routing entry (0-1 -> 0x31 -> IRQ 1 Mode:0 Ac=
tive:0 Dest:1)
[    0.474864] pnp 00:01: Plug and Play ACPI device, IDs PNP0303 (active)
[    0.474864] pnp 00:01: Plug and Play ACPI device, IDs PNP0303 (active)
[    0.477771] IOAPIC[0]: Set routing entry (0-12 -> 0x3c -> IRQ 12 Mode:0 =
Active:0 Dest:1)
[    0.477771] IOAPIC[0]: Set routing entry (0-12 -> 0x3c -> IRQ 12 Mode:0 =
Active:0 Dest:1)
[    0.481123] pnp 00:02: Plug and Play ACPI device, IDs PNP0f13 (active)
[    0.481123] pnp 00:02: Plug and Play ACPI device, IDs PNP0f13 (active)
[    0.485417] IOAPIC[0]: Set routing entry (0-6 -> 0x36 -> IRQ 6 Mode:0 Ac=
tive:0 Dest:1)
[    0.485417] IOAPIC[0]: Set routing entry (0-6 -> 0x36 -> IRQ 6 Mode:0 Ac=
tive:0 Dest:1)
[    0.488828] pnp 00:03: [dma 2]
[    0.488828] pnp 00:03: [dma 2]
[    0.490114] pnp 00:03: Plug and Play ACPI device, IDs PNP0700 (active)
[    0.490114] pnp 00:03: Plug and Play ACPI device, IDs PNP0700 (active)
[    0.493149] IOAPIC[0]: Set routing entry (0-7 -> 0x37 -> IRQ 7 Mode:0 Ac=
tive:0 Dest:1)
[    0.493149] IOAPIC[0]: Set routing entry (0-7 -> 0x37 -> IRQ 7 Mode:0 Ac=
tive:0 Dest:1)
[    0.496587] pnp 00:04: Plug and Play ACPI device, IDs PNP0400 (active)
[    0.496587] pnp 00:04: Plug and Play ACPI device, IDs PNP0400 (active)
[    0.500083] IOAPIC[0]: Set routing entry (0-4 -> 0x34 -> IRQ 4 Mode:0 Ac=
tive:0 Dest:1)
[    0.500083] IOAPIC[0]: Set routing entry (0-4 -> 0x34 -> IRQ 4 Mode:0 Ac=
tive:0 Dest:1)
[    0.503596] pnp 00:05: Plug and Play ACPI device, IDs PNP0501 (active)
[    0.503596] pnp 00:05: Plug and Play ACPI device, IDs PNP0501 (active)
[    0.507431] pnp: PnP ACPI: found 6 devices
[    0.507431] pnp: PnP ACPI: found 6 devices
[    0.515217] pci_bus 0000:00: resource 4 [io  0x0000-0x0cf7]
[    0.515217] pci_bus 0000:00: resource 4 [io  0x0000-0x0cf7]
[    0.517674] pci_bus 0000:00: resource 5 [io  0x0d00-0xadff]
[    0.517674] pci_bus 0000:00: resource 5 [io  0x0d00-0xadff]
[    0.519821] pci_bus 0000:00: resource 6 [io  0xae0f-0xaeff]
[    0.519821] pci_bus 0000:00: resource 6 [io  0xae0f-0xaeff]
[    0.522125] pci_bus 0000:00: resource 7 [io  0xaf20-0xafdf]
[    0.522125] pci_bus 0000:00: resource 7 [io  0xaf20-0xafdf]
[    0.525584] pci_bus 0000:00: resource 8 [io  0xafe4-0xffff]
[    0.525584] pci_bus 0000:00: resource 8 [io  0xafe4-0xffff]
[    0.528089] pci_bus 0000:00: resource 9 [mem 0x000a0000-0x000bffff]
[    0.528089] pci_bus 0000:00: resource 9 [mem 0x000a0000-0x000bffff]
[    0.530649] pci_bus 0000:00: resource 10 [mem 0x14000000-0xfebfffff]
[    0.530649] pci_bus 0000:00: resource 10 [mem 0x14000000-0xfebfffff]
[    0.533698] NET: Registered protocol family 1
[    0.533698] NET: Registered protocol family 1
[    0.535507] pci 0000:00:00.0: Limiting direct PCI/PCI transfers
[    0.535507] pci 0000:00:00.0: Limiting direct PCI/PCI transfers
[    0.538220] pci 0000:00:01.0: PIIX3: Enabling Passive Release
[    0.538220] pci 0000:00:01.0: PIIX3: Enabling Passive Release
[    0.540590] pci 0000:00:01.0: Activating ISA DMA hang workarounds
[    0.540590] pci 0000:00:01.0: Activating ISA DMA hang workarounds
[    0.543371] pci 0000:00:02.0: Video device with shadowed ROM
[    0.543371] pci 0000:00:02.0: Video device with shadowed ROM
[    0.545675] PCI: CLS 0 bytes, default 64
[    0.545675] PCI: CLS 0 bytes, default 64
[    0.547887] Unpacking initramfs...
[    0.547887] Unpacking initramfs...
[    1.668569] debug: unmapping init [mem 0xffff880012925000-0xffff880013fd=
7fff]
[    1.668569] debug: unmapping init [mem 0xffff880012925000-0xffff880013fd=
7fff]
[    1.673379] microcode: CPU0 sig=3D0xf61, pf=3D0x1, revision=3D0x1
[    1.673379] microcode: CPU0 sig=3D0xf61, pf=3D0x1, revision=3D0x1
[    1.675362] microcode: Microcode Update Driver: v2.00 <tigran@aivazian.f=
snet.co.uk>, Peter Oruba
[    1.675362] microcode: Microcode Update Driver: v2.00 <tigran@aivazian.f=
snet.co.uk>, Peter Oruba
[    1.680740] des3_ede-x86_64: performance on this CPU would be suboptimal=
: disabling des3_ede-x86_64.
[    1.680740] des3_ede-x86_64: performance on this CPU would be suboptimal=
: disabling des3_ede-x86_64.
[    1.683800] camellia-x86_64: performance on this CPU would be suboptimal=
: disabling camellia-x86_64.
[    1.683800] camellia-x86_64: performance on this CPU would be suboptimal=
: disabling camellia-x86_64.
[    1.687163] cryptomgr_test (15) used greatest stack depth: 14400 bytes l=
eft
[    1.687163] cryptomgr_test (15) used greatest stack depth: 14400 bytes l=
eft
[    1.689766] blowfish-x86_64: performance on this CPU would be suboptimal=
: disabling blowfish-x86_64.
[    1.689766] blowfish-x86_64: performance on this CPU would be suboptimal=
: disabling blowfish-x86_64.
[    1.693044] twofish-x86_64-3way: performance on this CPU would be subopt=
imal: disabling twofish-x86_64-3way.
[    1.693044] twofish-x86_64-3way: performance on this CPU would be subopt=
imal: disabling twofish-x86_64-3way.
[    1.698288] sha1_ssse3: Neither AVX nor AVX2 nor SSSE3 is available/usab=
le.
[    1.698288] sha1_ssse3: Neither AVX nor AVX2 nor SSSE3 is available/usab=
le.
[    1.700732] PCLMULQDQ-NI instructions are not detected.
[    1.700732] PCLMULQDQ-NI instructions are not detected.
[    1.702558] sha512_ssse3: Neither AVX nor SSSE3 is available/usable.
[    1.702558] sha512_ssse3: Neither AVX nor SSSE3 is available/usable.
[    1.704807] AVX or AES-NI instructions are not detected.
[    1.704807] AVX or AES-NI instructions are not detected.
[    1.706685] AVX instructions are not detected.
[    1.706685] AVX instructions are not detected.
[    1.708211] AVX instructions are not detected.
[    1.708211] AVX instructions are not detected.
[    1.709803] AVX2 or AES-NI instructions are not detected.
[    1.709803] AVX2 or AES-NI instructions are not detected.
[    1.711660] AVX2 instructions are not detected.
[    1.711660] AVX2 instructions are not detected.
[    1.713261] rcu-torture:--- Start of test: nreaders=3D1 nfakewriters=3D4=
 stat_interval=3D60 verbose=3D1 test_no_idle_hz=3D1 shuffle_interval=3D3 st=
utter=3D5 irqreader=3D1 fqs_duration=3D0 fqs_holdoff=3D0 fqs_stutter=3D3 te=
st_boost=3D1/0 test_boost_interval=3D7 test_boost_duration=3D4 shutdown_sec=
s=3D0 stall_cpu=3D0 stall_cpu_holdoff=3D10 n_barrier_cbs=3D0 onoff_interval=
=3D0 onoff_holdoff=3D0
[    1.713261] rcu-torture:--- Start of test: nreaders=3D1 nfakewriters=3D4=
 stat_interval=3D60 verbose=3D1 test_no_idle_hz=3D1 shuffle_interval=3D3 st=
utter=3D5 irqreader=3D1 fqs_duration=3D0 fqs_holdoff=3D0 fqs_stutter=3D3 te=
st_boost=3D1/0 test_boost_interval=3D7 test_boost_duration=3D4 shutdown_sec=
s=3D0 stall_cpu=3D0 stall_cpu_holdoff=3D10 n_barrier_cbs=3D0 onoff_interval=
=3D0 onoff_holdoff=3D0
[    1.723986] rcu-torture: Creating rcu_torture_writer task
[    1.723986] rcu-torture: Creating rcu_torture_writer task
[    1.726016] rcu-torture: Creating rcu_torture_fakewriter task
[    1.726016] rcu-torture: Creating rcu_torture_fakewriter task
[    1.728111] rcu-torture: rcu_torture_writer task started
[    1.728111] rcu-torture: rcu_torture_writer task started
[    1.729986] rcu-torture: Creating rcu_torture_fakewriter task
[    1.729986] rcu-torture: Creating rcu_torture_fakewriter task
[    1.732009] rcu-torture: rcu_torture_fakewriter task started
[    1.732009] rcu-torture: rcu_torture_fakewriter task started
[    1.734977] rcu-torture: Creating rcu_torture_fakewriter task
[    1.734977] rcu-torture: Creating rcu_torture_fakewriter task
[    1.736944] rcu-torture: rcu_torture_fakewriter task started
[    1.736944] rcu-torture: rcu_torture_fakewriter task started
[    1.738998] rcu-torture: Creating rcu_torture_fakewriter task
[    1.738998] rcu-torture: Creating rcu_torture_fakewriter task
[    1.741068] rcu-torture: rcu_torture_fakewriter task started
[    1.741068] rcu-torture: rcu_torture_fakewriter task started
[    1.743087] rcu-torture: Creating rcu_torture_reader task
[    1.743087] rcu-torture: Creating rcu_torture_reader task
[    1.744992] rcu-torture: rcu_torture_fakewriter task started
[    1.744992] rcu-torture: rcu_torture_fakewriter task started
[    1.747011] rcu-torture: Creating rcu_torture_stats task
[    1.747011] rcu-torture: Creating rcu_torture_stats task
[    1.748959] rcu-torture: rcu_torture_reader task started
[    1.748959] rcu-torture: rcu_torture_reader task started
[    1.750859] rcu-torture: Creating torture_shuffle task
[    1.750859] rcu-torture: Creating torture_shuffle task
[    1.752677] rcu-torture: rcu_torture_stats task started
[    1.752677] rcu-torture: rcu_torture_stats task started
[    1.756722] rcu-torture: Creating torture_stutter task
[    1.756722] rcu-torture: Creating torture_stutter task
[    1.758540] rcu-torture: torture_shuffle task started
[    1.758540] rcu-torture: torture_shuffle task started
[    1.760441] rcu-torture: Creating rcu_torture_cbflood task
[    1.760441] rcu-torture: Creating rcu_torture_cbflood task
[    1.762402] rcu-torture: torture_stutter task started
[    1.762402] rcu-torture: torture_stutter task started
[    1.765916] futex hash table entries: 256 (order: 2, 24576 bytes)
[    1.765916] futex hash table entries: 256 (order: 2, 24576 bytes)
[    1.770410] rcu-torture: rcu_torture_cbflood task started
[    1.770410] rcu-torture: rcu_torture_cbflood task started
[    2.441496] zpool: loaded
[    2.441496] zpool: loaded
[    2.454545] zbud: loaded
[    2.454545] zbud: loaded
[    2.459435] romfs: ROMFS MTD (C) 2007 Red Hat, Inc.
[    2.459435] romfs: ROMFS MTD (C) 2007 Red Hat, Inc.
[    2.461517] fuse init (API version 7.23)
[    2.461517] fuse init (API version 7.23)
[    2.480463] cryptomgr_test (64) used greatest stack depth: 14336 bytes l=
eft
[    2.480463] cryptomgr_test (64) used greatest stack depth: 14336 bytes l=
eft
[    2.484333] Key type asymmetric registered
[    2.484333] Key type asymmetric registered
[    2.485786] start plist test
[    2.485786] start plist test
[    2.489895] end plist test
[    2.489895] end plist test
[    2.490937] test_string_helpers: Running tests...
[    2.490937] test_string_helpers: Running tests...
[    2.493064] test_firmware: interface ready
[    2.493064] test_firmware: interface ready
[    2.528414] crc32: CRC_LE_BITS =3D 1, CRC_BE BITS =3D 1
[    2.528414] crc32: CRC_LE_BITS =3D 1, CRC_BE BITS =3D 1
[    2.530034] crc32: self tests passed, processed 225944 bytes in 10331516=
 nsec
[    2.530034] crc32: self tests passed, processed 225944 bytes in 10331516=
 nsec
[    2.544647] crc32c: CRC_LE_BITS =3D 1
[    2.544647] crc32c: CRC_LE_BITS =3D 1
[    2.545780] crc32c: self tests passed, processed 225944 bytes in 5198416=
 nsec
[    2.545780] crc32c: self tests passed, processed 225944 bytes in 5198416=
 nsec
[    2.672168] tsc: Refined TSC clocksource calibration: 2925.998 MHz
[    2.672168] tsc: Refined TSC clocksource calibration: 2925.998 MHz
[    3.137370] crc32_combine: 8373 self tests passed
[    3.137370] crc32_combine: 8373 self tests passed
[    3.654462] crc32c_combine: 8373 self tests passed
[    3.654462] crc32c_combine: 8373 self tests passed
[    3.656420] rbtree testing
[    3.656420] rbtree testing -> 40979 cycles
 -> 40979 cycles
[    5.159165] augmented rbtree testing
[    5.159165] augmented rbtree testing -> 58008 cycles
 -> 58008 cycles
[    7.267331] sched: RT throttling activated
[    7.267331] sched: RT throttling activated
[    7.267721] no IO addresses supplied
[    7.267721] no IO addresses supplied
[    7.269688] hgafb: HGA card not detected.
[    7.269688] hgafb: HGA card not detected.
[    7.270590] hgafb: probe of hgafb.0 failed with error -22
[    7.270590] hgafb: probe of hgafb.0 failed with error -22
[    7.271984] ipmi message handler version 39.2
[    7.271984] ipmi message handler version 39.2
[    7.273099] ipmi device interface
[    7.273099] ipmi device interface
[    7.273902] IPMI System Interface driver.
[    7.273902] IPMI System Interface driver.
[    7.275017] ipmi_si: Unable to find any System Interface(s)
[    7.275017] ipmi_si: Unable to find any System Interface(s)
[    7.276871] IPMI Watchdog: driver initialized
[    7.276871] IPMI Watchdog: driver initialized
[    7.279188] input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/inpu=
t/input0
[    7.279188] input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/inpu=
t/input0
[    7.282292] ACPI: Power Button [PWRF]
[    7.282292] ACPI: Power Button [PWRF]
[    7.285161] r3964: Philips r3964 Driver $Revision: 1.10 $
[    7.285161] r3964: Philips r3964 Driver $Revision: 1.10 $
[    7.286894] Serial: 8250/16550 driver, 4 ports, IRQ sharing disabled
[    7.286894] Serial: 8250/16550 driver, 4 ports, IRQ sharing disabled
[    7.319803] serial 00:05: ttyS0 at I/O 0x3f8 (irq =3D 4, base_baud =3D 1=
15200) is a 16550A
[    7.319803] serial 00:05: ttyS0 at I/O 0x3f8 (irq =3D 4, base_baud =3D 1=
15200) is a 16550A
[    7.325567] Hangcheck: starting hangcheck timer 0.9.1 (tick is 180 secon=
ds, margin is 60 seconds).
[    7.325567] Hangcheck: starting hangcheck timer 0.9.1 (tick is 180 secon=
ds, margin is 60 seconds).
[    7.330914] mtdoops: mtd device (mtddev=3Dname/number) must be supplied
[    7.330914] mtdoops: mtd device (mtddev=3Dname/number) must be supplied
[    7.333248] platform physmap-flash.0: failed to claim resource 0
[    7.333248] platform physmap-flash.0: failed to claim resource 0
[    7.335307] slram: not enough parameters.
[    7.335307] slram: not enough parameters.
[    7.338722] HSI/SSI char device loaded
[    7.338722] HSI/SSI char device loaded
[    7.339807] i8042: PNP: PS/2 Controller [PNP0303:KBD,PNP0f13:MOU] at 0x6=
0,0x64 irq 1,12
[    7.339807] i8042: PNP: PS/2 Controller [PNP0303:KBD,PNP0f13:MOU] at 0x6=
0,0x64 irq 1,12
[    7.342475] serio: i8042 KBD port at 0x60,0x64 irq 1
[    7.342475] serio: i8042 KBD port at 0x60,0x64 irq 1
[    7.343728] serio: i8042 AUX port at 0x60,0x64 irq 12
[    7.343728] serio: i8042 AUX port at 0x60,0x64 irq 12
[    7.345652] mousedev: PS/2 mouse device common for all mice
[    7.345652] mousedev: PS/2 mouse device common for all mice
[    7.347045] evbug: Connected device: input0 (Power Button at LNXPWRBN/bu=
tton/input0)
[    7.347045] evbug: Connected device: input0 (Power Button at LNXPWRBN/bu=
tton/input0)
[    7.350883] input: AT Translated Set 2 keyboard as /devices/platform/i80=
42/serio0/input/input1
[    7.350883] input: AT Translated Set 2 keyboard as /devices/platform/i80=
42/serio0/input/input1
[    7.355863] IR NEC protocol handler initialized
[    7.355863] IR NEC protocol handler initialized
[    7.357530] evbug: Connected device: input1 (AT Translated Set 2 keyboar=
d at isa0060/serio0/input0)
[    7.357530] evbug: Connected device: input1 (AT Translated Set 2 keyboar=
d at isa0060/serio0/input0)
[    7.360384] IR RC5(x/sz) protocol handler initialized
[    7.360384] IR RC5(x/sz) protocol handler initialized
[    7.361942] IR RC6 protocol handler initialized
[    7.361942] IR RC6 protocol handler initialized
[    7.363489] IR JVC protocol handler initialized
[    7.363489] IR JVC protocol handler initialized
[    7.365157] IR Sony protocol handler initialized
[    7.365157] IR Sony protocol handler initialized
[    7.366538] IR Sharp protocol handler initialized
[    7.366538] IR Sharp protocol handler initialized
[    7.368150] IR XMP protocol handler initialized
[    7.368150] IR XMP protocol handler initialized
[    7.369622] smssdio: Siano SMS1xxx SDIO driver
[    7.369622] smssdio: Siano SMS1xxx SDIO driver
[    7.370927] smssdio: Copyright Pierre Ossman
[    7.370927] smssdio: Copyright Pierre Ossman
[    7.372366] Driver for 1-wire Dallas network protocol.
[    7.372366] Driver for 1-wire Dallas network protocol.
[    7.374106] DS1WM w1 busmaster driver - (c) 2004 Szabolcs Gyurko
[    7.374106] DS1WM w1 busmaster driver - (c) 2004 Szabolcs Gyurko
[    7.376232] 1-Wire driver for the DS2760 battery monitor chip - (c) 2004=
-2005, Szabolcs Gyurko
[    7.376232] 1-Wire driver for the DS2760 battery monitor chip - (c) 2004=
-2005, Szabolcs Gyurko
[    7.379408] applesmc: supported laptop not found!
[    7.379408] applesmc: supported laptop not found!
[    7.380495] applesmc: driver init failed (ret=3D-19)!
[    7.380495] applesmc: driver init failed (ret=3D-19)!
[    7.381753] f71882fg: Not a Fintek device
[    7.381753] f71882fg: Not a Fintek device
[    7.382632] f71882fg: Not a Fintek device
[    7.382632] f71882fg: Not a Fintek device
[    7.384647] sch56xx_common: Unsupported device id: 0xff
[    7.384647] sch56xx_common: Unsupported device id: 0xff
[    7.385851] sch56xx_common: Unsupported device id: 0xff
[    7.385851] sch56xx_common: Unsupported device id: 0xff
[    7.387385] intel_powerclamp: Intel powerclamp does not run on family 15=
 model 6
[    7.387385] intel_powerclamp: Intel powerclamp does not run on family 15=
 model 6
[    7.389135] it87_wdt: no device
[    7.389135] it87_wdt: no device
[    7.389875] pc87413_wdt: Version 1.1 at io 0x2E
[    7.389875] pc87413_wdt: Version 1.1 at io 0x2E
[    7.390988] pc87413_wdt: initialized. timeout=3D1 min
[    7.390988] pc87413_wdt: initialized. timeout=3D1 min
[    7.392573] pc87413_wdt: cannot request SWC region at 0xffff
[    7.392573] pc87413_wdt: cannot request SWC region at 0xffff
[    7.395128] sbc60xxwdt: WDT driver for 60XX single board computer initia=
lised. timeout=3D30 sec (nowayout=3D1)
[    7.395128] sbc60xxwdt: WDT driver for 60XX single board computer initia=
lised. timeout=3D30 sec (nowayout=3D1)
[    7.398866] cpu5wdt: misc_register failed
[    7.398866] cpu5wdt: misc_register failed
[    7.400267] smsc37b787_wdt: SMsC 37B787 watchdog component driver 1.1 in=
itialising...
[    7.400267] smsc37b787_wdt: SMsC 37B787 watchdog component driver 1.1 in=
itialising...
[    7.403642] smsc37b787_wdt: Unable to register miscdev on minor 130
[    7.403642] smsc37b787_wdt: Unable to register miscdev on minor 130
[    7.405647] w83877f_wdt: I/O address 0x0443 already in use
[    7.405647] w83877f_wdt: I/O address 0x0443 already in use
[    7.407311] w83977f_wdt: driver v1.00
[    7.407311] w83977f_wdt: driver v1.00
[    7.408454] w83977f_wdt: cannot register miscdev on minor=3D130 (err=3D-=
16)
[    7.408454] w83977f_wdt: cannot register miscdev on minor=3D130 (err=3D-=
16)
[    7.410436] machzwd: MachZ ZF-Logic Watchdog driver initializing
[    7.410436] machzwd: MachZ ZF-Logic Watchdog driver initializing
[    7.412283] machzwd: no ZF-Logic found
[    7.412283] machzwd: no ZF-Logic found
[    7.413443] sbc_epx_c3: cannot register miscdev on minor=3D130 (err=3D-1=
6)
[    7.413443] sbc_epx_c3: cannot register miscdev on minor=3D130 (err=3D-1=
6)
[    7.415552] watchdog: Software Watchdog: cannot register miscdev on mino=
r=3D130 (err=3D-16).
[    7.415552] watchdog: Software Watchdog: cannot register miscdev on mino=
r=3D130 (err=3D-16).
[    7.418006] watchdog: Software Watchdog: a legacy watchdog module is pro=
bably present.
[    7.418006] watchdog: Software Watchdog: a legacy watchdog module is pro=
bably present.
[    7.420533] softdog: Software Watchdog Timer: 0.08 initialized. soft_nob=
oot=3D0 soft_margin=3D60 sec soft_panic=3D0 (nowayout=3D1)
[    7.420533] softdog: Software Watchdog Timer: 0.08 initialized. soft_nob=
oot=3D0 soft_margin=3D60 sec soft_panic=3D0 (nowayout=3D1)
[    7.424120] Driver 'mmc_test' needs updating - please use bus_type metho=
ds
[    7.424120] Driver 'mmc_test' needs updating - please use bus_type metho=
ds
[    7.426226] sdhci: Secure Digital Host Controller Interface driver
[    7.426226] sdhci: Secure Digital Host Controller Interface driver
[    7.428155] sdhci: Copyright(c) Pierre Ossman
[    7.428155] sdhci: Copyright(c) Pierre Ossman
[    7.429451] sdhci-pltfm: SDHCI platform and OF driver helper
[    7.429451] sdhci-pltfm: SDHCI platform and OF driver helper
[    7.432507] logger: created 256K log 'log_main'
[    7.432507] logger: created 256K log 'log_main'
[    7.434543] logger: created 256K log 'log_events'
[    7.434543] logger: created 256K log 'log_events'
[    7.436196] logger: created 256K log 'log_radio'
[    7.436196] logger: created 256K log 'log_radio'
[    7.437748] logger: created 256K log 'log_system'
[    7.437748] logger: created 256K log 'log_system'
[    7.439240] FPGA DOWNLOAD --->
[    7.439240] FPGA DOWNLOAD --->
[    7.440142] FPGA image file name: xlinx_fpga_firmware.bit
[    7.440142] FPGA image file name: xlinx_fpga_firmware.bit
[    7.441952] GPIO INIT FAIL!!
[    7.441952] GPIO INIT FAIL!!
[    7.450449]=20
[    7.450449] printing PIC contents
[    7.450449]=20
[    7.450449] printing PIC contents
[    7.451892] ... PIC  IMR: ffff
[    7.451892] ... PIC  IMR: ffff
[    7.452020] ... PIC  IRR: 1013
[    7.452020] ... PIC  IRR: 1013
[    7.453787] ... PIC  ISR: 0000
[    7.453787] ... PIC  ISR: 0000
[    7.454700] ... PIC ELCR: 0c00
[    7.454700] ... PIC ELCR: 0c00
[    7.455658] printing local APIC contents on CPU#0/0:
[    7.455658] printing local APIC contents on CPU#0/0:
[    7.457097] ... APIC ID:      00000000 (0)
[    7.457097] ... APIC ID:      00000000 (0)
[    7.457770] ... APIC VERSION: 01050014
[    7.457770] ... APIC VERSION: 01050014
[    7.457770] ... APIC TASKPRI: 00000000 (00)
[    7.457770] ... APIC TASKPRI: 00000000 (00)
[    7.457770] ... APIC PROCPRI: 00000000
[    7.457770] ... APIC PROCPRI: 00000000
[    7.457770] ... APIC LDR: 01000000
[    7.457770] ... APIC LDR: 01000000
[    7.457770] ... APIC DFR: ffffffff
[    7.457770] ... APIC DFR: ffffffff
[    7.457770] ... APIC SPIV: 000001ff
[    7.457770] ... APIC SPIV: 000001ff
[    7.457770] ... APIC ISR field:
[    7.457770] ... APIC ISR field:
[    7.457770] 00000000
[    7.457770] 000000000000000000000000000000000000000000000000000000000000=
000000000000000000000000000000000000000000000000000000000000

[    7.457770] ... APIC TMR field:
[    7.457770] ... APIC TMR field:
[    7.457770] 00000000
[    7.457770] 000000000e2000000e200000000000000000000000000000000000000000=
000000000000000000000000000000000000000000000000000000000000

[    7.457770] ... APIC IRR field:
[    7.457770] ... APIC IRR field:
[    7.457770] 00000000
[    7.457770] 000000000000000000000000000000000000000000000000000000000000=
000000000000000000000000000000000000000000000000800000008000

[    7.457770] ... APIC ESR: 00000000
[    7.457770] ... APIC ESR: 00000000
[    7.457770] ... APIC ICR: 00000831
[    7.457770] ... APIC ICR: 00000831
[    7.457770] ... APIC ICR2: 01000000
[    7.457770] ... APIC ICR2: 01000000
[    7.457770] ... APIC LVTT: 000000ef
[    7.457770] ... APIC LVTT: 000000ef
[    7.457770] ... APIC LVTPC: 00010000
[    7.457770] ... APIC LVTPC: 00010000
[    7.457770] ... APIC LVT0: 00010700
[    7.457770] ... APIC LVT0: 00010700
[    7.457770] ... APIC LVT1: 00000400
[    7.457770] ... APIC LVT1: 00000400
[    7.457770] ... APIC LVTERR: 000000fe
[    7.457770] ... APIC LVTERR: 000000fe
[    7.457770] ... APIC TMICT: 00021f13
[    7.457770] ... APIC TMICT: 00021f13
[    7.457770] ... APIC TMCCT: 00000000
[    7.457770] ... APIC TMCCT: 00000000
[    7.457770] ... APIC TDCR: 00000003
[    7.457770] ... APIC TDCR: 00000003
[    7.457770]=20
[    7.457770]=20
[    7.487009] number of MP IRQ sources: 15.
[    7.487009] number of MP IRQ sources: 15.
[    7.488655] number of IO-APIC #0 registers: 24.
[    7.488655] number of IO-APIC #0 registers: 24.
[    7.490381] testing the IO APIC.......................
[    7.490381] testing the IO APIC.......................
[    7.492537] IO APIC #0......
[    7.492537] IO APIC #0......
[    7.493691] .... register #00: 00000000
[    7.493691] .... register #00: 00000000
[    7.495293] .......    : physical APIC id: 00
[    7.495293] .......    : physical APIC id: 00
[    7.496654] .......    : Delivery Type: 0
[    7.496654] .......    : Delivery Type: 0
[    7.497528] .......    : LTS          : 0
[    7.497528] .......    : LTS          : 0
[    7.498436] .... register #01: 00170011
[    7.498436] .... register #01: 00170011
[    7.499428] .......     : max redirection entries: 17
[    7.499428] .......     : max redirection entries: 17
[    7.500540] .......     : PRQ implemented: 0
[    7.500540] .......     : PRQ implemented: 0
[    7.501440] .......     : IO APIC version: 11
[    7.501440] .......     : IO APIC version: 11
[    7.502359] .... register #02: 00000000
[    7.502359] .... register #02: 00000000
[    7.503238] .......     : arbitration: 00
[    7.503238] .......     : arbitration: 00
[    7.504121] .... IRQ redirection table:
[    7.504121] .... IRQ redirection table:
[    7.505001] 1    0    0   0   0    0    0    00
[    7.505001] 1    0    0   0   0    0    0    00
[    7.506692] 0    0    0   0   0    1    1    31
[    7.506692] 0    0    0   0   0    1    1    31
[    7.508437] 0    0    0   0   0    1    1    30
[    7.508437] 0    0    0   0   0    1    1    30
[    7.510265] 0    0    0   0   0    1    1    33
[    7.510265] 0    0    0   0   0    1    1    33
[    7.512164] 1    0    0   0   0    1    1    34
[    7.512164] 1    0    0   0   0    1    1    34
[    7.513934] 1    1    0   0   0    1    1    35
[    7.513934] 1    1    0   0   0    1    1    35
[    7.515721] 0    0    0   0   0    1    1    36
[    7.515721] 0    0    0   0   0    1    1    36
[    7.517639] 0    0    0   0   0    1    1    37
[    7.517639] 0    0    0   0   0    1    1    37
[    7.519454] 0    0    0   0   0    1    1    38
[    7.519454] 0    0    0   0   0    1    1    38
[    7.521018] 0    1    0   0   0    1    1    39
[    7.521018] 0    1    0   0   0    1    1    39
[    7.522644] 1    1    0   0   0    1    1    3A
[    7.522644] 1    1    0   0   0    1    1    3A
[    7.524504] 1    1    0   0   0    1    1    3B
[    7.524504] 1    1    0   0   0    1    1    3B
[    7.526393] 0    0    0   0   0    1    1    3C
[    7.526393] 0    0    0   0   0    1    1    3C
[    7.528193] 0    0    0   0   0    1    1    3D
[    7.528193] 0    0    0   0   0    1    1    3D
[    7.529992] 0    0    0   0   0    1    1    3E
[    7.529992] 0    0    0   0   0    1    1    3E
[    7.531888] 0    0    0   0   0    1    1    3F
[    7.531888] 0    0    0   0   0    1    1    3F
[    7.533708] 1    0    0   0   0    0    0    00
[    7.533708] 1    0    0   0   0    0    0    00
[    7.535369] 1    0    0   0   0    0    0    00
[    7.535369] 1    0    0   0   0    0    0    00
[    7.536381] 1    0    0   0   0    0    0    00
[    7.536381] 1    0    0   0   0    0    0    00
[    7.537416] 1    0    0   0   0    0    0    00
[    7.537416] 1    0    0   0   0    0    0    00
[    7.538448] 1    0    0   0   0    0    0    00
[    7.538448] 1    0    0   0   0    0    0    00
[    7.539540] 1    0    0   0   0    0    0    00
[    7.539540] 1    0    0   0   0    0    0    00
[    7.540521] 1    0    0   0   0    0    0    00
[    7.540521] 1    0    0   0   0    0    0    00
[    7.541482] 1    0    0   0   0    0    0    00
[    7.541482] 1    0    0   0   0    0    0    00
[    7.542519] IRQ to pin mappings:
[    7.542519] IRQ to pin mappings:
[    7.543281] IRQ0=20
[    7.543281] IRQ0 -> 0:2-> 0:2

[    7.543881] IRQ1=20
[    7.543881] IRQ1 -> 0:1-> 0:1

[    7.544636] IRQ3=20
[    7.544636] IRQ3 -> 0:3-> 0:3

[    7.545489] IRQ4=20
[    7.545489] IRQ4 -> 0:4-> 0:4

[    7.546369] IRQ5=20
[    7.546369] IRQ5 -> 0:5-> 0:5

[    7.547296] IRQ6=20
[    7.547296] IRQ6 -> 0:6-> 0:6

[    7.548052] IRQ7=20
[    7.548052] IRQ7 -> 0:7-> 0:7

[    7.548617] IRQ8=20
[    7.548617] IRQ8 -> 0:8-> 0:8

[    7.549547] IRQ9=20
[    7.549547] IRQ9 -> 0:9-> 0:9

[    7.550216] IRQ10=20
[    7.550216] IRQ10 -> 0:10-> 0:10

[    7.551095] IRQ11=20
[    7.551095] IRQ11 -> 0:11-> 0:11

[    7.551997] IRQ12=20
[    7.551997] IRQ12 -> 0:12-> 0:12

[    7.553075] IRQ13=20
[    7.553075] IRQ13 -> 0:13-> 0:13

[    7.554136] IRQ14=20
[    7.554136] IRQ14 -> 0:14-> 0:14

[    7.555084] IRQ15=20
[    7.555084] IRQ15 -> 0:15-> 0:15

[    7.555771] .................................... done.
[    7.555771] .................................... done.
[    7.557537] bootconsole [earlyser0] disabled
[    7.557537] bootconsole [earlyser0] disabled
[    7.559369] cryptomgr_probe (83) used greatest stack depth: 13768 bytes =
left
[    7.560366] Key type encrypted registered
[    7.561772]   Magic number: 10:107:796
[    7.562741] ALSA device list:
[    7.563292]   No soundcards found.
[    7.564660] debug: unmapping init [mem 0xffffffff82303000-0xffffffff823d=
0fff]
[    7.566071] Write protecting the kernel read-only data: 14336k
[    7.567512] debug: unmapping init [mem 0xffff880001776000-0xffff8800017f=
ffff]
[    7.568803] debug: unmapping init [mem 0xffff880001cbc000-0xffff880001df=
ffff]
[    7.581740] random: init urandom read with 2 bits of entropy available
[    7.595331] mount (90) used greatest stack depth: 13104 bytes left
/bin/sh: /proc/self/fd/9: No such file or directory
/bin/sh: /proc/self/fd/9: No such file or directory
/bin/sh: /proc/self/fd/9: No such file or directory
[   17.673482] ------------[ cut here ]------------
[   17.674874] WARNING: CPU: 0 PID: 109 at net/netlink/genetlink.c:1011 gen=
l_bind+0x142/0x15e()
[   17.676682] CPU: 0 PID: 109 Comm: trinity-main Not tainted 3.18.0-11169-=
gc380d9a #9
[   17.678005]  0000000000000009 ffff88000b44fdd8 ffffffff8175b593 ffff8800=
0b44fe18
[   17.679450]  ffffffff810b55aa 0000000000000000 ffffffff8174d931 ffffffff=
834a3400
[   17.680929]  0000000000000000 0000000000000000 0000000000000000 ffff8800=
0b44fe28
[   17.682377] Call Trace:
[   17.682820]  [<ffffffff8175b593>] dump_stack+0x2e/0x3e
[   17.683753]  [<ffffffff810b55aa>] warn_slowpath_common+0xb6/0xe5
[   17.684801]  [<ffffffff8174d931>] ? genl_bind+0x142/0x15e
[   17.685797]  [<ffffffff810b56db>] warn_slowpath_null+0x23/0x2c
[   17.686930]  [<ffffffff8174d931>] genl_bind+0x142/0x15e
[   17.688149]  [<ffffffff8174ab86>] netlink_bind+0x155/0x2ce
[   17.689413]  [<ffffffff8170e512>] SyS_bind+0xc1/0x117
[   17.690564]  [<ffffffff81769058>] ? _raw_spin_unlock+0x38/0x50
[   17.691875]  [<ffffffff8114553f>] ? context_tracking_user_exit+0xe2/0x101
[   17.693471]  [<ffffffff810eafbd>] ? trace_hardirqs_on+0x1b/0x24
[   17.694823]  [<ffffffff8176a2e7>] system_call_fastpath+0x12/0x17
[   17.696182] ---[ end trace f8ae22d84a926b3f ]---
[   17.697267] ------------[ cut here ]------------
[   17.698355] WARNING: CPU: 0 PID: 109 at net/netlink/genetlink.c:1011 gen=
l_bind+0x142/0x15e()
[   17.700582] CPU: 0 PID: 109 Comm: trinity-main Tainted: G        W      =
3.18.0-11169-gc380d9a #9
[   17.702557]  0000000000000009 ffff88000b44fdd8 ffffffff8175b593 ffff8800=
0b44fe18
[   17.704435]  ffffffff810b55aa 0000000000000001 ffffffff8174d931 ffffffff=
834a3400
[   17.706213]  0000000000000001 0000000000000000 0000000000000000 ffff8800=
0b44fe28
[   17.707938] Call Trace:
[   17.708529]  [<ffffffff8175b593>] dump_stack+0x2e/0x3e
[   17.709787]  [<ffffffff810b55aa>] warn_slowpath_common+0xb6/0xe5
[   17.711150]  [<ffffffff8174d931>] ? genl_bind+0x142/0x15e
[   17.712397]  [<ffffffff810b56db>] warn_slowpath_null+0x23/0x2c
[   17.713700]  [<ffffffff8174d931>] genl_bind+0x142/0x15e
[   17.714904]  [<ffffffff8174ab86>] netlink_bind+0x155/0x2ce
[   17.716150]  [<ffffffff8170e512>] SyS_bind+0xc1/0x117
[   17.717325]  [<ffffffff81769058>] ? _raw_spin_unlock+0x38/0x50
[   17.718645]  [<ffffffff8114553f>] ? context_tracking_user_exit+0xe2/0x101
[   17.720172]  [<ffffffff810eafbd>] ? trace_hardirqs_on+0x1b/0x24
[   17.721651]  [<ffffffff8176a2e7>] system_call_fastpath+0x12/0x17
[   17.722942] ---[ end trace f8ae22d84a926b40 ]---
[   17.723829] ------------[ cut here ]------------
[   17.725074] WARNING: CPU: 0 PID: 109 at net/netlink/genetlink.c:1011 gen=
l_bind+0x142/0x15e()
[   17.727120] CPU: 0 PID: 109 Comm: trinity-main Tainted: G        W      =
3.18.0-11169-gc380d9a #9
[   17.729225]  0000000000000009 ffff88000b44fdd8 ffffffff8175b593 ffff8800=
0b44fe18
[   17.730536]  ffffffff810b55aa 0000000000000004 ffffffff8174d931 ffffffff=
834a3400
[   17.731749]  0000000000000004 0000000000000000 0000000000000000 ffff8800=
0b44fe28
[   17.733340] Call Trace:
[   17.733786]  [<ffffffff8175b593>] dump_stack+0x2e/0x3e
[   17.734690]  [<ffffffff810b55aa>] warn_slowpath_common+0xb6/0xe5
[   17.735747]  [<ffffffff8174d931>] ? genl_bind+0x142/0x15e
[   17.736751]  [<ffffffff810b56db>] warn_slowpath_null+0x23/0x2c
[   17.737778]  [<ffffffff8174d931>] genl_bind+0x142/0x15e
[   17.738697]  [<ffffffff8174ab86>] netlink_bind+0x155/0x2ce
[   17.739666]  [<ffffffff8170e512>] SyS_bind+0xc1/0x117
[   17.740590]  [<ffffffff81769058>] ? _raw_spin_unlock+0x38/0x50
[   17.741606]  [<ffffffff8114553f>] ? context_tracking_user_exit+0xe2/0x101
[   17.742779]  [<ffffffff810eafbd>] ? trace_hardirqs_on+0x1b/0x24
[   17.743815]  [<ffffffff8176a2e7>] system_call_fastpath+0x12/0x17
[   17.744880] ---[ end trace f8ae22d84a926b41 ]---
[   17.745668] ------------[ cut here ]------------
[   17.746471] WARNING: CPU: 0 PID: 109 at net/netlink/genetlink.c:1011 gen=
l_bind+0x142/0x15e()
[   17.748214] CPU: 0 PID: 109 Comm: trinity-main Tainted: G        W      =
3.18.0-11169-gc380d9a #9
[   17.749715]  0000000000000009 ffff88000b44fdd8 ffffffff8175b593 ffff8800=
0b44fe18
[   17.751041]  ffffffff810b55aa 0000000000000005 ffffffff8174d931 ffffffff=
834a3400
[   17.752433]  0000000000000005 0000000000000000 0000000000000000 ffff8800=
0b44fe28
[   17.753757] Call Trace:
[   17.754175]  [<ffffffff8175b593>] dump_stack+0x2e/0x3e
[   17.755055]  [<ffffffff810b55aa>] warn_slowpath_common+0xb6/0xe5
[   17.756084]  [<ffffffff8174d931>] ? genl_bind+0x142/0x15e
[   17.756947]  [<ffffffff810b56db>] warn_slowpath_null+0x23/0x2c
[   17.757906]  [<ffffffff8174d931>] genl_bind+0x142/0x15e
[   17.758784]  [<ffffffff8174ab86>] netlink_bind+0x155/0x2ce
[   17.759710]  [<ffffffff8170e512>] SyS_bind+0xc1/0x117
[   17.760577]  [<ffffffff81769058>] ? _raw_spin_unlock+0x38/0x50
[   17.761554]  [<ffffffff8114553f>] ? context_tracking_user_exit+0xe2/0x101
[   17.762645]  [<ffffffff810eafbd>] ? trace_hardirqs_on+0x1b/0x24
[   17.763615]  [<ffffffff8176a2e7>] system_call_fastpath+0x12/0x17
[   17.764426] ---[ end trace f8ae22d84a926b42 ]---
[   17.764904] ------------[ cut here ]------------
[   17.765507] WARNING: CPU: 0 PID: 109 at net/netlink/genetlink.c:1011 gen=
l_bind+0x142/0x15e()
[   17.766541] CPU: 0 PID: 109 Comm: trinity-main Tainted: G        W      =
3.18.0-11169-gc380d9a #9
[   17.767470]  0000000000000009 ffff88000b44fdd8 ffffffff8175b593 ffff8800=
0b44fe18
[   17.768404]  ffffffff810b55aa 0000000000000006 ffffffff8174d931 ffffffff=
834a3400
[   17.769396]  0000000000000006 0000000000000000 0000000000000000 ffff8800=
0b44fe28
[   17.770222] Call Trace:
[   17.770497]  [<ffffffff8175b593>] dump_stack+0x2e/0x3e
[   17.771052]  [<ffffffff810b55aa>] warn_slowpath_common+0xb6/0xe5
[   17.771702]  [<ffffffff8174d931>] ? genl_bind+0x142/0x15e
[   17.772518]  [<ffffffff810b56db>] warn_slowpath_null+0x23/0x2c
[   17.773317]  [<ffffffff8174d931>] genl_bind+0x142/0x15e
[   17.773867]  [<ffffffff8174ab86>] netlink_bind+0x155/0x2ce
[   17.774435]  [<ffffffff8170e512>] SyS_bind+0xc1/0x117
[   17.774989]  [<ffffffff81769058>] ? _raw_spin_unlock+0x38/0x50
[   17.775618]  [<ffffffff8114553f>] ? context_tracking_user_exit+0xe2/0x101
[   17.776412]  [<ffffffff810eafbd>] ? trace_hardirqs_on+0x1b/0x24
[   17.777044]  [<ffffffff8176a2e7>] system_call_fastpath+0x12/0x17
[   17.777752] ---[ end trace f8ae22d84a926b43 ]---
[   17.778221] ------------[ cut here ]------------
[   17.778717] WARNING: CPU: 0 PID: 109 at net/netlink/genetlink.c:1011 gen=
l_bind+0x142/0x15e()
[   17.779838] CPU: 0 PID: 109 Comm: trinity-main Tainted: G        W      =
3.18.0-11169-gc380d9a #9
[   17.780813]  0000000000000009 ffff88000b44fdd8 ffffffff8175b593 ffff8800=
0b44fe18
[   17.781770]  ffffffff810b55aa 0000000000000007 ffffffff8174d931 ffffffff=
834a3400
[   17.782592]  0000000000000007 0000000000000000 0000000000000000 ffff8800=
0b44fe28
[   17.783443] Call Trace:
[   17.783715]  [<ffffffff8175b593>] dump_stack+0x2e/0x3e
[   17.784350]  [<ffffffff810b55aa>] warn_slowpath_common+0xb6/0xe5
[   17.784992]  [<ffffffff8174d931>] ? genl_bind+0x142/0x15e
[   17.785646]  [<ffffffff810b56db>] warn_slowpath_null+0x23/0x2c
[   17.786253]  [<ffffffff8174d931>] genl_bind+0x142/0x15e
[   17.786815]  [<ffffffff8174ab86>] netlink_bind+0x155/0x2ce
[   17.787407]  [<ffffffff8170e512>] SyS_bind+0xc1/0x117
[   17.788037]  [<ffffffff81769058>] ? _raw_spin_unlock+0x38/0x50
[   17.788649]  [<ffffffff8114553f>] ? context_tracking_user_exit+0xe2/0x101
[   17.789534]  [<ffffffff810eafbd>] ? trace_hardirqs_on+0x1b/0x24
[   17.790136]  [<ffffffff8176a2e7>] system_call_fastpath+0x12/0x17
[   17.790780] ---[ end trace f8ae22d84a926b44 ]---
[   17.791281] ------------[ cut here ]------------
[   17.791777] WARNING: CPU: 0 PID: 109 at net/netlink/genetlink.c:1011 gen=
l_bind+0x142/0x15e()
[   17.792876] CPU: 0 PID: 109 Comm: trinity-main Tainted: G        W      =
3.18.0-11169-gc380d9a #9
[   17.793856]  0000000000000009 ffff88000b44fdd8 ffffffff8175b593 ffff8800=
0b44fe18
[   17.794692]  ffffffff810b55aa 0000000000000008 ffffffff8174d931 ffffffff=
834a3400
[   17.795544]  0000000000000008 0000000000000000 0000000000000000 ffff8800=
0b44fe28
[   17.796494] Call Trace:
[   17.796741]  [<ffffffff8175b593>] dump_stack+0x2e/0x3e
[   17.797328]  [<ffffffff810b55aa>] warn_slowpath_common+0xb6/0xe5
[   17.797939]  [<ffffffff8174d931>] ? genl_bind+0x142/0x15e
[   17.798527]  [<ffffffff810b56db>] warn_slowpath_null+0x23/0x2c
[   17.799208]  [<ffffffff8174d931>] genl_bind+0x142/0x15e
[   17.799769]  [<ffffffff8174ab86>] netlink_bind+0x155/0x2ce
[   17.800441]  [<ffffffff8170e512>] SyS_bind+0xc1/0x117
[   17.800920]  [<ffffffff81769058>] ? _raw_spin_unlock+0x38/0x50
[   17.801611]  [<ffffffff8114553f>] ? context_tracking_user_exit+0xe2/0x101
[   17.802302]  [<ffffffff810eafbd>] ? trace_hardirqs_on+0x1b/0x24
[   17.802937]  [<ffffffff8176a2e7>] system_call_fastpath+0x12/0x17
[   17.803579] ---[ end trace f8ae22d84a926b45 ]---
[   17.804157] ------------[ cut here ]------------
[   17.804637] WARNING: CPU: 0 PID: 109 at net/netlink/genetlink.c:1011 gen=
l_bind+0x142/0x15e()
[   17.805728] CPU: 0 PID: 109 Comm: trinity-main Tainted: G        W      =
3.18.0-11169-gc380d9a #9
[   17.806634]  0000000000000009 ffff88000b44fdd8 ffffffff8175b593 ffff8800=
0b44fe18
[   17.807483]  ffffffff810b55aa 0000000000000009 ffffffff8174d931 ffffffff=
834a3400
[   17.808415]  0000000000000009 0000000000000000 0000000000000000 ffff8800=
0b44fe28
[   17.809278] Call Trace:
[   17.809550]  [<ffffffff8175b593>] dump_stack+0x2e/0x3e
[   17.810060]  [<ffffffff810b55aa>] warn_slowpath_common+0xb6/0xe5
[   17.810703]  [<ffffffff8174d931>] ? genl_bind+0x142/0x15e
[   17.811282]  [<ffffffff810b56db>] warn_slowpath_null+0x23/0x2c
[   17.811926]  [<ffffffff8174d931>] genl_bind+0x142/0x15e
[   17.812547]  [<ffffffff8174ab86>] netlink_bind+0x155/0x2ce
[   17.813078]  [<ffffffff8170e512>] SyS_bind+0xc1/0x117
[   17.813622]  [<ffffffff81769058>] ? _raw_spin_unlock+0x38/0x50
[   17.814219]  [<ffffffff8114553f>] ? context_tracking_user_exit+0xe2/0x101
[   17.814945]  [<ffffffff810eafbd>] ? trace_hardirqs_on+0x1b/0x24
[   17.815583]  [<ffffffff8176a2e7>] system_call_fastpath+0x12/0x17
[   17.816317] ---[ end trace f8ae22d84a926b46 ]---
[   17.817008] ------------[ cut here ]------------
[   17.817515] WARNING: CPU: 0 PID: 109 at net/netlink/genetlink.c:1011 gen=
l_bind+0x142/0x15e()
[   17.818523] CPU: 0 PID: 109 Comm: trinity-main Tainted: G        W      =
3.18.0-11169-gc380d9a #9
[   17.819499]  0000000000000009 ffff88000b44fdd8 ffffffff8175b593 ffff8800=
0b44fe18
[   17.820439]  ffffffff810b55aa 000000000000000a ffffffff8174d931 ffffffff=
834a3400
[   17.821229]  000000000000000a 0000000000000000 0000000000000000 ffff8800=
0b44fe28
[   17.822046] Call Trace:
[   17.822322]  [<ffffffff8175b593>] dump_stack+0x2e/0x3e
[   17.822868]  [<ffffffff810b55aa>] warn_slowpath_common+0xb6/0xe5
[   17.823507]  [<ffffffff8174d931>] ? genl_bind+0x142/0x15e
[   17.824161]  [<ffffffff810b56db>] warn_slowpath_null+0x23/0x2c
[   17.824758]  [<ffffffff8174d931>] genl_bind+0x142/0x15e
[   17.825288]  [<ffffffff8174ab86>] netlink_bind+0x155/0x2ce
[   17.825862]  [<ffffffff8170e512>] SyS_bind+0xc1/0x117
[   17.826392]  [<ffffffff81769058>] ? _raw_spin_unlock+0x38/0x50
[   17.827008]  [<ffffffff8114553f>] ? context_tracking_user_exit+0xe2/0x101
[   17.827735]  [<ffffffff810eafbd>] ? trace_hardirqs_on+0x1b/0x24
[   17.828452]  [<ffffffff8176a2e7>] system_call_fastpath+0x12/0x17
[   17.829073] ---[ end trace f8ae22d84a926b47 ]---
[   17.829616] ------------[ cut here ]------------
[   17.830086] WARNING: CPU: 0 PID: 109 at net/netlink/genetlink.c:1011 gen=
l_bind+0x142/0x15e()
[   17.831155] CPU: 0 PID: 109 Comm: trinity-main Tainted: G        W      =
3.18.0-11169-gc380d9a #9
[   17.832171]  0000000000000009 ffff88000b44fdd8 ffffffff8175b593 ffff8800=
0b44fe18
[   17.832953]  ffffffff810b55aa 000000000000000b ffffffff8174d931 ffffffff=
834a3400
[   17.833799]  000000000000000b 0000000000000000 0000000000000000 ffff8800=
0b44fe28
[   17.834619] Call Trace:
[   17.834889]  [<ffffffff8175b593>] dump_stack+0x2e/0x3e
[   17.835443]  [<ffffffff810b55aa>] warn_slowpath_common+0xb6/0xe5
[   17.836160]  [<ffffffff8174d931>] ? genl_bind+0x142/0x15e
[   17.836716]  [<ffffffff810b56db>] warn_slowpath_null+0x23/0x2c
[   17.837309]  [<ffffffff8174d931>] genl_bind+0x142/0x15e
[   17.837858]  [<ffffffff8174ab86>] netlink_bind+0x155/0x2ce
[   17.838424]  [<ffffffff8170e512>] SyS_bind+0xc1/0x117
[   17.839020]  [<ffffffff81769058>] ? _raw_spin_unlock+0x38/0x50
[   17.839623]  [<ffffffff8114553f>] ? context_tracking_user_exit+0xe2/0x101
[   17.840436]  [<ffffffff810eafbd>] ? trace_hardirqs_on+0x1b/0x24
[   17.841008]  [<ffffffff8176a2e7>] system_call_fastpath+0x12/0x17
[   17.841652] ---[ end trace f8ae22d84a926b48 ]---
[   17.842146] ------------[ cut here ]------------
[   17.842651] WARNING: CPU: 0 PID: 109 at net/netlink/genetlink.c:1011 gen=
l_bind+0x142/0x15e()
[   17.843701] CPU: 0 PID: 109 Comm: trinity-main Tainted: G        W      =
3.18.0-11169-gc380d9a #9
[   17.844688]  0000000000000009 ffff88000b44fdd8 ffffffff8175b593 ffff8800=
0b44fe18
[   17.845521]  ffffffff810b55aa 000000000000000c ffffffff8174d931 ffffffff=
834a3400
[   17.846349]  000000000000000c 0000000000000000 0000000000000000 ffff8800=
0b44fe28
[   17.847195] Call Trace:
[   17.847471]  [<ffffffff8175b593>] dump_stack+0x2e/0x3e
[   17.848104]  [<ffffffff810b55aa>] warn_slowpath_common+0xb6/0xe5
[   17.848717]  [<ffffffff8174d931>] ? genl_bind+0x142/0x15e
[   17.849330]  [<ffffffff810b56db>] warn_slowpath_null+0x23/0x2c
[   17.849931]  [<ffffffff8174d931>] genl_bind+0x142/0x15e
[   17.850497]  [<ffffffff8174ab86>] netlink_bind+0x155/0x2ce
[   17.851083]  [<ffffffff8170e512>] SyS_bind+0xc1/0x117
[   17.851628]  [<ffffffff81769058>] ? _raw_spin_unlock+0x38/0x50
[   17.852335]  [<ffffffff8114553f>] ? context_tracking_user_exit+0xe2/0x101
[   17.853000]  [<ffffffff810eafbd>] ? trace_hardirqs_on+0x1b/0x24
[   17.853645]  [<ffffffff8176a2e7>] system_call_fastpath+0x12/0x17
[   17.854265] ---[ end trace f8ae22d84a926b49 ]---
[   17.854806] ------------[ cut here ]------------
[   17.855309] WARNING: CPU: 0 PID: 109 at net/netlink/genetlink.c:1011 gen=
l_bind+0x142/0x15e()
[   17.856448] CPU: 0 PID: 109 Comm: trinity-main Tainted: G        W      =
3.18.0-11169-gc380d9a #9
[   17.857323]  0000000000000009 ffff88000b44fdd8 ffffffff8175b593 ffff8800=
0b44fe18
[   17.858193]  ffffffff810b55aa 000000000000000d ffffffff8174d931 ffffffff=
834a3400
[   17.859693]  000000000000000d 0000000000000000 0000000000000000 ffff8800=
0b44fe28
[   17.861019] Call Trace:
[   17.861437]  [<ffffffff8175b593>] dump_stack+0x2e/0x3e
[   17.862288]  [<ffffffff810b55aa>] warn_slowpath_common+0xb6/0xe5
[   17.863283]  [<ffffffff8174d931>] ? genl_bind+0x142/0x15e
[   17.864128]  [<ffffffff810b56db>] warn_slowpath_null+0x23/0x2c
[   17.864727]  [<ffffffff8174d931>] genl_bind+0x142/0x15e
[   17.865258]  [<ffffffff8174ab86>] netlink_bind+0x155/0x2ce
[   17.865856]  [<ffffffff8170e512>] SyS_bind+0xc1/0x117
[   17.866424]  [<ffffffff81769058>] ? _raw_spin_unlock+0x38/0x50
[   17.867037]  [<ffffffff8114553f>] ? context_tracking_user_exit+0xe2/0x101
[   17.867903]  [<ffffffff810eafbd>] ? trace_hardirqs_on+0x1b/0x24
[   17.868652]  [<ffffffff8176a2e7>] system_call_fastpath+0x12/0x17
[   17.869575] ---[ end trace f8ae22d84a926b4a ]---
[   17.870402] ------------[ cut here ]------------
[   17.871298] WARNING: CPU: 0 PID: 109 at net/netlink/genetlink.c:1011 gen=
l_bind+0x142/0x15e()
[   17.873154] CPU: 0 PID: 109 Comm: trinity-main Tainted: G        W      =
3.18.0-11169-gc380d9a #9
[   17.874882]  0000000000000009 ffff88000b44fdd8 ffffffff8175b593 ffff8800=
0b44fe18
[   17.876170]  ffffffff810b55aa 000000000000000e ffffffff8174d931 ffffffff=
834a3400
[   17.877176]  000000000000000e 0000000000000000 0000000000000000 ffff8800=
0b44fe28
[   17.878483] Call Trace:
[   17.878881]  [<ffffffff8175b593>] dump_stack+0x2e/0x3e
[   17.879699]  [<ffffffff810b55aa>] warn_slowpath_common+0xb6/0xe5
[   17.880732]  [<ffffffff8174d931>] ? genl_bind+0x142/0x15e
[   17.881627]  [<ffffffff810b56db>] warn_slowpath_null+0x23/0x2c
[   17.882545]  [<ffffffff8174d931>] genl_bind+0x142/0x15e
[   17.883372]  [<ffffffff8174ab86>] netlink_bind+0x155/0x2ce
[   17.884263]  [<ffffffff8170e512>] SyS_bind+0xc1/0x117
[   17.885069]  [<ffffffff81769058>] ? _raw_spin_unlock+0x38/0x50
[   17.885996]  [<ffffffff8114553f>] ? context_tracking_user_exit+0xe2/0x101
[   17.887068]  [<ffffffff810eafbd>] ? trace_hardirqs_on+0x1b/0x24
[   17.888042]  [<ffffffff8176a2e7>] system_call_fastpath+0x12/0x17
[   17.888994] ---[ end trace f8ae22d84a926b4b ]---
[   17.889784] ------------[ cut here ]------------
[   17.890527] WARNING: CPU: 0 PID: 109 at net/netlink/genetlink.c:1011 gen=
l_bind+0x142/0x15e()
[   17.892324] CPU: 0 PID: 109 Comm: trinity-main Tainted: G        W      =
3.18.0-11169-gc380d9a #9
[   17.893715]  0000000000000009 ffff88000b44fdd8 ffffffff8175b593 ffff8800=
0b44fe18
[   17.895053]  ffffffff810b55aa 000000000000000f ffffffff8174d931 ffffffff=
834a3400
[   17.896499]  000000000000000f 0000000000000000 0000000000000000 ffff8800=
0b44fe28
[   17.898043] Call Trace:
[   17.898436]  [<ffffffff8175b593>] dump_stack+0x2e/0x3e
[   17.899279]  [<ffffffff810b55aa>] warn_slowpath_common+0xb6/0xe5
[   17.900271]  [<ffffffff8174d931>] ? genl_bind+0x142/0x15e
[   17.901132]  [<ffffffff810b56db>] warn_slowpath_null+0x23/0x2c
[   17.901977]  [<ffffffff8174d931>] genl_bind+0x142/0x15e
[   17.902704]  [<ffffffff8174ab86>] netlink_bind+0x155/0x2ce
[   17.903388]  [<ffffffff8170e512>] SyS_bind+0xc1/0x117
[   17.904224]  [<ffffffff81769058>] ? _raw_spin_unlock+0x38/0x50
[   17.905183]  [<ffffffff8114553f>] ? context_tracking_user_exit+0xe2/0x101
[   17.906261]  [<ffffffff810eafbd>] ? trace_hardirqs_on+0x1b/0x24
[   17.907193]  [<ffffffff8176a2e7>] system_call_fastpath+0x12/0x17
[   17.908173] ---[ end trace f8ae22d84a926b4c ]---
[   17.917625] sock: process `trinity-main' is using obsolete setsockopt SO=
_BSDCOMPAT
[   17.921756] ------------[ cut here ]------------
[   17.922514] WARNING: CPU: 0 PID: 109 at net/netlink/genetlink.c:1011 gen=
l_bind+0x142/0x15e()
[   17.924101] CPU: 0 PID: 109 Comm: trinity-main Tainted: G        W      =
3.18.0-11169-gc380d9a #9
[   17.925487]  0000000000000009 ffff88000b44fdd8 ffffffff8175b593 ffff8800=
0b44fe18
[   17.926737]  ffffffff810b55aa 0000000000000004 ffffffff8174d931 ffffffff=
834a3400
[   17.927989]  0000000000000004 0000000000000000 0000000000000000 ffff8800=
0b44fe28
[   17.929143] Call Trace:
[   17.929429]  [<ffffffff8175b593>] dump_stack+0x2e/0x3e
[   17.930002]  [<ffffffff810b55aa>] warn_slowpath_common+0xb6/0xe5
[   17.930919]  [<ffffffff8174d931>] ? genl_bind+0x142/0x15e
[   17.931783]  [<ffffffff810b56db>] warn_slowpath_null+0x23/0x2c
[   17.932734]  [<ffffffff8174d931>] genl_bind+0x142/0x15e
[   17.933573]  [<ffffffff8174ab86>] netlink_bind+0x155/0x2ce
[   17.934448]  [<ffffffff8170e512>] SyS_bind+0xc1/0x117
[   17.935256]  [<ffffffff81769058>] ? _raw_spin_unlock+0x38/0x50
[   17.936204]  [<ffffffff8114553f>] ? context_tracking_user_exit+0xe2/0x101
[   17.937281]  [<ffffffff810eafbd>] ? trace_hardirqs_on+0x1b/0x24
[   17.938219]  [<ffffffff8176a2e7>] system_call_fastpath+0x12/0x17
[   17.939175] ---[ end trace f8ae22d84a926b4d ]---
[   17.940120] ------------[ cut here ]------------
[   17.941010] WARNING: CPU: 0 PID: 109 at net/netlink/genetlink.c:1011 gen=
l_bind+0x142/0x15e()
[   17.942610] CPU: 0 PID: 109 Comm: trinity-main Tainted: G        W      =
3.18.0-11169-gc380d9a #9
[   17.943983]  0000000000000009 ffff88000b44fdd8 ffffffff8175b593 ffff8800=
0b44fe18
[   17.945268]  ffffffff810b55aa 0000000000000005 ffffffff8174d931 ffffffff=
834a3400
[   17.946517]  0000000000000005 0000000000000000 0000000000000000 ffff8800=
0b44fe28
[   17.947762] Call Trace:
[   17.948179]  [<ffffffff8175b593>] dump_stack+0x2e/0x3e
[   17.948963]  [<ffffffff810b55aa>] warn_slowpath_common+0xb6/0xe5
[   17.949600]  [<ffffffff8174d931>] ? genl_bind+0x142/0x15e
[   17.950204]  [<ffffffff810b56db>] warn_slowpath_null+0x23/0x2c
[   17.950866]  [<ffffffff8174d931>] genl_bind+0x142/0x15e
[   17.951433]  [<ffffffff8174ab86>] netlink_bind+0x155/0x2ce
[   17.952048]  [<ffffffff8170e512>] SyS_bind+0xc1/0x117
[   17.952609]  [<ffffffff81769058>] ? _raw_spin_unlock+0x38/0x50
[   17.953236]  [<ffffffff8114553f>] ? context_tracking_user_exit+0xe2/0x101
[   17.953996]  [<ffffffff810eafbd>] ? trace_hardirqs_on+0x1b/0x24
[   17.954651]  [<ffffffff8176a2e7>] system_call_fastpath+0x12/0x17
[   17.955318] ---[ end trace f8ae22d84a926b4e ]---
[   17.955872] ------------[ cut here ]------------
[   17.956416] WARNING: CPU: 0 PID: 109 at net/netlink/genetlink.c:1011 gen=
l_bind+0x142/0x15e()
[   17.957488] CPU: 0 PID: 109 Comm: trinity-main Tainted: G        W      =
3.18.0-11169-gc380d9a #9
[   17.958443]  0000000000000009 ffff88000b44fdd8 ffffffff8175b593 ffff8800=
0b44fe18
[   17.959373]  ffffffff810b55aa 0000000000000007 ffffffff8174d931 ffffffff=
834a3400
[   17.960294]  0000000000000007 0000000000000000 0000000000000000 ffff8800=
0b44fe28
[   17.961139] Call Trace:
[   17.961400]  [<ffffffff8175b593>] dump_stack+0x2e/0x3e
[   17.961964]  [<ffffffff810b55aa>] warn_slowpath_common+0xb6/0xe5
[   17.962621]  [<ffffffff8174d931>] ? genl_bind+0x142/0x15e
[   17.963166]  [<ffffffff810b56db>] warn_slowpath_null+0x23/0x2c
[   17.963801]  [<ffffffff8174d931>] genl_bind+0x142/0x15e
[   17.964387]  [<ffffffff8174ab86>] netlink_bind+0x155/0x2ce
[   17.964969]  [<ffffffff8170e512>] SyS_bind+0xc1/0x117
[   17.965499]  [<ffffffff81769058>] ? _raw_spin_unlock+0x38/0x50
[   17.966137]  [<ffffffff8114553f>] ? context_tracking_user_exit+0xe2/0x101
[   17.967061]  [<ffffffff810eafbd>] ? trace_hardirqs_on+0x1b/0x24
[   17.967741]  [<ffffffff8176a2e7>] system_call_fastpath+0x12/0x17
[   17.968431] ---[ end trace f8ae22d84a926b4f ]---
[   17.969026] ------------[ cut here ]------------
[   17.969513] WARNING: CPU: 0 PID: 109 at net/netlink/genetlink.c:1011 gen=
l_bind+0x142/0x15e()
[   17.970568] CPU: 0 PID: 109 Comm: trinity-main Tainted: G        W      =
3.18.0-11169-gc380d9a #9
[   17.971504]  0000000000000009 ffff88000b44fdd8 ffffffff8175b593 ffff8800=
0b44fe18
[   17.972711]  ffffffff810b55aa 000000000000000a ffffffff8174d931 ffffffff=
834a3400
[   17.973914]  000000000000000a 0000000000000000 0000000000000000 ffff8800=
0b44fe28
[   17.975173] Call Trace:
[   17.975570]  [<ffffffff8175b593>] dump_stack+0x2e/0x3e
[   17.976230]  [<ffffffff810b55aa>] warn_slowpath_common+0xb6/0xe5
[   17.977005]  [<ffffffff8174d931>] ? genl_bind+0x142/0x15e
[   17.977585]  [<ffffffff810b56db>] warn_slowpath_null+0x23/0x2c
[   17.978238]  [<ffffffff8174d931>] genl_bind+0x142/0x15e
[   17.978913]  [<ffffffff8174ab86>] netlink_bind+0x155/0x2ce
[   17.979496]  [<ffffffff8170e512>] SyS_bind+0xc1/0x117
[   17.980085]  [<ffffffff81769058>] ? _raw_spin_unlock+0x38/0x50
[   17.980960]  [<ffffffff8114553f>] ? context_tracking_user_exit+0xe2/0x101
[   17.982004]  [<ffffffff810eafbd>] ? trace_hardirqs_on+0x1b/0x24
[   17.982779]  [<ffffffff8176a2e7>] system_call_fastpath+0x12/0x17
[   17.983422] ---[ end trace f8ae22d84a926b50 ]---
[   17.983987] ------------[ cut here ]------------
[   17.984692] WARNING: CPU: 0 PID: 109 at net/netlink/genetlink.c:1011 gen=
l_bind+0x142/0x15e()
[   17.986293] CPU: 0 PID: 109 Comm: trinity-main Tainted: G        W      =
3.18.0-11169-gc380d9a #9
[   17.987730]  0000000000000009 ffff88000b44fdd8 ffffffff8175b593 ffff8800=
0b44fe18
[   17.988803]  ffffffff810b55aa 000000000000000c ffffffff8174d931 ffffffff=
834a3400
[   17.989708]  000000000000000c 0000000000000000 0000000000000000 ffff8800=
0b44fe28
[   17.990514] Call Trace:
[   17.990782]  [<ffffffff8175b593>] dump_stack+0x2e/0x3e
[   17.991268]  [<ffffffff810b55aa>] warn_slowpath_common+0xb6/0xe5
[   17.992044]  [<ffffffff8174d931>] ? genl_bind+0x142/0x15e
[   17.992903]  [<ffffffff810b56db>] warn_slowpath_null+0x23/0x2c
[   17.993822]  [<ffffffff8174d931>] genl_bind+0x142/0x15e
[   17.994829]  [<ffffffff8174ab86>] netlink_bind+0x155/0x2ce
[   17.995614]  [<ffffffff8170e512>] SyS_bind+0xc1/0x117
[   17.996504]  [<ffffffff81769058>] ? _raw_spin_unlock+0x38/0x50
[   17.997190]  [<ffffffff8114553f>] ? context_tracking_user_exit+0xe2/0x101
[   17.997907]  [<ffffffff810eafbd>] ? trace_hardirqs_on+0x1b/0x24
[   17.998777]  [<ffffffff8176a2e7>] system_call_fastpath+0x12/0x17
[   17.999771] ---[ end trace f8ae22d84a926b51 ]---
[   18.023483] ------------[ cut here ]------------
[   18.024452] WARNING: CPU: 0 PID: 109 at net/netlink/genetlink.c:1011 gen=
l_bind+0x142/0x15e()
[   18.025978] CPU: 0 PID: 109 Comm: trinity-main Tainted: G        W      =
3.18.0-11169-gc380d9a #9
[   18.027105]  0000000000000009 ffff88000b44fdd8 ffffffff8175b593 ffff8800=
0b44fe18
[   18.027974]  ffffffff810b55aa 0000000000000004 ffffffff8174d931 ffffffff=
834a3400
[   18.029000]  0000000000000004 0000000000000000 0000000000000000 ffff8800=
0b44fe28
[   18.030117] Call Trace:
[   18.030510]  [<ffffffff8175b593>] dump_stack+0x2e/0x3e
[   18.031273]  [<ffffffff810b55aa>] warn_slowpath_common+0xb6/0xe5
[   18.032424]  [<ffffffff8174d931>] ? genl_bind+0x142/0x15e
[   18.033458]  [<ffffffff810b56db>] warn_slowpath_null+0x23/0x2c
[   18.034287]  [<ffffffff8174d931>] genl_bind+0x142/0x15e
[   18.035226]  [<ffffffff8174ab86>] netlink_bind+0x155/0x2ce
[   18.035926]  [<ffffffff8170e512>] SyS_bind+0xc1/0x117
[   18.036522]  [<ffffffff81769058>] ? _raw_spin_unlock+0x38/0x50
[   18.037378]  [<ffffffff8114553f>] ? context_tracking_user_exit+0xe2/0x101
[   18.038560]  [<ffffffff810eafbd>] ? trace_hardirqs_on+0x1b/0x24
[   18.039462]  [<ffffffff8176a2e7>] system_call_fastpath+0x12/0x17
[   18.040342] ---[ end trace f8ae22d84a926b52 ]---
[   18.041172] ------------[ cut here ]------------
[   18.041831] WARNING: CPU: 0 PID: 109 at net/netlink/genetlink.c:1011 gen=
l_bind+0x142/0x15e()
[   18.043254] CPU: 0 PID: 109 Comm: trinity-main Tainted: G        W      =
3.18.0-11169-gc380d9a #9
[   18.044641]  0000000000000009 ffff88000b44fdd8 ffffffff8175b593 ffff8800=
0b44fe18
[   18.045886]  ffffffff810b55aa 0000000000000005 ffffffff8174d931 ffffffff=
834a3400
[   18.047267]  0000000000000005 0000000000000000 0000000000000000 ffff8800=
0b44fe28
[   18.048708] Call Trace:
[   18.049182]  [<ffffffff8175b593>] dump_stack+0x2e/0x3e
[   18.050162]  [<ffffffff810b55aa>] warn_slowpath_common+0xb6/0xe5
[   18.051324]  [<ffffffff8174d931>] ? genl_bind+0x142/0x15e
[   18.052342]  [<ffffffff810b56db>] warn_slowpath_null+0x23/0x2c
[   18.053388]  [<ffffffff8174d931>] genl_bind+0x142/0x15e
[   18.054329]  [<ffffffff8174ab86>] netlink_bind+0x155/0x2ce
[   18.055339]  [<ffffffff8170e512>] SyS_bind+0xc1/0x117
[   18.056333]  [<ffffffff81769058>] ? _raw_spin_unlock+0x38/0x50
[   18.057459]  [<ffffffff8114553f>] ? context_tracking_user_exit+0xe2/0x101
[   18.058698]  [<ffffffff810eafbd>] ? trace_hardirqs_on+0x1b/0x24
[   18.059764]  [<ffffffff8176a2e7>] system_call_fastpath+0x12/0x17
[   18.060904] ---[ end trace f8ae22d84a926b53 ]---
[   18.061865] ------------[ cut here ]------------
[   18.062742] WARNING: CPU: 0 PID: 109 at net/netlink/genetlink.c:1011 gen=
l_bind+0x142/0x15e()
[   18.064535] CPU: 0 PID: 109 Comm: trinity-main Tainted: G        W      =
3.18.0-11169-gc380d9a #9
[   18.066115]  0000000000000009 ffff88000b44fdd8 ffffffff8175b593 ffff8800=
0b44fe18
[   18.067606]  ffffffff810b55aa 0000000000000006 ffffffff8174d931 ffffffff=
834a3400
[   18.069068]  0000000000000006 0000000000000000 0000000000000000 ffff8800=
0b44fe28
[   18.070507] Call Trace:
[   18.070966]  [<ffffffff8175b593>] dump_stack+0x2e/0x3e
[   18.071940]  [<ffffffff810b55aa>] warn_slowpath_common+0xb6/0xe5
[   18.073068]  [<ffffffff8174d931>] ? genl_bind+0x142/0x15e
[   18.074040]  [<ffffffff810b56db>] warn_slowpath_null+0x23/0x2c
[   18.075077]  [<ffffffff8174d931>] genl_bind+0x142/0x15e
[   18.076060]  [<ffffffff8174ab86>] netlink_bind+0x155/0x2ce
[   18.077106]  [<ffffffff8170e512>] SyS_bind+0xc1/0x117
[   18.078060]  [<ffffffff81769058>] ? _raw_spin_unlock+0x38/0x50
[   18.079095]  [<ffffffff8114553f>] ? context_tracking_user_exit+0xe2/0x101
[   18.080401]  [<ffffffff810eafbd>] ? trace_hardirqs_on+0x1b/0x24
[   18.081427]  [<ffffffff8176a2e7>] system_call_fastpath+0x12/0x17
[   18.082504] ---[ end trace f8ae22d84a926b54 ]---
[   18.083440] ------------[ cut here ]------------
[   18.084358] WARNING: CPU: 0 PID: 109 at net/netlink/genetlink.c:1011 gen=
l_bind+0x142/0x15e()
[   18.086147] CPU: 0 PID: 109 Comm: trinity-main Tainted: G        W      =
3.18.0-11169-gc380d9a #9
[   18.087685]  0000000000000009 ffff88000b44fdd8 ffffffff8175b593 ffff8800=
0b44fe18
[   18.089267]  ffffffff810b55aa 000000000000000a ffffffff8174d931 ffffffff=
834a3400
[   18.090927]  000000000000000a 0000000000000000 0000000000000000 ffff8800=
0b44fe28
[   18.092493] Call Trace:
[   18.092992]  [<ffffffff8175b593>] dump_stack+0x2e/0x3e
[   18.094039]  [<ffffffff810b55aa>] warn_slowpath_common+0xb6/0xe5
[   18.095311]  [<ffffffff8174d931>] ? genl_bind+0x142/0x15e
[   18.096425]  [<ffffffff810b56db>] warn_slowpath_null+0x23/0x2c
[   18.097560]  [<ffffffff8174d931>] genl_bind+0x142/0x15e
[   18.098507]  [<ffffffff8174ab86>] netlink_bind+0x155/0x2ce
[   18.099515]  [<ffffffff8170e512>] SyS_bind+0xc1/0x117
[   18.100450]  [<ffffffff81769058>] ? _raw_spin_unlock+0x38/0x50
[   18.101551]  [<ffffffff8114553f>] ? context_tracking_user_exit+0xe2/0x101
[   18.102823]  [<ffffffff810eafbd>] ? trace_hardirqs_on+0x1b/0x24
[   18.103894]  [<ffffffff8176a2e7>] system_call_fastpath+0x12/0x17
[   18.105044] ---[ end trace f8ae22d84a926b55 ]---
[   18.105987] ------------[ cut here ]------------
[   18.106880] WARNING: CPU: 0 PID: 109 at net/netlink/genetlink.c:1011 gen=
l_bind+0x142/0x15e()
[   18.108774] CPU: 0 PID: 109 Comm: trinity-main Tainted: G        W      =
3.18.0-11169-gc380d9a #9
[   18.110409]  0000000000000009 ffff88000b44fdd8 ffffffff8175b593 ffff8800=
0b44fe18
[   18.111956]  ffffffff810b55aa 000000000000000b ffffffff8174d931 ffffffff=
834a3400
[   18.113503]  000000000000000b 0000000000000000 0000000000000000 ffff8800=
0b44fe28
[   18.115102] Call Trace:
[   18.115546]  [<ffffffff8175b593>] dump_stack+0x2e/0x3e
[   18.116513]  [<ffffffff810b55aa>] warn_slowpath_common+0xb6/0xe5
[   18.117648]  [<ffffffff8174d931>] ? genl_bind+0x142/0x15e
[   18.118696]  [<ffffffff810b56db>] warn_slowpath_null+0x23/0x2c
[   18.119870]  [<ffffffff8174d931>] genl_bind+0x142/0x15e
[   18.120942]  [<ffffffff8174ab86>] netlink_bind+0x155/0x2ce
[   18.122006]  [<ffffffff8170e512>] SyS_bind+0xc1/0x117
[   18.122975]  [<ffffffff81769058>] ? _raw_spin_unlock+0x38/0x50
[   18.124084]  [<ffffffff8114553f>] ? context_tracking_user_exit+0xe2/0x101
[   18.125432]  [<ffffffff810eafbd>] ? trace_hardirqs_on+0x1b/0x24
[   18.126629]  [<ffffffff8176a2e7>] system_call_fastpath+0x12/0x17
[   18.127798] ---[ end trace f8ae22d84a926b56 ]---
[   18.128752] ------------[ cut here ]------------
[   18.129656] WARNING: CPU: 0 PID: 109 at net/netlink/genetlink.c:1011 gen=
l_bind+0x142/0x15e()
[   18.131557] CPU: 0 PID: 109 Comm: trinity-main Tainted: G        W      =
3.18.0-11169-gc380d9a #9
[   18.132941]  0000000000000009 ffff88000b44fdd8 ffffffff8175b593 ffff8800=
0b44fe18
[   18.134301]  ffffffff810b55aa 000000000000000c ffffffff8174d931 ffffffff=
834a3400
[   18.135717]  000000000000000c 0000000000000000 0000000000000000 ffff8800=
0b44fe28
[   18.137168] Call Trace:
[   18.137585]  [<ffffffff8175b593>] dump_stack+0x2e/0x3e
[   18.138501]  [<ffffffff810b55aa>] warn_slowpath_common+0xb6/0xe5
[   18.139583]  [<ffffffff8174d931>] ? genl_bind+0x142/0x15e
[   18.140569]  [<ffffffff810b56db>] warn_slowpath_null+0x23/0x2c
[   18.141581]  [<ffffffff8174d931>] genl_bind+0x142/0x15e
[   18.142350]  [<ffffffff8174ab86>] netlink_bind+0x155/0x2ce
[   18.143105]  [<ffffffff8170e512>] SyS_bind+0xc1/0x117
[   18.143795]  [<ffffffff81769058>] ? _raw_spin_unlock+0x38/0x50
[   18.144619]  [<ffffffff8114553f>] ? context_tracking_user_exit+0xe2/0x101
[   18.145554]  [<ffffffff810eafbd>] ? trace_hardirqs_on+0x1b/0x24
[   18.146374]  [<ffffffff8176a2e7>] system_call_fastpath+0x12/0x17
[   18.147211] ---[ end trace f8ae22d84a926b57 ]---
[   18.147898] ------------[ cut here ]------------
[   18.148612] WARNING: CPU: 0 PID: 109 at net/netlink/genetlink.c:1011 gen=
l_bind+0x142/0x15e()
[   18.150247] CPU: 0 PID: 109 Comm: trinity-main Tainted: G        W      =
3.18.0-11169-gc380d9a #9
[   18.151697]  0000000000000009 ffff88000b44fdd8 ffffffff8175b593 ffff8800=
0b44fe18
[   18.153036]  ffffffff810b55aa 000000000000000e ffffffff8174d931 ffffffff=
834a3400
[   18.154330]  000000000000000e 0000000000000000 0000000000000000 ffff8800=
0b44fe28
[   18.155656] Call Trace:
[   18.156098]  [<ffffffff8175b593>] dump_stack+0x2e/0x3e
[   18.156988]  [<ffffffff810b55aa>] warn_slowpath_common+0xb6/0xe5
[   18.157945]  [<ffffffff8174d931>] ? genl_bind+0x142/0x15e
[   18.158860]  [<ffffffff810b56db>] warn_slowpath_null+0x23/0x2c
[   18.159847]  [<ffffffff8174d931>] genl_bind+0x142/0x15e
[   18.160725]  [<ffffffff8174ab86>] netlink_bind+0x155/0x2ce
[   18.161618]  [<ffffffff8170e512>] SyS_bind+0xc1/0x117
[   18.162469]  [<ffffffff81769058>] ? _raw_spin_unlock+0x38/0x50
[   18.163446]  [<ffffffff8114553f>] ? context_tracking_user_exit+0xe2/0x101
[   18.164586]  [<ffffffff810eafbd>] ? trace_hardirqs_on+0x1b/0x24
[   18.165551]  [<ffffffff8176a2e7>] system_call_fastpath+0x12/0x17
[   18.166526] ---[ end trace f8ae22d84a926b58 ]---
[   18.209366] ------------[ cut here ]------------
[   18.210210] WARNING: CPU: 0 PID: 109 at net/netlink/genetlink.c:1011 gen=
l_bind+0x142/0x15e()
[   18.211982] CPU: 0 PID: 109 Comm: trinity-main Tainted: G        W      =
3.18.0-11169-gc380d9a #9
[   18.213530]  0000000000000009 ffff88000b44fdd8 ffffffff8175b593 ffff8800=
0b44fe18
[   18.214937]  ffffffff810b55aa 0000000000000000 ffffffff8174d931 ffffffff=
834a3400
[   18.216369]  0000000000000000 0000000000000000 0000000000000000 ffff8800=
0b44fe28
[   18.217766] Call Trace:
[   18.218224]  [<ffffffff8175b593>] dump_stack+0x2e/0x3e
[   18.219133]  [<ffffffff810b55aa>] warn_slowpath_common+0xb6/0xe5
[   18.220214]  [<ffffffff8174d931>] ? genl_bind+0x142/0x15e
[   18.221166]  [<ffffffff810b56db>] warn_slowpath_null+0x23/0x2c
[   18.222206]  [<ffffffff8174d931>] genl_bind+0x142/0x15e
[   18.223138]  [<ffffffff8174ab86>] netlink_bind+0x155/0x2ce
[   18.224145]  [<ffffffff8170e512>] SyS_bind+0xc1/0x117
[   18.225056]  [<ffffffff81769058>] ? _raw_spin_unlock+0x38/0x50
[   18.226061]  [<ffffffff8114553f>] ? context_tracking_user_exit+0xe2/0x101
[   18.227287]  [<ffffffff810eafbd>] ? trace_hardirqs_on+0x1b/0x24
[   18.228353]  [<ffffffff8176a2e7>] system_call_fastpath+0x12/0x17
[   18.229425] ---[ end trace f8ae22d84a926b59 ]---
[   18.230405] ------------[ cut here ]------------
[   18.231284] WARNING: CPU: 0 PID: 109 at net/netlink/genetlink.c:1011 gen=
l_bind+0x142/0x15e()
[   18.233126] CPU: 0 PID: 109 Comm: trinity-main Tainted: G        W      =
3.18.0-11169-gc380d9a #9
[   18.234693]  0000000000000009 ffff88000b44fdd8 ffffffff8175b593 ffff8800=
0b44fe18
[   18.236147]  ffffffff810b55aa 0000000000000001 ffffffff8174d931 ffffffff=
834a3400
[   18.237545]  0000000000000001 0000000000000000 0000000000000000 ffff8800=
0b44fe28
[   18.238848] Call Trace:
[   18.239110]  [<ffffffff8175b593>] dump_stack+0x2e/0x3e
[   18.239642]  [<ffffffff810b55aa>] warn_slowpath_common+0xb6/0xe5
[   18.240270]  [<ffffffff8174d931>] ? genl_bind+0x142/0x15e
[   18.240815]  [<ffffffff810b56db>] warn_slowpath_null+0x23/0x2c
[   18.241388]  [<ffffffff8174d931>] genl_bind+0x142/0x15e
[   18.241916]  [<ffffffff8174ab86>] netlink_bind+0x155/0x2ce
[   18.242508]  [<ffffffff8170e512>] SyS_bind+0xc1/0x117
[   18.243429]  [<ffffffff81769058>] ? _raw_spin_unlock+0x38/0x50
[   18.244493]  [<ffffffff8114553f>] ? context_tracking_user_exit+0xe2/0x101
[   18.245671]  [<ffffffff810eafbd>] ? trace_hardirqs_on+0x1b/0x24
[   18.246731]  [<ffffffff8176a2e7>] system_call_fastpath+0x12/0x17
[   18.247707] ---[ end trace f8ae22d84a926b5a ]---
[   18.248244] ------------[ cut here ]------------
[   18.248724] WARNING: CPU: 0 PID: 109 at net/netlink/genetlink.c:1011 gen=
l_bind+0x142/0x15e()
[   18.249713] CPU: 0 PID: 109 Comm: trinity-main Tainted: G        W      =
3.18.0-11169-gc380d9a #9
[   18.250599]  0000000000000009 ffff88000b44fdd8 ffffffff8175b593 ffff8800=
0b44fe18
[   18.251410]  ffffffff810b55aa 0000000000000004 ffffffff8174d931 ffffffff=
834a3400
[   18.252246]  0000000000000004 0000000000000000 0000000000000000 ffff8800=
0b44fe28
[   18.253111] Call Trace:
[   18.253362]  [<ffffffff8175b593>] dump_stack+0x2e/0x3e
[   18.253887]  [<ffffffff810b55aa>] warn_slowpath_common+0xb6/0xe5
[   18.254491]  [<ffffffff8174d931>] ? genl_bind+0x142/0x15e
[   18.255037]  [<ffffffff810b56db>] warn_slowpath_null+0x23/0x2c
[   18.255626]  [<ffffffff8174d931>] genl_bind+0x142/0x15e
[   18.256171]  [<ffffffff8174ab86>] netlink_bind+0x155/0x2ce
[   18.256730]  [<ffffffff8170e512>] SyS_bind+0xc1/0x117
[   18.257226]  [<ffffffff81769058>] ? _raw_spin_unlock+0x38/0x50
[   18.257812]  [<ffffffff8114553f>] ? context_tracking_user_exit+0xe2/0x101
[   18.258497]  [<ffffffff810eafbd>] ? trace_hardirqs_on+0x1b/0x24
[   18.259095]  [<ffffffff8176a2e7>] system_call_fastpath+0x12/0x17
[   18.259710] ---[ end trace f8ae22d84a926b5b ]---
[   18.260246] ------------[ cut here ]------------
[   18.260722] WARNING: CPU: 0 PID: 109 at net/netlink/genetlink.c:1011 gen=
l_bind+0x142/0x15e()
[   18.261696] CPU: 0 PID: 109 Comm: trinity-main Tainted: G        W      =
3.18.0-11169-gc380d9a #9
[   18.262696]  0000000000000009 ffff88000b44fdd8 ffffffff8175b593 ffff8800=
0b44fe18
[   18.264126]  ffffffff810b55aa 0000000000000005 ffffffff8174d931 ffffffff=
834a3400
[   18.265493]  0000000000000005 0000000000000000 0000000000000000 ffff8800=
0b44fe28
[   18.266894] Call Trace:
[   18.267354]  [<ffffffff8175b593>] dump_stack+0x2e/0x3e
[   18.268296]  [<ffffffff810b55aa>] warn_slowpath_common+0xb6/0xe5
[   18.269254]  [<ffffffff8174d931>] ? genl_bind+0x142/0x15e
[   18.269794]  [<ffffffff810b56db>] warn_slowpath_null+0x23/0x2c
[   18.270381]  [<ffffffff8174d931>] genl_bind+0x142/0x15e
[   18.270906]  [<ffffffff8174ab86>] netlink_bind+0x155/0x2ce
[   18.271489]  [<ffffffff8170e512>] SyS_bind+0xc1/0x117
[   18.272059]  [<ffffffff81769058>] ? _raw_spin_unlock+0x38/0x50
[   18.272781]  [<ffffffff8114553f>] ? context_tracking_user_exit+0xe2/0x101
[   18.273510]  [<ffffffff810eafbd>] ? trace_hardirqs_on+0x1b/0x24
[   18.274151]  [<ffffffff8176a2e7>] system_call_fastpath+0x12/0x17
[   18.274804] ---[ end trace f8ae22d84a926b5c ]---
[   18.275353] ------------[ cut here ]------------
[   18.275868] WARNING: CPU: 0 PID: 109 at net/netlink/genetlink.c:1011 gen=
l_bind+0x142/0x15e()
[   18.276970] CPU: 0 PID: 109 Comm: trinity-main Tainted: G        W      =
3.18.0-11169-gc380d9a #9
[   18.277919]  0000000000000009 ffff88000b44fdd8 ffffffff8175b593 ffff8800=
0b44fe18
[   18.278800]  ffffffff810b55aa 0000000000000006 ffffffff8174d931 ffffffff=
834a3400
[   18.279639]  0000000000000006 0000000000000000 0000000000000000 ffff8800=
0b44fe28
[   18.280555] Call Trace:
[   18.280830]  [<ffffffff8175b593>] dump_stack+0x2e/0x3e
[   18.281387]  [<ffffffff810b55aa>] warn_slowpath_common+0xb6/0xe5
[   18.282039]  [<ffffffff8174d931>] ? genl_bind+0x142/0x15e
[   18.282677]  [<ffffffff810b56db>] warn_slowpath_null+0x23/0x2c
[   18.283315]  [<ffffffff8174d931>] genl_bind+0x142/0x15e
[   18.283885]  [<ffffffff8174ab86>] netlink_bind+0x155/0x2ce
[   18.284492]  [<ffffffff8170e512>] SyS_bind+0xc1/0x117
[   18.285051]  [<ffffffff81769058>] ? _raw_spin_unlock+0x38/0x50
[   18.285664]  [<ffffffff8114553f>] ? context_tracking_user_exit+0xe2/0x101
[   18.286400]  [<ffffffff810eafbd>] ? trace_hardirqs_on+0x1b/0x24
[   18.287032]  [<ffffffff8176a2e7>] system_call_fastpath+0x12/0x17
[   18.287689] ---[ end trace f8ae22d84a926b5d ]---
[   18.288250] ------------[ cut here ]------------
[   18.288776] WARNING: CPU: 0 PID: 109 at net/netlink/genetlink.c:1011 gen=
l_bind+0x142/0x15e()
[   18.289835] CPU: 0 PID: 109 Comm: trinity-main Tainted: G        W      =
3.18.0-11169-gc380d9a #9
[   18.290785]  0000000000000009 ffff88000b44fdd8 ffffffff8175b593 ffff8800=
0b44fe18
[   18.291652]  ffffffff810b55aa 0000000000000008 ffffffff8174d931 ffffffff=
834a3400
[   18.292584]  0000000000000008 0000000000000000 0000000000000000 ffff8800=
0b44fe28
[   18.293533] Call Trace:
[   18.293813]  [<ffffffff8175b593>] dump_stack+0x2e/0x3e
[   18.294392]  [<ffffffff810b55aa>] warn_slowpath_common+0xb6/0xe5
[   18.295037]  [<ffffffff8174d931>] ? genl_bind+0x142/0x15e
[   18.295621]  [<ffffffff810b56db>] warn_slowpath_null+0x23/0x2c
[   18.296281]  [<ffffffff8174d931>] genl_bind+0x142/0x15e
[   18.296857]  [<ffffffff8174ab86>] netlink_bind+0x155/0x2ce
[   18.297461]  [<ffffffff8170e512>] SyS_bind+0xc1/0x117
[   18.298011]  [<ffffffff81769058>] ? _raw_spin_unlock+0x38/0x50
[   18.298655]  [<ffffffff8114553f>] ? context_tracking_user_exit+0xe2/0x101
[   18.299562]  [<ffffffff810eafbd>] ? trace_hardirqs_on+0x1b/0x24
[   18.300533]  [<ffffffff8176a2e7>] system_call_fastpath+0x12/0x17
[   18.301494] ---[ end trace f8ae22d84a926b5e ]---
[   18.302271] ------------[ cut here ]------------
[   18.303016] WARNING: CPU: 0 PID: 109 at net/netlink/genetlink.c:1011 gen=
l_bind+0x142/0x15e()
[   18.304609] CPU: 0 PID: 109 Comm: trinity-main Tainted: G        W      =
3.18.0-11169-gc380d9a #9
[   18.305994]  0000000000000009 ffff88000b44fdd8 ffffffff8175b593 ffff8800=
0b44fe18
[   18.307258]  ffffffff810b55aa 0000000000000009 ffffffff8174d931 ffffffff=
834a3400
[   18.308536]  0000000000000009 0000000000000000 0000000000000000 ffff8800=
0b44fe28
[   18.309790] Call Trace:
[   18.310194]  [<ffffffff8175b593>] dump_stack+0x2e/0x3e
[   18.311019]  [<ffffffff810b55aa>] warn_slowpath_common+0xb6/0xe5
[   18.311984]  [<ffffffff8174d931>] ? genl_bind+0x142/0x15e
[   18.312881]  [<ffffffff810b56db>] warn_slowpath_null+0x23/0x2c
[   18.313813]  [<ffffffff8174d931>] genl_bind+0x142/0x15e
[   18.314652]  [<ffffffff8174ab86>] netlink_bind+0x155/0x2ce
[   18.315531]  [<ffffffff8170e512>] SyS_bind+0xc1/0x117
[   18.316361]  [<ffffffff81769058>] ? _raw_spin_unlock+0x38/0x50
[   18.317291]  [<ffffffff8114553f>] ? context_tracking_user_exit+0xe2/0x101
[   18.318375]  [<ffffffff810eafbd>] ? trace_hardirqs_on+0x1b/0x24
[   18.319317]  [<ffffffff8176a2e7>] system_call_fastpath+0x12/0x17
[   18.320287] ---[ end trace f8ae22d84a926b5f ]---
[   18.321053] ------------[ cut here ]------------
[   18.321801] WARNING: CPU: 0 PID: 109 at net/netlink/genetlink.c:1011 gen=
l_bind+0x142/0x15e()
[   18.323385] CPU: 0 PID: 109 Comm: trinity-main Tainted: G        W      =
3.18.0-11169-gc380d9a #9
[   18.324787]  0000000000000009 ffff88000b44fdd8 ffffffff8175b593 ffff8800=
0b44fe18
[   18.326052]  ffffffff810b55aa 000000000000000e ffffffff8174d931 ffffffff=
834a3400
[   18.327311]  000000000000000e 0000000000000000 0000000000000000 ffff8800=
0b44fe28
[   18.328588] Call Trace:
[   18.328991]  [<ffffffff8175b593>] dump_stack+0x2e/0x3e
[   18.329847]  [<ffffffff810b55aa>] warn_slowpath_common+0xb6/0xe5
[   18.330803]  [<ffffffff8174d931>] ? genl_bind+0x142/0x15e
[   18.331665]  [<ffffffff810b56db>] warn_slowpath_null+0x23/0x2c
[   18.332607]  [<ffffffff8174d931>] genl_bind+0x142/0x15e
[   18.333156]  [<ffffffff8174ab86>] netlink_bind+0x155/0x2ce
[   18.333757]  [<ffffffff8170e512>] SyS_bind+0xc1/0x117
[   18.334311]  [<ffffffff81769058>] ? _raw_spin_unlock+0x38/0x50
[   18.334963]  [<ffffffff8114553f>] ? context_tracking_user_exit+0xe2/0x101
[   18.335710]  [<ffffffff810eafbd>] ? trace_hardirqs_on+0x1b/0x24
[   18.336401]  [<ffffffff8176a2e7>] system_call_fastpath+0x12/0x17
[   18.337056] ---[ end trace f8ae22d84a926b60 ]---
[   18.337613] ------------[ cut here ]------------
[   18.338127] WARNING: CPU: 0 PID: 109 at net/netlink/genetlink.c:1011 gen=
l_bind+0x142/0x15e()
[   18.339226] CPU: 0 PID: 109 Comm: trinity-main Tainted: G        W      =
3.18.0-11169-gc380d9a #9
[   18.340204]  0000000000000009 ffff88000b44fdd8 ffffffff8175b593 ffff8800=
0b44fe18
[   18.341085]  ffffffff810b55aa 000000000000000f ffffffff8174d931 ffffffff=
834a3400
[   18.341962]  000000000000000f 0000000000000000 0000000000000000 ffff8800=
0b44fe28
[   18.343096] Call Trace:
[   18.343541]  [<ffffffff8175b593>] dump_stack+0x2e/0x3e
[   18.344476]  [<ffffffff810b55aa>] warn_slowpath_common+0xb6/0xe5
[   18.345484]  [<ffffffff8174d931>] ? genl_bind+0x142/0x15e
[   18.346428]  [<ffffffff810b56db>] warn_slowpath_null+0x23/0x2c
[   18.347469]  [<ffffffff8174d931>] genl_bind+0x142/0x15e
[   18.348387]  [<ffffffff8174ab86>] netlink_bind+0x155/0x2ce
[   18.349334]  [<ffffffff8170e512>] SyS_bind+0xc1/0x117
[   18.350228]  [<ffffffff81769058>] ? _raw_spin_unlock+0x38/0x50
[   18.351240]  [<ffffffff8114553f>] ? context_tracking_user_exit+0xe2/0x101
[   18.352467]  [<ffffffff810eafbd>] ? trace_hardirqs_on+0x1b/0x24
[   18.353445]  [<ffffffff8176a2e7>] system_call_fastpath+0x12/0x17
[   18.354491] ---[ end trace f8ae22d84a926b61 ]---
[   18.377403] ------------[ cut here ]------------
[   18.378238] WARNING: CPU: 0 PID: 109 at net/netlink/genetlink.c:1011 gen=
l_bind+0x142/0x15e()
[   18.379894] CPU: 0 PID: 109 Comm: trinity-main Tainted: G        W      =
3.18.0-11169-gc380d9a #9
[   18.381373]  0000000000000009 ffff88000b44fdd8 ffffffff8175b593 ffff8800=
0b44fe18
[   18.382773]  ffffffff810b55aa 0000000000000000 ffffffff8174d931 ffffffff=
834a3400
[   18.384095]  0000000000000000 0000000000000000 0000000000000000 ffff8800=
0b44fe28
[   18.385151] Call Trace:
[   18.385599]  [<ffffffff8175b593>] dump_stack+0x2e/0x3e
[   18.386440]  [<ffffffff810b55aa>] warn_slowpath_common+0xb6/0xe5
[   18.387446]  [<ffffffff8174d931>] ? genl_bind+0x142/0x15e
[   18.388391]  [<ffffffff810b56db>] warn_slowpath_null+0x23/0x2c
[   18.389401]  [<ffffffff8174d931>] genl_bind+0x142/0x15e
[   18.390228]  [<ffffffff8174ab86>] netlink_bind+0x155/0x2ce
[   18.391119]  [<ffffffff8170e512>] SyS_bind+0xc1/0x117
[   18.391963]  [<ffffffff81769058>] ? _raw_spin_unlock+0x38/0x50
[   18.392993]  [<ffffffff8114553f>] ? context_tracking_user_exit+0xe2/0x101
[   18.394095]  [<ffffffff810eafbd>] ? trace_hardirqs_on+0x1b/0x24
[   18.395069]  [<ffffffff8176a2e7>] system_call_fastpath+0x12/0x17
[   18.396056] ---[ end trace f8ae22d84a926b62 ]---
[   18.396945] ------------[ cut here ]------------
[   18.397719] WARNING: CPU: 0 PID: 109 at net/netlink/genetlink.c:1011 gen=
l_bind+0x142/0x15e()
[   18.399382] CPU: 0 PID: 109 Comm: trinity-main Tainted: G        W      =
3.18.0-11169-gc380d9a #9
[   18.400845]  0000000000000009 ffff88000b44fdd8 ffffffff8175b593 ffff8800=
0b44fe18
[   18.402176]  ffffffff810b55aa 0000000000000001 ffffffff8174d931 ffffffff=
834a3400
[   18.403552]  0000000000000001 0000000000000000 0000000000000000 ffff8800=
0b44fe28
[   18.404877] Call Trace:
[   18.405280]  [<ffffffff8175b593>] dump_stack+0x2e/0x3e
[   18.406151]  [<ffffffff810b55aa>] warn_slowpath_common+0xb6/0xe5
[   18.407250]  [<ffffffff8174d931>] ? genl_bind+0x142/0x15e
[   18.408294]  [<ffffffff810b56db>] warn_slowpath_null+0x23/0x2c
[   18.409267]  [<ffffffff8174d931>] genl_bind+0x142/0x15e
[   18.410215]  [<ffffffff8174ab86>] netlink_bind+0x155/0x2ce
[   18.411143]  [<ffffffff8170e512>] SyS_bind+0xc1/0x117
[   18.411844]  [<ffffffff81769058>] ? _raw_spin_unlock+0x38/0x50
[   18.412435]  [<ffffffff8114553f>] ? context_tracking_user_exit+0xe2/0x101
[   18.413178]  [<ffffffff810eafbd>] ? trace_hardirqs_on+0x1b/0x24
[   18.413843]  [<ffffffff8176a2e7>] system_call_fastpath+0x12/0x17
[   18.414516] ---[ end trace f8ae22d84a926b63 ]---
[   18.415080] ------------[ cut here ]------------
[   18.415622] WARNING: CPU: 0 PID: 109 at net/netlink/genetlink.c:1011 gen=
l_bind+0x142/0x15e()
[   18.416739] CPU: 0 PID: 109 Comm: trinity-main Tainted: G        W      =
3.18.0-11169-gc380d9a #9
[   18.417715]  0000000000000009 ffff88000b44fdd8 ffffffff8175b593 ffff8800=
0b44fe18
[   18.418601]  ffffffff810b55aa 0000000000000005 ffffffff8174d931 ffffffff=
834a3400
[   18.419471]  0000000000000005 0000000000000000 0000000000000000 ffff8800=
0b44fe28
[   18.420333] Call Trace:
[   18.420619]  [<ffffffff8175b593>] dump_stack+0x2e/0x3e
[   18.421167]  [<ffffffff810b55aa>] warn_slowpath_common+0xb6/0xe5
[   18.421839]  [<ffffffff8174d931>] ? genl_bind+0x142/0x15e
[   18.422415]  [<ffffffff810b56db>] warn_slowpath_null+0x23/0x2c
[   18.423283]  [<ffffffff8174d931>] genl_bind+0x142/0x15e
[   18.423882]  [<ffffffff8174ab86>] netlink_bind+0x155/0x2ce
[   18.424735]  [<ffffffff8170e512>] SyS_bind+0xc1/0x117
[   18.425559]  [<ffffffff81769058>] ? _raw_spin_unlock+0x38/0x50
[   18.426483]  [<ffffffff8114553f>] ? context_tracking_user_exit+0xe2/0x101
[   18.427573]  [<ffffffff810eafbd>] ? trace_hardirqs_on+0x1b/0x24
[   18.428546]  [<ffffffff8176a2e7>] system_call_fastpath+0x12/0x17
[   18.429482] ---[ end trace f8ae22d84a926b64 ]---
[   18.430260] ------------[ cut here ]------------
[   18.431012] WARNING: CPU: 0 PID: 109 at net/netlink/genetlink.c:1011 gen=
l_bind+0x142/0x15e()
[   18.432621] CPU: 0 PID: 109 Comm: trinity-main Tainted: G        W      =
3.18.0-11169-gc380d9a #9
[   18.434021]  0000000000000009 ffff88000b44fdd8 ffffffff8175b593 ffff8800=
0b44fe18
[   18.435307]  ffffffff810b55aa 0000000000000006 ffffffff8174d931 ffffffff=
834a3400
[   18.436572]  0000000000000006 0000000000000000 0000000000000000 ffff8800=
0b44fe28
[   18.437815] Call Trace:
[   18.438189]  [<ffffffff8175b593>] dump_stack+0x2e/0x3e
[   18.439014]  [<ffffffff810b55aa>] warn_slowpath_common+0xb6/0xe5
[   18.439951]  [<ffffffff8174d931>] ? genl_bind+0x142/0x15e
[   18.440841]  [<ffffffff810b56db>] warn_slowpath_null+0x23/0x2c
[   18.441768]  [<ffffffff8174d931>] genl_bind+0x142/0x15e
[   18.442611]  [<ffffffff8174ab86>] netlink_bind+0x155/0x2ce
[   18.443509]  [<ffffffff8170e512>] SyS_bind+0xc1/0x117
[   18.444342]  [<ffffffff81769058>] ? _raw_spin_unlock+0x38/0x50
[   18.445255]  [<ffffffff8114553f>] ? context_tracking_user_exit+0xe2/0x101
[   18.446323]  [<ffffffff810eafbd>] ? trace_hardirqs_on+0x1b/0x24
[   18.447256]  [<ffffffff8176a2e7>] system_call_fastpath+0x12/0x17
[   18.448233] ---[ end trace f8ae22d84a926b65 ]---
[   18.448874] ------------[ cut here ]------------
[   18.449616] WARNING: CPU: 0 PID: 109 at net/netlink/genetlink.c:1011 gen=
l_bind+0x142/0x15e()
[   18.451203] CPU: 0 PID: 109 Comm: trinity-main Tainted: G        W      =
3.18.0-11169-gc380d9a #9
[   18.452610]  0000000000000009 ffff88000b44fdd8 ffffffff8175b593 ffff8800=
0b44fe18
[   18.453885]  ffffffff810b55aa 0000000000000007 ffffffff8174d931 ffffffff=
834a3400
[   18.455155]  0000000000000007 0000000000000000 0000000000000000 ffff8800=
0b44fe28
[   18.456460] Call Trace:
[   18.456875]  [<ffffffff8175b593>] dump_stack+0x2e/0x3e
[   18.457715]  [<ffffffff810b55aa>] warn_slowpath_common+0xb6/0xe5
[   18.458671]  [<ffffffff8174d931>] ? genl_bind+0x142/0x15e
[   18.459547]  [<ffffffff810b56db>] warn_slowpath_null+0x23/0x2c
[   18.460503]  [<ffffffff8174d931>] genl_bind+0x142/0x15e
[   18.461364]  [<ffffffff8174ab86>] netlink_bind+0x155/0x2ce
[   18.462248]  [<ffffffff8170e512>] SyS_bind+0xc1/0x117
[   18.463072]  [<ffffffff81769058>] ? _raw_spin_unlock+0x38/0x50
[   18.464035]  [<ffffffff8114553f>] ? context_tracking_user_exit+0xe2/0x101
[   18.465162]  [<ffffffff810eafbd>] ? trace_hardirqs_on+0x1b/0x24
[   18.466119]  [<ffffffff8176a2e7>] system_call_fastpath+0x12/0x17
[   18.467089] ---[ end trace f8ae22d84a926b66 ]---
[   18.472659] ------------[ cut here ]------------
[   18.473423] WARNING: CPU: 0 PID: 109 at net/netlink/genetlink.c:1011 gen=
l_bind+0x142/0x15e()
[   18.474995] CPU: 0 PID: 109 Comm: trinity-main Tainted: G        W      =
3.18.0-11169-gc380d9a #9
[   18.476435]  0000000000000009 ffff88000b44fdd8 ffffffff8175b593 ffff8800=
0b44fe18
[   18.477738]  ffffffff810b55aa 0000000000000001 ffffffff8174d931 ffffffff=
834a3400
[   18.479000]  0000000000000001 0000000000000000 0000000000000000 ffff8800=
0b44fe28
[   18.480337] Call Trace:
[   18.480767]  [<ffffffff8175b593>] dump_stack+0x2e/0x3e
[   18.481612]  [<ffffffff810b55aa>] warn_slowpath_common+0xb6/0xe5
[   18.482619]  [<ffffffff8174d931>] ? genl_bind+0x142/0x15e
[   18.483502]  [<ffffffff810b56db>] warn_slowpath_null+0x23/0x2c
[   18.484451]  [<ffffffff8174d931>] genl_bind+0x142/0x15e
[   18.485229]  [<ffffffff8174ab86>] netlink_bind+0x155/0x2ce
[   18.486058]  [<ffffffff8170e512>] SyS_bind+0xc1/0x117
[   18.486828]  [<ffffffff81769058>] ? _raw_spin_unlock+0x38/0x50
[   18.487734]  [<ffffffff8114553f>] ? context_tracking_user_exit+0xe2/0x101
[   18.488746]  [<ffffffff810eafbd>] ? trace_hardirqs_on+0x1b/0x24
[   18.489704]  [<ffffffff8176a2e7>] system_call_fastpath+0x12/0x17
[   18.490536] ---[ end trace f8ae22d84a926b67 ]---
[   18.491330] ------------[ cut here ]------------
[   18.492121] WARNING: CPU: 0 PID: 109 at net/netlink/genetlink.c:1011 gen=
l_bind+0x142/0x15e()
[   18.493702] CPU: 0 PID: 109 Comm: trinity-main Tainted: G        W      =
3.18.0-11169-gc380d9a #9
[   18.495066]  0000000000000009 ffff88000b44fdd8 ffffffff8175b593 ffff8800=
0b44fe18
[   18.496366]  ffffffff810b55aa 000000000000001f ffffffff8174d931 ffffffff=
834a3400
[   18.497635]  000000000000001f 0000000000000000 0000000000000000 ffff8800=
0b44fe28
[   18.498908] Call Trace:
[   18.499340]  [<ffffffff8175b593>] dump_stack+0x2e/0x3e
[   18.500179]  [<ffffffff810b55aa>] warn_slowpath_common+0xb6/0xe5
[   18.501133]  [<ffffffff8174d931>] ? genl_bind+0x142/0x15e
[   18.501992]  [<ffffffff810b56db>] warn_slowpath_null+0x23/0x2c
[   18.502945]  [<ffffffff8174d931>] genl_bind+0x142/0x15e
[   18.503817]  [<ffffffff8174ab86>] netlink_bind+0x155/0x2ce
[   18.504742]  [<ffffffff8170e512>] SyS_bind+0xc1/0x117
[   18.505535]  [<ffffffff81769058>] ? _raw_spin_unlock+0x38/0x50
[   18.506517]  [<ffffffff8114553f>] ? context_tracking_user_exit+0xe2/0x101
[   18.507582]  [<ffffffff810eafbd>] ? trace_hardirqs_on+0x1b/0x24
[   18.508529]  [<ffffffff8176a2e7>] system_call_fastpath+0x12/0x17
[   18.509469] ---[ end trace f8ae22d84a926b68 ]---
[   18.584421] ------------[ cut here ]------------
[   18.585268] WARNING: CPU: 0 PID: 109 at net/netlink/genetlink.c:1011 gen=
l_bind+0x142/0x15e()
[   18.586968] CPU: 0 PID: 109 Comm: trinity-main Tainted: G        W      =
3.18.0-11169-gc380d9a #9
[   18.588478]  0000000000000009 ffff88000b44fdd8 ffffffff8175b593 ffff8800=
0b44fe18
[   18.590026]  ffffffff810b55aa 0000000000000000 ffffffff8174d931 ffffffff=
834a3400
[   18.591565]  0000000000000000 0000000000000000 0000000000000000 ffff8800=
0b44fe28
[   18.593513] Call Trace:
[   18.594171]  [<ffffffff8175b593>] dump_stack+0x2e/0x3e
[   18.595468]  [<ffffffff810b55aa>] warn_slowpath_common+0xb6/0xe5
[   18.596927]  [<ffffffff8174d931>] ? genl_bind+0x142/0x15e
[   18.598240]  [<ffffffff810b56db>] warn_slowpath_null+0x23/0x2c
[   18.599736]  [<ffffffff8174d931>] genl_bind+0x142/0x15e
[   18.601047]  [<ffffffff8174ab86>] netlink_bind+0x155/0x2ce
[   18.602361]  [<ffffffff8170e512>] SyS_bind+0xc1/0x117
[   18.603528]  [<ffffffff81769058>] ? _raw_spin_unlock+0x38/0x50
[   18.604922]  [<ffffffff8114553f>] ? context_tracking_user_exit+0xe2/0x101
[   18.606546]  [<ffffffff810eafbd>] ? trace_hardirqs_on+0x1b/0x24
[   18.608045]  [<ffffffff8176a2e7>] system_call_fastpath+0x12/0x17
[   18.609466] ---[ end trace f8ae22d84a926b69 ]---
[   18.610663] ------------[ cut here ]------------
[   18.611771] WARNING: CPU: 0 PID: 109 at net/netlink/genetlink.c:1011 gen=
l_bind+0x142/0x15e()
[   18.614158] CPU: 0 PID: 109 Comm: trinity-main Tainted: G        W      =
3.18.0-11169-gc380d9a #9
[   18.616193]  0000000000000009 ffff88000b44fdd8 ffffffff8175b593 ffff8800=
0b44fe18
[   18.617959]  ffffffff810b55aa 0000000000000005 ffffffff8174d931 ffffffff=
834a3400
[   18.619897]  0000000000000005 0000000000000000 0000000000000000 ffff8800=
0b44fe28
[   18.621845] Call Trace:
[   18.622463]  [<ffffffff8175b593>] dump_stack+0x2e/0x3e
[   18.623726]  [<ffffffff810b55aa>] warn_slowpath_common+0xb6/0xe5
[   18.625221]  [<ffffffff8174d931>] ? genl_bind+0x142/0x15e
[   18.626625]  [<ffffffff810b56db>] warn_slowpath_null+0x23/0x2c
[   18.628086]  [<ffffffff8174d931>] genl_bind+0x142/0x15e
[   18.629343]  [<ffffffff8174ab86>] netlink_bind+0x155/0x2ce
[   18.630675]  [<ffffffff8170e512>] SyS_bind+0xc1/0x117
[   18.631968]  [<ffffffff81769058>] ? _raw_spin_unlock+0x38/0x50
[   18.633420]  [<ffffffff8114553f>] ? context_tracking_user_exit+0xe2/0x101
[   18.635045]  [<ffffffff810eafbd>] ? trace_hardirqs_on+0x1b/0x24
[   18.636540]  [<ffffffff8176a2e7>] system_call_fastpath+0x12/0x17
[   18.638025] ---[ end trace f8ae22d84a926b6a ]---
[   18.639155] ------------[ cut here ]------------
[   18.640271] WARNING: CPU: 0 PID: 109 at net/netlink/genetlink.c:1011 gen=
l_bind+0x142/0x15e()
[   18.642734] CPU: 0 PID: 109 Comm: trinity-main Tainted: G        W      =
3.18.0-11169-gc380d9a #9
[   18.644790]  0000000000000009 ffff88000b44fdd8 ffffffff8175b593 ffff8800=
0b44fe18
[   18.646675]  ffffffff810b55aa 0000000000000006 ffffffff8174d931 ffffffff=
834a3400
[   18.648682]  0000000000000006 0000000000000000 0000000000000000 ffff8800=
0b44fe28
[   18.650545] Call Trace:
[   18.651148]  [<ffffffff8175b593>] dump_stack+0x2e/0x3e
[   18.652437]  [<ffffffff810b55aa>] warn_slowpath_common+0xb6/0xe5
[   18.653735]  [<ffffffff8174d931>] ? genl_bind+0x142/0x15e
[   18.654742]  [<ffffffff810b56db>] warn_slowpath_null+0x23/0x2c
[   18.656054]  [<ffffffff8174d931>] genl_bind+0x142/0x15e
[   18.657015]  [<ffffffff8174ab86>] netlink_bind+0x155/0x2ce
[   18.658062]  [<ffffffff8170e512>] SyS_bind+0xc1/0x117
[   18.659014]  [<ffffffff81769058>] ? _raw_spin_unlock+0x38/0x50
[   18.660303]  [<ffffffff8114553f>] ? context_tracking_user_exit+0xe2/0x101
[   18.661543]  [<ffffffff810eafbd>] ? trace_hardirqs_on+0x1b/0x24
[   18.662595]  [<ffffffff8176a2e7>] system_call_fastpath+0x12/0x17
[   18.663730] ---[ end trace f8ae22d84a926b6b ]---
[   18.664733] ------------[ cut here ]------------
[   18.665605] WARNING: CPU: 0 PID: 109 at net/netlink/genetlink.c:1011 gen=
l_bind+0x142/0x15e()
[   18.667460] CPU: 0 PID: 109 Comm: trinity-main Tainted: G        W      =
3.18.0-11169-gc380d9a #9
[   18.669289]  0000000000000009 ffff88000b44fdd8 ffffffff8175b593 ffff8800=
0b44fe18
[   18.670723]  ffffffff810b55aa 0000000000000008 ffffffff8174d931 ffffffff=
834a3400
[   18.672312]  0000000000000008 0000000000000000 0000000000000000 ffff8800=
0b44fe28
[   18.674501] Call Trace:
[   18.675002]  [<ffffffff8175b593>] dump_stack+0x2e/0x3e
[   18.676058]  [<ffffffff810b55aa>] warn_slowpath_common+0xb6/0xe5
[   18.677169]  [<ffffffff8174d931>] ? genl_bind+0x142/0x15e
[   18.678130]  [<ffffffff810b56db>] warn_slowpath_null+0x23/0x2c
[   18.679032]  [<ffffffff8174d931>] genl_bind+0x142/0x15e
[   18.679845]  [<ffffffff8174ab86>] netlink_bind+0x155/0x2ce
[   18.680531]  [<ffffffff8170e512>] SyS_bind+0xc1/0x117
[   18.681188]  [<ffffffff81769058>] ? _raw_spin_unlock+0x38/0x50
[   18.681824]  [<ffffffff8114553f>] ? context_tracking_user_exit+0xe2/0x101
[   18.682606]  [<ffffffff810eafbd>] ? trace_hardirqs_on+0x1b/0x24
[   18.683253]  [<ffffffff8176a2e7>] system_call_fastpath+0x12/0x17
[   18.683927] ---[ end trace f8ae22d84a926b6c ]---
[   18.684593] ------------[ cut here ]------------
[   18.685215] WARNING: CPU: 0 PID: 109 at net/netlink/genetlink.c:1011 gen=
l_bind+0x142/0x15e()
[   18.686330] CPU: 0 PID: 109 Comm: trinity-main Tainted: G        W      =
3.18.0-11169-gc380d9a #9
[   18.687298]  0000000000000009 ffff88000b44fdd8 ffffffff8175b593 ffff8800=
0b44fe18
[   18.688353]  ffffffff810b55aa 0000000000000009 ffffffff8174d931 ffffffff=
834a3400
[   18.689563]  0000000000000009 0000000000000000 0000000000000000 ffff8800=
0b44fe28
[   18.690740] Call Trace:
[   18.691126]  [<ffffffff8175b593>] dump_stack+0x2e/0x3e
[   18.691916]  [<ffffffff810b55aa>] warn_slowpath_common+0xb6/0xe5
[   18.692777]  [<ffffffff8174d931>] ? genl_bind+0x142/0x15e
[   18.693430]  [<ffffffff810b56db>] warn_slowpath_null+0x23/0x2c
[   18.694026]  [<ffffffff8174d931>] genl_bind+0x142/0x15e
[   18.694636]  [<ffffffff8174ab86>] netlink_bind+0x155/0x2ce
[   18.695243]  [<ffffffff8170e512>] SyS_bind+0xc1/0x117
[   18.695783]  [<ffffffff81769058>] ? _raw_spin_unlock+0x38/0x50
[   18.696553]  [<ffffffff8114553f>] ? context_tracking_user_exit+0xe2/0x101
[   18.697332]  [<ffffffff810eafbd>] ? trace_hardirqs_on+0x1b/0x24
[   18.697941]  [<ffffffff8176a2e7>] system_call_fastpath+0x12/0x17
[   18.698633] ---[ end trace f8ae22d84a926b6d ]---
[   18.699213] ------------[ cut here ]------------
[   18.699718] WARNING: CPU: 0 PID: 109 at net/netlink/genetlink.c:1011 gen=
l_bind+0x142/0x15e()
[   18.700839] CPU: 0 PID: 109 Comm: trinity-main Tainted: G        W      =
3.18.0-11169-gc380d9a #9
[   18.702192]  0000000000000009 ffff88000b44fdd8 ffffffff8175b593 ffff8800=
0b44fe18
[   18.703433]  ffffffff810b55aa 000000000000000a ffffffff8174d931 ffffffff=
834a3400
[   18.704643]  000000000000000a 0000000000000000 0000000000000000 ffff8800=
0b44fe28
[   18.705874] Call Trace:
[   18.706287]  [<ffffffff8175b593>] dump_stack+0x2e/0x3e
[   18.707057]  [<ffffffff810b55aa>] warn_slowpath_common+0xb6/0xe5
[   18.707959]  [<ffffffff8174d931>] ? genl_bind+0x142/0x15e
[   18.708774]  [<ffffffff810b56db>] warn_slowpath_null+0x23/0x2c
[   18.709726]  [<ffffffff8174d931>] genl_bind+0x142/0x15e
[   18.710507]  [<ffffffff8174ab86>] netlink_bind+0x155/0x2ce
[   18.711350]  [<ffffffff8170e512>] SyS_bind+0xc1/0x117
[   18.712127]  [<ffffffff81769058>] ? _raw_spin_unlock+0x38/0x50
[   18.712786]  [<ffffffff8114553f>] ? context_tracking_user_exit+0xe2/0x101
[   18.713595]  [<ffffffff810eafbd>] ? trace_hardirqs_on+0x1b/0x24
[   18.714277]  [<ffffffff8176a2e7>] system_call_fastpath+0x12/0x17
[   18.714908] ---[ end trace f8ae22d84a926b6e ]---
[   18.715439] ------------[ cut here ]------------
[   18.715979] WARNING: CPU: 0 PID: 109 at net/netlink/genetlink.c:1011 gen=
l_bind+0x142/0x15e()
[   18.717152] CPU: 0 PID: 109 Comm: trinity-main Tainted: G        W      =
3.18.0-11169-gc380d9a #9
[   18.718051]  0000000000000009 ffff88000b44fdd8 ffffffff8175b593 ffff8800=
0b44fe18
[   18.719006]  ffffffff810b55aa 000000000000000c ffffffff8174d931 ffffffff=
834a3400
[   18.719868]  000000000000000c 0000000000000000 0000000000000000 ffff8800=
0b44fe28
[   18.720791] Call Trace:
[   18.721255]  [<ffffffff8175b593>] dump_stack+0x2e/0x3e
[   18.722235]  [<ffffffff810b55aa>] warn_slowpath_common+0xb6/0xe5
[   18.723429]  [<ffffffff8174d931>] ? genl_bind+0x142/0x15e
[   18.724550]  [<ffffffff810b56db>] warn_slowpath_null+0x23/0x2c
[   18.725663]  [<ffffffff8174d931>] genl_bind+0x142/0x15e
[   18.726622]  [<ffffffff8174ab86>] netlink_bind+0x155/0x2ce
[   18.727682]  [<ffffffff8170e512>] SyS_bind+0xc1/0x117
[   18.728698]  [<ffffffff81769058>] ? _raw_spin_unlock+0x38/0x50
[   18.729899]  [<ffffffff8114553f>] ? context_tracking_user_exit+0xe2/0x101
[   18.731204]  [<ffffffff810eafbd>] ? trace_hardirqs_on+0x1b/0x24
[   18.732410]  [<ffffffff8176a2e7>] system_call_fastpath+0x12/0x17
[   18.733596] ---[ end trace f8ae22d84a926b6f ]---
[   18.734551] ------------[ cut here ]------------
[   18.735520] WARNING: CPU: 0 PID: 109 at net/netlink/genetlink.c:1011 gen=
l_bind+0x142/0x15e()
[   18.737558] CPU: 0 PID: 109 Comm: trinity-main Tainted: G        W      =
3.18.0-11169-gc380d9a #9
[   18.739286]  0000000000000009 ffff88000b44fdd8 ffffffff8175b593 ffff8800=
0b44fe18
[   18.740868]  ffffffff810b55aa 000000000000000f ffffffff8174d931 ffffffff=
834a3400
[   18.742454]  000000000000000f 0000000000000000 0000000000000000 ffff8800=
0b44fe28
[   18.744091] Call Trace:
[   18.744620]  [<ffffffff8175b593>] dump_stack+0x2e/0x3e
[   18.745624]  [<ffffffff810b55aa>] warn_slowpath_common+0xb6/0xe5
[   18.746868]  [<ffffffff8174d931>] ? genl_bind+0x142/0x15e
[   18.748001]  [<ffffffff810b56db>] warn_slowpath_null+0x23/0x2c
[   18.749189]  [<ffffffff8174d931>] genl_bind+0x142/0x15e
[   18.750305]  [<ffffffff8174ab86>] netlink_bind+0x155/0x2ce
[   18.751467]  [<ffffffff8170e512>] SyS_bind+0xc1/0x117
[   18.752562]  [<ffffffff81769058>] ? _raw_spin_unlock+0x38/0x50
[   18.753734]  [<ffffffff8114553f>] ? context_tracking_user_exit+0xe2/0x101
[   18.755094]  [<ffffffff810eafbd>] ? trace_hardirqs_on+0x1b/0x24
[   18.756312]  [<ffffffff8176a2e7>] system_call_fastpath+0x12/0x17
[   18.757555] ---[ end trace f8ae22d84a926b70 ]---
[   18.758524] ------------[ cut here ]------------
[   18.759506] WARNING: CPU: 0 PID: 109 at net/netlink/genetlink.c:1011 gen=
l_bind+0x142/0x15e()
[   18.761646] CPU: 0 PID: 109 Comm: trinity-main Tainted: G        W      =
3.18.0-11169-gc380d9a #9
[   18.763508]  0000000000000009 ffff88000b44fdd8 ffffffff8175b593 ffff8800=
0b44fe18
[   18.765115]  ffffffff810b55aa 0000000000000011 ffffffff8174d931 ffffffff=
834a3400
[   18.766721]  0000000000000011 0000000000000000 0000000000000000 ffff8800=
0b44fe28
[   18.768479] Call Trace:
[   18.768974]  [<ffffffff8175b593>] dump_stack+0x2e/0x3e
[   18.770001]  [<ffffffff810b55aa>] warn_slowpath_common+0xb6/0xe5
[   18.771230]  [<ffffffff8174d931>] ? genl_bind+0x142/0x15e
[   18.772361]  [<ffffffff810b56db>] warn_slowpath_null+0x23/0x2c
[   18.773524]  [<ffffffff8174d931>] genl_bind+0x142/0x15e
[   18.774536]  [<ffffffff8174ab86>] netlink_bind+0x155/0x2ce
[   18.775692]  [<ffffffff8170e512>] SyS_bind+0xc1/0x117
[   18.776737]  [<ffffffff81769058>] ? _raw_spin_unlock+0x38/0x50
[   18.777925]  [<ffffffff8114553f>] ? context_tracking_user_exit+0xe2/0x101
[   18.779289]  [<ffffffff810eafbd>] ? trace_hardirqs_on+0x1b/0x24
[   18.780524]  [<ffffffff8176a2e7>] system_call_fastpath+0x12/0x17
[   18.781752] ---[ end trace f8ae22d84a926b71 ]---
[   18.782658] ------------[ cut here ]------------
[   18.783610] WARNING: CPU: 0 PID: 109 at net/netlink/genetlink.c:1011 gen=
l_bind+0x142/0x15e()
[   18.785647] CPU: 0 PID: 109 Comm: trinity-main Tainted: G        W      =
3.18.0-11169-gc380d9a #9
[   18.787400]  0000000000000009 ffff88000b44fdd8 ffffffff8175b593 ffff8800=
0b44fe18
[   18.789041]  ffffffff810b55aa 0000000000000012 ffffffff8174d931 ffffffff=
834a3400
[   18.790622]  0000000000000012 0000000000000000 0000000000000000 ffff8800=
0b44fe28
[   18.792254] Call Trace:
[   18.792745]  [<ffffffff8175b593>] dump_stack+0x2e/0x3e
[   18.793846]  [<ffffffff810b55aa>] warn_slowpath_common+0xb6/0xe5
[   18.794986]  [<ffffffff8174d931>] ? genl_bind+0x142/0x15e
[   18.796115]  [<ffffffff810b56db>] warn_slowpath_null+0x23/0x2c
[   18.797275]  [<ffffffff8174d931>] genl_bind+0x142/0x15e
[   18.798322]  [<ffffffff8174ab86>] netlink_bind+0x155/0x2ce
[   18.799449]  [<ffffffff8170e512>] SyS_bind+0xc1/0x117
[   18.800510]  [<ffffffff81769058>] ? _raw_spin_unlock+0x38/0x50
[   18.801678]  [<ffffffff8114553f>] ? context_tracking_user_exit+0xe2/0x101
[   18.802986]  [<ffffffff810eafbd>] ? trace_hardirqs_on+0x1b/0x24
[   18.804221]  [<ffffffff8176a2e7>] system_call_fastpath+0x12/0x17
[   18.805408] ---[ end trace f8ae22d84a926b72 ]---
[   18.806151] ------------[ cut here ]------------
[   18.806888] WARNING: CPU: 0 PID: 109 at net/netlink/genetlink.c:1011 gen=
l_bind+0x142/0x15e()
[   18.808459] CPU: 0 PID: 109 Comm: trinity-main Tainted: G        W      =
3.18.0-11169-gc380d9a #9
[   18.809896]  0000000000000009 ffff88000b44fdd8 ffffffff8175b593 ffff8800=
0b44fe18
[   18.811127]  ffffffff810b55aa 0000000000000014 ffffffff8174d931 ffffffff=
834a3400
[   18.812401]  0000000000000014 0000000000000000 0000000000000000 ffff8800=
0b44fe28
[   18.813692] Call Trace:
[   18.814089]  [<ffffffff8175b593>] dump_stack+0x2e/0x3e
[   18.814901]  [<ffffffff810b55aa>] warn_slowpath_common+0xb6/0xe5
[   18.815827]  [<ffffffff8174d931>] ? genl_bind+0x142/0x15e
[   18.816746]  [<ffffffff810b56db>] warn_slowpath_null+0x23/0x2c
[   18.817725]  [<ffffffff8174d931>] genl_bind+0x142/0x15e
[   18.818546]  [<ffffffff8174ab86>] netlink_bind+0x155/0x2ce
[   18.819407]  [<ffffffff8170e512>] SyS_bind+0xc1/0x117
[   18.820254]  [<ffffffff81769058>] ? _raw_spin_unlock+0x38/0x50
[   18.821170]  [<ffffffff8114553f>] ? context_tracking_user_exit+0xe2/0x101
[   18.822215]  [<ffffffff810eafbd>] ? trace_hardirqs_on+0x1b/0x24
[   18.823161]  [<ffffffff8176a2e7>] system_call_fastpath+0x12/0x17
[   18.824157] ---[ end trace f8ae22d84a926b73 ]---
[   18.825047] ------------[ cut here ]------------
[   18.825886] WARNING: CPU: 0 PID: 109 at net/netlink/genetlink.c:1011 gen=
l_bind+0x142/0x15e()
[   18.827657] CPU: 0 PID: 109 Comm: trinity-main Tainted: G        W      =
3.18.0-11169-gc380d9a #9
[   18.829295]  0000000000000009 ffff88000b44fdd8 ffffffff8175b593 ffff8800=
0b44fe18
[   18.830698]  ffffffff810b55aa 0000000000000016 ffffffff8174d931 ffffffff=
834a3400
[   18.831863]  0000000000000016 0000000000000000 0000000000000000 ffff8800=
0b44fe28
[   18.833322] Call Trace:
[   18.833692]  [<ffffffff8175b593>] dump_stack+0x2e/0x3e
[   18.834502]  [<ffffffff810b55aa>] warn_slowpath_common+0xb6/0xe5
[   18.835553]  [<ffffffff8174d931>] ? genl_bind+0x142/0x15e
[   18.836612]  [<ffffffff810b56db>] warn_slowpath_null+0x23/0x2c
[   18.837696]  [<ffffffff8174d931>] genl_bind+0x142/0x15e
[   18.838656]  [<ffffffff8174ab86>] netlink_bind+0x155/0x2ce
[   18.839705]  [<ffffffff8170e512>] SyS_bind+0xc1/0x117
[   18.840898]  [<ffffffff81769058>] ? _raw_spin_unlock+0x38/0x50
[   18.842262]  [<ffffffff8114553f>] ? context_tracking_user_exit+0xe2/0x101
[   18.843841]  [<ffffffff810eafbd>] ? trace_hardirqs_on+0x1b/0x24
[   18.845289]  [<ffffffff8176a2e7>] system_call_fastpath+0x12/0x17
[   18.846702] ---[ end trace f8ae22d84a926b74 ]---
[   18.847818] ------------[ cut here ]------------
[   18.848951] WARNING: CPU: 0 PID: 109 at net/netlink/genetlink.c:1011 gen=
l_bind+0x142/0x15e()
[   18.851316] CPU: 0 PID: 109 Comm: trinity-main Tainted: G        W      =
3.18.0-11169-gc380d9a #9
[   18.854781]  0000000000000009 ffff88000b44fdd8 ffffffff8175b593 ffff8800=
0b44fe18
[   18.857904]  ffffffff810b55aa 0000000000000017 ffffffff8174d931 ffffffff=
834a3400
[   18.860907]  0000000000000017 0000000000000000 0000000000000000 ffff8800=
0b44fe28
[   18.864063] Call Trace:
[   18.865079]  [<ffffffff8175b593>] dump_stack+0x2e/0x3e
[   18.867108]  [<ffffffff810b55aa>] warn_slowpath_common+0xb6/0xe5
[   18.869412]  [<ffffffff8174d931>] ? genl_bind+0x142/0x15e
[   18.871471]  [<ffffffff810b56db>] warn_slowpath_null+0x23/0x2c
[   18.873611]  [<ffffffff8174d931>] genl_bind+0x142/0x15e
[   18.875568]  [<ffffffff8174ab86>] netlink_bind+0x155/0x2ce
[   18.877620]  [<ffffffff8170e512>] SyS_bind+0xc1/0x117
[   18.879555]  [<ffffffff81769058>] ? _raw_spin_unlock+0x38/0x50
[   18.881670]  [<ffffffff8114553f>] ? context_tracking_user_exit+0xe2/0x101
[   18.884260]  [<ffffffff810eafbd>] ? trace_hardirqs_on+0x1b/0x24
[   18.886380]  [<ffffffff8176a2e7>] system_call_fastpath+0x12/0x17
[   18.888639] ---[ end trace f8ae22d84a926b75 ]---
[   18.907052] ------------[ cut here ]------------
[   18.907961] WARNING: CPU: 0 PID: 109 at net/netlink/genetlink.c:1011 gen=
l_bind+0x142/0x15e()
[   18.909922] CPU: 0 PID: 109 Comm: trinity-main Tainted: G        W      =
3.18.0-11169-gc380d9a #9
[   18.911638]  0000000000000009 ffff88000b44fdd8 ffffffff8175b593 ffff8800=
0b44fe18
[   18.913188]  ffffffff810b55aa 0000000000000000 ffffffff8174d931 ffffffff=
834a3400
[   18.914823]  0000000000000000 0000000000000000 0000000000000000 ffff8800=
0b44fe28
[   18.916389] Call Trace:
[   18.916892]  [<ffffffff8175b593>] dump_stack+0x2e/0x3e
[   18.917870]  [<ffffffff810b55aa>] warn_slowpath_common+0xb6/0xe5
[   18.919016]  [<ffffffff8174d931>] ? genl_bind+0x142/0x15e
[   18.920101]  [<ffffffff810b56db>] warn_slowpath_null+0x23/0x2c
[   18.921251]  [<ffffffff8174d931>] genl_bind+0x142/0x15e
[   18.922303]  [<ffffffff8174ab86>] netlink_bind+0x155/0x2ce
[   18.923344]  [<ffffffff8170e512>] SyS_bind+0xc1/0x117
[   18.924322]  [<ffffffff81769058>] ? _raw_spin_unlock+0x38/0x50
[   18.925211]  [<ffffffff8114553f>] ? context_tracking_user_exit+0xe2/0x101
[   18.926486]  [<ffffffff810eafbd>] ? trace_hardirqs_on+0x1b/0x24
[   18.927577]  [<ffffffff8176a2e7>] system_call_fastpath+0x12/0x17
[   18.928454] ---[ end trace f8ae22d84a926b76 ]---
[   18.929307] ------------[ cut here ]------------
[   18.930049] WARNING: CPU: 0 PID: 109 at net/netlink/genetlink.c:1011 gen=
l_bind+0x142/0x15e()
[   18.931656] CPU: 0 PID: 109 Comm: trinity-main Tainted: G        W      =
3.18.0-11169-gc380d9a #9
[   18.933059]  0000000000000009 ffff88000b44fdd8 ffffffff8175b593 ffff8800=
0b44fe18
[   18.934321]  ffffffff810b55aa 0000000000000006 ffffffff8174d931 ffffffff=
834a3400
[   18.935568]  0000000000000006 0000000000000000 0000000000000000 ffff8800=
0b44fe28
[   18.936836] Call Trace:
[   18.937241]  [<ffffffff8175b593>] dump_stack+0x2e/0x3e
[   18.938053]  [<ffffffff810b55aa>] warn_slowpath_common+0xb6/0xe5
[   18.939001]  [<ffffffff8174d931>] ? genl_bind+0x142/0x15e
[   18.939860]  [<ffffffff810b56db>] warn_slowpath_null+0x23/0x2c
[   18.940803]  [<ffffffff8174d931>] genl_bind+0x142/0x15e
[   18.941635]  [<ffffffff8174ab86>] netlink_bind+0x155/0x2ce
[   18.942501]  [<ffffffff8170e512>] SyS_bind+0xc1/0x117
[   18.943325]  [<ffffffff81769058>] ? _raw_spin_unlock+0x38/0x50
[   18.944493]  [<ffffffff8114553f>] ? context_tracking_user_exit+0xe2/0x101
[   18.945822]  [<ffffffff810eafbd>] ? trace_hardirqs_on+0x1b/0x24
[   18.946979]  [<ffffffff8176a2e7>] system_call_fastpath+0x12/0x17
[   18.948171] ---[ end trace f8ae22d84a926b77 ]---
[   18.949106] ------------[ cut here ]------------
[   18.950028] WARNING: CPU: 0 PID: 109 at net/netlink/genetlink.c:1011 gen=
l_bind+0x142/0x15e()
[   18.951971] CPU: 0 PID: 109 Comm: trinity-main Tainted: G        W      =
3.18.0-11169-gc380d9a #9
[   18.953702]  0000000000000009 ffff88000b44fdd8 ffffffff8175b593 ffff8800=
0b44fe18
[   18.955284]  ffffffff810b55aa 0000000000000008 ffffffff8174d931 ffffffff=
834a3400
[   18.956850]  0000000000000008 0000000000000000 0000000000000000 ffff8800=
0b44fe28
[   18.958410] Call Trace:
[   18.958907]  [<ffffffff8175b593>] dump_stack+0x2e/0x3e
[   18.959924]  [<ffffffff810b55aa>] warn_slowpath_common+0xb6/0xe5
[   18.961125]  [<ffffffff8174d931>] ? genl_bind+0x142/0x15e
[   18.962265]  [<ffffffff810b56db>] warn_slowpath_null+0x23/0x2c
[   18.963493]  [<ffffffff8174d931>] genl_bind+0x142/0x15e
[   18.964616]  [<ffffffff8174ab86>] netlink_bind+0x155/0x2ce
[   18.965752]  [<ffffffff8170e512>] SyS_bind+0xc1/0x117
[   18.966818]  [<ffffffff81769058>] ? _raw_spin_unlock+0x38/0x50
[   18.968056]  [<ffffffff8114553f>] ? context_tracking_user_exit+0xe2/0x101
[   18.969466]  [<ffffffff810eafbd>] ? trace_hardirqs_on+0x1b/0x24
[   18.970707]  [<ffffffff8176a2e7>] system_call_fastpath+0x12/0x17
[   18.971962] ---[ end trace f8ae22d84a926b78 ]---
[   18.972954] ------------[ cut here ]------------
[   18.973928] WARNING: CPU: 0 PID: 109 at net/netlink/genetlink.c:1011 gen=
l_bind+0x142/0x15e()
[   18.976025] CPU: 0 PID: 109 Comm: trinity-main Tainted: G        W      =
3.18.0-11169-gc380d9a #9
[   18.977860]  0000000000000009 ffff88000b44fdd8 ffffffff8175b593 ffff8800=
0b44fe18
[   18.979506]  ffffffff810b55aa 000000000000000c ffffffff8174d931 ffffffff=
834a3400
[   18.981188]  000000000000000c 0000000000000000 0000000000000000 ffff8800=
0b44fe28
[   18.982857] Call Trace:
[   18.983402]  [<ffffffff8175b593>] dump_stack+0x2e/0x3e
[   18.984498]  [<ffffffff810b55aa>] warn_slowpath_common+0xb6/0xe5
[   18.985765]  [<ffffffff8174d931>] ? genl_bind+0x142/0x15e
[   18.986909]  [<ffffffff810b56db>] warn_slowpath_null+0x23/0x2c
[   18.988147]  [<ffffffff8174d931>] genl_bind+0x142/0x15e
[   18.989237]  [<ffffffff8174ab86>] netlink_bind+0x155/0x2ce
[   18.990402]  [<ffffffff8170e512>] SyS_bind+0xc1/0x117
[   18.991471]  [<ffffffff81769058>] ? _raw_spin_unlock+0x38/0x50
[   18.992731]  [<ffffffff8114553f>] ? context_tracking_user_exit+0xe2/0x101
[   18.994146]  [<ffffffff810eafbd>] ? trace_hardirqs_on+0x1b/0x24
[   18.995387]  [<ffffffff8176a2e7>] system_call_fastpath+0x12/0x17
[   18.996668] ---[ end trace f8ae22d84a926b79 ]---
[   18.997675] ------------[ cut here ]------------
[   18.998660] WARNING: CPU: 0 PID: 109 at net/netlink/genetlink.c:1011 gen=
l_bind+0x142/0x15e()
[   19.000728] CPU: 0 PID: 109 Comm: trinity-main Tainted: G        W      =
3.18.0-11169-gc380d9a #9
[   19.002496]  0000000000000009 ffff88000b44fdd8 ffffffff8175b593 ffff8800=
0b44fe18
[   19.004170]  ffffffff810b55aa 000000000000000f ffffffff8174d931 ffffffff=
834a3400
[   19.005815]  000000000000000f 0000000000000000 0000000000000000 ffff8800=
0b44fe28
[   19.007493] Call Trace:
[   19.008045]  [<ffffffff8175b593>] dump_stack+0x2e/0x3e
[   19.009131]  [<ffffffff810b55aa>] warn_slowpath_common+0xb6/0xe5
[   19.010395]  [<ffffffff8174d931>] ? genl_bind+0x142/0x15e
[   19.011528]  [<ffffffff810b56db>] warn_slowpath_null+0x23/0x2c
[   19.012776]  [<ffffffff8174d931>] genl_bind+0x142/0x15e
[   19.013873]  [<ffffffff8174ab86>] netlink_bind+0x155/0x2ce
[   19.015024]  [<ffffffff8170e512>] SyS_bind+0xc1/0x117
[   19.016112]  [<ffffffff81769058>] ? _raw_spin_unlock+0x38/0x50
[   19.017349]  [<ffffffff8114553f>] ? context_tracking_user_exit+0xe2/0x101
[   19.018775]  [<ffffffff810eafbd>] ? trace_hardirqs_on+0x1b/0x24
[   19.020037]  [<ffffffff8176a2e7>] system_call_fastpath+0x12/0x17
[   19.021300] ---[ end trace f8ae22d84a926b7a ]---
[   19.022310] ------------[ cut here ]------------
[   19.023278] WARNING: CPU: 0 PID: 109 at net/netlink/genetlink.c:1011 gen=
l_bind+0x142/0x15e()
[   19.025354] CPU: 0 PID: 109 Comm: trinity-main Tainted: G        W      =
3.18.0-11169-gc380d9a #9
[   19.027179]  0000000000000009 ffff88000b44fdd8 ffffffff8175b593 ffff8800=
0b44fe18
[   19.028865]  ffffffff810b55aa 0000000000000012 ffffffff8174d931 ffffffff=
834a3400
[   19.030516]  0000000000000012 0000000000000000 0000000000000000 ffff8800=
0b44fe28
[   19.032183] Call Trace:
[   19.032724]  [<ffffffff8175b593>] dump_stack+0x2e/0x3e
[   19.033808]  [<ffffffff810b55aa>] warn_slowpath_common+0xb6/0xe5
[   19.035072]  [<ffffffff8174d931>] ? genl_bind+0x142/0x15e
[   19.036228]  [<ffffffff810b56db>] warn_slowpath_null+0x23/0x2c
[   19.037455]  [<ffffffff8174d931>] genl_bind+0x142/0x15e
[   19.038552]  [<ffffffff8174ab86>] netlink_bind+0x155/0x2ce
[   19.039708]  [<ffffffff8170e512>] SyS_bind+0xc1/0x117
[   19.040784]  [<ffffffff81769058>] ? _raw_spin_unlock+0x38/0x50
[   19.042008]  [<ffffffff8114553f>] ? context_tracking_user_exit+0xe2/0x101
[   19.043444]  [<ffffffff810eafbd>] ? trace_hardirqs_on+0x1b/0x24
[   19.044692]  [<ffffffff8176a2e7>] system_call_fastpath+0x12/0x17
[   19.045961] ---[ end trace f8ae22d84a926b7b ]---
[   19.046957] ------------[ cut here ]------------
[   19.047940] WARNING: CPU: 0 PID: 109 at net/netlink/genetlink.c:1011 gen=
l_bind+0x142/0x15e()
[   19.050042] CPU: 0 PID: 109 Comm: trinity-main Tainted: G        W      =
3.18.0-11169-gc380d9a #9
[   19.051864]  0000000000000009 ffff88000b44fdd8 ffffffff8175b593 ffff8800=
0b44fe18
[   19.053547]  ffffffff810b55aa 0000000000000013 ffffffff8174d931 ffffffff=
834a3400
[   19.055222]  0000000000000013 0000000000000000 0000000000000000 ffff8800=
0b44fe28
[   19.056899] Call Trace:
[   19.057432]  [<ffffffff8175b593>] dump_stack+0x2e/0x3e
[   19.058462]  [<ffffffff810b55aa>] warn_slowpath_common+0xb6/0xe5
[   19.059730]  [<ffffffff8174d931>] ? genl_bind+0x142/0x15e
[   19.060906]  [<ffffffff810b56db>] warn_slowpath_null+0x23/0x2c
[   19.062128]  [<ffffffff8174d931>] genl_bind+0x142/0x15e
[   19.063244]  [<ffffffff8174ab86>] netlink_bind+0x155/0x2ce
[   19.064420]  [<ffffffff8170e512>] SyS_bind+0xc1/0x117
[   19.065484]  [<ffffffff81769058>] ? _raw_spin_unlock+0x38/0x50
[   19.066669]  [<ffffffff8114553f>] ? context_tracking_user_exit+0xe2/0x101
[   19.068120]  [<ffffffff810eafbd>] ? trace_hardirqs_on+0x1b/0x24
[   19.069390]  [<ffffffff8176a2e7>] system_call_fastpath+0x12/0x17
[   19.070598] ---[ end trace f8ae22d84a926b7c ]---
[   19.071546] ------------[ cut here ]------------
[   19.072497] WARNING: CPU: 0 PID: 109 at net/netlink/genetlink.c:1011 gen=
l_bind+0x142/0x15e()
[   19.074433] CPU: 0 PID: 109 Comm: trinity-main Tainted: G        W      =
3.18.0-11169-gc380d9a #9
[   19.076210]  0000000000000009 ffff88000b44fdd8 ffffffff8175b593 ffff8800=
0b44fe18
[   19.077755]  ffffffff810b55aa 0000000000000017 ffffffff8174d931 ffffffff=
834a3400
[   19.079303]  0000000000000017 0000000000000000 0000000000000000 ffff8800=
0b44fe28
[   19.080909] Call Trace:
[   19.081391]  [<ffffffff8175b593>] dump_stack+0x2e/0x3e
[   19.082392]  [<ffffffff810b55aa>] warn_slowpath_common+0xb6/0xe5
[   19.083596]  [<ffffffff8174d931>] ? genl_bind+0x142/0x15e
[   19.084691]  [<ffffffff810b56db>] warn_slowpath_null+0x23/0x2c
[   19.085837]  [<ffffffff8174d931>] genl_bind+0x142/0x15e
[   19.086965]  [<ffffffff8174ab86>] netlink_bind+0x155/0x2ce
[   19.088085]  [<ffffffff8170e512>] SyS_bind+0xc1/0x117
[   19.089106]  [<ffffffff81769058>] ? _raw_spin_unlock+0x38/0x50
[   19.090230]  [<ffffffff8114553f>] ? context_tracking_user_exit+0xe2/0x101
[   19.091595]  [<ffffffff810eafbd>] ? trace_hardirqs_on+0x1b/0x24
[   19.092806]  [<ffffffff8176a2e7>] system_call_fastpath+0x12/0x17
[   19.093980] ---[ end trace f8ae22d84a926b7d ]---
[   19.538986] ------------[ cut here ]------------
[   19.539567] WARNING: CPU: 0 PID: 109 at net/netlink/genetlink.c:1040 gen=
l_unbind+0x133/0x142()
[   19.540710] CPU: 0 PID: 109 Comm: trinity-main Tainted: G        W      =
3.18.0-11169-gc380d9a #9
[   19.541698]  0000000000000009 ffff88000b44fd38 ffffffff8175b593 ffff8800=
0b44fd78
[   19.542581]  ffffffff810b55aa 0000000000000001 ffffffff8174d7e0 ffffffff=
834a3400
[   19.543481]  0000000000000001 0000000000000000 ffff88001202a520 ffff8800=
0b44fd88
[   19.544373] Call Trace:
[   19.544665]  [<ffffffff8175b593>] dump_stack+0x2e/0x3e
[   19.545257]  [<ffffffff810b55aa>] warn_slowpath_common+0xb6/0xe5
[   19.545930]  [<ffffffff8174d7e0>] ? genl_unbind+0x133/0x142
[   19.546544]  [<ffffffff810b56db>] warn_slowpath_null+0x23/0x2c
[   19.547195]  [<ffffffff8174d7e0>] genl_unbind+0x133/0x142
[   19.547804]  [<ffffffff8174b063>] netlink_release+0x364/0x3fd
[   19.548463]  [<ffffffff8170d262>] sock_release+0x23/0xa3
[   19.549072]  [<ffffffff8170d2f6>] sock_close+0x14/0x1f
[   19.549646]  [<ffffffff81199c9f>] __fput+0x16c/0x28e
[   19.550232]  [<ffffffff81199dd1>] ____fput+0x10/0x19
[   19.550793]  [<ffffffff810d1d20>] task_work_run+0xc7/0x116
[   19.551405]  [<ffffffff810b7e57>] do_exit+0x550/0xd1f
[   19.551950]  [<ffffffff8114553f>] ? context_tracking_user_exit+0xe2/0x101
[   19.552710]  [<ffffffff810b8776>] do_group_exit+0x107/0x127
[   19.553359]  [<ffffffff810b87ac>] SyS_exit_group+0x16/0x16
[   19.553982]  [<ffffffff8176a2e7>] system_call_fastpath+0x12/0x17
[   19.554654] ---[ end trace f8ae22d84a926b7e ]---
[   19.555248] ------------[ cut here ]------------
[   19.555777] WARNING: CPU: 0 PID: 109 at net/netlink/genetlink.c:1040 gen=
l_unbind+0x133/0x142()
[   19.556927] CPU: 0 PID: 109 Comm: trinity-main Tainted: G        W      =
3.18.0-11169-gc380d9a #9
[   19.557915]  0000000000000009 ffff88000b44fd38 ffffffff8175b593 ffff8800=
0b44fd78
[   19.558799]  ffffffff810b55aa 0000000000000004 ffffffff8174d7e0 ffffffff=
834a3400
[   19.559700]  0000000000000004 0000000000000000 ffff88001202a520 ffff8800=
0b44fd88
[   19.560613] Call Trace:
[   19.560895]  [<ffffffff8175b593>] dump_stack+0x2e/0x3e
[   19.561463]  [<ffffffff810b55aa>] warn_slowpath_common+0xb6/0xe5
[   19.562117]  [<ffffffff8174d7e0>] ? genl_unbind+0x133/0x142
[   19.562699]  [<ffffffff810b56db>] warn_slowpath_null+0x23/0x2c
[   19.563344]  [<ffffffff8174d7e0>] genl_unbind+0x133/0x142
[   19.563943]  [<ffffffff8174b063>] netlink_release+0x364/0x3fd
[   19.564573]  [<ffffffff8170d262>] sock_release+0x23/0xa3
[   19.565185]  [<ffffffff8170d2f6>] sock_close+0x14/0x1f
[   19.566160]  [<ffffffff81199c9f>] __fput+0x16c/0x28e
[   19.567133]  [<ffffffff81199dd1>] ____fput+0x10/0x19
[   19.568101]  [<ffffffff810d1d20>] task_work_run+0xc7/0x116
[   19.569125]  [<ffffffff810b7e57>] do_exit+0x550/0xd1f
[   19.570108]  [<ffffffff8114553f>] ? context_tracking_user_exit+0xe2/0x101
[   19.571365]  [<ffffffff810b8776>] do_group_exit+0x107/0x127
[   19.572438]  [<ffffffff810b87ac>] SyS_exit_group+0x16/0x16
[   19.573392]  [<ffffffff8176a2e7>] system_call_fastpath+0x12/0x17
[   19.574453] ---[ end trace f8ae22d84a926b7f ]---
[   19.575366] ------------[ cut here ]------------
[   19.576307] WARNING: CPU: 0 PID: 109 at net/netlink/genetlink.c:1040 gen=
l_unbind+0x133/0x142()
[   19.578651] CPU: 0 PID: 109 Comm: trinity-main Tainted: G        W      =
3.18.0-11169-gc380d9a #9
[   19.580405]  0000000000000009 ffff88000b44fd38 ffffffff8175b593 ffff8800=
0b44fd78
[   19.581944]  ffffffff810b55aa 0000000000000005 ffffffff8174d7e0 ffffffff=
834a3400
[   19.583833]  0000000000000005 0000000000000000 ffff88001202a520 ffff8800=
0b44fd88
[   19.585700] Call Trace:
[   19.586342]  [<ffffffff8175b593>] dump_stack+0x2e/0x3e
[   19.587626]  [<ffffffff810b55aa>] warn_slowpath_common+0xb6/0xe5
[   19.589066]  [<ffffffff8174d7e0>] ? genl_unbind+0x133/0x142
[   19.590410]  [<ffffffff810b56db>] warn_slowpath_null+0x23/0x2c
[   19.591776]  [<ffffffff8174d7e0>] genl_unbind+0x133/0x142
[   19.593120]  [<ffffffff8174b063>] netlink_release+0x364/0x3fd
[   19.594466]  [<ffffffff8170d262>] sock_release+0x23/0xa3
[   19.595752]  [<ffffffff8170d2f6>] sock_close+0x14/0x1f
[   19.596989]  [<ffffffff81199c9f>] __fput+0x16c/0x28e
[   19.598159]  [<ffffffff81199dd1>] ____fput+0x10/0x19
[   19.599363]  [<ffffffff810d1d20>] task_work_run+0xc7/0x116
[   19.600668]  [<ffffffff810b7e57>] do_exit+0x550/0xd1f
[   19.601899]  [<ffffffff8114553f>] ? context_tracking_user_exit+0xe2/0x101
[   19.603480]  [<ffffffff810b8776>] do_group_exit+0x107/0x127
[   19.604851]  [<ffffffff810b87ac>] SyS_exit_group+0x16/0x16
[   19.606138]  [<ffffffff8176a2e7>] system_call_fastpath+0x12/0x17
[   19.607562] ---[ end trace f8ae22d84a926b80 ]---
[   19.608796] ------------[ cut here ]------------
[   19.609885] WARNING: CPU: 0 PID: 109 at net/netlink/genetlink.c:1040 gen=
l_unbind+0x133/0x142()
[   19.612320] CPU: 0 PID: 109 Comm: trinity-main Tainted: G        W      =
3.18.0-11169-gc380d9a #9
[   19.614368]  0000000000000009 ffff88000b44fd38 ffffffff8175b593 ffff8800=
0b44fd78
[   19.616270]  ffffffff810b55aa 0000000000000006 ffffffff8174d7e0 ffffffff=
834a3400
[   19.618127]  0000000000000006 0000000000000000 ffff88001202a520 ffff8800=
0b44fd88
[   19.619983] Call Trace:
[   19.620643]  [<ffffffff8175b593>] dump_stack+0x2e/0x3e
[   19.621833]  [<ffffffff810b55aa>] warn_slowpath_common+0xb6/0xe5
[   19.623269]  [<ffffffff8174d7e0>] ? genl_unbind+0x133/0x142
[   19.624598]  [<ffffffff810b56db>] warn_slowpath_null+0x23/0x2c
[   19.626002]  [<ffffffff8174d7e0>] genl_unbind+0x133/0x142
[   19.627294]  [<ffffffff8174b063>] netlink_release+0x364/0x3fd
[   19.628704]  [<ffffffff8170d262>] sock_release+0x23/0xa3
[   19.629948]  [<ffffffff8170d2f6>] sock_close+0x14/0x1f
[   19.631151]  [<ffffffff81199c9f>] __fput+0x16c/0x28e
[   19.632358]  [<ffffffff81199dd1>] ____fput+0x10/0x19
[   19.633556]  [<ffffffff810d1d20>] task_work_run+0xc7/0x116
[   19.634873]  [<ffffffff810b7e57>] do_exit+0x550/0xd1f
[   19.636087]  [<ffffffff8114553f>] ? context_tracking_user_exit+0xe2/0x101
[   19.637692]  [<ffffffff810b8776>] do_group_exit+0x107/0x127
[   19.639002]  [<ffffffff810b87ac>] SyS_exit_group+0x16/0x16
[   19.640341]  [<ffffffff8176a2e7>] system_call_fastpath+0x12/0x17
[   19.641783] ---[ end trace f8ae22d84a926b81 ]---
[   19.642956] ------------[ cut here ]------------
[   19.644129] WARNING: CPU: 0 PID: 109 at net/netlink/genetlink.c:1040 gen=
l_unbind+0x133/0x142()
[   19.646634] CPU: 0 PID: 109 Comm: trinity-main Tainted: G        W      =
3.18.0-11169-gc380d9a #9
[   19.648769]  0000000000000009 ffff88000b44fd38 ffffffff8175b593 ffff8800=
0b44fd78
[   19.650625]  ffffffff810b55aa 0000000000000007 ffffffff8174d7e0 ffffffff=
834a3400
[   19.652504]  0000000000000007 0000000000000000 ffff88001202a520 ffff8800=
0b44fd88
[   19.654364] Call Trace:
[   19.654959]  [<ffffffff8175b593>] dump_stack+0x2e/0x3e
[   19.656229]  [<ffffffff810b55aa>] warn_slowpath_common+0xb6/0xe5
[   19.657636]  [<ffffffff8174d7e0>] ? genl_unbind+0x133/0x142
[   19.658972]  [<ffffffff810b56db>] warn_slowpath_null+0x23/0x2c
[   19.660380]  [<ffffffff8174d7e0>] genl_unbind+0x133/0x142
[   19.661658]  [<ffffffff8174b063>] netlink_release+0x364/0x3fd
[   19.663020]  [<ffffffff8170d262>] sock_release+0x23/0xa3
[   19.664339]  [<ffffffff8170d2f6>] sock_close+0x14/0x1f
[   19.665571]  [<ffffffff81199c9f>] __fput+0x16c/0x28e
[   19.666757]  [<ffffffff81199dd1>] ____fput+0x10/0x19
[   19.667946]  [<ffffffff810d1d20>] task_work_run+0xc7/0x116
[   19.669253]  [<ffffffff810b7e57>] do_exit+0x550/0xd1f
[   19.670492]  [<ffffffff8114553f>] ? context_tracking_user_exit+0xe2/0x101
[   19.672099]  [<ffffffff810b8776>] do_group_exit+0x107/0x127
[   19.673827]  [<ffffffff810b87ac>] SyS_exit_group+0x16/0x16
[   19.674853]  [<ffffffff8176a2e7>] system_call_fastpath+0x12/0x17
[   19.675924] ---[ end trace f8ae22d84a926b82 ]---
[   19.676837] ------------[ cut here ]------------
[   19.677661] WARNING: CPU: 0 PID: 109 at net/netlink/genetlink.c:1040 gen=
l_unbind+0x133/0x142()
[   19.679433] CPU: 0 PID: 109 Comm: trinity-main Tainted: G        W      =
3.18.0-11169-gc380d9a #9
[   19.681052]  0000000000000009 ffff88000b44fd38 ffffffff8175b593 ffff8800=
0b44fd78
[   19.682507]  ffffffff810b55aa 0000000000000008 ffffffff8174d7e0 ffffffff=
834a3400
[   19.683877]  0000000000000008 0000000000000000 ffff88001202a520 ffff8800=
0b44fd88
[   19.685300] Call Trace:
[   19.685742]  [<ffffffff8175b593>] dump_stack+0x2e/0x3e
[   19.686671]  [<ffffffff810b55aa>] warn_slowpath_common+0xb6/0xe5
[   19.687793]  [<ffffffff8174d7e0>] ? genl_unbind+0x133/0x142
[   19.688819]  [<ffffffff810b56db>] warn_slowpath_null+0x23/0x2c
[   19.689827]  [<ffffffff8174d7e0>] genl_unbind+0x133/0x142
[   19.690779]  [<ffffffff8174b063>] netlink_release+0x364/0x3fd
[   19.691815]  [<ffffffff8170d262>] sock_release+0x23/0xa3
[   19.692757]  [<ffffffff8170d2f6>] sock_close+0x14/0x1f
[   19.693641]  [<ffffffff81199c9f>] __fput+0x16c/0x28e
[   19.694522]  [<ffffffff81199dd1>] ____fput+0x10/0x19
[   19.695450]  [<ffffffff810d1d20>] task_work_run+0xc7/0x116
[   19.696477]  [<ffffffff810b7e57>] do_exit+0x550/0xd1f
[   19.697339]  [<ffffffff8114553f>] ? context_tracking_user_exit+0xe2/0x101
[   19.698493]  [<ffffffff810b8776>] do_group_exit+0x107/0x127
[   19.699493]  [<ffffffff810b87ac>] SyS_exit_group+0x16/0x16
[   19.700588]  [<ffffffff8176a2e7>] system_call_fastpath+0x12/0x17
[   19.701731] ---[ end trace f8ae22d84a926b83 ]---
[   19.703156] ------------[ cut here ]------------
[   19.704007] WARNING: CPU: 0 PID: 109 at net/netlink/genetlink.c:1040 gen=
l_unbind+0x133/0x142()
[   19.705927] CPU: 0 PID: 109 Comm: trinity-main Tainted: G        W      =
3.18.0-11169-gc380d9a #9
[   19.707512]  0000000000000009 ffff88000b44fd38 ffffffff8175b593 ffff8800=
0b44fd78
[   19.708926]  ffffffff810b55aa 0000000000000009 ffffffff8174d7e0 ffffffff=
834a3400
[   19.710326]  0000000000000009 0000000000000000 ffff88001202a520 ffff8800=
0b44fd88
[   19.711806] Call Trace:
[   19.712284]  [<ffffffff8175b593>] dump_stack+0x2e/0x3e
[   19.713187]  [<ffffffff810b55aa>] warn_slowpath_common+0xb6/0xe5
[   19.714213]  [<ffffffff8174d7e0>] ? genl_unbind+0x133/0x142
[   19.715180]  [<ffffffff810b56db>] warn_slowpath_null+0x23/0x2c
[   19.716278]  [<ffffffff8174d7e0>] genl_unbind+0x133/0x142
[   19.717290]  [<ffffffff8174b063>] netlink_release+0x364/0x3fd
[   19.718315]  [<ffffffff8170d262>] sock_release+0x23/0xa3
[   19.719233]  [<ffffffff8170d2f6>] sock_close+0x14/0x1f
[   19.720152]  [<ffffffff81199c9f>] __fput+0x16c/0x28e
[   19.721060]  [<ffffffff81199dd1>] ____fput+0x10/0x19
[   19.722012]  [<ffffffff810d1d20>] task_work_run+0xc7/0x116
[   19.722984]  [<ffffffff810b7e57>] do_exit+0x550/0xd1f
[   19.723853]  [<ffffffff8114553f>] ? context_tracking_user_exit+0xe2/0x101
[   19.725053]  [<ffffffff810b8776>] do_group_exit+0x107/0x127
[   19.726068]  [<ffffffff810b87ac>] SyS_exit_group+0x16/0x16
[   19.727076]  [<ffffffff8176a2e7>] system_call_fastpath+0x12/0x17
[   19.728175] ---[ end trace f8ae22d84a926b84 ]---
[   19.729057] ------------[ cut here ]------------
[   19.729846] WARNING: CPU: 0 PID: 109 at net/netlink/genetlink.c:1040 gen=
l_unbind+0x133/0x142()
[   19.731888] CPU: 0 PID: 109 Comm: trinity-main Tainted: G        W      =
3.18.0-11169-gc380d9a #9
[   19.733619]  0000000000000009 ffff88000b44fd38 ffffffff8175b593 ffff8800=
0b44fd78
[   19.735019]  ffffffff810b55aa 000000000000000a ffffffff8174d7e0 ffffffff=
834a3400
[   19.736939]  000000000000000a 0000000000000000 ffff88001202a520 ffff8800=
0b44fd88
[   19.738744] Call Trace:
[   19.739241]  [<ffffffff8175b593>] dump_stack+0x2e/0x3e
[   19.740247]  [<ffffffff810b55aa>] warn_slowpath_common+0xb6/0xe5
[   19.742245]  [<ffffffff8174d7e0>] ? genl_unbind+0x133/0x142
[   19.743286]  [<ffffffff810b56db>] warn_slowpath_null+0x23/0x2c
[   19.744402]  [<ffffffff8174d7e0>] genl_unbind+0x133/0x142
[   19.745392]  [<ffffffff8174b063>] netlink_release+0x364/0x3fd
[   19.746471]  [<ffffffff8170d262>] sock_release+0x23/0xa3
[   19.747459]  [<ffffffff8170d2f6>] sock_close+0x14/0x1f
[   19.748442]  [<ffffffff81199c9f>] __fput+0x16c/0x28e
[   19.749528]  [<ffffffff81199dd1>] ____fput+0x10/0x19
[   19.750467]  [<ffffffff810d1d20>] task_work_run+0xc7/0x116
[   19.751487]  [<ffffffff810b7e57>] do_exit+0x550/0xd1f
[   19.752423]  [<ffffffff8114553f>] ? context_tracking_user_exit+0xe2/0x101
[   19.753749]  [<ffffffff810b8776>] do_group_exit+0x107/0x127
[   19.754769]  [<ffffffff810b87ac>] SyS_exit_group+0x16/0x16
[   19.755791]  [<ffffffff8176a2e7>] system_call_fastpath+0x12/0x17
[   19.756931] ---[ end trace f8ae22d84a926b85 ]---
[   19.757908] ------------[ cut here ]------------
[   19.758863] WARNING: CPU: 0 PID: 109 at net/netlink/genetlink.c:1040 gen=
l_unbind+0x133/0x142()
[   19.760741] CPU: 0 PID: 109 Comm: trinity-main Tainted: G        W      =
3.18.0-11169-gc380d9a #9
[   19.762366]  0000000000000009 ffff88000b44fd38 ffffffff8175b593 ffff8800=
0b44fd78
[   19.763931]  ffffffff810b55aa 000000000000000b ffffffff8174d7e0 ffffffff=
834a3400
[   19.765532]  000000000000000b 0000000000000000 ffff88001202a520 ffff8800=
0b44fd88
[   19.767069] Call Trace:
[   19.767544]  [<ffffffff8175b593>] dump_stack+0x2e/0x3e
[   19.768562]  [<ffffffff810b55aa>] warn_slowpath_common+0xb6/0xe5
[   19.769724]  [<ffffffff8174d7e0>] ? genl_unbind+0x133/0x142
[   19.770732]  [<ffffffff810b56db>] warn_slowpath_null+0x23/0x2c
[   19.771790]  [<ffffffff8174d7e0>] genl_unbind+0x133/0x142
[   19.772834]  [<ffffffff8174b063>] netlink_release+0x364/0x3fd
[   19.773871]  [<ffffffff8170d262>] sock_release+0x23/0xa3
[   19.774846]  [<ffffffff8170d2f6>] sock_close+0x14/0x1f
[   19.775785]  [<ffffffff81199c9f>] __fput+0x16c/0x28e
[   19.776724]  [<ffffffff81199dd1>] ____fput+0x10/0x19
[   19.777707]  [<ffffffff810d1d20>] task_work_run+0xc7/0x116
[   19.778727]  [<ffffffff810b7e57>] do_exit+0x550/0xd1f
[   19.779725]  [<ffffffff8114553f>] ? context_tracking_user_exit+0xe2/0x101
[   19.781039]  [<ffffffff810b8776>] do_group_exit+0x107/0x127
[   19.782060]  [<ffffffff810b87ac>] SyS_exit_group+0x16/0x16
[   19.783059]  [<ffffffff8176a2e7>] system_call_fastpath+0x12/0x17
[   19.784202] ---[ end trace f8ae22d84a926b86 ]---
[   19.785145] ------------[ cut here ]------------
[   19.785865] WARNING: CPU: 0 PID: 109 at net/netlink/genetlink.c:1040 gen=
l_unbind+0x133/0x142()
[   19.787616] CPU: 0 PID: 109 Comm: trinity-main Tainted: G        W      =
3.18.0-11169-gc380d9a #9
[   19.789248]  0000000000000009 ffff88000b44fd38 ffffffff8175b593 ffff8800=
0b44fd78
[   19.790747]  ffffffff810b55aa 000000000000000c ffffffff8174d7e0 ffffffff=
834a3400
[   19.792281]  000000000000000c 0000000000000000 ffff88001202a520 ffff8800=
0b44fd88
[   19.793905] Call Trace:
[   19.794419]  [<ffffffff8175b593>] dump_stack+0x2e/0x3e
[   19.795365]  [<ffffffff810b55aa>] warn_slowpath_common+0xb6/0xe5
[   19.796369]  [<ffffffff8174d7e0>] ? genl_unbind+0x133/0x142
[   19.797274]  [<ffffffff810b56db>] warn_slowpath_null+0x23/0x2c
[   19.798205]  [<ffffffff8174d7e0>] genl_unbind+0x133/0x142
[   19.799001]  [<ffffffff8174b063>] netlink_release+0x364/0x3fd
[   19.799656]  [<ffffffff8170d262>] sock_release+0x23/0xa3
[   19.800281]  [<ffffffff8170d2f6>] sock_close+0x14/0x1f
[   19.800831]  [<ffffffff81199c9f>] __fput+0x16c/0x28e
[   19.801341]  [<ffffffff81199dd1>] ____fput+0x10/0x19
[   19.801884]  [<ffffffff810d1d20>] task_work_run+0xc7/0x116
[   19.802499]  [<ffffffff810b7e57>] do_exit+0x550/0xd1f
[   19.803066]  [<ffffffff8114553f>] ? context_tracking_user_exit+0xe2/0x101
[   19.803830]  [<ffffffff810b8776>] do_group_exit+0x107/0x127
[   19.804461]  [<ffffffff810b87ac>] SyS_exit_group+0x16/0x16
[   19.805073]  [<ffffffff8176a2e7>] system_call_fastpath+0x12/0x17
[   19.805721] ---[ end trace f8ae22d84a926b87 ]---
[   19.806307] ------------[ cut here ]------------
[   19.806832] WARNING: CPU: 0 PID: 109 at net/netlink/genetlink.c:1040 gen=
l_unbind+0x133/0x142()
[   19.807968] CPU: 0 PID: 109 Comm: trinity-main Tainted: G        W      =
3.18.0-11169-gc380d9a #9
[   19.808955]  0000000000000009 ffff88000b44fd38 ffffffff8175b593 ffff8800=
0b44fd78
[   19.809834]  ffffffff810b55aa 000000000000000d ffffffff8174d7e0 ffffffff=
834a3400
[   19.810739]  000000000000000d 0000000000000000 ffff88001202a520 ffff8800=
0b44fd88
[   19.811639] Call Trace:
[   19.811924]  [<ffffffff8175b593>] dump_stack+0x2e/0x3e
[   19.812511]  [<ffffffff810b55aa>] warn_slowpath_common+0xb6/0xe5
[   19.813174]  [<ffffffff8174d7e0>] ? genl_unbind+0x133/0x142
[   19.813809]  [<ffffffff810b56db>] warn_slowpath_null+0x23/0x2c
[   19.814455]  [<ffffffff8174d7e0>] genl_unbind+0x133/0x142
[   19.815063]  [<ffffffff8174b063>] netlink_release+0x364/0x3fd
[   19.815713]  [<ffffffff8170d262>] sock_release+0x23/0xa3
[   19.816315]  [<ffffffff8170d2f6>] sock_close+0x14/0x1f
[   19.816893]  [<ffffffff81199c9f>] __fput+0x16c/0x28e
[   19.817444]  [<ffffffff81199dd1>] ____fput+0x10/0x19
[   19.818006]  [<ffffffff810d1d20>] task_work_run+0xc7/0x116
[   19.818616]  [<ffffffff810b7e57>] do_exit+0x550/0xd1f
[   19.819173]  [<ffffffff8114553f>] ? context_tracking_user_exit+0xe2/0x101
[   19.819910]  [<ffffffff810b8776>] do_group_exit+0x107/0x127
[   19.820552]  [<ffffffff810b87ac>] SyS_exit_group+0x16/0x16
[   19.821161]  [<ffffffff8176a2e7>] system_call_fastpath+0x12/0x17
[   19.821836] ---[ end trace f8ae22d84a926b88 ]---
[   19.822388] ------------[ cut here ]------------
[   19.822915] WARNING: CPU: 0 PID: 109 at net/netlink/genetlink.c:1040 gen=
l_unbind+0x133/0x142()
[   19.824058] CPU: 0 PID: 109 Comm: trinity-main Tainted: G        W      =
3.18.0-11169-gc380d9a #9
[   19.825033]  0000000000000009 ffff88000b44fd38 ffffffff8175b593 ffff8800=
0b44fd78
[   19.825920]  ffffffff810b55aa 000000000000000e ffffffff8174d7e0 ffffffff=
834a3400
[   19.826808]  000000000000000e 0000000000000000 ffff88001202a520 ffff8800=
0b44fd88
[   19.827687] Call Trace:
[   19.827954]  [<ffffffff8175b593>] dump_stack+0x2e/0x3e
[   19.828534]  [<ffffffff810b55aa>] warn_slowpath_common+0xb6/0xe5
[   19.829175]  [<ffffffff8174d7e0>] ? genl_unbind+0x133/0x142
[   19.829808]  [<ffffffff810b56db>] warn_slowpath_null+0x23/0x2c
[   19.830466]  [<ffffffff8174d7e0>] genl_unbind+0x133/0x142
[   19.831070]  [<ffffffff8174b063>] netlink_release+0x364/0x3fd
[   19.831720]  [<ffffffff8170d262>] sock_release+0x23/0xa3
[   19.832293]  [<ffffffff8170d2f6>] sock_close+0x14/0x1f
[   19.832857]  [<ffffffff81199c9f>] __fput+0x16c/0x28e
[   19.833409]  [<ffffffff81199dd1>] ____fput+0x10/0x19
[   19.833970]  [<ffffffff810d1d20>] task_work_run+0xc7/0x116
[   19.834595]  [<ffffffff810b7e57>] do_exit+0x550/0xd1f
[   19.835164]  [<ffffffff8114553f>] ? context_tracking_user_exit+0xe2/0x101
[   19.835930]  [<ffffffff810b8776>] do_group_exit+0x107/0x127
[   19.836567]  [<ffffffff810b87ac>] SyS_exit_group+0x16/0x16
[   19.837174]  [<ffffffff8176a2e7>] system_call_fastpath+0x12/0x17
[   19.837853] ---[ end trace f8ae22d84a926b89 ]---
[   19.838406] ------------[ cut here ]------------
[   19.838925] WARNING: CPU: 0 PID: 109 at net/netlink/genetlink.c:1040 gen=
l_unbind+0x133/0x142()
[   19.840066] CPU: 0 PID: 109 Comm: trinity-main Tainted: G        W      =
3.18.0-11169-gc380d9a #9
[   19.841015]  0000000000000009 ffff88000b44fd38 ffffffff8175b593 ffff8800=
0b44fd78
[   19.841895]  ffffffff810b55aa 000000000000000f ffffffff8174d7e0 ffffffff=
834a3400
[   19.842756]  000000000000000f 0000000000000000 ffff88001202a520 ffff8800=
0b44fd88
[   19.843648] Call Trace:
[   19.843935]  [<ffffffff8175b593>] dump_stack+0x2e/0x3e
[   19.844537]  [<ffffffff810b55aa>] warn_slowpath_common+0xb6/0xe5
[   19.845202]  [<ffffffff8174d7e0>] ? genl_unbind+0x133/0x142
[   19.845768]  [<ffffffff810b56db>] warn_slowpath_null+0x23/0x2c
[   19.846374]  [<ffffffff8174d7e0>] genl_unbind+0x133/0x142
[   19.846915]  [<ffffffff8174b063>] netlink_release+0x364/0x3fd
[   19.847500]  [<ffffffff8170d262>] sock_release+0x23/0xa3
[   19.848056]  [<ffffffff8170d2f6>] sock_close+0x14/0x1f
[   19.848584]  [<ffffffff81199c9f>] __fput+0x16c/0x28e
[   19.849097]  [<ffffffff81199dd1>] ____fput+0x10/0x19
[   19.849601]  [<ffffffff810d1d20>] task_work_run+0xc7/0x116
[   19.850162]  [<ffffffff810b7e57>] do_exit+0x550/0xd1f
[   19.850703]  [<ffffffff8114553f>] ? context_tracking_user_exit+0xe2/0x101
[   19.851426]  [<ffffffff810b8776>] do_group_exit+0x107/0x127
[   19.852040]  [<ffffffff810b87ac>] SyS_exit_group+0x16/0x16
[   19.852629]  [<ffffffff8176a2e7>] system_call_fastpath+0x12/0x17
[   19.853252] ---[ end trace f8ae22d84a926b8a ]---
[   19.854252] ------------[ cut here ]------------
[   19.855308] WARNING: CPU: 0 PID: 109 at net/netlink/genetlink.c:1040 gen=
l_unbind+0x133/0x142()
[   19.857478] CPU: 0 PID: 109 Comm: trinity-main Tainted: G        W      =
3.18.0-11169-gc380d9a #9
[   19.859345]  0000000000000009 ffff88000b44fd38 ffffffff8175b593 ffff8800=
0b44fd78
[   19.861096]  ffffffff810b55aa 0000000000000005 ffffffff8174d7e0 ffffffff=
834a3400
[   19.862712]  0000000000000005 0000000000000000 ffff88001202a520 ffff8800=
0b44fd88
[   19.864407] Call Trace:
[   19.864942]  [<ffffffff8175b593>] dump_stack+0x2e/0x3e
[   19.866002]  [<ffffffff810b55aa>] warn_slowpath_common+0xb6/0xe5
[   19.867115]  [<ffffffff8174d7e0>] ? genl_unbind+0x133/0x142
[   19.868228]  [<ffffffff810b56db>] warn_slowpath_null+0x23/0x2c
[   19.869315]  [<ffffffff8174d7e0>] genl_unbind+0x133/0x142
[   19.870322]  [<ffffffff8174b063>] netlink_release+0x364/0x3fd
[   19.871312]  [<ffffffff8170d262>] sock_release+0x23/0xa3
[   19.872301]  [<ffffffff8170d2f6>] sock_close+0x14/0x1f
[   19.873277]  [<ffffffff81199c9f>] __fput+0x16c/0x28e
[   19.874221]  [<ffffffff81199dd1>] ____fput+0x10/0x19
[   19.875117]  [<ffffffff810d1d20>] task_work_run+0xc7/0x116
[   19.876191]  [<ffffffff810b7e57>] do_exit+0x550/0xd1f
[   19.877237]  [<ffffffff8114553f>] ? context_tracking_user_exit+0xe2/0x101
[   19.878717]  [<ffffffff810b8776>] do_group_exit+0x107/0x127
[   19.879899]  [<ffffffff810b87ac>] SyS_exit_group+0x16/0x16
[   19.881041]  [<ffffffff8176a2e7>] system_call_fastpath+0x12/0x17
[   19.882303] ---[ end trace f8ae22d84a926b8b ]---
[   19.883435] ------------[ cut here ]------------
[   19.884438] WARNING: CPU: 0 PID: 109 at net/netlink/genetlink.c:1040 gen=
l_unbind+0x133/0x142()
[   19.886544] CPU: 0 PID: 109 Comm: trinity-main Tainted: G        W      =
3.18.0-11169-gc380d9a #9
[   19.888412]  0000000000000009 ffff88000b44fd38 ffffffff8175b593 ffff8800=
0b44fd78
[   19.889972]  ffffffff810b55aa 0000000000000006 ffffffff8174d7e0 ffffffff=
834a3400
[   19.891583]  0000000000000006 0000000000000000 ffff88001202a520 ffff8800=
0b44fd88
[   19.893293] Call Trace:
[   19.893824]  [<ffffffff8175b593>] dump_stack+0x2e/0x3e
[   19.894834]  [<ffffffff810b55aa>] warn_slowpath_common+0xb6/0xe5
[   19.896015]  [<ffffffff8174d7e0>] ? genl_unbind+0x133/0x142
[   19.897237]  [<ffffffff810b56db>] warn_slowpath_null+0x23/0x2c
[   19.898460]  [<ffffffff8174d7e0>] genl_unbind+0x133/0x142
[   19.899555]  [<ffffffff8174b063>] netlink_release+0x364/0x3fd
[   19.900787]  [<ffffffff8170d262>] sock_release+0x23/0xa3
[   19.901934]  [<ffffffff8170d2f6>] sock_close+0x14/0x1f
[   19.902992]  [<ffffffff81199c9f>] __fput+0x16c/0x28e
[   19.903986]  [<ffffffff81199dd1>] ____fput+0x10/0x19
[   19.905045]  [<ffffffff810d1d20>] task_work_run+0xc7/0x116
[   19.906185]  [<ffffffff810b7e57>] do_exit+0x550/0xd1f
[   19.907229]  [<ffffffff8114553f>] ? context_tracking_user_exit+0xe2/0x101
[   19.908561]  [<ffffffff810b8776>] do_group_exit+0x107/0x127
[   19.909643]  [<ffffffff810b87ac>] SyS_exit_group+0x16/0x16
[   19.910791]  [<ffffffff8176a2e7>] system_call_fastpath+0x12/0x17
[   19.911995] ---[ end trace f8ae22d84a926b8c ]---
[   19.912996] ------------[ cut here ]------------
[   19.914077] WARNING: CPU: 0 PID: 109 at net/netlink/genetlink.c:1040 gen=
l_unbind+0x133/0x142()
[   19.916415] CPU: 0 PID: 109 Comm: trinity-main Tainted: G        W      =
3.18.0-11169-gc380d9a #9
[   19.918039]  0000000000000009 ffff88000b44fd38 ffffffff8175b593 ffff8800=
0b44fd78
[   19.919544]  ffffffff810b55aa 0000000000000008 ffffffff8174d7e0 ffffffff=
834a3400
[   19.921052]  0000000000000008 0000000000000000 ffff88001202a520 ffff8800=
0b44fd88
[   19.922499] Call Trace:
[   19.922983]  [<ffffffff8175b593>] dump_stack+0x2e/0x3e
[   19.923968]  [<ffffffff810b55aa>] warn_slowpath_common+0xb6/0xe5
[   19.925116]  [<ffffffff8174d7e0>] ? genl_unbind+0x133/0x142
[   19.926156]  [<ffffffff810b56db>] warn_slowpath_null+0x23/0x2c
[   19.927319]  [<ffffffff8174d7e0>] genl_unbind+0x133/0x142
[   19.928393]  [<ffffffff8174b063>] netlink_release+0x364/0x3fd
[   19.929506]  [<ffffffff8170d262>] sock_release+0x23/0xa3
[   19.930557]  [<ffffffff8170d2f6>] sock_close+0x14/0x1f
[   19.931579]  [<ffffffff81199c9f>] __fput+0x16c/0x28e
[   19.932581]  [<ffffffff81199dd1>] ____fput+0x10/0x19
[   19.933574]  [<ffffffff810d1d20>] task_work_run+0xc7/0x116
[   19.934658]  [<ffffffff810b7e57>] do_exit+0x550/0xd1f
[   19.935664]  [<ffffffff8114553f>] ? context_tracking_user_exit+0xe2/0x101
[   19.936998]  [<ffffffff810b8776>] do_group_exit+0x107/0x127
[   19.938054]  [<ffffffff810b87ac>] SyS_exit_group+0x16/0x16
[   19.939126]  [<ffffffff8176a2e7>] system_call_fastpath+0x12/0x17
[   19.940337] ---[ end trace f8ae22d84a926b8d ]---
[   19.941280] ------------[ cut here ]------------
[   19.942184] WARNING: CPU: 0 PID: 109 at net/netlink/genetlink.c:1040 gen=
l_unbind+0x133/0x142()
[   19.944158] CPU: 0 PID: 109 Comm: trinity-main Tainted: G        W      =
3.18.0-11169-gc380d9a #9
[   19.945686]  0000000000000009 ffff88000b44fd38 ffffffff8175b593 ffff8800=
0b44fd78
[   19.947119]  ffffffff810b55aa 000000000000000b ffffffff8174d7e0 ffffffff=
834a3400
[   19.948548]  000000000000000b 0000000000000000 ffff88001202a520 ffff8800=
0b44fd88
[   19.949923] Call Trace:
[   19.950404]  [<ffffffff8175b593>] dump_stack+0x2e/0x3e
[   19.951343]  [<ffffffff810b55aa>] warn_slowpath_common+0xb6/0xe5
[   19.952462]  [<ffffffff8174d7e0>] ? genl_unbind+0x133/0x142
[   19.953454]  [<ffffffff810b56db>] warn_slowpath_null+0x23/0x2c
[   19.954471]  [<ffffffff8174d7e0>] genl_unbind+0x133/0x142
[   19.955460]  [<ffffffff8174b063>] netlink_release+0x364/0x3fd
[   19.956534]  [<ffffffff8170d262>] sock_release+0x23/0xa3
[   19.957472]  [<ffffffff8170d2f6>] sock_close+0x14/0x1f
[   19.958419]  [<ffffffff81199c9f>] __fput+0x16c/0x28e
[   19.959318]  [<ffffffff81199dd1>] ____fput+0x10/0x19
[   19.960224]  [<ffffffff810d1d20>] task_work_run+0xc7/0x116
[   19.961162]  [<ffffffff810b7e57>] do_exit+0x550/0xd1f
[   19.962052]  [<ffffffff8114553f>] ? context_tracking_user_exit+0xe2/0x101
[   19.963257]  [<ffffffff810b8776>] do_group_exit+0x107/0x127
[   19.963857]  [<ffffffff810b87ac>] SyS_exit_group+0x16/0x16
[   19.964440]  [<ffffffff8176a2e7>] system_call_fastpath+0x12/0x17
[   19.965071] ---[ end trace f8ae22d84a926b8e ]---
[   19.965558] ------------[ cut here ]------------
[   19.966058] WARNING: CPU: 0 PID: 109 at net/netlink/genetlink.c:1040 gen=
l_unbind+0x133/0x142()
[   19.967105] CPU: 0 PID: 109 Comm: trinity-main Tainted: G        W      =
3.18.0-11169-gc380d9a #9
[   19.968028]  0000000000000009 ffff88000b44fd38 ffffffff8175b593 ffff8800=
0b44fd78
[   19.968898]  ffffffff810b55aa 000000000000000d ffffffff8174d7e0 ffffffff=
834a3400
[   19.969702]  000000000000000d 0000000000000000 ffff88001202a520 ffff8800=
0b44fd88
[   19.970528] Call Trace:
[   19.970791]  [<ffffffff8175b593>] dump_stack+0x2e/0x3e
[   19.971342]  [<ffffffff810b55aa>] warn_slowpath_common+0xb6/0xe5
[   19.971969]  [<ffffffff8174d7e0>] ? genl_unbind+0x133/0x142
[   19.972572]  [<ffffffff810b56db>] warn_slowpath_null+0x23/0x2c
[   19.973177]  [<ffffffff8174d7e0>] genl_unbind+0x133/0x142
[   19.973751]  [<ffffffff8174b063>] netlink_release+0x364/0x3fd
[   19.974339]  [<ffffffff8170d262>] sock_release+0x23/0xa3
[   19.974898]  [<ffffffff8170d2f6>] sock_close+0x14/0x1f
[   19.975459]  [<ffffffff81199c9f>] __fput+0x16c/0x28e
[   19.975984]  [<ffffffff81199dd1>] ____fput+0x10/0x19
[   19.976573]  [<ffffffff810d1d20>] task_work_run+0xc7/0x116
[   19.977150]  [<ffffffff810b7e57>] do_exit+0x550/0xd1f
[   19.977685]  [<ffffffff8114553f>] ? context_tracking_user_exit+0xe2/0x101
[   19.978411]  [<ffffffff810b8776>] do_group_exit+0x107/0x127
[   19.978990]  [<ffffffff810b87ac>] SyS_exit_group+0x16/0x16
[   19.979572]  [<ffffffff8176a2e7>] system_call_fastpath+0x12/0x17
[   19.980194] ---[ end trace f8ae22d84a926b8f ]---
[   19.981122] ------------[ cut here ]------------
[   19.981650] WARNING: CPU: 0 PID: 109 at net/netlink/genetlink.c:1040 gen=
l_unbind+0x133/0x142()
[   19.982679] CPU: 0 PID: 109 Comm: trinity-main Tainted: G        W      =
3.18.0-11169-gc380d9a #9
[   19.983601]  0000000000000009 ffff88000b44fd38 ffffffff8175b593 ffff8800=
0b44fd78
[   19.984453]  ffffffff810b55aa 0000000000000005 ffffffff8174d7e0 ffffffff=
834a3400
[   19.985269]  0000000000000005 0000000000000000 ffff88001202a520 ffff8800=
0b44fd88
[   19.986115] Call Trace:
[   19.986387]  [<ffffffff8175b593>] dump_stack+0x2e/0x3e
[   19.986968]  [<ffffffff810b55aa>] warn_slowpath_common+0xb6/0xe5
[   19.987624]  [<ffffffff8174d7e0>] ? genl_unbind+0x133/0x142
[   19.988212]  [<ffffffff810b56db>] warn_slowpath_null+0x23/0x2c
[   19.988840]  [<ffffffff8174d7e0>] genl_unbind+0x133/0x142
[   19.989403]  [<ffffffff8174b063>] netlink_release+0x364/0x3fd
[   19.989998]  [<ffffffff8170d262>] sock_release+0x23/0xa3
[   19.990552]  [<ffffffff8170d2f6>] sock_close+0x14/0x1f
[   19.991098]  [<ffffffff81199c9f>] __fput+0x16c/0x28e
[   19.991630]  [<ffffffff81199dd1>] ____fput+0x10/0x19
[   19.992141]  [<ffffffff810d1d20>] task_work_run+0xc7/0x116
[   19.992708]  [<ffffffff810b7e57>] do_exit+0x550/0xd1f
[   19.993220]  [<ffffffff8114553f>] ? context_tracking_user_exit+0xe2/0x101
[   19.993938]  [<ffffffff810b8776>] do_group_exit+0x107/0x127
[   19.994517]  [<ffffffff810b87ac>] SyS_exit_group+0x16/0x16
[   19.995121]  [<ffffffff8176a2e7>] system_call_fastpath+0x12/0x17
[   19.995747] ---[ end trace f8ae22d84a926b90 ]---
[   19.996321] ------------[ cut here ]------------
[   19.996833] WARNING: CPU: 0 PID: 109 at net/netlink/genetlink.c:1040 gen=
l_unbind+0x133/0x142()
[   19.998220] CPU: 0 PID: 109 Comm: trinity-main Tainted: G        W      =
3.18.0-11169-gc380d9a #9
[   19.999663]  0000000000000009 ffff88000b44fd38 ffffffff8175b593 ffff8800=
0b44fd78
[   20.000554]  ffffffff810b55aa 0000000000000006 ffffffff8174d7e0 ffffffff=
834a3400
[   20.001368]  0000000000000006 0000000000000000 ffff88001202a520 ffff8800=
0b44fd88
[   20.002191] Call Trace:
[   20.002478]  [<ffffffff8175b593>] dump_stack+0x2e/0x3e
[   20.003045]  [<ffffffff810b55aa>] warn_slowpath_common+0xb6/0xe5
[   20.003716]  [<ffffffff8174d7e0>] ? genl_unbind+0x133/0x142
[   20.004301]  [<ffffffff810b56db>] warn_slowpath_null+0x23/0x2c
[   20.004911]  [<ffffffff8174d7e0>] genl_unbind+0x133/0x142
[   20.005468]  [<ffffffff8174b063>] netlink_release+0x364/0x3fd
[   20.006085]  [<ffffffff8170d262>] sock_release+0x23/0xa3
[   20.006630]  [<ffffffff8170d2f6>] sock_close+0x14/0x1f
[   20.007151]  [<ffffffff81199c9f>] __fput+0x16c/0x28e
[   20.007692]  [<ffffffff81199dd1>] ____fput+0x10/0x19
[   20.008208]  [<ffffffff810d1d20>] task_work_run+0xc7/0x116
[   20.008824]  [<ffffffff810b7e57>] do_exit+0x550/0xd1f
[   20.009351]  [<ffffffff8114553f>] ? context_tracking_user_exit+0xe2/0x101
[   20.010070]  [<ffffffff810b8776>] do_group_exit+0x107/0x127
[   20.010634]  [<ffffffff810b87ac>] SyS_exit_group+0x16/0x16
[   20.011224]  [<ffffffff8176a2e7>] system_call_fastpath+0x12/0x17
[   20.011887] ---[ end trace f8ae22d84a926b91 ]---
[   20.012442] ------------[ cut here ]------------
[   20.012919] WARNING: CPU: 0 PID: 109 at net/netlink/genetlink.c:1040 gen=
l_unbind+0x133/0x142()
[   20.013969] CPU: 0 PID: 109 Comm: trinity-main Tainted: G        W      =
3.18.0-11169-gc380d9a #9
[   20.014895]  0000000000000009 ffff88000b44fd38 ffffffff8175b593 ffff8800=
0b44fd78
[   20.015767]  ffffffff810b55aa 0000000000000007 ffffffff8174d7e0 ffffffff=
834a3400
[   20.016611]  0000000000000007 0000000000000000 ffff88001202a520 ffff8800=
0b44fd88
[   20.017445] Call Trace:
[   20.017738]  [<ffffffff8175b593>] dump_stack+0x2e/0x3e
[   20.018281]  [<ffffffff810b55aa>] warn_slowpath_common+0xb6/0xe5
[   20.018901]  [<ffffffff8174d7e0>] ? genl_unbind+0x133/0x142
[   20.019492]  [<ffffffff810b56db>] warn_slowpath_null+0x23/0x2c
[   20.020096]  [<ffffffff8174d7e0>] genl_unbind+0x133/0x142
[   20.020718]  [<ffffffff8174b063>] netlink_release+0x364/0x3fd
[   20.021312]  [<ffffffff8170d262>] sock_release+0x23/0xa3
[   20.021862]  [<ffffffff8170d2f6>] sock_close+0x14/0x1f
[   20.022384]  [<ffffffff81199c9f>] __fput+0x16c/0x28e
[   20.022884]  [<ffffffff81199dd1>] ____fput+0x10/0x19
[   20.023424]  [<ffffffff810d1d20>] task_work_run+0xc7/0x116
[   20.024022]  [<ffffffff810b7e57>] do_exit+0x550/0xd1f
[   20.024567]  [<ffffffff8114553f>] ? context_tracking_user_exit+0xe2/0x101
[   20.025247]  [<ffffffff810b8776>] do_group_exit+0x107/0x127
[   20.025839]  [<ffffffff810b87ac>] SyS_exit_group+0x16/0x16
[   20.026413]  [<ffffffff8176a2e7>] system_call_fastpath+0x12/0x17
[   20.027074] ---[ end trace f8ae22d84a926b92 ]---
[   20.027623] ------------[ cut here ]------------
[   20.028120] WARNING: CPU: 0 PID: 109 at net/netlink/genetlink.c:1040 gen=
l_unbind+0x133/0x142()
[   20.029169] CPU: 0 PID: 109 Comm: trinity-main Tainted: G        W      =
3.18.0-11169-gc380d9a #9
[   20.030104]  0000000000000009 ffff88000b44fd38 ffffffff8175b593 ffff8800=
0b44fd78
[   20.030942]  ffffffff810b55aa 000000000000000b ffffffff8174d7e0 ffffffff=
834a3400
[   20.031781]  000000000000000b 0000000000000000 ffff88001202a520 ffff8800=
0b44fd88
[   20.032598] Call Trace:
[   20.032876]  [<ffffffff8175b593>] dump_stack+0x2e/0x3e
[   20.033404]  [<ffffffff810b55aa>] warn_slowpath_common+0xb6/0xe5
[   20.034040]  [<ffffffff8174d7e0>] ? genl_unbind+0x133/0x142
[   20.034607]  [<ffffffff810b56db>] warn_slowpath_null+0x23/0x2c
[   20.035226]  [<ffffffff8174d7e0>] genl_unbind+0x133/0x142
[   20.035807]  [<ffffffff8174b063>] netlink_release+0x364/0x3fd
[   20.036407]  [<ffffffff8170d262>] sock_release+0x23/0xa3
[   20.036976]  [<ffffffff8170d2f6>] sock_close+0x14/0x1f
[   20.037505]  [<ffffffff81199c9f>] __fput+0x16c/0x28e
[   20.038032]  [<ffffffff81199dd1>] ____fput+0x10/0x19
[   20.038532]  [<ffffffff810d1d20>] task_work_run+0xc7/0x116
[   20.039111]  [<ffffffff810b7e57>] do_exit+0x550/0xd1f
[   20.039657]  [<ffffffff8114553f>] ? context_tracking_user_exit+0xe2/0x101
[   20.040375]  [<ffffffff810b8776>] do_group_exit+0x107/0x127
[   20.040966]  [<ffffffff810b87ac>] SyS_exit_group+0x16/0x16
[   20.041531]  [<ffffffff8176a2e7>] system_call_fastpath+0x12/0x17
[   20.042147] ---[ end trace f8ae22d84a926b93 ]---
[   20.042650] ------------[ cut here ]------------
[   20.043146] WARNING: CPU: 0 PID: 109 at net/netlink/genetlink.c:1040 gen=
l_unbind+0x133/0x142()
[   20.044231] CPU: 0 PID: 109 Comm: trinity-main Tainted: G        W      =
3.18.0-11169-gc380d9a #9
[   20.045130]  0000000000000009 ffff88000b44fd38 ffffffff8175b593 ffff8800=
0b44fd78
[   20.045981]  ffffffff810b55aa 000000000000000c ffffffff8174d7e0 ffffffff=
834a3400
[   20.047324]  000000000000000c 0000000000000000 ffff88001202a520 ffff8800=
0b44fd88
[   20.048903] Call Trace:
[   20.049402]  [<ffffffff8175b593>] dump_stack+0x2e/0x3e
[   20.050406]  [<ffffffff810b55aa>] warn_slowpath_common+0xb6/0xe5
[   20.051549]  [<ffffffff8174d7e0>] ? genl_unbind+0x133/0x142
[   20.052668]  [<ffffffff810b56db>] warn_slowpath_null+0x23/0x2c
[   20.053818]  [<ffffffff8174d7e0>] genl_unbind+0x133/0x142
[   20.054858]  [<ffffffff8174b063>] netlink_release+0x364/0x3fd
[   20.055986]  [<ffffffff8170d262>] sock_release+0x23/0xa3
[   20.057052]  [<ffffffff8170d2f6>] sock_close+0x14/0x1f
[   20.058079]  [<ffffffff81199c9f>] __fput+0x16c/0x28e
[   20.058966]  [<ffffffff81199dd1>] ____fput+0x10/0x19
[   20.059821]  [<ffffffff810d1d20>] task_work_run+0xc7/0x116
[   20.060795]  [<ffffffff810b7e57>] do_exit+0x550/0xd1f
[   20.061682]  [<ffffffff8114553f>] ? context_tracking_user_exit+0xe2/0x101
[   20.062839]  [<ffffffff810b8776>] do_group_exit+0x107/0x127
[   20.063802]  [<ffffffff810b87ac>] SyS_exit_group+0x16/0x16
[   20.064776]  [<ffffffff8176a2e7>] system_call_fastpath+0x12/0x17
[   20.065822] ---[ end trace f8ae22d84a926b94 ]---
[   20.066681] ------------[ cut here ]------------
[   20.067505] WARNING: CPU: 0 PID: 109 at net/netlink/genetlink.c:1040 gen=
l_unbind+0x133/0x142()
[   20.069267] CPU: 0 PID: 109 Comm: trinity-main Tainted: G        W      =
3.18.0-11169-gc380d9a #9
[   20.070764]  0000000000000009 ffff88000b44fd38 ffffffff8175b593 ffff8800=
0b44fd78
[   20.072162]  ffffffff810b55aa 000000000000000d ffffffff8174d7e0 ffffffff=
834a3400
[   20.073534]  000000000000000d 0000000000000000 ffff88001202a520 ffff8800=
0b44fd88
[   20.074904] Call Trace:
[   20.075353]  [<ffffffff8175b593>] dump_stack+0x2e/0x3e
[   20.076272]  [<ffffffff810b55aa>] warn_slowpath_common+0xb6/0xe5
[   20.077300]  [<ffffffff8174d7e0>] ? genl_unbind+0x133/0x142
[   20.078269]  [<ffffffff810b56db>] warn_slowpath_null+0x23/0x2c
[   20.079276]  [<ffffffff8174d7e0>] genl_unbind+0x133/0x142
[   20.080233]  [<ffffffff8174b063>] netlink_release+0x364/0x3fd
[   20.081237]  [<ffffffff8170d262>] sock_release+0x23/0xa3
[   20.082154]  [<ffffffff8170d2f6>] sock_close+0x14/0x1f
[   20.083038]  [<ffffffff81199c9f>] __fput+0x16c/0x28e
[   20.083912]  [<ffffffff81199dd1>] ____fput+0x10/0x19
[   20.084713]  [<ffffffff810d1d20>] task_work_run+0xc7/0x116
[   20.085652]  [<ffffffff810b7e57>] do_exit+0x550/0xd1f
[   20.086555]  [<ffffffff8114553f>] ? context_tracking_user_exit+0xe2/0x101
[   20.087743]  [<ffffffff810b8776>] do_group_exit+0x107/0x127
[   20.088726]  [<ffffffff810b87ac>] SyS_exit_group+0x16/0x16
[   20.089685]  [<ffffffff8176a2e7>] system_call_fastpath+0x12/0x17
[   20.090715] ---[ end trace f8ae22d84a926b95 ]---
[   20.091569] ------------[ cut here ]------------
[   20.092397] WARNING: CPU: 0 PID: 109 at net/netlink/genetlink.c:1040 gen=
l_unbind+0x133/0x142()
[   20.094137] CPU: 0 PID: 109 Comm: trinity-main Tainted: G        W      =
3.18.0-11169-gc380d9a #9
[   20.095641]  0000000000000009 ffff88000b44fd38 ffffffff8175b593 ffff8800=
0b44fd78
[   20.097033]  ffffffff810b55aa 000000000000000f ffffffff8174d7e0 ffffffff=
834a3400
[   20.098402]  000000000000000f 0000000000000000 ffff88001202a520 ffff8800=
0b44fd88
[   20.099749] Call Trace:
[   20.100205]  [<ffffffff8175b593>] dump_stack+0x2e/0x3e
[   20.101085]  [<ffffffff810b55aa>] warn_slowpath_common+0xb6/0xe5
[   20.102122]  [<ffffffff8174d7e0>] ? genl_unbind+0x133/0x142
[   20.103089]  [<ffffffff810b56db>] warn_slowpath_null+0x23/0x2c
[   20.104106]  [<ffffffff8174d7e0>] genl_unbind+0x133/0x142
[   20.105055]  [<ffffffff8174b063>] netlink_release+0x364/0x3fd
[   20.106047]  [<ffffffff8170d262>] sock_release+0x23/0xa3
[   20.106962]  [<ffffffff8170d2f6>] sock_close+0x14/0x1f
[   20.107902]  [<ffffffff81199c9f>] __fput+0x16c/0x28e
[   20.108770]  [<ffffffff81199dd1>] ____fput+0x10/0x19
[   20.109625]  [<ffffffff810d1d20>] task_work_run+0xc7/0x116
[   20.110570]  [<ffffffff810b7e57>] do_exit+0x550/0xd1f
[   20.111435]  [<ffffffff8114553f>] ? context_tracking_user_exit+0xe2/0x101
[   20.112625]  [<ffffffff810b8776>] do_group_exit+0x107/0x127
[   20.113578]  [<ffffffff810b87ac>] SyS_exit_group+0x16/0x16
[   20.114558]  [<ffffffff8176a2e7>] system_call_fastpath+0x12/0x17
[   20.115590] ---[ end trace f8ae22d84a926b96 ]---
[   20.117494] ------------[ cut here ]------------
[   20.118343] WARNING: CPU: 0 PID: 109 at net/netlink/genetlink.c:1040 gen=
l_unbind+0x133/0x142()
[   20.120082] CPU: 0 PID: 109 Comm: trinity-main Tainted: G        W      =
3.18.0-11169-gc380d9a #9
[   20.121574]  0000000000000009 ffff88000b44fd38 ffffffff8175b593 ffff8800=
0b44fd78
[   20.122980]  ffffffff810b55aa 0000000000000001 ffffffff8174d7e0 ffffffff=
834a3400
[   20.124374]  0000000000000001 0000000000000000 ffff88001202a520 ffff8800=
0b44fd88
[   20.125745] Call Trace:
[   20.126178]  [<ffffffff8175b593>] dump_stack+0x2e/0x3e
[   20.127068]  [<ffffffff810b55aa>] warn_slowpath_common+0xb6/0xe5
[   20.128122]  [<ffffffff8174d7e0>] ? genl_unbind+0x133/0x142
[   20.129084]  [<ffffffff810b56db>] warn_slowpath_null+0x23/0x2c
[   20.130084]  [<ffffffff8174d7e0>] genl_unbind+0x133/0x142
[   20.131022]  [<ffffffff8174b063>] netlink_release+0x364/0x3fd
[   20.132033]  [<ffffffff8170d262>] sock_release+0x23/0xa3
[   20.132975]  [<ffffffff8170d2f6>] sock_close+0x14/0x1f
[   20.133867]  [<ffffffff81199c9f>] __fput+0x16c/0x28e
[   20.134725]  [<ffffffff81199dd1>] ____fput+0x10/0x19
[   20.135600]  [<ffffffff810d1d20>] task_work_run+0xc7/0x116
[   20.136541]  [<ffffffff810b7e57>] do_exit+0x550/0xd1f
[   20.137319]  [<ffffffff8114553f>] ? context_tracking_user_exit+0xe2/0x101
[   20.138304]  [<ffffffff810b8776>] do_group_exit+0x107/0x127
[   20.138908]  [<ffffffff810b87ac>] SyS_exit_group+0x16/0x16
[   20.139511]  [<ffffffff8176a2e7>] system_call_fastpath+0x12/0x17
[   20.140195] ---[ end trace f8ae22d84a926b97 ]---
[   20.140885] ------------[ cut here ]------------
[   20.141413] WARNING: CPU: 0 PID: 109 at net/netlink/genetlink.c:1040 gen=
l_unbind+0x133/0x142()
[   20.142460] CPU: 0 PID: 109 Comm: trinity-main Tainted: G        W      =
3.18.0-11169-gc380d9a #9
[   20.143860]  0000000000000009 ffff88000b44fd38 ffffffff8175b593 ffff8800=
0b44fd78
[   20.145159]  ffffffff810b55aa 0000000000000004 ffffffff8174d7e0 ffffffff=
834a3400
[   20.146295]  0000000000000004 0000000000000000 ffff88001202a520 ffff8800=
0b44fd88
[   20.147507] Call Trace:
[   20.147834]  [<ffffffff8175b593>] dump_stack+0x2e/0x3e
[   20.148648]  [<ffffffff810b55aa>] warn_slowpath_common+0xb6/0xe5
[   20.149415]  [<ffffffff8174d7e0>] ? genl_unbind+0x133/0x142
[   20.150253]  [<ffffffff810b56db>] warn_slowpath_null+0x23/0x2c
[   20.150871]  [<ffffffff8174d7e0>] genl_unbind+0x133/0x142
[   20.151475]  [<ffffffff8174b063>] netlink_release+0x364/0x3fd
[   20.152103]  [<ffffffff8170d262>] sock_release+0x23/0xa3
[   20.152677]  [<ffffffff8170d2f6>] sock_close+0x14/0x1f
[   20.153264]  [<ffffffff81199c9f>] __fput+0x16c/0x28e
[   20.153829]  [<ffffffff81199dd1>] ____fput+0x10/0x19
[   20.154396]  [<ffffffff810d1d20>] task_work_run+0xc7/0x116
[   20.155017]  [<ffffffff810b7e57>] do_exit+0x550/0xd1f
[   20.155583]  [<ffffffff8114553f>] ? context_tracking_user_exit+0xe2/0x101
[   20.156322]  [<ffffffff810b8776>] do_group_exit+0x107/0x127
[   20.156943]  [<ffffffff810b87ac>] SyS_exit_group+0x16/0x16
[   20.157580]  [<ffffffff8176a2e7>] system_call_fastpath+0x12/0x17
[   20.158284] ---[ end trace f8ae22d84a926b98 ]---
[   20.158829] ------------[ cut here ]------------
[   20.159360] WARNING: CPU: 0 PID: 109 at net/netlink/genetlink.c:1040 gen=
l_unbind+0x133/0x142()
[   20.160479] CPU: 0 PID: 109 Comm: trinity-main Tainted: G        W      =
3.18.0-11169-gc380d9a #9
[   20.161482]  0000000000000009 ffff88000b44fd38 ffffffff8175b593 ffff8800=
0b44fd78
[   20.162407]  ffffffff810b55aa 0000000000000005 ffffffff8174d7e0 ffffffff=
834a3400
[   20.163323]  0000000000000005 0000000000000000 ffff88001202a520 ffff8800=
0b44fd88
[   20.164213] Call Trace:
[   20.164499]  [<ffffffff8175b593>] dump_stack+0x2e/0x3e
[   20.165074]  [<ffffffff810b55aa>] warn_slowpath_common+0xb6/0xe5
[   20.165757]  [<ffffffff8174d7e0>] ? genl_unbind+0x133/0x142
[   20.166391]  [<ffffffff810b56db>] warn_slowpath_null+0x23/0x2c
[   20.167009]  [<ffffffff8174d7e0>] genl_unbind+0x133/0x142
[   20.167576]  [<ffffffff8174b063>] netlink_release+0x364/0x3fd
[   20.168193]  [<ffffffff8170d262>] sock_release+0x23/0xa3
[   20.168789]  [<ffffffff8170d2f6>] sock_close+0x14/0x1f
[   20.169388]  [<ffffffff81199c9f>] __fput+0x16c/0x28e
[   20.169974]  [<ffffffff81199dd1>] ____fput+0x10/0x19
[   20.170566]  [<ffffffff810d1d20>] task_work_run+0xc7/0x116
[   20.171218]  [<ffffffff810b7e57>] do_exit+0x550/0xd1f
[   20.171815]  [<ffffffff8114553f>] ? context_tracking_user_exit+0xe2/0x101
[   20.172610]  [<ffffffff810b8776>] do_group_exit+0x107/0x127
[   20.173273]  [<ffffffff810b87ac>] SyS_exit_group+0x16/0x16
[   20.173921]  [<ffffffff8176a2e7>] system_call_fastpath+0x12/0x17
[   20.174632] ---[ end trace f8ae22d84a926b99 ]---
[   20.175228] ------------[ cut here ]------------
[   20.175761] WARNING: CPU: 0 PID: 109 at net/netlink/genetlink.c:1040 gen=
l_unbind+0x133/0x142()
[   20.176907] CPU: 0 PID: 109 Comm: trinity-main Tainted: G        W      =
3.18.0-11169-gc380d9a #9
[   20.177836]  0000000000000009 ffff88000b44fd38 ffffffff8175b593 ffff8800=
0b44fd78
[   20.178708]  ffffffff810b55aa 0000000000000006 ffffffff8174d7e0 ffffffff=
834a3400
[   20.179599]  0000000000000006 0000000000000000 ffff88001202a520 ffff8800=
0b44fd88
[   20.180513] Call Trace:
[   20.180800]  [<ffffffff8175b593>] dump_stack+0x2e/0x3e
[   20.181385]  [<ffffffff810b55aa>] warn_slowpath_common+0xb6/0xe5
[   20.182062]  [<ffffffff8174d7e0>] ? genl_unbind+0x133/0x142
[   20.182691]  [<ffffffff810b56db>] warn_slowpath_null+0x23/0x2c
[   20.183350]  [<ffffffff8174d7e0>] genl_unbind+0x133/0x142
[   20.183950]  [<ffffffff8174b063>] netlink_release+0x364/0x3fd
[   20.184583]  [<ffffffff8170d262>] sock_release+0x23/0xa3
[   20.185138]  [<ffffffff8170d2f6>] sock_close+0x14/0x1f
[   20.185731]  [<ffffffff81199c9f>] __fput+0x16c/0x28e
[   20.186304]  [<ffffffff81199dd1>] ____fput+0x10/0x19
[   20.186831]  [<ffffffff810d1d20>] task_work_run+0xc7/0x116
[   20.187416]  [<ffffffff810b7e57>] do_exit+0x550/0xd1f
[   20.187981]  [<ffffffff8114553f>] ? context_tracking_user_exit+0xe2/0x101
[   20.188772]  [<ffffffff810b8776>] do_group_exit+0x107/0x127
[   20.189380]  [<ffffffff810b87ac>] SyS_exit_group+0x16/0x16
[   20.189967]  [<ffffffff8176a2e7>] system_call_fastpath+0x12/0x17
[   20.190610] ---[ end trace f8ae22d84a926b9a ]---
[   20.191123] ------------[ cut here ]------------
[   20.191611] WARNING: CPU: 0 PID: 109 at net/netlink/genetlink.c:1040 gen=
l_unbind+0x133/0x142()
[   20.192682] CPU: 0 PID: 109 Comm: trinity-main Tainted: G        W      =
3.18.0-11169-gc380d9a #9
[   20.193714]  0000000000000009 ffff88000b44fd38 ffffffff8175b593 ffff8800=
0b44fd78
[   20.194643]  ffffffff810b55aa 0000000000000007 ffffffff8174d7e0 ffffffff=
834a3400
[   20.195574]  0000000000000007 0000000000000000 ffff88001202a520 ffff8800=
0b44fd88
[   20.196482] Call Trace:
[   20.196769]  [<ffffffff8175b593>] dump_stack+0x2e/0x3e
[   20.197349]  [<ffffffff810b55aa>] warn_slowpath_common+0xb6/0xe5
[   20.198020]  [<ffffffff8174d7e0>] ? genl_unbind+0x133/0x142
[   20.198646]  [<ffffffff810b56db>] warn_slowpath_null+0x23/0x2c
[   20.199269]  [<ffffffff8174d7e0>] genl_unbind+0x133/0x142
[   20.199872]  [<ffffffff8174b063>] netlink_release+0x364/0x3fd
[   20.200635]  [<ffffffff8170d262>] sock_release+0x23/0xa3
[   20.201232]  [<ffffffff8170d2f6>] sock_close+0x14/0x1f
[   20.201814]  [<ffffffff81199c9f>] __fput+0x16c/0x28e
[   20.202382]  [<ffffffff81199dd1>] ____fput+0x10/0x19
[   20.202940]  [<ffffffff810d1d20>] task_work_run+0xc7/0x116
[   20.203565]  [<ffffffff810b7e57>] do_exit+0x550/0xd1f
[   20.204129]  [<ffffffff8114553f>] ? context_tracking_user_exit+0xe2/0x101
[   20.204872]  [<ffffffff810b8776>] do_group_exit+0x107/0x127
[   20.205507]  [<ffffffff810b87ac>] SyS_exit_group+0x16/0x16
[   20.206131]  [<ffffffff8176a2e7>] system_call_fastpath+0x12/0x17
[   20.206778] ---[ end trace f8ae22d84a926b9b ]---
[   20.207288] ------------[ cut here ]------------
[   20.207816] WARNING: CPU: 0 PID: 109 at net/netlink/genetlink.c:1040 gen=
l_unbind+0x133/0x142()
[   20.208951] CPU: 0 PID: 109 Comm: trinity-main Tainted: G        W      =
3.18.0-11169-gc380d9a #9
[   20.209861]  0000000000000009 ffff88000b44fd38 ffffffff8175b593 ffff8800=
0b44fd78
[   20.210713]  ffffffff810b55aa 0000000000000009 ffffffff8174d7e0 ffffffff=
834a3400
[   20.211581]  0000000000000009 0000000000000000 ffff88001202a520 ffff8800=
0b44fd88
[   20.212469] Call Trace:
[   20.212752]  [<ffffffff8175b593>] dump_stack+0x2e/0x3e
[   20.213340]  [<ffffffff810b55aa>] warn_slowpath_common+0xb6/0xe5
[   20.214018]  [<ffffffff8174d7e0>] ? genl_unbind+0x133/0x142
[   20.214649]  [<ffffffff810b56db>] warn_slowpath_null+0x23/0x2c
[   20.215311]  [<ffffffff8174d7e0>] genl_unbind+0x133/0x142
[   20.215905]  [<ffffffff8174b063>] netlink_release+0x364/0x3fd
[   20.216561]  [<ffffffff8170d262>] sock_release+0x23/0xa3
[   20.217147]  [<ffffffff8170d2f6>] sock_close+0x14/0x1f
[   20.217736]  [<ffffffff81199c9f>] __fput+0x16c/0x28e
[   20.218299]  [<ffffffff81199dd1>] ____fput+0x10/0x19
[   20.218847]  [<ffffffff810d1d20>] task_work_run+0xc7/0x116
[   20.219442]  [<ffffffff810b7e57>] do_exit+0x550/0xd1f
[   20.219989]  [<ffffffff8114553f>] ? context_tracking_user_exit+0xe2/0x101
[   20.220747]  [<ffffffff810b8776>] do_group_exit+0x107/0x127
[   20.221357]  [<ffffffff810b87ac>] SyS_exit_group+0x16/0x16
[   20.221930]  [<ffffffff8176a2e7>] system_call_fastpath+0x12/0x17
[   20.222565] ---[ end trace f8ae22d84a926b9c ]---
[   20.223107] ------------[ cut here ]------------
[   20.223641] WARNING: CPU: 0 PID: 109 at net/netlink/genetlink.c:1040 gen=
l_unbind+0x133/0x142()
[   20.224787] CPU: 0 PID: 109 Comm: trinity-main Tainted: G        W      =
3.18.0-11169-gc380d9a #9
[   20.225768]  0000000000000009 ffff88000b44fd38 ffffffff8175b593 ffff8800=
0b44fd78
[   20.226646]  ffffffff810b55aa 000000000000000a ffffffff8174d7e0 ffffffff=
834a3400
[   20.227515]  000000000000000a 0000000000000000 ffff88001202a520 ffff8800=
0b44fd88
[   20.228385] Call Trace:
[   20.228663]  [<ffffffff8175b593>] dump_stack+0x2e/0x3e
[   20.229232]  [<ffffffff810b55aa>] warn_slowpath_common+0xb6/0xe5
[   20.229882]  [<ffffffff8174d7e0>] ? genl_unbind+0x133/0x142
[   20.230497]  [<ffffffff810b56db>] warn_slowpath_null+0x23/0x2c
[   20.231123]  [<ffffffff8174d7e0>] genl_unbind+0x133/0x142
[   20.231720]  [<ffffffff8174b063>] netlink_release+0x364/0x3fd
[   20.232345]  [<ffffffff8170d262>] sock_release+0x23/0xa3
[   20.232959]  [<ffffffff8170d2f6>] sock_close+0x14/0x1f
[   20.233526]  [<ffffffff81199c9f>] __fput+0x16c/0x28e
[   20.234082]  [<ffffffff81199dd1>] ____fput+0x10/0x19
[   20.234642]  [<ffffffff810d1d20>] task_work_run+0xc7/0x116
[   20.235262]  [<ffffffff810b7e57>] do_exit+0x550/0xd1f
[   20.235829]  [<ffffffff8114553f>] ? context_tracking_user_exit+0xe2/0x101
[   20.236577]  [<ffffffff810b8776>] do_group_exit+0x107/0x127
[   20.237186]  [<ffffffff810b87ac>] SyS_exit_group+0x16/0x16
[   20.237809]  [<ffffffff8176a2e7>] system_call_fastpath+0x12/0x17
[   20.238467] ---[ end trace f8ae22d84a926b9d ]---
[   20.239002] ------------[ cut here ]------------
[   20.239521] WARNING: CPU: 0 PID: 109 at net/netlink/genetlink.c:1040 gen=
l_unbind+0x133/0x142()
[   20.240629] CPU: 0 PID: 109 Comm: trinity-main Tainted: G        W      =
3.18.0-11169-gc380d9a #9
[   20.241547]  0000000000000009 ffff88000b44fd38 ffffffff8175b593 ffff8800=
0b44fd78
[   20.242357]  ffffffff810b55aa 000000000000000f ffffffff8174d7e0 ffffffff=
834a3400
[   20.243155]  000000000000000f 0000000000000000 ffff88001202a520 ffff8800=
0b44fd88
[   20.243961] Call Trace:
[   20.244240]  [<ffffffff8175b593>] dump_stack+0x2e/0x3e
[   20.244758]  [<ffffffff810b55aa>] warn_slowpath_common+0xb6/0xe5
[   20.245366]  [<ffffffff8174d7e0>] ? genl_unbind+0x133/0x142
[   20.245925]  [<ffffffff810b56db>] warn_slowpath_null+0x23/0x2c
[   20.246514]  [<ffffffff8174d7e0>] genl_unbind+0x133/0x142
[   20.247055]  [<ffffffff8174b063>] netlink_release+0x364/0x3fd
[   20.247640]  [<ffffffff8170d262>] sock_release+0x23/0xa3
[   20.248191]  [<ffffffff8170d2f6>] sock_close+0x14/0x1f
[   20.248717]  [<ffffffff81199c9f>] __fput+0x16c/0x28e
[   20.249227]  [<ffffffff81199dd1>] ____fput+0x10/0x19
[   20.249730]  [<ffffffff810d1d20>] task_work_run+0xc7/0x116
[   20.250289]  [<ffffffff810b7e57>] do_exit+0x550/0xd1f
[   20.250801]  [<ffffffff8114553f>] ? context_tracking_user_exit+0xe2/0x101
[   20.251489]  [<ffffffff810b8776>] do_group_exit+0x107/0x127
[   20.252065]  [<ffffffff810b87ac>] SyS_exit_group+0x16/0x16
[   20.252621]  [<ffffffff8176a2e7>] system_call_fastpath+0x12/0x17
[   20.253226] ---[ end trace f8ae22d84a926b9e ]---
[   20.254171] ------------[ cut here ]------------
[   20.254658] WARNING: CPU: 0 PID: 109 at net/netlink/genetlink.c:1040 gen=
l_unbind+0x133/0x142()
[   20.255676] CPU: 0 PID: 109 Comm: trinity-main Tainted: G        W      =
3.18.0-11169-gc380d9a #9
[   20.256577]  0000000000000009 ffff88000b44fd38 ffffffff8175b593 ffff8800=
0b44fd78
[   20.257392]  ffffffff810b55aa 0000000000000001 ffffffff8174d7e0 ffffffff=
834a3400
[   20.258195]  0000000000000001 0000000000000000 ffff88001202a520 ffff8800=
0b44fd88
[   20.259004] Call Trace:
[   20.259270]  [<ffffffff8175b593>] dump_stack+0x2e/0x3e
[   20.259789]  [<ffffffff810b55aa>] warn_slowpath_common+0xb6/0xe5
[   20.260412]  [<ffffffff8174d7e0>] ? genl_unbind+0x133/0x142
[   20.260971]  [<ffffffff810b56db>] warn_slowpath_null+0x23/0x2c
[   20.261559]  [<ffffffff8174d7e0>] genl_unbind+0x133/0x142
[   20.262105]  [<ffffffff8174b063>] netlink_release+0x364/0x3fd
[   20.262688]  [<ffffffff8170d262>] sock_release+0x23/0xa3
[   20.263230]  [<ffffffff8170d2f6>] sock_close+0x14/0x1f
[   20.263748]  [<ffffffff81199c9f>] __fput+0x16c/0x28e
[   20.264273]  [<ffffffff81199dd1>] ____fput+0x10/0x19
[   20.264776]  [<ffffffff810d1d20>] task_work_run+0xc7/0x116
[   20.265335]  [<ffffffff810b7e57>] do_exit+0x550/0xd1f
[   20.265844]  [<ffffffff8114553f>] ? context_tracking_user_exit+0xe2/0x101
[   20.266530]  [<ffffffff810b8776>] do_group_exit+0x107/0x127
[   20.267088]  [<ffffffff810b87ac>] SyS_exit_group+0x16/0x16
[   20.267652]  [<ffffffff8176a2e7>] system_call_fastpath+0x12/0x17
[   20.268268] ---[ end trace f8ae22d84a926b9f ]---
[   20.268847] ------------[ cut here ]------------
[   20.269327] WARNING: CPU: 0 PID: 109 at net/netlink/genetlink.c:1040 gen=
l_unbind+0x133/0x142()
[   20.270346] CPU: 0 PID: 109 Comm: trinity-main Tainted: G        W      =
3.18.0-11169-gc380d9a #9
[   20.271224]  0000000000000009 ffff88000b44fd38 ffffffff8175b593 ffff8800=
0b44fd78
[   20.272073]  ffffffff810b55aa 0000000000000004 ffffffff8174d7e0 ffffffff=
834a3400
[   20.272885]  0000000000000004 0000000000000000 ffff88001202a520 ffff8800=
0b44fd88
[   20.273691] Call Trace:
[   20.273950]  [<ffffffff8175b593>] dump_stack+0x2e/0x3e
[   20.274474]  [<ffffffff810b55aa>] warn_slowpath_common+0xb6/0xe5
[   20.275079]  [<ffffffff8174d7e0>] ? genl_unbind+0x133/0x142
[   20.275643]  [<ffffffff810b56db>] warn_slowpath_null+0x23/0x2c
[   20.276250]  [<ffffffff8174d7e0>] genl_unbind+0x133/0x142
[   20.276802]  [<ffffffff8174b063>] netlink_release+0x364/0x3fd
[   20.277394]  [<ffffffff8170d262>] sock_release+0x23/0xa3
[   20.277933]  [<ffffffff8170d2f6>] sock_close+0x14/0x1f
[   20.278457]  [<ffffffff81199c9f>] __fput+0x16c/0x28e
[   20.278959]  [<ffffffff81199dd1>] ____fput+0x10/0x19
[   20.279468]  [<ffffffff810d1d20>] task_work_run+0xc7/0x116
[   20.280037]  [<ffffffff810b7e57>] do_exit+0x550/0xd1f
[   20.280560]  [<ffffffff8114553f>] ? context_tracking_user_exit+0xe2/0x101
[   20.281249]  [<ffffffff810b8776>] do_group_exit+0x107/0x127
[   20.281810]  [<ffffffff810b87ac>] SyS_exit_group+0x16/0x16
[   20.282372]  [<ffffffff8176a2e7>] system_call_fastpath+0x12/0x17
[   20.282976] ---[ end trace f8ae22d84a926ba0 ]---
[   20.283476] ------------[ cut here ]------------
[   20.283948] WARNING: CPU: 0 PID: 109 at net/netlink/genetlink.c:1040 gen=
l_unbind+0x133/0x142()
[   20.284985] CPU: 0 PID: 109 Comm: trinity-main Tainted: G        W      =
3.18.0-11169-gc380d9a #9
[   20.285867]  0000000000000009 ffff88000b44fd38 ffffffff8175b593 ffff8800=
0b44fd78
[   20.286677]  ffffffff810b55aa 0000000000000006 ffffffff8174d7e0 ffffffff=
834a3400
[   20.287486]  0000000000000006 0000000000000000 ffff88001202a520 ffff8800=
0b44fd88
[   20.288317] Call Trace:
[   20.288577]  [<ffffffff8175b593>] dump_stack+0x2e/0x3e
[   20.289099]  [<ffffffff810b55aa>] warn_slowpath_common+0xb6/0xe5
[   20.289709]  [<ffffffff8174d7e0>] ? genl_unbind+0x133/0x142
[   20.290274]  [<ffffffff810b56db>] warn_slowpath_null+0x23/0x2c
[   20.290861]  [<ffffffff8174d7e0>] genl_unbind+0x133/0x142
[   20.291409]  [<ffffffff8174b063>] netlink_release+0x364/0x3fd
[   20.291991]  [<ffffffff8170d262>] sock_release+0x23/0xa3
[   20.292546]  [<ffffffff8170d2f6>] sock_close+0x14/0x1f
[   20.293066]  [<ffffffff81199c9f>] __fput+0x16c/0x28e
[   20.293581]  [<ffffffff81199dd1>] ____fput+0x10/0x19
[   20.294082]  [<ffffffff810d1d20>] task_work_run+0xc7/0x116
[   20.294641]  [<ffffffff810b7e57>] do_exit+0x550/0xd1f
[   20.295154]  [<ffffffff8114553f>] ? context_tracking_user_exit+0xe2/0x101
[   20.295838]  [<ffffffff810b8776>] do_group_exit+0x107/0x127
[   20.296417]  [<ffffffff810b87ac>] SyS_exit_group+0x16/0x16
[   20.296968]  [<ffffffff8176a2e7>] system_call_fastpath+0x12/0x17
[   20.297577] ---[ end trace f8ae22d84a926ba1 ]---
[   20.298064] ------------[ cut here ]------------
[   20.298542] WARNING: CPU: 0 PID: 109 at net/netlink/genetlink.c:1040 gen=
l_unbind+0x133/0x142()
[   20.299558] CPU: 0 PID: 109 Comm: trinity-main Tainted: G        W      =
3.18.0-11169-gc380d9a #9
[   20.300451]  0000000000000009 ffff88000b44fd38 ffffffff8175b593 ffff8800=
0b44fd78
[   20.301266]  ffffffff810b55aa 0000000000000007 ffffffff8174d7e0 ffffffff=
834a3400
[   20.302085]  0000000000000007 0000000000000000 ffff88001202a520 ffff8800=
0b44fd88
[   20.302901] Call Trace:
[   20.303161]  [<ffffffff8175b593>] dump_stack+0x2e/0x3e
[   20.303687]  [<ffffffff810b55aa>] warn_slowpath_common+0xb6/0xe5
[   20.304308]  [<ffffffff8174d7e0>] ? genl_unbind+0x133/0x142
[   20.304871]  [<ffffffff810b56db>] warn_slowpath_null+0x23/0x2c
[   20.305464]  [<ffffffff8174d7e0>] genl_unbind+0x133/0x142
[   20.306011]  [<ffffffff8174b063>] netlink_release+0x364/0x3fd
[   20.306596]  [<ffffffff8170d262>] sock_release+0x23/0xa3
[   20.307132]  [<ffffffff8170d2f6>] sock_close+0x14/0x1f
[   20.307659]  [<ffffffff81199c9f>] __fput+0x16c/0x28e
[   20.308176]  [<ffffffff81199dd1>] ____fput+0x10/0x19
[   20.308688]  [<ffffffff810d1d20>] task_work_run+0xc7/0x116
[   20.309249]  [<ffffffff810b7e57>] do_exit+0x550/0xd1f
[   20.309762]  [<ffffffff8114553f>] ? context_tracking_user_exit+0xe2/0x101
[   20.310448]  [<ffffffff810b8776>] do_group_exit+0x107/0x127
[   20.311007]  [<ffffffff810b87ac>] SyS_exit_group+0x16/0x16
[   20.311567]  [<ffffffff8176a2e7>] system_call_fastpath+0x12/0x17
[   20.312182] ---[ end trace f8ae22d84a926ba2 ]---
[   20.312686] ------------[ cut here ]------------
[   20.313161] WARNING: CPU: 0 PID: 109 at net/netlink/genetlink.c:1040 gen=
l_unbind+0x133/0x142()
[   20.314179] CPU: 0 PID: 109 Comm: trinity-main Tainted: G        W      =
3.18.0-11169-gc380d9a #9
[   20.315052]  0000000000000009 ffff88000b44fd38 ffffffff8175b593 ffff8800=
0b44fd78
[   20.315861]  ffffffff810b55aa 0000000000000008 ffffffff8174d7e0 ffffffff=
834a3400
[   20.316690]  0000000000000008 0000000000000000 ffff88001202a520 ffff8800=
0b44fd88
[   20.317499] Call Trace:
[   20.317760]  [<ffffffff8175b593>] dump_stack+0x2e/0x3e
[   20.318289]  [<ffffffff810b55aa>] warn_slowpath_common+0xb6/0xe5
[   20.318899]  [<ffffffff8174d7e0>] ? genl_unbind+0x133/0x142
[   20.319474]  [<ffffffff810b56db>] warn_slowpath_null+0x23/0x2c
[   20.320089]  [<ffffffff8174d7e0>] genl_unbind+0x133/0x142
[   20.320646]  [<ffffffff8174b063>] netlink_release+0x364/0x3fd
[   20.321231]  [<ffffffff8170d262>] sock_release+0x23/0xa3
[   20.321766]  [<ffffffff8170d2f6>] sock_close+0x14/0x1f
[   20.322293]  [<ffffffff81199c9f>] __fput+0x16c/0x28e
[   20.322796]  [<ffffffff81199dd1>] ____fput+0x10/0x19
[   20.323301]  [<ffffffff810d1d20>] task_work_run+0xc7/0x116
[   20.323853]  [<ffffffff810b7e57>] do_exit+0x550/0xd1f
[   20.324385]  [<ffffffff8114553f>] ? context_tracking_user_exit+0xe2/0x101
[   20.325067]  [<ffffffff810b8776>] do_group_exit+0x107/0x127
[   20.325636]  [<ffffffff810b87ac>] SyS_exit_group+0x16/0x16
[   20.326191]  [<ffffffff8176a2e7>] system_call_fastpath+0x12/0x17
[   20.326797] ---[ end trace f8ae22d84a926ba3 ]---
[   20.327683] ------------[ cut here ]------------
[   20.329150] WARNING: CPU: 0 PID: 109 at net/netlink/genetlink.c:1040 gen=
l_unbind+0x133/0x142()
[   20.330757] CPU: 0 PID: 109 Comm: trinity-main Tainted: G        W      =
3.18.0-11169-gc380d9a #9
[   20.332173]  0000000000000009 ffff88000b44fd38 ffffffff8175b593 ffff8800=
0b44fd78
[   20.333446]  ffffffff810b55aa 0000000000000020 ffffffff8174d7e0 ffffffff=
834a3400
[   20.334705]  0000000000000020 0000000000000000 ffff88001202a520 ffff8800=
0b44fd88
[   20.335962] Call Trace:
[   20.336392]  [<ffffffff8175b593>] dump_stack+0x2e/0x3e
[   20.337217]  [<ffffffff810b55aa>] warn_slowpath_common+0xb6/0xe5
[   20.338170]  [<ffffffff8174d7e0>] ? genl_unbind+0x133/0x142
[   20.339054]  [<ffffffff810b56db>] warn_slowpath_null+0x23/0x2c
[   20.339981]  [<ffffffff8174d7e0>] genl_unbind+0x133/0x142
[   20.340850]  [<ffffffff8174b063>] netlink_release+0x364/0x3fd
[   20.341771]  [<ffffffff8170d262>] sock_release+0x23/0xa3
[   20.342626]  [<ffffffff8170d2f6>] sock_close+0x14/0x1f
[   20.343447]  [<ffffffff81199c9f>] __fput+0x16c/0x28e
[   20.344256]  [<ffffffff81199dd1>] ____fput+0x10/0x19
[   20.345050]  [<ffffffff810d1d20>] task_work_run+0xc7/0x116
[   20.345930]  [<ffffffff810b7e57>] do_exit+0x550/0xd1f
[   20.346749]  [<ffffffff8114553f>] ? context_tracking_user_exit+0xe2/0x101
[   20.347830]  [<ffffffff810b8776>] do_group_exit+0x107/0x127
[   20.348753]  [<ffffffff810b87ac>] SyS_exit_group+0x16/0x16
[   20.349631]  [<ffffffff8176a2e7>] system_call_fastpath+0x12/0x17
[   20.350592] ---[ end trace f8ae22d84a926ba4 ]---
[   20.352841] ------------[ cut here ]------------
[   20.353599] WARNING: CPU: 0 PID: 109 at net/netlink/genetlink.c:1040 gen=
l_unbind+0x133/0x142()
[   20.355205] CPU: 0 PID: 109 Comm: trinity-main Tainted: G        W      =
3.18.0-11169-gc380d9a #9
[   20.356620]  0000000000000009 ffff88000b44fd38 ffffffff8175b593 ffff8800=
0b44fd78
[   20.357874]  ffffffff810b55aa 0000000000000001 ffffffff8174d7e0 ffffffff=
834a3400
[   20.359133]  0000000000000001 0000000000000000 ffff88001202a520 ffff8800=
0b44fd88
[   20.360420] Call Trace:
[   20.360822]  [<ffffffff8175b593>] dump_stack+0x2e/0x3e
[   20.361644]  [<ffffffff810b55aa>] warn_slowpath_common+0xb6/0xe5
[   20.362618]  [<ffffffff8174d7e0>] ? genl_unbind+0x133/0x142
[   20.363512]  [<ffffffff810b56db>] warn_slowpath_null+0x23/0x2c
[   20.364408]  [<ffffffff8174d7e0>] genl_unbind+0x133/0x142
[   20.365028]  [<ffffffff8174b063>] netlink_release+0x364/0x3fd
[   20.365650]  [<ffffffff8170d262>] sock_release+0x23/0xa3
[   20.366226]  [<ffffffff8170d2f6>] sock_close+0x14/0x1f
[   20.366763]  [<ffffffff81199c9f>] __fput+0x16c/0x28e
[   20.367308]  [<ffffffff81199dd1>] ____fput+0x10/0x19
[   20.367871]  [<ffffffff810d1d20>] task_work_run+0xc7/0x116
[   20.368532]  [<ffffffff810b7e57>] do_exit+0x550/0xd1f
[   20.369105]  [<ffffffff8114553f>] ? context_tracking_user_exit+0xe2/0x101
[   20.369894]  [<ffffffff810b8776>] do_group_exit+0x107/0x127
[   20.370541]  [<ffffffff810b87ac>] SyS_exit_group+0x16/0x16
[   20.371170]  [<ffffffff8176a2e7>] system_call_fastpath+0x12/0x17
[   20.371841] ---[ end trace f8ae22d84a926ba5 ]---
[   20.372609] ------------[ cut here ]------------
[   20.373112] WARNING: CPU: 0 PID: 109 at net/netlink/genetlink.c:1040 gen=
l_unbind+0x133/0x142()
[   20.374280] CPU: 0 PID: 109 Comm: trinity-main Tainted: G        W      =
3.18.0-11169-gc380d9a #9
[   20.375204]  0000000000000009 ffff88000b44fd38 ffffffff8175b593 ffff8800=
0b44fd78
[   20.376089]  ffffffff810b55aa 0000000000000004 ffffffff8174d7e0 ffffffff=
834a3400
[   20.376991]  0000000000000004 0000000000000000 ffff88001202a520 ffff8800=
0b44fd88
[   20.377849] Call Trace:
[   20.378130]  [<ffffffff8175b593>] dump_stack+0x2e/0x3e
[   20.378711]  [<ffffffff810b55aa>] warn_slowpath_common+0xb6/0xe5
[   20.379365]  [<ffffffff8174d7e0>] ? genl_unbind+0x133/0x142
[   20.379970]  [<ffffffff810b56db>] warn_slowpath_null+0x23/0x2c
[   20.380643]  [<ffffffff8174d7e0>] genl_unbind+0x133/0x142
[   20.381236]  [<ffffffff8174b063>] netlink_release+0x364/0x3fd
[   20.381892]  [<ffffffff8170d262>] sock_release+0x23/0xa3
[   20.382498]  [<ffffffff8170d2f6>] sock_close+0x14/0x1f
[   20.383063]  [<ffffffff81199c9f>] __fput+0x16c/0x28e
[   20.383612]  [<ffffffff81199dd1>] ____fput+0x10/0x19
[   20.384177]  [<ffffffff810d1d20>] task_work_run+0xc7/0x116
[   20.384811]  [<ffffffff810b7e57>] do_exit+0x550/0xd1f
[   20.385388]  [<ffffffff8114553f>] ? context_tracking_user_exit+0xe2/0x101
[   20.386150]  [<ffffffff810b8776>] do_group_exit+0x107/0x127
[   20.386774]  [<ffffffff810b87ac>] SyS_exit_group+0x16/0x16
[   20.387408]  [<ffffffff8176a2e7>] system_call_fastpath+0x12/0x17
[   20.388081] ---[ end trace f8ae22d84a926ba6 ]---
[   20.388644] ------------[ cut here ]------------
[   20.389147] WARNING: CPU: 0 PID: 109 at net/netlink/genetlink.c:1040 gen=
l_unbind+0x133/0x142()
[   20.390325] CPU: 0 PID: 109 Comm: trinity-main Tainted: G        W      =
3.18.0-11169-gc380d9a #9
[   20.391283]  0000000000000009 ffff88000b44fd38 ffffffff8175b593 ffff8800=
0b44fd78
[   20.392168]  ffffffff810b55aa 0000000000000006 ffffffff8174d7e0 ffffffff=
834a3400
[   20.393050]  0000000000000006 0000000000000000 ffff88001202a520 ffff8800=
0b44fd88
[   20.393973] Call Trace:
[   20.394282]  [<ffffffff8175b593>] dump_stack+0x2e/0x3e
[   20.394886]  [<ffffffff810b55aa>] warn_slowpath_common+0xb6/0xe5
[   20.395574]  [<ffffffff8174d7e0>] ? genl_unbind+0x133/0x142
[   20.396223]  [<ffffffff810b56db>] warn_slowpath_null+0x23/0x2c
[   20.396882]  [<ffffffff8174d7e0>] genl_unbind+0x133/0x142
[   20.397511]  [<ffffffff8174b063>] netlink_release+0x364/0x3fd
[   20.398171]  [<ffffffff8170d262>] sock_release+0x23/0xa3
[   20.398796]  [<ffffffff8170d2f6>] sock_close+0x14/0x1f
[   20.399402]  [<ffffffff81199c9f>] __fput+0x16c/0x28e
[   20.399956]  [<ffffffff81199dd1>] ____fput+0x10/0x19
[   20.400556]  [<ffffffff810d1d20>] task_work_run+0xc7/0x116
[   20.401211]  [<ffffffff810b7e57>] do_exit+0x550/0xd1f
[   20.401812]  [<ffffffff8114553f>] ? context_tracking_user_exit+0xe2/0x101
[   20.402694]  [<ffffffff810b8776>] do_group_exit+0x107/0x127
[   20.403328]  [<ffffffff810b87ac>] SyS_exit_group+0x16/0x16
[   20.403937]  [<ffffffff8176a2e7>] system_call_fastpath+0x12/0x17
[   20.404625] ---[ end trace f8ae22d84a926ba7 ]---
[   20.405171] ------------[ cut here ]------------
[   20.405706] WARNING: CPU: 0 PID: 109 at net/netlink/genetlink.c:1040 gen=
l_unbind+0x133/0x142()
[   20.406954] CPU: 0 PID: 109 Comm: trinity-main Tainted: G        W      =
3.18.0-11169-gc380d9a #9
[   20.407931]  0000000000000009 ffff88000b44fd38 ffffffff8175b593 ffff8800=
0b44fd78
[   20.408842]  ffffffff810b55aa 0000000000000007 ffffffff8174d7e0 ffffffff=
834a3400
[   20.409734]  0000000000000007 0000000000000000 ffff88001202a520 ffff8800=
0b44fd88
[   20.410737] Call Trace:
[   20.411023]  [<ffffffff8175b593>] dump_stack+0x2e/0x3e
[   20.411599]  [<ffffffff810b55aa>] warn_slowpath_common+0xb6/0xe5
[   20.412284]  [<ffffffff8174d7e0>] ? genl_unbind+0x133/0x142
[   20.412916]  [<ffffffff810b56db>] warn_slowpath_null+0x23/0x2c
[   20.413578]  [<ffffffff8174d7e0>] genl_unbind+0x133/0x142
[   20.414225]  [<ffffffff8174b063>] netlink_release+0x364/0x3fd
[   20.414907]  [<ffffffff8170d262>] sock_release+0x23/0xa3
[   20.415504]  [<ffffffff8170d2f6>] sock_close+0x14/0x1f
[   20.416084]  [<ffffffff81199c9f>] __fput+0x16c/0x28e
[   20.416642]  [<ffffffff81199dd1>] ____fput+0x10/0x19
[   20.417213]  [<ffffffff810d1d20>] task_work_run+0xc7/0x116
[   20.417832]  [<ffffffff810b7e57>] do_exit+0x550/0xd1f
[   20.418513]  [<ffffffff8114553f>] ? context_tracking_user_exit+0xe2/0x101
[   20.419274]  [<ffffffff810b8776>] do_group_exit+0x107/0x127
[   20.419898]  [<ffffffff810b87ac>] SyS_exit_group+0x16/0x16
[   20.420531]  [<ffffffff8176a2e7>] system_call_fastpath+0x12/0x17
[   20.421221] ---[ end trace f8ae22d84a926ba8 ]---
[   20.421745] ------------[ cut here ]------------
[   20.422338] WARNING: CPU: 0 PID: 109 at net/netlink/genetlink.c:1040 gen=
l_unbind+0x133/0x142()
[   20.423520] CPU: 0 PID: 109 Comm: trinity-main Tainted: G        W      =
3.18.0-11169-gc380d9a #9
[   20.424508]  0000000000000009 ffff88000b44fd38 ffffffff8175b593 ffff8800=
0b44fd78
[   20.425415]  ffffffff810b55aa 0000000000000009 ffffffff8174d7e0 ffffffff=
834a3400
[   20.426381]  0000000000000009 0000000000000000 ffff88001202a520 ffff8800=
0b44fd88
[   20.427322] Call Trace:
[   20.427604]  [<ffffffff8175b593>] dump_stack+0x2e/0x3e
[   20.428185]  [<ffffffff810b55aa>] warn_slowpath_common+0xb6/0xe5
[   20.428876]  [<ffffffff8174d7e0>] ? genl_unbind+0x133/0x142
[   20.429515]  [<ffffffff810b56db>] warn_slowpath_null+0x23/0x2c
[   20.430232]  [<ffffffff8174d7e0>] genl_unbind+0x133/0x142
[   20.430893]  [<ffffffff8174b063>] netlink_release+0x364/0x3fd
[   20.431541]  [<ffffffff8170d262>] sock_release+0x23/0xa3
[   20.432141]  [<ffffffff8170d2f6>] sock_close+0x14/0x1f
[   20.432732]  [<ffffffff81199c9f>] __fput+0x16c/0x28e
[   20.433309]  [<ffffffff81199dd1>] ____fput+0x10/0x19
[   20.433876]  [<ffffffff810d1d20>] task_work_run+0xc7/0x116
[   20.434594]  [<ffffffff810b7e57>] do_exit+0x550/0xd1f
[   20.435164]  [<ffffffff8114553f>] ? context_tracking_user_exit+0xe2/0x101
[   20.435917]  [<ffffffff810b8776>] do_group_exit+0x107/0x127
[   20.436550]  [<ffffffff810b87ac>] SyS_exit_group+0x16/0x16
[   20.437174]  [<ffffffff8176a2e7>] system_call_fastpath+0x12/0x17
[   20.437863] ---[ end trace f8ae22d84a926ba9 ]---
[   20.438523] ------------[ cut here ]------------
[   20.439048] WARNING: CPU: 0 PID: 109 at net/netlink/genetlink.c:1040 gen=
l_unbind+0x133/0x142()
[   20.440186] CPU: 0 PID: 109 Comm: trinity-main Tainted: G        W      =
3.18.0-11169-gc380d9a #9
[   20.441183]  0000000000000009 ffff88000b44fd38 ffffffff8175b593 ffff8800=
0b44fd78
[   20.442134]  ffffffff810b55aa 000000000000000a ffffffff8174d7e0 ffffffff=
834a3400
[   20.443081]  000000000000000a 0000000000000000 ffff88001202a520 ffff8800=
0b44fd88
[   20.443966] Call Trace:
[   20.444268]  [<ffffffff8175b593>] dump_stack+0x2e/0x3e
[   20.444856]  [<ffffffff810b55aa>] warn_slowpath_common+0xb6/0xe5
[   20.445546]  [<ffffffff8174d7e0>] ? genl_unbind+0x133/0x142
[   20.446236]  [<ffffffff810b56db>] warn_slowpath_null+0x23/0x2c
[   20.446952]  [<ffffffff8174d7e0>] genl_unbind+0x133/0x142
[   20.447568]  [<ffffffff8174b063>] netlink_release+0x364/0x3fd
[   20.448226]  [<ffffffff8170d262>] sock_release+0x23/0xa3
[   20.448834]  [<ffffffff8170d2f6>] sock_close+0x14/0x1f
[   20.449425]  [<ffffffff81199c9f>] __fput+0x16c/0x28e
[   20.449988]  [<ffffffff81199dd1>] ____fput+0x10/0x19
[   20.450664]  [<ffffffff810d1d20>] task_work_run+0xc7/0x116
[   20.451290]  [<ffffffff810b7e57>] do_exit+0x550/0xd1f
[   20.451854]  [<ffffffff8114553f>] ? context_tracking_user_exit+0xe2/0x101
[   20.452632]  [<ffffffff810b8776>] do_group_exit+0x107/0x127
[   20.453277]  [<ffffffff810b87ac>] SyS_exit_group+0x16/0x16
[   20.453895]  [<ffffffff8176a2e7>] system_call_fastpath+0x12/0x17
[   20.454661] ---[ end trace f8ae22d84a926baa ]---
[   20.455212] ------------[ cut here ]------------
[   20.455734] WARNING: CPU: 0 PID: 109 at net/netlink/genetlink.c:1040 gen=
l_unbind+0x133/0x142()
[   20.456872] CPU: 0 PID: 109 Comm: trinity-main Tainted: G        W      =
3.18.0-11169-gc380d9a #9
[   20.457867]  0000000000000009 ffff88000b44fd38 ffffffff8175b593 ffff8800=
0b44fd78
[   20.458870]  ffffffff810b55aa 000000000000000b ffffffff8174d7e0 ffffffff=
834a3400
[   20.459759]  000000000000000b 0000000000000000 ffff88001202a520 ffff8800=
0b44fd88
[   20.460663] Call Trace:
[   20.460954]  [<ffffffff8175b593>] dump_stack+0x2e/0x3e
[   20.461547]  [<ffffffff810b55aa>] warn_slowpath_common+0xb6/0xe5
[   20.462289]  [<ffffffff8174d7e0>] ? genl_unbind+0x133/0x142
[   20.462981]  [<ffffffff810b56db>] warn_slowpath_null+0x23/0x2c
[   20.463631]  [<ffffffff8174d7e0>] genl_unbind+0x133/0x142
[   20.464282]  [<ffffffff8174b063>] netlink_release+0x364/0x3fd
[   20.464930]  [<ffffffff8170d262>] sock_release+0x23/0xa3
[   20.465538]  [<ffffffff8170d2f6>] sock_close+0x14/0x1f
[   20.466168]  [<ffffffff81199c9f>] __fput+0x16c/0x28e
[   20.466820]  [<ffffffff81199dd1>] ____fput+0x10/0x19
[   20.467384]  [<ffffffff810d1d20>] task_work_run+0xc7/0x116
[   20.467992]  [<ffffffff810b7e57>] do_exit+0x550/0xd1f
[   20.468638]  [<ffffffff8114553f>] ? context_tracking_user_exit+0xe2/0x101
[   20.469414]  [<ffffffff810b8776>] do_group_exit+0x107/0x127
[   20.470045]  [<ffffffff810b87ac>] SyS_exit_group+0x16/0x16
[   20.470833]  [<ffffffff8176a2e7>] system_call_fastpath+0x12/0x17
[   20.471508] ---[ end trace f8ae22d84a926bab ]---
[   20.472098] ------------[ cut here ]------------
[   20.472641] WARNING: CPU: 0 PID: 109 at net/netlink/genetlink.c:1040 gen=
l_unbind+0x133/0x142()
[   20.473786] CPU: 0 PID: 109 Comm: trinity-main Tainted: G        W      =
3.18.0-11169-gc380d9a #9
[   20.474921]  0000000000000009 ffff88000b44fd38 ffffffff8175b593 ffff8800=
0b44fd78
[   20.475815]  ffffffff810b55aa 000000000000000d ffffffff8174d7e0 ffffffff=
834a3400
[   20.476761]  000000000000000d 0000000000000000 ffff88001202a520 ffff8800=
0b44fd88
[   20.477659] Call Trace:
[   20.477950]  [<ffffffff8175b593>] dump_stack+0x2e/0x3e
[   20.478695]  [<ffffffff810b55aa>] warn_slowpath_common+0xb6/0xe5
[   20.479375]  [<ffffffff8174d7e0>] ? genl_unbind+0x133/0x142
[   20.479987]  [<ffffffff810b56db>] warn_slowpath_null+0x23/0x2c
[   20.480719]  [<ffffffff8174d7e0>] genl_unbind+0x133/0x142
[   20.481344]  [<ffffffff8174b063>] netlink_release+0x364/0x3fd
[   20.481997]  [<ffffffff8170d262>] sock_release+0x23/0xa3
[   20.482760]  [<ffffffff8170d2f6>] sock_close+0x14/0x1f
[   20.483344]  [<ffffffff81199c9f>] __fput+0x16c/0x28e
[   20.483899]  [<ffffffff81199dd1>] ____fput+0x10/0x19
[   20.484524]  [<ffffffff810d1d20>] task_work_run+0xc7/0x116
[   20.485151]  [<ffffffff810b7e57>] do_exit+0x550/0xd1f
[   20.485730]  [<ffffffff8114553f>] ? context_tracking_user_exit+0xe2/0x101
[   20.486640]  [<ffffffff810b8776>] do_group_exit+0x107/0x127
[   20.487268]  [<ffffffff810b87ac>] SyS_exit_group+0x16/0x16
[   20.487882]  [<ffffffff8176a2e7>] system_call_fastpath+0x12/0x17
[   20.488619] ---[ end trace f8ae22d84a926bac ]---
[   20.489148] ------------[ cut here ]------------
[   20.489679] WARNING: CPU: 0 PID: 109 at net/netlink/genetlink.c:1040 gen=
l_unbind+0x133/0x142()
[   20.490832] CPU: 0 PID: 109 Comm: trinity-main Tainted: G        W      =
3.18.0-11169-gc380d9a #9
[   20.491832]  0000000000000009 ffff88000b44fd38 ffffffff8175b593 ffff8800=
0b44fd78
[   20.492716]  ffffffff810b55aa 0000000000000012 ffffffff8174d7e0 ffffffff=
834a3400
[   20.493615]  0000000000000012 0000000000000000 ffff88001202a520 ffff8800=
0b44fd88
[   20.494501] Call Trace:
[   20.494783]  [<ffffffff8175b593>] dump_stack+0x2e/0x3e
[   20.495369]  [<ffffffff810b55aa>] warn_slowpath_common+0xb6/0xe5
[   20.496090]  [<ffffffff8174d7e0>] ? genl_unbind+0x133/0x142
[   20.496726]  [<ffffffff810b56db>] warn_slowpath_null+0x23/0x2c
[   20.497392]  [<ffffffff8174d7e0>] genl_unbind+0x133/0x142
[   20.498041]  [<ffffffff8174b063>] netlink_release+0x364/0x3fd
[   20.498676]  [<ffffffff8170d262>] sock_release+0x23/0xa3
[   20.499285]  [<ffffffff8170d2f6>] sock_close+0x14/0x1f
[   20.499863]  [<ffffffff81199c9f>] __fput+0x16c/0x28e
[   20.500445]  [<ffffffff81199dd1>] ____fput+0x10/0x19
[   20.501007]  [<ffffffff810d1d20>] task_work_run+0xc7/0x116
[   20.501620]  [<ffffffff810b7e57>] do_exit+0x550/0xd1f
[   20.502165]  [<ffffffff8114553f>] ? context_tracking_user_exit+0xe2/0x101
[   20.502935]  [<ffffffff810b8776>] do_group_exit+0x107/0x127
[   20.503550]  [<ffffffff810b87ac>] SyS_exit_group+0x16/0x16
[   20.504187]  [<ffffffff8176a2e7>] system_call_fastpath+0x12/0x17
[   20.504868] ---[ end trace f8ae22d84a926bad ]---
[   20.505448] ------------[ cut here ]------------
[   20.505985] WARNING: CPU: 0 PID: 109 at net/netlink/genetlink.c:1040 gen=
l_unbind+0x133/0x142()
[   20.507126] CPU: 0 PID: 109 Comm: trinity-main Tainted: G        W      =
3.18.0-11169-gc380d9a #9
[   20.508089]  0000000000000009 ffff88000b44fd38 ffffffff8175b593 ffff8800=
0b44fd78
[   20.508932]  ffffffff810b55aa 0000000000000013 ffffffff8174d7e0 ffffffff=
834a3400
[   20.509813]  0000000000000013 0000000000000000 ffff88001202a520 ffff8800=
0b44fd88
[   20.510725] Call Trace:
[   20.511021]  [<ffffffff8175b593>] dump_stack+0x2e/0x3e
[   20.511602]  [<ffffffff810b55aa>] warn_slowpath_common+0xb6/0xe5
[   20.512313]  [<ffffffff8174d7e0>] ? genl_unbind+0x133/0x142
[   20.512936]  [<ffffffff810b56db>] warn_slowpath_null+0x23/0x2c
[   20.513562]  [<ffffffff8174d7e0>] genl_unbind+0x133/0x142
[   20.514176]  [<ffffffff8174b063>] netlink_release+0x364/0x3fd
[   20.514782]  [<ffffffff8170d262>] sock_release+0x23/0xa3
[   20.515355]  [<ffffffff8170d2f6>] sock_close+0x14/0x1f
[   20.515918]  [<ffffffff81199c9f>] __fput+0x16c/0x28e
[   20.516478]  [<ffffffff81199dd1>] ____fput+0x10/0x19
[   20.517097]  [<ffffffff810d1d20>] task_work_run+0xc7/0x116
[   20.517689]  [<ffffffff810b7e57>] do_exit+0x550/0xd1f
[   20.518314]  [<ffffffff8114553f>] ? context_tracking_user_exit+0xe2/0x101
[   20.519272]  [<ffffffff810b8776>] do_group_exit+0x107/0x127
[   20.519982]  [<ffffffff810b87ac>] SyS_exit_group+0x16/0x16
[   20.520589]  [<ffffffff8176a2e7>] system_call_fastpath+0x12/0x17
[   20.521340] ---[ end trace f8ae22d84a926bae ]---
[   20.521876] ------------[ cut here ]------------
[   20.522538] WARNING: CPU: 0 PID: 109 at net/netlink/genetlink.c:1040 gen=
l_unbind+0x133/0x142()
[   20.523705] CPU: 0 PID: 109 Comm: trinity-main Tainted: G        W      =
3.18.0-11169-gc380d9a #9
[   20.524725]  0000000000000009 ffff88000b44fd38 ffffffff8175b593 ffff8800=
0b44fd78
[   20.525693]  ffffffff810b55aa 0000000000000015 ffffffff8174d7e0 ffffffff=
834a3400
[   20.526597]  0000000000000015 0000000000000000 ffff88001202a520 ffff8800=
0b44fd88
[   20.527496] Call Trace:
[   20.527785]  [<ffffffff8175b593>] dump_stack+0x2e/0x3e
[   20.528379]  [<ffffffff810b55aa>] warn_slowpath_common+0xb6/0xe5
[   20.529060]  [<ffffffff8174d7e0>] ? genl_unbind+0x133/0x142
[   20.529690]  [<ffffffff810b56db>] warn_slowpath_null+0x23/0x2c
[   20.530339]  [<ffffffff8174d7e0>] genl_unbind+0x133/0x142
[   20.530912]  [<ffffffff8174b063>] netlink_release+0x364/0x3fd
[   20.531536]  [<ffffffff8170d262>] sock_release+0x23/0xa3
[   20.532105]  [<ffffffff8170d2f6>] sock_close+0x14/0x1f
[   20.532673]  [<ffffffff81199c9f>] __fput+0x16c/0x28e
[   20.533186]  [<ffffffff81199dd1>] ____fput+0x10/0x19
[   20.533711]  [<ffffffff810d1d20>] task_work_run+0xc7/0x116
[   20.534392]  [<ffffffff810b7e57>] do_exit+0x550/0xd1f
[   20.535015]  [<ffffffff8114553f>] ? context_tracking_user_exit+0xe2/0x101
[   20.535828]  [<ffffffff810b8776>] do_group_exit+0x107/0x127
[   20.536539]  [<ffffffff810b87ac>] SyS_exit_group+0x16/0x16
[   20.537226]  [<ffffffff8176a2e7>] system_call_fastpath+0x12/0x17
[   20.537868] ---[ end trace f8ae22d84a926baf ]---
[   20.538554] ------------[ cut here ]------------
[   20.539147] WARNING: CPU: 0 PID: 109 at net/netlink/genetlink.c:1040 gen=
l_unbind+0x133/0x142()
[   20.540522] CPU: 0 PID: 109 Comm: trinity-main Tainted: G        W      =
3.18.0-11169-gc380d9a #9
[   20.541536]  0000000000000009 ffff88000b44fd38 ffffffff8175b593 ffff8800=
0b44fd78
[   20.542535]  ffffffff810b55aa 0000000000000017 ffffffff8174d7e0 ffffffff=
834a3400
[   20.543469]  0000000000000017 0000000000000000 ffff88001202a520 ffff8800=
0b44fd88
[   20.544427] Call Trace:
[   20.544695]  [<ffffffff8175b593>] dump_stack+0x2e/0x3e
[   20.545336]  [<ffffffff810b55aa>] warn_slowpath_common+0xb6/0xe5
[   20.545962]  [<ffffffff8174d7e0>] ? genl_unbind+0x133/0x142
[   20.546675]  [<ffffffff810b56db>] warn_slowpath_null+0x23/0x2c
[   20.547279]  [<ffffffff8174d7e0>] genl_unbind+0x133/0x142
[   20.548009]  [<ffffffff8174b063>] netlink_release+0x364/0x3fd
[   20.548633]  [<ffffffff8170d262>] sock_release+0x23/0xa3
[   20.549300]  [<ffffffff8170d2f6>] sock_close+0x14/0x1f
[   20.549846]  [<ffffffff81199c9f>] __fput+0x16c/0x28e
[   20.550493]  [<ffffffff81199dd1>] ____fput+0x10/0x19
[   20.551017]  [<ffffffff810d1d20>] task_work_run+0xc7/0x116
[   20.551694]  [<ffffffff810b7e57>] do_exit+0x550/0xd1f
[   20.552324]  [<ffffffff8114553f>] ? context_tracking_user_exit+0xe2/0x101
[   20.553243]  [<ffffffff810b8776>] do_group_exit+0x107/0x127
[   20.553831]  [<ffffffff810b87ac>] SyS_exit_group+0x16/0x16
[   20.554519]  [<ffffffff8176a2e7>] system_call_fastpath+0x12/0x17
[   20.555154] ---[ end trace f8ae22d84a926bb0 ]---
[   20.555794] ------------[ cut here ]------------
[   20.556484] WARNING: CPU: 0 PID: 109 at net/netlink/genetlink.c:1040 gen=
l_unbind+0x133/0x142()
[   20.557674] CPU: 0 PID: 109 Comm: trinity-main Tainted: G        W      =
3.18.0-11169-gc380d9a #9
[   20.558807]  0000000000000009 ffff88000b44fd38 ffffffff8175b593 ffff8800=
0b44fd78
[   20.559667]  ffffffff810b55aa 0000000000000018 ffffffff8174d7e0 ffffffff=
834a3400
[   20.560616]  0000000000000018 0000000000000000 ffff88001202a520 ffff8800=
0b44fd88
[   20.561543] Call Trace:
[   20.561841]  [<ffffffff8175b593>] dump_stack+0x2e/0x3e
[   20.562442]  [<ffffffff810b55aa>] warn_slowpath_common+0xb6/0xe5
[   20.563117]  [<ffffffff8174d7e0>] ? genl_unbind+0x133/0x142
[   20.563766]  [<ffffffff810b56db>] warn_slowpath_null+0x23/0x2c
[   20.564463]  [<ffffffff8174d7e0>] genl_unbind+0x133/0x142
[   20.565078]  [<ffffffff8174b063>] netlink_release+0x364/0x3fd
[   20.565727]  [<ffffffff8170d262>] sock_release+0x23/0xa3
[   20.566377]  [<ffffffff8170d2f6>] sock_close+0x14/0x1f
[   20.566955]  [<ffffffff81199c9f>] __fput+0x16c/0x28e
[   20.567558]  [<ffffffff81199dd1>] ____fput+0x10/0x19
[   20.568164]  [<ffffffff810d1d20>] task_work_run+0xc7/0x116
[   20.568830]  [<ffffffff810b7e57>] do_exit+0x550/0xd1f
[   20.569424]  [<ffffffff8114553f>] ? context_tracking_user_exit+0xe2/0x101
[   20.570225]  [<ffffffff810b8776>] do_group_exit+0x107/0x127
[   20.570858]  [<ffffffff810b87ac>] SyS_exit_group+0x16/0x16
[   20.571487]  [<ffffffff8176a2e7>] system_call_fastpath+0x12/0x17
[   20.572146] ---[ end trace f8ae22d84a926bb1 ]---
[   20.573027] ------------[ cut here ]------------
[   20.573565] WARNING: CPU: 0 PID: 109 at net/netlink/genetlink.c:1040 gen=
l_unbind+0x133/0x142()
[   20.574722] CPU: 0 PID: 109 Comm: trinity-main Tainted: G        W      =
3.18.0-11169-gc380d9a #9
[   20.575748]  0000000000000009 ffff88000b44fd38 ffffffff8175b593 ffff8800=
0b44fd78
[   20.576738]  ffffffff810b55aa 0000000000000001 ffffffff8174d7e0 ffffffff=
834a3400
[   20.577669]  0000000000000001 0000000000000000 ffff88001202a520 ffff8800=
0b44fd88
[   20.578605] Call Trace:
[   20.578925]  [<ffffffff8175b593>] dump_stack+0x2e/0x3e
[   20.579555]  [<ffffffff810b55aa>] warn_slowpath_common+0xb6/0xe5
[   20.580279]  [<ffffffff8174d7e0>] ? genl_unbind+0x133/0x142
[   20.580977]  [<ffffffff810b56db>] warn_slowpath_null+0x23/0x2c
[   20.581703]  [<ffffffff8174d7e0>] genl_unbind+0x133/0x142
[   20.582395]  [<ffffffff8174b063>] netlink_release+0x364/0x3fd
[   20.583105]  [<ffffffff8170d262>] sock_release+0x23/0xa3
[   20.583779]  [<ffffffff8170d2f6>] sock_close+0x14/0x1f
[   20.584448]  [<ffffffff81199c9f>] __fput+0x16c/0x28e
[   20.585078]  [<ffffffff81199dd1>] ____fput+0x10/0x19
[   20.585684]  [<ffffffff810d1d20>] task_work_run+0xc7/0x116
[   20.586416]  [<ffffffff810b7e57>] do_exit+0x550/0xd1f
[   20.587040]  [<ffffffff8114553f>] ? context_tracking_user_exit+0xe2/0x101
[   20.587912]  [<ffffffff810b8776>] do_group_exit+0x107/0x127
[   20.588573]  [<ffffffff810b87ac>] SyS_exit_group+0x16/0x16
[   20.589243]  [<ffffffff8176a2e7>] system_call_fastpath+0x12/0x17
[   20.589915] ---[ end trace f8ae22d84a926bb2 ]---
[   20.590493] ------------[ cut here ]------------
[   20.591024] WARNING: CPU: 0 PID: 109 at net/netlink/genetlink.c:1040 gen=
l_unbind+0x133/0x142()
[   20.592280] CPU: 0 PID: 109 Comm: trinity-main Tainted: G        W      =
3.18.0-11169-gc380d9a #9
[   20.593321]  0000000000000009 ffff88000b44fd38 ffffffff8175b593 ffff8800=
0b44fd78
[   20.594218]  ffffffff810b55aa 0000000000000007 ffffffff8174d7e0 ffffffff=
834a3400
[   20.595144]  0000000000000007 0000000000000000 ffff88001202a520 ffff8800=
0b44fd88
[   20.596080] Call Trace:
[   20.596384]  [<ffffffff8175b593>] dump_stack+0x2e/0x3e
[   20.596961]  [<ffffffff810b55aa>] warn_slowpath_common+0xb6/0xe5
[   20.597648]  [<ffffffff8174d7e0>] ? genl_unbind+0x133/0x142
[   20.598289]  [<ffffffff810b56db>] warn_slowpath_null+0x23/0x2c
[   20.599034]  [<ffffffff8174d7e0>] genl_unbind+0x133/0x142
[   20.599640]  [<ffffffff8174b063>] netlink_release+0x364/0x3fd
[   20.600469]  [<ffffffff8170d262>] sock_release+0x23/0xa3
[   20.601073]  [<ffffffff8170d2f6>] sock_close+0x14/0x1f
[   20.601649]  [<ffffffff81199c9f>] __fput+0x16c/0x28e
[   20.602292]  [<ffffffff81199dd1>] ____fput+0x10/0x19
[   20.602939]  [<ffffffff810d1d20>] task_work_run+0xc7/0x116
[   20.603627]  [<ffffffff810b7e57>] do_exit+0x550/0xd1f
[   20.604296]  [<ffffffff8114553f>] ? context_tracking_user_exit+0xe2/0x101
[   20.605120]  [<ffffffff810b8776>] do_group_exit+0x107/0x127
[   20.605743]  [<ffffffff810b87ac>] SyS_exit_group+0x16/0x16
[   20.606480]  [<ffffffff8176a2e7>] system_call_fastpath+0x12/0x17
[   20.607142] ---[ end trace f8ae22d84a926bb3 ]---
[   20.607763] ------------[ cut here ]------------
[   20.608392] WARNING: CPU: 0 PID: 109 at net/netlink/genetlink.c:1040 gen=
l_unbind+0x133/0x142()
[   20.609622] CPU: 0 PID: 109 Comm: trinity-main Tainted: G        W      =
3.18.0-11169-gc380d9a #9
[   20.610766]  0000000000000009 ffff88000b44fd38 ffffffff8175b593 ffff8800=
0b44fd78
[   20.611726]  ffffffff810b55aa 0000000000000009 ffffffff8174d7e0 ffffffff=
834a3400
[   20.612806]  0000000000000009 0000000000000000 ffff88001202a520 ffff8800=
0b44fd88
[   20.613762] Call Trace:
[   20.614045]  [<ffffffff8175b593>] dump_stack+0x2e/0x3e
[   20.614750]  [<ffffffff810b55aa>] warn_slowpath_common+0xb6/0xe5
[   20.615492]  [<ffffffff8174d7e0>] ? genl_unbind+0x133/0x142
[   20.616221]  [<ffffffff810b56db>] warn_slowpath_null+0x23/0x2c
[   20.616954]  [<ffffffff8174d7e0>] genl_unbind+0x133/0x142
[   20.617663]  [<ffffffff8174b063>] netlink_release+0x364/0x3fd
[   20.618461]  [<ffffffff8170d262>] sock_release+0x23/0xa3
[   20.619176]  [<ffffffff8170d2f6>] sock_close+0x14/0x1f
[   20.619831]  [<ffffffff81199c9f>] __fput+0x16c/0x28e
[   20.620492]  [<ffffffff81199dd1>] ____fput+0x10/0x19
[   20.621130]  [<ffffffff810d1d20>] task_work_run+0xc7/0x116
[   20.621719]  [<ffffffff810b7e57>] do_exit+0x550/0xd1f
[   20.622296]  [<ffffffff8114553f>] ? context_tracking_user_exit+0xe2/0x101
[   20.623049]  [<ffffffff810b8776>] do_group_exit+0x107/0x127
[   20.623753]  [<ffffffff810b87ac>] SyS_exit_group+0x16/0x16
[   20.624554]  [<ffffffff8176a2e7>] system_call_fastpath+0x12/0x17
[   20.625303] ---[ end trace f8ae22d84a926bb4 ]---
[   20.625838] ------------[ cut here ]------------
[   20.626539] WARNING: CPU: 0 PID: 109 at net/netlink/genetlink.c:1040 gen=
l_unbind+0x133/0x142()
[   20.627736] CPU: 0 PID: 109 Comm: trinity-main Tainted: G        W      =
3.18.0-11169-gc380d9a #9
[   20.628890]  0000000000000009 ffff88000b44fd38 ffffffff8175b593 ffff8800=
0b44fd78
[   20.629772]  ffffffff810b55aa 000000000000000d ffffffff8174d7e0 ffffffff=
834a3400
[   20.630830]  000000000000000d 0000000000000000 ffff88001202a520 ffff8800=
0b44fd88
[   20.631783] Call Trace:
[   20.632165]  [<ffffffff8175b593>] dump_stack+0x2e/0x3e
[   20.632823]  [<ffffffff810b55aa>] warn_slowpath_common+0xb6/0xe5
[   20.633583]  [<ffffffff8174d7e0>] ? genl_unbind+0x133/0x142
[   20.634320]  [<ffffffff810b56db>] warn_slowpath_null+0x23/0x2c
[   20.635056]  [<ffffffff8174d7e0>] genl_unbind+0x133/0x142
[   20.635745]  [<ffffffff8174b063>] netlink_release+0x364/0x3fd
[   20.636617]  [<ffffffff8170d262>] sock_release+0x23/0xa3
[   20.637299]  [<ffffffff8170d2f6>] sock_close+0x14/0x1f
[   20.637863]  [<ffffffff81199c9f>] __fput+0x16c/0x28e
[   20.638589]  [<ffffffff81199dd1>] ____fput+0x10/0x19
[   20.639237]  [<ffffffff810d1d20>] task_work_run+0xc7/0x116
[   20.640015]  [<ffffffff810b7e57>] do_exit+0x550/0xd1f
[   20.640603]  [<ffffffff8114553f>] ? context_tracking_user_exit+0xe2/0x101
[   20.641445]  [<ffffffff810b8776>] do_group_exit+0x107/0x127
[   20.642154]  [<ffffffff810b87ac>] SyS_exit_group+0x16/0x16
[   20.642861]  [<ffffffff8176a2e7>] system_call_fastpath+0x12/0x17
[   20.643608] ---[ end trace f8ae22d84a926bb5 ]---
[   20.644251] ------------[ cut here ]------------
[   20.644766] WARNING: CPU: 0 PID: 109 at net/netlink/genetlink.c:1040 gen=
l_unbind+0x133/0x142()
[   20.645961] CPU: 0 PID: 109 Comm: trinity-main Tainted: G        W      =
3.18.0-11169-gc380d9a #9
[   20.647100]  0000000000000009 ffff88000b44fd38 ffffffff8175b593 ffff8800=
0b44fd78
[   20.648166]  ffffffff810b55aa 0000000000000013 ffffffff8174d7e0 ffffffff=
834a3400
[   20.649146]  0000000000000013 0000000000000000 ffff88001202a520 ffff8800=
0b44fd88
[   20.650016] Call Trace:
[   20.650394]  [<ffffffff8175b593>] dump_stack+0x2e/0x3e
[   20.651045]  [<ffffffff810b55aa>] warn_slowpath_common+0xb6/0xe5
[   20.651800]  [<ffffffff8174d7e0>] ? genl_unbind+0x133/0x142
[   20.652628]  [<ffffffff810b56db>] warn_slowpath_null+0x23/0x2c
[   20.653368]  [<ffffffff8174d7e0>] genl_unbind+0x133/0x142
[   20.653958]  [<ffffffff8174b063>] netlink_release+0x364/0x3fd
[   20.654777]  [<ffffffff8170d262>] sock_release+0x23/0xa3
[   20.655358]  [<ffffffff8170d2f6>] sock_close+0x14/0x1f
[   20.656152]  [<ffffffff81199c9f>] __fput+0x16c/0x28e
[   20.656794]  [<ffffffff81199dd1>] ____fput+0x10/0x19
[   20.657433]  [<ffffffff810d1d20>] task_work_run+0xc7/0x116
[   20.658030]  [<ffffffff810b7e57>] do_exit+0x550/0xd1f
[   20.658849]  [<ffffffff8114553f>] ? context_tracking_user_exit+0xe2/0x101
[   20.659685]  [<ffffffff810b8776>] do_group_exit+0x107/0x127
[   20.660404]  [<ffffffff810b87ac>] SyS_exit_group+0x16/0x16
[   20.661005]  [<ffffffff8176a2e7>] system_call_fastpath+0x12/0x17
[   20.661755] ---[ end trace f8ae22d84a926bb6 ]---
[   20.662394] ------------[ cut here ]------------
[   20.662984] WARNING: CPU: 0 PID: 109 at net/netlink/genetlink.c:1040 gen=
l_unbind+0x133/0x142()
[   20.664306] CPU: 0 PID: 109 Comm: trinity-main Tainted: G        W      =
3.18.0-11169-gc380d9a #9
[   20.665355]  0000000000000009 ffff88000b44fd38 ffffffff8175b593 ffff8800=
0b44fd78
[   20.666293]  ffffffff810b55aa 0000000000000014 ffffffff8174d7e0 ffffffff=
834a3400
[   20.667220]  0000000000000014 0000000000000000 ffff88001202a520 ffff8800=
0b44fd88
[   20.668163] Call Trace:
[   20.668457]  [<ffffffff8175b593>] dump_stack+0x2e/0x3e
[   20.669039]  [<ffffffff810b55aa>] warn_slowpath_common+0xb6/0xe5
[   20.669711]  [<ffffffff8174d7e0>] ? genl_unbind+0x133/0x142
[   20.670385]  [<ffffffff810b56db>] warn_slowpath_null+0x23/0x2c
[   20.671065]  [<ffffffff8174d7e0>] genl_unbind+0x133/0x142
[   20.671706]  [<ffffffff8174b063>] netlink_release+0x364/0x3fd
[   20.672364]  [<ffffffff8170d262>] sock_release+0x23/0xa3
[   20.673102]  [<ffffffff8170d2f6>] sock_close+0x14/0x1f
[   20.674701]  [<ffffffff81199c9f>] __fput+0x16c/0x28e
[   20.675247]  [<ffffffff81199dd1>] ____fput+0x10/0x19
[   20.675991]  [<ffffffff810d1d20>] task_work_run+0xc7/0x116
[   20.676724]  [<ffffffff810b7e57>] do_exit+0x550/0xd1f
[   20.677373]  [<ffffffff8114553f>] ? context_tracking_user_exit+0xe2/0x101
[   20.678192]  [<ffffffff810b8776>] do_group_exit+0x107/0x127
[   20.678990]  [<ffffffff810b87ac>] SyS_exit_group+0x16/0x16
[   20.679693]  [<ffffffff8176a2e7>] system_call_fastpath+0x12/0x17
[   20.680461] ---[ end trace f8ae22d84a926bb7 ]---
[   20.681095] ------------[ cut here ]------------
[   20.681627] WARNING: CPU: 0 PID: 109 at net/netlink/genetlink.c:1040 gen=
l_unbind+0x133/0x142()
[   20.682904] CPU: 0 PID: 109 Comm: trinity-main Tainted: G        W      =
3.18.0-11169-gc380d9a #9
[   20.684073]  0000000000000009 ffff88000b44fd38 ffffffff8175b593 ffff8800=
0b44fd78
[   20.684943]  ffffffff810b55aa 0000000000000018 ffffffff8174d7e0 ffffffff=
834a3400
[   20.685902]  0000000000000018 0000000000000000 ffff88001202a520 ffff8800=
0b44fd88
[   20.686989] Call Trace:
[   20.687265]  [<ffffffff8175b593>] dump_stack+0x2e/0x3e
[   20.688006]  [<ffffffff810b55aa>] warn_slowpath_common+0xb6/0xe5
[   20.688690]  [<ffffffff8174d7e0>] ? genl_unbind+0x133/0x142
[   20.689484]  [<ffffffff810b56db>] warn_slowpath_null+0x23/0x2c
[   20.690210]  [<ffffffff8174d7e0>] genl_unbind+0x133/0x142
[   20.690900]  [<ffffffff8174b063>] netlink_release+0x364/0x3fd
[   20.691621]  [<ffffffff8170d262>] sock_release+0x23/0xa3
[   20.692343]  [<ffffffff8170d2f6>] sock_close+0x14/0x1f
[   20.692991]  [<ffffffff81199c9f>] __fput+0x16c/0x28e
[   20.693632]  [<ffffffff81199dd1>] ____fput+0x10/0x19
[   20.694272]  [<ffffffff810d1d20>] task_work_run+0xc7/0x116
[   20.694974]  [<ffffffff810b7e57>] do_exit+0x550/0xd1f
[   20.695607]  [<ffffffff8114553f>] ? context_tracking_user_exit+0xe2/0x101
[   20.696549]  [<ffffffff810b8776>] do_group_exit+0x107/0x127
[   20.697264]  [<ffffffff810b87ac>] SyS_exit_group+0x16/0x16
[   20.697867]  [<ffffffff8176a2e7>] system_call_fastpath+0x12/0x17
[   20.698704] ---[ end trace f8ae22d84a926bb8 ]---
[   61.756085] rcu-torture: rtc: ffffffff83194300 ver: 1 tfle: 0 rta: 1 rta=
f: 0 rtf: 0 rtmbe: 0 rtbke: 0 rtbre: 0 rtbf: 0 rtb: 0 nt: 1 barrier: 0/0:0 =
cbflood: 1
[   61.758004] rcu-torture: Reader Pipe:  2 0 0 0 0 0 0 0 0 0 0
[   61.758804] rcu-torture: Reader Batch:  2 0 0 0 0 0 0 0 0 0 0
[   61.759743] rcu-torture: Free-Block Circulation:  0 0 0 0 0 0 0 0 0 0 0
mount: proc has wrong device number or fs type proc not supported
/etc/rc6.d/S40umountfs: line 20: /proc/mounts: No such file or directory
cat: /proc/1/maps: No such file or directory
cat: /proc/1/maps: No such file or directory
cat: /proc/1/maps: No such file or directory
cat: /proc/1/maps: No such file or directory
cat: /proc/1/maps: No such file or directory
cat: /proc/1/maps: No such file or directory
umount: /var/run: not mounted
umount: /var/lock: not mounted
umount: /dev/shm: not mounted
 * Will now restart
[   72.956306] Unregister pv shared memory for cpu 0
[   72.956909] rcu-torture: Unscheduled system shutdown detected
[   72.957557] sbc60xxwdt: Watchdog timer is now disabled...
[   72.958779] reboot: Restarting system
[   72.959189] reboot: machine restart
Elapsed time: 80
qemu-system-x86_64 -cpu kvm64 -enable-kvm -kernel /kernel/x86_64-randconfig=
-n0-12271619/c380d9a7afff0e4c2e5f3c1c2dc7d2f4214dd962/vmlinuz-3.18.0-11169-=
gc380d9a -append 'hung_task_panic=3D1 earlyprintk=3DttyS0,115200 debug apic=
=3Ddebug sysrq_always_enabled rcupdate.rcu_cpu_stall_timeout=3D100 panic=3D=
-1 softlockup_panic=3D1 nmi_watchdog=3Dpanic oops=3Dpanic load_ramdisk=3D2 =
prompt_ramdisk=3D0 console=3DttyS0,115200 console=3Dtty0 vga=3Dnormal  root=
=3D/dev/ram0 rw link=3D/kbuild-tests/run-queue/kvm/x86_64-randconfig-n0-122=
71619/linux-devel:devel-lkp-nhm1-smoke-201412271621:c380d9a7afff0e4c2e5f3c1=
c2dc7d2f4214dd962:bisect-linux-1/.vmlinuz-c380d9a7afff0e4c2e5f3c1c2dc7d2f42=
14dd962-20141227174430-26-client7 branch=3Dlinux-devel/devel-lkp-nhm1-smoke=
-201412271621 BOOT_IMAGE=3D/kernel/x86_64-randconfig-n0-12271619/c380d9a7af=
ff0e4c2e5f3c1c2dc7d2f4214dd962/vmlinuz-3.18.0-11169-gc380d9a drbd.minor_cou=
nt=3D8'  -initrd /kernel-tests/initrd/quantal-core-x86_64.cgz -m 320 -smp 2=
 -net nic,vlan=3D1,model=3De1000 -net user,vlan=3D1 -boot order=3Dnc -no-re=
boot -watchdog i6300esb -rtc base=3Dlocaltime -pidfile /dev/shm/kboot/pid-q=
uantal-client7-25 -serial file:/dev/shm/kboot/serial-quantal-client7-25 -da=
emonize -display none -monitor null=20

--OgqxwSJOaUobr8KG
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="config-3.18.0-11169-gc380d9a"

#
# Automatically generated file; DO NOT EDIT.
# Linux/x86_64 3.18.0 Kernel Configuration
#
CONFIG_64BIT=y
CONFIG_X86_64=y
CONFIG_X86=y
CONFIG_INSTRUCTION_DECODER=y
CONFIG_PERF_EVENTS_INTEL_UNCORE=y
CONFIG_OUTPUT_FORMAT="elf64-x86-64"
CONFIG_ARCH_DEFCONFIG="arch/x86/configs/x86_64_defconfig"
CONFIG_LOCKDEP_SUPPORT=y
CONFIG_STACKTRACE_SUPPORT=y
CONFIG_HAVE_LATENCYTOP_SUPPORT=y
CONFIG_MMU=y
CONFIG_NEED_DMA_MAP_STATE=y
CONFIG_NEED_SG_DMA_LENGTH=y
CONFIG_GENERIC_BUG=y
CONFIG_GENERIC_BUG_RELATIVE_POINTERS=y
CONFIG_GENERIC_HWEIGHT=y
CONFIG_RWSEM_XCHGADD_ALGORITHM=y
CONFIG_GENERIC_CALIBRATE_DELAY=y
CONFIG_ARCH_HAS_CPU_RELAX=y
CONFIG_ARCH_HAS_CACHE_LINE_SIZE=y
CONFIG_HAVE_SETUP_PER_CPU_AREA=y
CONFIG_NEED_PER_CPU_EMBED_FIRST_CHUNK=y
CONFIG_NEED_PER_CPU_PAGE_FIRST_CHUNK=y
CONFIG_ARCH_HIBERNATION_POSSIBLE=y
CONFIG_ARCH_SUSPEND_POSSIBLE=y
CONFIG_ARCH_WANT_HUGE_PMD_SHARE=y
CONFIG_ARCH_WANT_GENERAL_HUGETLB=y
CONFIG_ZONE_DMA32=y
CONFIG_AUDIT_ARCH=y
CONFIG_ARCH_SUPPORTS_OPTIMIZED_INLINING=y
CONFIG_ARCH_SUPPORTS_DEBUG_PAGEALLOC=y
CONFIG_X86_INTEL_MPX=y
CONFIG_ARCH_HWEIGHT_CFLAGS="-fcall-saved-rdi -fcall-saved-rsi -fcall-saved-rdx -fcall-saved-rcx -fcall-saved-r8 -fcall-saved-r9 -fcall-saved-r10 -fcall-saved-r11"
CONFIG_ARCH_SUPPORTS_UPROBES=y
CONFIG_FIX_EARLYCON_MEM=y
CONFIG_DEFCONFIG_LIST="/lib/modules/$UNAME_RELEASE/.config"
CONFIG_CONSTRUCTORS=y
CONFIG_IRQ_WORK=y
CONFIG_BUILDTIME_EXTABLE_SORT=y

#
# General setup
#
CONFIG_BROKEN_ON_SMP=y
CONFIG_INIT_ENV_ARG_LIMIT=32
CONFIG_CROSS_COMPILE=""
# CONFIG_COMPILE_TEST is not set
CONFIG_LOCALVERSION=""
CONFIG_LOCALVERSION_AUTO=y
CONFIG_HAVE_KERNEL_GZIP=y
CONFIG_HAVE_KERNEL_BZIP2=y
CONFIG_HAVE_KERNEL_LZMA=y
CONFIG_HAVE_KERNEL_XZ=y
CONFIG_HAVE_KERNEL_LZO=y
CONFIG_HAVE_KERNEL_LZ4=y
# CONFIG_KERNEL_GZIP is not set
# CONFIG_KERNEL_BZIP2 is not set
# CONFIG_KERNEL_LZMA is not set
# CONFIG_KERNEL_XZ is not set
CONFIG_KERNEL_LZO=y
# CONFIG_KERNEL_LZ4 is not set
CONFIG_DEFAULT_HOSTNAME="(none)"
CONFIG_SYSVIPC=y
# CONFIG_POSIX_MQUEUE is not set
CONFIG_CROSS_MEMORY_ATTACH=y
CONFIG_FHANDLE=y
CONFIG_USELIB=y
# CONFIG_AUDIT is not set
CONFIG_HAVE_ARCH_AUDITSYSCALL=y

#
# IRQ subsystem
#
CONFIG_GENERIC_IRQ_PROBE=y
CONFIG_GENERIC_IRQ_SHOW=y
CONFIG_GENERIC_IRQ_LEGACY_ALLOC_HWIRQ=y
CONFIG_IRQ_DOMAIN=y
# CONFIG_IRQ_DOMAIN_DEBUG is not set
CONFIG_IRQ_FORCED_THREADING=y
CONFIG_SPARSE_IRQ=y
CONFIG_CLOCKSOURCE_WATCHDOG=y
CONFIG_ARCH_CLOCKSOURCE_DATA=y
CONFIG_CLOCKSOURCE_VALIDATE_LAST_CYCLE=y
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
CONFIG_NO_HZ_COMMON=y
# CONFIG_HZ_PERIODIC is not set
CONFIG_NO_HZ_IDLE=y
CONFIG_NO_HZ=y
CONFIG_HIGH_RES_TIMERS=y

#
# CPU/Task time and stats accounting
#
CONFIG_VIRT_CPU_ACCOUNTING=y
# CONFIG_TICK_CPU_ACCOUNTING is not set
CONFIG_VIRT_CPU_ACCOUNTING_GEN=y
# CONFIG_IRQ_TIME_ACCOUNTING is not set
CONFIG_BSD_PROCESS_ACCT=y
CONFIG_BSD_PROCESS_ACCT_V3=y
# CONFIG_TASKSTATS is not set

#
# RCU Subsystem
#
CONFIG_TINY_RCU=y
# CONFIG_TASKS_RCU is not set
# CONFIG_RCU_STALL_COMMON is not set
CONFIG_CONTEXT_TRACKING=y
CONFIG_CONTEXT_TRACKING_FORCE=y
# CONFIG_TREE_RCU_TRACE is not set
CONFIG_BUILD_BIN2C=y
CONFIG_IKCONFIG=y
CONFIG_LOG_BUF_SHIFT=17
CONFIG_HAVE_UNSTABLE_SCHED_CLOCK=y
CONFIG_ARCH_SUPPORTS_NUMA_BALANCING=y
CONFIG_ARCH_SUPPORTS_INT128=y
CONFIG_CGROUPS=y
CONFIG_CGROUP_DEBUG=y
# CONFIG_CGROUP_FREEZER is not set
CONFIG_CGROUP_DEVICE=y
CONFIG_CPUSETS=y
# CONFIG_PROC_PID_CPUSET is not set
# CONFIG_CGROUP_CPUACCT is not set
# CONFIG_MEMCG is not set
CONFIG_CGROUP_PERF=y
CONFIG_CGROUP_SCHED=y
CONFIG_FAIR_GROUP_SCHED=y
# CONFIG_CFS_BANDWIDTH is not set
CONFIG_RT_GROUP_SCHED=y
CONFIG_CHECKPOINT_RESTORE=y
# CONFIG_NAMESPACES is not set
CONFIG_SCHED_AUTOGROUP=y
# CONFIG_SYSFS_DEPRECATED is not set
# CONFIG_RELAY is not set
CONFIG_BLK_DEV_INITRD=y
CONFIG_INITRAMFS_SOURCE=""
CONFIG_RD_GZIP=y
# CONFIG_RD_BZIP2 is not set
# CONFIG_RD_LZMA is not set
# CONFIG_RD_XZ is not set
CONFIG_RD_LZO=y
CONFIG_RD_LZ4=y
# CONFIG_INIT_FALLBACK is not set
CONFIG_CC_OPTIMIZE_FOR_SIZE=y
CONFIG_ANON_INODES=y
CONFIG_SYSCTL_EXCEPTION_TRACE=y
CONFIG_HAVE_PCSPKR_PLATFORM=y
CONFIG_BPF=y
CONFIG_EXPERT=y
# CONFIG_SGETMASK_SYSCALL is not set
# CONFIG_SYSFS_SYSCALL is not set
CONFIG_KALLSYMS=y
CONFIG_KALLSYMS_ALL=y
CONFIG_PRINTK=y
CONFIG_BUG=y
CONFIG_PCSPKR_PLATFORM=y
CONFIG_BASE_FULL=y
CONFIG_FUTEX=y
CONFIG_EPOLL=y
# CONFIG_SIGNALFD is not set
# CONFIG_TIMERFD is not set
CONFIG_EVENTFD=y
CONFIG_BPF_SYSCALL=y
# CONFIG_SHMEM is not set
CONFIG_AIO=y
# CONFIG_ADVISE_SYSCALLS is not set
CONFIG_PCI_QUIRKS=y
# CONFIG_EMBEDDED is not set
CONFIG_HAVE_PERF_EVENTS=y

#
# Kernel Performance Events And Counters
#
CONFIG_PERF_EVENTS=y
# CONFIG_DEBUG_PERF_USE_VMALLOC is not set
# CONFIG_VM_EVENT_COUNTERS is not set
# CONFIG_SLUB_DEBUG is not set
# CONFIG_COMPAT_BRK is not set
# CONFIG_SLAB is not set
CONFIG_SLUB=y
# CONFIG_SLOB is not set
# CONFIG_SYSTEM_TRUSTED_KEYRING is not set
CONFIG_PROFILING=y
# CONFIG_OPROFILE is not set
CONFIG_HAVE_OPROFILE=y
CONFIG_OPROFILE_NMI_TIMER=y
CONFIG_JUMP_LABEL=y
# CONFIG_UPROBES is not set
# CONFIG_HAVE_64BIT_ALIGNED_ACCESS is not set
CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS=y
CONFIG_ARCH_USE_BUILTIN_BSWAP=y
CONFIG_HAVE_IOREMAP_PROT=y
CONFIG_HAVE_KPROBES=y
CONFIG_HAVE_KRETPROBES=y
CONFIG_HAVE_OPTPROBES=y
CONFIG_HAVE_KPROBES_ON_FTRACE=y
CONFIG_HAVE_ARCH_TRACEHOOK=y
CONFIG_HAVE_DMA_ATTRS=y
CONFIG_HAVE_DMA_CONTIGUOUS=y
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
CONFIG_HAVE_ARCH_SECCOMP_FILTER=y
CONFIG_HAVE_CC_STACKPROTECTOR=y
CONFIG_CC_STACKPROTECTOR=y
# CONFIG_CC_STACKPROTECTOR_NONE is not set
CONFIG_CC_STACKPROTECTOR_REGULAR=y
# CONFIG_CC_STACKPROTECTOR_STRONG is not set
CONFIG_HAVE_CONTEXT_TRACKING=y
CONFIG_HAVE_VIRT_CPU_ACCOUNTING_GEN=y
CONFIG_HAVE_IRQ_TIME_ACCOUNTING=y
CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE=y
CONFIG_HAVE_ARCH_SOFT_DIRTY=y
CONFIG_MODULES_USE_ELF_RELA=y
CONFIG_HAVE_IRQ_EXIT_ON_IRQ_STACK=y

#
# GCOV-based kernel profiling
#
CONFIG_GCOV_KERNEL=y
CONFIG_ARCH_HAS_GCOV_PROFILE_ALL=y
CONFIG_GCOV_PROFILE_ALL=y
# CONFIG_GCOV_FORMAT_AUTODETECT is not set
# CONFIG_GCOV_FORMAT_3_4 is not set
CONFIG_GCOV_FORMAT_4_7=y
# CONFIG_HAVE_GENERIC_DMA_COHERENT is not set
CONFIG_RT_MUTEXES=y
CONFIG_BASE_SMALL=0
# CONFIG_MODULES is not set
# CONFIG_BLOCK is not set
CONFIG_UNINLINE_SPIN_UNLOCK=y
CONFIG_ARCH_SUPPORTS_ATOMIC_RMW=y
CONFIG_ARCH_USE_QUEUE_RWLOCK=y
CONFIG_FREEZER=y

#
# Processor type and features
#
CONFIG_ZONE_DMA=y
# CONFIG_SMP is not set
CONFIG_X86_FEATURE_NAMES=y
CONFIG_X86_MPPARSE=y
CONFIG_X86_EXTENDED_PLATFORM=y
# CONFIG_X86_GOLDFISH is not set
# CONFIG_X86_INTEL_LPSS is not set
# CONFIG_IOSF_MBI is not set
# CONFIG_SCHED_OMIT_FRAME_POINTER is not set
CONFIG_HYPERVISOR_GUEST=y
CONFIG_PARAVIRT=y
# CONFIG_PARAVIRT_DEBUG is not set
# CONFIG_XEN is not set
CONFIG_KVM_GUEST=y
# CONFIG_KVM_DEBUG_FS is not set
# CONFIG_PARAVIRT_TIME_ACCOUNTING is not set
CONFIG_PARAVIRT_CLOCK=y
CONFIG_NO_BOOTMEM=y
# CONFIG_MEMTEST is not set
# CONFIG_MK8 is not set
# CONFIG_MPSC is not set
CONFIG_MCORE2=y
# CONFIG_MATOM is not set
# CONFIG_GENERIC_CPU is not set
CONFIG_X86_INTERNODE_CACHE_SHIFT=6
CONFIG_X86_L1_CACHE_SHIFT=6
CONFIG_X86_INTEL_USERCOPY=y
CONFIG_X86_USE_PPRO_CHECKSUM=y
CONFIG_X86_P6_NOP=y
CONFIG_X86_TSC=y
CONFIG_X86_CMPXCHG64=y
CONFIG_X86_CMOV=y
CONFIG_X86_MINIMUM_CPU_FAMILY=64
CONFIG_X86_DEBUGCTLMSR=y
# CONFIG_PROCESSOR_SELECT is not set
CONFIG_CPU_SUP_INTEL=y
CONFIG_CPU_SUP_AMD=y
CONFIG_CPU_SUP_CENTAUR=y
CONFIG_HPET_TIMER=y
# CONFIG_DMI is not set
# CONFIG_GART_IOMMU is not set
# CONFIG_CALGARY_IOMMU is not set
CONFIG_SWIOTLB=y
CONFIG_IOMMU_HELPER=y
CONFIG_NR_CPUS=1
# CONFIG_PREEMPT_NONE is not set
CONFIG_PREEMPT_VOLUNTARY=y
# CONFIG_PREEMPT is not set
CONFIG_PREEMPT_COUNT=y
CONFIG_X86_LOCAL_APIC=y
CONFIG_X86_IO_APIC=y
# CONFIG_X86_REROUTE_FOR_BROKEN_BOOT_IRQS is not set
# CONFIG_X86_MCE is not set
# CONFIG_X86_16BIT is not set
CONFIG_X86_VSYSCALL_EMULATION=y
CONFIG_I8K=y
CONFIG_MICROCODE=y
CONFIG_MICROCODE_INTEL=y
CONFIG_MICROCODE_AMD=y
CONFIG_MICROCODE_OLD_INTERFACE=y
# CONFIG_MICROCODE_INTEL_EARLY is not set
# CONFIG_MICROCODE_AMD_EARLY is not set
# CONFIG_MICROCODE_EARLY is not set
CONFIG_X86_MSR=y
# CONFIG_X86_CPUID is not set
CONFIG_ARCH_PHYS_ADDR_T_64BIT=y
CONFIG_ARCH_DMA_ADDR_T_64BIT=y
CONFIG_DIRECT_GBPAGES=y
CONFIG_ARCH_SPARSEMEM_ENABLE=y
CONFIG_ARCH_SPARSEMEM_DEFAULT=y
CONFIG_ARCH_SELECT_MEMORY_MODEL=y
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
# CONFIG_HAVE_BOOTMEM_INFO_NODE is not set
# CONFIG_MEMORY_HOTPLUG is not set
CONFIG_PAGEFLAGS_EXTENDED=y
CONFIG_SPLIT_PTLOCK_CPUS=4
CONFIG_ARCH_ENABLE_SPLIT_PMD_PTLOCK=y
CONFIG_COMPACTION=y
CONFIG_MIGRATION=y
CONFIG_PHYS_ADDR_T_64BIT=y
CONFIG_ZONE_DMA_FLAG=1
CONFIG_VIRT_TO_BUS=y
CONFIG_KSM=y
CONFIG_DEFAULT_MMAP_MIN_ADDR=4096
CONFIG_TRANSPARENT_HUGEPAGE=y
CONFIG_TRANSPARENT_HUGEPAGE_ALWAYS=y
# CONFIG_TRANSPARENT_HUGEPAGE_MADVISE is not set
CONFIG_NEED_PER_CPU_KM=y
# CONFIG_CLEANCACHE is not set
# CONFIG_CMA is not set
CONFIG_ZPOOL=y
CONFIG_ZBUD=y
CONFIG_ZSMALLOC=y
# CONFIG_PGTABLE_MAPPING is not set
CONFIG_GENERIC_EARLY_IOREMAP=y
CONFIG_X86_CHECK_BIOS_CORRUPTION=y
# CONFIG_X86_BOOTPARAM_MEMORY_CORRUPTION_CHECK is not set
CONFIG_X86_RESERVE_LOW=64
# CONFIG_MTRR is not set
CONFIG_ARCH_RANDOM=y
# CONFIG_X86_SMAP is not set
# CONFIG_EFI is not set
# CONFIG_SECCOMP is not set
# CONFIG_HZ_100 is not set
CONFIG_HZ_250=y
# CONFIG_HZ_300 is not set
# CONFIG_HZ_1000 is not set
CONFIG_HZ=250
CONFIG_SCHED_HRTICK=y
# CONFIG_KEXEC is not set
CONFIG_CRASH_DUMP=y
CONFIG_PHYSICAL_START=0x1000000
CONFIG_RELOCATABLE=y
# CONFIG_RANDOMIZE_BASE is not set
CONFIG_PHYSICAL_ALIGN=0x200000
# CONFIG_CMDLINE_BOOL is not set
CONFIG_ARCH_ENABLE_MEMORY_HOTPLUG=y

#
# Power management and ACPI options
#
CONFIG_SUSPEND=y
CONFIG_SUSPEND_FREEZER=y
CONFIG_PM_SLEEP=y
# CONFIG_PM_AUTOSLEEP is not set
CONFIG_PM_WAKELOCKS=y
CONFIG_PM_WAKELOCKS_LIMIT=100
CONFIG_PM_WAKELOCKS_GC=y
CONFIG_PM_RUNTIME=y
CONFIG_PM=y
CONFIG_PM_DEBUG=y
# CONFIG_PM_ADVANCED_DEBUG is not set
CONFIG_PM_SLEEP_DEBUG=y
CONFIG_PM_TRACE=y
CONFIG_PM_TRACE_RTC=y
# CONFIG_WQ_POWER_EFFICIENT_DEFAULT is not set
CONFIG_ACPI=y
CONFIG_ACPI_LEGACY_TABLES_LOOKUP=y
CONFIG_ARCH_MIGHT_HAVE_ACPI_PDC=y
CONFIG_ACPI_SLEEP=y
# CONFIG_ACPI_EC_DEBUGFS is not set
CONFIG_ACPI_AC=y
CONFIG_ACPI_BATTERY=y
CONFIG_ACPI_BUTTON=y
CONFIG_ACPI_FAN=y
# CONFIG_ACPI_DOCK is not set
CONFIG_ACPI_PROCESSOR=y
# CONFIG_ACPI_IPMI is not set
# CONFIG_ACPI_PROCESSOR_AGGREGATOR is not set
CONFIG_ACPI_THERMAL=y
# CONFIG_ACPI_CUSTOM_DSDT is not set
# CONFIG_ACPI_INITRD_TABLE_OVERRIDE is not set
# CONFIG_ACPI_DEBUG is not set
# CONFIG_ACPI_PCI_SLOT is not set
CONFIG_X86_PM_TIMER=y
# CONFIG_ACPI_CONTAINER is not set
# CONFIG_ACPI_SBS is not set
# CONFIG_ACPI_HED is not set
# CONFIG_ACPI_CUSTOM_METHOD is not set
# CONFIG_ACPI_REDUCED_HARDWARE_ONLY is not set
CONFIG_HAVE_ACPI_APEI=y
CONFIG_HAVE_ACPI_APEI_NMI=y
# CONFIG_ACPI_APEI is not set
# CONFIG_PMIC_OPREGION is not set
CONFIG_SFI=y

#
# CPU Frequency scaling
#
CONFIG_CPU_FREQ=y
CONFIG_CPU_FREQ_GOV_COMMON=y
# CONFIG_CPU_FREQ_STAT is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_PERFORMANCE is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_POWERSAVE is not set
CONFIG_CPU_FREQ_DEFAULT_GOV_USERSPACE=y
# CONFIG_CPU_FREQ_DEFAULT_GOV_ONDEMAND is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_CONSERVATIVE is not set
CONFIG_CPU_FREQ_GOV_PERFORMANCE=y
# CONFIG_CPU_FREQ_GOV_POWERSAVE is not set
CONFIG_CPU_FREQ_GOV_USERSPACE=y
CONFIG_CPU_FREQ_GOV_ONDEMAND=y
CONFIG_CPU_FREQ_GOV_CONSERVATIVE=y

#
# CPU frequency scaling drivers
#
CONFIG_X86_INTEL_PSTATE=y
# CONFIG_X86_PCC_CPUFREQ is not set
# CONFIG_X86_ACPI_CPUFREQ is not set
# CONFIG_X86_SPEEDSTEP_CENTRINO is not set
CONFIG_X86_P4_CLOCKMOD=y

#
# shared options
#
CONFIG_X86_SPEEDSTEP_LIB=y

#
# CPU Idle
#
CONFIG_CPU_IDLE=y
CONFIG_CPU_IDLE_GOV_LADDER=y
CONFIG_CPU_IDLE_GOV_MENU=y
# CONFIG_ARCH_NEEDS_CPU_IDLE_COUPLED is not set
CONFIG_INTEL_IDLE=y

#
# Memory power savings
#
CONFIG_I7300_IDLE_IOAT_CHANNEL=y
CONFIG_I7300_IDLE=y

#
# Bus options (PCI etc.)
#
CONFIG_PCI=y
CONFIG_PCI_DIRECT=y
# CONFIG_PCI_MMCONFIG is not set
CONFIG_PCI_DOMAINS=y
# CONFIG_PCI_CNB20LE_QUIRK is not set
# CONFIG_PCIEPORTBUS is not set
# CONFIG_PCI_MSI is not set
# CONFIG_PCI_DEBUG is not set
# CONFIG_PCI_REALLOC_ENABLE_AUTO is not set
# CONFIG_PCI_STUB is not set
CONFIG_HT_IRQ=y
# CONFIG_PCI_IOV is not set
# CONFIG_PCI_PRI is not set
# CONFIG_PCI_PASID is not set
# CONFIG_PCI_IOAPIC is not set
CONFIG_PCI_LABEL=y

#
# PCI host controller drivers
#
# CONFIG_ISA_DMA_API is not set
CONFIG_AMD_NB=y
CONFIG_PCCARD=y
CONFIG_PCMCIA=y
# CONFIG_PCMCIA_LOAD_CIS is not set
CONFIG_CARDBUS=y

#
# PC-card bridges
#
# CONFIG_YENTA is not set
# CONFIG_PD6729 is not set
# CONFIG_I82092 is not set
# CONFIG_HOTPLUG_PCI is not set
# CONFIG_RAPIDIO is not set
# CONFIG_X86_SYSFB is not set

#
# Executable file formats / Emulations
#
CONFIG_BINFMT_ELF=y
CONFIG_ARCH_BINFMT_ELF_RANDOMIZE_PIE=y
CONFIG_BINFMT_SCRIPT=y
# CONFIG_HAVE_AOUT is not set
# CONFIG_BINFMT_MISC is not set
# CONFIG_COREDUMP is not set
# CONFIG_IA32_EMULATION is not set
CONFIG_X86_DEV_DMA_OPS=y
CONFIG_PMC_ATOM=y
CONFIG_NET=y

#
# Networking options
#
# CONFIG_PACKET is not set
CONFIG_UNIX=y
# CONFIG_UNIX_DIAG is not set
# CONFIG_NET_KEY is not set
# CONFIG_INET is not set
# CONFIG_NETWORK_SECMARK is not set
# CONFIG_NET_PTP_CLASSIFY is not set
# CONFIG_NETWORK_PHY_TIMESTAMPING is not set
# CONFIG_NETFILTER is not set
# CONFIG_ATM is not set
# CONFIG_BRIDGE is not set
# CONFIG_VLAN_8021Q is not set
# CONFIG_DECNET is not set
# CONFIG_LLC2 is not set
# CONFIG_IPX is not set
# CONFIG_ATALK is not set
# CONFIG_X25 is not set
# CONFIG_LAPB is not set
# CONFIG_PHONET is not set
# CONFIG_IEEE802154 is not set
# CONFIG_NET_SCHED is not set
# CONFIG_DCB is not set
# CONFIG_DNS_RESOLVER is not set
# CONFIG_BATMAN_ADV is not set
# CONFIG_VSOCKETS is not set
# CONFIG_NETLINK_MMAP is not set
# CONFIG_NETLINK_DIAG is not set
# CONFIG_NET_MPLS_GSO is not set
# CONFIG_HSR is not set
# CONFIG_CGROUP_NET_PRIO is not set
# CONFIG_CGROUP_NET_CLASSID is not set
CONFIG_NET_RX_BUSY_POLL=y
CONFIG_BQL=y

#
# Network testing
#
# CONFIG_HAMRADIO is not set
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
# CONFIG_RFKILL_REGULATOR is not set
# CONFIG_NET_9P is not set
# CONFIG_CAIF is not set
# CONFIG_NFC is not set
CONFIG_HAVE_BPF_JIT=y

#
# Device Drivers
#

#
# Generic Driver Options
#
# CONFIG_UEVENT_HELPER is not set
# CONFIG_DEVTMPFS is not set
CONFIG_STANDALONE=y
# CONFIG_PREVENT_FIRMWARE_BUILD is not set
CONFIG_FW_LOADER=y
# CONFIG_FIRMWARE_IN_KERNEL is not set
CONFIG_EXTRA_FIRMWARE=""
CONFIG_FW_LOADER_USER_HELPER=y
# CONFIG_FW_LOADER_USER_HELPER_FALLBACK is not set
CONFIG_ALLOW_DEV_COREDUMP=y
# CONFIG_DEBUG_DRIVER is not set
# CONFIG_DEBUG_DEVRES is not set
# CONFIG_SYS_HYPERVISOR is not set
# CONFIG_GENERIC_CPU_DEVICES is not set
CONFIG_GENERIC_CPU_AUTOPROBE=y
CONFIG_REGMAP=y
CONFIG_REGMAP_I2C=y
CONFIG_REGMAP_MMIO=y
CONFIG_REGMAP_IRQ=y
# CONFIG_DMA_SHARED_BUFFER is not set

#
# Bus devices
#
# CONFIG_CONNECTOR is not set
CONFIG_MTD=y
# CONFIG_MTD_REDBOOT_PARTS is not set
# CONFIG_MTD_CMDLINE_PARTS is not set
# CONFIG_MTD_AR7_PARTS is not set

#
# User Modules And Translation Layers
#
CONFIG_MTD_OOPS=y

#
# RAM/ROM/Flash chip drivers
#
# CONFIG_MTD_CFI is not set
CONFIG_MTD_JEDECPROBE=y
CONFIG_MTD_GEN_PROBE=y
# CONFIG_MTD_CFI_ADV_OPTIONS is not set
CONFIG_MTD_MAP_BANK_WIDTH_1=y
CONFIG_MTD_MAP_BANK_WIDTH_2=y
CONFIG_MTD_MAP_BANK_WIDTH_4=y
# CONFIG_MTD_MAP_BANK_WIDTH_8 is not set
# CONFIG_MTD_MAP_BANK_WIDTH_16 is not set
# CONFIG_MTD_MAP_BANK_WIDTH_32 is not set
CONFIG_MTD_CFI_I1=y
CONFIG_MTD_CFI_I2=y
# CONFIG_MTD_CFI_I4 is not set
# CONFIG_MTD_CFI_I8 is not set
CONFIG_MTD_CFI_INTELEXT=y
# CONFIG_MTD_CFI_AMDSTD is not set
# CONFIG_MTD_CFI_STAA is not set
CONFIG_MTD_CFI_UTIL=y
CONFIG_MTD_RAM=y
CONFIG_MTD_ROM=y
CONFIG_MTD_ABSENT=y

#
# Mapping drivers for chip access
#
# CONFIG_MTD_COMPLEX_MAPPINGS is not set
CONFIG_MTD_PHYSMAP=y
CONFIG_MTD_PHYSMAP_COMPAT=y
CONFIG_MTD_PHYSMAP_START=0x8000000
CONFIG_MTD_PHYSMAP_LEN=0
CONFIG_MTD_PHYSMAP_BANKWIDTH=2
CONFIG_MTD_AMD76XROM=y
# CONFIG_MTD_ICHXROM is not set
# CONFIG_MTD_ESB2ROM is not set
# CONFIG_MTD_CK804XROM is not set
# CONFIG_MTD_SCB2_FLASH is not set
# CONFIG_MTD_NETtel is not set
# CONFIG_MTD_L440GX is not set
# CONFIG_MTD_INTEL_VR_NOR is not set
CONFIG_MTD_PLATRAM=y

#
# Self-contained MTD device drivers
#
# CONFIG_MTD_PMC551 is not set
CONFIG_MTD_SLRAM=y
CONFIG_MTD_PHRAM=y
CONFIG_MTD_MTDRAM=y
CONFIG_MTDRAM_TOTAL_SIZE=4096
CONFIG_MTDRAM_ERASE_SIZE=128
CONFIG_MTDRAM_ABS_POS=0

#
# Disk-On-Chip Device Drivers
#
# CONFIG_MTD_DOCG3 is not set
CONFIG_MTD_NAND_ECC=y
CONFIG_MTD_NAND_ECC_SMC=y
CONFIG_MTD_NAND=y
CONFIG_MTD_NAND_BCH=y
CONFIG_MTD_NAND_ECC_BCH=y
# CONFIG_MTD_SM_COMMON is not set
CONFIG_MTD_NAND_DENALI=y
# CONFIG_MTD_NAND_DENALI_PCI is not set
# CONFIG_MTD_NAND_OMAP_BCH_BUILD is not set
CONFIG_MTD_NAND_IDS=y
# CONFIG_MTD_NAND_RICOH is not set
# CONFIG_MTD_NAND_DISKONCHIP is not set
CONFIG_MTD_NAND_DOCG4=y
# CONFIG_MTD_NAND_CAFE is not set
# CONFIG_MTD_NAND_NANDSIM is not set
# CONFIG_MTD_NAND_PLATFORM is not set
CONFIG_MTD_ONENAND=y
# CONFIG_MTD_ONENAND_VERIFY_WRITE is not set
CONFIG_MTD_ONENAND_GENERIC=y
# CONFIG_MTD_ONENAND_OTP is not set
CONFIG_MTD_ONENAND_2X_PROGRAM=y

#
# LPDDR & LPDDR2 PCM memory drivers
#
# CONFIG_MTD_LPDDR is not set
CONFIG_MTD_SPI_NOR=y
CONFIG_MTD_SPI_NOR_USE_4K_SECTORS=y
CONFIG_MTD_UBI=y
CONFIG_MTD_UBI_WL_THRESHOLD=4096
CONFIG_MTD_UBI_BEB_LIMIT=20
CONFIG_MTD_UBI_FASTMAP=y
# CONFIG_MTD_UBI_GLUEBI is not set
CONFIG_ARCH_MIGHT_HAVE_PC_PARPORT=y
# CONFIG_PARPORT is not set
CONFIG_PNP=y
CONFIG_PNP_DEBUG_MESSAGES=y

#
# Protocols
#
CONFIG_PNPACPI=y

#
# Misc devices
#
CONFIG_SENSORS_LIS3LV02D=y
# CONFIG_AD525X_DPOT is not set
# CONFIG_DUMMY_IRQ is not set
# CONFIG_IBM_ASM is not set
# CONFIG_PHANTOM is not set
# CONFIG_SGI_IOC4 is not set
# CONFIG_TIFM_CORE is not set
# CONFIG_ICS932S401 is not set
CONFIG_ENCLOSURE_SERVICES=y
# CONFIG_HP_ILO is not set
CONFIG_APDS9802ALS=y
CONFIG_ISL29003=y
CONFIG_ISL29020=y
# CONFIG_SENSORS_TSL2550 is not set
CONFIG_SENSORS_BH1780=y
CONFIG_SENSORS_BH1770=y
CONFIG_SENSORS_APDS990X=y
CONFIG_HMC6352=y
CONFIG_DS1682=y
CONFIG_VMWARE_BALLOON=y
# CONFIG_BMP085_I2C is not set
CONFIG_USB_SWITCH_FSA9480=y
CONFIG_SRAM=y
# CONFIG_C2PORT is not set

#
# EEPROM support
#
# CONFIG_EEPROM_AT24 is not set
CONFIG_EEPROM_LEGACY=y
CONFIG_EEPROM_MAX6875=y
CONFIG_EEPROM_93CX6=y
# CONFIG_CB710_CORE is not set

#
# Texas Instruments shared transport line discipline
#
CONFIG_SENSORS_LIS3_I2C=y

#
# Altera FPGA firmware download module
#
CONFIG_ALTERA_STAPL=y
# CONFIG_INTEL_MEI is not set
# CONFIG_INTEL_MEI_ME is not set
# CONFIG_INTEL_MEI_TXE is not set
# CONFIG_VMWARE_VMCI is not set

#
# Intel MIC Bus Driver
#
# CONFIG_INTEL_MIC_BUS is not set

#
# Intel MIC Host Driver
#

#
# Intel MIC Card Driver
#
# CONFIG_GENWQE is not set
CONFIG_ECHO=y
# CONFIG_CXL_BASE is not set
CONFIG_HAVE_IDE=y

#
# SCSI device support
#
CONFIG_SCSI_MOD=y
# CONFIG_SCSI_DMA is not set
# CONFIG_SCSI_NETLINK is not set
# CONFIG_FUSION is not set

#
# IEEE 1394 (FireWire) support
#
# CONFIG_FIREWIRE is not set
# CONFIG_FIREWIRE_NOSY is not set
# CONFIG_I2O is not set
CONFIG_MACINTOSH_DRIVERS=y
# CONFIG_NETDEVICES is not set

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
CONFIG_INPUT_EVBUG=y

#
# Input Device Drivers
#
CONFIG_INPUT_KEYBOARD=y
# CONFIG_KEYBOARD_ADP5588 is not set
CONFIG_KEYBOARD_ADP5589=y
CONFIG_KEYBOARD_ATKBD=y
CONFIG_KEYBOARD_QT1070=y
CONFIG_KEYBOARD_QT2160=y
CONFIG_KEYBOARD_LKKBD=y
# CONFIG_KEYBOARD_TCA6416 is not set
CONFIG_KEYBOARD_TCA8418=y
CONFIG_KEYBOARD_LM8323=y
# CONFIG_KEYBOARD_LM8333 is not set
# CONFIG_KEYBOARD_MAX7359 is not set
CONFIG_KEYBOARD_MCS=y
CONFIG_KEYBOARD_MPR121=y
# CONFIG_KEYBOARD_NEWTON is not set
CONFIG_KEYBOARD_OPENCORES=y
# CONFIG_KEYBOARD_STOWAWAY is not set
# CONFIG_KEYBOARD_SUNKBD is not set
CONFIG_KEYBOARD_XTKBD=y
CONFIG_KEYBOARD_CROS_EC=y
# CONFIG_INPUT_MOUSE is not set
# CONFIG_INPUT_JOYSTICK is not set
# CONFIG_INPUT_TABLET is not set
# CONFIG_INPUT_TOUCHSCREEN is not set
# CONFIG_INPUT_MISC is not set

#
# Hardware I/O ports
#
CONFIG_SERIO=y
CONFIG_ARCH_MIGHT_HAVE_PC_SERIO=y
CONFIG_SERIO_I8042=y
CONFIG_SERIO_SERPORT=y
CONFIG_SERIO_CT82C710=y
# CONFIG_SERIO_PCIPS2 is not set
CONFIG_SERIO_LIBPS2=y
CONFIG_SERIO_RAW=y
# CONFIG_SERIO_ALTERA_PS2 is not set
CONFIG_SERIO_PS2MULT=y
# CONFIG_SERIO_ARC_PS2 is not set
CONFIG_GAMEPORT=y
# CONFIG_GAMEPORT_NS558 is not set
# CONFIG_GAMEPORT_L4 is not set
# CONFIG_GAMEPORT_EMU10K1 is not set
# CONFIG_GAMEPORT_FM801 is not set

#
# Character devices
#
CONFIG_TTY=y
# CONFIG_VT is not set
CONFIG_UNIX98_PTYS=y
# CONFIG_DEVPTS_MULTIPLE_INSTANCES is not set
# CONFIG_LEGACY_PTYS is not set
# CONFIG_SERIAL_NONSTANDARD is not set
# CONFIG_NOZOMI is not set
# CONFIG_N_GSM is not set
# CONFIG_TRACE_ROUTER is not set
CONFIG_TRACE_SINK=y
# CONFIG_DEVKMEM is not set

#
# Serial drivers
#
CONFIG_SERIAL_EARLYCON=y
CONFIG_SERIAL_8250=y
CONFIG_SERIAL_8250_DEPRECATED_OPTIONS=y
CONFIG_SERIAL_8250_PNP=y
CONFIG_SERIAL_8250_CONSOLE=y
CONFIG_SERIAL_8250_DMA=y
CONFIG_SERIAL_8250_PCI=y
# CONFIG_SERIAL_8250_CS is not set
CONFIG_SERIAL_8250_NR_UARTS=4
CONFIG_SERIAL_8250_RUNTIME_UARTS=4
# CONFIG_SERIAL_8250_EXTENDED is not set
# CONFIG_SERIAL_8250_DW is not set
# CONFIG_SERIAL_8250_FINTEK is not set

#
# Non-8250 serial port support
#
# CONFIG_SERIAL_MFD_HSU is not set
CONFIG_SERIAL_CORE=y
CONFIG_SERIAL_CORE_CONSOLE=y
# CONFIG_SERIAL_JSM is not set
CONFIG_SERIAL_SCCNXP=y
CONFIG_SERIAL_SCCNXP_CONSOLE=y
# CONFIG_SERIAL_SC16IS7XX is not set
# CONFIG_SERIAL_ALTERA_JTAGUART is not set
# CONFIG_SERIAL_ALTERA_UART is not set
CONFIG_SERIAL_ARC=y
CONFIG_SERIAL_ARC_CONSOLE=y
CONFIG_SERIAL_ARC_NR_PORTS=1
# CONFIG_SERIAL_RP2 is not set
# CONFIG_SERIAL_FSL_LPUART is not set
CONFIG_TTY_PRINTK=y
CONFIG_IPMI_HANDLER=y
# CONFIG_IPMI_PANIC_EVENT is not set
CONFIG_IPMI_DEVICE_INTERFACE=y
CONFIG_IPMI_SI=y
# CONFIG_IPMI_SI_PROBE_DEFAULTS is not set
# CONFIG_IPMI_SSIF is not set
CONFIG_IPMI_WATCHDOG=y
# CONFIG_IPMI_POWEROFF is not set
CONFIG_HW_RANDOM=y
CONFIG_HW_RANDOM_TIMERIOMEM=y
CONFIG_HW_RANDOM_INTEL=y
CONFIG_HW_RANDOM_AMD=y
CONFIG_HW_RANDOM_VIA=y
# CONFIG_NVRAM is not set
CONFIG_R3964=y
# CONFIG_APPLICOM is not set

#
# PCMCIA character devices
#
# CONFIG_SYNCLINK_CS is not set
CONFIG_CARDMAN_4000=y
CONFIG_CARDMAN_4040=y
# CONFIG_MWAVE is not set
# CONFIG_HPET is not set
CONFIG_HANGCHECK_TIMER=y
# CONFIG_TCG_TPM is not set
# CONFIG_TELCLOCK is not set
CONFIG_DEVPORT=y
# CONFIG_XILLYBUS is not set

#
# I2C support
#
CONFIG_I2C=y
CONFIG_ACPI_I2C_OPREGION=y
CONFIG_I2C_BOARDINFO=y
CONFIG_I2C_COMPAT=y
# CONFIG_I2C_CHARDEV is not set
CONFIG_I2C_MUX=y

#
# Multiplexer I2C Chip support
#
CONFIG_I2C_MUX_PCA9541=y
# CONFIG_I2C_HELPER_AUTO is not set
# CONFIG_I2C_SMBUS is not set

#
# I2C Algorithms
#
CONFIG_I2C_ALGOBIT=y
# CONFIG_I2C_ALGOPCF is not set
CONFIG_I2C_ALGOPCA=y

#
# I2C Hardware Bus support
#

#
# PC SMBus host controller drivers
#
# CONFIG_I2C_ALI1535 is not set
# CONFIG_I2C_ALI1563 is not set
# CONFIG_I2C_ALI15X3 is not set
# CONFIG_I2C_AMD756 is not set
# CONFIG_I2C_AMD8111 is not set
# CONFIG_I2C_I801 is not set
# CONFIG_I2C_ISCH is not set
# CONFIG_I2C_ISMT is not set
# CONFIG_I2C_PIIX4 is not set
# CONFIG_I2C_NFORCE2 is not set
# CONFIG_I2C_SIS5595 is not set
# CONFIG_I2C_SIS630 is not set
# CONFIG_I2C_SIS96X is not set
# CONFIG_I2C_VIA is not set
# CONFIG_I2C_VIAPRO is not set

#
# ACPI drivers
#
# CONFIG_I2C_SCMI is not set

#
# I2C system bus drivers (mostly embedded / system-on-chip)
#
# CONFIG_I2C_DESIGNWARE_PCI is not set
# CONFIG_I2C_KEMPLD is not set
# CONFIG_I2C_OCORES is not set
CONFIG_I2C_PCA_PLATFORM=y
# CONFIG_I2C_PXA_PCI is not set
CONFIG_I2C_SIMTEC=y
# CONFIG_I2C_XILINX is not set

#
# External I2C/SMBus adapter drivers
#
# CONFIG_I2C_PARPORT_LIGHT is not set
# CONFIG_I2C_TAOS_EVM is not set

#
# Other I2C/SMBus bus drivers
#
CONFIG_I2C_CROS_EC_TUNNEL=y
CONFIG_I2C_SLAVE=y
CONFIG_I2C_SLAVE_EEPROM=y
# CONFIG_I2C_DEBUG_CORE is not set
# CONFIG_I2C_DEBUG_ALGO is not set
# CONFIG_I2C_DEBUG_BUS is not set
# CONFIG_SPI is not set
# CONFIG_SPMI is not set
CONFIG_HSI=y
CONFIG_HSI_BOARDINFO=y

#
# HSI controllers
#

#
# HSI clients
#
CONFIG_HSI_CHAR=y

#
# PPS support
#
# CONFIG_PPS is not set

#
# PPS generators support
#

#
# PTP clock support
#
# CONFIG_PTP_1588_CLOCK is not set

#
# Enable PHYLIB and NETWORK_PHY_TIMESTAMPING to see the additional clocks.
#
CONFIG_ARCH_WANT_OPTIONAL_GPIOLIB=y
# CONFIG_GPIOLIB is not set
CONFIG_W1=y

#
# 1-wire Bus Masters
#
# CONFIG_W1_MASTER_MATROX is not set
CONFIG_W1_MASTER_DS2482=y
CONFIG_W1_MASTER_DS1WM=y

#
# 1-wire Slaves
#
CONFIG_W1_SLAVE_THERM=y
CONFIG_W1_SLAVE_SMEM=y
# CONFIG_W1_SLAVE_DS2408 is not set
# CONFIG_W1_SLAVE_DS2413 is not set
CONFIG_W1_SLAVE_DS2406=y
CONFIG_W1_SLAVE_DS2423=y
# CONFIG_W1_SLAVE_DS2431 is not set
CONFIG_W1_SLAVE_DS2433=y
CONFIG_W1_SLAVE_DS2433_CRC=y
CONFIG_W1_SLAVE_DS2760=y
# CONFIG_W1_SLAVE_DS2780 is not set
CONFIG_W1_SLAVE_DS2781=y
CONFIG_W1_SLAVE_DS28E04=y
CONFIG_W1_SLAVE_BQ27000=y
CONFIG_POWER_SUPPLY=y
# CONFIG_POWER_SUPPLY_DEBUG is not set
# CONFIG_PDA_POWER is not set
# CONFIG_GENERIC_ADC_BATTERY is not set
# CONFIG_MAX8925_POWER is not set
# CONFIG_WM831X_BACKUP is not set
# CONFIG_WM831X_POWER is not set
# CONFIG_TEST_POWER is not set
# CONFIG_BATTERY_DS2760 is not set
# CONFIG_BATTERY_DS2780 is not set
# CONFIG_BATTERY_DS2781 is not set
# CONFIG_BATTERY_DS2782 is not set
# CONFIG_BATTERY_SBS is not set
# CONFIG_BATTERY_BQ27x00 is not set
# CONFIG_BATTERY_MAX17040 is not set
# CONFIG_BATTERY_MAX17042 is not set
# CONFIG_CHARGER_MAX8903 is not set
# CONFIG_CHARGER_LP8727 is not set
# CONFIG_CHARGER_LP8788 is not set
# CONFIG_CHARGER_MAX14577 is not set
# CONFIG_CHARGER_MAX8997 is not set
# CONFIG_CHARGER_BQ2415X is not set
# CONFIG_CHARGER_SMB347 is not set
# CONFIG_POWER_RESET is not set
# CONFIG_POWER_AVS is not set
CONFIG_HWMON=y
CONFIG_HWMON_VID=y
CONFIG_HWMON_DEBUG_CHIP=y

#
# Native drivers
#
CONFIG_SENSORS_AD7414=y
# CONFIG_SENSORS_AD7418 is not set
CONFIG_SENSORS_ADM1021=y
# CONFIG_SENSORS_ADM1025 is not set
# CONFIG_SENSORS_ADM1026 is not set
# CONFIG_SENSORS_ADM1029 is not set
CONFIG_SENSORS_ADM1031=y
CONFIG_SENSORS_ADM9240=y
# CONFIG_SENSORS_ADT7410 is not set
CONFIG_SENSORS_ADT7411=y
CONFIG_SENSORS_ADT7462=y
# CONFIG_SENSORS_ADT7470 is not set
CONFIG_SENSORS_ADT7475=y
CONFIG_SENSORS_ASC7621=y
# CONFIG_SENSORS_K8TEMP is not set
# CONFIG_SENSORS_K10TEMP is not set
# CONFIG_SENSORS_FAM15H_POWER is not set
CONFIG_SENSORS_APPLESMC=y
# CONFIG_SENSORS_ASB100 is not set
CONFIG_SENSORS_ATXP1=y
CONFIG_SENSORS_DS620=y
CONFIG_SENSORS_DS1621=y
# CONFIG_SENSORS_I5K_AMB is not set
CONFIG_SENSORS_F71805F=y
CONFIG_SENSORS_F71882FG=y
# CONFIG_SENSORS_F75375S is not set
CONFIG_SENSORS_MC13783_ADC=y
# CONFIG_SENSORS_FSCHMD is not set
CONFIG_SENSORS_GL518SM=y
CONFIG_SENSORS_GL520SM=y
CONFIG_SENSORS_G760A=y
CONFIG_SENSORS_G762=y
CONFIG_SENSORS_HIH6130=y
CONFIG_SENSORS_IBMAEM=y
CONFIG_SENSORS_IBMPEX=y
CONFIG_SENSORS_IIO_HWMON=y
# CONFIG_SENSORS_CORETEMP is not set
CONFIG_SENSORS_IT87=y
CONFIG_SENSORS_JC42=y
CONFIG_SENSORS_POWR1220=y
CONFIG_SENSORS_LINEAGE=y
CONFIG_SENSORS_LTC2945=y
CONFIG_SENSORS_LTC4151=y
# CONFIG_SENSORS_LTC4215 is not set
# CONFIG_SENSORS_LTC4222 is not set
CONFIG_SENSORS_LTC4245=y
CONFIG_SENSORS_LTC4260=y
# CONFIG_SENSORS_LTC4261 is not set
# CONFIG_SENSORS_MAX16065 is not set
CONFIG_SENSORS_MAX1619=y
CONFIG_SENSORS_MAX1668=y
# CONFIG_SENSORS_MAX197 is not set
# CONFIG_SENSORS_MAX6639 is not set
CONFIG_SENSORS_MAX6642=y
# CONFIG_SENSORS_MAX6650 is not set
# CONFIG_SENSORS_MAX6697 is not set
CONFIG_SENSORS_HTU21=y
CONFIG_SENSORS_MCP3021=y
# CONFIG_SENSORS_LM63 is not set
CONFIG_SENSORS_LM73=y
CONFIG_SENSORS_LM75=y
# CONFIG_SENSORS_LM77 is not set
CONFIG_SENSORS_LM78=y
CONFIG_SENSORS_LM80=y
# CONFIG_SENSORS_LM83 is not set
# CONFIG_SENSORS_LM85 is not set
CONFIG_SENSORS_LM87=y
CONFIG_SENSORS_LM90=y
CONFIG_SENSORS_LM92=y
# CONFIG_SENSORS_LM93 is not set
CONFIG_SENSORS_LM95234=y
# CONFIG_SENSORS_LM95241 is not set
CONFIG_SENSORS_LM95245=y
# CONFIG_SENSORS_PC87360 is not set
CONFIG_SENSORS_PC87427=y
# CONFIG_SENSORS_NTC_THERMISTOR is not set
CONFIG_SENSORS_NCT6683=y
CONFIG_SENSORS_NCT6775=y
CONFIG_SENSORS_NCT7802=y
CONFIG_SENSORS_PCF8591=y
# CONFIG_PMBUS is not set
CONFIG_SENSORS_SHT21=y
CONFIG_SENSORS_SHTC1=y
# CONFIG_SENSORS_SIS5595 is not set
# CONFIG_SENSORS_DME1737 is not set
# CONFIG_SENSORS_EMC1403 is not set
# CONFIG_SENSORS_EMC2103 is not set
CONFIG_SENSORS_EMC6W201=y
# CONFIG_SENSORS_SMSC47M1 is not set
CONFIG_SENSORS_SMSC47M192=y
# CONFIG_SENSORS_SMSC47B397 is not set
CONFIG_SENSORS_SCH56XX_COMMON=y
CONFIG_SENSORS_SCH5627=y
CONFIG_SENSORS_SCH5636=y
# CONFIG_SENSORS_SMM665 is not set
CONFIG_SENSORS_ADC128D818=y
# CONFIG_SENSORS_ADS1015 is not set
CONFIG_SENSORS_ADS7828=y
CONFIG_SENSORS_AMC6821=y
CONFIG_SENSORS_INA209=y
CONFIG_SENSORS_INA2XX=y
# CONFIG_SENSORS_THMC50 is not set
# CONFIG_SENSORS_TMP102 is not set
CONFIG_SENSORS_TMP103=y
CONFIG_SENSORS_TMP401=y
CONFIG_SENSORS_TMP421=y
# CONFIG_SENSORS_VIA_CPUTEMP is not set
# CONFIG_SENSORS_VIA686A is not set
CONFIG_SENSORS_VT1211=y
# CONFIG_SENSORS_VT8231 is not set
# CONFIG_SENSORS_W83781D is not set
CONFIG_SENSORS_W83791D=y
CONFIG_SENSORS_W83792D=y
# CONFIG_SENSORS_W83793 is not set
CONFIG_SENSORS_W83795=y
CONFIG_SENSORS_W83795_FANCTRL=y
CONFIG_SENSORS_W83L785TS=y
CONFIG_SENSORS_W83L786NG=y
CONFIG_SENSORS_W83627HF=y
# CONFIG_SENSORS_W83627EHF is not set
# CONFIG_SENSORS_WM831X is not set

#
# ACPI drivers
#
# CONFIG_SENSORS_ACPI_POWER is not set
# CONFIG_SENSORS_ATK0110 is not set
CONFIG_THERMAL=y
# CONFIG_THERMAL_HWMON is not set
# CONFIG_THERMAL_DEFAULT_GOV_STEP_WISE is not set
CONFIG_THERMAL_DEFAULT_GOV_FAIR_SHARE=y
# CONFIG_THERMAL_DEFAULT_GOV_USER_SPACE is not set
CONFIG_THERMAL_GOV_FAIR_SHARE=y
# CONFIG_THERMAL_GOV_STEP_WISE is not set
# CONFIG_THERMAL_GOV_BANG_BANG is not set
CONFIG_THERMAL_GOV_USER_SPACE=y
# CONFIG_THERMAL_EMULATION is not set
CONFIG_INTEL_POWERCLAMP=y
# CONFIG_INT340X_THERMAL is not set

#
# Texas Instruments thermal drivers
#
CONFIG_WATCHDOG=y
CONFIG_WATCHDOG_CORE=y
CONFIG_WATCHDOG_NOWAYOUT=y

#
# Watchdog Device Drivers
#
CONFIG_SOFT_WATCHDOG=y
CONFIG_WM831X_WATCHDOG=y
# CONFIG_XILINX_WATCHDOG is not set
# CONFIG_DW_WATCHDOG is not set
CONFIG_RN5T618_WATCHDOG=y
CONFIG_RETU_WATCHDOG=y
# CONFIG_ACQUIRE_WDT is not set
# CONFIG_ADVANTECH_WDT is not set
# CONFIG_ALIM1535_WDT is not set
# CONFIG_ALIM7101_WDT is not set
CONFIG_F71808E_WDT=y
# CONFIG_SP5100_TCO is not set
# CONFIG_SBC_FITPC2_WATCHDOG is not set
# CONFIG_EUROTECH_WDT is not set
# CONFIG_IB700_WDT is not set
CONFIG_IBMASR=y
# CONFIG_WAFER_WDT is not set
# CONFIG_I6300ESB_WDT is not set
# CONFIG_IE6XX_WDT is not set
# CONFIG_ITCO_WDT is not set
CONFIG_IT8712F_WDT=y
CONFIG_IT87_WDT=y
# CONFIG_HP_WATCHDOG is not set
CONFIG_KEMPLD_WDT=y
# CONFIG_SC1200_WDT is not set
CONFIG_PC87413_WDT=y
# CONFIG_NV_TCO is not set
CONFIG_60XX_WDT=y
CONFIG_CPU5_WDT=y
CONFIG_SMSC_SCH311X_WDT=y
CONFIG_SMSC37B787_WDT=y
# CONFIG_VIA_WDT is not set
CONFIG_W83627HF_WDT=y
CONFIG_W83877F_WDT=y
CONFIG_W83977F_WDT=y
CONFIG_MACHZ_WDT=y
CONFIG_SBC_EPX_C3_WATCHDOG=y

#
# PCI-based Watchdog Cards
#
# CONFIG_PCIPCWATCHDOG is not set
# CONFIG_WDTPCI is not set
CONFIG_SSB_POSSIBLE=y

#
# Sonics Silicon Backplane
#
# CONFIG_SSB is not set
CONFIG_BCMA_POSSIBLE=y

#
# Broadcom specific AMBA
#
CONFIG_BCMA=y
CONFIG_BCMA_HOST_PCI_POSSIBLE=y
CONFIG_BCMA_HOST_PCI=y
CONFIG_BCMA_HOST_SOC=y
CONFIG_BCMA_DRIVER_GMAC_CMN=y
CONFIG_BCMA_DEBUG=y

#
# Multifunction device drivers
#
CONFIG_MFD_CORE=y
CONFIG_MFD_AS3711=y
# CONFIG_PMIC_ADP5520 is not set
# CONFIG_MFD_BCM590XX is not set
CONFIG_MFD_AXP20X=y
CONFIG_MFD_CROS_EC=y
# CONFIG_MFD_CROS_EC_I2C is not set
# CONFIG_PMIC_DA903X is not set
# CONFIG_MFD_DA9052_I2C is not set
# CONFIG_MFD_DA9055 is not set
# CONFIG_MFD_DA9063 is not set
CONFIG_MFD_MC13XXX=y
CONFIG_MFD_MC13XXX_I2C=y
# CONFIG_HTC_PASIC3 is not set
# CONFIG_LPC_ICH is not set
# CONFIG_LPC_SCH is not set
# CONFIG_INTEL_SOC_PMIC is not set
# CONFIG_MFD_JANZ_CMODIO is not set
CONFIG_MFD_KEMPLD=y
CONFIG_MFD_88PM800=y
CONFIG_MFD_88PM805=y
# CONFIG_MFD_88PM860X is not set
CONFIG_MFD_MAX14577=y
# CONFIG_MFD_MAX77686 is not set
CONFIG_MFD_MAX77693=y
CONFIG_MFD_MAX8907=y
CONFIG_MFD_MAX8925=y
CONFIG_MFD_MAX8997=y
# CONFIG_MFD_MAX8998 is not set
# CONFIG_MFD_MENF21BMC is not set
CONFIG_MFD_RETU=y
# CONFIG_MFD_PCF50633 is not set
# CONFIG_MFD_RDC321X is not set
# CONFIG_MFD_RTSX_PCI is not set
# CONFIG_MFD_RC5T583 is not set
CONFIG_MFD_RN5T618=y
# CONFIG_MFD_SEC_CORE is not set
CONFIG_MFD_SI476X_CORE=y
# CONFIG_MFD_SM501 is not set
CONFIG_MFD_SMSC=y
# CONFIG_ABX500_CORE is not set
CONFIG_MFD_SYSCON=y
# CONFIG_MFD_TI_AM335X_TSCADC is not set
CONFIG_MFD_LP3943=y
CONFIG_MFD_LP8788=y
# CONFIG_MFD_PALMAS is not set
CONFIG_TPS6105X=y
# CONFIG_TPS6507X is not set
# CONFIG_MFD_TPS65090 is not set
# CONFIG_MFD_TPS65217 is not set
# CONFIG_MFD_TPS65218 is not set
CONFIG_MFD_TPS6586X=y
# CONFIG_MFD_TPS80031 is not set
# CONFIG_TWL4030_CORE is not set
CONFIG_TWL6040_CORE=y
CONFIG_MFD_WL1273_CORE=y
# CONFIG_MFD_LM3533 is not set
# CONFIG_MFD_TC3589X is not set
# CONFIG_MFD_TMIO is not set
# CONFIG_MFD_VX855 is not set
# CONFIG_MFD_ARIZONA_I2C is not set
CONFIG_MFD_WM8400=y
CONFIG_MFD_WM831X=y
CONFIG_MFD_WM831X_I2C=y
# CONFIG_MFD_WM8350_I2C is not set
CONFIG_MFD_WM8994=y
CONFIG_REGULATOR=y
# CONFIG_REGULATOR_DEBUG is not set
CONFIG_REGULATOR_FIXED_VOLTAGE=y
CONFIG_REGULATOR_VIRTUAL_CONSUMER=y
CONFIG_REGULATOR_USERSPACE_CONSUMER=y
CONFIG_REGULATOR_88PM800=y
# CONFIG_REGULATOR_ACT8865 is not set
CONFIG_REGULATOR_AD5398=y
CONFIG_REGULATOR_ANATOP=y
CONFIG_REGULATOR_AS3711=y
CONFIG_REGULATOR_AXP20X=y
CONFIG_REGULATOR_DA9210=y
CONFIG_REGULATOR_DA9211=y
CONFIG_REGULATOR_FAN53555=y
CONFIG_REGULATOR_ISL9305=y
CONFIG_REGULATOR_ISL6271A=y
# CONFIG_REGULATOR_LP3971 is not set
CONFIG_REGULATOR_LP3972=y
CONFIG_REGULATOR_LP872X=y
CONFIG_REGULATOR_LP8755=y
CONFIG_REGULATOR_LP8788=y
CONFIG_REGULATOR_LTC3589=y
CONFIG_REGULATOR_MAX14577=y
CONFIG_REGULATOR_MAX1586=y
CONFIG_REGULATOR_MAX8649=y
# CONFIG_REGULATOR_MAX8660 is not set
# CONFIG_REGULATOR_MAX8907 is not set
CONFIG_REGULATOR_MAX8925=y
CONFIG_REGULATOR_MAX8952=y
CONFIG_REGULATOR_MAX8973=y
CONFIG_REGULATOR_MAX8997=y
CONFIG_REGULATOR_MAX77693=y
CONFIG_REGULATOR_MC13XXX_CORE=y
CONFIG_REGULATOR_MC13783=y
CONFIG_REGULATOR_MC13892=y
CONFIG_REGULATOR_PFUZE100=y
CONFIG_REGULATOR_RN5T618=y
CONFIG_REGULATOR_TPS51632=y
# CONFIG_REGULATOR_TPS6105X is not set
# CONFIG_REGULATOR_TPS62360 is not set
CONFIG_REGULATOR_TPS65023=y
CONFIG_REGULATOR_TPS6507X=y
CONFIG_REGULATOR_TPS6586X=y
CONFIG_REGULATOR_WM831X=y
# CONFIG_REGULATOR_WM8400 is not set
CONFIG_REGULATOR_WM8994=y
CONFIG_MEDIA_SUPPORT=y

#
# Multimedia core support
#
# CONFIG_MEDIA_CAMERA_SUPPORT is not set
# CONFIG_MEDIA_ANALOG_TV_SUPPORT is not set
CONFIG_MEDIA_DIGITAL_TV_SUPPORT=y
CONFIG_MEDIA_RADIO_SUPPORT=y
# CONFIG_MEDIA_SDR_SUPPORT is not set
CONFIG_MEDIA_RC_SUPPORT=y
CONFIG_VIDEO_DEV=y
CONFIG_VIDEO_V4L2=y
# CONFIG_VIDEO_ADV_DEBUG is not set
CONFIG_VIDEO_FIXED_MINOR_RANGES=y
CONFIG_DVB_CORE=y
# CONFIG_TTPCI_EEPROM is not set
CONFIG_DVB_MAX_ADAPTERS=8
# CONFIG_DVB_DYNAMIC_MINORS is not set

#
# Media drivers
#
CONFIG_RC_CORE=y
# CONFIG_RC_MAP is not set
CONFIG_RC_DECODERS=y
# CONFIG_LIRC is not set
CONFIG_IR_NEC_DECODER=y
CONFIG_IR_RC5_DECODER=y
CONFIG_IR_RC6_DECODER=y
CONFIG_IR_JVC_DECODER=y
CONFIG_IR_SONY_DECODER=y
# CONFIG_IR_SANYO_DECODER is not set
CONFIG_IR_SHARP_DECODER=y
# CONFIG_IR_MCE_KBD_DECODER is not set
CONFIG_IR_XMP_DECODER=y
CONFIG_RC_DEVICES=y
# CONFIG_RC_ATI_REMOTE is not set
# CONFIG_IR_ENE is not set
CONFIG_IR_HIX5HD2=y
# CONFIG_IR_IMON is not set
# CONFIG_IR_MCEUSB is not set
# CONFIG_IR_ITE_CIR is not set
# CONFIG_IR_FINTEK is not set
# CONFIG_IR_NUVOTON is not set
# CONFIG_IR_REDRAT3 is not set
# CONFIG_IR_STREAMZAP is not set
# CONFIG_IR_WINBOND_CIR is not set
# CONFIG_IR_IGORPLUGUSB is not set
# CONFIG_IR_IGUANA is not set
# CONFIG_IR_TTUSBIR is not set
# CONFIG_RC_LOOPBACK is not set
# CONFIG_IR_GPIO_CIR is not set
# CONFIG_MEDIA_PCI_SUPPORT is not set

#
# Supported MMC/SDIO adapters
#
CONFIG_SMS_SDIO_DRV=y
# CONFIG_RADIO_ADAPTERS is not set
CONFIG_MEDIA_COMMON_OPTIONS=y

#
# common driver options
#
CONFIG_SMS_SIANO_MDTV=y
CONFIG_SMS_SIANO_RC=y

#
# Media ancillary drivers (tuners, sensors, i2c, frontends)
#
# CONFIG_MEDIA_SUBDRV_AUTOSELECT is not set
CONFIG_VIDEO_IR_I2C=y

#
# Encoders, decoders, sensors and other helper chips
#

#
# Audio decoders, processors and mixers
#
CONFIG_VIDEO_TVAUDIO=y
# CONFIG_VIDEO_TDA7432 is not set
# CONFIG_VIDEO_TDA9840 is not set
# CONFIG_VIDEO_TEA6415C is not set
CONFIG_VIDEO_TEA6420=y
CONFIG_VIDEO_MSP3400=y
# CONFIG_VIDEO_CS5345 is not set
# CONFIG_VIDEO_CS53L32A is not set
CONFIG_VIDEO_TLV320AIC23B=y
# CONFIG_VIDEO_UDA1342 is not set
CONFIG_VIDEO_WM8775=y
CONFIG_VIDEO_WM8739=y
CONFIG_VIDEO_VP27SMPX=y
CONFIG_VIDEO_SONY_BTF_MPX=y

#
# RDS decoders
#
# CONFIG_VIDEO_SAA6588 is not set

#
# Video decoders
#
CONFIG_VIDEO_ADV7180=y
CONFIG_VIDEO_ADV7183=y
CONFIG_VIDEO_BT819=y
CONFIG_VIDEO_BT856=y
# CONFIG_VIDEO_BT866 is not set
CONFIG_VIDEO_KS0127=y
CONFIG_VIDEO_ML86V7667=y
CONFIG_VIDEO_SAA7110=y
CONFIG_VIDEO_SAA711X=y
CONFIG_VIDEO_TVP514X=y
CONFIG_VIDEO_TVP5150=y
# CONFIG_VIDEO_TVP7002 is not set
CONFIG_VIDEO_TW2804=y
CONFIG_VIDEO_TW9903=y
CONFIG_VIDEO_TW9906=y
# CONFIG_VIDEO_VPX3220 is not set

#
# Video and audio decoders
#
CONFIG_VIDEO_SAA717X=y
CONFIG_VIDEO_CX25840=y

#
# Video encoders
#
# CONFIG_VIDEO_SAA7127 is not set
CONFIG_VIDEO_SAA7185=y
CONFIG_VIDEO_ADV7170=y
CONFIG_VIDEO_ADV7175=y
# CONFIG_VIDEO_ADV7343 is not set
CONFIG_VIDEO_ADV7393=y
CONFIG_VIDEO_AK881X=y
CONFIG_VIDEO_THS8200=y

#
# Camera sensor devices
#

#
# Flash devices
#

#
# Video improvement chips
#
# CONFIG_VIDEO_UPD64031A is not set
# CONFIG_VIDEO_UPD64083 is not set

#
# Audio/Video compression chips
#
CONFIG_VIDEO_SAA6752HS=y

#
# Miscellaneous helper chips
#
CONFIG_VIDEO_THS7303=y
CONFIG_VIDEO_M52790=y

#
# Sensors used on soc_camera driver
#
CONFIG_MEDIA_TUNER=y

#
# Customize TV tuners
#
CONFIG_MEDIA_TUNER_SIMPLE=y
# CONFIG_MEDIA_TUNER_TDA8290 is not set
CONFIG_MEDIA_TUNER_TDA827X=y
# CONFIG_MEDIA_TUNER_TDA18271 is not set
CONFIG_MEDIA_TUNER_TDA9887=y
# CONFIG_MEDIA_TUNER_TEA5761 is not set
CONFIG_MEDIA_TUNER_TEA5767=y
# CONFIG_MEDIA_TUNER_MT20XX is not set
CONFIG_MEDIA_TUNER_MT2060=y
# CONFIG_MEDIA_TUNER_MT2063 is not set
# CONFIG_MEDIA_TUNER_MT2266 is not set
CONFIG_MEDIA_TUNER_MT2131=y
CONFIG_MEDIA_TUNER_QT1010=y
CONFIG_MEDIA_TUNER_XC2028=y
# CONFIG_MEDIA_TUNER_XC5000 is not set
CONFIG_MEDIA_TUNER_XC4000=y
CONFIG_MEDIA_TUNER_MXL5005S=y
CONFIG_MEDIA_TUNER_MXL5007T=y
# CONFIG_MEDIA_TUNER_MC44S803 is not set
# CONFIG_MEDIA_TUNER_MAX2165 is not set
# CONFIG_MEDIA_TUNER_TDA18218 is not set
# CONFIG_MEDIA_TUNER_FC0011 is not set
# CONFIG_MEDIA_TUNER_FC0012 is not set
CONFIG_MEDIA_TUNER_FC0013=y
CONFIG_MEDIA_TUNER_TDA18212=y
CONFIG_MEDIA_TUNER_E4000=y
# CONFIG_MEDIA_TUNER_FC2580 is not set
CONFIG_MEDIA_TUNER_M88TS2022=y
CONFIG_MEDIA_TUNER_M88RS6000T=y
CONFIG_MEDIA_TUNER_TUA9001=y
# CONFIG_MEDIA_TUNER_SI2157 is not set
# CONFIG_MEDIA_TUNER_IT913X is not set
CONFIG_MEDIA_TUNER_R820T=y
# CONFIG_MEDIA_TUNER_MXL301RF is not set
CONFIG_MEDIA_TUNER_QM1D1C0042=y

#
# Customise DVB Frontends
#

#
# Multistandard (satellite) frontends
#
CONFIG_DVB_STB0899=y
CONFIG_DVB_STB6100=y
# CONFIG_DVB_STV090x is not set
# CONFIG_DVB_STV6110x is not set
CONFIG_DVB_M88DS3103=y

#
# Multistandard (cable + terrestrial) frontends
#
CONFIG_DVB_DRXK=y
# CONFIG_DVB_TDA18271C2DD is not set
CONFIG_DVB_SI2165=y

#
# DVB-S (satellite) frontends
#
CONFIG_DVB_CX24110=y
CONFIG_DVB_CX24123=y
# CONFIG_DVB_MT312 is not set
CONFIG_DVB_ZL10036=y
# CONFIG_DVB_ZL10039 is not set
CONFIG_DVB_S5H1420=y
CONFIG_DVB_STV0288=y
CONFIG_DVB_STB6000=y
CONFIG_DVB_STV0299=y
# CONFIG_DVB_STV6110 is not set
# CONFIG_DVB_STV0900 is not set
CONFIG_DVB_TDA8083=y
CONFIG_DVB_TDA10086=y
CONFIG_DVB_TDA8261=y
CONFIG_DVB_VES1X93=y
CONFIG_DVB_TUNER_ITD1000=y
CONFIG_DVB_TUNER_CX24113=y
CONFIG_DVB_TDA826X=y
CONFIG_DVB_TUA6100=y
CONFIG_DVB_CX24116=y
CONFIG_DVB_CX24117=y
# CONFIG_DVB_SI21XX is not set
CONFIG_DVB_TS2020=y
CONFIG_DVB_DS3000=y
CONFIG_DVB_MB86A16=y
# CONFIG_DVB_TDA10071 is not set

#
# DVB-T (terrestrial) frontends
#
# CONFIG_DVB_SP8870 is not set
CONFIG_DVB_SP887X=y
CONFIG_DVB_CX22700=y
CONFIG_DVB_CX22702=y
# CONFIG_DVB_S5H1432 is not set
CONFIG_DVB_DRXD=y
# CONFIG_DVB_L64781 is not set
CONFIG_DVB_TDA1004X=y
CONFIG_DVB_NXT6000=y
CONFIG_DVB_MT352=y
CONFIG_DVB_ZL10353=y
# CONFIG_DVB_DIB3000MB is not set
CONFIG_DVB_DIB3000MC=y
# CONFIG_DVB_DIB7000M is not set
# CONFIG_DVB_DIB7000P is not set
# CONFIG_DVB_DIB9000 is not set
CONFIG_DVB_TDA10048=y
# CONFIG_DVB_AF9013 is not set
# CONFIG_DVB_EC100 is not set
CONFIG_DVB_HD29L2=y
# CONFIG_DVB_STV0367 is not set
# CONFIG_DVB_CXD2820R is not set
CONFIG_DVB_RTL2830=y
# CONFIG_DVB_RTL2832 is not set
CONFIG_DVB_SI2168=y
# CONFIG_DVB_AS102_FE is not set

#
# DVB-C (cable) frontends
#
CONFIG_DVB_VES1820=y
# CONFIG_DVB_TDA10021 is not set
# CONFIG_DVB_TDA10023 is not set
CONFIG_DVB_STV0297=y

#
# ATSC (North American/Korean Terrestrial/Cable DTV) frontends
#
# CONFIG_DVB_NXT200X is not set
CONFIG_DVB_OR51211=y
# CONFIG_DVB_OR51132 is not set
# CONFIG_DVB_BCM3510 is not set
CONFIG_DVB_LGDT330X=y
# CONFIG_DVB_LGDT3305 is not set
# CONFIG_DVB_LG2160 is not set
CONFIG_DVB_S5H1409=y
CONFIG_DVB_AU8522=y
CONFIG_DVB_AU8522_DTV=y
CONFIG_DVB_AU8522_V4L=y
CONFIG_DVB_S5H1411=y

#
# ISDB-T (terrestrial) frontends
#
CONFIG_DVB_S921=y
CONFIG_DVB_DIB8000=y
# CONFIG_DVB_MB86A20S is not set

#
# ISDB-S (satellite) & ISDB-T (terrestrial) frontends
#
# CONFIG_DVB_TC90522 is not set

#
# Digital terrestrial only tuners/PLL
#
CONFIG_DVB_PLL=y
# CONFIG_DVB_TUNER_DIB0070 is not set
CONFIG_DVB_TUNER_DIB0090=y

#
# SEC control devices for DVB-S
#
# CONFIG_DVB_DRX39XYJ is not set
CONFIG_DVB_LNBP21=y
CONFIG_DVB_LNBP22=y
# CONFIG_DVB_ISL6405 is not set
# CONFIG_DVB_ISL6421 is not set
CONFIG_DVB_ISL6423=y
# CONFIG_DVB_A8293 is not set
# CONFIG_DVB_SP2 is not set
# CONFIG_DVB_LGS8GL5 is not set
CONFIG_DVB_LGS8GXX=y
CONFIG_DVB_ATBM8830=y
# CONFIG_DVB_TDA665x is not set
CONFIG_DVB_IX2505V=y
# CONFIG_DVB_M88RS2000 is not set
# CONFIG_DVB_AF9033 is not set

#
# Tools to develop new frontends
#
CONFIG_DVB_DUMMY_FE=y

#
# Graphics support
#
# CONFIG_AGP is not set
CONFIG_VGA_ARB=y
CONFIG_VGA_ARB_MAX_GPUS=16
# CONFIG_VGA_SWITCHEROO is not set

#
# Direct Rendering Manager
#
# CONFIG_DRM is not set

#
# Frame buffer Devices
#
CONFIG_FB=y
CONFIG_FIRMWARE_EDID=y
CONFIG_FB_CMDLINE=y
# CONFIG_FB_DDC is not set
# CONFIG_FB_BOOT_VESA_SUPPORT is not set
CONFIG_FB_CFB_FILLRECT=y
CONFIG_FB_CFB_COPYAREA=y
CONFIG_FB_CFB_IMAGEBLIT=y
# CONFIG_FB_CFB_REV_PIXELS_IN_BYTE is not set
CONFIG_FB_SYS_FILLRECT=y
CONFIG_FB_SYS_COPYAREA=y
CONFIG_FB_SYS_IMAGEBLIT=y
CONFIG_FB_FOREIGN_ENDIAN=y
# CONFIG_FB_BOTH_ENDIAN is not set
# CONFIG_FB_BIG_ENDIAN is not set
CONFIG_FB_LITTLE_ENDIAN=y
CONFIG_FB_SYS_FOPS=y
CONFIG_FB_DEFERRED_IO=y
CONFIG_FB_HECUBA=y
# CONFIG_FB_SVGALIB is not set
# CONFIG_FB_MACMODES is not set
# CONFIG_FB_BACKLIGHT is not set
CONFIG_FB_MODE_HELPERS=y
CONFIG_FB_TILEBLITTING=y

#
# Frame buffer hardware drivers
#
# CONFIG_FB_CIRRUS is not set
# CONFIG_FB_PM2 is not set
# CONFIG_FB_CYBER2000 is not set
CONFIG_FB_ARC=y
# CONFIG_FB_ASILIANT is not set
# CONFIG_FB_IMSTT is not set
# CONFIG_FB_VGA16 is not set
# CONFIG_FB_VESA is not set
CONFIG_FB_N411=y
CONFIG_FB_HGA=y
# CONFIG_FB_OPENCORES is not set
CONFIG_FB_S1D13XXX=y
# CONFIG_FB_NVIDIA is not set
# CONFIG_FB_RIVA is not set
# CONFIG_FB_I740 is not set
# CONFIG_FB_LE80578 is not set
# CONFIG_FB_MATROX is not set
# CONFIG_FB_RADEON is not set
# CONFIG_FB_ATY128 is not set
# CONFIG_FB_ATY is not set
# CONFIG_FB_S3 is not set
# CONFIG_FB_SAVAGE is not set
# CONFIG_FB_SIS is not set
# CONFIG_FB_VIA is not set
# CONFIG_FB_NEOMAGIC is not set
# CONFIG_FB_KYRO is not set
# CONFIG_FB_3DFX is not set
# CONFIG_FB_VOODOO1 is not set
# CONFIG_FB_VT8623 is not set
# CONFIG_FB_TRIDENT is not set
# CONFIG_FB_ARK is not set
# CONFIG_FB_PM3 is not set
# CONFIG_FB_CARMINE is not set
CONFIG_FB_VIRTUAL=y
CONFIG_FB_METRONOME=y
# CONFIG_FB_MB862XX is not set
CONFIG_FB_BROADSHEET=y
# CONFIG_FB_AUO_K190X is not set
# CONFIG_FB_SIMPLE is not set
CONFIG_BACKLIGHT_LCD_SUPPORT=y
CONFIG_LCD_CLASS_DEVICE=y
CONFIG_LCD_PLATFORM=y
# CONFIG_BACKLIGHT_CLASS_DEVICE is not set
# CONFIG_VGASTATE is not set
CONFIG_LOGO=y
CONFIG_LOGO_LINUX_MONO=y
# CONFIG_LOGO_LINUX_VGA16 is not set
# CONFIG_LOGO_LINUX_CLUT224 is not set
CONFIG_SOUND=y
CONFIG_SOUND_OSS_CORE=y
CONFIG_SOUND_OSS_CORE_PRECLAIM=y
CONFIG_SND=y
CONFIG_SND_TIMER=y
CONFIG_SND_PCM=y
CONFIG_SND_COMPRESS_OFFLOAD=y
CONFIG_SND_JACK=y
CONFIG_SND_SEQUENCER=y
CONFIG_SND_SEQ_DUMMY=y
CONFIG_SND_OSSEMUL=y
CONFIG_SND_MIXER_OSS=y
CONFIG_SND_PCM_OSS=y
CONFIG_SND_PCM_OSS_PLUGINS=y
CONFIG_SND_SEQUENCER_OSS=y
# CONFIG_SND_HRTIMER is not set
CONFIG_SND_DYNAMIC_MINORS=y
CONFIG_SND_MAX_CARDS=32
# CONFIG_SND_SUPPORT_OLD_API is not set
# CONFIG_SND_VERBOSE_PRINTK is not set
CONFIG_SND_DEBUG=y
# CONFIG_SND_DEBUG_VERBOSE is not set
CONFIG_SND_DMA_SGBUF=y
# CONFIG_SND_RAWMIDI_SEQ is not set
# CONFIG_SND_OPL3_LIB_SEQ is not set
# CONFIG_SND_OPL4_LIB_SEQ is not set
# CONFIG_SND_SBAWE_SEQ is not set
# CONFIG_SND_EMU10K1_SEQ is not set
# CONFIG_SND_DRIVERS is not set
CONFIG_SND_PCI=y
# CONFIG_SND_AD1889 is not set
# CONFIG_SND_ALS300 is not set
# CONFIG_SND_ALI5451 is not set
# CONFIG_SND_ASIHPI is not set
# CONFIG_SND_ATIIXP is not set
# CONFIG_SND_ATIIXP_MODEM is not set
# CONFIG_SND_AU8810 is not set
# CONFIG_SND_AU8820 is not set
# CONFIG_SND_AU8830 is not set
# CONFIG_SND_AW2 is not set
# CONFIG_SND_AZT3328 is not set
# CONFIG_SND_BT87X is not set
# CONFIG_SND_CA0106 is not set
# CONFIG_SND_CMIPCI is not set
# CONFIG_SND_OXYGEN is not set
# CONFIG_SND_CS4281 is not set
# CONFIG_SND_CS46XX is not set
# CONFIG_SND_CTXFI is not set
# CONFIG_SND_DARLA20 is not set
# CONFIG_SND_GINA20 is not set
# CONFIG_SND_LAYLA20 is not set
# CONFIG_SND_DARLA24 is not set
# CONFIG_SND_GINA24 is not set
# CONFIG_SND_LAYLA24 is not set
# CONFIG_SND_MONA is not set
# CONFIG_SND_MIA is not set
# CONFIG_SND_ECHO3G is not set
# CONFIG_SND_INDIGO is not set
# CONFIG_SND_INDIGOIO is not set
# CONFIG_SND_INDIGODJ is not set
# CONFIG_SND_INDIGOIOX is not set
# CONFIG_SND_INDIGODJX is not set
# CONFIG_SND_EMU10K1 is not set
# CONFIG_SND_EMU10K1X is not set
# CONFIG_SND_ENS1370 is not set
# CONFIG_SND_ENS1371 is not set
# CONFIG_SND_ES1938 is not set
# CONFIG_SND_ES1968 is not set
# CONFIG_SND_FM801 is not set
# CONFIG_SND_HDSP is not set
# CONFIG_SND_HDSPM is not set
# CONFIG_SND_ICE1712 is not set
# CONFIG_SND_ICE1724 is not set
# CONFIG_SND_INTEL8X0 is not set
# CONFIG_SND_INTEL8X0M is not set
# CONFIG_SND_KORG1212 is not set
# CONFIG_SND_LOLA is not set
# CONFIG_SND_LX6464ES is not set
# CONFIG_SND_MAESTRO3 is not set
# CONFIG_SND_MIXART is not set
# CONFIG_SND_NM256 is not set
# CONFIG_SND_PCXHR is not set
# CONFIG_SND_RIPTIDE is not set
# CONFIG_SND_RME32 is not set
# CONFIG_SND_RME96 is not set
# CONFIG_SND_RME9652 is not set
# CONFIG_SND_SONICVIBES is not set
# CONFIG_SND_TRIDENT is not set
# CONFIG_SND_VIA82XX is not set
# CONFIG_SND_VIA82XX_MODEM is not set
# CONFIG_SND_VIRTUOSO is not set
# CONFIG_SND_VX222 is not set
# CONFIG_SND_YMFPCI is not set

#
# HD-Audio
#
# CONFIG_SND_HDA_INTEL is not set
# CONFIG_SND_PCMCIA is not set
CONFIG_SND_SOC=y
CONFIG_SND_ATMEL_SOC=y

#
# SoC Audio for Freescale CPUs
#

#
# Common SoC Audio options for Freescale CPUs:
#
# CONFIG_SND_SOC_FSL_ASRC is not set
# CONFIG_SND_SOC_FSL_SAI is not set
# CONFIG_SND_SOC_FSL_SSI is not set
CONFIG_SND_SOC_FSL_SPDIF=y
CONFIG_SND_SOC_FSL_ESAI=y
CONFIG_SND_SOC_IMX_AUDMUX=y
CONFIG_SND_SST_MFLD_PLATFORM=y
CONFIG_SND_SST_IPC=y
CONFIG_SND_SST_IPC_ACPI=y
CONFIG_SND_SOC_INTEL_SST=y
CONFIG_SND_SOC_INTEL_SST_ACPI=y
CONFIG_SND_SOC_INTEL_BYTCR_RT5640_MACH=y
CONFIG_SND_SOC_I2C_AND_SPI=y

#
# CODEC drivers
#
CONFIG_SND_SOC_ADAU1701=y
CONFIG_SND_SOC_AK4554=y
CONFIG_SND_SOC_AK4642=y
CONFIG_SND_SOC_AK5386=y
CONFIG_SND_SOC_ALC5623=y
CONFIG_SND_SOC_CS35L32=y
CONFIG_SND_SOC_CS42L51=y
CONFIG_SND_SOC_CS42L51_I2C=y
CONFIG_SND_SOC_CS42L52=y
CONFIG_SND_SOC_CS42L56=y
CONFIG_SND_SOC_CS42L73=y
CONFIG_SND_SOC_CS4265=y
CONFIG_SND_SOC_CS4270=y
CONFIG_SND_SOC_CS4271=y
CONFIG_SND_SOC_CS4271_I2C=y
CONFIG_SND_SOC_CS42XX8=y
CONFIG_SND_SOC_CS42XX8_I2C=y
CONFIG_SND_SOC_HDMI_CODEC=y
CONFIG_SND_SOC_ES8328=y
CONFIG_SND_SOC_PCM1681=y
CONFIG_SND_SOC_PCM512x=y
CONFIG_SND_SOC_PCM512x_I2C=y
CONFIG_SND_SOC_RL6231=y
CONFIG_SND_SOC_RT5631=y
CONFIG_SND_SOC_RT5640=y
# CONFIG_SND_SOC_RT5677_SPI is not set
CONFIG_SND_SOC_SGTL5000=y
CONFIG_SND_SOC_SIGMADSP=y
CONFIG_SND_SOC_SIGMADSP_I2C=y
CONFIG_SND_SOC_SIRF_AUDIO_CODEC=y
CONFIG_SND_SOC_SPDIF=y
CONFIG_SND_SOC_SSM2602=y
CONFIG_SND_SOC_SSM2602_I2C=y
CONFIG_SND_SOC_SSM4567=y
CONFIG_SND_SOC_STA350=y
CONFIG_SND_SOC_TAS2552=y
CONFIG_SND_SOC_TAS5086=y
CONFIG_SND_SOC_TFA9879=y
CONFIG_SND_SOC_TLV320AIC23=y
CONFIG_SND_SOC_TLV320AIC23_I2C=y
CONFIG_SND_SOC_TLV320AIC31XX=y
CONFIG_SND_SOC_TLV320AIC3X=y
CONFIG_SND_SOC_TS3A227E=y
CONFIG_SND_SOC_WM8510=y
CONFIG_SND_SOC_WM8523=y
CONFIG_SND_SOC_WM8580=y
CONFIG_SND_SOC_WM8711=y
CONFIG_SND_SOC_WM8728=y
CONFIG_SND_SOC_WM8731=y
CONFIG_SND_SOC_WM8737=y
CONFIG_SND_SOC_WM8741=y
CONFIG_SND_SOC_WM8750=y
CONFIG_SND_SOC_WM8753=y
CONFIG_SND_SOC_WM8776=y
CONFIG_SND_SOC_WM8804=y
CONFIG_SND_SOC_WM8903=y
CONFIG_SND_SOC_WM8962=y
CONFIG_SND_SOC_WM8978=y
CONFIG_SND_SOC_TPA6130A2=y
# CONFIG_SND_SIMPLE_CARD is not set
# CONFIG_SOUND_PRIME is not set

#
# HID support
#
# CONFIG_HID is not set

#
# I2C HID support
#
# CONFIG_I2C_HID is not set
CONFIG_USB_OHCI_LITTLE_ENDIAN=y
CONFIG_USB_SUPPORT=y
CONFIG_USB_ARCH_HAS_HCD=y
# CONFIG_USB is not set

#
# USB port drivers
#

#
# USB Physical Layer drivers
#
# CONFIG_USB_PHY is not set
# CONFIG_NOP_USB_XCEIV is not set
# CONFIG_TAHVO_USB is not set
# CONFIG_USB_GADGET is not set
# CONFIG_UWB is not set
CONFIG_MMC=y
# CONFIG_MMC_DEBUG is not set
CONFIG_MMC_CLKGATE=y

#
# MMC/SD/SDIO Card Drivers
#
CONFIG_SDIO_UART=y
CONFIG_MMC_TEST=y

#
# MMC/SD/SDIO Host Controller Drivers
#
CONFIG_MMC_SDHCI=y
# CONFIG_MMC_SDHCI_PCI is not set
# CONFIG_MMC_SDHCI_ACPI is not set
CONFIG_MMC_SDHCI_PLTFM=y
# CONFIG_MMC_TIFM_SD is not set
# CONFIG_MMC_SDRICOH_CS is not set
# CONFIG_MMC_CB710 is not set
# CONFIG_MMC_VIA_SDMMC is not set
# CONFIG_MMC_USDHI6ROL0 is not set
# CONFIG_MMC_TOSHIBA_PCI is not set
# CONFIG_MEMSTICK is not set
CONFIG_NEW_LEDS=y
CONFIG_LEDS_CLASS=y

#
# LED drivers
#
# CONFIG_LEDS_LM3530 is not set
# CONFIG_LEDS_LM3642 is not set
# CONFIG_LEDS_PCA9532 is not set
CONFIG_LEDS_LP3944=y
CONFIG_LEDS_LP55XX_COMMON=y
CONFIG_LEDS_LP5521=y
CONFIG_LEDS_LP5523=y
# CONFIG_LEDS_LP5562 is not set
# CONFIG_LEDS_LP8501 is not set
CONFIG_LEDS_LP8788=y
CONFIG_LEDS_LP8860=y
CONFIG_LEDS_PCA955X=y
CONFIG_LEDS_PCA963X=y
CONFIG_LEDS_WM831X_STATUS=y
CONFIG_LEDS_REGULATOR=y
CONFIG_LEDS_BD2802=y
CONFIG_LEDS_MC13783=y
CONFIG_LEDS_TCA6507=y
CONFIG_LEDS_MAX8997=y
CONFIG_LEDS_LM355x=y

#
# LED driver for blink(1) USB RGB LED is under Special HID drivers (HID_THINGM)
#
CONFIG_LEDS_BLINKM=y

#
# LED Triggers
#
# CONFIG_LEDS_TRIGGERS is not set
# CONFIG_ACCESSIBILITY is not set
CONFIG_EDAC=y
# CONFIG_EDAC_LEGACY_SYSFS is not set
CONFIG_EDAC_DEBUG=y
CONFIG_EDAC_MM_EDAC=y
# CONFIG_EDAC_E752X is not set
# CONFIG_EDAC_I82975X is not set
# CONFIG_EDAC_I3000 is not set
# CONFIG_EDAC_I3200 is not set
# CONFIG_EDAC_IE31200 is not set
# CONFIG_EDAC_X38 is not set
# CONFIG_EDAC_I5400 is not set
# CONFIG_EDAC_I5000 is not set
# CONFIG_EDAC_I5100 is not set
# CONFIG_EDAC_I7300 is not set
CONFIG_RTC_LIB=y
# CONFIG_RTC_CLASS is not set
CONFIG_DMADEVICES=y
# CONFIG_DMADEVICES_DEBUG is not set

#
# DMA Devices
#
# CONFIG_INTEL_MID_DMAC is not set
# CONFIG_INTEL_IOATDMA is not set
CONFIG_DW_DMAC_CORE=y
CONFIG_DW_DMAC=y
# CONFIG_DW_DMAC_PCI is not set
CONFIG_DMA_ENGINE=y
CONFIG_DMA_ACPI=y

#
# DMA Clients
#
CONFIG_ASYNC_TX_DMA=y
CONFIG_DMATEST=y
CONFIG_AUXDISPLAY=y
# CONFIG_UIO is not set
# CONFIG_VIRT_DRIVERS is not set

#
# Virtio drivers
#
# CONFIG_VIRTIO_PCI is not set
# CONFIG_VIRTIO_MMIO is not set

#
# Microsoft Hyper-V guest support
#
# CONFIG_HYPERV is not set
CONFIG_STAGING=y
# CONFIG_SLICOSS is not set

#
# IIO staging drivers
#

#
# Accelerometers
#

#
# Analog to digital converters
#

#
# Analog digital bi-direction converters
#

#
# Capacitance to digital converters
#
# CONFIG_AD7150 is not set
CONFIG_AD7152=y
CONFIG_AD7746=y

#
# Direct Digital Synthesis
#

#
# Digital gyroscope sensors
#

#
# Network Analyzer, Impedance Converters
#
CONFIG_AD5933=y

#
# Light sensors
#
# CONFIG_SENSORS_ISL29018 is not set
# CONFIG_SENSORS_ISL29028 is not set
# CONFIG_TSL2583 is not set
CONFIG_TSL2x7x=y

#
# Magnetometer sensors
#
CONFIG_SENSORS_HMC5843=y
CONFIG_SENSORS_HMC5843_I2C=y

#
# Active energy metering IC
#
CONFIG_ADE7854=y
# CONFIG_ADE7854_I2C is not set

#
# Resolver to digital converters
#

#
# Triggers - standalone
#
# CONFIG_IIO_SIMPLE_DUMMY is not set
# CONFIG_FB_XGI is not set
CONFIG_FT1000=y
# CONFIG_FT1000_PCMCIA is not set

#
# Speakup console speech
#
CONFIG_TOUCHSCREEN_SYNAPTICS_I2C_RMI4=y
CONFIG_STAGING_MEDIA=y
# CONFIG_DVB_CXD2099 is not set
# CONFIG_VIDEO_DT3155 is not set
# CONFIG_VIDEO_TLG2300 is not set
CONFIG_DVB_MN88472=y
CONFIG_DVB_MN88473=y
# CONFIG_VIDEO_SAA7191 is not set

#
# Android
#
CONFIG_ANDROID_LOGGER=y
CONFIG_ANDROID_TIMED_OUTPUT=y
CONFIG_ANDROID_LOW_MEMORY_KILLER=y
# CONFIG_SYNC is not set
# CONFIG_ION is not set
# CONFIG_WIMAX_GDM72XX is not set
# CONFIG_DGNC is not set
# CONFIG_DGAP is not set
CONFIG_GS_FPGABOOT=y
CONFIG_CRYPTO_SKEIN=y
CONFIG_UNISYSSPAR=y
CONFIG_UNISYS_VISORUTIL=y
CONFIG_UNISYS_VISORCHANNEL=y
CONFIG_UNISYS_VISORCHIPSET=y
CONFIG_UNISYS_CHANNELSTUB=y
# CONFIG_UNISYS_UISLIB is not set
# CONFIG_X86_PLATFORM_DEVICES is not set
CONFIG_CHROME_PLATFORMS=y
# CONFIG_CHROMEOS_PSTORE is not set

#
# SOC (System On Chip) specific Drivers
#
CONFIG_SOC_TI=y

#
# Hardware Spinlock drivers
#

#
# Clock Source drivers
#
CONFIG_CLKEVT_I8253=y
CONFIG_I8253_LOCK=y
CONFIG_CLKBLD_I8253=y
# CONFIG_ATMEL_PIT is not set
# CONFIG_SH_TIMER_CMT is not set
# CONFIG_SH_TIMER_MTU2 is not set
# CONFIG_SH_TIMER_TMU is not set
# CONFIG_EM_TIMER_STI is not set
# CONFIG_MAILBOX is not set
CONFIG_IOMMU_SUPPORT=y
# CONFIG_AMD_IOMMU is not set

#
# Remoteproc drivers
#
# CONFIG_STE_MODEM_RPROC is not set

#
# Rpmsg drivers
#

#
# SOC (System On Chip) specific Drivers
#
# CONFIG_PM_DEVFREQ is not set
CONFIG_EXTCON=y

#
# Extcon Device Drivers
#
CONFIG_EXTCON_ADC_JACK=y
CONFIG_EXTCON_MAX14577=y
CONFIG_EXTCON_MAX77693=y
CONFIG_EXTCON_MAX8997=y
# CONFIG_EXTCON_RT8973A is not set
CONFIG_EXTCON_SM5502=y
CONFIG_MEMORY=y
CONFIG_IIO=y
CONFIG_IIO_BUFFER=y
# CONFIG_IIO_BUFFER_CB is not set
CONFIG_IIO_KFIFO_BUF=y
CONFIG_IIO_TRIGGERED_BUFFER=y
CONFIG_IIO_TRIGGER=y
CONFIG_IIO_CONSUMERS_PER_TRIGGER=2

#
# Accelerometers
#
CONFIG_BMA180=y
# CONFIG_BMC150_ACCEL is not set
CONFIG_IIO_ST_ACCEL_3AXIS=y
CONFIG_IIO_ST_ACCEL_I2C_3AXIS=y
# CONFIG_MMA8452 is not set
CONFIG_KXCJK1013=y

#
# Analog to digital converters
#
CONFIG_AD7291=y
# CONFIG_AD799X is not set
CONFIG_AXP288_ADC=y
CONFIG_LP8788_ADC=y
CONFIG_MAX1363=y
# CONFIG_MCP3422 is not set
# CONFIG_NAU7802 is not set
CONFIG_TI_ADC081C=y

#
# Amplifiers
#

#
# Hid Sensor IIO Common
#
CONFIG_IIO_ST_SENSORS_I2C=y
CONFIG_IIO_ST_SENSORS_CORE=y

#
# Digital to analog converters
#
CONFIG_AD5064=y
CONFIG_AD5380=y
CONFIG_AD5446=y
CONFIG_MAX517=y
CONFIG_MCP4725=y

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
# Digital gyroscope sensors
#
CONFIG_BMG160=y
# CONFIG_IIO_ST_GYRO_3AXIS is not set
CONFIG_ITG3200=y

#
# Humidity sensors
#
CONFIG_SI7005=y
CONFIG_SI7020=y

#
# Inertial measurement units
#
CONFIG_INV_MPU6050_IIO=y

#
# Light sensors
#
CONFIG_ADJD_S311=y
CONFIG_AL3320A=y
CONFIG_APDS9300=y
CONFIG_CM32181=y
CONFIG_CM36651=y
CONFIG_GP2AP020A00F=y
CONFIG_ISL29125=y
# CONFIG_LTR501 is not set
CONFIG_TCS3414=y
CONFIG_TCS3472=y
CONFIG_SENSORS_TSL2563=y
CONFIG_TSL4531=y
CONFIG_VCNL4000=y

#
# Magnetometer sensors
#
CONFIG_AK09911=y
# CONFIG_MAG3110 is not set
CONFIG_IIO_ST_MAGN_3AXIS=y
CONFIG_IIO_ST_MAGN_I2C_3AXIS=y

#
# Inclinometer sensors
#

#
# Triggers - standalone
#
CONFIG_IIO_INTERRUPT_TRIGGER=y
CONFIG_IIO_SYSFS_TRIGGER=y

#
# Pressure sensors
#
CONFIG_BMP280=y
# CONFIG_MPL115 is not set
# CONFIG_MPL3115 is not set
CONFIG_IIO_ST_PRESS=y
CONFIG_IIO_ST_PRESS_I2C=y
CONFIG_T5403=y

#
# Lightning sensors
#

#
# Temperature sensors
#
CONFIG_MLX90614=y
CONFIG_TMP006=y
# CONFIG_NTB is not set
# CONFIG_VME_BUS is not set
# CONFIG_PWM is not set
# CONFIG_IPACK_BUS is not set
CONFIG_RESET_CONTROLLER=y
# CONFIG_FMC is not set

#
# PHY Subsystem
#
CONFIG_GENERIC_PHY=y
CONFIG_BCM_KONA_USB2_PHY=y
CONFIG_POWERCAP=y
# CONFIG_MCB is not set
CONFIG_RAS=y
# CONFIG_THUNDERBOLT is not set

#
# Android
#
CONFIG_ANDROID=y
CONFIG_ANDROID_BINDER_IPC=y

#
# Firmware Drivers
#
# CONFIG_EDD is not set
# CONFIG_FIRMWARE_MEMMAP is not set
CONFIG_DELL_RBU=y
# CONFIG_DCDBAS is not set
# CONFIG_ISCSI_IBFT_FIND is not set
CONFIG_GOOGLE_FIRMWARE=y

#
# Google Firmware Drivers
#

#
# File systems
#
CONFIG_DCACHE_WORD_ACCESS=y
CONFIG_FS_POSIX_ACL=y
CONFIG_EXPORTFS=y
CONFIG_FILE_LOCKING=y
CONFIG_FSNOTIFY=y
CONFIG_DNOTIFY=y
CONFIG_INOTIFY_USER=y
# CONFIG_FANOTIFY is not set
# CONFIG_QUOTA is not set
# CONFIG_QUOTACTL is not set
CONFIG_AUTOFS4_FS=y
CONFIG_FUSE_FS=y
# CONFIG_CUSE is not set
# CONFIG_OVERLAY_FS is not set

#
# Caches
#
CONFIG_FSCACHE=y
CONFIG_FSCACHE_DEBUG=y

#
# Pseudo filesystems
#
# CONFIG_PROC_FS is not set
CONFIG_KERNFS=y
CONFIG_SYSFS=y
# CONFIG_HUGETLBFS is not set
# CONFIG_HUGETLB_PAGE is not set
CONFIG_CONFIGFS_FS=y
CONFIG_MISC_FILESYSTEMS=y
# CONFIG_ECRYPT_FS is not set
CONFIG_JFFS2_FS=y
CONFIG_JFFS2_FS_DEBUG=0
CONFIG_JFFS2_FS_WRITEBUFFER=y
# CONFIG_JFFS2_FS_WBUF_VERIFY is not set
# CONFIG_JFFS2_SUMMARY is not set
CONFIG_JFFS2_FS_XATTR=y
CONFIG_JFFS2_FS_POSIX_ACL=y
# CONFIG_JFFS2_FS_SECURITY is not set
CONFIG_JFFS2_COMPRESSION_OPTIONS=y
CONFIG_JFFS2_ZLIB=y
CONFIG_JFFS2_LZO=y
# CONFIG_JFFS2_RTIME is not set
# CONFIG_JFFS2_RUBIN is not set
# CONFIG_JFFS2_CMODE_NONE is not set
CONFIG_JFFS2_CMODE_PRIORITY=y
# CONFIG_JFFS2_CMODE_SIZE is not set
# CONFIG_JFFS2_CMODE_FAVOURLZO is not set
CONFIG_UBIFS_FS=y
CONFIG_UBIFS_FS_ADVANCED_COMPR=y
# CONFIG_UBIFS_FS_LZO is not set
# CONFIG_UBIFS_FS_ZLIB is not set
# CONFIG_LOGFS is not set
CONFIG_ROMFS_FS=y
CONFIG_ROMFS_BACKED_BY_MTD=y
CONFIG_ROMFS_ON_MTD=y
# CONFIG_PSTORE is not set
CONFIG_NETWORK_FILESYSTEMS=y
CONFIG_NLS=y
CONFIG_NLS_DEFAULT="iso8859-1"
CONFIG_NLS_CODEPAGE_437=y
CONFIG_NLS_CODEPAGE_737=y
CONFIG_NLS_CODEPAGE_775=y
# CONFIG_NLS_CODEPAGE_850 is not set
# CONFIG_NLS_CODEPAGE_852 is not set
CONFIG_NLS_CODEPAGE_855=y
CONFIG_NLS_CODEPAGE_857=y
CONFIG_NLS_CODEPAGE_860=y
CONFIG_NLS_CODEPAGE_861=y
CONFIG_NLS_CODEPAGE_862=y
# CONFIG_NLS_CODEPAGE_863 is not set
CONFIG_NLS_CODEPAGE_864=y
CONFIG_NLS_CODEPAGE_865=y
CONFIG_NLS_CODEPAGE_866=y
# CONFIG_NLS_CODEPAGE_869 is not set
CONFIG_NLS_CODEPAGE_936=y
# CONFIG_NLS_CODEPAGE_950 is not set
CONFIG_NLS_CODEPAGE_932=y
# CONFIG_NLS_CODEPAGE_949 is not set
CONFIG_NLS_CODEPAGE_874=y
# CONFIG_NLS_ISO8859_8 is not set
CONFIG_NLS_CODEPAGE_1250=y
CONFIG_NLS_CODEPAGE_1251=y
CONFIG_NLS_ASCII=y
CONFIG_NLS_ISO8859_1=y
CONFIG_NLS_ISO8859_2=y
CONFIG_NLS_ISO8859_3=y
CONFIG_NLS_ISO8859_4=y
CONFIG_NLS_ISO8859_5=y
CONFIG_NLS_ISO8859_6=y
# CONFIG_NLS_ISO8859_7 is not set
CONFIG_NLS_ISO8859_9=y
CONFIG_NLS_ISO8859_13=y
CONFIG_NLS_ISO8859_14=y
CONFIG_NLS_ISO8859_15=y
CONFIG_NLS_KOI8_R=y
CONFIG_NLS_KOI8_U=y
CONFIG_NLS_MAC_ROMAN=y
CONFIG_NLS_MAC_CELTIC=y
CONFIG_NLS_MAC_CENTEURO=y
CONFIG_NLS_MAC_CROATIAN=y
CONFIG_NLS_MAC_CYRILLIC=y
CONFIG_NLS_MAC_GAELIC=y
# CONFIG_NLS_MAC_GREEK is not set
CONFIG_NLS_MAC_ICELAND=y
# CONFIG_NLS_MAC_INUIT is not set
CONFIG_NLS_MAC_ROMANIAN=y
CONFIG_NLS_MAC_TURKISH=y
CONFIG_NLS_UTF8=y

#
# Kernel hacking
#
CONFIG_TRACE_IRQFLAGS_SUPPORT=y

#
# printk and dmesg options
#
CONFIG_PRINTK_TIME=y
CONFIG_MESSAGE_LOGLEVEL_DEFAULT=4
# CONFIG_BOOT_PRINTK_DELAY is not set
# CONFIG_DYNAMIC_DEBUG is not set

#
# Compile-time checks and compiler options
#
# CONFIG_DEBUG_INFO is not set
CONFIG_ENABLE_WARN_DEPRECATED=y
# CONFIG_ENABLE_MUST_CHECK is not set
CONFIG_FRAME_WARN=2048
# CONFIG_STRIP_ASM_SYMS is not set
CONFIG_READABLE_ASM=y
# CONFIG_UNUSED_SYMBOLS is not set
# CONFIG_PAGE_OWNER is not set
CONFIG_DEBUG_FS=y
# CONFIG_HEADERS_CHECK is not set
# CONFIG_DEBUG_SECTION_MISMATCH is not set
CONFIG_ARCH_WANT_FRAME_POINTERS=y
CONFIG_FRAME_POINTER=y
CONFIG_DEBUG_FORCE_WEAK_PER_CPU=y
# CONFIG_MAGIC_SYSRQ is not set
CONFIG_DEBUG_KERNEL=y

#
# Memory Debugging
#
CONFIG_PAGE_EXTENSION=y
CONFIG_DEBUG_PAGEALLOC=y
CONFIG_WANT_PAGE_DEBUG_FLAGS=y
CONFIG_PAGE_GUARD=y
# CONFIG_DEBUG_OBJECTS is not set
# CONFIG_SLUB_STATS is not set
CONFIG_HAVE_DEBUG_KMEMLEAK=y
# CONFIG_DEBUG_KMEMLEAK is not set
CONFIG_DEBUG_STACK_USAGE=y
CONFIG_DEBUG_VM=y
# CONFIG_DEBUG_VM_VMACACHE is not set
# CONFIG_DEBUG_VM_RB is not set
# CONFIG_DEBUG_VIRTUAL is not set
# CONFIG_DEBUG_MEMORY_INIT is not set
CONFIG_HAVE_DEBUG_STACKOVERFLOW=y
# CONFIG_DEBUG_STACKOVERFLOW is not set
CONFIG_HAVE_ARCH_KMEMCHECK=y
# CONFIG_DEBUG_SHIRQ is not set

#
# Debug Lockups and Hangs
#
CONFIG_LOCKUP_DETECTOR=y
CONFIG_HARDLOCKUP_DETECTOR=y
# CONFIG_BOOTPARAM_HARDLOCKUP_PANIC is not set
CONFIG_BOOTPARAM_HARDLOCKUP_PANIC_VALUE=0
CONFIG_BOOTPARAM_SOFTLOCKUP_PANIC=y
CONFIG_BOOTPARAM_SOFTLOCKUP_PANIC_VALUE=1
# CONFIG_DETECT_HUNG_TASK is not set
# CONFIG_PANIC_ON_OOPS is not set
CONFIG_PANIC_ON_OOPS_VALUE=0
CONFIG_PANIC_TIMEOUT=0
CONFIG_SCHED_STACK_END_CHECK=y

#
# Lock Debugging (spinlocks, mutexes, etc...)
#
# CONFIG_DEBUG_RT_MUTEXES is not set
CONFIG_DEBUG_SPINLOCK=y
CONFIG_DEBUG_MUTEXES=y
CONFIG_DEBUG_WW_MUTEX_SLOWPATH=y
CONFIG_DEBUG_LOCK_ALLOC=y
CONFIG_PROVE_LOCKING=y
CONFIG_LOCKDEP=y
CONFIG_LOCK_STAT=y
CONFIG_DEBUG_LOCKDEP=y
CONFIG_DEBUG_ATOMIC_SLEEP=y
CONFIG_DEBUG_LOCKING_API_SELFTESTS=y
# CONFIG_LOCK_TORTURE_TEST is not set
CONFIG_TRACE_IRQFLAGS=y
CONFIG_STACKTRACE=y
# CONFIG_DEBUG_KOBJECT is not set
CONFIG_DEBUG_BUGVERBOSE=y
CONFIG_DEBUG_LIST=y
CONFIG_DEBUG_PI_LIST=y
CONFIG_DEBUG_SG=y
CONFIG_DEBUG_NOTIFIERS=y
# CONFIG_DEBUG_CREDENTIALS is not set

#
# RCU Debugging
#
# CONFIG_PROVE_RCU is not set
CONFIG_SPARSE_RCU_POINTER=y
CONFIG_TORTURE_TEST=y
CONFIG_RCU_TORTURE_TEST=y
# CONFIG_RCU_TORTURE_TEST_RUNNABLE is not set
# CONFIG_RCU_TRACE is not set
CONFIG_NOTIFIER_ERROR_INJECTION=y
CONFIG_PM_NOTIFIER_ERROR_INJECT=y
# CONFIG_FAULT_INJECTION is not set
CONFIG_ARCH_HAS_DEBUG_STRICT_USER_COPY_CHECKS=y
# CONFIG_DEBUG_STRICT_USER_COPY_CHECKS is not set
CONFIG_USER_STACKTRACE_SUPPORT=y
CONFIG_HAVE_FUNCTION_TRACER=y
CONFIG_HAVE_FUNCTION_GRAPH_TRACER=y
CONFIG_HAVE_FUNCTION_GRAPH_FP_TEST=y
CONFIG_HAVE_DYNAMIC_FTRACE=y
CONFIG_HAVE_DYNAMIC_FTRACE_WITH_REGS=y
CONFIG_HAVE_FTRACE_MCOUNT_RECORD=y
CONFIG_HAVE_SYSCALL_TRACEPOINTS=y
CONFIG_HAVE_FENTRY=y
CONFIG_HAVE_C_RECORDMCOUNT=y
CONFIG_TRACING_SUPPORT=y
# CONFIG_FTRACE is not set

#
# Runtime Testing
#
# CONFIG_TEST_LIST_SORT is not set
# CONFIG_BACKTRACE_SELF_TEST is not set
CONFIG_RBTREE_TEST=y
CONFIG_ATOMIC64_SELFTEST=y
CONFIG_TEST_STRING_HELPERS=y
CONFIG_TEST_KSTRTOX=y
CONFIG_TEST_RHASHTABLE=y
# CONFIG_PROVIDE_OHCI1394_DMA_INIT is not set
# CONFIG_DMA_API_DEBUG is not set
CONFIG_TEST_FIRMWARE=y
# CONFIG_TEST_UDELAY is not set
# CONFIG_SAMPLES is not set
CONFIG_HAVE_ARCH_KGDB=y
# CONFIG_KGDB is not set
# CONFIG_STRICT_DEVMEM is not set
CONFIG_X86_VERBOSE_BOOTUP=y
CONFIG_EARLY_PRINTK=y
# CONFIG_EARLY_PRINTK_DBGP is not set
CONFIG_X86_PTDUMP=y
CONFIG_DEBUG_RODATA=y
CONFIG_DEBUG_RODATA_TEST=y
CONFIG_DOUBLEFAULT=y
# CONFIG_DEBUG_TLBFLUSH is not set
CONFIG_IOMMU_STRESS=y
CONFIG_HAVE_MMIOTRACE_SUPPORT=y
CONFIG_IO_DELAY_TYPE_0X80=0
CONFIG_IO_DELAY_TYPE_0XED=1
CONFIG_IO_DELAY_TYPE_UDELAY=2
CONFIG_IO_DELAY_TYPE_NONE=3
# CONFIG_IO_DELAY_0X80 is not set
# CONFIG_IO_DELAY_0XED is not set
CONFIG_IO_DELAY_UDELAY=y
# CONFIG_IO_DELAY_NONE is not set
CONFIG_DEFAULT_IO_DELAY_TYPE=2
# CONFIG_DEBUG_BOOT_PARAMS is not set
# CONFIG_CPA_DEBUG is not set
# CONFIG_OPTIMIZE_INLINING is not set
CONFIG_DEBUG_NMI_SELFTEST=y
CONFIG_X86_DEBUG_STATIC_CPU_HAS=y

#
# Security options
#
CONFIG_KEYS=y
CONFIG_PERSISTENT_KEYRINGS=y
CONFIG_ENCRYPTED_KEYS=y
# CONFIG_KEYS_DEBUG_PROC_KEYS is not set
CONFIG_SECURITY_DMESG_RESTRICT=y
CONFIG_SECURITY=y
# CONFIG_SECURITYFS is not set
CONFIG_SECURITY_NETWORK=y
CONFIG_SECURITY_PATH=y
# CONFIG_SECURITY_TOMOYO is not set
# CONFIG_SECURITY_APPARMOR is not set
# CONFIG_SECURITY_YAMA is not set
# CONFIG_INTEGRITY is not set
CONFIG_DEFAULT_SECURITY_DAC=y
CONFIG_DEFAULT_SECURITY=""
CONFIG_CRYPTO=y

#
# Crypto core or helper
#
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
CONFIG_CRYPTO_PCOMP=y
CONFIG_CRYPTO_PCOMP2=y
CONFIG_CRYPTO_MANAGER=y
CONFIG_CRYPTO_MANAGER2=y
# CONFIG_CRYPTO_USER is not set
CONFIG_CRYPTO_MANAGER_DISABLE_TESTS=y
CONFIG_CRYPTO_GF128MUL=y
CONFIG_CRYPTO_NULL=y
CONFIG_CRYPTO_WORKQUEUE=y
CONFIG_CRYPTO_CRYPTD=y
CONFIG_CRYPTO_MCRYPTD=y
CONFIG_CRYPTO_AUTHENC=y
CONFIG_CRYPTO_ABLK_HELPER=y
CONFIG_CRYPTO_GLUE_HELPER_X86=y

#
# Authenticated Encryption with Associated Data
#
# CONFIG_CRYPTO_CCM is not set
# CONFIG_CRYPTO_GCM is not set
# CONFIG_CRYPTO_SEQIV is not set

#
# Block modes
#
CONFIG_CRYPTO_CBC=y
# CONFIG_CRYPTO_CTR is not set
CONFIG_CRYPTO_CTS=y
CONFIG_CRYPTO_ECB=y
CONFIG_CRYPTO_LRW=y
# CONFIG_CRYPTO_PCBC is not set
CONFIG_CRYPTO_XTS=y

#
# Hash modes
#
CONFIG_CRYPTO_CMAC=y
CONFIG_CRYPTO_HMAC=y
CONFIG_CRYPTO_XCBC=y
CONFIG_CRYPTO_VMAC=y

#
# Digest
#
CONFIG_CRYPTO_CRC32C=y
# CONFIG_CRYPTO_CRC32C_INTEL is not set
# CONFIG_CRYPTO_CRC32 is not set
CONFIG_CRYPTO_CRC32_PCLMUL=y
CONFIG_CRYPTO_CRCT10DIF=y
CONFIG_CRYPTO_GHASH=y
# CONFIG_CRYPTO_MD4 is not set
CONFIG_CRYPTO_MD5=y
CONFIG_CRYPTO_MICHAEL_MIC=y
# CONFIG_CRYPTO_RMD128 is not set
CONFIG_CRYPTO_RMD160=y
CONFIG_CRYPTO_RMD256=y
CONFIG_CRYPTO_RMD320=y
CONFIG_CRYPTO_SHA1=y
CONFIG_CRYPTO_SHA1_SSSE3=y
# CONFIG_CRYPTO_SHA256_SSSE3 is not set
CONFIG_CRYPTO_SHA512_SSSE3=y
CONFIG_CRYPTO_SHA1_MB=y
CONFIG_CRYPTO_SHA256=y
CONFIG_CRYPTO_SHA512=y
# CONFIG_CRYPTO_TGR192 is not set
# CONFIG_CRYPTO_WP512 is not set
# CONFIG_CRYPTO_GHASH_CLMUL_NI_INTEL is not set

#
# Ciphers
#
CONFIG_CRYPTO_AES=y
CONFIG_CRYPTO_AES_X86_64=y
CONFIG_CRYPTO_AES_NI_INTEL=y
CONFIG_CRYPTO_ANUBIS=y
# CONFIG_CRYPTO_ARC4 is not set
# CONFIG_CRYPTO_BLOWFISH is not set
CONFIG_CRYPTO_BLOWFISH_COMMON=y
CONFIG_CRYPTO_BLOWFISH_X86_64=y
CONFIG_CRYPTO_CAMELLIA=y
CONFIG_CRYPTO_CAMELLIA_X86_64=y
CONFIG_CRYPTO_CAMELLIA_AESNI_AVX_X86_64=y
CONFIG_CRYPTO_CAMELLIA_AESNI_AVX2_X86_64=y
CONFIG_CRYPTO_CAST_COMMON=y
CONFIG_CRYPTO_CAST5=y
CONFIG_CRYPTO_CAST5_AVX_X86_64=y
CONFIG_CRYPTO_CAST6=y
# CONFIG_CRYPTO_CAST6_AVX_X86_64 is not set
CONFIG_CRYPTO_DES=y
CONFIG_CRYPTO_DES3_EDE_X86_64=y
CONFIG_CRYPTO_FCRYPT=y
CONFIG_CRYPTO_KHAZAD=y
# CONFIG_CRYPTO_SALSA20 is not set
CONFIG_CRYPTO_SALSA20_X86_64=y
CONFIG_CRYPTO_SEED=y
CONFIG_CRYPTO_SERPENT=y
CONFIG_CRYPTO_SERPENT_SSE2_X86_64=y
CONFIG_CRYPTO_SERPENT_AVX_X86_64=y
CONFIG_CRYPTO_SERPENT_AVX2_X86_64=y
# CONFIG_CRYPTO_TEA is not set
CONFIG_CRYPTO_TWOFISH=y
CONFIG_CRYPTO_TWOFISH_COMMON=y
CONFIG_CRYPTO_TWOFISH_X86_64=y
CONFIG_CRYPTO_TWOFISH_X86_64_3WAY=y
# CONFIG_CRYPTO_TWOFISH_AVX_X86_64 is not set

#
# Compression
#
CONFIG_CRYPTO_DEFLATE=y
CONFIG_CRYPTO_ZLIB=y
# CONFIG_CRYPTO_LZO is not set
CONFIG_CRYPTO_LZ4=y
CONFIG_CRYPTO_LZ4HC=y

#
# Random Number Generation
#
CONFIG_CRYPTO_ANSI_CPRNG=y
# CONFIG_CRYPTO_DRBG_MENU is not set
# CONFIG_CRYPTO_USER_API_HASH is not set
# CONFIG_CRYPTO_USER_API_SKCIPHER is not set
# CONFIG_CRYPTO_HW is not set
CONFIG_ASYMMETRIC_KEY_TYPE=y
# CONFIG_ASYMMETRIC_PUBLIC_KEY_SUBTYPE is not set
CONFIG_PUBLIC_KEY_ALGO_RSA=y
CONFIG_HAVE_KVM=y
# CONFIG_VIRTUALIZATION is not set
# CONFIG_BINARY_PRINTF is not set

#
# Library routines
#
CONFIG_BITREVERSE=y
CONFIG_GENERIC_STRNCPY_FROM_USER=y
CONFIG_GENERIC_STRNLEN_USER=y
CONFIG_GENERIC_NET_UTILS=y
CONFIG_GENERIC_FIND_FIRST_BIT=y
CONFIG_GENERIC_PCI_IOMAP=y
CONFIG_GENERIC_IOMAP=y
CONFIG_GENERIC_IO=y
CONFIG_ARCH_USE_CMPXCHG_LOCKREF=y
CONFIG_ARCH_HAS_FAST_MULTIPLIER=y
# CONFIG_CRC_CCITT is not set
CONFIG_CRC16=y
# CONFIG_CRC_T10DIF is not set
# CONFIG_CRC_ITU_T is not set
CONFIG_CRC32=y
CONFIG_CRC32_SELFTEST=y
# CONFIG_CRC32_SLICEBY8 is not set
# CONFIG_CRC32_SLICEBY4 is not set
# CONFIG_CRC32_SARWATE is not set
CONFIG_CRC32_BIT=y
CONFIG_CRC7=y
# CONFIG_LIBCRC32C is not set
CONFIG_CRC8=y
# CONFIG_AUDIT_ARCH_COMPAT_GENERIC is not set
CONFIG_RANDOM32_SELFTEST=y
CONFIG_ZLIB_INFLATE=y
CONFIG_ZLIB_DEFLATE=y
CONFIG_LZO_COMPRESS=y
CONFIG_LZO_DECOMPRESS=y
CONFIG_LZ4_COMPRESS=y
CONFIG_LZ4HC_COMPRESS=y
CONFIG_LZ4_DECOMPRESS=y
# CONFIG_XZ_DEC is not set
# CONFIG_XZ_DEC_BCJ is not set
CONFIG_DECOMPRESS_GZIP=y
CONFIG_DECOMPRESS_LZO=y
CONFIG_DECOMPRESS_LZ4=y
CONFIG_GENERIC_ALLOCATOR=y
CONFIG_BCH=y
CONFIG_ASSOCIATIVE_ARRAY=y
CONFIG_HAS_IOMEM=y
CONFIG_HAS_IOPORT_MAP=y
CONFIG_HAS_DMA=y
CONFIG_DQL=y
CONFIG_NLATTR=y
CONFIG_ARCH_HAS_ATOMIC64_DEC_IF_POSITIVE=y
CONFIG_AVERAGE=y
CONFIG_CLZ_TAB=y
CONFIG_CORDIC=y
CONFIG_DDR=y
CONFIG_MPILIB=y
CONFIG_ARCH_HAS_SG_CHAIN=y

--OgqxwSJOaUobr8KG
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

_______________________________________________
LKP mailing list
LKP@linux.intel.com

--OgqxwSJOaUobr8KG--
