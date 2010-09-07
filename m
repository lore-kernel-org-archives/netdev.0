From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [2.6.36-rc3] NFS: possible irq lock inversion dependency
Date: Tue, 7 Sep 2010 21:32:44 +0900
Message-ID: <201009072132.FHA93457.MHOJFQOOFLVStF@I-love.SAKURA.ne.jp>
References: <201006242053.IAG26562.JHQFFOMSVFtOLO@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: linux-fsdevel@vger.kernel.org, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <201006242053.IAG26562.JHQFFOMSVFtOLO@I-love.SAKURA.ne.jp>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Tetsuo Handa wrote:
> Hello.
> 
> I sometimes get below warning when the system is about to reboot/halt.
> Is this already reported? If not, I'll try to establish steps to reproduce.

Although none of my patch's function is printed in the trace, this warning may
be my fault because I haven't succeeded to reproduce using vanilla kernels.
Does somebody know what's happening here?

Regards.

[  149.577099] nfsd: last server has exited, flushing export cache
[  151.108010] 
[  151.108015] =========================================================
[  151.109597] [ INFO: possible irq lock inversion dependency detected ]
[  151.110778] 2.6.36-rc3-ccs #2
[  151.110778] ------------------------               [<c104093f>] sys_exit_group+0xf/0x20
[  151.110778]                               78]                                          [<c106cd3a>] lock_acquire+0x7a/0xa0
[  151.110778]                                          [<c138f239>] _raw_spin_lock+0x39/0x70
[  151.110778]                                          [<c12dd021>] sk_clone+0xb1/0x2c0
[  151.110778]                                          [<c13134da>] inet_csk_clone+0x1a/0xb0
[  151.110778]                                          [<c1328a9c>] tcp_create_openreq_child+0x1c/0x460
[  151.110778]                                          [<c132616f>] tcp_v4_syn_recv_sock+0x3f/0x1e0
[  151.110778]                                          [<c132906c>] tcp_check_req+0x18c/0x3b0
[  151.110778]                                          [<c132635d>] tcp_v4_hnd_req+0x4d/0x160
[  151.110778]                                          [<c1326689>] tcp_v4_do_rcv+0x159/0x280
[  151.110778]                                          [<c1326d24>] tcp_v4_rcv+0x574/0xa30
[  151.110778]                                          [<c1308b63>] ip_local_deliver_finish+0x103/0x320
[  151.110778]                                          [<c1308db0>] ip_local_deliver+0x30/0x40
[  151.110778]                                          [<c1308f29>] ip_rcv_finish+0x169/0x480
[  151.110778]                                          [<c13093da>] ip_rcv+0x19a/0x2b0
[  151.110778]                                          [<c12ea04d>] __netif_receive_skb+0x21d/0x310
[  151.110778]                                          [<c12eab58>] process_backlog+0x88/0x160
[  151.110778]                                          [<c12eaf27>] net_rx_action+0x127/0x140
[  151.110778]                                          [<c1042e00>] __do_softirq+0xd0/0x130
[  151.110778]     INITIAL USE at:
[  151.110778]                                         [<c106b5d0>] __lock_acquire+0x1c0/0x8e0
[  151.110778]                                         [<c106cd3a>] lock_acquire+0x7a/0xa0
[  151.110778]                                         [<c138f3ae>] _raw_spin_lock_bh+0x3e/0x80
[  151.110778]                                         [<c12de689>] lock_sock_fast+0x29/0x90
[  151.110778]                                         [<c132e834>] udp_destroy_sock+0x14/0x40
[  151.110778]                                         [<c12de9e3>] sk_common_release+0xb3/0xc0
[  151.110778]                                         [<c132f1a8>] udp_lib_close+0x8/0x10
[  151.110778]                                         [<c133510e>] inet_release+0xbe/0x100
[  151.110778]                                         [<c12d8b96>] sock_release+0x66/0x80
[  151.110778]                                         [<c12d9912>] sock_close+0x12/0x30
[  151.110778]                                         [<c10c600b>] __fput+0x1cb/0x240
[  151.110778]                                         [<c10c6099>] fput+0x19/0x20
[  151.110778]                                         [<c10c3ed3>] filp_close+0x43/0x70
[  151.110778]                                         [<c103fd5d>] close_files+0xad/0x150
[  151.110778]                                         [<c103fe69>] put_files_struct+0x29/0xf0
[  151.110778]                                         [<c103ffc0>] exit_files+0x40/0x50
[  151.110778]                                         [<c1040686>] do_exit+0x116/0x2e0
[  151.110778]                                         [<c10408b4>] do_group_exit+0x34/0xb0
[  151.110778]                                         [<c104093f>] sys_exit_group+0xf/0x20
[  151.110778]                                         [<c138fe51>] syscall_call+0x7/0xb
[  151.110778]   }
[  151.110778]   ... key      at: [<c1d63a70>] af_family_slock_keys+0x10/0x140
[  151.110778]   ... acquired at:
[  151.110778]    [<c106924b>] check_prevs_add+0xab/0x100
[  151.110778]    [<c10695d5>] validate_chain+0x305/0x5a0
[  151.110778]    [<c106b6bd>] __lock_acquire+0x2ad/0x8e0
[  151.110778]    [<c106cd3a>] lock_acquire+0x7a/0xa0
[  151.110778]    [<c138f9ee>] _raw_write_lock_bh+0x3e/0x80
[  151.110778]    [<c1313806>] inet_csk_listen_stop+0x86/0x160
[  151.110778]    [<c1316348>] tcp_close+0x378/0x380
[  151.110778]    [<c133510e>] inet_release+0xbe/0x100
[  151.110778]    [<c12d8b96>] sock_release+0x66/0x80
[  151.110778]    [<c12d9912>] sock_close+0x12/0x30
[  151.110778]    [<c10c600b>] __fput+0x1cb/0x240
[  151.110778]    [<c10c6099>] fput+0x19/0x20
[  151.110778]    [<c10c3ed3>] filp_close+0x43/0x70
[  151.110778]    [<c10c3f6d>] sys_close+0x6d/0x110
[  151.110778]    [<c138fe51>] syscall_call+0x7/0xb
[  151.110778] 
[  151.110778] -> (clock-AF_INET){++.?..} ops: 1650 {
[  151.110778]    HARDIRQ-ON-W at:
[  151.110778]                                        [<c106aa1e>] mark_irqflags+0xfe/0x180
[  151.110778]                                        [<c106b79d>] __lock_acquire+0x38d/0x8e0
[  151.110778]                                        [<c106cd3a>] lock_acquire+0x7a/0xa0
[  151.110778]                                        [<c138f9ee>] _raw_write_lock_bh+0x3e/0x80
[  151.110778]                                        [<c12de95f>] sk_common_release+0x2f/0xc0
[  151.110778]                                        [<c132f1a8>] udp_lib_close+0x8/0x10
[  151.110778]                                        [<c133510e>] inet_release+0xbe/0x100
[  151.110778]                                        [<c12d8b96>] sock_release+0x66/0x80
[  151.110778]                                        [<c12d9912>] sock_close+0x12/0x30
[  151.110778]                                        [<c10c600b>] __fput+0x1cb/0x240
[  151.110778]                                        [<c10c6099>] fput+0x19/0x20
[  151.110778]                                        [<c10c3ed3>] filp_close+0x43/0x70
[  151.110778]                                        [<c103fd5d>] close_files+0xad/0x150
[  151.110778]                                        [<c103fe69>] put_files_struct+0x29/0xf0
[  151.110778]                                        [<c103ffc0>] exit_files+0x40/0x50
[  151.110778]                                        [<c1040686>] do_exit+0x116/0x2e0
[  151.110778]                                        [<c10408b4>] do_group_exit+0x34/0xb0
[  151.110778]                                        [<c104093f>] sys_exit_group+0xf/0x20
[  151.110778]                                        [<c138fe51>] syscall_call+0x7/0xb
[  151.110778]    HARDIRQ-ON-R at:
[  151.110778]                                        [<c106a98e>] mark_irqflags+0x6e/0x180
[  151.110778]                                        [<c106b79d>] __lock_acquire+0x38d/0x8e0
[  151.110778]                                        [<c106cd3a>] lock_acquire+0x7a/0xa0
[  151.110778]                                        [<c138f559>] _raw_read_lock+0x39/0x70
[  151.110778]                                        [<c13613ee>] xs_tcp_state_change+0x1e/0x1d0
[  151.110778]                                        [<c131f478>] tcp_rcv_synsent_state_process+0x398/0x590
[  151.110778]                                        [<c131fb17>] tcp_rcv_state_process+0x4a7/0x560
[  151.110778]                                        [<c13265a1>] tcp_v4_do_rcv+0x71/0x280
[  151.110778]                                        [<c12dd956>] __release_sock+0x66/0x150
[  151.110778]                                        [<c12de657>] release_sock+0x87/0x90
[  151.110778]                                        [<c13354fa>] inet_stream_connect+0x5a/0x1b0
[  151.110778]                                        [<c12db4b8>] kernel_connect+0x18/0x30
[  151.110778]                                        [<c136209e>] xs_tcp_finish_connecting+0x4e/0x120
[  151.110778]                                        [<c13621cb>] xs_tcp_setup_socket+0x5b/0x180
[  151.110778]                                        [<c1362404>] xs_tcp_connect_worker4+0x14/0x20
[  151.110778]                                        [<c1051617>] process_one_work+0x147/0x3a0
[  151.110778]                                        [<c1051956>] worker_thread+0xa6/0x200
[  151.110778]                                        [<c1056825>] kthread+0x75/0x80
[  151.110778]                                        [<c10031fa>] kernel_thread_helper+0x6/0x1c
[  151.110778]    IN-SOFTIRQ-R at:
[  151.110778]                                        [<c106aa3e>] mark_irqflags+0x11e/0x180
[  151.110778]                                        [<c106b79d>] __lock_acquire+0x38d/0x8e0
[  151.110778]                                        [<c106cd3a>] lock_acquire+0x7a/0xa0
[  151.110778]                                        [<c138f559>] _raw_read_lock+0x39/0x70
[  151.110778]                                        [<c13612c1>] xs_tcp_data_ready+0x21/0x90
[  151.110778]                                        [<c131d938>] tcp_data_queue+0x248/0x820
[  151.110778]                                        [<c131ecae>] tcp_rcv_established+0xae/0x4e0
[  151.110778]                                        [<c1326701>] tcp_v4_do_rcv+0x1d1/0x280
[  151.110778]                                        [<c1326d24>] tcp_v4_rcv+0x574/0xa30
[  151.110778]                                        [<c1308b63>] ip_local_deliver_finish+0x103/0x320
[  151.110778]                                        [<c1308db0>] ip_local_deliver+0x30/0x40
[  151.110778]                                        [<c1308f29>] ip_rcv_finish+0x169/0x480
[  151.110778]                                        [<c13093da>] ip_rcv+0x19a/0x2b0
[  151.110778]                                        [<c12ea04d>] __netif_receive_skb+0x21d/0x310
[  151.110778]                                        [<c12eab58>] process_backlog+0x88/0x160
[  151.110778]                                        [<c12eaf27>] net_rx_action+0x127/0x140
[  151.110778]                                        [<c1042e00>] __do_softirq+0xd0/0x130
[  151.110778]    SOFTIRQ-ON-R at:
[  151.110778]                                        [<c106aa02>] mark_irqflags+0xe2/0x180
[  151.110778]                                        [<c106b79d>] __lock_acquire+0x38d/0x8e0
[  151.110778]                                        [<c106cd3a>] lock_acquire+0x7a/0xa0
[  151.110778]                                        [<c138f559>] _raw_read_lock+0x39/0x70
[  151.110778]                                        [<c13613ee>] xs_tcp_state_change+0x1e/0x1d0
[  151.110778]                                        [<c1335be7>] inet_shutdown+0x97/0x110
[  151.110778]                                        [<c12db6b9>] kernel_sock_shutdown+0x9/0x10
[  151.110778]                                        [<c13606e7>] xs_tcp_shutdown+0x17/0x20
[  151.110778]                                        [<c13609e7>] xs_tcp_close+0x27/0x30
[  151.110778]                                        [<c135ec3d>] xprt_autoclose+0x1d/0x50
[  151.110778]                                        [<c1051617>] process_one_work+0x147/0x3a0
[  151.110778]                                        [<c1051956>] worker_thread+0xa6/0x200
[  151.110778]                                        [<c1056825>] kthread+0x75/0x80
[  151.110778]                                        [<c10031fa>] kernel_thread_helper+0x6/0x1c
[  151.110778]    INITIAL USE at:
[  151.110778]                                       [<c106b5d0>] __lock_acquire+0x1c0/0x8e0
[  151.110778]                                       [<c106cd3a>] lock_acquire+0x7a/0xa0
[  151.110778]                                       [<c138f9ee>] _raw_write_lock_bh+0x3e/0x80
[  151.110778]                                       [<c12de95f>] sk_common_release+0x2f/0xc0
[  151.110778]                                       [<c132f1a8>] udp_lib_close+0x8/0x10
[  151.110778]                                       [<c133510e>] inet_release+0xbe/0x100
[  151.110778]                                       [<c12d8b96>] sock_release+0x66/0x80
[  151.110778]                                       [<c12d9912>] sock_close+0x12/0x30
[  151.110778]                                       [<c10c600b>] __fput+0x1cb/0x240
[  151.110778]                                       [<c10c6099>] fput+0x19/0x20
[  151.110778]                                       [<c10c3ed3>] filp_close+0x43/0x70
[  151.110778]                                       [<c103fd5d>] close_files+0xad/0x150
[  151.110778]                                       [<c103fe69>] put_files_struct+0x29/0xf0
[  151.110778]                                       [<c103ffc0>] exit_files+0x40/0x50
[  151.110778]                                       [<c1040686>] do_exit+0x116/0x2e0
[  151.110778]                                       [<c10408b4>] do_group_exit+0x34/0xb0
[  151.110778]                                       [<c104093f>] sys_exit_group+0xf/0x20
[  151.110778]                                       [<c138fe51>] syscall_call+0x7/0xb
[  151.110778]  }
[  151.110778]  ... key      at: [<c1d63bb0>] af_callback_keys+0x10/0x130
[  151.110778]  ... acquired at:
[  151.110778]    [<c1069e86>] check_usage_backwards+0x76/0xd0
[  151.110778]    [<c106a099>] mark_lock_irq+0x99/0x240
[  151.110778]    [<c106ad3c>] mark_lock+0x21c/0x3c0
[  151.110778]    [<c106aa02>] mark_irqflags+0xe2/0x180
[  151.110778]    [<c106b79d>] __lock_acquire+0x38d/0x8e0
[  151.110778]    [<c106cd3a>] lock_acquire+0x7a/0xa0
[  151.110778]    [<c138f559>] _raw_read_lock+0x39/0x70
[  151.110778]    [<c13613ee>] xs_tcp_state_change+0x1e/0x1d0
[  151.110778]    [<c1335be7>] inet_shutdown+0x97/0x110
[  151.110778]    [<c12db6b9>] kernel_sock_shutdown+0x9/0x10
[  151.110778]    [<c13606e7>] xs_tcp_shutdown+0x17/0x20
[  151.110778]    [<c13609e7>] xs_tcp_close+0x27/0x30
[  151.110778]    [<c135ec3d>] xprt_autoclose+0x1d/0x50
[  151.110778]    [<c1051617>] process_one_work+0x147/0x3a0
[  151.110778]    [<c1051956>] worker_thread+0xa6/0x200
[  151.110778]    [<c1056825>] kthread+0x75/0x80
[  151.110778]    [<c10031fa>] kernel_thread_helper+0x6/0x1c
[  151.110778] 
[  151.110778] 
[  151.110778] stack backtrace:
[  151.110778] Pid: 418, comm: kworker/1:1 Not tainted 2.6.36-rc3-ccs #2
[  151.110778] Call Trace:
[  151.110778]  [<c103de48>] ? printk+0x18/0x20
[  151.110778]  [<c1069d18>] print_irq_inversion_bug+0x108/0x120
[  151.110778]  [<c1069e86>] check_usage_backwards+0x76/0xd0
[  151.110778]  [<c106a099>] mark_lock_irq+0x99/0x240
[  151.110778]  [<c1069e10>] ? check_usage_backwards+0x0/0xd0
[  151.110778]  [<c106ad3c>] mark_lock+0x21c/0x3c0
[  151.110778]  [<c106aa02>] mark_irqflags+0xe2/0x180
[  151.110778]  [<c106b79d>] __lock_acquire+0x38d/0x8e0
[  151.110778]  [<c106ca9a>] ? __lock_is_held+0x3a/0x60
[  151.110778]  [<c106cd3a>] lock_acquire+0x7a/0xa0
[  151.110778]  [<c13613ee>] ? xs_tcp_state_change+0x1e/0x1d0
[  151.110778]  [<c138f559>] _raw_read_lock+0x39/0x70
[  151.110778]  [<c13613ee>] ? xs_tcp_state_change+0x1e/0x1d0
[  151.110778]  [<c13613ee>] xs_tcp_state_change+0x1e/0x1d0
[  151.110778]  [<c13229af>] ? tcp_send_fin+0x4f/0xc0
[  151.110778]  [<c1335be7>] inet_shutdown+0x97/0x110
[  151.110778]  [<c12db6b9>] kernel_sock_shutdown+0x9/0x10
[  151.110778]  [<c13606e7>] xs_tcp_shutdown+0x17/0x20
[  151.110778]  [<c13609e7>] xs_tcp_close+0x27/0x30
[  151.110778]  [<c135ec3d>] xprt_autoclose+0x1d/0x50
[  151.110778]  [<c1051617>] process_one_work+0x147/0x3a0
[  151.110778]  [<c10515a6>] ? process_one_work+0xd6/0x3a0
[  151.110778]  [<c106d2b9>] ? __lock_acquired+0x119/0x1c0
[  151.110778]  [<c135ec20>] ? xprt_autoclose+0x0/0x50
[  151.110778]  [<c10518cc>] ? worker_thread+0x1c/0x200
[  151.110778]  [<c1050457>] ? __need_more_worker+0x17/0x40
[  151.110778]  [<c1051956>] worker_thread+0xa6/0x200
[  151.110778]  [<c1056825>] kthread+0x75/0x80
[  151.110778]  [<c10518b0>] ? worker_thread+0x0/0x200
[  151.110778]  [<c10567b0>] ? kthread+0x0/0x80
[  151.110778]  [<c10031fa>] kernel_thread_helper+0x6/0x1c
[  159.600716] Restarting system.
[  159.601345] machine restart
