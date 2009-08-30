From: Marcel Holtmann <marcel@holtmann.org>
Subject: [PATCH 14/47] Bluetooth: Remove pointless casts from Marvell debugfs support
Date: Sun, 30 Aug 2009 01:50:28 -0700
Message-ID: <542399037d0cb2b2e96dfb8ced35b07dfb1c3706.1251621661.git.marcel@holtmann.org>
References: <cover.1251621661.git.marcel@holtmann.org>
 <fd0b3ff707dc1f7837079044bd4eca7ed505f70d.1251621661.git.marcel@holtmann.org>
 <981b1414d78a7a42cab48b97d4de54a62d61db88.1251621661.git.marcel@holtmann.org>
 <290ba200815fdecb4d40dc942499c4ea6d0c4624.1251621661.git.marcel@holtmann.org>
 <364f63519d94442ed373ac7da79033c8282df46a.1251621661.git.marcel@holtmann.org>
 <9eba32b86d17ef87131fa0bce43c614904ab5781.1251621661.git.marcel@holtmann.org>
 <edad63886993d18ab800c49f6587a93432ef8b35.1251621661.git.marcel@holtmann.org>
 <132ff4e5fa8dfb71a7d99902f88043113947e972.1251621661.git.marcel@holtmann.org>
 <789221ecc870117b77e354d488d5d29f15410de8.1251621661.git.marcel@holtmann.org>
 <fb784f0508d5aa39a23e72879a8dfb517c6f6e7f.1251621661.git.marcel@holtmann.org>
 <196be0cd018068d545e1d764094c7b07aaf0bcfe.1251621661.git.marcel@holtmann.org>
 <e7a25f9839fd392ec2c96e7e2b3734501d761a24.1251621661.git.marcel@holtmann.org>
 <08b0b0ce8c609b0e2284b134f0614e211374a038.1251621661.git.marcel@holtmann.org>
 <944fe798c6a48336e82bbc0d4e280587325a4d95.1251621661.git.marcel@holtmann.org>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:53286 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752896AbZH3IwI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Aug 2009 04:52:08 -0400
In-Reply-To: <944fe798c6a48336e82bbc0d4e280587325a4d95.1251621661.git.marcel@holtmann.org>
In-Reply-To: <cover.1251621661.git.marcel@holtmann.org>
References: <cover.1251621661.git.marcel@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Marvell Bluetooth driver has debugfs support and they are casting
like there is no tomorrow. Remove all of them and magically the code
becomes more readable.

Signed-off-by: Marcel Holtmann <marcel@holtmann.org>
---
 drivers/bluetooth/btmrvl_debugfs.c |  249 +++++++++++++++---------------------
 1 files changed, 106 insertions(+), 143 deletions(-)

