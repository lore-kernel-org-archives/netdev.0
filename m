From: Bjorn Andersson <bjorn.andersson-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Subject: [PATCH 09/16] wcn36xx: Parse trigger_ba response properly
Date: Mon, 28 Mar 2016 23:06:26 -0700
Message-ID: <1459231593-360-10-git-send-email-bjorn.andersson@linaro.org>
References: <1459231593-360-1-git-send-email-bjorn.andersson@linaro.org>
Cc: wcn36xx-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Pontus Fuchs <pontus.fuchs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Eugene Krasnikov <k.eugene.e-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1459231593-360-1-git-send-email-bjorn.andersson-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Pontus Fuchs <pontus.fuchs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

This message does not follow the canonical format and needs it's own
parser.

Signed-off-by: Pontus Fuchs <pontus.fuchs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Signed-off-by: Bjorn Andersson <bjorn.andersson-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
---
 drivers/net/wireless/ath/wcn36xx/smd.c | 14 ++++++++++++--
 1 file changed, 12 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/ath/wcn36xx/smd.c b/drivers/net/wireless/ath/wcn36xx/smd.c
index 887781dff110..2b416ee9f105 100644
--- a/drivers/net/wireless/ath/wcn36xx/smd.c
+++ b/drivers/net/wireless/ath/wcn36xx/smd.c
@@ -1963,6 +1963,17 @@ out:
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
@@ -1987,8 +1998,7 @@ int wcn36xx_smd_trigger_ba(struct wcn36xx *wcn, u8 sta_index)
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

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
