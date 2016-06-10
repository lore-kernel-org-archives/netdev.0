From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: Re: [PATCH][RT] netpoll: Always take poll_lock when doing polling
Date: Fri, 10 Jun 2016 18:20:22 +0200
Message-ID: <8582eb37-3b5b-ee7e-3a67-8f4609b0ac3f@linutronix.de>
References: <20160526195641.6c26e979@gandalf.local.home>
 <20160602161235.GA12971@linutronix.de>
 <20160604071131.08d449db@grimm.local.home>
 <20160610155717.GB10775@linutronix.de>
 <20160610121118.03f281e8@gandalf.local.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: alison@peloton-tech.com, LKML <linux-kernel@vger.kernel.org>,
	linux-rt-users <linux-rt-users@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	Peter Zijlstra <peterz@infradead.org>,
	Clark Williams <williams@redhat.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>
To: Steven Rostedt <rostedt@goodmis.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.linutronix.de ([62.245.132.108]:37737 "EHLO
	Galois.linutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751266AbcFJQUf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jun 2016 12:20:35 -0400
In-Reply-To: <20160610121118.03f281e8@gandalf.local.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/10/2016 06:11 PM, Steven Rostedt wrote:
>> It is true that in RT we don't have such a limit like in !RT. You would
>> need to use __raise_softirq_irqoff_ksoft() instead the normal or +
>> wakeup() since you may have timers pending and those need to go to the
>> "other" ksoftirqd.
>> But then I don't see much change. ksoftirqd runs now at SCHED_OTHER so
>> it will end up on the CPU right away unless there other tasks that need
>> the CPU. So the scheduler will balance it the same way. The only change
>> will be that softirqs which are processed in context of any application
>> for more than two jiffies will be moved to ksoftirqd. This could be a
>> win.
> 
> We actually triggered a starvation due to this. I was just seeing if
> Alison hit the same issue we did in our tests.

Okay. Didn't get this information from him. But this is only because
the softirqs not running in ksoftirqd, right?

> -- Steve
> 
Sebastian
