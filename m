From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 14/14] d80211: move d80211_common.h to net/d80211
Date: Wed, 13 Dec 2006 17:41:50 +0100 (CET)
Message-ID: <20061213164150.1664C3AA7ED@silver.suse.cz>
References: <20061213174109.005697000.midnight@suse.cz>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:57270 "EHLO silver.suse.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S965047AbWLMRIz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Dec 2006 12:08:55 -0500
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20061213174109.005697000.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Michael Wu <flamingice@sourmilk.net>

This moves d80211_common.h to net/d80211/ieee80211_common.h since
d80211 drivers should not include this file.

Signed-off-by: Michael Wu <flamingice@sourmilk.net>
Signed-off-by: Jiri Benc <jbenc@suse.cz>

---

 drivers/net/wireless/d80211/bcm43xx/bcm43xx.h |    1 
 include/net/d80211_common.h                   |   98 -------------------------
 net/d80211/ieee80211.c                        |    2 -
 net/d80211/ieee80211_common.h                 |   98 +++++++++++++++++++++++++
 net/d80211/wpa.c                              |    2 -
 5 files changed, 100 insertions(+), 101 deletions(-)
 delete mode 100644 include/net/d80211_common.h
 create mode 100644 net/d80211/ieee80211_common.h

4ae94181f808da96352478c6d4102e3b0b5dfaac
diff --git a/drivers/net/wireless/d80211/bcm43xx/bcm43xx.h b/drivers/net/wireless/d80211/bcm43xx/bcm43xx.h
index a607857..55258e7 100644
--- a/drivers/net/wireless/d80211/bcm43xx/bcm43xx.h
+++ b/drivers/net/wireless/d80211/bcm43xx/bcm43xx.h
@@ -14,7 +14,6 @@ #include <asm/io.h>
 #include <linux/ssb.h>
 #include <linux/wireless.h>
 #include <net/d80211.h>
-#include <net/d80211_common.h>
 
 #include "bcm43xx_debugfs.h"
 #include "bcm43xx_leds.h"
diff --git a/include/net/d80211_common.h b/include/net/d80211_common.h
deleted file mode 100644
index 31167f0..0000000
--- a/include/net/d80211_common.h
+++ /dev/null
@@ -1,98 +0,0 @@
-/*
- * IEEE 802.11 driver (80211.o) -- hostapd interface
- * Copyright 2002-2004, Instant802 Networks, Inc.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 as
- * published by the Free Software Foundation.
- */
-
-#ifndef D80211_COMMON_H
-#define D80211_COMMON_H
-
-#include <linux/types.h>
-
-/*
- * This is common header information with user space. It is used on all
- * frames sent to wlan#ap interface.
- */
-
-#define IEEE80211_FI_VERSION 0x80211001
-
-struct ieee80211_frame_info {
-	__be32 version;
-	__be32 length;
-	__be64 mactime;
-	__be64 hosttime;
-	__be32 phytype;
-	__be32 channel;
-	__be32 datarate;
-	__be32 antenna;
-	__be32 priority;
-	__be32 ssi_type;
-	__be32 ssi_signal;
-	__be32 ssi_noise;
-	__be32 preamble;
-	__be32 encoding;
-
-	/* Note: this structure is otherwise identical to capture format used
-	 * in linux-wlan-ng, but this additional field is used to provide meta
-	 * data about the frame to hostapd. This was the easiest method for
-	 * providing this information, but this might change in the future. */
-	__be32 msg_type;
-} __attribute__ ((packed));
-
-
-enum ieee80211_msg_type {
-	ieee80211_msg_normal = 0,
-	ieee80211_msg_tx_callback_ack = 1,
-	ieee80211_msg_tx_callback_fail = 2,
-	ieee80211_msg_passive_scan = 3,
-	ieee80211_msg_wep_frame_unknown_key = 4,
-	ieee80211_msg_michael_mic_failure = 5,
-	/* hole at 6, was monitor but never sent to userspace */
-	ieee80211_msg_sta_not_assoc = 7,
-	ieee80211_msg_set_aid_for_sta = 8 /* used by Intersil MVC driver */,
-	ieee80211_msg_key_threshold_notification = 9,
-	ieee80211_msg_radar = 11,
-};
-
-struct ieee80211_msg_set_aid_for_sta {
-	char	sta_address[ETH_ALEN];
-	u16	aid;
-};
-
-struct ieee80211_msg_key_notification {
-	int tx_rx_count;
-	char ifname[IFNAMSIZ];
-	u8 addr[ETH_ALEN]; /* ff:ff:ff:ff:ff:ff for broadcast keys */
-};
-
-
-enum ieee80211_phytype {
-        ieee80211_phytype_fhss_dot11_97  = 1,
-        ieee80211_phytype_dsss_dot11_97  = 2,
-        ieee80211_phytype_irbaseband     = 3,
-        ieee80211_phytype_dsss_dot11_b   = 4,
-        ieee80211_phytype_pbcc_dot11_b   = 5,
-        ieee80211_phytype_ofdm_dot11_g   = 6,
-        ieee80211_phytype_pbcc_dot11_g   = 7,
-        ieee80211_phytype_ofdm_dot11_a   = 8,
-        ieee80211_phytype_dsss_dot11_turbog = 255,
-        ieee80211_phytype_dsss_dot11_turbo = 256,
-};
-
-enum ieee80211_ssi_type {
-        ieee80211_ssi_none = 0,
-        ieee80211_ssi_norm = 1, /* normalized, 0-1000 */
-        ieee80211_ssi_dbm = 2,
-        ieee80211_ssi_raw = 3, /* raw SSI */
-};
-
-struct ieee80211_radar_info {
-		int channel;
-		int radar;
-		int radar_type;
-};
-
-#endif /* D80211_COMMON_H */
diff --git a/net/d80211/ieee80211.c b/net/d80211/ieee80211.c
index 6e6d8bd..13484fb 100644
--- a/net/d80211/ieee80211.c
+++ b/net/d80211/ieee80211.c
@@ -22,7 +22,7 @@ #include <net/iw_handler.h>
 #include <linux/compiler.h>
 #include <linux/bitmap.h>
 
