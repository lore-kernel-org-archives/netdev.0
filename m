From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH net 1/2] isdn_ppp: Add checks for allocation failure in
 isdn_ppp_open()
Date: Wed, 14 Oct 2015 18:51:14 +0100
Message-ID: <1444845074.31451.21.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-xOnacfr6LJaT0/BCLeIt"
Cc: Karsten Keil <isdn@linux-pingi.de>, linux-ppp@vger.kernel.org,
	netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-ppp-owner@vger.kernel.org>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-xOnacfr6LJaT0/BCLeIt
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Compile-tested only.

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
=C2=A0drivers/isdn/i4l/isdn_ppp.c | 6 ++++++
=C2=A01 file changed, 6 insertions(+)

diff --git a/drivers/isdn/i4l/isdn_ppp.c b/drivers/isdn/i4l/isdn_ppp.c
index c4198fa..86f9abe 100644
--- a/drivers/isdn/i4l/isdn_ppp.c
+++ b/drivers/isdn/i4l/isdn_ppp.c
@@ -301,6 +301,8 @@ isdn_ppp_open(int min, struct file *file)
=C2=A0	is->compflags =3D 0;
=C2=A0
=C2=A0	is->reset =3D isdn_ppp_ccp_reset_alloc(is);
+	if (!is->reset)
+		return -ENOMEM;
=C2=A0
=C2=A0	is->lp =3D NULL;
=C2=A0	is->mp_seqno =3D 0;=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0/* MP s=
equence number */
@@ -320,6 +322,10 @@ isdn_ppp_open(int min, struct file *file)
=C2=A0	=C2=A0* VJ header compression init
=C2=A0	=C2=A0*/
=C2=A0	is->slcomp =3D slhc_init(16, 16);	/* not necessary for 2. link in bu=
ndle */
+	if (!is->slcomp) {
+		isdn_ppp_ccp_reset_free(is);
+		return -ENOMEM;
+	}
=C2=A0#endif
=C2=A0#ifdef CONFIG_IPPP_FILTER
=C2=A0	is->pass_filter =3D NULL;

--=20
Ben Hutchings
[W]e found...that it wasn't as easy to get programs right as we had thought=
.
... I realized that a large part of my life from then on was going to be sp=
ent
in finding mistakes in my own programs. - Maurice Wilkes, 1949
--=-xOnacfr6LJaT0/BCLeIt
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAVh6WEue/yOyVhhEJAQornQ//U6SWptEAK3vQub4s2fX/9pFcBXkelfLN
lPZexxbH3PhrLhkcXAZfLK4yWEcCB/19kS3VRwJkh30tTBIMecqNy5ld6BYJLxuw
FgQqQO0gYcpel7czgXjf8APhLJEMn1e4xjg+heAUXd2nokPsm62FUQO7aDvyj2Zr
fI6bpu8g9PL6V/UFeh5Te7B83i9WN1p7OqM0tz0tIMSdiTaBZ1GIWB89gbhnhWu1
O0w52suHGaqnnJ0zEr0f7ibXs7p4b0wF31W+K+uOoUDCaa8ZNfH77CzlXIeXk5kF
uVoFz1dRwHsAi5HdkcTCr/uWKFnoXvTVvKmiCqR5D4TDOekkAS28SMx9ehq4ouNb
Mwrss4QU1gxu88Li75RrUk5YddV5uA4TiRyyjwK1BeaLSOwVHRz73pbRYX7lKIVL
EXZOtSXGriDxTDq4pRu42aPmeCn+pnUL5oZ14dl04HTyBTMcNVT+AH6JZg16BdtN
zvNTO4VpJ/HGMyxqrztbe7z/bDZpQ/5FuL+i7n/h7gUWVTYbYbqPIvznaKU48fUC
YG0Lp9/4ORC3nyw1R9wnf8pJscOtc+0/kVAPzB5IZUqeZ1A7iyDqGyLeR7U7vinl
mUlnrFhu1D2UK4yOtB/9SkUZvzEvGdWj4e+8m90SSEMZ20VVUPDh+o4HcoH3TMv6
rKnCq499HqU=
=aSo8
-----END PGP SIGNATURE-----

--=-xOnacfr6LJaT0/BCLeIt--
