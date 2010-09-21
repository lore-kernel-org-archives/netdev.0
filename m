From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: Re: [2.6.36-rc5] INET?: possible irq lock inversion dependency
Date: Tue, 21 Sep 2010 18:10:49 +0900
Message-ID: <201009210910.o8L9Anaf071504@www262.sakura.ne.jp>
References: <201006242053.IAG26562.JHQFFOMSVFtOLO@I-love.SAKURA.ne.jp> <201009072132.FHA93457.MHOJFQOOFLVStF@I-love.SAKURA.ne.jp> <201009210651.o8L6pbkP038129@www262.sakura.ne.jp> <1285055760.2617.27.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Cc: linux-fsdevel@vger.kernel.org, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <1285055760.2617.27.camel@edumazet-laptop>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet wrote:
> I would say someone calls xs_tcp_state_change() while softirqs are not
> masked.
> 
> If its expected, then following patch is needed ?

After applying your patch, I got the same warning on different place.
I got this when doing "mount 127.0.0.1:/usr/src/ /mnt/".

Regards.

[  320.747630] 
[  320.747633] =========================================================
[  320.749957] [ INFO: possible irq lock inversion dependency detected ]
[  320.749957] 2.6.36-rc5-old #3
[  320.749957] ---------------------------------------------------------
[  320.749957] mount/3799 just changed the state of lock:
[  320.749957]  (clock-AF_INET){++.?..}, at: [<c135ec4c>] xs_udp_write_space+0x1c/0x50
[  320.749957] but this lock was taken by another, SOFTIRQ-safe lock in the past:
[  320.749957]  (slock-AF_INET){+.-...}
[  320.749957] 
[  320.749957] and interrupts could create inverse lock ordering between them.
[  320.749957] 
[  320.749957] 
[  320.749957] other info that might help us debug this:
[  320.749957] no locks held by mount/3799.
[  320.749957] 
[  320.749957] the shortest dependencies between 2nd lock and 1st lock:
[  320.749957]  -> (slock-AF_INET){+.-...} ops: 4340 {
[  320.749957]     HARDIRQ-ON-W at:
[  320.749957]                                          [<c106ab8e>] mark_irqflags+0xfe/0x180
[  320.749957]                                          [<c106b90d>] __lock_acquire+0x38d/0x8e0
[  320.749957]                                          [<c106ceaa>] lock_acquire+0x7a/0xa0
[  320.749957]                                          [<c138ca3e>] _raw_spin_lock_bh+0x3e/0x80
[  320.749957]                                          [<c12dba59>] lock_sock_fast+0x29/0x90
[  320.749957]                                          [<c132bdb4>] udp_destroy_sock+0x14/0x40
[  320.749957]                                          [<c12dbdb3>] sk_common_release+0xb3/0xc0
[  320.749957]                                          [<c132c728>] udp_lib_close+0x8/0x10
[  320.749957]                                          [<c133268e>] inet_release+0xbe/0x100
[  320.749957]                                          [<c12d5f66>] sock_release+0x66/0x80
[  320.749957]                                          [<c12d6ce2>] sock_close+0x12/0x30
[  320.749957]                                          [<c10c66fb>] __fput+0x1cb/0x240
[  320.749957]                                          [<c10c6789>] fput+0x19/0x20
[  320.749957]                                          [<c10c45c3>] filp_close+0x43/0x70
[  320.749957]                                          [<c103fded>] close_files+0xad/0x150
[  320.749957]                                          [<c103fef9>] put_files_struct+0x29/0xf0
[  320.749957]                                          [<c1040050>] exit_files+0x40/0x50
[  320.749957]                                          [<c1040716>] do_exit+0x116/0x2e0
[  320.749957]                                          [<c1040944>] do_group_exit+0x34/0xb0
[  320.749957]                                          [<c10409cf>] sys_exit_group+0xf/0x20
[  320.749957]                                          [<c138d4e1>] syscall_call+0x7/0xb
[  320.749957]     IN-SOFTIRQ-W at:
[  320.749957]                                          [<c106abae>] mark_irqflags+0x11e/0x180
[  320.749957]                                          [<c106b90d>] __lock_acquire+0x38d/0x8e0
[  320.749957]                                          [<c106ceaa>] lock_acquire+0x7a/0xa0
[  320.749957]                                          [<c138c8c9>] _raw_spin_lock+0x39/0x70
[  320.749957]                                          [<c12da3f1>] sk_clone+0xb1/0x2c0
[  320.749957]                                          [<c13108ea>] inet_csk_clone+0x1a/0xb0
[  320.749957]                                          [<c1325ecc>] tcp_create_openreq_child+0x1c/0x460
[  320.749957]                                          [<c132359f>] tcp_v4_syn_recv_sock+0x3f/0x1e0
[  320.749957]                                          [<c132649c>] tcp_check_req+0x18c/0x3b0
[  320.749957]                                          [<c132378d>] tcp_v4_hnd_req+0x4d/0x160
[  320.749957]                                          [<c1323ab9>] tcp_v4_do_rcv+0x159/0x280
[  320.749957]                                          [<c1324154>] tcp_v4_rcv+0x574/0xa30
[  320.749957]                                          [<c1305f63>] ip_local_deliver_finish+0x103/0x320
[  320.749957]                                          [<c13061b0>] ip_local_deliver+0x30/0x40
[  320.749957]                                          [<c1306329>] ip_rcv_finish+0x169/0x480
[  320.749957]                                          [<c13067da>] ip_rcv+0x19a/0x2b0
[  320.749957]                                          [<c12e743d>] __netif_receive_skb+0x21d/0x310
[  320.749957]                                          [<c12e7f48>] process_backlog+0x88/0x160
[  320.749957]                                          [<c12e8317>] net_rx_action+0x127/0x140
[  320.749957]                                          [<c1042e90>] __do_softirq+0xd0/0x130
[  320.749957]     INITIAL USE at:
[  320.749957]                                         [<c106b740>] __lock_acquire+0x1c0/0x8e0
[  320.749957]                                         [<c106ceaa>] lock_acquire+0x7a/0xa0
[  320.749957]                                         [<c138ca3e>] _raw_spin_lock_bh+0x3e/0x80
[  320.749957]                                         [<c12dba59>] lock_sock_fast+0x29/0x90
[  320.749957]                                         [<c132bdb4>] udp_destroy_sock+0x14/0x40
[  320.749957]                                         [<c12dbdb3>] sk_common_release+0xb3/0xc0
[  320.749957]                                         [<c132c728>] udp_lib_close+0x8/0x10
[  320.749957]                                         [<c133268e>] inet_release+0xbe/0x100
[  320.749957]                                         [<c12d5f66>] sock_release+0x66/0x80
[  320.749957]                                         [<c12d6ce2>] sock_close+0x12/0x30
[  320.749957]                                         [<c10c66fb>] __fput+0x1cb/0x240
[  320.749957]                                         [<c10c6789>] fput+0x19/0x20
[  320.749957]                                         [<c10c45c3>] filp_close+0x43/0x70
[  320.749957]                                         [<c103fded>] close_files+0xad/0x150
[  320.749957]                                         [<c103fef9>] put_files_struct+0x29/0xf0
[  320.749957]                                         [<c1040050>] exit_files+0x40/0x50
[  320.749957]                                         [<c1040716>] do_exit+0x116/0x2e0
[  320.749957]                                         [<c1040944>] do_group_exit+0x34/0xb0
[  320.749957]                                         [<c10409cf>] sys_exit_group+0xf/0x20
[  320.749957]                                         [<c138d4e1>] syscall_call+0x7/0xb
[  320.749957]   }
[  320.749957]   ... key      at: [<c1d4d9f0>] af_family_slock_keys+0x10/0x140
[  320.749957]   ... acquired at:
[  320.749957]    [<c10693bb>] check_prevs_add+0xab/0x100
[  320.749957]    [<c1069745>] validate_chain+0x305/0x5a0
[  320.749957]    [<c106b82d>] __lock_acquire+0x2ad/0x8e0
[  320.749957]    [<c106ceaa>] lock_acquire+0x7a/0xa0
[  320.749957]    [<c138d07e>] _raw_write_lock_bh+0x3e/0x80
[  320.749957]    [<c1310c16>] inet_csk_listen_stop+0x86/0x160
[  320.749957]    [<c1313772>] tcp_close+0x382/0x390
[  320.749957]    [<c133268e>] inet_release+0xbe/0x100
[  320.749957]    [<c12d5f66>] sock_release+0x66/0x80
[  320.749957]    [<c12d6ce2>] sock_close+0x12/0x30
[  320.749957]    [<c10c66fb>] __fput+0x1cb/0x240
[  320.749957]    [<c10c6789>] fput+0x19/0x20
[  320.749957]    [<c10c45c3>] filp_close+0x43/0x70
[  320.749957]    [<c10c465d>] sys_close+0x6d/0x110
[  320.749957]    [<c138d4e1>] syscall_call+0x7/0xb
[  320.749957] 
[  320.749957] -> (clock-AF_INET){++.?..} ops: 850 {
[  320.749957]    HARDIRQ-ON-W at:
[  320.749957]                                        [<c106ab8e>] mark_irqflags+0xfe/0x180
[  320.749957]                                        [<c106b90d>] __lock_acquire+0x38d/0x8e0
[  320.749957]                                        [<c106ceaa>] lock_acquire+0x7a/0xa0
[  320.749957]                                        [<c138d07e>] _raw_write_lock_bh+0x3e/0x80
[  320.749957]                                        [<c12dbd2f>] sk_common_release+0x2f/0xc0
[  320.749957]                                        [<c132c728>] udp_lib_close+0x8/0x10
[  320.749957]                                        [<c133268e>] inet_release+0xbe/0x100
[  320.749957]                                        [<c12d5f66>] sock_release+0x66/0x80
[  320.749957]                                        [<c12d6ce2>] sock_close+0x12/0x30
[  320.749957]                                        [<c10c66fb>] __fput+0x1cb/0x240
[  320.749957]                                        [<c10c6789>] fput+0x19/0x20
[  320.749957]                                        [<c10c45c3>] filp_close+0x43/0x70
[  320.749957]                                        [<c103fded>] close_files+0xad/0x150
[  320.749957]                                        [<c103fef9>] put_files_struct+0x29/0xf0
[  320.749957]                                        [<c1040050>] exit_files+0x40/0x50
[  320.749957]                                        [<c1040716>] do_exit+0x116/0x2e0
[  320.749957]                                        [<c1040944>] do_group_exit+0x34/0xb0
[  320.749957]                                        [<c10409cf>] sys_exit_group+0xf/0x20
[  320.749957]                                        [<c138d4e1>] syscall_call+0x7/0xb
[  320.749957]    HARDIRQ-ON-R at:
[  320.749957]                                        [<c106aafe>] mark_irqflags+0x6e/0x180
[  320.749957]                                        [<c106b90d>] __lock_acquire+0x38d/0x8e0
[  320.749957]                                        [<c106ceaa>] lock_acquire+0x7a/0xa0
[  320.749957]                                        [<c138cd5e>] _raw_read_lock_bh+0x3e/0x80
[  320.749957]                                        [<c135e9be>] xs_tcp_state_change+0x1e/0x1d0
[  320.749957]                                        [<c131c8a8>] tcp_rcv_synsent_state_process+0x398/0x590
[  320.749957]                                        [<c131cf47>] tcp_rcv_state_process+0x4a7/0x560
[  320.749957]                                        [<c13239d1>] tcp_v4_do_rcv+0x71/0x280
[  320.749957]                                        [<c12dad26>] __release_sock+0x66/0x150
[  320.749957]                                        [<c12dba27>] release_sock+0x87/0x90
[  320.749957]                                        [<c1332a7a>] inet_stream_connect+0x5a/0x1b0
[  320.749957]                                        [<c12d8888>] kernel_connect+0x18/0x30
[  320.749957]                                        [<c135f66e>] xs_tcp_finish_connecting+0x4e/0x120
[  320.749957]                                        [<c135f79b>] xs_tcp_setup_socket+0x5b/0x180
[  320.749957]                                        [<c135f9d4>] xs_tcp_connect_worker4+0x14/0x20
[  320.749957]                                        [<c1051767>] process_one_work+0x147/0x3a0
[  320.749957]                                        [<c1051aa6>] worker_thread+0xa6/0x200
[  320.749957]                                        [<c1056985>] kthread+0x75/0x80
[  320.749957]                                        [<c10031fa>] kernel_thread_helper+0x6/0x1c
[  320.749957]    IN-SOFTIRQ-R at:
[  320.749957]                                        [<c106abae>] mark_irqflags+0x11e/0x180
[  320.749957]                                        [<c106b90d>] __lock_acquire+0x38d/0x8e0
[  320.749957]                                        [<c106ceaa>] lock_acquire+0x7a/0xa0
[  320.749957]                                        [<c138cbe9>] _raw_read_lock+0x39/0x70
[  320.749957]                                        [<c135e891>] xs_tcp_data_ready+0x21/0x90
[  320.749957]                                        [<c131ad68>] tcp_data_queue+0x248/0x820
[  320.749957]                                        [<c131c0de>] tcp_rcv_established+0xae/0x4e0
[  320.749957]                                        [<c1323b31>] tcp_v4_do_rcv+0x1d1/0x280
[  320.749957]                                        [<c1324154>] tcp_v4_rcv+0x574/0xa30
[  320.749957]                                        [<c1305f63>] ip_local_deliver_finish+0x103/0x320
[  320.749957]                                        [<c13061b0>] ip_local_deliver+0x30/0x40
[  320.749957]                                        [<c1306329>] ip_rcv_finish+0x169/0x480
[  320.749957]                                        [<c13067da>] ip_rcv+0x19a/0x2b0
[  320.749957]                                        [<c12e743d>] __netif_receive_skb+0x21d/0x310
[  320.749957]                                        [<c12e7f48>] process_backlog+0x88/0x160
[  320.749957]                                        [<c12e8317>] net_rx_action+0x127/0x140
[  320.749957]                                        [<c1042e90>] __do_softirq+0xd0/0x130
[  320.749957]    SOFTIRQ-ON-R at:
[  320.749957]                                        [<c106ab72>] mark_irqflags+0xe2/0x180
[  320.749957]                                        [<c106b90d>] __lock_acquire+0x38d/0x8e0
[  320.749957]                                        [<c106ceaa>] lock_acquire+0x7a/0xa0
[  320.749957]                                        [<c138cbe9>] _raw_read_lock+0x39/0x70
[  320.749957]                                        [<c135ec4c>] xs_udp_write_space+0x1c/0x50
[  320.749957]                                        [<c135ed5a>] xs_udp_do_set_buffer_size+0x8a/0x90
[  320.749957]                                        [<c135ed9d>] xs_udp_set_buffer_size+0x3d/0x40
[  320.749957]                                        [<c135a0e8>] rpc_setbufsize+0x28/0x30
[  320.749957]                                        [<e09c4314>] nfs_server_set_fsinfo+0x364/0x400 [nfs]
[  320.749957]                                        [<e09c4415>] nfs_probe_fsinfo+0x65/0x100 [nfs]
[  320.749957]                                        [<e09c4717>] nfs_create_server+0x87/0x240 [nfs]
[  320.749957]                                        [<e09ceaeb>] nfs_get_sb+0x8b/0x240 [nfs]
[  320.749957]                                        [<c10c82c1>] vfs_kern_mount+0x71/0x190
[  320.749957]                                        [<c10c8607>] do_kern_mount+0x37/0x90
[  320.749957]                                        [<c10deae7>] do_new_mount+0x57/0xa0
[  320.749957]                                        [<c10df111>] do_mount+0x171/0x1b0
[  320.749957]                                        [<c10df40c>] sys_mount+0x6c/0xa0
[  320.749957]                                        [<c138d4e1>] syscall_call+0x7/0xb
[  320.749957]    INITIAL USE at:
[  320.749957]                                       [<c106b740>] __lock_acquire+0x1c0/0x8e0
[  320.749957]                                       [<c106ceaa>] lock_acquire+0x7a/0xa0
[  320.749957]                                       [<c138d07e>] _raw_write_lock_bh+0x3e/0x80
[  320.749957]                                       [<c12dbd2f>] sk_common_release+0x2f/0xc0
[  320.749957]                                       [<c132c728>] udp_lib_close+0x8/0x10
[  320.749957]                                       [<c133268e>] inet_release+0xbe/0x100
[  320.749957]                                       [<c12d5f66>] sock_release+0x66/0x80
[  320.749957]                                       [<c12d6ce2>] sock_close+0x12/0x30
[  320.749957]                                       [<c10c66fb>] __fput+0x1cb/0x240
[  320.749957]                                       [<c10c6789>] fput+0x19/0x20
[  320.749957]                                       [<c10c45c3>] filp_close+0x43/0x70
[  320.749957]                                       [<c103fded>] close_files+0xad/0x150
[  320.749957]                                       [<c103fef9>] put_files_struct+0x29/0xf0
[  320.749957]                                       [<c1040050>] exit_files+0x40/0x50
[  320.749957]                                       [<c1040716>] do_exit+0x116/0x2e0
[  320.749957]                                       [<c1040944>] do_group_exit+0x34/0xb0
[  320.749957]                                       [<c10409cf>] sys_exit_group+0xf/0x20
[  320.749957]                                       [<c138d4e1>] syscall_call+0x7/0xb
[  320.749957]  }
[  320.749957]  ... key      at: [<c1d4db30>] af_callback_keys+0x10/0x130
[  320.749957]  ... acquired at:
[  320.749957]    [<c1069ff6>] check_usage_backwards+0x76/0xd0
[  320.749957]    [<c106a209>] mark_lock_irq+0x99/0x240
[  320.749957]    [<c106aeac>] mark_lock+0x21c/0x3c0
[  320.749957]    [<c106ab72>] mark_irqflags+0xe2/0x180
[  320.749957]    [<c106b90d>] __lock_acquire+0x38d/0x8e0
[  320.749957]    [<c106ceaa>] lock_acquire+0x7a/0xa0
[  320.749957]    [<c138cbe9>] _raw_read_lock+0x39/0x70
[  320.749957]    [<c135ec4c>] xs_udp_write_space+0x1c/0x50
[  320.749957]    [<c135ed5a>] xs_udp_do_set_buffer_size+0x8a/0x90
[  320.749957]    [<c135ed9d>] xs_udp_set_buffer_size+0x3d/0x40
[  320.749957]    [<c135a0e8>] rpc_setbufsize+0x28/0x30
[  320.749957]    [<e09c4314>] nfs_server_set_fsinfo+0x364/0x400 [nfs]
[  320.749957]    [<e09c4415>] nfs_probe_fsinfo+0x65/0x100 [nfs]
[  320.749957]    [<e09c4717>] nfs_create_server+0x87/0x240 [nfs]
[  320.749957]    [<e09ceaeb>] nfs_get_sb+0x8b/0x240 [nfs]
[  320.749957]    [<c10c82c1>] vfs_kern_mount+0x71/0x190
[  320.749957]    [<c10c8607>] do_kern_mount+0x37/0x90
[  320.749957]    [<c10deae7>] do_new_mount+0x57/0xa0
[  320.749957]    [<c10df111>] do_mount+0x171/0x1b0
[  320.749957]    [<c10df40c>] sys_mount+0x6c/0xa0
[  320.749957]    [<c138d4e1>] syscall_call+0x7/0xb
[  320.749957] 
[  320.749957] 
[  320.749957] stack backtrace:
[  320.749957] Pid: 3799, comm: mount Not tainted 2.6.36-rc5-old #3
[  320.749957] Call Trace:
[  320.749957]  [<c103ded8>] ? printk+0x18/0x20
[  320.749957]  [<c1069e88>] print_irq_inversion_bug+0x108/0x120
[  320.749957]  [<c1069ff6>] check_usage_backwards+0x76/0xd0
[  320.749957]  [<c106a209>] mark_lock_irq+0x99/0x240
[  320.749957]  [<c1069f80>] ? check_usage_backwards+0x0/0xd0
[  320.749957]  [<c106aeac>] mark_lock+0x21c/0x3c0
[  320.749957]  [<c106ab72>] mark_irqflags+0xe2/0x180
[  320.749957]  [<c106b90d>] __lock_acquire+0x38d/0x8e0
[  320.749957]  [<c109a95e>] ? mempool_free_slab+0xe/0x10
[  320.749957]  [<c109a938>] ? mempool_free+0x98/0xa0
[  320.749957]  [<c106ceaa>] lock_acquire+0x7a/0xa0
[  320.749957]  [<c135ec4c>] ? xs_udp_write_space+0x1c/0x50
[  320.749957]  [<c138cbe9>] _raw_read_lock+0x39/0x70
[  320.749957]  [<c135ec4c>] ? xs_udp_write_space+0x1c/0x50
[  320.749957]  [<c135ec4c>] xs_udp_write_space+0x1c/0x50
[  320.749957]  [<c135ed5a>] xs_udp_do_set_buffer_size+0x8a/0x90
[  320.749957]  [<c135ed9d>] xs_udp_set_buffer_size+0x3d/0x40
[  320.749957]  [<c135ed60>] ? xs_udp_set_buffer_size+0x0/0x40
[  320.749957]  [<c135a0e8>] rpc_setbufsize+0x28/0x30
[  320.749957]  [<e09c4314>] nfs_server_set_fsinfo+0x364/0x400 [nfs]
[  320.749957]  [<e09c4415>] nfs_probe_fsinfo+0x65/0x100 [nfs]
[  320.749957]  [<c10bf8b8>] ? cache_alloc_debugcheck_after+0x98/0x1d0
[  320.749957]  [<e09cb1d3>] ? nfs_alloc_fattr+0x23/0x30 [nfs]
[  320.749957]  [<e09c4717>] nfs_create_server+0x87/0x240 [nfs]
[  320.749957]  [<e09cb1f5>] ? nfs_alloc_fhandle+0x15/0x30 [nfs]
[  320.749957]  [<e09ceaeb>] nfs_get_sb+0x8b/0x240 [nfs]
[  320.749957]  [<e09ce9b0>] ? nfs_compare_super+0x0/0x90 [nfs]
[  320.749957]  [<c10c82c1>] vfs_kern_mount+0x71/0x190
[  320.749957]  [<c10dc4fc>] ? get_fs_type+0x8c/0xa0
[  320.749957]  [<c10c8607>] do_kern_mount+0x37/0x90
[  320.749957]  [<c10deae7>] do_new_mount+0x57/0xa0
[  320.749957]  [<c10df111>] do_mount+0x171/0x1b0
[  320.749957]  [<c10df40c>] sys_mount+0x6c/0xa0
[  320.749957]  [<c138d4e1>] syscall_call+0x7/0xb
