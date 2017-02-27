From: Andrey Konovalov <andreyknvl@google.com>
Subject: Re: net/bridge: warning in br_fdb_find
Date: Mon, 27 Feb 2017 16:34:38 +0100
Message-ID: <CAAeHK+xQy5aGOUd3rGJBMkaXWixicO6ozevjnxA_J4K9M8G=+g@mail.gmail.com>
References: <CAAeHK+ziub42iBx7fvoQaa6NYysSFH5o31M+hVStCqdYFVvO+g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Dmitry Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>,
        Eric Dumazet <edumazet@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Stephen Hemminger <stephen@networkplumber.org>,
        "David S. Miller" <davem@davemloft.net>,
        bridge@lists.linux-foundation.org, netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAAeHK+ziub42iBx7fvoQaa6NYysSFH5o31M+hVStCqdYFVvO+g@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 27, 2017 at 4:33 PM, Andrey Konovalov <andreyknvl@google.com> wrote:
> Hi,
>
> I'm getting a huge number of warning reports while fuzzing the kernel
> with syzkaller.
> Unfortunately they are not reproducible.
>
> On commit e5d56efc97f8240d0b5d66c03949382b6d7e5570 (Feb 26).
>
> My .config is attached.
>
> WARNING: CPU: 1 PID: 6203 at net/bridge/br_fdb.c:109
> br_fdb_find+0x20c/0x220 net/bridge/br_fdb.c:109
> Kernel panic - not syncing: panic_on_warn set ...
>
> CPU: 1 PID: 6203 Comm: syz-executor0 Not tainted 4.10.0+ #54
> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
> Call Trace:
>  __dump_stack lib/dump_stack.c:15 [inline]
>  dump_stack+0x292/0x398 lib/dump_stack.c:51
>  panic+0x1cb/0x3a9 kernel/panic.c:179
>  __warn+0x1c4/0x1e0 kernel/panic.c:540
>  warn_slowpath_null+0x2c/0x40 kernel/panic.c:583
>  br_fdb_find+0x20c/0x220 net/bridge/br_fdb.c:109
>  fdb_insert+0xf7/0x300 net/bridge/br_fdb.c:529
>  br_fdb_insert+0x3a/0x60 net/bridge/br_fdb.c:557
>  __vlan_add+0x1621/0x3670 net/bridge/br_vlan.c:250
>  br_vlan_add+0x9e1/0xf30 net/bridge/br_vlan.c:599
>  br_vlan_init+0x241/0x320 net/bridge/br_vlan.c:940
>  br_dev_init+0xe2/0x220 net/bridge/br_device.c:106
>  register_netdevice+0x2f1/0xee0 net/core/dev.c:7137
>  register_netdev+0x1a/0x30 net/core/dev.c:7313
>  br_add_bridge+0x97/0xd0 net/bridge/br_if.c:393
>  br_ioctl_deviceless_stub+0x800/0xa40 net/bridge/br_ioctl.c:378
>  sock_ioctl+0x256/0x440 net/socket.c:960
>  vfs_ioctl fs/ioctl.c:43 [inline]
>  do_vfs_ioctl+0x1bf/0x1780 fs/ioctl.c:683
>  SYSC_ioctl fs/ioctl.c:698 [inline]
>  SyS_ioctl+0x8f/0xc0 fs/ioctl.c:689
>  entry_SYSCALL_64_fastpath+0x1f/0xc2
> RIP: 0033:0x4458b9
> RSP: 002b:00007f4afad8fb58 EFLAGS: 00000286 ORIG_RAX: 0000000000000010
> RAX: ffffffffffffffda RBX: 0000000000000005 RCX: 00000000004458b9
> RDX: 0000000020000000 RSI: 01400000000089a0 RDI: 0000000000000005
> RBP: 00000000006e0be0 R08: 0000000000000000 R09: 0000000000000000
> R10: 0000000000000000 R11: 0000000000000286 R12: 0000000000708000
> R13: 0000000000000010 R14: 0000000000080003 R15: 0000000000000000
> Dumping ftrace buffer:
>    (ftrace buffer empty)
> Kernel Offset: disabled
> Rebooting in 86400 seconds..

+syzkaller@googlegroups.com
