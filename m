From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] add %pM printf format specifier
Date: Sat, 25 Oct 2008 10:00:45 +0200
Message-ID: <1224921645.3919.48.camel@johannes.berg>
References: <1224892008.3919.27.camel@johannes.berg>
	 <1224898906.6636.74.camel@localhost>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-9nCa3SratgFvS1NXcOIt"
Cc: "David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:59504 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751947AbYJYIAz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Oct 2008 04:00:55 -0400
In-Reply-To: <1224898906.6636.74.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-9nCa3SratgFvS1NXcOIt
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Fri, 2008-10-24 at 18:41 -0700, Joe Perches wrote:


> > +static char *mac_address(char *buf, char *end, u8 *addr, int field_wid=
th, int precision, int flags)
> > +{
> > +	/* room for 6 * two hex digits, 5 colons and trailing zero */
> > +	char mac[18];
> > +	char *p =3D mac, *pend =3D mac + sizeof(mac);
> > +	int i;
> > +
> > +	for (i=3D0; i < 6; i++) {
> > +		p =3D number(p, pend, addr[i], 16, 2, -1, SMALL | ZEROPAD);
> > +		*p++ =3D ':';
> > +	}
>=20
> For consistency, shouldn't the function name be mac_address_string?
>=20
> I (and perhaps Harvey H) would be happier with:
>=20
> 	char mac[18];
> 	char *p =3D mac;
> 	int i;
>=20
> 	for (i =3D 0; i < 5; i++) {
> 		p =3D pack_hex_byte(p, addr[i]);
> 		*p++ =3D ':';
> 	}
> 	p =3D pack_hex_byte(p, addr[5]);
> 	*p =3D '\0';
>=20
> Smaller, faster, etc...

Heh. I wasn't aware of pack_hex_byte. Not sure it really is smaller
though with the inlining, and kernel messages ought not to be
performance sensitive. OTOH, this is _way_ simpler in terms of code,
I'll send v2.

> Also, as the number of %p(foo) types increases, perhaps
> something like sparse could validate the printf argument
> types?

Hard to do really, what guarantees that a MAC address is 6 bytes, which
is the relevant thing? :)

johannes

--=-9nCa3SratgFvS1NXcOIt
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIcBAABAgAGBQJJAtIqAAoJEKVg1VMiehFY48oQAKsFgyZFb6wGxOBxdS+7IB0X
QNA/MPAxzOrK06V+Uwd9q90Rkf1waAuLMJVfyEvH9jpKoJoer45kEFG4rZd6fuZS
dOwvDvvQ/f6Us1s5Gdwip5H76X0Yn89vgF/6fPzfdK2zgU8xXDUonZ75240CuVeF
MGXr1eq23UcpYjT994E97/SkR/pQMdIcVMfW7sYRmpjr8iHmNCsaVYVkrHX08wCK
RsPCDF5Y4ZZUtnRyXmEXNUBncf0H3j5Kt/tAKD7ps/G0q9U6cQtG+Ey4tFA4wicZ
SjWqQBjoZ2+TJmCLWgeAyuTZdlS3MB7eWnZye8mM+d+ckFBNl2uI+kk5MNe79OMQ
S4EL/mCZdaJlzqVwcEmqh4mbmR4obt7dUwmjfbXbJ9PcpVie7K9OElXWuM3sCTPt
uMkimEFZGN3TulT1bbNqkgPS14SUeOGwZ2jKfgM8HrdTCpn3tkN4yiKyPDZE1WKL
tWrix+UoTgfeKNlvXhZlobOYvOw4CS+XIIFFuLB9si3HIRXiM6mI7ROpbki7K5gp
JAh7Iog5mJp+pp1RwldUF07FVDJ1TLNQWZ2xRrfcvJha0Ev5pygDJRZ5y0E1Lf0h
EB6hzZV6EFgWhtSbjRhmT5lkwz4mTXG+jkl1mMw3OdcbX1y0zOCEfcnxYzbIugf8
OYD8xILQoCLJ1Cc5XavM
=yMID
-----END PGP SIGNATURE-----

--=-9nCa3SratgFvS1NXcOIt--

