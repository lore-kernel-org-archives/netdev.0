From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 1/4] xfrm: increment genid before bumping state genids
Date: Wed, 31 Mar 2010 18:50:23 +0800
Message-ID: <20100331105023.GA12845@gondor.apana.org.au>
References: <1270030626-16687-1-git-send-email-timo.teras@iki.fi> <1270030626-16687-3-git-send-email-timo.teras@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Timo Teras <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([216.59.3.182]:44763 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752453Ab0CaKu0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Mar 2010 06:50:26 -0400
Content-Disposition: inline
In-Reply-To: <1270030626-16687-3-git-send-email-timo.teras@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 31, 2010 at 01:17:03PM +0300, Timo Teras wrote:
> __xfrm_state_bump_genids() is used to update the genid of all
> matching xfrm_state's, so any bundle using the state would get
> refreshed with the newly inserted state.
> 
> However, since __xfrm_state_bump_genids() is called before the
> __xfrm_state_insert() which actually bumps the genid counter,
> it is possible that the genid was not updated at all (if there
> was no state inserts previously).
> 
> This is fixed by moving the genid incrementation to
> __xfrm_state_bump_genids() so the older states are guaranteed
> to get different genid.
> 
> Signed-off-by: Timo Teras <timo.teras@iki.fi>

It would appear that not all xfrm_state_insert calls are preceded
by xfrm_state_bump_genids so this patch isn't correct.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
