From: Nicholas Mc Guire <hofrat@osadl.org>
Subject: [PATCH 1/2] ath10k: wmi: match wait_for_completion_timeout return type
Date: Sat, 14 Mar 2015 04:55:02 -0400
Message-ID: <1426323302-1310-1-git-send-email-hofrat@osadl.org>
Cc: Michal Kazior <michal.kazior@tieto.com>,
	ath10k@lists.infradead.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Nicholas Mc Guire <hofrat@osadl.org>
To: Kalle Valo <kvalo@qca.qualcomm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

return type of wait_for_completion_timeout is unsigned long not int. This
patch adjusts the type and name of the return variable and adjusts the 
success/fail values to match those used at the call site in ath10k_core_start

Signed-off-by: Nicholas Mc Guire <hofrat@osadl.org>
---

Adjustment of return values was proposed by Michal Kazior
<michal.kazior@tieto.com> - thanks!

Patch was only compile tested with x86_64_defconfig + CONFIG_ATH_CARDS=m,
CONFIG_ATH10K=m

Patch is against 4.0-rc3 (localversion-next is -next-20150313)

 drivers/net/wireless/ath/ath10k/wmi.c |   20 ++++++++++++--------
 1 file changed, 12 insertions(+), 8 deletions(-)

diff --git a/drivers/net/wireless/ath/ath10k/wmi.c b/drivers/net/wireless/ath/ath10k/wmi.c
index c7ea77e..65e495d 100644
--- a/drivers/net/wireless/ath/ath10k/wmi.c
+++ b/drivers/net/wireless/ath/ath10k/wmi.c
@@ -884,20 +884,24 @@ void ath10k_wmi_put_wmi_channel(struct wmi_channel *ch,
 
 int ath10k_wmi_wait_for_service_ready(struct ath10k *ar)
 {
-	int ret;
+	unsigned long time_left;
 
-	ret = wait_for_completion_timeout(&ar->wmi.service_ready,
-					  WMI_SERVICE_READY_TIMEOUT_HZ);
-	return ret;
+	time_left = wait_for_completion_timeout(&ar->wmi.service_ready,
+						WMI_SERVICE_READY_TIMEOUT_HZ);
+	if (!time_left)
+		return -ETIMEDOUT;
+	return 0;
 }
 
 int ath10k_wmi_wait_for_unified_ready(struct ath10k *ar)
 {
-	int ret;
+	unsigned long time_left;
 
-	ret = wait_for_completion_timeout(&ar->wmi.unified_ready,
-					  WMI_UNIFIED_READY_TIMEOUT_HZ);
-	return ret;
+	time_left = wait_for_completion_timeout(&ar->wmi.unified_ready,
+						WMI_UNIFIED_READY_TIMEOUT_HZ);
+	if (!time_left)
+		return -ETIMEDOUT;
+	return 0;
 }
 
 struct sk_buff *ath10k_wmi_alloc_skb(struct ath10k *ar, u32 len)
-- 
1.7.10.4
