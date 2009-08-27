From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: Receive side performance issue with multi-10-GigE and NUMA
Date: Wed, 26 Aug 2009 20:14:26 -0400
Message-ID: <20090827001426.GA26475@hmsreliant.think-freely.org>
References: <20090826181502.GC13632@elte.hu> <20090826190435.GC10816@hmsreliant.think-freely.org> <20090826190830.GF13632@elte.hu> <20090826.123631.79533250.davem@davemloft.net> <20090826194835.GA16508@elte.hu> <20090826202344.GE10816@hmsreliant.think-freely.org> <20090826204027.GA21159@elte.hu> <20090826223922.GA25318@hmsreliant.think-freely.org> <alpine.DEB.2.00.0908261913030.11291@gandalf.stny.rr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ingo Molnar <mingo@elte.hu>, David Miller <davem@davemloft.net>,
	fweisbec@gmail.com, billfink@mindspring.com,
	netdev@vger.kernel.org, brice@myri.com, gallatin@myri.com
To: Steven Rostedt <rostedt@goodmis.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:42966 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750761AbZH0AOi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Aug 2009 20:14:38 -0400
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.0908261913030.11291@gandalf.stny.rr.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 26, 2009 at 07:33:55PM -0400, Steven Rostedt wrote:
> 
> On Wed, 26 Aug 2009, Neil Horman wrote:
> 
> > On Wed, Aug 26, 2009 at 10:40:27PM +0200, Ingo Molnar wrote:
> > > 
> > > * Neil Horman <nhorman@tuxdriver.com> wrote:
> > > 
> > > > On Wed, Aug 26, 2009 at 09:48:35PM +0200, Ingo Molnar wrote:
> > > > > 
> > > > > * David Miller <davem@davemloft.net> wrote:
> > > > > 
> > > > > > From: Ingo Molnar <mingo@elte.hu>
> > > > > > Date: Wed, 26 Aug 2009 21:08:30 +0200
> > > > > > 
> > > > > > > Sigh, no. Please re-read the past discussions about this. 
> > > > > > > trace_skb_sources.c is a hack and should be converted to generic 
> > > > > > > tracepoints. Is there anything in it that cannot be expressed in 
> > > > > > > terms of TRACE_EVENT()?
> > > > > > 
> > > > > > Neil explained why he needed to implement it this way in his reply 
> > > > > > to Steven Rostedt.  I attach it here for your convenience.
> > > > > 
> > > > > thanks. The argument is invalid:
> > > > 
> > > > Just because you assert that doesn't make it so, Ingo.
> > > 
> > > I stand by that statement, the argument is invalid, for the many 
> > > reasons i outlined in my previous mails. (you'd have gotten those 
> > > same arguments had you submitted that patch to the folks who 
> > > maintain kernel/trace/)
> > > 
> 
> > Steven specifically told me to submit the patch to the subsystem maintainer that
> > I'm adding tracepoints for, and the only feedback I got on it was his one
> > question, the answer to which I assume satisfied him, due to that there was no
> > subseuqent discussion.  I'm going to ignore your previous emails, because,
> > despite the various advantages of just using plain TRACE_EVENTs because you
> > provide the ftrace interface, and I found it useful.  Your observation is
> > correct, I like it, and thats what I wanted to use, so I used it.  If you don't
> > want people to use it, don't provide it.
> 
> Actually, I suggested to submit it to the subsystem maintainer if there 
> was no changes to the tracing infrastructure. We may have just had a 
> misunderstanding there. No biggy.
> 
I'm not sure how the addition of an ftrace module constitutes a change to the
tracing infrastructure, but whatever, yes, no biggy.  I've bugun modifying the
TRACE_EVENT that I added to export the data I need directly.  Should be pretty
straightforward.  Dave I'll have a patch up on netdev in a day or two after I
test it.  Steven, should this still just go to netdev with a cc to you?  I'd
like to avoid repeating the same confusion here a second time around if I can

> > 
> > Ok, I'm rather tired of arguing.  Dave, I'll leave this in your hands.  The code
> > I wrote works fairly well in my view, and I feel like the review on it was both
> > positive and sufficent for inclusion.  But thats not my call, its yours.  I can
> > meet my own need with a raw TRACE_EVENT for now just as easily.  IF you feel
> > like the skb plugin should be pulled, please do so, and let me know.  All I ask
> > is that you keep the skb_copy_datagram_iovec TRACE_EVENT in place.  If you pull
> > the ftrace plugin, I'll submit a subsequent patch to agument the printing format
> > so that I can gather the numa allocation and consumption data directly there.
> 
> Yes, please keep the TRACE_EVENT (I think we can all agree on that ;-).
> 
Yes, that is rather centeral to what I'm monitoring :)

> You probably already read my previous email on the matter. Don't delete 
> your plugin patch until we get everything you need with TRACE_EVENT alone.
> 
Its ok, I should have the TRACE_EVENT modified to export this stuff directly by
tomorrow or friday anyway.  I really honestly just liked the ftrace interface
better, I found it a bit less confusing :)

Best
Neil

> Thanks,
> 
> -- Steve
> 
> 
