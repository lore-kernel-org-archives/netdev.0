From: Dave Jones <davej@redhat.com>
Subject: decnet triggered lockup
Date: Sat, 15 Jun 2013 14:49:08 -0400
Message-ID: <20130615184908.GB19439@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35806 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754213Ab3FOStQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 15 Jun 2013 14:49:16 -0400
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id r5FInFNe007585
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Sat, 15 Jun 2013 14:49:15 -0400
Received: from gelk.kernelslacker.org (ovpn-113-67.phx2.redhat.com [10.3.113.67])
	by int-mx10.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id r5FIn9Pf003469
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Sat, 15 Jun 2013 14:49:15 -0400
Received: from gelk.kernelslacker.org (localhost [127.0.0.1])
	by gelk.kernelslacker.org (8.14.7/8.14.5) with ESMTP id r5FIn942019704
	for <netdev@vger.kernel.org>; Sat, 15 Jun 2013 14:49:09 -0400
Received: (from davej@localhost)
	by gelk.kernelslacker.org (8.14.7/8.14.7/Submit) id r5FIn8Bg019703
	for netdev@vger.kernel.org; Sat, 15 Jun 2013 14:49:08 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mistakenly left CONFIG_DECNET enabled, and got this followed by
a total lockup.


BUG: soft lockup - CPU#1 stuck for 22s! [trinity-child2:9278]
Modules linked in: 8021q garp bridge stp fuse tun snd_seq_dummy hidp rfcomm ipt_ULOG nfnetlink can_raw can_bcm llc2 decnet netrom scsi_transport_iscsi pppoe pppox ppp_generic slhc appletalk irda phonet af_802154 bnep af_key ipx p8023 psnap p8022 llc rose can af_rxrpc caif_socket caif nfc crc_ccitt atm ax25 bluetooth rfkill x25 rds coretemp hwmon kvm_intel snd_hda_codec_realtek kvm crc32c_intel ghash_clmulni_intel snd_hda_codec_hdmi microcode pcspkr snd_hda_intel snd_hda_codec snd_hwdep snd_seq snd_seq_device e1000e usb_debug snd_pcm snd_page_alloc snd_timer ptp snd pps_core soundcore xfs libcrc32c
irq event stamp: 3487531
hardirqs last  enabled at (3487530): [<ffffffff816ed1e0>] restore_args+0x0/0x30
hardirqs last disabled at (3487531): [<ffffffff816f5cea>] apic_timer_interrupt+0x6a/0x80
softirqs last  enabled at (3153202): [<ffffffff810542d4>] __do_softirq+0x194/0x440
softirqs last disabled at (3153209): [<ffffffff8105473d>] irq_exit+0xcd/0xe0
CPU: 1 PID: 9278 Comm: trinity-child2 Not tainted 3.10.0-rc5+ #13
task: ffff8801684fca40 ti: ffff88018c89c000 task.ti: ffff88018c89c000
RIP: 0010:[<ffffffff816ec5a7>]  [<ffffffff816ec5a7>] _raw_spin_unlock_irqrestore+0x67/0x80
RSP: 0018:ffff880244a03d90  EFLAGS: 00000286
RAX: ffff8801684fca40 RBX: ffffffff816ed1e0 RCX: 0000000000000002
RDX: 0000000000004340 RSI: ffff8801684fd1f8 RDI: ffff8801684fca40
RBP: ffff880244a03da0 R08: 0000000010000103 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000001 R12: ffff880244a03d08
R13: ffffffff816f5cef R14: ffff880244a03da0 R15: ffff8802432ec000
FS:  00007fbed31ba740(0000) GS:ffff880244a00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 0000003850abc720 CR3: 000000022c843000 CR4: 00000000001407e0
DR0: 0000000001717000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000600
Stack:
 ffff880219ec0de8 ffff8802432ec000 ffff880244a03de0 ffffffff8105dc39
 0000000000000286 ffff880219ec09c0 ffff880219ec0a10 0000000010000101
 ffffffffa04c21d0 ffff880219ec09c0 ffff880244a03df8 ffffffff81594a88
Call Trace:
 <IRQ> 
 [<ffffffff8105dc39>] mod_timer+0x119/0x320
 [<ffffffffa04c21d0>] ? dn_neigh_elist+0x40/0x40 [decnet]
 [<ffffffff81594a88>] sk_reset_timer+0x18/0x30
 [<ffffffffa04c224c>] dn_slow_timer+0x7c/0x110 [decnet]
 [<ffffffff8105ca6a>] call_timer_fn+0x8a/0x370
 [<ffffffff8105c9e5>] ? call_timer_fn+0x5/0x370
 [<ffffffffa04c21d0>] ? dn_neigh_elist+0x40/0x40 [decnet]
 [<ffffffff8105cf8c>] run_timer_softirq+0x23c/0x390
 [<ffffffff8105423f>] __do_softirq+0xff/0x440
 [<ffffffff8105473d>] irq_exit+0xcd/0xe0
 [<ffffffff816f6b8b>] smp_apic_timer_interrupt+0x6b/0x9b
 [<ffffffff816f5cef>] apic_timer_interrupt+0x6f/0x80
 <EOI> 
 [<ffffffff8114f7ef>] ? free_hot_cold_page+0xff/0x180
 [<ffffffff8114fa47>] __free_pages+0x47/0x70
 [<ffffffff8114fac1>] free_pages+0x51/0x60
 [<ffffffff81034003>] pgd_free+0x53/0x60
 [<ffffffff81046da9>] __mmdrop+0x29/0xb0
 [<ffffffff81086d0d>] finish_task_switch+0xfd/0x130
 [<ffffffff81086c57>] ? finish_task_switch+0x47/0x130
 [<ffffffff816ea6e4>] __schedule+0x444/0x9c0
 [<ffffffff816eb2c3>] preempt_schedule_irq+0x53/0x90
 [<ffffffff81595d33>] ? release_sock+0x193/0x1f0
 [<ffffffff816ed2f6>] retint_kernel+0x26/0x30
 [<ffffffff81052ea2>] ? local_bh_enable_ip+0x82/0xf0
 [<ffffffff816ec53a>] _raw_spin_unlock_bh+0x3a/0x40
 [<ffffffff81595d33>] release_sock+0x193/0x1f0
 [<ffffffffa03b0b91>] llcp_sock_listen+0x71/0xd0 [nfc]
 [<ffffffff81592ef5>] SyS_listen+0x85/0x90
 [<ffffffff816f5294>] tracesys+0xdd/0xe2
Code: 00 e8 9e 47 00 00 65 48 8b 04 25 f0 b9 00 00 48 8b 80 38 e0 ff ff a8 08 75 13 5b 41 5c 5d c3 0f 1f 44 00 00 e8 fb ad 9c ff 53 9d <eb> cf 0f 1f 80 00 00 00 00 e8 bb ea ff ff eb df 66 0f 1f 84 00 
BUG: soft lockup - CPU#1 stuck for 22s! [trinity-child2:9278]
Modules linked in: 8021q garp bridge stp fuse tun snd_seq_dummy hidp rfcomm ipt_ULOG nfnetlink can_raw can_bcm llc2 decnet netrom scsi_transport_iscsi pppoe pppox ppp_generic slhc appletalk irda phonet af_802154 bnep af_key ipx p8023 psnap p8022 llc rose can af_rxrpc caif_socket caif nfc crc_ccitt atm ax25 bluetooth rfkill x25 rds coretemp hwmon kvm_intel snd_hda_codec_realtek kvm crc32c_intel ghash_clmulni_intel snd_hda_codec_hdmi microcode pcspkr snd_hda_intel snd_hda_codec snd_hwdep snd_seq snd_seq_device e1000e usb_debug snd_pcm snd_page_alloc snd_timer ptp snd pps_core soundcore xfs libcrc32c
irq event stamp: 4605143
hardirqs last  enabled at (4605142): [<ffffffff816ed1e0>] restore_args+0x0/0x30
hardirqs last disabled at (4605143): [<ffffffff816f5cea>] apic_timer_interrupt+0x6a/0x80
softirqs last  enabled at (4331570): [<ffffffff810542d4>] __do_softirq+0x194/0x440
softirqs last disabled at (4331581): [<ffffffff8105473d>] irq_exit+0xcd/0xe0
CPU: 1 PID: 9278 Comm: trinity-child2 Not tainted 3.10.0-rc5+ #13
RSP: 0018:ffff880244a03dc0  EFLAGS: 00000246
RAX: ffff8801684fca40 RBX: ffffffff816ed1e0 RCX: 0000000010e00000
RDX: ffffffff8216fe60 RSI: 0000000000000000 RDI: ffffffffef200438
RBP: ffff880244a03e18 R08: ffff8801684fd1c0 R09: 0000000000000001
R10: 0000000000000000 R11: 0000000000000001 R12: ffff880244a03d38
R13: ffffffff816f5cef R14: ffff880244a03e18 R15: 0000000000000000
FS:  00007fbed31ba740(0000) GS:ffff880244a00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 0000003850abc720 CR3: 000000022c843000 CR4: 00000000001407e0
DR0: 0000000001717000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000600
Stack:
 0000000000000000 ffffffff8105c9e5 ffff880200000000 0000000000000246
 0000000000000002 ffff880244a03e30 ffff8802432ec000 ffff88022a4c5228
 0000000010000102 ffffffffa04c21d0 ffff88022a4c4e00 ffff880244a03e88
Call Trace:
 <IRQ> 
 [<ffffffff8105c9e5>] ? call_timer_fn+0x5/0x370
 [<ffffffffa04c21d0>] ? dn_neigh_elist+0x40/0x40 [decnet]
 [<ffffffff8105ca5f>] call_timer_fn+0x7f/0x370
 [<ffffffff8105c9e5>] ? call_timer_fn+0x5/0x370
 [<ffffffffa04c21d0>] ? dn_neigh_elist+0x40/0x40 [decnet]
 [<ffffffff8105cf8c>] run_timer_softirq+0x23c/0x390
 [<ffffffff8105423f>] __do_softirq+0xff/0x440
 [<ffffffff8105473d>] irq_exit+0xcd/0xe0
 [<ffffffff816f6b8b>] smp_apic_timer_interrupt+0x6b/0x9b
 [<ffffffff816f5cef>] apic_timer_interrupt+0x6f/0x80
 <EOI> 
 [<ffffffff816ec5a7>] ? _raw_spin_unlock_irqrestore+0x67/0x80
 [<ffffffff816e21c9>] __slab_free+0x5f/0x39f
 [<ffffffff816ec5b5>] ? _raw_spin_unlock_irqrestore+0x75/0x80
 [<ffffffff813149be>] ? debug_check_no_obj_freed+0x14e/0x250
 [<ffffffff81198d35>] ? kmem_cache_free+0x95/0x300
 [<ffffffff81198f8c>] kmem_cache_free+0x2ec/0x300
 [<ffffffff81046df2>] ? __mmdrop+0x72/0xb0
 [<ffffffff81046df2>] __mmdrop+0x72/0xb0
 [<ffffffff81086d0d>] finish_task_switch+0xfd/0x130
 [<ffffffff81086c57>] ? finish_task_switch+0x47/0x130
 [<ffffffff816ea6e4>] __schedule+0x444/0x9c0
 [<ffffffff816eb2c3>] preempt_schedule_irq+0x53/0x90
 [<ffffffff81595d33>] ? release_sock+0x193/0x1f0
 [<ffffffff816ed2f6>] retint_kernel+0x26/0x30
 [<ffffffff81052ea2>] ? local_bh_enable_ip+0x82/0xf0
 [<ffffffff816ec53a>] _raw_spin_unlock_bh+0x3a/0x40
 [<ffffffff81595d33>] release_sock+0x193/0x1f0
 [<ffffffffa03b0b91>] llcp_sock_listen+0x71/0xd0 [nfc]
 [<ffffffff81592ef5>] SyS_listen+0x85/0x90
 [<ffffffff816f5294>] tracesys+0xdd/0xe2
Code: 49 c1 e9 09 48 89 44 24 08 49 83 f1 01 41 83 e1 01 e8 5f dd ff ff 65 48 8b 04 25 00 ba 00 00 c7 80 7c 07 00 00 00 00 00 00 53 9d <48> 83 c4 30 5b 41 5c 41 5d 41 5e 41 5f 5d c3 0f 1f 00 65 48 8b 
BUG: soft lockup - CPU#1 stuck for 22s! [trinity-child2:9278]
Modules linked in: 8021q garp bridge stp fuse tun snd_seq_dummy hidp rfcomm ipt_ULOG nfnetlink can_raw can_bcm llc2 decnet netrom scsi_transport_iscsi pppoe pppox ppp_generic slhc appletalk irda phonet af_802154 bnep af_key ipx p8023 psnap p8022 llc rose can af_rxrpc caif_socket caif nfc crc_ccitt atm ax25 bluetooth rfkill x25 rds coretemp hwmon kvm_intel snd_hda_codec_realtek kvm crc32c_intel ghash_clmulni_intel snd_hda_codec_hdmi microcode pcspkr snd_hda_intel snd_hda_codec snd_hwdep snd_seq snd_seq_device e1000e usb_debug snd_pcm snd_page_alloc snd_timer ptp snd pps_core soundcore xfs libcrc32c
irq event stamp: 10864695
hardirqs last  enabled at (10864694): [<ffffffff816ed1e0>] restore_args+0x0/0x30
hardirqs last disabled at (10864695): [<ffffffff816f5cea>] apic_timer_interrupt+0x6a/0x80
softirqs last  enabled at (9770178): [<ffffffff810542d4>] __do_softirq+0x194/0x440
softirqs last disabled at (9770181): [<ffffffff8105473d>] irq_exit+0xcd/0xe0
CPU: 1 PID: 9278 Comm: trinity-child2 Not tainted 3.10.0-rc5+ #13
task: ffff8801684fca40 ti: ffff88018c89c000 task.ti: ffff88018c89c000
RIP: 0010:[<ffffffff816ec5f2>]  [<ffffffff816ec5f2>] _raw_spin_unlock_irq+0x32/0x60
RSP: 0018:ffff880244a03e80  EFLAGS: 00000202
RAX: ffff8801684fca40 RBX: ffffffff816ed1e0 RCX: 0000000000000000
RDX: 0000000000000000 RSI: 0000000000000000 RDI: 0000000000000001
RBP: ffff880244a03e88 R08: 0000000010000101 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000001 R12: ffff880244a03df8
R13: ffffffff816f5cef R14: ffff880244a03e88 R15: ffff88020232ab28
FS:  00007fbed31ba740(0000) GS:ffff880244a00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00007f748879c000 CR3: 000000022c843000 CR4: 00000000001407e0
DR0: 0000000001717000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000600
Stack:
 ffff8802432ec000 ffff880244a03ef8 ffffffff8105cf7d ffff88018c89dfd8
 ffff88018c89dfd8 ffff88018c89dfd8 ffff88018c89dfd8 ffff88020232a700
 ffff8801f23b34e8 ffff88020a54c868 0000000000000001 0000000000000001
Call Trace:
 <IRQ> 
 [<ffffffff8105cf7d>] run_timer_softirq+0x22d/0x390
 [<ffffffff8105423f>] __do_softirq+0xff/0x440
 [<ffffffff8105473d>] irq_exit+0xcd/0xe0
 [<ffffffff816f6b8b>] smp_apic_timer_interrupt+0x6b/0x9b
 [<ffffffff816f5cef>] apic_timer_interrupt+0x6f/0x80
 <EOI> 
 [<ffffffff816ea2a0>] ? wait_for_completion_interruptible+0x180/0x180
 [<ffffffff816eb2c3>] ? preempt_schedule_irq+0x53/0x90
 [<ffffffff816ed2f6>] retint_kernel+0x26/0x30
 [<ffffffff81145297>] ? user_enter+0x87/0xd0
 [<ffffffff8100f6f8>] syscall_trace_leave+0x78/0x140
 [<ffffffff816f536f>] int_check_syscall_exit_work+0x34/0x3d
Code: 01 00 00 00 48 89 e5 53 48 89 fb 48 8b 55 08 48 8d 7f 18 e8 01 d8 9c ff 48 89 df e8 19 55 c2 ff e8 b4 ad 9c ff fb bf 01 00 00 00 <e8> 29 47 00 00 65 48 8b 04 25 f0 b9 00 00 48 8b 80 38 e0 ff ff 
BUG: soft lockup - CPU#1 stuck for 23s! [trinity-child2:9278]
Modules linked in: 8021q garp bridge stp fuse tun snd_seq_dummy hidp rfcomm ipt_ULOG nfnetlink can_raw can_bcm llc2 decnet netrom scsi_transport_iscsi pppoe pppox ppp_generic slhc appletalk irda phonet af_802154 bnep af_key ipx p8023 psnap p8022 llc rose can af_rxrpc caif_socket caif nfc crc_ccitt atm ax25 bluetooth rfkill x25 rds coretemp hwmon kvm_intel snd_hda_codec_realtek kvm crc32c_intel ghash_clmulni_intel snd_hda_codec_hdmi microcode pcspkr snd_hda_intel snd_hda_codec snd_hwdep snd_seq snd_seq_device e1000e usb_debug snd_pcm snd_page_alloc snd_timer ptp snd pps_core soundcore xfs libcrc32c
irq event stamp: 18101305
hardirqs last  enabled at (18101304): [<ffffffff816ed1e0>] restore_args+0x0/0x30
hardirqs last disabled at (18101305): [<ffffffff816f5cea>] apic_timer_interrupt+0x6a/0x80
softirqs last  enabled at (17715300): [<ffffffff810542d4>] __do_softirq+0x194/0x440
softirqs last disabled at (17715303): [<ffffffff8105473d>] irq_exit+0xcd/0xe0
CPU: 1 PID: 9278 Comm: trinity-child2 Not tainted 3.10.0-rc5+ #13
task: ffff8801684fca40 ti: ffff88018c89c000 task.ti: ffff88018c89c000
RIP: 0010:[<ffffffff816ec5a7>]  [<ffffffff816ec5a7>] _raw_spin_unlock_irqrestore+0x67/0x80
RSP: 0018:ffff880244a03d90  EFLAGS: 00000286
RAX: ffff8801684fca40 RBX: ffffffff816ed1e0 RCX: 0000000000000002
RDX: 0000000000004340 RSI: ffff8801684fd1f8 RDI: ffff8801684fca40
RBP: ffff880244a03da0 R08: 0000000010000102 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000001 R12: ffff880244a03d08
R13: ffffffff816f5cef R14: ffff880244a03da0 R15: ffff8802432ec000
FS:  00007fbed31ba740(0000) GS:ffff880244a00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00007f748879c000 CR3: 000000022c843000 CR4: 00000000001407e0
DR0: 0000000001717000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000600
Stack:
 ffff88018ca62168 ffff8802432ec000 ffff880244a03de0 ffffffff8105dc39
 0000000000000286 ffff88018ca61d40 ffff88018ca61d90 0000000010000100
 ffffffffa04c21d0 ffff88018ca61d40 ffff880244a03df8 ffffffff81594a88
Call Trace:
 <IRQ> 
 [<ffffffff8105dc39>] mod_timer+0x119/0x320
 [<ffffffffa04c21d0>] ? dn_neigh_elist+0x40/0x40 [decnet]
 [<ffffffff81594a88>] sk_reset_timer+0x18/0x30
 [<ffffffffa04c224c>] dn_slow_timer+0x7c/0x110 [decnet]
 [<ffffffff8105ca6a>] call_timer_fn+0x8a/0x370
 [<ffffffff8105c9e5>] ? call_timer_fn+0x5/0x370
 [<ffffffffa04c21d0>] ? dn_neigh_elist+0x40/0x40 [decnet]
 [<ffffffff8105cf8c>] run_timer_softirq+0x23c/0x390
 [<ffffffff8105423f>] __do_softirq+0xff/0x440
 [<ffffffff8105473d>] irq_exit+0xcd/0xe0
 [<ffffffff816f6b8b>] smp_apic_timer_interrupt+0x6b/0x9b
 [<ffffffff816f5cef>] apic_timer_interrupt+0x6f/0x80
 <EOI> 
 [<ffffffff816ed1e0>] ? retint_restore_args+0xe/0xe
 [<ffffffff816ea2a0>] ? wait_for_completion_interruptible+0x180/0x180
 [<ffffffff816eb2c3>] ? preempt_schedule_irq+0x53/0x90
 [<ffffffff816ed2f6>] retint_kernel+0x26/0x30
 [<ffffffff81145297>] ? user_enter+0x87/0xd0
 [<ffffffff8100f6f8>] syscall_trace_leave+0x78/0x140
 [<ffffffff816f536f>] int_check_syscall_exit_work+0x34/0x3d
