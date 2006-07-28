From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: Netchannles: first stage has been completed. Further ideas.
Date: Fri, 28 Jul 2006 14:49:24 +1000
Message-ID: <1154062165.5159.76.camel@localhost.localdomain>
References: <20060718081625.GA13830@2ka.mipt.ru>
	 <20060718230121.GA31474@ms2.inr.ac.ru>
	 <1153966671.6904.71.camel@localhost.localdomain>
	 <20060726.221708.123400049.davem@davemloft.net>
	 <1153979173.6904.100.camel@localhost.localdomain>
	 <20060727163335.GA12944@ms2.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, johnpol@2ka.mipt.ru,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.tip.net.au ([203.10.76.45]:57275 "EHLO ozlabs.org")
	by vger.kernel.org with ESMTP id S1751892AbWG1Eta (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Jul 2006 00:49:30 -0400
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
In-Reply-To: <20060727163335.GA12944@ms2.inr.ac.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-07-27 at 20:33 +0400, Alexey Kuznetsov wrote:
> Hello!
> 
> On Thu, Jul 27, 2006 at 03:46:12PM +1000, Rusty Russell wrote:
> > Of course, it means rewriting all the userspace tools, documentation,
> > and creating a complete new infrastructure for connection tracking and
> > NAT, but if that's what's required, then so be it.
> 
> That's what I love to hear. Not a joke. :-)
> 
> Could I only suggest not to relate this to netchannels? :-)
> In the past we used to call this thing (grand-unified) "flow cache".

Yes.  Thankyou for all your explanation, it was very helpful.  I agree,
grand unified lookup idea returns 8).  Netchannels proposal vs.
netfilter forced me back into thinking about it again, but it is
unrelated.  Any "netfilter bypass" acceleration will want similar ideas.

I apologize for misreading your discussion of Evgeniy's implementation
with general channel problem.  My mistake.  

> > userspace), no dequeue lock is required.
> 
> And that was a part of the second question.
> 
> I do not see, how single threaded TCP is possible. In receiver path
> it has to ack with quite strict time bounds, to delack etc., in sender path
> it has to slow start, I am even not saying about "slow path" things:
> retransmit, probing window, lingering without process context etc.
> It looks like, VJ implies the protocol must be changed. We can't, we mustn't.

All good points.  I can see two kinds of problems here: performance
problems due to wakeup (eg. ack processing for 5MB write), and
correctness problems due to no kernel enforcement.  We need measurements
for the performance issues, so I'll ignore them for the moment.

For correctness, in true end-to-end, kernel is just a router for
userspace, then we do not worry about such problems 8)  In real life
kernel must enforce linger and sending tuple correctness, but I don't
know how much else we must regulate.  Too much, and you are right: we
have slow and fast path split just like now.

> After we deidealize this idealization and recognize that some "slow path"
> should exist and some part of this "slow path" has to be executed
> with higher priority than the "fast" one, where do we arrive?
> Is not it exactly what we have right now? Clean fast path, separate slow path.
> Not good enough? Where? Let's find and fix this.

I am still not sure how significant slow path is: if 99% can be in
userspace, it could work very well for RDMA.  I would like to have seen
VJ's implementation so we could compare and steal bits.

Thanks,
Rusty.
-- 
Help! Save Australia from the worst of the DMCA: http://linux.org.au/law

