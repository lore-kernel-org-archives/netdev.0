From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: netpoll + xmit_lock == deadlock
Date: Wed, 29 Jul 2009 15:35:23 +0800
Message-ID: <20090729073523.GA4515@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Matt Carlson <mcarlson@broadcom.com>
To: "David S. Miller" <davem@davemloft.net>,
	Matt Mackall <mpm@selenic.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:46098 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752357AbZG2Hfa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jul 2009 03:35:30 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi:

While working on TX mitigiation, I noticed that while netpoll
takes care to avoid recursive dead locks on the NAPI path, it
has no protection against the TX path when calling the poll
function.

So if a driver is in the TX path, and a printk occurs, then a
recursive dead lock can occur if that driver tries to take the
xmit lock in its poll function to clean up descriptors.

Fortunately not a lot of drivers do this but at least some are
vulnerable to it, e.g., tg3.

So we need to make it very clear that the poll function must
not take any locks or they must use try_lock if the driver is
to support netpoll.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
