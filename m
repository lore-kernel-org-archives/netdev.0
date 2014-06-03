From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH net-next 5/8] ethtool: Disallow ETHTOOL_SRSSH with both
 indir table and hash key unchanged
Date: Tue, 03 Jun 2014 02:51:00 +0100
Message-ID: <1401760260.14007.184.camel@deadeye.wl.decadent.org.uk>
References: <1401760161.14007.179.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-Qe1vMDzOSY1+Nf+1/3ui"
Cc: netdev <netdev@vger.kernel.org>,
	Venkat Duvvuru <VenkatKumar.Duvvuru@Emulex.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:49649 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752579AbaFCBvH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jun 2014 21:51:07 -0400
In-Reply-To: <1401760161.14007.179.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-Qe1vMDzOSY1+Nf+1/3ui
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
If more than one person is responsible for a bug, no one is at fault.

--=-Qe1vMDzOSY1+Nf+1/3ui
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUAU40qBOe/yOyVhhEJAQq26BAAnz85tICpHBHnl0vcQuMBVS9yi6GpBr3Q
Xk3iocCo85/h0k7sE6xmCy9FNIx0hWIWvfmcvfvSciuAumXDTIC1xWypNHr9wToF
PnESK+ZBJ802QZ2rRVQWAmJ4/Jag5+J32WUWLoB9hFY8NjWwltKisOts0shi5nkV
OYA8VTCJzXUIJt53vt1CxpIWkzrN2RBHtmqtKF4bdTeTk7Tzy+v5fCby5+4evEYy
U3DBCUDIv8edZk7/Ld/Hax22GB5f5a+C1NOGiGBhX7JM8jKjfsEcs6DGhvDY4wKl
ftUVwpBEfRG0gNbG9UQABeTtm71sy60CY8CY1B5UWMB0qeEH5buOarS337AqkkKe
22U19hRvDhJwSWFOwgb7kW1Nja7ixtWvPLrL43pzMDIYLyEwDjPDOfu76PVWorl3
vN+kRXcO06icwyry1d2XlonXFf8fPUz/UB1elV7kRQjkdODoiKa164OJq1I0vD/8
Qq8X4G9tkUA0/JS7loZ1zNi3VxbTkgls7cESBGalNBBiWbVCdu2cGq0NbO+11DdB
EA5u1PRq5ik3M5yuj3ceN2fToVbo2YvJAbnJNQ2mDbyi4I3wCNwxL27ETTNH9Mba
GYEBysIzZXWOnJXPatv4AR7vmq0isiTeKlb7u8GEpQqjE1rIjidzzvaITOQGQmvv
SpNNOhl545Y=
=mMeW
-----END PGP SIGNATURE-----

--=-Qe1vMDzOSY1+Nf+1/3ui--
