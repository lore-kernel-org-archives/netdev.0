From: Yanko Kaneti <yaneti@declera.com>
Subject: PPPOE lockdep report  in dev_queue_xmit+0x8b8/0x900
Date: Mon, 18 Feb 2013 19:43:41 +0200
Message-ID: <1361209421.9147.12.camel@d2>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-ppp@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-ppp-owner@vger.kernel.org>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hello,

I've had the following lockdep report for the last couple of years of
kernels. I don't think I've had a lockup during that time related to
pppoe.

The pppoe entry in the MAINTAINERS file lists Michal Ostrowski <mostrows@earthlink.net>
which unfortunately bounces.


Regards
Yanko

[  123.603836] ======================================================
[  123.603838] [ INFO: possible circular locking dependency detected ]
[  123.603842] 3.8.0-0.rc7.git3.1.fc19.x86_64 #1 Not tainted
[  123.603844] -------------------------------------------------------
[  123.603846] liferea/2399 is trying to acquire lock:
[  123.603848]  (dev->qdisc_tx_busylock ?: &qdisc_tx_busylock){+.-...}, at: [<ffffffff815c9478>] dev_queue_xmit+0x8b8/0x900
[  123.603860] 
but task is already holding lock:
[  123.603862]  (&(&pch->downl)->rlock){+.-...}, at: [<ffffffffa0637d6d>] ppp_push+0x12d/0x630 [ppp_generic]
[  123.603872] 
which lock already depends on the new lock.

