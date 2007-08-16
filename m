From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all architectures
Date: Thu, 16 Aug 2007 13:39:45 +0800
Message-ID: <20070816053945.GB32442@gondor.apana.org.au>
References: <18115.35524.56393.347841@cargo.ozlabs.ibm.com> <Pine.LNX.4.64.0708151725130.10497@schroedinger.engr.sgi.com> <20070816003948.GY9645@linux.vnet.ibm.com> <Pine.LNX.4.64.0708151740570.10497@schroedinger.engr.sgi.com> <18115.44462.622801.683446@cargo.ozlabs.ibm.com> <20070816020042.GA30650@gondor.apana.org.au> <18115.45316.702491.681906@cargo.ozlabs.ibm.com> <alpine.LFD.0.999.0708160800130.24380@enigma.security.iitk.ac.in> <alpine.LFD.0.999.0708160815510.24380@enigma.security.iitk.ac.in> <18115.52863.638655.658466@cargo.ozlabs.ibm.com>
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
Received: from rhun.apana.org.au ([64.62.148.172]:4187 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752064AbXHPFkH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Aug 2007 01:40:07 -0400
Content-Disposition: inline
In-Reply-To: <18115.52863.638655.658466@cargo.ozlabs.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 16, 2007 at 02:11:43PM +1000, Paul Mackerras wrote:
>
> The uses of atomic_read where one might want it to allow caching of
> the result seem to me to fall into 3 categories:
> 
> 1. Places that are buggy because of a race arising from the way it's
>    used.
> 
> 2. Places where there is a race but it doesn't matter because we're
>    doing some clever trick.
> 
> 3. Places where there is some locking in place that eliminates any
>    potential race.

Agreed.

> In case 1, adding volatile won't solve the race, of course, but it's
> hard to argue that we shouldn't do something because it will slow down
> buggy code.  Case 2 is hopefully pretty rare and accompanied by large
> comment blocks, and in those cases caching the result of atomic_read
> explicitly in a local variable would probably make the code clearer.
> And in case 3 there is no reason to use atomic_t at all; we might as
> well just use an int.

Since adding volatile doesn't help any of the 3 cases, and
takes away optimisations from both 2 and 3, I wonder what
is the point of the addition after all?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
