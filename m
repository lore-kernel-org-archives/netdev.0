From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v10 3/4] net sched actions: dump more than
 TCA_ACT_MAX_PRIO actions per batch
Date: Mon, 12 Jun 2017 16:16:55 +0200
Message-ID: <20170612141655.GE1993@nanopsycho>
References: <1497182026-11594-1-git-send-email-jhs@emojatatu.com>
 <1497182026-11594-4-git-send-email-jhs@emojatatu.com>
 <20170611141303.GC1896@nanopsycho.orion>
 <fbf09ea1-36ee-69b1-74b0-ac436fff86ad@mojatatu.com>
 <20170612114751.GC1993@nanopsycho>
 <8d63d734-1c44-824f-a5b2-ba8c12e6f05b@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        xiyou.wangcong@gmail.com, eric.dumazet@gmail.com,
        simon.horman@netronome.com, mrv@mojatatu.com
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:35677 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751974AbdFLOQ6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Jun 2017 10:16:58 -0400
Received: by mail-wr0-f196.google.com with SMTP id g76so22333370wrd.2
        for <netdev@vger.kernel.org>; Mon, 12 Jun 2017 07:16:58 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <8d63d734-1c44-824f-a5b2-ba8c12e6f05b@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Jun 12, 2017 at 03:57:05PM CEST, jhs@mojatatu.com wrote:
>On 17-06-12 07:47 AM, Jiri Pirko wrote:
>> Mon, Jun 12, 2017 at 01:16:05PM CEST, jhs@mojatatu.com wrote:
>> > On 17-06-11 10:13 AM, Jiri Pirko wrote:
>
>> > This also is not useful.
>> > It happens to be ok for this use case but not for the
>> > general case. i.e.
>> > We need to get the whole struct not just the values
>> > and use the selector to pick what bits are affected.
>> > Example if bit X is set to 1 in selector and bit X in value
>> > is 0, then we set the kernel's bit X to 0.
>> 
>> Sure, have another helper for selector then.
>> Or, you can have:
>> 
>> 	struct nla_flag_bits *fb;
>> 	fb = nla_get_flag_bits(tb[TCA_ROOT_FLAGS]);
>> 
>> Or all 3 helpers. My point is, it is a specific netlink attribute with
>> specific format, it should have get/put helpers.
>> 
>
>I did try nla_get_flag_bits(tb[TCA_ROOT_FLAGS], &fb) so i dont have
>to do alloc/free - it ended being a single line function which
>does a memcpy.
>Is this really necessary?

Yes please, it is necessary! By the same logic, nla_get_u32 would not be
necessary.

I don't understand why you need alloc/free...


>The user of this structure better know it to make use of it.
>
>cheers,
>jamal
