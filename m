From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Deadlock with icmpv6fuzz
Date: Wed, 28 Jan 2009 20:35:07 +1100
Message-ID: <20090128093507.GA15956@gondor.apana.org.au>
References: <20090120204743.GA25797@alice> <20090126.213112.197185044.davem@davemloft.net> <20090127075356.GA6255@alice>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: Eric Sesterhenn <snakebyte@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:32922 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752390AbZA1JfW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Jan 2009 04:35:22 -0500
Content-Disposition: inline
In-Reply-To: <20090127075356.GA6255@alice>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 27, 2009 at 07:53:56AM +0000, Eric Sesterhenn wrote:
> 
> With current -git i get a different issue (and the box stays alive)

I think I see the problem (though I must say that this code is
really hairy, it's almost like I'm reading your average device
driver!).

When a protocol such as raw or UDP parses extension headers it
stores a pointer to the parsed option in ipv6_txoptions instead
of copying the option.

So as long as you only use it during the system call nothing bad
happens, but once you put the cork on, the next send is going to
go boom.

Any volunteers to fix this?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
