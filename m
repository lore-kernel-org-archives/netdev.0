From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 7/21] d80211: clean up exports
Date: Wed, 23 Aug 2006 21:24:16 +0200 (CEST)
Message-ID: <20060823192416.0EFB9483A7@silver.suse.cz>
References: <20060823212316.333159079.midnight@suse.cz>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:28624 "EHLO silver.suse.cz")
	by vger.kernel.org with ESMTP id S965134AbWHWTYQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2006 15:24:16 -0400
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20060823212316.333159079.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Johannes Berg <johannes@sipsolutions.net>

This puts all EXPORT_SYMBOL() macros along with the function being exported.

Signed-off-by: Johannes Berg <johannes@sipsolutions.net>
Signed-off-by: Jiri Benc <jbenc@suse.cz>

---

 net/d80211/ieee80211.c |   69 +++++++++++++++++-------------------------------
 net/d80211/sta_info.c  |    2 +
 2 files changed, 27 insertions(+), 44 deletions(-)

d7d4b1971ecdd40b8a0b210ddd06d9d8ac972255
diff --git a/net/d80211/ieee80211.c b/net/d80211/ieee80211.c
index 1846d3e..9416538 100644
--- a/net/d80211/ieee80211.c
+++ b/net/d80211/ieee80211.c
@@ -270,7 +270,7 @@ int ieee80211_get_hdrlen(u16 fc)
 
 	return hdrlen;
 }
