From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v4 1/2] net sched actions: dump more than
 TCA_ACT_MAX_PRIO actions per batch
Date: Thu, 20 Apr 2017 13:58:42 -0400 (EDT)
Message-ID: <20170420.135842.510628867060301387.davem@davemloft.net>
References: <48ec5026-38bf-ebfd-98e5-78c8cb1d24f5@mojatatu.com>
        <20170420.115000.250335491542942036.davem@davemloft.net>
        <95110642-0f9c-d622-3ca5-16ad5115da2f@mojatatu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, jiri@resnulli.us, netdev@vger.kernel.org,
        xiyou.wangcong@gmail.com
To: jhs@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:46208 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S967315AbdDTR6o (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Apr 2017 13:58:44 -0400
In-Reply-To: <95110642-0f9c-d622-3ca5-16ad5115da2f@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>
Date: Thu, 20 Apr 2017 13:38:14 -0400

> On 17-04-20 11:50 AM, David Miller wrote:
>> From: Jamal Hadi Salim <jhs@mojatatu.com>
>> Date: Thu, 20 Apr 2017 09:27:00 -0400
>>
>>> The issue Jiri is bringing up is unrelated. He is talking about
>>> a bitmap and conflating it with a data structure. They are not
>>> the same issue.
>>
>> Bitmaps can have the same exact problem as padding if we didn't code
>> it correctly.
>>
>> The issue is _purely_, "did we check unused 'fields' and enforce them
>> to be a certain value"
>>
>> If not, we lose, and can't use those "fields" in the future.
>>
>> This rule applies whether you are speaking about padding or a bitmask.
>>
> 
> There are no examples of such issues with bitmasks encapsulated in
> TLVs
> that exist.
> I grep iproute2 code and there are tons of example of bitmask flags
> being sent in TLVs. They all start with:
> 
> u64/32/16 mybitflags = 0;
> 
> if i want foo then
>        mybitflags |= BRIDGE_FLAGS_SELF;
> if i want bar then
>        mybitflags |= xxxx
> 
> addattr16/32/64(&req.n, sizeof(req), ATTR_XXX, mybitflags);
> 
> It does not make much sense to have a TLV for each of these
> bits when i can fit a bunch of them in u16/32/64.

I have not ruled out bitmasks.  I'm only saying that the kernel must
properly reject bits it doesn't recognize when they are set.

Each bit must have a strict semantic, even unused ones, otherwise
unused ones may never safely be used in the future.
