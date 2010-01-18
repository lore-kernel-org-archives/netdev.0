From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless-2.6 2010-01-18
Date: Mon, 18 Jan 2010 17:22:09 -0500
Message-ID: <20100118222208.GA28686@tuxdriver.com>
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

Here are a few more fixes intended for 2.6.33 -- I don't think there
is anything controversial this time. :-)  The biggest one just adds
some copyright notices to a couple of files.  Everything else is
more-or-less one-liner stuff, and one adds a device ID...

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit cd65c3c7d1081290b7365897c2290a84aa967d4d:
  Octavian Purdila (1):
        net: fix build erros with CONFIG_BUG=n, CONFIG_GENERIC_BUG=n

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git master

Abhijeet Kolekar (1):
      cfg80211: fix channel setting for wext

Benoit Papillault (1):
      mac80211: check that ieee80211_set_power_mgmt only handles STA interfaces.

Bob Copeland (1):
      mac80211: fix sign error in pid controller

Christian Lamparter (1):
      p54pci: rx frame length check

Hin-Tak Leung (1):
      zd1211rw: adding 0409:0248 to supported device list

Reinette Chatre (1):
      iwlwifi: add license to tracing files

Samuel Ortiz (1):
      iwmc3200wifi: Add UMAC wifi headers to the pmkid command

Wey-Yi Guy (1):
      iwlwifi: Fix throughput stall issue in HT mode for 5000

 drivers/net/wireless/iwlwifi/iwl-5000.c      |    5 +++++
 drivers/net/wireless/iwlwifi/iwl-devtrace.c  |   26 ++++++++++++++++++++++++++
 drivers/net/wireless/iwlwifi/iwl-devtrace.h  |   26 ++++++++++++++++++++++++++
 drivers/net/wireless/iwmc3200wifi/commands.c |    4 ++++
 drivers/net/wireless/iwmc3200wifi/commands.h |    1 +
 drivers/net/wireless/p54/p54pci.c            |    8 ++++++++
 drivers/net/wireless/zd1211rw/zd_usb.c       |    1 +
 net/mac80211/cfg.c                           |    3 +++
 net/mac80211/rc80211_pid_algo.c              |    2 +-
 net/wireless/sme.c                           |    1 +
 10 files changed, 76 insertions(+), 1 deletions(-)

diff --git a/drivers/net/wireless/iwlwifi/iwl-5000.c b/drivers/net/wireless/iwlwifi/iwl-5000.c
index 33a5866..de45f30 100644
--- a/drivers/net/wireless/iwlwifi/iwl-5000.c
+++ b/drivers/net/wireless/iwlwifi/iwl-5000.c
@@ -1598,6 +1598,7 @@ struct iwl_cfg iwl5300_agn_cfg = {
 	.use_bsm = false,
 	.ht_greenfield_support = true,
 	.led_compensation = 51,
+	.use_rts_for_ht = true, /* use rts/cts protection */
 	.chain_noise_num_beacons = IWL_CAL_NUM_BEACONS,
 	.sm_ps_mode = WLAN_HT_CAP_SM_PS_DISABLED,
 };
@@ -1622,6 +1623,7 @@ struct iwl_cfg iwl5100_bgn_cfg = {
 	.use_bsm = false,
 	.ht_greenfield_support = true,
 	.led_compensation = 51,
+	.use_rts_for_ht = true, /* use rts/cts protection */
 	.chain_noise_num_beacons = IWL_CAL_NUM_BEACONS,
 };
 
@@ -1667,6 +1669,7 @@ struct iwl_cfg iwl5100_agn_cfg = {
 	.use_bsm = false,
 	.ht_greenfield_support = true,
 	.led_compensation = 51,
+	.use_rts_for_ht = true, /* use rts/cts protection */
 	.chain_noise_num_beacons = IWL_CAL_NUM_BEACONS,
 	.sm_ps_mode = WLAN_HT_CAP_SM_PS_DISABLED,
 };
@@ -1691,6 +1694,7 @@ struct iwl_cfg iwl5350_agn_cfg = {
 	.use_bsm = false,
 	.ht_greenfield_support = true,
 	.led_compensation = 51,
+	.use_rts_for_ht = true, /* use rts/cts protection */
 	.chain_noise_num_beacons = IWL_CAL_NUM_BEACONS,
 	.sm_ps_mode = WLAN_HT_CAP_SM_PS_DISABLED,
 };
