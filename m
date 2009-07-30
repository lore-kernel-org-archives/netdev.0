From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: netpoll + xmit_lock == deadlock
Date: Wed, 29 Jul 2009 21:06:39 -0400
Message-ID: <20090730010639.GB4169@localhost.localdomain>
References: <20090729073523.GA4515@gondor.apana.org.au> <1248894478.4545.2822.camel@calx> <20090729194300.GB17410@hmsreliant.think-freely.org> <20090729223831.GA14066@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Matt Mackall <mpm@selenic.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Matt Carlson <mcarlson@broadcom.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:34156 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756118AbZG3BGo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jul 2009 21:06:44 -0400
Content-Disposition: inline
In-Reply-To: <20090729223831.GA14066@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 30, 2009 at 06:38:32AM +0800, Herbert Xu wrote:
> On Wed, Jul 29, 2009 at 03:43:00PM -0400, Neil Horman wrote:
> > 
> > I think there is actually some recursion protection.  If you look in
> > netpoll_send_skb (where all netpoll transmits pass through), we do a
> > __netif_tx_trylock, and only continue down the tx path if we obtain the lock.
> > If not, we call netpoll_poll, wait a while, and try again.  I think that should
> > prevent the deadlock condition you are concerned about.
> 
> When netpoll_poll calls dev->poll which then takes the TX lock 
> you have no protection whatsoever.  Some drivers do this in order
> to ensure that TX descriptor cleanups do not race against the
> transmitting side.  See tg3 for an example.

but nothing in that path takes the xmit_lock.  The poll_lock is taken in that
patch, but thats for recieve_side syncronization, not transmit side.  Nothing in
the tg3 driver (to use your example), that I can see takes the xmit_lock in the
rx path either, so I'm not really sure where you comming from here.
Neil

> 
> Cheers,
> -- 
> Visit Openswan at http://www.openswan.org/
> Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
> Home Page: http://gondor.apana.org.au/~herbert/
> PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
