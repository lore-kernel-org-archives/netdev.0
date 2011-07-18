From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH v2] connector: add an event for monitoring process
	tracers
Date: Mon, 18 Jul 2011 19:54:58 +0200
Message-ID: <20110718175458.GA12840@redhat.com>
References: <1310751918-31579-1-git-send-email-vzapolskiy@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Evgeniy Polyakov <zbr@ioremap.net>,
	"David S. Miller" <davem@davemloft.net>
To: Vladimir Zapolskiy <vzapolskiy@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36798 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751097Ab1GRR5V (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Jul 2011 13:57:21 -0400
Content-Disposition: inline
In-Reply-To: <1310751918-31579-1-git-send-email-vzapolskiy@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/15, Vladimir Zapolskiy wrote:
>
> Such an event allows to create a simple automated userspace mechanism
> to be aware about processes connecting to others, therefore predefined
> process policies can be applied to them if needed.

I'd wish I could understand this ;) IOW, I still do not understand why
this is useful, but this doesn't matter. Since Evgeniy acked this patch,
I'll apply it to ptrace tree.



Can't resist, a couple of very minor/cosmetics nits. Just because I am
blighter ;)

> +void proc_ptrace_connector(struct task_struct *task, int which_id);

"which_id" doesn't match "ptrace_id" used elsewhere. And PTRACE_ATTACH
instead of simple boolean looks as if you are going to add more ptrace
events, but I guess this won't happen.

> -	if (!retval)
> +	if (!retval) {
>  		wait_on_bit(&task->jobctl, JOBCTL_TRAPPING_BIT,
>  			    ptrace_trapping_sleep_fn, TASK_UNINTERRUPTIBLE);
> +		proc_ptrace_connector(task, PTRACE_ATTACH);
> +	}

OK, but it is a bit strange we are waiting for STOPPED/TRACED transition
before we report PROC_EVENT_PTRACE. Perhaps it makes more sense to
call proc_ptrace_connector() first, this also decreases the probability
PTRACE_ATTACH will be reported after PROC_EVENT_EXIT.


But once again, this is very minor and cosmetic. I am going to apply
the patch as is unless you send v3 quickly.

Oleg.

