From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH net-next 3/8] ethtool: Improve explanation of the two arrays
 following struct ethtool_rxfh
Date: Tue, 03 Jun 2014 02:50:49 +0100
Message-ID: <1401760249.14007.182.camel@deadeye.wl.decadent.org.uk>
References: <1401760161.14007.179.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-+cBmfYd3klOn/YP+KM+5"
Cc: netdev <netdev@vger.kernel.org>,
	Venkat Duvvuru <VenkatKumar.Duvvuru@Emulex.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:49642 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752579AbaFCBu4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jun 2014 21:50:56 -0400
In-Reply-To: <1401760161.14007.179.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-+cBmfYd3klOn/YP+KM+5
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

The use of two variable-length arrays is unusual so deserves a bit
more explanation.

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
 include/uapi/linux/ethtool.h | 17 +++++++++--------
 1 file changed, 9 insertions(+), 8 deletions(-)

diff --git a/include/uapi/linux/ethtool.h b/include/uapi/linux/ethtool.h
index cba18e3..e3c7a71 100644
--- a/include/uapi/linux/ethtool.h
+++ b/include/uapi/linux/ethtool.h
@@ -850,16 +850,17 @@ struct ethtool_rxfh_indir {
  * struct ethtool_rxfh - command to get/set RX flow hash indir or/and hash=
 key.
  * @cmd: Specific command number - %ETHTOOL_GRSSH or %ETHTOOL_SRSSH
  * @rss_context: RSS context identifier.
- * @indir_size: On entry, the array size of the user buffer, which may be =
zero,
- *		or (for %ETHTOOL_SRSSH), %ETH_RXFH_INDIR_NO_CHANGE.
- *		On return from %ETHTOOL_GRSSH, the array size of the hardware
- *		indirection table.
- * @key_size:	On entry, the array size of the user buffer in bytes,
- *		which may be zero.
- *		On return from %ETHTOOL_GRSSH, the size of the RSS hash key.
+ * @indir_size: On entry, the array size of the user buffer for the
+ *	indirection table, which may be zero, or (for %ETHTOOL_SRSSH),
+ *	%ETH_RXFH_INDIR_NO_CHANGE.  On return from %ETHTOOL_GRSSH,
+ *	the array size of the hardware indirection table.
+ * @key_size: On entry, the array size of the user buffer for the hash key=
,
+ *	which may be zero.  On return from %ETHTOOL_GRSSH, the size of the
+ *	hardware hash key.
  * @rsvd:	Reserved for future extensions.
  * @rss_config: RX ring/queue index for each hash value i.e., indirection =
table
- *		of size @indir_size followed by hash key of size @key_size.
+ *	of @indir_size __u32 elements, followed by hash key of @key_size
+ *	bytes.
  *
  * For %ETHTOOL_GRSSH, a @indir_size and key_size of zero means that only =
the
  * size should be returned.  For %ETHTOOL_SRSSH, an @indir_size of


--=20
Ben Hutchings
If more than one person is responsible for a bug, no one is at fault.

--=-+cBmfYd3klOn/YP+KM+5
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUAU40p+ee/yOyVhhEJAQrwvQ/6Aiddyj4W7EwxKZiAbUx07lqtKtgsrV5C
D+lw8PzHbTXp6UupR8ilq6bollcfFS5rzcZ4modkKwZeJpfKeEDrej2P6M/ZIzYq
DrI5Y/g56pQooKbGIfCuePE8d4ot4Q+Lzi5SMFyPcZ2YLXMijWIlKslDHzyC2YhR
ICovgzjuUVc2KQ0GDXMHe3EsFVA2Qs2PB5CK8UkH+yo5fUDogypwCcafcyVMvfcK
wxjp7eeXt4CgBgQHf5WubJ14Ymn1nc8YGkwf4myPiPL4I1L2PQTa0GKpoXChx+ze
P+eXCLUSSd5UjyUDM4GuT5/jSo53ruqfO2q96N4ygedTlhAgfQOOKGwl8Lu11heV
ocJAvlhH7aICRtl8ekaHe1F9/02TKnimXlR/OkZ8n3WJuqteEZnV3L+zaveABIqJ
L+seVDd4hYhCmGNs9wduBErzeZsMd8CpUKXP0fgDCdDvzkICyZsp0AxJZIwLvX0E
5/IihsxJSXFsc26zk20Z7PcRBf31D1w1ljjG65BB63ljCP7M3MVTJWiuFwDdJAjB
9qllV4j1V7M80iQY7+3rsmLHkNqM1NZiRaDLKIySCkZp7QEHSK7IL6fegV8rvvw4
Kh9vsdSW7r4Kf2bgVJgfdLLj4rX2nUHetZIsrxTuG4+kwR8y7nWUImOJZ8Pz3WC9
kKdzJoZCiaU=
=1Exs
-----END PGP SIGNATURE-----

--=-+cBmfYd3klOn/YP+KM+5--
