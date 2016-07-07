From: Bjorn Andersson <bjorn.andersson@linaro.org>
Subject: [PATCH] wcn36xx: Silence error about unsupported smd event 188
Date: Thu,  7 Jul 2016 07:48:53 -0700
Message-ID: <1467902933-28577-1-git-send-email-bjorn.andersson@linaro.org>
Cc: wcn36xx@lists.infradead.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Nicolas Dechesne <nicolas.dechesne@linaro.org>
To: Eugene Krasnikov <k.eugene.e@gmail.com>,
	Kalle Valo <kvalo@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:35258 "EHLO
	mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752159AbcGGOs5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jul 2016 10:48:57 -0400
Received: by mail-pf0-f170.google.com with SMTP id c2so6848457pfa.2
        for <netdev@vger.kernel.org>; Thu, 07 Jul 2016 07:48:56 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sometimes the firmware sends a HAL_DEL_BA_IND, the prima driver silently
ignore this message so let's do the same to silence the error message.

Cc: Nicolas Dechesne <nicolas.dechesne@linaro.org>
Signed-off-by: Bjorn Andersson <bjorn.andersson@linaro.org>
---
 drivers/net/wireless/ath/wcn36xx/smd.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/wireless/ath/wcn36xx/smd.c b/drivers/net/wireless/ath/wcn36xx/smd.c
index e8b630c4f11e..3d56a3f236f9 100644
--- a/drivers/net/wireless/ath/wcn36xx/smd.c
+++ b/drivers/net/wireless/ath/wcn36xx/smd.c
@@ -2226,6 +2226,7 @@ static void wcn36xx_smd_rsp_process(struct wcn36xx *wcn, void *buf, size_t len)
 
 	case WCN36XX_HAL_COEX_IND:
 	case WCN36XX_HAL_AVOID_FREQ_RANGE_IND:
+	case WCN36XX_HAL_DEL_BA_IND:
 	case WCN36XX_HAL_OTA_TX_COMPL_IND:
 	case WCN36XX_HAL_MISSED_BEACON_IND:
 	case WCN36XX_HAL_DELETE_STA_CONTEXT_IND:
@@ -2273,6 +2274,7 @@ static void wcn36xx_ind_smd_work(struct work_struct *work)
 
 	switch (msg_header->msg_type) {
 	case WCN36XX_HAL_COEX_IND:
+	case WCN36XX_HAL_DEL_BA_IND:
 	case WCN36XX_HAL_AVOID_FREQ_RANGE_IND:
 		break;
 	case WCN36XX_HAL_OTA_TX_COMPL_IND:
-- 
2.5.0
