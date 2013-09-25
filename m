From: Joe Perches <joe@perches.com>
Subject: [PATCH 04/11] ath: Remove extern from function prototypes
Date: Wed, 25 Sep 2013 12:37:22 -0700
Message-ID: <a3dabaf02d36dbb4051188b706a3e66e6465c56b.1380137609.git.joe@perches.com>
References: <cover.1380137609.git.joe@perches.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Kalle Valo <kvalo@qca.qualcomm.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	"Luis R. Rodriguez" <mcgrof@qca.qualcomm.com>,
	Jouni Malinen <jouni@qca.qualcomm.com>,
	Vasanthakumar Thiagarajan <vthiagar@qca.qualcomm.com>,
	Senthil Balasubramanian <senthilb@qca.qualcomm.com>,
	ath10k@lists.infradead.org, linux-wireless@vger.kernel.org,
	linux-kernel@vger.kernel.org, ath9k-devel@lists.ath9k.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1380137609.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There are a mix of function prototypes with and without extern
in the kernel sources.  Standardize on not using extern for
function prototypes.

Function prototypes don't need to be written with extern.
extern is assumed by the compiler.  Its use is as unnecessary as
using auto to declare automatic/local variables in a block.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/wireless/ath/ath10k/debug.h  | 8 ++++----
 drivers/net/wireless/ath/ath6kl/common.h | 3 +--
 drivers/net/wireless/ath/ath6kl/debug.h  | 9 ++++-----
 drivers/net/wireless/ath/ath9k/ath9k.h   | 2 +-
 4 files changed, 10 insertions(+), 12 deletions(-)

diff --git a/drivers/net/wireless/ath/ath10k/debug.h b/drivers/net/wireless/ath/ath10k/debug.h
index 168140c..bb00633 100644
--- a/drivers/net/wireless/ath/ath10k/debug.h
+++ b/drivers/net/wireless/ath/ath10k/debug.h
@@ -37,9 +37,9 @@ enum ath10k_debug_mask {
 
 extern unsigned int ath10k_debug_mask;
 
-extern __printf(1, 2) int ath10k_info(const char *fmt, ...);
-extern __printf(1, 2) int ath10k_err(const char *fmt, ...);
-extern __printf(1, 2) int ath10k_warn(const char *fmt, ...);
+__printf(1, 2) int ath10k_info(const char *fmt, ...);
+__printf(1, 2) int ath10k_err(const char *fmt, ...);
+__printf(1, 2) int ath10k_warn(const char *fmt, ...);
 
 #ifdef CONFIG_ATH10K_DEBUGFS
 int ath10k_debug_create(struct ath10k *ar);
@@ -68,7 +68,7 @@ static inline void ath10k_debug_read_target_stats(struct ath10k *ar,
 #endif /* CONFIG_ATH10K_DEBUGFS */
 
 #ifdef CONFIG_ATH10K_DEBUG
-extern __printf(2, 3) void ath10k_dbg(enum ath10k_debug_mask mask,
+__printf(2, 3) void ath10k_dbg(enum ath10k_debug_mask mask,
 				      const char *fmt, ...);
 void ath10k_dbg_dump(enum ath10k_debug_mask mask,
 		     const char *msg, const char *prefix,
diff --git a/drivers/net/wireless/ath/ath6kl/common.h b/drivers/net/wireless/ath/ath6kl/common.h
index 98a8861..05debf7 100644
--- a/drivers/net/wireless/ath/ath6kl/common.h
+++ b/drivers/net/wireless/ath/ath6kl/common.h
@@ -22,8 +22,7 @@
 
 #define ATH6KL_MAX_IE			256
 
-extern __printf(2, 3)
-int ath6kl_printk(const char *level, const char *fmt, ...);
+__printf(2, 3) int ath6kl_printk(const char *level, const char *fmt, ...);
 
 /*
  * Reflects the version of binary interface exposed by ATH6KL target
diff --git a/drivers/net/wireless/ath/ath6kl/debug.h b/drivers/net/wireless/ath/ath6kl/debug.h
index 74369de..ca9ba00 100644
--- a/drivers/net/wireless/ath/ath6kl/debug.h
+++ b/drivers/net/wireless/ath/ath6kl/debug.h
@@ -50,11 +50,10 @@ enum ATH6K_DEBUG_MASK {
 };
 
 extern unsigned int debug_mask;
-extern __printf(2, 3)
-int ath6kl_printk(const char *level, const char *fmt, ...);
-extern __printf(1, 2) int ath6kl_info(const char *fmt, ...);
-extern __printf(1, 2) int ath6kl_err(const char *fmt, ...);
-extern __printf(1, 2) int ath6kl_warn(const char *fmt, ...);
+__printf(2, 3) int ath6kl_printk(const char *level, const char *fmt, ...);
+__printf(1, 2) int ath6kl_info(const char *fmt, ...);
+__printf(1, 2) int ath6kl_err(const char *fmt, ...);
+__printf(1, 2) int ath6kl_warn(const char *fmt, ...);
 
 enum ath6kl_war {
 	ATH6KL_WAR_INVALID_RATE,
diff --git a/drivers/net/wireless/ath/ath9k/ath9k.h b/drivers/net/wireless/ath/ath9k/ath9k.h
index 2ee35f6..da24ba2 100644
--- a/drivers/net/wireless/ath/ath9k/ath9k.h
+++ b/drivers/net/wireless/ath/ath9k/ath9k.h
@@ -952,7 +952,7 @@ void ath9k_ps_restore(struct ath_softc *sc);
 u8 ath_txchainmask_reduction(struct ath_softc *sc, u8 chainmask, u32 rate);
 
 void ath_start_rfkill_poll(struct ath_softc *sc);
-extern void ath9k_rfkill_poll_state(struct ieee80211_hw *hw);
+void ath9k_rfkill_poll_state(struct ieee80211_hw *hw);
 void ath9k_calculate_iter_data(struct ieee80211_hw *hw,
 			       struct ieee80211_vif *vif,
 			       struct ath9k_vif_iter_data *iter_data);
-- 
1.8.1.2.459.gbcd45b4.dirty
