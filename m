From: David Miller <davem@davemloft.net>
Subject: Re: [IPSEC]: Fix potential dst leak in xfrm_lookup
Date: Tue, 11 Dec 2007 04:40:16 -0800 (PST)
Message-ID: <20071211.044016.218495218.davem@davemloft.net>
References: <20071211120729.GA14088@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53618
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751187AbXLKMkR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Dec 2007 07:40:17 -0500
In-Reply-To: <20071211120729.GA14088@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 11 Dec 2007 20:07:29 +0800

> [IPSEC]: Fix potential dst leak in xfrm_lookup
> 
> If we get an error during the actual policy lookup we don't free the
> original dst while the caller expects us to always free the original
> dst in case of error.
> 
> This patch fixes that.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Sigh, thanks for fixing this.  Applied to net-2.6 and I'll toss it
over to -stable too.

I bet the __xfrm_lookup() callers could stand a major audit, with the
special -EREMOTE logic I bet there are non-EREMOTE code paths there
that don't handle the dst ref semantics properly.

This is a very error prone interface, both at the implementation
and in the callers.
