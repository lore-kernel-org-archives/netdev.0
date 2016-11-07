From: Andrey Konovalov <andreyknvl@google.com>
Subject: net/tcp: warning in tcp_recvmsg
Date: Mon, 7 Nov 2016 20:15:55 +0100
Message-ID: <CAAeHK+zMEM5Fnj0ztwg7T5-G1AqFMiPwsc5+-yUJT-rCeKKDtA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Dmitry Vyukov <dvyukov@google.com>,
        Alexander Potapenko <glider@google.com>,
        Kostya Serebryany <kcc@google.com>,
        Eric Dumazet <edumazet@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f52.google.com ([209.85.213.52]:36056 "EHLO
        mail-vk0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751453AbcKGTXo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Nov 2016 14:23:44 -0500
Received: by mail-vk0-f52.google.com with SMTP id p9so129948197vkd.3
        for <netdev@vger.kernel.org>; Mon, 07 Nov 2016 11:23:39 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I've got the following error report while running the syzkaller fuzzer:

------------[ cut here ]------------
WARNING: CPU: 1 PID: 9957 at net/ipv4/tcp.c:1766
tcp_recvmsg+0x19d7/0x26e0 net/ipv4/tcp.c:1765
Modules linked in:
CPU: 1 PID: 9957 Comm: syz-executor Not tainted 4.9.0-rc4+ #352
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
 ffff880065bd7788 ffffffff81b46a64 0000000000000000 0000000000000000
 ffffffff8445f8e0 0000000000000000 ffff880065bd77d0 ffffffff81111387
 ffff880068414980 00000000000006e6 ffffffff8445f8e0 00000000000006e6
Call Trace:
 [<     inline     >] __dump_stack lib/dump_stack.c:15
 [<ffffffff81b46a64>] dump_stack+0xb3/0x10f lib/dump_stack.c:51
 [<ffffffff81111387>] __warn+0x1a7/0x1f0 kernel/panic.c:550
 [<ffffffff8111159c>] warn_slowpath_null+0x2c/0x40 kernel/panic.c:585
 [<ffffffff830a95b7>] tcp_recvmsg+0x19d7/0x26e0 net/ipv4/tcp.c:1765
 [<ffffffff83171e28>] inet_recvmsg+0x308/0x4b0 net/ipv4/af_inet.c:765
 [<     inline     >] sock_recvmsg_nosec net/socket.c:708
 [<ffffffff82b6fb29>] sock_recvmsg+0xd9/0x110 net/socket.c:715
 [<ffffffff82b6fda7>] sock_read_iter+0x247/0x360 net/socket.c:792
 [<ffffffff8151e2db>] do_iter_readv_writev+0x2bb/0x3f0 fs/read_write.c:695
 [<ffffffff81520141>] do_readv_writev+0x431/0x730 fs/read_write.c:872
 [<ffffffff815204cc>] vfs_readv+0x8c/0xc0 fs/read_write.c:898
 [<ffffffff815205e1>] do_readv+0xe1/0x240 fs/read_write.c:924
 [<     inline     >] SYSC_readv fs/read_write.c:1011
 [<ffffffff815238b7>] SyS_readv+0x27/0x30 fs/read_write.c:1008
 [<ffffffff83fc1501>] entry_SYSCALL_64_fastpath+0x1f/0xc2
arch/x86/entry/entry_64.S:209
---[ end trace 8efae7c5dcb2bd76 ]---

On commit bc33b0ca11e3df467777a4fa7639ba488c9d4911 (Nov 5).

Thanks!
