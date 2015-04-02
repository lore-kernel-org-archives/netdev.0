From: Fengguang Wu <fengguang.wu@intel.com>
Subject: [rhashtable] [ INFO: suspicious RCU usage. ]
Date: Thu, 2 Apr 2015 08:52:11 +0800
Message-ID: <20150402005211.GC12979@wfg-t540p.sh.intel.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="R3G7APHDIzY6R/pk"
Cc: fengguang.wu@intel.com, LKP <lkp@01.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:3109 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751533AbbDBAwP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Apr 2015 20:52:15 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--R3G7APHDIzY6R/pk
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Herbert,

0day kernel testing robot got the below dmesg and the first bad commit is

git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master

commit ccd57b1bd32460d27bbb9c599e795628a3c66983
Author:     Herbert Xu <herbert@gondor.apana.org.au>
AuthorDate: Tue Mar 24 00:50:28 2015 +1100
Commit:     David S. Miller <davem@davemloft.net>
CommitDate: Mon Mar 23 22:07:52 2015 -0400

    rhashtable: Add immediate rehash during insertion
    
    This patch reintroduces immediate rehash during insertion.  If
    we find during insertion that the table is full or the chain
    length exceeds a set limit (currently 16 but may be disabled
    with insecure_elasticity) then we will force an immediate rehash.
    The rehash will contain an expansion if the table utilisation
    exceeds 75%.
    
    If this rehash fails then the insertion will fail.  Otherwise the
    insertion will be reattempted in the new hash table.
    
    Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
    Acked-by: Thomas Graf <tgraf@suug.ch>
    Signed-off-by: David S. Miller <davem@davemloft.net>

[    0.552992]   Adding 2048 keys
[    0.553792] 
[    0.554400] ===============================
[    0.555285] [ INFO: suspicious RCU usage. ]
[    0.556176] 4.0.0-rc4-01225-gccd57b1 #171 Not tainted
[    0.557156] -------------------------------
[    0.558044] lib/rhashtable.c:400 suspicious rcu_dereference_check() usage!
[    0.559741] 
[    0.559741] other info that might help us debug this:
[    0.559741] 
[    0.561764] 
[    0.561764] rcu_scheduler_active = 1, debug_locks = 0
[    0.563254] no locks held by swapper/0/1.
[    0.564124] 
[    0.564124] stack backtrace:
[    0.565394] CPU: 0 PID: 1 Comm: swapper/0 Not tainted 4.0.0-rc4-01225-gccd57b1 #171
[    0.567017] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.7.5-20140531_083030-gandalf 04/01/2014
[    0.568898]  0000000000000001 ffff88000f563d38 ffffffff8182e695 0000000000000011
[    0.570775]  ffff88000f558000 ffff88000f563d68 ffffffff810ffce7 ffffffff831fc340
[    0.572637]  ffff88000e874d10 000000000000000d ffff88000e199e40 ffff88000f563da8
[    0.574519] Call Trace:
[    0.575219]  [<ffffffff8182e695>] dump_stack+0x4c/0x65
[    0.576210]  [<ffffffff810ffce7>] lockdep_rcu_suspicious+0xe7/0x120
[    0.577314]  [<ffffffff8142d0fe>] rhashtable_insert_rehash+0x18e/0x1d0
[    0.578443]  [<ffffffff8221814c>] test_rht_init+0x38f/0x12bd
[    0.579483]  [<ffffffff810002c0>] ? do_one_initcall+0x80/0x200
[    0.580542]  [<ffffffff82217dbd>] ? test_firmware_init+0x79/0x79
[    0.581615]  [<ffffffff810002d0>] do_one_initcall+0x90/0x200
[    0.582651]  [<ffffffff821e2212>] kernel_init_freeable+0x22d/0x2b5
[    0.583743]  [<ffffffff81829160>] ? rest_init+0x140/0x140
[    0.584755]  [<ffffffff8182916e>] kernel_init+0xe/0xf0
[    0.585743]  [<ffffffff81839318>] ret_from_fork+0x58/0x90
[    0.586756]  [<ffffffff81829160>] ? rest_init+0x140/0x140
[    0.587778] ------------[ cut here ]------------
[    0.588715] WARNING: CPU: 0 PID: 1 at lib/rhashtable.c:408 rhashtable_insert_rehash+0x95/0x1d0()
[    0.590608] Modules linked in:
[    0.591439] CPU: 0 PID: 1 Comm: swapper/0 Not tainted 4.0.0-rc4-01225-gccd57b1 #171
[    0.593058] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.7.5-20140531_083030-gandalf 04/01/2014
[    0.594929]  ffffffff81d08b58 ffff88000f563d18 ffffffff8182e695 0000000000000000
[    0.596809]  0000000000000000 ffff88000f563d58 ffffffff810af7fa 00000000fffffe00
[    0.598682]  ffffffff831fc340 0000000000000010 ffff88000e199840 0000000000000001
[    0.600558] Call Trace:
[    0.601259]  [<ffffffff8182e695>] dump_stack+0x4c/0x65
[    0.602238]  [<ffffffff810af7fa>] warn_slowpath_common+0x8a/0xc0
[    0.603310]  [<ffffffff810af8ea>] warn_slowpath_null+0x1a/0x20
[    0.604366]  [<ffffffff8142d005>] rhashtable_insert_rehash+0x95/0x1d0
[    0.605495]  [<ffffffff8221814c>] test_rht_init+0x38f/0x12bd
[    0.606536]  [<ffffffff810002c0>] ? do_one_initcall+0x80/0x200
[    0.607589]  [<ffffffff82217dbd>] ? test_firmware_init+0x79/0x79
[    0.608664]  [<ffffffff810002d0>] do_one_initcall+0x90/0x200
[    0.609704]  [<ffffffff821e2212>] kernel_init_freeable+0x22d/0x2b5
[    0.610797]  [<ffffffff81829160>] ? rest_init+0x140/0x140
[    0.611808]  [<ffffffff8182916e>] kernel_init+0xe/0xf0
[    0.612792]  [<ffffffff81839318>] ret_from_fork+0x58/0x90
[    0.613801]  [<ffffffff81829160>] ? rest_init+0x140/0x140
[    0.614808] ---[ end trace b5aa4dbce5f556f0 ]---
[    0.615763] glob: 64 self-tests passed, 0 failed

git bisect start 4fab6501bb2945a0c0c9045c059ac342147856fd e42391cd048809d903291d07f86ed3934ce138e9 --
git bisect  bad 92d9ebca6ac4759827ea9785ace3aecba37e78ad  # 19:58      0-     20  Merge 'devfreq/for-rafael' into devel-hourly-2015033101
git bisect  bad 18dd8e1456f801932f2e75e636d9132297e402d5  # 19:58      0-     20  Merge 'peterhuewe-tpmdd/for-current' into devel-hourly-2015033101
git bisect good 49e34ea97b39e88623b1c0e658ba0cf27034150e  # 19:58     20+      0  Merge 'tegra/for-4.1/dt' into devel-hourly-2015033101
git bisect good f81c2b2a8cf42ef78cd7e0aa08d880eec7e0787a  # 20:02     20+      1  Merge 'tegra/for-next' into devel-hourly-2015033101
git bisect  bad e0ac3b3842ecc894c7fa5d0a02596f15875f89eb  # 20:02      0-     20  Merge 'lunn/v4.0-rc5-groeck-dsa-next-cleanup' into devel-hourly-2015033101
git bisect good 749e956cfcc62b4ca948e6fb40c06d412e1d75c6  # 20:02     20+      0  Merge 'mvebu/for-next' into devel-hourly-2015033101
git bisect good 0f7bbd5805e3d32e3ee58d1a802a8404a724f2fc  # 20:05     20+     40  mpls: Better error code for unsupported option.
git bisect good 6eada0110c8984477f5f1e57a0b7f7b2fc841e30  # 20:11     20+     40  netns: constify net_hash_mix() and various callers
git bisect good c637aab05c9dd0894832a7c542a1553b2815b9ef  # 20:11     20+      0  can: kvaser_usb: Use can-dev unregistration mechanism
git bisect  bad ce046c568cbfb4734583131086f88cfe993c01d0  # 20:11      0-     20  Merge branch 'ipv6_stable_privacy_address'
git bisect good 40451fd013878b005ccae767dfebc07dfecf85d9  # 20:11     20+      0  Merge git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next
git bisect  bad ca8cf341903f90070e191cc8be8f705ab7af2d4a  # 20:11      0-     20  net: bcmgenet: propagate errors from bcmgenet_power_down
git bisect good 31ccde2dacea8375c3a7d6fffbf0060ee0d40214  # 20:14     20+      2  rhashtable: Allow hashfn to be unset
git bisect good b824478b2145be78ac19e1cf44e2b9036c7a9608  # 20:14     20+      0  rhashtable: Add multiple rehash support
git bisect  bad ccd57b1bd32460d27bbb9c599e795628a3c66983  # 20:14      0-     20  rhashtable: Add immediate rehash during insertion
git bisect good b9ecfdaa1090b5988422eaf5348ea1954d2d7219  # 20:18     20+      1  rhashtable: Allow GFP_ATOMIC bucket table allocation
# first bad commit: [ccd57b1bd32460d27bbb9c599e795628a3c66983] rhashtable: Add immediate rehash during insertion
git bisect good b9ecfdaa1090b5988422eaf5348ea1954d2d7219  # 20:24     60+      1  rhashtable: Allow GFP_ATOMIC bucket table allocation
# extra tests with DEBUG_INFO
git bisect  bad ccd57b1bd32460d27bbb9c599e795628a3c66983  # 20:24      0-     60  rhashtable: Add immediate rehash during insertion
# extra tests on HEAD of linux-devel/devel-hourly-2015033101
git bisect  bad 4fab6501bb2945a0c0c9045c059ac342147856fd  # 20:24      0-     22  0day head guard for 'devel-hourly-2015033101'
# extra tests on tree/branch next/master
git bisect  bad e954104e2b634b42811dad8d502cbf240f206df2  # 20:35      0-      1  Add linux-next specific files for 20150401
# extra tests on tree/branch linus/master
git bisect good 6c310bc1acdd02110182a2ec6efa3e7571a3b80c  # 21:22     60+      1  Merge tag 'locks-v4.0-5' of git://git.samba.org/jlayton/linux
# extra tests on tree/branch next/master
git bisect  bad e954104e2b634b42811dad8d502cbf240f206df2  # 21:22      0-     60  Add linux-next specific files for 20150401