Code: 00 e8 9e 47 00 00 65 48 8b 04 25 f0 b9 00 00 48 8b 80 38 e0 ff ff a8 08 75 13 5b 41 5c 5d c3 0f 1f 44 00 00 e8 fb ad 9c ff 53 9d <eb> cf 0f 1f 80 00 00 00 00 e8 bb ea ff ff eb df 66 0f 1f 84 00 
BUG: soft lockup - CPU#1 stuck for 23s! [trinity-child2:9278]
Modules linked in: 8021q garp bridge stp fuse tun snd_seq_dummy hidp rfcomm ipt_ULOG nfnetlink can_raw can_bcm llc2 decnet netrom scsi_transport_iscsi pppoe pppox ppp_generic slhc appletalk irda phonet af_802154 bnep af_key ipx p8023 psnap p8022 llc rose can af_rxrpc caif_socket caif nfc crc_ccitt atm ax25 bluetooth rfkill x25 rds coretemp hwmon kvm_intel snd_hda_codec_realtek kvm crc32c_intel ghash_clmulni_intel snd_hda_codec_hdmi microcode pcspkr snd_hda_intel snd_hda_codec snd_hwdep snd_seq snd_seq_device e1000e usb_debug snd_pcm snd_page_alloc snd_timer ptp snd pps_core soundcore xfs libcrc32c
irq event stamp: 30921163
hardirqs last  enabled at (30921162): [<ffffffff816ed1e0>] restore_args+0x0/0x30
hardirqs last disabled at (30921163): [<ffffffff816f5cea>] apic_timer_interrupt+0x6a/0x80
softirqs last  enabled at (29829218): [<ffffffff810542d4>] __do_softirq+0x194/0x440
softirqs last disabled at (29829621): [<ffffffff8105473d>] irq_exit+0xcd/0xe0
CPU: 1 PID: 9278 Comm: trinity-child2 Not tainted 3.10.0-rc5+ #13
task: ffff8801684fca40 ti: ffff88018c89c000 task.ti: ffff88018c89c000
RIP: 0010:[<ffffffff816ec5a7>]  [<ffffffff816ec5a7>] _raw_spin_unlock_irqrestore+0x67/0x80
RSP: 0018:ffff880244a03d90  EFLAGS: 00000286
RAX: ffff8801684fca40 RBX: ffffffff816ed1e0 RCX: 0000000000000002
RDX: 0000000000004340 RSI: ffff8801684fd1f8 RDI: ffff8801684fca40
RBP: ffff880244a03da0 R08: 0000000000000102 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000001 R12: ffff880244a03d08
R13: ffffffff816f5cef R14: ffff880244a03da0 R15: ffff8802432ec000
FS:  00007fbed31ba740(0000) GS:ffff880244a00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 0000003850abc720 CR3: 000000022c843000 CR4: 00000000001407e0
DR0: 0000000001717000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000600
Stack:
 ffff880219ec34e8 ffff8802432ec000 ffff880244a03de0 ffffffff8105dc39
 0000000000000286 ffff880219ec30c0 ffff880219ec3110 0000000000000100
 ffffffffa04c21d0 ffff880219ec30c0 ffff880244a03df8 ffffffff81594a88
Call Trace:
 <IRQ> 
 [<ffffffff8105dc39>] mod_timer+0x119/0x320
 [<ffffffffa04c21d0>] ? dn_neigh_elist+0x40/0x40 [decnet]
 [<ffffffff81594a88>] sk_reset_timer+0x18/0x30
 [<ffffffffa04c224c>] dn_slow_timer+0x7c/0x110 [decnet]
 [<ffffffff8105ca6a>] call_timer_fn+0x8a/0x370
 [<ffffffff8105c9e5>] ? call_timer_fn+0x5/0x370
 [<ffffffffa04c21d0>] ? dn_neigh_elist+0x40/0x40 [decnet]
 [<ffffffff8105cf8c>] run_timer_softirq+0x23c/0x390
 [<ffffffff8105423f>] __do_softirq+0xff/0x440
 [<ffffffff8105473d>] irq_exit+0xcd/0xe0
 [<ffffffff816f6b8b>] smp_apic_timer_interrupt+0x6b/0x9b
 [<ffffffff816f5cef>] apic_timer_interrupt+0x6f/0x80
 <EOI> 
 [<ffffffff816ed1e0>] ? retint_restore_args+0xe/0xe
 [<ffffffff81145297>] ? user_enter+0x87/0xd0
 [<ffffffff8100f6f8>] syscall_trace_leave+0x78/0x140
 [<ffffffff816f536f>] int_check_syscall_exit_work+0x34/0x3d
Code: 00 e8 9e 47 00 00 65 48 8b 04 25 f0 b9 00 00 48 8b 80 38 e0 ff ff a8 08 75 13 5b 41 5c 5d c3 0f 1f 44 00 00 e8 fb ad 9c ff 53 9d <eb> cf 0f 1f 80 00 00 00 00 e8 bb ea ff ff eb df 66 0f 1f 84 00 
BUG: soft lockup - CPU#1 stuck for 22s! [trinity-child2:9278]
Modules linked in: 8021q garp bridge stp fuse tun snd_seq_dummy hidp rfcomm ipt_ULOG nfnetlink can_raw can_bcm llc2 decnet netrom scsi_transport_iscsi pppoe pppox ppp_generic slhc appletalk irda phonet af_802154 bnep af_key ipx p8023 psnap p8022 llc rose can af_rxrpc caif_socket caif nfc crc_ccitt atm ax25 bluetooth rfkill x25 rds coretemp hwmon kvm_intel snd_hda_codec_realtek kvm crc32c_intel ghash_clmulni_intel snd_hda_codec_hdmi microcode pcspkr snd_hda_intel snd_hda_codec snd_hwdep snd_seq snd_seq_device e1000e usb_debug snd_pcm snd_page_alloc snd_timer ptp snd pps_core soundcore xfs libcrc32c
irq event stamp: 36540201
hardirqs last  enabled at (36540200): [<ffffffff816ed1e0>] restore_args+0x0/0x30
hardirqs last disabled at (36540201): [<ffffffff816f5cea>] apic_timer_interrupt+0x6a/0x80
softirqs last  enabled at (36329390): [<ffffffff810542d4>] __do_softirq+0x194/0x440
softirqs last disabled at (36329393): [<ffffffff8105473d>] irq_exit+0xcd/0xe0
CPU: 1 PID: 9278 Comm: trinity-child2 Not tainted 3.10.0-rc5+ #13
task: ffff8801684fca40 ti: ffff88018c89c000 task.ti: ffff88018c89c000
RIP: 0010:[<ffffffff816ec5f2>]  [<ffffffff816ec5f2>] _raw_spin_unlock_irq+0x32/0x60
RSP: 0018:ffff880244a03e80  EFLAGS: 00000216
RAX: ffff8801684fca40 RBX: ffffffff816ed1e0 RCX: 0000000000000000
RDX: 0000000000000000 RSI: 0000000000000000 RDI: 0000000000000001
RBP: ffff880244a03e88 R08: 0000000010000101 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000001 R12: ffff880244a03df8
R13: ffffffff816f5cef R14: ffff880244a03e88 R15: ffff880184d8ef68
FS:  00007fbed31ba740(0000) GS:ffff880244a00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00007f748879c000 CR3: 000000022c843000 CR4: 00000000001407e0
DR0: 0000000001717000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000600
Stack:
 ffff8802432ec000 ffff880244a03ef8 ffffffff8105cf7d ffff88018c89dfd8
 ffff88018c89dfd8 ffff88018c89dfd8 ffff88018c89dfd8 ffff880184d8eb40
 ffff880184d8e5a8 ffff88020232ef68 0000000000000001 0000000000000001
Call Trace:
 <IRQ> 
 [<ffffffff8105cf7d>] run_timer_softirq+0x22d/0x390
 [<ffffffff8105423f>] __do_softirq+0xff/0x440
 [<ffffffff8105473d>] irq_exit+0xcd/0xe0
 [<ffffffff816f6b8b>] smp_apic_timer_interrupt+0x6b/0x9b
 [<ffffffff816f5cef>] apic_timer_interrupt+0x6f/0x80
 <EOI> 
 [<ffffffff816ed1e0>] ? retint_restore_args+0xe/0xe
 [<ffffffff816ea2a0>] ? wait_for_completion_interruptible+0x180/0x180
 [<ffffffff816eb2c3>] ? preempt_schedule_irq+0x53/0x90
 [<ffffffff816ed2f6>] retint_kernel+0x26/0x30
 [<ffffffff81145297>] ? user_enter+0x87/0xd0
 [<ffffffff8100f6f8>] syscall_trace_leave+0x78/0x140
 [<ffffffff816f536f>] int_check_syscall_exit_work+0x34/0x3d
Code: 01 00 00 00 48 89 e5 53 48 89 fb 48 8b 55 08 48 8d 7f 18 e8 01 d8 9c ff 48 89 df e8 19 55 c2 ff e8 b4 ad 9c ff fb bf 01 00 00 00 <e8> 29 47 00 00 65 48 8b 04 25 f0 b9 00 00 48 8b 80 38 e0 ff ff 
BUG: soft lockup - CPU#0 stuck for 22s! [trinity-child2:9278]
Modules linked in: 8021q garp bridge stp fuse tun snd_seq_dummy hidp rfcomm ipt_ULOG nfnetlink can_raw can_bcm llc2 decnet netrom scsi_transport_iscsi pppoe pppox ppp_generic slhc appletalk irda phonet af_802154 bnep af_key ipx p8023 psnap p8022 llc rose can af_rxrpc caif_socket caif nfc crc_ccitt atm ax25 bluetooth rfkill x25 rds coretemp hwmon kvm_intel snd_hda_codec_realtek kvm crc32c_intel ghash_clmulni_intel snd_hda_codec_hdmi microcode pcspkr snd_hda_intel snd_hda_codec snd_hwdep snd_seq snd_seq_device e1000e usb_debug snd_pcm snd_page_alloc snd_timer ptp snd pps_core soundcore xfs libcrc32c
irq event stamp: 42158897
hardirqs last  enabled at (42158896): [<ffffffff816ed1e0>] restore_args+0x0/0x30
hardirqs last disabled at (42158897): [<ffffffff816f5cea>] apic_timer_interrupt+0x6a/0x80
softirqs last  enabled at (41212430): [<ffffffff810542d4>] __do_softirq+0x194/0x440
softirqs last disabled at (41212433): [<ffffffff8105473d>] irq_exit+0xcd/0xe0
CPU: 0 PID: 9278 Comm: trinity-child2 Not tainted 3.10.0-rc5+ #13
task: ffff8801684fca40 ti: ffff88018c89c000 task.ti: ffff88018c89c000
RIP: 0010:[<ffffffff816ec5f2>]  [<ffffffff816ec5f2>] _raw_spin_unlock_irq+0x32/0x60
RSP: 0018:ffff880244803e80  EFLAGS: 00000206
RAX: ffff8801684fca40 RBX: ffffffff816ed1e0 RCX: 0000000000000000
RDX: 0000000000000000 RSI: 0000000000000000 RDI: 0000000000000001
RBP: ffff880244803e88 R08: 0000000000000102 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000001 R12: ffff880244803df8
R13: ffffffff816f5cef R14: ffff880244803e88 R15: ffff88020236e5a8
FS:  00007fbed31ba740(0000) GS:ffff880244800000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00007f748879c000 CR3: 000000023cbdd000 CR4: 00000000001407f0
DR0: 0000000001717000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000600
Stack:
 ffffffff820fe240 ffff880244803ef8 ffffffff8105cf7d ffff88018c89dfd8
 ffff88018c89dfd8 ffff88018c89dfd8 ffff88018c89dfd8 ffff88020236e180
 ffff88022a4c17a8 ffff8802023fc868 0000000000000001 0000000000000001
Call Trace:
 <IRQ> 
 [<ffffffff8105cf7d>] run_timer_softirq+0x22d/0x390
 [<ffffffff8105423f>] __do_softirq+0xff/0x440
 [<ffffffff8105473d>] irq_exit+0xcd/0xe0
 [<ffffffff816f6b8b>] smp_apic_timer_interrupt+0x6b/0x9b
 [<ffffffff816f5cef>] apic_timer_interrupt+0x6f/0x80
 <EOI> 
 [<ffffffff816ed1e0>] ? retint_restore_args+0xe/0xe
 [<ffffffff816ec5a7>] ? _raw_spin_unlock_irqrestore+0x67/0x80
 [<ffffffff813149be>] debug_check_no_obj_freed+0x14e/0x250
 [<ffffffff810b72dd>] ? trace_hardirqs_on_caller+0xfd/0x1c0
 [<ffffffff8114e9b3>] free_pages_prepare+0x193/0x2a0
 [<ffffffff8114ef89>] free_compound_page+0x29/0x40
 [<ffffffff81154bbf>] __put_compound_page+0x1f/0x30
 [<ffffffff81154c55>] put_compound_page+0x55/0x200
 [<ffffffff8115534f>] release_pages+0x1cf/0x1e0
 [<ffffffff81183b5d>] free_pages_and_swap_cache+0xad/0xd0
 [<ffffffff8116d72c>] tlb_flush_mmu.part.69+0x4c/0x90
 [<ffffffff8116dd75>] tlb_finish_mmu+0x55/0x60
 [<ffffffff81178730>] exit_mmap+0xf0/0x170
 [<ffffffff810472df>] mmput+0x6f/0x100
 [<ffffffff8104f30c>] do_exit+0x27c/0xcd0
 [<ffffffff816ec5ec>] ? _raw_spin_unlock_irq+0x2c/0x60
 [<ffffffff8105114c>] do_group_exit+0x4c/0xc0
 [<ffffffff810636f1>] get_signal_to_deliver+0x2e1/0x940
 [<ffffffff81002418>] do_signal+0x48/0x5a0
 [<ffffffff810b437e>] ? put_lock_stats.isra.29+0xe/0x40
 [<ffffffff8108ce2d>] ? get_parent_ip+0xd/0x50
 [<ffffffff81145325>] ? user_exit+0x45/0x90
 [<ffffffff810b72dd>] ? trace_hardirqs_on_caller+0xfd/0x1c0
 [<ffffffff810029e8>] do_notify_resume+0x78/0x90
 [<ffffffff816f538a>] int_signal+0x12/0x17
Code: 01 00 00 00 48 89 e5 53 48 89 fb 48 8b 55 08 48 8d 7f 18 e8 01 d8 9c ff 48 89 df e8 19 55 c2 ff e8 b4 ad 9c ff fb bf 01 00 00 00 <e8> 29 47 00 00 65 48 8b 04 25 f0 b9 00 00 48 8b 80 38 e0 ff ff 
BUG: soft lockup - CPU#0 stuck for 23s! [trinity-child2:9278]
Modules linked in: 8021q garp bridge stp fuse tun snd_seq_dummy hidp rfcomm ipt_ULOG nfnetlink can_raw can_bcm llc2 decnet netrom scsi_transport_iscsi pppoe pppox ppp_generic slhc appletalk irda phonet af_802154 bnep af_key ipx p8023 psnap p8022 llc rose can af_rxrpc caif_socket caif nfc crc_ccitt atm ax25 bluetooth rfkill x25 rds coretemp hwmon kvm_intel snd_hda_codec_realtek kvm crc32c_intel ghash_clmulni_intel snd_hda_codec_hdmi microcode pcspkr snd_hda_intel snd_hda_codec snd_hwdep snd_seq snd_seq_device e1000e usb_debug snd_pcm snd_page_alloc snd_timer ptp snd pps_core soundcore xfs libcrc32c
irq event stamp: 43337155
hardirqs last  enabled at (43337154): [<ffffffff816ed1e0>] restore_args+0x0/0x30
hardirqs last disabled at (43337155): [<ffffffff816f5cea>] apic_timer_interrupt+0x6a/0x80
softirqs last  enabled at (42835484): [<ffffffff810542d4>] __do_softirq+0x194/0x440
softirqs last disabled at (42835487): [<ffffffff8105473d>] irq_exit+0xcd/0xe0
CPU: 0 PID: 9278 Comm: trinity-child2 Not tainted 3.10.0-rc5+ #13
task: ffff8801684fca40 ti: ffff88018c89c000 task.ti: ffff88018c89c000
RIP: 0010:[<ffffffff810b9946>]  [<ffffffff810b9946>] lock_acquire+0xa6/0x1f0
RSP: 0018:ffff880244803d78  EFLAGS: 00000246
RAX: ffff8801684fca40 RBX: ffffffff816ed1e0 RCX: 0000021c10cc0000
RDX: ffffffff8216fe80 RSI: 0000000000000038 RDI: fffffde3efbb0433
RBP: ffff880244803dd0 R08: ffff8801684fd1f8 R09: 0000000000000001
R10: 0000000000000000 R11: 0000000000000001 R12: ffff880244803ce8
R13: ffffffff816f5cef R14: ffff880244803dd0 R15: 0000000000000000
FS:  00007fbed31ba740(0000) GS:ffff880244800000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00007f748879c000 CR3: 000000023cbdd000 CR4: 00000000001407f0
DR0: 0000000001717000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000600
Stack:
 0000000000000000 ffffffffa04c21eb 0000000000000000 0000000000000246
 0000000000000000 ffff8801f23b13e8 ffff8801f23b13d0 ffff8801f23b13e8
 0000000000000101 ffffffffa04c21d0 ffff8801f23b1380 ffff880244803df8
Call Trace:
 <IRQ> 
 [<ffffffffa04c21eb>] ? dn_slow_timer+0x1b/0x110 [decnet]
 [<ffffffffa04c21d0>] ? dn_neigh_elist+0x40/0x40 [decnet]
 [<ffffffff816ec140>] _raw_spin_lock+0x40/0x80
 [<ffffffffa04c21eb>] ? dn_slow_timer+0x1b/0x110 [decnet]
 [<ffffffffa04c21eb>] dn_slow_timer+0x1b/0x110 [decnet]
 [<ffffffff8105ca6a>] call_timer_fn+0x8a/0x370
 [<ffffffff8105c9e5>] ? call_timer_fn+0x5/0x370
 [<ffffffffa04c21d0>] ? dn_neigh_elist+0x40/0x40 [decnet]
 [<ffffffff8105cf8c>] run_timer_softirq+0x23c/0x390
 [<ffffffff8105423f>] __do_softirq+0xff/0x440
 [<ffffffff8105473d>] irq_exit+0xcd/0xe0
 [<ffffffff816f6b8b>] smp_apic_timer_interrupt+0x6b/0x9b
 [<ffffffff816f5cef>] apic_timer_interrupt+0x6f/0x80
 <EOI> 
 [<ffffffff816ed1e0>] ? retint_restore_args+0xe/0xe
 [<ffffffff816ec5a7>] ? _raw_spin_unlock_irqrestore+0x67/0x80
 [<ffffffff813149be>] debug_check_no_obj_freed+0x14e/0x250
 [<ffffffff810b72dd>] ? trace_hardirqs_on_caller+0xfd/0x1c0
 [<ffffffff8114e9b3>] free_pages_prepare+0x193/0x2a0
 [<ffffffff8114ef89>] free_compound_page+0x29/0x40
 [<ffffffff81154bbf>] __put_compound_page+0x1f/0x30
 [<ffffffff81154c55>] put_compound_page+0x55/0x200
 [<ffffffff8115534f>] release_pages+0x1cf/0x1e0
 [<ffffffff81183b5d>] free_pages_and_swap_cache+0xad/0xd0
 [<ffffffff8116d72c>] tlb_flush_mmu.part.69+0x4c/0x90
 [<ffffffff8116dd75>] tlb_finish_mmu+0x55/0x60
 [<ffffffff81178730>] exit_mmap+0xf0/0x170
 [<ffffffff810472df>] mmput+0x6f/0x100
 [<ffffffff8104f30c>] do_exit+0x27c/0xcd0
 [<ffffffff816ec5ec>] ? _raw_spin_unlock_irq+0x2c/0x60
 [<ffffffff8105114c>] do_group_exit+0x4c/0xc0
 [<ffffffff810636f1>] get_signal_to_deliver+0x2e1/0x940
 [<ffffffff81002418>] do_signal+0x48/0x5a0
 [<ffffffff810b437e>] ? put_lock_stats.isra.29+0xe/0x40
 [<ffffffff8108ce2d>] ? get_parent_ip+0xd/0x50
 [<ffffffff81145325>] ? user_exit+0x45/0x90
 [<ffffffff810b72dd>] ? trace_hardirqs_on_caller+0xfd/0x1c0
 [<ffffffff810029e8>] do_notify_resume+0x78/0x90
 [<ffffffff816f538a>] int_signal+0x12/0x17
