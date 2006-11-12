From: David Kimdon <david.kimdon@devicescape.com>
Subject: [patch] d80211: endian annotations for ieee80211_frame_info, etc.
Date: Sun, 12 Nov 2006 10:11:01 -0800
Message-ID: <20061112181101.GA13434@devicescape.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Jiri Benc <jbenc@suse.cz>,
	David Kimdon <david.kimdon@devicescape.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.devicescape.com ([207.138.119.2]:5594 "EHLO
	mail.devicescape.com") by vger.kernel.org with ESMTP
	id S1751907AbWKLSLC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 12 Nov 2006 13:11:02 -0500
To: netdev@vger.kernel.org
Content-Disposition: inline; filename="endian-annotate.patch"
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thanks to sparse for pointing out these missing endian annotations.

All the fields in the AVS capture header (struct ieee80211_frame_info) are in
network byte order.

The length in the ethernet header is in network byte order.

last_seq_ctrl is stored little endian.

Signed-off-by: David Kimdon <david.kimdon@devicescape.com>

Index: wireless-dev/include/net/d80211_common.h
===================================================================
--- wireless-dev.orig/include/net/d80211_common.h	2006-11-05 14:54:08.240747720 -0800
+++ wireless-dev/include/net/d80211_common.h	2006-11-05 14:56:45.225882352 -0800
@@ -20,26 +20,26 @@
 #define IEEE80211_FI_VERSION 0x80211001
 
 struct ieee80211_frame_info {
-        u32 version;
-        u32 length;
-        u64 mactime;
-        u64 hosttime;
-        u32 phytype;
-        u32 channel;
-        u32 datarate;
-        u32 antenna;
-        u32 priority;
-        u32 ssi_type;
-        u32 ssi_signal;
-        u32 ssi_noise;
-        u32 preamble;
-        u32 encoding;
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
 
 	/* Note: this structure is otherwise identical to capture format used
 	 * in linux-wlan-ng, but this additional field is used to provide meta
 	 * data about the frame to hostapd. This was the easiest method for
 	 * providing this information, but this might change in the future. */
-	u32 msg_type;
+	__be32 msg_type;
 } __attribute__ ((packed));
 
 
Index: wireless-dev/net/d80211/ieee80211.c
===================================================================
--- wireless-dev.orig/net/d80211/ieee80211.c	2006-11-05 14:48:09.808237744 -0800
+++ wireless-dev/net/d80211/ieee80211.c	2006-11-05 15:01:29.594651728 -0800
@@ -2427,7 +2427,7 @@
 		memcpy(skb_push(skb, ETH_ALEN), dst, ETH_ALEN);
 	} else {
 		struct ethhdr *ehdr;
-                unsigned short len;
+		__be16 len;
 		skb_pull(skb, hdrlen);
 		len = htons(skb->len);
 		ehdr = (struct ethhdr *) skb_push(skb, sizeof(struct ethhdr));
Index: wireless-dev/net/d80211/ieee80211_ioctl.c
===================================================================
--- wireless-dev.orig/net/d80211/ieee80211_ioctl.c	2006-11-05 14:48:09.816236528 -0800
+++ wireless-dev/net/d80211/ieee80211_ioctl.c	2006-11-05 14:56:45.228881896 -0800
@@ -218,7 +218,7 @@
 struct iapp_layer2_update {
 	u8 da[ETH_ALEN]; /* broadcast */
 	u8 sa[ETH_ALEN]; /* STA addr */
-	u16 len; /* 6 */
+	__be16 len; /* 6 */
 	u8 dsap; /* 0 */
 	u8 ssap; /* 0 */
 	u8 control;
Index: wireless-dev/net/d80211/sta_info.h
===================================================================
--- wireless-dev.orig/net/d80211/sta_info.h	2006-11-05 14:48:09.823235464 -0800
+++ wireless-dev/net/d80211/sta_info.h	2006-11-05 14:56:45.229881744 -0800
@@ -74,7 +74,7 @@
 	void *rate_ctrl_priv;
 
 	/* last received seq/frag number from this STA (per RX queue) */
-	u16 last_seq_ctrl[NUM_RX_DATA_QUEUES];
+	__le16 last_seq_ctrl[NUM_RX_DATA_QUEUES];
 	unsigned long num_duplicates; /* number of duplicate frames received
 				       * from this STA */
 	unsigned long tx_fragments; /* number of transmitted MPDUs */

--
