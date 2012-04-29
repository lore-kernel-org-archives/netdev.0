From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: kernel panic, inconsistent lock, vanilla 3.3.4, 32bit, tcp
Date: Sun, 29 Apr 2012 09:32:42 +0200
Message-ID: <1335684762.2900.69.camel@edumazet-glaptop>
References: <04009a9cbb27bf97cb7d86612191b751@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Glauber Costa <glommer@parallels.com>
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:43209 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752222Ab2D2Hcs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Apr 2012 03:32:48 -0400
Received: by wejx9 with SMTP id x9so1235633wej.19
        for <netdev@vger.kernel.org>; Sun, 29 Apr 2012 00:32:46 -0700 (PDT)
In-Reply-To: <04009a9cbb27bf97cb7d86612191b751@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2012-04-29 at 00:45 +0300, Denys Fedoryshchenko wrote:
> Hi
> 
> Just got repeatable kernel panic on loaded proxy server
> 
> Here is the log:
> Apr 29 00:38:17 10.0.15.2 kernel: [  762.903868]
> Apr 29 00:38:17 10.0.15.2 kernel: [  762.903880] 
> =================================
> Apr 29 00:38:17 10.0.15.2 kernel: [  762.903890] [ INFO: inconsistent 
> lock state ]
> Apr 29 00:38:17 10.0.15.2 kernel: [  762.903903] 3.3.4-build-0061 #8 
> Not tainted
> Apr 29 00:38:17 10.0.15.2 kernel: [  762.904133] 
> ---------------------------------
> Apr 29 00:38:17 10.0.15.2 kernel: [  762.904344] inconsistent 
> {IN-SOFTIRQ-W} -> {SOFTIRQ-ON-W} usage.
> Apr 29 00:38:17 10.0.15.2 kernel: [  762.904542] squid/1603 
> [HC0[0]:SC0[0]:HE1:SE1] takes:
> Apr 29 00:38:17 10.0.15.2 kernel: [  762.904542]  (key#3){+.?...}, at: 
> [<c0232cc4>] __percpu_counter_sum+0xd/0x58
> Apr 29 00:38:17 10.0.15.2 kernel: [  762.904542] {IN-SOFTIRQ-W} state 
> was registered at:
> Apr 29 00:38:17 10.0.15.2 kernel: [  762.904542]   [<c0158b84>] 
> __lock_acquire+0x284/0xc26
> Apr 29 00:38:17 10.0.15.2 kernel: [  762.904542]   [<c01598e8>] 
> lock_acquire+0x71/0x85
> Apr 29 00:38:17 10.0.15.2 kernel: [  762.904542]   [<c0349765>] 
> _raw_spin_lock+0x33/0x40
> Apr 29 00:38:17 10.0.15.2 kernel: [  762.904542]   [<c0232c93>] 
> __percpu_counter_add+0x58/0x7c
> Apr 29 00:38:17 10.0.15.2 kernel: [  762.904542]   [<c02cfde1>] 
> sk_clone_lock+0x1e5/0x200
> Apr 29 00:38:17 10.0.15.2 kernel: [  762.904542]   [<c0303ee4>] 
> inet_csk_clone_lock+0xe/0x78
> Apr 29 00:38:17 10.0.15.2 kernel: [  762.904542]   [<c0315778>] 
> tcp_create_openreq_child+0x1b/0x404
> Apr 29 00:38:17 10.0.15.2 kernel: [  762.904542]   [<c031339c>] 
> tcp_v4_syn_recv_sock+0x32/0x1c1
> Apr 29 00:38:17 10.0.15.2 kernel: [  762.904542]   [<c031615a>] 
> tcp_check_req+0x1fd/0x2d7
> Apr 29 00:38:17 10.0.15.2 kernel: [  762.904542]   [<c0313f77>] 
> tcp_v4_do_rcv+0xab/0x194
> Apr 29 00:38:17 10.0.15.2 kernel: [  762.904542]   [<c03153bb>] 
> tcp_v4_rcv+0x3b3/0x5cc
> Apr 29 00:38:17 10.0.15.2 kernel: [  762.904542]   [<c02fc0c4>] 
> ip_local_deliver_finish+0x13a/0x1e9
> Apr 29 00:38:17 10.0.15.2 kernel: [  762.904542]   [<c02fc539>] 
> NF_HOOK.clone.11+0x46/0x4d
> Apr 29 00:38:17 10.0.15.2 kernel: [  762.904542]   [<c02fc652>] 
> ip_local_deliver+0x41/0x45
> Apr 29 00:38:17 10.0.15.2 kernel: [  762.904542]   [<c02fc4d1>] 
> ip_rcv_finish+0x31a/0x33c
> Apr 29 00:38:17 10.0.15.2 kernel: [  762.904542]   [<c02fc539>] 
> NF_HOOK.clone.11+0x46/0x4d
> Apr 29 00:38:17 10.0.15.2 kernel: [  762.904542]   [<c02fc857>] 
> ip_rcv+0x201/0x23e
> Apr 29 00:38:17 10.0.15.2 kernel: [  762.904542]   [<c02daa3a>] 
> __netif_receive_skb+0x319/0x368
> Apr 29 00:38:17 10.0.15.2 kernel: [  762.904542]   [<c02dac07>] 
> netif_receive_skb+0x4e/0x7d
> Apr 29 00:38:17 10.0.15.2 kernel: [  762.904542]   [<c02dacf6>] 
> napi_skb_finish+0x1e/0x34
> Apr 29 00:38:17 10.0.15.2 kernel: [  762.904542]   [<c02db122>] 
> napi_gro_receive+0x20/0x24
> Apr 29 00:38:17 10.0.15.2 kernel: [  762.904542]   [<f85d1743>] 
> e1000_receive_skb+0x3f/0x45 [e1000e]
> Apr 29 00:38:17 10.0.15.2 kernel: [  762.904542]   [<f85d3464>] 
> e1000_clean_rx_irq+0x1f9/0x284 [e1000e]
> Apr 29 00:38:17 10.0.15.2 kernel: [  762.904542]   [<f85d3926>] 
> e1000_clean+0x62/0x1f4 [e1000e]
> Apr 29 00:38:17 10.0.15.2 kernel: [  762.904542]   [<c02db228>] 
> net_rx_action+0x90/0x160
> Apr 29 00:38:17 10.0.15.2 kernel: [  762.904542]   [<c012a445>] 
> __do_softirq+0x7b/0x118
> Apr 29 00:38:17 10.0.15.2 kernel: [  762.904542] irq event stamp: 
> 156915469
> Apr 29 00:38:17 10.0.15.2 kernel: [  762.904542] hardirqs last  enabled 
> at (156915469): [<c019b4f4>] __slab_alloc.clone.58.clone.63+0xc4/0x2de
> Apr 29 00:38:17 10.0.15.2 kernel: [  762.904542] hardirqs last disabled 
> at (156915468): [<c019b452>] __slab_alloc.clone.58.clone.63+0x22/0x2de
> Apr 29 00:38:17 10.0.15.2 kernel: [  762.904542] softirqs last  enabled 
> at (156915466): [<c02ce677>] lock_sock_nested+0x64/0x6c
> Apr 29 00:38:17 10.0.15.2 kernel: [  762.904542] softirqs last disabled 
> at (156915464): [<c0349914>] _raw_spin_lock_bh+0xe/0x45
> Apr 29 00:38:17 10.0.15.2 kernel: [  762.904542]
> Apr 29 00:38:17 10.0.15.2 kernel: [  762.904542] other info that might 
> help us debug this:
> Apr 29 00:38:17 10.0.15.2 kernel: [  762.904542]  Possible unsafe 
> locking scenario:
> Apr 29 00:38:17 10.0.15.2 kernel: [  762.904542]
> Apr 29 00:38:17 10.0.15.2 kernel: [  762.904542]        CPU0
> Apr 29 00:38:17 10.0.15.2 kernel: [  762.904542]        ----
> Apr 29 00:38:17 10.0.15.2 kernel: [  762.904542]   lock(key#3);
> Apr 29 00:38:17 10.0.15.2 kernel: [  762.904542]   <Interrupt>
> Apr 29 00:38:17 10.0.15.2 kernel: [  762.904542]     lock(key#3);
> Apr 29 00:38:17 10.0.15.2 kernel: [  762.904542]
> Apr 29 00:38:17 10.0.15.2 kernel: [  762.904542]  *** DEADLOCK ***
> Apr 29 00:38:17 10.0.15.2 kernel: [  762.904542]
> Apr 29 00:38:17 10.0.15.2 kernel: [  762.904542] 1 lock held by 
> squid/1603:
> Apr 29 00:38:17 10.0.15.2 kernel: [  762.904542]  #0:  
> (sk_lock-AF_INET){+.+.+.}, at: [<c03055c0>] lock_sock+0xa/0xc
> Apr 29 00:38:17 10.0.15.2 kernel: [  762.904542]
> Apr 29 00:38:17 10.0.15.2 kernel: [  762.904542] stack backtrace:
> Apr 29 00:38:17 10.0.15.2 kernel: [  762.904542] Pid: 1603, comm: squid 
> Not tainted 3.3.4-build-0061 #8
> Apr 29 00:38:17 10.0.15.2 kernel: [  762.904542] Call Trace:
> Apr 29 00:38:17 10.0.15.2 kernel: [  762.904542]  [<c0347b73>] ? 
> printk+0x18/0x1d
> Apr 29 00:38:17 10.0.15.2 kernel: [  762.904542]  [<c015873a>] 
> valid_state+0x1f6/0x201
> Apr 29 00:38:17 10.0.15.2 kernel: [  762.904542]  [<c0158816>] 
> mark_lock+0xd1/0x1bb
> Apr 29 00:38:17 10.0.15.2 kernel: [  762.904542]  [<c015876b>] ? 
> mark_lock+0x26/0x1bb
> Apr 29 00:38:17 10.0.15.2 kernel: [  762.904542]  [<c015805d>] ? 
> check_usage_forwards+0x77/0x77
> Apr 29 00:38:17 10.0.15.2 kernel: [  762.904542]  [<c0158bf8>] 
> __lock_acquire+0x2f8/0xc26
> Apr 29 00:38:17 10.0.15.2 kernel: [  762.904542]  [<c0159b8e>] ? 
> mark_held_locks+0x5d/0x7b
> Apr 29 00:38:17 10.0.15.2 kernel: [  762.904542]  [<c0159cf6>] ? 
> trace_hardirqs_on+0xb/0xd
> Apr 29 00:38:17 10.0.15.2 kernel: [  762.904542]  [<c0158dd4>] ? 
> __lock_acquire+0x4d4/0xc26
> Apr 29 00:38:17 10.0.15.2 kernel: [  762.904542]  [<c01598e8>] 
> lock_acquire+0x71/0x85
> Apr 29 00:38:17 10.0.15.2 kernel: [  762.904542]  [<c0232cc4>] ? 
> __percpu_counter_sum+0xd/0x58
> Apr 29 00:38:17 10.0.15.2 kernel: [  762.904542]  [<c0349765>] 
> _raw_spin_lock+0x33/0x40
> Apr 29 00:38:17 10.0.15.2 kernel: [  762.904542]  [<c0232cc4>] ? 
> __percpu_counter_sum+0xd/0x58
> Apr 29 00:38:17 10.0.15.2 kernel: [  762.904542]  [<c0232cc4>] 
> __percpu_counter_sum+0xd/0x58
> Apr 29 00:38:17 10.0.15.2 kernel: [  762.904542]  [<c02cebc4>] 
> __sk_mem_schedule+0xdd/0x1c7
> Apr 29 00:38:17 10.0.15.2 kernel: [  762.904542]  [<c02d178d>] ? 
> __alloc_skb+0x76/0x100
> Apr 29 00:38:17 10.0.15.2 kernel: [  762.904542]  [<c0305e8e>] 
> sk_wmem_schedule+0x21/0x2d
> Apr 29 00:38:17 10.0.15.2 kernel: [  762.904542]  [<c0306370>] 
> sk_stream_alloc_skb+0x42/0xaa
> Apr 29 00:38:17 10.0.15.2 kernel: [  762.904542]  [<c0306567>] 
> tcp_sendmsg+0x18f/0x68b
> Apr 29 00:38:17 10.0.15.2 kernel: [  762.904542]  [<c031f3dc>] ? 
> ip_fast_csum+0x30/0x30
> Apr 29 00:38:17 10.0.15.2 kernel: [  762.904542]  [<c0320193>] 
> inet_sendmsg+0x53/0x5a
> Apr 29 00:38:17 10.0.15.2 kernel: [  762.904542]  [<c02cb633>] 
> sock_aio_write+0xd2/0xda
> Apr 29 00:38:17 10.0.15.2 kernel: [  762.904542]  [<c015876b>] ? 
> mark_lock+0x26/0x1bb
> Apr 29 00:38:17 10.0.15.2 kernel: [  762.904542]  [<c01a1017>] 
> do_sync_write+0x9f/0xd9
> Apr 29 00:38:17 10.0.15.2 kernel: [  762.904542]  [<c01a2111>] ? 
> file_free_rcu+0x2f/0x2f
> Apr 29 00:38:17 10.0.15.2 kernel: [  762.904542]  [<c01a17a1>] 
> vfs_write+0x8f/0xab
> Apr 29 00:38:17 10.0.15.2 kernel: [  762.904542]  [<c01a284d>] ? 
> fget_light+0x75/0x7c
> Apr 29 00:38:17 10.0.15.2 kernel: [  762.904542]  [<c01a1900>] 
> sys_write+0x3d/0x5e
> Apr 29 00:38:17 10.0.15.2 kernel: [  762.904542]  [<c0349ec9>] 
> syscall_call+0x7/0xb
> Apr 29 00:38:17 10.0.15.2 kernel: [  762.904542]  [<c0340000>] ? 
> rp_sidt+0x41/0x83
> 
> 
> ---
> Denys Fedoryshchenko

Seems to be related to Glauber Costa work

sk_memory_allocated_add() seems to assume __percpu_counter_add() is irq
safe (truth is : it is not safe)