This script may reproduce the error.

----------------------------------------------------------------------------
#!/bin/bash

kernel=$1
initrd=yocto-minimal-x86_64.cgz

wget --no-clobber https://github.com/fengguang/reproduce-kernel-bug/raw/master/initrd/$initrd

kvm=(
	qemu-system-x86_64
	-enable-kvm
	-cpu Haswell,+smep,+smap
	-kernel $kernel
	-initrd $initrd
	-m 256
	-smp 1
	-device e1000,netdev=net0
	-netdev user,id=net0
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
	rd.udev.log-priority=err
	systemd.log_target=journal
	systemd.log_level=warning
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

--R3G7APHDIzY6R/pk
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="dmesg-yocto-ivb41-3:20150331113735:x86_64-randconfig-n0-03310731:4.0.0-rc4-01225-gccd57b1:171"
Content-Transfer-Encoding: quoted-printable

early console in setup code
Probing EDD (edd=3Doff to disable)... ok
early console in decompress_kernel
KASLR disabled by default...

Decompressing Linux... Parsing ELF... done.
Booting the kernel.
[    0.000000] Initializing cgroup subsys cpuset
[    0.000000] Initializing cgroup subsys cpu
[    0.000000] Linux version 4.0.0-rc4-01225-gccd57b1 (kbuild@lkp-nhm1) (gc=
c version 4.9.1 (Debian 4.9.1-19) ) #171 SMP Tue Mar 31 11:25:53 CST 2015
[    0.000000] Command line: hung_task_panic=3D1 earlyprintk=3DttyS0,115200=
 rd.udev.log-priority=3Derr systemd.log_target=3Djournal systemd.log_level=
=3Dwarning debug apic=3Ddebug sysrq_always_enabled rcupdate.rcu_cpu_stall_t=
imeout=3D100 panic=3D-1 softlockup_panic=3D1 nmi_watchdog=3Dpanic oops=3Dpa=
nic load_ramdisk=3D2 prompt_ramdisk=3D0 console=3DttyS0,115200 console=3Dtt=
y0 vga=3Dnormal  root=3D/dev/ram0 rw link=3D/kbuild-tests/run-queue/kvm/x86=
_64-randconfig-n0-03310731/linux-devel:devel-hourly-2015033101:ccd57b1bd324=
60d27bbb9c599e795628a3c66983:bisect-linux-2/.vmlinuz-ccd57b1bd32460d27bbb9c=
599e795628a3c66983-20150331112724-8-ivb41 branch=3Dlinux-devel/devel-hourly=
-2015033101 BOOT_IMAGE=3D/kernel/x86_64-randconfig-n0-03310731/ccd57b1bd324=
60d27bbb9c599e795628a3c66983/vmlinuz-4.0.0-rc4-01225-gccd57b1 drbd.minor_co=
unt=3D8
[    0.000000] e820: BIOS-provided physical RAM map:
[    0.000000] BIOS-e820: [mem 0x0000000000000000-0x000000000009fbff] usable
[    0.000000] BIOS-e820: [mem 0x000000000009fc00-0x000000000009ffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000000f0000-0x00000000000fffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x0000000000100000-0x000000000ffdffff] usable
[    0.000000] BIOS-e820: [mem 0x000000000ffe0000-0x000000000fffffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000feffc000-0x00000000feffffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000fffc0000-0x00000000ffffffff] reser=
ved
[    0.000000] bootconsole [earlyser0] enabled
[    0.000000] NX (Execute Disable) protection: active
[    0.000000] SMBIOS 2.8 present.
[    0.000000] DMI: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.7.5-2014=
0531_083030-gandalf 04/01/2014
[    0.000000] Hypervisor detected: KVM
[    0.000000] e820: update [mem 0x00000000-0x00000fff] usable =3D=3D> rese=
rved
[    0.000000] e820: remove [mem 0x000a0000-0x000fffff] usable
[    0.000000] e820: last_pfn =3D 0xffe0 max_arch_pfn =3D 0x400000000
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
[    0.000000] PAT configuration [0-7]: WB  WC  UC- UC  WB  WC  UC- UC =20
[    0.000000] Scan for SMP in [mem 0x00000000-0x000003ff]
[    0.000000] Scan for SMP in [mem 0x0009fc00-0x0009ffff]
[    0.000000] Scan for SMP in [mem 0x000f0000-0x000fffff]
[    0.000000] found SMP MP-table at [mem 0x000f0e90-0x000f0e9f] mapped at =
[ffff8800000f0e90]
[    0.000000]   mpc: f0ea0-f0fa8
[    0.000000] Base memory trampoline at [ffff880000099000] 99000 size 24576
[    0.000000] init_memory_mapping: [mem 0x00000000-0x000fffff]
[    0.000000]  [mem 0x00000000-0x000fffff] page 4k
[    0.000000] BRK [0x0322b000, 0x0322bfff] PGTABLE
[    0.000000] BRK [0x0322c000, 0x0322cfff] PGTABLE
[    0.000000] BRK [0x0322d000, 0x0322dfff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0x0fa00000-0x0fbfffff]
[    0.000000]  [mem 0x0fa00000-0x0fbfffff] page 2M
[    0.000000] init_memory_mapping: [mem 0x00100000-0x0f9fffff]
[    0.000000]  [mem 0x00100000-0x001fffff] page 4k
[    0.000000]  [mem 0x00200000-0x0f9fffff] page 2M
[    0.000000] init_memory_mapping: [mem 0x0fc00000-0x0ffdffff]
[    0.000000]  [mem 0x0fc00000-0x0fdfffff] page 2M
[    0.000000]  [mem 0x0fe00000-0x0ffdffff] page 4k
[    0.000000] BRK [0x0322e000, 0x0322efff] PGTABLE
[    0.000000] RAMDISK: [mem 0x0fcce000-0x0ffd7fff]
[    0.000000] ACPI: Early table checksum verification disabled
[    0.000000] ACPI: RSDP 0x00000000000F0CB0 000014 (v00 BOCHS )
[    0.000000] ACPI: RSDT 0x000000000FFE1854 000034 (v01 BOCHS  BXPCRSDT 00=
000001 BXPC 00000001)
[    0.000000] ACPI: FACP 0x000000000FFE0B37 000074 (v01 BOCHS  BXPCFACP 00=
000001 BXPC 00000001)
[    0.000000] ACPI: DSDT 0x000000000FFE0040 000AF7 (v01 BOCHS  BXPCDSDT 00=
000001 BXPC 00000001)
[    0.000000] ACPI: FACS 0x000000000FFE0000 000040
[    0.000000] ACPI: SSDT 0x000000000FFE0BAB 000BF9 (v01 BOCHS  BXPCSSDT 00=
000001 BXPC 00000001)
[    0.000000] ACPI: APIC 0x000000000FFE17A4 000078 (v01 BOCHS  BXPCAPIC 00=
000001 BXPC 00000001)
[    0.000000] ACPI: HPET 0x000000000FFE181C 000038 (v01 BOCHS  BXPCHPET 00=
000001 BXPC 00000001)
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to ffffffffff57d000 (        fee00000)
[    0.000000] No NUMA configuration found
[    0.000000] Faking a node at [mem 0x0000000000000000-0x000000000ffdffff]
[    0.000000] NODE_DATA(0) allocated [mem 0x0fca7000-0x0fccdfff]
[    0.000000] kvm-clock: Using msrs 4b564d01 and 4b564d00
[    0.000000] kvm-clock: cpu 0, msr 0:fc27001, primary cpu clock
[    0.000000]  [ffffea0000000000-ffffea00003fffff] PMD -> [ffff88000f00000=
0-ffff88000f3fffff] on node 0
[    0.000000] Zone ranges:
[    0.000000]   DMA      [mem 0x0000000000001000-0x0000000000ffffff]
[    0.000000]   DMA32    [mem 0x0000000001000000-0x000000000ffdffff]
[    0.000000]   Normal   empty
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x0000000000001000-0x000000000009efff]
[    0.000000]   node   0: [mem 0x0000000000100000-0x000000000ffdffff]
[    0.000000] Initmem setup node 0 [mem 0x0000000000001000-0x000000000ffdf=
fff]
[    0.000000] On node 0 totalpages: 65406
[    0.000000]   DMA zone: 64 pages used for memmap
[    0.000000]   DMA zone: 21 pages reserved
[    0.000000]   DMA zone: 3998 pages, LIFO batch:0
[    0.000000]   DMA32 zone: 960 pages used for memmap
[    0.000000]   DMA32 zone: 61408 pages, LIFO batch:15
[    0.000000] ACPI: PM-Timer IO Port: 0x608
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to ffffffffff57d000 (        fee00000)
[    0.000000] ACPI: LAPIC (acpi_id[0x00] lapic_id[0x00] enabled)
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
[    0.000000] smpboot: Allowing 1 CPUs, 0 hotplug CPUs
[    0.000000] mapped IOAPIC to ffffffffff57c000 (fec00000)
[    0.000000] PM: Registered nosave memory: [mem 0x00000000-0x00000fff]
[    0.000000] PM: Registered nosave memory: [mem 0x0009f000-0x0009ffff]
[    0.000000] PM: Registered nosave memory: [mem 0x000a0000-0x000effff]
[    0.000000] PM: Registered nosave memory: [mem 0x000f0000-0x000fffff]
[    0.000000] e820: [mem 0x10000000-0xfeffbfff] available for PCI devices
[    0.000000] Booting paravirtualized kernel on KVM
[    0.000000] setup_percpu: NR_CPUS:8192 nr_cpumask_bits:1 nr_cpu_ids:1 nr=
_node_ids:1
[    0.000000] PERCPU: Embedded 479 pages/cpu @ffff88000fa00000 s1922840 r8=
192 d30952 u2097152
[    0.000000] pcpu-alloc: s1922840 r8192 d30952 u2097152 alloc=3D1*2097152
[    0.000000] pcpu-alloc: [0] 0=20
[    0.000000] KVM setup async PF for cpu 0
[    0.000000] kvm-stealtime: cpu 0, msr fa0d340
[    0.000000] Built 1 zonelists in Node order, mobility grouping on.  Tota=
l pages: 64361
[    0.000000] Policy zone: DMA32
[    0.000000] Kernel command line: hung_task_panic=3D1 earlyprintk=3DttyS0=
,115200 rd.udev.log-priority=3Derr systemd.log_target=3Djournal systemd.log=
_level=3Dwarning debug apic=3Ddebug sysrq_always_enabled rcupdate.rcu_cpu_s=
tall_timeout=3D100 panic=3D-1 softlockup_panic=3D1 nmi_watchdog=3Dpanic oop=
s=3Dpanic load_ramdisk=3D2 prompt_ramdisk=3D0 console=3DttyS0,115200 consol=
e=3Dtty0 vga=3Dnormal  root=3D/dev/ram0 rw link=3D/kbuild-tests/run-queue/k=
vm/x86_64-randconfig-n0-03310731/linux-devel:devel-hourly-2015033101:ccd57b=
1bd32460d27bbb9c599e795628a3c66983:bisect-linux-2/.vmlinuz-ccd57b1bd32460d2=
7bbb9c599e795628a3c66983-20150331112724-8-ivb41 branch=3Dlinux-devel/devel-=
hourly-2015033101 BOOT_IMAGE=3D/kernel/x86_64-randconfig-n0-03310731/ccd57b=
1bd32460d27bbb9c599e795628a3c66983/vmlinuz-4.0.0-rc4-01225-gccd57b1 drbd.mi=
nor_count=3D8
[    0.000000] sysrq: sysrq always enabled.
[    0.000000] PID hash table entries: 1024 (order: 1, 8192 bytes)
[    0.000000] xsave: enabled xstate_bv 0x7, cntxt size 0x340 using standar=
d form
[    0.000000] Memory: 216672K/261624K available (8432K kernel code, 2087K =
rwdata, 3836K rodata, 3924K init, 14600K bss, 44952K reserved, 0K cma-reser=
ved)
[    0.000000] SLUB: HWalign=3D64, Order=3D0-3, MinObjects=3D0, CPUs=3D1, N=
odes=3D1
[    0.000000] Hierarchical RCU implementation.
[    0.000000] RCU: Adjusting geometry for rcu_fanout_leaf=3D16, nr_cpu_ids=
=3D1
[    0.000000] Running RCU self tests
[    0.000000] NR_IRQS:524544 nr_irqs:256 16
[    0.000000] Console: colour VGA+ 80x25
[    0.000000] console [tty0] enabled
[    0.000000] bootconsole [earlyser0] disabled
[    0.000000] Initializing cgroup subsys cpuset
[    0.000000] Initializing cgroup subsys cpu
[    0.000000] Linux version 4.0.0-rc4-01225-gccd57b1 (kbuild@lkp-nhm1) (gc=
c version 4.9.1 (Debian 4.9.1-19) ) #171 SMP Tue Mar 31 11:25:53 CST 2015
[    0.000000] Command line: hung_task_panic=3D1 earlyprintk=3DttyS0,115200=
 rd.udev.log-priority=3Derr systemd.log_target=3Djournal systemd.log_level=
