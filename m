From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [bug, netconsole, SLUB] BUG skbuff_head_cache: Poison
	overwritten
Date: Fri, 18 Jul 2008 02:01:30 +0200
Message-ID: <20080718000130.GA24013@elte.hu>
References: <20080717214222.GA29449@elte.hu> <19f34abd0807171615s5b477d4cr22d3e9444bcf65df@mail.gmail.com> <20080717235254.GA6833@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Pekka Enberg <penberg@cs.helsinki.fi>,
	"Rafael J. Wysocki" <rjw@sisk.pl>
To: Vegard Nossum <vegard.nossum@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:56333 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760167AbYGRACA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Jul 2008 20:02:00 -0400
Content-Disposition: inline
In-Reply-To: <20080717235254.GA6833@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


two other ones:

kmemcheck: Caught 32-bit read from uninitialized memory (f459ac00)
uuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuu
^

Pid: 1614, comm: kjournald Not tainted (2.6.26-tip #20187)
EIP: 0060:[<c05ea904>] EFLAGS: 00010216 CPU: 0
EIP is at skb_copy_bits+0x54/0x220
EAX: 00000110 EBX: 00000110 ECX: 00000044 EDX: f6c256c0
ESI: f459ac00 EDI: f459a000 EBP: c09b9f60 ESP: c09de048
 DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
CR0: 8005003b CR2: f71c2700 CR3: 2e849000 CR4: 000006d0
DR0: 00000000 DR1: 00000000 DR2: 00000000 DR3: 00000000
DR6: ffff4ff0 DR7: 00000400
 [<c05ebe28>] skb_copy+0x78/0x90
 [<c05f9426>] neigh_timer_handler+0x156/0x2c0
 [<c012ba62>] run_timer_softirq+0x142/0x180
 [<c0129092>] __do_softirq+0x82/0xf0
 [<c0105b8a>] call_on_stack+0x1a/0x30
 [<ffffffff>] 0xffffffff


plus:

kmemcheck: Caught 32-bit read from uninitialized memory (f654b590)
iiiiiiiiiiiiiiiiuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuu
                ^

Pid: 3130, comm: git-read-tree Not tainted (2.6.26-tip #20187)
EIP: 0060:[<c05eb396>] EFLAGS: 00010286 CPU: 0
EIP is at pskb_expand_head+0x86/0x150
EAX: 00000140 EBX: f6763124 ECX: 00000027 EDX: f6549400
ESI: f654b590 EDI: f6549650 EBP: c09b9a80 ESP: c09dfa28
 DS: 007b ES: 007b FS: 00d8 GS: 0033 SS: 0068
CR0: 8005003b CR2: f71c2700 CR3: 2e849000 CR4: 000006d0
DR0: 00000000 DR1: 00000000 DR2: 00000000 DR3: 00000000
DR6: ffff4ff0 DR7: 00000400
 [<c05eb67d>] __pskb_pull_tail+0x21d/0x300
 [<c03b45dd>] e1000_xmit_frame+0x1fd/0xa60
 [<c05f0fd4>] dev_hard_start_xmit+0x254/0x2e0
 [<c0609721>] __qdisc_run+0x61/0x1b0
 [<c05f383e>] dev_queue_xmit+0x25e/0x340
 [<c061f315>] ip_finish_output+0x105/0x260
 [<c061f739>] ip_output+0x49/0x50
 [<c061debd>] ip_local_out+0x1d/0x30
 [<c061fa85>] ip_queue_xmit+0x1a5/0x340
 [<c062ffd3>] tcp_transmit_skb+0x443/0x800
 [<c06316aa>] __tcp_push_pending_frames+0xfa/0x730
 [<c062ee58>] tcp_rcv_established+0x3b8/0x6f0
 [<c0634f50>] tcp_v4_do_rcv+0x2d0/0x510
 [<c063720e>] tcp_v4_rcv+0x58e/0x660
 [<c061b5ac>] ip_local_deliver+0x4c/0x180
 [<c061b99e>] ip_rcv+0x2be/0x570
 [<c05f08d3>] netif_receive_skb+0x333/0x400
 [<c03b2aa7>] e1000_receive_skb+0x47/0x180
 [<c03b3983>] e1000_clean_rx_irq+0x223/0x2e0
 [<c03b225b>] e1000_clean+0x5b/0x200
 [<c05f29db>] net_rx_action+0xfb/0x160
 [<c0129092>] __do_softirq+0x82/0xf0
 [<c0105b8a>] call_on_stack+0x1a/0x30
 [<ffffffff>] 0xffffffff

again, from the RX path, likely false positives. We've got to fix these 
false positives to make automated debugging easier.

	Ingo
