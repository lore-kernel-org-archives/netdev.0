From: Fengguang Wu <fengguang.wu@intel.com>
Subject: [rhashtable] [ INFO: possible recursive locking detected ]
Date: Thu, 12 Mar 2015 11:29:24 +0800
Message-ID: <20150312032924.GA12390@wfg-t540p.sh.intel.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="YiEDa0DAkWCtVeE4"
Cc: fengguang.wu@intel.com, LKP <lkp@01.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--YiEDa0DAkWCtVeE4
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Greetings,

0day kernel testing robot got the below dmesg and the first bad commit is

git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next.git master

commit aa34a6cb0478842452bac58edb50d3ef9e178c92
Author:     Herbert Xu <herbert@gondor.apana.org.au>
AuthorDate: Wed Mar 11 09:43:48 2015 +1100
Commit:     David S. Miller <davem@davemloft.net>
CommitDate: Wed Mar 11 16:36:21 2015 -0400

    rhashtable: Add arbitrary rehash function
    
    This patch adds a rehash function that supports the use of any
    hash function for the new table.  This is needed to support changing
    the random seed value during the lifetime of the hash table.
    
    However for now the random seed value is still constant and the
    rehash function is simply used to replace the existing expand/shrink
    functions.
    
    [ ASSERT_BUCKET_LOCK() and thus debug_dump_table() +
      debug_dump_buckets() are not longer used, so delete them
      entirely. -DaveM ]
    
    Signed-off-by: Herbert Xu <herbert.xu@redhat.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

+------------------------------------------+------------+------------+------------+
|                                          | 988dfbd795 | aa34a6cb04 | 61f0d861fc |
+------------------------------------------+------------+------------+------------+
| boot_successes                           | 60         | 0          | 0          |
| boot_failures                            | 0          | 20         | 14         |
| INFO:possible_recursive_locking_detected | 0          | 20         | 14         |
| backtrace:test_rht_init                  | 0          | 20         | 14         |
| backtrace:rhashtable_expand              | 0          | 20         | 14         |
| backtrace:kernel_init_freeable           | 0          | 20         | 14         |
+------------------------------------------+------------+------------+------------+

[    2.307176] 
[    2.307922] =============================================
[    2.307922] =============================================
[    2.310446] [ INFO: possible recursive locking detected ]
[    2.310446] [ INFO: possible recursive locking detected ]
[    2.311089] 4.0.0-rc3-00505-gaa34a6c #7 Not tainted
[    2.311089] 4.0.0-rc3-00505-gaa34a6c #7 Not tainted
[    2.311089] ---------------------------------------------
[    2.311089] ---------------------------------------------
[    2.311089] swapper/1 is trying to acquire lock:
[    2.311089] swapper/1 is trying to acquire lock:
[    2.311089]  (
[    2.311089]  (&(&tbl->locks[i])->rlock&(&tbl->locks[i])->rlock){+.....}){+.....}, at: , at: [<ffffffff813ef48d>] rhashtable_rehash+0xfd/0x1a0
[<ffffffff813ef48d>] rhashtable_rehash+0xfd/0x1a0
[    2.311089] 
[    2.311089] but task is already holding lock:
[    2.311089] 
[    2.311089] but task is already holding lock:
[    2.311089]  (
[    2.311089]  (&(&tbl->locks[i])->rlock&(&tbl->locks[i])->rlock){+.....}){+.....}, at: , at: [<ffffffff813ef401>] rhashtable_rehash+0x71/0x1a0
[<ffffffff813ef401>] rhashtable_rehash+0x71/0x1a0
[    2.311089] 
[    2.311089] other info that might help us debug this:
[    2.311089] 
[    2.311089] other info that might help us debug this:
[    2.311089]  Possible unsafe locking scenario:
[    2.311089] 
[    2.311089]  Possible unsafe locking scenario:
[    2.311089] 
[    2.311089]        CPU0
[    2.311089]        CPU0
[    2.311089]        ----
[    2.311089]        ----
[    2.311089]   lock(
[    2.311089]   lock(&(&tbl->locks[i])->rlock&(&tbl->locks[i])->rlock);
);
[    2.311089]   lock(
[    2.311089]   lock(&(&tbl->locks[i])->rlock&(&tbl->locks[i])->rlock);
);
[    2.311089] 
[    2.311089]  *** DEADLOCK ***
[    2.311089] 
[    2.311089] 
[    2.311089]  *** DEADLOCK ***
[    2.311089] 
[    2.311089]  May be due to missing lock nesting notation
[    2.311089] 
[    2.311089]  May be due to missing lock nesting notation
[    2.311089] 
[    2.311089] 2 locks held by swapper/1:
[    2.311089] 2 locks held by swapper/1:
[    2.311089]  #0: 
[    2.311089]  #0:  ( (&ht->mutex&ht->mutex){+.+.+.}){+.+.+.}, at: , at: [<ffffffff81eb1d2e>] test_rht_init+0x15c/0x37d
[<ffffffff81eb1d2e>] test_rht_init+0x15c/0x37d
[    2.311089]  #1: 
[    2.311089]  #1:  ( (&(&tbl->locks[i])->rlock&(&tbl->locks[i])->rlock){+.....}){+.....}, at: , at: [<ffffffff813ef401>] rhashtable_rehash+0x71/0x1a0
[<ffffffff813ef401>] rhashtable_rehash+0x71/0x1a0
[    2.311089] 
[    2.311089] stack backtrace:
[    2.311089] 
[    2.311089] stack backtrace:
[    2.311089] CPU: 0 PID: 1 Comm: swapper Not tainted 4.0.0-rc3-00505-gaa34a6c #7
[    2.311089] CPU: 0 PID: 1 Comm: swapper Not tainted 4.0.0-rc3-00505-gaa34a6c #7
[    2.311089] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.7.5-20140531_083030-gandalf 04/01/2014
[    2.311089] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.7.5-20140531_083030-gandalf 04/01/2014
[    2.311089]  ffffffff826cedb0
[    2.311089]  ffffffff826cedb0 ffff88001246fc18 ffff88001246fc18 ffffffff817c123e ffffffff817c123e ffff88001246fcf8 ffff88001246fcf8

[    2.311089]  ffffffff81098da8
[    2.311089]  ffffffff81098da8 0000000000000292 0000000000000292 ffffffff81e1d7b8 ffffffff81e1d7b8 ffff88001246fc48 ffff88001246fc48

[    2.311089]  ffffffff00000000
[    2.311089]  ffffffff00000000 000000001246fc68 000000001246fc68 000000040c102081 000000040c102081 0000000000000002 0000000000000002

[    2.311089] Call Trace:
[    2.311089] Call Trace:
[    2.311089]  [<ffffffff817c123e>] dump_stack+0x19/0x1b
[    2.311089]  [<ffffffff817c123e>] dump_stack+0x19/0x1b
[    2.311089]  [<ffffffff81098da8>] __lock_acquire+0x17a8/0x2180
[    2.311089]  [<ffffffff81098da8>] __lock_acquire+0x17a8/0x2180
[    2.311089]  [<ffffffff81099fda>] lock_acquire+0x6a/0x90
[    2.311089]  [<ffffffff81099fda>] lock_acquire+0x6a/0x90
[    2.311089]  [<ffffffff813ef48d>] ? rhashtable_rehash+0xfd/0x1a0
[    2.311089]  [<ffffffff813ef48d>] ? rhashtable_rehash+0xfd/0x1a0
[    2.311089]  [<ffffffff81eb1cba>] ? test_rht_init+0xe8/0x37d
[    2.311089]  [<ffffffff81eb1cba>] ? test_rht_init+0xe8/0x37d
[    2.311089]  [<ffffffff817c7377>] _raw_spin_lock+0x37/0x70
[    2.311089]  [<ffffffff817c7377>] _raw_spin_lock+0x37/0x70
[    2.311089]  [<ffffffff813ef48d>] ? rhashtable_rehash+0xfd/0x1a0
[    2.311089]  [<ffffffff813ef48d>] ? rhashtable_rehash+0xfd/0x1a0
[    2.311089]  [<ffffffff813ef48d>] rhashtable_rehash+0xfd/0x1a0
[    2.311089]  [<ffffffff813ef48d>] rhashtable_rehash+0xfd/0x1a0
[    2.311089]  [<ffffffff81eb1cba>] ? test_rht_init+0xe8/0x37d
[    2.311089]  [<ffffffff81eb1cba>] ? test_rht_init+0xe8/0x37d
[    2.311089]  [<ffffffff81eb1bd2>] ? test_rht_lookup+0xca/0xca
[    2.311089]  [<ffffffff81eb1bd2>] ? test_rht_lookup+0xca/0xca
[    2.311089]  [<ffffffff813eff12>] rhashtable_expand+0x42/0x70
[    2.311089]  [<ffffffff813eff12>] rhashtable_expand+0x42/0x70
[    2.311089]  [<ffffffff81eb1d3a>] test_rht_init+0x168/0x37d
[    2.311089]  [<ffffffff81eb1d3a>] test_rht_init+0x168/0x37d
[    2.311089]  [<ffffffff81124838>] ? kfree+0xa8/0x110
[    2.311089]  [<ffffffff81124838>] ? kfree+0xa8/0x110
[    2.311089]  [<ffffffff813f19c0>] ? test_fw_misc_read+0x60/0x60
[    2.311089]  [<ffffffff813f19c0>] ? test_fw_misc_read+0x60/0x60
[    2.311089]  [<ffffffff810002a4>] do_one_initcall+0x84/0x1c0
[    2.311089]  [<ffffffff810002a4>] do_one_initcall+0x84/0x1c0
[    2.311089]  [<ffffffff81e930c4>] kernel_init_freeable+0x1eb/0x273
[    2.311089]  [<ffffffff81e930c4>] kernel_init_freeable+0x1eb/0x273
[    2.311089]  [<ffffffff817bcef0>] ? rest_init+0xc0/0xc0
[    2.311089]  [<ffffffff817bcef0>] ? rest_init+0xc0/0xc0
[    2.311089]  [<ffffffff817bcef9>] kernel_init+0x9/0xf0
[    2.311089]  [<ffffffff817bcef9>] kernel_init+0x9/0xf0
[    2.311089]  [<ffffffff817c8297>] ret_from_fork+0x57/0x90
[    2.311089]  [<ffffffff817c8297>] ret_from_fork+0x57/0x90
[    2.311089]  [<ffffffff817bcef0>] ? rest_init+0xc0/0xc0
[    2.311089]  [<ffffffff817bcef0>] ? rest_init+0xc0/0xc0
[    2.566279]   Verifying lookups...
[    2.566279]   Verifying lookups...
[    2.570044]   Table expansion iteration 1...

git bisect start 61f0d861fc6924fa673ecf1128a911d49cb10dc8 2c90331cf5ed1d648a711b9483e173aaaf2c4a9b --
git bisect good 843c2fdf7a12951815d981fa431d7e04d8259332  # 07:17     20+      0  net: dctcp: loosen requirement to assert ECT(0) during 3WHS
git bisect good 723b8e460d87e957f251dc5764f4ab86af6ab44e  # 07:45     20+      0  udp: In udp_flow_src_port use random hash value if skb_get_hash fails
git bisect good 496127290f298d839918a14728b653b43ef02708  # 07:53     20+      0  inet_diag: remove duplicate code from inet_twsk_diag_dump()
git bisect good cbe21d92e4d501e4895ef668b43fd8998c9b3b02  # 08:10     20+      0  net: stmmac: make reset control an optional requirement
git bisect good bf0b211256be342e92d3ee5c5a1fb8d42f3928bb  # 08:33     20+      0  Merge branch 'dsa-next'
git bisect good ddb4b9a1328ea89733133e86cf1972d23891abfc  # 08:44     20+      0  fib_trie: Address possible NULL pointer dereference in resize
git bisect  bad aa34a6cb0478842452bac58edb50d3ef9e178c92  # 09:02      0-      1  rhashtable: Add arbitrary rehash function
git bisect good 0ddcf43d5d4a03ded1ee3f6b3b72a0cbed4e90b1  # 09:09     20+      0  ipv4: FIB Local/MAIN table collapse
git bisect good 988dfbd795cf08b00576c1ced4210281b2bccffc  # 09:23     20+      0  rhashtable: Move hash_rnd into bucket_table
# first bad commit: [aa34a6cb0478842452bac58edb50d3ef9e178c92] rhashtable: Add arbitrary rehash function
git bisect good 988dfbd795cf08b00576c1ced4210281b2bccffc  # 09:26     60+      0  rhashtable: Move hash_rnd into bucket_table
# extra tests with DEBUG_INFO
git bisect  bad aa34a6cb0478842452bac58edb50d3ef9e178c92  # 09:35      0-      2  rhashtable: Add arbitrary rehash function
# extra tests on HEAD of net-next/master
git bisect  bad 61f0d861fc6924fa673ecf1128a911d49cb10dc8  # 09:35      0-     14  fib_trie: Fix uninitialized variable warning
# extra tests with first bad commit reverted
# extra tests on tree/branch linus/master
git bisect good cca28a5fda5d8fa69982bdb54341eeeb3eab215a  # 09:54     60+      1  Merge tag 'for-linus-20150310' of git://git.infradead.org/linux-mtd
# extra tests on tree/branch next/master
git bisect good 23bd64da26b62ee37a637be015149b703e6c3d04  # 10:08     60+      0  Add linux-next specific files for 20150311


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

--YiEDa0DAkWCtVeE4
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="dmesg-quantal-client9-13:20150312090115:x86_64-randconfig-iv1-03120156:4.0.0-rc3-00505-gaa34a6c:7"
Content-Transfer-Encoding: quoted-printable

early console in setup code
early console in decompress_kernel

Decompressing Linux... Parsing ELF... done.
Booting the kernel.
[    0.000000] Initializing cgroup subsys cpuset
[    0.000000] Initializing cgroup subsys cpu
[    0.000000] Linux version 4.0.0-rc3-00505-gaa34a6c (kbuild@ivytown2) (gc=
c version 4.9.2 (Debian 4.9.2-10) ) #7 Thu Mar 12 08:58:48 CST 2015
[    0.000000] Command line: hung_task_panic=3D1 earlyprintk=3DttyS0,115200=
 rd.udev.log-priority=3Derr systemd.log_target=3Djournal systemd.log_level=
=3Dwarning debug apic=3Ddebug sysrq_always_enabled rcupdate.rcu_cpu_stall_t=
imeout=3D100 panic=3D-1 softlockup_panic=3D1 nmi_watchdog=3Dpanic oops=3Dpa=
nic load_ramdisk=3D2 prompt_ramdisk=3D0 console=3DttyS0,115200 console=3Dtt=
y0 vga=3Dnormal  root=3D/dev/ram0 rw link=3D/kbuild-tests/run-queue/kvm/x86=
_64-randconfig-iv1-03120156/net-next:master:aa34a6cb0478842452bac58edb50d3e=
f9e178c92:bisect-linux-0/.vmlinuz-aa34a6cb0478842452bac58edb50d3ef9e178c92-=
20150312085959-7-client9 branch=3Dnet-next/master BOOT_IMAGE=3D/kernel/x86_=
64-randconfig-iv1-03120156/aa34a6cb0478842452bac58edb50d3ef9e178c92/vmlinuz=
-4.0.0-rc3-00505-gaa34a6c drbd.minor_count=3D8
[    0.000000] KERNEL supported cpus:
[    0.000000]   AMD AuthenticAMD
[    0.000000]   Centaur CentaurHauls
[    0.000000] CPU: vendor_id 'GenuineIntel' unknown, using generic init.
[    0.000000] CPU: Your system may be unstable.
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
[    0.000000] SMBIOS 2.8 present.
[    0.000000] DMI: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.7.5-2014=
0531_083030-gandalf 04/01/2014
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
[    0.000000] BRK [0x02e8f000, 0x02e8ffff] PGTABLE
[    0.000000] BRK [0x02e90000, 0x02e90fff] PGTABLE
[    0.000000] BRK [0x02e91000, 0x02e91fff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0x12600000-0x127fffff]
[    0.000000]  [mem 0x12600000-0x127fffff] page 2M
[    0.000000] init_memory_mapping: [mem 0x00100000-0x125fffff]
[    0.000000]  [mem 0x00100000-0x001fffff] page 4k
[    0.000000]  [mem 0x00200000-0x125fffff] page 2M
[    0.000000] init_memory_mapping: [mem 0x12800000-0x13fdffff]
[    0.000000]  [mem 0x12800000-0x13dfffff] page 2M
[    0.000000]  [mem 0x13e00000-0x13fdffff] page 4k
[    0.000000] BRK [0x02e92000, 0x02e92fff] PGTABLE
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
[    0.000000] mapped APIC to ffffffffff5fb000 (        fee00000)
[    0.000000] kvm-clock: Using msrs 4b564d01 and 4b564d00
[    0.000000] kvm-clock: cpu 0, msr 0:13fdf001, primary cpu clock
[    0.000000]  [ffffea0000000000-ffffea00005fffff] PMD -> [ffff880011a0000=
0-ffff880011ffffff] on node 0
[    0.000000] Zone ranges:
[    0.000000]   DMA      [mem 0x0000000000001000-0x0000000000ffffff]
[    0.000000]   DMA32    [mem 0x0000000001000000-0x0000000013fdffff]
[    0.000000]   Normal   empty
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x0000000000001000-0x000000000009efff]
[    0.000000]   node   0: [mem 0x0000000000100000-0x0000000013fdffff]
[    0.000000] Initmem setup node 0 [mem 0x0000000000001000-0x0000000013fdf=
fff]
[    0.000000] On node 0 totalpages: 81790
[    0.000000]   DMA zone: 64 pages used for memmap
[    0.000000]   DMA zone: 21 pages reserved
[    0.000000]   DMA zone: 3998 pages, LIFO batch:0
[    0.000000]   DMA32 zone: 1216 pages used for memmap
[    0.000000]   DMA32 zone: 77792 pages, LIFO batch:15
[    0.000000] ACPI: PM-Timer IO Port: 0x608
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to ffffffffff5fb000 (        fee00000)
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
[    0.000000] mapped IOAPIC to ffffffffff5fa000 (fec00000)
[    0.000000] KVM setup async PF for cpu 0
[    0.000000] kvm-stealtime: cpu 0, msr 1c28840
[    0.000000] e820: [mem 0x14000000-0xfeffbfff] available for PCI devices
[    0.000000] Booting paravirtualized kernel on KVM
[    0.000000] pcpu-alloc: s0 r0 d32768 u32768 alloc=3D1*32768
[    0.000000] pcpu-alloc: [0] 0=20
[    0.000000] Built 1 zonelists in Zone order, mobility grouping on.  Tota=
l pages: 80489
[    0.000000] Kernel command line: hung_task_panic=3D1 earlyprintk=3DttyS0=
,115200 rd.udev.log-priority=3Derr systemd.log_target=3Djournal systemd.log=
_level=3Dwarning debug apic=3Ddebug sysrq_always_enabled rcupdate.rcu_cpu_s=
tall_timeout=3D100 panic=3D-1 softlockup_panic=3D1 nmi_watchdog=3Dpanic oop=
s=3Dpanic load_ramdisk=3D2 prompt_ramdisk=3D0 console=3DttyS0,115200 consol=
e=3Dtty0 vga=3Dnormal  root=3D/dev/ram0 rw link=3D/kbuild-tests/run-queue/k=
vm/x86_64-randconfig-iv1-03120156/net-next:master:aa34a6cb0478842452bac58ed=
b50d3ef9e178c92:bisect-linux-0/.vmlinuz-aa34a6cb0478842452bac58edb50d3ef9e1=
78c92-20150312085959-7-client9 branch=3Dnet-next/master BOOT_IMAGE=3D/kerne=
l/x86_64-randconfig-iv1-03120156/aa34a6cb0478842452bac58edb50d3ef9e178c92/v=
mlinuz-4.0.0-rc3-00505-gaa34a6c drbd.minor_count=3D8
[    0.000000] sysrq: sysrq always enabled.
[    0.000000] PID hash table entries: 2048 (order: 2, 16384 bytes)
[    0.000000] Dentry cache hash table entries: 65536 (order: 7, 524288 byt=
es)
[    0.000000] Inode-cache hash table entries: 32768 (order: 6, 262144 byte=
s)
[    0.000000] Memory: 265480K/327160K available (7982K kernel code, 2626K =
rwdata, 3848K rodata, 764K init, 15604K bss, 61680K reserved, 0K cma-reserv=
ed)
[    0.000000] NR_IRQS:4352 nr_irqs:256 16
[    0.000000] Initializing cgroup subsys cpuset
[    0.000000] Initializing cgroup subsys cpu
[    0.000000] Linux version 4.0.0-rc3-00505-gaa34a6c (kbuild@ivytown2) (gc=
c version 4.9.2 (Debian 4.9.2-10) ) #7 Thu Mar 12 08:58:48 CST 2015
[    0.000000] Command line: hung_task_panic=3D1 earlyprintk=3DttyS0,115200=
 rd.udev.log-priority=3Derr systemd.log_target=3Djournal systemd.log_level=
=3Dwarning debug apic=3Ddebug sysrq_always_enabled rcupdate.rcu_cpu_stall_t=
imeout=3D100 panic=3D-1 softlockup_panic=3D1 nmi_watchdog=3Dpanic oops=3Dpa=
nic load_ramdisk=3D2 prompt_ramdisk=3D0 console=3DttyS0,115200 console=3Dtt=
y0 vga=3Dnormal  root=3D/dev/ram0 rw link=3D/kbuild-tests/run-queue/kvm/x86=
_64-randconfig-iv1-03120156/net-next:master:aa34a6cb0478842452bac58edb50d3e=
f9e178c92:bisect-linux-0/.vmlinuz-aa34a6cb0478842452bac58edb50d3ef9e178c92-=
20150312085959-7-client9 branch=3Dnet-next/master BOOT_IMAGE=3D/kernel/x86_=
64-randconfig-iv1-03120156/aa34a6cb0478842452bac58edb50d3ef9e178c92/vmlinuz=
-4.0.0-rc3-00505-gaa34a6c drbd.minor_count=3D8
[    0.000000] KERNEL supported cpus:
[    0.000000]   AMD AuthenticAMD
[    0.000000]   Centaur CentaurHauls
[    0.000000] CPU: vendor_id 'GenuineIntel' unknown, using generic init.
[    0.000000] CPU: Your system may be unstable.
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
[    0.000000] SMBIOS 2.8 present.
[    0.000000] DMI: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.7.5-2014=
0531_083030-gandalf 04/01/2014
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
[    0.000000] BRK [0x02e8f000, 0x02e8ffff] PGTABLE
[    0.000000] BRK [0x02e90000, 0x02e90fff] PGTABLE
[    0.000000] BRK [0x02e91000, 0x02e91fff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0x12600000-0x127fffff]
[    0.000000]  [mem 0x12600000-0x127fffff] page 2M
[    0.000000] init_memory_mapping: [mem 0x00100000-0x125fffff]
[    0.000000]  [mem 0x00100000-0x001fffff] page 4k
[    0.000000]  [mem 0x00200000-0x125fffff] page 2M
[    0.000000] init_memory_mapping: [mem 0x12800000-0x13fdffff]
[    0.000000]  [mem 0x12800000-0x13dfffff] page 2M
[    0.000000]  [mem 0x13e00000-0x13fdffff] page 4k
[    0.000000] BRK [0x02e92000, 0x02e92fff] PGTABLE
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
[    0.000000] mapped APIC to ffffffffff5fb000 (        fee00000)
[    0.000000] kvm-clock: Using msrs 4b564d01 and 4b564d00
[    0.000000] kvm-clock: cpu 0, msr 0:13fdf001, primary cpu clock
[    0.000000]  [ffffea0000000000-ffffea00005fffff] PMD -> [ffff880011a0000=
0-ffff880011ffffff] on node 0
[    0.000000] Zone ranges:
[    0.000000]   DMA      [mem 0x0000000000001000-0x0000000000ffffff]
[    0.000000]   DMA32    [mem 0x0000000001000000-0x0000000013fdffff]
[    0.000000]   Normal   empty
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x0000000000001000-0x000000000009efff]
[    0.000000]   node   0: [mem 0x0000000000100000-0x0000000013fdffff]
[    0.000000] Initmem setup node 0 [mem 0x0000000000001000-0x0000000013fdf=
fff]
[    0.000000] On node 0 totalpages: 81790
[    0.000000]   DMA zone: 64 pages used for memmap
[    0.000000]   DMA zone: 21 pages reserved
[    0.000000]   DMA zone: 3998 pages, LIFO batch:0
[    0.000000]   DMA32 zone: 1216 pages used for memmap
[    0.000000]   DMA32 zone: 77792 pages, LIFO batch:15
[    0.000000] ACPI: PM-Timer IO Port: 0x608
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to ffffffffff5fb000 (        fee00000)
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
[    0.000000] mapped IOAPIC to ffffffffff5fa000 (fec00000)
[    0.000000] KVM setup async PF for cpu 0
[    0.000000] kvm-stealtime: cpu 0, msr 1c28840
[    0.000000] e820: [mem 0x14000000-0xfeffbfff] available for PCI devices
[    0.000000] Booting paravirtualized kernel on KVM
[    0.000000] pcpu-alloc: s0 r0 d32768 u32768 alloc=3D1*32768
[    0.000000] pcpu-alloc: [0] 0=20
[    0.000000] Built 1 zonelists in Zone order, mobility grouping on.  Tota=
l pages: 80489
[    0.000000] Kernel command line: hung_task_panic=3D1 earlyprintk=3DttyS0=
,115200 rd.udev.log-priority=3Derr systemd.log_target=3Djournal systemd.log=
_level=3Dwarning debug apic=3Ddebug sysrq_always_enabled rcupdate.rcu_cpu_s=
tall_timeout=3D100 panic=3D-1 softlockup_panic=3D1 nmi_watchdog=3Dpanic oop=
s=3Dpanic load_ramdisk=3D2 prompt_ramdisk=3D0 console=3DttyS0,115200 consol=
e=3Dtty0 vga=3Dnormal  root=3D/dev/ram0 rw link=3D/kbuild-tests/run-queue/k=
vm/x86_64-randconfig-iv1-03120156/net-next:master:aa34a6cb0478842452bac58ed=
b50d3ef9e178c92:bisect-linux-0/.vmlinuz-aa34a6cb0478842452bac58edb50d3ef9e1=
78c92-20150312085959-7-client9 branch=3Dnet-next/master BOOT_IMAGE=3D/kerne=
l/x86_64-randconfig-iv1-03120156/aa34a6cb0478842452bac58edb50d3ef9e178c92/v=
mlinuz-4.0.0-rc3-00505-gaa34a6c drbd.minor_count=3D8
[    0.000000] sysrq: sysrq always enabled.
[    0.000000] PID hash table entries: 2048 (order: 2, 16384 bytes)
[    0.000000] Dentry cache hash table entries: 65536 (order: 7, 524288 byt=
es)
[    0.000000] Inode-cache hash table entries: 32768 (order: 6, 262144 byte=
s)
[    0.000000] Memory: 265480K/327160K available (7982K kernel code, 2626K =
rwdata, 3848K rodata, 764K init, 15604K bss, 61680K reserved, 0K cma-reserv=
ed)
[    0.000000] NR_IRQS:4352 nr_irqs:256 16
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
[    0.000000] ODEBUG: selftest passed
[    0.000000] ODEBUG: selftest passed
[    0.000000] hpet clockevent registered
[    0.000000] hpet clockevent registered
[    0.000000] tsc: Detected 2925.998 MHz processor
[    0.000000] tsc: Detected 2925.998 MHz processor
[    0.008000] Calibrating delay loop (skipped) preset value..=20
[    0.008000] Calibrating delay loop (skipped) preset value.. 5851.99 Bogo=
MIPS (lpj=3D11703992)
5851.99 BogoMIPS (lpj=3D11703992)
[    0.008856] pid_max: default: 32768 minimum: 301
[    0.008856] pid_max: default: 32768 minimum: 301
[    0.010112] ACPI: Core revision 20150204
[    0.010112] ACPI: Core revision 20150204
[    0.014449] ACPI:=20
[    0.014449] ACPI: All ACPI Tables successfully acquiredAll ACPI Tables s=
uccessfully acquired

[    0.016191] Security Framework initialized
[    0.016191] Security Framework initialized
[    0.017324] Mount-cache hash table entries: 1024 (order: 1, 8192 bytes)
[    0.017324] Mount-cache hash table entries: 1024 (order: 1, 8192 bytes)
[    0.020015] Mountpoint-cache hash table entries: 1024 (order: 1, 8192 by=
tes)
[    0.020015] Mountpoint-cache hash table entries: 1024 (order: 1, 8192 by=
tes)
[    0.022771] Initializing cgroup subsys blkio
[    0.022771] Initializing cgroup subsys blkio
[    0.024024] Initializing cgroup subsys memory
[    0.024024] Initializing cgroup subsys memory
[    0.025244] Initializing cgroup subsys freezer
[    0.025244] Initializing cgroup subsys freezer
[    0.026501] Last level iTLB entries: 4KB 0, 2MB 0, 4MB 0
[    0.026501] Last level iTLB entries: 4KB 0, 2MB 0, 4MB 0
[    0.028010] Last level dTLB entries: 4KB 0, 2MB 0, 4MB 0, 1GB 0
[    0.028010] Last level dTLB entries: 4KB 0, 2MB 0, 4MB 0, 1GB 0
[    0.029676] CPU:=20
[    0.029676] CPU: GenuineIntel GenuineIntel Common KVM processorCommon KV=
M processor (fam: 0f, model: 06 (fam: 0f, model: 06, stepping: 01)
, stepping: 01)
[    0.035367] Performance Events:=20
[    0.035367] Performance Events: no PMU driver, software events only.
no PMU driver, software events only.
[    0.037491] Getting VERSION: 1050014
[    0.037491] Getting VERSION: 1050014
[    0.038503] Getting VERSION: 1050014
[    0.038503] Getting VERSION: 1050014
[    0.039497] Getting ID: 0
[    0.039497] Getting ID: 0
[    0.040027] Getting ID: ff000000
[    0.040027] Getting ID: ff000000
[    0.041026] Getting LVT0: 8700
[    0.041026] Getting LVT0: 8700
[    0.041900] Getting LVT1: 8400
[    0.041900] Getting LVT1: 8400
[    0.042838] enabled ExtINT on CPU#0
[    0.042838] enabled ExtINT on CPU#0
[    0.045135] ENABLING IO-APIC IRQs
[    0.045135] ENABLING IO-APIC IRQs
[    0.048040] init IO_APIC IRQs
[    0.048040] init IO_APIC IRQs
[    0.048901]  apic 0 pin 0 not connected
[    0.048901]  apic 0 pin 0 not connected
[    0.050039] IOAPIC[0]: Set routing entry (0-1 -> 0x31 -> IRQ 1 Mode:0 Ac=
tive:0 Dest:1)
[    0.050039] IOAPIC[0]: Set routing entry (0-1 -> 0x31 -> IRQ 1 Mode:0 Ac=
tive:0 Dest:1)
[    0.052062] IOAPIC[0]: Set routing entry (0-2 -> 0x30 -> IRQ 0 Mode:0 Ac=
tive:0 Dest:1)
[    0.052062] IOAPIC[0]: Set routing entry (0-2 -> 0x30 -> IRQ 0 Mode:0 Ac=
tive:0 Dest:1)
[    0.054317] IOAPIC[0]: Set routing entry (0-2 -> 0x30 -> IRQ 0 Mode:0 Ac=
tive:0 Dest:1)
[    0.054317] IOAPIC[0]: Set routing entry (0-2 -> 0x30 -> IRQ 0 Mode:0 Ac=
tive:0 Dest:1)
[    0.056043] IOAPIC[0]: Set routing entry (0-3 -> 0x33 -> IRQ 3 Mode:0 Ac=
tive:0 Dest:1)
[    0.056043] IOAPIC[0]: Set routing entry (0-3 -> 0x33 -> IRQ 3 Mode:0 Ac=
tive:0 Dest:1)
[    0.060032] IOAPIC[0]: Set routing entry (0-4 -> 0x34 -> IRQ 4 Mode:0 Ac=
tive:0 Dest:1)
[    0.060032] IOAPIC[0]: Set routing entry (0-4 -> 0x34 -> IRQ 4 Mode:0 Ac=
tive:0 Dest:1)
[    0.062242] IOAPIC[0]: Set routing entry (0-5 -> 0x35 -> IRQ 5 Mode:1 Ac=
tive:0 Dest:1)
[    0.062242] IOAPIC[0]: Set routing entry (0-5 -> 0x35 -> IRQ 5 Mode:1 Ac=
tive:0 Dest:1)
[    0.064044] IOAPIC[0]: Set routing entry (0-6 -> 0x36 -> IRQ 6 Mode:0 Ac=
tive:0 Dest:1)
[    0.064044] IOAPIC[0]: Set routing entry (0-6 -> 0x36 -> IRQ 6 Mode:0 Ac=
tive:0 Dest:1)
[    0.066307] IOAPIC[0]: Set routing entry (0-7 -> 0x37 -> IRQ 7 Mode:0 Ac=
tive:0 Dest:1)
[    0.066307] IOAPIC[0]: Set routing entry (0-7 -> 0x37 -> IRQ 7 Mode:0 Ac=
tive:0 Dest:1)
[    0.068037] IOAPIC[0]: Set routing entry (0-8 -> 0x38 -> IRQ 8 Mode:0 Ac=
tive:0 Dest:1)
[    0.068037] IOAPIC[0]: Set routing entry (0-8 -> 0x38 -> IRQ 8 Mode:0 Ac=
tive:0 Dest:1)
[    0.070192] IOAPIC[0]: Set routing entry (0-9 -> 0x39 -> IRQ 9 Mode:1 Ac=
tive:0 Dest:1)
[    0.070192] IOAPIC[0]: Set routing entry (0-9 -> 0x39 -> IRQ 9 Mode:1 Ac=
tive:0 Dest:1)
[    0.072058] IOAPIC[0]: Set routing entry (0-10 -> 0x3a -> IRQ 10 Mode:1 =
Active:0 Dest:1)
[    0.072058] IOAPIC[0]: Set routing entry (0-10 -> 0x3a -> IRQ 10 Mode:1 =
Active:0 Dest:1)
[    0.076041] IOAPIC[0]: Set routing entry (0-11 -> 0x3b -> IRQ 11 Mode:1 =
Active:0 Dest:1)
[    0.076041] IOAPIC[0]: Set routing entry (0-11 -> 0x3b -> IRQ 11 Mode:1 =
Active:0 Dest:1)
[    0.078294] IOAPIC[0]: Set routing entry (0-12 -> 0x3c -> IRQ 12 Mode:0 =
Active:0 Dest:1)
[    0.078294] IOAPIC[0]: Set routing entry (0-12 -> 0x3c -> IRQ 12 Mode:0 =
Active:0 Dest:1)
[    0.080051] IOAPIC[0]: Set routing entry (0-13 -> 0x3d -> IRQ 13 Mode:0 =
Active:0 Dest:1)
[    0.080051] IOAPIC[0]: Set routing entry (0-13 -> 0x3d -> IRQ 13 Mode:0 =
Active:0 Dest:1)
[    0.084048] IOAPIC[0]: Set routing entry (0-14 -> 0x3e -> IRQ 14 Mode:0 =
Active:0 Dest:1)
[    0.084048] IOAPIC[0]: Set routing entry (0-14 -> 0x3e -> IRQ 14 Mode:0 =
Active:0 Dest:1)
[    0.086466] IOAPIC[0]: Set routing entry (0-15 -> 0x3f -> IRQ 15 Mode:0 =
Active:0 Dest:1)
[    0.086466] IOAPIC[0]: Set routing entry (0-15 -> 0x3f -> IRQ 15 Mode:0 =
Active:0 Dest:1)
[    0.088031]  apic 0 pin 16 not connected
[    0.088031]  apic 0 pin 16 not connected
[    0.089094]  apic 0 pin 17 not connected
[    0.089094]  apic 0 pin 17 not connected
[    0.090138]  apic 0 pin 18 not connected
[    0.090138]  apic 0 pin 18 not connected
[    0.092008]  apic 0 pin 19 not connected
[    0.092008]  apic 0 pin 19 not connected
[    0.093096]  apic 0 pin 20 not connected
[    0.093096]  apic 0 pin 20 not connected
[    0.094145]  apic 0 pin 21 not connected
[    0.094145]  apic 0 pin 21 not connected
[    0.095240]  apic 0 pin 22 not connected
[    0.095240]  apic 0 pin 22 not connected
[    0.096005]  apic 0 pin 23 not connected
[    0.096005]  apic 0 pin 23 not connected
[    0.097258] ..TIMER: vector=3D0x30 apic1=3D0 pin1=3D2 apic2=3D-1 pin2=3D=
-1
[    0.097258] ..TIMER: vector=3D0x30 apic1=3D0 pin1=3D2 apic2=3D-1 pin2=3D=
-1
[    0.100009] Using local APIC timer interrupts.
[    0.100009] calibrating APIC timer ...
[    0.100009] Using local APIC timer interrupts.
[    0.100009] calibrating APIC timer ...
[    0.108000] ... lapic delta =3D 6499817
[    0.108000] ... lapic delta =3D 6499817
[    0.108000] ... PM-Timer delta =3D 372261
[    0.108000] ... PM-Timer delta =3D 372261
[    0.108000] APIC calibration not consistent with PM-Timer: 103ms instead=
 of 100ms
