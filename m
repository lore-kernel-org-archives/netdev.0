From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 1/3 3.18] rtlwifi: Fix setting of tx descriptor for new trx flow
Date: Wed,  5 Nov 2014 19:10:52 -0600
Message-ID: <1415236254-12274-2-git-send-email-Larry.Finger@lwfinger.net>
References: <1415236254-12274-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f181.google.com ([209.85.214.181]:54243 "EHLO
	mail-ob0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750990AbaKFBLT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2014 20:11:19 -0500
In-Reply-To: <1415236254-12274-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Device RTL8192EE uses a new form of trx flow. This fix sets up the descriptors
correctly.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/net/wireless/rtlwifi/pci.c | 11 ++++++++---
 1 file changed, 8 insertions(+), 3 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/pci.c b/drivers/net/wireless/rtlwifi/pci.c
index 25daa87..116f746 100644
--- a/drivers/net/wireless/rtlwifi/pci.c
+++ b/drivers/net/wireless/rtlwifi/pci.c
@@ -1127,9 +1127,14 @@ static void _rtl_pci_prepare_bcn_tasklet(struct ieee80211_hw *hw)
 
 	__skb_queue_tail(&ring->queue, pskb);
 
-	rtlpriv->cfg->ops->set_desc(hw, (u8 *)pdesc, true, HW_DESC_OWN,
-				    &temp_one);
-
+	if (rtlpriv->use_new_trx_flow) {
+		temp_one = 4;
+		rtlpriv->cfg->ops->set_desc(hw, (u8 *)pbuffer_desc, true,
+					    HW_DESC_OWN, (u8 *)&temp_one);
+	} else {
+		rtlpriv->cfg->ops->set_desc(hw, (u8 *)pdesc, true, HW_DESC_OWN,
+					    &temp_one);
+	}
 	return;
 }
 
-- 
2.1.2
