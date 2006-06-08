From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 9/12] d80211: remove useless parameters
Date: Thu,  8 Jun 2006 09:49:13 +0200 (CEST)
Message-ID: <20060608074913.72EAF48396@silver.suse.cz>
References: <20060608094822.014829000.midnight@suse.cz>
Cc: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:52632 "EHLO silver.suse.cz")
	by vger.kernel.org with ESMTP id S964784AbWFHHsC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2006 03:48:02 -0400
To: netdev@vger.kernel.org
In-Reply-To: <20060608094822.014829000.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There is no necessity for passing ieee80211_local parameter to sta_info_put
and sta_info_free now.

Signed-off-by: Jiri Benc <jbenc@suse.cz>

---

 net/d80211/ieee80211.c       |   18 +++++++++---------
 net/d80211/ieee80211_iface.c |    4 ++--
 net/d80211/ieee80211_ioctl.c |   20 ++++++++++----------
 net/d80211/ieee80211_sta.c   |    8 ++++----
 net/d80211/rate_control.c    |    4 ++--
 net/d80211/sta_info.c        |   16 ++++++++--------
 net/d80211/sta_info.h        |    5 ++---
 7 files changed, 37 insertions(+), 38 deletions(-)

bc9e55deef4924f5a4ba82487747726413636df6
diff --git a/net/d80211/ieee80211.c b/net/d80211/ieee80211.c
index 15d43f8..75aaa99 100644
--- a/net/d80211/ieee80211.c
+++ b/net/d80211/ieee80211.c
@@ -1153,7 +1153,7 @@ static int ieee80211_tx(struct net_devic
 	skb = tx.skb; /* handlers are allowed to change skb */
 
 	if (sta)
-		sta_info_put(local, sta);
+		sta_info_put(sta);
 
 	if (unlikely(res == TXRX_DROP)) {
 		I802_DEBUG_INC(local->tx_handlers_drop);
@@ -1373,7 +1373,7 @@ static int ieee80211_subif_start_xmit(st
 			fc |= WLAN_FC_STYPE_QOS_DATA << 4;
 			hdrlen += 2;
 		}
-		sta_info_put(local, sta);
+		sta_info_put(sta);
 	}
 
 	hdr.frame_control = cpu_to_le16(fc);
@@ -1743,7 +1743,7 @@ ieee80211_get_buffered_bc(struct net_dev
 	}
 
 	if (sta)
-		sta_info_put(local, sta);
+		sta_info_put(sta);
 
 	return skb;
 }
@@ -2330,7 +2330,7 @@ ieee80211_rx_h_data(struct ieee80211_txr
 				skb = NULL;
 			}
 			if (dsta)
-				sta_info_put(local, dsta);
+				sta_info_put(dsta);
 		}
 	}
 
@@ -3469,7 +3469,7 @@ void __ieee80211_rx(struct net_device *d
 
   end:
 	if (sta)
-		sta_info_put(local, sta);
+		sta_info_put(sta);
 }
 
 
@@ -3806,7 +3806,7 @@ void ieee80211_tx_status(struct net_devi
 				status->excessive_retries = 0;
 				status->tx_filtered = 1;
 			}
-			sta_info_put(local, sta);
+			sta_info_put(sta);
 		}
 	}
 
@@ -3855,7 +3855,7 @@ void ieee80211_tx_status(struct net_devi
 				}
 				dev_kfree_skb(skb);
 			}
