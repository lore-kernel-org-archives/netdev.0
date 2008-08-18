From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: Re: [PATCH]: Schedule correct qdisc in watchdog.
Date: Mon, 18 Aug 2008 14:04:55 +0300
Message-ID: <200808181404.56131.denys@visp.net.lb>
References: <20080818091011.GC5434@ff.dom.local> <20080818103559.GA6548@ff.dom.local> <20080818104355.GB6548@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2.globalproof.net ([194.146.153.25]:59024 "EHLO
	relay2.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751473AbYHRLGJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Aug 2008 07:06:09 -0400
In-Reply-To: <20080818104355.GB6548@ff.dom.local>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Just to update. Current net-2.6 with [PATCH]: Schedule correct qdisc in watchdog. , for now only following warning appearing

[  177.061416]
[  177.061416] =============================================
[  177.061416] [ INFO: possible recursive locking detected ]
[  177.061416] 2.6.27-rc3-build-0031-12578-g96d2031-dirty #25
[  177.061416] ---------------------------------------------
[  177.061416] swapper/0 is trying to acquire lock:
[  177.061416]  (&list->lock#2){-+..}, at: [<c026191e>] dev_queue_xmit+0x31c/0x4a0
[  177.061416]
[  177.061416] but task is already holding lock:
[  177.061416]  (&list->lock#2){-+..}, at: [<c0260e5d>] netif_receive_skb+0x271/0x400
[  177.061416]
[  177.061416] other info that might help us debug this:
[  177.061416] 5 locks held by swapper/0:
[  177.061416]  #0:  (rcu_read_lock){..--}, at: [<c025f97b>] net_rx_action+0x54/0x1e5
[  177.061416]  #1:  (rcu_read_lock){..--}, at: [<c0260cf8>] netif_receive_skb+0x10c/0x400
[  177.061416]  #2:  (&list->lock#2){-+..}, at: [<c0260e5d>] netif_receive_skb+0x271/0x400
[  177.061416]  #3:  (&p->tcfc_lock){-+..}, at: [<e0a1b303>] tcf_mirred+0x1f/0x14c [act_mirred]
[  177.061416]  #4:  (rcu_read_lock){..--}, at: [<c0261782>] dev_queue_xmit+0x180/0x4a0
[  177.061416]
[  177.061416] stack backtrace:
[  177.061416] Pid: 0, comm: swapper Not tainted 2.6.27-rc3-build-0031-12578-g96d2031-dirty #25
[  177.061416]  [<c02ba6cf>] ? printk+0xf/0x18
[  177.061416]  [<c013ed12>] __lock_acquire+0xb3a/0x118a
[  177.061416]  [<c013f3aa>] lock_acquire+0x48/0x64
[  177.061416]  [<c026191e>] ? dev_queue_xmit+0x31c/0x4a0
[  177.061416]  [<c02bcba1>] _spin_lock+0x1b/0x2a
[  177.061416]  [<c026191e>] ? dev_queue_xmit+0x31c/0x4a0
[  177.061416]  [<c026191e>] dev_queue_xmit+0x31c/0x4a0
[  177.061416]  [<e0a1b40f>] tcf_mirred+0x12b/0x14c [act_mirred]
[  177.061416]  [<e0a1b2e4>] ? tcf_mirred+0x0/0x14c [act_mirred]
[  177.061416]  [<c02711bb>] tcf_action_exec+0x43/0x72
[  177.061416]  [<e0a4dcd5>] u32_classify+0xf4/0x20b [cls_u32]
[  177.061416]  [<c013dabf>] ? trace_hardirqs_on+0xb/0xd
[  177.061416]  [<c026ebb9>] tc_classify_compat+0x2e/0x5d
[  177.061416]  [<c026ed01>] tc_classify+0x17/0x72
[  177.061416]  [<e0a530b2>] ingress_enqueue+0x1a/0x54 [sch_ingress]
[  177.061416]  [<c0260e7d>] netif_receive_skb+0x291/0x400
[  177.061416]  [<c013dabf>] ? trace_hardirqs_on+0xb/0xd
[  177.061416]  [<c0261060>] process_backlog+0x74/0xcb
[  177.061416]  [<c025f9e2>] net_rx_action+0xbb/0x1e5
[  177.061416]  [<c0126203>] __do_softirq+0x7b/0xf4
[  177.061416]  [<c0126188>] ? __do_softirq+0x0/0xf4
[  177.061416]  [<c01060b3>] do_softirq+0x65/0xb6
[  177.061416]  [<c014a35d>] ? handle_fasteoi_irq+0x0/0xb6
[  177.061416]  [<c0125e28>] irq_exit+0x44/0x79
[  177.061416]  [<c0106038>] do_IRQ+0xae/0xc4
[  177.061416]  [<c0104288>] common_interrupt+0x28/0x30
[  177.061416]  [<c013007b>] ? find_get_pid+0x2e/0x4d
[  177.061416]  [<c0108dc6>] ? default_idle+0x32/0x51
[  177.061416]  [<c01029ee>] cpu_idle+0xbf/0xe1
[  177.061416]  [<c02afefa>] rest_init+0x4e/0x50
[  177.061416]  =======================

On Monday 18 August 2008, Jarek Poplawski wrote:
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


