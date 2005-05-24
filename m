From: Jiri Benc <jbenc@suse.cz>
Subject: [5/6] ipw2200: fix after "ieee80211_device alignment fix"
Date: Tue, 24 May 2005 15:19:15 +0200
Message-ID: <20050524151915.5b772c95@griffin.suse.cz>
References: <20050524150711.01632672@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: NetDev <netdev@oss.sgi.com>
In-Reply-To: <20050524150711.01632672@griffin.suse.cz>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Fixes ipw2200 after ieee80211_device alignment fix
(patch [2/5] ieee80211: ieee80211_device alignment fix and cleanup).


Signed-off-by: Jiri Benc <jbenc@suse.cz>
Signed-off-by: Jirka Bohac <jbohac@suse.cz>

--- linux-2.6.12-rc2-mm3.02/drivers/net/wireless/ipw2200.c	2005-05-18 13:36:28.000000000 +0200
+++ linux-2.6.12-rc2-mm3.02-ipwfix/drivers/net/wireless/ipw2200.c	2005-05-18 16:50:29.000000000 +0200
@@ -5586,7 +5586,7 @@
 	}
 
 	if (ieee->set_security)
-		ieee->set_security(ieee->dev, &sec);
+		ieee->set_security(ieee, &sec);
 	else
 		ret = -EOPNOTSUPP;
 
@@ -5613,7 +5613,7 @@
 	}
 
 	if (ieee->set_security)
-		ieee->set_security(ieee->dev, &sec);
+		ieee->set_security(ieee, &sec);
 	else
 		ret = -EOPNOTSUPP;
 
