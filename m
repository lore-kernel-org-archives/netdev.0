From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next v4 1/2] net sched actions: dump more than
 TCA_ACT_MAX_PRIO actions per batch
Date: Fri, 21 Apr 2017 06:36:19 -0400
Message-ID: <ed5c82c7-0e59-d377-fefc-3b97764d2843@mojatatu.com>
References: <48ec5026-38bf-ebfd-98e5-78c8cb1d24f5@mojatatu.com>
 <20170420.115000.250335491542942036.davem@davemloft.net>
 <95110642-0f9c-d622-3ca5-16ad5115da2f@mojatatu.com>
 <20170420.135842.510628867060301387.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, jiri@resnulli.us, netdev@vger.kernel.org,
        xiyou.wangcong@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f180.google.com ([209.85.223.180]:35775 "EHLO
        mail-io0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1037320AbdDUKgb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2017 06:36:31 -0400
Received: by mail-io0-f180.google.com with SMTP id r16so108678512ioi.2
        for <netdev@vger.kernel.org>; Fri, 21 Apr 2017 03:36:31 -0700 (PDT)
In-Reply-To: <20170420.135842.510628867060301387.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-04-20 01:58 PM, David Miller wrote:
> From: Jamal Hadi Salim <jhs@mojatatu.com>
> Date: Thu, 20 Apr 2017 13:38:14 -0400
>

>> There are no examples of such issues with bitmasks encapsulated in
>> TLVs

>> It does not make much sense to have a TLV for each of these
>> bits when i can fit a bunch of them in u16/32/64.
>
> I have not ruled out bitmasks.  I'm only saying that the kernel must
> properly reject bits it doesn't recognize when they are set.
>

It is the other way round from what i see: It ignores them.
This allows new bits to be added over time.
Note: It is a bug - which must be fixed - if user space sets
something the kernel doesnt want it to set. Even then, the only good
use case i can think of for something like this is the kernel
is exposing something to user space for read-only and user space
is being silly and setting read-only bits on requests to the kernel.
But even that is not a catastrophic issue; kernel should just ignore it.

> Each bit must have a strict semantic, even unused ones, otherwise
> unused ones may never safely be used in the future.
>

I think we are pretty good at this.
It would be interesting to have a fuzzer which sets random bits on a
TLV bitmask and see what bugs show up.

cheers,
jamal
