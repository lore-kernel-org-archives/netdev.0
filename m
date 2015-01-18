From: Andy Green <andy.green@linaro.org>
Subject: [PATCH 5/7] net: wireless: wcn36xx: swallow two wcn3620 IND messages
Date: Sun, 18 Jan 2015 13:11:05 +0800
Message-ID: <20150118051105.31866.43889.stgit@114-36-241-182.dynamic.hinet.net>
References: <20150118050741.31866.36490.stgit@114-36-241-182.dynamic.hinet.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: wcn36xx@lists.infradead.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org
To: Kalle Valo <kvalo@codeaurora.org>,
	Eugene Krasnikov <k.eugene.e@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:39370 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751577AbbARFLM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Jan 2015 00:11:12 -0500
In-Reply-To: <20150118050741.31866.36490.stgit@114-36-241-182.dynamic.hinet.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

WCN3620 can asynchronously send two new kinds of indication message,
since we can't handle them just accept them quietly.

Signed-off-by: Andy Green <andy.green@linaro.org>
---
 drivers/net/wireless/ath/wcn36xx/smd.c |    6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/net/wireless/ath/wcn36xx/smd.c b/drivers/net/wireless/ath/wcn36xx/smd.c
index 6398693..819741c 100644
--- a/drivers/net/wireless/ath/wcn36xx/smd.c
+++ b/drivers/net/wireless/ath/wcn36xx/smd.c
@@ -2061,6 +2061,8 @@ static void wcn36xx_smd_rsp_process(struct wcn36xx *wcn, void *buf, size_t len)
 		complete(&wcn->hal_rsp_compl);
 		break;
 
+	case WCN36XX_HAL_COEX_IND:
+	case WCN36XX_HAL_AVOID_FREQ_RANGE_IND:
 	case WCN36XX_HAL_OTA_TX_COMPL_IND:
 	case WCN36XX_HAL_MISSED_BEACON_IND:
 	case WCN36XX_HAL_DELETE_STA_CONTEXT_IND:
@@ -2107,6 +2109,10 @@ static void wcn36xx_ind_smd_work(struct work_struct *work)
 	msg_header = (struct wcn36xx_hal_msg_header *)hal_ind_msg->msg;
 
 	switch (msg_header->msg_type) {
+	case WCN36XX_HAL_COEX_IND:
+		break;
+	case WCN36XX_HAL_AVOID_FREQ_RANGE_IND:
+		break;
 	case WCN36XX_HAL_OTA_TX_COMPL_IND:
 		wcn36xx_smd_tx_compl_ind(wcn,
 					 hal_ind_msg->msg,
