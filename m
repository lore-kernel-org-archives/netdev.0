From: Gertjan van Wingerde <gwingerde@home.nl>
Subject: [PATCH 1/2] ieee80211: Update generic definitions to latest specs
 - take #2
Date: Fri, 03 Jun 2005 22:31:21 +0200
Message-ID: <42A0BE19.3060503@home.nl>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060209080801050100020902"
Cc: jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------060209080801050100020902
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi,

Attached patch updates the definitions of the generic ieee80211 stack to 
the latest versions of the published 802.11x specification suite.
Please review and apply.

Signed-off-by: Gertjan van Wingerde <gwingerde@home.nl>

Thanks,

Gertjan van Wingerde


--------------060209080801050100020902
Content-Type: text/plain;
 name="ieee80211-new-definitions.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="ieee80211-new-definitions.diff"

Index: include/net/ieee80211.h
===================================================================
--- 4b4ba76aa81b3627142787262fd2f8049dd3662d/include/net/ieee80211.h  (mode:100644)
+++ uncommitted/include/net/ieee80211.h  (mode:100644)
@@ -103,7 +103,7 @@
 #define	MAX_FRAG_THRESHOLD     2346U
 
 /* Frame control field constants */
-#define IEEE80211_FCTL_VERS		0x0002
+#define IEEE80211_FCTL_VERS		0x0003
 #define IEEE80211_FCTL_FTYPE		0x000c
 #define IEEE80211_FCTL_STYPE		0x00f0
 #define IEEE80211_FCTL_TODS		0x0100
@@ -111,8 +111,8 @@
 #define IEEE80211_FCTL_MOREFRAGS	0x0400
 #define IEEE80211_FCTL_RETRY		0x0800
 #define IEEE80211_FCTL_PM		0x1000
-#define IEEE80211_FCTL_MOREDATA	0x2000
-#define IEEE80211_FCTL_WEP		0x4000
+#define IEEE80211_FCTL_MOREDATA		0x2000
+#define IEEE80211_FCTL_PROTECTED	0x4000
 #define IEEE80211_FCTL_ORDER		0x8000
 
 #define IEEE80211_FTYPE_MGMT		0x0000
@@ -131,6 +131,7 @@
 #define IEEE80211_STYPE_DISASSOC	0x00A0
 #define IEEE80211_STYPE_AUTH		0x00B0
 #define IEEE80211_STYPE_DEAUTH		0x00C0
+#define IEEE80211_STYPE_ACTION		0x00D0
 
 /* control */
 #define IEEE80211_STYPE_PSPOLL		0x00A0
@@ -251,6 +252,7 @@
 
 #define SNAP_SIZE sizeof(struct ieee80211_snap_hdr)
 
+#define WLAN_FC_GET_VERS(fc) ((fc) & IEEE80211_FCTL_VERS)
 #define WLAN_FC_GET_TYPE(fc) ((fc) & IEEE80211_FCTL_FTYPE)
 #define WLAN_FC_GET_STYPE(fc) ((fc) & IEEE80211_FCTL_STYPE)
 
@@ -271,6 +273,9 @@
 #define WLAN_CAPABILITY_SHORT_PREAMBLE (1<<5)
 #define WLAN_CAPABILITY_PBCC (1<<6)
 #define WLAN_CAPABILITY_CHANNEL_AGILITY (1<<7)
+#define WLAN_CAPABILITY_SPECTRUM_MGMT (1<<8)
+#define WLAN_CAPABILITY_SHORT_SLOT_TIME (1<<10)
+#define WLAN_CAPABILITY_OSSS_OFDM (1<<13)
 
 /* Status codes */
 #define WLAN_STATUS_SUCCESS 0
@@ -285,9 +290,24 @@
 #define WLAN_STATUS_AP_UNABLE_TO_HANDLE_NEW_STA 17
 #define WLAN_STATUS_ASSOC_DENIED_RATES 18
 /* 802.11b */
-#define WLAN_STATUS_ASSOC_DENIED_NOSHORT 19
+#define WLAN_STATUS_ASSOC_DENIED_NOSHORTPREAMBLE 19
 #define WLAN_STATUS_ASSOC_DENIED_NOPBCC 20
 #define WLAN_STATUS_ASSOC_DENIED_NOAGILITY 21
