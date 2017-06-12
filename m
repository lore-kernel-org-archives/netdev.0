From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next v10 3/4] net sched actions: dump more than
 TCA_ACT_MAX_PRIO actions per batch
Date: Mon, 12 Jun 2017 09:57:05 -0400
Message-ID: <8d63d734-1c44-824f-a5b2-ba8c12e6f05b@mojatatu.com>
References: <1497182026-11594-1-git-send-email-jhs@emojatatu.com>
 <1497182026-11594-4-git-send-email-jhs@emojatatu.com>
 <20170611141303.GC1896@nanopsycho.orion>
 <fbf09ea1-36ee-69b1-74b0-ac436fff86ad@mojatatu.com>
 <20170612114751.GC1993@nanopsycho>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        xiyou.wangcong@gmail.com, eric.dumazet@gmail.com,
        simon.horman@netronome.com, mrv@mojatatu.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:36049 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751954AbdFLN5I (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Jun 2017 09:57:08 -0400
Received: by mail-it0-f66.google.com with SMTP id 185so8639262itv.3
        for <netdev@vger.kernel.org>; Mon, 12 Jun 2017 06:57:07 -0700 (PDT)
In-Reply-To: <20170612114751.GC1993@nanopsycho>
Content-Language: en-GB
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-06-12 07:47 AM, Jiri Pirko wrote:
> Mon, Jun 12, 2017 at 01:16:05PM CEST, jhs@mojatatu.com wrote:
>> On 17-06-11 10:13 AM, Jiri Pirko wrote:

>> This also is not useful.
>> It happens to be ok for this use case but not for the
>> general case. i.e.
>> We need to get the whole struct not just the values
>> and use the selector to pick what bits are affected.
>> Example if bit X is set to 1 in selector and bit X in value
>> is 0, then we set the kernel's bit X to 0.
> 
> Sure, have another helper for selector then.
> Or, you can have:
> 
> 	struct nla_flag_bits *fb;
> 	fb = nla_get_flag_bits(tb[TCA_ROOT_FLAGS]);
> 
> Or all 3 helpers. My point is, it is a specific netlink attribute with
> specific format, it should have get/put helpers.
> 

I did try nla_get_flag_bits(tb[TCA_ROOT_FLAGS], &fb) so i dont have
to do alloc/free - it ended being a single line function which
does a memcpy.
Is this really necessary?
The user of this structure better know it to make use of it.

cheers,
jamal
