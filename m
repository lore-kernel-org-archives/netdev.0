From: Bjorn Andersson <bjorn.andersson@linaro.org>
Subject: [PATCH] wcn36xx: Set SMD timeout to 10 seconds
Date: Thu, 21 Apr 2016 14:09:42 -0700
Message-ID: <1461272982-7233-1-git-send-email-bjorn.andersson@linaro.org>
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, John Stultz <john.stultz@linaro.org>
To: Eugene Krasnikov <k.eugene.e@gmail.com>,
	Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

After booting the wireless subsystem and uploading the NV blob to the
WCNSS_CTRL service the remote continues to do things and will not start
servicing wlan-requests for another 2-5 seconds (measured).

The downstream code does not have any special handling for this case,
but has a timeout of 10 seconds for the communication layer. By
extending the wcn36xx timeout to match this we follows the same flow for
the boot procedure and can successfully configure WiFi as wlan0 is
registered.

Signed-off-by: Bjorn Andersson <bjorn.andersson@linaro.org>
---
 drivers/net/wireless/ath/wcn36xx/smd.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/ath/wcn36xx/smd.h b/drivers/net/wireless/ath/wcn36xx/smd.h
index e6aadd273c46..6310560901f0 100644
--- a/drivers/net/wireless/ath/wcn36xx/smd.h
+++ b/drivers/net/wireless/ath/wcn36xx/smd.h
@@ -24,7 +24,7 @@
 
 #define WCN36XX_HAL_BUF_SIZE				4096
 
-#define HAL_MSG_TIMEOUT 500
+#define HAL_MSG_TIMEOUT 10000
 #define WCN36XX_SMSM_WLAN_TX_ENABLE			0x00000400
 #define WCN36XX_SMSM_WLAN_TX_RINGS_EMPTY		0x00000200
 /* The PNO version info be contained in the rsp msg */
-- 
2.5.0
