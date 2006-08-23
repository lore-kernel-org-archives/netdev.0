From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 12/21] d80211: get rid of MICHAEL_MIC_HWACCEL define
Date: Wed, 23 Aug 2006 21:24:21 +0200 (CEST)
Message-ID: <20060823192421.3FF8F483AE@silver.suse.cz>
References: <20060823212316.333159079.midnight@suse.cz>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:29648 "EHLO silver.suse.cz")
	by vger.kernel.org with ESMTP id S965119AbWHWTYV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2006 15:24:21 -0400
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20060823212316.333159079.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Johannes Berg <johannes@sipsolutions.net>

The symbol MICHAEL_MIC_HWACCEL is always defined and hence
all the ifdefs using it are useless. This patch removes it.

Signed-off-by: Johannes Berg <johannes@sipsolutions.net>
Signed-off-by: Jiri Benc <jbenc@suse.cz>

---

 net/d80211/wpa.c |   11 -----------
 1 files changed, 0 insertions(+), 11 deletions(-)

0c2bf906ecdf3c6fda21aa83afb07f015dd7ec20
diff --git a/net/d80211/wpa.c b/net/d80211/wpa.c
index 412b4a6..31abf9b 100644
--- a/net/d80211/wpa.c
+++ b/net/d80211/wpa.c
@@ -25,9 +25,6 @@ #include "hostapd_ioctl.h"
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
 
@@ -108,14 +103,12 @@ #ifdef CONFIG_HOSTAPD_WPA_TESTING
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
@@ -189,7 +182,6 @@ #ifdef CONFIG_HOSTAPD_WPA_TESTING
 	}
 #endif /* CONFIG_HOSTAPD_WPA_TESTING */
 
-#ifdef MICHAEL_MIC_HWACCEL
 	if ((rx->u.rx.status->flag & RX_FLAG_DECRYPTED) &&
 	    !rx->key->force_sw_encrypt && !rx->local->conf.sw_decrypt) {
 		if (rx->local->hw->wep_include_iv) {
@@ -202,7 +194,6 @@ #ifdef MICHAEL_MIC_HWACCEL
 		if (!rx->fragmented && !wpa_test)
 			goto remove_mic;
 	}
-#endif /* MICHAEL_MIC_HWACCEL */
 
 	if (ieee80211_get_hdr_info(skb, &sa, &da, &qos_tid, &data, &data_len)
 	    || data_len < MICHAEL_MIC_LEN)
@@ -278,9 +269,7 @@ #endif /* CONFIG_HOSTAPD_WPA_TESTING */
 		return TXRX_QUEUED;
 	}
 
-#ifdef MICHAEL_MIC_HWACCEL
  remove_mic:
-#endif /* MICHAEL_MIC_HWACCEL */
 	/* remove Michael MIC from payload */
 	skb_trim(skb, skb->len - MICHAEL_MIC_LEN);
 
-- 
1.3.0

