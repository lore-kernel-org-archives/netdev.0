From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH v2] connector: add an event for monitoring process
	tracers
Date: Mon, 18 Jul 2011 21:39:38 +0200
Message-ID: <20110718193938.GA17629@redhat.com>
References: <1310751918-31579-1-git-send-email-vzapolskiy@gmail.com> <20110718175458.GA12840@redhat.com> <CAMW3pwYvXqi4=e24kvQRdsHsFa5o1KL9PrekK0RCVyWTvhNx4A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Evgeniy Polyakov <zbr@ioremap.net>,
	"David S. Miller" <davem@davemloft.net>
To: Vladimir Zapolskiy <vzapolskiy@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38195 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755044Ab1GRTmH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Jul 2011 15:42:07 -0400
Content-Disposition: inline
In-Reply-To: <CAMW3pwYvXqi4=e24kvQRdsHsFa5o1KL9PrekK0RCVyWTvhNx4A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/18, Vladimir Zapolskiy wrote:
>
> On Mon, Jul 18, 2011 at 8:54 PM, Oleg Nesterov <oleg@redhat.com> wrote:
>
> > "which_id" doesn't match "ptrace_id" used elsewhere. And PTRACE_ATTACH
> > instead of simple boolean looks as if you are going to add more ptrace
> > events, but I guess this won't happen.
> >
>^
> I'd like to preserve that variant, in my opinion its just a bit more
> undisguised version rather than bare true/false.

OK. Although this "else return" in proc_ptrace_connector() looks like
the "hide the potentional error" to me.

> >> -     if (!retval)
> >> +     if (!retval) {
> >>               wait_on_bit(&task->jobctl, JOBCTL_TRAPPING_BIT,
> >>                           ptrace_trapping_sleep_fn, TASK_UNINTERRUPTIBLE);
> >> +             proc_ptrace_connector(task, PTRACE_ATTACH);
> >> +     }
> >
> > OK, but it is a bit strange we are waiting for STOPPED/TRACED transition
> > before we report PROC_EVENT_PTRACE. Perhaps it makes more sense to
> > call proc_ptrace_connector() first, this also decreases the probability
> > PTRACE_ATTACH will be reported after PROC_EVENT_EXIT.
> >
> Yes, there is a difference. But as far as there is no guaranteed
> serialization in proc connector event reports, user-space process
> trackers should be designed to operate correctly having in mind
> possible event reordering.

Yes, but I didn't really mean the correctness. I meant, this looks
confusing, as if this wait_on_bit() has something to do with attach.
Likewise I do not understand why proc_exec_connector() is called
after ptrace_event() which can sleep unpredictably long.



Nevermind, applied.

Oleg.

