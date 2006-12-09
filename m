From: Michael Wu <flamingice@sourmilk.net>
Subject: [PATCH 2/4] d80211: merge d80211_shared.h into d80211.h
Date: Sat, 9 Dec 2006 03:17:45 -0500
Message-ID: <200612090317.49792.flamingice@sourmilk.net>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart2437115.3c584CTD8O";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, John Linville <linville@tuxdriver.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	Jouni Malinen <jkm@devicescape.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from server8.tchmachines.com ([216.180.241.250]:59293 "EHLO
	server8.tchmachines.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S936168AbWLII3u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Dec 2006 03:29:50 -0500
To: Jiri Benc <jbenc@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart2437115.3c584CTD8O
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

merge d80211_shared.h into d80211.h

This merges d80211_shared.h into d80211.h.

Signed-off-by: Michael Wu <flamingice@sourmilk.net>
=2D--

 include/net/d80211.h        |   32 +++++++++++++++++++++++++++++-
 include/net/d80211_shared.h |   46 ---------------------------------------=
=2D---
 2 files changed, 31 insertions(+), 47 deletions(-)

diff --git a/include/net/d80211.h b/include/net/d80211.h
index 688c625..c7e5bb3 100644
=2D-- a/include/net/d80211.h
+++ b/include/net/d80211.h
@@ -16,7 +16,6 @@
 #include <linux/wireless.h>
 #include <linux/device.h>
 #include <linux/ieee80211.h>
