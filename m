From: Florian Westphal <fw@strlen.de>
Subject: [PATCH RFC 09/14] net: wireless: mac80211: shrink private driver area
Date: Mon,  2 Mar 2015 18:40:23 +0100
Message-ID: <1425318028-26531-10-git-send-email-fw@strlen.de>
References: <1425318028-26531-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>, linux-wireless@vger.kernel.org
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:54117 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753962AbbCBRks (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2015 12:40:48 -0500
In-Reply-To: <1425318028-26531-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This makes the structure fit 44-byte sized skb->cb[].

Cc: linux-wireless@vger.kernel.org
Signed-off-by: Florian Westphal <fw@strlen.de>
---
 drivers/net/wireless/ath/ath9k/ath9k.h | 2 +-
 include/net/mac80211.h                 | 8 +++-----
 2 files changed, 4 insertions(+), 6 deletions(-)

diff --git a/drivers/net/wireless/ath/ath9k/ath9k.h b/drivers/net/wireless/ath/ath9k/ath9k.h
index 0f8e946..2ed77cf 100644
--- a/drivers/net/wireless/ath/ath9k/ath9k.h
+++ b/drivers/net/wireless/ath/ath9k/ath9k.h
@@ -184,12 +184,12 @@ struct ath_frame_info {
 	struct ath_buf *bf;
 	u16 framelen;
 	s8 txq;
-	enum ath9k_key_type keytype;
 	u8 keyix;
 	u8 rtscts_rate;
 	u8 retries : 7;
 	u8 baw_tracked : 1;
 	u8 tx_power;
+	enum ath9k_key_type keytype:2;
 };
 
 struct ath_rxbuf {
diff --git a/include/net/mac80211.h b/include/net/mac80211.h
index 36c2599..372c25a 100644
--- a/include/net/mac80211.h
+++ b/include/net/mac80211.h
@@ -627,11 +627,11 @@ enum mac80211_rate_control_flags {
 };
 
 
-/* there are 40 bytes if you don't need the rateset to be kept */
-#define IEEE80211_TX_INFO_DRIVER_DATA_SIZE 40
+/* there are 32 bytes if you don't need the rateset to be kept */
+#define IEEE80211_TX_INFO_DRIVER_DATA_SIZE 32
 
 /* if you do need the rateset, then you have less space */
-#define IEEE80211_TX_INFO_RATE_DRIVER_DATA_SIZE 24
+#define IEEE80211_TX_INFO_RATE_DRIVER_DATA_SIZE 16
 
 /* maximum number of rate stages */
 #define IEEE80211_TX_MAX_RATES	4
@@ -765,8 +765,6 @@ struct ieee80211_tx_info {
 		struct {
 			struct ieee80211_tx_rate driver_rates[
 				IEEE80211_TX_MAX_RATES];
-			u8 pad[4];
-
 			void *rate_driver_data[
 				IEEE80211_TX_INFO_RATE_DRIVER_DATA_SIZE / sizeof(void *)];
 		};
-- 
2.0.5
