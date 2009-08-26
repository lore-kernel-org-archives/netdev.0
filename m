From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: Receive side performance issue with multi-10-GigE and NUMA
Date: Wed, 26 Aug 2009 19:23:04 -0400
Message-ID: <20090826232304.GB25980@hmsreliant.think-freely.org>
References: <20090826202344.GE10816@hmsreliant.think-freely.org> <20090826204027.GA21159@elte.hu> <20090826223922.GA25318@hmsreliant.think-freely.org> <20090826.154410.95005620.davem@davemloft.net> <alpine.DEB.2.00.0908261901270.11291@gandalf.stny.rr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, Ingo Molnar <mingo@elte.hu>,
	Frederic Weisbecker <fweisbec@gmail.com>,
	billfink@mindspring.com, netdev@vger.kernel.org, brice@myri.com,
	gallatin@myri.com
To: Steven Rostedt <rostedt@goodmis.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:50400 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754019AbZHZXXI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Aug 2009 19:23:08 -0400
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.0908261901270.11291@gandalf.stny.rr.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 26, 2009 at 07:05:20PM -0400, Steven Rostedt wrote:
> 
> On Wed, 26 Aug 2009, David Miller wrote:
> 
> > From: Neil Horman <nhorman@tuxdriver.com>
> > Date: Wed, 26 Aug 2009 18:39:22 -0400
> > 
> > > Ok, I'm rather tired of arguing.  Dave, I'll leave this in your hands.
> > 
> > I've gotten this kind of urging, both in private and in public, from
> > both of you now.  And I'm sorry, that's not how this works.
> > 
> > It is not my job to somehow force you turkeys how to work effectively
> > together. :-)
> > 
> > What we can do is ask Mr. Rostedt to asses the situation and give
> > his feedback.
> > 
> > So if Steven could give some feedback about this specific situation
> > that would be great and might help us move forward.
> 
> OK, here's my thought on the matter.
> 
> How about Neil try out doing all he can with the existing TRACE_EVENT 
> work. I'm sure Ingo and myself would be fine with helping him with any 
> issues he comes up with. If there is something that he hates about it, 
> that really makes his user space code messy, then he can put the ball back 
> in our court, and Ingo and I will need to come up with a solution.
> 
> If we truly hit a show stopper, than we can always fall back to the ftrace 
> plugin. But until we find out for sure that TRACE_EVENT is not good 
> enough, then we should try that out.
> 
> How's that sound?
> 

Ok, thats fine by me.  I really don't have any oposition to just using raw
TRACE_EVENTS for my current purposes, but as Ingo's previous mail shows, theres
_alot_ to it.  Using the ftrace interface was really, in the end, just simpler
for me.  But if just using TRACE_EVENT is the way it needs to be, so be it.

Dave, would you please revert commit 9ec04da7489d2c9ae01ea6e9b5fa313ccf3d35fb
and 5a165657bef7c47e5ff4cd138f7758ef6278e87b?  That should remove the ftrace
code, and leave the TRACE_EVENT tracepoint for skb_copy_datagram_to_iovec in
place.  I'll submit a patch in the next few days to augment the TRACE_EVENT
format to export all the data that I need.

Thanks!
Neil

> -- Steve
> 
> 
