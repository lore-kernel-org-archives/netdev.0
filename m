From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: IPv6 xfrm GSO fragmentation bug
Date: Mon, 31 Aug 2015 15:35:26 +0800
Message-ID: <20150831073526.GA31958@gondor.apana.org.au>
References: <20150830082432.GA25588@gondor.apana.org.au>
 <20150831071916.GG25499@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:32833 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751372AbbHaHfu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Aug 2015 03:35:50 -0400
Content-Disposition: inline
In-Reply-To: <20150831071916.GG25499@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 31, 2015 at 09:19:16AM +0200, Steffen Klassert wrote:
>
> As far as I remember, this was to catch local message size
> errors before __xfrm6_output calls ip6_fragment which would
> use icmpv6_send for the error notification. IPv4 does not do
> fragmentation in the xfrm4_output functions, so this mtu
> check was not needed there.
> 
> I think just adding the gso checks should be fine.

I see where the bug came from.  Indeed IPv6 does do fragmentation
but only for tunnel mode.  While your patch added a check that also
affected transport mode.  So in addition to the GSO fix we should
also make the MTU check conditional to tunnel mode.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
