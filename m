From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all architectures
Date: Thu, 16 Aug 2007 18:02:32 -0700
Message-ID: <20070817010232.GK16957@linux.vnet.ibm.com>
References: <18115.45316.702491.681906@cargo.ozlabs.ibm.com> <alpine.LFD.0.999.0708160800130.24380@enigma.security.iitk.ac.in> <alpine.LFD.0.999.0708160815510.24380@enigma.security.iitk.ac.in> <18115.52863.638655.658466@cargo.ozlabs.ibm.com> <20070816053945.GB32442@gondor.apana.org.au> <18115.62741.807704.969977@cargo.ozlabs.ibm.com> <20070816070907.GA964@gondor.apana.org.au> <Pine.LNX.4.64.0708161743500.13267@kivilampi-30.cs.helsinki.fi> <46C4ABA5.9010804@redhat.com> <Pine.LNX.4.64.0708161319000.17777@schroedinger.engr.sgi.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chris Snook <csnook@redhat.com>,
	Ilpo =?iso-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Paul Mackerras <paulus@samba.org>,
	Satyam Sharma <satyam@infradead.org>,
	Stefan Richter <stefanr@s5r6.in-berlin.de>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-arch@vger.kernel.org,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Netdev <netdev@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>, ak@suse.de,
	heiko.carstens@de.ibm.com, David Miller <davem@davemloft.net>,
	schwidefsky@de.ibm.com, wensong@linux-vs.org, horms@verge.net.au,
	wjiang@resilience.com, cfriesen@nortel.com, zlynx@acm.org,
	rpjday@mindspring.com, jesper.juhl@gmail.com,
	segher@kernel.crashing.org
To: Christoph Lameter <clameter@sgi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e6.ny.us.ibm.com ([32.97.182.146]:52343 "EHLO e6.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752823AbXHQBCg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Aug 2007 21:02:36 -0400
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0708161319000.17777@schroedinger.engr.sgi.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 16, 2007 at 01:20:26PM -0700, Christoph Lameter wrote:
> On Thu, 16 Aug 2007, Chris Snook wrote:
> 
> > atomic_dec() already has volatile behavior everywhere, so this is semantically
> > okay, but this code (and any like it) should be calling cpu_relax() each
> > iteration through the loop, unless there's a compelling reason not to.  I'll
> > allow that for some hardware drivers (possibly this one) such a compelling
> > reason may exist, but hardware-independent core subsystems probably have no
> > excuse.
> 
> No it does not have any volatile semantics. atomic_dec() can be reordered 
> at will by the compiler within the current basic unit if you do not add a 
> barrier.

Yep.  Or you can use atomic_dec_return() instead of using a barrier.

						Thanx, Paul
