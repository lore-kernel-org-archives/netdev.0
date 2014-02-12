From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH net-next 02/14] ethtool: Expand documentation of struct
 ethtool_drvinfo
Date: Wed, 12 Feb 2014 22:14:03 +0000
Message-ID: <1392243243.15615.6.camel@deadeye.wl.decadent.org.uk>
References: <1392243184.15615.4.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-x6jLpN1JvGEDeNjB4InX"
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:52776 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753033AbaBLWOK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Feb 2014 17:14:10 -0500
In-Reply-To: <1392243184.15615.4.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-x6jLpN1JvGEDeNjB4InX
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Replace the inline comments (and some others below) with a full
explanation of the semantics, in kernel-doc format.  Specify which
strings may be empty.  Document the relationship with other commands.

Replace the 'deprecation' of some fields with a proper explanation of
the conversion to generalised string sets, as userland programs may
not be able to assume that ETHTOOL_GSSET_INFO is available.

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
 include/uapi/linux/ethtool.h | 56 ++++++++++++++++++++++++++++++----------=
----
 1 file changed, 39 insertions(+), 17 deletions(-)

diff --git a/include/uapi/linux/ethtool.h b/include/uapi/linux/ethtool.h
index c4d5eb2..cc523cb 100644
--- a/include/uapi/linux/ethtool.h
+++ b/include/uapi/linux/ethtool.h
@@ -139,28 +139,50 @@ static inline __u32 ethtool_cmd_speed(const struct et=
htool_cmd *ep)
=20
 #define ETHTOOL_FWVERS_LEN	32
 #define ETHTOOL_BUSINFO_LEN	32
-/* these strings are set to whatever the driver author decides... */
+
+/**
+ * struct ethtool_drvinfo - general driver and device information
+ * @cmd: Command number =3D %ETHTOOL_GDRVINFO
+ * @driver: Driver short name.  This should normally match the name
+ *	in its bus driver structure (e.g. pci_driver::name).  Must
+ *	not be an empty string.
+ * @version: Driver version string; may be an empty string
+ * @fw_version: Firmware version string; may be an empty string
+ * @bus_info: Device bus address.  This should match the dev_name()
+ *	string for the underlying bus device, if there is one.  May be
+ *	an empty string.
+ * @n_priv_flags: Number of flags valid for %ETHTOOL_GPFLAGS and
+ *	%ETHTOOL_SPFLAGS commands; also the number of strings in the
+ *	%ETH_SS_PRIV_FLAGS set
+ * @n_stats: Number of u64 statistics returned by the %ETHTOOL_GSTATS
+ *	command; also the number of strings in the %ETH_SS_STATS set
+ * @testinfo_len: Number of results returned by the %ETHTOOL_TEST
+ *	command; also the number of strings in the %ETH_SS_TEST set
+ * @eedump_len: Size of EEPROM accessible through the %ETHTOOL_GEEPROM
+ *	and %ETHTOOL_SEEPROM commands, in bytes
+ * @regdump_len: Size of register dump returned by the %ETHTOOL_GREGS
+ *	command, in bytes
+ *
+ * Users can use the %ETHTOOL_GSSET_INFO command to get the number of
+ * strings in any string set (from Linux 2.6.34).
+ *
+ * Drivers should set at most @driver, @version, @fw_version and
+ * @bus_info in their get_drvinfo() implementation.  The ethtool
+ * core fills in the other fields using other driver operations.
+ */
 struct ethtool_drvinfo {
 	__u32	cmd;
-	char	driver[32];	/* driver short name, "tulip", "eepro100" */
-	char	version[32];	/* driver version string */
-	char	fw_version[ETHTOOL_FWVERS_LEN];	/* firmware version string */
-	char	bus_info[ETHTOOL_BUSINFO_LEN];	/* Bus info for this IF. */
-				/* For PCI devices, use pci_name(pci_dev). */
+	char	driver[32];
+	char	version[32];
+	char	fw_version[ETHTOOL_FWVERS_LEN];
+	char	bus_info[ETHTOOL_BUSINFO_LEN];
 	char	reserved1[32];
 	char	reserved2[12];
-				/*
-				 * Some struct members below are filled in
-				 * using ops->get_sset_count().  Obtaining
-				 * this info from ethtool_drvinfo is now
-				 * deprecated; Use ETHTOOL_GSSET_INFO
-				 * instead.
-				 */
-	__u32	n_priv_flags;	/* number of flags valid in ETHTOOL_GPFLAGS */
-	__u32	n_stats;	/* number of u64's from ETHTOOL_GSTATS */
+	__u32	n_priv_flags;
+	__u32	n_stats;
 	__u32	testinfo_len;
-	__u32	eedump_len;	/* Size of data from ETHTOOL_GEEPROM (bytes) */
-	__u32	regdump_len;	/* Size of data from ETHTOOL_GREGS (bytes) */
+	__u32	eedump_len;
+	__u32	regdump_len;
 };
=20
 #define SOPASS_MAX	6


--=20
Ben Hutchings
If more than one person is responsible for a bug, no one is at fault.

--=-x6jLpN1JvGEDeNjB4InX
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAUvvyK+e/yOyVhhEJAQqpLRAAtFDYcVakmFPevcopgOj9WdRWGqGtauab
tNRm1LzK3dKF6ZWhtu2YWuX+7HqEOzNMazHp0U0IWXzcLlwtRIHnXSn7DzTPdjqt
yvpFcUO7nDeigYztWE4DwSBH4ZCRXls2WQEYaLfRZnR+kVdhaO72nuRG6cfbEGRv
9cXa1tpCCUL70LybwZt5EzaFbWOueYyDAS8TH0BiYJbqtpfG9xldRbGvpv/MkNYd
UGnDXgJfCKE80TVYb3VfsOsUxmBn4HHhmuMWPCpBx1WlHB4Hm//W0IrsfN9/630Y
eoPfm1njhYq6RBv38fHgrNqMffGzmw3pkavnqCHWvy+gnMP+fiFaFnV1C1caexS0
QzhyAQ15wBiPgXvgTfvJvYDJI+DGSWQYoO4SCcm6F8SvTC568jv3DBAxMNtnAwHM
CWBAmbleJ/peAO4/3JBPE79eLCeooZ7FeE157KPeABCGoLwDtZ1kzgayiTWr3Ha7
WoPu5g4rthNe+JPpRNL7y9W7F76l/ytTCp/pKLKYDAbiEJUump9N11IHym95WaQL
OaJLLS0xDbaSG0HgJgZ5RAV4D5MctgDmfxgfO+jZjaAL5rrrYRyi+nKnmD2b9nTq
mYTalHIcabCZUe/8WqFxJ3xh6/sdHWOxv00nqqlQ9St4Vr1fnEuHF88TZ61wwUGh
Tz3iLwwCDkI=
=ix/O
-----END PGP SIGNATURE-----

--=-x6jLpN1JvGEDeNjB4InX--
