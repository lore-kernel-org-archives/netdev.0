From: Greg Dietsche <Gregory.Dietsche@cuw.edu>
Subject: [PATCH 3/4] iwlegacy: remove enum iw_calib and related code
Date: Mon, 27 Feb 2012 12:25:32 -0600
Message-ID: <1330367133-26465-4-git-send-email-Gregory.Dietsche@cuw.edu>
References: <1330367133-26465-1-git-send-email-Gregory.Dietsche@cuw.edu>
Cc: linville@tuxdriver.com, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Greg Dietsche <Gregory.Dietsche@cuw.edu>
To: sgruszka@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1330367133-26465-1-git-send-email-Gregory.Dietsche@cuw.edu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove the enum il_calib. It defined one identifier: IL_CALIB_MAX.
Remove the function il4965_calib_free_results. It was doing nothing
because IL_CALIB_MAX is zero. Next, remove calib_results from the
il_priv structure and also remove the associated return
type/struct il_calib_result.

Signed-off-by: Greg Dietsche <Gregory.Dietsche@cuw.edu>
---
 drivers/net/wireless/iwlegacy/4965-calib.c |   12 ------------
 drivers/net/wireless/iwlegacy/4965-mac.c   |    1 -
 drivers/net/wireless/iwlegacy/4965.h       |    1 -
 drivers/net/wireless/iwlegacy/common.h     |   18 ------------------
 4 files changed, 0 insertions(+), 32 deletions(-)

diff --git a/drivers/net/wireless/iwlegacy/4965-calib.c b/drivers/net/wireless/iwlegacy/4965-calib.c
index 47c20e3..e78bdef 100644
--- a/drivers/net/wireless/iwlegacy/4965-calib.c
+++ b/drivers/net/wireless/iwlegacy/4965-calib.c
@@ -79,18 +79,6 @@ struct stats_general_data {
 	u32 beacon_energy_c;
 };
 
-void
-il4965_calib_free_results(struct il_priv *il)
-{
-	int i;
-
-	for (i = 0; i < IL_CALIB_MAX; i++) {
-		kfree(il->calib_results[i].buf);
-		il->calib_results[i].buf = NULL;
-		il->calib_results[i].buf_len = 0;
-	}
-}
-
 /*****************************************************************************
  * RUNTIME calibrations framework
  *****************************************************************************/
diff --git a/drivers/net/wireless/iwlegacy/4965-mac.c b/drivers/net/wireless/iwlegacy/4965-mac.c
index 2d01db0..3160e37 100644
--- a/drivers/net/wireless/iwlegacy/4965-mac.c
+++ b/drivers/net/wireless/iwlegacy/4965-mac.c
@@ -6347,7 +6347,6 @@ err:
 static void
 il4965_uninit_drv(struct il_priv *il)
 {
-	il4965_calib_free_results(il);
 	il_free_geos(il);
 	il_free_channel_map(il);
 	kfree(il->scan_cmd);
diff --git a/drivers/net/wireless/iwlegacy/4965.h b/drivers/net/wireless/iwlegacy/4965.h
index 208a456..1db6776 100644
--- a/drivers/net/wireless/iwlegacy/4965.h
+++ b/drivers/net/wireless/iwlegacy/4965.h
@@ -927,7 +927,6 @@ void il4965_chain_noise_calibration(struct il_priv *il, void *stat_resp);
 void il4965_sensitivity_calibration(struct il_priv *il, void *resp);
 void il4965_init_sensitivity(struct il_priv *il);
 void il4965_reset_run_time_calib(struct il_priv *il);
-void il4965_calib_free_results(struct il_priv *il);
 
 /* Debug */
 #ifdef CONFIG_IWLEGACY_DEBUGFS
diff --git a/drivers/net/wireless/iwlegacy/common.h b/drivers/net/wireless/iwlegacy/common.h
index 6ed9871..d0de922 100644
--- a/drivers/net/wireless/iwlegacy/common.h
+++ b/drivers/net/wireless/iwlegacy/common.h
@@ -961,21 +961,6 @@ enum il4965_calib_enabled_state {
 	IL_CALIB_ENABLED = 1,
 };
 
-/*
- * enum il_calib
- * defines the order in which results of initial calibrations
- * should be sent to the runtime uCode
- */
-enum il_calib {
-	IL_CALIB_MAX,
-};
-
-/* Opaque calibration results */
-struct il_calib_result {
-	void *buf;
-	size_t buf_len;
-};
-
 enum ucode_type {
 	UCODE_NONE = 0,
 	UCODE_INIT,
@@ -1195,9 +1180,6 @@ struct il_priv {
 	s32 temperature;	/* degrees Kelvin */
 	s32 last_temperature;
 
-	/* init calibration results */
-	struct il_calib_result calib_results[IL_CALIB_MAX];
-
 	/* Scan related variables */
 	unsigned long scan_start;
 	unsigned long scan_start_tsf;
-- 
1.7.6.4
