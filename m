From: Bjorn Andersson <bjorn.andersson-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Subject: [PATCH 15/16] wcn36xx: don't pad beacons for mesh
Date: Mon, 28 Mar 2016 23:06:32 -0700
Message-ID: <1459231593-360-16-git-send-email-bjorn.andersson@linaro.org>
References: <1459231593-360-1-git-send-email-bjorn.andersson@linaro.org>
Cc: wcn36xx-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Jason Mobarak <jam-W/OLz77bvjtBDgjK7y7TUQ@public.gmane.org>,
	Chun-Yeow Yeoh <yeohchunyeow-W/OLz77bvjtBDgjK7y7TUQ@public.gmane.org>
To: Eugene Krasnikov <k.eugene.e-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1459231593-360-1-git-send-email-bjorn.andersson-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Jason Mobarak <jam-W/OLz77bvjtBDgjK7y7TUQ@public.gmane.org>

Patch "wcn36xx: Pad TIM PVM if needed" has caused a regression in mesh
beaconing.  The field tim_off is always 0 for mesh mode, and thus
pvm_len (referring to the TIM length field) and pad are both incorrectly
calculated.  Thus, msg_body.beacon_length is incorrectly calculated for
mesh mode. Fix this.

Signed-off-by: Jason Mobarak <jam-W/OLz77bvjtBDgjK7y7TUQ@public.gmane.org>
Signed-off-by: Chun-Yeow Yeoh <yeohchunyeow-W/OLz77bvjtBDgjK7y7TUQ@public.gmane.org>
Signed-off-by: Bjorn Andersson <bjorn.andersson-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
---
 drivers/net/wireless/ath/wcn36xx/smd.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/drivers/net/wireless/ath/wcn36xx/smd.c b/drivers/net/wireless/ath/wcn36xx/smd.c
index a57d158298a1..b1bdc229e560 100644
--- a/drivers/net/wireless/ath/wcn36xx/smd.c
+++ b/drivers/net/wireless/ath/wcn36xx/smd.c
@@ -1410,6 +1410,11 @@ int wcn36xx_smd_send_beacon(struct wcn36xx *wcn, struct ieee80211_vif *vif,
 
 	pvm_len = skb_beacon->data[tim_off + 1] - 3;
 	pad = TIM_MIN_PVM_SIZE - pvm_len;
+
+	/* Padding is irrelevant to mesh mode since tim_off is always 0. */
+	if (vif->type == NL80211_IFTYPE_MESH_POINT)
+		pad = 0;
+
 	msg_body.beacon_length = skb_beacon->len + pad;
 	/* TODO need to find out why + 6 is needed */
 	msg_body.beacon_length6 = msg_body.beacon_length + 6;
-- 
2.5.0

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
