From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next v4 1/2] net sched actions: dump more than
 TCA_ACT_MAX_PRIO actions per batch
Date: Fri, 21 Apr 2017 11:55:40 -0400
Message-ID: <c2d61246-b92d-efef-cd07-005f8a8dacc0@mojatatu.com>
References: <ed5c82c7-0e59-d377-fefc-3b97764d2843@mojatatu.com>
 <20170421.105156.736001860584596934.davem@davemloft.net>
 <82a6c32b-d58e-aeed-bfb5-546f328eaf35@mojatatu.com>
 <20170421.113800.1367091481085913667.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, jiri@resnulli.us, netdev@vger.kernel.org,
        xiyou.wangcong@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:35611 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1161808AbdDUPzq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2017 11:55:46 -0400
Received: by mail-io0-f195.google.com with SMTP id d203so31813326iof.2
        for <netdev@vger.kernel.org>; Fri, 21 Apr 2017 08:55:46 -0700 (PDT)
In-Reply-To: <20170421.113800.1367091481085913667.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-04-21 11:38 AM, David Miller wrote:
> From: Jamal Hadi Salim <jhs@mojatatu.com>
> Date: Fri, 21 Apr 2017 11:29:19 -0400
>

>
> You don't know this because the kernel has never verified it.
> Jamal, you cannot walk past this important point, nothing can
> be argued further because of it.
>
>> Old kernels ignore them. New kernels look at the new ones.
>> We'll be in a lot of trouble if this was not the case
>> for things today;-> People add bits all the time in TLVs
>> and in netlink headers that are labeled as flags.
>
> And when we do things that way it's broken, and why we have such
> crappy behavior.
>
> We made a very bad decision a long time ago to ignore unrecognized
> things in netlink and it was a grave error which we must start
> correcting now.
>

Dave, that is a different argument which i can appreciate.

> If a user says "enable X" and it just gets simply ignored by older
> kernels, that can't work properly.  What if "enable X" is something
> like "turn on encryption"?  Are you OK with the user getting no
> feedback that their stuff is not going to be encrypted?
>

For this specific use case:
Dont they need a newer kernel which supports "enable encryption"?

> Even something as benign as "give melarger action dumps" _must_ still
> have the same behavior because the user has no alternative action plan
> possible if it cannot tell if the kernel supports the facility or not.
>

So you are seeing this as feature discovery as well then.

>> Dave, I dont think you are suggesting we should use a TLV for every
>> bit
>> we want to  send to the kernel (as Jiri is), are you?
>
> Jiri is not suggesting this, he is instead saying if you want to
> support more bits in the future then you must check that the unused
> bits are zero _now_ so that we can prove that userland clears them
> properly.
>
> And if you don't have any direct plans for more bits in the future,
> use just a single attribute with the smallest integer type possible.
>

Ok, lets move with that premise then in our discussion.

>> I think you as suggesting we should from now on enforce a rule that
>> in the kernel we start checking that bits in a bitmap received for
>> things we are not interested in. So if a bit i dont understand shows
>> up in the kernel what should i do?
>
> Reject it.
>

It may be case by case basis, no?

I can understand rejecting for something that will break operations.
Example "i want you to encrypt this".
But i think there are other cases like "please give me a large
dump" which require less harsh reaction in particular because
I have alternative means in the kernel to achieve the dump.
Would logging or no reaction be fine then?

cheers,
jamal
