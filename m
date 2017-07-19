From: Philipp Zabel <p.zabel@pengutronix.de>
Subject: [PATCH 049/102] ath10k: explicitly request exclusive reset control
Date: Wed, 19 Jul 2017 17:25:53 +0200
Message-ID: <20170719152646.25903-50-p.zabel@pengutronix.de>
References: <20170719152646.25903-1-p.zabel@pengutronix.de>
Cc: Philipp Zabel <p.zabel@pengutronix.de>,
        Kalle Valo <kvalo@qca.qualcomm.com>,
        ath10k@lists.infradead.org, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170719152646.25903-1-p.zabel@pengutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Commit a53e35db70d1 ("reset: Ensure drivers are explicit when requesting
reset lines") started to transition the reset control request API calls
to explicitly state whether the driver needs exclusive or shared reset
control behavior. Convert all drivers requesting exclusive resets to the
explicit API call so the temporary transition helpers can be removed.

No functional changes.

Cc: Kalle Valo <kvalo@qca.qualcomm.com>
Cc: ath10k@lists.infradead.org
Cc: linux-wireless@vger.kernel.org
Cc: netdev@vger.kernel.org
Signed-off-by: Philipp Zabel <p.zabel@pengutronix.de>
---
 drivers/net/wireless/ath/ath10k/ahb.c | 15 ++++++++++-----
 1 file changed, 10 insertions(+), 5 deletions(-)

diff --git a/drivers/net/wireless/ath/ath10k/ahb.c b/drivers/net/wireless/ath/ath10k/ahb.c
index da770af830369..2ad3ed7b89417 100644
--- a/drivers/net/wireless/ath/ath10k/ahb.c
+++ b/drivers/net/wireless/ath/ath10k/ahb.c
@@ -197,35 +197,40 @@ static int ath10k_ahb_rst_ctrl_init(struct ath10k *ar)
 
 	dev = &ar_ahb->pdev->dev;
 
-	ar_ahb->core_cold_rst = devm_reset_control_get(dev, "wifi_core_cold");
+	ar_ahb->core_cold_rst = devm_reset_control_get_exclusive(dev,
+								 "wifi_core_cold");
 	if (IS_ERR(ar_ahb->core_cold_rst)) {
 		ath10k_err(ar, "failed to get core cold rst ctrl: %ld\n",
 			   PTR_ERR(ar_ahb->core_cold_rst));
 		return PTR_ERR(ar_ahb->core_cold_rst);
 	}
 
-	ar_ahb->radio_cold_rst = devm_reset_control_get(dev, "wifi_radio_cold");
+	ar_ahb->radio_cold_rst = devm_reset_control_get_exclusive(dev,
+								  "wifi_radio_cold");
 	if (IS_ERR(ar_ahb->radio_cold_rst)) {
 		ath10k_err(ar, "failed to get radio cold rst ctrl: %ld\n",
 			   PTR_ERR(ar_ahb->radio_cold_rst));
 		return PTR_ERR(ar_ahb->radio_cold_rst);
 	}
 
-	ar_ahb->radio_warm_rst = devm_reset_control_get(dev, "wifi_radio_warm");
+	ar_ahb->radio_warm_rst = devm_reset_control_get_exclusive(dev,
+								  "wifi_radio_warm");
 	if (IS_ERR(ar_ahb->radio_warm_rst)) {
 		ath10k_err(ar, "failed to get radio warm rst ctrl: %ld\n",
 			   PTR_ERR(ar_ahb->radio_warm_rst));
 		return PTR_ERR(ar_ahb->radio_warm_rst);
 	}
 
-	ar_ahb->radio_srif_rst = devm_reset_control_get(dev, "wifi_radio_srif");
+	ar_ahb->radio_srif_rst = devm_reset_control_get_exclusive(dev,
+								  "wifi_radio_srif");
 	if (IS_ERR(ar_ahb->radio_srif_rst)) {
 		ath10k_err(ar, "failed to get radio srif rst ctrl: %ld\n",
 			   PTR_ERR(ar_ahb->radio_srif_rst));
 		return PTR_ERR(ar_ahb->radio_srif_rst);
 	}
 
-	ar_ahb->cpu_init_rst = devm_reset_control_get(dev, "wifi_cpu_init");
+	ar_ahb->cpu_init_rst = devm_reset_control_get_exclusive(dev,
+								"wifi_cpu_init");
 	if (IS_ERR(ar_ahb->cpu_init_rst)) {
 		ath10k_err(ar, "failed to get cpu init rst ctrl: %ld\n",
 			   PTR_ERR(ar_ahb->cpu_init_rst));
-- 
2.11.0