[    0.108000] APIC calibration not consistent with PM-Timer: 103ms instead=
 of 100ms
[    0.108000] APIC delta adjusted to PM-Timer: 6250011 (6499817)
[    0.108000] APIC delta adjusted to PM-Timer: 6250011 (6499817)
[    0.108000] TSC delta adjusted to PM-Timer: 292600598 (304295500)
[    0.108000] TSC delta adjusted to PM-Timer: 292600598 (304295500)
[    0.108000] ..... delta 6250011
[    0.108000] ..... delta 6250011
[    0.108000] ..... mult: 268435928
[    0.108000] ..... mult: 268435928
[    0.108000] ..... calibration result: 4000007
[    0.108000] ..... calibration result: 4000007
[    0.108000] ..... CPU clock speed is 2926.0023 MHz.
[    0.108000] ..... CPU clock speed is 2926.0023 MHz.
[    0.108000] ..... host bus clock speed is 1000.0007 MHz.
[    0.108000] ..... host bus clock speed is 1000.0007 MHz.
[    0.109266] xor: measuring software checksum speed
[    0.109266] xor: measuring software checksum speed
[    0.148008]    prefetch64-sse:  9204.000 MB/sec
[    0.148008]    prefetch64-sse:  9204.000 MB/sec
[    0.188008]    generic_sse:  8070.000 MB/sec
[    0.188008]    generic_sse:  8070.000 MB/sec
[    0.192010] xor: using function: prefetch64-sse (9204.000 MB/sec)
[    0.192010] xor: using function: prefetch64-sse (9204.000 MB/sec)
[    0.196019] prandom: seed boundary self test passed
[    0.196019] prandom: seed boundary self test passed
[    0.200769] prandom: 100 self tests passed
[    0.200769] prandom: 100 self tests passed
[    0.202638] atomic64_test: passed for x86-64 platform with CX8 and with =
SSE
[    0.202638] atomic64_test: passed for x86-64 platform with CX8 and with =
SSE
[    0.204547] NET: Registered protocol family 16
[    0.204547] NET: Registered protocol family 16
[    0.208826] cpuidle: using governor ladder
[    0.208826] cpuidle: using governor ladder
[    0.212019] cpuidle: using governor menu
[    0.212019] cpuidle: using governor menu
[    0.214622] ACPI: bus type PCI registered
[    0.214622] ACPI: bus type PCI registered
[    0.216120] PCI: Using configuration type 1 for base access
[    0.216120] PCI: Using configuration type 1 for base access
[    0.296015] raid6: sse2x1    3698 MB/s
[    0.296015] raid6: sse2x1    3698 MB/s
[    0.364018] raid6: sse2x2    4575 MB/s
[    0.364018] raid6: sse2x2    4575 MB/s
[    0.436011] raid6: sse2x4    3696 MB/s
[    0.436011] raid6: sse2x4    3696 MB/s
[    0.440010] raid6: using algorithm sse2x2 (4575 MB/s)
[    0.440010] raid6: using algorithm sse2x2 (4575 MB/s)
[    0.444009] raid6: using intx1 recovery algorithm
[    0.444009] raid6: using intx1 recovery algorithm
[    0.448225] ACPI: Added _OSI(Module Device)
[    0.448225] ACPI: Added _OSI(Module Device)
[    0.452012] ACPI: Added _OSI(Processor Device)
[    0.452012] ACPI: Added _OSI(Processor Device)
[    0.456012] ACPI: Added _OSI(3.0 _SCP Extensions)
[    0.456012] ACPI: Added _OSI(3.0 _SCP Extensions)
[    0.460013] ACPI: Added _OSI(Processor Aggregator Device)
[    0.460013] ACPI: Added _OSI(Processor Aggregator Device)
[    0.469063] IOAPIC[0]: Set routing entry (0-9 -> 0x39 -> IRQ 9 Mode:1 Ac=
tive:0 Dest:1)
[    0.469063] IOAPIC[0]: Set routing entry (0-9 -> 0x39 -> IRQ 9 Mode:1 Ac=
tive:0 Dest:1)
[    0.480220] ACPI: Interpreter enabled
[    0.480220] ACPI: Interpreter enabled
[    0.484029] ACPI: (supports S0 S5)
[    0.484029] ACPI: (supports S0 S5)
[    0.488009] ACPI: Using IOAPIC for interrupt routing
[    0.488009] ACPI: Using IOAPIC for interrupt routing
[    0.492070] PCI: Using host bridge windows from ACPI; if necessary, use =
"pci=3Dnocrs" and report a bug
[    0.492070] PCI: Using host bridge windows from ACPI; if necessary, use =
"pci=3Dnocrs" and report a bug
[    0.505885] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-ff])
[    0.505885] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-ff])
[    0.508023] acpi PNP0A03:00: _OSC: OS supports [Segments MSI]
[    0.508023] acpi PNP0A03:00: _OSC: OS supports [Segments MSI]
[    0.512087] acpi PNP0A03:00: _OSC failed (AE_NOT_FOUND); disabling ASPM
[    0.512087] acpi PNP0A03:00: _OSC failed (AE_NOT_FOUND); disabling ASPM
[    0.516447] PCI host bridge to bus 0000:00
[    0.516447] PCI host bridge to bus 0000:00
[    0.520016] pci_bus 0000:00: root bus resource [bus 00-ff]
[    0.520016] pci_bus 0000:00: root bus resource [bus 00-ff]
[    0.524011] pci_bus 0000:00: root bus resource [io  0x0000-0x0cf7 window]
[    0.524011] pci_bus 0000:00: root bus resource [io  0x0000-0x0cf7 window]
[    0.528013] pci_bus 0000:00: root bus resource [io  0x0d00-0xadff window]
[    0.528013] pci_bus 0000:00: root bus resource [io  0x0d00-0xadff window]
[    0.532013] pci_bus 0000:00: root bus resource [io  0xae0f-0xaeff window]
[    0.532013] pci_bus 0000:00: root bus resource [io  0xae0f-0xaeff window]
[    0.536011] pci_bus 0000:00: root bus resource [io  0xaf20-0xafdf window]
[    0.536011] pci_bus 0000:00: root bus resource [io  0xaf20-0xafdf window]
[    0.540013] pci_bus 0000:00: root bus resource [io  0xafe4-0xffff window]
[    0.540013] pci_bus 0000:00: root bus resource [io  0xafe4-0xffff window]
[    0.544013] pci_bus 0000:00: root bus resource [mem 0x000a0000-0x000bfff=
f window]
[    0.544013] pci_bus 0000:00: root bus resource [mem 0x000a0000-0x000bfff=
f window]
[    0.548014] pci_bus 0000:00: root bus resource [mem 0x14000000-0xfebffff=
f window]
[    0.548014] pci_bus 0000:00: root bus resource [mem 0x14000000-0xfebffff=
f window]
[    0.556044] pci 0000:00:00.0: [8086:1237] type 00 class 0x060000
[    0.556044] pci 0000:00:00.0: [8086:1237] type 00 class 0x060000
[    0.560797] pci 0000:00:01.0: [8086:7000] type 00 class 0x060100
[    0.560797] pci 0000:00:01.0: [8086:7000] type 00 class 0x060100
[    0.564913] pci 0000:00:01.1: [8086:7010] type 00 class 0x010180
[    0.564913] pci 0000:00:01.1: [8086:7010] type 00 class 0x010180
[    0.574756] pci 0000:00:01.1: reg 0x20: [io  0xc040-0xc04f]
[    0.574756] pci 0000:00:01.1: reg 0x20: [io  0xc040-0xc04f]
[    0.577307] pci 0000:00:01.1: legacy IDE quirk: reg 0x10: [io  0x01f0-0x=
01f7]
[    0.577307] pci 0000:00:01.1: legacy IDE quirk: reg 0x10: [io  0x01f0-0x=
01f7]
[    0.580013] pci 0000:00:01.1: legacy IDE quirk: reg 0x14: [io  0x03f6]
[    0.580013] pci 0000:00:01.1: legacy IDE quirk: reg 0x14: [io  0x03f6]
[    0.584012] pci 0000:00:01.1: legacy IDE quirk: reg 0x18: [io  0x0170-0x=
0177]
[    0.584012] pci 0000:00:01.1: legacy IDE quirk: reg 0x18: [io  0x0170-0x=
0177]
[    0.588009] pci 0000:00:01.1: legacy IDE quirk: reg 0x1c: [io  0x0376]
[    0.588009] pci 0000:00:01.1: legacy IDE quirk: reg 0x1c: [io  0x0376]
[    0.592450] pci 0000:00:01.3: [8086:7113] type 00 class 0x068000
[    0.592450] pci 0000:00:01.3: [8086:7113] type 00 class 0x068000
[    0.596577] pci 0000:00:01.3: quirk: [io  0x0600-0x063f] claimed by PIIX=
4 ACPI
[    0.596577] pci 0000:00:01.3: quirk: [io  0x0600-0x063f] claimed by PIIX=
4 ACPI
[    0.600032] pci 0000:00:01.3: quirk: [io  0x0700-0x070f] claimed by PIIX=
4 SMB
[    0.600032] pci 0000:00:01.3: quirk: [io  0x0700-0x070f] claimed by PIIX=
4 SMB
[    0.604511] pci 0000:00:02.0: [1013:00b8] type 00 class 0x030000
[    0.604511] pci 0000:00:02.0: [1013:00b8] type 00 class 0x030000
[    0.609435] pci 0000:00:02.0: reg 0x10: [mem 0xfc000000-0xfdffffff pref]
[    0.609435] pci 0000:00:02.0: reg 0x10: [mem 0xfc000000-0xfdffffff pref]
[    0.613339] pci 0000:00:02.0: reg 0x14: [mem 0xfebf0000-0xfebf0fff]
[    0.613339] pci 0000:00:02.0: reg 0x14: [mem 0xfebf0000-0xfebf0fff]
[    0.622386] pci 0000:00:02.0: reg 0x30: [mem 0xfebe0000-0xfebeffff pref]
[    0.622386] pci 0000:00:02.0: reg 0x30: [mem 0xfebe0000-0xfebeffff pref]
[    0.624478] pci 0000:00:03.0: [8086:100e] type 00 class 0x020000
[    0.624478] pci 0000:00:03.0: [8086:100e] type 00 class 0x020000
[    0.629255] pci 0000:00:03.0: reg 0x10: [mem 0xfebc0000-0xfebdffff]
[    0.629255] pci 0000:00:03.0: reg 0x10: [mem 0xfebc0000-0xfebdffff]
[    0.633171] pci 0000:00:03.0: reg 0x14: [io  0xc000-0xc03f]
[    0.633171] pci 0000:00:03.0: reg 0x14: [io  0xc000-0xc03f]
[    0.644618] pci 0000:00:03.0: reg 0x30: [mem 0xfeb80000-0xfebbffff pref]
[    0.644618] pci 0000:00:03.0: reg 0x30: [mem 0xfeb80000-0xfebbffff pref]
[    0.648461] pci 0000:00:04.0: [8086:25ab] type 00 class 0x088000
[    0.648461] pci 0000:00:04.0: [8086:25ab] type 00 class 0x088000
[    0.652777] pci 0000:00:04.0: reg 0x10: [mem 0xfebf1000-0xfebf100f]
[    0.652777] pci 0000:00:04.0: reg 0x10: [mem 0xfebf1000-0xfebf100f]
[    0.665030] pci_bus 0000:00: on NUMA node 0
[    0.665030] pci_bus 0000:00: on NUMA node 0
[    0.669022] ACPI: PCI Interrupt Link [LNKA] (IRQs
[    0.669022] ACPI: PCI Interrupt Link [LNKA] (IRQs 5 5 *10 *10 11 11))

[    0.673863] ACPI: PCI Interrupt Link [LNKB] (IRQs
[    0.673863] ACPI: PCI Interrupt Link [LNKB] (IRQs 5 5 *10 *10 11 11))

[    0.681237] ACPI: PCI Interrupt Link [LNKC] (IRQs
[    0.681237] ACPI: PCI Interrupt Link [LNKC] (IRQs 5 5 10 10 *11 *11))

[    0.688428] ACPI: PCI Interrupt Link [LNKD] (IRQs
[    0.688428] ACPI: PCI Interrupt Link [LNKD] (IRQs 5 5 10 10 *11 *11))

[    0.696024] ACPI: PCI Interrupt Link [LNKS] (IRQs
[    0.696024] ACPI: PCI Interrupt Link [LNKS] (IRQs *9 *9))

[    0.701267] ACPI:=20
[    0.701267] ACPI: Enabled 16 GPEs in block 00 to 0FEnabled 16 GPEs in bl=
ock 00 to 0F

[    0.708065] vgaarb: setting as boot device: PCI:0000:00:02.0
[    0.708065] vgaarb: setting as boot device: PCI:0000:00:02.0
[    0.712000] vgaarb: device added: PCI:0000:00:02.0,decodes=3Dio+mem,owns=
=3Dio+mem,locks=3Dnone
[    0.712000] vgaarb: device added: PCI:0000:00:02.0,decodes=3Dio+mem,owns=
=3Dio+mem,locks=3Dnone
[    0.712011] vgaarb: loaded
[    0.712011] vgaarb: loaded
[    0.716007] vgaarb: bridge control possible 0000:00:02.0
[    0.716007] vgaarb: bridge control possible 0000:00:02.0
[    0.720723] SCSI subsystem initialized
[    0.720723] SCSI subsystem initialized
[    0.724084] libata version 3.00 loaded.
[    0.724084] libata version 3.00 loaded.
[    0.727259] ACPI: bus type USB registered
[    0.727259] ACPI: bus type USB registered
[    0.728102] usbcore: registered new interface driver usbfs
[    0.728102] usbcore: registered new interface driver usbfs
[    0.732068] usbcore: registered new interface driver hub
[    0.732068] usbcore: registered new interface driver hub
[    0.736066] usbcore: registered new device driver usb
[    0.736066] usbcore: registered new device driver usb
[    0.740154] Linux video capture interface: v2.00
[    0.740154] Linux video capture interface: v2.00
[    0.744064] pps_core: LinuxPPS API ver. 1 registered
[    0.744064] pps_core: LinuxPPS API ver. 1 registered
[    0.748009] pps_core: Software ver. 5.3.6 - Copyright 2005-2007 Rodolfo =
Giometti <giometti@linux.it>
[    0.748009] pps_core: Software ver. 5.3.6 - Copyright 2005-2007 Rodolfo =
Giometti <giometti@linux.it>
[    0.752435] Advanced Linux Sound Architecture Driver Initialized.
[    0.752435] Advanced Linux Sound Architecture Driver Initialized.
[    0.756061] PCI: Using ACPI for IRQ routing
[    0.756061] PCI: Using ACPI for IRQ routing
[    0.760008] PCI: pci_cache_line_size set to 64 bytes
[    0.760008] PCI: pci_cache_line_size set to 64 bytes
[    0.764164] e820: reserve RAM buffer [mem 0x0009fc00-0x0009ffff]
[    0.764164] e820: reserve RAM buffer [mem 0x0009fc00-0x0009ffff]
[    0.768022] e820: reserve RAM buffer [mem 0x13fe0000-0x13ffffff]
[    0.768022] e820: reserve RAM buffer [mem 0x13fe0000-0x13ffffff]
[    0.772849] HPET: 3 timers in total, 0 timers will be used for per-cpu t=
imer
[    0.772849] HPET: 3 timers in total, 0 timers will be used for per-cpu t=
imer
[    0.776292] Switched to clocksource kvm-clock
[    0.776292] Switched to clocksource kvm-clock
[    0.781205] pnp: PnP ACPI init
[    0.781205] pnp: PnP ACPI init
[    0.784901] IOAPIC[0]: Set routing entry (0-8 -> 0x38 -> IRQ 8 Mode:0 Ac=
tive:0 Dest:1)
[    0.784901] IOAPIC[0]: Set routing entry (0-8 -> 0x38 -> IRQ 8 Mode:0 Ac=
tive:0 Dest:1)
[    0.793422] pnp 00:00: Plug and Play ACPI device, IDs PNP0b00 (active)
[    0.793422] pnp 00:00: Plug and Play ACPI device, IDs PNP0b00 (active)
[    0.800232] IOAPIC[0]: Set routing entry (0-1 -> 0x31 -> IRQ 1 Mode:0 Ac=
tive:0 Dest:1)
[    0.800232] IOAPIC[0]: Set routing entry (0-1 -> 0x31 -> IRQ 1 Mode:0 Ac=
tive:0 Dest:1)
[    0.809664] pnp 00:01: Plug and Play ACPI device, IDs PNP0303 (active)
[    0.809664] pnp 00:01: Plug and Play ACPI device, IDs PNP0303 (active)
[    0.825864] IOAPIC[0]: Set routing entry (0-12 -> 0x3c -> IRQ 12 Mode:0 =
Active:0 Dest:1)
[    0.825864] IOAPIC[0]: Set routing entry (0-12 -> 0x3c -> IRQ 12 Mode:0 =
Active:0 Dest:1)
[    0.829747] pnp 00:02: Plug and Play ACPI device, IDs PNP0f13 (active)
[    0.829747] pnp 00:02: Plug and Play ACPI device, IDs PNP0f13 (active)
[    0.832941] IOAPIC[0]: Set routing entry (0-6 -> 0x36 -> IRQ 6 Mode:0 Ac=
tive:0 Dest:1)
[    0.832941] IOAPIC[0]: Set routing entry (0-6 -> 0x36 -> IRQ 6 Mode:0 Ac=
tive:0 Dest:1)
[    0.836589] pnp 00:03: [dma 2]
[    0.836589] pnp 00:03: [dma 2]
[    0.838138] pnp 00:03: Plug and Play ACPI device, IDs PNP0700 (active)
[    0.838138] pnp 00:03: Plug and Play ACPI device, IDs PNP0700 (active)
[    0.847392] IOAPIC[0]: Set routing entry (0-7 -> 0x37 -> IRQ 7 Mode:0 Ac=
tive:0 Dest:1)
[    0.847392] IOAPIC[0]: Set routing entry (0-7 -> 0x37 -> IRQ 7 Mode:0 Ac=
tive:0 Dest:1)
[    0.851319] pnp 00:04: Plug and Play ACPI device, IDs PNP0400 (active)
[    0.851319] pnp 00:04: Plug and Play ACPI device, IDs PNP0400 (active)
[    0.854694] IOAPIC[0]: Set routing entry (0-4 -> 0x34 -> IRQ 4 Mode:0 Ac=
tive:0 Dest:1)
[    0.854694] IOAPIC[0]: Set routing entry (0-4 -> 0x34 -> IRQ 4 Mode:0 Ac=
tive:0 Dest:1)
[    0.858524] pnp 00:05: Plug and Play ACPI device, IDs PNP0501 (active)
[    0.858524] pnp 00:05: Plug and Play ACPI device, IDs PNP0501 (active)
[    0.863151] pnp: PnP ACPI: found 6 devices
[    0.863151] pnp: PnP ACPI: found 6 devices
[    0.870343] pci_bus 0000:00: resource 4 [io  0x0000-0x0cf7 window]
[    0.870343] pci_bus 0000:00: resource 4 [io  0x0000-0x0cf7 window]
[    0.873298] pci_bus 0000:00: resource 5 [io  0x0d00-0xadff window]
[    0.873298] pci_bus 0000:00: resource 5 [io  0x0d00-0xadff window]
[    0.876200] pci_bus 0000:00: resource 6 [io  0xae0f-0xaeff window]
[    0.876200] pci_bus 0000:00: resource 6 [io  0xae0f-0xaeff window]
[    0.879149] pci_bus 0000:00: resource 7 [io  0xaf20-0xafdf window]
[    0.879149] pci_bus 0000:00: resource 7 [io  0xaf20-0xafdf window]
[    0.881998] pci_bus 0000:00: resource 8 [io  0xafe4-0xffff window]
[    0.881998] pci_bus 0000:00: resource 8 [io  0xafe4-0xffff window]
[    0.884839] pci_bus 0000:00: resource 9 [mem 0x000a0000-0x000bffff windo=
w]
[    0.884839] pci_bus 0000:00: resource 9 [mem 0x000a0000-0x000bffff windo=
w]
[    0.887891] pci_bus 0000:00: resource 10 [mem 0x14000000-0xfebfffff wind=
ow]
[    0.887891] pci_bus 0000:00: resource 10 [mem 0x14000000-0xfebfffff wind=
ow]
[    0.891223] NET: Registered protocol family 1
[    0.891223] NET: Registered protocol family 1
[    0.893400] pci 0000:00:00.0: Limiting direct PCI/PCI transfers
[    0.893400] pci 0000:00:00.0: Limiting direct PCI/PCI transfers
[    0.896190] pci 0000:00:01.0: PIIX3: Enabling Passive Release
[    0.896190] pci 0000:00:01.0: PIIX3: Enabling Passive Release
[    0.898954] pci 0000:00:01.0: Activating ISA DMA hang workarounds
[    0.898954] pci 0000:00:01.0: Activating ISA DMA hang workarounds
[    0.901906] pci 0000:00:02.0: Video device with shadowed ROM
[    0.901906] pci 0000:00:02.0: Video device with shadowed ROM
[    0.904649] PCI: CLS 0 bytes, default 64
[    0.904649] PCI: CLS 0 bytes, default 64
[    0.906851] Unpacking initramfs...
[    0.906851] Unpacking initramfs...
[    2.093528] Freeing initrd memory: 23244K (ffff880012925000 - ffff880013=
fd8000)
[    2.093528] Freeing initrd memory: 23244K (ffff880012925000 - ffff880013=
fd8000)
[    2.110746] microcode: no support for this CPU vendor
[    2.110746] microcode: no support for this CPU vendor
[    2.114328] PCLMULQDQ-NI instructions are not detected.
[    2.114328] PCLMULQDQ-NI instructions are not detected.
[    2.116879] AVX or AES-NI instructions are not detected.
[    2.116879] AVX or AES-NI instructions are not detected.
[    2.119430] AVX instructions are not detected.
[    2.119430] AVX instructions are not detected.
[    2.121738] spin_lock-torture:--- Start of test [debug]: nwriters_stress=
=3D2 nreaders_stress=3D0 stat_interval=3D60 verbose=3D1 shuffle_interval=3D=
3 stutter=3D5 shutdown_secs=3D0 onoff_interval=3D0 onoff_holdoff=3D0
[    2.121738] spin_lock-torture:--- Start of test [debug]: nwriters_stress=
=3D2 nreaders_stress=3D0 stat_interval=3D60 verbose=3D1 shuffle_interval=3D=
3 stutter=3D5 shutdown_secs=3D0 onoff_interval=3D0 onoff_holdoff=3D0
[    2.143019] spin_lock-torture: Creating torture_shuffle task
[    2.143019] spin_lock-torture: Creating torture_shuffle task
[    2.145925] spin_lock-torture: Creating torture_stutter task
[    2.145925] spin_lock-torture: Creating torture_stutter task
[    2.148640] spin_lock-torture: torture_shuffle task started
[    2.148640] spin_lock-torture: torture_shuffle task started
[    2.164423] spin_lock-torture: Creating lock_torture_writer task
[    2.164423] spin_lock-torture: Creating lock_torture_writer task
[    2.167355] spin_lock-torture: torture_stutter task started
[    2.167355] spin_lock-torture: torture_stutter task started
[    2.170093] spin_lock-torture: Creating lock_torture_writer task
[    2.170093] spin_lock-torture: Creating lock_torture_writer task
[    2.173068] spin_lock-torture: lock_torture_writer task started
[    2.173068] spin_lock-torture: lock_torture_writer task started
[    2.176101] spin_lock-torture: Creating lock_torture_stats task
[    2.176101] spin_lock-torture: Creating lock_torture_stats task
[    2.178976] spin_lock-torture: lock_torture_writer task started
[    2.178976] spin_lock-torture: lock_torture_writer task started
[    2.195014] futex hash table entries: 256 (order: 2, 24576 bytes)
[    2.195014] futex hash table entries: 256 (order: 2, 24576 bytes)
[    2.197360] Initialise system trusted keyring
[    2.197360] Initialise system trusted keyring
[    2.199451] spin_lock-torture: lock_torture_stats task started
[    2.199451] spin_lock-torture: lock_torture_stats task started
[    2.202321] VFS: Disk quotas dquot_6.5.2
[    2.202321] VFS: Disk quotas dquot_6.5.2
[    2.204130] VFS: Dquot-cache hash table entries: 512 (order 0, 4096 byte=
s)
[    2.204130] VFS: Dquot-cache hash table entries: 512 (order 0, 4096 byte=
s)
[    2.206987] fuse init (API version 7.23)
[    2.206987] fuse init (API version 7.23)
[    2.208610] JFS: nTxBlock =3D 2255, nTxLock =3D 18045
[    2.208610] JFS: nTxBlock =3D 2255, nTxLock =3D 18045
[    2.224557] SGI XFS with security attributes, debug enabled
[    2.224557] SGI XFS with security attributes, debug enabled
[    2.227577] NILFS version 2 loaded
[    2.227577] NILFS version 2 loaded
[    2.229603] gfs2: GFS2 installed
[    2.229603] gfs2: GFS2 installed
[    2.231227] Key type big_key registered
[    2.231227] Key type big_key registered
[    2.234852] Key type asymmetric registered
[    2.234852] Key type asymmetric registered
[    2.249511] Asymmetric key parser 'x509' registered
[    2.249511] Asymmetric key parser 'x509' registered
[    2.251886] Key type pkcs7_test registered
[    2.251886] Key type pkcs7_test registered
[    2.253964] bounce: pool size: 64 pages
[    2.253964] bounce: pool size: 64 pages
[    2.255845] Block layer SCSI generic (bsg) driver version 0.4 loaded (ma=
jor 252)
[    2.255845] Block layer SCSI generic (bsg) driver version 0.4 loaded (ma=
jor 252)
[    2.259637] io scheduler noop registered (default)
[    2.259637] io scheduler noop registered (default)
[    2.262252] test_hexdump: Running tests...
[    2.262252] test_hexdump: Running tests...
[    2.276919] test_firmware: interface ready
[    2.276919] test_firmware: interface ready
[    2.278880] Running resizable hashtable tests...
[    2.278880] Running resizable hashtable tests...
[    2.281120]   Adding 2048 keys
[    2.281120]   Adding 2048 keys
[    2.284374]   Traversal complete: counted=3D2048, nelems=3D2048, entries=
=3D2048
[    2.284374]   Traversal complete: counted=3D2048, nelems=3D2048, entries=
=3D2048
[    2.292218]   Table expansion iteration 0...
[    2.292218]   Table expansion iteration 0...
[    2.307176]=20
[    2.307176]=20
[    2.307922] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
[    2.307922] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
[    2.310446] [ INFO: possible recursive locking detected ]
[    2.310446] [ INFO: possible recursive locking detected ]
[    2.311089] 4.0.0-rc3-00505-gaa34a6c #7 Not tainted
[    2.311089] 4.0.0-rc3-00505-gaa34a6c #7 Not tainted
[    2.311089] ---------------------------------------------
[    2.311089] ---------------------------------------------
[    2.311089] swapper/1 is trying to acquire lock:
[    2.311089] swapper/1 is trying to acquire lock:
[    2.311089]  (
[    2.311089]  (&(&tbl->locks[i])->rlock&(&tbl->locks[i])->rlock){+.....})=
{+.....}, at: , at: [<ffffffff813ef48d>] rhashtable_rehash+0xfd/0x1a0
[<ffffffff813ef48d>] rhashtable_rehash+0xfd/0x1a0
[    2.311089]=20
[    2.311089] but task is already holding lock:
[    2.311089]=20
[    2.311089] but task is already holding lock:
[    2.311089]  (
[    2.311089]  (&(&tbl->locks[i])->rlock&(&tbl->locks[i])->rlock){+.....})=
{+.....}, at: , at: [<ffffffff813ef401>] rhashtable_rehash+0x71/0x1a0
[<ffffffff813ef401>] rhashtable_rehash+0x71/0x1a0
[    2.311089]=20
[    2.311089] other info that might help us debug this:
[    2.311089]=20
[    2.311089] other info that might help us debug this:
[    2.311089]  Possible unsafe locking scenario:
[    2.311089]=20
[    2.311089]  Possible unsafe locking scenario:
[    2.311089]=20
[    2.311089]        CPU0
[    2.311089]        CPU0
[    2.311089]        ----
[    2.311089]        ----
[    2.311089]   lock(
[    2.311089]   lock(&(&tbl->locks[i])->rlock&(&tbl->locks[i])->rlock);
);
[    2.311089]   lock(
[    2.311089]   lock(&(&tbl->locks[i])->rlock&(&tbl->locks[i])->rlock);
);
[    2.311089]=20
[    2.311089]  *** DEADLOCK ***
[    2.311089]=20
[    2.311089]=20
[    2.311089]  *** DEADLOCK ***
[    2.311089]=20
[    2.311089]  May be due to missing lock nesting notation
[    2.311089]=20
[    2.311089]  May be due to missing lock nesting notation
[    2.311089]=20
[    2.311089] 2 locks held by swapper/1:
[    2.311089] 2 locks held by swapper/1:
[    2.311089]  #0:=20
[    2.311089]  #0:  ( (&ht->mutex&ht->mutex){+.+.+.}){+.+.+.}, at: , at: [=
<ffffffff81eb1d2e>] test_rht_init+0x15c/0x37d
[<ffffffff81eb1d2e>] test_rht_init+0x15c/0x37d
[    2.311089]  #1:=20
[    2.311089]  #1:  ( (&(&tbl->locks[i])->rlock&(&tbl->locks[i])->rlock){+=
=2E....}){+.....}, at: , at: [<ffffffff813ef401>] rhashtable_rehash+0x71/0x=
1a0
[<ffffffff813ef401>] rhashtable_rehash+0x71/0x1a0
[    2.311089]=20
[    2.311089] stack backtrace:
[    2.311089]=20
[    2.311089] stack backtrace:
[    2.311089] CPU: 0 PID: 1 Comm: swapper Not tainted 4.0.0-rc3-00505-gaa3=
4a6c #7
[    2.311089] CPU: 0 PID: 1 Comm: swapper Not tainted 4.0.0-rc3-00505-gaa3=
4a6c #7
[    2.311089] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS =
1.7.5-20140531_083030-gandalf 04/01/2014
[    2.311089] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS =
1.7.5-20140531_083030-gandalf 04/01/2014
[    2.311089]  ffffffff826cedb0
[    2.311089]  ffffffff826cedb0 ffff88001246fc18 ffff88001246fc18 ffffffff=
817c123e ffffffff817c123e ffff88001246fcf8 ffff88001246fcf8