diff --git a/drivers/bluetooth/btmrvl_debugfs.c b/drivers/bluetooth/btmrvl_debugfs.c
index 747bb0c..4617bd1 100644
--- a/drivers/bluetooth/btmrvl_debugfs.c
+++ b/drivers/bluetooth/btmrvl_debugfs.c
@@ -51,20 +51,15 @@ static int btmrvl_open_generic(struct inode *inode, struct file *file)
 }
 
 static ssize_t btmrvl_hscfgcmd_write(struct file *file,
-					const char __user *ubuf,
-					size_t count,
-					loff_t *ppos)
+			const char __user *ubuf, size_t count, loff_t *ppos)
 {
-	struct btmrvl_private *priv =
-				(struct btmrvl_private *) file->private_data;
-
-	long result, ret;
+	struct btmrvl_private *priv = file->private_data;
 	char buf[16];
+	long result, ret;
 
 	memset(buf, 0, sizeof(buf));
 
-	if (copy_from_user(&buf, ubuf,
-				min_t(size_t, sizeof(buf) - 1, count)))
+	if (copy_from_user(&buf, ubuf, min_t(size_t, sizeof(buf) - 1, count)))
 		return -EFAULT;
 
 	ret = strict_strtol(buf, 10, &result);
@@ -79,38 +74,35 @@ static ssize_t btmrvl_hscfgcmd_write(struct file *file,
 	return count;
 }
 
-static ssize_t btmrvl_hscfgcmd_read(struct file *file, char __user * userbuf,
-				    size_t count, loff_t *ppos)
+static ssize_t btmrvl_hscfgcmd_read(struct file *file, char __user *userbuf,
+						size_t count, loff_t *ppos)
 {
-	struct btmrvl_private *priv =
-				(struct btmrvl_private *) file->private_data;
-	int ret;
+	struct btmrvl_private *priv = file->private_data;
 	char buf[16];
+	int ret;
 
 	ret = snprintf(buf, sizeof(buf) - 1, "%d\n",
-			priv->btmrvl_dev.hscfgcmd);
+						priv->btmrvl_dev.hscfgcmd);
 
 	return simple_read_from_buffer(userbuf, count, ppos, buf, ret);
 }
 
 static const struct file_operations btmrvl_hscfgcmd_fops = {
-	.read = btmrvl_hscfgcmd_read,
-	.write = btmrvl_hscfgcmd_write,
-	.open = btmrvl_open_generic,
+	.read	= btmrvl_hscfgcmd_read,
+	.write	= btmrvl_hscfgcmd_write,
+	.open	= btmrvl_open_generic,
 };
 
 static ssize_t btmrvl_psmode_write(struct file *file, const char __user *ubuf,
-				   size_t count, loff_t *ppos)
+						size_t count, loff_t *ppos)
 {
-	struct btmrvl_private *priv =
-				(struct btmrvl_private *) file->private_data;
-	long result, ret;
+	struct btmrvl_private *priv = file->private_data;
 	char buf[16];
+	long result, ret;
 
 	memset(buf, 0, sizeof(buf));
 
-	if (copy_from_user(&buf, ubuf,
-				min_t(size_t, sizeof(buf) - 1, count)))
+	if (copy_from_user(&buf, ubuf, min_t(size_t, sizeof(buf) - 1, count)))
 		return -EFAULT;
 
 	ret = strict_strtol(buf, 10, &result);
@@ -120,38 +112,35 @@ static ssize_t btmrvl_psmode_write(struct file *file, const char __user *ubuf,
 	return count;
 }
 
-static ssize_t btmrvl_psmode_read(struct file *file, char __user * userbuf,
-				  size_t count, loff_t *ppos)
+static ssize_t btmrvl_psmode_read(struct file *file, char __user *userbuf,
+						size_t count, loff_t *ppos)
 {
-	struct btmrvl_private *priv =
-				(struct btmrvl_private *) file->private_data;
-	int ret;
+	struct btmrvl_private *priv = file->private_data;
 	char buf[16];
+	int ret;
 
 	ret = snprintf(buf, sizeof(buf) - 1, "%d\n",
-			priv->btmrvl_dev.psmode);
+						priv->btmrvl_dev.psmode);
 
 	return simple_read_from_buffer(userbuf, count, ppos, buf, ret);
 }
 
 static const struct file_operations btmrvl_psmode_fops = {
-	.read = btmrvl_psmode_read,
-	.write = btmrvl_psmode_write,
-	.open = btmrvl_open_generic,
+	.read	= btmrvl_psmode_read,
+	.write	= btmrvl_psmode_write,
+	.open	= btmrvl_open_generic,
 };
 
 static ssize_t btmrvl_pscmd_write(struct file *file, const char __user *ubuf,
-				  size_t count, loff_t *ppos)
+						size_t count, loff_t *ppos)
 {
-	struct btmrvl_private *priv =
-				(struct btmrvl_private *) file->private_data;
-	long result, ret;
+	struct btmrvl_private *priv = file->private_data;
 	char buf[16];
+	long result, ret;
 
 	memset(buf, 0, sizeof(buf));
 
-	if (copy_from_user(&buf, ubuf,
-				min_t(size_t, sizeof(buf) - 1, count)))
+	if (copy_from_user(&buf, ubuf, min_t(size_t, sizeof(buf) - 1, count)))
 		return -EFAULT;
 
 	ret = strict_strtol(buf, 10, &result);
@@ -167,13 +156,12 @@ static ssize_t btmrvl_pscmd_write(struct file *file, const char __user *ubuf,
 
 }
 
-static ssize_t btmrvl_pscmd_read(struct file *file, char __user * userbuf,
-				 size_t count, loff_t *ppos)
+static ssize_t btmrvl_pscmd_read(struct file *file, char __user *userbuf,
+						size_t count, loff_t *ppos)
 {
-	struct btmrvl_private *priv =
-				(struct btmrvl_private *) file->private_data;
-	int ret;
+	struct btmrvl_private *priv = file->private_data;
 	char buf[16];
+	int ret;
 
 	ret = snprintf(buf, sizeof(buf) - 1, "%d\n", priv->btmrvl_dev.pscmd);
 
@@ -187,17 +175,15 @@ static const struct file_operations btmrvl_pscmd_fops = {
 };
 
 static ssize_t btmrvl_gpiogap_write(struct file *file, const char __user *ubuf,
-				    size_t count, loff_t *ppos)
+						size_t count, loff_t *ppos)
 {
-	struct btmrvl_private *priv =
-				(struct btmrvl_private *) file->private_data;
-	long result, ret;
+	struct btmrvl_private *priv = file->private_data;
 	char buf[16];
+	long result, ret;
 
 	memset(buf, 0, sizeof(buf));
 
-	if (copy_from_user(&buf, ubuf,
-				min_t(size_t, sizeof(buf) - 1, count)))
+	if (copy_from_user(&buf, ubuf, min_t(size_t, sizeof(buf) - 1, count)))
 		return -EFAULT;
 
 	ret = strict_strtol(buf, 16, &result);
@@ -207,38 +193,35 @@ static ssize_t btmrvl_gpiogap_write(struct file *file, const char __user *ubuf,
 	return count;
 }
 
-static ssize_t btmrvl_gpiogap_read(struct file *file, char __user * userbuf,
-				   size_t count, loff_t *ppos)
+static ssize_t btmrvl_gpiogap_read(struct file *file, char __user *userbuf,
+						size_t count, loff_t *ppos)
 {
-	struct btmrvl_private *priv =
-				(struct btmrvl_private *) file->private_data;
-	int ret;
+	struct btmrvl_private *priv = file->private_data;
 	char buf[16];
+	int ret;
 
 	ret = snprintf(buf, sizeof(buf) - 1, "0x%x\n",
-			priv->btmrvl_dev.gpio_gap);
+						priv->btmrvl_dev.gpio_gap);
 
 	return simple_read_from_buffer(userbuf, count, ppos, buf, ret);
 }
 
 static const struct file_operations btmrvl_gpiogap_fops = {
-	.read = btmrvl_gpiogap_read,
-	.write = btmrvl_gpiogap_write,
-	.open = btmrvl_open_generic,
+	.read	= btmrvl_gpiogap_read,
+	.write	= btmrvl_gpiogap_write,
+	.open	= btmrvl_open_generic,
 };
 
 static ssize_t btmrvl_hscmd_write(struct file *file, const char __user *ubuf,
-				  size_t count, loff_t *ppos)
+						size_t count, loff_t *ppos)
 {
-	struct btmrvl_private *priv =
-				(struct btmrvl_private *) file->private_data;
-	long result, ret;
+	struct btmrvl_private *priv = (struct btmrvl_private *) file->private_data;
 	char buf[16];
+	long result, ret;
 
 	memset(buf, 0, sizeof(buf));
 
-	if (copy_from_user(&buf, ubuf,
-				min_t(size_t, sizeof(buf) - 1, count)))
+	if (copy_from_user(&buf, ubuf, min_t(size_t, sizeof(buf) - 1, count)))
 		return -EFAULT;
 
 	ret = strict_strtol(buf, 10, &result);
@@ -252,13 +235,12 @@ static ssize_t btmrvl_hscmd_write(struct file *file, const char __user *ubuf,
 	return count;
 }
 
-static ssize_t btmrvl_hscmd_read(struct file *file, char __user * userbuf,
-				 size_t count, loff_t *ppos)
+static ssize_t btmrvl_hscmd_read(struct file *file, char __user *userbuf,
+						size_t count, loff_t *ppos)
 {
-	struct btmrvl_private *priv =
-				(struct btmrvl_private *) file->private_data;
-	int ret;
+	struct btmrvl_private *priv = file->private_data;
 	char buf[16];
+	int ret;
 
 	ret = snprintf(buf, sizeof(buf) - 1, "%d\n", priv->btmrvl_dev.hscmd);
 
@@ -266,23 +248,21 @@ static ssize_t btmrvl_hscmd_read(struct file *file, char __user * userbuf,
 }
 
 static const struct file_operations btmrvl_hscmd_fops = {
-	.read = btmrvl_hscmd_read,
-	.write = btmrvl_hscmd_write,
-	.open = btmrvl_open_generic,
+	.read	= btmrvl_hscmd_read,
+	.write	= btmrvl_hscmd_write,
+	.open	= btmrvl_open_generic,
 };
 
 static ssize_t btmrvl_hsmode_write(struct file *file, const char __user *ubuf,
-				   size_t count, loff_t *ppos)
+						size_t count, loff_t *ppos)
 {
-	struct btmrvl_private *priv =
-				(struct btmrvl_private *) file->private_data;
-	long result, ret;
+	struct btmrvl_private *priv = file->private_data;
 	char buf[16];
+	long result, ret;
 
 	memset(buf, 0, sizeof(buf));
 
-	if (copy_from_user(&buf, ubuf,
-				min_t(size_t, sizeof(buf) - 1, count)))
+	if (copy_from_user(&buf, ubuf, min_t(size_t, sizeof(buf) - 1, count)))
 		return -EFAULT;
 
 	ret = strict_strtol(buf, 10, &result);
@@ -293,32 +273,29 @@ static ssize_t btmrvl_hsmode_write(struct file *file, const char __user *ubuf,
 }
 
 static ssize_t btmrvl_hsmode_read(struct file *file, char __user * userbuf,
-				  size_t count, loff_t *ppos)
+						size_t count, loff_t *ppos)
 {
-	struct btmrvl_private *priv =
-				(struct btmrvl_private *) file->private_data;
-	int ret;
+	struct btmrvl_private *priv = file->private_data;
 	char buf[16];
+	int ret;
 
-	ret = snprintf(buf, sizeof(buf) - 1, "%d\n",
-			priv->btmrvl_dev.hsmode);
+	ret = snprintf(buf, sizeof(buf) - 1, "%d\n", priv->btmrvl_dev.hsmode);
 
 	return simple_read_from_buffer(userbuf, count, ppos, buf, ret);
 }
 
 static const struct file_operations btmrvl_hsmode_fops = {
-	.read = btmrvl_hsmode_read,
-	.write = btmrvl_hsmode_write,
-	.open = btmrvl_open_generic,
+	.read	= btmrvl_hsmode_read,
+	.write	= btmrvl_hsmode_write,
+	.open	= btmrvl_open_generic,
 };
 
-static ssize_t btmrvl_curpsmode_read(struct file *file, char __user * userbuf,
-				     size_t count, loff_t *ppos)
+static ssize_t btmrvl_curpsmode_read(struct file *file, char __user *userbuf,
+						size_t count, loff_t *ppos)
 {
-	struct btmrvl_private *priv =
-				(struct btmrvl_private *) file->private_data;
-	int ret;
+	struct btmrvl_private *priv = file->private_data;
 	char buf[16];
+	int ret;
 
 	ret = snprintf(buf, sizeof(buf) - 1, "%d\n", priv->adapter->psmode);
 
@@ -326,71 +303,65 @@ static ssize_t btmrvl_curpsmode_read(struct file *file, char __user * userbuf,
 }
 
 static const struct file_operations btmrvl_curpsmode_fops = {
-	.read = btmrvl_curpsmode_read,
-	.open = btmrvl_open_generic,
+	.read	= btmrvl_curpsmode_read,
+	.open	= btmrvl_open_generic,
 };
 
 static ssize_t btmrvl_psstate_read(struct file *file, char __user * userbuf,
-				   size_t count, loff_t *ppos)
+						size_t count, loff_t *ppos)
 {
-	struct btmrvl_private *priv =
-				(struct btmrvl_private *) file->private_data;
-	int ret;
+	struct btmrvl_private *priv = file->private_data;
 	char buf[16];
+	int ret;
 
-	ret = snprintf(buf, sizeof(buf) - 1, "%d\n",
-			priv->adapter->ps_state);
+	ret = snprintf(buf, sizeof(buf) - 1, "%d\n", priv->adapter->ps_state);
 
 	return simple_read_from_buffer(userbuf, count, ppos, buf, ret);
 }
 
 static const struct file_operations btmrvl_psstate_fops = {
-	.read = btmrvl_psstate_read,
-	.open = btmrvl_open_generic,
+	.read	= btmrvl_psstate_read,
+	.open	= btmrvl_open_generic,
 };
 
-static ssize_t btmrvl_hsstate_read(struct file *file, char __user * userbuf,
-				   size_t count, loff_t *ppos)
+static ssize_t btmrvl_hsstate_read(struct file *file, char __user *userbuf,
+						size_t count, loff_t *ppos)
 {
-	struct btmrvl_private *priv =
-				(struct btmrvl_private *) file->private_data;
-	int ret;
+	struct btmrvl_private *priv = file->private_data;
 	char buf[16];
+	int ret;
 
-	ret = snprintf(buf, sizeof(buf) - 1, "%d\n",
-			priv->adapter->hs_state);
+	ret = snprintf(buf, sizeof(buf) - 1, "%d\n", priv->adapter->hs_state);
 
 	return simple_read_from_buffer(userbuf, count, ppos, buf, ret);
 }
 
 static const struct file_operations btmrvl_hsstate_fops = {
-	.read = btmrvl_hsstate_read,
-	.open = btmrvl_open_generic,
+	.read	= btmrvl_hsstate_read,
+	.open	= btmrvl_open_generic,
 };
 
-static ssize_t btmrvl_txdnldready_read(struct file *file, char __user * userbuf,
-				       size_t count, loff_t *ppos)
+static ssize_t btmrvl_txdnldready_read(struct file *file, char __user *userbuf,
+						size_t count, loff_t *ppos)
 {
-	struct btmrvl_private *priv =
-				(struct btmrvl_private *) file->private_data;
-	int ret;
+	struct btmrvl_private *priv = file->private_data;
 	char buf[16];
+	int ret;
 
 	ret = snprintf(buf, sizeof(buf) - 1, "%d\n",
-			priv->btmrvl_dev.tx_dnld_rdy);
+					priv->btmrvl_dev.tx_dnld_rdy);
 
 	return simple_read_from_buffer(userbuf, count, ppos, buf, ret);
 }
 
 static const struct file_operations btmrvl_txdnldready_fops = {
-	.read = btmrvl_txdnldready_read,
-	.open = btmrvl_open_generic,
+	.read	= btmrvl_txdnldready_read,
+	.open	= btmrvl_open_generic,
 };
 
 void btmrvl_debugfs_init(struct hci_dev *hdev)
 {
-	struct btmrvl_private *priv =
-				(struct btmrvl_private *) hdev->driver_data;
+	struct btmrvl_private *priv = hdev->driver_data;
 	struct btmrvl_debugfs_data *dbg;
 
 	dbg = kzalloc(sizeof(*dbg), GFP_KERNEL);
@@ -406,22 +377,16 @@ void btmrvl_debugfs_init(struct hci_dev *hdev)
 	dbg->config_dir = debugfs_create_dir("config", dbg->root_dir);
 
 	dbg->psmode = debugfs_create_file("psmode", 0644, dbg->config_dir,
-					  hdev->driver_data,
-					  &btmrvl_psmode_fops);
-	dbg->pscmd =
-	    debugfs_create_file("pscmd", 0644, dbg->config_dir,
+				hdev->driver_data, &btmrvl_psmode_fops);
+	dbg->pscmd = debugfs_create_file("pscmd", 0644, dbg->config_dir,
 				hdev->driver_data, &btmrvl_pscmd_fops);
-	dbg->gpiogap =
-	    debugfs_create_file("gpiogap", 0644, dbg->config_dir,
+	dbg->gpiogap = debugfs_create_file("gpiogap", 0644, dbg->config_dir,
 				hdev->driver_data, &btmrvl_gpiogap_fops);
-	dbg->hsmode =
-	    debugfs_create_file("hsmode", 0644, dbg->config_dir,
+	dbg->hsmode =  debugfs_create_file("hsmode", 0644, dbg->config_dir,
 				hdev->driver_data, &btmrvl_hsmode_fops);
-	dbg->hscmd =
-	    debugfs_create_file("hscmd", 0644, dbg->config_dir,
+	dbg->hscmd = debugfs_create_file("hscmd", 0644, dbg->config_dir,
 				hdev->driver_data, &btmrvl_hscmd_fops);
-	dbg->hscfgcmd =
-	    debugfs_create_file("hscfgcmd", 0644, dbg->config_dir,
+	dbg->hscfgcmd = debugfs_create_file("hscfgcmd", 0644, dbg->config_dir,
 				hdev->driver_data, &btmrvl_hscfgcmd_fops);
 
 	dbg->status_dir = debugfs_create_dir("status", dbg->root_dir);
@@ -429,21 +394,19 @@ void btmrvl_debugfs_init(struct hci_dev *hdev)
 						dbg->status_dir,
 						hdev->driver_data,
 						&btmrvl_curpsmode_fops);
-	dbg->psstate =
-	    debugfs_create_file("psstate", 0444, dbg->status_dir,
+	dbg->psstate = debugfs_create_file("psstate", 0444, dbg->status_dir,
 				hdev->driver_data, &btmrvl_psstate_fops);
-	dbg->hsstate =
-	    debugfs_create_file("hsstate", 0444, dbg->status_dir,
+	dbg->hsstate = debugfs_create_file("hsstate", 0444, dbg->status_dir,
 				hdev->driver_data, &btmrvl_hsstate_fops);
-	dbg->txdnldready =
-	    debugfs_create_file("txdnldready", 0444, dbg->status_dir,
-				hdev->driver_data, &btmrvl_txdnldready_fops);
+	dbg->txdnldready = debugfs_create_file("txdnldready", 0444,
+						dbg->status_dir,
+						hdev->driver_data,
+						&btmrvl_txdnldready_fops);
 }
 
 void btmrvl_debugfs_remove(struct hci_dev *hdev)
 {
-	struct btmrvl_private *priv =
-				(struct btmrvl_private *) hdev->driver_data;
+	struct btmrvl_private *priv = hdev->driver_data;
 	struct btmrvl_debugfs_data *dbg = priv->debugfs_data;
 
 	if (!dbg)
-- 
1.6.2.5

