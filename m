From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH ethtool] Fix ETHTOOL_ENABLE_PRETTY_DUMP conditions
Date: Mon, 21 Apr 2014 23:40:52 +0100
Message-ID: <1398120052.3624.162.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-SnkzZhCAEn3HbRofdyzS"
Cc: Florian Fainelli <f.fainelli@gmail.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:51349 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754599AbaDUWk5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Apr 2014 18:40:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-SnkzZhCAEn3HbRofdyzS
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

The C macro ETHTOOL_ENABLE_PRETTY_DUMP was not being defined by default.
Rearrange the autoconf mess to fix this.

The macro name was also misspelt in one condition.

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
I applied this before the 3.14 release I just made.  autotools continues
to surprise me, never pleasantly.

Ben.

 configure.ac | 15 ++++++++-------
 ethtool.c    |  2 +-
 2 files changed, 9 insertions(+), 8 deletions(-)

diff --git a/configure.ac b/configure.ac
index c08938b..ab0b01b 100644
--- a/configure.ac
+++ b/configure.ac
@@ -32,13 +32,14 @@ AC_CHECK_FUNCS(socket strtol)
=20
 dnl Check for options
 AC_ARG_ENABLE(pretty-dump,
-	       [  --enable-pretty-dump	  enable registers, EEPROM and SFP pretty =
dumps (enabled by default)],
-	       [if test x$enableval !=3D xno; then
-			AC_DEFINE(ETHTOOL_ENABLE_PRETTY_DUMP, 1,
-			[Define this to enable register, EEPROM and SFP pretty dumps.]) enable_=
prettydump=3Dyes
-		fi],
-	       enable_prettydump=3Dyes)
-AM_CONDITIONAL([ETHTOOL_ENABLE_PRETTY_DUMP], [test x$enable_prettydump =3D=
 xyes])
+	      [  --enable-pretty-dump	  enable registers, EEPROM and SFP pretty d=
umps (enabled by default)],
+	      ,
+	      enable_pretty_dump=3Dyes)
+if test x$enable_pretty_dump =3D xyes; then
+    AC_DEFINE(ETHTOOL_ENABLE_PRETTY_DUMP, 1,
+	      [Define this to enable register, EEPROM and SFP pretty dumps.])
+fi
+AM_CONDITIONAL([ETHTOOL_ENABLE_PRETTY_DUMP], [test x$enable_pretty_dump =
=3D xyes])
=20
 AC_CONFIG_FILES([Makefile ethtool.spec ethtool.8])
 AC_OUTPUT
diff --git a/ethtool.c b/ethtool.c
index 091a6b9..8e968a8 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -979,7 +979,7 @@ static int dump_eeprom(int geeprom_dump_raw, struct eth=
tool_drvinfo *info,
 		fwrite(ee->data, 1, ee->len, stdout);
 		return 0;
 	}
-#ifdef ETHTOOL_ENABL_PRETTY_DUMP
+#ifdef ETHTOOL_ENABLE_PRETTY_DUMP
 	if (!strncmp("natsemi", info->driver, ETHTOOL_BUSINFO_LEN)) {
 		return natsemi_dump_eeprom(info, ee);
 	} else if (!strncmp("tg3", info->driver, ETHTOOL_BUSINFO_LEN)) {

--=20
Ben Hutchings
Knowledge is power.  France is bacon.

--=-SnkzZhCAEn3HbRofdyzS
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAU1WedOe/yOyVhhEJAQozbw/+NlpTt/T6Q6GzVmubbT8gX82E6FsUKDe9
goMyhqC+sxEpCozV7oO9mETKLs2DiIGjNRVRVqwyNK6003cwEvwRYWCUCwtvi90f
htbnxh9NLFa3zOMwdW9kaxflXO9EgkoInxcJxOlRN5MrJviQovYT/euwTbXRdmX2
674ZZbsoDcGAtm8giSTP/Ek+VPNAbIBAiC8UuDLy1c8VzXkne7RuWhyULqN6Wq04
V8/KjqwtRc1viGt6zJ6lO29CCpB2XH3mPb1AjYia01QJ9SUdk3UCOOpHiwVtje5u
z3hrjeTfr92gA+QYcoXXV9bYacpitP4Qb0bcqeaWV1L6lkeh+Slr9qSsxb3/uGjX
kMzK9cwwnS+DwZJek58zDSEbDm7j5AAppSccSj/P2jq4gTmBUHG21rCrqj74IF8u
4KYMOMXuRJ9Eo//WK0dZPdLTgG7bF0CrfYe6izRIGXqemteufIVpPbwmLvzmADs1
w2W2Zp7cgtk8G7ePaMMiaHIKkE67TToA/ZRDy4/Xc3+AuGMUoZkZN58FuMF0lbZI
eaZcGxT4KhHFMe2rg2bSIZ2zz0AkqWWAZzvasdEetSMzBQE0UeztYZ5bcm88gcVK
IX3KJyztD4w0MlBB4TbU7QKJaWodi/zRGEvfHDCG1m4Gma3ntvHQe4/HL5MdKIRr
CfqqDzYqMeU=
=lnm4
-----END PGP SIGNATURE-----

--=-SnkzZhCAEn3HbRofdyzS--