[    2.311089]  ffffffff81098da8
[    2.311089]  ffffffff81098da8 0000000000000292 0000000000000292 ffffffff=
81e1d7b8 ffffffff81e1d7b8 ffff88001246fc48 ffff88001246fc48

[    2.311089]  ffffffff00000000
[    2.311089]  ffffffff00000000 000000001246fc68 000000001246fc68 00000004=
0c102081 000000040c102081 0000000000000002 0000000000000002

[    2.311089] Call Trace:
[    2.311089] Call Trace:
[    2.311089]  [<ffffffff817c123e>] dump_stack+0x19/0x1b
[    2.311089]  [<ffffffff817c123e>] dump_stack+0x19/0x1b
[    2.311089]  [<ffffffff81098da8>] __lock_acquire+0x17a8/0x2180
[    2.311089]  [<ffffffff81098da8>] __lock_acquire+0x17a8/0x2180
[    2.311089]  [<ffffffff81099fda>] lock_acquire+0x6a/0x90
[    2.311089]  [<ffffffff81099fda>] lock_acquire+0x6a/0x90
[    2.311089]  [<ffffffff813ef48d>] ? rhashtable_rehash+0xfd/0x1a0
[    2.311089]  [<ffffffff813ef48d>] ? rhashtable_rehash+0xfd/0x1a0
[    2.311089]  [<ffffffff81eb1cba>] ? test_rht_init+0xe8/0x37d
[    2.311089]  [<ffffffff81eb1cba>] ? test_rht_init+0xe8/0x37d
[    2.311089]  [<ffffffff817c7377>] _raw_spin_lock+0x37/0x70
[    2.311089]  [<ffffffff817c7377>] _raw_spin_lock+0x37/0x70
[    2.311089]  [<ffffffff813ef48d>] ? rhashtable_rehash+0xfd/0x1a0
[    2.311089]  [<ffffffff813ef48d>] ? rhashtable_rehash+0xfd/0x1a0
[    2.311089]  [<ffffffff813ef48d>] rhashtable_rehash+0xfd/0x1a0
[    2.311089]  [<ffffffff813ef48d>] rhashtable_rehash+0xfd/0x1a0
[    2.311089]  [<ffffffff81eb1cba>] ? test_rht_init+0xe8/0x37d
[    2.311089]  [<ffffffff81eb1cba>] ? test_rht_init+0xe8/0x37d
[    2.311089]  [<ffffffff81eb1bd2>] ? test_rht_lookup+0xca/0xca
[    2.311089]  [<ffffffff81eb1bd2>] ? test_rht_lookup+0xca/0xca
[    2.311089]  [<ffffffff813eff12>] rhashtable_expand+0x42/0x70
[    2.311089]  [<ffffffff813eff12>] rhashtable_expand+0x42/0x70
[    2.311089]  [<ffffffff81eb1d3a>] test_rht_init+0x168/0x37d
[    2.311089]  [<ffffffff81eb1d3a>] test_rht_init+0x168/0x37d
[    2.311089]  [<ffffffff81124838>] ? kfree+0xa8/0x110
[    2.311089]  [<ffffffff81124838>] ? kfree+0xa8/0x110
[    2.311089]  [<ffffffff813f19c0>] ? test_fw_misc_read+0x60/0x60
[    2.311089]  [<ffffffff813f19c0>] ? test_fw_misc_read+0x60/0x60
[    2.311089]  [<ffffffff810002a4>] do_one_initcall+0x84/0x1c0
[    2.311089]  [<ffffffff810002a4>] do_one_initcall+0x84/0x1c0
[    2.311089]  [<ffffffff81e930c4>] kernel_init_freeable+0x1eb/0x273
[    2.311089]  [<ffffffff81e930c4>] kernel_init_freeable+0x1eb/0x273
[    2.311089]  [<ffffffff817bcef0>] ? rest_init+0xc0/0xc0
[    2.311089]  [<ffffffff817bcef0>] ? rest_init+0xc0/0xc0
[    2.311089]  [<ffffffff817bcef9>] kernel_init+0x9/0xf0
[    2.311089]  [<ffffffff817bcef9>] kernel_init+0x9/0xf0
[    2.311089]  [<ffffffff817c8297>] ret_from_fork+0x57/0x90
[    2.311089]  [<ffffffff817c8297>] ret_from_fork+0x57/0x90
[    2.311089]  [<ffffffff817bcef0>] ? rest_init+0xc0/0xc0
[    2.311089]  [<ffffffff817bcef0>] ? rest_init+0xc0/0xc0
[    2.566279]   Verifying lookups...
[    2.566279]   Verifying lookups...
[    2.570044]   Table expansion iteration 1...
[    2.570044]   Table expansion iteration 1...
[    2.572593]   Verifying lookups...
[    2.572593]   Verifying lookups...
[    2.575489]   Table expansion iteration 2...
[    2.575489]   Table expansion iteration 2...
[    2.580751]   Verifying lookups...
[    2.580751]   Verifying lookups...
[    2.582970]   Table expansion iteration 3...
[    2.582970]   Table expansion iteration 3...
[    2.585217]   Verifying lookups...
[    2.585217]   Verifying lookups...
[    2.587226]   Table shrinkage iteration 0...
[    2.587226]   Table shrinkage iteration 0...
[    2.589393]   Verifying lookups...
[    2.589393]   Verifying lookups...
[    2.604802]   Table shrinkage iteration 1...
[    2.604802]   Table shrinkage iteration 1...
[    2.607064]   Verifying lookups...
[    2.607064]   Verifying lookups...
[    2.609694]   Table shrinkage iteration 2...
[    2.609694]   Table shrinkage iteration 2...
[    2.611952]   Verifying lookups...
[    2.611952]   Verifying lookups...
[    2.646479]   Table shrinkage iteration 3...
[    2.646479]   Table shrinkage iteration 3...
[    2.648757]   Verifying lookups...
[    2.648757]   Verifying lookups...
[    2.653689]   Traversal complete: counted=3D2048, nelems=3D2048, entries=
=3D2048
[    2.653689]   Traversal complete: counted=3D2048, nelems=3D2048, entries=
=3D2048
[    2.656610]   Deleting 2048 keys
[    2.656610]   Deleting 2048 keys
[    2.671687] pci_hotplug: PCI Hot Plug PCI Core version: 0.5
[    2.671687] pci_hotplug: PCI Hot Plug PCI Core version: 0.5
[    2.674191] input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/inpu=
t/input0
[    2.674191] input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/inpu=
t/input0
[    2.676559] ACPI: Power Button [PWRF]
[    2.676559] ACPI: Power Button [PWRF]
[    2.678438] r3964: Philips r3964 Driver $Revision: 1.10 $
[    2.678438] r3964: Philips r3964 Driver $Revision: 1.10 $
[    2.681002] Serial: 8250/16550 driver, 4 ports, IRQ sharing disabled
[    2.681002] Serial: 8250/16550 driver, 4 ports, IRQ sharing disabled
[    2.753634] 00:05: ttyS0 at I/O 0x3f8 (irq =3D 4, base_baud =3D 115200) =
is a 16550A
[    2.753634] 00:05: ttyS0 at I/O 0x3f8 (irq =3D 4, base_baud =3D 115200) =
is a 16550A
[    2.757203] Non-volatile memory driver v1.3
[    2.757203] Non-volatile memory driver v1.3
[    2.758771] telclk_interrupt =3D 0xf non-mcpbl0010 hw.
[    2.758771] telclk_interrupt =3D 0xf non-mcpbl0010 hw.
[    2.760658] parport_pc 00:04: reported by Plug and Play ACPI
[    2.760658] parport_pc 00:04: reported by Plug and Play ACPI
[    2.762797] parport0: PC-style at 0x378
[    2.762797] parport0: PC-style at 0x378, irq 7, irq 7 [ [PCSPPPCSPP(,...=
)(,...)]
]
[    2.765940] ibmasm: IBM ASM Service Processor Driver version 1.0 loaded
[    2.765940] ibmasm: IBM ASM Service Processor Driver version 1.0 loaded
[    2.769275] mic_init not running on X100 ret -19
[    2.769275] mic_init not running on X100 ret -19
[    2.784771] usbcore: registered new interface driver rtsx_usb
[    2.784771] usbcore: registered new interface driver rtsx_usb
[    2.787871] usbcore: registered new interface driver viperboard
[    2.787871] usbcore: registered new interface driver viperboard
[    2.791040] Adaptec aacraid driver 1.2-0[30300]-ms
[    2.791040] Adaptec aacraid driver 1.2-0[30300]-ms
[    2.793382] 3ware Storage Controller device driver for Linux v1.26.02.00=
3.
[    2.793382] 3ware Storage Controller device driver for Linux v1.26.02.00=
3.
[    2.796726] ipr: IBM Power RAID SCSI Device Driver version: 2.6.0 (Novem=
ber 16, 2012)
[    2.796726] ipr: IBM Power RAID SCSI Device Driver version: 2.6.0 (Novem=
ber 16, 2012)
[    2.800525] RocketRAID 3xxx/4xxx Controller driver v1.8
[    2.800525] RocketRAID 3xxx/4xxx Controller driver v1.8
[    2.803114] VMware PVSCSI driver - version 1.0.5.0-k
[    2.803114] VMware PVSCSI driver - version 1.0.5.0-k
[    2.805260] st: Version 20101219, fixed bufsize 32768, s/g segs 256
[    2.805260] st: Version 20101219, fixed bufsize 32768, s/g segs 256
[    2.808550] Rounding down aligned max_sectors from 4294967295 to 4294967=
288
[    2.808550] Rounding down aligned max_sectors from 4294967295 to 4294967=
288
[    2.928159] parport0: AVR Butterfly
[    2.928159] parport0: AVR Butterfly
[    2.929449] parport0: cannot grant exclusive access for device spi-lm70l=
lp
[    2.929449] parport0: cannot grant exclusive access for device spi-lm70l=
lp
[    2.931856] spi-lm70llp: spi_lm70llp probe fail, status -12
[    2.931856] spi-lm70llp: spi_lm70llp probe fail, status -12
[    2.933963] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
[    2.933963] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
[    2.936031] ehci-pci: EHCI PCI platform driver
[    2.936031] ehci-pci: EHCI PCI platform driver
[    2.937526] ehci-platform: EHCI generic platform driver
[    2.937526] ehci-platform: EHCI generic platform driver
[    2.939310] driver u132_hcd
[    2.939310] driver u132_hcd
[    2.940385] usbcore: registered new interface driver cdc_acm
[    2.940385] usbcore: registered new interface driver cdc_acm
[    2.942319] cdc_acm: USB Abstract Control Model driver for USB modems an=
d ISDN adapters
[    2.942319] cdc_acm: USB Abstract Control Model driver for USB modems an=
d ISDN adapters
[    2.944924] usbcore: registered new interface driver usb-storage
[    2.944924] usbcore: registered new interface driver usb-storage
[    2.946843] usbcore: registered new interface driver ums-alauda
[    2.946843] usbcore: registered new interface driver ums-alauda
[    2.948858] usbcore: registered new interface driver ums-freecom
[    2.948858] usbcore: registered new interface driver ums-freecom
[    2.950884] usbcore: registered new interface driver ums-jumpshot
[    2.950884] usbcore: registered new interface driver ums-jumpshot
[    2.952840] usbcore: registered new interface driver adutux
[    2.952840] usbcore: registered new interface driver adutux
[    2.954838] ftdi_elan: driver ftdi-elan
[    2.954838] ftdi_elan: driver ftdi-elan
[    2.956156] usbcore: registered new interface driver ftdi-elan
[    2.956156] usbcore: registered new interface driver ftdi-elan
[    2.958065] usbcore: registered new interface driver yurex
[    2.958065] usbcore: registered new interface driver yurex
[    2.959872] i8042: PNP: PS/2 Controller [PNP0303:KBD,PNP0f13:MOU] at 0x6=
0,0x64 irq 1,12
[    2.959872] i8042: PNP: PS/2 Controller [PNP0303:KBD,PNP0f13:MOU] at 0x6=
0,0x64 irq 1,12
[    2.963290] serio: i8042 KBD port at 0x60,0x64 irq 1
[    2.963290] serio: i8042 KBD port at 0x60,0x64 irq 1
[    2.964894] serio: i8042 AUX port at 0x60,0x64 irq 12
[    2.964894] serio: i8042 AUX port at 0x60,0x64 irq 12
[    2.966526] parport0: cannot grant exclusive access for device parkbd
[    2.966526] parport0: cannot grant exclusive access for device parkbd
[    2.968787] usbcore: registered new interface driver usb_acecad
[    2.968787] usbcore: registered new interface driver usb_acecad
[    2.970681] usbcore: registered new interface driver aiptek
[    2.970681] usbcore: registered new interface driver aiptek
[    2.972507] usbcore: registered new interface driver hanwang
[    2.972507] usbcore: registered new interface driver hanwang
[    2.974297] usbcore: registered new interface driver kbtab
[    2.974297] usbcore: registered new interface driver kbtab
[    2.976217] usbcore: registered new interface driver ati_remote2
[    2.976217] usbcore: registered new interface driver ati_remote2
[    2.978089] cm109: Keymap for Komunikate KIP1000 phone loaded
[    2.978089] cm109: Keymap for Komunikate KIP1000 phone loaded
[    2.979899] usbcore: registered new interface driver cm109
[    2.979899] usbcore: registered new interface driver cm109
[    2.981612] cm109: CM109 phone driver: 20080805 (C) Alfred E. Heggestad
[    2.981612] cm109: CM109 phone driver: 20080805 (C) Alfred E. Heggestad
[    2.983903] input: PC Speaker as /devices/platform/pcspkr/input/input1
[    2.983903] input: PC Speaker as /devices/platform/pcspkr/input/input1
[    2.985996] usbcore: registered new interface driver powermate
[    2.985996] usbcore: registered new interface driver powermate
[    2.987860] usbcore: registered new interface driver yealink
[    2.987860] usbcore: registered new interface driver yealink
[    2.989782] i2c-parport: adapter type unspecified
[    2.989782] i2c-parport: adapter type unspecified
[    2.991174] smssdio: Siano SMS1xxx SDIO driver
[    2.991174] smssdio: Siano SMS1xxx SDIO driver
[    2.992508] smssdio: Copyright Pierre Ossman
[    2.992508] smssdio: Copyright Pierre Ossman
[    2.993805] usbcore: registered new interface driver radioshark2
[    2.993805] usbcore: registered new interface driver radioshark2
[    2.995529] usbcore: registered new interface driver radio-mr800
[    2.995529] usbcore: registered new interface driver radio-mr800
[    2.997388] usbcore: registered new interface driver radio-ma901
[    2.997388] usbcore: registered new interface driver radio-ma901
[    2.999220] pps pps0: new PPS source ktimer
[    2.999220] pps pps0: new PPS source ktimer
[    3.000432] pps pps0: ktimer PPS source registered
[    3.000432] pps pps0: ktimer PPS source registered
[    3.002063] Driver 'mmcblk' needs updating - please use bus_type methods
[    3.002063] Driver 'mmcblk' needs updating - please use bus_type methods
[    3.004502] input: AT Translated Set 2 keyboard as /devices/platform/i80=
42/serio0/input/input2
[    3.004502] input: AT Translated Set 2 keyboard as /devices/platform/i80=
42/serio0/input/input2
[    3.007446] ledtrig-cpu: registered to indicate activity on CPUs
[    3.007446] ledtrig-cpu: registered to indicate activity on CPUs
[    3.009558] FPGA DOWNLOAD --->
[    3.009558] FPGA DOWNLOAD --->
[    3.010589] FPGA image file name: xlinx_fpga_firmware.bit
[    3.010589] FPGA image file name: xlinx_fpga_firmware.bit
[    3.012457] GPIO INIT FAIL!!
[    3.012457] GPIO INIT FAIL!!
[    3.013483] I2O subsystem v1.325
[    3.013483] I2O subsystem v1.325
[    3.014611] i2o: max drivers =3D 8
[    3.014611] i2o: max drivers =3D 8
[    3.015807] I2O Bus Adapter OSM v1.317
[    3.015807] I2O Bus Adapter OSM v1.317
[    3.017102] I2O ProcFS OSM v1.316
[    3.017102] I2O ProcFS OSM v1.316
[    3.019655] ... APIC ID:      00000000 (0)
[    3.019655] ... APIC ID:      00000000 (0)
[    3.021070] ... APIC VERSION: 01050014
[    3.021070] ... APIC VERSION: 01050014
[    3.021070] 00000000
[    3.021070] 000000000000000000000000000000000000000000000000000000000000=
000000000000000000000000000000000000000000000000000000000000

[    3.021070] 00000000
[    3.021070] 000000000e2000000e200000000000000000000000000000000000000000=
000000000000000000000000000000000000000000000000000000000000

[    3.021070] 00000000
[    3.021070] 000000000000000000000000000000000000000000000000000000000000=
000000000000000000000000000000000000000000000000800000008000

[    3.021070]=20
[    3.021070]=20
[    3.030923] number of MP IRQ sources: 15.
[    3.030923] number of MP IRQ sources: 15.
[    3.032267] number of IO-APIC #0 registers: 24.
[    3.032267] number of IO-APIC #0 registers: 24.
[    3.033232] testing the IO APIC.......................
[    3.033232] testing the IO APIC.......................
[    3.034350] IO APIC #0......
[    3.034350] IO APIC #0......
[    3.035022] .... register #00: 00000000
[    3.035022] .... register #00: 00000000
[    3.036358] .......    : physical APIC id: 00
[    3.036358] .......    : physical APIC id: 00
[    3.037767] .......    : Delivery Type: 0
[    3.037767] .......    : Delivery Type: 0
[    3.039150] .......    : LTS          : 0
[    3.039150] .......    : LTS          : 0
[    3.040499] .... register #01: 00170011
[    3.040499] .... register #01: 00170011
[    3.041793] .......     : max redirection entries: 17
[    3.041793] .......     : max redirection entries: 17
[    3.043479] .......     : PRQ implemented: 0
[    3.043479] .......     : PRQ implemented: 0
[    3.044948] .......     : IO APIC version: 11
[    3.044948] .......     : IO APIC version: 11
[    3.046390] .... register #02: 00000000
[    3.046390] .... register #02: 00000000
[    3.047660] .......     : arbitration: 00
[    3.047660] .......     : arbitration: 00
[    3.049010] .... IRQ redirection table:
[    3.049010] .... IRQ redirection table:
[    3.050193] 1    0    0   0   0    0    0    00
[    3.050193] 1    0    0   0   0    0    0    00
[    3.051524] 0    0    0   0   0    1    1    31
[    3.051524] 0    0    0   0   0    1    1    31
[    3.053219] 0    0    0   0   0    1    1    30
[    3.053219] 0    0    0   0   0    1    1    30
[    3.054845] 0    0    0   0   0    1    1    33
[    3.054845] 0    0    0   0   0    1    1    33
[    3.056544] 1    0    0   0   0    1    1    34
[    3.056544] 1    0    0   0   0    1    1    34
[    3.058193] 1    1    0   0   0    1    1    35
[    3.058193] 1    1    0   0   0    1    1    35
[    3.059829] 0    0    0   0   0    1    1    36
[    3.059829] 0    0    0   0   0    1    1    36
[    3.061502] 0    0    0   0   0    1    1    37
[    3.061502] 0    0    0   0   0    1    1    37
[    3.063160] 0    0    0   0   0    1    1    38
[    3.063160] 0    0    0   0   0    1    1    38
[    3.064799] 0    1    0   0   0    1    1    39
[    3.064799] 0    1    0   0   0    1    1    39
[    3.066401] 1    1    0   0   0    1    1    3A
[    3.066401] 1    1    0   0   0    1    1    3A
[    3.068086] 1    1    0   0   0    1    1    3B
[    3.068086] 1    1    0   0   0    1    1    3B
[    3.069722] 0    0    0   0   0    1    1    3C
[    3.069722] 0    0    0   0   0    1    1    3C
[    3.071380] 0    0    0   0   0    1    1    3D
[    3.071380] 0    0    0   0   0    1    1    3D
[    3.073042] 0    0    0   0   0    1    1    3E
[    3.073042] 0    0    0   0   0    1    1    3E
[    3.074702] 0    0    0   0   0    1    1    3F
[    3.074702] 0    0    0   0   0    1    1    3F
[    3.076351] 1    0    0   0   0    0    0    00
[    3.076351] 1    0    0   0   0    0    0    00
[    3.078014] 1    0    0   0   0    0    0    00
[    3.078014] 1    0    0   0   0    0    0    00
[    3.079691] 1    0    0   0   0    0    0    00
[    3.079691] 1    0    0   0   0    0    0    00
[    3.081340] 1    0    0   0   0    0    0    00
[    3.081340] 1    0    0   0   0    0    0    00
[    3.083038] 1    0    0   0   0    0    0    00
[    3.083038] 1    0    0   0   0    0    0    00
[    3.084676] 1    0    0   0   0    0    0    00
[    3.084676] 1    0    0   0   0    0    0    00
[    3.086343] 1    0    0   0   0    0    0    00
[    3.086343] 1    0    0   0   0    0    0    00
[    3.094625] 1    0    0   0   0    0    0    00
[    3.094625] 1    0    0   0   0    0    0    00
[    3.096006] IRQ to pin mappings:
[    3.096006] IRQ to pin mappings:
[    3.096985] IRQ0=20
[    3.096985] IRQ0 -> 0:2-> 0:2

[    3.097781] IRQ1=20
[    3.097781] IRQ1 -> 0:1-> 0:1

[    3.098968] IRQ3=20
[    3.098968] IRQ3 -> 0:3-> 0:3

[    3.100203] IRQ4=20
[    3.100203] IRQ4 -> 0:4-> 0:4

[    3.101494] IRQ5=20
[    3.101494] IRQ5 -> 0:5-> 0:5

[    3.102832] IRQ6=20
[    3.102832] IRQ6 -> 0:6-> 0:6

[    3.104078] IRQ7=20
[    3.104078] IRQ7 -> 0:7-> 0:7

[    3.105321] IRQ8=20
[    3.105321] IRQ8 -> 0:8-> 0:8

[    3.106585] IRQ9=20
[    3.106585] IRQ9 -> 0:9-> 0:9

[    3.107879] IRQ10=20
[    3.107879] IRQ10 -> 0:10-> 0:10

[    3.109205] IRQ11=20
[    3.109205] IRQ11 -> 0:11-> 0:11

[    3.110519] IRQ12=20
[    3.110519] IRQ12 -> 0:12-> 0:12

[    3.111888] IRQ13=20
[    3.111888] IRQ13 -> 0:13-> 0:13

[    3.113277] IRQ14=20
[    3.113277] IRQ14 -> 0:14-> 0:14

[    3.114732] IRQ15=20
[    3.114732] IRQ15 -> 0:15-> 0:15

[    3.116085] .................................... done.
[    3.116085] .................................... done.
[    3.118831] bootconsole [earlyser0] disabled
[    3.118831] bootconsole [earlyser0] disabled
[    3.120903] Loading compiled-in X.509 certificates
[    3.123388] Loaded X.509 cert 'Magrathea: Glacier signing key: 64040449f=
a3a145833ba528e41d155e7093a9c45'
[    3.125900] tsc: Refined TSC clocksource calibration: 2926.000 MHz
[    3.127649] Btrfs loaded, integrity-checker=3Don
[    3.129127] ALSA device list:
[    3.129836]   No soundcards found.
[    3.131552] Freeing unused kernel memory: 764K (ffffffff81e92000 - fffff=
fff81f51000)
[    3.133475] Write protecting the kernel read-only data: 12288k
[    3.135200] Freeing unused kernel memory: 200K (ffff8800017ce000 - ffff8=
80001800000)
[    3.137408] Freeing unused kernel memory: 248K (ffff880001bc2000 - ffff8=
80001c00000)
[    3.145026] random: init urandom read with 2 bits of entropy available
mount: unknown filesystem type 'devpts'
mountall: mount /dev/pts [2148] terminated with status 32
mountall: Filesystem could not be mounted: /dev/pts
mountall: Skipping mounting /dev/pts since Plymouth is not available
udevd[2186]: error creating signalfd
udevd[2197]: error creating signalfd
udevd[2199]: error creating signalfd
udevd[2201]: error creating signalfd
udevd[2204]: error creating signalfd
udevd[2210]: error creating signalfd
udevd[2213]: error creating signalfd
udevd[2218]: error creating signalfd
udevd[2227]: error creating signalfd
udevd[2229]: error creating signalfd
udevd[2232]: error creating signalfd
Kernel tests: Boot OK!
Trinity v1.4pre  Dave Jones <davej@redhat.com>
[init] Marking syscall get_robust_list (64bit:274 32bit:312) as to be disab=
led.
Done parsing arguments.
Marking all syscalls as enabled.
[init] Disabling syscalls marked as disabled by command line options
[init] Marked 64-bit syscall get_robust_list (274) as deactivated.
[init] Marked 32-bit syscall get_robust_list (312) as deactivated.
[init] 32-bit syscalls: 350 enabled, 1 disabled.  64-bit syscalls: 313 enab=
led, 1 disabled.
DANGER: RUNNING AS ROOT.
Unless you are running in a virtual machine, this could cause serious probl=
ems such as overwriting CMOS
or similar which could potentially make this machine unbootable without a f=
irmware reset.

