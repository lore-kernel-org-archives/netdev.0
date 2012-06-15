From: Joe Perches <joe@perches.com>
Subject: [PATCH wireless-next 18/20] ti: Use pr_<level>
Date: Thu, 14 Jun 2012 22:53:58 -0700
Message-ID: <a4533db379be3689e3b29ed9b0d170263d875f7d.1339739416.git.joe@perches.com>
References: <cover.1339739415.git.joe@perches.com>
Cc: Luciano Coelho <coelho@ti.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1339739415.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use a more current logging style.

Convert printks to pr_<level>.
Coalesce formats, align arguments.

Add newlines to calls, remove from macros.
Remove unnecessary duplicate newlines from calls.
Remove spaces before newlines.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/wireless/ti/wl1251/acx.c      |  151 ++++++++--------
 drivers/net/wireless/ti/wl1251/boot.c     |   51 +++---
 drivers/net/wireless/ti/wl1251/cmd.c      |   76 ++++----
 drivers/net/wireless/ti/wl1251/init.c     |   16 +-
 drivers/net/wireless/ti/wl1251/io.c       |   27 ++--
 drivers/net/wireless/ti/wl1251/main.c     |  103 ++++++------
 drivers/net/wireless/ti/wl1251/ps.c       |   16 +-
 drivers/net/wireless/ti/wl1251/rx.c       |    8 +-
 drivers/net/wireless/ti/wl1251/sdio.c     |   20 +-
 drivers/net/wireless/ti/wl1251/spi.c      |   20 +-
 drivers/net/wireless/ti/wl1251/tx.c       |   21 +--
 drivers/net/wireless/ti/wl1251/wl1251.h   |   20 +-
 drivers/net/wireless/ti/wl12xx/acx.c      |    2 +-
 drivers/net/wireless/ti/wl12xx/cmd.c      |   18 +-
 drivers/net/wireless/ti/wl12xx/main.c     |   39 ++--
 drivers/net/wireless/ti/wl18xx/acx.c      |   12 +-
 drivers/net/wireless/ti/wl18xx/main.c     |   54 +++---
 drivers/net/wireless/ti/wl18xx/tx.c       |   10 +-
 drivers/net/wireless/ti/wlcore/acx.c      |  229 ++++++++++++------------
 drivers/net/wireless/ti/wlcore/boot.c     |   56 +++---
 drivers/net/wireless/ti/wlcore/cmd.c      |  164 +++++++++---------
 drivers/net/wireless/ti/wlcore/debug.h    |   22 ++--
 drivers/net/wireless/ti/wlcore/debugfs.c  |   42 +++---
 drivers/net/wireless/ti/wlcore/event.c    |   16 +-
 drivers/net/wireless/ti/wlcore/main.c     |  281 ++++++++++++++---------------
 drivers/net/wireless/ti/wlcore/ps.c       |   34 ++--
 drivers/net/wireless/ti/wlcore/rx.c       |   33 ++--
 drivers/net/wireless/ti/wlcore/scan.c     |   68 ++++----
 drivers/net/wireless/ti/wlcore/sdio.c     |    3 +-
 drivers/net/wireless/ti/wlcore/testmode.c |   16 +-
 drivers/net/wireless/ti/wlcore/tx.c       |   23 ++--
 31 files changed, 816 insertions(+), 835 deletions(-)

diff --git a/drivers/net/wireless/ti/wl1251/acx.c b/drivers/net/wireless/ti/wl1251/acx.c
index ad87a1a..15f8f6e 100644
--- a/drivers/net/wireless/ti/wl1251/acx.c
+++ b/drivers/net/wireless/ti/wl1251/acx.c
@@ -15,7 +15,7 @@ int wl1251_acx_frame_rates(struct wl1251 *wl, u8 ctrl_rate, u8 ctrl_mod,
 	struct acx_fw_gen_frame_rates *rates;
 	int ret;
 
-	wl1251_debug(DEBUG_ACX, "acx frame rates");
+	wl1251_debug(DEBUG_ACX, "acx frame rates\n");
 
 	rates = kzalloc(sizeof(*rates), GFP_KERNEL);
 	if (!rates) {
@@ -31,7 +31,7 @@ int wl1251_acx_frame_rates(struct wl1251 *wl, u8 ctrl_rate, u8 ctrl_mod,
 	ret = wl1251_cmd_configure(wl, ACX_FW_GEN_FRAME_RATES,
 				   rates, sizeof(*rates));
 	if (ret < 0) {
-		wl1251_error("Failed to set FW rates and modulation");
+		wl1251_err("Failed to set FW rates and modulation\n");
 		goto out;
 	}
 
@@ -46,7 +46,7 @@ int wl1251_acx_station_id(struct wl1251 *wl)
 	struct acx_dot11_station_id *mac;
 	int ret, i;
 
-	wl1251_debug(DEBUG_ACX, "acx dot11_station_id");
+	wl1251_debug(DEBUG_ACX, "acx dot11_station_id\n");
 
 	mac = kzalloc(sizeof(*mac), GFP_KERNEL);
 	if (!mac) {
@@ -71,7 +71,7 @@ int wl1251_acx_default_key(struct wl1251 *wl, u8 key_id)
 	struct acx_dot11_default_key *default_key;
 	int ret;
 
-	wl1251_debug(DEBUG_ACX, "acx dot11_default_key (%d)", key_id);
+	wl1251_debug(DEBUG_ACX, "acx dot11_default_key (%d)\n", key_id);
 
 	default_key = kzalloc(sizeof(*default_key), GFP_KERNEL);
 	if (!default_key) {
@@ -84,7 +84,7 @@ int wl1251_acx_default_key(struct wl1251 *wl, u8 key_id)
 	ret = wl1251_cmd_configure(wl, DOT11_DEFAULT_KEY,
 				   default_key, sizeof(*default_key));
 	if (ret < 0) {
-		wl1251_error("Couldn't set default key");
+		wl1251_err("Couldn't set default key\n");
 		goto out;
 	}
 
@@ -101,7 +101,7 @@ int wl1251_acx_wake_up_conditions(struct wl1251 *wl, u8 wake_up_event,
 	struct acx_wake_up_condition *wake_up;
 	int ret;
 
-	wl1251_debug(DEBUG_ACX, "acx wake up conditions");
+	wl1251_debug(DEBUG_ACX, "acx wake up conditions\n");
 
 	wake_up = kzalloc(sizeof(*wake_up), GFP_KERNEL);
 	if (!wake_up) {
@@ -115,7 +115,7 @@ int wl1251_acx_wake_up_conditions(struct wl1251 *wl, u8 wake_up_event,
 	ret = wl1251_cmd_configure(wl, ACX_WAKE_UP_CONDITIONS,
 				   wake_up, sizeof(*wake_up));
 	if (ret < 0) {
-		wl1251_warning("could not set wake up conditions: %d", ret);
+		wl1251_warn("could not set wake up conditions: %d\n", ret);
 		goto out;
 	}
 
@@ -129,7 +129,7 @@ int wl1251_acx_sleep_auth(struct wl1251 *wl, u8 sleep_auth)
 	struct acx_sleep_auth *auth;
 	int ret;
 
-	wl1251_debug(DEBUG_ACX, "acx sleep auth");
+	wl1251_debug(DEBUG_ACX, "acx sleep auth\n");
 
 	auth = kzalloc(sizeof(*auth), GFP_KERNEL);
 	if (!auth) {
@@ -151,7 +151,7 @@ int wl1251_acx_fw_version(struct wl1251 *wl, char *buf, size_t len)
 	struct acx_revision *rev;
 	int ret;
 
-	wl1251_debug(DEBUG_ACX, "acx fw rev");
+	wl1251_debug(DEBUG_ACX, "acx fw rev\n");
 
 	rev = kzalloc(sizeof(*rev), GFP_KERNEL);
 	if (!rev) {
@@ -161,7 +161,7 @@ int wl1251_acx_fw_version(struct wl1251 *wl, char *buf, size_t len)
 
 	ret = wl1251_cmd_interrogate(wl, ACX_FW_REV, rev, sizeof(*rev));
 	if (ret < 0) {
-		wl1251_warning("ACX_FW_REV interrogate failed");
+		wl1251_warn("ACX_FW_REV interrogate failed\n");
 		goto out;
 	}
 
@@ -185,7 +185,7 @@ int wl1251_acx_tx_power(struct wl1251 *wl, int power)
 	struct acx_current_tx_power *acx;
 	int ret;
 
-	wl1251_debug(DEBUG_ACX, "acx dot11_cur_tx_pwr");
+	wl1251_debug(DEBUG_ACX, "acx dot11_cur_tx_pwr\n");
 
 	if (power < 0 || power > 25)
 		return -EINVAL;
@@ -200,7 +200,7 @@ int wl1251_acx_tx_power(struct wl1251 *wl, int power)
 
 	ret = wl1251_cmd_configure(wl, DOT11_CUR_TX_PWR, acx, sizeof(*acx));
 	if (ret < 0) {
-		wl1251_warning("configure of tx power failed: %d", ret);
+		wl1251_warn("configure of tx power failed: %d\n", ret);
 		goto out;
 	}
 
@@ -214,7 +214,7 @@ int wl1251_acx_feature_cfg(struct wl1251 *wl)
 	struct acx_feature_config *feature;
 	int ret;
 
-	wl1251_debug(DEBUG_ACX, "acx feature cfg");
+	wl1251_debug(DEBUG_ACX, "acx feature cfg\n");
 
 	feature = kzalloc(sizeof(*feature), GFP_KERNEL);
 	if (!feature) {
@@ -229,7 +229,7 @@ int wl1251_acx_feature_cfg(struct wl1251 *wl)
 	ret = wl1251_cmd_configure(wl, ACX_FEATURE_CFG,
 				   feature, sizeof(*feature));
 	if (ret < 0) {
-		wl1251_error("Couldn't set HW encryption");
+		wl1251_err("Couldn't set HW encryption\n");
 		goto out;
 	}
 
@@ -243,7 +243,7 @@ int wl1251_acx_mem_map(struct wl1251 *wl, struct acx_header *mem_map,
 {
 	int ret;
 
-	wl1251_debug(DEBUG_ACX, "acx mem map");
+	wl1251_debug(DEBUG_ACX, "acx mem map\n");
 
 	ret = wl1251_cmd_interrogate(wl, ACX_MEM_MAP, mem_map, len);
 	if (ret < 0)
@@ -258,7 +258,7 @@ int wl1251_acx_data_path_params(struct wl1251 *wl,
 	struct acx_data_path_params *params;
 	int ret;
 
-	wl1251_debug(DEBUG_ACX, "acx data path params");
+	wl1251_debug(DEBUG_ACX, "acx data path params\n");
 
 	params = kzalloc(sizeof(*params), GFP_KERNEL);
 	if (!params) {
@@ -288,10 +288,10 @@ int wl1251_acx_data_path_params(struct wl1251 *wl,
 				     resp, sizeof(*resp));
 
 	if (ret < 0) {
-		wl1251_warning("failed to read data path parameters: %d", ret);
+		wl1251_warn("failed to read data path parameters: %d\n", ret);
 		goto out;
 	} else if (resp->header.cmd.status != CMD_STATUS_SUCCESS) {
-		wl1251_warning("data path parameter acx status failed");
+		wl1251_warn("data path parameter acx status failed\n");
 		ret = -EIO;
 		goto out;
 	}
@@ -306,7 +306,7 @@ int wl1251_acx_rx_msdu_life_time(struct wl1251 *wl, u32 life_time)
 	struct acx_rx_msdu_lifetime *acx;
 	int ret;
 
-	wl1251_debug(DEBUG_ACX, "acx rx msdu life time");
+	wl1251_debug(DEBUG_ACX, "acx rx msdu life time\n");
 
 	acx = kzalloc(sizeof(*acx), GFP_KERNEL);
 	if (!acx) {
@@ -318,7 +318,7 @@ int wl1251_acx_rx_msdu_life_time(struct wl1251 *wl, u32 life_time)
 	ret = wl1251_cmd_configure(wl, DOT11_RX_MSDU_LIFE_TIME,
 				   acx, sizeof(*acx));
 	if (ret < 0) {
-		wl1251_warning("failed to set rx msdu life time: %d", ret);
+		wl1251_warn("failed to set rx msdu life time: %d\n", ret);
 		goto out;
 	}
 
@@ -332,7 +332,7 @@ int wl1251_acx_rx_config(struct wl1251 *wl, u32 config, u32 filter)
 	struct acx_rx_config *rx_config;
 	int ret;
 
-	wl1251_debug(DEBUG_ACX, "acx rx config");
+	wl1251_debug(DEBUG_ACX, "acx rx config\n");
 
 	rx_config = kzalloc(sizeof(*rx_config), GFP_KERNEL);
 	if (!rx_config) {
@@ -346,7 +346,7 @@ int wl1251_acx_rx_config(struct wl1251 *wl, u32 config, u32 filter)
 	ret = wl1251_cmd_configure(wl, ACX_RX_CFG,
 				   rx_config, sizeof(*rx_config));
 	if (ret < 0) {
-		wl1251_warning("failed to set rx config: %d", ret);
+		wl1251_warn("failed to set rx config: %d\n", ret);
 		goto out;
 	}
 
@@ -360,7 +360,7 @@ int wl1251_acx_pd_threshold(struct wl1251 *wl)
 	struct acx_packet_detection *pd;
 	int ret;
 
-	wl1251_debug(DEBUG_ACX, "acx data pd threshold");
+	wl1251_debug(DEBUG_ACX, "acx data pd threshold\n");
 
 	pd = kzalloc(sizeof(*pd), GFP_KERNEL);
 	if (!pd) {
@@ -372,7 +372,7 @@ int wl1251_acx_pd_threshold(struct wl1251 *wl)
 
 	ret = wl1251_cmd_configure(wl, ACX_PD_THRESHOLD, pd, sizeof(*pd));
 	if (ret < 0) {
-		wl1251_warning("failed to set pd threshold: %d", ret);
+		wl1251_warn("failed to set pd threshold: %d\n", ret);
 		goto out;
 	}
 
@@ -386,7 +386,7 @@ int wl1251_acx_slot(struct wl1251 *wl, enum acx_slot_type slot_time)
 	struct acx_slot *slot;
 	int ret;
 
-	wl1251_debug(DEBUG_ACX, "acx slot");
+	wl1251_debug(DEBUG_ACX, "acx slot\n");
 
 	slot = kzalloc(sizeof(*slot), GFP_KERNEL);
 	if (!slot) {
@@ -399,7 +399,7 @@ int wl1251_acx_slot(struct wl1251 *wl, enum acx_slot_type slot_time)
 
 	ret = wl1251_cmd_configure(wl, ACX_SLOT, slot, sizeof(*slot));
 	if (ret < 0) {
-		wl1251_warning("failed to set slot time: %d", ret);
+		wl1251_warn("failed to set slot time: %d\n", ret);
 		goto out;
 	}
 
@@ -413,7 +413,7 @@ int wl1251_acx_group_address_tbl(struct wl1251 *wl)
 	struct acx_dot11_grp_addr_tbl *acx;
 	int ret;
 
-	wl1251_debug(DEBUG_ACX, "acx group address tbl");
+	wl1251_debug(DEBUG_ACX, "acx group address tbl\n");
 
 	acx = kzalloc(sizeof(*acx), GFP_KERNEL);
 	if (!acx) {
@@ -429,7 +429,7 @@ int wl1251_acx_group_address_tbl(struct wl1251 *wl)
 	ret = wl1251_cmd_configure(wl, DOT11_GROUP_ADDRESS_TBL,
 				   acx, sizeof(*acx));
 	if (ret < 0) {
-		wl1251_warning("failed to set group addr table: %d", ret);
+		wl1251_warn("failed to set group addr table: %d\n", ret);
 		goto out;
 	}
 
@@ -449,7 +449,7 @@ int wl1251_acx_service_period_timeout(struct wl1251 *wl)
 		goto out;
 	}
 
-	wl1251_debug(DEBUG_ACX, "acx service period timeout");
+	wl1251_debug(DEBUG_ACX, "acx service period timeout\n");
 
 	rx_timeout->ps_poll_timeout = RX_TIMEOUT_PS_POLL_DEF;
 	rx_timeout->upsd_timeout = RX_TIMEOUT_UPSD_DEF;
@@ -457,8 +457,8 @@ int wl1251_acx_service_period_timeout(struct wl1251 *wl)
 	ret = wl1251_cmd_configure(wl, ACX_SERVICE_PERIOD_TIMEOUT,
 				   rx_timeout, sizeof(*rx_timeout));
 	if (ret < 0) {
-		wl1251_warning("failed to set service period timeout: %d",
-			       ret);
+		wl1251_warn("failed to set service period timeout: %d\n",
+			    ret);
 		goto out;
 	}
 
@@ -472,7 +472,7 @@ int wl1251_acx_rts_threshold(struct wl1251 *wl, u16 rts_threshold)
 	struct acx_rts_threshold *rts;
 	int ret;
 
-	wl1251_debug(DEBUG_ACX, "acx rts threshold");
+	wl1251_debug(DEBUG_ACX, "acx rts threshold\n");
 
 	rts = kzalloc(sizeof(*rts), GFP_KERNEL);
 	if (!rts) {
@@ -484,7 +484,7 @@ int wl1251_acx_rts_threshold(struct wl1251 *wl, u16 rts_threshold)
 
 	ret = wl1251_cmd_configure(wl, DOT11_RTS_THRESHOLD, rts, sizeof(*rts));
 	if (ret < 0) {
-		wl1251_warning("failed to set rts threshold: %d", ret);
+		wl1251_warn("failed to set rts threshold: %d\n", ret);
 		goto out;
 	}
 
@@ -498,7 +498,7 @@ int wl1251_acx_beacon_filter_opt(struct wl1251 *wl, bool enable_filter)
 	struct acx_beacon_filter_option *beacon_filter;
 	int ret;
 
-	wl1251_debug(DEBUG_ACX, "acx beacon filter opt");
+	wl1251_debug(DEBUG_ACX, "acx beacon filter opt\n");
 
 	beacon_filter = kzalloc(sizeof(*beacon_filter), GFP_KERNEL);
 	if (!beacon_filter) {
@@ -512,7 +512,7 @@ int wl1251_acx_beacon_filter_opt(struct wl1251 *wl, bool enable_filter)
 	ret = wl1251_cmd_configure(wl, ACX_BEACON_FILTER_OPT,
 				   beacon_filter, sizeof(*beacon_filter));
 	if (ret < 0) {
-		wl1251_warning("failed to set beacon filter opt: %d", ret);
+		wl1251_warn("failed to set beacon filter opt: %d\n", ret);
 		goto out;
 	}
 
@@ -527,7 +527,7 @@ int wl1251_acx_beacon_filter_table(struct wl1251 *wl)
 	int idx = 0;
 	int ret;
 
-	wl1251_debug(DEBUG_ACX, "acx beacon filter table");
+	wl1251_debug(DEBUG_ACX, "acx beacon filter table\n");
 
 	ie_table = kzalloc(sizeof(*ie_table), GFP_KERNEL);
 	if (!ie_table) {
@@ -543,7 +543,7 @@ int wl1251_acx_beacon_filter_table(struct wl1251 *wl)
 	ret = wl1251_cmd_configure(wl, ACX_BEACON_FILTER_TABLE,
 				   ie_table, sizeof(*ie_table));
 	if (ret < 0) {
-		wl1251_warning("failed to set beacon filter table: %d", ret);
+		wl1251_warn("failed to set beacon filter table: %d\n", ret);
 		goto out;
 	}
 
@@ -557,7 +557,7 @@ int wl1251_acx_conn_monit_params(struct wl1251 *wl)
 	struct acx_conn_monit_params *acx;
 	int ret;
 
-	wl1251_debug(DEBUG_ACX, "acx connection monitor parameters");
+	wl1251_debug(DEBUG_ACX, "acx connection monitor parameters\n");
 
 	acx = kzalloc(sizeof(*acx), GFP_KERNEL);
 	if (!acx) {
@@ -571,8 +571,8 @@ int wl1251_acx_conn_monit_params(struct wl1251 *wl)
 	ret = wl1251_cmd_configure(wl, ACX_CONN_MONIT_PARAMS,
 				   acx, sizeof(*acx));
 	if (ret < 0) {
-		wl1251_warning("failed to set connection monitor "
-			       "parameters: %d", ret);
+		wl1251_warn("failed to set connection monitor parameters: %d\n",
+			    ret);
 		goto out;
 	}
 
@@ -586,7 +586,7 @@ int wl1251_acx_sg_enable(struct wl1251 *wl)
 	struct acx_bt_wlan_coex *pta;
 	int ret;
 
-	wl1251_debug(DEBUG_ACX, "acx sg enable");
+	wl1251_debug(DEBUG_ACX, "acx sg enable\n");
 
 	pta = kzalloc(sizeof(*pta), GFP_KERNEL);
 	if (!pta) {
@@ -598,7 +598,7 @@ int wl1251_acx_sg_enable(struct wl1251 *wl)
 
 	ret = wl1251_cmd_configure(wl, ACX_SG_ENABLE, pta, sizeof(*pta));
 	if (ret < 0) {
-		wl1251_warning("failed to set softgemini enable: %d", ret);
+		wl1251_warn("failed to set softgemini enable: %d\n", ret);
 		goto out;
 	}
 
@@ -612,7 +612,7 @@ int wl1251_acx_sg_cfg(struct wl1251 *wl)
 	struct acx_bt_wlan_coex_param *param;
 	int ret;
 
-	wl1251_debug(DEBUG_ACX, "acx sg cfg");
+	wl1251_debug(DEBUG_ACX, "acx sg cfg\n");
 
 	param = kzalloc(sizeof(*param), GFP_KERNEL);
 	if (!param) {
@@ -652,7 +652,7 @@ int wl1251_acx_sg_cfg(struct wl1251 *wl)
 
 	ret = wl1251_cmd_configure(wl, ACX_SG_CFG, param, sizeof(*param));
 	if (ret < 0) {
-		wl1251_warning("failed to set sg config: %d", ret);
+		wl1251_warn("failed to set sg config: %d\n", ret);
 		goto out;
 	}
 
@@ -666,7 +666,7 @@ int wl1251_acx_cca_threshold(struct wl1251 *wl)
 	struct acx_energy_detection *detection;
 	int ret;
 
-	wl1251_debug(DEBUG_ACX, "acx cca threshold");
+	wl1251_debug(DEBUG_ACX, "acx cca threshold\n");
 
 	detection = kzalloc(sizeof(*detection), GFP_KERNEL);
 	if (!detection) {
@@ -680,7 +680,7 @@ int wl1251_acx_cca_threshold(struct wl1251 *wl)
 	ret = wl1251_cmd_configure(wl, ACX_CCA_THRESHOLD,
 				   detection, sizeof(*detection));
 	if (ret < 0)
-		wl1251_warning("failed to set cca threshold: %d", ret);
+		wl1251_warn("failed to set cca threshold: %d\n", ret);
 
 out:
 	kfree(detection);
@@ -692,7 +692,7 @@ int wl1251_acx_bcn_dtim_options(struct wl1251 *wl)
 	struct acx_beacon_broadcast *bb;
 	int ret;
 
-	wl1251_debug(DEBUG_ACX, "acx bcn dtim options");
+	wl1251_debug(DEBUG_ACX, "acx bcn dtim options\n");
 
 	bb = kzalloc(sizeof(*bb), GFP_KERNEL);
 	if (!bb) {
@@ -707,7 +707,7 @@ int wl1251_acx_bcn_dtim_options(struct wl1251 *wl)
 
 	ret = wl1251_cmd_configure(wl, ACX_BCN_DTIM_OPTIONS, bb, sizeof(*bb));
 	if (ret < 0) {
-		wl1251_warning("failed to set rx config: %d", ret);
+		wl1251_warn("failed to set rx config: %d\n", ret);
 		goto out;
 	}
 
@@ -721,7 +721,7 @@ int wl1251_acx_aid(struct wl1251 *wl, u16 aid)
 	struct acx_aid *acx_aid;
 	int ret;
 
-	wl1251_debug(DEBUG_ACX, "acx aid");
+	wl1251_debug(DEBUG_ACX, "acx aid\n");
 
 	acx_aid = kzalloc(sizeof(*acx_aid), GFP_KERNEL);
 	if (!acx_aid) {
@@ -733,7 +733,7 @@ int wl1251_acx_aid(struct wl1251 *wl, u16 aid)
 
 	ret = wl1251_cmd_configure(wl, ACX_AID, acx_aid, sizeof(*acx_aid));
 	if (ret < 0) {
-		wl1251_warning("failed to set aid: %d", ret);
+		wl1251_warn("failed to set aid: %d\n", ret);
 		goto out;
 	}
 
@@ -747,7 +747,7 @@ int wl1251_acx_event_mbox_mask(struct wl1251 *wl, u32 event_mask)
 	struct acx_event_mask *mask;
 	int ret;
 
-	wl1251_debug(DEBUG_ACX, "acx event mbox mask");
+	wl1251_debug(DEBUG_ACX, "acx event mbox mask\n");
 
 	mask = kzalloc(sizeof(*mask), GFP_KERNEL);
 	if (!mask) {
@@ -763,7 +763,7 @@ int wl1251_acx_event_mbox_mask(struct wl1251 *wl, u32 event_mask)
 	ret = wl1251_cmd_configure(wl, ACX_EVENT_MBOX_MASK,
 				   mask, sizeof(*mask));
 	if (ret < 0) {
-		wl1251_warning("failed to set acx_event_mbox_mask: %d", ret);
+		wl1251_warn("failed to set acx_event_mbox_mask: %d\n", ret);
 		goto out;
 	}
 
@@ -778,7 +778,7 @@ int wl1251_acx_low_rssi(struct wl1251 *wl, s8 threshold, u8 weight,
 	struct acx_low_rssi *rssi;
 	int ret;
 
-	wl1251_debug(DEBUG_ACX, "acx low rssi");
+	wl1251_debug(DEBUG_ACX, "acx low rssi\n");
 
 	rssi = kzalloc(sizeof(*rssi), GFP_KERNEL);
 	if (!rssi)
@@ -791,7 +791,7 @@ int wl1251_acx_low_rssi(struct wl1251 *wl, s8 threshold, u8 weight,
 
 	ret = wl1251_cmd_configure(wl, ACX_LOW_RSSI, rssi, sizeof(*rssi));
 	if (ret < 0)
-		wl1251_warning("failed to set low rssi threshold: %d", ret);
+		wl1251_warn("failed to set low rssi threshold: %d\n", ret);
 
 	kfree(rssi);
 	return ret;
@@ -802,7 +802,7 @@ int wl1251_acx_set_preamble(struct wl1251 *wl, enum acx_preamble_type preamble)
 	struct acx_preamble *acx;
 	int ret;
 
-	wl1251_debug(DEBUG_ACX, "acx_set_preamble");
+	wl1251_debug(DEBUG_ACX, "acx_set_preamble\n");
 
 	acx = kzalloc(sizeof(*acx), GFP_KERNEL);
 	if (!acx) {
@@ -814,7 +814,7 @@ int wl1251_acx_set_preamble(struct wl1251 *wl, enum acx_preamble_type preamble)
 
 	ret = wl1251_cmd_configure(wl, ACX_PREAMBLE_TYPE, acx, sizeof(*acx));
 	if (ret < 0) {
-		wl1251_warning("Setting of preamble failed: %d", ret);
+		wl1251_warn("Setting of preamble failed: %d\n", ret);
 		goto out;
 	}
 
@@ -829,7 +829,7 @@ int wl1251_acx_cts_protect(struct wl1251 *wl,
 	struct acx_ctsprotect *acx;
 	int ret;
 
-	wl1251_debug(DEBUG_ACX, "acx_set_ctsprotect");
+	wl1251_debug(DEBUG_ACX, "acx_set_ctsprotect\n");
 
 	acx = kzalloc(sizeof(*acx), GFP_KERNEL);
 	if (!acx) {
@@ -841,7 +841,7 @@ int wl1251_acx_cts_protect(struct wl1251 *wl,
 
 	ret = wl1251_cmd_configure(wl, ACX_CTS_PROTECTION, acx, sizeof(*acx));
 	if (ret < 0) {
-		wl1251_warning("Setting of ctsprotect failed: %d", ret);
+		wl1251_warn("Setting of ctsprotect failed: %d\n", ret);
 		goto out;
 	}
 
@@ -864,7 +864,7 @@ int wl1251_acx_tsf_info(struct wl1251 *wl, u64 *mactime)
 	ret = wl1251_cmd_interrogate(wl, ACX_TSF_INFO,
 				     tsf_info, sizeof(*tsf_info));
 	if (ret < 0) {
-		wl1251_warning("ACX_FW_REV interrogate failed");
+		wl1251_warn("ACX_FW_REV interrogate failed\n");
 		goto out;
 	}
 
@@ -880,12 +880,12 @@ int wl1251_acx_statistics(struct wl1251 *wl, struct acx_statistics *stats)
 {
 	int ret;
 
-	wl1251_debug(DEBUG_ACX, "acx statistics");
+	wl1251_debug(DEBUG_ACX, "acx statistics\n");
 
 	ret = wl1251_cmd_interrogate(wl, ACX_STATISTICS, stats,
 				     sizeof(*stats));
 	if (ret < 0) {
-		wl1251_warning("acx statistics failed: %d", ret);
+		wl1251_warn("acx statistics failed: %d\n", ret);
 		return -ENOMEM;
 	}
 
@@ -897,7 +897,7 @@ int wl1251_acx_rate_policies(struct wl1251 *wl)
 	struct acx_rate_policy *acx;
 	int ret = 0;
 
-	wl1251_debug(DEBUG_ACX, "acx rate policies");
+	wl1251_debug(DEBUG_ACX, "acx rate policies\n");
 
 	acx = kzalloc(sizeof(*acx), GFP_KERNEL);
 
@@ -915,7 +915,7 @@ int wl1251_acx_rate_policies(struct wl1251 *wl)
 
 	ret = wl1251_cmd_configure(wl, ACX_RATE_POLICY, acx, sizeof(*acx));
 	if (ret < 0) {
-		wl1251_warning("Setting of rate policies failed: %d", ret);
+		wl1251_warn("Setting of rate policies failed: %d\n", ret);
 		goto out;
 	}
 
@@ -929,7 +929,7 @@ int wl1251_acx_mem_cfg(struct wl1251 *wl)
 	struct wl1251_acx_config_memory *mem_conf;
 	int ret, i;
 
-	wl1251_debug(DEBUG_ACX, "acx mem cfg");
+	wl1251_debug(DEBUG_ACX, "acx mem cfg\n");
 
 	mem_conf = kzalloc(sizeof(*mem_conf), GFP_KERNEL);
 	if (!mem_conf) {
@@ -962,7 +962,7 @@ int wl1251_acx_mem_cfg(struct wl1251 *wl)
 	ret = wl1251_cmd_configure(wl, ACX_MEM_CFG, mem_conf,
 				   sizeof(*mem_conf));
 	if (ret < 0) {
-		wl1251_warning("wl1251 mem config failed: %d", ret);
+		wl1251_warn("wl1251 mem config failed: %d\n", ret);
 		goto out;
 	}
 
@@ -976,7 +976,7 @@ int wl1251_acx_wr_tbtt_and_dtim(struct wl1251 *wl, u16 tbtt, u8 dtim)
 	struct wl1251_acx_wr_tbtt_and_dtim *acx;
 	int ret;
 
-	wl1251_debug(DEBUG_ACX, "acx tbtt and dtim");
+	wl1251_debug(DEBUG_ACX, "acx tbtt and dtim\n");
 
 	acx = kzalloc(sizeof(*acx), GFP_KERNEL);
 	if (!acx) {
@@ -990,7 +990,7 @@ int wl1251_acx_wr_tbtt_and_dtim(struct wl1251 *wl, u16 tbtt, u8 dtim)
 	ret = wl1251_cmd_configure(wl, ACX_WR_TBTT_AND_DTIM,
 				   acx, sizeof(*acx));
 	if (ret < 0) {
-		wl1251_warning("failed to set tbtt and dtim: %d", ret);
+		wl1251_warn("failed to set tbtt and dtim: %d\n", ret);
 		goto out;
 	}
 
@@ -1005,7 +1005,7 @@ int wl1251_acx_bet_enable(struct wl1251 *wl, enum wl1251_acx_bet_mode mode,
 	struct wl1251_acx_bet_enable *acx;
 	int ret;
 
-	wl1251_debug(DEBUG_ACX, "acx bet enable");
+	wl1251_debug(DEBUG_ACX, "acx bet enable\n");
 
 	acx = kzalloc(sizeof(*acx), GFP_KERNEL);
 	if (!acx) {
@@ -1018,7 +1018,7 @@ int wl1251_acx_bet_enable(struct wl1251 *wl, enum wl1251_acx_bet_mode mode,
 
 	ret = wl1251_cmd_configure(wl, ACX_BET_ENABLE, acx, sizeof(*acx));
 	if (ret < 0) {
-		wl1251_warning("wl1251 acx bet enable failed: %d", ret);
+		wl1251_warn("wl1251 acx bet enable failed: %d\n", ret);
 		goto out;
 	}
 
@@ -1033,8 +1033,8 @@ int wl1251_acx_ac_cfg(struct wl1251 *wl, u8 ac, u8 cw_min, u16 cw_max,
 	struct wl1251_acx_ac_cfg *acx;
 	int ret = 0;
 
-	wl1251_debug(DEBUG_ACX, "acx ac cfg %d cw_ming %d cw_max %d "
-		     "aifs %d txop %d", ac, cw_min, cw_max, aifs, txop);
+	wl1251_debug(DEBUG_ACX, "acx ac cfg %d cw_ming %d cw_max %d aifs %d txop %d\n",
+		     ac, cw_min, cw_max, aifs, txop);
 
 	acx = kzalloc(sizeof(*acx), GFP_KERNEL);
 
@@ -1051,7 +1051,7 @@ int wl1251_acx_ac_cfg(struct wl1251 *wl, u8 ac, u8 cw_min, u16 cw_max,
 
 	ret = wl1251_cmd_configure(wl, ACX_AC_CFG, acx, sizeof(*acx));
 	if (ret < 0) {
-		wl1251_warning("acx ac cfg failed: %d", ret);
+		wl1251_warn("acx ac cfg failed: %d\n", ret);
 		goto out;
 	}
 
@@ -1068,9 +1068,8 @@ int wl1251_acx_tid_cfg(struct wl1251 *wl, u8 queue,
 	struct wl1251_acx_tid_cfg *acx;
 	int ret = 0;
 
-	wl1251_debug(DEBUG_ACX, "acx tid cfg %d type %d tsid %d "
-		     "ps_scheme %d ack_policy %d", queue, type, tsid,
-		     ps_scheme, ack_policy);
+	wl1251_debug(DEBUG_ACX, "acx tid cfg %d type %d tsid %d ps_scheme %d ack_policy %d\n",
+		     queue, type, tsid, ps_scheme, ack_policy);
 
 	acx = kzalloc(sizeof(*acx), GFP_KERNEL);
 
@@ -1087,7 +1086,7 @@ int wl1251_acx_tid_cfg(struct wl1251 *wl, u8 queue,
 
 	ret = wl1251_cmd_configure(wl, ACX_TID_CFG, acx, sizeof(*acx));
 	if (ret < 0) {
-		wl1251_warning("acx tid cfg failed: %d", ret);
+		wl1251_warn("acx tid cfg failed: %d\n", ret);
 		goto out;
 	}
 
diff --git a/drivers/net/wireless/ti/wl1251/boot.c b/drivers/net/wireless/ti/wl1251/boot.c
index a2e5241..c30410f 100644
--- a/drivers/net/wireless/ti/wl1251/boot.c
+++ b/drivers/net/wireless/ti/wl1251/boot.c
@@ -46,14 +46,15 @@ int wl1251_boot_soft_reset(struct wl1251 *wl)
 	timeout = jiffies + usecs_to_jiffies(SOFT_RESET_MAX_TIME);
 	while (1) {
 		boot_data = wl1251_reg_read32(wl, ACX_REG_SLV_SOFT_RESET);
-		wl1251_debug(DEBUG_BOOT, "soft reset bootdata 0x%x", boot_data);
+		wl1251_debug(DEBUG_BOOT, "soft reset bootdata 0x%x\n",
+			     boot_data);
 		if ((boot_data & ACX_SLV_SOFT_RESET_BIT) == 0)
 			break;
 
 		if (time_after(jiffies, timeout)) {
 			/* 1.2 check pWhalBus->uSelfClearTime if the
 			 * timeout was reached */
-			wl1251_error("soft reset timeout");
+			wl1251_err("soft reset timeout\n");
 			return -1;
 		}
 
@@ -92,15 +93,15 @@ int wl1251_boot_init_seq(struct wl1251 *wl)
 
 	/* read NVS params */
 	scr_pad6 = wl1251_reg_read32(wl, SCR_PAD6);
-	wl1251_debug(DEBUG_BOOT, "scr_pad6 0x%x", scr_pad6);
+	wl1251_debug(DEBUG_BOOT, "scr_pad6 0x%x\n", scr_pad6);
 
 	/* read ELP_CMD */
 	elp_cmd = wl1251_reg_read32(wl, ELP_CMD);
-	wl1251_debug(DEBUG_BOOT, "elp_cmd 0x%x", elp_cmd);
+	wl1251_debug(DEBUG_BOOT, "elp_cmd 0x%x\n", elp_cmd);
 
 	/* set the BB calibration time to be 300 usec (PLL_CAL_TIME) */
 	ref_freq = scr_pad6 & 0x000000FF;
-	wl1251_debug(DEBUG_BOOT, "ref_freq 0x%x", ref_freq);
+	wl1251_debug(DEBUG_BOOT, "ref_freq 0x%x\n", ref_freq);
 
 	wl1251_reg_write32(wl, PLL_CAL_TIME, 0x9);
 
@@ -228,10 +229,11 @@ int wl1251_boot_run_firmware(struct wl1251 *wl)
 
 	chip_id = wl1251_reg_read32(wl, CHIP_ID_B);
 
-	wl1251_debug(DEBUG_BOOT, "chip id after firmware boot: 0x%x", chip_id);
+	wl1251_debug(DEBUG_BOOT, "chip id after firmware boot: 0x%x\n",
+		     chip_id);
 
 	if (chip_id != wl->chip_id) {
-		wl1251_error("chip id doesn't match after firmware boot");
+		wl1251_err("chip id doesn't match after firmware boot\n");
 		return -EIO;
 	}
 
@@ -242,8 +244,7 @@ int wl1251_boot_run_firmware(struct wl1251 *wl)
 		acx_intr = wl1251_reg_read32(wl, ACX_REG_INTERRUPT_NO_CLEAR);
 
 		if (acx_intr == 0xffffffff) {
-			wl1251_error("error reading hardware complete "
-				     "init indication");
+			wl1251_err("error reading hardware complete init indication\n");
 			return -EIO;
 		}
 		/* check that ACX_INTR_INIT_COMPLETE is enabled */
@@ -255,8 +256,7 @@ int wl1251_boot_run_firmware(struct wl1251 *wl)
 	}
 
 	if (loop > INIT_LOOP) {
-		wl1251_error("timeout waiting for the hardware to "
-			     "complete initialization");
+		wl1251_err("timeout waiting for the hardware to complete initialization\n");
 		return -EIO;
 	}
 
@@ -272,7 +272,7 @@ int wl1251_boot_run_firmware(struct wl1251 *wl)
 			     WL1251_PART_WORK_REG_START,
 			     WL1251_PART_WORK_REG_SIZE);
 
-	wl1251_debug(DEBUG_MAILBOX, "cmd_box_addr 0x%x event_box_addr 0x%x",
+	wl1251_debug(DEBUG_MAILBOX, "cmd_box_addr 0x%x event_box_addr 0x%x\n",
 		     wl->cmd_box_addr, wl->event_box_addr);
 
 	wl1251_acx_fw_version(wl, wl->fw_ver, sizeof(wl->fw_ver));
@@ -303,7 +303,7 @@ int wl1251_boot_run_firmware(struct wl1251 *wl)
 
 	ret = wl1251_event_unmask(wl);
 	if (ret < 0) {
-		wl1251_error("EVENT mask setting failed");
+		wl1251_err("EVENT mask setting failed\n");
 		return ret;
 	}
 
@@ -321,24 +321,24 @@ static int wl1251_boot_upload_firmware(struct wl1251 *wl)
 
 	/* whal_FwCtrl_LoadFwImageSm() */
 
-	wl1251_debug(DEBUG_BOOT, "chip id before fw upload: 0x%x",
+	wl1251_debug(DEBUG_BOOT, "chip id before fw upload: 0x%x\n",
 		     wl1251_reg_read32(wl, CHIP_ID_B));
 
 	/* 10.0 check firmware length and set partition */
 	fw_data_len =  (wl->fw[4] << 24) | (wl->fw[5] << 16) |
 		(wl->fw[6] << 8) | (wl->fw[7]);
 
-	wl1251_debug(DEBUG_BOOT, "fw_data_len %zu chunk_size %d", fw_data_len,
-		CHUNK_SIZE);
+	wl1251_debug(DEBUG_BOOT, "fw_data_len %zu chunk_size %d\n", fw_data_len,
+		     CHUNK_SIZE);
 
 	if ((fw_data_len % 4) != 0) {
-		wl1251_error("firmware length not multiple of four");
+		wl1251_err("firmware length not multiple of four\n");
 		return -EIO;
 	}
 
 	buf = kmalloc(CHUNK_SIZE, GFP_KERNEL);
 	if (!buf) {
-		wl1251_error("allocation for firmware upload chunk failed");
+		wl1251_err("allocation for firmware upload chunk failed\n");
 		return -ENOMEM;
 	}
 
@@ -370,7 +370,7 @@ static int wl1251_boot_upload_firmware(struct wl1251 *wl)
 		/* 10.3 upload the chunk */
 		addr = WL1251_PART_DOWN_MEM_START + chunk_num * CHUNK_SIZE;
 		p = wl->fw + FW_HDR_SIZE + chunk_num * CHUNK_SIZE;
-		wl1251_debug(DEBUG_BOOT, "uploading fw chunk 0x%p to 0x%x",
+		wl1251_debug(DEBUG_BOOT, "uploading fw chunk 0x%p to 0x%x\n",
 			     p, addr);
 
 		/* need to copy the chunk for dma */
@@ -389,7 +389,7 @@ static int wl1251_boot_upload_firmware(struct wl1251 *wl)
 	len = fw_data_len % CHUNK_SIZE;
 	memcpy(buf, p, len);
 
-	wl1251_debug(DEBUG_BOOT, "uploading fw last chunk (%zu B) 0x%p to 0x%x",
+	wl1251_debug(DEBUG_BOOT, "uploading fw last chunk (%zu B) 0x%p to 0x%x\n",
 		     len, p, addr);
 	wl1251_mem_write(wl, addr, buf, len);
 
@@ -435,7 +435,7 @@ static int wl1251_boot_upload_nvs(struct wl1251 *wl)
 			       | (nvs_ptr[2] << 16) | (nvs_ptr[3] << 24));
 
 			wl1251_debug(DEBUG_BOOT,
-				     "nvs burst write 0x%x: 0x%x",
+				     "nvs burst write 0x%x: 0x%x\n",
 				     dest_addr, val);
 			wl1251_mem_write32(wl, dest_addr, val);
 
@@ -465,7 +465,7 @@ static int wl1251_boot_upload_nvs(struct wl1251 *wl)
 		       | (nvs_ptr[2] << 16) | (nvs_ptr[3] << 24));
 
 		wl1251_debug(DEBUG_BOOT,
-			     "nvs write table 0x%x: 0x%x",
+			     "nvs write table 0x%x: 0x%x\n",
 			     nvs_start, val);
 		wl1251_mem_write32(wl, nvs_start, val);
 
@@ -517,8 +517,7 @@ int wl1251_boot(struct wl1251 *wl)
 	wl->boot_attr.minor = (tmp & 0x00FF0000) >> 16;
 	minor_minor_e2_ver = (tmp & 0xFF000000) >> 24;
 
-	wl1251_debug(DEBUG_BOOT, "radioType 0x%x majorE2Ver 0x%x "
-		     "minorE2Ver 0x%x minor_minor_e2_ver 0x%x",
+	wl1251_debug(DEBUG_BOOT, "radioType 0x%x majorE2Ver 0x%x minorE2Ver 0x%x minor_minor_e2_ver 0x%x\n",
 		     wl->boot_attr.radio_type, wl->boot_attr.major,
 		     wl->boot_attr.minor, minor_minor_e2_ver);
 
@@ -529,13 +528,13 @@ int wl1251_boot(struct wl1251 *wl)
 	/* 9. NVS processing done */
 	boot_data = wl1251_reg_read32(wl, ACX_REG_ECPU_CONTROL);
 
-	wl1251_debug(DEBUG_BOOT, "halt boot_data 0x%x", boot_data);
+	wl1251_debug(DEBUG_BOOT, "halt boot_data 0x%x\n", boot_data);
 
 	/* 10. check that ECPU_CONTROL_HALT bits are set in
 	 * pWhalBus->uBootData and start uploading firmware
 	 */
 	if ((boot_data & ECPU_CONTROL_HALT) == 0) {
-		wl1251_error("boot failed, ECPU_CONTROL_HALT not set");
+		wl1251_err("boot failed, ECPU_CONTROL_HALT not set\n");
 		ret = -EIO;
 		goto out;
 	}
diff --git a/drivers/net/wireless/ti/wl1251/cmd.c b/drivers/net/wireless/ti/wl1251/cmd.c
index d14d69d..a6a3e6e 100644
--- a/drivers/net/wireless/ti/wl1251/cmd.c
+++ b/drivers/net/wireless/ti/wl1251/cmd.c
@@ -40,7 +40,7 @@ int wl1251_cmd_send(struct wl1251 *wl, u16 id, void *buf, size_t len)
 	intr = wl1251_reg_read32(wl, ACX_REG_INTERRUPT_NO_CLEAR);
 	while (!(intr & WL1251_ACX_INTR_CMD_COMPLETE)) {
 		if (time_after(jiffies, timeout)) {
-			wl1251_error("command complete timeout");
+			wl1251_err("command complete timeout\n");
 			ret = -ETIMEDOUT;
 			goto out;
 		}
@@ -69,12 +69,12 @@ int wl1251_cmd_test(struct wl1251 *wl, void *buf, size_t buf_len, u8 answer)
 {
 	int ret;
 
-	wl1251_debug(DEBUG_CMD, "cmd test");
+	wl1251_debug(DEBUG_CMD, "cmd test\n");
 
 	ret = wl1251_cmd_send(wl, CMD_TEST, buf, buf_len);
 
 	if (ret < 0) {
-		wl1251_warning("TEST command failed");
+		wl1251_warn("TEST command failed\n");
 		return ret;
 	}
 
@@ -91,8 +91,8 @@ int wl1251_cmd_test(struct wl1251 *wl, void *buf, size_t buf_len, u8 answer)
 		cmd_answer = buf;
 
 		if (cmd_answer->header.status != CMD_STATUS_SUCCESS)
-			wl1251_error("TEST command answer error: %d",
-				     cmd_answer->header.status);
+			wl1251_err("TEST command answer error: %d\n",
+				   cmd_answer->header.status);
 	}
 
 	return 0;
@@ -111,7 +111,7 @@ int wl1251_cmd_interrogate(struct wl1251 *wl, u16 id, void *buf, size_t len)
 	struct acx_header *acx = buf;
 	int ret;
 
-	wl1251_debug(DEBUG_CMD, "cmd interrogate");
+	wl1251_debug(DEBUG_CMD, "cmd interrogate\n");
 
 	acx->id = id;
 
@@ -120,7 +120,7 @@ int wl1251_cmd_interrogate(struct wl1251 *wl, u16 id, void *buf, size_t len)
 
 	ret = wl1251_cmd_send(wl, CMD_INTERROGATE, acx, sizeof(*acx));
 	if (ret < 0) {
-		wl1251_error("INTERROGATE command failed");
+		wl1251_err("INTERROGATE command failed\n");
 		goto out;
 	}
 
@@ -129,8 +129,8 @@ int wl1251_cmd_interrogate(struct wl1251 *wl, u16 id, void *buf, size_t len)
 
 	acx = buf;
 	if (acx->cmd.status != CMD_STATUS_SUCCESS)
-		wl1251_error("INTERROGATE command error: %d",
-			     acx->cmd.status);
+		wl1251_err("INTERROGATE command error: %d\n",
+			   acx->cmd.status);
 
 out:
 	return ret;
@@ -149,7 +149,7 @@ int wl1251_cmd_configure(struct wl1251 *wl, u16 id, void *buf, size_t len)
 	struct acx_header *acx = buf;
 	int ret;
 
-	wl1251_debug(DEBUG_CMD, "cmd configure");
+	wl1251_debug(DEBUG_CMD, "cmd configure\n");
 
 	acx->id = id;
 
@@ -158,7 +158,7 @@ int wl1251_cmd_configure(struct wl1251 *wl, u16 id, void *buf, size_t len)
 
 	ret = wl1251_cmd_send(wl, CMD_CONFIGURE, acx, len);
 	if (ret < 0) {
-		wl1251_warning("CONFIGURE command NOK");
+		wl1251_warn("CONFIGURE command NOK\n");
 		return ret;
 	}
 
@@ -171,7 +171,7 @@ int wl1251_cmd_vbm(struct wl1251 *wl, u8 identity,
 	struct wl1251_cmd_vbm_update *vbm;
 	int ret;
 
-	wl1251_debug(DEBUG_CMD, "cmd vbm");
+	wl1251_debug(DEBUG_CMD, "cmd vbm\n");
 
 	vbm = kzalloc(sizeof(*vbm), GFP_KERNEL);
 	if (!vbm) {
@@ -182,8 +182,8 @@ int wl1251_cmd_vbm(struct wl1251 *wl, u8 identity,
 	/* Count and period will be filled by the target */
 	vbm->tim.bitmap_ctrl = bitmap_control;
 	if (bitmap_len > PARTIAL_VBM_MAX) {
-		wl1251_warning("cmd vbm len is %d B, truncating to %d",
-			       bitmap_len, PARTIAL_VBM_MAX);
+		wl1251_warn("cmd vbm len is %d B, truncating to %d\n",
+			    bitmap_len, PARTIAL_VBM_MAX);
 		bitmap_len = PARTIAL_VBM_MAX;
 	}
 	memcpy(vbm->tim.pvb_field, bitmap, bitmap_len);
@@ -194,7 +194,7 @@ int wl1251_cmd_vbm(struct wl1251 *wl, u8 identity,
 
 	ret = wl1251_cmd_send(wl, CMD_VBM, vbm, sizeof(*vbm));
 	if (ret < 0) {
-		wl1251_error("VBM command failed");
+		wl1251_err("VBM command failed\n");
 		goto out;
 	}
 
@@ -209,7 +209,7 @@ int wl1251_cmd_data_path(struct wl1251 *wl, u8 channel, bool enable)
 	int ret;
 	u16 cmd_rx, cmd_tx;
 
-	wl1251_debug(DEBUG_CMD, "cmd data path");
+	wl1251_debug(DEBUG_CMD, "cmd data path\n");
 
 	cmd = kzalloc(sizeof(*cmd), GFP_KERNEL);
 	if (!cmd) {
@@ -229,22 +229,22 @@ int wl1251_cmd_data_path(struct wl1251 *wl, u8 channel, bool enable)
 
 	ret = wl1251_cmd_send(wl, cmd_rx, cmd, sizeof(*cmd));
 	if (ret < 0) {
-		wl1251_error("rx %s cmd for channel %d failed",
-			     enable ? "start" : "stop", channel);
+		wl1251_err("rx %s cmd for channel %d failed\n",
+			   enable ? "start" : "stop", channel);
 		goto out;
 	}
 
-	wl1251_debug(DEBUG_BOOT, "rx %s cmd channel %d",
+	wl1251_debug(DEBUG_BOOT, "rx %s cmd channel %d\n",
 		     enable ? "start" : "stop", channel);
 
 	ret = wl1251_cmd_send(wl, cmd_tx, cmd, sizeof(*cmd));
 	if (ret < 0) {
-		wl1251_error("tx %s cmd for channel %d failed",
-			     enable ? "start" : "stop", channel);
+		wl1251_err("tx %s cmd for channel %d failed\n",
+			   enable ? "start" : "stop", channel);
 		goto out;
 	}
 
-	wl1251_debug(DEBUG_BOOT, "tx %s cmd channel %d",
+	wl1251_debug(DEBUG_BOOT, "tx %s cmd channel %d\n",
 		     enable ? "start" : "stop", channel);
 
 out:
@@ -265,7 +265,7 @@ int wl1251_cmd_join(struct wl1251 *wl, u8 bss_type, u8 channel,
 		goto out;
 	}
 
-	wl1251_debug(DEBUG_CMD, "cmd join%s ch %d %d/%d",
+	wl1251_debug(DEBUG_CMD, "cmd join%s ch %d %d/%d\n",
 		     bss_type == BSS_TYPE_IBSS ? " ibss" : "",
 		     channel, beacon_interval, dtim_interval);
 
@@ -297,7 +297,7 @@ int wl1251_cmd_join(struct wl1251 *wl, u8 bss_type, u8 channel,
 
 	ret = wl1251_cmd_send(wl, CMD_START_JOIN, join, sizeof(*join));
 	if (ret < 0) {
-		wl1251_error("failed to initiate cmd join");
+		wl1251_err("failed to initiate cmd join\n");
 		goto out;
 	}
 
@@ -311,7 +311,7 @@ int wl1251_cmd_ps_mode(struct wl1251 *wl, u8 ps_mode)
 	struct wl1251_cmd_ps_params *ps_params = NULL;
 	int ret = 0;
 
-	wl1251_debug(DEBUG_CMD, "cmd set ps mode");
+	wl1251_debug(DEBUG_CMD, "cmd set ps mode\n");
 
 	ps_params = kzalloc(sizeof(*ps_params), GFP_KERNEL);
 	if (!ps_params) {
@@ -328,7 +328,7 @@ int wl1251_cmd_ps_mode(struct wl1251 *wl, u8 ps_mode)
 	ret = wl1251_cmd_send(wl, CMD_SET_PS_MODE, ps_params,
 			      sizeof(*ps_params));
 	if (ret < 0) {
-		wl1251_error("cmd set_ps_mode failed");
+		wl1251_err("cmd set_ps_mode failed\n");
 		goto out;
 	}
 
@@ -343,7 +343,7 @@ int wl1251_cmd_read_memory(struct wl1251 *wl, u32 addr, void *answer,
 	struct cmd_read_write_memory *cmd;
 	int ret = 0;
 
-	wl1251_debug(DEBUG_CMD, "cmd read memory");
+	wl1251_debug(DEBUG_CMD, "cmd read memory\n");
 
 	cmd = kzalloc(sizeof(*cmd), GFP_KERNEL);
 	if (!cmd) {
@@ -359,7 +359,7 @@ int wl1251_cmd_read_memory(struct wl1251 *wl, u32 addr, void *answer,
 
 	ret = wl1251_cmd_send(wl, CMD_READ_MEMORY, cmd, sizeof(*cmd));
 	if (ret < 0) {
-		wl1251_error("read memory command failed: %d", ret);
+		wl1251_err("read memory command failed: %d\n", ret);
 		goto out;
 	}
 
@@ -367,8 +367,8 @@ int wl1251_cmd_read_memory(struct wl1251 *wl, u32 addr, void *answer,
 	wl1251_mem_read(wl, wl->cmd_box_addr, cmd, sizeof(*cmd));
 
 	if (cmd->header.status != CMD_STATUS_SUCCESS)
-		wl1251_error("error in read command result: %d",
-			     cmd->header.status);
+		wl1251_err("error in read command result: %d\n",
+			   cmd->header.status);
 
 	memcpy(answer, cmd->value, len);
 
@@ -384,7 +384,7 @@ int wl1251_cmd_template_set(struct wl1251 *wl, u16 cmd_id,
 	size_t cmd_len;
 	int ret = 0;
 
-	wl1251_debug(DEBUG_CMD, "cmd template %d", cmd_id);
+	wl1251_debug(DEBUG_CMD, "cmd template %d\n", cmd_id);
 
 	WARN_ON(buf_len > WL1251_MAX_TEMPLATE_SIZE);
 	buf_len = min_t(size_t, buf_len, WL1251_MAX_TEMPLATE_SIZE);
@@ -403,7 +403,7 @@ int wl1251_cmd_template_set(struct wl1251 *wl, u16 cmd_id,
 
 	ret = wl1251_cmd_send(wl, cmd_id, cmd, cmd_len);
 	if (ret < 0) {
-		wl1251_warning("cmd set_template failed: %d", ret);
+		wl1251_warn("cmd set_template failed: %d\n", ret);
 		goto out;
 	}
 
@@ -419,7 +419,7 @@ int wl1251_cmd_scan(struct wl1251 *wl, u8 *ssid, size_t ssid_len,
 	struct wl1251_cmd_scan *cmd;
 	int i, ret = 0;
 
-	wl1251_debug(DEBUG_CMD, "cmd scan");
+	wl1251_debug(DEBUG_CMD, "cmd scan\n");
 
 	cmd = kzalloc(sizeof(*cmd), GFP_KERNEL);
 	if (!cmd)
@@ -453,15 +453,15 @@ int wl1251_cmd_scan(struct wl1251 *wl, u8 *ssid, size_t ssid_len,
 
 	ret = wl1251_cmd_send(wl, CMD_SCAN, cmd, sizeof(*cmd));
 	if (ret < 0) {
-		wl1251_error("cmd scan failed: %d", ret);
+		wl1251_err("cmd scan failed: %d\n", ret);
 		goto out;
 	}
 
 	wl1251_mem_read(wl, wl->cmd_box_addr, cmd, sizeof(*cmd));
 
 	if (cmd->header.status != CMD_STATUS_SUCCESS) {
-		wl1251_error("cmd scan status wasn't success: %d",
-			     cmd->header.status);
+		wl1251_err("cmd scan status wasn't success: %d\n",
+			   cmd->header.status);
 		ret = -EIO;
 		goto out;
 	}
@@ -476,7 +476,7 @@ int wl1251_cmd_trigger_scan_to(struct wl1251 *wl, u32 timeout)
 	struct wl1251_cmd_trigger_scan_to *cmd;
 	int ret;
 
-	wl1251_debug(DEBUG_CMD, "cmd trigger scan to");
+	wl1251_debug(DEBUG_CMD, "cmd trigger scan to\n");
 
 	cmd = kzalloc(sizeof(*cmd), GFP_KERNEL);
 	if (!cmd)
@@ -486,7 +486,7 @@ int wl1251_cmd_trigger_scan_to(struct wl1251 *wl, u32 timeout)
 
 	ret = wl1251_cmd_send(wl, CMD_TRIGGER_SCAN_TO, cmd, sizeof(*cmd));
 	if (ret < 0) {
-		wl1251_error("cmd trigger scan to failed: %d", ret);
+		wl1251_err("cmd trigger scan to failed: %d\n", ret);
 		goto out;
 	}
 
diff --git a/drivers/net/wireless/ti/wl1251/init.c b/drivers/net/wireless/ti/wl1251/init.c
index 89b43d3..2cdab26 100644
--- a/drivers/net/wireless/ti/wl1251/init.c
+++ b/drivers/net/wireless/ti/wl1251/init.c
@@ -35,13 +35,13 @@ int wl1251_hw_init_hwenc_config(struct wl1251 *wl)
 
 	ret = wl1251_acx_feature_cfg(wl);
 	if (ret < 0) {
-		wl1251_warning("couldn't set feature config");
+		wl1251_warn("couldn't set feature config\n");
 		return ret;
 	}
 
 	ret = wl1251_acx_default_key(wl, wl->default_key);
 	if (ret < 0) {
-		wl1251_warning("couldn't set default key");
+		wl1251_warn("couldn't set default key\n");
 		return ret;
 	}
 
@@ -211,7 +211,7 @@ int wl1251_hw_init_mem_config(struct wl1251 *wl)
 	wl->target_mem_map = kzalloc(sizeof(struct wl1251_acx_mem_map),
 					  GFP_KERNEL);
 	if (!wl->target_mem_map) {
-		wl1251_error("couldn't allocate target memory map");
+		wl1251_err("couldn't allocate target memory map\n");
 		return -ENOMEM;
 	}
 
@@ -219,7 +219,7 @@ int wl1251_hw_init_mem_config(struct wl1251 *wl)
 	ret = wl1251_acx_mem_map(wl, wl->target_mem_map,
 				 sizeof(struct wl1251_acx_mem_map));
 	if (ret < 0) {
-		wl1251_error("couldn't retrieve firmware memory map");
+		wl1251_err("couldn't retrieve firmware memory map\n");
 		kfree(wl->target_mem_map);
 		wl->target_mem_map = NULL;
 		return ret;
@@ -260,7 +260,7 @@ static int wl1251_hw_init_txq_fill(u8 qid,
 			(QOS_TX_LOW_VO_DEF * num_blocks) / 100;
 		break;
 	default:
-		wl1251_error("Invalid TX queue id: %d", qid);
+		wl1251_err("Invalid TX queue id: %d\n", qid);
 		return -EINVAL;
 	}
 
@@ -273,7 +273,7 @@ static int wl1251_hw_init_tx_queue_config(struct wl1251 *wl)
 	struct wl1251_acx_mem_map *wl_mem_map = wl->target_mem_map;
 	int ret, i;
 
-	wl1251_debug(DEBUG_ACX, "acx tx queue config");
+	wl1251_debug(DEBUG_ACX, "acx tx queue config\n");
 
 	config = kzalloc(sizeof(*config), GFP_KERNEL);
 	if (!config) {
@@ -311,7 +311,7 @@ static int wl1251_hw_init_data_path_config(struct wl1251 *wl)
 	wl->data_path = kzalloc(sizeof(struct acx_data_path_params_resp),
 				GFP_KERNEL);
 	if (!wl->data_path) {
-		wl1251_error("Couldnt allocate data path parameters");
+		wl1251_err("Couldnt allocate data path parameters\n");
 		return -ENOMEM;
 	}
 
@@ -405,7 +405,7 @@ int wl1251_hw_init(struct wl1251 *wl)
 		goto out_free_data_path;
 
 	wl_mem_map = wl->target_mem_map;
-	wl1251_info("%d tx blocks at 0x%x, %d rx blocks at 0x%x",
+	wl1251_info("%d tx blocks at 0x%x, %d rx blocks at 0x%x\n",
 		    wl_mem_map->num_tx_mem_blocks,
 		    wl->data_path->tx_control_addr,
 		    wl_mem_map->num_rx_mem_blocks,
diff --git a/drivers/net/wireless/ti/wl1251/io.c b/drivers/net/wireless/ti/wl1251/io.c
index cdcadbf..2561ac2 100644
--- a/drivers/net/wireless/ti/wl1251/io.c
+++ b/drivers/net/wireless/ti/wl1251/io.c
@@ -46,7 +46,7 @@ static int wl1251_translate_reg_addr(struct wl1251 *wl, int addr)
 	if (addr < REGISTERS_BASE) {
 		/* Make sure we don't go over the table */
 		if (addr >= ACX_REG_TABLE_LEN) {
-			wl1251_error("address out of range (%d)", addr);
+			wl1251_err("address out of range (%d)\n", addr);
 			return -EINVAL;
 		}
 		addr = wl1251_io_reg_table[addr];
@@ -137,20 +137,19 @@ void wl1251_set_partition(struct wl1251 *wl,
 {
 	struct wl1251_partition partition[2];
 
-	wl1251_debug(DEBUG_SPI, "mem_start %08X mem_size %08X",
+	wl1251_debug(DEBUG_SPI, "mem_start %08X mem_size %08X\n",
 		     mem_start, mem_size);
-	wl1251_debug(DEBUG_SPI, "reg_start %08X reg_size %08X",
+	wl1251_debug(DEBUG_SPI, "reg_start %08X reg_size %08X\n",
 		     reg_start, reg_size);
 
 	/* Make sure that the two partitions together don't exceed the
 	 * address range */
 	if ((mem_size + reg_size) > HW_ACCESS_MEMORY_MAX_RANGE) {
-		wl1251_debug(DEBUG_SPI, "Total size exceeds maximum virtual"
-			     " address range.  Truncating partition[0].");
+		wl1251_debug(DEBUG_SPI, "Total size exceeds maximum virtual address range.  Truncating partition[0].\n");
 		mem_size = HW_ACCESS_MEMORY_MAX_RANGE - reg_size;
-		wl1251_debug(DEBUG_SPI, "mem_start %08X mem_size %08X",
+		wl1251_debug(DEBUG_SPI, "mem_start %08X mem_size %08X\n",
 			     mem_start, mem_size);
-		wl1251_debug(DEBUG_SPI, "reg_start %08X reg_size %08X",
+		wl1251_debug(DEBUG_SPI, "reg_start %08X reg_size %08X\n",
 			     reg_start, reg_size);
 	}
 
@@ -158,23 +157,21 @@ void wl1251_set_partition(struct wl1251 *wl,
 	    ((mem_start + mem_size) > reg_start)) {
 		/* Guarantee that the memory partition doesn't overlap the
 		 * registers partition */
-		wl1251_debug(DEBUG_SPI, "End of partition[0] is "
-			     "overlapping partition[1].  Adjusted.");
+		wl1251_debug(DEBUG_SPI, "End of partition[0] is overlapping partition[1].  Adjusted.\n");
 		mem_size = reg_start - mem_start;
-		wl1251_debug(DEBUG_SPI, "mem_start %08X mem_size %08X",
+		wl1251_debug(DEBUG_SPI, "mem_start %08X mem_size %08X\n",
 			     mem_start, mem_size);
-		wl1251_debug(DEBUG_SPI, "reg_start %08X reg_size %08X",
+		wl1251_debug(DEBUG_SPI, "reg_start %08X reg_size %08X\n",
 			     reg_start, reg_size);
 	} else if ((reg_start < mem_start) &&
 		   ((reg_start + reg_size) > mem_start)) {
 		/* Guarantee that the register partition doesn't overlap the
 		 * memory partition */
-		wl1251_debug(DEBUG_SPI, "End of partition[1] is"
-			     " overlapping partition[0].  Adjusted.");
+		wl1251_debug(DEBUG_SPI, "End of partition[1] is overlapping partition[0].  Adjusted.\n");
 		reg_size = mem_start - reg_start;
-		wl1251_debug(DEBUG_SPI, "mem_start %08X mem_size %08X",
+		wl1251_debug(DEBUG_SPI, "mem_start %08X mem_size %08X\n",
 			     mem_start, mem_size);
-		wl1251_debug(DEBUG_SPI, "reg_start %08X reg_size %08X",
+		wl1251_debug(DEBUG_SPI, "reg_start %08X reg_size %08X\n",
 			     reg_start, reg_size);
 	}
 
diff --git a/drivers/net/wireless/ti/wl1251/main.c b/drivers/net/wireless/ti/wl1251/main.c
index d1afb8e..47cb523 100644
--- a/drivers/net/wireless/ti/wl1251/main.c
+++ b/drivers/net/wireless/ti/wl1251/main.c
@@ -71,13 +71,13 @@ static int wl1251_fetch_firmware(struct wl1251 *wl)
 	ret = request_firmware(&fw, WL1251_FW_NAME, dev);
 
 	if (ret < 0) {
-		wl1251_error("could not get firmware: %d", ret);
+		wl1251_err("could not get firmware: %d\n", ret);
 		return ret;
 	}
 
 	if (fw->size % 4) {
-		wl1251_error("firmware size is not multiple of 32 bits: %zu",
-			     fw->size);
+		wl1251_err("firmware size is not multiple of 32 bits: %zu\n",
+			   fw->size);
 		ret = -EILSEQ;
 		goto out;
 	}
@@ -86,7 +86,7 @@ static int wl1251_fetch_firmware(struct wl1251 *wl)
 	wl->fw = vmalloc(wl->fw_len);
 
 	if (!wl->fw) {
-		wl1251_error("could not allocate memory for the firmware");
+		wl1251_err("could not allocate memory for the firmware\n");
 		ret = -ENOMEM;
 		goto out;
 	}
@@ -110,13 +110,13 @@ static int wl1251_fetch_nvs(struct wl1251 *wl)
 	ret = request_firmware(&fw, WL1251_NVS_NAME, dev);
 
 	if (ret < 0) {
-		wl1251_error("could not get nvs file: %d", ret);
+		wl1251_err("could not get nvs file: %d\n", ret);
 		return ret;
 	}
 
 	if (fw->size % 4) {
-		wl1251_error("nvs size is not multiple of 32 bits: %zu",
-			     fw->size);
+		wl1251_err("nvs size is not multiple of 32 bits: %zu\n",
+			   fw->size);
 		ret = -EILSEQ;
 		goto out;
 	}
@@ -125,7 +125,7 @@ static int wl1251_fetch_nvs(struct wl1251 *wl)
 	wl->nvs = kmemdup(fw->data, wl->nvs_len, GFP_KERNEL);
 
 	if (!wl->nvs) {
-		wl1251_error("could not allocate memory for the nvs file");
+		wl1251_err("could not allocate memory for the nvs file\n");
 		ret = -ENOMEM;
 		goto out;
 	}
@@ -147,7 +147,7 @@ static void wl1251_fw_wakeup(struct wl1251 *wl)
 	elp_reg = wl1251_read_elp(wl, HW_ACCESS_ELP_CTRL_REG_ADDR);
 
 	if (!(elp_reg & ELPCTRL_WLAN_READY))
-		wl1251_warning("WLAN not ready");
+		wl1251_warn("WLAN not ready\n");
 }
 
 static int wl1251_chip_wakeup(struct wl1251 *wl)
@@ -181,16 +181,16 @@ static int wl1251_chip_wakeup(struct wl1251 *wl)
 
 	switch (wl->chip_id) {
 	case CHIP_ID_1251_PG12:
-		wl1251_debug(DEBUG_BOOT, "chip id 0x%x (1251 PG12)",
+		wl1251_debug(DEBUG_BOOT, "chip id 0x%x (1251 PG12)\n",
 			     wl->chip_id);
 		break;
 	case CHIP_ID_1251_PG11:
-		wl1251_debug(DEBUG_BOOT, "chip id 0x%x (1251 PG11)",
+		wl1251_debug(DEBUG_BOOT, "chip id 0x%x (1251 PG11)\n",
 			     wl->chip_id);
 		break;
 	case CHIP_ID_1251_PG10:
 	default:
-		wl1251_error("unsupported chip id: 0x%x", wl->chip_id);
+		wl1251_err("unsupported chip id: 0x%x\n", wl->chip_id);
 		ret = -ENODEV;
 		goto out;
 	}
@@ -222,7 +222,7 @@ static void wl1251_irq_work(struct work_struct *work)
 
 	mutex_lock(&wl->mutex);
 
-	wl1251_debug(DEBUG_IRQ, "IRQ work");
+	wl1251_debug(DEBUG_IRQ, "IRQ work\n");
 
 	if (wl->state == WL1251_STATE_OFF)
 		goto out;
@@ -234,7 +234,7 @@ static void wl1251_irq_work(struct work_struct *work)
 	wl1251_reg_write32(wl, ACX_REG_INTERRUPT_MASK, WL1251_ACX_INTR_ALL);
 
 	intr = wl1251_reg_read32(wl, ACX_REG_INTERRUPT_CLEAR);
-	wl1251_debug(DEBUG_IRQ, "intr: 0x%x", intr);
+	wl1251_debug(DEBUG_IRQ, "intr: 0x%x\n", intr);
 
 	do {
 		if (wl->data_path) {
@@ -245,68 +245,67 @@ static void wl1251_irq_work(struct work_struct *work)
 			switch ((wl->rx_counter - wl->rx_handled) & 0xf) {
 			case 0:
 				wl1251_debug(DEBUG_IRQ,
-					     "RX: FW and host in sync");
+					     "RX: FW and host in sync\n");
 				intr &= ~WL1251_ACX_INTR_RX0_DATA;
 				intr &= ~WL1251_ACX_INTR_RX1_DATA;
 				break;
 			case 1:
-				wl1251_debug(DEBUG_IRQ, "RX: FW +1");
+				wl1251_debug(DEBUG_IRQ, "RX: FW +1\n");
 				intr |= WL1251_ACX_INTR_RX0_DATA;
 				intr &= ~WL1251_ACX_INTR_RX1_DATA;
 				break;
 			case 2:
-				wl1251_debug(DEBUG_IRQ, "RX: FW +2");
+				wl1251_debug(DEBUG_IRQ, "RX: FW +2\n");
 				intr |= WL1251_ACX_INTR_RX0_DATA;
 				intr |= WL1251_ACX_INTR_RX1_DATA;
 				break;
 			default:
-				wl1251_warning(
-					"RX: FW and host out of sync: %d",
-					wl->rx_counter - wl->rx_handled);
+				wl1251_warn("RX: FW and host out of sync: %d\n",
+					    wl->rx_counter - wl->rx_handled);
 				break;
 			}
 
 			wl->rx_handled = wl->rx_counter;
 
-			wl1251_debug(DEBUG_IRQ, "RX counter: %d",
+			wl1251_debug(DEBUG_IRQ, "RX counter: %d\n",
 				     wl->rx_counter);
 		}
 
 		intr &= wl->intr_mask;
 
 		if (intr == 0) {
-			wl1251_debug(DEBUG_IRQ, "INTR is 0");
+			wl1251_debug(DEBUG_IRQ, "INTR is 0\n");
 			goto out_sleep;
 		}
 
 		if (intr & WL1251_ACX_INTR_RX0_DATA) {
-			wl1251_debug(DEBUG_IRQ, "WL1251_ACX_INTR_RX0_DATA");
+			wl1251_debug(DEBUG_IRQ, "WL1251_ACX_INTR_RX0_DATA\n");
 			wl1251_rx(wl);
 		}
 
 		if (intr & WL1251_ACX_INTR_RX1_DATA) {
-			wl1251_debug(DEBUG_IRQ, "WL1251_ACX_INTR_RX1_DATA");
+			wl1251_debug(DEBUG_IRQ, "WL1251_ACX_INTR_RX1_DATA\n");
 			wl1251_rx(wl);
 		}
 
 		if (intr & WL1251_ACX_INTR_TX_RESULT) {
-			wl1251_debug(DEBUG_IRQ, "WL1251_ACX_INTR_TX_RESULT");
+			wl1251_debug(DEBUG_IRQ, "WL1251_ACX_INTR_TX_RESULT\n");
 			wl1251_tx_complete(wl);
 		}
 
 		if (intr & WL1251_ACX_INTR_EVENT_A) {
-			wl1251_debug(DEBUG_IRQ, "WL1251_ACX_INTR_EVENT_A");
+			wl1251_debug(DEBUG_IRQ, "WL1251_ACX_INTR_EVENT_A\n");
 			wl1251_event_handle(wl, 0);
 		}
 
 		if (intr & WL1251_ACX_INTR_EVENT_B) {
-			wl1251_debug(DEBUG_IRQ, "WL1251_ACX_INTR_EVENT_B");
+			wl1251_debug(DEBUG_IRQ, "WL1251_ACX_INTR_EVENT_B\n");
 			wl1251_event_handle(wl, 1);
 		}
 
 		if (intr & WL1251_ACX_INTR_INIT_COMPLETE)
 			wl1251_debug(DEBUG_IRQ,
-				     "WL1251_ACX_INTR_INIT_COMPLETE");
+				     "WL1251_ACX_INTR_INIT_COMPLETE\n");
 
 		if (--ctr == 0)
 			break;
@@ -342,7 +341,7 @@ static int wl1251_join(struct wl1251 *wl, u8 bss_type, u8 channel,
 
 	ret = wl1251_event_wait(wl, JOIN_EVENT_COMPLETE_ID, 100);
 	if (ret < 0)
-		wl1251_warning("join timeout");
+		wl1251_warn("join timeout\n");
 
 out:
 	return ret;
@@ -394,7 +393,7 @@ static void wl1251_op_tx(struct ieee80211_hw *hw, struct sk_buff *skb)
 	 * the queue here, otherwise the queue will get too long.
 	 */
 	if (skb_queue_len(&wl->tx_queue) >= WL1251_TX_QUEUE_HIGH_WATERMARK) {
-		wl1251_debug(DEBUG_TX, "op_tx: tx_queue full, stop queues");
+		wl1251_debug(DEBUG_TX, "op_tx: tx_queue full, stop queues\n");
 
 		spin_lock_irqsave(&wl->wl_lock, flags);
 		ieee80211_stop_queues(wl->hw);
@@ -414,8 +413,8 @@ static int wl1251_op_start(struct ieee80211_hw *hw)
 	mutex_lock(&wl->mutex);
 
 	if (wl->state != WL1251_STATE_OFF) {
-		wl1251_error("cannot start because not in off state: %d",
-			     wl->state);
+		wl1251_err("cannot start because not in off state: %d\n",
+			   wl->state);
 		ret = -EBUSY;
 		goto out;
 	}
@@ -438,7 +437,7 @@ static int wl1251_op_start(struct ieee80211_hw *hw)
 
 	wl->state = WL1251_STATE_ON;
 
-	wl1251_info("firmware booted (%s)", wl->fw_ver);
+	wl1251_info("firmware booted (%s)\n", wl->fw_ver);
 
 	/* update hw/fw version info in wiphy struct */
 	wiphy->hw_version = wl->chip_id;
@@ -457,7 +456,7 @@ static void wl1251_op_stop(struct ieee80211_hw *hw)
 {
 	struct wl1251 *wl = hw->priv;
 
-	wl1251_info("down");
+	wl1251_info("down\n");
 
 	wl1251_debug(DEBUG_MAC80211, "mac80211 stop");
 
@@ -615,7 +614,7 @@ static int wl1251_op_config(struct ieee80211_hw *hw, u32 changed)
 	}
 
 	if (conf->flags & IEEE80211_CONF_PS && !wl->psm_requested) {
-		wl1251_debug(DEBUG_PSM, "psm enabled");
+		wl1251_debug(DEBUG_PSM, "psm enabled\n");
 
 		wl->psm_requested = true;
 
@@ -632,7 +631,7 @@ static int wl1251_op_config(struct ieee80211_hw *hw, u32 changed)
 			goto out_sleep;
 	} else if (!(conf->flags & IEEE80211_CONF_PS) &&
 		   wl->psm_requested) {
-		wl1251_debug(DEBUG_PSM, "psm disabled");
+		wl1251_debug(DEBUG_PSM, "psm disabled\n");
 
 		wl->psm_requested = false;
 
@@ -765,7 +764,7 @@ static int wl1251_set_key_type(struct wl1251 *wl,
 		mac80211_key->flags |= IEEE80211_KEY_FLAG_GENERATE_IV;
 		break;
 	default:
-		wl1251_error("Unknown key cipher 0x%x", mac80211_key->cipher);
+		wl1251_err("Unknown key cipher 0x%x\n", mac80211_key->cipher);
 		return -EOPNOTSUPP;
 	}
 
@@ -795,9 +794,9 @@ static int wl1251_op_set_key(struct ieee80211_hw *hw, enum set_key_cmd cmd,
 
 	addr = sta ? sta->addr : bcast_addr;
 
-	wl1251_debug(DEBUG_CRYPT, "CMD: 0x%x", cmd);
+	wl1251_debug(DEBUG_CRYPT, "CMD: 0x%x\n", cmd);
 	wl1251_dump(DEBUG_CRYPT, "ADDR: ", addr, ETH_ALEN);
-	wl1251_debug(DEBUG_CRYPT, "Key: algo:0x%x, id:%d, len:%d flags 0x%x",
+	wl1251_debug(DEBUG_CRYPT, "Key: algo:0x%x, id:%d, len:%d flags 0x%x\n",
 		     key->cipher, key->keyidx, key->keylen, key->flags);
 	wl1251_dump(DEBUG_CRYPT, "KEY: ", key->key, key->keylen);
 
@@ -821,13 +820,13 @@ static int wl1251_op_set_key(struct ieee80211_hw *hw, enum set_key_cmd cmd,
 		wl_cmd->key_action = KEY_REMOVE;
 		break;
 	default:
-		wl1251_error("Unsupported key cmd 0x%x", cmd);
+		wl1251_err("Unsupported key cmd 0x%x\n", cmd);
 		break;
 	}
 
 	ret = wl1251_set_key_type(wl, wl_cmd, cmd, key, addr);
 	if (ret < 0) {
-		wl1251_error("Set KEY type failed");
+		wl1251_err("Set KEY type failed\n");
 		goto out_sleep;
 	}
 
@@ -858,7 +857,7 @@ static int wl1251_op_set_key(struct ieee80211_hw *hw, enum set_key_cmd cmd,
 
 	ret = wl1251_cmd_send(wl, CMD_SET_KEYS, wl_cmd, sizeof(*wl_cmd));
 	if (ret < 0) {
-		wl1251_warning("could not set keys");
+		wl1251_warn("could not set keys\n");
 		goto out_sleep;
 	}
 
@@ -894,7 +893,7 @@ static int wl1251_op_hw_scan(struct ieee80211_hw *hw,
 	mutex_lock(&wl->mutex);
 
 	if (wl->scanning) {
-		wl1251_debug(DEBUG_SCAN, "scan already in progress");
+		wl1251_debug(DEBUG_SCAN, "scan already in progress\n");
 		ret = -EINVAL;
 		goto out;
 	}
@@ -951,7 +950,7 @@ static int wl1251_op_set_rts_threshold(struct ieee80211_hw *hw, u32 value)
 
 	ret = wl1251_acx_rts_threshold(wl, (u16) value);
 	if (ret < 0)
-		wl1251_warning("wl1251_op_set_rts_threshold failed: %d", ret);
+		wl1251_warn("wl1251_op_set_rts_threshold failed: %d\n", ret);
 
 	wl1251_ps_elp_sleep(wl);
 
@@ -1043,7 +1042,7 @@ static void wl1251_op_bss_info_changed(struct ieee80211_hw *hw,
 		else
 			ret = wl1251_acx_slot(wl, SLOT_TIME_LONG);
 		if (ret < 0) {
-			wl1251_warning("Set slot time failed %d", ret);
+			wl1251_warn("Set slot time failed %d\n", ret);
 			goto out_sleep;
 		}
 	}
@@ -1061,7 +1060,7 @@ static void wl1251_op_bss_info_changed(struct ieee80211_hw *hw,
 		else
 			ret = wl1251_acx_cts_protect(wl, CTSPROTECT_DISABLE);
 		if (ret < 0) {
-			wl1251_warning("Set ctsprotect failed %d", ret);
+			wl1251_warn("Set ctsprotect failed %d\n", ret);
 			goto out_sleep;
 		}
 	}
@@ -1295,7 +1294,7 @@ static int wl1251_read_eeprom_mac(struct wl1251 *wl)
 
 	ret = wl1251_read_eeprom(wl, 0x1c, mac, sizeof(mac));
 	if (ret < 0) {
-		wl1251_warning("failed to read MAC address from EEPROM");
+		wl1251_warn("failed to read MAC address from EEPROM\n");
 		return ret;
 	}
 
@@ -1317,13 +1316,13 @@ static int wl1251_register_hw(struct wl1251 *wl)
 
 	ret = ieee80211_register_hw(wl->hw);
 	if (ret < 0) {
-		wl1251_error("unable to register mac80211 hw: %d", ret);
+		wl1251_err("unable to register mac80211 hw: %d\n", ret);
 		return ret;
 	}
 
 	wl->mac80211_registered = true;
 
-	wl1251_notice("loaded");
+	wl1251_notice("loaded\n");
 
 	return 0;
 }
@@ -1359,7 +1358,7 @@ int wl1251_init_ieee80211(struct wl1251 *wl)
 		goto out;
 
 	wl1251_debugfs_init(wl);
-	wl1251_notice("initialized");
+	wl1251_notice("initialized\n");
 
 	ret = 0;
 
@@ -1377,7 +1376,7 @@ struct ieee80211_hw *wl1251_alloc_hw(void)
 
 	hw = ieee80211_alloc_hw(sizeof(*wl), &wl1251_ops);
 	if (!hw) {
-		wl1251_error("could not alloc ieee80211_hw");
+		wl1251_err("could not alloc ieee80211_hw\n");
 		return ERR_PTR(-ENOMEM);
 	}
 
@@ -1435,7 +1434,7 @@ struct ieee80211_hw *wl1251_alloc_hw(void)
 
 	wl->rx_descriptor = kmalloc(sizeof(*wl->rx_descriptor), GFP_KERNEL);
 	if (!wl->rx_descriptor) {
-		wl1251_error("could not allocate memory for rx descriptor");
+		wl1251_err("could not allocate memory for rx descriptor\n");
 		ieee80211_free_hw(hw);
 		return ERR_PTR(-ENOMEM);
 	}
diff --git a/drivers/net/wireless/ti/wl1251/ps.c b/drivers/net/wireless/ti/wl1251/ps.c
index db719f7..f784d1e 100644
--- a/drivers/net/wireless/ti/wl1251/ps.c
+++ b/drivers/net/wireless/ti/wl1251/ps.c
@@ -35,14 +35,14 @@ void wl1251_elp_work(struct work_struct *work)
 	dwork = container_of(work, struct delayed_work, work);
 	wl = container_of(dwork, struct wl1251, elp_work);
 
-	wl1251_debug(DEBUG_PSM, "elp work");
+	wl1251_debug(DEBUG_PSM, "elp work\n");
 
 	mutex_lock(&wl->mutex);
 
 	if (wl->elp || wl->station_mode == STATION_ACTIVE_MODE)
 		goto out;
 
-	wl1251_debug(DEBUG_PSM, "chip to elp");
+	wl1251_debug(DEBUG_PSM, "chip to elp\n");
 	wl1251_write_elp(wl, HW_ACCESS_ELP_CTRL_REG_ADDR, ELPCTRL_SLEEP);
 	wl->elp = true;
 
@@ -74,7 +74,7 @@ int wl1251_ps_elp_wakeup(struct wl1251 *wl)
 	if (!wl->elp)
 		return 0;
 
-	wl1251_debug(DEBUG_PSM, "waking up chip from elp");
+	wl1251_debug(DEBUG_PSM, "waking up chip from elp\n");
 
 	start = jiffies;
 	timeout = jiffies + msecs_to_jiffies(WL1251_WAKEUP_TIMEOUT);
@@ -89,14 +89,14 @@ int wl1251_ps_elp_wakeup(struct wl1251 *wl)
 	 */
 	while (!(elp_reg & ELPCTRL_WLAN_READY)) {
 		if (time_after(jiffies, timeout)) {
-			wl1251_error("elp wakeup timeout");
+			wl1251_err("elp wakeup timeout\n");
 			return -ETIMEDOUT;
 		}
 		msleep(1);
 		elp_reg = wl1251_read_elp(wl, HW_ACCESS_ELP_CTRL_REG_ADDR);
 	}
 
-	wl1251_debug(DEBUG_PSM, "wakeup time: %u ms",
+	wl1251_debug(DEBUG_PSM, "wakeup time: %u ms\n",
 		     jiffies_to_msecs(jiffies - start));
 
 	wl->elp = false;
@@ -110,7 +110,7 @@ int wl1251_ps_set_mode(struct wl1251 *wl, enum wl1251_station_mode mode)
 
 	switch (mode) {
 	case STATION_POWER_SAVE_MODE:
-		wl1251_debug(DEBUG_PSM, "entering psm");
+		wl1251_debug(DEBUG_PSM, "entering psm\n");
 
 		/* enable beacon filtering */
 		ret = wl1251_acx_beacon_filter_opt(wl, true);
@@ -137,7 +137,7 @@ int wl1251_ps_set_mode(struct wl1251 *wl, enum wl1251_station_mode mode)
 			return ret;
 		break;
 	case STATION_IDLE:
-		wl1251_debug(DEBUG_PSM, "entering idle");
+		wl1251_debug(DEBUG_PSM, "entering idle\n");
 
 		ret = wl1251_acx_sleep_auth(wl, WL1251_PSM_ELP);
 		if (ret < 0)
@@ -149,7 +149,7 @@ int wl1251_ps_set_mode(struct wl1251 *wl, enum wl1251_station_mode mode)
 		break;
 	case STATION_ACTIVE_MODE:
 	default:
-		wl1251_debug(DEBUG_PSM, "leaving psm");
+		wl1251_debug(DEBUG_PSM, "leaving psm\n");
 
 		ret = wl1251_acx_sleep_auth(wl, WL1251_PSM_CAM);
 		if (ret < 0)
diff --git a/drivers/net/wireless/ti/wl1251/rx.c b/drivers/net/wireless/ti/wl1251/rx.c
index 6af3526..6ae6026 100644
--- a/drivers/net/wireless/ti/wl1251/rx.c
+++ b/drivers/net/wireless/ti/wl1251/rx.c
@@ -158,8 +158,8 @@ static void wl1251_rx_body(struct wl1251 *wl,
 	last_id_inc = (wl->rx_last_id + 1) % (RX_MAX_PACKET_ID + 1);
 
 	if (last_id_inc != curr_id) {
-		wl1251_warning("curr ID:%d, last ID inc:%d",
-			       curr_id, last_id_inc);
+		wl1251_warn("curr ID:%d, last ID inc:%d\n",
+			    curr_id, last_id_inc);
 		wl->rx_last_id = curr_id;
 	} else {
 		wl->rx_last_id = last_id_inc;
@@ -172,7 +172,7 @@ static void wl1251_rx_body(struct wl1251 *wl,
 
 	skb = __dev_alloc_skb(length, GFP_KERNEL);
 	if (!skb) {
-		wl1251_error("Couldn't allocate RX frame");
+		wl1251_err("Couldn't allocate RX frame\n");
 		return;
 	}
 
@@ -189,7 +189,7 @@ static void wl1251_rx_body(struct wl1251 *wl,
 
 	wl1251_rx_status(wl, desc, &status, beacon);
 
-	wl1251_debug(DEBUG_RX, "rx skb 0x%p: %d B %s", skb, skb->len,
+	wl1251_debug(DEBUG_RX, "rx skb 0x%p: %d B %s\n", skb, skb->len,
 		     beacon ? "beacon" : "");
 
 	memcpy(IEEE80211_SKB_RXCB(skb), &status, sizeof(status));
diff --git a/drivers/net/wireless/ti/wl1251/sdio.c b/drivers/net/wireless/ti/wl1251/sdio.c
index e2750a1..234e2d9 100644
--- a/drivers/net/wireless/ti/wl1251/sdio.c
+++ b/drivers/net/wireless/ti/wl1251/sdio.c
@@ -54,7 +54,7 @@ static void wl1251_sdio_interrupt(struct sdio_func *func)
 {
 	struct wl1251 *wl = sdio_get_drvdata(func);
 
-	wl1251_debug(DEBUG_IRQ, "IRQ");
+	wl1251_debug(DEBUG_IRQ, "IRQ\n");
 
 	/* FIXME should be synchronous for sdio */
 	ieee80211_queue_work(wl->hw, &wl->irq_work);
@@ -76,7 +76,7 @@ static void wl1251_sdio_read(struct wl1251 *wl, int addr,
 	sdio_claim_host(func);
 	ret = sdio_memcpy_fromio(func, buf, addr, len);
 	if (ret)
-		wl1251_error("sdio read failed (%d)", ret);
+		wl1251_err("sdio read failed (%d)\n", ret);
 	sdio_release_host(func);
 }
 
@@ -89,7 +89,7 @@ static void wl1251_sdio_write(struct wl1251 *wl, int addr,
 	sdio_claim_host(func);
 	ret = sdio_memcpy_toio(func, addr, buf, len);
 	if (ret)
-		wl1251_error("sdio write failed (%d)", ret);
+		wl1251_err("sdio write failed (%d)\n", ret);
 	sdio_release_host(func);
 }
 
@@ -110,7 +110,7 @@ static void wl1251_sdio_read_elp(struct wl1251 *wl, int addr, u32 *val)
 	sdio_release_host(func);
 
 	if (ret)
-		wl1251_error("sdio_readb failed (%d)", ret);
+		wl1251_err("sdio_readb failed (%d)\n", ret);
 }
 
 static void wl1251_sdio_write_elp(struct wl1251 *wl, int addr, u32 val)
@@ -124,7 +124,7 @@ static void wl1251_sdio_write_elp(struct wl1251 *wl, int addr, u32 val)
 	sdio_release_host(func);
 
 	if (ret)
-		wl1251_error("sdio_writeb failed (%d)", ret);
+		wl1251_err("sdio_writeb failed (%d)\n", ret);
 	else
 		wl_sdio->elp_val = val;
 }
@@ -263,7 +263,7 @@ static int wl1251_sdio_probe(struct sdio_func *func,
 		irq_set_status_flags(wl->irq, IRQ_NOAUTOEN);
 		ret = request_irq(wl->irq, wl1251_line_irq, 0, "wl1251", wl);
 		if (ret < 0) {
-			wl1251_error("request_irq() failed: %d", ret);
+			wl1251_err("request_irq() failed: %d\n", ret);
 			goto disable;
 		}
 
@@ -272,12 +272,12 @@ static int wl1251_sdio_probe(struct sdio_func *func,
 		wl1251_sdio_ops.enable_irq = wl1251_enable_line_irq;
 		wl1251_sdio_ops.disable_irq = wl1251_disable_line_irq;
 
-		wl1251_info("using dedicated interrupt line");
+		wl1251_info("using dedicated interrupt line\n");
 	} else {
 		wl1251_sdio_ops.enable_irq = wl1251_sdio_enable_irq;
 		wl1251_sdio_ops.disable_irq = wl1251_sdio_disable_irq;
 
-		wl1251_info("using SDIO interrupt");
+		wl1251_info("using SDIO interrupt\n");
 	}
 
 	ret = wl1251_init_ieee80211(wl);
@@ -357,14 +357,14 @@ static int __init wl1251_sdio_init(void)
 
 	err = sdio_register_driver(&wl1251_sdio_driver);
 	if (err)
-		wl1251_error("failed to register sdio driver: %d", err);
+		wl1251_err("failed to register sdio driver: %d\n", err);
 	return err;
 }
 
 static void __exit wl1251_sdio_exit(void)
 {
 	sdio_unregister_driver(&wl1251_sdio_driver);
-	wl1251_notice("unloaded");
+	wl1251_notice("unloaded\n");
 }
 
 module_init(wl1251_sdio_init);
diff --git a/drivers/net/wireless/ti/wl1251/spi.c b/drivers/net/wireless/ti/wl1251/spi.c
index 87f6305..440443e 100644
--- a/drivers/net/wireless/ti/wl1251/spi.c
+++ b/drivers/net/wireless/ti/wl1251/spi.c
@@ -35,7 +35,7 @@ static irqreturn_t wl1251_irq(int irq, void *cookie)
 {
 	struct wl1251 *wl;
 
-	wl1251_debug(DEBUG_IRQ, "IRQ");
+	wl1251_debug(DEBUG_IRQ, "IRQ\n");
 
 	wl = cookie;
 
@@ -57,7 +57,7 @@ static void wl1251_spi_reset(struct wl1251 *wl)
 
 	cmd = kzalloc(WSPI_INIT_CMD_LEN, GFP_KERNEL);
 	if (!cmd) {
-		wl1251_error("could not allocate cmd for spi reset");
+		wl1251_err("could not allocate cmd for spi reset\n");
 		return;
 	}
 
@@ -83,7 +83,7 @@ static void wl1251_spi_wake(struct wl1251 *wl)
 
 	cmd = kzalloc(WSPI_INIT_CMD_LEN, GFP_KERNEL);
 	if (!cmd) {
-		wl1251_error("could not allocate cmd for spi init");
+		wl1251_err("could not allocate cmd for spi init\n");
 		return;
 	}
 
@@ -242,7 +242,7 @@ static int __devinit wl1251_spi_probe(struct spi_device *spi)
 
 	pdata = spi->dev.platform_data;
 	if (!pdata) {
-		wl1251_error("no platform data");
+		wl1251_err("no platform data\n");
 		return -ENODEV;
 	}
 
@@ -263,19 +263,19 @@ static int __devinit wl1251_spi_probe(struct spi_device *spi)
 
 	ret = spi_setup(spi);
 	if (ret < 0) {
-		wl1251_error("spi_setup failed");
+		wl1251_err("spi_setup failed\n");
 		goto out_free;
 	}
 
 	wl->set_power = pdata->set_power;
 	if (!wl->set_power) {
-		wl1251_error("set power function missing in platform data");
+		wl1251_err("set power function missing in platform data\n");
 		return -ENODEV;
 	}
 
 	wl->irq = spi->irq;
 	if (wl->irq < 0) {
-		wl1251_error("irq missing in platform data");
+		wl1251_err("irq missing in platform data\n");
 		return -ENODEV;
 	}
 
@@ -284,7 +284,7 @@ static int __devinit wl1251_spi_probe(struct spi_device *spi)
 	irq_set_status_flags(wl->irq, IRQ_NOAUTOEN);
 	ret = request_irq(wl->irq, wl1251_irq, 0, DRIVER_NAME, wl);
 	if (ret < 0) {
-		wl1251_error("request_irq() failed: %d", ret);
+		wl1251_err("request_irq() failed: %d\n", ret);
 		goto out_free;
 	}
 
@@ -331,7 +331,7 @@ static int __init wl1251_spi_init(void)
 
 	ret = spi_register_driver(&wl1251_spi_driver);
 	if (ret < 0) {
-		wl1251_error("failed to register spi driver: %d", ret);
+		wl1251_err("failed to register spi driver: %d\n", ret);
 		goto out;
 	}
 
@@ -343,7 +343,7 @@ static void __exit wl1251_spi_exit(void)
 {
 	spi_unregister_driver(&wl1251_spi_driver);
 
-	wl1251_notice("unloaded");
+	wl1251_notice("unloaded\n");
 }
 
 module_init(wl1251_spi_init);
diff --git a/drivers/net/wireless/ti/wl1251/tx.c b/drivers/net/wireless/ti/wl1251/tx.c
index 28121c5..2a5f586 100644
--- a/drivers/net/wireless/ti/wl1251/tx.c
+++ b/drivers/net/wireless/ti/wl1251/tx.c
@@ -210,7 +210,7 @@ static int wl1251_tx_send_packet(struct wl1251 *wl, struct sk_buff *skb,
 	*/
 	if (unlikely((long)skb->data & 0x03)) {
 		int offset = (4 - (long)skb->data) & 0x03;
-		wl1251_debug(DEBUG_TX, "skb offset %d", offset);
+		wl1251_debug(DEBUG_TX, "skb offset %d\n", offset);
 
 		/* check whether the current skb can be used */
 		if (skb_cloned(skb) || (skb_tailroom(skb) < offset)) {
@@ -218,7 +218,7 @@ static int wl1251_tx_send_packet(struct wl1251 *wl, struct sk_buff *skb,
 								 GFP_KERNEL);
 
 			if (unlikely(newskb == NULL)) {
-				wl1251_error("Can't allocate skb!");
+				wl1251_err("Can't allocate skb!\n");
 				return -EINVAL;
 			}
 
@@ -228,7 +228,7 @@ static int wl1251_tx_send_packet(struct wl1251 *wl, struct sk_buff *skb,
 			wl->tx_frames[tx_hdr->id] = skb = newskb;
 
 			offset = (4 - (long)skb->data) & 0x03;
-			wl1251_debug(DEBUG_TX, "new skb offset %d", offset);
+			wl1251_debug(DEBUG_TX, "new skb offset %d\n", offset);
 		}
 
 		/* align the buffer on a 4-byte boundary */
@@ -251,8 +251,8 @@ static int wl1251_tx_send_packet(struct wl1251 *wl, struct sk_buff *skb,
 
 	wl1251_mem_write(wl, addr, skb->data, len);
 
-	wl1251_debug(DEBUG_TX, "tx id %u skb 0x%p payload %u rate 0x%x "
-		     "queue %d", tx_hdr->id, skb, tx_hdr->length,
+	wl1251_debug(DEBUG_TX, "tx id %u skb 0x%p payload %u rate 0x%x queue %d\n",
+		     tx_hdr->id, skb, tx_hdr->length,
 		     tx_hdr->rate, tx_hdr->xmit_queue);
 
 	return 0;
@@ -387,7 +387,7 @@ static void wl1251_tx_packet_cb(struct wl1251 *wl,
 
 	skb = wl->tx_frames[result->id];
 	if (skb == NULL) {
-		wl1251_error("SKB for packet %d is NULL", result->id);
+		wl1251_err("SKB for packet %d is NULL\n", result->id);
 		return;
 	}
 
@@ -412,8 +412,7 @@ static void wl1251_tx_packet_cb(struct wl1251 *wl,
 		skb_pull(skb, WL1251_TKIP_IV_SPACE);
 	}
 
-	wl1251_debug(DEBUG_TX, "tx status id %u skb 0x%p failures %u rate 0x%x"
-		     " status 0x%x (%s)",
+	wl1251_debug(DEBUG_TX, "tx status id %u skb 0x%p failures %u rate 0x%x status 0x%x (%s)\n",
 		     result->id, skb, result->ack_failures, result->rate,
 		     result->status, wl1251_tx_parse_status(result->status));
 
@@ -461,14 +460,14 @@ void wl1251_tx_complete(struct wl1251 *wl)
 
 	if ((num_complete > 0) && (queue_len > 0)) {
 		/* firmware buffer has space, reschedule tx_work */
-		wl1251_debug(DEBUG_TX, "tx_complete: reschedule tx_work");
+		wl1251_debug(DEBUG_TX, "tx_complete: reschedule tx_work\n");
 		ieee80211_queue_work(wl->hw, &wl->tx_work);
 	}
 
 	if (wl->tx_queue_stopped &&
 	    queue_len <= WL1251_TX_QUEUE_LOW_WATERMARK) {
 		/* tx_queue has space, restart queues */
-		wl1251_debug(DEBUG_TX, "tx_complete: waking queues");
+		wl1251_debug(DEBUG_TX, "tx_complete: waking queues\n");
 		spin_lock_irqsave(&wl->wl_lock, flags);
 		ieee80211_wake_queues(wl->hw);
 		wl->tx_queue_stopped = false;
@@ -538,7 +537,7 @@ void wl1251_tx_flush(struct wl1251 *wl)
 	while ((skb = skb_dequeue(&wl->tx_queue))) {
 		info = IEEE80211_SKB_CB(skb);
 
-		wl1251_debug(DEBUG_TX, "flushing skb 0x%p", skb);
+		wl1251_debug(DEBUG_TX, "flushing skb 0x%p\n", skb);
 
 		if (!(info->flags & IEEE80211_TX_CTL_REQ_TX_STATUS))
 				continue;
diff --git a/drivers/net/wireless/ti/wl1251/wl1251.h b/drivers/net/wireless/ti/wl1251/wl1251.h
index 9d8f581..e4d0063 100644
--- a/drivers/net/wireless/ti/wl1251/wl1251.h
+++ b/drivers/net/wireless/ti/wl1251/wl1251.h
@@ -54,22 +54,22 @@ enum {
 
 #define DEBUG_DUMP_LIMIT 1024
 
-#define wl1251_error(fmt, arg...) \
-	printk(KERN_ERR DRIVER_PREFIX "ERROR " fmt "\n", ##arg)
+#define wl1251_err(fmt, arg...)				\
+	pr_err(DRIVER_PREFIX "ERROR " fmt, ##arg)
 
-#define wl1251_warning(fmt, arg...) \
-	printk(KERN_WARNING DRIVER_PREFIX "WARNING " fmt "\n", ##arg)
+#define wl1251_warn(fmt, arg...)				\
+	pr_warn(DRIVER_PREFIX "WARNING " fmt, ##arg)
 
-#define wl1251_notice(fmt, arg...) \
-	printk(KERN_INFO DRIVER_PREFIX fmt "\n", ##arg)
+#define wl1251_notice(fmt, arg...)		\
+	pr_info(DRIVER_PREFIX fmt, ##arg)
 
-#define wl1251_info(fmt, arg...) \
-	printk(KERN_DEBUG DRIVER_PREFIX fmt "\n", ##arg)
+#define wl1251_info(fmt, arg...)				\
+	printk(KERN_DEBUG DRIVER_PREFIX fmt, ##arg)
 
 #define wl1251_debug(level, fmt, arg...) \
-	do { \
+	do {				 \
 		if (level & DEBUG_LEVEL) \
-			printk(KERN_DEBUG DRIVER_PREFIX fmt "\n", ##arg); \
+			printk(KERN_DEBUG DRIVER_PREFIX fmt, ##arg); \
 	} while (0)
 
 #define wl1251_dump(level, prefix, buf, len)	\
diff --git a/drivers/net/wireless/ti/wl12xx/acx.c b/drivers/net/wireless/ti/wl12xx/acx.c
index bea06b2..77a1e21 100644
--- a/drivers/net/wireless/ti/wl12xx/acx.c
+++ b/drivers/net/wireless/ti/wl12xx/acx.c
@@ -42,7 +42,7 @@ int wl1271_acx_host_if_cfg_bitmap(struct wl1271 *wl, u32 host_cfg_bitmap)
 	ret = wl1271_cmd_configure(wl, ACX_HOST_IF_CFG_BITMAP,
 				   bitmap_conf, sizeof(*bitmap_conf));
 	if (ret < 0) {
-		wl1271_warning("wl1271 bitmap config opt failed: %d", ret);
+		wl1271_warn("wl1271 bitmap config opt failed: %d\n", ret);
 		goto out;
 	}
 
diff --git a/drivers/net/wireless/ti/wl12xx/cmd.c b/drivers/net/wireless/ti/wl12xx/cmd.c
index 50ba748..6bbc031 100644
--- a/drivers/net/wireless/ti/wl12xx/cmd.c
+++ b/drivers/net/wireless/ti/wl12xx/cmd.c
@@ -54,7 +54,7 @@ int wl1271_cmd_ext_radio_parms(struct wl1271 *wl)
 
 	ret = wl1271_cmd_test(wl, ext_radio_parms, sizeof(*ext_radio_parms), 0);
 	if (ret < 0)
-		wl1271_warning("TEST_CMD_INI_FILE_RF_EXTENDED_PARAM failed");
+		wl1271_warn("TEST_CMD_INI_FILE_RF_EXTENDED_PARAM failed\n");
 
 	kfree(ext_radio_parms);
 	return ret;
@@ -73,7 +73,7 @@ int wl1271_cmd_general_parms(struct wl1271 *wl)
 		return -ENODEV;
 
 	if (gp->tx_bip_fem_manufacturer >= WL1271_INI_FEM_MODULE_COUNT) {
-		wl1271_warning("FEM index from INI out of bounds");
+		wl1271_warn("FEM index from INI out of bounds\n");
 		return -EINVAL;
 	}
 
@@ -93,7 +93,7 @@ int wl1271_cmd_general_parms(struct wl1271 *wl)
 
 	ret = wl1271_cmd_test(wl, gen_parms, sizeof(*gen_parms), answer);
 	if (ret < 0) {
-		wl1271_warning("CMD_INI_FILE_GENERAL_PARAM failed");
+		wl1271_warn("CMD_INI_FILE_GENERAL_PARAM failed\n");
 		goto out;
 	}
 
@@ -101,7 +101,7 @@ int wl1271_cmd_general_parms(struct wl1271 *wl)
 		gen_parms->general_params.tx_bip_fem_manufacturer;
 
 	if (gp->tx_bip_fem_manufacturer >= WL1271_INI_FEM_MODULE_COUNT) {
-		wl1271_warning("FEM index from FW out of bounds");
+		wl1271_warn("FEM index from FW out of bounds\n");
 		ret = -EINVAL;
 		goto out;
 	}
@@ -127,7 +127,7 @@ int wl128x_cmd_general_parms(struct wl1271 *wl)
 		return -ENODEV;
 
 	if (gp->tx_bip_fem_manufacturer >= WL1271_INI_FEM_MODULE_COUNT) {
-		wl1271_warning("FEM index from ini out of bounds");
+		wl1271_warn("FEM index from ini out of bounds\n");
 		return -EINVAL;
 	}
 
@@ -148,7 +148,7 @@ int wl128x_cmd_general_parms(struct wl1271 *wl)
 
 	ret = wl1271_cmd_test(wl, gen_parms, sizeof(*gen_parms), answer);
 	if (ret < 0) {
-		wl1271_warning("CMD_INI_FILE_GENERAL_PARAM failed");
+		wl1271_warn("CMD_INI_FILE_GENERAL_PARAM failed\n");
 		goto out;
 	}
 
@@ -156,7 +156,7 @@ int wl128x_cmd_general_parms(struct wl1271 *wl)
 		gen_parms->general_params.tx_bip_fem_manufacturer;
 
 	if (gp->tx_bip_fem_manufacturer >= WL1271_INI_FEM_MODULE_COUNT) {
-		wl1271_warning("FEM index from FW out of bounds");
+		wl1271_warn("FEM index from FW out of bounds\n");
 		ret = -EINVAL;
 		goto out;
 	}
@@ -205,7 +205,7 @@ int wl1271_cmd_radio_parms(struct wl1271 *wl)
 
 	ret = wl1271_cmd_test(wl, radio_parms, sizeof(*radio_parms), 0);
 	if (ret < 0)
-		wl1271_warning("CMD_INI_FILE_RADIO_PARAM failed");
+		wl1271_warn("CMD_INI_FILE_RADIO_PARAM failed\n");
 
 	kfree(radio_parms);
 	return ret;
@@ -249,7 +249,7 @@ int wl128x_cmd_radio_parms(struct wl1271 *wl)
 
 	ret = wl1271_cmd_test(wl, radio_parms, sizeof(*radio_parms), 0);
 	if (ret < 0)
-		wl1271_warning("CMD_INI_FILE_RADIO_PARAM failed");
+		wl1271_warn("CMD_INI_FILE_RADIO_PARAM failed\n");
 
 	kfree(radio_parms);
 	return ret;
diff --git a/drivers/net/wireless/ti/wl12xx/main.c b/drivers/net/wireless/ti/wl12xx/main.c
index 85d1600..64c7fb7 100644
--- a/drivers/net/wireless/ti/wl12xx/main.c
+++ b/drivers/net/wireless/ti/wl12xx/main.c
@@ -626,8 +626,8 @@ static int wl12xx_identify_chip(struct wl1271 *wl)
 
 	switch (wl->chip.id) {
 	case CHIP_ID_1271_PG10:
-		wl1271_warning("chip id 0x%x (1271 PG10) support is obsolete",
-			       wl->chip.id);
+		wl1271_warn("chip id 0x%x (1271 PG10) support is obsolete\n",
+			    wl->chip.id);
 
 		wl->quirks |= WLCORE_QUIRK_LEGACY_NVS |
 			      WLCORE_QUIRK_TKIP_HEADER_SPACE;
@@ -642,7 +642,7 @@ static int wl12xx_identify_chip(struct wl1271 *wl)
 		break;
 
 	case CHIP_ID_1271_PG20:
-		wl1271_debug(DEBUG_BOOT, "chip id 0x%x (1271 PG20)",
+		wl1271_debug(DEBUG_BOOT, "chip id 0x%x (1271 PG20)\n",
 			     wl->chip.id);
 
 		wl->quirks |= WLCORE_QUIRK_LEGACY_NVS |
@@ -659,7 +659,7 @@ static int wl12xx_identify_chip(struct wl1271 *wl)
 		break;
 
 	case CHIP_ID_1283_PG20:
-		wl1271_debug(DEBUG_BOOT, "chip id 0x%x (1283 PG20)",
+		wl1271_debug(DEBUG_BOOT, "chip id 0x%x (1283 PG20)\n",
 			     wl->chip.id);
 		wl->plt_fw_name = WL128X_PLT_FW_NAME;
 		wl->sr_fw_name = WL128X_FW_NAME_SINGLE;
@@ -672,7 +672,7 @@ static int wl12xx_identify_chip(struct wl1271 *wl)
 		break;
 	case CHIP_ID_1283_PG10:
 	default:
-		wl1271_warning("unsupported chip id: 0x%x", wl->chip.id);
+		wl1271_warn("unsupported chip id: 0x%x\n", wl->chip.id);
 		ret = -ENODEV;
 		goto out;
 	}
@@ -712,7 +712,7 @@ static u16 wl12xx_top_reg_read(struct wl1271 *wl, int addr)
 	} while (!(val & OCP_READY_MASK) && --timeout);
 
 	if (!timeout) {
-		wl1271_warning("Top register access timed out.");
+		wl1271_warn("Top register access timed out\n");
 		return 0xffff;
 	}
 
@@ -720,7 +720,7 @@ static u16 wl12xx_top_reg_read(struct wl1271 *wl, int addr)
 	if ((val & OCP_STATUS_MASK) == OCP_STATUS_OK)
 		return val & 0xffff;
 	else {
-		wl1271_warning("Top register access returned error.");
+		wl1271_warn("Top register access returned error\n");
 		return 0xffff;
 	}
 }
@@ -906,7 +906,7 @@ static int wl127x_boot_clk(struct wl1271 *wl)
 
 	pause = wl1271_read32(wl, WL12XX_PLL_PARAMETERS);
 
-	wl1271_debug(DEBUG_BOOT, "pause1 0x%x", pause);
+	wl1271_debug(DEBUG_BOOT, "pause1 0x%x\n", pause);
 
 	pause &= ~(WU_COUNTER_PAUSE_VAL);
 	pause |= WU_COUNTER_PAUSE_VAL;
@@ -927,14 +927,15 @@ static int wl1271_boot_soft_reset(struct wl1271 *wl)
 	timeout = jiffies + usecs_to_jiffies(SOFT_RESET_MAX_TIME);
 	while (1) {
 		boot_data = wl1271_read32(wl, WL12XX_SLV_SOFT_RESET);
-		wl1271_debug(DEBUG_BOOT, "soft reset bootdata 0x%x", boot_data);
+		wl1271_debug(DEBUG_BOOT, "soft reset bootdata 0x%x\n",
+			     boot_data);
 		if ((boot_data & ACX_SLV_SOFT_RESET_BIT) == 0)
 			break;
 
 		if (time_after(jiffies, timeout)) {
 			/* 1.2 check pWhalBus->uSelfClearTime if the
 			 * timeout was reached */
-			wl1271_error("soft reset timeout");
+			wl1271_err("soft reset timeout\n");
 			return -1;
 		}
 
@@ -979,7 +980,7 @@ static int wl12xx_pre_boot(struct wl1271 *wl)
 
 	clk = wl1271_read32(wl, WL12XX_DRPW_SCRATCH_START);
 
-	wl1271_debug(DEBUG_BOOT, "clk2 0x%x", clk);
+	wl1271_debug(DEBUG_BOOT, "clk2 0x%x\n", clk);
 
 	if (wl->chip.id == CHIP_ID_1283_PG20)
 		clk |= ((selected_clock & 0x3) << 1) << 4;
@@ -1007,13 +1008,13 @@ static void wl12xx_pre_upload(struct wl1271 *wl)
 
 	/* write firmware's last address (ie. it's length) to
 	 * ACX_EEPROMLESS_IND_REG */
-	wl1271_debug(DEBUG_BOOT, "ACX_EEPROMLESS_IND_REG");
+	wl1271_debug(DEBUG_BOOT, "ACX_EEPROMLESS_IND_REG\n");
 
 	wl1271_write32(wl, WL12XX_EEPROMLESS_IND, WL12XX_EEPROMLESS_IND);
 
 	tmp = wlcore_read_reg(wl, REG_CHIP_ID_B);
 
-	wl1271_debug(DEBUG_BOOT, "chip id 0x%x", tmp);
+	wl1271_debug(DEBUG_BOOT, "chip id 0x%x\n", tmp);
 
 	/* 6. read the EEPROM parameters */
 	tmp = wl1271_read32(wl, WL12XX_SCR_PAD2);
@@ -1115,7 +1116,7 @@ wl12xx_set_tx_desc_data_len(struct wl1271 *wl, struct wl1271_tx_hw_descr *desc,
 		desc->length = cpu_to_le16(aligned_len >> 2);
 
 		wl1271_debug(DEBUG_TX,
-			     "tx_fill_hdr: hlid: %d len: %d life: %d mem: %d extra: %d",
+			     "tx_fill_hdr: hlid: %d len: %d life: %d mem: %d extra: %d\n",
 			     desc->hlid,
 			     le16_to_cpu(desc->length),
 			     le16_to_cpu(desc->life_time),
@@ -1131,7 +1132,7 @@ wl12xx_set_tx_desc_data_len(struct wl1271 *wl, struct wl1271_tx_hw_descr *desc,
 		desc->length = cpu_to_le16(aligned_len >> 2);
 
 		wl1271_debug(DEBUG_TX,
-			     "tx_fill_hdr: pad: %d hlid: %d len: %d life: %d mem: %d",
+			     "tx_fill_hdr: pad: %d hlid: %d len: %d life: %d mem: %d\n",
 			     pad, desc->hlid,
 			     le16_to_cpu(desc->length),
 			     le16_to_cpu(desc->life_time),
@@ -1262,7 +1263,7 @@ static bool wl12xx_mac_in_fuse(struct wl1271 *wl)
 	}
 
 	wl1271_debug(DEBUG_PROBE,
-		     "PG Ver major = %d minor = %d, MAC %s present",
+		     "PG Ver major = %d minor = %d, MAC %s present\n",
 		     major, minor, supported ? "is" : "is not");
 
 	return supported;
@@ -1432,7 +1433,7 @@ static int __devinit wl12xx_probe(struct platform_device *pdev)
 
 	hw = wlcore_alloc_hw(sizeof(*priv));
 	if (IS_ERR(hw)) {
-		wl1271_error("can't allocate hw");
+		wl1271_err("can't allocate hw\n");
 		return PTR_ERR(hw);
 	}
 
@@ -1470,7 +1471,7 @@ static int __devinit wl12xx_probe(struct platform_device *pdev)
 		else if (!strcmp(fref_param, "52"))
 			priv->ref_clock = WL12XX_REFCLOCK_52;
 		else
-			wl1271_error("Invalid fref parameter %s", fref_param);
+			wl1271_err("Invalid fref parameter %s\n", fref_param);
 	}
 
 	if (!tcxo_param) {
@@ -1493,7 +1494,7 @@ static int __devinit wl12xx_probe(struct platform_device *pdev)
 		else if (!strcmp(tcxo_param, "33.6"))
 			priv->tcxo_clock = WL12XX_TCXOCLOCK_33_6;
 		else
-			wl1271_error("Invalid tcxo parameter %s", tcxo_param);
+			wl1271_err("Invalid tcxo parameter %s\n", tcxo_param);
 	}
 
 	return wlcore_probe(wl, pdev);
diff --git a/drivers/net/wireless/ti/wl18xx/acx.c b/drivers/net/wireless/ti/wl18xx/acx.c
index 72840e2..355c3b9 100644
--- a/drivers/net/wireless/ti/wl18xx/acx.c
+++ b/drivers/net/wireless/ti/wl18xx/acx.c
@@ -32,7 +32,7 @@ int wl18xx_acx_host_if_cfg_bitmap(struct wl1271 *wl, u32 host_cfg_bitmap,
 	struct wl18xx_acx_host_config_bitmap *bitmap_conf;
 	int ret;
 
-	wl1271_debug(DEBUG_ACX, "acx cfg bitmap %d blk %d spare %d field %d",
+	wl1271_debug(DEBUG_ACX, "acx cfg bitmap %d blk %d spare %d field %d\n",
 		     host_cfg_bitmap, sdio_blk_size, extra_mem_blks,
 		     len_field_size);
 
@@ -50,7 +50,7 @@ int wl18xx_acx_host_if_cfg_bitmap(struct wl1271 *wl, u32 host_cfg_bitmap,
 	ret = wl1271_cmd_configure(wl, ACX_HOST_IF_CFG_BITMAP,
 				   bitmap_conf, sizeof(*bitmap_conf));
 	if (ret < 0) {
-		wl1271_warning("wl1271 bitmap config opt failed: %d", ret);
+		wl1271_warn("wl1271 bitmap config opt failed: %d\n", ret);
 		goto out;
 	}
 
@@ -65,7 +65,7 @@ int wl18xx_acx_set_checksum_state(struct wl1271 *wl)
 	struct wl18xx_acx_checksum_state *acx;
 	int ret;
 
-	wl1271_debug(DEBUG_ACX, "acx checksum state");
+	wl1271_debug(DEBUG_ACX, "acx checksum state\n");
 
 	acx = kzalloc(sizeof(*acx), GFP_KERNEL);
 	if (!acx) {
@@ -77,7 +77,7 @@ int wl18xx_acx_set_checksum_state(struct wl1271 *wl)
 
 	ret = wl1271_cmd_configure(wl, ACX_CHECKSUM_CONFIG, acx, sizeof(*acx));
 	if (ret < 0) {
-		wl1271_warning("failed to set Tx checksum state: %d", ret);
+		wl1271_warn("failed to set Tx checksum state: %d\n", ret);
 		goto out;
 	}
 
@@ -91,7 +91,7 @@ int wl18xx_acx_clear_statistics(struct wl1271 *wl)
 	struct wl18xx_acx_clear_statistics *acx;
 	int ret = 0;
 
-	wl1271_debug(DEBUG_ACX, "acx clear statistics");
+	wl1271_debug(DEBUG_ACX, "acx clear statistics\n");
 
 	acx = kzalloc(sizeof(*acx), GFP_KERNEL);
 	if (!acx) {
@@ -101,7 +101,7 @@ int wl18xx_acx_clear_statistics(struct wl1271 *wl)
 
 	ret = wl1271_cmd_configure(wl, ACX_CLEAR_STATISTICS, acx, sizeof(*acx));
 	if (ret < 0) {
-		wl1271_warning("failed to clear firmware statistics: %d", ret);
+		wl1271_warn("failed to clear firmware statistics: %d\n", ret);
 		goto out;
 	}
 
diff --git a/drivers/net/wireless/ti/wl18xx/main.c b/drivers/net/wireless/ti/wl18xx/main.c
index ed9c365..98118c3 100644
--- a/drivers/net/wireless/ti/wl18xx/main.c
+++ b/drivers/net/wireless/ti/wl18xx/main.c
@@ -599,8 +599,8 @@ static int wl18xx_identify_chip(struct wl1271 *wl)
 
 	switch (wl->chip.id) {
 	case CHIP_ID_185x_PG20:
-		wl1271_debug(DEBUG_BOOT, "chip id 0x%x (185x PG20)",
-				 wl->chip.id);
+		wl1271_debug(DEBUG_BOOT, "chip id 0x%x (185x PG20)\n",
+			     wl->chip.id);
 		wl->sr_fw_name = WL18XX_FW_NAME;
 		/* wl18xx uses the same firmware for PLT */
 		wl->plt_fw_name = WL18XX_FW_NAME;
@@ -610,7 +610,7 @@ static int wl18xx_identify_chip(struct wl1271 *wl)
 
 		break;
 	case CHIP_ID_185x_PG10:
-		wl1271_debug(DEBUG_BOOT, "chip id 0x%x (185x PG10)",
+		wl1271_debug(DEBUG_BOOT, "chip id 0x%x (185x PG10)\n",
 			     wl->chip.id);
 		wl->sr_fw_name = WL18XX_FW_NAME;
 		/* wl18xx uses the same firmware for PLT */
@@ -625,7 +625,7 @@ static int wl18xx_identify_chip(struct wl1271 *wl)
 
 		break;
 	default:
-		wl1271_warning("unsupported chip id: 0x%x", wl->chip.id);
+		wl1271_warn("unsupported chip id: 0x%x\n", wl->chip.id);
 		ret = -ENODEV;
 		goto out;
 	}
@@ -643,7 +643,8 @@ static void wl18xx_set_clk(struct wl1271 *wl)
 	/* TODO: PG2: apparently we need to read the clk type */
 
 	clk_freq = wl18xx_top_reg_read(wl, PRIMARY_CLK_DETECT);
-	wl1271_debug(DEBUG_BOOT, "clock freq %d (%d, %d, %d, %d, %s)", clk_freq,
+	wl1271_debug(DEBUG_BOOT, "clock freq %d (%d, %d, %d, %d, %s)\n",
+		     clk_freq,
 		     wl18xx_clk_table[clk_freq].n, wl18xx_clk_table[clk_freq].m,
 		     wl18xx_clk_table[clk_freq].p, wl18xx_clk_table[clk_freq].q,
 		     wl18xx_clk_table[clk_freq].swallow ? "swallow" : "spit");
@@ -713,7 +714,7 @@ static void wl18xx_pre_upload(struct wl1271 *wl)
 
 	tmp = wlcore_read_reg(wl, REG_CHIP_ID_B);
 
-	wl1271_debug(DEBUG_BOOT, "chip id 0x%x", tmp);
+	wl1271_debug(DEBUG_BOOT, "chip id 0x%x\n", tmp);
 
 	tmp = wl1271_read32(wl, WL18XX_SCR_PAD2);
 }
@@ -821,8 +822,8 @@ wl18xx_set_tx_desc_data_len(struct wl1271 *wl, struct wl1271_tx_hw_descr *desc,
 	else
 		desc->wl18xx_mem.ctrl = 0;
 
-	wl1271_debug(DEBUG_TX, "tx_fill_hdr: hlid: %d "
-		     "len: %d life: %d mem: %d", desc->hlid,
+	wl1271_debug(DEBUG_TX, "tx_fill_hdr: hlid: %d len: %d life: %d mem: %d\n",
+		     desc->hlid,
 		     le16_to_cpu(desc->length),
 		     le16_to_cpu(desc->life_time),
 		     desc->wl18xx_mem.total_mem_blocks);
@@ -954,7 +955,7 @@ static u32 wl18xx_sta_get_ap_rate_mask(struct wl1271 *wl,
 
 	if (wlvif->channel_type == NL80211_CHAN_HT40MINUS ||
 	    wlvif->channel_type == NL80211_CHAN_HT40PLUS) {
-		wl1271_debug(DEBUG_ACX, "using wide channel rate mask");
+		wl1271_debug(DEBUG_ACX, "using wide channel rate mask\n");
 		hw_rate_set |= CONF_TX_RATE_USE_WIDE_CHAN;
 
 		/* we don't support MIMO in wide-channel mode */
@@ -970,10 +971,10 @@ static u32 wl18xx_ap_get_mimo_wide_rate_mask(struct wl1271 *wl,
 	if ((wlvif->channel_type == NL80211_CHAN_HT40MINUS ||
 	     wlvif->channel_type == NL80211_CHAN_HT40PLUS) &&
 	    !strcmp(ht_mode_param, "wide")) {
-		wl1271_debug(DEBUG_ACX, "using wide channel rate mask");
+		wl1271_debug(DEBUG_ACX, "using wide channel rate mask\n");
 		return CONF_TX_RATE_USE_WIDE_CHAN;
 	} else if (!strcmp(ht_mode_param, "mimo")) {
-		wl1271_debug(DEBUG_ACX, "using MIMO rate mask");
+		wl1271_debug(DEBUG_ACX, "using MIMO rate mask\n");
 
 		/*
 		 * PG 1.0 has some problems with MCS_13, so disable it
@@ -1015,15 +1016,14 @@ static int wl18xx_conf_init(struct wl1271 *wl, struct device *dev)
 
 	ret = request_firmware(&fw, WL18XX_CONF_FILE_NAME, dev);
 	if (ret < 0) {
-		wl1271_error("could not get configuration binary %s: %d",
-			     WL18XX_CONF_FILE_NAME, ret);
+		wl1271_err("could not get configuration binary %s: %d\n",
+			   WL18XX_CONF_FILE_NAME, ret);
 		goto out_fallback;
 	}
 
 	if (fw->size != WL18XX_CONF_SIZE) {
-		wl1271_error("configuration binary file size is wrong, "
-			     "expected %ld got %zd",
-			     WL18XX_CONF_SIZE, fw->size);
+		wl1271_err("configuration binary file size is wrong, expected %ld got %zd\n",
+			   (unsigned long)WL18XX_CONF_SIZE, fw->size);
 		ret = -EINVAL;
 		goto out;
 	}
@@ -1031,17 +1031,16 @@ static int wl18xx_conf_init(struct wl1271 *wl, struct device *dev)
 	conf_file = (struct wlcore_conf_file *) fw->data;
 
 	if (conf_file->header.magic != cpu_to_le32(WL18XX_CONF_MAGIC)) {
-		wl1271_error("configuration binary file magic number mismatch, "
-			     "expected 0x%0x got 0x%0x", WL18XX_CONF_MAGIC,
-			     conf_file->header.magic);
+		wl1271_err("configuration binary file magic number mismatch, expected 0x%0x got 0x%0x\n",
+			   WL18XX_CONF_MAGIC,
+			   conf_file->header.magic);
 		ret = -EINVAL;
 		goto out;
 	}
 
 	if (conf_file->header.version != cpu_to_le32(WL18XX_CONF_VERSION)) {
-		wl1271_error("configuration binary file version not supported, "
-			     "expected 0x%08x got 0x%08x",
-			     WL18XX_CONF_VERSION, conf_file->header.version);
+		wl1271_err("configuration binary file version not supported, expected 0x%08x got 0x%08x\n",
+			   WL18XX_CONF_VERSION, conf_file->header.version);
 		ret = -EINVAL;
 		goto out;
 	}
@@ -1052,7 +1051,7 @@ static int wl18xx_conf_init(struct wl1271 *wl, struct device *dev)
 	goto out;
 
 out_fallback:
-	wl1271_warning("falling back to default config");
+	wl1271_warn("falling back to default config\n");
 
 	/* apply driver default configuration */
 	memcpy(&wl->conf, &wl18xx_conf, sizeof(wl18xx_conf));
@@ -1097,7 +1096,8 @@ static int wl18xx_handle_static_data(struct wl1271 *wl,
 	struct wl18xx_static_data_priv *static_data_priv =
 		(struct wl18xx_static_data_priv *) static_data->priv;
 
-	wl1271_info("PHY firmware version: %s", static_data_priv->phy_version);
+	wl1271_info("PHY firmware version: %s\n",
+		    static_data_priv->phy_version);
 
 	return 0;
 }
@@ -1275,7 +1275,7 @@ static int __devinit wl18xx_probe(struct platform_device *pdev)
 
 	hw = wlcore_alloc_hw(sizeof(*priv));
 	if (IS_ERR(hw)) {
-		wl1271_error("can't allocate hw");
+		wl1271_err("can't allocate hw\n");
 		ret = PTR_ERR(hw);
 		goto out;
 	}
@@ -1316,7 +1316,7 @@ static int __devinit wl18xx_probe(struct platform_device *pdev)
 		       &wl18xx_siso20_ht_cap,
 		       sizeof(wl18xx_siso20_ht_cap));
 	} else {
-		wl1271_error("invalid ht_mode '%s'", ht_mode_param);
+		wl1271_err("invalid ht_mode '%s'\n", ht_mode_param);
 		ret = -EINVAL;
 		goto out_free;
 	}
@@ -1340,7 +1340,7 @@ static int __devinit wl18xx_probe(struct platform_device *pdev)
 		/* HACK! Just for now we hardcode COM8 to 0x06 */
 		priv->conf.phy.low_band_component_type = 0x06;
 	} else {
-		wl1271_error("invalid board type '%s'", board_type_param);
+		wl1271_err("invalid board type '%s'\n", board_type_param);
 		ret = -EINVAL;
 		goto out_free;
 	}
diff --git a/drivers/net/wireless/ti/wl18xx/tx.c b/drivers/net/wireless/ti/wl18xx/tx.c
index 5b1fb10..aef7eae 100644
--- a/drivers/net/wireless/ti/wl18xx/tx.c
+++ b/drivers/net/wireless/ti/wl18xx/tx.c
@@ -37,7 +37,7 @@ static void wl18xx_tx_complete_packet(struct wl1271 *wl, u8 tx_stat_byte)
 
 	/* check for id legality */
 	if (unlikely(id >= wl->num_tx_desc || wl->tx_frames[id] == NULL)) {
-		wl1271_warning("illegal id in tx completion: %d", id);
+		wl1271_warn("illegal id in tx completion: %d\n", id);
 		return;
 	}
 
@@ -83,7 +83,7 @@ static void wl18xx_tx_complete_packet(struct wl1271 *wl, u8 tx_stat_byte)
 		skb_pull(skb, WL1271_EXTRA_SPACE_TKIP);
 	}
 
-	wl1271_debug(DEBUG_TX, "tx status id %u skb 0x%p success %d",
+	wl1271_debug(DEBUG_TX, "tx status id %u skb 0x%p success %d\n",
 		     id, skb, tx_success);
 
 	/* return the packet to the stack */
@@ -104,12 +104,12 @@ void wl18xx_tx_immediate_complete(struct wl1271 *wl)
 		return;
 
 	/* freed Tx descriptors */
-	wl1271_debug(DEBUG_TX, "last released desc = %d, current idx = %d",
+	wl1271_debug(DEBUG_TX, "last released desc = %d, current idx = %d\n",
 		     priv->last_fw_rls_idx, status_priv->fw_release_idx);
 
 	if (status_priv->fw_release_idx >= WL18XX_FW_MAX_TX_STATUS_DESC) {
-		wl1271_error("invalid desc release index %d",
-			     status_priv->fw_release_idx);
+		wl1271_err("invalid desc release index %d\n",
+			   status_priv->fw_release_idx);
 		WARN_ON(1);
 		return;
 	}
diff --git a/drivers/net/wireless/ti/wlcore/acx.c b/drivers/net/wireless/ti/wlcore/acx.c
index b9ec42c..55172d2 100644
--- a/drivers/net/wireless/ti/wlcore/acx.c
+++ b/drivers/net/wireless/ti/wlcore/acx.c
@@ -40,7 +40,7 @@ int wl1271_acx_wake_up_conditions(struct wl1271 *wl, struct wl12xx_vif *wlvif,
 	struct acx_wake_up_condition *wake_up;
 	int ret;
 
-	wl1271_debug(DEBUG_ACX, "acx wake up conditions (wake_up_event %d listen_interval %d)",
+	wl1271_debug(DEBUG_ACX, "acx wake up conditions (wake_up_event %d listen_interval %d)\n",
 		     wake_up_event, listen_interval);
 
 	wake_up = kzalloc(sizeof(*wake_up), GFP_KERNEL);
@@ -56,7 +56,7 @@ int wl1271_acx_wake_up_conditions(struct wl1271 *wl, struct wl12xx_vif *wlvif,
 	ret = wl1271_cmd_configure(wl, ACX_WAKE_UP_CONDITIONS,
 				   wake_up, sizeof(*wake_up));
 	if (ret < 0) {
-		wl1271_warning("could not set wake up conditions: %d", ret);
+		wl1271_warn("could not set wake up conditions: %d\n", ret);
 		goto out;
 	}
 
@@ -70,7 +70,7 @@ int wl1271_acx_sleep_auth(struct wl1271 *wl, u8 sleep_auth)
 	struct acx_sleep_auth *auth;
 	int ret;
 
-	wl1271_debug(DEBUG_ACX, "acx sleep auth");
+	wl1271_debug(DEBUG_ACX, "acx sleep auth\n");
 
 	auth = kzalloc(sizeof(*auth), GFP_KERNEL);
 	if (!auth) {
@@ -94,7 +94,7 @@ int wl1271_acx_tx_power(struct wl1271 *wl, struct wl12xx_vif *wlvif,
 	struct acx_current_tx_power *acx;
 	int ret;
 
-	wl1271_debug(DEBUG_ACX, "acx dot11_cur_tx_pwr %d", power);
+	wl1271_debug(DEBUG_ACX, "acx dot11_cur_tx_pwr %d\n", power);
 
 	if (power < 0 || power > 25)
 		return -EINVAL;
@@ -110,7 +110,7 @@ int wl1271_acx_tx_power(struct wl1271 *wl, struct wl12xx_vif *wlvif,
 
 	ret = wl1271_cmd_configure(wl, DOT11_CUR_TX_PWR, acx, sizeof(*acx));
 	if (ret < 0) {
-		wl1271_warning("configure of tx power failed: %d", ret);
+		wl1271_warn("configure of tx power failed: %d\n", ret);
 		goto out;
 	}
 
@@ -124,7 +124,7 @@ int wl1271_acx_feature_cfg(struct wl1271 *wl, struct wl12xx_vif *wlvif)
 	struct acx_feature_config *feature;
 	int ret;
 
-	wl1271_debug(DEBUG_ACX, "acx feature cfg");
+	wl1271_debug(DEBUG_ACX, "acx feature cfg\n");
 
 	feature = kzalloc(sizeof(*feature), GFP_KERNEL);
 	if (!feature) {
@@ -140,7 +140,7 @@ int wl1271_acx_feature_cfg(struct wl1271 *wl, struct wl12xx_vif *wlvif)
 	ret = wl1271_cmd_configure(wl, ACX_FEATURE_CFG,
 				   feature, sizeof(*feature));
 	if (ret < 0) {
-		wl1271_error("Couldnt set HW encryption");
+		wl1271_err("Couldnt set HW encryption\n");
 		goto out;
 	}
 
@@ -154,7 +154,7 @@ int wl1271_acx_mem_map(struct wl1271 *wl, struct acx_header *mem_map,
 {
 	int ret;
 
-	wl1271_debug(DEBUG_ACX, "acx mem map");
+	wl1271_debug(DEBUG_ACX, "acx mem map\n");
 
 	ret = wl1271_cmd_interrogate(wl, ACX_MEM_MAP, mem_map, len);
 	if (ret < 0)
@@ -168,7 +168,7 @@ int wl1271_acx_rx_msdu_life_time(struct wl1271 *wl)
 	struct acx_rx_msdu_lifetime *acx;
 	int ret;
 
-	wl1271_debug(DEBUG_ACX, "acx rx msdu life time");
+	wl1271_debug(DEBUG_ACX, "acx rx msdu life time\n");
 
 	acx = kzalloc(sizeof(*acx), GFP_KERNEL);
 	if (!acx) {
@@ -180,7 +180,7 @@ int wl1271_acx_rx_msdu_life_time(struct wl1271 *wl)
 	ret = wl1271_cmd_configure(wl, DOT11_RX_MSDU_LIFE_TIME,
 				   acx, sizeof(*acx));
 	if (ret < 0) {
-		wl1271_warning("failed to set rx msdu life time: %d", ret);
+		wl1271_warn("failed to set rx msdu life time: %d\n", ret);
 		goto out;
 	}
 
@@ -195,7 +195,7 @@ int wl1271_acx_slot(struct wl1271 *wl, struct wl12xx_vif *wlvif,
 	struct acx_slot *slot;
 	int ret;
 
-	wl1271_debug(DEBUG_ACX, "acx slot");
+	wl1271_debug(DEBUG_ACX, "acx slot\n");
 
 	slot = kzalloc(sizeof(*slot), GFP_KERNEL);
 	if (!slot) {
@@ -209,7 +209,7 @@ int wl1271_acx_slot(struct wl1271 *wl, struct wl12xx_vif *wlvif,
 
 	ret = wl1271_cmd_configure(wl, ACX_SLOT, slot, sizeof(*slot));
 	if (ret < 0) {
-		wl1271_warning("failed to set slot time: %d", ret);
+		wl1271_warn("failed to set slot time: %d\n", ret);
 		goto out;
 	}
 
@@ -224,7 +224,7 @@ int wl1271_acx_group_address_tbl(struct wl1271 *wl, struct wl12xx_vif *wlvif,
 	struct acx_dot11_grp_addr_tbl *acx;
 	int ret;
 
-	wl1271_debug(DEBUG_ACX, "acx group address tbl");
+	wl1271_debug(DEBUG_ACX, "acx group address tbl\n");
 
 	acx = kzalloc(sizeof(*acx), GFP_KERNEL);
 	if (!acx) {
@@ -241,7 +241,7 @@ int wl1271_acx_group_address_tbl(struct wl1271 *wl, struct wl12xx_vif *wlvif,
 	ret = wl1271_cmd_configure(wl, DOT11_GROUP_ADDRESS_TBL,
 				   acx, sizeof(*acx));
 	if (ret < 0) {
-		wl1271_warning("failed to set group addr table: %d", ret);
+		wl1271_warn("failed to set group addr table: %d\n", ret);
 		goto out;
 	}
 
@@ -262,7 +262,7 @@ int wl1271_acx_service_period_timeout(struct wl1271 *wl,
 		goto out;
 	}
 
-	wl1271_debug(DEBUG_ACX, "acx service period timeout");
+	wl1271_debug(DEBUG_ACX, "acx service period timeout\n");
 
 	rx_timeout->role_id = wlvif->role_id;
 	rx_timeout->ps_poll_timeout = cpu_to_le16(wl->conf.rx.ps_poll_timeout);
@@ -271,8 +271,8 @@ int wl1271_acx_service_period_timeout(struct wl1271 *wl,
 	ret = wl1271_cmd_configure(wl, ACX_SERVICE_PERIOD_TIMEOUT,
 				   rx_timeout, sizeof(*rx_timeout));
 	if (ret < 0) {
-		wl1271_warning("failed to set service period timeout: %d",
-			       ret);
+		wl1271_warn("failed to set service period timeout: %d\n",
+			    ret);
 		goto out;
 	}
 
@@ -294,7 +294,7 @@ int wl1271_acx_rts_threshold(struct wl1271 *wl, struct wl12xx_vif *wlvif,
 	if (rts_threshold > IEEE80211_MAX_RTS_THRESHOLD)
 		rts_threshold = wl->conf.rx.rts_threshold;
 
-	wl1271_debug(DEBUG_ACX, "acx rts threshold: %d", rts_threshold);
+	wl1271_debug(DEBUG_ACX, "acx rts threshold: %d\n", rts_threshold);
 
 	rts = kzalloc(sizeof(*rts), GFP_KERNEL);
 	if (!rts) {
@@ -307,7 +307,7 @@ int wl1271_acx_rts_threshold(struct wl1271 *wl, struct wl12xx_vif *wlvif,
 
 	ret = wl1271_cmd_configure(wl, DOT11_RTS_THRESHOLD, rts, sizeof(*rts));
 	if (ret < 0) {
-		wl1271_warning("failed to set rts threshold: %d", ret);
+		wl1271_warn("failed to set rts threshold: %d\n", ret);
 		goto out;
 	}
 
@@ -322,7 +322,7 @@ int wl1271_acx_dco_itrim_params(struct wl1271 *wl)
 	struct conf_itrim_settings *c = &wl->conf.itrim;
 	int ret;
 
-	wl1271_debug(DEBUG_ACX, "acx dco itrim parameters");
+	wl1271_debug(DEBUG_ACX, "acx dco itrim parameters\n");
 
 	dco = kzalloc(sizeof(*dco), GFP_KERNEL);
 	if (!dco) {
@@ -336,7 +336,7 @@ int wl1271_acx_dco_itrim_params(struct wl1271 *wl)
 	ret = wl1271_cmd_configure(wl, ACX_SET_DCO_ITRIM_PARAMS,
 				   dco, sizeof(*dco));
 	if (ret < 0) {
-		wl1271_warning("failed to set dco itrim parameters: %d", ret);
+		wl1271_warn("failed to set dco itrim parameters: %d\n", ret);
 		goto out;
 	}
 
@@ -351,7 +351,7 @@ int wl1271_acx_beacon_filter_opt(struct wl1271 *wl, struct wl12xx_vif *wlvif,
 	struct acx_beacon_filter_option *beacon_filter = NULL;
 	int ret = 0;
 
-	wl1271_debug(DEBUG_ACX, "acx beacon filter opt");
+	wl1271_debug(DEBUG_ACX, "acx beacon filter opt\n");
 
 	if (enable_filter &&
 	    wl->conf.conn.bcn_filt_mode == CONF_BCN_FILT_MODE_DISABLED)
@@ -375,7 +375,7 @@ int wl1271_acx_beacon_filter_opt(struct wl1271 *wl, struct wl12xx_vif *wlvif,
 	ret = wl1271_cmd_configure(wl, ACX_BEACON_FILTER_OPT,
 				   beacon_filter, sizeof(*beacon_filter));
 	if (ret < 0) {
-		wl1271_warning("failed to set beacon filter opt: %d", ret);
+		wl1271_warn("failed to set beacon filter opt: %d\n", ret);
 		goto out;
 	}
 
@@ -392,7 +392,7 @@ int wl1271_acx_beacon_filter_table(struct wl1271 *wl,
 	int ret;
 	bool vendor_spec = false;
 
-	wl1271_debug(DEBUG_ACX, "acx beacon filter table");
+	wl1271_debug(DEBUG_ACX, "acx beacon filter table\n");
 
 	ie_table = kzalloc(sizeof(*ie_table), GFP_KERNEL);
 	if (!ie_table) {
@@ -431,7 +431,7 @@ int wl1271_acx_beacon_filter_table(struct wl1271 *wl,
 	ret = wl1271_cmd_configure(wl, ACX_BEACON_FILTER_TABLE,
 				   ie_table, sizeof(*ie_table));
 	if (ret < 0) {
-		wl1271_warning("failed to set beacon filter table: %d", ret);
+		wl1271_warn("failed to set beacon filter table: %d\n", ret);
 		goto out;
 	}
 
@@ -450,7 +450,7 @@ int wl1271_acx_conn_monit_params(struct wl1271 *wl, struct wl12xx_vif *wlvif,
 	u32 timeout = ACX_CONN_MONIT_DISABLE_VALUE;
 	int ret;
 
-	wl1271_debug(DEBUG_ACX, "acx connection monitor parameters: %s",
+	wl1271_debug(DEBUG_ACX, "acx connection monitor parameters: %s\n",
 		     enable ? "enabled" : "disabled");
 
 	acx = kzalloc(sizeof(*acx), GFP_KERNEL);
@@ -471,8 +471,8 @@ int wl1271_acx_conn_monit_params(struct wl1271 *wl, struct wl12xx_vif *wlvif,
 	ret = wl1271_cmd_configure(wl, ACX_CONN_MONIT_PARAMS,
 				   acx, sizeof(*acx));
 	if (ret < 0) {
-		wl1271_warning("failed to set connection monitor "
-			       "parameters: %d", ret);
+		wl1271_warn("failed to set connection monitor parameters: %d\n",
+			    ret);
 		goto out;
 	}
 
@@ -487,7 +487,7 @@ int wl1271_acx_sg_enable(struct wl1271 *wl, bool enable)
 	struct acx_bt_wlan_coex *pta;
 	int ret;
 
-	wl1271_debug(DEBUG_ACX, "acx sg enable");
+	wl1271_debug(DEBUG_ACX, "acx sg enable\n");
 
 	pta = kzalloc(sizeof(*pta), GFP_KERNEL);
 	if (!pta) {
@@ -502,7 +502,7 @@ int wl1271_acx_sg_enable(struct wl1271 *wl, bool enable)
 
 	ret = wl1271_cmd_configure(wl, ACX_SG_ENABLE, pta, sizeof(*pta));
 	if (ret < 0) {
-		wl1271_warning("failed to set softgemini enable: %d", ret);
+		wl1271_warn("failed to set softgemini enable: %d\n", ret);
 		goto out;
 	}
 
@@ -517,7 +517,7 @@ int wl12xx_acx_sg_cfg(struct wl1271 *wl)
 	struct conf_sg_settings *c = &wl->conf.sg;
 	int i, ret;
 
-	wl1271_debug(DEBUG_ACX, "acx sg cfg");
+	wl1271_debug(DEBUG_ACX, "acx sg cfg\n");
 
 	param = kzalloc(sizeof(*param), GFP_KERNEL);
 	if (!param) {
@@ -532,7 +532,7 @@ int wl12xx_acx_sg_cfg(struct wl1271 *wl)
 
 	ret = wl1271_cmd_configure(wl, ACX_SG_CFG, param, sizeof(*param));
 	if (ret < 0) {
-		wl1271_warning("failed to set sg config: %d", ret);
+		wl1271_warn("failed to set sg config: %d\n", ret);
 		goto out;
 	}
 
@@ -546,7 +546,7 @@ int wl1271_acx_cca_threshold(struct wl1271 *wl)
 	struct acx_energy_detection *detection;
 	int ret;
 
-	wl1271_debug(DEBUG_ACX, "acx cca threshold");
+	wl1271_debug(DEBUG_ACX, "acx cca threshold\n");
 
 	detection = kzalloc(sizeof(*detection), GFP_KERNEL);
 	if (!detection) {
@@ -560,7 +560,7 @@ int wl1271_acx_cca_threshold(struct wl1271 *wl)
 	ret = wl1271_cmd_configure(wl, ACX_CCA_THRESHOLD,
 				   detection, sizeof(*detection));
 	if (ret < 0)
-		wl1271_warning("failed to set cca threshold: %d", ret);
+		wl1271_warn("failed to set cca threshold: %d\n", ret);
 
 out:
 	kfree(detection);
@@ -572,7 +572,7 @@ int wl1271_acx_bcn_dtim_options(struct wl1271 *wl, struct wl12xx_vif *wlvif)
 	struct acx_beacon_broadcast *bb;
 	int ret;
 
-	wl1271_debug(DEBUG_ACX, "acx bcn dtim options");
+	wl1271_debug(DEBUG_ACX, "acx bcn dtim options\n");
 
 	bb = kzalloc(sizeof(*bb), GFP_KERNEL);
 	if (!bb) {
@@ -588,7 +588,7 @@ int wl1271_acx_bcn_dtim_options(struct wl1271 *wl, struct wl12xx_vif *wlvif)
 
 	ret = wl1271_cmd_configure(wl, ACX_BCN_DTIM_OPTIONS, bb, sizeof(*bb));
 	if (ret < 0) {
-		wl1271_warning("failed to set rx config: %d", ret);
+		wl1271_warn("failed to set rx config: %d\n", ret);
 		goto out;
 	}
 
@@ -602,7 +602,7 @@ int wl1271_acx_aid(struct wl1271 *wl, struct wl12xx_vif *wlvif, u16 aid)
 	struct acx_aid *acx_aid;
 	int ret;
 
-	wl1271_debug(DEBUG_ACX, "acx aid");
+	wl1271_debug(DEBUG_ACX, "acx aid\n");
 
 	acx_aid = kzalloc(sizeof(*acx_aid), GFP_KERNEL);
 	if (!acx_aid) {
@@ -615,7 +615,7 @@ int wl1271_acx_aid(struct wl1271 *wl, struct wl12xx_vif *wlvif, u16 aid)
 
 	ret = wl1271_cmd_configure(wl, ACX_AID, acx_aid, sizeof(*acx_aid));
 	if (ret < 0) {
-		wl1271_warning("failed to set aid: %d", ret);
+		wl1271_warn("failed to set aid: %d\n", ret);
 		goto out;
 	}
 
@@ -629,7 +629,7 @@ int wl1271_acx_event_mbox_mask(struct wl1271 *wl, u32 event_mask)
 	struct acx_event_mask *mask;
 	int ret;
 
-	wl1271_debug(DEBUG_ACX, "acx event mbox mask");
+	wl1271_debug(DEBUG_ACX, "acx event mbox mask\n");
 
 	mask = kzalloc(sizeof(*mask), GFP_KERNEL);
 	if (!mask) {
@@ -644,7 +644,7 @@ int wl1271_acx_event_mbox_mask(struct wl1271 *wl, u32 event_mask)
 	ret = wl1271_cmd_configure(wl, ACX_EVENT_MBOX_MASK,
 				   mask, sizeof(*mask));
 	if (ret < 0) {
-		wl1271_warning("failed to set acx_event_mbox_mask: %d", ret);
+		wl1271_warn("failed to set acx_event_mbox_mask: %d\n", ret);
 		goto out;
 	}
 
@@ -659,7 +659,7 @@ int wl1271_acx_set_preamble(struct wl1271 *wl, struct wl12xx_vif *wlvif,
 	struct acx_preamble *acx;
 	int ret;
 
-	wl1271_debug(DEBUG_ACX, "acx_set_preamble");
+	wl1271_debug(DEBUG_ACX, "acx_set_preamble\n");
 
 	acx = kzalloc(sizeof(*acx), GFP_KERNEL);
 	if (!acx) {
@@ -672,7 +672,7 @@ int wl1271_acx_set_preamble(struct wl1271 *wl, struct wl12xx_vif *wlvif,
 
 	ret = wl1271_cmd_configure(wl, ACX_PREAMBLE_TYPE, acx, sizeof(*acx));
 	if (ret < 0) {
-		wl1271_warning("Setting of preamble failed: %d", ret);
+		wl1271_warn("Setting of preamble failed: %d\n", ret);
 		goto out;
 	}
 
@@ -687,7 +687,7 @@ int wl1271_acx_cts_protect(struct wl1271 *wl, struct wl12xx_vif *wlvif,
 	struct acx_ctsprotect *acx;
 	int ret;
 
-	wl1271_debug(DEBUG_ACX, "acx_set_ctsprotect");
+	wl1271_debug(DEBUG_ACX, "acx_set_ctsprotect\n");
 
 	acx = kzalloc(sizeof(*acx), GFP_KERNEL);
 	if (!acx) {
@@ -700,7 +700,7 @@ int wl1271_acx_cts_protect(struct wl1271 *wl, struct wl12xx_vif *wlvif,
 
 	ret = wl1271_cmd_configure(wl, ACX_CTS_PROTECTION, acx, sizeof(*acx));
 	if (ret < 0) {
-		wl1271_warning("Setting of ctsprotect failed: %d", ret);
+		wl1271_warn("Setting of ctsprotect failed: %d\n", ret);
 		goto out;
 	}
 
@@ -713,12 +713,12 @@ int wl1271_acx_statistics(struct wl1271 *wl, void *stats)
 {
 	int ret;
 
-	wl1271_debug(DEBUG_ACX, "acx statistics");
+	wl1271_debug(DEBUG_ACX, "acx statistics\n");
 
 	ret = wl1271_cmd_interrogate(wl, ACX_STATISTICS, stats,
 				     wl->stats.fw_stats_len);
 	if (ret < 0) {
-		wl1271_warning("acx statistics failed: %d", ret);
+		wl1271_warn("acx statistics failed: %d\n", ret);
 		return -ENOMEM;
 	}
 
@@ -731,7 +731,7 @@ int wl1271_acx_sta_rate_policies(struct wl1271 *wl, struct wl12xx_vif *wlvif)
 	struct conf_tx_rate_class *c = &wl->conf.tx.sta_rc_conf;
 	int ret = 0;
 
-	wl1271_debug(DEBUG_ACX, "acx rate policies");
+	wl1271_debug(DEBUG_ACX, "acx rate policies\n");
 
 	acx = kzalloc(sizeof(*acx), GFP_KERNEL);
 
@@ -740,8 +740,8 @@ int wl1271_acx_sta_rate_policies(struct wl1271 *wl, struct wl12xx_vif *wlvif)
 		goto out;
 	}
 
-	wl1271_debug(DEBUG_ACX, "basic_rate: 0x%x, full_rate: 0x%x",
-		wlvif->basic_rate, wlvif->rate_set);
+	wl1271_debug(DEBUG_ACX, "basic_rate: 0x%x, full_rate: 0x%x\n",
+		     wlvif->basic_rate, wlvif->rate_set);
 
 	/* configure one basic rate class */
 	acx->rate_policy_idx = cpu_to_le32(wlvif->sta.basic_rate_idx);
@@ -752,7 +752,7 @@ int wl1271_acx_sta_rate_policies(struct wl1271 *wl, struct wl12xx_vif *wlvif)
 
 	ret = wl1271_cmd_configure(wl, ACX_RATE_POLICY, acx, sizeof(*acx));
 	if (ret < 0) {
-		wl1271_warning("Setting of rate policies failed: %d", ret);
+		wl1271_warn("Setting of rate policies failed: %d\n", ret);
 		goto out;
 	}
 
@@ -768,7 +768,7 @@ int wl1271_acx_sta_rate_policies(struct wl1271 *wl, struct wl12xx_vif *wlvif)
 
 	ret = wl1271_cmd_configure(wl, ACX_RATE_POLICY, acx, sizeof(*acx));
 	if (ret < 0) {
-		wl1271_warning("Setting of rate policies failed: %d", ret);
+		wl1271_warn("Setting of rate policies failed: %d\n", ret);
 		goto out;
 	}
 
@@ -786,7 +786,7 @@ int wl1271_acx_sta_rate_policies(struct wl1271 *wl, struct wl12xx_vif *wlvif)
 
 	ret = wl1271_cmd_configure(wl, ACX_RATE_POLICY, acx, sizeof(*acx));
 	if (ret < 0) {
-		wl1271_warning("Setting of rate policies failed: %d", ret);
+		wl1271_warn("Setting of rate policies failed: %d\n", ret);
 		goto out;
 	}
 
@@ -801,7 +801,7 @@ int wl1271_acx_ap_rate_policy(struct wl1271 *wl, struct conf_tx_rate_class *c,
 	struct acx_rate_policy *acx;
 	int ret = 0;
 
-	wl1271_debug(DEBUG_ACX, "acx ap rate policy %d rates 0x%x",
+	wl1271_debug(DEBUG_ACX, "acx ap rate policy %d rates 0x%x\n",
 		     idx, c->enabled_rates);
 
 	acx = kzalloc(sizeof(*acx), GFP_KERNEL);
@@ -819,7 +819,7 @@ int wl1271_acx_ap_rate_policy(struct wl1271 *wl, struct conf_tx_rate_class *c,
 
 	ret = wl1271_cmd_configure(wl, ACX_RATE_POLICY, acx, sizeof(*acx));
 	if (ret < 0) {
-		wl1271_warning("Setting of ap rate policy failed: %d", ret);
+		wl1271_warn("Setting of ap rate policy failed: %d\n", ret);
 		goto out;
 	}
 
@@ -834,8 +834,8 @@ int wl1271_acx_ac_cfg(struct wl1271 *wl, struct wl12xx_vif *wlvif,
 	struct acx_ac_cfg *acx;
 	int ret = 0;
 
-	wl1271_debug(DEBUG_ACX, "acx ac cfg %d cw_ming %d cw_max %d "
-		     "aifs %d txop %d", ac, cw_min, cw_max, aifsn, txop);
+	wl1271_debug(DEBUG_ACX, "acx ac cfg %d cw_ming %d cw_max %d aifs %d txop %d\n",
+		     ac, cw_min, cw_max, aifsn, txop);
 
 	acx = kzalloc(sizeof(*acx), GFP_KERNEL);
 
@@ -853,7 +853,7 @@ int wl1271_acx_ac_cfg(struct wl1271 *wl, struct wl12xx_vif *wlvif,
 
 	ret = wl1271_cmd_configure(wl, ACX_AC_CFG, acx, sizeof(*acx));
 	if (ret < 0) {
-		wl1271_warning("acx ac cfg failed: %d", ret);
+		wl1271_warn("acx ac cfg failed: %d\n", ret);
 		goto out;
 	}
 
@@ -870,7 +870,7 @@ int wl1271_acx_tid_cfg(struct wl1271 *wl, struct wl12xx_vif *wlvif,
 	struct acx_tid_config *acx;
 	int ret = 0;
 
-	wl1271_debug(DEBUG_ACX, "acx tid config");
+	wl1271_debug(DEBUG_ACX, "acx tid config\n");
 
 	acx = kzalloc(sizeof(*acx), GFP_KERNEL);
 
@@ -890,7 +890,7 @@ int wl1271_acx_tid_cfg(struct wl1271 *wl, struct wl12xx_vif *wlvif,
 
 	ret = wl1271_cmd_configure(wl, ACX_TID_CFG, acx, sizeof(*acx));
 	if (ret < 0) {
-		wl1271_warning("Setting of tid config failed: %d", ret);
+		wl1271_warn("Setting of tid config failed: %d\n", ret);
 		goto out;
 	}
 
@@ -911,7 +911,7 @@ int wl1271_acx_frag_threshold(struct wl1271 *wl, u32 frag_threshold)
 	if (frag_threshold > IEEE80211_MAX_FRAG_THRESHOLD)
 		frag_threshold = wl->conf.tx.frag_threshold;
 
-	wl1271_debug(DEBUG_ACX, "acx frag threshold: %d", frag_threshold);
+	wl1271_debug(DEBUG_ACX, "acx frag threshold: %d\n", frag_threshold);
 
 	acx = kzalloc(sizeof(*acx), GFP_KERNEL);
 
@@ -923,7 +923,7 @@ int wl1271_acx_frag_threshold(struct wl1271 *wl, u32 frag_threshold)
 	acx->frag_threshold = cpu_to_le16((u16)frag_threshold);
 	ret = wl1271_cmd_configure(wl, ACX_FRAG_CFG, acx, sizeof(*acx));
 	if (ret < 0) {
-		wl1271_warning("Setting of frag threshold failed: %d", ret);
+		wl1271_warn("Setting of frag threshold failed: %d\n", ret);
 		goto out;
 	}
 
@@ -937,7 +937,7 @@ int wl1271_acx_tx_config_options(struct wl1271 *wl)
 	struct acx_tx_config_options *acx;
 	int ret = 0;
 
-	wl1271_debug(DEBUG_ACX, "acx tx config options");
+	wl1271_debug(DEBUG_ACX, "acx tx config options\n");
 
 	acx = kzalloc(sizeof(*acx), GFP_KERNEL);
 
@@ -950,7 +950,7 @@ int wl1271_acx_tx_config_options(struct wl1271 *wl)
 	acx->tx_compl_threshold = cpu_to_le16(wl->conf.tx.tx_compl_threshold);
 	ret = wl1271_cmd_configure(wl, ACX_TX_CONFIG_OPT, acx, sizeof(*acx));
 	if (ret < 0) {
-		wl1271_warning("Setting of tx options failed: %d", ret);
+		wl1271_warn("Setting of tx options failed: %d\n", ret);
 		goto out;
 	}
 
@@ -965,7 +965,7 @@ int wl12xx_acx_mem_cfg(struct wl1271 *wl)
 	struct conf_memory_settings *mem;
 	int ret;
 
-	wl1271_debug(DEBUG_ACX, "wl1271 mem cfg");
+	wl1271_debug(DEBUG_ACX, "wl1271 mem cfg\n");
 
 	mem_conf = kzalloc(sizeof(*mem_conf), GFP_KERNEL);
 	if (!mem_conf) {
@@ -990,7 +990,7 @@ int wl12xx_acx_mem_cfg(struct wl1271 *wl)
 	ret = wl1271_cmd_configure(wl, ACX_MEM_CFG, mem_conf,
 				   sizeof(*mem_conf));
 	if (ret < 0) {
-		wl1271_warning("wl1271 mem config failed: %d", ret);
+		wl1271_warn("wl1271 mem config failed: %d\n", ret);
 		goto out;
 	}
 
@@ -1007,7 +1007,7 @@ int wl1271_acx_init_mem_config(struct wl1271 *wl)
 	wl->target_mem_map = kzalloc(sizeof(struct wl1271_acx_mem_map),
 				     GFP_KERNEL);
 	if (!wl->target_mem_map) {
-		wl1271_error("couldn't allocate target memory map");
+		wl1271_err("couldn't allocate target memory map\n");
 		return -ENOMEM;
 	}
 
@@ -1015,7 +1015,7 @@ int wl1271_acx_init_mem_config(struct wl1271 *wl)
 	ret = wl1271_acx_mem_map(wl, (void *)wl->target_mem_map,
 				 sizeof(struct wl1271_acx_mem_map));
 	if (ret < 0) {
-		wl1271_error("couldn't retrieve firmware memory map");
+		wl1271_err("couldn't retrieve firmware memory map\n");
 		kfree(wl->target_mem_map);
 		wl->target_mem_map = NULL;
 		return ret;
@@ -1024,7 +1024,7 @@ int wl1271_acx_init_mem_config(struct wl1271 *wl)
 	/* initialize TX block book keeping */
 	wl->tx_blocks_available =
 		le32_to_cpu(wl->target_mem_map->num_tx_mem_blocks);
-	wl1271_debug(DEBUG_TX, "available tx blocks: %d",
+	wl1271_debug(DEBUG_TX, "available tx blocks: %d\n",
 		     wl->tx_blocks_available);
 
 	return 0;
@@ -1036,7 +1036,7 @@ int wl1271_acx_init_rx_interrupt(struct wl1271 *wl)
 	struct wl1271_acx_rx_config_opt *rx_conf;
 	int ret;
 
-	wl1271_debug(DEBUG_ACX, "wl1271 rx interrupt config");
+	wl1271_debug(DEBUG_ACX, "wl1271 rx interrupt config\n");
 
 	rx_conf = kzalloc(sizeof(*rx_conf), GFP_KERNEL);
 	if (!rx_conf) {
@@ -1052,7 +1052,7 @@ int wl1271_acx_init_rx_interrupt(struct wl1271 *wl)
 	ret = wl1271_cmd_configure(wl, ACX_RX_CONFIG_OPT, rx_conf,
 				   sizeof(*rx_conf));
 	if (ret < 0) {
-		wl1271_warning("wl1271 rx config opt failed: %d", ret);
+		wl1271_warn("wl1271 rx config opt failed: %d\n", ret);
 		goto out;
 	}
 
@@ -1067,7 +1067,7 @@ int wl1271_acx_bet_enable(struct wl1271 *wl, struct wl12xx_vif *wlvif,
 	struct wl1271_acx_bet_enable *acx = NULL;
 	int ret = 0;
 
-	wl1271_debug(DEBUG_ACX, "acx bet enable");
+	wl1271_debug(DEBUG_ACX, "acx bet enable\n");
 
 	if (enable && wl->conf.conn.bet_enable == CONF_BET_MODE_DISABLE)
 		goto out;
@@ -1084,7 +1084,7 @@ int wl1271_acx_bet_enable(struct wl1271 *wl, struct wl12xx_vif *wlvif,
 
 	ret = wl1271_cmd_configure(wl, ACX_BET_ENABLE, acx, sizeof(*acx));
 	if (ret < 0) {
-		wl1271_warning("acx bet enable failed: %d", ret);
+		wl1271_warn("acx bet enable failed: %d\n", ret);
 		goto out;
 	}
 
@@ -1099,7 +1099,7 @@ int wl1271_acx_arp_ip_filter(struct wl1271 *wl, struct wl12xx_vif *wlvif,
 	struct wl1271_acx_arp_filter *acx;
 	int ret;
 
-	wl1271_debug(DEBUG_ACX, "acx arp ip filter, enable: %d", enable);
+	wl1271_debug(DEBUG_ACX, "acx arp ip filter, enable: %d\n", enable);
 
 	acx = kzalloc(sizeof(*acx), GFP_KERNEL);
 	if (!acx) {
@@ -1117,7 +1117,7 @@ int wl1271_acx_arp_ip_filter(struct wl1271 *wl, struct wl12xx_vif *wlvif,
 	ret = wl1271_cmd_configure(wl, ACX_ARP_IP_FILTER,
 				   acx, sizeof(*acx));
 	if (ret < 0) {
-		wl1271_warning("failed to set arp ip filter: %d", ret);
+		wl1271_warn("failed to set arp ip filter: %d\n", ret);
 		goto out;
 	}
 
@@ -1132,7 +1132,7 @@ int wl1271_acx_pm_config(struct wl1271 *wl)
 	struct  conf_pm_config_settings *c = &wl->conf.pm_config;
 	int ret = 0;
 
-	wl1271_debug(DEBUG_ACX, "acx pm config");
+	wl1271_debug(DEBUG_ACX, "acx pm config\n");
 
 	acx = kzalloc(sizeof(*acx), GFP_KERNEL);
 	if (!acx) {
@@ -1145,7 +1145,7 @@ int wl1271_acx_pm_config(struct wl1271 *wl)
 
 	ret = wl1271_cmd_configure(wl, ACX_PM_CONFIG, acx, sizeof(*acx));
 	if (ret < 0) {
-		wl1271_warning("acx pm config failed: %d", ret);
+		wl1271_warn("acx pm config failed: %d\n", ret);
 		goto out;
 	}
 
@@ -1161,7 +1161,7 @@ int wl1271_acx_keep_alive_mode(struct wl1271 *wl, struct wl12xx_vif *wlvif,
 	struct wl1271_acx_keep_alive_mode *acx = NULL;
 	int ret = 0;
 
-	wl1271_debug(DEBUG_ACX, "acx keep alive mode: %d", enable);
+	wl1271_debug(DEBUG_ACX, "acx keep alive mode: %d\n", enable);
 
 	acx = kzalloc(sizeof(*acx), GFP_KERNEL);
 	if (!acx) {
@@ -1174,7 +1174,7 @@ int wl1271_acx_keep_alive_mode(struct wl1271 *wl, struct wl12xx_vif *wlvif,
 
 	ret = wl1271_cmd_configure(wl, ACX_KEEP_ALIVE_MODE, acx, sizeof(*acx));
 	if (ret < 0) {
-		wl1271_warning("acx keep alive mode failed: %d", ret);
+		wl1271_warn("acx keep alive mode failed: %d\n", ret);
 		goto out;
 	}
 
@@ -1189,7 +1189,7 @@ int wl1271_acx_keep_alive_config(struct wl1271 *wl, struct wl12xx_vif *wlvif,
 	struct wl1271_acx_keep_alive_config *acx = NULL;
 	int ret = 0;
 
-	wl1271_debug(DEBUG_ACX, "acx keep alive config");
+	wl1271_debug(DEBUG_ACX, "acx keep alive config\n");
 
 	acx = kzalloc(sizeof(*acx), GFP_KERNEL);
 	if (!acx) {
@@ -1206,7 +1206,7 @@ int wl1271_acx_keep_alive_config(struct wl1271 *wl, struct wl12xx_vif *wlvif,
 	ret = wl1271_cmd_configure(wl, ACX_SET_KEEP_ALIVE_CONFIG,
 				   acx, sizeof(*acx));
 	if (ret < 0) {
-		wl1271_warning("acx keep alive config failed: %d", ret);
+		wl1271_warn("acx keep alive config failed: %d\n", ret);
 		goto out;
 	}
 
@@ -1221,7 +1221,7 @@ int wl1271_acx_rssi_snr_trigger(struct wl1271 *wl, struct wl12xx_vif *wlvif,
 	struct wl1271_acx_rssi_snr_trigger *acx = NULL;
 	int ret = 0;
 
-	wl1271_debug(DEBUG_ACX, "acx rssi snr trigger");
+	wl1271_debug(DEBUG_ACX, "acx rssi snr trigger\n");
 
 	acx = kzalloc(sizeof(*acx), GFP_KERNEL);
 	if (!acx) {
@@ -1247,7 +1247,7 @@ int wl1271_acx_rssi_snr_trigger(struct wl1271 *wl, struct wl12xx_vif *wlvif,
 
 	ret = wl1271_cmd_configure(wl, ACX_RSSI_SNR_TRIGGER, acx, sizeof(*acx));
 	if (ret < 0) {
-		wl1271_warning("acx rssi snr trigger setting failed: %d", ret);
+		wl1271_warn("acx rssi snr trigger setting failed: %d\n", ret);
 		goto out;
 	}
 
@@ -1263,7 +1263,7 @@ int wl1271_acx_rssi_snr_avg_weights(struct wl1271 *wl,
 	struct conf_roam_trigger_settings *c = &wl->conf.roam_trigger;
 	int ret = 0;
 
-	wl1271_debug(DEBUG_ACX, "acx rssi snr avg weights");
+	wl1271_debug(DEBUG_ACX, "acx rssi snr avg weights\n");
 
 	acx = kzalloc(sizeof(*acx), GFP_KERNEL);
 	if (!acx) {
@@ -1279,7 +1279,7 @@ int wl1271_acx_rssi_snr_avg_weights(struct wl1271 *wl,
 
 	ret = wl1271_cmd_configure(wl, ACX_RSSI_SNR_WEIGHTS, acx, sizeof(*acx));
 	if (ret < 0) {
-		wl1271_warning("acx rssi snr trigger weights failed: %d", ret);
+		wl1271_warn("acx rssi snr trigger weights failed: %d\n", ret);
 		goto out;
 	}
 
@@ -1296,9 +1296,8 @@ int wl1271_acx_set_ht_capabilities(struct wl1271 *wl,
 	int ret = 0;
 	u32 ht_capabilites = 0;
 
-	wl1271_debug(DEBUG_ACX, "acx ht capabilities setting "
-		     "sta supp: %d sta cap: %d", ht_cap->ht_supported,
-		     ht_cap->cap);
+	wl1271_debug(DEBUG_ACX, "acx ht capabilities setting sta supp: %d sta cap: %d\n",
+		     ht_cap->ht_supported, ht_cap->cap);
 
 	acx = kzalloc(sizeof(*acx), GFP_KERNEL);
 	if (!acx) {
@@ -1326,7 +1325,7 @@ int wl1271_acx_set_ht_capabilities(struct wl1271 *wl,
 
 	ret = wl1271_cmd_configure(wl, ACX_PEER_HT_CAP, acx, sizeof(*acx));
 	if (ret < 0) {
-		wl1271_warning("acx ht capabilities setting failed: %d", ret);
+		wl1271_warn("acx ht capabilities setting failed: %d\n", ret);
 		goto out;
 	}
 
@@ -1342,7 +1341,7 @@ int wl1271_acx_set_ht_information(struct wl1271 *wl,
 	struct wl1271_acx_ht_information *acx;
 	int ret = 0;
 
-	wl1271_debug(DEBUG_ACX, "acx ht information setting");
+	wl1271_debug(DEBUG_ACX, "acx ht information setting\n");
 
 	acx = kzalloc(sizeof(*acx), GFP_KERNEL);
 	if (!acx) {
@@ -1362,7 +1361,7 @@ int wl1271_acx_set_ht_information(struct wl1271 *wl,
 	ret = wl1271_cmd_configure(wl, ACX_HT_BSS_OPERATION, acx, sizeof(*acx));
 
 	if (ret < 0) {
-		wl1271_warning("acx ht information setting failed: %d", ret);
+		wl1271_warn("acx ht information setting failed: %d\n", ret);
 		goto out;
 	}
 
@@ -1378,7 +1377,7 @@ int wl12xx_acx_set_ba_initiator_policy(struct wl1271 *wl,
 	struct wl1271_acx_ba_initiator_policy *acx;
 	int ret;
 
-	wl1271_debug(DEBUG_ACX, "acx ba initiator policy");
+	wl1271_debug(DEBUG_ACX, "acx ba initiator policy\n");
 
 	acx = kzalloc(sizeof(*acx), GFP_KERNEL);
 	if (!acx) {
@@ -1397,7 +1396,7 @@ int wl12xx_acx_set_ba_initiator_policy(struct wl1271 *wl,
 				   acx,
 				   sizeof(*acx));
 	if (ret < 0) {
-		wl1271_warning("acx ba initiator policy failed: %d", ret);
+		wl1271_warn("acx ba initiator policy failed: %d\n", ret);
 		goto out;
 	}
 
@@ -1413,7 +1412,7 @@ int wl12xx_acx_set_ba_receiver_session(struct wl1271 *wl, u8 tid_index,
 	struct wl1271_acx_ba_receiver_setup *acx;
 	int ret;
 
-	wl1271_debug(DEBUG_ACX, "acx ba receiver session setting");
+	wl1271_debug(DEBUG_ACX, "acx ba receiver session setting\n");
 
 	acx = kzalloc(sizeof(*acx), GFP_KERNEL);
 	if (!acx) {
@@ -1430,7 +1429,7 @@ int wl12xx_acx_set_ba_receiver_session(struct wl1271 *wl, u8 tid_index,
 	ret = wl1271_cmd_configure(wl, ACX_BA_SESSION_RX_SETUP, acx,
 				   sizeof(*acx));
 	if (ret < 0) {
-		wl1271_warning("acx ba receiver session failed: %d", ret);
+		wl1271_warn("acx ba receiver session failed: %d\n", ret);
 		goto out;
 	}
 
@@ -1456,7 +1455,7 @@ int wl12xx_acx_tsf_info(struct wl1271 *wl, struct wl12xx_vif *wlvif,
 	ret = wl1271_cmd_interrogate(wl, ACX_TSF_INFO,
 				     tsf_info, sizeof(*tsf_info));
 	if (ret < 0) {
-		wl1271_warning("acx tsf info interrogate failed");
+		wl1271_warn("acx tsf info interrogate failed\n");
 		goto out;
 	}
 
@@ -1475,7 +1474,7 @@ int wl1271_acx_ps_rx_streaming(struct wl1271 *wl, struct wl12xx_vif *wlvif,
 	u32 conf_queues, enable_queues;
 	int i, ret = 0;
 
-	wl1271_debug(DEBUG_ACX, "acx ps rx streaming");
+	wl1271_debug(DEBUG_ACX, "acx ps rx streaming\n");
 
 	rx_streaming = kzalloc(sizeof(*rx_streaming), GFP_KERNEL);
 	if (!rx_streaming) {
@@ -1508,7 +1507,7 @@ int wl1271_acx_ps_rx_streaming(struct wl1271 *wl, struct wl12xx_vif *wlvif,
 					   rx_streaming,
 					   sizeof(*rx_streaming));
 		if (ret < 0) {
-			wl1271_warning("acx ps rx streaming failed: %d", ret);
+			wl1271_warn("acx ps rx streaming failed: %d\n", ret);
 			goto out;
 		}
 	}
@@ -1522,7 +1521,7 @@ int wl1271_acx_ap_max_tx_retry(struct wl1271 *wl, struct wl12xx_vif *wlvif)
 	struct wl1271_acx_ap_max_tx_retry *acx = NULL;
 	int ret;
 
-	wl1271_debug(DEBUG_ACX, "acx ap max tx retry");
+	wl1271_debug(DEBUG_ACX, "acx ap max tx retry\n");
 
 	acx = kzalloc(sizeof(*acx), GFP_KERNEL);
 	if (!acx)
@@ -1533,7 +1532,7 @@ int wl1271_acx_ap_max_tx_retry(struct wl1271 *wl, struct wl12xx_vif *wlvif)
 
 	ret = wl1271_cmd_configure(wl, ACX_MAX_TX_FAILURE, acx, sizeof(*acx));
 	if (ret < 0) {
-		wl1271_warning("acx ap max tx retry failed: %d", ret);
+		wl1271_warn("acx ap max tx retry failed: %d\n", ret);
 		goto out;
 	}
 
@@ -1547,7 +1546,7 @@ int wl12xx_acx_config_ps(struct wl1271 *wl, struct wl12xx_vif *wlvif)
 	struct wl1271_acx_config_ps *config_ps;
 	int ret;
 
-	wl1271_debug(DEBUG_ACX, "acx config ps");
+	wl1271_debug(DEBUG_ACX, "acx config ps\n");
 
 	config_ps = kzalloc(sizeof(*config_ps), GFP_KERNEL);
 	if (!config_ps) {
@@ -1563,7 +1562,7 @@ int wl12xx_acx_config_ps(struct wl1271 *wl, struct wl12xx_vif *wlvif)
 				   sizeof(*config_ps));
 
 	if (ret < 0) {
-		wl1271_warning("acx config ps failed: %d", ret);
+		wl1271_warn("acx config ps failed: %d\n", ret);
 		goto out;
 	}
 
@@ -1577,7 +1576,7 @@ int wl1271_acx_set_inconnection_sta(struct wl1271 *wl, u8 *addr)
 	struct wl1271_acx_inconnection_sta *acx = NULL;
 	int ret;
 
-	wl1271_debug(DEBUG_ACX, "acx set inconnaction sta %pM", addr);
+	wl1271_debug(DEBUG_ACX, "acx set inconnaction sta %pM\n", addr);
 
 	acx = kzalloc(sizeof(*acx), GFP_KERNEL);
 	if (!acx)
@@ -1588,7 +1587,7 @@ int wl1271_acx_set_inconnection_sta(struct wl1271 *wl, u8 *addr)
 	ret = wl1271_cmd_configure(wl, ACX_UPDATE_INCONNECTION_STA_LIST,
 				   acx, sizeof(*acx));
 	if (ret < 0) {
-		wl1271_warning("acx set inconnaction sta failed: %d", ret);
+		wl1271_warn("acx set inconnaction sta failed: %d\n", ret);
 		goto out;
 	}
 
@@ -1602,7 +1601,7 @@ int wl1271_acx_fm_coex(struct wl1271 *wl)
 	struct wl1271_acx_fm_coex *acx;
 	int ret;
 
-	wl1271_debug(DEBUG_ACX, "acx fm coex setting");
+	wl1271_debug(DEBUG_ACX, "acx fm coex setting\n");
 
 	acx = kzalloc(sizeof(*acx), GFP_KERNEL);
 	if (!acx) {
@@ -1628,7 +1627,7 @@ int wl1271_acx_fm_coex(struct wl1271 *wl)
 
 	ret = wl1271_cmd_configure(wl, ACX_FM_COEX_CFG, acx, sizeof(*acx));
 	if (ret < 0) {
-		wl1271_warning("acx fm coex setting failed: %d", ret);
+		wl1271_warn("acx fm coex setting failed: %d\n", ret);
 		goto out;
 	}
 
@@ -1643,7 +1642,7 @@ int wl12xx_acx_set_rate_mgmt_params(struct wl1271 *wl)
 	struct conf_rate_policy_settings *conf = &wl->conf.rate;
 	int ret;
 
-	wl1271_debug(DEBUG_ACX, "acx set rate mgmt params");
+	wl1271_debug(DEBUG_ACX, "acx set rate mgmt params\n");
 
 	acx = kzalloc(sizeof(*acx), GFP_KERNEL);
 	if (!acx)
@@ -1670,7 +1669,7 @@ int wl12xx_acx_set_rate_mgmt_params(struct wl1271 *wl)
 	ret = wl1271_cmd_configure(wl, ACX_SET_RATE_MGMT_PARAMS,
 				   acx, sizeof(*acx));
 	if (ret < 0) {
-		wl1271_warning("acx set rate mgmt params failed: %d", ret);
+		wl1271_warn("acx set rate mgmt params failed: %d\n", ret);
 		goto out;
 	}
 
@@ -1685,7 +1684,7 @@ int wl12xx_acx_config_hangover(struct wl1271 *wl)
 	struct conf_hangover_settings *conf = &wl->conf.hangover;
 	int ret;
 
-	wl1271_debug(DEBUG_ACX, "acx config hangover");
+	wl1271_debug(DEBUG_ACX, "acx config hangover\n");
 
 	acx = kzalloc(sizeof(*acx), GFP_KERNEL);
 	if (!acx) {
@@ -1709,7 +1708,7 @@ int wl12xx_acx_config_hangover(struct wl1271 *wl)
 				   sizeof(*acx));
 
 	if (ret < 0) {
-		wl1271_warning("acx config hangover failed: %d", ret);
+		wl1271_warn("acx config hangover failed: %d\n", ret);
 		goto out;
 	}
 
@@ -1727,7 +1726,7 @@ int wl1271_acx_default_rx_filter_enable(struct wl1271 *wl, bool enable,
 	struct acx_default_rx_filter *acx;
 	int ret;
 
-	wl1271_debug(DEBUG_ACX, "acx default rx filter en: %d act: %d",
+	wl1271_debug(DEBUG_ACX, "acx default rx filter en: %d act: %d\n",
 		     enable, action);
 
 	acx = kzalloc(sizeof(*acx), GFP_KERNEL);
@@ -1740,7 +1739,7 @@ int wl1271_acx_default_rx_filter_enable(struct wl1271 *wl, bool enable,
 	ret = wl1271_cmd_configure(wl, ACX_ENABLE_RX_DATA_FILTER, acx,
 				   sizeof(*acx));
 	if (ret < 0) {
-		wl1271_warning("acx default rx filter enable failed: %d", ret);
+		wl1271_warn("acx default rx filter enable failed: %d\n", ret);
 		goto out;
 	}
 
@@ -1762,14 +1761,14 @@ int wl1271_acx_set_rx_filter(struct wl1271 *wl, u8 index, bool enable,
 	WARN_ON(index >= WL1271_MAX_RX_FILTERS);
 
 	wl1271_debug(DEBUG_ACX,
-		     "acx set rx filter idx: %d enable: %d filter: %p",
+		     "acx set rx filter idx: %d enable: %d filter: %p\n",
 		     index, enable, filter);
 
 	if (enable) {
 		fields_size = wl1271_rx_filter_get_fields_size(filter);
 
-		wl1271_debug(DEBUG_ACX, "act: %d num_fields: %d field_size: %d",
-		      filter->action, filter->num_fields, fields_size);
+		wl1271_debug(DEBUG_ACX, "act: %d num_fields: %d field_size: %d\n",
+			     filter->action, filter->num_fields, fields_size);
 	}
 
 	acx_size = ALIGN(sizeof(*acx) + fields_size, 4);
@@ -1791,7 +1790,7 @@ int wl1271_acx_set_rx_filter(struct wl1271 *wl, u8 index, bool enable,
 
 	ret = wl1271_cmd_configure(wl, ACX_SET_RX_DATA_FILTER, acx, acx_size);
 	if (ret < 0) {
-		wl1271_warning("setting rx filter failed: %d", ret);
+		wl1271_warn("setting rx filter failed: %d\n", ret);
 		goto out;
 	}
 
diff --git a/drivers/net/wireless/ti/wlcore/boot.c b/drivers/net/wireless/ti/wlcore/boot.c
index 0fda500..2cefdbf 100644
--- a/drivers/net/wireless/ti/wlcore/boot.c
+++ b/drivers/net/wireless/ti/wlcore/boot.c
@@ -62,7 +62,7 @@ static int wlcore_boot_parse_fw_ver(struct wl1271 *wl,
 		     &wl->chip.fw_ver[4]);
 
 	if (ret != 5) {
-		wl1271_warning("fw version incorrect value");
+		wl1271_warn("fw version incorrect value\n");
 		memset(wl->chip.fw_ver, 0, sizeof(wl->chip.fw_ver));
 		ret = -EINVAL;
 		goto out;
@@ -112,19 +112,19 @@ static int wl1271_boot_upload_firmware_chunk(struct wl1271 *wl, void *buf,
 
 	/* whal_FwCtrl_LoadFwImageSm() */
 
-	wl1271_debug(DEBUG_BOOT, "starting firmware upload");
+	wl1271_debug(DEBUG_BOOT, "starting firmware upload\n");
 
-	wl1271_debug(DEBUG_BOOT, "fw_data_len %zd chunk_size %d",
+	wl1271_debug(DEBUG_BOOT, "fw_data_len %zd chunk_size %d\n",
 		     fw_data_len, CHUNK_SIZE);
 
 	if ((fw_data_len % 4) != 0) {
-		wl1271_error("firmware length not multiple of four");
+		wl1271_err("firmware length not multiple of four\n");
 		return -EIO;
 	}
 
 	chunk = kmalloc(CHUNK_SIZE, GFP_KERNEL);
 	if (!chunk) {
-		wl1271_error("allocation for firmware upload chunk failed");
+		wl1271_err("allocation for firmware upload chunk failed\n");
 		return -ENOMEM;
 	}
 
@@ -151,7 +151,7 @@ static int wl1271_boot_upload_firmware_chunk(struct wl1271 *wl, void *buf,
 		addr = dest + chunk_num * CHUNK_SIZE;
 		p = buf + chunk_num * CHUNK_SIZE;
 		memcpy(chunk, p, CHUNK_SIZE);
-		wl1271_debug(DEBUG_BOOT, "uploading fw chunk 0x%p to 0x%x",
+		wl1271_debug(DEBUG_BOOT, "uploading fw chunk 0x%p to 0x%x\n",
 			     p, addr);
 		wl1271_write(wl, addr, chunk, CHUNK_SIZE, false);
 
@@ -162,7 +162,7 @@ static int wl1271_boot_upload_firmware_chunk(struct wl1271 *wl, void *buf,
 	addr = dest + chunk_num * CHUNK_SIZE;
 	p = buf + chunk_num * CHUNK_SIZE;
 	memcpy(chunk, p, fw_data_len % CHUNK_SIZE);
-	wl1271_debug(DEBUG_BOOT, "uploading fw last chunk (%zd B) 0x%p to 0x%x",
+	wl1271_debug(DEBUG_BOOT, "uploading fw last chunk (%zd B) 0x%p to 0x%x\n",
 		     fw_data_len % CHUNK_SIZE, p, addr);
 	wl1271_write(wl, addr, chunk, fw_data_len % CHUNK_SIZE, false);
 
@@ -180,7 +180,8 @@ int wlcore_boot_upload_firmware(struct wl1271 *wl)
 	chunks = be32_to_cpup((__be32 *) fw);
 	fw += sizeof(u32);
 
-	wl1271_debug(DEBUG_BOOT, "firmware chunks to be uploaded: %u", chunks);
+	wl1271_debug(DEBUG_BOOT, "firmware chunks to be uploaded: %u\n",
+		     chunks);
 
 	while (chunks--) {
 		addr = be32_to_cpup((__be32 *) fw);
@@ -189,10 +190,10 @@ int wlcore_boot_upload_firmware(struct wl1271 *wl)
 		fw += sizeof(u32);
 
 		if (len > 300000) {
-			wl1271_info("firmware chunk too long: %u", len);
+			wl1271_info("firmware chunk too long: %u\n", len);
 			return -EINVAL;
 		}
-		wl1271_debug(DEBUG_BOOT, "chunk %d addr 0x%x len %u",
+		wl1271_debug(DEBUG_BOOT, "chunk %d addr 0x%x len %u\n",
 			     chunks, addr, len);
 		ret = wl1271_boot_upload_firmware_chunk(wl, fw, len, addr);
 		if (ret != 0)
@@ -212,7 +213,7 @@ int wlcore_boot_upload_nvs(struct wl1271 *wl)
 	u8 *nvs_ptr, *nvs_aligned;
 
 	if (wl->nvs == NULL) {
-		wl1271_error("NVS file is needed during boot");
+		wl1271_err("NVS file is needed during boot\n");
 		return -ENODEV;
 	}
 
@@ -233,8 +234,8 @@ int wlcore_boot_upload_nvs(struct wl1271 *wl)
 		if (wl->nvs_len != sizeof(struct wl1271_nvs_file) &&
 		    (wl->nvs_len != WL1271_INI_LEGACY_NVS_FILE_SIZE ||
 		     wl->enable_11a)) {
-			wl1271_error("nvs size is not as expected: %zu != %zu",
-				wl->nvs_len, sizeof(struct wl1271_nvs_file));
+			wl1271_err("nvs size is not as expected: %zu != %zu\n",
+				   wl->nvs_len, sizeof(struct wl1271_nvs_file));
 			kfree(wl->nvs);
 			wl->nvs = NULL;
 			wl->nvs_len = 0;
@@ -251,9 +252,9 @@ int wlcore_boot_upload_nvs(struct wl1271 *wl)
 			if (nvs->general_params.dual_mode_select)
 				wl->enable_11a = true;
 		} else {
-			wl1271_error("nvs size is not as expected: %zu != %zu",
-				     wl->nvs_len,
-				     sizeof(struct wl128x_nvs_file));
+			wl1271_err("nvs size is not as expected: %zu != %zu\n",
+				   wl->nvs_len,
+				   sizeof(struct wl128x_nvs_file));
 			kfree(wl->nvs);
 			wl->nvs = NULL;
 			wl->nvs_len = 0;
@@ -305,7 +306,7 @@ int wlcore_boot_upload_nvs(struct wl1271 *wl)
 			       | (nvs_ptr[2] << 16) | (nvs_ptr[3] << 24));
 
 			wl1271_debug(DEBUG_BOOT,
-				     "nvs burst write 0x%x: 0x%x",
+				     "nvs burst write 0x%x: 0x%x\n",
 				     dest_addr, val);
 			wl1271_write32(wl, dest_addr, val);
 
@@ -348,7 +349,7 @@ int wlcore_boot_upload_nvs(struct wl1271 *wl)
 	return 0;
 
 out_badnvs:
-	wl1271_error("nvs data is malformed");
+	wl1271_err("nvs data is malformed\n");
 	return -EILSEQ;
 }
 EXPORT_SYMBOL_GPL(wlcore_boot_upload_nvs);
@@ -365,10 +366,11 @@ int wlcore_boot_run_firmware(struct wl1271 *wl)
 
 	chip_id = wlcore_read_reg(wl, REG_CHIP_ID_B);
 
-	wl1271_debug(DEBUG_BOOT, "chip id after firmware boot: 0x%x", chip_id);
+	wl1271_debug(DEBUG_BOOT, "chip id after firmware boot: 0x%x\n",
+		     chip_id);
 
 	if (chip_id != wl->chip.id) {
-		wl1271_error("chip id doesn't match after firmware boot");
+		wl1271_err("chip id doesn't match after firmware boot\n");
 		return -EIO;
 	}
 
@@ -379,8 +381,7 @@ int wlcore_boot_run_firmware(struct wl1271 *wl)
 		intr = wlcore_read_reg(wl, REG_INTERRUPT_NO_CLEAR);
 
 		if (intr == 0xffffffff) {
-			wl1271_error("error reading hardware complete "
-				     "init indication");
+			wl1271_err("error reading hardware complete init indication\n");
 			return -EIO;
 		}
 		/* check that ACX_INTR_INIT_COMPLETE is enabled */
@@ -392,26 +393,25 @@ int wlcore_boot_run_firmware(struct wl1271 *wl)
 	}
 
 	if (loop > INIT_LOOP) {
-		wl1271_error("timeout waiting for the hardware to "
-			     "complete initialization");
+		wl1271_err("timeout waiting for the hardware to complete initialization\n");
 		return -EIO;
 	}
 
 	/* get hardware config command mail box */
 	wl->cmd_box_addr = wlcore_read_reg(wl, REG_COMMAND_MAILBOX_PTR);
 
-	wl1271_debug(DEBUG_MAILBOX, "cmd_box_addr 0x%x", wl->cmd_box_addr);
+	wl1271_debug(DEBUG_MAILBOX, "cmd_box_addr 0x%x\n", wl->cmd_box_addr);
 
 	/* get hardware config event mail box */
 	wl->mbox_ptr[0] = wlcore_read_reg(wl, REG_EVENT_MAILBOX_PTR);
 	wl->mbox_ptr[1] = wl->mbox_ptr[0] + sizeof(struct event_mailbox);
 
-	wl1271_debug(DEBUG_MAILBOX, "MBOX ptrs: 0x%x 0x%x",
+	wl1271_debug(DEBUG_MAILBOX, "MBOX ptrs: 0x%x 0x%x\n",
 		     wl->mbox_ptr[0], wl->mbox_ptr[1]);
 
 	ret = wlcore_boot_static_data(wl);
 	if (ret < 0) {
-		wl1271_error("error getting static data");
+		wl1271_err("error getting static data\n");
 		return ret;
 	}
 
@@ -440,7 +440,7 @@ int wlcore_boot_run_firmware(struct wl1271 *wl)
 
 	ret = wl1271_event_unmask(wl);
 	if (ret < 0) {
-		wl1271_error("EVENT mask setting failed");
+		wl1271_err("EVENT mask setting failed\n");
 		return ret;
 	}
 
diff --git a/drivers/net/wireless/ti/wlcore/cmd.c b/drivers/net/wireless/ti/wlcore/cmd.c
index 885364c..c90b339 100644
--- a/drivers/net/wireless/ti/wlcore/cmd.c
+++ b/drivers/net/wireless/ti/wlcore/cmd.c
@@ -78,7 +78,7 @@ int wl1271_cmd_send(struct wl1271 *wl, u16 id, void *buf, size_t len,
 	intr = wlcore_read_reg(wl, REG_INTERRUPT_NO_CLEAR);
 	while (!(intr & WL1271_ACX_INTR_CMD_COMPLETE)) {
 		if (time_after(jiffies, timeout)) {
-			wl1271_error("command complete timeout");
+			wl1271_err("command complete timeout\n");
 			ret = -ETIMEDOUT;
 			goto fail;
 		}
@@ -99,7 +99,7 @@ int wl1271_cmd_send(struct wl1271 *wl, u16 id, void *buf, size_t len,
 
 	status = le16_to_cpu(cmd->status);
 	if (status != CMD_STATUS_SUCCESS) {
-		wl1271_error("command execute failure %d", status);
+		wl1271_err("command execute failure %d\n", status);
 		ret = -EIO;
 		goto fail;
 	}
@@ -132,7 +132,7 @@ static int wl1271_cmd_wait_for_event_or_timeout(struct wl1271 *wl, u32 mask)
 
 	do {
 		if (time_after(jiffies, timeout)) {
-			wl1271_debug(DEBUG_CMD, "timeout waiting for event %d",
+			wl1271_debug(DEBUG_CMD, "timeout waiting for event %d\n",
 				     (int)mask);
 			ret = -ETIMEDOUT;
 			goto out;
@@ -173,7 +173,7 @@ int wl12xx_cmd_role_enable(struct wl1271 *wl, u8 *addr, u8 role_type,
 	struct wl12xx_cmd_role_enable *cmd;
 	int ret;
 
-	wl1271_debug(DEBUG_CMD, "cmd role enable");
+	wl1271_debug(DEBUG_CMD, "cmd role enable\n");
 
 	if (WARN_ON(*role_id != WL12XX_INVALID_ROLE_ID))
 		return -EBUSY;
@@ -196,7 +196,7 @@ int wl12xx_cmd_role_enable(struct wl1271 *wl, u8 *addr, u8 role_type,
 
 	ret = wl1271_cmd_send(wl, CMD_ROLE_ENABLE, cmd, sizeof(*cmd), 0);
 	if (ret < 0) {
-		wl1271_error("failed to initiate cmd role enable");
+		wl1271_err("failed to initiate cmd role enable\n");
 		goto out_free;
 	}
 
@@ -215,7 +215,7 @@ int wl12xx_cmd_role_disable(struct wl1271 *wl, u8 *role_id)
 	struct wl12xx_cmd_role_disable *cmd;
 	int ret;
 
-	wl1271_debug(DEBUG_CMD, "cmd role disable");
+	wl1271_debug(DEBUG_CMD, "cmd role disable\n");
 
 	if (WARN_ON(*role_id == WL12XX_INVALID_ROLE_ID))
 		return -ENOENT;
@@ -229,7 +229,7 @@ int wl12xx_cmd_role_disable(struct wl1271 *wl, u8 *role_id)
 
 	ret = wl1271_cmd_send(wl, CMD_ROLE_DISABLE, cmd, sizeof(*cmd), 0);
 	if (ret < 0) {
-		wl1271_error("failed to initiate cmd role disable");
+		wl1271_err("failed to initiate cmd role disable\n");
 		goto out_free;
 	}
 
@@ -321,7 +321,7 @@ static int wl12xx_cmd_role_start_dev(struct wl1271 *wl,
 		goto out;
 	}
 
-	wl1271_debug(DEBUG_CMD, "cmd role start dev %d", wlvif->dev_role_id);
+	wl1271_debug(DEBUG_CMD, "cmd role start dev %d\n", wlvif->dev_role_id);
 
 	cmd->role_id = wlvif->dev_role_id;
 	if (wlvif->band == IEEE80211_BAND_5GHZ)
@@ -336,12 +336,12 @@ static int wl12xx_cmd_role_start_dev(struct wl1271 *wl,
 	cmd->device.hlid = wlvif->dev_hlid;
 	cmd->device.session = wl12xx_get_new_session_id(wl, wlvif);
 
-	wl1271_debug(DEBUG_CMD, "role start: roleid=%d, hlid=%d, session=%d",
+	wl1271_debug(DEBUG_CMD, "role start: roleid=%d, hlid=%d, session=%d\n",
 		     cmd->role_id, cmd->device.hlid, cmd->device.session);
 
 	ret = wl1271_cmd_send(wl, CMD_ROLE_START, cmd, sizeof(*cmd), 0);
 	if (ret < 0) {
-		wl1271_error("failed to initiate cmd role enable");
+		wl1271_err("failed to initiate cmd role enable\n");
 		goto err_hlid;
 	}
 
@@ -373,7 +373,7 @@ static int wl12xx_cmd_role_stop_dev(struct wl1271 *wl,
 		goto out;
 	}
 
-	wl1271_debug(DEBUG_CMD, "cmd role stop dev");
+	wl1271_debug(DEBUG_CMD, "cmd role stop dev\n");
 
 	cmd->role_id = wlvif->dev_role_id;
 	cmd->disc_type = DISCONNECT_IMMEDIATE;
@@ -381,13 +381,13 @@ static int wl12xx_cmd_role_stop_dev(struct wl1271 *wl,
 
 	ret = wl1271_cmd_send(wl, CMD_ROLE_STOP, cmd, sizeof(*cmd), 0);
 	if (ret < 0) {
-		wl1271_error("failed to initiate cmd role stop");
+		wl1271_err("failed to initiate cmd role stop\n");
 		goto out_free;
 	}
 
 	ret = wl1271_cmd_wait_for_event(wl, ROLE_STOP_COMPLETE_EVENT_ID);
 	if (ret < 0) {
-		wl1271_error("cmd role stop dev event completion error");
+		wl1271_err("cmd role stop dev event completion error\n");
 		goto out_free;
 	}
 
@@ -412,7 +412,7 @@ int wl12xx_cmd_role_start_sta(struct wl1271 *wl, struct wl12xx_vif *wlvif)
 		goto out;
 	}
 
-	wl1271_debug(DEBUG_CMD, "cmd role start sta %d", wlvif->role_id);
+	wl1271_debug(DEBUG_CMD, "cmd role start sta %d\n", wlvif->role_id);
 
 	cmd->role_id = wlvif->role_id;
 	if (wlvif->band == IEEE80211_BAND_5GHZ)
@@ -436,14 +436,13 @@ int wl12xx_cmd_role_start_sta(struct wl1271 *wl, struct wl12xx_vif *wlvif)
 	cmd->sta.session = wl12xx_get_new_session_id(wl, wlvif);
 	cmd->sta.remote_rates = cpu_to_le32(wlvif->rate_set);
 
-	wl1271_debug(DEBUG_CMD, "role start: roleid=%d, hlid=%d, session=%d "
-		     "basic_rate_set: 0x%x, remote_rates: 0x%x",
+	wl1271_debug(DEBUG_CMD, "role start: roleid=%d, hlid=%d, session=%d basic_rate_set: 0x%x, remote_rates: 0x%x\n",
 		     wlvif->role_id, cmd->sta.hlid, cmd->sta.session,
 		     wlvif->basic_rate_set, wlvif->rate_set);
 
 	ret = wl1271_cmd_send(wl, CMD_ROLE_START, cmd, sizeof(*cmd), 0);
 	if (ret < 0) {
-		wl1271_error("failed to initiate cmd role start sta");
+		wl1271_err("failed to initiate cmd role start sta\n");
 		goto err_hlid;
 	}
 
@@ -475,7 +474,7 @@ int wl12xx_cmd_role_stop_sta(struct wl1271 *wl, struct wl12xx_vif *wlvif)
 		goto out;
 	}
 
-	wl1271_debug(DEBUG_CMD, "cmd role stop sta %d", wlvif->role_id);
+	wl1271_debug(DEBUG_CMD, "cmd role stop sta %d\n", wlvif->role_id);
 
 	cmd->role_id = wlvif->role_id;
 	cmd->disc_type = DISCONNECT_IMMEDIATE;
@@ -483,7 +482,7 @@ int wl12xx_cmd_role_stop_sta(struct wl1271 *wl, struct wl12xx_vif *wlvif)
 
 	ret = wl1271_cmd_send(wl, CMD_ROLE_STOP, cmd, sizeof(*cmd), 0);
 	if (ret < 0) {
-		wl1271_error("failed to initiate cmd role stop sta");
+		wl1271_err("failed to initiate cmd role stop sta\n");
 		goto out_free;
 	}
 
@@ -504,11 +503,11 @@ int wl12xx_cmd_role_start_ap(struct wl1271 *wl, struct wl12xx_vif *wlvif)
 	u32 supported_rates;
 	int ret;
 
-	wl1271_debug(DEBUG_CMD, "cmd role start ap %d", wlvif->role_id);
+	wl1271_debug(DEBUG_CMD, "cmd role start ap %d\n", wlvif->role_id);
 
 	/* trying to use hidden SSID with an old hostapd version */
 	if (wlvif->ssid_len == 0 && !bss_conf->hidden_ssid) {
-		wl1271_error("got a null SSID from beacon/bss");
+		wl1271_err("got a null SSID from beacon/bss\n");
 		ret = -EINVAL;
 		goto out;
 	}
@@ -555,7 +554,7 @@ int wl12xx_cmd_role_start_ap(struct wl1271 *wl, struct wl12xx_vif *wlvif)
 	supported_rates = CONF_TX_AP_ENABLED_RATES | CONF_TX_MCS_RATES |
 		wlcore_hw_ap_get_mimo_wide_rate_mask(wl, wlvif);
 
-	wl1271_debug(DEBUG_CMD, "cmd role start ap with supported_rates 0x%08x",
+	wl1271_debug(DEBUG_CMD, "cmd role start ap with supported_rates 0x%08x\n",
 		     supported_rates);
 
 	cmd->ap.local_rates = cpu_to_le32(supported_rates);
@@ -568,14 +567,14 @@ int wl12xx_cmd_role_start_ap(struct wl1271 *wl, struct wl12xx_vif *wlvif)
 		cmd->band = WLCORE_BAND_5GHZ;
 		break;
 	default:
-		wl1271_warning("ap start - unknown band: %d", (int)wlvif->band);
+		wl1271_warn("ap start - unknown band: %d\n", (int)wlvif->band);
 		cmd->band = WLCORE_BAND_2_4GHZ;
 		break;
 	}
 
 	ret = wl1271_cmd_send(wl, CMD_ROLE_START, cmd, sizeof(*cmd), 0);
 	if (ret < 0) {
-		wl1271_error("failed to initiate cmd role start ap");
+		wl1271_err("failed to initiate cmd role start ap\n");
 		goto out_free_bcast;
 	}
 
@@ -605,13 +604,13 @@ int wl12xx_cmd_role_stop_ap(struct wl1271 *wl, struct wl12xx_vif *wlvif)
 		goto out;
 	}
 
-	wl1271_debug(DEBUG_CMD, "cmd role stop ap %d", wlvif->role_id);
+	wl1271_debug(DEBUG_CMD, "cmd role stop ap %d\n", wlvif->role_id);
 
 	cmd->role_id = wlvif->role_id;
 
 	ret = wl1271_cmd_send(wl, CMD_ROLE_STOP, cmd, sizeof(*cmd), 0);
 	if (ret < 0) {
-		wl1271_error("failed to initiate cmd role stop ap");
+		wl1271_err("failed to initiate cmd role stop ap\n");
 		goto out_free;
 	}
 
@@ -638,7 +637,7 @@ int wl12xx_cmd_role_start_ibss(struct wl1271 *wl, struct wl12xx_vif *wlvif)
 		goto out;
 	}
 
-	wl1271_debug(DEBUG_CMD, "cmd role start ibss %d", wlvif->role_id);
+	wl1271_debug(DEBUG_CMD, "cmd role start ibss %d\n", wlvif->role_id);
 
 	cmd->role_id = wlvif->role_id;
 	if (wlvif->band == IEEE80211_BAND_5GHZ)
@@ -661,17 +660,16 @@ int wl12xx_cmd_role_start_ibss(struct wl1271 *wl, struct wl12xx_vif *wlvif)
 	cmd->ibss.hlid = wlvif->sta.hlid;
 	cmd->ibss.remote_rates = cpu_to_le32(wlvif->rate_set);
 
-	wl1271_debug(DEBUG_CMD, "role start: roleid=%d, hlid=%d, session=%d "
-		     "basic_rate_set: 0x%x, remote_rates: 0x%x",
+	wl1271_debug(DEBUG_CMD, "role start: roleid=%d, hlid=%d, session=%d basic_rate_set: 0x%x, remote_rates: 0x%x\n",
 		     wlvif->role_id, cmd->sta.hlid, cmd->sta.session,
 		     wlvif->basic_rate_set, wlvif->rate_set);
 
-	wl1271_debug(DEBUG_CMD, "vif->bss_conf.bssid = %pM",
+	wl1271_debug(DEBUG_CMD, "vif->bss_conf.bssid = %pM\n",
 		     vif->bss_conf.bssid);
 
 	ret = wl1271_cmd_send(wl, CMD_ROLE_START, cmd, sizeof(*cmd), 0);
 	if (ret < 0) {
-		wl1271_error("failed to initiate cmd role enable");
+		wl1271_err("failed to initiate cmd role enable\n");
 		goto err_hlid;
 	}
 
@@ -702,7 +700,7 @@ int wl1271_cmd_test(struct wl1271 *wl, void *buf, size_t buf_len, u8 answer)
 	int ret;
 	size_t res_len = 0;
 
-	wl1271_debug(DEBUG_CMD, "cmd test");
+	wl1271_debug(DEBUG_CMD, "cmd test\n");
 
 	if (answer)
 		res_len = buf_len;
@@ -710,7 +708,7 @@ int wl1271_cmd_test(struct wl1271 *wl, void *buf, size_t buf_len, u8 answer)
 	ret = wl1271_cmd_send(wl, CMD_TEST, buf, buf_len, res_len);
 
 	if (ret < 0) {
-		wl1271_warning("TEST command failed");
+		wl1271_warn("TEST command failed\n");
 		return ret;
 	}
 
@@ -731,7 +729,7 @@ int wl1271_cmd_interrogate(struct wl1271 *wl, u16 id, void *buf, size_t len)
 	struct acx_header *acx = buf;
 	int ret;
 
-	wl1271_debug(DEBUG_CMD, "cmd interrogate");
+	wl1271_debug(DEBUG_CMD, "cmd interrogate\n");
 
 	acx->id = cpu_to_le16(id);
 
@@ -740,7 +738,7 @@ int wl1271_cmd_interrogate(struct wl1271 *wl, u16 id, void *buf, size_t len)
 
 	ret = wl1271_cmd_send(wl, CMD_INTERROGATE, acx, sizeof(*acx), len);
 	if (ret < 0)
-		wl1271_error("INTERROGATE command failed");
+		wl1271_err("INTERROGATE command failed\n");
 
 	return ret;
 }
@@ -758,7 +756,7 @@ int wl1271_cmd_configure(struct wl1271 *wl, u16 id, void *buf, size_t len)
 	struct acx_header *acx = buf;
 	int ret;
 
-	wl1271_debug(DEBUG_CMD, "cmd configure (%d)", id);
+	wl1271_debug(DEBUG_CMD, "cmd configure (%d)\n", id);
 
 	acx->id = cpu_to_le16(id);
 
@@ -767,7 +765,7 @@ int wl1271_cmd_configure(struct wl1271 *wl, u16 id, void *buf, size_t len)
 
 	ret = wl1271_cmd_send(wl, CMD_CONFIGURE, acx, len, 0);
 	if (ret < 0) {
-		wl1271_warning("CONFIGURE command NOK");
+		wl1271_warn("CONFIGURE command NOK\n");
 		return ret;
 	}
 
@@ -781,7 +779,7 @@ int wl1271_cmd_data_path(struct wl1271 *wl, bool enable)
 	int ret;
 	u16 cmd_rx, cmd_tx;
 
-	wl1271_debug(DEBUG_CMD, "cmd data path");
+	wl1271_debug(DEBUG_CMD, "cmd data path\n");
 
 	cmd = kzalloc(sizeof(*cmd), GFP_KERNEL);
 	if (!cmd) {
@@ -802,22 +800,22 @@ int wl1271_cmd_data_path(struct wl1271 *wl, bool enable)
 
 	ret = wl1271_cmd_send(wl, cmd_rx, cmd, sizeof(*cmd), 0);
 	if (ret < 0) {
-		wl1271_error("rx %s cmd for channel %d failed",
-			     enable ? "start" : "stop", cmd->channel);
+		wl1271_err("rx %s cmd for channel %d failed\n",
+			   enable ? "start" : "stop", cmd->channel);
 		goto out;
 	}
 
-	wl1271_debug(DEBUG_BOOT, "rx %s cmd channel %d",
+	wl1271_debug(DEBUG_BOOT, "rx %s cmd channel %d\n",
 		     enable ? "start" : "stop", cmd->channel);
 
 	ret = wl1271_cmd_send(wl, cmd_tx, cmd, sizeof(*cmd), 0);
 	if (ret < 0) {
-		wl1271_error("tx %s cmd for channel %d failed",
-			     enable ? "start" : "stop", cmd->channel);
+		wl1271_err("tx %s cmd for channel %d failed\n",
+			   enable ? "start" : "stop", cmd->channel);
 		goto out;
 	}
 
-	wl1271_debug(DEBUG_BOOT, "tx %s cmd channel %d",
+	wl1271_debug(DEBUG_BOOT, "tx %s cmd channel %d\n",
 		     enable ? "start" : "stop", cmd->channel);
 
 out:
@@ -832,7 +830,7 @@ int wl1271_cmd_ps_mode(struct wl1271 *wl, struct wl12xx_vif *wlvif,
 	struct wl1271_cmd_ps_params *ps_params = NULL;
 	int ret = 0;
 
-	wl1271_debug(DEBUG_CMD, "cmd set ps mode");
+	wl1271_debug(DEBUG_CMD, "cmd set ps mode\n");
 
 	ps_params = kzalloc(sizeof(*ps_params), GFP_KERNEL);
 	if (!ps_params) {
@@ -847,7 +845,7 @@ int wl1271_cmd_ps_mode(struct wl1271 *wl, struct wl12xx_vif *wlvif,
 	ret = wl1271_cmd_send(wl, CMD_SET_PS_MODE, ps_params,
 			      sizeof(*ps_params), 0);
 	if (ret < 0) {
-		wl1271_error("cmd set_ps_mode failed");
+		wl1271_err("cmd set_ps_mode failed\n");
 		goto out;
 	}
 
@@ -863,7 +861,7 @@ int wl1271_cmd_template_set(struct wl1271 *wl, u8 role_id,
 	struct wl1271_cmd_template_set *cmd;
 	int ret = 0;
 
-	wl1271_debug(DEBUG_CMD, "cmd template_set %d (role %d)",
+	wl1271_debug(DEBUG_CMD, "cmd template_set %d (role %d)\n",
 		     template_id, role_id);
 
 	WARN_ON(buf_len > WL1271_CMD_TEMPL_MAX_SIZE);
@@ -889,7 +887,7 @@ int wl1271_cmd_template_set(struct wl1271 *wl, u8 role_id,
 
 	ret = wl1271_cmd_send(wl, CMD_SET_TEMPLATE, cmd, sizeof(*cmd), 0);
 	if (ret < 0) {
-		wl1271_warning("cmd set_template failed: %d", ret);
+		wl1271_warn("cmd set_template failed: %d\n", ret);
 		goto out_free;
 	}
 
@@ -927,7 +925,7 @@ int wl12xx_cmd_build_null_data(struct wl1271 *wl, struct wl12xx_vif *wlvif)
 out:
 	dev_kfree_skb(skb);
 	if (ret)
-		wl1271_warning("cmd buld null data failed %d", ret);
+		wl1271_warn("cmd buld null data failed %d\n", ret);
 
 	return ret;
 
@@ -952,7 +950,7 @@ int wl12xx_cmd_build_klv_null_data(struct wl1271 *wl,
 out:
 	dev_kfree_skb(skb);
 	if (ret)
-		wl1271_warning("cmd build klv null data failed %d", ret);
+		wl1271_warn("cmd build klv null data failed %d\n", ret);
 
 	return ret;
 
@@ -1038,7 +1036,7 @@ struct sk_buff *wl1271_cmd_build_ap_probe_req(struct wl1271 *wl,
 					      skb->data, skb->len, 0, rate);
 
 	if (ret < 0)
-		wl1271_error("Unable to set ap probe request template.");
+		wl1271_err("Unable to set ap probe request template\n");
 
 out:
 	return skb;
@@ -1057,7 +1055,7 @@ int wl1271_cmd_build_arp_rsp(struct wl1271 *wl, struct wl12xx_vif *wlvif)
 	skb = dev_alloc_skb(sizeof(*hdr) + sizeof(__le16) + sizeof(*tmpl) +
 			    WL1271_EXTRA_SPACE_MAX);
 	if (!skb) {
-		wl1271_error("failed to allocate buffer for arp rsp template");
+		wl1271_err("failed to allocate buffer for arp rsp template\n");
 		return -ENOMEM;
 	}
 
@@ -1097,8 +1095,8 @@ int wl1271_cmd_build_arp_rsp(struct wl1271 *wl, struct wl12xx_vif *wlvif)
 		extra = 0;
 		break;
 	default:
-		wl1271_warning("Unknown encryption type: %d",
-			       wlvif->encryption_type);
+		wl1271_warn("Unknown encryption type: %d\n",
+			    wlvif->encryption_type);
 		ret = -EINVAL;
 		goto out;
 	}
@@ -1165,7 +1163,7 @@ int wl12xx_cmd_set_default_wep_key(struct wl1271 *wl, u8 id, u8 hlid)
 	struct wl1271_cmd_set_keys *cmd;
 	int ret = 0;
 
-	wl1271_debug(DEBUG_CMD, "cmd set_default_wep_key %d", id);
+	wl1271_debug(DEBUG_CMD, "cmd set_default_wep_key %d\n", id);
 
 	cmd = kzalloc(sizeof(*cmd), GFP_KERNEL);
 	if (!cmd) {
@@ -1181,7 +1179,7 @@ int wl12xx_cmd_set_default_wep_key(struct wl1271 *wl, u8 id, u8 hlid)
 
 	ret = wl1271_cmd_send(wl, CMD_SET_KEYS, cmd, sizeof(*cmd), 0);
 	if (ret < 0) {
-		wl1271_warning("cmd set_default_wep_key failed: %d", ret);
+		wl1271_warn("cmd set_default_wep_key failed: %d\n", ret);
 		goto out;
 	}
 
@@ -1246,7 +1244,7 @@ int wl1271_cmd_set_sta_key(struct wl1271 *wl, struct wl12xx_vif *wlvif,
 
 	ret = wl1271_cmd_send(wl, CMD_SET_KEYS, cmd, sizeof(*cmd), 0);
 	if (ret < 0) {
-		wl1271_warning("could not set keys");
+		wl1271_warn("could not set keys\n");
 	goto out;
 	}
 
@@ -1282,8 +1280,8 @@ int wl1271_cmd_set_ap_key(struct wl1271 *wl, struct wl12xx_vif *wlvif,
 		lid_type = UNICAST_LID_TYPE;
 	}
 
-	wl1271_debug(DEBUG_CRYPT, "ap key action: %d id: %d lid: %d type: %d"
-		     " hlid: %d", (int)action, (int)id, (int)lid_type,
+	wl1271_debug(DEBUG_CRYPT, "ap key action: %d id: %d lid: %d type: %d hlid: %d\n",
+		     (int)action, (int)id, (int)lid_type,
 		     (int)key_type, (int)hlid);
 
 	cmd->lid_key_type = lid_type;
@@ -1313,7 +1311,7 @@ int wl1271_cmd_set_ap_key(struct wl1271 *wl, struct wl12xx_vif *wlvif,
 
 	ret = wl1271_cmd_send(wl, CMD_SET_KEYS, cmd, sizeof(*cmd), 0);
 	if (ret < 0) {
-		wl1271_warning("could not set ap keys");
+		wl1271_warn("could not set ap keys\n");
 		goto out;
 	}
 
@@ -1327,7 +1325,7 @@ int wl12xx_cmd_set_peer_state(struct wl1271 *wl, u8 hlid)
 	struct wl12xx_cmd_set_peer_state *cmd;
 	int ret = 0;
 
-	wl1271_debug(DEBUG_CMD, "cmd set peer state (hlid=%d)", hlid);
+	wl1271_debug(DEBUG_CMD, "cmd set peer state (hlid=%d)\n", hlid);
 
 	cmd = kzalloc(sizeof(*cmd), GFP_KERNEL);
 	if (!cmd) {
@@ -1340,7 +1338,7 @@ int wl12xx_cmd_set_peer_state(struct wl1271 *wl, u8 hlid)
 
 	ret = wl1271_cmd_send(wl, CMD_SET_PEER_STATE, cmd, sizeof(*cmd), 0);
 	if (ret < 0) {
-		wl1271_error("failed to send set peer state command");
+		wl1271_err("failed to send set peer state command\n");
 		goto out_free;
 	}
 
@@ -1358,7 +1356,7 @@ int wl12xx_cmd_add_peer(struct wl1271 *wl, struct wl12xx_vif *wlvif,
 	int i, ret;
 	u32 sta_rates;
 
-	wl1271_debug(DEBUG_CMD, "cmd add peer %d", (int)hlid);
+	wl1271_debug(DEBUG_CMD, "cmd add peer %d\n", (int)hlid);
 
 	cmd = kzalloc(sizeof(*cmd), GFP_KERNEL);
 	if (!cmd) {
@@ -1392,12 +1390,12 @@ int wl12xx_cmd_add_peer(struct wl1271 *wl, struct wl12xx_vif *wlvif,
 		cpu_to_le32(wl1271_tx_enabled_rates_get(wl, sta_rates,
 							wlvif->band));
 
-	wl1271_debug(DEBUG_CMD, "new peer rates=0x%x queues=0x%x",
+	wl1271_debug(DEBUG_CMD, "new peer rates=0x%x queues=0x%x\n",
 		     cmd->supported_rates, sta->uapsd_queues);
 
 	ret = wl1271_cmd_send(wl, CMD_ADD_PEER, cmd, sizeof(*cmd), 0);
 	if (ret < 0) {
-		wl1271_error("failed to initiate cmd add peer");
+		wl1271_err("failed to initiate cmd add peer\n");
 		goto out_free;
 	}
 
@@ -1413,7 +1411,7 @@ int wl12xx_cmd_remove_peer(struct wl1271 *wl, u8 hlid)
 	struct wl12xx_cmd_remove_peer *cmd;
 	int ret;
 
-	wl1271_debug(DEBUG_CMD, "cmd remove peer %d", (int)hlid);
+	wl1271_debug(DEBUG_CMD, "cmd remove peer %d\n", (int)hlid);
 
 	cmd = kzalloc(sizeof(*cmd), GFP_KERNEL);
 	if (!cmd) {
@@ -1428,7 +1426,7 @@ int wl12xx_cmd_remove_peer(struct wl1271 *wl, u8 hlid)
 
 	ret = wl1271_cmd_send(wl, CMD_REMOVE_PEER, cmd, sizeof(*cmd), 0);
 	if (ret < 0) {
-		wl1271_error("failed to initiate cmd remove peer");
+		wl1271_err("failed to initiate cmd remove peer\n");
 		goto out_free;
 	}
 
@@ -1451,7 +1449,7 @@ int wl12xx_cmd_config_fwlog(struct wl1271 *wl)
 	struct wl12xx_cmd_config_fwlog *cmd;
 	int ret = 0;
 
-	wl1271_debug(DEBUG_CMD, "cmd config firmware logger");
+	wl1271_debug(DEBUG_CMD, "cmd config firmware logger\n");
 
 	cmd = kzalloc(sizeof(*cmd), GFP_KERNEL);
 	if (!cmd) {
@@ -1467,7 +1465,7 @@ int wl12xx_cmd_config_fwlog(struct wl1271 *wl)
 
 	ret = wl1271_cmd_send(wl, CMD_CONFIG_FWLOGGER, cmd, sizeof(*cmd), 0);
 	if (ret < 0) {
-		wl1271_error("failed to send config firmware logger command");
+		wl1271_err("failed to send config firmware logger command\n");
 		goto out_free;
 	}
 
@@ -1483,7 +1481,7 @@ int wl12xx_cmd_start_fwlog(struct wl1271 *wl)
 	struct wl12xx_cmd_start_fwlog *cmd;
 	int ret = 0;
 
-	wl1271_debug(DEBUG_CMD, "cmd start firmware logger");
+	wl1271_debug(DEBUG_CMD, "cmd start firmware logger\n");
 
 	cmd = kzalloc(sizeof(*cmd), GFP_KERNEL);
 	if (!cmd) {
@@ -1493,7 +1491,7 @@ int wl12xx_cmd_start_fwlog(struct wl1271 *wl)
 
 	ret = wl1271_cmd_send(wl, CMD_START_FWLOGGER, cmd, sizeof(*cmd), 0);
 	if (ret < 0) {
-		wl1271_error("failed to send start firmware logger command");
+		wl1271_err("failed to send start firmware logger command\n");
 		goto out_free;
 	}
 
@@ -1509,7 +1507,7 @@ int wl12xx_cmd_stop_fwlog(struct wl1271 *wl)
 	struct wl12xx_cmd_stop_fwlog *cmd;
 	int ret = 0;
 
-	wl1271_debug(DEBUG_CMD, "cmd stop firmware logger");
+	wl1271_debug(DEBUG_CMD, "cmd stop firmware logger\n");
 
 	cmd = kzalloc(sizeof(*cmd), GFP_KERNEL);
 	if (!cmd) {
@@ -1519,7 +1517,7 @@ int wl12xx_cmd_stop_fwlog(struct wl1271 *wl)
 
 	ret = wl1271_cmd_send(wl, CMD_STOP_FWLOGGER, cmd, sizeof(*cmd), 0);
 	if (ret < 0) {
-		wl1271_error("failed to send stop firmware logger command");
+		wl1271_err("failed to send stop firmware logger command\n");
 		goto out_free;
 	}
 
@@ -1536,7 +1534,7 @@ static int wl12xx_cmd_roc(struct wl1271 *wl, struct wl12xx_vif *wlvif,
 	struct wl12xx_cmd_roc *cmd;
 	int ret = 0;
 
-	wl1271_debug(DEBUG_CMD, "cmd roc %d (%d)", wlvif->channel, role_id);
+	wl1271_debug(DEBUG_CMD, "cmd roc %d (%d)\n", wlvif->channel, role_id);
 
 	if (WARN_ON(role_id == WL12XX_INVALID_ROLE_ID))
 		return -EINVAL;
@@ -1557,7 +1555,7 @@ static int wl12xx_cmd_roc(struct wl1271 *wl, struct wl12xx_vif *wlvif,
 		cmd->band = WLCORE_BAND_5GHZ;
 		break;
 	default:
-		wl1271_error("roc - unknown band: %d", (int)wlvif->band);
+		wl1271_err("roc - unknown band: %d\n", (int)wlvif->band);
 		ret = -EINVAL;
 		goto out_free;
 	}
@@ -1565,7 +1563,7 @@ static int wl12xx_cmd_roc(struct wl1271 *wl, struct wl12xx_vif *wlvif,
 
 	ret = wl1271_cmd_send(wl, CMD_REMAIN_ON_CHANNEL, cmd, sizeof(*cmd), 0);
 	if (ret < 0) {
-		wl1271_error("failed to send ROC command");
+		wl1271_err("failed to send ROC command\n");
 		goto out_free;
 	}
 
@@ -1581,7 +1579,7 @@ static int wl12xx_cmd_croc(struct wl1271 *wl, u8 role_id)
 	struct wl12xx_cmd_croc *cmd;
 	int ret = 0;
 
-	wl1271_debug(DEBUG_CMD, "cmd croc (%d)", role_id);
+	wl1271_debug(DEBUG_CMD, "cmd croc (%d)\n", role_id);
 
 	cmd = kzalloc(sizeof(*cmd), GFP_KERNEL);
 	if (!cmd) {
@@ -1593,7 +1591,7 @@ static int wl12xx_cmd_croc(struct wl1271 *wl, u8 role_id)
 	ret = wl1271_cmd_send(wl, CMD_CANCEL_REMAIN_ON_CHANNEL, cmd,
 			      sizeof(*cmd), 0);
 	if (ret < 0) {
-		wl1271_error("failed to send ROC command");
+		wl1271_err("failed to send ROC command\n");
 		goto out_free;
 	}
 
@@ -1623,7 +1621,7 @@ int wl12xx_roc(struct wl1271 *wl, struct wl12xx_vif *wlvif, u8 role_id)
 		ret = wl1271_cmd_wait_for_event(wl,
 					   REMAIN_ON_CHANNEL_COMPLETE_EVENT_ID);
 		if (ret < 0) {
-			wl1271_error("cmd roc event completion error");
+			wl1271_err("cmd roc event completion error\n");
 			goto out;
 		}
 	}
@@ -1664,7 +1662,7 @@ int wl12xx_cmd_channel_switch(struct wl1271 *wl,
 	struct wl12xx_cmd_channel_switch *cmd;
 	int ret;
 
-	wl1271_debug(DEBUG_ACX, "cmd channel switch");
+	wl1271_debug(DEBUG_ACX, "cmd channel switch\n");
 
 	cmd = kzalloc(sizeof(*cmd), GFP_KERNEL);
 	if (!cmd) {
@@ -1682,7 +1680,7 @@ int wl12xx_cmd_channel_switch(struct wl1271 *wl,
 
 	ret = wl1271_cmd_send(wl, CMD_CHANNEL_SWITCH, cmd, sizeof(*cmd), 0);
 	if (ret < 0) {
-		wl1271_error("failed to send channel switch command");
+		wl1271_err("failed to send channel switch command\n");
 		goto out_free;
 	}
 
@@ -1698,7 +1696,7 @@ int wl12xx_cmd_stop_channel_switch(struct wl1271 *wl)
 	struct wl12xx_cmd_stop_channel_switch *cmd;
 	int ret;
 
-	wl1271_debug(DEBUG_ACX, "cmd stop channel switch");
+	wl1271_debug(DEBUG_ACX, "cmd stop channel switch\n");
 
 	cmd = kzalloc(sizeof(*cmd), GFP_KERNEL);
 	if (!cmd) {
@@ -1708,7 +1706,7 @@ int wl12xx_cmd_stop_channel_switch(struct wl1271 *wl)
 
 	ret = wl1271_cmd_send(wl, CMD_STOP_CHANNEL_SWICTH, cmd, sizeof(*cmd), 0);
 	if (ret < 0) {
-		wl1271_error("failed to stop channel switch command");
+		wl1271_err("failed to stop channel switch command\n");
 		goto out_free;
 	}
 
diff --git a/drivers/net/wireless/ti/wlcore/debug.h b/drivers/net/wireless/ti/wlcore/debug.h
index 6b800b3..83b72c2 100644
--- a/drivers/net/wireless/ti/wlcore/debug.h
+++ b/drivers/net/wireless/ti/wlcore/debug.h
@@ -61,22 +61,22 @@ extern u32 wl12xx_debug_level;
 
 #define DEBUG_DUMP_LIMIT 1024
 
-#define wl1271_error(fmt, arg...) \
-	pr_err(DRIVER_PREFIX "ERROR " fmt "\n", ##arg)
+#define wl1271_err(fmt, arg...)				\
+	pr_err(DRIVER_PREFIX "ERROR " fmt, ##arg)
 
-#define wl1271_warning(fmt, arg...) \
-	pr_warning(DRIVER_PREFIX "WARNING " fmt "\n", ##arg)
+#define wl1271_warn(fmt, arg...)				\
+	pr_warn(DRIVER_PREFIX "WARNING " fmt, ##arg)
 
-#define wl1271_notice(fmt, arg...) \
-	pr_info(DRIVER_PREFIX fmt "\n", ##arg)
+#define wl1271_notice(fmt, arg...)		\
+	pr_info(DRIVER_PREFIX fmt, ##arg)
 
-#define wl1271_info(fmt, arg...) \
-	pr_info(DRIVER_PREFIX fmt "\n", ##arg)
+#define wl1271_info(fmt, arg...)		\
+	pr_info(DRIVER_PREFIX fmt, ##arg)
 
-#define wl1271_debug(level, fmt, arg...) \
-	do { \
+#define wl1271_debug(level, fmt, arg...)	\
+	do {					\
 		if (level & wl12xx_debug_level) \
-			pr_debug(DRIVER_PREFIX fmt "\n", ##arg); \
+			pr_debug(DRIVER_PREFIX fmt, ##arg); \
 	} while (0)
 
 /* TODO: use pr_debug_hex_dump when it becomes available */
diff --git a/drivers/net/wireless/ti/wlcore/debugfs.c b/drivers/net/wireless/ti/wlcore/debugfs.c
index 689a847..d5bbc9a 100644
--- a/drivers/net/wireless/ti/wlcore/debugfs.c
+++ b/drivers/net/wireless/ti/wlcore/debugfs.c
@@ -109,7 +109,7 @@ static void chip_op_handler(struct wl1271 *wl, unsigned long value,
 	int (*chip_op) (struct wl1271 *wl);
 
 	if (!arg) {
-		wl1271_warning("debugfs chip_op_handler with no callback");
+		wl1271_warn("debugfs chip_op_handler with no callback\n");
 		return;
 	}
 
@@ -153,12 +153,12 @@ static inline void no_write_handler(struct wl1271 *wl,
 									\
 	ret = kstrtoul_from_user(user_buf, count, 10, &value);		\
 	if (ret < 0) {							\
-		wl1271_warning("illegal value for " #param);		\
+		wl1271_warn("illegal value for " #param);		\
 		return -EINVAL;						\
 	}								\
 									\
 	if (value < min_val || value > max_val) {			\
-		wl1271_warning(#param " is not in valid range");	\
+		wl1271_warn(#param " is not in valid range");		\
 		return -ERANGE;						\
 	}								\
 									\
@@ -209,7 +209,7 @@ static ssize_t gpio_power_write(struct file *file,
 
 	ret = kstrtoul_from_user(user_buf, count, 10, &value);
 	if (ret < 0) {
-		wl1271_warning("illegal value in gpio_power");
+		wl1271_warn("illegal value in gpio_power\n");
 		return -EINVAL;
 	}
 
@@ -271,12 +271,12 @@ static ssize_t dynamic_ps_timeout_write(struct file *file,
 
 	ret = kstrtoul_from_user(user_buf, count, 10, &value);
 	if (ret < 0) {
-		wl1271_warning("illegal value in dynamic_ps");
+		wl1271_warn("illegal value in dynamic_ps\n");
 		return -EINVAL;
 	}
 
 	if (value < 1 || value > 65535) {
-		wl1271_warning("dyanmic_ps_timeout is not in valid range");
+		wl1271_warn("dyanmic_ps_timeout is not in valid range\n");
 		return -ERANGE;
 	}
 
@@ -335,12 +335,12 @@ static ssize_t forced_ps_write(struct file *file,
 
 	ret = kstrtoul_from_user(user_buf, count, 10, &value);
 	if (ret < 0) {
-		wl1271_warning("illegal value in forced_ps");
+		wl1271_warn("illegal value in forced_ps\n");
 		return -EINVAL;
 	}
 
 	if (value != 1 && value != 0) {
-		wl1271_warning("forced_ps should be either 0 or 1");
+		wl1271_warn("forced_ps should be either 0 or 1\n");
 		return -ERANGE;
 	}
 
@@ -403,12 +403,12 @@ static ssize_t split_scan_timeout_write(struct file *file,
 
 	ret = kstrtoul_from_user(user_buf, count, 10, &value);
 	if (ret < 0) {
-		wl1271_warning("illegal value in split_scan_timeout");
+		wl1271_warn("illegal value in split_scan_timeout\n");
 		return -EINVAL;
 	}
 
 	if (value == 0)
-		wl1271_info("split scan will be disabled");
+		wl1271_info("split scan will be disabled\n");
 
 	mutex_lock(&wl->mutex);
 
@@ -641,12 +641,12 @@ static ssize_t dtim_interval_write(struct file *file,
 
 	ret = kstrtoul_from_user(user_buf, count, 10, &value);
 	if (ret < 0) {
-		wl1271_warning("illegal value for dtim_interval");
+		wl1271_warn("illegal value for dtim_interval\n");
 		return -EINVAL;
 	}
 
 	if (value < 1 || value > 10) {
-		wl1271_warning("dtim value is not in valid range");
+		wl1271_warn("dtim value is not in valid range\n");
 		return -ERANGE;
 	}
 
@@ -702,12 +702,12 @@ static ssize_t suspend_dtim_interval_write(struct file *file,
 
 	ret = kstrtoul_from_user(user_buf, count, 10, &value);
 	if (ret < 0) {
-		wl1271_warning("illegal value for suspend_dtim_interval");
+		wl1271_warn("illegal value for suspend_dtim_interval\n");
 		return -EINVAL;
 	}
 
 	if (value < 1 || value > 10) {
-		wl1271_warning("suspend_dtim value is not in valid range");
+		wl1271_warn("suspend_dtim value is not in valid range\n");
 		return -ERANGE;
 	}
 
@@ -757,12 +757,12 @@ static ssize_t beacon_interval_write(struct file *file,
 
 	ret = kstrtoul_from_user(user_buf, count, 10, &value);
 	if (ret < 0) {
-		wl1271_warning("illegal value for beacon_interval");
+		wl1271_warn("illegal value for beacon_interval\n");
 		return -EINVAL;
 	}
 
 	if (value < 1 || value > 255) {
-		wl1271_warning("beacon interval value is not in valid range");
+		wl1271_warn("beacon interval value is not in valid range\n");
 		return -ERANGE;
 	}
 
@@ -801,13 +801,13 @@ static ssize_t rx_streaming_interval_write(struct file *file,
 
 	ret = kstrtoul_from_user(user_buf, count, 10, &value);
 	if (ret < 0) {
-		wl1271_warning("illegal value in rx_streaming_interval!");
+		wl1271_warn("illegal value in rx_streaming_interval!\n");
 		return -EINVAL;
 	}
 
 	/* valid values: 0, 10-100 */
 	if (value && (value < 10 || value > 100)) {
-		wl1271_warning("value is not in range!");
+		wl1271_warn("value is not in range!\n");
 		return -ERANGE;
 	}
 
@@ -856,13 +856,13 @@ static ssize_t rx_streaming_always_write(struct file *file,
 
 	ret = kstrtoul_from_user(user_buf, count, 10, &value);
 	if (ret < 0) {
-		wl1271_warning("illegal value in rx_streaming_write!");
+		wl1271_warn("illegal value in rx_streaming_write!\n");
 		return -EINVAL;
 	}
 
 	/* valid values: 0, 10-100 */
 	if (!(value == 0 || value == 1)) {
-		wl1271_warning("value is not in valid!");
+		wl1271_warn("value is not in valid!\n");
 		return -EINVAL;
 	}
 
@@ -918,7 +918,7 @@ static ssize_t beacon_filtering_write(struct file *file,
 
 	ret = kstrtoul(buf, 0, &value);
 	if (ret < 0) {
-		wl1271_warning("illegal value for beacon_filtering!");
+		wl1271_warn("illegal value for beacon_filtering!\n");
 		return -EINVAL;
 	}
 
diff --git a/drivers/net/wireless/ti/wlcore/event.c b/drivers/net/wireless/ti/wlcore/event.c
index c976f04..49217f7 100644
--- a/drivers/net/wireless/ti/wlcore/event.c
+++ b/drivers/net/wireless/ti/wlcore/event.c
@@ -120,15 +120,15 @@ static int wl1271_event_process(struct wl1271 *wl)
 	}
 
 	if (vector & PERIODIC_SCAN_REPORT_EVENT_ID) {
-		wl1271_debug(DEBUG_EVENT, "PERIODIC_SCAN_REPORT_EVENT "
-			     "(status 0x%0x)", mbox->scheduled_scan_status);
+		wl1271_debug(DEBUG_EVENT, "PERIODIC_SCAN_REPORT_EVENT (status 0x%0x)\n",
+			     mbox->scheduled_scan_status);
 
 		wl1271_scan_sched_scan_results(wl);
 	}
 
 	if (vector & PERIODIC_SCAN_COMPLETE_EVENT_ID) {
-		wl1271_debug(DEBUG_EVENT, "PERIODIC_SCAN_COMPLETE_EVENT "
-			     "(status 0x%0x)", mbox->scheduled_scan_status);
+		wl1271_debug(DEBUG_EVENT, "PERIODIC_SCAN_COMPLETE_EVENT (status 0x%0x)\n",
+			     mbox->scheduled_scan_status);
 		if (wl->sched_scanning) {
 			ieee80211_sched_scan_stopped(wl->hw);
 			wl->sched_scanning = false;
@@ -187,8 +187,7 @@ static int wl1271_event_process(struct wl1271 *wl)
 
 	if (vector & BA_SESSION_RX_CONSTRAINT_EVENT_ID) {
 		u8 role_id = mbox->role_id;
-		wl1271_debug(DEBUG_EVENT, "BA_SESSION_RX_CONSTRAINT_EVENT_ID. "
-			     "ba_allowed = 0x%x, role_id=%d",
+		wl1271_debug(DEBUG_EVENT, "BA_SESSION_RX_CONSTRAINT_EVENT_ID. ba_allowed = 0x%x, role_id=%d\n",
 			     mbox->rx_ba_allowed, role_id);
 
 		wl12xx_for_each_wlvif(wl, wlvif) {
@@ -202,9 +201,8 @@ static int wl1271_event_process(struct wl1271 *wl)
 	}
 
 	if (vector & CHANNEL_SWITCH_COMPLETE_EVENT_ID) {
-		wl1271_debug(DEBUG_EVENT, "CHANNEL_SWITCH_COMPLETE_EVENT_ID. "
-					  "status = 0x%x",
-					  mbox->channel_switch_status);
+		wl1271_debug(DEBUG_EVENT, "CHANNEL_SWITCH_COMPLETE_EVENT_ID. status = 0x%x\n",
+			     mbox->channel_switch_status);
 		/*
 		 * That event uses for two cases:
 		 * 1) channel switch complete with status=0
diff --git a/drivers/net/wireless/ti/wlcore/main.c b/drivers/net/wireless/ti/wlcore/main.c
index 1156e3f..3795568 100644
--- a/drivers/net/wireless/ti/wlcore/main.c
+++ b/drivers/net/wireless/ti/wlcore/main.c
@@ -85,7 +85,7 @@ static int wl12xx_set_authorized(struct wl1271 *wl,
 
 	wl12xx_croc(wl, wlvif->role_id);
 
-	wl1271_info("Association completed.");
+	wl1271_info("Association completed\n");
 	return 0;
 }
 
@@ -260,7 +260,7 @@ static void wl12xx_tx_watchdog_work(struct work_struct *work)
 	 * time (e.g. pending Tx on the non-ROC channels)
 	 */
 	if (find_first_bit(wl->roc_map, WL12XX_MAX_ROLES) < WL12XX_MAX_ROLES) {
-		wl1271_debug(DEBUG_TX, "No Tx (in FW) for %d ms due to ROC",
+		wl1271_debug(DEBUG_TX, "No Tx (in FW) for %d ms due to ROC\n",
 			     wl->conf.tx.tx_watchdog_timeout);
 		wl12xx_rearm_tx_watchdog_locked(wl);
 		goto out;
@@ -271,7 +271,7 @@ static void wl12xx_tx_watchdog_work(struct work_struct *work)
 	 * time
 	 */
 	if (wl->scan.state != WL1271_SCAN_STATE_IDLE) {
-		wl1271_debug(DEBUG_TX, "No Tx (in FW) for %d ms due to scan",
+		wl1271_debug(DEBUG_TX, "No Tx (in FW) for %d ms due to scan\n",
 			     wl->conf.tx.tx_watchdog_timeout);
 		wl12xx_rearm_tx_watchdog_locked(wl);
 		goto out;
@@ -284,16 +284,15 @@ static void wl12xx_tx_watchdog_work(struct work_struct *work)
 	* stations are removed due to inactivity.
 	*/
 	if (wl->active_sta_count) {
-		wl1271_debug(DEBUG_TX, "No Tx (in FW) for %d ms. AP has "
-			     " %d stations",
-			      wl->conf.tx.tx_watchdog_timeout,
-			      wl->active_sta_count);
+		wl1271_debug(DEBUG_TX, "No Tx (in FW) for %d ms. AP has %d stations\n",
+			     wl->conf.tx.tx_watchdog_timeout,
+			     wl->active_sta_count);
 		wl12xx_rearm_tx_watchdog_locked(wl);
 		goto out;
 	}
 
-	wl1271_error("Tx stuck (in FW) for %d ms. Starting recovery",
-		     wl->conf.tx.tx_watchdog_timeout);
+	wl1271_err("Tx stuck (in FW) for %d ms. Starting recovery.\n",
+		   wl->conf.tx.tx_watchdog_timeout);
 	wl12xx_queue_recovery_work(wl);
 
 out:
@@ -315,7 +314,7 @@ static void wlcore_adjust_conf(struct wl1271 *wl)
 			wl->conf.fwlog.mem_blocks = 0;
 			wl->conf.fwlog.output = WL12XX_FWLOG_OUTPUT_NONE;
 		} else {
-			wl1271_error("Unknown fwlog parameter %s", fwlog_param);
+			wl1271_err("Unknown fwlog parameter %s\n", fwlog_param);
 		}
 	}
 }
@@ -358,7 +357,7 @@ static void wl12xx_irq_update_links_status(struct wl1271 *wl,
 	cur_fw_ps_map = le32_to_cpu(status->link_ps_bitmap);
 	if (wl->ap_fw_ps_map != cur_fw_ps_map) {
 		wl1271_debug(DEBUG_PSM,
-			     "link ps prev 0x%x cur 0x%x changed 0x%x",
+			     "link ps prev 0x%x cur 0x%x changed 0x%x\n",
 			     wl->ap_fw_ps_map, cur_fw_ps_map,
 			     wl->ap_fw_ps_map ^ cur_fw_ps_map);
 
@@ -395,8 +394,7 @@ static void wl12xx_fw_status(struct wl1271 *wl,
 	wlcore_raw_read_data(wl, REG_RAW_FW_STATUS_ADDR, status_1,
 			     status_len, false);
 
-	wl1271_debug(DEBUG_IRQ, "intr: 0x%x (fw_rx_counter = %d, "
-		     "drv_rx_counter = %d, tx_results_counter = %d)",
+	wl1271_debug(DEBUG_IRQ, "intr: 0x%x (fw_rx_counter = %d, drv_rx_counter = %d, tx_results_counter = %d)\n",
 		     status_1->intr,
 		     status_1->fw_rx_counter,
 		     status_1->drv_rx_counter,
@@ -512,7 +510,7 @@ static irqreturn_t wl1271_irq(int irq, void *cookie)
 
 	mutex_lock(&wl->mutex);
 
-	wl1271_debug(DEBUG_IRQ, "IRQ work");
+	wl1271_debug(DEBUG_IRQ, "IRQ work\n");
 
 	if (unlikely(wl->state == WL1271_STATE_OFF))
 		goto out;
@@ -542,7 +540,7 @@ static irqreturn_t wl1271_irq(int irq, void *cookie)
 		}
 
 		if (unlikely(intr & WL1271_ACX_INTR_WATCHDOG)) {
-			wl1271_error("HW watchdog interrupt received! starting recovery.");
+			wl1271_err("HW watchdog interrupt received! Starting recovery.\n");
 			wl->watchdog_recovery = true;
 			wl12xx_queue_recovery_work(wl);
 
@@ -551,8 +549,7 @@ static irqreturn_t wl1271_irq(int irq, void *cookie)
 		}
 
 		if (unlikely(intr & WL1271_ACX_SW_INTR_WATCHDOG)) {
-			wl1271_error("SW watchdog interrupt received! "
-				     "starting recovery.");
+			wl1271_err("SW watchdog interrupt received! Starting recovery.\n");
 			wl->watchdog_recovery = true;
 			wl12xx_queue_recovery_work(wl);
 
@@ -561,7 +558,7 @@ static irqreturn_t wl1271_irq(int irq, void *cookie)
 		}
 
 		if (likely(intr & WL1271_ACX_INTR_DATA)) {
-			wl1271_debug(DEBUG_IRQ, "WL1271_ACX_INTR_DATA");
+			wl1271_debug(DEBUG_IRQ, "WL1271_ACX_INTR_DATA\n");
 
 			wl12xx_rx(wl, wl->fw_status_1);
 
@@ -590,21 +587,21 @@ static irqreturn_t wl1271_irq(int irq, void *cookie)
 		}
 
 		if (intr & WL1271_ACX_INTR_EVENT_A) {
-			wl1271_debug(DEBUG_IRQ, "WL1271_ACX_INTR_EVENT_A");
+			wl1271_debug(DEBUG_IRQ, "WL1271_ACX_INTR_EVENT_A\n");
 			wl1271_event_handle(wl, 0);
 		}
 
 		if (intr & WL1271_ACX_INTR_EVENT_B) {
-			wl1271_debug(DEBUG_IRQ, "WL1271_ACX_INTR_EVENT_B");
+			wl1271_debug(DEBUG_IRQ, "WL1271_ACX_INTR_EVENT_B\n");
 			wl1271_event_handle(wl, 1);
 		}
 
 		if (intr & WL1271_ACX_INTR_INIT_COMPLETE)
 			wl1271_debug(DEBUG_IRQ,
-				     "WL1271_ACX_INTR_INIT_COMPLETE");
+				     "WL1271_ACX_INTR_INIT_COMPLETE\n");
 
 		if (intr & WL1271_ACX_INTR_HW_AVAILABLE)
-			wl1271_debug(DEBUG_IRQ, "WL1271_ACX_INTR_HW_AVAILABLE");
+			wl1271_debug(DEBUG_IRQ, "WL1271_ACX_INTR_HW_AVAILABLE\n");
 	}
 
 	wl1271_ps_elp_sleep(wl);
@@ -679,18 +676,18 @@ static int wl12xx_fetch_firmware(struct wl1271 *wl, bool plt)
 	if (wl->fw_type == fw_type)
 		return 0;
 
-	wl1271_debug(DEBUG_BOOT, "booting firmware %s", fw_name);
+	wl1271_debug(DEBUG_BOOT, "booting firmware %s\n", fw_name);
 
 	ret = request_firmware(&fw, fw_name, wl->dev);
 
 	if (ret < 0) {
-		wl1271_error("could not get firmware %s: %d", fw_name, ret);
+		wl1271_err("could not get firmware %s: %d\n", fw_name, ret);
 		return ret;
 	}
 
 	if (fw->size % 4) {
-		wl1271_error("firmware size is not multiple of 32 bits: %zu",
-			     fw->size);
+		wl1271_err("firmware size is not multiple of 32 bits: %zu\n",
+			   fw->size);
 		ret = -EILSEQ;
 		goto out;
 	}
@@ -701,7 +698,7 @@ static int wl12xx_fetch_firmware(struct wl1271 *wl, bool plt)
 	wl->fw = vmalloc(wl->fw_len);
 
 	if (!wl->fw) {
-		wl1271_error("could not allocate memory for the firmware");
+		wl1271_err("could not allocate memory for the firmware\n");
 		ret = -ENOMEM;
 		goto out;
 	}
@@ -723,7 +720,7 @@ static void wl1271_fetch_nvs(struct wl1271 *wl)
 	ret = request_firmware(&fw, WL12XX_NVS_NAME, wl->dev);
 
 	if (ret < 0) {
-		wl1271_debug(DEBUG_BOOT, "could not get nvs file %s: %d",
+		wl1271_debug(DEBUG_BOOT, "could not get nvs file %s: %d\n",
 			     WL12XX_NVS_NAME, ret);
 		return;
 	}
@@ -731,7 +728,7 @@ static void wl1271_fetch_nvs(struct wl1271 *wl)
 	wl->nvs = kmemdup(fw->data, fw->size, GFP_KERNEL);
 
 	if (!wl->nvs) {
-		wl1271_error("could not allocate memory for the nvs file");
+		wl1271_err("could not allocate memory for the nvs file\n");
 		goto out;
 	}
 
@@ -781,7 +778,7 @@ static void wl12xx_read_fwlog_panic(struct wl1271 *wl)
 	    (wl->conf.fwlog.mem_blocks == 0))
 		return;
 
-	wl1271_info("Reading FW panic log");
+	wl1271_info("Reading FW panic log\n");
 
 	block = kmalloc(WL12XX_HW_BLOCK_SIZE, GFP_KERNEL);
 	if (!block)
@@ -845,8 +842,7 @@ static void wl1271_recovery_work(struct work_struct *work)
 
 	/* change partitions momentarily so we can read the FW pc */
 	wlcore_set_partition(wl, &wl->ptable[PART_BOOT]);
-	wl1271_info("Hardware recovery in progress. FW ver: %s pc: 0x%x "
-		    "hint_sts: 0x%08x",
+	wl1271_info("Hardware recovery in progress. FW ver: %s pc: 0x%x hint_sts: 0x%08x\n",
 		    wl->chip.fw_ver_str,
 		    wlcore_read_reg(wl, REG_PC_ON_RECOVERY),
 		    wlcore_read_reg(wl, REG_INTERRUPT_NO_CLEAR));
@@ -856,7 +852,7 @@ static void wl1271_recovery_work(struct work_struct *work)
 	       !test_bit(WL1271_FLAG_INTENDED_FW_RECOVERY, &wl->flags));
 
 	if (no_recovery) {
-		wl1271_info("No recovery (chosen on module load). Fw will remain stuck.");
+		wl1271_info("No recovery (chosen on module load). Fw will remain stuck.\n");
 		clear_bit(WL1271_FLAG_RECOVERY_IN_PROGRESS, &wl->flags);
 		goto out_unlock;
 	}
@@ -998,11 +994,11 @@ int wl1271_plt_start(struct wl1271 *wl)
 
 	mutex_lock(&wl->mutex);
 
-	wl1271_notice("power up");
+	wl1271_notice("power up\n");
 
 	if (wl->state != WL1271_STATE_OFF) {
-		wl1271_error("cannot go into PLT state because not "
-			     "in off state: %d", wl->state);
+		wl1271_err("cannot go into PLT state because not in off state: %d\n",
+			   wl->state);
 		ret = -EBUSY;
 		goto out;
 	}
@@ -1019,7 +1015,7 @@ int wl1271_plt_start(struct wl1271 *wl)
 
 		wl->plt = true;
 		wl->state = WL1271_STATE_ON;
-		wl1271_notice("firmware booted in PLT mode (%s)",
+		wl1271_notice("firmware booted in PLT mode (%s)\n",
 			      wl->chip.fw_ver_str);
 
 		/* update hw/fw version info in wiphy struct */
@@ -1033,8 +1029,8 @@ power_off:
 		wl1271_power_off(wl);
 	}
 
-	wl1271_error("firmware boot in PLT mode failed despite %d retries",
-		     WL1271_BOOT_RETRIES);
+	wl1271_err("firmware boot in PLT mode failed despite %d retries\n",
+		   WL1271_BOOT_RETRIES);
 out:
 	mutex_unlock(&wl->mutex);
 
@@ -1045,7 +1041,7 @@ int wl1271_plt_stop(struct wl1271 *wl)
 {
 	int ret = 0;
 
-	wl1271_notice("power down");
+	wl1271_notice("power down\n");
 
 	/*
 	 * Interrupts must be disabled before setting the state to OFF.
@@ -1064,8 +1060,8 @@ int wl1271_plt_stop(struct wl1271 *wl)
 		 */
 		wlcore_enable_interrupts(wl);
 
-		wl1271_error("cannot power down because not in PLT "
-			     "state: %d", wl->state);
+		wl1271_err("cannot power down because not in PLT state: %d\n",
+			   wl->state);
 		ret = -EBUSY;
 		goto out;
 	}
@@ -1121,12 +1117,12 @@ static void wl1271_op_tx(struct ieee80211_hw *hw, struct sk_buff *skb)
 	     (wlcore_is_queue_stopped(wl, q) &&
 	      !wlcore_is_queue_stopped_by_reason(wl, q,
 			WLCORE_QUEUE_STOP_REASON_WATERMARK))) {
-		wl1271_debug(DEBUG_TX, "DROP skb hlid %d q %d", hlid, q);
+		wl1271_debug(DEBUG_TX, "DROP skb hlid %d q %d\n", hlid, q);
 		ieee80211_free_txskb(hw, skb);
 		goto out;
 	}
 
-	wl1271_debug(DEBUG_TX, "queue skb hlid %d q %d len %d",
+	wl1271_debug(DEBUG_TX, "queue skb hlid %d q %d len %d\n",
 		     hlid, q, skb->len);
 	skb_queue_tail(&wl->links[hlid].tx_queue[q], skb);
 
@@ -1137,7 +1133,7 @@ static void wl1271_op_tx(struct ieee80211_hw *hw, struct sk_buff *skb)
 	 * the queue here, otherwise the queue will get too long.
 	 */
 	if (wl->tx_queue_count[q] >= WL1271_TX_QUEUE_HIGH_WATERMARK) {
-		wl1271_debug(DEBUG_TX, "op_tx: stopping queues for q %d", q);
+		wl1271_debug(DEBUG_TX, "op_tx: stopping queues for q %d\n", q);
 		wlcore_stop_queue_locked(wl, q,
 					 WLCORE_QUEUE_STOP_REASON_WATERMARK);
 	}
@@ -1200,7 +1196,7 @@ static struct sk_buff *wl12xx_alloc_dummy_packet(struct wl1271 *wl)
 
 	skb = dev_alloc_skb(TOTAL_TX_DUMMY_PACKET_SIZE);
 	if (!skb) {
-		wl1271_warning("Failed to allocate a dummy packet skb");
+		wl1271_warn("Failed to allocate a dummy packet skb\n");
 		return NULL;
 	}
 
@@ -1233,7 +1229,7 @@ wl1271_validate_wowlan_pattern(struct cfg80211_wowlan_trig_pkt_pattern *p)
 	int i, pattern_len = 0;
 
 	if (!p->mask) {
-		wl1271_warning("No mask in WoWLAN pattern");
+		wl1271_warn("No mask in WoWLAN pattern\n");
 		return -EINVAL;
 	}
 
@@ -1276,12 +1272,12 @@ wl1271_validate_wowlan_pattern(struct cfg80211_wowlan_trig_pkt_pattern *p)
 	}
 
 	if (num_fields > WL1271_RX_FILTER_MAX_FIELDS) {
-		wl1271_warning("RX Filter too complex. Too many segments");
+		wl1271_warn("RX Filter too complex. Too many segments\n");
 		return -EINVAL;
 	}
 
 	if (fields_size > WL1271_RX_FILTER_MAX_FIELDS_SIZE) {
-		wl1271_warning("RX filter pattern is too big");
+		wl1271_warn("RX filter pattern is too big\n");
 		return -E2BIG;
 	}
 
@@ -1313,7 +1309,7 @@ int wl1271_rx_filter_alloc_field(struct wl12xx_rx_filter *filter,
 	struct wl12xx_rx_filter_field *field;
 
 	if (filter->num_fields == WL1271_RX_FILTER_MAX_FIELDS) {
-		wl1271_warning("Max fields per RX filter. can't alloc another");
+		wl1271_warn("Max fields per RX filter. can't alloc another\n");
 		return -EINVAL;
 	}
 
@@ -1321,7 +1317,7 @@ int wl1271_rx_filter_alloc_field(struct wl12xx_rx_filter *filter,
 
 	field->pattern = kzalloc(len, GFP_KERNEL);
 	if (!field->pattern) {
-		wl1271_warning("Failed to allocate RX filter pattern");
+		wl1271_warn("Failed to allocate RX filter pattern\n");
 		return -ENOMEM;
 	}
 
@@ -1381,7 +1377,7 @@ static int wl1271_convert_wowlan_pattern_to_rx_filter(
 
 	filter = wl1271_rx_filter_alloc();
 	if (!filter) {
-		wl1271_warning("Failed to alloc rx filter");
+		wl1271_warn("Failed to alloc rx filter\n");
 		ret = -ENOMEM;
 		goto err;
 	}
@@ -1452,7 +1448,7 @@ static int wl1271_configure_wowlan(struct wl1271 *wl,
 	for (i = 0; i < wow->n_patterns; i++) {
 		ret = wl1271_validate_wowlan_pattern(&wow->patterns[i]);
 		if (ret) {
-			wl1271_warning("Bad wowlan pattern %d", i);
+			wl1271_warn("Bad wowlan pattern %d\n", i);
 			return ret;
 		}
 	}
@@ -1469,8 +1465,8 @@ static int wl1271_configure_wowlan(struct wl1271 *wl,
 
 		ret = wl1271_convert_wowlan_pattern_to_rx_filter(p, &filter);
 		if (ret) {
-			wl1271_warning("Failed to create an RX filter from "
-				       "wowlan pattern %d", i);
+			wl1271_warn("Failed to create an RX filter from wowlan pattern %d\n",
+				    i);
 			goto out;
 		}
 
@@ -1506,7 +1502,7 @@ static int wl1271_configure_suspend_sta(struct wl1271 *wl,
 				    wl->conf.conn.suspend_listen_interval);
 
 	if (ret < 0)
-		wl1271_error("suspend: set wake up conditions failed: %d", ret);
+		wl1271_err("suspend: set wake up conditions failed: %d\n", ret);
 
 	wl1271_ps_elp_sleep(wl);
 
@@ -1568,8 +1564,8 @@ static void wl1271_configure_resume(struct wl1271 *wl,
 				    wl->conf.conn.listen_interval);
 
 		if (ret < 0)
-			wl1271_error("resume: wake up conditions failed: %d",
-				     ret);
+			wl1271_err("resume: wake up conditions failed: %d\n",
+				   ret);
 
 	} else if (is_ap) {
 		ret = wl1271_acx_beacon_filter_opt(wl, wlvif, false);
@@ -1596,7 +1592,7 @@ static int wl1271_op_suspend(struct ieee80211_hw *hw,
 		ret = wl1271_configure_suspend(wl, wlvif, wow);
 		if (ret < 0) {
 			mutex_unlock(&wl->mutex);
-			wl1271_warning("couldn't prepare device to suspend");
+			wl1271_warn("couldn't prepare device to suspend\n");
 			return ret;
 		}
 	}
@@ -1815,7 +1811,7 @@ static u8 wl12xx_get_role_type(struct wl1271 *wl, struct wl12xx_vif *wlvif)
 		return WL1271_ROLE_IBSS;
 
 	default:
-		wl1271_error("invalid bss_type: %d", wlvif->bss_type);
+		wl1271_err("invalid bss_type: %d\n", wlvif->bss_type);
 	}
 	return WL12XX_INVALID_ROLE_TYPE;
 }
@@ -1949,12 +1945,12 @@ power_off:
 	}
 
 	if (!booted) {
-		wl1271_error("firmware boot failed despite %d retries",
-			     WL1271_BOOT_RETRIES);
+		wl1271_err("firmware boot failed despite %d retries\n",
+			   WL1271_BOOT_RETRIES);
 		goto out;
 	}
 
-	wl1271_info("firmware booted (%s)", wl->chip.fw_ver_str);
+	wl1271_info("firmware booted (%s)\n", wl->chip.fw_ver_str);
 
 	/* update hw/fw version info in wiphy struct */
 	wiphy->hw_version = wl->chip.id;
@@ -2156,7 +2152,7 @@ static void __wl1271_op_remove_interface(struct wl1271 *wl,
 	if (wl->state != WL1271_STATE_ON)
 		return;
 
-	wl1271_info("down");
+	wl1271_info("down\n");
 
 	if (wl->scan.state != WL1271_SCAN_STATE_IDLE &&
 	    wl->scan_vif == vif) {
@@ -2314,7 +2310,7 @@ static int wl1271_join(struct wl1271 *wl, struct wl12xx_vif *wlvif,
 	 * users who really like to roam a lot :)
 	 */
 	if (test_bit(WLVIF_FLAG_STA_ASSOCIATED, &wlvif->flags))
-		wl1271_info("JOIN while associated.");
+		wl1271_info("JOIN while associated\n");
 
 	/* clear encryption type */
 	wlvif->encryption_type = KEY_NONE;
@@ -2456,8 +2452,8 @@ static int wl12xx_config_vif(struct wl1271 *wl, struct wl12xx_vif *wlvif,
 		if (is_ap) {
 			ret = wl1271_init_ap_rates(wl, wlvif);
 			if (ret < 0)
-				wl1271_error("AP rate policy change failed %d",
-					     ret);
+				wl1271_err("AP rate policy change failed %d\n",
+					   ret);
 		} else {
 			/*
 			 * FIXME: the mac80211 should really provide a fixed
@@ -2473,8 +2469,8 @@ static int wl12xx_config_vif(struct wl1271 *wl, struct wl12xx_vif *wlvif,
 						       wlvif->basic_rate_set);
 			ret = wl1271_acx_sta_rate_policies(wl, wlvif);
 			if (ret < 0)
-				wl1271_warning("rate policy for channel "
-					       "failed %d", ret);
+				wl1271_warn("rate policy for channel failed %d\n",
+					    ret);
 
 			/*
 			 * change the ROC channel. do it only if we are
@@ -2513,23 +2509,23 @@ static int wl12xx_config_vif(struct wl1271 *wl, struct wl12xx_vif *wlvif,
 				ps_mode_str = "auto";
 			}
 
-			wl1271_debug(DEBUG_PSM, "%s ps enabled", ps_mode_str);
+			wl1271_debug(DEBUG_PSM, "%s ps enabled\n", ps_mode_str);
 
 			ret = wl1271_ps_set_mode(wl, wlvif, ps_mode);
 
 			if (ret < 0)
-				wl1271_warning("enter %s ps failed %d",
-					       ps_mode_str, ret);
+				wl1271_warn("enter %s ps failed %d\n",
+					    ps_mode_str, ret);
 
 		} else if (!(conf->flags & IEEE80211_CONF_PS) &&
 			   test_bit(WLVIF_FLAG_IN_PS, &wlvif->flags)) {
 
-			wl1271_debug(DEBUG_PSM, "auto ps disabled");
+			wl1271_debug(DEBUG_PSM, "auto ps disabled\n");
 
 			ret = wl1271_ps_set_mode(wl, wlvif,
 						 STATION_ACTIVE_MODE);
 			if (ret < 0)
-				wl1271_warning("exit auto ps failed %d", ret);
+				wl1271_warn("exit auto ps failed %d\n", ret);
 		}
 	}
 
@@ -2553,13 +2549,12 @@ static int wl1271_op_config(struct ieee80211_hw *hw, u32 changed)
 
 	channel = ieee80211_frequency_to_channel(conf->channel->center_freq);
 
-	wl1271_debug(DEBUG_MAC80211, "mac80211 config ch %d psm %s power %d %s"
-		     " changed 0x%x",
+	wl1271_debug(DEBUG_MAC80211, "mac80211 config ch %d psm %s power %d %s changed 0x%x\n",
 		     channel,
 		     conf->flags & IEEE80211_CONF_PS ? "on" : "off",
 		     conf->power_level,
 		     conf->flags & IEEE80211_CONF_IDLE ? "idle" : "in use",
-			 changed);
+		     changed);
 
 	/*
 	 * mac80211 will go to idle nearly immediately after transmitting some
@@ -2624,7 +2619,7 @@ static u64 wl1271_op_prepare_multicast(struct ieee80211_hw *hw,
 
 	fp = kzalloc(sizeof(*fp), GFP_ATOMIC);
 	if (!fp) {
-		wl1271_error("Out of memory setting filters.");
+		wl1271_err("Out of memory setting filters\n");
 		return 0;
 	}
 
@@ -2661,8 +2656,8 @@ static void wl1271_op_configure_filter(struct ieee80211_hw *hw,
 
 	int ret;
 
-	wl1271_debug(DEBUG_MAC80211, "mac80211 configure filter changed %x"
-		     " total %x", changed, *total);
+	wl1271_debug(DEBUG_MAC80211, "mac80211 configure filter changed %x total %x\n",
+		     changed, *total);
 
 	mutex_lock(&wl->mutex);
 
@@ -2714,7 +2709,7 @@ static int wl1271_record_ap_key(struct wl1271 *wl, struct wl12xx_vif *wlvif,
 	struct wl1271_ap_key *ap_key;
 	int i;
 
-	wl1271_debug(DEBUG_CRYPT, "record ap key id %d", (int)id);
+	wl1271_debug(DEBUG_CRYPT, "record ap key id %d\n", (int)id);
 
 	if (key_size > MAX_KEY_SIZE)
 		return -EINVAL;
@@ -2728,7 +2723,7 @@ static int wl1271_record_ap_key(struct wl1271 *wl, struct wl12xx_vif *wlvif,
 			break;
 
 		if (wlvif->ap.recorded_keys[i]->id == id) {
-			wl1271_warning("trying to record key replacement");
+			wl1271_warn("trying to record key replacement\n");
 			return -EINVAL;
 		}
 	}
@@ -2910,8 +2905,8 @@ int wlcore_set_key(struct wl1271 *wl, enum set_key_cmd cmd,
 
 	wl1271_debug(DEBUG_MAC80211, "mac80211 set key");
 
-	wl1271_debug(DEBUG_CRYPT, "CMD: 0x%x sta: %p", cmd, sta);
-	wl1271_debug(DEBUG_CRYPT, "Key: algo:0x%x, id:%d, len:%d flags 0x%x",
+	wl1271_debug(DEBUG_CRYPT, "CMD: 0x%x sta: %p\n", cmd, sta);
+	wl1271_debug(DEBUG_CRYPT, "Key: algo:0x%x, id:%d, len:%d flags 0x%x\n",
 		     key_conf->cipher, key_conf->keyidx,
 		     key_conf->keylen, key_conf->flags);
 	wl1271_dump(DEBUG_CRYPT, "KEY: ", key_conf->key, key_conf->keylen);
@@ -2954,7 +2949,7 @@ int wlcore_set_key(struct wl1271 *wl, enum set_key_cmd cmd,
 		tx_seq_16 = WL1271_TX_SECURITY_LO16(wlvif->tx_security_seq);
 		break;
 	default:
-		wl1271_error("Unknown key algo 0x%x", key_conf->cipher);
+		wl1271_err("Unknown key algo 0x%x\n", key_conf->cipher);
 
 		ret = -EOPNOTSUPP;
 		goto out_sleep;
@@ -2967,7 +2962,7 @@ int wlcore_set_key(struct wl1271 *wl, enum set_key_cmd cmd,
 				 key_conf->keylen, key_conf->key,
 				 tx_seq_32, tx_seq_16, sta);
 		if (ret < 0) {
-			wl1271_error("Could not add or replace key");
+			wl1271_err("Could not add or replace key\n");
 			goto out_sleep;
 		}
 
@@ -2981,7 +2976,7 @@ int wlcore_set_key(struct wl1271 *wl, enum set_key_cmd cmd,
 			wlvif->encryption_type = key_type;
 			ret = wl1271_cmd_build_arp_rsp(wl, wlvif);
 			if (ret < 0) {
-				wl1271_warning("build arp rsp failed: %d", ret);
+				wl1271_warn("build arp rsp failed: %d\n", ret);
 				goto out_sleep;
 			}
 		}
@@ -2993,13 +2988,13 @@ int wlcore_set_key(struct wl1271 *wl, enum set_key_cmd cmd,
 				     key_conf->keylen, key_conf->key,
 				     0, 0, sta);
 		if (ret < 0) {
-			wl1271_error("Could not remove key");
+			wl1271_err("Could not remove key\n");
 			goto out_sleep;
 		}
 		break;
 
 	default:
-		wl1271_error("Unsupported key cmd 0x%x", cmd);
+		wl1271_err("Unsupported key cmd 0x%x\n", cmd);
 		ret = -EOPNOTSUPP;
 		break;
 	}
@@ -3190,7 +3185,7 @@ static int wl1271_op_set_frag_threshold(struct ieee80211_hw *hw, u32 value)
 
 	ret = wl1271_acx_frag_threshold(wl, value);
 	if (ret < 0)
-		wl1271_warning("wl1271_op_set_frag_threshold failed: %d", ret);
+		wl1271_warn("wl1271_op_set_frag_threshold failed: %d\n", ret);
 
 	wl1271_ps_elp_sleep(wl);
 
@@ -3220,7 +3215,7 @@ static int wl1271_op_set_rts_threshold(struct ieee80211_hw *hw, u32 value)
 	wl12xx_for_each_wlvif(wl, wlvif) {
 		ret = wl1271_acx_rts_threshold(wl, wlvif, value);
 		if (ret < 0)
-			wl1271_warning("set rts threshold failed: %d", ret);
+			wl1271_warn("set rts threshold failed: %d\n", ret);
 	}
 	wl1271_ps_elp_sleep(wl);
 
@@ -3239,13 +3234,13 @@ static int wl1271_ssid_set(struct ieee80211_vif *vif, struct sk_buff *skb,
 					 skb->len - offset);
 
 	if (!ptr) {
-		wl1271_error("No SSID in IEs!");
+		wl1271_err("No SSID in IEs!\n");
 		return -ENOENT;
 	}
 
 	ssid_len = ptr[1];
 	if (ssid_len > IEEE80211_MAX_SSID_LEN) {
-		wl1271_error("SSID is too long!");
+		wl1271_err("SSID is too long!\n");
 		return -EINVAL;
 	}
 
@@ -3306,7 +3301,7 @@ static int wl1271_ap_set_probe_resp_tmpl(struct wl1271 *wl, u32 rates,
 	if (ret < 0)
 		goto out;
 
-	wl1271_debug(DEBUG_AP, "probe response updated");
+	wl1271_debug(DEBUG_AP, "probe response updated\n");
 	set_bit(WLVIF_FLAG_AP_PROBE_RESP_SET, &wlvif->flags);
 
 out:
@@ -3334,7 +3329,7 @@ static int wl1271_ap_set_probe_resp_tmpl_legacy(struct wl1271 *wl,
 					       rates);
 
 	if (probe_rsp_len + bss_conf->ssid_len > WL1271_CMD_TEMPL_MAX_SIZE) {
-		wl1271_error("probe_rsp template too big");
+		wl1271_err("probe_rsp template too big\n");
 		return -EINVAL;
 	}
 
@@ -3344,7 +3339,7 @@ static int wl1271_ap_set_probe_resp_tmpl_legacy(struct wl1271 *wl,
 	ptr = cfg80211_find_ie(WLAN_EID_SSID, probe_rsp_data + ie_offset,
 			       probe_rsp_len - ie_offset);
 	if (!ptr) {
-		wl1271_error("No SSID in beacon!");
+		wl1271_err("No SSID in beacon!\n");
 		return -EINVAL;
 	}
 
@@ -3385,7 +3380,7 @@ static int wl1271_bss_erp_info_changed(struct wl1271 *wl,
 		else
 			ret = wl1271_acx_slot(wl, wlvif, SLOT_TIME_LONG);
 		if (ret < 0) {
-			wl1271_warning("Set slot time failed %d", ret);
+			wl1271_warn("Set slot time failed %d\n", ret);
 			goto out;
 		}
 	}
@@ -3405,7 +3400,7 @@ static int wl1271_bss_erp_info_changed(struct wl1271 *wl,
 			ret = wl1271_acx_cts_protect(wl, wlvif,
 						     CTSPROTECT_DISABLE);
 		if (ret < 0) {
-			wl1271_warning("Set ctsprotect failed %d", ret);
+			wl1271_warn("Set ctsprotect failed %d\n", ret);
 			goto out;
 		}
 	}
@@ -3432,7 +3427,7 @@ static int wlcore_set_beacon_template(struct wl1271 *wl,
 		goto out;
 	}
 
-	wl1271_debug(DEBUG_MASTER, "beacon updated");
+	wl1271_debug(DEBUG_MASTER, "beacon updated\n");
 
 	ret = wl1271_ssid_set(vif, beacon, ieoffset);
 	if (ret < 0) {
@@ -3505,8 +3500,8 @@ static int wl1271_bss_beacon_info_changed(struct wl1271 *wl,
 	int ret = 0;
 
 	if ((changed & BSS_CHANGED_BEACON_INT)) {
-		wl1271_debug(DEBUG_MASTER, "beacon interval updated: %d",
-			bss_conf->beacon_int);
+		wl1271_debug(DEBUG_MASTER, "beacon interval updated: %d\n",
+			     bss_conf->beacon_int);
 
 		wlvif->beacon_int = bss_conf->beacon_int;
 	}
@@ -3525,7 +3520,7 @@ static int wl1271_bss_beacon_info_changed(struct wl1271 *wl,
 
 out:
 	if (ret != 0)
-		wl1271_error("beacon info change failed: %d", ret);
+		wl1271_err("beacon info change failed: %d\n", ret);
 	return ret;
 }
 
@@ -3548,7 +3543,7 @@ static void wl1271_bss_info_changed_ap(struct wl1271 *wl,
 
 		ret = wl1271_init_ap_rates(wl, wlvif);
 		if (ret < 0) {
-			wl1271_error("AP rate policy change failed %d", ret);
+			wl1271_err("AP rate policy change failed %d\n", ret);
 			goto out;
 		}
 
@@ -3581,7 +3576,7 @@ static void wl1271_bss_info_changed_ap(struct wl1271 *wl,
 					goto out;
 
 				set_bit(WLVIF_FLAG_AP_STARTED, &wlvif->flags);
-				wl1271_debug(DEBUG_AP, "started AP");
+				wl1271_debug(DEBUG_AP, "started AP\n");
 			}
 		} else {
 			if (test_bit(WLVIF_FLAG_AP_STARTED, &wlvif->flags)) {
@@ -3592,7 +3587,7 @@ static void wl1271_bss_info_changed_ap(struct wl1271 *wl,
 				clear_bit(WLVIF_FLAG_AP_STARTED, &wlvif->flags);
 				clear_bit(WLVIF_FLAG_AP_PROBE_RESP_SET,
 					  &wlvif->flags);
-				wl1271_debug(DEBUG_AP, "stopped AP");
+				wl1271_debug(DEBUG_AP, "stopped AP\n");
 			}
 		}
 	}
@@ -3607,7 +3602,7 @@ static void wl1271_bss_info_changed_ap(struct wl1271 *wl,
 		ret = wl1271_acx_set_ht_information(wl, wlvif,
 					bss_conf->ht_operation_mode);
 		if (ret < 0) {
-			wl1271_warning("Set ht information failed %d", ret);
+			wl1271_warn("Set ht information failed %d\n", ret);
 			goto out;
 		}
 	}
@@ -3658,7 +3653,7 @@ static void wl1271_bss_info_changed_sta(struct wl1271 *wl,
 		do_join = true;
 
 	if ((changed & BSS_CHANGED_BEACON_ENABLED) && ibss_joined) {
-		wl1271_debug(DEBUG_ADHOC, "ad-hoc beaconing: %s",
+		wl1271_debug(DEBUG_ADHOC, "ad-hoc beaconing: %s\n",
 			     bss_conf->enable_beacon ? "enabled" : "disabled");
 
 		do_join = true;
@@ -3667,7 +3662,7 @@ static void wl1271_bss_info_changed_sta(struct wl1271 *wl,
 	if (changed & BSS_CHANGED_IDLE && !is_ibss) {
 		ret = wl1271_sta_handle_idle(wl, wlvif, bss_conf->idle);
 		if (ret < 0)
-			wl1271_warning("idle mode change failed %d", ret);
+			wl1271_warn("idle mode change failed %d\n", ret);
 	}
 
 	if ((changed & BSS_CHANGED_CQM)) {
@@ -3829,7 +3824,7 @@ sta_not_found:
 	}
 
 	if (changed & BSS_CHANGED_IBSS) {
-		wl1271_debug(DEBUG_ADHOC, "ibss_joined: %d",
+		wl1271_debug(DEBUG_ADHOC, "ibss_joined: %d\n",
 			     bss_conf->ibss_joined);
 
 		if (bss_conf->ibss_joined) {
@@ -3856,7 +3851,7 @@ sta_not_found:
 	if (do_join) {
 		ret = wl1271_join(wl, wlvif, set_assoc);
 		if (ret < 0) {
-			wl1271_warning("cmd join failed %d", ret);
+			wl1271_warn("cmd join failed %d\n", ret);
 			goto out;
 		}
 
@@ -3889,8 +3884,8 @@ sta_not_found:
 							     true,
 							     wlvif->sta.hlid);
 			if (ret < 0) {
-				wl1271_warning("Set ht cap true failed %d",
-					       ret);
+				wl1271_warn("Set ht cap true failed %d\n",
+					    ret);
 				goto out;
 			}
 		}
@@ -3901,8 +3896,8 @@ sta_not_found:
 							     false,
 							     wlvif->sta.hlid);
 			if (ret < 0) {
-				wl1271_warning("Set ht cap false failed %d",
-					       ret);
+				wl1271_warn("Set ht cap false failed %d\n",
+					    ret);
 				goto out;
 			}
 		}
@@ -3914,7 +3909,7 @@ sta_not_found:
 		ret = wl1271_acx_set_ht_information(wl, wlvif,
 					bss_conf->ht_operation_mode);
 		if (ret < 0) {
-			wl1271_warning("Set ht information failed %d", ret);
+			wl1271_warn("Set ht information failed %d\n", ret);
 			goto out;
 		}
 	}
@@ -3937,7 +3932,7 @@ sta_not_found:
 			 */
 			ret = wl1271_cmd_build_arp_rsp(wl, wlvif);
 			if (ret < 0) {
-				wl1271_warning("build arp rsp failed: %d", ret);
+				wl1271_warn("build arp rsp failed: %d\n", ret);
 				goto out;
 			}
 
@@ -4112,14 +4107,14 @@ static int wl1271_allocate_sta(struct wl1271 *wl,
 
 
 	if (wl->active_sta_count >= AP_MAX_STATIONS) {
-		wl1271_warning("could not allocate HLID - too much stations");
+		wl1271_warn("could not allocate HLID - too much stations\n");
 		return -EBUSY;
 	}
 
 	wl_sta = (struct wl1271_station *)sta->drv_priv;
 	ret = wl12xx_allocate_link(wl, wlvif, &wl_sta->hlid);
 	if (ret < 0) {
-		wl1271_warning("could not allocate HLID - too many links");
+		wl1271_warn("could not allocate HLID - too many links\n");
 		return -EBUSY;
 	}
 
@@ -4344,14 +4339,14 @@ static int wl1271_op_ampdu_action(struct ieee80211_hw *hw,
 
 		if (wl->ba_rx_session_count >= RX_BA_MAX_SESSIONS) {
 			ret = -EBUSY;
-			wl1271_error("exceeded max RX BA sessions");
+			wl1271_err("exceeded max RX BA sessions\n");
 			break;
 		}
 
 		if (*ba_bitmap & BIT(tid)) {
 			ret = -EINVAL;
-			wl1271_error("cannot enable RX BA session on active "
-				     "tid: %d", tid);
+			wl1271_err("cannot enable RX BA session on active tid: %d\n",
+				   tid);
 			break;
 		}
 
@@ -4366,8 +4361,8 @@ static int wl1271_op_ampdu_action(struct ieee80211_hw *hw,
 	case IEEE80211_AMPDU_RX_STOP:
 		if (!(*ba_bitmap & BIT(tid))) {
 			ret = -EINVAL;
-			wl1271_error("no active RX BA session on tid: %d",
-				     tid);
+			wl1271_err("no active RX BA session on tid: %d\n",
+				   tid);
 			break;
 		}
 
@@ -4390,7 +4385,7 @@ static int wl1271_op_ampdu_action(struct ieee80211_hw *hw,
 		break;
 
 	default:
-		wl1271_error("Incorrect ampdu action id=%x\n", action);
+		wl1271_err("Incorrect ampdu action id=%x\n", action);
 		ret = -EINVAL;
 	}
 
@@ -4411,8 +4406,8 @@ static int wl12xx_set_bitrate_mask(struct ieee80211_hw *hw,
 	int i, ret = 0;
 
 	wl1271_debug(DEBUG_MAC80211, "mac80211 set_bitrate_mask 0x%x 0x%x",
-		mask->control[NL80211_BAND_2GHZ].legacy,
-		mask->control[NL80211_BAND_5GHZ].legacy);
+		     mask->control[NL80211_BAND_2GHZ].legacy,
+		     mask->control[NL80211_BAND_5GHZ].legacy);
 
 	mutex_lock(&wl->mutex);
 
@@ -4685,13 +4680,13 @@ u8 wlcore_rate_to_idx(struct wl1271 *wl, u8 rate, enum ieee80211_band band)
 	BUG_ON(band >= 2);
 
 	if (unlikely(rate >= wl->hw_tx_rate_tbl_size)) {
-		wl1271_error("Illegal RX rate from HW: %d", rate);
+		wl1271_err("Illegal RX rate from HW: %d\n", rate);
 		return 0;
 	}
 
 	idx = wl->band_rate_to_idx[band][rate];
 	if (unlikely(idx == CONF_HW_RXTX_RATE_UNSUPPORTED)) {
-		wl1271_error("Unsupported RX rate from HW: %d", rate);
+		wl1271_err("Unsupported RX rate from HW: %d\n", rate);
 		return 0;
 	}
 
@@ -4726,7 +4721,7 @@ static ssize_t wl1271_sysfs_store_bt_coex_state(struct device *dev,
 
 	ret = kstrtoul(buf, 10, &res);
 	if (ret < 0) {
-		wl1271_warning("incorrect value written to bt_coex_mode");
+		wl1271_warn("incorrect value written to bt_coex_mode\n");
 		return count;
 	}
 
@@ -4853,7 +4848,7 @@ static void wl1271_connection_loss_work(struct work_struct *work)
 	dwork = container_of(work, struct delayed_work, work);
 	wl = container_of(dwork, struct wl1271, connection_loss_work);
 
-	wl1271_info("Connection loss work.");
+	wl1271_info("Connection loss work\n");
 
 	mutex_lock(&wl->mutex);
 
@@ -4876,11 +4871,11 @@ static void wl12xx_derive_mac_addresses(struct wl1271 *wl,
 {
 	int i;
 
-	wl1271_debug(DEBUG_PROBE, "base address: oui %06x nic %06x, n %d",
+	wl1271_debug(DEBUG_PROBE, "base address: oui %06x nic %06x, n %d\n",
 		     oui, nic, n);
 
 	if (nic + n - 1 > 0xffffff)
-		wl1271_warning("NIC part of the MAC address wraps around!");
+		wl1271_warn("NIC part of the MAC address wraps around!\n");
 
 	for (i = 0; i < n; i++) {
 		wl->addresses[i].addr[0] = (u8)(oui >> 16);
@@ -4952,7 +4947,7 @@ static int wl1271_register_hw(struct wl1271 *wl)
 
 	ret = ieee80211_register_hw(wl->hw);
 	if (ret < 0) {
-		wl1271_error("unable to register mac80211 hw: %d", ret);
+		wl1271_err("unable to register mac80211 hw: %d\n", ret);
 		goto out;
 	}
 
@@ -4960,7 +4955,7 @@ static int wl1271_register_hw(struct wl1271 *wl)
 
 	wl1271_debugfs_init(wl);
 
-	wl1271_notice("loaded");
+	wl1271_notice("loaded\n");
 
 out:
 	return ret;
@@ -5092,7 +5087,7 @@ struct ieee80211_hw *wlcore_alloc_hw(size_t priv_size)
 
 	hw = ieee80211_alloc_hw(sizeof(*wl), &wl1271_ops);
 	if (!hw) {
-		wl1271_error("could not alloc ieee80211_hw");
+		wl1271_err("could not alloc ieee80211_hw\n");
 		ret = -ENOMEM;
 		goto err_hw_alloc;
 	}
@@ -5102,7 +5097,7 @@ struct ieee80211_hw *wlcore_alloc_hw(size_t priv_size)
 
 	wl->priv = kzalloc(priv_size, GFP_KERNEL);
 	if (!wl->priv) {
-		wl1271_error("could not alloc wl priv");
+		wl1271_err("could not alloc wl priv\n");
 		ret = -ENOMEM;
 		goto err_priv_alloc;
 	}
@@ -5260,7 +5255,7 @@ static irqreturn_t wl12xx_hardirq(int irq, void *cookie)
 	struct wl1271 *wl = cookie;
 	unsigned long flags;
 
-	wl1271_debug(DEBUG_IRQ, "IRQ");
+	wl1271_debug(DEBUG_IRQ, "IRQ\n");
 
 	/* complete the ELP completion */
 	spin_lock_irqsave(&wl->wl_lock, flags);
@@ -5273,7 +5268,7 @@ static irqreturn_t wl12xx_hardirq(int irq, void *cookie)
 	if (test_bit(WL1271_FLAG_SUSPENDED, &wl->flags)) {
 		/* don't enqueue a work right now. mark it as pending */
 		set_bit(WL1271_FLAG_PENDING_WORK, &wl->flags);
-		wl1271_debug(DEBUG_IRQ, "should not enqueue work");
+		wl1271_debug(DEBUG_IRQ, "should not enqueue work\n");
 		disable_irq_nosync(wl->irq);
 		pm_wakeup_event(wl->dev, 0);
 		spin_unlock_irqrestore(&wl->wl_lock, flags);
@@ -5317,7 +5312,7 @@ int __devinit wlcore_probe(struct wl1271 *wl, struct platform_device *pdev)
 				   irqflags,
 				   pdev->name, wl);
 	if (ret < 0) {
-		wl1271_error("request_irq() failed: %d", ret);
+		wl1271_err("request_irq() failed: %d\n", ret);
 		goto out_free_hw;
 	}
 
@@ -5338,7 +5333,7 @@ int __devinit wlcore_probe(struct wl1271 *wl, struct platform_device *pdev)
 
 	ret = wl12xx_get_hw_info(wl);
 	if (ret < 0) {
-		wl1271_error("couldn't get hw info");
+		wl1271_err("couldn't get hw info\n");
 		goto out;
 	}
 
@@ -5357,21 +5352,21 @@ int __devinit wlcore_probe(struct wl1271 *wl, struct platform_device *pdev)
 	/* Create sysfs file to control bt coex state */
 	ret = device_create_file(wl->dev, &dev_attr_bt_coex_state);
 	if (ret < 0) {
-		wl1271_error("failed to create sysfs file bt_coex_state");
+		wl1271_err("failed to create sysfs file bt_coex_state\n");
 		goto out_irq;
 	}
 
 	/* Create sysfs file to get HW PG version */
 	ret = device_create_file(wl->dev, &dev_attr_hw_pg_ver);
 	if (ret < 0) {
-		wl1271_error("failed to create sysfs file hw_pg_ver");
+		wl1271_err("failed to create sysfs file hw_pg_ver\n");
 		goto out_bt_coex_state;
 	}
 
 	/* Create sysfs file for the FW log */
 	ret = device_create_bin_file(wl->dev, &fwlog_attr);
 	if (ret < 0) {
-		wl1271_error("failed to create sysfs file fwlog");
+		wl1271_err("failed to create sysfs file fwlog\n");
 		goto out_hw_pg_ver;
 	}
 
diff --git a/drivers/net/wireless/ti/wlcore/ps.c b/drivers/net/wireless/ti/wlcore/ps.c
index 47e81b3..eef201f4 100644
--- a/drivers/net/wireless/ti/wlcore/ps.c
+++ b/drivers/net/wireless/ti/wlcore/ps.c
@@ -39,7 +39,7 @@ void wl1271_elp_work(struct work_struct *work)
 	dwork = container_of(work, struct delayed_work, work);
 	wl = container_of(dwork, struct wl1271, elp_work);
 
-	wl1271_debug(DEBUG_PSM, "elp work");
+	wl1271_debug(DEBUG_PSM, "elp work\n");
 
 	mutex_lock(&wl->mutex);
 
@@ -62,7 +62,7 @@ void wl1271_elp_work(struct work_struct *work)
 			goto out;
 	}
 
-	wl1271_debug(DEBUG_PSM, "chip to elp");
+	wl1271_debug(DEBUG_PSM, "chip to elp\n");
 	wl1271_raw_write32(wl, HW_ACCESS_ELP_CTRL_REG, ELPCTRL_SLEEP);
 	set_bit(WL1271_FLAG_IN_ELP, &wl->flags);
 
@@ -122,7 +122,7 @@ int wl1271_ps_elp_wakeup(struct wl1271 *wl)
 	if (!test_bit(WL1271_FLAG_IN_ELP, &wl->flags))
 		return 0;
 
-	wl1271_debug(DEBUG_PSM, "waking up chip from elp");
+	wl1271_debug(DEBUG_PSM, "waking up chip from elp\n");
 
 	/*
 	 * The spinlock is required here to synchronize both the work and
@@ -141,19 +141,19 @@ int wl1271_ps_elp_wakeup(struct wl1271 *wl)
 		ret = wait_for_completion_timeout(
 			&compl, msecs_to_jiffies(WL1271_WAKEUP_TIMEOUT));
 		if (ret == 0) {
-			wl1271_error("ELP wakeup timeout!");
+			wl1271_err("ELP wakeup timeout!\n");
 			wl12xx_queue_recovery_work(wl);
 			ret = -ETIMEDOUT;
 			goto err;
 		} else if (ret < 0) {
-			wl1271_error("ELP wakeup completion error.");
+			wl1271_err("ELP wakeup completion error\n");
 			goto err;
 		}
 	}
 
 	clear_bit(WL1271_FLAG_IN_ELP, &wl->flags);
 
-	wl1271_debug(DEBUG_PSM, "wakeup time: %u ms",
+	wl1271_debug(DEBUG_PSM, "wakeup time: %u ms\n",
 		     jiffies_to_msecs(jiffies - start_time));
 	goto out;
 
@@ -176,14 +176,14 @@ int wl1271_ps_set_mode(struct wl1271 *wl, struct wl12xx_vif *wlvif,
 	switch (mode) {
 	case STATION_AUTO_PS_MODE:
 	case STATION_POWER_SAVE_MODE:
-		wl1271_debug(DEBUG_PSM, "entering psm (mode=%d,timeout=%u)",
+		wl1271_debug(DEBUG_PSM, "entering psm (mode=%d,timeout=%u)\n",
 			     mode, timeout);
 
 		ret = wl1271_acx_wake_up_conditions(wl, wlvif,
 					    wl->conf.conn.wake_up_event,
 					    wl->conf.conn.listen_interval);
 		if (ret < 0) {
-			wl1271_error("couldn't set wake up conditions");
+			wl1271_err("couldn't set wake up conditions\n");
 			return ret;
 		}
 
@@ -205,7 +205,7 @@ int wl1271_ps_set_mode(struct wl1271 *wl, struct wl12xx_vif *wlvif,
 		}
 		break;
 	case STATION_ACTIVE_MODE:
-		wl1271_debug(DEBUG_PSM, "leaving psm");
+		wl1271_debug(DEBUG_PSM, "leaving psm\n");
 
 		/* disable beacon early termination */
 		if ((wlvif->band == IEEE80211_BAND_2GHZ) &&
@@ -222,7 +222,7 @@ int wl1271_ps_set_mode(struct wl1271 *wl, struct wl12xx_vif *wlvif,
 		clear_bit(WLVIF_FLAG_IN_PS, &wlvif->flags);
 		break;
 	default:
-		wl1271_warning("trying to set ps to unsupported mode %d", mode);
+		wl1271_warn("trying to set ps to unsupported mode %d\n", mode);
 		ret = -EINVAL;
 	}
 
@@ -270,15 +270,15 @@ void wl12xx_ps_link_start(struct wl1271 *wl, struct wl12xx_vif *wlvif,
 	if (test_bit(hlid, &wl->ap_ps_map))
 		return;
 
-	wl1271_debug(DEBUG_PSM, "start mac80211 PSM on hlid %d pkts %d "
-		     "clean_queues %d", hlid, wl->links[hlid].allocated_pkts,
+	wl1271_debug(DEBUG_PSM, "start mac80211 PSM on hlid %d pkts %d clean_queues %d\n",
+		     hlid, wl->links[hlid].allocated_pkts,
 		     clean_queues);
 
 	rcu_read_lock();
 	sta = ieee80211_find_sta(vif, wl->links[hlid].addr);
 	if (!sta) {
-		wl1271_error("could not find sta %pM for starting ps",
-			     wl->links[hlid].addr);
+		wl1271_err("could not find sta %pM for starting ps\n",
+			   wl->links[hlid].addr);
 		rcu_read_unlock();
 		return;
 	}
@@ -301,15 +301,15 @@ void wl12xx_ps_link_end(struct wl1271 *wl, struct wl12xx_vif *wlvif, u8 hlid)
 	if (!test_bit(hlid, &wl->ap_ps_map))
 		return;
 
-	wl1271_debug(DEBUG_PSM, "end mac80211 PSM on hlid %d", hlid);
+	wl1271_debug(DEBUG_PSM, "end mac80211 PSM on hlid %d\n", hlid);
 
 	__clear_bit(hlid, &wl->ap_ps_map);
 
 	rcu_read_lock();
 	sta = ieee80211_find_sta(vif, wl->links[hlid].addr);
 	if (!sta) {
-		wl1271_error("could not find sta %pM for ending ps",
-			     wl->links[hlid].addr);
+		wl1271_err("could not find sta %pM for ending ps\n",
+			   wl->links[hlid].addr);
 		goto end;
 	}
 
diff --git a/drivers/net/wireless/ti/wlcore/rx.c b/drivers/net/wireless/ti/wlcore/rx.c
index 78200dc..99d5021 100644
--- a/drivers/net/wireless/ti/wlcore/rx.c
+++ b/drivers/net/wireless/ti/wlcore/rx.c
@@ -94,7 +94,7 @@ static void wl1271_rx_status(struct wl1271 *wl,
 
 		if (unlikely(desc_err_code == WL1271_RX_DESC_MIC_FAIL)) {
 			status->flag |= RX_FLAG_MMIC_ERROR;
-			wl1271_warning("Michael MIC error");
+			wl1271_warn("Michael MIC error\n");
 		}
 	}
 }
@@ -121,8 +121,8 @@ static int wl1271_rx_handle_data(struct wl1271 *wl, u8 *data, u32 length,
 
 	pkt_data_len = wlcore_hw_get_rx_packet_len(wl, data, length);
 	if (!pkt_data_len) {
-		wl1271_error("Invalid packet arrived from HW. length %d",
-			     length);
+		wl1271_err("Invalid packet arrived from HW. length %d\n",
+			   length);
 		return -EINVAL;
 	}
 
@@ -143,22 +143,22 @@ static int wl1271_rx_handle_data(struct wl1271 *wl, u8 *data, u32 length,
 	/* discard corrupted packets */
 	case WL1271_RX_DESC_DRIVER_RX_Q_FAIL:
 	case WL1271_RX_DESC_DECRYPT_FAIL:
-		wl1271_warning("corrupted packet in RX with status: 0x%x",
-			       desc->status & WL1271_RX_DESC_STATUS_MASK);
+		wl1271_warn("corrupted packet in RX with status: 0x%x\n",
+			    desc->status & WL1271_RX_DESC_STATUS_MASK);
 		return -EINVAL;
 	case WL1271_RX_DESC_SUCCESS:
 	case WL1271_RX_DESC_MIC_FAIL:
 		break;
 	default:
-		wl1271_error("invalid RX descriptor status: 0x%x",
-			     desc->status & WL1271_RX_DESC_STATUS_MASK);
+		wl1271_err("invalid RX descriptor status: 0x%x\n",
+			   desc->status & WL1271_RX_DESC_STATUS_MASK);
 		return -EINVAL;
 	}
 
 	/* skb length not including rx descriptor */
 	skb = __dev_alloc_skb(pkt_data_len + reserved, GFP_KERNEL);
 	if (!skb) {
-		wl1271_error("Couldn't allocate RX frame");
+		wl1271_err("Couldn't allocate RX frame\n");
 		return -ENOMEM;
 	}
 
@@ -189,7 +189,7 @@ static int wl1271_rx_handle_data(struct wl1271 *wl, u8 *data, u32 length,
 	wlcore_hw_set_rx_csum(wl, desc, skb);
 
 	seq_num = (le16_to_cpu(hdr->seq_ctrl) & IEEE80211_SCTL_SEQ) >> 4;
-	wl1271_debug(DEBUG_RX, "rx skb 0x%p: %d B %s seq %d hlid %d", skb,
+	wl1271_debug(DEBUG_RX, "rx skb 0x%p: %d B %s seq %d hlid %d\n", skb,
 		     skb->len - desc->pad_len,
 		     beacon ? "beacon" : "",
 		     seq_num, *hlid);
@@ -228,7 +228,7 @@ void wl12xx_rx(struct wl1271 *wl, struct wl_fw_status_1 *status)
 		}
 
 		if (buf_size == 0) {
-			wl1271_warning("received empty data");
+			wl1271_warn("received empty data\n");
 			break;
 		}
 
@@ -257,9 +257,8 @@ void wl12xx_rx(struct wl1271 *wl, struct wl_fw_status_1 *status)
 				if (hlid < WL12XX_MAX_LINKS)
 					__set_bit(hlid, active_hlids);
 				else
-					WARN(1,
-					     "hlid exceeded WL12XX_MAX_LINKS "
-					     "(%d)\n", hlid);
+					WARN(1, "hlid exceeded WL12XX_MAX_LINKS (%d)\n",
+					     hlid);
 			}
 
 			wl->rx_counter++;
@@ -288,16 +287,16 @@ int wl1271_rx_filter_enable(struct wl1271 *wl,
 	int ret;
 
 	if (wl->rx_filter_enabled[index] == enable) {
-		wl1271_warning("Request to enable an already "
-			     "enabled rx filter %d", index);
+		wl1271_warn("Request to enable an already enabled rx filter %d\n",
+			    index);
 		return 0;
 	}
 
 	ret = wl1271_acx_set_rx_filter(wl, index, enable, filter);
 
 	if (ret) {
-		wl1271_error("Failed to %s rx data filter %d (err=%d)",
-			     enable ? "enable" : "disable", index, ret);
+		wl1271_err("Failed to %s rx data filter %d (err=%d)\n",
+			   enable ? "enable" : "disable", index, ret);
 		return ret;
 	}
 
diff --git a/drivers/net/wireless/ti/wlcore/scan.c b/drivers/net/wireless/ti/wlcore/scan.c
index d9daed5..f53e6ca 100644
--- a/drivers/net/wireless/ti/wlcore/scan.c
+++ b/drivers/net/wireless/ti/wlcore/scan.c
@@ -42,7 +42,7 @@ void wl1271_scan_complete_work(struct work_struct *work)
 	dwork = container_of(work, struct delayed_work, work);
 	wl = container_of(dwork, struct wl1271, scan_complete_work);
 
-	wl1271_debug(DEBUG_SCAN, "Scanning complete");
+	wl1271_debug(DEBUG_SCAN, "Scanning complete\n");
 
 	mutex_lock(&wl->mutex);
 
@@ -78,7 +78,7 @@ void wl1271_scan_complete_work(struct work_struct *work)
 	wl1271_ps_elp_sleep(wl);
 
 	if (wl->scan.failed) {
-		wl1271_info("Scan completed due to error.");
+		wl1271_info("Scan completed due to error\n");
 		wl12xx_queue_recovery_work(wl);
 	}
 
@@ -114,17 +114,17 @@ static int wl1271_get_scan_channels(struct wl1271 *wl,
 		     * marked as passive.
 		     */
 		    (passive || !(flags & IEEE80211_CHAN_PASSIVE_SCAN))) {
-			wl1271_debug(DEBUG_SCAN, "band %d, center_freq %d ",
+			wl1271_debug(DEBUG_SCAN, "band %d, center_freq %d\n",
 				     req->channels[i]->band,
 				     req->channels[i]->center_freq);
-			wl1271_debug(DEBUG_SCAN, "hw_value %d, flags %X",
+			wl1271_debug(DEBUG_SCAN, "hw_value %d, flags %X\n",
 				     req->channels[i]->hw_value,
 				     req->channels[i]->flags);
 			wl1271_debug(DEBUG_SCAN,
-				     "max_antenna_gain %d, max_power %d",
+				     "max_antenna_gain %d, max_power %d\n",
 				     req->channels[i]->max_antenna_gain,
 				     req->channels[i]->max_power);
-			wl1271_debug(DEBUG_SCAN, "beacon_found %d",
+			wl1271_debug(DEBUG_SCAN, "beacon_found %d\n",
 				     req->channels[i]->beacon_found);
 
 			if (!passive) {
@@ -228,7 +228,7 @@ static int wl1271_scan_send(struct wl1271 *wl, struct ieee80211_vif *vif,
 					 wl->scan.req->ie,
 					 wl->scan.req->ie_len);
 	if (ret < 0) {
-		wl1271_error("PROBE request template failed");
+		wl1271_err("PROBE request template failed\n");
 		goto out;
 	}
 
@@ -236,7 +236,7 @@ static int wl1271_scan_send(struct wl1271 *wl, struct ieee80211_vif *vif,
 	ret = wl1271_cmd_send(wl, CMD_TRIGGER_SCAN_TO, trigger,
 			      sizeof(*trigger), 0);
 	if (ret < 0) {
-		wl1271_error("trigger scan to failed for hw scan");
+		wl1271_err("trigger scan to failed for hw scan\n");
 		goto out;
 	}
 
@@ -244,7 +244,7 @@ static int wl1271_scan_send(struct wl1271 *wl, struct ieee80211_vif *vif,
 
 	ret = wl1271_cmd_send(wl, CMD_SCAN, cmd, sizeof(*cmd), 0);
 	if (ret < 0) {
-		wl1271_error("SCAN failed");
+		wl1271_err("SCAN failed\n");
 		goto out;
 	}
 
@@ -332,7 +332,7 @@ void wl1271_scan_stm(struct wl1271 *wl, struct ieee80211_vif *vif)
 		break;
 
 	default:
-		wl1271_error("invalid scan state");
+		wl1271_err("invalid scan state\n");
 		break;
 	}
 
@@ -387,7 +387,7 @@ int wl1271_scan_stop(struct wl1271 *wl)
 	if (WARN_ON(wl->scan.state == WL1271_SCAN_STATE_IDLE))
 		return -EINVAL;
 
-	wl1271_debug(DEBUG_CMD, "cmd scan stop");
+	wl1271_debug(DEBUG_CMD, "cmd scan stop\n");
 
 	cmd = kzalloc(sizeof(*cmd), GFP_KERNEL);
 	if (!cmd) {
@@ -398,7 +398,7 @@ int wl1271_scan_stop(struct wl1271 *wl)
 	ret = wl1271_cmd_send(wl, CMD_STOP_SCAN, cmd,
 			      sizeof(*cmd), 0);
 	if (ret < 0) {
-		wl1271_error("cmd stop_scan failed");
+		wl1271_err("cmd stop_scan failed\n");
 		goto out;
 	}
 out:
@@ -450,15 +450,15 @@ wl1271_scan_get_sched_scan_channels(struct wl1271 *wl,
 		    /* if radar is set, we ignore the passive flag */
 		    (radar ||
 		     !!(flags & IEEE80211_CHAN_PASSIVE_SCAN) == passive)) {
-			wl1271_debug(DEBUG_SCAN, "band %d, center_freq %d ",
+			wl1271_debug(DEBUG_SCAN, "band %d, center_freq %d\n",
 				     req->channels[i]->band,
 				     req->channels[i]->center_freq);
-			wl1271_debug(DEBUG_SCAN, "hw_value %d, flags %X",
+			wl1271_debug(DEBUG_SCAN, "hw_value %d, flags %X\n",
 				     req->channels[i]->hw_value,
 				     req->channels[i]->flags);
-			wl1271_debug(DEBUG_SCAN, "max_power %d",
+			wl1271_debug(DEBUG_SCAN, "max_power %d\n",
 				     req->channels[i]->max_power);
-			wl1271_debug(DEBUG_SCAN, "min_dwell_time %d max dwell time %d",
+			wl1271_debug(DEBUG_SCAN, "min_dwell_time %d max dwell time %d\n",
 				     min_dwell_time_active,
 				     max_dwell_time_active);
 
@@ -493,7 +493,7 @@ wl1271_scan_get_sched_scan_channels(struct wl1271 *wl,
 				 * the passive channel list
 				 */
 				(*n_pactive_ch)++;
-				wl1271_debug(DEBUG_SCAN, "n_pactive_ch = %d",
+				wl1271_debug(DEBUG_SCAN, "n_pactive_ch = %d\n",
 					     *n_pactive_ch);
 			}
 
@@ -550,11 +550,11 @@ wl1271_scan_sched_scan_channels(struct wl1271 *wl,
 
 	cfg->n_pactive_ch = n_pactive_ch;
 
-	wl1271_debug(DEBUG_SCAN, "    2.4GHz: active %d passive %d",
+	wl1271_debug(DEBUG_SCAN, "    2.4GHz: active %d passive %d\n",
 		     cfg->active[0], cfg->passive[0]);
-	wl1271_debug(DEBUG_SCAN, "    5GHz: active %d passive %d",
+	wl1271_debug(DEBUG_SCAN, "    5GHz: active %d passive %d\n",
 		     cfg->active[1], cfg->passive[1]);
-	wl1271_debug(DEBUG_SCAN, "    DFS: %d", cfg->dfs);
+	wl1271_debug(DEBUG_SCAN, "    DFS: %d\n", cfg->dfs);
 
 	return  cfg->passive[0] || cfg->active[0] ||
 		cfg->passive[1] || cfg->active[1] || cfg->dfs ||
@@ -572,7 +572,7 @@ wl12xx_scan_sched_scan_ssid_list(struct wl1271 *wl,
 	struct cfg80211_ssid *ssids = req->ssids;
 	int ret = 0, type, i, j, n_match_ssids = 0;
 
-	wl1271_debug(DEBUG_CMD, "cmd sched scan ssid list");
+	wl1271_debug(DEBUG_CMD, "cmd sched scan ssid list\n");
 
 	/* count the match sets that contain SSIDs */
 	for (i = 0; i < req->n_match_sets; i++)
@@ -655,7 +655,7 @@ wl12xx_scan_sched_scan_ssid_list(struct wl1271 *wl,
 	ret = wl1271_cmd_send(wl, CMD_CONNECTION_SCAN_SSID_CFG, cmd,
 			      sizeof(*cmd), 0);
 	if (ret < 0) {
-		wl1271_error("cmd sched scan ssid list failed");
+		wl1271_err("cmd sched scan ssid list failed\n");
 		goto out_free;
 	}
 
@@ -677,7 +677,7 @@ int wl1271_scan_sched_scan_config(struct wl1271 *wl,
 	int i, ret;
 	bool force_passive = !req->n_ssids;
 
-	wl1271_debug(DEBUG_CMD, "cmd sched_scan scan config");
+	wl1271_debug(DEBUG_CMD, "cmd sched_scan scan config\n");
 
 	cfg = kzalloc(sizeof(*cfg), GFP_KERNEL);
 	if (!cfg)
@@ -707,10 +707,10 @@ int wl1271_scan_sched_scan_config(struct wl1271 *wl,
 
 	cfg->filter_type = ret;
 
-	wl1271_debug(DEBUG_SCAN, "filter_type = %d", cfg->filter_type);
+	wl1271_debug(DEBUG_SCAN, "filter_type = %d\n", cfg->filter_type);
 
 	if (!wl1271_scan_sched_scan_channels(wl, req, cfg)) {
-		wl1271_error("scan channel list is empty");
+		wl1271_err("scan channel list is empty\n");
 		ret = -EINVAL;
 		goto out;
 	}
@@ -724,7 +724,7 @@ int wl1271_scan_sched_scan_config(struct wl1271 *wl,
 						 ies->ie[band],
 						 ies->len[band]);
 		if (ret < 0) {
-			wl1271_error("2.4GHz PROBE request template failed");
+			wl1271_err("2.4GHz PROBE request template failed\n");
 			goto out;
 		}
 	}
@@ -738,7 +738,7 @@ int wl1271_scan_sched_scan_config(struct wl1271 *wl,
 						 ies->ie[band],
 						 ies->len[band]);
 		if (ret < 0) {
-			wl1271_error("5GHz PROBE request template failed");
+			wl1271_err("5GHz PROBE request template failed\n");
 			goto out;
 		}
 	}
@@ -748,7 +748,7 @@ int wl1271_scan_sched_scan_config(struct wl1271 *wl,
 	ret = wl1271_cmd_send(wl, CMD_CONNECTION_SCAN_CFG, cfg,
 			      sizeof(*cfg), 0);
 	if (ret < 0) {
-		wl1271_error("SCAN configuration failed");
+		wl1271_err("SCAN configuration failed\n");
 		goto out;
 	}
 out:
@@ -761,7 +761,7 @@ int wl1271_scan_sched_scan_start(struct wl1271 *wl, struct wl12xx_vif *wlvif)
 	struct wl1271_cmd_sched_scan_start *start;
 	int ret = 0;
 
-	wl1271_debug(DEBUG_CMD, "cmd periodic scan start");
+	wl1271_debug(DEBUG_CMD, "cmd periodic scan start\n");
 
 	if (wlvif->bss_type != BSS_TYPE_STA_BSS)
 		return -EOPNOTSUPP;
@@ -779,7 +779,7 @@ int wl1271_scan_sched_scan_start(struct wl1271 *wl, struct wl12xx_vif *wlvif)
 	ret = wl1271_cmd_send(wl, CMD_START_PERIODIC_SCAN, start,
 			      sizeof(*start), 0);
 	if (ret < 0) {
-		wl1271_error("failed to send scan start command");
+		wl1271_err("failed to send scan start command\n");
 		goto out_free;
 	}
 
@@ -790,7 +790,7 @@ out_free:
 
 void wl1271_scan_sched_scan_results(struct wl1271 *wl)
 {
-	wl1271_debug(DEBUG_SCAN, "got periodic scan results");
+	wl1271_debug(DEBUG_SCAN, "got periodic scan results\n");
 
 	ieee80211_sched_scan_results(wl->hw);
 }
@@ -800,12 +800,12 @@ void wl1271_scan_sched_scan_stop(struct wl1271 *wl,  struct wl12xx_vif *wlvif)
 	struct wl1271_cmd_sched_scan_stop *stop;
 	int ret = 0;
 
-	wl1271_debug(DEBUG_CMD, "cmd periodic scan stop");
+	wl1271_debug(DEBUG_CMD, "cmd periodic scan stop\n");
 
 	/* FIXME: what to do if alloc'ing to stop fails? */
 	stop = kzalloc(sizeof(*stop), GFP_KERNEL);
 	if (!stop) {
-		wl1271_error("failed to alloc memory to send sched scan stop");
+		wl1271_err("failed to alloc memory to send sched scan stop\n");
 		return;
 	}
 
@@ -815,7 +815,7 @@ void wl1271_scan_sched_scan_stop(struct wl1271 *wl,  struct wl12xx_vif *wlvif)
 	ret = wl1271_cmd_send(wl, CMD_STOP_PERIODIC_SCAN, stop,
 			      sizeof(*stop), 0);
 	if (ret < 0) {
-		wl1271_error("failed to send sched scan stop command");
+		wl1271_err("failed to send sched scan stop command\n");
 		goto out_free;
 	}
 
diff --git a/drivers/net/wireless/ti/wlcore/sdio.c b/drivers/net/wireless/ti/wlcore/sdio.c
index c67ec48..b7ade55 100644
--- a/drivers/net/wireless/ti/wlcore/sdio.c
+++ b/drivers/net/wireless/ti/wlcore/sdio.c
@@ -342,8 +342,7 @@ static int wl1271_suspend(struct device *dev)
 		sdio_flags = sdio_get_host_pm_caps(func);
 
 		if (!(sdio_flags & MMC_PM_KEEP_POWER)) {
-			dev_err(dev, "can't keep power while host "
-				     "is suspended\n");
+			dev_err(dev, "can't keep power while host is suspended\n");
 			ret = -EINVAL;
 			goto out;
 		}
diff --git a/drivers/net/wireless/ti/wlcore/testmode.c b/drivers/net/wireless/ti/wlcore/testmode.c
index 0e59ea2..05cd2de 100644
--- a/drivers/net/wireless/ti/wlcore/testmode.c
+++ b/drivers/net/wireless/ti/wlcore/testmode.c
@@ -76,7 +76,7 @@ static int wl1271_tm_cmd_test(struct wl1271 *wl, struct nlattr *tb[])
 	void *buf;
 	u8 answer = 0;
 
-	wl1271_debug(DEBUG_TESTMODE, "testmode cmd test");
+	wl1271_debug(DEBUG_TESTMODE, "testmode cmd test\n");
 
 	if (!tb[WL1271_TM_ATTR_DATA])
 		return -EINVAL;
@@ -103,7 +103,7 @@ static int wl1271_tm_cmd_test(struct wl1271 *wl, struct nlattr *tb[])
 
 	ret = wl1271_cmd_test(wl, buf, buf_len, answer);
 	if (ret < 0) {
-		wl1271_warning("testmode cmd test failed: %d", ret);
+		wl1271_warn("testmode cmd test failed: %d\n", ret);
 		goto out_sleep;
 	}
 
@@ -142,7 +142,7 @@ static int wl1271_tm_cmd_interrogate(struct wl1271 *wl, struct nlattr *tb[])
 	struct sk_buff *skb;
 	u8 ie_id;
 
-	wl1271_debug(DEBUG_TESTMODE, "testmode cmd interrogate");
+	wl1271_debug(DEBUG_TESTMODE, "testmode cmd interrogate\n");
 
 	if (!tb[WL1271_TM_ATTR_IE_ID])
 		return -EINVAL;
@@ -168,7 +168,7 @@ static int wl1271_tm_cmd_interrogate(struct wl1271 *wl, struct nlattr *tb[])
 
 	ret = wl1271_cmd_interrogate(wl, ie_id, cmd, sizeof(*cmd));
 	if (ret < 0) {
-		wl1271_warning("testmode cmd interrogate failed: %d", ret);
+		wl1271_warn("testmode cmd interrogate failed: %d\n", ret);
 		goto out_free;
 	}
 
@@ -205,7 +205,7 @@ static int wl1271_tm_cmd_configure(struct wl1271 *wl, struct nlattr *tb[])
 	void *buf;
 	u8 ie_id;
 
-	wl1271_debug(DEBUG_TESTMODE, "testmode cmd configure");
+	wl1271_debug(DEBUG_TESTMODE, "testmode cmd configure\n");
 
 	if (!tb[WL1271_TM_ATTR_DATA])
 		return -EINVAL;
@@ -224,7 +224,7 @@ static int wl1271_tm_cmd_configure(struct wl1271 *wl, struct nlattr *tb[])
 	mutex_unlock(&wl->mutex);
 
 	if (ret < 0) {
-		wl1271_warning("testmode cmd configure failed: %d", ret);
+		wl1271_warn("testmode cmd configure failed: %d\n", ret);
 		return ret;
 	}
 
@@ -236,7 +236,7 @@ static int wl1271_tm_cmd_set_plt_mode(struct wl1271 *wl, struct nlattr *tb[])
 	u32 val;
 	int ret;
 
-	wl1271_debug(DEBUG_TESTMODE, "testmode cmd set plt mode");
+	wl1271_debug(DEBUG_TESTMODE, "testmode cmd set plt mode\n");
 
 	if (!tb[WL1271_TM_ATTR_PLT_MODE])
 		return -EINVAL;
@@ -260,7 +260,7 @@ static int wl1271_tm_cmd_set_plt_mode(struct wl1271 *wl, struct nlattr *tb[])
 
 static int wl1271_tm_cmd_recover(struct wl1271 *wl, struct nlattr *tb[])
 {
-	wl1271_debug(DEBUG_TESTMODE, "testmode cmd recover");
+	wl1271_debug(DEBUG_TESTMODE, "testmode cmd recover\n");
 
 	wl12xx_queue_recovery_work(wl);
 
diff --git a/drivers/net/wireless/ti/wlcore/tx.c b/drivers/net/wireless/ti/wlcore/tx.c
index 6983e7a..6a0bebd 100644
--- a/drivers/net/wireless/ti/wlcore/tx.c
+++ b/drivers/net/wireless/ti/wlcore/tx.c
@@ -54,7 +54,7 @@ static int wl1271_set_default_wep_key(struct wl1271 *wl,
 	if (ret < 0)
 		return ret;
 
-	wl1271_debug(DEBUG_CRYPT, "default wep key idx: %d", (int)id);
+	wl1271_debug(DEBUG_CRYPT, "default wep key idx: %d\n", (int)id);
 	return 0;
 }
 
@@ -235,7 +235,7 @@ static int wl1271_tx_allocate(struct wl1271 *wl, struct wl12xx_vif *wlvif,
 		ret = 0;
 
 		wl1271_debug(DEBUG_TX,
-			     "tx_allocate: size: %d, blocks: %d, id: %d",
+			     "tx_allocate: size: %d, blocks: %d, id: %d\n",
 			     total_len, total_blocks, id);
 	} else {
 		wl1271_free_tx_id(wl, id);
@@ -380,7 +380,7 @@ static int wl1271_prepare_tx_frame(struct wl1271 *wl, struct wl12xx_vif *wlvif,
 	}
 	hlid = wl12xx_tx_get_hlid(wl, wlvif, skb);
 	if (hlid == WL12XX_INVALID_LINK_ID) {
-		wl1271_error("invalid hlid. dropping skb 0x%p", skb);
+		wl1271_err("invalid hlid. dropping skb 0x%p\n", skb);
 		return -EINVAL;
 	}
 
@@ -797,7 +797,7 @@ static void wl1271_tx_complete_packet(struct wl1271 *wl,
 
 	/* check for id legality */
 	if (unlikely(id >= wl->num_tx_desc || wl->tx_frames[id] == NULL)) {
-		wl1271_warning("TX result illegal id: %d", id);
+		wl1271_warn("TX result illegal id: %d\n", id);
 		return;
 	}
 
@@ -865,8 +865,7 @@ static void wl1271_tx_complete_packet(struct wl1271 *wl,
 		skb_pull(skb, WL1271_EXTRA_SPACE_TKIP);
 	}
 
-	wl1271_debug(DEBUG_TX, "tx status id %u skb 0x%p failures %u rate 0x%x"
-		     " status 0x%x",
+	wl1271_debug(DEBUG_TX, "tx status id %u skb 0x%p failures %u rate 0x%x status 0x%x\n",
 		     result->id, skb, result->ack_failures,
 		     result->rate_class_index, result->status);
 
@@ -895,11 +894,11 @@ void wl1271_tx_complete(struct wl1271 *wl)
 				tx_result_host_counter), fw_counter);
 
 	count = fw_counter - wl->tx_results_count;
-	wl1271_debug(DEBUG_TX, "tx_complete received, packets: %d", count);
+	wl1271_debug(DEBUG_TX, "tx_complete received, packets: %d\n", count);
 
 	/* verify that the result buffer is not getting overrun */
 	if (unlikely(count > TX_HW_RESULT_QUEUE_LEN))
-		wl1271_warning("TX result overflow from chipset: %d", count);
+		wl1271_warn("TX result overflow from chipset: %d\n", count);
 
 	/* process the results */
 	for (i = 0; i < count; i++) {
@@ -926,7 +925,7 @@ void wl1271_tx_reset_link_queues(struct wl1271 *wl, u8 hlid)
 	for (i = 0; i < NUM_TX_QUEUES; i++) {
 		total[i] = 0;
 		while ((skb = skb_dequeue(&wl->links[hlid].tx_queue[i]))) {
-			wl1271_debug(DEBUG_TX, "link freeing skb 0x%p", skb);
+			wl1271_debug(DEBUG_TX, "link freeing skb 0x%p\n", skb);
 
 			if (!wl12xx_is_dummy_packet(wl, skb)) {
 				info = IEEE80211_SKB_CB(skb);
@@ -994,7 +993,7 @@ void wl12xx_tx_reset(struct wl1271 *wl)
 
 		skb = wl->tx_frames[i];
 		wl1271_free_tx_id(wl, i);
-		wl1271_debug(DEBUG_TX, "freeing skb 0x%p", skb);
+		wl1271_debug(DEBUG_TX, "freeing skb 0x%p\n", skb);
 
 		if (!wl12xx_is_dummy_packet(wl, skb)) {
 			/*
@@ -1037,7 +1036,7 @@ void wl1271_tx_flush(struct wl1271 *wl)
 
 	while (!time_after(jiffies, timeout)) {
 		mutex_lock(&wl->mutex);
-		wl1271_debug(DEBUG_TX, "flushing tx buffer: %d %d",
+		wl1271_debug(DEBUG_TX, "flushing tx buffer: %d %d\n",
 			     wl->tx_frames_cnt,
 			     wl1271_tx_total_queue_count(wl));
 		if ((wl->tx_frames_cnt == 0) &&
@@ -1049,7 +1048,7 @@ void wl1271_tx_flush(struct wl1271 *wl)
 		msleep(1);
 	}
 
-	wl1271_warning("Unable to flush all TX buffers, timed out.");
+	wl1271_warn("Unable to flush all TX buffers, timed out\n");
 
 	/* forcibly flush all Tx buffers on our queues */
 	mutex_lock(&wl->mutex);
-- 
1.7.8.111.gad25c.dirty
