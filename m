From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC PATCH v3 1/5] irq: add tracepoint to softirq_raise
Date: Wed, 21 Jul 2010 22:01:34 +0900 (JST)
Message-ID: <20100721215836.86F9.A69D9226@jp.fujitsu.com>
References: <4C469A41.4020807@jp.fujitsu.com> <20100721111419.GB21259@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: kosaki.motohiro@jp.fujitsu.com,
	Koki Sanagi <sanagi.koki@jp.fujitsu.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	davem@davemloft.net, kaneshige.kenji@jp.fujitsu.com,
	izumi.taku@jp.fujitsu.com, laijs@cn.fujitsu.com,
	scott.a.mcmillan@intel.com, rostedt@goodmis.org,
	eric.dumazet@gmail.com, fweisbec@gmail.com,
	mathieu.desnoyers@polymtl.ca
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fgwmail6.fujitsu.co.jp ([192.51.44.36]:49647 "EHLO
	fgwmail6.fujitsu.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753336Ab0GUNBi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jul 2010 09:01:38 -0400
In-Reply-To: <20100721111419.GB21259@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > >>  #endif /*  _TRACE_IRQ_H */
> > >> diff --git a/kernel/softirq.c b/kernel/softirq.c
> > >> index 825e112..6790599 100644
> > >> --- a/kernel/softirq.c
> > >> +++ b/kernel/softirq.c
> > >> @@ -215,9 +215,9 @@ restart:
> > >>  			int prev_count = preempt_count();
> > >>  			kstat_incr_softirqs_this_cpu(h - softirq_vec);
> > >>  
> > >> -			trace_softirq_entry(h, softirq_vec);
> > >> +			trace_softirq_entry(h - softirq_vec);
> > >>  			h->action(h);
> > >> -			trace_softirq_exit(h, softirq_vec);
> > >> +			trace_softirq_exit(h - softirq_vec);
> > > 
> > > You're loosing information here by reducing the numbers of parameters in this
> > > tracepoint.  How many other tracepoint scripts rely on having both pointers
> > > handy?  Why not just do the pointer math inside your tracehook instead?
> > 
> > In __raise_softirq_irqoff macro there is no method to refer softirq_vec, so it
> > can't use softirq DECLARE_EVENT_CLASS as is.
> > Currently,  there is no script using softirq_entry or softirq_exit.
> > 
> That shouldn't matter, just pass in NULL for softirq_vec in
> __raise_softirq_irqoff as the second argument to the trace function.  You may
> need to fix up the class definition so that the assignment or printk doesn't try
> to dereference that pointer when its NULL, but thats easy enough, and it avoids
> breaking any other perf scripts floating out there.

please see 5 lines above. we already have 'h - softirq_vec' calculation in
this function. so, Sanagi-san's change don't makes any overhead.

So, if the overhead is zero, I'd prefer simplest tracepoint definition :)



