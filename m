From: Bjorn Andersson <bjorn.andersson@linaro.org>
Subject: [PATCH v3 12/18] wcn36xx: Clear encrypt_type when deleting bss key
Date: Mon, 18 Apr 2016 22:00:50 -0700
Message-ID: <1461042056-10607-13-git-send-email-bjorn.andersson@linaro.org>
References: <1461042056-10607-1-git-send-email-bjorn.andersson@linaro.org>
Cc: Pontus Fuchs <pontus.fuchs@gmail.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Eugene Krasnikov <k.eugene.e@gmail.com>,
	Kalle Valo <kvalo@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:35004 "EHLO
	mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752567AbcDSFBY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Apr 2016 01:01:24 -0400
Received: by mail-pf0-f181.google.com with SMTP id n1so2718430pfn.2
        for <netdev@vger.kernel.org>; Mon, 18 Apr 2016 22:01:18 -0700 (PDT)
In-Reply-To: <1461042056-10607-1-git-send-email-bjorn.andersson@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pontus Fuchs <pontus.fuchs@gmail.com>

This fixes a problem connecting to an open network after being
connected to an encrypted network.

Signed-off-by: Pontus Fuchs <pontus.fuchs@gmail.com>
Signed-off-by: Bjorn Andersson <bjorn.andersson@linaro.org>
---
 drivers/net/wireless/ath/wcn36xx/main.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/wireless/ath/wcn36xx/main.c b/drivers/net/wireless/ath/wcn36xx/main.c
index 7c06ca9fdd2c..f9c77de94583 100644
--- a/drivers/net/wireless/ath/wcn36xx/main.c
+++ b/drivers/net/wireless/ath/wcn36xx/main.c
@@ -471,6 +471,7 @@ static int wcn36xx_set_key(struct ieee80211_hw *hw, enum set_key_cmd cmd,
 		break;
 	case DISABLE_KEY:
 		if (!(IEEE80211_KEY_FLAG_PAIRWISE & key_conf->flags)) {
+			vif_priv->encrypt_type = WCN36XX_HAL_ED_NONE;
 			wcn36xx_smd_remove_bsskey(wcn,
 				vif_priv->encrypt_type,
 				key_conf->keyidx);
@@ -626,6 +627,7 @@ static void wcn36xx_bss_info_changed(struct ieee80211_hw *hw,
 		} else {
 			vif_priv->is_joining = false;
 			wcn36xx_smd_delete_bss(wcn, vif);
+			vif_priv->encrypt_type = WCN36XX_HAL_ED_NONE;
 		}
 	}
 
-- 
2.5.0
