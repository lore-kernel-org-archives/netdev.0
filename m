From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all architectures
Date: Sat, 18 Aug 2007 14:54:09 -0700
Message-ID: <20070818215409.GC7628@linux.vnet.ibm.com>
References: <46C505B2.6030704@yahoo.com.au> <18117.4848.695269.72976@cargo.ozlabs.ibm.com> <46C516BA.60700@yahoo.com.au> <alpine.LFD.0.999.0708162045150.30176@woody.linux-foundation.org> <20070817235912.GA24314@linux.vnet.ibm.com> <20070818000913.GA25585@gondor.apana.org.au> <20070818010818.GQ8464@linux.vnet.ibm.com> <Pine.LNX.4.64.0708171817050.15427@schroedinger.engr.sgi.com> <alpine.LFD.0.999.0708180709060.3666@enigma.security.iitk.ac.in> <alpine.LFD.0.999.0708172110400.30176@woody.linux-foundation.org>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Satyam Sharma <satyam@infradead.org>,
	Christoph Lameter <clameter@sgi.com>,
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
Received: from e6.ny.us.ibm.com ([32.97.182.146]:41446 "EHLO e6.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757544AbXHRVyR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 18 Aug 2007 17:54:17 -0400
Content-Disposition: inline
In-Reply-To: <alpine.LFD.0.999.0708172110400.30176@woody.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 17, 2007 at 09:13:35PM -0700, Linus Torvalds wrote:
> 
> 
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
> 
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
> is just not a very good compiler. But when talking about "volatile", 
> that's exactly what ytou always get (and always have gotten - this is 
> not a regression, and I doubt gcc is alone in this).

One of the gcc guys claimed that he thought that the two-instruction
sequence would be faster on some x86 machines.  I pointed out that
there might be a concern about code size.  I chose not to point out
that people might also care about the other x86 machines.  ;-)

							Thanx, Paul
