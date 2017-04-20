From: Andrey Konovalov <andreyknvl@google.com>
Subject: Re: net: heap out-of-bounds in fib6_clean_node/rt6_fill_node/fib6_age/fib6_prune_clone
Date: Thu, 20 Apr 2017 17:29:20 +0200
Message-ID: <CAAeHK+zX2-eYuHscTKtP059H5tbX25t=hstGkCNtRvmcS1KDoQ@mail.gmail.com>
References: <CACT4Y+YrA45diWz_8f4St8oX6aTC1kuGXMUvniGRbqXSGwawZQ@mail.gmail.com>
 <CACT4Y+YpUZ+7f5bzPh1hATwUXaZaPTu4rYYdz0RY1MHA1WG3SA@mail.gmail.com>
 <328b1fa7-2d97-6ae3-3b87-e33a0d564ad9@cumulusnetworks.com>
 <CACT4Y+aQFe+M=ESuShQ4FYNWAd8CNEQ=0rW+aAB0P-tp=PpFyQ@mail.gmail.com>
 <CACT4Y+aQgM=9QMkyfcXF2B5gGidvL07JP_m_inNXTPXU22i=aA@mail.gmail.com>
 <CACT4Y+Yx1cgWCkC2c7bze1V1VaecgBfioMvKS2-FUeaRr4DGXg@mail.gmail.com>
 <CACT4Y+bcMz13ad2kLaZGvct5sQ+RDki0StnOEbz3exAa8=zxqQ@mail.gmail.com>
 <CACT4Y+Z6f4aOxMZW44WXdYEyDJbGBYLnjKsHBXfK800h+EkrxA@mail.gmail.com>
 <2270c1ca-9481-60c1-9c29-87669223bded@cumulusnetworks.com>
 <CACT4Y+aUROZgAczRfntp5Rgvzcypviz5ZWBPdE6MWSiO0-3jEg@mail.gmail.com>
 <CAAeHK+zx6W_yxnoEQ2Pc1AT4uLXqYZaoi5oQBeuCntdGS38TQg@mail.gmail.com>
 <580392d8-fa33-67bb-c5d6-27d262f1646a@cumulusnetworks.com>
 <CAAeHK+zZb=K4X9=NmSWQJL8bpgMbXoG+h4RasAyYDr+C5pkVYA@mail.gmail.com>
 <CAM_iQpXyDN5GD+QLmWgJSc0bqV0ViK5LxSdwAV3XsHWr6vLJ2Q@mail.gmail.com>
 <1dad955e-28c1-3f02-8876-90cce4a7d1f8@cumulusnetworks.com>
 <CACT4Y+amFHj1DV3pmj+eJVxg52+GLdE-fEin5M86dOKubea7DQ@mail.gmail.com>
 <CAAeHK+zWO1COcZDp9q4eHP9YN9Qv8CXLOJu8dJgCbihcFSK3jg@mail.gmail.com> <CAAeHK+zSe82vc5gCRgr_EoUwiALPnWVdWJBPwJZBpbxYz=kGJw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Ahern <dsa@cumulusnetworks.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Mahesh Bandewar <maheshb@google.com>,
        Eric Dumazet <edumazet@google.com>,
        David Miller <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        syzkaller <syzkaller@googlegroups.com>
To: Dmitry Vyukov <dvyukov@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAAeHK+zSe82vc5gCRgr_EoUwiALPnWVdWJBPwJZBpbxYz=kGJw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 20, 2017 at 5:28 PM, Andrey Konovalov <andreyknvl@google.com> wrote:
> I've extracted a reproducer for another bug.

It works for me as is, but you might need to run it in a loop.

>
> This one seems to be much closer to what Dmitry reported intially.
>
> ------------[ cut here ]------------
> WARNING: CPU: 1 PID: 3892 at net/ipv6/ip6_fib.c:1472 fib6_del+0xa60/0xdc0
> Modules linked in:
> CPU: 1 PID: 3892 Comm: a.out Not tainted 4.11.0-rc7+ #251
> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
> Call Trace:
>  __dump_stack lib/dump_stack.c:16
>  dump_stack+0x292/0x398 lib/dump_stack.c:52
>  __warn+0x19f/0x1e0 kernel/panic.c:549
>  warn_slowpath_null+0x2c/0x40 kernel/panic.c:584
>  fib6_del+0xa60/0xdc0 net/ipv6/ip6_fib.c:1472
>  fib6_clean_node+0x3ce/0x550 net/ipv6/ip6_fib.c:1652
>  fib6_walk_continue+0x577/0x760 net/ipv6/ip6_fib.c:1578
>  fib6_walk+0x91/0xf0 net/ipv6/ip6_fib.c:1623
>  fib6_clean_tree+0x266/0x3c0 net/ipv6/ip6_fib.c:1695
>  __fib6_clean_all+0x1f7/0x3b0 net/ipv6/ip6_fib.c:1711
>  fib6_clean_all+0x27/0x30 net/ipv6/ip6_fib.c:1722
>  rt6_ifdown+0xf7/0x910 net/ipv6/route.c:2820
>  addrconf_ifdown+0x1a3/0x1aa0 net/ipv6/addrconf.c:3541
>  addrconf_notify+0x1bb/0x2570 net/ipv6/addrconf.c:3466
>  notifier_call_chain+0x145/0x2f0 kernel/notifier.c:93
>  __raw_notifier_call_chain kernel/notifier.c:394
>  raw_notifier_call_chain+0x2d/0x40 kernel/notifier.c:401
>  call_netdevice_notifiers_info+0x51/0x90 net/core/dev.c:1647
>  call_netdevice_notifiers net/core/dev.c:1663
>  __dev_notify_flags+0x1fd/0x320 net/core/dev.c:6499
>  dev_change_flags+0xf5/0x140 net/core/dev.c:6530
>  dev_ifsioc+0x62a/0x9f0 net/core/dev_ioctl.c:254
>  dev_ioctl+0x249/0x1160 net/core/dev_ioctl.c:532
>  sock_do_ioctl+0x94/0xb0 net/socket.c:913
>  sock_ioctl+0x28f/0x440 net/socket.c:1004
>  vfs_ioctl fs/ioctl.c:45
>  do_vfs_ioctl+0x1bf/0x1780 fs/ioctl.c:685
>  SYSC_ioctl fs/ioctl.c:700
>  SyS_ioctl+0x8f/0xc0 fs/ioctl.c:691
>  entry_SYSCALL_64_fastpath+0x1f/0xc2 arch/x86/entry/entry_64.S:204
> RIP: 0033:0x7f575ded4347
> RSP: 002b:00007fffc94d9948 EFLAGS: 00000217 ORIG_RAX: 0000000000000010
> RAX: ffffffffffffffda RBX: 00007fffc94d9b30 RCX: 00007f575ded4347
> RDX: 00007fffc94d9980 RSI: 0000000000008914 RDI: 0000000000000006
> RBP: 00000000004004e0 R08: 0000000000000028 R09: 0101010101010101
> R10: 0000000000000000 R11: 0000000000000217 R12: 0000000000000000
> R13: 00007fffc94d9b30 R14: 0000000000000000 R15: 0000000000000000
> ---[ end trace 9bda4459ad907043 ]---
