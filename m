From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: net: suspicious RCU usage in nf_hook
Date: Fri, 27 Jan 2017 15:30:50 -0800
Message-ID: <CAM_iQpU9Tc6vwZ46wKcmH8FMRyYesY9qXM0kDY-OhgWbO-TtpQ@mail.gmail.com>
References: <CACT4Y+bpmwj1WH7g6inQBm+7PvHepv9tTmYBUqkJYFvquGDYCQ@mail.gmail.com>
 <CAM_iQpXNwZbkF+zoR5qdREcK6ZFt3ODbrpRB38WidLkcUWt5dw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Eric Dumazet <edumazet@google.com>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        netfilter-devel@vger.kernel.org,
        syzkaller <syzkaller@googlegroups.com>
To: Dmitry Vyukov <dvyukov@google.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <CAM_iQpXNwZbkF+zoR5qdREcK6ZFt3ODbrpRB38WidLkcUWt5dw@mail.gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 27, 2017 at 3:22 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> On Fri, Jan 27, 2017 at 1:15 PM, Dmitry Vyukov <dvyukov@google.com> wrote:
>> stack backtrace:
>> CPU: 2 PID: 23111 Comm: syz-executor14 Not tainted 4.10.0-rc5+ #192
>> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
>> Call Trace:
>>  __dump_stack lib/dump_stack.c:15 [inline]
>>  dump_stack+0x2ee/0x3ef lib/dump_stack.c:51
>>  lockdep_rcu_suspicious+0x139/0x180 kernel/locking/lockdep.c:4452
>>  rcu_preempt_sleep_check include/linux/rcupdate.h:560 [inline]
>>  ___might_sleep+0x560/0x650 kernel/sched/core.c:7748
>>  __might_sleep+0x95/0x1a0 kernel/sched/core.c:7739
>>  mutex_lock_nested+0x24f/0x1730 kernel/locking/mutex.c:752
>>  atomic_dec_and_mutex_lock+0x119/0x160 kernel/locking/mutex.c:1060
>>  __static_key_slow_dec+0x7a/0x1e0 kernel/jump_label.c:149
>>  static_key_slow_dec+0x51/0x90 kernel/jump_label.c:174
>>  net_disable_timestamp+0x3b/0x50 net/core/dev.c:1728
>>  sock_disable_timestamp+0x98/0xc0 net/core/sock.c:403
>>  __sk_destruct+0x27d/0x6b0 net/core/sock.c:1441
>>  sk_destruct+0x47/0x80 net/core/sock.c:1460
>
> jump label uses a mutex and we call jump label API in softIRQ context...
> Maybe we have to move it to a work struct as what we did for netlink.

Correct myself: process context but with RCU read lock held...
