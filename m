From: Hadar Hen Zion <hadarh@dev.mellanox.co.il>
Subject: Re: [PATCH net-next V4 4/4] net/sched: Introduce act_tunnel_key
Date: Thu, 1 Sep 2016 16:46:27 +0300
Message-ID: <CAJL1qvFm4SH2wg2ASbdqjVE2Ju5V-coCZ0G0Vr75X1=X4AyZgA@mail.gmail.com>
References: <1472647584-6713-1-git-send-email-hadarh@mellanox.com>
 <1472647584-6713-5-git-send-email-hadarh@mellanox.com> <CANn89i+ZnnJrLeSXadgDxWWT6q1Y+gPVoK8EJ417AzNfFKLQ+A@mail.gmail.com>
 <CAJL1qvE7Tpv0vmg6yRz7+Xh2T3rpqUvHshazK-N_6w2P-iv1hw@mail.gmail.com> <1472735786.5019.26.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <edumazet@google.com>,
        Hadar Hen Zion <hadarh@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>, Jiri Pirko <jiri@mellanox.com>,
        Jiri Benc <jbenc@redhat.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Shmulik Ladkani <shmulik.ladkani@gmail.com>,
        Tom Herbert <tom@herbertland.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Amir Vadai <amirva@mellanox.com>, Amir Vadai <amir@vadai.me>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f68.google.com ([209.85.218.68]:35843 "EHLO
        mail-oi0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755034AbcIAOAk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Sep 2016 10:00:40 -0400
Received: by mail-oi0-f68.google.com with SMTP id b22so7889996oii.3
        for <netdev@vger.kernel.org>; Thu, 01 Sep 2016 07:00:39 -0700 (PDT)
In-Reply-To: <1472735786.5019.26.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 1, 2016 at 4:16 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Thu, 2016-09-01 at 12:28 +0300, Hadar Hen Zion wrote:
>
>>
>> As you suggested above, I can do it by adding "int action" to struct
>> tcf_tunnel_key_paramse.
>> But, it means that act_tunnel_key would have a different behavior than
>> all the other actions and even though
>> "struct tc_action" has a designated parameters to store this action we
>> won't use it.
>> So it won't be completely clean...
>>
>> Do you think we have a cleaner way to protect it?
>
> Fact that the act_ modules had a spinlock made them all share the same
> structure.
>
> Now we want RCU protection, here is the thing.
>
> Say you want to access 3 different fields, A, B and C.
>
> If you put A and B in the rcu protected pointer, but leave C in the
> 'control part, protected by spinlock'
>
> Then your fast path wont be able to have a consistent view of 3
> variables A, B C.
>
> It might read an old value of A & B, and the recently updated C,
>
> Or it might read an old C, and the updated values of A & B

Yes, agree.

I'll add 'action' to struct tcf_tunnel_key_params.

Thanks,
Hadar


>
> As Cong very kindly pointed to us/me, if we want to be 'clean', we want
> to make sure we read a consistent 3-tuple.
>
> I will send updates when I have time to act_mirred.c
>
>
