From: Ingo Molnar <mingo@elte.hu>
Subject: [regression] nf_iterate(), BUG: unable to handle kernel NULL
	pointer dereference
Date: Thu, 24 Jul 2008 13:56:25 +0200
Message-ID: <20080724115625.GA23994@elte.hu>
References: <20080724060448.GA10203@elte.hu> <E1KLwlD-0001Ub-00@gondolin.me.apana.org.au> <20080724.022259.113079007.davem@davemloft.net> <20080724093411.GA12001@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, w@1wt.eu, davidn@davidnewall.com,
	torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	stefanr@s5r6.in-berlin.de, rjw@sisk.pl, ilpo.jarvinen@helsinki.fi,
	Dave Jones <davej@redhat.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:36852 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756719AbYGXL53 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Jul 2008 07:57:29 -0400
Content-Disposition: inline
In-Reply-To: <20080724093411.GA12001@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


here's a new type of crash a -tip testbox triggered today:

BUG: unable to handle kernel NULL pointer dereference at 0000000000000000
IP: [<0000000000000000>] 0x0
PGD 0 
Oops: 0010 [1] PREEMPT 
CPU 0 
Pid: 5331, comm: ssh Not tainted 2.6.26 #21613
RIP: 0010:[<0000000000000000>]  [<0000000000000000>] 0x0
RSP: 0018:ffff88003b959a70  EFLAGS: 00010217
RAX: ffff88003b9ba91c RBX: ffff88003b9baac0 RCX: 0000000000000002
RDX: ffff88003b9baac0 RSI: 0000000000000014 RDI: ffff88003b9ba3d8
RBP: ffff88003b959a98 R08: ffff88003e434130 R09: ffff88003b9598b8
R10: 0000000000002000 R11: 00000000d85507ac R12: ffff88003b9ba3d8
R13: 0000000000000002 R14: ffff88003e06a020 R15: 0000000000000000
FS:  00007fb2b7806780(0000) GS:ffffffff80c1c180(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 0000000000000000 CR3: 000000003b9e8000 CR4: 00000000000006a0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process ssh (pid: 5331, threadinfo ffff88003b958000, task ffff88003b99a000)
Stack:  ffffffff80777f25 ffff88003b959a98 ffffffff80c24170 ffff88003b959b28
 0000000000000004 ffff88003b959ae8 ffffffff80733107 ffff88003b959ab8
 ffff88003b9ba3d8 ffffffff80c1ed60 0000000000000004 ffff88003b9ba3d8
Call Trace:
 [<ffffffff80777f25>] ? ipv4_confirm+0x8d/0x122
 [<ffffffff80733107>] nf_iterate+0x43/0xa5
 [<ffffffff8074bbb2>] ? ip_finish_output+0x0/0x62
 [<ffffffff807331cd>] nf_hook_slow+0x64/0xcb
 [<ffffffff8074bbb2>] ? ip_finish_output+0x0/0x62
 [<ffffffff8074b63b>] nf_hook_thresh+0x1e/0x20
 [<ffffffff8074bd44>] ip_output+0xb3/0xc9
 [<ffffffff8074a27e>] dst_output+0xb/0xd
 [<ffffffff8074b6ef>] ip_local_out+0x1e/0x22
 [<ffffffff8074c75c>] ip_queue_xmit+0x2a6/0x321
 [<ffffffff80241961>] ? sub_preempt_count+0x2d/0x40
 [<ffffffff8028f239>] ? slob_alloc+0x11b/0x248
 [<ffffffff8075b85a>] tcp_transmit_skb+0x5ec/0x61b
 [<ffffffff807122b6>] ? kmalloc+0xc/0xe
 [<ffffffff8075d7ae>] tcp_connect+0x2a4/0x344
 [<ffffffff80760cf1>] tcp_v4_connect+0x3cd/0x425
 [<ffffffff8076bc7d>] inet_stream_connect+0x9a/0x24d
 [<ffffffff80292988>] ? fget_light+0x38/0x85
 [<ffffffff8070c60c>] sys_connect+0x68/0x8b
 [<ffffffff8025dfab>] ? up_read+0x9/0xb
 [<ffffffff8023727c>] ? do_page_fault+0x55f/0x92f
 [<ffffffff8022479a>] system_call_fastpath+0x16/0x1b

with this config:

  http://redhat.com/~mingo/misc/config-Thu_Jul_24_13_23_34_CEST_2008.bad

i'll try a bisection.

	Ingo
