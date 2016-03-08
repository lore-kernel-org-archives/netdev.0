From: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH 3/5] ti: wl1251: Convert wl1251_warning to wiphy_warn
Date: Mon,  7 Mar 2016 16:19:35 -0800
Message-ID: <fd990dbaa1d88bcef0956d843fbf0bb792d3b071.1457395071.git.joe@perches.com>
References: <cover.1457395071.git.joe@perches.com>
Cc: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <cover.1457395071.git.joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Use the more common logging mechanism.

Miscellanea:

o Coalesce formats
o Realign arguments
o Reflow to fit 80 columns

Signed-off-by: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
---
 drivers/net/wireless/ti/wl1251/acx.c    | 91 ++++++++++++++++++++-------------
 drivers/net/wireless/ti/wl1251/cmd.c    | 10 ++--
 drivers/net/wireless/ti/wl1251/init.c   |  4 +-
 drivers/net/wireless/ti/wl1251/main.c   | 26 ++++++----
 drivers/net/wireless/ti/wl1251/rx.c     |  4 +-
 drivers/net/wireless/ti/wl1251/tx.c     |  4 +-
 drivers/net/wireless/ti/wl1251/wl1251.h |  3 --
 7 files changed, 82 insertions(+), 60 deletions(-)

diff --git a/drivers/net/wireless/ti/wl1251/acx.c b/drivers/net/wireless/ti/wl1251/acx.c
index 23b4882..22d3daa 100644
--- a/drivers/net/wireless/ti/wl1251/acx.c
+++ b/drivers/net/wireless/ti/wl1251/acx.c
@@ -103,7 +103,8 @@ int wl1251_acx_wake_up_conditions(struct wl1251 *wl, u8 wake_up_event,
 	ret = wl1251_cmd_configure(wl, ACX_WAKE_UP_CONDITIONS,
 				   wake_up, sizeof(*wake_up));
 	if (ret < 0) {
-		wl1251_warning("could not set wake up conditions: %d", ret);
+		wiphy_warn(wl->hw->wiphy, "could not set wake up conditions: %d\n",
+			   ret);
 		goto out;
 	}
 
@@ -144,7 +145,7 @@ int wl1251_acx_fw_version(struct wl1251 *wl, char *buf, size_t len)
 
 	ret = wl1251_cmd_interrogate(wl, ACX_FW_REV, rev, sizeof(*rev));
 	if (ret < 0) {
-		wl1251_warning("ACX_FW_REV interrogate failed");
+		wiphy_warn(wl->hw->wiphy, "ACX_FW_REV interrogate failed\n");
 		goto out;
 	}
 
@@ -181,7 +182,8 @@ int wl1251_acx_tx_power(struct wl1251 *wl, int power)
 
 	ret = wl1251_cmd_configure(wl, DOT11_CUR_TX_PWR, acx, sizeof(*acx));
 	if (ret < 0) {
-		wl1251_warning("configure of tx power failed: %d", ret);
+		wiphy_warn(wl->hw->wiphy, "configure of tx power failed: %d\n",
+			   ret);
 		goto out;
 	}
 
@@ -265,10 +267,11 @@ int wl1251_acx_data_path_params(struct wl1251 *wl,
 				     resp, sizeof(*resp));
 
 	if (ret < 0) {
-		wl1251_warning("failed to read data path parameters: %d", ret);
+		wiphy_warn(wl->hw->wiphy, "failed to read data path parameters: %d\n",
+			   ret);
 		goto out;
 	} else if (resp->header.cmd.status != CMD_STATUS_SUCCESS) {
-		wl1251_warning("data path parameter acx status failed");
+		wiphy_warn(wl->hw->wiphy, "data path parameter acx status failed\n");
 		ret = -EIO;
 		goto out;
 	}
@@ -293,7 +296,8 @@ int wl1251_acx_rx_msdu_life_time(struct wl1251 *wl, u32 life_time)
 	ret = wl1251_cmd_configure(wl, DOT11_RX_MSDU_LIFE_TIME,
 				   acx, sizeof(*acx));
 	if (ret < 0) {
-		wl1251_warning("failed to set rx msdu life time: %d", ret);
+		wiphy_warn(wl->hw->wiphy, "failed to set rx msdu life time: %d\n",
+			   ret);
 		goto out;
 	}
 
@@ -319,7 +323,7 @@ int wl1251_acx_rx_config(struct wl1251 *wl, u32 config, u32 filter)
 	ret = wl1251_cmd_configure(wl, ACX_RX_CFG,
 				   rx_config, sizeof(*rx_config));
 	if (ret < 0) {
-		wl1251_warning("failed to set rx config: %d", ret);
+		wiphy_warn(wl->hw->wiphy, "failed to set rx config: %d\n", ret);
 		goto out;
 	}
 
@@ -343,7 +347,8 @@ int wl1251_acx_pd_threshold(struct wl1251 *wl)
 
 	ret = wl1251_cmd_configure(wl, ACX_PD_THRESHOLD, pd, sizeof(*pd));
 	if (ret < 0) {
-		wl1251_warning("failed to set pd threshold: %d", ret);
+		wiphy_warn(wl->hw->wiphy, "failed to set pd threshold: %d\n",
+			   ret);
 		goto out;
 	}
 
@@ -368,7 +373,8 @@ int wl1251_acx_slot(struct wl1251 *wl, enum acx_slot_type slot_time)
 
 	ret = wl1251_cmd_configure(wl, ACX_SLOT, slot, sizeof(*slot));
 	if (ret < 0) {
-		wl1251_warning("failed to set slot time: %d", ret);
+		wiphy_warn(wl->hw->wiphy, "failed to set slot time: %d\n",
+			   ret);
 		goto out;
 	}
 
@@ -397,7 +403,8 @@ int wl1251_acx_group_address_tbl(struct wl1251 *wl, bool enable,
 	ret = wl1251_cmd_configure(wl, DOT11_GROUP_ADDRESS_TBL,
 				   acx, sizeof(*acx));
 	if (ret < 0) {
-		wl1251_warning("failed to set group addr table: %d", ret);
+		wiphy_warn(wl->hw->wiphy, "failed to set group addr table: %d\n",
+			   ret);
 		goto out;
 	}
 
@@ -423,8 +430,8 @@ int wl1251_acx_service_period_timeout(struct wl1251 *wl)
 	ret = wl1251_cmd_configure(wl, ACX_SERVICE_PERIOD_TIMEOUT,
 				   rx_timeout, sizeof(*rx_timeout));
 	if (ret < 0) {
-		wl1251_warning("failed to set service period timeout: %d",
-			       ret);
+		wiphy_warn(wl->hw->wiphy, "failed to set service period timeout: %d\n",
+			   ret);
 		goto out;
 	}
 
@@ -448,7 +455,8 @@ int wl1251_acx_rts_threshold(struct wl1251 *wl, u16 rts_threshold)
 
 	ret = wl1251_cmd_configure(wl, DOT11_RTS_THRESHOLD, rts, sizeof(*rts));
 	if (ret < 0) {
-		wl1251_warning("failed to set rts threshold: %d", ret);
+		wiphy_warn(wl->hw->wiphy, "failed to set rts threshold: %d\n",
+			   ret);
 		goto out;
 	}
 
@@ -474,7 +482,8 @@ int wl1251_acx_beacon_filter_opt(struct wl1251 *wl, bool enable_filter)
 	ret = wl1251_cmd_configure(wl, ACX_BEACON_FILTER_OPT,
 				   beacon_filter, sizeof(*beacon_filter));
 	if (ret < 0) {
-		wl1251_warning("failed to set beacon filter opt: %d", ret);
+		wiphy_warn(wl->hw->wiphy, "failed to set beacon filter opt: %d\n",
+			   ret);
 		goto out;
 	}
 
@@ -503,7 +512,8 @@ int wl1251_acx_beacon_filter_table(struct wl1251 *wl)
 	ret = wl1251_cmd_configure(wl, ACX_BEACON_FILTER_TABLE,
 				   ie_table, sizeof(*ie_table));
 	if (ret < 0) {
-		wl1251_warning("failed to set beacon filter table: %d", ret);
+		wiphy_warn(wl->hw->wiphy, "failed to set beacon filter table: %d\n",
+			   ret);
 		goto out;
 	}
 
@@ -529,8 +539,8 @@ int wl1251_acx_conn_monit_params(struct wl1251 *wl)
 	ret = wl1251_cmd_configure(wl, ACX_CONN_MONIT_PARAMS,
 				   acx, sizeof(*acx));
 	if (ret < 0) {
-		wl1251_warning("failed to set connection monitor "
-			       "parameters: %d", ret);
+		wiphy_warn(wl->hw->wiphy, "failed to set connection monitor parameters: %d\n",
+			   ret);
 		goto out;
 	}
 
@@ -554,7 +564,8 @@ int wl1251_acx_sg_enable(struct wl1251 *wl)
 
 	ret = wl1251_cmd_configure(wl, ACX_SG_ENABLE, pta, sizeof(*pta));
 	if (ret < 0) {
-		wl1251_warning("failed to set softgemini enable: %d", ret);
+		wiphy_warn(wl->hw->wiphy, "failed to set softgemini enable: %d\n",
+			   ret);
 		goto out;
 	}
 
@@ -606,7 +617,7 @@ int wl1251_acx_sg_cfg(struct wl1251 *wl)
 
 	ret = wl1251_cmd_configure(wl, ACX_SG_CFG, param, sizeof(*param));
 	if (ret < 0) {
-		wl1251_warning("failed to set sg config: %d", ret);
+		wiphy_warn(wl->hw->wiphy, "failed to set sg config: %d\n", ret);
 		goto out;
 	}
 
@@ -632,7 +643,8 @@ int wl1251_acx_cca_threshold(struct wl1251 *wl)
 	ret = wl1251_cmd_configure(wl, ACX_CCA_THRESHOLD,
 				   detection, sizeof(*detection));
 	if (ret < 0)
-		wl1251_warning("failed to set cca threshold: %d", ret);
+		wiphy_warn(wl->hw->wiphy, "failed to set cca threshold: %d\n",
+			   ret);
 
 	kfree(detection);
 	return ret;
@@ -656,7 +668,7 @@ int wl1251_acx_bcn_dtim_options(struct wl1251 *wl)
 
 	ret = wl1251_cmd_configure(wl, ACX_BCN_DTIM_OPTIONS, bb, sizeof(*bb));
 	if (ret < 0) {
-		wl1251_warning("failed to set rx config: %d", ret);
+		wiphy_warn(wl->hw->wiphy, "failed to set rx config: %d\n", ret);
 		goto out;
 	}
 
@@ -680,7 +692,7 @@ int wl1251_acx_aid(struct wl1251 *wl, u16 aid)
 
 	ret = wl1251_cmd_configure(wl, ACX_AID, acx_aid, sizeof(*acx_aid));
 	if (ret < 0) {
-		wl1251_warning("failed to set aid: %d", ret);
+		wiphy_warn(wl->hw->wiphy, "failed to set aid: %d\n", ret);
 		goto out;
 	}
 
@@ -708,7 +720,8 @@ int wl1251_acx_event_mbox_mask(struct wl1251 *wl, u32 event_mask)
 	ret = wl1251_cmd_configure(wl, ACX_EVENT_MBOX_MASK,
 				   mask, sizeof(*mask));
 	if (ret < 0) {
-		wl1251_warning("failed to set acx_event_mbox_mask: %d", ret);
+		wiphy_warn(wl->hw->wiphy, "failed to set acx_event_mbox_mask: %d\n",
+			   ret);
 		goto out;
 	}
 
@@ -736,7 +749,8 @@ int wl1251_acx_low_rssi(struct wl1251 *wl, s8 threshold, u8 weight,
 
 	ret = wl1251_cmd_configure(wl, ACX_LOW_RSSI, rssi, sizeof(*rssi));
 	if (ret < 0)
-		wl1251_warning("failed to set low rssi threshold: %d", ret);
+		wiphy_warn(wl->hw->wiphy, "failed to set low rssi threshold: %d\n",
+			   ret);
 
 	kfree(rssi);
 	return ret;
@@ -757,7 +771,8 @@ int wl1251_acx_set_preamble(struct wl1251 *wl, enum acx_preamble_type preamble)
 
 	ret = wl1251_cmd_configure(wl, ACX_PREAMBLE_TYPE, acx, sizeof(*acx));
 	if (ret < 0) {
-		wl1251_warning("Setting of preamble failed: %d", ret);
+		wiphy_warn(wl->hw->wiphy, "Setting of preamble failed: %d\n",
+			   ret);
 		goto out;
 	}
 
@@ -782,7 +797,8 @@ int wl1251_acx_cts_protect(struct wl1251 *wl,
 
 	ret = wl1251_cmd_configure(wl, ACX_CTS_PROTECTION, acx, sizeof(*acx));
 	if (ret < 0) {
-		wl1251_warning("Setting of ctsprotect failed: %d", ret);
+		wiphy_warn(wl->hw->wiphy, "Setting of ctsprotect failed: %d\n",
+			   ret);
 		goto out;
 	}
 
@@ -803,7 +819,7 @@ int wl1251_acx_tsf_info(struct wl1251 *wl, u64 *mactime)
 	ret = wl1251_cmd_interrogate(wl, ACX_TSF_INFO,
 				     tsf_info, sizeof(*tsf_info));
 	if (ret < 0) {
-		wl1251_warning("ACX_FW_REV interrogate failed");
+		wiphy_warn(wl->hw->wiphy, "ACX_FW_REV interrogate failed\n");
 		goto out;
 	}
 
@@ -824,7 +840,7 @@ int wl1251_acx_statistics(struct wl1251 *wl, struct acx_statistics *stats)
 	ret = wl1251_cmd_interrogate(wl, ACX_STATISTICS, stats,
 				     sizeof(*stats));
 	if (ret < 0) {
-		wl1251_warning("acx statistics failed: %d", ret);
+		wiphy_warn(wl->hw->wiphy, "acx statistics failed: %d\n", ret);
 		return -ENOMEM;
 	}
 
@@ -857,7 +873,8 @@ int wl1251_acx_rate_policies(struct wl1251 *wl)
 
 	ret = wl1251_cmd_configure(wl, ACX_RATE_POLICY, acx, sizeof(*acx));
 	if (ret < 0) {
-		wl1251_warning("Setting of rate policies failed: %d", ret);
+		wiphy_warn(wl->hw->wiphy, "Setting of rate policies failed: %d\n",
+			   ret);
 		goto out;
 	}
 
@@ -902,7 +919,8 @@ int wl1251_acx_mem_cfg(struct wl1251 *wl)
 	ret = wl1251_cmd_configure(wl, ACX_MEM_CFG, mem_conf,
 				   sizeof(*mem_conf));
 	if (ret < 0) {
-		wl1251_warning("wl1251 mem config failed: %d", ret);
+		wiphy_warn(wl->hw->wiphy, "wl1251 mem config failed: %d\n",
+			   ret);
 		goto out;
 	}
 
@@ -928,7 +946,8 @@ int wl1251_acx_wr_tbtt_and_dtim(struct wl1251 *wl, u16 tbtt, u8 dtim)
 	ret = wl1251_cmd_configure(wl, ACX_WR_TBTT_AND_DTIM,
 				   acx, sizeof(*acx));
 	if (ret < 0) {
-		wl1251_warning("failed to set tbtt and dtim: %d", ret);
+		wiphy_warn(wl->hw->wiphy, "failed to set tbtt and dtim: %d\n",
+			   ret);
 		goto out;
 	}
 
@@ -954,7 +973,8 @@ int wl1251_acx_bet_enable(struct wl1251 *wl, enum wl1251_acx_bet_mode mode,
 
 	ret = wl1251_cmd_configure(wl, ACX_BET_ENABLE, acx, sizeof(*acx));
 	if (ret < 0) {
-		wl1251_warning("wl1251 acx bet enable failed: %d", ret);
+		wiphy_warn(wl->hw->wiphy, "wl1251 acx bet enable failed: %d\n",
+			   ret);
 		goto out;
 	}
 
@@ -983,7 +1003,8 @@ int wl1251_acx_arp_ip_filter(struct wl1251 *wl, bool enable, __be32 address)
 	ret = wl1251_cmd_configure(wl, ACX_ARP_IP_FILTER,
 				   acx, sizeof(*acx));
 	if (ret < 0)
-		wl1251_warning("failed to set arp ip filter: %d", ret);
+		wiphy_warn(wl->hw->wiphy, "failed to set arp ip filter: %d\n",
+			   ret);
 
 	kfree(acx);
 	return ret;
@@ -1010,7 +1031,7 @@ int wl1251_acx_ac_cfg(struct wl1251 *wl, u8 ac, u8 cw_min, u16 cw_max,
 
 	ret = wl1251_cmd_configure(wl, ACX_AC_CFG, acx, sizeof(*acx));
 	if (ret < 0) {
-		wl1251_warning("acx ac cfg failed: %d", ret);
+		wiphy_warn(wl->hw->wiphy, "acx ac cfg failed: %d\n", ret);
 		goto out;
 	}
 
@@ -1043,7 +1064,7 @@ int wl1251_acx_tid_cfg(struct wl1251 *wl, u8 queue,
 
 	ret = wl1251_cmd_configure(wl, ACX_TID_CFG, acx, sizeof(*acx));
 	if (ret < 0) {
-		wl1251_warning("acx tid cfg failed: %d", ret);
+		wiphy_warn(wl->hw->wiphy, "acx tid cfg failed: %d\n", ret);
 		goto out;
 	}
 
diff --git a/drivers/net/wireless/ti/wl1251/cmd.c b/drivers/net/wireless/ti/wl1251/cmd.c
index a2a306e..f956c63 100644
--- a/drivers/net/wireless/ti/wl1251/cmd.c
+++ b/drivers/net/wireless/ti/wl1251/cmd.c
@@ -74,7 +74,7 @@ int wl1251_cmd_test(struct wl1251 *wl, void *buf, size_t buf_len, u8 answer)
 	ret = wl1251_cmd_send(wl, CMD_TEST, buf, buf_len);
 
 	if (ret < 0) {
-		wl1251_warning("TEST command failed");
+		wiphy_warn(wl->hw->wiphy, "TEST command failed\n");
 		return ret;
 	}
 
@@ -158,7 +158,7 @@ int wl1251_cmd_configure(struct wl1251 *wl, u16 id, void *buf, size_t len)
 
 	ret = wl1251_cmd_send(wl, CMD_CONFIGURE, acx, len);
 	if (ret < 0) {
-		wl1251_warning("CONFIGURE command NOK");
+		wiphy_warn(wl->hw->wiphy, "CONFIGURE command NOK\n");
 		return ret;
 	}
 
@@ -182,8 +182,8 @@ int wl1251_cmd_vbm(struct wl1251 *wl, u8 identity,
 	/* Count and period will be filled by the target */
 	vbm->tim.bitmap_ctrl = bitmap_control;
 	if (bitmap_len > PARTIAL_VBM_MAX) {
-		wl1251_warning("cmd vbm len is %d B, truncating to %d",
-			       bitmap_len, PARTIAL_VBM_MAX);
+		wiphy_warn(wl->hw->wiphy, "cmd vbm len is %d B, truncating to %d\n",
+			   bitmap_len, PARTIAL_VBM_MAX);
 		bitmap_len = PARTIAL_VBM_MAX;
 	}
 	memcpy(vbm->tim.pvb_field, bitmap, bitmap_len);
@@ -413,7 +413,7 @@ int wl1251_cmd_template_set(struct wl1251 *wl, u16 cmd_id,
 
 	ret = wl1251_cmd_send(wl, cmd_id, cmd, cmd_len);
 	if (ret < 0) {
-		wl1251_warning("cmd set_template failed: %d", ret);
+		wiphy_warn(wl->hw->wiphy, "cmd set_template failed: %d\n", ret);
 		goto out;
 	}
 
diff --git a/drivers/net/wireless/ti/wl1251/init.c b/drivers/net/wireless/ti/wl1251/init.c
index b1fedb9..796ccf4 100644
--- a/drivers/net/wireless/ti/wl1251/init.c
+++ b/drivers/net/wireless/ti/wl1251/init.c
@@ -35,13 +35,13 @@ int wl1251_hw_init_hwenc_config(struct wl1251 *wl)
 
 	ret = wl1251_acx_feature_cfg(wl, 0);
 	if (ret < 0) {
-		wl1251_warning("couldn't set feature config");
+		wiphy_warn(wl->hw->wiphy, "couldn't set feature config\n");
 		return ret;
 	}
 
 	ret = wl1251_acx_default_key(wl, wl->default_key);
 	if (ret < 0) {
-		wl1251_warning("couldn't set default key");
+		wiphy_warn(wl->hw->wiphy, "couldn't set default key\n");
 		return ret;
 	}
 
diff --git a/drivers/net/wireless/ti/wl1251/main.c b/drivers/net/wireless/ti/wl1251/main.c
index 7266d66..a0576e7 100644
--- a/drivers/net/wireless/ti/wl1251/main.c
+++ b/drivers/net/wireless/ti/wl1251/main.c
@@ -150,7 +150,7 @@ static void wl1251_fw_wakeup(struct wl1251 *wl)
 	elp_reg = wl1251_read_elp(wl, HW_ACCESS_ELP_CTRL_REG_ADDR);
 
 	if (!(elp_reg & ELPCTRL_WLAN_READY))
-		wl1251_warning("WLAN not ready");
+		wiphy_warn(wl->hw->wiphy, "WLAN not ready\n");
 }
 
 static int wl1251_chip_wakeup(struct wl1251 *wl)
@@ -264,9 +264,9 @@ static void wl1251_irq_work(struct work_struct *work)
 				intr |= WL1251_ACX_INTR_RX1_DATA;
 				break;
 			default:
-				wl1251_warning(
-					"RX: FW and host out of sync: %d",
-					wl->rx_counter - wl->rx_handled);
+				wiphy_warn(wl->hw->wiphy,
+					   "RX: FW and host out of sync: %d\n",
+					   wl->rx_counter - wl->rx_handled);
 				break;
 			}
 
@@ -352,7 +352,7 @@ static int wl1251_join(struct wl1251 *wl, u8 bss_type, u8 channel,
 
 	ret = wl1251_event_wait(wl, JOIN_EVENT_COMPLETE_ID, 100);
 	if (ret < 0)
-		wl1251_warning("join timeout");
+		wiphy_warn(wl->hw->wiphy, "join timeout\n");
 
 out:
 	return ret;
@@ -577,7 +577,8 @@ static int wl1251_build_null_data(struct wl1251 *wl)
 out:
 	dev_kfree_skb(skb);
 	if (ret)
-		wl1251_warning("cmd buld null data failed: %d", ret);
+		wiphy_warn(wl->hw->wiphy, "cmd buld null data failed: %d\n",
+			   ret);
 
 	return ret;
 }
@@ -973,7 +974,7 @@ static int wl1251_op_set_key(struct ieee80211_hw *hw, enum set_key_cmd cmd,
 
 	ret = wl1251_cmd_send(wl, CMD_SET_KEYS, wl_cmd, sizeof(*wl_cmd));
 	if (ret < 0) {
-		wl1251_warning("could not set keys");
+		wiphy_warn(wl->hw->wiphy, "could not set keys\n");
 		goto out_sleep;
 	}
 
@@ -1084,7 +1085,8 @@ static int wl1251_op_set_rts_threshold(struct ieee80211_hw *hw, u32 value)
 
 	ret = wl1251_acx_rts_threshold(wl, (u16) value);
 	if (ret < 0)
-		wl1251_warning("wl1251_op_set_rts_threshold failed: %d", ret);
+		wiphy_warn(wl->hw->wiphy, "wl1251_op_set_rts_threshold failed: %d\n",
+			   ret);
 
 	wl1251_ps_elp_sleep(wl);
 
@@ -1172,7 +1174,8 @@ static void wl1251_op_bss_info_changed(struct ieee80211_hw *hw,
 		else
 			ret = wl1251_acx_slot(wl, SLOT_TIME_LONG);
 		if (ret < 0) {
-			wl1251_warning("Set slot time failed %d", ret);
+			wiphy_warn(wl->hw->wiphy, "Set slot time failed %d\n",
+				   ret);
 			goto out_sleep;
 		}
 	}
@@ -1190,7 +1193,8 @@ static void wl1251_op_bss_info_changed(struct ieee80211_hw *hw,
 		else
 			ret = wl1251_acx_cts_protect(wl, CTSPROTECT_DISABLE);
 		if (ret < 0) {
-			wl1251_warning("Set ctsprotect failed %d", ret);
+			wiphy_warn(wl->hw->wiphy, "Set ctsprotect failed %d\n",
+				   ret);
 			goto out_sleep;
 		}
 	}
@@ -1436,7 +1440,7 @@ static int wl1251_read_eeprom_mac(struct wl1251 *wl)
 
 	ret = wl1251_read_eeprom(wl, 0x1c, mac, sizeof(mac));
 	if (ret < 0) {
-		wl1251_warning("failed to read MAC address from EEPROM");
+		wiphy_warn(wl->hw->wiphy, "failed to read MAC address from EEPROM\n");
 		return ret;
 	}
 
diff --git a/drivers/net/wireless/ti/wl1251/rx.c b/drivers/net/wireless/ti/wl1251/rx.c
index 0176656..df59521 100644
--- a/drivers/net/wireless/ti/wl1251/rx.c
+++ b/drivers/net/wireless/ti/wl1251/rx.c
@@ -158,8 +158,8 @@ static void wl1251_rx_body(struct wl1251 *wl,
 	last_id_inc = (wl->rx_last_id + 1) % (RX_MAX_PACKET_ID + 1);
 
 	if (last_id_inc != curr_id) {
-		wl1251_warning("curr ID:%d, last ID inc:%d",
-			       curr_id, last_id_inc);
+		wiphy_warn(wl->hw->wiphy, "curr ID:%d, last ID inc:%d\n",
+			   curr_id, last_id_inc);
 		wl->rx_last_id = curr_id;
 	} else {
 		wl->rx_last_id = last_id_inc;
diff --git a/drivers/net/wireless/ti/wl1251/tx.c b/drivers/net/wireless/ti/wl1251/tx.c
index 0aa2d54..0e782f8 100644
--- a/drivers/net/wireless/ti/wl1251/tx.c
+++ b/drivers/net/wireless/ti/wl1251/tx.c
@@ -289,13 +289,13 @@ static void enable_tx_for_packet_injection(struct wl1251 *wl)
 	ret = wl1251_cmd_join(wl, BSS_TYPE_STA_BSS, wl->channel,
 			      wl->beacon_int, wl->dtim_period);
 	if (ret < 0) {
-		wl1251_warning("join failed");
+		wiphy_warn(wl->hw->wiphy, "join failed\n");
 		return;
 	}
 
 	ret = wl1251_event_wait(wl, JOIN_EVENT_COMPLETE_ID, 100);
 	if (ret < 0) {
-		wl1251_warning("join timeout");
+		wiphy_warn(wl->hw->wiphy, "join timeout\n");
 		return;
 	}
 
diff --git a/drivers/net/wireless/ti/wl1251/wl1251.h b/drivers/net/wireless/ti/wl1251/wl1251.h
index 2fdb194..5d520d2 100644
--- a/drivers/net/wireless/ti/wl1251/wl1251.h
+++ b/drivers/net/wireless/ti/wl1251/wl1251.h
@@ -54,9 +54,6 @@ enum {
 
 #define DEBUG_DUMP_LIMIT 1024
 
-#define wl1251_warning(fmt, arg...) \
-	printk(KERN_WARNING DRIVER_PREFIX "WARNING " fmt "\n", ##arg)
