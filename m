From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [RFC] remove NLA_STRING NUL trimming
Date: Fri, 23 Mar 2007 15:40:43 +0100
Message-ID: <1174660843.3366.31.camel@johannes.berg>
References: <1174605138.3588.54.camel@johannes.berg>
	 <20070323142046.GC521@postel.suug.ch>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-ebCkoVRSQDzQS0DHnK0N"
Cc: netdev <netdev@vger.kernel.org>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:45137 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1945894AbXCWOlz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Mar 2007 10:41:55 -0400
In-Reply-To: <20070323142046.GC521@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-ebCkoVRSQDzQS0DHnK0N
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Fri, 2007-03-23 at 15:20 +0100, Thomas Graf wrote:

> It's not really removed, the trailing NUL is just ignored when checking
> the length of the attribute.=20

Good point.

> This is needed for older netlink families
> where strings are not always NUL terminated, yet we still need to accept
> the additional byte needed in case it is present. This validation is
> strictly necessary, otherwise nla_strcmp() and others will fail.

Ok.

> > For wireless, we have a few places where we need to be able to accept
> > any (even binary) values, for example for the SSID; the SSID can validl=
y
> > end with \0 and I'd still love to be able to take advantage of
> > NLA_STRING and .len =3D 32 so I don't need to check the length myself.
> > However, given the code above, an SSID with a terminating \0 would be
> > reduced by one character.
>=20
> I suggest that you introduce NLA_BINARY which enforces a maximum length.

Alright, I'll post a patch in a bit.

johannes

--=-ebCkoVRSQDzQS0DHnK0N
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD4DBQBGA+br/ETPhpq3jKURAoamAKCTMY5RaUWtTnDnoruodZ8rkM/SAwCXfo0M
sK1tzJ+iRyII8J2A4MP7jg==
=ffDa
-----END PGP SIGNATURE-----

--=-ebCkoVRSQDzQS0DHnK0N--

