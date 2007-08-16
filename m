From: Paul Mackerras <paulus@samba.org>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all
 architectures
Date: Thu, 16 Aug 2007 10:34:15 +1000
Message-ID: <18115.39815.730873.346526@cargo.ozlabs.ibm.com>
References: <20070809131423.GA9927@shell.boston.redhat.com>
	<Pine.LNX.4.64.0708141529310.32693@schroedinger.engr.sgi.com>
	<alpine.LFD.0.999.0708150417240.6482@enigma.security.iitk.ac.in>
	<46C2D6F3.3070707@s5r6.in-berlin.de>
	<alpine.LFD.0.999.0708151713080.16414@enigma.security.iitk.ac.in>
	<18115.35524.56393.347841@cargo.ozlabs.ibm.com>
	<Pine.LNX.4.64.0708151725130.10497@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Satyam Sharma <satyam@infradead.org>,
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
	segher@kernel.crashing.org,
	Herbert Xu <herbert@gondor.apana.org.au>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: Christoph Lameter <clameter@sgi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:39643 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753060AbXHPAfl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Aug 2007 20:35:41 -0400
In-Reply-To: <Pine.LNX.4.64.0708151725130.10497@schroedinger.engr.sgi.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Christoph Lameter writes:

> On Thu, 16 Aug 2007, Paul Mackerras wrote:
> 
> > In the kernel we use atomic variables in precisely those situations
> > where a variable is potentially accessed concurrently by multiple
> > CPUs, and where each CPU needs to see updates done by other CPUs in a
> > timely fashion.  That is what they are for.  Therefore the compiler
> > must not cache values of atomic variables in registers; each
> > atomic_read must result in a load and each atomic_set must result in a
> > store.  Anything else will just lead to subtle bugs.
> 
> This may have been the intend. However, today the visibility is controlled 
> using barriers. And we have barriers that we use with atomic operations. 

Those barriers are for when we need ordering between atomic variables
and other memory locations.  An atomic variable by itself doesn't and
shouldn't need any barriers for other CPUs to be able to see what's
happening to it.

Paul.