[  123.603875] 
the existing dependency chain (in reverse order) is:
[  123.603877] 
-> #3 (&(&pch->downl)->rlock){+.-...}:
[  123.603881]        [<ffffffff810db302>] lock_acquire+0xa2/0x1f0
[  123.603887]        [<ffffffff81704d2b>] _raw_spin_lock_bh+0x4b/0x80
[  123.603892]        [<ffffffffa0637d6d>] ppp_push+0x12d/0x630 [ppp_generic]
[  123.603896]        [<ffffffffa063a9df>] ppp_xmit_process+0x43f/0x670 [ppp_generic]
[  123.603900]        [<ffffffffa063afb0>] ppp_write+0xf0/0x110 [ppp_generic]
[  123.603904]        [<ffffffff811d8f32>] vfs_write+0xa2/0x170
[  123.603908]        [<ffffffff811d90ec>] sys_write+0x4c/0xa0
[  123.603910]        [<ffffffff8170eb59>] system_call_fastpath+0x16/0x1b
[  123.603916] 
-> #2 (&(&ppp->wlock)->rlock){+.-...}:
[  123.603920]        [<ffffffff810db302>] lock_acquire+0xa2/0x1f0
[  123.603923]        [<ffffffff81704d2b>] _raw_spin_lock_bh+0x4b/0x80
[  123.603926]        [<ffffffffa063a5cc>] ppp_xmit_process+0x2c/0x670 [ppp_generic]
[  123.603930]        [<ffffffffa063ae3d>] ppp_start_xmit+0x13d/0x1c0 [ppp_generic]
[  123.603933]        [<ffffffff815c8209>] dev_hard_start_xmit+0x259/0x6c0
[  123.603936]        [<ffffffff815e9dfe>] sch_direct_xmit+0xee/0x290
[  123.603940]        [<ffffffff815c8db6>] dev_queue_xmit+0x1f6/0x900
[  123.603943]        [<ffffffff815cfda1>] neigh_direct_output+0x11/0x20
[  123.603946]        [<ffffffff8160a0c9>] ip_finish_output+0x2b9/0x7f0
[  123.603950]        [<ffffffff8160c2bc>] ip_output+0x5c/0x100
[  123.603952]        [<ffffffff8160b649>] ip_local_out+0x29/0x90
[  123.603955]        [<ffffffff8160cdf5>] ip_send_skb+0x15/0x50
[  123.603958]        [<ffffffff8160ce63>] ip_push_pending_frames+0x33/0x40
[  123.603960]        [<ffffffff8163f6b5>] icmp_push_reply+0xf5/0x130
[  123.603964]        [<ffffffff8164096d>] icmp_send+0x49d/0xc80
[  123.603966]        [<ffffffff8163c709>] __udp4_lib_rcv+0x469/0xa80
[  123.603969]        [<ffffffff8163cd3a>] udp_rcv+0x1a/0x20
[  123.603971]        [<ffffffff8160497e>] ip_local_deliver_finish+0x19e/0x4c0
[  123.603974]        [<ffffffff81605697>] ip_local_deliver+0x47/0x80
[  123.603977]        [<ffffffff81604e00>] ip_rcv_finish+0x160/0x760
[  123.603979]        [<ffffffff816058e9>] ip_rcv+0x219/0x340
[  123.603982]        [<ffffffff815c6712>] __netif_receive_skb+0xad2/0xdc0
[  123.603985]        [<ffffffff815c7b1e>] process_backlog+0xbe/0x1a0
[  123.603988]        [<ffffffff815c7112>] net_rx_action+0x172/0x380
[  123.603990]        [<ffffffff81072b6f>] __do_softirq+0xef/0x3d0
[  123.603994]        [<ffffffff8170fefc>] call_softirq+0x1c/0x30
[  123.603998]        [<ffffffff8101c495>] do_softirq+0x85/0xc0
[  123.604002]        [<ffffffff81073035>] irq_exit+0xd5/0xe0
[  123.604005]        [<ffffffff817107a6>] do_IRQ+0x56/0xc0
[  123.604008]        [<ffffffff81705c32>] ret_from_intr+0x0/0x1a
[  123.604011]        [<ffffffff81022add>] default_idle+0x5d/0x550
[  123.604015]        [<ffffffff810243fc>] cpu_idle+0x10c/0x170
[  123.604018]        [<ffffffff816f11dd>] start_secondary+0x263/0x265
[  123.604022] 
-> #1 (_xmit_PPP#2){+.-...}:
[  123.604026]        [<ffffffff810db302>] lock_acquire+0xa2/0x1f0
[  123.604029]        [<ffffffff81704ca6>] _raw_spin_lock+0x46/0x80
[  123.604032]        [<ffffffff815e9dc0>] sch_direct_xmit+0xb0/0x290
[  123.604035]        [<ffffffff815c8db6>] dev_queue_xmit+0x1f6/0x900
[  123.604038]        [<ffffffff815cfda1>] neigh_direct_output+0x11/0x20
[  123.604040]        [<ffffffff8160a0c9>] ip_finish_output+0x2b9/0x7f0
[  123.604043]        [<ffffffff8160c2bc>] ip_output+0x5c/0x100
[  123.604046]        [<ffffffff8160b649>] ip_local_out+0x29/0x90
[  123.604048]        [<ffffffff8160bad3>] ip_queue_xmit+0x1b3/0x670
[  123.604051]        [<ffffffff81625e62>] tcp_transmit_skb+0x3e2/0xa60
[  123.604054]        [<ffffffff81626676>] tcp_write_xmit+0x196/0xad0
[  123.604057]        [<ffffffff8162721e>] __tcp_push_pending_frames+0x2e/0xc0
[  123.604060]        [<ffffffff81616ebd>] tcp_sendmsg+0x11d/0xe00
[  123.604063]        [<ffffffff81646b17>] inet_sendmsg+0x117/0x230
[  123.604066]        [<ffffffff815a971a>] sock_sendmsg+0xaa/0xe0
[  123.604071]        [<ffffffff815ac079>] sys_sendto+0x129/0x1d0
[  123.604073]        [<ffffffff8170eb59>] system_call_fastpath+0x16/0x1b
[  123.604077] 
-> #0 (dev->qdisc_tx_busylock ?: &qdisc_tx_busylock){+.-...}:
[  123.604080]        [<ffffffff810da8b1>] __lock_acquire+0x17e1/0x1a80
[  123.604083]        [<ffffffff810db302>] lock_acquire+0xa2/0x1f0
[  123.604086]        [<ffffffff81704ca6>] _raw_spin_lock+0x46/0x80
[  123.604089]        [<ffffffff815c9478>] dev_queue_xmit+0x8b8/0x900
[  123.604091]        [<ffffffffa06562b2>] __pppoe_xmit+0x142/0x190 [pppoe]
[  123.604095]        [<ffffffffa0656311>] pppoe_xmit+0x11/0x20 [pppoe]
[  123.604098]        [<ffffffffa0637d88>] ppp_push+0x148/0x630 [ppp_generic]
[  123.604101]        [<ffffffffa063a9df>] ppp_xmit_process+0x43f/0x670 [ppp_generic]
[  123.604105]        [<ffffffffa063ae3d>] ppp_start_xmit+0x13d/0x1c0 [ppp_generic]
[  123.604108]        [<ffffffff815c8209>] dev_hard_start_xmit+0x259/0x6c0
[  123.604111]        [<ffffffff815e9dfe>] sch_direct_xmit+0xee/0x290
[  123.604114]        [<ffffffff815c8db6>] dev_queue_xmit+0x1f6/0x900
[  123.604117]        [<ffffffff815cfda1>] neigh_direct_output+0x11/0x20
[  123.604120]        [<ffffffff8160a0c9>] ip_finish_output+0x2b9/0x7f0
[  123.604123]        [<ffffffff8160c2bc>] ip_output+0x5c/0x100
[  123.604125]        [<ffffffff8160b649>] ip_local_out+0x29/0x90
[  123.604128]        [<ffffffff8160bad3>] ip_queue_xmit+0x1b3/0x670
[  123.604131]        [<ffffffff81625e62>] tcp_transmit_skb+0x3e2/0xa60
[  123.604134]        [<ffffffff81628b74>] tcp_send_ack+0xa4/0xf0
[  123.604137]        [<ffffffff81617c46>] tcp_cleanup_rbuf+0x76/0x120
[  123.604140]        [<ffffffff816189ca>] tcp_recvmsg+0x72a/0xd50
[  123.604143]        [<ffffffff81646fc9>] inet_recvmsg+0x129/0x220
[  123.604146]        [<ffffffff815a9859>] sock_recvmsg+0xb9/0xf0
[  123.604149]        [<ffffffff815ac227>] sys_recvfrom+0xe7/0x160
[  123.604152]        [<ffffffff8170eb59>] system_call_fastpath+0x16/0x1b
[  123.604155] 
other info that might help us debug this:

