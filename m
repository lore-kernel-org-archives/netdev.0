From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 6/24] make atomic_read() behave consistently on frv
Date: Tue, 14 Aug 2007 15:26:17 +0800
Message-ID: <20070814072617.GA8766@gondor.apana.org.au>
References: <20070811042943.GA13410@linux.vnet.ibm.com> <E1IKSHQ-0007hg-00@gondolin.me.apana.org.au> <20070813060302.GF13410@linux.vnet.ibm.com> <46C13EE1.1000707@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: paulmck@linux.vnet.ibm.com, csnook@redhat.com, dhowells@redhat.com,
	linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org,
	torvalds@linux-foundation.org, netdev@vger.kernel.org,
	akpm@linux-foundation.org, ak@suse.de, heiko.carstens@de.ibm.com,
	davem@davemloft.net, schwidefsky@de.ibm.com, wensong@linux-vs.org,
	horms@verge.net.au, wjiang@resilience.com, cfriesen@nortel.com,
	zlynx@acm.org, rpjday@mindspring.com, jesper.juhl@gmail.com
To: Nick Piggin <nickpiggin@yahoo.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2188 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750714AbXHNH1Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Aug 2007 03:27:24 -0400
Content-Disposition: inline
In-Reply-To: <46C13EE1.1000707@yahoo.com.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 14, 2007 at 03:34:25PM +1000, Nick Piggin wrote:
>
> What do you think of this crazy idea?
> 
> /* Enforce a compiler barrier for only operations to location X.
>  * Call multiple times to provide an ordering between multiple
>  * memory locations. Other memory operations can be assumed by
>  * the compiler to remain unchanged and may be reordered
>  */
> #define order(x) asm volatile("" : "+m" (x))

Yes this is a very good idea.  This also makes it explicit
that the coder is depending on this rather than the more
vague connotations of atomic_read.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
