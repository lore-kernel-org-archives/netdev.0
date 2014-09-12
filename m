From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH NEXT] rtlwifi: btcoexist: Change local debugging macros CL_*** into the standard varieties
Date: Fri, 12 Sep 2014 15:50:58 -0500
Message-ID: <1410555058-9096-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f50.google.com ([209.85.219.50]:56204 "EHLO
	mail-oa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751056AbaILUvH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Sep 2014 16:51:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Macros CL_SNPRINTF and CL_PRINTF are always used in that order. The first
formats info into a buffer, and the second dumps it with printk. As the
debug system in rtlwifi has a macro that does this with a single call,
it seems reasonable to use it instead. An additional benefit is that the
debug level can be set when loading the driver used by the wifi device.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 .../wireless/rtlwifi/btcoexist/halbtc8192e2ant.c   | 119 +++++++-------------
 .../wireless/rtlwifi/btcoexist/halbtc8723b1ant.c   | 125 +++++++--------------
 .../wireless/rtlwifi/btcoexist/halbtc8723b2ant.c   | 105 ++++++-----------
 .../wireless/rtlwifi/btcoexist/halbtc8821a1ant.c   | 122 +++++++-------------
 .../wireless/rtlwifi/btcoexist/halbtc8821a2ant.c   | 107 ++++++------------
 .../net/wireless/rtlwifi/btcoexist/halbtcoutsrc.c  |   3 -
 .../net/wireless/rtlwifi/btcoexist/halbtcoutsrc.h  |   4 -
 7 files changed, 194 insertions(+), 391 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/btcoexist/halbtc8192e2ant.c b/drivers/net/wireless/rtlwifi/btcoexist/halbtc8192e2ant.c
index af3f604..53261d6 100644
--- a/drivers/net/wireless/rtlwifi/btcoexist/halbtc8192e2ant.c
+++ b/drivers/net/wireless/rtlwifi/btcoexist/halbtc8192e2ant.c
@@ -3305,7 +3305,7 @@ void ex_halbtc8192e2ant_display_coex_info(struct btc_coexist *btcoexist)
 {
 	struct btc_board_info *board_info = &btcoexist->board_info;
 	struct btc_stack_info *stack_info = &btcoexist->stack_info;
-	u8 *cli_buf = btcoexist->cli_buf;
+	struct rtl_priv *rtlpriv = btcoexist->adapter;
 	u8 u8tmp[4], i, bt_info_ext, ps_tdma_case = 0;
 	u16 u16tmp[4];
 	u32 u32tmp[4];
@@ -3316,87 +3316,75 @@ void ex_halbtc8192e2ant_display_coex_info(struct btc_coexist *btcoexist)
 	u8 wifi_dot11_chnl, wifi_hs_chnl;
 	u32 fw_ver = 0, bt_patch_ver = 0;
 
-	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE,
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
 		   "\r\n ============[BT Coexist info]============");
-	CL_PRINTF(cli_buf);
 
 	if (btcoexist->manual_control) {
-		CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE,
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
 			   "\r\n ===========[Under Manual Control]===========");
-		CL_PRINTF(cli_buf);
-		CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE,
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
 			   "\r\n ==========================================");
-		CL_PRINTF(cli_buf);
 	}
 
 	if (!board_info->bt_exist) {
-		CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n BT not exists !!!");
-		CL_PRINTF(cli_buf);
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "\r\n BT not exists !!!");
 		return;
 	}
 
-	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE,
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
 		   "\r\n %-35s = %d/ %d ", "Ant PG number/ Ant mechanism:",
 		   board_info->pg_ant_num, board_info->btdm_ant_num);
-	CL_PRINTF(cli_buf);
 
-	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = %s / %d",
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "\r\n %-35s = %s / %d",
 		   "BT stack/ hci ext ver",
 		   ((stack_info->profile_notified) ? "Yes" : "No"),
 		   stack_info->hci_version);
-	CL_PRINTF(cli_buf);
 
 	btcoexist->btc_get(btcoexist, BTC_GET_U4_BT_PATCH_VER, &bt_patch_ver);
 	btcoexist->btc_get(btcoexist, BTC_GET_U4_WIFI_FW_VER, &fw_ver);
-	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE,
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
 		   "\r\n %-35s = %d_%d/ 0x%x/ 0x%x(%d)",
 		   "CoexVer/ FwVer/ PatchVer",
 		   glcoex_ver_date_8192e_2ant, glcoex_ver_8192e_2ant,
 		   fw_ver, bt_patch_ver, bt_patch_ver);
-	CL_PRINTF(cli_buf);
 
 	btcoexist->btc_get(btcoexist, BTC_GET_BL_HS_OPERATION, &bt_hson);
 	btcoexist->btc_get(btcoexist, BTC_GET_U1_WIFI_DOT11_CHNL,
 			   &wifi_dot11_chnl);
 	btcoexist->btc_get(btcoexist, BTC_GET_U1_WIFI_HS_CHNL, &wifi_hs_chnl);
-	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = %d / %d(%d)",
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "\r\n %-35s = %d / %d(%d)",
 		   "Dot11 channel / HsMode(HsChnl)",
 		   wifi_dot11_chnl, bt_hson, wifi_hs_chnl);
-	CL_PRINTF(cli_buf);
 
-	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = %02x %02x %02x ",
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "\r\n %-35s = %02x %02x %02x ",
 		   "H2C Wifi inform bt chnl Info", coex_dm->wifi_chnl_info[0],
 		   coex_dm->wifi_chnl_info[1], coex_dm->wifi_chnl_info[2]);
-	CL_PRINTF(cli_buf);
 
 	btcoexist->btc_get(btcoexist, BTC_GET_S4_WIFI_RSSI, &wifirssi);
 	btcoexist->btc_get(btcoexist, BTC_GET_S4_HS_RSSI, &bt_hs_rssi);
-	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = %d/ %d",
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "\r\n %-35s = %d/ %d",
 		   "Wifi rssi/ HS rssi", wifirssi, bt_hs_rssi);
-	CL_PRINTF(cli_buf);
 
 	btcoexist->btc_get(btcoexist, BTC_GET_BL_WIFI_SCAN, &scan);
 	btcoexist->btc_get(btcoexist, BTC_GET_BL_WIFI_LINK, &link);
 	btcoexist->btc_get(btcoexist, BTC_GET_BL_WIFI_ROAM, &roam);
-	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = %d/ %d/ %d ",
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "\r\n %-35s = %d/ %d/ %d ",
 		   "Wifi link/ roam/ scan", link, roam, scan);
-	CL_PRINTF(cli_buf);
 
 	btcoexist->btc_get(btcoexist, BTC_GET_BL_WIFI_UNDER_5G, &wifi_under_5g);
 	btcoexist->btc_get(btcoexist, BTC_GET_U4_WIFI_BW, &wifi_bw);
 	btcoexist->btc_get(btcoexist, BTC_GET_BL_WIFI_BUSY, &wifi_busy);
 	btcoexist->btc_get(btcoexist, BTC_GET_U4_WIFI_TRAFFIC_DIRECTION,
 			   &wifi_traffic_dir);
-	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = %s / %s/ %s ",
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "\r\n %-35s = %s / %s/ %s ",
 		   "Wifi status", (wifi_under_5g ? "5G" : "2.4G"),
 		   ((BTC_WIFI_BW_LEGACY == wifi_bw) ? "Legacy" :
 			(((BTC_WIFI_BW_HT40 == wifi_bw) ? "HT40" : "HT20"))),
 		   ((!wifi_busy) ? "idle" :
 			((BTC_WIFI_TRAFFIC_TX == wifi_traffic_dir) ?
 				"uplink" : "downlink")));
-	CL_PRINTF(cli_buf);
 
-	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = [%s/ %d/ %d] ",
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "\r\n %-35s = [%s/ %d/ %d] ",
 		   "BT [status/ rssi/ retryCnt]",
 		   ((btcoexist->bt_info.bt_disabled) ? ("disabled") :
 		    ((coex_sta->c2h_bt_inquiry_page) ?
@@ -3406,166 +3394,139 @@ void ex_halbtc8192e2ant_display_coex_info(struct btc_coexist *btcoexist)
 			 ((BT_8192E_2ANT_BT_STATUS_CONNECTED_IDLE ==
 			   coex_dm->bt_status) ? "connected-idle" : "busy")))),
 		   coex_sta->bt_rssi, coex_sta->bt_retry_cnt);
-	CL_PRINTF(cli_buf);
 
-	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = %d / %d / %d / %d",
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "\r\n %-35s = %d / %d / %d / %d",
 		   "SCO/HID/PAN/A2DP", stack_info->sco_exist,
 		   stack_info->hid_exist, stack_info->pan_exist,
 		   stack_info->a2dp_exist);
-	CL_PRINTF(cli_buf);
 	btcoexist->btc_disp_dbg_msg(btcoexist, BTC_DBG_DISP_BT_LINK_INFO);
 
 	bt_info_ext = coex_sta->bt_info_ext;
-	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = %s",
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "\r\n %-35s = %s",
 		   "BT Info A2DP rate",
 		   (bt_info_ext&BIT0) ? "Basic rate" : "EDR rate");
-	CL_PRINTF(cli_buf);
 
 	for (i = 0; i < BT_INFO_SRC_8192E_2ANT_MAX; i++) {
 		if (coex_sta->bt_info_c2h_cnt[i]) {
-			CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE,
+			RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
 				   "\r\n %-35s = %02x %02x %02x %02x ",
 				   GLBtInfoSrc8192e2Ant[i],
 				   coex_sta->bt_info_c2h[i][0],
 				   coex_sta->bt_info_c2h[i][1],
 				   coex_sta->bt_info_c2h[i][2],
 				   coex_sta->bt_info_c2h[i][3]);
-			CL_PRINTF(cli_buf);
-			CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE,
+			RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
 				   "%02x %02x %02x(%d)",
 				   coex_sta->bt_info_c2h[i][4],
 				   coex_sta->bt_info_c2h[i][5],
 				   coex_sta->bt_info_c2h[i][6],
 				   coex_sta->bt_info_c2h_cnt[i]);
-			CL_PRINTF(cli_buf);
 		}
 	}
 
-	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = %s/%s",
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "\r\n %-35s = %s/%s",
 		   "PS state, IPS/LPS",
 		   ((coex_sta->under_ips ? "IPS ON" : "IPS OFF")),
 		   ((coex_sta->under_lps ? "LPS ON" : "LPS OFF")));
-	CL_PRINTF(cli_buf);
 	btcoexist->btc_disp_dbg_msg(btcoexist, BTC_DBG_DISP_FW_PWR_MODE_CMD);
 
-	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = 0x%x ", "SS Type",
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "\r\n %-35s = 0x%x ", "SS Type",
 		   coex_dm->cur_sstype);
-	CL_PRINTF(cli_buf);
 
 	/* Sw mechanism	*/
-	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s",
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "\r\n %-35s",
 		   "============[Sw mechanism]============");
-	CL_PRINTF(cli_buf);
-	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = %d/ %d/ %d ",
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "\r\n %-35s = %d/ %d/ %d ",
 		   "SM1[ShRf/ LpRA/ LimDig]", coex_dm->cur_rf_rx_lpf_shrink,
 		   coex_dm->cur_low_penalty_ra, coex_dm->limited_dig);