-			sta_info_put(local, sta);
+			sta_info_put(sta);
 			return;
 		}
 	} else {
@@ -3978,8 +3978,8 @@ int ieee80211_if_update_wds(struct net_d
 	/* Remove STA entry for the old peer */
 	sta = sta_info_get(local, sdata->u.wds.remote_addr);
 	if (sta) {
-		sta_info_put(local, sta);
-		sta_info_free(local, sta, 0);
+		sta_info_put(sta);
+		sta_info_free(sta, 0);
 	} else {
 		printk(KERN_DEBUG "%s: could not find STA entry for WDS link "
 		       "peer " MACSTR "\n",
diff --git a/net/d80211/ieee80211_iface.c b/net/d80211/ieee80211_iface.c
index 467dcba..960a90e 100644
--- a/net/d80211/ieee80211_iface.c
+++ b/net/d80211/ieee80211_iface.c
@@ -261,8 +261,8 @@ #endif
 	case IEEE80211_IF_TYPE_WDS:
 		sta = sta_info_get(local, sdata->u.wds.remote_addr);
 		if (sta) {
-			sta_info_put(local, sta);
-			sta_info_free(local, sta, 0);
+			sta_info_put(sta);
+			sta_info_free(sta, 0);
 		} else {
 #ifdef CONFIG_D80211_VERBOSE_DEBUG
 			printk(KERN_DEBUG "%s: Someone had deleted my STA "
diff --git a/net/d80211/ieee80211_ioctl.c b/net/d80211/ieee80211_ioctl.c
index e1bdc03..562b9f3 100644
--- a/net/d80211/ieee80211_ioctl.c
+++ b/net/d80211/ieee80211_ioctl.c
@@ -294,7 +294,7 @@ static int ieee80211_ioctl_add_sta(struc
 		}
 	}
 
-	sta_info_put(local, sta);
+	sta_info_put(sta);
 
 	return 0;
 }
@@ -308,8 +308,8 @@ static int ieee80211_ioctl_remove_sta(st
 
 	sta = sta_info_get(local, param->sta_addr);
 	if (sta) {
-		sta_info_put(local, sta);
-		sta_info_free(local, sta, 1);
+		sta_info_put(sta);
+		sta_info_free(sta, 1);
 	}
 
 	return sta ? 0 : -ENOENT;
@@ -393,7 +393,7 @@ static int ieee80211_ioctl_get_info_sta(
 	param->u.get_info_sta.last_rssi = sta->last_rssi;
 	param->u.get_info_sta.last_ack_rssi = sta->last_ack_rssi[2];
 
-	sta_info_put(local, sta);
+	sta_info_put(sta);
 
 	return 0;
 }
@@ -421,7 +421,7 @@ static int ieee80211_ioctl_set_flags_sta
 			printk(KERN_DEBUG "%s: failed to set low-level driver "
 			       "PAE state (unauthorized) for " MACSTR "\n",
 			       dev->name, MAC2STR(sta->addr));
-		sta_info_put(local, sta);
+		sta_info_put(sta);
 	}
 
 	return sta ? 0 : -ENOENT;
@@ -563,7 +563,7 @@ #endif /* CONFIG_D80211_VERBOSE_DEBUG */
 				if (sta->flags & WLAN_STA_WME) {
 					try_hwaccel = 0;
 				}
-				sta_info_put(local, sta);
+				sta_info_put(sta);
 				sta = NULL;
 			}
 		}
@@ -643,7 +643,7 @@ #endif /* CONFIG_D80211_VERBOSE_DEBUG */
 
  done:
 	if (sta)
-		sta_info_put(local, sta);
+		sta_info_put(sta);
 
 	return ret;
 }
@@ -813,7 +813,7 @@ static int ieee80211_ioctl_get_encryptio
 	}
 
 	if (sta)
-		sta_info_put(local, sta);
+		sta_info_put(sta);
 
 	return ret;
 }
@@ -842,7 +842,7 @@ static int ieee80211_ioctl_wpa_trigger(s
 
 	sta->wpa_trigger = param->u.wpa_trigger.trigger;
 
-	sta_info_put(local, sta);
+	sta_info_put(sta);
 	return 0;
 }
 #endif /* CONFIG_HOSTAPD_WPA_TESTING */
@@ -1136,7 +1136,7 @@ #endif
 			sta->vlan_id = param->u.set_sta_vlan.vlan_id;
                         dev_put(new_vlan_dev);
                 }
-		sta_info_put(local, sta);
+		sta_info_put(sta);
 	}
 
 	return sta ? 0 : -ENOENT;
diff --git a/net/d80211/ieee80211_sta.c b/net/d80211/ieee80211_sta.c
index a42c387..37d40aa 100644
--- a/net/d80211/ieee80211_sta.c
+++ b/net/d80211/ieee80211_sta.c
@@ -730,7 +730,7 @@ static void ieee80211_associated(struct 
 							 ifsta->ssid_len);
 			}
 		}
-		sta_info_put(local, sta);
+		sta_info_put(sta);
 	}
 	if (disassoc) {
 		union iwreq_data wrqu;
@@ -1200,7 +1200,7 @@ static void ieee80211_rx_mgmt_assoc_resp
 	}
 
 
-	sta_info_put(local, sta);
+	sta_info_put(sta);
 
 	ieee80211_associated(dev, ifsta);
 }
@@ -1443,7 +1443,7 @@ #endif /* IEEE80211_IBSS_DEBUG */
 			       dev->name, MAC2STR(sta->addr), prev_rates,
 			       supp_rates, sta->supp_rates);
 		}
-		sta_info_put(local, sta);
+		sta_info_put(sta);
 	}
 
 	if (elems.ssid == NULL)
@@ -1836,7 +1836,7 @@ static void ieee80211_sta_expire(struct 
 			       IEEE80211_IBSS_INACTIVITY_LIMIT)) {
 			printk(KERN_DEBUG "%s: expiring inactive STA " MACSTR
 			       "\n", dev->name, MAC2STR(sta->addr));
-			sta_info_free(local, sta, 1);
+			sta_info_free(sta, 1);
 		}
 	}
 	spin_unlock_bh(&local->sta_lock);
