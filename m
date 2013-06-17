From: Dave Jones <davej@redhat.com>
Subject: ax25_recvmsg lockup
Date: Mon, 17 Jun 2013 10:28:03 -0400
Message-ID: <20130617142803.GB16732@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57151 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754064Ab3FQReQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Jun 2013 13:34:16 -0400
Received: from int-mx12.intmail.prod.int.phx2.redhat.com (int-mx12.intmail.prod.int.phx2.redhat.com [10.5.11.25])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id r5HHYFGm012637
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Mon, 17 Jun 2013 13:34:16 -0400
Received: from gelk.kernelslacker.org (ovpn-113-48.phx2.redhat.com [10.3.113.48])
	by int-mx12.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id r5HHYAtn025189
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Mon, 17 Jun 2013 13:34:15 -0400
Received: from gelk.kernelslacker.org (localhost [127.0.0.1])
	by gelk.kernelslacker.org (8.14.7/8.14.5) with ESMTP id r5HESEgE030511
	for <netdev@vger.kernel.org>; Mon, 17 Jun 2013 10:28:24 -0400
Received: (from davej@localhost)
	by gelk.kernelslacker.org (8.14.7/8.14.7/Submit) id r5HES4Xw030227
	for netdev@vger.kernel.org; Mon, 17 Jun 2013 10:28:04 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With the right arguments from userspace, reading from an ax25 socket
can spend long enough in the kernel that it triggers the softlockup detector.
I hit a bunch of these traces in a trinity run that I left running over the weekend.

	Dave

BUG: soft lockup - CPU#1 stuck for 22s! [trinity-child1:16261]
Modules linked in: bridge 8021q garp stp tun fuse snd_seq_dummy rfcomm bnep nfnetlink hidp ipt_ULOG scsi_transport_iscsi can_bcm ipx p8023 p8022 x25 netrom nfc rose llc2 ax25 caif_socket irda caif pppoe pppox ppp_generic crc_ccitt slhc appletalk psnap can_raw llc can af_rxrpc atm af_key af_802154 rds phonet bluetooth rfkill coretemp hwmon kvm_intel kvm snd_hda_codec_realtek crc32c_intel ghash_clmulni_intel microcode snd_hda_codec_hdmi pcspkr snd_hda_intel snd_hda_codec snd_hwdep snd_seq snd_seq_device usb_debug snd_pcm e1000e snd_page_alloc snd_timer snd ptp pps_core soundcore xfs libcrc32c
irq event stamp: 10012027
hardirqs last  enabled at (10012026): [<ffffffff816ed220>] restore_args+0x0/0x30
hardirqs last disabled at (10012027): [<ffffffff816f5d2a>] apic_timer_interrupt+0x6a/0x80
softirqs last  enabled at (9840102): [<ffffffff810542d4>] __do_softirq+0x194/0x440
softirqs last disabled at (9840105): [<ffffffff8105473d>] irq_exit+0xcd/0xe0
CPU: 1 PID: 16261 Comm: trinity-child1 Not tainted 3.10.0-rc6+ #15 [loadavg: 31.07 14.82 9.29 8/188 19161]
task: ffff88023c62ca40 ti: ffff880228538000 task.ti: ffff880228538000
RIP: 0010:[<ffffffff816ec5f7>]  [<ffffffff816ec5f7>] _raw_spin_unlock_irqrestore+0x67/0x80
RSP: 0018:ffff880244a03dd8  EFLAGS: 00000292
RAX: ffff88023c62ca40 RBX: ffffffff816ed220 RCX: 0000000000000000
RDX: 0000000000000000 RSI: 0000000000000000 RDI: ffff88023c62ca40
RBP: ffff880244a03de8 R08: 0000000010000101 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000001 R12: ffff880244a03d48
R13: ffffffff816f5d2f R14: ffff880244a03de8 R15: ffffffff81c4fa40
FS:  00007f187c62d740(0000) GS:ffff880244a00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 0000000004f171f8 CR3: 000000022b4fb000 CR4: 00000000001407e0
DR0: 0000000001fe7000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000600
Stack:
 ffffffff81c4fa40 0000000000000292 ffff880244a03e08 ffffffff810fbf20
 0000000000000000 0000000000000000 ffff880244a03eb8 ffffffff810fd0da
 0000000000000000 ffff880244a03e40 0000000000000000 ffff880228539fd8
Call Trace:
 <IRQ> 
 [<ffffffff810fbf20>] rcu_report_qs_rsp+0x30/0x70
 [<ffffffff810fd0da>] rcu_report_qs_rnp+0x21a/0x2c0
 [<ffffffff8110333f>] rcu_process_callbacks+0x39f/0x520
 [<ffffffff8105423f>] __do_softirq+0xff/0x440
 [<ffffffff8105473d>] irq_exit+0xcd/0xe0
 [<ffffffff816f6bcb>] smp_apic_timer_interrupt+0x6b/0x9b
 [<ffffffff816f5d2f>] apic_timer_interrupt+0x6f/0x80
 <EOI> 
 [<ffffffff816ed220>] ? retint_restore_args+0xe/0xe
 [<ffffffff816ea2f0>] ? wait_for_completion_interruptible+0x180/0x180
 [<ffffffff816eb313>] ? preempt_schedule_irq+0x53/0x90
 [<ffffffff81595d63>] ? release_sock+0x193/0x1f0
 [<ffffffff816ed336>] retint_kernel+0x26/0x30
 [<ffffffff81052ea2>] ? local_bh_enable_ip+0x82/0xf0
 [<ffffffff816ec58a>] _raw_spin_unlock_bh+0x3a/0x40
 [<ffffffff81595d63>] release_sock+0x193/0x1f0
 [<ffffffffa04205ef>] ax25_recvmsg+0xdf/0x210 [ax25]
 [<ffffffff8100a384>] ? native_sched_clock+0x24/0x80
 [<ffffffff81091985>] ? sched_clock_cpu+0xb5/0x100
 [<ffffffff81590fc6>] sock_aio_read.part.8+0x116/0x130
 [<ffffffff81591001>] sock_aio_read+0x21/0x30
 [<ffffffff811ac4b0>] do_sync_read+0x80/0xb0
 [<ffffffff811acbad>] vfs_read+0x14d/0x170
 [<ffffffff811ad5ac>] SyS_read+0x4c/0xa0
 [<ffffffff816f52d4>] tracesys+0xdd/0xe2
Code: 00 e8 8e 47 00 00 65 48 8b 04 25 f0 b9 00 00 48 8b 80 38 e0 ff ff a8 08 75 13 5b 41 5c 5d c3 0f 1f 44 00 00 e8 ab ad 9c ff 53 9d <eb> cf 0f 1f 80 00 00 00 00 e8 bb ea ff ff eb df 66 0f 1f 84 00 
