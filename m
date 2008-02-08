From: Alexey Dobriyan <adobriyan@sw.ru>
Subject: 2.6.24?: WARNING: at net/core/dev.c: skb_gso_segment()
Date: Fri, 8 Feb 2008 19:00:10 +0300
Message-ID: <20080208160010.GC29127@localhost.sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:35285 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756881AbYBHQAO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Feb 2008 11:00:14 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

FYI, this happened several times with OpenVZ kernel here, though one user
reported against v2.6.24 but without calltrace:
http://marc.info/?l=linux-kernel&m=120155594432027&w=2
Anyway...


Driver is tg3.

[  403.240511] WARNING: at net/core/dev.c:1407 skb_gso_segment()

	if (WARN_ON(skb->ip_summed != CHECKSUM_PARTIAL)) {

[  403.240653] Pid: 6114, comm: bash Tainted:  G   M    2.6.24-openvz #30
[  403.240779] 
[  403.240781] Call Trace:
[  403.240987]  <IRQ>  [<ffffffff8041a81b>] skb_gso_segment+0x19b/0x250
[  403.241194]  [<ffffffff8041aae9>] dev_hard_start_xmit+0x219/0x2d0
[  403.241318]  [<ffffffff8041d6c5>] dev_queue_xmit+0x2b5/0x370
[  403.241440]  [<ffffffff804404a3>] ip_queue_xmit+0x323/0x4c0
[  403.241565]  [<ffffffff802a72d9>] init_object+0x89/0xa0
[  403.241684]  [<ffffffff802aa814>] __slab_alloc+0x394/0x3f0
[  403.241805]  [<ffffffff80454ddd>] tso_fragment+0x7d/0x260
[  403.241927]  [<ffffffff80454ddd>] tso_fragment+0x7d/0x260
[  403.242048]  [<ffffffff80453226>] tcp_transmit_skb+0x526/0x950
[  403.242170]  [<ffffffff80454ec8>] tso_fragment+0x168/0x260
[  403.242290]  [<ffffffff80455105>] __tcp_push_pending_frames+0x145/0x9a0
[  403.242415]  [<ffffffff802a8b2c>] __slab_free+0x9c/0x2d0
[  403.242533]  [<ffffffff80451fd1>] tcp_rcv_established+0x481/0x880
[  403.242657]  [<ffffffff80451ff1>] tcp_rcv_established+0x4a1/0x880
[  403.242783]  [<ffffffff80459c4b>] tcp_v4_do_rcv+0x3ab/0x790
[  403.242904]  [<ffffffff80437123>] ip_route_input+0x153/0x1200
[  403.243044]  [<ffffffff8045cecd>] tcp_v4_rcv+0xa0d/0xb60
[  403.243165]  [<ffffffff8043a8cd>] ip_local_deliver_finish+0xfd/0x2c0
[  403.243288]  [<ffffffff8043a458>] ip_rcv_finish+0x128/0x4a0
[  403.243409]  [<ffffffff8041a266>] netif_receive_skb+0x2e6/0x390
[  403.243531]  [<ffffffff8041d005>] process_backlog+0x85/0xf0
[  403.243654]  [<ffffffff8041cd40>] net_rx_action+0x170/0x200
[  403.243777]  [<ffffffff802422d9>] __do_softirq+0xb9/0x160
[  403.243898]  [<ffffffff8020d17c>] call_softirq+0x1c/0x30
[  403.244017]  [<ffffffff8020f645>] do_softirq+0x55/0xb0
[  403.244134]  [<ffffffff80242215>] irq_exit+0xe5/0xf0
[  403.244252]  [<ffffffff8020f720>] do_IRQ+0x80/0x100
[  403.244368]  [<ffffffff8020c476>] ret_from_intr+0x0/0xf
[  403.244489]  <EOI>

