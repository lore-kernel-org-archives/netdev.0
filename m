From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless-2.6 2009-02-27
Date: Fri, 27 Feb 2009 14:48:06 -0500
Message-ID: <20090227194806.GH3687@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Dave,

Here is one more fix inteded for 2.6.29.  It fixes a crash for the OLPC
guys...

Please let me know if there are problems!

Thanks,

John

---

Individual patch is available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/

---

The following changes since commit 0c9a3aaaf30e1d1994de58c554ef97a719e20892:
  David S. Miller (1):
        Merge branch 'master' of git://git.kernel.org/.../linville/wireless-2.6

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git master

Kiran Divekar (1):
      libertas: fix misuse of netdev_priv() and dev->ml_priv

 drivers/net/wireless/libertas/ethtool.c    |   12 ++--
 drivers/net/wireless/libertas/if_usb.c     |    4 +-
 drivers/net/wireless/libertas/main.c       |   31 ++++++------
 drivers/net/wireless/libertas/persistcfg.c |   16 +++---
 drivers/net/wireless/libertas/scan.c       |    4 +-
 drivers/net/wireless/libertas/tx.c         |    2 +-
 drivers/net/wireless/libertas/wext.c       |   72 ++++++++++++++--------------
 7 files changed, 71 insertions(+), 70 deletions(-)

