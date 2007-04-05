From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [SC92031]: Fix priv->lock context (was: 2.6.21-rc5-mm4)
Date: Thu, 5 Apr 2007 21:44:31 +1000
Message-ID: <20070405114431.GA10972@gondor.apana.org.au>
References: <20070404190402.609cbd65.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "Antonino A. Daplas" <adaplas@pol.net>,
	Jeff Garzik <jgarzik@pobox.com>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3754 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1766952AbXDELpJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Apr 2007 07:45:09 -0400
Content-Disposition: inline
In-Reply-To: <20070404190402.609cbd65.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 05, 2007 at 02:04:02AM +0000, Andrew Morton wrote:
> 
> This looks like a locking bug in the ipv6 changes in davem's devel tree.
> There are no relevant changes to drivers/net/sc92031.c in rc5-mm4.

Actually, this looks like a latent bug in sc92031.  It's calling
spin_lock in the dev->open function on a lock that's held in BH
context.

[SC92031]: Fix priv->lock context

The spin_lock calls made in dev->open and dev->close must disable
BH since open/close are made in process context.  Conversely, the
call in dev->hard_start_xmit does not need to disable BH since it
is already executing with BH disabled.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
