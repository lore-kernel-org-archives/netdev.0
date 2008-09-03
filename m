From: David Miller <davem@davemloft.net>
Subject: Re: xfrm_state locking regression...
Date: Tue, 02 Sep 2008 23:14:20 -0700 (PDT)
Message-ID: <20080902.231420.255718595.davem@davemloft.net>
References: <20080903053935.GA8428@gondor.apana.org.au>
	<48BE245D.3060905@iki.fi>
	<20080903055041.GA8547@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: timo.teras@iki.fi, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33233
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753482AbYICGO1 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Sep 2008 02:14:27 -0400
In-Reply-To: <20080903055041.GA8547@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 3 Sep 2008 15:50:41 +1000

> On Wed, Sep 03, 2008 at 08:45:01AM +0300, Timo Ter=E4s wrote:
> >
> > > ipsec: Move state dump list unlinking into GC
> > >=20
> > > This patch moves the unlinking of x->all (for dumping) into the
> > > GC and changes the lock to xfrm_cfg_mutex.
> >=20
> > Shouldn't this also change the locking in all places where
> > x->all is used?
>=20
> You're right.  I'd forgotten about the larval states for some
> reason, probably because I just added them to the list :)
>=20
> So let's keep xfrm_state_lock and just move it.

How about we un-crap the reference counting?

Every list an object lives on is an external reference, and that is
the rule that is violated by this ->all list handling.

And that's why we need to take a single shared lock twice just to get
rid of an xfrm_state object now.
