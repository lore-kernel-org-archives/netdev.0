From: Aristeu Sergio Rozanski Filho <aris@cathedrallabs.org>
Subject: [PATCH] 5/5: eepro: fix auto-detection option
Date: Thu, 18 Nov 2004 21:41:03 -0200
Message-ID: <20041118234103.GJ24080@cathedrallabs.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="gIHggtDV96iaw8wO"
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--gIHggtDV96iaw8wO
Content-Type: multipart/mixed; boundary="oJFDFiWc3BlD0xT/"
Content-Disposition: inline


--oJFDFiWc3BlD0xT/
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable


--=20
Aristeu


--oJFDFiWc3BlD0xT/
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="05-eepro-fix_autodetect_option.patch"
Content-Transfer-Encoding: quoted-printable

eepro: fix auto-detection option

Signed-off-by: Aristeu Sergio Rozanski Filho <aris@cathedrallabs.org>

--- 2.6-dual/drivers/net/eepro.c.orig	2004-10-05 22:27:55.000000000 -0300
+++ 2.6-dual/drivers/net/eepro.c	2004-10-05 21:44:23.000000000 -0300
@@ -1779,7 +1779,9 @@ static struct ethtool_ops eepro_ethtool_
 #define MAX_EEPRO 8
 static struct net_device *dev_eepro[MAX_EEPRO];
=20
-static int io[MAX_EEPRO];
+static int io[MAX_EEPRO] =3D {
+  [0 ... MAX_EEPRO-1] =3D -1
+};
 static int irq[MAX_EEPRO];
 static int mem[MAX_EEPRO] =3D {	/* Size of the rx buffer in KB */
   [0 ... MAX_EEPRO-1] =3D RCV_DEFAULT_RAM/1024
@@ -1808,19 +1810,21 @@ init_module(void)
 {
 	struct net_device *dev;
 	int i;
-	if (io[0] =3D=3D 0 && autodetect =3D=3D 0) {
+	if (io[0] =3D=3D -1 && autodetect =3D=3D 0) {
 		printk(KERN_WARNING "eepro_init_module: Probe is very dangerous in ISA b=
oards!\n");
 		printk(KERN_WARNING "eepro_init_module: Please add \"autodetect=3D1\" to=
 force probe\n");
 		return -ENODEV;
 	}
 	else if (autodetect) {
 		/* if autodetect is set then we must force detection */
-		io[0] =3D 0;
+		for (i =3D 0; i < MAX_EEPRO; i++) {
+			io[i] =3D 0;
+		}
=20
 		printk(KERN_INFO "eepro_init_module: Auto-detecting boards (May God prot=
ect us...)\n");
 	}
=20
-	for (i =3D 0; i < MAX_EEPRO; i++) {
+	for (i =3D 0; io[i] !=3D -1 && i < MAX_EEPRO; i++) {
 		dev =3D alloc_etherdev(sizeof(struct eepro_local));
 		if (!dev)
 			break;

--oJFDFiWc3BlD0xT/--

--gIHggtDV96iaw8wO
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQFBnTMPRRJOudsVYbMRAnsIAJ9agNzsJBBjqfP5Xopd1mXv9RB5MACeLjGI
mFOm/TsfbP6/71o+uz66wOU=
=gDax
-----END PGP SIGNATURE-----

--gIHggtDV96iaw8wO--