-	CL_PRINTF(cli_buf);
-	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = %d/ %d/ %d(0x%x) ",
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "\r\n %-35s = %d/ %d/ %d(0x%x) ",
 		   "SM2[AgcT/ AdcB/ SwDacSwing(lvl)]",
 		   coex_dm->cur_agc_table_en, coex_dm->cur_adc_back_off,
 		   coex_dm->cur_dac_swing_on, coex_dm->cur_dac_swing_lvl);
-	CL_PRINTF(cli_buf);
 
-	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = 0x%x ", "Rate Mask",
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "\r\n %-35s = 0x%x ", "Rate Mask",
 		   btcoexist->bt_info.ra_mask);
-	CL_PRINTF(cli_buf);
 
 	/* Fw mechanism	*/
-	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s",
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "\r\n %-35s",
 		   "============[Fw mechanism]============");
-	CL_PRINTF(cli_buf);
 
 	ps_tdma_case = coex_dm->cur_ps_tdma;
-	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE,
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
 		   "\r\n %-35s = %02x %02x %02x %02x %02x case-%d (auto:%d)",
 		   "PS TDMA", coex_dm->ps_tdma_para[0],
 		   coex_dm->ps_tdma_para[1], coex_dm->ps_tdma_para[2],
 		   coex_dm->ps_tdma_para[3], coex_dm->ps_tdma_para[4],
 		   ps_tdma_case, coex_dm->auto_tdma_adjust);
-	CL_PRINTF(cli_buf);
 
-	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = %d/ %d ",
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "\r\n %-35s = %d/ %d ",
 		   "DecBtPwr/ IgnWlanAct",
 		   coex_dm->cur_dec_bt_pwr, coex_dm->cur_ignore_wlan_act);
-	CL_PRINTF(cli_buf);
 
 	/* Hw setting */
-	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s",
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "\r\n %-35s",
 		   "============[Hw setting]============");
-	CL_PRINTF(cli_buf);
 
-	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = 0x%x",
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "\r\n %-35s = 0x%x",
 		   "RF-A, 0x1e initVal", coex_dm->bt_rf0x1e_backup);
-	CL_PRINTF(cli_buf);
 
-	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = 0x%x/0x%x/0x%x/0x%x",
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "\r\n %-35s = 0x%x/0x%x/0x%x/0x%x",
 		   "backup ARFR1/ARFR2/RL/AMaxTime", coex_dm->backup_arfr_cnt1,
 		   coex_dm->backup_arfr_cnt2, coex_dm->backup_retrylimit,
 		   coex_dm->backup_ampdu_maxtime);
-	CL_PRINTF(cli_buf);
 
 	u32tmp[0] = btcoexist->btc_read_4byte(btcoexist, 0x430);
 	u32tmp[1] = btcoexist->btc_read_4byte(btcoexist, 0x434);
 	u16tmp[0] = btcoexist->btc_read_2byte(btcoexist, 0x42a);
 	u8tmp[0] = btcoexist->btc_read_1byte(btcoexist, 0x456);
-	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = 0x%x/0x%x/0x%x/0x%x",
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "\r\n %-35s = 0x%x/0x%x/0x%x/0x%x",
 		   "0x430/0x434/0x42a/0x456",
 		   u32tmp[0], u32tmp[1], u16tmp[0], u8tmp[0]);
-	CL_PRINTF(cli_buf);
 
 	u32tmp[0] = btcoexist->btc_read_4byte(btcoexist, 0xc04);
 	u32tmp[1] = btcoexist->btc_read_4byte(btcoexist, 0xd04);
 	u32tmp[2] = btcoexist->btc_read_4byte(btcoexist, 0x90c);
-	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = 0x%x/ 0x%x/ 0x%x",
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "\r\n %-35s = 0x%x/ 0x%x/ 0x%x",
 		   "0xc04/ 0xd04/ 0x90c", u32tmp[0], u32tmp[1], u32tmp[2]);
-	CL_PRINTF(cli_buf);
 
 	u8tmp[0] = btcoexist->btc_read_1byte(btcoexist, 0x778);
-	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = 0x%x", "0x778",
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "\r\n %-35s = 0x%x", "0x778",
 		   u8tmp[0]);
-	CL_PRINTF(cli_buf);
 
 	u8tmp[0] = btcoexist->btc_read_1byte(btcoexist, 0x92c);
 	u32tmp[0] = btcoexist->btc_read_4byte(btcoexist, 0x930);
-	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = 0x%x/ 0x%x",
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "\r\n %-35s = 0x%x/ 0x%x",
 		   "0x92c/ 0x930", (u8tmp[0]), u32tmp[0]);
-	CL_PRINTF(cli_buf);
 
 	u8tmp[0] = btcoexist->btc_read_1byte(btcoexist, 0x40);
 	u8tmp[1] = btcoexist->btc_read_1byte(btcoexist, 0x4f);
-	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = 0x%x/ 0x%x",
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "\r\n %-35s = 0x%x/ 0x%x",
 		   "0x40/ 0x4f", u8tmp[0], u8tmp[1]);
-	CL_PRINTF(cli_buf);
 
 	u32tmp[0] = btcoexist->btc_read_4byte(btcoexist, 0x550);
 	u8tmp[0] = btcoexist->btc_read_1byte(btcoexist, 0x522);
-	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = 0x%x/ 0x%x",
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "\r\n %-35s = 0x%x/ 0x%x",
 		   "0x550(bcn ctrl)/0x522", u32tmp[0], u8tmp[0]);
-	CL_PRINTF(cli_buf);
 
 	u32tmp[0] = btcoexist->btc_read_4byte(btcoexist, 0xc50);
-	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = 0x%x", "0xc50(dig)",
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "\r\n %-35s = 0x%x", "0xc50(dig)",
 		   u32tmp[0]);
-	CL_PRINTF(cli_buf);
 
 	u32tmp[0] = btcoexist->btc_read_4byte(btcoexist, 0x6c0);
 	u32tmp[1] = btcoexist->btc_read_4byte(btcoexist, 0x6c4);
 	u32tmp[2] = btcoexist->btc_read_4byte(btcoexist, 0x6c8);
 	u8tmp[0] = btcoexist->btc_read_1byte(btcoexist, 0x6cc);
-	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE,
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
 		   "\r\n %-35s = 0x%x/ 0x%x/ 0x%x/ 0x%x",
 		   "0x6c0/0x6c4/0x6c8/0x6cc(coexTable)",
 		   u32tmp[0], u32tmp[1], u32tmp[2], u8tmp[0]);
-	CL_PRINTF(cli_buf);
 
-	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = %d/ %d",
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "\r\n %-35s = %d/ %d",
 		   "0x770(hp rx[31:16]/tx[15:0])",
 		   coex_sta->high_priority_rx, coex_sta->high_priority_tx);
-	CL_PRINTF(cli_buf);
-	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = %d/ %d",
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "\r\n %-35s = %d/ %d",
 		   "0x774(lp rx[31:16]/tx[15:0])",
 		   coex_sta->low_priority_rx, coex_sta->low_priority_tx);
-	CL_PRINTF(cli_buf);
 #if (BT_AUTO_REPORT_ONLY_8192E_2ANT == 1)
 	halbtc8192e2ant_monitor_bt_ctr(btcoexist);
 #endif
diff --git a/drivers/net/wireless/rtlwifi/btcoexist/halbtc8723b1ant.c b/drivers/net/wireless/rtlwifi/btcoexist/halbtc8723b1ant.c
index e4948c8..c4acd40 100644
--- a/drivers/net/wireless/rtlwifi/btcoexist/halbtc8723b1ant.c
+++ b/drivers/net/wireless/rtlwifi/btcoexist/halbtc8723b1ant.c
@@ -2398,7 +2398,7 @@ void ex_halbtc8723b1ant_display_coex_info(struct btc_coexist *btcoexist)
 	struct btc_board_info *board_info = &btcoexist->board_info;
 	struct btc_stack_info *stack_info = &btcoexist->stack_info;
 	struct btc_bt_link_info *bt_link_info = &btcoexist->bt_link_info;
-	u8 *cli_buf = btcoexist->cli_buf;
+	struct rtl_priv *rtlpriv = btcoexist->adapter;
 	u8 u8tmp[4], i, bt_info_ext, pstdmacase = 0;
 	u16 u16tmp[4];
 	u32 u32tmp[4];
@@ -2410,81 +2410,68 @@ void ex_halbtc8723b1ant_display_coex_info(struct btc_coexist *btcoexist)
 	u8 wifi_dot11_chnl, wifi_hs_chnl;
 	u32 fw_ver = 0, bt_patch_ver = 0;
 
-	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE,
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
 		   "\r\n ============[BT Coexist info]============");
-	CL_PRINTF(cli_buf);
 
 	if (btcoexist->manual_control) {
-		CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE,
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
 			   "\r\n ============[Under Manual Control]==========");
-		CL_PRINTF(cli_buf);
-		CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE,
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
 			   "\r\n ==========================================");
-		CL_PRINTF(cli_buf);
 	}
 	if (btcoexist->stop_coex_dm) {
-		CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE,
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
 			   "\r\n ============[Coex is STOPPED]============");
-		CL_PRINTF(cli_buf);
-		CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE,
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
 			   "\r\n ==========================================");
-		CL_PRINTF(cli_buf);
 	}
 
 	if (!board_info->bt_exist) {
-		CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n BT not exists !!!");
-		CL_PRINTF(cli_buf);
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "\r\n BT not exists !!!");
 		return;
 	}
 
-	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = %d/ %d/ %d",
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "\r\n %-35s = %d/ %d/ %d",
 		   "Ant PG Num/ Ant Mech/ Ant Pos:",
 		   board_info->pg_ant_num, board_info->btdm_ant_num,
 		   board_info->btdm_ant_pos);
-	CL_PRINTF(cli_buf);
 
-	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = %s / %d",
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "\r\n %-35s = %s / %d",
 		   "BT stack/ hci ext ver",
 		   ((stack_info->profile_notified) ? "Yes" : "No"),
 		   stack_info->hci_version);
-	CL_PRINTF(cli_buf);
 
 	btcoexist->btc_get(btcoexist, BTC_GET_U4_BT_PATCH_VER, &bt_patch_ver);
 	btcoexist->btc_get(btcoexist, BTC_GET_U4_WIFI_FW_VER, &fw_ver);
-	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE,
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
 		   "\r\n %-35s = %d_%x/ 0x%x/ 0x%x(%d)",
 		   "CoexVer/ FwVer/ PatchVer",
 		   glcoex_ver_date_8723b_1ant, glcoex_ver_8723b_1ant,
 		   fw_ver, bt_patch_ver, bt_patch_ver);
-	CL_PRINTF(cli_buf);
 
 	btcoexist->btc_get(btcoexist, BTC_GET_BL_HS_OPERATION, &bt_hs_on);
 	btcoexist->btc_get(btcoexist, BTC_GET_U1_WIFI_DOT11_CHNL,
 			   &wifi_dot11_chnl);
 	btcoexist->btc_get(btcoexist, BTC_GET_U1_WIFI_HS_CHNL, &wifi_hs_chnl);
-	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = %d / %d(%d)",
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "\r\n %-35s = %d / %d(%d)",
 		   "Dot11 channel / HsChnl(HsMode)",
 		   wifi_dot11_chnl, wifi_hs_chnl, bt_hs_on);
-	CL_PRINTF(cli_buf);
 
