From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [XFRM]: Improve MTU estimation
Date: Fri, 4 Aug 2006 20:13:46 +1000
Message-ID: <20060804101345.GA17583@gondor.apana.org.au>
References: <44D30A48.4050403@trash.net> <44D312EF.8010202@trash.net> <20060804100121.GA17239@gondor.apana.org.au> <44D31CCE.7020301@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Kernel Netdev Mailing List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:50193 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1161070AbWHDKNt
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Aug 2006 06:13:49 -0400
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <44D31CCE.7020301@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 04, 2006 at 12:09:18PM +0200, Patrick McHardy wrote:
> 
> I was wondering why the old code distinguished between transport mode
> and tunnel mode, I couldn't spot anything that would be affected. I'll
> look into the transport mode case again.

The problem is basically you don't know a priori the size of the IP
options.  So you assume the worst case where the IP options causes
the largest amount of padding for encryption (IP option length itself
must be a multiple of 4, so for a block size of 8 the worst is 4,
and the worst is 12 for a block size of 16).

Of course it gets hairier if you have ESP padding.  I'm not even sure
if the current code gets that right.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
