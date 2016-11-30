From: Andrey Konovalov <andreyknvl@google.com>
Subject: Re: net: GPF in rt6_get_cookie
Date: Wed, 30 Nov 2016 11:39:16 +0100
Message-ID: <CAAeHK+wvAZByn7-fONWYk1P8fXA9wNdkVLGtXfQsdFb-NSdn+g@mail.gmail.com>
References: <CACT4Y+Y-B_GCDGpcLHt1CtXs3u9MBFD82MSFWTcL_v4Vi3+=HQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>
To: syzkaller <syzkaller@googlegroups.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CACT4Y+Y-B_GCDGpcLHt1CtXs3u9MBFD82MSFWTcL_v4Vi3+=HQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Nov 26, 2016 at 5:23 PM, 'Dmitry Vyukov' via syzkaller
<syzkaller@googlegroups.com> wrote:
> Hello,
>
> I got several GPFs in rt6_get_cookie while running syzkaller:
>
> general protection fault: 0000 [#1] SMP DEBUG_PAGEALLOC KASAN
> Dumping ftrace buffer:
>    (ftrace buffer empty)
> Modules linked in:
> CPU: 2 PID: 10156 Comm: syz-executor Not tainted 4.9.0-rc5+ #54
> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
> task: ffff880016f40480 task.stack: ffff88000fc00000
> RIP: 0010:[<ffffffff87a209e8>]  [<     inline     >] rt6_get_cookie
> include/net/ip6_fib.h:174
> RIP: 0010:[<ffffffff87a209e8>]  [<ffffffff87a209e8>]
> sctp_v6_get_dst+0x7c8/0x1960 net/sctp/ipv6.c:340
> RSP: 0018:ffff88000fc07298  EFLAGS: 00010202
> RAX: dffffc0000000000 RBX: 0000000000000000 RCX: ffffc900029f5000
> RDX: 0000000000000015 RSI: 0000000000000001 RDI: 00000000000000a8
> RBP: ffff88000fc07580 R08: 0000000000000000 R09: 0000000000000001
> R10: 0000000000000000 R11: 0000000000000000 R12: ffff880066cd0068
> R13: 1ffff10001f80e92 R14: ffff880066cd0040 R15: ffff88005f2d2808
> FS:  00007f52c41f7700(0000) GS:ffff88006d000000(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> CR2: 0000000020016000 CR3: 0000000065dd7000 CR4: 00000000000006e0
> DR0: 0000000000000400 DR1: 0000000000000400 DR2: 0000000000000000
> DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000600
> Stack:
>  ffffffff87a210f6 ffffffff8701ad45 ffff88006768ec20 ffff88006768ec20
>  0000000000000000 0000000016f40480 ffff88000fc07450 1ffff1000cd9a017
>  ffff88006768ec00 ffff880066fc0730 ffff880066cd0068 1ffff10001f80e66
> Call Trace:
>  [<ffffffff879a313d>] sctp_transport_route+0xad/0x430 net/sctp/transport.c:279
>  [<ffffffff8799b106>] sctp_assoc_add_peer+0x5a6/0x13e0 net/sctp/associola.c:641
>  [<ffffffff879e8911>] sctp_sendmsg+0x1921/0x3bc0 net/sctp/socket.c:1864
>  [<ffffffff8701ad45>] inet_sendmsg+0x385/0x590 net/ipv4/af_inet.c:734
>  [<     inline     >] sock_sendmsg_nosec net/socket.c:621
>  [<ffffffff86a6d54f>] sock_sendmsg+0xcf/0x110 net/socket.c:631
>  [<ffffffff86a6ede0>] SYSC_sendto+0x660/0x810 net/socket.c:1656
>  [<ffffffff86a71dd5>] SyS_sendto+0x45/0x60 net/socket.c:1624
>  [<ffffffff88149dc5>] entry_SYSCALL_64_fastpath+0x23/0xc6
> Code: 00 00 48 8b 84 24 88 00 00 00 48 8b 58 40 e8 80 76 cc f9 48 8d
> bb a8 00 00 00 48 b8 00 00 00 00 00 fc ff df 48 89 fa 48 c1 ea 03 <80>
> 3c 02 00 0f 85 56 0f 00 00 48 8b 9b a8 00 00 00 45 31 ed 48
> RIP  [<     inline     >] rt6_get_cookie include/net/ip6_fib.h:174
> RIP  [<ffffffff87a209e8>] sctp_v6_get_dst+0x7c8/0x1960 net/sctp/ipv6.c:340
>  RSP <ffff88000fc07298>
> ---[ end trace b8d1354fa571700d ]---
>
>
> general protection fault: 0000 [#1] SMP DEBUG_PAGEALLOC KASAN
> Dumping ftrace buffer:
>    (ftrace buffer empty)
> Modules linked in:
> CPU: 3 PID: 22744 Comm: syz-executor Not tainted 4.9.0-rc5+ #54
> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
> task: ffff88006b92a840 task.stack: ffff88006a730000
> RIP: 0010:[<ffffffff87a209e8>]  [<     inline     >] rt6_get_cookie
> include/net/ip6_fib.h:174
> RIP: 0010:[<ffffffff87a209e8>]  [<ffffffff87a209e8>]
> sctp_v6_get_dst+0x7c8/0x1960 net/sctp/ipv6.c:340
> RSP: 0018:ffff88006a736b88  EFLAGS: 00010202
> RAX: dffffc0000000000 RBX: 0000000000000000 RCX: ffffc90003c4f000
> RDX: 0000000000000015 RSI: 0000000000000001 RDI: 00000000000000a8
> RBP: ffff88006a736e68 R08: 0000000000000000 R09: 0000000000000001
> R10: 0000000000000000 R11: 0000000000000000 R12: ffff880064cff268
> R13: 1ffff1000d4e6db0 R14: ffff880064cff240 R15: ffff88006a4b6808
> FS:  00007f74f4ec9700(0000) GS:ffff88006d100000(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> CR2: 000000002070effc CR3: 000000003bd2f000 CR4: 00000000000006e0
> DR0: 0000000000000400 DR1: 0000000000000400 DR2: 0000000000000000
> DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000600
> Stack:
>  ffffffff87a210f6 ffffffff000bbd2d ffff88006c2cd5a0 ffff88006c2cd5a0
>  0000000000000000 000000006ccb46c0 ffff88006a736d40 1ffff1000c99fe57
>  ffff88006c2cd500 ffff8800658b1f30 ffff880064cff268 1ffff1000d4e6d84
> Call Trace:
>  [<ffffffff879a313d>] sctp_transport_route+0xad/0x430 net/sctp/transport.c:279
>  [<ffffffff8799b106>] sctp_assoc_add_peer+0x5a6/0x13e0 net/sctp/associola.c:641
>  [<ffffffff879e4358>] __sctp_connect+0x288/0xc90 net/sctp/socket.c:1178
>  [<ffffffff879e4f0b>] __sctp_setsockopt_connectx+0x1ab/0x200
> net/sctp/socket.c:1332
>  [<     inline     >] sctp_getsockopt_connectx3 net/sctp/socket.c:1417
>  [<ffffffff879fd2bd>] sctp_getsockopt+0x36ed/0x6800 net/sctp/socket.c:6474
>  [<ffffffff86a76c0a>] sock_common_getsockopt+0x9a/0xe0 net/core/sock.c:2649
>  [<     inline     >] SYSC_getsockopt net/socket.c:1788
>  [<ffffffff86a724d7>] SyS_getsockopt+0x257/0x390 net/socket.c:1770
>  [<ffffffff88149dc5>] entry_SYSCALL_64_fastpath+0x23/0xc6
> Code: 00 00 48 8b 84 24 88 00 00 00 48 8b 58 40 e8 80 76 cc f9 48 8d
> bb a8 00 00 00 48 b8 00 00 00 00 00 fc ff df 48 89 fa 48 c1 ea 03 <80>
> 3c 02 00 0f 85 56 0f 00 00 48 8b 9b a8 00 00 00 45 31 ed 48
> RIP  [<     inline     >] rt6_get_cookie include/net/ip6_fib.h:174
> RIP  [<ffffffff87a209e8>] sctp_v6_get_dst+0x7c8/0x1960 net/sctp/ipv6.c:340
>  RSP <ffff88006a736b88>
> ---[ end trace f42d1c14cb6d2835 ]---
>
> This happened on commit a25f0944ba9b1d8a6813fd6f1a86f1bd59ac25a6 (Nov 13).
>
> Unfortunately this is not reproducible.
>
> The line is:
>
>     return rt->rt6i_node ? rt->rt6i_node->fn_sernum : 0;
>
> Can it be a data race? rt->rt6i_node != NULL, but the next moment it
> is already NULL? That would explain the crash and non-reproducibility
> (need ThreadSanitizer!).
>
> This always happened when called from sctp code, but I don't know if
> it is relevant or not. It happened only 3 times.

I'm seeing similar crashes from ipv6 and dccp code, reports below.

===

general protection fault: 0000 [#1] SMP KASAN
Dumping ftrace buffer:
   (ftrace buffer empty)
Modules linked in:
CPU: 1 PID: 30320 Comm: syz-executor0 Not tainted 4.9.0-rc6+ #462
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
task: ffff880069c10040 task.stack: ffff880069f20000
RIP: 0010:[<ffffffff839eec82>]  [<     inline     >] rt6_get_cookie
include/net/ip6_fib.h:174
RIP: 0010:[<ffffffff839eec82>]  [<     inline     >] ip6_dst_store
include/net/ip6_route.h:174
RIP: 0010:[<ffffffff839eec82>]  [<ffffffff839eec82>]
dccp_v6_connect+0x762/0x14e0 net/dccp/ipv6.c:899
RSP: 0018:ffff880069f27ab0  EFLAGS: 00010202
RAX: ffff880069c10040 RBX: ffff88003b5b0040 RCX: 0000000000000000
RDX: dffffc0000000000 RSI: ffffc90000e6c000 RDI: 00000000000000a8
RBP: ffff880069f27c08 R08: 0000000000000015 R09: ffffffff839eec65
R10: 1ffff1000d2d78e0 R11: dffffc0000000000 R12: ffff880069f27e00
R13: ffff8800696bc6c0 R14: ffff88003b5b08e8 R15: ffff88003b5b08e8
FS:  00007f04712ef700(0000) GS:ffff88003ed00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00000000004ad010 CR3: 0000000037c6a000 CR4: 00000000000006e0
Stack:
 ffff880069f27c58 ffff88003b5b04a0 ffff88003b5b0088 ffff88003b5b0078
 ffff880069f27e02 ffff88003b5b0052 00000000ffffffff 0000000000000000
 1ffff1000d3e4f60 0000000000000000 0000000041b58ab3 ffffffff84a3599d
Call Trace:
 [<ffffffff8329b087>] __inet_stream_connect+0x2a7/0xb30 net/ipv4/af_inet.c:594
 [<ffffffff8329b965>] inet_stream_connect+0x55/0xa0 net/ipv4/af_inet.c:655
 [<ffffffff82c9e5f4>] SYSC_connect+0x244/0x2f0 net/socket.c:1548
 [<ffffffff82ca0de4>] SyS_connect+0x24/0x30 net/socket.c:1529
 [<ffffffff81006485>] do_syscall_64+0x195/0x490 arch/x86/entry/common.c:280
 [<ffffffff840f2d09>] entry_SYSCALL64_slow_path+0x25/0x25
Code: 49 8b 7d 40 48 89 7c 24 38 e8 cb 50 a6 fd 48 8b 4c 24 38 48 ba
00 00 00 00 00 fc ff df 48 8d b9 a8 00 00 00 49 89 f8 49 c1 e8 03 <41>
80 3c 10 00 0f 85 52 0d 00 00 48 8b 81 a8 00 00 00 48 85 c0
RIP  [<     inline     >] rt6_get_cookie include/net/ip6_fib.h:174
RIP  [<     inline     >] ip6_dst_store include/net/ip6_route.h:174
RIP  [<ffffffff839eec82>] dccp_v6_connect+0x762/0x14e0 net/dccp/ipv6.c:899
 RSP <ffff880069f27ab0>
---[ end trace e7d9d916f3bf26c5 ]---
Kernel panic - not syncing: Fatal exception
Dumping ftrace buffer:
   (ftrace buffer empty)
Kernel Offset: disabled

===

general protection fault: 0000 [#1] SMP KASAN
Dumping ftrace buffer:
   (ftrace buffer empty)
Modules linked in:
CPU: 3 PID: 21865 Comm: syz-executor0 Not tainted 4.9.0-rc6+ #462
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
task: ffff88003bacc480 task.stack: ffff88003a038000
RIP: 0010:[<ffffffff834c9c7f>]  [<     inline     >] rt6_get_cookie
include/net/ip6_fib.h:174
RIP: 0010:[<ffffffff834c9c7f>]  [<     inline     >] ip6_dst_store
include/net/ip6_route.h:174
RIP: 0010:[<ffffffff834c9c7f>]  [<ffffffff834c9c7f>]
ip6_datagram_dst_update+0x75f/0xe70 net/ipv6/datagram.c:108
RSP: 0018:ffff88003a03fb48  EFLAGS: 00010202
RAX: ffff88003bacc480 RBX: ffff880068e887c0 RCX: 0000000000000001
RDX: 0000000000000015 RSI: ffffc90000de4000 RDI: 00000000000000a8
RBP: ffff88003a03fc88 R08: 0000000000004000 R09: ffffffff834c9c67
R10: dffffc0000000000 R11: dffffc0000000000 R12: ffff880068e88cf0
R13: ffff88006ba75a40 R14: 0000000000000000 R15: 0000000000000000
FS:  00007f1d4c9f3700(0000) GS:ffff88006e100000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00000000004ad010 CR3: 000000006cde5000 CR4: 00000000000006e0
Stack:
 ffffffff834c997b 0000000041b58ab3 ffffffff849dee58 1ffff10007407f70
 ffff880068e887f8 ffff880068e887f8 ffff880068e88cf0 0000000041b58ab3
 ffffffff84a35071 ffffffff834c9520 0000000000000007 ffff88003bacc480
Call Trace:
 [<     inline     >] __ip6_datagram_connect net/ipv6/datagram.c:246
 [<ffffffff834cab95>] ip6_datagram_connect+0x375/0xcc0 net/ipv6/datagram.c:261
 [<ffffffff834cb53f>] ip6_datagram_connect_v6_only+0x5f/0x80
net/ipv6/datagram.c:273
 [<ffffffff8329a3ab>] inet_dgram_connect+0x11b/0x200 net/ipv4/af_inet.c:530
 [<ffffffff82c9e5f4>] SYSC_connect+0x244/0x2f0 net/socket.c:1548
 [<ffffffff82ca0de4>] SyS_connect+0x24/0x30 net/socket.c:1529
 [<ffffffff840f2c41>] entry_SYSCALL_64_fastpath+0x1f/0xc2
Code: 80 3c 08 00 0f 85 96 05 00 00 4d 8b 7d 40 e8 c9 a0 f8 fd 49 8d
bf a8 00 00 00 49 ba 00 00 00 00 00 fc ff df 48 89 fa 48 c1 ea 03 <42>
80 3c 12 00 0f 85 74 05 00 00 4d 8b bf a8 00 00 00 4d 85 ff
RIP  [<     inline     >] rt6_get_cookie include/net/ip6_fib.h:174
RIP  [<     inline     >] ip6_dst_store include/net/ip6_route.h:174
RIP  [<ffffffff834c9c7f>] ip6_datagram_dst_update+0x75f/0xe70
net/ipv6/datagram.c:108
 RSP <ffff88003a03fb48>
---[ end trace 148fc8ac80034c6f ]---
Kernel panic - not syncing: Fatal exception
Dumping ftrace buffer:
   (ftrace buffer empty)
Kernel Offset: disabled

===

>
> Thanks.
>
> --
> You received this message because you are subscribed to the Google Groups "syzkaller" group.
> To unsubscribe from this group and stop receiving emails from it, send an email to syzkaller+unsubscribe@googlegroups.com.
> For more options, visit https://groups.google.com/d/optout.
