From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH net-next 5/8] ethtool: Disallow ETHTOOL_SRSSH with both
 indir table and hash key unchanged
Date: Mon, 02 Jun 2014 02:02:26 +0100
Message-ID: <1401670946.14007.99.camel@deadeye.wl.decadent.org.uk>
References: <1401670659.14007.94.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-DyJ0IwPKoUUnRQLLfGtQ"
Cc: netdev <netdev@vger.kernel.org>,
	Venkat Duvvuru <VenkatKumar.Duvvuru@Emulex.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:46339 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752655AbaFBBCd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Jun 2014 21:02:33 -0400
In-Reply-To: <1401670659.14007.94.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-DyJ0IwPKoUUnRQLLfGtQ
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

This would be a no-op, so there is no reason to request it.

This also allows conversion of the current implementations of
ethtool_ops::{get,set}_rxfh_indir to ethtool_ops::{get,set}_rxfh
with no change other than their parameters.

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
 include/linux/ethtool.h | 4 ++--
 net/core/ethtool.c      | 5 ++++-
 2 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index 886e127..de687a9 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -168,8 +168,8 @@ static inline u32 ethtool_rxfh_indir_default(u32 index,=
 u32 n_rx_rings)
  * @set_rxfh_indir: Set the contents of the RX flow hash indirection table=
.
  *	Will not be called if @get_rxfh_indir_size returns zero.
  * @set_rxfh: Set the contents of the RX flow hash indirection table and/o=
r
- *	hash key.  Either or both arguments may be %NULL if that attribute
- *	is not to be changed.
+ *	hash key.  In case only the indirection table or hash key is to be
+ *	changed, the other argument will be %NULL.
  *	Will only be called if one or both of @get_rxfh_indir_size and
  *	@get_rxfh_key_size are implemented and return non-zero.
  *	Returns a negative error code or zero.
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 7156fe5..b885734 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -802,11 +802,14 @@ static noinline_for_stack int ethtool_set_rxfh(struct=
 net_device *dev,
 		return -EFAULT;
=20
 	/* If either indir or hash key is valid, proceed further.
+	 * It is not valid to request that both be unchanged.
 	 */
 	if ((user_indir_size &&
 	     user_indir_size !=3D ETH_RXFH_INDIR_NO_CHANGE &&
 	     user_indir_size !=3D dev_indir_size) ||
-	    (user_key_size && (user_key_size !=3D dev_key_size)))
+	    (user_key_size && (user_key_size !=3D dev_key_size)) ||
+	    (user_indir_size =3D=3D ETH_RXFH_INDIR_NO_CHANGE &&
+	     user_key_size =3D=3D 0))
 		return -EINVAL;
=20
 	if (user_indir_size !=3D ETH_RXFH_INDIR_NO_CHANGE)


--=20
Ben Hutchings
Any smoothly functioning technology is indistinguishable from a rigged demo=
.

--=-DyJ0IwPKoUUnRQLLfGtQ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUAU4vNIue/yOyVhhEJAQrjSQ//RED0Tt+7fx6HICO9ZR3nOCzHwKIrOXtz
VdO8RmRmaREhihBc4zu2ECyWZPcT/aSRJyy4GQZZ00vNNPfvE8BL3AY12JlaLb+W
1POqTh8oIzP31jISNj2VzQEAXxOxXNorulI6L/n4l/bDY3SblHeNyTKO6txoQ+/3
dBxIA2LZpQbR4PnmyHDUSD9qjGDM6BeAEH4XpRETTEsuFfIEGeFdjoI7wuzI8qNb
KkJtKmqeA6jqYPq9/zkzaIVtxfr90gHIql8u+ejMsab67GNC9jEMFXdaIVrb/O6S
T7H1kupuocaCHoKs5Ki+iSoRTCveNkQWWpTnDvZ2h21rjbXXCOmLH6gx7ZFmlX6n
FeUiQBiwvRf7ES0h4JJDw10rrCp7vhOffxuiWv1CRqJO9l400Qmnl2RI1fEOezm1
24/iOALRuMWAnz1n49gE9bdS+c5grq80x1cgYLQscCaVAhPuB+jk8BK2x8DR2Zhf
w+MofQWwNTLuuaLAJXOf4+bxZmCVifGMAXsZeMopeYIwxV3W2hqISm/DB+P25V6W
sKQohaF+8GfV3Zqqer9ZLRQ1HHyhP4x5CLnsSX0QLg5OApgpY/WoPI4zKHsmJPEn
OB2MgG01wiw7niPKHXDhLJQoTi6rVXusFwFnX0HKmYIyc1vJgaHnsBPFKwNIL0kh
0tauemjo6So=
=FKs2
-----END PGP SIGNATURE-----

--=-DyJ0IwPKoUUnRQLLfGtQ--
