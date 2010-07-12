From: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH 14/36] drivers/net/wireless: Remove unnecessary casts of private_data
Date: Mon, 12 Jul 2010 13:50:06 -0700
Message-ID: <76fc6e08df3304c90934852cc82427380f829676.1278967120.git.joe@perches.com>
References: <cover.1278967120.git.joe@perches.com>
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	"Luis R. Rodriguez" <lrodriguez-DlyHzToyqoxBDgjK7y7TUQ@public.gmane.org>,
	Jouni Malinen <jmalinen-DlyHzToyqoxBDgjK7y7TUQ@public.gmane.org>,
	Sujith Manoharan <Sujith.Manoharan-DlyHzToyqoxBDgjK7y7TUQ@public.gmane.org>,
	Vasanthakumar Thiagarajan <vasanth-DlyHzToyqoxBDgjK7y7TUQ@public.gmane.org>,
	Senthil Balasubramanian <senthilkumar-DlyHzToyqoxBDgjK7y7TUQ@public.gmane.org>,
	Reinette Chatre <reinette.chatre-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Wey-Yi Guy <wey-yi.w.guy-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Intel Linux Wireless <ilw-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ath9k-devel-xDcbHBWguxHbcTqmT+pZeQ@public.gmane.org,
	libertas-dev-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
To: Jiri Kosina <trivial-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <cover.1278967120.git.joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
---
 drivers/net/wireless/airo.c                   |   22 +++++++++++-----------
 drivers/net/wireless/ath/ath9k/htc_drv_main.c |    9 +++------
 drivers/net/wireless/iwlwifi/iwl-debugfs.c    |   10 +++++-----
 drivers/net/wireless/libertas/debugfs.c       |    4 ++--
 4 files changed, 21 insertions(+), 24 deletions(-)

