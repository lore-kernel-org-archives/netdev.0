From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH net-next 4/8] ethtool: Expand documentation of
 ethtool_ops::{get,set}_rxfh()
Date: Tue, 03 Jun 2014 02:50:54 +0100
Message-ID: <1401760254.14007.183.camel@deadeye.wl.decadent.org.uk>
References: <1401760161.14007.179.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-i1eQUitB5SQ9Ki3o4EMA"
Cc: netdev <netdev@vger.kernel.org>,
	Venkat Duvvuru <VenkatKumar.Duvvuru@Emulex.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:49646 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752579AbaFCBvB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jun 2014 21:51:01 -0400
In-Reply-To: <1401760161.14007.179.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-i1eQUitB5SQ9Ki3o4EMA
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Some corner-cases are not explained properly.

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
 include/linux/ethtool.h | 17 +++++++++--------
 1 file changed, 9 insertions(+), 8 deletions(-)

diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index 212f537..886e127 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -162,15 +162,16 @@ static inline u32 ethtool_rxfh_indir_default(u32 inde=
x, u32 n_rx_rings)
  *	Will not be called if @get_rxfh_indir_size returns zero.
  * @get_rxfh: Get the contents of the RX flow hash indirection table and h=
ash
  *	key.
- *	Will not be called if @get_rxfh_indir_size and @get_rxfh_key_size
- *	returns zero.
+ *	Will only be called if one or both of @get_rxfh_indir_size and
+ *	@get_rxfh_key_size are implemented and return non-zero.
  *	Returns a negative error code or zero.
  * @set_rxfh_indir: Set the contents of the RX flow hash indirection table=
.
  *	Will not be called if @get_rxfh_indir_size returns zero.
- * @set_rxfh: Set the contents of the RX flow hash indirection table and
- *	hash key.
- *	Will not be called if @get_rxfh_indir_size and @get_rxfh_key_size
- *	returns zero.
+ * @set_rxfh: Set the contents of the RX flow hash indirection table and/o=
r
+ *	hash key.  Either or both arguments may be %NULL if that attribute
+ *	is not to be changed.
+ *	Will only be called if one or both of @get_rxfh_indir_size and
+ *	@get_rxfh_key_size are implemented and return non-zero.
  *	Returns a negative error code or zero.
  * @get_channels: Get number of channels.
  * @set_channels: Set number of channels.  Returns a negative error code o=
r
@@ -244,8 +245,8 @@ struct ethtool_ops {
 	int	(*reset)(struct net_device *, u32 *);
 	u32	(*get_rxfh_key_size)(struct net_device *);
 	u32	(*get_rxfh_indir_size)(struct net_device *);
-	int	(*get_rxfh)(struct net_device *, u32 *, u8 *);
-	int	(*set_rxfh)(struct net_device *, u32 *, u8 *);
+	int	(*get_rxfh)(struct net_device *, u32 *indir, u8 *key);
+	int	(*set_rxfh)(struct net_device *, u32 *indir, u8 *key);
 	int	(*get_rxfh_indir)(struct net_device *, u32 *);
 	int	(*set_rxfh_indir)(struct net_device *, const u32 *);
 	void	(*get_channels)(struct net_device *, struct ethtool_channels *);


--=20
Ben Hutchings
If more than one person is responsible for a bug, no one is at fault.

--=-i1eQUitB5SQ9Ki3o4EMA
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUAU40p/ue/yOyVhhEJAQqcDRAAqfzaDK4gBW9hI71PaPmI+hUV7phMkEZd
wWidCOOFJJg1SK51M+vBc+AYA4ll7kPG/HLYyDhWRv91aSFcR1FCqibIIScc9lyc
P3B/29J/qQxyfZy2Djd13BZgUWt6G7iJuWlWcoCGIP4xxCDFDN4B2bn9M1oHZ5Fp
bCP9p5mK7DEtL2CCpjZE1xJsJUrryWiYhk3dApZzPV0YZK8jfPzrrJVyZzfRi4L6
B557DdP7sPdDFKsITj1XBgArGhgCBfLzhk90+BCLMPJBdSpjXdoj7FFzK1XY03ym
ArNrJlbHCC00S1vgm+VTeBecoiR/+ri9HVnJmVPjN6OcdcTmiV1dSXSk5dab7Ghh
W6g6LTSOklkiABBaNjDK0k+2d2PQlxId3Rdm6C9iJdZAIg1d3l/mP0igy6bkuFMy
VgoLy7zcv0ewH6BAI8ZZcE81Uhtrw9RgS/Kwktt1r2NMUQKctwV6O/CCm/Bg7nO3
h1whXgKL5QPXQ8RQLHitbJKeDtDeTjKNEtqsmZwsSEGYNJSALjZj1KTfuRbYjhOm
RZxGNzwKKOirkku7bwf2c2BcSpzNotrUNTkzUuShe/P2BSexSAcr/EETDtoHUnpy
zboYdv1rT3kKHqEpLp1Oiu7CQ1FP+OhpXddbhfLFZYYCZVoaKFMC978a1KHsEd35
QesZmlhGLrY=
=KwcV
-----END PGP SIGNATURE-----

--=-i1eQUitB5SQ9Ki3o4EMA--
