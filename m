From: Kirtika Ruchandani <kirtika.ruchandani@gmail.com>
Subject: [PATCH] cfg80211: Fix checkpatch issues
Date: Sat, 28 May 2016 01:05:23 -0700
Message-ID: <1464422723-7241-1-git-send-email-kirtika.ruchandani@gmail.com>
Cc: Kirtika Ruchandani <kirtika.ruchandani@gmail.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, davem@davemloft.net
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix the following issues reported by checkpatch.pl -
- document spinlock_t where needed/possible
- do not use multiple blank lines
- add blank line after a declaration
- use a trailing '*/' on a separate line in block comments
- don't use empty '/*' lines
- use ether_addr_copy instead of memcpy
- fix line over 80 chars
- match alignment of function arguments to open parentheses

Signed-off-by: Kirtika Ruchandani <kirtika.ruchandani@gmail.com>
---
 net/wireless/core.c | 73 +++++++++++++++++++++++------------------------------
 net/wireless/core.h | 33 +++++++++++++-----------
 2 files changed, 49 insertions(+), 57 deletions(-)

diff --git a/net/wireless/core.c b/net/wireless/core.c
index d25c82b..f7b14af 100644
--- a/net/wireless/core.c
+++ b/net/wireless/core.c
@@ -102,8 +102,7 @@ static int cfg80211_dev_check_name(struct cfg80211_registered_device *rdev,
 		digits = 1;
 		while (wiphy_idx /= 10)
 			digits++;
-		/*
-		 * deny the name if it is phy<idx> where <idx> is printed
+		/* deny the name if it is phy<idx> where <idx> is printed
 		 * without leading zeroes. taken == strlen(newname) here
 		 */
 		if (taken == strlen(PHY_NAME) + digits)
@@ -179,7 +178,7 @@ int cfg80211_switch_netns(struct cfg80211_registered_device *rdev,
 				continue;
 			wdev->netdev->features &= ~NETIF_F_NETNS_LOCAL;
 			err = dev_change_net_namespace(wdev->netdev, net,
-							"wlan%d");
+						       "wlan%d");
 			WARN_ON(err);
 			wdev->netdev->features |= NETIF_F_NETNS_LOCAL;
 		}
@@ -267,7 +266,8 @@ static void cfg80211_rfkill_sync_work(struct work_struct *work)
 {
 	struct cfg80211_registered_device *rdev;

-	rdev = container_of(work, struct cfg80211_registered_device, rfkill_sync);
+	rdev = container_of(work, struct cfg80211_registered_device,
+			    rfkill_sync);
 	cfg80211_rfkill_set_block(rdev, rfkill_blocked(rdev->rfkill));
 }

@@ -328,7 +328,7 @@ static void cfg80211_sched_scan_stop_wk(struct work_struct *work)
 	struct cfg80211_registered_device *rdev;

 	rdev = container_of(work, struct cfg80211_registered_device,
-			   sched_scan_stop_wk);
+			    sched_scan_stop_wk);

 	rtnl_lock();

@@ -461,15 +461,14 @@ use_default_name:

 	init_waitqueue_head(&rdev->dev_wait);

-	/*
-	 * Initialize wiphy parameters to IEEE 802.11 MIB default values.
+	/* Initialize wiphy parameters to IEEE 802.11 MIB default values.
 	 * Fragmentation and RTS threshold are disabled by default with the
 	 * special -1 value.
 	 */
 	rdev->wiphy.retry_short = 7;
 	rdev->wiphy.retry_long = 4;
-	rdev->wiphy.frag_threshold = (u32) -1;
-	rdev->wiphy.rts_threshold = (u32) -1;
+	rdev->wiphy.frag_threshold = (u32)-1;
+	rdev->wiphy.rts_threshold = (u32)-1;
 	rdev->wiphy.coverage_class = 0;

 	rdev->wiphy.max_num_csa_counters = 1;
@@ -492,8 +491,7 @@ static int wiphy_verify_combinations(struct wiphy *wiphy)

 		c = &wiphy->iface_combinations[i];

-		/*
-		 * Combinations with just one interface aren't real,
+		/* Combinations with just one interface aren't real,
 		 * however we make an exception for DFS.
 		 */
 		if (WARN_ON((c->max_interfaces < 2) && !c->radar_detect_widths))