diff --git a/drivers/net/wireless/airo.c b/drivers/net/wireless/airo.c
index 6b605df..115442b 100644
--- a/drivers/net/wireless/airo.c
+++ b/drivers/net/wireless/airo.c
@@ -4657,7 +4657,7 @@ static ssize_t proc_write( struct file *file,
 			   loff_t *offset )
 {
 	loff_t pos = *offset;
-	struct proc_data *priv = (struct proc_data*)file->private_data;
+	struct proc_data *priv = file->private_data;
 
 	if (!priv->wbuffer)
 		return -EINVAL;
@@ -4689,7 +4689,7 @@ static int proc_status_open(struct inode *inode, struct file *file)
 
 	if ((file->private_data = kzalloc(sizeof(struct proc_data ), GFP_KERNEL)) == NULL)
 		return -ENOMEM;
-	data = (struct proc_data *)file->private_data;
+	data = file->private_data;
 	if ((data->rbuffer = kmalloc( 2048, GFP_KERNEL )) == NULL) {
 		kfree (file->private_data);
 		return -ENOMEM;
@@ -4772,7 +4772,7 @@ static int proc_stats_rid_open( struct inode *inode,
 
 	if ((file->private_data = kzalloc(sizeof(struct proc_data ), GFP_KERNEL)) == NULL)
 		return -ENOMEM;
-	data = (struct proc_data *)file->private_data;
+	data = file->private_data;
 	if ((data->rbuffer = kmalloc( 4096, GFP_KERNEL )) == NULL) {
 		kfree (file->private_data);
 		return -ENOMEM;
@@ -5045,7 +5045,7 @@ static int proc_config_open(struct inode *inode, struct file *file)
 
 	if ((file->private_data = kzalloc(sizeof(struct proc_data ), GFP_KERNEL)) == NULL)
 		return -ENOMEM;
-	data = (struct proc_data *)file->private_data;
+	data = file->private_data;
 	if ((data->rbuffer = kmalloc( 2048, GFP_KERNEL )) == NULL) {
 		kfree (file->private_data);
 		return -ENOMEM;
@@ -5127,7 +5127,7 @@ static int proc_config_open(struct inode *inode, struct file *file)
 
 static void proc_SSID_on_close(struct inode *inode, struct file *file)
 {
-	struct proc_data *data = (struct proc_data *)file->private_data;
+	struct proc_data *data = file->private_data;
 	struct proc_dir_entry *dp = PDE(inode);
 	struct net_device *dev = dp->data;
 	struct airo_info *ai = dev->ml_priv;
@@ -5163,7 +5163,7 @@ static void proc_SSID_on_close(struct inode *inode, struct file *file)
 }
 
 static void proc_APList_on_close( struct inode *inode, struct file *file ) {
-	struct proc_data *data = (struct proc_data *)file->private_data;
+	struct proc_data *data = file->private_data;
 	struct proc_dir_entry *dp = PDE(inode);
 	struct net_device *dev = dp->data;
 	struct airo_info *ai = dev->ml_priv;
@@ -5309,7 +5309,7 @@ static void proc_wepkey_on_close( struct inode *inode, struct file *file ) {
 
 	memset(key, 0, sizeof(key));
 
-	data = (struct proc_data *)file->private_data;
+	data = file->private_data;
 	if ( !data->writelen ) return;
 
 	if (data->wbuffer[0] >= '0' && data->wbuffer[0] <= '3' &&
@@ -5363,7 +5363,7 @@ static int proc_wepkey_open( struct inode *inode, struct file *file )
 	if ((file->private_data = kzalloc(sizeof(struct proc_data ), GFP_KERNEL)) == NULL)
 		return -ENOMEM;
 	memset(&wkr, 0, sizeof(wkr));
-	data = (struct proc_data *)file->private_data;
+	data = file->private_data;
 	if ((data->rbuffer = kzalloc( 180, GFP_KERNEL )) == NULL) {
 		kfree (file->private_data);
 		return -ENOMEM;
@@ -5409,7 +5409,7 @@ static int proc_SSID_open(struct inode *inode, struct file *file)
 
 	if ((file->private_data = kzalloc(sizeof(struct proc_data ), GFP_KERNEL)) == NULL)
 		return -ENOMEM;
-	data = (struct proc_data *)file->private_data;
+	data = file->private_data;
 	if ((data->rbuffer = kmalloc( 104, GFP_KERNEL )) == NULL) {
 		kfree (file->private_data);
 		return -ENOMEM;
@@ -5453,7 +5453,7 @@ static int proc_APList_open( struct inode *inode, struct file *file ) {
 
 	if ((file->private_data = kzalloc(sizeof(struct proc_data ), GFP_KERNEL)) == NULL)
 		return -ENOMEM;
-	data = (struct proc_data *)file->private_data;
+	data = file->private_data;
 	if ((data->rbuffer = kmalloc( 104, GFP_KERNEL )) == NULL) {
 		kfree (file->private_data);
 		return -ENOMEM;
@@ -5495,7 +5495,7 @@ static int proc_BSSList_open( struct inode *inode, struct file *file ) {
 
 	if ((file->private_data = kzalloc(sizeof(struct proc_data ), GFP_KERNEL)) == NULL)
 		return -ENOMEM;
-	data = (struct proc_data *)file->private_data;
+	data = file->private_data;
 	if ((data->rbuffer = kmalloc( 1024, GFP_KERNEL )) == NULL) {
 		kfree (file->private_data);
 		return -ENOMEM;
diff --git a/drivers/net/wireless/ath/ath9k/htc_drv_main.c b/drivers/net/wireless/ath/ath9k/htc_drv_main.c
index e38ca66..47f7603 100644
--- a/drivers/net/wireless/ath/ath9k/htc_drv_main.c
+++ b/drivers/net/wireless/ath/ath9k/htc_drv_main.c
@@ -492,8 +492,7 @@ static int ath9k_debugfs_open(struct inode *inode, struct file *file)
 static ssize_t read_file_tgt_stats(struct file *file, char __user *user_buf,
 				   size_t count, loff_t *ppos)
 {
-	struct ath9k_htc_priv *priv =
-		(struct ath9k_htc_priv *) file->private_data;
+	struct ath9k_htc_priv *priv = file->private_data;
 	struct ath9k_htc_target_stats cmd_rsp;
 	char buf[512];
 	unsigned int len = 0;
@@ -536,8 +535,7 @@ static const struct file_operations fops_tgt_stats = {
 static ssize_t read_file_xmit(struct file *file, char __user *user_buf,
 			      size_t count, loff_t *ppos)
 {
-	struct ath9k_htc_priv *priv =
-		(struct ath9k_htc_priv *) file->private_data;
+	struct ath9k_htc_priv *priv = file->private_data;
 	char buf[512];
 	unsigned int len = 0;
 
@@ -582,8 +580,7 @@ static const struct file_operations fops_xmit = {
 static ssize_t read_file_recv(struct file *file, char __user *user_buf,
 			      size_t count, loff_t *ppos)
 {
-	struct ath9k_htc_priv *priv =
-		(struct ath9k_htc_priv *) file->private_data;
+	struct ath9k_htc_priv *priv = file->private_data;
 	char buf[512];
 	unsigned int len = 0;
 
diff --git a/drivers/net/wireless/iwlwifi/iwl-debugfs.c b/drivers/net/wireless/iwlwifi/iwl-debugfs.c
index 088a2c1..7b25d14 100644
--- a/drivers/net/wireless/iwlwifi/iwl-debugfs.c
+++ b/drivers/net/wireless/iwlwifi/iwl-debugfs.c
@@ -1267,7 +1267,7 @@ static ssize_t iwl_dbgfs_ucode_tracing_read(struct file *file,
 					char __user *user_buf,
 					size_t count, loff_t *ppos) {
 
-	struct iwl_priv *priv = (struct iwl_priv *)file->private_data;
+	struct iwl_priv *priv = file->private_data;
 	int pos = 0;
 	char buf[128];
 	const size_t bufsz = sizeof(buf);
@@ -1317,7 +1317,7 @@ static ssize_t iwl_dbgfs_rxon_flags_read(struct file *file,
 					 char __user *user_buf,
 					 size_t count, loff_t *ppos) {
 
-	struct iwl_priv *priv = (struct iwl_priv *)file->private_data;
+	struct iwl_priv *priv = file->private_data;
 	int len = 0;
 	char buf[20];
 
@@ -1329,7 +1329,7 @@ static ssize_t iwl_dbgfs_rxon_filter_flags_read(struct file *file,
 						char __user *user_buf,
 						size_t count, loff_t *ppos) {
 
-	struct iwl_priv *priv = (struct iwl_priv *)file->private_data;
+	struct iwl_priv *priv = file->private_data;
 	int len = 0;
 	char buf[20];
 
@@ -1342,7 +1342,7 @@ static ssize_t iwl_dbgfs_fh_reg_read(struct file *file,
 					 char __user *user_buf,
 					 size_t count, loff_t *ppos)
 {
-	struct iwl_priv *priv = (struct iwl_priv *)file->private_data;
+	struct iwl_priv *priv = file->private_data;
 	char *buf;
 	int pos = 0;
 	ssize_t ret = -EFAULT;
@@ -1404,7 +1404,7 @@ static ssize_t iwl_dbgfs_plcp_delta_read(struct file *file,
 					char __user *user_buf,
 					size_t count, loff_t *ppos) {
 
-	struct iwl_priv *priv = (struct iwl_priv *)file->private_data;
+	struct iwl_priv *priv = file->private_data;
 	int pos = 0;
 	char buf[12];
 	const size_t bufsz = sizeof(buf);
diff --git a/drivers/net/wireless/libertas/debugfs.c b/drivers/net/wireless/libertas/debugfs.c
index 1736746..667695b 100644
--- a/drivers/net/wireless/libertas/debugfs.c
+++ b/drivers/net/wireless/libertas/debugfs.c
@@ -839,7 +839,7 @@ static ssize_t lbs_debugfs_read(struct file *file, char __user *userbuf,
 
 	p = buf;
 
-	d = (struct debug_data *)file->private_data;
+	d = file->private_data;
 
 	for (i = 0; i < num_of_items; i++) {
 		if (d[i].size == 1)
@@ -878,7 +878,7 @@ static ssize_t lbs_debugfs_write(struct file *f, const char __user *buf,
 	char *p0;
 	char *p1;
 	char *p2;
-	struct debug_data *d = (struct debug_data *)f->private_data;
+	struct debug_data *d = f->private_data;
 
 	pdata = kmalloc(cnt, GFP_KERNEL);
 	if (pdata == NULL)
-- 
1.7.1.337.g6068.dirty

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
