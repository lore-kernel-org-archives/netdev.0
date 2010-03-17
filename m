From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] xfrm: cache bundle lookup results in flow cache
Date: Wed, 17 Mar 2010 21:07:04 +0800
Message-ID: <20100317130704.GA2601@gondor.apana.org.au>
References: <1268655610-7845-1-git-send-email-timo.teras@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Timo Teras <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:39450 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753353Ab0CQNHJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Mar 2010 09:07:09 -0400
Content-Disposition: inline
In-Reply-To: <1268655610-7845-1-git-send-email-timo.teras@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 15, 2010 at 02:20:10PM +0200, Timo Teras wrote:
> Instead of doing O(n) xfrm_find_bundle() call per-packet, cache
> the previous lookup results in flow cache. The flow cache is
> updated to be per-netns and more generic.

This only works well if the traffic doesn't switch bundles much.
But if that were the case then the number of bundles is likely
to be small anyway.

IOW I think if we're doing this then we should go the whole
distance and directly cache bundles instead of policies in the
flow cache.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