@@ -503,8 +501,7 @@ static int wiphy_verify_combinations(struct wiphy *wiphy)
 		if (WARN_ON(!c->num_different_channels))
 			return -EINVAL;

-		/*
-		 * Put a sane limit on maximum number of different
+		/* Put a sane limit on maximum number of different
 		 * channels to simplify channel accounting code.
 		 */
 		if (WARN_ON(c->num_different_channels >
@@ -540,8 +537,7 @@ static int wiphy_verify_combinations(struct wiphy *wiphy)
 				return -EINVAL;

 			cnt += c->limits[j].max;
-			/*
-			 * Don't advertise an unsupported type
+			/* Don't advertise an unsupported type
 			 * in a combination.
 			 */
 			if (WARN_ON((wiphy->interface_modes & types) != types))
@@ -581,8 +577,7 @@ int wiphy_register(struct wiphy *wiphy)
 		     !rdev->ops->tdls_cancel_channel_switch)))
 		return -EINVAL;

-	/*
-	 * if a wiphy has unsupported modes for regulatory channel enforcement,
+	/* if a wiphy has unsupported modes for regulatory channel enforcement,
 	 * opt-out of enforcement checking
 	 */
 	if (wiphy->interface_modes & ~(BIT(NL80211_IFTYPE_STATION) |
@@ -633,11 +628,12 @@ int wiphy_register(struct wiphy *wiphy)
 	 * hence subtract 2 as bit 0 is invalid.
 	 */
 	if (WARN_ON(wiphy->bss_select_support &&
-		    (wiphy->bss_select_support & ~(BIT(__NL80211_BSS_SELECT_ATTR_AFTER_LAST) - 2))))
+		    (wiphy->bss_select_support &
+		     ~(BIT(__NL80211_BSS_SELECT_ATTR_AFTER_LAST) - 2))))
 		return -EINVAL;

 	if (wiphy->addresses)
-		memcpy(wiphy->perm_addr, wiphy->addresses[0].addr, ETH_ALEN);
+		ether_addr_copy(wiphy->perm_addr, wiphy->addresses[0].addr);

 	/* sanity check ifmodes */
 	WARN_ON(!ifmodes);
@@ -658,16 +654,14 @@ int wiphy_register(struct wiphy *wiphy)
 		sband->band = band;
 		if (WARN_ON(!sband->n_channels))
 			return -EINVAL;
-		/*
-		 * on 60GHz band, there are no legacy rates, so
+		/* On 60GHz band, there are no legacy rates, so
 		 * n_bitrates is 0
 		 */
 		if (WARN_ON(band != NL80211_BAND_60GHZ &&
 			    !sband->n_bitrates))
 			return -EINVAL;

-		/*
-		 * Since cfg80211_disable_40mhz_24ghz is global, we can
+		/* Since cfg80211_disable_40mhz_24ghz is global, we can
 		 * modify the sband's ht data even if the driver uses a
 		 * global structure for that.
 		 */
@@ -678,8 +672,7 @@ int wiphy_register(struct wiphy *wiphy)
 			sband->ht_cap.cap &= ~IEEE80211_HT_CAP_SGI_40;
 		}

-		/*
-		 * Since we use a u32 for rate bitmaps in
+		/* Since we use a u32 for rate bitmaps in
 		 * ieee80211_get_response_rate, we cannot
 		 * have more than 32 legacy rates.
 		 */
