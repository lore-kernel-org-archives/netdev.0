From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: Receive side performance issue with multi-10-GigE and NUMA
Date: Wed, 26 Aug 2009 20:29:59 -0400 (EDT)
Message-ID: <alpine.DEB.2.00.0908262021300.18923@gandalf.stny.rr.com>
References: <20090826181502.GC13632@elte.hu> <20090826190435.GC10816@hmsreliant.think-freely.org> <20090826190830.GF13632@elte.hu> <20090826.123631.79533250.davem@davemloft.net> <20090826194835.GA16508@elte.hu> <20090826202344.GE10816@hmsreliant.think-freely.org>
 <20090826204027.GA21159@elte.hu> <20090826223922.GA25318@hmsreliant.think-freely.org> <alpine.DEB.2.00.0908261913030.11291@gandalf.stny.rr.com> <20090827001426.GA26475@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Ingo Molnar <mingo@elte.hu>, David Miller <davem@davemloft.net>,
	fweisbec@gmail.com, billfink@mindspring.com,
	netdev@vger.kernel.org, brice@myri.com, gallatin@myri.com
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hrndva-omtalb.mail.rr.com ([71.74.56.123]:36977 "EHLO
	hrndva-omtalb.mail.rr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754279AbZH0AaA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Aug 2009 20:30:00 -0400
In-Reply-To: <20090827001426.GA26475@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Wed, 26 Aug 2009, Neil Horman wrote:
> > 
> I'm not sure how the addition of an ftrace module constitutes a change to the
> tracing infrastructure, but whatever, yes, no biggy.  I've bugun modifying the
> TRACE_EVENT that I added to export the data I need directly.  Should be pretty
> straightforward.  Dave I'll have a patch up on netdev in a day or two after I
> test it.  Steven, should this still just go to netdev with a cc to you?  I'd
> like to avoid repeating the same confusion here a second time around if I can

Yes, please Cc myself, and Ingo on those changes. I see where the 
confusion came. It is where the code changes. The code in kernel/trace is 
considered ftrace internals (there's internal tracing upkeep that is 
needed for all plugins). But with TRACE_EVENT, those can happen totally 
inside a subsystem without touching any tracing directory. Those are 
yours, and the TRACE_EVENT is just an API to the rest of the kernel. We 
don't even care if you add a header to include/trace/events/ (if it 
follows the standard format).

But by adding a plugin, it causes more work for us. The plugin types do 
not get automated like TRACE_EVENTs and for binary readers like perf and 
trace-cmd, we need to hand export the binary format for them.

> 
> > > 
> > > Ok, I'm rather tired of arguing.  Dave, I'll leave this in your hands.  The code
> > > I wrote works fairly well in my view, and I feel like the review on it was both
> > > positive and sufficent for inclusion.  But thats not my call, its yours.  I can
> > > meet my own need with a raw TRACE_EVENT for now just as easily.  IF you feel
> > > like the skb plugin should be pulled, please do so, and let me know.  All I ask
> > > is that you keep the skb_copy_datagram_iovec TRACE_EVENT in place.  If you pull
> > > the ftrace plugin, I'll submit a subsequent patch to agument the printing format
> > > so that I can gather the numa allocation and consumption data directly there.
> > 
> > Yes, please keep the TRACE_EVENT (I think we can all agree on that ;-).
> > 
> Yes, that is rather centeral to what I'm monitoring :)
> 
> > You probably already read my previous email on the matter. Don't delete 
> > your plugin patch until we get everything you need with TRACE_EVENT alone.
> > 
> Its ok, I should have the TRACE_EVENT modified to export this stuff directly by
> tomorrow or friday anyway.  I really honestly just liked the ftrace interface
> better, I found it a bit less confusing :)

Heh, because it was just a bit of cut and paste. But as Frederic said, 
very much prone to errors. And it breaks the binary userspace readers. 
Your new type did not get exported via trace_export.c.

TRACE_EVENT can be a little harder to learn, because it is all MACRO 
magic, but once you understand them, you'll find that they are very easy.

Thanks!

-- Steve

