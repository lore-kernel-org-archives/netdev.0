From: "Denys Fedoryshchenko" <denys@visp.net.lb>
Subject: Re: circular locking, mirred, 2.6.24.2
Date: Sat, 8 Mar 2008 12:16:52 +0200
Message-ID: <20080308101540.M65133@visp.net.lb>
References: <20080305103935.M76165@visp.net.lb> <20080306134015.GA4571@ff.dom.local> <1204811995.4440.30.camel@localhost> <20080306175629.GA2876@ami.dom.local> <1204836523.4457.103.camel@localhost> <20080306214000.GC2876@ami.dom.local> <1204846839.4431.23.camel@localhost> <20080307075113.GA3912@ff.dom.local> <1204898002.4431.99.camel@localhost> <20080308084628.GA2749@ami.dom.local> <20080308085854.GB2749@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=koi8-r
Cc: netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>, jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usermail.globalproof.net ([194.146.153.18]:52978 "EHLO
	usermail.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751744AbYCHKRE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Mar 2008 05:17:04 -0500
In-Reply-To: <20080308085854.GB2749@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Update. I am not able to reproduce on my PC, but still able to reproduce on 
PPPoE server (but here i cannot take risk to use 2.6.25-rcX kernels). This is 
PPPoE:

[2148614.154684]
[2148614.154688] =======================================================
[2148614.154805] [ INFO: possible circular locking dependency detected ]
[2148614.154862] 2.6.24.3-build-0023 #9
[2148614.154913] -------------------------------------------------------
[2148614.154969] swapper/0 is trying to acquire lock:
[2148614.155023]  (&ifb_queue_lock_key){-+..}, at: [<c0289d4d>] 
dev_queue_xmit+0x177/0x302
[2148614.155245]
[2148614.155246] but task is already holding lock:
[2148614.155346]  (&p->tcfc_lock){-+..}, at: [<f8a10066>] tcf_mirred+0x20/
0x180 [act_mirred]
[2148614.155569]
[2148614.155570] which lock already depends on the new lock.
[2148614.155571]
[2148614.155715]
[2148614.155716] the existing dependency chain (in reverse order) is:
[2148614.155817]
[2148614.155818] -> #2 (&p->tcfc_lock){-+..}:
[2148614.156026]        [<c014368c>] __lock_acquire+0xa30/0xc19
[2148614.156371]        [<c01438ef>] lock_acquire+0x7a/0x94
[2148614.156714]        [<c02d9525>] _spin_lock+0x2e/0x58
[2148614.157062]        [<f89e638d>] tcf_ipt+0x4b/0xde [act_ipt]
[2148614.157412]        [<c0298000>] tcf_action_exec+0x44/0x77
[2148614.157764]        [<f89da5d2>] u32_classify+0x119/0x24a [cls_u32]
[2148614.158116]        [<c0295e1e>] tc_classify_compat+0x2f/0x5e
[2148614.158460]        [<c0295fff>] tc_classify+0x1a/0x80
[2148614.158802]        [<f89ec118>] ingress_enqueue+0x1a/0x53 [sch_ingress]
[2148614.159152]        [<c0287275>] netif_receive_skb+0x296/0x44c
[2148614.159496]        [<c0289ada>] process_backlog+0x77/0xd4
[2148614.159839]        [<c02895f8>] net_rx_action+0xbf/0x201
[2148614.160183]        [<c012ac15>] __do_softirq+0x6f/0xe9
[2148614.160530]        [<c01078af>] do_softirq+0x61/0xc8
[2148614.160876]        [<ffffffff>] 0xffffffff
[2148614.161226]
[2148614.161227] -> #1 (&dev->ingress_lock){-+..}:
[2148614.161435]        [<c014368c>] __lock_acquire+0xa30/0xc19
[2148614.161781]        [<c01438ef>] lock_acquire+0x7a/0x94
[2148614.162123]        [<c02d9525>] _spin_lock+0x2e/0x58
[2148614.162465]        [<c02954c3>] qdisc_lock_tree+0x1e/0x21
[2148614.162807]        [<c0296ba5>] qdisc_create+0x17e/0x1e3
[2148614.163148]        [<c0297368>] tc_modify_qdisc+0x2a3/0x3a3
[2148614.163490]        [<c029051d>] rtnetlink_rcv_msg+0x18e/0x1a8
[2148614.163835]        [<c029b670>] netlink_rcv_skb+0x30/0x82
[2148614.164181]        [<c0290387>] rtnetlink_rcv+0x17/0x1f
[2148614.164523]        [<c029b444>] netlink_unicast+0x19c/0x205
[2148614.164868]        [<c029bc41>] netlink_sendmsg+0x250/0x25c
[2148614.165210]        [<c027d894>] sock_sendmsg+0xcc/0xe5
[2148614.165554]        [<c027da00>] sys_sendmsg+0x153/0x1b1
[2148614.165898]        [<c027e860>] sys_socketcall+0x203/0x222
[2148614.166242]        [<c0104e9a>] sysenter_past_esp+0x5f/0xa5
[2148614.166589]        [<ffffffff>] 0xffffffff
[2148614.166935]
[2148614.166936] -> #0 (&ifb_queue_lock_key){-+..}:
[2148614.167143]        [<c014357c>] __lock_acquire+0x920/0xc19
[2148614.167490]        [<c01438ef>] lock_acquire+0x7a/0x94
[2148614.167832]        [<c02d9525>] _spin_lock+0x2e/0x58
[2148614.168176]        [<c0289d4d>] dev_queue_xmit+0x177/0x302
[2148614.168529]        [<f8a101a5>] tcf_mirred+0x15f/0x180 [act_mirred]
[2148614.168878]        [<c0298000>] tcf_action_exec+0x44/0x77
[2148614.169223]        [<f89da5d2>] u32_classify+0x119/0x24a [cls_u32]
[2148614.169571]        [<c0295e1e>] tc_classify_compat+0x2f/0x5e
[2148614.169914]        [<c0295fff>] tc_classify+0x1a/0x80
[2148614.170257]        [<f89ec118>] ingress_enqueue+0x1a/0x53 [sch_ingress]
[2148614.170605]        [<c0287275>] netif_receive_skb+0x296/0x44c
[2148614.170950]        [<c0289ada>] process_backlog+0x77/0xd4
[2148614.171293]        [<c02895f8>] net_rx_action+0xbf/0x201
[2148614.171635]        [<c012ac15>] __do_softirq+0x6f/0xe9
[2148614.171978]        [<c01078af>] do_softirq+0x61/0xc8
[2148614.172321]        [<ffffffff>] 0xffffffff
[2148614.172664]
[2148614.172665] other info that might help us debug this:
[2148614.172666]
[2148614.172810] 5 locks held by swapper/0:
[2148614.172862]  #0:  (rcu_read_lock){..--}, at: [<c0289589>] 
net_rx_action+0x50/0x201
[2148614.173111]  #1:  (rcu_read_lock){..--}, at: [<c02870d5>] 
netif_receive_skb+0xf6/0x44c
[2148614.173359]  #2:  (&dev->ingress_lock){-+..}, at: [<c0287261>] 
netif_receive_skb+0x282/0x44c
[2148614.173608]  #3:  (&p->tcfc_lock){-+..}, at: [<f8a10066>] 
tcf_mirred+0x20/0x180 [act_mirred]
[2148614.173859]  #4:  (rcu_read_lock){..--}, at: [<c0289cf3>] 
dev_queue_xmit+0x11d/0x302
[2148614.174110]
[2148614.174111] stack backtrace:
[2148614.174208] Pid: 0, comm: swapper Not tainted 2.6.24.3-build-0023 #9
[2148614.174265]  [<c0105f2a>] show_trace_log_lvl+0x1a/0x2f
[2148614.174360]  [<c0106843>] show_trace+0x12/0x14
[2148614.174452]  [<c010713a>] dump_stack+0x6c/0x72
[2148614.174541]  [<c014175c>] print_circular_bug_tail+0x5f/0x68
[2148614.174634]  [<c014357c>] __lock_acquire+0x920/0xc19
[2148614.174725]  [<c01438ef>] lock_acquire+0x7a/0x94
[2148614.174814]  [<c02d9525>] _spin_lock+0x2e/0x58
[2148614.174904]  [<c0289d4d>] dev_queue_xmit+0x177/0x302
[2148614.174995]  [<f8a101a5>] tcf_mirred+0x15f/0x180 [act_mirred]
[2148614.175091]  [<c0298000>] tcf_action_exec+0x44/0x77
[2148614.175183]  [<f89da5d2>] u32_classify+0x119/0x24a [cls_u32]
[2148614.175279]  [<c0295e1e>] tc_classify_compat+0x2f/0x5e
[2148614.175370]  [<c0295fff>] tc_classify+0x1a/0x80
[2148614.175460]  [<f89ec118>] ingress_enqueue+0x1a/0x53 [sch_ingress]
[2148614.175554]  [<c0287275>] netif_receive_skb+0x296/0x44c
[2148614.175646]  [<c0289ada>] process_backlog+0x77/0xd4
[2148614.175735]  [<c02895f8>] net_rx_action+0xbf/0x201
[2148614.175825]  [<c012ac15>] __do_softirq+0x6f/0xe9
[2148614.175915]  [<c01078af>] do_softirq+0x61/0xc8
[2148614.176005]  =======================


On Sat, 8 Mar 2008 09:58:54 +0100, Jarek Poplawski wrote
> On Sat, Mar 08, 2008 at 09:46:28AM +0100, Jarek Poplawski wrote:
> ....
> > said doesn't use this patch with it's ingress (at least currently).
> 
> + said doesn't use this path with it's ingress (at least currently).
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

