From: Vladimir Zapolskiy <vzapolskiy@gmail.com>
Subject: Re: [PATCH v2] connector: add an event for monitoring process tracers
Date: Mon, 18 Jul 2011 21:57:27 +0300
Message-ID: <CAMW3pwYvXqi4=e24kvQRdsHsFa5o1KL9PrekK0RCVyWTvhNx4A@mail.gmail.com>
References: <1310751918-31579-1-git-send-email-vzapolskiy@gmail.com>
	<20110718175458.GA12840@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, Evgeniy Polyakov <zbr@ioremap.net>,
	"David S. Miller" <davem@davemloft.net>
To: Oleg Nesterov <oleg@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:44932 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754270Ab1GRS52 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jul 2011 14:57:28 -0400
Received: by gyh3 with SMTP id 3so1449188gyh.19
        for <netdev@vger.kernel.org>; Mon, 18 Jul 2011 11:57:27 -0700 (PDT)
In-Reply-To: <20110718175458.GA12840@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 18, 2011 at 8:54 PM, Oleg Nesterov <oleg@redhat.com> wrote:
> On 07/15, Vladimir Zapolskiy wrote:
>>
>> Such an event allows to create a simple automated userspace mechanism
>> to be aware about processes connecting to others, therefore predefined
>> process policies can be applied to them if needed.
>
> I'd wish I could understand this ;) IOW, I still do not understand why
> this is useful, but this doesn't matter. Since Evgeniy acked this patch,
> I'll apply it to ptrace tree.
>

Originally the idea comes from a desire to classify development tools
like strace or gdb in the same way as a tracee process, for instance
put them to a tracee's current cgroup partition, which might be done
automatically in user-space by some process "track and manage" daemon.

>
> Can't resist, a couple of very minor/cosmetics nits. Just because I am
> blighter ;)
>
>> +void proc_ptrace_connector(struct task_struct *task, int which_id);
>
> "which_id" doesn't match "ptrace_id" used elsewhere. And PTRACE_ATTACH
> instead of simple boolean looks as if you are going to add more ptrace
> events, but I guess this won't happen.
>

I'd like to preserve that variant, in my opinion its just a bit more
undisguised version rather than bare true/false.

>> -     if (!retval)
>> +     if (!retval) {
>>               wait_on_bit(&task->jobctl, JOBCTL_TRAPPING_BIT,
>>                           ptrace_trapping_sleep_fn, TASK_UNINTERRUPTIBLE);
>> +             proc_ptrace_connector(task, PTRACE_ATTACH);
>> +     }
>
> OK, but it is a bit strange we are waiting for STOPPED/TRACED transition
> before we report PROC_EVENT_PTRACE. Perhaps it makes more sense to
> call proc_ptrace_connector() first, this also decreases the probability
> PTRACE_ATTACH will be reported after PROC_EVENT_EXIT.
>
Yes, there is a difference. But as far as there is no guaranteed
serialization in proc connector event reports, user-space process
trackers should be designed to operate correctly having in mind
possible event reordering.

>
> But once again, this is very minor and cosmetic. I am going to apply
> the patch as is unless you send v3 quickly.
>

Thank you a lot, especially for comments, but I think this v2 is good
enough to be applied :) And if there are more users of that proc
connector extension in future, it might be needed to cut some sharp
corners later, and may be even add implicit detach reporting :)

--
With best wishes,
Vladimir
