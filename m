From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v11 3/4] net sched actions: dump more than
 TCA_ACT_MAX_PRIO actions per batch
Date: Tue, 25 Jul 2017 13:33:52 +0200
Message-ID: <20170725113352.GA3186@nanopsycho>
References: <1500860146-26970-1-git-send-email-jhs@emojatatu.com>
 <1500860146-26970-4-git-send-email-jhs@emojatatu.com>
 <20170724112750.GC1868@nanopsycho>
 <7057a692-7233-4632-4f66-2f57c98322ea@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        xiyou.wangcong@gmail.com, dsahern@gmail.com,
        eric.dumazet@gmail.com, mrv@mojatatu.com,
        simon.horman@netronome.com, alex.aring@gmail.com
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:38140 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750861AbdGYLdz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Jul 2017 07:33:55 -0400
Received: by mail-wr0-f194.google.com with SMTP id g32so2364009wrd.5
        for <netdev@vger.kernel.org>; Tue, 25 Jul 2017 04:33:55 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <7057a692-7233-4632-4f66-2f57c98322ea@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Jul 25, 2017 at 01:22:44PM CEST, jhs@mojatatu.com wrote:
>On 17-07-24 07:27 AM, Jiri Pirko wrote:
>> Mon, Jul 24, 2017 at 03:35:45AM CEST, jhs@mojatatu.com wrote:
>> > From: Jamal Hadi Salim <jhs@mojatatu.com>
>[..]
>> 
>> This helper should be part of the previous patch.
>> 
>
>Will do next update.
>> 
>
>>> @@ -1157,8 +1164,18 @@ static int tc_dump_action(struct sk_buff *skb,
>struct netlink_callback *cb)
>>> 	struct tc_action_ops *a_o;
>>> 	int ret = 0;
>>> 	struct tcamsg *t = (struct tcamsg *) nlmsg_data(cb->nlh);
>>> -	struct nlattr *kind = find_dump_kind(cb->nlh);
>>> +	struct nla_bitfield_32 fb;
>>> +	struct nlattr *count_attr = NULL;
>>> +	struct nlattr *tb[TCA_ROOT_MAX + 1];
>>> +	struct nlattr *kind = NULL;
>>
>> Reverse christmas tree :D
>>
>
>There were already 2 christmas trees in place;->
>I will re-arrange this.
>
>> > 
>> > +	if (tb[TCA_ROOT_FLAGS])
>> > +		fb = nla_get_bitfield_32(tb[TCA_ROOT_FLAGS]);
>> 
>> fb? bf? nbf? Please make this synced within the patchset.
>> 
>> 
>
>Ok, what do you like best? ;->

"bf"


>
>> Don't you need to mask value with selector? In fact, I think that
>> nla_get_bitfield_32 could just return u32 which would be (value&selector).
>> The validation takes care of unsupported bits.
>
>For my use case I dont need any of the above since I dont need to
>unset things. In other use cases you will need both selector and
>value in case someone wants a bit to be set to 0.
>Infact I think i will rename that helper to "nla_get_bitvalue_32"
>to be more precise.

The getter should contain name of the type, so "nla_get_bitfield32_val"
is much better.

What if I pass val 0x1 and selector 0x0 from userspace. I don't have the
bit selected, so you should not process it in kernel, no?


>
>cheers,
>jamal
