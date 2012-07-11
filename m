From: Dave Jones <davej@redhat.com>
Subject: 3.5rc6 oops on caif unload.
Date: Tue, 10 Jul 2012 21:48:16 -0400
Message-ID: <20120711014816.GA4930@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: sjur.brandeland@stericsson.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:4463 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755801Ab2GKBsY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Jul 2012 21:48:24 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

rmmod caif got me this surprise ..

general protection fault: 0000 [#1] PREEMPT SMP 
CPU 1 
Modules linked in:
 hfs catc aer_inject ptp pps_core target_core_file target_core_iblock target_core_pscsi tcm_loop target_core_mod vga16fb sysimgblt fb_sys_fops syscopyarea vgastate output platform_lcd lcd sysfillrect n_r3964 n_gsm nozomi jsm serio_raw altera_ps2 input_polldev sparse_keymap uinput bluetooth rfkill cpufreq_stats ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 xt_state nf_conntrack ip6table_filter ip6_tables kvm_intel kvm crc32c_intel ghash_clmulni_intel microcode pcspkr i2c_i801 usb_debug e1000e nfsd nfs_acl auth_rpcgss lockd sunrpc i915 video i2c_algo_bit drm_kms_helper drm i2c_core [last unloaded: caif_socket]
Pid: 17842, comm: modprobe Not tainted 3.5.0-rc6+ #101
RIP: 0010:[<ffffffffa0f7f561>]  [<ffffffffa0f7f561>] caif_get+0x51/0xb0 [caif]
RSP: 0000:ffff88012d5a5df8  EFLAGS: 00010296
RAX: 6b6b6b6b6b6b6b13 RBX: 6b6b6b6b6b6b6b6b RCX: 0000000000000001
RDX: 0000000000000000 RSI: ffffffff81c310e0 RDI: 0000000000000282
RBP: ffff88012d5a5e28 R08: 0000000000000000 R09: 0000000000000001
R10: 0000000000000000 R11: 0000000000000002 R12: ffff880142114828
R13: ffff8801457b22a0 R14: ffff880142114828 R15: 0000000000000000
FS:  00007fa134219740(0000) GS:ffff880147e00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 00000038e1e14e0b CR3: 000000009fa23000 CR4: 00000000001407e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process modprobe (pid: 17842, threadinfo ffff88012d5a4000, task ffff8801304226b0)
Stack:
 ffff88012d5a5e28  6b6b6b6b6b6b6b6b  ffffffffa0f7f350  ffff8801457b22a0  0000000000000009
 6b6b6b6b6b6b6b6b  ffff88012d5a5e88  ffffffffa0f802bd  0000000000000000  0000000000000000
 0000000001319578   0000000000000000

Call Trace:
 [<ffffffffa0f7f350>] ? transmit+0x2e0/0x2e0 [caif]
 [<ffffffffa0f802bd>] caif_device_notify+0x4d/0x5a0 [caif]
 [<ffffffff81552ba9>] unregister_netdevice_notifier+0xb9/0x100
 [<ffffffffa0f86dcc>] caif_device_exit+0x1c/0x250 [caif]
 [<ffffffff810e7734>] sys_delete_module+0x1a4/0x300
 [<ffffffff810da82d>] ? trace_hardirqs_on_caller+0x15d/0x1e0
 [<ffffffff813517de>] ? trace_hardirqs_on_thunk+0x3a/0x3f
 [<ffffffff81696bad>] system_call_fastpath+0x1a/0x1f
Code: 00 48 89 45 d8 48 8b 5d d8 e8 ac 17 11 e0 85 c0 74 10 80 3d 74 9c 00 00 00 74 34 0f 1f 
80 00 00 00 00 49 39 dc 48 8d 43 a8 74 4f <4c> 39 6b 10 74 4b 48 8b 40 58 48 89 45 d8 48 8b 
5d d8 e8 78 17 

RIP 
 [<ffffffffa0f7f561>] caif_get+0x51/0xb0 [caif]
 RSP <ffff88012d5a5df8>
---[ end trace a81c7acd5619effe ]---
