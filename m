From: Joe Perches <joe@perches.com>
Subject: [PATCH wireless-next 11/20] mac80211_hwsim: Use pr_<level>
Date: Thu, 14 Jun 2012 22:53:51 -0700
Message-ID: <f03c0933fd2c334ef9aedffc04b2ec5f6924108f.1339739416.git.joe@perches.com>
References: <cover.1339739415.git.joe@perches.com>
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1339739415.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use a more current logging style.

Convert printks to pr_<level>.
Convert printk(KERN_DEBUG to pr_debug(.
Coalesce formats, align arguments.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/wireless/mac80211_hwsim.c |   61 ++++++++++++++------------------
 1 files changed, 27 insertions(+), 34 deletions(-)

diff --git a/drivers/net/wireless/mac80211_hwsim.c b/drivers/net/wireless/mac80211_hwsim.c
index a0b7cfd..eae77d2 100644
--- a/drivers/net/wireless/mac80211_hwsim.c
+++ b/drivers/net/wireless/mac80211_hwsim.c
@@ -15,6 +15,8 @@
  * - RX filtering based on filter configuration (data->rx_filter)
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/list.h>
 #include <linux/slab.h>
 #include <linux/spinlock.h>
@@ -578,7 +580,7 @@ static void mac80211_hwsim_tx_frame_nl(struct ieee80211_hw *hw,
 	msg_head = genlmsg_put(skb, 0, 0, &hwsim_genl_family, 0,
 			       HWSIM_CMD_FRAME);
 	if (msg_head == NULL) {
-		printk(KERN_DEBUG "mac80211_hwsim: problem with msg_head\n");
+		pr_debug("problem with msg_head\n");
 		goto nla_put_failure;
 	}
 
@@ -626,7 +628,7 @@ static void mac80211_hwsim_tx_frame_nl(struct ieee80211_hw *hw,
 	return;
 
 nla_put_failure:
-	printk(KERN_DEBUG "mac80211_hwsim: error occurred in %s\n", __func__);
+	pr_debug("error occurred in %s\n", __func__);
 }
 
 static bool mac80211_hwsim_tx_frame_no_nl(struct ieee80211_hw *hw,
@@ -1189,12 +1191,10 @@ static int mac80211_hwsim_hw_scan(struct ieee80211_hw *hw,
 	hsd->hw = hw;
 	INIT_DELAYED_WORK(&hsd->w, hw_scan_done);
 
-	printk(KERN_DEBUG "hwsim hw_scan request\n");
+	pr_debug("hw_scan request\n");
 	for (i = 0; i < req->n_channels; i++)
-		printk(KERN_DEBUG "hwsim hw_scan freq %d\n",
-			req->channels[i]->center_freq);
-	print_hex_dump(KERN_DEBUG, "scan IEs: ", DUMP_PREFIX_OFFSET,
-			16, 1, req->ie, req->ie_len, 1);
+		pr_debug("hw_scan freq %d\n", req->channels[i]->center_freq);
+	print_hex_dump_bytes("scan IEs: ", DUMP_PREFIX_OFFSET, req->ie, req->ie_len);
 
 	ieee80211_queue_delayed_work(hw, &hsd->w, 2 * HZ);
 
@@ -1208,11 +1208,11 @@ static void mac80211_hwsim_sw_scan(struct ieee80211_hw *hw)
 	mutex_lock(&hwsim->mutex);
 
 	if (hwsim->scanning) {
-		printk(KERN_DEBUG "two hwsim sw_scans detected!\n");
+		pr_debug("two hwsim sw_scans detected!\n");
 		goto out;
 	}
 
-	printk(KERN_DEBUG "hwsim sw_scan request, prepping stuff\n");
+	pr_debug("sw_scan request, prepping stuff\n");
 	hwsim->scanning = true;
 
 out:
@@ -1225,7 +1225,7 @@ static void mac80211_hwsim_sw_scan_complete(struct ieee80211_hw *hw)
 
 	mutex_lock(&hwsim->mutex);
 
-	printk(KERN_DEBUG "hwsim sw_scan_complete\n");
+	pr_debug("sw_scan_complete\n");
 	hwsim->scanning = false;
 
 	mutex_unlock(&hwsim->mutex);
@@ -1338,7 +1338,7 @@ static void hwsim_send_ps_poll(void *dat, u8 *mac, struct ieee80211_vif *vif)
 		return mac80211_hwsim_tx_frame_nl(data->hw, skb, _pid);
 
 	if (!mac80211_hwsim_tx_frame_no_nl(data->hw, skb))
-		printk(KERN_DEBUG "%s: PS-poll frame not ack'ed\n", __func__);
+		pr_debug("%s: PS-poll frame not ack'ed\n", __func__);
 	dev_kfree_skb(skb);
 }
 
@@ -1377,7 +1377,7 @@ static void hwsim_send_nullfunc(struct mac80211_hwsim_data *data, u8 *mac,
 		return mac80211_hwsim_tx_frame_nl(data->hw, skb, _pid);
 
 	if (!mac80211_hwsim_tx_frame_no_nl(data->hw, skb))
-		printk(KERN_DEBUG "%s: nullfunc frame not ack'ed\n", __func__);
+		pr_debug("%s: nullfunc frame not ack'ed\n", __func__);
 	dev_kfree_skb(skb);
 }
 
@@ -1621,7 +1621,7 @@ static int hwsim_cloned_frame_received_nl(struct sk_buff *skb_2,
 
 	return 0;
 err:
-	printk(KERN_DEBUG "mac80211_hwsim: error occurred in %s\n", __func__);
+	pr_debug("error occurred in %s\n", __func__);
 	goto out;
 out:
 	dev_kfree_skb(skb);
@@ -1636,12 +1636,12 @@ static int hwsim_register_received_nl(struct sk_buff *skb_2,
 
 	wmediumd_pid = info->snd_pid;
 
-	printk(KERN_DEBUG "mac80211_hwsim: received a REGISTER, "
-	       "switching to wmediumd mode with pid %d\n", info->snd_pid);
+	pr_debug("received a REGISTER, switching to wmediumd mode with pid %d\n",
+		 info->snd_pid);
 
 	return 0;
 out:
-	printk(KERN_DEBUG "mac80211_hwsim: error occurred in %s\n", __func__);
+	pr_debug("error occurred in %s\n", __func__);
 	return -EINVAL;
 }
 
@@ -1675,8 +1675,7 @@ static int mac80211_hwsim_netlink_notify(struct notifier_block *nb,
 		return NOTIFY_DONE;
 
 	if (notify->pid == wmediumd_pid) {
-		printk(KERN_INFO "mac80211_hwsim: wmediumd released netlink"
-		       " socket, switching to perfect channel medium\n");
+		pr_info("wmediumd released netlink socket, switching to perfect channel medium\n");
 		wmediumd_pid = 0;
 	}
 	return NOTIFY_DONE;
@@ -1690,7 +1689,7 @@ static struct notifier_block hwsim_netlink_notifier = {
 static int hwsim_init_netlink(void)
 {
 	int rc;
-	printk(KERN_INFO "mac80211_hwsim: initializing netlink\n");
+	pr_info("initializing netlink\n");
 
 	rc = genl_register_family_with_ops(&hwsim_genl_family,
 		hwsim_ops, ARRAY_SIZE(hwsim_ops));
@@ -1704,7 +1703,7 @@ static int hwsim_init_netlink(void)
 	return 0;
 
 failure:
-	printk(KERN_DEBUG "mac80211_hwsim: error occurred in %s\n", __func__);
+	pr_debug("error occurred in %s\n", __func__);
 	return -EINVAL;
 }
 
@@ -1712,14 +1711,13 @@ static void hwsim_exit_netlink(void)
 {
 	int ret;
 
-	printk(KERN_INFO "mac80211_hwsim: closing netlink\n");
+	pr_info("closing netlink\n");
 	/* unregister the notifier */
 	netlink_unregister_notifier(&hwsim_netlink_notifier);
 	/* unregister the family */
 	ret = genl_unregister_family(&hwsim_genl_family);
 	if (ret)
-		printk(KERN_DEBUG "mac80211_hwsim: "
-		       "unregister family %i\n", ret);
+		pr_debug("unregister family %i\n", ret);
 }
 
 static const struct ieee80211_iface_limit hwsim_if_limits[] = {
@@ -1768,12 +1766,10 @@ static int __init init_mac80211_hwsim(void)
 	addr[0] = 0x02;
 
 	for (i = 0; i < radios; i++) {
-		printk(KERN_DEBUG "mac80211_hwsim: Initializing radio %d\n",
-		       i);
+		pr_debug("Initializing radio %d\n", i);
 		hw = ieee80211_alloc_hw(sizeof(*data), &mac80211_hwsim_ops);
 		if (!hw) {
-			printk(KERN_DEBUG "mac80211_hwsim: ieee80211_alloc_hw "
-			       "failed\n");
+			pr_debug("ieee80211_alloc_hw failed\n");
 			err = -ENOMEM;
 			goto failed;
 		}
@@ -1783,9 +1779,7 @@ static int __init init_mac80211_hwsim(void)
 		data->dev = device_create(hwsim_class, NULL, 0, hw,
 					  "hwsim%d", i);
 		if (IS_ERR(data->dev)) {
-			printk(KERN_DEBUG
-			       "mac80211_hwsim: device_create "
-			       "failed (%ld)\n", PTR_ERR(data->dev));
+			pr_debug("device_create failed (%ld)\n", PTR_ERR(data->dev));
 			err = -ENOMEM;
 			goto failed_drvdata;
 		}
@@ -1946,8 +1940,7 @@ static int __init init_mac80211_hwsim(void)
 			schedule_timeout_interruptible(1);
 		err = ieee80211_register_hw(hw);
 		if (err < 0) {
-			printk(KERN_DEBUG "mac80211_hwsim: "
-			       "ieee80211_register_hw failed (%d)\n", err);
+			pr_debug("ieee80211_register_hw failed (%d)\n", err);
 			goto failed_hw;
 		}
 
@@ -2039,7 +2032,7 @@ static int __init init_mac80211_hwsim(void)
 	return 0;
 
 failed_nl:
-	printk(KERN_DEBUG "mac_80211_hwsim: failed initializing netlink\n");
+	pr_debug("failed initializing netlink\n");
 	return err;
 
 failed_mon:
@@ -2060,7 +2053,7 @@ failed:
 
 static void __exit exit_mac80211_hwsim(void)
 {
-	printk(KERN_DEBUG "mac80211_hwsim: unregister radios\n");
+	pr_debug("unregister radios\n");
 
 	hwsim_exit_netlink();
 
-- 
1.7.8.111.gad25c.dirty
