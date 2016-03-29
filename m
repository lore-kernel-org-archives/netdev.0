From: Bjorn Andersson <bjorn.andersson@linaro.org>
Subject: [RESEND PATCH 15/16] wcn36xx: don't pad beacons for mesh
Date: Tue, 29 Mar 2016 14:41:12 -0700
Message-ID: <1459287672-3324-1-git-send-email-bjorn.andersson@linaro.org>
References: <1459231593-360-16-git-send-email-bjorn.andersson@linaro.org>
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	wcn36xx@lists.infradead.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Jason Mobarak <jam@cozybit.com>,
	Chun-Yeow Yeoh <yeohchunyeow@cozybit.com>
To: Eugene Krasnikov <k.eugene.e@gmail.com>,
	Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1459231593-360-16-git-send-email-bjorn.andersson@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jason Mobarak <jam@cozybit.com>

Patch "wcn36xx: Pad TIM PVM if needed" has caused a regression in mesh
beaconing.  The field tim_off is always 0 for mesh mode, and thus
pvm_len (referring to the TIM length field) and pad are both incorrectly
calculated.  Thus, msg_body.beacon_length is incorrectly calculated for
mesh mode. Fix this.

Fixes: 8ad99a4e3ee5 ("wcn36xx: Pad TIM PVM if needed")
Signed-off-by: Jason Mobarak <jam@cozybit.com>
Signed-off-by: Chun-Yeow Yeoh <yeohchunyeow@cozybit.com>
Signed-off-by: Bjorn Andersson <bjorn.andersson@linaro.org>
---

Resend this single patch with included Fixes tag.

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
