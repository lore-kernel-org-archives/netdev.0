From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next v4 1/2] net sched actions: dump more than
 TCA_ACT_MAX_PRIO actions per batch
Date: Fri, 21 Apr 2017 11:29:19 -0400
Message-ID: <82a6c32b-d58e-aeed-bfb5-546f328eaf35@mojatatu.com>
References: <95110642-0f9c-d622-3ca5-16ad5115da2f@mojatatu.com>
 <20170420.135842.510628867060301387.davem@davemloft.net>
 <ed5c82c7-0e59-d377-fefc-3b97764d2843@mojatatu.com>
 <20170421.105156.736001860584596934.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, jiri@resnulli.us, netdev@vger.kernel.org,
        xiyou.wangcong@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:33952 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1161679AbdDUPhZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2017 11:37:25 -0400
Received: by mail-io0-f194.google.com with SMTP id h41so31562827ioi.1
        for <netdev@vger.kernel.org>; Fri, 21 Apr 2017 08:37:25 -0700 (PDT)
In-Reply-To: <20170421.105156.736001860584596934.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-04-21 10:51 AM, David Miller wrote:
> From: Jamal Hadi Salim <jhs@mojatatu.com>
> Date: Fri, 21 Apr 2017 06:36:19 -0400
>
>> On 17-04-20 01:58 PM, David Miller wrote:
>>> From: Jamal Hadi Salim <jhs@mojatatu.com>
>>> Date: Thu, 20 Apr 2017 13:38:14 -0400
>>>
>>

>
> Which means we can never use them for anything else reliably,
> there could be random crap in there.
>

Today: User space set them to zero. Receivers in the kernel
only look at what they are interested in. I stopped checking after a
while - but everything i looked at in iproute2 worked
like this.

>> This allows new bits to be added over time.
>
> No, ignoring them actually means we cannot add new bits.
>

Old kernels ignore them. New kernels look at the new ones.
We'll be in a lot of trouble if this was not the case
for things today;-> People add bits all the time in TLVs
and in netlink headers that are labeled as flags.

>> Note: It is a bug - which must be fixed - if user space sets
>> something the kernel doesnt want it to set. Even then, the only good
>> use case i can think of for something like this is the kernel
>> is exposing something to user space for read-only and user space
>> is being silly and setting read-only bits on requests to the kernel.
>> But even that is not a catastrophic issue; kernel should just ignore
>> it.
>
> But since we didn't check and enforce, we can't use the bits for
> settings however we like.
>
> That's the entire point.
>
> We can _never_ go back later and say "oops, add the checks now, it's
> all good" because that doesn't work at all.
>

Dave, I dont think you are suggesting we should use a TLV for every bit
we want to  send to the kernel (as Jiri is), are you?

I think you as suggesting we should from now on enforce a rule that
in the kernel we start checking that bits in a bitmap received for
things we are not interested in. So if a bit i dont understand shows
up in the kernel what should i do?
Rejecting the transaction because i received something i dont
understand is not conducive to forward compatibility. Maybe logging
it would be useful.
If i dont get a bit i am expecting (old user space), then for sure
rejecting sounds reasonable.

cheers,
jamal
