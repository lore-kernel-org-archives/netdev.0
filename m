From: Sander Eikelenboom <linux@eikelenboom.it>
Subject: [167986.379006] WARNING: at net/core/skbuff.c:3444 skb_try_coalesce+0x359/0x390()
Date: Wed, 28 Nov 2012 20:52:33 +0100
Message-ID: <1916318379.20121128205233@eikelenboom.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from static.121.164.40.188.clients.your-server.de ([188.40.164.121]:57464
	"EHLO smtp.eikelenboom.it" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755841Ab2K1Twj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Nov 2012 14:52:39 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On one of my virtual machines i got this splat(running a 3.7.0-rc7):


[167986.378985] ------------[ cut here ]------------
[167986.379006] WARNING: at net/core/skbuff.c:3444 skb_try_coalesce+0x359/0x390()
[167986.379012] Modules linked in:
[167986.379021] Pid: 3231, comm: apache2 Not tainted 3.7.0-rc7-20121126-persistent #1
[167986.379028] Call Trace:
[167986.379032]  <IRQ>  [<ffffffff8106762a>] warn_slowpath_common+0x7a/0xb0
[167986.379047]  [<ffffffff8106f8b5>] ? local_bh_enable+0xb5/0x160
[167986.379053]  [<ffffffff81067675>] warn_slowpath_null+0x15/0x20
[167986.379059]  [<ffffffff816a4879>] skb_try_coalesce+0x359/0x390
[167986.379067]  [<ffffffff8175bdb9>] tcp_try_coalesce+0x69/0xc0
[167986.379073]  [<ffffffff8175be64>] tcp_queue_rcv+0x54/0x100
[167986.379079]  [<ffffffff8176023f>] ? tcp_rcv_state_process+0x84f/0xc70
[167986.379086]  [<ffffffff8176091b>] tcp_rcv_established+0x2bb/0x6a0
[167986.379093]  [<ffffffff8176903f>] ? tcp_v4_rcv+0x6cf/0xb10
[167986.379098]  [<ffffffff81768625>] tcp_v4_do_rcv+0x135/0x480
[167986.379106]  [<ffffffff8180db82>] ? _raw_spin_lock_nested+0x42/0x50
[167986.379112]  [<ffffffff8176903f>] ? tcp_v4_rcv+0x6cf/0xb10
[167986.379118]  [<ffffffff817692cd>] tcp_v4_rcv+0x95d/0xb10
[167986.379125]  [<ffffffff810b24f8>] ? lock_acquire+0xd8/0x100
[167986.379133]  [<ffffffff81745aa5>] ? ip_local_deliver_finish+0x45/0x230
[167986.379140]  [<ffffffff81745b7a>] ip_local_deliver_finish+0x11a/0x230
[167986.379149]  [<ffffffff81745aa5>] ? ip_local_deliver_finish+0x45/0x230
[167986.379156]  [<ffffffff81745cc8>] ip_local_deliver+0x38/0x80
[167986.379162]  [<ffffffff8174528a>] ip_rcv_finish+0x15a/0x630
[167986.379169]  [<ffffffff81745978>] ip_rcv+0x218/0x300
[167986.379176]  [<ffffffff816adc9d>] __netif_receive_skb+0x65d/0x8d0
[167986.379182]  [<ffffffff816ad785>] ? __netif_receive_skb+0x145/0x8d0
[167986.379189]  [<ffffffff810ae6ed>] ? trace_hardirqs_on+0xd/0x10
[167986.379197]  [<ffffffff810fb243>] ? free_hot_cold_page+0x1b3/0x1e0
[167986.379204]  [<ffffffff816b01f8>] netif_receive_skb+0x28/0xf0
[167986.379210]  [<ffffffff816a5d13>] ? __pskb_pull_tail+0x253/0x340
[167986.400668]  [<ffffffff814b5945>] xennet_poll+0xad5/0xe10
[167986.400679]  [<ffffffff816b0fa6>] net_rx_action+0x136/0x260
[167986.400692]  [<ffffffff8106f4f1>] ? __do_softirq+0x71/0x1a0
[167986.400698]  [<ffffffff8106f549>] __do_softirq+0xc9/0x1a0
[167986.400705]  [<ffffffff818106fc>] call_softirq+0x1c/0x30
[167986.400709]  <EOI>  [<ffffffff8100fd95>] do_softirq+0x85/0xf0
[167986.400721]  [<ffffffff8174c666>] ? ip_finish_output+0x246/0x530
[167986.400727]  [<ffffffff8106f953>] local_bh_enable+0x153/0x160
[167986.400733]  [<ffffffff8174c666>] ip_finish_output+0x246/0x530
[167986.400739]  [<ffffffff8174c4ed>] ? ip_finish_output+0xcd/0x530
[167986.400749]  [<ffffffff8174c9a9>] ip_output+0x59/0xe0
[167986.400755]  [<ffffffff8174b4c8>] ip_local_out+0x28/0x90
[167986.400760]  [<ffffffff8174ba7f>] ip_queue_xmit+0x17f/0x4a0
[167986.400766]  [<ffffffff8174b900>] ? ip_send_unicast_reply+0x340/0x340
[167986.400773]  [<ffffffff810a1ed7>] ? getnstimeofday+0x47/0xe0
[167986.400779]  [<ffffffff816a24c9>] ? __skb_clone+0x29/0x120
[167986.400786]  [<ffffffff81761ba0>] tcp_transmit_skb+0x400/0x8d0
[167986.400793]  [<ffffffff81764b8c>] tcp_write_xmit+0x22c/0xa70
[167986.400799]  [<ffffffff8176543d>] __tcp_push_pending_frames+0x2d/0x90
[167986.400809]  [<ffffffff8175577d>] tcp_sendmsg+0x17d/0xe10
[167986.400816]  [<ffffffff8177c0c9>] inet_sendmsg+0xa9/0x100
[167986.400822]  [<ffffffff8177c020>] ? inet_autobind+0x70/0x70
[167986.400829]  [<ffffffff816991d0>] ? sock_destroy_inode+0x40/0x40
[167986.400835]  [<ffffffff816992fd>] sock_aio_write+0x12d/0x140
[167986.400842]  [<ffffffff81144ceb>] do_sync_readv_writev+0x9b/0xe0
[167986.400849]  [<ffffffff8114539f>] do_readv_writev+0xcf/0x1d0
[167986.400855]  [<ffffffff811454de>] vfs_writev+0x3e/0x60
[167986.400861]  [<ffffffff8114562a>] sys_writev+0x5a/0xc0
[167986.400871]  [<ffffffff812b639e>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[167986.400878]  [<ffffffff8180f469>] system_call_fastpath+0x16/0x1b
[167986.400884] ---[ end trace 2f73b807ee74fc5a ]---