-	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = %02x %02x %02x ",
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "\r\n %-35s = %02x %02x %02x ",
 		   "H2C Wifi inform bt chnl Info",
 		   coex_dm->wifi_chnl_info[0], coex_dm->wifi_chnl_info[1],
 		   coex_dm->wifi_chnl_info[2]);
-	CL_PRINTF(cli_buf);
 
 	btcoexist->btc_get(btcoexist, BTC_GET_S4_WIFI_RSSI, &wifi_rssi);
 	btcoexist->btc_get(btcoexist, BTC_GET_S4_HS_RSSI, &bt_hs_rssi);
-	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = %d/ %d",
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "\r\n %-35s = %d/ %d",
 		   "Wifi rssi/ HS rssi", wifi_rssi, bt_hs_rssi);
-	CL_PRINTF(cli_buf);
 
 	btcoexist->btc_get(btcoexist, BTC_GET_BL_WIFI_SCAN, &scan);
 	btcoexist->btc_get(btcoexist, BTC_GET_BL_WIFI_LINK, &link);
 	btcoexist->btc_get(btcoexist, BTC_GET_BL_WIFI_ROAM, &roam);
-	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = %d/ %d/ %d ",
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "\r\n %-35s = %d/ %d/ %d ",
 		   "Wifi link/ roam/ scan", link, roam, scan);
-	CL_PRINTF(cli_buf);
 
 	btcoexist->btc_get(btcoexist , BTC_GET_BL_WIFI_UNDER_5G,
 			   &wifi_under_5g);
@@ -2493,27 +2480,25 @@ void ex_halbtc8723b1ant_display_coex_info(struct btc_coexist *btcoexist)
 	btcoexist->btc_get(btcoexist, BTC_GET_U4_WIFI_TRAFFIC_DIRECTION,
 			   &wifi_traffic_dir);
 
-	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = %s / %s/ %s ",
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "\r\n %-35s = %s / %s/ %s ",
 		   "Wifi status", (wifi_under_5g ? "5G" : "2.4G"),
 		   ((BTC_WIFI_BW_LEGACY == wifi_bw) ? "Legacy" :
 			(((BTC_WIFI_BW_HT40 == wifi_bw) ? "HT40" : "HT20"))),
 		   ((!wifi_busy) ? "idle" :
 			((BTC_WIFI_TRAFFIC_TX == wifi_traffic_dir) ?
 				"uplink" : "downlink")));
-	CL_PRINTF(cli_buf);
 
 	btcoexist->btc_get(btcoexist, BTC_GET_U4_WIFI_LINK_STATUS,
 			   &wifi_link_status);
-	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = %d/ %d/ %d/ %d/ %d",
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "\r\n %-35s = %d/ %d/ %d/ %d/ %d",
 		   "sta/vwifi/hs/p2pGo/p2pGc",
 		   ((wifi_link_status & WIFI_STA_CONNECTED) ? 1 : 0),
 		   ((wifi_link_status & WIFI_AP_CONNECTED) ? 1 : 0),
 		   ((wifi_link_status & WIFI_HS_CONNECTED) ? 1 : 0),
 		   ((wifi_link_status & WIFI_P2P_GO_CONNECTED) ? 1 : 0),
 		   ((wifi_link_status & WIFI_P2P_GC_CONNECTED) ? 1 : 0));
-	CL_PRINTF(cli_buf);
 
-	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = [%s/ %d/ %d] ",
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "\r\n %-35s = [%s/ %d/ %d] ",
 		   "BT [status/ rssi/ retryCnt]",
 		   ((btcoexist->bt_info.bt_disabled) ? ("disabled") :
 		    ((coex_sta->c2h_bt_inquiry_page) ? ("inquiry/page scan") :
@@ -2524,25 +2509,22 @@ void ex_halbtc8723b1ant_display_coex_info(struct btc_coexist *btcoexist)
 			coex_dm->bt_status) ?
 		       "connected-idle" : "busy")))),
 		     coex_sta->bt_rssi, coex_sta->bt_retry_cnt);
-	CL_PRINTF(cli_buf);
 
-	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE,
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
 		   "\r\n %-35s = %d / %d / %d / %d",
 		   "SCO/HID/PAN/A2DP", bt_link_info->sco_exist,
 		   bt_link_info->hid_exist, bt_link_info->pan_exist,
 		   bt_link_info->a2dp_exist);
-	CL_PRINTF(cli_buf);
 	btcoexist->btc_disp_dbg_msg(btcoexist, BTC_DBG_DISP_BT_LINK_INFO);
 
 	bt_info_ext = coex_sta->bt_info_ext;
-	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = %s",
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "\r\n %-35s = %s",
 		   "BT Info A2DP rate",
 		   (bt_info_ext & BIT0) ? "Basic rate" : "EDR rate");
-	CL_PRINTF(cli_buf);
 
 	for (i = 0; i < BT_INFO_SRC_8723B_1ANT_MAX; i++) {
 		if (coex_sta->bt_info_c2h_cnt[i]) {
-			CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE,
+			RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
 				   "\r\n %-35s = %02x %02x %02x %02x %02x %02x %02x(%d)",
 				   GLBtInfoSrc8723b1Ant[i],
 				   coex_sta->bt_info_c2h[i][0],
@@ -2553,130 +2535,111 @@ void ex_halbtc8723b1ant_display_coex_info(struct btc_coexist *btcoexist)
 				   coex_sta->bt_info_c2h[i][5],
 				   coex_sta->bt_info_c2h[i][6],
 				   coex_sta->bt_info_c2h_cnt[i]);
-			CL_PRINTF(cli_buf);
 		}
 	}
-	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE,
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
 		   "\r\n %-35s = %s/%s, (0x%x/0x%x)",
 		   "PS state, IPS/LPS, (lps/rpwm)",
 		   ((coex_sta->under_ips ? "IPS ON" : "IPS OFF")),
 		   ((coex_sta->under_lps ? "LPS ON" : "LPS OFF")),
 		   btcoexist->bt_info.lps_val,
 		   btcoexist->bt_info.rpwm_val);
-	CL_PRINTF(cli_buf);
 	btcoexist->btc_disp_dbg_msg(btcoexist, BTC_DBG_DISP_FW_PWR_MODE_CMD);
 
 	if (!btcoexist->manual_control) {
 		/* Sw mechanism	*/
-		CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s",
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "\r\n %-35s",
 			   "============[Sw mechanism]============");
-		CL_PRINTF(cli_buf);
 
-		CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = %d/",
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "\r\n %-35s = %d/",
 			   "SM[LowPenaltyRA]", coex_dm->cur_low_penalty_ra);
-		CL_PRINTF(cli_buf);
 
-		CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = %s/ %s/ %d ",
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "\r\n %-35s = %s/ %s/ %d ",
 			   "DelBA/ BtCtrlAgg/ AggSize",
 			   (btcoexist->bt_info.reject_agg_pkt ? "Yes" : "No"),
 			   (btcoexist->bt_info.bt_ctrl_buf_size ? "Yes" : "No"),
 			   btcoexist->bt_info.agg_buf_size);
-		CL_PRINTF(cli_buf);
 
-		CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = 0x%x ",
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "\r\n %-35s = 0x%x ",
 			   "Rate Mask", btcoexist->bt_info.ra_mask);
-		CL_PRINTF(cli_buf);
 
 		/* Fw mechanism	*/
-		CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s",
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "\r\n %-35s",
 			   "============[Fw mechanism]============");
-		CL_PRINTF(cli_buf);
 
 		pstdmacase = coex_dm->cur_ps_tdma;
-		CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE,
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
 			   "\r\n %-35s = %02x %02x %02x %02x %02x case-%d (auto:%d)",
 			   "PS TDMA", coex_dm->ps_tdma_para[0],
 			   coex_dm->ps_tdma_para[1], coex_dm->ps_tdma_para[2],
 			   coex_dm->ps_tdma_para[3], coex_dm->ps_tdma_para[4],
 			   pstdmacase, coex_dm->auto_tdma_adjust);
-		CL_PRINTF(cli_buf);
 
-		CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = %d ",
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "\r\n %-35s = %d ",
 			   "IgnWlanAct", coex_dm->cur_ignore_wlan_act);
-		CL_PRINTF(cli_buf);
 
-		CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = 0x%x ",
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "\r\n %-35s = 0x%x ",
 			   "Latest error condition(should be 0)",
 			   coex_dm->error_condition);
-		CL_PRINTF(cli_buf);
 	}
 
 	/* Hw setting */
-	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s",
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "\r\n %-35s",
 		   "============[Hw setting]============");
-	CL_PRINTF(cli_buf);
 
-	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = 0x%x/0x%x/0x%x/0x%x",
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "\r\n %-35s = 0x%x/0x%x/0x%x/0x%x",
 		   "backup ARFR1/ARFR2/RL/AMaxTime", coex_dm->backup_arfr_cnt1,
 		   coex_dm->backup_arfr_cnt2, coex_dm->backup_retry_limit,
 		   coex_dm->backup_ampdu_max_time);
-	CL_PRINTF(cli_buf);
 
 	u32tmp[0] = btcoexist->btc_read_4byte(btcoexist, 0x430);
 	u32tmp[1] = btcoexist->btc_read_4byte(btcoexist, 0x434);
 	u16tmp[0] = btcoexist->btc_read_2byte(btcoexist, 0x42a);
 	u8tmp[0] = btcoexist->btc_read_1byte(btcoexist, 0x456);
-	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = 0x%x/0x%x/0x%x/0x%x",
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "\r\n %-35s = 0x%x/0x%x/0x%x/0x%x",
 		   "0x430/0x434/0x42a/0x456",
 		   u32tmp[0], u32tmp[1], u16tmp[0], u8tmp[0]);
-	CL_PRINTF(cli_buf);
 
 	u8tmp[0] = btcoexist->btc_read_1byte(btcoexist, 0x778);
 	u32tmp[0] = btcoexist->btc_read_4byte(btcoexist, 0x6cc);
 	u32tmp[1] = btcoexist->btc_read_4byte(btcoexist, 0x880);
-	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = 0x%x/ 0x%x/ 0x%x",
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "\r\n %-35s = 0x%x/ 0x%x/ 0x%x",
 		   "0x778/0x6cc/0x880[29:25]", u8tmp[0], u32tmp[0],
 		   (u32tmp[1] & 0x3e000000) >> 25);
-	CL_PRINTF(cli_buf);
 
 	u32tmp[0] = btcoexist->btc_read_4byte(btcoexist, 0x948);
 	u8tmp[0] = btcoexist->btc_read_1byte(btcoexist, 0x67);
 	u8tmp[1] = btcoexist->btc_read_1byte(btcoexist, 0x765);
-	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = 0x%x/ 0x%x/ 0x%x",
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "\r\n %-35s = 0x%x/ 0x%x/ 0x%x",
 		   "0x948/ 0x67[5] / 0x765",
 		   u32tmp[0], ((u8tmp[0] & 0x20) >> 5), u8tmp[1]);
-	CL_PRINTF(cli_buf);
 
 	u32tmp[0] = btcoexist->btc_read_4byte(btcoexist, 0x92c);
 	u32tmp[1] = btcoexist->btc_read_4byte(btcoexist, 0x930);
 	u32tmp[2] = btcoexist->btc_read_4byte(btcoexist, 0x944);
-	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = 0x%x/ 0x%x/ 0x%x",
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "\r\n %-35s = 0x%x/ 0x%x/ 0x%x",
 		   "0x92c[1:0]/ 0x930[7:0]/0x944[1:0]",
 		   u32tmp[0] & 0x3, u32tmp[1] & 0xff, u32tmp[2] & 0x3);
