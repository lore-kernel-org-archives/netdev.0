From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] xfrm: Accept ESP packets regardless of UDP
	encapsulation mode
Date: Fri, 19 Dec 2008 21:19:27 +1100
Message-ID: <20081219101927.GA6898@gondor.apana.org.au>
References: <E1LDGgX-0007JE-T9@gondolin.me.apana.org.au> <1229603816.10402.178.camel@martin> <20081218205406.GA451@gondor.apana.org.au> <20081218.192313.250049404.davem@davemloft.net> <1229680846.13159.115.camel@martin>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	sbergman@cc.hut.fi
To: Martin Willi <martin@strongswan.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:52127 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753140AbYLSKTf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Dec 2008 05:19:35 -0500
Content-Disposition: inline
In-Reply-To: <1229680846.13159.115.camel@martin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 19, 2008 at 11:00:45AM +0100, Martin Willi wrote:
>
> I'll do some testing with a modified patch that accepts encapsulated
> packets on a non-encapsulating SA, but not vice-versa. This should solve
> that specific issue without introducing that (and hopefully no other)
> regression.

Yes this patch looks safe to me from ESP's point of view.

However, I still don't think this makes sense as ESP will no longer
react to an address change (since it may have no x->encap) should a
routing change cause NAT to occur.

Moreover, the fact that we need this patch in the first place
means that the two sides may be sending different encapsulations
to each other which should raise a big red flag since any stateful
firewall in the middle is going to break this completely.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
