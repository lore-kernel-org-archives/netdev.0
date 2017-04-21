From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v4 1/2] net sched actions: dump more than
 TCA_ACT_MAX_PRIO actions per batch
Date: Fri, 21 Apr 2017 10:51:56 -0400 (EDT)
Message-ID: <20170421.105156.736001860584596934.davem@davemloft.net>
References: <95110642-0f9c-d622-3ca5-16ad5115da2f@mojatatu.com>
        <20170420.135842.510628867060301387.davem@davemloft.net>
        <ed5c82c7-0e59-d377-fefc-3b97764d2843@mojatatu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, jiri@resnulli.us, netdev@vger.kernel.org,
        xiyou.wangcong@gmail.com
To: jhs@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36432 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1041424AbdDUS1g (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2017 14:27:36 -0400
In-Reply-To: <ed5c82c7-0e59-d377-fefc-3b97764d2843@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>
Date: Fri, 21 Apr 2017 06:36:19 -0400

> On 17-04-20 01:58 PM, David Miller wrote:
>> From: Jamal Hadi Salim <jhs@mojatatu.com>
>> Date: Thu, 20 Apr 2017 13:38:14 -0400
>>
> 
>>> There are no examples of such issues with bitmasks encapsulated in
>>> TLVs
> 
>>> It does not make much sense to have a TLV for each of these
>>> bits when i can fit a bunch of them in u16/32/64.
>>
>> I have not ruled out bitmasks.  I'm only saying that the kernel must
>> properly reject bits it doesn't recognize when they are set.
>>
> 
> It is the other way round from what i see: It ignores them.

Which means we can never use them for anything else reliably,
there could be random crap in there.

> This allows new bits to be added over time.

No, ignoring them actually means we cannot add new bits.

> Note: It is a bug - which must be fixed - if user space sets
> something the kernel doesnt want it to set. Even then, the only good
> use case i can think of for something like this is the kernel
> is exposing something to user space for read-only and user space
> is being silly and setting read-only bits on requests to the kernel.
> But even that is not a catastrophic issue; kernel should just ignore
> it.

But since we didn't check and enforce, we can't use the bits for
settings however we like.

That's the entire point.

We can _never_ go back later and say "oops, add the checks now, it's
all good" because that doesn't work at all.
