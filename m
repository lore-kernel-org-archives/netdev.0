From: mcgrof@ruslug.rutgers.edu (Luis R. Rodriguez)
Subject: [PATCH 1/3] prism54: remove some module_params
Date: Thu, 19 Aug 2004 19:00:03 -0400
Sender: prism54-devel-bounces@prism54.org
Message-ID: <20040819230003.GZ6044@ruslug.rutgers.edu>
References: <20040819225424.GY6044@ruslug.rutgers.edu>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1315725657=="
Return-path: <prism54-devel-bounces@prism54.org>
To: Jeff Garzik <jgarzik@pobox.com>, Netdev <netdev@oss.sgi.com>,
	prism54-devel@prism54.org
In-Reply-To: <20040819225424.GY6044@ruslug.rutgers.edu>
List-Unsubscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=unsubscribe>
List-Archive: <http://prism54.org/pipermail/prism54-devel>
List-Post: <mailto:prism54-devel@prism54.org>
List-Help: <mailto:prism54-devel-request@prism54.org?subject=help>
List-Subscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=subscribe>
Mime-version: 1.0
Errors-To: prism54-devel-bounces@prism54.org
List-Id: netdev.vger.kernel.org


--===============1315725657==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="TBNym+cBXeFsS4Vs"
Content-Disposition: inline


--TBNym+cBXeFsS4Vs
Content-Type: multipart/mixed; boundary="RDS4xtyBfx+7DiaI"
Content-Disposition: inline


--RDS4xtyBfx+7DiaI
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable


2004-08-18	Luis R. Rodriguez <mcgrof@ruslug.rutgers.edu>

	* isl_ioctl.c (prism54_mib_init): remove module_param usage and=20
	dependency as its unnecessary

--=20
GnuPG Key fingerprint =3D 113F B290 C6D2 0251 4D84  A34A 6ADD 4937 E20A 525E

--RDS4xtyBfx+7DiaI
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="01-remove-module_params.diff"
Content-Transfer-Encoding: quoted-printable

diff -Naurp linux-2.6.8.1/drivers/net/wireless/prism54/isl_ioctl.c linux-2.=
6.8.1-prism54/drivers/net/wireless/prism54/isl_ioctl.c
--- linux-2.6.8.1/drivers/net/wireless/prism54/isl_ioctl.c	2004-08-14 16:16=
:24.000000000 +0000
+++ linux-2.6.8.1-prism54/drivers/net/wireless/prism54/isl_ioctl.c	2004-08-=
16 17:39:31.000000000 +0000
@@ -36,38 +36,6 @@
=20
 #include <net/iw_handler.h>	/* New driver API */
