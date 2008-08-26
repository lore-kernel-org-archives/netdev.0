From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: [PATCH 1/15] netdevice: safe convert to netdev_priv() #part-15
Date: Tue, 26 Aug 2008 22:19:19 +0800
Message-ID: <48B410E7.706@cn.fujitsu.com>
References: <48B3D717.7070706@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>,
	NETDEV <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:58993 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1757175AbYHZOVq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Aug 2008 10:21:46 -0400
In-Reply-To: <48B3D717.7070706@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
diff --git a/drivers/net/wan/x25_asy.c b/drivers/net/wan/x25_asy.c
index 2a6c7a6..9c453ae 100644
--- a/drivers/net/wan/x25_asy.c
+++ b/drivers/net/wan/x25_asy.c
@@ -64,7 +64,7 @@ static struct x25_asy *x25_asy_alloc(void)
 		if (dev == NULL)
 			break;
 
-		sl = dev->priv;
+		sl = netdev_priv(dev);
 		/* Not in use ? */
 		if (!test_and_set_bit(SLF_INUSE, &sl->flags))
 			return sl;
@@ -86,7 +86,7 @@ static struct x25_asy *x25_asy_alloc(void)
 			return NULL;
 
 		/* Initialize channel control data */
-		sl = dev->priv;
+		sl = netdev_priv(dev);
 		dev->base_addr    = i;
 
 		/* register device so that it can be ifconfig'ed       */
