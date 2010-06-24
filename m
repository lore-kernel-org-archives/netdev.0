From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [2.6.35-rc3] NFS: possible irq lock inversion dependency
Date: Thu, 24 Jun 2010 20:53:44 +0900
Message-ID: <201006242053.IAG26562.JHQFFOMSVFtOLO@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: linux-fsdevel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wine.ocn.ne.jp ([122.1.235.145]:54485 "EHLO smtp.wine.ocn.ne.jp"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751740Ab0FXLxq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Jun 2010 07:53:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

I sometimes get below warning when the system is about to reboot/halt.
Is this already reported? If not, I'll try to establish steps to reproduce.

----- Dump 1 -----

[  508.594713] nfsd: last server has exited, flushing export cache
[  509.100525] 
[  509.100529] =========================================================
[  509.102129] [ INFO: possible irq lock inversion dependency detected ]
<4>[  509.102513]                                       [<c103f69f>] sys_exit_group+0xf/0x20
<4>[  509.102513]                                       [<c13327e1>] syscall_call+0x7/0xb
[  509.102513]  }
[  509.102513]  ... key      at: [<c1cbfd90>] af_callback_keys+0x10/0x130
[  509.102513]  ... acquired at:
[  509.102513]    [<c10656c6>] check_usage_backwards+0x76/0xd0
[  509.102513]    [<c10658d9>] mark_lock_irq+0x99/0x240
[  509.102513]    [<c106657c>] mark_lock+0x21c/0x3c0
[  509.102513]    [<c1066242>] mark_irqflags+0xe2/0x180
[  509.102513]    [<c1066fdd>] __lock_acquire+0x38d/0x8e0
[  509.102513]    [<c106857a>] lock_acquire+0x7a/0xa0
[  509.102513]    [<c1331f69>] _raw_read_lock+0x39/0x70
[  509.102513]    [<c130a0ae>] xs_tcp_state_change+0x1e/0x1c0
[  509.102513]    [<c12e2397>] inet_shutdown+0x97/0x110
[  509.102513]    [<c1289649>] kernel_sock_shutdown+0x9/0x10
[  509.102513]    [<c13093a7>] xs_tcp_shutdown+0x17/0x20
[  509.102513]    [<c13096a7>] xs_tcp_close+0x27/0x30
[  509.102513]    [<c130792d>] xprt_autoclose+0x1d/0x50
[  509.102513]    [<c104edc0>] run_workqueue+0xe0/0x1d0
[  509.102513]    [<c104ef4b>] worker_thread+0x9b/0xd0
[  509.102513]    [<c1052a65>] kthread+0x75/0x80
[  509.102513]    [<c100317a>] kernel_thread_helper+0x6/0x1c
[  509.102513] 
[  509.102513] 
[  509.102513] stack backtrace:
[  509.102513] Pid: 337, comm: rpciod/1 Not tainted 2.6.35-rc3-ccs #6
[  509.102513] Call Trace:
[  509.102513]  [<c103cbe8>] ? printk+0x18/0x20
[  509.102513]  [<c1065558>] print_irq_inversion_bug+0x108/0x120
[  509.102513]  [<c10656c6>] check_usage_backwards+0x76/0xd0
[  509.102513]  [<c10658d9>] mark_lock_irq+0x99/0x240
[  509.102513]  [<c1065650>] ? check_usage_backwards+0x0/0xd0
[  509.102513]  [<c106657c>] mark_lock+0x21c/0x3c0
[  509.102513]  [<c1066242>] mark_irqflags+0xe2/0x180
[  509.102513]  [<c1066fdd>] __lock_acquire+0x38d/0x8e0
[  509.102513]  [<c10682da>] ? __lock_is_held+0x3a/0x60
[  509.102513]  [<c106857a>] lock_acquire+0x7a/0xa0
[  509.102513]  [<c130a0ae>] ? xs_tcp_state_change+0x1e/0x1c0
[  509.102513]  [<c1331f69>] _raw_read_lock+0x39/0x70
[  509.102513]  [<c130a0ae>] ? xs_tcp_state_change+0x1e/0x1c0
[  509.102513]  [<c130a0ae>] xs_tcp_state_change+0x1e/0x1c0
[  509.102513]  [<c12cf3bf>] ? tcp_send_fin+0x4f/0xc0
[  509.102513]  [<c12e2397>] inet_shutdown+0x97/0x110
[  509.102513]  [<c104ed5e>] ? run_workqueue+0x7e/0x1d0
[  509.102513]  [<c1289649>] kernel_sock_shutdown+0x9/0x10
[  509.102513]  [<c13093a7>] xs_tcp_shutdown+0x17/0x20
[  509.102513]  [<c13096a7>] xs_tcp_close+0x27/0x30
[  509.102513]  [<c130792d>] xprt_autoclose+0x1d/0x50
[  509.102513]  [<c104edc0>] run_workqueue+0xe0/0x1d0
[  509.102513]  [<c104ed5e>] ? run_workqueue+0x7e/0x1d0
[  509.102513]  [<c1307910>] ? xprt_autoclose+0x0/0x50
[  509.102513]  [<c1052e8a>] ? prepare_to_wait+0x3a/0x60
[  509.102513]  [<c104ef4b>] worker_thread+0x9b/0xd0
[  509.102513]  [<c1053000>] ? autoremove_wake_function+0x0/0x50
[  509.102513]  [<c1053000>] ? autoremove_wake_function+0x0/0x50
[  509.102513]  [<c1035456>] ? complete+0x46/0x60
[  509.102513]  [<c1052a65>] kthread+0x75/0x80
[  509.102513]  [<c104eeb0>] ? worker_thread+0x0/0xd0
[  509.102513]  [<c10529f0>] ? kthread+0x0/0x80
[  509.102513]  [<c10529f0>] ? kthread+0x0/0x80
[  509.102513]  [<c100317a>] kernel_thread_helper+0x6/0x1c
9>] _raw_spin_lock+0x39/0x70
[  509.102513]                                          [<c128ae51>] sk_clone+0xb1/0x2c0
[  509.102513]                                          [<c12c0046>] inet_csk_clone+0x16/0x90
[  509.102513]                                          [<c12d519c>] tcp_create_openreq_child+0x1c/0x460
[  509.102513]                                          [<c12d2a1f>] tcp_v4_syn_recv_sock+0x3f/0x1e0
[  509.102513]                                          [<c12d576c>] tcp_check_req+0x18c/0x3b0
[  509.102513]                                          [<c12d2c0d>] tcp_v4_hnd_req+0x4d/0x160
[  509.102513]                                          [<c12d2f39>] tcp_v4_do_rcv+0x159/0x280
[  509.102513]                                          [<c12d35d4>] tcp_v4_rcv+0x574/0xa30
[  509.102513]                                          [<c12b5c4f>] ip_local_deliver_finish+0xff/0x2c0
[  509.102513]                                          [<c12b5e40>] ip_local_deliver+0x30/0x40
[  509.102513]                                          [<c12b5f99>] ip_rcv_finish+0x149/0x440
[  509.102513]                                          [<c12b63f6>] ip_rcv+0x166/0x240
[  509.102513]                                          [<c1297b0d>] __netif_receive_skb+0x1cd/0x280
[  509.102513]                                          [<c12985e8>] process_backlog+0x88/0x160
[  509.102513]                                          [<c12989b7>] net_rx_action+0x127/0x140
[  509.102513]                                          [<c1041b30>] __do_softirq+0xd0/0x130
[  509.102513]     INITIAL USE at:
[  509.102513]                                         [<c1066e16>] __lock_acquire+0x1c6/0x8e0
[  509.102513]                                         [<c106857a>] lock_acquire+0x7a/0xa0
[  509.102513]                                         [<c1331dbe>] _raw_spin_lock_bh+0x3e/0x80
[  509.102513]                                         [<c128c4c9>] lock_sock_fast+0x29/0x90
[  509.102513]                                         [<c12dae84>] udp_destroy_sock+0x14/0x40
[  509.102513]                                         [<c128c823>] sk_common_release+0xb3/0xc0
[  509.102513]                                         [<c12db7f8>] udp_lib_close+0x8/0x10
[  509.102513]                                         [<c12e18ce>] inet_release+0xbe/0x100
[  509.102513]                                         [<c1286c36>] sock_release+0x66/0x80
[  509.102513]                                         [<c1287952>] sock_close+0x12/0x30
[  509.102513]                                         [<c10b705b>] __fput+0x1cb/0x210
[  509.102513]                                         [<c10b70b9>] fput+0x19/0x20
[  509.102513]                                         [<c10b54f3>] filp_close+0x43/0x70
[  509.102513]                                         [<c103eafb>] close_files+0xab/0x140
[  509.102513]                                         [<c103ebf9>] put_files_struct+0x29/0xf0
[  509.102513]                                         [<c103ed50>] exit_files+0x40/0x50
[  509.102513]                                         [<c103f400>] do_exit+0x100/0x2b0
[  509.102513]                                         [<c103f614>] do_group_exit+0x34/0xb0
[  509.102513]                                         [<c103f69f>] sys_exit_group+0xf/0x20
[  509.102513]                                         [<c13327e1>] syscall_call+0x7/0xb
[  509.102513]   }
[  509.102513]   ... key      at: [<c1cbfc50>] af_family_slock_keys+0x10/0x140
[  509.102513]   ... acquired at:
[  509.102513]    [<c1064a8b>] check_prevs_add+0xab/0x100
[  509.102513]    [<c1064e15>] validate_chain+0x305/0x5a0
[  509.102513]    [<c1066f03>] __lock_acquire+0x2b3/0x8e0
[  509.102513]    [<c106857a>] lock_acquire+0x7a/0xa0
[  509.102513]    [<c13323fe>] _raw_write_lock_bh+0x3e/0x80
[  509.102513]    [<c12c0356>] inet_csk_listen_stop+0x86/0x160
[  509.102513]    [<c12c2dc0>] tcp_close+0x350/0x360
[  509.102513]    [<c12e18ce>] inet_release+0xbe/0x100
[  509.102513]    [<c1286c36>] sock_release+0x66/0x80
[  509.102513]    [<c1287952>] sock_close+0x12/0x30
[  509.102513]    [<c10b705b>] __fput+0x1cb/0x210
[  509.102513]    [<c10b70b9>] fput+0x19/0x20
[  509.102513]    [<c10b54f3>] filp_close+0x43/0x70
[  509.102513]    [<c10b558d>] sys_close+0x6d/0x100
[  509.102513]    [<c13327e1>] syscall_call+0x7/0xb
[  509.102513] 
[  509.102513] -> (clock-AF_INET){++.?..} ops: 877 {
[  509.102513]    HARDIRQ-ON-W at:
[  509.102513]                                        [<c106625e>] mark_irqflags+0xfe/0x180
[  509.102513]                                        [<c1066fdd>] __lock_acquire+0x38d/0x8e0
[  509.102513]                                        [<c106857a>] lock_acquire+0x7a/0xa0
[  509.102513]                                        [<c13323fe>] _raw_write_lock_bh+0x3e/0x80
[  509.102513]                                        [<c128c79f>] sk_common_release+0x2f/0xc0
[  509.102513]                                        [<c12db7f8>] udp_lib_close+0x8/0x10
[  509.102513]                                        [<c12e18ce>] inet_release+0xbe/0x100
[  509.102513]                                        [<c1286c36>] sock_release+0x66/0x80
[  509.102513]                                        [<c1287952>] sock_close+0x12/0x30
[  509.102513]                                        [<c10b705b>] __fput+0x1cb/0x210
[  509.102513]                                        [<c10b70b9>] fput+0x19/0x20
[  509.102513]                                        [<c10b54f3>] filp_close+0x43/0x70
[  509.102513]                                        [<c103eafb>] close_files+0xab/0x140
[  509.102513]                                        [<c103ebf9>] put_files_struct+0x29/0xf0
[  509.102513]                                        [<c103ed50>] exit_files+0x40/0x50
[  509.102513]                                        [<c103f400>] do_exit+0x100/0x2b0
[  509.102513]                                        [<c103f614>] do_group_exit+0x34/0xb0
[  509.102513]                                        [<c103f69f>] sys_exit_group+0xf/0x20
[  509.102513]                                        [<c13327e1>] syscall_call+0x7/0xb
[  509.102513]    HARDIRQ-ON-R at:
[  509.102513]                                        [<c10661ce>] mark_irqflags+0x6e/0x180
[  509.102513]                                        [<c1066fdd>] __lock_acquire+0x38d/0x8e0
[  509.102513]                                        [<c106857a>] lock_acquire+0x7a/0xa0
[  509.102513]                                        [<c1331f69>] _raw_read_lock+0x39/0x70
[  509.102513]                                        [<c130a0ae>] xs_tcp_state_change+0x1e/0x1c0
[  509.102513]                                        [<c12cbea8>] tcp_rcv_synsent_state_process+0x388/0x580
[  509.102513]                                        [<c12cc547>] tcp_rcv_state_process+0x4a7/0x560
[  509.102513]                                        [<c12d2e51>] tcp_v4_do_rcv+0x71/0x280
[  509.102513]                                        [<c128b786>] __release_sock+0x66/0x150
[  509.102513]                                        [<c128c497>] release_sock+0x87/0x90
[  509.102513]                                        [<c12e1cba>] inet_stream_connect+0x5a/0x1b0
[  509.102513]                                        [<c1289448>] kernel_connect+0x18/0x30
[  509.102513]                                        [<c130acce>] xs_tcp_finish_connecting+0x4e/0x120
[  509.102513]                                        [<c130adfb>] xs_tcp_setup_socket+0x5b/0x180
[  509.102513]                                        [<c130b034>] xs_tcp_connect_worker4+0x14/0x20
[  509.102513]                                        [<c104edc0>] run_workqueue+0xe0/0x1d0
[  509.102513]                                        [<c104ef4b>] worker_thread+0x9b/0xd0
[  509.102513]                                        [<c1052a65>] kthread+0x75/0x80
[  509.102513]                                        [<c100317a>] kernel_thread_helper+0x6/0x1c
[  509.102513]    IN-SOFTIRQ-R at:
[  509.102513]                                        [<c106627e>] mark_irqflags+0x11e/0x180
[  509.102513]                                        [<c1066fdd>] __lock_acquire+0x38d/0x8e0
[  509.102513]                                        [<c106857a>] lock_acquire+0x7a/0xa0
[  509.102513]                                        [<c1331f69>] _raw_read_lock+0x39/0x70
[  509.102513]                                        [<c1309f81>] xs_tcp_data_ready+0x21/0x90
[  509.102513]                                        [<c12ca378>] tcp_data_queue+0x248/0x820
[  509.102513]                                        [<c12cb6ee>] tcp_rcv_established+0xae/0x4e0
[  509.102513]                                        [<c12d2fb1>] tcp_v4_do_rcv+0x1d1/0x280
[  509.102513]                                        [<c12d35d4>] tcp_v4_rcv+0x574/0xa30
[  509.102513]                                        [<c12b5c4f>] ip_local_deliver_finish+0xff/0x2c0
[  509.102513]                                        [<c12b5e40>] ip_local_deliver+0x30/0x40
[  509.102513]                                        [<c12b5f99>] ip_rcv_finish+0x149/0x440
[  509.102513]                                        [<c12b63f6>] ip_rcv+0x166/0x240
[  509.102513]                                        [<c1297b0d>] __netif_receive_skb+0x1cd/0x280
[  509.102513]                                        [<c12985e8>] process_backlog+0x88/0x160
[  509.102513]                                        [<c12989b7>] net_rx_action+0x127/0x140
[  509.102513]                                        [<c1041b30>] __do_softirq+0xd0/0x130
[  509.102513]    SOFTIRQ-ON-R at:
[  509.102513]                                        [<c1066242>] mark_irqflags+0xe2/0x180
[  509.102513]                                        [<c1066fdd>] __lock_acquire+0x38d/0x8e0
[  509.102513]                                        [<c106857a>] lock_acquire+0x7a/0xa0
[  509.102513]                                        [<c1331f69>] _raw_read_lock+0x39/0x70
[  509.102513]                                        [<c130a0ae>] xs_tcp_state_change+0x1e/0x1c0
[  509.102513]                                        [<c12e2397>] inet_shutdown+0x97/0x110
[  509.102513]                                        [<c1289649>] kernel_sock_shutdown+0x9/0x10
[  509.102513]                                        [<c13093a7>] xs_tcp_shutdown+0x17/0x20
[  509.102513]                                        [<c13096a7>] xs_tcp_close+0x27/0x30
[  509.102513]                                        [<c130792d>] xprt_autoclose+0x1d/0x50
[  509.102513]                                        [<c104edc0>] run_workqueue+0xe0/0x1d0
[  509.102513]                                        [<c104ef4b>] worker_thread+0x9b/0xd0
[  509.102513]                                        [<c1052a65>] kthread+0x75/0x80
[  509.102513]                                        [<c100317a>] kernel_thread_helper+0x6/0x1c
[  509.102513]    INITIAL USE at:
[  509.102513]                                       [<c1066e16>] __lock_acquire+0x1c6/0x8e0
[  509.102513]                                       [<c106857a>] lock_acquire+0x7a/0xa0
[  509.102513]                                       [<c13323fe>] _raw_write_lock_bh+0x3e/0x80
[  509.102513]                                       [<c128c79f>] sk_common_release+0x2f/0xc0
[  509.102513]                                       [<c12db7f8>] udp_lib_close+0x8/0x10
[  509.102513]                                       [<c12e18ce>] inet_release+0xbe/0x100
[  509.102513]                                       [<c1286c36>] sock_release+0x66/0x80
[  509.102513]                                       [<c1287952>] sock_close+0x12/0x30
[  509.102513]                                       [<c10b705b>] __fput+0x1cb/0x210
[  509.102513]                                       [<c10b70b9>] fput+0x19/0x20
[  509.102513]                                       [<c10b54f3>] filp_close+0x43/0x70
[  509.102513]                                       [<c103eafb>] close_files+0xab/0x140
[  509.102513]                                       [<c103ebf9>] put_files_struct+0x29/0xf0
[  509.102513]                                       [<c103ed50>] exit_files+0x40/0x50
[  509.102513]                                       [<c103f400>] do_exit+0x100/0x2b0
[  509.102513]                                       [<c103f614>] do_group_exit+0x34/0xb0
[  509.102513]                                       [<c103f69f>] sys_exit_group+0xf/0x20
[  509.102513]                                       [<c13327e1>] syscall_call+0x7/0xb
[  509.102513]  }
[  509.102513]  ... key      at: [<c1cbfd90>] af_callback_keys+0x10/0x130
[  509.102513]  ... acquired at:
[  509.102513]    [<c10656c6>] check_usage_backwards+0x76/0xd0
[  509.102513]    [<c10658d9>] mark_lock_irq+0x99/0x240
[  509.102513]    [<c106657c>] mark_lock+0x21c/0x3c0
[  509.102513]    [<c1066242>] mark_irqflags+0xe2/0x180
[  509.102513]    [<c1066fdd>] __lock_acquire+0x38d/0x8e0
[  509.102513]    [<c106857a>] lock_acquire+0x7a/0xa0
[  509.102513]    [<c1331f69>] _raw_read_lock+0x39/0x70
[  509.102513]    [<c130a0ae>] xs_tcp_state_change+0x1e/0x1c0
[  509.102513]    [<c12e2397>] inet_shutdown+0x97/0x110
[  509.102513]    [<c1289649>] kernel_sock_shutdown+0x9/0x10
[  509.102513]    [<c13093a7>] xs_tcp_shutdown+0x17/0x20
[  509.102513]    [<c13096a7>] xs_tcp_close+0x27/0x30
[  509.102513]    [<c130792d>] xprt_autoclose+0x1d/0x50
[  509.102513]    [<c104edc0>] run_workqueue+0xe0/0x1d0
[  509.102513]    [<c104ef4b>] worker_thread+0x9b/0xd0
[  509.102513]    [<c1052a65>] kthread+0x75/0x80
[  509.102513]    [<c100317a>] kernel_thread_helper+0x6/0x1c
[  509.102513] 
[  509.102513] 
[  509.102513] stack backtrace:
[  509.102513] Pid: 337, comm: rpciod/1 Not tainted 2.6.35-rc3-ccs #6
[  509.102513] Call Trace:
[  509.102513]  [<c103cbe8>] ? printk+0x18/0x20
[  509.102513]  [<c1065558>] print_irq_inversion_bug+0x108/0x120
[  509.102513]  [<c10656c6>] check_usage_backwards+0x76/0xd0
[  509.102513]  [<c10658d9>] mark_lock_irq+0x99/0x240
[  509.102513]  [<c1065650>] ? check_usage_backwards+0x0/0xd0
[  509.102513]  [<c106657c>] mark_lock+0x21c/0x3c0
[  509.102513]  [<c1066242>] mark_irqflags+0xe2/0x180
[  509.102513]  [<c1066fdd>] __lock_acquire+0x38d/0x8e0
[  509.102513]  [<c10682da>] ? __lock_is_held+0x3a/0x60
[  509.102513]  [<c106857a>] lock_acquire+0x7a/0xa0
[  509.102513]  [<c130a0ae>] ? xs_tcp_state_change+0x1e/0x1c0
[  509.102513]  [<c1331f69>] _raw_read_lock+0x39/0x70
[  509.102513]  [<c130a0ae>] ? xs_tcp_state_change+0x1e/0x1c0
[  509.102513]  [<c130a0ae>] xs_tcp_state_change+0x1e/0x1c0
[  509.102513]  [<c12cf3bf>] ? tcp_send_fin+0x4f/0xc0
[  509.102513]  [<c12e2397>] inet_shutdown+0x97/0x110
[  509.102513]  [<c104ed5e>] ? run_workqueue+0x7e/0x1d0
[  509.102513]  [<c1289649>] kernel_sock_shutdown+0x9/0x10
[  509.102513]  [<c13093a7>] xs_tcp_shutdown+0x17/0x20
[  509.102513]  [<c13096a7>] xs_tcp_close+0x27/0x30
[  509.102513]  [<c130792d>] xprt_autoclose+0x1d/0x50
[  509.102513]  [<c104edc0>] run_workqueue+0xe0/0x1d0
[  509.102513]  [<c104ed5e>] ? run_workqueue+0x7e/0x1d0
[  509.102513]  [<c1307910>] ? xprt_autoclose+0x0/0x50
[  509.102513]  [<c1052e8a>] ? prepare_to_wait+0x3a/0x60
[  509.102513]  [<c104ef4b>] worker_thread+0x9b/0xd0
[  509.102513]  [<c1053000>] ? autoremove_wake_function+0x0/0x50
[  509.102513]  [<c1053000>] ? autoremove_wake_function+0x0/0x50
[  509.102513]  [<c1035456>] ? complete+0x46/0x60
[  509.102513]  [<c1052a65>] kthread+0x75/0x80
[  509.102513]  [<c104eeb0>] ? worker_thread+0x0/0xd0
[  509.102513]  [<c10529f0>] ? kthread+0x0/0x80
[  509.102513]  [<c10529f0>] ? kthread+0x0/0x80
[  509.102513]  [<c100317a>] kernel_thread_helper+0x6/0x1c
[  518.099361] ACPI: Preparing to enter system sleep state S5
[  518.101223] Disabling non-boot CPUs ...
[  518.607480] lockdep: fixing up alternatives.
[  518.608334] SMP alternatives: switching to UP code
[  518.908243] Power down.
[  518.909864] acpi_power_off called




