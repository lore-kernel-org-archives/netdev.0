From: Michael Wu <flamingice@sourmilk.net>
Subject: [PATCH] zd1211rw-d80211: check IEEE80211_TXCTL_USE_CTS_PROTECT
Date: Tue, 5 Dec 2006 18:48:52 -0500
Message-ID: <200612051848.57138.flamingice@sourmilk.net>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart24282050.Vrlut0OJjZ";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Ulrich Kunitz <kune@deine-taler.de>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.rutgers.edu ([128.6.72.243]:47708 "EHLO
	annwn14.rutgers.edu" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755519AbWLEXtN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Dec 2006 18:49:13 -0500
To: Daniel Drake <dsd@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart24282050.Vrlut0OJjZ
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

zd1211rw-d80211: check IEEE80211_TXCTL_USE_CTS_PROTECT

This makes zd1211 check for IEEE80211_TXCTL_USE_CTS_PROTECT and set things
appropriately in the hardware TX header.

Signed-off-by: Michael Wu <flamingice@sourmilk.net>
=2D--

 drivers/net/wireless/d80211/zd1211rw/zd_mac.c |   14 +++++---------
 1 files changed, 5 insertions(+), 9 deletions(-)

diff --git a/drivers/net/wireless/d80211/zd1211rw/zd_mac.c=20
b/drivers/net/wireless/d80211/zd1211rw/zd_mac.c
index dde972d..a76fa6a 100644
=2D-- a/drivers/net/wireless/d80211/zd1211rw/zd_mac.c
+++ b/drivers/net/wireless/d80211/zd1211rw/zd_mac.c
@@ -248,15 +248,11 @@ static void cs_set_control(struct zd_mac
 	if ((fctl & IEEE80211_FCTL_STYPE) =3D=3D IEEE80211_STYPE_PSPOLL)
 		cs->control |=3D ZD_CS_PS_POLL_FRAME;
=20
=2D	if (flags & IEEE80211_TXCTL_USE_RTS_CTS) {
=2D		/* FIXME: check the logic */
=2D		if (ZD_CS_TYPE(cs->modulation) =3D=3D ZD_CS_OFDM) {
=2D			/* 802.11g */
=2D			cs->control |=3D ZD_CS_SELF_CTS;
=2D		} else { /* 802.11b */
=2D			cs->control |=3D ZD_CS_RTS;
=2D		}
=2D	}
+	if (flags & IEEE80211_TXCTL_USE_RTS_CTS)
+		cs->control |=3D ZD_CS_RTS;
+
+	if (flags & IEEE80211_TXCTL_USE_CTS_PROTECT)
+		cs->control |=3D ZD_CS_SELF_CTS;
=20
 	/* FIXME: Management frame? */
 }

--nextPart24282050.Vrlut0OJjZ
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBFdgVoT3Oqt9AH4aERAiQwAJ0WP1fWNCp3iwJJMyvTctkjKJUQiACbBmhB
2phk4SnY9ktjAauq/Z6BP0M=
=qmHa
-----END PGP SIGNATURE-----

--nextPart24282050.Vrlut0OJjZ--