diff --git a/net/d80211/rate_control.c b/net/d80211/rate_control.c
index 9bcb8fc..e7e6791 100644
--- a/net/d80211/rate_control.c
+++ b/net/d80211/rate_control.c
@@ -209,7 +209,7 @@ #endif /* CONFIG_D80211_VERBOSE_DEBUG */
 		}
 	}
 
-	sta_info_put(local, sta);
+	sta_info_put(sta);
 }
 
 
@@ -260,7 +260,7 @@ rate_control_simple_get_rate(struct net_
 	extra->nonerp_idx = nonerp_idx;
 	extra->nonerp = &local->curr_rates[extra->nonerp_idx];
 
-	sta_info_put(local, sta);
+	sta_info_put(sta);
 
 	return &local->curr_rates[rateidx];
 }
diff --git a/net/d80211/sta_info.c b/net/d80211/sta_info.c
index bba4771..9c6adaa 100644
--- a/net/d80211/sta_info.c
+++ b/net/d80211/sta_info.c
@@ -102,7 +102,7 @@ int sta_info_min_txrate_get(struct ieee8
 }
 
 
-void sta_info_put(struct ieee80211_local *local, struct sta_info *sta)
+void sta_info_put(struct sta_info *sta)
 {
 	kobject_put(&sta->kobj);
 }
@@ -200,13 +200,13 @@ #endif /* CONFIG_D80211_VERBOSE_DEBUG */
 	ieee80211_proc_deinit_sta(local, sta);
 	ieee80211_sta_sysfs_remove(sta);
 
-	sta_info_put(local, sta);
+	sta_info_put(sta);
 }
 
-void sta_info_free(struct ieee80211_local *local, struct sta_info *sta,
-		   int locked)
+void sta_info_free(struct sta_info *sta, int locked)
 {
 	struct sk_buff *skb;
+	struct ieee80211_local *local = sta->local;
 	struct ieee80211_sub_if_data *sdata;
 
 	if (!locked)
@@ -320,7 +320,7 @@ static void sta_info_cleanup(unsigned lo
 		struct sta_info *sta = (struct sta_info *) ptr;
 		__sta_info_get(sta);
 		sta_info_cleanup_expire_buffered(local, sta);
-		sta_info_put(local, sta);
+		sta_info_put(sta);
 		ptr = ptr->next;
 	}
 	spin_unlock_bh(&local->sta_lock);
@@ -368,7 +368,7 @@ static void sta_info_proc_add_task(void 
 		sta->sysfs_registered = 1;
 		ieee80211_sta_sysfs_add(sta);
 		ieee80211_proc_init_sta(local, sta);
-		sta_info_put(local, sta);
+		sta_info_put(sta);
 	}
 }
 
@@ -412,7 +412,7 @@ void sta_info_stop(struct ieee80211_loca
 		 * parameter to ensure all sysfs sta entries are
 		 * unregistered. We don't need locking at this
 		 * point. */
-		sta_info_free(local, sta, 0);
+		sta_info_free(sta, 0);
 	}
 	ieee80211_sta_kset_sysfs_unregister(local);
 }
@@ -449,7 +449,7 @@ void sta_info_flush(struct ieee80211_loc
 	list_for_each_safe(ptr, n, &local->sta_list) {
 		struct sta_info *sta = list_entry(ptr, struct sta_info, list);
 		if (dev == NULL || dev == sta->dev)
-			sta_info_free(local, sta, 1);
+			sta_info_free(sta, 1);
 	}
 	spin_unlock_bh(&local->sta_lock);
 }
diff --git a/net/d80211/sta_info.h b/net/d80211/sta_info.h
index ddfe50e..70334e5 100644
--- a/net/d80211/sta_info.h
+++ b/net/d80211/sta_info.h
@@ -134,11 +134,10 @@ #define STA_INFO_CLEANUP_INTERVAL (10 * 
 
 struct sta_info * sta_info_get(struct ieee80211_local *local, u8 *addr);
 int sta_info_min_txrate_get(struct ieee80211_local *local);
-void sta_info_put(struct ieee80211_local *local, struct sta_info *sta);
+void sta_info_put(struct sta_info *sta);
 struct sta_info * sta_info_add(struct ieee80211_local *local,
 			       struct net_device *dev, u8 *addr);
-void sta_info_free(struct ieee80211_local *local, struct sta_info *sta,
-		   int locked);
+void sta_info_free(struct sta_info *sta, int locked);
 void sta_info_release(struct kobject *kobj);
 void sta_info_init(struct ieee80211_local *local);
 int sta_info_start(struct ieee80211_local *local);
-- 
1.3.0

