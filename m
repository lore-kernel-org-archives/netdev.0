From: Paul McQuade <paulmcquad@gmail.com>
Subject: [PATCH 2/3] net: wireless: b43: Fixed Pointer issue
Date: Sun, 18 Oct 2015 00:01:37 +0100
Message-ID: <1445122898-5810-2-git-send-email-paulmcquad@gmail.com>
References: <1445122898-5810-1-git-send-email-paulmcquad@gmail.com>
Cc: kvalo@codeaurora.org, zajec5@gmail.com, johannes.berg@intel.com,
	davem@davemloft.net, joe@perches.com, m@bues.ch,
	mike.looijmans@topic.nl, cengelma@gmx.at, khoroshilov@ispras.ru,
	linux-wireless@vger.kernel.org, b43-dev@lists.infradead.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: paulmcquad@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1445122898-5810-1-git-send-email-paulmcquad@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Moved around pointer to avoid ERROR

Signed-off-by: Paul McQuade <paulmcquad@gmail.com>
---
 drivers/net/wireless/b43/dma.h  | 14 +++++++-------
 drivers/net/wireless/b43/main.c |  6 +++---
 drivers/net/wireless/b43/main.h |  2 +-
 drivers/net/wireless/b43/xmit.h |  2 +-
 4 files changed, 12 insertions(+), 12 deletions(-)
 
 enum b43_dmatype {
diff --git a/drivers/net/wireless/b43/main.c b/drivers/net/wireless/b43/main.c
index 2849070..040caa4 100644
--- a/drivers/net/wireless/b43/main.c
+++ b/drivers/net/wireless/b43/main.c
@@ -364,7 +364,7 @@ static struct ieee80211_supported_band b43_band_2ghz_limited = {
 
 static void b43_wireless_core_exit(struct b43_wldev *dev);
 static int b43_wireless_core_init(struct b43_wldev *dev);
-static struct b43_wldev * b43_wireless_core_stop(struct b43_wldev *dev);
+static struct b43_wldev *b43_wireless_core_stop(struct b43_wldev *dev);
 static int b43_wireless_core_start(struct b43_wldev *dev);
 static void b43_op_bss_info_changed(struct ieee80211_hw *hw,
 				    struct ieee80211_vif *vif,
@@ -989,7 +989,7 @@ static void do_key_write(struct b43_wldev *dev,
 		 * 0xffffffff and let's b43_op_update_tkip_key provide a
 		 * correct pair.
 		 */
-		rx_tkip_phase1_write(dev, index, 0xffffffff, (u16*)buf);
+		rx_tkip_phase1_write(dev, index, 0xffffffff, (u16 *)buf);
 	} else if (index >= pairwise_keys_start) /* clear it */
 		rx_tkip_phase1_write(dev, index, 0, NULL);
 	if (key)
@@ -4334,7 +4334,7 @@ out_unlock:
 /* Locking: wl->mutex
  * Returns the current dev. This might be different from the passed in dev,
  * because the core might be gone away while we unlocked the mutex. */
-static struct b43_wldev * b43_wireless_core_stop(struct b43_wldev *dev)
+static struct b43_wldev *b43_wireless_core_stop(struct b43_wldev *dev)
 {
 	struct b43_wl *wl;
 	struct b43_wldev *orig_dev;
diff --git a/drivers/net/wireless/b43/main.h b/drivers/net/wireless/b43/main.h
index c46430c..fa56b22 100644
--- a/drivers/net/wireless/b43/main.h
+++ b/drivers/net/wireless/b43/main.h
@@ -73,7 +73,7 @@ static inline int b43_is_ofdm_rate(int rate)
 u8 b43_ieee80211_antenna_sanitize(struct b43_wldev *dev,
 				  u8 antenna_nr);
 
-void b43_tsf_read(struct b43_wldev *dev, u64 * tsf);
+void b43_tsf_read(struct b43_wldev *dev, u64 *tsf);
 void b43_tsf_write(struct b43_wldev *dev, u64 tsf);
 
 u32 b43_shm_read32(struct b43_wldev *dev, u16 routing, u16 offset);
diff --git a/drivers/net/wireless/b43/xmit.h b/drivers/net/wireless/b43/xmit.h
index ba61153..fed8657 100644
--- a/drivers/net/wireless/b43/xmit.h
+++ b/drivers/net/wireless/b43/xmit.h
@@ -203,7 +203,7 @@ size_t b43_txhdr_size(struct b43_wldev *dev)
 
 
 int b43_generate_txhdr(struct b43_wldev *dev,
-		       u8 * txhdr,
+		       u8 *txhdr,
 		       struct sk_buff *skb_frag,
 		       struct ieee80211_tx_info *txctl, u16 cookie);
 
-- 
2.6.1
