From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: TX pre-headers...
Date: Mon, 9 Feb 2009 21:19:12 +1100
Message-ID: <20090209101912.GA8338@gondor.apana.org.au>
References: <20090206.014107.231141422.davem@davemloft.net> <20090209100713.GA8299@gondor.apana.org.au> <20090209.021403.56830306.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:58536 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752776AbZBIKTP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Feb 2009 05:19:15 -0500
Content-Disposition: inline
In-Reply-To: <20090209.021403.56830306.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 09, 2009 at 02:14:03AM -0800, David Miller wrote:
> 
> Indeed, I noticed needed_headroom when I set out to start coding
> things up. :)
> 
> There are all sorts of cases that won't work well, as you implicitly
> suggest.  For example, forwarding to a path that encapsulates to a GRE
> or other type of tunnel.
> 
> For IPSEC we're predominantly COW'ing the data anyways, so...

Yes tunneling (especially when it's hidden by netfilter) is the
hard part.

Here's a thought, what if we had your global maximum, and every
time we have to reallocate a packet because of a failed head
room check, we increase the maximum by the needed amount (we should
add a ceiling in case some buggy path ignores this maximum when
allocating a new packet).

This way even tunnels could benefit from not having to copy all
the time.

As a failed check should be rare (given that we're continuously
increasing it) the overhead in updating the maximum should be
reasonable.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
