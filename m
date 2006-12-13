From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 12/14] d80211: merge d80211_shared.h into d80211.h
Date: Wed, 13 Dec 2006 17:41:47 +0100 (CET)
Message-ID: <20061213164147.D6BD63AA7EB@silver.suse.cz>
References: <20061213174109.005697000.midnight@suse.cz>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:57269 "EHLO silver.suse.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S965046AbWLMRIz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Dec 2006 12:08:55 -0500
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20061213174109.005697000.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Michael Wu <flamingice@sourmilk.net>

This merges d80211_shared.h into d80211.h.

Signed-off-by: Michael Wu <flamingice@sourmilk.net>
Signed-off-by: Jiri Benc <jbenc@suse.cz>

---

 include/net/d80211.h        |   32 +++++++++++++++++++++++++++++-
 include/net/d80211_shared.h |   46 -------------------------------------------
 2 files changed, 31 insertions(+), 47 deletions(-)
 delete mode 100644 include/net/d80211_shared.h

3dbbcd7c8aaec66320f38835ceea04f5ce4bc456
diff --git a/include/net/d80211.h b/include/net/d80211.h
index 688c625..c7e5bb3 100644
--- a/include/net/d80211.h
+++ b/include/net/d80211.h
@@ -16,7 +16,6 @@ #include <linux/skbuff.h>
 #include <linux/wireless.h>
 #include <linux/device.h>
 #include <linux/ieee80211.h>
-#include "d80211_shared.h"
 
 /* Note! Only ieee80211_tx_status_irqsafe() and ieee80211_rx_irqsafe() can be
  * called in hardware interrupt context. The low-level driver must not call any
@@ -47,6 +46,10 @@ #include "d80211_shared.h"
 #define IEEE80211_VERSION 2
 
 
+#define IEEE80211_CHAN_W_SCAN 0x00000001
+#define IEEE80211_CHAN_W_ACTIVE_SCAN 0x00000002
+#define IEEE80211_CHAN_W_IBSS 0x00000004
+
 /* Channel information structure. Low-level driver is expected to fill in chan,
  * freq, and val fields. Other fields will be filled in by 80211.o based on
  * hostapd information and low-level driver does not need to use them. The
@@ -61,6 +64,22 @@ struct ieee80211_channel {
         unsigned char antenna_max;
 };
 
+#define IEEE80211_RATE_ERP 0x00000001
+#define IEEE80211_RATE_BASIC 0x00000002
+#define IEEE80211_RATE_PREAMBLE2 0x00000004
+#define IEEE80211_RATE_SUPPORTED 0x00000010
+#define IEEE80211_RATE_OFDM 0x00000020
+#define IEEE80211_RATE_CCK 0x00000040
+#define IEEE80211_RATE_TURBO 0x00000080
+#define IEEE80211_RATE_MANDATORY 0x00000100
+
+#define IEEE80211_RATE_CCK_2 (IEEE80211_RATE_CCK | IEEE80211_RATE_PREAMBLE2)
+#define IEEE80211_RATE_MODULATION(f) \
+(f & (IEEE80211_RATE_CCK | IEEE80211_RATE_OFDM))
+
+/* Low-level driver should set PREAMBLE2, OFDM, CCK, and TURBO flags.
+ * BASIC, SUPPORTED, ERP, and MANDATORY flags are set in 80211.o based on the
+ * configuration. */
 struct ieee80211_rate {
 	int rate; /* rate in 100 kbps */
 	int val; /* hw specific value for the rate */
@@ -77,6 +96,17 @@ struct ieee80211_rate {
 		       * optimizing channel utilization estimates */
 };
 
+/* 802.11g is backwards-compatible with 802.11b, so a wlan card can
+ * actually be both in 11b and 11g modes at the same time. */
+enum {
+	MODE_IEEE80211A = 0 /* IEEE 802.11a */,
+	MODE_IEEE80211B = 1 /* IEEE 802.11b only */,
+	MODE_ATHEROS_TURBO = 2 /* Atheros Turbo mode (2x.11a at 5 GHz) */,
+	MODE_IEEE80211G = 3 /* IEEE 802.11g (and 802.11b compatibility) */,
+	MODE_ATHEROS_TURBOG = 4 /* Atheros Turbo mode (2x.11g at 2.4 GHz) */,
+	NUM_IEEE80211_MODES = 5
+};
+
 struct ieee80211_hw_modes {
 	int mode;
 	int num_channels;
diff --git a/include/net/d80211_shared.h b/include/net/d80211_shared.h
deleted file mode 100644
index 2f1bb42..0000000
--- a/include/net/d80211_shared.h
+++ /dev/null
@@ -1,46 +0,0 @@
-/*
- * IEEE 802.11 -- shared defines for low-level drivers, 80211.o, and hostapd
- * Copyright 2002-2004, Instant802 Networks, Inc.
- * Copyright 2005, Devicescape Software, Inc.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 as
- * published by the Free Software Foundation.
- */
-
-#ifndef D80211_SHARED_H
-#define D80211_SHARED_H
-
-/* 802.11g is backwards-compatible with 802.11b, so a wlan card can
- * actually be both in 11b and 11g modes at the same time. */
-enum {
-	MODE_IEEE80211A = 0 /* IEEE 802.11a */,
-	MODE_IEEE80211B = 1 /* IEEE 802.11b only */,
-	MODE_ATHEROS_TURBO = 2 /* Atheros Turbo mode (2x.11a at 5 GHz) */,
-	MODE_IEEE80211G = 3 /* IEEE 802.11g (and 802.11b compatibility) */,
-	MODE_ATHEROS_TURBOG = 4 /* Atheros Turbo mode (2x.11g at 2.4 GHz) */,
-	NUM_IEEE80211_MODES = 5
-};
-
-#define IEEE80211_CHAN_W_SCAN 0x00000001
-#define IEEE80211_CHAN_W_ACTIVE_SCAN 0x00000002
-#define IEEE80211_CHAN_W_IBSS 0x00000004
-
-/* Low-level driver should set PREAMBLE2, OFDM, CCK, and TURBO flags.
- * BASIC, SUPPORTED, ERP, and MANDATORY flags are set in 80211.o based on the
- * configuration. */
-#define IEEE80211_RATE_ERP 0x00000001
-#define IEEE80211_RATE_BASIC 0x00000002
-#define IEEE80211_RATE_PREAMBLE2 0x00000004
-#define IEEE80211_RATE_SUPPORTED 0x00000010
-#define IEEE80211_RATE_OFDM 0x00000020
-#define IEEE80211_RATE_CCK 0x00000040
-#define IEEE80211_RATE_TURBO 0x00000080
-#define IEEE80211_RATE_MANDATORY 0x00000100
-
-#define IEEE80211_RATE_CCK_2 (IEEE80211_RATE_CCK | IEEE80211_RATE_PREAMBLE2)
-#define IEEE80211_RATE_MODULATION(f) \
-(f & (IEEE80211_RATE_CCK | IEEE80211_RATE_OFDM))
-
-
-#endif /* D80211_SHARED_H */
-- 
1.3.0

