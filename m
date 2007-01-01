From: Jan Kiszka <jan.kiszka@web.de>
Subject: [PATCH] d80211: Reinit keys on mode change
Date: Mon, 01 Jan 2007 21:19:53 +0100
Message-ID: <45996CE9.1010903@web.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigA7F4E8993005C52DB3FEF621"
Cc: netdev@vger.kernel.org, Ivo Van Doorn <ivdoorn@gmail.com>,
	rt2400-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmmailgate02.web.de ([217.72.192.227]:41551 "EHLO
	fmmailgate02.web.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932804AbXAAUtg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jan 2007 15:49:36 -0500
To: Jiri Benc <jbenc@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigA7F4E8993005C52DB3FEF621
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Switching the interface mode with some encryption keys set and then later=

touching any key, triggers an oops because ieee80211_if_reinit fails to
NULL'ify the related pointers after free'ing the key on mode change. Long=

explanation, simple fix below.

Signed-off-by: Jan Kiszka <jan.kiszka@web.de>

[Sorry, yet another rt2x00 CVS patch...]

---
 ieee80211/ieee80211_iface.c |    1 +
 1 file changed, 1 insertion(+)

Index: rt2x00/ieee80211/ieee80211_iface.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- rt2x00.orig/ieee80211/ieee80211_iface.c
+++ rt2x00/ieee80211/ieee80211_iface.c
@@ -231,6 +231,7 @@ void ieee80211_if_reinit(struct net_devi
 					    local->keys[i], 0);
 #endif
 		ieee80211_key_free(sdata->keys[i]);
+		sdata->keys[i] =3D NULL;
 	}
=20
 	/* Shouldn't be necessary but won't hurt */



--------------enigA7F4E8993005C52DB3FEF621
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)
Comment: Using GnuPG with SUSE - http://enigmail.mozdev.org

iD8DBQFFmWzpniDOoMHTA+kRArThAJ0aPZWWvwXfbCDeMq29OvJI3YWRuwCfRYth
mcrFuFWo5J9u3CmhBkmAh6k=
=lgYd
-----END PGP SIGNATURE-----

--------------enigA7F4E8993005C52DB3FEF621--