@@ -790,6 +783,7 @@ void wiphy_unregister(struct wiphy *wiphy)

 	wait_event(rdev->dev_wait, ({
 		int __count;
+
 		rtnl_lock();
 		__count = rdev->opencount;
 		rtnl_unlock();
@@ -804,16 +798,14 @@ void wiphy_unregister(struct wiphy *wiphy)

 	WARN_ON(!list_empty(&rdev->wiphy.wdev_list));

-	/*
-	 * First remove the hardware from everywhere, this makes
+	/* First remove the hardware from everywhere, this makes
 	 * it impossible to find from userspace.
 	 */
 	debugfs_remove_recursive(rdev->wiphy.debugfsdir);
 	list_del_rcu(&rdev->list);
 	synchronize_rcu();

-	/*
-	 * If this device got a regulatory hint tell core its
+	/* If this device got a regulatory hint tell core its
 	 * free to listen now to a new shiny device regulatory hint
 	 */
 	wiphy_regulatory_deregister(wiphy);
@@ -844,6 +836,7 @@ void cfg80211_dev_free(struct cfg80211_registered_device *rdev)
 {
 	struct cfg80211_internal_bss *scan, *tmp;
 	struct cfg80211_beacon_registration *reg, *treg;
+
 	rfkill_destroy(rdev->rfkill);
 	list_for_each_entry_safe(reg, treg, &rdev->beacon_registrations, list) {
 		list_del(&reg->list);
@@ -1012,8 +1005,7 @@ static int cfg80211_netdev_notifier_call(struct notifier_block *nb,
 		SET_NETDEV_DEVTYPE(dev, &wiphy_type);
 		break;
 	case NETDEV_REGISTER:
-		/*
-		 * NB: cannot take rdev->mtx here because this may be
+		/* NB: cannot take rdev->mtx here because this may be
 		 * called within code protected by it when interfaces
 		 * are added with nl80211.
 		 */
@@ -1089,15 +1081,16 @@ static int cfg80211_netdev_notifier_call(struct notifier_block *nb,
 			{
 				/* backward compat code... */
 				struct mesh_setup setup;
+
 				memcpy(&setup, &default_mesh_setup,
-						sizeof(setup));
+				       sizeof(setup));
 				 /* back compat only needed for mesh_id */
 				setup.mesh_id = wdev->ssid;
 				setup.mesh_id_len = wdev->mesh_id_up_len;
 				if (wdev->mesh_id_up_len)
 					__cfg80211_join_mesh(rdev, dev,
-							&setup,
-							&default_mesh_config);
+							     &setup,
+							     &default_mesh_config);
 				break;
 			}
 #endif
@@ -1107,8 +1100,7 @@ static int cfg80211_netdev_notifier_call(struct notifier_block *nb,
 		wdev_unlock(wdev);
 		rdev->opencount++;

-		/*
-		 * Configure power management to the driver here so that its
+		/* Configure power management to the driver here so that its
 		 * correctly set also after interface type changes etc.
 		 */
 		if ((wdev->iftype == NL80211_IFTYPE_STATION ||
@@ -1121,8 +1113,7 @@ static int cfg80211_netdev_notifier_call(struct notifier_block *nb,
 			}
 		break;
 	case NETDEV_UNREGISTER:
-		/*
-		 * It is possible to get NETDEV_UNREGISTER
+		/* It is possible to get NETDEV_UNREGISTER
 		 * multiple times. To detect that, check
 		 * that the interface is still on the list
 		 * of registered interfaces, and only then
@@ -1137,16 +1128,14 @@ static int cfg80211_netdev_notifier_call(struct notifier_block *nb,
 			kzfree(wdev->wext.keys);
 #endif
 		}
-		/*
-		 * synchronise (so that we won't find this netdev
+		/* synchronise (so that we won't find this netdev
 		 * from other code any more) and then clear the list
 		 * head so that the above code can safely check for
 		 * !list_empty() to avoid double-cleanup.
 		 */
 		synchronize_rcu();
 		INIT_LIST_HEAD(&wdev->list);
-		/*
-		 * Ensure that all events have been processed and
+		/* Ensure that all events have been processed and
 		 * freed.
 		 */
 		cfg80211_process_wdev_events(wdev);
diff --git a/net/wireless/core.h b/net/wireless/core.h
index 025b7a5..75fb34f 100644
--- a/net/wireless/core.h
+++ b/net/wireless/core.h
@@ -16,7 +16,6 @@
 #include <net/cfg80211.h>
 #include "reg.h"

-
 #define WIPHY_IDX_INVALID	-1

 struct cfg80211_registered_device {
@@ -33,18 +32,19 @@ struct cfg80211_registered_device {
 	 * on the same alpha2 quickly. The alpha2 may differ from
 	 * cfg80211_regdomain's alpha2 when an intersection has occurred.
 	 * If the AP is reconfigured this can also be used to tell us if
-	 * the country on the country IE changed. */
+	 * the country on the country IE changed.
+	 */
 	char country_ie_alpha2[2];

-	/*
-	 * the driver requests the regulatory core to set this regulatory
+	/* The driver requests the regulatory core to set this regulatory
 	 * domain as the wiphy's. Only used for %REGULATORY_WIPHY_SELF_MANAGED
 	 * devices using the regulatory_set_wiphy_regd() API
 	 */
 	const struct ieee80211_regdomain *requested_regd;

 	/* If a Country IE has been received this tells us the environment
-	 * which its telling us its in. This defaults to ENVIRON_ANY */
+	 * which its telling us its in. This defaults to ENVIRON_ANY
+	 */
 	enum environment_cap env;

 	/* wiphy index, internal only */
@@ -90,6 +90,7 @@ struct cfg80211_registered_device {

 	struct cfg80211_coalesce *coalesce;

+	/* Destroy interfaces for given registered device */
 	spinlock_t destroy_list_lock;
 	struct list_head destroy_list;
 	struct work_struct destroy_work;
@@ -97,7 +98,8 @@ struct cfg80211_registered_device {
 	struct work_struct sched_scan_stop_wk;

 	/* must be last because of the way we do wiphy_priv(),
-	 * and it should at least be aligned to NETDEV_ALIGN */
+	 * and it should at least be aligned to NETDEV_ALIGN
+	 */
 	struct wiphy wiphy __aligned(NETDEV_ALIGN);
 };

@@ -145,7 +147,8 @@ struct cfg80211_internal_bss {
 	struct cfg80211_bss pub;
 };

-static inline struct cfg80211_internal_bss *bss_from_pub(struct cfg80211_bss *pub)
+static inline
+struct cfg80211_internal_bss *bss_from_pub(struct cfg80211_bss *pub)
 {
 	return container_of(pub, struct cfg80211_internal_bss, pub);
 }
@@ -158,10 +161,10 @@ static inline void cfg80211_hold_bss(struct cfg80211_internal_bss *bss)
 static inline void cfg80211_unhold_bss(struct cfg80211_internal_bss *bss)
 {
 	int r = atomic_dec_return(&bss->hold);
+
 	WARN_ON(r < 0);
 }

-
 struct cfg80211_registered_device *cfg80211_rdev_by_wiphy_idx(int wiphy_idx);
 int get_wiphy_idx(struct wiphy *wiphy);

@@ -186,7 +189,8 @@ static inline void wdev_unlock(struct wireless_dev *wdev)

 #define ASSERT_WDEV_LOCK(wdev) lockdep_assert_held(&(wdev)->mtx)

-static inline bool cfg80211_has_monitors_only(struct cfg80211_registered_device *rdev)
+static inline
+bool cfg80211_has_monitors_only(struct cfg80211_registered_device *rdev)
 {
 	ASSERT_RTNL();

@@ -270,7 +274,7 @@ void ieee80211_set_bitrate_flags(struct wiphy *wiphy);

 void cfg80211_bss_expire(struct cfg80211_registered_device *rdev);
 void cfg80211_bss_age(struct cfg80211_registered_device *rdev,
-                      unsigned long age_secs);
+		      unsigned long age_secs);

 /* IBSS */
 int cfg80211_join_ibss(struct cfg80211_registered_device *rdev,
@@ -451,9 +455,9 @@ static inline unsigned int elapsed_jiffies_msecs(unsigned long start)

 void
 cfg80211_get_chan_state(struct wireless_dev *wdev,
-		        struct ieee80211_channel **chan,
-		        enum cfg80211_chan_mode *chanmode,
-		        u8 *radar_detect);
+			struct ieee80211_channel **chan,
+			enum cfg80211_chan_mode *chanmode,
+			u8 *radar_detect);

 int cfg80211_set_monitor_channel(struct cfg80211_registered_device *rdev,
 				 struct cfg80211_chan_def *chandef);
@@ -481,8 +485,7 @@ void cfg80211_stop_p2p_device(struct cfg80211_registered_device *rdev,
 #ifdef CONFIG_CFG80211_DEVELOPER_WARNINGS
 #define CFG80211_DEV_WARN_ON(cond)	WARN_ON(cond)
 #else
-/*
- * Trick to enable using it as a condition,
+/* Trick to enable using it as a condition,
  * and also not give a warning when it's
  * not used that way.
  */
