From: Paul Mackerras <paulus@samba.org>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all architectures
Date: Thu, 16 Aug 2007 13:15:05 +1000
Message-ID: <18115.49465.34538.840034@cargo.ozlabs.ibm.com>
References: <alpine.LFD.0.999.0708150417240.6482@enigma.security.iitk.ac.in>
	<46C2D6F3.3070707@s5r6.in-berlin.de>
	<alpine.LFD.0.999.0708151713080.16414@enigma.security.iitk.ac.in>
	<18115.35524.56393.347841@cargo.ozlabs.ibm.com>
	<Pine.LNX.4.64.0708151725130.10497@schroedinger.engr.sgi.com>
	<20070816003948.GY9645@linux.vnet.ibm.com>
	<Pine.LNX.4.64.0708151740570.10497@schroedinger.engr.sgi.com>
	<18115.44462.622801.683446@cargo.ozlabs.ibm.com>
	<20070816020042.GA30650@gondor.apana.org.au>
	<18115.45316.702491.681906@cargo.ozlabs.ibm.com>
	<20070816021105.GA30883@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
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
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:49958 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756705AbXHPDXT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Aug 2007 23:23:19 -0400
In-Reply-To: <20070816021105.GA30883@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu writes:

> > Are you sure?  How do you know some other CPU hasn't changed the value
> > in between?
> 
> Yes I'm sure, because we don't care if others have increased
> the reservation.

But others can also reduce the reservation.  Also, the code sets and
clears *sk->sk_prot->memory_pressure nonatomically with respect to the
reads of sk->sk_prot->memory_allocated, so in fact the code doesn't
guarantee any particular relationship between the two.

That code looks like a beautiful example of buggy, racy code where
someone has sprinkled magic fix-the-races dust (otherwise known as
atomic_t) around in a vain attempt to fix the races.

That's assuming that all that stuff actually performs any useful
purpose, of course, and that there isn't some lock held by the
callers.  In the latter case it is pointless using atomic_t.

Paul.
