From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: net: memory leak in mkiss_open
Date: Tue, 23 Feb 2016 22:56:02 -0800
Message-ID: <CAM_iQpXawteUbi3tzKoo+d8sDx4XAbxz6wROpUrHmb1aXfNffA@mail.gmail.com>
References: <CACT4Y+bkpz+iPpv_LMrAG+ap+qQYtyTX7mO_M_eGHFYh28J=2g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Jiri Slaby <jslaby@suse.com>, ralf@linux-mips.org,
	Jeff Garzik <jgarzik@pobox.com>,
	syzkaller <syzkaller@googlegroups.com>,
	Kostya Serebryany <kcc@google.com>,
	Alexander Potapenko <glider@google.com>,
	Sasha Levin <sasha.levin@oracle.com>
To: Dmitry Vyukov <dvyukov@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CACT4Y+bkpz+iPpv_LMrAG+ap+qQYtyTX7mO_M_eGHFYh28J=2g@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 22, 2016 at 2:05 AM, Dmitry Vyukov <dvyukov@google.com> wrote:
> unreferenced object 0xffff8800628991d8 (size 4096):
>   comm "a.out", pid 7081, jiffies 4294920662 (age 35.917s)
>   hex dump (first 32 bytes):
>     00 00 00 00 00 00 00 00 61 78 30 00 00 00 00 00  ........ax0.....
>     00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
>   backtrace:
>     [<ffffffff86680923>] kmemleak_alloc+0x63/0xa0 mm/kmemleak.c:916
>     [<     inline     >] kmemleak_alloc_recursive include/linux/kmemleak.h:47
>     [<     inline     >] slab_post_alloc_hook mm/slub.c:1337
>     [<     inline     >] slab_alloc_node mm/slub.c:2596
>     [<     inline     >] slab_alloc mm/slub.c:2604
>     [<ffffffff8176b585>] __kmalloc+0x1c5/0x3a0 mm/slub.c:3564
>     [<     inline     >] kmalloc include/linux/slab.h:468
>     [<ffffffff8554c93e>] kzalloc+0x1e/0x30 include/linux/slab.h:607
>     [<ffffffff85551442>] alloc_netdev_mqs+0x82/0xd20 net/core/dev.c:7387
>     [<ffffffff83ef39da>] mkiss_open+0xaa/0xc30 drivers/net/hamradio/mkiss.c:707
>     [<ffffffff82fbd258>] tty_ldisc_open.isra.2+0x78/0xd0
> drivers/tty/tty_ldisc.c:454
>     [<ffffffff82fbd842>] tty_set_ldisc+0x292/0x8a0 drivers/tty/tty_ldisc.c:561
>     [<     inline     >] tiocsetd drivers/tty/tty_io.c:2655
>     [<ffffffff82fa651e>] tty_ioctl+0xb2e/0x2160 drivers/tty/tty_io.c:2910
>     [<     inline     >] vfs_ioctl fs/ioctl.c:43
>     [<ffffffff8180597c>] do_vfs_ioctl+0x18c/0xfb0 fs/ioctl.c:674
>     [<     inline     >] SYSC_ioctl fs/ioctl.c:689
>     [<ffffffff8180682f>] SyS_ioctl+0x8f/0xc0 fs/ioctl.c:680
>     [<ffffffff8669ddb6>] entry_SYSCALL_64_fastpath+0x16/0x7a
> arch/x86/entry/entry_64.S:185
>     [<ffffffffffffffff>] 0xffffffffffffffff
> unreferenced object 0xffff8800652b1aa0 (size 96):
>   comm "a.out", pid 7081, jiffies 4294920662 (age 35.917s)
>   hex dump (first 32 bytes):
>     b8 94 89 62 00 88 ff ff b8 94 89 62 00 88 ff ff  ...b.......b....
>     98 92 9c aa b0 40 02 00 00 00 00 00 00 00 00 00  .....@..........
>   backtrace:
>     [<ffffffff86680923>] kmemleak_alloc+0x63/0xa0 mm/kmemleak.c:916
>     [<     inline     >] kmemleak_alloc_recursive include/linux/kmemleak.h:47
>     [<     inline     >] slab_post_alloc_hook mm/slub.c:1337
>     [<     inline     >] slab_alloc_node mm/slub.c:2596
>     [<     inline     >] slab_alloc mm/slub.c:2604
>     [<ffffffff8176ae6e>] kmem_cache_alloc_trace+0x1ee/0x350 mm/slub.c:2621
>     [<     inline     >] kmalloc include/linux/slab.h:463
>     [<ffffffff8557a4e2>] __hw_addr_create_ex+0x62/0x240
> net/core/dev_addr_lists.c:34
>     [<ffffffff8557a7bc>] __hw_addr_add_ex+0xfc/0x270
> net/core/dev_addr_lists.c:80
>     [<     inline     >] __hw_addr_add net/core/dev_addr_lists.c:88
>     [<ffffffff8557ac35>] dev_addr_init+0x105/0x1c0 net/core/dev_addr_lists.c:371
>     [<ffffffff855514f0>] alloc_netdev_mqs+0x130/0xd20 net/core/dev.c:7400
>     [<ffffffff83ef39da>] mkiss_open+0xaa/0xc30 drivers/net/hamradio/mkiss.c:707
>     [<ffffffff82fbd258>] tty_ldisc_open.isra.2+0x78/0xd0
> drivers/tty/tty_ldisc.c:454
>     [<ffffffff82fbd842>] tty_set_ldisc+0x292/0x8a0 drivers/tty/tty_ldisc.c:561
>     [<     inline     >] tiocsetd drivers/tty/tty_io.c:2655
>     [<ffffffff82fa651e>] tty_ioctl+0xb2e/0x2160 drivers/tty/tty_io.c:2910
>     [<     inline     >] vfs_ioctl fs/ioctl.c:43
>     [<ffffffff8180597c>] do_vfs_ioctl+0x18c/0xfb0 fs/ioctl.c:674
>     [<     inline     >] SYSC_ioctl fs/ioctl.c:689
>     [<ffffffff8180682f>] SyS_ioctl+0x8f/0xc0 fs/ioctl.c:680
>     [<ffffffff8669ddb6>] entry_SYSCALL_64_fastpath+0x16/0x7a
> arch/x86/entry/entry_64.S:185

This looks more like a tty layer leak than netdev layer.
