From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH net-next 1/8] ethtool: Return immediately on error in
 ethtool_copy_validate_indir()
Date: Tue, 03 Jun 2014 02:50:36 +0100
Message-ID: <1401760236.14007.180.camel@deadeye.wl.decadent.org.uk>
References: <1401760161.14007.179.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-yNZ/eNLIU+yaV1bjrzNq"
Cc: netdev <netdev@vger.kernel.org>,
	Venkat Duvvuru <VenkatKumar.Duvvuru@Emulex.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:49634 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751441AbaFCBun (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jun 2014 21:50:43 -0400
In-Reply-To: <1401760161.14007.179.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-yNZ/eNLIU+yaV1bjrzNq
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

We must return -EFAULT immediately rather than continuing into
the loop.

Similarly, we may as well return -EINVAL directly.

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
 net/core/ethtool.c | 16 +++++++---------
 1 file changed, 7 insertions(+), 9 deletions(-)

diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index aa8978a..c834cb2 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -561,19 +561,17 @@ static int ethtool_copy_validate_indir(u32 *indir, vo=
id __user *useraddr,
 					struct ethtool_rxnfc *rx_rings,
 					u32 size)
 {
-	int ret =3D 0, i;
+	int i;
=20
 	if (copy_from_user(indir, useraddr, size * sizeof(indir[0])))
-		ret =3D -EFAULT;
+		return -EFAULT;
=20
 	/* Validate ring indices */
-	for (i =3D 0; i < size; i++) {
-		if (indir[i] >=3D rx_rings->data) {
-			ret =3D -EINVAL;
-			break;
-		}
-	}
-	return ret;
+	for (i =3D 0; i < size; i++)
+		if (indir[i] >=3D rx_rings->data)
+			return -EINVAL;
+
+	return 0;
 }
=20
 static noinline_for_stack int ethtool_get_rxfh_indir(struct net_device *de=
v,


--=20
Ben Hutchings
If more than one person is responsible for a bug, no one is at fault.

--=-yNZ/eNLIU+yaV1bjrzNq
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUAU40p7ee/yOyVhhEJAQqOcA/9E+ElSPFyWKYYHDJNddncc2vgVU5fISxF
UkCpPWmb1eY1k95xRuao2YIiufeJN5rjLdrvKq8JnYNbKRW8Cgn5HQNOF/WNjPlB
vQP51tQLpUxjCweKtVcfLDgywU7Hac7JFQEUPpbfOT7RE3vRDN0TSQG/hy4LJSmS
62PU91W83n0SPhAOfiFnQBvIkJ2sVye8VS60+oHwz7DNwVYS0qLp8RAD7V3QAb3f
pmf99gT45nmq7sYHCVtCE6I/pPegR1NED5XGKsCiFgPAM9BaeNU6G5NtO2r8dV1/
ZU0EAKnoaV3n8pVbqNji5KYfSJ/pdmiKHWj2Knt8gch+5WC8nMLkJSKNNwvpDJFo
o4GYb7oO3TKNhfCHOw98s5B9ydfFpaj1+9w0Vgo+hzXLsZzU1d6VgKYlxQckslko
fCu7rtI5fku01KgPV6AAMV/5YruZhNKc0UvUFUnVurkG0A5nTJiOU18Tg5Gx4fMu
MBMIWr9e9/WA3oz85DEajEH6W4Gh3/YYEvjNlLlxho04l4Oh8ec1h4lyu+Vwk1Fo
qmaHTQPhemqQGdF7jha8fYWfUa4FHcjMY14oBn9KMSckFrS6oMuR+ZSszZ/DfxdQ
R+o4bRewBNIfCTSYC/8Fqt7M8qGa2wA5IPRRToOj6fwMrmgbADIUPDQhq2a1oOWc
Zsjs1vu79uU=
=4DIi
-----END PGP SIGNATURE-----

--=-yNZ/eNLIU+yaV1bjrzNq--
