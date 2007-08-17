From: Satyam Sharma <satyam@infradead.org>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all
 architectures
Date: Sat, 18 Aug 2007 05:25:41 +0530 (IST)
Message-ID: <alpine.LFD.0.999.0708180522120.3666@enigma.security.iitk.ac.in>
References: <20070816003948.GY9645@linux.vnet.ibm.com>
 <Pine.LNX.4.64.0708151740570.10497@schroedinger.engr.sgi.com>
 <18115.44462.622801.683446@cargo.ozlabs.ibm.com> <20070816020042.GA30650@gondor.apana.org.au>
 <18115.45316.702491.681906@cargo.ozlabs.ibm.com>
 <alpine.LFD.0.999.0708160800130.24380@enigma.security.iitk.ac.in>
 <alpine.LFD.0.999.0708160815510.24380@enigma.security.iitk.ac.in>
 <18115.52863.638655.658466@cargo.ozlabs.ibm.com> <20070816053945.GB32442@gondor.apana.org.au>
 <18115.62741.807704.969977@cargo.ozlabs.ibm.com> <20070816070907.GA964@gondor.apana.org.au>
 <Pine.LNX.4.64.0708161743500.13267@kivilampi-30.cs.helsinki.fi>
 <46C4ABA5.9010804@redhat.com> <Pine.LNX.4.64.0708161319000.17777@schroedinger.engr.sgi.com>
 <c298f0e3f9e49c9dd2d326115d156084@kernel.crashing.org>
 <alpine.LFD.0.999.0708180002290.3666@enigma.security.iitk.ac.in>
 <a51ab88dc00f8d7fd44f79400671d259@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=us-ascii
Cc: Christoph Lameter <clameter@sgi.com>,
	Paul Mackerras <paulus@samba.org>, heiko.carstens@de.ibm.com,
	horms@verge.net.au, Stefan Richter <stefanr@s5r6.in-berlin.de>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	=?iso-8859-15?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	ak@suse.de, cfriesen@nortel.com, rpjday@mindspring.com,
	Netdev <netdev@vger.kernel.org>, jesper.juhl@gmail.com,
	linux-arch@vger.kernel.org, zlynx@acm.org,
	Andrew Morton <akpm@linux-foundation.org>,
	schwidefsky@de.ibm.com, Chris Snook <csnook@redhat.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	wensong@linux-vs.org, wjiang@resilience.com
To: Segher Boessenkool <segher@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:39097 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751966AbXHQXnN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Aug 2007 19:43:13 -0400
In-Reply-To: <a51ab88dc00f8d7fd44f79400671d259@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Sat, 18 Aug 2007, Segher Boessenkool wrote:

> > > > No it does not have any volatile semantics. atomic_dec() can be
> > > > reordered
> > > > at will by the compiler within the current basic unit if you do not add
> > > > a
> > > > barrier.
> > > 
> > > "volatile" has nothing to do with reordering.
> > 
> > If you're talking of "volatile" the type-qualifier keyword, then
> > http://lkml.org/lkml/2007/8/16/231 (and sub-thread below it) shows
> > otherwise.
> 
> I'm not sure what in that mail you mean, but anyway...
> 
> Yes, of course, the fact that "volatile" creates a side effect
> prevents certain things from being reordered wrt the atomic_dec();
> but the atomic_dec() has a side effect *already* so the volatile
> doesn't change anything.

That's precisely what that sub-thread (read down to the last mail
there, and not the first mail only) shows. So yes, "volatile" does
have something to do with re-ordering (as guaranteed by the C
standard).


> > > atomic_dec() writes
> > > to memory, so it _does_ have "volatile semantics", implicitly, as
> > > long as the compiler cannot optimise the atomic variable away
> > > completely -- any store counts as a side effect.
> > 
> > I don't think an atomic_dec() implemented as an inline "asm volatile"
> > or one that uses a "forget" macro would have the same re-ordering
> > guarantees as an atomic_dec() that uses a volatile access cast.
> 
> The "asm volatile" implementation does have exactly the same
> reordering guarantees as the "volatile cast" thing,

I don't think so.

> if that is
> implemented by GCC in the "obvious" way.  Even a "plain" asm()
> will do the same.

Read the relevant GCC documentation.

[ of course, if the (latest) GCC documentation is *yet again*
  wrong, then alright, not much I can do about it, is there. ]
