From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net] sched, cls: check if we could overwrite actions when
 changing a filter
Date: Wed, 16 Apr 2014 14:10:08 -0700
Message-ID: <CAM_iQpXRVZ8_keaL-8OkmRVguA29bnTPS2ZHZ0j2SSeB6A=1jQ@mail.gmail.com>
References: <1397605563-29756-1-git-send-email-xiyou.wangcong@gmail.com>
	<534E77D0.8000307@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <cwang@twopensource.com>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f51.google.com ([209.85.219.51]:42865 "EHLO
	mail-oa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030183AbaDPVKJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Apr 2014 17:10:09 -0400
Received: by mail-oa0-f51.google.com with SMTP id i4so12963387oah.24
        for <netdev@vger.kernel.org>; Wed, 16 Apr 2014 14:10:09 -0700 (PDT)
In-Reply-To: <534E77D0.8000307@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 16, 2014 at 5:30 AM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
> On 04/15/14 19:46, Cong Wang wrote:
>>
>> From: Cong Wang <cwang@twopensource.com>
>>
>> When actions are attached to a filter, they are a part of the filter
>> itself, so when changing a filter we should allow to overwrite the actions
>> inside as well.
>>
>> In my specific case, when I tried to _append_ a new action to an existing
>> filter which already has an action, I got EEXIST since kernel refused
>> to overwrite the existing one in kernel.
>>
>> This patch checks if we are changing the filter checking NLM_F_CREATE flag
>> (Sigh, filters don't use NLM_F_REPLACE...) and then passes the boolean
>> down
>> to actions. This fixes the problem above.
>
>
>
> What are you trying to achieve?

I thought it's clear: I have a filter F1 contains an action A1,
they are already in kernel (therefore I can read them from libnl cache),
then I want to append A2 to F1 so that F1 would have two actions
A1 and A2.

In short: change from F1 -> A1 to F1 -> A1 -> A2 atomically.

> These are general netlink rules (which can be streamlined by
> the object).
> Append means "I dont care if this exists, add it to the end"

Exactly what I meant.

> In that case, you would specify the an existing filter rule but
> in order to resolve ambiguity tc classifiers provide priorities
> (i.e just specify a different priority) and the rule will be added
> before or after  the conflicting rule.
> If you dont do that then you will get back EEXIST to tell you
> there is a conflict.

But I already told kernel I am changing a filter, so why it
complains? I should change an existing one, shouldn't I?

> You cant replace an existing filter in particular when it has
> a graph of actions attached to it. You can replace the paremetrization
> of an existing bound action - but i am not sure that is what you
> are trying to do here. For that address the specific action directly.
> i.e tc action ....

Why? Since actions are inside it, I should be able to change any
part of it, right?

> If otoh you wanted to replace the filter + action graph with a backup
> rule, then just add it lower in the priority list and delete the
> existing one etc.
>

This is not atomic, is it?
