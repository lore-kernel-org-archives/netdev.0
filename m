From: Bjorn Andersson <bjorn.andersson@linaro.org>
Subject: [PATCH v5 5/5] wcn36xx: Don't use the destroyed hal_mutex
Date: Mon, 14 Nov 2016 22:06:54 -0800
Message-ID: <1479190014-11297-5-git-send-email-bjorn.andersson@linaro.org>
References: <1479190014-11297-1-git-send-email-bjorn.andersson@linaro.org>
Cc: wcn36xx@lists.infradead.org, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-arm-msm@vger.kernel.org, Andy Gross <andy.gross@linaro.org>
To: Eugene Krasnikov <k.eugene.e@gmail.com>,
        Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1479190014-11297-1-git-send-email-bjorn.andersson@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

ieee80211_unregister_hw() might invoke operations to stop the interface,
that uses the hal_mutex. So don't destroy it until after we're done
using it.

Signed-off-by: Bjorn Andersson <bjorn.andersson@linaro.org>
---

With this patch I can successfully (although with a SMD send timeout in the
shutdown path) start and stop the WCNSS PIL/remoteproc multiple times and the
wlan0 interface will come and go accordingly.

Will submit the necessary DT patches soon as well.

Changes since v4:
- New patch

 drivers/net/wireless/ath/wcn36xx/main.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/wireless/ath/wcn36xx/main.c b/drivers/net/wireless/ath/wcn36xx/main.c
index 96a9584edcbb..0002190c9041 100644
--- a/drivers/net/wireless/ath/wcn36xx/main.c
+++ b/drivers/net/wireless/ath/wcn36xx/main.c
@@ -1241,7 +1241,6 @@ static int wcn36xx_remove(struct platform_device *pdev)
 	wcn36xx_dbg(WCN36XX_DBG_MAC, "platform remove\n");
 
 	release_firmware(wcn->nv);
-	mutex_destroy(&wcn->hal_mutex);
 
 	ieee80211_unregister_hw(hw);
 
@@ -1250,6 +1249,8 @@ static int wcn36xx_remove(struct platform_device *pdev)
 
 	iounmap(wcn->dxe_base);
 	iounmap(wcn->ccu_base);
+
+	mutex_destroy(&wcn->hal_mutex);
 	ieee80211_free_hw(hw);
 
 	return 0;
-- 
2.5.0
