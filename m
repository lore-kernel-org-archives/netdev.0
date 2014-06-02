From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH net-next 3/8] ethtool: Improve explanation of the two arrays
 following struct ethtool_rxfh
Date: Mon, 02 Jun 2014 02:01:43 +0100
Message-ID: <1401670903.14007.97.camel@deadeye.wl.decadent.org.uk>
References: <1401670659.14007.94.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-bZCP2XTB1ga1bNgWdvO+"
Cc: netdev <netdev@vger.kernel.org>,
	Venkat Duvvuru <VenkatKumar.Duvvuru@Emulex.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:46331 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752656AbaFBBBu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Jun 2014 21:01:50 -0400
In-Reply-To: <1401670659.14007.94.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-bZCP2XTB1ga1bNgWdvO+
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
Any smoothly functioning technology is indistinguishable from a rigged demo=
.

--=-bZCP2XTB1ga1bNgWdvO+
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUAU4vM9+e/yOyVhhEJAQqJmhAAjOfeKKKe2NOABA15I+vcIZa4Qz4qGmab
b00RP4YV2ijbvMd8+G5RVYoQJ7HbYI7qHovjvZpfxGJgF1W6+gJ1BuUt4Eh64kbR
3BSeip1x/8H8Rt+gm+et4yhHi6SARQDXew2unXxUFAbl32B/x/8LsbtwLFQHx76W
Ic4o+7Zqe2ftKrSz80xam6i37tg+iICE7jZYUkO76jXmLOcD/b2ZLhknTFiwFixF
RCgtHtjTPnH4PCTHfSa44LUXrDQzFZ931c1SGAsvCLGJYMpTXyu2isosKG1TQFEx
BRGY42gIekSfyucd6CiM8AdIHw+DnQ/DGQtFzIsdzIC/RcUgvXAtRDMW6WgeX3o2
WcUs3PJZq1KFhjPPLbBG9p9cS9AUWNFh/BILXv43HsZpTvKsy7St8DV6b7q58jI4
ZFokjmlKm9IizBtj9x46WFLgVR60hZE3r01fHs25yi34CcahSCijKLrAh9OHshHA
rVr+gXLthUb1p6ehtFEHSQ9tXltjhDRTN65ebi5X/evDQmveXmx9H1k8LXCrIwwn
VO37mGfr3kOrasbyhj6jb7nmlb7ojGlMcEBYd8DfZ50bVuhI2iIkbjBxP3Nhb/Nn
uj1jI8Bws9kk9HnS9oeNmZu1A/CyDOA61cvrR71pmJ6e01deDw/OQ6L4VNEygkVe
LbOSaUMRaqc=
=ve9/
-----END PGP SIGNATURE-----

--=-bZCP2XTB1ga1bNgWdvO+--
