From: Fengguang Wu <fengguang.wu@intel.com>
Subject: [netfilter] INFO: task kworker/u2:0:6 blocked for more than 120
 seconds.
Date: Mon, 20 Jul 2015 10:14:02 +0800
Message-ID: <20150720021402.GA13183@wfg-t540p.sh.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: fengguang.wu@intel.com, Pablo Neira Ayuso <pablo@netfilter.org>,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	LKP <lkp@01.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Greetings,

0day kernel testing robot got the below dmesg and the first bad commit is

git://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs-next.git master

commit 085db2c04557d31db61541f361bd8b4de92c9939
Author:     Eric W. Biederman <ebiederm@xmission.com>
AuthorDate: Fri Jul 10 18:15:06 2015 -0500
Commit:     Pablo Neira Ayuso <pablo@netfilter.org>
CommitDate: Wed Jul 15 18:17:26 2015 +0200

    netfilter: Per network namespace netfilter hooks.
    
    - Add a new set of functions for registering and unregistering per
      network namespace hooks.
    
    - Modify the old global namespace hook functions to use the per
      network namespace hooks in their implementation, so their remains a
      single list that needs to be walked for any hook (this is important
      for keeping the hook priority working and for keeping the code
      walking the hooks simple).
    
    - Only allow registering the per netdevice hooks in the network
      namespace where the network device lives.
    
    - Dynamically allocate the structures in the per network namespace
      hook list in nf_register_net_hook, and unregister them in
      nf_unregister_net_hook.
    
      Dynamic allocate is required somewhere as the number of network
      namespaces are not fixed so we might as well allocate them in the
      registration function.
    
      The chain of registered hooks on any list is expected to be small so
      the cost of walking that list to find the entry we are unregistering
      should also be small.
    
      Performing the management of the dynamically allocated list entries
      in the registration and unregistration functions keeps the complexity
      from spreading.
    
    Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>

+--------------------------------------------------+------------+------------+------------+
|                                                  | 0edcf282b0 | 085db2c045 | 91bd7e9bd9 |
+--------------------------------------------------+------------+------------+------------+
| boot_successes                                   | 909        | 215        | 30         |
| boot_failures                                    | 1          | 15         | 4          |
| BUG:kernel_test_hang                             | 1          | 0          | 1          |
| INFO:task_blocked_for_more_than#seconds          | 0          | 15         | 4          |
| EIP_is_at_default_send_IPI_mask_logical          | 0          | 15         | 3          |
| Kernel_panic-not_syncing:hung_task:blocked_tasks | 0          | 15         | 3          |
| backtrace:reg_timeout_work                       | 0          | 11         | 2          |
| backtrace:watchdog                               | 0          | 15         | 3          |
| backtrace:cleanup_net                            | 0          | 4          | 2          |
| backtrace:reg_check_chans_work                   | 0          | 0          | 1          |
| backtrace:do_group_exit                          | 0          | 0          | 1          |
| backtrace:SyS_exit_group                         | 0          | 0          | 1          |
| backtrace:do_vfs_ioctl                           | 0          | 0          | 1          |
| backtrace:SyS_ioctl                              | 0          | 0          | 1          |
| backtrace:addrconf_verify_work                   | 0          | 0          | 1          |
+--------------------------------------------------+------------+------------+------------+

