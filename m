From: Eric Dumazet <edumazet@google.com>
Subject: Re: net/ipv4: division by 0 in tcp_select_window
Date: Fri, 3 Mar 2017 10:37:36 -0800
Message-ID: <CANn89iJZOvy_40R0fQfsAxq2oZJHXO8xURRMf9RUT7rGHhZ11Q@mail.gmail.com>
References: <CACT4Y+Y+dL6EzkfDahjQUyyT4YMhDin7UPY5RQYbNH0n0DJ5xA@mail.gmail.com>
 <CACT4Y+Y8cDy2+WJ=d+RK7Z+DKAg5Tygszh8eR3Z48tvftBDmZg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
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
In-Reply-To: <CACT4Y+Y8cDy2+WJ=d+RK7Z+DKAg5Tygszh8eR3Z48tvftBDmZg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Mar 3, 2017 at 10:24 AM, Dmitry Vyukov <dvyukov@google.com> wrote:
> On Fri, Mar 3, 2017 at 7:10 PM, Dmitry Vyukov <dvyukov@google.com> wrote:
>> Hello,
>>

> Wonder if this has been causing other crashes like this one?
>
> ------------[ cut here ]------------
> kernel BUG at net/ipv4/tcp_output.c:2748!
> Call Trace:
>  <IRQ>
>  tcp_retransmit_skb+0x2e/0x230 net/ipv4/tcp_output.c:2822
>  tcp_retransmit_timer+0x104c/0x2d50 net/ipv4/tcp_timer.c:491
>  tcp_write_timer_handler+0x334/0x9d0 net/ipv4/tcp_timer.c:574
>  tcp_write_timer+0x164/0x180 net/ipv4/tcp_timer.c:592
>  call_timer_fn+0x241/0x820 kernel/time/timer.c:1266
>  expire_timers kernel/time/timer.c:1305 [inline]
>  __run_timers+0x960/0xcf0 kernel/time/timer.c:1599
>  run_timer_softirq+0x21/0x80 kernel/time/timer.c:1612
>  __do_softirq+0x31f/0xbe7 kernel/softirq.c:284
>  invoke_softirq kernel/softirq.c:364 [inline]
>  irq_exit+0x1cc/0x200 kernel/softirq.c:405
>  exiting_irq arch/x86/include/asm/apic.h:658 [inline]
>  smp_apic_timer_interrupt+0x76/0xa0 arch/x86/kernel/apic/apic.c:962
>  apic_timer_interrupt+0x93/0xa0 arch/x86/entry/entry_64.S:487
>
> if (before(TCP_SKB_CB(skb)->seq, tp->snd_una)) {
>   if (before(TCP_SKB_CB(skb)->end_seq, tp->snd_una))
>     BUG();

This path uses a socket lock. Probably different problem.
