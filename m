From: Brad Fitzpatrick <brad@danga.com>
Subject: e1000, 2.6.9: swapper: page allocation failure. order:1, mode:0x20
Date: Tue, 7 Dec 2004 11:18:04 -0800 (PST)
Message-ID: <Pine.LNX.4.58.0412071111500.10145@danga.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <linux-net-owner@vger.kernel.org>
To: linux-net@vger.kernel.org, netdev@oss.sgi.com
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

On a busy database server I'm getting tons of these w/ 2.6.9 and e1000, no
NAPI, no jumbo frames:

swapper: page allocation failure. order:1, mode:0x20
 [<c0130169>] __alloc_pages+0x2e9/0x30c
 [<c0274182>] e1000_xmit_frame+0x816/0x820
 [<c01301a9>] __get_free_pages+0x1d/0x30
 [<c013320a>] kmem_getpages+0x26/0xd4
 [<c0133e67>] cache_grow+0xb3/0x148
 [<c01340aa>] cache_alloc_refill+0x1ae/0x1fc
 [<c01342cb>] kmem_cache_alloc+0x43/0x4c
 [<c02d4b0e>] sk_alloc+0x26/0x98
 [<c030591c>] tcp_create_openreq_child+0x24/0x538
 [<c0302920>] tcp_v4_syn_recv_sock+0x4c/0x2d8
 [<c030606f>] tcp_check_req+0x23f/0x3e0
 [<c0274182>] e1000_xmit_frame+0x816/0x820
 [<c02eccb6>] ip_output+0x76/0x7c
 [<c02e3f37>] qdisc_restart+0x1f/0x1e8
 [<c02dafd8>] dev_queue_xmit+0x234/0x244
 [<c02ecadd>] ip_finish_output+0x165/0x1b0
 [<c02eccb6>] ip_output+0x76/0x7c
 [<c02ed065>] ip_queue_xmit+0x3a9/0x428
 [<c01114e4>] recalc_task_prio+0x128/0x138
 [<c0111593>] activate_task+0x9f/0xb0
 [<c01114e4>] recalc_task_prio+0x128/0x138
 [<c0111593>] activate_task+0x9f/0xb0
 [<c01114e4>] recalc_task_prio+0x128/0x138
 [<c0111593>] activate_task+0x9f/0xb0
 [<c01119b6>] try_to_wake_up+0x25a/0x268
 [<c011302f>] default_wake_function+0x17/0x1c
 [<c011302f>] default_wake_function+0x17/0x1c
 [<c0302bde>] tcp_v4_hnd_req+0x32/0x190
 [<c0302bf8>] tcp_v4_hnd_req+0x4c/0x190
 [<c0302eff>] tcp_v4_do_rcv+0xbb/0x120
 [<c0302ed8>] tcp_v4_do_rcv+0x94/0x120
 [<c03033fd>] tcp_v4_rcv+0x499/0x758
 [<c02e8843>] ip_route_input+0x33/0x140
 [<c02ea254>] ip_local_deliver+0x9c/0x13c
 [<c02ea641>] ip_rcv+0x34d/0x3ec
 [<c02db495>] netif_receive_skb+0x149/0x180
 [<c02db551>] process_backlog+0x85/0x114
 [<c02db660>] net_rx_action+0x80/0x128
 [<c011a0ea>] __do_softirq+0x6a/0xd4
 [<c011a17c>] do_softirq+0x28/0x30
 [<c010649a>] do_IRQ+0x10e/0x124
 [<c0104710>] common_interrupt+0x18/0x20
 [<c0102149>] default_idle+0x29/0x34
 [<c01021cc>] cpu_idle+0x30/0x44
 [<c010042f>] rest_init+0x47/0x48
 [<c044c7f9>] start_kernel+0x161/0x168

>From following lists, I read this as e1000 in interrupt context tried
to allocate two contiguous pages without sleeping, and the "emergency
pools" or whatnot weren't full enough?

We're not using jumbo frames, ... what is e1000 allocating 8k for?
(or am I misreading this?)

Also not using TSO, unless it's the default again in 2.6.9.

What should I tune to avoid this from happening?

Thanks!
Brad
