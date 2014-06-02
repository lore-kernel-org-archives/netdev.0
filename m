From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH net-next 1/8] ethtool: Return immediately on error in
 ethtool_copy_validate_indir()
Date: Mon, 02 Jun 2014 02:01:20 +0100
Message-ID: <1401670880.14007.95.camel@deadeye.wl.decadent.org.uk>
References: <1401670659.14007.94.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-TCw97kog30aaIYkbVH56"
Cc: netdev <netdev@vger.kernel.org>,
	Venkat Duvvuru <VenkatKumar.Duvvuru@Emulex.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:46323 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752472AbaFBBB1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Jun 2014 21:01:27 -0400
In-Reply-To: <1401670659.14007.94.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-TCw97kog30aaIYkbVH56
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
Any smoothly functioning technology is indistinguishable from a rigged demo=
.

--=-TCw97kog30aaIYkbVH56
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUAU4vM4Oe/yOyVhhEJAQoO4A//cKtg5DjV8DLYE+i9eYFrAOh5ypwSJksN
9mYdz6o5rt18Cy3nTX+v36j4Wrgi4+YEQCPa3TFA8LlVYvb/Da5Tx2prtNe2iuUo
7ccSf7CTvlEAVLujUie4ABRugvTn4ctkwQImjVjMsbD2QxU3QjZdQ1h1WvZsMhkQ
fsv8MkxfVgspaIYkCPXrIV4dk2ADOY98eG93Hmsk2TYUDwnZkVOgP42QspFt01aQ
l1yQq7A48WIPs+vlai67SwBHBIFI43/LH2cWqerFfAqqq2NaFV68XoOCBZ0megjM
Yji+FHV61dyzezlMHj+zCyiHEEOjboNAnT93VENgbXZmbNOmvBdAVK0sMvLaTQuO
yW8oy/NvzH6RnhzpvIFbkeU7meTtM+m9YhbacFHQiuT6i03XMedvb9ZCuI1iATv2
/j0uqBZ9K/a7QHWMCCy5SYZLnsXgLa/VauQY+1qCzg4WuGwEeIYt0DajO/TtLKd2
wl1wS0vvaV82Qcgy+YMb9fTw2uTpOeUDUW6fezL0Q+bgQEJigT3BErRnaQUosJmm
6frMU+oH/ypwtHPB13LV4X0G0Gwp1UwpHAH/o58QT28qSXzPjcCucRky3GuGhhJ9
mI2HmvFSXf3MKxmc7jpOQnIHQCKtV6FRMVSPZQ9fJ0XNi1Z5Fr/91wNT9JCBlOpT
ujwx9UNKk9E=
=Oc19
-----END PGP SIGNATURE-----

--=-TCw97kog30aaIYkbVH56--
