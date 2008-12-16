From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 3/8] net: Add Generic Receive Offload infrastructure
Date: Tue, 16 Dec 2008 13:04:32 +1100
Message-ID: <20081216020432.GA6454@gondor.apana.org.au>
References: <20081213013420.GA13549@gondor.apana.org.au> <E1LBJPd-0003YU-Ap@gondolin.me.apana.org.au> <20081215232942.GD6759@linux.vnet.ibm.com> <20081215.153920.105386030.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: paulmck@linux.vnet.ibm.com, netdev@vger.kernel.org,
	johnpol@2ka.mipt.ru, bhutchings@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:34249 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751461AbYLPCEm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Dec 2008 21:04:42 -0500
Content-Disposition: inline
In-Reply-To: <20081215.153920.105386030.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 15, 2008 at 03:39:20PM -0800, David Miller wrote:
> From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
>
> > Presumably ptype_base[] is a static array rather than a dynamically
> > allocated array that is resized under RCU protection, right?  Otherwise,
> > you could get in trouble if the above raced with the resize operation due
> > to the fact that you are outside of the RCU read-side critical section.
> 
> Yes, and we've been using RCU this way for this table for quite
> some time.  From net/core/dev.c:
> 
> #define PTYPE_HASH_SIZE	(16)
> #define PTYPE_HASH_MASK	(PTYPE_HASH_SIZE - 1)
> 
> static DEFINE_SPINLOCK(ptype_lock);
> static struct list_head ptype_base[PTYPE_HASH_SIZE] __read_mostly;
> static struct list_head ptype_all __read_mostly;	/* Taps */

Thanks for confirming.  Yes unless there is a sudden surge of
new Ethernet protocols we shouldn't need to resize this ever :)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
