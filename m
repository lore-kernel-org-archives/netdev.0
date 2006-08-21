From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH 13/18] d80211:  clean up some coding style issues
Date: Mon, 21 Aug 2006 09:41:20 +0200
Message-ID: <20060821075201.468651135@sipsolutions.net>
References: <20060821074107.648561364@sipsolutions.net>
Mime-Version: 1.0
Cc: Jouni Malinen <jkm@devicescape.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Jiri Benc <jbenc@suse.cz>,
	Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:58048 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1030338AbWHUICP
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Aug 2006 04:02:15 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline; filename=d80211-coding-style.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Try to reduce the coding style nits people will point out once
we post integration patches.

Signed-off-by: Johannes Berg <johannes@sipsolutions.net>

--- wireless-dev.orig/net/d80211/ieee80211.c	2006-08-20 20:13:29.932819787 +0200
+++ wireless-dev/net/d80211/ieee80211.c	2006-08-20 20:32:55.212819787 +0200
@@ -36,22 +36,15 @@
 /* See IEEE 802.1H for LLC/SNAP encapsulation/decapsulation */
 /* Ethernet-II snap header (RFC1042 for most EtherTypes) */
 static unsigned char rfc1042_header[] =
-{ 0xaa, 0xaa, 0x03, 0x00, 0x00, 0x00 };
+	{ 0xaa, 0xaa, 0x03, 0x00, 0x00, 0x00 };
+
 /* Bridge-Tunnel header (for EtherTypes ETH_P_AARP and ETH_P_IPX) */
 static unsigned char bridge_tunnel_header[] =
-{ 0xaa, 0xaa, 0x03, 0x00, 0x00, 0xf8 };
-/* No encapsulation header if EtherType < 0x600 (=length) */
+	{ 0xaa, 0xaa, 0x03, 0x00, 0x00, 0xf8 };
 
+/* No encapsulation header if EtherType < 0x600 (=length) */
 static unsigned char eapol_header[] =