[   24.456849] cfg80211: Timeout while waiting for CRDA to reply, restoring regulatory settings
Deconfiguring network interfaces... 
[   81.336920] cfg80211: Verifying active interfaces after reg change
[  241.816853] INFO: task kworker/u2:0:6 blocked for more than 120 seconds.
[  241.818319]       Not tainted 4.2.0-rc2-00147-g085db2c #3
[  241.819076] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[  241.820103] kworker/u2:0    D be827000  7124     6      2 0x00000000
[  241.821015] Workqueue: events_power_efficient reg_timeout_work
[  241.821829]  b02a5e5c 00000096 bdf5d300 be827000 b0298000 00000000 b02a6000 b0298000
[  241.823067]  b02a5e6c b1718a1c 00000000 b1b72080 b02a5e74 b1718ce0 b02a5ea0 b171ad73
[  241.824353]  b1b720a4 00000246 bd82de64 bdcede98 b0298000 b02a5e84 b1b7f800 b02535c0
[  241.825525] Call Trace:
[  241.825866]  [<b1718a1c>] schedule+0x53/0x7b
[  241.826489]  [<b1718ce0>] schedule_preempt_disabled+0x13/0x1b
[  241.827267]  [<b171ad73>] mutex_lock_nested+0x22b/0x3dd
[  241.827978]  [<b147d2da>] rtnl_lock+0x14/0x16
[  241.828571]  [<b1679607>] reg_timeout_work+0x17/0x2f
[  241.829310]  [<b106eba6>] process_one_work+0x3fc/0x730
[  241.830058]  [<b106f51d>] ? worker_thread+0x35/0x77d
[  241.830791]  [<b106fa99>] worker_thread+0x5b1/0x77d
[  241.831452]  [<b106f4e8>] ? max_active_store+0x5a/0x5a
[  241.832156]  [<b1074c11>] kthread+0xe3/0xe8
[  241.832706]  [<b171e460>] ret_from_kernel_thread+0x20/0x30
[  241.833461]  [<b1074b2e>] ? kthread_create_on_node+0x1b6/0x1b6
[  241.834251] 3 locks held by kworker/u2:0/6:
[  241.834819]  #0:  ("events_power_efficient"){......}, at: [<b106eabb>] process_one_work+0x311/0x730
[  241.836161]  #1:  ((reg_timeout).work){......}, at: [<b106eabb>] process_one_work+0x311/0x730
[  241.837424]  #2:  (rtnl_mutex){......}, at: [<b147d2da>] rtnl_lock+0x14/0x16
[  241.838507] sending NMI to all CPUs:
[  241.839070] NMI backtrace for cpu 0
[  241.839520] CPU: 0 PID: 11 Comm: khungtaskd Not tainted 4.2.0-rc2-00147-g085db2c #3
[  241.840544] task: b02da000 ti: b02de000 task.ti: b02de000
[  241.841292] EIP: 0060:[<b1032a76>] EFLAGS: 00000046 CPU: 0
[  241.842029] EIP is at default_send_IPI_mask_logical+0x114/0x125
[  241.842816] EAX: 00000c00 EBX: 00000001 ECX: 00000001 EDX: fffff000
[  241.843628] ESI: 01000000 EDI: 00000001 EBP: b02dfee4 ESP: b02dfecc
[  241.844538]  DS: 007b ES: 007b FS: 0000 GS: 0000 SS: 0068
[  241.845246] CR0: 80050033 CR2: 08050090 CR3: 0dfb2000 CR4: 00140690
[  241.846065] DR0: 080d6000 DR1: 00000000 DR2: 00000000 DR3: 00000000
[  241.846951] DR6: ffff0ff0 DR7: 00000600
[  241.847462] Stack:
[  241.847752]  00000246 00000800 00000002 00000002 00000000 00000000 b02dff00 b1033631
[  241.848795]  b1a66513 b1a88abb 00000002 00000000 b0298000 b02dff34 b10d598c 00000000
[  241.849898]  00000000 000003fa 00007ffb b0298000 00000078 b0298124 b02981e8 b02d9bf0
[  241.850909] Call Trace:
[  241.851235]  [<b1033631>] arch_trigger_all_cpu_backtrace+0xe8/0x1ee
[  241.852110]  [<b10d598c>] watchdog+0x4bf/0x4c9
[  241.852723]  [<b10d54cd>] ? reset_hung_task_detector+0x14/0x14
[  241.853514]  [<b1074c11>] kthread+0xe3/0xe8
[  241.854055]  [<b171e460>] ret_from_kernel_thread+0x20/0x30
[  241.854793]  [<b1074b2e>] ? kthread_create_on_node+0x1b6/0x1b6
[  241.855580] Code: 18 a1 64 ee b2 b1 89 b0 10 d3 ff ff 8b 45 ec 8b 55 f0 0b 55 ec 80 cc 04 83 7d f0 02 0f 45 c2 8b 15 64 ee b2 b1 89 82 00 d3 ff ff <8b> 45 e8 50 9d 8d 74 26 00 83 c4 0c 5b 5e 5f 5d c3 55 89 e5 3e
[  241.858049] Kernel panic - not syncing: hung_task: blocked tasks
[  241.858922] CPU: 0 PID: 11 Comm: khungtaskd Not tainted 4.2.0-rc2-00147-g085db2c #3
[  241.859919]  00010401 00000002 00000000 b02dfee4 b1715680 b02dfefc b1713aee 00000000
[  241.861117]  00000002 00000000 b0298000 b02dff34 b10d5996 b1a744a0 00000000 00000000
[  241.862371]  000003fa 00007ffb b0298000 00000078 b0298124 b02981e8 b02d9bf0 00000000
[  241.863523] Call Trace:
[  241.863871]  [<b1715680>] dump_stack+0x16/0x18
[  241.864526]  [<b1713aee>] panic+0xcc/0x267
[  241.865065]  [<b10d5996>] watchdog+0x4c9/0x4c9
[  241.865669]  [<b10d54cd>] ? reset_hung_task_detector+0x14/0x14
[  241.866429]  [<b1074c11>] kthread+0xe3/0xe8
[  241.866985]  [<b171e460>] ret_from_kernel_thread+0x20/0x30
[  241.867721]  [<b1074b2e>] ? kthread_create_on_node+0x1b6/0x1b6
[  241.868511] Kernel Offset: disabled

