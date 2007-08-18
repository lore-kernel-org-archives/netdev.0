From: Satyam Sharma <satyam@infradead.org>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all
 architectures
Date: Sat, 18 Aug 2007 19:06:33 +0530 (IST)
Message-ID: <alpine.LFD.0.999.0708181853210.29105@enigma.security.iitk.ac.in>
References: <20070815234021.GA28775@gondor.apana.org.au>
 <3694fb2e4ed1e4d9bf873c0d050c911e@kernel.crashing.org> <46C3B50E.7010702@yahoo.com.au>
 <194369f4c96ea0e24decf8f9197d5bad@kernel.crashing.org> <46C505B2.6030704@yahoo.com.au>
 <18117.4848.695269.72976@cargo.ozlabs.ibm.com> <46C516BA.60700@yahoo.com.au>
 <alpine.LFD.0.999.0708162045150.30176@woody.linux-foundation.org>
 <20070817235912.GA24314@linux.vnet.ibm.com> <20070818000913.GA25585@gondor.apana.org.au>
 <20070818010818.GQ8464@linux.vnet.ibm.com> <Pine.LNX.4.64.0708171817050.15427@schroedinger.engr.sgi.com>
 <alpine.LFD.0.999.0708180709060.3666@enigma.security.iitk.ac.in>
 <alpine.LFD.0.999.0708172110400.30176@woody.linux-foundation.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=us-ascii
Cc: Christoph Lameter <clameter@sgi.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Nick Piggin <nickpiggin@yahoo.com.au>,
	Paul Mackerras <paulus@samba.org>,
	Segher Boessenkool <segher@kernel.crashing.org>,
	heiko.carstens@de.ibm.com, horms@verge.net.au,
	linux-kernel@vger.kernel.org, rpjday@mindspring.com, ak@suse.de,
	netdev@vger.kernel.org, cfriesen@nortel.com,
	akpm@linux-foundation.org, jesper.juhl@gmail.com,
	linux-arch@vger.kernel.org, zlynx@acm.org, schwidefsky@de.ibm.com,
	Chris Snook <csnook@redhat.com>, davem@davemloft.net,
	wensong@linux-vs.org, wjiang@resilience.com
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:45661 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750987AbXHRNYF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Aug 2007 09:24:05 -0400
In-Reply-To: <alpine.LFD.0.999.0708172110400.30176@woody.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Fri, 17 Aug 2007, Linus Torvalds wrote:

> On Sat, 18 Aug 2007, Satyam Sharma wrote:
> > 
> > No code does (or would do, or should do):
> > 
> > 	x.counter++;
> > 
> > on an "atomic_t x;" anyway.
> 
> That's just an example of a general problem.
> 
> No, you don't use "x.counter++". But you *do* use
> 
> 	if (atomic_read(&x) <= 1)
> 
> and loading into a register is stupid and pointless, when you could just 
> do it as a regular memory-operand to the cmp instruction.

True, but that makes this a bad/poor code generation issue with the
compiler, not something that affects the _correctness_ of atomic ops if
"volatile" is used for that counter object (as was suggested), because
we'd always use the atomic_inc() etc primitives to do increments, which
are always (should be!) implemented to be atomic.


> And as far as the compiler is concerned, the problem is the 100% same: 
> combining operations with the volatile memop.
> 
> The fact is, a compiler that thinks that
> 
> 	movl mem,reg
> 	cmpl $val,reg
> 
> is any better than
> 
> 	cmpl $val,mem
> 
> is just not a very good compiler.

Absolutely, this is definitely a bug report worth opening with gcc. And
what you've said to explain this previously sounds definitely correct --
seeing "volatile" for any access does appear to just scare the hell out
of gcc and makes it generate such (poor) code.


Satyam
