From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH] net: wireless: replace strict_strtoul() with kstrtoul()
Date: Sat, 01 Jun 2013 16:24:06 +0900
Message-ID: <000f01ce5e99$00617fc0$01247f40$@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jingoo Han <jg1.han@samsung.com>,
	"Luis R. Rodriguez" <mcgrof@qca.qualcomm.com>,
	'Jouni Malinen' <jouni@qca.qualcomm.com>,
	Vasanthakumar Thiagarajan <vthiagar@qca.qualcomm.com>,
	Senthil Balasubramanian <senthilb@qca.qualcomm.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Stanislaw Gruszka <sgruszka@redhat.com>,
	'Larry Finger' <Larry.Finger@lwfinger.net>,
	'Chaoming Li' <chaoming_li@realsil.com.cn>,
	linux-wireless@vger.kernel.org
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout4.samsung.com ([203.254.224.34]:60751 "EHLO
	mailout4.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750839Ab3FAHYJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Jun 2013 03:24:09 -0400
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The usage of strict_strtoul() is not preferred, because
strict_strtoul() is obsolete. Thus, kstrtoul() should be
used.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/wireless/ath/ath9k/debug.c         |   14 +++++++-------
 drivers/net/wireless/ath/ath9k/dfs_debug.c     |    2 +-
 drivers/net/wireless/ath/ath9k/htc_drv_debug.c |    2 +-
 drivers/net/wireless/iwlegacy/3945-mac.c       |    2 +-
 drivers/net/wireless/iwlegacy/4965-mac.c       |    4 ++--
 drivers/net/wireless/libertas/mesh.c           |    2 +-
 drivers/net/wireless/rtlwifi/base.c            |    2 +-
 7 files changed, 14 insertions(+), 14 deletions(-)

diff --git a/drivers/net/wireless/ath/ath9k/debug.c b/drivers/net/wireless/ath/ath9k/debug.c
index 53c0658..0399c897 100644
--- a/drivers/net/wireless/ath/ath9k/debug.c
+++ b/drivers/net/wireless/ath/ath9k/debug.c
@@ -69,7 +69,7 @@ static ssize_t write_file_debug(struct file *file, const char __user *user_buf,
 		return -EFAULT;
 
 	buf[len] = '\0';
-	if (strict_strtoul(buf, 0, &mask))
+	if (kstrtoul(buf, 0, &mask))
 		return -EINVAL;
 
 	common->debug_mask = mask;
@@ -114,7 +114,7 @@ static ssize_t write_file_tx_chainmask(struct file *file, const char __user *use
 		return -EFAULT;
 
 	buf[len] = '\0';
-	if (strict_strtoul(buf, 0, &mask))
+	if (kstrtoul(buf, 0, &mask))
 		return -EINVAL;
 
 	ah->txchainmask = mask;
@@ -157,7 +157,7 @@ static ssize_t write_file_rx_chainmask(struct file *file, const char __user *use
 		return -EFAULT;
 
 	buf[len] = '\0';
-	if (strict_strtoul(buf, 0, &mask))
+	if (kstrtoul(buf, 0, &mask))
 		return -EINVAL;
 
 	ah->rxchainmask = mask;
@@ -200,7 +200,7 @@ static ssize_t write_file_disable_ani(struct file *file,
 		return -EFAULT;
 
 	buf[len] = '\0';
-	if (strict_strtoul(buf, 0, &disable_ani))
+	if (kstrtoul(buf, 0, &disable_ani))
 		return -EINVAL;
 
 	common->disable_ani = !!disable_ani;
@@ -253,7 +253,7 @@ static ssize_t write_file_ant_diversity(struct file *file,
 		goto exit;
 
 	buf[len] = '\0';
-	if (strict_strtoul(buf, 0, &antenna_diversity))
+	if (kstrtoul(buf, 0, &antenna_diversity))
 		return -EINVAL;
 
 	common->antenna_diversity = !!antenna_diversity;
@@ -1223,7 +1223,7 @@ static ssize_t write_file_regidx(struct file *file, const char __user *user_buf,
 		return -EFAULT;
 
 	buf[len] = '\0';
-	if (strict_strtoul(buf, 0, &regidx))
+	if (kstrtoul(buf, 0, &regidx))
 		return -EINVAL;
 
 	sc->debug.regidx = regidx;
@@ -1268,7 +1268,7 @@ static ssize_t write_file_regval(struct file *file, const char __user *user_buf,
 		return -EFAULT;
 
 	buf[len] = '\0';
-	if (strict_strtoul(buf, 0, &regval))
+	if (kstrtoul(buf, 0, &regval))
 		return -EINVAL;
 
 	ath9k_ps_wakeup(sc);
diff --git a/drivers/net/wireless/ath/ath9k/dfs_debug.c b/drivers/net/wireless/ath/ath9k/dfs_debug.c
index b7611b7..3c6e413 100644
--- a/drivers/net/wireless/ath/ath9k/dfs_debug.c
+++ b/drivers/net/wireless/ath/ath9k/dfs_debug.c
@@ -96,7 +96,7 @@ static ssize_t write_file_dfs(struct file *file, const char __user *user_buf,
 		return -EFAULT;
 
 	buf[len] = '\0';
-	if (strict_strtoul(buf, 0, &val))
+	if (kstrtoul(buf, 0, &val))
 		return -EINVAL;
 
 	if (val == DFS_STATS_RESET_MAGIC)
diff --git a/drivers/net/wireless/ath/ath9k/htc_drv_debug.c b/drivers/net/wireless/ath/ath9k/htc_drv_debug.c
index 87110de5..d08ef24 100644
--- a/drivers/net/wireless/ath/ath9k/htc_drv_debug.c
+++ b/drivers/net/wireless/ath/ath9k/htc_drv_debug.c
@@ -471,7 +471,7 @@ static ssize_t write_file_debug(struct file *file, const char __user *user_buf,
 		return -EFAULT;
 
 	buf[len] = '\0';
-	if (strict_strtoul(buf, 0, &mask))
+	if (kstrtoul(buf, 0, &mask))
 		return -EINVAL;
 
 	common->debug_mask = mask;
diff --git a/drivers/net/wireless/iwlegacy/3945-mac.c b/drivers/net/wireless/iwlegacy/3945-mac.c
index b37a582..dce5e8f 100644
--- a/drivers/net/wireless/iwlegacy/3945-mac.c
+++ b/drivers/net/wireless/iwlegacy/3945-mac.c
@@ -3119,7 +3119,7 @@ il3945_store_debug_level(struct device *d, struct device_attribute *attr,
 	unsigned long val;
 	int ret;
 
-	ret = strict_strtoul(buf, 0, &val);
+	ret = kstrtoul(buf, 0, &val);
 	if (ret)
 		IL_INFO("%s is not in hex or decimal form.\n", buf);
 	else
diff --git a/drivers/net/wireless/iwlegacy/4965-mac.c b/drivers/net/wireless/iwlegacy/4965-mac.c
index 9a95045..3c4899b 100644
--- a/drivers/net/wireless/iwlegacy/4965-mac.c
+++ b/drivers/net/wireless/iwlegacy/4965-mac.c
@@ -4567,7 +4567,7 @@ il4965_store_debug_level(struct device *d, struct device_attribute *attr,
 	unsigned long val;
 	int ret;
 
-	ret = strict_strtoul(buf, 0, &val);
+	ret = kstrtoul(buf, 0, &val);
 	if (ret)
 		IL_ERR("%s is not in hex or decimal form.\n", buf);
 	else
@@ -4614,7 +4614,7 @@ il4965_store_tx_power(struct device *d, struct device_attribute *attr,
 	unsigned long val;
 	int ret;
 
-	ret = strict_strtoul(buf, 10, &val);
+	ret = kstrtoul(buf, 10, &val);
 	if (ret)
 		IL_INFO("%s is not in decimal form.\n", buf);
 	else {
diff --git a/drivers/net/wireless/libertas/mesh.c b/drivers/net/wireless/libertas/mesh.c
index 3e81264..efae07e 100644
--- a/drivers/net/wireless/libertas/mesh.c
+++ b/drivers/net/wireless/libertas/mesh.c
@@ -240,7 +240,7 @@ static ssize_t lbs_prb_rsp_limit_set(struct device *dev,
 	memset(&mesh_access, 0, sizeof(mesh_access));
 	mesh_access.data[0] = cpu_to_le32(CMD_ACT_SET);
 
-	if (!strict_strtoul(buf, 10, &retry_limit))
+	if (!kstrtoul(buf, 10, &retry_limit))
 		return -ENOTSUPP;
 	if (retry_limit > 15)
 		return -ENOTSUPP;
diff --git a/drivers/net/wireless/rtlwifi/base.c b/drivers/net/wireless/rtlwifi/base.c
index af59dd5..8053f77 100644
--- a/drivers/net/wireless/rtlwifi/base.c
+++ b/drivers/net/wireless/rtlwifi/base.c
@@ -1817,7 +1817,7 @@ static ssize_t rtl_store_debug_level(struct device *d,
 	unsigned long val;
 	int ret;
 
-	ret = strict_strtoul(buf, 0, &val);
+	ret = kstrtoul(buf, 0, &val);
 	if (ret) {
 		printk(KERN_DEBUG "%s is not in hex or decimal form.\n", buf);
 	} else {
-- 
1.7.10.4
