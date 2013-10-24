From: Jing Wang <windsdaemon@gmail.com>
Subject: [PATCH 1/1] drivers:net:wireless  return -ENOMEM if kzalloc fails
Date: Thu, 24 Oct 2013 16:14:11 +0800
Message-ID: <1382602451-2517-1-git-send-email-windsdaemon@gmail.com>
Cc: Jing Wang <windsdaemon@gmail.com>
To: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f51.google.com ([209.85.160.51]:50970 "EHLO
	mail-pb0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753308Ab3JXITY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Oct 2013 04:19:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jing Wang <windsdaemon@gmail.com>

the original code used goto out if kzalloc fails,but the out include kfree,
so return -ENOMEME if kzalloc fails.

Signed-off-by: Jing Wang <windsdaemon@gmail.com>
---
 drivers/net/wireless/ti/wl1251/acx.c |  207 +++++++++++-----------------------
 1 files changed, 68 insertions(+), 139 deletions(-)

diff --git a/drivers/net/wireless/ti/wl1251/acx.c b/drivers/net/wireless/ti/wl1251/acx.c
index db6430c..bb0edc9 100644
--- a/drivers/net/wireless/ti/wl1251/acx.c
+++ b/drivers/net/wireless/ti/wl1251/acx.c
@@ -18,10 +18,8 @@ int wl1251_acx_frame_rates(struct wl1251 *wl, u8 ctrl_rate, u8 ctrl_mod,
 	wl1251_debug(DEBUG_ACX, "acx frame rates");
 
 	rates = kzalloc(sizeof(*rates), GFP_KERNEL);
-	if (!rates) {
-		ret = -ENOMEM;
-		goto out;
-	}
+	if (!rates)
+		return -ENOMEM;
 
 	rates->tx_ctrl_frame_rate = ctrl_rate;
 	rates->tx_ctrl_frame_mod = ctrl_mod;
@@ -49,10 +47,8 @@ int wl1251_acx_station_id(struct wl1251 *wl)
 	wl1251_debug(DEBUG_ACX, "acx dot11_station_id");
 
 	mac = kzalloc(sizeof(*mac), GFP_KERNEL);
-	if (!mac) {
-		ret = -ENOMEM;
-		goto out;
-	}
+	if (!mac)
+		return -ENOMEM;
 
 	for (i = 0; i < ETH_ALEN; i++)
 		mac->mac[i] = wl->mac_addr[ETH_ALEN - 1 - i];
@@ -74,10 +70,8 @@ int wl1251_acx_default_key(struct wl1251 *wl, u8 key_id)
 	wl1251_debug(DEBUG_ACX, "acx dot11_default_key (%d)", key_id);
 
 	default_key = kzalloc(sizeof(*default_key), GFP_KERNEL);
-	if (!default_key) {
-		ret = -ENOMEM;
-		goto out;
-	}
+	if (!default_key)
+		return -ENOMEM;
 
 	default_key->id = key_id;
 
@@ -104,10 +98,8 @@ int wl1251_acx_wake_up_conditions(struct wl1251 *wl, u8 wake_up_event,
 	wl1251_debug(DEBUG_ACX, "acx wake up conditions");
 
 	wake_up = kzalloc(sizeof(*wake_up), GFP_KERNEL);
-	if (!wake_up) {
-		ret = -ENOMEM;
-		goto out;
-	}
+	if (!wake_up)
+		return -ENOMEM;
 
 	wake_up->wake_up_event = wake_up_event;
 	wake_up->listen_interval = listen_interval;
@@ -132,10 +124,8 @@ int wl1251_acx_sleep_auth(struct wl1251 *wl, u8 sleep_auth)
 	wl1251_debug(DEBUG_ACX, "acx sleep auth");
 
 	auth = kzalloc(sizeof(*auth), GFP_KERNEL);
-	if (!auth) {
-		ret = -ENOMEM;
-		goto out;
-	}
+	if (!auth)
+		return -ENOMEM;
 
 	auth->sleep_auth = sleep_auth;
 
@@ -154,10 +144,8 @@ int wl1251_acx_fw_version(struct wl1251 *wl, char *buf, size_t len)
 	wl1251_debug(DEBUG_ACX, "acx fw rev");
 
 	rev = kzalloc(sizeof(*rev), GFP_KERNEL);
-	if (!rev) {
-		ret = -ENOMEM;
-		goto out;
-	}
+	if (!rev)
+		return -ENOMEM;
 
 	ret = wl1251_cmd_interrogate(wl, ACX_FW_REV, rev, sizeof(*rev));
 	if (ret < 0) {
@@ -191,10 +179,8 @@ int wl1251_acx_tx_power(struct wl1251 *wl, int power)
 		return -EINVAL;
 
 	acx = kzalloc(sizeof(*acx), GFP_KERNEL);
-	if (!acx) {
-		ret = -ENOMEM;
-		goto out;
-	}
+	if (!acx)
+		return -ENOMEM;
 
 	acx->current_tx_power = power * 10;
 
@@ -217,10 +203,8 @@ int wl1251_acx_feature_cfg(struct wl1251 *wl)
 	wl1251_debug(DEBUG_ACX, "acx feature cfg");
 
 	feature = kzalloc(sizeof(*feature), GFP_KERNEL);
-	if (!feature) {
-		ret = -ENOMEM;
-		goto out;
-	}
+	if (!feature)
+		return -ENOMEM;
 
 	/* DF_ENCRYPTION_DISABLE and DF_SNIFF_MODE_ENABLE are disabled */
 	feature->data_flow_options = 0;
@@ -261,10 +245,8 @@ int wl1251_acx_data_path_params(struct wl1251 *wl,
 	wl1251_debug(DEBUG_ACX, "acx data path params");
 
 	params = kzalloc(sizeof(*params), GFP_KERNEL);
-	if (!params) {
-		ret = -ENOMEM;
-		goto out;
-	}
+	if (!params)
+		return -ENOMEM;
 
 	params->rx_packet_ring_chunk_size = DP_RX_PACKET_RING_CHUNK_SIZE;
 	params->tx_packet_ring_chunk_size = DP_TX_PACKET_RING_CHUNK_SIZE;
@@ -309,10 +291,8 @@ int wl1251_acx_rx_msdu_life_time(struct wl1251 *wl, u32 life_time)
 	wl1251_debug(DEBUG_ACX, "acx rx msdu life time");
 
 	acx = kzalloc(sizeof(*acx), GFP_KERNEL);
-	if (!acx) {
-		ret = -ENOMEM;
-		goto out;
-	}
+	if (!acx)
+		return -ENOMEM;
 
 	acx->lifetime = life_time;
 	ret = wl1251_cmd_configure(wl, DOT11_RX_MSDU_LIFE_TIME,
@@ -335,10 +315,8 @@ int wl1251_acx_rx_config(struct wl1251 *wl, u32 config, u32 filter)
 	wl1251_debug(DEBUG_ACX, "acx rx config");
 
 	rx_config = kzalloc(sizeof(*rx_config), GFP_KERNEL);
-	if (!rx_config) {
-		ret = -ENOMEM;
-		goto out;
-	}
+	if (!rx_config)
+		return -ENOMEM;
 
 	rx_config->config_options = config;
 	rx_config->filter_options = filter;
@@ -363,10 +341,8 @@ int wl1251_acx_pd_threshold(struct wl1251 *wl)
 	wl1251_debug(DEBUG_ACX, "acx data pd threshold");
 
 	pd = kzalloc(sizeof(*pd), GFP_KERNEL);
-	if (!pd) {
-		ret = -ENOMEM;
-		goto out;
-	}
+	if (!pd)
+		return -ENOMEM;
 
 	/* FIXME: threshold value not set */
 
@@ -389,10 +365,8 @@ int wl1251_acx_slot(struct wl1251 *wl, enum acx_slot_type slot_time)
 	wl1251_debug(DEBUG_ACX, "acx slot");
 
 	slot = kzalloc(sizeof(*slot), GFP_KERNEL);
-	if (!slot) {
-		ret = -ENOMEM;
-		goto out;
-	}
+	if (!slot)
+		return -ENOMEM;
 
 	slot->wone_index = STATION_WONE_INDEX;
 	slot->slot_time = slot_time;
@@ -416,10 +390,8 @@ int wl1251_acx_group_address_tbl(struct wl1251 *wl)
 	wl1251_debug(DEBUG_ACX, "acx group address tbl");
 
 	acx = kzalloc(sizeof(*acx), GFP_KERNEL);
-	if (!acx) {
-		ret = -ENOMEM;
-		goto out;
-	}
+	if (!acx)
+		return -ENOMEM;
 
 	/* MAC filtering */
 	acx->enabled = 0;
@@ -444,10 +416,8 @@ int wl1251_acx_service_period_timeout(struct wl1251 *wl)
 	int ret;
 
 	rx_timeout = kzalloc(sizeof(*rx_timeout), GFP_KERNEL);
-	if (!rx_timeout) {
-		ret = -ENOMEM;
-		goto out;
-	}
+	if (!rx_timeout)
+		return -ENOMEM;
 
 	wl1251_debug(DEBUG_ACX, "acx service period timeout");
 
@@ -475,10 +445,8 @@ int wl1251_acx_rts_threshold(struct wl1251 *wl, u16 rts_threshold)
 	wl1251_debug(DEBUG_ACX, "acx rts threshold");
 
 	rts = kzalloc(sizeof(*rts), GFP_KERNEL);
-	if (!rts) {
-		ret = -ENOMEM;
-		goto out;
-	}
+	if (!rts)
+		return -ENOMEM;
 
 	rts->threshold = rts_threshold;
 
@@ -501,10 +469,8 @@ int wl1251_acx_beacon_filter_opt(struct wl1251 *wl, bool enable_filter)
 	wl1251_debug(DEBUG_ACX, "acx beacon filter opt");
 
 	beacon_filter = kzalloc(sizeof(*beacon_filter), GFP_KERNEL);
-	if (!beacon_filter) {
-		ret = -ENOMEM;
-		goto out;
-	}
+	if (!beacon_filter)
+		return -ENOMEM;
 
 	beacon_filter->enable = enable_filter;
 	beacon_filter->max_num_beacons = 0;
@@ -530,10 +496,8 @@ int wl1251_acx_beacon_filter_table(struct wl1251 *wl)
 	wl1251_debug(DEBUG_ACX, "acx beacon filter table");
 
 	ie_table = kzalloc(sizeof(*ie_table), GFP_KERNEL);
-	if (!ie_table) {
-		ret = -ENOMEM;
-		goto out;
-	}
+	if (!ie_table)
+		return -ENOMEM;
 
 	/* configure default beacon pass-through rules */
 	ie_table->num_ie = 1;
@@ -560,10 +524,8 @@ int wl1251_acx_conn_monit_params(struct wl1251 *wl)
 	wl1251_debug(DEBUG_ACX, "acx connection monitor parameters");
 
 	acx = kzalloc(sizeof(*acx), GFP_KERNEL);
-	if (!acx) {
-		ret = -ENOMEM;
-		goto out;
-	}
+	if (!acx)
+		return -ENOMEM;
 
 	acx->synch_fail_thold = SYNCH_FAIL_DEFAULT_THRESHOLD;
 	acx->bss_lose_timeout = NO_BEACON_DEFAULT_TIMEOUT;
@@ -589,10 +551,8 @@ int wl1251_acx_sg_enable(struct wl1251 *wl)
 	wl1251_debug(DEBUG_ACX, "acx sg enable");
 
 	pta = kzalloc(sizeof(*pta), GFP_KERNEL);
-	if (!pta) {
-		ret = -ENOMEM;
-		goto out;
-	}
+	if (!pta)
+		return -ENOMEM;
 
 	pta->enable = SG_ENABLE;
 
@@ -615,10 +575,8 @@ int wl1251_acx_sg_cfg(struct wl1251 *wl)
 	wl1251_debug(DEBUG_ACX, "acx sg cfg");
 
 	param = kzalloc(sizeof(*param), GFP_KERNEL);
-	if (!param) {
-		ret = -ENOMEM;
-		goto out;
-	}
+	if (!param)
+		return -ENOMEM;
 
 	/* BT-WLAN coext parameters */
 	param->min_rate = RATE_INDEX_24MBPS;
@@ -669,10 +627,8 @@ int wl1251_acx_cca_threshold(struct wl1251 *wl)
 	wl1251_debug(DEBUG_ACX, "acx cca threshold");
 
 	detection = kzalloc(sizeof(*detection), GFP_KERNEL);
-	if (!detection) {
-		ret = -ENOMEM;
-		goto out;
-	}
+	if (!detection)
+		return -ENOMEM;
 
 	detection->rx_cca_threshold = CCA_THRSH_DISABLE_ENERGY_D;
 	detection->tx_energy_detection = 0;
@@ -695,10 +651,8 @@ int wl1251_acx_bcn_dtim_options(struct wl1251 *wl)
 	wl1251_debug(DEBUG_ACX, "acx bcn dtim options");
 
 	bb = kzalloc(sizeof(*bb), GFP_KERNEL);
-	if (!bb) {
-		ret = -ENOMEM;
-		goto out;
-	}
+	if (!bb)
+		return -ENOMEM;
 
 	bb->beacon_rx_timeout = BCN_RX_TIMEOUT_DEF_VALUE;
 	bb->broadcast_timeout = BROADCAST_RX_TIMEOUT_DEF_VALUE;
@@ -724,10 +678,8 @@ int wl1251_acx_aid(struct wl1251 *wl, u16 aid)
 	wl1251_debug(DEBUG_ACX, "acx aid");
 
 	acx_aid = kzalloc(sizeof(*acx_aid), GFP_KERNEL);
-	if (!acx_aid) {
-		ret = -ENOMEM;
-		goto out;
-	}
+	if (!acx_aid)
+		return -ENOMEM;
 
 	acx_aid->aid = aid;
 
@@ -750,10 +702,8 @@ int wl1251_acx_event_mbox_mask(struct wl1251 *wl, u32 event_mask)
 	wl1251_debug(DEBUG_ACX, "acx event mbox mask");
 
 	mask = kzalloc(sizeof(*mask), GFP_KERNEL);
-	if (!mask) {
-		ret = -ENOMEM;
-		goto out;
-	}
+	if (!mask)
+		return -ENOMEM;
 
 	/* high event mask is unused */
 	mask->high_event_mask = 0xffffffff;
@@ -805,10 +755,8 @@ int wl1251_acx_set_preamble(struct wl1251 *wl, enum acx_preamble_type preamble)
 	wl1251_debug(DEBUG_ACX, "acx_set_preamble");
 
 	acx = kzalloc(sizeof(*acx), GFP_KERNEL);
-	if (!acx) {
-		ret = -ENOMEM;
-		goto out;
-	}
+	if (!acx)
+		return -ENOMEM;
 
 	acx->preamble = preamble;
 
@@ -832,10 +780,8 @@ int wl1251_acx_cts_protect(struct wl1251 *wl,
 	wl1251_debug(DEBUG_ACX, "acx_set_ctsprotect");
 
 	acx = kzalloc(sizeof(*acx), GFP_KERNEL);
-	if (!acx) {
-		ret = -ENOMEM;
-		goto out;
-	}
+	if (!acx)
+		return -ENOMEM;
 
 	acx->ctsprotect = ctsprotect;
 
@@ -856,10 +802,8 @@ int wl1251_acx_tsf_info(struct wl1251 *wl, u64 *mactime)
 	int ret;
 
 	tsf_info = kzalloc(sizeof(*tsf_info), GFP_KERNEL);
-	if (!tsf_info) {
-		ret = -ENOMEM;
-		goto out;
-	}
+	if (!tsf_info)
+		return -ENOMEM;
 
 	ret = wl1251_cmd_interrogate(wl, ACX_TSF_INFO,
 				     tsf_info, sizeof(*tsf_info));
@@ -900,11 +844,8 @@ int wl1251_acx_rate_policies(struct wl1251 *wl)
 	wl1251_debug(DEBUG_ACX, "acx rate policies");
 
 	acx = kzalloc(sizeof(*acx), GFP_KERNEL);
-
-	if (!acx) {
-		ret = -ENOMEM;
-		goto out;
-	}
+	if (!acx)
+		return -ENOMEM;
 
 	/* configure one default (one-size-fits-all) rate class */
 	acx->rate_class_cnt = 1;
@@ -932,10 +873,8 @@ int wl1251_acx_mem_cfg(struct wl1251 *wl)
 	wl1251_debug(DEBUG_ACX, "acx mem cfg");
 
 	mem_conf = kzalloc(sizeof(*mem_conf), GFP_KERNEL);
-	if (!mem_conf) {
-		ret = -ENOMEM;
-		goto out;
-	}
+	if (!mem_conf)
+		return -ENOMEM;
 
 	/* memory config */
 	mem_conf->mem_config.num_stations = cpu_to_le16(DEFAULT_NUM_STATIONS);
@@ -979,10 +918,8 @@ int wl1251_acx_wr_tbtt_and_dtim(struct wl1251 *wl, u16 tbtt, u8 dtim)
 	wl1251_debug(DEBUG_ACX, "acx tbtt and dtim");
 
 	acx = kzalloc(sizeof(*acx), GFP_KERNEL);
-	if (!acx) {
-		ret = -ENOMEM;
-		goto out;
-	}
+	if (!acx)
+		return -ENOMEM;
 
 	acx->tbtt = tbtt;
 	acx->dtim = dtim;
@@ -1008,10 +945,8 @@ int wl1251_acx_bet_enable(struct wl1251 *wl, enum wl1251_acx_bet_mode mode,
 	wl1251_debug(DEBUG_ACX, "acx bet enable");
 
 	acx = kzalloc(sizeof(*acx), GFP_KERNEL);
-	if (!acx) {
-		ret = -ENOMEM;
-		goto out;
-	}
+	if (!acx)
+		return -ENOMEM;
 
 	acx->enable = mode;
 	acx->max_consecutive = max_consecutive;
@@ -1037,11 +972,8 @@ int wl1251_acx_ac_cfg(struct wl1251 *wl, u8 ac, u8 cw_min, u16 cw_max,
 		     "aifs %d txop %d", ac, cw_min, cw_max, aifs, txop);
 
 	acx = kzalloc(sizeof(*acx), GFP_KERNEL);
-
-	if (!acx) {
-		ret = -ENOMEM;
-		goto out;
-	}
+	if (!acx)
+		return -ENOMEM;
 
 	acx->ac = ac;
 	acx->cw_min = cw_min;
@@ -1073,11 +1005,8 @@ int wl1251_acx_tid_cfg(struct wl1251 *wl, u8 queue,
 		     ps_scheme, ack_policy);
 
 	acx = kzalloc(sizeof(*acx), GFP_KERNEL);
-
-	if (!acx) {
-		ret = -ENOMEM;
-		goto out;
-	}
+	if (!acx)
+		return -ENOMEM;
 
 	acx->queue = queue;
 	acx->type = type;
-- 
1.7.1
