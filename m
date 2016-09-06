From: Masahiro Yamada <yamada.masahiro@socionext.com>
Subject: [PATCH 3/3] ath10k: do not check if reset is NULL
Date: Tue,  6 Sep 2016 21:39:58 +0900
Message-ID: <1473165598-28683-4-git-send-email-yamada.masahiro@socionext.com>
References: <1473165598-28683-1-git-send-email-yamada.masahiro@socionext.com>
Cc: Johannes Berg <johannes@sipsolutions.net>,
        "Luis R. Rodriguez" <mcgrof@do-not-panic.com>,
        Masahiro Yamada <yamada.masahiro@socionext.com>,
        Kalle Valo <kvalo@qca.qualcomm.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, ath10k@lists.infradead.org
To: linux-wireless@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1473165598-28683-1-git-send-email-yamada.masahiro@socionext.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Since reset_control_get() never returns NULL, we can use IS_ERR()
instead of IS_ERR_OR_NULL().  The return statements can be simpler
as well.

Signed-off-by: Masahiro Yamada <yamada.masahiro@socionext.com>
---

 drivers/net/wireless/ath/ath10k/ahb.c | 25 ++++++++++---------------
 1 file changed, 10 insertions(+), 15 deletions(-)

diff --git a/drivers/net/wireless/ath/ath10k/ahb.c b/drivers/net/wireless/ath/ath10k/ahb.c
index 6b355ee..b29dc4d 100644
--- a/drivers/net/wireless/ath/ath10k/ahb.c
+++ b/drivers/net/wireless/ath/ath10k/ahb.c
@@ -195,43 +195,38 @@ static int ath10k_ahb_rst_ctrl_init(struct ath10k *ar)
 	dev = &ar_ahb->pdev->dev;
 
 	ar_ahb->core_cold_rst = devm_reset_control_get(dev, "wifi_core_cold");
-	if (IS_ERR_OR_NULL(ar_ahb->core_cold_rst)) {
+	if (IS_ERR(ar_ahb->core_cold_rst)) {
 		ath10k_err(ar, "failed to get core cold rst ctrl: %ld\n",
 			   PTR_ERR(ar_ahb->core_cold_rst));
-		return ar_ahb->core_cold_rst ?
-			PTR_ERR(ar_ahb->core_cold_rst) : -ENODEV;
+		return PTR_ERR(ar_ahb->core_cold_rst);
 	}
 
 	ar_ahb->radio_cold_rst = devm_reset_control_get(dev, "wifi_radio_cold");
-	if (IS_ERR_OR_NULL(ar_ahb->radio_cold_rst)) {
+	if (IS_ERR(ar_ahb->radio_cold_rst)) {
 		ath10k_err(ar, "failed to get radio cold rst ctrl: %ld\n",
 			   PTR_ERR(ar_ahb->radio_cold_rst));
-		return ar_ahb->radio_cold_rst ?
-			PTR_ERR(ar_ahb->radio_cold_rst) : -ENODEV;
+		return PTR_ERR(ar_ahb->radio_cold_rst);
 	}
 
 	ar_ahb->radio_warm_rst = devm_reset_control_get(dev, "wifi_radio_warm");
-	if (IS_ERR_OR_NULL(ar_ahb->radio_warm_rst)) {
+	if (IS_ERR(ar_ahb->radio_warm_rst)) {
 		ath10k_err(ar, "failed to get radio warm rst ctrl: %ld\n",
 			   PTR_ERR(ar_ahb->radio_warm_rst));
-		return ar_ahb->radio_warm_rst ?
-			PTR_ERR(ar_ahb->radio_warm_rst) : -ENODEV;
+		return PTR_ERR(ar_ahb->radio_warm_rst);
 	}
 
 	ar_ahb->radio_srif_rst = devm_reset_control_get(dev, "wifi_radio_srif");
-	if (IS_ERR_OR_NULL(ar_ahb->radio_srif_rst)) {
+	if (IS_ERR(ar_ahb->radio_srif_rst)) {
 		ath10k_err(ar, "failed to get radio srif rst ctrl: %ld\n",
 			   PTR_ERR(ar_ahb->radio_srif_rst));
-		return ar_ahb->radio_srif_rst ?
-			PTR_ERR(ar_ahb->radio_srif_rst) : -ENODEV;
+		return PTR_ERR(ar_ahb->radio_srif_rst);
 	}
 
 	ar_ahb->cpu_init_rst = devm_reset_control_get(dev, "wifi_cpu_init");
-	if (IS_ERR_OR_NULL(ar_ahb->cpu_init_rst)) {
+	if (IS_ERR(ar_ahb->cpu_init_rst)) {
 		ath10k_err(ar, "failed to get cpu init rst ctrl: %ld\n",
 			   PTR_ERR(ar_ahb->cpu_init_rst));
-		return ar_ahb->cpu_init_rst ?
-			PTR_ERR(ar_ahb->cpu_init_rst) : -ENODEV;
+		return PTR_ERR(ar_ahb->cpu_init_rst);
 	}
 
 	return 0;
-- 
1.9.1