[  123.604158] Chain exists of:
  dev->qdisc_tx_busylock ?: &qdisc_tx_busylock --> &(&ppp->wlock)->rlock --> &(&pch->downl)->rlock

[  123.604163]  Possible unsafe locking scenario:

[  123.604165]        CPU0                    CPU1
[  123.604167]        ----                    ----
[  123.604168]   lock(&(&pch->downl)->rlock);
[  123.604171]                                lock(&(&ppp->wlock)->rlock);
[  123.604173]                                lock(&(&pch->downl)->rlock);
[  123.604175]   lock(dev->qdisc_tx_busylock ?: &qdisc_tx_busylock);
[  123.604178] 
 *** DEADLOCK ***

[  123.604181] 8 locks held by liferea/2399:
[  123.604182]  #0:  (sk_lock-AF_INET){+.+.+.}, at: [<ffffffff816182d2>] tcp_recvmsg+0x32/0xd50
[  123.604188]  #1:  (rcu_read_lock){.+.+..}, at: [<ffffffff8160b925>] ip_queue_xmit+0x5/0x670
[  123.604194]  #2:  (rcu_read_lock_bh){.+....}, at: [<ffffffff81609f48>] ip_finish_output+0x138/0x7f0
[  123.604199]  #3:  (rcu_read_lock_bh){.+....}, at: [<ffffffff815c8bc5>] dev_queue_xmit+0x5/0x900
[  123.604204]  #4:  (_xmit_PPP#2){+.-...}, at: [<ffffffff815e9dc0>] sch_direct_xmit+0xb0/0x290
[  123.604210]  #5:  (&(&ppp->wlock)->rlock){+.-...}, at: [<ffffffffa063a5cc>] ppp_xmit_process+0x2c/0x670 [ppp_generic]
[  123.604216]  #6:  (&(&pch->downl)->rlock){+.-...}, at: [<ffffffffa0637d6d>] ppp_push+0x12d/0x630 [ppp_generic]
[  123.604222]  #7:  (rcu_read_lock_bh){.+....}, at: [<ffffffff815c8bc5>] dev_queue_xmit+0x5/0x900
[  123.604227] 
stack backtrace:
[  123.604231] Pid: 2399, comm: liferea Not tainted 3.8.0-0.rc7.git3.1.fc19.x86_64 #1
[  123.604233] Call Trace:
[  123.604239]  [<ffffffff816f9c6e>] print_circular_bug+0x201/0x210
[  123.604243]  [<ffffffff810da8b1>] __lock_acquire+0x17e1/0x1a80
[  123.604246]  [<ffffffff810d93b5>] ? __lock_acquire+0x2e5/0x1a80
[  123.604250]  [<ffffffff810db302>] lock_acquire+0xa2/0x1f0
[  123.604253]  [<ffffffff815c9478>] ? dev_queue_xmit+0x8b8/0x900
[  123.604257]  [<ffffffff81704ca6>] _raw_spin_lock+0x46/0x80
[  123.604260]  [<ffffffff815c9478>] ? dev_queue_xmit+0x8b8/0x900
[  123.604263]  [<ffffffff815c9478>] dev_queue_xmit+0x8b8/0x900
[  123.604267]  [<ffffffff815c8bc5>] ? dev_queue_xmit+0x5/0x900
[  123.604270]  [<ffffffffa06562b2>] __pppoe_xmit+0x142/0x190 [pppoe]
[  123.604274]  [<ffffffffa0656311>] pppoe_xmit+0x11/0x20 [pppoe]
[  123.604278]  [<ffffffffa0637d88>] ppp_push+0x148/0x630 [ppp_generic]
[  123.604282]  [<ffffffff810d8c9c>] ? trace_hardirqs_on_caller+0xac/0x190
[  123.604285]  [<ffffffff810d8d8d>] ? trace_hardirqs_on+0xd/0x10
[  123.604289]  [<ffffffffa063a9df>] ppp_xmit_process+0x43f/0x670 [ppp_generic]
[  123.604292]  [<ffffffff810d8d8d>] ? trace_hardirqs_on+0xd/0x10
[  123.604296]  [<ffffffffa063ae3d>] ppp_start_xmit+0x13d/0x1c0 [ppp_generic]
[  123.604300]  [<ffffffff815c8209>] dev_hard_start_xmit+0x259/0x6c0
[  123.604303]  [<ffffffff815e9dfe>] sch_direct_xmit+0xee/0x290
[  123.604307]  [<ffffffff815c8db6>] dev_queue_xmit+0x1f6/0x900
[  123.604310]  [<ffffffff815c8bc5>] ? dev_queue_xmit+0x5/0x900
[  123.604313]  [<ffffffff815cfda1>] neigh_direct_output+0x11/0x20
[  123.604316]  [<ffffffff8160a0c9>] ip_finish_output+0x2b9/0x7f0
[  123.604319]  [<ffffffff81609f48>] ? ip_finish_output+0x138/0x7f0
[  123.604323]  [<ffffffff8160c2bc>] ip_output+0x5c/0x100
[  123.604326]  [<ffffffff8160b649>] ip_local_out+0x29/0x90
[  123.604329]  [<ffffffff8160bad3>] ip_queue_xmit+0x1b3/0x670
[  123.604332]  [<ffffffff8160b925>] ? ip_queue_xmit+0x5/0x670
[  123.604335]  [<ffffffff81625e62>] tcp_transmit_skb+0x3e2/0xa60
[  123.604339]  [<ffffffff811b8a19>] ? ksize+0x19/0xc0
[  123.604342]  [<ffffffff81628b74>] tcp_send_ack+0xa4/0xf0
[  123.604346]  [<ffffffff81617c46>] tcp_cleanup_rbuf+0x76/0x120
[  123.604350]  [<ffffffff816189ca>] tcp_recvmsg+0x72a/0xd50
[  123.604354]  [<ffffffff810ad465>] ? sched_clock_cpu+0xb5/0x100
[  123.604358]  [<ffffffff81646fc9>] inet_recvmsg+0x129/0x220
[  123.604361]  [<ffffffff815a9859>] sock_recvmsg+0xb9/0xf0
[  123.604365]  [<ffffffff810d93b5>] ? __lock_acquire+0x2e5/0x1a80
[  123.604368]  [<ffffffff815ac227>] sys_recvfrom+0xe7/0x160
[  123.604372]  [<ffffffff8170eb85>] ? sysret_check+0x22/0x5d
[  123.604376]  [<ffffffff810d8ced>] ? trace_hardirqs_on_caller+0xfd/0x190
[  123.604381]  [<ffffffff8136094e>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[  123.604385]  [<ffffffff8170eb59>] system_call_fastpath+0x16/0x1b


