From: "Denys Fedoryshchenko" <denys@visp.net.lb>
Subject: possible recursive locking, 2.6.24-rc7
Date: Sun, 13 Jan 2008 17:48:05 +0200
Message-ID: <20080113154634.M81483@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=koi8-r
Cc: netdev@vger.kernel.org
To: kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from usermail.globalproof.net ([194.146.153.18]:56505 "EHLO
	usermail.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751269AbYAMPsX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Jan 2008 10:48:23 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, got in dmesg
Not sure where to send (there is TCP), so sending netdev@ and kernel@


[159859.491752]
[159859.491755] =============================================
[159859.492021] [ INFO: possible recursive locking detected ]
[159859.492156] 2.6.24-rc7-devel #2
[159859.492284] ---------------------------------------------
[159859.492418] swapper/0 is trying to acquire lock:
[159859.492550]  (&q->lock){++..}, at: [<c01175ff>] __wake_up+0x15/0x42
[159859.492883]
[159859.492884] but task is already holding lock:
[159859.493140]  (&q->lock){++..}, at: [<c01175ff>] __wake_up+0x15/0x42
[159859.493466]
[159859.493467] other info that might help us debug this:
[159859.493726] 5 locks held by swapper/0:
[159859.495687]  #0:  (rcu_read_lock){..--}, at: [<c02dd9af>]
netif_receive_skb+                                                           
                 0x9c/0x3a7
[159859.496141]  #1:  (rcu_read_lock){..--}, at: [<c02f8072>]
ip_local_deliver_f                                                           
                 inish+0x30/0x18d
[159859.496604]  #2:  (slock-AF_INET/1){-+..}, at: [<c0310474>]
tcp_v4_rcv+0x426                                                             
               /0x812
[159859.497104]  #3:  (clock-AF_INET){-.-?}, at: [<c02d7684>]
sock_def_readable+                                                           
                 0x18/0x6e
[159859.497555]  #4:  (&q->lock){++..}, at: [<c01175ff>] __wake_up+0x15/0x42
[159859.497931]
[159859.497932] stack backtrace:
[159859.498185] Pid: 0, comm: swapper Not tainted 2.6.24-rc7-devel #2
[159859.498320]  [<c0105e68>] show_trace_log_lvl+0x1a/0x2f
[159859.498505]  [<c0106810>] show_trace+0x12/0x14
[159859.498690]  [<c0107107>] dump_stack+0x6c/0x72
[159859.498872]  [<c01384c0>] __lock_acquire+0x172/0xb8c
[159859.499057]  [<c01392a7>] lock_acquire+0x5f/0x78
[159859.499239]  [<c03299cf>] _spin_lock_irqsave+0x34/0x44
[159859.499423]  [<c01175ff>] __wake_up+0x15/0x42
[159859.499604]  [<c01869ea>] ep_poll_safewake+0x8e/0xbf
[159859.499787]  [<c01876b3>] ep_poll_callback+0x9f/0xac
[159859.499970]  [<c0115d36>] __wake_up_common+0x32/0x5c
[159859.500154]  [<c011761b>] __wake_up+0x31/0x42
[159859.500335]  [<c02d76ae>] sock_def_readable+0x42/0x6e
[159859.500518]  [<c0309105>] tcp_rcv_established+0x3bc/0x643
[159859.500704]  [<c030e588>] tcp_v4_do_rcv+0x2f/0x325
[159859.500887]  [<c0310817>] tcp_v4_rcv+0x7c9/0x812
[159859.501069]  [<c02f8149>] ip_local_deliver_finish+0x107/0x18d
[159859.501255]  [<c02f854e>] ip_local_deliver+0x72/0x7c
[159859.501438]  [<c02f8023>] ip_rcv_finish+0x2cf/0x2ee
[159859.501623]  [<c02f84b2>] ip_rcv+0x211/0x23b
[159859.501805]  [<c02ddc63>] netif_receive_skb+0x350/0x3a7
[159859.501989]  [<f88f2b6d>] bnx2_poll+0x975/0xb45 [bnx2]
[159859.502177]  [<c02dfdab>] net_rx_action+0x6c/0x116
[159859.502360]  [<c0120ed8>] __do_softirq+0x6f/0xe9
[159859.502543]  [<c0120f8c>] do_softirq+0x3a/0x52
[159859.502728]  [<c012128b>] irq_exit+0x47/0x7b
[159859.502911]  [<c01076af>] do_IRQ+0x81/0x96
[159859.503098]  [<c010586a>] common_interrupt+0x2e/0x34
[159859.503288]  [<c0103434>] mwait_idle+0x12/0x14
[159859.503476]  [<c010353d>] cpu_idle+0x7b/0x95
[159859.503662]  [<c03272c9>] rest_init+0x49/0x4b
[159859.503844]  [<c0449c08>] start_kernel+0x2f9/0x301
[159859.504030]  [<00000000>] 0x0
[159859.504210]  =======================


--
Denys Fedoryshchenko
Technical Manager
Virtual ISP S.A.L.

