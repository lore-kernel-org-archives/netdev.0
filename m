From: Dave Jones <davej@codemonkey.org.uk>
Subject: BUG_ON(sg->sg_magic != SG_MAGIC) on tls socket.
Date: Fri, 11 Aug 2017 14:52:01 -0400
Message-ID: <20170811185201.7afmkfa3cuoqm4u2@codemonkey.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davejwatson@fb.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from scorn.kernelslacker.org ([45.56.101.199]:57704 "EHLO
        scorn.kernelslacker.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753712AbdHKSwC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 11 Aug 2017 14:52:02 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

kernel BUG at ./include/linux/scatterlist.h:189!
invalid opcode: 0000 [#1] SMP KASAN
CPU: 3 PID: 20890 Comm: trinity-c51 Not tainted 4.13.0-rc4-think+ #5 
task: ffff88036e3d1cc0 task.stack: ffff88033e9d8000
RIP: 0010:tls_push_record+0x675/0x680
RSP: 0018:ffff88033e9df630 EFLAGS: 00010287
RAX: 0000000000000000 RBX: ffff8802ee3b8968 RCX: ffffffff82226754
RDX: dffffc0000000000 RSI: dffffc0000000000 RDI: ffff8802ee3b8c10
RBP: ffff88033e9df6d0 R08: 0000000000000000 R09: ffffed005d107004
R10: 0000000000000004 R11: ffffed005d107003 R12: ffff880341b30668
R13: ffff8802ee3b8c10 R14: ffff8802ee3b8c38 R15: 0000000087654321
FS:  00007f465ced2700(0000) GS:ffff88046b600000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00000029cbf021f8 CR3: 000000045abd0000 CR4: 00000000001406e0
DR0: 00007f8f17bd2000 DR1: 00007f8c27d0f000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000600
Call Trace:
 ? copy_page_to_iter+0x6c0/0x6c0
 tls_sw_sendmsg+0x6d8/0x9c0
 ? alloc_sg+0x510/0x510
 ? cyc2ns_read_end+0x10/0x10
 ? import_iovec+0xa8/0x1f0
 ? do_syscall_64+0x1bc/0x3e0
 ? entry_SYSCALL64_slow_path+0x25/0x25
 inet_sendmsg+0xce/0x310
 ? inet_recvmsg+0x3a0/0x3a0
 ? inet_recvmsg+0x3a0/0x3a0
 sock_write_iter+0x1b0/0x280
 ? kernel_sendmsg+0x70/0x70
 ? __might_sleep+0x72/0xe0
 do_iter_readv_writev+0x29a/0x370
 ? vfs_dedupe_file_range+0x3f0/0x3f0
 ? rw_verify_area+0x65/0x150
 do_iter_write+0xd7/0x2a0
 ? __hrtimer_run_queues+0x980/0x980
 vfs_writev+0x142/0x220
 ? __fget_light+0x1ae/0x230
 ? vfs_iter_write+0x70/0x70
 ? syscall_exit_register+0x3f0/0x3f0
 ? rcutorture_record_progress+0x20/0x20
 ? __fdget_pos+0x88/0x120
 ? __fdget_raw+0x20/0x20
 do_writev+0xd2/0x1c0
 ? do_writev+0xd2/0x1c0
 ? vfs_writev+0x220/0x220
 ? mark_held_locks+0x23/0xb0
 ? do_syscall_64+0xc0/0x3e0
 ? SyS_readv+0x20/0x20
 SyS_writev+0x10/0x20
 do_syscall_64+0x1bc/0x3e0
 ? syscall_return_slowpath+0x240/0x240
 ? __context_tracking_exit.part.5+0x23d/0x2a0
 ? cpumask_check.part.2+0x10/0x10
 ? mark_held_locks+0x23/0xb0
 ? return_from_SYSCALL_64+0x2d/0x7a
 ? trace_hardirqs_on_caller+0x182/0x260
 ? trace_hardirqs_on_thunk+0x1a/0x1c
 entry_SYSCALL64_slow_path+0x25/0x25
RIP: 0033:0x7f465c7fd219
RSP: 002b:00007ffda332a238 EFLAGS: 00000246
 ORIG_RAX: 0000000000000014
RAX: ffffffffffffffda RBX: 0000000000000014 RCX: 00007f465c7fd219
RDX: 0000000000000047 RSI: 00000029cbef1b50 RDI: 0000000000000137
RBP: 00007ffda332a2e0 R08: 0000000000000100 R09: fffffffffffffff8
R10: 000000000000fff9 R11: 0000000000000246 R12: 0000000000000002
R13: 00007f465cd66058 R14: 00007f465ced2698 R15: 00007f465cd66000
Code: 8d bb 58 04 00 00 e8 3b d5 20 ff 48 8b 83 58 04 00 00 f0 80 48 08 04 48 83 c4 78 44 89 f0 5b 41 5c 41 5d 41 5e 41 5f 5d c3 0f 0b <0f> 0b 0f 0b 0f 0b 0f 1f 44 00 00 0f 1f 44 00 00 55 ba 17 00 00 
RIP: tls_push_record+0x675/0x680 RSP: ffff88033e9df630



186 static inline void sg_mark_end(struct scatterlist *sg)
187 {
188 #ifdef CONFIG_DEBUG_SG
189         BUG_ON(sg->sg_magic != SG_MAGIC);
190 #endif