-{ 0xaa, 0xaa, 0x03, 0x00, 0x00, 0x00, 0x88, 0x8e };
-
-static int rate_control_initialize(struct ieee80211_local *local);
-
-
-static u8 * ieee80211_get_bssid(struct ieee80211_hdr *hdr, size_t len);
-
-static int ieee80211_mgmt_start_xmit(struct sk_buff *skb,
-				     struct net_device *dev);
+	{ 0xaa, 0xaa, 0x03, 0x00, 0x00, 0x00, 0x88, 0x8e };
 
 struct ieee80211_key_conf *
 ieee80211_key_data2conf(struct ieee80211_local *local,
@@ -479,7 +472,8 @@ ieee80211_tx_h_fragment(struct ieee80211
 		fhdr = (struct ieee80211_hdr *) skb_put(frag, hdrlen);
 		memcpy(fhdr, first->data, hdrlen);
 		if (i == num_fragm - 2)
-			fhdr->frame_control &= cpu_to_le16(~IEEE80211_FCTL_MOREFRAGS);
+			fhdr->frame_control &=
+				cpu_to_le16(~IEEE80211_FCTL_MOREFRAGS);
 		fhdr->seq_ctrl = cpu_to_le16(i + 1);
 		copylen = left > per_fragm ? per_fragm : left;
 		memcpy(skb_put(frag, copylen), pos, copylen);
@@ -515,8 +509,7 @@ static int wep_encrypt_skb(struct ieee80
 	} else {
 		tx->u.tx.control->key_idx = tx->key->hw_key_idx;
 		if (tx->local->hw->wep_include_iv) {
-			if (ieee80211_wep_add_iv(tx->local, skb, tx->key) ==
-			    NULL)
+			if (!ieee80211_wep_add_iv(tx->local, skb, tx->key))
 				return -1;
 		}
         }
@@ -535,7 +528,8 @@ void ieee80211_tx_set_iswep(struct ieee8
 		for (i = 0; i < tx->u.tx.num_extra_frag; i++) {
 			fhdr = (struct ieee80211_hdr *)
 				tx->u.tx.extra_frag[i]->data;
-			fhdr->frame_control |= cpu_to_le16(IEEE80211_FCTL_PROTECTED);
+			fhdr->frame_control |=
+				cpu_to_le16(IEEE80211_FCTL_PROTECTED);
 		}
 	}
 }
@@ -1173,7 +1167,8 @@ static int __ieee80211_tx(struct ieee802
 	int ret, i;
 
 	if (skb) {
-		ieee80211_dump_frame(local->mdev->name, "TX to low-level driver", skb);
+		ieee80211_dump_frame(local->mdev->name,
+				     "TX to low-level driver", skb);
 		ret = local->hw->tx(local->mdev, skb, control);
 		if (ret)
 			return IEEE80211_TX_AGAIN;
@@ -1266,9 +1261,9 @@ static void ieee80211_tx(struct net_devi
 				(struct ieee80211_hdr *)
 				tx.u.tx.extra_frag[i]->data;
 
-			if (i + 1 < tx.u.tx.num_extra_frag) {
+			if (i + 1 < tx.u.tx.num_extra_frag)
 				next_len = tx.u.tx.extra_frag[i + 1]->len;
-			} else {
+			else {
 				next_len = 0;
 				tx.u.tx.rate = tx.u.tx.last_frag_rate;
 				tx.u.tx.last_frag_hwrate = tx.u.tx.rate->val;
@@ -1731,8 +1726,8 @@ static void ieee80211_beacon_add_tim(str
 }
 
 
-struct sk_buff * ieee80211_beacon_get(struct net_device *dev, int if_id,
-				      struct ieee80211_tx_control *control)
+struct sk_buff *ieee80211_beacon_get(struct net_device *dev, int if_id,
+				     struct ieee80211_tx_control *control)
 {
 	struct ieee80211_local *local = dev->ieee80211_ptr;
 	struct sk_buff *skb;
@@ -1775,9 +1770,8 @@ struct sk_buff * ieee80211_beacon_get(st
 
 	ieee80211_beacon_add_tim(local, ap, skb);
 
-	if (b_tail) {
+	if (b_tail)
 		memcpy(skb_put(skb, bt_len), b_tail, bt_len);
-	}
 
 	if (control) {
 		memset(&extra, 0, sizeof(extra));
@@ -1786,16 +1780,18 @@ struct sk_buff * ieee80211_beacon_get(st
 		rate = rate_control_get_rate(dev, skb, &extra);
 		if (!rate) {
 			if (net_ratelimit()) {
-				printk(KERN_DEBUG "%s: ieee80211_beacon_get: no rate "
-				       "found\n", dev->name);
+				printk(KERN_DEBUG "%s: ieee80211_beacon_get: "
+				       "no rate found\n", dev->name);
 			}
 			dev_kfree_skb(skb);
 			return NULL;
 		}
 
-		control->tx_rate = (local->short_preamble &&
-				    (rate->flags & IEEE80211_RATE_PREAMBLE2)) ?
-			rate->val2 : rate->val;
+		if (local->short_preamble &&
+		    (rate->flags & IEEE80211_RATE_PREAMBLE2))
+			control->tx_rate = rate->val2;
+		else
+			control->tx_rate = rate->val;
 		control->antenna_sel = local->conf.antenna_sel;
 		control->power_level = local->conf.power_level;
 		control->no_ack = 1;
@@ -1940,9 +1936,8 @@ int ieee80211_hw_config(struct net_devic
 	for (i = 0; i < local->hw->num_modes; i++) {
 		struct ieee80211_hw_modes *mode = &local->hw->modes[i];
 		if (mode->mode == local->conf.phymode) {
-			if (local->curr_rates != mode->rates) {
+			if (local->curr_rates != mode->rates)
 				rate_control_clear(local);
-			}
 			local->curr_rates = mode->rates;
 			local->num_curr_rates = mode->num_rates;
 			ieee80211_prepare_rates(dev);
@@ -2386,9 +2381,8 @@ ieee80211_rx_h_data(struct ieee80211_txr
 		memcpy(dst, hdr->addr1, ETH_ALEN);
 		memcpy(src, hdr->addr3, ETH_ALEN);
 
-		if (sdata->type != IEEE80211_IF_TYPE_STA) {
+		if (sdata->type != IEEE80211_IF_TYPE_STA)
 			return TXRX_DROP;
-		}
 		break;
 	case 0:
 		/* DA SA BSSID */
@@ -2458,10 +2452,10 @@ ieee80211_rx_h_data(struct ieee80211_txr
 		} else {
 			struct sta_info *dsta;
                         dsta = sta_info_get(local, skb->data);
-			if (dsta && !dsta->dev) {
-                                printk(KERN_DEBUG "Station with null dev "
+			if (dsta && !dsta->dev)
+				printk(KERN_DEBUG "Station with null dev "
 				       "structure!\n");
-                        } else if (dsta && dsta->dev == dev) {
+			else if (dsta && dsta->dev == dev) {
 				/* Destination station is associated to this
 				 * AP, so send the frame directly to it and
 				 * do not pass the frame to local net stack.
@@ -2768,18 +2762,24 @@ ieee80211_rx_h_ps_poll(struct ieee80211_
 		/* Use MoreData flag to indicate whether there are more
 		 * buffered frames for this STA */
 		if (no_pending_pkts) {
-			hdr->frame_control &= cpu_to_le16(~IEEE80211_FCTL_MOREDATA);
+			hdr->frame_control &=
+				cpu_to_le16(~IEEE80211_FCTL_MOREDATA);
 			rx->sta->flags &= ~WLAN_STA_TIM;
 		} else
-			hdr->frame_control |= cpu_to_le16(IEEE80211_FCTL_MOREDATA);
+			hdr->frame_control |=
+				cpu_to_le16(IEEE80211_FCTL_MOREDATA);
 
 		dev_queue_xmit(skb);
 
 		if (no_pending_pkts) {
 			if (rx->local->hw->set_tim)
-				rx->local->hw->set_tim(rx->dev, rx->sta->aid, 0);
+				rx->local->hw->set_tim(rx->dev,
+						       rx->sta->aid,
+						       0);
 			if (rx->sdata->bss)
-				bss_tim_clear(rx->local, rx->sdata->bss, rx->sta->aid);
+				bss_tim_clear(rx->local,
+					      rx->sdata->bss,
+					      rx->sta->aid);
 		}
 #ifdef IEEE80211_VERBOSE_DEBUG_PS
 	} else if (!rx->u.rx.sent_ps_buffered) {
@@ -3078,9 +3078,9 @@ ieee80211_rx_h_check(struct ieee80211_tx
 	else
 		always_sta_key = 1;
 
-	if (rx->sta && rx->sta->key && always_sta_key) {
+	if (rx->sta && rx->sta->key && always_sta_key)
 		rx->key = rx->sta->key;
-        } else {
+	else {
 		if (rx->sta && rx->sta->key)
 			rx->key = rx->sta->key;
 		else
@@ -3125,6 +3125,39 @@ ieee80211_rx_h_check(struct ieee80211_tx
 	return TXRX_CONTINUE;
 }
 
+static u8 *ieee80211_get_bssid(struct ieee80211_hdr *hdr, size_t len)
+{
+	u16 fc;
+
+	if (len < 24)
+		return NULL;
+
+	fc = le16_to_cpu(hdr->frame_control);
+
+	switch (fc & IEEE80211_FCTL_FTYPE) {
+	case IEEE80211_FTYPE_DATA:
+		switch (fc & (IEEE80211_FCTL_TODS | IEEE80211_FCTL_FROMDS)) {
+		case IEEE80211_FCTL_TODS:
+			return hdr->addr1;
+		case (IEEE80211_FCTL_TODS | IEEE80211_FCTL_FROMDS):
+			return NULL;
+		case IEEE80211_FCTL_FROMDS:
+			return hdr->addr2;
+		case 0:
+			return hdr->addr3;
+		}
+		break;
+	case IEEE80211_FTYPE_MGMT:
+		return hdr->addr3;
+	case IEEE80211_FTYPE_CTL:
+		if ((fc & IEEE80211_FCTL_STYPE) == IEEE80211_STYPE_PSPOLL)
+			return hdr->addr1;
+		else
+			return NULL;
+	}
+
+	return NULL;
+}
 
 static ieee80211_txrx_result
 ieee80211_rx_h_sta_process(struct ieee80211_txrx_data *rx)
@@ -3195,13 +3228,10 @@ ieee80211_rx_h_wep_weak_iv_detection(str
 		return TXRX_CONTINUE;
 
 	/* Check for weak IVs, if hwaccel did not remove IV from the frame */
-	if (rx->local->hw->wep_include_iv ||
-	    rx->key->force_sw_encrypt || rx->local->conf.sw_decrypt) {
-		u8 *iv = ieee80211_wep_is_weak_iv(rx->skb, rx->key);
-		if (iv) {
-			rx->sta->wep_weak_iv_count++;
-		}
-	}
+	if ((rx->local->hw->wep_include_iv ||
+	     rx->key->force_sw_encrypt || rx->local->conf.sw_decrypt)
+	    && ieee80211_wep_is_weak_iv(rx->skb, rx->key))
+		rx->sta->wep_weak_iv_count++;
 
 	return TXRX_CONTINUE;
 }
@@ -3370,41 +3400,6 @@ ieee80211_rx_h_passive_scan(struct ieee8
         return TXRX_CONTINUE;
 }
 
-
-static u8 * ieee80211_get_bssid(struct ieee80211_hdr *hdr, size_t len)
-{
-	u16 fc;
-
-	if (len < 24)
-		return NULL;
-
-	fc = le16_to_cpu(hdr->frame_control);
-
-	switch (fc & IEEE80211_FCTL_FTYPE) {
-	case IEEE80211_FTYPE_DATA:
-		switch (fc & (IEEE80211_FCTL_TODS | IEEE80211_FCTL_FROMDS)) {
-		case IEEE80211_FCTL_TODS:
-			return hdr->addr1;
-		case (IEEE80211_FCTL_TODS | IEEE80211_FCTL_FROMDS):
-			return NULL;
-		case IEEE80211_FCTL_FROMDS:
-			return hdr->addr2;
-		case 0:
-			return hdr->addr3;
-		}
-		break;
-	case IEEE80211_FTYPE_MGMT:
-		return hdr->addr3;
-	case IEEE80211_FTYPE_CTL:
-		if ((fc & IEEE80211_FCTL_STYPE) == IEEE80211_STYPE_PSPOLL)
-			return hdr->addr1;
-		else
-			return NULL;
-	}
-
-	return NULL;
-}
-
 static void ieee80211_rx_michael_mic_report(struct net_device *dev,
 					    struct ieee80211_hdr *hdr,
 					    struct sta_info *sta,
@@ -3518,9 +3513,8 @@ static inline ieee80211_txrx_result __ie
 		}
 	}
 
-	if (res == TXRX_DROP) {
+	if (res == TXRX_DROP)
 		dev_kfree_skb(rx->skb);
-	}
 	return res;
 }
 
@@ -3626,7 +3620,8 @@ void __ieee80211_rx(struct net_device *d
 					rx.u.rx.ra_match = 0;
 				} else if (!sta)
 					sta = rx.sta =
-						ieee80211_ibss_add_sta(dev, skb, bssid,
+						ieee80211_ibss_add_sta(dev, skb,
+								       bssid,
 								       hdr->addr2);
 						/* FIXME: call with sdata->dev */
 				break;
@@ -3661,9 +3656,11 @@ void __ieee80211_rx(struct net_device *d
 				skb_new = skb_copy(skb, GFP_ATOMIC);
 				if (!skb_new) {
 					if (net_ratelimit())
-						printk(KERN_DEBUG "%s: failed to copy "
-						       "multicast frame for %s",
-						       dev->name, prev->dev->name);
+						printk(KERN_DEBUG "%s: failed "
+						       "to copy multicast frame "
+						       "for %s",
+						       dev->name,
+						       prev->dev->name);
 					continue;
 				}
 				rx.skb = skb_new;
@@ -4400,6 +4397,27 @@ struct net_device *ieee80211_alloc_hw(si
 }
 EXPORT_SYMBOL(ieee80211_alloc_hw);
 
+static int rate_control_initialize(struct ieee80211_local *local)
+{
+	struct rate_control_ops *rctrl;
+
+	BUG_ON(local->rate_ctrl);
+
+	rctrl = ieee80211_rate_control_select(NULL);
+	if (rctrl) {
+		rate_control_alloc(local, rctrl);
+		if (local->rate_ctrl) {
+			printk(KERN_DEBUG "%s: Selected rate control "
+			       "algorithm '%s'\n", local->mdev->name,
+			       local->rate_ctrl->name);
+			return 0;
+		}
+	}
+
+	printk(KERN_WARNING "%s: Failed to select rate control algorithm\n",
+	       local->mdev->name);
+	return -1;
+}
 
 int ieee80211_register_hw(struct net_device *dev, struct ieee80211_hw *hw)
 {
@@ -4447,7 +4465,8 @@ int ieee80211_register_hw(struct net_dev
 		rtnl_unlock();
 		goto fail_dev;
 	}
-	sysfs_create_link(&local->class_dev.kobj, &dev->class_dev.kobj, "master");
+	sysfs_create_link(&local->class_dev.kobj, &dev->class_dev.kobj,
+			  "master");
 	result = ieee80211_sysfs_add_netdevice(dev);
 	rtnl_unlock();
 	if (result < 0)
@@ -4687,7 +4706,7 @@ void ieee80211_start_queues(struct net_d
 }
 EXPORT_SYMBOL(ieee80211_start_queues);
 
-void * ieee80211_dev_hw_data(struct net_device *dev)
+void *ieee80211_dev_hw_data(struct net_device *dev)
 {
 	struct ieee80211_local *local = dev->ieee80211_ptr;
 	return local->hw_priv;
@@ -4695,7 +4714,7 @@ void * ieee80211_dev_hw_data(struct net_
 EXPORT_SYMBOL(ieee80211_dev_hw_data);
 
 
-void * ieee80211_dev_stats(struct net_device *dev)
+void *ieee80211_dev_stats(struct net_device *dev)
 {
 	struct ieee80211_sub_if_data *sdata;
 	sdata = IEEE80211_DEV_TO_SUB_IF(dev);
@@ -4704,29 +4723,6 @@ void * ieee80211_dev_stats(struct net_de
 EXPORT_SYMBOL(ieee80211_dev_stats);
 
 
-static int rate_control_initialize(struct ieee80211_local *local)
-{
-	struct rate_control_ops *rctrl;
-
-	BUG_ON(local->rate_ctrl);
-
-	rctrl = ieee80211_rate_control_select(NULL);
-	if (rctrl) {
-		rate_control_alloc(local, rctrl);
-		if (local->rate_ctrl) {
-			printk(KERN_DEBUG "%s: Selected rate control "
-			       "algorithm '%s'\n", local->mdev->name,
-			       local->rate_ctrl->name);
-			return 0;
-		}
-	}
-
-	printk(KERN_WARNING "%s: Failed to select rate control algorithm\n",
-	       local->mdev->name);
-	return -1;
-}
-
-
 static int __init ieee80211_init(void)
 {
 	struct sk_buff *skb;
--- wireless-dev.orig/net/d80211/ieee80211_ioctl.c	2006-08-20 20:13:40.372819787 +0200
+++ wireless-dev/net/d80211/ieee80211_ioctl.c	2006-08-20 20:13:49.872819787 +0200
@@ -605,9 +605,8 @@ static int ieee80211_set_encryption(stru
 		else if (sdata->type == IEEE80211_IF_TYPE_STA) {
 			sta = sta_info_get(local, sdata->u.sta.bssid);
 			if (sta) {
-				if (sta->flags & WLAN_STA_WME) {
+				if (sta->flags & WLAN_STA_WME)
 					try_hwaccel = 0;
-				}
 				sta_info_put(sta);
 				sta = NULL;
 			}
@@ -2018,9 +2017,8 @@ static int ieee80211_ioctl_siwrts(struct
 	/* If the wlan card performs RTS/CTS in hardware/firmware,
 	 * configure it here */
 
-	if (local->hw->set_rts_threshold) {
+	if (local->hw->set_rts_threshold)
 		local->hw->set_rts_threshold(dev, local->rts_threshold);
-	}
 
 	return 0;
 }
@@ -2421,9 +2419,9 @@ static int ieee80211_ioctl_prism2_param(
                         local->rate_limit_bucket = local->rate_limit_burst;
 			local->rate_limit_timer.expires = jiffies + HZ;
 			add_timer(&local->rate_limit_timer);
-		} else if (local->rate_limit && !value) {
+		} else if (local->rate_limit && !value)
 			del_timer_sync(&local->rate_limit_timer);
-		}
+
 		local->rate_limit = value;
 		break;
 
@@ -2431,9 +2429,9 @@ static int ieee80211_ioctl_prism2_param(
                 if (!local->stat_time && value) {
                         local->stat_timer.expires = jiffies + HZ * value / 100;
                         add_timer(&local->stat_timer);
-                } else if (local->stat_time && !value) {
+                } else if (local->stat_time && !value)
                         del_timer_sync(&local->stat_timer);
-                }
+
                 local->stat_time = value;
                 break;
 	case PRISM2_PARAM_SHORT_SLOT_TIME:
--- wireless-dev.orig/net/d80211/ieee80211_scan.c	2006-08-20 20:13:30.022819787 +0200
+++ wireless-dev/net/d80211/ieee80211_scan.c	2006-08-20 20:13:49.882819787 +0200
@@ -38,9 +38,8 @@ static void get_channel_params(struct ie
 	local->scan.chan_idx = 0;
 	do {
 		*chan = &(*mode)->channels[local->scan.chan_idx];
-		if ((*chan)->chan == channel) {
+		if ((*chan)->chan == channel)
 			return;
-		}
 		local->scan.chan_idx++;
 	} while (local->scan.chan_idx < (*mode)->num_channels);
 	*chan = NULL;
@@ -222,9 +221,8 @@ static void ieee80211_scan_stop(struct n
 
 	mode = &local->hw->modes[local->scan.mode_idx];
 
-	if (local->scan.chan_idx >= mode->num_channels) {
+	if (local->scan.chan_idx >= mode->num_channels)
 		local->scan.chan_idx = 0;
-	}
 
 	chan = &mode->channels[local->scan.chan_idx];
 
--- wireless-dev.orig/net/d80211/ieee80211_sta.c	2006-08-20 20:13:30.062819787 +0200
+++ wireless-dev/net/d80211/ieee80211_sta.c	2006-08-20 20:32:53.612819787 +0200
@@ -262,28 +262,24 @@ static void ieee80211_sta_wmm_params(str
 		switch (aci) {
 		case 1:
 			queue = IEEE80211_TX_QUEUE_DATA3;
-			if (acm) {
+			if (acm)
 				local->wmm_acm |= BIT(1) | BIT(2);
-			}
 			break;
 		case 2:
 			queue = IEEE80211_TX_QUEUE_DATA1;
-			if (acm) {
+			if (acm)
 				local->wmm_acm |= BIT(4) | BIT(5);
-			}
 			break;
 		case 3:
 			queue = IEEE80211_TX_QUEUE_DATA0;
-			if (acm) {
+			if (acm)
 				local->wmm_acm |= BIT(6) | BIT(7);
-			}
 			break;
 		case 0:
 		default:
 			queue = IEEE80211_TX_QUEUE_DATA2;
-			if (acm) {
+			if (acm)
 				local->wmm_acm |= BIT(0) | BIT(3);
-			}
 			break;
 		}
 
@@ -492,9 +488,8 @@ static void ieee80211_send_assoc(struct 
 	if (bss) {
 		if (bss->capability & WLAN_CAPABILITY_PRIVACY)
 			capab |= WLAN_CAPABILITY_PRIVACY;
-		if (bss->wmm_ie) {
+		if (bss->wmm_ie)
 			wmm = 1;
-		}
 		ieee80211_rx_bss_put(dev, bss);
 	}
 
@@ -1011,9 +1006,8 @@ static void ieee80211_rx_mgmt_deauth(str
 	       " (reason=%d)\n",
 	       dev->name, MAC_ARG(mgmt->sa), reason_code);
 
-	if (ifsta->authenticated) {
+	if (ifsta->authenticated)
 		printk(KERN_DEBUG "%s: deauthenticated\n", dev->name);
-	}
 
 	if (ifsta->state == IEEE80211_AUTHENTICATE ||
 	    ifsta->state == IEEE80211_ASSOCIATE ||
@@ -2162,9 +2156,9 @@ static int ieee80211_sta_create_ibss(str
 	bss->freq = local->conf.freq;
 	bss->last_update = jiffies;
 	bss->capability = cpu_to_le16(WLAN_CAPABILITY_IBSS);
-	if (sdata->default_key) {
+	if (sdata->default_key)
 		bss->capability |= cpu_to_le16(WLAN_CAPABILITY_PRIVACY);
-	} else
+	else
 		sdata->drop_unencrypted = 0;
 	bss->supp_rates_len = local->num_curr_rates;
 	pos = bss->supp_rates;
@@ -2782,9 +2776,9 @@ int ieee80211_sta_set_extra_ie(struct ne
 }
 
 
-struct sta_info * ieee80211_ibss_add_sta(struct net_device *dev,
-					 struct sk_buff *skb, u8 *bssid,
-					 u8 *addr)
+struct sta_info *ieee80211_ibss_add_sta(struct net_device *dev,
+					struct sk_buff *skb, u8 *bssid,
+					u8 *addr)
 {
 	struct ieee80211_local *local = dev->ieee80211_ptr;
 	struct list_head *ptr;
--- wireless-dev.orig/net/d80211/ieee80211_sysfs.c	2006-08-20 20:13:30.102819787 +0200
+++ wireless-dev/net/d80211/ieee80211_sysfs.c	2006-08-20 20:13:49.902819787 +0200
@@ -18,8 +18,10 @@
 #include "ieee80211_i.h"
 #include "rate_control.h"
 
-#define to_ieee80211_local(class)	container_of(class, struct ieee80211_local, class_dev)
-#define to_net_dev(class)		container_of(class, struct net_device, class_dev)
+#define to_ieee80211_local(class)\
+	container_of(class, struct ieee80211_local, class_dev)
+#define to_net_dev(class)\
+	container_of(class, struct net_device, class_dev)
 
 static inline int rtnl_lock_local(struct ieee80211_local *local)
 {
@@ -245,18 +247,56 @@ static struct class_device_attribute iee
 	__ATTR(radar_detect, S_IRUGO, ieee80211_local_show_radar_detect, NULL),
 	__ATTR(antenna_sel, S_IRUGO, ieee80211_local_show_antenna_sel, NULL),
 	__ATTR(calib_int, S_IRUGO, ieee80211_local_show_calib_int, NULL),
-	__ATTR(bridge_packets, S_IRUGO, ieee80211_local_show_bridge_packets, NULL),
-	__ATTR(key_tx_rx_threshold, S_IRUGO, ieee80211_local_show_key_tx_rx_threshold, NULL),
-	__ATTR(rts_threshold, S_IRUGO, ieee80211_local_show_rts_threshold, NULL),
-	__ATTR(fragmentation_threshold, S_IRUGO, ieee80211_local_show_fragmentation_threshold, NULL),
-	__ATTR(short_retry_limit, S_IRUGO, ieee80211_local_show_short_retry_limit, NULL),
-	__ATTR(long_retry_limit, S_IRUGO, ieee80211_local_show_long_retry_limit, NULL),
-	__ATTR(total_ps_buffered, S_IRUGO, ieee80211_local_show_total_ps_buffered, NULL),
+	__ATTR(bridge_packets,
+	       S_IRUGO,
+	       ieee80211_local_show_bridge_packets,
+	       NULL),
+
+	__ATTR(key_tx_rx_threshold,
+	       S_IRUGO,
+	       ieee80211_local_show_key_tx_rx_threshold,
+	       NULL),
+
+	__ATTR(rts_threshold,
+	       S_IRUGO,
+	       ieee80211_local_show_rts_threshold,
+	       NULL),
+
+	__ATTR(fragmentation_threshold,
+	       S_IRUGO,
+	       ieee80211_local_show_fragmentation_threshold,
+	       NULL),
+
+	__ATTR(short_retry_limit,
+	       S_IRUGO,
+	       ieee80211_local_show_short_retry_limit,
+	       NULL),
+
+	__ATTR(long_retry_limit,
+	       S_IRUGO,
+	       ieee80211_local_show_long_retry_limit,
+	       NULL),
+
+	__ATTR(total_ps_buffered,
+	       S_IRUGO,
+	       ieee80211_local_show_total_ps_buffered,
+	       NULL),
+
 	__ATTR(mode, S_IRUGO, ieee80211_local_show_mode, NULL),
+
 	__ATTR(wep_iv, S_IRUGO, ieee80211_local_show_wep_iv, NULL),
-	__ATTR(tx_power_reduction, S_IRUGO, ieee80211_local_show_tx_power_reduction, NULL),
+
+	__ATTR(tx_power_reduction,
+	       S_IRUGO,
+	       ieee80211_local_show_tx_power_reduction,
+	       NULL),
+
 	__ATTR(modes, S_IRUGO, ieee80211_local_show_modes, NULL),
-	__ATTR(rate_ctrl_alg, S_IRUGO, ieee80211_local_show_rate_ctrl_alg, NULL),
+
+	__ATTR(rate_ctrl_alg,
+	       S_IRUGO,
+	       ieee80211_local_show_rate_ctrl_alg,
+	       NULL),
 	{}
 };
 
@@ -266,14 +306,17 @@ static struct class_device_attribute iee
 IEEE80211_LOCAL_SHOW(name, field, format)				\
 static CLASS_DEVICE_ATTR(name, S_IRUGO, ieee80211_local_show_##name, NULL);
 
-IEEE80211_LOCAL_ATTR(transmitted_fragment_count, dot11TransmittedFragmentCount, "%u");
-IEEE80211_LOCAL_ATTR(multicast_transmitted_frame_count, dot11MulticastTransmittedFrameCount, "%u");
+IEEE80211_LOCAL_ATTR(transmitted_fragment_count,
+		     dot11TransmittedFragmentCount, "%u");
+IEEE80211_LOCAL_ATTR(multicast_transmitted_frame_count,
+		     dot11MulticastTransmittedFrameCount, "%u");
 IEEE80211_LOCAL_ATTR(failed_count, dot11FailedCount, "%u");
 IEEE80211_LOCAL_ATTR(retry_count, dot11RetryCount, "%u");
 IEEE80211_LOCAL_ATTR(multiple_retry_count, dot11MultipleRetryCount, "%u");
 IEEE80211_LOCAL_ATTR(frame_duplicate_count, dot11FrameDuplicateCount, "%u");
 IEEE80211_LOCAL_ATTR(received_fragment_count, dot11ReceivedFragmentCount, "%u");
-IEEE80211_LOCAL_ATTR(multicast_received_frame_count, dot11MulticastReceivedFrameCount, "%u");
+IEEE80211_LOCAL_ATTR(multicast_received_frame_count,
+		     dot11MulticastReceivedFrameCount, "%u");
 IEEE80211_LOCAL_ATTR(transmitted_frame_count, dot11TransmittedFrameCount, "%u");
 IEEE80211_LOCAL_ATTR(wep_undecryptable_count, dot11WEPUndecryptableCount, "%u");
 IEEE80211_LOCAL_ATTR(num_scans, scan.num_scans, "%u");
@@ -281,20 +324,28 @@ IEEE80211_LOCAL_ATTR(num_scans, scan.num
 #ifdef CONFIG_D80211_DEBUG_COUNTERS
 IEEE80211_LOCAL_ATTR(tx_handlers_drop, tx_handlers_drop, "%u");
 IEEE80211_LOCAL_ATTR(tx_handlers_queued, tx_handlers_queued, "%u");
-IEEE80211_LOCAL_ATTR(tx_handlers_drop_unencrypted, tx_handlers_drop_unencrypted, "%u");
-IEEE80211_LOCAL_ATTR(tx_handlers_drop_fragment, tx_handlers_drop_fragment, "%u");
+IEEE80211_LOCAL_ATTR(tx_handlers_drop_unencrypted,
+		     tx_handlers_drop_unencrypted, "%u");
+IEEE80211_LOCAL_ATTR(tx_handlers_drop_fragment,
+		     tx_handlers_drop_fragment, "%u");
 IEEE80211_LOCAL_ATTR(tx_handlers_drop_wep, tx_handlers_drop_wep, "%u");
-IEEE80211_LOCAL_ATTR(tx_handlers_drop_rate_limit, tx_handlers_drop_rate_limit, "%u");
-IEEE80211_LOCAL_ATTR(tx_handlers_drop_not_assoc, tx_handlers_drop_not_assoc, "%u");
-IEEE80211_LOCAL_ATTR(tx_handlers_drop_unauth_port, tx_handlers_drop_unauth_port, "%u");
+IEEE80211_LOCAL_ATTR(tx_handlers_drop_rate_limit,
+		     tx_handlers_drop_rate_limit, "%u");
+IEEE80211_LOCAL_ATTR(tx_handlers_drop_not_assoc,
+		     tx_handlers_drop_not_assoc, "%u");
+IEEE80211_LOCAL_ATTR(tx_handlers_drop_unauth_port,
+		     tx_handlers_drop_unauth_port, "%u");
 IEEE80211_LOCAL_ATTR(rx_handlers_drop, rx_handlers_drop, "%u");
 IEEE80211_LOCAL_ATTR(rx_handlers_queued, rx_handlers_queued, "%u");
-IEEE80211_LOCAL_ATTR(rx_handlers_drop_nullfunc, rx_handlers_drop_nullfunc, "%u");
+IEEE80211_LOCAL_ATTR(rx_handlers_drop_nullfunc,
+		     rx_handlers_drop_nullfunc, "%u");
 IEEE80211_LOCAL_ATTR(rx_handlers_drop_defrag, rx_handlers_drop_defrag, "%u");
 IEEE80211_LOCAL_ATTR(rx_handlers_drop_short, rx_handlers_drop_short, "%u");
-IEEE80211_LOCAL_ATTR(rx_handlers_drop_passive_scan, rx_handlers_drop_passive_scan, "%u");
+IEEE80211_LOCAL_ATTR(rx_handlers_drop_passive_scan,
+		     rx_handlers_drop_passive_scan, "%u");
 IEEE80211_LOCAL_ATTR(tx_expand_skb_head, tx_expand_skb_head, "%u");
-IEEE80211_LOCAL_ATTR(tx_expand_skb_head_cloned, tx_expand_skb_head_cloned, "%u");
+IEEE80211_LOCAL_ATTR(tx_expand_skb_head_cloned,
+		     tx_expand_skb_head_cloned, "%u");
 IEEE80211_LOCAL_ATTR(rx_expand_skb_head, rx_expand_skb_head, "%u");
 IEEE80211_LOCAL_ATTR(rx_expand_skb_head2, rx_expand_skb_head2, "%u");
 IEEE80211_LOCAL_ATTR(rx_handlers_fragments, rx_handlers_fragments, "%u");
@@ -432,10 +483,10 @@ static ssize_t ieee80211_if_show(struct 
 	ssize_t ret = -EINVAL;
 
 	read_lock(&dev_base_lock);
-	if (dev->reg_state == NETREG_REGISTERED) {
+	if (dev->reg_state == NETREG_REGISTERED)
 		ret = (*format)(sdata, buf);
-	}
 	read_unlock(&dev_base_lock);
+
 	return ret;
 }
 
--- wireless-dev.orig/net/d80211/rate_control_simple.c	2006-08-20 20:13:30.172819787 +0200
+++ wireless-dev/net/d80211/rate_control_simple.c	2006-08-20 20:13:49.902819787 +0200
@@ -169,18 +169,17 @@ static void rate_control_simple_tx_statu
 		}
 #endif
 
-		if (per_failed > local->rate_ctrl_num_down) {
+		if (per_failed > local->rate_ctrl_num_down)
 			rate_control_rate_dec(local, sta);
-		} else if (per_failed < local->rate_ctrl_num_up) {
+		else if (per_failed < local->rate_ctrl_num_up)
 			rate_control_rate_inc(local, sta);
-		}
+
 		srctrl->tx_avg_rate_sum += local->curr_rates[sta->txrate].rate;
 		srctrl->tx_avg_rate_num++;
 		srctrl->tx_num_failures = 0;
 		srctrl->tx_num_xmit = 0;
-	} else if (sta->tx_num_consecutive_failures >= RATE_CONTROL_EMERG_DEC) {
+	} else if (sta->tx_num_consecutive_failures >= RATE_CONTROL_EMERG_DEC)
 		rate_control_rate_dec(local, sta);
-	}
 
 	if (srctrl->avg_rate_update + 60 * HZ < jiffies) {
 		srctrl->avg_rate_update = jiffies;
--- wireless-dev.orig/net/d80211/wme.c	2006-08-20 20:13:30.192819787 +0200
+++ wireless-dev/net/d80211/wme.c	2006-08-20 20:13:49.912819787 +0200
@@ -38,19 +38,17 @@ ieee80211_rx_h_parse_qos(struct ieee8021
 		/* frame has qos control */
 		tid = qc[0] & QOS_CONTROL_TID_MASK;
 	} else {
-		if (unlikely((rx->fc & IEEE80211_FCTL_FTYPE) == IEEE80211_FTYPE_MGMT)) {
+		if (unlikely((rx->fc & IEEE80211_FCTL_FTYPE) == IEEE80211_FTYPE_MGMT))
 			/* Separate TID for management frames */
 			tid = NUM_RX_DATA_QUEUES - 1;
-		} else {
+		else
 			/* no qos control present */
 			tid = 0; /* 802.1d - Best Effort */
-		}
 	}
 #ifdef CONFIG_D80211_DEBUG_COUNTERS
 	I802_DEBUG_INC(rx->local->wme_rx_queue[tid]);
-	if (rx->sta) {
+	if (rx->sta)
 		I802_DEBUG_INC(rx->sta->wme_rx_queue[tid]);
-	}
 #endif /* CONFIG_D80211_DEBUG_COUNTERS */
 
 	rx->u.rx.queue = tid;
@@ -184,11 +182,10 @@ static inline int classify80211(struct s
 	const int ieee802_1d_to_ac[8] = { 2, 3, 3, 2, 1, 1, 0, 0 };
 
 	/* see if frame is data or non data frame */
-	if (unlikely((fc & IEEE80211_FCTL_FTYPE) != IEEE80211_FTYPE_DATA)) {
+	if (unlikely((fc & IEEE80211_FCTL_FTYPE) != IEEE80211_FTYPE_DATA))
 		/* management frames go on AC_VO queue, but are sent
 		* without QoS control fields */
 		return IEEE80211_TX_QUEUE_DATA0;
-	}
 
 	if (unlikely(pkt_data->mgmt_iface)) {
 		/* Data frames from hostapd (mainly, EAPOL) use AC_VO
@@ -213,11 +210,10 @@ static inline int classify80211(struct s
 	/* incase we are a client verify acm is not set for this ac */
 	for (; unlikely(local->wmm_acm & BIT(skb->priority)); )
 	{
-		if (wme_downgrade_ac(skb)) {
+		if (wme_downgrade_ac(skb))
 			/* No AC with lower priority has acm=0,
 			* drop packet. */
 			return -1;
-		}
 	}
 
 	/* look up which queue to use for frames with this 1d tag */
@@ -402,9 +398,8 @@ static int wme_qdiscop_init(struct Qdisc
 		return -EINVAL;
 
 	/* if options were passed in, set them */
-	if (opt) {
+	if (opt)
 		err = wme_qdiscop_tune(qd, opt);
-	}
 
 	/* create child queues */
 	for (i = 0; i < queues; i++) {
@@ -412,7 +407,8 @@ static int wme_qdiscop_init(struct Qdisc
 		q->queues[i] = qdisc_create_dflt(qd->dev, &CHILD_QDISC_OPS);
 		if (q->queues[i] == 0) {
 			q->queues[i] = &noop_qdisc;
-			printk(KERN_ERR "%s child qdisc %i creation failed", dev->name, i);
+			printk(KERN_ERR "%s child qdisc %i creation failed",
+			       dev->name, i);
 		}
 	}
 
@@ -588,7 +584,8 @@ static struct tcf_proto ** wme_classop_f
 }
 
 
-/* this qdisc is classful (i.e. has classes, some of which may have leaf qdiscs attached)
+/* this qdisc is classful (i.e. has classes,
+ * some of which may have leaf qdiscs attached)
  * - these are the operations on the classes */
 static struct Qdisc_class_ops class_ops =
 {
--- wireless-dev.orig/net/d80211/wpa.c	2006-08-20 20:13:30.232819787 +0200
+++ wireless-dev/net/d80211/wpa.c	2006-08-20 20:32:51.772819787 +0200
@@ -184,9 +184,8 @@ ieee80211_rx_h_michael_mic_verify(struct
 		return TXRX_CONTINUE;
 
 #ifdef CONFIG_HOSTAPD_WPA_TESTING
-	if (rx->sta && rx->sta->wpa_trigger & WPA_TRIGGER_FAIL_RX_MIC) {
+	if (rx->sta && rx->sta->wpa_trigger & WPA_TRIGGER_FAIL_RX_MIC)
 		wpa_test = 1;
-	}
 #endif /* CONFIG_HOSTAPD_WPA_TESTING */
 
 #ifdef MICHAEL_MIC_HWACCEL
@@ -498,7 +497,8 @@ ieee80211_rx_h_tkip_decrypt(struct ieee8
 		hwaccel = 1;
 	}
 
-	res = ieee80211_tkip_decrypt_data(rx->local->wep_tfm, key, skb->data + hdrlen,
+	res = ieee80211_tkip_decrypt_data(rx->local->wep_tfm, key,
+					  skb->data + hdrlen,
 					  skb->len - hdrlen, rx->sta->addr,
 					  hwaccel, rx->u.rx.queue);
 	if (res != TKIP_DECRYPT_OK || wpa_test) {
--- wireless-dev.orig/net/d80211/aes_ccm.c	2006-08-20 20:13:30.272819787 +0200
+++ wireless-dev/net/d80211/aes_ccm.c	2006-08-20 20:13:49.922819787 +0200
@@ -143,7 +143,7 @@ int ieee80211_aes_ccm_decrypt(struct cry
 }
 
 
-struct crypto_tfm * ieee80211_aes_key_setup_encrypt(const u8 key[])
+struct crypto_tfm *ieee80211_aes_key_setup_encrypt(const u8 key[])
 {
 	struct crypto_tfm *tfm;
 
--- wireless-dev.orig/net/d80211/aes_ccm.h	2006-08-20 20:13:30.342819787 +0200
+++ wireless-dev/net/d80211/aes_ccm.h	2006-08-20 20:13:49.922819787 +0200
@@ -14,7 +14,7 @@
 
 #define AES_BLOCK_LEN 16
 
-struct crypto_tfm * ieee80211_aes_key_setup_encrypt(const u8 key[]);
+struct crypto_tfm *ieee80211_aes_key_setup_encrypt(const u8 key[]);
 void ieee80211_aes_ccm_encrypt(struct crypto_tfm *tfm, u8 *scratch,
 			       u8 *b_0, u8 *aad, u8 *data, size_t data_len,
 			       u8 *cdata, u8 *mic);
--- wireless-dev.orig/net/d80211/ieee80211_i.h	2006-08-20 20:13:30.362819787 +0200
+++ wireless-dev/net/d80211/ieee80211_i.h	2006-08-20 20:13:49.922819787 +0200
@@ -637,9 +637,9 @@ void ieee80211_sta_rx_scan(struct net_de
 void ieee80211_rx_bss_list_init(struct net_device *dev);
 void ieee80211_rx_bss_list_deinit(struct net_device *dev);
 int ieee80211_sta_set_extra_ie(struct net_device *dev, char *ie, size_t len);
-struct sta_info * ieee80211_ibss_add_sta(struct net_device *dev,
-					 struct sk_buff *skb, u8 *bssid,
-					 u8 *addr);
+struct sta_info *ieee80211_ibss_add_sta(struct net_device *dev,
+					struct sk_buff *skb, u8 *bssid,
+					u8 *addr);
 int ieee80211_sta_deauthenticate(struct net_device *dev, u16 reason);
 int ieee80211_sta_disassociate(struct net_device *dev, u16 reason);
 
--- wireless-dev.orig/net/d80211/rate_control.h	2006-08-20 20:13:30.402819787 +0200
+++ wireless-dev/net/d80211/rate_control.h	2006-08-20 20:13:49.922819787 +0200
@@ -121,7 +121,7 @@ static inline void rate_control_free(str
 }
 
 
-static inline void * rate_control_alloc_sta(struct ieee80211_local *local)
+static inline void *rate_control_alloc_sta(struct ieee80211_local *local)
 {
 	return local->rate_ctrl->alloc_sta();
 }
--- wireless-dev.orig/net/d80211/sta_info.c	2006-08-20 20:13:30.442819787 +0200
+++ wireless-dev/net/d80211/sta_info.c	2006-08-20 20:13:49.932819787 +0200
@@ -58,7 +58,7 @@ static inline struct sta_info *__sta_inf
 	return kobject_get(&sta->kobj) ? sta : NULL;
 }
 
-struct sta_info * sta_info_get(struct ieee80211_local *local, u8 *addr)
+struct sta_info *sta_info_get(struct ieee80211_local *local, u8 *addr)
 {
 	struct sta_info *sta;
 
@@ -128,8 +128,8 @@ void sta_info_release(struct kobject *ko
 }
 
 
-struct sta_info * sta_info_add(struct ieee80211_local *local,
-			       struct net_device *dev, u8 *addr)
+struct sta_info *sta_info_add(struct ieee80211_local *local,
+			      struct net_device *dev, u8 *addr)
 {
 	struct sta_info *sta;
 
--- wireless-dev.orig/net/d80211/tkip.c	2006-08-20 20:13:30.482819787 +0200
+++ wireless-dev/net/d80211/tkip.c	2006-08-20 20:13:49.932819787 +0200
@@ -176,8 +176,8 @@ static void tkip_mixing_phase2(const u16
 /* Add TKIP IV and Ext. IV at @pos. @iv0, @iv1, and @iv2 are the first octets
  * of the IV. Returns pointer to the octet following IVs (i.e., beginning of
  * the packet payload). */
-u8 * ieee80211_tkip_add_iv(u8 *pos, struct ieee80211_key *key,
-			   u8 iv0, u8 iv1, u8 iv2)
+u8 *ieee80211_tkip_add_iv(u8 *pos, struct ieee80211_key *key,
+			  u8 iv0, u8 iv1, u8 iv2)
 {
 	*pos++ = iv0;
 	*pos++ = iv1;
@@ -196,7 +196,8 @@ u8 * ieee80211_tkip_add_iv(u8 *pos, stru
  * headroom of eight octets for IV and Ext. IV and taildroom of four octets
  * for ICV. @payload_len is the length of payload (_not_ including extra
  * headroom and tailroom). @ta is the transmitter addresses. */
-void ieee80211_tkip_encrypt_data(struct crypto_tfm *tfm, struct ieee80211_key *key,
+void ieee80211_tkip_encrypt_data(struct crypto_tfm *tfm,
+				 struct ieee80211_key *key,
 				 u8 *pos, size_t payload_len, u8 *ta)
 {
 	u8 rc4key[16];
@@ -221,7 +222,8 @@ void ieee80211_tkip_encrypt_data(struct 
  * beginning of the buffer containing IEEE 802.11 header payload, i.e.,
  * including IV, Ext. IV, real data, Michael MIC, ICV. @payload_len is the
  * length of payload, including IV, Ext. IV, MIC, ICV.  */
-int ieee80211_tkip_decrypt_data(struct crypto_tfm *tfm, struct ieee80211_key *key,
+int ieee80211_tkip_decrypt_data(struct crypto_tfm *tfm,
+				struct ieee80211_key *key,
 				u8 *payload, size_t payload_len, u8 *ta,
 				int only_iv, int queue)
 {
--- wireless-dev.orig/net/d80211/tkip.h	2006-08-20 20:13:30.502819787 +0200
+++ wireless-dev/net/d80211/tkip.h	2006-08-20 20:13:49.932819787 +0200
@@ -13,9 +13,10 @@
 #include <linux/crypto.h>
 #include "ieee80211_key.h"
 
-u8 * ieee80211_tkip_add_iv(u8 *pos, struct ieee80211_key *key,
-			   u8 iv0, u8 iv1, u8 iv2);
-void ieee80211_tkip_encrypt_data(struct crypto_tfm *tfm, struct ieee80211_key *key,
+u8 *ieee80211_tkip_add_iv(u8 *pos, struct ieee80211_key *key,
+			  u8 iv0, u8 iv1, u8 iv2);
+void ieee80211_tkip_encrypt_data(struct crypto_tfm *tfm,
+				 struct ieee80211_key *key,
 				 u8 *pos, size_t payload_len, u8 *ta);
 enum {
 	TKIP_DECRYPT_OK = 0,
@@ -23,7 +24,8 @@ enum {
 	TKIP_DECRYPT_INVALID_KEYIDX = -2,
 	TKIP_DECRYPT_REPLAY = -3,
 };
-int ieee80211_tkip_decrypt_data(struct crypto_tfm *tfm, struct ieee80211_key *key,
+int ieee80211_tkip_decrypt_data(struct crypto_tfm *tfm,
+				struct ieee80211_key *key,
 				u8 *payload, size_t payload_len, u8 *ta,
 				int only_iv, int queue);
 
--- wireless-dev.orig/net/d80211/wep.c	2006-08-20 20:13:30.572819787 +0200
+++ wireless-dev/net/d80211/wep.c	2006-08-20 20:13:49.932819787 +0200
@@ -172,7 +172,8 @@ int ieee80211_wep_encrypt(struct ieee802
 	/* Add room for ICV */
 	skb_put(skb, WEP_ICV_LEN);
 
-	ieee80211_wep_encrypt_data(local->wep_tfm, rc4key, klen, iv + WEP_IV_LEN, len);
+	ieee80211_wep_encrypt_data(local->wep_tfm, rc4key, klen,
+				   iv + WEP_IV_LEN, len);
 
 	kfree(rc4key);
 
--- wireless-dev.orig/include/net/d80211.h	2006-08-20 20:32:58.982819787 +0200
+++ wireless-dev/include/net/d80211.h	2006-08-20 20:34:00.682819787 +0200
@@ -366,8 +366,13 @@ struct ieee80211_if_conf {
 	struct sk_buff *beacon;
 };
 
-typedef enum { ALG_NONE, ALG_WEP, ALG_TKIP, ALG_CCMP, ALG_NULL }
-ieee80211_key_alg;
+typedef enum {
+	ALG_NONE,
+	ALG_WEP,
+	ALG_TKIP,
+	ALG_CCMP,
+	ALG_NULL
+} ieee80211_key_alg;
 
 
 struct ieee80211_key_conf {
@@ -414,15 +419,17 @@ struct ieee80211_scan_conf {
         struct sk_buff *skb; /* skb to transmit before changing channels, maybe
 			      * NULL for none */
         struct ieee80211_tx_control *tx_control;
-
 };
 
 #define IEEE80211_SEQ_COUNTER_RX	0
 #define IEEE80211_SEQ_COUNTER_TX	1
 
 typedef enum {
-	SET_KEY, DISABLE_KEY, REMOVE_ALL_KEYS,
-	ENABLE_COMPRESSION, DISABLE_COMPRESSION
+	SET_KEY,
+	DISABLE_KEY,
+	REMOVE_ALL_KEYS,
+	ENABLE_COMPRESSION,
+	DISABLE_COMPRESSION
 } set_key_cmd;
 
 /* Configuration block used by the low-level driver to tell 802.11 code about

--
