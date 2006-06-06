From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 2.6.18 1/3] tg3: Remove unnecessary tx_lock
Date: Tue, 6 Jun 2006 12:04:34 +1000
Message-ID: <20060606020434.GA23672@gondor.apana.org.au>
References: <1149536843.13155.6.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, jgarzik@pobox.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:21263 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1751213AbWFFCEw
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Jun 2006 22:04:52 -0400
To: Michael Chan <mchan@broadcom.com>
Content-Disposition: inline
In-Reply-To: <1149536843.13155.6.camel@rh4>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jun 05, 2006 at 12:47:23PM -0700, Michael Chan wrote:
> Remove tx_lock where it is unnecessary. tg3 runs lockless and so it
> requires interrupts to be disabled and sync'ed, netif_queue and NAPI
> poll to be stopped before the device can be reconfigured. After
> stopping everything, it is no longer necessary to get the tx_lock.

The paths where full lock is preceded by netif_tx_disable are obviously
safe (well, once you take off the LLTX flag anyway).  However, there are
paths that don't do netif_tx_disable (e.g., tg3_set_rx_mode), are they
safe as well?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
