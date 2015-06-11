From: Nicholas Mc Guire <hofrat@osadl.org>
Subject: [PATCH] ath10k: txrx: remove unreachable negative return check and fixup type
Date: Thu, 11 Jun 2015 18:18:09 +0200
Message-ID: <1434039489-24934-1-git-send-email-hofrat@osadl.org>
Cc: ath10k@lists.infradead.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Nicholas Mc Guire <hofrat@osadl.org>
To: Kalle Valo <kvalo@qca.qualcomm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

wait_event_timeout(), introduced in 'commit 5e3dd157d7e7 ("ath10k: mac80211
driver for Qualcomm Atheros 802.11ac CQA98xx devices")' never returns < 0
so the only failure condition to be checked is == 0 (timeout). Further the
return type is long not int - an appropriately named variable is added
and the assignments fixed up.

Signed-off-by: Nicholas Mc Guire <hofrat@osadl.org>
---

Patch was compile tested with x86_64_defconfig + CONFIG_ATH_CARD=y
CONFIG_ATH10K=m

Patch is against 4.1-rc7 (localversion-next is -next-20150611)
 
 drivers/net/wireless/ath/ath10k/txrx.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/wireless/ath/ath10k/txrx.c b/drivers/net/wireless/ath/ath10k/txrx.c
index 826500b..6cf2891 100644
--- a/drivers/net/wireless/ath/ath10k/txrx.c
+++ b/drivers/net/wireless/ath/ath10k/txrx.c
@@ -147,9 +147,9 @@ struct ath10k_peer *ath10k_peer_find_by_id(struct ath10k *ar, int peer_id)
 static int ath10k_wait_for_peer_common(struct ath10k *ar, int vdev_id,
 				       const u8 *addr, bool expect_mapped)
 {
-	int ret;
+	long time_left;
 
-	ret = wait_event_timeout(ar->peer_mapping_wq, ({
+	time_left = wait_event_timeout(ar->peer_mapping_wq, ({
 			bool mapped;
 
 			spin_lock_bh(&ar->data_lock);
@@ -160,7 +160,7 @@ static int ath10k_wait_for_peer_common(struct ath10k *ar, int vdev_id,
 			 test_bit(ATH10K_FLAG_CRASH_FLUSH, &ar->dev_flags));
 		}), 3*HZ);
 
-	if (ret <= 0)
+	if (time_left == 0)
 		return -ETIMEDOUT;
 
 	return 0;
-- 
1.7.10.4
