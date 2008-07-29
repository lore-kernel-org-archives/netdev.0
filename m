From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC] sctp/tcp: Question -- ICMPv4 length check (not) redundant?
Date: Tue, 29 Jul 2008 09:56:49 +0800
Message-ID: <20080729015649.GA15441@gondor.apana.org.au>
References: <20080727045121.GA419@gondor.apana.org.au> <20080728112527.GB7589@gerrit.erg.abdn.ac.uk> <488DC63A.3070309@hp.com> <20080728170846.GB3762@gerrit.erg.abdn.ac.uk> <488E0192.9030406@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Gerrit Renker <gerrit@erg.abdn.ac.uk>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Vlad Yasevich <vladislav.yasevich@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:36979 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752845AbYG2B5H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jul 2008 21:57:07 -0400
Content-Disposition: inline
In-Reply-To: <488E0192.9030406@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 28, 2008 at 01:27:46PM -0400, Vlad Yasevich wrote:
> 
> So the suggestion really is then to remove the length check icmp_unreach()?

Yes.

> Because as it stands right now, the protocol error handler will not be invoked
> if we don't have the iphdr + 8 bytes worth of data.  That's is actually a requirement
> from the ICMP rfc 792.

That requirement only makes sense if the original packet has at
least 8 bytes of payload.  Since the RFC doesn't talk about
padding in case it doesn't have 8 byte, the behaviour in that
case is clearly undefined.

As far as Linux is concerned, we've never done padding if there
is less than 8 bytes of payload.  So as such we must be prepared
to deal with that on the input side as well.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
