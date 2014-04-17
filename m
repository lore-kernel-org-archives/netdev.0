From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [Patch net] sched, cls: check if we could overwrite actions when
 changing a filter
Date: Thu, 17 Apr 2014 07:50:08 -0400
Message-ID: <534FBFF0.3020606@mojatatu.com>
References: <1397605563-29756-1-git-send-email-xiyou.wangcong@gmail.com>	<534E77D0.8000307@mojatatu.com> <CAM_iQpXRVZ8_keaL-8OkmRVguA29bnTPS2ZHZ0j2SSeB6A=1jQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <cwang@twopensource.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f172.google.com ([209.85.223.172]:62238 "EHLO
	mail-ie0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752291AbaDQLuU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Apr 2014 07:50:20 -0400
Received: by mail-ie0-f172.google.com with SMTP id as1so249407iec.17
        for <netdev@vger.kernel.org>; Thu, 17 Apr 2014 04:50:19 -0700 (PDT)
In-Reply-To: <CAM_iQpXRVZ8_keaL-8OkmRVguA29bnTPS2ZHZ0j2SSeB6A=1jQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/16/14 17:10, Cong Wang wrote:
> On Wed, Apr 16, 2014 at 5:30 AM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:

>
> I thought it's clear: I have a filter F1 contains an action A1,
> they are already in kernel (therefore I can read them from libnl cache),
> then I want to append A2 to F1 so that F1 would have two actions
> A1 and A2.
>
> In short: change from F1 -> A1 to F1 -> A1 -> A2 atomically.
>

Ok, got it.

>> In that case, you would specify the an existing filter rule but
>> in order to resolve ambiguity tc classifiers provide priorities
>> (i.e just specify a different priority) and the rule will be added
>> before or after  the conflicting rule.
>> If you dont do that then you will get back EEXIST to tell you
>> there is a conflict.
>
> But I already told kernel I am changing a filter, so why it
> complains? I should change an existing one, shouldn't I?
>

[..]

> Why? Since actions are inside it, I should be able to change any
> part of it, right?
>

The challenge is in the semantics. You are making change to the
graph _not_ to the filter. There are dependencies in a graph. IOW,
I doubt what you are doing could be made generic and safe without
it being a two step operation since we have multiple tables to deal
with.
Example - what would you do if you wanted to change the graph
so that you add something in the middle or remove something at
the end?

>> If otoh you wanted to replace the filter + action graph with a backup
>> rule, then just add it lower in the priority list and delete the
>> existing one etc.
>>
>
> This is not atomic, is it?
>

It avoids the need for atomicity. Backup rule will never be used
as long as the active is still in use.
If you can do the two steps in the kernel as i described, then
you can achieve your purpose but i worry it will complicate code
for a corner use case (which has a work around already).

cheers,
jamal
