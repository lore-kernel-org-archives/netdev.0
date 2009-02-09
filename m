From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: TX pre-headers...
Date: Mon, 09 Feb 2009 16:39:48 +0100
Message-ID: <m3zlgvaabf.fsf@intrepid.localdomain>
References: <20090206.014107.231141422.davem@davemloft.net>
	<20090209100713.GA8299@gondor.apana.org.au>
	<20090209.021403.56830306.davem@davemloft.net>
	<20090209101912.GA8338@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:35506 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754765AbZBIPjx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Feb 2009 10:39:53 -0500
In-Reply-To: <20090209101912.GA8338@gondor.apana.org.au> (Herbert Xu's message of "Mon\, 9 Feb 2009 21\:19\:12 +1100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu <herbert@gondor.apana.org.au> writes:

> Yes tunneling (especially when it's hidden by netfilter) is the
> hard part.
>
> Here's a thought, what if we had your global maximum, and every
> time we have to reallocate a packet because of a failed head
> room check, we increase the maximum by the needed amount (we should
> add a ceiling in case some buggy path ignores this maximum when
> allocating a new packet).
>
> This way even tunnels could benefit from not having to copy all
> the time.
>
> As a failed check should be rare (given that we're continuously
> increasing it) the overhead in updating the maximum should be
> reasonable.

I agree.

OTOH and FWIW my stuff (= WAN) alone without stacking fits in 32 bytes,
the typical max case is 10 bytes for Frame-Relay header + 14 bytes for
Ethernet header + 4 bytes for 802.1Q tag = 28 bytes.

OTOH I wonder if these changes make the dev->hard_header_len no longer
needed.
-- 
Krzysztof Halasa