ctrl-c now unless you really know what you are doing.
[init] Started watchdog process, PID is 25217
[main] Main thread is alive.
[main] Setsockopt(1 1d 693000 4) on fd 6 [1:1:1]
[main] Setsockopt(1 7 693000 4) on fd 7 [1:5:1]
[main] Setsockopt(1 1 693000 4) on fd 9 [16:3:0]
[main] Setsockopt(1 29 693000 70) on fd 10 [1:5:1]
[main] Setsockopt(10e 3 693000 4) on fd 11 [16:3:4]
[main] Setsockopt(1 10 693000 96) on fd 13 [1:5:1]
[main] Setsockopt(1 20 693000 4) on fd 14 [16:2:16]
[main] Setsockopt(1 24 693000 4) on fd 15 [1:5:1]
[main] Setsockopt(1 9 693000 4) on fd 16 [1:5:1]
[main] Setsockopt(1 2a 693000 4) on fd 17 [1:5:1]
[main] Setsockopt(1 1d 693000 9b) on fd 18 [1:1:1]
[main] Setsockopt(1 28 693000 4) on fd 19 [16:3:4]
[main] Setsockopt(1 24 693000 4) on fd 20 [1:2:1]
[main] Setsockopt(1 d 693000 8) on fd 21 [1:1:1]
[main] Setsockopt(1 5 693000 4) on fd 25 [1:2:1]
[main] Setsockopt(1 28 693000 4) on fd 26 [1:1:1]
[main] Setsockopt(10e 5 693000 c7) on fd 27 [16:3:2]
[main] Setsockopt(1 d 693000 8) on fd 30 [1:2:1]
[main] Setsockopt(1 2c 693000 4) on fd 32 [1:2:1]
[main] Setsockopt(1 10 693000 bb) on fd 33 [1:5:1]
[main] Setsockopt(1 1d 693000 be) on fd 35 [1:2:1]
[main] Setsockopt(1 a 693000 54) on fd 36 [16:2:15]
[main] Setsockopt(1 6 693000 ea) on fd 37 [1:2:1]
[main] Setsockopt(1 a 693000 4) on fd 40 [1:1:1]
[main] Setsockopt(10e 4 693000 4) on fd 41 [16:2:15]
[main] Setsockopt(1 2a 693000 4) on fd 42 [1:2:1]
[main] Setsockopt(1 c 693000 4) on fd 45 [1:5:1]
[main] Setsockopt(1 1d 693000 4) on fd 47 [1:2:1]
[main] Setsockopt(1 e 693000 4) on fd 49 [1:2:1]
[main] Setsockopt(1 c 693000 81) on fd 50 [16:3:15]
[main] Setsockopt(1 8 693000 72) on fd 51 [1:1:1]
[main] Setsockopt(10e 4 693000 e7) on fd 52 [16:3:15]
[main] Setsockopt(1 c 693000 a) on fd 54 [16:3:0]
[main] Setsockopt(1 22 693000 c0) on fd 55 [1:5:1]
[main] Setsockopt(1 24 693000 5e) on fd 57 [1:1:1]
[main] Setsockopt(1 10 693000 4) on fd 59 [1:5:1]
[main] Setsockopt(1 2d 693000 4) on fd 60 [1:1:1]
[main] Setsockopt(1 23 693000 4) on fd 61 [1:2:1]
[main] Setsockopt(1 2d 693000 4) on fd 62 [1:5:1]
[main] Setsockopt(1 24 693000 40) on fd 65 [1:5:1]
[main] Setsockopt(1 6 693000 ff) on fd 67 [1:1:1]
[main] Setsockopt(1 20 693000 35) on fd 69 [1:1:1]
[main] Setsockopt(1 1d 693000 44) on fd 70 [1:1:1]
[main] Setsockopt(1 29 693000 9d) on fd 71 [1:2:1]
[main] Setsockopt(1 20 693000 4) on fd 74 [1:1:1]
[main] Setsockopt(1 2e 693000 4) on fd 76 [16:3:0]
[main] Setsockopt(1 a 693000 88) on fd 78 [16:3:0]
[main] Setsockopt(1 1d 693000 3e) on fd 80 [16:3:2]
[main] Setsockopt(1 28 693000 4) on fd 81 [1:1:1]
[main] Setsockopt(1 9 693000 ea) on fd 82 [1:5:1]
[main] Setsockopt(1 f 693000 4) on fd 83 [1:2:1]
[main] Setsockopt(1 2e 693000 40) on fd 85 [16:2:16]
[main] Setsockopt(1 d 693000 8) on fd 86 [1:2:1]
[main] Setsockopt(1 2e 693000 4) on fd 87 [1:1:1]
[main] Setsockopt(1 25 693000 58) on fd 88 [1:5:1]
[main] Setsockopt(1 e 693000 4) on fd 95 [1:5:1]
[main] Setsockopt(10e 3 693000 f) on fd 96 [16:3:16]
[main] Setsockopt(1 20 693000 4) on fd 97 [1:1:1]
[main] Setsockopt(1 d 693000 8) on fd 98 [1:2:1]
[main] Setsockopt(1 f 693000 4) on fd 101 [16:2:15]
[main] Setsockopt(1 7 693000 20) on fd 104 [1:5:1]
[main] Setsockopt(1 21 693000 4) on fd 105 [1:2:1]
[main] Setsockopt(1 9 693000 b8) on fd 106 [1:1:1]
[main] Setsockopt(1 14 693000 10) on fd 108 [16:2:16]
[main] Setsockopt(1 15 693000 10) on fd 109 [1:1:1]
[main] Setsockopt(1 c 693000 ae) on fd 111 [16:3:0]
[main] Setsockopt(1 10 693000 4) on fd 112 [1:2:1]
[main] Setsockopt(1 2f 693000 4) on fd 116 [1:1:1]
[main] Setsockopt(1 8 693000 4) on fd 117 [1:1:1]
[main] Setsockopt(1 21 693000 bd) on fd 118 [1:5:1]
[main] Setsockopt(1 b 693000 4e) on fd 123 [1:5:1]
[main] Setsockopt(1 d 693000 8) on fd 124 [16:3:15]
[main] Setsockopt(1 7 693000 4) on fd 127 [1:5:1]
[main] Setsockopt(1 f 693000 4) on fd 131 [1:5:1]
[main] Setsockopt(1 20 693000 4) on fd 133 [1:2:1]
[main] Setsockopt(1 2f 693000 f0) on fd 134 [1:5:1]
[main] Setsockopt(1 e 693000 4) on fd 136 [1:1:1]
[main] Setsockopt(1 6 693000 2e) on fd 138 [1:5:1]
[main] Setsockopt(10e 5 693000 ed) on fd 139 [16:3:16]
[main] Setsockopt(1 23 693000 3b) on fd 142 [1:5:1]
[main] Setsockopt(1 2b 693000 6a) on fd 143 [16:2:4]
[main] Setsockopt(1 1d 693000 4b) on fd 149 [16:2:0]
[main] Setsockopt(1 8 693000 68) on fd 150 [1:1:1]
[main] Setsockopt(1 5 693000 5f) on fd 152 [1:2:1]
[main] Setsockopt(1 2a 693000 7) on fd 154 [1:2:1]
[main] Setsockopt(1 6 693000 5f) on fd 156 [1:5:1]
[main] Setsockopt(10e 5 693000 4) on fd 158 [16:2:0]
[main] Setsockopt(1 14 693000 10) on fd 160 [1:1:1]
[main] Setsockopt(1 b 693000 4) on fd 161 [1:2:1]
[main] Setsockopt(1 7 693000 4) on fd 163 [1:1:1]
[main] Setsockopt(1 28 693000 46) on fd 164 [1:2:1]
[main] Setsockopt(1 8 693000 70) on fd 167 [1:2:1]
[main] Setsockopt(1 20 693000 4) on fd 168 [1:5:1]
[main] Setsockopt(1 2c 693000 4) on fd 169 [1:5:1]
[main] Setsockopt(1 24 693000 4) on fd 172 [1:1:1]
[main] Setsockopt(1 25 693000 92) on fd 175 [1:5:1]
[main] Setsockopt(1 28 693000 12) on fd 176 [16:3:2]
[main] Setsockopt(1 2f 693000 4) on fd 178 [1:5:1]
[main] Setsockopt(1 10 693000 4) on fd 179 [1:5:1]
[main] Setsockopt(1 f 693000 4) on fd 180 [1:1:1]
[main] Setsockopt(10e 4 693000 56) on fd 181 [16:2:0]
[main] Setsockopt(10e 4 693000 4) on fd 183 [16:3:2]
[main] Setsockopt(1 2 693000 4) on fd 186 [1:5:1]
[main] Setsockopt(1 8 693000 4) on fd 187 [1:5:1]
[main] Setsockopt(1 9 693000 4) on fd 189 [16:2:15]
[main] Setsockopt(1 28 693000 4) on fd 190 [1:2:1]
[main] Setsockopt(1 23 693000 4) on fd 193 [1:2:1]
[main] Setsockopt(1 25 693000 4) on fd 195 [1:5:1]
[main] Setsockopt(1 7 693000 4) on fd 196 [16:3:0]
[main] Setsockopt(1 d 693000 8) on fd 201 [1:2:1]
[main] Setsockopt(1 29 693000 4) on fd 202 [1:5:1]
[main] Setsockopt(1 1d 693000 4) on fd 204 [1:1:1]
[main] Setsockopt(1 7 693000 4) on fd 205 [16:2:4]
[main] Setsockopt(1 24 693000 12) on fd 206 [1:5:1]
[main] Setsockopt(1 24 693000 4) on fd 208 [1:5:1]
[main] Setsockopt(1 c 693000 4) on fd 209 [1:5:1]
[main] Setsockopt(1 23 693000 6b) on fd 210 [1:1:1]
[main] Setsockopt(1 6 693000 4) on fd 211 [1:2:1]
[main] Setsockopt(1 a 693000 4) on fd 212 [1:1:1]
[main] Setsockopt(1 2c 693000 6b) on fd 213 [16:3:15]
[main] Setsockopt(1 c 693000 4) on fd 214 [1:2:1]
[main] Setsockopt(1 5 693000 b2) on fd 215 [1:1:1]
[main] Setsockopt(1 b 693000 4) on fd 216 [1:2:1]
[main] Setsockopt(1 1d 693000 4) on fd 217 [1:5:1]
[main] Setsockopt(10e 5 693000 12) on fd 218 [16:3:16]
[main] Setsockopt(1 2c 693000 4) on fd 219 [1:2:1]
[main] Setsockopt(1 d 693000 8) on fd 220 [1:2:1]
[main] Setsockopt(1 2b 693000 8d) on fd 224 [1:2:1]
[main] Setsockopt(1 2b 693000 4) on fd 225 [1:5:1]
[main] Setsockopt(1 b 693000 4) on fd 226 [1:1:1]
[main] Setsockopt(1 1 693000 4) on fd 229 [16:2:2]
[main] Setsockopt(1 2c 693000 2a) on fd 234 [1:2:1]
[main] Setsockopt(1 5 693000 4) on fd 235 [1:1:1]
[main] Setsockopt(1 f 693000 4) on fd 237 [1:2:1]
[main] Setsockopt(1 1 693000 4) on fd 239 [1:1:1]
[main] Setsockopt(1 2e 693000 18) on fd 240 [16:2:2]
[main] Setsockopt(1 12 693000 6f) on fd 242 [1:2:1]
[main] Setsockopt(1 10 693000 77) on fd 244 [1:1:1]
[main] Setsockopt(10e 5 693000 17) on fd 245 [16:3:4]
[main] Setsockopt(1 2 693000 4) on fd 247 [1:1:1]
[main] Setsockopt(10e 3 693000 49) on fd 248 [16:3:4]
[main] Setsockopt(1 c 693000 4) on fd 250 [1:5:1]
[main] Setsockopt(1 20 693000 4) on fd 251 [1:5:1]
[main] Setsockopt(1 21 693000 4) on fd 252 [16:2:2]
[main] Setsockopt(1 6 693000 4) on fd 253 [1:5:1]
[main] Setsockopt(1 9 693000 4) on fd 254 [1:5:1]
[main] Setsockopt(10e 3 693000 4) on fd 256 [16:2:2]
[main] Setsockopt(1 20 693000 ab) on fd 257 [1:2:1]
[main] Setsockopt(1 12 693000 13) on fd 258 [1:5:1]
[main] Setsockopt(10e 4 693000 3c) on fd 260 [16:3:16]
[main] Setsockopt(1 a 693000 4) on fd 263 [1:5:1]
[main] Setsockopt(1 2f 693000 cd) on fd 265 [16:3:4]
[main] Setsockopt(10e 4 693000 c9) on fd 268 [16:3:16]
[main] Setsockopt(1 2b 693000 4) on fd 270 [1:5:1]
[main] Setsockopt(1 10 693000 4) on fd 278 [1:5:1]
[main] Setsockopt(1 2a 693000 54) on fd 279 [1:5:1]
[main] Setsockopt(1 d 693000 8) on fd 280 [1:2:1]
[main] Setsockopt(10e 4 693000 4) on fd 281 [16:3:4]
[main] Setsockopt(1 28 693000 67) on fd 284 [1:2:1]
[main] Setsockopt(10e 4 693000 54) on fd 285 [16:2:2]
[main] Setsockopt(1 1d 693000 4) on fd 286 [1:5:1]
[main] Setsockopt(1 2e 693000 4) on fd 287 [16:3:2]
[main] Setsockopt(1 22 693000 b4) on fd 288 [1:2:1]
[main] Setsockopt(1 8 693000 4) on fd 290 [1:1:1]
[main] Setsockopt(10e 2 693000 c5) on fd 293 [16:2:16]
[main] Setsockopt(1 29 693000 4) on fd 294 [1:2:1]
[main] Setsockopt(1 23 693000 5a) on fd 296 [1:5:1]
[main] Setsockopt(1 12 693000 4) on fd 299 [1:2:1]
[main] Setsockopt(1 2c 693000 8) on fd 300 [1:1:1]
[main] Setsockopt(1 2e 693000 4) on fd 301 [1:2:1]
[main] Setsockopt(1 d 693000 8) on fd 303 [1:2:1]
[main] Setsockopt(1 a 693000 4) on fd 306 [16:2:16]
[main] Setsockopt(1 2e 693000 c) on fd 307 [1:2:1]
[main] Setsockopt(1 d 693000 8) on fd 310 [16:3:16]
[main] Setsockopt(1 20 693000 47) on fd 312 [1:2:1]
[main] Setsockopt(1 8 693000 34) on fd 315 [1:1:1]
[main] Setsockopt(1 2c 693000 e4) on fd 317 [1:5:1]
[main] Setsockopt(10e 5 693000 4) on fd 318 [16:3:0]
[main] Setsockopt(1 c 693000 b4) on fd 320 [1:2:1]
[main] Setsockopt(1 2e 693000 4) on fd 321 [1:2:1]
[main] Setsockopt(1 f 693000 4) on fd 322 [1:5:1]
[main] Setsockopt(1 2e 693000 4) on fd 323 [1:5:1]
[main] Setsockopt(1 21 693000 33) on fd 324 [1:1:1]
[main] Setsockopt(1 7 693000 57) on fd 325 [1:2:1]
[main] Setsockopt(1 2 693000 4) on fd 326 [1:1:1]
[main] Setsockopt(1 2a 693000 4) on fd 327 [1:5:1]
[main] Setsockopt(1 e 693000 4) on fd 329 [16:3:15]
[main] Setsockopt(1 29 693000 4) on fd 334 [16:2:2]
[main] Setsockopt(1 2c 693000 67) on fd 335 [1:5:1]
[main] Setsockopt(1 6 693000 4) on fd 340 [1:2:1]
[main] Setsockopt(1 23 693000 4) on fd 341 [1:1:1]
[main] Setsockopt(1 1 693000 ec) on fd 342 [1:5:1]
[main] Setsockopt(1 1 693000 4) on fd 343 [1:5:1]
[main] Setsockopt(1 1 693000 ca) on fd 347 [1:2:1]
[main] Setsockopt(1 5 693000 4) on fd 348 [16:3:0]
[main] Setsockopt(1 b 693000 4) on fd 350 [1:1:1]
[main] Setsockopt(1 f 693000 4) on fd 351 [1:1:1]
[main] Setsockopt(1 10 693000 17) on fd 352 [1:5:1]
[main] Setsockopt(1 21 693000 69) on fd 354 [1:2:1]
[main] Setsockopt(1 b 693000 4) on fd 355 [1:5:1]
[main] Setsockopt(1 f 693000 4) on fd 356 [1:1:1]
[main] Setsockopt(1 5 693000 6) on fd 357 [1:2:1]
[main] Setsockopt(10e 1 693000 4) on fd 358 [16:3:15]
[main] Setsockopt(1 29 693000 8b) on fd 359 [1:2:1]
[main] Setsockopt(1 2 693000 4) on fd 360 [1:1:1]
[main] Setsockopt(10e 4 693000 56) on fd 361 [16:2:16]
[main] Setsockopt(1 2f 693000 c) on fd 364 [1:5:1]
[main] Setsockopt(1 e 693000 4) on fd 366 [1:1:1]
[main] Setsockopt(1 15 693000 10) on fd 367 [1:1:1]
[main] Setsockopt(1 8 693000 a0) on fd 368 [1:5:1]
[main] Setsockopt(1 f 693000 4) on fd 370 [1:1:1]
[main] Setsockopt(1 2c 693000 4) on fd 371 [1:2:1]
[main] Setsockopt(1 2a 693000 ec) on fd 373 [1:2:1]
[main] Setsockopt(1 28 693000 7) on fd 374 [1:1:1]
[main] Setsockopt(1 2e 693000 4) on fd 376 [1:5:1]
[main] Setsockopt(10e 4 693000 4) on fd 377 [16:2:0]
[main] Setsockopt(1 12 693000 4) on fd 380 [1:1:1]
[main] 375 sockets created based on info from socket cachefile.
[main] Generating file descriptors
[main] Added 169 filenames from /dev
[main] Added 7346 filenames from /proc
[main] Added 3372 filenames from /sys
[child0:25231] mbind (237) returned ENOSYS, marking as inactive.
[child0:25231] process_vm_readv (310) returned ENOSYS, marking as inactive.
[child0:25231] semget (64) returned ENOSYS, marking as inactive.
[child0:25231] shmdt (67) returned ENOSYS, marking as inactive.
[child0:25231] msgsnd (69) returned ENOSYS, marking as inactive.
[child0:25231] mq_timedreceive (243) returned ENOSYS, marking as inactive.
[child0:25231] geteuid16 (49) returned ENOSYS, marking as inactive.
[child0:25231] semtimedop (220) returned ENOSYS, marking as inactive.
[child0:25231] timerfd_gettime (287) returned ENOSYS, marking as inactive.
[child0:25231] shmat (30) returned ENOSYS, marking as inactive.
[child0:25231] mq_timedsend (242) returned ENOSYS, marking as inactive.
[child0:25231] uid changed! Was: 0, now 70
Bailing main loop. Exit reason: UID changed.
[watchdog] [25217] Watchdog exiting
[init]=20
Ran 106 syscalls. Successes: 27  Failures: 79
[   62.200040] Writes:  Total: 2  Max/Min: 0/0   Fail: 0=20
error: 'rc.local' exited outside the expected code flow.
umount: /run/lock: not mounted
 * Will now restart
[   63.313994] spin_lock-torture: Unscheduled system shutdown detected
[   63.314877] reboot: Restarting system
Elapsed time: 75
qemu-system-x86_64 -cpu kvm64 -enable-kvm -kernel /kernel/x86_64-randconfig=
-iv1-03120156/aa34a6cb0478842452bac58edb50d3ef9e178c92/vmlinuz-4.0.0-rc3-00=
505-gaa34a6c -append 'hung_task_panic=3D1 earlyprintk=3DttyS0,115200 rd.ude=
v.log-priority=3Derr systemd.log_target=3Djournal systemd.log_level=3Dwarni=
ng debug apic=3Ddebug sysrq_always_enabled rcupdate.rcu_cpu_stall_timeout=
=3D100 panic=3D-1 softlockup_panic=3D1 nmi_watchdog=3Dpanic oops=3Dpanic lo=
ad_ramdisk=3D2 prompt_ramdisk=3D0 console=3DttyS0,115200 console=3Dtty0 vga=
=3Dnormal  root=3D/dev/ram0 rw link=3D/kbuild-tests/run-queue/kvm/x86_64-ra=
ndconfig-iv1-03120156/net-next:master:aa34a6cb0478842452bac58edb50d3ef9e178=
c92:bisect-linux-0/.vmlinuz-aa34a6cb0478842452bac58edb50d3ef9e178c92-201503=
12085959-7-client9 branch=3Dnet-next/master BOOT_IMAGE=3D/kernel/x86_64-ran=
dconfig-iv1-03120156/aa34a6cb0478842452bac58edb50d3ef9e178c92/vmlinuz-4.0.0=
-rc3-00505-gaa34a6c drbd.minor_count=3D8'  -initrd /kernel-tests/initrd/qua=
ntal-core-x86_64.cgz -m 320 -smp 2 -net nic,vlan=3D1,model=3De1000 -net use=
r,vlan=3D1 -boot order=3Dnc -no-reboot -watchdog i6300esb -rtc base=3Dlocal=
time -pidfile /dev/shm/kboot/pid-quantal-client9-13 -serial file:/dev/shm/k=
boot/serial-quantal-client9-13 -daemonize -display none -monitor null=20

--YiEDa0DAkWCtVeE4
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="config-4.0.0-rc3-00505-gaa34a6c"

#
# Automatically generated file; DO NOT EDIT.
# Linux/x86_64 4.0.0-rc3 Kernel Configuration
#
CONFIG_64BIT=y
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
# CONFIG_KERNEL_LZO is not set
CONFIG_KERNEL_LZ4=y
CONFIG_DEFAULT_HOSTNAME="(none)"
# CONFIG_SWAP is not set
# CONFIG_SYSVIPC is not set
# CONFIG_POSIX_MQUEUE is not set
# CONFIG_CROSS_MEMORY_ATTACH is not set
CONFIG_FHANDLE=y
# CONFIG_USELIB is not set
# CONFIG_AUDIT is not set
CONFIG_HAVE_ARCH_AUDITSYSCALL=y

#
# IRQ subsystem
#
CONFIG_GENERIC_IRQ_PROBE=y
CONFIG_GENERIC_IRQ_SHOW=y
CONFIG_GENERIC_IRQ_LEGACY_ALLOC_HWIRQ=y
CONFIG_GENERIC_IRQ_CHIP=y
CONFIG_IRQ_DOMAIN=y
CONFIG_GENERIC_MSI_IRQ=y
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
# CONFIG_HIGH_RES_TIMERS is not set

#
# CPU/Task time and stats accounting
#
CONFIG_TICK_CPU_ACCOUNTING=y
# CONFIG_VIRT_CPU_ACCOUNTING_GEN is not set
# CONFIG_IRQ_TIME_ACCOUNTING is not set
# CONFIG_BSD_PROCESS_ACCT is not set
# CONFIG_TASKSTATS is not set

#
# RCU Subsystem
#
CONFIG_TINY_RCU=y
CONFIG_SRCU=y
CONFIG_TASKS_RCU=y
CONFIG_RCU_STALL_COMMON=y
# CONFIG_TREE_RCU_TRACE is not set
CONFIG_RCU_KTHREAD_PRIO=0
CONFIG_BUILD_BIN2C=y
CONFIG_IKCONFIG=y
# CONFIG_IKCONFIG_PROC is not set
CONFIG_LOG_BUF_SHIFT=17
CONFIG_HAVE_UNSTABLE_SCHED_CLOCK=y
CONFIG_ARCH_SUPPORTS_NUMA_BALANCING=y
CONFIG_ARCH_SUPPORTS_INT128=y
CONFIG_CGROUPS=y
# CONFIG_CGROUP_DEBUG is not set
CONFIG_CGROUP_FREEZER=y
# CONFIG_CGROUP_DEVICE is not set
CONFIG_CPUSETS=y
CONFIG_PROC_PID_CPUSET=y
# CONFIG_CGROUP_CPUACCT is not set
CONFIG_PAGE_COUNTER=y
CONFIG_MEMCG=y
# CONFIG_MEMCG_KMEM is not set
# CONFIG_CGROUP_PERF is not set
CONFIG_CGROUP_SCHED=y
CONFIG_FAIR_GROUP_SCHED=y
CONFIG_CFS_BANDWIDTH=y
# CONFIG_RT_GROUP_SCHED is not set
CONFIG_BLK_CGROUP=y
# CONFIG_DEBUG_BLK_CGROUP is not set
# CONFIG_CHECKPOINT_RESTORE is not set
# CONFIG_NAMESPACES is not set
CONFIG_SCHED_AUTOGROUP=y
# CONFIG_SYSFS_DEPRECATED is not set
CONFIG_RELAY=y
CONFIG_BLK_DEV_INITRD=y
CONFIG_INITRAMFS_SOURCE=""
CONFIG_RD_GZIP=y
CONFIG_RD_BZIP2=y
CONFIG_RD_LZMA=y
# CONFIG_RD_XZ is not set
# CONFIG_RD_LZO is not set
# CONFIG_RD_LZ4 is not set
# CONFIG_CC_OPTIMIZE_FOR_SIZE is not set
CONFIG_SYSCTL=y
CONFIG_ANON_INODES=y
CONFIG_HAVE_UID16=y
CONFIG_SYSCTL_EXCEPTION_TRACE=y
CONFIG_HAVE_PCSPKR_PLATFORM=y
CONFIG_BPF=y
CONFIG_EXPERT=y
# CONFIG_UID16 is not set
# CONFIG_SGETMASK_SYSCALL is not set
# CONFIG_SYSFS_SYSCALL is not set
CONFIG_SYSCTL_SYSCALL=y
CONFIG_KALLSYMS=y
CONFIG_KALLSYMS_ALL=y
CONFIG_PRINTK=y
CONFIG_BUG=y
CONFIG_ELF_CORE=y
CONFIG_PCSPKR_PLATFORM=y
CONFIG_BASE_FULL=y
CONFIG_FUTEX=y
CONFIG_EPOLL=y
# CONFIG_SIGNALFD is not set
# CONFIG_TIMERFD is not set
CONFIG_EVENTFD=y
CONFIG_BPF_SYSCALL=y
CONFIG_SHMEM=y
CONFIG_AIO=y
CONFIG_ADVISE_SYSCALLS=y
CONFIG_PCI_QUIRKS=y
CONFIG_EMBEDDED=y
CONFIG_HAVE_PERF_EVENTS=y
CONFIG_PERF_USE_VMALLOC=y

#
# Kernel Performance Events And Counters
#
CONFIG_PERF_EVENTS=y
CONFIG_DEBUG_PERF_USE_VMALLOC=y
CONFIG_VM_EVENT_COUNTERS=y
CONFIG_COMPAT_BRK=y
CONFIG_SLAB=y
# CONFIG_SLUB is not set
# CONFIG_SLOB is not set
CONFIG_SYSTEM_TRUSTED_KEYRING=y
# CONFIG_PROFILING is not set
CONFIG_HAVE_OPROFILE=y
CONFIG_OPROFILE_NMI_TIMER=y
CONFIG_KPROBES=y
CONFIG_JUMP_LABEL=y
CONFIG_OPTPROBES=y
# CONFIG_UPROBES is not set
# CONFIG_HAVE_64BIT_ALIGNED_ACCESS is not set
CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS=y
CONFIG_ARCH_USE_BUILTIN_BSWAP=y
CONFIG_KRETPROBES=y
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
CONFIG_HAVE_CMPXCHG_LOCAL=y
CONFIG_HAVE_CMPXCHG_DOUBLE=y
CONFIG_ARCH_WANT_COMPAT_IPC_PARSE_VERSION=y
CONFIG_ARCH_WANT_OLD_COMPAT_IPC=y
CONFIG_HAVE_ARCH_SECCOMP_FILTER=y
CONFIG_SECCOMP_FILTER=y
CONFIG_HAVE_CC_STACKPROTECTOR=y
# CONFIG_CC_STACKPROTECTOR is not set
CONFIG_CC_STACKPROTECTOR_NONE=y
# CONFIG_CC_STACKPROTECTOR_REGULAR is not set
# CONFIG_CC_STACKPROTECTOR_STRONG is not set
CONFIG_HAVE_CONTEXT_TRACKING=y
CONFIG_HAVE_VIRT_CPU_ACCOUNTING_GEN=y
CONFIG_HAVE_IRQ_TIME_ACCOUNTING=y
CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE=y
CONFIG_HAVE_ARCH_SOFT_DIRTY=y
CONFIG_MODULES_USE_ELF_RELA=y
CONFIG_HAVE_IRQ_EXIT_ON_IRQ_STACK=y
CONFIG_OLD_SIGSUSPEND3=y
CONFIG_COMPAT_OLD_SIGACTION=y

#
# GCOV-based kernel profiling
#
CONFIG_GCOV_KERNEL=y
CONFIG_ARCH_HAS_GCOV_PROFILE_ALL=y
# CONFIG_GCOV_PROFILE_ALL is not set
# CONFIG_GCOV_FORMAT_AUTODETECT is not set
# CONFIG_GCOV_FORMAT_3_4 is not set
CONFIG_GCOV_FORMAT_4_7=y
# CONFIG_HAVE_GENERIC_DMA_COHERENT is not set
CONFIG_SLABINFO=y
CONFIG_RT_MUTEXES=y
CONFIG_BASE_SMALL=0
CONFIG_MODULES=y
# CONFIG_MODULE_FORCE_LOAD is not set
# CONFIG_MODULE_UNLOAD is not set
CONFIG_MODVERSIONS=y
CONFIG_MODULE_SRCVERSION_ALL=y
CONFIG_MODULE_SIG=y
CONFIG_MODULE_SIG_FORCE=y
CONFIG_MODULE_SIG_ALL=y
# CONFIG_MODULE_SIG_SHA1 is not set
# CONFIG_MODULE_SIG_SHA224 is not set
# CONFIG_MODULE_SIG_SHA256 is not set
CONFIG_MODULE_SIG_SHA384=y
# CONFIG_MODULE_SIG_SHA512 is not set
CONFIG_MODULE_SIG_HASH="sha384"
CONFIG_MODULE_COMPRESS=y
CONFIG_MODULE_COMPRESS_GZIP=y
# CONFIG_MODULE_COMPRESS_XZ is not set
CONFIG_BLOCK=y
CONFIG_BLK_DEV_BSG=y
CONFIG_BLK_DEV_BSGLIB=y
CONFIG_BLK_DEV_INTEGRITY=y
CONFIG_BLK_DEV_THROTTLING=y
# CONFIG_BLK_CMDLINE_PARSER is not set

#
# Partition Types
#
CONFIG_PARTITION_ADVANCED=y
CONFIG_ACORN_PARTITION=y
CONFIG_ACORN_PARTITION_CUMANA=y
CONFIG_ACORN_PARTITION_EESOX=y
# CONFIG_ACORN_PARTITION_ICS is not set
CONFIG_ACORN_PARTITION_ADFS=y
# CONFIG_ACORN_PARTITION_POWERTEC is not set
# CONFIG_ACORN_PARTITION_RISCIX is not set
CONFIG_AIX_PARTITION=y
# CONFIG_OSF_PARTITION is not set
# CONFIG_AMIGA_PARTITION is not set
# CONFIG_ATARI_PARTITION is not set
CONFIG_MAC_PARTITION=y
# CONFIG_MSDOS_PARTITION is not set
CONFIG_LDM_PARTITION=y
# CONFIG_LDM_DEBUG is not set
# CONFIG_SGI_PARTITION is not set
CONFIG_ULTRIX_PARTITION=y
CONFIG_SUN_PARTITION=y
# CONFIG_KARMA_PARTITION is not set
# CONFIG_EFI_PARTITION is not set
CONFIG_SYSV68_PARTITION=y
# CONFIG_CMDLINE_PARTITION is not set
CONFIG_BLOCK_COMPAT=y

#
# IO Schedulers
#
CONFIG_IOSCHED_NOOP=y
# CONFIG_IOSCHED_DEADLINE is not set
# CONFIG_IOSCHED_CFQ is not set
CONFIG_DEFAULT_NOOP=y
CONFIG_DEFAULT_IOSCHED="noop"
CONFIG_ASN1=y
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
# CONFIG_X86_AMD_PLATFORM_DEVICE is not set
CONFIG_IOSF_MBI=m
# CONFIG_IOSF_MBI_DEBUG is not set
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
CONFIG_MEMTEST=y
# CONFIG_MK8 is not set
# CONFIG_MPSC is not set
# CONFIG_MCORE2 is not set
# CONFIG_MATOM is not set
CONFIG_GENERIC_CPU=y
CONFIG_X86_INTERNODE_CACHE_SHIFT=6
CONFIG_X86_L1_CACHE_SHIFT=6
CONFIG_X86_TSC=y
CONFIG_X86_CMPXCHG64=y
CONFIG_X86_CMOV=y
CONFIG_X86_MINIMUM_CPU_FAMILY=64
CONFIG_X86_DEBUGCTLMSR=y
CONFIG_PROCESSOR_SELECT=y
# CONFIG_CPU_SUP_INTEL is not set
CONFIG_CPU_SUP_AMD=y
CONFIG_CPU_SUP_CENTAUR=y
CONFIG_HPET_TIMER=y
CONFIG_DMI=y
# CONFIG_GART_IOMMU is not set
CONFIG_CALGARY_IOMMU=y
# CONFIG_CALGARY_IOMMU_ENABLED_BY_DEFAULT is not set
CONFIG_SWIOTLB=y
CONFIG_IOMMU_HELPER=y
CONFIG_NR_CPUS=1
CONFIG_PREEMPT_NONE=y
# CONFIG_PREEMPT_VOLUNTARY is not set
# CONFIG_PREEMPT is not set
CONFIG_PREEMPT_COUNT=y
CONFIG_UP_LATE_INIT=y
CONFIG_X86_UP_APIC_MSI=y
CONFIG_X86_LOCAL_APIC=y
CONFIG_X86_IO_APIC=y
CONFIG_X86_REROUTE_FOR_BROKEN_BOOT_IRQS=y
# CONFIG_X86_MCE is not set
CONFIG_X86_16BIT=y
CONFIG_X86_ESPFIX64=y
CONFIG_X86_VSYSCALL_EMULATION=y
# CONFIG_I8K is not set
CONFIG_MICROCODE=y
CONFIG_MICROCODE_INTEL=y
# CONFIG_MICROCODE_AMD is not set
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
CONFIG_ARCH_PROC_KCORE_TEXT=y
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
CONFIG_MEMORY_BALLOON=y
CONFIG_BALLOON_COMPACTION=y
CONFIG_COMPACTION=y
CONFIG_MIGRATION=y
CONFIG_PHYS_ADDR_T_64BIT=y
CONFIG_ZONE_DMA_FLAG=1
CONFIG_BOUNCE=y
CONFIG_NEED_BOUNCE_POOL=y
CONFIG_VIRT_TO_BUS=y
CONFIG_KSM=y
CONFIG_DEFAULT_MMAP_MIN_ADDR=4096
CONFIG_TRANSPARENT_HUGEPAGE=y
CONFIG_TRANSPARENT_HUGEPAGE_ALWAYS=y
# CONFIG_TRANSPARENT_HUGEPAGE_MADVISE is not set
CONFIG_NEED_PER_CPU_KM=y
# CONFIG_CLEANCACHE is not set
# CONFIG_CMA is not set
# CONFIG_ZPOOL is not set
CONFIG_ZBUD=m
CONFIG_ZSMALLOC=y
CONFIG_PGTABLE_MAPPING=y
CONFIG_ZSMALLOC_STAT=y
CONFIG_GENERIC_EARLY_IOREMAP=y
# CONFIG_X86_CHECK_BIOS_CORRUPTION is not set
CONFIG_X86_RESERVE_LOW=64
# CONFIG_MTRR is not set
CONFIG_ARCH_RANDOM=y
CONFIG_X86_SMAP=y
# CONFIG_EFI is not set
CONFIG_SECCOMP=y
# CONFIG_HZ_100 is not set
CONFIG_HZ_250=y
# CONFIG_HZ_300 is not set
# CONFIG_HZ_1000 is not set
CONFIG_HZ=250
# CONFIG_SCHED_HRTICK is not set
# CONFIG_KEXEC is not set
# CONFIG_CRASH_DUMP is not set
CONFIG_PHYSICAL_START=0x1000000
# CONFIG_RELOCATABLE is not set
CONFIG_PHYSICAL_ALIGN=0x200000
CONFIG_COMPAT_VDSO=y
# CONFIG_CMDLINE_BOOL is not set
CONFIG_HAVE_LIVEPATCH=y
CONFIG_ARCH_ENABLE_MEMORY_HOTPLUG=y

#
# Power management and ACPI options
#
# CONFIG_SUSPEND is not set
# CONFIG_PM is not set
CONFIG_ACPI=y
CONFIG_ACPI_LEGACY_TABLES_LOOKUP=y
CONFIG_ARCH_MIGHT_HAVE_ACPI_PDC=y
# CONFIG_ACPI_PROCFS_POWER is not set
# CONFIG_ACPI_EC_DEBUGFS is not set
CONFIG_ACPI_AC=y
CONFIG_ACPI_BATTERY=y
CONFIG_ACPI_BUTTON=y
# CONFIG_ACPI_VIDEO is not set
CONFIG_ACPI_FAN=y
# CONFIG_ACPI_DOCK is not set
CONFIG_ACPI_PROCESSOR=y
# CONFIG_ACPI_IPMI is not set
# CONFIG_ACPI_PROCESSOR_AGGREGATOR is not set
CONFIG_ACPI_THERMAL=y
CONFIG_ACPI_CUSTOM_DSDT_FILE=""
# CONFIG_ACPI_CUSTOM_DSDT is not set
# CONFIG_ACPI_INITRD_TABLE_OVERRIDE is not set
# CONFIG_ACPI_DEBUG is not set
# CONFIG_ACPI_PCI_SLOT is not set
CONFIG_X86_PM_TIMER=y
# CONFIG_ACPI_CONTAINER is not set
CONFIG_ACPI_HOTPLUG_IOAPIC=y
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
# CONFIG_CPU_FREQ_DEFAULT_GOV_USERSPACE is not set
CONFIG_CPU_FREQ_DEFAULT_GOV_ONDEMAND=y
# CONFIG_CPU_FREQ_DEFAULT_GOV_CONSERVATIVE is not set
CONFIG_CPU_FREQ_GOV_PERFORMANCE=y
CONFIG_CPU_FREQ_GOV_POWERSAVE=y
CONFIG_CPU_FREQ_GOV_USERSPACE=m
CONFIG_CPU_FREQ_GOV_ONDEMAND=y
# CONFIG_CPU_FREQ_GOV_CONSERVATIVE is not set

#
# CPU frequency scaling drivers
#
# CONFIG_X86_INTEL_PSTATE is not set
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

#
# Memory power savings
#
# CONFIG_I7300_IDLE is not set

