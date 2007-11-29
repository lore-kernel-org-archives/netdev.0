From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH (resubmit)][BRIDGE] Properly dereference the br_should_route_hook
Date: Fri, 30 Nov 2007 10:49:00 +1100
Message-ID: <20071129234900.GB23769@gondor.apana.org.au>
References: <474C43F4.5080704@openvz.org> <20071129130420.GA8487@gondor.apana.org.au> <20071129143650.GD32449@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pavel Emelyanov <xemul@openvz.org>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	bridge@lists.osdl.org, devel@openvz.org
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2561 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1761976AbXK2XtL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Nov 2007 18:49:11 -0500
Content-Disposition: inline
In-Reply-To: <20071129143650.GD32449@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 29, 2007 at 06:36:50AM -0800, Paul E. McKenney wrote:
>
> That certainly is an interesting tradeoff...  Save a memory barrier
> when assigning NULL, but pay an extra test and branch in all cases.
> Though it does make for a simpler rule -- just use rcu_assign_pointer()
> in all cases.  Of course, if almost all rcu_assign_pointer() executions
> assign non-NULL pointers, the optimal strategy would be to leave the
> implementation of rcu_assign_pointer() alone, and simply enforce use
> of rcu_assign_pointer(), even if the pointer being assigned is NULL.

I was thinking of something much simpler.  If the second argument is
constant and NULL, then skip the barrier.  No run-time slow-down at
all.
 
> Although rcu_dereference() does a memory barrier only on Alpha, that of
> rcu_assign_pointer() is needed on any machine that does not preserve store
> order (Itanium, POWER, ARM, some MIPS boxes according to rumor, ...).

Good point!

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
