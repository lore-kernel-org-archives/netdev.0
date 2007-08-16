From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all architectures
Date: Thu, 16 Aug 2007 15:09:07 +0800
Message-ID: <20070816070907.GA964@gondor.apana.org.au>
References: <20070816003948.GY9645@linux.vnet.ibm.com> <Pine.LNX.4.64.0708151740570.10497@schroedinger.engr.sgi.com> <18115.44462.622801.683446@cargo.ozlabs.ibm.com> <20070816020042.GA30650@gondor.apana.org.au> <18115.45316.702491.681906@cargo.ozlabs.ibm.com> <alpine.LFD.0.999.0708160800130.24380@enigma.security.iitk.ac.in> <alpine.LFD.0.999.0708160815510.24380@enigma.security.iitk.ac.in> <18115.52863.638655.658466@cargo.ozlabs.ibm.com> <20070816053945.GB32442@gondor.apana.org.au> <18115.62741.807704.969977@cargo.ozlabs.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Satyam Sharma <satyam@infradead.org>,
	Christoph Lameter <clameter@sgi.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
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
Received: from rhun.apana.org.au ([64.62.148.172]:4725 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754769AbXHPHKb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Aug 2007 03:10:31 -0400
Content-Disposition: inline
In-Reply-To: <18115.62741.807704.969977@cargo.ozlabs.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 16, 2007 at 04:56:21PM +1000, Paul Mackerras wrote:
>
> Note that I said these are the cases _where one might want to allow
> caching_, so of course adding volatile doesn't help _these_ cases.
> There are of course other cases where one definitely doesn't want to
> allow the compiler to cache the value, such as when polling an atomic
> variable waiting for another CPU to change it, and from my inspection
> so far these cases seem to be the majority.

We've been through that already.  If it's a busy-wait it
should use cpu_relax.  If it's scheduling away that already
forces the compiler to reread anyway.

Do you have an actual example where volatile is needed?

> - It matches the normal expectation based on the name "atomic_read"
> - It matches the behaviour of the other atomic_* primitives

Can't argue since you left out what those expectations
or properties are.

> - It avoids bugs in the cases where "volatile" behaviour is required

Do you (or anyone else for that matter) have an example of this?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
