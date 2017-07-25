From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v11 3/4] net sched actions: dump more than
 TCA_ACT_MAX_PRIO actions per batch
Date: Tue, 25 Jul 2017 14:37:28 +0200
Message-ID: <20170725123728.GC3186@nanopsycho>
References: <1500860146-26970-1-git-send-email-jhs@emojatatu.com>
 <1500860146-26970-4-git-send-email-jhs@emojatatu.com>
 <20170724112750.GC1868@nanopsycho>
 <7057a692-7233-4632-4f66-2f57c98322ea@mojatatu.com>
 <20170725113352.GA3186@nanopsycho>
 <355f2140-d8e8-8a4e-1f31-cbbcbfd6821b@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        xiyou.wangcong@gmail.com, dsahern@gmail.com,
        eric.dumazet@gmail.com, mrv@mojatatu.com,
        simon.horman@netronome.com, alex.aring@gmail.com
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:36642 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750732AbdGYMhb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Jul 2017 08:37:31 -0400
Received: by mail-wm0-f65.google.com with SMTP id 184so16101720wmo.3
        for <netdev@vger.kernel.org>; Tue, 25 Jul 2017 05:37:31 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <355f2140-d8e8-8a4e-1f31-cbbcbfd6821b@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Jul 25, 2017 at 02:34:58PM CEST, jhs@mojatatu.com wrote:
>On 17-07-25 07:33 AM, Jiri Pirko wrote:
>> Tue, Jul 25, 2017 at 01:22:44PM CEST, jhs@mojatatu.com wrote:
>
>> > > fb? bf? nbf? Please make this synced within the patchset.
>> > > 
>> > > 
>> > 
>> > Ok, what do you like best? ;->
>> 
>> "bf"
>> 
>
>Ok.
>
>> 
>> > 
>> > > Don't you need to mask value with selector? In fact, I think that
>> > > nla_get_bitfield_32 could just return u32 which would be (value&selector).
>> > > The validation takes care of unsupported bits.
>> > 
>> > For my use case I dont need any of the above since I dont need to
>> > unset things. In other use cases you will need both selector and
>> > value in case someone wants a bit to be set to 0.
>> > Infact I think i will rename that helper to "nla_get_bitvalue_32"
>> > to be more precise.
>> 
>> The getter should contain name of the type, so "nla_get_bitfield32_val"
>> is much better.
>> 
>
>Actually I mispoke. I was returning the struct not the value. So
>nla_get_bitfield32() is a better name.

ack


>
>> What if I pass val 0x1 and selector 0x0 from userspace. I don't have the
>> bit selected, so you should not process it in kernel, no?
>> 
>
>Yes, valid point. I am not sure - should we reject?

I think that the validation might check this and reject. Makes sense to
me.
