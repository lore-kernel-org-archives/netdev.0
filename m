From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all architectures
Date: Thu, 16 Aug 2007 11:43:39 +0800
Message-ID: <20070816034339.GB31844@gondor.apana.org.au>
References: <alpine.LFD.0.999.0708151713080.16414@enigma.security.iitk.ac.in> <18115.35524.56393.347841@cargo.ozlabs.ibm.com> <Pine.LNX.4.64.0708151725130.10497@schroedinger.engr.sgi.com> <20070816003948.GY9645@linux.vnet.ibm.com> <Pine.LNX.4.64.0708151740570.10497@schroedinger.engr.sgi.com> <18115.44462.622801.683446@cargo.ozlabs.ibm.com> <20070816020042.GA30650@gondor.apana.org.au> <18115.45316.702491.681906@cargo.ozlabs.ibm.com> <20070816021105.GA30883@gondor.apana.org.au> <18115.49465.34538.840034@cargo.ozlabs.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Lameter <clameter@sgi.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Satyam Sharma <satyam@infradead.org>,
	Stefan Richter <stefanr@s5r6.in-berlin.de>,
	Chris Snook <csnook@redhat.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-arch@vger.kernel.org,
	Linus Torvalds <torvalds@linux-foundation.org>,
	netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	ak@suse.de, heiko.carstens@de.ibm.com, davem@davemloft.net,
	schwidefsky@de.ibm.com, wensong@linux-vs.org, horms@verge.net.au,
	wjiang@resilience.com, cfriesen@nortel.com, zlynx@acm.org,
	rpjday@mindspring.com, jesper.juhl@gmail.com,
	segher@kernel.crashing.org
To: Paul Mackerras <paulus@samba.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3351 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1761949AbXHPDoU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Aug 2007 23:44:20 -0400
Content-Disposition: inline
In-Reply-To: <18115.49465.34538.840034@cargo.ozlabs.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 16, 2007 at 01:15:05PM +1000, Paul Mackerras wrote:
> 
> But others can also reduce the reservation.  Also, the code sets and
> clears *sk->sk_prot->memory_pressure nonatomically with respect to the
> reads of sk->sk_prot->memory_allocated, so in fact the code doesn't
> guarantee any particular relationship between the two.

Yes others can reduce the reservation, but the point of this
is that the code doesn't care.  We'll either see the value
before or after the reduction and in either case we'll do
something sensible.

The worst that can happen is when we're just below the hard
limit and multiple CPUs fail to allocate but that's not really
a problem because if the machine is making progress at all
then we will eventually scale back and allow these allocations
to succeed.

As to the non-atomic operation on memory_pressue, that's OK
because we only ever assign values to it and never do other
operations such as += or -=.  Remember that int/long assignments
must be atomic or Linux won't run on your architecture.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
