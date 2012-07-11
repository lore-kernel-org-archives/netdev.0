From: Dave Jones <davej@redhat.com>
Subject: 3.5-rc6: kernel BUG at kernel/timer.c:711!
Date: Wed, 11 Jul 2012 09:03:56 -0400
Message-ID: <20120711130356.GA3936@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel <linux-kernel@vger.kernel.org>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[34323.844970] ------------[ cut here ]------------
[34323.845555] kernel BUG at kernel/timer.c:711!
[34323.846110] invalid opcode: 0000 [#1] PREEMPT SMP 
[34323.846657] CPU 6 
[34323.846670] Modules linked in:
[34323.853968]  ebtables
[34323.866941]  xt_cpu
[34323.890355]  msdos
[34323.920927]  ppp_synctty
[34323.959787]  raid6_pq
[34323.964221]  raid10 shpchp fakephp aer_inject ptp pps_core target_core_file target_core_iblock target_core_pscsi tcm_loop target_core_mod vga16fb sysimgblt fb_sys_fops syscopyarea vgastate output platform_lcd lcd sysfillrect n_r3964 n_gsm nozomi jsm serio_raw altera_ps2 input_polldev sparse_keymap uinput fuse ipt_ULOG nfnetlink tun binfmt_misc sctp libcrc32c caif_socket caif phonet bluetooth rfkill can llc2 pppoe pppox ppp_generic slhc irda crc_ccitt rds af_key decnet rose x25 atm netrom appletalk ipx p8023 psnap p8022 llc ax25 ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 xt_state nf_conntrack ip6table_filter ip6_tables kvm_intel kvm crc32c_intel ghash_clmulni_intel microcode pcspkr usb_debug i2c_i801 e1000e nfsd nfs_acl auth_rpcgss lockd sunrpc i915 video i2c_algo_bit drm_kms_helper dr
 m i2c_core [last unloaded: scsi_wait_scan]
[34323.997915] 
[34323.999802] Pid: 15419, comm: trinity-child6 Not tainted 3.5.0-rc6+ #102
[34324.004383] RIP: 0010:[<ffffffff8107de30>]  [<ffffffff8107de30>] mod_timer+0x4a0/0x4c0
[34324.006791] RSP: 0018:ffff88004567be08  EFLAGS: 00010246
[34324.008623] RAX: 0000000000000000 RBX: ffff88010eb916b0 RCX: 000000000000000b
[34324.010443] RDX: 0000000000000000 RSI: 0000000000000000 RDI: ffff88004567be10
[34324.012731] RBP: ffff88004567be48 R08: 0000000000000000 R09: 0000000000000000
[34324.014511] R10: 0000000000000001 R11: 0000000000000000 R12: 00000001003f0800
[34324.016552] R13: 00000001003f0b71 R14: ffff880123269600 R15: 00000000ffffff01
[34324.018297] FS:  00007fc0dc317740(0000) GS:ffff880148800000(0000) knlGS:0000000000000000
[34324.020111] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[34324.021834] CR2: 00007fc0da305000 CR3: 000000001bad8000 CR4: 00000000001407e0
[34324.023532] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[34324.025221] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[34324.026874] Process trinity-child6 (pid: 15419, threadinfo ffff88004567a000, task ffff88002ee58000)
[34324.028515] Stack:
[34324.030127]  ffffffff8154108d 0000000000000b04 ffff88004567be28 ffff88010eb91290
[34324.031914]  0000000000000009 0000000000000004 ffff880123269600 00000000ffffff01
[34324.034029]  ffff88004567be68 ffffffff81540d1c ffffffff8154518c ffff88010eb91290
[34324.036201] Call Trace:
[34324.037779]  [<ffffffff8154108d>] ? lock_sock_nested+0x8d/0xa0
[34324.039370]  [<ffffffff81540d1c>] sk_reset_timer+0x1c/0x30
[34324.040921]  [<ffffffff8154518c>] ? sock_setsockopt+0x8c/0x950
[34324.042454]  [<ffffffff8159d350>] inet_csk_reset_keepalive_timer+0x20/0x30
[34324.043950]  [<ffffffff815b491d>] tcp_set_keepalive+0x3d/0x50
[34324.045483]  [<ffffffff81545a13>] sock_setsockopt+0x913/0x950
[34324.046946]  [<ffffffff811d5b0a>] ? fget_light+0x3ca/0x500
[34324.048379]  [<ffffffff81696b19>] ? sysret_check+0x22/0x5d
[34324.050103]  [<ffffffff8153f536>] sys_setsockopt+0xc6/0xe0
[34324.051593]  [<ffffffff81696aed>] system_call_fastpath+0x1a/0x1f
[34324.052966] Code: 4d ff ff ff 48 c7 c7 60 10 c3 81 e8 7b 6e 05 00 85 c0 0f 85 b8 fd ff ff eb 93 48 8b 75 08 48 89 df e8 85 f0 ff ff e9 df fb ff ff <0f> 0b 4d 89 f5 e9 ad fc ff ff 66 0f 1f 44 00 00 e8 c6 38 60 00 
[34324.057257] RIP  [<ffffffff8107de30>] mod_timer+0x4a0/0x4c0
[34324.059070]  RSP <ffff88004567be08>
[34324.062014] ---[ end trace fedc8673629f8303 ]---

That's...

	BUG_ON(!timer->function);
