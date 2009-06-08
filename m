From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 2/4] virtio_net: return NETDEV_TX_BUSY instead of
	queueing an extra skb.
Date: Mon, 8 Jun 2009 15:22:47 +1000
Message-ID: <20090608052247.GA19826@gondor.apana.org.au>
References: <200905292346.04815.rusty@rustcorp.com.au> <200906022325.57961.rusty@rustcorp.com.au> <20090602234532.GA5417@gondor.apana.org.au> <200906031247.05591.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	David Miller <davem@davemloft.net>
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:51620 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751146AbZFHFWs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Jun 2009 01:22:48 -0400
Content-Disposition: inline
In-Reply-To: <200906031247.05591.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 03, 2009 at 12:47:04PM +0930, Rusty Russell wrote:
> 
> We could figure out if we can take the worst-case packet, and underutilize
> our queue.  And fix the other *67* drivers.

Most of those are for debugging purposes, i.e., they'll never
happen unless the driver is buggy.

> Of course that doesn't even work, because we return NETDEV_TX_BUSY from dev.c!

If and when your driver becomes part of the core and it has to
feed into other drivers, then you can use this argument :)

> "Hi, core netdevs here.  Don't use NETDEV_TX_BUSY.   Yeah, we can't figure out
> how to avoid it either.  But y'know, just hack something together".

No you've misunderstood my complaint.  I'm not trying to get you
to replace NETDEV_TX_BUSY by the equally abhorrent queue in the
driver, I'm saying that you should stop the queue before you get
a packet that overflows by looking at the amount of free queue
space after transmitting each packet.

For most drivers this is easy to do.  What's so different about
virtio-net that makes this impossible?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