@@ -120,7 +120,7 @@ static void x25_asy_free(struct x25_asy *sl)
 
 static int x25_asy_change_mtu(struct net_device *dev, int newmtu)
 {
-	struct x25_asy *sl = dev->priv;
+	struct x25_asy *sl = netdev_priv(dev);
 	unsigned char *xbuff, *rbuff;
 	int len = 2 * newmtu;
 
@@ -280,7 +280,7 @@ static void x25_asy_write_wakeup(struct tty_struct *tty)
 
 static void x25_asy_timeout(struct net_device *dev)
 {
-	struct x25_asy *sl = dev->priv;
+	struct x25_asy *sl = netdev_priv(dev);
 
 	spin_lock(&sl->lock);
 	if (netif_queue_stopped(dev)) {
@@ -301,7 +301,7 @@ static void x25_asy_timeout(struct net_device *dev)
 
 static int x25_asy_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	struct x25_asy *sl = dev->priv;
+	struct x25_asy *sl = netdev_priv(dev);
 	int err;
 
 	if (!netif_running(sl->dev)) {
@@ -373,7 +373,7 @@ static int x25_asy_data_indication(struct net_device *dev, struct sk_buff *skb)
 
 static void x25_asy_data_transmit(struct net_device *dev, struct sk_buff *skb)
 {
-	struct x25_asy *sl = dev->priv;
+	struct x25_asy *sl = netdev_priv(dev);
 
 	spin_lock(&sl->lock);
 	if (netif_queue_stopped(sl->dev) || sl->tty == NULL) {
@@ -398,7 +398,7 @@ static void x25_asy_data_transmit(struct net_device *dev, struct sk_buff *skb)
 
 static void x25_asy_connected(struct net_device *dev, int reason)
 {
-	struct x25_asy *sl = dev->priv;
+	struct x25_asy *sl = netdev_priv(dev);
 	struct sk_buff *skb;
 	unsigned char *ptr;
 
@@ -418,7 +418,7 @@ static void x25_asy_connected(struct net_device *dev, int reason)
 
 static void x25_asy_disconnected(struct net_device *dev, int reason)
 {
-	struct x25_asy *sl = dev->priv;
+	struct x25_asy *sl = netdev_priv(dev);
 	struct sk_buff *skb;
 	unsigned char *ptr;
 
@@ -450,7 +450,7 @@ static struct lapb_register_struct x25_asy_callbacks = {
 /* Open the low-level part of the X.25 channel. Easy! */
 static int x25_asy_open(struct net_device *dev)
 {
-	struct x25_asy *sl = dev->priv;
+	struct x25_asy *sl = netdev_priv(dev);
 	unsigned long len;
 	int err;
 
@@ -499,7 +499,7 @@ norbuff:
 /* Close the low-level part of the X.25 channel. Easy! */
 static int x25_asy_close(struct net_device *dev)
 {
-	struct x25_asy *sl = dev->priv;
+	struct x25_asy *sl = netdev_priv(dev);
 	int err;
 
 	spin_lock(&sl->lock);
@@ -615,7 +615,7 @@ static void x25_asy_close_tty(struct tty_struct *tty)
 
 static struct net_device_stats *x25_asy_get_stats(struct net_device *dev)
 {
-	struct x25_asy *sl = dev->priv;
+	struct x25_asy *sl = netdev_priv(dev);
 	return &sl->stats;
 }
 
@@ -717,7 +717,7 @@ static int x25_asy_ioctl(struct tty_struct *tty, struct file *file,
 
 static int x25_asy_open_dev(struct net_device *dev)
 {
-	struct x25_asy *sl = dev->priv;
+	struct x25_asy *sl = netdev_priv(dev);
 	if (sl->tty == NULL)
 		return -ENODEV;
 	return 0;
@@ -726,7 +726,7 @@ static int x25_asy_open_dev(struct net_device *dev)
 /* Initialise the X.25 driver.  Called by the device init code */
 static void x25_asy_setup(struct net_device *dev)
 {
-	struct x25_asy *sl = dev->priv;
+	struct x25_asy *sl = netdev_priv(dev);
 
 	sl->magic  = X25_ASY_MAGIC;
 	sl->dev	   = dev;
@@ -793,7 +793,7 @@ static void __exit exit_x25_asy(void)
 	for (i = 0; i < x25_asy_maxdev; i++) {
 		dev = x25_asy_devs[i];
 		if (dev) {
-			struct x25_asy *sl = dev->priv;
+			struct x25_asy *sl = netdev_priv(dev);
 
 			spin_lock_bh(&sl->lock);
 			if (sl->tty)
diff --git a/drivers/net/wireless/libertas/ethtool.c b/drivers/net/wireless/libertas/ethtool.c
index 688d60d..156f471 100644
--- a/drivers/net/wireless/libertas/ethtool.c
+++ b/drivers/net/wireless/libertas/ethtool.c
@@ -23,7 +23,7 @@ static const char * mesh_stat_strings[]= {
 static void lbs_ethtool_get_drvinfo(struct net_device *dev,
 					 struct ethtool_drvinfo *info)
 {
-	struct lbs_private *priv = (struct lbs_private *) dev->priv;
+	struct lbs_private *priv = netdev_priv(dev);
 
 	snprintf(info->fw_version, 32, "%u.%u.%u.p%u",
 		priv->fwrelease >> 24 & 0xff,
@@ -47,7 +47,7 @@ static int lbs_ethtool_get_eeprom_len(struct net_device *dev)
 static int lbs_ethtool_get_eeprom(struct net_device *dev,
                                   struct ethtool_eeprom *eeprom, u8 * bytes)
 {
-	struct lbs_private *priv = (struct lbs_private *) dev->priv;
+	struct lbs_private *priv = netdev_priv(dev);
 	struct cmd_ds_802_11_eeprom_access cmd;
 	int ret;
 
@@ -76,7 +76,7 @@ out:
 static void lbs_ethtool_get_stats(struct net_device *dev,
 				  struct ethtool_stats *stats, uint64_t *data)
 {
-	struct lbs_private *priv = dev->priv;
+	struct lbs_private *priv = netdev_priv(dev);
 	struct cmd_ds_mesh_access mesh_access;
 	int ret;
 
@@ -113,7 +113,7 @@ static void lbs_ethtool_get_stats(struct net_device *dev,
 
 static int lbs_ethtool_get_sset_count(struct net_device *dev, int sset)
 {
-	struct lbs_private *priv = dev->priv;
+	struct lbs_private *priv = netdev_priv(dev);
 
 	if (sset == ETH_SS_STATS && dev == priv->mesh_dev)
 		return MESH_STATS_NUM;
@@ -143,7 +143,7 @@ static void lbs_ethtool_get_strings(struct net_device *dev,
 static void lbs_ethtool_get_wol(struct net_device *dev,
 				struct ethtool_wolinfo *wol)
 {
-	struct lbs_private *priv = dev->priv;
+	struct lbs_private *priv = netdev_priv(dev);
 
 	if (priv->wol_criteria == 0xffffffff) {
 		/* Interface driver didn't configure wake */
@@ -166,7 +166,7 @@ static void lbs_ethtool_get_wol(struct net_device *dev,
 static int lbs_ethtool_set_wol(struct net_device *dev,
 			       struct ethtool_wolinfo *wol)
 {
-	struct lbs_private *priv = dev->priv;
+	struct lbs_private *priv = netdev_priv(dev);
 	uint32_t criteria = 0;
 
 	if (priv->wol_criteria == 0xffffffff && wol->wolopts)
diff --git a/drivers/net/wireless/libertas/persistcfg.c b/drivers/net/wireless/libertas/persistcfg.c
index 3309a9c..dfbd139 100644
--- a/drivers/net/wireless/libertas/persistcfg.c
+++ b/drivers/net/wireless/libertas/persistcfg.c
@@ -18,7 +18,7 @@
 static int mesh_get_default_parameters(struct device *dev,
 				       struct mrvl_mesh_defaults *defs)
 {
-	struct lbs_private *priv = to_net_dev(dev)->priv;
+	struct lbs_private *priv = netdev_priv(to_net_dev(dev));
 	struct cmd_ds_mesh_config cmd;
 	int ret;
 
@@ -57,7 +57,7 @@ static ssize_t bootflag_get(struct device *dev,
 static ssize_t bootflag_set(struct device *dev, struct device_attribute *attr,
 			    const char *buf, size_t count)
 {
-	struct lbs_private *priv = to_net_dev(dev)->priv;
+	struct lbs_private *priv = netdev_priv(to_net_dev(dev));
 	struct cmd_ds_mesh_config cmd;
 	uint32_t datum;
 	int ret;
@@ -100,7 +100,7 @@ static ssize_t boottime_get(struct device *dev,
 static ssize_t boottime_set(struct device *dev,
 		struct device_attribute *attr, const char *buf, size_t count)
 {
-	struct lbs_private *priv = to_net_dev(dev)->priv;
+	struct lbs_private *priv = netdev_priv(to_net_dev(dev));
 	struct cmd_ds_mesh_config cmd;
 	uint32_t datum;
 	int ret;
@@ -152,7 +152,7 @@ static ssize_t channel_get(struct device *dev,
 static ssize_t channel_set(struct device *dev, struct device_attribute *attr,
 			   const char *buf, size_t count)
 {
-	struct lbs_private *priv = to_net_dev(dev)->priv;
+	struct lbs_private *priv = netdev_priv(to_net_dev(dev));
 	struct cmd_ds_mesh_config cmd;
 	uint32_t datum;
 	int ret;
@@ -210,7 +210,7 @@ static ssize_t mesh_id_set(struct device *dev, struct device_attribute *attr,
 	struct cmd_ds_mesh_config cmd;
 	struct mrvl_mesh_defaults defs;
 	struct mrvl_meshie *ie;
-	struct lbs_private *priv = to_net_dev(dev)->priv;
+	struct lbs_private *priv = netdev_priv(to_net_dev(dev));
 	int len;
 	int ret;
 
@@ -269,7 +269,7 @@ static ssize_t protocol_id_set(struct device *dev,
 	struct cmd_ds_mesh_config cmd;
 	struct mrvl_mesh_defaults defs;
 	struct mrvl_meshie *ie;
-	struct lbs_private *priv = to_net_dev(dev)->priv;
+	struct lbs_private *priv = netdev_priv(to_net_dev(dev));
 	uint32_t datum;
 	int ret;
 
@@ -323,7 +323,7 @@ static ssize_t metric_id_set(struct device *dev, struct device_attribute *attr,
 	struct cmd_ds_mesh_config cmd;
 	struct mrvl_mesh_defaults defs;
 	struct mrvl_meshie *ie;
-	struct lbs_private *priv = to_net_dev(dev)->priv;
+	struct lbs_private *priv = netdev_priv(to_net_dev(dev));
 	uint32_t datum;
 	int ret;
 
@@ -377,7 +377,7 @@ static ssize_t capability_set(struct device *dev, struct device_attribute *attr,
 	struct cmd_ds_mesh_config cmd;
 	struct mrvl_mesh_defaults defs;
 	struct mrvl_meshie *ie;
-	struct lbs_private *priv = to_net_dev(dev)->priv;
+	struct lbs_private *priv = netdev_priv(to_net_dev(dev));
 	uint32_t datum;
 	int ret;
 
diff --git a/drivers/net/wireless/libertas/scan.c b/drivers/net/wireless/libertas/scan.c
index 4b27456..33b77f8 100644
--- a/drivers/net/wireless/libertas/scan.c
+++ b/drivers/net/wireless/libertas/scan.c
@@ -939,7 +939,7 @@ out:
 int lbs_set_scan(struct net_device *dev, struct iw_request_info *info,
 		 union iwreq_data *wrqu, char *extra)
 {
-	struct lbs_private *priv = dev->priv;
+	struct lbs_private *priv = netdev_priv(dev);
 	int ret = 0;
 
 	lbs_deb_enter(LBS_DEB_WEXT);
@@ -997,7 +997,7 @@ int lbs_get_scan(struct net_device *dev, struct iw_request_info *info,
 		 struct iw_point *dwrq, char *extra)
 {
 #define SCAN_ITEM_SIZE 128
-	struct lbs_private *priv = dev->priv;
+	struct lbs_private *priv = netdev_priv(dev);
 	int err = 0;
 	char *ev = extra;
 	char *stop = ev + dwrq->length;
diff --git a/drivers/net/wireless/libertas/tx.c b/drivers/net/wireless/libertas/tx.c
index a4972fe..dac4626 100644
--- a/drivers/net/wireless/libertas/tx.c
+++ b/drivers/net/wireless/libertas/tx.c
@@ -60,7 +60,7 @@ static u32 convert_radiotap_rate_to_mv(u8 rate)
 int lbs_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	unsigned long flags;
-	struct lbs_private *priv = dev->priv;
+	struct lbs_private *priv = netdev_priv(dev);
 	struct txpd *txpd;
 	char *p802x_hdr;
 	uint16_t pkt_len;


