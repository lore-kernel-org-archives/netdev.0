From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: Netchannles: first stage has been completed. Further ideas.
Date: Thu, 27 Jul 2006 20:33:35 +0400
Message-ID: <20060727163335.GA12944@ms2.inr.ac.ru>
References: <20060718081625.GA13830@2ka.mipt.ru> <20060718230121.GA31474@ms2.inr.ac.ru> <1153966671.6904.71.camel@localhost.localdomain> <20060726.221708.123400049.davem@davemloft.net> <1153979173.6904.100.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, johnpol@2ka.mipt.ru,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from minus.inr.ac.ru ([194.67.69.97]:31189 "HELO ms2.inr.ac.ru")
	by vger.kernel.org with SMTP id S1750855AbWG0QeJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Jul 2006 12:34:09 -0400
To: Rusty Russell <rusty@rustcorp.com.au>
Content-Disposition: inline
In-Reply-To: <1153979173.6904.100.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

On Thu, Jul 27, 2006 at 03:46:12PM +1000, Rusty Russell wrote:
> Of course, it means rewriting all the userspace tools, documentation,
> and creating a complete new infrastructure for connection tracking and
> NAT, but if that's what's required, then so be it.

That's what I love to hear. Not a joke. :-)

Could I only suggest not to relate this to netchannels? :-)
In the past we used to call this thing (grand-unified) "flow cache".


> I don't think they are equivalent.  In channels,

I understand this. Actually, it was what I said in the next paragraph,
which you even cited.

I really do not like to repeat myself, it is nothing but idle talk,
but if the questions are questioned...

First, it was stated that suggested implementation performs better and even
much better. I am asking why do we see such improvement?
I am absolutely not satisifed with statement "It is better. Period."
>From all that I see, this particular implementation does not implement
optimizations suggested by VJ, it implements only the things,
which are not supposed to affect performance or to affect it negatively.

Idle talk? I am sure that if that improvement happened not due
to a severe protocol violation we can easily fix existing stack.


> userspace), no dequeue lock is required.

And that was a part of the second question.

I do not see, how single threaded TCP is possible. In receiver path
it has to ack with quite strict time bounds, to delack etc., in sender path
it has to slow start, I am even not saying about "slow path" things:
retransmit, probing window, lingering without process context etc.
It looks like, VJ implies the protocol must be changed. We can't, we mustn't.

After we deidealize this idealization and recognize that some "slow path"
should exist and some part of this "slow path" has to be executed
with higher priority than the "fast" one, where do we arrive?
Is not it exactly what we have right now? Clean fast path, separate slow path.
Not good enough? Where? Let's find and fix this.

Alexey
