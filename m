From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH (resubmit)][BRIDGE] Properly dereference the br_should_route_hook
Date: Fri, 30 Nov 2007 00:04:20 +1100
Message-ID: <20071129130420.GA8487@gondor.apana.org.au>
References: <474C43F4.5080704@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	bridge@lists.osdl.org, devel@openvz.org,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3476 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757940AbXK2NEZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Nov 2007 08:04:25 -0500
Content-Disposition: inline
In-Reply-To: <474C43F4.5080704@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 27, 2007 at 07:21:08PM +0300, Pavel Emelyanov wrote:
> This hook is protected with the RCU, so simple
> 
> 	if (br_should_route_hook)
> 		br_should_route_hook(...)
> 
> is not enough on some architectures.
> 
> Use the rcu_dereference/rcu_assign_pointer in this case.
> 
> Fixed Stephen's comment concerning using the typeof().
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied to net-2.6.  Thanks Pavel!

>  static void __exit ebtable_broute_fini(void)
>  {
> -	br_should_route_hook = NULL;
> +	rcu_assign_pointer(br_should_route_hook, NULL);

Just for the record, rcu_assign_pointer is never necessary when
you're assigning NULL.  The reason is that rcu_assign_pointer serves
as a barrier between the initialisation of the content of what you're
assigning and the actual assignment.  Since NULL does not need to be
initialised you don't need the barrier :)

Hmm, perhaps we could even build this logic into rcu_assign_pointer.

Then again, who still uses an Alpha? Mine died years ago :)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
