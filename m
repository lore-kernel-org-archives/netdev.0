From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 2/2] tun: fallback if skb_alloc() fails on big packets
Date: Tue, 12 Aug 2008 18:14:09 +0800
Message-ID: <20080812101409.GA22114@gondor.apana.org.au>
References: <200808121624.56948.rusty@rustcorp.com.au> <200808121625.53703.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Max Krasnyansky <maxk@qualcomm.com>
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:58822 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751430AbYHLKON (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Aug 2008 06:14:13 -0400
Content-Disposition: inline
In-Reply-To: <200808121625.53703.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 12, 2008 at 04:25:53PM +1000, Rusty Russell wrote:
> skb_alloc produces linear packets (using kmalloc()).  That can fail,
> so should we fall back to making paged skbs.
> 
> My original version of this patch always allocate paged skbs for big
> packets.  But that made performance drop from 8.4 seconds to 8.8
> seconds on 1G lguest->Host TCP xmit.  So now we only do that as a
> fallback.
> 
> Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>

I'm not sure that this is really a good idea.  If anything then
tries to expand the head of this skb, they may fail and be forced
to drop the packet.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
