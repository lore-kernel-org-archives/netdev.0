From: Herbert Xu <herbert.xu@redhat.com>
Subject: Re: [PATCH][RFC] tcp: fix ambiguity in the `before' relation
Date: Fri, 5 Jan 2007 14:59:04 +1100
Message-ID: <20070105035904.GB18653@gondor.apana.org.au>
References: <E1H2GGi-0008E5-00@gondolin.me.apana.org.au> <200701041249.02459@strip-the-willow>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4477 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1030313AbXAED7g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jan 2007 22:59:36 -0500
To: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Content-Disposition: inline
In-Reply-To: <200701041249.02459@strip-the-willow>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 04, 2007 at 12:49:02PM +0000, Gerrit Renker wrote:
> 
> The key point where the new definition differs from the old is that _the relation_
> before(x,y) is unambiguous: the case "before(x,y) && before(y,x)" will no longer occur.

This is highly dependent on how the before macro is used in actual code.
There is nothing to suggest that this change won't create new security
holes in DCCP or any other protocol that uses this macro.  The only
way to be sure is to audit every single use.

So I think we need to do one of two things:

1) Audit every single before/after check to ensure that it works
correctly with the new definition.
2) Change before/after such that before(x, x+2^31) == !before(x+2^31, x).

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
