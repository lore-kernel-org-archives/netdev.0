From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH] d80211:  clean up exports
Date: Wed, 23 Aug 2006 12:03:27 +0200
Message-ID: <1156327407.3914.2.camel@ux156>
References: <20060821074107.648561364@sipsolutions.net>
	 <20060821075200.277082970@sipsolutions.net>
	 <20060822164436.GG13240@instant802.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	Jiri Benc <jbenc@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:3554 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S964801AbWHWKDf
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Aug 2006 06:03:35 -0400
To: Jouni Malinen <jkm@devicescape.com>
In-Reply-To: <20060822164436.GG13240@instant802.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This puts all EXPORT_SYMBOL() macros along with the function being exported.

Signed-off-by: Johannes Berg <johannes@sipsolutions.net>

--- wireless-dev.orig/net/d80211/ieee80211.c	2006-08-23 10:35:03.000000000 +0200
+++ wireless-dev/net/d80211/ieee80211.c	2006-08-23 10:35:03.000000000 +0200
@@ -267,6 +267,7 @@ int ieee80211_get_hdrlen(u16 fc)
 
 	return hdrlen;
 }
+EXPORT_SYMBOL(ieee80211_get_hdrlen);
 
 
 int ieee80211_get_hdrlen_from_skb(struct sk_buff *skb)
@@ -281,6 +282,7 @@ int ieee80211_get_hdrlen_from_skb(struct
 		return 0;
 	return hdrlen;
 }
+EXPORT_SYMBOL(ieee80211_get_hdrlen_from_skb);
 
 
 #ifdef IEEE80211_VERBOSE_DEBUG_FRAME_DUMP
@@ -1816,6 +1818,7 @@ struct sk_buff * ieee80211_beacon_get(st
 	ap->num_beacons++;
 	return skb;
 }
+EXPORT_SYMBOL(ieee80211_beacon_get);
 
 
 struct sk_buff *
@@ -1882,6 +1885,7 @@ ieee80211_get_buffered_bc(struct net_dev
 
 	return skb;
 }
+EXPORT_SYMBOL(ieee80211_get_buffered_bc);
 
 static int __ieee80211_if_config(struct net_device *dev,
 				 struct sk_buff *beacon)
@@ -1966,6 +1970,7 @@ struct ieee80211_conf *ieee80211_get_hw_
 	struct ieee80211_local *local = dev->ieee80211_ptr;
         return &local->conf;
 }
+EXPORT_SYMBOL(ieee80211_get_hw_conf);
 
 
 static int ieee80211_change_mtu(struct net_device *dev, int new_mtu)
@@ -2097,6 +2102,7 @@ struct dev_mc_list *ieee80211_get_mc_lis
 	*ptr = sdata;
 	return mc;
 }
