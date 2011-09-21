From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] xfrm: Perform a replay check after return from async
	codepaths
Date: Wed, 21 Sep 2011 21:21:58 +1000
Message-ID: <20110921112158.GB18648@gondor.apana.org.au>
References: <20110921093858.GW1808@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:45361 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751995Ab1IULWF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Sep 2011 07:22:05 -0400
Content-Disposition: inline
In-Reply-To: <20110921093858.GW1808@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 21, 2011 at 11:38:58AM +0200, Steffen Klassert wrote:
> When asyncronous crypto algorithms are used, there might be many
> packets that passed the xfrm replay check, but the replay advance
> function is not called yet for these packets. So the replay check
> function would accept a replay of all of these packets. Also the
> system might crash if there are more packets in async processing
> than the size of the anti replay window, because the replay advance
> function would try to update the replay window beyond the bounds.
> 
> This pach adds a second replay check after resuming from the async
> processing to fix these issues.
> 
> Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>

Actually why does this matter? For a single SA, the processing
in xfrm_input should be completely synchronous, even when you're
using asynchronous algorithms.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
