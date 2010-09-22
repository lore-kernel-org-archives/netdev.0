From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: Re: [2.6.36-rc5] INET?: possible irq lock inversion dependency
Date: Wed, 22 Sep 2010 17:58:08 +0900
Message-ID: <201009220858.o8M8w8s3094017@www262.sakura.ne.jp>
References: <201006242053.IAG26562.JHQFFOMSVFtOLO@I-love.SAKURA.ne.jp> <201009072132.FHA93457.MHOJFQOOFLVStF@I-love.SAKURA.ne.jp> <201009210651.o8L6pbkP038129@www262.sakura.ne.jp> <1285055760.2617.27.camel@edumazet-laptop> <201009210910.o8L9Anaf071504@www262.sakura.ne.jp> <1285061757.2617.176.camel@edumazet-laptop> <1285064011.2617.238.camel@edumazet-laptop> <201009220714.o8M7Ebps067361@www262.sakura.ne.jp> <1285144306.2639.90.camel@edumazet-laptop> <1285144471.2639.96.camel@edumazet-laptop> <1285144681.2639.102.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Cc: linux-fsdevel@vger.kernel.org, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from www262.sakura.ne.jp ([202.181.97.72]:54911 "EHLO
	www262.sakura.ne.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752040Ab0IVI6L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Sep 2010 04:58:11 -0400
In-Reply-To: <1285144681.2639.102.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Updated and booted/tested patch :

The warning by test.sh disappeared by your patch.
But the warning which I encounter upon reboot still appears.

[   74.289683] nfsd: last server has exited, flushing export cache
[   75.935807] 
[   75.935811] =========================================================
[   75.937431] [ INFO: possible irq lock inversion dependency detected ]
[   75.937431] 2.6.36-rc5 #2
[   75.937431] ---------------------------------------------------------
[   75.937431] kworker/1:1/418 just changed the state of lock:
[   75.937431]  (clock-AF_INET#2){++.?..}, at: [<c135ddee>] xs_tcp_state_change+0x1e/0x1d0
[   75.937431] but this lock was taken by another, SOFTIRQ-safe lock in the past:
[   75.937431]  (slock-AF_INET){+.-...}
[   75.937431] 
[   75.937431] and interrupts could create inverse lock ordering between them.
[   75.937431] 
[   75.937431] 
[   75.937431] other info that might help us debug this:
[   75.937431] 3 locks held by kworker/1:1/418:
[   75.937431]  #0:  (rpciod){+.+.+.}, at: [<c10514d6>] process_one_work+0xd6/0x3a0
[   75.937431]  #1:  ((&xprt->task_cleanup)){+.+...}, at: [<c10514d6>] process_one_work+0xd6/0x3a0
[   75.937431]  #2:  (sk_lock-AF_INET-RPC){+.+...}, at: [<c1332549>] inet_shutdown+0x49/0x110
[   75.937431] 
[   75.937431] the shortest dependencies between 2nd lock and 1st lock:
[   75.937431]  -> (slock-AF_INET){+.-...} ops: 1648 {
[   75.937431]     HARDIRQ-ON-W at:
[   75.937431]                                          [<c106a8de>] mark_irqflags+0xfe/0x180
[   75.937431]                                          [<c106b65d>] __lock_acquire+0x38d/0x8e0
[   75.937431]                                          [<c106cbfa>] lock_acquire+0x7a/0xa0
[   75.937431]                                          [<c138be6e>] _raw_spin_lock_bh+0x3e/0x80
[   75.937431]                                          [<c12daf79>] lock_sock_fast+0x29/0x90
[   75.937431]                                          [<c132b1e4>] udp_destroy_sock+0x14/0x40
[   75.937431]                                          [<c12db2d3>] sk_common_release+0xb3/0xc0
[   75.937431]                                          [<c132bb58>] udp_lib_close+0x8/0x10
[   75.937431]                                          [<c1331abe>] inet_release+0xbe/0x100
[   75.937431]                                          [<c12d5476>] sock_release+0x66/0x80
[   75.937431]                                          [<c12d61f2>] sock_close+0x12/0x30
[   75.937431]                                          [<c10c637b>] __fput+0x1cb/0x240
[   75.937431]                                          [<c10c6409>] fput+0x19/0x20
[   75.937431]                                          [<c10c4263>] filp_close+0x43/0x70
[   75.937431]                                          [<c103fdcd>] close_files+0xad/0x150
[   75.937431]                                          [<c103fed9>] put_files_struct+0x29/0xf0
[   75.937431]                                          [<c1040030>] exit_files+0x40/0x50
[   75.937431]                                          [<c10406f6>] do_exit+0x116/0x2e0
[   75.937431]                                          [<c1040924>] do_group_exit+0x34/0xb0
[   75.937431]                                          [<c10409af>] sys_exit_group+0xf/0x20
[   75.937431]                                          [<c138c911>] syscall_call+0x7/0xb
[   75.937431]     IN-SOFTIRQ-W at:
[   75.937431]                                          [<c106a8fe>] mark_irqflags+0x11e/0x180
[   75.937431]                                          [<c106b65d>] __lock_acquire+0x38d/0x8e0
[   75.937431]                                          [<c106cbfa>] lock_acquire+0x7a/0xa0
[   75.937431]                                          [<c138bcf9>] _raw_spin_lock+0x39/0x70
[   75.937431]                                          [<c12d98d1>] sk_clone+0xb1/0x2e0
[   75.937431]                                          [<c130fdba>] inet_csk_clone+0x1a/0xb0
[   75.937431]                                          [<c132539c>] tcp_create_openreq_child+0x1c/0x460
[   75.937431]                                          [<c1322a6f>] tcp_v4_syn_recv_sock+0x3f/0x1e0
[   75.937431]                                          [<c132596c>] tcp_check_req+0x18c/0x3b0
[   75.937431]                                          [<c1322c5d>] tcp_v4_hnd_req+0x4d/0x160
[   75.937431]                                          [<c1322f89>] tcp_v4_do_rcv+0x159/0x280
[   75.937431]                                          [<c1323624>] tcp_v4_rcv+0x574/0xa30
[   75.937431]                                          [<c1305483>] ip_local_deliver_finish+0x103/0x320
[   75.937431]                                          [<c13056d0>] ip_local_deliver+0x30/0x40
[   75.937431]                                          [<c1305849>] ip_rcv_finish+0x169/0x480
[   75.937431]                                          [<c1305cfa>] ip_rcv+0x19a/0x2b0
[   75.937431]                                          [<c12e695d>] __netif_receive_skb+0x21d/0x310
[   75.937431]                                          [<c12e7468>] process_backlog+0x88/0x160
[   75.937431]                                          [<c12e7837>] net_rx_action+0x127/0x140
[   75.937431]                                          [<c1042e70>] __do_softirq+0xd0/0x130
[   75.937431]     INITIAL USE at:
[   75.937431]                                         [<c106b490>] __lock_acquire+0x1c0/0x8e0
[   75.937431]                                         [<c106cbfa>] lock_acquire+0x7a/0xa0
[   75.937431]                                         [<c138be6e>] _raw_spin_lock_bh+0x3e/0x80
[   75.937431]                                         [<c12daf79>] lock_sock_fast+0x29/0x90
[   75.937431]                                         [<c132b1e4>] udp_destroy_sock+0x14/0x40
[   75.937431]                                         [<c12db2d3>] sk_common_release+0xb3/0xc0
[   75.937431]                                         [<c132bb58>] udp_lib_close+0x8/0x10
[   75.937431]                                         [<c1331abe>] inet_release+0xbe/0x100
[   75.937431]                                         [<c12d5476>] sock_release+0x66/0x80
[   75.937431]                                         [<c12d61f2>] sock_close+0x12/0x30
[   75.937431]                                         [<c10c637b>] __fput+0x1cb/0x240
[   75.937431]                                         [<c10c6409>] fput+0x19/0x20
[   75.937431]                                         [<c10c4263>] filp_close+0x43/0x70
[   75.937431]                                         [<c103fdcd>] close_files+0xad/0x150
[   75.937431]                                         [<c103fed9>] put_files_struct+0x29/0xf0
[   75.937431]                                         [<c1040030>] exit_files+0x40/0x50
[   75.937431]                                         [<c10406f6>] do_exit+0x116/0x2e0
[   75.937431]                                         [<c1040924>] do_group_exit+0x34/0xb0
[   75.937431]                                         [<c10409af>] sys_exit_group+0xf/0x20
[   75.937431]                                         [<c138c911>] syscall_call+0x7/0xb
[   75.937431]   }
[   75.937431]   ... key      at: [<c1d4c9d0>] af_family_slock_keys+0x10/0x140
[   75.937431]   ... acquired at:
[   75.937431]    [<c106910b>] check_prevs_add+0xab/0x100
[   75.937431]    [<c1069495>] validate_chain+0x305/0x5a0
[   75.937431]    [<c106b57d>] __lock_acquire+0x2ad/0x8e0
[   75.937431]    [<c106cbfa>] lock_acquire+0x7a/0xa0
[   75.937431]    [<c138c4ae>] _raw_write_lock_bh+0x3e/0x80
[   75.937431]    [<c13100e6>] inet_csk_listen_stop+0x86/0x160
[   75.937431]    [<c1312c42>] tcp_close+0x382/0x390
[   75.937431]    [<c1331abe>] inet_release+0xbe/0x100
[   75.937431]    [<c12d5476>] sock_release+0x66/0x80
[   75.937431]    [<c12d61f2>] sock_close+0x12/0x30
[   75.937431]    [<c10c637b>] __fput+0x1cb/0x240
[   75.937431]    [<c10c6409>] fput+0x19/0x20
[   75.937431]    [<c10c4263>] filp_close+0x43/0x70
[   75.937431]    [<c10c42fd>] sys_close+0x6d/0x110
[   75.937431]    [<c138c911>] syscall_call+0x7/0xb
[   75.937431] 
[   75.937431] -> (clock-AF_INET#2){++.?..} ops: 96 {
[   75.937431]    HARDIRQ-ON-W at:
[   75.937431]                                        [<c106a8de>] mark_irqflags+0xfe/0x180
[   75.937431]                                        [<c106b65d>] __lock_acquire+0x38d/0x8e0
[   75.937431]                                        [<c106cbfa>] lock_acquire+0x7a/0xa0
[   75.937431]                                        [<c138c4ae>] _raw_write_lock_bh+0x3e/0x80
[   75.937431]                                        [<c135eac3>] xs_tcp_finish_connecting+0x73/0x120
[   75.937431]                                        [<c135ebcb>] xs_tcp_setup_socket+0x5b/0x180
[   75.937431]                                        [<c135ee04>] xs_tcp_connect_worker4+0x14/0x20
[   75.937431]                                        [<c1051547>] process_one_work+0x147/0x3a0
[   75.937431]                                        [<c1051886>] worker_thread+0xa6/0x200
[   75.937431]                                        [<c1056765>] kthread+0x75/0x80
[   75.937431]                                        [<c10031fa>] kernel_thread_helper+0x6/0x1c
[   75.937431]    HARDIRQ-ON-R at:
[   75.937431]                                        [<c106a84e>] mark_irqflags+0x6e/0x180
[   75.937431]                                        [<c106b65d>] __lock_acquire+0x38d/0x8e0
[   75.937431]                                        [<c106cbfa>] lock_acquire+0x7a/0xa0
[   75.937431]                                        [<c138c019>] _raw_read_lock+0x39/0x70
[   75.937431]                                        [<c135ddee>] xs_tcp_state_change+0x1e/0x1d0
[   75.937431]                                        [<c131bd78>] tcp_rcv_synsent_state_process+0x398/0x590
[   75.937431]                                        [<c131c417>] tcp_rcv_state_process+0x4a7/0x560
[   75.937431]                                        [<c1322ea1>] tcp_v4_do_rcv+0x71/0x280
[   75.937431]                                        [<c12da226>] __release_sock+0x66/0x150
[   75.937431]                                        [<c12daf47>] release_sock+0x87/0x90
[   75.937431]                                        [<c1331eaa>] inet_stream_connect+0x5a/0x1b0
[   75.937431]                                        [<c12d7d68>] kernel_connect+0x18/0x30
[   75.937431]                                        [<c135ea9e>] xs_tcp_finish_connecting+0x4e/0x120
[   75.937431]                                        [<c135ebcb>] xs_tcp_setup_socket+0x5b/0x180
[   75.937431]                                        [<c135ee04>] xs_tcp_connect_worker4+0x14/0x20
[   75.937431]                                        [<c1051547>] process_one_work+0x147/0x3a0
[   75.937431]                                        [<c1051886>] worker_thread+0xa6/0x200
[   75.937431]                                        [<c1056765>] kthread+0x75/0x80
[   75.937431]                                        [<c10031fa>] kernel_thread_helper+0x6/0x1c
[   75.937431]    IN-SOFTIRQ-R at:
[   75.937431]                                        [<c106a8fe>] mark_irqflags+0x11e/0x180
[   75.937431]                                        [<c106b65d>] __lock_acquire+0x38d/0x8e0
[   75.937431]                                        [<c106cbfa>] lock_acquire+0x7a/0xa0
[   75.937431]                                        [<c138c019>] _raw_read_lock+0x39/0x70
[   75.937431]                                        [<c135dcc1>] xs_tcp_data_ready+0x21/0x90
[   75.937431]                                        [<c131a238>] tcp_data_queue+0x248/0x820
[   75.937431]                                        [<c131b5ae>] tcp_rcv_established+0xae/0x4e0
[   75.937431]                                        [<c1323001>] tcp_v4_do_rcv+0x1d1/0x280
[   75.937431]                                        [<c1323624>] tcp_v4_rcv+0x574/0xa30
[   75.937431]                                        [<c1305483>] ip_local_deliver_finish+0x103/0x320
[   75.937431]                                        [<c13056d0>] ip_local_deliver+0x30/0x40
[   75.937431]                                        [<c1305849>] ip_rcv_finish+0x169/0x480
[   75.937431]                                        [<c1305cfa>] ip_rcv+0x19a/0x2b0
[   75.937431]                                        [<c12e695d>] __netif_receive_skb+0x21d/0x310
[   75.937431]                                        [<c12e7468>] process_backlog+0x88/0x160
[   75.937431]                                        [<c12e7837>] net_rx_action+0x127/0x140
[   75.937431]                                        [<c1042e70>] __do_softirq+0xd0/0x130
[   75.937431]    SOFTIRQ-ON-R at:
[   75.937431]                                        [<c106a8c2>] mark_irqflags+0xe2/0x180
[   75.937431]                                        [<c106b65d>] __lock_acquire+0x38d/0x8e0
[   75.937431]                                        [<c106cbfa>] lock_acquire+0x7a/0xa0
[   75.937431]                                        [<c138c019>] _raw_read_lock+0x39/0x70
[   75.937431]                                        [<c135ddee>] xs_tcp_state_change+0x1e/0x1d0
[   75.937431]                                        [<c1332597>] inet_shutdown+0x97/0x110
[   75.937431]                                        [<c12d7f69>] kernel_sock_shutdown+0x9/0x10
[   75.937431]                                        [<c135d0e7>] xs_tcp_shutdown+0x17/0x20
[   75.937431]                                        [<c135d3e7>] xs_tcp_close+0x27/0x30
[   75.937431]                                        [<c135b63d>] xprt_autoclose+0x1d/0x50
[   75.937431]                                        [<c1051547>] process_one_work+0x147/0x3a0
[   75.937431]                                        [<c1051886>] worker_thread+0xa6/0x200
[   75.937431]                                        [<c1056765>] kthread+0x75/0x80
[   75.937431]                                        [<c10031fa>] kernel_thread_helper+0x6/0x1c
[   75.937431]    INITIAL USE at:
[   75.937431]                                       [<c106b490>] __lock_acquire+0x1c0/0x8e0
[   75.937431]                                       [<c106cbfa>] lock_acquire+0x7a/0xa0
[   75.937431]                                       [<c138c4ae>] _raw_write_lock_bh+0x3e/0x80
[   75.937431]                                       [<c135eac3>] xs_tcp_finish_connecting+0x73/0x120
[   75.937431]                                       [<c135ebcb>] xs_tcp_setup_socket+0x5b/0x180
[   75.937431]                                       [<c135ee04>] xs_tcp_connect_worker4+0x14/0x20
[   75.937431]                                       [<c1051547>] process_one_work+0x147/0x3a0
[   75.937431]                                       [<c1051886>] worker_thread+0xa6/0x200
[   75.937431]                                       [<c1056765>] kthread+0x75/0x80
[   75.937431]                                       [<c10031fa>] kernel_thread_helper+0x6/0x1c
[   75.937431]  }
[   75.937431]  ... key      at: [<c1d4cb10>] af_callback_keys+0x10/0x130
[   75.937431]  ... acquired at:
[   75.937431]    [<c1069d46>] check_usage_backwards+0x76/0xd0
[   75.937431]    [<c1069f59>] mark_lock_irq+0x99/0x240
[   75.937431]    [<c106abfc>] mark_lock+0x21c/0x3c0
[   75.937431]    [<c106a8c2>] mark_irqflags+0xe2/0x180
[   75.937431]    [<c106b65d>] __lock_acquire+0x38d/0x8e0
[   75.937431]    [<c106cbfa>] lock_acquire+0x7a/0xa0
[   75.937431]    [<c138c019>] _raw_read_lock+0x39/0x70
[   75.937431]    [<c135ddee>] xs_tcp_state_change+0x1e/0x1d0
[   75.937431]    [<c1332597>] inet_shutdown+0x97/0x110
[   75.937431]    [<c12d7f69>] kernel_sock_shutdown+0x9/0x10
[   75.937431]    [<c135d0e7>] xs_tcp_shutdown+0x17/0x20
[   75.937431]    [<c135d3e7>] xs_tcp_close+0x27/0x30
[   75.937431]    [<c135b63d>] xprt_autoclose+0x1d/0x50
[   75.937431]    [<c1051547>] process_one_work+0x147/0x3a0
[   75.937431]    [<c1051886>] worker_thread+0xa6/0x200
[   75.937431]    [<c1056765>] kthread+0x75/0x80
[   75.937431]    [<c10031fa>] kernel_thread_helper+0x6/0x1c
[   75.937431] 
[   75.937431] 
[   75.937431] stack backtrace:
[   75.937431] Pid: 418, comm: kworker/1:1 Not tainted 2.6.36-rc5 #2
[   75.937431] Call Trace:
[   75.937431]  [<c103deb8>] ? printk+0x18/0x20
[   75.937431]  [<c1069bd8>] print_irq_inversion_bug+0x108/0x120
[   75.937431]  [<c1069d46>] check_usage_backwards+0x76/0xd0
[   75.937431]  [<c1069f59>] mark_lock_irq+0x99/0x240
[   75.937431]  [<c1069cd0>] ? check_usage_backwards+0x0/0xd0
[   75.937431]  [<c106abfc>] mark_lock+0x21c/0x3c0
[   75.937431]  [<c106a8c2>] mark_irqflags+0xe2/0x180
[   75.937431]  [<c106b65d>] __lock_acquire+0x38d/0x8e0
[   75.937431]  [<c106c95a>] ? __lock_is_held+0x3a/0x60
[   75.937431]  [<c106cbfa>] lock_acquire+0x7a/0xa0
[   75.937431]  [<c135ddee>] ? xs_tcp_state_change+0x1e/0x1d0
[   75.937431]  [<c138c019>] _raw_read_lock+0x39/0x70
[   75.937431]  [<c135ddee>] ? xs_tcp_state_change+0x1e/0x1d0
[   75.937431]  [<c135ddee>] xs_tcp_state_change+0x1e/0x1d0
[   75.937431]  [<c131f2af>] ? tcp_send_fin+0x4f/0xc0
[   75.937431]  [<c1332597>] inet_shutdown+0x97/0x110
[   75.937431]  [<c12d7f69>] kernel_sock_shutdown+0x9/0x10
[   75.937431]  [<c135d0e7>] xs_tcp_shutdown+0x17/0x20
[   75.937431]  [<c135d3e7>] xs_tcp_close+0x27/0x30
[   75.937431]  [<c135b63d>] xprt_autoclose+0x1d/0x50
[   75.937431]  [<c1051547>] process_one_work+0x147/0x3a0
[   75.937431]  [<c10514d6>] ? process_one_work+0xd6/0x3a0
[   75.937431]  [<c106d179>] ? __lock_acquired+0x119/0x1c0
[   75.937431]  [<c135b620>] ? xprt_autoclose+0x0/0x50
[   75.937431]  [<c10517fc>] ? worker_thread+0x1c/0x200
[   75.937431]  [<c1050317>] ? __need_more_worker+0x17/0x40
[   75.937431]  [<c1051886>] worker_thread+0xa6/0x200
[   75.937431]  [<c1056765>] kthread+0x75/0x80
[   75.937431]  [<c10517e0>] ? worker_thread+0x0/0x200
[   75.937431]  [<c10566f0>] ? kthread+0x0/0x80
[   75.937431]  [<c10031fa>] kernel_thread_helper+0x6/0x1c
[   83.749463] Restarting system.
[   83.751581] machine restart

FYI,

  # cat /etc/exports
  /usr/src/ *(rw,no_root_squash,async)

  # grep nfs /proc/mounts
  127.0.0.1:/usr/src/ /mnt nfs rw,relatime,vers=3,rsize=32768,wsize=32768,namlen=255,hard,proto=udp,port=65535,timeo=7,retrans=3,sec=sys,addr=127.0.0.1 0 0

test.sh does not trigger this warning on 2.6.34.7 and
triggers this warning on 2.6.35.5 .

Regards.