-	CL_PRINTF(cli_buf);
 
 	u8tmp[0] = btcoexist->btc_read_1byte(btcoexist, 0x39);
 	u8tmp[1] = btcoexist->btc_read_1byte(btcoexist, 0x40);
 	u32tmp[0] = btcoexist->btc_read_4byte(btcoexist, 0x4c);
 	u8tmp[2] = btcoexist->btc_read_1byte(btcoexist, 0x64);
-	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE,
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
 		   "\r\n %-35s = 0x%x/ 0x%x/ 0x%x/ 0x%x",
 		   "0x38[11]/0x40/0x4c[24:23]/0x64[0]",
 		   ((u8tmp[0] & 0x8)>>3), u8tmp[1],
 		   ((u32tmp[0] & 0x01800000) >> 23), u8tmp[2] & 0x1);
-	CL_PRINTF(cli_buf);
 
 	u32tmp[0] = btcoexist->btc_read_4byte(btcoexist, 0x550);
 	u8tmp[0] = btcoexist->btc_read_1byte(btcoexist, 0x522);
-	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = 0x%x/ 0x%x",
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "\r\n %-35s = 0x%x/ 0x%x",
 		   "0x550(bcn ctrl)/0x522", u32tmp[0], u8tmp[0]);
-	CL_PRINTF(cli_buf);
 
 	u32tmp[0] = btcoexist->btc_read_4byte(btcoexist, 0xc50);
 	u8tmp[0] = btcoexist->btc_read_1byte(btcoexist, 0x49c);
-	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = 0x%x/ 0x%x",
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "\r\n %-35s = 0x%x/ 0x%x",
 		   "0xc50(dig)/0x49c(null-drop)", u32tmp[0] & 0xff, u8tmp[0]);
-	CL_PRINTF(cli_buf);
 
 	u32tmp[0] = btcoexist->btc_read_4byte(btcoexist, 0xda0);
 	u32tmp[1] = btcoexist->btc_read_4byte(btcoexist, 0xda4);
@@ -2694,27 +2657,23 @@ void ex_halbtc8723b1ant_display_coex_info(struct btc_coexist *btcoexist)
 		   (u32tmp[3] & 0xffff);
 	fa_cck = (u8tmp[0] << 8) + u8tmp[1];
 
-	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = 0x%x/ 0x%x/ 0x%x",
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "\r\n %-35s = 0x%x/ 0x%x/ 0x%x",
 		   "OFDM-CCA/OFDM-FA/CCK-FA",
 		   u32tmp[0] & 0xffff, fa_ofdm, fa_cck);
-	CL_PRINTF(cli_buf);
 
 	u32tmp[0] = btcoexist->btc_read_4byte(btcoexist, 0x6c0);
 	u32tmp[1] = btcoexist->btc_read_4byte(btcoexist, 0x6c4);
 	u32tmp[2] = btcoexist->btc_read_4byte(btcoexist, 0x6c8);
-	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = 0x%x/ 0x%x/ 0x%x",
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "\r\n %-35s = 0x%x/ 0x%x/ 0x%x",
 		   "0x6c0/0x6c4/0x6c8(coexTable)",
 		   u32tmp[0], u32tmp[1], u32tmp[2]);
-	CL_PRINTF(cli_buf);
 
-	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = %d/ %d",
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "\r\n %-35s = %d/ %d",
 		   "0x770(high-pri rx/tx)", coex_sta->high_priority_rx,
 		   coex_sta->high_priority_tx);
-	CL_PRINTF(cli_buf);
-	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = %d/ %d",
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "\r\n %-35s = %d/ %d",
 		   "0x774(low-pri rx/tx)", coex_sta->low_priority_rx,
 		   coex_sta->low_priority_tx);
-	CL_PRINTF(cli_buf);
 #if (BT_AUTO_REPORT_ONLY_8723B_1ANT == 1)
 	halbtc8723b1ant_monitor_bt_ctr(btcoexist);
 #endif
diff --git a/drivers/net/wireless/rtlwifi/btcoexist/halbtc8723b2ant.c b/drivers/net/wireless/rtlwifi/btcoexist/halbtc8723b2ant.c
index bd37d65..cefe269 100644
--- a/drivers/net/wireless/rtlwifi/btcoexist/halbtc8723b2ant.c
+++ b/drivers/net/wireless/rtlwifi/btcoexist/halbtc8723b2ant.c
@@ -3159,7 +3159,7 @@ void ex_btc8723b2ant_display_coex_info(struct btc_coexist *btcoexist)
 	struct btc_board_info *board_info = &btcoexist->board_info;
 	struct btc_stack_info *stack_info = &btcoexist->stack_info;
 	struct btc_bt_link_info *bt_link_info = &btcoexist->bt_link_info;
-	u8 *cli_buf = btcoexist->cli_buf;
+	struct rtl_priv *rtlpriv = btcoexist->adapter;
 	u8 u8tmp[4], i, bt_info_ext, ps_tdma_case = 0;
 	u32 u32tmp[4];
 	bool roam = false, scan = false;
@@ -3171,106 +3171,91 @@ void ex_btc8723b2ant_display_coex_info(struct btc_coexist *btcoexist)
 	u32 fw_ver = 0, bt_patch_ver = 0;
 	u8 ap_num = 0;
 
-	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE,
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
 		   "\r\n ============[BT Coexist info]============");
-	CL_PRINTF(cli_buf);
 
 	if (btcoexist->manual_control) {
-		CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE,
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
 			   "\r\n ==========[Under Manual Control]============");
-		CL_PRINTF(cli_buf);
-		CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE,
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
 			   "\r\n ==========================================");
-		CL_PRINTF(cli_buf);
 	}
 
 	if (!board_info->bt_exist) {
-		CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n BT not exists !!!");
-		CL_PRINTF(cli_buf);
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "\r\n BT not exists !!!");
 		return;
 	}
 
-	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = %d/ %d ",
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "\r\n %-35s = %d/ %d ",
 		   "Ant PG number/ Ant mechanism:",
 		   board_info->pg_ant_num, board_info->btdm_ant_num);
-	CL_PRINTF(cli_buf);
 
-	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = %s / %d",
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "\r\n %-35s = %s / %d",
 		   "BT stack/ hci ext ver",
 		   ((stack_info->profile_notified) ? "Yes" : "No"),
 		   stack_info->hci_version);
-	CL_PRINTF(cli_buf);
 
 	btcoexist->btc_get(btcoexist, BTC_GET_U4_BT_PATCH_VER, &bt_patch_ver);
 	btcoexist->btc_get(btcoexist, BTC_GET_U4_WIFI_FW_VER, &fw_ver);
-	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE,
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
 		   "\r\n %-35s = %d_%x/ 0x%x/ 0x%x(%d)",
 		   "CoexVer/ FwVer/ PatchVer",
 		   glcoex_ver_date_8723b_2ant, glcoex_ver_8723b_2ant,
 		   fw_ver, bt_patch_ver, bt_patch_ver);
-	CL_PRINTF(cli_buf);
 
 	btcoexist->btc_get(btcoexist, BTC_GET_BL_HS_OPERATION, &bt_hs_on);
 	btcoexist->btc_get(btcoexist, BTC_GET_U1_WIFI_DOT11_CHNL,
 			   &wifi_dot11_chnl);
 	btcoexist->btc_get(btcoexist, BTC_GET_U1_WIFI_HS_CHNL, &wifi_hs_chnl);
 
-	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = %d / %d(%d)",
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "\r\n %-35s = %d / %d(%d)",
 		   "Dot11 channel / HsChnl(HsMode)",
 		   wifi_dot11_chnl, wifi_hs_chnl, bt_hs_on);
-	CL_PRINTF(cli_buf);
 
-	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = %02x %02x %02x ",
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "\r\n %-35s = %02x %02x %02x ",
 		   "H2C Wifi inform bt chnl Info", coex_dm->wifi_chnl_info[0],
 		   coex_dm->wifi_chnl_info[1], coex_dm->wifi_chnl_info[2]);
-	CL_PRINTF(cli_buf);
 
 	btcoexist->btc_get(btcoexist, BTC_GET_S4_WIFI_RSSI, &wifi_rssi);
 	btcoexist->btc_get(btcoexist, BTC_GET_S4_HS_RSSI, &bt_hs_rssi);
 	btcoexist->btc_get(btcoexist, BTC_GET_U1_AP_NUM, &ap_num);
-	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = %d/ %d/ %d",
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "\r\n %-35s = %d/ %d/ %d",
 		   "Wifi rssi/ HS rssi/ AP#", wifi_rssi, bt_hs_rssi, ap_num);
-	CL_PRINTF(cli_buf);
 
 	btcoexist->btc_get(btcoexist, BTC_GET_BL_WIFI_SCAN, &scan);
 	btcoexist->btc_get(btcoexist, BTC_GET_BL_WIFI_LINK, &link);
 	btcoexist->btc_get(btcoexist, BTC_GET_BL_WIFI_ROAM, &roam);
-	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = %d/ %d/ %d ",
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "\r\n %-35s = %d/ %d/ %d ",
 		   "Wifi link/ roam/ scan", link, roam, scan);
-	CL_PRINTF(cli_buf);
 
 	btcoexist->btc_get(btcoexist, BTC_GET_BL_WIFI_UNDER_5G, &wifi_under_5g);
 	btcoexist->btc_get(btcoexist, BTC_GET_U4_WIFI_BW, &wifi_bw);
 	btcoexist->btc_get(btcoexist, BTC_GET_BL_WIFI_BUSY, &wifi_busy);
 	btcoexist->btc_get(btcoexist, BTC_GET_U4_WIFI_TRAFFIC_DIRECTION,
 			   &wifi_traffic_dir);
-	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = %s / %s/ %s ",
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "\r\n %-35s = %s / %s/ %s ",
 		   "Wifi status", (wifi_under_5g ? "5G" : "2.4G"),
 		   ((BTC_WIFI_BW_LEGACY == wifi_bw) ? "Legacy" :
 		   (((BTC_WIFI_BW_HT40 == wifi_bw) ? "HT40" : "HT20"))),
 		   ((!wifi_busy) ? "idle" :
 		   ((BTC_WIFI_TRAFFIC_TX == wifi_traffic_dir) ?
 		   "uplink" : "downlink")));
-	CL_PRINTF(cli_buf);
 
-	CL_PRINTF(cli_buf);
 
-	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = %d / %d / %d / %d",
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "\r\n %-35s = %d / %d / %d / %d",
 		   "SCO/HID/PAN/A2DP",
 		   bt_link_info->sco_exist, bt_link_info->hid_exist,
 		   bt_link_info->pan_exist, bt_link_info->a2dp_exist);
-	CL_PRINTF(cli_buf);
 	btcoexist->btc_disp_dbg_msg(btcoexist, BTC_DBG_DISP_BT_LINK_INFO);
 
 	bt_info_ext = coex_sta->bt_info_ext;
-	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = %s",
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "\r\n %-35s = %s",
 		   "BT Info A2DP rate",
 		   (bt_info_ext&BIT0) ? "Basic rate" : "EDR rate");
