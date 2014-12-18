From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [iwlwifi] BUG: unable to handle kernel
Date: Thu, 18 Dec 2014 13:07:05 -0800
Message-ID: <20141218210705.GA26694@wfg-t540p.sh.intel.com>
References: <20141218171309.GD9298@wfg-t540p.sh.intel.com>
 <1418931737.4679.1.camel@egrumbacBox>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"lkp@01.org" <lkp@01.org>,
	"linux-leds@vger.kernel.org" <linux-leds@vger.kernel.org>
To: "Grumbach, Emmanuel" <emmanuel.grumbach@intel.com>
Return-path: <linux-leds-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1418931737.4679.1.camel@egrumbacBox>
Sender: linux-leds-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Dec 19, 2014 at 03:42:17AM +0800, Grumbach, Emmanuel wrote:
> On Thu, 2014-12-18 at 09:13 -0800, Fengguang Wu wrote:
> > Hi All,
> > 
> > I don't see any relationship between the BUG and this bisected commit.
> > Anyway, it's better to report it to the lists than to ignore.
> 
> Right - but I have to say that I have no clue how this comment can cause
> the bug you are seeing...

s?comment?commit?

> Do you even have an Intel Wireless device the VM could access?

Nope. It's simple QEMU virtual machine boot test.

Thanks,
Fengguang

