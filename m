From: Dave Jones <davej@redhat.com>
Subject: ip6_dst_lookup_tail oops
Date: Wed, 16 Jan 2013 09:55:07 -0500
Message-ID: <20130116145507.GA12244@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:5833 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751944Ab3APPwY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Jan 2013 10:52:24 -0500
Received: from int-mx01.intmail.prod.int.phx2.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id r0GFqJHH003583
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Wed, 16 Jan 2013 10:52:24 -0500
Received: from gelk.kernelslacker.org (ovpn-113-149.phx2.redhat.com [10.3.113.149])
	by int-mx01.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with ESMTP id r0GEt9MH030894
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Wed, 16 Jan 2013 09:55:13 -0500
Received: from gelk.kernelslacker.org (localhost [127.0.0.1])
	by gelk.kernelslacker.org (8.14.5/8.14.5) with ESMTP id r0GEt8Vn019842
	for <netdev@vger.kernel.org>; Wed, 16 Jan 2013 09:55:08 -0500
Received: (from davej@localhost)
	by gelk.kernelslacker.org (8.14.5/8.14.5/Submit) id r0GEt7un019841
	for netdev@vger.kernel.org; Wed, 16 Jan 2013 09:55:07 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hit this after around 36 hours of fuzzing.

BUG: unable to handle kernel NULL pointer dereference at 000000000000017e
IP: [<ffffffff81626308>] ip6_dst_lookup_tail+0xe8/0x200
PGD be5fe067 PUD 93459067 PMD 0 
Oops: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
Modules linked in: fuse l2tp_ppp l2tp_core 8021q garp bridge stp dlci binfmt_misc hidp bnep rfcomm ipt_ULOG scsi_transport_iscsi can_raw nfnetlink can_bcm can llc2 af_key netrom af_rxrpc phonet rose caif_socket caif pppoe pppox ax25 nfc ppp_generic decnet appletalk slhc ipx irda p8023 atm psnap x25 crc_ccitt p8022 llc lockd sunrpc ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 xt_conntrack nf_conntrack ip6table_filter ip6_tables btusb bluetooth snd_hda_codec_realtek snd_hda_intel snd_hda_codec usb_debug rfkill microcode snd_pcm snd_page_alloc serio_raw snd_timer snd pcspkr edac_core soundcore r8169 mii vhost_net tun macvtap macvlan kvm_amd kvm
CPU 2 
Pid: 10098, comm: trinity-child2 Not tainted 3.8.0-rc3+ #52 Gigabyte Technology Co., Ltd. GA-MA78GM-S2H/GA-MA78GM-S2H
RIP: 0010:[<ffffffff81626308>]  [<ffffffff81626308>] ip6_dst_lookup_tail+0xe8/0x200
RSP: 0018:ffff88008b5b3978  EFLAGS: 00010206
RAX: 0000000000000011 RBX: 0000000000000000 RCX: 0000000000000000
RDX: ffff88008b5b3b10 RSI: ffff880124067600 RDI: ffff880065013800
RBP: ffff88008b5b3a08 R08: 0000000000000001 R09: 0000000000000000
R10: 0000000000000001 R11: 0000000000000000 R12: ffff88008b5b3a20
R13: ffff88008b5b3b10 R14: ffff880065013800 R15: ffffffff81cb1980
FS:  00007fd98131d740(0000) GS:ffff88012f200000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 000000000000017e CR3: 000000009bef5000 CR4: 00000000000007e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process trinity-child2 (pid: 10098, threadinfo ffff88008b5b2000, task ffff880089e3a490)
Stack:
 ffff880065013800 0000000000000002 0000000000000001 0000000000000000
 ffff88008b5b39a8 ffffffff81332a28 ffff88008b5b39c8 ffffffff8106bdfc
 0000000000000001 ffff880124067600 ffff88008b5b3a08 0000000086d9021e
Call Trace:
 [<ffffffff81332a28>] ? __const_udelay+0x28/0x30
 [<ffffffff8106bdfc>] ? __rcu_read_unlock+0x5c/0xa0
 [<ffffffff8154f065>] ? sk_dst_check+0x5/0x260
 [<ffffffff816266cb>] ip6_sk_dst_lookup_flow+0xcb/0x1b0
 [<ffffffff8164803e>] udpv6_sendmsg+0x66e/0xb80
 [<ffffffff81332a28>] ? __const_udelay+0x28/0x30
 [<ffffffff8106bdfc>] ? __rcu_read_unlock+0x5c/0xa0
 [<ffffffff815e6391>] inet_sendmsg+0x111/0x220
 [<ffffffff815e6285>] ? inet_sendmsg+0x5/0x220
 [<ffffffff81547220>] sock_sendmsg+0xb0/0xe0
 [<ffffffff810b228e>] ? put_lock_stats.isra.23+0xe/0x40
 [<ffffffff810b73a7>] ? lock_release_non_nested+0x2b7/0x2f0
 [<ffffffff815486bc>] __sys_sendmsg+0x3ac/0x3c0
 [<ffffffff810b1ef8>] ? trace_hardirqs_off_caller+0x28/0xc0
 [<ffffffff810b1e22>] ? get_lock_stats+0x22/0x70
 [<ffffffff810b228e>] ? put_lock_stats.isra.23+0xe/0x40
 [<ffffffff8100a1b6>] ? native_sched_clock+0x26/0x90
 [<ffffffff810b1ef8>] ? trace_hardirqs_off_caller+0x28/0xc0
 [<ffffffff8104c494>] ? do_setitimer+0x1c4/0x300
 [<ffffffff810b228e>] ? put_lock_stats.isra.23+0xe/0x40
 [<ffffffff811cbe3a>] ? fget_light+0x3ca/0x500
 [<ffffffff810b830d>] ? trace_hardirqs_on+0xd/0x10
 [<ffffffff8154afb9>] sys_sendmsg+0x49/0x90
 [<ffffffff816a6802>] system_call_fastpath+0x16/0x1b
Code: 00 00 48 8b 5d d8 4c 8b 65 e0 4c 8b 6d e8 4c 8b 75 f0 4c 8b 7d f8 c9 c3 0f 1f 00 49 8b 34 24 48 8b 86 98 00 00 00 48 85 c0 74 c2 <f6> 80 6d 01 00 00 de 75 b9 48 8b 56 18 49 8d 75 24 b9 01 00 00 
RIP  [<ffffffff81626308>] ip6_dst_lookup_tail+0xe8/0x200
 RSP <ffff88008b5b3978>
CR2: 000000000000017e
---[ end trace 439801e1c30eed47 ]---


   0:	f6 80 6d 01 00 00 de 	testb  $0xde,0x16d(%rax)
   7:	75 b9                	jne    0xffffffffffffffc2
   9:	48 8b 56 18          	mov    0x18(%rsi),%rdx
   d:	49 8d 75 24          	lea    0x24(%r13),%rsi
  11:	b9                   	.byte 0xb9
  12:	01 00                	add    %eax,(%rax)
	...

This looks like the GPF in this function I reported last September.
http://www.spinics.net/lists/netdev/msg211894.html

In those reports, I ended up with an rt->n == 0x8000000000000011,
but this time, it's just 0x11.

	Dave
