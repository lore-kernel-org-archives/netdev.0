From: Stefan Richter <stefanr@s5r6.in-berlin.de>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all
 architectures
Date: Thu, 16 Aug 2007 12:31:03 +0200
Message-ID: <46C42767.4070104@s5r6.in-berlin.de>
References: <18115.44462.622801.683446@cargo.ozlabs.ibm.com> <20070816020042.GA30650@gondor.apana.org.au> <18115.45316.702491.681906@cargo.ozlabs.ibm.com> <alpine.LFD.0.999.0708160800130.24380@enigma.security.iitk.ac.in> <alpine.LFD.0.999.0708160815510.24380@enigma.security.iitk.ac.in> <18115.52863.638655.658466@cargo.ozlabs.ibm.com> <20070816053945.GB32442@gondor.apana.org.au> <18115.62741.807704.969977@cargo.ozlabs.ibm.com> <20070816070907.GA964@gondor.apana.org.au> <46C40587.7050708@s5r6.in-berlin.de> <20070816081049.GA1431@gondor.apana.org.au> <46C41EE4.9090806@s5r6.in-berlin.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Paul Mackerras <paulus@samba.org>,
	Satyam Sharma <satyam@infradead.org>,
	Christoph Lameter <clameter@sgi.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
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
Received: from hp3.statik.tu-cottbus.de ([141.43.120.68]:41327 "EHLO
	hp3.statik.tu-cottbus.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753350AbXHPKbF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Aug 2007 06:31:05 -0400
In-Reply-To: <46C41EE4.9090806@s5r6.in-berlin.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I wrote:
> Herbert Xu wrote:
>> On Thu, Aug 16, 2007 at 10:06:31AM +0200, Stefan Richter wrote:
[...]
>>> expectation that each
>>> occurrence of atomic_read actually results in a load operation, i.e. is
>>> not optimized away.
[...]
>> Can you find an actual atomic_read code snippet there that is
>> broken without the volatile modifier?

PS:  Just to clarify, I'm not speaking for the volatile modifier.  I'm
not speaking for any particular implementation of atomic_t and its
accessors at all.  All I am saying is that
  - we use atomically accessed data types because we concurrently but
    locklessly access this data,
  - hence a read access to this data that could be optimized away
    makes *no sense at all*.

The only sensible read accessor to an atomic datatype is a read accessor
that will not be optimized away.

So, the architecture guys can implement atomic_read however they want
--- as long as it cannot be optimized away.*

PPS:  If somebody has code where he can afford to let the compiler
coalesce atomic_read with a previous access to the same data, i.e.
doesn't need and doesn't want all guarantees that the atomic_read API
makes (or IMO should make), then he can replace the atomic_read by a
local temporary variable.


*) Exceptions:
	if (known_to_be_false)
		read_access(a);
and the like.
-- 
Stefan Richter
-=====-=-=== =--- =----
http://arcgraph.de/sr/
