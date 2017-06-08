From: Andrey Konovalov <andreyknvl@google.com>
Subject: net/can: trying to register non-static key in can_rx_register
Date: Thu, 8 Jun 2017 17:16:22 +0200
Message-ID: <CAAeHK+ywJzK4Hd=O_+j+Dw7pb=s-MgwVLJywrLAQdkwfybdu1Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Dmitry Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Oliver Hartkopp <socketcan@hartkopp.net>,
        Marc Kleine-Budde <mkl@pengutronix.de>,
        "David S. Miller" <davem@davemloft.net>, linux-can@vger.kernel.org,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I've got the following error report while fuzzing the kernel with syzkaller.

On commit b29794ec95c6856b316c2295904208bf11ffddd9 (4.12-rc4+).

INFO: trying to register non-static key.
the code is fine but needs lockdep annotation.
turning off the locking correctness validator.
CPU: 2 PID: 17404 Comm: syz-executor1 Not tainted 4.12.0-rc4+ #15
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
Call Trace:
 __dump_stack lib/dump_stack.c:16 [inline]
 dump_stack+0x292/0x395 lib/dump_stack.c:52
 register_lock_class+0x717/0x1aa0 kernel/locking/lockdep.c:755
 __lock_acquire+0x269/0x3690 kernel/locking/lockdep.c:3255
 ? 0xffffffffa0000000
 lock_acquire+0x22d/0x560 kernel/locking/lockdep.c:3855
 __raw_spin_lock include/linux/spinlock_api_smp.h:142 [inline]
 _raw_spin_lock+0x2f/0x40 kernel/locking/spinlock.c:151
 spin_lock include/linux/spinlock.h:299 [inline]
 can_rx_register+0x4f3/0x700 net/can/af_can.c:483
 raw_enable_filters+0xd7/0x1e0 net/can/raw.c:192
 raw_enable_allfilters+0x8a/0x1e0 net/can/raw.c:258
 raw_bind+0x244/0x830 net/can/raw.c:435
 SYSC_bind+0x20e/0x4c0 net/socket.c:1422
 SyS_bind+0x29/0x30 net/socket.c:1408
 entry_SYSCALL_64_fastpath+0x1f/0xbe
RIP: 0033:0x446389
RSP: 002b:00007fa1efda2c08 EFLAGS: 00000292 ORIG_RAX: 0000000000000031
RAX: ffffffffffffffda RBX: 0000000000000220 RCX: 0000000000446389
RDX: 0000000000000060 RSI: 0000000020001fa0 RDI: 0000000000000017
RBP: 00000000ffffffff R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000292 R12: 0000000000000017
R13: 0000000000003770 R14: 00000000006e4830 R15: 0000000000c13000
