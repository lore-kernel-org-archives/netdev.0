From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH][RT] netpoll: Always take poll_lock when doing polling
Date: Fri, 10 Jun 2016 12:11:18 -0400
Message-ID: <20160610121118.03f281e8@gandalf.local.home>
References: <20160526195641.6c26e979@gandalf.local.home>
	<20160602161235.GA12971@linutronix.de>
	<20160604071131.08d449db@grimm.local.home>
	<20160610155717.GB10775@linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: alison@peloton-tech.com, LKML <linux-kernel@vger.kernel.org>,
	linux-rt-users <linux-rt-users@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	Peter Zijlstra <peterz@infradead.org>,
	Clark Williams <williams@redhat.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>
To: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0050.hostedemail.com ([216.40.44.50]:34089 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752963AbcFJQLX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jun 2016 12:11:23 -0400
In-Reply-To: <20160610155717.GB10775@linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 10 Jun 2016 17:57:17 +0200
Sebastian Andrzej Siewior <bigeasy@linutronix.de> wrote:

> * Steven Rostedt | 2016-06-04 07:11:31 [-0400]:
> 
> >From: Steven Rostedt <srostedt@redhat.com>
> >Date: Tue, 5 Jan 2016 14:53:09 -0500
> >Subject: [PATCH] softirq: Perform softirqs in local_bh_enable() for a limited
> > amount of time
> >
> >To prevent starvation of tasks like ksoftirqd, if the task that is
> >processing its softirqs takes more than 2 jiffies to do so, and the
> >softirqs are constantly being re-added, then defer the processing to
> >ksoftirqd.  
> 
> I'm not sure about this. Alison didn't scream "yes it solves my problem"
> and I am not sure what it is.
> It is true that in RT we don't have such a limit like in !RT. You would
> need to use __raise_softirq_irqoff_ksoft() instead the normal or +
> wakeup() since you may have timers pending and those need to go to the
> "other" ksoftirqd.
> But then I don't see much change. ksoftirqd runs now at SCHED_OTHER so
> it will end up on the CPU right away unless there other tasks that need
> the CPU. So the scheduler will balance it the same way. The only change
> will be that softirqs which are processed in context of any application
> for more than two jiffies will be moved to ksoftirqd. This could be a
> win.

We actually triggered a starvation due to this. I was just seeing if
Alison hit the same issue we did in our tests.

-- Steve