@@ -1715,6 +1719,7 @@ struct iwl_cfg iwl5150_agn_cfg = {
 	.use_bsm = false,
 	.ht_greenfield_support = true,
 	.led_compensation = 51,
+	.use_rts_for_ht = true, /* use rts/cts protection */
 	.chain_noise_num_beacons = IWL_CAL_NUM_BEACONS,
 	.sm_ps_mode = WLAN_HT_CAP_SM_PS_DISABLED,
 };
diff --git a/drivers/net/wireless/iwlwifi/iwl-devtrace.c b/drivers/net/wireless/iwlwifi/iwl-devtrace.c
index e7d88d1..83cc4e5 100644
--- a/drivers/net/wireless/iwlwifi/iwl-devtrace.c
+++ b/drivers/net/wireless/iwlwifi/iwl-devtrace.c
@@ -1,3 +1,29 @@
+/******************************************************************************
+ *
+ * Copyright(c) 2009 - 2010 Intel Corporation. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ *
+ * You should have received a copy of the GNU General Public License along with
+ * this program; if not, write to the Free Software Foundation, Inc.,
+ * 51 Franklin Street, Fifth Floor, Boston, MA 02110, USA
+ *
+ * The full GNU General Public License is included in this distribution in the
+ * file called LICENSE.
+ *
+ * Contact Information:
+ *  Intel Linux Wireless <ilw-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
+ * Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
+ *
+ *****************************************************************************/
+
 #include <linux/module.h>
 
 /* sparse doesn't like tracepoint macros */
diff --git a/drivers/net/wireless/iwlwifi/iwl-devtrace.h b/drivers/net/wireless/iwlwifi/iwl-devtrace.h
index 2136196..d9c7363 100644
--- a/drivers/net/wireless/iwlwifi/iwl-devtrace.h
+++ b/drivers/net/wireless/iwlwifi/iwl-devtrace.h
@@ -1,3 +1,29 @@
+/******************************************************************************
+ *
+ * Copyright(c) 2009 - 2010 Intel Corporation. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ *
+ * You should have received a copy of the GNU General Public License along with
+ * this program; if not, write to the Free Software Foundation, Inc.,
+ * 51 Franklin Street, Fifth Floor, Boston, MA 02110, USA
+ *
+ * The full GNU General Public License is included in this distribution in the
+ * file called LICENSE.
+ *
+ * Contact Information:
+ *  Intel Linux Wireless <ilw-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
+ * Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
+ *
+ *****************************************************************************/
+
 #if !defined(__IWLWIFI_DEVICE_TRACE) || defined(TRACE_HEADER_MULTI_READ)
 #define __IWLWIFI_DEVICE_TRACE
 