+/* 802.11h */
+#define WLAN_STATUS_ASSOC_DENIED_NOSPECTRUM 22
+#define WLAN_STATUS_ASSOC_REJECTED_BAD_POWER 23
+#define WLAN_STATUS_ASSOC_REJECTED_BAD_SUPP_CHAN 24
+/* 802.11g */
+#define WLAN_STATUS_ASSOC_DENIED_NOSHORTTIME 25
+#define WLAN_STATUS_ASSOC_DENIED_NODSSSOFDM 26
+/* 802.11i */
+#define WLAN_STATUS_INVALID_IE 40
+#define WLAN_STATUS_INVALID_GROUP_CIPHER 41
+#define WLAN_STATUS_INVALID_PAIRWISE_CIPHER 42
+#define WLAN_STATUS_INVALID_AKMP 43
+#define WLAN_STATUS_UNSUPP_RSN_VERSION 44
+#define WLAN_STATUS_INVALID_RSN_IE_CAP 45
+#define WLAN_STATUS_CIPHER_SUITE_REJECTED 46
 
 /* Reason codes */
 #define WLAN_REASON_UNSPECIFIED 1
@@ -299,6 +319,22 @@
 #define WLAN_REASON_CLASS3_FRAME_FROM_NONASSOC_STA 7
 #define WLAN_REASON_DISASSOC_STA_HAS_LEFT 8
 #define WLAN_REASON_STA_REQ_ASSOC_WITHOUT_AUTH 9
+/* 802.11h */
+#define WLAN_REASON_DISASSOC_BAD_POWER 10
+#define WLAN_REASON_DISASSOC_BAD_SUPP_CHAN 11
+/* 802.11i */
+#define WLAN_REASON_INVALID_IE 13
+#define WLAN_REASON_MIC_FAILURE 14
+#define WLAN_REASON_4WAY_HANDSHAKE_TIMEOUT 15
+#define WLAN_REASON_GROUP_KEY_HANDSHAKE_TIMEOUT 16
+#define WLAN_REASON_IE_DIFFERENT 17
+#define WLAN_REASON_INVALID_GROUP_CIPHER 18
+#define WLAN_REASON_INVALID_PAIRWISE_CIPHER 19
+#define WLAN_REASON_INVALID_AKMP 20
+#define WLAN_REASON_UNSUPP_RSN_VERSION 21
+#define WLAN_REASON_INVALID_RSN_IE_CAP 22
+#define WLAN_REASON_IEEE8021X_FAILED 23
+#define WLAN_REASON_CIPHER_SUITE_REJECTED 24
 
 
 #define IEEE80211_STATMASK_SIGNAL (1<<0)
@@ -477,17 +513,32 @@
 #define BEACON_PROBE_SSID_ID_POSITION 12
 
 /* Management Frame Information Element Types */
-#define MFIE_TYPE_SSID       0
-#define MFIE_TYPE_RATES      1
-#define MFIE_TYPE_FH_SET     2
-#define MFIE_TYPE_DS_SET     3
-#define MFIE_TYPE_CF_SET     4
-#define MFIE_TYPE_TIM        5
-#define MFIE_TYPE_IBSS_SET   6
-#define MFIE_TYPE_CHALLENGE  16
-#define MFIE_TYPE_RSN	     48
-#define MFIE_TYPE_RATES_EX   50
-#define MFIE_TYPE_GENERIC    221
+#define MFIE_TYPE_SSID              0
+#define MFIE_TYPE_RATES             1
+#define MFIE_TYPE_FH_SET            2
+#define MFIE_TYPE_DS_SET            3
+#define MFIE_TYPE_CF_SET            4
+#define MFIE_TYPE_TIM               5
+#define MFIE_TYPE_IBSS_SET          6
+#define MFIE_TYPE_COUNTRY           7
+#define MFIE_TYPE_HOP_PARAMS        8
+#define MFIE_TYPE_HOP_TABLE         9
+#define MFIE_TYPE_REQUEST           10
+#define MFIE_TYPE_CHALLENGE         16
+#define MFIE_TYPE_POWER_CONSTRAINT  32
+#define MFIE_TYPE_POWER_CAPABILITY  33
+#define MFIE_TYPE_TPC_REQUEST       34
+#define MFIE_TYPE_TPC_REPORT        35
+#define MFIE_TYPE_SUPP_CHANNELS     36
+#define MFIE_TYPE_CSA               37
+#define MFIE_TYPE_MEASURE_REQUEST   38
+#define MFIE_TYPE_MEASURE_REPORT    39
+#define MFIE_TYPE_QUIET             40
+#define MFIE_TYPE_IBSS_DFS          41
+#define MFIE_TYPE_ERP_INFO          42
+#define MFIE_TYPE_RSN	            48
+#define MFIE_TYPE_RATES_EX          50
+#define MFIE_TYPE_GENERIC           221
 
 struct ieee80211_info_element_hdr {
 	u8 id;
Index: net/ieee80211/ieee80211_rx.c
===================================================================
--- 4b4ba76aa81b3627142787262fd2f8049dd3662d/net/ieee80211/ieee80211_rx.c  (mode:100644)
+++ uncommitted/net/ieee80211/ieee80211_rx.c  (mode:100644)
@@ -440,7 +440,7 @@
 			      crypt->ops->decrypt_mpdu == NULL))
 			crypt = NULL;
 
