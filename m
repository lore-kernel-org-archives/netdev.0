From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: KASAN: use-after-free Read in sit_tunnel_xmit
Date: Mon, 30 Oct 2017 11:41:50 -0700
Message-ID: <CAM_iQpVyf_=UFW5Oay9a15GD8QaXbgbPse333SWAivE=dd+TXQ@mail.gmail.com>
References: <001a1141c71c1c6df8055cc55e50@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: David Miller <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        LKML <linux-kernel@vger.kernel.org>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        syzkaller-bugs@googlegroups.com,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
To: syzbot
        <bot+1aa412fe58f4059538c0204a0f096524e6dce60b@syzkaller.appspotmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <001a1141c71c1c6df8055cc55e50@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 30, 2017 at 8:34 AM, syzbot
<bot+1aa412fe58f4059538c0204a0f096524e6dce60b@syzkaller.appspotmail.com>
wrote:
> Hello,
>
> syzkaller hit the following crash on
> 4dc12ffeaeac939097a3f55c881d3dc3523dff0c
> git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git/master
> compiler: gcc (GCC) 7.1.1 20170620
> .config is attached
> Raw console output is attached.
>
>
>
>
> skbuff: bad partial csum: csum=53081/14726 len=2273
> ==================================================================
> BUG: KASAN: use-after-free in ipv6_get_dsfield include/net/dsfield.h:23
> [inline]
> BUG: KASAN: use-after-free in ipip6_tunnel_xmit net/ipv6/sit.c:968 [inline]
> BUG: KASAN: use-after-free in sit_tunnel_xmit+0x2a41/0x3130
> net/ipv6/sit.c:1016
> Read of size 2 at addr ffff8801c64afd00 by task syz-executor3/16942
>
> CPU: 0 PID: 16942 Comm: syz-executor3 Not tainted 4.14.0-rc5+ #97
> Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS
> Google 01/01/2011
> Call Trace:
>  __dump_stack lib/dump_stack.c:16 [inline]
>  dump_stack+0x194/0x257 lib/dump_stack.c:52
>  print_address_description+0x73/0x250 mm/kasan/report.c:252
>  kasan_report_error mm/kasan/report.c:351 [inline]
>  kasan_report+0x25b/0x340 mm/kasan/report.c:409
>  __asan_report_load2_noabort+0x14/0x20 mm/kasan/report.c:428
>  ipv6_get_dsfield include/net/dsfield.h:23 [inline]
>  ipip6_tunnel_xmit net/ipv6/sit.c:968 [inline]
>  sit_tunnel_xmit+0x2a41/0x3130 net/ipv6/sit.c:1016
>  __netdev_start_xmit include/linux/netdevice.h:4022 [inline]
>  netdev_start_xmit include/linux/netdevice.h:4031 [inline]
>  xmit_one net/core/dev.c:3008 [inline]
>  dev_hard_start_xmit+0x248/0xac0 net/core/dev.c:3024
>  __dev_queue_xmit+0x17d2/0x2070 net/core/dev.c:3505
>  dev_queue_xmit+0x17/0x20 net/core/dev.c:3538
>  neigh_direct_output+0x15/0x20 net/core/neighbour.c:1390
>  neigh_output include/net/neighbour.h:481 [inline]
>  ip6_finish_output2+0xad1/0x22a0 net/ipv6/ip6_output.c:120
>  ip6_fragment+0x25ae/0x3420 net/ipv6/ip6_output.c:723
>  ip6_finish_output+0x319/0x920 net/ipv6/ip6_output.c:144
>  NF_HOOK_COND include/linux/netfilter.h:238 [inline]
>  ip6_output+0x1f4/0x850 net/ipv6/ip6_output.c:163
>  dst_output include/net/dst.h:459 [inline]
>  ip6_local_out+0x95/0x160 net/ipv6/output_core.c:176
>  ip6_send_skb+0xa1/0x330 net/ipv6/ip6_output.c:1658
>  ip6_push_pending_frames+0xb3/0xe0 net/ipv6/ip6_output.c:1678
>  rawv6_push_pending_frames net/ipv6/raw.c:616 [inline]
>  rawv6_sendmsg+0x2eb9/0x3e40 net/ipv6/raw.c:935
>  inet_sendmsg+0x11f/0x5e0 net/ipv4/af_inet.c:763
>  sock_sendmsg_nosec net/socket.c:633 [inline]
>  sock_sendmsg+0xca/0x110 net/socket.c:643
>  SYSC_sendto+0x352/0x5a0 net/socket.c:1750
>  SyS_sendto+0x40/0x50 net/socket.c:1718
>  entry_SYSCALL_64_fastpath+0x1f/0xbe
> RIP: 0033:0x452869
> RSP: 002b:00007fe3c12e5be8 EFLAGS: 00000212 ORIG_RAX: 000000000000002c
> RAX: ffffffffffffffda RBX: 00000000007580d8 RCX: 0000000000452869
> RDX: 00000000000007f1 RSI: 000000002013b7ff RDI: 0000000000000014
> RBP: 0000000000000161 R08: 00000000204e8fe4 R09: 000000000000001c
> R10: 0000000001000000 R11: 0000000000000212 R12: 00000000006f01b8
> R13: 00000000ffffffff R14: 00007fe3c12e66d4 R15: 0000000000000017
>
> Allocated by task 16924:
>  save_stack_trace+0x16/0x20 arch/x86/kernel/stacktrace.c:59
>  save_stack+0x43/0xd0 mm/kasan/kasan.c:447
>  set_track mm/kasan/kasan.c:459 [inline]
>  kasan_kmalloc+0xad/0xe0 mm/kasan/kasan.c:551
>  __do_kmalloc_node mm/slab.c:3689 [inline]
>  __kmalloc_node_track_caller+0x47/0x70 mm/slab.c:3703
>  __kmalloc_reserve.isra.40+0x41/0xd0 net/core/skbuff.c:138
>  __alloc_skb+0x13b/0x780 net/core/skbuff.c:206
>  alloc_skb include/linux/skbuff.h:985 [inline]
>  sock_wmalloc+0x140/0x1d0 net/core/sock.c:1932
>  __ip6_append_data.isra.43+0x2681/0x3340 net/ipv6/ip6_output.c:1397
>  ip6_append_data+0x189/0x290 net/ipv6/ip6_output.c:1552
>  rawv6_sendmsg+0x1dd9/0x3e40 net/ipv6/raw.c:928
>  inet_sendmsg+0x11f/0x5e0 net/ipv4/af_inet.c:763
>  sock_sendmsg_nosec net/socket.c:633 [inline]
>  sock_sendmsg+0xca/0x110 net/socket.c:643
>  SYSC_sendto+0x352/0x5a0 net/socket.c:1750
>  SyS_sendto+0x40/0x50 net/socket.c:1718
>  entry_SYSCALL_64_fastpath+0x1f/0xbe
>
> Freed by task 16942:
>  save_stack_trace+0x16/0x20 arch/x86/kernel/stacktrace.c:59
>  save_stack+0x43/0xd0 mm/kasan/kasan.c:447
>  set_track mm/kasan/kasan.c:459 [inline]
>  kasan_slab_free+0x71/0xc0 mm/kasan/kasan.c:524
>  __cache_free mm/slab.c:3503 [inline]
>  kfree+0xca/0x250 mm/slab.c:3820
>  skb_free_head+0x74/0xb0 net/core/skbuff.c:554
>  pskb_expand_head+0x36b/0x1210 net/core/skbuff.c:1494
>  __pskb_pull_tail+0x14a/0x17c0 net/core/skbuff.c:1877
>  pskb_may_pull include/linux/skbuff.h:2102 [inline]
>  _decode_session6+0x8a4/0x1100 net/ipv6/xfrm6_policy.c:148

