From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: Receive side performance issue with multi-10-GigE and NUMA
Date: Wed, 26 Aug 2009 18:39:22 -0400
Message-ID: <20090826223922.GA25318@hmsreliant.think-freely.org>
References: <20090826181502.GC13632@elte.hu> <20090826190435.GC10816@hmsreliant.think-freely.org> <20090826190830.GF13632@elte.hu> <20090826.123631.79533250.davem@davemloft.net> <20090826194835.GA16508@elte.hu> <20090826202344.GE10816@hmsreliant.think-freely.org> <20090826204027.GA21159@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, rostedt@goodmis.org,
	fweisbec@gmail.com, billfink@mindspring.com,
	netdev@vger.kernel.org, brice@myri.com, gallatin@myri.com
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:37301 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754186AbZHZWjc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Aug 2009 18:39:32 -0400
Content-Disposition: inline
In-Reply-To: <20090826204027.GA21159@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 26, 2009 at 10:40:27PM +0200, Ingo Molnar wrote:
> 
> * Neil Horman <nhorman@tuxdriver.com> wrote:
> 
> > On Wed, Aug 26, 2009 at 09:48:35PM +0200, Ingo Molnar wrote:
> > > 
> > > * David Miller <davem@davemloft.net> wrote:
> > > 
> > > > From: Ingo Molnar <mingo@elte.hu>
> > > > Date: Wed, 26 Aug 2009 21:08:30 +0200
> > > > 
> > > > > Sigh, no. Please re-read the past discussions about this. 
> > > > > trace_skb_sources.c is a hack and should be converted to generic 
> > > > > tracepoints. Is there anything in it that cannot be expressed in 
> > > > > terms of TRACE_EVENT()?
> > > > 
> > > > Neil explained why he needed to implement it this way in his reply 
> > > > to Steven Rostedt.  I attach it here for your convenience.
> > > 
> > > thanks. The argument is invalid:
> > 
> > Just because you assert that doesn't make it so, Ingo.
> 
> I stand by that statement, the argument is invalid, for the many 
> reasons i outlined in my previous mails. (you'd have gotten those 
> same arguments had you submitted that patch to the folks who 
> maintain kernel/trace/)
> 
Steven specifically told me to submit the patch to the subsystem maintainer that
I'm adding tracepoints for, and the only feedback I got on it was his one
question, the answer to which I assume satisfied him, due to that there was no
subseuqent discussion.  I'm going to ignore your previous emails, because,
despite the various advantages of just using plain TRACE_EVENTs because you
provide the ftrace interface, and I found it useful.  Your observation is
correct, I like it, and thats what I wanted to use, so I used it.  If you don't
want people to use it, don't provide it.

> > > > > BTW, why not just do this as events? Or was this just a easy way 
> > > > > to communicate with the user space tools?
> > > > 
> > > > Thats exactly why I did it.  the idea is for me to now write a 
> > > > user space tool that lets me analyze the events and ajust process 
> > > > scheduling to optimize the rx path. Neil
> > > 
> > > All tooling (in fact _more_ tooling) can be done based on generic, 
> > > TRACE_EVENT() based tracepoints. Generic tracepoints are far more 
> > > available, have a generalized format with format parsers and user 
> > > tooling implemented, etc. etc.
> > 
> > Then why allow for ftrace modules at all?  [...]
> 
> We routinely reject trivial plugins like yours and ask people to use 
> the proper mechanism: TRACE_EVENT().
> 
Again, if you consider there to only be one proper mechanism here, don't provide
others.

> We are also converting non-trivial plugins to generic tracepoints. A 
> recent example are the system call tracepoints, but we also 
> converted blktrace and kmemtrace to generic tracepoints.
> 
If you're getting rid of ftrace, then fine, just say so.  If the interface I
chose is getting removed, I'll change it.  But I'm not going to change it just
because you're going around saying my previous work sucks.  Theres nothing wrong
with it, it works quite well right now as it is.

> But trace_skb_sources.c got committed to the networking tree, 
> without review and acks from the tracing folks. Now you are 
> unwilling to fix it and that's not very constructive.
> 
I'm not willing to fix it because its not broken.  I submitted it where steven
suggested that I submitted it, and the reviews that I got were positive.  All
you've told me is that you think theres a better way.  Its fine if theres a
better way, but the way I have currently is sufficient.  I have acutal bugs to
fix.  Rewriting this to suit your opinions after the fact really isn't
productive for me.

> > [...] I grant that the skb ftracer is a bit trivial at the moment 
> > for an ftrace module, but I really prefer to leave it is so that I 
> > can expand it with additional tracepoints.  And looking at them, 
> > anything you've said above applies to any of the currently 
> > implemented ftrace modules.  If you're so adamant that we should 
> > just do everything with TRACE_EVENT log messages, then lets get 
> > rid of the ftrace infrastructure all together.  Until we do that, 
> > however, I like my skb tracer just as it is.
> 
> You dont seem to be aware of the breath of features and capabilities 
> that TRACE_EVENT() based tooling allows us to do. Please see my 
> previous mail about an (incomplete) list.
> 
Fine, I grant you that TRACE_EVENT might provide great advantages over an ftrace
module.  What you seem to be missing is that an ftrace module is sufficnet for
the needs of what I was tracing.


Ok, I'm rather tired of arguing.  Dave, I'll leave this in your hands.  The code
I wrote works fairly well in my view, and I feel like the review on it was both
positive and sufficent for inclusion.  But thats not my call, its yours.  I can
meet my own need with a raw TRACE_EVENT for now just as easily.  IF you feel
like the skb plugin should be pulled, please do so, and let me know.  All I ask
is that you keep the skb_copy_datagram_iovec TRACE_EVENT in place.  If you pull
the ftrace plugin, I'll submit a subsequent patch to agument the printing format
so that I can gather the numa allocation and consumption data directly there.

Regards
Neil


