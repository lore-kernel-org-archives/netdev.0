From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next v11 3/4] net sched actions: dump more than
 TCA_ACT_MAX_PRIO actions per batch
Date: Fri, 28 Jul 2017 11:08:10 -0400
Message-ID: <fc91ce4d-b7d1-7e95-7e9a-9265aed68424@mojatatu.com>
References: <1500860146-26970-1-git-send-email-jhs@emojatatu.com>
 <1500860146-26970-4-git-send-email-jhs@emojatatu.com>
 <20170724112750.GC1868@nanopsycho>
 <7057a692-7233-4632-4f66-2f57c98322ea@mojatatu.com>
 <20170725113352.GA3186@nanopsycho>
 <355f2140-d8e8-8a4e-1f31-cbbcbfd6821b@mojatatu.com>
 <20170725123728.GC3186@nanopsycho>
 <27472f41-1dd3-66a0-d4fc-6b7290c14b27@mojatatu.com>
 <20170728141234.GD1857@nanopsycho>
 <4e835ac7-0700-726d-7f6c-6e584ff073eb@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        xiyou.wangcong@gmail.com, dsahern@gmail.com,
        eric.dumazet@gmail.com, mrv@mojatatu.com,
        simon.horman@netronome.com, alex.aring@gmail.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:34805 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752176AbdG1PIM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Jul 2017 11:08:12 -0400
Received: by mail-io0-f194.google.com with SMTP id m88so10432025iod.1
        for <netdev@vger.kernel.org>; Fri, 28 Jul 2017 08:08:12 -0700 (PDT)
In-Reply-To: <4e835ac7-0700-726d-7f6c-6e584ff073eb@mojatatu.com>
Content-Language: en-GB
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-07-28 10:52 AM, Jamal Hadi Salim wrote:
> On 17-07-28 10:12 AM, Jiri Pirko wrote:
>> Fri, Jul 28, 2017 at 03:41:44PM CEST, jhs@mojatatu.com wrote:
> [..]
>>
>> Looks like a big mess to be honest. Mixing up u32* u32 void*. I don't
>> understand ****. Would be probably good to first apply my review comment
>> on the function itselt, then to add the checks :)
>>
> 
> I havent even compiled/test that Jiri.
> Just ignore the void * and assume it is a u32 *.
> 

This compiled - but dont have much time right now to test.
===
static int validate_nla_bitfield32(const struct nlattr *nla,
                                    u32 *valid_flags_allowed)
{
         const struct nla_bitfield32 *bf = nla_data(nla);
         u32 *valid_flags_mask = valid_flags_allowed;

         if (!valid_flags_allowed)
                 return -EINVAL;

         /*disallow invalid selector */
         if ((bf->selector & *valid_flags_allowed) > *valid_flags_allowed)
                 return -EINVAL;

         /*disallow invalid bit values */
         if (bf->value & ~*valid_flags_mask)
                 return -EINVAL;

         /*disallow valid bit values that are not selected*/
         if (bf->value & ~bf->selector)
                 return -EINVAL;

         return 0;
}
========

cheers,
jamal
