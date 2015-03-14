From: Nicholas Mc Guire <hofrat@osadl.org>
Subject: [PATCH] ath10k: thermal: match wait_for_completion_timeout return type
Date: Sat, 14 Mar 2015 05:37:22 -0400
Message-ID: <1426325842-19774-1-git-send-email-hofrat@osadl.org>
Cc: ath10k@lists.infradead.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Nicholas Mc Guire <hofrat@osadl.org>
To: Kalle Valo <kvalo@qca.qualcomm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Return type of wait_for_completion_timeout is unsigned long not int.
An appropriately named unsigned long is added and the assignments fixed up.

Signed-off-by: Nicholas Mc Guire <hofrat@osadl.org>
---

Patch was only compile tested with x86_64_defconfig + CONFIG_ATH_CARDS=m,
CONFIG_ATH10K=m

Patch is against 4.0-rc3 (localversion-next is -next-20150313)

 drivers/net/wireless/ath/ath10k/thermal.c |    7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/wireless/ath/ath10k/thermal.c b/drivers/net/wireless/ath/ath10k/thermal.c
index aede750..dfa7c93 100644
--- a/drivers/net/wireless/ath/ath10k/thermal.c
+++ b/drivers/net/wireless/ath/ath10k/thermal.c
@@ -127,6 +127,7 @@ static ssize_t ath10k_thermal_show_temp(struct device *dev,
 {
 	struct ath10k *ar = dev_get_drvdata(dev);
 	int ret, temperature;
+	unsigned long time_left;
 
 	mutex_lock(&ar->conf_mutex);
 
@@ -148,9 +149,9 @@ static ssize_t ath10k_thermal_show_temp(struct device *dev,
 		goto out;
 	}
 
-	ret = wait_for_completion_timeout(&ar->thermal.wmi_sync,
-					  ATH10K_THERMAL_SYNC_TIMEOUT_HZ);
-	if (ret == 0) {
+	time_left = wait_for_completion_timeout(&ar->thermal.wmi_sync,
+						ATH10K_THERMAL_SYNC_TIMEOUT_HZ);
+	if (!time_left) {
 		ath10k_warn(ar, "failed to synchronize thermal read\n");
 		ret = -ETIMEDOUT;
 		goto out;
-- 
1.7.10.4