-	CL_PRINTF(cli_buf);
 
 	for (i = 0; i < BT_INFO_SRC_8723B_2ANT_MAX; i++) {
 		if (coex_sta->bt_info_c2h_cnt[i]) {
-			CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE,
+			RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
 				   "\r\n %-35s = %02x %02x %02x "
 				   "%02x %02x %02x %02x(%d)",
 				   glbt_info_src_8723b_2ant[i],
@@ -3282,104 +3267,88 @@ void ex_btc8723b2ant_display_coex_info(struct btc_coexist *btcoexist)
 				   coex_sta->bt_info_c2h[i][5],
 				   coex_sta->bt_info_c2h[i][6],
 				   coex_sta->bt_info_c2h_cnt[i]);
-			CL_PRINTF(cli_buf);
 		}
 	}
 
-	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = %s/%s",
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "\r\n %-35s = %s/%s",
 		   "PS state, IPS/LPS",
 		   ((coex_sta->under_ips ? "IPS ON" : "IPS OFF")),
 		   ((coex_sta->under_lps ? "LPS ON" : "LPS OFF")));
-	CL_PRINTF(cli_buf);
 	btcoexist->btc_disp_dbg_msg(btcoexist, BTC_DBG_DISP_FW_PWR_MODE_CMD);
 
 	/* Sw mechanism	*/
-	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE,
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
 		   "\r\n %-35s", "============[Sw mechanism]============");
-	CL_PRINTF(cli_buf);
-	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = %d/ %d/ %d ",
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "\r\n %-35s = %d/ %d/ %d ",
 		   "SM1[ShRf/ LpRA/ LimDig]", coex_dm->cur_rf_rx_lpf_shrink,
 		   coex_dm->cur_low_penalty_ra, coex_dm->limited_dig);
-	CL_PRINTF(cli_buf);
-	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = %d/ %d/ %d(0x%x) ",
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "\r\n %-35s = %d/ %d/ %d(0x%x) ",
 		   "SM2[AgcT/ AdcB/ SwDacSwing(lvl)]",
 		   coex_dm->cur_agc_table_en, coex_dm->cur_adc_back_off,
 		   coex_dm->cur_dac_swing_on, coex_dm->cur_dac_swing_lvl);
-	CL_PRINTF(cli_buf);
 
 	/* Fw mechanism	*/
-	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s",
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "\r\n %-35s",
 		   "============[Fw mechanism]============");
-	CL_PRINTF(cli_buf);
 
 	ps_tdma_case = coex_dm->cur_ps_tdma;
-	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE,
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
 		   "\r\n %-35s = %02x %02x %02x %02x %02x case-%d (auto:%d)",
 		   "PS TDMA", coex_dm->ps_tdma_para[0],
 		   coex_dm->ps_tdma_para[1], coex_dm->ps_tdma_para[2],
 		   coex_dm->ps_tdma_para[3], coex_dm->ps_tdma_para[4],
 		   ps_tdma_case, coex_dm->auto_tdma_adjust);
-	CL_PRINTF(cli_buf);
 
-	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = %d/ %d ",
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "\r\n %-35s = %d/ %d ",
 		   "DecBtPwr/ IgnWlanAct", coex_dm->cur_dec_bt_pwr,
 		   coex_dm->cur_ignore_wlan_act);
-	CL_PRINTF(cli_buf);
 
 	/* Hw setting */
-	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s",
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "\r\n %-35s",
 		   "============[Hw setting]============");
-	CL_PRINTF(cli_buf);
 
-	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = 0x%x",
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "\r\n %-35s = 0x%x",
 		   "RF-A, 0x1e initVal", coex_dm->bt_rf0x1e_backup);
-	CL_PRINTF(cli_buf);
 
 	u8tmp[0] = btcoexist->btc_read_1byte(btcoexist, 0x778);
 	u32tmp[0] = btcoexist->btc_read_4byte(btcoexist, 0x880);
-	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = 0x%x/ 0x%x",
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "\r\n %-35s = 0x%x/ 0x%x",
 		   "0x778/0x880[29:25]", u8tmp[0],
 		   (u32tmp[0]&0x3e000000) >> 25);
-	CL_PRINTF(cli_buf);
 
 	u32tmp[0] = btcoexist->btc_read_4byte(btcoexist, 0x948);
 	u8tmp[0] = btcoexist->btc_read_1byte(btcoexist, 0x67);
 	u8tmp[1] = btcoexist->btc_read_1byte(btcoexist, 0x765);
-	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = 0x%x/ 0x%x/ 0x%x",
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "\r\n %-35s = 0x%x/ 0x%x/ 0x%x",
 		   "0x948/ 0x67[5] / 0x765",
 		   u32tmp[0], ((u8tmp[0]&0x20) >> 5), u8tmp[1]);
-	CL_PRINTF(cli_buf);
 
 	u32tmp[0] = btcoexist->btc_read_4byte(btcoexist, 0x92c);
 	u32tmp[1] = btcoexist->btc_read_4byte(btcoexist, 0x930);
 	u32tmp[2] = btcoexist->btc_read_4byte(btcoexist, 0x944);
-	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = 0x%x/ 0x%x/ 0x%x",
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "\r\n %-35s = 0x%x/ 0x%x/ 0x%x",
 		   "0x92c[1:0]/ 0x930[7:0]/0x944[1:0]",
 		   u32tmp[0]&0x3, u32tmp[1]&0xff, u32tmp[2]&0x3);
-	CL_PRINTF(cli_buf);
 
 	u8tmp[0] = btcoexist->btc_read_1byte(btcoexist, 0x39);
 	u8tmp[1] = btcoexist->btc_read_1byte(btcoexist, 0x40);
 	u32tmp[0] = btcoexist->btc_read_4byte(btcoexist, 0x4c);
 	u8tmp[2] = btcoexist->btc_read_1byte(btcoexist, 0x64);
-	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE,
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
 		   "\r\n %-35s = 0x%x/ 0x%x/ 0x%x/ 0x%x",
 		   "0x38[11]/0x40/0x4c[24:23]/0x64[0]",
 		   ((u8tmp[0] & 0x8)>>3), u8tmp[1],
 		   ((u32tmp[0]&0x01800000)>>23), u8tmp[2]&0x1);
-	CL_PRINTF(cli_buf);
 
 	u32tmp[0] = btcoexist->btc_read_4byte(btcoexist, 0x550);
 	u8tmp[0] = btcoexist->btc_read_1byte(btcoexist, 0x522);
-	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = 0x%x/ 0x%x",
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "\r\n %-35s = 0x%x/ 0x%x",
 		   "0x550(bcn ctrl)/0x522", u32tmp[0], u8tmp[0]);
-	CL_PRINTF(cli_buf);
 
 	u32tmp[0] = btcoexist->btc_read_4byte(btcoexist, 0xc50);
 	u8tmp[0] = btcoexist->btc_read_1byte(btcoexist, 0x49c);
-	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = 0x%x/ 0x%x",
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "\r\n %-35s = 0x%x/ 0x%x",
 		   "0xc50(dig)/0x49c(null-drop)", u32tmp[0]&0xff, u8tmp[0]);
-	CL_PRINTF(cli_buf);
 
 	u32tmp[0] = btcoexist->btc_read_4byte(btcoexist, 0xda0);
 	u32tmp[1] = btcoexist->btc_read_4byte(btcoexist, 0xda4);
@@ -3397,29 +3366,25 @@ void ex_btc8723b2ant_display_coex_info(struct btc_coexist *btcoexist)
 		   (u32tmp[3] & 0xffff);
 	fa_cck = (u8tmp[0] << 8) + u8tmp[1];
 
-	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = 0x%x/ 0x%x/ 0x%x",
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "\r\n %-35s = 0x%x/ 0x%x/ 0x%x",
 		   "OFDM-CCA/OFDM-FA/CCK-FA",
 		   u32tmp[0]&0xffff, fa_ofdm, fa_cck);
-	CL_PRINTF(cli_buf);
 
 	u32tmp[0] = btcoexist->btc_read_4byte(btcoexist, 0x6c0);
 	u32tmp[1] = btcoexist->btc_read_4byte(btcoexist, 0x6c4);
 	u32tmp[2] = btcoexist->btc_read_4byte(btcoexist, 0x6c8);
 	u8tmp[0] = btcoexist->btc_read_1byte(btcoexist, 0x6cc);
-	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE,
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
 		   "\r\n %-35s = 0x%x/ 0x%x/ 0x%x/ 0x%x",
 		   "0x6c0/0x6c4/0x6c8/0x6cc(coexTable)",
 		   u32tmp[0], u32tmp[1], u32tmp[2], u8tmp[0]);
-	CL_PRINTF(cli_buf);
 
-	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = %d/ %d",
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "\r\n %-35s = %d/ %d",
 		   "0x770(high-pri rx/tx)",
 		   coex_sta->high_priority_rx, coex_sta->high_priority_tx);
-	CL_PRINTF(cli_buf);
-	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = %d/ %d",
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "\r\n %-35s = %d/ %d",
 		   "0x774(low-pri rx/tx)", coex_sta->low_priority_rx,
 		   coex_sta->low_priority_tx);
-	CL_PRINTF(cli_buf);
 #if (BT_AUTO_REPORT_ONLY_8723B_2ANT == 1)
 	btc8723b2ant_monitor_bt_ctr(btcoexist);
 #endif
diff --git a/drivers/net/wireless/rtlwifi/btcoexist/halbtc8821a1ant.c b/drivers/net/wireless/rtlwifi/btcoexist/halbtc8821a1ant.c
index 0b75e8c..b72e537 100644
--- a/drivers/net/wireless/rtlwifi/btcoexist/halbtc8821a1ant.c
+++ b/drivers/net/wireless/rtlwifi/btcoexist/halbtc8821a1ant.c
@@ -2235,7 +2235,7 @@ void ex_halbtc8821a1ant_display_coex_info(struct btc_coexist *btcoexist)
 	struct btc_board_info *board_info = &btcoexist->board_info;
 	struct btc_stack_info *stack_info = &btcoexist->stack_info;
 	struct btc_bt_link_info *bt_link_info = &btcoexist->bt_link_info;
-	u8 *cli_buf = btcoexist->cli_buf;
+	struct rtl_priv *rtlpriv = btcoexist->adapter;
 	u8 u1_tmp[4], i, bt_info_ext, ps_tdma_case = 0;
 	u16 u2_tmp[4];
 	u32 u4_tmp[4];
@@ -2246,58 +2246,49 @@ void ex_halbtc8821a1ant_display_coex_info(struct btc_coexist *btcoexist)
 	u8 wifi_dot11_chnl, wifi_hs_chnl;
 	u32 fw_ver = 0, bt_patch_ver = 0;
 
-	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE,
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
 		   "\r\n ============[BT Coexist info]============");
-	CL_PRINTF(cli_buf);
 
 	if (btcoexist->manual_control) {
-		CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE,
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
 			   "\r\n ============[Under Manual Control]============");
-		CL_PRINTF(cli_buf);
-		CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE,
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
 			   "\r\n ==========================================");
-		CL_PRINTF(cli_buf);
 	}
 	if (btcoexist->stop_coex_dm) {
-		CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE,
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
 			   "\r\n ============[Coex is STOPPED]============");
-		CL_PRINTF(cli_buf);
-		CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE,
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
 			   "\r\n ==========================================");
-		CL_PRINTF(cli_buf);
 	}
 
 	if (!board_info->bt_exist) {
-		CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n BT not exists !!!");
-		CL_PRINTF(cli_buf);
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "\r\n BT not exists !!!");
 		return;
 	}
 
