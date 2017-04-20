From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next v4 1/2] net sched actions: dump more than
 TCA_ACT_MAX_PRIO actions per batch
Date: Thu, 20 Apr 2017 13:38:14 -0400
Message-ID: <95110642-0f9c-d622-3ca5-16ad5115da2f@mojatatu.com>
References: <f0e84f44-ba3a-7eb4-8b22-9764048d9406@mojatatu.com>
 <1492690694.22296.32.camel@edumazet-glaptop3.roam.corp.google.com>
 <48ec5026-38bf-ebfd-98e5-78c8cb1d24f5@mojatatu.com>
 <20170420.115000.250335491542942036.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, jiri@resnulli.us, netdev@vger.kernel.org,
        xiyou.wangcong@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f169.google.com ([209.85.223.169]:34526 "EHLO
        mail-io0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S945278AbdDTRiS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Apr 2017 13:38:18 -0400
Received: by mail-io0-f169.google.com with SMTP id a103so80374562ioj.1
        for <netdev@vger.kernel.org>; Thu, 20 Apr 2017 10:38:18 -0700 (PDT)
In-Reply-To: <20170420.115000.250335491542942036.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-04-20 11:50 AM, David Miller wrote:
> From: Jamal Hadi Salim <jhs@mojatatu.com>
> Date: Thu, 20 Apr 2017 09:27:00 -0400
>
>> The issue Jiri is bringing up is unrelated. He is talking about
>> a bitmap and conflating it with a data structure. They are not
>> the same issue.
>
> Bitmaps can have the same exact problem as padding if we didn't code
> it correctly.
>
> The issue is _purely_, "did we check unused 'fields' and enforce them
> to be a certain value"
>
> If not, we lose, and can't use those "fields" in the future.
>
> This rule applies whether you are speaking about padding or a bitmask.
>

There are no examples of such issues with bitmasks encapsulated in TLVs
that exist.
I grep iproute2 code and there are tons of example of bitmask flags
being sent in TLVs. They all start with:

u64/32/16 mybitflags = 0;

if i want foo then
        mybitflags |= BRIDGE_FLAGS_SELF;
if i want bar then
        mybitflags |= xxxx

addattr16/32/64(&req.n, sizeof(req), ATTR_XXX, mybitflags);

It does not make much sense to have a TLV for each of these
bits when i can fit a bunch of them in u16/32/64.

cheers,
jamal
