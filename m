From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 11/14] d80211: move 802.11 defines to linux/ieee80211.h
Date: Wed, 13 Dec 2006 17:41:46 +0100 (CET)
Message-ID: <20061213164146.C622D3AA7EA@silver.suse.cz>
References: <20061213174109.005697000.midnight@suse.cz>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:57268 "EHLO silver.suse.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S965039AbWLMRIz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Dec 2006 12:08:55 -0500
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20061213174109.005697000.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Michael Wu <flamingice@sourmilk.net>

This moves 802.11 defines from net/d80211.h into linux/ieee80211.h.

It also renames IEEE80211_DATA_LEN to IEEE80211_MAX_DATA_LEN to better
match the other definitions.

Signed-off-by: Michael Wu <flamingice@sourmilk.net>
Signed-off-by: Jiri Benc <jbenc@suse.cz>

---

 include/linux/Kbuild      |    1 
 include/linux/ieee80211.h |  107 +++++++++++++++++++++++++++++++++++++++++++++
 include/net/d80211.h      |   90 --------------------------------------
 net/d80211/ieee80211.c    |    4 +-
 4 files changed, 111 insertions(+), 91 deletions(-)
 create mode 100644 include/linux/ieee80211.h

a2e9253024872101863b1557b116bc95cd2190ef
diff --git a/include/linux/Kbuild b/include/linux/Kbuild
index c051f75..e6dccc8 100644
--- a/include/linux/Kbuild
+++ b/include/linux/Kbuild
@@ -72,6 +72,7 @@ header-y += hysdn_if.h
 header-y += i2c-dev.h
 header-y += i8k.h
 header-y += icmp.h
+header-y += ieee80211.h
 header-y += if_addr.h
 header-y += if_arcnet.h
 header-y += if_arp.h
diff --git a/include/linux/ieee80211.h b/include/linux/ieee80211.h
new file mode 100644
index 0000000..9afa694
--- /dev/null
+++ b/include/linux/ieee80211.h
@@ -0,0 +1,107 @@
+/*
+ * IEEE 802.11 defines
+ *
+ * Copyright (c) 2001-2002, SSH Communications Security Corp and Jouni Malinen
+ * <jkmaline@cc.hut.fi>
+ * Copyright (c) 2002-2003, Jouni Malinen <jkmaline@cc.hut.fi>
+ * Copyright (c) 2005, Devicescape Software, Inc.
+ * Copyright (c) 2006, Michael Wu <flamingice@sourmilk.net>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#ifndef IEEE80211_H
+#define IEEE80211_H
+
+#include <linux/types.h>
+
+#define FCS_LEN 4
+
+#define IEEE80211_FCTL_VERS		0x0003
+#define IEEE80211_FCTL_FTYPE		0x000c
+#define IEEE80211_FCTL_STYPE		0x00f0
+#define IEEE80211_FCTL_TODS		0x0100
+#define IEEE80211_FCTL_FROMDS		0x0200
+#define IEEE80211_FCTL_MOREFRAGS	0x0400
+#define IEEE80211_FCTL_RETRY		0x0800
+#define IEEE80211_FCTL_PM		0x1000
+#define IEEE80211_FCTL_MOREDATA		0x2000
+#define IEEE80211_FCTL_PROTECTED	0x4000
+#define IEEE80211_FCTL_ORDER		0x8000
+
+#define IEEE80211_SCTL_FRAG		0x000F
+#define IEEE80211_SCTL_SEQ		0xFFF0
+
+#define IEEE80211_FTYPE_MGMT		0x0000
+#define IEEE80211_FTYPE_CTL		0x0004
+#define IEEE80211_FTYPE_DATA		0x0008
+
+/* management */
+#define IEEE80211_STYPE_ASSOC_REQ	0x0000
+#define IEEE80211_STYPE_ASSOC_RESP	0x0010
+#define IEEE80211_STYPE_REASSOC_REQ	0x0020
+#define IEEE80211_STYPE_REASSOC_RESP	0x0030
+#define IEEE80211_STYPE_PROBE_REQ	0x0040
+#define IEEE80211_STYPE_PROBE_RESP	0x0050
+#define IEEE80211_STYPE_BEACON		0x0080
+#define IEEE80211_STYPE_ATIM		0x0090
+#define IEEE80211_STYPE_DISASSOC	0x00A0
+#define IEEE80211_STYPE_AUTH		0x00B0
+#define IEEE80211_STYPE_DEAUTH		0x00C0
+#define IEEE80211_STYPE_ACTION		0x00D0
+
+/* control */
+#define IEEE80211_STYPE_PSPOLL		0x00A0
+#define IEEE80211_STYPE_RTS		0x00B0
+#define IEEE80211_STYPE_CTS		0x00C0
+#define IEEE80211_STYPE_ACK		0x00D0
+#define IEEE80211_STYPE_CFEND		0x00E0
+#define IEEE80211_STYPE_CFENDACK	0x00F0
+
+/* data */
+#define IEEE80211_STYPE_DATA			0x0000
+#define IEEE80211_STYPE_DATA_CFACK		0x0010
+#define IEEE80211_STYPE_DATA_CFPOLL		0x0020
+#define IEEE80211_STYPE_DATA_CFACKPOLL		0x0030
+#define IEEE80211_STYPE_NULLFUNC		0x0040
+#define IEEE80211_STYPE_CFACK			0x0050
+#define IEEE80211_STYPE_CFPOLL			0x0060
+#define IEEE80211_STYPE_CFACKPOLL		0x0070
+#define IEEE80211_STYPE_QOS_DATA		0x0080
+#define IEEE80211_STYPE_QOS_DATA_CFACK		0x0090
+#define IEEE80211_STYPE_QOS_DATA_CFPOLL		0x00A0
+#define IEEE80211_STYPE_QOS_DATA_CFACKPOLL	0x00B0
+#define IEEE80211_STYPE_QOS_NULLFUNC		0x00C0
+#define IEEE80211_STYPE_QOS_CFACK		0x00D0
+#define IEEE80211_STYPE_QOS_CFPOLL		0x00E0
+#define IEEE80211_STYPE_QOS_CFACKPOLL		0x00F0
+
+
+/* miscellaneous IEEE 802.11 constants */
+#define IEEE80211_MAX_FRAG_THRESHOLD	2346
+#define IEEE80211_MAX_RTS_THRESHOLD	2347
+#define IEEE80211_MAX_AID		2007
+#define IEEE80211_MAX_TIM_LEN		251
+#define IEEE80211_MAX_DATA_LEN		2304
+/* Maximum size for the MA-UNITDATA primitive, 802.11 standard section
+   6.2.1.1.2.
+
+   The figure in section 7.1.2 suggests a body size of up to 2312
+   bytes is allowed, which is a bit confusing, I suspect this
+   represents the 2304 bytes of real data, plus a possible 8 bytes of
+   WEP IV and ICV. (this interpretation suggested by Ramiro Barreiro) */
+
+
+struct ieee80211_hdr {
+	__le16 frame_control;
+	__le16 duration_id;
+	__u8 addr1[6];
+	__u8 addr2[6];
+	__u8 addr3[6];
+	__le16 seq_ctrl;
+	__u8 addr4[6];
+} __attribute__ ((packed));
+
+#endif /* IEEE80211_H */
diff --git a/include/net/d80211.h b/include/net/d80211.h
index f7f6318..688c625 100644
--- a/include/net/d80211.h
+++ b/include/net/d80211.h
@@ -15,6 +15,7 @@ #include <linux/if_ether.h>
 #include <linux/skbuff.h>
 #include <linux/wireless.h>
 #include <linux/device.h>
