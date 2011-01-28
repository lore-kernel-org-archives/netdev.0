From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC PATCH] ipsec: fix IPv4 AH alignment on 32 bits
Date: Fri, 28 Jan 2011 14:51:08 +1000
Message-ID: <20110128045108.GA8351@gondor.apana.org.au>
References: <20110121.202021.32719353.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nicolas.dichtel@6wind.com, netdev@vger.kernel.org,
	christophe.gouault@6wind.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:41350 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754684Ab1A1EvO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Jan 2011 23:51:14 -0500
Content-Disposition: inline
In-Reply-To: <20110121.202021.32719353.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> wrote:
>
> We cannot just start rejecting the old 8-byte alignment on input if
> Linux has been using an 8-byte alignment since day one.
> 
> If you want this change to be considered seriously, you need to relax
> the AH4 input check.

I second your sentiment.  However, in this particular case it
would appear that our old implementation was also overly strict
in rejecting 32-bit alignment so even if we relax it now it still
wouldn't work with an old implementation once we reduce the padding
on output (unless you traffic was one-way only).

So perhaps an SA configuration flag is needed?

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