#
# Bus options (PCI etc.)
#
CONFIG_PCI=y
CONFIG_PCI_DIRECT=y
# CONFIG_PCI_MMCONFIG is not set
CONFIG_PCI_DOMAINS=y
CONFIG_PCI_CNB20LE_QUIRK=y
CONFIG_PCIEPORTBUS=y
# CONFIG_HOTPLUG_PCI_PCIE is not set
# CONFIG_PCIEAER is not set
# CONFIG_PCIEASPM is not set
CONFIG_PCI_MSI=y
# CONFIG_PCI_DEBUG is not set
CONFIG_PCI_REALLOC_ENABLE_AUTO=y
# CONFIG_PCI_STUB is not set
CONFIG_HT_IRQ=y
CONFIG_PCI_ATS=y
CONFIG_PCI_IOV=y
CONFIG_PCI_PRI=y
CONFIG_PCI_PASID=y
CONFIG_PCI_LABEL=y

#
# PCI host controller drivers
#
# CONFIG_ISA_DMA_API is not set
CONFIG_AMD_NB=y
# CONFIG_PCCARD is not set
CONFIG_HOTPLUG_PCI=y
# CONFIG_HOTPLUG_PCI_ACPI is not set
# CONFIG_HOTPLUG_PCI_CPCI is not set
# CONFIG_HOTPLUG_PCI_SHPC is not set
CONFIG_RAPIDIO=y
# CONFIG_RAPIDIO_TSI721 is not set
CONFIG_RAPIDIO_DISC_TIMEOUT=30
# CONFIG_RAPIDIO_ENABLE_RX_TX_PORTS is not set
CONFIG_RAPIDIO_DMA_ENGINE=y
CONFIG_RAPIDIO_DEBUG=y
CONFIG_RAPIDIO_ENUM_BASIC=m

#
# RapidIO Switch drivers
#
CONFIG_RAPIDIO_TSI57X=m
CONFIG_RAPIDIO_CPS_XX=y
# CONFIG_RAPIDIO_TSI568 is not set
# CONFIG_RAPIDIO_CPS_GEN2 is not set
# CONFIG_X86_SYSFB is not set

#
# Executable file formats / Emulations
#
CONFIG_BINFMT_ELF=y
CONFIG_COMPAT_BINFMT_ELF=y
CONFIG_ARCH_BINFMT_ELF_RANDOMIZE_PIE=y
CONFIG_CORE_DUMP_DEFAULT_ELF_HEADERS=y
CONFIG_BINFMT_SCRIPT=y
# CONFIG_HAVE_AOUT is not set
# CONFIG_BINFMT_MISC is not set
CONFIG_COREDUMP=y
CONFIG_IA32_EMULATION=y
# CONFIG_IA32_AOUT is not set
# CONFIG_X86_X32 is not set
CONFIG_COMPAT=y
CONFIG_COMPAT_FOR_U64_ALIGNMENT=y
CONFIG_KEYS_COMPAT=y
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
# CONFIG_MPLS is not set
# CONFIG_HSR is not set
# CONFIG_CGROUP_NET_PRIO is not set
# CONFIG_CGROUP_NET_CLASSID is not set
CONFIG_NET_RX_BUSY_POLL=y
CONFIG_BQL=y
# CONFIG_BPF_JIT is not set

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
# CONFIG_STANDALONE is not set
CONFIG_PREVENT_FIRMWARE_BUILD=y
CONFIG_FW_LOADER=y
CONFIG_FIRMWARE_IN_KERNEL=y
CONFIG_EXTRA_FIRMWARE=""
# CONFIG_FW_LOADER_USER_HELPER_FALLBACK is not set
# CONFIG_ALLOW_DEV_COREDUMP is not set
# CONFIG_DEBUG_DRIVER is not set
# CONFIG_DEBUG_DEVRES is not set
# CONFIG_SYS_HYPERVISOR is not set
# CONFIG_GENERIC_CPU_DEVICES is not set
CONFIG_GENERIC_CPU_AUTOPROBE=y
CONFIG_REGMAP=y
CONFIG_REGMAP_I2C=y
CONFIG_REGMAP_SPI=y
CONFIG_REGMAP_MMIO=y
CONFIG_REGMAP_IRQ=y
CONFIG_DMA_SHARED_BUFFER=y
CONFIG_FENCE_TRACE=y

#
# Bus devices
#
# CONFIG_CONNECTOR is not set
CONFIG_MTD=m
CONFIG_MTD_TESTS=m
# CONFIG_MTD_REDBOOT_PARTS is not set
CONFIG_MTD_CMDLINE_PARTS=m
CONFIG_MTD_AR7_PARTS=m

#
# User Modules And Translation Layers
#
CONFIG_MTD_BLKDEVS=m
CONFIG_MTD_BLOCK=m
# CONFIG_MTD_BLOCK_RO is not set
CONFIG_FTL=m
# CONFIG_NFTL is not set
CONFIG_INFTL=m
CONFIG_RFD_FTL=m
# CONFIG_SSFDC is not set
CONFIG_SM_FTL=m
CONFIG_MTD_OOPS=m

#
# RAM/ROM/Flash chip drivers
#
CONFIG_MTD_CFI=m
CONFIG_MTD_JEDECPROBE=m
CONFIG_MTD_GEN_PROBE=m
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
# CONFIG_MTD_CFI_INTELEXT is not set
CONFIG_MTD_CFI_AMDSTD=m
# CONFIG_MTD_CFI_STAA is not set
CONFIG_MTD_CFI_UTIL=m
CONFIG_MTD_RAM=m
CONFIG_MTD_ROM=m
# CONFIG_MTD_ABSENT is not set

#
# Mapping drivers for chip access
#
# CONFIG_MTD_COMPLEX_MAPPINGS is not set
# CONFIG_MTD_PHYSMAP is not set
CONFIG_MTD_AMD76XROM=m
CONFIG_MTD_ICHXROM=m
# CONFIG_MTD_ESB2ROM is not set
# CONFIG_MTD_CK804XROM is not set
# CONFIG_MTD_SCB2_FLASH is not set
CONFIG_MTD_NETtel=m
# CONFIG_MTD_L440GX is not set
CONFIG_MTD_INTEL_VR_NOR=m
# CONFIG_MTD_PLATRAM is not set

#
# Self-contained MTD device drivers
#
CONFIG_MTD_PMC551=m
# CONFIG_MTD_PMC551_BUGFIX is not set
CONFIG_MTD_PMC551_DEBUG=y
CONFIG_MTD_DATAFLASH=m
# CONFIG_MTD_DATAFLASH_WRITE_VERIFY is not set
# CONFIG_MTD_DATAFLASH_OTP is not set
CONFIG_MTD_SST25L=m
# CONFIG_MTD_SLRAM is not set
CONFIG_MTD_PHRAM=m
CONFIG_MTD_MTDRAM=m
CONFIG_MTDRAM_TOTAL_SIZE=4096
CONFIG_MTDRAM_ERASE_SIZE=128
CONFIG_MTD_BLOCK2MTD=m

#
# Disk-On-Chip Device Drivers
#
CONFIG_MTD_DOCG3=m
CONFIG_BCH_CONST_M=14
CONFIG_BCH_CONST_T=4
CONFIG_MTD_NAND_ECC=m
# CONFIG_MTD_NAND_ECC_SMC is not set
CONFIG_MTD_NAND=m
# CONFIG_MTD_NAND_ECC_BCH is not set
# CONFIG_MTD_SM_COMMON is not set
CONFIG_MTD_NAND_DENALI=m
CONFIG_MTD_NAND_DENALI_PCI=m
CONFIG_MTD_NAND_DENALI_SCRATCH_REG_ADDR=0xFF108018
# CONFIG_MTD_NAND_GPIO is not set
# CONFIG_MTD_NAND_OMAP_BCH_BUILD is not set
CONFIG_MTD_NAND_IDS=m
# CONFIG_MTD_NAND_RICOH is not set
# CONFIG_MTD_NAND_DISKONCHIP is not set
CONFIG_MTD_NAND_DOCG4=m
CONFIG_MTD_NAND_CAFE=m
CONFIG_MTD_NAND_NANDSIM=m
CONFIG_MTD_NAND_PLATFORM=m
CONFIG_MTD_NAND_HISI504=m
# CONFIG_MTD_ONENAND is not set

#
# LPDDR & LPDDR2 PCM memory drivers
#
CONFIG_MTD_LPDDR=m
CONFIG_MTD_QINFO_PROBE=m
# CONFIG_MTD_SPI_NOR is not set
# CONFIG_MTD_UBI is not set
CONFIG_ARCH_MIGHT_HAVE_PC_PARPORT=y
CONFIG_PARPORT=y
CONFIG_PARPORT_PC=y
# CONFIG_PARPORT_SERIAL is not set
CONFIG_PARPORT_PC_FIFO=y
# CONFIG_PARPORT_PC_SUPERIO is not set
# CONFIG_PARPORT_GSC is not set
# CONFIG_PARPORT_AX88796 is not set
# CONFIG_PARPORT_1284 is not set
CONFIG_PARPORT_NOT_PC=y
CONFIG_PNP=y
CONFIG_PNP_DEBUG_MESSAGES=y

#
# Protocols
#
CONFIG_PNPACPI=y
CONFIG_BLK_DEV=y
# CONFIG_BLK_DEV_NULL_BLK is not set
# CONFIG_PARIDE is not set
# CONFIG_BLK_DEV_PCIESSD_MTIP32XX is not set
# CONFIG_ZRAM is not set
# CONFIG_BLK_CPQ_CISS_DA is not set
# CONFIG_BLK_DEV_DAC960 is not set
# CONFIG_BLK_DEV_UMEM is not set
# CONFIG_BLK_DEV_COW_COMMON is not set
# CONFIG_BLK_DEV_LOOP is not set

#
# DRBD disabled because PROC_FS or INET not selected
#
# CONFIG_BLK_DEV_NBD is not set
# CONFIG_BLK_DEV_NVME is not set
# CONFIG_BLK_DEV_SKD is not set
# CONFIG_BLK_DEV_SX8 is not set
# CONFIG_BLK_DEV_RAM is not set
# CONFIG_CDROM_PKTCDVD is not set
# CONFIG_ATA_OVER_ETH is not set
# CONFIG_VIRTIO_BLK is not set
# CONFIG_BLK_DEV_HD is not set
# CONFIG_BLK_DEV_RSXX is not set

#
# Misc devices
#
CONFIG_SENSORS_LIS3LV02D=m
# CONFIG_AD525X_DPOT is not set
# CONFIG_DUMMY_IRQ is not set
CONFIG_IBM_ASM=y
# CONFIG_PHANTOM is not set
CONFIG_SGI_IOC4=m
CONFIG_TIFM_CORE=y
CONFIG_TIFM_7XX1=y
CONFIG_ICS932S401=m
CONFIG_ENCLOSURE_SERVICES=y
CONFIG_HP_ILO=y
# CONFIG_APDS9802ALS is not set
CONFIG_ISL29003=y
# CONFIG_ISL29020 is not set
CONFIG_SENSORS_TSL2550=m
CONFIG_SENSORS_BH1780=m
# CONFIG_SENSORS_BH1770 is not set
# CONFIG_SENSORS_APDS990X is not set
CONFIG_HMC6352=m
# CONFIG_DS1682 is not set
CONFIG_TI_DAC7512=y
# CONFIG_VMWARE_BALLOON is not set
CONFIG_BMP085=y
CONFIG_BMP085_I2C=m
CONFIG_BMP085_SPI=m
CONFIG_USB_SWITCH_FSA9480=m
CONFIG_LATTICE_ECP3_CONFIG=y
# CONFIG_SRAM is not set
CONFIG_C2PORT=m
CONFIG_C2PORT_DURAMAR_2150=m

#
# EEPROM support
#
CONFIG_EEPROM_AT24=m
CONFIG_EEPROM_AT25=y
CONFIG_EEPROM_LEGACY=m
# CONFIG_EEPROM_MAX6875 is not set
CONFIG_EEPROM_93CX6=y
# CONFIG_EEPROM_93XX46 is not set
CONFIG_CB710_CORE=y
CONFIG_CB710_DEBUG=y
CONFIG_CB710_DEBUG_ASSUMPTIONS=y

#
# Texas Instruments shared transport line discipline
#
# CONFIG_TI_ST is not set
CONFIG_SENSORS_LIS3_I2C=m

#
# Altera FPGA firmware download module
#
CONFIG_ALTERA_STAPL=y
# CONFIG_VMWARE_VMCI is not set

#
# Intel MIC Bus Driver
#
CONFIG_INTEL_MIC_BUS=y

#
# Intel MIC Host Driver
#
CONFIG_INTEL_MIC_HOST=m

#
# Intel MIC Card Driver
#
CONFIG_INTEL_MIC_CARD=y
# CONFIG_GENWQE is not set
CONFIG_ECHO=y
# CONFIG_CXL_BASE is not set
CONFIG_HAVE_IDE=y
# CONFIG_IDE is not set

#
# SCSI device support
#
CONFIG_SCSI_MOD=y
CONFIG_RAID_ATTRS=y
CONFIG_SCSI=y
CONFIG_SCSI_DMA=y
# CONFIG_SCSI_NETLINK is not set
# CONFIG_SCSI_MQ_DEFAULT is not set
CONFIG_SCSI_PROC_FS=y

#
# SCSI support type (disk, tape, CD-ROM)
#
# CONFIG_BLK_DEV_SD is not set
CONFIG_CHR_DEV_ST=y
# CONFIG_CHR_DEV_OSST is not set
CONFIG_BLK_DEV_SR=y
# CONFIG_BLK_DEV_SR_VENDOR is not set
CONFIG_CHR_DEV_SG=y
CONFIG_CHR_DEV_SCH=m
# CONFIG_SCSI_ENCLOSURE is not set
# CONFIG_SCSI_CONSTANTS is not set
CONFIG_SCSI_LOGGING=y
# CONFIG_SCSI_SCAN_ASYNC is not set

#
# SCSI Transports
#
CONFIG_SCSI_SPI_ATTRS=y
# CONFIG_SCSI_FC_ATTRS is not set
# CONFIG_SCSI_ISCSI_ATTRS is not set
CONFIG_SCSI_SAS_ATTRS=y
CONFIG_SCSI_SAS_LIBSAS=y
CONFIG_SCSI_SAS_ATA=y
# CONFIG_SCSI_SAS_HOST_SMP is not set
CONFIG_SCSI_SRP_ATTRS=y
CONFIG_SCSI_LOWLEVEL=y
CONFIG_ISCSI_BOOT_SYSFS=y
# CONFIG_SCSI_BNX2_ISCSI is not set
# CONFIG_BE2ISCSI is not set
CONFIG_BLK_DEV_3W_XXXX_RAID=y
# CONFIG_SCSI_HPSA is not set
CONFIG_SCSI_3W_9XXX=m
# CONFIG_SCSI_3W_SAS is not set
# CONFIG_SCSI_ACARD is not set
CONFIG_SCSI_AACRAID=y
# CONFIG_SCSI_AIC7XXX is not set
CONFIG_SCSI_AIC79XX=y
CONFIG_AIC79XX_CMDS_PER_DEVICE=32
CONFIG_AIC79XX_RESET_DELAY_MS=5000
CONFIG_AIC79XX_DEBUG_ENABLE=y
CONFIG_AIC79XX_DEBUG_MASK=0
# CONFIG_AIC79XX_REG_PRETTY_PRINT is not set
CONFIG_SCSI_AIC94XX=m
# CONFIG_AIC94XX_DEBUG is not set
CONFIG_SCSI_MVSAS=y
CONFIG_SCSI_MVSAS_DEBUG=y
CONFIG_SCSI_MVSAS_TASKLET=y
# CONFIG_SCSI_MVUMI is not set
CONFIG_SCSI_DPT_I2O=m
CONFIG_SCSI_ADVANSYS=y
CONFIG_SCSI_ARCMSR=y
# CONFIG_SCSI_ESAS2R is not set
# CONFIG_MEGARAID_NEWGEN is not set
# CONFIG_MEGARAID_LEGACY is not set
CONFIG_MEGARAID_SAS=m
CONFIG_SCSI_MPT2SAS=m
CONFIG_SCSI_MPT2SAS_MAX_SGE=128
# CONFIG_SCSI_MPT2SAS_LOGGING is not set
# CONFIG_SCSI_MPT3SAS is not set
CONFIG_SCSI_UFSHCD=m
# CONFIG_SCSI_UFSHCD_PCI is not set
CONFIG_SCSI_UFSHCD_PLATFORM=m
CONFIG_SCSI_HPTIOP=y
CONFIG_VMWARE_PVSCSI=y
CONFIG_SCSI_DMX3191D=m
# CONFIG_SCSI_FUTURE_DOMAIN is not set
CONFIG_SCSI_ISCI=m
CONFIG_SCSI_IPS=m
CONFIG_SCSI_INITIO=m
# CONFIG_SCSI_INIA100 is not set
# CONFIG_SCSI_PPA is not set
CONFIG_SCSI_IMM=m
CONFIG_SCSI_IZIP_EPP16=y
# CONFIG_SCSI_IZIP_SLOW_CTR is not set
CONFIG_SCSI_STEX=m
CONFIG_SCSI_SYM53C8XX_2=m
CONFIG_SCSI_SYM53C8XX_DMA_ADDRESSING_MODE=1
CONFIG_SCSI_SYM53C8XX_DEFAULT_TAGS=16
CONFIG_SCSI_SYM53C8XX_MAX_TAGS=64
# CONFIG_SCSI_SYM53C8XX_MMIO is not set
CONFIG_SCSI_IPR=y
# CONFIG_SCSI_IPR_TRACE is not set
CONFIG_SCSI_IPR_DUMP=y
CONFIG_SCSI_QLOGIC_1280=y
# CONFIG_SCSI_QLA_ISCSI is not set
CONFIG_SCSI_DC395x=y
CONFIG_SCSI_AM53C974=m
CONFIG_SCSI_WD719X=y
# CONFIG_SCSI_DEBUG is not set
# CONFIG_SCSI_PMCRAID is not set
CONFIG_SCSI_PM8001=m
CONFIG_SCSI_VIRTIO=m
# CONFIG_SCSI_DH is not set
CONFIG_SCSI_OSD_INITIATOR=m
# CONFIG_SCSI_OSD_ULD is not set
CONFIG_SCSI_OSD_DPRINT_SENSE=1
CONFIG_SCSI_OSD_DEBUG=y
CONFIG_ATA=y
# CONFIG_ATA_NONSTANDARD is not set
# CONFIG_ATA_VERBOSE_ERROR is not set
CONFIG_ATA_ACPI=y
CONFIG_SATA_PMP=y

#
# Controllers with non-SFF native interface
#
CONFIG_SATA_AHCI=m
CONFIG_SATA_AHCI_PLATFORM=y
CONFIG_SATA_INIC162X=y
CONFIG_SATA_ACARD_AHCI=y
# CONFIG_SATA_SIL24 is not set
# CONFIG_ATA_SFF is not set
# CONFIG_MD is not set
CONFIG_TARGET_CORE=y
CONFIG_TCM_IBLOCK=y
CONFIG_TCM_FILEIO=y
# CONFIG_TCM_PSCSI is not set
# CONFIG_TCM_USER is not set
CONFIG_LOOPBACK_TARGET=y
# CONFIG_ISCSI_TARGET is not set
CONFIG_SBP_TARGET=m
CONFIG_FUSION=y
# CONFIG_FUSION_SPI is not set
CONFIG_FUSION_SAS=m
CONFIG_FUSION_MAX_SGE=128
# CONFIG_FUSION_CTL is not set
CONFIG_FUSION_LOGGING=y

#
# IEEE 1394 (FireWire) support
#
CONFIG_FIREWIRE=m
# CONFIG_FIREWIRE_OHCI is not set
# CONFIG_FIREWIRE_SBP2 is not set
# CONFIG_FIREWIRE_NOSY is not set
# CONFIG_MACINTOSH_DRIVERS is not set
# CONFIG_NETDEVICES is not set
# CONFIG_VHOST_NET is not set
# CONFIG_VHOST_SCSI is not set
CONFIG_VHOST_RING=m

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
CONFIG_INPUT_MOUSEDEV=m
CONFIG_INPUT_MOUSEDEV_PSAUX=y
CONFIG_INPUT_MOUSEDEV_SCREEN_X=1024
CONFIG_INPUT_MOUSEDEV_SCREEN_Y=768
CONFIG_INPUT_JOYDEV=m
# CONFIG_INPUT_EVDEV is not set
CONFIG_INPUT_EVBUG=m

#
# Input Device Drivers
#
CONFIG_INPUT_KEYBOARD=y
CONFIG_KEYBOARD_ADP5520=y
# CONFIG_KEYBOARD_ADP5588 is not set
CONFIG_KEYBOARD_ADP5589=m
CONFIG_KEYBOARD_ATKBD=y
CONFIG_KEYBOARD_QT1070=y
# CONFIG_KEYBOARD_QT2160 is not set
# CONFIG_KEYBOARD_LKKBD is not set
CONFIG_KEYBOARD_GPIO=m
CONFIG_KEYBOARD_GPIO_POLLED=y
CONFIG_KEYBOARD_TCA6416=m
CONFIG_KEYBOARD_TCA8418=y
CONFIG_KEYBOARD_MATRIX=y
CONFIG_KEYBOARD_LM8323=m
# CONFIG_KEYBOARD_LM8333 is not set
CONFIG_KEYBOARD_MAX7359=m
# CONFIG_KEYBOARD_MCS is not set
CONFIG_KEYBOARD_MPR121=y
CONFIG_KEYBOARD_NEWTON=y
# CONFIG_KEYBOARD_OPENCORES is not set
# CONFIG_KEYBOARD_STOWAWAY is not set
CONFIG_KEYBOARD_SUNKBD=y
CONFIG_KEYBOARD_TC3589X=m
CONFIG_KEYBOARD_TWL4030=y
CONFIG_KEYBOARD_XTKBD=y
CONFIG_KEYBOARD_CROS_EC=y
# CONFIG_INPUT_MOUSE is not set
# CONFIG_INPUT_JOYSTICK is not set
CONFIG_INPUT_TABLET=y
CONFIG_TABLET_USB_ACECAD=y
CONFIG_TABLET_USB_AIPTEK=y
# CONFIG_TABLET_USB_GTCO is not set
CONFIG_TABLET_USB_HANWANG=y
CONFIG_TABLET_USB_KBTAB=y
# CONFIG_TABLET_SERIAL_WACOM4 is not set
CONFIG_INPUT_TOUCHSCREEN=y
CONFIG_TOUCHSCREEN_88PM860X=y
CONFIG_TOUCHSCREEN_ADS7846=m
CONFIG_TOUCHSCREEN_AD7877=m
CONFIG_TOUCHSCREEN_AD7879=m
CONFIG_TOUCHSCREEN_AD7879_I2C=m
CONFIG_TOUCHSCREEN_AD7879_SPI=m
CONFIG_TOUCHSCREEN_ATMEL_MXT=m
# CONFIG_TOUCHSCREEN_AUO_PIXCIR is not set
CONFIG_TOUCHSCREEN_BU21013=y
CONFIG_TOUCHSCREEN_CY8CTMG110=m
CONFIG_TOUCHSCREEN_CYTTSP_CORE=m
CONFIG_TOUCHSCREEN_CYTTSP_I2C=m
CONFIG_TOUCHSCREEN_CYTTSP_SPI=m
CONFIG_TOUCHSCREEN_CYTTSP4_CORE=m
CONFIG_TOUCHSCREEN_CYTTSP4_I2C=m
CONFIG_TOUCHSCREEN_CYTTSP4_SPI=m
CONFIG_TOUCHSCREEN_DA9034=y
# CONFIG_TOUCHSCREEN_DYNAPRO is not set
CONFIG_TOUCHSCREEN_HAMPSHIRE=y
CONFIG_TOUCHSCREEN_EETI=y
# CONFIG_TOUCHSCREEN_FUJITSU is not set
# CONFIG_TOUCHSCREEN_GOODIX is not set
CONFIG_TOUCHSCREEN_ILI210X=y
# CONFIG_TOUCHSCREEN_GUNZE is not set
# CONFIG_TOUCHSCREEN_ELAN is not set
# CONFIG_TOUCHSCREEN_ELO is not set
CONFIG_TOUCHSCREEN_WACOM_W8001=y
CONFIG_TOUCHSCREEN_WACOM_I2C=y
# CONFIG_TOUCHSCREEN_MAX11801 is not set
CONFIG_TOUCHSCREEN_MCS5000=y
CONFIG_TOUCHSCREEN_MMS114=y
CONFIG_TOUCHSCREEN_MTOUCH=y
CONFIG_TOUCHSCREEN_INEXIO=y
# CONFIG_TOUCHSCREEN_MK712 is not set
# CONFIG_TOUCHSCREEN_PENMOUNT is not set
# CONFIG_TOUCHSCREEN_EDT_FT5X06 is not set
# CONFIG_TOUCHSCREEN_TOUCHRIGHT is not set
CONFIG_TOUCHSCREEN_TOUCHWIN=m
# CONFIG_TOUCHSCREEN_TI_AM335X_TSC is not set
# CONFIG_TOUCHSCREEN_PIXCIR is not set
CONFIG_TOUCHSCREEN_WM831X=m
# CONFIG_TOUCHSCREEN_WM97XX is not set
CONFIG_TOUCHSCREEN_USB_COMPOSITE=m
CONFIG_TOUCHSCREEN_MC13783=y
CONFIG_TOUCHSCREEN_USB_EGALAX=y
CONFIG_TOUCHSCREEN_USB_PANJIT=y
CONFIG_TOUCHSCREEN_USB_3M=y
# CONFIG_TOUCHSCREEN_USB_ITM is not set
# CONFIG_TOUCHSCREEN_USB_ETURBO is not set
# CONFIG_TOUCHSCREEN_USB_GUNZE is not set
CONFIG_TOUCHSCREEN_USB_DMC_TSC10=y
CONFIG_TOUCHSCREEN_USB_IRTOUCH=y
CONFIG_TOUCHSCREEN_USB_IDEALTEK=y
# CONFIG_TOUCHSCREEN_USB_GENERAL_TOUCH is not set
# CONFIG_TOUCHSCREEN_USB_GOTOP is not set
CONFIG_TOUCHSCREEN_USB_JASTEC=y
# CONFIG_TOUCHSCREEN_USB_ELO is not set
CONFIG_TOUCHSCREEN_USB_E2I=y
# CONFIG_TOUCHSCREEN_USB_ZYTRONIC is not set
# CONFIG_TOUCHSCREEN_USB_ETT_TC45USB is not set
CONFIG_TOUCHSCREEN_USB_NEXIO=y
CONFIG_TOUCHSCREEN_USB_EASYTOUCH=y
CONFIG_TOUCHSCREEN_TOUCHIT213=y
# CONFIG_TOUCHSCREEN_TSC_SERIO is not set
# CONFIG_TOUCHSCREEN_TSC2005 is not set
CONFIG_TOUCHSCREEN_TSC2007=y
CONFIG_TOUCHSCREEN_ST1232=m
CONFIG_TOUCHSCREEN_SUR40=m
CONFIG_TOUCHSCREEN_TPS6507X=m
CONFIG_TOUCHSCREEN_ZFORCE=m
CONFIG_INPUT_MISC=y
CONFIG_INPUT_88PM860X_ONKEY=y
CONFIG_INPUT_88PM80X_ONKEY=m
CONFIG_INPUT_AD714X=m
CONFIG_INPUT_AD714X_I2C=m
CONFIG_INPUT_AD714X_SPI=m
# CONFIG_INPUT_BMA150 is not set
# CONFIG_INPUT_E3X0_BUTTON is not set
CONFIG_INPUT_PCSPKR=y
CONFIG_INPUT_MAX8925_ONKEY=m
# CONFIG_INPUT_MC13783_PWRBUTTON is not set
# CONFIG_INPUT_MMA8450 is not set
# CONFIG_INPUT_MPU3050 is not set
# CONFIG_INPUT_APANEL is not set
# CONFIG_INPUT_GP2A is not set
CONFIG_INPUT_GPIO_BEEPER=y
# CONFIG_INPUT_GPIO_TILT_POLLED is not set
# CONFIG_INPUT_ATLAS_BTNS is not set
CONFIG_INPUT_ATI_REMOTE2=y
CONFIG_INPUT_KEYSPAN_REMOTE=m
# CONFIG_INPUT_KXTJ9 is not set
CONFIG_INPUT_POWERMATE=y
CONFIG_INPUT_YEALINK=y
CONFIG_INPUT_CM109=y
CONFIG_INPUT_RETU_PWRBUTTON=m
CONFIG_INPUT_TWL4030_PWRBUTTON=y
CONFIG_INPUT_TWL4030_VIBRA=m
CONFIG_INPUT_UINPUT=m
CONFIG_INPUT_PCF50633_PMU=y
# CONFIG_INPUT_PCF8574 is not set
CONFIG_INPUT_PWM_BEEPER=m
# CONFIG_INPUT_GPIO_ROTARY_ENCODER is not set
CONFIG_INPUT_WM831X_ON=y
CONFIG_INPUT_ADXL34X=y
CONFIG_INPUT_ADXL34X_I2C=y
# CONFIG_INPUT_ADXL34X_SPI is not set
# CONFIG_INPUT_IMS_PCU is not set
CONFIG_INPUT_CMA3000=y
# CONFIG_INPUT_CMA3000_I2C is not set
# CONFIG_INPUT_IDEAPAD_SLIDEBAR is not set
# CONFIG_INPUT_SOC_BUTTON_ARRAY is not set
CONFIG_INPUT_DRV260X_HAPTICS=y
# CONFIG_INPUT_DRV2667_HAPTICS is not set

#
# Hardware I/O ports
#
CONFIG_SERIO=y
CONFIG_ARCH_MIGHT_HAVE_PC_SERIO=y
CONFIG_SERIO_I8042=y
# CONFIG_SERIO_SERPORT is not set
CONFIG_SERIO_CT82C710=y
CONFIG_SERIO_PARKBD=y
# CONFIG_SERIO_PCIPS2 is not set
CONFIG_SERIO_LIBPS2=y
CONFIG_SERIO_RAW=y
CONFIG_SERIO_ALTERA_PS2=y
# CONFIG_SERIO_PS2MULT is not set
CONFIG_SERIO_ARC_PS2=y
CONFIG_GAMEPORT=m
CONFIG_GAMEPORT_NS558=m
# CONFIG_GAMEPORT_L4 is not set
# CONFIG_GAMEPORT_EMU10K1 is not set
# CONFIG_GAMEPORT_FM801 is not set

#
# Character devices
#
CONFIG_TTY=y
# CONFIG_VT is not set
# CONFIG_UNIX98_PTYS is not set
# CONFIG_LEGACY_PTYS is not set
# CONFIG_SERIAL_NONSTANDARD is not set
CONFIG_NOZOMI=m
# CONFIG_N_GSM is not set
CONFIG_TRACE_ROUTER=m
CONFIG_TRACE_SINK=m
CONFIG_DEVMEM=y
CONFIG_DEVKMEM=y

#
# Serial drivers
#
CONFIG_SERIAL_EARLYCON=y
CONFIG_SERIAL_8250=y
CONFIG_SERIAL_8250_DEPRECATED_OPTIONS=y
CONFIG_SERIAL_8250_PNP=y
CONFIG_SERIAL_8250_CONSOLE=y
CONFIG_SERIAL_8250_DMA=y
CONFIG_SERIAL_8250_PCI=m
CONFIG_SERIAL_8250_NR_UARTS=4
CONFIG_SERIAL_8250_RUNTIME_UARTS=4
# CONFIG_SERIAL_8250_EXTENDED is not set
CONFIG_SERIAL_8250_DW=m
# CONFIG_SERIAL_8250_FINTEK is not set

#
# Non-8250 serial port support
#
CONFIG_SERIAL_MAX3100=y
CONFIG_SERIAL_MAX310X=m
# CONFIG_SERIAL_MFD_HSU is not set
CONFIG_SERIAL_CORE=y
CONFIG_SERIAL_CORE_CONSOLE=y
# CONFIG_SERIAL_JSM is not set
CONFIG_SERIAL_SCCNXP=y
# CONFIG_SERIAL_SCCNXP_CONSOLE is not set
CONFIG_SERIAL_SC16IS7XX=y
CONFIG_SERIAL_ALTERA_JTAGUART=m
CONFIG_SERIAL_ALTERA_UART=y
CONFIG_SERIAL_ALTERA_UART_MAXPORTS=4
CONFIG_SERIAL_ALTERA_UART_BAUDRATE=115200
# CONFIG_SERIAL_ALTERA_UART_CONSOLE is not set
CONFIG_SERIAL_IFX6X60=m
CONFIG_SERIAL_ARC=m
CONFIG_SERIAL_ARC_NR_PORTS=1
# CONFIG_SERIAL_RP2 is not set
CONFIG_SERIAL_FSL_LPUART=m
CONFIG_TTY_PRINTK=m
# CONFIG_PRINTER is not set
CONFIG_PPDEV=m
# CONFIG_VIRTIO_CONSOLE is not set
CONFIG_IPMI_HANDLER=m
# CONFIG_IPMI_PANIC_EVENT is not set
# CONFIG_IPMI_DEVICE_INTERFACE is not set
CONFIG_IPMI_SI=m
CONFIG_IPMI_SI_PROBE_DEFAULTS=y
CONFIG_IPMI_SSIF=m
CONFIG_IPMI_WATCHDOG=m
CONFIG_IPMI_POWEROFF=m
CONFIG_HW_RANDOM=m
CONFIG_HW_RANDOM_TIMERIOMEM=m
CONFIG_HW_RANDOM_INTEL=m
# CONFIG_HW_RANDOM_AMD is not set
# CONFIG_HW_RANDOM_VIA is not set
CONFIG_HW_RANDOM_VIRTIO=m
CONFIG_HW_RANDOM_TPM=m
CONFIG_NVRAM=y
CONFIG_R3964=y
# CONFIG_APPLICOM is not set
# CONFIG_MWAVE is not set
CONFIG_RAW_DRIVER=y
CONFIG_MAX_RAW_DEVS=256
# CONFIG_HPET is not set
# CONFIG_HANGCHECK_TIMER is not set
CONFIG_TCG_TPM=m
CONFIG_TCG_TIS=m
# CONFIG_TCG_TIS_I2C_ATMEL is not set
# CONFIG_TCG_TIS_I2C_INFINEON is not set
CONFIG_TCG_TIS_I2C_NUVOTON=m
CONFIG_TCG_NSC=m
CONFIG_TCG_ATMEL=m
# CONFIG_TCG_INFINEON is not set
CONFIG_TCG_TIS_I2C_ST33=m
# CONFIG_TCG_CRB is not set
CONFIG_TELCLOCK=y
CONFIG_DEVPORT=y
CONFIG_XILLYBUS=y
CONFIG_XILLYBUS_PCIE=y

