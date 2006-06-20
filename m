From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [NET]: Prevent multiple qdisc runs
Date: Tue, 20 Jun 2006 17:00:00 +1000
Message-ID: <20060620070000.GA11348@gondor.apana.org.au>
References: <20060619121519.GA16031@gondor.apana.org.au> <20060619.235719.58454931.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:38663 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S965109AbWFTHAD
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Jun 2006 03:00:03 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060619.235719.58454931.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jun 19, 2006 at 11:57:19PM -0700, David Miller wrote:
> 
> But this is yet another atomic operation on the transmit
> path :-(  This problem, however, is inevitable because of
> how we do things and thus isn't the fault of your change.
> 
> I'm going to apply this patch to 2.6.18, however...  we should split
> up the dev->state handling into seperate cacheline synchronizers.
> Sharing RX and TX locking bits in the same word is not all that
> efficient.

Good point.  This particular bit doesn't even need to be atomic since
it's sitting inside a spinlock.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
