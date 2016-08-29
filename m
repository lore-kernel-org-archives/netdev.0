From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net-next V3 4/4] net/sched: Introduce act_tunnel_key
Date: Sun, 28 Aug 2016 22:04:21 -0700
Message-ID: <CAM_iQpV=iCa_nyNRaTE=qkZvw+44mzN8sY01su0pLi2yqqpVmA@mail.gmail.com>
References: <1472141627-27339-1-git-send-email-hadarh@mellanox.com>
 <1472141627-27339-5-git-send-email-hadarh@mellanox.com> <1472147334.14381.149.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAM_iQpXvS5KQ-3AaPjtHHRrexr48tTMSXpuJPFkOsz6caJP5EA@mail.gmail.com> <1472238975.14381.192.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Hadar Hen Zion <hadarh@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Jiri Pirko <jiri@mellanox.com>, Jiri Benc <jbenc@redhat.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Shmulik Ladkani <shmulik.ladkani@gmail.com>,
        Tom Herbert <tom@herbertland.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Amir Vadai <amirva@mellanox.com>, Amir Vadai <amir@vadai.me>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:36052 "EHLO
        mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750909AbcH2FEp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 29 Aug 2016 01:04:45 -0400
Received: by mail-wm0-f48.google.com with SMTP id q128so62567625wma.1
        for <netdev@vger.kernel.org>; Sun, 28 Aug 2016 22:04:43 -0700 (PDT)
In-Reply-To: <1472238975.14381.192.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 26, 2016 at 12:16 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Fri, 2016-08-26 at 11:26 -0700, Cong Wang wrote:
>> 1) Currently there are only a few actions using lockless, and they are
>> questionable, as we already discussed before, there could be some
>> race condition when you modify an existing action.
>
> There is no fundamental issue with a race condition.

For mirred action, maybe. As we already discussed, the more
complex an action is, the harder to make it lockless in your
way (that is, not using RCU)

>
> Sure, there are races, but they have no serious effect.
>
> Feel free to send a fix if you really have time to spare.

It's because the code is written by you?

I am surprised how you try to hide your own problem in
such a way...


>
>>
>> 2) We need to change the tc action API in order to fully support RCU,
>> which is what I have been working on these days. I should come up
>> with something next Monday (if not this weekend).
>>
>> So for this patchset, using spinlock is fine, just as many other actions.
>> I will take care of it later.
>
> This is _not_ fine.


OK, so where are your patches to make the rest actions
lockless?


>
> We are in 2016, not in 1995 anymore.
>

Fair enough, sounds like all actions are already lockless in
fast path now in 2016, you know this is not true...


> We are not adding a spinlock in a hot path unless absolutely needed.

If it is bug-free, yes, I am totally with you. I care about corretness
more than any performance.


>
> With multi queue NIC, this spinlock is going to hurt performance so much
> that this action wont be used by any serious user.

We have used mirred action even before you make it lockless.


>
> Here, it is absolutely trivial to use RCU and/or percpu counters.

Sounds like we don't need any API change, why not go ahead
and try it? Please do teach me how to modify an existing
action in a lockless way without changing any API (and of course
needs to be bug-free), I am very happy to learn your "trivial" way
to fix this, since I don't have any trivial fix.

Please, stop bullsh*t, show me your trivial code.
