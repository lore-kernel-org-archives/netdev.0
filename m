From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [Patch net-next 3/4] sch_htb: update backlog as well
Date: Fri, 16 Oct 2015 08:19:48 -0400
Message-ID: <5620EB64.4010209@mojatatu.com>
References: <1444675083-9825-1-git-send-email-xiyou.wangcong@gmail.com>
 <1444675083-9825-4-git-send-email-xiyou.wangcong@gmail.com>
 <561E499D.7060402@mojatatu.com>
 <CAM_iQpXsweCm+ETtHeNQFMoEJ7jGGSONG=MD6KX=+GHuBFvq2w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Cong Wang <cwang@twopensource.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f171.google.com ([209.85.223.171]:36357 "EHLO
	mail-io0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932103AbbJPMTu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Oct 2015 08:19:50 -0400
Received: by ioii196 with SMTP id i196so121203247ioi.3
        for <netdev@vger.kernel.org>; Fri, 16 Oct 2015 05:19:50 -0700 (PDT)
In-Reply-To: <CAM_iQpXsweCm+ETtHeNQFMoEJ7jGGSONG=MD6KX=+GHuBFvq2w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/15/15 00:21, Cong Wang wrote:
> On Wed, Oct 14, 2015 at 5:25 AM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
>> On 10/12/15 14:38, Cong Wang wrote:
>>>
>>> It is odd to see qlen!=0 but backlog==0, for a real example:
>>>
>>
>> Backlog is a transient stat so a lot of times it should be 0. Only when
>> the CPU is sending faster than the link can handle should you see
>> the backlog grow (and eventually drain to 0).
>
> Of course. But in my case, we were sending a burst of traffic while
> with a lower HTB bw limit, so we can consistently see backlog!=0
> for many seconds.
>


Depending on how much bandwidth you are allowing to be shaped,
this observation is expected. HTB (and any non-work
conserving qdisc) would keep packets backlogged for as long as you
you are instructing it to keep them. If you are sending to the link
faster than the shaping rate, qdisc backlog will grow and take a
while to drain.
[I have seen cases where actually the way the parameters are set
is the problem (unfortunately userspace doesnt do a lot of checking
for sanity).]

Like i said earlier, the idea of keeping track of backlog is useful.
I think the commit log threw me off.
"It is odd to see qlen!=0 but backlog==0"
If you change that commit log then:

Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>

cheers,
jamal
