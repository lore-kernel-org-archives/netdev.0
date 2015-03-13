From: Nicholas Mc Guire <hofrat@osadl.org>
Subject: [PATCH] ath10k: mac: match wait_for_completion_timeout return type
Date: Fri, 13 Mar 2015 14:38:06 -0400
Message-ID: <1426271886-20562-1-git-send-email-hofrat@osadl.org>
Cc: ath10k@lists.infradead.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Nicholas Mc Guire <hofrat@osadl.org>
To: Kalle Valo <kvalo@qca.qualcomm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Return type of wait_for_completion_timeout is unsigned long not int.
An appropriately named unsigned long is added, respectively 'ret'
renamed, and the assignments fixed up.

Signed-off-by: Nicholas Mc Guire <hofrat@osadl.org>
---

Patch was only compile tested with x86_64_defconfig + CONFIG_ATH_CARDS=m,
CONFIG_ATH10K=m

Patch is against 4.0-rc3 (localversion-next is -next-20150313)

 drivers/net/wireless/ath/ath10k/mac.c |   20 +++++++++++---------
 1 file changed, 11 insertions(+), 9 deletions(-)

diff --git a/drivers/net/wireless/ath/ath10k/mac.c b/drivers/net/wireless/ath/ath10k/mac.c
index e8cc19f..3fa11d8 100644
--- a/drivers/net/wireless/ath/ath10k/mac.c
+++ b/drivers/net/wireless/ath/ath10k/mac.c
@@ -99,6 +99,7 @@ static int ath10k_install_key(struct ath10k_vif *arvif,
 {
 	struct ath10k *ar = arvif->ar;
 	int ret;
+	unsigned long time_left;
 
 	lockdep_assert_held(&ar->conf_mutex);
 
@@ -108,8 +109,8 @@ static int ath10k_install_key(struct ath10k_vif *arvif,
 	if (ret)
 		return ret;
 
-	ret = wait_for_completion_timeout(&ar->install_key_done, 3*HZ);
-	if (ret == 0)
+	time_left = wait_for_completion_timeout(&ar->install_key_done, 3 * HZ);
+	if (time_left == 0)
 		return -ETIMEDOUT;
 
 	return 0;
@@ -561,16 +562,16 @@ static void ath10k_mac_vif_beacon_cleanup(struct ath10k_vif *arvif)
 
 static inline int ath10k_vdev_setup_sync(struct ath10k *ar)
 {
-	int ret;
+	unsigned long time_left;
 
 	lockdep_assert_held(&ar->conf_mutex);
 
 	if (test_bit(ATH10K_FLAG_CRASH_FLUSH, &ar->dev_flags))
 		return -ESHUTDOWN;
 
-	ret = wait_for_completion_timeout(&ar->vdev_setup_done,
-					  ATH10K_VDEV_SETUP_TIMEOUT_HZ);
-	if (ret == 0)
+	time_left = wait_for_completion_timeout(&ar->vdev_setup_done,
+						ATH10K_VDEV_SETUP_TIMEOUT_HZ);
+	if (time_left == 0)
 		return -ETIMEDOUT;
 
 	return 0;
@@ -2432,6 +2433,7 @@ void ath10k_offchan_tx_work(struct work_struct *work)
 	const u8 *peer_addr;
 	int vdev_id;
 	int ret;
+	unsigned long time_left;
 
 	/* FW requirement: We must create a peer before FW will send out
 	 * an offchannel frame. Otherwise the frame will be stuck and
@@ -2477,9 +2479,9 @@ void ath10k_offchan_tx_work(struct work_struct *work)
 
 		ath10k_tx_htt(ar, skb);
 
-		ret = wait_for_completion_timeout(&ar->offchan_tx_completed,
-						  3 * HZ);
-		if (ret == 0)
+		time_left =
+		wait_for_completion_timeout(&ar->offchan_tx_completed, 3 * HZ);
+		if (time_left == 0)
 			ath10k_warn(ar, "timed out waiting for offchannel skb %p\n",
 				    skb);
 
-- 
1.7.10.4
