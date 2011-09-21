From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] xfrm: Perform a replay check after return from async
	codepaths
Date: Wed, 21 Sep 2011 22:24:42 +1000
Message-ID: <20110921122442.GA19162@gondor.apana.org.au>
References: <20110921093858.GW1808@secunet.com> <20110921112158.GB18648@gondor.apana.org.au> <20110921115727.GX1808@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:48380 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751115Ab1IUMYr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Sep 2011 08:24:47 -0400
Content-Disposition: inline
In-Reply-To: <20110921115727.GX1808@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 21, 2011 at 01:57:27PM +0200, Steffen Klassert wrote:
>
> Well, I've got pretty reproduceable crashes when the sender of
> the IPsec packets introduces reorder, that's why I noticed this.
> 
> The problem is, that the replay check function is called before
> the asynchronous crypto processing and the replay advance function
> is called after resume from the asynchronous processing. So
> we can submit multiple packets to the crypto layer without
> updating the replay window. This means that the replay check
> function accepts packets that should have been dropped, because
> they are reordered and more than 'replay window size' packets
> to late. This leads to a crash as we try to update the replay
> window beyond the allocated bounds.

OK I see what you mean now.

Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

Thanks!
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