=2D#include "d80211_shared.h"
=20
 /* Note! Only ieee80211_tx_status_irqsafe() and ieee80211_rx_irqsafe() can=
 be
  * called in hardware interrupt context. The low-level driver must not cal=
l any
@@ -47,6 +46,10 @@
 #define IEEE80211_VERSION 2
=20
=20
+#define IEEE80211_CHAN_W_SCAN 0x00000001
+#define IEEE80211_CHAN_W_ACTIVE_SCAN 0x00000002
+#define IEEE80211_CHAN_W_IBSS 0x00000004
+
 /* Channel information structure. Low-level driver is expected to fill in =
chan,
  * freq, and val fields. Other fields will be filled in by 80211.o based on
  * hostapd information and low-level driver does not need to use them. The
@@ -61,6 +64,22 @@ struct ieee80211_channel {
         unsigned char antenna_max;
 };
=20
+#define IEEE80211_RATE_ERP 0x00000001
+#define IEEE80211_RATE_BASIC 0x00000002
+#define IEEE80211_RATE_PREAMBLE2 0x00000004
+#define IEEE80211_RATE_SUPPORTED 0x00000010
+#define IEEE80211_RATE_OFDM 0x00000020
+#define IEEE80211_RATE_CCK 0x00000040
+#define IEEE80211_RATE_TURBO 0x00000080
+#define IEEE80211_RATE_MANDATORY 0x00000100
+
+#define IEEE80211_RATE_CCK_2 (IEEE80211_RATE_CCK | IEEE80211_RATE_PREAMBLE=
2)
+#define IEEE80211_RATE_MODULATION(f) \
+(f & (IEEE80211_RATE_CCK | IEEE80211_RATE_OFDM))
+
+/* Low-level driver should set PREAMBLE2, OFDM, CCK, and TURBO flags.
+ * BASIC, SUPPORTED, ERP, and MANDATORY flags are set in 80211.o based on =
the
+ * configuration. */
 struct ieee80211_rate {
 	int rate; /* rate in 100 kbps */
 	int val; /* hw specific value for the rate */
@@ -77,6 +96,17 @@ struct ieee80211_rate {
 		       * optimizing channel utilization estimates */
 };
=20
+/* 802.11g is backwards-compatible with 802.11b, so a wlan card can
+ * actually be both in 11b and 11g modes at the same time. */
+enum {
+	MODE_IEEE80211A =3D 0 /* IEEE 802.11a */,
+	MODE_IEEE80211B =3D 1 /* IEEE 802.11b only */,
+	MODE_ATHEROS_TURBO =3D 2 /* Atheros Turbo mode (2x.11a at 5 GHz) */,
+	MODE_IEEE80211G =3D 3 /* IEEE 802.11g (and 802.11b compatibility) */,
+	MODE_ATHEROS_TURBOG =3D 4 /* Atheros Turbo mode (2x.11g at 2.4 GHz) */,
+	NUM_IEEE80211_MODES =3D 5
+};
+
 struct ieee80211_hw_modes {
 	int mode;
 	int num_channels;
diff --git a/include/net/d80211_shared.h b/include/net/d80211_shared.h
deleted file mode 100644
index 2f1bb42..0000000
=2D-- a/include/net/d80211_shared.h
+++ /dev/null
@@ -1,46 +0,0 @@
=2D/*
=2D * IEEE 802.11 -- shared defines for low-level drivers, 80211.o, and hos=
tapd
=2D * Copyright 2002-2004, Instant802 Networks, Inc.
=2D * Copyright 2005, Devicescape Software, Inc.
=2D *
=2D * This program is free software; you can redistribute it and/or modify
=2D * it under the terms of the GNU General Public License version 2 as
=2D * published by the Free Software Foundation.
=2D */
=2D
=2D#ifndef D80211_SHARED_H
=2D#define D80211_SHARED_H
=2D
=2D/* 802.11g is backwards-compatible with 802.11b, so a wlan card can
=2D * actually be both in 11b and 11g modes at the same time. */
=2Denum {
=2D	MODE_IEEE80211A =3D 0 /* IEEE 802.11a */,
=2D	MODE_IEEE80211B =3D 1 /* IEEE 802.11b only */,
=2D	MODE_ATHEROS_TURBO =3D 2 /* Atheros Turbo mode (2x.11a at 5 GHz) */,
=2D	MODE_IEEE80211G =3D 3 /* IEEE 802.11g (and 802.11b compatibility) */,
=2D	MODE_ATHEROS_TURBOG =3D 4 /* Atheros Turbo mode (2x.11g at 2.4 GHz) */,
=2D	NUM_IEEE80211_MODES =3D 5
=2D};
=2D
=2D#define IEEE80211_CHAN_W_SCAN 0x00000001
=2D#define IEEE80211_CHAN_W_ACTIVE_SCAN 0x00000002
=2D#define IEEE80211_CHAN_W_IBSS 0x00000004
=2D
=2D/* Low-level driver should set PREAMBLE2, OFDM, CCK, and TURBO flags.
=2D * BASIC, SUPPORTED, ERP, and MANDATORY flags are set in 80211.o based o=
n the
=2D * configuration. */
=2D#define IEEE80211_RATE_ERP 0x00000001
=2D#define IEEE80211_RATE_BASIC 0x00000002
=2D#define IEEE80211_RATE_PREAMBLE2 0x00000004
=2D#define IEEE80211_RATE_SUPPORTED 0x00000010
=2D#define IEEE80211_RATE_OFDM 0x00000020
=2D#define IEEE80211_RATE_CCK 0x00000040
=2D#define IEEE80211_RATE_TURBO 0x00000080
=2D#define IEEE80211_RATE_MANDATORY 0x00000100
=2D
=2D#define IEEE80211_RATE_CCK_2 (IEEE80211_RATE_CCK | IEEE80211_RATE_PREAMB=
LE2)
=2D#define IEEE80211_RATE_MODULATION(f) \
=2D(f & (IEEE80211_RATE_CCK | IEEE80211_RATE_OFDM))
=2D
=2D
=2D#endif /* D80211_SHARED_H */

--nextPart2437115.3c584CTD8O
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBFenEtT3Oqt9AH4aERAswiAKDbk0kSb/nrNryj+lrN8RV1Mu+NwwCghWvV
905YNKflUfzUGe1YRti6X4M=
=2mwO
-----END PGP SIGNATURE-----

--nextPart2437115.3c584CTD8O--
