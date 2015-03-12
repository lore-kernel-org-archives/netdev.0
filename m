From: Nicholas Mc Guire <hofrat@osadl.org>
Subject: [PATCH 3/3] ath10k: core: drop check for impossible negative return case
Date: Thu, 12 Mar 2015 11:49:34 -0400
Message-ID: <1426175374-8674-1-git-send-email-hofrat@osadl.org>
Cc: ath10k@lists.infradead.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Nicholas Mc Guire <hofrat@osadl.org>
To: Kalle Valo <kvalo@qca.qualcomm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

fixup ath10k_wmi_wait_for_service_ready and
ath10k_wmi_wait_for_unified_ready return >=0 but never
negative as they are just passing on the return value from
wait_for_completion_timeout - so the error check should be
against equality to 0 not <= 0.

Note that the code behavior is correct even with the current <= 0 check
as on success >= 1 is returned always - so this really is just a cleanup.

Signed-off-by: Nicholas Mc Guire <hofrat@osadl.org>
---

Patch was only compile tested with x86_64_defconfig + CONFIG_ATH_CARDS=m,
CONFIG_ATH10K=m

Patch is against 4.0-rc3 (localversion-next is -next-20150312)

 drivers/net/wireless/ath/ath10k/core.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/ath/ath10k/core.c b/drivers/net/wireless/ath/ath10k/core.c
index c0e454b..b764336 100644
--- a/drivers/net/wireless/ath/ath10k/core.c
+++ b/drivers/net/wireless/ath/ath10k/core.c
@@ -1080,7 +1080,7 @@ int ath10k_core_start(struct ath10k *ar, enum ath10k_firmware_mode mode)
 
 	if (mode == ATH10K_FIRMWARE_MODE_NORMAL) {
 		status = ath10k_wmi_wait_for_service_ready(ar);
-		if (status <= 0) {
+		if (status == 0) {
 			ath10k_warn(ar, "wmi service ready event not received");
 			status = -ETIMEDOUT;
 			goto err_hif_stop;
@@ -1098,7 +1098,7 @@ int ath10k_core_start(struct ath10k *ar, enum ath10k_firmware_mode mode)
 	}
 
 	status = ath10k_wmi_wait_for_unified_ready(ar);
-	if (status <= 0) {
+	if (status == 0) {
 		ath10k_err(ar, "wmi unified ready event not received\n");
 		status = -ETIMEDOUT;
 		goto err_hif_stop;
-- 
1.7.10.4
