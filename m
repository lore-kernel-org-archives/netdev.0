From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: net: heap out-of-bounds in
 fib6_clean_node/rt6_fill_node/fib6_age/fib6_prune_clone
Date: Tue, 25 Apr 2017 09:57:27 -0600
Message-ID: <01689f75-6713-a371-1dd7-8446ad2bfba7@cumulusnetworks.com>
References: <CACT4Y+YrA45diWz_8f4St8oX6aTC1kuGXMUvniGRbqXSGwawZQ@mail.gmail.com>
 <f707c195-251f-6058-5f4c-d55710533b11@cumulusnetworks.com>
 <CACT4Y+YCPxKkaZBfAabxtAV71R0ghLT-vUKVewJpm9wb2GXaEQ@mail.gmail.com>
 <1488658514.9415.356.camel@edumazet-glaptop3.roam.corp.google.com>
 <4e4d7d51-82de-b21e-cb5d-d804f7b88999@cumulusnetworks.com>
 <CACT4Y+Z1MvKbb35-jhaY=jEoR+t2u2TiUpkCR_oG3=VNmKjqvQ@mail.gmail.com>
 <14c01aea-6c2f-6ba5-6aee-52c55f410da7@cumulusnetworks.com>
 <CACT4Y+aomj0W8M9JNr1GLsT8EFFHV9YsOTYzWkvwKZANE9hiBQ@mail.gmail.com>
 <CACT4Y+aDzAYs9mbNGeFEkYSB2wTwomZTGEKn4hDH0PAb4uiLqw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        Mahesh Bandewar <maheshb@google.com>,
        Eric Dumazet <edumazet@google.com>,
        David Miller <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Dmitry Vyukov <dvyukov@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CACT4Y+aDzAYs9mbNGeFEkYSB2wTwomZTGEKn4hDH0PAb4uiLqw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 3/7/17 2:21 AM, Dmitry Vyukov wrote:
> ------------[ cut here ]------------
> WARNING: CPU: 2 PID: 3990 at net/ipv6/ip6_fib.c:991
> fib6_add+0x2e12/0x3290 net/ipv6/ip6_fib.c:991 net/ipv6/ip6_fib.c:991
> Kernel panic - not syncing: panic_on_warn set ...
> 
> CPU: 2 PID: 3990 Comm: kworker/2:4 Not tainted 4.11.0-rc1+ #311
> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
> Workqueue: ipv6_addrconf addrconf_dad_work
> Call Trace:
>  __dump_stack lib/dump_stack.c:16 [inline]
>  __dump_stack lib/dump_stack.c:16 [inline] lib/dump_stack.c:52
>  dump_stack+0x2fb/0x3fd lib/dump_stack.c:52 lib/dump_stack.c:52
>  panic+0x20f/0x426 kernel/panic.c:180 kernel/panic.c:180
>  __warn+0x1c4/0x1e0 kernel/panic.c:541 kernel/panic.c:541
>  warn_slowpath_null+0x2c/0x40 kernel/panic.c:584 kernel/panic.c:584
>  fib6_add+0x2e12/0x3290 net/ipv6/ip6_fib.c:991 net/ipv6/ip6_fib.c:991
>  __ip6_ins_rt+0x60/0x80 net/ipv6/route.c:948 net/ipv6/route.c:948
>  ip6_ins_rt+0x19b/0x220 net/ipv6/route.c:959 net/ipv6/route.c:959
>  __ipv6_ifa_notify+0x62e/0x7a0 net/ipv6/addrconf.c:5485 net/ipv6/addrconf.c:5485
>  ipv6_ifa_notify+0xdf/0x1d0 net/ipv6/addrconf.c:5518 net/ipv6/addrconf.c:5518
>  addrconf_dad_completed+0xe6/0x950 net/ipv6/addrconf.c:3983
> net/ipv6/addrconf.c:3983
>  addrconf_dad_begin net/ipv6/addrconf.c:3797 [inline]

Similarly for this one.