-		if (!crypt && (fc & IEEE80211_FCTL_WEP)) {
+		if (!crypt && (fc & IEEE80211_FCTL_PROTECTED)) {
 			/* This seems to be triggered by some (multicast?)
 			 * frames from other than current BSS, so just drop the
 			 * frames silently instead of filling system log with
@@ -456,7 +456,7 @@
 #ifdef NOT_YET
 	if (type != WLAN_FC_TYPE_DATA) {
 		if (type == WLAN_FC_TYPE_MGMT && stype == WLAN_FC_STYPE_AUTH &&
-		    fc & IEEE80211_FCTL_WEP && ieee->host_decrypt &&
+		    fc & IEEE80211_FCTL_PROTECTED && ieee->host_decrypt &&
 		    (keyidx = hostap_rx_frame_decrypt(ieee, skb, crypt)) < 0)
 		{
 			printk(KERN_DEBUG "%s: failed to decrypt mgmt::auth "
@@ -557,7 +557,7 @@
 
 	/* skb: hdr + (possibly fragmented, possibly encrypted) payload */
 
-	if (ieee->host_decrypt && (fc & IEEE80211_FCTL_WEP) &&
+	if (ieee->host_decrypt && (fc & IEEE80211_FCTL_PROTECTED) &&
 	    (keyidx = ieee80211_rx_frame_decrypt(ieee, skb, crypt)) < 0)
 		goto rx_dropped;
 
@@ -565,7 +565,7 @@
 
 	/* skb: hdr + (possibly fragmented) plaintext payload */
 	// PR: FIXME: hostap has additional conditions in the "if" below:
-	// ieee->host_decrypt && (fc & IEEE80211_FCTL_WEP) &&
+	// ieee->host_decrypt && (fc & IEEE80211_FCTL_PROTECTED) &&
 	if ((frag != 0 || (fc & IEEE80211_FCTL_MOREFRAGS))) {
 		int flen;
 		struct sk_buff *frag_skb = ieee80211_frag_cache_get(ieee, hdr);
@@ -621,12 +621,12 @@
 
 	/* skb: hdr + (possible reassembled) full MSDU payload; possibly still
 	 * encrypted/authenticated */
-	if (ieee->host_decrypt && (fc & IEEE80211_FCTL_WEP) &&
+	if (ieee->host_decrypt && (fc & IEEE80211_FCTL_PROTECTED) &&
 	    ieee80211_rx_frame_decrypt_msdu(ieee, skb, keyidx, crypt))
 		goto rx_dropped;
 
 	hdr = (struct ieee80211_hdr *) skb->data;
-	if (crypt && !(fc & IEEE80211_FCTL_WEP) && !ieee->open_wep) {
+	if (crypt && !(fc & IEEE80211_FCTL_PROTECTED) && !ieee->open_wep) {
 		if (/*ieee->ieee802_1x &&*/
 		    ieee80211_is_eapol_frame(ieee, skb)) {
 #ifdef CONFIG_IEEE80211_DEBUG
@@ -647,7 +647,7 @@
 	}
 
 #ifdef CONFIG_IEEE80211_DEBUG
-	if (crypt && !(fc & IEEE80211_FCTL_WEP) &&
+	if (crypt && !(fc & IEEE80211_FCTL_PROTECTED) &&
 	    ieee80211_is_eapol_frame(ieee, skb)) {
 			struct eapol *eap = (struct eapol *)(skb->data +
 				24);
@@ -656,7 +656,7 @@
 	}
 #endif
 
-	if (crypt && !(fc & IEEE80211_FCTL_WEP) && !ieee->open_wep &&
+	if (crypt && !(fc & IEEE80211_FCTL_PROTECTED) && !ieee->open_wep &&
 	    !ieee80211_is_eapol_frame(ieee, skb)) {
 		IEEE80211_DEBUG_DROP(
 			"dropped unencrypted RX data "
Index: net/ieee80211/ieee80211_tx.c
===================================================================
--- 4b4ba76aa81b3627142787262fd2f8049dd3662d/net/ieee80211/ieee80211_tx.c  (mode:100644)
+++ uncommitted/net/ieee80211/ieee80211_tx.c  (mode:100644)
@@ -314,7 +314,7 @@
 
 	if (encrypt)
 		fc = IEEE80211_FTYPE_DATA | IEEE80211_STYPE_DATA |
-			IEEE80211_FCTL_WEP;
+			IEEE80211_FCTL_PROTECTED;
 	else
 		fc = IEEE80211_FTYPE_DATA | IEEE80211_STYPE_DATA;
 
Index: drivers/net/wireless/atmel.c
===================================================================
--- 4b4ba76aa81b3627142787262fd2f8049dd3662d/drivers/net/wireless/atmel.c  (mode:100644)
+++ uncommitted/drivers/net/wireless/atmel.c  (mode:100644)
@@ -867,7 +867,7 @@
 	header.duration_id = 0;
 	header.seq_ctl = 0;
 	if (priv->wep_is_on)
-		frame_ctl |= IEEE80211_FCTL_WEP;
+		frame_ctl |= IEEE80211_FCTL_PROTECTED;
 	if (priv->operating_mode == IW_MODE_ADHOC) {
 		memcpy(&header.addr1, skb->data, 6);
 		memcpy(&header.addr2, dev->dev_addr, 6);
@@ -1117,7 +1117,7 @@
 		/* probe for CRC use here if needed  once five packets have arrived with
 		   the same crc status, we assume we know what's happening and stop probing */
 		if (priv->probe_crc) {
-			if (!priv->wep_is_on || !(frame_ctl & IEEE80211_FCTL_WEP)) {
+			if (!priv->wep_is_on || !(frame_ctl & IEEE80211_FCTL_PROTECTED)) {
 				priv->do_rx_crc = probe_crc(priv, rx_packet_loc, msdu_size);
 			} else {
 				priv->do_rx_crc = probe_crc(priv, rx_packet_loc + 24, msdu_size - 24);
@@ -1132,7 +1132,7 @@
 		}
 		    
 		/* don't CRC header when WEP in use */
-		if (priv->do_rx_crc && (!priv->wep_is_on || !(frame_ctl & IEEE80211_FCTL_WEP))) {
+		if (priv->do_rx_crc && (!priv->wep_is_on || !(frame_ctl & IEEE80211_FCTL_PROTECTED))) {
 			crc = crc32_le(0xffffffff, (unsigned char *)&header, 24);
 		}
 		msdu_size -= 24; /* header */
@@ -2677,7 +2677,7 @@
 		auth.alg = cpu_to_le16(C80211_MGMT_AAN_SHAREDKEY); 
 		/* no WEP for authentication frames with TrSeqNo 1 */
 		if (priv->CurrentAuthentTransactionSeqNum != 1)
-			header.frame_ctl |=  cpu_to_le16(IEEE80211_FCTL_WEP); 
+			header.frame_ctl |=  cpu_to_le16(IEEE80211_FCTL_PROTECTED); 
 	} else {
 		auth.alg = cpu_to_le16(C80211_MGMT_AAN_OPENSYSTEM);
 	}

--------------060209080801050100020902--
