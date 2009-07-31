From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: netpoll + xmit_lock == deadlock
Date: Fri, 31 Jul 2009 21:02:43 +0800
Message-ID: <20090731130243.GA31058@gondor.apana.org.au>
References: <20090729073523.GA4515@gondor.apana.org.au> <1248894478.4545.2822.camel@calx> <20090729194300.GB17410@hmsreliant.think-freely.org> <20090729223831.GA14066@gondor.apana.org.au> <20090730010639.GB4169@localhost.localdomain> <20090731013017.GB25895@gondor.apana.org.au> <20090731125654.GB18303@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Matt Mackall <mpm@selenic.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Matt Carlson <mcarlson@broadcom.com>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:37759 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752201AbZGaNCz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Jul 2009 09:02:55 -0400
Content-Disposition: inline
In-Reply-To: <20090731125654.GB18303@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 31, 2009 at 08:56:54AM -0400, Neil Horman wrote:
>
> > tg3_poll => tg3_poll_work => tg3_tx => netif_tx_lock
> 
> Oh, goodness, thats just asking for disaster.  Setting asside the netpoll issue
> for the moment, what if we take an rx interrupt on a cpu while in the middle of
> sending a frame?  Whats to stop the NET_RX_SOFTIRQ after the hard interrupt and
> recursively taking the _xmit_lock?  With or without netpoll, that seems prone to
> deadlock.

No that can't happen because BH is disabled in the xmit function.

This problem is specific to netpoll because it does things that
normally can't happen with BH off.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
