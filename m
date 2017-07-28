From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v11 3/4] net sched actions: dump more than
 TCA_ACT_MAX_PRIO actions per batch
Date: Fri, 28 Jul 2017 16:57:18 +0200
Message-ID: <20170728145718.GF1857@nanopsycho>
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
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        xiyou.wangcong@gmail.com, dsahern@gmail.com,
        eric.dumazet@gmail.com, mrv@mojatatu.com,
        simon.horman@netronome.com, alex.aring@gmail.com
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:36530 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752073AbdG1O5V (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Jul 2017 10:57:21 -0400
Received: by mail-wm0-f67.google.com with SMTP id 184so27733147wmo.3
        for <netdev@vger.kernel.org>; Fri, 28 Jul 2017 07:57:20 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <4e835ac7-0700-726d-7f6c-6e584ff073eb@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Jul 28, 2017 at 04:52:02PM CEST, jhs@mojatatu.com wrote:
>On 17-07-28 10:12 AM, Jiri Pirko wrote:
>> Fri, Jul 28, 2017 at 03:41:44PM CEST, jhs@mojatatu.com wrote:
>[..]
>> 
>> Looks like a big mess to be honest. Mixing up u32* u32 void*. I don't
>> understand ****. Would be probably good to first apply my review comment
>> on the function itselt, then to add the checks :)
>> 
>
>I havent even compiled/test that Jiri.
>Just ignore the void * and assume it is a u32 *.
>
>I am trying to avoid doing unlucky number 13 patch.

I'll rather wait for you to send the code in proper shape so I can
decypher easily and don't have to guess.


>So feedback on this is good. Just look at what it is disallowing
>first.
>
>back later.
>
>cheers,
>jamal
>
>> 
>> > I can think of.
>> > 
>> > static int validate_nla_bitfield32(const struct nlattr *nla,
>> >                                     void *valid_flags_allowed)
>> > {
>> >         const struct nla_bitfield32 *bf = nla_data(nla);
>> >         u32 *valid_flags_mask = valid_flags_allowed;
>> > 
>> >         if (!valid_flags_allowed)
>> >                 return -EINVAL;
>> >         /*disallow invalid selector */
>> >         if ((bf->selector & valid_flags_allowed) >*valid_flags_allowed)
>> >                 return -EINVAL;
>> >         /*disallow invalid bit values */
>> >         if (bf->value & ~*valid_flags_mask)
>> >                 return -EINVAL;
>> >         /*disallow valid bit values that are not selected*/
>> >         if (bf->value & ~nbf->selector)
>> >                 return -EINVAL;
>> > 
>> >         return 0;
>> > }
>> > 
>> > cheers,
>> > jamal
>
