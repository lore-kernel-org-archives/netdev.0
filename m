From: Joe Perches <joe@perches.com>
Subject: [PATCH 1/5] ti: Convert wl1271_<level> logging macros to dev_<level> or pr_<level>
Date: Mon,  7 Mar 2016 16:19:33 -0800
Message-ID: <760b583e96a9a88f06e97150617f791c3726a302.1457395071.git.joe@perches.com>
References: <cover.1457395071.git.joe@perches.com>
Cc: Kalle Valo <kvalo@codeaurora.org>, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0113.hostedemail.com ([216.40.44.113]:60774 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S932298AbcCHAUP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2016 19:20:15 -0500
In-Reply-To: <cover.1457395071.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the more common logging mechanism passing wl->dev where
appropriate.  Remove the macros.  Add argument struct wl1271 *wl to
some functions to make these logging mechanisms work.

Miscellanea:

o Coalesce formats, add required trailing \n to formats
  Some formats already had previously incorrect \n uses
o Realign arguments
o Correct a couple typos and grammar defects
o Split a multiple line error message to multiple calls of dev_err
o Add #define pr_fmt when pr_<level> is used
o Remove unnecessary/duplicate pr_fmt use from wl1271_debug macro

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/wireless/ti/wl12xx/acx.c      |   2 +-
 drivers/net/wireless/ti/wl12xx/cmd.c      |  20 +--
 drivers/net/wireless/ti/wl12xx/main.c     |  34 ++--
 drivers/net/wireless/ti/wl12xx/scan.c     |  24 +--
 drivers/net/wireless/ti/wl18xx/acx.c      |  25 +--
 drivers/net/wireless/ti/wl18xx/cmd.c      |  20 +--
 drivers/net/wireless/ti/wl18xx/debugfs.c  |   2 +-
 drivers/net/wireless/ti/wl18xx/event.c    |   8 +-
 drivers/net/wireless/ti/wl18xx/main.c     |  50 +++---
 drivers/net/wireless/ti/wl18xx/scan.c     |  16 +-
 drivers/net/wireless/ti/wl18xx/tx.c       |   8 +-
 drivers/net/wireless/ti/wlcore/acx.c      | 132 ++++++++--------
 drivers/net/wireless/ti/wlcore/boot.c     |  45 +++---
 drivers/net/wireless/ti/wlcore/cmd.c      | 103 +++++++------
 drivers/net/wireless/ti/wlcore/debug.h    |  14 +-
 drivers/net/wireless/ti/wlcore/debugfs.c  |  54 +++----
 drivers/net/wireless/ti/wlcore/event.c    |  14 +-
 drivers/net/wireless/ti/wlcore/main.c     | 248 ++++++++++++++++--------------
 drivers/net/wireless/ti/wlcore/ps.c       |  15 +-
 drivers/net/wireless/ti/wlcore/rx.c       |  26 ++--
 drivers/net/wireless/ti/wlcore/scan.c     |   4 +-
 drivers/net/wireless/ti/wlcore/sysfs.c    |   8 +-
 drivers/net/wireless/ti/wlcore/testmode.c |  14 +-
 drivers/net/wireless/ti/wlcore/tx.c       |  14 +-
 drivers/net/wireless/ti/wlcore/wlcore_i.h |   3 -
 25 files changed, 464 insertions(+), 439 deletions(-)

diff --git a/drivers/net/wireless/ti/wl12xx/acx.c b/drivers/net/wireless/ti/wl12xx/acx.c
index bea06b2..4a11158 100644
--- a/drivers/net/wireless/ti/wl12xx/acx.c
+++ b/drivers/net/wireless/ti/wl12xx/acx.c
@@ -42,7 +42,7 @@ int wl1271_acx_host_if_cfg_bitmap(struct wl1271 *wl, u32 host_cfg_bitmap)
 	ret = wl1271_cmd_configure(wl, ACX_HOST_IF_CFG_BITMAP,
 				   bitmap_conf, sizeof(*bitmap_conf));
 	if (ret < 0) {
-		wl1271_warning("wl1271 bitmap config opt failed: %d", ret);
+		dev_warn(wl->dev, "wl1271 bitmap config opt failed: %d\n", ret);
 		goto out;
 	}
 
diff --git a/drivers/net/wireless/ti/wl12xx/cmd.c b/drivers/net/wireless/ti/wl12xx/cmd.c
index 7485dba..8f358d3 100644
--- a/drivers/net/wireless/ti/wl12xx/cmd.c
+++ b/drivers/net/wireless/ti/wl12xx/cmd.c
@@ -54,7 +54,7 @@ int wl1271_cmd_ext_radio_parms(struct wl1271 *wl)
 
 	ret = wl1271_cmd_test(wl, ext_radio_parms, sizeof(*ext_radio_parms), 0);
 	if (ret < 0)
-		wl1271_warning("TEST_CMD_INI_FILE_RF_EXTENDED_PARAM failed");
+		dev_warn(wl->dev, "TEST_CMD_INI_FILE_RF_EXTENDED_PARAM failed\n");
 
 	kfree(ext_radio_parms);
 	return ret;
@@ -73,7 +73,7 @@ int wl1271_cmd_general_parms(struct wl1271 *wl)
 		return -ENODEV;
 
 	if (gp->tx_bip_fem_manufacturer >= WL1271_INI_FEM_MODULE_COUNT) {
-		wl1271_warning("FEM index from INI out of bounds");
+		dev_warn(wl->dev, "FEM index from INI out of bounds\n");
 		return -EINVAL;
 	}
 
@@ -97,7 +97,7 @@ int wl1271_cmd_general_parms(struct wl1271 *wl)
 
 	ret = wl1271_cmd_test(wl, gen_parms, sizeof(*gen_parms), answer);
 	if (ret < 0) {
-		wl1271_warning("CMD_INI_FILE_GENERAL_PARAM failed");
+		dev_warn(wl->dev, "CMD_INI_FILE_GENERAL_PARAM failed\n");
 		goto out;
 	}
 
@@ -105,7 +105,7 @@ int wl1271_cmd_general_parms(struct wl1271 *wl)
 		gen_parms->general_params.tx_bip_fem_manufacturer;
 
 	if (gp->tx_bip_fem_manufacturer >= WL1271_INI_FEM_MODULE_COUNT) {
-		wl1271_warning("FEM index from FW out of bounds");
+		dev_warn(wl->dev, "FEM index from FW out of bounds\n");
 		ret = -EINVAL;
 		goto out;
 	}
@@ -140,7 +140,7 @@ int wl128x_cmd_general_parms(struct wl1271 *wl)
 		return -ENODEV;
 
 	if (gp->tx_bip_fem_manufacturer >= WL1271_INI_FEM_MODULE_COUNT) {
-		wl1271_warning("FEM index from ini out of bounds");
+		dev_warn(wl->dev, "FEM index from ini out of bounds\n");
 		return -EINVAL;
 	}
 
@@ -165,7 +165,7 @@ int wl128x_cmd_general_parms(struct wl1271 *wl)
 
 	ret = wl1271_cmd_test(wl, gen_parms, sizeof(*gen_parms), answer);
 	if (ret < 0) {
-		wl1271_warning("CMD_INI_FILE_GENERAL_PARAM failed");
+		dev_warn(wl->dev, "CMD_INI_FILE_GENERAL_PARAM failed\n");
 		goto out;
 	}
 
@@ -173,7 +173,7 @@ int wl128x_cmd_general_parms(struct wl1271 *wl)
 		gen_parms->general_params.tx_bip_fem_manufacturer;
 
 	if (gp->tx_bip_fem_manufacturer >= WL1271_INI_FEM_MODULE_COUNT) {
-		wl1271_warning("FEM index from FW out of bounds");
+		dev_warn(wl->dev, "FEM index from FW out of bounds\n");
 		ret = -EINVAL;
 		goto out;
 	}
@@ -233,7 +233,7 @@ int wl1271_cmd_radio_parms(struct wl1271 *wl)
 
 	ret = wl1271_cmd_test(wl, radio_parms, sizeof(*radio_parms), 0);
 	if (ret < 0)
-		wl1271_warning("CMD_INI_FILE_RADIO_PARAM failed");
+		dev_warn(wl->dev, "CMD_INI_FILE_RADIO_PARAM failed\n");
 
 	kfree(radio_parms);
 	return ret;
@@ -279,7 +279,7 @@ int wl128x_cmd_radio_parms(struct wl1271 *wl)
 
 	ret = wl1271_cmd_test(wl, radio_parms, sizeof(*radio_parms), 0);
 	if (ret < 0)
-		wl1271_warning("CMD_INI_FILE_RADIO_PARAM failed");
+		dev_warn(wl->dev, "CMD_INI_FILE_RADIO_PARAM failed\n");
 
 	kfree(radio_parms);
 	return ret;
@@ -311,7 +311,7 @@ int wl12xx_cmd_channel_switch(struct wl1271 *wl,
 
 	ret = wl1271_cmd_send(wl, CMD_CHANNEL_SWITCH, cmd, sizeof(*cmd), 0);
 	if (ret < 0) {
-		wl1271_error("failed to send channel switch command");
+		dev_err(wl->dev, "failed to send channel switch command\n");
 		goto out_free;
 	}
 
diff --git a/drivers/net/wireless/ti/wl12xx/main.c b/drivers/net/wireless/ti/wl12xx/main.c
index a0d6ccc..c9d793d 100644
--- a/drivers/net/wireless/ti/wl12xx/main.c
+++ b/drivers/net/wireless/ti/wl12xx/main.c
@@ -19,6 +19,8 @@
  *
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/module.h>
 #include <linux/platform_device.h>
 
@@ -642,8 +644,8 @@ static int wl12xx_identify_chip(struct wl1271 *wl)
 
 	switch (wl->chip.id) {
 	case CHIP_ID_127X_PG10:
-		wl1271_warning("chip id 0x%x (1271 PG10) support is obsolete",
-			       wl->chip.id);
+		dev_warn(wl->dev, "chip id 0x%x (1271 PG10) support is obsolete\n",
+			 wl->chip.id);
 
 		wl->quirks |= WLCORE_QUIRK_LEGACY_NVS |
 			      WLCORE_QUIRK_DUAL_PROBE_TMPL |
@@ -712,7 +714,7 @@ static int wl12xx_identify_chip(struct wl1271 *wl)
 		break;
 	case CHIP_ID_128X_PG10:
 	default:
-		wl1271_warning("unsupported chip id: 0x%x", wl->chip.id);
+		dev_warn(wl->dev, "unsupported chip id: 0x%x\n", wl->chip.id);
 		ret = -ENODEV;
 		goto out;
 	}
@@ -782,13 +784,13 @@ static int __must_check wl12xx_top_reg_read(struct wl1271 *wl, int addr,
 	} while (!(val & OCP_READY_MASK) && --timeout);
 
 	if (!timeout) {
-		wl1271_warning("Top register access timed out.");
+		dev_warn(wl->dev, "Top register access timed out\n");
 		return -ETIMEDOUT;
 	}
 
 	/* check data status and return if OK */
 	if ((val & OCP_STATUS_MASK) != OCP_STATUS_OK) {
-		wl1271_warning("Top register access returned error.");
+		dev_warn(wl->dev, "Top register access returned error\n");
 		return -EIO;
 	}
 
@@ -1073,7 +1075,7 @@ static int wl1271_boot_soft_reset(struct wl1271 *wl)
 		if (time_after(jiffies, timeout)) {
 			/* 1.2 check pWhalBus->uSelfClearTime if the
 			 * timeout was reached */
-			wl1271_error("soft reset timeout");
+			dev_err(wl->dev, "soft reset timeout\n");
 			return -1;
 		}
 
@@ -1836,10 +1838,10 @@ static int wl12xx_setup(struct wl1271 *wl)
 						pdev_data->ref_clock_freq,
 						pdev_data->ref_clock_xtal);
 		if (priv->ref_clock < 0) {
-			wl1271_error("Invalid ref_clock frequency (%d Hz, %s)",
-				     pdev_data->ref_clock_freq,
-				     pdev_data->ref_clock_xtal ?
-				     "XTAL" : "not XTAL");
+			dev_err(wl->dev, "Invalid ref_clock frequency (%d Hz, %s)\n",
+				pdev_data->ref_clock_freq,
+				pdev_data->ref_clock_xtal ?
+				"XTAL" : "not XTAL");
 
 			return priv->ref_clock;
 		}
@@ -1857,7 +1859,8 @@ static int wl12xx_setup(struct wl1271 *wl)
 		else if (!strcmp(fref_param, "52"))
 			priv->ref_clock = WL12XX_REFCLOCK_52;
 		else
-			wl1271_error("Invalid fref parameter %s", fref_param);
+			dev_err(wl->dev, "Invalid fref parameter %s\n",
+				fref_param);
 	}
 
 	if (!tcxo_param && pdev_data->tcxo_clock_freq) {
@@ -1865,8 +1868,8 @@ static int wl12xx_setup(struct wl1271 *wl)
 						pdev_data->tcxo_clock_freq,
 						true);
 		if (priv->tcxo_clock < 0) {
-			wl1271_error("Invalid tcxo_clock frequency (%d Hz)",
-				     pdev_data->tcxo_clock_freq);
+			dev_err(wl->dev, "Invalid tcxo_clock frequency (%d Hz)\n",
+				pdev_data->tcxo_clock_freq);
 
 			return priv->tcxo_clock;
 		}
@@ -1888,7 +1891,8 @@ static int wl12xx_setup(struct wl1271 *wl)
 		else if (!strcmp(tcxo_param, "33.6"))
 			priv->tcxo_clock = WL12XX_TCXOCLOCK_33_6;
 		else
-			wl1271_error("Invalid tcxo parameter %s", tcxo_param);
+			dev_err(wl->dev, "Invalid tcxo parameter %s\n",
+				tcxo_param);
 	}
 
 	priv->rx_mem_addr = kmalloc(sizeof(*priv->rx_mem_addr), GFP_KERNEL);
@@ -1908,7 +1912,7 @@ static int wl12xx_probe(struct platform_device *pdev)
 			     WL12XX_AGGR_BUFFER_SIZE,
 			     sizeof(struct wl12xx_event_mailbox));
 	if (IS_ERR(hw)) {
-		wl1271_error("can't allocate hw");
+		pr_err("can't allocate hw\n");
 		ret = PTR_ERR(hw);
 		goto out;
 	}
diff --git a/drivers/net/wireless/ti/wl12xx/scan.c b/drivers/net/wireless/ti/wl12xx/scan.c
index ebed13a..c474179 100644
--- a/drivers/net/wireless/ti/wl12xx/scan.c
+++ b/drivers/net/wireless/ti/wl12xx/scan.c
@@ -162,7 +162,7 @@ static int wl1271_scan_send(struct wl1271 *wl, struct wl12xx_vif *wlvif,
 					 wl->scan.req->ie,
 					 wl->scan.req->ie_len, NULL, 0, false);
 	if (ret < 0) {
-		wl1271_error("PROBE request template failed");
+		dev_err(wl->dev, "PROBE request template failed\n");
 		goto out;
 	}
 
@@ -170,7 +170,7 @@ static int wl1271_scan_send(struct wl1271 *wl, struct wl12xx_vif *wlvif,
 	ret = wl1271_cmd_send(wl, CMD_TRIGGER_SCAN_TO, trigger,
 			      sizeof(*trigger), 0);
 	if (ret < 0) {
-		wl1271_error("trigger scan to failed for hw scan");
+		dev_err(wl->dev, "trigger scan to failed for hw scan\n");
 		goto out;
 	}
 
@@ -178,7 +178,7 @@ static int wl1271_scan_send(struct wl1271 *wl, struct wl12xx_vif *wlvif,
 
 	ret = wl1271_cmd_send(wl, CMD_SCAN, cmd, sizeof(*cmd), 0);
 	if (ret < 0) {
-		wl1271_error("SCAN failed");
+		dev_err(wl->dev, "SCAN failed\n");
 		goto out;
 	}
 
@@ -207,7 +207,7 @@ int wl12xx_scan_stop(struct wl1271 *wl, struct wl12xx_vif *wlvif)
 	ret = wl1271_cmd_send(wl, CMD_STOP_SCAN, cmd,
 			      sizeof(*cmd), 0);
 	if (ret < 0) {
-		wl1271_error("cmd stop_scan failed");
+		dev_err(wl->dev, "cmd stop_scan failed\n");
 		goto out;
 	}
 out:
@@ -292,7 +292,7 @@ void wl1271_scan_stm(struct wl1271 *wl, struct wl12xx_vif *wlvif)
 		break;
 
 	default:
-		wl1271_error("invalid scan state");
+		dev_err(wl->dev, "invalid scan state\n");
 		break;
 	}
 
@@ -371,7 +371,7 @@ int wl1271_scan_sched_scan_config(struct wl1271 *wl,
 	if (!wlcore_set_scan_chan_params(wl, cfg_channels, req->channels,
 					 req->n_channels, req->n_ssids,
 					 SCAN_TYPE_PERIODIC)) {
-		wl1271_error("scan channel list is empty");
+		dev_err(wl->dev, "scan channel list is empty\n");
 		ret = -EINVAL;
 		goto out;
 	}
@@ -389,7 +389,7 @@ int wl1271_scan_sched_scan_config(struct wl1271 *wl,
 						 ies->common_ie_len,
 						 true);
 		if (ret < 0) {
-			wl1271_error("2.4GHz PROBE request template failed");
+			dev_err(wl->dev, "2.4GHz PROBE request template failed\n");
 			goto out;
 		}
 	}
@@ -406,7 +406,7 @@ int wl1271_scan_sched_scan_config(struct wl1271 *wl,
 						 ies->common_ie_len,
 						 true);
 		if (ret < 0) {
-			wl1271_error("5GHz PROBE request template failed");
+			dev_err(wl->dev, "5GHz PROBE request template failed\n");
 			goto out;
 		}
 	}
