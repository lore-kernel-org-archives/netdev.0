From: Hans de Goede <hdegoede@redhat.com>
Subject: [PATCH] net: wireless: rtl8xxxu: Make rtl8xxxu_ampdu_action less chatty
Date: Thu, 18 Aug 2016 19:52:47 +0200
Message-ID: <1471542767-2877-1-git-send-email-hdegoede@redhat.com>
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	Hans de Goede <hdegoede@redhat.com>
To: Jes Sorensen <Jes.Sorensen@redhat.com>,
	Kalle Valo <kvalo@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44692 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752848AbcHRTKS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Aug 2016 15:10:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On my home network rtl8xxxu is spamming the log with
IEEE80211_AMPDU_RX_START / IEEE80211_AMPDU_RX_STOP every few seconds
turn these messages into debug messages.

Signed-off-by: Hans de Goede <hdegoede@redhat.com>
---
 drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu_core.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu_core.c b/drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu_core.c
index 77048db..28b5ac95 100644
--- a/drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu_core.c
+++ b/drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu_core.c
@@ -5704,7 +5704,7 @@ rtl8xxxu_ampdu_action(struct ieee80211_hw *hw, struct ieee80211_vif *vif,
 
 	switch (action) {
 	case IEEE80211_AMPDU_TX_START:
-		dev_info(dev, "%s: IEEE80211_AMPDU_TX_START\n", __func__);
+		dev_dbg(dev, "%s: IEEE80211_AMPDU_TX_START\n", __func__);
 		ampdu_factor = sta->ht_cap.ampdu_factor;
 		ampdu_density = sta->ht_cap.ampdu_density;
 		rtl8xxxu_set_ampdu_factor(priv, ampdu_factor);
@@ -5714,21 +5714,21 @@ rtl8xxxu_ampdu_action(struct ieee80211_hw *hw, struct ieee80211_vif *vif,
 			ampdu_factor, ampdu_density);
 		break;
 	case IEEE80211_AMPDU_TX_STOP_FLUSH:
-		dev_info(dev, "%s: IEEE80211_AMPDU_TX_STOP_FLUSH\n", __func__);
+		dev_dbg(dev, "%s: IEEE80211_AMPDU_TX_STOP_FLUSH\n", __func__);
 		rtl8xxxu_set_ampdu_factor(priv, 0);
 		rtl8xxxu_set_ampdu_min_space(priv, 0);
 		break;
 	case IEEE80211_AMPDU_TX_STOP_FLUSH_CONT:
-		dev_info(dev, "%s: IEEE80211_AMPDU_TX_STOP_FLUSH_CONT\n",
+		dev_dbg(dev, "%s: IEEE80211_AMPDU_TX_STOP_FLUSH_CONT\n",
 			 __func__);
 		rtl8xxxu_set_ampdu_factor(priv, 0);
 		rtl8xxxu_set_ampdu_min_space(priv, 0);
 		break;
 	case IEEE80211_AMPDU_RX_START:
-		dev_info(dev, "%s: IEEE80211_AMPDU_RX_START\n", __func__);
+		dev_dbg(dev, "%s: IEEE80211_AMPDU_RX_START\n", __func__);
 		break;
 	case IEEE80211_AMPDU_RX_STOP:
-		dev_info(dev, "%s: IEEE80211_AMPDU_RX_STOP\n", __func__);
+		dev_dbg(dev, "%s: IEEE80211_AMPDU_RX_STOP\n", __func__);
 		break;
 	default:
 		break;
-- 
2.7.4