+EXPORT_SYMBOL(ieee80211_get_mc_list_item);
 
 static struct net_device_stats *ieee80211_get_stats(struct net_device *dev)
 {
@@ -2644,6 +2650,7 @@ int ieee80211_radar_status(struct net_de
 	ieee80211_rx_mgmt(dev, skb, 0, ieee80211_msg_radar);
 	return 0;
 }
+EXPORT_SYMBOL(ieee80211_radar_status);
 
 
 int ieee80211_set_aid_for_sta(struct net_device *dev, u8 *peer_address,
@@ -2667,6 +2674,7 @@ int ieee80211_set_aid_for_sta(struct net
         ieee80211_rx_mgmt(dev, skb, 0, ieee80211_msg_set_aid_for_sta);
         return 0;
 }
+EXPORT_SYMBOL(ieee80211_set_aid_for_sta);
 
 
 static void ap_sta_ps_start(struct net_device *dev, struct sta_info *sta)
@@ -3692,6 +3700,7 @@ void __ieee80211_rx(struct net_device *d
 	if (sta)
 		sta_info_put(sta);
 }
+EXPORT_SYMBOL(__ieee80211_rx);
 
 
 static ieee80211_txrx_result
@@ -3865,6 +3874,7 @@ void ieee80211_rx_irqsafe(struct net_dev
         skb_queue_tail(&local->skb_queue, skb);
         tasklet_schedule(&local->tasklet);
 }
+EXPORT_SYMBOL(ieee80211_rx_irqsafe);
 
 
 void ieee80211_tx_status_irqsafe(struct net_device *dev, struct sk_buff *skb,
@@ -3894,6 +3904,7 @@ void ieee80211_tx_status_irqsafe(struct 
 	}
         tasklet_schedule(&local->tasklet);
 }
+EXPORT_SYMBOL(ieee80211_tx_status_irqsafe);
 
 
 static void ieee80211_tasklet_handler(unsigned long data)
@@ -4145,6 +4156,7 @@ void ieee80211_tx_status(struct net_devi
         /* Send frame to hostapd */
         ieee80211_rx_mgmt(dev, skb, NULL, msg_type);
 }
+EXPORT_SYMBOL(ieee80211_tx_status);
 
 
 /* TODO: implement register/unregister functions for adding TX/RX handlers
@@ -4397,6 +4409,7 @@ struct net_device *ieee80211_alloc_hw(si
 
 	return mdev;
 }
+EXPORT_SYMBOL(ieee80211_alloc_hw);
 
 
 int ieee80211_register_hw(struct net_device *dev, struct ieee80211_hw *hw)
@@ -4508,6 +4521,7 @@ fail_sysfs:
 	ieee80211_dev_free_index(local);
 	return result;
 }
+EXPORT_SYMBOL(ieee80211_register_hw);
 
 int ieee80211_update_hw(struct net_device *dev, struct ieee80211_hw *hw)
 {
@@ -4539,6 +4553,7 @@ int ieee80211_update_hw(struct net_devic
 
 	return 0;
 }
+EXPORT_SYMBOL(ieee80211_update_hw);
 
 
 void ieee80211_unregister_hw(struct net_device *dev)
@@ -4599,6 +4614,7 @@ void ieee80211_unregister_hw(struct net_
 	ieee80211_dev_free_index(local);
 	ieee80211_led_exit(local);
 }
+EXPORT_SYMBOL(ieee80211_unregister_hw);
 
 void ieee80211_free_hw(struct net_device *dev)
 {
@@ -4608,6 +4624,7 @@ void ieee80211_free_hw(struct net_device
 	ieee80211_wep_free(local);
 	ieee80211_dev_free(local);
 }
+EXPORT_SYMBOL(ieee80211_free_hw);
 
 void ieee80211_release_hw(struct ieee80211_local *local)
 {
@@ -4654,6 +4671,7 @@ int ieee80211_netif_oper(struct net_devi
 
         return 0;
 }
+EXPORT_SYMBOL(ieee80211_netif_oper);
 
 void ieee80211_wake_queue(struct net_device *dev, int queue)
 {
@@ -4668,6 +4686,7 @@ void ieee80211_wake_queue(struct net_dev
 			__netif_schedule(dev);
 	}
 }
+EXPORT_SYMBOL(ieee80211_wake_queue);
 
 void ieee80211_stop_queue(struct net_device *dev, int queue)
 {
@@ -4675,6 +4694,7 @@ void ieee80211_stop_queue(struct net_dev
 
 	set_bit(IEEE80211_LINK_STATE_XOFF, &local->state[queue]);
 }
+EXPORT_SYMBOL(ieee80211_stop_queue);
 
 void ieee80211_start_queues(struct net_device *dev)
 {
@@ -4684,12 +4704,14 @@ void ieee80211_start_queues(struct net_d
 	for (i = 0; i < local->hw->queues; i++)
 		clear_bit(IEEE80211_LINK_STATE_XOFF, &local->state[i]);
 }
+EXPORT_SYMBOL(ieee80211_start_queues);
 
 void * ieee80211_dev_hw_data(struct net_device *dev)
 {
 	struct ieee80211_local *local = dev->ieee80211_ptr;
 	return local->hw_priv;
 }
+EXPORT_SYMBOL(ieee80211_dev_hw_data);
 
 
 void * ieee80211_dev_stats(struct net_device *dev)
@@ -4723,6 +4745,7 @@ void ieee80211_rate_control_unregister(s
 	list_del(&ops->list);
 	mutex_unlock(&ieee80211_rate_ctrl_mtx);
 }
+EXPORT_SYMBOL(ieee80211_dev_stats);
 
 
 static int rate_control_initialize(struct ieee80211_local *local)
@@ -4795,34 +4818,6 @@ static void __exit ieee80211_exit(void)
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
 
--- wireless-dev.orig/net/d80211/sta_info.c	2006-08-23 10:35:03.000000000 +0200
+++ wireless-dev/net/d80211/sta_info.c	2006-08-23 10:35:03.000000000 +0200
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

