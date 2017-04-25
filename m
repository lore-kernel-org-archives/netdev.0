From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: net: heap out-of-bounds in
 fib6_clean_node/rt6_fill_node/fib6_age/fib6_prune_clone
Date: Tue, 25 Apr 2017 09:56:33 -0600
Message-ID: <381a3e2d-dbf8-5e26-e6b2-4dc291d49dbe@cumulusnetworks.com>
References: <CACT4Y+YrA45diWz_8f4St8oX6aTC1kuGXMUvniGRbqXSGwawZQ@mail.gmail.com>
 <f707c195-251f-6058-5f4c-d55710533b11@cumulusnetworks.com>
 <CACT4Y+YCPxKkaZBfAabxtAV71R0ghLT-vUKVewJpm9wb2GXaEQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Mahesh Bandewar <maheshb@google.com>,
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
In-Reply-To: <CACT4Y+YCPxKkaZBfAabxtAV71R0ghLT-vUKVewJpm9wb2GXaEQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 3/4/17 11:57 AM, Dmitry Vyukov wrote:
> ==================================================================
> BUG: KASAN: slab-out-of-bounds in rt6_dump_route+0x293/0x2f0
> net/ipv6/route.c:3551 at addr ffff88007e523694
> Read of size 4 by task syz-executor3/24426
> CPU: 2 PID: 24426 Comm: syz-executor3 Not tainted 4.10.0+ #293
> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
> Call Trace:
>  __dump_stack lib/dump_stack.c:16 [inline]
>  dump_stack+0x2fb/0x3fd lib/dump_stack.c:52
>  kasan_object_err+0x1c/0x90 mm/kasan/report.c:166
>  print_address_description mm/kasan/report.c:208 [inline]
>  kasan_report_error mm/kasan/report.c:292 [inline]
>  kasan_report.part.2+0x1b0/0x460 mm/kasan/report.c:314
>  kasan_report mm/kasan/report.c:334 [inline]
>  __asan_report_load4_noabort+0x29/0x30 mm/kasan/report.c:334
>  rt6_dump_route+0x293/0x2f0 net/ipv6/route.c:3551
>  fib6_dump_node+0x101/0x1a0 net/ipv6/ip6_fib.c:315
>  fib6_walk_continue+0x4b3/0x620 net/ipv6/ip6_fib.c:1576
>  fib6_walk+0x91/0xf0 net/ipv6/ip6_fib.c:1621
>  fib6_dump_table net/ipv6/ip6_fib.c:374 [inline]
>  inet6_dump_fib+0x832/0xea0 net/ipv6/ip6_fib.c:447

My expectation is that this one is fixed with the ipv6 patch I have sent
(not yet committed). Are you seeing this backtrace with that patch?
