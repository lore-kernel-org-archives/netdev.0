From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next v4 1/2] net sched actions: dump more than
 TCA_ACT_MAX_PRIO actions per batch
Date: Mon, 24 Apr 2017 08:54:19 -0400
Message-ID: <f2ca8953-ba18-3593-aaf2-13b474574147@mojatatu.com>
References: <20170421.113800.1367091481085913667.davem@davemloft.net>
 <c2d61246-b92d-efef-cd07-005f8a8dacc0@mojatatu.com>
 <758ff636-365f-6180-9353-69da5d339a3a@mojatatu.com>
 <20170421.121217.1268145592512455181.davem@davemloft.net>
 <c6333422-ae6d-149c-09ec-c5dfb43d68b3@mojatatu.com>
 <20170424092754.GB25218@vergenet.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
        jiri@resnulli.us, netdev@vger.kernel.org, xiyou.wangcong@gmail.com
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:33308 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1170316AbdDXMyW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Apr 2017 08:54:22 -0400
Received: by mail-it0-f66.google.com with SMTP id z67so17039477itb.0
        for <netdev@vger.kernel.org>; Mon, 24 Apr 2017 05:54:21 -0700 (PDT)
In-Reply-To: <20170424092754.GB25218@vergenet.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-04-24 05:27 AM, Simon Horman wrote:
> On Fri, Apr 21, 2017 at 02:11:00PM -0400, Jamal Hadi Salim wrote:
>> On 17-04-21 12:12 PM, David Miller wrote:

>
> From my PoV, for #d user-space has to either get smart or fail.
>
> Creating new tc involved work in order to support the new feature.
> Part of that work would be a decision weather or not to provide
> compatibility for old kernel or to bail out gracefully.
>

But not that much work as is being ascribed now.
This is a big change to user space code. Are we planning to
change all netlink apps (everything in iproute2) to now discover
by testing whether their flags are accepted or not? One extra
crossing to the kernel just to test the waters.

I think there's a middle ground and see which idea takes off.
Refer to the last patch I sent which implements the idea below.

cheers,
jamal

>> There is a simpler approach that would work going forward.
>> How about letting the user choose their fate? Set something maybe
>> in the netlink header to tell the kernel "if you dont understand
>> something I am asking for - please ignore it and do what you can".
>> This would maintain current behavior but would force the user to
>> explicitly state so.
>>
>> cheers,
>> jamal
>>