=3Dwarning debug apic=3Ddebug sysrq_always_enabled rcupdate.rcu_cpu_stall_t=
imeout=3D100 panic=3D-1 softlockup_panic=3D1 nmi_watchdog=3Dpanic oops=3Dpa=
nic load_ramdisk=3D2 prompt_ramdisk=3D0 console=3DttyS0,115200 console=3Dtt=
y0 vga=3Dnormal  root=3D/dev/ram0 rw link=3D/kbuild-tests/run-queue/kvm/x86=
_64-randconfig-n0-03310731/linux-devel:devel-hourly-2015033101:ccd57b1bd324=
60d27bbb9c599e795628a3c66983:bisect-linux-2/.vmlinuz-ccd57b1bd32460d27bbb9c=
599e795628a3c66983-20150331112724-8-ivb41 branch=3Dlinux-devel/devel-hourly=
-2015033101 BOOT_IMAGE=3D/kernel/x86_64-randconfig-n0-03310731/ccd57b1bd324=
60d27bbb9c599e795628a3c66983/vmlinuz-4.0.0-rc4-01225-gccd57b1 drbd.minor_co=
unt=3D8
[    0.000000] e820: BIOS-provided physical RAM map:
[    0.000000] BIOS-e820: [mem 0x0000000000000000-0x000000000009fbff] usable
[    0.000000] BIOS-e820: [mem 0x000000000009fc00-0x000000000009ffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000000f0000-0x00000000000fffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x0000000000100000-0x000000000ffdffff] usable
[    0.000000] BIOS-e820: [mem 0x000000000ffe0000-0x000000000fffffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000feffc000-0x00000000feffffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000fffc0000-0x00000000ffffffff] reser=
ved
[    0.000000] bootconsole [earlyser0] enabled
[    0.000000] NX (Execute Disable) protection: active
[    0.000000] SMBIOS 2.8 present.
[    0.000000] DMI: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.7.5-2014=
0531_083030-gandalf 04/01/2014
[    0.000000] Hypervisor detected: KVM
[    0.000000] e820: update [mem 0x00000000-0x00000fff] usable =3D=3D> rese=
rved
[    0.000000] e820: remove [mem 0x000a0000-0x000fffff] usable
[    0.000000] e820: last_pfn =3D 0xffe0 max_arch_pfn =3D 0x400000000
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
[    0.000000] PAT configuration [0-7]: WB  WC  UC- UC  WB  WC  UC- UC =20
[    0.000000] Scan for SMP in [mem 0x00000000-0x000003ff]
[    0.000000] Scan for SMP in [mem 0x0009fc00-0x0009ffff]
[    0.000000] Scan for SMP in [mem 0x000f0000-0x000fffff]
[    0.000000] found SMP MP-table at [mem 0x000f0e90-0x000f0e9f] mapped at =
[ffff8800000f0e90]
[    0.000000]   mpc: f0ea0-f0fa8
[    0.000000] Base memory trampoline at [ffff880000099000] 99000 size 24576
[    0.000000] init_memory_mapping: [mem 0x00000000-0x000fffff]
[    0.000000]  [mem 0x00000000-0x000fffff] page 4k
[    0.000000] BRK [0x0322b000, 0x0322bfff] PGTABLE
[    0.000000] BRK [0x0322c000, 0x0322cfff] PGTABLE
[    0.000000] BRK [0x0322d000, 0x0322dfff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0x0fa00000-0x0fbfffff]
[    0.000000]  [mem 0x0fa00000-0x0fbfffff] page 2M
[    0.000000] init_memory_mapping: [mem 0x00100000-0x0f9fffff]
[    0.000000]  [mem 0x00100000-0x001fffff] page 4k
[    0.000000]  [mem 0x00200000-0x0f9fffff] page 2M
[    0.000000] init_memory_mapping: [mem 0x0fc00000-0x0ffdffff]
[    0.000000]  [mem 0x0fc00000-0x0fdfffff] page 2M
[    0.000000]  [mem 0x0fe00000-0x0ffdffff] page 4k
[    0.000000] BRK [0x0322e000, 0x0322efff] PGTABLE
[    0.000000] RAMDISK: [mem 0x0fcce000-0x0ffd7fff]
[    0.000000] ACPI: Early table checksum verification disabled
[    0.000000] ACPI: RSDP 0x00000000000F0CB0 000014 (v00 BOCHS )
[    0.000000] ACPI: RSDT 0x000000000FFE1854 000034 (v01 BOCHS  BXPCRSDT 00=
000001 BXPC 00000001)
[    0.000000] ACPI: FACP 0x000000000FFE0B37 000074 (v01 BOCHS  BXPCFACP 00=
000001 BXPC 00000001)
[    0.000000] ACPI: DSDT 0x000000000FFE0040 000AF7 (v01 BOCHS  BXPCDSDT 00=
000001 BXPC 00000001)
[    0.000000] ACPI: FACS 0x000000000FFE0000 000040
[    0.000000] ACPI: SSDT 0x000000000FFE0BAB 000BF9 (v01 BOCHS  BXPCSSDT 00=
000001 BXPC 00000001)
[    0.000000] ACPI: APIC 0x000000000FFE17A4 000078 (v01 BOCHS  BXPCAPIC 00=
000001 BXPC 00000001)
[    0.000000] ACPI: HPET 0x000000000FFE181C 000038 (v01 BOCHS  BXPCHPET 00=
000001 BXPC 00000001)
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to ffffffffff57d000 (        fee00000)
[    0.000000] No NUMA configuration found
[    0.000000] Faking a node at [mem 0x0000000000000000-0x000000000ffdffff]
[    0.000000] NODE_DATA(0) allocated [mem 0x0fca7000-0x0fccdfff]
[    0.000000] kvm-clock: Using msrs 4b564d01 and 4b564d00
[    0.000000] kvm-clock: cpu 0, msr 0:fc27001, primary cpu clock
[    0.000000]  [ffffea0000000000-ffffea00003fffff] PMD -> [ffff88000f00000=
0-ffff88000f3fffff] on node 0
[    0.000000] Zone ranges:
[    0.000000]   DMA      [mem 0x0000000000001000-0x0000000000ffffff]
[    0.000000]   DMA32    [mem 0x0000000001000000-0x000000000ffdffff]
[    0.000000]   Normal   empty
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x0000000000001000-0x000000000009efff]
[    0.000000]   node   0: [mem 0x0000000000100000-0x000000000ffdffff]
[    0.000000] Initmem setup node 0 [mem 0x0000000000001000-0x000000000ffdf=
fff]
[    0.000000] On node 0 totalpages: 65406
[    0.000000]   DMA zone: 64 pages used for memmap
[    0.000000]   DMA zone: 21 pages reserved
[    0.000000]   DMA zone: 3998 pages, LIFO batch:0
[    0.000000]   DMA32 zone: 960 pages used for memmap
[    0.000000]   DMA32 zone: 61408 pages, LIFO batch:15
[    0.000000] ACPI: PM-Timer IO Port: 0x608
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to ffffffffff57d000 (        fee00000)
[    0.000000] ACPI: LAPIC (acpi_id[0x00] lapic_id[0x00] enabled)
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
[    0.000000] smpboot: Allowing 1 CPUs, 0 hotplug CPUs
[    0.000000] mapped IOAPIC to ffffffffff57c000 (fec00000)
[    0.000000] PM: Registered nosave memory: [mem 0x00000000-0x00000fff]
[    0.000000] PM: Registered nosave memory: [mem 0x0009f000-0x0009ffff]
[    0.000000] PM: Registered nosave memory: [mem 0x000a0000-0x000effff]
[    0.000000] PM: Registered nosave memory: [mem 0x000f0000-0x000fffff]
[    0.000000] e820: [mem 0x10000000-0xfeffbfff] available for PCI devices
[    0.000000] Booting paravirtualized kernel on KVM
[    0.000000] setup_percpu: NR_CPUS:8192 nr_cpumask_bits:1 nr_cpu_ids:1 nr=
_node_ids:1
[    0.000000] PERCPU: Embedded 479 pages/cpu @ffff88000fa00000 s1922840 r8=
192 d30952 u2097152
[    0.000000] pcpu-alloc: s1922840 r8192 d30952 u2097152 alloc=3D1*2097152
[    0.000000] pcpu-alloc: [0] 0=20
[    0.000000] KVM setup async PF for cpu 0
[    0.000000] kvm-stealtime: cpu 0, msr fa0d340
[    0.000000] Built 1 zonelists in Node order, mobility grouping on.  Tota=
l pages: 64361
[    0.000000] Policy zone: DMA32
[    0.000000] Kernel command line: hung_task_panic=3D1 earlyprintk=3DttyS0=
,115200 rd.udev.log-priority=3Derr systemd.log_target=3Djournal systemd.log=
_level=3Dwarning debug apic=3Ddebug sysrq_always_enabled rcupdate.rcu_cpu_s=
tall_timeout=3D100 panic=3D-1 softlockup_panic=3D1 nmi_watchdog=3Dpanic oop=
s=3Dpanic load_ramdisk=3D2 prompt_ramdisk=3D0 console=3DttyS0,115200 consol=
e=3Dtty0 vga=3Dnormal  root=3D/dev/ram0 rw link=3D/kbuild-tests/run-queue/k=
vm/x86_64-randconfig-n0-03310731/linux-devel:devel-hourly-2015033101:ccd57b=
1bd32460d27bbb9c599e795628a3c66983:bisect-linux-2/.vmlinuz-ccd57b1bd32460d2=
7bbb9c599e795628a3c66983-20150331112724-8-ivb41 branch=3Dlinux-devel/devel-=
hourly-2015033101 BOOT_IMAGE=3D/kernel/x86_64-randconfig-n0-03310731/ccd57b=
1bd32460d27bbb9c599e795628a3c66983/vmlinuz-4.0.0-rc4-01225-gccd57b1 drbd.mi=
nor_count=3D8
[    0.000000] sysrq: sysrq always enabled.
[    0.000000] PID hash table entries: 1024 (order: 1, 8192 bytes)
[    0.000000] xsave: enabled xstate_bv 0x7, cntxt size 0x340 using standar=
d form
[    0.000000] Memory: 216672K/261624K available (8432K kernel code, 2087K =
rwdata, 3836K rodata, 3924K init, 14600K bss, 44952K reserved, 0K cma-reser=
ved)
[    0.000000] SLUB: HWalign=3D64, Order=3D0-3, MinObjects=3D0, CPUs=3D1, N=
odes=3D1
[    0.000000] Hierarchical RCU implementation.
[    0.000000] RCU: Adjusting geometry for rcu_fanout_leaf=3D16, nr_cpu_ids=
=3D1
[    0.000000] Running RCU self tests
[    0.000000] NR_IRQS:524544 nr_irqs:256 16
[    0.000000] Console: colour VGA+ 80x25
[    0.000000] console [tty0] enabled
[    0.000000] bootconsole [earlyser0] disabled
[    0.000000] console [ttyS0] enabled
[    0.000000] Lock dependency validator: Copyright (c) 2006 Red Hat, Inc.,=
 Ingo Molnar
