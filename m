From: Andrey Konovalov <andreyknvl@google.com>
Subject: net/ipv6: null-ptr-deref in ip6mr_sk_done
Date: Sun, 5 Mar 2017 17:54:01 +0100
Message-ID: <CAAeHK+z9YUi6Qh7tkODFaDXuDNmUx173CQe5hnT3r8-3Ycg8+w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <edumazet@google.com>,
        Dmitry Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f170.google.com ([209.85.128.170]:34477 "EHLO
        mail-wr0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750770AbdCEQyE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 5 Mar 2017 11:54:04 -0500
Received: by mail-wr0-f170.google.com with SMTP id l37so102142873wrc.1
        for <netdev@vger.kernel.org>; Sun, 05 Mar 2017 08:54:03 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I've got the following bug report while fuzzing the kernel with syzkaller.
Unfortunately it's not reproducible.

On commit e5d56efc97f8240d0b5d66c03949382b6d7e5570 (Feb 26).

kasan: GPF could be caused by NULL-ptr deref or user memory access
general protection fault: 0000 [#1] SMP KASAN
Dumping ftrace buffer:
   (ftrace buffer empty)
Modules linked in:
CPU: 0 PID: 14446 Comm: syz-executor6 Not tainted 4.10.0+ #82
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
task: ffff88001f311700 task.stack: ffff88001f6e8000
RIP: 0010:ip6mr_sk_done+0x15a/0x3d0 net/ipv6/ip6mr.c:1618
RSP: 0018:ffff88001f6ef418 EFLAGS: 00010202
RAX: dffffc0000000000 RBX: 1ffff10003edde8c RCX: ffffc900043ee000
RDX: 0000000000000004 RSI: ffffffff83e3b3f8 RDI: 0000000000000020
RBP: ffff88001f6ef508 R08: fffffbfff0dcc5d8 R09: 0000000000000000
R10: ffffffff86e62ec0 R11: 0000000000000000 R12: 0000000000000000
R13: 0000000000000000 R14: ffff88001f6ef4e0 R15: ffff8800380a0040
FS:  00007f7a52cec700(0000) GS:ffff88003ec00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 000000000061c500 CR3: 000000001f1ae000 CR4: 00000000000006f0
DR0: 0000000020000000 DR1: 0000000020000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000600
Call Trace:
 rawv6_close+0x4c/0x80 net/ipv6/raw.c:1217
 inet_release+0xed/0x1c0 net/ipv4/af_inet.c:425
 inet6_release+0x50/0x70 net/ipv6/af_inet6.c:432
 sock_release+0x8d/0x1e0 net/socket.c:597
 __sock_create+0x39d/0x880 net/socket.c:1226
 sock_create_kern+0x3f/0x50 net/socket.c:1243
 inet_ctl_sock_create+0xbb/0x280 net/ipv4/af_inet.c:1526
 icmpv6_sk_init+0x163/0x500 net/ipv6/icmp.c:954
 ops_init+0x10a/0x550 net/core/net_namespace.c:115
 setup_net+0x261/0x660 net/core/net_namespace.c:291
 copy_net_ns+0x27e/0x540 net/core/net_namespace.c:396
9pnet_virtio: no channels available for device ./file1
 create_new_namespaces+0x437/0x9b0 kernel/nsproxy.c:106
 unshare_nsproxy_namespaces+0xae/0x1e0 kernel/nsproxy.c:205
 SYSC_unshare kernel/fork.c:2281 [inline]
 SyS_unshare+0x64e/0x1000 kernel/fork.c:2231
 entry_SYSCALL_64_fastpath+0x1f/0xc2
RIP: 0033:0x4458d9
RSP: 002b:00007f7a52cebb58 EFLAGS: 00000286 ORIG_RAX: 0000000000000110
RAX: ffffffffffffffda RBX: 0000000062020200 RCX: 00000000004458d9
RDX: 0000000000000000 RSI: 0000000000000000 RDI: 0000000062020200
RBP: 00000000006e2f20 R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000286 R12: 00000000007080a8
R13: 0000000000000000 R14: 00007f7a52cec9c0 R15: 00007f7a52cec700
Code: 4d 89 ec c6 04 03 f8 0f 84 c0 00 00 00 48 89 85 10 ff ff ff e8
48 7c 77 fd 49 8d 7d 20 48 8b 85 10 ff ff ff 48 89 fa 48 c1 ea 03 <80>
3c 02 00 0f 85 0c 02 00 00 48 8b 85 30 ff ff ff 49 3b 45 20
RIP: ip6mr_sk_done+0x15a/0x3d0 net/ipv6/ip6mr.c:1618 RSP: ffff88001f6ef418
---[ end trace bc30527cd591afc5 ]---
Kernel panic - not syncing: Fatal exception
Dumping ftrace buffer:
   (ftrace buffer empty)
Kernel Offset: disabled
Rebooting in 86400 seconds..
