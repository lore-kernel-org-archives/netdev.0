From: Michael Wu <flamingice@sourmilk.net>
Subject: [PATCH 4/4] d80211: move d80211_common.h to net/d80211
Date: Sat, 9 Dec 2006 03:27:40 -0500
Message-ID: <200612090327.45206.flamingice@sourmilk.net>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart34287510.yFjQHEG9v8";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Johannes Berg <johannes@sipsolutions.net>,
	John Linville <linville@tuxdriver.com>,
	Jouni Malinen <jkm@devicescape.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from server8.tchmachines.com ([216.180.241.250]:59296 "EHLO
	server8.tchmachines.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S936182AbWLII3u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Dec 2006 03:29:50 -0500
To: Jiri Benc <jbenc@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart34287510.yFjQHEG9v8
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

d80211: move d80211_common.h to net/d80211

This moves d80211_common.h to net/d80211/ieee80211_common.h since
d80211 drivers should not include this file.

Signed-off-by: Michael Wu <flamingice@sourmilk.net>
=2D--

 drivers/net/wireless/d80211/bcm43xx/bcm43xx.h |    1=20
 include/net/d80211_common.h                   |   98 ---------------------=
=2D---
 net/d80211/ieee80211.c                        |    2 -
 net/d80211/ieee80211_common.h                 |   98 +++++++++++++++++++++=
++++
 net/d80211/wpa.c                              |    2 -
 5 files changed, 100 insertions(+), 101 deletions(-)

diff --git a/drivers/net/wireless/d80211/bcm43xx/bcm43xx.h b/drivers/net/wi=
reless/d80211/bcm43xx/bcm43xx.h
index a607857..55258e7 100644
=2D-- a/drivers/net/wireless/d80211/bcm43xx/bcm43xx.h
+++ b/drivers/net/wireless/d80211/bcm43xx/bcm43xx.h
@@ -14,7 +14,6 @@
 #include <linux/ssb.h>
 #include <linux/wireless.h>
 #include <net/d80211.h>
=2D#include <net/d80211_common.h>
=20
 #include "bcm43xx_debugfs.h"
 #include "bcm43xx_leds.h"
diff --git a/include/net/d80211_common.h b/include/net/d80211_common.h
deleted file mode 100644
index 31167f0..0000000
=2D-- a/include/net/d80211_common.h
+++ /dev/null
@@ -1,98 +0,0 @@
=2D/*
=2D * IEEE 802.11 driver (80211.o) -- hostapd interface
=2D * Copyright 2002-2004, Instant802 Networks, Inc.
=2D *
=2D * This program is free software; you can redistribute it and/or modify
=2D * it under the terms of the GNU General Public License version 2 as
=2D * published by the Free Software Foundation.
=2D */
=2D
=2D#ifndef D80211_COMMON_H
=2D#define D80211_COMMON_H
=2D
=2D#include <linux/types.h>
=2D
=2D/*
=2D * This is common header information with user space. It is used on all
=2D * frames sent to wlan#ap interface.
=2D */
=2D
=2D#define IEEE80211_FI_VERSION 0x80211001
=2D
=2Dstruct ieee80211_frame_info {
=2D	__be32 version;
=2D	__be32 length;
=2D	__be64 mactime;
=2D	__be64 hosttime;
=2D	__be32 phytype;
=2D	__be32 channel;
=2D	__be32 datarate;
=2D	__be32 antenna;
=2D	__be32 priority;
=2D	__be32 ssi_type;
=2D	__be32 ssi_signal;
=2D	__be32 ssi_noise;
=2D	__be32 preamble;
=2D	__be32 encoding;
=2D
=2D	/* Note: this structure is otherwise identical to capture format used
=2D	 * in linux-wlan-ng, but this additional field is used to provide meta
=2D	 * data about the frame to hostapd. This was the easiest method for
=2D	 * providing this information, but this might change in the future. */
=2D	__be32 msg_type;
=2D} __attribute__ ((packed));
=2D
=2D
=2Denum ieee80211_msg_type {
=2D	ieee80211_msg_normal =3D 0,
=2D	ieee80211_msg_tx_callback_ack =3D 1,
=2D	ieee80211_msg_tx_callback_fail =3D 2,
=2D	ieee80211_msg_passive_scan =3D 3,
=2D	ieee80211_msg_wep_frame_unknown_key =3D 4,
=2D	ieee80211_msg_michael_mic_failure =3D 5,
=2D	/* hole at 6, was monitor but never sent to userspace */
=2D	ieee80211_msg_sta_not_assoc =3D 7,
=2D	ieee80211_msg_set_aid_for_sta =3D 8 /* used by Intersil MVC driver */,
=2D	ieee80211_msg_key_threshold_notification =3D 9,
=2D	ieee80211_msg_radar =3D 11,
=2D};
=2D
=2Dstruct ieee80211_msg_set_aid_for_sta {
=2D	char	sta_address[ETH_ALEN];
=2D	u16	aid;
=2D};
=2D
=2Dstruct ieee80211_msg_key_notification {
=2D	int tx_rx_count;
=2D	char ifname[IFNAMSIZ];
=2D	u8 addr[ETH_ALEN]; /* ff:ff:ff:ff:ff:ff for broadcast keys */
=2D};
=2D
=2D
=2Denum ieee80211_phytype {
=2D        ieee80211_phytype_fhss_dot11_97  =3D 1,
=2D        ieee80211_phytype_dsss_dot11_97  =3D 2,
=2D        ieee80211_phytype_irbaseband     =3D 3,
=2D        ieee80211_phytype_dsss_dot11_b   =3D 4,
=2D        ieee80211_phytype_pbcc_dot11_b   =3D 5,
=2D        ieee80211_phytype_ofdm_dot11_g   =3D 6,
=2D        ieee80211_phytype_pbcc_dot11_g   =3D 7,
=2D        ieee80211_phytype_ofdm_dot11_a   =3D 8,
=2D        ieee80211_phytype_dsss_dot11_turbog =3D 255,
=2D        ieee80211_phytype_dsss_dot11_turbo =3D 256,
=2D};
=2D
=2Denum ieee80211_ssi_type {
=2D        ieee80211_ssi_none =3D 0,
=2D        ieee80211_ssi_norm =3D 1, /* normalized, 0-1000 */
=2D        ieee80211_ssi_dbm =3D 2,
=2D        ieee80211_ssi_raw =3D 3, /* raw SSI */
=2D};
=2D
=2Dstruct ieee80211_radar_info {
=2D		int channel;
=2D		int radar;
=2D		int radar_type;
=2D};
=2D
=2D#endif /* D80211_COMMON_H */
diff --git a/net/d80211/ieee80211.c b/net/d80211/ieee80211.c
index d07d927..7c638b9 100644
=2D-- a/net/d80211/ieee80211.c
+++ b/net/d80211/ieee80211.c
@@ -22,7 +22,7 @@
 #include <linux/compiler.h>
 #include <linux/bitmap.h>
=20
=2D#include <net/d80211_common.h>
+#include "ieee80211_common.h"
 #include "ieee80211_i.h"
 #include "ieee80211_rate.h"
 #include "wep.h"
diff --git a/net/d80211/ieee80211_common.h b/net/d80211/ieee80211_common.h
new file mode 100644
index 0000000..06c970d
=2D-- /dev/null
+++ b/net/d80211/ieee80211_common.h
@@ -0,0 +1,98 @@
+/*
+ * IEEE 802.11 driver (80211.o) -- hostapd interface
+ * Copyright 2002-2004, Instant802 Networks, Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#ifndef IEEE80211_COMMON_H
+#define IEEE80211_COMMON_H
+
+#include <linux/types.h>
+
+/*
+ * This is common header information with user space. It is used on all
+ * frames sent to wlan#ap interface.
+ */
+
+#define IEEE80211_FI_VERSION 0x80211001
+
+struct ieee80211_frame_info {
+	__be32 version;
+	__be32 length;
+	__be64 mactime;
+	__be64 hosttime;
+	__be32 phytype;
+	__be32 channel;
+	__be32 datarate;
+	__be32 antenna;
+	__be32 priority;
+	__be32 ssi_type;
+	__be32 ssi_signal;
+	__be32 ssi_noise;
+	__be32 preamble;
+	__be32 encoding;
+
+	/* Note: this structure is otherwise identical to capture format used
+	 * in linux-wlan-ng, but this additional field is used to provide meta
+	 * data about the frame to hostapd. This was the easiest method for
+	 * providing this information, but this might change in the future. */
+	__be32 msg_type;
+} __attribute__ ((packed));
+
+
+enum ieee80211_msg_type {
+	ieee80211_msg_normal =3D 0,
+	ieee80211_msg_tx_callback_ack =3D 1,
+	ieee80211_msg_tx_callback_fail =3D 2,
+	ieee80211_msg_passive_scan =3D 3,
+	ieee80211_msg_wep_frame_unknown_key =3D 4,
+	ieee80211_msg_michael_mic_failure =3D 5,
+	/* hole at 6, was monitor but never sent to userspace */
+	ieee80211_msg_sta_not_assoc =3D 7,
+	ieee80211_msg_set_aid_for_sta =3D 8 /* used by Intersil MVC driver */,
+	ieee80211_msg_key_threshold_notification =3D 9,
+	ieee80211_msg_radar =3D 11,
+};
+
+struct ieee80211_msg_set_aid_for_sta {
+	char	sta_address[ETH_ALEN];
+	u16	aid;
+};
+
+struct ieee80211_msg_key_notification {
+	int tx_rx_count;
+	char ifname[IFNAMSIZ];
+	u8 addr[ETH_ALEN]; /* ff:ff:ff:ff:ff:ff for broadcast keys */
+};
+
+
+enum ieee80211_phytype {
+        ieee80211_phytype_fhss_dot11_97  =3D 1,
+        ieee80211_phytype_dsss_dot11_97  =3D 2,
+        ieee80211_phytype_irbaseband     =3D 3,
+        ieee80211_phytype_dsss_dot11_b   =3D 4,
+        ieee80211_phytype_pbcc_dot11_b   =3D 5,
+        ieee80211_phytype_ofdm_dot11_g   =3D 6,
+        ieee80211_phytype_pbcc_dot11_g   =3D 7,
+        ieee80211_phytype_ofdm_dot11_a   =3D 8,
+        ieee80211_phytype_dsss_dot11_turbog =3D 255,
+        ieee80211_phytype_dsss_dot11_turbo =3D 256,
+};
+
+enum ieee80211_ssi_type {
+        ieee80211_ssi_none =3D 0,
+        ieee80211_ssi_norm =3D 1, /* normalized, 0-1000 */
+        ieee80211_ssi_dbm =3D 2,
+        ieee80211_ssi_raw =3D 3, /* raw SSI */
+};
+
+struct ieee80211_radar_info {
+		int channel;
+		int radar;
+		int radar_type;
+};
+
+#endif /* IEEE80211_COMMON_H */
diff --git a/net/d80211/wpa.c b/net/d80211/wpa.c
index f649156..7b64abf 100644
=2D-- a/net/d80211/wpa.c
+++ b/net/d80211/wpa.c
@@ -14,7 +14,7 @@
 #include <net/iw_handler.h>
=20
 #include <net/d80211.h>
=2D#include <net/d80211_common.h>
+#include "ieee80211_common.h"
 #include "ieee80211_i.h"
 #include "michael.h"
 #include "tkip.h"

--nextPart34287510.yFjQHEG9v8
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBFenOBT3Oqt9AH4aERAiaFAJ0cBAEi227887TX+v4ZOgj4wKlIeQCcD3JV
ZwhiTbwojYT1IQlPK+AHuvI=
=a/+M
-----END PGP SIGNATURE-----

--nextPart34287510.yFjQHEG9v8--