diff --git a/drivers/net/wireless/libertas/ethtool.c b/drivers/net/wireless/libertas/ethtool.c
index 61d2f50..b118a35 100644
--- a/drivers/net/wireless/libertas/ethtool.c
+++ b/drivers/net/wireless/libertas/ethtool.c
@@ -23,7 +23,7 @@ static const char * mesh_stat_strings[]= {
 static void lbs_ethtool_get_drvinfo(struct net_device *dev,
 					 struct ethtool_drvinfo *info)
 {
-	struct lbs_private *priv = netdev_priv(dev);
+	struct lbs_private *priv = dev->ml_priv;
 
 	snprintf(info->fw_version, 32, "%u.%u.%u.p%u",
 		priv->fwrelease >> 24 & 0xff,
@@ -47,7 +47,7 @@ static int lbs_ethtool_get_eeprom_len(struct net_device *dev)
 static int lbs_ethtool_get_eeprom(struct net_device *dev,
                                   struct ethtool_eeprom *eeprom, u8 * bytes)
 {
-	struct lbs_private *priv = netdev_priv(dev);
+	struct lbs_private *priv = dev->ml_priv;
 	struct cmd_ds_802_11_eeprom_access cmd;
 	int ret;
 
@@ -76,7 +76,7 @@ out:
 static void lbs_ethtool_get_stats(struct net_device *dev,
 				  struct ethtool_stats *stats, uint64_t *data)
 {
-	struct lbs_private *priv = netdev_priv(dev);
+	struct lbs_private *priv = dev->ml_priv;
 	struct cmd_ds_mesh_access mesh_access;
 	int ret;
 
@@ -113,7 +113,7 @@ static void lbs_ethtool_get_stats(struct net_device *dev,
 
 static int lbs_ethtool_get_sset_count(struct net_device *dev, int sset)
 {
-	struct lbs_private *priv = netdev_priv(dev);
+	struct lbs_private *priv = dev->ml_priv;
 
 	if (sset == ETH_SS_STATS && dev == priv->mesh_dev)
 		return MESH_STATS_NUM;
@@ -143,7 +143,7 @@ static void lbs_ethtool_get_strings(struct net_device *dev,
 static void lbs_ethtool_get_wol(struct net_device *dev,
 				struct ethtool_wolinfo *wol)
 {
-	struct lbs_private *priv = netdev_priv(dev);
+	struct lbs_private *priv = dev->ml_priv;
 
 	if (priv->wol_criteria == 0xffffffff) {
 		/* Interface driver didn't configure wake */
@@ -166,7 +166,7 @@ static void lbs_ethtool_get_wol(struct net_device *dev,
 static int lbs_ethtool_set_wol(struct net_device *dev,
 			       struct ethtool_wolinfo *wol)
 {
-	struct lbs_private *priv = netdev_priv(dev);
+	struct lbs_private *priv = dev->ml_priv;
 	uint32_t criteria = 0;
 
 	if (priv->wol_criteria == 0xffffffff && wol->wolopts)
diff --git a/drivers/net/wireless/libertas/if_usb.c b/drivers/net/wireless/libertas/if_usb.c
index 2fc637a..ea3dc03 100644
--- a/drivers/net/wireless/libertas/if_usb.c
+++ b/drivers/net/wireless/libertas/if_usb.c
@@ -59,7 +59,7 @@ static int if_usb_reset_device(struct if_usb_card *cardp);
 static ssize_t if_usb_firmware_set(struct device *dev,
 		struct device_attribute *attr, const char *buf, size_t count)
 {
-	struct lbs_private *priv = netdev_priv(to_net_dev(dev));
+	struct lbs_private *priv = to_net_dev(dev)->ml_priv;
 	struct if_usb_card *cardp = priv->card;
 	char fwname[FIRMWARE_NAME_MAX];
 	int ret;
@@ -86,7 +86,7 @@ static DEVICE_ATTR(lbs_flash_fw, 0200, NULL, if_usb_firmware_set);
 static ssize_t if_usb_boot2_set(struct device *dev,
 		struct device_attribute *attr, const char *buf, size_t count)
 {
-	struct lbs_private *priv = netdev_priv(to_net_dev(dev));
+	struct lbs_private *priv = to_net_dev(dev)->ml_priv;
 	struct if_usb_card *cardp = priv->card;
 	char fwname[FIRMWARE_NAME_MAX];
 	int ret;
diff --git a/drivers/net/wireless/libertas/main.c b/drivers/net/wireless/libertas/main.c
index 4e0007d..f76623e 100644
--- a/drivers/net/wireless/libertas/main.c
+++ b/drivers/net/wireless/libertas/main.c
@@ -222,7 +222,7 @@ u8 lbs_data_rate_to_fw_index(u32 rate)
 static ssize_t lbs_anycast_get(struct device *dev,
 		struct device_attribute *attr, char * buf)
 {
-	struct lbs_private *priv = netdev_priv(to_net_dev(dev));
+	struct lbs_private *priv = to_net_dev(dev)->ml_priv;
 	struct cmd_ds_mesh_access mesh_access;
 	int ret;
 
@@ -241,7 +241,7 @@ static ssize_t lbs_anycast_get(struct device *dev,
 static ssize_t lbs_anycast_set(struct device *dev,
 		struct device_attribute *attr, const char * buf, size_t count)
 {
-	struct lbs_private *priv = netdev_priv(to_net_dev(dev));
+	struct lbs_private *priv = to_net_dev(dev)->ml_priv;
 	struct cmd_ds_mesh_access mesh_access;
 	uint32_t datum;
 	int ret;
@@ -263,7 +263,7 @@ static ssize_t lbs_anycast_set(struct device *dev,
 static ssize_t lbs_prb_rsp_limit_get(struct device *dev,
 		struct device_attribute *attr, char *buf)
 {
-	struct lbs_private *priv = netdev_priv(to_net_dev(dev));
+	struct lbs_private *priv = to_net_dev(dev)->ml_priv;
 	struct cmd_ds_mesh_access mesh_access;
 	int ret;
 	u32 retry_limit;
@@ -286,7 +286,7 @@ static ssize_t lbs_prb_rsp_limit_get(struct device *dev,
 static ssize_t lbs_prb_rsp_limit_set(struct device *dev,
 		struct device_attribute *attr, const char *buf, size_t count)
 {
-	struct lbs_private *priv = netdev_priv(to_net_dev(dev));
+	struct lbs_private *priv = to_net_dev(dev)->ml_priv;
 	struct cmd_ds_mesh_access mesh_access;
 	int ret;
 	unsigned long retry_limit;
@@ -321,7 +321,7 @@ static void lbs_remove_mesh(struct lbs_private *priv);
 static ssize_t lbs_rtap_get(struct device *dev,
 		struct device_attribute *attr, char * buf)
 {
-	struct lbs_private *priv = netdev_priv(to_net_dev(dev));
+	struct lbs_private *priv = to_net_dev(dev)->ml_priv;
 	return snprintf(buf, 5, "0x%X\n", priv->monitormode);
 }
 
@@ -332,7 +332,7 @@ static ssize_t lbs_rtap_set(struct device *dev,
 		struct device_attribute *attr, const char * buf, size_t count)
 {
 	int monitor_mode;
-	struct lbs_private *priv = netdev_priv(to_net_dev(dev));
+	struct lbs_private *priv = to_net_dev(dev)->ml_priv;
 
 	sscanf(buf, "%x", &monitor_mode);
 	if (monitor_mode) {
@@ -383,7 +383,7 @@ static DEVICE_ATTR(lbs_rtap, 0644, lbs_rtap_get, lbs_rtap_set );
 static ssize_t lbs_mesh_get(struct device *dev,
 		struct device_attribute *attr, char * buf)
 {
-	struct lbs_private *priv = netdev_priv(to_net_dev(dev));
+	struct lbs_private *priv = to_net_dev(dev)->ml_priv;
 	return snprintf(buf, 5, "0x%X\n", !!priv->mesh_dev);
 }
 
@@ -393,7 +393,7 @@ static ssize_t lbs_mesh_get(struct device *dev,
 static ssize_t lbs_mesh_set(struct device *dev,
 		struct device_attribute *attr, const char * buf, size_t count)
 {
-	struct lbs_private *priv = netdev_priv(to_net_dev(dev));
+	struct lbs_private *priv = to_net_dev(dev)->ml_priv;
 	int enable;
 	int ret, action = CMD_ACT_MESH_CONFIG_STOP;
 
@@ -452,7 +452,7 @@ static struct attribute_group lbs_mesh_attr_group = {
  */
 static int lbs_dev_open(struct net_device *dev)
 {
-	struct lbs_private *priv = netdev_priv(dev) ;
+	struct lbs_private *priv = dev->ml_priv;
 	int ret = 0;
 
 	lbs_deb_enter(LBS_DEB_NET);
@@ -521,7 +521,7 @@ static int lbs_mesh_stop(struct net_device *dev)
  */
 static int lbs_eth_stop(struct net_device *dev)
 {
-	struct lbs_private *priv = netdev_priv(dev);
+	struct lbs_private *priv = dev->ml_priv;
 
 	lbs_deb_enter(LBS_DEB_NET);
 
@@ -538,7 +538,7 @@ static int lbs_eth_stop(struct net_device *dev)
 
 static void lbs_tx_timeout(struct net_device *dev)
 {
-	struct lbs_private *priv = netdev_priv(dev);
+	struct lbs_private *priv = dev->ml_priv;
 
 	lbs_deb_enter(LBS_DEB_TX);
 
@@ -590,7 +590,7 @@ EXPORT_SYMBOL_GPL(lbs_host_to_card_done);
  */
 static struct net_device_stats *lbs_get_stats(struct net_device *dev)
 {
-	struct lbs_private *priv = netdev_priv(dev);
+	struct lbs_private *priv = dev->ml_priv;
 
 	lbs_deb_enter(LBS_DEB_NET);
 	return &priv->stats;
@@ -599,7 +599,7 @@ static struct net_device_stats *lbs_get_stats(struct net_device *dev)
 static int lbs_set_mac_address(struct net_device *dev, void *addr)
 {
 	int ret = 0;
-	struct lbs_private *priv = netdev_priv(dev);
+	struct lbs_private *priv = dev->ml_priv;
 	struct sockaddr *phwaddr = addr;
 	struct cmd_ds_802_11_mac_address cmd;
 
@@ -732,7 +732,7 @@ static void lbs_set_mcast_worker(struct work_struct *work)
 
 static void lbs_set_multicast_list(struct net_device *dev)
 {
-	struct lbs_private *priv = netdev_priv(dev);
+	struct lbs_private *priv = dev->ml_priv;
 
 	schedule_work(&priv->mcast_work);
 }
@@ -748,7 +748,7 @@ static void lbs_set_multicast_list(struct net_device *dev)
 static int lbs_thread(void *data)
 {
 	struct net_device *dev = data;
-	struct lbs_private *priv = netdev_priv(dev);
+	struct lbs_private *priv = dev->ml_priv;
 	wait_queue_t wait;
 
 	lbs_deb_enter(LBS_DEB_THREAD);
@@ -1184,6 +1184,7 @@ struct lbs_private *lbs_add_card(void *card, struct device *dmdev)
 		goto done;
 	}
 	priv = netdev_priv(dev);
+	dev->ml_priv = priv;
 
 	if (lbs_init_adapter(priv)) {
 		lbs_pr_err("failed to initialize adapter structure.\n");
diff --git a/drivers/net/wireless/libertas/persistcfg.c b/drivers/net/wireless/libertas/persistcfg.c
index d42b7a5..18fe29f 100644
--- a/drivers/net/wireless/libertas/persistcfg.c
+++ b/drivers/net/wireless/libertas/persistcfg.c
@@ -18,7 +18,7 @@
 static int mesh_get_default_parameters(struct device *dev,
 				       struct mrvl_mesh_defaults *defs)
 {
-	struct lbs_private *priv = netdev_priv(to_net_dev(dev));
+	struct lbs_private *priv = to_net_dev(dev)->ml_priv;
 	struct cmd_ds_mesh_config cmd;
 	int ret;
 
@@ -57,7 +57,7 @@ static ssize_t bootflag_get(struct device *dev,
 static ssize_t bootflag_set(struct device *dev, struct device_attribute *attr,
 			    const char *buf, size_t count)
 {
-	struct lbs_private *priv = netdev_priv(to_net_dev(dev));
+	struct lbs_private *priv = to_net_dev(dev)->ml_priv;
 	struct cmd_ds_mesh_config cmd;
 	uint32_t datum;
 	int ret;
@@ -100,7 +100,7 @@ static ssize_t boottime_get(struct device *dev,
 static ssize_t boottime_set(struct device *dev,
 		struct device_attribute *attr, const char *buf, size_t count)
 {
-	struct lbs_private *priv = netdev_priv(to_net_dev(dev));
+	struct lbs_private *priv = to_net_dev(dev)->ml_priv;
 	struct cmd_ds_mesh_config cmd;
 	uint32_t datum;
 	int ret;
@@ -152,7 +152,7 @@ static ssize_t channel_get(struct device *dev,
 static ssize_t channel_set(struct device *dev, struct device_attribute *attr,
 			   const char *buf, size_t count)
 {
-	struct lbs_private *priv = netdev_priv(to_net_dev(dev));
+	struct lbs_private *priv = to_net_dev(dev)->ml_priv;
 	struct cmd_ds_mesh_config cmd;
 	uint32_t datum;
 	int ret;
@@ -210,7 +210,7 @@ static ssize_t mesh_id_set(struct device *dev, struct device_attribute *attr,
 	struct cmd_ds_mesh_config cmd;
 	struct mrvl_mesh_defaults defs;
 	struct mrvl_meshie *ie;
-	struct lbs_private *priv = netdev_priv(to_net_dev(dev));
+	struct lbs_private *priv = to_net_dev(dev)->ml_priv;
 	int len;
 	int ret;
 
@@ -269,7 +269,7 @@ static ssize_t protocol_id_set(struct device *dev,
 	struct cmd_ds_mesh_config cmd;
 	struct mrvl_mesh_defaults defs;
 	struct mrvl_meshie *ie;
-	struct lbs_private *priv = netdev_priv(to_net_dev(dev));
+	struct lbs_private *priv = to_net_dev(dev)->ml_priv;
 	uint32_t datum;
 	int ret;
 
@@ -323,7 +323,7 @@ static ssize_t metric_id_set(struct device *dev, struct device_attribute *attr,
 	struct cmd_ds_mesh_config cmd;
 	struct mrvl_mesh_defaults defs;
 	struct mrvl_meshie *ie;
-	struct lbs_private *priv = netdev_priv(to_net_dev(dev));
+	struct lbs_private *priv = to_net_dev(dev)->ml_priv;
 	uint32_t datum;
 	int ret;
 
@@ -377,7 +377,7 @@ static ssize_t capability_set(struct device *dev, struct device_attribute *attr,
 	struct cmd_ds_mesh_config cmd;
 	struct mrvl_mesh_defaults defs;
 	struct mrvl_meshie *ie;
-	struct lbs_private *priv = netdev_priv(to_net_dev(dev));
+	struct lbs_private *priv = to_net_dev(dev)->ml_priv;
 	uint32_t datum;
 	int ret;
 
diff --git a/drivers/net/wireless/libertas/scan.c b/drivers/net/wireless/libertas/scan.c
index 57f6c12..9014950 100644
--- a/drivers/net/wireless/libertas/scan.c
+++ b/drivers/net/wireless/libertas/scan.c
@@ -945,7 +945,7 @@ int lbs_set_scan(struct net_device *dev, struct iw_request_info *info,
 		 union iwreq_data *wrqu, char *extra)
 {
 	DECLARE_SSID_BUF(ssid);
-	struct lbs_private *priv = netdev_priv(dev);
+	struct lbs_private *priv = dev->ml_priv;
 	int ret = 0;
 
 	lbs_deb_enter(LBS_DEB_WEXT);
@@ -1008,7 +1008,7 @@ int lbs_get_scan(struct net_device *dev, struct iw_request_info *info,
 		 struct iw_point *dwrq, char *extra)
 {
 #define SCAN_ITEM_SIZE 128
-	struct lbs_private *priv = netdev_priv(dev);
+	struct lbs_private *priv = dev->ml_priv;
 	int err = 0;
 	char *ev = extra;
 	char *stop = ev + dwrq->length;
diff --git a/drivers/net/wireless/libertas/tx.c b/drivers/net/wireless/libertas/tx.c
index dac4626..68bec31 100644
--- a/drivers/net/wireless/libertas/tx.c
+++ b/drivers/net/wireless/libertas/tx.c
@@ -60,7 +60,7 @@ static u32 convert_radiotap_rate_to_mv(u8 rate)
 int lbs_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	unsigned long flags;
-	struct lbs_private *priv = netdev_priv(dev);
+	struct lbs_private *priv = dev->ml_priv;
 	struct txpd *txpd;
 	char *p802x_hdr;
 	uint16_t pkt_len;
diff --git a/drivers/net/wireless/libertas/wext.c b/drivers/net/wireless/libertas/wext.c
index c6102e0..f16d136 100644
--- a/drivers/net/wireless/libertas/wext.c
+++ b/drivers/net/wireless/libertas/wext.c
@@ -163,7 +163,7 @@ static int lbs_get_name(struct net_device *dev, struct iw_request_info *info,
 static int lbs_get_freq(struct net_device *dev, struct iw_request_info *info,
 			 struct iw_freq *fwrq, char *extra)
 {
-	struct lbs_private *priv = netdev_priv(dev);
+	struct lbs_private *priv = dev->ml_priv;
 	struct chan_freq_power *cfp;
 
 	lbs_deb_enter(LBS_DEB_WEXT);
@@ -189,7 +189,7 @@ static int lbs_get_freq(struct net_device *dev, struct iw_request_info *info,
 static int lbs_get_wap(struct net_device *dev, struct iw_request_info *info,
 			struct sockaddr *awrq, char *extra)
 {
-	struct lbs_private *priv = netdev_priv(dev);
+	struct lbs_private *priv = dev->ml_priv;
 
 	lbs_deb_enter(LBS_DEB_WEXT);
 
@@ -207,7 +207,7 @@ static int lbs_get_wap(struct net_device *dev, struct iw_request_info *info,
 static int lbs_set_nick(struct net_device *dev, struct iw_request_info *info,
 			 struct iw_point *dwrq, char *extra)
 {
-	struct lbs_private *priv = netdev_priv(dev);
+	struct lbs_private *priv = dev->ml_priv;
 
 	lbs_deb_enter(LBS_DEB_WEXT);
 
@@ -231,7 +231,7 @@ static int lbs_set_nick(struct net_device *dev, struct iw_request_info *info,
 static int lbs_get_nick(struct net_device *dev, struct iw_request_info *info,
 			 struct iw_point *dwrq, char *extra)
 {
-	struct lbs_private *priv = netdev_priv(dev);
+	struct lbs_private *priv = dev->ml_priv;
 
 	lbs_deb_enter(LBS_DEB_WEXT);
 
@@ -248,7 +248,7 @@ static int lbs_get_nick(struct net_device *dev, struct iw_request_info *info,
 static int mesh_get_nick(struct net_device *dev, struct iw_request_info *info,
 			 struct iw_point *dwrq, char *extra)
 {
-	struct lbs_private *priv = netdev_priv(dev);
+	struct lbs_private *priv = dev->ml_priv;
 
 	lbs_deb_enter(LBS_DEB_WEXT);
 
@@ -273,7 +273,7 @@ static int lbs_set_rts(struct net_device *dev, struct iw_request_info *info,
 			struct iw_param *vwrq, char *extra)
 {
 	int ret = 0;
-	struct lbs_private *priv = netdev_priv(dev);
+	struct lbs_private *priv = dev->ml_priv;
 	u32 val = vwrq->value;
 
 	lbs_deb_enter(LBS_DEB_WEXT);
@@ -293,7 +293,7 @@ static int lbs_set_rts(struct net_device *dev, struct iw_request_info *info,
 static int lbs_get_rts(struct net_device *dev, struct iw_request_info *info,
 			struct iw_param *vwrq, char *extra)
 {
-	struct lbs_private *priv = netdev_priv(dev);
+	struct lbs_private *priv = dev->ml_priv;
 	int ret = 0;
 	u16 val = 0;
 
@@ -315,7 +315,7 @@ out:
 static int lbs_set_frag(struct net_device *dev, struct iw_request_info *info,
 			 struct iw_param *vwrq, char *extra)
 {
-	struct lbs_private *priv = netdev_priv(dev);
+	struct lbs_private *priv = dev->ml_priv;
 	int ret = 0;
 	u32 val = vwrq->value;
 
@@ -336,7 +336,7 @@ static int lbs_set_frag(struct net_device *dev, struct iw_request_info *info,
 static int lbs_get_frag(struct net_device *dev, struct iw_request_info *info,
 			 struct iw_param *vwrq, char *extra)
 {
-	struct lbs_private *priv = netdev_priv(dev);
+	struct lbs_private *priv = dev->ml_priv;
 	int ret = 0;
 	u16 val = 0;
 
@@ -359,7 +359,7 @@ out:
 static int lbs_get_mode(struct net_device *dev,
 			 struct iw_request_info *info, u32 * uwrq, char *extra)
 {
-	struct lbs_private *priv = netdev_priv(dev);
+	struct lbs_private *priv = dev->ml_priv;
 
 	lbs_deb_enter(LBS_DEB_WEXT);
 
@@ -385,7 +385,7 @@ static int lbs_get_txpow(struct net_device *dev,
 			  struct iw_request_info *info,
 			  struct iw_param *vwrq, char *extra)
 {
-	struct lbs_private *priv = netdev_priv(dev);
+	struct lbs_private *priv = dev->ml_priv;
 	s16 curlevel = 0;
 	int ret = 0;
 
@@ -418,7 +418,7 @@ out:
 static int lbs_set_retry(struct net_device *dev, struct iw_request_info *info,
 			  struct iw_param *vwrq, char *extra)
 {
-	struct lbs_private *priv = netdev_priv(dev);
+	struct lbs_private *priv = dev->ml_priv;
 	int ret = 0;
 	u16 slimit = 0, llimit = 0;
 
@@ -466,7 +466,7 @@ out:
 static int lbs_get_retry(struct net_device *dev, struct iw_request_info *info,
 			  struct iw_param *vwrq, char *extra)
 {
-	struct lbs_private *priv = netdev_priv(dev);
+	struct lbs_private *priv = dev->ml_priv;
 	int ret = 0;
 	u16 val = 0;
 
@@ -542,7 +542,7 @@ static int lbs_get_range(struct net_device *dev, struct iw_request_info *info,
 			  struct iw_point *dwrq, char *extra)
 {
 	int i, j;
-	struct lbs_private *priv = netdev_priv(dev);
+	struct lbs_private *priv = dev->ml_priv;
 	struct iw_range *range = (struct iw_range *)extra;
 	struct chan_freq_power *cfp;
 	u8 rates[MAX_RATES + 1];
@@ -708,7 +708,7 @@ out:
 static int lbs_set_power(struct net_device *dev, struct iw_request_info *info,
 			  struct iw_param *vwrq, char *extra)
 {
-	struct lbs_private *priv = netdev_priv(dev);
+	struct lbs_private *priv = dev->ml_priv;
 
 	lbs_deb_enter(LBS_DEB_WEXT);
 
@@ -758,7 +758,7 @@ static int lbs_set_power(struct net_device *dev, struct iw_request_info *info,
 static int lbs_get_power(struct net_device *dev, struct iw_request_info *info,
 			  struct iw_param *vwrq, char *extra)
 {
-	struct lbs_private *priv = netdev_priv(dev);
+	struct lbs_private *priv = dev->ml_priv;
 
 	lbs_deb_enter(LBS_DEB_WEXT);
 
@@ -781,7 +781,7 @@ static struct iw_statistics *lbs_get_wireless_stats(struct net_device *dev)
 		EXCELLENT = 95,
 		PERFECT = 100
 	};
-	struct lbs_private *priv = netdev_priv(dev);
+	struct lbs_private *priv = dev->ml_priv;
 	u32 rssi_qual;
 	u32 tx_qual;
 	u32 quality = 0;
@@ -886,7 +886,7 @@ static int lbs_set_freq(struct net_device *dev, struct iw_request_info *info,
 		  struct iw_freq *fwrq, char *extra)
 {
 	int ret = -EINVAL;
-	struct lbs_private *priv = netdev_priv(dev);
+	struct lbs_private *priv = dev->ml_priv;
 	struct chan_freq_power *cfp;
 	struct assoc_request * assoc_req;
 
@@ -943,7 +943,7 @@ static int lbs_mesh_set_freq(struct net_device *dev,
 			     struct iw_request_info *info,
 			     struct iw_freq *fwrq, char *extra)
 {
-	struct lbs_private *priv = netdev_priv(dev);
+	struct lbs_private *priv = dev->ml_priv;
 	struct chan_freq_power *cfp;
 	int ret = -EINVAL;
 
@@ -994,7 +994,7 @@ out:
 static int lbs_set_rate(struct net_device *dev, struct iw_request_info *info,
 		  struct iw_param *vwrq, char *extra)
 {
-	struct lbs_private *priv = netdev_priv(dev);
+	struct lbs_private *priv = dev->ml_priv;
 	u8 new_rate = 0;
 	int ret = -EINVAL;
 	u8 rates[MAX_RATES + 1];
@@ -1054,7 +1054,7 @@ out:
 static int lbs_get_rate(struct net_device *dev, struct iw_request_info *info,
 		  struct iw_param *vwrq, char *extra)
 {
-	struct lbs_private *priv = netdev_priv(dev);
+	struct lbs_private *priv = dev->ml_priv;
 
 	lbs_deb_enter(LBS_DEB_WEXT);
 
@@ -1079,7 +1079,7 @@ static int lbs_set_mode(struct net_device *dev,
 		  struct iw_request_info *info, u32 * uwrq, char *extra)
 {
 	int ret = 0;
-	struct lbs_private *priv = netdev_priv(dev);
+	struct lbs_private *priv = dev->ml_priv;
 	struct assoc_request * assoc_req;
 
 	lbs_deb_enter(LBS_DEB_WEXT);
@@ -1124,7 +1124,7 @@ static int lbs_get_encode(struct net_device *dev,
 			   struct iw_request_info *info,
 			   struct iw_point *dwrq, u8 * extra)
 {
-	struct lbs_private *priv = netdev_priv(dev);
+	struct lbs_private *priv = dev->ml_priv;
 	int index = (dwrq->flags & IW_ENCODE_INDEX) - 1;
 
 	lbs_deb_enter(LBS_DEB_WEXT);
@@ -1319,7 +1319,7 @@ static int lbs_set_encode(struct net_device *dev,
 		    struct iw_point *dwrq, char *extra)
 {
 	int ret = 0;
-	struct lbs_private *priv = netdev_priv(dev);
+	struct lbs_private *priv = dev->ml_priv;
 	struct assoc_request * assoc_req;
 	u16 is_default = 0, index = 0, set_tx_key = 0;
 
@@ -1395,7 +1395,7 @@ static int lbs_get_encodeext(struct net_device *dev,
 			      char *extra)
 {
 	int ret = -EINVAL;
-	struct lbs_private *priv = netdev_priv(dev);
+	struct lbs_private *priv = dev->ml_priv;
 	struct iw_encode_ext *ext = (struct iw_encode_ext *)extra;
 	int index, max_key_len;
 
@@ -1501,7 +1501,7 @@ static int lbs_set_encodeext(struct net_device *dev,
 			      char *extra)
 {
 	int ret = 0;
-	struct lbs_private *priv = netdev_priv(dev);
+	struct lbs_private *priv = dev->ml_priv;
 	struct iw_encode_ext *ext = (struct iw_encode_ext *)extra;
 	int alg = ext->alg;
 	struct assoc_request * assoc_req;
@@ -1639,7 +1639,7 @@ static int lbs_set_genie(struct net_device *dev,
 			  struct iw_point *dwrq,
 			  char *extra)
 {
-	struct lbs_private *priv = netdev_priv(dev);
+	struct lbs_private *priv = dev->ml_priv;
 	int ret = 0;
 	struct assoc_request * assoc_req;
 
@@ -1685,7 +1685,7 @@ static int lbs_get_genie(struct net_device *dev,
 			  char *extra)
 {
 	int ret = 0;
-	struct lbs_private *priv = netdev_priv(dev);
+	struct lbs_private *priv = dev->ml_priv;
 
 	lbs_deb_enter(LBS_DEB_WEXT);
 
@@ -1713,7 +1713,7 @@ static int lbs_set_auth(struct net_device *dev,
 			 struct iw_param *dwrq,
 			 char *extra)
 {
-	struct lbs_private *priv = netdev_priv(dev);
+	struct lbs_private *priv = dev->ml_priv;
 	struct assoc_request * assoc_req;
 	int ret = 0;
 	int updated = 0;
@@ -1816,7 +1816,7 @@ static int lbs_get_auth(struct net_device *dev,
 			 char *extra)
 {
 	int ret = 0;
-	struct lbs_private *priv = netdev_priv(dev);
+	struct lbs_private *priv = dev->ml_priv;
 
 	lbs_deb_enter(LBS_DEB_WEXT);
 
@@ -1857,7 +1857,7 @@ static int lbs_set_txpow(struct net_device *dev, struct iw_request_info *info,
 		   struct iw_param *vwrq, char *extra)
 {
 	int ret = 0;
-	struct lbs_private *priv = netdev_priv(dev);
+	struct lbs_private *priv = dev->ml_priv;
 	s16 dbm = (s16) vwrq->value;
 
 	lbs_deb_enter(LBS_DEB_WEXT);
@@ -1936,7 +1936,7 @@ out:
 static int lbs_get_essid(struct net_device *dev, struct iw_request_info *info,
 		   struct iw_point *dwrq, char *extra)
 {
-	struct lbs_private *priv = netdev_priv(dev);
+	struct lbs_private *priv = dev->ml_priv;
 
 	lbs_deb_enter(LBS_DEB_WEXT);
 
@@ -1971,7 +1971,7 @@ static int lbs_get_essid(struct net_device *dev, struct iw_request_info *info,
 static int lbs_set_essid(struct net_device *dev, struct iw_request_info *info,
 		   struct iw_point *dwrq, char *extra)
 {
-	struct lbs_private *priv = netdev_priv(dev);
+	struct lbs_private *priv = dev->ml_priv;
 	int ret = 0;
 	u8 ssid[IW_ESSID_MAX_SIZE];
 	u8 ssid_len = 0;
@@ -2040,7 +2040,7 @@ static int lbs_mesh_get_essid(struct net_device *dev,
 			      struct iw_request_info *info,
 			      struct iw_point *dwrq, char *extra)
 {
-	struct lbs_private *priv = netdev_priv(dev);
+	struct lbs_private *priv = dev->ml_priv;
 
 	lbs_deb_enter(LBS_DEB_WEXT);
 
@@ -2058,7 +2058,7 @@ static int lbs_mesh_set_essid(struct net_device *dev,
 			      struct iw_request_info *info,
 			      struct iw_point *dwrq, char *extra)
 {
-	struct lbs_private *priv = netdev_priv(dev);
+	struct lbs_private *priv = dev->ml_priv;
 	int ret = 0;
 
 	lbs_deb_enter(LBS_DEB_WEXT);
@@ -2102,7 +2102,7 @@ static int lbs_mesh_set_essid(struct net_device *dev,
 static int lbs_set_wap(struct net_device *dev, struct iw_request_info *info,
 		 struct sockaddr *awrq, char *extra)
 {
-	struct lbs_private *priv = netdev_priv(dev);
+	struct lbs_private *priv = dev->ml_priv;
 	struct assoc_request * assoc_req;
 	int ret = 0;
 
-- 
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
