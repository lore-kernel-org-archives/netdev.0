From: Alexander Beregalov <a.beregalov@gmail.com>
Subject: 2.6.38-rc5: nfsd: page allocation failure. spinlock trylock failure
 on UP
Date: Mon, 21 Feb 2011 23:33:29 +0300
Message-ID: <AANLkTi=14N_c_B7mLY0H8Dt8pte6C0mjFnVuC37e44Hs@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi

Let me know if I can provide more info

nfsd: page allocation failure. order:5, mode:0x4020
BUG: spinlock trylock failure on UP on CPU#0, nfsd/1574
 lock: f6771be0, .magic: dead4ead, .owner: nfsd/1574, .owner_cpu: 0
Pid: 1574, comm: nfsd Not tainted 2.6.38-rc5-00100-g0cc9d52 #1
Call Trace:
 [<c11ec94d>] ? spin_bug+0x9d/0xe0
 [<c11ecb9a>] ? do_raw_spin_trylock+0x3a/0x40
 [<c1365dae>] ? _raw_spin_trylock+0xe/0x50
 [<c109b08a>] ? __kmalloc_track_caller+0x9a/0x170
 [<c12fc1e9>] ? netpoll_send_skb_on_dev+0x109/0x220
 [<c12e2e74>] ? __alloc_skb+0x54/0x100
 [<c12fc4ee>] ? netpoll_send_udp+0x1ee/0x220
 [<c129ba8c>] ? write_msg+0x9c/0xd0
 [<c129b9f0>] ? write_msg+0x0/0xd0
 [<c102b2c3>] ? __call_console_drivers+0x43/0x60
 [<c102b32f>] ? _call_console_drivers+0x4f/0x80
 [<c102b651>] ? console_unlock+0xf1/0x200
 [<c102ba79>] ? vprintk+0x209/0x3b0
 [<c100205d>] ? do_signal+0x3bd/0x870
 [<c11d93c5>] ? ___ratelimit+0x85/0x100
 [<c136365e>] ? printk+0x18/0x1a
 [<c1078055>] ? __alloc_pages_nodemask+0x405/0x620
 [<c107828b>] ? __get_free_pages+0x1b/0x30
 [<c109a3e2>] ? __kmalloc+0x152/0x170
 [<c12e2507>] ? pskb_expand_head+0x147/0x2e0
 [<c12e29ff>] ? __pskb_pull_tail+0x23f/0x340
 [<c1050f8b>] ? trace_hardirqs_off+0xb/0x10
 [<c12ec592>] ? dev_hard_start_xmit+0x2a2/0x570
 [<c1365f1c>] ? _raw_spin_lock+0x5c/0x70
 [<c12fd590>] ? sch_direct_xmit+0x90/0x200
 [<c1365f1c>] ? _raw_spin_lock+0x5c/0x70
 [<c12ec9e8>] ? dev_queue_xmit+0x188/0x600
 [<c12ec860>] ? dev_queue_xmit+0x0/0x600
 [<c130b173>] ? ip_finish_output+0x133/0x400
 [<c130bdf7>] ? ip_output+0x67/0xc0
 [<c130b5d0>] ? ip_local_out+0x20/0x70
 [<c130b789>] ? ip_queue_xmit+0x169/0x420
 [<c130b620>] ? ip_queue_xmit+0x0/0x420
 [<c1047a42>] ? sched_clock_local.clone.1+0x42/0x1a0
 [<c131f6ec>] ? tcp_transmit_skb+0x35c/0x810
 [<c1320218>] ? tcp_write_xmit+0xf8/0x950
 [<c12e2188>] ? __kfree_skb+0x38/0x90
 [<c1320ad7>] ? __tcp_push_pending_frames+0x27/0xb0
 [<c131efe6>] ? tcp_current_mss+0x76/0xa0
 [<c131da56>] ? tcp_rcv_established+0x416/0x610
 [<c1324020>] ? tcp_v4_do_rcv+0x90/0x1e0
 [<c12dd4fc>] ? release_sock+0x5c/0x170
 [<c12dd53d>] ? release_sock+0x9d/0x170
 [<c131419c>] ? tcp_sendpage+0x9c/0x5c0
 [<c1314100>] ? tcp_sendpage+0x0/0x5c0
 [<c13327af>] ? inet_sendpage+0x3f/0xa0
 [<c1332770>] ? inet_sendpage+0x0/0xa0
 [<c12da158>] ? kernel_sendpage+0x28/0x50
 [<c134ff42>] ? svc_send_common+0xd2/0x120
 [<c134fff9>] ? svc_sendto+0x69/0x1a0
 [<c1047c5d>] ? sched_clock_cpu+0x7d/0xf0
 [<c1050f8b>] ? trace_hardirqs_off+0xb/0x10
 [<c1047d16>] ? local_clock+0x46/0x60
 [<c10537d6>] ? mark_held_locks+0x56/0x80
 [<c1364cc9>] ? mutex_lock_nested+0x1d9/0x2a0
 [<c1364cd3>] ? mutex_lock_nested+0x1e3/0x2a0
 [<c13501b3>] ? svc_tcp_sendto+0x33/0xa0
 [<c1359d7b>] ? svc_send+0x8b/0xe0
 [<c113f870>] ? nfs3svc_release_fhandle+0x0/0x20
 [<c134cbda>] ? svc_process+0x22a/0x750
 [<c11313e0>] ? nfsd+0xa0/0x130
 [<c1020cc8>] ? complete+0x48/0x60
 [<c1131340>] ? nfsd+0x0/0x130
 [<c1041fb4>] ? kthread+0x74/0x80
 [<c1041f40>] ? kthread+0x0/0x80
 [<c100307a>] ? kernel_thread_helper+0x6/0x1c
