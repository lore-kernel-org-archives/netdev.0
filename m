From: Dave Jones <davej@codemonkey.org.uk>
Subject: [4.14rc6] __tcp_select_window divide by zero.
Date: Tue, 24 Oct 2017 09:00:30 -0400
Message-ID: <20171024130030.7t7j7tmfiyrlepmm@codemonkey.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from scorn.kernelslacker.org ([45.56.101.199]:60060 "EHLO
        scorn.kernelslacker.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932991AbdJXNAc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Oct 2017 09:00:32 -0400
Received: from [2601:196:4600:5b90:ae9e:17ff:feb7:72ca] (helo=wopr.kernelslacker.org)
        by scorn.kernelslacker.org with esmtp (Exim 4.89)
        (envelope-from <davej@codemonkey.org.uk>)
        id 1e6yop-0008E9-7c
        for netdev@vger.kernel.org; Tue, 24 Oct 2017 09:00:31 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

divide error: 0000 [#1] SMP KASAN
CPU: 0 PID: 31140 Comm: trinity-c12 Not tainted 4.14.0-rc6-think+ #1 
task: ffff8803c0d08040 task.stack: ffff8803df548000
RIP: 0010:__tcp_select_window+0x21f/0x400
RSP: 0018:ffff8803df54f418 EFLAGS: 00010246
RAX: 0000000000000000 RBX: ffff880458fd3140 RCX: ffffffff82120ea5
RDX: 0000000000000000 RSI: dffffc0000000000 RDI: ffff880458fd3a88
RBP: 0000000000000000 R08: 0000000000000001 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000000 R12: 0000000000098968
R13: 1ffff1007bea9e87 R14: 0000000000000000 R15: 0000000000000000
FS:  00007f76da1db700(0000) GS:ffff88046ae00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 0000000000000000 CR3: 00000003f67cd002 CR4: 00000000001606f0
DR0: 00007f76d819f000 DR1: 00007f75a29f5000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000600
Call Trace:
 ? tcp_schedule_loss_probe+0x270/0x270
 ? lock_acquire+0x12e/0x350
 ? tcp_recvmsg+0x124/0x1430
 ? lock_release+0x890/0x890
 ? do_raw_spin_trylock+0x100/0x100
 ? do_raw_spin_trylock+0x40/0x100
 tcp_cleanup_rbuf+0x27d/0x2a0
 ? tcp_recv_skb+0x180/0x180
 ? mark_held_locks+0x70/0xa0
 ? __local_bh_enable_ip+0x60/0x90
 tcp_recvmsg+0x7a9/0x1430
 ? tcp_recv_timestamp+0x250/0x250
 ? __free_insn_slot+0x390/0x390
 ? rcu_is_watching+0x88/0xd0
 ? entry_SYSCALL64_slow_path+0x25/0x25
 ? is_bpf_text_address+0x86/0xf0
 ? kernel_text_address+0xec/0x100
 ? __kernel_text_address+0xe/0x30
 ? unwind_get_return_address+0x2f/0x50
 ? __save_stack_trace+0x92/0x100
 ? memcmp+0x45/0x70
 ? match_held_lock+0x93/0x410
 ? save_trace+0x1c0/0x1c0
 ? save_stack+0x89/0xb0
 ? save_stack+0x32/0xb0
 ? kasan_kmalloc+0xa0/0xd0
 ? native_sched_clock+0xf9/0x1a0
 ? rw_copy_check_uvector+0x15e/0x180
 inet_recvmsg+0x10b/0x360
 ? inet_create+0x770/0x770
 ? sched_clock_cpu+0x14/0xf0
 ? sched_clock_cpu+0x14/0xf0
 sock_read_iter+0x19d/0x240
 ? sock_recvmsg+0x60/0x60
 do_iter_readv_writev+0x2e4/0x320
 ? vfs_dedupe_file_range+0x3e0/0x3e0
 do_iter_read+0x149/0x280
 vfs_readv+0x107/0x180
 ? compat_rw_copy_check_uvector+0x1d0/0x1d0
 ? fget_raw+0x10/0x10
 ? __lock_is_held+0x2e/0xd0
 ? do_preadv+0xf0/0xf0
 ? __fdget_pos+0x82/0x110
 ? __fdget_raw+0x10/0x10
 ? do_readv+0xc0/0x1b0
 do_readv+0xc0/0x1b0
 ? vfs_readv+0x180/0x180
 ? mark_held_locks+0x1b/0xa0
 ? do_syscall_64+0xae/0x400
 ? do_preadv+0xf0/0xf0
 do_syscall_64+0x182/0x400
 ? syscall_return_slowpath+0x270/0x270
 ? rcu_read_lock_sched_held+0x90/0xa0
 ? __context_tracking_exit.part.4+0x223/0x290
 ? mark_held_locks+0x1b/0xa0
 ? return_from_SYSCALL_64+0x2d/0x7a
 ? trace_hardirqs_on_caller+0x17a/0x250
 ? trace_hardirqs_on_thunk+0x1a/0x1c
 entry_SYSCALL64_slow_path+0x25/0x25
RIP: 0033:0x7f76d9b05219
RSP: 002b:00007ffd41fd30d8 EFLAGS: 00000246  ORIG_RAX: 0000000000000013
RAX: ffffffffffffffda RBX: 0000000000000013 RCX: 00007f76d9b05219
RDX: 0000000000000016 RSI: 00005611ca731c70 RDI: 0000000000000179
RBP: 00007ffd41fd3180 R08: 0000000000a07395 R09: 0000000a10d65a68
R10: 0000000000000001 R11: 0000000000000246 R12: 0000000000000002
R13: 00007f76da180058 R14: 00007f76da1db698 R15: 00007f76da180000
Code: 41 5e 41 5f c3 48 8d bb 48 09 00 00 e8 4b 2b 30 ff 8b 83 48 09 00 00 89 ea 44 29 f2 39 c2 7d 08 39 c5 0f 8d 86 01 00 00 89 e8 99 <41> f7 fe 89 e8 29 d0 eb 8c 41 f7 df 48 89 c7 44 89 f9 d3 fd e8 
RIP: __tcp_select_window+0x21f/0x400 RSP: ffff8803df54f418



                        window = rounddown(free_space, mss);
    45ec:       89 e8                   mov    %ebp,%eax
    45ee:       99                      cltd   
    45ef:       41 f7 fe                idiv   %r14d
    45f2:       89 e8                   mov    %ebp,%eax
    45f4:       29 d0                   sub    %edx,%eax
    45f6:       eb 8c                   jmp    4584 <__tcp_select_window+0x1b4>
    45f8:       41 f7 df                neg    %r15d
