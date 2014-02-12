From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH net-next 08/14] ethtool: Expand documentation of string set
 types
Date: Wed, 12 Feb 2014 22:14:33 +0000
Message-ID: <1392243273.15615.12.camel@deadeye.wl.decadent.org.uk>
References: <1392243184.15615.4.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-0prFsVGCB2BbjkjXurMs"
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:52796 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754534AbaBLWOm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Feb 2014 17:14:42 -0500
In-Reply-To: <1392243184.15615.4.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-0prFsVGCB2BbjkjXurMs
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
 include/uapi/linux/ethtool.h | 59 +++++++++++++++++++++++++++++++++++-----=
----
 1 file changed, 47 insertions(+), 12 deletions(-)

diff --git a/include/uapi/linux/ethtool.h b/include/uapi/linux/ethtool.h
index 8ca2924..e726340d 100644
--- a/include/uapi/linux/ethtool.h
+++ b/include/uapi/linux/ethtool.h
@@ -496,31 +496,66 @@ struct ethtool_pauseparam {
 };
=20
 #define ETH_GSTRING_LEN		32
+
+/**
+ * enum ethtool_stringset - string set ID
+ * @ETH_SS_TEST: Self-test result names, for use with %ETHTOOL_TEST
+ * @ETH_SS_STATS: Statistic names, for use with %ETHTOOL_GSTATS
+ * @ETH_SS_PRIV_FLAGS: Driver private flag names, for use with
+ *	%ETHTOOL_GPFLAGS and %ETHTOOL_SPFLAGS
+ * @ETH_SS_NTUPLE_FILTERS: Previously used with %ETHTOOL_GRXNTUPLE;
+ *	now deprecated
+ * @ETH_SS_FEATURES: Device feature names
+ */
 enum ethtool_stringset {
 	ETH_SS_TEST		=3D 0,
 	ETH_SS_STATS,
 	ETH_SS_PRIV_FLAGS,
-	ETH_SS_NTUPLE_FILTERS,	/* Do not use, GRXNTUPLE is now deprecated */
+	ETH_SS_NTUPLE_FILTERS,
 	ETH_SS_FEATURES,
 };
=20
-/* for passing string sets for data tagging */
+/**
+ * struct ethtool_gstrings - string set for data tagging
+ * @cmd: Command number =3D %ETHTOOL_GSTRINGS
+ * @string_set: String set ID; one of &enum ethtool_stringset
+ * @len: On return, the number of strings in the string set
+ * @data: Buffer for strings.  Each string is null-padded to a size of
+ *	%ETH_GSTRING_LEN.
+ *
+ * Users must use %ETHTOOL_GSSET_INFO to find the number of strings in
+ * the string set.  They must allocate a buffer of the appropriate
+ * size immediately following this structure.
+ */
 struct ethtool_gstrings {
-	__u32	cmd;		/* ETHTOOL_GSTRINGS */
-	__u32	string_set;	/* string set id e.c. ETH_SS_TEST, etc*/
-	__u32	len;		/* number of strings in the string set */
+	__u32	cmd;
+	__u32	string_set;
+	__u32	len;
 	__u8	data[0];
 };
=20
+/**
+ * struct ethtool_sset_info - string set information
+ * @cmd: Command number =3D %ETHTOOL_GSSET_INFO
+ * @sset_mask: On entry, a bitmask of string sets to query, with bits
+ *	numbered according to &enum ethtool_stringset.  On return, a
+ *	bitmask of those string sets queried that are supported.
+ * @data: Buffer for string set sizes.  On return, this contains the
+ *	size of each string set that was queried and supported, in
+ *	order of ID.
+ *
+ * Example: The user passes in @sset_mask =3D 0x7 (sets 0, 1, 2) and on
+ * return @sset_mask =3D=3D 0x6 (sets 1, 2).  Then @data[0] contains the
+ * size of set 1 and @data[1] contains the size of set 2.
+ *
+ * Users must allocate a buffer of the appropriate size (4 * number of
+ * sets queried) immediately following this structure.
+ */
 struct ethtool_sset_info {
-	__u32	cmd;		/* ETHTOOL_GSSET_INFO */
+	__u32	cmd;
 	__u32	reserved;
-	__u64	sset_mask;	/* input: each bit selects an sset to query */
-				/* output: each bit a returned sset */
-	__u32	data[0];	/* ETH_SS_xxx count, in order, based on bits
-				   in sset_mask.  One bit implies one
-				   __u32, two bits implies two
-				   __u32's, etc. */
+	__u64	sset_mask;
+	__u32	data[0];
 };
=20
 /**


--=20
Ben Hutchings
If more than one person is responsible for a bug, no one is at fault.

--=-0prFsVGCB2BbjkjXurMs
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAUvvySee/yOyVhhEJAQrV3A//dR3gVo8L9dez1uX+3Qt2N/XOWCnHyhER
Pp9/NlLwss4tBUytMjY5l5/1yqGplA03AbC99spHUvkf3pfbmUuNg0zUCQ39ctvy
WdSwJl/bQNTm+XRufJQFrphuBOz85nY5I1VxUPSw0Vcj1olrHDwg6+k+z379pJLY
vWn12VSpVIY1iS7voRoTstA8JIVMKMPS5jVdhu8RYKzzNJM7mv7Yy7JcUyQwrrOt
3neKcwb4GQLjRreZAn7myb4DXxMctgtMu8tjMn/Mk5x+GIfeKzj3PZ+zc4tm6Vxd
bgo/jFMT5gMHTpWssBKddT0+wiOlUIRbetIzJneu8BH9FIOIJ3E7iFH6Z0WqxL5S
4wHrV2oe2QHYApBvUsQXXqOnMxwDlOJKc4YohSDRSybacTLIfwFEZK4aEeybLEuI
wb9dIEeGkw2pB9cMNWfWZaYRjqDX4p4CBNKnRfPeSwtEC2ViTO/Vl6Gz54Igp+e2
FmvugRYk+Zfy/f/iEBnUDXcqDnM+dN7VclnWNhBCllDm05qs4CCodANPquW8nWG2
6bV26AJtGNBBBykPOY94CfmyNvG4W5XG11AMLQuSPyDLuvV6B+zLxlHTuLzjgK3Z
Hv1HOCicRbt6JejMoEbvq2UwLltFyPAKyc1PlC6pKzLLsBbiPrpLg3Sbt2l42qHo
OHvkM/5eDnI=
=MaeN
-----END PGP SIGNATURE-----

--=-0prFsVGCB2BbjkjXurMs--