-
+EXPORT_SYMBOL(ieee80211_get_hdrlen);
 
 int ieee80211_get_hdrlen_from_skb(struct sk_buff *skb)
 {
@@ -284,7 +284,7 @@ int ieee80211_get_hdrlen_from_skb(struct
 		return 0;
 	return hdrlen;
 }
-
+EXPORT_SYMBOL(ieee80211_get_hdrlen_from_skb);
 
 #ifdef IEEE80211_VERBOSE_DEBUG_FRAME_DUMP
 static void ieee80211_dump_frame(const char *ifname, const char *title,
@@ -1827,7 +1827,7 @@ #endif /* CONFIG_D80211_VERBOSE_DEBUG */
 	ap->num_beacons++;
 	return skb;
 }
-
+EXPORT_SYMBOL(ieee80211_beacon_get);
 
 struct sk_buff *
 ieee80211_get_buffered_bc(struct net_device *dev, int if_id,
@@ -1893,6 +1893,7 @@ ieee80211_get_buffered_bc(struct net_dev
 
 	return skb;
 }
+EXPORT_SYMBOL(ieee80211_get_buffered_bc);
 
 static int __ieee80211_if_config(struct net_device *dev,
 				 struct sk_buff *beacon)
@@ -1977,7 +1978,7 @@ struct ieee80211_conf *ieee80211_get_hw_
 	struct ieee80211_local *local = dev->ieee80211_ptr;
         return &local->conf;
 }
-
+EXPORT_SYMBOL(ieee80211_get_hw_conf);
 
 static int ieee80211_change_mtu(struct net_device *dev, int new_mtu)
 {
@@ -2108,6 +2109,7 @@ struct dev_mc_list *ieee80211_get_mc_lis
 	*ptr = sdata;
 	return mc;
 }
+EXPORT_SYMBOL(ieee80211_get_mc_list_item);
 
 static struct net_device_stats *ieee80211_get_stats(struct net_device *dev)
 {
@@ -2655,7 +2657,7 @@ int ieee80211_radar_status(struct net_de
 	ieee80211_rx_mgmt(dev, skb, 0, ieee80211_msg_radar);
 	return 0;
 }
-
+EXPORT_SYMBOL(ieee80211_radar_status);
 
 int ieee80211_set_aid_for_sta(struct net_device *dev, u8 *peer_address,
 			      u16 aid)
@@ -2678,7 +2680,7 @@ int ieee80211_set_aid_for_sta(struct net
         ieee80211_rx_mgmt(dev, skb, 0, ieee80211_msg_set_aid_for_sta);
         return 0;
 }
-
+EXPORT_SYMBOL(ieee80211_set_aid_for_sta);
 
 static void ap_sta_ps_start(struct net_device *dev, struct sta_info *sta)
 {
@@ -3705,7 +3707,7 @@ void __ieee80211_rx(struct net_device *d
 	if (sta)
 		sta_info_put(sta);
 }
-
+EXPORT_SYMBOL(__ieee80211_rx);
 
 static ieee80211_txrx_result
 ieee80211_tx_h_load_stats(struct ieee80211_txrx_data *tx)
@@ -3878,7 +3880,7 @@ void ieee80211_rx_irqsafe(struct net_dev
         skb_queue_tail(&local->skb_queue, skb);
         tasklet_schedule(&local->tasklet);
 }
-
+EXPORT_SYMBOL(ieee80211_rx_irqsafe);
 
 void ieee80211_tx_status_irqsafe(struct net_device *dev, struct sk_buff *skb,
 				 struct ieee80211_tx_status *status)
@@ -3907,7 +3909,7 @@ void ieee80211_tx_status_irqsafe(struct 
 	}
         tasklet_schedule(&local->tasklet);
 }
-
+EXPORT_SYMBOL(ieee80211_tx_status_irqsafe);
 
 static void ieee80211_tasklet_handler(unsigned long data)
 {
@@ -4161,7 +4163,7 @@ #endif /* IEEE80211_LEDS */
         /* Send frame to hostapd */
         ieee80211_rx_mgmt(dev, skb, NULL, msg_type);
 }
-
+EXPORT_SYMBOL(ieee80211_tx_status);
 
 /* TODO: implement register/unregister functions for adding TX/RX handlers
  * into ordered list */
@@ -4413,7 +4415,7 @@ struct net_device *ieee80211_alloc_hw(si
 
 	return mdev;
 }
-
+EXPORT_SYMBOL(ieee80211_alloc_hw);
 
 int ieee80211_register_hw(struct net_device *dev, struct ieee80211_hw *hw)
 {
@@ -4522,6 +4524,7 @@ fail_sysfs:
 	ieee80211_dev_free_index(local);
 	return result;
 }
+EXPORT_SYMBOL(ieee80211_register_hw);
 
 int ieee80211_update_hw(struct net_device *dev, struct ieee80211_hw *hw)
 {
@@ -4553,7 +4556,7 @@ int ieee80211_update_hw(struct net_devic
 
 	return 0;
 }
-
+EXPORT_SYMBOL(ieee80211_update_hw);
 
 void ieee80211_unregister_hw(struct net_device *dev)
 {
@@ -4612,6 +4615,7 @@ void ieee80211_unregister_hw(struct net_
 
 	ieee80211_dev_free_index(local);
 }
+EXPORT_SYMBOL(ieee80211_unregister_hw);
 
 void ieee80211_free_hw(struct net_device *dev)
 {
@@ -4621,6 +4625,7 @@ void ieee80211_free_hw(struct net_device
 	ieee80211_wep_free(local);
 	ieee80211_dev_free(local);
 }
+EXPORT_SYMBOL(ieee80211_free_hw);
 
 void ieee80211_release_hw(struct ieee80211_local *local)
 {
@@ -4667,6 +4672,7 @@ #endif
 
         return 0;
 }
+EXPORT_SYMBOL(ieee80211_netif_oper);
 
 void ieee80211_wake_queue(struct net_device *dev, int queue)
 {
@@ -4681,6 +4687,7 @@ void ieee80211_wake_queue(struct net_dev
 			__netif_schedule(dev);
 	}
 }
+EXPORT_SYMBOL(ieee80211_wake_queue);
 
 void ieee80211_stop_queue(struct net_device *dev, int queue)
 {
@@ -4688,6 +4695,7 @@ void ieee80211_stop_queue(struct net_dev
 
 	set_bit(IEEE80211_LINK_STATE_XOFF, &local->state[queue]);
 }
+EXPORT_SYMBOL(ieee80211_stop_queue);
 
 void ieee80211_start_queues(struct net_device *dev)
 {
@@ -4697,13 +4705,14 @@ void ieee80211_start_queues(struct net_d
 	for (i = 0; i < local->hw->queues; i++)
 		clear_bit(IEEE80211_LINK_STATE_XOFF, &local->state[i]);
 }
+EXPORT_SYMBOL(ieee80211_start_queues);
 
 void * ieee80211_dev_hw_data(struct net_device *dev)
 {
 	struct ieee80211_local *local = dev->ieee80211_ptr;
 	return local->hw_priv;
 }
-
+EXPORT_SYMBOL(ieee80211_dev_hw_data);
 
 void * ieee80211_dev_stats(struct net_device *dev)
 {
@@ -4711,7 +4720,7 @@ void * ieee80211_dev_stats(struct net_de
 	sdata = IEEE80211_DEV_TO_SUB_IF(dev);
 	return &(sdata->stats);
 }
-
+EXPORT_SYMBOL(ieee80211_dev_stats);
 
 int ieee80211_rate_control_register(struct rate_control_ops *ops)
 {
@@ -4727,7 +4736,7 @@ int ieee80211_rate_control_register(stru
 
 	return 0;
 }
-
+EXPORT_SYMBOL(ieee80211_rate_control_register);
 
 void ieee80211_rate_control_unregister(struct rate_control_ops *ops)
 {
@@ -4748,7 +4757,7 @@ void ieee80211_rate_control_unregister(s
 		alg = alg->next;
 	}
 }
-
+EXPORT_SYMBOL(ieee80211_rate_control_unregister);
 
 static int rate_control_initialize(struct ieee80211_local *local)
 {
@@ -4813,34 +4822,6 @@ static void __exit ieee80211_exit(void)
 }
 
 
-EXPORT_SYMBOL(ieee80211_alloc_hw);
-EXPORT_SYMBOL(ieee80211_register_hw);
-EXPORT_SYMBOL(ieee80211_update_hw);
-EXPORT_SYMBOL(ieee80211_unregister_hw);
-EXPORT_SYMBOL(ieee80211_free_hw);
-EXPORT_SYMBOL(__ieee80211_rx);
-EXPORT_SYMBOL(ieee80211_tx_status);
-EXPORT_SYMBOL(ieee80211_beacon_get);
-EXPORT_SYMBOL(ieee80211_get_buffered_bc);
-EXPORT_SYMBOL(ieee80211_netif_oper);
-EXPORT_SYMBOL(ieee80211_wake_queue);
-EXPORT_SYMBOL(ieee80211_stop_queue);
-EXPORT_SYMBOL(ieee80211_start_queues);
-EXPORT_SYMBOL(ieee80211_dev_hw_data);
-EXPORT_SYMBOL(ieee80211_dev_stats);
-EXPORT_SYMBOL(ieee80211_get_hw_conf);
-EXPORT_SYMBOL(ieee80211_set_aid_for_sta);
-EXPORT_SYMBOL(ieee80211_rx_irqsafe);
-EXPORT_SYMBOL(ieee80211_tx_status_irqsafe);
-EXPORT_SYMBOL(ieee80211_get_hdrlen);
-EXPORT_SYMBOL(ieee80211_get_hdrlen_from_skb);
-EXPORT_SYMBOL(ieee80211_rate_control_register);
-EXPORT_SYMBOL(ieee80211_rate_control_unregister);
-EXPORT_SYMBOL(sta_info_get);
-EXPORT_SYMBOL(sta_info_put);
-EXPORT_SYMBOL(ieee80211_radar_status);
-EXPORT_SYMBOL(ieee80211_get_mc_list_item);
-
 module_init(ieee80211_init);
 module_exit(ieee80211_exit);
 
diff --git a/net/d80211/sta_info.c b/net/d80211/sta_info.c
index dd5bc97..5d4b001 100644
--- a/net/d80211/sta_info.c
+++ b/net/d80211/sta_info.c
@@ -76,6 +76,7 @@ struct sta_info * sta_info_get(struct ie
 
 	return sta;
 }
+EXPORT_SYMBOL(sta_info_get);
 
 int sta_info_min_txrate_get(struct ieee80211_local *local)
 {
@@ -104,6 +105,7 @@ void sta_info_put(struct sta_info *sta)
 {
 	kobject_put(&sta->kobj);
 }
+EXPORT_SYMBOL(sta_info_put);
 
 void sta_info_release(struct kobject *kobj)
 {
-- 
1.3.0

