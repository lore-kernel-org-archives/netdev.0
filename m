From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] xfrm: Workaround incompatibility of ESN and async
 crypto
Date: Tue, 4 Sep 2012 05:31:55 -0700
Message-ID: <20120904123155.GA3152@gondor.apana.org.au>
References: <20120904100329.GA13023@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sting.hengli.com.au ([178.18.18.71]:45668 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756900Ab2IDMcC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Sep 2012 08:32:02 -0400
Content-Disposition: inline
In-Reply-To: <20120904100329.GA13023@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 04, 2012 at 12:03:29PM +0200, Steffen Klassert wrote:
> ESN for esp is defined in RFC 4303. This RFC assumes that the
> sequence number counters are always up to date. However,
> this is not true if an async crypto algorithm is employed.
> 
> If the sequence number counters are not up to date on sequence
> number check, we may incorrectly update the upper 32 bit of
> the sequence number. This leads to a DOS.
> 
> We workaround this by comparing the upper sequence number,
> (used for authentication) with the upper sequence number
> computed after the async processing. We drop the packet
> if these numbers are different.
> 
> To do this, we introduce a recheck function that does this
> check in the ESN case.
> 
> Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>

Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

It took me a while to understand the problem but Steffen was
correct again as usual.

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
