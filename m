From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: >10% performance degradation since 2.6.18
Date: Sun, 5 Jul 2009 12:01:37 +0800
Message-ID: <20090705040137.GA7747@gondor.apana.org.au>
References: <4A4F1EA0.3070501@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: andi@firstfloor.org, arjan@infradead.org, matthew@wil.cx,
	jens.axboe@oracle.com, linux-kernel@vger.kernel.org,
	douglas.w.styner@intel.com, chinang.ma@intel.com,
	terry.o.prickett@intel.com, matthew.r.wilcox@intel.com,
	Eric.Moore@lsi.com, DL-MPTFusionLinux@lsi.com,
	netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:58370 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750712AbZGEECX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Jul 2009 00:02:23 -0400
Content-Disposition: inline
In-Reply-To: <4A4F1EA0.3070501@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff Garzik <jeff@garzik.org> wrote:
> 
> What's the best setup for power usage?
> What's the best setup for performance?
> Are they the same?

Yes.

> Is it most optimal to have the interrupt for socket $X occur on the same 
> CPU as where the app is running?

Yes.

> If yes, how to best handle when the scheduler moves app to another CPU?
> Should we reprogram the NIC hardware flow steering mechanism at that point?

Not really.  For now the best thing to do is to pin everything
down and not move at all, because we can't afford to move.

The only way for moving to work is if we had the ability to get
the sockets to follow the processes.  That means, we must have
one RX queue per socket.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