@@ -5623,7 +5623,7 @@
 
 static int ipw_wpa_set_param(struct net_device *dev, u8 name, u32 value)
 {
-	struct ipw_priv *priv = ieee80211_priv(dev);
+	struct ipw_priv *priv = ieee80211_priv(netdev_priv(dev));
 	int ret=0;
 
 	switch (name) {
@@ -5662,7 +5662,7 @@
 
 static int ipw_wpa_mlme(struct net_device *dev, int command, int reason)
 {
-	struct ipw_priv *priv = ieee80211_priv(dev);
+	struct ipw_priv *priv = ieee80211_priv(netdev_priv(dev));
 	int ret = 0;
 
 	switch (command) {
@@ -5712,8 +5712,8 @@
 static int ipw_wpa_set_wpa_ie(struct net_device *dev,
 			      struct ipw_param *param, int plen)
 {
-	struct ipw_priv *priv = ieee80211_priv(dev);
-	struct ieee80211_device *ieee = priv->ieee;
+	struct ieee80211_device *ieee = netdev_priv(dev);
+	struct ipw_priv *priv = ieee80211_priv(ieee);
 	u8 *buf;
 
 	if (!ieee->wpa_enabled)
@@ -5748,8 +5748,7 @@
 				  struct ipw_param *param, int param_len)
 {
 	int ret = 0;
-	struct ipw_priv *priv = ieee80211_priv(dev);
-	struct ieee80211_device *ieee = priv->ieee;
+	struct ieee80211_device *ieee = netdev_priv(dev);
 	struct ieee80211_crypto_ops *ops;
 	struct ieee80211_crypt_data **crypt;
 
@@ -5871,7 +5870,7 @@
 	}
  done:
 	if (ieee->set_security)
-		ieee->set_security(ieee->dev, &sec);
+		ieee->set_security(ieee, &sec);
 
 	/* Do not reset port if card is in Managed mode since resetting will
 	 * generate new IEEE 802.11 authentication which may end up in looping
@@ -5881,7 +5880,7 @@
 	if (ieee->reset_on_keychange &&
 	    ieee->iw_mode != IW_MODE_INFRA &&
 	    ieee->reset_port &&
-	    ieee->reset_port(dev)) {
+	    ieee->reset_port(ieee)) {
 		IPW_DEBUG_INFO("%s: reset_port failed\n", dev->name);
 		param->u.crypt.err = IPW_CRYPT_ERR_CARD_CONF_FAILED;
 		return -EINVAL;
@@ -6525,7 +6524,7 @@
 			   struct iw_request_info *info,
 			   union iwreq_data *wrqu, char *extra)
 {
-	struct ipw_priv *priv = ieee80211_priv(dev);
+	struct ipw_priv *priv = ieee80211_priv(netdev_priv(dev));
 	down(&priv->sem);
 	if (priv->status & STATUS_RF_KILL_MASK)
 		strcpy(wrqu->name, "radio off");
@@ -6574,7 +6573,7 @@
 			   struct iw_request_info *info,
 			   union iwreq_data *wrqu, char *extra)
 {
-	struct ipw_priv *priv = ieee80211_priv(dev);
+	struct ipw_priv *priv = ieee80211_priv(netdev_priv(dev));
 	struct iw_freq *fwrq = &wrqu->freq;
 	int ret = 0;
 
@@ -6610,7 +6609,7 @@
 			   struct iw_request_info *info,
 			   union iwreq_data *wrqu, char *extra)
 {
-	struct ipw_priv *priv = ieee80211_priv(dev);
+	struct ipw_priv *priv = ieee80211_priv(netdev_priv(dev));
 
 	wrqu->freq.e = 0;
 
@@ -6632,7 +6631,7 @@
 			   struct iw_request_info *info,
 			   union iwreq_data *wrqu, char *extra)
 {
-	struct ipw_priv *priv = ieee80211_priv(dev);
+	struct ipw_priv *priv = ieee80211_priv(netdev_priv(dev));
 	int err = 0;
 
 	IPW_DEBUG_WX("Set MODE: %d\n", wrqu->mode);
@@ -6688,7 +6687,7 @@
 			       struct iw_request_info *info,
 			       union iwreq_data *wrqu, char *extra)
 {
-	struct ipw_priv *priv = ieee80211_priv(dev);
+	struct ipw_priv *priv = ieee80211_priv(netdev_priv(dev));
         down(&priv->sem);
 	wrqu->mode = priv->ieee->iw_mode;
 	IPW_DEBUG_WX("Get MODE -> %d\n", wrqu->mode);
@@ -6725,7 +6724,7 @@
 			    struct iw_request_info *info,
 			    union iwreq_data *wrqu, char *extra)
 {
-	struct ipw_priv *priv = ieee80211_priv(dev);
+	struct ipw_priv *priv = ieee80211_priv(netdev_priv(dev));
 	struct iw_range *range = (struct iw_range *)extra;
 	u16 val;
 	int i;
@@ -6789,7 +6788,7 @@
 			  struct iw_request_info *info,
 			  union iwreq_data *wrqu, char *extra)
 {
-	struct ipw_priv *priv = ieee80211_priv(dev);
+	struct ipw_priv *priv = ieee80211_priv(netdev_priv(dev));
 
 	static const unsigned char any[] = {
 		0xff, 0xff, 0xff, 0xff, 0xff, 0xff
@@ -6838,7 +6837,7 @@
 			  struct iw_request_info *info,
 			  union iwreq_data *wrqu, char *extra)
 {
-	struct ipw_priv *priv = ieee80211_priv(dev);
+	struct ipw_priv *priv = ieee80211_priv(netdev_priv(dev));
 	/* If we are associated, trying to associate, or have a statically
 	 * configured BSSID then return that; otherwise return ANY */
 	down(&priv->sem);
@@ -6859,7 +6858,7 @@
 			    struct iw_request_info *info,
 			    union iwreq_data *wrqu, char *extra)
 {
-	struct ipw_priv *priv = ieee80211_priv(dev);
+	struct ipw_priv *priv = ieee80211_priv(netdev_priv(dev));
 	char *essid = ""; /* ANY */
 	int length = 0;
 	down(&priv->sem);
@@ -6909,7 +6908,7 @@
 			    struct iw_request_info *info,
 			    union iwreq_data *wrqu, char *extra)
 {
-	struct ipw_priv *priv = ieee80211_priv(dev);
+	struct ipw_priv *priv = ieee80211_priv(netdev_priv(dev));
 
 	/* If we are associated, trying to associate, or have a statically
 	 * configured ESSID then return that; otherwise return ANY */
@@ -6934,7 +6933,7 @@
 			   struct iw_request_info *info,
 			   union iwreq_data *wrqu, char *extra)
 {
-	struct ipw_priv *priv = ieee80211_priv(dev);
+	struct ipw_priv *priv = ieee80211_priv(netdev_priv(dev));
 
 	IPW_DEBUG_WX("Setting nick to '%s'\n", extra);
 	if (wrqu->data.length > IW_ESSID_MAX_SIZE)
@@ -6954,7 +6953,7 @@
 			   struct iw_request_info *info,
 			   union iwreq_data *wrqu, char *extra)
 {
-	struct ipw_priv *priv = ieee80211_priv(dev);
+	struct ipw_priv *priv = ieee80211_priv(netdev_priv(dev));
 	IPW_DEBUG_WX("Getting nick\n");
 	down(&priv->sem);
 	wrqu->data.length = strlen(priv->nick) + 1;
@@ -6969,7 +6968,7 @@
 			   union iwreq_data *wrqu, char *extra)
 {
 	/* TODO: We should use semaphores or locks for access to priv */
-	struct ipw_priv *priv = ieee80211_priv(dev);
+	struct ipw_priv *priv = ieee80211_priv(netdev_priv(dev));
 	u32 target_rate = wrqu->bitrate.value;
 	u32 fixed, mask;
 
@@ -7081,7 +7080,7 @@
 			   struct iw_request_info *info,
 			   union iwreq_data *wrqu, char *extra)
 {
-	struct ipw_priv * priv = ieee80211_priv(dev);
+	struct ipw_priv * priv = ieee80211_priv(netdev_priv(dev));
 	down(&priv->sem);
 	wrqu->bitrate.value = priv->last_rate;
 	up(&priv->sem);
@@ -7094,7 +7093,7 @@
 			  struct iw_request_info *info,
 			  union iwreq_data *wrqu, char *extra)
 {
-	struct ipw_priv *priv = ieee80211_priv(dev);
+	struct ipw_priv *priv = ieee80211_priv(netdev_priv(dev));
 	down(&priv->sem);
 	if (wrqu->rts.disabled)
 		priv->rts_threshold = DEFAULT_RTS_THRESHOLD;
@@ -7117,7 +7116,7 @@
 			  struct iw_request_info *info,
 			  union iwreq_data *wrqu, char *extra)
 {
-	struct ipw_priv *priv = ieee80211_priv(dev);
+	struct ipw_priv *priv = ieee80211_priv(netdev_priv(dev));
 	down(&priv->sem);
 	wrqu->rts.value = priv->rts_threshold;
 	wrqu->rts.fixed = 0;	/* no auto select */
@@ -7133,7 +7132,7 @@
 			    struct iw_request_info *info,
 			    union iwreq_data *wrqu, char *extra)
 {
-	struct ipw_priv *priv = ieee80211_priv(dev);
+	struct ipw_priv *priv = ieee80211_priv(netdev_priv(dev));
 	struct ipw_tx_power tx_power;
 	int i;
 	down(&priv->sem);
@@ -7185,7 +7184,7 @@
 			    struct iw_request_info *info,
 			    union iwreq_data *wrqu, char *extra)
 {
-	struct ipw_priv *priv = ieee80211_priv(dev);
+	struct ipw_priv *priv = ieee80211_priv(netdev_priv(dev));
 	down(&priv->sem);
 	wrqu->power.value = priv->tx_power;
 	wrqu->power.fixed = 1;
@@ -7204,7 +7203,7 @@
 			       struct iw_request_info *info,
 			       union iwreq_data *wrqu, char *extra)
 {
-	struct ipw_priv *priv = ieee80211_priv(dev);
+	struct ipw_priv *priv = ieee80211_priv(netdev_priv(dev));
 	down(&priv->sem);
 	if (wrqu->frag.disabled)
 		priv->ieee->fts = DEFAULT_FTS;
@@ -7226,7 +7225,7 @@
 			       struct iw_request_info *info,
 			       union iwreq_data *wrqu, char *extra)
 {
-	struct ipw_priv *priv = ieee80211_priv(dev);
+	struct ipw_priv *priv = ieee80211_priv(netdev_priv(dev));
 	down(&priv->sem);
 	wrqu->frag.value = priv->ieee->fts;
 	wrqu->frag.fixed = 0;	/* no auto select */
@@ -7260,7 +7259,7 @@
 			   struct iw_request_info *info,
 			   union iwreq_data *wrqu, char *extra)
 {
-	struct ipw_priv *priv = ieee80211_priv(dev);
+	struct ipw_priv *priv = ieee80211_priv(netdev_priv(dev));
 	IPW_DEBUG_WX("Start scan\n");
 	down(&priv->sem);
 	if (ipw_request_scan(priv)) {
@@ -7275,7 +7274,7 @@
 			   struct iw_request_info *info,
 			   union iwreq_data *wrqu, char *extra)
 {
-	struct ipw_priv *priv = ieee80211_priv(dev);
+	struct ipw_priv *priv = ieee80211_priv(netdev_priv(dev));
 	return ieee80211_wx_get_scan(priv->ieee, info, wrqu, extra);
 }
 
@@ -7283,7 +7282,7 @@
 				 struct iw_request_info *info,
 				 union iwreq_data *wrqu, char *key)
 {
-	struct ipw_priv *priv = ieee80211_priv(dev);
+	struct ipw_priv *priv = ieee80211_priv(netdev_priv(dev));
 	return ieee80211_wx_set_encode(priv->ieee, info, wrqu, key);
 }
 
@@ -7291,7 +7290,7 @@
 				 struct iw_request_info *info,
 				 union iwreq_data *wrqu, char *key)
 {
-	struct ipw_priv *priv = ieee80211_priv(dev);
+	struct ipw_priv *priv = ieee80211_priv(netdev_priv(dev));
 	return ieee80211_wx_get_encode(priv->ieee, info, wrqu, key);
 }
 
@@ -7299,7 +7298,7 @@
 			        struct iw_request_info *info,
 			        union iwreq_data *wrqu, char *extra)
 {
-	struct ipw_priv *priv = ieee80211_priv(dev);
+	struct ipw_priv *priv = ieee80211_priv(netdev_priv(dev));
 	int err;
 	down(&priv->sem);
 	if (wrqu->power.disabled) {
@@ -7350,7 +7349,7 @@
 			        struct iw_request_info *info,
 			        union iwreq_data *wrqu, char *extra)
 {
-	struct ipw_priv *priv = ieee80211_priv(dev);
+	struct ipw_priv *priv = ieee80211_priv(netdev_priv(dev));
 	down(&priv->sem);
 	if (!(priv->power_mode & IPW_POWER_ENABLED))
 		wrqu->power.disabled = 1;
@@ -7367,7 +7366,7 @@
 				    struct iw_request_info *info,
 				    union iwreq_data *wrqu, char *extra)
 {
-	struct ipw_priv *priv = ieee80211_priv(dev);
+	struct ipw_priv *priv = ieee80211_priv(netdev_priv(dev));
 	int mode = *(int *)extra;
 	int err;
 	down(&priv->sem);
@@ -7396,7 +7395,7 @@
 				    struct iw_request_info *info,
 				    union iwreq_data *wrqu, char *extra)
 {
-	struct ipw_priv *priv = ieee80211_priv(dev);
+	struct ipw_priv *priv = ieee80211_priv(netdev_priv(dev));
 	int level = IPW_POWER_LEVEL(priv->power_mode);
 	char *p = extra;
 
@@ -7428,7 +7427,7 @@
                                     struct iw_request_info *info,
                                     union iwreq_data *wrqu, char *extra)
 {
-        struct ipw_priv *priv = ieee80211_priv(dev);
+        struct ipw_priv *priv = ieee80211_priv(netdev_priv(netdev_priv(dev)));
 	int mode = *(int *)extra;
 	u8 band = 0, modulation = 0;
 
@@ -7495,7 +7494,7 @@
                                     struct iw_request_info *info,
                                     union iwreq_data *wrqu, char *extra)
 {
-        struct ipw_priv *priv = ieee80211_priv(dev);
+        struct ipw_priv *priv = ieee80211_priv(netdev_priv(dev));
 	down(&priv->sem);
 	switch (priv->ieee->mode) {
 	case IEEE_A:
@@ -7538,7 +7537,7 @@
 				   struct iw_request_info *info,
 				   union iwreq_data *wrqu, char *extra)
 {
-	struct ipw_priv *priv = ieee80211_priv(dev);
+	struct ipw_priv *priv = ieee80211_priv(netdev_priv(dev));
 	int mode = *(int *)extra;
 	down(&priv->sem);
 	/* Switching from SHORT -> LONG requires a disassociation */
@@ -7570,7 +7569,7 @@
 			       struct iw_request_info *info,
 			       union iwreq_data *wrqu, char *extra)
 {
-	struct ipw_priv *priv = ieee80211_priv(dev);
+	struct ipw_priv *priv = ieee80211_priv(netdev_priv(dev));
 	down(&priv->sem);
 	if (priv->config & CFG_PREAMBLE_LONG)
 		snprintf(wrqu->name, IFNAMSIZ, "long (1)");
@@ -7745,7 +7744,7 @@
  */
 static struct iw_statistics *ipw_get_wireless_stats(struct net_device * dev)
 {
-	struct ipw_priv *priv = ieee80211_priv(dev);
+	struct ipw_priv *priv = ieee80211_priv(netdev_priv(dev));
 	struct iw_statistics *wstats;
 
 	wstats = &priv->wstats;
@@ -7808,7 +7807,7 @@
 
 static int ipw_net_open(struct net_device *dev)
 {
-	struct ipw_priv *priv = ieee80211_priv(dev);
+	struct ipw_priv *priv = ieee80211_priv(netdev_priv(dev));
 	IPW_DEBUG_INFO("dev->open\n");
 	/* we should be verifying the device is ready to be opened */
 	down(&priv->sem);
@@ -7972,9 +7971,9 @@
 }
 
 static int ipw_net_hard_start_xmit(struct ieee80211_txb *txb,
-				   struct net_device *dev)
+				   struct ieee80211_device *ieee)
 {
-	struct ipw_priv *priv = ieee80211_priv(dev);
+	struct ipw_priv *priv = ieee80211_priv(ieee);
 	unsigned long flags;
 
 	IPW_DEBUG_TX("dev->xmit(%d bytes)\n", txb->payload_size);
@@ -7983,7 +7982,7 @@
 	if (!(priv->status & STATUS_ASSOCIATED)) {
 		IPW_DEBUG_INFO("Tx attempt while not associated.\n");
 		priv->ieee->stats.tx_carrier_errors++;
-		netif_stop_queue(dev);
+		netif_stop_queue(ieee80211_dev(ieee));
 		goto fail_unlock;
 	}
 
@@ -8002,7 +8001,7 @@
 
 static struct net_device_stats *ipw_net_get_stats(struct net_device *dev)
 {
-	struct ipw_priv *priv = ieee80211_priv(dev);
+	struct ipw_priv *priv = ieee80211_priv(netdev_priv(dev));
 
 	priv->ieee->stats.tx_packets = priv->tx_packets;
 	priv->ieee->stats.rx_packets = priv->rx_packets;
@@ -8016,7 +8015,7 @@
 
 static int ipw_net_set_mac_address(struct net_device *dev, void *p)
 {
-	struct ipw_priv *priv = ieee80211_priv(dev);
+	struct ipw_priv *priv = ieee80211_priv(netdev_priv(dev));
 	struct sockaddr *addr = p;
 	if (!is_valid_ether_addr(addr->sa_data))
 		return -EADDRNOTAVAIL;
@@ -8033,7 +8032,7 @@
 static void ipw_ethtool_get_drvinfo(struct net_device *dev,
 				    struct ethtool_drvinfo *info)
 {
-	struct ipw_priv *p = ieee80211_priv(dev);
+	struct ipw_priv *p = ieee80211_priv(netdev_priv(dev));
 	char vers[64];
 	char date[32];
 	u32 len;
@@ -8054,7 +8053,7 @@
 
 static u32 ipw_ethtool_get_link(struct net_device *dev)
 {
-	struct ipw_priv *priv = ieee80211_priv(dev);
+	struct ipw_priv *priv = ieee80211_priv(netdev_priv(dev));
 	return (priv->status & STATUS_ASSOCIATED) != 0;
 }
 
@@ -8066,7 +8065,7 @@
 static int ipw_ethtool_get_eeprom(struct net_device *dev,
 				  struct ethtool_eeprom *eeprom, u8 *bytes)
 {
-	struct ipw_priv *p = ieee80211_priv(dev);
+	struct ipw_priv *p = ieee80211_priv(netdev_priv(dev));
 
 	if (eeprom->offset + eeprom->len > CX2_EEPROM_IMAGE_SIZE)
 		return -EINVAL;
@@ -8079,7 +8078,7 @@
 static int ipw_ethtool_set_eeprom(struct net_device *dev,
 				  struct ethtool_eeprom *eeprom, u8 *bytes)
 {
-	struct ipw_priv *p = ieee80211_priv(dev);
+	struct ipw_priv *p = ieee80211_priv(netdev_priv(dev));
 	int i;
 
 	if (eeprom->offset + eeprom->len > CX2_EEPROM_IMAGE_SIZE)
@@ -8293,10 +8292,10 @@
 }
 
 
-static void shim__set_security(struct net_device *dev,
+static void shim__set_security(struct ieee80211_device *ieee,
 			       struct ieee80211_security *sec)
 {
-	struct ipw_priv *priv = ieee80211_priv(dev);
+	struct ipw_priv *priv = ieee80211_priv(ieee);
 	int i;
 	down(&priv->sem);
 	for (i = 0; i < 4; i++) {
@@ -8579,7 +8578,7 @@
 /* Called by register_netdev() */
 static int ipw_net_init(struct net_device *dev)
 {
-	struct ipw_priv *priv = ieee80211_priv(dev);
+	struct ipw_priv *priv = ieee80211_priv(netdev_priv(dev));
 	down(&priv->sem);
 	if (priv->status & STATUS_RF_KILL_SW) {
 		IPW_WARNING("Radio disabled by module parameter.\n");
@@ -8665,19 +8664,21 @@
 {
 	int err = 0;
 	struct net_device *net_dev;
+	struct ieee80211_device *ieee;
 	void __iomem *base;
 	u32 length, val;
 	struct ipw_priv *priv;
 	int band, modulation;
 
-	net_dev = alloc_ieee80211(sizeof(struct ipw_priv));
-	if (net_dev == NULL) {
+	ieee = alloc_ieee80211(sizeof(struct ipw_priv));
+	if (ieee == NULL) {
 		err = -ENOMEM;
 		goto out;
 	}
+	net_dev = ieee80211_dev(ieee);
 
-	priv = ieee80211_priv(net_dev);
-	priv->ieee = netdev_priv(net_dev);
+	priv = ieee80211_priv(ieee);
+	priv->ieee = ieee;
 
 	priv->net_dev = net_dev;
 	priv->pci_dev = pdev;
@@ -8882,7 +8883,7 @@
 	pci_disable_device(pdev);
 	pci_set_drvdata(pdev, NULL);
  out_free_ieee80211:
-	free_ieee80211(priv->net_dev);
+	free_ieee80211(priv->ieee);
  out:
 	return err;
 }
@@ -8924,7 +8925,7 @@
 	pci_release_regions(pdev);
 	pci_disable_device(pdev);
 	pci_set_drvdata(pdev, NULL);
-	free_ieee80211(priv->net_dev);
+	free_ieee80211(priv->ieee);
 
 #ifdef CONFIG_PM
 	if (fw_loaded) {


--
Jiri Benc
SUSE Labs
