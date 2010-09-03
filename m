From: Frederic Weisbecker <fweisbec@gmail.com>
Subject: Re: [PATCH v4 1/5] irq: add tracepoint to softirq_raise
Date: Fri, 3 Sep 2010 17:42:08 +0200
Message-ID: <20100903154206.GB5352@nowhere>
References: <4C72422C.5070102@jp.fujitsu.com> <4C724298.4050509@jp.fujitsu.com> <20100903152909.GA5352@nowhere> <1283528376.2356.436.camel@gandalf.stny.rr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Koki Sanagi <sanagi.koki@jp.fujitsu.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, davem@davemloft.net,
	kaneshige.kenji@jp.fujitsu.com, izumi.taku@jp.fujitsu.com,
	kosaki.motohiro@jp.fujitsu.com, nhorman@tuxdriver.com,
	laijs@cn.fujitsu.com, scott.a.mcmillan@intel.com,
	eric.dumazet@gmail.com, mathieu.desnoyers@polymtl.ca
To: Steven Rostedt <rostedt@goodmis.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1283528376.2356.436.camel@gandalf.stny.rr.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 03, 2010 at 11:39:36AM -0400, Steven Rostedt wrote:
> On Fri, 2010-09-03 at 17:29 +0200, Frederic Weisbecker wrote:
> 
> > >  #define softirq_name(sirq) { sirq##_SOFTIRQ, #sirq }
> > >  #define show_softirq_name(val)				\
> > > @@ -93,7 +95,10 @@ DECLARE_EVENT_CLASS(softirq,
> > >  	),
> > >  
> > >  	TP_fast_assign(
> > > -		__entry->vec = (int)(h - vec);
> > > +		if (vec)
> > > +			__entry->vec = (int)(h - vec);
> > > +		else
> > > +			__entry->vec = *((int *)h);
> > >  	),
> > 
> > 
> > 
> > It seems that this will break softirq_entry/exit tracepoints.
> > __entry->vec will deref vec->action() for these two, which is not
> > what we want.
> 
> But for trace_softirq_entry and trace_softirq_exit, vec will not be
> NULL.


Oh right...

/me slaps his forehead


 
> 
> > 
> > If you can't have the same tracepoint signature for the three, just
> > split the new one in a seperate TRACE_EVENT().
> 
> It may be a bit of a hack, and questionable about adding another
> TRACE_EVENT(). There still is a pretty good space savings in using
> DEFINE_EVENT() over TRACE_EVENT() though.


Yeah, let's keep it as is.
