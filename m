From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH 16/18] d80211:  get rid of MICHAEL_MIC_HWACCEL define
Date: Mon, 21 Aug 2006 09:41:23 +0200
Message-ID: <20060821075202.538664376@sipsolutions.net>
References: <20060821074107.648561364@sipsolutions.net>
Mime-Version: 1.0
Cc: Jouni Malinen <jkm@devicescape.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Jiri Benc <jbenc@suse.cz>,
	Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:64448 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1030357AbWHUICW
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Aug 2006 04:02:22 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline; filename=d80211-michael-mic-define.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The symbol MICHAEL_MIC_HWACCEL is always defined and hence
all the ifdefs using it are useless. This patch removes it.

Signed-off-by: Johannes Berg <johannes@sipsolutions.net>

--- wireless-dev.orig/net/d80211/wpa.c	2006-08-20 17:32:40.058192788 +0200
+++ wireless-dev/net/d80211/wpa.c	2006-08-20 17:33:52.968192788 +0200
@@ -25,9 +25,6 @@
 #endif /* CONFIG_HOSTAPD_WPA_TESTING */
 
 
-#define MICHAEL_MIC_HWACCEL
-
-
 int ieee80211_get_hdr_info(const struct sk_buff *skb, u8 **sa, u8 **da,
 			   u8 *qos_tid, u8 **data, size_t *data_len)
 {
@@ -87,9 +84,7 @@ ieee80211_tx_h_michael_mic_add(struct ie
 	u16 fc;
 	struct sk_buff *skb = tx->skb;
 	int authenticator;
-#if defined(CONFIG_HOSTAPD_WPA_TESTING) || defined(MICHAEL_MIC_HWACCEL)
 	int wpa_test = 0;
-#endif
 
 	fc = tx->fc;
 
@@ -108,14 +103,12 @@ ieee80211_tx_h_michael_mic_add(struct ie
 	}
 #endif /* CONFIG_HOSTAPD_WPA_TESTING */
 
-#ifdef MICHAEL_MIC_HWACCEL
 	if (!tx->key->force_sw_encrypt && !tx->local->conf.sw_decrypt &&
 	    !tx->fragmented && !wpa_test) {
 		/* hwaccel - with no need for preallocated room for Michael MIC
 		 */
 		return TXRX_CONTINUE;
 	}
-#endif /* MICHAEL_MIC_HWACCEL */
 
 	if (skb_tailroom(skb) < MICHAEL_MIC_LEN) {
 		I802_DEBUG_INC(tx->local->tx_expand_skb_head);
@@ -188,7 +181,6 @@ ieee80211_rx_h_michael_mic_verify(struct
 		wpa_test = 1;
 #endif /* CONFIG_HOSTAPD_WPA_TESTING */
 
-#ifdef MICHAEL_MIC_HWACCEL
 	if ((rx->u.rx.status->flag & RX_FLAG_DECRYPTED) &&
 	    !rx->key->force_sw_encrypt && !rx->local->conf.sw_decrypt) {
 		if (rx->local->hw->wep_include_iv) {
@@ -201,7 +193,6 @@ ieee80211_rx_h_michael_mic_verify(struct
 		if (!rx->fragmented && !wpa_test)
 			goto remove_mic;
 	}
-#endif /* MICHAEL_MIC_HWACCEL */
 
 	if (ieee80211_get_hdr_info(skb, &sa, &da, &qos_tid, &data, &data_len)
 	    || data_len < MICHAEL_MIC_LEN)
@@ -277,9 +268,7 @@ ieee80211_rx_h_michael_mic_verify(struct
 		return TXRX_QUEUED;
 	}
 
-#ifdef MICHAEL_MIC_HWACCEL
  remove_mic:
-#endif /* MICHAEL_MIC_HWACCEL */
 	/* remove Michael MIC from payload */
 	skb_trim(skb, skb->len - MICHAEL_MIC_LEN);
 

--
