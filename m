From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next v11 3/4] net sched actions: dump more than
 TCA_ACT_MAX_PRIO actions per batch
Date: Tue, 25 Jul 2017 08:34:58 -0400
Message-ID: <355f2140-d8e8-8a4e-1f31-cbbcbfd6821b@mojatatu.com>
References: <1500860146-26970-1-git-send-email-jhs@emojatatu.com>
 <1500860146-26970-4-git-send-email-jhs@emojatatu.com>
 <20170724112750.GC1868@nanopsycho>
 <7057a692-7233-4632-4f66-2f57c98322ea@mojatatu.com>
 <20170725113352.GA3186@nanopsycho>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        xiyou.wangcong@gmail.com, dsahern@gmail.com,
        eric.dumazet@gmail.com, mrv@mojatatu.com,
        simon.horman@netronome.com, alex.aring@gmail.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:37369 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750861AbdGYMfB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Jul 2017 08:35:01 -0400
Received: by mail-io0-f195.google.com with SMTP id c74so755081iod.4
        for <netdev@vger.kernel.org>; Tue, 25 Jul 2017 05:35:01 -0700 (PDT)
In-Reply-To: <20170725113352.GA3186@nanopsycho>
Content-Language: en-GB
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-07-25 07:33 AM, Jiri Pirko wrote:
> Tue, Jul 25, 2017 at 01:22:44PM CEST, jhs@mojatatu.com wrote:

>>> fb? bf? nbf? Please make this synced within the patchset.
>>>
>>>
>>
>> Ok, what do you like best? ;->
> 
> "bf"
> 

Ok.

> 
>>
>>> Don't you need to mask value with selector? In fact, I think that
>>> nla_get_bitfield_32 could just return u32 which would be (value&selector).
>>> The validation takes care of unsupported bits.
>>
>> For my use case I dont need any of the above since I dont need to
>> unset things. In other use cases you will need both selector and
>> value in case someone wants a bit to be set to 0.
>> Infact I think i will rename that helper to "nla_get_bitvalue_32"
>> to be more precise.
> 
> The getter should contain name of the type, so "nla_get_bitfield32_val"
> is much better.
> 

Actually I mispoke. I was returning the struct not the value. So
nla_get_bitfield32() is a better name.

> What if I pass val 0x1 and selector 0x0 from userspace. I don't have the
> bit selected, so you should not process it in kernel, no?
>

Yes, valid point. I am not sure - should we reject?

cheers,
jamal
