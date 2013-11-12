From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH] rtlwifi: Remove unused calls to rtl_is_special_data()
Date: Tue, 12 Nov 2013 11:02:20 -0600
Message-ID: <1384275740-10388-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org, mark.cave-ayland@ilande.co.uk
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f48.google.com ([209.85.219.48]:35872 "EHLO
	mail-oa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753327Ab3KLRCq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Nov 2013 12:02:46 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When routine rtl_is_special_data() is called with false as its last argument,
and the returned value is not tested, the call is essentially an extended
no-op. Accordingly, these calls may be removed.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
Reported-by: Mark Cave-Ayland <mark.cave-ayland@ilande.co.uk>
---
 drivers/net/wireless/rtlwifi/pci.c | 2 --
 drivers/net/wireless/rtlwifi/usb.c | 4 ----
 2 files changed, 6 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/pci.c b/drivers/net/wireless/rtlwifi/pci.c
index 0f49444..8707d1a 100644
--- a/drivers/net/wireless/rtlwifi/pci.c
+++ b/drivers/net/wireless/rtlwifi/pci.c
@@ -688,8 +688,6 @@ static void _rtl_receive_one(struct ieee80211_hw *hw, struct sk_buff *skb,
 		rtlpriv->stats.rxbytesunicast += skb->len;
 	}
 
-	rtl_is_special_data(hw, skb, false);
-
 	if (ieee80211_is_data(fc)) {
 		rtlpriv->cfg->ops->led_control(hw, LED_CTL_RX);
 
diff --git a/drivers/net/wireless/rtlwifi/usb.c b/drivers/net/wireless/rtlwifi/usb.c
index 6e2b5c5..ec385e4 100644
--- a/drivers/net/wireless/rtlwifi/usb.c
+++ b/drivers/net/wireless/rtlwifi/usb.c
@@ -475,8 +475,6 @@ static void _rtl_usb_rx_process_agg(struct ieee80211_hw *hw,
 			rtlpriv->stats.rxbytesunicast +=  skb->len;
 		}
 
-		rtl_is_special_data(hw, skb, false);
-
 		if (ieee80211_is_data(fc)) {
 			rtlpriv->cfg->ops->led_control(hw, LED_CTL_RX);
 
@@ -517,8 +515,6 @@ static void _rtl_usb_rx_process_noagg(struct ieee80211_hw *hw,
 			rtlpriv->stats.rxbytesunicast +=  skb->len;
 		}
 
-		rtl_is_special_data(hw, skb, false);
-
 		if (ieee80211_is_data(fc)) {
 			rtlpriv->cfg->ops->led_control(hw, LED_CTL_RX);
 
-- 
1.8.4