Code: 49 c1 e9 09 48 89 44 24 08 49 83 f1 01 41 83 e1 01 e8 5f dd ff ff 65 48 8b 04 25 00 ba 00 00 c7 80 7c 07 00 00 00 00 00 00 53 9d <48> 83 c4 30 5b 41 5c 41 5d 41 5e 41 5f 5d c3 0f 1f 00 65 48 8b 
BUG: soft lockup - CPU#1 stuck for 23s! [trinity-child2:9278]
Modules linked in: 8021q garp bridge stp fuse tun snd_seq_dummy hidp rfcomm ipt_ULOG nfnetlink can_raw can_bcm llc2 decnet netrom scsi_transport_iscsi pppoe pppox ppp_generic slhc appletalk irda phonet af_802154 bnep af_key ipx p8023 psnap p8022 llc rose can af_rxrpc caif_socket caif nfc crc_ccitt atm ax25 bluetooth rfkill x25 rds coretemp hwmon kvm_intel snd_hda_codec_realtek kvm crc32c_intel ghash_clmulni_intel snd_hda_codec_hdmi microcode pcspkr snd_hda_intel snd_hda_codec snd_hwdep snd_seq snd_seq_device e1000e usb_debug snd_pcm snd_page_alloc snd_timer ptp snd pps_core soundcore xfs libcrc32c
irq event stamp: 44507153
hardirqs last  enabled at (44507152): [<ffffffff816ed1e0>] restore_args+0x0/0x30
hardirqs last disabled at (44507153): [<ffffffff816f5cea>] apic_timer_interrupt+0x6a/0x80
softirqs last  enabled at (43774438): [<ffffffff810542d4>] __do_softirq+0x194/0x440
softirqs last disabled at (43774441): [<ffffffff8105473d>] irq_exit+0xcd/0xe0
CPU: 1 PID: 9278 Comm: trinity-child2 Not tainted 3.10.0-rc5+ #13
task: ffff8801684fca40 ti: ffff88018c89c000 task.ti: ffff88018c89c000
RIP: 0010:[<ffffffff816ec5f2>]  [<ffffffff816ec5f2>] _raw_spin_unlock_irq+0x32/0x60
RSP: 0018:ffff880244a03e80  EFLAGS: 00000202
RAX: ffff8801684fca40 RBX: ffffffff816ed1e0 RCX: 0000000000000000
RDX: 0000000000000000 RSI: 0000000000000000 RDI: 0000000000000001
RBP: ffff880244a03e88 R08: 0000000010000103 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000001 R12: ffff880244a03df8
R13: ffffffff816f5cef R14: ffff880244a03e88 R15: ffff88017796a168
FS:  00007fbed31ba740(0000) GS:ffff880244a00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00007f748879c000 CR3: 0000000001c0b000 CR4: 00000000001407e0
DR0: 0000000001717000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000600
Stack:
 ffff8802432ec000 ffff880244a03ef8 ffffffff8105cf7d ffff88018c89dfd8
 ffff88018c89dfd8 ffff88018c89dfd8 ffff88018c89dfd8 ffff880177969d40
 ffff8802023f8428 ffff880219ec34e8 0000000000000001 0000000000000001
Call Trace:
 <IRQ> 
 [<ffffffff8105cf7d>] run_timer_softirq+0x22d/0x390
 [<ffffffff8105423f>] __do_softirq+0xff/0x440
 [<ffffffff8105473d>] irq_exit+0xcd/0xe0
 [<ffffffff816f6b8b>] smp_apic_timer_interrupt+0x6b/0x9b
 [<ffffffff816f5cef>] apic_timer_interrupt+0x6f/0x80
 <EOI> 
 [<ffffffff816ed1e0>] ? retint_restore_args+0xe/0xe
 [<ffffffff816ec5f2>] ? _raw_spin_unlock_irq+0x32/0x60
 [<ffffffff816ec5ec>] ? _raw_spin_unlock_irq+0x2c/0x60
 [<ffffffff81086c95>] finish_task_switch+0x85/0x130
 [<ffffffff81086c57>] ? finish_task_switch+0x47/0x130
 [<ffffffff816ea6e4>] __schedule+0x444/0x9c0
 [<ffffffff816eb0b4>] preempt_schedule+0x44/0x60
 [<ffffffff816ec5b5>] _raw_spin_unlock_irqrestore+0x75/0x80
 [<ffffffff813149be>] debug_check_no_obj_freed+0x14e/0x250
 [<ffffffff810b72dd>] ? trace_hardirqs_on_caller+0xfd/0x1c0
 [<ffffffff8114e9b3>] free_pages_prepare+0x193/0x2a0
 [<ffffffff8114ef89>] free_compound_page+0x29/0x40
 [<ffffffff81154bbf>] __put_compound_page+0x1f/0x30
 [<ffffffff81154c55>] put_compound_page+0x55/0x200
 [<ffffffff8115534f>] release_pages+0x1cf/0x1e0
 [<ffffffff81183b5d>] free_pages_and_swap_cache+0xad/0xd0
 [<ffffffff8116d72c>] tlb_flush_mmu.part.69+0x4c/0x90
 [<ffffffff8116dd75>] tlb_finish_mmu+0x55/0x60
 [<ffffffff81178730>] exit_mmap+0xf0/0x170
 [<ffffffff810472df>] mmput+0x6f/0x100
 [<ffffffff8104f30c>] do_exit+0x27c/0xcd0
 [<ffffffff816ec5ec>] ? _raw_spin_unlock_irq+0x2c/0x60
 [<ffffffff8105114c>] do_group_exit+0x4c/0xc0
 [<ffffffff810636f1>] get_signal_to_deliver+0x2e1/0x940
 [<ffffffff81002418>] do_signal+0x48/0x5a0
 [<ffffffff810b437e>] ? put_lock_stats.isra.29+0xe/0x40
 [<ffffffff8108ce2d>] ? get_parent_ip+0xd/0x50
 [<ffffffff81145325>] ? user_exit+0x45/0x90
 [<ffffffff810b72dd>] ? trace_hardirqs_on_caller+0xfd/0x1c0
 [<ffffffff810029e8>] do_notify_resume+0x78/0x90
 [<ffffffff816f538a>] int_signal+0x12/0x17
Code: 01 00 00 00 48 89 e5 53 48 89 fb 48 8b 55 08 48 8d 7f 18 e8 01 d8 9c ff 48 89 df e8 19 55 c2 ff e8 b4 ad 9c ff fb bf 01 00 00 00 <e8> 29 47 00 00 65 48 8b 04 25 f0 b9 00 00 48 8b 80 38 e0 ff ff 
BUG: soft lockup - CPU#1 stuck for 23s! [trinity-child2:9278]
Modules linked in: 8021q garp bridge stp fuse tun snd_seq_dummy hidp rfcomm ipt_ULOG nfnetlink can_raw can_bcm llc2 decnet netrom scsi_transport_iscsi pppoe pppox ppp_generic slhc appletalk irda phonet af_802154 bnep af_key ipx p8023 psnap p8022 llc rose can af_rxrpc caif_socket caif nfc crc_ccitt atm ax25 bluetooth rfkill x25 rds coretemp hwmon kvm_intel snd_hda_codec_realtek kvm crc32c_intel ghash_clmulni_intel snd_hda_codec_hdmi microcode pcspkr snd_hda_intel snd_hda_codec snd_hwdep snd_seq snd_seq_device e1000e usb_debug snd_pcm snd_page_alloc snd_timer ptp snd pps_core soundcore xfs libcrc32c
irq event stamp: 45673559
hardirqs last  enabled at (45673558): [<ffffffff816ed1e0>] restore_args+0x0/0x30
hardirqs last disabled at (45673559): [<ffffffff816f5cea>] apic_timer_interrupt+0x6a/0x80
softirqs last  enabled at (43774438): [<ffffffff810542d4>] __do_softirq+0x194/0x440
softirqs last disabled at (43774441): [<ffffffff8105473d>] irq_exit+0xcd/0xe0
CPU: 1 PID: 9278 Comm: trinity-child2 Not tainted 3.10.0-rc5+ #13
task: ffff8801684fca40 ti: ffff88018c89c000 task.ti: ffff88018c89c000
RIP: 0010:[<ffffffff810fc506>]  [<ffffffff810fc506>] rcu_lockdep_current_cpu_online+0x66/0xa0
RSP: 0018:ffff880244a03b50  EFLAGS: 00000202
RAX: ffff880244bcdd80 RBX: ffffffff816ed1e0 RCX: 0000000000000001
RDX: 000000000000000f RSI: 0000000010000104 RDI: 0000000000000001
RBP: ffff880244a03b58 R08: 0000000010000104 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000001 R12: ffff880244a03ac8
R13: ffffffff816f5cef R14: ffff880244a03b58 R15: ffffffffa01b287d
FS:  00007fbed31ba740(0000) GS:ffff880244a00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00007f748879c000 CR3: 0000000001c0b000 CR4: 00000000001407e0
DR0: 0000000001717000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000600
Stack:
 ffffffffa01e0568 ffff880244a03b80 ffffffff810c4de5 ffffffffa01e0568
 ffffffffa01b287d ffff880244a03fc0 ffff880244a03b98 ffffffff810c4e52
 ffffffffa01b287d ffff880244a03bb0 ffffffff810c96cf ffffffffa01b287d
Call Trace:
 <IRQ> 
 [<ffffffff810c4de5>] __module_address+0xd5/0x130
 [<ffffffffa01b287d>] ? e1000e_poll+0x6d/0x310 [e1000e]
 [<ffffffff810c4e52>] __module_text_address+0x12/0x60
 [<ffffffffa01b287d>] ? e1000e_poll+0x6d/0x310 [e1000e]
 [<ffffffff810c96cf>] is_module_text_address+0x1f/0x60
 [<ffffffffa01b287d>] ? e1000e_poll+0x6d/0x310 [e1000e]
 [<ffffffff81077658>] __kernel_text_address+0x58/0x80
 [<ffffffffa01b287d>] ? e1000e_poll+0x6d/0x310 [e1000e]
 [<ffffffff81005dff>] print_context_stack+0x8f/0x100
 [<ffffffff81004abd>] dump_trace+0x12d/0x2f0
 [<ffffffff810b7287>] ? trace_hardirqs_on_caller+0xa7/0x1c0
 [<ffffffff810105cb>] save_stack_trace+0x2b/0x50
 [<ffffffff81320289>] dma_entry_alloc+0x59/0x90
 [<ffffffff81320981>] debug_dma_map_page+0x91/0x140
 [<ffffffffa01ad01b>] e1000_alloc_rx_buffers+0x1ab/0x2c0 [e1000e]
 [<ffffffffa01aa7b6>] e1000_clean_rx_irq+0x2a6/0x440 [e1000e]
 [<ffffffffa01b287d>] e1000e_poll+0x6d/0x310 [e1000e]
 [<ffffffff815adf9a>] net_rx_action+0x16a/0x370
 [<ffffffff8105423f>] __do_softirq+0xff/0x440
 [<ffffffff8105473d>] irq_exit+0xcd/0xe0
 [<ffffffff816f6b8b>] smp_apic_timer_interrupt+0x6b/0x9b
 [<ffffffff816f5cef>] apic_timer_interrupt+0x6f/0x80
 <EOI> 
 [<ffffffff816ed1e0>] ? retint_restore_args+0xe/0xe
 [<ffffffff816ec5f2>] ? _raw_spin_unlock_irq+0x32/0x60
 [<ffffffff816ec5ec>] ? _raw_spin_unlock_irq+0x2c/0x60
 [<ffffffff81086c95>] finish_task_switch+0x85/0x130
 [<ffffffff81086c57>] ? finish_task_switch+0x47/0x130
 [<ffffffff816ea6e4>] __schedule+0x444/0x9c0
 [<ffffffff816eb0b4>] preempt_schedule+0x44/0x60
 [<ffffffff816ec5b5>] _raw_spin_unlock_irqrestore+0x75/0x80
 [<ffffffff813149be>] debug_check_no_obj_freed+0x14e/0x250
 [<ffffffff810b72dd>] ? trace_hardirqs_on_caller+0xfd/0x1c0
 [<ffffffff8114e9b3>] free_pages_prepare+0x193/0x2a0
 [<ffffffff8114ef89>] free_compound_page+0x29/0x40
 [<ffffffff81154bbf>] __put_compound_page+0x1f/0x30
 [<ffffffff81154c55>] put_compound_page+0x55/0x200
 [<ffffffff8115534f>] release_pages+0x1cf/0x1e0
 [<ffffffff81183b5d>] free_pages_and_swap_cache+0xad/0xd0
 [<ffffffff8116d72c>] tlb_flush_mmu.part.69+0x4c/0x90
 [<ffffffff8116dd75>] tlb_finish_mmu+0x55/0x60
 [<ffffffff81178730>] exit_mmap+0xf0/0x170
 [<ffffffff810472df>] mmput+0x6f/0x100
 [<ffffffff8104f30c>] do_exit+0x27c/0xcd0
 [<ffffffff816ec5ec>] ? _raw_spin_unlock_irq+0x2c/0x60
 [<ffffffff8105114c>] do_group_exit+0x4c/0xc0
 [<ffffffff810636f1>] get_signal_to_deliver+0x2e1/0x940
 [<ffffffff81002418>] do_signal+0x48/0x5a0
 [<ffffffff810b437e>] ? put_lock_stats.isra.29+0xe/0x40
 [<ffffffff8108ce2d>] ? get_parent_ip+0xd/0x50
 [<ffffffff81145325>] ? user_exit+0x45/0x90
 [<ffffffff810b72dd>] ? trace_hardirqs_on_caller+0xfd/0x1c0
 [<ffffffff810029e8>] do_notify_resume+0x78/0x90
 [<ffffffff816f538a>] int_signal+0x12/0x17
Code: 01 6f 21 00 48 c7 c3 80 dd 1c 00 89 c0 48 03 1c c5 80 50 cf 81 48 8b 53 18 48 89 d8 bb 01 00 00 00 48 8b 52 68 48 85 50 20 74 2a <bf> 01 00 00 00 e8 10 48 5f 00 65 48 8b 04 25 f0 b9 00 00 48 8b 
BUG: soft lockup - CPU#0 stuck for 22s! [trinity-child2:9278]
Modules linked in: 8021q garp bridge stp fuse tun snd_seq_dummy hidp rfcomm ipt_ULOG nfnetlink can_raw can_bcm llc2 decnet netrom scsi_transport_iscsi pppoe pppox ppp_generic slhc appletalk irda phonet af_802154 bnep af_key ipx p8023 psnap p8022 llc rose can af_rxrpc caif_socket caif nfc crc_ccitt atm ax25 bluetooth rfkill x25 rds coretemp hwmon kvm_intel snd_hda_codec_realtek kvm crc32c_intel ghash_clmulni_intel snd_hda_codec_hdmi microcode pcspkr snd_hda_intel snd_hda_codec snd_hwdep snd_seq snd_seq_device e1000e usb_debug snd_pcm snd_page_alloc snd_timer ptp snd pps_core soundcore xfs libcrc32c
irq event stamp: 47896723
hardirqs last  enabled at (47896722): [<ffffffff816ed1e0>] restore_args+0x0/0x30
hardirqs last disabled at (47896723): [<ffffffff816f5cea>] apic_timer_interrupt+0x6a/0x80
softirqs last  enabled at (46750802): [<ffffffff810542d4>] __do_softirq+0x194/0x440
softirqs last disabled at (46750805): [<ffffffff8105473d>] irq_exit+0xcd/0xe0
CPU: 0 PID: 9278 Comm: trinity-child2 Not tainted 3.10.0-rc5+ #13
task: ffff8801684fca40 ti: ffff88018c89c000 task.ti: ffff88018c89c000
RIP: 0010:[<ffffffff816ec5f2>]  [<ffffffff816ec5f2>] _raw_spin_unlock_irq+0x32/0x60
RSP: 0018:ffff880244803e80  EFLAGS: 00000202
RAX: ffff8801684fca40 RBX: ffffffff816ed1e0 RCX: 0000000000000000
RDX: 0000000000000000 RSI: 0000000000000000 RDI: 0000000000000001
RBP: ffff880244803e88 R08: 0000000000000102 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000001 R12: ffff880244803df8
R13: ffffffff816f5cef R14: ffff880244803e88 R15: ffff8801ddd54868
FS:  00007fbed31ba740(0000) GS:ffff880244800000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00007f748879c000 CR3: 000000023cbdd000 CR4: 00000000001407f0
DR0: 0000000001717000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000600
Stack:
 ffffffff820fe240 ffff880244803ef8 ffffffff8105cf7d ffff88018c89dfd8
 ffff88018c89dfd8 ffff88018c89dfd8 ffff88018c89dfd8 ffff8801ddd54440
 ffff88022a4c34e8 ffff88016872f928 0000000000000001 0000000000000001
Call Trace:
 <IRQ> 
 [<ffffffff8105cf7d>] run_timer_softirq+0x22d/0x390
 [<ffffffff8105423f>] __do_softirq+0xff/0x440
 [<ffffffff8105473d>] irq_exit+0xcd/0xe0
 [<ffffffff816f6b8b>] smp_apic_timer_interrupt+0x6b/0x9b
 [<ffffffff816f5cef>] apic_timer_interrupt+0x6f/0x80
 <EOI> 
 [<ffffffff816ed1e0>] ? retint_restore_args+0xe/0xe
 [<ffffffff816ec5a7>] ? _raw_spin_unlock_irqrestore+0x67/0x80
 [<ffffffff813149be>] debug_check_no_obj_freed+0x14e/0x250
 [<ffffffff810b72dd>] ? trace_hardirqs_on_caller+0xfd/0x1c0
 [<ffffffff8114e9b3>] free_pages_prepare+0x193/0x2a0
 [<ffffffff8114ef89>] free_compound_page+0x29/0x40
 [<ffffffff81154bbf>] __put_compound_page+0x1f/0x30
 [<ffffffff81154c55>] put_compound_page+0x55/0x200
 [<ffffffff8115534f>] release_pages+0x1cf/0x1e0
 [<ffffffff81183b5d>] free_pages_and_swap_cache+0xad/0xd0
 [<ffffffff8116d72c>] tlb_flush_mmu.part.69+0x4c/0x90
 [<ffffffff8116dd75>] tlb_finish_mmu+0x55/0x60
 [<ffffffff81178730>] exit_mmap+0xf0/0x170
 [<ffffffff810472df>] mmput+0x6f/0x100
 [<ffffffff8104f30c>] do_exit+0x27c/0xcd0
 [<ffffffff816ec5ec>] ? _raw_spin_unlock_irq+0x2c/0x60
 [<ffffffff8105114c>] do_group_exit+0x4c/0xc0
 [<ffffffff810636f1>] get_signal_to_deliver+0x2e1/0x940
 [<ffffffff81002418>] do_signal+0x48/0x5a0
 [<ffffffff810b437e>] ? put_lock_stats.isra.29+0xe/0x40
 [<ffffffff8108ce2d>] ? get_parent_ip+0xd/0x50
 [<ffffffff81145325>] ? user_exit+0x45/0x90
 [<ffffffff810b72dd>] ? trace_hardirqs_on_caller+0xfd/0x1c0
 [<ffffffff810029e8>] do_notify_resume+0x78/0x90
 [<ffffffff816f538a>] int_signal+0x12/0x17
