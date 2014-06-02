From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH net-next 4/8] ethtool: Expand documentation of
 ethtool_ops::{get,set}_rxfh()
Date: Mon, 02 Jun 2014 02:02:09 +0100
Message-ID: <1401670929.14007.98.camel@deadeye.wl.decadent.org.uk>
References: <1401670659.14007.94.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-ZuAZaX75T68tSaD6Ow1/"
Cc: netdev <netdev@vger.kernel.org>,
	Venkat Duvvuru <VenkatKumar.Duvvuru@Emulex.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:46335 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752655AbaFBBCQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Jun 2014 21:02:16 -0400
In-Reply-To: <1401670659.14007.94.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-ZuAZaX75T68tSaD6Ow1/
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
Any smoothly functioning technology is indistinguishable from a rigged demo=
.

--=-ZuAZaX75T68tSaD6Ow1/
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUAU4vNEee/yOyVhhEJAQpfCQ/+L8JShtGcgnVHRaGaFcZgdUubIaiA6jw8
FbakSZkdW/hG71FqwfKaqdjdcmriJZ7XOXjFxw5ZIZadLK7huxfhYSoo77xOHcLA
K0O0zsHz9pT0oXRezG8oLPHJczlAfqiPzc5lWQy6cm7Vfa/C/L5BL6WGzqqMcu3S
ron2hHsCyMTocDhgsUXPIzKhwgtn8iRwu0kQLmR4CuwfAFLwW+6mja/du1UtriMG
RQEJkpqkBsJnM7H+0LR/P7XWmuqmLO8kV4BbN0q/NbcCGKDv14IXD1L2eF71RSN5
ZXaWlOR8nSl50gS6kW3sO1Rc3F0whPGmXN4RmlOgmHvc7Utl9AqKXWmQGwAZIkld
XSTWX4b12YhW9HPCKHcIvMMHCJZ3QNa3cq1cKM9D/OsqI98yvqwqPrj4HNRL8Qk2
SqQLz1ct3rBHaShgjfj5Z5z2XdSzkF38B0Ds/eoYNL+SqKXWQ2CWrdyeUM1SKez5
PRTM0G0kwJyLzby74CulcWee2BUPUTlG/iZ5NNW2p4K+VrBh6CoEl3Gops74Us2n
DT+y/z27/xghkYH8shXsTmZZ8emGiKeQzWZ+DcjYHrhaKxt+4tj6OlGHwpA5ziCD
nVIQ51d1iLJ90KNG8wsHBcGUuy2WrsmdhUSOl8kUHQ6+26H+84HDCkpQgaE4O3SO
gCYw1QyfnuA=
=qeao
-----END PGP SIGNATURE-----

--=-ZuAZaX75T68tSaD6Ow1/--