> > 
> > git://git.kernel.org/pub/scm/linux/kernel/git/iwlwifi/iwlwifi-fixes.git master
> > 
> > commit 03d6c3b0fa4f5f0379cede079ec828a6c999fe43
> > Author:     Emmanuel Grumbach <emmanuel.grumbach@intel.com>
> > AuthorDate: Wed Dec 3 10:39:07 2014 +0200
> > Commit:     Emmanuel Grumbach <emmanuel.grumbach@intel.com>
> > CommitDate: Sun Dec 14 10:20:29 2014 +0200
> > 
> >     iwlwifi: pcie: re-ACK all interrupts after device reset
> >     
> >     When we reset the device, the CSR_INT gets cleared as well
> >     as CSR_INT_MASK. Meaning that we shouldn't get any interrupt
> >     but, due to a hardware bug, recent devices will keep sending
> >     interrupts. This leads to an interrupt storm while stopping
> >     the device.
> >     The way to fix this is to ACK all the interrupts after the
> >     device is reset so that the value of CSR_INT will stay
> >     0xffffffff.
> >     
> >     Fixes: 522713c81e4e ("iwlwifi: pcie: properly reset the device")
> >     Signed-off-by: Emmanuel Grumbach <emmanuel.grumbach@intel.com>
> > 
> > +------------------------------------------+------------+------------+------------+
> > |                                          | 0a79a0c011 | 03d6c3b0fa | iwlwifi-fi |
> > +------------------------------------------+------------+------------+------------+
> > | boot_successes                           | 60         | 19         | 3          |
> > | boot_failures                            | 0          | 1          | 9          |
> > | BUG:unable_to_handle_kernel              | 0          | 1          | 9          |
> > | Oops                                     | 0          | 1          | 9          |
> > | RIP:strcmp                               | 0          | 1          | 9          |
> > | Kernel_panic-not_syncing:Fatal_exception | 0          | 1          | 9          |
> > | backtrace:led_trigger_register_simple    | 0          | 1          | 9          |
> > | backtrace:ledtrig_usb_init               | 0          | 1          | 9          |
> > | backtrace:kernel_init_freeable           | 0          | 1          | 9          |
> > +------------------------------------------+------------+------------+------------+
> > 
> > [    5.345018] g_serial gadget: Gadget Serial v2.4
> > [    5.345927] g_serial gadget: g_serial ready
> > [    5.345927] g_serial gadget: g_serial ready
> > [    5.346777] BUG: unable to handle kernel 
> > [    5.346777] BUG: unable to handle kernel paging requestpaging request at ffff88000004e5f0
> >  at ffff88000004e5f0
> > [    5.348183] IP:
> > [    5.348183] IP: [<ffffffff81446a68>] strcmp+0x6/0x20
> >  [<ffffffff81446a68>] strcmp+0x6/0x20
> > [    5.349183] PGD 37f1067 
> > [    5.349183] PGD 37f1067 PUD 37f2067 PUD 37f2067 PMD 37f3067 PMD 37f3067 PTE 800000000004e060PTE 800000000004e060
> > 
> > [    5.350498] Oops: 0000 [#1] 
> > [    5.350498] Oops: 0000 [#1] DEBUG_PAGEALLOCDEBUG_PAGEALLOC
> > 
> > [    5.351360] CPU: 0 PID: 1 Comm: swapper Not tainted 3.18.0-g03d6c3b #1
> > [    5.351360] CPU: 0 PID: 1 Comm: swapper Not tainted 3.18.0-g03d6c3b #1
> > [    5.352660] task: ffff880012060000 ti: ffff88001204c000 task.ti: ffff88001204c000
> > [    5.352660] task: ffff880012060000 ti: ffff88001204c000 task.ti: ffff88001204c000
> > [    5.354143] RIP: 0010:[<ffffffff81446a68>] 
> > [    5.354143] RIP: 0010:[<ffffffff81446a68>]  [<ffffffff81446a68>] strcmp+0x6/0x20
> >  [<ffffffff81446a68>] strcmp+0x6/0x20
> > [    5.354451] RSP: 0000:ffff88001204fe28  EFLAGS: 00010246
> > [    5.354451] RSP: 0000:ffff88001204fe28  EFLAGS: 00010246
> > [    5.354451] RAX: 0000000000000000 RBX: ffff88000c08fe00 RCX: ffffffff81d35310
> > [    5.354451] RAX: 0000000000000000 RBX: ffff88000c08fe00 RCX: ffffffff81d35310
> > [    5.354451] RDX: ffff88000c08fe68 RSI: ffffffff826d05be RDI: ffff88000004e5f0
> > [    5.354451] RDX: ffff88000c08fe68 RSI: ffffffff826d05be RDI: ffff88000004e5f0
> > [    5.354451] RBP: ffff88001204fe28 R08: 0000000000000001 R09: 000000000000033a
> > [    5.354451] RBP: ffff88001204fe28 R08: 0000000000000001 R09: 000000000000033a
> > [    5.354451] R10: 0000000000000000 R11: ffffffff82531cd1 R12: ffff88000c19fa00
> > [    5.354451] R10: 0000000000000000 R11: ffffffff82531cd1 R12: ffff88000c19fa00
> > [    5.354451] R13: 0000000000000000 R14: ffffffff837958b8 R15: 0000000000000000
> > [    5.354451] R13: 0000000000000000 R14: ffffffff837958b8 R15: 0000000000000000
> > [    5.354451] FS:  0000000000000000(0000) GS:ffffffff82789000(0000) knlGS:0000000000000000
> > [    5.354451] FS:  0000000000000000(0000) GS:ffffffff82789000(0000) knlGS:0000000000000000
> > [    5.354451] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> > [    5.354451] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> > [    5.354451] CR2: ffff88000004e5f0 CR3: 0000000002776000 CR4: 00000000000006b0
> > [    5.354451] CR2: ffff88000004e5f0 CR3: 0000000002776000 CR4: 00000000000006b0
> > [    5.354451] Stack:
> > [    5.354451] Stack:
> > [    5.354451]  ffff88001204fe58
> > [    5.354451]  ffff88001204fe58 ffffffff81d35334 ffffffff81d35334 0000000000000000 0000000000000000 ffff88000c19fa00 ffff88000c19fa00
> > 
> > [    5.354451]  ffffffff826d05be
> > [    5.354451]  ffffffff826d05be 0000000000000000 0000000000000000 ffff88001204fe88 ffff88001204fe88 ffffffff81d35648 ffffffff81d35648
> > 
> > [    5.354451]  ffff88000e3bbcc0
> > [    5.354451]  ffff88000e3bbcc0 ffffffff82b3fe61 ffffffff82b3fe61 0000000000000000 0000000000000000 ffffffff82b98910 ffffffff82b98910
> > 
> > [    5.354451] Call Trace:
> > [    5.354451] Call Trace:
> > [    5.354451]  [<ffffffff81d35334>] led_trigger_register+0x63/0x129
> > [    5.354451]  [<ffffffff81d35334>] led_trigger_register+0x63/0x129
> > [    5.354451]  [<ffffffff81d35648>] led_trigger_register_simple+0x35/0x79
> > [    5.354451]  [<ffffffff81d35648>] led_trigger_register_simple+0x35/0x79
> > [    5.354451]  [<ffffffff82b3fe61>] ? gs_bind+0xea/0xea
> > [    5.354451]  [<ffffffff82b3fe61>] ? gs_bind+0xea/0xea
> > [    5.354451]  [<ffffffff82b3fe78>] ledtrig_usb_init+0x17/0x2e
> > [    5.354451]  [<ffffffff82b3fe78>] ledtrig_usb_init+0x17/0x2e
> > [    5.354451]  [<ffffffff82b00044>] do_one_initcall+0xe6/0x171
> > [    5.354451]  [<ffffffff82b00044>] do_one_initcall+0xe6/0x171
> > [    5.354451]  [<ffffffff82b001c7>] kernel_init_freeable+0xf8/0x180
> > [    5.354451]  [<ffffffff82b001c7>] kernel_init_freeable+0xf8/0x180
> > [    5.354451]  [<ffffffff82060791>] ? rest_init+0xbd/0xbd
> > [    5.354451]  [<ffffffff82060791>] ? rest_init+0xbd/0xbd
> > [    5.354451]  [<ffffffff8206079a>] kernel_init+0x9/0xd0
> > [    5.354451]  [<ffffffff8206079a>] kernel_init+0x9/0xd0
> > [    5.354451]  [<ffffffff8207d2ba>] ret_from_fork+0x7a/0xb0
> > [    5.354451]  [<ffffffff8207d2ba>] ret_from_fork+0x7a/0xb0
> > [    5.354451]  [<ffffffff82060791>] ? rest_init+0xbd/0xbd
> > [    5.354451]  [<ffffffff82060791>] ? rest_init+0xbd/0xbd
> > [    5.354451] Code: 
> > [    5.354451] Code: c0 c0 eb eb f5 f5 31 31 c9 c9 40 40 8a 8a 3c 3c 0e 0e 4d 4d 8d 8d 0c 0c 08 08 40 40 84 84 ff ff 41 41 88 88 3c 3c 08 08 74 74 0d 0d 48 48 ff ff c1 c1 48 48 39 39 ca ca 75 75 e7 e7 41 41 c6 c6 41 41 01 01 00 00 5d 5d c3 c3 55 55 31 31 c0 c0 48 48 89 89 e5 e5 <8a> <8a> 14 14 07 07 3a 3a 14 14 06 06 74 74 07 07 19 19 c0 c0 83 83 c8 c8 01 01 eb eb 09 09 48 48 ff ff c0 c0 84 84 d2 d2 75 75 
> > 
> > [    5.354451] RIP 
> > [    5.354451] RIP  [<ffffffff81446a68>] strcmp+0x6/0x20
> >  [<ffffffff81446a68>] strcmp+0x6/0x20
> > [    5.354451]  RSP <ffff88001204fe28>
> > [    5.354451]  RSP <ffff88001204fe28>
> > [    5.354451] CR2: ffff88000004e5f0
> > [    5.354451] CR2: ffff88000004e5f0
> > [    5.354451] ---[ end trace 8f9377b34c860a0c ]---
> > [    5.354451] ---[ end trace 8f9377b34c860a0c ]---
> > 
> > git bisect start baa21e834941ee5fbe4bd421c871f7c0c5f9a086 70e71ca0af244f48a5dcf56dc435243792e3a495 --
> > git bisect  bad 03d6c3b0fa4f5f0379cede079ec828a6c999fe43  # 16:23      0-      1  iwlwifi: pcie: re-ACK all interrupts after device reset
> > git bisect good 0a79a0c011cb291675e3b80760a452fcba5c59d9  # 16:28     20+      0  iwlwifi: mvm: clear IN_HW_RESTART flag on stop()
> > # first bad commit: [03d6c3b0fa4f5f0379cede079ec828a6c999fe43] iwlwifi: pcie: re-ACK all interrupts after device reset
> > git bisect good 0a79a0c011cb291675e3b80760a452fcba5c59d9  # 16:30     60+      0  iwlwifi: mvm: clear IN_HW_RESTART flag on stop()
> > # extra tests on HEAD of iwlwifi-fixes/master
> > git bisect  bad baa21e834941ee5fbe4bd421c871f7c0c5f9a086  # 16:30      0-      9  iwlwifi: pcie: limit fw chunk sizes given to fh
> > # extra tests on tree/branch iwlwifi-fixes/master
> > git bisect  bad baa21e834941ee5fbe4bd421c871f7c0c5f9a086  # 16:30      0-      9  iwlwifi: pcie: limit fw chunk sizes given to fh
> > # extra tests on tree/branch linus/master
> > git bisect good 44e8967d591686463e84a88b46b03beba3ab49fb  # 16:32     60+      0  Ceph: remove left-over reject file
> > # extra tests on tree/branch next/master
> > git bisect good cfaa3a95dd2b402599b1d8122dc3107478db8717  # 16:35     60+      1  Add linux-next specific files for 20141218
> > 
> > 
> > This script may reproduce the error.
> > 
> > ----------------------------------------------------------------------------
> > #!/bin/bash
> > 
> > kernel=$1
> > initrd=quantal-core-x86_64.cgz
> > 
> > wget --no-clobber https://github.com/fengguang/reproduce-kernel-bug/raw/master/initrd/$initrd
> > 
> > kvm=(
> > 	qemu-system-x86_64
> > 	-cpu kvm64
> > 	-enable-kvm
> > 	-kernel $kernel
> > 	-initrd $initrd
> > 	-m 320
> > 	-smp 2
> > 	-net nic,vlan=1,model=e1000
> > 	-net user,vlan=1
> > 	-boot order=nc
> > 	-no-reboot
> > 	-watchdog i6300esb
> > 	-rtc base=localtime
> > 	-serial stdio
> > 	-display none
> > 	-monitor null 
> > )
> > 
> > append=(
> > 	hung_task_panic=1
> > 	earlyprintk=ttyS0,115200
> > 	debug
> > 	apic=debug
> > 	sysrq_always_enabled
> > 	rcupdate.rcu_cpu_stall_timeout=100
> > 	panic=-1
> > 	softlockup_panic=1
> > 	nmi_watchdog=panic
> > 	oops=panic
> > 	load_ramdisk=2
> > 	prompt_ramdisk=0
> > 	console=ttyS0,115200
> > 	console=tty0
> > 	vga=normal
> > 	root=/dev/ram0
> > 	rw
> > 	drbd.minor_count=8
> > )
> > 
> > "${kvm[@]}" --append "${append[*]}"
> > ----------------------------------------------------------------------------
> > 
> > Thanks,
> > Fengguang
> > _______________________________________________
> > LKP mailing list
> > LKP@linux.intel.com
> 
