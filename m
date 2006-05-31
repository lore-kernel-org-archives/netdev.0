From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: netif_tx_disable and lockless TX
Date: Wed, 31 May 2006 14:17:05 +1000
Message-ID: <20060531041705.GA6584@gondor.apana.org.au>
References: <20060531040307.GA6447@gondor.apana.org.au> <20060530.211322.51700292.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mchan@broadcom.com, jgarzik@pobox.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:25092 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1751666AbWEaERT
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 May 2006 00:17:19 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060530.211322.51700292.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 30, 2006 at 09:13:22PM -0700, David Miller wrote:
> 
> There were numbers posted for real drivers at one point, I
> do remember that, and the gains were non-trivial.  At least
> enough to justify the feature.

I wonder if there are other ways of achieving the same improvement.

> As per the bug, I always keep thinking about changing how we
> do the lockless stuff by simply making xmit_lock a pointer.
> Drivers like tg3 can make it point to their local driver lock.

This is equivalent to just using the xmit_lock in the driver, right?
IIRC the problem was with IRQ disabling vs. BH disabling.

That's why I suggest that every NIC that uses this feature be forced
to do what TG3 does so only BH disabling is needed.  Once that's done
they can just use xmit_lock and everyone will be happy again.

> This leaves still the cases like loopback which do no locking
> whatsoever.  I don't know how to fit it into the above idea.

As far as I'm concerned loopback can do whatever it wants as long as
it doesn't create bugs in real NICs :)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
