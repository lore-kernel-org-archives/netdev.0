From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] netdev: Reset ipv4 flags during bundle creation on interfamily ipsec
Date: Fri, 19 Oct 2007 21:09:05 +0800
Message-ID: <20071019130905.GA14032@gondor.apana.org.au>
References: <200710191437.39449.joakim.koskela@hiit.fi> <200710191440.17232.joakim.koskela@hiit.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>
To: Joakim Koskela <joakim.koskela@hiit.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3398 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756625AbXJSNJI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Oct 2007 09:09:08 -0400
Content-Disposition: inline
In-Reply-To: <200710191440.17232.joakim.koskela@hiit.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 19, 2007 at 02:40:16PM +0300, Joakim Koskela wrote:
> This patch resets the ipv4-related flags in the new flow as their
> content will otherwise depend on the bits of the ipv6 addresses the
> struct was previously used for. For example, fl4_tos might have
> RTO_ONLINK set, which usually prevents the right route from being
> found.
> 
> This bit was chopped off the larger patch dealing with the problems
> related to creating the bundles for inter-family tranformations.

This changes behaviour.  Previously the same TOS value would be
used all the way through.  With this it won't apply to the first
tunnel and every SA after it.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
