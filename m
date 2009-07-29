From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: netpoll + xmit_lock == deadlock
Date: Thu, 30 Jul 2009 06:38:32 +0800
Message-ID: <20090729223831.GA14066@gondor.apana.org.au>
References: <20090729073523.GA4515@gondor.apana.org.au> <1248894478.4545.2822.camel@calx> <20090729194300.GB17410@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Matt Mackall <mpm@selenic.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Matt Carlson <mcarlson@broadcom.com>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:50906 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751123AbZG2Win (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jul 2009 18:38:43 -0400
Content-Disposition: inline
In-Reply-To: <20090729194300.GB17410@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 29, 2009 at 03:43:00PM -0400, Neil Horman wrote:
> 
> I think there is actually some recursion protection.  If you look in
> netpoll_send_skb (where all netpoll transmits pass through), we do a
> __netif_tx_trylock, and only continue down the tx path if we obtain the lock.
> If not, we call netpoll_poll, wait a while, and try again.  I think that should
> prevent the deadlock condition you are concerned about.

When netpoll_poll calls dev->poll which then takes the TX lock 
you have no protection whatsoever.  Some drivers do this in order
to ensure that TX descriptor cleanups do not race against the
transmitting side.  See tg3 for an example.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
