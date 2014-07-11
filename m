From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH net] dns_resolver: Null-terminate the right string
Date: Fri, 11 Jul 2014 21:31:25 +0100
Message-ID: <1405110685.26540.95.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-jAKL/xctisbLCDa15iUM"
Cc: netdev <netdev@vger.kernel.org>,
	Manuel =?ISO-8859-1?Q?Sch=F6lling?= <manuel.schoelling@gmx.de>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:36249 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752169AbaGKUbk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jul 2014 16:31:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-jAKL/xctisbLCDa15iUM
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

*_result[len] is parsed as *(_result[len]) which is not at all what we
want to touch here.

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
 net/dns_resolver/dns_query.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/dns_resolver/dns_query.c b/net/dns_resolver/dns_query.c
index 9acec61f..dd8696a 100644
--- a/net/dns_resolver/dns_query.c
+++ b/net/dns_resolver/dns_query.c
@@ -150,7 +150,7 @@ int dns_query(const char *type, const char *name, size_=
t namelen,
 		goto put;
=20
 	memcpy(*_result, upayload->data, len);
-	*_result[len] =3D '\0';
+	(*_result)[len] =3D '\0';
=20
 	if (_expiry)
 		*_expiry =3D rkey->expiry;

--=20
Ben Hutchings
To err is human; to really foul things up requires a computer.

--=-jAKL/xctisbLCDa15iUM
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUAU8BJoue/yOyVhhEJAQqkuw//XemJQexwjVvrmVvmzkMMIZkD8t3ovbc5
r9SRGs8TWOset3zQAeIWZ+vStA+msAzaRz+9DvE54eQB0gk/frO7+c3DDw6xXKpb
/0lEHzA7afBJA7ZX9GLiKPzjewjv6C9JQ2OKkDO3vB9UQq+oPorndbiSzsrD7SFh
q39ePcRKmn/Ii28odgRrITifRdJgWoae1HoJEn43zyxZ+0f1UxFeoqrGDU6We3Tp
XkYyH1mMgdoc1Zz3s48EOBCNghVJhpR6m6ih7oKVE8+p56uURVIGyduNoMoG3kg2
3bK6vo1DJMI50K57CtwLqhFBbQ7NWFVbUp6eA97YVCxN5c8Zla8op+oi0VQkJIkR
dkvgRi2hjSPjFFrks/cFNlDEFGDyeKD2KUo8Vz3Ev9mKXA0AJnRjzpDJjeBFPphU
4e7kZEjONmk0R3Gq57mU6kpQLOHcOg3WViKM+kJSaDs/W8Hw6n8LDJ4JxmRZLuyp
P8yCXyvVeGBPuxm84BT0TaYwlwViQ7SZ/TWuFVtaQKfYOw8HxI9GYdxxIOq2n4ch
l0mKZ03L7Z/WbwV0fU0IisVLs597TC84CE8m7jt7QUri9r/1hJKmm2mgkIuvz/pY
XduRkkELtrYdwKG35bLAup+X3hmtLEZbUqz04MS1Fg+vu9Mav2yKg7ggof1AS89m
YMiMtAbV4Vs=
=DB7f
-----END PGP SIGNATURE-----

--=-jAKL/xctisbLCDa15iUM--
