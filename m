From: Dave Jones <davej@codemonkey.org.uk>
Subject: KASAN: slab-out-of-bounds from net_namespace.c:ops_init
Date: Fri, 11 Aug 2017 12:10:42 -0400
Message-ID: <20170811161042.nw6jzecaqgkua46s@codemonkey.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from scorn.kernelslacker.org ([45.56.101.199]:57170 "EHLO
        scorn.kernelslacker.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753025AbdHKQKn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 11 Aug 2017 12:10:43 -0400
Received: from [2601:196:4600:5b90:ae9e:17ff:feb7:72ca] (helo=wopr.kernelslacker.org)
        by scorn.kernelslacker.org with esmtp (Exim 4.89)
        (envelope-from <davej@codemonkey.org.uk>)
        id 1dgCWI-0001WW-FB
        for netdev@vger.kernel.org; Fri, 11 Aug 2017 12:10:42 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

==================================================================
BUG: KASAN: slab-out-of-bounds in ops_init+0x201/0x330
Write of size 8 at addr ffff88045744c448 by task trinity-c4/1499

CPU: 2 PID: 1499 Comm: trinity-c4 Not tainted 4.13.0-rc4-think+ #5 
Call Trace:
 dump_stack+0xc5/0x151
 ? dma_virt_map_sg+0xff/0xff
 ? show_regs_print_info+0x41/0x41
 print_address_description+0xd9/0x260
 kasan_report+0x27a/0x370
 ? ops_init+0x201/0x330
 __asan_store8+0x57/0x90
 ops_init+0x201/0x330
 ? net_alloc_generic+0x50/0x50
 ? __raw_spin_lock_init+0x21/0x80
 ? trace_hardirqs_on_caller+0x182/0x260
 ? lockdep_init_map+0xb2/0x2b0
 setup_net+0x208/0x400
 ? ops_init+0x330/0x330
 ? copy_net_ns+0x151/0x390
 ? can_nice.part.81+0x20/0x20
 ? rcu_is_watching+0x8d/0xd0
 ? __lock_is_held+0x30/0xd0
 ? rcutorture_record_progress+0x20/0x20
 ? copy_net_ns+0x151/0x390
 copy_net_ns+0x200/0x390
 ? net_drop_ns+0x20/0x20
 ? do_mount+0x19d0/0x19d0
 ? create_new_namespaces+0x97/0x450
 ? rcu_read_lock_sched_held+0x96/0xa0
 ? kmem_cache_alloc+0x28a/0x2f0
 create_new_namespaces+0x317/0x450
 ? sys_ni_syscall+0x20/0x20
 ? cap_capable+0x7f/0xf0
 unshare_nsproxy_namespaces+0x77/0xf0
 SyS_unshare+0x573/0xbb0
 ? walk_process_tree+0x2a0/0x2a0
 ? lock_release+0x920/0x920
 ? lock_release+0x920/0x920
 ? mntput_no_expire+0x117/0x620
 ? rcu_is_watching+0x8d/0xd0
 ? exit_to_usermode_loop+0x1b0/0x1b0
 ? rcu_read_lock_sched_held+0x96/0xa0
 ? __context_tracking_exit.part.5+0x23d/0x2a0
 ? cpumask_check.part.2+0x10/0x10
 ? context_tracking_user_exit+0x30/0x30
 ? __f_unlock_pos+0x15/0x20
 ? SyS_read+0x146/0x160
 ? do_syscall_64+0xc0/0x3e0
 ? walk_process_tree+0x2a0/0x2a0
 do_syscall_64+0x1bc/0x3e0
 ? syscall_return_slowpath+0x240/0x240
 ? mark_held_locks+0x23/0xb0
 ? return_from_SYSCALL_64+0x2d/0x7a
 ? trace_hardirqs_on_caller+0x182/0x260
 ? trace_hardirqs_on_thunk+0x1a/0x1c
 entry_SYSCALL64_slow_path+0x25/0x25
RIP: 0033:0x7f9e1c454219
RSP: 002b:00007fff180f9c88 EFLAGS: 00000246
 ORIG_RAX: 0000000000000110
RAX: ffffffffffffffda RBX: 0000000000000110 RCX: 00007f9e1c454219
RDX: 00000000000000c4 RSI: ffff8000000ff000 RDI: 0000000074060700
RBP: 00007fff180f9d30 R08: 0000000000000002 R09: 2fa420810090095e
R10: ffff880ffffffb40 R11: 0000000000000246 R12: 0000000000000002
R13: 00007f9e1cb06058 R14: 00007f9e1cb29698 R15: 00007f9e1cb06000

Allocated by task 1499:
 save_stack_trace+0x1b/0x20
 save_stack+0x43/0xd0
 kasan_kmalloc+0xad/0xe0
 __kmalloc+0x14b/0x370
 net_alloc_generic+0x25/0x50
 copy_net_ns+0x130/0x390
 create_new_namespaces+0x317/0x450
 unshare_nsproxy_namespaces+0x77/0xf0
 SyS_unshare+0x573/0xbb0
 do_syscall_64+0x1bc/0x3e0
 return_from_SYSCALL_64+0x0/0x7a

Freed by task 504:
 save_stack_trace+0x1b/0x20
 save_stack+0x43/0xd0
 kasan_slab_free+0x72/0xc0
 kfree+0xe1/0x2f0
 rcu_process_callbacks+0x5a6/0x1dc0
 __do_softirq+0x1e7/0x817

The buggy address belongs to the object at ffff88045744c3c8
 which belongs to the cache kmalloc-128 of size 128
The buggy address is located 0 bytes to the right of
 128-byte region [ffff88045744c3c8, ffff88045744c448)
The buggy address belongs to the page:
page:ffffea00115d1300 count:1 mapcount:0 mapping:          (null) index:0x0
 compound_mapcount: 0
flags: 0x8000000000008100(slab|head)
raw: 8000000000008100 0000000000000000 0000000000000000 0000000100110011
raw: ffffea00113f2b20 ffffea0011328a20 ffff880467c0f140 0000000000000000
page dumped because: kasan: bad access detected

Memory state around the buggy address:
 ffff88045744c300: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
 ffff88045744c380: fc fc fc fc fc fc fc fc fc 00 00 00 00 00 00 00
>ffff88045744c400: 00 00 00 00 00 00 00 00 00 fc fc fc fc fc fc fc
                                              ^
 ffff88045744c480: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
 ffff88045744c500: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
==================================================================