-	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE,
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
 		   "\r\n %-35s = %d/ %d/ %d",
 		   "Ant PG Num/ Ant Mech/ Ant Pos:",
 		   board_info->pg_ant_num,
 		   board_info->btdm_ant_num,
 		   board_info->btdm_ant_pos);
-	CL_PRINTF(cli_buf);
 
-	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE,
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
 		   "\r\n %-35s = %s / %d", "BT stack/ hci ext ver",
 		   ((stack_info->profile_notified) ? "Yes" : "No"),
 		stack_info->hci_version);
-	CL_PRINTF(cli_buf);
 
 	btcoexist->btc_get(btcoexist, BTC_GET_U4_BT_PATCH_VER,
 			   &bt_patch_ver);
 	btcoexist->btc_get(btcoexist, BTC_GET_U4_WIFI_FW_VER, &fw_ver);
-	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE,
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
 		   "\r\n %-35s = %d_%x/ 0x%x/ 0x%x(%d)",
 		   "CoexVer/ FwVer/ PatchVer",
 		   glcoex_ver_date_8821a_1ant,
 		   glcoex_ver_8821a_1ant,
 		   fw_ver, bt_patch_ver,
 		   bt_patch_ver);
-	CL_PRINTF(cli_buf);
 
 	btcoexist->btc_get(btcoexist, BTC_GET_BL_HS_OPERATION,
 			   &bt_hs_on);
@@ -2305,33 +2296,29 @@ void ex_halbtc8821a1ant_display_coex_info(struct btc_coexist *btcoexist)
 			   &wifi_dot11_chnl);
 	btcoexist->btc_get(btcoexist, BTC_GET_U1_WIFI_HS_CHNL,
 			   &wifi_hs_chnl);
-	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE,
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
 		   "\r\n %-35s = %d / %d(%d)",
 		   "Dot11 channel / HsChnl(HsMode)",
 		   wifi_dot11_chnl, wifi_hs_chnl, bt_hs_on);
-	CL_PRINTF(cli_buf);
 
-	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE,
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
 		   "\r\n %-35s = %02x %02x %02x ",
 		   "H2C Wifi inform bt chnl Info",
 		   coex_dm->wifi_chnl_info[0], coex_dm->wifi_chnl_info[1],
 		   coex_dm->wifi_chnl_info[2]);
-	CL_PRINTF(cli_buf);
 
 	btcoexist->btc_get(btcoexist, BTC_GET_S4_WIFI_RSSI, &wifi_rssi);
 	btcoexist->btc_get(btcoexist, BTC_GET_S4_HS_RSSI, &bt_hs_rssi);
-	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE,
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
 		   "\r\n %-35s = %d/ %d", "Wifi rssi/ HS rssi",
 		   (int)wifi_rssi, (int)bt_hs_rssi);
-	CL_PRINTF(cli_buf);
 
 	btcoexist->btc_get(btcoexist, BTC_GET_BL_WIFI_SCAN, &scan);
 	btcoexist->btc_get(btcoexist, BTC_GET_BL_WIFI_LINK, &link);
 	btcoexist->btc_get(btcoexist, BTC_GET_BL_WIFI_ROAM, &roam);
-	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE,
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
 		   "\r\n %-35s = %d/ %d/ %d ", "Wifi link/ roam/ scan",
 		   link, roam, scan);
-	CL_PRINTF(cli_buf);
 
 	btcoexist->btc_get(btcoexist, BTC_GET_BL_WIFI_UNDER_5G,
 			   &wifi_under_5g);
@@ -2341,7 +2328,7 @@ void ex_halbtc8821a1ant_display_coex_info(struct btc_coexist *btcoexist)
 			   &wifi_busy);
 	btcoexist->btc_get(btcoexist, BTC_GET_U4_WIFI_TRAFFIC_DIRECTION,
 			   &wifi_traffic_dir);
-	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE,
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
 		   "\r\n %-35s = %s / %s/ %s ", "Wifi status",
 		   (wifi_under_5g ? "5G" : "2.4G"),
 		   ((BTC_WIFI_BW_LEGACY == wifi_bw) ? "Legacy" :
@@ -2349,8 +2336,7 @@ void ex_halbtc8821a1ant_display_coex_info(struct btc_coexist *btcoexist)
 		   ((!wifi_busy) ? "idle" :
 		   ((BTC_WIFI_TRAFFIC_TX == wifi_traffic_dir) ?
 		   "uplink" : "downlink")));
-	CL_PRINTF(cli_buf);
-	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE,
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
 		   "\r\n %-35s = [%s/ %d/ %d] ", "BT [status/ rssi/ retryCnt]",
 		   ((btcoexist->bt_info.bt_disabled) ? ("disabled") :
 		   ((coex_sta->c2h_bt_inquiry_page) ? ("inquiry/page scan") :
@@ -2361,28 +2347,25 @@ void ex_halbtc8821a1ant_display_coex_info(struct btc_coexist *btcoexist)
 		     coex_dm->bt_status) ?
 		   "connected-idle" : "busy")))),
 		   coex_sta->bt_rssi, coex_sta->bt_retry_cnt);
-	CL_PRINTF(cli_buf);
 
-	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE,
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
 		   "\r\n %-35s = %d / %d / %d / %d", "SCO/HID/PAN/A2DP",
 		   bt_link_info->sco_exist,
 		   bt_link_info->hid_exist,
 		   bt_link_info->pan_exist,
 		   bt_link_info->a2dp_exist);
-	CL_PRINTF(cli_buf);
 	btcoexist->btc_disp_dbg_msg(btcoexist, BTC_DBG_DISP_BT_LINK_INFO);
 
 	bt_info_ext = coex_sta->bt_info_ext;
-	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE,
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
 		   "\r\n %-35s = %s",
 		   "BT Info A2DP rate",
 		   (bt_info_ext&BIT0) ?
 		   "Basic rate" : "EDR rate");
-	CL_PRINTF(cli_buf);
 
 	for (i = 0; i < BT_INFO_SRC_8821A_1ANT_MAX; i++) {
 		if (coex_sta->bt_info_c2h_cnt[i]) {
-			CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE,
+			RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
 				   "\r\n %-35s = %02x %02x %02x %02x %02x %02x %02x(%d)",
 				   glbt_info_src_8821a_1ant[i],
 				   coex_sta->bt_info_c2h[i][0],
@@ -2393,49 +2376,42 @@ void ex_halbtc8821a1ant_display_coex_info(struct btc_coexist *btcoexist)
 				   coex_sta->bt_info_c2h[i][5],
 				   coex_sta->bt_info_c2h[i][6],
 				   coex_sta->bt_info_c2h_cnt[i]);
-			CL_PRINTF(cli_buf);
 		}
 	}
-	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE,
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
 		   "\r\n %-35s = %s/%s, (0x%x/0x%x)",
 		   "PS state, IPS/LPS, (lps/rpwm)",
 		   ((coex_sta->under_ips ? "IPS ON" : "IPS OFF")),
 		   ((coex_sta->under_Lps ? "LPS ON" : "LPS OFF")),
 		   btcoexist->bt_info.lps_val,
 		   btcoexist->bt_info.rpwm_val);
-	CL_PRINTF(cli_buf);
 	btcoexist->btc_disp_dbg_msg(btcoexist, BTC_DBG_DISP_FW_PWR_MODE_CMD);
 
 	if (!btcoexist->manual_control) {
 		/* Sw mechanism*/
-		CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE,
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
 			   "\r\n %-35s", "============[Sw mechanism]============");
-		CL_PRINTF(cli_buf);
 
-		CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE,
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
 			   "\r\n %-35s = %d", "SM[LowPenaltyRA]",
 			   coex_dm->cur_low_penalty_ra);
-		CL_PRINTF(cli_buf);
 
-		CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE,
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
 			   "\r\n %-35s = %s/ %s/ %d ",
 			   "DelBA/ BtCtrlAgg/ AggSize",
 			   (btcoexist->bt_info.reject_agg_pkt ? "Yes" : "No"),
 			   (btcoexist->bt_info.bt_ctrl_buf_size ? "Yes" : "No"),
 			   btcoexist->bt_info.agg_buf_size);
-		CL_PRINTF(cli_buf);
-		CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE,
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
 			   "\r\n %-35s = 0x%x ", "Rate Mask",
 			   btcoexist->bt_info.ra_mask);
-		CL_PRINTF(cli_buf);
 
 		/* Fw mechanism*/
-		CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s",
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "\r\n %-35s",
 			   "============[Fw mechanism]============");
-		CL_PRINTF(cli_buf);
 
 		ps_tdma_case = coex_dm->cur_ps_tdma;
-		CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE,
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
 			   "\r\n %-35s = %02x %02x %02x %02x %02x case-%d (auto:%d)",
 			   "PS TDMA",
 			   coex_dm->ps_tdma_para[0],
@@ -2445,115 +2421,99 @@ void ex_halbtc8821a1ant_display_coex_info(struct btc_coexist *btcoexist)
 			   coex_dm->ps_tdma_para[4],
 			   ps_tdma_case,
 			   coex_dm->auto_tdma_adjust);
-		CL_PRINTF(cli_buf);
 
-		CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE,
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
 			   "\r\n %-35s = 0x%x ",
 			   "Latest error condition(should be 0)",
 			   coex_dm->error_condition);
-		CL_PRINTF(cli_buf);
 
-		CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE,
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
 			   "\r\n %-35s = %d ", "IgnWlanAct",
 			   coex_dm->cur_ignore_wlan_act);
-		CL_PRINTF(cli_buf);
 	}
 
 	/* Hw setting*/
-	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE,
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
 		   "\r\n %-35s", "============[Hw setting]============");
-	CL_PRINTF(cli_buf);
 
-	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE,
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
 		   "\r\n %-35s = 0x%x/0x%x/0x%x/0x%x",
 		   "backup ARFR1/ARFR2/RL/AMaxTime",
 		   coex_dm->backup_arfr_cnt1,
 		   coex_dm->backup_arfr_cnt2,
 		   coex_dm->backup_retry_limit,
 		   coex_dm->backup_ampdu_max_time);
-	CL_PRINTF(cli_buf);
 
 	u4_tmp[0] = btcoexist->btc_read_4byte(btcoexist, 0x430);
 	u4_tmp[1] = btcoexist->btc_read_4byte(btcoexist, 0x434);
 	u2_tmp[0] = btcoexist->btc_read_2byte(btcoexist, 0x42a);
 	u1_tmp[0] = btcoexist->btc_read_1byte(btcoexist, 0x456);
-	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE,
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
 		   "\r\n %-35s = 0x%x/0x%x/0x%x/0x%x",
 		   "0x430/0x434/0x42a/0x456",
 		   u4_tmp[0], u4_tmp[1], u2_tmp[0], u1_tmp[0]);
-	CL_PRINTF(cli_buf);
 
 	u1_tmp[0] = btcoexist->btc_read_1byte(btcoexist, 0x778);
 	u4_tmp[0] = btcoexist->btc_read_4byte(btcoexist, 0xc58);
-	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE,
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
 		   "\r\n %-35s = 0x%x/ 0x%x", "0x778/ 0xc58[29:25]",
 		   u1_tmp[0], (u4_tmp[0]&0x3e000000) >> 25);
-	CL_PRINTF(cli_buf);
 
 	u1_tmp[0] = btcoexist->btc_read_1byte(btcoexist, 0x8db);
