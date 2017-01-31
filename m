From: Andrey Konovalov <andreyknvl@google.com>
Subject: net/tcp: warning in tcp_try_coalesce/skb_try_coalesce
Date: Tue, 31 Jan 2017 14:17:11 +0100
Message-ID: <CAAeHK+xaFar2pj1xkbkhfjN+3ucLsfMpoHWFAKcHq3-F_Zm+mw@mail.gmail.com>
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
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I've got the following error report while running the syzkaller fuzzer.

On commit 566cf877a1fcb6d6dc0126b076aad062054c2637 (4.10-rc6).

The fuzzer hits this issue quite often, but I don't have a working reproducer.

WARNING: CPU: 3 PID: 7091 at net/core/skbuff.c:4331
skb_try_coalesce+0x14b1/0x1f80 net/core/skbuff.c:4331
Kernel panic - not syncing: panic_on_warn set ...

CPU: 3 PID: 7091 Comm: syz-executor4 Not tainted 4.10.0-rc6+ #116
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
Call Trace:
 __dump_stack lib/dump_stack.c:15 [inline]
 dump_stack+0x292/0x398 lib/dump_stack.c:51
 panic+0x1cb/0x3a9 kernel/panic.c:179
 __warn+0x1c4/0x1e0 kernel/panic.c:539
 warn_slowpath_null+0x2c/0x40 kernel/panic.c:582
 skb_try_coalesce+0x14b1/0x1f80 net/core/skbuff.c:4331
 tcp_try_coalesce+0x178/0x560 net/ipv4/tcp_input.c:4337
 tcp_queue_rcv+0x13c/0x7a0 net/ipv4/tcp_input.c:4572
 tcp_data_queue+0x97e/0x46b0 net/ipv4/tcp_input.c:4681
 tcp_rcv_state_process+0xd92/0x42d0 net/ipv4/tcp_input.c:6130
 tcp_v4_do_rcv+0x571/0x940 net/ipv4/tcp_ipv4.c:1426
 sk_backlog_rcv include/net/sock.h:893 [inline]
 __release_sock+0x127/0x3a0 net/core/sock.c:2053
 release_sock+0xa5/0x2b0 net/core/sock.c:2540
 inet_shutdown+0x1a8/0x350 net/ipv4/af_inet.c:833
 SYSC_shutdown net/socket.c:1840 [inline]
 SyS_shutdown+0x253/0x2f0 net/socket.c:1831
 entry_SYSCALL_64_fastpath+0x1f/0xc2
RIP: 0033:0x4457d9
RSP: 002b:00007f73b41a5b58 EFLAGS: 00000282 ORIG_RAX: 0000000000000030
RAX: ffffffffffffffda RBX: 0000000000000005 RCX: 00000000004457d9
RDX: 0000000000000000 RSI: 0000000000000001 RDI: 0000000000000005
RBP: 00000000006e2170 R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000282 R12: 0000000000708000
R13: 0000000000000005 R14: 0000000000000029 R15: 000000000000003f
Dumping ftrace buffer:
   (ftrace buffer empty)
Kernel Offset: disabled
Rebooting in 86400 seconds..
