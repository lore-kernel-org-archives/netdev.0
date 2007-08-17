From: Satyam Sharma <satyam@infradead.org>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all
 architectures
Date: Fri, 17 Aug 2007 16:25:14 +0530 (IST)
Message-ID: <alpine.LFD.0.999.0708171612440.3666@enigma.security.iitk.ac.in>
References: <18115.52863.638655.658466@cargo.ozlabs.ibm.com>
 <20070816053945.GB32442@gondor.apana.org.au> <18115.62741.807704.969977@cargo.ozlabs.ibm.com>
 <20070816070907.GA964@gondor.apana.org.au>
 <Pine.LNX.4.64.0708161743500.13267@kivilampi-30.cs.helsinki.fi>
 <46C4ABA5.9010804@redhat.com> <Pine.LNX.4.64.0708161319000.17777@schroedinger.engr.sgi.com>
 <18117.1287.779351.836552@cargo.ozlabs.ibm.com>
 <alpine.LFD.0.999.0708161953310.30176@woody.linux-foundation.org>
 <18117.6495.397597.582736@cargo.ozlabs.ibm.com> <20070817035342.GA14744@gondor.apana.org.au>
 <alpine.LFD.0.999.0708171142550.3666@enigma.security.iitk.ac.in>
 <46C55E90.7010407@yahoo.com.au> <alpine.LFD.0.999.0708171431150.3666@enigma.security.iitk.ac.in>
 <46C56ADF.8010501@cyberone.com.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Paul Mackerras <paulus@samba.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Christoph Lameter <clameter@sgi.com>,
	Chris Snook <csnook@redhat.com>,
	Ilpo Jarvinen <ilpo.jarvinen@helsinki.fi>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Stefan Richter <stefanr@s5r6.in-berlin.de>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-arch@vger.kernel.org, Netdev <netdev@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>, ak@suse.de,
	heiko.carstens@de.ibm.com, David Miller <davem@davemloft.net>,
	schwidefsky@de.ibm.com, wensong@linux-vs.org, horms@verge.net.au,
	wjiang@resilience.com, cfriesen@nortel.com, zlynx@acm.org,
	rpjday@mindspring.com, jesper.juhl@gmail.com,
	segher@kernel.crashing.org
To: Nick Piggin <piggin@cyberone.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:52087 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753361AbXHQKnl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Aug 2007 06:43:41 -0400
In-Reply-To: <46C56ADF.8010501@cyberone.com.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Fri, 17 Aug 2007, Nick Piggin wrote:

> Satyam Sharma wrote:
> > [...]
> > The point is about *author expecations*. If people do expect atomic_read()
> > (or a variant thereof) to have volatile semantics, why not give them such
> > a variant?
> 
> Because they should be thinking about them in terms of barriers, over
> which the compiler / CPU is not to reorder accesses or cache memory
> operations, rather than "special" "volatile" accesses.

This is obviously just a taste thing. Whether to have that forget(x)
barrier as something author should explicitly sprinkle appropriately
in appropriate places in the code by himself or use a primitive that
includes it itself.

I'm not saying "taste matters aren't important" (they are), but I'm really
skeptical if most folks would find the former tasteful.

> > And by the way, the point is *also* about the fact that cpu_relax(), as
> > of today, implies a full memory clobber, which is not what a lot of such
> > loops want. (due to stuff mentioned elsewhere, summarized in that summary)
> 
> That's not the point,

That's definitely the point, why not. This is why "barrier()", being
heavy-handed, is not the best option.

> because as I also mentioned, the logical extention
> to Linux's barrier API to handle this is the order(x) macro. Again, not
> special volatile accessors.

Sure, that forget(x) macro _is_ proposed to be made part of the generic
API. Doesn't explain why not to define/use primitives that has volatility
semantics in itself, though (taste matters apart).
