From: Ingo Molnar <mingo@elte.hu>
Subject: Re: Receive side performance issue with multi-10-GigE and NUMA
Date: Wed, 26 Aug 2009 22:40:27 +0200
Message-ID: <20090826204027.GA21159@elte.hu>
References: <20090826181502.GC13632@elte.hu> <20090826190435.GC10816@hmsreliant.think-freely.org> <20090826190830.GF13632@elte.hu> <20090826.123631.79533250.davem@davemloft.net> <20090826194835.GA16508@elte.hu> <20090826202344.GE10816@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, rostedt@goodmis.org,
	fweisbec@gmail.com, billfink@mindspring.com,
	netdev@vger.kernel.org, brice@myri.com, gallatin@myri.com
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.mail.elte.hu ([157.181.1.138]:35340 "EHLO mx3.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751480AbZHZUkh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Aug 2009 16:40:37 -0400
Content-Disposition: inline
In-Reply-To: <20090826202344.GE10816@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Neil Horman <nhorman@tuxdriver.com> wrote:

> On Wed, Aug 26, 2009 at 09:48:35PM +0200, Ingo Molnar wrote:
> > 
> > * David Miller <davem@davemloft.net> wrote:
> > 
> > > From: Ingo Molnar <mingo@elte.hu>
> > > Date: Wed, 26 Aug 2009 21:08:30 +0200
> > > 
> > > > Sigh, no. Please re-read the past discussions about this. 
> > > > trace_skb_sources.c is a hack and should be converted to generic 
> > > > tracepoints. Is there anything in it that cannot be expressed in 
> > > > terms of TRACE_EVENT()?
> > > 
> > > Neil explained why he needed to implement it this way in his reply 
> > > to Steven Rostedt.  I attach it here for your convenience.
> > 
> > thanks. The argument is invalid:
> 
> Just because you assert that doesn't make it so, Ingo.

I stand by that statement, the argument is invalid, for the many 
reasons i outlined in my previous mails. (you'd have gotten those 
same arguments had you submitted that patch to the folks who 
maintain kernel/trace/)

> > > > BTW, why not just do this as events? Or was this just a easy way 
> > > > to communicate with the user space tools?
> > > 
> > > Thats exactly why I did it.  the idea is for me to now write a 
> > > user space tool that lets me analyze the events and ajust process 
> > > scheduling to optimize the rx path. Neil
> > 
> > All tooling (in fact _more_ tooling) can be done based on generic, 
> > TRACE_EVENT() based tracepoints. Generic tracepoints are far more 
> > available, have a generalized format with format parsers and user 
> > tooling implemented, etc. etc.
> 
> Then why allow for ftrace modules at all?  [...]

We routinely reject trivial plugins like yours and ask people to use 
the proper mechanism: TRACE_EVENT().

We are also converting non-trivial plugins to generic tracepoints. A 
recent example are the system call tracepoints, but we also 
converted blktrace and kmemtrace to generic tracepoints.

But trace_skb_sources.c got committed to the networking tree, 
without review and acks from the tracing folks. Now you are 
unwilling to fix it and that's not very constructive.

> [...] I grant that the skb ftracer is a bit trivial at the moment 
> for an ftrace module, but I really prefer to leave it is so that I 
> can expand it with additional tracepoints.  And looking at them, 
> anything you've said above applies to any of the currently 
> implemented ftrace modules.  If you're so adamant that we should 
> just do everything with TRACE_EVENT log messages, then lets get 
> rid of the ftrace infrastructure all together.  Until we do that, 
> however, I like my skb tracer just as it is.

You dont seem to be aware of the breath of features and capabilities 
that TRACE_EVENT() based tooling allows us to do. Please see my 
previous mail about an (incomplete) list.

( One item i forgot to mention there: using them you can for example 
  trace full workloads, such as a kernel build - without other 
  workloads mixed into that trace. Etc. etc. - the list goes on. )

	Ingo
