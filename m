From: H Hartley Sweeten <hartleys@visionengravers.com>
Subject: [PATCH] iwl-debugfs.c: remove unnecessary casts of void *
Date: Fri, 8 Jan 2010 16:14:10 -0700
Message-ID: <201001081614.10343.hartleys@visionengravers.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: yi.zhu@intel.com, reinette.chatre@intel.com, linville@tuxdriver.com
To: Linux Kernel <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	ilw@linux.intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from [206.15.93.42] ([206.15.93.42]:12343 "EHLO
	visionfs1.visionengravers.com" rhost-flags-FAIL-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752670Ab0AHXON (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jan 2010 18:14:13 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

iwl-debugfs.c: remove unnecessary casts of void *

void pointers do not need to be cast to other pointer types.

Signed-off-by: H Hartley Sweeten <hsweeten@visionengravers.com>
Cc: Zhu Yi <yi.zhu@intel.com>
Cc: Reinette Chatre <reinette.chatre@intel.com>
Cc: John W. Linville <linville@tuxdriver.com>

---

diff --git a/drivers/net/wireless/iwlwifi/iwl-debugfs.c b/drivers/net/wireless/iwlwifi/iwl-debugfs.c
index 21e0f66..351dbd8 100644
--- a/drivers/net/wireless/iwlwifi/iwl-debugfs.c
+++ b/drivers/net/wireless/iwlwifi/iwl-debugfs.c
@@ -125,7 +125,7 @@ static ssize_t iwl_dbgfs_tx_statistics_read(struct file *file,
 						char __user *user_buf,
 						size_t count, loff_t *ppos) {
 
-	struct iwl_priv *priv = (struct iwl_priv *)file->private_data;
+	struct iwl_priv *priv = file->private_data;
 	char *buf;
 	int pos = 0;
 
@@ -184,7 +184,7 @@ static ssize_t iwl_dbgfs_rx_statistics_read(struct file *file,
 						char __user *user_buf,
 						size_t count, loff_t *ppos) {
 
-	struct iwl_priv *priv = (struct iwl_priv *)file->private_data;
+	struct iwl_priv *priv = file->private_data;
 	char *buf;
 	int pos = 0;
 	int cnt;
@@ -232,7 +232,7 @@ static ssize_t iwl_dbgfs_sram_read(struct file *file,
 	ssize_t ret;
 	int i;
 	int pos = 0;
-	struct iwl_priv *priv = (struct iwl_priv *)file->private_data;
+	struct iwl_priv *priv = file->private_data;
 	size_t bufsz;
 
 	/* default is to dump the entire data segment */
@@ -306,7 +306,7 @@ static ssize_t iwl_dbgfs_sram_write(struct file *file,
 static ssize_t iwl_dbgfs_stations_read(struct file *file, char __user *user_buf,
 					size_t count, loff_t *ppos)
 {
-	struct iwl_priv *priv = (struct iwl_priv *)file->private_data;
+	struct iwl_priv *priv = file->private_data;
 	struct iwl_station_entry *station;
 	int max_sta = priv->hw_params.max_stations;
 	char *buf;
@@ -376,7 +376,7 @@ static ssize_t iwl_dbgfs_nvm_read(struct file *file,
 				       loff_t *ppos)
 {
 	ssize_t ret;
-	struct iwl_priv *priv = (struct iwl_priv *)file->private_data;
+	struct iwl_priv *priv = file->private_data;
 	int pos = 0, ofs = 0, buf_size = 0;
 	const u8 *ptr;
 	char *buf;
@@ -446,7 +446,7 @@ static ssize_t iwl_dbgfs_log_event_write(struct file *file,
 static ssize_t iwl_dbgfs_channels_read(struct file *file, char __user *user_buf,
 				       size_t count, loff_t *ppos)
 {
-	struct iwl_priv *priv = (struct iwl_priv *)file->private_data;
+	struct iwl_priv *priv = file->private_data;
 	struct ieee80211_channel *channels = NULL;
 	const struct ieee80211_supported_band *supp_band = NULL;
 	int pos = 0, i, bufsz = PAGE_SIZE;
@@ -519,7 +519,7 @@ static ssize_t iwl_dbgfs_status_read(struct file *file,
 						char __user *user_buf,
 						size_t count, loff_t *ppos) {
 
-	struct iwl_priv *priv = (struct iwl_priv *)file->private_data;
+	struct iwl_priv *priv = file->private_data;
 	char buf[512];
 	int pos = 0;
 	const size_t bufsz = sizeof(buf);
@@ -567,7 +567,7 @@ static ssize_t iwl_dbgfs_interrupt_read(struct file *file,
 					char __user *user_buf,
 					size_t count, loff_t *ppos) {
 
-	struct iwl_priv *priv = (struct iwl_priv *)file->private_data;
+	struct iwl_priv *priv = file->private_data;
 	int pos = 0;
 	int cnt = 0;
 	char *buf;
@@ -654,7 +654,7 @@ static ssize_t iwl_dbgfs_interrupt_write(struct file *file,
 static ssize_t iwl_dbgfs_qos_read(struct file *file, char __user *user_buf,
 				       size_t count, loff_t *ppos)
 {
-	struct iwl_priv *priv = (struct iwl_priv *)file->private_data;
+	struct iwl_priv *priv = file->private_data;
 	int pos = 0, i;
 	char buf[256];
 	const size_t bufsz = sizeof(buf);
@@ -677,7 +677,7 @@ static ssize_t iwl_dbgfs_qos_read(struct file *file, char __user *user_buf,
 static ssize_t iwl_dbgfs_led_read(struct file *file, char __user *user_buf,
 				  size_t count, loff_t *ppos)
 {
-	struct iwl_priv *priv = (struct iwl_priv *)file->private_data;
+	struct iwl_priv *priv = file->private_data;
 	int pos = 0;
 	char buf[256];
 	const size_t bufsz = sizeof(buf);
@@ -703,7 +703,7 @@ static ssize_t iwl_dbgfs_thermal_throttling_read(struct file *file,
 				char __user *user_buf,
 				size_t count, loff_t *ppos)
 {
-	struct iwl_priv *priv = (struct iwl_priv *)file->private_data;
+	struct iwl_priv *priv = file->private_data;
 	struct iwl_tt_mgmt *tt = &priv->thermal_throttle;
 	struct iwl_tt_restriction *restriction;
 	char buf[100];
@@ -763,7 +763,7 @@ static ssize_t iwl_dbgfs_disable_ht40_read(struct file *file,
 					 char __user *user_buf,
 					 size_t count, loff_t *ppos)
 {
-	struct iwl_priv *priv = (struct iwl_priv *)file->private_data;
+	struct iwl_priv *priv = file->private_data;
 	char buf[100];
 	int pos = 0;
 	const size_t bufsz = sizeof(buf);
@@ -820,7 +820,7 @@ static ssize_t iwl_dbgfs_sleep_level_override_read(struct file *file,
 						   char __user *user_buf,
 						   size_t count, loff_t *ppos)
 {
-	struct iwl_priv *priv = (struct iwl_priv *)file->private_data;
+	struct iwl_priv *priv = file->private_data;
 	char buf[10];
 	int pos, value;
 	const size_t bufsz = sizeof(buf);
@@ -838,7 +838,7 @@ static ssize_t iwl_dbgfs_current_sleep_command_read(struct file *file,
 						    char __user *user_buf,
 						    size_t count, loff_t *ppos)
 {
-	struct iwl_priv *priv = (struct iwl_priv *)file->private_data;
+	struct iwl_priv *priv = file->private_data;
 	char buf[200];
 	int pos = 0, i;
 	const size_t bufsz = sizeof(buf);
@@ -976,7 +976,7 @@ static ssize_t iwl_dbgfs_tx_queue_read(struct file *file,
 						char __user *user_buf,
 						size_t count, loff_t *ppos) {
 
-	struct iwl_priv *priv = (struct iwl_priv *)file->private_data;
+	struct iwl_priv *priv = file->private_data;
 	struct iwl_tx_queue *txq;
 	struct iwl_queue *q;
 	char *buf;
@@ -1022,7 +1022,7 @@ static ssize_t iwl_dbgfs_rx_queue_read(struct file *file,
 						char __user *user_buf,
 						size_t count, loff_t *ppos) {
 
-	struct iwl_priv *priv = (struct iwl_priv *)file->private_data;
+	struct iwl_priv *priv = file->private_data;
 	struct iwl_rx_queue *rxq = &priv->rxq;
 	char buf[256];
 	int pos = 0;
@@ -1068,7 +1068,7 @@ static ssize_t iwl_dbgfs_ucode_rx_stats_read(struct file *file,
 					char __user *user_buf,
 					size_t count, loff_t *ppos)
 {
-	struct iwl_priv *priv = (struct iwl_priv *)file->private_data;
+	struct iwl_priv *priv = file->private_data;
 	int pos = 0;
 	char *buf;
 	int bufsz = sizeof(struct statistics_rx_phy) * 20 +
@@ -1379,7 +1379,7 @@ static ssize_t iwl_dbgfs_ucode_tx_stats_read(struct file *file,
 					char __user *user_buf,
 					size_t count, loff_t *ppos)
 {
-	struct iwl_priv *priv = (struct iwl_priv *)file->private_data;
+	struct iwl_priv *priv = file->private_data;
 	int pos = 0;
 	char *buf;
 	int bufsz = (sizeof(struct statistics_tx) * 24) + 250;
@@ -1521,7 +1521,7 @@ static ssize_t iwl_dbgfs_ucode_general_stats_read(struct file *file,
 					char __user *user_buf,
 					size_t count, loff_t *ppos)
 {
-	struct iwl_priv *priv = (struct iwl_priv *)file->private_data;
+	struct iwl_priv *priv = file->private_data;
 	int pos = 0;
 	char *buf;
 	int bufsz = sizeof(struct statistics_general) * 4 + 250;
@@ -1612,7 +1612,7 @@ static ssize_t iwl_dbgfs_sensitivity_read(struct file *file,
 					char __user *user_buf,
 					size_t count, loff_t *ppos) {
 
-	struct iwl_priv *priv = (struct iwl_priv *)file->private_data;
+	struct iwl_priv *priv = file->private_data;
 	int pos = 0;
 	int cnt = 0;
 	char *buf;
@@ -1693,7 +1693,7 @@ static ssize_t iwl_dbgfs_chain_noise_read(struct file *file,
 					char __user *user_buf,
 					size_t count, loff_t *ppos) {
 
-	struct iwl_priv *priv = (struct iwl_priv *)file->private_data;
+	struct iwl_priv *priv = file->private_data;
 	int pos = 0;
 	int cnt = 0;
 	char *buf;
@@ -1751,7 +1751,7 @@ static ssize_t iwl_dbgfs_tx_power_read(struct file *file,
 					char __user *user_buf,
 					size_t count, loff_t *ppos) {
 
-	struct iwl_priv *priv = (struct iwl_priv *)file->private_data;
+	struct iwl_priv *priv = file->private_data;
 	char buf[128];
 	int pos = 0;
 	ssize_t ret;
@@ -1802,7 +1802,7 @@ static ssize_t iwl_dbgfs_power_save_status_read(struct file *file,
 						    char __user *user_buf,
 						    size_t count, loff_t *ppos)
 {
-	struct iwl_priv *priv = (struct iwl_priv *)file->private_data;
+	struct iwl_priv *priv = file->private_data;
 	char buf[60];
 	int pos = 0;
 	const size_t bufsz = sizeof(buf);
