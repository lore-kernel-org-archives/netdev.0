From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: general protection fault in fib_dump_info
Date: Mon, 14 Aug 2017 20:33:14 -0700
Message-ID: <1502767994.4936.47.camel@edumazet-glaptop3.roam.corp.google.com>
References: <CADUsjNkM2KuAJj6xc=Xj3he8z3B5XYv5m8H5x-FCHwdGjW_AYg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, kuznet@ms2.inr.ac.ru, yoshfuji@linux-ipv6.org,
        netdev@vger.kernel.org, syzkaller@googlegroups.com
To: idaifish <idaifish@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f53.google.com ([74.125.83.53]:38556 "EHLO
        mail-pg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753185AbdHODdR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 14 Aug 2017 23:33:17 -0400
Received: by mail-pg0-f53.google.com with SMTP id l64so59290706pge.5
        for <netdev@vger.kernel.org>; Mon, 14 Aug 2017 20:33:17 -0700 (PDT)
In-Reply-To: <CADUsjNkM2KuAJj6xc=Xj3he8z3B5XYv5m8H5x-FCHwdGjW_AYg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-08-15 at 10:49 +0800, idaifish wrote:
> Syzkaller hit 'general protection fault in fib_dump_info' bug on
> commit 4.13-rc5..
> 
> Guilty file: net/ipv4/fib_semantics.c
> 
> kasan: GPF could be caused by NULL-ptr deref or user memory access
> general protection fault: 0000 [#1] SMP KASAN
> Modules linked in:
> CPU: 0 PID: 2808 Comm: syz-executor0 Not tainted 4.13.0-rc5 #1
> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS
> Ubuntu-1.8.2-1ubuntu1 04/01/2014
> task: ffff880078562700 task.stack: ffff880078110000
> RIP: 0010:fib_dump_info+0x388/0x1170 net/ipv4/fib_semantics.c:1314
> RSP: 0018:ffff880078117010 EFLAGS: 00010206
> RAX: dffffc0000000000 RBX: 00000000000000fe RCX: 0000000000000002
> RDX: 0000000000000006 RSI: ffff880078117084 RDI: 0000000000000030
> RBP: ffff880078117268 R08: 000000000000000c R09: ffff8800780d80c8
> R10: 0000000058d629b4 R11: 0000000067fce681 R12: 0000000000000000
> R13: ffff8800784bd540 R14: ffff8800780d80b5 R15: ffff8800780d80a4
> FS:  00000000022fa940(0000) GS:ffff88007fc00000(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> CR2: 00000000004387d0 CR3: 0000000079135000 CR4: 00000000000006f0
> Call Trace:
>  inet_rtm_getroute+0xc89/0x1f50 net/ipv4/route.c:2766
>  rtnetlink_rcv_msg+0x288/0x680 net/core/rtnetlink.c:4217
>  netlink_rcv_skb+0x340/0x470 net/netlink/af_netlink.c:2397
>  rtnetlink_rcv+0x28/0x30 net/core/rtnetlink.c:4223
>  netlink_unicast_kernel net/netlink/af_netlink.c:1265 [inline]
>  netlink_unicast+0x4c4/0x6e0 net/netlink/af_netlink.c:1291
>  netlink_sendmsg+0x8c4/0xca0 net/netlink/af_netlink.c:1854
>  sock_sendmsg_nosec net/socket.c:633 [inline]
>  sock_sendmsg+0xca/0x110 net/socket.c:643
>  ___sys_sendmsg+0x779/0x8d0 net/socket.c:2035
>  __sys_sendmsg+0xd1/0x170 net/socket.c:2069
>  SYSC_sendmsg net/socket.c:2080 [inline]
>  SyS_sendmsg+0x2d/0x50 net/socket.c:2076
>  entry_SYSCALL_64_fastpath+0x1a/0xa5
> RIP: 0033:0x4512e9
> RSP: 002b:00007ffc75584cc8 EFLAGS: 00000216 ORIG_RAX: 000000000000002e
> RAX: ffffffffffffffda RBX: 0000000000000002 RCX: 00000000004512e9
> RDX: 0000000000000000 RSI: 0000000020f2cfc8 RDI: 0000000000000003
> RBP: 000000000000000e R08: 0000000000000000 R09: 0000000000000000
> R10: 0000000000000000 R11: 0000000000000216 R12: fffffffffffffffe
> R13: 0000000000718000 R14: 0000000020c44ff0 R15: 0000000000000000
> Code: 00 0f b6 8d ec fd ff ff 48 8b 85 f0 fd ff ff 88 48 17 48 8b 45
> 28 48 8d 78 30 48 b8 00 00 00 00 00 fc ff df 48 89 fa 48 c1 ea 03 <0f>
> b6 04 02 84 c0 74 08 3c 03 0f 8e cb 0c 00 00 48 8b 45 28 44
> RIP: fib_dump_info+0x388/0x1170 net/ipv4/fib_semantics.c:1314 RSP:
> ffff880078117010
> ---[ end trace 254a7af28348f88b ]---
> Kernel panic - not syncing: Fatal exception
> Kernel Offset: disabled
> Rebooting in 86400 seconds..
> 
> ---------------------
> 
> .config and reproducer.prog are attached.  Unfortunately the extracted
> C program can't work.
> Maybe you can follow the instruction
> [https://github.com/google/syzkaller/blob/master/docs/executing_syzkaller_programs.md]
> to reproduce the bug.
> 
> 

Probably fixed by commit 2c87d63ac853550e734edfd45e1be5e5aa44fbcc
("ipv4: route: fix inet_rtm_getroute induced crash")
(In David Miller net tree)
