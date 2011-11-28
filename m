From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next] tcp: tcp_sendmsg() wrong access to
 sk_route_caps
Date: Mon, 28 Nov 2011 17:20:42 +0000
Message-ID: <1322500843.26733.2.camel@bwh-desktop>
References: <1322476067.2292.12.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1322477197.2024.4.camel@Joe-Laptop>
	 <1322496298.2292.76.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1322499255.2024.22.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	=?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>,
	Andrew Morton <akpm@linux-foundation.org>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:47768 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753679Ab1K1RUv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2011 12:20:51 -0500
In-Reply-To: <1322499255.2024.22.camel@Joe-Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-11-28 at 08:54 -0800, Joe Perches wrote:
> On Mon, 2011-11-28 at 17:04 +0100, Eric Dumazet wrote:
> > Le lundi 28 novembre 2011 =C3=A0 02:46 -0800, Joe Perches a =C3=A9c=
rit :
> > > On Mon, 2011-11-28 at 11:27 +0100, Eric Dumazet wrote:
> > > > +	sg =3D !!(sk->sk_route_caps & NETIF_F_SG);
> > > As sg is now bool, using !! is unnecessary.
> > > A commit was done recently to remove one.
> > > 3ad9b358e03fd9dbf6705721490c811b666b0fe2
> > Hmm... I find it dangerous and error prone. Obviously not at the ti=
me we
> > commit such changes, but later, because a future reader might be fo=
oled.
> > Using !!(expr) is pretty clear about the potential problem, and
> > generates no extra code if a bool is used for the target.
>=20
> Though I don't think
> 	bool =3D expr;
> is particularly error prone,
> spatch shows 58 uses of
> 	bool =3D !!expr;
> in net-next drivers/net.
>=20
> It might be useful to standardize on either the
> implicit or explicit !! style.
>=20
> I think !! is an intentional and sensible style
> and should be the preferred use.

I see it as a workaround for the historical lack of a real bool type in
C.

> Perhaps a checkpatch warning should be issued
> when the implicit cast is used.

checkpatch can't do type-checking; maybe you mean sparse.

Ben.

--=20
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
