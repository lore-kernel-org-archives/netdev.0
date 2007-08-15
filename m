From: Paul Mackerras <paulus@samba.org>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all
 architectures
Date: Thu, 16 Aug 2007 09:22:44 +1000
Message-ID: <18115.35524.56393.347841@cargo.ozlabs.ibm.com>
References: <20070809131423.GA9927@shell.boston.redhat.com>
	<Pine.LNX.4.64.0708141529310.32693@schroedinger.engr.sgi.com>
	<alpine.LFD.0.999.0708150417240.6482@enigma.security.iitk.ac.in>
	<46C2D6F3.3070707@s5r6.in-berlin.de>
	<alpine.LFD.0.999.0708151713080.16414@enigma.security.iitk.ac.in>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Stefan Richter <stefanr@s5r6.in-berlin.de>,
	Christoph Lameter <clameter@sgi.com>,
	Chris Snook <csnook@redhat.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-arch@vger.kernel.org,
	Linus Torvalds <torvalds@linux-foundation.org>,
	netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	ak@suse.de, heiko.carstens@de.ibm.com, davem@davemloft.net,
	schwidefsky@de.ibm.com, wensong@linux-vs.org, horms@verge.net.au,
	wjiang@resilience.com, cfriesen@nortel.com, zlynx@acm.org,
	rpjday@mindspring.com, jesper.juhl@gmail.com,
	segher@kernel.crashing.org,
	Herbert Xu <herbert@gondor.apana.org.au>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: Satyam Sharma <satyam@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:60506 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S937230AbXHOXWv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Aug 2007 19:22:51 -0400
In-Reply-To: <alpine.LFD.0.999.0708151713080.16414@enigma.security.iitk.ac.in>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Satyam Sharma writes:

> > Doesn't "atomic WRT all processors" require volatility?
> 
> No, it definitely doesn't. Why should it?
> 
> "Atomic w.r.t. all processors" is just your normal, simple "atomicity"
> for SMP systems (ensure that that object is modified / set / replaced
> in main memory atomically) and has nothing to do with "volatile"
> behaviour.

Atomic variables are "volatile" in the sense that they are liable to
be changed at any time by mechanisms that are outside the knowledge of
the C compiler, namely, other CPUs, or this CPU executing an interrupt
routine.

In the kernel we use atomic variables in precisely those situations
where a variable is potentially accessed concurrently by multiple
CPUs, and where each CPU needs to see updates done by other CPUs in a
timely fashion.  That is what they are for.  Therefore the compiler
must not cache values of atomic variables in registers; each
atomic_read must result in a load and each atomic_set must result in a
store.  Anything else will just lead to subtle bugs.

I have no strong opinion about whether or not the best way to achieve
this is through the use of the "volatile" C keyword.  Segher's idea of
using asm instead seems like a good one to me.

Paul.
