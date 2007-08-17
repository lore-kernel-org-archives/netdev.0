From: Paul Mackerras <paulus@samba.org>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all architectures
Date: Fri, 17 Aug 2007 15:04:48 +1000
Message-ID: <18117.11376.111737.891134@cargo.ozlabs.ibm.com>
References: <alpine.LFD.0.999.0708160800130.24380@enigma.security.iitk.ac.in>
	<alpine.LFD.0.999.0708160815510.24380@enigma.security.iitk.ac.in>
	<18115.52863.638655.658466@cargo.ozlabs.ibm.com>
	<20070816053945.GB32442@gondor.apana.org.au>
	<18115.62741.807704.969977@cargo.ozlabs.ibm.com>
	<20070816070907.GA964@gondor.apana.org.au>
	<46C40587.7050708@s5r6.in-berlin.de>
	<20070816081049.GA1431@gondor.apana.org.au>
	<46C41EE4.9090806@s5r6.in-berlin.de>
	<46C42767.4070104@s5r6.in-berlin.de>
	<20070816104250.GB2927@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Stefan Richter <stefanr@s5r6.in-berlin.de>,
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
Received: from ozlabs.org ([203.10.76.45]:53239 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754682AbXHQFFI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Aug 2007 01:05:08 -0400
In-Reply-To: <20070816104250.GB2927@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu writes:

> So the point here is that if you don't mind getting a stale
> value from the CPU cache when doing an atomic_read, then
> surely you won't mind getting a stale value from the compiler
> "cache".

No, that particular argument is bogus, because there is a cache
coherency protocol operating to keep the CPU cache coherent with
stores from other CPUs, but there isn't any such protocol (nor should
there be) for a register used as a "cache".

(Linux requires SMP systems to keep any CPU caches coherent as far as
accesses by other CPUs are concerned.  It doesn't support any SMP
systems that are not cache-coherent as far as CPU accesses are
concerned.  It does support systems with non-cache-coherent DMA.)

Paul.
