From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 3/5] xfrm: Traffic Flow Confidentiality for IPv4 ESP
Date: Fri, 3 Dec 2010 15:34:03 +0800
Message-ID: <20101203073403.GA2292@gondor.apana.org.au>
References: <1291132155-31277-1-git-send-email-martin@strongswan.org> <1291132155-31277-4-git-send-email-martin@strongswan.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-crypto@vger.kernel.org, netdev@vger.kernel.org
To: Martin Willi <martin@strongswan.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:49458 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751709Ab0LCHeG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Dec 2010 02:34:06 -0500
Content-Disposition: inline
In-Reply-To: <1291132155-31277-4-git-send-email-martin@strongswan.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 30, 2010 at 03:49:13PM +0000, Martin Willi wrote:
>
> +	if (skb->len >= tfcpadto) {
> +		clen = ALIGN(skb->len + 2, blksize);
> +	} else if (x->tfc.flags & XFRM_TFC_ESPV3 &&
> +		   x->props.mode == XFRM_MODE_TUNNEL) {
> +		/* ESPv3 TFC padding, append bytes to payload */
> +		tfclen = tfcpadto - skb->len;
> +		clen = ALIGN(skb->len + 2 + tfclen, blksize);
> +	} else {
> +		/* ESPv2 TFC padding. If we exceed the 255 byte maximum, use
> +		 * random padding to hide payload length as good as possible. */
> +		clen = ALIGN(skb->len + 2 + tfcpadto - skb->len, blksize);
> +		if (clen - skb->len - 2 > 255) {
> +			clen = ALIGN(skb->len + (u8)random32() + 2, blksize);
> +			if (clen - skb->len - 2 > 255)
> +				clen -= blksize;
> +		}

What is the basis of this random length padding?

Also, what happens when padto exceeds the MTU? Doesn't this
effectively disable PMTU-discovery?

I know that your last patch allows the padto to be set by PMTU.
But why would we ever want to use a padto that isn't clamped by
PMTU?

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
