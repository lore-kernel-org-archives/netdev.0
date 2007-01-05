From: Herbert Xu <herbert.xu@redhat.com>
Subject: Re: [PATCH][RFC] tcp: fix ambiguity in the `before' relation
Date: Fri, 5 Jan 2007 23:01:57 +1100
Message-ID: <20070105120157.GA21872@gondor.apana.org.au>
References: <E1H2GGi-0008E5-00@gondolin.me.apana.org.au> <200701041249.02459@strip-the-willow> <20070105035904.GB18653@gondor.apana.org.au> <200701051151.16377@strip-the-willow>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2616 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1161067AbXAEMCZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Jan 2007 07:02:25 -0500
To: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Content-Disposition: inline
In-Reply-To: <200701051151.16377@strip-the-willow>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 05, 2007 at 11:51:16AM +0000, Gerrit Renker wrote:
>      
> |  2) Change before/after such that before(x, x+2^31) == !before(x+2^31, x).
> This is what the new definition does: in the old definition we always have that
> before(x, x+2^31) == before(x+2^31, x).

Sorry but the new definition has exactly the same problem since

	before(x, x+2^31) == before(x+2^31, x) == 0

While the old definition had

	before(x, x+2^31) == before(x+2^31, x) == 1

Both are equally bad.  It's only unambiguous if

	before(x, x+2^31) == !before(x+2^31, x) == 0

or

	before(x, x+2^31) == !before(x+2^31, x) == 1

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