Code: 01 00 00 00 48 89 e5 53 48 89 fb 48 8b 55 08 48 8d 7f 18 e8 01 d8 9c ff 48 89 df e8 19 55 c2 ff e8 b4 ad 9c ff fb bf 01 00 00 00 <e8> 29 47 00 00 65 48 8b 04 25 f0 b9 00 00 48 8b 80 38 e0 ff ff 
BUG: soft lockup - CPU#0 stuck for 22s! [trinity-child2:9278]
Modules linked in: 8021q garp bridge stp fuse tun snd_seq_dummy hidp rfcomm ipt_ULOG nfnetlink can_raw can_bcm llc2 decnet netrom scsi_transport_iscsi pppoe pppox ppp_generic slhc appletalk irda phonet af_802154 bnep af_key ipx p8023 psnap p8022 llc rose can af_rxrpc caif_socket caif nfc crc_ccitt atm ax25 bluetooth rfkill x25 rds coretemp hwmon kvm_intel snd_hda_codec_realtek kvm crc32c_intel ghash_clmulni_intel snd_hda_codec_hdmi microcode pcspkr snd_hda_intel snd_hda_codec snd_hwdep snd_seq snd_seq_device e1000e usb_debug snd_pcm snd_page_alloc snd_timer ptp snd pps_core soundcore xfs libcrc32c
irq event stamp: 49079765
hardirqs last  enabled at (49079764): [<ffffffff816ed1e0>] restore_args+0x0/0x30
hardirqs last disabled at (49079765): [<ffffffff816f5cea>] apic_timer_interrupt+0x6a/0x80
softirqs last  enabled at (48511516): [<ffffffff810542d4>] __do_softirq+0x194/0x440
softirqs last disabled at (48511519): [<ffffffff8105473d>] irq_exit+0xcd/0xe0
CPU: 0 PID: 9278 Comm: trinity-child2 Not tainted 3.10.0-rc5+ #13
task: ffff8801684fca40 ti: ffff88018c89c000 task.ti: ffff88018c89c000
RIP: 0010:[<ffffffff816ec5f2>]  [<ffffffff816ec5f2>] _raw_spin_unlock_irq+0x32/0x60
RSP: 0018:ffff880244803e80  EFLAGS: 00000206
RAX: ffff8801684fca40 RBX: ffffffff816ed1e0 RCX: 0000000000000000
RDX: 0000000000000000 RSI: 0000000000000000 RDI: 0000000000000001
RBP: ffff880244803e88 R08: 0000000000000102 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000001 R12: ffff880244803df8
R13: ffffffff816f5cef R14: ffff880244803e88 R15: ffff880184d8d228
FS:  00007fbed31ba740(0000) GS:ffff880244800000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00007f748879c000 CR3: 000000023cbdd000 CR4: 00000000001407f0
DR0: 0000000001717000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000600
Stack:
 ffffffff820fe240 ffff880244803ef8 ffffffff8105cf7d ffff88018c89dfd8
 ffff88018c89dfd8 ffff88018c89dfd8 ffff88018c89dfd8 ffff880184d8ce00
 ffff8801ddd53ea8 ffff8801ddd53ea8 0000000000000001 0000000000000001
Call Trace:
 <IRQ> 
 [<ffffffff8105cf7d>] run_timer_softirq+0x22d/0x390
 [<ffffffff8105423f>] __do_softirq+0xff/0x440
 [<ffffffff8105473d>] irq_exit+0xcd/0xe0
 [<ffffffff816f6b8b>] smp_apic_timer_interrupt+0x6b/0x9b
 [<ffffffff816f5cef>] apic_timer_interrupt+0x6f/0x80
 <EOI> 
 [<ffffffff816ed1e0>] ? retint_restore_args+0xe/0xe
 [<ffffffff816ec5a7>] ? _raw_spin_unlock_irqrestore+0x67/0x80
 [<ffffffff813149be>] debug_check_no_obj_freed+0x14e/0x250
 [<ffffffff810b72dd>] ? trace_hardirqs_on_caller+0xfd/0x1c0
 [<ffffffff8114e9b3>] free_pages_prepare+0x193/0x2a0
 [<ffffffff8114ef89>] free_compound_page+0x29/0x40
 [<ffffffff81154bbf>] __put_compound_page+0x1f/0x30
 [<ffffffff81154c55>] put_compound_page+0x55/0x200
 [<ffffffff8115534f>] release_pages+0x1cf/0x1e0
 [<ffffffff81183b5d>] free_pages_and_swap_cache+0xad/0xd0
 [<ffffffff8116d72c>] tlb_flush_mmu.part.69+0x4c/0x90
 [<ffffffff8116dd75>] tlb_finish_mmu+0x55/0x60
 [<ffffffff81178730>] exit_mmap+0xf0/0x170
 [<ffffffff810472df>] mmput+0x6f/0x100
 [<ffffffff8104f30c>] do_exit+0x27c/0xcd0
 [<ffffffff816ec5ec>] ? _raw_spin_unlock_irq+0x2c/0x60
 [<ffffffff8105114c>] do_group_exit+0x4c/0xc0
 [<ffffffff810636f1>] get_signal_to_deliver+0x2e1/0x940
 [<ffffffff81002418>] do_signal+0x48/0x5a0
 [<ffffffff810b437e>] ? put_lock_stats.isra.29+0xe/0x40
 [<ffffffff8108ce2d>] ? get_parent_ip+0xd/0x50
 [<ffffffff81145325>] ? user_exit+0x45/0x90
 [<ffffffff810b72dd>] ? trace_hardirqs_on_caller+0xfd/0x1c0
 [<ffffffff810029e8>] do_notify_resume+0x78/0x90
 [<ffffffff816f538a>] int_signal+0x12/0x17
Code: 01 00 00 00 48 89 e5 53 48 89 fb 48 8b 55 08 48 8d 7f 18 e8 01 d8 9c ff 48 89 df e8 19 55 c2 ff e8 b4 ad 9c ff fb bf 01 00 00 00 <e8> 29 47 00 00 65 48 8b 04 25 f0 b9 00 00 48 8b 80 38 e0 ff ff 
BUG: soft lockup - CPU#1 stuck for 23s! [trinity-child2:9278]
Modules linked in: 8021q garp bridge stp fuse tun snd_seq_dummy hidp rfcomm ipt_ULOG nfnetlink can_raw can_bcm llc2 decnet netrom scsi_transport_iscsi pppoe pppox ppp_generic slhc appletalk irda phonet af_802154 bnep af_key ipx p8023 psnap p8022 llc rose can af_rxrpc caif_socket caif nfc crc_ccitt atm ax25 bluetooth rfkill x25 rds coretemp hwmon kvm_intel snd_hda_codec_realtek kvm crc32c_intel ghash_clmulni_intel snd_hda_codec_hdmi microcode pcspkr snd_hda_intel snd_hda_codec snd_hwdep snd_seq snd_seq_device e1000e usb_debug snd_pcm snd_page_alloc snd_timer ptp snd pps_core soundcore xfs libcrc32c
irq event stamp: 53654177
hardirqs last  enabled at (53654176): [<ffffffff816ed1e0>] restore_args+0x0/0x30
hardirqs last disabled at (53654177): [<ffffffff816f5cea>] apic_timer_interrupt+0x6a/0x80
softirqs last  enabled at (52893084): [<ffffffff810542d4>] __do_softirq+0x194/0x440
softirqs last disabled at (52893087): [<ffffffff8105473d>] irq_exit+0xcd/0xe0
CPU: 1 PID: 9278 Comm: trinity-child2 Not tainted 3.10.0-rc5+ #13
task: ffff8801684fca40 ti: ffff88018c89c000 task.ti: ffff88018c89c000
RIP: 0010:[<ffffffff816e2b6f>]  [<ffffffff816e2b6f>] __slab_alloc+0x45c/0x507
RSP: 0018:ffff880244a03af8  EFLAGS: 00000292
RAX: ffff8801684fca40 RBX: ffffffff816ed1e0 RCX: 0000000000000000
RDX: 0000000000000000 RSI: 0000000000000000 RDI: ffff8801684fca40
RBP: ffff880244a03bc0 R08: 0000000000000001 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000001 R12: ffff880244a03a68
R13: ffffffff816f5cef R14: ffff880244a03bc0 R15: ffff88024085c300
FS:  00007fbed31ba740(0000) GS:ffff880244a00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00007f748879c000 CR3: 0000000001c0b000 CR4: 00000000001407e0
DR0: 0000000001717000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000600
Stack:
 ffffffff8100a384 0000000000000006 ffff880244a03b30 ffffffff81091985
 0000000000000006 0000000000000000 ffff88024085c300 00000002ffffffff
 ffffffff8158736a 0000002000000000 0000000000000292 ffffffff81091985
Call Trace:
 <IRQ> 
 [<ffffffff8100a384>] ? native_sched_clock+0x24/0x80
 [<ffffffff81091985>] ? sched_clock_cpu+0xb5/0x100
 [<ffffffff8158736a>] ? alloc_iova_mem+0x1a/0x20
 [<ffffffff81091985>] ? sched_clock_cpu+0xb5/0x100
 [<ffffffff8119ce87>] kmem_cache_alloc+0x257/0x320
 [<ffffffff8158736a>] ? alloc_iova_mem+0x1a/0x20
 [<ffffffff8158736a>] alloc_iova_mem+0x1a/0x20
 [<ffffffff8158401e>] alloc_iova+0x2e/0x250
 [<ffffffff81091985>] ? sched_clock_cpu+0xb5/0x100
 [<ffffffff815861c5>] intel_alloc_iova+0x95/0xd0
 [<ffffffff8158888b>] __intel_map_single+0x9b/0x1a0
 [<ffffffff81588990>] ? __intel_map_single+0x1a0/0x1a0
 [<ffffffff815889c3>] intel_map_page+0x33/0x40
 [<ffffffffa01acfd7>] e1000_alloc_rx_buffers+0x167/0x2c0 [e1000e]
 [<ffffffffa01aa80f>] e1000_clean_rx_irq+0x2ff/0x440 [e1000e]
 [<ffffffffa01b287d>] e1000e_poll+0x6d/0x310 [e1000e]
 [<ffffffff815adf9a>] net_rx_action+0x16a/0x370
 [<ffffffff8105423f>] __do_softirq+0xff/0x440
 [<ffffffff8105473d>] irq_exit+0xcd/0xe0
 [<ffffffff816f6b8b>] smp_apic_timer_interrupt+0x6b/0x9b
 [<ffffffff816f5cef>] apic_timer_interrupt+0x6f/0x80
 <EOI> 
 [<ffffffff816ed1e0>] ? retint_restore_args+0xe/0xe
 [<ffffffff816ea2a0>] ? wait_for_completion_interruptible+0x180/0x180
 [<ffffffff816eb2c3>] ? preempt_schedule_irq+0x53/0x90
 [<ffffffff816ed2f6>] retint_kernel+0x26/0x30
 [<ffffffff81074621>] ? task_work_run+0x91/0xe0
 [<ffffffff811e11c8>] ? exit_fs+0x78/0x90
 [<ffffffff8104f343>] do_exit+0x2b3/0xcd0
 [<ffffffff816ec5ec>] ? _raw_spin_unlock_irq+0x2c/0x60
 [<ffffffff8105114c>] do_group_exit+0x4c/0xc0
 [<ffffffff810636f1>] get_signal_to_deliver+0x2e1/0x940
 [<ffffffff81002418>] do_signal+0x48/0x5a0
 [<ffffffff810b437e>] ? put_lock_stats.isra.29+0xe/0x40
 [<ffffffff8108ce2d>] ? get_parent_ip+0xd/0x50
 [<ffffffff81145325>] ? user_exit+0x45/0x90
 [<ffffffff810b72dd>] ? trace_hardirqs_on_caller+0xfd/0x1c0
 [<ffffffff810029e8>] do_notify_resume+0x78/0x90
 [<ffffffff816f538a>] int_signal+0x12/0x17
Code: 24 50 00 02 00 00 49 c7 07 00 00 00 00 75 12 ff 74 24 50 9d e8 93 10 9d ff 4c 89 e0 e9 a6 00 00 00 e8 36 48 9d ff ff 74 24 50 9d <4c> 89 e0 e9 94 00 00 00 8b 74 24 4c 48 89 df e8 aa f1 ff ff 84 
BUG: soft lockup - CPU#1 stuck for 22s! [trinity-child2:9278]
Modules linked in: 8021q garp bridge stp fuse tun snd_seq_dummy hidp rfcomm ipt_ULOG nfnetlink can_raw can_bcm llc2 decnet netrom scsi_transport_iscsi pppoe pppox ppp_generic slhc appletalk irda phonet af_802154 bnep af_key ipx p8023 psnap p8022 llc rose can af_rxrpc caif_socket caif nfc crc_ccitt atm ax25 bluetooth rfkill x25 rds coretemp hwmon kvm_intel snd_hda_codec_realtek kvm crc32c_intel ghash_clmulni_intel snd_hda_codec_hdmi microcode pcspkr snd_hda_intel snd_hda_codec snd_hwdep snd_seq snd_seq_device e1000e usb_debug snd_pcm snd_page_alloc snd_timer ptp snd pps_core soundcore xfs libcrc32c
irq event stamp: 57087367
hardirqs last  enabled at (57087366): [<ffffffff816ed1e0>] restore_args+0x0/0x30
hardirqs last disabled at (57087367): [<ffffffff816f5cea>] apic_timer_interrupt+0x6a/0x80
softirqs last  enabled at (55972350): [<ffffffff810542d4>] __do_softirq+0x194/0x440
softirqs last disabled at (55972773): [<ffffffff8105473d>] irq_exit+0xcd/0xe0
CPU: 1 PID: 9278 Comm: trinity-child2 Not tainted 3.10.0-rc5+ #13
task: ffff8801684fca40 ti: ffff88018c89c000 task.ti: ffff88018c89c000
RIP: 0010:[<ffffffff816ec5f2>]  [<ffffffff816ec5f2>] _raw_spin_unlock_irq+0x32/0x60
RSP: 0018:ffff880244a03e80  EFLAGS: 00000216
RAX: ffff8801684fca40 RBX: ffffffff816ed1e0 RCX: 0000000000000000
RDX: 0000000000000000 RSI: 0000000000000000 RDI: 0000000000000001
RBP: ffff880244a03e88 R08: 0000000000000101 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000001 R12: ffff880244a03df8
R13: ffffffff816f5cef R14: ffff880244a03e88 R15: ffff88022a4c5228
FS:  00007fbed31ba740(0000) GS:ffff880244a00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00007f748879c000 CR3: 0000000001c0b000 CR4: 00000000001407e0
DR0: 0000000001717000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000600
Stack:
 ffff8802432ec000 ffff880244a03ef8 ffffffff8105cf7d ffff88018c89dfd8
 ffff88018c89dfd8 ffff88018c89dfd8 ffff88018c89dfd8 ffff88022a4c4e00
 ffff88022a4c2168 ffff88020236d228 0000000000000001 0000000000000001
Call Trace:
 <IRQ> 
 [<ffffffff8105cf7d>] run_timer_softirq+0x22d/0x390
 [<ffffffff8105423f>] __do_softirq+0xff/0x440
 [<ffffffff8105473d>] irq_exit+0xcd/0xe0
 [<ffffffff816f6b8b>] smp_apic_timer_interrupt+0x6b/0x9b
 [<ffffffff816f5cef>] apic_timer_interrupt+0x6f/0x80
 <EOI> 
 [<ffffffff816ed1e0>] ? retint_restore_args+0xe/0xe
 [<ffffffff816e2b6f>] ? __slab_alloc+0x45c/0x507
 [<ffffffff81313f05>] ? __debug_object_init+0x445/0x460
 [<ffffffff810b72dd>] ? trace_hardirqs_on_caller+0xfd/0x1c0
 [<ffffffff810b73ad>] ? trace_hardirqs_on+0xd/0x10
 [<ffffffff8119ce87>] kmem_cache_alloc+0x257/0x320
 [<ffffffff81313f05>] ? __debug_object_init+0x445/0x460
 [<ffffffff81313f05>] __debug_object_init+0x445/0x460
 [<ffffffff81313f3b>] debug_object_init+0x1b/0x20
 [<ffffffff810762fc>] rcuhead_fixup_activate+0x2c/0xc0
 [<ffffffff81314081>] debug_object_activate+0x121/0x1e0
 [<ffffffff8115d3a0>] ? shmem_destroy_inode+0x40/0x40
 [<ffffffff8110106f>] __call_rcu+0x3f/0x840
 [<ffffffff811f4732>] ? fsnotify_clear_marks_by_inode+0xa2/0x130
 [<ffffffff811018cd>] call_rcu+0x1d/0x20
 [<ffffffff8115d38d>] shmem_destroy_inode+0x2d/0x40
 [<ffffffff811c8918>] destroy_inode+0x38/0x60
 [<ffffffff811c8a4e>] evict+0x10e/0x1a0
 [<ffffffff811c9375>] iput+0xf5/0x190
 [<ffffffff811c4a08>] dput+0x208/0x2f0
 [<ffffffff811ae6e8>] __fput+0x198/0x2d0
 [<ffffffff811ae8de>] ____fput+0xe/0x10
 [<ffffffff8107463c>] task_work_run+0xac/0xe0
 [<ffffffff8104f343>] do_exit+0x2b3/0xcd0
 [<ffffffff816ec5ec>] ? _raw_spin_unlock_irq+0x2c/0x60
 [<ffffffff8105114c>] do_group_exit+0x4c/0xc0
 [<ffffffff810636f1>] get_signal_to_deliver+0x2e1/0x940
 [<ffffffff81002418>] do_signal+0x48/0x5a0
 [<ffffffff810b437e>] ? put_lock_stats.isra.29+0xe/0x40
 [<ffffffff8108ce2d>] ? get_parent_ip+0xd/0x50
 [<ffffffff81145325>] ? user_exit+0x45/0x90
 [<ffffffff810b72dd>] ? trace_hardirqs_on_caller+0xfd/0x1c0
 [<ffffffff810029e8>] do_notify_resume+0x78/0x90
 [<ffffffff816f538a>] int_signal+0x12/0x17
