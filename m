From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: IPsecv6  tunnel mode fragmentation
Date: Thu, 9 Dec 2010 20:44:29 +0800
Message-ID: <20101209124429.GA27083@gondor.apana.org.au>
References: <20101208071109.GA14537@gondor.apana.org.au> <1291861242.11224.265.camel@faith.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, samudrala@us.ibm.com, rashmin@us.ibm.com,
	davem@davemloft.net, dlstevens@us.ibm.com
To: Joy Latten <latten@austin.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:42056 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755411Ab0LIMoe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Dec 2010 07:44:34 -0500
Content-Disposition: inline
In-Reply-To: <1291861242.11224.265.camel@faith.austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 08, 2010 at 08:20:42PM -0600, Joy Latten wrote:
>
> We did attempt to debug in kernel to see whether the pkt-too-big 
> was being discarded... from what we saw, it did not seem to be. 
> Also, an "ip -6  r l c" on TARGET showed the adjusted mtu for the route 
> to HOST, which the pkt-too-big was for. tunnel's mtu is untouched.

Oh I see what you're saying.  Sorry I misunderstood the issue
earlier.

> Thus why I reached my original conclusion, that perhaps 
> esp/ah disregard inner hdr mtu since does not fragment.
> Thus inner pkt will be too big when it reaches link for 
> inner/original pkt to be sent on.

Indeed we don't have any fragmentation capbility at all on the
IPsec output path inside the tunnel.  For IPv4 this isn't an issue
because the other end can perform fragmentation.  This is clearly
not an option with IPv6.

I'll look into this.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