----- Dump 2 -----

[  974.096047] nfsd: last server has exited, flushing export cache
[  975.514620] 
[  975.514622] =========================================================
[  975.516172] [ INFO: possible irq lock inversion dependency detected ]
x34/0xb0
<4>[  975.517504]                                       [<c103f69f>] sys_exit_group+0xf/0x20
[  975.517507]                                       [<c13327e1>] syscall_call+0x7/0xb
[  975.517510]  }
[  975.517511]  ... key      at: [<c1cbfd90>] af_callback_keys+0x10/0x130
[  975.517513]  ... acquired at:
[  975.517515]    [<c10656c6>] check_usage_backwards+0x76/0xd0
[  975.517517]    [<c10658d9>] mark_lock_irq+0x99/0x240
[  975.517519]    [<c106657c>] mark_lock+0x21c/0x3c0
[  975.517522]    [<c1066242>] mark_irqflags+0xe2/0x180
[  975.517524]    [<c1066fdd>] __lock_acquire+0x38d/0x8e0
[  975.517526]    [<c106857a>] lock_acquire+0x7a/0xa0
[  975.517529]    [<c1331f69>] _raw_read_lock+0x39/0x70
[  975.517531]    [<c130a0ae>] xs_tcp_state_change+0x1e/0x1c0
[  975.517534]    [<c12e2397>] inet_shutdown+0x97/0x110
[  975.517536]    [<c1289649>] kernel_sock_shutdown+0x9/0x10
[  975.517539]    [<c13093a7>] xs_tcp_shutdown+0x17/0x20
[  975.517541]    [<c13096a7>] xs_tcp_close+0x27/0x30
[  975.517544]    [<c130792d>] xprt_autoclose+0x1d/0x50
[  975.517546]    [<c104edc0>] run_workqueue+0xe0/0x1d0
[  975.517549]    [<c104ef4b>] worker_thread+0x9b/0xd0
[  975.517551]    [<c1052a65>] kthread+0x75/0x80
[  975.517553]    [<c100317a>] kernel_thread_helper+0x6/0x1c
[  975.517556] 
[  975.517570] 
[  975.517571] stack backtrace:
[  975.517628] Pid: 337, comm: rpciod/1 Not tainted 2.6.35-rc3-ccs #6
[  975.517648] Call Trace:
[  975.517692]  [<c103cbe8>] ? printk+0x18/0x20
[  975.517704]  [<c1065558>] print_irq_inversion_bug+0x108/0x120
[  975.517708]  [<c10656c6>] check_usage_backwards+0x76/0xd0
[  975.517711]  [<c10658d9>] mark_lock_irq+0x99/0x240
[  975.517713]  [<c1065650>] ? check_usage_backwards+0x0/0xd0
[  975.517716]  [<c106657c>] mark_lock+0x21c/0x3c0
[  975.517718]  [<c1066242>] mark_irqflags+0xe2/0x180
[  975.517721]  [<c1066fdd>] __lock_acquire+0x38d/0x8e0
[  975.517723]  [<c10682da>] ? __lock_is_held+0x3a/0x60
[  975.517726]  [<c106857a>] lock_acquire+0x7a/0xa0
[  975.517729]  [<c130a0ae>] ? xs_tcp_state_change+0x1e/0x1c0
[  975.517732]  [<c1331f69>] _raw_read_lock+0x39/0x70
[  975.517735]  [<c130a0ae>] ? xs_tcp_state_change+0x1e/0x1c0
[  975.517737]  [<c130a0ae>] xs_tcp_state_change+0x1e/0x1c0
[  975.517740]  [<c12cf3bf>] ? tcp_send_fin+0x4f/0xc0
[  975.517743]  [<c12e2397>] inet_shutdown+0x97/0x110
[  975.517745]  [<c104ed5e>] ? run_workqueue+0x7e/0x1d0
[  975.517748]  [<c1289649>] kernel_sock_shutdown+0x9/0x10
[  975.517751]  [<c13093a7>] xs_tcp_shutdown+0x17/0x20
[  975.517753]  [<c13096a7>] xs_tcp_close+0x27/0x30
[  975.517756]  [<c130792d>] xprt_autoclose+0x1d/0x50
[  975.517758]  [<c104edc0>] run_workqueue+0xe0/0x1d0
[  975.517761]  [<c104ed5e>] ? run_workqueue+0x7e/0x1d0
[  975.517763]  [<c1307910>] ? xprt_autoclose+0x0/0x50
[  975.517766]  [<c1052e8a>] ? prepare_to_wait+0x3a/0x60
[  975.517769]  [<c104ef4b>] worker_thread+0x9b/0xd0
[  975.517771]  [<c1053000>] ? autoremove_wake_function+0x0/0x50
[  975.517774]  [<c1053000>] ? autoremove_wake_function+0x0/0x50
[  975.517779]  [<c1035456>] ? complete+0x46/0x60
[  975.517782]  [<c1052a65>] kthread+0x75/0x80
[  975.517784]  [<c104eeb0>] ? worker_thread+0x0/0xd0
[  975.517786]  [<c10529f0>] ? kthread+0x0/0x80
[  975.517789]  [<c10529f0>] ? kthread+0x0/0x80
[  975.517791]  [<c100317a>] kernel_thread_helper+0x6/0x1c
9>] _raw_spin_lock+0x39/0x70
[  975.517015]                                          [<c128ae51>] sk_clone+0xb1/0x2c0
[  975.517018]                                          [<c12c0046>] inet_csk_clone+0x16/0x90
[  975.517022]                                          [<c12d519c>] tcp_create_openreq_child+0x1c/0x460
[  975.517025]                                          [<c12d2a1f>] tcp_v4_syn_recv_sock+0x3f/0x1e0
[  975.517028]                                          [<c12d576c>] tcp_check_req+0x18c/0x3b0
[  975.517031]                                          [<c12d2c0d>] tcp_v4_hnd_req+0x4d/0x160
[  975.517033]                                          [<c12d2f39>] tcp_v4_do_rcv+0x159/0x280
[  975.517036]                                          [<c12d35d4>] tcp_v4_rcv+0x574/0xa30
[  975.517038]                                          [<c12b5c4f>] ip_local_deliver_finish+0xff/0x2c0
[  975.517042]                                          [<c12b5e40>] ip_local_deliver+0x30/0x40
[  975.517045]                                          [<c12b5f99>] ip_rcv_finish+0x149/0x440
[  975.517048]                                          [<c12b63f6>] ip_rcv+0x166/0x240
[  975.517050]                                          [<c1297b0d>] __netif_receive_skb+0x1cd/0x280
[  975.517054]                                          [<c12985e8>] process_backlog+0x88/0x160
[  975.517057]                                          [<c12989b7>] net_rx_action+0x127/0x140
[  975.517060]                                          [<c1041b30>] __do_softirq+0xd0/0x130
[  975.517063]     INITIAL USE at:
[  975.517065]                                         [<c1066e16>] __lock_acquire+0x1c6/0x8e0
[  975.517067]                                         [<c106857a>] lock_acquire+0x7a/0xa0
[  975.517070]                                         [<c1331dbe>] _raw_spin_lock_bh+0x3e/0x80
[  975.517073]                                         [<c128c4c9>] lock_sock_fast+0x29/0x90
[  975.517076]                                         [<c12dae84>] udp_destroy_sock+0x14/0x40
[  975.517079]                                         [<c128c823>] sk_common_release+0xb3/0xc0
[  975.517083]                                         [<c12db7f8>] udp_lib_close+0x8/0x10
[  975.517085]                                         [<c12e18ce>] inet_release+0xbe/0x100
[  975.517088]                                         [<c1286c36>] sock_release+0x66/0x80
[  975.517091]                                         [<c1287952>] sock_close+0x12/0x30
[  975.517094]                                         [<c10b705b>] __fput+0x1cb/0x210
[  975.517097]                                         [<c10b70b9>] fput+0x19/0x20
[  975.517099]                                         [<c10b54f3>] filp_close+0x43/0x70
[  975.517102]                                         [<c103eafb>] close_files+0xab/0x140
[  975.517105]                                         [<c103ebf9>] put_files_struct+0x29/0xf0
[  975.517108]                                         [<c103ed50>] exit_files+0x40/0x50
[  975.517111]                                         [<c103f400>] do_exit+0x100/0x2b0
[  975.517114]                                         [<c103f614>] do_group_exit+0x34/0xb0
[  975.517117]                                         [<c103f69f>] sys_exit_group+0xf/0x20
[  975.517120]                                         [<c13327e1>] syscall_call+0x7/0xb
[  975.517130]   }
[  975.517139]   ... key      at: [<c1cbfc50>] af_family_slock_keys+0x10/0x140
[  975.517180]   ... acquired at:
[  975.517187]    [<c1064a8b>] check_prevs_add+0xab/0x100
[  975.517190]    [<c1064e15>] validate_chain+0x305/0x5a0
[  975.517193]    [<c1066f03>] __lock_acquire+0x2b3/0x8e0
[  975.517195]    [<c106857a>] lock_acquire+0x7a/0xa0
[  975.517198]    [<c13323fe>] _raw_write_lock_bh+0x3e/0x80
[  975.517200]    [<c12c0356>] inet_csk_listen_stop+0x86/0x160
[  975.517203]    [<c12c2dc0>] tcp_close+0x350/0x360
[  975.517205]    [<c12e18ce>] inet_release+0xbe/0x100
[  975.517208]    [<c1286c36>] sock_release+0x66/0x80
[  975.517210]    [<c1287952>] sock_close+0x12/0x30
[  975.517212]    [<c10b705b>] __fput+0x1cb/0x210
[  975.517215]    [<c10b70b9>] fput+0x19/0x20
[  975.517217]    [<c10b54f3>] filp_close+0x43/0x70
[  975.517220]    [<c10b558d>] sys_close+0x6d/0x100
[  975.517222]    [<c13327e1>] syscall_call+0x7/0xb
[  975.517230] 
[  975.517240] -> (clock-AF_INET){++.?..} ops: 879 {
[  975.517244]    HARDIRQ-ON-W at:
[  975.517246]                                        [<c106625e>] mark_irqflags+0xfe/0x180
[  975.517249]                                        [<c1066fdd>] __lock_acquire+0x38d/0x8e0
[  975.517252]                                        [<c106857a>] lock_acquire+0x7a/0xa0
[  975.517254]                                        [<c13323fe>] _raw_write_lock_bh+0x3e/0x80
[  975.517257]                                        [<c128c79f>] sk_common_release+0x2f/0xc0
[  975.517260]                                        [<c12db7f8>] udp_lib_close+0x8/0x10
[  975.517263]                                        [<c12e18ce>] inet_release+0xbe/0x100
[  975.517266]                                        [<c1286c36>] sock_release+0x66/0x80
[  975.517269]                                        [<c1287952>] sock_close+0x12/0x30
[  975.517271]                                        [<c10b705b>] __fput+0x1cb/0x210
[  975.517274]                                        [<c10b70b9>] fput+0x19/0x20
[  975.517277]                                        [<c10b54f3>] filp_close+0x43/0x70
[  975.517280]                                        [<c103eafb>] close_files+0xab/0x140
[  975.517283]                                        [<c103ebf9>] put_files_struct+0x29/0xf0
[  975.517286]                                        [<c103ed50>] exit_files+0x40/0x50
[  975.517289]                                        [<c103f400>] do_exit+0x100/0x2b0
[  975.517291]                                        [<c103f614>] do_group_exit+0x34/0xb0
[  975.517294]                                        [<c103f69f>] sys_exit_group+0xf/0x20
[  975.517297]                                        [<c13327e1>] syscall_call+0x7/0xb
[  975.517300]    HARDIRQ-ON-R at:
[  975.517302]                                        [<c10661ce>] mark_irqflags+0x6e/0x180
[  975.517304]                                        [<c1066fdd>] __lock_acquire+0x38d/0x8e0
[  975.517307]                                        [<c106857a>] lock_acquire+0x7a/0xa0
[  975.517310]                                        [<c1331f69>] _raw_read_lock+0x39/0x70
[  975.517312]                                        [<c130a0ae>] xs_tcp_state_change+0x1e/0x1c0
[  975.517316]                                        [<c12cbea8>] tcp_rcv_synsent_state_process+0x388/0x580
[  975.517319]                                        [<c12cc547>] tcp_rcv_state_process+0x4a7/0x560
[  975.517322]                                        [<c12d2e51>] tcp_v4_do_rcv+0x71/0x280
[  975.517325]                                        [<c128b786>] __release_sock+0x66/0x150
[  975.517327]                                        [<c128c497>] release_sock+0x87/0x90
[  975.517330]                                        [<c12e1cba>] inet_stream_connect+0x5a/0x1b0
[  975.517333]                                        [<c1289448>] kernel_connect+0x18/0x30
[  975.517336]                                        [<c130acce>] xs_tcp_finish_connecting+0x4e/0x120
[  975.517339]                                        [<c130adfb>] xs_tcp_setup_socket+0x5b/0x180
[  975.517342]                                        [<c130b034>] xs_tcp_connect_worker4+0x14/0x20
[  975.517344]                                        [<c104edc0>] run_workqueue+0xe0/0x1d0
[  975.517347]                                        [<c104ef4b>] worker_thread+0x9b/0xd0
[  975.517350]                                        [<c1052a65>] kthread+0x75/0x80
[  975.517353]                                        [<c100317a>] kernel_thread_helper+0x6/0x1c
[  975.517358]    IN-SOFTIRQ-R at:
[  975.517359]                                        [<c106627e>] mark_irqflags+0x11e/0x180
[  975.517364]                                        [<c1066fdd>] __lock_acquire+0x38d/0x8e0
[  975.517367]                                        [<c106857a>] lock_acquire+0x7a/0xa0
[  975.517369]                                        [<c1331f69>] _raw_read_lock+0x39/0x70
[  975.517372]                                        [<c1309f81>] xs_tcp_data_ready+0x21/0x90
[  975.517375]                                        [<c12ca378>] tcp_data_queue+0x248/0x820
[  975.517378]                                        [<c12cb6ee>] tcp_rcv_established+0xae/0x4e0
[  975.517381]                                        [<c12d2fb1>] tcp_v4_do_rcv+0x1d1/0x280
[  975.517384]                                        [<c12d35d4>] tcp_v4_rcv+0x574/0xa30
[  975.517386]                                        [<c12b5c4f>] ip_local_deliver_finish+0xff/0x2c0
[  975.517389]                                        [<c12b5e40>] ip_local_deliver+0x30/0x40
[  975.517392]                                        [<c12b5f99>] ip_rcv_finish+0x149/0x440
[  975.517395]                                        [<c12b63f6>] ip_rcv+0x166/0x240
[  975.517398]                                        [<c1297b0d>] __netif_receive_skb+0x1cd/0x280
[  975.517401]                                        [<c12985e8>] process_backlog+0x88/0x160
[  975.517404]                                        [<c12989b7>] net_rx_action+0x127/0x140
[  975.517407]                                        [<c1041b30>] __do_softirq+0xd0/0x130
[  975.517411]    SOFTIRQ-ON-R at:
[  975.517412]                                        [<c1066242>] mark_irqflags+0xe2/0x180
[  975.517415]                                        [<c1066fdd>] __lock_acquire+0x38d/0x8e0
[  975.517418]                                        [<c106857a>] lock_acquire+0x7a/0xa0
[  975.517421]                                        [<c1331f69>] _raw_read_lock+0x39/0x70
[  975.517423]                                        [<c130a0ae>] xs_tcp_state_change+0x1e/0x1c0
[  975.517427]                                        [<c12e2397>] inet_shutdown+0x97/0x110
[  975.517429]                                        [<c1289649>] kernel_sock_shutdown+0x9/0x10
[  975.517432]                                        [<c13093a7>] xs_tcp_shutdown+0x17/0x20
[  975.517435]                                        [<c13096a7>] xs_tcp_close+0x27/0x30
[  975.517438]                                        [<c130792d>] xprt_autoclose+0x1d/0x50
[  975.517442]                                        [<c104edc0>] run_workqueue+0xe0/0x1d0
[  975.517445]                                        [<c104ef4b>] worker_thread+0x9b/0xd0
[  975.517448]                                        [<c1052a65>] kthread+0x75/0x80
[  975.517450]                                        [<c100317a>] kernel_thread_helper+0x6/0x1c
[  975.517453]    INITIAL USE at:
[  975.517455]                                       [<c1066e16>] __lock_acquire+0x1c6/0x8e0
[  975.517457]                                       [<c106857a>] lock_acquire+0x7a/0xa0
[  975.517460]                                       [<c13323fe>] _raw_write_lock_bh+0x3e/0x80
[  975.517463]                                       [<c128c79f>] sk_common_release+0x2f/0xc0
[  975.517466]                                       [<c12db7f8>] udp_lib_close+0x8/0x10
[  975.517469]                                       [<c12e18ce>] inet_release+0xbe/0x100
[  975.517471]                                       [<c1286c36>] sock_release+0x66/0x80
[  975.517474]                                       [<c1287952>] sock_close+0x12/0x30
[  975.517477]                                       [<c10b705b>] __fput+0x1cb/0x210
[  975.517480]                                       [<c10b70b9>] fput+0x19/0x20
[  975.517483]                                       [<c10b54f3>] filp_close+0x43/0x70
[  975.517485]                                       [<c103eafb>] close_files+0xab/0x140
[  975.517488]                                       [<c103ebf9>] put_files_struct+0x29/0xf0
[  975.517495]                                       [<c103ed50>] exit_files+0x40/0x50
[  975.517498]                                       [<c103f400>] do_exit+0x100/0x2b0
[  975.517501]                                       [<c103f614>] do_group_exit+0x34/0xb0
[  975.517504]                                       [<c103f69f>] sys_exit_group+0xf/0x20
[  975.517507]                                       [<c13327e1>] syscall_call+0x7/0xb
[  975.517510]  }
[  975.517511]  ... key      at: [<c1cbfd90>] af_callback_keys+0x10/0x130
[  975.517513]  ... acquired at:
[  975.517515]    [<c10656c6>] check_usage_backwards+0x76/0xd0
[  975.517517]    [<c10658d9>] mark_lock_irq+0x99/0x240
[  975.517519]    [<c106657c>] mark_lock+0x21c/0x3c0
[  975.517522]    [<c1066242>] mark_irqflags+0xe2/0x180
[  975.517524]    [<c1066fdd>] __lock_acquire+0x38d/0x8e0
[  975.517526]    [<c106857a>] lock_acquire+0x7a/0xa0
[  975.517529]    [<c1331f69>] _raw_read_lock+0x39/0x70
[  975.517531]    [<c130a0ae>] xs_tcp_state_change+0x1e/0x1c0
[  975.517534]    [<c12e2397>] inet_shutdown+0x97/0x110
[  975.517536]    [<c1289649>] kernel_sock_shutdown+0x9/0x10
[  975.517539]    [<c13093a7>] xs_tcp_shutdown+0x17/0x20
[  975.517541]    [<c13096a7>] xs_tcp_close+0x27/0x30
[  975.517544]    [<c130792d>] xprt_autoclose+0x1d/0x50
[  975.517546]    [<c104edc0>] run_workqueue+0xe0/0x1d0
[  975.517549]    [<c104ef4b>] worker_thread+0x9b/0xd0
[  975.517551]    [<c1052a65>] kthread+0x75/0x80
[  975.517553]    [<c100317a>] kernel_thread_helper+0x6/0x1c
[  975.517556] 
[  975.517570] 
[  975.517571] stack backtrace:
[  975.517628] Pid: 337, comm: rpciod/1 Not tainted 2.6.35-rc3-ccs #6
[  975.517648] Call Trace:
[  975.517692]  [<c103cbe8>] ? printk+0x18/0x20
[  975.517704]  [<c1065558>] print_irq_inversion_bug+0x108/0x120
[  975.517708]  [<c10656c6>] check_usage_backwards+0x76/0xd0
[  975.517711]  [<c10658d9>] mark_lock_irq+0x99/0x240
[  975.517713]  [<c1065650>] ? check_usage_backwards+0x0/0xd0
[  975.517716]  [<c106657c>] mark_lock+0x21c/0x3c0
[  975.517718]  [<c1066242>] mark_irqflags+0xe2/0x180
[  975.517721]  [<c1066fdd>] __lock_acquire+0x38d/0x8e0
[  975.517723]  [<c10682da>] ? __lock_is_held+0x3a/0x60
[  975.517726]  [<c106857a>] lock_acquire+0x7a/0xa0
[  975.517729]  [<c130a0ae>] ? xs_tcp_state_change+0x1e/0x1c0
[  975.517732]  [<c1331f69>] _raw_read_lock+0x39/0x70
[  975.517735]  [<c130a0ae>] ? xs_tcp_state_change+0x1e/0x1c0
[  975.517737]  [<c130a0ae>] xs_tcp_state_change+0x1e/0x1c0
[  975.517740]  [<c12cf3bf>] ? tcp_send_fin+0x4f/0xc0
[  975.517743]  [<c12e2397>] inet_shutdown+0x97/0x110
[  975.517745]  [<c104ed5e>] ? run_workqueue+0x7e/0x1d0
[  975.517748]  [<c1289649>] kernel_sock_shutdown+0x9/0x10
[  975.517751]  [<c13093a7>] xs_tcp_shutdown+0x17/0x20
[  975.517753]  [<c13096a7>] xs_tcp_close+0x27/0x30
[  975.517756]  [<c130792d>] xprt_autoclose+0x1d/0x50
[  975.517758]  [<c104edc0>] run_workqueue+0xe0/0x1d0
[  975.517761]  [<c104ed5e>] ? run_workqueue+0x7e/0x1d0
[  975.517763]  [<c1307910>] ? xprt_autoclose+0x0/0x50
[  975.517766]  [<c1052e8a>] ? prepare_to_wait+0x3a/0x60
[  975.517769]  [<c104ef4b>] worker_thread+0x9b/0xd0
[  975.517771]  [<c1053000>] ? autoremove_wake_function+0x0/0x50
[  975.517774]  [<c1053000>] ? autoremove_wake_function+0x0/0x50
[  975.517779]  [<c1035456>] ? complete+0x46/0x60
[  975.517782]  [<c1052a65>] kthread+0x75/0x80
[  975.517784]  [<c104eeb0>] ? worker_thread+0x0/0xd0
[  975.517786]  [<c10529f0>] ? kthread+0x0/0x80
[  975.517789]  [<c10529f0>] ? kthread+0x0/0x80
[  975.517791]  [<c100317a>] kernel_thread_helper+0x6/0x1c
[  984.626828] Restarting system.
[  984.627458] machine restart