Elapsed time: 250

git bisect start 91bd7e9bd95b52154b3b5c0e65097f12b6a3b3ee bc0195aad0daa2ad5b0d76cce22b167bc3435590 --
git bisect good 800805ef820e5b4386e23e3c9aa66c8f2a4ec041  # 00:09    130+      0  Merge 'tip/irq/c6x' into devel-spot-201507180507
git bisect good 0e22410e79442dab967a4e3cb24ff9009be0273f  # 00:31    130+      0  Merge 'arm-soc/lpc18xx/dt' into devel-spot-201507180507
git bisect good fa1e0ce59b220a0626def23982cc56fd0c0536ae  # 00:37    129+      0  Merge 'mac80211/master' into devel-spot-201507180507
git bisect good 6af8f85ca85616e2725ddc0103c419993c6fa633  # 00:45    130+      0  Merge 'arm-tegra/for-4.3/cleanup' into devel-spot-201507180507
git bisect good 38516ee0dc9c77fdc578209a6cc25c5b203e3300  # 00:56    130+      0  Merge 'arm-tegra/for-4.3/soc' into devel-spot-201507180507
git bisect good cc324162bdff1aab04c613db1fb9399bc4725c83  # 01:07    130+      0  Merge 'arm-tegra/for-4.3/clk' into devel-spot-201507180507
git bisect good e4677276c51bdd3a701566dadbbb633fad5310dd  # 01:10    127+      0  Merge 'tegra/for-next' into devel-spot-201507180507
git bisect  bad fd2ecda0341960d0ce361d648cf4dd98187afb06  # 01:21    118-      6  netfilter: nftables: Only run the nftables chains in the proper netns
git bisect good 4c0911566dec7755d15cb89239fb2db4447f7a62  # 01:31    228+      0  netfilter: Simply the tests for enabling and disabling the ingress queue hook
git bisect  bad 085db2c04557d31db61541f361bd8b4de92c9939  # 01:45    213-      4  netfilter: Per network namespace netfilter hooks.
git bisect good 0edcf282b0a6f38168294264837cf7d52a2f5255  # 01:57    310+      0  netfilter: Factor out the hook list selection from nf_register_hook
# first bad commit: [085db2c04557d31db61541f361bd8b4de92c9939] netfilter: Per network namespace netfilter hooks.
git bisect good 0edcf282b0a6f38168294264837cf7d52a2f5255  # 02:06    902+      0  netfilter: Factor out the hook list selection from nf_register_hook
# extra tests with DEBUG_INFO
git bisect  bad 085db2c04557d31db61541f361bd8b4de92c9939  # 02:18    263-      9  netfilter: Per network namespace netfilter hooks.
# extra tests on HEAD of linux-devel/devel-spot-201507180507
git bisect  bad b0e9316bc3b23de18a2a3f9a9cddd52a04965013  # 02:18      0-      5  0day head guard for 'devel-spot-201507180507'
# extra tests on tree/branch ipvs-next/master
git bisect  bad 7ef19cacacdc52e295245292d6aedcb15fc3863b  # 02:41    251-      6  ipvs: Add ovf scheduler
# extra tests with first bad commit reverted
git bisect good a138ed04d17096705e4a2df6b98542ea47ca89df  # 02:58    910+      0  Revert "netfilter: Per network namespace netfilter hooks."
# extra tests on tree/branch linus/master
git bisect good 9d37e6679dfddbb5fa605fb2d7ff448f7cd6d038  # 03:20    910+      0  Merge branch 'fixes' of git://ftp.arm.linux.org.uk/~rmk/linux-arm
# extra tests on tree/branch linux-next/master
git bisect good ee9a5e3e8ea94e1c56e4bb2373dd4431dd677389  # 03:41    903+      0  Add linux-next specific files for 20150717


This script may reproduce the error.

----------------------------------------------------------------------------
#!/bin/bash

kernel=$1
initrd=yocto-minimal-i386.cgz

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
	systemd.log_level=err
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

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/lkp                          Intel Corporation
