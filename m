From: Joe Perches <joe@perches.com>
Subject: [PATCH] ath6kl: Add __printf verification to ath6kl_dbg
Date: Thu, 30 Mar 2017 15:57:23 -0700
Message-ID: <e4556e95a5935f591fdff67c6fb2f7ef5c7fd04f.1490914618.git.joe@perches.com>
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Kalle Valo <kvalo@qca.qualcomm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix fallout too.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/wireless/ath/ath6kl/debug.h    | 2 ++
 drivers/net/wireless/ath/ath6kl/htc_pipe.c | 2 +-
 drivers/net/wireless/ath/ath6kl/wmi.c      | 2 +-
 3 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/ath/ath6kl/debug.h b/drivers/net/wireless/ath/ath6kl/debug.h
index 0614393dd7ae..94297572914f 100644
--- a/drivers/net/wireless/ath/ath6kl/debug.h
+++ b/drivers/net/wireless/ath/ath6kl/debug.h
@@ -63,6 +63,7 @@ int ath6kl_read_tgt_stats(struct ath6kl *ar, struct ath6kl_vif *vif);
 
 #ifdef CONFIG_ATH6KL_DEBUG
 
+__printf(2, 3)
 void ath6kl_dbg(enum ATH6K_DEBUG_MASK mask, const char *fmt, ...);
 void ath6kl_dbg_dump(enum ATH6K_DEBUG_MASK mask,
 		     const char *msg, const char *prefix,
@@ -83,6 +84,7 @@ int ath6kl_debug_init_fs(struct ath6kl *ar);
 void ath6kl_debug_cleanup(struct ath6kl *ar);
 
 #else
+__printf(2, 3)
 static inline void ath6kl_dbg(enum ATH6K_DEBUG_MASK dbg_mask,
 			      const char *fmt, ...)
 {
diff --git a/drivers/net/wireless/ath/ath6kl/htc_pipe.c b/drivers/net/wireless/ath/ath6kl/htc_pipe.c
index ca1a18c86c0d..d127a08d60df 100644
--- a/drivers/net/wireless/ath/ath6kl/htc_pipe.c
+++ b/drivers/net/wireless/ath/ath6kl/htc_pipe.c
@@ -995,7 +995,7 @@ static int ath6kl_htc_pipe_rx_complete(struct ath6kl *ar, struct sk_buff *skb,
 
 	if (netlen < (payload_len + HTC_HDR_LENGTH)) {
 		ath6kl_dbg(ATH6KL_DBG_HTC,
-			   "HTC Rx: insufficient length, got:%d expected =%u\n",
+			   "HTC Rx: insufficient length, got:%d expected =%zu\n",
 			   netlen, payload_len + HTC_HDR_LENGTH);
 		status = -EINVAL;
 		goto free_skb;
diff --git a/drivers/net/wireless/ath/ath6kl/wmi.c b/drivers/net/wireless/ath/ath6kl/wmi.c
index 84a6d12c3f8a..a082de81ec4c 100644
--- a/drivers/net/wireless/ath/ath6kl/wmi.c
+++ b/drivers/net/wireless/ath/ath6kl/wmi.c
@@ -1596,7 +1596,7 @@ static int ath6kl_wmi_txe_notify_event_rx(struct wmi *wmi, u8 *datap, int len,
 	rate = le32_to_cpu(ev->rate);
 	pkts = le32_to_cpu(ev->pkts);
 
-	ath6kl_dbg(ATH6KL_DBG_WMI, "TXE notify event: peer %pM rate %d% pkts %d intvl %ds\n",
+	ath6kl_dbg(ATH6KL_DBG_WMI, "TXE notify event: peer %pM rate %d%% pkts %d intvl %ds\n",
 		   vif->bssid, rate, pkts, vif->txe_intvl);
 
 	cfg80211_cqm_txe_notify(vif->ndev, vif->bssid, pkts,
-- 
2.10.0.rc2.1.g053435c