Code: 01 00 00 00 48 89 e5 53 48 89 fb 48 8b 55 08 48 8d 7f 18 e8 01 d8 9c ff 48 89 df e8 19 55 c2 ff e8 b4 ad 9c ff fb bf 01 00 00 00 <e8> 29 47 00 00 65 48 8b 04 25 f0 b9 00 00 48 8b 80 38 e0 ff ff 
BUG: soft lockup - CPU#1 stuck for 23s! [trinity-child2:9278]
Modules linked in: 8021q garp bridge stp fuse tun snd_seq_dummy hidp rfcomm ipt_ULOG nfnetlink can_raw can_bcm llc2 decnet netrom scsi_transport_iscsi pppoe pppox ppp_generic slhc appletalk irda phonet af_802154 bnep af_key ipx p8023 psnap p8022 llc rose can af_rxrpc caif_socket caif nfc crc_ccitt atm ax25 bluetooth rfkill x25 rds coretemp hwmon kvm_intel snd_hda_codec_realtek kvm crc32c_intel ghash_clmulni_intel snd_hda_codec_hdmi microcode pcspkr snd_hda_intel snd_hda_codec snd_hwdep snd_seq snd_seq_device e1000e usb_debug snd_pcm snd_page_alloc snd_timer ptp snd pps_core soundcore xfs libcrc32c
irq event stamp: 60135409
hardirqs last  enabled at (60135408): [<ffffffff816ed1e0>] restore_args+0x0/0x30
hardirqs last disabled at (60135409): [<ffffffff816f5cea>] apic_timer_interrupt+0x6a/0x80
softirqs last  enabled at (59184328): [<ffffffff810542d4>] __do_softirq+0x194/0x440
softirqs last disabled at (59184331): [<ffffffff8105473d>] irq_exit+0xcd/0xe0
CPU: 1 PID: 9278 Comm: trinity-child2 Not tainted 3.10.0-rc5+ #13
task: ffff8801684fca40 ti: ffff88018c89c000 task.ti: ffff88018c89c000
RIP: 0010:[<ffffffff816e2b6f>]  [<ffffffff816e2b6f>] __slab_alloc+0x45c/0x507
RSP: 0018:ffff880244a03af8  EFLAGS: 00000292
RAX: ffff8801684fca40 RBX: ffffffff816ed1e0 RCX: 0000000000000000
RDX: 0000000000000000 RSI: 0000000000000000 RDI: ffff8801684fca40
RBP: ffff880244a03bc0 R08: 0000000000000001 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000001 R12: ffff880244a03a68
R13: ffffffff816f5cef R14: ffff880244a03bc0 R15: ffff880234e8a000
FS:  00007fbed31ba740(0000) GS:ffff880244a00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00000000020ad8b8 CR3: 0000000001c0b000 CR4: 00000000001407e0
DR0: 0000000001717000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000600
Stack:
 ffffffff8100a384 0000000000000006 ffff880244a03b30 ffffffff81091985
 0000000000000006 0000000000000000 ffff880234e8a000 00000002ffffffff
 ffffffff8158736a 0000002000000000 0000000000000292 ffffffff81091985
Call Trace:
 <IRQ> 
 [<ffffffff8100a384>] ? native_sched_clock+0x24/0x80
 [<ffffffff81091985>] ? sched_clock_cpu+0xb5/0x100
 [<ffffffff8158736a>] ? alloc_iova_mem+0x1a/0x20
 [<ffffffff81091985>] ? sched_clock_cpu+0xb5/0x100
 [<ffffffff8119ce87>] kmem_cache_alloc+0x257/0x320
 [<ffffffff8158736a>] ? alloc_iova_mem+0x1a/0x20
 [<ffffffff8158736a>] alloc_iova_mem+0x1a/0x20
 [<ffffffff8158401e>] alloc_iova+0x2e/0x250
 [<ffffffff81091985>] ? sched_clock_cpu+0xb5/0x100
 [<ffffffff815861c5>] intel_alloc_iova+0x95/0xd0
 [<ffffffff8158888b>] __intel_map_single+0x9b/0x1a0
 [<ffffffff81588990>] ? __intel_map_single+0x1a0/0x1a0
 [<ffffffff815889c3>] intel_map_page+0x33/0x40
 [<ffffffffa01acfd7>] e1000_alloc_rx_buffers+0x167/0x2c0 [e1000e]
 [<ffffffffa01aa80f>] e1000_clean_rx_irq+0x2ff/0x440 [e1000e]
 [<ffffffffa01b287d>] e1000e_poll+0x6d/0x310 [e1000e]
 [<ffffffff815adf9a>] net_rx_action+0x16a/0x370
 [<ffffffff811f4732>] ? fsnotify_clear_marks_by_inode+0xa2/0x130
 [<ffffffff8105423f>] __do_softirq+0xff/0x440
 [<ffffffff811f4732>] ? fsnotify_clear_marks_by_inode+0xa2/0x130
 [<ffffffff8105473d>] irq_exit+0xcd/0xe0
 [<ffffffff816f6b8b>] smp_apic_timer_interrupt+0x6b/0x9b
 [<ffffffff816f5cef>] apic_timer_interrupt+0x6f/0x80
 <EOI> 
 [<ffffffff816ed1e0>] ? retint_restore_args+0xe/0xe
 [<ffffffff810b9e90>] ? lock_release+0xb0/0x320
 [<ffffffff816ec4bf>] _raw_spin_unlock+0x1f/0x60
 [<ffffffff811f4732>] fsnotify_clear_marks_by_inode+0xa2/0x130
 [<ffffffff811f2f7e>] __fsnotify_inode_delete+0xe/0x10
 [<ffffffff811c881a>] __destroy_inode+0x2a/0xf0
 [<ffffffff811c8902>] destroy_inode+0x22/0x60
 [<ffffffff811c8a4e>] evict+0x10e/0x1a0
 [<ffffffff811c9375>] iput+0xf5/0x190
 [<ffffffff811c4a08>] dput+0x208/0x2f0
 [<ffffffff811ae6e8>] __fput+0x198/0x2d0
 [<ffffffff811ae8de>] ____fput+0xe/0x10
 [<ffffffff8107463c>] task_work_run+0xac/0xe0
 [<ffffffff8104f343>] do_exit+0x2b3/0xcd0
 [<ffffffff816ec5ec>] ? _raw_spin_unlock_irq+0x2c/0x60
 [<ffffffff8105114c>] do_group_exit+0x4c/0xc0
 [<ffffffff810636f1>] get_signal_to_deliver+0x2e1/0x940
 [<ffffffff81002418>] do_signal+0x48/0x5a0
 [<ffffffff810b437e>] ? put_lock_stats.isra.29+0xe/0x40
 [<ffffffff8108ce2d>] ? get_parent_ip+0xd/0x50
 [<ffffffff81145325>] ? user_exit+0x45/0x90
 [<ffffffff810b72dd>] ? trace_hardirqs_on_caller+0xfd/0x1c0
 [<ffffffff810029e8>] do_notify_resume+0x78/0x90
 [<ffffffff816f538a>] int_signal+0x12/0x17
Code: 24 50 00 02 00 00 49 c7 07 00 00 00 00 75 12 ff 74 24 50 9d e8 93 10 9d ff 4c 89 e0 e9 a6 00 00 00 e8 36 48 9d ff ff 74 24 50 9d <4c> 89 e0 e9 94 00 00 00 8b 74 24 4c 48 89 df e8 aa f1 ff ff 84 
BUG: soft lockup - CPU#0 stuck for 22s! [trinity-child2:9278]
Modules linked in: 8021q garp bridge stp fuse tun snd_seq_dummy hidp rfcomm ipt_ULOG nfnetlink can_raw can_bcm llc2 decnet netrom scsi_transport_iscsi pppoe pppox ppp_generic slhc appletalk irda phonet af_802154 bnep af_key ipx p8023 psnap p8022 llc rose can af_rxrpc caif_socket caif nfc crc_ccitt atm ax25 bluetooth rfkill x25 rds coretemp hwmon kvm_intel snd_hda_codec_realtek kvm crc32c_intel ghash_clmulni_intel snd_hda_codec_hdmi microcode pcspkr snd_hda_intel snd_hda_codec snd_hwdep snd_seq snd_seq_device e1000e usb_debug snd_pcm snd_page_alloc snd_timer ptp snd pps_core soundcore xfs libcrc32c
irq event stamp: 66190657
hardirqs last  enabled at (66190656): [<ffffffff816ed1e0>] restore_args+0x0/0x30
hardirqs last disabled at (66190657): [<ffffffff816f5cea>] apic_timer_interrupt+0x6a/0x80
softirqs last  enabled at (65542138): [<ffffffff810542d4>] __do_softirq+0x194/0x440
softirqs last disabled at (65542141): [<ffffffff8105473d>] irq_exit+0xcd/0xe0
CPU: 0 PID: 9278 Comm: trinity-child2 Not tainted 3.10.0-rc5+ #13
task: ffff8801684fca40 ti: ffff88018c89c000 task.ti: ffff88018c89c000
RIP: 0010:[<ffffffff816ec5a7>]  [<ffffffff816ec5a7>] _raw_spin_unlock_irqrestore+0x67/0x80
RSP: 0018:ffff880244803d90  EFLAGS: 00000286
RAX: ffff8801684fca40 RBX: ffffffff816ed1e0 RCX: 0000000000000002
RDX: 0000000000004340 RSI: ffff8801684fd1f8 RDI: ffff8801684fca40
RBP: ffff880244803da0 R08: 0000000000000103 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000001 R12: ffff880244803d08
R13: ffffffff816f5cef R14: ffff880244803da0 R15: ffffffff820fe240
FS:  00007fbed31ba740(0000) GS:ffff880244800000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00007f748879c000 CR3: 0000000001c0b000 CR4: 00000000001407f0
DR0: 0000000001717000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000600
Stack:
 ffff8801f23b0428 ffffffff820fe240 ffff880244803de0 ffffffff8105dc39
 0000000000000286 ffff8801f23b0000 ffff8801f23b0050 0000000000000101
 ffffffffa04c21d0 ffff8801f23b0000 ffff880244803df8 ffffffff81594a88
Call Trace:
 <IRQ> 
 [<ffffffff8105dc39>] mod_timer+0x119/0x320
 [<ffffffffa04c21d0>] ? dn_neigh_elist+0x40/0x40 [decnet]
 [<ffffffff81594a88>] sk_reset_timer+0x18/0x30
 [<ffffffffa04c224c>] dn_slow_timer+0x7c/0x110 [decnet]
 [<ffffffff8105ca6a>] call_timer_fn+0x8a/0x370
 [<ffffffff8105c9e5>] ? call_timer_fn+0x5/0x370
 [<ffffffffa04c21d0>] ? dn_neigh_elist+0x40/0x40 [decnet]
 [<ffffffff8105cf8c>] run_timer_softirq+0x23c/0x390
 [<ffffffff8105423f>] __do_softirq+0xff/0x440
 [<ffffffff8105473d>] irq_exit+0xcd/0xe0
 [<ffffffff816f6b8b>] smp_apic_timer_interrupt+0x6b/0x9b
 [<ffffffff816f5cef>] apic_timer_interrupt+0x6f/0x80
 <EOI> 
 [<ffffffff816ed1e0>] ? retint_restore_args+0xe/0xe
 [<ffffffff816ec5a7>] ? _raw_spin_unlock_irqrestore+0x67/0x80
 [<ffffffff8131406a>] debug_object_activate+0x10a/0x1e0
 [<ffffffff811ae4f0>] ? get_max_files+0x20/0x20
 [<ffffffff8110106f>] __call_rcu+0x3f/0x840
 [<ffffffff8108ce2d>] ? get_parent_ip+0xd/0x50
 [<ffffffff816f0d91>] ? sub_preempt_count+0x71/0x100
 [<ffffffff811018cd>] call_rcu+0x1d/0x20
 [<ffffffff811ae6e0>] __fput+0x190/0x2d0
 [<ffffffff811ae8de>] ____fput+0xe/0x10
 [<ffffffff8107463c>] task_work_run+0xac/0xe0
 [<ffffffff8104f343>] do_exit+0x2b3/0xcd0
 [<ffffffff816ec5ec>] ? _raw_spin_unlock_irq+0x2c/0x60
 [<ffffffff8105114c>] do_group_exit+0x4c/0xc0
 [<ffffffff810636f1>] get_signal_to_deliver+0x2e1/0x940
 [<ffffffff81002418>] do_signal+0x48/0x5a0
 [<ffffffff810b437e>] ? put_lock_stats.isra.29+0xe/0x40
 [<ffffffff8108ce2d>] ? get_parent_ip+0xd/0x50
 [<ffffffff81145325>] ? user_exit+0x45/0x90
 [<ffffffff810b72dd>] ? trace_hardirqs_on_caller+0xfd/0x1c0
 [<ffffffff810029e8>] do_notify_resume+0x78/0x90
 [<ffffffff816f538a>] int_signal+0x12/0x17
Code: 00 e8 9e 47 00 00 65 48 8b 04 25 f0 b9 00 00 48 8b 80 38 e0 ff ff a8 08 75 13 5b 41 5c 5d c3 0f 1f 44 00 00 e8 fb ad 9c ff 53 9d <eb> cf 0f 1f 80 00 00 00 00 e8 bb ea ff ff eb df 66 0f 1f 84 00 
BUG: soft lockup - CPU#3 stuck for 23s! [trinity-child2:9278]
Modules linked in: 8021q garp bridge stp fuse tun snd_seq_dummy hidp rfcomm ipt_ULOG nfnetlink can_raw can_bcm llc2 decnet netrom scsi_transport_iscsi pppoe pppox ppp_generic slhc appletalk irda phonet af_802154 bnep af_key ipx p8023 psnap p8022 llc rose can af_rxrpc caif_socket caif nfc crc_ccitt atm ax25 bluetooth rfkill x25 rds coretemp hwmon kvm_intel snd_hda_codec_realtek kvm crc32c_intel ghash_clmulni_intel snd_hda_codec_hdmi microcode pcspkr snd_hda_intel snd_hda_codec snd_hwdep snd_seq snd_seq_device e1000e usb_debug snd_pcm snd_page_alloc snd_timer ptp snd pps_core soundcore xfs libcrc32c
irq event stamp: 69303803
hardirqs last  enabled at (69303802): [<ffffffff816ed1e0>] restore_args+0x0/0x30
hardirqs last disabled at (69303803): [<ffffffff816f5cea>] apic_timer_interrupt+0x6a/0x80
softirqs last  enabled at (67857358): [<ffffffff810542d4>] __do_softirq+0x194/0x440
softirqs last disabled at (67857361): [<ffffffff8105473d>] irq_exit+0xcd/0xe0
CPU: 3 PID: 9278 Comm: trinity-child2 Not tainted 3.10.0-rc5+ #13
task: ffff8801684fca40 ti: ffff88018c89c000 task.ti: ffff88018c89c000
RIP: 0010:[<ffffffff816ec5f2>]  [<ffffffff816ec5f2>] _raw_spin_unlock_irq+0x32/0x60
RSP: 0018:ffff880244e03e80  EFLAGS: 00000206
RAX: ffff8801684fca40 RBX: ffffffff816ed1e0 RCX: 0000000000000000
RDX: 0000000000000000 RSI: 0000000000000000 RDI: 0000000000000001
RBP: ffff880244e03e88 R08: 0000000000000102 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000001 R12: ffff880244e03df8
R13: ffffffff816f5cef R14: ffff880244e03e88 R15: ffff8802417b97a8
FS:  00007fbed31ba740(0000) GS:ffff880244e00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 0000000000e54000 CR3: 0000000182086000 CR4: 00000000001407e0
DR0: 0000000001717000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000600
Stack:
 ffff8802433b0000 ffff880244e03ef8 ffffffff8105cf7d ffff88018c89dfd8
 ffff88018c89dfd8 ffff88018c89dfd8 ffff88018c89dfd8 ffff8802417b9380
 ffff8801ddd55be8 ffff88022a4c3ea8 0000000000000001 0000000000000001
Call Trace:
 <IRQ> 
 [<ffffffff8105cf7d>] run_timer_softirq+0x22d/0x390
 [<ffffffff8105423f>] __do_softirq+0xff/0x440
 [<ffffffff8105473d>] irq_exit+0xcd/0xe0
 [<ffffffff816f6b8b>] smp_apic_timer_interrupt+0x6b/0x9b
 [<ffffffff816f5cef>] apic_timer_interrupt+0x6f/0x80
 <EOI> 
 [<ffffffff816ed1e0>] ? retint_restore_args+0xe/0xe
 [<ffffffff816ec5a7>] ? _raw_spin_unlock_irqrestore+0x67/0x80
 [<ffffffff816e21c9>] __slab_free+0x5f/0x39f
 [<ffffffff816f0d91>] ? sub_preempt_count+0x71/0x100
 [<ffffffff816ec582>] ? _raw_spin_unlock_irqrestore+0x42/0x80
 [<ffffffff813149be>] ? debug_check_no_obj_freed+0x14e/0x250
 [<ffffffff81198d35>] ? kmem_cache_free+0x95/0x300
 [<ffffffff81198f8c>] kmem_cache_free+0x2ec/0x300
 [<ffffffff811c2b42>] ? __d_free+0x42/0x60
 [<ffffffff811c2b42>] __d_free+0x42/0x60
 [<ffffffff811c3185>] d_free+0x55/0x60
 [<ffffffff811c49a0>] dput+0x1a0/0x2f0
 [<ffffffff811ae6e8>] __fput+0x198/0x2d0
 [<ffffffff811ae8de>] ____fput+0xe/0x10
 [<ffffffff8107463c>] task_work_run+0xac/0xe0
 [<ffffffff8104f343>] do_exit+0x2b3/0xcd0
 [<ffffffff816ec5ec>] ? _raw_spin_unlock_irq+0x2c/0x60
 [<ffffffff8105114c>] do_group_exit+0x4c/0xc0
 [<ffffffff810636f1>] get_signal_to_deliver+0x2e1/0x940
 [<ffffffff81002418>] do_signal+0x48/0x5a0
 [<ffffffff810b437e>] ? put_lock_stats.isra.29+0xe/0x40
 [<ffffffff8108ce2d>] ? get_parent_ip+0xd/0x50
 [<ffffffff81145325>] ? user_exit+0x45/0x90
 [<ffffffff810b72dd>] ? trace_hardirqs_on_caller+0xfd/0x1c0
 [<ffffffff810029e8>] do_notify_resume+0x78/0x90
 [<ffffffff816f538a>] int_signal+0x12/0x17
Code: 01 00 00 00 48 89 e5 53 48 89 fb 48 8b 55 08 48 8d 7f 18 e8 01 d8 9c ff 48 89 df e8 19 55 c2 ff e8 b4 ad 9c ff fb bf 01 00 00 00 <e8> 29 47 00 00 65 48 8b 04 25 f0 b9 00 00 48 8b 80 38 e0 ff ff 
BUG: soft lockup - CPU#3 stuck for 22s! [trinity-child3:15395]
Modules linked in: 8021q garp bridge stp fuse tun snd_seq_dummy hidp rfcomm ipt_ULOG nfnetlink can_raw can_bcm llc2 decnet netrom scsi_transport_iscsi pppoe pppox ppp_generic slhc appletalk irda phonet af_802154 bnep af_key ipx p8023 psnap p8022 llc rose can af_rxrpc caif_socket caif nfc crc_ccitt atm ax25 bluetooth rfkill x25 rds coretemp hwmon kvm_intel snd_hda_codec_realtek kvm crc32c_intel ghash_clmulni_intel snd_hda_codec_hdmi microcode pcspkr snd_hda_intel snd_hda_codec snd_hwdep snd_seq snd_seq_device e1000e usb_debug snd_pcm snd_page_alloc snd_timer ptp snd pps_core soundcore xfs libcrc32c
irq event stamp: 37598
hardirqs last  enabled at (37597): [<ffffffff810b25da>] tick_nohz_task_switch+0x2a/0x80
hardirqs last disabled at (37598): [<ffffffff816f5cea>] apic_timer_interrupt+0x6a/0x80
softirqs last  enabled at (37590): [<ffffffff810542d4>] __do_softirq+0x194/0x440
softirqs last disabled at (37567): [<ffffffff8105473d>] irq_exit+0xcd/0xe0
CPU: 3 PID: 15395 Comm: trinity-child3 Not tainted 3.10.0-rc5+ #13
task: ffff8802362a8000 ti: ffff880233ffc000 task.ti: ffff880233ffc000
RIP: 0010:[<ffffffff8130951f>]  [<ffffffff8130951f>] delay_tsc+0x2f/0xe0
RSP: 0018:ffff880233ffdd50  EFLAGS: 00000202
RAX: 000000006d318952 RBX: ffffffff824d4920 RCX: 000000000000b910
RDX: 0000000000006ea1 RSI: ffff880244e00000 RDI: 0000000000000001
RBP: ffff880233ffdd78 R08: 0000000000000001 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000001 R12: ffff88016026ee88
R13: ffff880233ffdd20 R14: ffffffff810b72dd R15: 0000000000000000
FS:  00007fbed31ba740(0000) GS:ffff880244e00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 0000000002c0b228 CR3: 00000001758f7000 CR4: 00000000001407e0
DR0: 0000000001717000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000600
Stack:
 ffffffff81c04640 000000000001e67c 0000000088c7d2c8 ffff88016026ee00
 ffff88016026f010 ffff880233ffdd88 ffffffff8130944f ffff880233ffddb0
 ffffffff81311a61 ffffffff81c04640 ffffffff81c04658 ffff88023c8e4630
