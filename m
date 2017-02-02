From: =?UTF-8?q?Amadeusz=20S=C5=82awi=C5=84ski?=
        <amadeusz.slawinski@tieto.com>
Subject: [PATCH 2/3] ath10k: use size_t for len variables
Date: Thu,  2 Feb 2017 11:19:32 +0100
Message-ID: <1486030773-30600-2-git-send-email-amadeusz.slawinski@tieto.com>
References: <1486030773-30600-1-git-send-email-amadeusz.slawinski@tieto.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        =?UTF-8?q?Amadeusz=20S=C5=82awi=C5=84ski?=
        <amadeusz.slawinski@tieto.com>
To: ath10k@lists.infradead.org, Kalle Valo <kvalo@qca.qualcomm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1486030773-30600-1-git-send-email-amadeusz.slawinski@tieto.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

cleanup to consolidate type used for len variables

Signed-off-by: Amadeusz Sławiński <amadeusz.slawinski@tieto.com>
---
 drivers/net/wireless/ath/ath10k/core.c     |  2 +-
 drivers/net/wireless/ath/ath10k/debug.c    | 49 +++++++++++++++---------------
 drivers/net/wireless/ath/ath10k/spectral.c |  7 +++--
 3 files changed, 29 insertions(+), 29 deletions(-)

