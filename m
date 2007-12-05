From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: sockets affected by IPsec always block (2.6.23)
Date: Wed, 5 Dec 2007 18:39:27 +1100
Message-ID: <20071205073927.GA12413@gondor.apana.org.au>
References: <20071205065132.GA11476@gondor.apana.org.au> <20071204.231200.117152338.davem@davemloft.net> <20071205071607.GA11852@gondor.apana.org.au> <20071204.233432.136250076.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: simon@fire.lp0.eu, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4098 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751564AbXLEHjd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Dec 2007 02:39:33 -0500
Content-Disposition: inline
In-Reply-To: <20071204.233432.136250076.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 04, 2007 at 11:34:32PM -0800, David Miller wrote:
> 
> TCP has some built-in assumptions about characteristics of
> interent links and what constitutes a timeout which is "too long"
> and should thus result in a full connection failure.
> 
> IPSEC changes this because of IPSEC route resolution via
> ISAKMP.
> 
> With this in mind I can definitely see people preferring
> the "block until IPSEC resolves" behavior, especially for
> something like, say, periodic remote backups and stuff like
> that where you really want the thing to just sit and wait
> for the connect() to succeed instead of failing.

Hmm, but connect(2) should succeed in that case thanks to the
blackhole route, no? The subsequent SYNs will then be dropped
until the IPsec SAs are in place.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