Call Trace:
 [<ffffffff8130944f>] __delay+0xf/0x20
 [<ffffffff81311a61>] do_raw_spin_lock+0xe1/0x130
 [<ffffffff816ec160>] _raw_spin_lock+0x60/0x80
 [<ffffffff811da6d8>] ? sync_inodes_sb+0x228/0x2a0
 [<ffffffff811da6d8>] sync_inodes_sb+0x228/0x2a0
 [<ffffffff816e98bf>] ? wait_for_completion+0xdf/0x110
 [<ffffffff8108ce2d>] ? get_parent_ip+0xd/0x50
 [<ffffffff811e0240>] ? generic_write_sync+0x70/0x70
 [<ffffffff811e0259>] sync_inodes_one_sb+0x19/0x20
 [<ffffffff811b0bd2>] iterate_supers+0xb2/0x110
 [<ffffffff811e04c5>] sys_sync+0x35/0x90
 [<ffffffff816f5294>] tracesys+0xdd/0xe2
Code: 00 55 48 89 e5 41 57 41 56 41 55 41 54 41 89 fc bf 01 00 00 00 53 e8 21 77 3e 00 e8 cc 9e 00 00 41 89 c5 0f 1f 00 0f ae e8 0f 31 <65> 4c 8b 3c 25 f0 b9 00 00 89 c3 eb 2f 0f 1f 40 00 bf 01 00 00 
BUG: soft lockup - CPU#3 stuck for 23s! [trinity-child2:9278]
Modules linked in: 8021q garp bridge stp fuse tun snd_seq_dummy hidp rfcomm ipt_ULOG nfnetlink can_raw can_bcm llc2 decnet netrom scsi_transport_iscsi pppoe pppox ppp_generic slhc appletalk irda phonet af_802154 bnep af_key ipx p8023 psnap p8022 llc rose can af_rxrpc caif_socket caif nfc crc_ccitt atm ax25 bluetooth rfkill x25 rds coretemp hwmon kvm_intel snd_hda_codec_realtek kvm crc32c_intel ghash_clmulni_intel snd_hda_codec_hdmi microcode pcspkr snd_hda_intel snd_hda_codec snd_hwdep snd_seq snd_seq_device e1000e usb_debug snd_pcm snd_page_alloc snd_timer ptp snd pps_core soundcore xfs libcrc32c
irq event stamp: 83776047
hardirqs last  enabled at (83776046): [<ffffffff816ed1e0>] restore_args+0x0/0x30
hardirqs last disabled at (83776047): [<ffffffff816f5cea>] apic_timer_interrupt+0x6a/0x80
softirqs last  enabled at (83242260): [<ffffffff810542d4>] __do_softirq+0x194/0x440
softirqs last disabled at (83242263): [<ffffffff8105473d>] irq_exit+0xcd/0xe0
CPU: 3 PID: 9278 Comm: trinity-child2 Not tainted 3.10.0-rc5+ #13
task: ffff8801684fca40 ti: ffff88018c89c000 task.ti: ffff88018c89c000
RIP: 0010:[<ffffffff816ec5f2>]  [<ffffffff816ec5f2>] _raw_spin_unlock_irq+0x32/0x60
RSP: 0018:ffff880244e03e80  EFLAGS: 00000202
RAX: ffff8801684fca40 RBX: ffffffff816ed1e0 RCX: 0000000000000002
RDX: 0000000000004800 RSI: ffff8801684fd1c0 RDI: 0000000000000001
RBP: ffff880244e03e88 R08: 0000000010000103 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000001 R12: ffff880244e03df8
R13: ffffffff816f5cef R14: ffff880244e03e88 R15: ffff88020a54b4e8
FS:  00007fbed31ba740(0000) GS:ffff880244e00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00007fea4f695000 CR3: 0000000001c0b000 CR4: 00000000001407e0
DR0: 0000000001717000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000600
Stack:
 ffff8802433b0000 ffff880244e03ef8 ffffffff8105cf7d ffff88018c89dfd8
 ffff88018c89dfd8 ffff88018c89dfd8 ffff88018c89dfd8 ffff88020a54b0c0
 ffff88022d52d228 ffff880184d8dbe8 0000000000000001 0000000000000001
Call Trace:
 <IRQ> 
 [<ffffffff8105cf7d>] run_timer_softirq+0x22d/0x390
 [<ffffffff8105423f>] __do_softirq+0xff/0x440
 [<ffffffff8105473d>] irq_exit+0xcd/0xe0
 [<ffffffff816f6b8b>] smp_apic_timer_interrupt+0x6b/0x9b
 [<ffffffff816f5cef>] apic_timer_interrupt+0x6f/0x80
 <EOI> 
 [<ffffffff816ed1e0>] ? retint_restore_args+0xe/0xe
 [<ffffffff816ec5f2>] ? _raw_spin_unlock_irq+0x32/0x60
 [<ffffffff816ec5ec>] ? _raw_spin_unlock_irq+0x2c/0x60
 [<ffffffff81086c95>] finish_task_switch+0x85/0x130
 [<ffffffff81086c57>] ? finish_task_switch+0x47/0x130
 [<ffffffff816ea6e4>] __schedule+0x444/0x9c0
 [<ffffffff816eb2c3>] preempt_schedule_irq+0x53/0x90
 [<ffffffffa0465528>] ? atalk_release+0x68/0x1a0 [appletalk]
 [<ffffffff816ed2f6>] retint_kernel+0x26/0x30
 [<ffffffff81052ea2>] ? local_bh_enable_ip+0x82/0xf0
 [<ffffffff81052e98>] ? local_bh_enable_ip+0x78/0xf0
 [<ffffffff816ece7a>] _raw_write_unlock_bh+0x3a/0x40
 [<ffffffffa0465528>] atalk_release+0x68/0x1a0 [appletalk]
 [<ffffffff81590fff>] sock_release+0x1f/0x90
 [<ffffffff81591082>] sock_close+0x12/0x20
 [<ffffffff811ae645>] __fput+0xf5/0x2d0
 [<ffffffff811ae8de>] ____fput+0xe/0x10
 [<ffffffff8107463c>] task_work_run+0xac/0xe0
 [<ffffffff8104f343>] do_exit+0x2b3/0xcd0
 [<ffffffff816ec5ec>] ? _raw_spin_unlock_irq+0x2c/0x60
 [<ffffffff8105114c>] do_group_exit+0x4c/0xc0
 [<ffffffff810636f1>] get_signal_to_deliver+0x2e1/0x940
 [<ffffffff81002418>] do_signal+0x48/0x5a0
 [<ffffffff810b437e>] ? put_lock_stats.isra.29+0xe/0x40
 [<ffffffff8108ce2d>] ? get_parent_ip+0xd/0x50
 [<ffffffff81145325>] ? user_exit+0x45/0x90
 [<ffffffff810b72dd>] ? trace_hardirqs_on_caller+0xfd/0x1c0
 [<ffffffff810029e8>] do_notify_resume+0x78/0x90
 [<ffffffff816f538a>] int_signal+0x12/0x17
Code: 01 00 00 00 48 89 e5 53 48 89 fb 48 8b 55 08 48 8d 7f 18 e8 01 d8 9c ff 48 89 df e8 19 55 c2 ff e8 b4 ad 9c ff fb bf 01 00 00 00 <e8> 29 47 00 00 65 48 8b 04 25 f0 b9 00 00 48 8b 80 38 e0 ff ff 
BUG: soft lockup - CPU#2 stuck for 23s! [trinity-child2:9278]
Modules linked in: 8021q garp bridge stp fuse tun snd_seq_dummy hidp rfcomm ipt_ULOG nfnetlink can_raw can_bcm llc2 decnet netrom scsi_transport_iscsi pppoe pppox ppp_generic slhc appletalk irda phonet af_802154 bnep af_key ipx p8023 psnap p8022 llc rose can af_rxrpc caif_socket caif nfc crc_ccitt atm ax25 bluetooth rfkill x25 rds coretemp hwmon kvm_intel snd_hda_codec_realtek kvm crc32c_intel ghash_clmulni_intel snd_hda_codec_hdmi microcode pcspkr snd_hda_intel snd_hda_codec snd_hwdep snd_seq snd_seq_device e1000e usb_debug snd_pcm snd_page_alloc snd_timer ptp snd pps_core soundcore xfs libcrc32c
irq event stamp: 84929899
hardirqs last  enabled at (84929898): [<ffffffff816ed1e0>] restore_args+0x0/0x30
hardirqs last disabled at (84929899): [<ffffffff816f5cea>] apic_timer_interrupt+0x6a/0x80
softirqs last  enabled at (83776352): [<ffffffff810542d4>] __do_softirq+0x194/0x440
softirqs last disabled at (83776373): [<ffffffff8105473d>] irq_exit+0xcd/0xe0
CPU: 2 PID: 9278 Comm: trinity-child2 Not tainted 3.10.0-rc5+ #13
task: ffff8801684fca40 ti: ffff88018c89c000 task.ti: ffff88018c89c000
RIP: 0010:[<ffffffff816ec5f2>]  [<ffffffff816ec5f2>] _raw_spin_unlock_irq+0x32/0x60
RSP: 0018:ffff880244c03e80  EFLAGS: 00000202
RAX: ffff8801684fca40 RBX: ffffffff816ed1e0 RCX: 0000000000000002
RDX: 0000000000004800 RSI: ffff8801684fd1c0 RDI: 0000000000000001
RBP: ffff880244c03e88 R08: 0000000010000103 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000001 R12: ffff880244c03df8
R13: ffffffff816f5cef R14: ffff880244c03e88 R15: ffff8802417b8de8
FS:  00007fbed31ba740(0000) GS:ffff880244c00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00007f748879c000 CR3: 0000000001c0b000 CR4: 00000000001407e0
DR0: 0000000001717000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000600
Stack:
 ffff880243390000 ffff880244c03ef8 ffffffff8105cf7d ffff88018c89dfd8
 ffff88018c89dfd8 ffff88018c89dfd8 ffff88018c89dfd8 ffff8802417b89c0
 ffff88020236ab28 ffff8801779197a8 0000000000000001 0000000000000001
Call Trace:
 <IRQ> 
 [<ffffffff8105cf7d>] run_timer_softirq+0x22d/0x390
 [<ffffffff8105423f>] __do_softirq+0xff/0x440
 [<ffffffff8105473d>] irq_exit+0xcd/0xe0
 [<ffffffff816f6b8b>] smp_apic_timer_interrupt+0x6b/0x9b
 [<ffffffff816f5cef>] apic_timer_interrupt+0x6f/0x80
 <EOI> 
 [<ffffffff816ed1e0>] ? retint_restore_args+0xe/0xe
 [<ffffffff816ec5f2>] ? _raw_spin_unlock_irq+0x32/0x60
 [<ffffffff816ec5ec>] ? _raw_spin_unlock_irq+0x2c/0x60
 [<ffffffff81086c95>] finish_task_switch+0x85/0x130
 [<ffffffff81086c57>] ? finish_task_switch+0x47/0x130
 [<ffffffff816ea6e4>] __schedule+0x444/0x9c0
 [<ffffffff816eb2c3>] preempt_schedule_irq+0x53/0x90
 [<ffffffffa0465528>] ? atalk_release+0x68/0x1a0 [appletalk]
 [<ffffffff816ed2f6>] retint_kernel+0x26/0x30
 [<ffffffff81052ea2>] ? local_bh_enable_ip+0x82/0xf0
 [<ffffffff81052e98>] ? local_bh_enable_ip+0x78/0xf0
 [<ffffffff816ece7a>] _raw_write_unlock_bh+0x3a/0x40
 [<ffffffffa0465528>] atalk_release+0x68/0x1a0 [appletalk]
 [<ffffffff81590fff>] sock_release+0x1f/0x90
] BUG: soft lockup - CPU#2 stuck for 23s! [trinity-child2:9278]
Modules linked in: 8021q garp bridge stp fuse tun snd_seq_dummy hidp rfcomm ipt_ULOG nfnetlink can_raw can_bcm llc2 decnet netrom scsi_transport_iscsi pppoe pppox ppp_generic slhc appletalk irda phonet af_802154 bnep af_key ipx p8023 psnap p8022 llc rose can af_rxrpc caif_socket caif nfc crc_ccitt atm ax25 bluetooth rfkill x25 rds coretemp hwmon kvm_intel snd_hda_codec_realtek kvm crc32c_intel ghash_clmulni_intel snd_hda_codec_hdmi microcode pcspkr snd_hda_intel snd_hda_codec snd_hwdep snd_seq snd_seq_device e1000e usb_debug snd_pcm snd_page_alloc snd_timer ptp snd pps_core soundcore xfs libcrc32c
irq event stamp: 90253915
hardirqs last  enabled at (90253914): [<ffffffff816ed1e0>] restore_args+0x0/0x30
hardirqs last disabled at (90253915): [<ffffffff816f5cea>] apic_timer_interrupt+0x6a/0x80
softirqs last  enabled at (89186016): [<ffffffff810542d4>] __do_softirq+0x194/0x440
softirqs last disabled at (89186419): [<ffffffff8105473d>] irq_exit+0xcd/0xe0
CPU: 2 PID: 9278 Comm: trinity-child2 Not tainted 3.10.0-rc5+ #13
task: ffff8801684fca40 ti: ffff88018c89c000 task.ti: ffff88018c89c000
RIP: 0010:[<ffffffff816eb083>]  [<ffffffff816eb083>] preempt_schedule+0x13/0x60
RSP: 0018:ffff880244c03de8  EFLAGS: 00000202
RAX: ffff88018c89dfd8 RBX: ffffffff816ed1e0 RCX: 000000000000b910
RDX: ffff880244c485c0 RSI: 0000000000000101 RDI: 0000000000000001
RBP: ffff880244c03df8 R08: 0000000000000102 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000001 R12: ffff880244c03d58
R13: ffffffff816f5cef R14: ffff880244c03df8 R15: ffff8802417be1d0
FS:  00007fbed31ba740(0000) GS:ffff880244c00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00007f748879c000 CR3: 0000000001c0b000 CR4: 00000000001407e0
DR0: 0000000001717000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000600
Stack:
 ffffffff816ec4ed ffff8802417be180 ffff880244c03e18 ffffffffa04c2254
 ffff880243390000 ffff8802417be5a8 ffff880244c03e88 ffffffff8105ca6a
 ffffffff8105c9e5 ffffffffa04c7c98 ffffffff8254f1e0 0000000000000000
Call Trace:
 <IRQ> 
 [<ffffffff816ec4ed>] ? _raw_spin_unlock+0x4d/0x60
 [<ffffffffa04c2254>] dn_slow_timer+0x84/0x110 [decnet]
 [<ffffffff8105ca6a>] call_timer_fn+0x8a/0x370
 [<ffffffff8105c9e5>] ? call_timer_fn+0x5/0x370
 [<ffffffffa04c21d0>] ? dn_neigh_elist+0x40/0x40 [decnet]
 [<ffffffff8105cf8c>] run_timer_softirq+0x23c/0x390
 [<ffffffff8105423f>] __do_softirq+0xff/0x440
 [<ffffffff8105473d>] irq_exit+0xcd/0xe0
 [<ffffffff816f6b8b>] smp_apic_timer_interrupt+0x6b/0x9b
 [<ffffffff816f5cef>] apic_timer_interrupt+0x6f/0x80
 <EOI> 
 [<ffffffff816ed1e0>] ? retint_restore_args+0xe/0xe
 [<ffffffff8108468d>] ? lg_local_lock+0x5d/0x80
 [<ffffffff81084676>] ? lg_local_lock+0x46/0x80
 [<ffffffff811cf571>] ? mntput_no_expire+0x21/0x120
 [<ffffffff811cf571>] mntput_no_expire+0x21/0x120
 [<ffffffff811cf696>] mntput+0x26/0x40
 [<ffffffff811ae6f0>] __fput+0x1a0/0x2d0
 [<ffffffff811ae8de>] ____fput+0xe/0x10
 [<ffffffff8107463c>] task_work_run+0xac/0xe0
 [<ffffffff8104f343>] do_exit+0x2b3/0xcd0
84851] BUG: soft lockup - CPU#2 stuck for 22s! [trinity-child2:9278]
Modules linked in: 8021q garp bridge stp fuse tun snd_seq_dummy hidp rfcomm ipt_ULOG nfnetlink can_raw can_bcm llc2 decnet netrom scsi_transport_iscsi pppoe pppox ppp_generic slhc appletalk irda phonet af_802154 bnep af_key ipx p8023 psnap p8022 llc rose can af_rxrpc caif_socket caif nfc crc_ccitt atm ax25 bluetooth rfkill x25 rds coretemp hwmon kvm_intel snd_hda_codec_realtek kvm crc32c_intel ghash_clmulni_intel snd_hda_codec_hdmi microcode pcspkr snd_hda_intel snd_hda_codec snd_hwdep snd_seq snd_seq_device e1000e usb_debug snd_pcm snd_page_alloc snd_timer ptp snd pps_core soundcore xfs libcrc32c
irq event stamp: 91383033
hardirqs last  enabled at (91383032): [<ffffffff816ed1e0>] restore_args+0x0/0x30
hardirqs last disabled at (91383033): [<ffffffff816f5cea>] apic_timer_interrupt+0x6a/0x80
softirqs last  enabled at (89186016): [<ffffffff810542d4>] __do_softirq+0x194/0x440
softirqs last disabled at (89186419): [<ffffffff8105473d>] irq_exit+0xcd/0xe0
CPU: 2 PID: 9278 Comm: trinity-child2 Not tainted 3.10.0-rc5+ #13
task: ffff8801684fca40 ti: ffff88018c89c000 task.ti: ffff88018c89c000
RIP: 0010:[<ffffffff816ec5a7>]  [<ffffffff816ec5a7>] _raw_spin_unlock_irqrestore+0x67/0x80
RSP: 0018:ffff880244c03df0  EFLAGS: 00000282
RAX: ffff8801684fca40 RBX: ffffffff816ed1e0 RCX: 0000000000000002
RDX: 00000000000022b0 RSI: ffff8801684fd1f8 RDI: ffff8801684fca40
RBP: ffff880244c03e00 R08: 0000000000000102 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000001 R12: ffff880244c03d68
R13: ffffffff816f5cef R14: ffff880244c03e00 R15: ffffffff81cc4140
FS:  00007fbed31ba740(0000) GS:ffff880244c00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00007f748879c000 CR3: 0000000001c0b000 CR4: 00000000001407e0
DR0: 0000000001717000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000600
Stack:
 0000000000000282 ffffffff81cc41a0 ffff880244c03e18 ffffffff81584a2d
 ffff880243390000 ffff880244c03e88 ffffffff8105ca6a ffffffff8105c9e5
 ffffffff82d05d5d ffffffff8250f6c0 0000000000000000 ffffffff81a6b5a5
