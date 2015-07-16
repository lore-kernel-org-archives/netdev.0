From: Maninder Singh <maninder1.s@samsung.com>
Subject: [PATCH 1/1] ath10k: fixing wrong initialization of struct channel
Date: Thu, 16 Jul 2015 09:25:33 +0530
Message-ID: <1437018933-25832-1-git-send-email-maninder1.s@samsung.com>
Cc: pankaj.m@samsung.com, Maninder Singh <maninder1.s@samsung.com>
To: kvalo@qca.qualcomm.com, ath10k@lists.infradead.org,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

chandef is initialized with NULL and on the very next line,
we are using it to get channel, which is not correct.

channel should be initialized after obtaining chandef.

Signed-off-by: Maninder Singh <maninder1.s@samsung.com>
---
 drivers/net/wireless/ath/ath10k/mac.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/ath/ath10k/mac.c b/drivers/net/wireless/ath/ath10k/mac.c
index 218b6af..3d196b5 100644
--- a/drivers/net/wireless/ath/ath10k/mac.c
+++ b/drivers/net/wireless/ath/ath10k/mac.c
@@ -836,7 +836,7 @@ static inline int ath10k_vdev_setup_sync(struct ath10k *ar)
 static int ath10k_monitor_vdev_start(struct ath10k *ar, int vdev_id)
 {
 	struct cfg80211_chan_def *chandef = NULL;
-	struct ieee80211_channel *channel = chandef->chan;
+	struct ieee80211_channel *channel = NULL;
 	struct wmi_vdev_start_request_arg arg = {};
 	int ret = 0;
 
-- 
1.7.9.5
