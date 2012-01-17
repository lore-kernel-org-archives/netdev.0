From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH net 2/2] net: WARN if skb_checksum_help() is called on
	skb requiring segmentation
Date: Tue, 17 Jan 2012 17:11:15 +1100
Message-ID: <20120117061115.GA14918@gondor.apana.org.au>
References: <1326753539.3065.31.camel@bwh-desktop> <1326753818.3065.35.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:53567 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750916Ab2AQGLW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2012 01:11:22 -0500
Content-Disposition: inline
In-Reply-To: <1326753818.3065.35.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 16, 2012 at 10:43:38PM +0000, Ben Hutchings wrote:
> skb_checksum_help() has never done anything useful with skbs that
> require segmentation.  Setting skb->ip_summed = CHECKSUM_NONE makes
> them invalid and provokes a later WARNing in skb_gso_segment().
> 
> Passing such an skb to skb_checksum_help() indicates a bug, so we
> should warn about it immediately.  Move the warning from
> skb_gso_segment() into a shared function, and add the calling function
> name, gso_type and gso_size to it.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> ---
> The price for writing the warning format only once is having to pass in
> the calling function name.  Not sure whether it's a good trade-off.

Do we really need the name since we should get a back trace?

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
