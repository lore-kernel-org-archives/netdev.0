From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: xfrm_state locking regression...
Date: Tue, 23 Sep 2008 21:07:09 +0800
Message-ID: <20080923130709.GA29902@gondor.apana.org.au>
References: <20080923052239.GA26233@gondor.apana.org.au> <48D88BCC.5030806@iki.fi> <20080923064707.GA26836@gondor.apana.org.au> <48D8B967.8000107@iki.fi> <20080923112416.GA28946@gondor.apana.org.au> <48D8DC28.1020001@iki.fi> <20080923121414.GB29257@gondor.apana.org.au> <48D8E045.8040508@iki.fi> <20080923125615.GC29524@gondor.apana.org.au> <48D8E8A9.8050100@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Timo =?iso-8859-1?Q?Ter=E4s?= <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:53890 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750849AbYIWNHP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Sep 2008 09:07:15 -0400
Content-Disposition: inline
In-Reply-To: <48D8E8A9.8050100@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 23, 2008 at 04:01:29PM +0300, Timo Ter=E4s wrote:
>
> So, what to do?
> 1. Go back to: list_del_rcu, xfrm_state_hold(all.next) on delete and
>    xfrm_state_put(all.next) on destruct.
> 2. Add per-entry hlist of walkers currently referencing it.
> 3. Use the global walker list.
>=20
> 1 can keep memory allocated until userland wakes up. 2 & 3 can make
> the delete of that entry slow if there's many walkers suspended.

I'd cross 3 off the list because 2 is just so much better :)

I'd slightly lean towards 2 but now that you mention it yes even
that is vulnerable to loads of dumpers sitting on the same entry.
So SELINUX folks wouldn't like that :)

> Btw. the current stuff in net-next is broken. There's no locking
> for xfrm_state_walkers list handling.

What about xfrm_cfg_mutex?

Cheers,
--=20
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
