From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: 3.5rc6 sctp panic
Date: Sat, 14 Jul 2012 17:14:34 -0400
Message-ID: <20120714211434.GA7159@neilslaptop.think-freely.org>
References: <20120711000831.GA10518@redhat.com>
 <20120714.130201.1562818146578811700.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davej@redhat.com, netdev@vger.kernel.org, vyasevich@gmail.com,
	sri@us.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:40429 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750824Ab2GNVOt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Jul 2012 17:14:49 -0400
Content-Disposition: inline
In-Reply-To: <20120714.130201.1562818146578811700.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jul 14, 2012 at 01:02:01PM -0700, David Miller wrote:
> From: Dave Jones <davej@redhat.com>
> Date: Tue, 10 Jul 2012 20:08:32 -0400
> 
> > I just hit this while fuzz testing, and the box locked up immediately afterwards.
> > The serial log was a little mangled, I did my best to clean it up..
> 
> Guys can we fix crashes like this one reported by Dave instead of
> working on new features and cleanups?
> 
> Thanks.
> 
Yeah, I'll put it at the top of my to do list, and track it down monday AM.
Neil

> > [22766.294255] general protection fault: 0000 [#1] PREEMPT SMP 
> > [22766.295376] CPU 0 
> > [22766.295384] Modules linked in:
> > [22766.387137]  ffffffffa169f292 6b6b6b6b6b6b6b6b ffff880147c03a90 ffff880147c03a74
> > [22766.387135] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 00000000000
> > [22766.387136] Process trinity-watchdo (pid: 10896, threadinfo ffff88013e7d2000,
> > [22766.387137] Stack:
> > [22766.387140]  ffff880147c03a10
> > [22766.387140]  ffffffffa169f2b6
> > [22766.387140]  ffff88013ed95728
> > [22766.387143]  0000000000000002
> > [22766.387143]  0000000000000000
> > [22766.387143]  ffff880003fad062
> > [22766.387144]  ffff88013c120000
> > [22766.387144] 
> > [22766.387145] Call Trace:
> > [22766.387145]  <IRQ> 
> > [22766.387150]  [<ffffffffa169f292>] ? __sctp_lookup_association+0x62/0xd0 [sctp]
> > [22766.387154]  [<ffffffffa169f2b6>] __sctp_lookup_association+0x86/0xd0 [sctp]
> > [22766.387157]  [<ffffffffa169f597>] sctp_rcv+0x207/0xbb0 [sctp]
> > [22766.387161]  [<ffffffff810d4da8>] ? trace_hardirqs_off_caller+0x28/0xd0
> > [22766.387163]  [<ffffffff815827e3>] ? nf_hook_slow+0x133/0x210
> > [22766.387166]  [<ffffffff815902fc>] ? ip_local_deliver_finish+0x4c/0x4c0
> > [22766.387168]  [<ffffffff8159043d>] ip_local_deliver_finish+0x18d/0x4c0
> > [22766.387169]  [<ffffffff815902fc>] ? ip_local_deliver_finish+0x4c/0x4c0
> > [22766.387171]  [<ffffffff81590a07>] ip_local_deliver+0x47/0x80
> > [22766.387172]  [<ffffffff8158fd80>] ip_rcv_finish+0x150/0x680
> > [22766.387174]  [<ffffffff81590c54>] ip_rcv+0x214/0x320
> > [22766.387176]  [<ffffffff81558c07>] __netif_receive_skb+0x7b7/0x910
> > [22766.387178]  [<ffffffff8155856c>] ? __netif_receive_skb+0x11c/0x910
> > [22766.387180]  [<ffffffff810d423e>] ? put_lock_stats.isra.25+0xe/0x40
> > [22766.387182]  [<ffffffff81558f83>] netif_receive_skb+0x23/0x1f0
> > [22766.387183]  [<ffffffff815596a9>] ? dev_gro_receive+0x139/0x440
> > [22766.387185]  [<ffffffff81559280>] napi_skb_finish+0x70/0xa0
> > [22766.387187]  [<ffffffff81559cb5>] napi_gro_receive+0xf5/0x130
> > [22766.387218]  [<ffffffffa01c4679>] e1000_receive_skb+0x59/0x70 [e1000e]
> > [22766.387242]  [<ffffffffa01c5aab>] e1000_clean_rx_irq+0x28b/0x460 [e1000e]
> > [22766.387266]  [<ffffffffa01c9c18>] e1000e_poll+0x78/0x430 [e1000e]
> > [22766.387268]  [<ffffffff81559fea>] net_rx_action+0x1aa/0x3d0
> > [22766.387270]  [<ffffffff810a495f>] ? account_system_vtime+0x10f/0x130
> > [22766.387273]  [<ffffffff810734d0>] __do_softirq+0xe0/0x420
> > [22766.387275]  [<ffffffff8169826c>] call_softirq+0x1c/0x30
> > [22766.387278]  [<ffffffff8101db15>] do_softirq+0xd5/0x110
> > [22766.387279]  [<ffffffff81073bc5>] irq_exit+0xd5/0xe0
> > [22766.387281]  [<ffffffff81698b03>] do_IRQ+0x63/0xd0
> > [22766.387283]  [<ffffffff8168ee2f>] common_interrupt+0x6f/0x6f
> > [22766.387283]  <EOI> 
> > [22766.387284] 
> > [22766.387285]  [<ffffffff8168eed9>] ? retint_swapgs+0x13/0x1b
> > [22766.387285] Code: c0 90 5d c3 66 0f 1f 44 00 00 4c 89 c8 5d c3 0f 1f 00 55 48 89 e5 48 83 
> > ec 20 48 89 5d e8 4c 89 65 f0 4c 89 6d f8 66 66 66 66 90 <0f> b7 87 98 00 00 00 48 89 fb 
> > 49 89 f5 66 c1 c0 08 66 39 46 02 
> > [22766.387307] 
> > [22766.387307] RIP 
> > [22766.387311]  [<ffffffffa168a2c9>] sctp_assoc_is_match+0x19/0x90 [sctp]
> > [22766.387311]  RSP <ffff880147c039b0>
> > [22766.387142]  ffffffffa16ab120
> > [22766.599537] ---[ end trace 3f6dae82e37b17f5 ]---
> > [22766.601221] Kernel panic - not syncing: Fatal exception in interrupt
> > 
> > 
> > 
> > Disassembly of the function shows that we oopsed here..
> > 
> > /* Is this the association we are looking for? */
> > struct sctp_transport *sctp_assoc_is_match(struct sctp_association *asoc,
> >                                            const union sctp_addr *laddr,
> >                                            const union sctp_addr *paddr)
> > {
> >     1070:       55                      push   %rbp
> >     1071:       48 89 e5                mov    %rsp,%rbp
> >     1074:       48 83 ec 20             sub    $0x20,%rsp
> >     1078:       48 89 5d e8             mov    %rbx,-0x18(%rbp)
> >     107c:       4c 89 65 f0             mov    %r12,-0x10(%rbp)
> >     1080:       4c 89 6d f8             mov    %r13,-0x8(%rbp)
> >     1084:       e8 00 00 00 00          callq  1089 <sctp_assoc_is_match+0x19>
> >         struct sctp_transport *transport;
> > 
> >         if ((htons(asoc->base.bind_addr.port) == laddr->v4.sin_port) &&
> >     1089:       0f b7 87 98 00 00 00    movzwl 0x98(%rdi),%eax
> > 
> > 
> > --
> > To unsubscribe from this list: send the line "unsubscribe netdev" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > 
> 