diff --git a/drivers/net/wireless/ath/ath10k/core.c b/drivers/net/wireless/ath/ath10k/core.c
index 749e381..2aa6bc7 100644
--- a/drivers/net/wireless/ath/ath10k/core.c
+++ b/drivers/net/wireless/ath/ath10k/core.c
@@ -349,7 +349,7 @@ void ath10k_core_get_fw_features_str(struct ath10k *ar,
 				     char *buf,
 				     size_t buf_len)
 {
-	unsigned int len = 0;
+	size_t len = 0;
 	int i;
 
 	for (i = 0; i < ATH10K_FW_FEATURE_COUNT; i++) {
diff --git a/drivers/net/wireless/ath/ath10k/debug.c b/drivers/net/wireless/ath/ath10k/debug.c
index 82a4c67..f649236 100644
--- a/drivers/net/wireless/ath/ath10k/debug.c
+++ b/drivers/net/wireless/ath/ath10k/debug.c
@@ -235,7 +235,7 @@ static ssize_t ath10k_read_wmi_services(struct file *file,
 {
 	struct ath10k *ar = file->private_data;
 	char *buf;
-	unsigned int len = 0, buf_len = 4096;
+	size_t len = 0, buf_len = 4096;
 	const char *name;
 	ssize_t ret_cnt;
 	bool enabled;
@@ -524,7 +524,7 @@ static ssize_t ath10k_fw_stats_read(struct file *file, char __user *user_buf,
 				    size_t count, loff_t *ppos)
 {
 	const char *buf = file->private_data;
-	unsigned int len = strlen(buf);
+	size_t len = strlen(buf);
 
 	return simple_read_from_buffer(user_buf, count, ppos, buf, len);
 }
@@ -542,17 +542,16 @@ static ssize_t ath10k_debug_fw_reset_stats_read(struct file *file,
 						size_t count, loff_t *ppos)
 {
 	struct ath10k *ar = file->private_data;
-	int ret, len, buf_len;
+	int ret;
+	size_t len = 0, buf_len = 500;
 	char *buf;
 
-	buf_len = 500;
 	buf = kmalloc(buf_len, GFP_KERNEL);
 	if (!buf)
 		return -ENOMEM;
 
 	spin_lock_bh(&ar->data_lock);
 
-	len = 0;
 	len += scnprintf(buf + len, buf_len - len,
 			 "fw_crash_counter\t\t%d\n", ar->stats.fw_crash_counter);
 	len += scnprintf(buf + len, buf_len - len,
@@ -691,7 +690,7 @@ static ssize_t ath10k_read_chip_id(struct file *file, char __user *user_buf,
 				   size_t count, loff_t *ppos)
 {
 	struct ath10k *ar = file->private_data;
-	unsigned int len;
+	size_t len;
 	char buf[50];
 
 	len = scnprintf(buf, sizeof(buf), "0x%08x\n", ar->chip_id);
@@ -726,8 +725,8 @@ static struct ath10k_dump_file_data *ath10k_build_dump_file(struct ath10k *ar)
 	struct ath10k_fw_crash_data *crash_data = ar->debug.fw_crash_data;
 	struct ath10k_dump_file_data *dump_data;
 	struct ath10k_tlv_dump_data *dump_tlv;
-	int hdr_len = sizeof(*dump_data);
-	unsigned int len, sofar = 0;
+	size_t hdr_len = sizeof(*dump_data);
+	size_t len, sofar = 0;
 	unsigned char *buf;
 
 	len = hdr_len;
@@ -844,7 +843,7 @@ static ssize_t ath10k_reg_addr_read(struct file *file,
 {
 	struct ath10k *ar = file->private_data;
 	u8 buf[32];
-	unsigned int len = 0;
+	size_t len = 0;
 	u32 reg_addr;
 
 	mutex_lock(&ar->conf_mutex);
@@ -892,7 +891,7 @@ static ssize_t ath10k_reg_value_read(struct file *file,
 {
 	struct ath10k *ar = file->private_data;
 	u8 buf[48];
-	unsigned int len;
+	size_t len;
 	u32 reg_addr, reg_val;
 	int ret;
 
@@ -1115,7 +1114,7 @@ static ssize_t ath10k_read_htt_stats_mask(struct file *file,
 {
 	struct ath10k *ar = file->private_data;
 	char buf[32];
-	unsigned int len;
+	size_t len;
 
 	len = scnprintf(buf, sizeof(buf), "%lu\n", ar->debug.htt_stats_mask);
 
@@ -1169,7 +1168,7 @@ static ssize_t ath10k_read_htt_max_amsdu_ampdu(struct file *file,
 	struct ath10k *ar = file->private_data;
 	char buf[64];
 	u8 amsdu, ampdu;
-	unsigned int len;
+	size_t len;
 
 	mutex_lock(&ar->conf_mutex);
 
@@ -1229,7 +1228,7 @@ static ssize_t ath10k_read_fw_dbglog(struct file *file,
 				     size_t count, loff_t *ppos)
 {
 	struct ath10k *ar = file->private_data;
-	unsigned int len;
+	size_t len;
 	char buf[96];
 
 	len = scnprintf(buf, sizeof(buf), "0x%16llx %u\n",
@@ -1555,11 +1554,10 @@ static ssize_t ath10k_read_ani_enable(struct file *file, char __user *user_buf,
 				      size_t count, loff_t *ppos)
 {
 	struct ath10k *ar = file->private_data;
-	int len = 0;
+	size_t len;
 	char buf[32];
 
-	len = scnprintf(buf, sizeof(buf) - len, "%d\n",
-			ar->ani_enabled);
+	len = scnprintf(buf, sizeof(buf), "%d\n", ar->ani_enabled);
 
 	return simple_read_from_buffer(user_buf, count, ppos, buf, len);
 }
@@ -1584,11 +1582,10 @@ static ssize_t ath10k_read_nf_cal_period(struct file *file,
 					 size_t count, loff_t *ppos)
 {
 	struct ath10k *ar = file->private_data;
-	unsigned int len;
+	size_t len;
 	char buf[32];
 
-	len = scnprintf(buf, sizeof(buf), "%d\n",
-			ar->debug.nf_cal_period);
+	len = scnprintf(buf, sizeof(buf), "%d\n", ar->debug.nf_cal_period);
 
 	return simple_read_from_buffer(user_buf, count, ppos, buf, len);
 }
@@ -1684,9 +1681,10 @@ void ath10k_debug_tpc_stats_process(struct ath10k *ar,
 }
 
 static void ath10k_tpc_stats_print(struct ath10k_tpc_stats *tpc_stats,
-				   unsigned int j, char *buf, unsigned int *len)
+				   unsigned int j, char *buf, size_t *len)
 {
-	unsigned int i, buf_len;
+	int i;
+	size_t buf_len;
 	static const char table_str[][5] = { "CDD",
 					     "STBC",
 					     "TXBF" };
@@ -1726,7 +1724,8 @@ static void ath10k_tpc_stats_fill(struct ath10k *ar,
 				  struct ath10k_tpc_stats *tpc_stats,
 				  char *buf)
 {
-	unsigned int len, j, buf_len;
+	int j;
+	size_t len, buf_len;
 
 	len = 0;
 	buf_len = ATH10K_TPC_CONFIG_BUF_SIZE;
@@ -1860,7 +1859,7 @@ static ssize_t ath10k_tpc_stats_read(struct file *file, char __user *user_buf,
 				     size_t count, loff_t *ppos)
 {
 	const char *buf = file->private_data;
-	unsigned int len = strlen(buf);
+	size_t len = strlen(buf);
 
 	return simple_read_from_buffer(user_buf, count, ppos, buf, len);
 }
@@ -2284,7 +2283,7 @@ static ssize_t ath10k_debug_fw_checksums_read(struct file *file,
 					      size_t count, loff_t *ppos)
 {
 	struct ath10k *ar = file->private_data;
-	unsigned int len = 0, buf_len = 4096;
+	size_t len = 0, buf_len = 4096;
 	ssize_t ret_cnt;
 	char *buf;
 
@@ -2500,7 +2499,7 @@ void ath10k_dbg_dump(struct ath10k *ar,
 		     const void *buf, size_t len)
 {
 	char linebuf[256];
-	unsigned int linebuflen;
+	size_t linebuflen;
 	const void *ptr;
 
 	if (ath10k_debug_mask & mask) {
diff --git a/drivers/net/wireless/ath/ath10k/spectral.c b/drivers/net/wireless/ath/ath10k/spectral.c
index 2ffc1fe..c061d69 100644
--- a/drivers/net/wireless/ath/ath10k/spectral.c
+++ b/drivers/net/wireless/ath/ath10k/spectral.c
@@ -278,7 +278,7 @@ static ssize_t read_file_spec_scan_ctl(struct file *file, char __user *user_buf,
 {
 	struct ath10k *ar = file->private_data;
 	char *mode = "";
-	unsigned int len;
+	size_t len;
 	enum ath10k_spectral_mode spectral_mode;
 
 	mutex_lock(&ar->conf_mutex);
@@ -370,7 +370,7 @@ static ssize_t read_file_spectral_count(struct file *file,
 {
 	struct ath10k *ar = file->private_data;
 	char buf[32];
-	unsigned int len;
+	size_t len;
 	u8 spectral_count;
 
 	mutex_lock(&ar->conf_mutex);
@@ -422,7 +422,8 @@ static ssize_t read_file_spectral_bins(struct file *file,
 {
 	struct ath10k *ar = file->private_data;
 	char buf[32];
-	unsigned int len, bins, fft_size, bin_scale;
+	unsigned int bins, fft_size, bin_scale;
+	size_t len;
 
 	mutex_lock(&ar->conf_mutex);
 
-- 
1.9.1
