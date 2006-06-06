From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [NET]: Add netif_tx_lock
Date: Tue, 6 Jun 2006 20:22:10 +1000
Message-ID: <20060606102210.GA26982@gondor.apana.org.au>
References: <20060531.170908.46214247.davem@davemloft.net> <20060601002525.GA19220@gondor.apana.org.au> <20060601111503.GA16097@gondor.apana.org.au> <20060605.213250.85688925.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mchan@broadcom.com, jgarzik@pobox.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:778 "EHLO arnor.apana.org.au")
	by vger.kernel.org with ESMTP id S1751003AbWFFKWS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jun 2006 06:22:18 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060605.213250.85688925.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jun 05, 2006 at 09:32:50PM -0700, David Miller wrote:
> 
> IPOIB is going to BUG() with this change.  Because now, in their
> multicast code, you're going to local_bh_disable() via
> netif_tx_unlock() with hw IRQs disabled which is illegal.
> 
> It shows a bug here in the locking of the IPOIB driver.

You had me woried there.

> We need to think about this change some more. :)

I thought about it a bit more and I'm not worried anymore :)

Notice that the patch does netif_tx_lock/netif_tx_unlock
for IB instead of netif_tx_lock_bh/netif_tx_unlock_bh.
So there is no BH enabling going on at all.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