Call Trace:
 <IRQ> 
 [<ffffffff81584a2d>] flush_unmaps_timeout+0x2d/0x30
 [<ffffffff8105ca6a>] call_timer_fn+0x8a/0x370
 [<ffffffff8105c9e5>] ? call_timer_fn+0x5/0x370
 [<ffffffff81584a00>] ? flush_unmaps+0x170/0x170
 [<ffffffff8105cf8c>] run_timer_softirq+0x23c/0x390
 [<ffffffff8105423f>] __do_softirq+0xff/0x440
 [<ffffffff8105473d>] irq_exit+0xcd/0xe0
 [<ffffffff816f6b8b>] smp_apic_timer_interrupt+0x6b/0x9b
 [<ffffffff816f5cef>] apic_timer_interrupt+0x6f/0x80
 <EOI> 
 [<ffffffff816ed1e0>] ? retint_restore_args+0xe/0xe
 [<ffffffff8108468d>] ? lg_local_lock+0x5d/0x80
 [<ffffffff81084676>] ? lg_local_lock+0x46/0x80
 [<ffffffff811cf571>] ? mntput_no_expire+0x21/0x120
 [<ffffffff811cf571>] mntput_no_expire+0x21/0x120
 [<ffffffff811cf696>] mntput+0x26/0x40
 [<ffffffff811ae6f0>] __fput+0x1a0/0x2d0
 [<ffffffff811ae8de>] ____fput+0xe/0x10
 [<ffffffff8107463c>] task_work_run+0xac/0xe0
 [<ffffffff8104f343>] do_exit+0x2b3/0xcd0
 [<ffffffff816ec5ec>] ? _raw_spin_unlock_irq+0x2c/0x60
50] INFO: rcu_preempt self-detected stall on CPU { 2}  (t=6500 jiffies g=1306728 c=1306727 q=0)
sending NMI to all CPUs:
NMI backtrace for cpu 2
CPU: 2 PID: 9278 Comm: trinity-child2 Not tainted 3.10.0-rc5+ #13
task: ffff8801684fca40 ti: ffff88018c89c000 task.ti: ffff88018c89c000
RIP: 0010:[<ffffffff8102a468>]  [<ffffffff8102a468>] __x2apic_send_IPI_mask+0x188/0x1c0
RSP: 0018:ffff880244c03b38  EFLAGS: 00000046
RAX: 0000000000000004 RBX: 0000000000000001 RCX: 000000000000003c
RDX: 000000000000000f RSI: 0000000000000004 RDI: 0000000000000000
RBP: ffff880244c03b88 R08: ffff8802432a98f0 R09: 0000000000000001
R10: 0000000000000000 R11: 0000000000000001 R12: ffff8802432a98f0
R13: ffff8802437ea3f0 R14: 0000000000080000 R15: 000000000000cfd0
FS:  00007fbed31ba740(0000) GS:ffff880244c00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00007f748879c000 CR3: 0000000001c0b000 CR4: 00000000001407e0
DR0: 0000000001717000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000600
Stack:
 0000000000000092 000000000000cfc8 0000000200000002 0000000000000004
 0000000000000002 0000000000002710 ffffffff81c4fa40 ffffffff81c4fa40
 ffff880244dcd9c0 0000000000000000 ffff880244c03b98 ffffffff8102a4bc
Call Trace:
 <IRQ> 
 [<ffffffff8102a4bc>] x2apic_send_IPI_all+0x1c/0x20
 [<ffffffff81026875>] arch_trigger_all_cpu_backtrace+0x65/0xa0
 [<ffffffff81104f81>] rcu_check_callbacks+0x331/0x8e0
 [<ffffffff8107ffa0>] ? hrtimer_run_queues+0x20/0x180
 [<ffffffff81091985>] ? sched_clock_cpu+0xb5/0x100
 [<ffffffff8105e147>] update_process_times+0x47/0x80
 [<ffffffff810b1565>] tick_sched_handle.isra.16+0x25/0x60
 [<ffffffff810b1681>] tick_sched_timer+0x41/0x60
 [<ffffffff8107f001>] __run_hrtimer+0x81/0x4e0
 [<ffffffff810b1640>] ? tick_sched_do_timer+0x60/0x60
 [<ffffffff8107fc4f>] hrtimer_interrupt+0xff/0x240
 [<ffffffff8105ca75>] ? call_timer_fn+0x95/0x370
 [<ffffffff816f6b86>] smp_apic_timer_interrupt+0x66/0x9b
 [<ffffffff816f5cef>] apic_timer_interrupt+0x6f/0x80
 [<ffffffff816ed1e0>] ? retint_restore_args+0xe/0xe
 [<ffffffff810b9e90>] ? lock_release+0xb0/0x320
 [<ffffffffa04c21d0>] ? dn_neigh_elist+0x40/0x40 [decnet]
 [<ffffffff8105ca8a>] call_timer_fn+0xaa/0x370
 [<ffffffff8105c9e5>] ? call_timer_fn+0x5/0x370
 [<ffffffffa04c21d0>] ? dn_neigh_elist+0x40/0x40 [decnet]
 [<ffffffff8105cf8c>] run_timer_softirq+0x23c/0x390
 [<ffffffff8105423f>] __do_softirq+0xff/0x440
 [<ffffffff8105473d>] irq_exit+0xcd/0xe0
 [<ffffffff816f6b8b>] smp_apic_timer_interrupt+0x6b/0x9b
 [<ffffffff816f5cef>] apic_timer_interrupt+0x6f/0x80
 <EOI> 
 [<ffffffff816ed1e0>] ? retint_restore_args+0xe/0xe
 [<ffffffff8108468d>] ? lg_local_lock+0x5d/0x80
 [<ffffffff81084676>] ? lg_local_lock+0x46/0x80
 [<ffffffff811cf571>] ? mntput_no_expire+0x21/0x120
 [<ffffffff811cf571>] mntput_no_expire+0x21/0x120
 [<ffffffff811cf696>] mntput+0x26/0x40
 [<ffffffff811ae6f0>] __fput+0x1a0/0x2d0
 [<ffffffff811ae8de>] ____fput+0xe/0x10
 [<ffffffff810746[53506.564733] BUG: soft lockup - CPU#2 stuck for 22s! [trinity-child2:9278]
Modules linked in: 8021q garp bridge stp fuse tun snd_seq_dummy hidp rfcomm ipt_ULOG nfnetlink can_raw can_bcm llc2 decnet netrom scsi_transport_iscsi pppoe pppox ppp_generic slhc appletalk irda phonet af_802154 bnep af_key ipx p8023 psnap p8022 llc rose can af_rxrpc caif_socket caif nfc crc_ccitt atm ax25 bluetooth rfkill x25 rds coretemp hwmon kvm_intel snd_hda_codec_realtek kvm crc32c_intel ghash_clmulni_intel snd_hda_codec_hdmi microcode pcspkr snd_hda_intel snd_hda_codec snd_hwdep snd_seq snd_seq_device e1000e usb_debug snd_pcm snd_page_alloc snd_timer ptp snd pps_core soundcore xfs libcrc32c
irq event stamp: 92829001
hardirqs last  enabled at (92829000): [<ffffffff816ed1e0>] restore_args+0x0/0x30
hardirqs last disabled at (92829001): [<ffffffff816f5cea>] apic_timer_interrupt+0x6a/0x80
softirqs last  enabled at (92526040): [<ffffffff810542d4>] __do_softirq+0x194/0x440
softirqs last disabled at (92526043): [<ffffffff8105473d>] irq_exit+0xcd/0xe0
CPU: 2 PID: 9278 Comm: trinity-child2 Not tainted 3.10.0-rc5+ #13
task: ffff8801684fca40 ti: ffff88018c89c000 task.ti: ffff88018c89c000
RIP: 0010:[<ffffffff810b9e02>]  [<ffffffff810b9e02>] lock_release+0x22/0x320
RSP: 0018:ffff880244c03dd0  EFLAGS: 00000246
RAX: 0000000000000000 RBX: ffffffff816ed1e0 RCX: 0000000000000002
RDX: ffffffffa04c2254 RSI: 0000000000000001 RDI: ffff880241083128
RBP: ffff880244c03de0 R08: 0000000000000103 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000001 R12: ffff880244c03d48
R13: ffffffff816f5cef R14: ffff880244c03de0 R15: ffff880241083110
FS:  00007fbed31ba740(0000) GS:ffff880244c00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00007f748879c000 CR3: 0000000001c0b000 CR4: 00000000001407e0
DR0: 0000000001717000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000600
Stack:
 ffffffffa04c21d0 ffff8802410830c0 ffff880244c03df8 ffffffff816ec4bf
 ffff8802410830c0 ffff880244c03e18 ffffffffa04c2254 ffff880243390000
 ffff8802410834e8 ffff880244c03e88 ffffffff8105ca6a ffffffff8105c9e5
Call Trace:
 <IRQ> 
 [<ffffffffa04c21d0>] ? dn_neigh_elist+0x40/0x40 [decnet]
 [<ffffffff816ec4bf>] _raw_spin_unlock+0x1f/0x60
 [<ffffffffa04c2254>] dn_slow_timer+0x84/0x110 [decnet]
 [<ffffffff8105ca6a>] call_timer_fn+0x8a/0x370
 [<ffffffff8105c9e5>] ? call_timer_fn+0x5/0x370
 [<ffffffffa04c21d0>] ? dn_neigh_elist+0x40/0x40 [decnet]
 [<ffffffff8105cf8c>] run_timer_softirq+0x23c/0x390
 [<ffffffff8105423f>] __do_softirq+0xff/0x440
 [<ffffffff8105473d>] irq_exit+0xcd/0xe0
 [<ffffffff816f6b8b>] smp_apic_timer_interrupt+0x6b/0x9b
 [<ffffffff816f5cef>] apic_timer_interrupt+0x6f/0x80
 <EOI> 
 [<ffffffff816ed1e0>] ? retint_restore_args+0xe/0xe
 [<ffffffff8108468d>] ? lg_local_lock+0x5d/0x80
 [<ffffffff81084676>] ? lg_local_lock+0x46/0x80
 [<ffffffff811cf571>] ? mntput_no_expire+0x21/0x120
 [<ffffffff811cf571>] mntput_no_expire+0x21/0x120
 [<ffffffff811cf696>] mntput+0x26/0x40
 [<ffffffff811ae6f0>] __fput+0x1a0/0x2d0
 [<ffffffff811ae8de>] ____fput+0xe/0x10
 [<ffffffff8107463c>] task_work_run+0xac/0x[53534.549138] BUG: soft lockup - CPU#2 stuck for 22s! [trinity-child2:9278]
Modules linked in: 8021q garp bridge stp fuse tun snd_seq_dummy hidp rfcomm ipt_ULOG nfnetlink can_raw can_bcm llc2 decnet netrom scsi_transport_iscsi pppoe pppox ppp_generic slhc appletalk irda phonet af_802154 bnep af_key ipx p8023 psnap p8022 llc rose can af_rxrpc caif_socket caif nfc crc_ccitt atm ax25 bluetooth rfkill x25 rds coretemp hwmon kvm_intel snd_hda_codec_realtek kvm crc32c_intel ghash_clmulni_intel snd_hda_codec_hdmi microcode pcspkr snd_hda_intel snd_hda_codec snd_hwdep snd_seq snd_seq_device e1000e usb_debug snd_pcm snd_page_alloc snd_timer ptp snd pps_core soundcore xfs libcrc32c
irq event stamp: 93962231
hardirqs last  enabled at (93962230): [<ffffffff816ed1e0>] restore_args+0x0/0x30
hardirqs last disabled at (93962231): [<ffffffff816f5cea>] apic_timer_interrupt+0x6a/0x80
softirqs last  enabled at (92526040): [<ffffffff810542d4>] __do_softirq+0x194/0x440
softirqs last disabled at (92526043): [<ffffffff8105473d>] irq_exit+0xcd/0xe0
CPU: 2 PID: 9278 Comm: trinity-child2 Not tainted 3.10.0-rc5+ #13
task: ffff8801684fca40 ti: ffff88018c89c000 task.ti: ffff88018c89c000
RIP: 0010:[<ffffffff816ec5f2>]  [<ffffffff816ec5f2>] _raw_spin_unlock_irq+0x32/0x60
RSP: 0018:ffff880244c03e80  EFLAGS: 00000206
RAX: ffff8801684fca40 RBX: ffffffff816ed1e0 RCX: 0000000000000003
RDX: 0000000000000470 RSI: ffff8801684fd1c0 RDI: 0000000000000001
RBP: ffff880244c03e88 R08: 0000000000000102 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000001 R12: ffff880244c03df8
R13: ffffffff816f5cef R14: ffff880244c03e88 R15: ffff88020232f928
FS:  00007fbed31ba740(0000) GS:ffff880244c00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00007f748879c000 CR3: 0000000001c0b000 CR4: 00000000001407e0
DR0: 0000000001717000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000600
Stack:
 ffff880243390000 ffff880244c03ef8 ffffffff8105cf7d ffff88018c89dfd8
 ffff88018c89dfd8 ffff88018c89dfd8 ffff88018c89dfd8 ffff88020232f500
 ffff880219ec5228 ffff88020a54bea8 0000000000000001 0000000000000001
Call Trace:
 <IRQ> 
 [<ffffffff8105cf7d>] run_timer_softirq+0x22d/0x390
 [<ffffffff8105423f>] __do_softirq+0xff/0x440
 [<ffffffff8105473d>] irq_exit+0xcd/0xe0
 [<ffffffff816f6b8b>] smp_apic_timer_interrupt+0x6b/0x9b
 [<ffffffff816f5cef>] apic_timer_interrupt+0x6f/0x80
 <EOI> 
 [<ffffffff816ed1e0>] ? retint_restore_args+0xe/0xe
 [<ffffffff8108468d>] ? lg_local_lock+0x5d/0x80
 [<ffffffff81084676>] ? lg_local_lock+0x46/0x80
 [<ffffffff811cf571>] ? mntput_no_expire+0x21/0x120
 [<ffffffff811cf571>] mntput_no_expire+0x21/0x120
 [<ffffffff811cf696>] mntput+0x26/0x40
 [<ffffffff811ae6f0>] __fput+0x1a0/0x2d0
 [<ffffffff811ae8de>] ____fput+0xe/0x10
 [<ffffffff8107463c>] task_work_run+0xac/0xe0
 [<ffffffff8104f343>] do_exit+0x2b3/0xcd0
 [<ffffffff816ec5ec>] ? _raw_spin_unlock_irq+0x2c/0x60
 [<ffffffff8105114c>] do_group_exit+0x4c/0xc0
 [<ffffffff810636f1>] get_signal_to_deliver+0x2e1/0x940
 [<ffffffff81002418>] do_signal+0x48/0x5a0
 [<ffffffff810b437e>] ? put_lock_stats.isra.29+0xe/0x40
33496] BUG: soft lockup - CPU#2 stuck for 22s! [trinity-child2:9278]
Modules linked in: 8021q garp bridge stp fuse tun snd_seq_dummy hidp rfcomm ipt_ULOG nfnetlink can_raw can_bcm llc2 decnet netrom scsi_transport_iscsi pppoe pppox ppp_generic slhc appletalk irda phonet af_802154 bnep af_key ipx p8023 psnap p8022 llc rose can af_rxrpc caif_socket caif nfc crc_ccitt atm ax25 bluetooth rfkill x25 rds coretemp hwmon kvm_intel snd_hda_codec_realtek kvm crc32c_intel ghash_clmulni_intel snd_hda_codec_hdmi microcode pcspkr snd_hda_intel snd_hda_codec snd_hwdep snd_seq snd_seq_device e1000e usb_debug snd_pcm snd_page_alloc snd_timer ptp snd pps_core soundcore xfs libcrc32c
irq event stamp: 95094981
hardirqs last  enabled at (95094980): [<ffffffff816ed1e0>] restore_args+0x0/0x30
hardirqs last disabled at (95094981): [<ffffffff816f5cea>] apic_timer_interrupt+0x6a/0x80
softirqs last  enabled at (92526040): [<ffffffff810542d4>] __do_softirq+0x194/0x440
softirqs last disabled at (92526043): [<ffffffff8105473d>] irq_exit+0xcd/0xe0
CPU: 2 PID: 9278 Comm: trinity-child2 Not tainted 3.10.0-rc5+ #13
task: ffff8801684fca40 ti: ffff88018c89c000 task.ti: ffff88018c89c000
RIP: 0010:[<ffffffff816ec5a7>]  [<ffffffff816ec5a7>] _raw_spin_unlock_irqrestore+0x67/0x80
RSP: 0018:ffff880244c03d90  EFLAGS: 00000286
RAX: ffff8801684fca40 RBX: ffffffff816ed1e0 RCX: 0000000000000002
RDX: 0000000000004340 RSI: ffff8801684fd230 RDI: ffff8801684fca40
RBP: ffff880244c03da0 R08: 0000000000000103 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000001 R12: ffff880244c03d08
R13: ffffffff816f5cef R14: ffff880244c03da0 R15: ffff880243390000
FS:  00007fbed31ba740(0000) GS:ffff880244c00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00007f748879c000 CR3: 0000000001c0b000 CR4: 00000000001407e0
DR0: 0000000001717000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000600
Stack:
 ffff88022d528428 ffff880243390000 ffff880244c03de0 ffffffff8105dc39
 0000000000000286 ffff88022d528000 ffff88022d528050 0000000000000101
 ffffffffa04c21d0 ffff88022d528000 ffff880244c03df8 ffffffff81594a88
Call Trace:
 <IRQ> 
 [<ffffffff8105dc39>] mod_timer+0x119/0x320
 [<ffffffffa04c21d0>] ? dn_neigh_elist+0x40/0x40 [decnet]
 [<ffffffff81594a88>] sk_reset_timer+0x18/0x30
 [<ffffffffa04c224c>] dn_slow_timer+0x7c/0x110 [decnet]
 [<ffffffff8105ca6a>] call_timer_fn+0x8a/0x370
 [<ffffffff8105c9e5>] ? call_timer_fn+0x5/0x370
 [<ffffffffa04c21d0>] ? dn_neigh_elist+0x40/0x40 [decnet]
 [<ffffffff8105cf8c>] run_timer_softirq+0x23c/0x390
 [<ffffffff8105423f>] __do_softirq+0xff/0x440
 [<ffffffff8105473d>] irq_exit+0xcd/0xe0
 [<ffffffff816f6b8b>] smp_apic_timer_interrupt+0x6b/0x9b
 [<ffffffff816f5cef>] apic_timer_interrupt+0x6f/0x80
 <EOI> 
 [<ffffffff816ed1e0>] ? retint_restore_args+0xe/0xe
 [<ffffffff8108468d>] ? lg_local_lock+0x5d/0x80
 [<ffffffff81084676>] ? lg_local_lock+0x46/0x80
 [<ffffffff811cf571>] ? mntput_no_expire+0x21/0x120
 [<ffffffff811cf571>] mntput_no_expire+0x21/0x120
 [<ffffffff811cf696>] mntput+0x26/0x40
 [<ffffffff811ae6f0>] __fput+0x1a0/0x2d0
 [<ffffffff811ae8de>] ____f[53654.512179] BUG: soft lockup - CPU#3 stuck for 22s! [trinity-child2:9278]
Modules linked in: 8021q garp bridge stp fuse tun snd_seq_dummy hidp rfcomm ipt_ULOG nfnetlink can_raw can_bcm llc2 decnet netrom scsi_transport_iscsi pppoe pppox ppp_generic slhc appletalk irda phonet af_802154 bnep af_key ipx p8023 psnap p8022 llc rose can af_rxrpc caif_socket caif nfc crc_ccitt atm ax25 bluetooth rfkill x25 rds coretemp hwmon kvm_intel snd_hda_codec_realtek kvm crc32c_intel ghash_clmulni_intel snd_hda_codec_hdmi microcode pcspkr snd_hda_intel snd_hda_codec snd_hwdep snd_seq snd_seq_device e1000e usb_debug snd_pcm snd_page_alloc snd_timer ptp snd pps_core soundcore xfs libcrc32c
irq event stamp: 99648941
hardirqs last  enabled at (99648940): [<ffffffff816ed1e0>] restore_args+0x0/0x30
hardirqs last disabled at (99648941): [<ffffffff816f5cea>] apic_timer_interrupt+0x6a/0x80
softirqs last  enabled at (98576516): [<ffffffff810542d4>] __do_softirq+0x194/0x440
softirqs last disabled at (98577051): [<ffffffff8105473d>] irq_exit+0xcd/0xe0
CPU: 3 PID: 9278 Comm: trinity-child2 Not tainted 3.10.0-rc5+ #13
task: ffff8801684fca40 ti: ffff88018c89c000 task.ti: ffff88018c89c000
RIP: 0010:[<ffffffff810b5fb5>]  [<ffffffff810b5fb5>] lock_acquired+0x105/0x3f0
RSP: 0018:ffff880244e03d98  EFLAGS: 00000246
RAX: ffff8801684fca40 RBX: ffffffff816ed1e0 RCX: 0000000000000003
RDX: 0000000000004340 RSI: 0000000000000102 RDI: 0000000000000001
RBP: ffff880244e03dd0 R08: 0000000000000102 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000001 R12: ffff880244e03d08
R13: ffffffff816f5cef R14: ffff880244e03dd0 R15: ffff8801684fca40
FS:  00007fbed31ba740(0000) GS:ffff880244e00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 0000000003b5ab28 CR3: 0000000001c0b000 CR4: 00000000001407e0
DR0: 0000000001717000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000600
Stack:
 0000000300000000 ffffffffa04c21eb ffff880241082750 ffff880241082768
 0000000000000101 ffffffffa04c21d0 ffff880241082700 ffff880244e03df8
 ffffffff816ec16c ffffffffa04c21eb ffff880241082700 ffff880241082750
