From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: xfrm_state locking regression...
Date: Tue, 23 Sep 2008 14:47:07 +0800
Message-ID: <20080923064707.GA26836@gondor.apana.org.au>
References: <48D63E3A.90301@iki.fi> <48D66677.2040309@iki.fi> <20080922114256.GA27055@gondor.apana.org.au> <48D7971A.5050107@iki.fi> <20080922235012.GA23658@gondor.apana.org.au> <48D8763E.4030607@iki.fi> <20080923045951.GA26048@gondor.apana.org.au> <48D87BDA.8040804@iki.fi> <20080923052239.GA26233@gondor.apana.org.au> <48D88BCC.5030806@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Timo =?iso-8859-1?Q?Ter=E4s?= <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:36977 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752056AbYIWGrO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Sep 2008 02:47:14 -0400
Content-Disposition: inline
In-Reply-To: <48D88BCC.5030806@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 23, 2008 at 09:25:16AM +0300, Timo Ter=E4s wrote:
>
> Something like this. I just compile tested, so I'm not sure if it
> actually works.

It is quite clever :)
=20
> The corresponding put is in _destroy(). Added it as a final thing
> to do so hopefully compiler optimizes tail recursion to iteration.
> (Seemed to do that in my case.)

Yeah we should open code this to be absolutely sure that we don't
get killed by a stupid compiler.

However, I think this is still open to the same problem that my
patch had, i.e., if a dumper goes to sleep during the dump we may
prevent entries from being freed indefinitely.  Yes your idea
is better in that we may only withhold say a fraction (depending
on the order of deletion it could be anywhere from none to every
entry) of the entries instead of all of them, but fundamentally
the same issue is still there.

Considering the fact that dumps require root privileges I'm not
convinced as of yet that this is worth it.

Hmm, could we perhaps go back to your original scheme of keeping
everything on the list and see if we can use RCU to make it lockless
instead?

Cheers,
--=20
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
