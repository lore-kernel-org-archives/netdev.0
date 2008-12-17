From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] tcp: make urg+gso work for real this time
Date: Thu, 18 Dec 2008 08:27:25 +1100
Message-ID: <E1LD3vR-000753-Ja@gondolin.me.apana.org.au>
References: <20081217125505.GA8379@ms2.inr.ac.ru>
Cc: herbert@gondor.apana.org.au, ptesarik@suse.cz,
	ilpo.jarvinen@helsinki.fi, davem@davemloft.net,
	netdev@vger.kernel.org
To: kuznet@ms2.inr.ac.ru (Alexey Kuznetsov)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:57070 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751099AbYLQV1r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Dec 2008 16:27:47 -0500
In-Reply-To: <20081217125505.GA8379@ms2.inr.ac.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Alexey Kuznetsov <kuznet@ms2.inr.ac.ru> wrote:
> 
> If you are serious about this, also it would be a good idea
> to make SO_OOBINLINE default option. Consider this. At least this
> will allow to trap applications which will corrupt data stream
> earlier.

Well enabling SO_OOBINLINE would contradict POSIX.  Much as I'd
like to have it on by default, I don't think it's really worth it.

In any case such applications will break right now because URG
notifications can be merged due to out-of-order delivery, which
would cause OOB data to go in-band.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
