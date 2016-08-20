From: Baozeng Ding <sploving1@gmail.com>
Subject: net/sctp: BUG: KASAN: stack-out-of-bounds in memcmp
Date: Sat, 20 Aug 2016 15:51:10 +0800
Message-ID: <6843fbba-a11c-8bc4-495a-294dc7fdcc35@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-sctp@vger.kernel.org, netdev@vger.kernel.org
To: Vladislav Yasevich <vyasevich@gmail.com>, nhorman@tuxdriver.com,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f67.google.com ([209.85.218.67]:35055 "EHLO
        mail-oi0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751350AbcHTHvy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 20 Aug 2016 03:51:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello all,
The following program triggers  stack-out-of-bounds in memcmp. The kernel version is 4.8.0-rc1+ (on Aug 13 commit 118253a593bd1c57de2d1193df1ccffe1abe745b). Thanks.

==================================================================
BUG: KASAN: stack-out-of-bounds in memcmp+0xf8/0x120 at addr ffff8803f7247170
Read of size 1 by task 0/10880
page:ffffea000fdc91c0 count:0 mapcount:0 mapping:          (null) index:0x0
flags: 0x2fffc0000000000()
page dumped because: kasan: bad access detected
CPU: 0 PID: 10880 Comm: 0 Tainted: G    B   W       4.8.0-rc1+ #30
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS rel-1.8.2-0-g33fbe13 by qemu-project.org 04/01/2014
 ffffffff87cb8ee0 ffff8803f7246fb0 ffffffff82cdc0a9 fffffffff7247040
 fffffbfff0f971dc ffff8803f7247040 ffff8803f7247170 ffff8803f72471f0
 ffff8804841fee98 00000000000000ff ffff8803f7247030 ffffffff817c0ba8
Call Trace:
 [<     inline     >] __dump_stack /lib/dump_stack.c:15
 [<ffffffff82cdc0a9>] dump_stack+0x12e/0x185 /lib/dump_stack.c:51
 [<     inline     >] print_address_description /mm/kasan/report.c:204
 [<ffffffff817c0ba8>] kasan_report_error+0x498/0x4c0 /mm/kasan/report.c:283
 [<ffffffff81536180>] ? is_module_text_address+0x10/0x20 /kernel/module.c:4224
 [<     inline     >] kasan_report /mm/kasan/report.c:303
 [<ffffffff817c0c0e>] __asan_report_load1_noabort+0x3e/0x40 /mm/kasan/report.c:321
 [<ffffffff82cfb2e8>] ? memcmp+0xf8/0x120 /lib/string.c:768
 [<ffffffff82cfb2e8>] memcmp+0xf8/0x120 /lib/string.c:768
 [<     inline     >] find_stack /lib/stackdepot.c:176
 [<ffffffff82daabed>] depot_save_stack+0x16d/0x5b0 /lib/stackdepot.c:224
 [<ffffffff817bfac8>] save_stack+0xb8/0xd0 /mm/kasan/kasan.c:485
 [<ffffffff8122b576>] ? save_stack_trace+0x26/0x50 /arch/x86/kernel/stacktrace.c:67
 [<ffffffff817bfa56>] ? save_stack+0x46/0xd0 /mm/kasan/kasan.c:479
 [<     inline     >] ? set_track /mm/kasan/kasan.c:491
 [<ffffffff817c0281>] ? kasan_slab_free+0x71/0xb0 /mm/kasan/kasan.c:555
 [<     inline     >] ? slab_free_hook /mm/slub.c:1356
 [<     inline     >] ? slab_free_freelist_hook /mm/slub.c:1378
 [<     inline     >] ? slab_free /mm/slub.c:2936
 [<ffffffff817bc974>] ? kfree+0x114/0x370 /mm/slub.c:3856
 [<ffffffff8556d194>] ? skb_free_head+0x74/0xb0 /net/core/skbuff.c:580
 [<ffffffff8556f37f>] ? skb_release_data+0x33f/0x3e0 /net/core/skbuff.c:611
 [<ffffffff8556f46a>] ? skb_release_all+0x4a/0x60 /net/core/skbuff.c:670
 [<     inline     >] ? __kfree_skb /net/core/skbuff.c:684
 [<ffffffff8557a313>] ? consume_skb+0x133/0x360 /net/core/skbuff.c:757
 [<     inline     >] ? sctp_chunk_destroy /net/sctp/sm_make_chunk.c:1447
 [<ffffffff86173826>] ? sctp_chunk_put+0xc6/0x180 /net/sctp/sm_make_chunk.c:1474
 [<ffffffff86173933>] ? sctp_chunk_free+0x53/0x60 /net/sctp/sm_make_chunk.c:1461
 [<ffffffff86189420>] ? sctp_inq_pop+0x6c0/0x1150 /net/sctp/inqueue.c:150
 [<ffffffff86167c11>] ? sctp_assoc_bh_rcv+0xd1/0x490 /net/sctp/associola.c:1018
 [<ffffffff86188c4c>] ? sctp_inq_push+0x12c/0x190 /net/sctp/inqueue.c:95
 [<ffffffff861c4b24>] ? sctp_backlog_rcv+0xe4/0xa60 /net/sctp/input.c:342
 [<     inline     >] ? sk_backlog_rcv /./include/net/sock.h:872
 [<ffffffff855604c7>] ? __release_sock+0x127/0x3a0 /net/core/sock.c:2063
 [<ffffffff85560799>] ? release_sock+0x59/0x1c0 /net/core/sock.c:2521
 [<ffffffff861a1ad5>] ? sctp_wait_for_connect+0x2f5/0x510 /net/sctp/socket.c:7525
 [<ffffffff861aa9b1>] ? sctp_sendmsg+0x2041/0x30b0 /net/sctp/socket.c:1984
 [<ffffffff859c6395>] ? inet_sendmsg+0x2f5/0x4c0 /net/ipv4/af_inet.c:740
 [<     inline     >] ? sock_sendmsg_nosec /net/socket.c:609
 [<ffffffff855516ea>] ? sock_sendmsg+0xca/0x110 /net/socket.c:619
 [<ffffffff85554e7f>] ? ___sys_sendmsg+0x2bf/0x880 /net/socket.c:1942
 [<ffffffff85558119>] ? __sys_sendmmsg+0x159/0x380 /net/socket.c:2032
 [<     inline     >] ? SYSC_sendmmsg /net/socket.c:2061
 [<ffffffff85558375>] ? SyS_sendmmsg+0x35/0x60 /net/socket.c:2056
 [<ffffffff8675b680>] ? entry_SYSCALL_64_fastpath+0x23/0xc1 /arch/x86/entry/entry_64.S:207
 [<ffffffff8619174a>] ? sctp_outq_uncork+0x5a/0x70 /net/sctp/outqueue.c:786
 [<ffffffff818050e0>] ? hugetlb_cgroup_migrate+0x420/0x420 ??:?
 [<ffffffff814804ad>] ? trace_hardirqs_on+0xd/0x10 /kernel/locking/lockdep.c:2740
 [<     inline     >] ? spin_unlock_irqrestore /./include/linux/spinlock.h:362
 [<ffffffff818059ed>] ? __delete_object+0x9d/0x100 /mm/kmemleak.c:638
 [<ffffffff8556d194>] ? skb_free_head+0x74/0xb0 /net/core/skbuff.c:580
 [<ffffffff814cba22>] ? call_rcu_sched+0x12/0x20 /kernel/rcu/tree.c:3191
 [<ffffffff81805932>] ? put_object+0x42/0x60 /mm/kmemleak.c:474
 [<ffffffff818059f5>] ? __delete_object+0xa5/0x100 /mm/kmemleak.c:639
 [<     inline     >] set_track /mm/kasan/kasan.c:491
 [<ffffffff817c0281>] kasan_slab_free+0x71/0xb0 /mm/kasan/kasan.c:555
 [<ffffffff8556d194>] ? skb_free_head+0x74/0xb0 /net/core/skbuff.c:580
 [<     inline     >] slab_free_hook /mm/slub.c:1356
 [<     inline     >] slab_free_freelist_hook /mm/slub.c:1378
 [<     inline     >] slab_free /mm/slub.c:2936
 [<ffffffff817bc974>] kfree+0x114/0x370 /mm/slub.c:3856
 [<ffffffff8556d194>] skb_free_head+0x74/0xb0 /net/core/skbuff.c:580
 [<ffffffff8556f37f>] skb_release_data+0x33f/0x3e0 /net/core/skbuff.c:611
 [<ffffffff8556f46a>] skb_release_all+0x4a/0x60 /net/core/skbuff.c:670
 [<     inline     >] __kfree_skb /net/core/skbuff.c:684
 [<ffffffff8557a313>] consume_skb+0x133/0x360 /net/core/skbuff.c:757
 [<     inline     >] sctp_chunk_destroy /net/sctp/sm_make_chunk.c:1447
 [<ffffffff86173826>] sctp_chunk_put+0xc6/0x180 /net/sctp/sm_make_chunk.c:1474
 [<ffffffff86173933>] sctp_chunk_free+0x53/0x60 /net/sctp/sm_make_chunk.c:1461
 [<ffffffff86189420>] sctp_inq_pop+0x6c0/0x1150 /net/sctp/inqueue.c:150
 [<ffffffff86167c11>] sctp_assoc_bh_rcv+0xd1/0x490 /net/sctp/associola.c:1018
 [<ffffffff86188c4c>] sctp_inq_push+0x12c/0x190 /net/sctp/inqueue.c:95
 [<ffffffff861c4b24>] sctp_backlog_rcv+0xe4/0xa60 /net/sctp/input.c:342
 [<ffffffff814804ad>] ? trace_hardirqs_on+0xd/0x10 /kernel/locking/lockdep.c:2740
 [<ffffffff813856b8>] ? __local_bh_enable_ip+0xa8/0x190 /kernel/softirq.c:175
 [<     inline     >] sk_backlog_rcv /./include/net/sock.h:872
 [<ffffffff855604c7>] __release_sock+0x127/0x3a0 /net/core/sock.c:2063
 [<ffffffff85560799>] release_sock+0x59/0x1c0 /net/core/sock.c:2521
 [<ffffffff861a1ad5>] sctp_wait_for_connect+0x2f5/0x510 /net/sctp/socket.c:7525
 [<ffffffff861a17e0>] ? sctp_shutdown+0x190/0x190 /./include/net/net_namespace.h:259
 [<ffffffff81462ce0>] ? prepare_to_wait_event+0x410/0x410 /./include/linux/sched.h:3153
 [<ffffffff861710c5>] ? sctp_datamsg_put+0x25/0x350 /net/sctp/chunk.c:135
 [<ffffffff861bafa9>] ? sctp_primitive_SEND+0xa9/0xd0 /net/sctp/primitive.c:178
 [<ffffffff861aa9b1>] sctp_sendmsg+0x2041/0x30b0 /net/sctp/socket.c:1984
 [<ffffffff81529063>] ? __module_text_address+0x13/0x150 /kernel/module.c:4239
 [<ffffffff81536180>] ? is_module_text_address+0x10/0x20 /kernel/module.c:4224
 [<ffffffff861a8970>] ? sctp_id2assoc+0x330/0x330 /net/sctp/socket.c:209
 [<ffffffff81480d10>] ? debug_check_no_locks_freed+0x3c0/0x3c0 /./include/linux/sched.h:2056
 [<ffffffff8173773e>] ? __might_fault+0x18e/0x1d0 /mm/memory.c:4000
 [<ffffffff817bf9c4>] ? kasan_check_write+0x14/0x20 /mm/kasan/kasan.c:310
 [<     inline     >] ? sock_rps_record_flow /./include/net/sock.h:895
 [<ffffffff859c6113>] ? inet_sendmsg+0x73/0x4c0 /net/ipv4/af_inet.c:733
 [<     inline     >] ? rcu_read_unlock /./include/linux/rcupdate.h:922
 [<     inline     >] ? sock_rps_record_flow_hash /./include/net/sock.h:888
 [<     inline     >] ? sock_rps_record_flow /./include/net/sock.h:895
 [<ffffffff859c629a>] ? inet_sendmsg+0x1fa/0x4c0 /net/ipv4/af_inet.c:733
 [<ffffffff859c6395>] inet_sendmsg+0x2f5/0x4c0 /net/ipv4/af_inet.c:740
 [<     inline     >] ? sock_rps_record_flow /./include/net/sock.h:895
 [<ffffffff859c6113>] ? inet_sendmsg+0x73/0x4c0 /net/ipv4/af_inet.c:733
 [<ffffffff859c60a0>] ? inet_recvmsg+0x4a0/0x4a0 /./include/linux/compiler.h:220
 [<     inline     >] sock_sendmsg_nosec /net/socket.c:609
 [<ffffffff855516ea>] sock_sendmsg+0xca/0x110 /net/socket.c:619
 [<ffffffff85554e7f>] ___sys_sendmsg+0x2bf/0x880 /net/socket.c:1942
 [<ffffffff85554bc0>] ? sock_create_kern+0x50/0x50 /net/socket.c:1203
 [<ffffffff81480d10>] ? debug_check_no_locks_freed+0x3c0/0x3c0 /./include/linux/sched.h:2056
 [<ffffffff816b4fa0>] ? gfp_pfmemalloc_allowed+0x120/0x120 /./arch/x86/include/asm/bitops.h:311
 [<ffffffff81480d10>] ? debug_check_no_locks_freed+0x3c0/0x3c0 /./include/linux/sched.h:2056
 [<ffffffff817f2120>] ? mem_cgroup_css_offline+0x210/0x210 /mm/memcontrol.c:4310
 [<ffffffff817ef780>] ? mem_cgroup_count_precharge_pte_range+0x4e0/0x4e0 /./include/linux/huge_mm.h:128
 [<     inline     >] ? rcu_read_unlock /./include/linux/rcupdate.h:922
 [<ffffffff817efb1f>] ? get_mem_cgroup_from_mm+0x39f/0x4a0 /mm/memcontrol.c:743
 [<ffffffff8187aa28>] ? __fdget+0x18/0x20 /fs/file.c:764
 [<ffffffff85550208>] ? sockfd_lookup_light+0xf8/0x1f0 /net/socket.c:463
 [<ffffffff85558119>] __sys_sendmmsg+0x159/0x380 /net/socket.c:2032
 [<ffffffff85557fc0>] ? SyS_sendmsg+0x50/0x50 /net/socket.c:1986
 [<ffffffff817458a0>] ? __pmd_alloc+0x3f0/0x3f0 /./include/linux/mm.h:1759
 [<ffffffff8173773e>] ? __might_fault+0x18e/0x1d0 /mm/memory.c:4000
 [<ffffffff85552207>] ? SYSC_bind+0x147/0x250 /net/socket.c:1376
 [<ffffffff81298109>] ? __do_page_fault+0x479/0xbb0 /arch/x86/mm/fault.c:1382
 [<ffffffff81474caa>] ? up_read+0x1a/0x40 /kernel/locking/rwsem.c:101
 [<ffffffff81297e28>] ? __do_page_fault+0x198/0xbb0 /arch/x86/mm/fault.c:1298
 [<     inline     >] SYSC_sendmmsg /net/socket.c:2061
 [<ffffffff85558375>] SyS_sendmmsg+0x35/0x60 /net/socket.c:2056
 [<ffffffff8675b680>] entry_SYSCALL_64_fastpath+0x23/0xc1 /arch/x86/entry/entry_64.S:207
Memory state around the buggy address:
 ffff8803f7247000: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
 ffff8803f7247080: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
>ffff8803f7247100: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 f1 f1
                                                             ^
 ffff8803f7247180: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
 ffff8803f7247200: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
==================================================================

#define _GNU_SOURCE
#include <unistd.h>
#include <stdint.h>
#include <sys/socket.h>
#include <sys/mman.h>
#include <linux/in.h>
#include <fcntl.h>
#include <string.h>
#include <stdio.h>

int main()
{
	int fd;
	mmap((void *)0x20000000ul, 0xff2000ul, 0x3ul, 0x32ul, -1, 0x0ul);
	fd = socket(AF_INET6, SOCK_STREAM, IPPROTO_SCTP);
	memcpy((void*)0x20f82f80, "\x0a\x00\xab\x12\x72\xd4\x19\x9a\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x01\x85\xda\x00\xa0\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00", 128);
        bind(fd, (struct sockaddr*)0x20f82f80ul, 0x80ul);
	*(uint64_t*)0x202e1fc8 = (uint64_t)0x20f77f80;
	*(uint32_t*)0x202e1fd0 = (uint32_t)0x80;
	*(uint64_t*)0x202e1fd8 = (uint64_t)0x20f7dfe0;
	*(uint64_t*)0x202e1fe0 = (uint64_t)0x2;
	*(uint64_t*)0x202e1fe8 = (uint64_t)0x20f77000;
	*(uint64_t*)0x202e1ff0 = (uint64_t)0x3;
	*(uint32_t*)0x202e1ff8 = (uint32_t)0x80;
	memcpy((void*)0x20f77f80, "\x0a\x00\xab\x12\xb0\xb3\x20\x7b\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x01\xc2\xc2\x0b\xb2\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00", 128);
	*(uint64_t*)0x20f7dfe0 = (uint64_t)0x20f77fc5;
	*(uint64_t*)0x20f7dfe8 = (uint64_t)0x3b;
	*(uint64_t*)0x20f7dff0 = (uint64_t)0x20f77fac;
	*(uint64_t*)0x20f7dff8 = (uint64_t)0x54;
	memcpy((void*)0x20f77fc5, "\xa5\x7d\xf3\xc4\xfe\xd3\xfd\x44\x63\x00\x8c\x1e\x4c\x2e\x8d\x8d\x9a\x9c\x9c\x9d\x5b\x7c\xe1\x06\xf7\x15\x16\xed\x68\xd1\xfc\xf4\xa4\x3a\xe4\x69\x51\x16\x74\xf4\x1a\xcf\x0e\x99\xc3\xa3\x87\xe7\x81\x6c\x10\x78\x75\x17\x69\x9d\x11\x0c\xc7", 59);
	memcpy((void*)0x20f77fac, "\x86\x08\x89\x3c\xf3\x58\xea\xe7\x64\x6a\xfb\xb5\xe8\xdd\x5f\x69\xa5\xd4\xdc\xd9\xe7\x71\x95\x07\x78\x7b\x21\xda\x43\x9c\x62\x4d\xca\x64\xb5\x6e\x96\x55\xe9\x58\x76\x66\x1d\xb9\x7b\xe6\x20\xc1\xa9\xed\x70\xc1\x2b\x7c\x86\x8c\xba\x28\xb3\x2c\xb9\x64\xb7\x84\x65\x0d\x7f\xa6\x98\x6f\x49\xcb\x35\xad\x5a\xdf\x13\x75\x99\x57\x7e\xbb\x38\x89", 84);
	*(uint64_t*)0x20f77000 = (uint64_t)0x15;
	*(uint32_t*)0x20f77008 = (uint32_t)0x1;
	*(uint32_t*)0x20f7700c = (uint32_t)0xfffffffffffffffe;
	*(uint8_t*)0x20f77010 = (uint8_t)0xbb;
	*(uint8_t*)0x20f77011 = (uint8_t)0x2;
	*(uint8_t*)0x20f77012 = (uint8_t)0x5;
	*(uint8_t*)0x20f77013 = (uint8_t)0x2;
	*(uint8_t*)0x20f77014 = (uint8_t)0x80000000;
	*(uint64_t*)0x20f77015 = (uint64_t)0x10;
	*(uint32_t*)0x20f7701d = (uint32_t)0xffff;
	*(uint32_t*)0x20f77021 = (uint32_t)0x1;
	*(uint64_t*)0x20f77025 = (uint64_t)0x13;
	*(uint32_t*)0x20f7702d = (uint32_t)0x6;
	*(uint32_t*)0x20f77031 = (uint32_t)0xfffffffffffffe00;
	*(uint8_t*)0x20f77035 = (uint8_t)0x80000000;
	*(uint8_t*)0x20f77036 = (uint8_t)0xfffffffffffffff8;
	sendmmsg(fd, (struct mmsghdr *)0x202e1fc8ul, 0x1ul, 0x1ul);
	return 0;
}

Best Regards,
Baozeng Ding
