From: "Denys Fedoryshchenko" <denys@visp.net.lb>
Subject: Re: circular locking, mirred, 2.6.24.2
Date: Mon, 25 Feb 2008 12:48:38 +0200
Message-ID: <20080225104652.M2446@visp.net.lb>
References: <20080224222035.M62480@visp.net.lb> <20080225095646.GA4321@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=koi8-r
Cc: netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usermail.globalproof.net ([194.146.153.18]:33214 "EHLO
	usermail.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754137AbYBYKst (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Feb 2008 05:48:49 -0500
In-Reply-To: <20080225095646.GA4321@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

What does it mean early?
I have custom boot scripts, it is also custom system based on busybox. There 
is a chance that i forgot to bring ifb0 up, but thats it.
I think such warning must not appear on any actions in userspace.

On Mon, 25 Feb 2008 09:56:46 +0000, Jarek Poplawski wrote
> On 24-02-2008 23:20, Denys Fedoryshchenko wrote:
> > 2.6.24.2 with applied patches for printk,softlockup, and patch for htb 
(as i 
> > understand, they are in 2.6.25 git and it is fixes).
> > 
> > I will send also to private mails QoS rules i am using.
> > 
> > [  118.840072] =======================================================
> > [  118.840158] [ INFO: possible circular locking dependency detected ]
> > [  118.840203] 2.6.24.2-build-0022 #7
> > [  118.840243] -------------------------------------------------------
> > [  118.840288] swapper/0 is trying to acquire lock:
> > [  118.840329]  (&dev->queue_lock){-+..}, at: [<c0289c11>] dev_queue_xmit
> > +0x177/0x302
> > [  118.840490]
> > [  118.840490] but task is already holding lock:
> > [  118.840567]  (&p->tcfc_lock){-+..}, at: [<f89f0066>] tcf_mirred
+0x20/0x180 
> > [act_mirred]
> > [  118.840727]
> > [  118.840727] which lock already depends on the new lock.
> > [  118.840728]
> > [  118.840842]
> > [  118.840842] the existing dependency chain (in reverse order) is:
> > [  118.840921]
> > [  118.840921] -> #2 (&p->tcfc_lock){-+..}:
> > [  118.841075]        [<c0143624>] __lock_acquire+0xa30/0xc19
> > [  118.841324]        [<c0143887>] lock_acquire+0x7a/0x94
> > [  118.841572]        [<c02d93f5>] _spin_lock+0x2e/0x58
> > [  118.841820]        [<f89f0066>] tcf_mirred+0x20/0x180 [act_mirred]
> > [  118.842068]        [<c0297ec4>] tcf_action_exec+0x44/0x77
> > [  118.842344]        [<f89ba5d2>] u32_classify+0x119/0x24a [cls_u32]
> > [  118.842595]        [<c0295ce2>] tc_classify_compat+0x2f/0x5e
> > [  118.842845]        [<c0295ec3>] tc_classify+0x1a/0x80
> > [  118.843092]        [<f899c118>] ingress_enqueue+0x1a/0x53 [sch_ingress]
> > [  118.843343]        [<c0287139>] netif_receive_skb+0x296/0x44c
> > [  118.843592]        [<f88d1a4e>] e100_poll+0x14b/0x26a [e100]
> > [  118.843843]        [<c02894bc>] net_rx_action+0xbf/0x201
> > [  118.844091]        [<c012ac15>] __do_softirq+0x6f/0xe9
> > [  118.844343]        [<c01078af>] do_softirq+0x61/0xc8
> > [  118.844591]        [<ffffffff>] 0xffffffff
> > [  118.844840]
> > [  118.844840] -> #1 (&dev->ingress_lock){-+..}:
> > [  118.844993]        [<c0143624>] __lock_acquire+0xa30/0xc19
> > [  118.845242]        [<c0143887>] lock_acquire+0x7a/0x94
> > [  118.845489]        [<c02d93f5>] _spin_lock+0x2e/0x58
> > [  118.845737]        [<c0295387>] qdisc_lock_tree+0x1e/0x21
> > [  118.845984]        [<c02953b6>] dev_init_scheduler+0xb/0x53
> > [  118.846235]        [<c0288483>] register_netdevice+0x2a3/0x2fd
> > [  118.846483]        [<c028850f>] register_netdev+0x32/0x3f
> > [  118.846730]        [<c03ea8ee>] loopback_net_init+0x39/0x6c
> > [  118.846980]        [<c02858ef>] register_pernet_operations+0x13/0x15
> > [  118.847230]        [<c0285958>] register_pernet_device+0x1f/0x4c
> > [  118.847478]        [<c03ea8b3>] loopback_init+0xd/0xf
> > [  118.847725]        [<c03d64df>] kernel_init+0x155/0x2c6
> 
> This looks strange: are you sure your tc scripts aren't started too
> early? (Or maybe there are some problems during booting?)
> 
> Regards,
> Jarek P.
> 
> > [  118.847973]        [<c0105bab>] kernel_thread_helper+0x7/0x10
> > [  118.848225]        [<ffffffff>] 0xffffffff
> > [  118.848472]
> > [  118.848472] -> #0 (&dev->queue_lock){-+..}:
> > [  118.848626]        [<c0143514>] __lock_acquire+0x920/0xc19
> > [  118.848874]        [<c0143887>] lock_acquire+0x7a/0x94
> > [  118.849122]        [<c02d93f5>] _spin_lock+0x2e/0x58
> > [  118.849370]        [<c0289c11>] dev_queue_xmit+0x177/0x302
> > [  118.849617]        [<f89f01a5>] tcf_mirred+0x15f/0x180 [act_mirred]
> > [  118.849866]        [<c0297ec4>] tcf_action_exec+0x44/0x77
> > [  118.850114]        [<f89ba5d2>] u32_classify+0x119/0x24a [cls_u32]
> > [  118.850366]        [<c0295ce2>] tc_classify_compat+0x2f/0x5e
> > [  118.850614]        [<c0295ec3>] tc_classify+0x1a/0x80
> > [  118.850861]        [<f899c118>] ingress_enqueue+0x1a/0x53 [sch_ingress]
> > [  118.851111]        [<c0287139>] netif_receive_skb+0x296/0x44c
> > [  118.851360]        [<f88d1a4e>] e100_poll+0x14b/0x26a [e100]
> > [  118.851612]        [<c02894bc>] net_rx_action+0xbf/0x201
> > [  118.851859]        [<c012ac15>] __do_softirq+0x6f/0xe9
> > [  118.852106]        [<c01078af>] do_softirq+0x61/0xc8
> > [  118.852355]        [<ffffffff>] 0xffffffff
> ....
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


--
Denys Fedoryshchenko
Technical Manager
Virtual ISP S.A.L.