diff --git a/drivers/net/wireless/iwmc3200wifi/commands.c b/drivers/net/wireless/iwmc3200wifi/commands.c
index 777584d..1e41ad0 100644
--- a/drivers/net/wireless/iwmc3200wifi/commands.c
+++ b/drivers/net/wireless/iwmc3200wifi/commands.c
@@ -973,6 +973,10 @@ int iwm_send_pmkid_update(struct iwm_priv *iwm,
 
 	memset(&update, 0, sizeof(struct iwm_umac_pmkid_update));
 
+	update.hdr.oid = UMAC_WIFI_IF_CMD_PMKID_UPDATE;
+	update.hdr.buf_size = cpu_to_le16(sizeof(struct iwm_umac_pmkid_update) -
+					  sizeof(struct iwm_umac_wifi_if));
+
 	update.command = cpu_to_le32(command);
 	if (pmksa->bssid)
 		memcpy(&update.bssid, pmksa->bssid, ETH_ALEN);
diff --git a/drivers/net/wireless/iwmc3200wifi/commands.h b/drivers/net/wireless/iwmc3200wifi/commands.h
index 06af055..3dfd9f0 100644
--- a/drivers/net/wireless/iwmc3200wifi/commands.h
+++ b/drivers/net/wireless/iwmc3200wifi/commands.h
@@ -463,6 +463,7 @@ struct iwm_umac_cmd_stop_resume_tx {
 #define IWM_CMD_PMKID_FLUSH 3
 
 struct iwm_umac_pmkid_update {
+	struct iwm_umac_wifi_if hdr;
 	__le32 command;
 	u8 bssid[ETH_ALEN];
 	__le16 reserved;
diff --git a/drivers/net/wireless/p54/p54pci.c b/drivers/net/wireless/p54/p54pci.c
index a15962a..a72f7c2 100644
--- a/drivers/net/wireless/p54/p54pci.c
+++ b/drivers/net/wireless/p54/p54pci.c
@@ -197,6 +197,14 @@ static void p54p_check_rx_ring(struct ieee80211_hw *dev, u32 *index,
 			i %= ring_limit;
 			continue;
 		}
+
+		if (unlikely(len > priv->common.rx_mtu)) {
+			if (net_ratelimit())
+				dev_err(&priv->pdev->dev, "rx'd frame size "
+					"exceeds length threshold.\n");
+
+			len = priv->common.rx_mtu;
+		}
 		skb_put(skb, len);
 
 		if (p54_rx(dev, skb)) {
diff --git a/drivers/net/wireless/zd1211rw/zd_usb.c b/drivers/net/wireless/zd1211rw/zd_usb.c
index ac19ecd..72d3e43 100644
--- a/drivers/net/wireless/zd1211rw/zd_usb.c
+++ b/drivers/net/wireless/zd1211rw/zd_usb.c
@@ -62,6 +62,7 @@ static struct usb_device_id usb_ids[] = {
 	{ USB_DEVICE(0x6891, 0xa727), .driver_info = DEVICE_ZD1211 },
 	/* ZD1211B */
 	{ USB_DEVICE(0x0053, 0x5301), .driver_info = DEVICE_ZD1211B },
+	{ USB_DEVICE(0x0409, 0x0248), .driver_info = DEVICE_ZD1211B },
 	{ USB_DEVICE(0x0411, 0x00da), .driver_info = DEVICE_ZD1211B },
 	{ USB_DEVICE(0x0471, 0x1236), .driver_info = DEVICE_ZD1211B },
 	{ USB_DEVICE(0x0471, 0x1237), .driver_info = DEVICE_ZD1211B },
diff --git a/net/mac80211/cfg.c b/net/mac80211/cfg.c
index 6dc3579..9ae1a47 100644
--- a/net/mac80211/cfg.c
+++ b/net/mac80211/cfg.c
@@ -1331,6 +1331,9 @@ static int ieee80211_set_power_mgmt(struct wiphy *wiphy, struct net_device *dev,
 	struct ieee80211_local *local = wdev_priv(dev->ieee80211_ptr);
 	struct ieee80211_conf *conf = &local->hw.conf;
 
+	if (sdata->vif.type != NL80211_IFTYPE_STATION)
+		return -EOPNOTSUPP;
+
 	if (!(local->hw.flags & IEEE80211_HW_SUPPORTS_PS))
 		return -EOPNOTSUPP;
 
diff --git a/net/mac80211/rc80211_pid_algo.c b/net/mac80211/rc80211_pid_algo.c
index 699d3ed..29bc4c5 100644
--- a/net/mac80211/rc80211_pid_algo.c
+++ b/net/mac80211/rc80211_pid_algo.c
@@ -190,7 +190,7 @@ static void rate_control_pid_sample(struct rc_pid_info *pinfo,
 	rate_control_pid_normalize(pinfo, sband->n_bitrates);
 
 	/* Compute the proportional, integral and derivative errors. */
-	err_prop = (pinfo->target << RC_PID_ARITH_SHIFT) - pf;
+	err_prop = (pinfo->target - pf) << RC_PID_ARITH_SHIFT;
 
 	err_avg = spinfo->err_avg_sc >> pinfo->smoothing_shift;
 	spinfo->err_avg_sc = spinfo->err_avg_sc - err_avg + err_prop;
diff --git a/net/wireless/sme.c b/net/wireless/sme.c
index 2333d78..dc0fc49 100644
--- a/net/wireless/sme.c
+++ b/net/wireless/sme.c
@@ -655,6 +655,7 @@ void __cfg80211_disconnected(struct net_device *dev, const u8 *ie,
 	memset(&wrqu, 0, sizeof(wrqu));
 	wrqu.ap_addr.sa_family = ARPHRD_ETHER;
 	wireless_send_event(dev, SIOCGIWAP, &wrqu, NULL);
+	wdev->wext.connect.ssid_len = 0;
 #endif
 }
 
-- 
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
