From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net 2/2] net: WARN if skb_checksum_help() is called on
 skb requiring segmentation
Date: Tue, 17 Jan 2012 17:15:02 +0000
Message-ID: <1326820502.2478.5.camel@bwh-desktop>
References: <1326753539.3065.31.camel@bwh-desktop>
	 <1326753818.3065.35.camel@bwh-desktop>
	 <20120117061115.GA14918@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:45243 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755120Ab2AQRPG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2012 12:15:06 -0500
In-Reply-To: <20120117061115.GA14918@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-01-17 at 17:11 +1100, Herbert Xu wrote:
> On Mon, Jan 16, 2012 at 10:43:38PM +0000, Ben Hutchings wrote:
> > skb_checksum_help() has never done anything useful with skbs that
> > require segmentation.  Setting skb->ip_summed = CHECKSUM_NONE makes
> > them invalid and provokes a later WARNing in skb_gso_segment().
> > 
> > Passing such an skb to skb_checksum_help() indicates a bug, so we
> > should warn about it immediately.  Move the warning from
> > skb_gso_segment() into a shared function, and add the calling function
> > name, gso_type and gso_size to it.
> > 
> > Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> > ---
> > The price for writing the warning format only once is having to pass in
> > the calling function name.  Not sure whether it's a good trade-off.
> 
> Do we really need the name since we should get a back trace?

If the compiler were to aggressively inline some of these functions then
it might no longer be clear where this was called from.  But I agree
that the name is normally redundant, so I'll take it out.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
