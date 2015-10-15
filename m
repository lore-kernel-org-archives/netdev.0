From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net-next 3/4] sch_htb: update backlog as well
Date: Wed, 14 Oct 2015 21:21:56 -0700
Message-ID: <CAM_iQpXsweCm+ETtHeNQFMoEJ7jGGSONG=MD6KX=+GHuBFvq2w@mail.gmail.com>
References: <1444675083-9825-1-git-send-email-xiyou.wangcong@gmail.com>
	<1444675083-9825-4-git-send-email-xiyou.wangcong@gmail.com>
	<561E499D.7060402@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Cong Wang <cwang@twopensource.com>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f44.google.com ([209.85.218.44]:33061 "EHLO
	mail-oi0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932177AbbJOEV4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Oct 2015 00:21:56 -0400
Received: by oiar126 with SMTP id r126so39666794oia.0
        for <netdev@vger.kernel.org>; Wed, 14 Oct 2015 21:21:56 -0700 (PDT)
In-Reply-To: <561E499D.7060402@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 14, 2015 at 5:25 AM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
> On 10/12/15 14:38, Cong Wang wrote:
>>
>> It is odd to see qlen!=0 but backlog==0, for a real example:
>>
>
> Backlog is a transient stat so a lot of times it should be 0. Only when
> the CPU is sending faster than the link can handle should you see
> the backlog grow (and eventually drain to 0).

Of course. But in my case, we were sending a burst of traffic while
with a lower HTB bw limit, so we can consistently see backlog!=0
for many seconds.

>
> Even though your explanation above is inaccurate I think the spirit
> of the patch looks reasonable. i.e keeping track of all additions to
> the queue and removals from the queue in the backlog stats is useful.
> However, you need to be extremely careful: This should only be done
> at exactly the spot the packet is enqueued (and not by a parent's
> enqueue asking for hierarchical enques).

The reason why I care about backlog and qlen is I want to know
the average length of each packet in backlog, to check if it is a
GSO packet at least.

>
> I think some more work is needed Cong for this general patchset.
>

Sure, I could miss something somewhere, just point it out. :)

Thanks.