@@ -416,7 +416,7 @@ int wl1271_scan_sched_scan_config(struct wl1271 *wl,
 	ret = wl1271_cmd_send(wl, CMD_CONNECTION_SCAN_CFG, cfg,
 			      sizeof(*cfg), 0);
 	if (ret < 0) {
-		wl1271_error("SCAN configuration failed");
+		dev_err(wl->dev, "SCAN configuration failed\n");
 		goto out;
 	}
 out:
@@ -449,7 +449,7 @@ int wl1271_scan_sched_scan_start(struct wl1271 *wl, struct wl12xx_vif *wlvif)
 	ret = wl1271_cmd_send(wl, CMD_START_PERIODIC_SCAN, start,
 			      sizeof(*start), 0);
 	if (ret < 0) {
-		wl1271_error("failed to send scan start command");
+		dev_err(wl->dev, "failed to send scan start command\n");
 		goto out_free;
 	}
 
@@ -481,7 +481,7 @@ void wl12xx_scan_sched_scan_stop(struct wl1271 *wl,  struct wl12xx_vif *wlvif)
 	/* FIXME: what to do if alloc'ing to stop fails? */
 	stop = kzalloc(sizeof(*stop), GFP_KERNEL);
 	if (!stop) {
-		wl1271_error("failed to alloc memory to send sched scan stop");
+		dev_err(wl->dev, "failed to alloc memory to send sched scan stop\n");
 		return;
 	}
 
@@ -491,7 +491,7 @@ void wl12xx_scan_sched_scan_stop(struct wl1271 *wl,  struct wl12xx_vif *wlvif)
 	ret = wl1271_cmd_send(wl, CMD_STOP_PERIODIC_SCAN, stop,
 			      sizeof(*stop), 0);
 	if (ret < 0) {
-		wl1271_error("failed to send sched scan stop command");
+		dev_err(wl->dev, "failed to send sched scan stop command\n");
 		goto out_free;
 	}
 
diff --git a/drivers/net/wireless/ti/wl18xx/acx.c b/drivers/net/wireless/ti/wl18xx/acx.c
index 4be0409..b314151 100644
--- a/drivers/net/wireless/ti/wl18xx/acx.c
+++ b/drivers/net/wireless/ti/wl18xx/acx.c
@@ -51,7 +51,7 @@ int wl18xx_acx_host_if_cfg_bitmap(struct wl1271 *wl, u32 host_cfg_bitmap,
 	ret = wl1271_cmd_configure(wl, ACX_HOST_IF_CFG_BITMAP,
 				   bitmap_conf, sizeof(*bitmap_conf));
 	if (ret < 0) {
-		wl1271_warning("wl1271 bitmap config opt failed: %d", ret);
+		dev_warn(wl->dev, "wl1271 bitmap config opt failed: %d\n", ret);
 		goto out;
 	}
 
@@ -78,7 +78,7 @@ int wl18xx_acx_set_checksum_state(struct wl1271 *wl)
 
 	ret = wl1271_cmd_configure(wl, ACX_CSUM_CONFIG, acx, sizeof(*acx));
 	if (ret < 0) {
-		wl1271_warning("failed to set Tx checksum state: %d", ret);
+		dev_warn(wl->dev, "failed to set Tx checksum state: %d\n", ret);
 		goto out;
 	}
 
@@ -102,7 +102,8 @@ int wl18xx_acx_clear_statistics(struct wl1271 *wl)
 
 	ret = wl1271_cmd_configure(wl, ACX_CLEAR_STATISTICS, acx, sizeof(*acx));
 	if (ret < 0) {
-		wl1271_warning("failed to clear firmware statistics: %d", ret);
+		dev_warn(wl->dev, "failed to clear firmware statistics: %d\n",
+			 ret);
 		goto out;
 	}
 
@@ -132,7 +133,8 @@ int wl18xx_acx_peer_ht_operation_mode(struct wl1271 *wl, u8 hlid, bool wide)
 				   sizeof(*acx));
 
 	if (ret < 0) {
-		wl1271_warning("acx peer ht operation mode failed: %d", ret);
+		dev_warn(wl->dev, "acx peer ht operation mode failed: %d\n",
+			 ret);
 		goto out;
 	}
 
@@ -187,7 +189,8 @@ int wl18xx_acx_set_peer_cap(struct wl1271 *wl,
 
 	ret = wl1271_cmd_configure(wl, ACX_PEER_CAP, acx, sizeof(*acx));
 	if (ret < 0) {
-		wl1271_warning("acx ht capabilities setting failed: %d", ret);
+		dev_warn(wl->dev, "acx ht capabilities setting failed: %d\n",
+			 ret);
 		goto out;
 	}
 
@@ -215,7 +218,8 @@ int wl18xx_acx_interrupt_notify_config(struct wl1271 *wl,
 	acx->enable = action;
 	ret = wl1271_cmd_configure(wl, ACX_INTERRUPT_NOTIFY, acx, sizeof(*acx));
 	if (ret < 0) {
-		wl1271_warning("acx interrupt notify setting failed: %d", ret);
+		dev_warn(wl->dev, "acx interrupt notify setting failed: %d\n",
+			 ret);
 		goto out;
 	}
 
@@ -242,8 +246,8 @@ int wl18xx_acx_rx_ba_filter(struct wl1271 *wl, bool action)
 	acx->enable = (u32)action;
 	ret = wl1271_cmd_configure(wl, ACX_RX_BA_FILTER, acx, sizeof(*acx));
 	if (ret < 0) {
-		wl1271_warning("acx rx ba activity filter setting failed: %d",
-			       ret);
+		dev_warn(wl->dev, "acx rx ba activity filter setting failed: %d\n",
+			 ret);
 		goto out;
 	}
 
@@ -274,7 +278,7 @@ int wl18xx_acx_ap_sleep(struct wl1271 *wl)
 
 	ret = wl1271_cmd_configure(wl, ACX_AP_SLEEP_CFG, acx, sizeof(*acx));
 	if (ret < 0) {
-		wl1271_warning("acx config ap-sleep failed: %d", ret);
+		dev_warn(wl->dev, "acx config ap-sleep failed: %d\n", ret);
 		goto out;
 	}
 
@@ -302,7 +306,8 @@ int wl18xx_acx_dynamic_fw_traces(struct wl1271 *wl)
 	ret = wl1271_cmd_configure(wl, ACX_DYNAMIC_TRACES_CFG,
 				   acx, sizeof(*acx));
 	if (ret < 0) {
-		wl1271_warning("acx config dynamic fw traces failed: %d", ret);
+		dev_warn(wl->dev, "acx config dynamic fw traces failed: %d\n",
+			 ret);
 		goto out;
 	}
 out:
diff --git a/drivers/net/wireless/ti/wl18xx/cmd.c b/drivers/net/wireless/ti/wl18xx/cmd.c
index a8d176d..31bca7f 100644
--- a/drivers/net/wireless/ti/wl18xx/cmd.c
+++ b/drivers/net/wireless/ti/wl18xx/cmd.c
@@ -55,8 +55,8 @@ int wl18xx_cmd_channel_switch(struct wl1271 *wl,
 		cmd->band = WLCORE_BAND_5GHZ;
 		break;
 	default:
-		wl1271_error("invalid channel switch band: %d",
-			     ch_switch->chandef.chan->band);
+		dev_err(wl->dev, "invalid channel switch band: %d\n",
+			ch_switch->chandef.chan->band);
 		ret = -EINVAL;
 		goto out_free;
 	}
@@ -74,7 +74,7 @@ int wl18xx_cmd_channel_switch(struct wl1271 *wl,
 
 	ret = wl1271_cmd_send(wl, CMD_CHANNEL_SWITCH, cmd, sizeof(*cmd), 0);
 	if (ret < 0) {
-		wl1271_error("failed to send channel switch command");
+		dev_err(wl->dev, "failed to send channel switch command\n");
 		goto out_free;
 	}
 
@@ -102,7 +102,7 @@ int wl18xx_cmd_smart_config_start(struct wl1271 *wl, u32 group_bitmap)
 
 	ret = wl1271_cmd_send(wl, CMD_SMART_CONFIG_START, cmd, sizeof(*cmd), 0);
 	if (ret < 0) {
-		wl1271_error("failed to send smart config start command");
+		dev_err(wl->dev, "failed to send smart config start command\n");
 		goto out_free;
 	}
 
@@ -127,7 +127,7 @@ int wl18xx_cmd_smart_config_stop(struct wl1271 *wl)
 
 	ret = wl1271_cmd_send(wl, CMD_SMART_CONFIG_STOP, cmd, sizeof(*cmd), 0);
 	if (ret < 0) {
-		wl1271_error("failed to send smart config stop command");
+		dev_err(wl->dev, "failed to send smart config stop command\n");
 		goto out_free;
 	}
 
@@ -147,7 +147,7 @@ int wl18xx_cmd_smart_config_set_group_key(struct wl1271 *wl, u16 group_id,
 		     group_id);
 
 	if (key_len != sizeof(cmd->key)) {
-		wl1271_error("invalid group key size: %d", key_len);
+		dev_err(wl->dev, "invalid group key size: %d\n", key_len);
 		return -E2BIG;
 	}
 
@@ -163,7 +163,7 @@ int wl18xx_cmd_smart_config_set_group_key(struct wl1271 *wl, u16 group_id,
 	ret = wl1271_cmd_send(wl, CMD_SMART_CONFIG_SET_GROUP_KEY, cmd,
 			      sizeof(*cmd), 0);
 	if (ret < 0) {
-		wl1271_error("failed to send smart config set group key cmd");
+		dev_err(wl->dev, "failed to send smart config set group key cmd\n");
 		goto out_free;
 	}
 
@@ -195,7 +195,7 @@ int wl18xx_cmd_set_cac(struct wl1271 *wl, struct wl12xx_vif *wlvif, bool start)
 			      start ? CMD_CAC_START : CMD_CAC_STOP,
 			      cmd, sizeof(*cmd), 0);
 	if (ret < 0) {
-		wl1271_error("failed to send cac command");
+		dev_err(wl->dev, "failed to send cac command\n");
 		goto out_free;
 	}
 
@@ -221,7 +221,7 @@ int wl18xx_cmd_radar_detection_debug(struct wl1271 *wl, u8 channel)
 	ret = wl1271_cmd_send(wl, CMD_DFS_RADAR_DETECTION_DEBUG,
 			      cmd, sizeof(*cmd), 0);
 	if (ret < 0) {
-		wl1271_error("failed to send radar detection debug command");
+		dev_err(wl->dev, "failed to send radar detection debug command\n");
 		goto out_free;
 	}
 
@@ -247,7 +247,7 @@ int wl18xx_cmd_dfs_master_restart(struct wl1271 *wl, struct wl12xx_vif *wlvif)
 	ret = wl1271_cmd_send(wl, CMD_DFS_MASTER_RESTART,
 			      cmd, sizeof(*cmd), 0);
 	if (ret < 0) {
-		wl1271_error("failed to send dfs master restart command");
+		dev_err(wl->dev, "failed to send dfs master restart command\n");
 		goto out_free;
 	}
 out_free:
diff --git a/drivers/net/wireless/ti/wl18xx/debugfs.c b/drivers/net/wireless/ti/wl18xx/debugfs.c
index 4edfe28..57e1b19 100644
--- a/drivers/net/wireless/ti/wl18xx/debugfs.c
+++ b/drivers/net/wireless/ti/wl18xx/debugfs.c
@@ -267,7 +267,7 @@ static ssize_t radar_detection_write(struct file *file,
 
 	ret = kstrtou8_from_user(user_buf, count, 10, &channel);
 	if (ret < 0) {
-		wl1271_warning("illegal channel");
+		dev_warn(wl->dev, "illegal channel\n");
 		return -EINVAL;
 	}
 
diff --git a/drivers/net/wireless/ti/wl18xx/event.c b/drivers/net/wireless/ti/wl18xx/event.c
index 719907a..97c86c9 100644
--- a/drivers/net/wireless/ti/wl18xx/event.c
+++ b/drivers/net/wireless/ti/wl18xx/event.c
@@ -117,7 +117,7 @@ static void wlcore_event_time_sync(struct wl1271 *wl, u16 tsf_msb, u16 tsf_lsb)
 	u32 clock;
 	/* convert the MSB+LSB to a u32 TSF value */
 	clock = (tsf_msb << 16) | tsf_lsb;
-	wl1271_info("TIME_SYNC_EVENT_ID: clock %u", clock);
+	dev_info(wl->dev, "TIME_SYNC_EVENT_ID: clock %u\n", clock);
 }
 
 int wl18xx_process_mailbox_events(struct wl1271 *wl)
@@ -142,9 +142,9 @@ int wl18xx_process_mailbox_events(struct wl1271 *wl)
 				mbox->time_sync_tsf_lsb);
 
 	if (vector & RADAR_DETECTED_EVENT_ID) {
-		wl1271_info("radar event: channel %d type %s",
-			    mbox->radar_channel,
-			    wl18xx_radar_type_decode(mbox->radar_type));
+		dev_info(wl->dev, "radar event: channel %d type %s\n",
+			 mbox->radar_channel,
+			 wl18xx_radar_type_decode(mbox->radar_type));
 
 		ieee80211_radar_detected(wl->hw);
 	}
diff --git a/drivers/net/wireless/ti/wl18xx/main.c b/drivers/net/wireless/ti/wl18xx/main.c
index 1bf26cc..92deb27 100644
--- a/drivers/net/wireless/ti/wl18xx/main.c
+++ b/drivers/net/wireless/ti/wl18xx/main.c
@@ -19,6 +19,8 @@
  *
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/module.h>
 #include <linux/platform_device.h>
 #include <linux/ip.h>
@@ -696,13 +698,13 @@ static int wl18xx_identify_chip(struct wl1271 *wl)
 				      0, 0, 0, 0);
 		break;
 	case CHIP_ID_185x_PG10:
-		wl1271_warning("chip id 0x%x (185x PG10) is deprecated",
-			       wl->chip.id);
+		dev_warn(wl->dev, "chip id 0x%x (185x PG10) is deprecated\n",
+			 wl->chip.id);
 		ret = -ENODEV;
 		goto out;
 
 	default:
-		wl1271_warning("unsupported chip id: 0x%x", wl->chip.id);
+		dev_warn(wl->dev, "unsupported chip id: 0x%x\n", wl->chip.id);
 		ret = -ENODEV;
 		goto out;
 	}
@@ -931,7 +933,7 @@ static int wl18xx_pre_upload(struct wl1271 *wl)
 
 	ret = irq_get_trigger_type(wl->irq);
 	if ((ret == IRQ_TYPE_LEVEL_LOW) || (ret == IRQ_TYPE_EDGE_FALLING)) {
-		wl1271_info("using inverted interrupt logic: %d", ret);
+		dev_info(wl->dev, "using inverted interrupt logic: %d\n", ret);
 		ret = wlcore_set_partition(wl,
 					   &wl->ptable[PART_TOP_PRCM_ELP_SOC]);
 		if (ret < 0)
@@ -1381,8 +1383,8 @@ static int wl18xx_get_pg_ver(struct wl1271 *wl, s8 *ver)
 
 	rdl_ver = (fuse & WL18XX_RDL_VER_MASK) >> WL18XX_RDL_VER_OFFSET;
 
-	wl1271_info("wl18xx HW: %s, PG %d.%d (ROM 0x%x)",
-		    wl18xx_rdl_name(rdl_ver), pg_ver, metal, rom);
+	dev_info(wl->dev, "wl18xx HW: %s, PG %d.%d (ROM 0x%x)\n",
+		 wl18xx_rdl_name(rdl_ver), pg_ver, metal, rom);
 
 	if (ver)
 		*ver = pg_ver;
@@ -1404,14 +1406,14 @@ static int wl18xx_load_conf_file(struct device *dev, struct wlcore_conf *conf,
 
 	ret = request_firmware(&fw, WL18XX_CONF_FILE_NAME, dev);
 	if (ret < 0) {
-		wl1271_error("could not get configuration binary %s: %d",
-			     WL18XX_CONF_FILE_NAME, ret);
+		dev_err(dev, "could not get configuration binary %s: %d\n",
+			WL18XX_CONF_FILE_NAME, ret);
 		return ret;
 	}
 
 	if (fw->size != WL18XX_CONF_SIZE) {
-		wl1271_error("configuration binary file size is wrong, expected %zu got %zu",
-			     WL18XX_CONF_SIZE, fw->size);
+		dev_err(dev, "configuration binary file size is wrong, expected %zu got %zu\n",
+			WL18XX_CONF_SIZE, fw->size);
 		ret = -EINVAL;
 		goto out_release;
 	}
@@ -1419,17 +1421,15 @@ static int wl18xx_load_conf_file(struct device *dev, struct wlcore_conf *conf,
 	conf_file = (struct wlcore_conf_file *) fw->data;
 
 	if (conf_file->header.magic != cpu_to_le32(WL18XX_CONF_MAGIC)) {
-		wl1271_error("configuration binary file magic number mismatch, "
-			     "expected 0x%0x got 0x%0x", WL18XX_CONF_MAGIC,
-			     conf_file->header.magic);
+		dev_err(dev, "configuration binary file magic number mismatch, expected 0x%0x got 0x%0x\n",
+			WL18XX_CONF_MAGIC, conf_file->header.magic);
 		ret = -EINVAL;
 		goto out_release;
 	}
 
 	if (conf_file->header.version != cpu_to_le32(WL18XX_CONF_VERSION)) {
-		wl1271_error("configuration binary file version not supported, "
-			     "expected 0x%08x got 0x%08x",
-			     WL18XX_CONF_VERSION, conf_file->header.version);
+		dev_err(dev, "configuration binary file version not supported, expected 0x%08x got 0x%08x\n",
+			WL18XX_CONF_VERSION, conf_file->header.version);
 		ret = -EINVAL;
 		goto out_release;
 	}
@@ -1447,7 +1447,7 @@ static int wl18xx_conf_init(struct wl1271 *wl, struct device *dev)
 	struct wl18xx_priv *priv = wl->priv;
 
 	if (wl18xx_load_conf_file(dev, &wl->conf, &priv->conf) < 0) {
-		wl1271_warning("falling back to default config");
+		dev_warn(wl->dev, "falling back to default config\n");
 
 		/* apply driver default configuration */
 		memcpy(&wl->conf, &wl18xx_conf, sizeof(wl->conf));
@@ -1465,7 +1465,7 @@ static int wl18xx_plt_init(struct wl1271 *wl)
 
 	/* calibrator based auto/fem detect not supported for 18xx */
 	if (wl->plt_mode == PLT_FEM_DETECT) {
-		wl1271_error("wl18xx_plt_init: PLT FEM_DETECT not supported");
+		dev_err(wl->dev, "wl18xx_plt_init: PLT FEM_DETECT not supported\n");
 		return -EINVAL;
 	}
 
@@ -1505,7 +1505,7 @@ static int wl18xx_get_mac(struct wl1271 *wl)
 
 		wl->fuse_oui_addr = (mac[0] << 16) + (mac[1] << 8) + mac[2];
 		wl->fuse_nic_addr = (mac[3] << 16) + (mac[4] << 8) + mac[5];
-		wl1271_warning("MAC address from fuse not available, using random locally administered addresses.");
+		dev_warn(wl->dev, "MAC address from fuse not available, using random locally administered addresses\n");
 	}
 
 	ret = wlcore_set_partition(wl, &wl->ptable[PART_DOWN]);
@@ -1526,7 +1526,8 @@ static int wl18xx_handle_static_data(struct wl1271 *wl,
 	/* make sure the string is NULL-terminated */
 	wl->chip.phy_fw_ver_str[sizeof(wl->chip.phy_fw_ver_str) - 1] = '\0';
 
-	wl1271_info("PHY firmware version: %s", static_data_priv->phy_version);
+	dev_info(wl->dev, "PHY firmware version: %s\n",
+		 static_data_priv->phy_version);
 
 	return 0;
 }
@@ -1945,14 +1946,14 @@ static int wl18xx_setup(struct wl1271 *wl)
 		} else if (!strcmp(board_type_param, "com8")) {
 			priv->conf.phy.board_type = BOARD_TYPE_COM8_18XX;
 		} else {
-			wl1271_error("invalid board type '%s'",
+			dev_err(wl->dev, "invalid board type '%s'\n",
 				board_type_param);
 			return -EINVAL;
 		}
 	}
 
 	if (priv->conf.phy.board_type >= NUM_BOARD_TYPES) {
-		wl1271_error("invalid board type '%d'",
+		dev_err(wl->dev, "invalid board type '%d'\n",
 			priv->conf.phy.board_type);
 		return -EINVAL;
 	}
@@ -1985,7 +1986,8 @@ static int wl18xx_setup(struct wl1271 *wl)
 		else if (!strcmp(ht_mode_param, "siso20"))
 			priv->conf.ht.mode = HT_MODE_SISO20;
 		else {
-			wl1271_error("invalid ht_mode '%s'", ht_mode_param);
+			dev_err(wl->dev, "invalid ht_mode '%s'\n",
+				ht_mode_param);
 			return -EINVAL;
 		}
 	}
@@ -2038,7 +2040,7 @@ static int wl18xx_probe(struct platform_device *pdev)
 			     WL18XX_AGGR_BUFFER_SIZE,
 			     sizeof(struct wl18xx_event_mailbox));
 	if (IS_ERR(hw)) {
-		wl1271_error("can't allocate hw");
+		pr_err("can't allocate hw\n");
 		ret = PTR_ERR(hw);
 		goto out;
 	}
diff --git a/drivers/net/wireless/ti/wl18xx/scan.c b/drivers/net/wireless/ti/wl18xx/scan.c
index bc15aa2..c64a443 100644
--- a/drivers/net/wireless/ti/wl18xx/scan.c
+++ b/drivers/net/wireless/ti/wl18xx/scan.c
@@ -121,7 +121,7 @@ static int wl18xx_scan_send(struct wl1271 *wl, struct wl12xx_vif *wlvif,
 				 0,
 				 false);
 		if (ret < 0) {
-			wl1271_error("2.4GHz PROBE request template failed");
+			dev_err(wl->dev, "2.4GHz PROBE request template failed\n");
 			goto out;
 		}
 	}
@@ -138,7 +138,7 @@ static int wl18xx_scan_send(struct wl1271 *wl, struct wl12xx_vif *wlvif,
 				 0,
 				 false);
 		if (ret < 0) {
-			wl1271_error("5GHz PROBE request template failed");
+			dev_err(wl->dev, "5GHz PROBE request template failed\n");
 			goto out;
 		}
 	}
@@ -147,7 +147,7 @@ static int wl18xx_scan_send(struct wl1271 *wl, struct wl12xx_vif *wlvif,
 
 	ret = wl1271_cmd_send(wl, CMD_SCAN, cmd, sizeof(*cmd), 0);
 	if (ret < 0) {
-		wl1271_error("SCAN failed");
+		dev_err(wl->dev, "SCAN failed\n");
 		goto out;
 	}
 
@@ -264,7 +264,7 @@ int wl18xx_scan_sched_scan_config(struct wl1271 *wl,
 				 ies->common_ie_len,
 				 true);
 		if (ret < 0) {
-			wl1271_error("2.4GHz PROBE request template failed");
+			dev_err(wl->dev, "2.4GHz PROBE request template failed\n");
 			goto out;
 		}
 	}
@@ -281,7 +281,7 @@ int wl18xx_scan_sched_scan_config(struct wl1271 *wl,
 				 ies->common_ie_len,
 				 true);
 		if (ret < 0) {
-			wl1271_error("5GHz PROBE request template failed");
+			dev_err(wl->dev, "5GHz PROBE request template failed\n");
 			goto out;
 		}
 	}
