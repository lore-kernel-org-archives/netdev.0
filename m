From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH v4 1/5] irq: add tracepoint to softirq_raise
Date: Fri, 03 Sep 2010 11:39:36 -0400
Message-ID: <1283528376.2356.436.camel@gandalf.stny.rr.com>
References: <4C72422C.5070102@jp.fujitsu.com>
	 <4C724298.4050509@jp.fujitsu.com>  <20100903152909.GA5352@nowhere>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-15"
Content-Transfer-Encoding: 7bit
Cc: Koki Sanagi <sanagi.koki@jp.fujitsu.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, davem@davemloft.net,
	kaneshige.kenji@jp.fujitsu.com, izumi.taku@jp.fujitsu.com,
	kosaki.motohiro@jp.fujitsu.com, nhorman@tuxdriver.com,
	laijs@cn.fujitsu.com, scott.a.mcmillan@intel.com,
	eric.dumazet@gmail.com, mathieu.desnoyers@polymtl.ca
To: Frederic Weisbecker <fweisbec@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100903152909.GA5352@nowhere>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2010-09-03 at 17:29 +0200, Frederic Weisbecker wrote:

> >  #define softirq_name(sirq) { sirq##_SOFTIRQ, #sirq }
> >  #define show_softirq_name(val)				\
> > @@ -93,7 +95,10 @@ DECLARE_EVENT_CLASS(softirq,
> >  	),
> >  
> >  	TP_fast_assign(
> > -		__entry->vec = (int)(h - vec);
> > +		if (vec)
> > +			__entry->vec = (int)(h - vec);
> > +		else
> > +			__entry->vec = *((int *)h);
> >  	),
> 
> 
> 
> It seems that this will break softirq_entry/exit tracepoints.
> __entry->vec will deref vec->action() for these two, which is not
> what we want.

But for trace_softirq_entry and trace_softirq_exit, vec will not be
NULL.


> 
> If you can't have the same tracepoint signature for the three, just
> split the new one in a seperate TRACE_EVENT().

It may be a bit of a hack, and questionable about adding another
TRACE_EVENT(). There still is a pretty good space savings in using
DEFINE_EVENT() over TRACE_EVENT() though.

-- Steve