-#include <net/d80211_common.h>
+#include "ieee80211_common.h"
 #include "ieee80211_i.h"
 #include "ieee80211_rate.h"
 #include "wep.h"
diff --git a/net/d80211/ieee80211_common.h b/net/d80211/ieee80211_common.h
new file mode 100644
index 0000000..06c970d
--- /dev/null
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
+	ieee80211_msg_normal = 0,
+	ieee80211_msg_tx_callback_ack = 1,
+	ieee80211_msg_tx_callback_fail = 2,
+	ieee80211_msg_passive_scan = 3,
+	ieee80211_msg_wep_frame_unknown_key = 4,
+	ieee80211_msg_michael_mic_failure = 5,
+	/* hole at 6, was monitor but never sent to userspace */
+	ieee80211_msg_sta_not_assoc = 7,
+	ieee80211_msg_set_aid_for_sta = 8 /* used by Intersil MVC driver */,
+	ieee80211_msg_key_threshold_notification = 9,
+	ieee80211_msg_radar = 11,
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
+        ieee80211_phytype_fhss_dot11_97  = 1,
+        ieee80211_phytype_dsss_dot11_97  = 2,
+        ieee80211_phytype_irbaseband     = 3,
+        ieee80211_phytype_dsss_dot11_b   = 4,
+        ieee80211_phytype_pbcc_dot11_b   = 5,
+        ieee80211_phytype_ofdm_dot11_g   = 6,
+        ieee80211_phytype_pbcc_dot11_g   = 7,
+        ieee80211_phytype_ofdm_dot11_a   = 8,
+        ieee80211_phytype_dsss_dot11_turbog = 255,
+        ieee80211_phytype_dsss_dot11_turbo = 256,
+};
+
+enum ieee80211_ssi_type {
+        ieee80211_ssi_none = 0,
+        ieee80211_ssi_norm = 1, /* normalized, 0-1000 */
+        ieee80211_ssi_dbm = 2,
+        ieee80211_ssi_raw = 3, /* raw SSI */
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
--- a/net/d80211/wpa.c
+++ b/net/d80211/wpa.c
@@ -14,7 +14,7 @@ #include <linux/compiler.h>
 #include <net/iw_handler.h>
 
 #include <net/d80211.h>
-#include <net/d80211_common.h>
+#include "ieee80211_common.h"
 #include "ieee80211_i.h"
 #include "michael.h"
 #include "tkip.h"
-- 
1.3.0

