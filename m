From: Bjorn Andersson <bjorn.andersson@linaro.org>
Subject: [PATCH v3 09/18] wcn36xx: Parse trigger_ba response properly
Date: Mon, 18 Apr 2016 22:00:47 -0700
Message-ID: <1461042056-10607-10-git-send-email-bjorn.andersson@linaro.org>
References: <1461042056-10607-1-git-send-email-bjorn.andersson@linaro.org>
Cc: Pontus Fuchs <pontus.fuchs@gmail.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Eugene Krasnikov <k.eugene.e@gmail.com>,
	Kalle Valo <kvalo@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:33387 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752220AbcDSFBK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Apr 2016 01:01:10 -0400
Received: by mail-pa0-f44.google.com with SMTP id zm5so2667129pac.0
        for <netdev@vger.kernel.org>; Mon, 18 Apr 2016 22:01:10 -0700 (PDT)
In-Reply-To: <1461042056-10607-1-git-send-email-bjorn.andersson@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pontus Fuchs <pontus.fuchs@gmail.com>

This message does not follow the canonical format and needs it's own
parser.

Signed-off-by: Pontus Fuchs <pontus.fuchs@gmail.com>
Signed-off-by: Bjorn Andersson <bjorn.andersson@linaro.org>
---
 drivers/net/wireless/ath/wcn36xx/smd.c | 14 ++++++++++++--
 1 file changed, 12 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/ath/wcn36xx/smd.c b/drivers/net/wireless/ath/wcn36xx/smd.c
index 76c6856ed932..7f315d098f52 100644
--- a/drivers/net/wireless/ath/wcn36xx/smd.c
+++ b/drivers/net/wireless/ath/wcn36xx/smd.c
@@ -1968,6 +1968,17 @@ out:
 	return ret;
 }
 
+static int wcn36xx_smd_trigger_ba_rsp(void *buf, int len)
+{
+	struct wcn36xx_hal_trigger_ba_rsp_msg *rsp;
+
+	if (len < sizeof(*rsp))
+		return -EINVAL;
+
+	rsp = (struct wcn36xx_hal_trigger_ba_rsp_msg *) buf;
+	return rsp->status;
+}
+
 int wcn36xx_smd_trigger_ba(struct wcn36xx *wcn, u8 sta_index)
 {
 	struct wcn36xx_hal_trigger_ba_req_msg msg_body;
@@ -1992,8 +2003,7 @@ int wcn36xx_smd_trigger_ba(struct wcn36xx *wcn, u8 sta_index)
 		wcn36xx_err("Sending hal_trigger_ba failed\n");
 		goto out;
 	}
-	ret = wcn36xx_smd_rsp_status_check_v2(wcn, wcn->hal_buf,
-						wcn->hal_rsp_len);
+	ret = wcn36xx_smd_trigger_ba_rsp(wcn->hal_buf, wcn->hal_rsp_len);
 	if (ret) {
 		wcn36xx_err("hal_trigger_ba response failed err=%d\n", ret);
 		goto out;
-- 
2.5.0
