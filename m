From: Herbert Xu <herbert.xu@redhat.com>
Subject: Re: [PATCH][RFC] tcp: fix ambiguity in the `before' relation
Date: Sat, 6 Jan 2007 07:34:43 +1100
Message-ID: <20070105203443.GA25173@gondor.apana.org.au>
References: <E1H2GGi-0008E5-00@gondolin.me.apana.org.au> <200701051151.16377@strip-the-willow> <20070105120157.GA21872@gondor.apana.org.au> <200701051249.13325@strip-the-willow>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1222 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750736AbXAEUfP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Jan 2007 15:35:15 -0500
To: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Content-Disposition: inline
In-Reply-To: <200701051249.13325@strip-the-willow>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 05, 2007 at 12:49:13PM +0000, Gerrit Renker wrote:
> 
> Since the old definition is not used in the way "before(x, y) && !before(y, x)", but rather in the
> fashion "before(x, y)" or "after(y, x)", the main advantage of the new definition is that it makes
> this type of use a safe case. 

This is not true because

	if (before(x, y))
		goto drop;

means that you're effectively using it as !before(x, y).  In other words,
the change is good if our code read

	if (before(x, y))
		process_packet();

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
