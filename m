From: Sven Anders <sven@anduras.de>
Subject: [PATCH] e1000e: Fix usage under kexec
Date: Mon, 09 Nov 2009 21:25:21 +0100
Message-ID: <4AF87AB1.1070603@anduras.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig987ADF05B7B6FB7BAE591B81"
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metropolitan.anduras.de ([80.237.200.159]:43418 "EHLO
	metropolitan.anduras.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754037AbZKIUZS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Nov 2009 15:25:18 -0500
Received: from popper.anduras.office (p54918733.dip0.t-ipconnect.de [84.145.135.51])
	(Authenticated sender: anduras@anduras.priv)
	by metropolitan.anduras.de (Postfix) with ESMTP id 644001E543C
	for <netdev@vger.kernel.org>; Mon,  9 Nov 2009 21:25:23 +0100 (CET)
Received: from localhost (localhost [127.0.0.1])
	by popper.anduras.office (Postfix) with ESMTP id EE4CC2140A5
	for <netdev@vger.kernel.org>; Mon,  9 Nov 2009 21:25:22 +0100 (CET)
Received: from popper.anduras.office ([127.0.0.1])
	by localhost (popper.anduras.office [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 12843-05 for <netdev@vger.kernel.org>;
	Mon, 9 Nov 2009 21:25:22 +0100 (CET)
Received: from [192.168.10.15] (suburban.anduras.office [10.10.20.242])
	by popper.anduras.office (Postfix) with ESMTP id 787D6214001
	for <netdev@vger.kernel.org>; Mon,  9 Nov 2009 21:25:22 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig987ADF05B7B6FB7BAE591B81
Content-Type: multipart/mixed;
 boundary="------------040600080801070608080509"

This is a multi-part message in MIME format.
--------------040600080801070608080509
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: quoted-printable

Hello!

We're experiencing the following problem:

We start a minimal linux system, prepare the system and start the
final system via kexec.
On two different systems (one with a 82573 and one with a 82574),
the driver cannot initialize the network hardware, because the PHY
is not recognized.

We get the following error:
  e1000e: probe of 0000:02:00.0 failed with error -2

We cannot unload the driver of the first kernel, because it's
compiled in statically.

It's caused by the PHY, because it's already initialized by the
first driver and therefore does not respond correctly. The driver
assumes the PHY to be in 'reset' state, which is done by the BIOS.

We fixed it by adding a

+       /* Reset PHY before initializing it. Allows re-init after kexec. =
*/
+       if (!e1000_check_reset_block(hw))
+         e1000_phy_hw_reset(hw);

to the initialization routine. I'm not sure, if we need the additional
"block" check.
A patch is attached.

Please send a note, if the patch is correct or wrong...

Regards
 Sven Anders

--=20
 Sven Anders <anders@anduras.de>                 () Ascii Ribbon Campaign=

                                                 /\ Support plain text e-=
mail
 ANDURAS service solutions AG
 Innstrasse 71 - 94036 Passau - Germany
 Web: www.anduras.de - Tel: +49 (0)851-4 90 50-0 - Fax: +49 (0)851-4 90 5=
0-55

Those who would give up essential Liberty, to purchase a little
temporary Safety, deserve neither Liberty nor Safety.
  - Benjamin Franklin

--------------040600080801070608080509
Content-Type: text/x-patch;
 name="e1000e-kexec.patch"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline;
 filename="e1000e-kexec.patch"

--- linux-2.6.29.6/drivers/net/e1000e/82571.c.orig	2009-11-04 00:44:27.00=
0000000 +0100
+++ linux-2.6.29.6/drivers/net/e1000e/82571.c	2009-11-04 00:44:19.0000000=
00 +0100
@@ -107,6 +107,10 @@ static s32 e1000_init_phy_params_82571(s
 		break;
 	}
=20
+	/* Reset PHY before initializing it. Allows re-init after kexec. */
+	if (!e1000_check_reset_block(hw))
+	  e1000_phy_hw_reset(hw);
+
 	/* This can only be done after all function pointers are setup. */
 	ret_val =3D e1000_get_phy_id_82571(hw);
=20

--------------040600080801070608080509
Content-Type: text/x-vcard; charset=utf-8;
 name="sven.vcf"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
 filename="sven.vcf"

begin:vcard
fn:Sven Anders
n:Anders;Sven
adr;quoted-printable:;;Weidestra=3DC3=3D9Fe 19;Hannover;Niedersachsen;304=
53;Deutschland
email;internet:sven@anduras.de
tel;home:+49 (0)511 / 2123090
tel;cell:+49 (0)170 / 8091180
x-mozilla-html:FALSE
url:http://staff.anduras.de/anders
version:2.1
end:vcard


--------------040600080801070608080509--

--------------enig987ADF05B7B6FB7BAE591B81
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iEYEARECAAYFAkr4erEACgkQ5lKZ7Feg4EdPaACfeo95plhp3TcMySPb8sv0++Xg
8kEAoIFBHlLfmGdmQN9ZGZjRd0G4929j
=ir6t
-----END PGP SIGNATURE-----

--------------enig987ADF05B7B6FB7BAE591B81--