#
# I2C support
#
CONFIG_I2C=y
CONFIG_ACPI_I2C_OPREGION=y
CONFIG_I2C_BOARDINFO=y
# CONFIG_I2C_COMPAT is not set
CONFIG_I2C_CHARDEV=m
CONFIG_I2C_MUX=y

#
# Multiplexer I2C Chip support
#
CONFIG_I2C_MUX_GPIO=y
CONFIG_I2C_MUX_PCA9541=m
CONFIG_I2C_MUX_PCA954x=y
CONFIG_I2C_HELPER_AUTO=y
CONFIG_I2C_SMBUS=y
CONFIG_I2C_ALGOBIT=y

#
# I2C Hardware Bus support
#

#
# PC SMBus host controller drivers
#
CONFIG_I2C_ALI1535=m
# CONFIG_I2C_ALI1563 is not set
CONFIG_I2C_ALI15X3=m
# CONFIG_I2C_AMD756 is not set
CONFIG_I2C_AMD8111=m
CONFIG_I2C_I801=m
CONFIG_I2C_ISCH=y
CONFIG_I2C_ISMT=m
CONFIG_I2C_PIIX4=m
# CONFIG_I2C_NFORCE2 is not set
# CONFIG_I2C_SIS5595 is not set
# CONFIG_I2C_SIS630 is not set
CONFIG_I2C_SIS96X=m
CONFIG_I2C_VIA=m
CONFIG_I2C_VIAPRO=m

#
# ACPI drivers
#
# CONFIG_I2C_SCMI is not set

#
# I2C system bus drivers (mostly embedded / system-on-chip)
#
# CONFIG_I2C_CBUS_GPIO is not set
CONFIG_I2C_DESIGNWARE_CORE=y
CONFIG_I2C_DESIGNWARE_PCI=y
CONFIG_I2C_GPIO=y
CONFIG_I2C_KEMPLD=y
# CONFIG_I2C_OCORES is not set
# CONFIG_I2C_PCA_PLATFORM is not set
# CONFIG_I2C_PXA_PCI is not set
CONFIG_I2C_SIMTEC=y
CONFIG_I2C_XILINX=m

#
# External I2C/SMBus adapter drivers
#
# CONFIG_I2C_DIOLAN_U2C is not set
CONFIG_I2C_PARPORT=y
# CONFIG_I2C_PARPORT_LIGHT is not set
# CONFIG_I2C_ROBOTFUZZ_OSIF is not set
# CONFIG_I2C_TAOS_EVM is not set
CONFIG_I2C_TINY_USB=m
CONFIG_I2C_VIPERBOARD=m

#
# Other I2C/SMBus bus drivers
#
# CONFIG_I2C_CROS_EC_TUNNEL is not set
# CONFIG_I2C_STUB is not set
CONFIG_I2C_SLAVE=y
CONFIG_I2C_SLAVE_EEPROM=m
# CONFIG_I2C_DEBUG_CORE is not set
# CONFIG_I2C_DEBUG_ALGO is not set
# CONFIG_I2C_DEBUG_BUS is not set
CONFIG_SPI=y
# CONFIG_SPI_DEBUG is not set
CONFIG_SPI_MASTER=y

#
# SPI Master Controller Drivers
#
# CONFIG_SPI_ALTERA is not set
CONFIG_SPI_BITBANG=y
CONFIG_SPI_BUTTERFLY=y
# CONFIG_SPI_GPIO is not set
CONFIG_SPI_LM70_LLP=y
CONFIG_SPI_OC_TINY=y
CONFIG_SPI_PXA2XX_DMA=y
CONFIG_SPI_PXA2XX=m
# CONFIG_SPI_PXA2XX_PCI is not set
# CONFIG_SPI_SC18IS602 is not set
CONFIG_SPI_XCOMM=m
# CONFIG_SPI_XILINX is not set
CONFIG_SPI_DESIGNWARE=m
# CONFIG_SPI_DW_PCI is not set
# CONFIG_SPI_DW_MMIO is not set

#
# SPI Protocol Masters
#
CONFIG_SPI_SPIDEV=m
CONFIG_SPI_TLE62X0=m
# CONFIG_SPMI is not set
CONFIG_HSI=m
CONFIG_HSI_BOARDINFO=y

#
# HSI controllers
#

#
# HSI clients
#
# CONFIG_HSI_CHAR is not set

#
# PPS support
#
CONFIG_PPS=y
# CONFIG_PPS_DEBUG is not set

#
# PPS clients support
#
CONFIG_PPS_CLIENT_KTIMER=y
# CONFIG_PPS_CLIENT_LDISC is not set
# CONFIG_PPS_CLIENT_PARPORT is not set
# CONFIG_PPS_CLIENT_GPIO is not set

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
CONFIG_GPIOLIB=y
CONFIG_GPIO_DEVRES=y
CONFIG_GPIO_ACPI=y
CONFIG_GPIOLIB_IRQCHIP=y
# CONFIG_DEBUG_GPIO is not set
# CONFIG_GPIO_SYSFS is not set
CONFIG_GPIO_GENERIC=y
CONFIG_GPIO_MAX730X=m

#
# Memory mapped GPIO drivers:
#
CONFIG_GPIO_GENERIC_PLATFORM=y
CONFIG_GPIO_IT8761E=m
# CONFIG_GPIO_F7188X is not set
CONFIG_GPIO_SCH311X=m
CONFIG_GPIO_SCH=m
CONFIG_GPIO_ICH=m
CONFIG_GPIO_VX855=y
# CONFIG_GPIO_LYNXPOINT is not set

#
# I2C GPIO expanders:
#
CONFIG_GPIO_ARIZONA=m
# CONFIG_GPIO_CRYSTAL_COVE is not set
CONFIG_GPIO_LP3943=m
CONFIG_GPIO_MAX7300=m
CONFIG_GPIO_MAX732X=m
CONFIG_GPIO_PCA953X=m
CONFIG_GPIO_PCF857X=y
# CONFIG_GPIO_RC5T583 is not set
# CONFIG_GPIO_SX150X is not set
# CONFIG_GPIO_TC3589X is not set
# CONFIG_GPIO_TWL4030 is not set
CONFIG_GPIO_WM831X=m
CONFIG_GPIO_WM8350=y
CONFIG_GPIO_WM8994=m
CONFIG_GPIO_ADP5520=m
# CONFIG_GPIO_ADP5588 is not set

#
# PCI GPIO expanders:
#
CONFIG_GPIO_BT8XX=y
# CONFIG_GPIO_AMD8111 is not set
CONFIG_GPIO_INTEL_MID=y
CONFIG_GPIO_ML_IOH=y
CONFIG_GPIO_RDC321X=m

#
# SPI GPIO expanders:
#
# CONFIG_GPIO_MAX7301 is not set
CONFIG_GPIO_MCP23S08=y
CONFIG_GPIO_MC33880=y

#
# AC97 GPIO expanders:
#

#
# LPC GPIO expanders:
#
CONFIG_GPIO_KEMPLD=m

#
# MODULbus GPIO expanders:
#
# CONFIG_GPIO_TPS6586X is not set

#
# USB GPIO expanders:
#
CONFIG_GPIO_VIPERBOARD=m
CONFIG_W1=m

#
# 1-wire Bus Masters
#
CONFIG_W1_MASTER_MATROX=m
CONFIG_W1_MASTER_DS2490=m
CONFIG_W1_MASTER_DS2482=m
CONFIG_W1_MASTER_DS1WM=m
# CONFIG_W1_MASTER_GPIO is not set

#
# 1-wire Slaves
#
CONFIG_W1_SLAVE_THERM=m
CONFIG_W1_SLAVE_SMEM=m
# CONFIG_W1_SLAVE_DS2408 is not set
CONFIG_W1_SLAVE_DS2413=m
CONFIG_W1_SLAVE_DS2406=m
# CONFIG_W1_SLAVE_DS2423 is not set
CONFIG_W1_SLAVE_DS2431=m
CONFIG_W1_SLAVE_DS2433=m
CONFIG_W1_SLAVE_DS2433_CRC=y
CONFIG_W1_SLAVE_DS2760=m
# CONFIG_W1_SLAVE_DS2780 is not set
CONFIG_W1_SLAVE_DS2781=m
CONFIG_W1_SLAVE_DS28E04=m
CONFIG_W1_SLAVE_BQ27000=m
CONFIG_POWER_SUPPLY=y
# CONFIG_POWER_SUPPLY_DEBUG is not set
CONFIG_PDA_POWER=y
# CONFIG_GENERIC_ADC_BATTERY is not set
# CONFIG_MAX8925_POWER is not set
CONFIG_WM831X_BACKUP=y
# CONFIG_WM831X_POWER is not set
CONFIG_WM8350_POWER=y
CONFIG_TEST_POWER=y
CONFIG_BATTERY_88PM860X=m
CONFIG_BATTERY_DS2760=m
# CONFIG_BATTERY_DS2780 is not set
# CONFIG_BATTERY_DS2781 is not set
CONFIG_BATTERY_DS2782=m
CONFIG_BATTERY_SBS=y
# CONFIG_BATTERY_BQ27x00 is not set
# CONFIG_BATTERY_DA9030 is not set
CONFIG_BATTERY_MAX17040=m
CONFIG_BATTERY_MAX17042=y
CONFIG_BATTERY_TWL4030_MADC=m
CONFIG_CHARGER_88PM860X=m
CONFIG_CHARGER_PCF50633=m
# CONFIG_BATTERY_RX51 is not set
CONFIG_CHARGER_ISP1704=m
# CONFIG_CHARGER_MAX8903 is not set
# CONFIG_CHARGER_TWL4030 is not set
CONFIG_CHARGER_LP8727=m
# CONFIG_CHARGER_LP8788 is not set
CONFIG_CHARGER_GPIO=m
CONFIG_CHARGER_BQ2415X=y
CONFIG_CHARGER_BQ24190=y
CONFIG_CHARGER_BQ24735=y
CONFIG_CHARGER_SMB347=m
# CONFIG_CHARGER_TPS65090 is not set
CONFIG_BATTERY_GAUGE_LTC2941=m
CONFIG_BATTERY_RT5033=y
# CONFIG_POWER_RESET is not set
CONFIG_POWER_AVS=y
CONFIG_HWMON=m
CONFIG_HWMON_VID=m
# CONFIG_HWMON_DEBUG_CHIP is not set

#
# Native drivers
#
CONFIG_SENSORS_ABITUGURU=m
# CONFIG_SENSORS_ABITUGURU3 is not set
CONFIG_SENSORS_AD7314=m
# CONFIG_SENSORS_AD7414 is not set
CONFIG_SENSORS_AD7418=m
CONFIG_SENSORS_ADM1021=m
# CONFIG_SENSORS_ADM1025 is not set
# CONFIG_SENSORS_ADM1026 is not set
CONFIG_SENSORS_ADM1029=m
CONFIG_SENSORS_ADM1031=m
CONFIG_SENSORS_ADM9240=m
CONFIG_SENSORS_ADT7X10=m
CONFIG_SENSORS_ADT7310=m
# CONFIG_SENSORS_ADT7410 is not set
# CONFIG_SENSORS_ADT7411 is not set
CONFIG_SENSORS_ADT7462=m
CONFIG_SENSORS_ADT7470=m
# CONFIG_SENSORS_ADT7475 is not set
CONFIG_SENSORS_ASC7621=m
CONFIG_SENSORS_K8TEMP=m
# CONFIG_SENSORS_K10TEMP is not set
CONFIG_SENSORS_FAM15H_POWER=m
CONFIG_SENSORS_APPLESMC=m
CONFIG_SENSORS_ASB100=m
# CONFIG_SENSORS_ATXP1 is not set
# CONFIG_SENSORS_DS620 is not set
CONFIG_SENSORS_DS1621=m
CONFIG_SENSORS_I5K_AMB=m
CONFIG_SENSORS_F71805F=m
CONFIG_SENSORS_F71882FG=m
CONFIG_SENSORS_F75375S=m
CONFIG_SENSORS_MC13783_ADC=m
# CONFIG_SENSORS_FSCHMD is not set
# CONFIG_SENSORS_GL518SM is not set
CONFIG_SENSORS_GL520SM=m
CONFIG_SENSORS_G760A=m
CONFIG_SENSORS_G762=m
CONFIG_SENSORS_GPIO_FAN=m
# CONFIG_SENSORS_HIH6130 is not set
CONFIG_SENSORS_IBMAEM=m
# CONFIG_SENSORS_IBMPEX is not set
CONFIG_SENSORS_IIO_HWMON=m
CONFIG_SENSORS_I5500=m
CONFIG_SENSORS_CORETEMP=m
CONFIG_SENSORS_IT87=m
CONFIG_SENSORS_JC42=m
# CONFIG_SENSORS_POWR1220 is not set
CONFIG_SENSORS_LINEAGE=m
CONFIG_SENSORS_LTC2945=m
CONFIG_SENSORS_LTC4151=m
CONFIG_SENSORS_LTC4215=m
CONFIG_SENSORS_LTC4222=m
CONFIG_SENSORS_LTC4245=m
CONFIG_SENSORS_LTC4260=m
# CONFIG_SENSORS_LTC4261 is not set
CONFIG_SENSORS_MAX1111=m
# CONFIG_SENSORS_MAX16065 is not set
CONFIG_SENSORS_MAX1619=m
# CONFIG_SENSORS_MAX1668 is not set
CONFIG_SENSORS_MAX197=m
# CONFIG_SENSORS_MAX6639 is not set
CONFIG_SENSORS_MAX6642=m
# CONFIG_SENSORS_MAX6650 is not set
# CONFIG_SENSORS_MAX6697 is not set
CONFIG_SENSORS_HTU21=m
CONFIG_SENSORS_MCP3021=m
# CONFIG_SENSORS_ADCXX is not set
# CONFIG_SENSORS_LM63 is not set
CONFIG_SENSORS_LM70=m
# CONFIG_SENSORS_LM73 is not set
CONFIG_SENSORS_LM75=m
# CONFIG_SENSORS_LM77 is not set
# CONFIG_SENSORS_LM78 is not set
CONFIG_SENSORS_LM80=m
# CONFIG_SENSORS_LM83 is not set
CONFIG_SENSORS_LM85=m
CONFIG_SENSORS_LM87=m
CONFIG_SENSORS_LM90=m
# CONFIG_SENSORS_LM92 is not set
CONFIG_SENSORS_LM93=m
# CONFIG_SENSORS_LM95234 is not set
CONFIG_SENSORS_LM95241=m
CONFIG_SENSORS_LM95245=m
CONFIG_SENSORS_PC87360=m
# CONFIG_SENSORS_PC87427 is not set
# CONFIG_SENSORS_NTC_THERMISTOR is not set
CONFIG_SENSORS_NCT6683=m
# CONFIG_SENSORS_NCT6775 is not set
CONFIG_SENSORS_NCT7802=m
CONFIG_SENSORS_PCF8591=m
# CONFIG_PMBUS is not set
CONFIG_SENSORS_SHT15=m
CONFIG_SENSORS_SHT21=m
CONFIG_SENSORS_SHTC1=m
CONFIG_SENSORS_SIS5595=m
CONFIG_SENSORS_DME1737=m
# CONFIG_SENSORS_EMC1403 is not set
# CONFIG_SENSORS_EMC2103 is not set
CONFIG_SENSORS_EMC6W201=m
# CONFIG_SENSORS_SMSC47M1 is not set
CONFIG_SENSORS_SMSC47M192=m
# CONFIG_SENSORS_SMSC47B397 is not set
# CONFIG_SENSORS_SCH56XX_COMMON is not set
# CONFIG_SENSORS_SMM665 is not set
# CONFIG_SENSORS_ADC128D818 is not set
CONFIG_SENSORS_ADS1015=m
# CONFIG_SENSORS_ADS7828 is not set
CONFIG_SENSORS_ADS7871=m
# CONFIG_SENSORS_AMC6821 is not set
CONFIG_SENSORS_INA209=m
# CONFIG_SENSORS_INA2XX is not set
CONFIG_SENSORS_THMC50=m
CONFIG_SENSORS_TMP102=m
# CONFIG_SENSORS_TMP103 is not set
# CONFIG_SENSORS_TMP401 is not set
CONFIG_SENSORS_TMP421=m
CONFIG_SENSORS_TWL4030_MADC=m
# CONFIG_SENSORS_VIA_CPUTEMP is not set
CONFIG_SENSORS_VIA686A=m
# CONFIG_SENSORS_VT1211 is not set
CONFIG_SENSORS_VT8231=m
CONFIG_SENSORS_W83781D=m
# CONFIG_SENSORS_W83791D is not set
CONFIG_SENSORS_W83792D=m
CONFIG_SENSORS_W83793=m
CONFIG_SENSORS_W83795=m
CONFIG_SENSORS_W83795_FANCTRL=y
# CONFIG_SENSORS_W83L785TS is not set
CONFIG_SENSORS_W83L786NG=m
CONFIG_SENSORS_W83627HF=m
CONFIG_SENSORS_W83627EHF=m
CONFIG_SENSORS_WM831X=m
# CONFIG_SENSORS_WM8350 is not set

#
# ACPI drivers
#
# CONFIG_SENSORS_ACPI_POWER is not set
# CONFIG_SENSORS_ATK0110 is not set
CONFIG_THERMAL=y
# CONFIG_THERMAL_DEFAULT_GOV_STEP_WISE is not set
CONFIG_THERMAL_DEFAULT_GOV_FAIR_SHARE=y
# CONFIG_THERMAL_DEFAULT_GOV_USER_SPACE is not set
CONFIG_THERMAL_GOV_FAIR_SHARE=y
# CONFIG_THERMAL_GOV_STEP_WISE is not set
# CONFIG_THERMAL_GOV_BANG_BANG is not set
CONFIG_THERMAL_GOV_USER_SPACE=y
# CONFIG_THERMAL_EMULATION is not set
CONFIG_INTEL_SOC_DTS_THERMAL=m
# CONFIG_INT340X_THERMAL is not set

#
# Texas Instruments thermal drivers
#
# CONFIG_WATCHDOG is not set
CONFIG_SSB_POSSIBLE=y

#
# Sonics Silicon Backplane
#
# CONFIG_SSB is not set
CONFIG_BCMA_POSSIBLE=y

#
# Broadcom specific AMBA
#
CONFIG_BCMA=m
CONFIG_BCMA_HOST_PCI_POSSIBLE=y
CONFIG_BCMA_HOST_PCI=y
CONFIG_BCMA_HOST_SOC=y
CONFIG_BCMA_DRIVER_PCI=y
CONFIG_BCMA_DRIVER_GMAC_CMN=y
CONFIG_BCMA_DRIVER_GPIO=y
# CONFIG_BCMA_DEBUG is not set

#
# Multifunction device drivers
#
CONFIG_MFD_CORE=y
CONFIG_MFD_AS3711=y
CONFIG_PMIC_ADP5520=y
CONFIG_MFD_AAT2870_CORE=y
CONFIG_MFD_BCM590XX=y
# CONFIG_MFD_AXP20X is not set
CONFIG_MFD_CROS_EC=y
# CONFIG_MFD_CROS_EC_I2C is not set
CONFIG_PMIC_DA903X=y
# CONFIG_MFD_DA9052_SPI is not set
# CONFIG_MFD_DA9052_I2C is not set
# CONFIG_MFD_DA9055 is not set
CONFIG_MFD_DA9063=y
CONFIG_MFD_DA9150=m
# CONFIG_MFD_DLN2 is not set
CONFIG_MFD_MC13XXX=y
CONFIG_MFD_MC13XXX_SPI=y
CONFIG_MFD_MC13XXX_I2C=y
CONFIG_HTC_PASIC3=m
CONFIG_HTC_I2CPLD=y
CONFIG_LPC_ICH=m
CONFIG_LPC_SCH=y
CONFIG_INTEL_SOC_PMIC=y
# CONFIG_MFD_JANZ_CMODIO is not set
CONFIG_MFD_KEMPLD=y
CONFIG_MFD_88PM800=m
CONFIG_MFD_88PM805=y
CONFIG_MFD_88PM860X=y
# CONFIG_MFD_MAX14577 is not set
# CONFIG_MFD_MAX77693 is not set
# CONFIG_MFD_MAX8907 is not set
CONFIG_MFD_MAX8925=y
# CONFIG_MFD_MAX8997 is not set
# CONFIG_MFD_MAX8998 is not set
# CONFIG_MFD_MENF21BMC is not set
# CONFIG_EZX_PCAP is not set
CONFIG_MFD_VIPERBOARD=y
CONFIG_MFD_RETU=m
CONFIG_MFD_PCF50633=y
CONFIG_PCF50633_ADC=m
# CONFIG_PCF50633_GPIO is not set
# CONFIG_UCB1400_CORE is not set
CONFIG_MFD_RDC321X=m
CONFIG_MFD_RTSX_PCI=m
CONFIG_MFD_RT5033=y
CONFIG_MFD_RTSX_USB=y
CONFIG_MFD_RC5T583=y
CONFIG_MFD_RN5T618=y
CONFIG_MFD_SEC_CORE=y
CONFIG_MFD_SI476X_CORE=y
# CONFIG_MFD_SM501 is not set
# CONFIG_MFD_SMSC is not set
CONFIG_ABX500_CORE=y
CONFIG_AB3100_CORE=y
CONFIG_AB3100_OTP=m
# CONFIG_MFD_SYSCON is not set
CONFIG_MFD_TI_AM335X_TSCADC=y
CONFIG_MFD_LP3943=m
CONFIG_MFD_LP8788=y
# CONFIG_MFD_PALMAS is not set
# CONFIG_TPS6105X is not set
# CONFIG_TPS65010 is not set
# CONFIG_TPS6507X is not set
CONFIG_MFD_TPS65090=y
CONFIG_MFD_TPS65217=y
# CONFIG_MFD_TPS65218 is not set
CONFIG_MFD_TPS6586X=y
# CONFIG_MFD_TPS65910 is not set
CONFIG_MFD_TPS65912=y
# CONFIG_MFD_TPS65912_I2C is not set
# CONFIG_MFD_TPS65912_SPI is not set
# CONFIG_MFD_TPS80031 is not set
CONFIG_TWL4030_CORE=y
CONFIG_MFD_TWL4030_AUDIO=y
# CONFIG_TWL6040_CORE is not set
CONFIG_MFD_WL1273_CORE=y
# CONFIG_MFD_LM3533 is not set
CONFIG_MFD_TC3589X=y
# CONFIG_MFD_TMIO is not set
CONFIG_MFD_VX855=y
CONFIG_MFD_ARIZONA=y
CONFIG_MFD_ARIZONA_I2C=y
CONFIG_MFD_ARIZONA_SPI=y
CONFIG_MFD_WM5102=y
CONFIG_MFD_WM5110=y
# CONFIG_MFD_WM8997 is not set
CONFIG_MFD_WM8400=y
CONFIG_MFD_WM831X=y
# CONFIG_MFD_WM831X_I2C is not set
CONFIG_MFD_WM831X_SPI=y
CONFIG_MFD_WM8350=y
CONFIG_MFD_WM8350_I2C=y
CONFIG_MFD_WM8994=y
# CONFIG_REGULATOR is not set
CONFIG_MEDIA_SUPPORT=y

#
# Multimedia core support
#
# CONFIG_MEDIA_CAMERA_SUPPORT is not set
# CONFIG_MEDIA_ANALOG_TV_SUPPORT is not set
CONFIG_MEDIA_DIGITAL_TV_SUPPORT=y
CONFIG_MEDIA_RADIO_SUPPORT=y
# CONFIG_MEDIA_SDR_SUPPORT is not set
# CONFIG_MEDIA_RC_SUPPORT is not set
CONFIG_VIDEO_DEV=y
CONFIG_VIDEO_V4L2=y
# CONFIG_VIDEO_ADV_DEBUG is not set
# CONFIG_VIDEO_FIXED_MINOR_RANGES is not set
CONFIG_DVB_CORE=y
# CONFIG_TTPCI_EEPROM is not set
CONFIG_DVB_MAX_ADAPTERS=8
# CONFIG_DVB_DYNAMIC_MINORS is not set

#
# Media drivers
#
# CONFIG_MEDIA_USB_SUPPORT is not set
# CONFIG_MEDIA_PCI_SUPPORT is not set

#
# Supported MMC/SDIO adapters
#
CONFIG_SMS_SDIO_DRV=y
CONFIG_RADIO_ADAPTERS=y
CONFIG_RADIO_TEA575X=y
CONFIG_RADIO_SI470X=y
CONFIG_USB_SI470X=m
CONFIG_I2C_SI470X=m
CONFIG_RADIO_SI4713=m
# CONFIG_USB_SI4713 is not set
CONFIG_PLATFORM_SI4713=m
CONFIG_I2C_SI4713=m
CONFIG_USB_MR800=y
# CONFIG_USB_DSBR is not set
CONFIG_RADIO_MAXIRADIO=y
CONFIG_RADIO_SHARK=m
CONFIG_RADIO_SHARK2=y
CONFIG_USB_KEENE=m
# CONFIG_USB_RAREMONO is not set
CONFIG_USB_MA901=y
CONFIG_RADIO_TEA5764=m
CONFIG_RADIO_SAA7706H=y
CONFIG_RADIO_TEF6862=y
CONFIG_RADIO_WL1273=y

#
# Texas Instruments WL128x FM driver (ST based)
#

#
# Supported FireWire (IEEE 1394) Adapters
#
CONFIG_DVB_FIREDTV=m
CONFIG_DVB_FIREDTV_INPUT=y
CONFIG_MEDIA_COMMON_OPTIONS=y

#
# common driver options
#
CONFIG_CYPRESS_FIRMWARE=y
CONFIG_SMS_SIANO_MDTV=y

#
# Media ancillary drivers (tuners, sensors, i2c, frontends)
#
CONFIG_MEDIA_SUBDRV_AUTOSELECT=y
CONFIG_MEDIA_ATTACH=y

#
# Audio decoders, processors and mixers
#

#
# RDS decoders
#

#
# Video decoders
#

#
# Video and audio decoders
#

#
# Video encoders
#

#
# Camera sensor devices
#

#
# Flash devices
#

#
# Video improvement chips
#

#
# Audio/Video compression chips
#

#
# Miscellaneous helper chips
#

#
# Sensors used on soc_camera driver
#
CONFIG_MEDIA_TUNER=y
CONFIG_MEDIA_TUNER_SIMPLE=y
CONFIG_MEDIA_TUNER_TDA8290=y
CONFIG_MEDIA_TUNER_TDA827X=y
CONFIG_MEDIA_TUNER_TDA18271=y
CONFIG_MEDIA_TUNER_TDA9887=y
CONFIG_MEDIA_TUNER_TEA5761=y
CONFIG_MEDIA_TUNER_TEA5767=y
CONFIG_MEDIA_TUNER_MT20XX=y
CONFIG_MEDIA_TUNER_XC2028=y
CONFIG_MEDIA_TUNER_XC5000=y
CONFIG_MEDIA_TUNER_XC4000=y
CONFIG_MEDIA_TUNER_MC44S803=y

#
# Multistandard (satellite) frontends
#

#
# Multistandard (cable + terrestrial) frontends
#

#
# DVB-S (satellite) frontends
#

#
# DVB-T (terrestrial) frontends
#
# CONFIG_DVB_AS102_FE is not set

#
# DVB-C (cable) frontends
#

#
# ATSC (North American/Korean Terrestrial/Cable DTV) frontends
#

#
# ISDB-T (terrestrial) frontends
#

#
# ISDB-S (satellite) & ISDB-T (terrestrial) frontends
#

#
# Digital terrestrial only tuners/PLL
#

#
# SEC control devices for DVB-S
#

#
# Tools to develop new frontends
#
# CONFIG_DVB_DUMMY_FE is not set

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
CONFIG_DRM=m
CONFIG_DRM_KMS_HELPER=m
CONFIG_DRM_KMS_FB_HELPER=y
# CONFIG_DRM_LOAD_EDID_FIRMWARE is not set
CONFIG_DRM_TTM=m

#
# I2C encoder or helper chips
#
CONFIG_DRM_I2C_ADV7511=m
# CONFIG_DRM_I2C_CH7006 is not set
# CONFIG_DRM_I2C_SIL164 is not set
CONFIG_DRM_I2C_NXP_TDA998X=m
# CONFIG_DRM_TDFX is not set
CONFIG_DRM_R128=m
CONFIG_DRM_RADEON=m
CONFIG_DRM_RADEON_UMS=y
# CONFIG_DRM_NOUVEAU is not set
# CONFIG_DRM_I915 is not set
# CONFIG_DRM_MGA is not set
# CONFIG_DRM_VIA is not set
CONFIG_DRM_SAVAGE=m
CONFIG_DRM_VMWGFX=m
# CONFIG_DRM_VMWGFX_FBCON is not set
# CONFIG_DRM_GMA500 is not set
# CONFIG_DRM_UDL is not set
CONFIG_DRM_AST=m
CONFIG_DRM_MGAG200=m
# CONFIG_DRM_CIRRUS_QEMU is not set
CONFIG_DRM_QXL=m
# CONFIG_DRM_BOCHS is not set

#
# Frame buffer Devices
#
CONFIG_FB=m
# CONFIG_FIRMWARE_EDID is not set
CONFIG_FB_CMDLINE=y
CONFIG_FB_DDC=m
# CONFIG_FB_BOOT_VESA_SUPPORT is not set
CONFIG_FB_CFB_FILLRECT=m
CONFIG_FB_CFB_COPYAREA=m
CONFIG_FB_CFB_IMAGEBLIT=m
# CONFIG_FB_CFB_REV_PIXELS_IN_BYTE is not set
CONFIG_FB_SYS_FILLRECT=m
CONFIG_FB_SYS_COPYAREA=m
CONFIG_FB_SYS_IMAGEBLIT=m
# CONFIG_FB_FOREIGN_ENDIAN is not set
CONFIG_FB_SYS_FOPS=m
CONFIG_FB_DEFERRED_IO=y
CONFIG_FB_HECUBA=m
CONFIG_FB_SVGALIB=m
# CONFIG_FB_MACMODES is not set
# CONFIG_FB_BACKLIGHT is not set
CONFIG_FB_MODE_HELPERS=y
CONFIG_FB_TILEBLITTING=y

