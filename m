From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] [IPSEC]: Add populate from packet (PFP) support
Date: Wed, 12 Dec 2007 21:52:56 +0800
Message-ID: <20071212135256.GA26200@gondor.apana.org.au>
References: <20071212032352.GA12890@hestia>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Joy Latten <latten@us.ibm.com>
To: Tyler Hicks <tyhicks@ou.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4777 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751428AbXLLNw7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Dec 2007 08:52:59 -0500
Content-Disposition: inline
In-Reply-To: <20071212032352.GA12890@hestia>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 11, 2007 at 07:23:52PM -0800, Tyler Hicks wrote:
> RFC 4301 requires us to associate each SPD entry with a set of flags to
> determine how to assign the selector values when creating a new SAD entry.
> 
> Each selector in the new xfrm_state can either be assigned using the
> corresponding selector in the xfrm_policy or with the corresponding value
> in the flowi.  Prior to this patch, the fields in the flowi were always
> used.
> 
> Signed-off-by: Tyler Hicks <tyhicks@ou.edu>

Thanks for the patch Tyler!

I think the kernel is fine as it is.  What we're doing is generating
the most specific selector possible for the larval SA and which lets
the KM do whatever it wants.

What RFC 4301 is asking for is for the mature SAs to have their
selectors either populated from the policy or the packet.

So for PFP the KM should fill out its SA selector according to its
PFP flags.  In other words we don't need PFP flags in the kernel
at all.

> +	if (pol->flags & XFRM_POLICY_PFP_SPORT) {
> +		x->sel.sport = xfrm_flowi_sport(fl);
> +		x->sel.sport_mask = htons(0xffff);
> +	} else {
> +		x->sel.sport = pol->selector.sport;
> +		x->sel.sport = pol->selector.sport_mask;

There's a typo here.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
