From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] make atomic_t volatile on all architectures
Date: Wed, 8 Aug 2007 20:47:20 -0700
Message-ID: <20070809034720.GA12996@linux.vnet.ibm.com>
References: <20070808230733.GA17270@shell.boston.redhat.com> <E1IIwQx-000468-00@gondolin.me.apana.org.au> <20070808.184824.133910636.davem@davemloft.net>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, csnook@redhat.com,
	akpm@linux-foundation.org, torvalds@linux-foundation.org,
	ak@suse.de, heiko.carstens@de.ibm.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	schwidefsky@de.ibm.com, wensong@linux-vs.org, horms@verge.net.au,
	wjiang@resilience.com, cfriesen@nortel.com, zlynx@acm.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e6.ny.us.ibm.com ([32.97.182.146]:35746 "EHLO e6.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754477AbXHIDrY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Aug 2007 23:47:24 -0400
Content-Disposition: inline
In-Reply-To: <20070808.184824.133910636.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 08, 2007 at 06:48:24PM -0700, David Miller wrote:
> From: Herbert Xu <herbert@gondor.apana.org.au>
> Date: Thu, 09 Aug 2007 09:03:27 +0800
> 
> > Such loops should always use something like cpu_relax() which comes
> > with a barrier.
> 
> This is an excellent point.
> 
> And it needs to be weighed with the error prone'ness Andrew mentioned.
> There probably is a middle ground somewhere.

OK...  I'll bite.  ACCESS_ONCE(), see http://lkml.org/lkml/2007/7/11/664.

This would allow ACCESS_ONCE(atomic_read(&x)) to be used where refetching
would be problematic, but allow the compiler free rein in cases where
refetching is OK.

The ACCESS_ONCE() primitive of course has its limitations as well, but
you did ask for a middle ground.  ;-)

							Thanx, Paul
