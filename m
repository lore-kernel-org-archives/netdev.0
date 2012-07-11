From: Dave Jones <davej@redhat.com>
Subject: 3.5rc6 modprobe -r ip_vs oopses
Date: Wed, 11 Jul 2012 15:07:23 -0400
Message-ID: <20120711190722.GA31185@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: wensong@linux-vs.org, horms@verge.net.au, ja@ssi.bg
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42859 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932352Ab2GKTxa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Jul 2012 15:53:30 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Triggered during modprobe -r ip_vs
(W taint flag came from something unrelated: 80211 trying >MAX_ORDER alloc failing).

BUG: unable to handle kernel NULL pointer dereference at 0000000000000750
IP: [<ffffffffa4c9280b>] ip_vs_dst_event+0x18b/0x200 [ip_vs]
PGD ae993067 PUD 35cbb067 PMD 0 
Oops: 0000 [#1] SMP 
CPU 2 

Pid: 11534, comm: modprobe Tainted: G        WC   3.5.0-rc6+ #78
 Dell Inc.                 Precision WorkStation 490    
/0DT031

RIP: 0010:[<ffffffffa4c9280b>]  [<ffffffffa4c9280b>] ip_vs_dst_event+0x18b/0x200 [ip_vs]
RSP: 0000:ffff8800c92b7e28  EFLAGS: 00010246
RAX: 0000000000000000 RBX: ffff880222fa22a0 RCX: 0000000000000006
RDX: ffffffffa4caba50 RSI: 2222222222222222 RDI: 2222222222222222
RBP: ffff8800c92b7e78 R08: 2222222222222222 R09: 2222222222222222
R10: 0000000000000000 R11: 0000000000000000 R12: ffffffff82bec540
R13: ffffffff82bec638 R14: ffffffff82bec540 R15: ffffffffa4caba40
FS:  00007f652be40700(0000) GS:ffff880226a00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 0000000000000750 CR3: 0000000035ea4000 CR4: 00000000000007e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process modprobe (pid: 11534, threadinfo ffff8800c92b6000, task ffff8801278d4900)
Stack:
 2222222222222222 0000000000000100 ffffffffa4caba50 ffffffffa4caa7a0
 ffffffffa4ca8750 ffff880222fa22a0 ffffffffa4ca8750 ffffffff82bec638
 ffffffff82bec540 0000000000000000 ffff8800c92b7eb8 ffffffff8156adcf

Call Trace:
 [<ffffffff8156adcf>] unregister_netdevice_notifier+0x7f/0x100
 [<ffffffffa4c96005>] ip_vs_control_cleanup+0x15/0x20 [ip_vs]
 [<ffffffffa4ca33b2>] ip_vs_cleanup+0x41/0xc8f [ip_vs]
 [<ffffffff810e0b8c>] sys_delete_module+0x19c/0x2c0
 [<ffffffff816c1615>] ? sysret_check+0x22/0x5d
 [<ffffffff8133c04e>] ? trace_hardirqs_on_thunk+0x3a/0x3f
 [<ffffffff816c15e9>] system_call_fastpath+0x16/0x1b
Code: 18 75 cd 4c 89 ef e8 35 48 00 00 eb c3 0f 1f 00 48 83 45 b8 01 48 81 
7d b8 00 01 00 00 0f 85 cd fe ff ff 49 8b 84 24 c0 0c 00 00 <4c> 8b a8 50 07 
00 00 48 05 50 07 00 00 49 39 c5 75 38 48 c7 c7 

RIP 
 [<ffffffffa4c9280b>] ip_vs_dst_event+0x18b/0x200 [ip_vs]
 RSP <ffff8800c92b7e28>
CR2: 0000000000000750
---[ end trace 83bf880b95bd63b8 ]---

That's here...

        list_for_each_entry(dest, &net_ipvs(net)->dest_trash, n_list) {
    226b:       4c 8b a8 50 07 00 00    mov    0x750(%rax),%r13
