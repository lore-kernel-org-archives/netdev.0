From: "Denys Fedoryshchenko" <denys@visp.net.lb>
Subject: Re: circular locking, mirred, 2.6.24.2
Date: Wed, 5 Mar 2008 12:45:51 +0200
Message-ID: <20080305103935.M76165@visp.net.lb>
References: <20080224222035.M62480@visp.net.lb> <20080225095646.GA4321@ff.dom.local> <20080225104652.M2446@visp.net.lb> <20080225113930.GA4733@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=koi8-r
Cc: netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usermail.globalproof.net ([194.146.153.18]:51435 "EHLO
	usermail.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758851AbYCEKqG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Mar 2008 05:46:06 -0500
In-Reply-To: <20080225113930.GA4733@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I did test on vanilla 2.6.25-rc3, on clean Gentoo distro and got 
similar message. The strange thing, message appeared not immediately after 
launching script, but after few seconds.

Scripts is the same. I have same message on another script, used for ppp 
shaper.

[   10.536424] =======================================================
[   10.536424] [ INFO: possible circular locking dependency detected ]
[   10.536424] 2.6.25-rc3-devel #3
[   10.536424] -------------------------------------------------------
[   10.536424] swapper/0 is trying to acquire lock:
[   10.536424]  (&dev->queue_lock){-+..}, at: [<c0299b4a>] 
dev_queue_xmit+0x175/0x2f3
[   10.536424]
[   10.536424] but task is already holding lock:
[   10.536424]  (&p->tcfc_lock){-+..}, at: [<f8a67154>] tcf_mirred+0x20/0x178 
[act_mirred]
[   10.536424]
[   10.536424] which lock already depends on the new lock.
[   10.536424]
[   10.536424]
[   10.536424] the existing dependency chain (in reverse order) is:
[   10.536424]
[   10.536424] -> #2 (&p->tcfc_lock){-+..}:
[   10.536424]        [<c013efb6>] __lock_acquire+0x963/0xb18
[   10.536424]        [<f8a67154>] tcf_mirred+0x20/0x178 [act_mirred]
[   10.536424]        [<c013f1d7>] lock_acquire+0x6c/0x89
[   10.536424]        [<f8a67154>] tcf_mirred+0x20/0x178 [act_mirred]
[   10.536424]        [<c02f6927>] _spin_lock+0x1c/0x49
[   10.536424]        [<f8a67154>] tcf_mirred+0x20/0x178 [act_mirred]
[   10.536424]        [<f8a67134>] tcf_mirred+0x0/0x178 [act_mirred]
[   10.536424]        [<f8a67154>] tcf_mirred+0x20/0x178 [act_mirred]
[   10.536424]        [<c010b2ce>] save_stack_address+0x0/0x28
[   10.536424]        [<f8a67134>] tcf_mirred+0x0/0x178 [act_mirred]
[   10.536424]        [<c02a7018>] tcf_action_exec+0x44/0x77
[   10.536424]        [<f89927b0>] u32_classify+0x119/0x24e [cls_u32]
[   10.536424]        [<c013f123>] __lock_acquire+0xad0/0xb18
[   10.536424]        [<c02a5006>] tc_classify_compat+0x2f/0x5e
[   10.536424]        [<c02a5d1c>] tc_classify+0x17/0x78
[   10.536424]        [<f89670a4>] ingress_enqueue+0x1a/0x53 [sch_ingress]
[   10.536424]        [<c0297009>] netif_receive_skb+0x263/0x3e6
[   10.536424]        [<f882b4d9>] e1000_clean_rx_irq+0x380/0x448 [e1000]
[   10.536424]        [<f8828e1e>] e1000_clean+0x62/0x1fd [e1000]
[   10.536424]        [<c029926f>] net_rx_action+0xb3/0x19e
[   10.536424]        [<c01276f7>] __do_softirq+0x6f/0xe9
[   10.536424]        [<c0106aa7>] do_softirq+0x5e/0xa8
[   10.536424]        [<ffffffff>] 0xffffffff
[   10.536424]
[   10.536424] -> #1 (&dev->ingress_lock){-+..}:
[   10.536424]        [<c013efb6>] __lock_acquire+0x963/0xb18
[   10.536424]        [<c02a4718>] qdisc_lock_tree+0x1e/0x21
[   10.536424]        [<c013f1d7>] lock_acquire+0x6c/0x89
[   10.536424]        [<c02a4718>] qdisc_lock_tree+0x1e/0x21
[   10.536424]        [<c02f6927>] _spin_lock+0x1c/0x49
[   10.536424]        [<c02a4718>] qdisc_lock_tree+0x1e/0x21
[   10.536424]        [<c02a4718>] qdisc_lock_tree+0x1e/0x21
[   10.536424]        [<c02a4747>] dev_init_scheduler+0xb/0x4d
[   10.536424]        [<c0298299>] register_netdevice+0x288/0x2e2
[   10.536424]        [<c0298325>] register_netdev+0x32/0x3f
[   10.536424]        [<c042a867>] loopback_net_init+0x34/0x63
[   10.536424]        [<c0295b3f>] register_pernet_operations+0x13/0x15
[   10.536424]        [<c0295ba8>] register_pernet_device+0x1f/0x4c
[   10.536424]        [<c042a831>] loopback_init+0xd/0xf
[   10.536424]        [<c0415478>] kernel_init+0x132/0x27c
[   10.536424]        [<c0415346>] kernel_init+0x0/0x27c
[   10.536424]        [<c0415346>] kernel_init+0x0/0x27c
[   10.536424]        [<c01056bf>] kernel_thread_helper+0x7/0x10
[   10.536424]        [<ffffffff>] 0xffffffff
[   10.536424]
[   10.536424] -> #0 (&dev->queue_lock){-+..}:
[   10.536424]        [<c013d169>] print_circular_bug_tail+0x2e/0x66
[   10.536424]        [<c013eedd>] __lock_acquire+0x88a/0xb18
[   10.536424]        [<c013f1d7>] lock_acquire+0x6c/0x89
[   10.536424]        [<c0299b4a>] dev_queue_xmit+0x175/0x2f3
[   10.536424]        [<c02f6927>] _spin_lock+0x1c/0x49
[   10.536424]        [<c0299b4a>] dev_queue_xmit+0x175/0x2f3
[   10.536425]        [<c0299b4a>] dev_queue_xmit+0x175/0x2f3
[   10.536425]        [<f8a6728b>] tcf_mirred+0x157/0x178 [act_mirred]
[   10.536425]        [<f8a67134>] tcf_mirred+0x0/0x178 [act_mirred]
[   10.536425]        [<c02a7018>] tcf_action_exec+0x44/0x77
[   10.536425]        [<f89927b0>] u32_classify+0x119/0x24e [cls_u32]
[   10.536425]        [<c013f123>] __lock_acquire+0xad0/0xb18
[   10.536425]        [<c02a5006>] tc_classify_compat+0x2f/0x5e
[   10.536425]        [<c02a5d1c>] tc_classify+0x17/0x78
[   10.536425]        [<f89670a4>] ingress_enqueue+0x1a/0x53 [sch_ingress]
[   10.536425]        [<c0297009>] netif_receive_skb+0x263/0x3e6
[   10.536425]        [<f882b4d9>] e1000_clean_rx_irq+0x380/0x448 [e1000]
[   10.536425]        [<f8828e1e>] e1000_clean+0x62/0x1fd [e1000]
[   10.536425]        [<c029926f>] net_rx_action+0xb3/0x19e
[   10.536425]        [<c01276f7>] __do_softirq+0x6f/0xe9
[   10.536425]        [<c0106aa7>] do_softirq+0x5e/0xa8
[   10.536425]        [<ffffffff>] 0xffffffff
[   10.536425]
[   10.536425] other info that might help us debug this:
[   10.536425]
[   10.536425] 5 locks held by swapper/0:
[   10.536425]  #0:  (rcu_read_lock){..--}, at: [<c029920c>] 
net_rx_action+0x50/0x19e
[   10.536425]  #1:  (rcu_read_lock){..--}, at: [<c0296e96>] 
netif_receive_skb+0xf0/0x3e6
[   10.536425]  #2:  (&dev->ingress_lock){-+..}, at: [<c0296ff5>] 
netif_receive_skb+0x24f/0x3e6
[   10.536425]  #3:  (&p->tcfc_lock){-+..}, at: [<f8a67154>] tcf_mirred+0x20/
0x178 [act_mirred]
[   10.536425]  #4:  (rcu_read_lock){..--}, at: [<c0299afb>] 
dev_queue_xmit+0x126/0x2f3
[   10.536425]
[   10.536425] stack backtrace:
[   10.536425] Pid: 0, comm: swapper Not tainted 2.6.25-rc3-devel #3
[   10.536425]  [<c013d196>] print_circular_bug_tail+0x5b/0x66
[   10.536425]  [<c013eedd>] __lock_acquire+0x88a/0xb18
[   10.536425]  [<c013f1d7>] lock_acquire+0x6c/0x89
[   10.536425]  [<c0299b4a>] ? dev_queue_xmit+0x175/0x2f3
[   10.536425]  [<c02f6927>] _spin_lock+0x1c/0x49
[   10.536425]  [<c0299b4a>] ? dev_queue_xmit+0x175/0x2f3
[   10.536425]  [<c0299b4a>] dev_queue_xmit+0x175/0x2f3
[   10.536425]  [<f8a6728b>] tcf_mirred+0x157/0x178 [act_mirred]
[   10.536425]  [<f8a67134>] ? tcf_mirred+0x0/0x178 [act_mirred]
[   10.536425]  [<c02a7018>] tcf_action_exec+0x44/0x77
[   10.536425]  [<f89927b0>] u32_classify+0x119/0x24e [cls_u32]
[   10.536425]  [<c013f123>] ? __lock_acquire+0xad0/0xb18
[   10.536425]  [<c02a5006>] tc_classify_compat+0x2f/0x5e
[   10.536425]  [<c02a5d1c>] tc_classify+0x17/0x78
[   10.536425]  [<f89670a4>] ingress_enqueue+0x1a/0x53 [sch_ingress]
[   10.536425]  [<c0297009>] netif_receive_skb+0x263/0x3e6
[   10.536425]  [<f882b4d9>] e1000_clean_rx_irq+0x380/0x448 [e1000]
[   10.536425]  [<f8828e1e>] e1000_clean+0x62/0x1fd [e1000]
[   10.536425]  [<c029926f>] net_rx_action+0xb3/0x19e
[   10.536425]  [<c01276f7>] __do_softirq+0x6f/0xe9
[   10.536425]  [<c0106aa7>] do_softirq+0x5e/0xa8
[   10.536425]  [<c014d8c9>] ? handle_edge_irq+0x0/0x10a
[   10.536425]  [<c0127655>] irq_exit+0x44/0x77
[   10.536425]  [<c0106b91>] do_IRQ+0xa0/0xb7
[   10.536425]  [<c0105446>] common_interrupt+0x2e/0x34
[   10.536425]  [<c01031b9>] ? mwait_idle_with_hints+0x39/0x3d
[   10.536425]  [<c0103364>] ? mwait_idle+0x0/0x14
[   10.536425]  [<c0103376>] mwait_idle+0x12/0x14
[   10.536425]  [<c0103696>] cpu_idle+0xb5/0xd5
[   10.536425]  [<c02e5b79>] rest_init+0x49/0x4b




On Mon, 25 Feb 2008 11:39:30 +0000, Jarek Poplawski wrote
> On Mon, Feb 25, 2008 at 12:48:38PM +0200, Denys Fedoryshchenko wrote:
> > What does it mean early?
> > I have custom boot scripts, it is also custom system based on busybox. 
There 
> > is a chance that i forgot to bring ifb0 up, but thats it.
> > I think such warning must not appear on any actions in userspace.
> 
> It's not about ifb0: this report shows loopback_init after some 
> action on eth, so eth was probably up before lo. And of course you 
> are right: this warning shouldn't be there. But, since this report 
> looks very strange, I wonder if there could be something else that mislead
> lockdep. Could you try to reproduce this with 2.6.24.2 without these
> additional patches?
> 
> Jarek P.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


--
Denys Fedoryshchenko
Technical Manager
Virtual ISP S.A.L.