#
# Frame buffer hardware drivers
#
# CONFIG_FB_CIRRUS is not set
CONFIG_FB_PM2=m
CONFIG_FB_PM2_FIFO_DISCONNECT=y
# CONFIG_FB_CYBER2000 is not set
CONFIG_FB_ARC=m
# CONFIG_FB_VGA16 is not set
CONFIG_FB_N411=m
CONFIG_FB_HGA=m
CONFIG_FB_OPENCORES=m
CONFIG_FB_S1D13XXX=m
CONFIG_FB_NVIDIA=m
# CONFIG_FB_NVIDIA_I2C is not set
# CONFIG_FB_NVIDIA_DEBUG is not set
# CONFIG_FB_NVIDIA_BACKLIGHT is not set
CONFIG_FB_RIVA=m
# CONFIG_FB_RIVA_I2C is not set
# CONFIG_FB_RIVA_DEBUG is not set
# CONFIG_FB_RIVA_BACKLIGHT is not set
CONFIG_FB_I740=m
CONFIG_FB_LE80578=m
CONFIG_FB_CARILLO_RANCH=m
CONFIG_FB_MATROX=m
# CONFIG_FB_MATROX_MILLENIUM is not set
# CONFIG_FB_MATROX_MYSTIQUE is not set
CONFIG_FB_MATROX_G=y
CONFIG_FB_MATROX_I2C=m
CONFIG_FB_MATROX_MAVEN=m
# CONFIG_FB_RADEON is not set
# CONFIG_FB_ATY128 is not set
CONFIG_FB_ATY=m
# CONFIG_FB_ATY_CT is not set
# CONFIG_FB_ATY_GX is not set
# CONFIG_FB_ATY_BACKLIGHT is not set
CONFIG_FB_S3=m
# CONFIG_FB_S3_DDC is not set
CONFIG_FB_SAVAGE=m
CONFIG_FB_SAVAGE_I2C=y
CONFIG_FB_SAVAGE_ACCEL=y
CONFIG_FB_SIS=m
# CONFIG_FB_SIS_300 is not set
CONFIG_FB_SIS_315=y
# CONFIG_FB_VIA is not set
# CONFIG_FB_NEOMAGIC is not set
# CONFIG_FB_KYRO is not set
# CONFIG_FB_3DFX is not set
CONFIG_FB_VOODOO1=m
CONFIG_FB_VT8623=m
CONFIG_FB_TRIDENT=m
CONFIG_FB_ARK=m
# CONFIG_FB_PM3 is not set
CONFIG_FB_CARMINE=m
CONFIG_FB_CARMINE_DRAM_EVAL=y
# CONFIG_CARMINE_DRAM_CUSTOM is not set
CONFIG_FB_SMSCUFX=m
CONFIG_FB_UDL=m
# CONFIG_FB_VIRTUAL is not set
CONFIG_FB_METRONOME=m
# CONFIG_FB_MB862XX is not set
# CONFIG_FB_BROADSHEET is not set
CONFIG_FB_AUO_K190X=m
# CONFIG_FB_AUO_K1900 is not set
CONFIG_FB_AUO_K1901=m
# CONFIG_BACKLIGHT_LCD_SUPPORT is not set
CONFIG_BACKLIGHT_CLASS_DEVICE=m
CONFIG_VGASTATE=m
CONFIG_HDMI=y
# CONFIG_LOGO is not set
CONFIG_SOUND=y
CONFIG_SOUND_OSS_CORE=y
CONFIG_SOUND_OSS_CORE_PRECLAIM=y
CONFIG_SND=y
CONFIG_SND_TIMER=y
CONFIG_SND_PCM=y
CONFIG_SND_HWDEP=y
CONFIG_SND_RAWMIDI=y
CONFIG_SND_JACK=y
CONFIG_SND_SEQUENCER=m
CONFIG_SND_SEQ_DUMMY=m
CONFIG_SND_OSSEMUL=y
CONFIG_SND_MIXER_OSS=y
CONFIG_SND_PCM_OSS=m
CONFIG_SND_PCM_OSS_PLUGINS=y
# CONFIG_SND_SEQUENCER_OSS is not set
# CONFIG_SND_DYNAMIC_MINORS is not set
# CONFIG_SND_SUPPORT_OLD_API is not set
CONFIG_SND_VERBOSE_PROCFS=y
CONFIG_SND_VERBOSE_PRINTK=y
CONFIG_SND_DEBUG=y
CONFIG_SND_DEBUG_VERBOSE=y
# CONFIG_SND_PCM_XRUN_DEBUG is not set
CONFIG_SND_VMASTER=y
CONFIG_SND_KCTL_JACK=y
CONFIG_SND_DMA_SGBUF=y
CONFIG_SND_RAWMIDI_SEQ=m
CONFIG_SND_OPL3_LIB_SEQ=m
# CONFIG_SND_OPL4_LIB_SEQ is not set
# CONFIG_SND_SBAWE_SEQ is not set
# CONFIG_SND_EMU10K1_SEQ is not set
CONFIG_SND_MPU401_UART=y
CONFIG_SND_OPL3_LIB=y
CONFIG_SND_VX_LIB=y
CONFIG_SND_AC97_CODEC=y
# CONFIG_SND_DRIVERS is not set
CONFIG_SND_PCI=y
# CONFIG_SND_AD1889 is not set
CONFIG_SND_ALS300=m
# CONFIG_SND_ALI5451 is not set
# CONFIG_SND_ASIHPI is not set
# CONFIG_SND_ATIIXP is not set
CONFIG_SND_ATIIXP_MODEM=m
# CONFIG_SND_AU8810 is not set
# CONFIG_SND_AU8820 is not set
# CONFIG_SND_AU8830 is not set
CONFIG_SND_AW2=y
# CONFIG_SND_AZT3328 is not set
CONFIG_SND_BT87X=y
# CONFIG_SND_BT87X_OVERCLOCK is not set
# CONFIG_SND_CA0106 is not set
# CONFIG_SND_CMIPCI is not set
CONFIG_SND_OXYGEN_LIB=y
CONFIG_SND_OXYGEN=y
# CONFIG_SND_CS4281 is not set
CONFIG_SND_CS46XX=m
# CONFIG_SND_CS46XX_NEW_DSP is not set
CONFIG_SND_CTXFI=y
CONFIG_SND_DARLA20=y
CONFIG_SND_GINA20=m
CONFIG_SND_LAYLA20=y
# CONFIG_SND_DARLA24 is not set
# CONFIG_SND_GINA24 is not set
CONFIG_SND_LAYLA24=y
# CONFIG_SND_MONA is not set
CONFIG_SND_MIA=m
CONFIG_SND_ECHO3G=y
# CONFIG_SND_INDIGO is not set
# CONFIG_SND_INDIGOIO is not set
CONFIG_SND_INDIGODJ=m
# CONFIG_SND_INDIGOIOX is not set
# CONFIG_SND_INDIGODJX is not set
# CONFIG_SND_EMU10K1 is not set
# CONFIG_SND_EMU10K1X is not set
CONFIG_SND_ENS1370=y
# CONFIG_SND_ENS1371 is not set
CONFIG_SND_ES1938=m
# CONFIG_SND_ES1968 is not set
CONFIG_SND_FM801=y
# CONFIG_SND_FM801_TEA575X_BOOL is not set
# CONFIG_SND_HDSP is not set
# CONFIG_SND_HDSPM is not set
# CONFIG_SND_ICE1712 is not set
CONFIG_SND_ICE1724=y
# CONFIG_SND_INTEL8X0 is not set
CONFIG_SND_INTEL8X0M=m
CONFIG_SND_KORG1212=y
CONFIG_SND_LOLA=m
CONFIG_SND_LX6464ES=y
# CONFIG_SND_MAESTRO3 is not set
CONFIG_SND_MIXART=m
CONFIG_SND_NM256=m
CONFIG_SND_PCXHR=y
# CONFIG_SND_RIPTIDE is not set
CONFIG_SND_RME32=y
# CONFIG_SND_RME96 is not set
# CONFIG_SND_RME9652 is not set
CONFIG_SND_SONICVIBES=m
CONFIG_SND_TRIDENT=y
CONFIG_SND_VIA82XX=y
CONFIG_SND_VIA82XX_MODEM=m
# CONFIG_SND_VIRTUOSO is not set
CONFIG_SND_VX222=y
CONFIG_SND_YMFPCI=y

#
# HD-Audio
#
CONFIG_SND_HDA=m
CONFIG_SND_HDA_INTEL=m
CONFIG_SND_HDA_DSP_LOADER=y
CONFIG_SND_HDA_PREALLOC_SIZE=64
# CONFIG_SND_HDA_HWDEP is not set
CONFIG_SND_HDA_RECONFIG=y
CONFIG_SND_HDA_INPUT_BEEP=y
CONFIG_SND_HDA_INPUT_BEEP_MODE=1
CONFIG_SND_HDA_INPUT_JACK=y
CONFIG_SND_HDA_PATCH_LOADER=y
# CONFIG_SND_HDA_CODEC_REALTEK is not set
CONFIG_SND_HDA_CODEC_ANALOG=m
CONFIG_SND_HDA_CODEC_SIGMATEL=m
CONFIG_SND_HDA_CODEC_VIA=m
CONFIG_SND_HDA_CODEC_HDMI=m
# CONFIG_SND_HDA_CODEC_CIRRUS is not set
# CONFIG_SND_HDA_CODEC_CONEXANT is not set
CONFIG_SND_HDA_CODEC_CA0110=m
CONFIG_SND_HDA_CODEC_CA0132=m
CONFIG_SND_HDA_CODEC_CA0132_DSP=y
CONFIG_SND_HDA_CODEC_CMEDIA=m
CONFIG_SND_HDA_CODEC_SI3054=m
CONFIG_SND_HDA_GENERIC=m
CONFIG_SND_SPI=y
# CONFIG_SND_USB is not set
# CONFIG_SND_FIREWIRE is not set
# CONFIG_SND_SOC is not set
CONFIG_SOUND_PRIME=m
CONFIG_AC97_BUS=y

#
# HID support
#
# CONFIG_HID is not set

#
# USB HID support
#
# CONFIG_USB_HID is not set
CONFIG_HID_PID=y

#
# USB HID Boot Protocol drivers
#
CONFIG_USB_KBD=y
CONFIG_USB_MOUSE=y

#
# I2C HID support
#
# CONFIG_I2C_HID is not set
CONFIG_USB_OHCI_LITTLE_ENDIAN=y
CONFIG_USB_SUPPORT=y
CONFIG_USB_COMMON=y
CONFIG_USB_ARCH_HAS_HCD=y
CONFIG_USB=y
CONFIG_USB_ANNOUNCE_NEW_DEVICES=y

#
# Miscellaneous USB options
#
CONFIG_USB_DEFAULT_PERSIST=y
# CONFIG_USB_DYNAMIC_MINORS is not set
CONFIG_USB_OTG=y
CONFIG_USB_OTG_WHITELIST=y
CONFIG_USB_OTG_BLACKLIST_HUB=y
CONFIG_USB_OTG_FSM=y
CONFIG_USB_MON=m
CONFIG_USB_WUSB=m
# CONFIG_USB_WUSB_CBAF is not set

#
# USB Host Controller Drivers
#
# CONFIG_USB_C67X00_HCD is not set
# CONFIG_USB_XHCI_HCD is not set
CONFIG_USB_EHCI_HCD=y
# CONFIG_USB_EHCI_ROOT_HUB_TT is not set
CONFIG_USB_EHCI_TT_NEWSCHED=y
CONFIG_USB_EHCI_PCI=y
CONFIG_USB_EHCI_HCD_PLATFORM=y
# CONFIG_USB_OXU210HP_HCD is not set
CONFIG_USB_ISP116X_HCD=y
CONFIG_USB_ISP1362_HCD=m
CONFIG_USB_FUSBH200_HCD=m
CONFIG_USB_FOTG210_HCD=m
CONFIG_USB_MAX3421_HCD=y
CONFIG_USB_OHCI_HCD=m
CONFIG_USB_OHCI_HCD_PCI=m
CONFIG_USB_OHCI_HCD_PLATFORM=m
CONFIG_USB_UHCI_HCD=m
CONFIG_USB_U132_HCD=y
CONFIG_USB_SL811_HCD=y
CONFIG_USB_SL811_HCD_ISO=y
CONFIG_USB_R8A66597_HCD=m
CONFIG_USB_WHCI_HCD=m
# CONFIG_USB_HWA_HCD is not set
CONFIG_USB_HCD_BCMA=m
CONFIG_USB_HCD_TEST_MODE=y

#
# USB Device Class drivers
#
CONFIG_USB_ACM=y
CONFIG_USB_PRINTER=m
CONFIG_USB_WDM=m
# CONFIG_USB_TMC is not set

#
# NOTE: USB_STORAGE depends on SCSI but BLK_DEV_SD may
#

#
# also be needed; see USB_STORAGE Help for more info
#
CONFIG_USB_STORAGE=y
CONFIG_USB_STORAGE_DEBUG=y
CONFIG_USB_STORAGE_REALTEK=m
# CONFIG_USB_STORAGE_DATAFAB is not set
CONFIG_USB_STORAGE_FREECOM=y
CONFIG_USB_STORAGE_ISD200=m
# CONFIG_USB_STORAGE_USBAT is not set
# CONFIG_USB_STORAGE_SDDR09 is not set
CONFIG_USB_STORAGE_SDDR55=m
CONFIG_USB_STORAGE_JUMPSHOT=y
CONFIG_USB_STORAGE_ALAUDA=y
CONFIG_USB_STORAGE_ONETOUCH=m
# CONFIG_USB_STORAGE_KARMA is not set
# CONFIG_USB_STORAGE_CYPRESS_ATACB is not set
CONFIG_USB_STORAGE_ENE_UB6250=m
CONFIG_USB_UAS=m

#
# USB Imaging devices
#
# CONFIG_USB_MDC800 is not set
CONFIG_USB_MICROTEK=m
# CONFIG_USBIP_CORE is not set
CONFIG_USB_MUSB_HDRC=y
CONFIG_USB_MUSB_HOST=y

#
# Platform Glue Layer
#
CONFIG_MUSB_PIO_ONLY=y
CONFIG_USB_DWC3=m
# CONFIG_USB_DWC3_HOST is not set
CONFIG_USB_DWC3_GADGET=y
# CONFIG_USB_DWC3_DUAL_ROLE is not set

#
# Platform Glue Driver Support
#
CONFIG_USB_DWC3_PCI=m

#
# Debugging features
#
# CONFIG_USB_DWC3_DEBUG is not set
CONFIG_USB_DWC2=m
# CONFIG_USB_DWC2_HOST is not set

#
# Gadget/Dual-role mode requires USB Gadget support to be enabled
#
# CONFIG_USB_DWC2_PERIPHERAL is not set
CONFIG_USB_DWC2_DUAL_ROLE=y
CONFIG_USB_DWC2_PLATFORM=m
CONFIG_USB_DWC2_DEBUG=y
CONFIG_USB_DWC2_VERBOSE=y
# CONFIG_USB_DWC2_TRACK_MISSED_SOFS is not set
# CONFIG_USB_DWC2_DEBUG_PERIODIC is not set
CONFIG_USB_CHIPIDEA=m
# CONFIG_USB_CHIPIDEA_UDC is not set
# CONFIG_USB_CHIPIDEA_HOST is not set
# CONFIG_USB_CHIPIDEA_DEBUG is not set
CONFIG_USB_ISP1760=y
CONFIG_USB_ISP1760_HCD=y
CONFIG_USB_ISP1760_HOST_ROLE=y

#
# USB port drivers
#
# CONFIG_USB_USS720 is not set
CONFIG_USB_SERIAL=m
# CONFIG_USB_SERIAL_GENERIC is not set
CONFIG_USB_SERIAL_SIMPLE=m
CONFIG_USB_SERIAL_AIRCABLE=m
CONFIG_USB_SERIAL_ARK3116=m
# CONFIG_USB_SERIAL_BELKIN is not set
CONFIG_USB_SERIAL_CH341=m
# CONFIG_USB_SERIAL_WHITEHEAT is not set
# CONFIG_USB_SERIAL_DIGI_ACCELEPORT is not set
# CONFIG_USB_SERIAL_CP210X is not set
CONFIG_USB_SERIAL_CYPRESS_M8=m
CONFIG_USB_SERIAL_EMPEG=m
CONFIG_USB_SERIAL_FTDI_SIO=m
# CONFIG_USB_SERIAL_VISOR is not set
# CONFIG_USB_SERIAL_IPAQ is not set
CONFIG_USB_SERIAL_IR=m
# CONFIG_USB_SERIAL_EDGEPORT is not set
# CONFIG_USB_SERIAL_EDGEPORT_TI is not set
CONFIG_USB_SERIAL_F81232=m
# CONFIG_USB_SERIAL_GARMIN is not set
# CONFIG_USB_SERIAL_IPW is not set
CONFIG_USB_SERIAL_IUU=m
CONFIG_USB_SERIAL_KEYSPAN_PDA=m
# CONFIG_USB_SERIAL_KEYSPAN is not set
CONFIG_USB_SERIAL_KLSI=m
CONFIG_USB_SERIAL_KOBIL_SCT=m
# CONFIG_USB_SERIAL_MCT_U232 is not set
CONFIG_USB_SERIAL_METRO=m
CONFIG_USB_SERIAL_MOS7720=m
CONFIG_USB_SERIAL_MOS7715_PARPORT=y
CONFIG_USB_SERIAL_MOS7840=m
# CONFIG_USB_SERIAL_MXUPORT is not set
# CONFIG_USB_SERIAL_NAVMAN is not set
CONFIG_USB_SERIAL_PL2303=m
CONFIG_USB_SERIAL_OTI6858=m
# CONFIG_USB_SERIAL_QCAUX is not set
# CONFIG_USB_SERIAL_QUALCOMM is not set
CONFIG_USB_SERIAL_SPCP8X5=m
# CONFIG_USB_SERIAL_SAFE is not set
CONFIG_USB_SERIAL_SIERRAWIRELESS=m
# CONFIG_USB_SERIAL_SYMBOL is not set
CONFIG_USB_SERIAL_TI=m
# CONFIG_USB_SERIAL_CYBERJACK is not set
# CONFIG_USB_SERIAL_XIRCOM is not set
CONFIG_USB_SERIAL_WWAN=m
CONFIG_USB_SERIAL_OPTION=m
CONFIG_USB_SERIAL_OMNINET=m
# CONFIG_USB_SERIAL_OPTICON is not set
CONFIG_USB_SERIAL_XSENS_MT=m
CONFIG_USB_SERIAL_WISHBONE=m
CONFIG_USB_SERIAL_SSU100=m
CONFIG_USB_SERIAL_QT2=m
# CONFIG_USB_SERIAL_DEBUG is not set

#
# USB Miscellaneous drivers
#
# CONFIG_USB_EMI62 is not set
CONFIG_USB_EMI26=m
CONFIG_USB_ADUTUX=y
CONFIG_USB_SEVSEG=m
# CONFIG_USB_RIO500 is not set
# CONFIG_USB_LEGOTOWER is not set
# CONFIG_USB_LCD is not set
# CONFIG_USB_LED is not set
CONFIG_USB_CYPRESS_CY7C63=m
CONFIG_USB_CYTHERM=m
CONFIG_USB_IDMOUSE=m
CONFIG_USB_FTDI_ELAN=y
# CONFIG_USB_APPLEDISPLAY is not set
CONFIG_USB_SISUSBVGA=m
# CONFIG_USB_LD is not set
CONFIG_USB_TRANCEVIBRATOR=m
CONFIG_USB_IOWARRIOR=m
# CONFIG_USB_TEST is not set
CONFIG_USB_EHSET_TEST_FIXTURE=m
# CONFIG_USB_ISIGHTFW is not set
CONFIG_USB_YUREX=y
CONFIG_USB_EZUSB_FX2=m
CONFIG_USB_HSIC_USB3503=y
CONFIG_USB_LINK_LAYER_TEST=m

#
# USB Physical Layer drivers
#
CONFIG_USB_PHY=y
CONFIG_NOP_USB_XCEIV=y
CONFIG_USB_GPIO_VBUS=y
# CONFIG_TAHVO_USB is not set
# CONFIG_USB_ISP1301 is not set
CONFIG_USB_GADGET=m
# CONFIG_USB_GADGET_DEBUG is not set
# CONFIG_USB_GADGET_DEBUG_FILES is not set
CONFIG_USB_GADGET_DEBUG_FS=y
CONFIG_USB_GADGET_VBUS_DRAW=2
CONFIG_USB_GADGET_STORAGE_NUM_BUFFERS=2

#
# USB Peripheral Controller
#
# CONFIG_USB_FOTG210_UDC is not set
CONFIG_USB_GR_UDC=m
# CONFIG_USB_R8A66597 is not set
CONFIG_USB_PXA27X=m
CONFIG_USB_MV_UDC=m
CONFIG_USB_MV_U3D=m
CONFIG_USB_M66592=m
CONFIG_USB_BDC_UDC=m

#
# Platform Support
#
CONFIG_USB_BDC_PCI=m
# CONFIG_USB_AMD5536UDC is not set
CONFIG_USB_NET2272=m
# CONFIG_USB_NET2272_DMA is not set
CONFIG_USB_NET2280=m
CONFIG_USB_GOKU=m
CONFIG_USB_EG20T=m
CONFIG_USB_DUMMY_HCD=m
CONFIG_USB_LIBCOMPOSITE=m
CONFIG_USB_F_ACM=m
CONFIG_USB_U_SERIAL=m
CONFIG_USB_F_SERIAL=m
CONFIG_USB_F_OBEX=m
CONFIG_USB_F_MASS_STORAGE=m
CONFIG_USB_F_FS=m
CONFIG_USB_F_UAC1=m
CONFIG_USB_F_UAC2=m
CONFIG_USB_F_MIDI=m
CONFIG_USB_F_HID=m
CONFIG_USB_CONFIGFS=m
CONFIG_USB_CONFIGFS_SERIAL=y
# CONFIG_USB_CONFIGFS_ACM is not set
CONFIG_USB_CONFIGFS_OBEX=y
# CONFIG_USB_CONFIGFS_NCM is not set
# CONFIG_USB_CONFIGFS_ECM is not set
# CONFIG_USB_CONFIGFS_ECM_SUBSET is not set
# CONFIG_USB_CONFIGFS_RNDIS is not set
# CONFIG_USB_CONFIGFS_EEM is not set
CONFIG_USB_CONFIGFS_MASS_STORAGE=y
# CONFIG_USB_CONFIGFS_F_LB_SS is not set
CONFIG_USB_CONFIGFS_F_FS=y
CONFIG_USB_CONFIGFS_F_UAC1=y
CONFIG_USB_CONFIGFS_F_UAC2=y
CONFIG_USB_CONFIGFS_F_MIDI=y
CONFIG_USB_CONFIGFS_F_HID=y
# CONFIG_USB_CONFIGFS_F_UVC is not set
# CONFIG_USB_ZERO is not set
# CONFIG_USB_AUDIO is not set
# CONFIG_USB_ETH is not set
# CONFIG_USB_G_NCM is not set
# CONFIG_USB_GADGETFS is not set
CONFIG_USB_FUNCTIONFS=m
# CONFIG_USB_FUNCTIONFS_ETH is not set
# CONFIG_USB_FUNCTIONFS_RNDIS is not set
CONFIG_USB_FUNCTIONFS_GENERIC=y
CONFIG_USB_MASS_STORAGE=m
CONFIG_USB_GADGET_TARGET=m
# CONFIG_USB_G_SERIAL is not set
CONFIG_USB_MIDI_GADGET=m
CONFIG_USB_G_PRINTER=m
# CONFIG_USB_CDC_COMPOSITE is not set
CONFIG_USB_G_ACM_MS=m
# CONFIG_USB_G_MULTI is not set
CONFIG_USB_G_HID=m
CONFIG_USB_G_DBGP=m
CONFIG_USB_G_DBGP_PRINTK=y
# CONFIG_USB_G_DBGP_SERIAL is not set
# CONFIG_USB_G_WEBCAM is not set
CONFIG_USB_LED_TRIG=y
CONFIG_UWB=m
# CONFIG_UWB_HWA is not set
CONFIG_UWB_WHCI=m
CONFIG_MMC=y
# CONFIG_MMC_DEBUG is not set
# CONFIG_MMC_CLKGATE is not set

#
# MMC/SD/SDIO Card Drivers
#
CONFIG_MMC_BLOCK=y
CONFIG_MMC_BLOCK_MINORS=8
CONFIG_MMC_BLOCK_BOUNCE=y
CONFIG_SDIO_UART=m
CONFIG_MMC_TEST=m

#
# MMC/SD/SDIO Host Controller Drivers
#
# CONFIG_MMC_SDHCI is not set
CONFIG_MMC_TIFM_SD=m
CONFIG_MMC_SPI=y
CONFIG_MMC_CB710=y
# CONFIG_MMC_VIA_SDMMC is not set
CONFIG_MMC_VUB300=m
# CONFIG_MMC_USHC is not set
# CONFIG_MMC_USDHI6ROL0 is not set
# CONFIG_MMC_REALTEK_PCI is not set
CONFIG_MMC_REALTEK_USB=m
CONFIG_MMC_TOSHIBA_PCI=y
CONFIG_MEMSTICK=y
# CONFIG_MEMSTICK_DEBUG is not set

#
# MemoryStick drivers
#
CONFIG_MEMSTICK_UNSAFE_RESUME=y
CONFIG_MSPRO_BLOCK=m
CONFIG_MS_BLOCK=y

#
# MemoryStick Host Controller Drivers
#
# CONFIG_MEMSTICK_TIFM_MS is not set
CONFIG_MEMSTICK_JMICRON_38X=m
CONFIG_MEMSTICK_R592=m
# CONFIG_MEMSTICK_REALTEK_PCI is not set
CONFIG_MEMSTICK_REALTEK_USB=m
CONFIG_NEW_LEDS=y
CONFIG_LEDS_CLASS=m
# CONFIG_LEDS_CLASS_FLASH is not set

#
# LED drivers
#
CONFIG_LEDS_88PM860X=m
CONFIG_LEDS_LM3530=m
CONFIG_LEDS_LM3642=m
CONFIG_LEDS_PCA9532=m
# CONFIG_LEDS_PCA9532_GPIO is not set
CONFIG_LEDS_GPIO=m
# CONFIG_LEDS_LP3944 is not set
CONFIG_LEDS_LP55XX_COMMON=m
CONFIG_LEDS_LP5521=m
CONFIG_LEDS_LP5523=m
CONFIG_LEDS_LP5562=m
CONFIG_LEDS_LP8501=m
CONFIG_LEDS_LP8788=m
# CONFIG_LEDS_LP8860 is not set
CONFIG_LEDS_CLEVO_MAIL=m
# CONFIG_LEDS_PCA955X is not set
CONFIG_LEDS_PCA963X=m
CONFIG_LEDS_WM831X_STATUS=m
CONFIG_LEDS_WM8350=m
CONFIG_LEDS_DA903X=m
CONFIG_LEDS_DAC124S085=m
CONFIG_LEDS_PWM=m
CONFIG_LEDS_BD2802=m
CONFIG_LEDS_INTEL_SS4200=m
CONFIG_LEDS_LT3593=m
# CONFIG_LEDS_ADP5520 is not set
CONFIG_LEDS_MC13783=m
CONFIG_LEDS_TCA6507=m
CONFIG_LEDS_LM355x=m

#
# LED driver for blink(1) USB RGB LED is under Special HID drivers (HID_THINGM)
#
CONFIG_LEDS_BLINKM=m

#
# LED Triggers
#
CONFIG_LEDS_TRIGGERS=y
CONFIG_LEDS_TRIGGER_TIMER=m
# CONFIG_LEDS_TRIGGER_ONESHOT is not set
CONFIG_LEDS_TRIGGER_HEARTBEAT=m
CONFIG_LEDS_TRIGGER_BACKLIGHT=m
CONFIG_LEDS_TRIGGER_CPU=y
CONFIG_LEDS_TRIGGER_GPIO=m
CONFIG_LEDS_TRIGGER_DEFAULT_ON=y

#
# iptables trigger is under Netfilter config (LED target)
#
CONFIG_LEDS_TRIGGER_TRANSIENT=y
CONFIG_LEDS_TRIGGER_CAMERA=y
# CONFIG_ACCESSIBILITY is not set
CONFIG_EDAC=y
CONFIG_EDAC_LEGACY_SYSFS=y
# CONFIG_EDAC_DEBUG is not set
# CONFIG_EDAC_MM_EDAC is not set
CONFIG_RTC_LIB=y
# CONFIG_RTC_CLASS is not set
CONFIG_DMADEVICES=y
# CONFIG_DMADEVICES_DEBUG is not set

#
# DMA Devices
#
CONFIG_INTEL_MIC_X100_DMA=y
# CONFIG_INTEL_MID_DMAC is not set
CONFIG_INTEL_IOATDMA=m
CONFIG_DW_DMAC_CORE=y
CONFIG_DW_DMAC=y
CONFIG_DW_DMAC_PCI=m
CONFIG_DMA_ENGINE=y
CONFIG_DMA_ACPI=y

#
# DMA Clients
#
CONFIG_ASYNC_TX_DMA=y
CONFIG_DMATEST=m
CONFIG_DMA_ENGINE_RAID=y
CONFIG_DCA=m
CONFIG_AUXDISPLAY=y
CONFIG_KS0108=m
CONFIG_KS0108_PORT=0x378
CONFIG_KS0108_DELAY=2
# CONFIG_CFAG12864B is not set
CONFIG_UIO=y
CONFIG_UIO_CIF=m
# CONFIG_UIO_PDRV_GENIRQ is not set
CONFIG_UIO_DMEM_GENIRQ=m
CONFIG_UIO_AEC=m
# CONFIG_UIO_SERCOS3 is not set
CONFIG_UIO_PCI_GENERIC=m
CONFIG_UIO_NETX=m
# CONFIG_UIO_MF624 is not set
CONFIG_VIRT_DRIVERS=y
CONFIG_VIRTIO=y

#
# Virtio drivers
#
CONFIG_VIRTIO_PCI=m
# CONFIG_VIRTIO_PCI_LEGACY is not set
CONFIG_VIRTIO_BALLOON=m
CONFIG_VIRTIO_MMIO=y
CONFIG_VIRTIO_MMIO_CMDLINE_DEVICES=y

#
# Microsoft Hyper-V guest support
#
# CONFIG_HYPERV is not set
CONFIG_STAGING=y
# CONFIG_SLICOSS is not set
# CONFIG_COMEDI is not set
CONFIG_PANEL=m
CONFIG_PANEL_PARPORT=0
CONFIG_PANEL_PROFILE=5
CONFIG_PANEL_CHANGE_MESSAGE=y
CONFIG_PANEL_BOOT_MESSAGE=""
CONFIG_RTS5208=m

#
# IIO staging drivers
#

#
# Accelerometers
#
CONFIG_ADIS16201=y
CONFIG_ADIS16203=m
CONFIG_ADIS16204=y
CONFIG_ADIS16209=y
# CONFIG_ADIS16220 is not set
# CONFIG_ADIS16240 is not set
CONFIG_LIS3L02DQ=y
CONFIG_SCA3000=m

#
# Analog to digital converters
#
# CONFIG_AD7606 is not set
# CONFIG_AD7780 is not set
CONFIG_AD7816=y
CONFIG_AD7192=y
CONFIG_AD7280=y

#
# Analog digital bi-direction converters
#
CONFIG_ADT7316=m
CONFIG_ADT7316_SPI=m
CONFIG_ADT7316_I2C=m

#
# Capacitance to digital converters
#
CONFIG_AD7150=y
CONFIG_AD7152=y
# CONFIG_AD7746 is not set

#
# Direct Digital Synthesis
#
CONFIG_AD9832=y
CONFIG_AD9834=y

#
# Digital gyroscope sensors
#
CONFIG_ADIS16060=m

#
# Network Analyzer, Impedance Converters
#
# CONFIG_AD5933 is not set

#
# Light sensors
#
CONFIG_SENSORS_ISL29018=y
# CONFIG_SENSORS_ISL29028 is not set
CONFIG_TSL2583=y
# CONFIG_TSL2x7x is not set

#
# Magnetometer sensors
#
CONFIG_SENSORS_HMC5843=m
CONFIG_SENSORS_HMC5843_I2C=m
CONFIG_SENSORS_HMC5843_SPI=m

#
# Active energy metering IC
#
# CONFIG_ADE7753 is not set
CONFIG_ADE7754=y
CONFIG_ADE7758=m
# CONFIG_ADE7759 is not set
CONFIG_ADE7854=y
CONFIG_ADE7854_I2C=y
CONFIG_ADE7854_SPI=m

#
# Resolver to digital converters
#
CONFIG_AD2S90=y
CONFIG_AD2S1200=m
# CONFIG_AD2S1210 is not set

#
# Triggers - standalone
#
CONFIG_IIO_SIMPLE_DUMMY=y
# CONFIG_IIO_SIMPLE_DUMMY_EVENTS is not set
# CONFIG_IIO_SIMPLE_DUMMY_BUFFER is not set
CONFIG_FB_SM7XX=m
CONFIG_FB_XGI=m
CONFIG_FT1000=m
# CONFIG_FT1000_USB is not set

#
# Speakup console speech
#
CONFIG_TOUCHSCREEN_SYNAPTICS_I2C_RMI4=m
# CONFIG_STAGING_MEDIA is not set

#
# Android
#
# CONFIG_USB_WPAN_HCD is not set
# CONFIG_WIMAX_GDM72XX is not set
# CONFIG_LTE_GDM724X is not set
CONFIG_FIREWIRE_SERIAL=m
CONFIG_FWTTY_MAX_TOTAL_PORTS=64
CONFIG_FWTTY_MAX_CARD_PORTS=32
CONFIG_MTD_SPINAND_MT29F=m
# CONFIG_MTD_SPINAND_ONDIEECC is not set
# CONFIG_DGNC is not set
# CONFIG_DGAP is not set
CONFIG_GS_FPGABOOT=y
CONFIG_CRYPTO_SKEIN=m
CONFIG_UNISYSSPAR=y
CONFIG_UNISYS_VISORUTIL=m
CONFIG_UNISYS_VISORCHANNEL=m
# CONFIG_UNISYS_VISORCHIPSET is not set
# CONFIG_FB_TFT is not set
CONFIG_I2O=y
# CONFIG_I2O_LCT_NOTIFY_ON_CHANGES is not set
# CONFIG_I2O_EXT_ADAPTEC is not set
# CONFIG_I2O_CONFIG is not set
CONFIG_I2O_BUS=y
# CONFIG_I2O_BLOCK is not set
# CONFIG_I2O_SCSI is not set
CONFIG_I2O_PROC=y
# CONFIG_X86_PLATFORM_DEVICES is not set
# CONFIG_CHROME_PLATFORMS is not set

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
# CONFIG_IOMMU_SUPPORT is not set