-	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE,
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
 		   "\r\n %-35s = 0x%x", "0x8db[6:5]",
 		   ((u1_tmp[0]&0x60)>>5));
-	CL_PRINTF(cli_buf);
 
 	u1_tmp[0] = btcoexist->btc_read_1byte(btcoexist, 0x975);
 	u4_tmp[0] = btcoexist->btc_read_4byte(btcoexist, 0xcb4);
-	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE,
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
 		   "\r\n %-35s = 0x%x/ 0x%x/ 0x%x",
 		   "0xcb4[29:28]/0xcb4[7:0]/0x974[9:8]",
 		   (u4_tmp[0] & 0x30000000)>>28,
 		    u4_tmp[0] & 0xff,
 		    u1_tmp[0] & 0x3);
-	CL_PRINTF(cli_buf);
 
 	u1_tmp[0] = btcoexist->btc_read_1byte(btcoexist, 0x40);
 	u4_tmp[0] = btcoexist->btc_read_4byte(btcoexist, 0x4c);
 	u1_tmp[1] = btcoexist->btc_read_1byte(btcoexist, 0x64);
-	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE,
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
 		   "\r\n %-35s = 0x%x/ 0x%x/ 0x%x",
 		   "0x40/0x4c[24:23]/0x64[0]",
 		   u1_tmp[0], ((u4_tmp[0]&0x01800000)>>23), u1_tmp[1]&0x1);
-	CL_PRINTF(cli_buf);
 
 	u4_tmp[0] = btcoexist->btc_read_4byte(btcoexist, 0x550);
 	u1_tmp[0] = btcoexist->btc_read_1byte(btcoexist, 0x522);
-	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE,
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
 		   "\r\n %-35s = 0x%x/ 0x%x", "0x550(bcn ctrl)/0x522",
 		   u4_tmp[0], u1_tmp[0]);
-	CL_PRINTF(cli_buf);
 
 	u4_tmp[0] = btcoexist->btc_read_4byte(btcoexist, 0xc50);
-	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE,
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
 		   "\r\n %-35s = 0x%x", "0xc50(dig)",
 		   u4_tmp[0]&0xff);
-	CL_PRINTF(cli_buf);
 
 	u4_tmp[0] = btcoexist->btc_read_4byte(btcoexist, 0xf48);
 	u1_tmp[0] = btcoexist->btc_read_1byte(btcoexist, 0xa5d);
 	u1_tmp[1] = btcoexist->btc_read_1byte(btcoexist, 0xa5c);
-	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE,
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
 		   "\r\n %-35s = 0x%x/ 0x%x", "OFDM-FA/ CCK-FA",
 		   u4_tmp[0], (u1_tmp[0]<<8) + u1_tmp[1]);
-	CL_PRINTF(cli_buf);
 
 	u4_tmp[0] = btcoexist->btc_read_4byte(btcoexist, 0x6c0);
 	u4_tmp[1] = btcoexist->btc_read_4byte(btcoexist, 0x6c4);
 	u4_tmp[2] = btcoexist->btc_read_4byte(btcoexist, 0x6c8);
 	u1_tmp[0] = btcoexist->btc_read_1byte(btcoexist, 0x6cc);
-	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE,
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
 		   "\r\n %-35s = 0x%x/ 0x%x/ 0x%x/ 0x%x",
 		   "0x6c0/0x6c4/0x6c8/0x6cc(coexTable)",
 		   u4_tmp[0], u4_tmp[1], u4_tmp[2], u1_tmp[0]);
-	CL_PRINTF(cli_buf);
 
-	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE,
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
 		   "\r\n %-35s = %d/ %d", "0x770(high-pri rx/tx)",
 		   coex_sta->high_priority_rx, coex_sta->high_priority_tx);
-	CL_PRINTF(cli_buf);
-	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE,
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
 		   "\r\n %-35s = %d/ %d", "0x774(low-pri rx/tx)",
 		   coex_sta->low_priority_rx, coex_sta->low_priority_tx);
-	CL_PRINTF(cli_buf);
 #if (BT_AUTO_REPORT_ONLY_8821A_1ANT == 1)
 	halbtc8821a1ant_monitor_bt_ctr(btcoexist);
 #endif
diff --git a/drivers/net/wireless/rtlwifi/btcoexist/halbtc8821a2ant.c b/drivers/net/wireless/rtlwifi/btcoexist/halbtc8821a2ant.c
index 2322b7d..cf819f0 100644
--- a/drivers/net/wireless/rtlwifi/btcoexist/halbtc8821a2ant.c
+++ b/drivers/net/wireless/rtlwifi/btcoexist/halbtc8821a2ant.c
@@ -3341,7 +3341,7 @@ ex_halbtc8821a2ant_display_coex_info(
 {
 	struct btc_board_info *board_info = &btcoexist->board_info;
 	struct btc_stack_info *stack_info = &btcoexist->stack_info;
-	u8 *cli_buf = btcoexist->cli_buf;
+	struct rtl_priv *rtlpriv = btcoexist->adapter;
 	u8 u1tmp[4], i, bt_info_ext, ps_tdma_case = 0;
 	u32 u4tmp[4];
 	bool roam = false, scan = false, link = false, wifi_under_5g = false;
@@ -3351,41 +3351,35 @@ ex_halbtc8821a2ant_display_coex_info(
 	u8 wifi_dot_11_chnl, wifi_hs_chnl;
 	u32 fw_ver = 0, bt_patch_ver = 0;
 
-	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE,
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
 		   "\r\n ============[BT Coexist info]============");
-	CL_PRINTF(cli_buf);
 
 	if (!board_info->bt_exist) {
-		CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n BT not exists !!!");
-		CL_PRINTF(cli_buf);
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "\r\n BT not exists !!!");
 		return;
 	}
 
-	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE,
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
 		   "\r\n %-35s = %d/ %d ", "Ant PG number/ Ant mechanism:",
 		   board_info->pg_ant_num, board_info->btdm_ant_num);
-	CL_PRINTF(cli_buf);
 
 	if (btcoexist->manual_control) {
-		CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE,
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
 			   "\r\n %-35s", "[Action Manual control]!!");
-		CL_PRINTF(cli_buf);
 	}
 
-	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE,
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
 		   "\r\n %-35s = %s / %d", "BT stack/ hci ext ver",
 		   ((stack_info->profile_notified) ? "Yes" : "No"),
 		   stack_info->hci_version);
-	CL_PRINTF(cli_buf);
 
 	btcoexist->btc_get(btcoexist, BTC_GET_U4_BT_PATCH_VER, &bt_patch_ver);
 	btcoexist->btc_get(btcoexist, BTC_GET_U4_WIFI_FW_VER, &fw_ver);
-	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE,
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
 		   "\r\n %-35s = %d_%d/ 0x%x/ 0x%x(%d)",
 		   "CoexVer/ FwVer/ PatchVer",
 		   glcoex_ver_date_8821a_2ant, glcoex_ver_8821a_2ant,
 		   fw_ver, bt_patch_ver, bt_patch_ver);
-	CL_PRINTF(cli_buf);
 
 	btcoexist->btc_get(btcoexist,
 		BTC_GET_BL_HS_OPERATION, &bt_hs_on);
@@ -3393,33 +3387,29 @@ ex_halbtc8821a2ant_display_coex_info(
 		BTC_GET_U1_WIFI_DOT11_CHNL, &wifi_dot_11_chnl);
 	btcoexist->btc_get(btcoexist,
 		BTC_GET_U1_WIFI_HS_CHNL, &wifi_hs_chnl);
-	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE,
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
 		   "\r\n %-35s = %d / %d(%d)",
 		   "Dot11 channel / HsMode(HsChnl)",
 		   wifi_dot_11_chnl, bt_hs_on, wifi_hs_chnl);
-	CL_PRINTF(cli_buf);
 
-	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE,
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
 		   "\r\n %-35s = %02x %02x %02x ",
 		   "H2C Wifi inform bt chnl Info",
 		   coex_dm->wifi_chnl_info[0], coex_dm->wifi_chnl_info[1],
 		   coex_dm->wifi_chnl_info[2]);
-	CL_PRINTF(cli_buf);
 
 	btcoexist->btc_get(btcoexist, BTC_GET_S4_WIFI_RSSI, &wifi_rssi);
 	btcoexist->btc_get(btcoexist, BTC_GET_S4_HS_RSSI, &bt_hs_rssi);
-	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE,
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
 		   "\r\n %-35s = %ld/ %ld", "Wifi rssi/ HS rssi",
 		   wifi_rssi, bt_hs_rssi);
-	CL_PRINTF(cli_buf);
 
 	btcoexist->btc_get(btcoexist, BTC_GET_BL_WIFI_SCAN, &scan);
 	btcoexist->btc_get(btcoexist, BTC_GET_BL_WIFI_LINK, &link);
 	btcoexist->btc_get(btcoexist, BTC_GET_BL_WIFI_ROAM, &roam);
-	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE,
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
 		   "\r\n %-35s = %d/ %d/ %d ", "Wifi link/ roam/ scan",
 		   link, roam, scan);
-	CL_PRINTF(cli_buf);
 
 	btcoexist->btc_get(btcoexist,
 		BTC_GET_BL_WIFI_UNDER_5G, &wifi_under_5g);
@@ -3429,7 +3419,7 @@ ex_halbtc8821a2ant_display_coex_info(
 		BTC_GET_BL_WIFI_BUSY, &wifi_busy);
 	btcoexist->btc_get(btcoexist,
 		BTC_GET_U4_WIFI_TRAFFIC_DIRECTION, &wifi_traffic_dir);
-	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE,
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
 		   "\r\n %-35s = %s / %s/ %s ", "Wifi status",
 		   (wifi_under_5g ? "5G" : "2.4G"),
 		   ((BTC_WIFI_BW_LEGACY == wifi_bw) ? "Legacy" :
@@ -3437,37 +3427,33 @@ ex_halbtc8821a2ant_display_coex_info(
 		   ((!wifi_busy) ? "idle" :
 		    ((BTC_WIFI_TRAFFIC_TX == wifi_traffic_dir) ?
 		     "uplink" : "downlink")));
-	CL_PRINTF(cli_buf);
 
-	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE,
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
 		   "\r\n %-35s = [%s/ %d/ %d] ", "BT [status/ rssi/ retryCnt]",
 		   ((coex_sta->c2h_bt_inquiry_page) ? ("inquiry/page scan") :
 		    ((BT_8821A_2ANT_BT_STATUS_IDLE == coex_dm->bt_status)
 		     ? "idle" : ((BT_8821A_2ANT_BT_STATUS_CON_IDLE ==
 		     coex_dm->bt_status) ? "connected-idle" : "busy"))),
 		    coex_sta->bt_rssi, coex_sta->bt_retry_cnt);
-	CL_PRINTF(cli_buf);
 
 	if (stack_info->profile_notified) {
-		CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE,
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
 			   "\r\n %-35s = %d / %d / %d / %d", "SCO/HID/PAN/A2DP",
 			   stack_info->sco_exist, stack_info->hid_exist,
 			   stack_info->pan_exist, stack_info->a2dp_exist);
-		CL_PRINTF(cli_buf);
 
 		btcoexist->btc_disp_dbg_msg(btcoexist,
 					    BTC_DBG_DISP_BT_LINK_INFO);
 	}
 
 	bt_info_ext = coex_sta->bt_info_ext;
-	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = %s",
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "\r\n %-35s = %s",
 		   "BT Info A2DP rate",
 		   (bt_info_ext&BIT0) ? "Basic rate" : "EDR rate");
