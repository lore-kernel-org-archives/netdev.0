From: Bjorn Andersson <bjorn.andersson@linaro.org>
Subject: [PATCH v3 16/18] wcn36xx: Delete BSS before idling link
Date: Mon, 18 Apr 2016 22:00:54 -0700
Message-ID: <1461042056-10607-17-git-send-email-bjorn.andersson@linaro.org>
References: <1461042056-10607-1-git-send-email-bjorn.andersson@linaro.org>
Cc: Pontus Fuchs <pontus.fuchs@gmail.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Eugene Krasnikov <k.eugene.e@gmail.com>,
	Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1461042056-10607-1-git-send-email-bjorn.andersson@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When disabling the beacon we must delete the bss before idling the link.

Signed-off-by: Bjorn Andersson <bjorn.andersson@linaro.org>
---

Changes since v2:
- Added this patch to the series

 drivers/net/wireless/ath/wcn36xx/main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/ath/wcn36xx/main.c b/drivers/net/wireless/ath/wcn36xx/main.c
index c0ba7b0775b3..680217506b3d 100644
--- a/drivers/net/wireless/ath/wcn36xx/main.c
+++ b/drivers/net/wireless/ath/wcn36xx/main.c
@@ -779,9 +779,9 @@ static void wcn36xx_bss_info_changed(struct ieee80211_hw *hw,
 			wcn36xx_smd_set_link_st(wcn, vif->addr, vif->addr,
 						link_state);
 		} else {
+			wcn36xx_smd_delete_bss(wcn, vif);
 			wcn36xx_smd_set_link_st(wcn, vif->addr, vif->addr,
 						WCN36XX_HAL_LINK_IDLE_STATE);
-			wcn36xx_smd_delete_bss(wcn, vif);
 		}
 	}
 out:
-- 
2.5.0
