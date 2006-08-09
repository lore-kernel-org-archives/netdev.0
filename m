From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] [e1000]: Remove unnecessary tx_lock
Date: Wed, 9 Aug 2006 10:25:30 +1000
Message-ID: <20060809002530.GA19881@gondor.apana.org.au>
References: <20060804110829.62136ebb@dxpl.pdx.osdl.net> <20060804.163111.85390037.davem@davemloft.net> <20060808170432.GD27383@kvack.org> <20060808.150607.10247901.davem@davemloft.net> <20060808232108.GA16059@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, shemminger@osdl.org,
	mchan@broadcom.com, hadi@cyberus.ca, jesse.brandeburg@intel.com,
	auke-jan.h.kok@intel.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:63239 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1030378AbWHIAyE
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Aug 2006 20:54:04 -0400
To: Benjamin LaHaise <bcrl@kvack.org>
Content-Disposition: inline
In-Reply-To: <20060808232108.GA16059@kvack.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 08, 2006 at 07:21:08PM -0400, Benjamin LaHaise wrote:
> 
> Looking at e1000, NETIF_F_LLTX is a waste -- the driver takes a spinlock 
> almost immediately after entering.  Taking the spinlock higher up in the 
> network stack, preferably for multiple packets, would at least let the 
> CPU deal with things sooner.  tg3 doesn't use LLTX and thus holds the lock 
> over hard_start_xmit().  bonding is atrocious and uses a read lock and unlock 
> in many of the xmit routines.  The only true lockless tx seems to be 
> loopback.

Your assessment is correct.  However, that's not the issue here.

The problem here is that the TX clean function does not take the lock
(nor do we want it to).  It can thus come in while you're transmitting
and empty the queue.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
