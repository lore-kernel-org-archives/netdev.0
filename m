From: David Miller <davem@davemloft.net>
Subject: Re: tbench wrt. loopback TSO
Date: Wed, 05 Nov 2008 04:09:43 -0800 (PST)
Message-ID: <20081105.040943.03609283.davem@davemloft.net>
References: <20081105114900.GA18691@ioremap.net>
	<20081105.035454.87914782.davem@davemloft.net>
	<Pine.LNX.4.64.0811051355550.23792@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: zbr@ioremap.net, netdev@vger.kernel.org, efault@gmx.de,
	mingo@elte.hu, a.p.zijlstra@chello.nl, herbert@gondor.apana.org.au
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33518
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751639AbYKEMKI convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Nov 2008 07:10:08 -0500
In-Reply-To: <Pine.LNX.4.64.0811051355550.23792@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Wed, 5 Nov 2008 14:04:14 +0200 (EET)

> On Wed, 5 Nov 2008, David Miller wrote:
>=20
> > From: Evgeniy Polyakov <zbr@ioremap.net>
> > Date: Wed, 5 Nov 2008 14:49:00 +0300
> >=20
> > > But what if we just remove that trimming at all? This may result =
in
> > > a not fully filled tso frame, but who cares if we copy data from
> > > userspace anyway, will add another potentially small copy at send=
ing
> > > time?
> >=20
> > Ok, the only part I care about is whether taking away this modulus
> > will result in a sub-MSS sized packet on the wire, which is
> > undesirable.
> >
> > The send logic will prevent this, right?
>=20
> I don't see what currently would do that. We'd need to resegment skbs=
=20
> there then...

Look at tcp_mss_split_point() in tcp_output.c

I think it ends up doing exactly this.

'needed' is set to min(skb->len, window)

and the return value is "needed - (needed % mss_now)"

The caller splits up the TSO segment as needed to satisfy this
returned limit.

That should effectively chop off the sub-mss part.
