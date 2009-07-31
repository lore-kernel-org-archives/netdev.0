From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: netpoll + xmit_lock == deadlock
Date: Fri, 31 Jul 2009 08:56:54 -0400
Message-ID: <20090731125654.GB18303@hmsreliant.think-freely.org>
References: <20090729073523.GA4515@gondor.apana.org.au> <1248894478.4545.2822.camel@calx> <20090729194300.GB17410@hmsreliant.think-freely.org> <20090729223831.GA14066@gondor.apana.org.au> <20090730010639.GB4169@localhost.localdomain> <20090731013017.GB25895@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Matt Mackall <mpm@selenic.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Matt Carlson <mcarlson@broadcom.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:40986 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751924AbZGaM5N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Jul 2009 08:57:13 -0400
Content-Disposition: inline
In-Reply-To: <20090731013017.GB25895@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 31, 2009 at 09:30:17AM +0800, Herbert Xu wrote:
> On Wed, Jul 29, 2009 at 09:06:39PM -0400, Neil Horman wrote:
> >
> > but nothing in that path takes the xmit_lock.  The poll_lock is taken in that
> > patch, but thats for recieve_side syncronization, not transmit side.  Nothing in
> > the tg3 driver (to use your example), that I can see takes the xmit_lock in the
> > rx path either, so I'm not really sure where you comming from here.
> 
> tg3_poll => tg3_poll_work => tg3_tx => netif_tx_lock

Oh, goodness, thats just asking for disaster.  Setting asside the netpoll issue
for the moment, what if we take an rx interrupt on a cpu while in the middle of
sending a frame?  Whats to stop the NET_RX_SOFTIRQ after the hard interrupt and
recursively taking the _xmit_lock?  With or without netpoll, that seems prone to
deadlock.

Neil

> -- 
> Visit Openswan at http://www.openswan.org/
> Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
> Home Page: http://gondor.apana.org.au/~herbert/
> PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
> 