Call Trace:
 <IRQ> 
 [<ffffffffa04c21eb>] ? dn_slow_timer+0x1b/0x110 [decnet]
 [<ffffffffa04c21d0>] ? dn_neigh_elist+0x40/0x40 [decnet]
 [<ffffffff816ec16c>] _raw_spin_lock+0x6c/0x80
 [<ffffffffa04c21eb>] ? dn_slow_timer+0x1b/0x110 [decnet]
 [<ffffffffa04c21eb>] dn_slow_timer+0x1b/0x110 [decnet]
 [<ffffffff8105ca6a>] call_timer_fn+0x8a/0x370
 [<ffffffff8105c9e5>] ? call_timer_fn+0x5/0x370
 [<ffffffffa04c21d0>] ? dn_neigh_elist+0x40/0x40 [decnet]
 [<ffffffff8105cf8c>] run_timer_softirq+0x23c/0x390
 [<ffffffff8105423f>] __do_softirq+0xff/0x440
 [<ffffffff8105473d>] irq_exit+0xcd/0xe0
 [<ffffffff816f6b8b>] smp_apic_timer_interrupt+0x6b/0x9b
 [<ffffffff816f5cef>] apic_timer_interrupt+0x6f/0x80
 <EOI> 
 [<ffffffff816ed1e0>] ? retint_restore_args+0xe/0xe
 [<ffffffff810b9946>] ? lock_acquire+0xa6/0x1f0
 [<ffffffff811cf571>] ? mntput_no_expire+0x21/0x120
 [<ffffffff8108466e>] lg_local_lock+0x3e/0x80
 [<ffffffff811cf571>] ? mntput_no_expire+0x21/0x120
 [<ffffffff811cf571>] mntput_no_expire+0x21/0x120
 [<ffffffff811cf696>] mntput+0x26/0x40
 [<ffffffff811ae6f0>] __fput+0x1a0/0x2d0
 [<ffffffff811ae8de>] ____fput+0xe/0x10
 [<ffffffff8107463c>] task_work_run+0xac/0xe0
 [<ffffffff8104f343>] do_exit+0x2b3/0xcd0
 [<ffffffff816ec5ec>] ? _raw_spin_unlock_irq+0x2c/0x60
 [<ffffffff8105114c>] do_group_exit+0x4c/0xc0
 [<ffffffff810636f1>] get_signal_to_deliver+0x2e1/0x940
 [<ffffffff81002418>] do_signal+0x48/0x5a0
 [<ffffffff810b437e>] ? put_lock_stats.isra.29+0xe/0x40
 [<ffffffff8108ce2d>] ? get_parent_ip+0xd/0x50
 [<ffffffff81145325>] ? user_exit+0x45/0x90
 [<ffffffff810b72dd>] ? trace_hardirqs_on_caller+0xfd/0x1c0
 [<ffffffff810029e8>] do_notify_resume+0x78/0x90
 [<ffffffff816f538a>] int_signal+0x12/0x17
Code: 89 ff e8 7f e1 ff ff 85 c0 74 b3 4d 3b 6f 10 0f 84 a1 00 00 00 65 48 8b 04 25 00 ba 00 00 c7 80 7c 07 00 00 00 00 00 00 41 56 9d <48> 83 c4 10 5b 41 5c 41 5d 41 5e 41 5f 5d c3 0f 1f 40 00 85 db 
BUG: soft lockup - CPU#2 stuck for 22s! [trinity-child2:9278]
Modules linked in: 8021q garp bridge stp fuse tun snd_seq_dummy hidp rfcomm ipt_ULOG nfnetlink can_raw can_bcm llc2 decnet netrom scsi_transport_iscsi pppoe pppox ppp_generic slhc appletalk irda phonet af_802154 bnep af_key ipx p8023 psnap p8022 llc rose can af_rxrpc caif_socket caif nfc crc_ccitt atm ax25 bluetooth rfkill x25 rds coretemp hwmon kvm_intel snd_hda_codec_realtek kvm crc32c_intel ghash_clmulni_intel snd_hda_codec_hdmi microcode pcspkr snd_hda_intel snd_hda_codec snd_hwdep snd_seq snd_seq_device e1000e usb_debug snd_pcm snd_page_alloc snd_timer ptp snd pps_core soundcore xfs libcrc32c
irq event stamp: 102175341
hardirqs last  enabled at (102175340): [<ffffffff816ed1e0>] restore_args+0x0/0x30
hardirqs last disabled at (102175341): [<ffffffff816f5cea>] apic_timer_interrupt+0x6a/0x80
softirqs last  enabled at (101559798): [<ffffffff810542d4>] __do_softirq+0x194/0x440
softirqs last disabled at (101559801): [<ffffffff8105473d>] irq_exit+0xcd/0xe0
CPU: 2 PID: 9278 Comm: trinity-child2 Not tainted 3.10.0-rc5+ #13
task: ffff8801684fca40 ti: ffff88018c89c000 task.ti: ffff88018c89c000
RIP: 0010:[<ffffffff810b9946>]  [<ffffffff810b9946>] lock_acquire+0xa6/0x1f0
RSP: 0018:ffff880244c03dc0  EFLAGS: 00000246
RAX: ffff8801684fca40 RBX: ffffffff816ed1e0 RCX: 0000000010e00000
RDX: ffffffff8216fe60 RSI: 0000000000000000 RDI: ffffffffef200438
RBP: ffff880244c03e18 R08: ffff8801684fd1c0 R09: 0000000000000001
R10: 0000000000000000 R11: 0000000000000001 R12: ffff880244c03d38
R13: ffffffff816f5cef R14: ffff880244c03e18 R15: 0000000000000000
FS:  00007fbed31ba740(0000) GS:ffff880244c00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 0000003850abc720 CR3: 0000000001c0b000 CR4: 00000000001407e0
DR0: 0000000001717000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000600
Stack:
 0000000000000000 ffffffff8105c9e5 ffff880200000000 0000000000000246
 0000000000000002 ffff880244c03e30 ffff880243390000 ffff880228ef0428
 0000000000000101 ffffffffa04c21d0 ffff880228ef0000 ffff880244c03e88
Call Trace:
 <IRQ> 
 [<ffffffff8105c9e5>] ? call_timer_fn+0x5/0x370
 [<ffffffffa04c21d0>] ? dn_neigh_elist+0x40/0x40 [decnet]
 [<ffffffff8105ca5f>] call_timer_fn+0x7f/0x370
 [<ffffffff8105c9e5>] ? call_timer_fn+0x5/0x370
 [<ffffffffa04c21d0>] ? dn_neigh_elist+0x40/0x40 [decnet]
 [<ffffffff8105cf8c>] run_timer_softirq+0x23c/0x390
 [<ffffffff8105423f>] __do_softirq+0xff/0x440
 [<ffffffff8105473d>] irq_exit+0xcd/0xe0
 [<ffffffff816f6b8b>] smp_apic_timer_interrupt+0x6b/0x9b
 [<ffffffff816f5cef>] apic_timer_interrupt+0x6f/0x80
 <EOI> 
 [<ffffffff816ed1e0>] ? retint_restore_args+0xe/0xe
 [<ffffffff816ec5a7>] ? _raw_spin_unlock_irqrestore+0x67/0x80
 [<ffffffff813149be>] debug_check_no_obj_freed+0x14e/0x250
 [<ffffffff81198d35>] ? kmem_cache_free+0x95/0x300
 [<ffffffff81198d4d>] kmem_cache_free+0xad/0x300
 [<ffffffff811c2b42>] ? __d_free+0x42/0x60
 [<ffffffff810b494e>] ? lock_release_holdtime.part.30+0xee/0x170
 [<ffffffff811c2b42>] __d_free+0x42/0x60
 [<ffffffff811c3185>] d_free+0x55/0x60
 [<f[53762.451909] BUG: soft lockup - CPU#3 stuck for 23s! [trinity-child2:9278]
Modules linked in: 8021q garp bridge stp fuse tun snd_seq_dummy hidp rfcomm ipt_ULOG nfnetlink can_raw can_bcm llc2 decnet netrom scsi_transport_iscsi pppoe pppox ppp_generic slhc appletalk irda phonet af_802154 bnep af_key ipx p8023 psnap p8022 llc rose can af_rxrpc caif_socket caif nfc crc_ccitt atm ax25 bluetooth rfkill x25 rds coretemp hwmon kvm_intel snd_hda_codec_realtek kvm crc32c_intel ghash_clmulni_intel snd_hda_codec_hdmi microcode pcspkr snd_hda_intel snd_hda_codec snd_hwdep snd_seq snd_seq_device e1000e usb_debug snd_pcm snd_page_alloc snd_timer ptp snd pps_core soundcore xfs libcrc32c
irq event stamp: 104442709
hardirqs last  enabled at (104442708): [<ffffffff816ed1e0>] restore_args+0x0/0x30
hardirqs last disabled at (104442709): [<ffffffff816f5cea>] apic_timer_interrupt+0x6a/0x80
softirqs last  enabled at (103416536): [<ffffffff810542d4>] __do_softirq+0x194/0x440
softirqs last disabled at (103416953): [<ffffffff8105473d>] irq_exit+0xcd/0xe0
CPU: 3 PID: 9278 Comm: trinity-child2 Not tainted 3.10.0-rc5+ #13
task: ffff8801684fca40 ti: ffff88018c89c000 task.ti: ffff88018c89c000
RIP: 0010:[<ffffffff810b9e90>]  [<ffffffff810b9e90>] lock_release+0xb0/0x320
RSP: 0018:ffff880244e03db8  EFLAGS: 00000246
RAX: ffff8801684fca40 RBX: ffffffff816ed1e0 RCX: 000000000000b910
RDX: ffff880244e485c0 RSI: 0000000000000102 RDI: 0000000000000001
RBP: ffff880244e03de0 R08: 0000000000000102 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000001 R12: ffff880244e03d28
R13: ffffffff816f5cef R14: ffff880244e03de0 R15: ffff88020208bae8
FS:  00007fbed31ba740(0000) GS:ffff880244e00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00007f00268fc068 CR3: 0000000001c0b000 CR4: 00000000001407e0
DR0: 0000000001717000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000600
Stack:
 ffff88020208bad0 ffff88020208bad0 0000000000000101 ffffffffa04c21d0
 ffff88020208ba80 ffff880244e03df8 ffffffff816ec4bf ffff88020208ba80
 ffff880244e03e18 ffffffffa04c2254 ffff8802433b0000 ffff88020208bea8
Call Trace:
 <IRQ> 
 [<ffffffffa04c21d0>] ? dn_neigh_elist+0x40/0x40 [decnet]
 [<ffffffff816ec4bf>] _raw_spin_unlock+0x1f/0x60
 [<ffffffffa04c2254>] dn_slow_timer+0x84/0x110 [decnet]
 [<ffffffff8105ca6a>] call_timer_fn+0x8a/0x370
 [<ffffffff8105c9e5>] ? call_timer_fn+0x5/0x370
 [<ffffffffa04c21d0>] ? dn_neigh_elist+0x40/0x40 [decnet]
 [<ffffffff8105cf8c>] run_timer_softirq+0x23c/0x390
 [<ffffffff8105423f>] __do_softirq+0xff/0x440
 [<ffffffff8105473d>] irq_exit+0xcd/0xe0
 [<ffffffff816f6b8b>] smp_apic_timer_interrupt+0x6b/0x9b
 [<ffffffff816f5cef>] apic_timer_interrupt+0x6f/0x80
 <EOI> 
 [<ffffffff816ed1e0>] ? retint_restore_args+0xe/0xe
 [<ffffffff816ec5a7>] ? _raw_spin_unlock_irqrestore+0x67/0x80
 [<ffffffff81314823>] debug_object_active_state+0x133/0x180
 [<ffffffff811ae4f0>] ? get_max_files+0x20/0x20
 [<ffffffff81101085>] __call_rcu+0x55/0x840
 [<ffffffff8108ce2d>] ? get_parent_ip+0xd/0x50
 [<ffffffff816f0d91>] ? sub_preempt_count+0x71/0x100
 [<ffffffff811018cd>] call_rcu+0x1d/0x20
 [<ffffffff811ae6e0>] __fput+0x190/0x2d0
 [<ffffffff811ae8de>] ____fput+0xe/0x10
 [<ffffffff8107463c>] task_work_run+0xac/0xe0
 [<ffffffff8104f343>] do_exit+0x2b3/0xcd0
 [<ffffffff816ec5ec>] ? _raw_spin_unlock_irq+0x2c/0x60
 [<ffffffff8105114c>] do_group_exit+0x4c/0xc0
 [<ffffffff810636f1>] get_signal_to_deliver+0x2e1/0x940
 [<ffffffff81002418>] do_signal+0x48/0x5a0
 [<ffffffff810b437e>] ? put_lock_stats.isra.29+0xe/0x40
 [<ffffffff8108ce2d>] ? get_parent_ip+0xd/0x50
 [<ffffffff81145325>] ? user_exit+0x45/0x90
 [<ffffffff810b72dd>] ? trace_hardirqs_on_caller+0xfd/0x1c0
 [<ffffffff810029e8>] do_notify_resume+0x78/0x90
 [<ffffffff816f538a>] int_signal+0x12/0x17
Code: ff 0f 85 b4 00 00 00 4c 89 ea 4c 89 e6 48 89 df e8 16 fc ff ff 65 48 8b 04 25 00 ba 00 00 c7 80 7c 07 00 00 00 00 00 00 41 56 9d <5b> 41 5c 41 5d 41 5e 41 5f 5d f3 c3 0f 1f 40 00 65 48 8b 04 25 
BUG: soft lockup - CPU#3 stuck for 23s! [trinity-child2:9278]
Modules linked in: 8021q garp bridge stp fuse tun snd_seq_dummy hidp rfcomm ipt_ULOG nfnetlink can_raw can_bcm llc2 decnet netrom scsi_transport_iscsi pppoe pppox ppp_generic slhc appletalk irda phonet af_802154 bnep af_key ipx p8023 psnap p8022 llc rose can af_rxrpc caif_socket caif nfc crc_ccitt atm ax25 bluetooth rfkill x25 rds coretemp hwmon kvm_intel snd_hda_codec_realtek kvm crc32c_intel ghash_clmulni_intel snd_hda_codec_hdmi microcode pcspkr snd_hda_intel snd_hda_codec snd_hwdep snd_seq snd_seq_device e1000e usb_debug snd_pcm snd_page_alloc snd_timer ptp snd pps_core soundcore xfs libcrc32c
irq event stamp: 105596253
hardirqs last  enabled at (105596252): [<ffffffff816ed1e0>] restore_args+0x0/0x30
hardirqs last disabled at (105596253): [<ffffffff816f5cea>] apic_timer_interrupt+0x6a/0x80
softirqs last  enabled at (103416536): [<ffffffff810542d4>] __do_softirq+0x194/0x440
softirqs last disabled at (103416953): [<ffffffff8105473d>] irq_exit+0xcd/0xe0
CPU: 3 PID: 9278 Comm: trinity-child2 Not tainted 3.10.0-rc5+ #13
task: ffff8801684fca40 ti: ffff88018c89c000 task.ti: ffff88018c89c000
RIP: 0010:[<ffffffff816ec5f2>]  [<ffffffff816ec5f2>] _raw_spin_unlock_irq+0x32/0x60
RSP: 0018:ffff880244e03e80  EFLAGS: 00000202
RAX: ffff8801684fca40 RBX: ffffffff816ed1e0 RCX: 0000000000000000
RDX: 0000000000000000 RSI: 0000000000000000 RDI: 0000000000000001
RBP: ffff880244e03e88 R08: 0000000000000102 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000001 R12: ffff880244e03df8
R13: ffffffff816f5cef R14: ffff880244e03e88 R15: ffff88020232e5a8
FS:  00007fbed31ba740(0000) GS:ffff880244e00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00007f00268fc068 CR3: 0000000001c0b000 CR4: 00000000001407e0
DR0: 0000000001717000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000600
Stack:
 ffff8802433b0000 ffff880244e03ef8 ffffffff8105cf7d ffff88018c89dfd8
 ffff88018c89dfd8 ffff88018c89dfd8 ffff88018c89dfd8 ffff88020232e180
 ffff8802023fd228 ffff88022d52d228 0000000000000001 0000000000000001
Call Trace:
 <IRQ> 
 [<ffffffff8105cf7d>] run_timer_softirq+0x22d/0x390
 [<ffffffff8105423f>] __do_softirq+0xff/0x440
 [<ffffffff8105473d>] irq_exit+0xcd/0xe0
 [<ffffffff816f6b8b>] smp_apic_timer_interrupt+0x6b/0x9b
 [<ffffffff816f5cef>] apic_timer_interrupt+0x6f/0x80
 <EOI> 
 [<ffffffff816ed1e0>] ? retint_restore_args+0xe/0xe
 [<ffffffff816ec5a7>] ? _raw_spin_unlock_irqrestore+0x67/0x80
 [<ffffffff81314823>] debug_object_active_state+0x133/0x180
 [<ffffffff811ae4f0>] ? get_max_files+0x20/0x20
 [<ffffffff81101085>] __call_rcu+0x55/0x840
 [<ffffffff8108ce2d>] ? get_parent_ip+0xd/0x50
 [<ffffffff816f0d91>] ? sub_preempt_count+0x71/0x100
 [<ffffffff811018cd>] call_rcu+0x1d/0x20
 [<ffffffff811ae6e0>] __fput+0x190/0x2d0
 [<ffffffff811ae8de>] ____fput+0xe/0x10
 [<ffffffff8107463c>] task_work_run+0xac/0xe0
 [<ffffffff8104f343>] do_exit+0x2b3/0xcd0
 [<ffffffff816ec5ec>] ? _raw_spin_unlock_irq+0x2c/0x60
 [<ffffffff8105114c>] do_group_exit+0x4c/0xc0
 [<ffffffff810636f1>] get_signal_to_deliver+0x2e1/0x940
 [<ffffffff81002418>] do_signal+0x48/0x5a0
 [<ffffffff810b437e>] ? put_lock_stats.isra.29+0xe/0x40
 [<ffffffff8108ce2d>] ? get_parent_ip+0xd/0x50
 [<ffffffff81145325>] ? user_exit+0x45/0x90
 [<ffffffff810b72dd>] ? trace_hardirqs_on_caller+0xfd/0x1c0
 [<ffffffff810029e8>] do_notify_resume+0x78/0x90
 [<ffffffff816f538a>] int_signal+0x12/0x17
Code: 01 00 00 00 48 89 e5 53 48 89 fb 48 8b 55 08 48 8d 7f 18 e8 01 d8 9c ff 48 89 df e8 19 55 c2 ff e8 b4 ad 9c ff fb bf 01 00 00 00 <e8> 29 47 00 00 65 48 8b 04 25 f0 b9 00 00 48 8b 80 38 e0 ff ff 