@@ -290,7 +290,7 @@ int wl18xx_scan_sched_scan_config(struct wl1271 *wl,
 
 	ret = wl1271_cmd_send(wl, CMD_SCAN, cmd, sizeof(*cmd), 0);
 	if (ret < 0) {
-		wl1271_error("SCAN failed");
+		dev_err(wl->dev, "SCAN failed\n");
 		goto out;
 	}
 
@@ -317,7 +317,7 @@ static int __wl18xx_scan_stop(struct wl1271 *wl, struct wl12xx_vif *wlvif,
 
 	stop = kzalloc(sizeof(*stop), GFP_KERNEL);
 	if (!stop) {
-		wl1271_error("failed to alloc memory to send sched scan stop");
+		dev_err(wl->dev, "failed to alloc memory to send sched scan stop\n");
 		return -ENOMEM;
 	}
 
@@ -326,7 +326,7 @@ static int __wl18xx_scan_stop(struct wl1271 *wl, struct wl12xx_vif *wlvif,
 
 	ret = wl1271_cmd_send(wl, CMD_STOP_SCAN, stop, sizeof(*stop), 0);
 	if (ret < 0) {
-		wl1271_error("failed to send sched scan stop command");
+		dev_err(wl->dev, "failed to send sched scan stop command\n");
 		goto out_free;
 	}
 
diff --git a/drivers/net/wireless/ti/wl18xx/tx.c b/drivers/net/wireless/ti/wl18xx/tx.c
index 3406ffb..cef7f31 100644
--- a/drivers/net/wireless/ti/wl18xx/tx.c
+++ b/drivers/net/wireless/ti/wl18xx/tx.c
@@ -35,7 +35,7 @@ void wl18xx_get_last_tx_rate(struct wl1271 *wl, struct ieee80211_vif *vif,
 	u8 fw_rate = wl->fw_status->counters.tx_last_rate;
 
 	if (fw_rate > CONF_HW_RATE_INDEX_MAX) {
-		wl1271_error("last Tx rate invalid: %d", fw_rate);
+		dev_err(wl->dev, "last Tx rate invalid: %d\n", fw_rate);
 		rate->idx = 0;
 		rate->flags = 0;
 		return;
@@ -82,7 +82,7 @@ static void wl18xx_tx_complete_packet(struct wl1271 *wl, u8 tx_stat_byte)
 
 	/* check for id legality */
 	if (unlikely(id >= wl->num_tx_desc || wl->tx_frames[id] == NULL)) {
-		wl1271_warning("illegal id in tx completion: %d", id);
+		dev_warn(wl->dev, "illegal id in tx completion: %d\n", id);
 		return;
 	}
 
@@ -155,8 +155,8 @@ void wl18xx_tx_immediate_complete(struct wl1271 *wl)
 		     priv->last_fw_rls_idx, status_priv->fw_release_idx);
 
 	if (status_priv->fw_release_idx >= WL18XX_FW_MAX_TX_STATUS_DESC) {
-		wl1271_error("invalid desc release index %d",
-			     status_priv->fw_release_idx);
+		dev_err(wl->dev, "invalid desc release index %d\n",
+			status_priv->fw_release_idx);
 		WARN_ON(1);
 		return;
 	}
diff --git a/drivers/net/wireless/ti/wlcore/acx.c b/drivers/net/wireless/ti/wlcore/acx.c
index 26cc23f..807c46a 100644
--- a/drivers/net/wireless/ti/wlcore/acx.c
+++ b/drivers/net/wireless/ti/wlcore/acx.c
@@ -56,7 +56,8 @@ int wl1271_acx_wake_up_conditions(struct wl1271 *wl, struct wl12xx_vif *wlvif,
 	ret = wl1271_cmd_configure(wl, ACX_WAKE_UP_CONDITIONS,
 				   wake_up, sizeof(*wake_up));
 	if (ret < 0) {
-		wl1271_warning("could not set wake up conditions: %d", ret);
+		dev_warn(wl->dev, "could not set wake up conditions: %d\n",
+			 ret);
 		goto out;
 	}
 
@@ -82,8 +83,8 @@ int wl1271_acx_sleep_auth(struct wl1271 *wl, u8 sleep_auth)
 
 	ret = wl1271_cmd_configure(wl, ACX_SLEEP_AUTH, auth, sizeof(*auth));
 	if (ret < 0) {
-		wl1271_error("could not configure sleep_auth to %d: %d",
-			     sleep_auth, ret);
+		dev_err(wl->dev, "could not configure sleep_auth to %d: %d\n",
+			sleep_auth, ret);
 		goto out;
 	}
 
@@ -116,7 +117,7 @@ int wl1271_acx_tx_power(struct wl1271 *wl, struct wl12xx_vif *wlvif,
 
 	ret = wl1271_cmd_configure(wl, DOT11_CUR_TX_PWR, acx, sizeof(*acx));
 	if (ret < 0) {
-		wl1271_warning("configure of tx power failed: %d", ret);
+		dev_warn(wl->dev, "configure of tx power failed: %d\n", ret);
 		goto out;
 	}
 
@@ -146,7 +147,7 @@ int wl1271_acx_feature_cfg(struct wl1271 *wl, struct wl12xx_vif *wlvif)
 	ret = wl1271_cmd_configure(wl, ACX_FEATURE_CFG,
 				   feature, sizeof(*feature));
 	if (ret < 0) {
-		wl1271_error("Couldnt set HW encryption");
+		dev_err(wl->dev, "Couldnt set HW encryption\n");
 		goto out;
 	}
 
@@ -187,7 +188,7 @@ int wl1271_acx_rx_msdu_life_time(struct wl1271 *wl)
 	ret = wl1271_cmd_configure(wl, DOT11_RX_MSDU_LIFE_TIME,
 				   acx, sizeof(*acx));
 	if (ret < 0) {
-		wl1271_warning("failed to set rx msdu life time: %d", ret);
+		dev_warn(wl->dev, "failed to set rx msdu life time: %d\n", ret);
 		goto out;
 	}
 
@@ -216,7 +217,7 @@ int wl1271_acx_slot(struct wl1271 *wl, struct wl12xx_vif *wlvif,
 
 	ret = wl1271_cmd_configure(wl, ACX_SLOT, slot, sizeof(*slot));
 	if (ret < 0) {
-		wl1271_warning("failed to set slot time: %d", ret);
+		dev_warn(wl->dev, "failed to set slot time: %d\n", ret);
 		goto out;
 	}
 
@@ -248,7 +249,7 @@ int wl1271_acx_group_address_tbl(struct wl1271 *wl, struct wl12xx_vif *wlvif,
 	ret = wl1271_cmd_configure(wl, DOT11_GROUP_ADDRESS_TBL,
 				   acx, sizeof(*acx));
 	if (ret < 0) {
-		wl1271_warning("failed to set group addr table: %d", ret);
+		dev_warn(wl->dev, "failed to set group addr table: %d\n", ret);
 		goto out;
 	}
 
@@ -278,8 +279,8 @@ int wl1271_acx_service_period_timeout(struct wl1271 *wl,
 	ret = wl1271_cmd_configure(wl, ACX_SERVICE_PERIOD_TIMEOUT,
 				   rx_timeout, sizeof(*rx_timeout));
 	if (ret < 0) {
-		wl1271_warning("failed to set service period timeout: %d",
-			       ret);
+		dev_warn(wl->dev, "failed to set service period timeout: %d\n",
+			 ret);
 		goto out;
 	}
 
@@ -314,7 +315,7 @@ int wl1271_acx_rts_threshold(struct wl1271 *wl, struct wl12xx_vif *wlvif,
 
 	ret = wl1271_cmd_configure(wl, DOT11_RTS_THRESHOLD, rts, sizeof(*rts));
 	if (ret < 0) {
-		wl1271_warning("failed to set rts threshold: %d", ret);
+		dev_warn(wl->dev, "failed to set rts threshold: %d\n", ret);
 		goto out;
 	}
 
@@ -343,7 +344,8 @@ int wl1271_acx_dco_itrim_params(struct wl1271 *wl)
 	ret = wl1271_cmd_configure(wl, ACX_SET_DCO_ITRIM_PARAMS,
 				   dco, sizeof(*dco));
 	if (ret < 0) {
-		wl1271_warning("failed to set dco itrim parameters: %d", ret);
+		dev_warn(wl->dev, "failed to set dco itrim parameters: %d\n",
+			 ret);
 		goto out;
 	}
 
@@ -383,7 +385,7 @@ int wl1271_acx_beacon_filter_opt(struct wl1271 *wl, struct wl12xx_vif *wlvif,
 	ret = wl1271_cmd_configure(wl, ACX_BEACON_FILTER_OPT,
 				   beacon_filter, sizeof(*beacon_filter));
 	if (ret < 0) {
-		wl1271_warning("failed to set beacon filter opt: %d", ret);
+		dev_warn(wl->dev, "failed to set beacon filter opt: %d\n", ret);
 		goto out;
 	}
 
@@ -439,7 +441,8 @@ int wl1271_acx_beacon_filter_table(struct wl1271 *wl,
 	ret = wl1271_cmd_configure(wl, ACX_BEACON_FILTER_TABLE,
 				   ie_table, sizeof(*ie_table));
 	if (ret < 0) {
-		wl1271_warning("failed to set beacon filter table: %d", ret);
+		dev_warn(wl->dev, "failed to set beacon filter table: %d\n",
+			 ret);
 		goto out;
 	}
 
@@ -479,8 +482,8 @@ int wl1271_acx_conn_monit_params(struct wl1271 *wl, struct wl12xx_vif *wlvif,
 	ret = wl1271_cmd_configure(wl, ACX_CONN_MONIT_PARAMS,
 				   acx, sizeof(*acx));
 	if (ret < 0) {
-		wl1271_warning("failed to set connection monitor "
-			       "parameters: %d", ret);
+		dev_warn(wl->dev, "failed to set connection monitor parameters: %d\n",
+			 ret);
 		goto out;
 	}
 
@@ -510,7 +513,7 @@ int wl1271_acx_sg_enable(struct wl1271 *wl, bool enable)
 
 	ret = wl1271_cmd_configure(wl, ACX_SG_ENABLE, pta, sizeof(*pta));
 	if (ret < 0) {
-		wl1271_warning("failed to set softgemini enable: %d", ret);
+		dev_warn(wl->dev, "failed to set softgemini enable: %d\n", ret);
 		goto out;
 	}
 
@@ -540,7 +543,7 @@ int wl12xx_acx_sg_cfg(struct wl1271 *wl)
 
 	ret = wl1271_cmd_configure(wl, ACX_SG_CFG, param, sizeof(*param));
 	if (ret < 0) {
-		wl1271_warning("failed to set sg config: %d", ret);
+		dev_warn(wl->dev, "failed to set sg config: %d\n", ret);
 		goto out;
 	}
 
@@ -568,7 +571,7 @@ int wl1271_acx_cca_threshold(struct wl1271 *wl)
 	ret = wl1271_cmd_configure(wl, ACX_CCA_THRESHOLD,
 				   detection, sizeof(*detection));
 	if (ret < 0)
-		wl1271_warning("failed to set cca threshold: %d", ret);
+		dev_warn(wl->dev, "failed to set cca threshold: %d\n", ret);
 
 out:
 	kfree(detection);
@@ -596,7 +599,7 @@ int wl1271_acx_bcn_dtim_options(struct wl1271 *wl, struct wl12xx_vif *wlvif)
 
 	ret = wl1271_cmd_configure(wl, ACX_BCN_DTIM_OPTIONS, bb, sizeof(*bb));
 	if (ret < 0) {
-		wl1271_warning("failed to set rx config: %d", ret);
+		dev_warn(wl->dev, "failed to set rx config: %d\n", ret);
 		goto out;
 	}
 
@@ -623,7 +626,7 @@ int wl1271_acx_aid(struct wl1271 *wl, struct wl12xx_vif *wlvif, u16 aid)
 
 	ret = wl1271_cmd_configure(wl, ACX_AID, acx_aid, sizeof(*acx_aid));
 	if (ret < 0) {
-		wl1271_warning("failed to set aid: %d", ret);
+		dev_warn(wl->dev, "failed to set aid: %d\n", ret);
 		goto out;
 	}
 
@@ -652,7 +655,8 @@ int wl1271_acx_event_mbox_mask(struct wl1271 *wl, u32 event_mask)
 	ret = wl1271_cmd_configure(wl, ACX_EVENT_MBOX_MASK,
 				   mask, sizeof(*mask));
 	if (ret < 0) {
-		wl1271_warning("failed to set acx_event_mbox_mask: %d", ret);
+		dev_warn(wl->dev, "failed to set acx_event_mbox_mask: %d\n",
+			 ret);
 		goto out;
 	}
 
@@ -680,7 +684,7 @@ int wl1271_acx_set_preamble(struct wl1271 *wl, struct wl12xx_vif *wlvif,
 
 	ret = wl1271_cmd_configure(wl, ACX_PREAMBLE_TYPE, acx, sizeof(*acx));
 	if (ret < 0) {
-		wl1271_warning("Setting of preamble failed: %d", ret);
+		dev_warn(wl->dev, "Setting of preamble failed: %d\n", ret);
 		goto out;
 	}
 
@@ -708,7 +712,7 @@ int wl1271_acx_cts_protect(struct wl1271 *wl, struct wl12xx_vif *wlvif,
 
 	ret = wl1271_cmd_configure(wl, ACX_CTS_PROTECTION, acx, sizeof(*acx));
 	if (ret < 0) {
-		wl1271_warning("Setting of ctsprotect failed: %d", ret);
+		dev_warn(wl->dev, "Setting of ctsprotect failed: %d\n", ret);
 		goto out;
 	}
 
@@ -727,7 +731,7 @@ int wl1271_acx_statistics(struct wl1271 *wl, void *stats)
 				     sizeof(struct acx_header),
 				     wl->stats.fw_stats_len);
 	if (ret < 0) {
-		wl1271_warning("acx statistics failed: %d", ret);
+		dev_warn(wl->dev, "acx statistics failed: %d\n", ret);
 		return -ENOMEM;
 	}
 
@@ -761,7 +765,7 @@ int wl1271_acx_sta_rate_policies(struct wl1271 *wl, struct wl12xx_vif *wlvif)
 
 	ret = wl1271_cmd_configure(wl, ACX_RATE_POLICY, acx, sizeof(*acx));
 	if (ret < 0) {
-		wl1271_warning("Setting of rate policies failed: %d", ret);
+		dev_warn(wl->dev, "Setting of rate policies failed: %d\n", ret);
 		goto out;
 	}
 
@@ -777,7 +781,7 @@ int wl1271_acx_sta_rate_policies(struct wl1271 *wl, struct wl12xx_vif *wlvif)
 
 	ret = wl1271_cmd_configure(wl, ACX_RATE_POLICY, acx, sizeof(*acx));
 	if (ret < 0) {
-		wl1271_warning("Setting of rate policies failed: %d", ret);
+		dev_warn(wl->dev, "Setting of rate policies failed: %d\n", ret);
 		goto out;
 	}
 
@@ -795,7 +799,7 @@ int wl1271_acx_sta_rate_policies(struct wl1271 *wl, struct wl12xx_vif *wlvif)
 
 	ret = wl1271_cmd_configure(wl, ACX_RATE_POLICY, acx, sizeof(*acx));
 	if (ret < 0) {
-		wl1271_warning("Setting of rate policies failed: %d", ret);
+		dev_warn(wl->dev, "Setting of rate policies failed: %d\n", ret);
 		goto out;
 	}
 
@@ -828,7 +832,8 @@ int wl1271_acx_ap_rate_policy(struct wl1271 *wl, struct conf_tx_rate_class *c,
 
 	ret = wl1271_cmd_configure(wl, ACX_RATE_POLICY, acx, sizeof(*acx));
 	if (ret < 0) {
-		wl1271_warning("Setting of ap rate policy failed: %d", ret);
+		dev_warn(wl->dev, "Setting of ap rate policy failed: %d\n",
+			 ret);
 		goto out;
 	}
 
@@ -862,7 +867,7 @@ int wl1271_acx_ac_cfg(struct wl1271 *wl, struct wl12xx_vif *wlvif,
 
 	ret = wl1271_cmd_configure(wl, ACX_AC_CFG, acx, sizeof(*acx));
 	if (ret < 0) {
-		wl1271_warning("acx ac cfg failed: %d", ret);
+		dev_warn(wl->dev, "acx ac cfg failed: %d\n", ret);
 		goto out;
 	}
 
@@ -899,7 +904,7 @@ int wl1271_acx_tid_cfg(struct wl1271 *wl, struct wl12xx_vif *wlvif,
 
 	ret = wl1271_cmd_configure(wl, ACX_TID_CFG, acx, sizeof(*acx));
 	if (ret < 0) {
-		wl1271_warning("Setting of tid config failed: %d", ret);
+		dev_warn(wl->dev, "Setting of tid config failed: %d\n", ret);
 		goto out;
 	}
 
@@ -932,7 +937,8 @@ int wl1271_acx_frag_threshold(struct wl1271 *wl, u32 frag_threshold)
 	acx->frag_threshold = cpu_to_le16((u16)frag_threshold);
 	ret = wl1271_cmd_configure(wl, ACX_FRAG_CFG, acx, sizeof(*acx));
 	if (ret < 0) {
-		wl1271_warning("Setting of frag threshold failed: %d", ret);
+		dev_warn(wl->dev, "Setting of frag threshold failed: %d\n",
+			 ret);
 		goto out;
 	}
 
@@ -959,7 +965,7 @@ int wl1271_acx_tx_config_options(struct wl1271 *wl)
 	acx->tx_compl_threshold = cpu_to_le16(wl->conf.tx.tx_compl_threshold);
 	ret = wl1271_cmd_configure(wl, ACX_TX_CONFIG_OPT, acx, sizeof(*acx));
 	if (ret < 0) {
-		wl1271_warning("Setting of tx options failed: %d", ret);
+		dev_warn(wl->dev, "Setting of tx options failed: %d\n", ret);
 		goto out;
 	}
 
@@ -999,7 +1005,7 @@ int wl12xx_acx_mem_cfg(struct wl1271 *wl)
 	ret = wl1271_cmd_configure(wl, ACX_MEM_CFG, mem_conf,
 				   sizeof(*mem_conf));
 	if (ret < 0) {
-		wl1271_warning("wl1271 mem config failed: %d", ret);
+		dev_warn(wl->dev, "wl1271 mem config failed: %d\n", ret);
 		goto out;
 	}
 
@@ -1016,7 +1022,7 @@ int wl1271_acx_init_mem_config(struct wl1271 *wl)
 	wl->target_mem_map = kzalloc(sizeof(struct wl1271_acx_mem_map),
 				     GFP_KERNEL);
 	if (!wl->target_mem_map) {
-		wl1271_error("couldn't allocate target memory map");
+		dev_err(wl->dev, "couldn't allocate target memory map\n");
 		return -ENOMEM;
 	}
 
@@ -1024,7 +1030,7 @@ int wl1271_acx_init_mem_config(struct wl1271 *wl)
 	ret = wl1271_acx_mem_map(wl, (void *)wl->target_mem_map,
 				 sizeof(struct wl1271_acx_mem_map));
 	if (ret < 0) {
-		wl1271_error("couldn't retrieve firmware memory map");
+		dev_err(wl->dev, "couldn't retrieve firmware memory map\n");
 		kfree(wl->target_mem_map);
 		wl->target_mem_map = NULL;
 		return ret;
@@ -1061,7 +1067,7 @@ int wl1271_acx_init_rx_interrupt(struct wl1271 *wl)
 	ret = wl1271_cmd_configure(wl, ACX_RX_CONFIG_OPT, rx_conf,
 				   sizeof(*rx_conf));
 	if (ret < 0) {
-		wl1271_warning("wl1271 rx config opt failed: %d", ret);
+		dev_warn(wl->dev, "wl1271 rx config opt failed: %d\n", ret);
 		goto out;
 	}
 
@@ -1093,7 +1099,7 @@ int wl1271_acx_bet_enable(struct wl1271 *wl, struct wl12xx_vif *wlvif,
 
 	ret = wl1271_cmd_configure(wl, ACX_BET_ENABLE, acx, sizeof(*acx));
 	if (ret < 0) {
-		wl1271_warning("acx bet enable failed: %d", ret);
+		dev_warn(wl->dev, "acx bet enable failed: %d\n", ret);
 		goto out;
 	}
 
@@ -1126,7 +1132,7 @@ int wl1271_acx_arp_ip_filter(struct wl1271 *wl, struct wl12xx_vif *wlvif,
 	ret = wl1271_cmd_configure(wl, ACX_ARP_IP_FILTER,
 				   acx, sizeof(*acx));
 	if (ret < 0) {
-		wl1271_warning("failed to set arp ip filter: %d", ret);
+		dev_warn(wl->dev, "failed to set arp ip filter: %d\n", ret);
 		goto out;
 	}
 
@@ -1154,7 +1160,7 @@ int wl1271_acx_pm_config(struct wl1271 *wl)
 
 	ret = wl1271_cmd_configure(wl, ACX_PM_CONFIG, acx, sizeof(*acx));
 	if (ret < 0) {
-		wl1271_warning("acx pm config failed: %d", ret);
+		dev_warn(wl->dev, "acx pm config failed: %d\n", ret);
 		goto out;
 	}
 
@@ -1183,7 +1189,7 @@ int wl1271_acx_keep_alive_mode(struct wl1271 *wl, struct wl12xx_vif *wlvif,
 
 	ret = wl1271_cmd_configure(wl, ACX_KEEP_ALIVE_MODE, acx, sizeof(*acx));
 	if (ret < 0) {
-		wl1271_warning("acx keep alive mode failed: %d", ret);
+		dev_warn(wl->dev, "acx keep alive mode failed: %d\n", ret);
 		goto out;
 	}
 
@@ -1215,7 +1221,7 @@ int wl1271_acx_keep_alive_config(struct wl1271 *wl, struct wl12xx_vif *wlvif,
 	ret = wl1271_cmd_configure(wl, ACX_SET_KEEP_ALIVE_CONFIG,
 				   acx, sizeof(*acx));
 	if (ret < 0) {
-		wl1271_warning("acx keep alive config failed: %d", ret);
+		dev_warn(wl->dev, "acx keep alive config failed: %d\n", ret);
 		goto out;
 	}
 
@@ -1256,7 +1262,8 @@ int wl1271_acx_rssi_snr_trigger(struct wl1271 *wl, struct wl12xx_vif *wlvif,
 
 	ret = wl1271_cmd_configure(wl, ACX_RSSI_SNR_TRIGGER, acx, sizeof(*acx));
 	if (ret < 0) {
-		wl1271_warning("acx rssi snr trigger setting failed: %d", ret);
+		dev_warn(wl->dev, "acx rssi snr trigger setting failed: %d\n",
+			 ret);
 		goto out;
 	}
 
@@ -1288,7 +1295,8 @@ int wl1271_acx_rssi_snr_avg_weights(struct wl1271 *wl,
 
 	ret = wl1271_cmd_configure(wl, ACX_RSSI_SNR_WEIGHTS, acx, sizeof(*acx));
 	if (ret < 0) {
-		wl1271_warning("acx rssi snr trigger weights failed: %d", ret);
+		dev_warn(wl->dev, "acx rssi snr trigger weights failed: %d\n",
+			 ret);
 		goto out;
 	}
 
@@ -1335,7 +1343,8 @@ int wl1271_acx_set_ht_capabilities(struct wl1271 *wl,
 
 	ret = wl1271_cmd_configure(wl, ACX_PEER_HT_CAP, acx, sizeof(*acx));
 	if (ret < 0) {
-		wl1271_warning("acx ht capabilities setting failed: %d", ret);
+		dev_warn(wl->dev, "acx ht capabilities setting failed: %d\n",
+			 ret);
 		goto out;
 	}
 
@@ -1373,7 +1382,8 @@ int wl1271_acx_set_ht_information(struct wl1271 *wl,
 	ret = wl1271_cmd_configure(wl, ACX_HT_BSS_OPERATION, acx, sizeof(*acx));
 
 	if (ret < 0) {
-		wl1271_warning("acx ht information setting failed: %d", ret);
+		dev_warn(wl->dev, "acx ht information setting failed: %d\n",
+			 ret);
 		goto out;
 	}
 
@@ -1408,7 +1418,7 @@ int wl12xx_acx_set_ba_initiator_policy(struct wl1271 *wl,
 				   acx,
 				   sizeof(*acx));
 	if (ret < 0) {
-		wl1271_warning("acx ba initiator policy failed: %d", ret);
+		dev_warn(wl->dev, "acx ba initiator policy failed: %d\n", ret);
 		goto out;
 	}
 
@@ -1442,13 +1452,13 @@ int wl12xx_acx_set_ba_receiver_session(struct wl1271 *wl, u8 tid_index,
 					    sizeof(*acx),
 					    BIT(CMD_STATUS_NO_RX_BA_SESSION));
 	if (ret < 0) {
-		wl1271_warning("acx ba receiver session failed: %d", ret);
+		dev_warn(wl->dev, "acx ba receiver session failed: %d\n", ret);
 		goto out;
 	}
 
 	/* sometimes we can't start the session */
 	if (ret == CMD_STATUS_NO_RX_BA_SESSION) {
-		wl1271_warning("no fw rx ba on tid %d", tid_index);
+		dev_warn(wl->dev, "no fw rx ba on tid %d\n", tid_index);
 		ret = -EBUSY;
 		goto out;
 	}
@@ -1476,7 +1486,7 @@ int wl12xx_acx_tsf_info(struct wl1271 *wl, struct wl12xx_vif *wlvif,
 	ret = wl1271_cmd_interrogate(wl, ACX_TSF_INFO, tsf_info,
 				sizeof(struct acx_header), sizeof(*tsf_info));
 	if (ret < 0) {
-		wl1271_warning("acx tsf info interrogate failed");
+		dev_warn(wl->dev, "acx tsf info interrogate failed\n");
 		goto out;
 	}
 
@@ -1528,7 +1538,8 @@ int wl1271_acx_ps_rx_streaming(struct wl1271 *wl, struct wl12xx_vif *wlvif,
 					   rx_streaming,
 					   sizeof(*rx_streaming));
 		if (ret < 0) {
-			wl1271_warning("acx ps rx streaming failed: %d", ret);
+			dev_warn(wl->dev, "acx ps rx streaming failed: %d\n",
+				 ret);
 			goto out;
 		}
 	}
@@ -1553,7 +1564,7 @@ int wl1271_acx_ap_max_tx_retry(struct wl1271 *wl, struct wl12xx_vif *wlvif)
 
 	ret = wl1271_cmd_configure(wl, ACX_MAX_TX_FAILURE, acx, sizeof(*acx));
 	if (ret < 0) {
-		wl1271_warning("acx ap max tx retry failed: %d", ret);
+		dev_warn(wl->dev, "acx ap max tx retry failed: %d\n", ret);
 		goto out;
 	}
 
@@ -1583,7 +1594,7 @@ int wl12xx_acx_config_ps(struct wl1271 *wl, struct wl12xx_vif *wlvif)
 				   sizeof(*config_ps));
 
 	if (ret < 0) {
-		wl1271_warning("acx config ps failed: %d", ret);
+		dev_warn(wl->dev, "acx config ps failed: %d\n", ret);
 		goto out;
 	}
 
@@ -1610,7 +1621,7 @@ int wl1271_acx_set_inconnection_sta(struct wl1271 *wl,
 	ret = wl1271_cmd_configure(wl, ACX_UPDATE_INCONNECTION_STA_LIST,
 				   acx, sizeof(*acx));
 	if (ret < 0) {
-		wl1271_warning("acx set inconnaction sta failed: %d", ret);
+		dev_warn(wl->dev, "acx set inconnaction sta failed: %d\n", ret);
 		goto out;
 	}
 
@@ -1650,7 +1661,7 @@ int wl1271_acx_fm_coex(struct wl1271 *wl)
 
 	ret = wl1271_cmd_configure(wl, ACX_FM_COEX_CFG, acx, sizeof(*acx));
 	if (ret < 0) {
-		wl1271_warning("acx fm coex setting failed: %d", ret);
+		dev_warn(wl->dev, "acx fm coex setting failed: %d\n", ret);
 		goto out;
 	}
 
@@ -1692,7 +1703,7 @@ int wl12xx_acx_set_rate_mgmt_params(struct wl1271 *wl)
 	ret = wl1271_cmd_configure(wl, ACX_SET_RATE_MGMT_PARAMS,
 				   acx, sizeof(*acx));
 	if (ret < 0) {
-		wl1271_warning("acx set rate mgmt params failed: %d", ret);
+		dev_warn(wl->dev, "acx set rate mgmt params failed: %d\n", ret);
 		goto out;
 	}
 
@@ -1731,7 +1742,7 @@ int wl12xx_acx_config_hangover(struct wl1271 *wl)
 				   sizeof(*acx));
 
 	if (ret < 0) {
-		wl1271_warning("acx config hangover failed: %d", ret);
+		dev_warn(wl->dev, "acx config hangover failed: %d\n", ret);
 		goto out;
 	}
 
@@ -1759,7 +1770,7 @@ int wlcore_acx_average_rssi(struct wl1271 *wl, struct wl12xx_vif *wlvif,
 	ret = wl1271_cmd_interrogate(wl, ACX_ROAMING_STATISTICS_TBL,
 				     acx, sizeof(*acx), sizeof(*acx));
 	if (ret	< 0) {
-		wl1271_warning("acx roaming statistics failed: %d", ret);
+		dev_warn(wl->dev, "acx roaming statistics failed: %d\n", ret);
 		ret = -ENOMEM;
 		goto out;
 	}
@@ -1791,7 +1802,8 @@ int wl1271_acx_default_rx_filter_enable(struct wl1271 *wl, bool enable,
 	ret = wl1271_cmd_configure(wl, ACX_ENABLE_RX_DATA_FILTER, acx,
 				   sizeof(*acx));
 	if (ret < 0) {
-		wl1271_warning("acx default rx filter enable failed: %d", ret);
+		dev_warn(wl->dev, "acx default rx filter enable failed: %d\n",
+			 ret);
 		goto out;
 	}
 
@@ -1842,7 +1854,7 @@ int wl1271_acx_set_rx_filter(struct wl1271 *wl, u8 index, bool enable,
 
 	ret = wl1271_cmd_configure(wl, ACX_SET_RX_DATA_FILTER, acx, acx_size);
 	if (ret < 0) {
-		wl1271_warning("setting rx filter failed: %d", ret);
+		dev_warn(wl->dev, "setting rx filter failed: %d\n", ret);
 		goto out;
 	}
 
diff --git a/drivers/net/wireless/ti/wlcore/boot.c b/drivers/net/wireless/ti/wlcore/boot.c
index 19b7ec7..6dcdec7 100644
--- a/drivers/net/wireless/ti/wlcore/boot.c
+++ b/drivers/net/wireless/ti/wlcore/boot.c
@@ -67,7 +67,7 @@ static int wlcore_boot_parse_fw_ver(struct wl1271 *wl,
 		     &wl->chip.fw_ver[4]);
 
 	if (ret != 5) {
-		wl1271_warning("fw version incorrect value");
+		dev_warn(wl->dev, "fw version incorrect value\n");
 		memset(wl->chip.fw_ver, 0, sizeof(wl->chip.fw_ver));
 		ret = -EINVAL;
 		goto out;
@@ -127,13 +127,12 @@ fail:
 			snprintf(min_fw_str, sizeof(min_fw_str),
 				  "%s%u.", min_fw_str, min_ver[i]);
 
-	wl1271_error("Your WiFi FW version (%u.%u.%u.%u.%u) is invalid.\n"
-		     "Please use at least FW %s\n"
-		     "You can get the latest firmwares at:\n"
-		     "git://github.com/TI-OpenLink/firmwares.git",
-		     fw_ver[FW_VER_CHIP], fw_ver[FW_VER_IF_TYPE],
-		     fw_ver[FW_VER_MAJOR], fw_ver[FW_VER_SUBTYPE],
-		     fw_ver[FW_VER_MINOR], min_fw_str);
+	dev_err(wl->dev, "Your WiFi FW version (%u.%u.%u.%u.%u) is invalid\n",
+		fw_ver[FW_VER_CHIP], fw_ver[FW_VER_IF_TYPE],
+		fw_ver[FW_VER_MAJOR], fw_ver[FW_VER_SUBTYPE],
+		fw_ver[FW_VER_MINOR]);
+	dev_err(wl->dev, "Please use at least FW '%s'\n", min_fw_str);
+	dev_err(wl->dev, "You can get the latest firmwares at: git://github.com/TI-OpenLink/firmwares.git");
 	return -EINVAL;
 }
 
@@ -187,13 +186,13 @@ static int wl1271_boot_upload_firmware_chunk(struct wl1271 *wl, void *buf,
 		     fw_data_len, CHUNK_SIZE);
 
 	if ((fw_data_len % 4) != 0) {
-		wl1271_error("firmware length not multiple of four");
+		dev_err(wl->dev, "firmware length not multiple of four\n");
 		return -EIO;
 	}
 
 	chunk = kmalloc(CHUNK_SIZE, GFP_KERNEL);
 	if (!chunk) {
-		wl1271_error("allocation for firmware upload chunk failed");
+		dev_err(wl->dev, "allocation for firmware upload chunk failed\n");
 		return -ENOMEM;
 	}
 
@@ -265,7 +264,7 @@ int wlcore_boot_upload_firmware(struct wl1271 *wl)
 		fw += sizeof(u32);
 
 		if (len > 300000) {
-			wl1271_info("firmware chunk too long: %u", len);
+			dev_info(wl->dev, "firmware chunk too long: %u\n", len);
 			return -EINVAL;
 		}
 		wl1271_debug(DEBUG_BOOT, "chunk %d addr 0x%x len %u",
@@ -289,7 +288,7 @@ int wlcore_boot_upload_nvs(struct wl1271 *wl)
 	int ret;
 
 	if (wl->nvs == NULL) {
-		wl1271_error("NVS file is needed during boot");
+		dev_err(wl->dev, "NVS file is needed during boot\n");
 		return -ENODEV;
 	}
 
@@ -310,7 +309,7 @@ int wlcore_boot_upload_nvs(struct wl1271 *wl)
 		if (wl->nvs_len != sizeof(struct wl1271_nvs_file) &&
 		    (wl->nvs_len != WL1271_INI_LEGACY_NVS_FILE_SIZE ||
 		     wl->enable_11a)) {
-			wl1271_error("nvs size is not as expected: %zu != %zu",
+			dev_err(wl->dev, "nvs size is not as expected: %zu != %zu\n",
 				wl->nvs_len, sizeof(struct wl1271_nvs_file));
 			kfree(wl->nvs);
 			wl->nvs = NULL;
@@ -328,9 +327,9 @@ int wlcore_boot_upload_nvs(struct wl1271 *wl)
 			if (nvs->general_params.dual_mode_select)
 				wl->enable_11a = true;
 		} else {
-			wl1271_error("nvs size is not as expected: %zu != %zu",
-				     wl->nvs_len,
-				     sizeof(struct wl128x_nvs_file));
+			dev_err(wl->dev, "nvs size is not as expected: %zu != %zu\n",
+				wl->nvs_len,
+				sizeof(struct wl128x_nvs_file));
 			kfree(wl->nvs);
 			wl->nvs = NULL;
 			wl->nvs_len = 0;
@@ -429,7 +428,7 @@ int wlcore_boot_upload_nvs(struct wl1271 *wl)
 	return ret;
 
 out_badnvs:
-	wl1271_error("nvs data is malformed");
+	dev_err(wl->dev, "nvs data is malformed\n");
 	return -EILSEQ;
 }
 EXPORT_SYMBOL_GPL(wlcore_boot_upload_nvs);
@@ -455,7 +454,7 @@ int wlcore_boot_run_firmware(struct wl1271 *wl)
 	wl1271_debug(DEBUG_BOOT, "chip id after firmware boot: 0x%x", chip_id);
 
 	if (chip_id != wl->chip.id) {
-		wl1271_error("chip id doesn't match after firmware boot");
+		dev_err(wl->dev, "chip id doesn't match after firmware boot\n");
 		return -EIO;
 	}
 
@@ -468,8 +467,7 @@ int wlcore_boot_run_firmware(struct wl1271 *wl)
 			return ret;
 
 		if (intr == 0xffffffff) {
-			wl1271_error("error reading hardware complete "
-				     "init indication");
+			dev_err(wl->dev, "error reading hardware complete init indication\n");
 			return -EIO;
 		}
 		/* check that ACX_INTR_INIT_COMPLETE is enabled */
@@ -483,8 +481,7 @@ int wlcore_boot_run_firmware(struct wl1271 *wl)
 	}
 
 	if (loop > INIT_LOOP) {
-		wl1271_error("timeout waiting for the hardware to "
-			     "complete initialization");
+		dev_err(wl->dev, "timeout waiting for the hardware to complete initialization\n");
 		return -EIO;
 	}
 
@@ -507,7 +504,7 @@ int wlcore_boot_run_firmware(struct wl1271 *wl)
 
 	ret = wlcore_boot_static_data(wl);
 	if (ret < 0) {
-		wl1271_error("error getting static data");
+		dev_err(wl->dev, "error getting static data\n");
 		return ret;
 	}
 
@@ -519,7 +516,7 @@ int wlcore_boot_run_firmware(struct wl1271 *wl)
 	/* unmask required mbox events  */
 	ret = wl1271_event_unmask(wl);
 	if (ret < 0) {
-		wl1271_error("EVENT mask setting failed");
+		dev_err(wl->dev, "EVENT mask setting failed\n");
 		return ret;
 	}
 
diff --git a/drivers/net/wireless/ti/wlcore/cmd.c b/drivers/net/wireless/ti/wlcore/cmd.c
index f01d24b..8152a80 100644
--- a/drivers/net/wireless/ti/wlcore/cmd.c
+++ b/drivers/net/wireless/ti/wlcore/cmd.c
@@ -94,7 +94,7 @@ static int __wlcore_cmd_send(struct wl1271 *wl, u16 id, void *buf,
 
 	while (!(intr & WL1271_ACX_INTR_CMD_COMPLETE)) {
 		if (time_after(jiffies, timeout)) {
-			wl1271_error("command complete timeout");
+			dev_err(wl->dev, "command complete timeout\n");
 			return -ETIMEDOUT;
 		}
 
@@ -145,7 +145,7 @@ static int wlcore_cmd_send_failsafe(struct wl1271 *wl, u16 id, void *buf,
 
 	if (ret >= MAX_COMMAND_STATUS ||
 	    !test_bit(ret, &valid_rets)) {
-		wl1271_error("command execute failure %d", ret);
+		dev_err(wl->dev, "command execute failure %d\n", ret);
 		ret = -EIO;
 		goto fail;
 	}
@@ -256,7 +256,7 @@ int wl12xx_cmd_role_enable(struct wl1271 *wl, u8 *addr, u8 role_type,
 
 	ret = wl1271_cmd_send(wl, CMD_ROLE_ENABLE, cmd, sizeof(*cmd), 0);
 	if (ret < 0) {
-		wl1271_error("failed to initiate cmd role enable");
+		dev_err(wl->dev, "failed to initiate cmd role enable\n");
 		goto out_free;
 	}
 
@@ -289,7 +289,7 @@ int wl12xx_cmd_role_disable(struct wl1271 *wl, u8 *role_id)
 
 	ret = wl1271_cmd_send(wl, CMD_ROLE_DISABLE, cmd, sizeof(*cmd), 0);
 	if (ret < 0) {
-		wl1271_error("failed to initiate cmd role disable");
+		dev_err(wl->dev, "failed to initiate cmd role disable\n");
 		goto out_free;
 	}
 
@@ -455,7 +455,7 @@ static int wl12xx_cmd_role_start_dev(struct wl1271 *wl,
 
 	ret = wl1271_cmd_send(wl, CMD_ROLE_START, cmd, sizeof(*cmd), 0);
 	if (ret < 0) {
-		wl1271_error("failed to initiate cmd role enable");
+		dev_err(wl->dev, "failed to initiate cmd role enable\n");
 		goto err_hlid;
 	}
 
@@ -495,7 +495,7 @@ static int wl12xx_cmd_role_stop_dev(struct wl1271 *wl,
 
 	ret = wl1271_cmd_send(wl, CMD_ROLE_STOP, cmd, sizeof(*cmd), 0);
 	if (ret < 0) {
-		wl1271_error("failed to initiate cmd role stop");
+		dev_err(wl->dev, "failed to initiate cmd role stop\n");
 		goto out_free;
 	}
 
@@ -565,7 +565,7 @@ int wl12xx_cmd_role_start_sta(struct wl1271 *wl, struct wl12xx_vif *wlvif)
 
 	ret = wl1271_cmd_send(wl, CMD_ROLE_START, cmd, sizeof(*cmd), 0);
 	if (ret < 0) {
-		wl1271_error("failed to initiate cmd role start sta");
+		dev_err(wl->dev, "failed to initiate cmd role start sta\n");
 		goto err_hlid;
 	}
 
@@ -606,7 +606,7 @@ int wl12xx_cmd_role_stop_sta(struct wl1271 *wl, struct wl12xx_vif *wlvif)
 
 	ret = wl1271_cmd_send(wl, CMD_ROLE_STOP, cmd, sizeof(*cmd), 0);
 	if (ret < 0) {
-		wl1271_error("failed to initiate cmd role stop sta");
+		dev_err(wl->dev, "failed to initiate cmd role stop sta\n");
 		goto out_free;
 	}
 
@@ -631,7 +631,7 @@ int wl12xx_cmd_role_start_ap(struct wl1271 *wl, struct wl12xx_vif *wlvif)
 
 	/* trying to use hidden SSID with an old hostapd version */
 	if (wlvif->ssid_len == 0 && !bss_conf->hidden_ssid) {
-		wl1271_error("got a null SSID from beacon/bss");
+		dev_err(wl->dev, "got a null SSID from beacon/bss\n");
 		ret = -EINVAL;
 		goto out;
 	}
@@ -700,14 +700,15 @@ int wl12xx_cmd_role_start_ap(struct wl1271 *wl, struct wl12xx_vif *wlvif)
 		cmd->band = WLCORE_BAND_5GHZ;
 		break;
 	default:
-		wl1271_warning("ap start - unknown band: %d", (int)wlvif->band);
+		dev_warn(wl->dev, "ap start - unknown band: %d\n",
+			 (int)wlvif->band);
 		cmd->band = WLCORE_BAND_2_4GHZ;
 		break;
 	}
 
 	ret = wl1271_cmd_send(wl, CMD_ROLE_START, cmd, sizeof(*cmd), 0);
 	if (ret < 0) {
-		wl1271_error("failed to initiate cmd role start ap");
+		dev_err(wl->dev, "failed to initiate cmd role start ap\n");
 		goto out_free_bcast;
 	}
 
@@ -743,7 +744,7 @@ int wl12xx_cmd_role_stop_ap(struct wl1271 *wl, struct wl12xx_vif *wlvif)
 
 	ret = wl1271_cmd_send(wl, CMD_ROLE_STOP, cmd, sizeof(*cmd), 0);
 	if (ret < 0) {
-		wl1271_error("failed to initiate cmd role stop ap");
+		dev_err(wl->dev, "failed to initiate cmd role stop ap\n");
 		goto out_free;
 	}
 
@@ -803,7 +804,7 @@ int wl12xx_cmd_role_start_ibss(struct wl1271 *wl, struct wl12xx_vif *wlvif)
 
 	ret = wl1271_cmd_send(wl, CMD_ROLE_START, cmd, sizeof(*cmd), 0);
 	if (ret < 0) {
-		wl1271_error("failed to initiate cmd role enable");
+		dev_err(wl->dev, "failed to initiate cmd role enable\n");
 		goto err_hlid;
 	}
 
@@ -842,7 +843,7 @@ int wl1271_cmd_test(struct wl1271 *wl, void *buf, size_t buf_len, u8 answer)
 	ret = wl1271_cmd_send(wl, CMD_TEST, buf, buf_len, res_len);
 
 	if (ret < 0) {
-		wl1271_warning("TEST command failed");
+		dev_warn(wl->dev, "TEST command failed\n");
 		return ret;
 	}
 
@@ -873,7 +874,7 @@ int wl1271_cmd_interrogate(struct wl1271 *wl, u16 id, void *buf,
 
 	ret = wl1271_cmd_send(wl, CMD_INTERROGATE, acx, cmd_len, res_len);
 	if (ret < 0)
-		wl1271_error("INTERROGATE command failed");
+		dev_err(wl->dev, "INTERROGATE command failed\n");
 
 	return ret;
 }
@@ -907,7 +908,7 @@ int wlcore_cmd_configure_failsafe(struct wl1271 *wl, u16 id, void *buf,
 	ret = wlcore_cmd_send_failsafe(wl, CMD_CONFIGURE, acx, len, 0,
 				       valid_rets);
 	if (ret < 0) {
-		wl1271_warning("CONFIGURE command NOK");
+		dev_warn(wl->dev, "CONFIGURE command NOK\n");
 		return ret;
 	}
 
@@ -955,8 +956,8 @@ int wl1271_cmd_data_path(struct wl1271 *wl, bool enable)
 
 	ret = wl1271_cmd_send(wl, cmd_rx, cmd, sizeof(*cmd), 0);
 	if (ret < 0) {
-		wl1271_error("rx %s cmd for channel %d failed",
-			     enable ? "start" : "stop", cmd->channel);
+		dev_err(wl->dev, "rx %s cmd for channel %d failed\n",
+			enable ? "start" : "stop", cmd->channel);
 		goto out;
 	}
 
@@ -965,8 +966,8 @@ int wl1271_cmd_data_path(struct wl1271 *wl, bool enable)
 
 	ret = wl1271_cmd_send(wl, cmd_tx, cmd, sizeof(*cmd), 0);
 	if (ret < 0) {
-		wl1271_error("tx %s cmd for channel %d failed",
-			     enable ? "start" : "stop", cmd->channel);
+		dev_err(wl->dev, "tx %s cmd for channel %d failed\n",
+			enable ? "start" : "stop", cmd->channel);
 		goto out;
 	}
 
@@ -1000,7 +1001,7 @@ int wl1271_cmd_ps_mode(struct wl1271 *wl, struct wl12xx_vif *wlvif,
 	ret = wl1271_cmd_send(wl, CMD_SET_PS_MODE, ps_params,
 			      sizeof(*ps_params), 0);
 	if (ret < 0) {
-		wl1271_error("cmd set_ps_mode failed");
+		dev_err(wl->dev, "cmd set_ps_mode failed\n");
 		goto out;
 	}
 
@@ -1042,7 +1043,7 @@ int wl1271_cmd_template_set(struct wl1271 *wl, u8 role_id,
 
 	ret = wl1271_cmd_send(wl, CMD_SET_TEMPLATE, cmd, sizeof(*cmd), 0);
 	if (ret < 0) {
-		wl1271_warning("cmd set_template failed: %d", ret);
+		dev_warn(wl->dev, "cmd set_template failed: %d\n", ret);
 		goto out_free;
 	}
 
@@ -1080,7 +1081,7 @@ int wl12xx_cmd_build_null_data(struct wl1271 *wl, struct wl12xx_vif *wlvif)
 out:
 	dev_kfree_skb(skb);
 	if (ret)
-		wl1271_warning("cmd buld null data failed %d", ret);
+		dev_warn(wl->dev, "cmd buld null data failed %d\n", ret);
 
 	return ret;
 
@@ -1105,7 +1106,7 @@ int wl12xx_cmd_build_klv_null_data(struct wl1271 *wl,
 out:
 	dev_kfree_skb(skb);
 	if (ret)
-		wl1271_warning("cmd build klv null data failed %d", ret);
+		dev_warn(wl->dev, "cmd build klv null data failed %d\n", ret);
 
 	return ret;
 
@@ -1205,7 +1206,7 @@ struct sk_buff *wl1271_cmd_build_ap_probe_req(struct wl1271 *wl,
 					      skb->data, skb->len, 0, rate);
 
 	if (ret < 0)
-		wl1271_error("Unable to set ap probe request template.");
+		dev_err(wl->dev, "Unable to set ap probe request template\n");
 
 out:
 	return skb;
@@ -1224,7 +1225,7 @@ int wl1271_cmd_build_arp_rsp(struct wl1271 *wl, struct wl12xx_vif *wlvif)
 	skb = dev_alloc_skb(sizeof(*hdr) + sizeof(__le16) + sizeof(*tmpl) +
 			    WL1271_EXTRA_SPACE_MAX);
 	if (!skb) {
-		wl1271_error("failed to allocate buffer for arp rsp template");
+		dev_err(wl->dev, "failed to allocate buffer for arp rsp template\n");
 		return -ENOMEM;
 	}
 
@@ -1264,8 +1265,8 @@ int wl1271_cmd_build_arp_rsp(struct wl1271 *wl, struct wl12xx_vif *wlvif)
 		extra = 0;
 		break;
 	default:
-		wl1271_warning("Unknown encryption type: %d",
-			       wlvif->encryption_type);
+		dev_warn(wl->dev, "Unknown encryption type: %d\n",
+			 wlvif->encryption_type);
 		ret = -EINVAL;
 		goto out;
 	}
@@ -1348,7 +1349,7 @@ int wl12xx_cmd_set_default_wep_key(struct wl1271 *wl, u8 id, u8 hlid)
 
 	ret = wl1271_cmd_send(wl, CMD_SET_KEYS, cmd, sizeof(*cmd), 0);
 	if (ret < 0) {
-		wl1271_warning("cmd set_default_wep_key failed: %d", ret);
+		dev_warn(wl->dev, "cmd set_default_wep_key failed: %d\n", ret);
 		goto out;
 	}
 
@@ -1413,7 +1414,7 @@ int wl1271_cmd_set_sta_key(struct wl1271 *wl, struct wl12xx_vif *wlvif,
 
 	ret = wl1271_cmd_send(wl, CMD_SET_KEYS, cmd, sizeof(*cmd), 0);
 	if (ret < 0) {
-		wl1271_warning("could not set keys");
+		dev_warn(wl->dev, "could not set keys\n");
 	goto out;
 	}
 
@@ -1480,7 +1481,7 @@ int wl1271_cmd_set_ap_key(struct wl1271 *wl, struct wl12xx_vif *wlvif,
 
 	ret = wl1271_cmd_send(wl, CMD_SET_KEYS, cmd, sizeof(*cmd), 0);
 	if (ret < 0) {
-		wl1271_warning("could not set ap keys");
+		dev_warn(wl->dev, "could not set ap keys\n");
 		goto out;
 	}
 
@@ -1512,7 +1513,7 @@ int wl12xx_cmd_set_peer_state(struct wl1271 *wl, struct wl12xx_vif *wlvif,
 
 	ret = wl1271_cmd_send(wl, CMD_SET_PEER_STATE, cmd, sizeof(*cmd), 0);
 	if (ret < 0) {
-		wl1271_error("failed to send set peer state command");
+		dev_err(wl->dev, "failed to send set peer state command\n");
 		goto out_free;
 	}
 
@@ -1571,7 +1572,7 @@ int wl12xx_cmd_add_peer(struct wl1271 *wl, struct wl12xx_vif *wlvif,
 
 	ret = wl1271_cmd_send(wl, CMD_ADD_PEER, cmd, sizeof(*cmd), 0);
 	if (ret < 0) {
-		wl1271_error("failed to initiate cmd add peer");
+		dev_err(wl->dev, "failed to initiate cmd add peer\n");
 		goto out_free;
 	}
 
@@ -1605,7 +1606,7 @@ int wl12xx_cmd_remove_peer(struct wl1271 *wl, struct wl12xx_vif *wlvif,
 
 	ret = wl1271_cmd_send(wl, CMD_REMOVE_PEER, cmd, sizeof(*cmd), 0);
 	if (ret < 0) {
-		wl1271_error("failed to initiate cmd remove peer");
+		dev_err(wl->dev, "failed to initiate cmd remove peer\n");
 		goto out_free;
 	}
 
@@ -1628,7 +1629,8 @@ out:
 	return ret;
 }
 
-static int wlcore_get_reg_conf_ch_idx(enum ieee80211_band band, u16 ch)
+static int wlcore_get_reg_conf_ch_idx(struct wl1271 *wl,
+				      enum ieee80211_band band, u16 ch)
 {
 	/*
 	 * map the given band/channel to the respective predefined
@@ -1665,7 +1667,8 @@ static int wlcore_get_reg_conf_ch_idx(enum ieee80211_band band, u16 ch)
 		break;
 	}
 
-	wl1271_error("%s: unknown band/channel: %d/%d", __func__, band, ch);
+	dev_err(wl->dev, "%s: unknown band/channel: %d/%d\n",
+		__func__, band, ch);
 	return -1;
 }
 
@@ -1677,7 +1680,7 @@ void wlcore_set_pending_regdomain_ch(struct wl1271 *wl, u16 channel,
 	if (!(wl->quirks & WLCORE_QUIRK_REGDOMAIN_CONF))
 		return;
 
-	ch_bit_idx = wlcore_get_reg_conf_ch_idx(band, channel);
+	ch_bit_idx = wlcore_get_reg_conf_ch_idx(wl, band, channel);
 
 	if (ch_bit_idx >= 0 && ch_bit_idx <= WL1271_MAX_CHANNELS)
 		set_bit(ch_bit_idx, (long *)wl->reg_ch_conf_pending);
@@ -1714,7 +1717,7 @@ int wlcore_cmd_regdomain_config_locked(struct wl1271 *wl)
 			    channel->dfs_state != NL80211_DFS_AVAILABLE)
 				continue;
 
-			ch_bit_idx = wlcore_get_reg_conf_ch_idx(b, ch);
+			ch_bit_idx = wlcore_get_reg_conf_ch_idx(wl, b, ch);
 			if (ch_bit_idx < 0)
 				continue;
 
@@ -1739,12 +1742,12 @@ int wlcore_cmd_regdomain_config_locked(struct wl1271 *wl)
 	cmd->dfs_region = wl->dfs_region;
 
 	wl1271_debug(DEBUG_CMD,
-		     "cmd reg domain bitmap1: 0x%08x, bitmap2: 0x%08x",
+		     "cmd reg domain bitmap1: 0x%08x, bitmap2: 0x%08x\n",
 		     cmd->ch_bit_map1, cmd->ch_bit_map2);
 
 	ret = wl1271_cmd_send(wl, CMD_DFS_CHANNEL_CONFIG, cmd, sizeof(*cmd), 0);
 	if (ret < 0) {
-		wl1271_error("failed to send reg domain dfs config");
+		dev_err(wl->dev, "failed to send reg domain dfs config\n");
 		goto out;
 	}
 
@@ -1752,8 +1755,8 @@ int wlcore_cmd_regdomain_config_locked(struct wl1271 *wl)
 				      WLCORE_EVENT_DFS_CONFIG_COMPLETE,
 				      &timeout);
 	if (ret < 0 || timeout) {
-		wl1271_error("reg domain conf %serror",
-			     timeout ? "completion " : "");
+		dev_err(wl->dev, "reg domain conf %serror\n",
+			timeout ? "completion " : "");
 		ret = timeout ? -ETIMEDOUT : ret;
 		goto out;
 	}
@@ -1787,7 +1790,7 @@ int wl12xx_cmd_config_fwlog(struct wl1271 *wl)
 
 	ret = wl1271_cmd_send(wl, CMD_CONFIG_FWLOGGER, cmd, sizeof(*cmd), 0);
 	if (ret < 0) {
-		wl1271_error("failed to send config firmware logger command");
+		dev_err(wl->dev, "failed to send config firmware logger command\n");
 		goto out_free;
 	}
 
@@ -1813,7 +1816,7 @@ int wl12xx_cmd_start_fwlog(struct wl1271 *wl)
 
 	ret = wl1271_cmd_send(wl, CMD_START_FWLOGGER, cmd, sizeof(*cmd), 0);
 	if (ret < 0) {
-		wl1271_error("failed to send start firmware logger command");
+		dev_err(wl->dev, "failed to send start firmware logger command\n");
 		goto out_free;
 	}
 
@@ -1839,7 +1842,7 @@ int wl12xx_cmd_stop_fwlog(struct wl1271 *wl)
 
 	ret = wl1271_cmd_send(wl, CMD_STOP_FWLOGGER, cmd, sizeof(*cmd), 0);
 	if (ret < 0) {
-		wl1271_error("failed to send stop firmware logger command");
+		dev_err(wl->dev, "failed to send stop firmware logger command\n");
 		goto out_free;
 	}
 
@@ -1877,7 +1880,7 @@ static int wl12xx_cmd_roc(struct wl1271 *wl, struct wl12xx_vif *wlvif,
 		cmd->band = WLCORE_BAND_5GHZ;
 		break;
 	default:
-		wl1271_error("roc - unknown band: %d", (int)wlvif->band);
+		dev_err(wl->dev, "roc - unknown band: %d\n", (int)wlvif->band);
 		ret = -EINVAL;
 		goto out_free;
 	}
@@ -1885,7 +1888,7 @@ static int wl12xx_cmd_roc(struct wl1271 *wl, struct wl12xx_vif *wlvif,
 
 	ret = wl1271_cmd_send(wl, CMD_REMAIN_ON_CHANNEL, cmd, sizeof(*cmd), 0);
 	if (ret < 0) {
-		wl1271_error("failed to send ROC command");
+		dev_err(wl->dev, "failed to send ROC command\n");
 		goto out_free;
 	}
 
@@ -1913,7 +1916,7 @@ static int wl12xx_cmd_croc(struct wl1271 *wl, u8 role_id)
 	ret = wl1271_cmd_send(wl, CMD_CANCEL_REMAIN_ON_CHANNEL, cmd,
 			      sizeof(*cmd), 0);
 	if (ret < 0) {
-		wl1271_error("failed to send ROC command");
+		dev_err(wl->dev, "failed to send ROC command\n");
 		goto out_free;
 	}
 
@@ -1982,7 +1985,7 @@ int wl12xx_cmd_stop_channel_switch(struct wl1271 *wl, struct wl12xx_vif *wlvif)
 
 	ret = wl1271_cmd_send(wl, CMD_STOP_CHANNEL_SWICTH, cmd, sizeof(*cmd), 0);
 	if (ret < 0) {
-		wl1271_error("failed to stop channel switch command");
+		dev_err(wl->dev, "failed to stop channel switch command\n");
 		goto out_free;
 	}
 
@@ -2087,7 +2090,7 @@ int wlcore_cmd_generic_cfg(struct wl1271 *wl, struct wl12xx_vif *wlvif,
 
 	ret = wl1271_cmd_send(wl, CMD_GENERIC_CFG, cmd, sizeof(*cmd), 0);
 	if (ret < 0) {
-		wl1271_error("failed to send generic cfg command");
+		dev_err(wl->dev, "failed to send generic cfg command\n");
 		goto out_free;
 	}
 out_free:
diff --git a/drivers/net/wireless/ti/wlcore/debug.h b/drivers/net/wireless/ti/wlcore/debug.h
index 27bfb7c..90d3aad 100644
--- a/drivers/net/wireless/ti/wlcore/debug.h
+++ b/drivers/net/wireless/ti/wlcore/debug.h
@@ -61,18 +61,6 @@ extern u32 wl12xx_debug_level;
 
 #define DEBUG_DUMP_LIMIT 1024
 
-#define wl1271_error(fmt, arg...) \
-	pr_err(DRIVER_PREFIX "ERROR " fmt "\n", ##arg)
-
-#define wl1271_warning(fmt, arg...) \
-	pr_warn(DRIVER_PREFIX "WARNING " fmt "\n", ##arg)
-
-#define wl1271_notice(fmt, arg...) \
-	pr_info(DRIVER_PREFIX fmt "\n", ##arg)
-
-#define wl1271_info(fmt, arg...) \
-	pr_info(DRIVER_PREFIX fmt "\n", ##arg)
-
 /* define the debug macro differently if dynamic debug is supported */
 #if defined(CONFIG_DYNAMIC_DEBUG)
 #define wl1271_debug(level, fmt, arg...) \
@@ -84,7 +72,7 @@ extern u32 wl12xx_debug_level;
 #define wl1271_debug(level, fmt, arg...) \
 	do { \
 		if (unlikely(level & wl12xx_debug_level)) \
-			printk(KERN_DEBUG pr_fmt(DRIVER_PREFIX fmt "\n"), \
+			printk(KERN_DEBUG DRIVER_PREFIX fmt "\n", \
 			       ##arg); \
 	} while (0)
 #endif
diff --git a/drivers/net/wireless/ti/wlcore/debugfs.c b/drivers/net/wireless/ti/wlcore/debugfs.c
index 7f672f6..8664c32 100644
--- a/drivers/net/wireless/ti/wlcore/debugfs.c
+++ b/drivers/net/wireless/ti/wlcore/debugfs.c
@@ -114,7 +114,7 @@ static void chip_op_handler(struct wl1271 *wl, unsigned long value,
 	int (*chip_op) (struct wl1271 *wl);
 
 	if (!arg) {
-		wl1271_warning("debugfs chip_op_handler with no callback");
+		dev_warn(wl->dev, "debugfs chip_op_handler with no callback\n");
 		return;
 	}
 
@@ -158,12 +158,12 @@ static inline void no_write_handler(struct wl1271 *wl,
 									\
 	ret = kstrtoul_from_user(user_buf, count, 10, &value);		\
 	if (ret < 0) {							\
-		wl1271_warning("illegal value for " #param);		\
+		dev_warn(wl->dev, "illegal value for " #param "\n");	\
 		return -EINVAL;						\
 	}								\
 									\
 	if (value < min_val || value > max_val) {			\
-		wl1271_warning(#param " is not in valid range");	\
+		dev_warn(wl->dev, #param " is not in valid range\n");	\
 		return -ERANGE;						\
 	}								\
 									\
@@ -214,7 +214,7 @@ static ssize_t gpio_power_write(struct file *file,
 
 	ret = kstrtoul_from_user(user_buf, count, 10, &value);
 	if (ret < 0) {
-		wl1271_warning("illegal value in gpio_power");
+		dev_warn(wl->dev, "illegal value in gpio_power\n");
 		return -EINVAL;
 	}
 
@@ -276,12 +276,12 @@ static ssize_t dynamic_ps_timeout_write(struct file *file,
 
 	ret = kstrtoul_from_user(user_buf, count, 10, &value);
 	if (ret < 0) {
-		wl1271_warning("illegal value in dynamic_ps");
+		dev_warn(wl->dev, "illegal value in dynamic_ps\n");
 		return -EINVAL;
 	}
 
 	if (value < 1 || value > 65535) {
-		wl1271_warning("dyanmic_ps_timeout is not in valid range");
+		dev_warn(wl->dev, "dyanmic_ps_timeout is not in valid range\n");
 		return -ERANGE;
 	}
 
@@ -340,12 +340,12 @@ static ssize_t forced_ps_write(struct file *file,
 
 	ret = kstrtoul_from_user(user_buf, count, 10, &value);
 	if (ret < 0) {
-		wl1271_warning("illegal value in forced_ps");
+		dev_warn(wl->dev, "illegal value in forced_ps\n");
 		return -EINVAL;
 	}
 
 	if (value != 1 && value != 0) {
-		wl1271_warning("forced_ps should be either 0 or 1");
+		dev_warn(wl->dev, "forced_ps should be either 0 or 1\n");
 		return -ERANGE;
 	}
 
@@ -408,12 +408,12 @@ static ssize_t split_scan_timeout_write(struct file *file,
 
 	ret = kstrtoul_from_user(user_buf, count, 10, &value);
 	if (ret < 0) {
-		wl1271_warning("illegal value in split_scan_timeout");
+		dev_warn(wl->dev, "illegal value in split_scan_timeout\n");
 		return -EINVAL;
 	}
 
 	if (value == 0)
-		wl1271_info("split scan will be disabled");
+		dev_info(wl->dev, "split scan will be disabled\n");
 
 	mutex_lock(&wl->mutex);
 
@@ -664,12 +664,12 @@ static ssize_t dtim_interval_write(struct file *file,
 
 	ret = kstrtoul_from_user(user_buf, count, 10, &value);
 	if (ret < 0) {
-		wl1271_warning("illegal value for dtim_interval");
+		dev_warn(wl->dev, "illegal value for dtim_interval\n");
 		return -EINVAL;
 	}
 
 	if (value < 1 || value > 10) {
-		wl1271_warning("dtim value is not in valid range");
+		dev_warn(wl->dev, "dtim value is not in valid range\n");
 		return -ERANGE;
 	}
 
@@ -725,12 +725,12 @@ static ssize_t suspend_dtim_interval_write(struct file *file,
 
 	ret = kstrtoul_from_user(user_buf, count, 10, &value);
 	if (ret < 0) {
-		wl1271_warning("illegal value for suspend_dtim_interval");
+		dev_warn(wl->dev, "illegal value for suspend_dtim_interval\n");
 		return -EINVAL;
 	}
 
 	if (value < 1 || value > 10) {
-		wl1271_warning("suspend_dtim value is not in valid range");
+		dev_warn(wl->dev, "suspend_dtim value is not in valid range\n");
 		return -ERANGE;
 	}
 
@@ -780,12 +780,12 @@ static ssize_t beacon_interval_write(struct file *file,
 
 	ret = kstrtoul_from_user(user_buf, count, 10, &value);
 	if (ret < 0) {
-		wl1271_warning("illegal value for beacon_interval");
+		dev_warn(wl->dev, "illegal value for beacon_interval\n");
 		return -EINVAL;
 	}
 
 	if (value < 1 || value > 255) {
-		wl1271_warning("beacon interval value is not in valid range");
+		dev_warn(wl->dev, "beacon interval value is not in valid range\n");
 		return -ERANGE;
 	}
 
@@ -824,13 +824,13 @@ static ssize_t rx_streaming_interval_write(struct file *file,
 
 	ret = kstrtoul_from_user(user_buf, count, 10, &value);
 	if (ret < 0) {
-		wl1271_warning("illegal value in rx_streaming_interval!");
+		dev_warn(wl->dev, "illegal value in rx_streaming_interval!\n");
 		return -EINVAL;
 	}
 
 	/* valid values: 0, 10-100 */
 	if (value && (value < 10 || value > 100)) {
-		wl1271_warning("value is not in range!");
+		dev_warn(wl->dev, "value is not in range!\n");
 		return -ERANGE;
 	}
 
@@ -879,13 +879,13 @@ static ssize_t rx_streaming_always_write(struct file *file,
 
 	ret = kstrtoul_from_user(user_buf, count, 10, &value);
 	if (ret < 0) {
-		wl1271_warning("illegal value in rx_streaming_write!");
+		dev_warn(wl->dev, "illegal value in rx_streaming_write!\n");
 		return -EINVAL;
 	}
 
 	/* valid values: 0, 10-100 */
 	if (!(value == 0 || value == 1)) {
-		wl1271_warning("value is not in valid!");
+		dev_warn(wl->dev, "value is not in valid!\n");
 		return -EINVAL;
 	}
 
@@ -934,7 +934,7 @@ static ssize_t beacon_filtering_write(struct file *file,
 
 	ret = kstrtoul_from_user(user_buf, count, 0, &value);
 	if (ret < 0) {
-		wl1271_warning("illegal value for beacon_filtering!");
+		dev_warn(wl->dev, "illegal value for beacon_filtering!\n");
 		return -EINVAL;
 	}
 
@@ -999,13 +999,13 @@ static ssize_t sleep_auth_write(struct file *file,
 
 	ret = kstrtoul_from_user(user_buf, count, 0, &value);
 	if (ret < 0) {
-		wl1271_warning("illegal value in sleep_auth");
+		dev_warn(wl->dev, "illegal value in sleep_auth\n");
 		return -EINVAL;
 	}
 
 	if (value > WL1271_PSM_MAX) {
-		wl1271_warning("sleep_auth must be between 0 and %d",
-			       WL1271_PSM_MAX);
+		dev_warn(wl->dev, "sleep_auth must be between 0 and %d\n",
+			 WL1271_PSM_MAX);
 		return -ERANGE;
 	}
 
@@ -1239,17 +1239,17 @@ static ssize_t fw_logger_write(struct file *file,
 
 	ret = kstrtoul_from_user(user_buf, count, 0, &value);
 	if (ret < 0) {
-		wl1271_warning("illegal value in fw_logger");
+		dev_warn(wl->dev, "illegal value in fw_logger\n");
 		return -EINVAL;
 	}
 
 	if ((value > 2) || (value == 0)) {
-		wl1271_warning("fw_logger value must be 1-UART 2-SDIO");
+		dev_warn(wl->dev, "fw_logger value must be 1-UART 2-SDIO\n");
 		return -ERANGE;
 	}
 
 	if (wl->conf.fwlog.output == 0) {
-		wl1271_warning("iligal opperation - fw logger disabled by default, please change mode via wlconf");
+		dev_warn(wl->dev, "invalid operation - fw logger disabled by default, please change mode via wlconf\n");
 		return -EINVAL;
 	}
 
diff --git a/drivers/net/wireless/ti/wlcore/event.c b/drivers/net/wireless/ti/wlcore/event.c
index 4b59f67..27d9c26 100644
--- a/drivers/net/wireless/ti/wlcore/event.c
+++ b/drivers/net/wireless/ti/wlcore/event.c
@@ -53,7 +53,7 @@ int wlcore_event_fw_logger(struct wl1271 *wl)
 
 	buffer = kzalloc(WL18XX_LOGGER_SDIO_BUFF_MAX, GFP_KERNEL);
 	if (!buffer) {
-		wl1271_error("Fail to allocate fw logger memory");
+		dev_err(wl->dev, "Fail to allocate fw logger memory\n");
 		fw_log.actual_buff_size = cpu_to_le32(0);
 		goto out;
 	}
@@ -61,8 +61,8 @@ int wlcore_event_fw_logger(struct wl1271 *wl)
 	ret = wlcore_read(wl, addr, buffer, WL18XX_LOGGER_SDIO_BUFF_MAX,
 			  false);
 	if (ret < 0) {
-		wl1271_error("Fail to read logger buffer, error_id = %d",
-			     ret);
+		dev_err(wl->dev, "Fail to read logger buffer, error_id = %d\n",
+			ret);
 		fw_log.actual_buff_size = cpu_to_le32(0);
 		goto free_out;
 	}
@@ -97,8 +97,8 @@ int wlcore_event_fw_logger(struct wl1271 *wl)
 
 	/* double check that clear address and write pointer are the same */
 	if (clear_addr != le32_to_cpu(fw_log.buff_write_ptr)) {
-		wl1271_error("Calculate of clear addr Clear = %x, write = %x",
-			     clear_addr, le32_to_cpu(fw_log.buff_write_ptr));
+		dev_err(wl->dev, "Calculate of clear addr Clear = %x, write = %x\n",
+			clear_addr, le32_to_cpu(fw_log.buff_write_ptr));
 	}
 
 	/* indicate FW about Clear buffer */
@@ -246,7 +246,7 @@ EXPORT_SYMBOL_GPL(wlcore_event_channel_switch);
 void wlcore_event_dummy_packet(struct wl1271 *wl)
 {
 	if (wl->plt) {
-		wl1271_info("Got DUMMY_PACKET event in PLT mode.  FW bug, ignoring.");
+		dev_info(wl->dev, "Got DUMMY_PACKET event in PLT mode.  FW bug, ignoring.\n");
 		return;
 	}
 
@@ -322,7 +322,7 @@ void wlcore_event_beacon_loss(struct wl1271 *wl, unsigned long roles_bitmap)
 	int delay = wl->conf.conn.synch_fail_thold *
 				wl->conf.conn.bss_lose_timeout;
 
-	wl1271_info("Beacon loss detected. roles:0x%lx", roles_bitmap);
+	dev_info(wl->dev, "Beacon loss detected. roles:0x%lx\n", roles_bitmap);
 
 	wl12xx_for_each_wlvif_sta(wl, wlvif) {
 		if (wlvif->role_id == WL12XX_INVALID_ROLE_ID ||
diff --git a/drivers/net/wireless/ti/wlcore/main.c b/drivers/net/wireless/ti/wlcore/main.c
index 45662cf..acfdd0f 100644
--- a/drivers/net/wireless/ti/wlcore/main.c
+++ b/drivers/net/wireless/ti/wlcore/main.c
@@ -20,6 +20,8 @@
  *
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/module.h>
 #include <linux/firmware.h>
 #include <linux/etherdevice.h>
@@ -71,7 +73,7 @@ static int wl12xx_set_authorized(struct wl1271 *wl, struct wl12xx_vif *wlvif)
 	if (ret < 0)
 		return ret;
 
-	wl1271_info("Association completed.");
+	dev_info(wl->dev, "Association completed\n");
 	return 0;
 }
 
@@ -292,8 +294,8 @@ static void wl12xx_tx_watchdog_work(struct work_struct *work)
 		goto out;
 	}
 
-	wl1271_error("Tx stuck (in FW) for %d ms. Starting recovery",
-		     wl->conf.tx.tx_watchdog_timeout);
+	dev_err(wl->dev, "Tx stuck (in FW) for %d ms. Starting recovery.\n",
+		wl->conf.tx.tx_watchdog_timeout);
 	wl12xx_queue_recovery_work(wl);
 
 out:
@@ -314,7 +316,8 @@ static void wlcore_adjust_conf(struct wl1271 *wl)
 			wl->conf.fwlog.mem_blocks = 0;
 			wl->conf.fwlog.output = WL12XX_FWLOG_OUTPUT_NONE;
 		} else {
-			wl1271_error("Unknown fwlog parameter %s", fwlog_param);
+			dev_err(wl->dev, "Unknown fwlog parameter %s\n",
+				fwlog_param);
 		}
 	}
 
@@ -558,7 +561,7 @@ static int wlcore_irq_locked(struct wl1271 *wl)
 		}
 
 		if (unlikely(intr & WL1271_ACX_INTR_WATCHDOG)) {
-			wl1271_error("HW watchdog interrupt received! starting recovery.");
+			dev_err(wl->dev, "HW watchdog interrupt received! starting recovery.\n");
 			wl->watchdog_recovery = true;
 			ret = -EIO;
 
@@ -567,8 +570,7 @@ static int wlcore_irq_locked(struct wl1271 *wl)
 		}
 
 		if (unlikely(intr & WL1271_ACX_SW_INTR_WATCHDOG)) {
-			wl1271_error("SW watchdog interrupt received! "
-				     "starting recovery.");
+			dev_err(wl->dev, "SW watchdog interrupt received! starting recovery.\n");
 			wl->watchdog_recovery = true;
 			ret = -EIO;
 
@@ -748,13 +750,14 @@ static int wl12xx_fetch_firmware(struct wl1271 *wl, bool plt)
 	ret = request_firmware(&fw, fw_name, wl->dev);
 
 	if (ret < 0) {
-		wl1271_error("could not get firmware %s: %d", fw_name, ret);
+		dev_err(wl->dev, "could not get firmware %s: %d\n",
+			fw_name, ret);
 		return ret;
 	}
 
 	if (fw->size % 4) {
-		wl1271_error("firmware size is not multiple of 32 bits: %zu",
-			     fw->size);
+		dev_err(wl->dev, "firmware size is not multiple of 32 bits: %zu\n",
+			fw->size);
 		ret = -EILSEQ;
 		goto out;
 	}
@@ -765,7 +768,7 @@ static int wl12xx_fetch_firmware(struct wl1271 *wl, bool plt)
 	wl->fw = vmalloc(wl->fw_len);
 
 	if (!wl->fw) {
-		wl1271_error("could not allocate memory for the firmware");
+		dev_err(wl->dev, "could not allocate memory for the firmware\n");
 		ret = -ENOMEM;
 		goto out;
 	}
@@ -815,7 +818,7 @@ static void wl12xx_read_fwlog_panic(struct wl1271 *wl)
 	if (wl->quirks & WLCORE_QUIRK_FWLOG_NOT_IMPLEMENTED)
 		return;
 
-	wl1271_info("Reading FW panic log");
+	dev_info(wl->dev, "Reading FW panic log\n");
 
 	/*
 	 * Make sure the chip is awake and the logger isn't active.
@@ -882,8 +885,8 @@ static void wlcore_print_recovery(struct wl1271 *wl)
 	u32 hint_sts = 0;
 	int ret;
 
-	wl1271_info("Hardware recovery in progress. FW ver: %s",
-		    wl->chip.fw_ver_str);
+	dev_info(wl->dev, "Hardware recovery in progress. FW ver: %s\n",
+		 wl->chip.fw_ver_str);
 
 	/* change partitions momentarily so we can read the FW pc */
 	ret = wlcore_set_partition(wl, &wl->ptable[PART_BOOT]);
@@ -898,8 +901,8 @@ static void wlcore_print_recovery(struct wl1271 *wl)
 	if (ret < 0)
 		return;
 
-	wl1271_info("pc: 0x%x, hint_sts: 0x%08x count: %d",
-				pc, hint_sts, ++wl->recovery_count);
+	dev_info(wl->dev, "pc: 0x%x, hint_sts: 0x%08x count: %d\n",
+		 pc, hint_sts, ++wl->recovery_count);
 
 	wlcore_set_partition(wl, &wl->ptable[PART_WORK]);
 }
@@ -927,7 +930,7 @@ static void wl1271_recovery_work(struct work_struct *work)
 	       !test_bit(WL1271_FLAG_INTENDED_FW_RECOVERY, &wl->flags));
 
 	if (wl->conf.recovery.no_recovery) {
-		wl1271_info("No recovery (chosen on module load). Fw will remain stuck.");
+		dev_info(wl->dev, "No recovery (chosen on module load). Fw will remain stuck.\n");
 		goto out_unlock;
 	}
 
@@ -1072,11 +1075,11 @@ int wl1271_plt_start(struct wl1271 *wl, const enum plt_mode plt_mode)
 
 	mutex_lock(&wl->mutex);
 
-	wl1271_notice("power up");
+	dev_notice(wl->dev, "power up\n");
 
 	if (wl->state != WLCORE_STATE_OFF) {
-		wl1271_error("cannot go into PLT state because not "
-			     "in off state: %d", wl->state);
+		dev_err(wl->dev, "cannot go into PLT state because not in off state: %d\n",
+			wl->state);
 		ret = -EBUSY;
 		goto out;
 	}
@@ -1098,9 +1101,9 @@ int wl1271_plt_start(struct wl1271 *wl, const enum plt_mode plt_mode)
 		}
 
 		wl->state = WLCORE_STATE_ON;
-		wl1271_notice("firmware booted in PLT mode %s (%s)",
-			      PLT_MODE[plt_mode],
-			      wl->chip.fw_ver_str);
+		dev_notice(wl->dev, "firmware booted in PLT mode %s (%s)\n",
+			   PLT_MODE[plt_mode],
+			   wl->chip.fw_ver_str);
 
 		/* update hw/fw version info in wiphy struct */
 		wiphy->hw_version = wl->chip.id;
@@ -1116,8 +1119,8 @@ power_off:
 	wl->plt = false;
 	wl->plt_mode = PLT_OFF;
 
-	wl1271_error("firmware boot in PLT mode failed despite %d retries",
-		     WL1271_BOOT_RETRIES);
+	dev_err(wl->dev, "firmware boot in PLT mode failed despite %d retries\n",
+		WL1271_BOOT_RETRIES);
 out:
 	mutex_unlock(&wl->mutex);
 
@@ -1128,7 +1131,7 @@ int wl1271_plt_stop(struct wl1271 *wl)
 {
 	int ret = 0;
 
-	wl1271_notice("power down");
+	dev_notice(wl->dev, "power down\n");
 
 	/*
 	 * Interrupts must be disabled before setting the state to OFF.
@@ -1147,8 +1150,8 @@ int wl1271_plt_stop(struct wl1271 *wl)
 		 */
 		wlcore_enable_interrupts(wl);
 
-		wl1271_error("cannot power down because not in PLT "
-			     "state: %d", wl->state);
+		dev_err(wl->dev, "cannot power down because not in PLT state: %d\n",
+			wl->state);
 		ret = -EBUSY;
 		goto out;
 	}
@@ -1293,7 +1296,7 @@ static struct sk_buff *wl12xx_alloc_dummy_packet(struct wl1271 *wl)
 
 	skb = dev_alloc_skb(TOTAL_TX_DUMMY_PACKET_SIZE);
 	if (!skb) {
-		wl1271_warning("Failed to allocate a dummy packet skb");
+		dev_warn(wl->dev, "Failed to allocate a dummy packet skb\n");
 		return NULL;
 	}
 
@@ -1320,13 +1323,14 @@ static struct sk_buff *wl12xx_alloc_dummy_packet(struct wl1271 *wl)
 
 #ifdef CONFIG_PM
 static int
-wl1271_validate_wowlan_pattern(struct cfg80211_pkt_pattern *p)
+wl1271_validate_wowlan_pattern(struct wl1271 *wl,
+			       struct cfg80211_pkt_pattern *p)
 {
 	int num_fields = 0, in_field = 0, fields_size = 0;
 	int i, pattern_len = 0;
 
 	if (!p->mask) {
-		wl1271_warning("No mask in WoWLAN pattern");
+		dev_warn(wl->dev, "No mask in WoWLAN pattern\n");
 		return -EINVAL;
 	}
 
@@ -1369,12 +1373,12 @@ wl1271_validate_wowlan_pattern(struct cfg80211_pkt_pattern *p)
 	}
 
 	if (num_fields > WL1271_RX_FILTER_MAX_FIELDS) {
-		wl1271_warning("RX Filter too complex. Too many segments");
+		dev_warn(wl->dev, "RX Filter too complex - too many segments\n");
 		return -EINVAL;
 	}
 
 	if (fields_size > WL1271_RX_FILTER_MAX_FIELDS_SIZE) {
-		wl1271_warning("RX filter pattern is too big");
+		dev_warn(wl->dev, "RX filter pattern is too big\n");
 		return -E2BIG;
 	}
 
@@ -1399,14 +1403,15 @@ void wl1271_rx_filter_free(struct wl12xx_rx_filter *filter)
 	kfree(filter);
 }
 
-int wl1271_rx_filter_alloc_field(struct wl12xx_rx_filter *filter,
-				 u16 offset, u8 flags,
-				 const u8 *pattern, u8 len)
+static int wl1271_rx_filter_alloc_field(struct wl1271 *wl,
+					struct wl12xx_rx_filter *filter,
+					u16 offset, u8 flags,
+					const u8 *pattern, u8 len)
 {
 	struct wl12xx_rx_filter_field *field;
 
 	if (filter->num_fields == WL1271_RX_FILTER_MAX_FIELDS) {
-		wl1271_warning("Max fields per RX filter. can't alloc another");
+		dev_warn(wl->dev, "Max fields per RX filter - can't alloc another\n");
 		return -EINVAL;
 	}
 
@@ -1414,7 +1419,7 @@ int wl1271_rx_filter_alloc_field(struct wl12xx_rx_filter *filter,
 
 	field->pattern = kzalloc(len, GFP_KERNEL);
 	if (!field->pattern) {
-		wl1271_warning("Failed to allocate RX filter pattern");
+		dev_warn(wl->dev, "Failed to allocate RX filter pattern\n");
 		return -ENOMEM;
 	}
 
@@ -1464,7 +1469,8 @@ void wl1271_rx_filter_flatten_fields(struct wl12xx_rx_filter *filter,
  * which needs to be freed using rx_filter_free()
  */
 static int
-wl1271_convert_wowlan_pattern_to_rx_filter(struct cfg80211_pkt_pattern *p,
+wl1271_convert_wowlan_pattern_to_rx_filter(struct wl1271 *wl,
+					   struct cfg80211_pkt_pattern *p,
 					   struct wl12xx_rx_filter **f)
 {
 	int i, j, ret = 0;
@@ -1474,7 +1480,7 @@ wl1271_convert_wowlan_pattern_to_rx_filter(struct cfg80211_pkt_pattern *p,
 
 	filter = wl1271_rx_filter_alloc();
 	if (!filter) {
-		wl1271_warning("Failed to alloc rx filter");
+		dev_warn(wl->dev, "Failed to alloc rx filter\n");
 		ret = -ENOMEM;
 		goto err;
 	}
@@ -1505,7 +1511,7 @@ wl1271_convert_wowlan_pattern_to_rx_filter(struct cfg80211_pkt_pattern *p,
 
 		len = j - i;
 
-		ret = wl1271_rx_filter_alloc_field(filter,
+		ret = wl1271_rx_filter_alloc_field(wl, filter,
 						   offset,
 						   flags,
 						   &p->pattern[i], len);
@@ -1550,9 +1556,9 @@ static int wl1271_configure_wowlan(struct wl1271 *wl,
 
 	/* Validate all incoming patterns before clearing current FW state */
 	for (i = 0; i < wow->n_patterns; i++) {
-		ret = wl1271_validate_wowlan_pattern(&wow->patterns[i]);
+		ret = wl1271_validate_wowlan_pattern(wl, &wow->patterns[i]);
 		if (ret) {
-			wl1271_warning("Bad wowlan pattern %d", i);
+			dev_warn(wl->dev, "Bad wowlan pattern %d\n", i);
 			return ret;
 		}
 	}
@@ -1572,10 +1578,11 @@ static int wl1271_configure_wowlan(struct wl1271 *wl,
 
 		p = &wow->patterns[i];
 
-		ret = wl1271_convert_wowlan_pattern_to_rx_filter(p, &filter);
+		ret = wl1271_convert_wowlan_pattern_to_rx_filter(wl,
+								 p, &filter);
 		if (ret) {
-			wl1271_warning("Failed to create an RX filter from "
-				       "wowlan pattern %d", i);
+			dev_warn(wl->dev, "Failed to create an RX filter from wowlan pattern %d\n",
+				 i);
 			goto out;
 		}
 
@@ -1616,7 +1623,8 @@ static int wl1271_configure_suspend_sta(struct wl1271 *wl,
 				    wl->conf.conn.suspend_listen_interval);
 
 	if (ret < 0)
-		wl1271_error("suspend: set wake up conditions failed: %d", ret);
+		dev_err(wl->dev, "suspend: set wake up conditions failed: %d\n",
+			ret);
 out:
 	return ret;
 
@@ -1682,8 +1690,8 @@ static void wl1271_configure_resume(struct wl1271 *wl, struct wl12xx_vif *wlvif)
 				    wl->conf.conn.listen_interval);
 
 		if (ret < 0)
-			wl1271_error("resume: wake up conditions failed: %d",
-				     ret);
+			dev_err(wl->dev, "resume: wake up conditions failed: %d\n",
+				ret);
 
 	} else if (is_ap) {
 		ret = wl1271_acx_beacon_filter_opt(wl, wlvif, false);
@@ -1702,7 +1710,7 @@ static int wl1271_op_suspend(struct ieee80211_hw *hw,
 
 	/* we want to perform the recovery before suspending */
 	if (test_bit(WL1271_FLAG_RECOVERY_IN_PROGRESS, &wl->flags)) {
-		wl1271_warning("postponing suspend to perform recovery");
+		dev_warn(wl->dev, "postponing suspend to perform recovery\n");
 		return -EBUSY;
 	}
 
@@ -1724,7 +1732,7 @@ static int wl1271_op_suspend(struct ieee80211_hw *hw,
 		ret = wl1271_configure_suspend(wl, wlvif, wow);
 		if (ret < 0) {
 			mutex_unlock(&wl->mutex);
-			wl1271_warning("couldn't prepare device to suspend");
+			dev_warn(wl->dev, "couldn't prepare device to suspend\n");
 			return ret;
 		}
 	}
@@ -1745,7 +1753,7 @@ out_sleep:
 	mutex_unlock(&wl->mutex);
 
 	if (ret < 0) {
-		wl1271_warning("couldn't prepare device to suspend");
+		dev_warn(wl->dev, "couldn't prepare device to suspend\n");
 		return ret;
 	}
 
@@ -1820,7 +1828,7 @@ static int wl1271_op_resume(struct ieee80211_hw *hw)
 	}
 
 	if (pending_recovery) {
-		wl1271_warning("queuing forgotten recovery on resume");
+		dev_warn(wl->dev, "queuing forgotten recovery on resume\n");
 		ieee80211_queue_work(wl->hw, &wl->recovery_work);
 		goto out_sleep;
 	}
@@ -2015,7 +2023,8 @@ static void wlcore_channel_switch_work(struct work_struct *work)
 	wlvif = container_of(dwork, struct wl12xx_vif, channel_switch_work);
 	wl = wlvif->wl;
 
-	wl1271_info("channel switch failed (role_id: %d).", wlvif->role_id);
+	dev_info(wl->dev, "channel switch failed (role_id: %d)\n",
+		 wlvif->role_id);
 
 	mutex_lock(&wl->mutex);
 
@@ -2051,7 +2060,8 @@ static void wlcore_connection_loss_work(struct work_struct *work)
 	wlvif = container_of(dwork, struct wl12xx_vif, connection_loss_work);
 	wl = wlvif->wl;
 
-	wl1271_info("Connection loss work (role_id: %d).", wlvif->role_id);
+	dev_info(wl->dev, "Connection loss work (role_id: %d)\n",
+		 wlvif->role_id);
 
 	mutex_lock(&wl->mutex);
 
@@ -2170,7 +2180,7 @@ static u8 wl12xx_get_role_type(struct wl1271 *wl, struct wl12xx_vif *wlvif)
 		return WL1271_ROLE_IBSS;
 
 	default:
-		wl1271_error("invalid bss_type: %d", wlvif->bss_type);
+		dev_err(wl->dev, "invalid bss_type: %d\n", wlvif->bss_type);
 	}
 	return WL12XX_INVALID_ROLE_TYPE;
 }
@@ -2313,12 +2323,12 @@ power_off:
 	}
 
 	if (!booted) {
-		wl1271_error("firmware boot failed despite %d retries",
-			     WL1271_BOOT_RETRIES);
+		dev_err(wl->dev, "firmware boot failed despite %d retries\n",
+			WL1271_BOOT_RETRIES);
 		goto out;
 	}
 
-	wl1271_info("firmware booted (%s)", wl->chip.fw_ver_str);
+	dev_info(wl->dev, "firmware booted (%s)\n", wl->chip.fw_ver_str);
 
 	/* update hw/fw version info in wiphy struct */
 	wiphy->hw_version = wl->chip.id;
@@ -2488,7 +2498,7 @@ static int wl1271_op_add_interface(struct ieee80211_hw *hw,
 	u8 role_type;
 
 	if (wl->plt) {
-		wl1271_error("Adding Interface not allowed while in PLT mode");
+		dev_err(wl->dev, "Adding Interface not allowed while in PLT mode\n");
 		return -EBUSY;
 	}
 
@@ -2611,7 +2621,7 @@ static void __wl1271_op_remove_interface(struct wl1271 *wl,
 	if (wl->state == WLCORE_STATE_OFF)
 		return;
 
-	wl1271_info("down");
+	dev_info(wl->dev, "down\n");
 
 	if (wl->scan.state != WL1271_SCAN_STATE_IDLE &&
 	    wl->scan_wlvif == wlvif) {
@@ -2805,7 +2815,7 @@ static int wlcore_join(struct wl1271 *wl, struct wl12xx_vif *wlvif)
 	 * users who really like to roam a lot :)
 	 */
 	if (test_bit(WLVIF_FLAG_STA_ASSOCIATED, &wlvif->flags))
-		wl1271_info("JOIN while associated.");
+		dev_info(wl->dev, "JOIN while associated\n");
 
 	/* clear encryption type */
 	wlvif->encryption_type = KEY_NONE;
@@ -2831,21 +2841,21 @@ static int wlcore_join(struct wl1271 *wl, struct wl12xx_vif *wlvif)
 	return ret;
 }
 
-static int wl1271_ssid_set(struct wl12xx_vif *wlvif, struct sk_buff *skb,
-			    int offset)
+static int wl1271_ssid_set(struct wl1271 *wl, struct wl12xx_vif *wlvif,
+			   struct sk_buff *skb, int offset)
 {
 	u8 ssid_len;
 	const u8 *ptr = cfg80211_find_ie(WLAN_EID_SSID, skb->data + offset,
 					 skb->len - offset);
 
 	if (!ptr) {
-		wl1271_error("No SSID in IEs!");
+		dev_err(wl->dev, "No SSID in IEs!\n");
 		return -ENOENT;
 	}
 
 	ssid_len = ptr[1];
 	if (ssid_len > IEEE80211_MAX_SSID_LEN) {
-		wl1271_error("SSID is too long!");
+		dev_err(wl->dev, "SSID is too long!\n");
 		return -EINVAL;
 	}
 
@@ -2870,7 +2880,7 @@ static int wlcore_set_ssid(struct wl1271 *wl, struct wl12xx_vif *wlvif)
 
 	ieoffset = offsetof(struct ieee80211_mgmt,
 			    u.probe_req.variable);
-	wl1271_ssid_set(wlvif, skb, ieoffset);
+	wl1271_ssid_set(wl, wlvif, skb, ieoffset);
 	dev_kfree_skb(skb);
 
 	return 0;
@@ -2909,7 +2919,7 @@ static int wlcore_set_assoc(struct wl1271 *wl, struct wl12xx_vif *wlvif,
 							NULL);
 	ieoffset = offsetof(struct ieee80211_mgmt,
 			    u.probe_req.variable);
-	wl1271_ssid_set(wlvif, wlvif->probereq, ieoffset);
+	wl1271_ssid_set(wl, wlvif, wlvif->probereq, ieoffset);
 
 	/* enable the connection monitoring feature */
 	ret = wl1271_acx_conn_monit_params(wl, wlvif, true);
@@ -3068,7 +3078,7 @@ static int wl1271_op_config(struct ieee80211_hw *hw, u32 changed)
 	int ret = 0;
 
 	wl1271_debug(DEBUG_MAC80211, "mac80211 config psm %s power %d %s"
-		     " changed 0x%x",
+		     " changed 0x%x\n",
 		     conf->flags & IEEE80211_CONF_PS ? "on" : "off",
 		     conf->power_level,
 		     conf->flags & IEEE80211_CONF_IDLE ? "idle" : "in use",
@@ -3115,10 +3125,8 @@ static u64 wl1271_op_prepare_multicast(struct ieee80211_hw *hw,
 	struct netdev_hw_addr *ha;
 
 	fp = kzalloc(sizeof(*fp), GFP_ATOMIC);
-	if (!fp) {
-		wl1271_error("Out of memory setting filters.");
+	if (!fp)
 		return 0;
-	}
 
 	/* update multicast filtering parameters */
 	fp->mc_list_length = 0;
@@ -3153,7 +3161,8 @@ static void wl1271_op_configure_filter(struct ieee80211_hw *hw,
 	int ret;
 
 	wl1271_debug(DEBUG_MAC80211, "mac80211 configure filter changed %x"
-		     " total %x", changed, *total);
+		     "total %x\n",
+		     changed, *total);
 
 	mutex_lock(&wl->mutex);
 
@@ -3222,7 +3231,7 @@ static int wl1271_record_ap_key(struct wl1271 *wl, struct wl12xx_vif *wlvif,
 			break;
 
 		if (wlvif->ap.recorded_keys[i]->id == id) {
-			wl1271_warning("trying to record key replacement");
+			dev_warn(wl->dev, "trying to record key replacement\n");
 			return -EINVAL;
 		}
 	}
@@ -3472,7 +3481,7 @@ int wlcore_set_key(struct wl1271 *wl, enum set_key_cmd cmd,
 		key_type = KEY_GEM;
 		break;
 	default:
-		wl1271_error("Unknown key algo 0x%x", key_conf->cipher);
+		dev_err(wl->dev, "Unknown key algo 0x%x\n", key_conf->cipher);
 
 		return -EOPNOTSUPP;
 	}
@@ -3484,7 +3493,7 @@ int wlcore_set_key(struct wl1271 *wl, enum set_key_cmd cmd,
 				 key_conf->keylen, key_conf->key,
 				 tx_seq_32, tx_seq_16, sta);
 		if (ret < 0) {
-			wl1271_error("Could not add or replace key");
+			dev_err(wl->dev, "Could not add or replace key\n");
 			return ret;
 		}
 
@@ -3498,7 +3507,8 @@ int wlcore_set_key(struct wl1271 *wl, enum set_key_cmd cmd,
 			wlvif->encryption_type = key_type;
 			ret = wl1271_cmd_build_arp_rsp(wl, wlvif);
 			if (ret < 0) {
-				wl1271_warning("build arp rsp failed: %d", ret);
+				dev_warn(wl->dev, "build arp rsp failed: %d\n",
+					 ret);
 				return ret;
 			}
 		}
@@ -3510,13 +3520,13 @@ int wlcore_set_key(struct wl1271 *wl, enum set_key_cmd cmd,
 				     key_conf->keylen, key_conf->key,
 				     0, 0, sta);
 		if (ret < 0) {
-			wl1271_error("Could not remove key");
+			dev_err(wl->dev, "Could not remove key\n");
 			return ret;
 		}
 		break;
 
 	default:
-		wl1271_error("Unsupported key cmd 0x%x", cmd);
+		dev_err(wl->dev, "Unsupported key cmd 0x%x\n", cmd);
 		return -EOPNOTSUPP;
 	}
 
@@ -3771,7 +3781,8 @@ static int wl1271_op_set_frag_threshold(struct ieee80211_hw *hw, u32 value)
 
 	ret = wl1271_acx_frag_threshold(wl, value);
 	if (ret < 0)
-		wl1271_warning("wl1271_op_set_frag_threshold failed: %d", ret);
+		dev_warn(wl->dev, "wl1271_op_set_frag_threshold failed: %d\n",
+			 ret);
 
 	wl1271_ps_elp_sleep(wl);
 
@@ -3801,7 +3812,8 @@ static int wl1271_op_set_rts_threshold(struct ieee80211_hw *hw, u32 value)
 	wl12xx_for_each_wlvif(wl, wlvif) {
 		ret = wl1271_acx_rts_threshold(wl, wlvif, value);
 		if (ret < 0)
-			wl1271_warning("set rts threshold failed: %d", ret);
+			dev_warn(wl->dev, "set rts threshold failed: %d\n",
+				 ret);
 	}
 	wl1271_ps_elp_sleep(wl);
 
@@ -3891,7 +3903,7 @@ static int wl1271_ap_set_probe_resp_tmpl_legacy(struct wl1271 *wl,
 					       rates);
 
 	if (probe_rsp_len + bss_conf->ssid_len > WL1271_CMD_TEMPL_MAX_SIZE) {
-		wl1271_error("probe_rsp template too big");
+		dev_err(wl->dev, "probe_rsp template too big\n");
 		return -EINVAL;
 	}
 
@@ -3901,7 +3913,7 @@ static int wl1271_ap_set_probe_resp_tmpl_legacy(struct wl1271 *wl,
 	ptr = cfg80211_find_ie(WLAN_EID_SSID, probe_rsp_data + ie_offset,
 			       probe_rsp_len - ie_offset);
 	if (!ptr) {
-		wl1271_error("No SSID in beacon!");
+		dev_err(wl->dev, "No SSID in beacon!\n");
 		return -EINVAL;
 	}
 
@@ -3942,7 +3954,7 @@ static int wl1271_bss_erp_info_changed(struct wl1271 *wl,
 		else
 			ret = wl1271_acx_slot(wl, wlvif, SLOT_TIME_LONG);
 		if (ret < 0) {
-			wl1271_warning("Set slot time failed %d", ret);
+			dev_warn(wl->dev, "Set slot time failed %d\n", ret);
 			goto out;
 		}
 	}
@@ -3962,7 +3974,7 @@ static int wl1271_bss_erp_info_changed(struct wl1271 *wl,
 			ret = wl1271_acx_cts_protect(wl, wlvif,
 						     CTSPROTECT_DISABLE);
 		if (ret < 0) {
-			wl1271_warning("Set ctsprotect failed %d", ret);
+			dev_warn(wl->dev, "Set ctsprotect failed %d\n", ret);
 			goto out;
 		}
 	}
@@ -3990,7 +4002,7 @@ static int wlcore_set_beacon_template(struct wl1271 *wl,
 
 	wl1271_debug(DEBUG_MASTER, "beacon updated");
 
-	ret = wl1271_ssid_set(wlvif, beacon, ieoffset);
+	ret = wl1271_ssid_set(wl, wlvif, beacon, ieoffset);
 	if (ret < 0) {
 		dev_kfree_skb(beacon);
 		goto out;
@@ -4093,7 +4105,7 @@ static int wl1271_bss_beacon_info_changed(struct wl1271 *wl,
 	}
 out:
 	if (ret != 0)
-		wl1271_error("beacon info change failed: %d", ret);
+		dev_err(wl->dev, "beacon info change failed: %d\n", ret);
 	return ret;
 }
 
@@ -4116,7 +4128,8 @@ static void wl1271_bss_info_changed_ap(struct wl1271 *wl,
 
 		ret = wl1271_init_ap_rates(wl, wlvif);
 		if (ret < 0) {
-			wl1271_error("AP rate policy change failed %d", ret);
+			dev_err(wl->dev, "AP rate policy change failed %d\n",
+				ret);
 			goto out;
 		}
 
@@ -4182,7 +4195,8 @@ static void wl1271_bss_info_changed_ap(struct wl1271 *wl,
 		ret = wl1271_acx_set_ht_information(wl, wlvif,
 					bss_conf->ht_operation_mode);
 		if (ret < 0) {
-			wl1271_warning("Set ht information failed %d", ret);
+			dev_warn(wl->dev, "Set ht information failed %d\n",
+				 ret);
 			goto out;
 		}
 	}
@@ -4397,7 +4411,7 @@ static void wl1271_bss_info_changed_sta(struct wl1271 *wl,
 	if (do_join) {
 		ret = wlcore_join(wl, wlvif);
 		if (ret < 0) {
-			wl1271_warning("cmd join failed %d", ret);
+			dev_warn(wl->dev, "cmd join failed %d\n", ret);
 			goto out;
 		}
 	}
@@ -4435,8 +4449,8 @@ static void wl1271_bss_info_changed_sta(struct wl1271 *wl,
 
 			ret = wl1271_ps_set_mode(wl, wlvif, ps_mode);
 			if (ret < 0)
-				wl1271_warning("enter %s ps failed %d",
-					       ps_mode_str, ret);
+				dev_warn(wl->dev, "enter %s ps failed %d\n",
+					 ps_mode_str, ret);
 		} else if (!bss_conf->ps &&
 			   test_bit(WLVIF_FLAG_IN_PS, &wlvif->flags)) {
 			wl1271_debug(DEBUG_PSM, "auto ps disabled");
@@ -4444,7 +4458,8 @@ static void wl1271_bss_info_changed_sta(struct wl1271 *wl,
 			ret = wl1271_ps_set_mode(wl, wlvif,
 						 STATION_ACTIVE_MODE);
 			if (ret < 0)
-				wl1271_warning("exit auto ps failed %d", ret);
+				dev_warn(wl->dev, "exit auto ps failed %d\n",
+					 ret);
 		}
 	}
 
@@ -4459,7 +4474,7 @@ static void wl1271_bss_info_changed_sta(struct wl1271 *wl,
 					     wlvif->rate_set,
 					     wlvif->sta.hlid);
 		if (ret < 0) {
-			wl1271_warning("Set ht cap failed %d", ret);
+			dev_warn(wl->dev, "Set ht cap failed %d\n", ret);
 			goto out;
 
 		}
@@ -4468,8 +4483,8 @@ static void wl1271_bss_info_changed_sta(struct wl1271 *wl,
 			ret = wl1271_acx_set_ht_information(wl, wlvif,
 						bss_conf->ht_operation_mode);
 			if (ret < 0) {
-				wl1271_warning("Set ht information failed %d",
-					       ret);
+				dev_warn(wl->dev, "Set ht information failed %d\n",
+					 ret);
 				goto out;
 			}
 		}
@@ -4492,7 +4507,8 @@ static void wl1271_bss_info_changed_sta(struct wl1271 *wl,
 			 */
 			ret = wl1271_cmd_build_arp_rsp(wl, wlvif);
 			if (ret < 0) {
-				wl1271_warning("build arp rsp failed: %d", ret);
+				dev_warn(wl->dev, "build arp rsp failed: %d\n",
+					 ret);
 				goto out;
 			}
 
@@ -4899,14 +4915,14 @@ static int wl1271_allocate_sta(struct wl1271 *wl,
 
 
 	if (wl->active_sta_count >= wl->max_ap_stations) {
-		wl1271_warning("could not allocate HLID - too much stations");
+		dev_warn(wl->dev, "could not allocate HLID - too many stations\n");
 		return -EBUSY;
 	}
 
 	wl_sta = (struct wl1271_station *)sta->drv_priv;
 	ret = wl12xx_allocate_link(wl, wlvif, &wl_sta->hlid);
 	if (ret < 0) {
-		wl1271_warning("could not allocate HLID - too many links");
+		dev_warn(wl->dev, "could not allocate HLID - too many links\n");
 		return -EBUSY;
 	}
 
@@ -5242,14 +5258,14 @@ static int wl1271_op_ampdu_action(struct ieee80211_hw *hw,
 
 		if (wl->ba_rx_session_count >= wl->ba_rx_session_count_max) {
 			ret = -EBUSY;
-			wl1271_error("exceeded max RX BA sessions");
+			dev_err(wl->dev, "exceeded max RX BA sessions\n");
 			break;
 		}
 
 		if (*ba_bitmap & BIT(tid)) {
 			ret = -EINVAL;
-			wl1271_error("cannot enable RX BA session on active "
-				     "tid: %d", tid);
+			dev_err(wl->dev, "cannot enable RX BA session on active tid: %d\n",
+				tid);
 			break;
 		}
 
@@ -5295,7 +5311,7 @@ static int wl1271_op_ampdu_action(struct ieee80211_hw *hw,
 		break;
 
 	default:
-		wl1271_error("Incorrect ampdu action id=%x\n", action);
+		dev_err(wl->dev, "Incorrect ampdu action id=%x\n", action);
 		ret = -EINVAL;
 	}
 
@@ -5452,7 +5468,7 @@ static void wlcore_op_channel_switch_beacon(struct ieee80211_hw *hw,
 
 	ret = wlcore_get_csa_count(wl, wlvif, &ch_switch.count);
 	if (ret < 0) {
-		wl1271_error("error getting beacon (for CSA counter)");
+		dev_err(wl->dev, "error getting beacon (for CSA counter)\n");
 		return;
 	}
 
@@ -5878,13 +5894,13 @@ u8 wlcore_rate_to_idx(struct wl1271 *wl, u8 rate, enum ieee80211_band band)
 	BUG_ON(band >= 2);
 
 	if (unlikely(rate >= wl->hw_tx_rate_tbl_size)) {
-		wl1271_error("Illegal RX rate from HW: %d", rate);
+		dev_err(wl->dev, "Illegal RX rate from HW: %d\n", rate);
 		return 0;
 	}
 
 	idx = wl->band_rate_to_idx[band][rate];
 	if (unlikely(idx == CONF_HW_RXTX_RATE_UNSUPPORTED)) {
-		wl1271_error("Unsupported RX rate from HW: %d", rate);
+		dev_err(wl->dev, "Unsupported RX rate from HW: %d\n", rate);
 		return 0;
 	}
 
@@ -5899,7 +5915,7 @@ static void wl12xx_derive_mac_addresses(struct wl1271 *wl, u32 oui, u32 nic)
 		     oui, nic);
 
 	if (nic + WLCORE_NUM_MAC_ADDRESSES - wl->num_mac_addr > 0xffffff)
-		wl1271_warning("NIC part of the MAC address wraps around!");
+		dev_warn(wl->dev, "NIC part of the MAC address wraps around!\n");
 
 	for (i = 0; i < wl->num_mac_addr; i++) {
 		wl->addresses[i].addr[0] = (u8)(oui >> 16);
@@ -5984,7 +6000,7 @@ static int wl1271_register_hw(struct wl1271 *wl)
 
 	ret = ieee80211_register_hw(wl->hw);
 	if (ret < 0) {
-		wl1271_error("unable to register mac80211 hw: %d", ret);
+		dev_err(wl->dev, "unable to register mac80211 hw: %d\n", ret);
 		goto out;
 	}
 
@@ -5992,7 +6008,7 @@ static int wl1271_register_hw(struct wl1271 *wl)
 
 	wl1271_debugfs_init(wl);
 
-	wl1271_notice("loaded");
+	dev_notice(wl->dev, "loaded\n");
 
 out:
 	return ret;
@@ -6158,7 +6174,7 @@ struct ieee80211_hw *wlcore_alloc_hw(size_t priv_size, u32 aggr_buf_size,
 
 	hw = ieee80211_alloc_hw(sizeof(*wl), &wl1271_ops);
 	if (!hw) {
-		wl1271_error("could not alloc ieee80211_hw");
+		pr_err("could not alloc ieee80211_hw\n");
 		ret = -ENOMEM;
 		goto err_hw_alloc;
 	}
@@ -6168,7 +6184,7 @@ struct ieee80211_hw *wlcore_alloc_hw(size_t priv_size, u32 aggr_buf_size,
 
 	wl->priv = kzalloc(priv_size, GFP_KERNEL);
 	if (!wl->priv) {
-		wl1271_error("could not alloc wl priv");
+		dev_err(wl->dev, "could not alloc wl priv\n");
 		ret = -ENOMEM;
 		goto err_priv_alloc;
 	}
@@ -6361,7 +6377,7 @@ static void wlcore_nvs_cb(const struct firmware *fw, void *context)
 	if (fw) {
 		wl->nvs = kmemdup(fw->data, fw->size, GFP_KERNEL);
 		if (!wl->nvs) {
-			wl1271_error("Could not allocate nvs data");
+			dev_err(wl->dev, "Could not allocate nvs data\n");
 			goto out;
 		}
 		wl->nvs_len = fw->size;
@@ -6383,7 +6399,7 @@ static void wlcore_nvs_cb(const struct firmware *fw, void *context)
 
 	res = platform_get_resource(pdev, IORESOURCE_IRQ, 0);
 	if (!res) {
-		wl1271_error("Could not get IRQ resource");
+		dev_err(wl->dev, "Could not get IRQ resource\n");
 		goto out_free_nvs;
 	}
 
@@ -6402,7 +6418,7 @@ static void wlcore_nvs_cb(const struct firmware *fw, void *context)
 
 	ret = wl12xx_get_hw_info(wl);
 	if (ret < 0) {
-		wl1271_error("couldn't get hw info");
+		dev_err(wl->dev, "couldn't get hw info\n");
 		wl1271_power_off(wl);
 		goto out_free_nvs;
 	}
@@ -6410,7 +6426,7 @@ static void wlcore_nvs_cb(const struct firmware *fw, void *context)
 	ret = request_threaded_irq(wl->irq, hardirq_fn, wlcore_irq,
 				   wl->irq_flags, pdev->name, wl);
 	if (ret < 0) {
-		wl1271_error("interrupt configuration failed");
+		dev_err(wl->dev, "interrupt configuration failed\n");
 		wl1271_power_off(wl);
 		goto out_free_nvs;
 	}
@@ -6475,7 +6491,7 @@ int wlcore_probe(struct wl1271 *wl, struct platform_device *pdev)
 				      WL12XX_NVS_NAME, &pdev->dev, GFP_KERNEL,
 				      wl, wlcore_nvs_cb);
 	if (ret < 0) {
-		wl1271_error("request_firmware_nowait failed: %d", ret);
+		dev_err(wl->dev, "request_firmware_nowait failed: %d\n", ret);
 		complete_all(&wl->nvs_loading_complete);
 	}
 
diff --git a/drivers/net/wireless/ti/wlcore/ps.c b/drivers/net/wireless/ti/wlcore/ps.c
index 4cd316e..bfd5a8f 100644
--- a/drivers/net/wireless/ti/wlcore/ps.c
+++ b/drivers/net/wireless/ti/wlcore/ps.c
@@ -148,7 +148,7 @@ int wl1271_ps_elp_wakeup(struct wl1271 *wl)
 		ret = wait_for_completion_timeout(
 			&compl, msecs_to_jiffies(WL1271_WAKEUP_TIMEOUT));
 		if (ret == 0) {
-			wl1271_error("ELP wakeup timeout!");
+			dev_err(wl->dev, "ELP wakeup timeout!\n");
 			wl12xx_queue_recovery_work(wl);
 			ret = -ETIMEDOUT;
 			goto err;
@@ -188,7 +188,7 @@ int wl1271_ps_set_mode(struct wl1271 *wl, struct wl12xx_vif *wlvif,
 					    wl->conf.conn.wake_up_event,
 					    wl->conf.conn.listen_interval);
 		if (ret < 0) {
-			wl1271_error("couldn't set wake up conditions");
+			dev_err(wl->dev, "couldn't set wake up conditions\n");
 			return ret;
 		}
 
@@ -227,7 +227,8 @@ int wl1271_ps_set_mode(struct wl1271 *wl, struct wl12xx_vif *wlvif,
 		clear_bit(WLVIF_FLAG_IN_PS, &wlvif->flags);
 		break;
 	default:
-		wl1271_warning("trying to set ps to unsupported mode %d", mode);
+		dev_warn(wl->dev, "trying to set ps to unsupported mode %d\n",
+			 mode);
 		ret = -EINVAL;
 	}
 
@@ -290,8 +291,8 @@ void wl12xx_ps_link_start(struct wl1271 *wl, struct wl12xx_vif *wlvif,
 	rcu_read_lock();
 	sta = ieee80211_find_sta(vif, wl->links[hlid].addr);
 	if (!sta) {
-		wl1271_error("could not find sta %pM for starting ps",
-			     wl->links[hlid].addr);
+		dev_err(wl->dev, "could not find sta %pM for starting ps\n",
+			wl->links[hlid].addr);
 		rcu_read_unlock();
 		return;
 	}
@@ -321,8 +322,8 @@ void wl12xx_ps_link_end(struct wl1271 *wl, struct wl12xx_vif *wlvif, u8 hlid)
 	rcu_read_lock();
 	sta = ieee80211_find_sta(vif, wl->links[hlid].addr);
 	if (!sta) {
-		wl1271_error("could not find sta %pM for ending ps",
-			     wl->links[hlid].addr);
+		dev_err(wl->dev, "could not find sta %pM for ending ps\n",
+			wl->links[hlid].addr);
 		goto end;
 	}
 
diff --git a/drivers/net/wireless/ti/wlcore/rx.c b/drivers/net/wireless/ti/wlcore/rx.c
index 34e7e93..e5c25254 100644
--- a/drivers/net/wireless/ti/wlcore/rx.c
+++ b/drivers/net/wireless/ti/wlcore/rx.c
@@ -101,8 +101,8 @@ static void wl1271_rx_status(struct wl1271 *wl,
 
 		if (unlikely(desc_err_code & WL1271_RX_DESC_MIC_FAIL)) {
 			status->flag |= RX_FLAG_MMIC_ERROR;
-			wl1271_warning("Michael MIC error. Desc: 0x%x",
-				       desc_err_code);
+			dev_warn(wl->dev, "Michael MIC error. Desc: 0x%x\n",
+				 desc_err_code);
 		}
 	}
 
@@ -133,8 +133,8 @@ static int wl1271_rx_handle_data(struct wl1271 *wl, u8 *data, u32 length,
 
 	pkt_data_len = wlcore_hw_get_rx_packet_len(wl, data, length);
 	if (!pkt_data_len) {
-		wl1271_error("Invalid packet arrived from HW. length %d",
-			     length);
+		dev_err(wl->dev, "Invalid packet arrived from HW. length %d\n",
+			length);
 		return -EINVAL;
 	}
 
@@ -155,9 +155,9 @@ static int wl1271_rx_handle_data(struct wl1271 *wl, u8 *data, u32 length,
 	/* discard corrupted packets */
 	if (desc->status & WL1271_RX_DESC_DECRYPT_FAIL) {
 		hdr = (void *)(data + sizeof(*desc) + offset_to_data);
-		wl1271_warning("corrupted packet in RX: status: 0x%x len: %d",
-			       desc->status & WL1271_RX_DESC_STATUS_MASK,
-			       pkt_data_len);
+		dev_warn(wl->dev, "corrupted packet in RX: status: 0x%x len: %d\n",
+			 desc->status & WL1271_RX_DESC_STATUS_MASK,
+			 pkt_data_len);
 		wl1271_dump((DEBUG_RX|DEBUG_CMD), "PKT: ", data + sizeof(*desc),
 			    min(pkt_data_len,
 				ieee80211_hdrlen(hdr->frame_control)));
@@ -167,7 +167,7 @@ static int wl1271_rx_handle_data(struct wl1271 *wl, u8 *data, u32 length,
 	/* skb length not including rx descriptor */
 	skb = __dev_alloc_skb(pkt_data_len + reserved, GFP_KERNEL);
 	if (!skb) {
-		wl1271_error("Couldn't allocate RX frame");
+		dev_err(wl->dev, "Couldn't allocate RX frame\n");
 		return -ENOMEM;
 	}
 
@@ -238,7 +238,7 @@ int wlcore_rx(struct wl1271 *wl, struct wl_fw_status *status)
 		}
 
 		if (buf_size == 0) {
-			wl1271_warning("received empty data");
+			dev_warn(wl->dev, "received empty data\n");
 			break;
 		}
 
@@ -309,16 +309,16 @@ int wl1271_rx_filter_enable(struct wl1271 *wl,
 	int ret;
 
 	if (!!test_bit(index, wl->rx_filter_enabled) == enable) {
-		wl1271_warning("Request to enable an already "
-			     "enabled rx filter %d", index);
+		dev_warn(wl->dev, "Request to enable an already enabled rx filter %d\n",
+			 index);
 		return 0;
 	}
 
 	ret = wl1271_acx_set_rx_filter(wl, index, enable, filter);
 
 	if (ret) {
-		wl1271_error("Failed to %s rx data filter %d (err=%d)",
-			     enable ? "enable" : "disable", index, ret);
+		dev_err(wl->dev, "Failed to %s rx data filter %d (err=%d)\n",
+			enable ? "enable" : "disable", index, ret);
 		return ret;
 	}
 
diff --git a/drivers/net/wireless/ti/wlcore/scan.c b/drivers/net/wireless/ti/wlcore/scan.c
index 1e3d51c..2f50cf3 100644
--- a/drivers/net/wireless/ti/wlcore/scan.c
+++ b/drivers/net/wireless/ti/wlcore/scan.c
@@ -76,7 +76,7 @@ void wl1271_scan_complete_work(struct work_struct *work)
 	wl1271_ps_elp_sleep(wl);
 
 	if (wl->scan.failed) {
-		wl1271_info("Scan completed due to error.");
+		dev_info(wl->dev, "Scan completed due to error\n");
 		wl12xx_queue_recovery_work(wl);
 	}
 
@@ -466,7 +466,7 @@ wlcore_scan_sched_scan_ssid_list(struct wl1271 *wl,
 	ret = wl1271_cmd_send(wl, CMD_CONNECTION_SCAN_SSID_CFG, cmd,
 			      sizeof(*cmd), 0);
 	if (ret < 0) {
-		wl1271_error("cmd sched scan ssid list failed");
+		dev_err(wl->dev, "cmd sched scan ssid list failed\n");
 		goto out_free;
 	}
 
diff --git a/drivers/net/wireless/ti/wlcore/sysfs.c b/drivers/net/wireless/ti/wlcore/sysfs.c
index a9218e5..1487398 100644
--- a/drivers/net/wireless/ti/wlcore/sysfs.c
+++ b/drivers/net/wireless/ti/wlcore/sysfs.c
@@ -52,7 +52,7 @@ static ssize_t wl1271_sysfs_store_bt_coex_state(struct device *dev,
 
 	ret = kstrtoul(buf, 10, &res);
 	if (ret < 0) {
-		wl1271_warning("incorrect value written to bt_coex_mode");
+		dev_warn(wl->dev, "incorrect value written to bt_coex_mode\n");
 		return count;
 	}
 
@@ -150,21 +150,21 @@ int wlcore_sysfs_init(struct wl1271 *wl)
 	/* Create sysfs file to control bt coex state */
 	ret = device_create_file(wl->dev, &dev_attr_bt_coex_state);
 	if (ret < 0) {
-		wl1271_error("failed to create sysfs file bt_coex_state");
+		dev_err(wl->dev, "failed to create sysfs file bt_coex_state\n");
 		goto out;
 	}
 
 	/* Create sysfs file to get HW PG version */
 	ret = device_create_file(wl->dev, &dev_attr_hw_pg_ver);
 	if (ret < 0) {
-		wl1271_error("failed to create sysfs file hw_pg_ver");
+		dev_err(wl->dev, "failed to create sysfs file hw_pg_ver\n");
 		goto out_bt_coex_state;
 	}
 
 	/* Create sysfs file for the FW log */
 	ret = device_create_bin_file(wl->dev, &fwlog_attr);
 	if (ret < 0) {
-		wl1271_error("failed to create sysfs file fwlog");
+		dev_err(wl->dev, "failed to create sysfs file fwlog\n");
 		goto out_hw_pg_ver;
 	}
 
diff --git a/drivers/net/wireless/ti/wlcore/testmode.c b/drivers/net/wireless/ti/wlcore/testmode.c
index ddad58f..6165c29 100644
--- a/drivers/net/wireless/ti/wlcore/testmode.c
+++ b/drivers/net/wireless/ti/wlcore/testmode.c
@@ -103,7 +103,7 @@ static int wl1271_tm_cmd_test(struct wl1271 *wl, struct nlattr *tb[])
 
 	ret = wl1271_cmd_test(wl, buf, buf_len, answer);
 	if (ret < 0) {
-		wl1271_warning("testmode cmd test failed: %d", ret);
+		dev_warn(wl->dev, "testmode cmd test failed: %d\n", ret);
 		goto out_sleep;
 	}
 
@@ -116,11 +116,11 @@ static int wl1271_tm_cmd_test(struct wl1271 *wl, struct nlattr *tb[])
 
 		if (params->test.id == TEST_CMD_P2G_CAL &&
 		    radio_status < 0)
-			wl1271_warning("testmode cmd: radio status=%d",
-					radio_status);
+			dev_warn(wl->dev, "testmode cmd: radio status=%d\n",
+				 radio_status);
 		else
-			wl1271_info("testmode cmd: radio status=%d",
-					radio_status);
+			dev_info(wl->dev, "testmode cmd: radio status=%d\n",
+				 radio_status);
 
 		len = nla_total_size(buf_len);
 		skb = cfg80211_testmode_alloc_reply_skb(wl->hw->wiphy, len);
@@ -182,7 +182,7 @@ static int wl1271_tm_cmd_interrogate(struct wl1271 *wl, struct nlattr *tb[])
 	ret = wl1271_cmd_interrogate(wl, ie_id, cmd,
 				     sizeof(struct acx_header), sizeof(*cmd));
 	if (ret < 0) {
-		wl1271_warning("testmode cmd interrogate failed: %d", ret);
+		dev_warn(wl->dev, "testmode cmd interrogate failed: %d\n", ret);
 		goto out_free;
 	}
 
@@ -237,7 +237,7 @@ static int wl1271_tm_cmd_configure(struct wl1271 *wl, struct nlattr *tb[])
 	mutex_unlock(&wl->mutex);
 
 	if (ret < 0) {
-		wl1271_warning("testmode cmd configure failed: %d", ret);
+		dev_warn(wl->dev, "testmode cmd configure failed: %d\n", ret);
 		return ret;
 	}
 
diff --git a/drivers/net/wireless/ti/wlcore/tx.c b/drivers/net/wireless/ti/wlcore/tx.c
index f0ac361..5442e32 100644
--- a/drivers/net/wireless/ti/wlcore/tx.c
+++ b/drivers/net/wireless/ti/wlcore/tx.c
@@ -384,12 +384,12 @@ static int wl1271_prepare_tx_frame(struct wl1271 *wl, struct wl12xx_vif *wlvif,
 	bool is_gem = false;
 
 	if (!skb) {
-		wl1271_error("discarding null skb");
+		dev_err(wl->dev, "discarding null skb\n");
 		return -EINVAL;
 	}
 
 	if (hlid == WL12XX_INVALID_LINK_ID) {
-		wl1271_error("invalid hlid. dropping skb 0x%p", skb);
+		dev_err(wl->dev, "invalid hlid - dropping skb 0x%p\n", skb);
 		return -EINVAL;
 	}
 
@@ -921,7 +921,7 @@ static void wl1271_tx_complete_packet(struct wl1271 *wl,
 
 	/* check for id legality */
 	if (unlikely(id >= wl->num_tx_desc || wl->tx_frames[id] == NULL)) {
-		wl1271_warning("TX result illegal id: %d", id);
+		dev_warn(wl->dev, "TX result illegal id: %d\n", id);
 		return;
 	}
 
@@ -1009,7 +1009,8 @@ int wlcore_tx_complete(struct wl1271 *wl)
 
 	/* verify that the result buffer is not getting overrun */
 	if (unlikely(count > TX_HW_RESULT_QUEUE_LEN))
-		wl1271_warning("TX result overflow from chipset: %d", count);
+		dev_warn(wl->dev, "TX result overflow from chipset: %d\n",
+			 count);
 
 	/* process the results */
 	for (i = 0; i < count; i++) {
@@ -1182,9 +1183,8 @@ void wl1271_tx_flush(struct wl1271 *wl)
 		}
 	}
 
-	wl1271_warning("Unable to flush all TX buffers, "
-		       "timed out (timeout %d ms",
-		       WL1271_TX_FLUSH_TIMEOUT / 1000);
+	dev_warn(wl->dev, "Unable to flush all TX buffers, timed out (timeout %d ms\n",
+		 WL1271_TX_FLUSH_TIMEOUT / 1000);
 
 	/* forcibly flush all Tx buffers on our queues */
 	for (i = 0; i < wl->num_links; i++)
diff --git a/drivers/net/wireless/ti/wlcore/wlcore_i.h b/drivers/net/wireless/ti/wlcore/wlcore_i.h
index 27c5687..bd63cac 100644
--- a/drivers/net/wireless/ti/wlcore/wlcore_i.h
+++ b/drivers/net/wireless/ti/wlcore/wlcore_i.h
@@ -529,9 +529,6 @@ int wl1271_plt_stop(struct wl1271 *wl);
 int wl1271_recalc_rx_streaming(struct wl1271 *wl, struct wl12xx_vif *wlvif);
 void wl12xx_queue_recovery_work(struct wl1271 *wl);
 size_t wl12xx_copy_fwlog(struct wl1271 *wl, u8 *memblock, size_t maxlen);
-int wl1271_rx_filter_alloc_field(struct wl12xx_rx_filter *filter,
-				 u16 offset, u8 flags,
-				 const u8 *pattern, u8 len);
 void wl1271_rx_filter_free(struct wl12xx_rx_filter *filter);
 struct wl12xx_rx_filter *wl1271_rx_filter_alloc(void);
 int wl1271_rx_filter_get_fields_size(struct wl12xx_rx_filter *filter);
-- 
2.6.3.368.gf34be46
