From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next v6 1/1] net sched actions: Add support for user
 cookies
Date: Tue, 24 Jan 2017 06:46:48 -0500
Message-ID: <dc61a214-2825-7bec-890c-069795a182a0@mojatatu.com>
References: <1485116750-31198-1-git-send-email-jhs@emojatatu.com>
 <20170123125838.GD31958@penelope.horms.nl> <58862CE7.2080906@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, jiri@mellanox.com,
        paulb@mellanox.com, john.fastabend@gmail.com, mrv@mojatatu.com,
        hadarh@mellanox.com, ogerlitz@mellanox.com, roid@mellanox.com,
        xiyou.wangcong@gmail.com
To: Daniel Borkmann <daniel@iogearbox.net>,
        Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f193.google.com ([209.85.216.193]:36479 "EHLO
        mail-qt0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750763AbdAXLqv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2017 06:46:51 -0500
Received: by mail-qt0-f193.google.com with SMTP id l7so24538575qtd.3
        for <netdev@vger.kernel.org>; Tue, 24 Jan 2017 03:46:50 -0800 (PST)
In-Reply-To: <58862CE7.2080906@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-01-23 11:18 AM, Daniel Borkmann wrote:
> On 01/23/2017 01:58 PM, Simon Horman wrote:
>> Hi Jamal,
>>
>> On Sun, Jan 22, 2017 at 03:25:50PM -0500, Jamal Hadi Salim wrote:
>>
>> ...
>>
>>> diff --git a/net/sched/act_api.c b/net/sched/act_api.c
>>> index cd08df9..58cf1c5 100644
>>> --- a/net/sched/act_api.c
>>> +++ b/net/sched/act_api.c
>>> @@ -24,6 +24,7 @@
>>>   #include <net/net_namespace.h>
>>>   #include <net/sock.h>
>>>   #include <net/sch_generic.h>
>>> +#include <net/pkt_cls.h>
>>>   #include <net/act_api.h>
>>>   #include <net/netlink.h>
>>>
>>> @@ -33,6 +34,8 @@ static void free_tcf(struct rcu_head *head)
>>>
>>>       free_percpu(p->cpu_bstats);
>>>       free_percpu(p->cpu_qstats);
>>> +    kfree(p->act_cookie->data);
>>
>> Does the above need to be protected by a check for p->act_cookie being
>> non-NULL?
>
> Yep, that would be a NULL-deref. Why not just embedd tc_cookie as
> suggested earlier, the struct is rather small anyway ...
>


Everytime I make a change like that i seem to forget to run one
more test and it creates more bugs (example, the last two resends
are errors introduced by changing the struct from last one which
was your suggestion;->).
So you will have to forgive me I am not going back to that
definition; I will post version 7 soon.

cheers,
jamal