-	CL_PRINTF(cli_buf);
 
 	for (i = 0; i < BT_INFO_SRC_8821A_2ANT_MAX; i++) {
 		if (coex_sta->bt_info_c2h_cnt[i]) {
-			CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE,
+			RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
 				   "\r\n %-35s = %02x %02x %02x %02x %02x %02x %02x(%d)",
 				   glbt_info_src_8821a_2ant[i],
 				   coex_sta->bt_info_c2h[i][0],
@@ -3478,139 +3464,118 @@ ex_halbtc8821a2ant_display_coex_info(
 				   coex_sta->bt_info_c2h[i][5],
 				   coex_sta->bt_info_c2h[i][6],
 				   coex_sta->bt_info_c2h_cnt[i]);
-			CL_PRINTF(cli_buf);
 		}
 	}
 
-	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = %s/%s",
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "\r\n %-35s = %s/%s",
 		   "PS state, IPS/LPS",
 		   ((coex_sta->under_ips ? "IPS ON" : "IPS OFF")),
 		   ((coex_sta->under_lps ? "LPS ON" : "LPS OFF")));
-	CL_PRINTF(cli_buf);
 	btcoexist->btc_disp_dbg_msg(btcoexist, BTC_DBG_DISP_FW_PWR_MODE_CMD);
 
 	/* Sw mechanism*/
-	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s",
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "\r\n %-35s",
 		   "============[Sw mechanism]============");
-	CL_PRINTF(cli_buf);
-	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE,
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
 		   "\r\n %-35s = %d/ %d/ %d/ %d ",
 		   "SM1[ShRf/ LpRA/ LimDig/ btLna]",
 		   coex_dm->cur_rf_rx_lpf_shrink, coex_dm->cur_low_penalty_ra,
 		   coex_dm->limited_dig, coex_dm->cur_bt_lna_constrain);
-	CL_PRINTF(cli_buf);
-	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE,
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
 		   "\r\n %-35s = %d/ %d/ %d(0x%x) ",
 		   "SM2[AgcT/ AdcB/ SwDacSwing(lvl)]",
 		   coex_dm->cur_agc_table_en, coex_dm->cur_adc_back_off,
 		   coex_dm->cur_dac_swing_on, coex_dm->cur_dac_swing_lvl);
-	CL_PRINTF(cli_buf);
 
 	/* Fw mechanism*/
-	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s",
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "\r\n %-35s",
 		   "============[Fw mechanism]============");
-	CL_PRINTF(cli_buf);
 
 	if (!btcoexist->manual_control) {
 		ps_tdma_case = coex_dm->cur_ps_tdma;
-		CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE,
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
 			   "\r\n %-35s = %02x %02x %02x %02x %02x case-%d",
 			   "PS TDMA",
 			   coex_dm->ps_tdma_para[0], coex_dm->ps_tdma_para[1],
 			   coex_dm->ps_tdma_para[2], coex_dm->ps_tdma_para[3],
 			   coex_dm->ps_tdma_para[4], ps_tdma_case);
-		CL_PRINTF(cli_buf);
 
-		CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE,
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
 			   "\r\n %-35s = %d/ %d ", "DecBtPwr/ IgnWlanAct",
 			   coex_dm->cur_dec_bt_pwr,
 			   coex_dm->cur_ignore_wlan_act);
-		CL_PRINTF(cli_buf);
 	}
 
 	/* Hw setting*/
-	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE,
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
 		   "\r\n %-35s", "============[Hw setting]============");
-	CL_PRINTF(cli_buf);
 
-	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE,
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
 		   "\r\n %-35s = 0x%x", "RF-A, 0x1e initVal",
 		   coex_dm->bt_rf0x1e_backup);
-	CL_PRINTF(cli_buf);
 
 	u1tmp[0] = btcoexist->btc_read_1byte(btcoexist, 0x778);
 	u1tmp[1] = btcoexist->btc_read_1byte(btcoexist, 0x6cc);
-	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = 0x%x/ 0x%x ",
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "\r\n %-35s = 0x%x/ 0x%x ",
 		   "0x778 (W_Act)/ 0x6cc (CoTab Sel)",
 		   u1tmp[0], u1tmp[1]);
-	CL_PRINTF(cli_buf);
 
 	u1tmp[0] = btcoexist->btc_read_1byte(btcoexist, 0x8db);
 	u1tmp[1] = btcoexist->btc_read_1byte(btcoexist, 0xc5b);
-	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = 0x%x/ 0x%x",
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "\r\n %-35s = 0x%x/ 0x%x",
 		   "0x8db(ADC)/0xc5b[29:25](DAC)",
 		   ((u1tmp[0]&0x60)>>5), ((u1tmp[1]&0x3e)>>1));
-	CL_PRINTF(cli_buf);
 
 	u4tmp[0] = btcoexist->btc_read_4byte(btcoexist, 0xcb4);
-	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = 0x%x/ 0x%x",
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "\r\n %-35s = 0x%x/ 0x%x",
 		   "0xcb4[7:0](ctrl)/ 0xcb4[29:28](val)",
 		   u4tmp[0]&0xff, ((u4tmp[0]&0x30000000)>>28));
-	CL_PRINTF(cli_buf);
 
 	u1tmp[0] = btcoexist->btc_read_1byte(btcoexist, 0x40);
 	u4tmp[0] = btcoexist->btc_read_4byte(btcoexist, 0x4c);
 	u4tmp[1] = btcoexist->btc_read_4byte(btcoexist, 0x974);
-	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = 0x%x/ 0x%x/ 0x%x",
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "\r\n %-35s = 0x%x/ 0x%x/ 0x%x",
 		   "0x40/ 0x4c[24:23]/ 0x974",
 		   u1tmp[0], ((u4tmp[0]&0x01800000)>>23), u4tmp[1]);
-	CL_PRINTF(cli_buf);
 
 	u4tmp[0] = btcoexist->btc_read_4byte(btcoexist, 0x550);
 	u1tmp[0] = btcoexist->btc_read_1byte(btcoexist, 0x522);
-	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = 0x%x/ 0x%x",
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "\r\n %-35s = 0x%x/ 0x%x",
 		   "0x550(bcn ctrl)/0x522",
 		   u4tmp[0], u1tmp[0]);
-	CL_PRINTF(cli_buf);
 
 	u4tmp[0] = btcoexist->btc_read_4byte(btcoexist, 0xc50);
 	u1tmp[0] = btcoexist->btc_read_1byte(btcoexist, 0xa0a);
-	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = 0x%x/ 0x%x",
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "\r\n %-35s = 0x%x/ 0x%x",
 		   "0xc50(DIG)/0xa0a(CCK-TH)",
 		   u4tmp[0], u1tmp[0]);
-	CL_PRINTF(cli_buf);
 
 	u4tmp[0] = btcoexist->btc_read_4byte(btcoexist, 0xf48);
 	u1tmp[0] = btcoexist->btc_read_1byte(btcoexist, 0xa5b);
 	u1tmp[1] = btcoexist->btc_read_1byte(btcoexist, 0xa5c);
-	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = 0x%x/ 0x%x",
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "\r\n %-35s = 0x%x/ 0x%x",
 		   "OFDM-FA/ CCK-FA",
 		   u4tmp[0], (u1tmp[0]<<8) + u1tmp[1]);
-	CL_PRINTF(cli_buf);
 
 	u4tmp[0] = btcoexist->btc_read_4byte(btcoexist, 0x6c0);
 	u4tmp[1] = btcoexist->btc_read_4byte(btcoexist, 0x6c4);
 	u4tmp[2] = btcoexist->btc_read_4byte(btcoexist, 0x6c8);
-	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = 0x%x/ 0x%x/ 0x%x",
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "\r\n %-35s = 0x%x/ 0x%x/ 0x%x",
 		   "0x6c0/0x6c4/0x6c8",
 		   u4tmp[0], u4tmp[1], u4tmp[2]);
-	CL_PRINTF(cli_buf);
 
-	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = %d/ %d",
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "\r\n %-35s = %d/ %d",
 		   "0x770 (hi-pri Rx/Tx)",
 		   coex_sta->high_priority_rx, coex_sta->high_priority_tx);
-	CL_PRINTF(cli_buf);
-	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = %d/ %d",
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "\r\n %-35s = %d/ %d",
 		   "0x774(low-pri Rx/Tx)",
 		   coex_sta->low_priority_rx, coex_sta->low_priority_tx);
-	CL_PRINTF(cli_buf);
 
 	/* Tx mgnt queue hang or not, 0x41b should = 0xf, ex: 0xd ==>hang*/
 	u1tmp[0] = btcoexist->btc_read_1byte(btcoexist, 0x41b);
-	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = 0x%x",
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "\r\n %-35s = 0x%x",
 		   "0x41b (mgntQ hang chk == 0xf)",
 		   u1tmp[0]);
-	CL_PRINTF(cli_buf);
 
 	btcoexist->btc_disp_dbg_msg(btcoexist, BTC_DBG_DISP_COEX_STATISTICS);
 }
diff --git a/drivers/net/wireless/rtlwifi/btcoexist/halbtcoutsrc.c b/drivers/net/wireless/rtlwifi/btcoexist/halbtcoutsrc.c
index 0620b22..fcf7459 100644
--- a/drivers/net/wireless/rtlwifi/btcoexist/halbtcoutsrc.c
+++ b/drivers/net/wireless/rtlwifi/btcoexist/halbtcoutsrc.c
@@ -32,7 +32,6 @@
 struct btc_coexist gl_bt_coexist;
 
 u32 btc_dbg_type[BTC_MSG_MAX];
-static u8 btc_dbg_buf[100];
 
 /***************************************************
  *		Debug related function
@@ -652,8 +651,6 @@ bool exhalbtc_initlize_variables(struct rtl_priv *adapter)
 	btcoexist->btc_get = halbtc_get;
 	btcoexist->btc_set = halbtc_set;
 
-	btcoexist->cli_buf = &btc_dbg_buf[0];
-
 	btcoexist->bt_info.bt_ctrl_buf_size = false;
 	btcoexist->bt_info.agg_buf_size = 5;
 
diff --git a/drivers/net/wireless/rtlwifi/btcoexist/halbtcoutsrc.h b/drivers/net/wireless/rtlwifi/btcoexist/halbtcoutsrc.h
index bd03b8c..1345545 100644
--- a/drivers/net/wireless/rtlwifi/btcoexist/halbtcoutsrc.h
+++ b/drivers/net/wireless/rtlwifi/btcoexist/halbtcoutsrc.h
@@ -116,9 +116,6 @@ extern u32 btc_dbg_type[];
 #define		WIFI_P2P_GO_CONNECTED			BIT3
 #define		WIFI_P2P_GC_CONNECTED			BIT4
 
-#define	CL_SPRINTF	snprintf
-#define	CL_PRINTF(buf)	printk("%s", buf)
-
 #define	BTC_PRINT(dbgtype, dbgflag, printstr, ...)		\
 	do {							\
 		if (unlikely(btc_dbg_type[dbgtype] & dbgflag)) {\
@@ -483,7 +480,6 @@ struct btc_coexist {
 	bool initilized;
 	bool stop_coex_dm;
 	bool manual_control;
-	u8 *cli_buf;
 	struct btc_statistics statistics;
 	u8 pwr_mode_val[10];
 
-- 
1.8.4.5
