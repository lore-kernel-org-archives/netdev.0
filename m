From: Satyam Sharma <satyam@infradead.org>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all
 architectures
Date: Fri, 17 Aug 2007 18:35:54 +0530 (IST)
Message-ID: <alpine.LFD.0.999.0708171822160.3666@enigma.security.iitk.ac.in>
References: <E1ILCgh-00052A-00@gondolin.me.apana.org.au> <46C32618.2080108@redhat.com>
 <20070815234021.GA28775@gondor.apana.org.au> <3694fb2e4ed1e4d9bf873c0d050c911e@kernel.crashing.org>
 <46C3B50E.7010702@yahoo.com.au> <194369f4c96ea0e24decf8f9197d5bad@kernel.crashing.org>
 <46C505B2.6030704@yahoo.com.au> <18117.4848.695269.72976@cargo.ozlabs.ibm.com>
 <alpine.LFD.0.999.0708162033400.30176@woody.linux-foundation.org>
 <alpine.LFD.0.999.0708171016160.3666@enigma.security.iitk.ac.in>
 <46C54D94.5080803@yahoo.com.au> <alpine.LFD.0.999.0708171358520.3666@enigma.security.iitk.ac.in>
 <46C56725.6000207@cyberone.com.au> <alpine.LFD.0.999.0708171505200.3666@enigma.security.iitk.ac.in>
 <46C5910A.6020904@cyberone.com.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=us-ascii
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Paul Mackerras <paulus@samba.org>,
	Segher Boessenkool <segher@kernel.crashing.org>,
	heiko.carstens@de.ibm.com, horms@verge.net.au,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	rpjday@mindspring.com, ak@suse.de, netdev@vger.kernel.org,
	cfriesen@nortel.com, Andrew Morton <akpm@linux-foundation.org>,
	jesper.juhl@gmail.com, linux-arch@vger.kernel.org, zlynx@acm.org,
	clameter@sgi.com, schwidefsky@de.ibm.com,
	Chris Snook <csnook@redhat.com>,
	Herbert Xu <herbert.xu@redhat.com>, davem@davemloft.net,
	wensong@linux-vs.org, wjiang@resilience.com
To: Nick Piggin <piggin@cyberone.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:53814 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752775AbXHQMxW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Aug 2007 08:53:22 -0400
In-Reply-To: <46C5910A.6020904@cyberone.com.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Fri, 17 Aug 2007, Nick Piggin wrote:

> Satyam Sharma wrote:
> [...]
> > You think both these are equivalent in terms of "looks":
> > 
> > 					|
> > while (!atomic_read(&v)) {		|	while (!atomic_read_xxx(&v)) {
> > 	...				|		...
> > 	cpu_relax_no_barrier();		|
> > cpu_relax_no_barrier();
> > 	order_atomic(&v);		|	}
> > }					|
> > 
> > (where order_atomic() is an atomic_t
> > specific wrapper as you mentioned below)
> > 
> > ?
> 
> I think the LHS is better if your atomic_read_xxx primitive is using the
> crazy one-sided barrier,
  ^^^^^

I'd say it's purposefully one-sided.

> because the LHS code you immediately know what
> barriers are happening, and with the RHS you have to look at the
> atomic_read_xxx
> definition.

No. As I said, the _xxx (whatever the heck you want to name it as) should
give the same heads-up that your "order_atomic" thing is supposed to give.


> If your atomic_read_xxx implementation was more intuitive, then both are
> pretty well equal. More lines != ugly code.
> 
> > [...]
> > What bugs?
> 
> You can't think for yourself? Your atomic_read_volatile contains a compiler
> barrier to the atomic variable before the load. 2 such reads from different
> locations look like this:
> 
> asm volatile("" : "+m" (v1));
> atomic_read(&v1);
> asm volatile("" : "+m" (v2));
> atomic_read(&v2);
> 
> Which implies that the load of v1 can be reordered to occur after the load
> of v2.

And how would that be a bug? (sorry, I really can't think for myself)


> > > Secondly, what sort of code would do such a thing?
> > 
> > See the nodemgr_host_thread() that does something similar, though not
> > exactly same.
> 
> I'm sorry, all this waffling about made up code which might do this and
> that is just a waste of time.

First, you could try looking at the code.

And by the way, as I've already said (why do *require* people to have to
repeat things to you?) this isn't even about only existing code.