#
# Remoteproc drivers
#
CONFIG_REMOTEPROC=y
CONFIG_STE_MODEM_RPROC=y

#
# Rpmsg drivers
#

#
# SOC (System On Chip) specific Drivers
#
CONFIG_SOC_TI=y
CONFIG_PM_DEVFREQ=y

#
# DEVFREQ Governors
#
CONFIG_DEVFREQ_GOV_SIMPLE_ONDEMAND=y
# CONFIG_DEVFREQ_GOV_PERFORMANCE is not set
CONFIG_DEVFREQ_GOV_POWERSAVE=y
CONFIG_DEVFREQ_GOV_USERSPACE=m

#
# DEVFREQ Drivers
#
# CONFIG_PM_DEVFREQ_EVENT is not set
CONFIG_EXTCON=y

#
# Extcon Device Drivers
#
CONFIG_EXTCON_ADC_JACK=y
CONFIG_EXTCON_GPIO=y
# CONFIG_EXTCON_RT8973A is not set
# CONFIG_EXTCON_SM5502 is not set
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
CONFIG_BMA180=m
CONFIG_BMC150_ACCEL=y
CONFIG_IIO_ST_ACCEL_3AXIS=m
CONFIG_IIO_ST_ACCEL_I2C_3AXIS=m
CONFIG_IIO_ST_ACCEL_SPI_3AXIS=m
CONFIG_KXSD9=y
# CONFIG_MMA8452 is not set
CONFIG_KXCJK1013=m
CONFIG_MMA9551_CORE=y
CONFIG_MMA9551=y
# CONFIG_MMA9553 is not set

#
# Analog to digital converters
#
CONFIG_AD_SIGMA_DELTA=y
# CONFIG_AD7266 is not set
CONFIG_AD7291=y
CONFIG_AD7298=y
CONFIG_AD7476=y
CONFIG_AD7791=m
# CONFIG_AD7793 is not set
CONFIG_AD7887=m
CONFIG_AD7923=m
CONFIG_AD799X=m
# CONFIG_CC10001_ADC is not set
CONFIG_LP8788_ADC=m
# CONFIG_MAX1027 is not set
CONFIG_MAX1363=y
CONFIG_MCP320X=y
# CONFIG_MCP3422 is not set
# CONFIG_NAU7802 is not set
# CONFIG_TI_ADC081C is not set
CONFIG_TI_ADC128S052=y
CONFIG_TI_AM335X_ADC=y
CONFIG_TWL4030_MADC=y
# CONFIG_TWL6030_GPADC is not set
CONFIG_VIPERBOARD_ADC=y

#
# Amplifiers
#
# CONFIG_AD8366 is not set

#
# Hid Sensor IIO Common
#

#
# SSP Sensor Common
#
# CONFIG_IIO_SSP_SENSORS_COMMONS is not set
CONFIG_IIO_SSP_SENSORHUB=y
CONFIG_IIO_ST_SENSORS_I2C=y
CONFIG_IIO_ST_SENSORS_SPI=y
CONFIG_IIO_ST_SENSORS_CORE=y

#
# Digital to analog converters
#
CONFIG_AD5064=y
# CONFIG_AD5360 is not set
# CONFIG_AD5380 is not set
# CONFIG_AD5421 is not set
# CONFIG_AD5446 is not set
# CONFIG_AD5449 is not set
# CONFIG_AD5504 is not set
# CONFIG_AD5624R_SPI is not set
CONFIG_AD5686=m
# CONFIG_AD5755 is not set
CONFIG_AD5764=y
CONFIG_AD5791=y
CONFIG_AD7303=y
# CONFIG_MAX517 is not set
# CONFIG_MCP4725 is not set
# CONFIG_MCP4922 is not set

#
# Frequency Synthesizers DDS/PLL
#

#
# Clock Generator/Distribution
#
# CONFIG_AD9523 is not set

#
# Phase-Locked Loop (PLL) frequency synthesizers
#
CONFIG_ADF4350=y

#
# Digital gyroscope sensors
#
# CONFIG_ADIS16080 is not set
CONFIG_ADIS16130=y
CONFIG_ADIS16136=m
CONFIG_ADIS16260=y
# CONFIG_ADXRS450 is not set
# CONFIG_BMG160 is not set
CONFIG_IIO_ST_GYRO_3AXIS=m
CONFIG_IIO_ST_GYRO_I2C_3AXIS=m
CONFIG_IIO_ST_GYRO_SPI_3AXIS=m
CONFIG_ITG3200=y

#
# Humidity sensors
#
CONFIG_DHT11=y
CONFIG_SI7005=y
CONFIG_SI7020=m

#
# Inertial measurement units
#
CONFIG_ADIS16400=y
CONFIG_ADIS16480=m
CONFIG_KMX61=y
# CONFIG_INV_MPU6050_IIO is not set
CONFIG_IIO_ADIS_LIB=y
CONFIG_IIO_ADIS_LIB_BUFFER=y

#
# Light sensors
#
CONFIG_ADJD_S311=m
# CONFIG_AL3320A is not set
CONFIG_APDS9300=y
CONFIG_CM32181=y
# CONFIG_CM3232 is not set
CONFIG_CM36651=y
# CONFIG_GP2AP020A00F is not set
CONFIG_ISL29125=y
CONFIG_JSA1212=y
CONFIG_LTR501=m
CONFIG_TCS3414=m
CONFIG_TCS3472=y
# CONFIG_SENSORS_TSL2563 is not set
CONFIG_TSL4531=m
CONFIG_VCNL4000=y

#
# Magnetometer sensors
#
CONFIG_AK8975=y
CONFIG_AK09911=y
# CONFIG_MAG3110 is not set
CONFIG_IIO_ST_MAGN_3AXIS=m
CONFIG_IIO_ST_MAGN_I2C_3AXIS=m
CONFIG_IIO_ST_MAGN_SPI_3AXIS=m

#
# Inclinometer sensors
#

#
# Triggers - standalone
#
# CONFIG_IIO_INTERRUPT_TRIGGER is not set
CONFIG_IIO_SYSFS_TRIGGER=y

#
# Pressure sensors
#
# CONFIG_BMP280 is not set
CONFIG_MPL115=y
CONFIG_MPL3115=m
CONFIG_IIO_ST_PRESS=y
CONFIG_IIO_ST_PRESS_I2C=y
CONFIG_IIO_ST_PRESS_SPI=y
CONFIG_T5403=m

#
# Lightning sensors
#
CONFIG_AS3935=y

#
# Proximity sensors
#
# CONFIG_SX9500 is not set

#
# Temperature sensors
#
# CONFIG_MLX90614 is not set
# CONFIG_TMP006 is not set
CONFIG_NTB=m
CONFIG_VME_BUS=y

#
# VME Bridge Drivers
#
CONFIG_VME_CA91CX42=m
CONFIG_VME_TSI148=y

#
# VME Board Drivers
#
# CONFIG_VMIVME_7805 is not set

#
# VME Device Drivers
#
CONFIG_VME_USER=m
CONFIG_VME_PIO2=m
CONFIG_PWM=y
CONFIG_PWM_SYSFS=y
CONFIG_PWM_LP3943=m
# CONFIG_PWM_LPSS is not set
# CONFIG_PWM_TWL is not set
# CONFIG_PWM_TWL_LED is not set
CONFIG_IPACK_BUS=y
CONFIG_BOARD_TPCI200=y
CONFIG_SERIAL_IPOCTAL=y
CONFIG_RESET_CONTROLLER=y
CONFIG_FMC=m
CONFIG_FMC_FAKEDEV=m
CONFIG_FMC_TRIVIAL=m
CONFIG_FMC_WRITE_EEPROM=m
CONFIG_FMC_CHARDEV=m

#
# PHY Subsystem
#
CONFIG_GENERIC_PHY=y
CONFIG_BCM_KONA_USB2_PHY=y
# CONFIG_PHY_SAMSUNG_USB2 is not set
# CONFIG_POWERCAP is not set
# CONFIG_MCB is not set
# CONFIG_THUNDERBOLT is not set

#
# Android
#
# CONFIG_ANDROID is not set

#
# Firmware Drivers
#
# CONFIG_EDD is not set
CONFIG_FIRMWARE_MEMMAP=y
# CONFIG_DELL_RBU is not set
# CONFIG_DCDBAS is not set
# CONFIG_DMIID is not set
# CONFIG_DMI_SYSFS is not set
CONFIG_DMI_SCAN_MACHINE_NON_EFI_FALLBACK=y
# CONFIG_ISCSI_IBFT_FIND is not set
# CONFIG_GOOGLE_FIRMWARE is not set

#
# File systems
#
CONFIG_DCACHE_WORD_ACCESS=y
CONFIG_EXT2_FS=m
CONFIG_EXT2_FS_XATTR=y
# CONFIG_EXT2_FS_POSIX_ACL is not set
# CONFIG_EXT2_FS_SECURITY is not set
CONFIG_EXT3_FS=y
CONFIG_EXT3_DEFAULTS_TO_ORDERED=y
# CONFIG_EXT3_FS_XATTR is not set
# CONFIG_EXT4_FS is not set
CONFIG_JBD=y
CONFIG_JBD_DEBUG=y
CONFIG_FS_MBCACHE=m
CONFIG_REISERFS_FS=m
CONFIG_REISERFS_CHECK=y
# CONFIG_REISERFS_PROC_INFO is not set
CONFIG_REISERFS_FS_XATTR=y
CONFIG_REISERFS_FS_POSIX_ACL=y
CONFIG_REISERFS_FS_SECURITY=y
CONFIG_JFS_FS=y
# CONFIG_JFS_POSIX_ACL is not set
# CONFIG_JFS_SECURITY is not set
CONFIG_JFS_DEBUG=y
CONFIG_JFS_STATISTICS=y
CONFIG_XFS_FS=y
# CONFIG_XFS_QUOTA is not set
# CONFIG_XFS_POSIX_ACL is not set
# CONFIG_XFS_RT is not set
CONFIG_XFS_DEBUG=y
CONFIG_GFS2_FS=y
# CONFIG_OCFS2_FS is not set
CONFIG_BTRFS_FS=y
CONFIG_BTRFS_FS_POSIX_ACL=y
CONFIG_BTRFS_FS_CHECK_INTEGRITY=y
# CONFIG_BTRFS_FS_RUN_SANITY_TESTS is not set
# CONFIG_BTRFS_DEBUG is not set
# CONFIG_BTRFS_ASSERT is not set
CONFIG_NILFS2_FS=y
CONFIG_FS_DAX=y
CONFIG_FS_POSIX_ACL=y
CONFIG_EXPORTFS=y
CONFIG_FILE_LOCKING=y
CONFIG_FSNOTIFY=y
CONFIG_DNOTIFY=y
CONFIG_INOTIFY_USER=y
CONFIG_FANOTIFY=y
# CONFIG_FANOTIFY_ACCESS_PERMISSIONS is not set
CONFIG_QUOTA=y
# CONFIG_QUOTA_NETLINK_INTERFACE is not set
# CONFIG_PRINT_QUOTA_WARNING is not set
CONFIG_QUOTA_DEBUG=y
CONFIG_QUOTA_TREE=y
CONFIG_QFMT_V1=m
CONFIG_QFMT_V2=y
CONFIG_QUOTACTL=y
CONFIG_QUOTACTL_COMPAT=y
# CONFIG_AUTOFS4_FS is not set
CONFIG_FUSE_FS=y
CONFIG_CUSE=y
# CONFIG_OVERLAY_FS is not set

#
# Caches
#
CONFIG_FSCACHE=m
CONFIG_FSCACHE_STATS=y
CONFIG_FSCACHE_HISTOGRAM=y
# CONFIG_FSCACHE_DEBUG is not set
# CONFIG_FSCACHE_OBJECT_LIST is not set
CONFIG_CACHEFILES=m
CONFIG_CACHEFILES_DEBUG=y
CONFIG_CACHEFILES_HISTOGRAM=y

#
# CD-ROM/DVD Filesystems
#
CONFIG_ISO9660_FS=y
# CONFIG_JOLIET is not set
# CONFIG_ZISOFS is not set
# CONFIG_UDF_FS is not set

#
# DOS/FAT/NT Filesystems
#
CONFIG_FAT_FS=y
# CONFIG_MSDOS_FS is not set
CONFIG_VFAT_FS=y
CONFIG_FAT_DEFAULT_CODEPAGE=437
CONFIG_FAT_DEFAULT_IOCHARSET="iso8859-1"
# CONFIG_NTFS_FS is not set

#
# Pseudo filesystems
#
CONFIG_PROC_FS=y
CONFIG_PROC_KCORE=y
CONFIG_PROC_SYSCTL=y
CONFIG_PROC_PAGE_MONITOR=y
CONFIG_KERNFS=y
CONFIG_SYSFS=y
CONFIG_TMPFS=y
CONFIG_TMPFS_POSIX_ACL=y
CONFIG_TMPFS_XATTR=y
# CONFIG_HUGETLBFS is not set
# CONFIG_HUGETLB_PAGE is not set
CONFIG_CONFIGFS_FS=y
# CONFIG_MISC_FILESYSTEMS is not set
CONFIG_NETWORK_FILESYSTEMS=y
CONFIG_NLS=y
CONFIG_NLS_DEFAULT="iso8859-1"
# CONFIG_NLS_CODEPAGE_437 is not set
# CONFIG_NLS_CODEPAGE_737 is not set
# CONFIG_NLS_CODEPAGE_775 is not set
# CONFIG_NLS_CODEPAGE_850 is not set
# CONFIG_NLS_CODEPAGE_852 is not set
# CONFIG_NLS_CODEPAGE_855 is not set
CONFIG_NLS_CODEPAGE_857=m
# CONFIG_NLS_CODEPAGE_860 is not set
CONFIG_NLS_CODEPAGE_861=y
CONFIG_NLS_CODEPAGE_862=m
CONFIG_NLS_CODEPAGE_863=y
CONFIG_NLS_CODEPAGE_864=y
CONFIG_NLS_CODEPAGE_865=y
CONFIG_NLS_CODEPAGE_866=y
# CONFIG_NLS_CODEPAGE_869 is not set
# CONFIG_NLS_CODEPAGE_936 is not set
CONFIG_NLS_CODEPAGE_950=m
CONFIG_NLS_CODEPAGE_932=m
CONFIG_NLS_CODEPAGE_949=y
# CONFIG_NLS_CODEPAGE_874 is not set
CONFIG_NLS_ISO8859_8=y
CONFIG_NLS_CODEPAGE_1250=y
CONFIG_NLS_CODEPAGE_1251=m
CONFIG_NLS_ASCII=m
# CONFIG_NLS_ISO8859_1 is not set
CONFIG_NLS_ISO8859_2=y
CONFIG_NLS_ISO8859_3=m
CONFIG_NLS_ISO8859_4=y
CONFIG_NLS_ISO8859_5=y
# CONFIG_NLS_ISO8859_6 is not set
# CONFIG_NLS_ISO8859_7 is not set
# CONFIG_NLS_ISO8859_9 is not set
CONFIG_NLS_ISO8859_13=y
# CONFIG_NLS_ISO8859_14 is not set
# CONFIG_NLS_ISO8859_15 is not set
CONFIG_NLS_KOI8_R=m
CONFIG_NLS_KOI8_U=y
CONFIG_NLS_MAC_ROMAN=y
# CONFIG_NLS_MAC_CELTIC is not set
# CONFIG_NLS_MAC_CENTEURO is not set
CONFIG_NLS_MAC_CROATIAN=m
CONFIG_NLS_MAC_CYRILLIC=m
# CONFIG_NLS_MAC_GAELIC is not set
CONFIG_NLS_MAC_GREEK=m
CONFIG_NLS_MAC_ICELAND=m
# CONFIG_NLS_MAC_INUIT is not set
# CONFIG_NLS_MAC_ROMANIAN is not set
# CONFIG_NLS_MAC_TURKISH is not set
CONFIG_NLS_UTF8=m

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
# CONFIG_ENABLE_WARN_DEPRECATED is not set
# CONFIG_ENABLE_MUST_CHECK is not set
CONFIG_FRAME_WARN=2048
# CONFIG_STRIP_ASM_SYMS is not set
# CONFIG_READABLE_ASM is not set
# CONFIG_UNUSED_SYMBOLS is not set
# CONFIG_PAGE_OWNER is not set
CONFIG_DEBUG_FS=y
CONFIG_HEADERS_CHECK=y
# CONFIG_DEBUG_SECTION_MISMATCH is not set
CONFIG_ARCH_WANT_FRAME_POINTERS=y
CONFIG_FRAME_POINTER=y
# CONFIG_DEBUG_FORCE_WEAK_PER_CPU is not set
CONFIG_MAGIC_SYSRQ=y
CONFIG_MAGIC_SYSRQ_DEFAULT_ENABLE=0x1
CONFIG_DEBUG_KERNEL=y

#
# Memory Debugging
#
CONFIG_PAGE_EXTENSION=y
# CONFIG_DEBUG_PAGEALLOC is not set
CONFIG_DEBUG_OBJECTS=y
CONFIG_DEBUG_OBJECTS_SELFTEST=y
# CONFIG_DEBUG_OBJECTS_FREE is not set
# CONFIG_DEBUG_OBJECTS_TIMERS is not set
# CONFIG_DEBUG_OBJECTS_WORK is not set
CONFIG_DEBUG_OBJECTS_RCU_HEAD=y
# CONFIG_DEBUG_OBJECTS_PERCPU_COUNTER is not set
CONFIG_DEBUG_OBJECTS_ENABLE_DEFAULT=1
# CONFIG_DEBUG_SLAB is not set
CONFIG_HAVE_DEBUG_KMEMLEAK=y
# CONFIG_DEBUG_KMEMLEAK is not set
# CONFIG_DEBUG_STACK_USAGE is not set
# CONFIG_DEBUG_VM is not set
# CONFIG_DEBUG_VIRTUAL is not set
CONFIG_DEBUG_MEMORY_INIT=y
CONFIG_HAVE_DEBUG_STACKOVERFLOW=y
# CONFIG_DEBUG_STACKOVERFLOW is not set
CONFIG_HAVE_ARCH_KMEMCHECK=y
# CONFIG_KMEMCHECK is not set
CONFIG_HAVE_ARCH_KASAN=y
CONFIG_KASAN_SHADOW_OFFSET=0xdffffc0000000000
CONFIG_DEBUG_SHIRQ=y

#
# Debug Lockups and Hangs
#
# CONFIG_LOCKUP_DETECTOR is not set
# CONFIG_DETECT_HUNG_TASK is not set
# CONFIG_PANIC_ON_OOPS is not set
CONFIG_PANIC_ON_OOPS_VALUE=0
CONFIG_PANIC_TIMEOUT=0
# CONFIG_SCHED_DEBUG is not set
# CONFIG_SCHEDSTATS is not set
# CONFIG_SCHED_STACK_END_CHECK is not set
CONFIG_TIMER_STATS=y

#
# Lock Debugging (spinlocks, mutexes, etc...)
#
CONFIG_DEBUG_RT_MUTEXES=y
CONFIG_DEBUG_SPINLOCK=y
CONFIG_DEBUG_MUTEXES=y
# CONFIG_DEBUG_WW_MUTEX_SLOWPATH is not set
CONFIG_DEBUG_LOCK_ALLOC=y
CONFIG_PROVE_LOCKING=y
CONFIG_LOCKDEP=y
CONFIG_LOCK_STAT=y
# CONFIG_DEBUG_LOCKDEP is not set
CONFIG_DEBUG_ATOMIC_SLEEP=y
# CONFIG_DEBUG_LOCKING_API_SELFTESTS is not set
CONFIG_LOCK_TORTURE_TEST=y
CONFIG_TRACE_IRQFLAGS=y
CONFIG_STACKTRACE=y
# CONFIG_DEBUG_KOBJECT is not set
CONFIG_DEBUG_BUGVERBOSE=y
# CONFIG_DEBUG_LIST is not set
# CONFIG_DEBUG_PI_LIST is not set
# CONFIG_DEBUG_SG is not set
# CONFIG_DEBUG_NOTIFIERS is not set
CONFIG_DEBUG_CREDENTIALS=y

#
# RCU Debugging
#
# CONFIG_PROVE_RCU is not set
CONFIG_SPARSE_RCU_POINTER=y
CONFIG_TORTURE_TEST=y
# CONFIG_RCU_TORTURE_TEST is not set
CONFIG_RCU_CPU_STALL_TIMEOUT=21
CONFIG_RCU_TRACE=y
# CONFIG_DEBUG_BLOCK_EXT_DEVT is not set
# CONFIG_NOTIFIER_ERROR_INJECTION is not set
# CONFIG_FAULT_INJECTION is not set
# CONFIG_LATENCYTOP is not set
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
CONFIG_TRACE_CLOCK=y
CONFIG_TRACING_SUPPORT=y
# CONFIG_FTRACE is not set

#
# Runtime Testing
#
# CONFIG_LKDTM is not set
CONFIG_TEST_LIST_SORT=y
# CONFIG_KPROBES_SANITY_TEST is not set
# CONFIG_BACKTRACE_SELF_TEST is not set
# CONFIG_RBTREE_TEST is not set
CONFIG_INTERVAL_TREE_TEST=m
# CONFIG_PERCPU_TEST is not set
CONFIG_ATOMIC64_SELFTEST=y
CONFIG_TEST_HEXDUMP=y
# CONFIG_TEST_STRING_HELPERS is not set
# CONFIG_TEST_KSTRTOX is not set
CONFIG_TEST_RHASHTABLE=y
CONFIG_PROVIDE_OHCI1394_DMA_INIT=y
CONFIG_BUILD_DOCSRC=y
# CONFIG_DMA_API_DEBUG is not set
CONFIG_TEST_LKM=m
# CONFIG_TEST_USER_COPY is not set
# CONFIG_TEST_BPF is not set
CONFIG_TEST_FIRMWARE=y
CONFIG_TEST_UDELAY=y
# CONFIG_SAMPLES is not set
CONFIG_HAVE_ARCH_KGDB=y
# CONFIG_KGDB is not set
# CONFIG_STRICT_DEVMEM is not set
CONFIG_X86_VERBOSE_BOOTUP=y
CONFIG_EARLY_PRINTK=y
CONFIG_EARLY_PRINTK_DBGP=y
CONFIG_X86_PTDUMP=y
CONFIG_DEBUG_RODATA=y
CONFIG_DEBUG_RODATA_TEST=y
CONFIG_DEBUG_SET_MODULE_RONX=y
CONFIG_DEBUG_NX_TEST=m
# CONFIG_DOUBLEFAULT is not set
# CONFIG_DEBUG_TLBFLUSH is not set
CONFIG_IOMMU_STRESS=y
CONFIG_HAVE_MMIOTRACE_SUPPORT=y
# CONFIG_X86_DECODER_SELFTEST is not set
CONFIG_IO_DELAY_TYPE_0X80=0
CONFIG_IO_DELAY_TYPE_0XED=1
CONFIG_IO_DELAY_TYPE_UDELAY=2
CONFIG_IO_DELAY_TYPE_NONE=3
# CONFIG_IO_DELAY_0X80 is not set
# CONFIG_IO_DELAY_0XED is not set
# CONFIG_IO_DELAY_UDELAY is not set
CONFIG_IO_DELAY_NONE=y
CONFIG_DEFAULT_IO_DELAY_TYPE=3
# CONFIG_DEBUG_BOOT_PARAMS is not set
# CONFIG_CPA_DEBUG is not set
# CONFIG_OPTIMIZE_INLINING is not set
CONFIG_DEBUG_NMI_SELFTEST=y
# CONFIG_X86_DEBUG_STATIC_CPU_HAS is not set

#
# Security options
#
CONFIG_KEYS=y
# CONFIG_PERSISTENT_KEYRINGS is not set
CONFIG_BIG_KEYS=y
# CONFIG_TRUSTED_KEYS is not set
CONFIG_ENCRYPTED_KEYS=m
# CONFIG_SECURITY_DMESG_RESTRICT is not set
CONFIG_SECURITY=y
CONFIG_SECURITYFS=y
CONFIG_SECURITY_NETWORK=y
# CONFIG_SECURITY_PATH is not set
# CONFIG_SECURITY_TOMOYO is not set
# CONFIG_SECURITY_APPARMOR is not set
# CONFIG_SECURITY_YAMA is not set
# CONFIG_INTEGRITY is not set
CONFIG_DEFAULT_SECURITY_DAC=y
CONFIG_DEFAULT_SECURITY=""
CONFIG_XOR_BLOCKS=y
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
CONFIG_CRYPTO_NULL=m
CONFIG_CRYPTO_WORKQUEUE=y
CONFIG_CRYPTO_CRYPTD=y
CONFIG_CRYPTO_MCRYPTD=m
CONFIG_CRYPTO_AUTHENC=y
CONFIG_CRYPTO_TEST=m
CONFIG_CRYPTO_ABLK_HELPER=y
CONFIG_CRYPTO_GLUE_HELPER_X86=y

#
# Authenticated Encryption with Associated Data
#
# CONFIG_CRYPTO_CCM is not set
# CONFIG_CRYPTO_GCM is not set
CONFIG_CRYPTO_SEQIV=m

#
# Block modes
#
CONFIG_CRYPTO_CBC=y
CONFIG_CRYPTO_CTR=m
CONFIG_CRYPTO_CTS=y
# CONFIG_CRYPTO_ECB is not set
CONFIG_CRYPTO_LRW=y
CONFIG_CRYPTO_PCBC=m
CONFIG_CRYPTO_XTS=y

#
# Hash modes
#
CONFIG_CRYPTO_CMAC=y
CONFIG_CRYPTO_HMAC=m
CONFIG_CRYPTO_XCBC=m
CONFIG_CRYPTO_VMAC=y

#
# Digest
#
CONFIG_CRYPTO_CRC32C=y
CONFIG_CRYPTO_CRC32C_INTEL=m
CONFIG_CRYPTO_CRC32=m
CONFIG_CRYPTO_CRC32_PCLMUL=y
CONFIG_CRYPTO_CRCT10DIF=y
CONFIG_CRYPTO_CRCT10DIF_PCLMUL=m
CONFIG_CRYPTO_GHASH=y
CONFIG_CRYPTO_MD4=y
# CONFIG_CRYPTO_MD5 is not set
# CONFIG_CRYPTO_MICHAEL_MIC is not set
# CONFIG_CRYPTO_RMD128 is not set
CONFIG_CRYPTO_RMD160=y
CONFIG_CRYPTO_RMD256=m
CONFIG_CRYPTO_RMD320=y
CONFIG_CRYPTO_SHA1=y
# CONFIG_CRYPTO_SHA1_SSSE3 is not set
# CONFIG_CRYPTO_SHA256_SSSE3 is not set
# CONFIG_CRYPTO_SHA512_SSSE3 is not set
CONFIG_CRYPTO_SHA1_MB=m
CONFIG_CRYPTO_SHA256=y
CONFIG_CRYPTO_SHA512=y
# CONFIG_CRYPTO_TGR192 is not set
CONFIG_CRYPTO_WP512=m
CONFIG_CRYPTO_GHASH_CLMUL_NI_INTEL=y

#
# Ciphers
#
CONFIG_CRYPTO_AES=y
CONFIG_CRYPTO_AES_X86_64=y
CONFIG_CRYPTO_AES_NI_INTEL=y
CONFIG_CRYPTO_ANUBIS=m
# CONFIG_CRYPTO_ARC4 is not set
CONFIG_CRYPTO_BLOWFISH=m
CONFIG_CRYPTO_BLOWFISH_COMMON=m
# CONFIG_CRYPTO_BLOWFISH_X86_64 is not set
CONFIG_CRYPTO_CAMELLIA=y
CONFIG_CRYPTO_CAMELLIA_X86_64=y
CONFIG_CRYPTO_CAMELLIA_AESNI_AVX_X86_64=y
# CONFIG_CRYPTO_CAMELLIA_AESNI_AVX2_X86_64 is not set
CONFIG_CRYPTO_CAST_COMMON=y
CONFIG_CRYPTO_CAST5=y
CONFIG_CRYPTO_CAST5_AVX_X86_64=m
CONFIG_CRYPTO_CAST6=m
CONFIG_CRYPTO_CAST6_AVX_X86_64=m
CONFIG_CRYPTO_DES=y
# CONFIG_CRYPTO_DES3_EDE_X86_64 is not set
# CONFIG_CRYPTO_FCRYPT is not set
# CONFIG_CRYPTO_KHAZAD is not set
CONFIG_CRYPTO_SALSA20=y
CONFIG_CRYPTO_SALSA20_X86_64=y
# CONFIG_CRYPTO_SEED is not set
CONFIG_CRYPTO_SERPENT=y
CONFIG_CRYPTO_SERPENT_SSE2_X86_64=m
CONFIG_CRYPTO_SERPENT_AVX_X86_64=y
CONFIG_CRYPTO_SERPENT_AVX2_X86_64=m
# CONFIG_CRYPTO_TEA is not set
CONFIG_CRYPTO_TWOFISH=y
CONFIG_CRYPTO_TWOFISH_COMMON=y
CONFIG_CRYPTO_TWOFISH_X86_64=y
CONFIG_CRYPTO_TWOFISH_X86_64_3WAY=m
CONFIG_CRYPTO_TWOFISH_AVX_X86_64=m

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
CONFIG_CRYPTO_DRBG_MENU=m
# CONFIG_CRYPTO_DRBG_HMAC is not set
# CONFIG_CRYPTO_DRBG_HASH is not set
CONFIG_CRYPTO_DRBG_CTR=y
CONFIG_CRYPTO_DRBG=m
# CONFIG_CRYPTO_USER_API_HASH is not set
# CONFIG_CRYPTO_USER_API_SKCIPHER is not set
# CONFIG_CRYPTO_USER_API_RNG is not set
CONFIG_CRYPTO_HASH_INFO=y
CONFIG_CRYPTO_HW=y
CONFIG_CRYPTO_DEV_PADLOCK=m
# CONFIG_CRYPTO_DEV_PADLOCK_AES is not set
CONFIG_CRYPTO_DEV_PADLOCK_SHA=m
CONFIG_CRYPTO_DEV_CCP=y
CONFIG_CRYPTO_DEV_CCP_DD=m
CONFIG_CRYPTO_DEV_CCP_CRYPTO=m
CONFIG_CRYPTO_DEV_QAT=m
CONFIG_CRYPTO_DEV_QAT_DH895xCC=m
CONFIG_ASYMMETRIC_KEY_TYPE=y
CONFIG_ASYMMETRIC_PUBLIC_KEY_SUBTYPE=y
CONFIG_PUBLIC_KEY_ALGO_RSA=y
CONFIG_X509_CERTIFICATE_PARSER=y
CONFIG_PKCS7_MESSAGE_PARSER=y
CONFIG_PKCS7_TEST_KEY=y
# CONFIG_SIGNED_PE_FILE_VERIFICATION is not set
CONFIG_HAVE_KVM=y
CONFIG_KVM_COMPAT=y
CONFIG_VIRTUALIZATION=y
# CONFIG_BINARY_PRINTF is not set

#
# Library routines
#
CONFIG_RAID6_PQ=y
CONFIG_BITREVERSE=y
# CONFIG_HAVE_ARCH_BITREVERSE is not set
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
CONFIG_CRC16=m
CONFIG_CRC_T10DIF=y
CONFIG_CRC_ITU_T=y
CONFIG_CRC32=y
# CONFIG_CRC32_SELFTEST is not set
# CONFIG_CRC32_SLICEBY8 is not set
CONFIG_CRC32_SLICEBY4=y
# CONFIG_CRC32_SARWATE is not set
# CONFIG_CRC32_BIT is not set
CONFIG_CRC7=y
CONFIG_LIBCRC32C=y
CONFIG_CRC8=m
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
CONFIG_DECOMPRESS_BZIP2=y
CONFIG_DECOMPRESS_LZMA=y
CONFIG_REED_SOLOMON=m
CONFIG_REED_SOLOMON_DEC16=y
CONFIG_BCH=m
CONFIG_BCH_CONST_PARAMS=y
CONFIG_INTERVAL_TREE=y
CONFIG_ASSOCIATIVE_ARRAY=y
CONFIG_HAS_IOMEM=y
CONFIG_HAS_IOPORT_MAP=y
CONFIG_HAS_DMA=y
CONFIG_CHECK_SIGNATURE=y
CONFIG_DQL=y
CONFIG_GLOB=y
# CONFIG_GLOB_SELFTEST is not set
CONFIG_NLATTR=y
CONFIG_ARCH_HAS_ATOMIC64_DEC_IF_POSITIVE=y
# CONFIG_AVERAGE is not set
CONFIG_CLZ_TAB=y
CONFIG_CORDIC=y
CONFIG_DDR=y
CONFIG_MPILIB=y
CONFIG_OID_REGISTRY=y
CONFIG_ARCH_HAS_SG_CHAIN=y

--YiEDa0DAkWCtVeE4--
