From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net] sched, cls: check if we could overwrite actions when
 changing a filter
Date: Thu, 17 Apr 2014 13:48:21 -0700
Message-ID: <CAM_iQpVqQbXcm0gGxe_JMURPtGYH+iOi8UGgvis5je6g9zbiKQ@mail.gmail.com>
References: <1397605563-29756-1-git-send-email-xiyou.wangcong@gmail.com>
	<534E77D0.8000307@mojatatu.com>
	<CAM_iQpXRVZ8_keaL-8OkmRVguA29bnTPS2ZHZ0j2SSeB6A=1jQ@mail.gmail.com>
	<534FBFF0.3020606@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <cwang@twopensource.com>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve0-f181.google.com ([209.85.128.181]:36289 "EHLO
	mail-ve0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751179AbaDQUsW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Apr 2014 16:48:22 -0400
Received: by mail-ve0-f181.google.com with SMTP id oy12so1254325veb.12
        for <netdev@vger.kernel.org>; Thu, 17 Apr 2014 13:48:21 -0700 (PDT)
In-Reply-To: <534FBFF0.3020606@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 17, 2014 at 4:50 AM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
> On 04/16/14 17:10, Cong Wang wrote:
>>
>> Why? Since actions are inside it, I should be able to change any
>> part of it, right?
>>
>
> The challenge is in the semantics. You are making change to the
> graph _not_ to the filter. There are dependencies in a graph. IOW,
> I doubt what you are doing could be made generic and safe without
> it being a two step operation since we have multiple tables to deal
> with.
> Example - what would you do if you wanted to change the graph
> so that you add something in the middle or remove something at
> the end?


Actions attached to a filter are at the end of the graph, they should
be able to be added/removed together.

>
>
>>> If otoh you wanted to replace the filter + action graph with a backup
>>> rule, then just add it lower in the priority list and delete the
>>> existing one etc.
>>>
>>
>> This is not atomic, is it?
>>
>
> It avoids the need for atomicity. Backup rule will never be used
> as long as the active is still in use.
> If you can do the two steps in the kernel as i described, then
> you can achieve your purpose but i worry it will complicate code
> for a corner use case (which has a work around already).
>

This is a workaround, not a fix. What if I have multiple threads
trying to append an action at the same time? This workaround
can't guarantee the correctness.

My case is a perfectly valid use, we have to fix it, maybe in
another way.
