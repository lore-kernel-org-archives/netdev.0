From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: xfrm_state locking regression...
Date: Tue, 23 Sep 2008 20:56:15 +0800
Message-ID: <20080923125615.GC29524@gondor.apana.org.au>
References: <20080923045951.GA26048@gondor.apana.org.au> <48D87BDA.8040804@iki.fi> <20080923052239.GA26233@gondor.apana.org.au> <48D88BCC.5030806@iki.fi> <20080923064707.GA26836@gondor.apana.org.au> <48D8B967.8000107@iki.fi> <20080923112416.GA28946@gondor.apana.org.au> <48D8DC28.1020001@iki.fi> <20080923121414.GB29257@gondor.apana.org.au> <48D8E045.8040508@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Timo =?iso-8859-1?Q?Ter=E4s?= <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:52831 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750869AbYIWM4W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Sep 2008 08:56:22 -0400
Content-Disposition: inline
In-Reply-To: <48D8E045.8040508@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 23, 2008 at 03:25:41PM +0300, Timo Ter=E4s wrote:
>
> There can be a lot of xfrm_state structs. As in thousands. So it
> will take more memory then. hlist would be enough, so it'd be a
> 4/8 bytes addition. Single pointer would not be enough as we can
> have multiple walks on the same entry.

Right, we need doubly linked lists in the walkers to ease unlinking.
But only a single pointer (i.e., an hlist) is needed in xfrm_state.

> I was thinking about the same. That's why I wasn't so sure if this is
> better. In practice there aren't many walks active. Maybe we limit
> the maximum simultaneous walks?

That sounds like a hack :)

> But in real life, there is only a one or two walkers if any active.
> So I would not consider a global update too expensive. But if you thi=
nk
> it might become a problem, I'd add an hlist to xfrm_state of walkers
> referencing that entry.

Well in real life dumps don't tend to get suspended either :)
In any case, a suspended dump is only going to pin down some
memory, while a very long list walk may kill the box.

Cheers,
--=20
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