[    0.000000] ... MAX_LOCKDEP_SUBCLASSES:  8
[    0.000000] ... MAX_LOCK_DEPTH:          48
[    0.000000] ... MAX_LOCKDEP_KEYS:        8191
[    0.000000] ... CLASSHASH_SIZE:          4096
[    0.000000] ... MAX_LOCKDEP_ENTRIES:     32768
[    0.000000] ... MAX_LOCKDEP_CHAINS:      65536
[    0.000000] ... CHAINHASH_SIZE:          32768
[    0.000000]  memory used by lock dependency info: 8671 kB
[    0.000000]  per task-struct memory footprint: 2688 bytes
[    0.000000] hpet clockevent registered
[    0.000000] tsc: Detected 2693.506 MHz processor
[    0.003000] Calibrating delay loop (skipped) preset value.. 5387.01 Bogo=
MIPS (lpj=3D2693506)
[    0.004005] pid_max: default: 32768 minimum: 301
[    0.005015] ACPI: Core revision 20150204
[    0.008895] ACPI: All ACPI Tables successfully acquired
[    0.010092] Security Framework initialized
[    0.011012] AppArmor: AppArmor initialized
[    0.012069] Dentry cache hash table entries: 32768 (order: 6, 262144 byt=
es)
[    0.013092] Inode-cache hash table entries: 16384 (order: 5, 131072 byte=
s)
[    0.014045] Mount-cache hash table entries: 512 (order: 0, 4096 bytes)
[    0.015011] Mountpoint-cache hash table entries: 512 (order: 0, 4096 byt=
es)
[    0.017661] Initializing cgroup subsys freezer
[    0.018026] Initializing cgroup subsys hugetlb
[    0.019085] mce: CPU supports 10 MCE banks
[    0.020040] Last level iTLB entries: 4KB 0, 2MB 0, 4MB 0
[    0.021005] Last level dTLB entries: 4KB 0, 2MB 0, 4MB 0, 1GB 0
[    0.033724] Freeing SMP alternatives memory: 28K (ffffffff823e0000 - fff=
fffff823e7000)
[    0.038282] Getting VERSION: 1050014
[    0.039009] Getting VERSION: 1050014
[    0.040006] Getting ID: 0
[    0.040736] Getting ID: ff000000
[    0.041010] Getting LVT0: 8700
[    0.042005] Getting LVT1: 8400
[    0.043023] enabled ExtINT on CPU#0
[    0.044673] ENABLING IO-APIC IRQs
[    0.045021] init IO_APIC IRQs
[    0.046005]  apic 0 pin 0 not connected
[    0.047048] IOAPIC[0]: Set routing entry (0-1 -> 0x31 -> IRQ 1 Mode:0 Ac=
tive:0 Dest:1)
[    0.048039] IOAPIC[0]: Set routing entry (0-2 -> 0x30 -> IRQ 0 Mode:0 Ac=
tive:0 Dest:1)
[    0.049024] IOAPIC[0]: Set routing entry (0-2 -> 0x30 -> IRQ 0 Mode:0 Ac=
tive:0 Dest:1)
[    0.050024] IOAPIC[0]: Set routing entry (0-3 -> 0x33 -> IRQ 3 Mode:0 Ac=
tive:0 Dest:1)
[    0.051024] IOAPIC[0]: Set routing entry (0-4 -> 0x34 -> IRQ 4 Mode:0 Ac=
tive:0 Dest:1)
[    0.052023] IOAPIC[0]: Set routing entry (0-5 -> 0x35 -> IRQ 5 Mode:1 Ac=
tive:0 Dest:1)
[    0.053024] IOAPIC[0]: Set routing entry (0-6 -> 0x36 -> IRQ 6 Mode:0 Ac=
tive:0 Dest:1)
[    0.054024] IOAPIC[0]: Set routing entry (0-7 -> 0x37 -> IRQ 7 Mode:0 Ac=
tive:0 Dest:1)
[    0.055024] IOAPIC[0]: Set routing entry (0-8 -> 0x38 -> IRQ 8 Mode:0 Ac=
tive:0 Dest:1)
[    0.056024] IOAPIC[0]: Set routing entry (0-9 -> 0x39 -> IRQ 9 Mode:1 Ac=
tive:0 Dest:1)
[    0.057023] IOAPIC[0]: Set routing entry (0-10 -> 0x3a -> IRQ 10 Mode:1 =
Active:0 Dest:1)
[    0.058023] IOAPIC[0]: Set routing entry (0-11 -> 0x3b -> IRQ 11 Mode:1 =
Active:0 Dest:1)
[    0.059023] IOAPIC[0]: Set routing entry (0-12 -> 0x3c -> IRQ 12 Mode:0 =
Active:0 Dest:1)
[    0.060023] IOAPIC[0]: Set routing entry (0-13 -> 0x3d -> IRQ 13 Mode:0 =
Active:0 Dest:1)
[    0.061024] IOAPIC[0]: Set routing entry (0-14 -> 0x3e -> IRQ 14 Mode:0 =
Active:0 Dest:1)
[    0.062023] IOAPIC[0]: Set routing entry (0-15 -> 0x3f -> IRQ 15 Mode:0 =
Active:0 Dest:1)
[    0.063019]  apic 0 pin 16 not connected
[    0.064004]  apic 0 pin 17 not connected
[    0.065004]  apic 0 pin 18 not connected
[    0.066003]  apic 0 pin 19 not connected
[    0.067003]  apic 0 pin 20 not connected
[    0.068003]  apic 0 pin 21 not connected
[    0.069003]  apic 0 pin 22 not connected
[    0.070004]  apic 0 pin 23 not connected
[    0.071142] ..TIMER: vector=3D0x30 apic1=3D0 pin1=3D2 apic2=3D-1 pin2=3D=
-1
[    0.072029] TSC deadline timer enabled
[    0.072882] smpboot: CPU0: Intel Core Processor (Haswell) (fam: 06, mode=
l: 3c, stepping: 01)
[    0.073034] Performance Events: unsupported p6 CPU model 60 no PMU drive=
r, software events only.
[    0.074739] x86: Booted up 1 node, 1 CPUs
[    0.075012] ----------------
[    0.075766] | NMI testsuite:
[    0.076005] --------------------
[    0.076784]   remote IPI:  ok  |
[    0.077596]    local IPI:  ok  |
[    0.078471] --------------------
[    0.079005] Good, all   2 testcases passed! |
[    0.079902] ---------------------------------
[    0.080005] smpboot: Total of 1 processors activated (5387.01 BogoMIPS)
[    0.081313] NMI watchdog: disabled (cpu0): hardware events not enabled
[    0.082795] devtmpfs: initialized
[    0.084225] prandom: seed boundary self test passed
[    0.085414] prandom: 100 self tests passed
[    0.086588] regulator-dummy: no parameters
[    0.087516] NET: Registered protocol family 16
[    0.088647] cpuidle: using governor ladder
[    0.089010] cpuidle: using governor menu
[    0.090092] ACPI: bus type PCI registered
[    0.091027] PCI: Using configuration type 1 for base access
[    0.098272] ACPI: Added _OSI(Module Device)
[    0.099007] ACPI: Added _OSI(Processor Device)
[    0.099909] ACPI: Added _OSI(3.0 _SCP Extensions)
[    0.100006] ACPI: Added _OSI(Processor Aggregator Device)
[    0.102892] IOAPIC[0]: Set routing entry (0-9 -> 0x39 -> IRQ 9 Mode:1 Ac=
tive:0 Dest:1)
[    0.106193] ACPI: Interpreter enabled
[    0.107040] ACPI: (supports S0 S4 S5)
[    0.107859] ACPI: Using IOAPIC for interrupt routing
[    0.108046] PCI: Using host bridge windows from ACPI; if necessary, use =
"pci=3Dnocrs" and report a bug
[    0.118675] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-ff])
[    0.119012] acpi PNP0A03:00: _OSC: OS supports [Segments]
[    0.120055] acpi PNP0A03:00: _OSC failed (AE_NOT_FOUND); disabling ASPM
[    0.121364] PCI host bridge to bus 0000:00
[    0.122009] pci_bus 0000:00: root bus resource [bus 00-ff]
[    0.123007] pci_bus 0000:00: root bus resource [io  0x0000-0x0cf7 window]
[    0.124006] pci_bus 0000:00: root bus resource [io  0x0d00-0xadff window]
[    0.125006] pci_bus 0000:00: root bus resource [io  0xae0f-0xaeff window]
[    0.126006] pci_bus 0000:00: root bus resource [io  0xaf20-0xafdf window]
[    0.127006] pci_bus 0000:00: root bus resource [io  0xafe4-0xffff window]
[    0.128006] pci_bus 0000:00: root bus resource [mem 0x000a0000-0x000bfff=
f window]
[    0.129006] pci_bus 0000:00: root bus resource [mem 0x10000000-0xfebffff=
f window]
[    0.130072] pci 0000:00:00.0: [8086:1237] type 00 class 0x060000
[    0.131646] pci 0000:00:01.0: [8086:7000] type 00 class 0x060100
[    0.132644] pci 0000:00:01.1: [8086:7010] type 00 class 0x010180
[    0.143009] pci 0000:00:01.1: reg 0x20: [io  0xc200-0xc20f]
[    0.148031] pci 0000:00:01.1: legacy IDE quirk: reg 0x10: [io  0x01f0-0x=
01f7]
[    0.149006] pci 0000:00:01.1: legacy IDE quirk: reg 0x14: [io  0x03f6]
[    0.150006] pci 0000:00:01.1: legacy IDE quirk: reg 0x18: [io  0x0170-0x=
0177]
[    0.151006] pci 0000:00:01.1: legacy IDE quirk: reg 0x1c: [io  0x0376]
[    0.152334] pci 0000:00:01.3: [8086:7113] type 00 class 0x068000
[    0.153350] pci 0000:00:01.3: quirk: [io  0x0600-0x063f] claimed by PIIX=
4 ACPI
[    0.154016] pci 0000:00:01.3: quirk: [io  0x0700-0x070f] claimed by PIIX=
4 SMB
[    0.155386] pci 0000:00:02.0: [1013:00b8] type 00 class 0x030000
[    0.158013] pci 0000:00:02.0: reg 0x10: [mem 0xfc000000-0xfdffffff pref]
[    0.161012] pci 0000:00:02.0: reg 0x14: [mem 0xfebf0000-0xfebf0fff]
[    0.172012] pci 0000:00:02.0: reg 0x30: [mem 0xfebe0000-0xfebeffff pref]
[    0.173363] pci 0000:00:03.0: [8086:100e] type 00 class 0x020000
[    0.176009] pci 0000:00:03.0: reg 0x10: [mem 0xfebc0000-0xfebdffff]
[    0.179009] pci 0000:00:03.0: reg 0x14: [io  0xc000-0xc03f]
[    0.190009] pci 0000:00:03.0: reg 0x30: [mem 0xfeb80000-0xfebbffff pref]
[    0.191381] pci 0000:00:04.0: [1af4:1001] type 00 class 0x010000
[    0.194009] pci 0000:00:04.0: reg 0x10: [io  0xc040-0xc07f]
[    0.197009] pci 0000:00:04.0: reg 0x14: [mem 0xfebf1000-0xfebf1fff]
[    0.208451] pci 0000:00:05.0: [1af4:1001] type 00 class 0x010000
[    0.211009] pci 0000:00:05.0: reg 0x10: [io  0xc080-0xc0bf]
[    0.214009] pci 0000:00:05.0: reg 0x14: [mem 0xfebf2000-0xfebf2fff]
[    0.225445] pci 0000:00:06.0: [1af4:1001] type 00 class 0x010000
[    0.228009] pci 0000:00:06.0: reg 0x10: [io  0xc0c0-0xc0ff]
[    0.231009] pci 0000:00:06.0: reg 0x14: [mem 0xfebf3000-0xfebf3fff]
[    0.242456] pci 0000:00:07.0: [1af4:1001] type 00 class 0x010000
[    0.245009] pci 0000:00:07.0: reg 0x10: [io  0xc100-0xc13f]
[    0.248009] pci 0000:00:07.0: reg 0x14: [mem 0xfebf4000-0xfebf4fff]
[    0.259445] pci 0000:00:08.0: [1af4:1001] type 00 class 0x010000
[    0.262009] pci 0000:00:08.0: reg 0x10: [io  0xc140-0xc17f]
[    0.265009] pci 0000:00:08.0: reg 0x14: [mem 0xfebf5000-0xfebf5fff]
[    0.276457] pci 0000:00:09.0: [1af4:1001] type 00 class 0x010000
[    0.279009] pci 0000:00:09.0: reg 0x10: [io  0xc180-0xc1bf]
[    0.282009] pci 0000:00:09.0: reg 0x14: [mem 0xfebf6000-0xfebf6fff]
[    0.293453] pci 0000:00:0a.0: [1af4:1001] type 00 class 0x010000
[    0.296009] pci 0000:00:0a.0: reg 0x10: [io  0xc1c0-0xc1ff]
[    0.299009] pci 0000:00:0a.0: reg 0x14: [mem 0xfebf7000-0xfebf7fff]
[    0.310430] pci 0000:00:0b.0: [8086:25ab] type 00 class 0x088000
[    0.313008] pci 0000:00:0b.0: reg 0x10: [mem 0xfebf8000-0xfebf800f]
[    0.327267] ACPI: PCI Interrupt Link [LNKA] (IRQs 5 *10 11)
[    0.328804] ACPI: PCI Interrupt Link [LNKB] (IRQs 5 *10 11)
[    0.329989] ACPI: PCI Interrupt Link [LNKC] (IRQs 5 10 *11)
[    0.330989] ACPI: PCI Interrupt Link [LNKD] (IRQs 5 10 *11)
[    0.331909] ACPI: PCI Interrupt Link [LNKS] (IRQs *9)
[    0.333202] ACPI: Enabled 16 GPEs in block 00 to 0F
[    0.334626] vgaarb: setting as boot device: PCI:0000:00:02.0
[    0.335000] vgaarb: device added: PCI:0000:00:02.0,decodes=3Dio+mem,owns=
=3Dio+mem,locks=3Dnone
[    0.335013] vgaarb: loaded
[    0.335728] vgaarb: bridge control possible 0000:00:02.0
[    0.336423] SCSI subsystem initialized
[    0.337112] libata version 3.00 loaded.
[    0.338123] pps_core: LinuxPPS API ver. 1 registered
[    0.339005] pps_core: Software ver. 5.3.6 - Copyright 2005-2007 Rodolfo =
Giometti <giometti@linux.it>
[    0.340019] PTP clock support registered
[    0.340970] EDAC MC: Ver: 3.0.0
[    0.341491] PCI: Using ACPI for IRQ routing
[    0.342006] PCI: pci_cache_line_size set to 64 bytes
[    0.343155] e820: reserve RAM buffer [mem 0x0009fc00-0x0009ffff]
[    0.344013] e820: reserve RAM buffer [mem 0x0ffe0000-0x0fffffff]
[    0.345625] NET: Registered protocol family 23
[    0.346052] NetLabel: Initializing
[    0.346851] NetLabel:  domain hash size =3D 128
[    0.347005] NetLabel:  protocols =3D UNLABELED CIPSOv4
[    0.348008] NetLabel:  unlabeled traffic allowed by default
[    0.349204] Switched to clocksource kvm-clock
[    0.350299] Warning: could not register annotated branches stats
[    0.365282] FS-Cache: Loaded
[    0.366319] AppArmor: AppArmor Filesystem Enabled
[    0.367318] pnp: PnP ACPI init
[    0.368193] IOAPIC[0]: Set routing entry (0-8 -> 0x38 -> IRQ 8 Mode:0 Ac=
tive:0 Dest:1)
[    0.369950] pnp 00:00: Plug and Play ACPI device, IDs PNP0b00 (active)
[    0.371133] IOAPIC[0]: Set routing entry (0-1 -> 0x31 -> IRQ 1 Mode:0 Ac=
tive:0 Dest:1)
[    0.372873] pnp 00:01: Plug and Play ACPI device, IDs PNP0303 (active)
[    0.374055] IOAPIC[0]: Set routing entry (0-12 -> 0x3c -> IRQ 12 Mode:0 =
Active:0 Dest:1)
[    0.375805] pnp 00:02: Plug and Play ACPI device, IDs PNP0f13 (active)
[    0.376993] IOAPIC[0]: Set routing entry (0-6 -> 0x36 -> IRQ 6 Mode:0 Ac=
tive:0 Dest:1)
[    0.378656] pnp 00:03: [dma 2]
[    0.379495] pnp 00:03: Plug and Play ACPI device, IDs PNP0700 (active)
[    0.380698] IOAPIC[0]: Set routing entry (0-7 -> 0x37 -> IRQ 7 Mode:0 Ac=
tive:0 Dest:1)
[    0.382415] pnp 00:04: Plug and Play ACPI device, IDs PNP0400 (active)
[    0.383620] IOAPIC[0]: Set routing entry (0-4 -> 0x34 -> IRQ 4 Mode:0 Ac=
tive:0 Dest:1)
[    0.385337] pnp 00:05: Plug and Play ACPI device, IDs PNP0501 (active)
[    0.386954] pnp: PnP ACPI: found 6 devices
[    0.398883] pci_bus 0000:00: resource 4 [io  0x0000-0x0cf7 window]
[    0.399949] pci_bus 0000:00: resource 5 [io  0x0d00-0xadff window]
[    0.401008] pci_bus 0000:00: resource 6 [io  0xae0f-0xaeff window]
[    0.402067] pci_bus 0000:00: resource 7 [io  0xaf20-0xafdf window]
[    0.403123] pci_bus 0000:00: resource 8 [io  0xafe4-0xffff window]
[    0.404180] pci_bus 0000:00: resource 9 [mem 0x000a0000-0x000bffff windo=
w]
[    0.405308] pci_bus 0000:00: resource 10 [mem 0x10000000-0xfebfffff wind=
ow]
[    0.406798] NET: Registered protocol family 2
[    0.408052] TCP established hash table entries: 2048 (order: 2, 16384 by=
tes)
[    0.409483] TCP bind hash table entries: 2048 (order: 5, 163840 bytes)
[    0.410702] TCP: Hash tables configured (established 2048 bind 2048)
[    0.411826] UDP hash table entries: 256 (order: 3, 49152 bytes)
[    0.412889] UDP-Lite hash table entries: 256 (order: 3, 49152 bytes)
[    0.414135] NET: Registered protocol family 1
[    0.415039] pci 0000:00:00.0: Limiting direct PCI/PCI transfers
[    0.416081] pci 0000:00:01.0: PIIX3: Enabling Passive Release
[    0.417109] pci 0000:00:01.0: Activating ISA DMA hang workarounds
[    0.418184] pci 0000:00:02.0: Video device with shadowed ROM
[    0.419253] PCI: CLS 0 bytes, default 64
[    0.420300] Unpacking initramfs...
[    0.487054] Freeing initrd memory: 3112K (ffff88000fcce000 - ffff88000ff=
d8000)
[    0.488974] Machine check injector initialized
[    0.490781] AVX version of gcm_enc/dec engaged.
[    0.491721] AES CTR mode by8 optimization enabled
[    0.493690] sha512_ssse3: Using AVX optimized SHA-512 implementation
[    0.495887] AVX2 instructions are not detected.
[    0.496877] spin_lock-torture:--- Start of test [debug]: nwriters_stress=
=3D2 nreaders_stress=3D0 stat_interval=3D60 verbose=3D1 shuffle_interval=3D=
3 stutter=3D5 shutdown_secs=3D0 onoff_interval=3D0 onoff_holdoff=3D0
[    0.500048] spin_lock-torture: Creating torture_shuffle task
[    0.501247] spin_lock-torture: Creating torture_stutter task
[    0.502372] spin_lock-torture: torture_shuffle task started
[    0.503429] spin_lock-torture: Creating lock_torture_writer task
[    0.504562] spin_lock-torture: torture_stutter task started
[    0.505676] spin_lock-torture: Creating lock_torture_writer task
[    0.506795] spin_lock-torture: lock_torture_writer task started
[    0.507913] spin_lock-torture: Creating lock_torture_stats task
[    0.509042] spin_lock-torture: lock_torture_writer task started
[    0.511879] futex hash table entries: 256 (order: 3, 32768 bytes)
[    0.513030] Initialise system trusted keyring
[    0.514053] audit: initializing netlink subsys (disabled)
[    0.515147] audit: type=3D2000 audit(1427772975.975:1): initialized
[    0.516718] spin_lock-torture: lock_torture_stats task started
[    0.517901] HugeTLB registered 2 MB page size, pre-allocated 0 pages
[    0.532299] zpool: loaded
[    0.533697] VFS: Disk quotas dquot_6.5.2
[    0.534791] VFS: Dquot-cache hash table entries: 512 (order 0, 4096 byte=
s)
[    0.536656] ntfs: driver 2.1.31 [Flags: R/O].
[    0.537965] fuse init (API version 7.23)
[    0.539881] JFS: nTxBlock =3D 1717, nTxLock =3D 13738
[    0.545450] Key type asymmetric registered
[    0.546370] Asymmetric key parser 'x509' registered
[    0.547560] Block layer SCSI generic (bsg) driver version 0.4 loaded (ma=
jor 249)
[    0.549166] io scheduler noop registered
[    0.550038] io scheduler deadline registered (default)
[    0.551144] test_firmware: interface ready
[    0.552050] Running resizable hashtable tests...
[    0.552992]   Adding 2048 keys
[    0.553792]=20
[    0.554400] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
[    0.555285] [ INFO: suspicious RCU usage. ]
[    0.556176] 4.0.0-rc4-01225-gccd57b1 #171 Not tainted
[    0.557156] -------------------------------
[    0.558044] lib/rhashtable.c:400 suspicious rcu_dereference_check() usag=
e!
[    0.559741]=20
[    0.559741] other info that might help us debug this:
[    0.559741]=20
[    0.561764]=20
[    0.561764] rcu_scheduler_active =3D 1, debug_locks =3D 0
[    0.563254] no locks held by swapper/0/1.
[    0.564124]=20
[    0.564124] stack backtrace:
[    0.565394] CPU: 0 PID: 1 Comm: swapper/0 Not tainted 4.0.0-rc4-01225-gc=
cd57b1 #171
[    0.567017] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS =
1.7.5-20140531_083030-gandalf 04/01/2014
[    0.568898]  0000000000000001 ffff88000f563d38 ffffffff8182e695 00000000=
00000011
[    0.570775]  ffff88000f558000 ffff88000f563d68 ffffffff810ffce7 ffffffff=
831fc340
[    0.572637]  ffff88000e874d10 000000000000000d ffff88000e199e40 ffff8800=
0f563da8
[    0.574519] Call Trace:
[    0.575219]  [<ffffffff8182e695>] dump_stack+0x4c/0x65
[    0.576210]  [<ffffffff810ffce7>] lockdep_rcu_suspicious+0xe7/0x120
[    0.577314]  [<ffffffff8142d0fe>] rhashtable_insert_rehash+0x18e/0x1d0
[    0.578443]  [<ffffffff8221814c>] test_rht_init+0x38f/0x12bd
[    0.579483]  [<ffffffff810002c0>] ? do_one_initcall+0x80/0x200
[    0.580542]  [<ffffffff82217dbd>] ? test_firmware_init+0x79/0x79
[    0.581615]  [<ffffffff810002d0>] do_one_initcall+0x90/0x200
[    0.582651]  [<ffffffff821e2212>] kernel_init_freeable+0x22d/0x2b5
[    0.583743]  [<ffffffff81829160>] ? rest_init+0x140/0x140
[    0.584755]  [<ffffffff8182916e>] kernel_init+0xe/0xf0
[    0.585743]  [<ffffffff81839318>] ret_from_fork+0x58/0x90
[    0.586756]  [<ffffffff81829160>] ? rest_init+0x140/0x140
[    0.587778] ------------[ cut here ]------------
[    0.588715] WARNING: CPU: 0 PID: 1 at lib/rhashtable.c:408 rhashtable_in=
sert_rehash+0x95/0x1d0()
[    0.590608] Modules linked in:
[    0.591439] CPU: 0 PID: 1 Comm: swapper/0 Not tainted 4.0.0-rc4-01225-gc=
cd57b1 #171
[    0.593058] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS =
1.7.5-20140531_083030-gandalf 04/01/2014
[    0.594929]  ffffffff81d08b58 ffff88000f563d18 ffffffff8182e695 00000000=
00000000
[    0.596809]  0000000000000000 ffff88000f563d58 ffffffff810af7fa 00000000=
fffffe00
[    0.598682]  ffffffff831fc340 0000000000000010 ffff88000e199840 00000000=
00000001
[    0.600558] Call Trace:
[    0.601259]  [<ffffffff8182e695>] dump_stack+0x4c/0x65
[    0.602238]  [<ffffffff810af7fa>] warn_slowpath_common+0x8a/0xc0
[    0.603310]  [<ffffffff810af8ea>] warn_slowpath_null+0x1a/0x20
[    0.604366]  [<ffffffff8142d005>] rhashtable_insert_rehash+0x95/0x1d0
[    0.605495]  [<ffffffff8221814c>] test_rht_init+0x38f/0x12bd
[    0.606536]  [<ffffffff810002c0>] ? do_one_initcall+0x80/0x200
[    0.607589]  [<ffffffff82217dbd>] ? test_firmware_init+0x79/0x79
[    0.608664]  [<ffffffff810002d0>] do_one_initcall+0x90/0x200
[    0.609704]  [<ffffffff821e2212>] kernel_init_freeable+0x22d/0x2b5
[    0.610797]  [<ffffffff81829160>] ? rest_init+0x140/0x140
[    0.611808]  [<ffffffff8182916e>] kernel_init+0xe/0xf0
[    0.612792]  [<ffffffff81839318>] ret_from_fork+0x58/0x90
[    0.613801]  [<ffffffff81829160>] ? rest_init+0x140/0x140
[    0.614808] ---[ end trace b5aa4dbce5f556f0 ]---
[    0.615763] glob: 64 self-tests passed, 0 failed
[    0.616881] ipmi message handler version 39.2
[    0.617808] IPMI System Interface driver.
[    0.618730] ipmi_si: Adding default-specified kcs state machine
[    0.619875] ipmi_si: Trying default-specified kcs state machine at i/o a=
ddress 0xca2, slave address 0x0, irq 0
[    0.621750] ipmi_si: Interface detection failed
[    0.622670] ipmi_si: Adding default-specified smic state machine
[    0.623812] ipmi_si: Trying default-specified smic state machine at i/o =
address 0xca9, slave address 0x0, irq 0
[    0.625687] ipmi_si: Interface detection failed
[    0.626608] ipmi_si: Adding default-specified bt state machine
[    0.637435] ipmi_si: Trying default-specified bt state machine at i/o ad=
dress 0xe4, slave address 0x0, irq 0
[    0.639718] ipmi_si: Interface detection failed
[    0.640656] ipmi_si: Unable to find any System Interface(s)
[    0.641662] IPMI SSIF Interface driver
[    0.642504] IPMI Watchdog: driver initialized
[    0.643374] Copyright (C) 2004 MontaVista Software - IPMI Powerdown via =
sys_reboot.
[    0.645080] input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/inpu=
t/input0
[    0.646635] ACPI: Power Button [PWRF]
[    0.667563] r3964: Philips r3964 Driver $Revision: 1.10 $
[    0.668557] Serial: 8250/16550 driver, 4 ports, IRQ sharing enabled
[    0.695142] 00:05: ttyS0 at I/O 0x3f8 (irq =3D 4, base_baud =3D 115200) =
is a 16550A
[    0.697275] Non-volatile memory driver v1.3
[    0.698297] telclk_interrupt =3D 0xf non-mcpbl0010 hw.
[    0.699273] Hangcheck: starting hangcheck timer 0.9.1 (tick is 180 secon=
ds, margin is 60 seconds).
[    0.701315] Loading iSCSI transport class v2.0-870.
[    0.702407] iscsi: registered transport (tcp)
[    0.703356] st: Version 20101219, fixed bufsize 32768, s/g segs 256
[    0.704494] osst :I: Tape driver with OnStream support version 0.99.4
[    0.704494] osst :I: $Id: osst.c,v 1.73 2005/01/01 21:13:34 wriede Exp $
[    0.706668] SCSI Media Changer driver v0.25=20
[    0.707573] osd: LOADED open-osd 0.2.1
[    0.708613] eql: Equalizer2002: Simon Janes (simon@ncm.com) and David S.=
 Miller (davem@redhat.com)
