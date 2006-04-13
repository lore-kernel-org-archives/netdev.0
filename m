From: Zhu Yi <yi.zhu@intel.com>
Subject: [PATCH 14/18] ipw2200: rename CONFIG_IPW_QOS to CONFIG_IPW2200_QOS
Date: Thu, 13 Apr 2006 17:20:45 +0800
Message-ID: <20060413092045.GA28801@mail.intel.com>
Reply-To: yi.zhu@intel.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmr20.intel.com ([134.134.136.19]:6321 "EHLO
	orsfmr005.jf.intel.com") by vger.kernel.org with ESMTP
	id S964853AbWDMJ1z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Apr 2006 05:27:55 -0400
To: netdev@vger.kernel.org, "John W. Linville" <linville@tuxdriver.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Zhu Yi <yi.zhu@intel.com>

---

 drivers/net/wireless/Kconfig   |    2 +-
 drivers/net/wireless/ipw2200.c |   42 ++++++++++++++++++++--------------------
 2 files changed, 22 insertions(+), 22 deletions(-)

b483305435de6baed1194ddaff5b437e0810a4c1
diff --git a/drivers/net/wireless/Kconfig b/drivers/net/wireless/Kconfig
index 5cd9c16..073b4a3 100644
--- a/drivers/net/wireless/Kconfig
+++ b/drivers/net/wireless/Kconfig
@@ -235,7 +235,7 @@ config IPW2200_MONITOR
 	  promiscuous mode via the Wireless Tool's Monitor mode.  While in this
 	  mode, no packets can be sent.
 
-config IPW_QOS
+config IPW2200_QOS
         bool "Enable QoS support"
         depends on IPW2200 && EXPERIMENTAL
 
diff --git a/drivers/net/wireless/ipw2200.c b/drivers/net/wireless/ipw2200.c
index 67e4150..426f306 100644
--- a/drivers/net/wireless/ipw2200.c
+++ b/drivers/net/wireless/ipw2200.c
@@ -107,7 +107,7 @@ static int rtap_iface = 0;     /* def: 0
 #endif
 
 
-#ifdef CONFIG_IPW_QOS
+#ifdef CONFIG_IPW2200_QOS
 static int qos_enable = 0;
 static int qos_burst_enable = 0;
 static int qos_no_ack_mask = 0;
@@ -171,7 +171,7 @@ static int ipw_send_qos_params_command(s
 				       *qos_param);
 static int ipw_send_qos_info_command(struct ipw_priv *priv, struct ieee80211_qos_information_element
 				     *qos_param);
-#endif				/* CONFIG_IPW_QOS */
+#endif				/* CONFIG_IPW2200_QOS */
 
 static struct iw_statistics *ipw_get_wireless_stats(struct net_device *dev);
 static void ipw_remove_current_network(struct ipw_priv *priv);
@@ -4342,7 +4342,7 @@ static void ipw_rx_notification(struct i
 					queue_work(priv->workqueue,
 						   &priv->system_config);
 
-#ifdef CONFIG_IPW_QOS
+#ifdef CONFIG_IPW2200_QOS
 #define IPW_GET_PACKET_STYPE(x) WLAN_FC_GET_STYPE( \
 			 le16_to_cpu(((struct ieee80211_hdr *)(x))->frame_ctl))
 					if ((priv->status & STATUS_AUTH) &&
@@ -6682,7 +6682,7 @@ static int ipw_wx_set_mlme(struct net_de
 	return 0;
 }
 
-#ifdef CONFIG_IPW_QOS
+#ifdef CONFIG_IPW2200_QOS
 
 /* QoS */
 /*
@@ -7148,7 +7148,7 @@ static int ipw_send_qos_info_command(str
 				qos_param);
 }
 
-#endif				/* CONFIG_IPW_QOS */
+#endif				/* CONFIG_IPW2200_QOS */
 
 static int ipw_associate_network(struct ipw_priv *priv,
 				 struct ieee80211_network *network,
@@ -7312,7 +7312,7 @@ static int ipw_associate_network(struct 
 
 	priv->assoc_network = network;
 
-#ifdef CONFIG_IPW_QOS
+#ifdef CONFIG_IPW2200_QOS
 	ipw_qos_association(priv, network);
 #endif
 
@@ -8367,10 +8367,10 @@ static int ipw_sw_reset(struct ipw_priv 
 		IPW_DEBUG_INFO("Bind to static channel %d\n", channel);
 		/* TODO: Validate that provided channel is in range */
 	}
-#ifdef CONFIG_IPW_QOS
+#ifdef CONFIG_IPW2200_QOS
 	ipw_qos_init(priv, qos_enable, qos_burst_enable,
 		     burst_duration_CCK, burst_duration_OFDM);
-#endif				/* CONFIG_IPW_QOS */
+#endif				/* CONFIG_IPW2200_QOS */
 
 	switch (mode) {
 	case 1:
@@ -10040,7 +10040,7 @@ static int ipw_tx_skb(struct ipw_priv *p
 	    txb->fragments[0]->data;
 	int i = 0;
 	struct tfd_frame *tfd;
-#ifdef CONFIG_IPW_QOS
+#ifdef CONFIG_IPW2200_QOS
 	int tx_id = ipw_get_tx_queue_number(priv, pri);
 	struct clx2_tx_queue *txq = &priv->txq[tx_id];
 #else
@@ -10147,10 +10147,10 @@ static int ipw_tx_skb(struct ipw_priv *p
 		/* No hardware encryption */
 		tfd->u.data.tx_flags |= DCT_FLAG_NO_WEP;
 
-#ifdef CONFIG_IPW_QOS
+#ifdef CONFIG_IPW2200_QOS
 	if (fc & IEEE80211_STYPE_QOS_DATA)
 		ipw_qos_set_tx_queue_command(priv, pri, &(tfd->u.data));
-#endif				/* CONFIG_IPW_QOS */
+#endif				/* CONFIG_IPW2200_QOS */
 
 	/* payload */
 	tfd->u.data.num_chunks = cpu_to_le32(min((u8) (NUM_TFD_CHUNKS - 2),
@@ -10230,12 +10230,12 @@ static int ipw_tx_skb(struct ipw_priv *p
 static int ipw_net_is_queue_full(struct net_device *dev, int pri)
 {
 	struct ipw_priv *priv = ieee80211_priv(dev);
-#ifdef CONFIG_IPW_QOS
+#ifdef CONFIG_IPW2200_QOS
 	int tx_id = ipw_get_tx_queue_number(priv, pri);
 	struct clx2_tx_queue *txq = &priv->txq[tx_id];
 #else
 	struct clx2_tx_queue *txq = &priv->txq[0];
-#endif				/* CONFIG_IPW_QOS */
+#endif				/* CONFIG_IPW2200_QOS */
 
 	if (ipw_queue_space(&txq->q) < txq->q.high_mark)
 		return 1;
@@ -10645,10 +10645,10 @@ static int ipw_setup_deferred_work(struc
 	INIT_WORK(&priv->merge_networks,
 		  (void (*)(void *))ipw_merge_adhoc_network, priv);
 
-#ifdef CONFIG_IPW_QOS
+#ifdef CONFIG_IPW2200_QOS
 	INIT_WORK(&priv->qos_activate, (void (*)(void *))ipw_bg_qos_activate,
 		  priv);
-#endif				/* CONFIG_IPW_QOS */
+#endif				/* CONFIG_IPW2200_QOS */
 
 	tasklet_init(&priv->irq_tasklet, (void (*)(unsigned long))
 		     ipw_irq_tasklet, (unsigned long)priv);
@@ -10820,10 +10820,10 @@ static int ipw_config(struct ipw_priv *p
 		if (ipw_send_rts_threshold(priv, priv->rts_threshold))
 			goto error;
 	}
-#ifdef CONFIG_IPW_QOS
+#ifdef CONFIG_IPW2200_QOS
 	IPW_DEBUG_QOS("QoS: call ipw_qos_activate\n");
 	ipw_qos_activate(priv, NULL);
-#endif				/* CONFIG_IPW_QOS */
+#endif				/* CONFIG_IPW2200_QOS */
 
 	if (ipw_set_random_seed(priv))
 		goto error;
@@ -11552,12 +11552,12 @@ static int ipw_pci_probe(struct pci_dev 
 	priv->ieee->set_security = shim__set_security;
 	priv->ieee->is_queue_full = ipw_net_is_queue_full;
 
-#ifdef CONFIG_IPW_QOS
+#ifdef CONFIG_IPW2200_QOS
 	priv->ieee->is_qos_active = ipw_is_qos_active;
 	priv->ieee->handle_probe_response = ipw_handle_beacon;
 	priv->ieee->handle_beacon = ipw_handle_probe_response;
 	priv->ieee->handle_assoc_response = ipw_handle_assoc_response;
-#endif				/* CONFIG_IPW_QOS */
+#endif				/* CONFIG_IPW2200_QOS */
 
 	priv->ieee->perfect_rssi = -20;
 	priv->ieee->worst_rssi = -85;
@@ -11815,7 +11815,7 @@ module_param(rtap_iface, int, 0444);
 MODULE_PARM_DESC(rtap_iface, "create the rtap interface (1 - create, default 0)");
 #endif
 
-#ifdef CONFIG_IPW_QOS
+#ifdef CONFIG_IPW2200_QOS
 module_param(qos_enable, int, 0444);
 MODULE_PARM_DESC(qos_enable, "enable all QoS functionalitis");
 
@@ -11830,7 +11830,7 @@ MODULE_PARM_DESC(burst_duration_CCK, "se
 
 module_param(burst_duration_OFDM, int, 0444);
 MODULE_PARM_DESC(burst_duration_OFDM, "set OFDM burst value");
-#endif				/* CONFIG_IPW_QOS */
+#endif				/* CONFIG_IPW2200_QOS */
 
 #ifdef CONFIG_IPW2200_MONITOR
 module_param(mode, int, 0444);
-- 
1.2.6

