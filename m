From: Michael Wu <flamingice@sourmilk.net>
Subject: d80211-drivers pull request (week51)
Date: Sun, 31 Dec 2006 12:41:54 -0500
Message-ID: <200612311241.59944.flamingice@sourmilk.net>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart5238900.nREGAl1MAL";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Daniel Drake <dsd@gentoo.org>,
	Ulrich Kunitz <kune@deine-taler.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from server8.tchmachines.com ([216.180.241.250]:56521 "EHLO
	server8.tchmachines.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030377AbWLaRmb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 Dec 2006 12:42:31 -0500
To: John Linville <linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart5238900.nREGAl1MAL
Content-Type: multipart/mixed;
  boundary="Boundary-01=_iZ/lFUBSaMNg1BA"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

--Boundary-01=_iZ/lFUBSaMNg1BA
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hi John,

Please pull
git://git.kernel.org/pub/scm/linux/kernel/git/mwu/d80211-drivers.git
for these patches:

adm8211-week51 branch:
      adm8211: set phymode in RX

p54-week51 branch:
      p54: fix device memory allocator
      p54: fix TX of encrypted frames
      p54: remove unnecessary use of __constant_cpu_to_*
      p54: use hardware RX frequency reporting
      p54: use link LED
      p54: fix issues found by sparse
      p54: set phymode in RX

zd1211rw-week51 branch:
      zd1211rw-d80211: Fix of a locking bug
      zd1211rw-d80211: Revert "zd1211rw: Removed unneeded packed attributes"
      zd1211rw-d80211: Add 3 more device IDs
      zd1211rw-d80211: Add ID for ZyXEL G-220
      zd1211rw-d80211: Add ID for Planex GW-US54Mini
      zd1211rw-d80211: Add ID for Belkin F5D7050 v4000
      zd1211rw-d80211: cleanups
      zd1211rw-d80211: Optimized handling of zero length entries in length info
      zd1211rw-d80211: check IEEE80211_TXCTL_USE_CTS_PROTECT
      zd1211rw-d80211: Use ieee80211_tx_status
      zd1211rw-d80211: 2 new ZD1211B device ID's
      zd1211rw-d80211: Add ID for Linksys WUSBF54G

The LED class patch for zd1211rw-d80211 was dropped.

A patch which updates zd1211rw-d80211 to the new workqueue API is attached
for when you pull those changes.

Thanks,
-Michael Wu

--Boundary-01=_iZ/lFUBSaMNg1BA
Content-Type: text/x-diff;
  charset="us-ascii";
  name="zd1211rw-d80211-workqueue-fix"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
	filename="zd1211rw-d80211-workqueue-fix"

zd1211rw-d80211: fix workqueue breakage

=46rom: Michael Wu <flamingice@sourmilk.net>

This allows zd1211rw-d80211 to compile with the workqueue API changes.

Signed-off-by: Michael Wu <flamingice@sourmilk.net>
=2D--

 drivers/net/wireless/d80211/zd1211rw/zd_mac.c |    7 ++++---
 drivers/net/wireless/d80211/zd1211rw/zd_mac.h |    2 +-
 2 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/drivers/net/wireless/d80211/zd1211rw/zd_mac.c b/drivers/net/wi=
reless/d80211/zd1211rw/zd_mac.c
index 6ee650f..7044ea3 100644
=2D-- a/drivers/net/wireless/d80211/zd1211rw/zd_mac.c
+++ b/drivers/net/wireless/d80211/zd1211rw/zd_mac.c
@@ -625,9 +625,10 @@ struct ieee80211_hw *zd_mac_alloc(struct
=20
 #define LINK_LED_WORK_DELAY HZ
=20
=2Dstatic void link_led_handler(void *p)
+static void link_led_handler(struct work_struct *work)
 {
=2D	struct zd_mac *mac =3D p;
+	struct zd_mac *mac =3D
+		container_of(work, struct zd_mac, housekeeping.link_led_work);
 	struct zd_chip *chip =3D &mac->chip;
 	int is_associated;
 	int r;
@@ -647,7 +648,7 @@ static void link_led_handler(void *p)
=20
 static void housekeeping_init(struct zd_mac *mac)
 {
=2D	INIT_WORK(&mac->housekeeping.link_led_work, link_led_handler, mac);
+	INIT_DELAYED_WORK(&mac->housekeeping.link_led_work, link_led_handler);
 }
=20
 static void housekeeping_enable(struct zd_mac *mac)
diff --git a/drivers/net/wireless/d80211/zd1211rw/zd_mac.h b/drivers/net/wi=
reless/d80211/zd1211rw/zd_mac.h
index e2ba410..6c402d9 100644
=2D-- a/drivers/net/wireless/d80211/zd1211rw/zd_mac.h
+++ b/drivers/net/wireless/d80211/zd1211rw/zd_mac.h
@@ -119,7 +119,7 @@ enum mac_flags {
 };
=20
 struct housekeeping {
=2D	struct work_struct link_led_work;
+	struct delayed_work link_led_work;
 };
=20
 #define ZD_MAC_STATS_BUFFER_SIZE 16

--Boundary-01=_iZ/lFUBSaMNg1BA--

--nextPart5238900.nREGAl1MAL
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBFl/ZnT3Oqt9AH4aERAp8EAKDT0enHJZTvIYxDiUF0KHjSiRKMhQCeKjWw
4sXHJoHNcGtnt0zyecCP65M=
=xA5X
-----END PGP SIGNATURE-----

--nextPart5238900.nREGAl1MAL--
