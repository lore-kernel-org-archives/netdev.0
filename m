From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next v6 2/3] net sched actions: dump more than
 TCA_ACT_MAX_PRIO actions per batch
Date: Fri, 21 Apr 2017 11:40:00 -0400
Message-ID: <6b26ef20-972f-24bf-22bf-8462606ce16d@mojatatu.com>
References: <1492772132-16559-1-git-send-email-jhs@emojatatu.com>
 <1492772132-16559-3-git-send-email-jhs@emojatatu.com>
 <20170421131220.GC1874@nanopsycho.orion>
 <1dea2c80-9c86-353e-6a74-f5b86070df04@mojatatu.com>
 <1492788031.6453.14.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jiri@resnulli.us>, davem@davemloft.net,
        xiyou.wangcong@gmail.com, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:33793 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1424733AbdDUTUw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2017 15:20:52 -0400
Received: by mail-io0-f194.google.com with SMTP id h41so33693103ioi.1
        for <netdev@vger.kernel.org>; Fri, 21 Apr 2017 12:20:52 -0700 (PDT)
In-Reply-To: <1492788031.6453.14.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-04-21 11:20 AM, Eric Dumazet wrote:
> On Fri, 2017-04-21 at 11:12 -0400, Jamal Hadi Salim wrote:
>> On 17-04-21 09:12 AM, Jiri Pirko wrote:
>>> Fri, Apr 21, 2017 at 12:55:31PM CEST, jhs@mojatatu.com wrote:
>>>> From: Jamal Hadi Salim <jhs@mojatatu.com>
>>

>> Jiri, there is a balance between extensibility and performance.
>> It is senseless to use a TLV just so i can set a 0/1(true/false).
>
> You assume that the (user space) did sensible things.
>

If it didnt it is a bug. Seriously.
Look: If this was the case a lot of things would break in the
kernel. We have bit flags everywhere. We add new ones frequently
to these bitmaps.

> Sometimes they do not, and sets some bits to 1 while they should not.
>

That is a bug.  You cant blame the compiler.

> If old kernel just ignored theses bits, application just ran fine and
> was _qualified_.
>
> Now customers might use these _working_ applications.
>
> Then, Jamal comes and change the kernel to give a meaning to these bits.
>

As happens frequently, not just Jamal - Eric also;->

> Now the customer is running the new kernel and the old application
> breaks horribly.
>
> Who is at fault ? Jamal of course, not the application authors that
> might be out of business, and could not have any test that could have
> spot the (future) issue.
>
> Please Jamal, can we stop this for good ?

Eric: Your are speaking in generalities and you starting premise is
wrong. Anyone setting random bits in a netlink bitmask that has not
been defined is creating bug. We have many examples of how netlink
bitmasks are being used and constantly extended. Please take a look.

If i was the first person starting this today, then yes you will be
making a lot of sense.
For the pads - the arguement that malloc-ing the datastructure may put
random values in the pads was a reasonable arguement. But this is not.

cheers,
jamal