[    0.710549] ipddp.c:v0.01 8/28/97 Bradford W. Johnson <johns393@maroon.t=
c.umn.edu>
[    0.712239] ipddp0: Appletalk-IP Decap. mode by Jay Schulist <jschlst@sa=
mba.org>
[    0.714102] i8042: PNP: PS/2 Controller [PNP0303:KBD,PNP0f13:MOU] at 0x6=
0,0x64 irq 1,12
[    0.716325] serio: i8042 KBD port at 0x60,0x64 irq 1
[    0.717263] serio: i8042 AUX port at 0x60,0x64 irq 12
[    0.758026] mk712: device not present
[    0.758907] rtc_cmos 00:00: RTC can wake from S4
[    0.759945] rtc (null): alarm rollover: day
[    0.761150] input: AT Translated Set 2 keyboard as /devices/platform/i80=
42/serio0/input/input1
[    0.763045] rtc rtc0: rtc_cmos: dev (253:0)
[    0.763905] rtc_cmos 00:00: rtc core: registered rtc_cmos as rtc0
[    0.765092] rtc_cmos 00:00: alarms up to one day, 114 bytes nvram, hpet =
irqs
[    0.766491] rtc (null): alarm rollover: day
[    0.767354] rtc (null): invalid alarm value: 1900-2-1 2022213768:1073741=
856:0
[    0.768565] rtc rtc1: test: dev (253:1)
[    0.769389] rtc-test rtc-test.0: rtc core: registered test as rtc1
[    0.770491] rtc (null): alarm rollover: day
[    0.771356] rtc (null): invalid alarm value: 1900-2-1 2022213768:1073741=
856:0
[    0.772559] rtc rtc2: test: dev (253:2)
[    0.773378] rtc-test rtc-test.1: rtc core: registered test as rtc2
[    0.774522] pps_ldisc: PPS line discipline registered
[    0.775472] Driver for 1-wire Dallas network protocol.
[    0.776533] ib700wdt: WDT driver for IB700 single board computer initial=
ising
[    0.777827] sc1200wdt: build 20020303
[    0.778648] sc1200wdt: io parameter must be specified
[    0.779607] smsc37b787_wdt: SMsC 37B787 watchdog component driver 1.1 in=
itialising...
[    0.782282] smsc37b787_wdt: Unable to register miscdev on minor 130
[    0.783404] watchdog: Software Watchdog: cannot register miscdev on mino=
r=3D130 (err=3D-16).
[    0.785015] watchdog: Software Watchdog: a legacy watchdog module is pro=
bably present.
[    0.786659] softdog: Software Watchdog Timer: 0.08 initialized. soft_nob=
oot=3D0 soft_margin=3D60 sec soft_panic=3D0 (nowayout=3D1)
[    0.788564] md: linear personality registered for level -1
[    0.789554] md: raid10 personality registered for level 10
[    0.790714] hidraw: raw HID events driver (C) Jiri Kosina
[    0.792031] pktgen: Packet Generator for packet performance testing. Ver=
sion: 2.74
[    0.793637] drop_monitor: Initializing network drop monitor service
[    0.794730] Netfilter messages via NETLINK v0.30.
[    0.795685] gre: GRE over IPv4 demultiplexor driver
[    0.796648] geneve: Geneve driver
[    0.797426] NET: Registered protocol family 15
[    0.798319] NET: Registered protocol family 5
[    0.799315] NET: Registered protocol family 33
[    0.800203] Key type rxrpc registered
[    0.800999] Key type rxrpc_s registered
[    0.802064] RxRPC: Registered security type 2 'rxkad'
[    0.803018] NET4: DECnet for Linux: V.2.5.68s (C) 1995-2003 Linux DECnet=
 Project Team
