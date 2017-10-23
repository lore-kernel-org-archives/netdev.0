From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net 00/15] net_sched: remove RCU callbacks from TC
Date: Mon, 23 Oct 2017 16:23:28 -0700
Message-ID: <CAM_iQpUXr-3rAkBiVFvZ5YSRG=ZrPEWzQwQYZ0Yx_YP_BQNGoA@mail.gmail.com>
References: <20171023220304.2268-1-xiyou.wangcong@gmail.com> <1508800599.30291.106.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        John Fastabend <john.fastabend@gmail.com>,
        Chris Mi <chrism@mellanox.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:56685 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751116AbdJWXXt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Oct 2017 19:23:49 -0400
Received: by mail-pf0-f193.google.com with SMTP id b85so18225334pfj.13
        for <netdev@vger.kernel.org>; Mon, 23 Oct 2017 16:23:48 -0700 (PDT)
In-Reply-To: <1508800599.30291.106.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 23, 2017 at 4:16 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Mon, 2017-10-23 at 15:02 -0700, Cong Wang wrote:
>
>> b) As suggested by Paul, we could defer the work to a workqueue and
>> gain the permission of holding RTNL again without any performance
>> impact, however, this seems impossible too, because as lockdep
>> complains we have a deadlock when flushing workqueue while hodling
>> RTNL lock, see the rcu_barrier() in tcf_block_put().
>>
>> Therefore, the simplest solution we have is probably just getting
>> rid of these RCU callbacks, because they are not necessary at all,
>> callers of these call_rcu() are all on slow paths and have RTNL
>> lock, so blocking is allowed in their contexts.
>
> I am against these pessimistic changes, sorry for not following past
> discussions last week.

So even Cc'ing you doesn't work. :-D

>
> I am asking a talk during upcoming netdev/netconf about this, if we need
> to take a decision.

I won't be able to make it.

>
> RTNL is already a big problem for many of us, adding synchronize_rcu()
> calls while holding RTNL is a no - go, unless we have clear evidence it
> can not be avoided.

You omitted too much, including the evidence I provide. In short it is very
hard to do, otherwise I should have already done it. I am very open to
any simple solution to avoid it, but so far none...

Saying no but without giving a possible solution does not help anything
here.
