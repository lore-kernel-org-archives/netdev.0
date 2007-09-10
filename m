From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all architectures
Date: Mon, 10 Sep 2007 14:50:41 -0700
Message-ID: <20070910215041.GJ11801@linux.vnet.ibm.com>
References: <20070816053945.GB32442@gondor.apana.org.au> <18115.62741.807704.969977@cargo.ozlabs.ibm.com> <20070816070907.GA964@gondor.apana.org.au> <Pine.LNX.4.64.0708161743500.13267@kivilampi-30.cs.helsinki.fi> <46C4ABA5.9010804@redhat.com> <Pine.LNX.4.64.0708161319000.17777@schroedinger.engr.sgi.com> <c298f0e3f9e49c9dd2d326115d156084@kernel.crashing.org> <Pine.LNX.4.64.0709101157060.24491@schroedinger.engr.sgi.com> <20070910205434.GF11801@linux.vnet.ibm.com> <Pine.LNX.4.64.0709101433090.26043@schroedinger.engr.sgi.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Segher Boessenkool <segher@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>, heiko.carstens@de.ibm.com,
	horms@verge.net.au, Stefan Richter <stefanr@s5r6.in-berlin.de>,
	Satyam Sharma <satyam@infradead.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Ilpo =?iso-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	ak@suse.de, cfriesen@nortel.com, rpjday@mindspring.com,
	Netdev <netdev@vger.kernel.org>, jesper.juhl@gmail.com,
	linux-arch@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>, zlynx@acm.org,
	schwidefsky@de.ibm.com, Chris Snook <csnook@redhat.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	wensong@linux-vs.org, wjiang@resilience.com
To: Christoph Lameter <clameter@sgi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:48347 "EHLO e4.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757425AbXIJVup (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Sep 2007 17:50:45 -0400
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0709101433090.26043@schroedinger.engr.sgi.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 10, 2007 at 02:36:26PM -0700, Christoph Lameter wrote:
> On Mon, 10 Sep 2007, Paul E. McKenney wrote:
> 
> > The one exception to this being the case where process-level code is
> > communicating to an interrupt handler running on that same CPU -- on
> > all CPUs that I am aware of, a given CPU always sees its own writes
> > in order.
> 
> Yes but that is due to the code path effectively continuing in the 
> interrupt handler. The cpu makes sure that op codes being executed always 
> see memory in a consistent way. The basic ordering problem with out of 
> order writes is therefore coming from other processors concurrently 
> executing code and holding variables in registers that are modified 
> elsewhere. The only solution that I know of are one or the other form of 
> barrier.

So we are agreed then -- volatile accesses may be of some assistance when
interacting with interrupt handlers running on the same CPU (presumably
when using per-CPU variables), but are generally useless when sharing
variables among CPUs.  Correct?

							Thanx, Paul
