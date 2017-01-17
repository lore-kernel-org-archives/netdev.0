From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next v4 1/2] net sched actions: Add support for user
 cookies
Date: Tue, 17 Jan 2017 17:57:58 +0100
Message-ID: <587E4D16.8030708@iogearbox.net>
References: <1484651509-27500-1-git-send-email-jhs@emojatatu.com> <1484651509-27500-2-git-send-email-jhs@emojatatu.com> <587E2747.9000207@iogearbox.net> <bead2dc5-87a2-2fca-d50d-871f28be1d5b@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@mellanox.com, paulb@mellanox.com,
        john.fastabend@gmail.com, simon.horman@netronome.com,
        mrv@mojatatu.com, hadarh@mellanox.com, ogerlitz@mellanox.com,
        roid@mellanox.com, xiyou.wangcong@gmail.com
To: Jamal Hadi Salim <jhs@mojatatu.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:39988 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750741AbdAQQ6r (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2017 11:58:47 -0500
In-Reply-To: <bead2dc5-87a2-2fca-d50d-871f28be1d5b@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/17/2017 05:50 PM, Jamal Hadi Salim wrote:
> On 17-01-17 09:16 AM, Daniel Borkmann wrote:
>> On 01/17/2017 12:11 PM, Jamal Hadi Salim wrote:
>>> From: Jamal Hadi Salim <jhs@mojatatu.com>
>>>
>>> Introduce optional 128-bit action cookie.
>>> Like all other cookie schemes in the networking world (eg in protocols
>>> like http or existing kernel fib protocol field, etc) the idea is to save
>>> user state that when retrieved serves as a correlator. The kernel
>>> _should not_ intepret it.  The user can store whatever they wish in the
>>> 128 bits.
>> [...]
>>
>> Since it looks like you need a v5 anyway, few comments below.
>>
>>>   include/net/act_api.h        |  1 +
>>>   include/net/pkt_cls.h        |  8 ++++++++
>>>   include/uapi/linux/pkt_cls.h |  3 +++
>>>   net/sched/act_api.c          | 25 +++++++++++++++++++++++++
>>>   4 files changed, 37 insertions(+)
>>>
>>> diff --git a/include/net/act_api.h b/include/net/act_api.h
>>> index 1d71644..0692458 100644
>>> --- a/include/net/act_api.h
>>> +++ b/include/net/act_api.h
>>> @@ -41,6 +41,7 @@ struct tc_action {
>>>       struct rcu_head            tcfa_rcu;
>>>       struct gnet_stats_basic_cpu __percpu *cpu_bstats;
>>>       struct gnet_stats_queue __percpu *cpu_qstats;
>>> +    struct tc_cookie    *act_ck;
>>
>> Since we know anyway that this is part of struct tc_action, can't
>> you just give this some real/readable name like ...
>>
>>   struct tc_cookie cookie;
>
> Grep-ability.
> I was worried about when the classifier adds its cookie it
> would need to use something like cls_cookie etc.

Given this cookie is just used for correlation in user space anyway
and not processed any further by the kernel, I think we can well
handle these very few spots, so would be better if the code is more
maintainable instead.

Thanks,
Daniel