Pid: 1574, comm: nfsd Not tainted 2.6.38-rc5-00100-g0cc9d52 #1
Call Trace:
 [<c107805a>] ? __alloc_pages_nodemask+0x40a/0x620
 [<c107828b>] ? __get_free_pages+0x1b/0x30
 [<c109a3e2>] ? __kmalloc+0x152/0x170
 [<c12e2507>] ? pskb_expand_head+0x147/0x2e0
 [<c12e29ff>] ? __pskb_pull_tail+0x23f/0x340
 [<c1050f8b>] ? trace_hardirqs_off+0xb/0x10
 [<c12ec592>] ? dev_hard_start_xmit+0x2a2/0x570
 [<c1365f1c>] ? _raw_spin_lock+0x5c/0x70
 [<c12fd590>] ? sch_direct_xmit+0x90/0x200
 [<c1365f1c>] ? _raw_spin_lock+0x5c/0x70
 [<c12ec9e8>] ? dev_queue_xmit+0x188/0x600
 [<c12ec860>] ? dev_queue_xmit+0x0/0x600
 [<c130b173>] ? ip_finish_output+0x133/0x400
 [<c130bdf7>] ? ip_output+0x67/0xc0
 [<c130b5d0>] ? ip_local_out+0x20/0x70
 [<c130b789>] ? ip_queue_xmit+0x169/0x420
 [<c130b620>] ? ip_queue_xmit+0x0/0x420
 [<c1047a42>] ? sched_clock_local.clone.1+0x42/0x1a0
 [<c131f6ec>] ? tcp_transmit_skb+0x35c/0x810
 [<c1320218>] ? tcp_write_xmit+0xf8/0x950
 [<c12e2188>] ? __kfree_skb+0x38/0x90
 [<c1320ad7>] ? __tcp_push_pending_frames+0x27/0xb0
 [<c131efe6>] ? tcp_current_mss+0x76/0xa0
 [<c131da56>] ? tcp_rcv_established+0x416/0x610
 [<c1324020>] ? tcp_v4_do_rcv+0x90/0x1e0
 [<c12dd4fc>] ? release_sock+0x5c/0x170
 [<c12dd53d>] ? release_sock+0x9d/0x170
 [<c131419c>] ? tcp_sendpage+0x9c/0x5c0
 [<c1314100>] ? tcp_sendpage+0x0/0x5c0
 [<c13327af>] ? inet_sendpage+0x3f/0xa0
 [<c1332770>] ? inet_sendpage+0x0/0xa0
 [<c12da158>] ? kernel_sendpage+0x28/0x50
 [<c134ff42>] ? svc_send_common+0xd2/0x120
 [<c134fff9>] ? svc_sendto+0x69/0x1a0
 [<c1047c5d>] ? sched_clock_cpu+0x7d/0xf0
 [<c1050f8b>] ? trace_hardirqs_off+0xb/0x10
 [<c1047d16>] ? local_clock+0x46/0x60
 [<c10537d6>] ? mark_held_locks+0x56/0x80
 [<c1364cc9>] ? mutex_lock_nested+0x1d9/0x2a0
 [<c1364cd3>] ? mutex_lock_nested+0x1e3/0x2a0
 [<c13501b3>] ? svc_tcp_sendto+0x33/0xa0
 [<c1359d7b>] ? svc_send+0x8b/0xe0
 [<c113f870>] ? nfs3svc_release_fhandle+0x0/0x20
 [<c134cbda>] ? svc_process+0x22a/0x750
 [<c11313e0>] ? nfsd+0xa0/0x130
 [<c1020cc8>] ? complete+0x48/0x60
 [<c1131340>] ? nfsd+0x0/0x130
 [<c1041fb4>] ? kthread+0x74/0x80
 [<c1041f40>] ? kthread+0x0/0x80
 [<c100307a>] ? kernel_thread_helper+0x6/0x1c
