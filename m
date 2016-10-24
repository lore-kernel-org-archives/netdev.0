From: Andrey Konovalov <andreyknvl@google.com>
Subject: net/can: warning in bcm_connect/proc_register
Date: Mon, 24 Oct 2016 18:21:27 +0200
Message-ID: <CAAeHK+x6w+Lg1GoCZXdjPtM6n72dpUbF_Bvtg80YNK-Wh8YJ4w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: syzkaller <syzkaller@googlegroups.com>,
        Kostya Serebryany <kcc@google.com>,
        Alexander Potapenko <glider@google.com>,
        Dmitry Vyukov <dvyukov@google.com>,
        Eric Dumazet <edumazet@google.com>
To: Oliver Hartkopp <socketcan@hartkopp.net>,
        Marc Kleine-Budde <mkl@pengutronix.de>,
        "David S. Miller" <davem@davemloft.net>, linux-can@vger.kernel.org,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I've got the following error report while running the syzkaller fuzzer:

WARNING: CPU: 0 PID: 32451 at fs/proc/generic.c:345 proc_register+0x25e/0x300
proc_dir_entry 'can-bcm/249757' already registered
Kernel panic - not syncing: panic_on_warn set ...

CPU: 0 PID: 32451 Comm: syz-executor Not tainted 4.9.0-rc1+ #293
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
 ffff880037d8fae0 ffffffff81b474f4 0000000000000003 dffffc0000000000
 ffffffff840cbf00 ffff880037d8fb04 ffff880037d8fba8 ffffffff8140c06a
 0000000041b58ab3 ffffffff8479ab7d ffffffff8140beae ffffffff00000032
Call Trace:
 [<     inline     >] __dump_stack lib/dump_stack.c:15
 [<ffffffff81b474f4>] dump_stack+0xb3/0x10f lib/dump_stack.c:51
 [<ffffffff8140c06a>] panic+0x1bc/0x39d kernel/panic.c:179
 [<ffffffff8111125c>] __warn+0x1cc/0x1f0 kernel/panic.c:542
 [<ffffffff8111132c>] warn_slowpath_fmt+0xac/0xd0 kernel/panic.c:565
 [<ffffffff8167d6ee>] proc_register+0x25e/0x300 fs/proc/generic.c:344
 [<ffffffff8167dc01>] proc_create_data+0x101/0x1a0 fs/proc/generic.c:507
 [<ffffffff835729ce>] bcm_connect+0x16e/0x380 net/can/bcm.c:1585
 [<ffffffff82b725e4>] SYSC_connect+0x244/0x2f0 net/socket.c:1533
 [<ffffffff82b74dd4>] SyS_connect+0x24/0x30 net/socket.c:1514
 [<ffffffff83fc19c1>] entry_SYSCALL_64_fastpath+0x1f/0xc2
Dumping ftrace buffer:
   (ftrace buffer empty)
Kernel Offset: disabled

On commit 07d9a380680d1c0eb51ef87ff2eab5c994949e69 (Oct 23).
