From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all
 architectures
Date: Fri, 17 Aug 2007 18:24:15 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0708171817050.15427@schroedinger.engr.sgi.com>
References: <20070815234021.GA28775@gondor.apana.org.au>
 <3694fb2e4ed1e4d9bf873c0d050c911e@kernel.crashing.org> <46C3B50E.7010702@yahoo.com.au>
 <194369f4c96ea0e24decf8f9197d5bad@kernel.crashing.org> <46C505B2.6030704@yahoo.com.au>
 <18117.4848.695269.72976@cargo.ozlabs.ibm.com> <46C516BA.60700@yahoo.com.au>
 <alpine.LFD.0.999.0708162045150.30176@woody.linux-foundation.org>
 <20070817235912.GA24314@linux.vnet.ibm.com> <20070818000913.GA25585@gondor.apana.org.au>
 <20070818010818.GQ8464@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Nick Piggin <nickpiggin@yahoo.com.au>,
	Paul Mackerras <paulus@samba.org>,
	Segher Boessenkool <segher@kernel.crashing.org>,
	heiko.carstens@de.ibm.com, horms@verge.net.au,
	linux-kernel@vger.kernel.org, rpjday@mindspring.com, ak@suse.de,
	netdev@vger.kernel.org, cfriesen@nortel.com,
	akpm@linux-foundation.org, jesper.juhl@gmail.com,
	linux-arch@vger.kernel.org, zlynx@acm.org, satyam@infradead.org,
	schwidefsky@de.ibm.com, Chris Snook <csnook@redhat.com>,
	davem@davemloft.net, wensong@linux-vs.org, wjiang@resilience.com
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from netops-testserver-3-out.sgi.com ([192.48.171.28]:33480 "EHLO
	relay.sgi.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751522AbXHRBYT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Aug 2007 21:24:19 -0400
In-Reply-To: <20070818010818.GQ8464@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 17 Aug 2007, Paul E. McKenney wrote:

> On Sat, Aug 18, 2007 at 08:09:13AM +0800, Herbert Xu wrote:
> > On Fri, Aug 17, 2007 at 04:59:12PM -0700, Paul E. McKenney wrote:
> > >
> > > gcc bugzilla bug #33102, for whatever that ends up being worth.  ;-)
> > 
> > I had totally forgotten that I'd already filed that bug more
> > than six years ago until they just closed yours as a duplicate
> > of mine :)
> > 
> > Good luck in getting it fixed!
> 
> Well, just got done re-opening it for the third time.  And a local
> gcc community member advised me not to give up too easily.  But I
> must admit that I am impressed with the speed that it was identified
> as duplicate.
> 
> Should be entertaining!  ;-)

Right. ROTFL... volatile actually breaks atomic_t instead of making it 
safe. x++ becomes a register load, increment and a register store. Without 
volatile we can increment the memory directly. It seems that volatile 
requires that the variable is loaded into a register first and then 
operated upon. Understandable when you think about volatile being used to 
access memory mapped I/O registers where a RMW operation could be 
problematic.

See http://gcc.gnu.org/bugzilla/show_bug.cgi?id=3506
