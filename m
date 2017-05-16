From: Andrey Konovalov <andreyknvl@google.com>
Subject: Re: drivers/net/hamradio: divide error in hdlcdrv_ioctl
Date: Tue, 16 May 2017 17:05:59 +0200
Message-ID: <CAAeHK+zzyZkWWhWcmacLOJ70AZd8tXf0hEhyX8LZX-s1+Op7HQ@mail.gmail.com>
References: <CAAeHK+ya2sAtLmJ0VyP6e=13OXUw98dp1WdRFU=o5+xGFGPtbQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: syzkaller <syzkaller@googlegroups.com>,
        Dmitry Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>
To: "David S. Miller" <davem@davemloft.net>,
        Alan Cox <alan@linux.intel.com>,
        Thomas Osterried <thomas@osterried.de>,
        Javier Martinez Canillas <javier@osg.samsung.com>,
        David Howells <dhowells@redhat.com>,
        Geliang Tang <geliangtang@gmail.com>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAAeHK+ya2sAtLmJ0VyP6e=13OXUw98dp1WdRFU=o5+xGFGPtbQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 16, 2017 at 5:05 PM, Andrey Konovalov <andreyknvl@google.com> wrote:
> Hi,
>
> I've got the following error report while fuzzing the kernel with syzkaller.
>
> On commit 2ea659a9ef488125eb46da6eb571de5eae5c43f6 (4.12-rc1).
>
> A reproducer and .config are attached.

+syzkaller

>
> divide error: 0000 [#1] SMP KASAN
> Modules linked in:
> CPU: 1 PID: 4019 Comm: a.out Not tainted 4.12.0-rc1+ #363
> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
> task: ffff88006b97c200 task.stack: ffff880062098000
> RIP: 0010:hdlcdrv_ioctl+0x8a3/0x1a50 drivers/net/hamradio/hdlcdrv.c:579
> RSP: 0018:ffff88006209f898 EFLAGS: 00010246
> RAX: 000000007fffffff RBX: ffff88006209f8d0 RCX: 0000000000000000
> RDX: 0000000000000000 RSI: 0000000000000000 RDI: ffff88006888abd0
> RBP: ffff88006209f9b8 R08: 1ffff1000c413e8a R09: 1ffff1000c413e6a
> R10: ffff88006b97c200 R11: 0000000000000001 R12: 1ffff1000c413f16
> R13: ffff88006888a100 R14: 0000000000000000 R15: 00000000005b78f4
> FS:  00007fb533884700(0000) GS:ffff88006cb00000(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> CR2: 000000002026b000 CR3: 0000000065576000 CR4: 00000000000006e0
> Call Trace:
>  dev_ifsioc+0x53f/0x9f0 net/core/dev_ioctl.c:338
>  dev_ioctl+0xc3c/0x1160 net/core/dev_ioctl.c:555
>  sock_ioctl+0x169/0x440 net/socket.c:944
>  vfs_ioctl fs/ioctl.c:45
>  do_vfs_ioctl+0x1bf/0x1660 fs/ioctl.c:685
>  SYSC_ioctl fs/ioctl.c:700
>  SyS_ioctl+0x8f/0xc0 fs/ioctl.c:691
>  entry_SYSCALL_64_fastpath+0x1f/0xbe arch/x86/entry/entry_64.S:204
> RIP: 0033:0x7fb532f96b79
> RSP: 002b:00007fffac2839f8 EFLAGS: 00000206 ORIG_RAX: 0000000000000010
> RAX: ffffffffffffffda RBX: 00007fffac283b60 RCX: 00007fb532f96b79
> RDX: 00000000208f1fd8 RSI: 00000100000089f0 RDI: 0000000000000003
> RBP: 00000000004004e0 R08: 0000000000000000 R09: 0000000000000000
> R10: 0000000000000000 R11: 0000000000000206 R12: 0000000000000000
> R13: 00007fffac283b60 R14: 0000000000000000 R15: 0000000000000000
> Code: 45 8b be 48 ff ff ff 48 89 fa 48 c1 ea 03 0f b6 04 02 84 c0 74
> 08 3c 03 0f 8e 8b 0e 00 00 45 8b b5 d0 0a 00 00 b8 ff ff ff 7f 99 <41>
> f7 fe 41 39 c7 0f 87 89 0c 00 00 e8 ac e5 7e fe 49 8d bd d8
> RIP: hdlcdrv_ioctl+0x8a3/0x1a50 RSP: ffff88006209f898
> ---[ end trace 204af21e5cc80963 ]---
> qemu: terminating on signal 15 from pid 141905
