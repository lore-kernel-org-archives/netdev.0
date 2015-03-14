From: Nicholas Mc Guire <hofrat@osadl.org>
Subject: [PATCH] ath10k: core: match wait_for_completion_timeout return type
Date: Sat, 14 Mar 2015 05:37:37 -0400
Message-ID: <1426325858-19808-1-git-send-email-hofrat@osadl.org>
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

 drivers/net/wireless/ath/ath10k/core.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/ath/ath10k/core.c b/drivers/net/wireless/ath/ath10k/core.c
index c0e454b..5fd833e 100644
--- a/drivers/net/wireless/ath/ath10k/core.c
+++ b/drivers/net/wireless/ath/ath10k/core.c
@@ -1151,6 +1151,7 @@ EXPORT_SYMBOL(ath10k_core_start);
 int ath10k_wait_for_suspend(struct ath10k *ar, u32 suspend_opt)
 {
 	int ret;
+	unsigned long time_left;
 
 	reinit_completion(&ar->target_suspend);
 
@@ -1160,9 +1161,9 @@ int ath10k_wait_for_suspend(struct ath10k *ar, u32 suspend_opt)
 		return ret;
 	}
 
-	ret = wait_for_completion_timeout(&ar->target_suspend, 1 * HZ);
+	time_left = wait_for_completion_timeout(&ar->target_suspend, 1 * HZ);
 
-	if (ret == 0) {
+	if (!time_left) {
 		ath10k_warn(ar, "suspend timed out - target pause event never came\n");
 		return -ETIMEDOUT;
 	}
-- 
1.7.10.4
