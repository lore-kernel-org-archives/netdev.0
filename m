From: Nicholas Mc Guire <hofrat@osadl.org>
Subject: [PATCH 2/2] ath10k: drop unnecessary check for negative return value
Date: Wed, 11 Mar 2015 13:20:31 -0400
Message-ID: <1426094431-10272-1-git-send-email-hofrat@osadl.org>
Cc: Valdis.Kletnieks@vt.edu, Bj??rn Mork <bjorn@mork.no>,
	ath10k@lists.infradead.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Nicholas Mc Guire <hofrat@osadl.org>
To: Kalle Valo <kvalo@qca.qualcomm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.osadl.org ([62.245.132.105]:58066 "EHLO www.osadl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751356AbbCKRZX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Mar 2015 13:25:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

wait_event_timeout() returns 0 on timeout and >= 1 on success but never
< 0 - so checking for timeout should be for equiavalence to 0 no <= 0.

Signed-off-by: Nicholas Mc Guire <hofrat@osadl.org>
---

Patch was only compile tested with x86_64_defconfig + CONFIG_ATH_CARDS=m,
CONFIG_ATH10K=m

Patch is against 4.0-rc3 (localversion-next is -next-20150311)

 drivers/net/wireless/ath/ath10k/mac.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/ath/ath10k/mac.c b/drivers/net/wireless/ath/ath10k/mac.c
index 7b27d99..4286f5c 100644
--- a/drivers/net/wireless/ath/ath10k/mac.c
+++ b/drivers/net/wireless/ath/ath10k/mac.c
@@ -4498,7 +4498,7 @@ static void ath10k_flush(struct ieee80211_hw *hw, struct ieee80211_vif *vif,
 				 check_htt_state(ar, skip),
 				 ATH10K_FLUSH_TIMEOUT_HZ);
 
-	if (ret <= 0 || skip)
+	if (ret == 0 || skip)
 		ath10k_warn(ar, "failed to flush transmit queue (skip %i ar-state %i): %i\n",
 			    skip, ar->state, ret);
 
-- 
1.7.10.4
