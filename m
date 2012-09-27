From: Dave Jones <davej@redhat.com>
Subject: GPF in ip6_dst_lookup_tail
Date: Thu, 27 Sep 2012 10:03:23 -0400
Message-ID: <20120927140323.GA1459@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:12597 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752320Ab2I0OD0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Sep 2012 10:03:26 -0400
Received: from int-mx11.intmail.prod.int.phx2.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.24])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id q8RE3QWW023584
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Thu, 27 Sep 2012 10:03:26 -0400
Received: from gelk.kernelslacker.org (ovpn-113-147.phx2.redhat.com [10.3.113.147])
	by int-mx11.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id q8RE3Pec030133
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Thu, 27 Sep 2012 10:03:26 -0400
Received: from gelk.kernelslacker.org (localhost [127.0.0.1])
	by gelk.kernelslacker.org (8.14.5/8.14.5) with ESMTP id q8RE3OjK000756
	for <netdev@vger.kernel.org>; Thu, 27 Sep 2012 10:03:24 -0400
Received: (from davej@localhost)
	by gelk.kernelslacker.org (8.14.5/8.14.5/Submit) id q8RE3N0N000755
	for netdev@vger.kernel.org; Thu, 27 Sep 2012 10:03:23 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Trinity bug of the day. I added some code to fabricate sockaddr's.
This seems to be the first casualty of that.


general protection fault: 0000 [#1] SMP 
Modules linked in: ipt_ULOG tun fuse binfmt_misc nfnetlink nfc caif_socket caif phonet can llc2 pppoe pppox ppp_generic slhc irda crc_ccitt rds af_key decnet rose x25 atm netrom appletalk ipx p8023 psnap p8022 llc ax25 lockd sunrpc bluetooth rfkill ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 ip6table_filter ip6_tables nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack kvm_intel kvm usb_debug crc32c_intel ghash_clmulni_intel microcode pcspkr i2c_i801 e1000e uinput i915 video i2c_algo_bit drm_kms_helper drm i2c_core
CPU 4 
Pid: 21651, comm: trinity-child4 Not tainted 3.6.0-rc7+ #55
RIP: 0010:[<ffffffff81628797>]  [<ffffffff81628797>] ip6_dst_lookup_tail+0x147/0x380
RSP: 0018:ffff8800144c3a48  EFLAGS: 00010286
RAX: 8000000000000011 RBX: ffff8800144c3b00 RCX: 0000000000000001
RDX: ffff8800144c2000 RSI: 0000000000000000 RDI: 0000000000000282
RBP: ffff8800144c3ae8 R08: 0000000000000014 R09: ffff8800034708c0
R10: ffffffff81c34a60 R11: 0000000000000000 R12: 0000000000000000
R13: ffff8800144c3bf0 R14: ffffffff81cd9580 R15: ffff8801052e4200
FS:  00007f74949af740(0000) GS:ffff880148400000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00000000051f7000 CR3: 00000000a8f72000 CR4: 00000000001407e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process trinity-child4 (pid: 21651, threadinfo ffff8800144c2000, task ffff880003470000)
Stack:
 ffffffff81628730 ffffffff810dafbf ffff880003470000 0000000000000000
 ffff8800144c3aa8 0000000000000282 ffff8800144c3aa8 ffff88013d79dd40
 ffff8801052e4200 0000000000000003 0000000000000001 0000000000000000
Call Trace:
 [<ffffffff81628730>] ? ip6_dst_lookup_tail+0xe0/0x380
 [<ffffffff810dafbf>] ? lock_release_holdtime.part.26+0xf/0x180
 [<ffffffff81556b20>] ? sock_def_wakeup+0x1b0/0x1b0
 [<ffffffff81628a9b>] ip6_sk_dst_lookup_flow+0xcb/0x1b0
 [<ffffffff81649d8d>] udpv6_sendmsg+0x6ad/0xc40
 [<ffffffff81023af9>] ? native_sched_clock+0x19/0x80
 [<ffffffff810db438>] ? trace_hardirqs_off_caller+0x28/0xd0
 [<ffffffff810db4ed>] ? trace_hardirqs_off+0xd/0x10
 [<ffffffff815e613a>] inet_sendmsg+0x12a/0x240
 [<ffffffff815e6010>] ? inet_create+0x6f0/0x6f0
 [<ffffffff815562a1>] ? sock_update_classid+0xb1/0x390
 [<ffffffff81556340>] ? sock_update_classid+0x150/0x390
 [<ffffffff8155115c>] sock_sendmsg+0xbc/0xf0
 [<ffffffff810b46c9>] ? local_clock+0x99/0xc0
 [<ffffffff810dff4f>] ? lock_release_non_nested+0x2df/0x320
 [<ffffffff810dafbf>] ? lock_release_holdtime.part.26+0xf/0x180
 [<ffffffff81553740>] sys_sendto+0x130/0x180
 [<ffffffff816af8ad>] system_call_fastpath+0x1a/0x1f
Code: c0 74 19 80 3d 0e 4d 6d 00 00 75 10 e8 73 cb af ff 85 c0 0f 85 e3 01 00 00 0f 1f 00 48 8b 03 48 8b 80 98 00 00 00 48 85 c0 74 09 <f6> 80 6d 01 00 00 de 74 48 e8 3b db a6 ff 85 c0 74 0d 80 3d d5 

The disassembly points here..

 983         rcu_read_lock();
 984         rt = (struct rt6_info *) *dst;
 985         n = rt->n;
 986         if (n && !(n->nud_state & NUD_VALID)) {
     db2:       48 85 c0                test   %rax,%rax
     db5:       74 09                   je     dc0 <ip6_dst_lookup_tail+0x150>
     db7:       f6 80 6d 01 00 00 de    testb  $0xde,0x16d(%rax)
     dbe:       74 48                   je     e08 <ip6_dst_lookup_tail+0x198>

'rt->n' is 0x8000000000000011, which looks like one of the garbage values trinity generates

	Dave