=20
-static int init_mode =3D CARD_DEFAULT_IW_MODE;
-static int init_channel =3D CARD_DEFAULT_CHANNEL;
-static int init_wep =3D CARD_DEFAULT_WEP;
-static int init_filter =3D CARD_DEFAULT_FILTER;
-static int init_authen =3D CARD_DEFAULT_AUTHEN;
-static int init_dot1x =3D CARD_DEFAULT_DOT1X;
-static int init_conformance =3D CARD_DEFAULT_CONFORMANCE;
-static int init_mlme =3D CARD_DEFAULT_MLME_MODE;
-
-module_param(init_mode, int, 0);
-MODULE_PARM_DESC(init_mode,
-		 "Set card mode:\n0: Auto\n1: Ad-Hoc\n2: Managed Client (Default)\n3: Ma=
ster / Access Point\n4: Repeater (Not supported yet)\n5: Secondary (Not sup=
ported yet)\n6: Monitor");
-
-module_param(init_channel, int, 0);
-MODULE_PARM_DESC(init_channel,
-		 "Check `iwpriv ethx channel` for available channels");
-
-module_param(init_wep, int, 0);
-module_param(init_filter, int, 0);
-
-module_param(init_authen, int, 0);
-MODULE_PARM_DESC(init_authen,
-		 "Authentication method. Can be of seven types:\n0 0x0000: None\n1 0x000=
1: DOT11_AUTH_OS (Default)\n2 0x0002: DOT11_AUTH_SK\n3 0x0003: DOT11_AUTH_B=
OTH");
-
-module_param(init_dot1x, int, 0);
-MODULE_PARM_DESC(init_dot1x,
-		 "\n0: None/not set	(Default)\n1: DOT11_DOT1X_AUTHENABLED\n2: DOT11_DOT1=
X_KEYTXENABLED");
-
-module_param(init_mlme, int, 0);
-MODULE_PARM_DESC(init_mlme,
-		 "Sets the MAC layer management entity (MLME) mode of operation,\n0: DOT=
11_MLME_AUTO (Default)\n1: DOT11_MLME_INTERMEDIATE\n2: DOT11_MLME_EXTENDED"=
);
-
 /**
  * prism54_mib_mode_helper - MIB change mode helper function
  * @mib: the &struct islpci_mib object to modify
@@ -141,36 +109,34 @@ prism54_mib_mode_helper(islpci_private *
 void
 prism54_mib_init(islpci_private *priv)
 {
-	u32 t;
+	u32 channel, authen, wep, filter, dot1x, mlme, conformance, power, mode;
 	struct obj_buffer psm_buffer =3D {
 		.size =3D PSM_BUFFER_SIZE,
 		.addr =3D priv->device_psm_buffer
 	};
=20
-	mgt_set(priv, DOT11_OID_CHANNEL, &init_channel);
-	mgt_set(priv, DOT11_OID_AUTHENABLE, &init_authen);
-	mgt_set(priv, DOT11_OID_PRIVACYINVOKED, &init_wep);
-
+	channel =3D CARD_DEFAULT_CHANNEL;
+	authen =3D CARD_DEFAULT_AUTHEN;
+	wep =3D CARD_DEFAULT_WEP;
+	filter =3D CARD_DEFAULT_FILTER; /* (0) Do not filter un-encrypted data */
+	dot1x =3D CARD_DEFAULT_DOT1X;=20
+	mlme =3D CARD_DEFAULT_MLME_MODE;
+	conformance =3D CARD_DEFAULT_CONFORMANCE;
+	power =3D 127;
+	mode =3D CARD_DEFAULT_IW_MODE;
+
+	mgt_set(priv, DOT11_OID_CHANNEL, &channel);
+	mgt_set(priv, DOT11_OID_AUTHENABLE, &authen);
+	mgt_set(priv, DOT11_OID_PRIVACYINVOKED, &wep);
 	mgt_set(priv, DOT11_OID_PSMBUFFER, &psm_buffer);
-	mgt_set(priv, DOT11_OID_EXUNENCRYPTED, &init_filter);
-	mgt_set(priv, DOT11_OID_DOT1XENABLE, &init_dot1x);
-	mgt_set(priv, DOT11_OID_MLMEAUTOLEVEL, &init_mlme);
-	mgt_set(priv, OID_INL_DOT11D_CONFORMANCE, &init_conformance);
-
-	t =3D 127;
-	mgt_set(priv, OID_INL_OUTPUTPOWER, &t);
-
-	/* Important: we are setting a default wireless mode and we are=20
-	 * forcing a valid one, so prism54_mib_mode_helper should just set
-	 * mib values depending on what the wireless mode given is. No need
-	 * for it save old values */
-	if (init_mode > IW_MODE_MONITOR || init_mode < IW_MODE_AUTO) {
-		printk(KERN_DEBUG "%s(): You passed a non-valid init_mode. "
-		       "Using default mode\n", __FUNCTION__);
-		init_mode =3D CARD_DEFAULT_IW_MODE;
-	}
+	mgt_set(priv, DOT11_OID_EXUNENCRYPTED, &filter);
+	mgt_set(priv, DOT11_OID_DOT1XENABLE, &dot1x);
+	mgt_set(priv, DOT11_OID_MLMEAUTOLEVEL, &mlme);
+	mgt_set(priv, OID_INL_DOT11D_CONFORMANCE, &conformance);
+	mgt_set(priv, OID_INL_OUTPUTPOWER, &power);
+
 	/* This sets all of the mode-dependent values */
-	prism54_mib_mode_helper(priv, init_mode);
+	prism54_mib_mode_helper(priv, mode);
 }
=20
 /* this will be executed outside of atomic context thanks to

--RDS4xtyBfx+7DiaI--

--TBNym+cBXeFsS4Vs
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQFBJTDzat1JN+IKUl4RAgnRAJ46BCPB0b2QwMs3qSscLabVitlo0ACfaZBw
EDWn4qK7Tsyvjr/RqGOWhRg=
=EK89
-----END PGP SIGNATURE-----

--TBNym+cBXeFsS4Vs--

--===============1315725657==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Prism54-devel mailing list
Prism54-devel@prism54.org
http://prism54.org/mailman/listinfo/prism54-devel

--===============1315725657==--