Looks like we should indicate error by returning some int
for afinfo->decode_session().



>  __xfrm_decode_session+0x63/0x100 net/xfrm/xfrm_policy.c:2343
>  xfrm_decode_session_reverse include/net/xfrm.h:1181 [inline]
>  icmpv6_route_lookup+0x343/0x640 net/ipv6/icmp.c:372
>  icmp6_send+0x1569/0x25b0 net/ipv6/icmp.c:551
>  icmpv6_send+0x142/0x280 net/ipv6/ip6_icmp.c:42
>  ip6_link_failure+0x94/0x580 net/ipv6/route.c:1997
>  dst_link_failure include/net/dst.h:442 [inline]
>  ipip6_tunnel_xmit net/ipv6/sit.c:940 [inline]
>  sit_tunnel_xmit+0x244f/0x3130 net/ipv6/sit.c:1016
>  __netdev_start_xmit include/linux/netdevice.h:4022 [inline]
>  netdev_start_xmit include/linux/netdevice.h:4031 [inline]
>  xmit_one net/core/dev.c:3008 [inline]
>  dev_hard_start_xmit+0x248/0xac0 net/core/dev.c:3024
>  __dev_queue_xmit+0x17d2/0x2070 net/core/dev.c:3505
>  dev_queue_xmit+0x17/0x20 net/core/dev.c:3538
>  neigh_direct_output+0x15/0x20 net/core/neighbour.c:1390
>  neigh_output include/net/neighbour.h:481 [inline]
>  ip6_finish_output2+0xad1/0x22a0 net/ipv6/ip6_output.c:120
>  ip6_fragment+0x25ae/0x3420 net/ipv6/ip6_output.c:723
>  ip6_finish_output+0x319/0x920 net/ipv6/ip6_output.c:144
>  NF_HOOK_COND include/linux/netfilter.h:238 [inline]
>  ip6_output+0x1f4/0x850 net/ipv6/ip6_output.c:163
>  dst_output include/net/dst.h:459 [inline]
>  ip6_local_out+0x95/0x160 net/ipv6/output_core.c:176
>  ip6_send_skb+0xa1/0x330 net/ipv6/ip6_output.c:1658
>  ip6_push_pending_frames+0xb3/0xe0 net/ipv6/ip6_output.c:1678
>  rawv6_push_pending_frames net/ipv6/raw.c:616 [inline]
>  rawv6_sendmsg+0x2eb9/0x3e40 net/ipv6/raw.c:935
>  inet_sendmsg+0x11f/0x5e0 net/ipv4/af_inet.c:763
>  sock_sendmsg_nosec net/socket.c:633 [inline]
>  sock_sendmsg+0xca/0x110 net/socket.c:643
>  SYSC_sendto+0x352/0x5a0 net/socket.c:1750
>  SyS_sendto+0x40/0x50 net/socket.c:1718
>  entry_SYSCALL_64_fastpath+0x1f/0xbe
>
> The buggy address belongs to the object at ffff8801c64afc80
>  which belongs to the cache kmalloc-512 of size 512
> The buggy address is located 128 bytes inside of
>  512-byte region [ffff8801c64afc80, ffff8801c64afe80)
> The buggy address belongs to the page:
> page:ffffea0007192bc0 count:1 mapcount:0 mapping:ffff8801c64af000 index:0x0
> flags: 0x200000000000100(slab)
> raw: 0200000000000100 ffff8801c64af000 0000000000000000 0000000100000006
> raw: ffffea00072d04e0 ffffea0007083fe0 ffff8801dac00940 0000000000000000
> page dumped because: kasan: bad access detected
>
> Memory state around the buggy address:
>  ffff8801c64afc00: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
>  ffff8801c64afc80: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
>>
>> ffff8801c64afd00: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
>
>                    ^
>  ffff8801c64afd80: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
>  ffff8801c64afe00: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
> ==================================================================
>
>
> ---
> This bug is generated by a dumb bot. It may contain errors.
> See https://goo.gl/tpsmEJ for details.
> Direct all questions to syzkaller@googlegroups.com.
>
> syzbot will keep track of this bug report.
> Once a fix for this bug is committed, please reply to this email with:
> #syz fix: exact-commit-title
> To mark this as a duplicate of another syzbot report, please reply with:
> #syz dup: exact-subject-of-another-report
> If it's a one-off invalid bug report, please reply with:
> #syz invalid
> Note: if the crash happens again, it will cause creation of a new bug
> report.
