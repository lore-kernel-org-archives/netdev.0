From: Bill Fink <billfink@mindspring.com>
Subject: Re: TSO trimming question
Date: Fri, 21 Dec 2007 14:37:07 -0500
Message-ID: <20071221143707.fbb0ae60.billfink@mindspring.com>
References: <20071221030648.389669c4.billfink@mindspring.com>
	<20071221.012720.67812056.davem@davemloft.net>
	<20071221092927.GA32434@gondor.apana.org.au>
	<20071221.013642.29817274.davem@davemloft.net>
	<20071221055822.8d977800.billfink@mindspring.com>
	<20071221135437.16fa63c8.billfink@mindspring.com>
	<Pine.LNX.4.64.0712212056220.31652@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Netdev <netdev@vger.kernel.org>, John Heffner <jheffner@psc.edu>
To: "Ilpo =?ISO-8859-1?Q?J=E4rvinen" ?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-spurfowl.atl.sa.earthlink.net ([209.86.89.66]:51406
	"EHLO elasmtp-spurfowl.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753776AbXLUThO convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Dec 2007 14:37:14 -0500
In-Reply-To: <Pine.LNX.4.64.0712212056220.31652@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 21 Dec 2007, Ilpo J=E4rvinen wrote:

> On Fri, 21 Dec 2007, Bill Fink wrote:
>=20
> > On Fri, 21 Dec 2007, Bill Fink wrote:
> >=20
> > > Or perhaps even:
> > >=20
> > > 	/* Ok, it looks like it is advisable to defer.  */
> > > 	tp->tso_deferred =3D jiffies;
> > >=20
> > > 	/* need to return a non-zero value to defer, which means won't
> > > 	 * defer if jiffies =3D=3D 0 but it's only a 1 in 4 billion even=
t
> > > 	 * (and avoids a compare/branch by not checking jiffies)
> > > 	 /
> > >         return jiffies;
> >=20
> > Ack.  I introduced my own 64-bit to 32-bit issue (too late at night=
).
> > How about:
> >=20
> > 	/* Ok, it looks like it is advisable to defer.  */
> > 	tp->tso_deferred =3D jiffies;
> >=20
> > 	/* this won't defer if jiffies =3D=3D 0 but it's only a 1 in
> > 	 * 4 billion event (and avoids a branch)
> > 	 */
> > 	return (jiffies !=3D 0);
>=20
> I'm not sure how the jiffies work but is this racy as well?
>=20
> Simple return tp->tso_deferred; should work, shouldn't it? :-)

As long as tp->tso_deferred remains u32, pending the other issue.

						-Bill