[    0.804720] DECnet: Routing cache hash table of 128 buckets, 10Kbytes
[    0.805810] NET: Registered protocol family 12
[    0.806751] 8021q: 802.1Q VLAN Support v1.8
[    0.808396] DCCP: Activated CCID 2 (TCP-like)
[    0.809353] DCCP: Activated CCID 3 (TCP-Friendly Rate Control)
[    0.810632] Key type dns_resolver registered
[    0.811526] Key type ceph registered
[    0.812519] libceph: loaded (mon/osd proto 15/24)
[    0.813834] ... APIC ID:      00000000 (0)
[    0.814494] ... APIC VERSION: 01050014
[    0.814494] 000000000000000000000000000000000000000000000000000000000000=
0000
[    0.814494] 000000000e20000000000000000000000000000000000000000000000000=
0000
[    0.814494] 000000000000000000000000000000000000000000000000000000000000=
8000
[    0.814494]=20
[    0.821204] number of MP IRQ sources: 15.
[    0.822064] number of IO-APIC #0 registers: 24.
[    0.822964] testing the IO APIC.......................
[    0.823954] IO APIC #0......
[    0.824697] .... register #00: 00000000
[    0.825519] .......    : physical APIC id: 00
[    0.826381] .......    : Delivery Type: 0
[    0.827244] .......    : LTS          : 0
[    0.828119] .... register #01: 00170011
[    0.828945] .......     : max redirection entries: 17
[    0.829873] .......     : PRQ implemented: 0
[    0.830775] .......     : IO APIC version: 11
[    0.831643] .... register #02: 00000000
[    0.832463] .......     : arbitration: 00
[    0.833338] .... IRQ redirection table:
[    0.834170] 1    0    0   0   0    0    0    00
[    0.835066] 0    0    0   0   0    1    1    31
[    0.835971] 0    0    0   0   0    1    1    30
[    0.836883] 0    0    0   0   0    1    1    33
[    0.837823] 1    0    0   0   0    1    1    34
[    0.838759] 1    1    0   0   0    1    1    35
[    0.839694] 0    0    0   0   0    1    1    36
[    0.840590] 0    0    0   0   0    1    1    37
[    0.841472] 0    0    0   0   0    1    1    38
[    0.842399] 0    1    0   0   0    1    1    39
[    0.843334] 1    1    0   0   0    1    1    3A
[    0.844227] 1    1    0   0   0    1    1    3B
[    0.845146] 0    0    0   0   0    1    1    3C
[    0.846051] 0    0    0   0   0    1    1    3D
[    0.846952] 0    0    0   0   0    1    1    3E
[    0.847867] 0    0    0   0   0    1    1    3F
[    0.848802] 1    0    0   0   0    0    0    00
[    0.849696] 1    0    0   0   0    0    0    00
[    0.850593] 1    0    0   0   0    0    0    00
[    0.851527] 1    0    0   0   0    0    0    00
[    0.852412] 1    0    0   0   0    0    0    00
[    0.853343] 1    0    0   0   0    0    0    00
[    0.854278] 1    0    0   0   0    0    0    00
[    0.855171] 1    0    0   0   0    0    0    00
[    0.856060] IRQ to pin mappings:
[    0.856805] IRQ0 -> 0:2
[    0.857655] IRQ1 -> 0:1
[    0.858501] IRQ3 -> 0:3
[    0.859301] IRQ4 -> 0:4
[    0.860136] IRQ5 -> 0:5
[    0.860958] IRQ6 -> 0:6
[    0.861770] IRQ7 -> 0:7
[    0.862581] IRQ8 -> 0:8
[    0.863422] IRQ9 -> 0:9
[    0.864235] IRQ10 -> 0:10
[    0.865065] IRQ11 -> 0:11
[    0.865883] IRQ12 -> 0:12
[    0.866754] IRQ13 -> 0:13
[    0.867622] IRQ14 -> 0:14
[    0.868481] IRQ15 -> 0:15
[    0.869343] .................................... done.
[    0.870516] Loading compiled-in X.509 certificates
[    0.872203] Loaded X.509 cert 'Magrathea: Glacier signing key: 8d76ac007=
e6e2cd6923616aece7add13d183b0a6'
[    0.874016] Running ring buffer tests...
[    1.492044] tsc: Refined TSC clocksource calibration: 2693.500 MHz
[   10.875056] finished
[   10.876087] CPU 0:
[   10.876732]               events:    5000
[   10.877574]        dropped bytes:    0
[   10.878381]        alloced bytes:    389452
[   10.879235]        written bytes:    382058
[   10.880131]        biggest event:    26
[   10.880947]       smallest event:    0
[   10.883073]          read events:   5000
[   10.883941]          lost events:   0
[   10.884738]         total events:   5000
[   10.885567]   recorded len bytes:   389452
[   10.886413]  recorded size bytes:   382058
[   10.887257] Ring buffer PASSED!
[   10.888196] kAFS: Red Hat AFS client v0.1 registering.
[   10.889197] FS-Cache: Netfs 'afs' registered for caching
[   10.891055] AppArmor: AppArmor sha1 policy hashing enabled
[   10.892632] rtc_cmos 00:00: setting system clock to 2015-03-31 11:36:26 =
UTC (1427801786)
[   10.894297] PM: Hibernation image not present or could not be loaded
--R3G7APHDIzY6R/pk--