+#include <linux/ieee80211.h>
 #include "d80211_shared.h"
 
 /* Note! Only ieee80211_tx_status_irqsafe() and ieee80211_rx_irqsafe() can be
@@ -935,95 +936,6 @@ enum {
 	IEEE80211_TEST_PARAM_TX_ANT_SEL_RAW = 5,
 };
 
-/* IEEE 802.11 defines */
-
-#define FCS_LEN 4
-
-#define IEEE80211_DATA_LEN              2304
-/* Maximum size for the MA-UNITDATA primitive, 802.11 standard section
-   6.2.1.1.2.
-
-   The figure in section 7.1.2 suggests a body size of up to 2312
-   bytes is allowed, which is a bit confusing, I suspect this
-   represents the 2304 bytes of real data, plus a possible 8 bytes of
-   WEP IV and ICV. (this interpretation suggested by Ramiro Barreiro) */
-
-#define IEEE80211_FCTL_VERS		0x0003
-#define IEEE80211_FCTL_FTYPE		0x000c
-#define IEEE80211_FCTL_STYPE		0x00f0
-#define IEEE80211_FCTL_TODS		0x0100
-#define IEEE80211_FCTL_FROMDS		0x0200
-#define IEEE80211_FCTL_MOREFRAGS	0x0400
-#define IEEE80211_FCTL_RETRY		0x0800
-#define IEEE80211_FCTL_PM		0x1000
-#define IEEE80211_FCTL_MOREDATA		0x2000
-#define IEEE80211_FCTL_PROTECTED	0x4000
-#define IEEE80211_FCTL_ORDER		0x8000
-
-#define IEEE80211_SCTL_FRAG		0x000F
-#define IEEE80211_SCTL_SEQ		0xFFF0
-
-#define IEEE80211_FTYPE_MGMT		0x0000
-#define IEEE80211_FTYPE_CTL		0x0004
-#define IEEE80211_FTYPE_DATA		0x0008
-
-/* management */
-#define IEEE80211_STYPE_ASSOC_REQ	0x0000
-#define IEEE80211_STYPE_ASSOC_RESP	0x0010
-#define IEEE80211_STYPE_REASSOC_REQ	0x0020
-#define IEEE80211_STYPE_REASSOC_RESP	0x0030
-#define IEEE80211_STYPE_PROBE_REQ	0x0040
-#define IEEE80211_STYPE_PROBE_RESP	0x0050
-#define IEEE80211_STYPE_BEACON		0x0080
-#define IEEE80211_STYPE_ATIM		0x0090
-#define IEEE80211_STYPE_DISASSOC	0x00A0
-#define IEEE80211_STYPE_AUTH		0x00B0
-#define IEEE80211_STYPE_DEAUTH		0x00C0
-#define IEEE80211_STYPE_ACTION		0x00D0
-
-/* control */
-#define IEEE80211_STYPE_PSPOLL		0x00A0
-#define IEEE80211_STYPE_RTS		0x00B0
-#define IEEE80211_STYPE_CTS		0x00C0
-#define IEEE80211_STYPE_ACK		0x00D0
-#define IEEE80211_STYPE_CFEND		0x00E0
-#define IEEE80211_STYPE_CFENDACK	0x00F0
-
-/* data */
-#define IEEE80211_STYPE_DATA			0x0000
-#define IEEE80211_STYPE_DATA_CFACK		0x0010
-#define IEEE80211_STYPE_DATA_CFPOLL		0x0020
-#define IEEE80211_STYPE_DATA_CFACKPOLL		0x0030
-#define IEEE80211_STYPE_NULLFUNC		0x0040
-#define IEEE80211_STYPE_CFACK			0x0050
-#define IEEE80211_STYPE_CFPOLL			0x0060
-#define IEEE80211_STYPE_CFACKPOLL		0x0070
-#define IEEE80211_STYPE_QOS_DATA		0x0080
-#define IEEE80211_STYPE_QOS_DATA_CFACK		0x0090
-#define IEEE80211_STYPE_QOS_DATA_CFPOLL		0x00A0
-#define IEEE80211_STYPE_QOS_DATA_CFACKPOLL	0x00B0
-#define IEEE80211_STYPE_QOS_NULLFUNC		0x00C0
-#define IEEE80211_STYPE_QOS_CFACK		0x00D0
-#define IEEE80211_STYPE_QOS_CFPOLL		0x00E0
-#define IEEE80211_STYPE_QOS_CFACKPOLL		0x00F0
-
-
-/* miscellaneous IEEE 802.11 constants */
-#define IEEE80211_MAX_FRAG_THRESHOLD 2346
-#define IEEE80211_MAX_RTS_THRESHOLD 2347
-#define IEEE80211_MAX_AID 2007
-#define IEEE80211_MAX_TIM_LEN 251
-
-struct ieee80211_hdr {
-	__le16 frame_control;
-	__le16 duration_id;
-	u8 addr1[6];
-	u8 addr2[6];
-	u8 addr3[6];
-	__le16 seq_ctrl;
-	u8 addr4[6];
-} __attribute__ ((packed));
-
 /* return a pointer to the source address (SA) */
 static inline u8 *ieee80211_get_SA(struct ieee80211_hdr *hdr)
 {
diff --git a/net/d80211/ieee80211.c b/net/d80211/ieee80211.c
index 9e7e1b3..4b2eebe 100644
--- a/net/d80211/ieee80211.c
+++ b/net/d80211/ieee80211.c
@@ -1939,7 +1939,7 @@ static int ieee80211_change_mtu(struct n
 {
 	/* FIX: what would be proper limits for MTU?
 	 * This interface uses 802.3 frames. */
-	if (new_mtu < 256 || new_mtu > IEEE80211_DATA_LEN - 24 - 6) {
+	if (new_mtu < 256 || new_mtu > IEEE80211_MAX_DATA_LEN - 24 - 6) {
 		printk(KERN_WARNING "%s: invalid MTU %d\n",
 		       dev->name, new_mtu);
 		return -EINVAL;
@@ -1957,7 +1957,7 @@ static int ieee80211_change_mtu_apdev(st
 {
 	/* FIX: what would be proper limits for MTU?
 	 * This interface uses 802.11 frames. */
-	if (new_mtu < 256 || new_mtu > IEEE80211_DATA_LEN) {
+	if (new_mtu < 256 || new_mtu > IEEE80211_MAX_DATA_LEN) {
 		printk(KERN_WARNING "%s: invalid MTU %d\n",
 		       dev->name, new_mtu);
 		return -EINVAL;
-- 
1.3.0

