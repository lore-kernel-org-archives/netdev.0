From: Jan Kiszka <jan.kiszka@web.de>
Subject: [PATCH] d80211: don't symlink empty default keys
Date: Tue, 09 Jan 2007 23:33:34 +0100
Message-ID: <45A4183E.4010401@web.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigA6A90330DC2C535CE07298F0"
Cc: netdev@vger.kernel.org, Ivo Van Doorn <ivdoorn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmmailgate02.web.de ([217.72.192.227]:51895 "EHLO
	fmmailgate02.web.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932479AbXAIWdh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jan 2007 17:33:37 -0500
To: Jiri Benc <jbenc@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigA6A90330DC2C535CE07298F0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

This gets rid of annoying

wlan0: cannot create symlink to default key

in my syslog with latest rt2x00. The patch takes care that in case of
(key/old_key =3D=3D NULL && set_tx_key) the existing default key symlink =
is
removed correctly. Moreover, it tests for key!=3DNULL before trying to re=
gister
a new default link.

Signed-off-by: Jan Kiszka <jan.kiszka@web.de>

---
 ieee80211/ieee80211_ioctl.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

Index: rt2x00/ieee80211/ieee80211_ioctl.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- rt2x00.orig/ieee80211/ieee80211_ioctl.c
+++ rt2x00/ieee80211/ieee80211_ioctl.c
@@ -629,7 +629,7 @@ static int ieee80211_set_encryption(stru
 		}
 		kfree(keyconf);
=20
-		if (key && sdata->default_key =3D=3D key) {
+		if (set_tx_key || (key && sdata->default_key =3D=3D key)) {
 			ieee80211_key_sysfs_remove_default(sdata);
 			sdata->default_key =3D NULL;
 		}
@@ -673,7 +673,7 @@ static int ieee80211_set_encryption(stru
 			}
 		}
=20
-		if (old_key && sdata->default_key =3D=3D old_key) {
+		if (set_tx_key || (old_key && sdata->default_key =3D=3D old_key)) {
 			ieee80211_key_sysfs_remove_default(sdata);
 			sdata->default_key =3D NULL;
 		}
@@ -700,7 +700,7 @@ static int ieee80211_set_encryption(stru
=20
 	if (set_tx_key || (!sta && !sdata->default_key && key)) {
 		sdata->default_key =3D key;
-		if (ieee80211_key_sysfs_add_default(sdata))
+		if (key && ieee80211_key_sysfs_add_default(sdata))
 			printk(KERN_WARNING "%s: cannot create symlink to "
 			       "default key\n", dev->name);
 		if (local->ops->set_key_idx &&



--------------enigA6A90330DC2C535CE07298F0
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.5 (GNU/Linux)
Comment: Using GnuPG with SUSE - http://enigmail.mozdev.org

iD8DBQFFpBg+niDOoMHTA+kRAqyYAJ4u0BEgT/l+LXI0nPghi1SPdueG0gCdEEIv
llT0ZADlVu2vjS6rqY5Pm6I=
=Ssn2
-----END PGP SIGNATURE-----

--------------enigA6A90330DC2C535CE07298F0--
