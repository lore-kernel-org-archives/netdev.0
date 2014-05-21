From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 2/4] staging: r8192ee: Add code for Bluetooth coexistence
Date: Wed, 21 May 2014 16:25:34 -0500
Message-ID: <1400707536-3338-3-git-send-email-Larry.Finger@lwfinger.net>
References: <1400707536-3338-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: netdev@vger.kernel.org, devel@driverdev.osuosl.org,
	Larry Finger <Larry.Finger@lwfinger.net>, zhangfp1@lenovo.com,
	troy_tan@realsil.com.cn
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f42.google.com ([209.85.219.42]:35270 "EHLO
	mail-oa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753021AbaEUV0E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 May 2014 17:26:04 -0400
Received: by mail-oa0-f42.google.com with SMTP id j17so2955550oag.15
        for <netdev@vger.kernel.org>; Wed, 21 May 2014 14:26:02 -0700 (PDT)
In-Reply-To: <1400707536-3338-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the wireless tree, this code forms a separate mini driver. As the changes
needed for the later drivers has not yet been merged, a separate version
is needed here.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 .../staging/rtl8192ee/btcoexist/halbt_precomp.h    |   50 +
 .../staging/rtl8192ee/btcoexist/halbtc8192e2ant.c  | 4110 ++++++++++++++++++++
 .../staging/rtl8192ee/btcoexist/halbtc8192e2ant.h  |  161 +
 .../staging/rtl8192ee/btcoexist/halbtc8723b1ant.c  | 3146 +++++++++++++++
 .../staging/rtl8192ee/btcoexist/halbtc8723b1ant.h  |  160 +
 .../staging/rtl8192ee/btcoexist/halbtc8723b2ant.c  | 3929 +++++++++++++++++++
 .../staging/rtl8192ee/btcoexist/halbtc8723b2ant.h  |  145 +
 .../staging/rtl8192ee/btcoexist/halbtc8821a1ant.c  | 2780 +++++++++++++
 .../staging/rtl8192ee/btcoexist/halbtc8821a1ant.h  |  158 +
 .../staging/rtl8192ee/btcoexist/halbtc8821a2ant.c  | 3438 ++++++++++++++++
 .../staging/rtl8192ee/btcoexist/halbtc8821a2ant.h  |  179 +
 drivers/staging/rtl8192ee/btcoexist/halbtcoutsrc.c | 1307 +++++++
 drivers/staging/rtl8192ee/btcoexist/halbtcoutsrc.h |  537 +++
 drivers/staging/rtl8192ee/btcoexist/rtl_btc.c      |  194 +
 drivers/staging/rtl8192ee/btcoexist/rtl_btc.h      |   62 +
 15 files changed, 20356 insertions(+)
 create mode 100644 drivers/staging/rtl8192ee/btcoexist/halbt_precomp.h
 create mode 100644 drivers/staging/rtl8192ee/btcoexist/halbtc8192e2ant.c
 create mode 100644 drivers/staging/rtl8192ee/btcoexist/halbtc8192e2ant.h
 create mode 100644 drivers/staging/rtl8192ee/btcoexist/halbtc8723b1ant.c
 create mode 100644 drivers/staging/rtl8192ee/btcoexist/halbtc8723b1ant.h
 create mode 100644 drivers/staging/rtl8192ee/btcoexist/halbtc8723b2ant.c
 create mode 100644 drivers/staging/rtl8192ee/btcoexist/halbtc8723b2ant.h
 create mode 100644 drivers/staging/rtl8192ee/btcoexist/halbtc8821a1ant.c
 create mode 100644 drivers/staging/rtl8192ee/btcoexist/halbtc8821a1ant.h
 create mode 100644 drivers/staging/rtl8192ee/btcoexist/halbtc8821a2ant.c
 create mode 100644 drivers/staging/rtl8192ee/btcoexist/halbtc8821a2ant.h
 create mode 100644 drivers/staging/rtl8192ee/btcoexist/halbtcoutsrc.c
 create mode 100644 drivers/staging/rtl8192ee/btcoexist/halbtcoutsrc.h
 create mode 100644 drivers/staging/rtl8192ee/btcoexist/rtl_btc.c
 create mode 100644 drivers/staging/rtl8192ee/btcoexist/rtl_btc.h

diff --git a/drivers/staging/rtl8192ee/btcoexist/halbt_precomp.h b/drivers/staging/rtl8192ee/btcoexist/halbt_precomp.h
new file mode 100644
index 0000000..56e6c46
--- /dev/null
+++ b/drivers/staging/rtl8192ee/btcoexist/halbt_precomp.h
@@ -0,0 +1,50 @@
+/******************************************************************************
+ *
+ * Copyright(c) 2007 - 2011 Realtek Corporation. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for
+ * more details.
+ *
+ *
+ ******************************************************************************/
+#ifndef	__HALBT_PRECOMP_H__
+#define __HALBT_PRECOMP_H__
+/*************************************************************
+ * include files
+ *************************************************************/
+#include "../wifi.h"
+#include "../efuse.h"
+#include "../base.h"
+#include "../regd.h"
+#include "../cam.h"
+#include "../ps.h"
+#include "../pci.h"
+
+#include "halbtcoutsrc.h"
+
+
+#include "halbtc8192e2ant.h"
+#include "halbtc8723b1ant.h"
+#include "halbtc8723b2ant.h"
+#include "halbtc8821a2ant.h"
+#include "halbtc8821a1ant.h"
+
+#define	MASKBYTE0			0xff
+#define	MASKBYTE1			0xff00
+#define	MASKBYTE2			0xff0000
+#define	MASKBYTE3			0xff000000
+#define	MASKHWORD			0xffff0000
+#define	MASKLWORD			0x0000ffff
+#define	MASKDWORD			0xffffffff
+#define	MASK12BITS			0xfff
+#define	MASKH4BITS			0xf0000000
+#define MASKOFDM_D			0xffc00000
+#define	MASKCCK				0x3f3f3f3f
+
+#endif	/* __HALBT_PRECOMP_H__ */
diff --git a/drivers/staging/rtl8192ee/btcoexist/halbtc8192e2ant.c b/drivers/staging/rtl8192ee/btcoexist/halbtc8192e2ant.c
new file mode 100644
index 0000000..ab2cc2f
--- /dev/null
+++ b/drivers/staging/rtl8192ee/btcoexist/halbtc8192e2ant.c
@@ -0,0 +1,4110 @@
+/**************************************************************
+ * Description:
+ *
+ * This file is for RTL8192E Co-exist mechanism
+ *
+ * History
+ * 2012/11/15 Cosa first check in.
+ *
+ **************************************************************/
+
+/**************************************************************
+ *   include files
+ **************************************************************/
+#include "halbt_precomp.h"
+/**************************************************************
+ *   Global variables, these are static variables
+ **************************************************************/
+static struct coex_dm_8192e_2ant glcoex_dm_8192e_2ant;
+static struct coex_dm_8192e_2ant *coex_dm = &glcoex_dm_8192e_2ant;
+static struct coex_sta_8192e_2ant glcoex_sta_8192e_2ant;
+static struct coex_sta_8192e_2ant *coex_sta = &glcoex_sta_8192e_2ant;
+
+static const char *const glbt_infosrc8192e2ant[] = {
+	"BT Info[wifi fw]",
+	"BT Info[bt rsp]",
+	"BT Info[bt auto report]",
+};
+
+static u32 glcoex_ver_date_8192e_2ant = 20130902;
+static u32 glcoex_ver_8192e_2ant = 0x34;
+
+/**************************************************************
+ *   local function proto type if needed
+ **************************************************************/
+/**************************************************************
+ *   local function start with halbtc8192e2ant_
+ **************************************************************/
+static u8 halbtc8192e2ant_btrssi_state(u8 level_num, u8 rssi_thresh,
+				       u8 rssi_thresh1)
+{
+	int btrssi = 0;
+	u8 btrssi_state = coex_sta->pre_bt_rssi_state;
+
+	btrssi = coex_sta->bt_rssi;
+
+	if (level_num == 2) {
+		if ((coex_sta->pre_bt_rssi_state == BTC_RSSI_STATE_LOW) ||
+		    (coex_sta->pre_bt_rssi_state == BTC_RSSI_STATE_STAY_LOW)) {
+			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_RSSI_STATE,
+				  "BT Rssi pre state = LOW\n");
+			if (btrssi >= (rssi_thresh +
+				       BTC_RSSI_COEX_THRESH_TOL_8192E_2ANT)) {
+				btrssi_state = BTC_RSSI_STATE_HIGH;
+				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_RSSI_STATE,
+					  "BT Rssi state switch to High\n");
+			} else {
+				btrssi_state = BTC_RSSI_STATE_STAY_LOW;
+				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_RSSI_STATE,
+					  "BT Rssi state stay at Low\n");
+			}
+		} else {
+			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_RSSI_STATE,
+				  "BT Rssi pre state = HIGH\n");
+			if (btrssi < rssi_thresh) {
+				btrssi_state = BTC_RSSI_STATE_LOW;
+				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_RSSI_STATE,
+					  "BT Rssi state switch to Low\n");
+			} else {
+				btrssi_state = BTC_RSSI_STATE_STAY_HIGH;
+				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_RSSI_STATE,
+					  "BT Rssi state stay at High\n");
+			}
+		}
+	} else if (level_num == 3) {
+		if (rssi_thresh > rssi_thresh1) {
+			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_RSSI_STATE,
+				  "BT Rssi thresh error!!\n");
+			return coex_sta->pre_bt_rssi_state;
+		}
+
+		if ((coex_sta->pre_bt_rssi_state == BTC_RSSI_STATE_LOW) ||
+		    (coex_sta->pre_bt_rssi_state == BTC_RSSI_STATE_STAY_LOW)) {
+			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_RSSI_STATE,
+				  "BT Rssi pre state = LOW\n");
+			if (btrssi >= (rssi_thresh +
+				      BTC_RSSI_COEX_THRESH_TOL_8192E_2ANT)) {
+				btrssi_state = BTC_RSSI_STATE_MEDIUM;
+				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_RSSI_STATE,
+					  "BT Rssi state switch to Medium\n");
+			} else {
+				btrssi_state = BTC_RSSI_STATE_STAY_LOW;
+				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_RSSI_STATE,
+					  "BT Rssi state stay at Low\n");
+			}
+		} else if ((coex_sta->pre_bt_rssi_state ==
+			    BTC_RSSI_STATE_MEDIUM) ||
+			   (coex_sta->pre_bt_rssi_state ==
+			    BTC_RSSI_STATE_STAY_MEDIUM)) {
+			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_RSSI_STATE,
+				  "[BTCoex], BT Rssi pre state = MEDIUM\n");
+			if (btrssi >= (rssi_thresh1 +
+				       BTC_RSSI_COEX_THRESH_TOL_8192E_2ANT)) {
+				btrssi_state = BTC_RSSI_STATE_HIGH;
+				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_RSSI_STATE,
+					  "BT Rssi state switch to High\n");
+			} else if (btrssi < rssi_thresh) {
+				btrssi_state = BTC_RSSI_STATE_LOW;
+				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_RSSI_STATE,
+					  "BT Rssi state switch to Low\n");
+			} else {
+				btrssi_state = BTC_RSSI_STATE_STAY_MEDIUM;
+				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_RSSI_STATE,
+					  "BT Rssi state stay at Medium\n");
+			}
+		} else {
+			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_RSSI_STATE,
+				  "BT Rssi pre state = HIGH\n");
+			if (btrssi < rssi_thresh1) {
+				btrssi_state = BTC_RSSI_STATE_MEDIUM;
+				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_RSSI_STATE,
+					  "BT Rssi state switch to Medium\n");
+			} else {
+				btrssi_state = BTC_RSSI_STATE_STAY_HIGH;
+				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_RSSI_STATE,
+					  "BT Rssi state stay at High\n");
+			}
+		}
+	}
+
+	coex_sta->pre_bt_rssi_state = btrssi_state;
+
+	return btrssi_state;
+}
+
+static u8 halbtc8192e2ant_wifirssi_state(struct btc_coexist *btcoexist,
+					 u8 index, u8 level_num, u8 rssi_thresh,
+					 u8 rssi_thresh1)
+{
+	int wifirssi = 0;
+	u8 wifirssi_state = coex_sta->pre_wifi_rssi_state[index];
+
+	btcoexist->btc_get(btcoexist, BTC_GET_S4_WIFI_RSSI, &wifirssi);
+
+	if (level_num == 2) {
+		if ((coex_sta->pre_wifi_rssi_state[index] ==
+		     BTC_RSSI_STATE_LOW) ||
+		    (coex_sta->pre_wifi_rssi_state[index] ==
+		     BTC_RSSI_STATE_STAY_LOW)) {
+			if (wifirssi >= (rssi_thresh +
+					 BTC_RSSI_COEX_THRESH_TOL_8192E_2ANT)) {
+				wifirssi_state = BTC_RSSI_STATE_HIGH;
+				BTC_PRINT(BTC_MSG_ALGORITHM,
+					  ALGO_WIFI_RSSI_STATE,
+					  "wifi RSSI state switch to High\n");
+			} else {
+				wifirssi_state = BTC_RSSI_STATE_STAY_LOW;
+				BTC_PRINT(BTC_MSG_ALGORITHM,
+					  ALGO_WIFI_RSSI_STATE,
+					  "wifi RSSI state stay at Low\n");
+			}
+		} else {
+			if (wifirssi < rssi_thresh) {
+				wifirssi_state = BTC_RSSI_STATE_LOW;
+				BTC_PRINT(BTC_MSG_ALGORITHM,
+					  ALGO_WIFI_RSSI_STATE,
+					  "wifi RSSI state switch to Low\n");
+			} else {
+				wifirssi_state = BTC_RSSI_STATE_STAY_HIGH;
+				BTC_PRINT(BTC_MSG_ALGORITHM,
+					  ALGO_WIFI_RSSI_STATE,
+					  "wifi RSSI state stay at High\n");
+			}
+		}
+	} else if (level_num == 3) {
+		if (rssi_thresh > rssi_thresh1) {
+			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_WIFI_RSSI_STATE,
+				  "wifi RSSI thresh error!!\n");
+			return coex_sta->pre_wifi_rssi_state[index];
+		}
+
+		if ((coex_sta->pre_wifi_rssi_state[index] ==
+		     BTC_RSSI_STATE_LOW) ||
+		    (coex_sta->pre_wifi_rssi_state[index] ==
+		     BTC_RSSI_STATE_STAY_LOW)) {
+			if (wifirssi >= (rssi_thresh +
+					 BTC_RSSI_COEX_THRESH_TOL_8192E_2ANT)) {
+				wifirssi_state = BTC_RSSI_STATE_MEDIUM;
+				BTC_PRINT(BTC_MSG_ALGORITHM,
+					  ALGO_WIFI_RSSI_STATE,
+					  "wifi RSSI state switch to Medium\n");
+			} else {
+				wifirssi_state = BTC_RSSI_STATE_STAY_LOW;
+				BTC_PRINT(BTC_MSG_ALGORITHM,
+					  ALGO_WIFI_RSSI_STATE,
+					  "wifi RSSI state stay at Low\n");
+			}
+		} else if ((coex_sta->pre_wifi_rssi_state[index] ==
+			    BTC_RSSI_STATE_MEDIUM) ||
+			   (coex_sta->pre_wifi_rssi_state[index] ==
+			    BTC_RSSI_STATE_STAY_MEDIUM)) {
+			if (wifirssi >= (rssi_thresh1 +
+					 BTC_RSSI_COEX_THRESH_TOL_8192E_2ANT)) {
+				wifirssi_state = BTC_RSSI_STATE_HIGH;
+				BTC_PRINT(BTC_MSG_ALGORITHM,
+					  ALGO_WIFI_RSSI_STATE,
+					  "wifi RSSI state switch to High\n");
+			} else if (wifirssi < rssi_thresh) {
+				wifirssi_state = BTC_RSSI_STATE_LOW;
+				BTC_PRINT(BTC_MSG_ALGORITHM,
+					  ALGO_WIFI_RSSI_STATE,
+					  "wifi RSSI state switch to Low\n");
+			} else {
+				wifirssi_state = BTC_RSSI_STATE_STAY_MEDIUM;
+				BTC_PRINT(BTC_MSG_ALGORITHM,
+					  ALGO_WIFI_RSSI_STATE,
+					  "wifi RSSI state stay at Medium\n");
+			}
+		} else {
+			if (wifirssi < rssi_thresh1) {
+				wifirssi_state = BTC_RSSI_STATE_MEDIUM;
+				BTC_PRINT(BTC_MSG_ALGORITHM,
+					  ALGO_WIFI_RSSI_STATE,
+					  "wifi RSSI state switch to Medium\n");
+			} else {
+				wifirssi_state = BTC_RSSI_STATE_STAY_HIGH;
+				BTC_PRINT(BTC_MSG_ALGORITHM,
+					  ALGO_WIFI_RSSI_STATE,
+					  "wifi RSSI state stay at High\n");
+			}
+		}
+	}
+
+	coex_sta->pre_wifi_rssi_state[index] = wifirssi_state;
+
+	return wifirssi_state;
+}
+
+static void halbtc_monitor_bt_enable_disable(struct btc_coexist *btcoexist)
+{
+	static bool pre_bt_disabled;
+	static u32 bt_disable_cnt;
+	bool bt_active = true, bt_disabled = false;
+
+	/* This function check if bt is disabled */
+
+	if (coex_sta->high_priority_tx == 0 &&
+	    coex_sta->high_priority_rx == 0 &&
+	    coex_sta->low_priority_tx == 0 &&
+	    coex_sta->low_priority_rx == 0)
+		bt_active = false;
+
+	if (coex_sta->high_priority_tx == 0xffff &&
+	    coex_sta->high_priority_rx == 0xffff &&
+	    coex_sta->low_priority_tx == 0xffff &&
+	    coex_sta->low_priority_rx == 0xffff)
+		bt_active = false;
+
+	if (bt_active) {
+		bt_disable_cnt = 0;
+		bt_disabled = false;
+		btcoexist->btc_set(btcoexist, BTC_SET_BL_BT_DISABLE,
+				   &bt_disabled);
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_MONITOR,
+			  "[BTCoex], BT is enabled !!\n");
+	} else {
+		bt_disable_cnt++;
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_MONITOR,
+			  "[BTCoex], bt all counters = 0, %d times!!\n",
+			  bt_disable_cnt);
+		if (bt_disable_cnt >= 2) {
+			bt_disabled = true;
+			btcoexist->btc_set(btcoexist, BTC_SET_BL_BT_DISABLE,
+					   &bt_disabled);
+			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_MONITOR,
+				  "[BTCoex], BT is disabled !!\n");
+		}
+	}
+	if (pre_bt_disabled != bt_disabled) {
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_MONITOR,
+			  "[BTCoex], BT is from %s to %s!!\n",
+			  (pre_bt_disabled ? "disabled" : "enabled"),
+			  (bt_disabled ? "disabled" : "enabled"));
+		pre_bt_disabled = bt_disabled;
+	}
+}
+
+static u32 halbtc8192e2ant_decidera_mask(struct btc_coexist *btcoexist,
+					 u8 sstype, u32 ra_masktype)
+{
+	u32 disra_mask = 0x0;
+
+	switch (ra_masktype) {
+	case 0: /* normal mode */
+		if (sstype == 2)
+			disra_mask = 0x0;	/* enable 2ss */
+		else
+			disra_mask = 0xfff00000;/* disable 2ss */
+		break;
+	case 1: /* disable cck 1/2 */
+		if (sstype == 2)
+			disra_mask = 0x00000003;/* enable 2ss */
+		else
+			disra_mask = 0xfff00003;/* disable 2ss */
+		break;
+	case 2: /* disable cck 1/2/5.5, ofdm 6/9/12/18/24, mcs 0/1/2/3/4 */
+		if (sstype == 2)
+			disra_mask = 0x0001f1f7;/* enable 2ss */
+		else
+			disra_mask = 0xfff1f1f7;/* disable 2ss */
+		break;
+	default:
+		break;
+	}
+
+	return disra_mask;
+}
+
+static void halbtc8192e2ant_updatera_mask(struct btc_coexist *btcoexist,
+					  bool force_exec, u32 dis_ratemask)
+{
+	coex_dm->curra_mask = dis_ratemask;
+
+	if (force_exec || (coex_dm->prera_mask != coex_dm->curra_mask))
+		btcoexist->btc_set(btcoexist, BTC_SET_ACT_UPDATE_ra_mask,
+				   &coex_dm->curra_mask);
+	coex_dm->prera_mask = coex_dm->curra_mask;
+}
+
+static void autorate_fallback_retry(struct btc_coexist *btcoexist,
+				    bool force_exec, u8 type)
+{
+	bool wifi_under_bmode = false;
+
+	coex_dm->cur_arfrtype = type;
+
+	if (force_exec || (coex_dm->pre_arfrtype != coex_dm->cur_arfrtype)) {
+		switch (coex_dm->cur_arfrtype) {
+		case 0:	/* normal mode */
+			btcoexist->btc_write_4byte(btcoexist, 0x430,
+						   coex_dm->backup_arfr_cnt1);
+			btcoexist->btc_write_4byte(btcoexist, 0x434,
+						   coex_dm->backup_arfr_cnt2);
+			break;
+		case 1:
+			btcoexist->btc_get(btcoexist,
+					   BTC_GET_BL_WIFI_UNDER_B_MODE,
+					   &wifi_under_bmode);
+			if (wifi_under_bmode) {
+				btcoexist->btc_write_4byte(btcoexist, 0x430,
+							   0x0);
+				btcoexist->btc_write_4byte(btcoexist, 0x434,
+							   0x01010101);
+			} else {
+				btcoexist->btc_write_4byte(btcoexist, 0x430,
+							   0x0);
+				btcoexist->btc_write_4byte(btcoexist, 0x434,
+							   0x04030201);
+			}
+			break;
+		default:
+			break;
+		}
+	}
+
+	coex_dm->pre_arfrtype = coex_dm->cur_arfrtype;
+}
+
+static void halbtc8192e2ant_retrylimit(struct btc_coexist *btcoexist,
+				       bool force_exec, u8 type)
+{
+	coex_dm->cur_retrylimit_type = type;
+
+	if (force_exec || (coex_dm->pre_retrylimit_type !=
+			   coex_dm->cur_retrylimit_type)) {
+		switch (coex_dm->cur_retrylimit_type) {
+		case 0:	/* normal mode */
+			btcoexist->btc_write_2byte(btcoexist, 0x42a,
+					    coex_dm->backup_retrylimit);
+			break;
+		case 1:	/* retry limit = 8 */
+			btcoexist->btc_write_2byte(btcoexist, 0x42a,
+						   0x0808);
+			break;
+		default:
+			break;
+		}
+	}
+
+	coex_dm->pre_retrylimit_type = coex_dm->cur_retrylimit_type;
+}
+
+static void halbtc8192e2ant_ampdu_maxtime(struct btc_coexist *btcoexist,
+					  bool force_exec, u8 type)
+{
+	coex_dm->cur_ampdutime_type = type;
+
+	if (force_exec || (coex_dm->pre_ampdutime_type !=
+			   coex_dm->cur_ampdutime_type)) {
+		switch (coex_dm->cur_ampdutime_type) {
+		case 0:	/* normal mode */
+			btcoexist->btc_write_1byte(btcoexist, 0x456,
+						coex_dm->backup_ampdu_maxtime);
+			break;
+		case 1:	/* AMPDU timw = 0x38 * 32us */
+			btcoexist->btc_write_1byte(btcoexist, 0x456, 0x38);
+			break;
+		default:
+			break;
+		}
+	}
+
+	coex_dm->pre_ampdutime_type = coex_dm->cur_ampdutime_type;
+}
+
+static void halbtc8192e2ant_limited_tx(struct btc_coexist *btcoexist,
+				       bool force_exec, u8 ra_masktype,
+				       u8 arfr_type, u8 retrylimit_type,
+				       u8 ampdutime_type)
+{
+	u32 disra_mask = 0x0;
+
+	coex_dm->curra_masktype = ra_masktype;
+	disra_mask = halbtc8192e2ant_decidera_mask(btcoexist,
+						   coex_dm->cur_sstype,
+						   ra_masktype);
+	halbtc8192e2ant_updatera_mask(btcoexist, force_exec, disra_mask);
+
+	autorate_fallback_retry(btcoexist, force_exec, arfr_type);
+	halbtc8192e2ant_retrylimit(btcoexist, force_exec, retrylimit_type);
+	halbtc8192e2ant_ampdu_maxtime(btcoexist, force_exec, ampdutime_type);
+}
+
+static void halbtc8192e2ant_limited_rx(struct btc_coexist *btcoexist,
+				       bool force_exec, bool rej_ap_agg_pkt,
+				       bool b_bt_ctrl_agg_buf_size,
+				       u8 agg_buf_size)
+{
+	bool reject_rx_agg = rej_ap_agg_pkt;
+	bool bt_ctrl_rx_agg_size = b_bt_ctrl_agg_buf_size;
+	u8 rx_agg_size = agg_buf_size;
+
+	/*********************************************
+	 *	Rx Aggregation related setting
+	 *********************************************/
+	btcoexist->btc_set(btcoexist, BTC_SET_BL_TO_REJ_AP_AGG_PKT,
+			   &reject_rx_agg);
+	/* decide BT control aggregation buf size or not */
+	btcoexist->btc_set(btcoexist, BTC_SET_BL_BT_CTRL_AGG_SIZE,
+			   &bt_ctrl_rx_agg_size);
+	/* aggregation buf size, only work
+	 * when BT control Rx aggregation size. */
+	btcoexist->btc_set(btcoexist, BTC_SET_U1_AGG_BUF_SIZE, &rx_agg_size);
+	/* real update aggregation setting */
+	btcoexist->btc_set(btcoexist, BTC_SET_ACT_AGGREGATE_CTRL, NULL);
+}
+
+static void halbtc8192e2ant_monitor_bt_ctr(struct btc_coexist *btcoexist)
+{
+	u32 reg_hp_txrx, reg_lp_txrx, u32tmp;
+	u32 reg_hp_tx = 0, reg_hp_rx = 0, reg_lp_tx = 0, reg_lp_rx = 0;
+
+	reg_hp_txrx = 0x770;
+	reg_lp_txrx = 0x774;
+
+	u32tmp = btcoexist->btc_read_4byte(btcoexist, reg_hp_txrx);
+	reg_hp_tx = u32tmp & MASKLWORD;
+	reg_hp_rx = (u32tmp & MASKHWORD)>>16;
+
+	u32tmp = btcoexist->btc_read_4byte(btcoexist, reg_lp_txrx);
+	reg_lp_tx = u32tmp & MASKLWORD;
+	reg_lp_rx = (u32tmp & MASKHWORD)>>16;
+
+	coex_sta->high_priority_tx = reg_hp_tx;
+	coex_sta->high_priority_rx = reg_hp_rx;
+	coex_sta->low_priority_tx = reg_lp_tx;
+	coex_sta->low_priority_rx = reg_lp_rx;
+
+	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_MONITOR,
+		  "[BTCoex] High Priority Tx/Rx (reg 0x%x) = 0x%x(%d)/0x%x(%d)\n",
+		  reg_hp_txrx, reg_hp_tx, reg_hp_tx, reg_hp_rx, reg_hp_rx);
+	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_MONITOR,
+		  "[BTCoex] Low Priority Tx/Rx (reg 0x%x) = 0x%x(%d)/0x%x(%d)\n",
+		  reg_lp_txrx, reg_lp_tx, reg_lp_tx, reg_lp_rx, reg_lp_rx);
+
+	/* reset counter */
+	btcoexist->btc_write_1byte(btcoexist, 0x76e, 0xc);
+}
+
+static void halbtc8192e2ant_querybt_info(struct btc_coexist *btcoexist)
+{
+	u8 h2c_parameter[1] = {0};
+
+	coex_sta->c2h_bt_info_req_sent = true;
+
+	h2c_parameter[0] |= BIT(0);	/* trigger */
+
+	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_EXEC,
+		  "[BTCoex], Query Bt Info, FW write 0x61 = 0x%x\n",
+		  h2c_parameter[0]);
+
+	btcoexist->btc_fill_h2c(btcoexist, 0x61, 1, h2c_parameter);
+}
+
+static void halbtc8192e2ant_update_btlink_info(struct btc_coexist *btcoexist)
+{
+	struct btc_bt_link_info *bt_link_info = &btcoexist->bt_link_info;
+	bool bt_hson = false;
+
+	btcoexist->btc_get(btcoexist, BTC_GET_BL_HS_OPERATION, &bt_hson);
+
+	bt_link_info->bt_link_exist = coex_sta->bt_link_exist;
+	bt_link_info->sco_exist = coex_sta->sco_exist;
+	bt_link_info->a2dp_exist = coex_sta->a2dp_exist;
+	bt_link_info->pan_exist = coex_sta->pan_exist;
+	bt_link_info->hid_exist = coex_sta->hid_exist;
+
+	/* work around for HS mode. */
+	if (bt_hson) {
+		bt_link_info->pan_exist = true;
+		bt_link_info->bt_link_exist = true;
+	}
+
+	/* check if Sco only */
+	if (bt_link_info->sco_exist &&
+	    !bt_link_info->a2dp_exist &&
+	    !bt_link_info->pan_exist &&
+	    !bt_link_info->hid_exist)
+		bt_link_info->sco_only = true;
+	else
+		bt_link_info->sco_only = false;
+
+	/* check if A2dp only */
+	if (!bt_link_info->sco_exist &&
+	    bt_link_info->a2dp_exist &&
+	    !bt_link_info->pan_exist &&
+	    !bt_link_info->hid_exist)
+		bt_link_info->a2dp_only = true;
+	else
+		bt_link_info->a2dp_only = false;
+
+	/* check if Pan only */
+	if (!bt_link_info->sco_exist &&
+	    !bt_link_info->a2dp_exist &&
+	    bt_link_info->pan_exist &&
+	    !bt_link_info->hid_exist)
+		bt_link_info->pan_only = true;
+	else
+		bt_link_info->pan_only = false;
+
+	/* check if Hid only */
+	if (!bt_link_info->sco_exist &&
+	    !bt_link_info->a2dp_exist &&
+	    !bt_link_info->pan_exist &&
+	    bt_link_info->hid_exist)
+		bt_link_info->hid_only = true;
+	else
+		bt_link_info->hid_only = false;
+}
+
+static u8 halbtc8192e2ant_action_algorithm(struct btc_coexist *btcoexist)
+{
+	struct btc_bt_link_info *bt_link_info = &btcoexist->bt_link_info;
+	struct btc_stack_info *stack_info = &btcoexist->stack_info;
+	bool bt_hson = false;
+	u8 algorithm = BT_8192E_2ANT_COEX_ALGO_UNDEFINED;
+	u8 num_diffprofile = 0;
+
+	btcoexist->btc_get(btcoexist, BTC_GET_BL_HS_OPERATION, &bt_hson);
+
+	if (!bt_link_info->bt_link_exist) {
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+			  "No BT link exists!!!\n");
+		return algorithm;
+	}
+
+	if (bt_link_info->sco_exist)
+		num_diffprofile++;
+	if (bt_link_info->hid_exist)
+		num_diffprofile++;
+	if (bt_link_info->pan_exist)
+		num_diffprofile++;
+	if (bt_link_info->a2dp_exist)
+		num_diffprofile++;
+
+	if (num_diffprofile == 1) {
+		if (bt_link_info->sco_exist) {
+			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+				  "SCO only\n");
+			algorithm = BT_8192E_2ANT_COEX_ALGO_SCO;
+		} else {
+			if (bt_link_info->hid_exist) {
+				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+					  "HID only\n");
+				algorithm = BT_8192E_2ANT_COEX_ALGO_HID;
+			} else if (bt_link_info->a2dp_exist) {
+				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+					  "A2DP only\n");
+				algorithm = BT_8192E_2ANT_COEX_ALGO_A2DP;
+			} else if (bt_link_info->pan_exist) {
+				if (bt_hson) {
+					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+						  "PAN(HS) only\n");
+					algorithm =
+						BT_8192E_2ANT_COEX_ALGO_PANHS;
+				} else {
+					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+						  "PAN(EDR) only\n");
+					algorithm =
+						BT_8192E_2ANT_COEX_ALGO_PANEDR;
+				}
+			}
+		}
+	} else if (num_diffprofile == 2) {
+		if (bt_link_info->sco_exist) {
+			if (bt_link_info->hid_exist) {
+				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+					  "SCO + HID\n");
+				algorithm = BT_8192E_2ANT_COEX_ALGO_SCO;
+			} else if (bt_link_info->a2dp_exist) {
+				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+					  "SCO + A2DP ==> SCO\n");
+				algorithm = BT_8192E_2ANT_COEX_ALGO_PANEDR_HID;
+			} else if (bt_link_info->pan_exist) {
+				if (bt_hson) {
+					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+						  "SCO + PAN(HS)\n");
+					algorithm = BT_8192E_2ANT_COEX_ALGO_SCO;
+				} else {
+					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+						  "SCO + PAN(EDR)\n");
+					algorithm =
+						BT_8192E_2ANT_COEX_ALGO_SCO_PAN;
+				}
+			}
+		} else {
+			if (bt_link_info->hid_exist &&
+			    bt_link_info->a2dp_exist) {
+				if (stack_info->num_of_hid >= 2) {
+					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+						  "HID*2 + A2DP\n");
+					algorithm =
+					BT_8192E_2ANT_COEX_ALGO_HID_A2DP_PANEDR;
+				} else {
+					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+						  "HID + A2DP\n");
+					algorithm =
+					    BT_8192E_2ANT_COEX_ALGO_HID_A2DP;
+				}
+			} else if (bt_link_info->hid_exist &&
+				   bt_link_info->pan_exist) {
+				if (bt_hson) {
+					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+						  "HID + PAN(HS)\n");
+					algorithm = BT_8192E_2ANT_COEX_ALGO_HID;
+				} else {
+					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+						  "HID + PAN(EDR)\n");
+					algorithm =
+					    BT_8192E_2ANT_COEX_ALGO_PANEDR_HID;
+				}
+			} else if (bt_link_info->pan_exist &&
+				   bt_link_info->a2dp_exist) {
+				if (bt_hson) {
+					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+						  "A2DP + PAN(HS)\n");
+					algorithm =
+					    BT_8192E_2ANT_COEX_ALGO_A2DP_PANHS;
+				} else {
+					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+						  "A2DP + PAN(EDR)\n");
+					algorithm =
+					    BT_8192E_2ANT_COEX_ALGO_PANEDR_A2DP;
+				}
+			}
+		}
+	} else if (num_diffprofile == 3) {
+		if (bt_link_info->sco_exist) {
+			if (bt_link_info->hid_exist &&
+			    bt_link_info->a2dp_exist) {
+				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+					  "SCO + HID + A2DP ==> HID\n");
+				algorithm = BT_8192E_2ANT_COEX_ALGO_PANEDR_HID;
+			} else if (bt_link_info->hid_exist &&
+				   bt_link_info->pan_exist) {
+				if (bt_hson) {
+					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+						  "SCO + HID + PAN(HS)\n");
+					algorithm = BT_8192E_2ANT_COEX_ALGO_SCO;
+				} else {
+					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+						  "SCO + HID + PAN(EDR)\n");
+					algorithm =
+						BT_8192E_2ANT_COEX_ALGO_SCO_PAN;
+				}
+			} else if (bt_link_info->pan_exist &&
+				   bt_link_info->a2dp_exist) {
+				if (bt_hson) {
+					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+						  "SCO + A2DP + PAN(HS)\n");
+					algorithm = BT_8192E_2ANT_COEX_ALGO_SCO;
+				} else {
+					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+						  "SCO + A2DP + PAN(EDR)\n");
+					algorithm =
+					    BT_8192E_2ANT_COEX_ALGO_PANEDR_HID;
+				}
+			}
+		} else {
+			if (bt_link_info->hid_exist &&
+			    bt_link_info->pan_exist &&
+			    bt_link_info->a2dp_exist) {
+				if (bt_hson) {
+					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+						  "HID + A2DP + PAN(HS)\n");
+					algorithm =
+					    BT_8192E_2ANT_COEX_ALGO_HID_A2DP;
+				} else {
+					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+						  "HID + A2DP + PAN(EDR)\n");
+					algorithm =
+					BT_8192E_2ANT_COEX_ALGO_HID_A2DP_PANEDR;
+				}
+			}
+		}
+	} else if (num_diffprofile >= 3) {
+		if (bt_link_info->sco_exist) {
+			if (bt_link_info->hid_exist &&
+			    bt_link_info->pan_exist &&
+			    bt_link_info->a2dp_exist) {
+				if (bt_hson) {
+					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+						  "ErrorSCO+HID+A2DP+PAN(HS)\n");
+
+				} else {
+					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+						  "SCO+HID+A2DP+PAN(EDR)\n");
+					algorithm =
+					    BT_8192E_2ANT_COEX_ALGO_PANEDR_HID;
+				}
+			}
+		}
+	}
+
+	return algorithm;
+}
+
+static void halbtc8192e2ant_setfw_dac_swinglevel(struct btc_coexist *btcoexist,
+						 u8 dac_swinglvl)
+{
+	u8 h2c_parameter[1] = {0};
+
+	/* There are several type of dacswing
+	 * 0x18/ 0x10/ 0xc/ 0x8/ 0x4/ 0x6 */
+	h2c_parameter[0] = dac_swinglvl;
+
+	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_EXEC,
+		  "[BTCoex], Set Dac Swing Level = 0x%x\n", dac_swinglvl);
+	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_EXEC,
+		  "[BTCoex], FW write 0x64 = 0x%x\n", h2c_parameter[0]);
+
+	btcoexist->btc_fill_h2c(btcoexist, 0x64, 1, h2c_parameter);
+}
+
+static void halbtc8192e2ant_set_fwdec_btpwr(struct btc_coexist *btcoexist,
+					    u8 dec_btpwr_lvl)
+{
+	u8 h2c_parameter[1] = {0};
+
+	h2c_parameter[0] = dec_btpwr_lvl;
+
+	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_EXEC,
+		  "[BTCoex] decrease Bt Power level = %d, FW write 0x62 = 0x%x\n",
+		  dec_btpwr_lvl, h2c_parameter[0]);
+
+	btcoexist->btc_fill_h2c(btcoexist, 0x62, 1, h2c_parameter);
+}
+
+static void halbtc8192e2ant_dec_btpwr(struct btc_coexist *btcoexist,
+				      bool force_exec, u8 dec_btpwr_lvl)
+{
+	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW,
+		  "[BTCoex], %s Dec BT power level = %d\n",
+		  (force_exec ? "force to" : ""), dec_btpwr_lvl);
+	coex_dm->cur_dec_bt_pwr = dec_btpwr_lvl;
+
+	if (!force_exec) {
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_DETAIL,
+			  "[BTCoex], preBtDecPwrLvl =%d, curBtDecPwrLvl =%d\n",
+			  coex_dm->pre_dec_bt_pwr, coex_dm->cur_dec_bt_pwr);
+	}
+	halbtc8192e2ant_set_fwdec_btpwr(btcoexist, coex_dm->cur_dec_bt_pwr);
+
+	coex_dm->pre_dec_bt_pwr = coex_dm->cur_dec_bt_pwr;
+}
+
+static void halbtc8192e2ant_set_bt_autoreport(struct btc_coexist *btcoexist,
+					      bool enable_autoreport)
+{
+	u8 h2c_parameter[1] = {0};
+
+	h2c_parameter[0] = 0;
+
+	if (enable_autoreport)
+		h2c_parameter[0] |= BIT(0);
+
+	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_EXEC,
+		  "[BTCoex], BT FW auto report : %s, FW write 0x68 = 0x%x\n",
+		  (enable_autoreport ? "Enabled!!" : "Disabled!!"),
+		  h2c_parameter[0]);
+
+	btcoexist->btc_fill_h2c(btcoexist, 0x68, 1, h2c_parameter);
+}
+
+static void halbtc8192e2ant_bt_autoreport(struct btc_coexist *btcoexist,
+					  bool force_exec,
+					  bool enable_autoreport)
+{
+	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW,
+		  "[BTCoex], %s BT Auto report = %s\n",
+		  (force_exec ? "force to" : ""),
+		  ((enable_autoreport) ? "Enabled" : "Disabled"));
+	coex_dm->cur_bt_auto_report = enable_autoreport;
+
+	if (!force_exec) {
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_DETAIL,
+			  "[BTCoex] bPreBtAutoReport =%d, bCurBtAutoReport =%d\n",
+			  coex_dm->pre_bt_auto_report,
+			  coex_dm->cur_bt_auto_report);
+
+		if (coex_dm->pre_bt_auto_report == coex_dm->cur_bt_auto_report)
+			return;
+	}
+	halbtc8192e2ant_set_bt_autoreport(btcoexist,
+					  coex_dm->cur_bt_auto_report);
+
+	coex_dm->pre_bt_auto_report = coex_dm->cur_bt_auto_report;
+}
+
+static void halbtc8192e2ant_fw_dac_swinglvl(struct btc_coexist *btcoexist,
+					    bool force_exec, u8 fw_dac_swinglvl)
+{
+	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW,
+		  "[BTCoex], %s set FW Dac Swing level = %d\n",
+		  (force_exec ? "force to" : ""), fw_dac_swinglvl);
+	coex_dm->cur_fw_dac_swing_lvl = fw_dac_swinglvl;
+
+	if (!force_exec) {
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_DETAIL,
+			  "[BTCoex] preFwDacSwingLvl =%d, curFwDacSwingLvl =%d\n",
+			  coex_dm->pre_fw_dac_swing_lvl,
+			  coex_dm->cur_fw_dac_swing_lvl);
+
+		if (coex_dm->pre_fw_dac_swing_lvl ==
+		    coex_dm->cur_fw_dac_swing_lvl)
+			return;
+	}
+
+	halbtc8192e2ant_setfw_dac_swinglevel(btcoexist,
+					     coex_dm->cur_fw_dac_swing_lvl);
+
+	coex_dm->pre_fw_dac_swing_lvl = coex_dm->cur_fw_dac_swing_lvl;
+}
+
+static void set_sw_rf_rx_lpf_corner(struct btc_coexist *btcoexist,
+				    bool rx_rf_shrink_on)
+{
+	if (rx_rf_shrink_on) {
+		/* Shrink RF Rx LPF corner */
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW_EXEC,
+			  "[BTCoex], Shrink RF Rx LPF corner!!\n");
+		btcoexist->btc_set_rf_reg(btcoexist, BTC_RF_A, 0x1e,
+					  0xfffff, 0xffffc);
+	} else {
+		/* Resume RF Rx LPF corner
+		 * After initialized, we can use coex_dm->btRf0x1eBackup */
+		if (btcoexist->initilized) {
+			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW_EXEC,
+				  "[BTCoex], Resume RF Rx LPF corner!!\n");
+			btcoexist->btc_set_rf_reg(btcoexist, BTC_RF_A, 0x1e,
+						  0xfffff,
+						  coex_dm->bt_rf0x1e_backup);
+		}
+	}
+}
+
+static void halbtc8192e2ant_rf_shrink(struct btc_coexist *btcoexist,
+				      bool force_exec, bool rx_rf_shrink_on)
+{
+	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW,
+		  "[BTCoex], %s turn Rx RF Shrink = %s\n",
+		  (force_exec ? "force to" : ""),
+		  ((rx_rf_shrink_on) ? "ON" : "OFF"));
+	coex_dm->cur_rf_rx_lpf_shrink = rx_rf_shrink_on;
+
+	if (!force_exec) {
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW_DETAIL,
+			  "[BTCoex]bPreRfRxLpfShrink =%d, bCurRfRxLpfShrink =%d\n",
+			  coex_dm->pre_rf_rx_lpf_shrink,
+			  coex_dm->cur_rf_rx_lpf_shrink);
+
+		if (coex_dm->pre_rf_rx_lpf_shrink ==
+		    coex_dm->cur_rf_rx_lpf_shrink)
+			return;
+	}
+	set_sw_rf_rx_lpf_corner(btcoexist, coex_dm->cur_rf_rx_lpf_shrink);
+
+	coex_dm->pre_rf_rx_lpf_shrink = coex_dm->cur_rf_rx_lpf_shrink;
+}
+
+static void halbtc8192e2ant_set_dac_swingreg(struct btc_coexist *btcoexist,
+					     u32 level)
+{
+	u8 val = (u8)level;
+
+	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW_EXEC,
+		  "[BTCoex], Write SwDacSwing = 0x%x\n", level);
+	btcoexist->btc_write_1byte_bitmask(btcoexist, 0x883, 0x3e, val);
+}
+
+static void setsw_fulltime_dacswing(struct btc_coexist *btcoexist,
+				    bool sw_dac_swingon,
+				    u32 sw_dac_swinglvl)
+{
+	if (sw_dac_swingon)
+		halbtc8192e2ant_set_dac_swingreg(btcoexist, sw_dac_swinglvl);
+	else
+		halbtc8192e2ant_set_dac_swingreg(btcoexist, 0x18);
+}
+
+static void halbtc8192e2ant_dacswing(struct btc_coexist *btcoexist,
+				     bool force_exec, bool dac_swingon,
+				     u32 dac_swinglvl)
+{
+	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW,
+		  "[BTCoex], %s turn DacSwing =%s, dac_swinglvl = 0x%x\n",
+		  (force_exec ? "force to" : ""),
+		  ((dac_swingon) ? "ON" : "OFF"), dac_swinglvl);
+	coex_dm->cur_dac_swing_on = dac_swingon;
+	coex_dm->cur_dac_swing_lvl = dac_swinglvl;
+
+	if (!force_exec) {
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW_DETAIL,
+			  "[BTCoex], bPreDacSwingOn =%d, preDacSwingLvl = 0x%x, ",
+			  coex_dm->pre_dac_swing_on,
+			  coex_dm->pre_dac_swing_lvl);
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW_DETAIL,
+			  "bCurDacSwingOn =%d, curDacSwingLvl = 0x%x\n",
+			  coex_dm->cur_dac_swing_on,
+			  coex_dm->cur_dac_swing_lvl);
+
+		if ((coex_dm->pre_dac_swing_on == coex_dm->cur_dac_swing_on) &&
+		    (coex_dm->pre_dac_swing_lvl == coex_dm->cur_dac_swing_lvl))
+			return;
+	}
+	mdelay(30);
+	setsw_fulltime_dacswing(btcoexist, dac_swingon, dac_swinglvl);
+
+	coex_dm->pre_dac_swing_on = coex_dm->cur_dac_swing_on;
+	coex_dm->pre_dac_swing_lvl = coex_dm->cur_dac_swing_lvl;
+}
+
+static void halbtc8192e2ant_set_agc_table(struct btc_coexist *btcoexist,
+					  bool agc_table_en)
+{
+	/* BB AGC Gain Table */
+	if (agc_table_en) {
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW_EXEC,
+			  "[BTCoex], BB Agc Table On!\n");
+		btcoexist->btc_write_4byte(btcoexist, 0xc78, 0x0a1A0001);
+		btcoexist->btc_write_4byte(btcoexist, 0xc78, 0x091B0001);
+		btcoexist->btc_write_4byte(btcoexist, 0xc78, 0x081C0001);
+		btcoexist->btc_write_4byte(btcoexist, 0xc78, 0x071D0001);
+		btcoexist->btc_write_4byte(btcoexist, 0xc78, 0x061E0001);
+		btcoexist->btc_write_4byte(btcoexist, 0xc78, 0x051F0001);
+	} else {
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW_EXEC,
+			  "[BTCoex], BB Agc Table Off!\n");
+		btcoexist->btc_write_4byte(btcoexist, 0xc78, 0xaa1A0001);
+		btcoexist->btc_write_4byte(btcoexist, 0xc78, 0xa91B0001);
+		btcoexist->btc_write_4byte(btcoexist, 0xc78, 0xa81C0001);
+		btcoexist->btc_write_4byte(btcoexist, 0xc78, 0xa71D0001);
+		btcoexist->btc_write_4byte(btcoexist, 0xc78, 0xa61E0001);
+		btcoexist->btc_write_4byte(btcoexist, 0xc78, 0xa51F0001);
+	}
+}
+
+static void halbtc8192e2ant_agctable(struct btc_coexist *btcoexist,
+				     bool force_exec, bool agc_table_en)
+{
+	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW,
+		  "[BTCoex], %s %s Agc Table\n",
+		  (force_exec ? "force to" : ""),
+		  ((agc_table_en) ? "Enable" : "Disable"));
+	coex_dm->cur_agc_table_en = agc_table_en;
+
+	if (!force_exec) {
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW_DETAIL,
+			  "[BTCoex], bPreAgcTableEn =%d, bCurAgcTableEn =%d\n",
+			  coex_dm->pre_agc_table_en, coex_dm->cur_agc_table_en);
+
+		if (coex_dm->pre_agc_table_en == coex_dm->cur_agc_table_en)
+			return;
+	}
+	halbtc8192e2ant_set_agc_table(btcoexist, agc_table_en);
+
+	coex_dm->pre_agc_table_en = coex_dm->cur_agc_table_en;
+}
+
+static void halbtc8192e2ant_set_coex_table(struct btc_coexist *btcoexist,
+					   u32 val0x6c0, u32 val0x6c4,
+					   u32 val0x6c8, u8 val0x6cc)
+{
+	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW_EXEC,
+		  "[BTCoex], set coex table, set 0x6c0 = 0x%x\n", val0x6c0);
+	btcoexist->btc_write_4byte(btcoexist, 0x6c0, val0x6c0);
+
+	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW_EXEC,
+		  "[BTCoex], set coex table, set 0x6c4 = 0x%x\n", val0x6c4);
+	btcoexist->btc_write_4byte(btcoexist, 0x6c4, val0x6c4);
+
+	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW_EXEC,
+		  "[BTCoex], set coex table, set 0x6c8 = 0x%x\n", val0x6c8);
+	btcoexist->btc_write_4byte(btcoexist, 0x6c8, val0x6c8);
+
+	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW_EXEC,
+		  "[BTCoex], set coex table, set 0x6cc = 0x%x\n", val0x6cc);
+	btcoexist->btc_write_1byte(btcoexist, 0x6cc, val0x6cc);
+}
+
+static void halbtc_coex_table(struct btc_coexist *btcoexist, bool force_exec,
+			      u32 val0x6c0, u32 val0x6c4,
+			      u32 val0x6c8, u8 val0x6cc)
+{
+	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW,
+		  "[BTCoex], %s write Coex Table 0x6c0 = 0x%x, ",
+		  (force_exec ? "force to" : ""), val0x6c0);
+	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW,
+		  "0x6c4 = 0x%x, 0x6c8 = 0x%x, 0x6cc = 0x%x\n",
+		  val0x6c4, val0x6c8, val0x6cc);
+	coex_dm->cur_val0x6c0 = val0x6c0;
+	coex_dm->cur_val0x6c4 = val0x6c4;
+	coex_dm->cur_val0x6c8 = val0x6c8;
+	coex_dm->cur_val0x6cc = val0x6cc;
+
+	if (!force_exec) {
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW_DETAIL,
+			  "[BTCoex], preVal0x6c0 = 0x%x, preVal0x6c4 = 0x%x, ",
+			  coex_dm->pre_val0x6c0, coex_dm->pre_val0x6c4);
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW_DETAIL,
+			  "preVal0x6c8 = 0x%x, preVal0x6cc = 0x%x!!\n",
+			  coex_dm->pre_val0x6c8, coex_dm->pre_val0x6cc);
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW_DETAIL,
+			  "[BTCoex], curVal0x6c0 = 0x%x, curVal0x6c4 = 0x%x\n",
+			  coex_dm->cur_val0x6c0, coex_dm->cur_val0x6c4);
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW_DETAIL,
+			  "curVal0x6c8 = 0x%x, curVal0x6cc = 0x%x !!\n",
+			  coex_dm->cur_val0x6c8, coex_dm->cur_val0x6cc);
+
+		if ((coex_dm->pre_val0x6c0 == coex_dm->cur_val0x6c0) &&
+		    (coex_dm->pre_val0x6c4 == coex_dm->cur_val0x6c4) &&
+		    (coex_dm->pre_val0x6c8 == coex_dm->cur_val0x6c8) &&
+		    (coex_dm->pre_val0x6cc == coex_dm->cur_val0x6cc))
+			return;
+	}
+	halbtc8192e2ant_set_coex_table(btcoexist, val0x6c0, val0x6c4,
+				       val0x6c8, val0x6cc);
+
+	coex_dm->pre_val0x6c0 = coex_dm->cur_val0x6c0;
+	coex_dm->pre_val0x6c4 = coex_dm->cur_val0x6c4;
+	coex_dm->pre_val0x6c8 = coex_dm->cur_val0x6c8;
+	coex_dm->pre_val0x6cc = coex_dm->cur_val0x6cc;
+}
+
+static void halbtc_coex_table_with_type(struct btc_coexist *btcoexist,
+					bool force_exec, u8 type)
+{
+	switch (type) {
+	case 0:
+		halbtc_coex_table(btcoexist, force_exec, 0x55555555,
+				  0x5a5a5a5a, 0xffffff, 0x3);
+		break;
+	case 1:
+		halbtc_coex_table(btcoexist, force_exec, 0x5a5a5a5a,
+				  0x5a5a5a5a, 0xffffff, 0x3);
+		break;
+	case 2:
+		halbtc_coex_table(btcoexist, force_exec, 0x55555555,
+				  0x5ffb5ffb, 0xffffff, 0x3);
+		break;
+	case 3:
+		halbtc_coex_table(btcoexist, force_exec, 0xdfffdfff,
+				  0x5fdb5fdb, 0xffffff, 0x3);
+		break;
+	case 4:
+		halbtc_coex_table(btcoexist, force_exec, 0xdfffdfff,
+				  0x5ffb5ffb, 0xffffff, 0x3);
+		break;
+	default:
+		break;
+	}
+}
+
+static void halbtc8192e2ant_set_fw_ignore_wlanact(struct btc_coexist *btcoexist,
+						  bool enable)
+{
+	u8 h2c_parameter[1] = {0};
+
+	if (enable)
+		h2c_parameter[0] |= BIT(0); /* function enable */
+
+	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_EXEC,
+		  "[BTCoex]set FW for BT Ignore Wlan_Act, FW write 0x63 = 0x%x\n",
+		  h2c_parameter[0]);
+
+	btcoexist->btc_fill_h2c(btcoexist, 0x63, 1, h2c_parameter);
+}
+
+static void halbtc8192e2ant_ignorewlanact(struct btc_coexist *btcoexist,
+					  bool force_exec, bool enable)
+{
+	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW,
+		  "[BTCoex], %s turn Ignore WlanAct %s\n",
+		  (force_exec ? "force to" : ""), (enable ? "ON" : "OFF"));
+	coex_dm->cur_ignore_wlan_act = enable;
+
+	if (!force_exec) {
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_DETAIL,
+			  "[BTCoex], bPreIgnoreWlanAct = %d ",
+			  coex_dm->pre_ignore_wlan_act);
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_DETAIL,
+			  "bCurIgnoreWlanAct = %d!!\n",
+			  coex_dm->cur_ignore_wlan_act);
+
+		if (coex_dm->pre_ignore_wlan_act ==
+		    coex_dm->cur_ignore_wlan_act)
+			return;
+	}
+	halbtc8192e2ant_set_fw_ignore_wlanact(btcoexist, enable);
+
+	coex_dm->pre_ignore_wlan_act = coex_dm->cur_ignore_wlan_act;
+}
+
+static void halbtc8192e2ant_setfwpstdma(struct btc_coexist *btcoexist, u8 byte1,
+					u8 byte2, u8 byte3, u8 byte4, u8 byte5)
+{
+	u8 h2c_parameter[5];
+
+	h2c_parameter[0] = byte1;
+	h2c_parameter[1] = byte2;
+	h2c_parameter[2] = byte3;
+	h2c_parameter[3] = byte4;
+	h2c_parameter[4] = byte5;
+
+	coex_dm->ps_tdma_para[0] = byte1;
+	coex_dm->ps_tdma_para[1] = byte2;
+	coex_dm->ps_tdma_para[2] = byte3;
+	coex_dm->ps_tdma_para[3] = byte4;
+	coex_dm->ps_tdma_para[4] = byte5;
+
+	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_EXEC,
+		  "[BTCoex], FW write 0x60(5bytes) = 0x%x%08x\n",
+		  h2c_parameter[0],
+		  h2c_parameter[1] << 24 | h2c_parameter[2] << 16 |
+		  h2c_parameter[3] << 8 | h2c_parameter[4]);
+
+	btcoexist->btc_fill_h2c(btcoexist, 0x60, 5, h2c_parameter);
+}
+
+static void halbtc_sw_mechanism1(struct btc_coexist *btcoexist,
+				 bool shrink_rx_lpf, bool low_penalty_ra,
+				 bool limited_dig, bool btlan_constrain)
+{
+	halbtc8192e2ant_rf_shrink(btcoexist, NORMAL_EXEC, shrink_rx_lpf);
+}
+
+static void halbtc_sw_mechanism2(struct btc_coexist *btcoexist,
+				 bool agc_table_shift, bool adc_backoff,
+				 bool sw_dac_swing, u32 dac_swinglvl)
+{
+	halbtc8192e2ant_agctable(btcoexist, NORMAL_EXEC, agc_table_shift);
+	halbtc8192e2ant_dacswing(btcoexist, NORMAL_EXEC, sw_dac_swing,
+				 dac_swinglvl);
+}
+
+static void halbtc8192e2ant_ps_tdma(struct btc_coexist *btcoexist,
+				    bool force_exec, bool turn_on, u8 type)
+{
+	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW,
+		  "[BTCoex], %s turn %s PS TDMA, type =%d\n",
+		  (force_exec ? "force to" : ""),
+		  (turn_on ? "ON" : "OFF"), type);
+	coex_dm->cur_ps_tdma_on = turn_on;
+	coex_dm->cur_ps_tdma = type;
+
+	if (!force_exec) {
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_DETAIL,
+			  "[BTCoex], bPrePsTdmaOn = %d, bCurPsTdmaOn = %d!!\n",
+			  coex_dm->pre_ps_tdma_on, coex_dm->cur_ps_tdma_on);
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_DETAIL,
+			  "[BTCoex], prePsTdma = %d, curPsTdma = %d!!\n",
+			  coex_dm->pre_ps_tdma, coex_dm->cur_ps_tdma);
+
+		if ((coex_dm->pre_ps_tdma_on == coex_dm->cur_ps_tdma_on) &&
+		    (coex_dm->pre_ps_tdma == coex_dm->cur_ps_tdma))
+			return;
+	}
+	if (turn_on) {
+		switch (type) {
+		case 1:
+		default:
+			halbtc8192e2ant_setfwpstdma(btcoexist, 0xe3, 0x1a,
+						    0x1a, 0xe1, 0x90);
+			break;
+		case 2:
+			halbtc8192e2ant_setfwpstdma(btcoexist, 0xe3, 0x12,
+						    0x12, 0xe1, 0x90);
+			break;
+		case 3:
+			halbtc8192e2ant_setfwpstdma(btcoexist, 0xe3, 0x1c,
+						    0x3, 0xf1, 0x90);
+			break;
+		case 4:
+			halbtc8192e2ant_setfwpstdma(btcoexist, 0xe3, 0x10,
+						    0x3, 0xf1, 0x90);
+			break;
+		case 5:
+			halbtc8192e2ant_setfwpstdma(btcoexist, 0xe3, 0x1a,
+						    0x1a, 0x60, 0x90);
+			break;
+		case 6:
+			halbtc8192e2ant_setfwpstdma(btcoexist, 0xe3, 0x12,
+						    0x12, 0x60, 0x90);
+			break;
+		case 7:
+			halbtc8192e2ant_setfwpstdma(btcoexist, 0xe3, 0x1c,
+						    0x3, 0x70, 0x90);
+			break;
+		case 8:
+			halbtc8192e2ant_setfwpstdma(btcoexist, 0xa3, 0x10,
+						    0x3, 0x70, 0x90);
+			break;
+		case 9:
+			halbtc8192e2ant_setfwpstdma(btcoexist, 0xe3, 0x1a,
+						    0x1a, 0xe1, 0x10);
+			break;
+		case 10:
+			halbtc8192e2ant_setfwpstdma(btcoexist, 0xe3, 0x12,
+						    0x12, 0xe1, 0x10);
+			break;
+		case 11:
+			halbtc8192e2ant_setfwpstdma(btcoexist, 0xe3, 0x1c,
+						    0x3, 0xf1, 0x10);
+			break;
+		case 12:
+			halbtc8192e2ant_setfwpstdma(btcoexist, 0xe3, 0x10,
+						    0x3, 0xf1, 0x10);
+			break;
+		case 13:
+			halbtc8192e2ant_setfwpstdma(btcoexist, 0xe3, 0x1a,
+						    0x1a, 0xe0, 0x10);
+			break;
+		case 14:
+			halbtc8192e2ant_setfwpstdma(btcoexist, 0xe3, 0x12,
+						    0x12, 0xe0, 0x10);
+			break;
+		case 15:
+			halbtc8192e2ant_setfwpstdma(btcoexist, 0xe3, 0x1c,
+						    0x3, 0xf0, 0x10);
+			break;
+		case 16:
+			halbtc8192e2ant_setfwpstdma(btcoexist, 0xe3, 0x12,
+						    0x3, 0xf0, 0x10);
+			break;
+		case 17:
+			halbtc8192e2ant_setfwpstdma(btcoexist, 0x61, 0x20,
+						    0x03, 0x10, 0x10);
+			break;
+		case 18:
+			halbtc8192e2ant_setfwpstdma(btcoexist, 0xe3, 0x5,
+						    0x5, 0xe1, 0x90);
+			break;
+		case 19:
+			halbtc8192e2ant_setfwpstdma(btcoexist, 0xe3, 0x25,
+						    0x25, 0xe1, 0x90);
+			break;
+		case 20:
+			halbtc8192e2ant_setfwpstdma(btcoexist, 0xe3, 0x25,
+						    0x25, 0x60, 0x90);
+			break;
+		case 21:
+			halbtc8192e2ant_setfwpstdma(btcoexist, 0xe3, 0x15,
+						    0x03, 0x70, 0x90);
+			break;
+		case 71:
+			halbtc8192e2ant_setfwpstdma(btcoexist, 0xe3, 0x1a,
+						    0x1a, 0xe1, 0x90);
+			break;
+		}
+	} else {
+		/* disable PS tdma */
+		switch (type) {
+		default:
+		case 0:
+			halbtc8192e2ant_setfwpstdma(btcoexist, 0x8, 0x0, 0x0,
+						    0x0, 0x0);
+			btcoexist->btc_write_1byte(btcoexist, 0x92c, 0x4);
+			break;
+		case 1:
+			halbtc8192e2ant_setfwpstdma(btcoexist, 0x0, 0x0, 0x0,
+						    0x8, 0x0);
+			mdelay(5);
+			btcoexist->btc_write_1byte(btcoexist, 0x92c, 0x20);
+			break;
+		}
+	}
+
+	/* update pre state */
+	coex_dm->pre_ps_tdma_on = coex_dm->cur_ps_tdma_on;
+	coex_dm->pre_ps_tdma = coex_dm->cur_ps_tdma;
+}
+
+static void set_switch_sstype(struct btc_coexist *btcoexist, u8 sstype)
+{
+	u8 mimops = BTC_MIMO_PS_DYNAMIC;
+	u32 disra_mask = 0x0;
+
+	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+		  "[BTCoex], REAL set SS Type = %d\n", sstype);
+
+	disra_mask = halbtc8192e2ant_decidera_mask(btcoexist, sstype,
+						   coex_dm->curra_masktype);
+	halbtc8192e2ant_updatera_mask(btcoexist, FORCE_EXEC, disra_mask);
+
+	if (sstype == 1) {
+		halbtc8192e2ant_ps_tdma(btcoexist, FORCE_EXEC, false, 1);
+		/* switch ofdm path */
+		btcoexist->btc_write_1byte(btcoexist, 0xc04, 0x11);
+		btcoexist->btc_write_1byte(btcoexist, 0xd04, 0x1);
+		btcoexist->btc_write_4byte(btcoexist, 0x90c, 0x81111111);
+		/* switch cck patch */
+		btcoexist->btc_write_1byte_bitmask(btcoexist, 0xe77, 0x4, 0x1);
+		btcoexist->btc_write_1byte(btcoexist, 0xa07, 0x81);
+		mimops = BTC_MIMO_PS_STATIC;
+	} else if (sstype == 2) {
+		halbtc8192e2ant_ps_tdma(btcoexist, FORCE_EXEC, false, 0);
+		btcoexist->btc_write_1byte(btcoexist, 0xc04, 0x33);
+		btcoexist->btc_write_1byte(btcoexist, 0xd04, 0x3);
+		btcoexist->btc_write_4byte(btcoexist, 0x90c, 0x81121313);
+		btcoexist->btc_write_1byte_bitmask(btcoexist, 0xe77, 0x4, 0x0);
+		btcoexist->btc_write_1byte(btcoexist, 0xa07, 0x41);
+		mimops = BTC_MIMO_PS_DYNAMIC;
+	}
+	/* set rx 1ss or 2ss */
+	btcoexist->btc_set(btcoexist, BTC_SET_ACT_SEND_MIMO_PS, &mimops);
+}
+
+static void halbtc8192e2ant_switch_sstype(struct btc_coexist *btcoexist,
+					  bool force_exec, u8 new_sstype)
+{
+	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+		  "[BTCoex], %s Switch SS Type = %d\n",
+		  (force_exec ? "force to" : ""), new_sstype);
+	coex_dm->cur_sstype = new_sstype;
+
+	if (!force_exec) {
+		if (coex_dm->pre_sstype == coex_dm->cur_sstype)
+			return;
+	}
+	set_switch_sstype(btcoexist, coex_dm->cur_sstype);
+
+	coex_dm->pre_sstype = coex_dm->cur_sstype;
+}
+
+static void halbtc8192e2ant_coex_alloff(struct btc_coexist *btcoexist)
+{
+	/* fw all off */
+	halbtc8192e2ant_ps_tdma(btcoexist, NORMAL_EXEC, false, 1);
+	halbtc8192e2ant_fw_dac_swinglvl(btcoexist, NORMAL_EXEC, 6);
+	halbtc8192e2ant_dec_btpwr(btcoexist, NORMAL_EXEC, 0);
+
+	/* sw all off */
+	halbtc_sw_mechanism1(btcoexist, false, false, false, false);
+	halbtc_sw_mechanism2(btcoexist, false, false, false, 0x18);
+
+	/* hw all off */
+	halbtc_coex_table_with_type(btcoexist, NORMAL_EXEC, 0);
+}
+
+static void halbtc8192e2ant_init_coex_dm(struct btc_coexist *btcoexist)
+{
+	/* force to reset coex mechanism */
+
+	halbtc8192e2ant_ps_tdma(btcoexist, FORCE_EXEC, false, 1);
+	halbtc8192e2ant_fw_dac_swinglvl(btcoexist, FORCE_EXEC, 6);
+	halbtc8192e2ant_dec_btpwr(btcoexist, FORCE_EXEC, 0);
+
+	halbtc_coex_table_with_type(btcoexist, FORCE_EXEC, 0);
+	halbtc8192e2ant_switch_sstype(btcoexist, FORCE_EXEC, 2);
+
+	halbtc_sw_mechanism1(btcoexist, false, false, false, false);
+	halbtc_sw_mechanism2(btcoexist, false, false, false, 0x18);
+}
+
+static void halbtc8192e2ant_action_bt_inquiry(struct btc_coexist *btcoexist)
+{
+	bool low_pwr_disable = true;
+
+	btcoexist->btc_set(btcoexist, BTC_SET_ACT_DISABLE_LOW_POWER,
+			   &low_pwr_disable);
+
+	halbtc8192e2ant_switch_sstype(btcoexist, NORMAL_EXEC, 1);
+
+	halbtc_coex_table_with_type(btcoexist, NORMAL_EXEC, 2);
+	halbtc8192e2ant_ps_tdma(btcoexist, NORMAL_EXEC, true, 3);
+	halbtc8192e2ant_fw_dac_swinglvl(btcoexist, NORMAL_EXEC, 6);
+	halbtc8192e2ant_dec_btpwr(btcoexist, NORMAL_EXEC, 0);
+
+	halbtc_sw_mechanism1(btcoexist, false, false, false, false);
+	halbtc_sw_mechanism2(btcoexist, false, false, false, 0x18);
+}
+
+static bool halbtc8192e2ant_is_common_action(struct btc_coexist *btcoexist)
+{
+	struct btc_bt_link_info *bt_link_info = &btcoexist->bt_link_info;
+	bool common = false, wifi_connected = false, wifi_busy = false;
+	bool bt_hson = false, low_pwr_disable = false;
+
+	btcoexist->btc_get(btcoexist, BTC_GET_BL_HS_OPERATION, &bt_hson);
+	btcoexist->btc_get(btcoexist, BTC_GET_BL_WIFI_CONNECTED,
+			   &wifi_connected);
+	btcoexist->btc_get(btcoexist, BTC_GET_BL_WIFI_BUSY, &wifi_busy);
+
+	if (bt_link_info->sco_exist || bt_link_info->hid_exist)
+		halbtc8192e2ant_limited_tx(btcoexist, NORMAL_EXEC, 1, 0, 0, 0);
+	else
+		halbtc8192e2ant_limited_tx(btcoexist, NORMAL_EXEC, 0, 0, 0, 0);
+
+	if (!wifi_connected) {
+		low_pwr_disable = false;
+		btcoexist->btc_set(btcoexist, BTC_SET_ACT_DISABLE_LOW_POWER,
+				   &low_pwr_disable);
+
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+			  "[BTCoex], Wifi non-connected idle!!\n");
+
+		if ((BT_8192E_2ANT_BT_STATUS_NON_CONNECTED_IDLE ==
+		     coex_dm->bt_status) ||
+		    (BT_8192E_2ANT_BT_STATUS_CONNECTED_IDLE ==
+		     coex_dm->bt_status)) {
+			halbtc8192e2ant_switch_sstype(btcoexist, NORMAL_EXEC,
+						      2);
+			halbtc_coex_table_with_type(btcoexist,
+						    NORMAL_EXEC, 1);
+			halbtc8192e2ant_ps_tdma(btcoexist, NORMAL_EXEC, false,
+						0);
+		} else {
+			halbtc8192e2ant_switch_sstype(btcoexist,
+						      NORMAL_EXEC, 1);
+			halbtc_coex_table_with_type(btcoexist,
+						    NORMAL_EXEC, 0);
+			halbtc8192e2ant_ps_tdma(btcoexist, NORMAL_EXEC,
+						false, 1);
+		}
+
+		halbtc8192e2ant_fw_dac_swinglvl(btcoexist, NORMAL_EXEC, 6);
+		halbtc8192e2ant_dec_btpwr(btcoexist, NORMAL_EXEC, 0);
+
+		halbtc_sw_mechanism1(btcoexist, false, false, false,
+				     false);
+		halbtc_sw_mechanism2(btcoexist, false, false, false,
+				     0x18);
+
+		common = true;
+	} else {
+		if (BT_8192E_2ANT_BT_STATUS_NON_CONNECTED_IDLE ==
+		    coex_dm->bt_status) {
+			low_pwr_disable = false;
+			btcoexist->btc_set(btcoexist,
+					   BTC_SET_ACT_DISABLE_LOW_POWER,
+					   &low_pwr_disable);
+
+			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+				  "Wifi connected + BT non connected-idle!!\n");
+
+			halbtc8192e2ant_switch_sstype(btcoexist,
+						      NORMAL_EXEC, 2);
+			halbtc_coex_table_with_type(btcoexist,
+						    NORMAL_EXEC, 1);
+			halbtc8192e2ant_ps_tdma(btcoexist, NORMAL_EXEC,
+						false, 0);
+			halbtc8192e2ant_fw_dac_swinglvl(btcoexist, NORMAL_EXEC,
+							6);
+			halbtc8192e2ant_dec_btpwr(btcoexist, NORMAL_EXEC, 0);
+
+			halbtc_sw_mechanism1(btcoexist, false, false,
+					     false, false);
+			halbtc_sw_mechanism2(btcoexist, false, false,
+					     false, 0x18);
+
+			common = true;
+		} else if (BT_8192E_2ANT_BT_STATUS_CONNECTED_IDLE ==
+			   coex_dm->bt_status) {
+			low_pwr_disable = true;
+			btcoexist->btc_set(btcoexist,
+					   BTC_SET_ACT_DISABLE_LOW_POWER,
+					   &low_pwr_disable);
+
+			if (bt_hson)
+				return false;
+			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+				  "Wifi connected + BT connected-idle!!\n");
+
+			halbtc8192e2ant_switch_sstype(btcoexist, NORMAL_EXEC,
+						      2);
+			halbtc_coex_table_with_type(btcoexist,
+						    NORMAL_EXEC, 1);
+			halbtc8192e2ant_ps_tdma(btcoexist, NORMAL_EXEC,
+						false, 0);
+			halbtc8192e2ant_fw_dac_swinglvl(btcoexist,
+							NORMAL_EXEC, 6);
+			halbtc8192e2ant_dec_btpwr(btcoexist, NORMAL_EXEC, 0);
+
+			halbtc_sw_mechanism1(btcoexist, true, false,
+					     false, false);
+			halbtc_sw_mechanism2(btcoexist, false, false,
+					     false, 0x18);
+
+			common = true;
+		} else {
+			low_pwr_disable = true;
+			btcoexist->btc_set(btcoexist,
+					   BTC_SET_ACT_DISABLE_LOW_POWER,
+					   &low_pwr_disable);
+
+			if (wifi_busy) {
+				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+					  "Wifi Connected-Busy + BT Busy!!\n");
+				common = false;
+			} else {
+				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+					  "Wifi Connected-Idle + BT Busy!!\n");
+
+				halbtc8192e2ant_switch_sstype(btcoexist,
+							      NORMAL_EXEC, 1);
+				halbtc_coex_table_with_type(btcoexist,
+							    NORMAL_EXEC, 2);
+				halbtc8192e2ant_ps_tdma(btcoexist, NORMAL_EXEC,
+							true, 21);
+				halbtc8192e2ant_fw_dac_swinglvl(btcoexist,
+								NORMAL_EXEC, 6);
+				halbtc8192e2ant_dec_btpwr(btcoexist,
+							  NORMAL_EXEC, 0);
+				halbtc_sw_mechanism1(btcoexist, false,
+						     false, false,
+						     false);
+				halbtc_sw_mechanism2(btcoexist, false,
+						     false, false,
+						     0x18);
+				common = true;
+			}
+		}
+	}
+	return common;
+}
+
+static void halbtc8192e2ant_tdma_duration_adjust(struct btc_coexist *btcoexist,
+						 bool sco_hid, bool tx_pause,
+						 u8 max_interval)
+{
+	static int up, dn, m, n, wait_cnt;
+	/* 0: no change, +1: increase WiFi duration,
+	 * -1: decrease WiFi duration */
+	int result;
+	u8 retry_cnt = 0;
+
+	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW,
+		  "[BTCoex], TdmaDurationAdjust()\n");
+
+	if (!coex_dm->auto_tdma_adjust) {
+		coex_dm->auto_tdma_adjust = true;
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_DETAIL,
+			  "[BTCoex], first run TdmaDurationAdjust()!!\n");
+		if (sco_hid) {
+			if (tx_pause) {
+				if (max_interval == 1) {
+					halbtc8192e2ant_ps_tdma(btcoexist,
+								NORMAL_EXEC,
+								true, 13);
+					coex_dm->ps_tdma_du_adj_type = 13;
+				} else if (max_interval == 2) {
+					halbtc8192e2ant_ps_tdma(btcoexist,
+								NORMAL_EXEC,
+								true, 14);
+					coex_dm->ps_tdma_du_adj_type = 14;
+				} else if (max_interval == 3) {
+					halbtc8192e2ant_ps_tdma(btcoexist,
+								NORMAL_EXEC,
+								true, 15);
+					coex_dm->ps_tdma_du_adj_type = 15;
+				} else {
+					halbtc8192e2ant_ps_tdma(btcoexist,
+								NORMAL_EXEC,
+								true, 15);
+					coex_dm->ps_tdma_du_adj_type = 15;
+				}
+			} else {
+				if (max_interval == 1) {
+					halbtc8192e2ant_ps_tdma(btcoexist,
+								NORMAL_EXEC,
+								true, 9);
+					coex_dm->ps_tdma_du_adj_type = 9;
+				} else if (max_interval == 2) {
+					halbtc8192e2ant_ps_tdma(btcoexist,
+								NORMAL_EXEC,
+								true, 10);
+					coex_dm->ps_tdma_du_adj_type = 10;
+				} else if (max_interval == 3) {
+					halbtc8192e2ant_ps_tdma(btcoexist,
+								NORMAL_EXEC,
+								true, 11);
+					coex_dm->ps_tdma_du_adj_type = 11;
+				} else {
+					halbtc8192e2ant_ps_tdma(btcoexist,
+								NORMAL_EXEC,
+								true, 11);
+					coex_dm->ps_tdma_du_adj_type = 11;
+				}
+			}
+		} else {
+			if (tx_pause) {
+				if (max_interval == 1) {
+					halbtc8192e2ant_ps_tdma(btcoexist,
+								NORMAL_EXEC,
+								true, 5);
+					coex_dm->ps_tdma_du_adj_type = 5;
+				} else if (max_interval == 2) {
+					halbtc8192e2ant_ps_tdma(btcoexist,
+								NORMAL_EXEC,
+								true, 6);
+					coex_dm->ps_tdma_du_adj_type = 6;
+				} else if (max_interval == 3) {
+					halbtc8192e2ant_ps_tdma(btcoexist,
+								NORMAL_EXEC,
+								true, 7);
+					coex_dm->ps_tdma_du_adj_type = 7;
+				} else {
+					halbtc8192e2ant_ps_tdma(btcoexist,
+								NORMAL_EXEC,
+								true, 7);
+					coex_dm->ps_tdma_du_adj_type = 7;
+				}
+			} else {
+				if (max_interval == 1) {
+					halbtc8192e2ant_ps_tdma(btcoexist,
+								NORMAL_EXEC,
+								true, 1);
+					coex_dm->ps_tdma_du_adj_type = 1;
+				} else if (max_interval == 2) {
+					halbtc8192e2ant_ps_tdma(btcoexist,
+								NORMAL_EXEC,
+								true, 2);
+					coex_dm->ps_tdma_du_adj_type = 2;
+				} else if (max_interval == 3) {
+					halbtc8192e2ant_ps_tdma(btcoexist,
+								NORMAL_EXEC,
+								true, 3);
+					coex_dm->ps_tdma_du_adj_type = 3;
+				} else {
+					halbtc8192e2ant_ps_tdma(btcoexist,
+								NORMAL_EXEC,
+								true, 3);
+					coex_dm->ps_tdma_du_adj_type = 3;
+				}
+			}
+		}
+
+		up = 0;
+		dn = 0;
+		m = 1;
+		n = 3;
+		result = 0;
+		wait_cnt = 0;
+	} else {
+		/* accquire the BT TRx retry count from BT_Info byte2 */
+		retry_cnt = coex_sta->bt_retry_cnt;
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_DETAIL,
+			  "[BTCoex], retry_cnt = %d\n", retry_cnt);
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_DETAIL,
+			  "[BTCoex], up =%d, dn =%d, m =%d, n =%d, wait_cnt =%d\n",
+			  up, dn, m, n, wait_cnt);
+		result = 0;
+		wait_cnt++;
+		/* no retry in the last 2-second duration */
+		if (retry_cnt == 0) {
+			up++;
+			dn--;
+
+			if (dn <= 0)
+				dn = 0;
+
+			if (up >= n) {
+				wait_cnt = 0;
+				n = 3;
+				up = 0;
+				dn = 0;
+				result = 1;
+				BTC_PRINT(BTC_MSG_ALGORITHM,
+					  ALGO_TRACE_FW_DETAIL,
+					  "[BTCoex]Increase wifi duration!!\n");
+			}
+		} else if (retry_cnt <= 3) {
+			up--;
+			dn++;
+
+			if (up <= 0)
+				up = 0;
+
+			if (dn == 2) {
+				if (wait_cnt <= 2)
+					m++;
+				else
+					m = 1;
+
+				if (m >= 20)
+					m = 20;
+
+				n = 3 * m;
+				up = 0;
+				dn = 0;
+				wait_cnt = 0;
+				result = -1;
+				BTC_PRINT(BTC_MSG_ALGORITHM,
+					  ALGO_TRACE_FW_DETAIL,
+					  "Reduce wifi duration for retry<3\n");
+			}
+		} else {
+			if (wait_cnt == 1)
+				m++;
+			else
+				m = 1;
+
+			if (m >= 20)
+				m = 20;
+
+			n = 3*m;
+			up = 0;
+			dn = 0;
+			wait_cnt = 0;
+			result = -1;
+			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_DETAIL,
+				  "Decrease wifi duration for retryCounter>3!!\n");
+		}
+
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_DETAIL,
+			  "[BTCoex], max Interval = %d\n", max_interval);
+		if (max_interval == 1) {
+			if (tx_pause) {
+				BTC_PRINT(BTC_MSG_ALGORITHM,
+					  ALGO_TRACE_FW_DETAIL,
+					  "[BTCoex], TxPause = 1\n");
+
+				if (coex_dm->cur_ps_tdma == 71) {
+					halbtc8192e2ant_ps_tdma(btcoexist,
+								NORMAL_EXEC,
+								true, 5);
+					coex_dm->ps_tdma_du_adj_type = 5;
+				} else if (coex_dm->cur_ps_tdma == 1) {
+					halbtc8192e2ant_ps_tdma(btcoexist,
+								NORMAL_EXEC,
+								true, 5);
+					coex_dm->ps_tdma_du_adj_type = 5;
+				} else if (coex_dm->cur_ps_tdma == 2) {
+					halbtc8192e2ant_ps_tdma(btcoexist,
+								NORMAL_EXEC,
+								true, 6);
+					coex_dm->ps_tdma_du_adj_type = 6;
+				} else if (coex_dm->cur_ps_tdma == 3) {
+					halbtc8192e2ant_ps_tdma(btcoexist,
+								NORMAL_EXEC,
+								true, 7);
+					coex_dm->ps_tdma_du_adj_type = 7;
+				} else if (coex_dm->cur_ps_tdma == 4) {
+					halbtc8192e2ant_ps_tdma(btcoexist,
+								NORMAL_EXEC,
+								true, 8);
+					coex_dm->ps_tdma_du_adj_type = 8;
+				}
+				if (coex_dm->cur_ps_tdma == 9) {
+					halbtc8192e2ant_ps_tdma(btcoexist,
+								NORMAL_EXEC,
+								true, 13);
+					coex_dm->ps_tdma_du_adj_type = 13;
+				} else if (coex_dm->cur_ps_tdma == 10) {
+					halbtc8192e2ant_ps_tdma(btcoexist,
+								NORMAL_EXEC,
+								true, 14);
+					coex_dm->ps_tdma_du_adj_type = 14;
+				} else if (coex_dm->cur_ps_tdma == 11) {
+					halbtc8192e2ant_ps_tdma(btcoexist,
+								NORMAL_EXEC,
+								true, 15);
+					coex_dm->ps_tdma_du_adj_type = 15;
+				} else if (coex_dm->cur_ps_tdma == 12) {
+					halbtc8192e2ant_ps_tdma(btcoexist,
+								NORMAL_EXEC,
+								true, 16);
+					coex_dm->ps_tdma_du_adj_type = 16;
+				}
+
+				if (result == -1) {
+					if (coex_dm->cur_ps_tdma == 5) {
+						halbtc8192e2ant_ps_tdma(
+								    btcoexist,
+								    NORMAL_EXEC,
+								    true, 6);
+						coex_dm->ps_tdma_du_adj_type =
+									     6;
+					} else if (coex_dm->cur_ps_tdma == 6) {
+						halbtc8192e2ant_ps_tdma(
+								    btcoexist,
+								    NORMAL_EXEC,
+								    true, 7);
+						coex_dm->ps_tdma_du_adj_type =
+									     7;
+					} else if (coex_dm->cur_ps_tdma == 7) {
+						halbtc8192e2ant_ps_tdma(
+								    btcoexist,
+								    NORMAL_EXEC,
+								    true, 8);
+						coex_dm->ps_tdma_du_adj_type =
+									     8;
+					} else if (coex_dm->cur_ps_tdma == 13) {
+						halbtc8192e2ant_ps_tdma(
+								    btcoexist,
+								    NORMAL_EXEC,
+								    true, 14);
+						coex_dm->ps_tdma_du_adj_type =
+									     14;
+					} else if (coex_dm->cur_ps_tdma == 14) {
+						halbtc8192e2ant_ps_tdma(
+								    btcoexist,
+								    NORMAL_EXEC,
+								    true, 15);
+						coex_dm->ps_tdma_du_adj_type =
+									     15;
+					} else if (coex_dm->cur_ps_tdma == 15) {
+						halbtc8192e2ant_ps_tdma(
+								    btcoexist,
+								    NORMAL_EXEC,
+								    true, 16);
+						coex_dm->ps_tdma_du_adj_type =
+									     16;
+					}
+				} else if (result == 1) {
+					if (coex_dm->cur_ps_tdma == 8) {
+						halbtc8192e2ant_ps_tdma(
+								    btcoexist,
+								    NORMAL_EXEC,
+								    true, 7);
+						coex_dm->ps_tdma_du_adj_type =
+									     7;
+					} else if (coex_dm->cur_ps_tdma == 7) {
+						halbtc8192e2ant_ps_tdma(
+								    btcoexist,
+								    NORMAL_EXEC,
+								    true, 6);
+						coex_dm->ps_tdma_du_adj_type =
+									     6;
+					} else if (coex_dm->cur_ps_tdma == 6) {
+						halbtc8192e2ant_ps_tdma(
+								    btcoexist,
+								    NORMAL_EXEC,
+								    true, 5);
+						coex_dm->ps_tdma_du_adj_type =
+									     5;
+					} else if (coex_dm->cur_ps_tdma == 16) {
+						halbtc8192e2ant_ps_tdma(
+								    btcoexist,
+								    NORMAL_EXEC,
+								    true, 15);
+						coex_dm->ps_tdma_du_adj_type =
+									     15;
+					} else if (coex_dm->cur_ps_tdma == 15) {
+						halbtc8192e2ant_ps_tdma(
+								    btcoexist,
+								    NORMAL_EXEC,
+								    true, 14);
+						coex_dm->ps_tdma_du_adj_type =
+									     14;
+					} else if (coex_dm->cur_ps_tdma == 14) {
+						halbtc8192e2ant_ps_tdma(
+								    btcoexist,
+								    NORMAL_EXEC,
+								    true, 13);
+						coex_dm->ps_tdma_du_adj_type =
+									     13;
+					}
+				}
+			} else {
+				BTC_PRINT(BTC_MSG_ALGORITHM,
+					  ALGO_TRACE_FW_DETAIL,
+					  "[BTCoex], TxPause = 0\n");
+				if (coex_dm->cur_ps_tdma == 5) {
+					halbtc8192e2ant_ps_tdma(btcoexist,
+								NORMAL_EXEC,
+								true, 71);
+					coex_dm->ps_tdma_du_adj_type = 71;
+				} else if (coex_dm->cur_ps_tdma == 6) {
+					halbtc8192e2ant_ps_tdma(btcoexist,
+								NORMAL_EXEC,
+								true, 2);
+					coex_dm->ps_tdma_du_adj_type = 2;
+				} else if (coex_dm->cur_ps_tdma == 7) {
+					halbtc8192e2ant_ps_tdma(btcoexist,
+								NORMAL_EXEC,
+								true, 3);
+					coex_dm->ps_tdma_du_adj_type = 3;
+				} else if (coex_dm->cur_ps_tdma == 8) {
+					halbtc8192e2ant_ps_tdma(btcoexist,
+								NORMAL_EXEC,
+								true, 4);
+					coex_dm->ps_tdma_du_adj_type = 4;
+				}
+				if (coex_dm->cur_ps_tdma == 13) {
+					halbtc8192e2ant_ps_tdma(btcoexist,
+								NORMAL_EXEC,
+								true, 9);
+					coex_dm->ps_tdma_du_adj_type = 9;
+				} else if (coex_dm->cur_ps_tdma == 14) {
+					halbtc8192e2ant_ps_tdma(btcoexist,
+								NORMAL_EXEC,
+								true, 10);
+					coex_dm->ps_tdma_du_adj_type = 10;
+				} else if (coex_dm->cur_ps_tdma == 15) {
+					halbtc8192e2ant_ps_tdma(btcoexist,
+								NORMAL_EXEC,
+								true, 11);
+					coex_dm->ps_tdma_du_adj_type = 11;
+				} else if (coex_dm->cur_ps_tdma == 16) {
+					halbtc8192e2ant_ps_tdma(btcoexist,
+								NORMAL_EXEC,
+								true, 12);
+					coex_dm->ps_tdma_du_adj_type = 12;
+				}
+
+				if (result == -1) {
+					if (coex_dm->cur_ps_tdma == 71) {
+						halbtc8192e2ant_ps_tdma(
+								    btcoexist,
+								    NORMAL_EXEC,
+								    true, 1);
+						coex_dm->ps_tdma_du_adj_type =
+									     1;
+					} else if (coex_dm->cur_ps_tdma == 1) {
+						halbtc8192e2ant_ps_tdma(
+								    btcoexist,
+								    NORMAL_EXEC,
+								    true, 2);
+						coex_dm->ps_tdma_du_adj_type =
+									     2;
+					} else if (coex_dm->cur_ps_tdma == 2) {
+						halbtc8192e2ant_ps_tdma(
+								    btcoexist,
+								    NORMAL_EXEC,
+								    true, 3);
+						coex_dm->ps_tdma_du_adj_type =
+									     3;
+					} else if (coex_dm->cur_ps_tdma == 3) {
+						halbtc8192e2ant_ps_tdma(
+								    btcoexist,
+								    NORMAL_EXEC,
+								    true, 4);
+						coex_dm->ps_tdma_du_adj_type =
+									     4;
+					} else if (coex_dm->cur_ps_tdma == 9) {
+						halbtc8192e2ant_ps_tdma(
+								    btcoexist,
+								    NORMAL_EXEC,
+								    true, 10);
+						coex_dm->ps_tdma_du_adj_type =
+									     10;
+					} else if (coex_dm->cur_ps_tdma == 10) {
+						halbtc8192e2ant_ps_tdma(
+								    btcoexist,
+								    NORMAL_EXEC,
+								    true, 11);
+						coex_dm->ps_tdma_du_adj_type =
+									     11;
+					} else if (coex_dm->cur_ps_tdma == 11) {
+						halbtc8192e2ant_ps_tdma(
+								    btcoexist,
+								    NORMAL_EXEC,
+								    true, 12);
+						coex_dm->ps_tdma_du_adj_type =
+									     12;
+					}
+				} else if (result == 1) {
+					if (coex_dm->cur_ps_tdma == 4) {
+						halbtc8192e2ant_ps_tdma(
+								    btcoexist,
+								    NORMAL_EXEC,
+								    true, 3);
+						coex_dm->ps_tdma_du_adj_type =
+									     3;
+					} else if (coex_dm->cur_ps_tdma == 3) {
+						halbtc8192e2ant_ps_tdma(
+								    btcoexist,
+								    NORMAL_EXEC,
+								    true, 2);
+						coex_dm->ps_tdma_du_adj_type =
+									     2;
+					} else if (coex_dm->cur_ps_tdma == 2) {
+						halbtc8192e2ant_ps_tdma(
+								    btcoexist,
+								    NORMAL_EXEC,
+								    true, 1);
+						coex_dm->ps_tdma_du_adj_type =
+									     1;
+					} else if (coex_dm->cur_ps_tdma == 1) {
+						halbtc8192e2ant_ps_tdma(
+								    btcoexist,
+								    NORMAL_EXEC,
+								    true, 71);
+						coex_dm->ps_tdma_du_adj_type =
+									     71;
+					} else if (coex_dm->cur_ps_tdma == 12) {
+						halbtc8192e2ant_ps_tdma(
+								    btcoexist,
+								    NORMAL_EXEC,
+								    true, 11);
+						coex_dm->ps_tdma_du_adj_type =
+									     11;
+					} else if (coex_dm->cur_ps_tdma == 11) {
+						halbtc8192e2ant_ps_tdma(
+								    btcoexist,
+								    NORMAL_EXEC,
+								    true, 10);
+						coex_dm->ps_tdma_du_adj_type =
+									     10;
+					} else if (coex_dm->cur_ps_tdma == 10) {
+						halbtc8192e2ant_ps_tdma(
+								    btcoexist,
+								    NORMAL_EXEC,
+								    true, 9);
+						coex_dm->ps_tdma_du_adj_type =
+									     9;
+					}
+				}
+			}
+		} else if (max_interval == 2) {
+			if (tx_pause) {
+				BTC_PRINT(BTC_MSG_ALGORITHM,
+					  ALGO_TRACE_FW_DETAIL,
+					  "[BTCoex], TxPause = 1\n");
+				if (coex_dm->cur_ps_tdma == 1) {
+					halbtc8192e2ant_ps_tdma(btcoexist,
+								NORMAL_EXEC,
+								true, 6);
+					coex_dm->ps_tdma_du_adj_type = 6;
+				} else if (coex_dm->cur_ps_tdma == 2) {
+					halbtc8192e2ant_ps_tdma(btcoexist,
+								NORMAL_EXEC,
+								true, 6);
+					coex_dm->ps_tdma_du_adj_type = 6;
+				} else if (coex_dm->cur_ps_tdma == 3) {
+					halbtc8192e2ant_ps_tdma(btcoexist,
+								NORMAL_EXEC,
+								true, 7);
+					coex_dm->ps_tdma_du_adj_type = 7;
+				} else if (coex_dm->cur_ps_tdma == 4) {
+					halbtc8192e2ant_ps_tdma(btcoexist,
+								NORMAL_EXEC,
+								true, 8);
+					coex_dm->ps_tdma_du_adj_type = 8;
+				}
+				if (coex_dm->cur_ps_tdma == 9) {
+					halbtc8192e2ant_ps_tdma(btcoexist,
+								NORMAL_EXEC,
+								true, 14);
+					coex_dm->ps_tdma_du_adj_type = 14;
+				} else if (coex_dm->cur_ps_tdma == 10) {
+					halbtc8192e2ant_ps_tdma(btcoexist,
+								NORMAL_EXEC,
+								true, 14);
+					coex_dm->ps_tdma_du_adj_type = 14;
+				} else if (coex_dm->cur_ps_tdma == 11) {
+					halbtc8192e2ant_ps_tdma(btcoexist,
+								NORMAL_EXEC,
+								true, 15);
+					coex_dm->ps_tdma_du_adj_type = 15;
+				} else if (coex_dm->cur_ps_tdma == 12) {
+					halbtc8192e2ant_ps_tdma(btcoexist,
+								NORMAL_EXEC,
+								true, 16);
+					coex_dm->ps_tdma_du_adj_type = 16;
+				}
+				if (result == -1) {
+					if (coex_dm->cur_ps_tdma == 5) {
+						halbtc8192e2ant_ps_tdma(
+								    btcoexist,
+								    NORMAL_EXEC,
+								    true, 6);
+						coex_dm->ps_tdma_du_adj_type =
+									     6;
+					} else if (coex_dm->cur_ps_tdma == 6) {
+						halbtc8192e2ant_ps_tdma(
+								    btcoexist,
+								    NORMAL_EXEC,
+								    true, 7);
+						coex_dm->ps_tdma_du_adj_type =
+									     7;
+					} else if (coex_dm->cur_ps_tdma == 7) {
+						halbtc8192e2ant_ps_tdma(
+								    btcoexist,
+								    NORMAL_EXEC,
+								    true, 8);
+						coex_dm->ps_tdma_du_adj_type =
+									     8;
+					} else if (coex_dm->cur_ps_tdma == 13) {
+						halbtc8192e2ant_ps_tdma(
+								    btcoexist,
+								    NORMAL_EXEC,
+								    true, 14);
+						coex_dm->ps_tdma_du_adj_type =
+									     14;
+					} else if (coex_dm->cur_ps_tdma == 14) {
+						halbtc8192e2ant_ps_tdma(
+								    btcoexist,
+								    NORMAL_EXEC,
+								    true, 15);
+						coex_dm->ps_tdma_du_adj_type =
+									     15;
+					} else if (coex_dm->cur_ps_tdma == 15) {
+						halbtc8192e2ant_ps_tdma(
+								    btcoexist,
+								    NORMAL_EXEC,
+								    true, 16);
+						coex_dm->ps_tdma_du_adj_type =
+									     16;
+					}
+				} else if (result == 1) {
+					if (coex_dm->cur_ps_tdma == 8) {
+						halbtc8192e2ant_ps_tdma(
+								    btcoexist,
+								    NORMAL_EXEC,
+								    true, 7);
+						coex_dm->ps_tdma_du_adj_type =
+									     7;
+					} else if (coex_dm->cur_ps_tdma == 7) {
+						halbtc8192e2ant_ps_tdma(
+								    btcoexist,
+								    NORMAL_EXEC,
+								    true, 6);
+						coex_dm->ps_tdma_du_adj_type =
+									     6;
+					} else if (coex_dm->cur_ps_tdma == 6) {
+						halbtc8192e2ant_ps_tdma(
+								    btcoexist,
+								    NORMAL_EXEC,
+								    true, 6);
+						coex_dm->ps_tdma_du_adj_type =
+									     6;
+					} else if (coex_dm->cur_ps_tdma == 16) {
+						halbtc8192e2ant_ps_tdma(
+								    btcoexist,
+								    NORMAL_EXEC,
+								    true, 15);
+						coex_dm->ps_tdma_du_adj_type =
+									     15;
+					} else if (coex_dm->cur_ps_tdma == 15) {
+						halbtc8192e2ant_ps_tdma(
+								    btcoexist,
+								    NORMAL_EXEC,
+								    true, 14);
+						coex_dm->ps_tdma_du_adj_type =
+									     14;
+					} else if (coex_dm->cur_ps_tdma == 14) {
+						halbtc8192e2ant_ps_tdma(
+								    btcoexist,
+								    NORMAL_EXEC,
+								    true, 14);
+						coex_dm->ps_tdma_du_adj_type =
+									     14;
+					}
+				}
+			} else {
+				BTC_PRINT(BTC_MSG_ALGORITHM,
+					  ALGO_TRACE_FW_DETAIL,
+					  "[BTCoex], TxPause = 0\n");
+				if (coex_dm->cur_ps_tdma == 5) {
+					halbtc8192e2ant_ps_tdma(btcoexist,
+								NORMAL_EXEC,
+								true, 2);
+					coex_dm->ps_tdma_du_adj_type = 2;
+				} else if (coex_dm->cur_ps_tdma == 6) {
+					halbtc8192e2ant_ps_tdma(btcoexist,
+								NORMAL_EXEC,
+								true, 2);
+					coex_dm->ps_tdma_du_adj_type = 2;
+				} else if (coex_dm->cur_ps_tdma == 7) {
+					halbtc8192e2ant_ps_tdma(btcoexist,
+								NORMAL_EXEC,
+								true, 3);
+					coex_dm->ps_tdma_du_adj_type = 3;
+				} else if (coex_dm->cur_ps_tdma == 8) {
+					halbtc8192e2ant_ps_tdma(btcoexist,
+								NORMAL_EXEC,
+								true, 4);
+					coex_dm->ps_tdma_du_adj_type = 4;
+				}
+				if (coex_dm->cur_ps_tdma == 13) {
+					halbtc8192e2ant_ps_tdma(btcoexist,
+								NORMAL_EXEC,
+								true, 10);
+					coex_dm->ps_tdma_du_adj_type = 10;
+				} else if (coex_dm->cur_ps_tdma == 14) {
+					halbtc8192e2ant_ps_tdma(btcoexist,
+								NORMAL_EXEC,
+								true, 10);
+					coex_dm->ps_tdma_du_adj_type = 10;
+				} else if (coex_dm->cur_ps_tdma == 15) {
+					halbtc8192e2ant_ps_tdma(btcoexist,
+								NORMAL_EXEC,
+								true, 11);
+					coex_dm->ps_tdma_du_adj_type = 11;
+				} else if (coex_dm->cur_ps_tdma == 16) {
+					halbtc8192e2ant_ps_tdma(btcoexist,
+								NORMAL_EXEC,
+								true, 12);
+					coex_dm->ps_tdma_du_adj_type = 12;
+				}
+				if (result == -1) {
+					if (coex_dm->cur_ps_tdma == 1) {
+						halbtc8192e2ant_ps_tdma(
+								    btcoexist,
+								    NORMAL_EXEC,
+								    true, 2);
+						coex_dm->ps_tdma_du_adj_type =
+									     2;
+					} else if (coex_dm->cur_ps_tdma == 2) {
+						halbtc8192e2ant_ps_tdma(
+								    btcoexist,
+								    NORMAL_EXEC,
+								    true, 3);
+						coex_dm->ps_tdma_du_adj_type =
+									     3;
+					} else if (coex_dm->cur_ps_tdma == 3) {
+						halbtc8192e2ant_ps_tdma(
+								    btcoexist,
+								    NORMAL_EXEC,
+								    true, 4);
+						coex_dm->ps_tdma_du_adj_type =
+									     4;
+					} else if (coex_dm->cur_ps_tdma == 9) {
+						halbtc8192e2ant_ps_tdma(
+								    btcoexist,
+								    NORMAL_EXEC,
+								    true, 10);
+						coex_dm->ps_tdma_du_adj_type =
+									     10;
+					} else if (coex_dm->cur_ps_tdma == 10) {
+						halbtc8192e2ant_ps_tdma(
+								    btcoexist,
+								    NORMAL_EXEC,
+								    true, 11);
+						coex_dm->ps_tdma_du_adj_type =
+									     11;
+					} else if (coex_dm->cur_ps_tdma == 11) {
+						halbtc8192e2ant_ps_tdma(
+								    btcoexist,
+								    NORMAL_EXEC,
+								    true, 12);
+						coex_dm->ps_tdma_du_adj_type =
+									     12;
+					}
+				} else if (result == 1) {
+					if (coex_dm->cur_ps_tdma == 4) {
+						halbtc8192e2ant_ps_tdma(
+								    btcoexist,
+								    NORMAL_EXEC,
+								    true, 3);
+						coex_dm->ps_tdma_du_adj_type =
+									     3;
+					} else if (coex_dm->cur_ps_tdma == 3) {
+						halbtc8192e2ant_ps_tdma(
+								    btcoexist,
+								    NORMAL_EXEC,
+								    true, 2);
+						coex_dm->ps_tdma_du_adj_type =
+									     2;
+					} else if (coex_dm->cur_ps_tdma == 2) {
+						halbtc8192e2ant_ps_tdma(
+								    btcoexist,
+								    NORMAL_EXEC,
+								    true, 2);
+						coex_dm->ps_tdma_du_adj_type =
+									     2;
+					} else if (coex_dm->cur_ps_tdma == 12) {
+						halbtc8192e2ant_ps_tdma(
+								    btcoexist,
+								    NORMAL_EXEC,
+								    true, 11);
+						coex_dm->ps_tdma_du_adj_type =
+									     11;
+					} else if (coex_dm->cur_ps_tdma == 11) {
+						halbtc8192e2ant_ps_tdma(
+								    btcoexist,
+								    NORMAL_EXEC,
+								    true, 10);
+						coex_dm->ps_tdma_du_adj_type =
+									     10;
+					} else if (coex_dm->cur_ps_tdma == 10) {
+						halbtc8192e2ant_ps_tdma(
+								    btcoexist,
+								    NORMAL_EXEC,
+								    true, 10);
+						coex_dm->ps_tdma_du_adj_type =
+									     10;
+					}
+				}
+			}
+		} else if (max_interval == 3) {
+			if (tx_pause) {
+				BTC_PRINT(BTC_MSG_ALGORITHM,
+					  ALGO_TRACE_FW_DETAIL,
+					  "[BTCoex], TxPause = 1\n");
+				if (coex_dm->cur_ps_tdma == 1) {
+					halbtc8192e2ant_ps_tdma(btcoexist,
+								NORMAL_EXEC,
+								true, 7);
+					coex_dm->ps_tdma_du_adj_type = 7;
+				} else if (coex_dm->cur_ps_tdma == 2) {
+					halbtc8192e2ant_ps_tdma(btcoexist,
+								NORMAL_EXEC,
+								true, 7);
+					coex_dm->ps_tdma_du_adj_type = 7;
+				} else if (coex_dm->cur_ps_tdma == 3) {
+					halbtc8192e2ant_ps_tdma(btcoexist,
+								NORMAL_EXEC,
+								true, 7);
+					coex_dm->ps_tdma_du_adj_type = 7;
+				} else if (coex_dm->cur_ps_tdma == 4) {
+					halbtc8192e2ant_ps_tdma(btcoexist,
+								NORMAL_EXEC,
+								true, 8);
+					coex_dm->ps_tdma_du_adj_type = 8;
+				}
+				if (coex_dm->cur_ps_tdma == 9) {
+					halbtc8192e2ant_ps_tdma(btcoexist,
+								NORMAL_EXEC,
+								true, 15);
+					coex_dm->ps_tdma_du_adj_type = 15;
+				} else if (coex_dm->cur_ps_tdma == 10) {
+					halbtc8192e2ant_ps_tdma(btcoexist,
+								NORMAL_EXEC,
+								true, 15);
+					coex_dm->ps_tdma_du_adj_type = 15;
+				} else if (coex_dm->cur_ps_tdma == 11) {
+					halbtc8192e2ant_ps_tdma(btcoexist,
+								NORMAL_EXEC,
+								true, 15);
+					coex_dm->ps_tdma_du_adj_type = 15;
+				} else if (coex_dm->cur_ps_tdma == 12) {
+					halbtc8192e2ant_ps_tdma(btcoexist,
+								NORMAL_EXEC,
+								true, 16);
+					coex_dm->ps_tdma_du_adj_type = 16;
+				}
+				if (result == -1) {
+					if (coex_dm->cur_ps_tdma == 5) {
+						halbtc8192e2ant_ps_tdma(
+								    btcoexist,
+								    NORMAL_EXEC,
+								    true, 7);
+						coex_dm->ps_tdma_du_adj_type =
+									     7;
+					} else if (coex_dm->cur_ps_tdma == 6) {
+						halbtc8192e2ant_ps_tdma(
+								    btcoexist,
+								    NORMAL_EXEC,
+								    true, 7);
+						coex_dm->ps_tdma_du_adj_type =
+									     7;
+					} else if (coex_dm->cur_ps_tdma == 7) {
+						halbtc8192e2ant_ps_tdma(
+								    btcoexist,
+								    NORMAL_EXEC,
+								    true, 8);
+						coex_dm->ps_tdma_du_adj_type =
+									     8;
+					} else if (coex_dm->cur_ps_tdma == 13) {
+						halbtc8192e2ant_ps_tdma(
+								    btcoexist,
+								    NORMAL_EXEC,
+								    true, 15);
+						coex_dm->ps_tdma_du_adj_type =
+									     15;
+					} else if (coex_dm->cur_ps_tdma == 14) {
+						halbtc8192e2ant_ps_tdma(
+								    btcoexist,
+								    NORMAL_EXEC,
+								    true, 15);
+						coex_dm->ps_tdma_du_adj_type =
+									     15;
+					} else if (coex_dm->cur_ps_tdma == 15) {
+						halbtc8192e2ant_ps_tdma(
+								    btcoexist,
+								    NORMAL_EXEC,
+								    true, 16);
+						coex_dm->ps_tdma_du_adj_type =
+									     16;
+					}
+				} else if (result == 1) {
+					if (coex_dm->cur_ps_tdma == 8) {
+						halbtc8192e2ant_ps_tdma(
+								    btcoexist,
+								    NORMAL_EXEC,
+								    true, 7);
+						coex_dm->ps_tdma_du_adj_type =
+									     7;
+					} else if (coex_dm->cur_ps_tdma == 7) {
+						halbtc8192e2ant_ps_tdma(
+								    btcoexist,
+								    NORMAL_EXEC,
+								    true, 7);
+						coex_dm->ps_tdma_du_adj_type =
+									     7;
+					} else if (coex_dm->cur_ps_tdma == 6) {
+						halbtc8192e2ant_ps_tdma(
+								    btcoexist,
+								    NORMAL_EXEC,
+								    true, 7);
+						coex_dm->ps_tdma_du_adj_type =
+									     7;
+					} else if (coex_dm->cur_ps_tdma == 16) {
+						halbtc8192e2ant_ps_tdma(
+								    btcoexist,
+								    NORMAL_EXEC,
+								    true, 15);
+						coex_dm->ps_tdma_du_adj_type =
+									     15;
+					} else if (coex_dm->cur_ps_tdma == 15) {
+						halbtc8192e2ant_ps_tdma(
+								    btcoexist,
+								    NORMAL_EXEC,
+								    true, 15);
+						coex_dm->ps_tdma_du_adj_type =
+									     15;
+					} else if (coex_dm->cur_ps_tdma == 14) {
+						halbtc8192e2ant_ps_tdma(
+								    btcoexist,
+								    NORMAL_EXEC,
+								    true, 15);
+						coex_dm->ps_tdma_du_adj_type =
+									     15;
+					}
+				}
+			} else {
+				BTC_PRINT(BTC_MSG_ALGORITHM,
+					  ALGO_TRACE_FW_DETAIL,
+					  "[BTCoex], TxPause = 0\n");
+				if (coex_dm->cur_ps_tdma == 5) {
+					halbtc8192e2ant_ps_tdma(btcoexist,
+								NORMAL_EXEC,
+								true, 3);
+					coex_dm->ps_tdma_du_adj_type = 3;
+				} else if (coex_dm->cur_ps_tdma == 6) {
+					halbtc8192e2ant_ps_tdma(btcoexist,
+								NORMAL_EXEC,
+								true, 3);
+					coex_dm->ps_tdma_du_adj_type = 3;
+				} else if (coex_dm->cur_ps_tdma == 7) {
+					halbtc8192e2ant_ps_tdma(btcoexist,
+								NORMAL_EXEC,
+								true, 3);
+					coex_dm->ps_tdma_du_adj_type = 3;
+				} else if (coex_dm->cur_ps_tdma == 8) {
+					halbtc8192e2ant_ps_tdma(btcoexist,
+								NORMAL_EXEC,
+								true, 4);
+					coex_dm->ps_tdma_du_adj_type = 4;
+				}
+				if (coex_dm->cur_ps_tdma == 13) {
+					halbtc8192e2ant_ps_tdma(btcoexist,
+								NORMAL_EXEC,
+								true, 11);
+					coex_dm->ps_tdma_du_adj_type = 11;
+				} else if (coex_dm->cur_ps_tdma == 14) {
+					halbtc8192e2ant_ps_tdma(btcoexist,
+								NORMAL_EXEC,
+								true, 11);
+					coex_dm->ps_tdma_du_adj_type = 11;
+				} else if (coex_dm->cur_ps_tdma == 15) {
+					halbtc8192e2ant_ps_tdma(btcoexist,
+								NORMAL_EXEC,
+								true, 11);
+					coex_dm->ps_tdma_du_adj_type = 11;
+				} else if (coex_dm->cur_ps_tdma == 16) {
+					halbtc8192e2ant_ps_tdma(btcoexist,
+								NORMAL_EXEC,
+								true, 12);
+					coex_dm->ps_tdma_du_adj_type = 12;
+				}
+				if (result == -1) {
+					if (coex_dm->cur_ps_tdma == 1) {
+						halbtc8192e2ant_ps_tdma(
+								    btcoexist,
+								    NORMAL_EXEC,
+								    true, 3);
+						coex_dm->ps_tdma_du_adj_type =
+									     3;
+					} else if (coex_dm->cur_ps_tdma == 2) {
+						halbtc8192e2ant_ps_tdma(
+								    btcoexist,
+								    NORMAL_EXEC,
+								    true, 3);
+						coex_dm->ps_tdma_du_adj_type =
+									     3;
+					} else if (coex_dm->cur_ps_tdma == 3) {
+						halbtc8192e2ant_ps_tdma(
+								    btcoexist,
+								    NORMAL_EXEC,
+								    true, 4);
+						coex_dm->ps_tdma_du_adj_type =
+									     4;
+					} else if (coex_dm->cur_ps_tdma == 9) {
+						halbtc8192e2ant_ps_tdma(
+								    btcoexist,
+								    NORMAL_EXEC,
+								    true, 11);
+						coex_dm->ps_tdma_du_adj_type =
+									     11;
+					} else if (coex_dm->cur_ps_tdma == 10) {
+						halbtc8192e2ant_ps_tdma(
+								    btcoexist,
+								    NORMAL_EXEC,
+								    true, 11);
+						coex_dm->ps_tdma_du_adj_type =
+									     11;
+					} else if (coex_dm->cur_ps_tdma == 11) {
+						halbtc8192e2ant_ps_tdma(
+								    btcoexist,
+								    NORMAL_EXEC,
+								    true, 12);
+						coex_dm->ps_tdma_du_adj_type =
+									     12;
+					}
+				} else if (result == 1) {
+					if (coex_dm->cur_ps_tdma == 4) {
+						halbtc8192e2ant_ps_tdma(
+								    btcoexist,
+								    NORMAL_EXEC,
+								    true, 3);
+						coex_dm->ps_tdma_du_adj_type =
+									     3;
+					} else if (coex_dm->cur_ps_tdma == 3) {
+						halbtc8192e2ant_ps_tdma(
+								    btcoexist,
+								    NORMAL_EXEC,
+								    true, 3);
+						coex_dm->ps_tdma_du_adj_type =
+									     3;
+					} else if (coex_dm->cur_ps_tdma == 2) {
+						halbtc8192e2ant_ps_tdma(
+								    btcoexist,
+								    NORMAL_EXEC,
+								    true, 3);
+						coex_dm->ps_tdma_du_adj_type =
+									     3;
+					} else if (coex_dm->cur_ps_tdma == 12) {
+						halbtc8192e2ant_ps_tdma(
+								    btcoexist,
+								    NORMAL_EXEC,
+								    true, 11);
+						coex_dm->ps_tdma_du_adj_type =
+									     11;
+					} else if (coex_dm->cur_ps_tdma == 11) {
+						halbtc8192e2ant_ps_tdma(
+								    btcoexist,
+								    NORMAL_EXEC,
+								    true, 11);
+						coex_dm->ps_tdma_du_adj_type =
+									     11;
+					} else if (coex_dm->cur_ps_tdma == 10) {
+						halbtc8192e2ant_ps_tdma(
+								    btcoexist,
+								    NORMAL_EXEC,
+								    true, 11);
+						coex_dm->ps_tdma_du_adj_type =
+									     11;
+					}
+				}
+			}
+		}
+	}
+
+	/* if current PsTdma not match with
+	 * the recorded one (when scan, dhcp...),
+	 * then we have to adjust it back to the previous record one. */
+	if (coex_dm->cur_ps_tdma != coex_dm->ps_tdma_du_adj_type) {
+		bool scan = false, link = false, roam = false;
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_DETAIL,
+			  "[BTCoex], PsTdma type dismatch!!!, ");
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_DETAIL,
+			  "curPsTdma =%d, recordPsTdma =%d\n",
+			  coex_dm->cur_ps_tdma, coex_dm->ps_tdma_du_adj_type);
+
+		btcoexist->btc_get(btcoexist, BTC_GET_BL_WIFI_SCAN, &scan);
+		btcoexist->btc_get(btcoexist, BTC_GET_BL_WIFI_LINK, &link);
+		btcoexist->btc_get(btcoexist, BTC_GET_BL_WIFI_ROAM, &roam);
+
+		if (!scan && !link && !roam)
+			halbtc8192e2ant_ps_tdma(btcoexist, NORMAL_EXEC,
+						true,
+						coex_dm->ps_tdma_du_adj_type);
+		else
+			BTC_PRINT(BTC_MSG_ALGORITHM,
+				  ALGO_TRACE_FW_DETAIL,
+				  "[BTCoex], roaming/link/scan is under progress, will adjust next time!!!\n");
+	}
+}
+
+/* SCO only or SCO+PAN(HS) */
+static void halbtc8192e2ant_action_sco(struct btc_coexist *btcoexist)
+{
+	u8 wifirssi_state, btrssi_state = BTC_RSSI_STATE_STAY_LOW;
+	u32 wifi_bw;
+
+	wifirssi_state = halbtc8192e2ant_wifirssi_state(btcoexist, 0, 2, 15, 0);
+
+	halbtc8192e2ant_switch_sstype(btcoexist, NORMAL_EXEC, 1);
+	halbtc8192e2ant_limited_rx(btcoexist, NORMAL_EXEC, false, false, 0x8);
+
+	halbtc8192e2ant_fw_dac_swinglvl(btcoexist, NORMAL_EXEC, 6);
+
+	halbtc_coex_table_with_type(btcoexist, NORMAL_EXEC, 4);
+
+	btrssi_state = halbtc8192e2ant_btrssi_state(3, 34, 42);
+
+	if ((btrssi_state == BTC_RSSI_STATE_LOW) ||
+	    (btrssi_state == BTC_RSSI_STATE_STAY_LOW)) {
+		halbtc8192e2ant_dec_btpwr(btcoexist, NORMAL_EXEC, 0);
+		halbtc8192e2ant_ps_tdma(btcoexist, NORMAL_EXEC, true, 13);
+	} else if ((btrssi_state == BTC_RSSI_STATE_MEDIUM) ||
+		   (btrssi_state == BTC_RSSI_STATE_STAY_MEDIUM)) {
+		halbtc8192e2ant_dec_btpwr(btcoexist, NORMAL_EXEC, 2);
+		halbtc8192e2ant_ps_tdma(btcoexist, NORMAL_EXEC, true, 9);
+	} else if ((btrssi_state == BTC_RSSI_STATE_HIGH) ||
+		   (btrssi_state == BTC_RSSI_STATE_STAY_HIGH)) {
+		halbtc8192e2ant_dec_btpwr(btcoexist, NORMAL_EXEC, 4);
+		halbtc8192e2ant_ps_tdma(btcoexist, NORMAL_EXEC, true, 9);
+	}
+
+	btcoexist->btc_get(btcoexist, BTC_GET_U4_WIFI_BW, &wifi_bw);
+
+	/* sw mechanism */
+	if (BTC_WIFI_BW_HT40 == wifi_bw) {
+		if ((wifirssi_state == BTC_RSSI_STATE_HIGH) ||
+		    (wifirssi_state == BTC_RSSI_STATE_STAY_HIGH)) {
+			halbtc_sw_mechanism1(btcoexist, true, true,
+					     false, false);
+			halbtc_sw_mechanism2(btcoexist, true, false,
+					     false, 0x6);
+		} else {
+			halbtc_sw_mechanism1(btcoexist, true, true,
+					     false, false);
+			halbtc_sw_mechanism2(btcoexist, false, false,
+					     false, 0x6);
+		}
+	} else {
+		if ((wifirssi_state == BTC_RSSI_STATE_HIGH) ||
+		    (wifirssi_state == BTC_RSSI_STATE_STAY_HIGH)) {
+			halbtc_sw_mechanism1(btcoexist, false, true,
+					     false, false);
+			halbtc_sw_mechanism2(btcoexist, true, false,
+					     false, 0x6);
+		} else {
+			halbtc_sw_mechanism1(btcoexist, false, true,
+					     false, false);
+			halbtc_sw_mechanism2(btcoexist, false, false,
+					     false, 0x6);
+		}
+	}
+}
+
+static void halbtc8192e2ant_action_sco_pan(struct btc_coexist *btcoexist)
+{
+	u8 wifirssi_state, btrssi_state = BTC_RSSI_STATE_STAY_LOW;
+	u32 wifi_bw;
+
+	wifirssi_state = halbtc8192e2ant_wifirssi_state(btcoexist, 0, 2, 15, 0);
+
+	halbtc8192e2ant_switch_sstype(btcoexist, NORMAL_EXEC, 1);
+	halbtc8192e2ant_limited_rx(btcoexist, NORMAL_EXEC, false, false, 0x8);
+
+	halbtc8192e2ant_fw_dac_swinglvl(btcoexist, NORMAL_EXEC, 6);
+
+	halbtc_coex_table_with_type(btcoexist, NORMAL_EXEC, 4);
+
+	btrssi_state = halbtc8192e2ant_btrssi_state(3, 34, 42);
+
+	if ((btrssi_state == BTC_RSSI_STATE_LOW) ||
+	    (btrssi_state == BTC_RSSI_STATE_STAY_LOW)) {
+		halbtc8192e2ant_dec_btpwr(btcoexist, NORMAL_EXEC, 0);
+		halbtc8192e2ant_ps_tdma(btcoexist, NORMAL_EXEC, true, 14);
+	} else if ((btrssi_state == BTC_RSSI_STATE_MEDIUM) ||
+		   (btrssi_state == BTC_RSSI_STATE_STAY_MEDIUM)) {
+		halbtc8192e2ant_dec_btpwr(btcoexist, NORMAL_EXEC, 2);
+		halbtc8192e2ant_ps_tdma(btcoexist, NORMAL_EXEC, true, 10);
+	} else if ((btrssi_state == BTC_RSSI_STATE_HIGH) ||
+		   (btrssi_state == BTC_RSSI_STATE_STAY_HIGH)) {
+		halbtc8192e2ant_dec_btpwr(btcoexist, NORMAL_EXEC, 4);
+		halbtc8192e2ant_ps_tdma(btcoexist, NORMAL_EXEC, true, 10);
+	}
+
+	btcoexist->btc_get(btcoexist, BTC_GET_U4_WIFI_BW, &wifi_bw);
+
+	/* sw mechanism */
+	if (BTC_WIFI_BW_HT40 == wifi_bw) {
+		if ((wifirssi_state == BTC_RSSI_STATE_HIGH) ||
+		    (wifirssi_state == BTC_RSSI_STATE_STAY_HIGH)) {
+			halbtc_sw_mechanism1(btcoexist, true, true,
+					     false, false);
+			halbtc_sw_mechanism2(btcoexist, true, false,
+					     false, 0x6);
+		} else {
+			halbtc_sw_mechanism1(btcoexist, true, true,
+					     false, false);
+			halbtc_sw_mechanism2(btcoexist, false, false,
+					     false, 0x6);
+		}
+	} else {
+		if ((wifirssi_state == BTC_RSSI_STATE_HIGH) ||
+		    (wifirssi_state == BTC_RSSI_STATE_STAY_HIGH)) {
+			halbtc_sw_mechanism1(btcoexist, false, true,
+					     false, false);
+			halbtc_sw_mechanism2(btcoexist, true, false,
+					     false, 0x6);
+		} else {
+			halbtc_sw_mechanism1(btcoexist, false, true,
+					     false, false);
+			halbtc_sw_mechanism2(btcoexist, false, false,
+					     false, 0x6);
+		}
+	}
+}
+
+static void halbtc8192e2ant_action_hid(struct btc_coexist *btcoexist)
+{
+	u8 wifirssi_state, btrssi_state = BTC_RSSI_STATE_HIGH;
+	u32 wifi_bw;
+
+	wifirssi_state = halbtc8192e2ant_wifirssi_state(btcoexist, 0, 2, 15, 0);
+	btrssi_state = halbtc8192e2ant_btrssi_state(3, 34, 42);
+
+	halbtc8192e2ant_switch_sstype(btcoexist, NORMAL_EXEC, 1);
+	halbtc8192e2ant_limited_rx(btcoexist, NORMAL_EXEC, false, false, 0x8);
+
+	halbtc8192e2ant_fw_dac_swinglvl(btcoexist, NORMAL_EXEC, 6);
+
+	btcoexist->btc_get(btcoexist, BTC_GET_U4_WIFI_BW, &wifi_bw);
+
+	halbtc_coex_table_with_type(btcoexist, NORMAL_EXEC, 3);
+
+	if ((btrssi_state == BTC_RSSI_STATE_LOW) ||
+	    (btrssi_state == BTC_RSSI_STATE_STAY_LOW)) {
+		halbtc8192e2ant_dec_btpwr(btcoexist, NORMAL_EXEC, 0);
+		halbtc8192e2ant_ps_tdma(btcoexist, NORMAL_EXEC, true, 13);
+	} else if ((btrssi_state == BTC_RSSI_STATE_MEDIUM) ||
+		   (btrssi_state == BTC_RSSI_STATE_STAY_MEDIUM)) {
+		halbtc8192e2ant_dec_btpwr(btcoexist, NORMAL_EXEC, 2);
+		halbtc8192e2ant_ps_tdma(btcoexist, NORMAL_EXEC, true, 9);
+	} else if ((btrssi_state == BTC_RSSI_STATE_HIGH) ||
+		   (btrssi_state == BTC_RSSI_STATE_STAY_HIGH)) {
+		halbtc8192e2ant_dec_btpwr(btcoexist, NORMAL_EXEC, 4);
+		halbtc8192e2ant_ps_tdma(btcoexist, NORMAL_EXEC, true, 9);
+	}
+
+	/* sw mechanism */
+	if (BTC_WIFI_BW_HT40 == wifi_bw) {
+		if ((wifirssi_state == BTC_RSSI_STATE_HIGH) ||
+		    (wifirssi_state == BTC_RSSI_STATE_STAY_HIGH)) {
+			halbtc_sw_mechanism1(btcoexist, true, true,
+					     false, false);
+			halbtc_sw_mechanism2(btcoexist, true, false,
+					     false, 0x18);
+		} else {
+			halbtc_sw_mechanism1(btcoexist, true, true,
+					     false, false);
+			halbtc_sw_mechanism2(btcoexist, false, false,
+					     false, 0x18);
+		}
+	} else {
+		if ((wifirssi_state == BTC_RSSI_STATE_HIGH) ||
+		    (wifirssi_state == BTC_RSSI_STATE_STAY_HIGH)) {
+			halbtc_sw_mechanism1(btcoexist, false, true,
+					     false, false);
+			halbtc_sw_mechanism2(btcoexist, true, false,
+					     false, 0x18);
+		} else {
+			halbtc_sw_mechanism1(btcoexist, false, true,
+					     false, false);
+			halbtc_sw_mechanism2(btcoexist, false, false,
+					     false, 0x18);
+		}
+	}
+}
+
+/* A2DP only / PAN(EDR) only/ A2DP+PAN(HS) */
+static void halbtc8192e2ant_action_a2dp(struct btc_coexist *btcoexist)
+{
+	u8 wifirssi_state, btrssi_state = BTC_RSSI_STATE_HIGH;
+	u32 wifi_bw;
+	bool long_dist = false;
+
+	wifirssi_state = halbtc8192e2ant_wifirssi_state(btcoexist, 0, 2, 15, 0);
+	btrssi_state = halbtc8192e2ant_btrssi_state(3, 34, 42);
+
+	if ((btrssi_state == BTC_RSSI_STATE_LOW ||
+	     btrssi_state == BTC_RSSI_STATE_STAY_LOW) &&
+	    (wifirssi_state == BTC_RSSI_STATE_LOW ||
+	     wifirssi_state == BTC_RSSI_STATE_STAY_LOW)) {
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+			  "[BTCoex], A2dp, wifi/bt rssi both LOW!!\n");
+		long_dist = true;
+	}
+	if (long_dist) {
+		halbtc8192e2ant_switch_sstype(btcoexist, NORMAL_EXEC, 2);
+		halbtc8192e2ant_limited_rx(btcoexist, NORMAL_EXEC, false, true,
+					   0x4);
+	} else {
+		halbtc8192e2ant_switch_sstype(btcoexist, NORMAL_EXEC, 1);
+		halbtc8192e2ant_limited_rx(btcoexist, NORMAL_EXEC, false, false,
+					   0x8);
+	}
+
+	halbtc8192e2ant_fw_dac_swinglvl(btcoexist, NORMAL_EXEC, 6);
+
+	if (long_dist)
+		halbtc_coex_table_with_type(btcoexist, NORMAL_EXEC, 0);
+	else
+		halbtc_coex_table_with_type(btcoexist, NORMAL_EXEC, 2);
+
+	if (long_dist) {
+		halbtc8192e2ant_ps_tdma(btcoexist, NORMAL_EXEC, true, 17);
+		coex_dm->auto_tdma_adjust = false;
+		halbtc8192e2ant_dec_btpwr(btcoexist, NORMAL_EXEC, 0);
+	} else {
+		if ((btrssi_state == BTC_RSSI_STATE_LOW) ||
+		    (btrssi_state == BTC_RSSI_STATE_STAY_LOW)) {
+			halbtc8192e2ant_tdma_duration_adjust(btcoexist, false,
+							     true, 1);
+			halbtc8192e2ant_dec_btpwr(btcoexist, NORMAL_EXEC, 0);
+		} else if ((btrssi_state == BTC_RSSI_STATE_MEDIUM) ||
+			   (btrssi_state == BTC_RSSI_STATE_STAY_MEDIUM)) {
+			halbtc8192e2ant_tdma_duration_adjust(btcoexist, false,
+							     false, 1);
+			halbtc8192e2ant_dec_btpwr(btcoexist, NORMAL_EXEC, 2);
+		} else if ((btrssi_state == BTC_RSSI_STATE_HIGH) ||
+			   (btrssi_state == BTC_RSSI_STATE_STAY_HIGH)) {
+			halbtc8192e2ant_tdma_duration_adjust(btcoexist, false,
+							     false, 1);
+			halbtc8192e2ant_dec_btpwr(btcoexist, NORMAL_EXEC, 4);
+		}
+	}
+
+	/* sw mechanism */
+	btcoexist->btc_get(btcoexist, BTC_GET_U4_WIFI_BW, &wifi_bw);
+	if (BTC_WIFI_BW_HT40 == wifi_bw) {
+		if ((wifirssi_state == BTC_RSSI_STATE_HIGH) ||
+		    (wifirssi_state == BTC_RSSI_STATE_STAY_HIGH)) {
+			halbtc_sw_mechanism1(btcoexist, true, false,
+					     false, false);
+			halbtc_sw_mechanism2(btcoexist, true, false,
+					     false, 0x18);
+		} else {
+			halbtc_sw_mechanism1(btcoexist, true, false,
+					     false, false);
+			halbtc_sw_mechanism2(btcoexist, false, false,
+					     false, 0x18);
+		}
+	} else {
+		if ((wifirssi_state == BTC_RSSI_STATE_HIGH) ||
+		    (wifirssi_state == BTC_RSSI_STATE_STAY_HIGH)) {
+			halbtc_sw_mechanism1(btcoexist, false, false,
+					     false, false);
+			halbtc_sw_mechanism2(btcoexist, true, false,
+					     false, 0x18);
+		} else {
+			halbtc_sw_mechanism1(btcoexist, false, false,
+					     false, false);
+			halbtc_sw_mechanism2(btcoexist, false, false,
+					     false, 0x18);
+		}
+	}
+}
+
+static void halbtc8192e2ant_action_a2dp_pan_hs(struct btc_coexist *btcoexist)
+{
+	u8 wifirssi_state, btrssi_state = BTC_RSSI_STATE_HIGH;
+	u32 wifi_bw;
+
+	wifirssi_state = halbtc8192e2ant_wifirssi_state(btcoexist, 0, 2, 15, 0);
+	btrssi_state = halbtc8192e2ant_btrssi_state(3, 34, 42);
+
+	halbtc8192e2ant_switch_sstype(btcoexist, NORMAL_EXEC, 1);
+	halbtc8192e2ant_limited_rx(btcoexist, NORMAL_EXEC, false, false, 0x8);
+
+	halbtc8192e2ant_fw_dac_swinglvl(btcoexist, NORMAL_EXEC, 6);
+	halbtc_coex_table_with_type(btcoexist, NORMAL_EXEC, 2);
+
+	if ((btrssi_state == BTC_RSSI_STATE_LOW) ||
+	    (btrssi_state == BTC_RSSI_STATE_STAY_LOW)) {
+		halbtc8192e2ant_tdma_duration_adjust(btcoexist, false, true, 2);
+		halbtc8192e2ant_dec_btpwr(btcoexist, NORMAL_EXEC, 0);
+	} else if ((btrssi_state == BTC_RSSI_STATE_MEDIUM) ||
+		   (btrssi_state == BTC_RSSI_STATE_STAY_MEDIUM)) {
+		halbtc8192e2ant_tdma_duration_adjust(btcoexist, false, false,
+						     2);
+		halbtc8192e2ant_dec_btpwr(btcoexist, NORMAL_EXEC, 2);
+	} else if ((btrssi_state == BTC_RSSI_STATE_HIGH) ||
+		   (btrssi_state == BTC_RSSI_STATE_STAY_HIGH)) {
+		halbtc8192e2ant_tdma_duration_adjust(btcoexist, false, false,
+						     2);
+		halbtc8192e2ant_dec_btpwr(btcoexist, NORMAL_EXEC, 4);
+	}
+
+	/* sw mechanism */
+	btcoexist->btc_get(btcoexist, BTC_GET_U4_WIFI_BW, &wifi_bw);
+	if (BTC_WIFI_BW_HT40 == wifi_bw) {
+		if ((wifirssi_state == BTC_RSSI_STATE_HIGH) ||
+		    (wifirssi_state == BTC_RSSI_STATE_STAY_HIGH)) {
+			halbtc_sw_mechanism1(btcoexist, true, false,
+					     false, false);
+			halbtc_sw_mechanism2(btcoexist, true, false,
+					     true, 0x6);
+		} else {
+			halbtc_sw_mechanism1(btcoexist, true, false,
+					     false, false);
+			halbtc_sw_mechanism2(btcoexist, false, false,
+					     true, 0x6);
+		}
+	} else {
+		if ((wifirssi_state == BTC_RSSI_STATE_HIGH) ||
+		    (wifirssi_state == BTC_RSSI_STATE_STAY_HIGH)) {
+			halbtc_sw_mechanism1(btcoexist, false, false,
+					     false, false);
+			halbtc_sw_mechanism2(btcoexist, true, false,
+					     true, 0x6);
+		} else {
+			halbtc_sw_mechanism1(btcoexist, false, false,
+					     false, false);
+			halbtc_sw_mechanism2(btcoexist, false, false,
+					     true, 0x6);
+		}
+	}
+}
+
+static void halbtc8192e2ant_action_pan_edr(struct btc_coexist *btcoexist)
+{
+	u8 wifirssi_state, btrssi_state = BTC_RSSI_STATE_HIGH;
+	u32 wifi_bw;
+
+	wifirssi_state = halbtc8192e2ant_wifirssi_state(btcoexist, 0, 2, 15, 0);
+	btrssi_state = halbtc8192e2ant_btrssi_state(3, 34, 42);
+
+	halbtc8192e2ant_switch_sstype(btcoexist, NORMAL_EXEC, 1);
+	halbtc8192e2ant_limited_rx(btcoexist, NORMAL_EXEC, false, false, 0x8);
+
+	halbtc8192e2ant_fw_dac_swinglvl(btcoexist, NORMAL_EXEC, 6);
+
+	halbtc_coex_table_with_type(btcoexist, NORMAL_EXEC, 2);
+
+	if ((btrssi_state == BTC_RSSI_STATE_LOW) ||
+	    (btrssi_state == BTC_RSSI_STATE_STAY_LOW)) {
+		halbtc8192e2ant_dec_btpwr(btcoexist, NORMAL_EXEC, 0);
+		halbtc8192e2ant_ps_tdma(btcoexist, NORMAL_EXEC, true, 5);
+	} else if ((btrssi_state == BTC_RSSI_STATE_MEDIUM) ||
+		   (btrssi_state == BTC_RSSI_STATE_STAY_MEDIUM)) {
+		halbtc8192e2ant_dec_btpwr(btcoexist, NORMAL_EXEC, 2);
+		halbtc8192e2ant_ps_tdma(btcoexist, NORMAL_EXEC, true, 1);
+	} else if ((btrssi_state == BTC_RSSI_STATE_HIGH) ||
+		   (btrssi_state == BTC_RSSI_STATE_STAY_HIGH)) {
+		halbtc8192e2ant_dec_btpwr(btcoexist, NORMAL_EXEC, 4);
+		halbtc8192e2ant_ps_tdma(btcoexist, NORMAL_EXEC, true, 1);
+	}
+
+	/* sw mechanism */
+	btcoexist->btc_get(btcoexist, BTC_GET_U4_WIFI_BW, &wifi_bw);
+	if (BTC_WIFI_BW_HT40 == wifi_bw) {
+		if ((wifirssi_state == BTC_RSSI_STATE_HIGH) ||
+		    (wifirssi_state == BTC_RSSI_STATE_STAY_HIGH)) {
+			halbtc_sw_mechanism1(btcoexist, true, false,
+					     false, false);
+			halbtc_sw_mechanism2(btcoexist, true, false,
+					     false, 0x18);
+		} else {
+			halbtc_sw_mechanism1(btcoexist, true, false,
+					     false, false);
+			halbtc_sw_mechanism2(btcoexist, false, false,
+					     false, 0x18);
+		}
+	} else {
+		if ((wifirssi_state == BTC_RSSI_STATE_HIGH) ||
+		    (wifirssi_state == BTC_RSSI_STATE_STAY_HIGH)) {
+			halbtc_sw_mechanism1(btcoexist, false, false,
+					     false, false);
+			halbtc_sw_mechanism2(btcoexist, true, false,
+					     false, 0x18);
+		} else {
+			halbtc_sw_mechanism1(btcoexist, false, false,
+					     false, false);
+			halbtc_sw_mechanism2(btcoexist, false, false,
+					     false, 0x18);
+		}
+	}
+}
+
+/* PAN(HS) only */
+static void halbtc8192e2ant_action_pan_hs(struct btc_coexist *btcoexist)
+{
+	u8 wifirssi_state, btrssi_state = BTC_RSSI_STATE_HIGH;
+	u32 wifi_bw;
+
+	wifirssi_state = halbtc8192e2ant_wifirssi_state(btcoexist, 0, 2, 15, 0);
+	btrssi_state = halbtc8192e2ant_btrssi_state(3, 34, 42);
+
+	halbtc8192e2ant_switch_sstype(btcoexist, NORMAL_EXEC, 1);
+	halbtc8192e2ant_limited_rx(btcoexist, NORMAL_EXEC, false, false, 0x8);
+
+	halbtc8192e2ant_fw_dac_swinglvl(btcoexist, NORMAL_EXEC, 6);
+
+	halbtc_coex_table_with_type(btcoexist, NORMAL_EXEC, 2);
+
+	if ((btrssi_state == BTC_RSSI_STATE_LOW) ||
+	    (btrssi_state == BTC_RSSI_STATE_STAY_LOW)) {
+		halbtc8192e2ant_dec_btpwr(btcoexist, NORMAL_EXEC, 0);
+	} else if ((btrssi_state == BTC_RSSI_STATE_MEDIUM) ||
+		   (btrssi_state == BTC_RSSI_STATE_STAY_MEDIUM)) {
+		halbtc8192e2ant_dec_btpwr(btcoexist, NORMAL_EXEC, 2);
+	} else if ((btrssi_state == BTC_RSSI_STATE_HIGH) ||
+		   (btrssi_state == BTC_RSSI_STATE_STAY_HIGH)) {
+		halbtc8192e2ant_dec_btpwr(btcoexist, NORMAL_EXEC, 4);
+	}
+	halbtc8192e2ant_ps_tdma(btcoexist, NORMAL_EXEC, false, 1);
+
+	btcoexist->btc_get(btcoexist, BTC_GET_U4_WIFI_BW, &wifi_bw);
+	if (BTC_WIFI_BW_HT40 == wifi_bw) {
+		if ((wifirssi_state == BTC_RSSI_STATE_HIGH) ||
+		    (wifirssi_state == BTC_RSSI_STATE_STAY_HIGH)) {
+			halbtc_sw_mechanism1(btcoexist, true, false,
+					     false, false);
+			halbtc_sw_mechanism2(btcoexist, true, false,
+					     false, 0x18);
+		} else {
+			halbtc_sw_mechanism1(btcoexist, true, false,
+					     false, false);
+			halbtc_sw_mechanism2(btcoexist, false, false,
+					     false, 0x18);
+		}
+	} else {
+		if ((wifirssi_state == BTC_RSSI_STATE_HIGH) ||
+		    (wifirssi_state == BTC_RSSI_STATE_STAY_HIGH)) {
+			halbtc_sw_mechanism1(btcoexist, false, false,
+					     false, false);
+			halbtc_sw_mechanism2(btcoexist, true, false,
+					     false, 0x18);
+		} else {
+			halbtc_sw_mechanism1(btcoexist, false, false,
+					     false, false);
+			halbtc_sw_mechanism2(btcoexist, false, false,
+					     false, 0x18);
+		}
+	}
+}
+
+/* PAN(EDR)+A2DP */
+static void halbtc8192e2ant_action_pan_edr_a2dp(struct btc_coexist *btcoexist)
+{
+	u8 wifirssi_state, btrssi_state = BTC_RSSI_STATE_HIGH;
+	u32 wifi_bw;
+
+	wifirssi_state = halbtc8192e2ant_wifirssi_state(btcoexist, 0, 2, 15, 0);
+	btrssi_state = halbtc8192e2ant_btrssi_state(3, 34, 42);
+
+	halbtc8192e2ant_switch_sstype(btcoexist, NORMAL_EXEC, 1);
+	halbtc8192e2ant_limited_rx(btcoexist, NORMAL_EXEC, false, false, 0x8);
+
+	halbtc8192e2ant_fw_dac_swinglvl(btcoexist, NORMAL_EXEC, 6);
+
+	halbtc_coex_table_with_type(btcoexist, NORMAL_EXEC, 2);
+
+	btcoexist->btc_get(btcoexist, BTC_GET_U4_WIFI_BW, &wifi_bw);
+
+	if ((btrssi_state == BTC_RSSI_STATE_LOW) ||
+	    (btrssi_state == BTC_RSSI_STATE_STAY_LOW)) {
+		halbtc8192e2ant_dec_btpwr(btcoexist, NORMAL_EXEC, 0);
+		halbtc8192e2ant_tdma_duration_adjust(btcoexist, false, true, 3);
+	} else if ((btrssi_state == BTC_RSSI_STATE_MEDIUM) ||
+		   (btrssi_state == BTC_RSSI_STATE_STAY_MEDIUM)) {
+		halbtc8192e2ant_dec_btpwr(btcoexist, NORMAL_EXEC, 2);
+		halbtc8192e2ant_tdma_duration_adjust(btcoexist, false, false,
+						     3);
+	} else if ((btrssi_state == BTC_RSSI_STATE_HIGH) ||
+		   (btrssi_state == BTC_RSSI_STATE_STAY_HIGH)) {
+		halbtc8192e2ant_dec_btpwr(btcoexist, NORMAL_EXEC, 4);
+		halbtc8192e2ant_tdma_duration_adjust(btcoexist, false, false,
+						     3);
+	}
+
+	/* sw mechanism	*/
+	if (BTC_WIFI_BW_HT40 == wifi_bw) {
+		if ((wifirssi_state == BTC_RSSI_STATE_HIGH) ||
+		    (wifirssi_state == BTC_RSSI_STATE_STAY_HIGH)) {
+			halbtc_sw_mechanism1(btcoexist, true, false,
+					     false, false);
+			halbtc_sw_mechanism2(btcoexist, true, false,
+					     false, 0x18);
+		} else {
+			halbtc_sw_mechanism1(btcoexist, true, false,
+					     false, false);
+			halbtc_sw_mechanism2(btcoexist, false, false,
+					     false, 0x18);
+		}
+	} else {
+		if ((wifirssi_state == BTC_RSSI_STATE_HIGH) ||
+		    (wifirssi_state == BTC_RSSI_STATE_STAY_HIGH)) {
+			halbtc_sw_mechanism1(btcoexist, false, false,
+					     false, false);
+			halbtc_sw_mechanism2(btcoexist, true, false,
+					     false, 0x18);
+		} else {
+			halbtc_sw_mechanism1(btcoexist, false, false,
+					     false, false);
+			halbtc_sw_mechanism2(btcoexist, false, false,
+					     false, 0x18);
+		}
+	}
+}
+
+static void halbtc8192e2ant_action_pan_edr_hid(struct btc_coexist *btcoexist)
+{
+	u8 wifirssi_state, btrssi_state = BTC_RSSI_STATE_HIGH;
+	u32 wifi_bw;
+
+	wifirssi_state = halbtc8192e2ant_wifirssi_state(btcoexist, 0, 2, 15, 0);
+	btrssi_state = halbtc8192e2ant_btrssi_state(3, 34, 42);
+
+	btcoexist->btc_get(btcoexist, BTC_GET_U4_WIFI_BW, &wifi_bw);
+
+	halbtc8192e2ant_switch_sstype(btcoexist, NORMAL_EXEC, 1);
+	halbtc8192e2ant_limited_rx(btcoexist, NORMAL_EXEC, false, false, 0x8);
+
+	halbtc8192e2ant_fw_dac_swinglvl(btcoexist, NORMAL_EXEC, 6);
+
+	halbtc_coex_table_with_type(btcoexist, NORMAL_EXEC, 3);
+
+	if ((btrssi_state == BTC_RSSI_STATE_LOW) ||
+	    (btrssi_state == BTC_RSSI_STATE_STAY_LOW)) {
+		halbtc8192e2ant_dec_btpwr(btcoexist, NORMAL_EXEC, 0);
+		halbtc8192e2ant_ps_tdma(btcoexist, NORMAL_EXEC, true, 14);
+	} else if ((btrssi_state == BTC_RSSI_STATE_MEDIUM) ||
+		   (btrssi_state == BTC_RSSI_STATE_STAY_MEDIUM)) {
+		halbtc8192e2ant_dec_btpwr(btcoexist, NORMAL_EXEC, 2);
+		halbtc8192e2ant_ps_tdma(btcoexist, NORMAL_EXEC, true, 10);
+	} else if ((btrssi_state == BTC_RSSI_STATE_HIGH) ||
+		   (btrssi_state == BTC_RSSI_STATE_STAY_HIGH)) {
+		halbtc8192e2ant_dec_btpwr(btcoexist, NORMAL_EXEC, 4);
+		halbtc8192e2ant_ps_tdma(btcoexist, NORMAL_EXEC, true, 10);
+	}
+
+	/* sw mechanism */
+	if (BTC_WIFI_BW_HT40 == wifi_bw) {
+		if ((wifirssi_state == BTC_RSSI_STATE_HIGH) ||
+		    (wifirssi_state == BTC_RSSI_STATE_STAY_HIGH)) {
+			halbtc_sw_mechanism1(btcoexist, true, true,
+					     false, false);
+			halbtc_sw_mechanism2(btcoexist, true, false,
+					     false, 0x18);
+		} else {
+			halbtc_sw_mechanism1(btcoexist, true, true,
+					     false, false);
+			halbtc_sw_mechanism2(btcoexist, false, false,
+					     false, 0x18);
+		}
+	} else {
+		if ((wifirssi_state == BTC_RSSI_STATE_HIGH) ||
+		    (wifirssi_state == BTC_RSSI_STATE_STAY_HIGH)) {
+			halbtc_sw_mechanism1(btcoexist, false, true,
+					     false, false);
+			halbtc_sw_mechanism2(btcoexist, true, false,
+					     false, 0x18);
+		} else {
+			halbtc_sw_mechanism1(btcoexist, false, true,
+					     false, false);
+			halbtc_sw_mechanism2(btcoexist, false, false,
+					     false, 0x18);
+		}
+	}
+}
+
+/* HID+A2DP+PAN(EDR) */
+static void action_hid_a2dp_pan_edr(struct btc_coexist *btcoexist)
+{
+	u8 wifirssi_state, btrssi_state = BTC_RSSI_STATE_HIGH;
+	u32 wifi_bw;
+
+	wifirssi_state = halbtc8192e2ant_wifirssi_state(btcoexist, 0, 2, 15, 0);
+	btrssi_state = halbtc8192e2ant_btrssi_state(3, 34, 42);
+
+	halbtc8192e2ant_switch_sstype(btcoexist, NORMAL_EXEC, 1);
+	halbtc8192e2ant_limited_rx(btcoexist, NORMAL_EXEC, false, false, 0x8);
+
+	halbtc8192e2ant_fw_dac_swinglvl(btcoexist, NORMAL_EXEC, 6);
+
+	btcoexist->btc_get(btcoexist, BTC_GET_U4_WIFI_BW, &wifi_bw);
+
+	halbtc_coex_table_with_type(btcoexist, NORMAL_EXEC, 3);
+
+	if ((btrssi_state == BTC_RSSI_STATE_LOW) ||
+	    (btrssi_state == BTC_RSSI_STATE_STAY_LOW)) {
+		halbtc8192e2ant_dec_btpwr(btcoexist, NORMAL_EXEC, 0);
+		halbtc8192e2ant_tdma_duration_adjust(btcoexist, true, true, 3);
+	} else if ((btrssi_state == BTC_RSSI_STATE_MEDIUM) ||
+		   (btrssi_state == BTC_RSSI_STATE_STAY_MEDIUM)) {
+		halbtc8192e2ant_dec_btpwr(btcoexist, NORMAL_EXEC, 2);
+		halbtc8192e2ant_tdma_duration_adjust(btcoexist, true, false, 3);
+	} else if ((btrssi_state == BTC_RSSI_STATE_HIGH) ||
+		   (btrssi_state == BTC_RSSI_STATE_STAY_HIGH)) {
+		halbtc8192e2ant_dec_btpwr(btcoexist, NORMAL_EXEC, 4);
+		halbtc8192e2ant_tdma_duration_adjust(btcoexist, true, false, 3);
+	}
+
+	/* sw mechanism */
+	if (BTC_WIFI_BW_HT40 == wifi_bw) {
+		if ((wifirssi_state == BTC_RSSI_STATE_HIGH) ||
+		    (wifirssi_state == BTC_RSSI_STATE_STAY_HIGH)) {
+			halbtc_sw_mechanism1(btcoexist, true, true,
+					     false, false);
+			halbtc_sw_mechanism2(btcoexist, true, false,
+					     false, 0x18);
+		} else {
+			halbtc_sw_mechanism1(btcoexist, true, true,
+					     false, false);
+			halbtc_sw_mechanism2(btcoexist, false, false,
+					     false, 0x18);
+		}
+	} else {
+		if ((wifirssi_state == BTC_RSSI_STATE_HIGH) ||
+		    (wifirssi_state == BTC_RSSI_STATE_STAY_HIGH)) {
+			halbtc_sw_mechanism1(btcoexist, false, true,
+					     false, false);
+			halbtc_sw_mechanism2(btcoexist, true, false,
+					     false, 0x18);
+		} else {
+			halbtc_sw_mechanism1(btcoexist, false, true,
+					     false, false);
+			halbtc_sw_mechanism2(btcoexist, false, false,
+					     false, 0x18);
+		}
+	}
+}
+
+static void halbtc8192e2ant_action_hid_a2dp(struct btc_coexist *btcoexist)
+{
+	u8 wifirssi_state, btrssi_state = BTC_RSSI_STATE_HIGH;
+	u32 wifi_bw;
+
+	wifirssi_state = halbtc8192e2ant_wifirssi_state(btcoexist, 0, 2, 15, 0);
+	btrssi_state = halbtc8192e2ant_btrssi_state(3, 34, 42);
+
+	halbtc8192e2ant_switch_sstype(btcoexist, NORMAL_EXEC, 1);
+	halbtc8192e2ant_limited_rx(btcoexist, NORMAL_EXEC, false, false, 0x8);
+
+	btcoexist->btc_get(btcoexist, BTC_GET_U4_WIFI_BW, &wifi_bw);
+
+	halbtc_coex_table_with_type(btcoexist, NORMAL_EXEC, 3);
+
+	if ((btrssi_state == BTC_RSSI_STATE_LOW) ||
+	    (btrssi_state == BTC_RSSI_STATE_STAY_LOW)) {
+		halbtc8192e2ant_dec_btpwr(btcoexist, NORMAL_EXEC, 0);
+		halbtc8192e2ant_tdma_duration_adjust(btcoexist, true, true, 2);
+	} else if ((btrssi_state == BTC_RSSI_STATE_MEDIUM) ||
+		   (btrssi_state == BTC_RSSI_STATE_STAY_MEDIUM))	{
+		halbtc8192e2ant_dec_btpwr(btcoexist, NORMAL_EXEC, 2);
+		halbtc8192e2ant_tdma_duration_adjust(btcoexist, true, false, 2);
+	} else if ((btrssi_state == BTC_RSSI_STATE_HIGH) ||
+		   (btrssi_state == BTC_RSSI_STATE_STAY_HIGH)) {
+		halbtc8192e2ant_dec_btpwr(btcoexist, NORMAL_EXEC, 4);
+		halbtc8192e2ant_tdma_duration_adjust(btcoexist, true, false, 2);
+	}
+
+	/* sw mechanism */
+	if (BTC_WIFI_BW_HT40 == wifi_bw) {
+		if ((wifirssi_state == BTC_RSSI_STATE_HIGH) ||
+		    (wifirssi_state == BTC_RSSI_STATE_STAY_HIGH)) {
+			halbtc_sw_mechanism1(btcoexist, true, true,
+					     false, false);
+			halbtc_sw_mechanism2(btcoexist, true, false,
+					     false, 0x18);
+		} else {
+			halbtc_sw_mechanism1(btcoexist, true, true,
+					     false, false);
+			halbtc_sw_mechanism2(btcoexist, false, false,
+					     false, 0x18);
+		}
+	} else {
+		if ((wifirssi_state == BTC_RSSI_STATE_HIGH) ||
+		    (wifirssi_state == BTC_RSSI_STATE_STAY_HIGH)) {
+			halbtc_sw_mechanism1(btcoexist, false, true,
+					     false, false);
+			halbtc_sw_mechanism2(btcoexist, true, false,
+					     false, 0x18);
+		} else {
+			halbtc_sw_mechanism1(btcoexist, false, true,
+					     false, false);
+			halbtc_sw_mechanism2(btcoexist, false, false,
+					     false, 0x18);
+		}
+	}
+}
+
+static void halbtc8192e2ant_run_coexist_mechanism(struct btc_coexist *btcoexist)
+{
+	u8 algorithm = 0;
+
+	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+		  "[BTCoex], RunCoexistMechanism() ===>\n");
+
+	if (btcoexist->manual_control) {
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+			  "[BTCoex], return for Manual CTRL <===\n");
+		return;
+	}
+
+	if (coex_sta->under_ips) {
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+			  "[BTCoex], wifi is under IPS !!!\n");
+		return;
+	}
+
+	algorithm = halbtc8192e2ant_action_algorithm(btcoexist);
+	if (coex_sta->c2h_bt_inquiry_page &&
+	    (BT_8192E_2ANT_COEX_ALGO_PANHS != algorithm)) {
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+			  "[BTCoex], BT is under inquiry/page scan !!\n");
+		halbtc8192e2ant_action_bt_inquiry(btcoexist);
+		return;
+	}
+
+	coex_dm->cur_algorithm = algorithm;
+	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+		  "[BTCoex], Algorithm = %d\n", coex_dm->cur_algorithm);
+
+	if (halbtc8192e2ant_is_common_action(btcoexist)) {
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+			  "[BTCoex], Action 2-Ant common.\n");
+		coex_dm->auto_tdma_adjust = false;
+	} else {
+		if (coex_dm->cur_algorithm != coex_dm->pre_algorithm) {
+			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+				  "[BTCoex] preAlgorithm =%d, curAlgorithm =%d\n",
+				  coex_dm->pre_algorithm,
+				  coex_dm->cur_algorithm);
+			coex_dm->auto_tdma_adjust = false;
+		}
+		switch (coex_dm->cur_algorithm) {
+		case BT_8192E_2ANT_COEX_ALGO_SCO:
+			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+				  "Action 2-Ant, algorithm = SCO.\n");
+			halbtc8192e2ant_action_sco(btcoexist);
+			break;
+		case BT_8192E_2ANT_COEX_ALGO_SCO_PAN:
+			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+				  "Action 2-Ant, algorithm = SCO+PAN(EDR).\n");
+			halbtc8192e2ant_action_sco_pan(btcoexist);
+			break;
+		case BT_8192E_2ANT_COEX_ALGO_HID:
+			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+				  "Action 2-Ant, algorithm = HID.\n");
+			halbtc8192e2ant_action_hid(btcoexist);
+			break;
+		case BT_8192E_2ANT_COEX_ALGO_A2DP:
+			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+				  "Action 2-Ant, algorithm = A2DP.\n");
+			halbtc8192e2ant_action_a2dp(btcoexist);
+			break;
+		case BT_8192E_2ANT_COEX_ALGO_A2DP_PANHS:
+			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+				  "Action 2-Ant, algorithm = A2DP+PAN(HS).\n");
+			halbtc8192e2ant_action_a2dp_pan_hs(btcoexist);
+			break;
+		case BT_8192E_2ANT_COEX_ALGO_PANEDR:
+			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+				  "Action 2-Ant, algorithm = PAN(EDR).\n");
+			halbtc8192e2ant_action_pan_edr(btcoexist);
+			break;
+		case BT_8192E_2ANT_COEX_ALGO_PANHS:
+			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+				  "Action 2-Ant, algorithm = HS mode.\n");
+			halbtc8192e2ant_action_pan_hs(btcoexist);
+			break;
+		case BT_8192E_2ANT_COEX_ALGO_PANEDR_A2DP:
+			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+				  "Action 2-Ant, algorithm = PAN+A2DP.\n");
+			halbtc8192e2ant_action_pan_edr_a2dp(btcoexist);
+			break;
+		case BT_8192E_2ANT_COEX_ALGO_PANEDR_HID:
+			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+				  "Action 2-Ant, algorithm = PAN(EDR)+HID.\n");
+			halbtc8192e2ant_action_pan_edr_hid(btcoexist);
+			break;
+		case BT_8192E_2ANT_COEX_ALGO_HID_A2DP_PANEDR:
+			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+				  "Action 2-Ant, algorithm = HID+A2DP+PAN.\n");
+			action_hid_a2dp_pan_edr(btcoexist);
+			break;
+		case BT_8192E_2ANT_COEX_ALGO_HID_A2DP:
+			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+				  "Action 2-Ant, algorithm = HID+A2DP.\n");
+			halbtc8192e2ant_action_hid_a2dp(btcoexist);
+			break;
+		default:
+			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+				  "Action 2-Ant, algorithm = unknown!!\n");
+			/* halbtc8192e2ant_coex_alloff(btcoexist); */
+			break;
+		}
+		coex_dm->pre_algorithm = coex_dm->cur_algorithm;
+	}
+}
+
+static void halbtc8192e2ant_init_hwconfig(struct btc_coexist *btcoexist,
+					  bool backup)
+{
+	u16 u16tmp = 0;
+	u8 u8tmp = 0;
+
+	BTC_PRINT(BTC_MSG_INTERFACE, INTF_INIT,
+		  "[BTCoex], 2Ant Init HW Config!!\n");
+
+	if (backup) {
+		/* backup rf 0x1e value */
+		coex_dm->bt_rf0x1e_backup =
+			btcoexist->btc_get_rf_reg(btcoexist, BTC_RF_A,
+						  0x1e, 0xfffff);
+
+		coex_dm->backup_arfr_cnt1 = btcoexist->btc_read_4byte(btcoexist,
+								      0x430);
+		coex_dm->backup_arfr_cnt2 = btcoexist->btc_read_4byte(btcoexist,
+								     0x434);
+		coex_dm->backup_retrylimit = btcoexist->btc_read_2byte(
+								    btcoexist,
+								    0x42a);
+		coex_dm->backup_ampdu_maxtime = btcoexist->btc_read_1byte(
+								    btcoexist,
+								    0x456);
+	}
+
+	/* antenna sw ctrl to bt */
+	btcoexist->btc_write_1byte(btcoexist, 0x4f, 0x6);
+	btcoexist->btc_write_1byte(btcoexist, 0x944, 0x24);
+	btcoexist->btc_write_4byte(btcoexist, 0x930, 0x700700);
+	btcoexist->btc_write_1byte(btcoexist, 0x92c, 0x20);
+	if (btcoexist->chip_interface == BTC_INTF_USB)
+		btcoexist->btc_write_4byte(btcoexist, 0x64, 0x30430004);
+	else
+		btcoexist->btc_write_4byte(btcoexist, 0x64, 0x30030004);
+
+	halbtc_coex_table_with_type(btcoexist, FORCE_EXEC, 0);
+
+	/* antenna switch control parameter */
+	btcoexist->btc_write_4byte(btcoexist, 0x858, 0x55555555);
+
+	/* coex parameters */
+	btcoexist->btc_write_1byte(btcoexist, 0x778, 0x3);
+	/* 0x790[5:0] = 0x5 */
+	u8tmp = btcoexist->btc_read_1byte(btcoexist, 0x790);
+	u8tmp &= 0xc0;
+	u8tmp |= 0x5;
+	btcoexist->btc_write_1byte(btcoexist, 0x790, u8tmp);
+
+	/* enable counter statistics */
+	btcoexist->btc_write_1byte(btcoexist, 0x76e, 0x4);
+
+	/* enable PTA */
+	btcoexist->btc_write_1byte(btcoexist, 0x40, 0x20);
+	/* enable mailbox interface */
+	u16tmp = btcoexist->btc_read_2byte(btcoexist, 0x40);
+	u16tmp |= BIT(9);
+	btcoexist->btc_write_2byte(btcoexist, 0x40, u16tmp);
+
+	/* enable PTA I2C mailbox  */
+	u8tmp = btcoexist->btc_read_1byte(btcoexist, 0x101);
+	u8tmp |= BIT(4);
+	btcoexist->btc_write_1byte(btcoexist, 0x101, u8tmp);
+
+	/* enable bt clock when wifi is disabled. */
+	u8tmp = btcoexist->btc_read_1byte(btcoexist, 0x93);
+	u8tmp |= BIT(0);
+	btcoexist->btc_write_1byte(btcoexist, 0x93, u8tmp);
+	/* enable bt clock when suspend. */
+	u8tmp = btcoexist->btc_read_1byte(btcoexist, 0x7);
+	u8tmp |= BIT(0);
+	btcoexist->btc_write_1byte(btcoexist, 0x7, u8tmp);
+}
+
+/*************************************************************
+ *   work around function start with wa_halbtc8192e2ant_
+ *************************************************************/
+
+/************************************************************
+ *   extern function start with EXhalbtc8192e2ant_
+ ************************************************************/
+
+void ex_halbtc8192e2ant_init_hwconfig(struct btc_coexist *btcoexist)
+{
+	halbtc8192e2ant_init_hwconfig(btcoexist, true);
+}
+
+void ex_halbtc8192e2ant_init_coex_dm(struct btc_coexist *btcoexist)
+{
+	BTC_PRINT(BTC_MSG_INTERFACE, INTF_INIT,
+		  "[BTCoex], Coex Mechanism Init!!\n");
+	halbtc8192e2ant_init_coex_dm(btcoexist);
+}
+
+void ex_halbtc8192e2ant_display_coex_info(struct btc_coexist *btcoexist)
+{
+	struct btc_board_info *board_info = &btcoexist->board_info;
+	struct btc_stack_info *stack_info = &btcoexist->stack_info;
+	u8 *cli_buf = btcoexist->cli_buf;
+	u8 u8tmp[4], i, bt_info_ext, ps_tdma_case = 0;
+	u16 u16tmp[4];
+	u32 u32tmp[4];
+	bool roam = false, scan = false, link = false, wifi_under_5g = false;
+	bool bt_hson = false, wifi_busy = false;
+	int wifirssi = 0, bt_hs_rssi = 0;
+	u32 wifi_bw, wifi_traffic_dir;
+	u8 wifi_dot11_chnl, wifi_hs_chnl;
+	u32 fw_ver = 0, bt_patch_ver = 0;
+
+	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE,
+		   "\r\n ============[BT Coexist info] ============");
+	CL_PRINTF(cli_buf);
+
+	if (btcoexist->manual_control) {
+		CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE,
+			   "\r\n ===========[Under Manual Control] ===========");
+		CL_PRINTF(cli_buf);
+		CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE,
+			   "\r\n ==========================================");
+		CL_PRINTF(cli_buf);
+	}
+
+	if (!board_info->bt_exist) {
+		CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n BT not exists !!!");
+		CL_PRINTF(cli_buf);
+		return;
+	}
+
+	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE,
+		   "\r\n %-35s = %d/ %d ", "Ant PG number/ Ant mechanism: ",
+		   board_info->pg_ant_num, board_info->btdm_ant_num);
+	CL_PRINTF(cli_buf);
+
+	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = %s / %d",
+		   "BT stack/ hci ext ver",
+		   ((stack_info->profile_notified) ? "Yes" : "No"),
+		   stack_info->hci_version);
+	CL_PRINTF(cli_buf);
+
+	btcoexist->btc_get(btcoexist, BTC_GET_U4_BT_PATCH_VER, &bt_patch_ver);
+	btcoexist->btc_get(btcoexist, BTC_GET_U4_WIFI_FW_VER, &fw_ver);
+	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE,
+		   "\r\n %-35s = %d_%d/ 0x%x/ 0x%x(%d)",
+		   "CoexVer/ FwVer/ PatchVer",
+		   glcoex_ver_date_8192e_2ant, glcoex_ver_8192e_2ant,
+		   fw_ver, bt_patch_ver, bt_patch_ver);
+	CL_PRINTF(cli_buf);
+
+	btcoexist->btc_get(btcoexist, BTC_GET_BL_HS_OPERATION, &bt_hson);
+	btcoexist->btc_get(btcoexist, BTC_GET_U1_WIFI_DOT11_CHNL,
+			   &wifi_dot11_chnl);
+	btcoexist->btc_get(btcoexist, BTC_GET_U1_WIFI_HS_CHNL, &wifi_hs_chnl);
+	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = %d / %d(%d)",
+		   "Dot11 channel / HsMode(HsChnl)",
+		   wifi_dot11_chnl, bt_hson, wifi_hs_chnl);
+	CL_PRINTF(cli_buf);
+
+	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = %02x %02x %02x ",
+		   "H2C Wifi inform bt chnl Info", coex_dm->wifi_chnl_info[0],
+		   coex_dm->wifi_chnl_info[1], coex_dm->wifi_chnl_info[2]);
+	CL_PRINTF(cli_buf);
+
+	btcoexist->btc_get(btcoexist, BTC_GET_S4_WIFI_RSSI, &wifirssi);
+	btcoexist->btc_get(btcoexist, BTC_GET_S4_HS_RSSI, &bt_hs_rssi);
+	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = %d/ %d",
+		   "Wifi rssi/ HS rssi", wifirssi, bt_hs_rssi);
+	CL_PRINTF(cli_buf);
+
+	btcoexist->btc_get(btcoexist, BTC_GET_BL_WIFI_SCAN, &scan);
+	btcoexist->btc_get(btcoexist, BTC_GET_BL_WIFI_LINK, &link);
+	btcoexist->btc_get(btcoexist, BTC_GET_BL_WIFI_ROAM, &roam);
+	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = %d/ %d/ %d ",
+		   "Wifi link/ roam/ scan", link, roam, scan);
+	CL_PRINTF(cli_buf);
+
+	btcoexist->btc_get(btcoexist, BTC_GET_BL_WIFI_UNDER_5G, &wifi_under_5g);
+	btcoexist->btc_get(btcoexist, BTC_GET_U4_WIFI_BW, &wifi_bw);
+	btcoexist->btc_get(btcoexist, BTC_GET_BL_WIFI_BUSY, &wifi_busy);
+	btcoexist->btc_get(btcoexist, BTC_GET_U4_WIFI_TRAFFIC_DIRECTION,
+			   &wifi_traffic_dir);
+	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = %s / %s/ %s ",
+		   "Wifi status", (wifi_under_5g ? "5G" : "2.4G"),
+		   ((BTC_WIFI_BW_LEGACY == wifi_bw) ? "Legacy" :
+			(((BTC_WIFI_BW_HT40 == wifi_bw) ? "HT40" : "HT20"))),
+		   ((!wifi_busy) ? "idle" :
+			((BTC_WIFI_TRAFFIC_TX == wifi_traffic_dir) ?
+				"uplink" : "downlink")));
+	CL_PRINTF(cli_buf);
+
+	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = [%s/ %d/ %d] ",
+		   "BT [status/ rssi/ retryCnt]",
+		   ((btcoexist->bt_info.bt_disabled) ? ("disabled") :
+		    ((coex_sta->c2h_bt_inquiry_page) ?
+		     ("inquiry/page scan") :
+		      ((BT_8192E_2ANT_BT_STATUS_NON_CONNECTED_IDLE ==
+			coex_dm->bt_status) ? "non-connected idle" :
+			 ((BT_8192E_2ANT_BT_STATUS_CONNECTED_IDLE ==
+			   coex_dm->bt_status) ? "connected-idle" : "busy")))),
+		   coex_sta->bt_rssi, coex_sta->bt_retry_cnt);
+	CL_PRINTF(cli_buf);
+
+	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = %d / %d / %d / %d",
+		   "SCO/HID/PAN/A2DP", stack_info->sco_exist,
+		   stack_info->hid_exist, stack_info->pan_exist,
+		   stack_info->a2dp_exist);
+	CL_PRINTF(cli_buf);
+	btcoexist->btc_disp_dbg_msg(btcoexist, BTC_DBG_DISP_BT_LINK_INFO);
+
+	bt_info_ext = coex_sta->bt_info_ext;
+	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = %s",
+		   "BT Info A2DP rate",
+		   (bt_info_ext & BIT(0)) ? "Basic rate" : "EDR rate");
+	CL_PRINTF(cli_buf);
+
+	for (i = 0; i < BT_INFO_SRC_8192E_2ANT_MAX; i++) {
+		if (coex_sta->bt_info_c2h_cnt[i]) {
+			CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE,
+				   "\r\n %-35s = %02x %02x %02x %02x ",
+				   glbt_infosrc8192e2ant[i],
+				   coex_sta->bt_info_c2h[i][0],
+				   coex_sta->bt_info_c2h[i][1],
+				   coex_sta->bt_info_c2h[i][2],
+				   coex_sta->bt_info_c2h[i][3]);
+			CL_PRINTF(cli_buf);
+			CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE,
+				   "%02x %02x %02x(%d)",
+				   coex_sta->bt_info_c2h[i][4],
+				   coex_sta->bt_info_c2h[i][5],
+				   coex_sta->bt_info_c2h[i][6],
+				   coex_sta->bt_info_c2h_cnt[i]);
+			CL_PRINTF(cli_buf);
+		}
+	}
+
+	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = %s/%s",
+		   "PS state, IPS/LPS",
+		   ((coex_sta->under_ips ? "IPS ON" : "IPS OFF")),
+		   ((coex_sta->under_lps ? "LPS ON" : "LPS OFF")));
+	CL_PRINTF(cli_buf);
+	btcoexist->btc_disp_dbg_msg(btcoexist, BTC_DBG_DISP_FW_PWR_MODE_CMD);
+
+	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = 0x%x ", "SS Type",
+		   coex_dm->cur_sstype);
+	CL_PRINTF(cli_buf);
+
+	/* Sw mechanism	*/
+	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s",
+		   "============[Sw mechanism] ============");
+	CL_PRINTF(cli_buf);
+	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = %d/ %d/ %d ",
+		   "SM1[ShRf/ LpRA/ LimDig]", coex_dm->cur_rf_rx_lpf_shrink,
+		   coex_dm->cur_low_penalty_ra, coex_dm->limited_dig);
+	CL_PRINTF(cli_buf);
+	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = %d/ %d/ %d(0x%x) ",
+		   "SM2[AgcT/ AdcB/ SwDacSwing(lvl)]",
+		   coex_dm->cur_agc_table_en, coex_dm->cur_adc_back_off,
+		   coex_dm->cur_dac_swing_on, coex_dm->cur_dac_swing_lvl);
+	CL_PRINTF(cli_buf);
+
+	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = 0x%x ", "Rate Mask",
+		   btcoexist->bt_info.ra_mask);
+	CL_PRINTF(cli_buf);
+
+	/* Fw mechanism	*/
+	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s",
+		   "============[Fw mechanism] ============");
+	CL_PRINTF(cli_buf);
+
+	ps_tdma_case = coex_dm->cur_ps_tdma;
+	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE,
+		   "\r\n %-35s = %02x %02x %02x %02x %02x case-%d (auto:%d)",
+		   "PS TDMA", coex_dm->ps_tdma_para[0],
+		   coex_dm->ps_tdma_para[1], coex_dm->ps_tdma_para[2],
+		   coex_dm->ps_tdma_para[3], coex_dm->ps_tdma_para[4],
+		   ps_tdma_case, coex_dm->auto_tdma_adjust);
+	CL_PRINTF(cli_buf);
+
+	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = %d/ %d ",
+		   "DecBtPwr/ IgnWlanAct",
+		   coex_dm->cur_dec_bt_pwr, coex_dm->cur_ignore_wlan_act);
+	CL_PRINTF(cli_buf);
+
+	/* Hw setting */
+	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s",
+		   "============[Hw setting] ============");
+	CL_PRINTF(cli_buf);
+
+	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = 0x%x",
+		   "RF-A, 0x1e initVal", coex_dm->bt_rf0x1e_backup);
+	CL_PRINTF(cli_buf);
+
+	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = 0x%x/0x%x/0x%x/0x%x",
+		   "backup ARFR1/ARFR2/RL/AMaxTime", coex_dm->backup_arfr_cnt1,
+		   coex_dm->backup_arfr_cnt2, coex_dm->backup_retrylimit,
+		   coex_dm->backup_ampdu_maxtime);
+	CL_PRINTF(cli_buf);
+
+	u32tmp[0] = btcoexist->btc_read_4byte(btcoexist, 0x430);
+	u32tmp[1] = btcoexist->btc_read_4byte(btcoexist, 0x434);
+	u16tmp[0] = btcoexist->btc_read_2byte(btcoexist, 0x42a);
+	u8tmp[0] = btcoexist->btc_read_1byte(btcoexist, 0x456);
+	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = 0x%x/0x%x/0x%x/0x%x",
+		   "0x430/0x434/0x42a/0x456",
+		   u32tmp[0], u32tmp[1], u16tmp[0], u8tmp[0]);
+	CL_PRINTF(cli_buf);
+
+	u32tmp[0] = btcoexist->btc_read_4byte(btcoexist, 0xc04);
+	u32tmp[1] = btcoexist->btc_read_4byte(btcoexist, 0xd04);
+	u32tmp[2] = btcoexist->btc_read_4byte(btcoexist, 0x90c);
+	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = 0x%x/ 0x%x/ 0x%x",
+		   "0xc04/ 0xd04/ 0x90c", u32tmp[0], u32tmp[1], u32tmp[2]);
+	CL_PRINTF(cli_buf);
+
+	u8tmp[0] = btcoexist->btc_read_1byte(btcoexist, 0x778);
+	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = 0x%x", "0x778",
+		   u8tmp[0]);
+	CL_PRINTF(cli_buf);
+
+	u8tmp[0] = btcoexist->btc_read_1byte(btcoexist, 0x92c);
+	u32tmp[0] = btcoexist->btc_read_4byte(btcoexist, 0x930);
+	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = 0x%x/ 0x%x",
+		   "0x92c/ 0x930", (u8tmp[0]), u32tmp[0]);
+	CL_PRINTF(cli_buf);
+
+	u8tmp[0] = btcoexist->btc_read_1byte(btcoexist, 0x40);
+	u8tmp[1] = btcoexist->btc_read_1byte(btcoexist, 0x4f);
+	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = 0x%x/ 0x%x",
+		   "0x40/ 0x4f", u8tmp[0], u8tmp[1]);
+	CL_PRINTF(cli_buf);
+
+	u32tmp[0] = btcoexist->btc_read_4byte(btcoexist, 0x550);
+	u8tmp[0] = btcoexist->btc_read_1byte(btcoexist, 0x522);
+	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = 0x%x/ 0x%x",
+		   "0x550(bcn ctrl)/0x522", u32tmp[0], u8tmp[0]);
+	CL_PRINTF(cli_buf);
+
+	u32tmp[0] = btcoexist->btc_read_4byte(btcoexist, 0xc50);
+	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = 0x%x", "0xc50(dig)",
+		   u32tmp[0]);
+	CL_PRINTF(cli_buf);
+
+	u32tmp[0] = btcoexist->btc_read_4byte(btcoexist, 0x6c0);
+	u32tmp[1] = btcoexist->btc_read_4byte(btcoexist, 0x6c4);
+	u32tmp[2] = btcoexist->btc_read_4byte(btcoexist, 0x6c8);
+	u8tmp[0] = btcoexist->btc_read_1byte(btcoexist, 0x6cc);
+	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE,
+		   "\r\n %-35s = 0x%x/ 0x%x/ 0x%x/ 0x%x",
+		   "0x6c0/0x6c4/0x6c8/0x6cc(coexTable)",
+		   u32tmp[0], u32tmp[1], u32tmp[2], u8tmp[0]);
+	CL_PRINTF(cli_buf);
+
+	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = %d/ %d",
+		   "0x770(hp rx[31:16]/tx[15:0])",
+		   coex_sta->high_priority_rx, coex_sta->high_priority_tx);
+	CL_PRINTF(cli_buf);
+	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = %d/ %d",
+		   "0x774(lp rx[31:16]/tx[15:0])",
+		   coex_sta->low_priority_rx, coex_sta->low_priority_tx);
+	CL_PRINTF(cli_buf);
+#if (BT_AUTO_REPORT_ONLY_8192E_2ANT == 1)
+	halbtc8192e2ant_monitor_bt_ctr(btcoexist);
+#endif
+	btcoexist->btc_disp_dbg_msg(btcoexist, BTC_DBG_DISP_COEX_STATISTICS);
+}
+
+void ex_halbtc8192e2ant_ips_notify(struct btc_coexist *btcoexist, u8 type)
+{
+	if (BTC_IPS_ENTER == type) {
+		BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
+			  "[BTCoex], IPS ENTER notify\n");
+		coex_sta->under_ips = true;
+		halbtc8192e2ant_coex_alloff(btcoexist);
+	} else if (BTC_IPS_LEAVE == type) {
+		BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
+			  "[BTCoex], IPS LEAVE notify\n");
+		coex_sta->under_ips = false;
+	}
+}
+
+void ex_halbtc8192e2ant_lps_notify(struct btc_coexist *btcoexist, u8 type)
+{
+	if (BTC_LPS_ENABLE == type) {
+		BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
+			  "[BTCoex], LPS ENABLE notify\n");
+		coex_sta->under_lps = true;
+	} else if (BTC_LPS_DISABLE == type) {
+		BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
+			  "[BTCoex], LPS DISABLE notify\n");
+		coex_sta->under_lps = false;
+	}
+}
+
+void ex_halbtc8192e2ant_scan_notify(struct btc_coexist *btcoexist, u8 type)
+{
+	if (BTC_SCAN_START == type)
+		BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
+			  "[BTCoex], SCAN START notify\n");
+	else if (BTC_SCAN_FINISH == type)
+		BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
+			  "[BTCoex], SCAN FINISH notify\n");
+}
+
+void ex_halbtc8192e2ant_connect_notify(struct btc_coexist *btcoexist, u8 type)
+{
+	if (BTC_ASSOCIATE_START == type)
+		BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
+			  "[BTCoex], CONNECT START notify\n");
+	else if (BTC_ASSOCIATE_FINISH == type)
+		BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
+			  "[BTCoex], CONNECT FINISH notify\n");
+}
+
+void ex_halbtc8192e2ant_media_status_notify(struct btc_coexist *btcoexist,
+					    u8 type)
+{
+	u8 h2c_parameter[3] = {0};
+	u32 wifi_bw;
+	u8 wifi_center_chnl;
+
+	if (btcoexist->manual_control ||
+	    btcoexist->stop_coex_dm ||
+	    btcoexist->bt_info.bt_disabled)
+		return;
+
+	if (BTC_MEDIA_CONNECT == type)
+		BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
+			  "[BTCoex], MEDIA connect notify\n");
+	else
+		BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
+			  "[BTCoex], MEDIA disconnect notify\n");
+
+	/* only 2.4G we need to inform bt the chnl mask */
+	btcoexist->btc_get(btcoexist, BTC_GET_U1_WIFI_CENTRAL_CHNL,
+			   &wifi_center_chnl);
+	if ((BTC_MEDIA_CONNECT == type) &&
+	    (wifi_center_chnl <= 14)) {
+		h2c_parameter[0] = 0x1;
+		h2c_parameter[1] = wifi_center_chnl;
+		btcoexist->btc_get(btcoexist, BTC_GET_U4_WIFI_BW, &wifi_bw);
+		if (BTC_WIFI_BW_HT40 == wifi_bw)
+			h2c_parameter[2] = 0x30;
+		else
+			h2c_parameter[2] = 0x20;
+	}
+
+	coex_dm->wifi_chnl_info[0] = h2c_parameter[0];
+	coex_dm->wifi_chnl_info[1] = h2c_parameter[1];
+	coex_dm->wifi_chnl_info[2] = h2c_parameter[2];
+
+	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_EXEC,
+		  "[BTCoex], FW write 0x66 = 0x%x\n",
+		  h2c_parameter[0] << 16 | h2c_parameter[1] << 8 |
+		  h2c_parameter[2]);
+
+	btcoexist->btc_fill_h2c(btcoexist, 0x66, 3, h2c_parameter);
+}
+
+void ex_halbtc8192e2ant_special_packet_notify(struct btc_coexist *btcoexist,
+					      u8 type)
+{
+	if (type == BTC_PACKET_DHCP)
+		BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
+			  "[BTCoex], DHCP Packet notify\n");
+}
+
+void ex_halbtc8192e2ant_bt_info_notify(struct btc_coexist *btcoexist,
+				       u8 *tmp_buf, u8 length)
+{
+	u8 bt_info = 0;
+	u8 i, rspsource = 0;
+	bool bt_busy = false, limited_dig = false;
+	bool wifi_connected = false;
+
+	coex_sta->c2h_bt_info_req_sent = false;
+
+	rspsource = tmp_buf[0] & 0xf;
+	if (rspsource >= BT_INFO_SRC_8192E_2ANT_MAX)
+		rspsource = BT_INFO_SRC_8192E_2ANT_WIFI_FW;
+	coex_sta->bt_info_c2h_cnt[rspsource]++;
+
+	BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
+		  "[BTCoex], Bt info[%d], length =%d, hex data =[",
+		  rspsource, length);
+	for (i = 0; i < length; i++) {
+		coex_sta->bt_info_c2h[rspsource][i] = tmp_buf[i];
+		if (i == 1)
+			bt_info = tmp_buf[i];
+		if (i == length-1)
+			BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
+				  "0x%02x]\n", tmp_buf[i]);
+		else
+			BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
+				  "0x%02x, ", tmp_buf[i]);
+	}
+
+	if (BT_INFO_SRC_8192E_2ANT_WIFI_FW != rspsource) {
+		coex_sta->bt_retry_cnt =	/* [3:0] */
+			coex_sta->bt_info_c2h[rspsource][2] & 0xf;
+
+		coex_sta->bt_rssi =
+			coex_sta->bt_info_c2h[rspsource][3] * 2 + 10;
+
+		coex_sta->bt_info_ext =
+			coex_sta->bt_info_c2h[rspsource][4];
+
+		/* Here we need to resend some wifi info to BT
+		 * because bt is reset and loss of the info. */
+		if ((coex_sta->bt_info_ext & BIT(1))) {
+			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+				  "bit1, send wifi BW&Chnl to BT!!\n");
+			btcoexist->btc_get(btcoexist, BTC_GET_BL_WIFI_CONNECTED,
+					   &wifi_connected);
+			if (wifi_connected)
+				ex_halbtc8192e2ant_media_status_notify(
+							btcoexist,
+							BTC_MEDIA_CONNECT);
+			else
+				ex_halbtc8192e2ant_media_status_notify(
+							btcoexist,
+							BTC_MEDIA_DISCONNECT);
+		}
+
+		if ((coex_sta->bt_info_ext & BIT(3))) {
+			if (!btcoexist->manual_control &&
+			    !btcoexist->stop_coex_dm) {
+				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+					  "bit3, BT NOT ignore Wlan active!\n");
+				halbtc8192e2ant_ignorewlanact(btcoexist,
+							      FORCE_EXEC,
+							      false);
+			}
+		} else {
+			/* BT already NOT ignore Wlan active,
+			 * do nothing here. */
+		}
+
+#if (BT_AUTO_REPORT_ONLY_8192E_2ANT == 0)
+		if ((coex_sta->bt_info_ext & BIT(4))) {
+			/* BT auto report already enabled, do nothing */
+		} else {
+			halbtc8192e2ant_bt_autoreport(btcoexist, FORCE_EXEC,
+						      true);
+		}
+#endif
+	}
+
+	/* check BIT(2) first ==> check if bt is under inquiry or page scan */
+	if (bt_info & BT_INFO_8192E_2ANT_B_INQ_PAGE)
+		coex_sta->c2h_bt_inquiry_page = true;
+	else
+		coex_sta->c2h_bt_inquiry_page = false;
+
+	/* set link exist status */
+	if (!(bt_info&BT_INFO_8192E_2ANT_B_CONNECTION)) {
+		coex_sta->bt_link_exist = false;
+		coex_sta->pan_exist = false;
+		coex_sta->a2dp_exist = false;
+		coex_sta->hid_exist = false;
+		coex_sta->sco_exist = false;
+	} else {/* connection exists */
+		coex_sta->bt_link_exist = true;
+		if (bt_info & BT_INFO_8192E_2ANT_B_FTP)
+			coex_sta->pan_exist = true;
+		else
+			coex_sta->pan_exist = false;
+		if (bt_info & BT_INFO_8192E_2ANT_B_A2DP)
+			coex_sta->a2dp_exist = true;
+		else
+			coex_sta->a2dp_exist = false;
+		if (bt_info & BT_INFO_8192E_2ANT_B_HID)
+			coex_sta->hid_exist = true;
+		else
+			coex_sta->hid_exist = false;
+		if (bt_info & BT_INFO_8192E_2ANT_B_SCO_ESCO)
+			coex_sta->sco_exist = true;
+		else
+			coex_sta->sco_exist = false;
+	}
+
+	halbtc8192e2ant_update_btlink_info(btcoexist);
+
+	if (!(bt_info&BT_INFO_8192E_2ANT_B_CONNECTION)) {
+		coex_dm->bt_status = BT_8192E_2ANT_BT_STATUS_NON_CONNECTED_IDLE;
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+			  "[BTCoex], BT Non-Connected idle!!!\n");
+	} else if (bt_info == BT_INFO_8192E_2ANT_B_CONNECTION) {
+		coex_dm->bt_status = BT_8192E_2ANT_BT_STATUS_CONNECTED_IDLE;
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+			  "[BTCoex], bt_infoNotify(), BT Connected-idle!!!\n");
+	} else if ((bt_info&BT_INFO_8192E_2ANT_B_SCO_ESCO) ||
+		   (bt_info&BT_INFO_8192E_2ANT_B_SCO_BUSY)) {
+		coex_dm->bt_status = BT_8192E_2ANT_BT_STATUS_SCO_BUSY;
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+			  "[BTCoex], bt_infoNotify(), BT SCO busy!!!\n");
+	} else if (bt_info&BT_INFO_8192E_2ANT_B_ACL_BUSY) {
+		coex_dm->bt_status = BT_8192E_2ANT_BT_STATUS_ACL_BUSY;
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+			  "[BTCoex], bt_infoNotify(), BT ACL busy!!!\n");
+	} else {
+		coex_dm->bt_status = BT_8192E_2ANT_BT_STATUS_MAX;
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+			  "[BTCoex]bt_infoNotify(), BT Non-Defined state!!!\n");
+	}
+
+	if ((BT_8192E_2ANT_BT_STATUS_ACL_BUSY == coex_dm->bt_status) ||
+	    (BT_8192E_2ANT_BT_STATUS_SCO_BUSY == coex_dm->bt_status) ||
+	    (BT_8192E_2ANT_BT_STATUS_ACL_SCO_BUSY == coex_dm->bt_status)) {
+		bt_busy = true;
+		limited_dig = true;
+	} else {
+		bt_busy = false;
+		limited_dig = false;
+	}
+
+	btcoexist->btc_set(btcoexist, BTC_SET_BL_BT_TRAFFIC_BUSY, &bt_busy);
+
+	coex_dm->limited_dig = limited_dig;
+	btcoexist->btc_set(btcoexist, BTC_SET_BL_BT_LIMITED_DIG, &limited_dig);
+
+	halbtc8192e2ant_run_coexist_mechanism(btcoexist);
+}
+
+void ex_halbtc8192e2ant_stack_operation_notify(struct btc_coexist *btcoexist,
+					       u8 type)
+{
+}
+
+void ex_halbtc8192e2ant_halt_notify(struct btc_coexist *btcoexist)
+{
+	BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY, "[BTCoex], Halt notify\n");
+
+	halbtc8192e2ant_ignorewlanact(btcoexist, FORCE_EXEC, true);
+	ex_halbtc8192e2ant_media_status_notify(btcoexist, BTC_MEDIA_DISCONNECT);
+}
+
+void ex_halbtc8192e2ant_periodical(struct btc_coexist *btcoexist)
+{
+	static u8 dis_ver_info_cnt;
+	u32 fw_ver = 0, bt_patch_ver = 0;
+	struct btc_board_info *board_info = &btcoexist->board_info;
+	struct btc_stack_info *stack_info = &btcoexist->stack_info;
+
+	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+		  "======================= Periodical =======================\n");
+	if (dis_ver_info_cnt <= 5) {
+		dis_ver_info_cnt += 1;
+		BTC_PRINT(BTC_MSG_INTERFACE, INTF_INIT,
+			  "************************************************\n");
+		BTC_PRINT(BTC_MSG_INTERFACE, INTF_INIT,
+			  "Ant PG Num/ Ant Mech/ Ant Pos = %d/ %d/ %d\n",
+			  board_info->pg_ant_num, board_info->btdm_ant_num,
+			  board_info->btdm_ant_pos);
+		BTC_PRINT(BTC_MSG_INTERFACE, INTF_INIT,
+			  "BT stack/ hci ext ver = %s / %d\n",
+			  ((stack_info->profile_notified) ? "Yes" : "No"),
+			  stack_info->hci_version);
+		btcoexist->btc_get(btcoexist, BTC_GET_U4_BT_PATCH_VER,
+				   &bt_patch_ver);
+		btcoexist->btc_get(btcoexist, BTC_GET_U4_WIFI_FW_VER, &fw_ver);
+		BTC_PRINT(BTC_MSG_INTERFACE, INTF_INIT,
+			  "CoexVer/ FwVer/ PatchVer = %d_%x/ 0x%x/ 0x%x(%d)\n",
+			  glcoex_ver_date_8192e_2ant, glcoex_ver_8192e_2ant,
+			  fw_ver, bt_patch_ver, bt_patch_ver);
+		BTC_PRINT(BTC_MSG_INTERFACE, INTF_INIT,
+			  "************************************************\n");
+	}
+
+#if (BT_AUTO_REPORT_ONLY_8192E_2ANT == 0)
+	halbtc8192e2ant_querybt_info(btcoexist);
+	halbtc8192e2ant_monitor_bt_ctr(btcoexist);
+	halbtc_monitor_bt_enable_disable(btcoexist);
+#else
+	if (halbtc8192e2ant_iswifi_status_changed(btcoexist) ||
+	    coex_dm->auto_tdma_adjust)
+		halbtc8192e2ant_run_coexist_mechanism(btcoexist);
+#endif
+}
diff --git a/drivers/staging/rtl8192ee/btcoexist/halbtc8192e2ant.h b/drivers/staging/rtl8192ee/btcoexist/halbtc8192e2ant.h
new file mode 100644
index 0000000..ece3e10
--- /dev/null
+++ b/drivers/staging/rtl8192ee/btcoexist/halbtc8192e2ant.h
@@ -0,0 +1,161 @@
+/*****************************************************************
+ *   The following is for 8192E 2Ant BT Co-exist definition
+ *****************************************************************/
+#define	BT_AUTO_REPORT_ONLY_8192E_2ANT			0
+
+#define	BT_INFO_8192E_2ANT_B_FTP			BIT(7)
+#define	BT_INFO_8192E_2ANT_B_A2DP			BIT(6)
+#define	BT_INFO_8192E_2ANT_B_HID			BIT(5)
+#define	BT_INFO_8192E_2ANT_B_SCO_BUSY			BIT(4)
+#define	BT_INFO_8192E_2ANT_B_ACL_BUSY			BIT(3)
+#define	BT_INFO_8192E_2ANT_B_INQ_PAGE			BIT(2)
+#define	BT_INFO_8192E_2ANT_B_SCO_ESCO			BIT(1)
+#define	BT_INFO_8192E_2ANT_B_CONNECTION			BIT(0)
+
+#define BTC_RSSI_COEX_THRESH_TOL_8192E_2ANT		2
+
+enum bt_info_src_8192e_2ant {
+	BT_INFO_SRC_8192E_2ANT_WIFI_FW			= 0x0,
+	BT_INFO_SRC_8192E_2ANT_BT_RSP			= 0x1,
+	BT_INFO_SRC_8192E_2ANT_BT_ACTIVE_SEND		= 0x2,
+	BT_INFO_SRC_8192E_2ANT_MAX
+};
+
+enum bt_8192e_2ant_bt_status {
+	BT_8192E_2ANT_BT_STATUS_NON_CONNECTED_IDLE	= 0x0,
+	BT_8192E_2ANT_BT_STATUS_CONNECTED_IDLE		= 0x1,
+	BT_8192E_2ANT_BT_STATUS_INQ_PAGE		= 0x2,
+	BT_8192E_2ANT_BT_STATUS_ACL_BUSY		= 0x3,
+	BT_8192E_2ANT_BT_STATUS_SCO_BUSY		= 0x4,
+	BT_8192E_2ANT_BT_STATUS_ACL_SCO_BUSY		= 0x5,
+	BT_8192E_2ANT_BT_STATUS_MAX
+};
+
+enum bt_8192e_2ant_coex_algo {
+	BT_8192E_2ANT_COEX_ALGO_UNDEFINED		= 0x0,
+	BT_8192E_2ANT_COEX_ALGO_SCO			= 0x1,
+	BT_8192E_2ANT_COEX_ALGO_SCO_PAN			= 0x2,
+	BT_8192E_2ANT_COEX_ALGO_HID			= 0x3,
+	BT_8192E_2ANT_COEX_ALGO_A2DP			= 0x4,
+	BT_8192E_2ANT_COEX_ALGO_A2DP_PANHS		= 0x5,
+	BT_8192E_2ANT_COEX_ALGO_PANEDR			= 0x6,
+	BT_8192E_2ANT_COEX_ALGO_PANHS			= 0x7,
+	BT_8192E_2ANT_COEX_ALGO_PANEDR_A2DP		= 0x8,
+	BT_8192E_2ANT_COEX_ALGO_PANEDR_HID		= 0x9,
+	BT_8192E_2ANT_COEX_ALGO_HID_A2DP_PANEDR		= 0xa,
+	BT_8192E_2ANT_COEX_ALGO_HID_A2DP		= 0xb,
+	BT_8192E_2ANT_COEX_ALGO_MAX			= 0xc
+};
+
+struct coex_dm_8192e_2ant {
+	/* fw mechanism */
+	u8 pre_dec_bt_pwr;
+	u8 cur_dec_bt_pwr;
+	u8 pre_fw_dac_swing_lvl;
+	u8 cur_fw_dac_swing_lvl;
+	bool cur_ignore_wlan_act;
+	bool pre_ignore_wlan_act;
+	u8 pre_ps_tdma;
+	u8 cur_ps_tdma;
+	u8 ps_tdma_para[5];
+	u8 ps_tdma_du_adj_type;
+	bool reset_tdma_adjust;
+	bool auto_tdma_adjust;
+	bool pre_ps_tdma_on;
+	bool cur_ps_tdma_on;
+	bool pre_bt_auto_report;
+	bool cur_bt_auto_report;
+
+	/* sw mechanism */
+	bool pre_rf_rx_lpf_shrink;
+	bool cur_rf_rx_lpf_shrink;
+	u32 bt_rf0x1e_backup;
+	bool pre_low_penalty_ra;
+	bool cur_low_penalty_ra;
+	bool pre_dac_swing_on;
+	u32 pre_dac_swing_lvl;
+	bool cur_dac_swing_on;
+	u32 cur_dac_swing_lvl;
+	bool pre_adc_back_off;
+	bool cur_adc_back_off;
+	bool pre_agc_table_en;
+	bool cur_agc_table_en;
+	u32 pre_val0x6c0;
+	u32 cur_val0x6c0;
+	u32 pre_val0x6c4;
+	u32 cur_val0x6c4;
+	u32 pre_val0x6c8;
+	u32 cur_val0x6c8;
+	u8 pre_val0x6cc;
+	u8 cur_val0x6cc;
+	bool limited_dig;
+
+	u32 backup_arfr_cnt1;	/* Auto Rate Fallback Retry cnt */
+	u32 backup_arfr_cnt2;	/* Auto Rate Fallback Retry cnt */
+	u16 backup_retrylimit;
+	u8 backup_ampdu_maxtime;
+
+	/* algorithm related */
+	u8 pre_algorithm;
+	u8 cur_algorithm;
+	u8 bt_status;
+	u8 wifi_chnl_info[3];
+
+	u8 pre_sstype;
+	u8 cur_sstype;
+
+	u32 prera_mask;
+	u32 curra_mask;
+	u8 curra_masktype;
+	u8 pre_arfrtype;
+	u8 cur_arfrtype;
+	u8 pre_retrylimit_type;
+	u8 cur_retrylimit_type;
+	u8 pre_ampdutime_type;
+	u8 cur_ampdutime_type;
+};
+
+struct coex_sta_8192e_2ant {
+	bool bt_link_exist;
+	bool sco_exist;
+	bool a2dp_exist;
+	bool hid_exist;
+	bool pan_exist;
+
+	bool under_lps;
+	bool under_ips;
+	u32 high_priority_tx;
+	u32 high_priority_rx;
+	u32 low_priority_tx;
+	u32 low_priority_rx;
+	u8 bt_rssi;
+	u8 pre_bt_rssi_state;
+	u8 pre_wifi_rssi_state[4];
+	bool c2h_bt_info_req_sent;
+	u8 bt_info_c2h[BT_INFO_SRC_8192E_2ANT_MAX][10];
+	u32 bt_info_c2h_cnt[BT_INFO_SRC_8192E_2ANT_MAX];
+	bool c2h_bt_inquiry_page;
+	u8 bt_retry_cnt;
+	u8 bt_info_ext;
+};
+
+/****************************************************************
+ *    The following is interface which will notify coex module.
+ ****************************************************************/
+void ex_halbtc8192e2ant_init_hwconfig(struct btc_coexist *btcoexist);
+void ex_halbtc8192e2ant_init_coex_dm(struct btc_coexist *btcoexist);
+void ex_halbtc8192e2ant_ips_notify(struct btc_coexist *btcoexist, u8 type);
+void ex_halbtc8192e2ant_lps_notify(struct btc_coexist *btcoexist, u8 type);
+void ex_halbtc8192e2ant_scan_notify(struct btc_coexist *btcoexist, u8 type);
+void ex_halbtc8192e2ant_connect_notify(struct btc_coexist *btcoexist, u8 type);
+void ex_halbtc8192e2ant_media_status_notify(struct btc_coexist *btcoexist,
+					    u8 type);
+void ex_halbtc8192e2ant_special_packet_notify(struct btc_coexist *btcoexist,
+					      u8 type);
+void ex_halbtc8192e2ant_bt_info_notify(struct btc_coexist *btcoexist,
+				       u8 *tmpbuf, u8 length);
+void ex_halbtc8192e2ant_stack_operation_notify(struct btc_coexist *btcoexist,
+					       u8 type);
+void ex_halbtc8192e2ant_halt_notify(struct btc_coexist *btcoexist);
+void ex_halbtc8192e2ant_periodical(struct btc_coexist *btcoexist);
+void ex_halbtc8192e2ant_display_coex_info(struct btc_coexist *btcoexist);
diff --git a/drivers/staging/rtl8192ee/btcoexist/halbtc8723b1ant.c b/drivers/staging/rtl8192ee/btcoexist/halbtc8723b1ant.c
new file mode 100644
index 0000000..d561c54
--- /dev/null
+++ b/drivers/staging/rtl8192ee/btcoexist/halbtc8723b1ant.c
@@ -0,0 +1,3146 @@
+/***************************************************************
+ * Description:
+ *
+ * This file is for RTL8723B Co-exist mechanism
+ *
+ * History
+ * 2012/11/15 Cosa first check in.
+ *
+ ***************************************************************/
+
+/***************************************************************
+ * include files
+ ***************************************************************/
+#include "halbt_precomp.h"
+/***************************************************************
+ * Global variables, these are static variables
+ ***************************************************************/
+static struct coex_dm_8723b_1ant glcoex_dm_8723b_1ant;
+static struct coex_dm_8723b_1ant *coex_dm = &glcoex_dm_8723b_1ant;
+static struct coex_sta_8723b_1ant glcoex_sta_8723b_1ant;
+static struct coex_sta_8723b_1ant *coex_sta = &glcoex_sta_8723b_1ant;
+
+static const char *const glb_infosrc8723b1ant[] = {
+	"BT Info[wifi fw]",
+	"BT Info[bt rsp]",
+	"BT Info[bt auto report]",
+};
+
+static u32 glcoex_ver_date_8723b_1ant = 20130918;
+static u32 glcoex_ver_8723b_1ant = 0x47;
+
+/***************************************************************
+ * local function proto type if needed
+ ***************************************************************/
+/***************************************************************
+ * local function start with halbtc8723b1ant_
+ ***************************************************************/
+static u8 halbtc8723b1ant_bt_rssi_state(u8 level_num, u8 rssi_thresh,
+					u8 rssi_thresh1)
+{
+	s32 bt_rssi = 0;
+	u8 rssi_state = coex_sta->pre_bt_rssi_state;
+
+	bt_rssi = coex_sta->bt_rssi;
+
+	if (level_num == 2) {
+		if ((coex_sta->pre_bt_rssi_state == BTC_RSSI_STATE_LOW) ||
+		    (coex_sta->pre_bt_rssi_state == BTC_RSSI_STATE_STAY_LOW)) {
+			if (bt_rssi >= rssi_thresh +
+					BTC_RSSI_COEX_THRESH_TOL_8723B_1ANT) {
+				rssi_state = BTC_RSSI_STATE_HIGH;
+				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_RSSI_STATE,
+					  "[BTCoex], BT Rssi state switch to High\n");
+			} else {
+				rssi_state = BTC_RSSI_STATE_STAY_LOW;
+				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_RSSI_STATE,
+					  "[BTCoex], BT Rssi state stay at Low\n");
+			}
+		} else {
+			if (bt_rssi < rssi_thresh) {
+				rssi_state = BTC_RSSI_STATE_LOW;
+				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_RSSI_STATE,
+					  "[BTCoex], BT Rssi state switch to Low\n");
+			} else {
+				rssi_state = BTC_RSSI_STATE_STAY_HIGH;
+				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_RSSI_STATE,
+					  "[BTCoex], BT Rssi state stay at High\n");
+			}
+		}
+	} else if (level_num == 3) {
+		if (rssi_thresh > rssi_thresh1) {
+			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_RSSI_STATE,
+				  "[BTCoex], BT Rssi thresh error!!\n");
+			return coex_sta->pre_bt_rssi_state;
+		}
+
+		if ((coex_sta->pre_bt_rssi_state == BTC_RSSI_STATE_LOW) ||
+		    (coex_sta->pre_bt_rssi_state == BTC_RSSI_STATE_STAY_LOW)) {
+			if (bt_rssi >= rssi_thresh +
+					BTC_RSSI_COEX_THRESH_TOL_8723B_1ANT) {
+				rssi_state = BTC_RSSI_STATE_MEDIUM;
+				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_RSSI_STATE,
+					  "[BTCoex], BT Rssi state switch to Medium\n");
+			} else {
+				rssi_state = BTC_RSSI_STATE_STAY_LOW;
+				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_RSSI_STATE,
+					  "[BTCoex], BT Rssi state stay at Low\n");
+			}
+		} else if ((coex_sta->pre_bt_rssi_state ==
+					BTC_RSSI_STATE_MEDIUM) ||
+			  (coex_sta->pre_bt_rssi_state ==
+					BTC_RSSI_STATE_STAY_MEDIUM)) {
+			if (bt_rssi >= rssi_thresh1 +
+					BTC_RSSI_COEX_THRESH_TOL_8723B_1ANT) {
+				rssi_state = BTC_RSSI_STATE_HIGH;
+				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_RSSI_STATE,
+					  "[BTCoex], BT Rssi state switch to High\n");
+			} else if (bt_rssi < rssi_thresh) {
+				rssi_state = BTC_RSSI_STATE_LOW;
+				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_RSSI_STATE,
+					  "[BTCoex], BT Rssi state switch to Low\n");
+			} else {
+				rssi_state = BTC_RSSI_STATE_STAY_MEDIUM;
+				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_RSSI_STATE,
+					  "[BTCoex], BT Rssi state stay at Medium\n");
+			}
+		} else {
+			if (bt_rssi < rssi_thresh1) {
+				rssi_state = BTC_RSSI_STATE_MEDIUM;
+				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_RSSI_STATE,
+					  "[BTCoex], BT Rssi state switch to Medium\n");
+			} else {
+				rssi_state = BTC_RSSI_STATE_STAY_HIGH;
+				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_RSSI_STATE,
+					  "[BTCoex], BT Rssi state stay at High\n");
+			}
+		}
+	}
+
+	coex_sta->pre_bt_rssi_state = rssi_state;
+
+	return rssi_state;
+}
+
+static u8 halbtc8723b1ant_wifi_rssi_state(struct btc_coexist *btcoexist,
+					  u8 index, u8 level_num,
+					  u8 rssi_thresh, u8 rssi_thresh1)
+{
+	s32 wifi_rssi = 0;
+	u8 wifi_rssi_state = coex_sta->pre_wifi_rssi_state[index];
+
+	btcoexist->btc_get(btcoexist,
+		BTC_GET_S4_WIFI_RSSI, &wifi_rssi);
+
+	if (level_num == 2) {
+		if ((coex_sta->pre_wifi_rssi_state[index] ==
+					BTC_RSSI_STATE_LOW) ||
+		    (coex_sta->pre_wifi_rssi_state[index] ==
+					BTC_RSSI_STATE_STAY_LOW)) {
+			if (wifi_rssi >= rssi_thresh +
+					BTC_RSSI_COEX_THRESH_TOL_8723B_1ANT) {
+				wifi_rssi_state = BTC_RSSI_STATE_HIGH;
+				BTC_PRINT(BTC_MSG_ALGORITHM,
+					  ALGO_WIFI_RSSI_STATE,
+					  "[BTCoex], wifi RSSI state switch to High\n");
+			} else {
+				wifi_rssi_state = BTC_RSSI_STATE_STAY_LOW;
+				BTC_PRINT(BTC_MSG_ALGORITHM,
+					  ALGO_WIFI_RSSI_STATE,
+					  "[BTCoex], wifi RSSI state stay at Low\n");
+			}
+		} else {
+			if (wifi_rssi < rssi_thresh) {
+				wifi_rssi_state = BTC_RSSI_STATE_LOW;
+				BTC_PRINT(BTC_MSG_ALGORITHM,
+					  ALGO_WIFI_RSSI_STATE,
+					  "[BTCoex], wifi RSSI state switch to Low\n");
+			} else {
+				wifi_rssi_state = BTC_RSSI_STATE_STAY_HIGH;
+				BTC_PRINT(BTC_MSG_ALGORITHM,
+					  ALGO_WIFI_RSSI_STATE,
+					  "[BTCoex], wifi RSSI state stay at High\n");
+			}
+		}
+	} else if (level_num == 3) {
+		if (rssi_thresh > rssi_thresh1) {
+			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_WIFI_RSSI_STATE,
+				  "[BTCoex], wifi RSSI thresh error!!\n");
+			return coex_sta->pre_wifi_rssi_state[index];
+		}
+
+		if ((coex_sta->pre_wifi_rssi_state[index] ==
+						BTC_RSSI_STATE_LOW) ||
+		    (coex_sta->pre_wifi_rssi_state[index] ==
+						BTC_RSSI_STATE_STAY_LOW)) {
+			if (wifi_rssi >= rssi_thresh +
+					 BTC_RSSI_COEX_THRESH_TOL_8723B_1ANT) {
+				wifi_rssi_state = BTC_RSSI_STATE_MEDIUM;
+				BTC_PRINT(BTC_MSG_ALGORITHM,
+					  ALGO_WIFI_RSSI_STATE,
+					  "[BTCoex], wifi RSSI state switch to Medium\n");
+			} else {
+				wifi_rssi_state = BTC_RSSI_STATE_STAY_LOW;
+				BTC_PRINT(BTC_MSG_ALGORITHM,
+					  ALGO_WIFI_RSSI_STATE,
+					  "[BTCoex], wifi RSSI state stay at Low\n");
+			}
+		} else if ((coex_sta->pre_wifi_rssi_state[index] ==
+						BTC_RSSI_STATE_MEDIUM) ||
+			   (coex_sta->pre_wifi_rssi_state[index] ==
+						BTC_RSSI_STATE_STAY_MEDIUM)) {
+			if (wifi_rssi >= rssi_thresh1 +
+					 BTC_RSSI_COEX_THRESH_TOL_8723B_1ANT) {
+				wifi_rssi_state = BTC_RSSI_STATE_HIGH;
+				BTC_PRINT(BTC_MSG_ALGORITHM,
+					  ALGO_WIFI_RSSI_STATE,
+					  "[BTCoex], wifi RSSI state switch to High\n");
+			} else if (wifi_rssi < rssi_thresh) {
+				wifi_rssi_state = BTC_RSSI_STATE_LOW;
+				BTC_PRINT(BTC_MSG_ALGORITHM,
+					  ALGO_WIFI_RSSI_STATE,
+					  "[BTCoex], wifi RSSI state switch to Low\n");
+			} else {
+				wifi_rssi_state = BTC_RSSI_STATE_STAY_MEDIUM;
+				BTC_PRINT(BTC_MSG_ALGORITHM,
+					  ALGO_WIFI_RSSI_STATE,
+					  "[BTCoex], wifi RSSI state stay at Medium\n");
+			}
+		} else {
+			if (wifi_rssi < rssi_thresh1) {
+				wifi_rssi_state = BTC_RSSI_STATE_MEDIUM;
+				BTC_PRINT(BTC_MSG_ALGORITHM,
+					  ALGO_WIFI_RSSI_STATE,
+					  "[BTCoex], wifi RSSI state switch to Medium\n");
+			} else {
+				wifi_rssi_state = BTC_RSSI_STATE_STAY_HIGH;
+				BTC_PRINT(BTC_MSG_ALGORITHM,
+					  ALGO_WIFI_RSSI_STATE,
+					  "[BTCoex], wifi RSSI state stay at High\n");
+			}
+		}
+	}
+
+	coex_sta->pre_wifi_rssi_state[index] = wifi_rssi_state;
+
+	return wifi_rssi_state;
+}
+
+static void halbtc8723b1ant_updatera_mask(struct btc_coexist *btcoexist,
+					  bool force_exec, u32 dis_rate_mask)
+{
+	coex_dm->curra_mask = dis_rate_mask;
+
+	if (force_exec || (coex_dm->prera_mask != coex_dm->curra_mask))
+		btcoexist->btc_set(btcoexist, BTC_SET_ACT_UPDATE_ra_mask,
+				   &coex_dm->curra_mask);
+
+	coex_dm->prera_mask = coex_dm->curra_mask;
+}
+
+static void auto_rate_fallback_retry(struct btc_coexist *btcoexist,
+				     bool force_exec, u8 type)
+{
+	bool wifi_under_bmode = false;
+
+	coex_dm->cur_arfr_type = type;
+
+	if (force_exec || (coex_dm->pre_arfr_type != coex_dm->cur_arfr_type)) {
+		switch (coex_dm->cur_arfr_type) {
+		case 0:	/* normal mode */
+			btcoexist->btc_write_4byte(btcoexist, 0x430,
+						   coex_dm->backup_arfr_cnt1);
+			btcoexist->btc_write_4byte(btcoexist, 0x434,
+						   coex_dm->backup_arfr_cnt2);
+			break;
+		case 1:
+			btcoexist->btc_get(btcoexist,
+					   BTC_GET_BL_WIFI_UNDER_B_MODE,
+					   &wifi_under_bmode);
+			if (wifi_under_bmode) {
+				btcoexist->btc_write_4byte(btcoexist,
+							   0x430, 0x0);
+				btcoexist->btc_write_4byte(btcoexist,
+							   0x434, 0x01010101);
+			} else {
+				btcoexist->btc_write_4byte(btcoexist,
+							   0x430, 0x0);
+				btcoexist->btc_write_4byte(btcoexist,
+							   0x434, 0x04030201);
+			}
+			break;
+		default:
+			break;
+		}
+	}
+
+	coex_dm->pre_arfr_type = coex_dm->cur_arfr_type;
+}
+
+static void halbtc8723b1ant_retry_limit(struct btc_coexist *btcoexist,
+					bool force_exec, u8 type)
+{
+	coex_dm->cur_retry_limit_type = type;
+
+	if (force_exec || (coex_dm->pre_retry_limit_type !=
+			   coex_dm->cur_retry_limit_type)) {
+		switch (coex_dm->cur_retry_limit_type) {
+		case 0:	/* normal mode */
+			btcoexist->btc_write_2byte(btcoexist, 0x42a,
+						   coex_dm->backup_retry_limit);
+			break;
+		case 1:	/* retry limit = 8 */
+			btcoexist->btc_write_2byte(btcoexist, 0x42a, 0x0808);
+			break;
+		default:
+			break;
+		}
+	}
+
+	coex_dm->pre_retry_limit_type = coex_dm->cur_retry_limit_type;
+}
+
+static void halbtc8723b1ant_ampdu_maxtime(struct btc_coexist *btcoexist,
+					  bool force_exec, u8 type)
+{
+	coex_dm->cur_ampdu_time_type = type;
+
+	if (force_exec || (coex_dm->pre_ampdu_time_type !=
+		coex_dm->cur_ampdu_time_type)) {
+		switch (coex_dm->cur_ampdu_time_type) {
+		case 0:	/* normal mode */
+			btcoexist->btc_write_1byte(btcoexist, 0x456,
+					coex_dm->backup_ampdu_max_time);
+			break;
+		case 1:	/* AMPDU timw = 0x38 * 32us */
+			btcoexist->btc_write_1byte(btcoexist,
+						   0x456, 0x38);
+			break;
+		default:
+			break;
+		}
+	}
+
+	coex_dm->pre_ampdu_time_type = coex_dm->cur_ampdu_time_type;
+}
+
+static void halbtc8723b1ant_limited_tx(struct btc_coexist *btcoexist,
+				       bool force_exec, u8 ra_masktype,
+				       u8 arfr_type, u8 retry_limit_type,
+				       u8 ampdu_time_type)
+{
+	switch (ra_masktype) {
+	case 0:	/* normal mode */
+		halbtc8723b1ant_updatera_mask(btcoexist, force_exec, 0x0);
+		break;
+	case 1:	/* disable cck 1/2 */
+		halbtc8723b1ant_updatera_mask(btcoexist, force_exec,
+					      0x00000003);
+		break;
+	/* disable cck 1/2/5.5, ofdm 6/9/12/18/24, mcs 0/1/2/3/4*/
+	case 2:
+		halbtc8723b1ant_updatera_mask(btcoexist, force_exec,
+					      0x0001f1f7);
+		break;
+	default:
+		break;
+	}
+
+	auto_rate_fallback_retry(btcoexist, force_exec, arfr_type);
+	halbtc8723b1ant_retry_limit(btcoexist, force_exec, retry_limit_type);
+	halbtc8723b1ant_ampdu_maxtime(btcoexist, force_exec, ampdu_time_type);
+}
+
+static void halbtc8723b1ant_limited_rx(struct btc_coexist *btcoexist,
+				       bool force_exec, bool rej_ap_agg_pkt,
+				bool b_bt_ctrl_agg_buf_size, u8 agg_buf_size)
+{
+	bool reject_rx_agg = rej_ap_agg_pkt;
+	bool bt_ctrl_rx_agg_size = b_bt_ctrl_agg_buf_size;
+	u8 rxaggsize = agg_buf_size;
+
+	/**********************************************
+	 *	Rx Aggregation related setting
+	 **********************************************/
+	btcoexist->btc_set(btcoexist, BTC_SET_BL_TO_REJ_AP_AGG_PKT,
+			   &reject_rx_agg);
+	/* decide BT control aggregation buf size or not  */
+	btcoexist->btc_set(btcoexist, BTC_SET_BL_BT_CTRL_AGG_SIZE,
+			   &bt_ctrl_rx_agg_size);
+	/* aggregation buf size, only work
+	 *when BT control Rx aggregation size.  */
+	btcoexist->btc_set(btcoexist, BTC_SET_U1_AGG_BUF_SIZE, &rxaggsize);
+	/* real update aggregation setting  */
+	btcoexist->btc_set(btcoexist, BTC_SET_ACT_AGGREGATE_CTRL, NULL);
+}
+
+static void halbtc8723b1ant_monitor_bt_ctr(struct btc_coexist *btcoexist)
+{
+	u32 reg_hp_txrx, reg_lp_txrx, u32tmp;
+	u32 reg_hp_tx = 0, reg_hp_rx = 0;
+	u32 reg_lp_tx = 0, reg_lp_rx = 0;
+
+	reg_hp_txrx = 0x770;
+	reg_lp_txrx = 0x774;
+
+	u32tmp = btcoexist->btc_read_4byte(btcoexist, reg_hp_txrx);
+	reg_hp_tx = u32tmp & MASKLWORD;
+	reg_hp_rx = (u32tmp & MASKHWORD) >> 16;
+
+	u32tmp = btcoexist->btc_read_4byte(btcoexist, reg_lp_txrx);
+	reg_lp_tx = u32tmp & MASKLWORD;
+	reg_lp_rx = (u32tmp & MASKHWORD) >> 16;
+
+	coex_sta->high_priority_tx = reg_hp_tx;
+	coex_sta->high_priority_rx = reg_hp_rx;
+	coex_sta->low_priority_tx = reg_lp_tx;
+	coex_sta->low_priority_rx = reg_lp_rx;
+
+	/* reset counter */
+	btcoexist->btc_write_1byte(btcoexist, 0x76e, 0xc);
+}
+
+static void halbtc8723b1ant_query_bt_info(struct btc_coexist *btcoexist)
+{
+	u8 h2c_parameter[1] = {0};
+
+	coex_sta->c2h_bt_info_req_sent = true;
+
+	h2c_parameter[0] |= BIT(0);	/* trigger*/
+
+	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_EXEC,
+		  "[BTCoex], Query Bt Info, FW write 0x61 = 0x%x\n",
+		  h2c_parameter[0]);
+
+	btcoexist->btc_fill_h2c(btcoexist, 0x61, 1, h2c_parameter);
+}
+
+static bool is_wifi_status_changed(struct btc_coexist *btcoexist)
+{
+	static bool pre_wifi_busy;
+	static bool pre_under_4way, pre_bt_hs_on;
+	bool wifi_busy = false, under_4way = false, bt_hs_on = false;
+	bool wifi_connected = false;
+
+	btcoexist->btc_get(btcoexist, BTC_GET_BL_WIFI_CONNECTED,
+			   &wifi_connected);
+	btcoexist->btc_get(btcoexist, BTC_GET_BL_WIFI_BUSY, &wifi_busy);
+	btcoexist->btc_get(btcoexist, BTC_GET_BL_HS_OPERATION, &bt_hs_on);
+	btcoexist->btc_get(btcoexist, BTC_GET_BL_WIFI_4_WAY_PROGRESS,
+			   &under_4way);
+
+	if (wifi_connected) {
+		if (wifi_busy != pre_wifi_busy) {
+			pre_wifi_busy = wifi_busy;
+			return true;
+		}
+		if (under_4way != pre_under_4way) {
+			pre_under_4way = under_4way;
+			return true;
+		}
+		if (bt_hs_on != pre_bt_hs_on) {
+			pre_bt_hs_on = bt_hs_on;
+			return true;
+		}
+	}
+
+	return false;
+}
+
+static void halbtc8723b1ant_update_bt_link_info(struct btc_coexist *btcoexist)
+{
+	struct btc_bt_link_info *bt_link_info = &btcoexist->bt_link_info;
+	bool bt_hs_on = false;
+
+	btcoexist->btc_get(btcoexist, BTC_GET_BL_HS_OPERATION, &bt_hs_on);
+
+	bt_link_info->bt_link_exist = coex_sta->bt_link_exist;
+	bt_link_info->sco_exist = coex_sta->sco_exist;
+	bt_link_info->a2dp_exist = coex_sta->a2dp_exist;
+	bt_link_info->pan_exist = coex_sta->pan_exist;
+	bt_link_info->hid_exist = coex_sta->hid_exist;
+
+	/* work around for HS mode. */
+	if (bt_hs_on) {
+		bt_link_info->pan_exist = true;
+		bt_link_info->bt_link_exist = true;
+	}
+
+	/* check if Sco only */
+	if (bt_link_info->sco_exist && !bt_link_info->a2dp_exist &&
+	    !bt_link_info->pan_exist && !bt_link_info->hid_exist)
+		bt_link_info->sco_only = true;
+	else
+		bt_link_info->sco_only = false;
+
+	/* check if A2dp only */
+	if (!bt_link_info->sco_exist && bt_link_info->a2dp_exist &&
+	    !bt_link_info->pan_exist && !bt_link_info->hid_exist)
+		bt_link_info->a2dp_only = true;
+	else
+		bt_link_info->a2dp_only = false;
+
+	/* check if Pan only */
+	if (!bt_link_info->sco_exist && !bt_link_info->a2dp_exist &&
+	    bt_link_info->pan_exist && !bt_link_info->hid_exist)
+		bt_link_info->pan_only = true;
+	else
+		bt_link_info->pan_only = false;
+
+	/* check if Hid only */
+	if (!bt_link_info->sco_exist && !bt_link_info->a2dp_exist &&
+	    !bt_link_info->pan_exist && bt_link_info->hid_exist)
+		bt_link_info->hid_only = true;
+	else
+		bt_link_info->hid_only = false;
+}
+
+static u8 halbtc8723b1ant_action_algorithm(struct btc_coexist *btcoexist)
+{
+	struct btc_bt_link_info *bt_link_info = &btcoexist->bt_link_info;
+	bool bt_hs_on = false;
+	u8 algorithm = BT_8723B_1ANT_COEX_ALGO_UNDEFINED;
+	u8 numofdiffprofile = 0;
+
+	btcoexist->btc_get(btcoexist, BTC_GET_BL_HS_OPERATION, &bt_hs_on);
+
+	if (!bt_link_info->bt_link_exist) {
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+			  "[BTCoex], No BT link exists!!!\n");
+		return algorithm;
+	}
+
+	if (bt_link_info->sco_exist)
+		numofdiffprofile++;
+	if (bt_link_info->hid_exist)
+		numofdiffprofile++;
+	if (bt_link_info->pan_exist)
+		numofdiffprofile++;
+	if (bt_link_info->a2dp_exist)
+		numofdiffprofile++;
+
+	if (numofdiffprofile == 1) {
+		if (bt_link_info->sco_exist) {
+			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+				  "[BTCoex], BT Profile = SCO only\n");
+			algorithm = BT_8723B_1ANT_COEX_ALGO_SCO;
+		} else {
+			if (bt_link_info->hid_exist) {
+				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+					  "[BTCoex], BT Profile = HID only\n");
+				algorithm = BT_8723B_1ANT_COEX_ALGO_HID;
+			} else if (bt_link_info->a2dp_exist) {
+				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+					  "[BTCoex], BT Profile = A2DP only\n");
+				algorithm = BT_8723B_1ANT_COEX_ALGO_A2DP;
+			} else if (bt_link_info->pan_exist) {
+				if (bt_hs_on) {
+					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+						  "[BTCoex], BT Profile = PAN(HS) only\n");
+					algorithm =
+						BT_8723B_1ANT_COEX_ALGO_PANHS;
+				} else {
+					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+						  "[BTCoex], BT Profile = PAN(EDR) only\n");
+					algorithm =
+						BT_8723B_1ANT_COEX_ALGO_PANEDR;
+				}
+			}
+		}
+	} else if (numofdiffprofile == 2) {
+		if (bt_link_info->sco_exist) {
+			if (bt_link_info->hid_exist) {
+				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+					  "[BTCoex], BT Profile = SCO + HID\n");
+				algorithm = BT_8723B_1ANT_COEX_ALGO_HID;
+			} else if (bt_link_info->a2dp_exist) {
+				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+					  "[BTCoex], BT Profile = SCO + A2DP ==> SCO\n");
+				algorithm = BT_8723B_1ANT_COEX_ALGO_SCO;
+			} else if (bt_link_info->pan_exist) {
+				if (bt_hs_on) {
+					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+						  "[BTCoex], BT Profile = SCO + PAN(HS)\n");
+					algorithm = BT_8723B_1ANT_COEX_ALGO_SCO;
+				} else {
+					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+						  "[BTCoex], BT Profile = SCO + PAN(EDR)\n");
+					algorithm =
+					    BT_8723B_1ANT_COEX_ALGO_PANEDR_HID;
+				}
+			}
+		} else {
+			if (bt_link_info->hid_exist &&
+			    bt_link_info->a2dp_exist) {
+				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+					  "[BTCoex], BT Profile = HID + A2DP\n");
+				algorithm = BT_8723B_1ANT_COEX_ALGO_HID_A2DP;
+			} else if (bt_link_info->hid_exist &&
+				   bt_link_info->pan_exist) {
+				if (bt_hs_on) {
+					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+						  "[BTCoex], BT Profile = HID + PAN(HS)\n");
+					algorithm =
+					    BT_8723B_1ANT_COEX_ALGO_HID_A2DP;
+				} else {
+					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+						  "[BTCoex], BT Profile = HID + PAN(EDR)\n");
+					algorithm =
+					    BT_8723B_1ANT_COEX_ALGO_PANEDR_HID;
+				}
+			} else if (bt_link_info->pan_exist &&
+				   bt_link_info->a2dp_exist) {
+				if (bt_hs_on) {
+					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+						  "[BTCoex], BT Profile = A2DP + PAN(HS)\n");
+					algorithm =
+					    BT_8723B_1ANT_COEX_ALGO_A2DP_PANHS;
+				} else {
+					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+						  "[BTCoex], BT Profile = A2DP + PAN(EDR)\n");
+					algorithm =
+					    BT_8723B_1ANT_COEX_ALGO_PANEDR_A2DP;
+				}
+			}
+		}
+	} else if (numofdiffprofile == 3) {
+		if (bt_link_info->sco_exist) {
+			if (bt_link_info->hid_exist &&
+			    bt_link_info->a2dp_exist) {
+				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+					  "[BTCoex], BT Profile = SCO + HID + A2DP ==> HID\n");
+				algorithm = BT_8723B_1ANT_COEX_ALGO_HID;
+			} else if (bt_link_info->hid_exist &&
+				   bt_link_info->pan_exist) {
+				if (bt_hs_on) {
+					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+						  "[BTCoex], BT Profile = SCO + HID + PAN(HS)\n");
+					algorithm =
+					    BT_8723B_1ANT_COEX_ALGO_HID_A2DP;
+				} else {
+					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+						  "[BTCoex], BT Profile = SCO + HID + PAN(EDR)\n");
+					algorithm =
+					    BT_8723B_1ANT_COEX_ALGO_PANEDR_HID;
+				}
+			} else if (bt_link_info->pan_exist &&
+				   bt_link_info->a2dp_exist) {
+				if (bt_hs_on) {
+					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+						  "[BTCoex], BT Profile = SCO + A2DP + PAN(HS)\n");
+					algorithm = BT_8723B_1ANT_COEX_ALGO_SCO;
+				} else {
+					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+						  "[BTCoex], BT Profile = SCO + A2DP + PAN(EDR) ==> HID\n");
+					algorithm =
+					    BT_8723B_1ANT_COEX_ALGO_PANEDR_HID;
+				}
+			}
+		} else {
+			if (bt_link_info->hid_exist &&
+			    bt_link_info->pan_exist &&
+			    bt_link_info->a2dp_exist) {
+				if (bt_hs_on) {
+					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+						  "[BTCoex], BT Profile = HID + A2DP + PAN(HS)\n");
+					algorithm =
+					    BT_8723B_1ANT_COEX_ALGO_HID_A2DP;
+				} else {
+					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+						  "[BTCoex], BT Profile = HID + A2DP + PAN(EDR)\n");
+					algorithm =
+					    BT_8723B_1ANT_COEX_ALGO_HID_A2DP_PANEDR;
+				}
+			}
+		}
+	} else if (numofdiffprofile >= 3) {
+		if (bt_link_info->sco_exist) {
+			if (bt_link_info->hid_exist &&
+			    bt_link_info->pan_exist &&
+			    bt_link_info->a2dp_exist) {
+				if (bt_hs_on) {
+					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+						  "[BTCoex], Error!!! BT Profile = SCO + HID + A2DP + PAN(HS)\n");
+				} else {
+					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+						  "[BTCoex], BT Profile = SCO + HID + A2DP + PAN(EDR) ==>PAN(EDR)+HID\n");
+					algorithm =
+					    BT_8723B_1ANT_COEX_ALGO_PANEDR_HID;
+				}
+			}
+		}
+	}
+
+	return algorithm;
+}
+
+static void set_sw_penalty_tx_rate_adapt(struct btc_coexist *btcoexist,
+					 bool low_penalty_ra)
+{
+	u8 h2c_parameter[6] = {0};
+
+	h2c_parameter[0] = 0x6;	/* opCode, 0x6 = Retry_Penalty */
+
+	if (low_penalty_ra) {
+		h2c_parameter[1] |= BIT(0);
+		/*normal rate except MCS7/6/5, OFDM54/48/36 */
+		h2c_parameter[2] = 0x00;
+		h2c_parameter[3] = 0xf7;  /*MCS7 or OFDM54 */
+		h2c_parameter[4] = 0xf8;  /*MCS6 or OFDM48 */
+		h2c_parameter[5] = 0xf9;  /*MCS5 or OFDM36 */
+	}
+
+	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_EXEC,
+		  "[BTCoex], set WiFi Low-Penalty Retry: %s",
+		  (low_penalty_ra ? "ON!!" : "OFF!!"));
+
+	btcoexist->btc_fill_h2c(btcoexist, 0x69, 6, h2c_parameter);
+}
+
+static void halbtc8723b1ant_low_penalty_ra(struct btc_coexist *btcoexist,
+					   bool force_exec, bool low_penalty_ra)
+{
+	coex_dm->cur_low_penalty_ra = low_penalty_ra;
+
+	if (!force_exec) {
+		if (coex_dm->pre_low_penalty_ra == coex_dm->cur_low_penalty_ra)
+			return;
+	}
+	set_sw_penalty_tx_rate_adapt(btcoexist, coex_dm->cur_low_penalty_ra);
+
+	coex_dm->pre_low_penalty_ra = coex_dm->cur_low_penalty_ra;
+}
+
+static void halbtc8723b1ant_set_coex_table(struct btc_coexist *btcoexist,
+					   u32 val0x6c0, u32 val0x6c4,
+					   u32 val0x6c8, u8 val0x6cc)
+{
+	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW_EXEC,
+		  "[BTCoex], set coex table, set 0x6c0 = 0x%x\n", val0x6c0);
+	btcoexist->btc_write_4byte(btcoexist, 0x6c0, val0x6c0);
+
+	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW_EXEC,
+		  "[BTCoex], set coex table, set 0x6c4 = 0x%x\n", val0x6c4);
+	btcoexist->btc_write_4byte(btcoexist, 0x6c4, val0x6c4);
+
+	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW_EXEC,
+		  "[BTCoex], set coex table, set 0x6c8 = 0x%x\n", val0x6c8);
+	btcoexist->btc_write_4byte(btcoexist, 0x6c8, val0x6c8);
+
+	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW_EXEC,
+		  "[BTCoex], set coex table, set 0x6cc = 0x%x\n", val0x6cc);
+	btcoexist->btc_write_1byte(btcoexist, 0x6cc, val0x6cc);
+}
+
+static void halbtc8723b1ant_coex_table(struct btc_coexist *btcoexist,
+				       bool force_exec, u32 val0x6c0,
+				       u32 val0x6c4, u32 val0x6c8,
+				       u8 val0x6cc)
+{
+	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW,
+		  "[BTCoex], %s write Coex Table 0x6c0 = 0x%x, 0x6c4 = 0x%x, 0x6cc = 0x%x\n",
+		  (force_exec ? "force to" : ""),
+		  val0x6c0, val0x6c4, val0x6cc);
+	coex_dm->cur_val0x6c0 = val0x6c0;
+	coex_dm->cur_val0x6c4 = val0x6c4;
+	coex_dm->cur_val0x6c8 = val0x6c8;
+	coex_dm->cur_val0x6cc = val0x6cc;
+
+	if (!force_exec) {
+		if ((coex_dm->pre_val0x6c0 == coex_dm->cur_val0x6c0) &&
+		    (coex_dm->pre_val0x6c4 == coex_dm->cur_val0x6c4) &&
+		    (coex_dm->pre_val0x6c8 == coex_dm->cur_val0x6c8) &&
+		    (coex_dm->pre_val0x6cc == coex_dm->cur_val0x6cc))
+			return;
+	}
+	halbtc8723b1ant_set_coex_table(btcoexist, val0x6c0, val0x6c4,
+				       val0x6c8, val0x6cc);
+
+	coex_dm->pre_val0x6c0 = coex_dm->cur_val0x6c0;
+	coex_dm->pre_val0x6c4 = coex_dm->cur_val0x6c4;
+	coex_dm->pre_val0x6c8 = coex_dm->cur_val0x6c8;
+	coex_dm->pre_val0x6cc = coex_dm->cur_val0x6cc;
+}
+
+static void coex_table_with_type(struct btc_coexist *btcoexist,
+				 bool force_exec, u8 type)
+{
+	switch (type) {
+	case 0:
+		halbtc8723b1ant_coex_table(btcoexist, force_exec, 0x55555555,
+					   0x55555555, 0xffffff, 0x3);
+		break;
+	case 1:
+		halbtc8723b1ant_coex_table(btcoexist, force_exec, 0x55555555,
+					   0x5a5a5a5a, 0xffffff, 0x3);
+		break;
+	case 2:
+		halbtc8723b1ant_coex_table(btcoexist, force_exec, 0x5a5a5a5a,
+					   0x5a5a5a5a, 0xffffff, 0x3);
+		break;
+	case 3:
+		halbtc8723b1ant_coex_table(btcoexist, force_exec, 0x55555555,
+					   0xaaaaaaaa, 0xffffff, 0x3);
+		break;
+	case 4:
+		halbtc8723b1ant_coex_table(btcoexist, force_exec, 0x55555555,
+					   0x5aaa5aaa, 0xffffff, 0x3);
+		break;
+	case 5:
+		halbtc8723b1ant_coex_table(btcoexist, force_exec, 0x5a5a5a5a,
+					   0xaaaa5a5a, 0xffffff, 0x3);
+		break;
+	case 6:
+		halbtc8723b1ant_coex_table(btcoexist, force_exec, 0x55555555,
+					   0xaaaa5a5a, 0xffffff, 0x3);
+		break;
+	case 7:
+		halbtc8723b1ant_coex_table(btcoexist, force_exec, 0xaaaaaaaa,
+					   0xaaaaaaaa, 0xffffff, 0x3);
+		break;
+	default:
+		break;
+	}
+}
+
+static void set_fw_ignore_wlan_act(struct btc_coexist *btcoexist,
+				   bool enable)
+{
+	u8 h2c_parameter[1] = {0};
+
+	if (enable)
+		h2c_parameter[0] |= BIT(0);	/* function enable */
+
+	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_EXEC,
+		  "[BTCoex], set FW for BT Ignore Wlan_Act, FW write 0x63 = 0x%x\n",
+		  h2c_parameter[0]);
+
+	btcoexist->btc_fill_h2c(btcoexist, 0x63, 1, h2c_parameter);
+}
+
+static void halbtc8723b1ant_ignore_wlan_act(struct btc_coexist *btcoexist,
+					    bool force_exec, bool enable)
+{
+	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW,
+		  "[BTCoex], %s turn Ignore WlanAct %s\n",
+		  (force_exec ? "force to" : ""), (enable ? "ON" : "OFF"));
+	coex_dm->cur_ignore_wlan_act = enable;
+
+	if (!force_exec) {
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_DETAIL,
+			  "[BTCoex], bPreIgnoreWlanAct = %d, bCurIgnoreWlanAct = %d!!\n",
+			  coex_dm->pre_ignore_wlan_act,
+			  coex_dm->cur_ignore_wlan_act);
+
+		if (coex_dm->pre_ignore_wlan_act ==
+		    coex_dm->cur_ignore_wlan_act)
+			return;
+	}
+	set_fw_ignore_wlan_act(btcoexist, enable);
+
+	coex_dm->pre_ignore_wlan_act = coex_dm->cur_ignore_wlan_act;
+}
+
+static void halbtc8723b1ant_set_fw_ps_tdma(struct btc_coexist *btcoexist,
+					   u8 byte1, u8 byte2, u8 byte3,
+					   u8 byte4, u8 byte5)
+{
+	u8 h2c_parameter[5] = {0};
+	u8 real_byte1 = byte1, real_byte5 = byte5;
+	bool ap_enable = false;
+
+	btcoexist->btc_get(btcoexist, BTC_GET_BL_WIFI_AP_MODE_ENABLE,
+			   &ap_enable);
+
+	if (ap_enable) {
+		if ((byte1 & BIT(4)) && !(byte1 & BIT(5))) {
+			BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
+				  "[BTCoex], FW for 1Ant AP mode\n");
+			real_byte1 &= ~BIT(4);
+			real_byte1 |= BIT(5);
+
+			real_byte5 |= BIT(5);
+			real_byte5 &= ~BIT(6);
+		}
+	}
+
+	h2c_parameter[0] = real_byte1;
+	h2c_parameter[1] = byte2;
+	h2c_parameter[2] = byte3;
+	h2c_parameter[3] = byte4;
+	h2c_parameter[4] = real_byte5;
+
+	coex_dm->ps_tdma_para[0] = real_byte1;
+	coex_dm->ps_tdma_para[1] = byte2;
+	coex_dm->ps_tdma_para[2] = byte3;
+	coex_dm->ps_tdma_para[3] = byte4;
+	coex_dm->ps_tdma_para[4] = real_byte5;
+
+	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_EXEC,
+		  "[BTCoex], PS-TDMA H2C cmd = 0x%x%08x\n",
+		  h2c_parameter[0],
+		  h2c_parameter[1] << 24 |
+		  h2c_parameter[2] << 16 |
+		  h2c_parameter[3] << 8 |
+		  h2c_parameter[4]);
+
+	btcoexist->btc_fill_h2c(btcoexist, 0x60, 5, h2c_parameter);
+}
+
+static void halbtc8723b1ant_set_lps_rpwm(struct btc_coexist *btcoexist,
+					 u8 lps_val, u8 rpwm_val)
+{
+	u8 lps = lps_val;
+	u8 rpwm = rpwm_val;
+
+	btcoexist->btc_set(btcoexist, BTC_SET_U1_LPS_VAL, &lps);
+	btcoexist->btc_set(btcoexist, BTC_SET_U1_RPWM_VAL, &rpwm);
+}
+
+static void halbtc8723b1ant_lpsrpwm(struct btc_coexist *btcoexist,
+				    bool force_exec,
+				    u8 lps_val, u8 rpwm_val)
+{
+	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW,
+		  "[BTCoex], %s set lps/rpwm = 0x%x/0x%x\n",
+		  (force_exec ? "force to" : ""), lps_val, rpwm_val);
+	coex_dm->cur_lps = lps_val;
+	coex_dm->cur_rpwm = rpwm_val;
+
+	if (!force_exec) {
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_DETAIL,
+			  "[BTCoex], LPS-RxBeaconMode = 0x%x, LPS-RPWM = 0x%x!!\n",
+			  coex_dm->cur_lps, coex_dm->cur_rpwm);
+
+		if ((coex_dm->pre_lps == coex_dm->cur_lps) &&
+		    (coex_dm->pre_rpwm == coex_dm->cur_rpwm)) {
+			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_DETAIL,
+				  "[BTCoex], LPS-RPWM_Last = 0x%x, LPS-RPWM_Now = 0x%x!!\n",
+				  coex_dm->pre_rpwm, coex_dm->cur_rpwm);
+
+			return;
+		}
+	}
+	halbtc8723b1ant_set_lps_rpwm(btcoexist, lps_val, rpwm_val);
+
+	coex_dm->pre_lps = coex_dm->cur_lps;
+	coex_dm->pre_rpwm = coex_dm->cur_rpwm;
+}
+
+static void halbtc8723b1ant_sw_mechanism(struct btc_coexist *btcoexist,
+					 bool low_penalty_ra)
+{
+	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_MONITOR,
+		  "[BTCoex], SM[LpRA] = %d\n", low_penalty_ra);
+
+	halbtc8723b1ant_low_penalty_ra(btcoexist, NORMAL_EXEC, low_penalty_ra);
+}
+
+static void halbtc8723b1ant_setantpath(struct btc_coexist *btcoexist,
+				       u8 ant_pos_type, bool init_hw_cfg,
+				bool wifi_off)
+{
+	struct btc_board_info *brd_info = &btcoexist->board_info;
+	u32 fw_ver = 0, u32tmp = 0;
+	bool pg_ext_switch = false;
+	bool use_ext_switch = false;
+	u8 h2c_parameter[2] = {0};
+
+	btcoexist->btc_get(btcoexist, BTC_GET_BL_EXT_SWITCH, &pg_ext_switch);
+	/* [31:16] = fw ver, [15:0] = fw sub ver */
+	btcoexist->btc_get(btcoexist, BTC_GET_U4_WIFI_FW_VER, &fw_ver);
+
+	if ((fw_ver < 0xc0000) || pg_ext_switch)
+		use_ext_switch = true;
+
+	if (init_hw_cfg) {
+		/*BT select s0/s1 is controlled by WiFi */
+		btcoexist->btc_write_1byte_bitmask(btcoexist, 0x67, 0x20, 0x1);
+
+		/*Force GNT_BT to Normal */
+		btcoexist->btc_write_1byte_bitmask(btcoexist, 0x765, 0x18, 0x0);
+	} else if (wifi_off) {
+		/*Force GNT_BT to High */
+		btcoexist->btc_write_1byte_bitmask(btcoexist, 0x765, 0x18, 0x3);
+		/*BT select s0/s1 is controlled by BT */
+		btcoexist->btc_write_1byte_bitmask(btcoexist, 0x67, 0x20, 0x0);
+
+		/* 0x4c[24:23] = 00, Set Antenna control by BT_RFE_CTRL
+		 * BT Vendor 0xac = 0xf002 */
+		u32tmp = btcoexist->btc_read_4byte(btcoexist, 0x4c);
+		u32tmp &= ~BIT(23);
+		u32tmp &= ~BIT(24);
+		btcoexist->btc_write_4byte(btcoexist, 0x4c, u32tmp);
+	}
+
+	if (use_ext_switch) {
+		if (init_hw_cfg) {
+			/* 0x4c[23] = 0, 0x4c[24] = 1  Antenna ctrl by WL/BT */
+			u32tmp = btcoexist->btc_read_4byte(btcoexist, 0x4c);
+			u32tmp &= ~BIT(23);
+			u32tmp |= BIT(24);
+			btcoexist->btc_write_4byte(btcoexist, 0x4c, u32tmp);
+
+			if (brd_info->btdm_ant_pos ==
+			    BTC_ANTENNA_AT_MAIN_PORT) {
+				/* Main Ant to  BT for IPS case 0x4c[23] = 1 */
+				btcoexist->btc_write_1byte_bitmask(btcoexist,
+								   0x64, 0x1,
+								   0x1);
+
+				/*tell firmware "no antenna inverse"*/
+				h2c_parameter[0] = 0;
+				h2c_parameter[1] = 1;  /*ext switch type*/
+				btcoexist->btc_fill_h2c(btcoexist, 0x65, 2,
+							h2c_parameter);
+			} else {
+				/*Aux Ant to  BT for IPS case 0x4c[23] = 1 */
+				btcoexist->btc_write_1byte_bitmask(btcoexist,
+								   0x64, 0x1,
+								   0x0);
+
+				/*tell firmware "antenna inverse"*/
+				h2c_parameter[0] = 1;
+				h2c_parameter[1] = 1;  /*ext switch type*/
+				btcoexist->btc_fill_h2c(btcoexist, 0x65, 2,
+							h2c_parameter);
+			}
+		}
+
+		/* fixed internal switch first*/
+		/* fixed internal switch S1->WiFi, S0->BT*/
+		if (brd_info->btdm_ant_pos == BTC_ANTENNA_AT_MAIN_PORT)
+			btcoexist->btc_write_2byte(btcoexist, 0x948, 0x0);
+		else/* fixed internal switch S0->WiFi, S1->BT*/
+			btcoexist->btc_write_2byte(btcoexist, 0x948, 0x280);
+
+		/* ext switch setting */
+		switch (ant_pos_type) {
+		case BTC_ANT_PATH_WIFI:
+			if (brd_info->btdm_ant_pos == BTC_ANTENNA_AT_MAIN_PORT)
+				btcoexist->btc_write_1byte_bitmask(btcoexist,
+								   0x92c, 0x3,
+								   0x1);
+			else
+				btcoexist->btc_write_1byte_bitmask(btcoexist,
+								   0x92c, 0x3,
+								   0x2);
+			break;
+		case BTC_ANT_PATH_BT:
+			if (brd_info->btdm_ant_pos == BTC_ANTENNA_AT_MAIN_PORT)
+				btcoexist->btc_write_1byte_bitmask(btcoexist,
+								   0x92c, 0x3,
+								   0x2);
+			else
+				btcoexist->btc_write_1byte_bitmask(btcoexist,
+								   0x92c, 0x3,
+								   0x1);
+			break;
+		default:
+		case BTC_ANT_PATH_PTA:
+			if (brd_info->btdm_ant_pos == BTC_ANTENNA_AT_MAIN_PORT)
+				btcoexist->btc_write_1byte_bitmask(btcoexist,
+								   0x92c, 0x3,
+								   0x1);
+			else
+				btcoexist->btc_write_1byte_bitmask(btcoexist,
+								   0x92c, 0x3,
+								   0x2);
+			break;
+		}
+
+	} else {
+		if (init_hw_cfg) {
+			/* 0x4c[23] = 1, 0x4c[24] = 0  Antenna control by 0x64*/
+			u32tmp = btcoexist->btc_read_4byte(btcoexist, 0x4c);
+			u32tmp |= BIT(23);
+			u32tmp &= ~BIT(24);
+			btcoexist->btc_write_4byte(btcoexist, 0x4c, u32tmp);
+
+			if (brd_info->btdm_ant_pos ==
+			    BTC_ANTENNA_AT_MAIN_PORT) {
+				/*Main Ant to  WiFi for IPS case 0x4c[23] = 1*/
+				btcoexist->btc_write_1byte_bitmask(btcoexist,
+								   0x64, 0x1,
+								   0x0);
+
+				/*tell firmware "no antenna inverse"*/
+				h2c_parameter[0] = 0;
+				h2c_parameter[1] = 0;  /*internal switch type*/
+				btcoexist->btc_fill_h2c(btcoexist, 0x65, 2,
+							h2c_parameter);
+			} else {
+				/*Aux Ant to  BT for IPS case 0x4c[23] = 1*/
+				btcoexist->btc_write_1byte_bitmask(btcoexist,
+								   0x64, 0x1,
+								   0x1);
+
+				/*tell firmware "antenna inverse"*/
+				h2c_parameter[0] = 1;
+				h2c_parameter[1] = 0;  /*internal switch type*/
+				btcoexist->btc_fill_h2c(btcoexist, 0x65, 2,
+							h2c_parameter);
+			}
+		}
+
+		/* fixed external switch first*/
+		/*Main->WiFi, Aux->BT*/
+		if (brd_info->btdm_ant_pos == BTC_ANTENNA_AT_MAIN_PORT)
+			btcoexist->btc_write_1byte_bitmask(btcoexist, 0x92c,
+							   0x3, 0x1);
+		else/*Main->BT, Aux->WiFi */
+			btcoexist->btc_write_1byte_bitmask(btcoexist, 0x92c,
+							   0x3, 0x2);
+
+		/* internal switch setting*/
+		switch (ant_pos_type) {
+		case BTC_ANT_PATH_WIFI:
+			if (brd_info->btdm_ant_pos == BTC_ANTENNA_AT_MAIN_PORT)
+				btcoexist->btc_write_2byte(btcoexist, 0x948,
+							   0x0);
+			else
+				btcoexist->btc_write_2byte(btcoexist, 0x948,
+							   0x280);
+			break;
+		case BTC_ANT_PATH_BT:
+			if (brd_info->btdm_ant_pos == BTC_ANTENNA_AT_MAIN_PORT)
+				btcoexist->btc_write_2byte(btcoexist, 0x948,
+							   0x280);
+			else
+				btcoexist->btc_write_2byte(btcoexist, 0x948,
+							   0x0);
+			break;
+		default:
+		case BTC_ANT_PATH_PTA:
+			if (brd_info->btdm_ant_pos == BTC_ANTENNA_AT_MAIN_PORT)
+				btcoexist->btc_write_2byte(btcoexist, 0x948,
+							   0x200);
+			else
+				btcoexist->btc_write_2byte(btcoexist, 0x948,
+							   0x80);
+			break;
+		}
+	}
+}
+
+static void halbtc8723b1ant_ps_tdma(struct btc_coexist *btcoexist,
+				    bool force_exec, bool turn_on, u8 type)
+{
+	bool wifi_busy = false;
+	u8 rssi_adjust_val = 0;
+
+	coex_dm->cur_ps_tdma_on = turn_on;
+	coex_dm->cur_ps_tdma = type;
+
+	btcoexist->btc_get(btcoexist, BTC_GET_BL_WIFI_BUSY, &wifi_busy);
+
+	if (!force_exec) {
+		if (coex_dm->cur_ps_tdma_on)
+			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_DETAIL,
+				  "[BTCoex], ******** TDMA(on, %d) *********\n",
+				  coex_dm->cur_ps_tdma);
+		else
+			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_DETAIL,
+				  "[BTCoex], ******** TDMA(off, %d) ********\n",
+				  coex_dm->cur_ps_tdma);
+
+		if ((coex_dm->pre_ps_tdma_on == coex_dm->cur_ps_tdma_on) &&
+		    (coex_dm->pre_ps_tdma == coex_dm->cur_ps_tdma))
+			return;
+	}
+	if (turn_on) {
+		switch (type) {
+		default:
+			halbtc8723b1ant_set_fw_ps_tdma(btcoexist, 0x51, 0x1a,
+						       0x1a, 0x0, 0x50);
+			break;
+		case 1:
+			halbtc8723b1ant_set_fw_ps_tdma(btcoexist, 0x51, 0x3a,
+						       0x03, 0x10, 0x50);
+
+			rssi_adjust_val = 11;
+			break;
+		case 2:
+			halbtc8723b1ant_set_fw_ps_tdma(btcoexist, 0x51, 0x2b,
+						       0x03, 0x10, 0x50);
+			rssi_adjust_val = 14;
+			break;
+		case 3:
+			halbtc8723b1ant_set_fw_ps_tdma(btcoexist, 0x51, 0x1d,
+						       0x1d, 0x0, 0x52);
+			break;
+		case 4:
+			halbtc8723b1ant_set_fw_ps_tdma(btcoexist, 0x93, 0x15,
+						       0x3, 0x14, 0x0);
+			rssi_adjust_val = 17;
+			break;
+		case 5:
+			halbtc8723b1ant_set_fw_ps_tdma(btcoexist, 0x61, 0x15,
+						       0x3, 0x11, 0x10);
+			break;
+		case 6:
+			halbtc8723b1ant_set_fw_ps_tdma(btcoexist, 0x61, 0x20,
+						       0x3, 0x11, 0x13);
+			break;
+		case 7:
+			halbtc8723b1ant_set_fw_ps_tdma(btcoexist, 0x13, 0xc,
+						       0x5, 0x0, 0x0);
+			break;
+		case 8:
+			halbtc8723b1ant_set_fw_ps_tdma(btcoexist, 0x93, 0x25,
+						       0x3, 0x10, 0x0);
+			break;
+		case 9:
+			halbtc8723b1ant_set_fw_ps_tdma(btcoexist, 0x51,  0x21,
+						       0x3, 0x10, 0x50);
+			rssi_adjust_val = 18;
+			break;
+		case 10:
+			halbtc8723b1ant_set_fw_ps_tdma(btcoexist, 0x13, 0xa,
+						       0xa, 0x0, 0x40);
+			break;
+		case 11:
+			halbtc8723b1ant_set_fw_ps_tdma(btcoexist, 0x51, 0x15,
+						       0x03, 0x10, 0x50);
+			rssi_adjust_val = 20;
+			break;
+		case 12:
+			halbtc8723b1ant_set_fw_ps_tdma(btcoexist, 0x51, 0x0a,
+						       0x0a, 0x0, 0x50);
+			break;
+		case 13:
+			halbtc8723b1ant_set_fw_ps_tdma(btcoexist, 0x51, 0x15,
+						       0x15, 0x0, 0x50);
+			break;
+		case 14:
+			halbtc8723b1ant_set_fw_ps_tdma(btcoexist, 0x51, 0x21,
+						       0x3, 0x10, 0x52);
+			break;
+		case 15:
+			halbtc8723b1ant_set_fw_ps_tdma(btcoexist, 0x13, 0xa,
+						       0x3, 0x8, 0x0);
+			break;
+		case 16:
+			halbtc8723b1ant_set_fw_ps_tdma(btcoexist, 0x93, 0x15,
+						       0x3, 0x10, 0x0);
+			rssi_adjust_val = 18;
+			break;
+		case 18:
+			halbtc8723b1ant_set_fw_ps_tdma(btcoexist, 0x93, 0x25,
+						       0x3, 0x10, 0x0);
+			rssi_adjust_val = 14;
+			break;
+		case 20:
+			halbtc8723b1ant_set_fw_ps_tdma(btcoexist, 0x61, 0x35,
+						       0x03, 0x11, 0x10);
+			break;
+		case 21:
+			halbtc8723b1ant_set_fw_ps_tdma(btcoexist, 0x61, 0x25,
+						       0x03, 0x11, 0x11);
+			break;
+		case 22:
+			halbtc8723b1ant_set_fw_ps_tdma(btcoexist, 0x61, 0x25,
+						       0x03, 0x11, 0x10);
+			break;
+		case 23:
+			halbtc8723b1ant_set_fw_ps_tdma(btcoexist, 0xe3, 0x25,
+						       0x3, 0x31, 0x18);
+			rssi_adjust_val = 22;
+			break;
+		case 24:
+			halbtc8723b1ant_set_fw_ps_tdma(btcoexist, 0xe3, 0x15,
+						       0x3, 0x31, 0x18);
+			rssi_adjust_val = 22;
+			break;
+		case 25:
+			halbtc8723b1ant_set_fw_ps_tdma(btcoexist, 0xe3, 0xa,
+						       0x3, 0x31, 0x18);
+			rssi_adjust_val = 22;
+			break;
+		case 26:
+			halbtc8723b1ant_set_fw_ps_tdma(btcoexist, 0xe3, 0xa,
+						       0x3, 0x31, 0x18);
+			rssi_adjust_val = 22;
+			break;
+		case 27:
+			halbtc8723b1ant_set_fw_ps_tdma(btcoexist, 0xe3, 0x25,
+						       0x3, 0x31, 0x98);
+			rssi_adjust_val = 22;
+			break;
+		case 28:
+			halbtc8723b1ant_set_fw_ps_tdma(btcoexist, 0x69, 0x25,
+						       0x3, 0x31, 0x0);
+			break;
+		case 29:
+			halbtc8723b1ant_set_fw_ps_tdma(btcoexist, 0xab, 0x1a,
+						       0x1a, 0x1, 0x10);
+			break;
+		case 30:
+			halbtc8723b1ant_set_fw_ps_tdma(btcoexist, 0x51, 0x14,
+						       0x3, 0x10, 0x50);
+			break;
+		case 31:
+			halbtc8723b1ant_set_fw_ps_tdma(btcoexist, 0xd3, 0x1a,
+						       0x1a, 0, 0x58);
+			break;
+		case 32:
+			halbtc8723b1ant_set_fw_ps_tdma(btcoexist, 0x61, 0xa,
+						       0x3, 0x10, 0x0);
+			break;
+		case 33:
+			halbtc8723b1ant_set_fw_ps_tdma(btcoexist, 0xa3, 0x25,
+						       0x3, 0x30, 0x90);
+			break;
+		case 34:
+			halbtc8723b1ant_set_fw_ps_tdma(btcoexist, 0x53, 0x1a,
+						       0x1a, 0x0, 0x10);
+			break;
+		case 35:
+			halbtc8723b1ant_set_fw_ps_tdma(btcoexist, 0x63, 0x1a,
+						       0x1a, 0x0, 0x10);
+			break;
+		case 36:
+			halbtc8723b1ant_set_fw_ps_tdma(btcoexist, 0xd3, 0x12,
+						       0x3, 0x14, 0x50);
+			break;
+		/* SoftAP only with no sta associated, BT disable ,
+		 * TDMA mode for power saving
+		 * here softap mode screen off will cost 70-80mA for phone */
+		case 40:
+			halbtc8723b1ant_set_fw_ps_tdma(btcoexist, 0x23, 0x18,
+						       0x00, 0x10, 0x24);
+			break;
+		}
+	} else {
+		switch (type) {
+		case 8: /*PTA Control */
+			halbtc8723b1ant_set_fw_ps_tdma(btcoexist, 0x8, 0x0,
+						       0x0, 0x0, 0x0);
+			halbtc8723b1ant_setantpath(btcoexist, BTC_ANT_PATH_PTA,
+						   false, false);
+			break;
+		case 0:
+		default:  /*Software control, Antenna at BT side */
+			halbtc8723b1ant_set_fw_ps_tdma(btcoexist, 0x0, 0x0,
+						       0x0, 0x0, 0x0);
+			halbtc8723b1ant_setantpath(btcoexist, BTC_ANT_PATH_BT,
+						   false, false);
+			break;
+		case 9:   /*Software control, Antenna at WiFi side */
+			halbtc8723b1ant_set_fw_ps_tdma(btcoexist, 0x0, 0x0,
+						       0x0, 0x0, 0x0);
+			halbtc8723b1ant_setantpath(btcoexist, BTC_ANT_PATH_WIFI,
+						   false, false);
+			break;
+		}
+	}
+	rssi_adjust_val = 0;
+	btcoexist->btc_set(btcoexist,
+			   BTC_SET_U1_RSSI_ADJ_VAL_FOR_1ANT_COEX_TYPE,
+			   &rssi_adjust_val);
+
+	/* update pre state */
+	coex_dm->pre_ps_tdma_on = coex_dm->cur_ps_tdma_on;
+	coex_dm->pre_ps_tdma = coex_dm->cur_ps_tdma;
+}
+
+static bool halbtc8723b1ant_is_common_action(struct btc_coexist *btcoexist)
+{
+	bool commom = false, wifi_connected = false;
+	bool wifi_busy = false;
+
+	btcoexist->btc_get(btcoexist, BTC_GET_BL_WIFI_CONNECTED,
+			   &wifi_connected);
+	btcoexist->btc_get(btcoexist, BTC_GET_BL_WIFI_BUSY, &wifi_busy);
+
+	if (!wifi_connected &&
+	    BT_8723B_1ANT_BT_STATUS_NON_CONNECTED_IDLE == coex_dm->bt_status) {
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+			  "[BTCoex], Wifi non connected-idle + BT non connected-idle!!\n");
+		halbtc8723b1ant_sw_mechanism(btcoexist, false);
+		commom = true;
+	} else if (wifi_connected &&
+		   (BT_8723B_1ANT_BT_STATUS_NON_CONNECTED_IDLE ==
+		    coex_dm->bt_status)) {
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+			  "[BTCoex], Wifi connected + BT non connected-idle!!\n");
+		halbtc8723b1ant_sw_mechanism(btcoexist, false);
+		commom = true;
+	} else if (!wifi_connected &&
+		   (BT_8723B_1ANT_BT_STATUS_CONNECTED_IDLE ==
+		    coex_dm->bt_status)) {
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+			  "[BTCoex], Wifi non connected-idle + BT connected-idle!!\n");
+		halbtc8723b1ant_sw_mechanism(btcoexist, false);
+		commom = true;
+	} else if (wifi_connected &&
+		   (BT_8723B_1ANT_BT_STATUS_CONNECTED_IDLE ==
+		    coex_dm->bt_status)) {
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+			  "[BTCoex], Wifi connected + BT connected-idle!!\n");
+		halbtc8723b1ant_sw_mechanism(btcoexist, false);
+		commom = true;
+	} else if (!wifi_connected &&
+		   (BT_8723B_1ANT_BT_STATUS_CONNECTED_IDLE !=
+		    coex_dm->bt_status)) {
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+			  ("[BTCoex], Wifi non connected-idle + BT Busy!!\n"));
+		halbtc8723b1ant_sw_mechanism(btcoexist, false);
+		commom = true;
+	} else {
+		if (wifi_busy)
+			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+				  "[BTCoex], Wifi Connected-Busy + BT Busy!!\n");
+		else
+			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+				  "[BTCoex], Wifi Connected-Idle + BT Busy!!\n");
+
+		commom = false;
+	}
+
+	return commom;
+}
+
+static void tdma_duration_adjust_for_acl(struct btc_coexist *btcoexist,
+					 u8 wifi_status)
+{
+	static s32 up, dn, m, n, wait_count;
+	/* 0: no change, +1: increase WiFi duration,
+	 * -1: decrease WiFi duration */
+	s32 result;
+	u8 retry_count = 0, bt_info_ext;
+	bool wifi_busy = false;
+
+	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW,
+		  "[BTCoex], TdmaDurationAdjustForAcl()\n");
+
+	if (BT_8723B_1ANT_WIFI_STATUS_CONNECTED_BUSY == wifi_status)
+		wifi_busy = true;
+	else
+		wifi_busy = false;
+
+	if ((BT_8723B_1ANT_WIFI_STATUS_NON_CONNECTED_ASSO_AUTH_SCAN ==
+							 wifi_status) ||
+	    (BT_8723B_1ANT_WIFI_STATUS_CONNECTED_SCAN == wifi_status) ||
+	    (BT_8723B_1ANT_WIFI_STATUS_CONNECTED_SPECIAL_PKT == wifi_status)) {
+		if (coex_dm->cur_ps_tdma != 1 && coex_dm->cur_ps_tdma != 2 &&
+		    coex_dm->cur_ps_tdma != 3 && coex_dm->cur_ps_tdma != 9) {
+			halbtc8723b1ant_ps_tdma(btcoexist, NORMAL_EXEC,
+						true, 9);
+			coex_dm->ps_tdma_du_adj_type = 9;
+
+			up = 0;
+			dn = 0;
+			m = 1;
+			n = 3;
+			result = 0;
+			wait_count = 0;
+		}
+		return;
+	}
+
+	if (!coex_dm->auto_tdma_adjust) {
+		coex_dm->auto_tdma_adjust = true;
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_DETAIL,
+			  "[BTCoex], first run TdmaDurationAdjust()!!\n");
+
+		halbtc8723b1ant_ps_tdma(btcoexist, NORMAL_EXEC, true, 2);
+		coex_dm->ps_tdma_du_adj_type = 2;
+
+		up = 0;
+		dn = 0;
+		m = 1;
+		n = 3;
+		result = 0;
+		wait_count = 0;
+	} else {
+		/*accquire the BT TRx retry count from BT_Info byte2 */
+		retry_count = coex_sta->bt_retry_cnt;
+		bt_info_ext = coex_sta->bt_info_ext;
+		result = 0;
+		wait_count++;
+		/* no retry in the last 2-second duration */
+		if (retry_count == 0) {
+			up++;
+			dn--;
+
+			if (dn <= 0)
+				dn = 0;
+
+			if (up >= n) {
+				wait_count = 0;
+				n = 3;
+				up = 0;
+				dn = 0;
+				result = 1;
+				BTC_PRINT(BTC_MSG_ALGORITHM,
+					  ALGO_TRACE_FW_DETAIL,
+					  "[BTCoex], Increase wifi duration!!\n");
+			}
+		} else if (retry_count <= 3) {
+			up--;
+			dn++;
+
+			if (up <= 0)
+				up = 0;
+
+			if (dn == 2) {
+				if (wait_count <= 2)
+					m++;
+				else
+					m = 1;
+
+				if (m >= 20)
+					m = 20;
+
+				n = 3 * m;
+				up = 0;
+				dn = 0;
+				wait_count = 0;
+				result = -1;
+				BTC_PRINT(BTC_MSG_ALGORITHM,
+					  ALGO_TRACE_FW_DETAIL,
+					  "[BTCoex], Decrease wifi duration for retryCounter<3!!\n");
+			}
+		} else {
+			if (wait_count == 1)
+				m++;
+			else
+				m = 1;
+
+			if (m >= 20)
+				m = 20;
+
+			n = 3 * m;
+			up = 0;
+			dn = 0;
+			wait_count = 0;
+			result = -1;
+			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_DETAIL,
+				  "[BTCoex], Decrease wifi duration for retryCounter>3!!\n");
+		}
+
+		if (result == -1) {
+			if ((BT_INFO_8723B_1ANT_A2DP_BASIC_RATE(bt_info_ext)) &&
+			    ((coex_dm->cur_ps_tdma == 1) ||
+			     (coex_dm->cur_ps_tdma == 2))) {
+				halbtc8723b1ant_ps_tdma(btcoexist, NORMAL_EXEC,
+							true, 9);
+				coex_dm->ps_tdma_du_adj_type = 9;
+			} else if (coex_dm->cur_ps_tdma == 1) {
+				halbtc8723b1ant_ps_tdma(btcoexist, NORMAL_EXEC,
+							true, 2);
+				coex_dm->ps_tdma_du_adj_type = 2;
+			} else if (coex_dm->cur_ps_tdma == 2) {
+				halbtc8723b1ant_ps_tdma(btcoexist, NORMAL_EXEC,
+							true, 9);
+				coex_dm->ps_tdma_du_adj_type = 9;
+			} else if (coex_dm->cur_ps_tdma == 9) {
+				halbtc8723b1ant_ps_tdma(btcoexist, NORMAL_EXEC,
+							true, 11);
+				coex_dm->ps_tdma_du_adj_type = 11;
+			}
+		} else if (result == 1) {
+			if ((BT_INFO_8723B_1ANT_A2DP_BASIC_RATE(bt_info_ext)) &&
+			    ((coex_dm->cur_ps_tdma == 1) ||
+			     (coex_dm->cur_ps_tdma == 2))) {
+				halbtc8723b1ant_ps_tdma(btcoexist, NORMAL_EXEC,
+							true, 9);
+				coex_dm->ps_tdma_du_adj_type = 9;
+			} else if (coex_dm->cur_ps_tdma == 11) {
+				halbtc8723b1ant_ps_tdma(btcoexist, NORMAL_EXEC,
+							true, 9);
+				coex_dm->ps_tdma_du_adj_type = 9;
+			} else if (coex_dm->cur_ps_tdma == 9) {
+				halbtc8723b1ant_ps_tdma(btcoexist, NORMAL_EXEC,
+							true, 2);
+				coex_dm->ps_tdma_du_adj_type = 2;
+			} else if (coex_dm->cur_ps_tdma == 2) {
+				halbtc8723b1ant_ps_tdma(btcoexist, NORMAL_EXEC,
+							true, 1);
+				coex_dm->ps_tdma_du_adj_type = 1;
+			}
+		} else {	  /*no change */
+			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_DETAIL,
+				  "[BTCoex],********* TDMA(on, %d) ********\n",
+				  coex_dm->cur_ps_tdma);
+		}
+
+		if (coex_dm->cur_ps_tdma != 1 && coex_dm->cur_ps_tdma != 2 &&
+		    coex_dm->cur_ps_tdma != 9 && coex_dm->cur_ps_tdma != 11) {
+			/* recover to previous adjust type */
+			halbtc8723b1ant_ps_tdma(btcoexist, NORMAL_EXEC, true,
+						coex_dm->ps_tdma_du_adj_type);
+		}
+	}
+}
+
+static void pstdmacheckforpowersavestate(struct btc_coexist *btcoexist,
+					 bool new_ps_state)
+{
+	u8 lps_mode = 0x0;
+
+	btcoexist->btc_get(btcoexist, BTC_GET_U1_LPS_MODE, &lps_mode);
+
+	if (lps_mode) {	/* already under LPS state */
+		if (new_ps_state) {
+			/* keep state under LPS, do nothing. */
+		} else {
+			/* will leave LPS state, turn off psTdma first */
+			halbtc8723b1ant_ps_tdma(btcoexist, NORMAL_EXEC,
+						false, 0);
+		}
+	} else {	/* NO PS state */
+		if (new_ps_state) {
+			/* will enter LPS state, turn off psTdma first */
+			halbtc8723b1ant_ps_tdma(btcoexist, NORMAL_EXEC,
+						false, 0);
+		} else {
+			/* keep state under NO PS state, do nothing. */
+		}
+	}
+}
+
+static void halbtc8723b1ant_power_save_state(struct btc_coexist *btcoexist,
+					     u8 ps_type, u8 lps_val,
+					     u8 rpwm_val)
+{
+	bool low_pwr_disable = false;
+
+	switch (ps_type) {
+	case BTC_PS_WIFI_NATIVE:
+		/* recover to original 32k low power setting */
+		low_pwr_disable = false;
+		btcoexist->btc_set(btcoexist, BTC_SET_ACT_DISABLE_LOW_POWER,
+				   &low_pwr_disable);
+		btcoexist->btc_set(btcoexist, BTC_SET_ACT_NORMAL_LPS, NULL);
+		break;
+	case BTC_PS_LPS_ON:
+		pstdmacheckforpowersavestate(btcoexist, true);
+		halbtc8723b1ant_lpsrpwm(btcoexist, NORMAL_EXEC, lps_val,
+					rpwm_val);
+		/* when coex force to enter LPS, do not enter 32k low power. */
+		low_pwr_disable = true;
+		btcoexist->btc_set(btcoexist, BTC_SET_ACT_DISABLE_LOW_POWER,
+				   &low_pwr_disable);
+		/* power save must executed before psTdma.	 */
+		btcoexist->btc_set(btcoexist, BTC_SET_ACT_ENTER_LPS, NULL);
+		break;
+	case BTC_PS_LPS_OFF:
+		pstdmacheckforpowersavestate(btcoexist, false);
+		btcoexist->btc_set(btcoexist, BTC_SET_ACT_LEAVE_LPS, NULL);
+		break;
+	default:
+		break;
+	}
+}
+
+/***************************************************
+ *
+ *	Software Coex Mechanism start
+ *
+ ***************************************************/
+/* SCO only or SCO+PAN(HS) */
+static void halbtc8723b1ant_action_sco(struct btc_coexist *btcoexist)
+{
+	halbtc8723b1ant_sw_mechanism(btcoexist, true);
+}
+
+static void halbtc8723b1ant_action_hid(struct btc_coexist *btcoexist)
+{
+	halbtc8723b1ant_sw_mechanism(btcoexist, true);
+}
+
+/*A2DP only / PAN(EDR) only/ A2DP+PAN(HS) */
+static void halbtc8723b1ant_action_a2dp(struct btc_coexist *btcoexist)
+{
+	halbtc8723b1ant_sw_mechanism(btcoexist, false);
+}
+
+static void halbtc8723b1ant_action_a2dp_pan_hs(struct btc_coexist *btcoexist)
+{
+	halbtc8723b1ant_sw_mechanism(btcoexist, false);
+}
+
+static void halbtc8723b1ant_action_pan_edr(struct btc_coexist *btcoexist)
+{
+	halbtc8723b1ant_sw_mechanism(btcoexist, false);
+}
+
+/* PAN(HS) only */
+static void halbtc8723b1ant_action_pan_hs(struct btc_coexist *btcoexist)
+{
+	halbtc8723b1ant_sw_mechanism(btcoexist, false);
+}
+
+/*PAN(EDR)+A2DP */
+static void halbtc8723b1ant_action_pan_edr_a2dp(struct btc_coexist *btcoexist)
+{
+	halbtc8723b1ant_sw_mechanism(btcoexist, false);
+}
+
+static void halbtc8723b1ant_action_pan_edr_hid(struct btc_coexist *btcoexist)
+{
+	halbtc8723b1ant_sw_mechanism(btcoexist, true);
+}
+
+/* HID+A2DP+PAN(EDR) */
+static void action_hid_a2dp_pan_edr(struct btc_coexist *btcoexist)
+{
+	halbtc8723b1ant_sw_mechanism(btcoexist, true);
+}
+
+static void halbtc8723b1ant_action_hid_a2dp(struct btc_coexist *btcoexist)
+{
+	halbtc8723b1ant_sw_mechanism(btcoexist, true);
+}
+
+/*****************************************************
+ *
+ *	Non-Software Coex Mechanism start
+ *
+ *****************************************************/
+static void halbtc8723b1ant_action_wifi_multiport(struct btc_coexist *btcoexist)
+{
+	halbtc8723b1ant_power_save_state(btcoexist, BTC_PS_WIFI_NATIVE,
+					 0x0, 0x0);
+
+	halbtc8723b1ant_ps_tdma(btcoexist, NORMAL_EXEC, false, 8);
+	coex_table_with_type(btcoexist, NORMAL_EXEC, 2);
+}
+
+static void halbtc8723b1ant_action_hs(struct btc_coexist *btcoexist)
+{
+	halbtc8723b1ant_ps_tdma(btcoexist, NORMAL_EXEC, true, 5);
+	coex_table_with_type(btcoexist, NORMAL_EXEC, 2);
+}
+
+static void halbtc8723b1ant_action_bt_inquiry(struct btc_coexist *btcoexist)
+{
+	struct btc_bt_link_info *bt_link_info = &btcoexist->bt_link_info;
+	bool wifi_connected = false, ap_enable = false;
+
+	btcoexist->btc_get(btcoexist, BTC_GET_BL_WIFI_AP_MODE_ENABLE,
+			   &ap_enable);
+	btcoexist->btc_get(btcoexist, BTC_GET_BL_WIFI_CONNECTED,
+			   &wifi_connected);
+
+	if (!wifi_connected) {
+		halbtc8723b1ant_power_save_state(btcoexist,
+						 BTC_PS_WIFI_NATIVE, 0x0, 0x0);
+		halbtc8723b1ant_ps_tdma(btcoexist, NORMAL_EXEC, false, 8);
+		coex_table_with_type(btcoexist, NORMAL_EXEC, 2);
+	} else if (bt_link_info->sco_exist || bt_link_info->hid_only) {
+		/* SCO/HID-only busy */
+		halbtc8723b1ant_power_save_state(btcoexist, BTC_PS_WIFI_NATIVE,
+						 0x0, 0x0);
+		halbtc8723b1ant_ps_tdma(btcoexist, NORMAL_EXEC, true, 32);
+		coex_table_with_type(btcoexist, NORMAL_EXEC, 1);
+	} else {
+		if (ap_enable)
+			halbtc8723b1ant_power_save_state(btcoexist,
+							 BTC_PS_WIFI_NATIVE,
+							 0x0, 0x0);
+		else
+			halbtc8723b1ant_power_save_state(btcoexist,
+							 BTC_PS_LPS_ON,
+							 0x50, 0x4);
+
+		halbtc8723b1ant_ps_tdma(btcoexist, NORMAL_EXEC, true, 30);
+		coex_table_with_type(btcoexist, NORMAL_EXEC, 1);
+	}
+}
+
+static void action_bt_sco_hid_only_busy(struct btc_coexist *btcoexist,
+					u8 wifi_status)
+{
+	struct btc_bt_link_info *bt_link_info = &btcoexist->bt_link_info;
+	bool wifi_connected = false;
+
+	btcoexist->btc_get(btcoexist, BTC_GET_BL_WIFI_CONNECTED,
+			   &wifi_connected);
+
+	/* tdma and coex table */
+
+	if (bt_link_info->sco_exist) {
+		halbtc8723b1ant_ps_tdma(btcoexist, NORMAL_EXEC, true, 5);
+		coex_table_with_type(btcoexist, NORMAL_EXEC, 2);
+	} else { /* HID */
+		halbtc8723b1ant_ps_tdma(btcoexist, NORMAL_EXEC, true, 6);
+		coex_table_with_type(btcoexist, NORMAL_EXEC, 5);
+	}
+}
+
+static void halbtc8723b1ant_action_wifi_connected_bt_acl_busy(
+					struct btc_coexist *btcoexist,
+					u8 wifi_status)
+{
+	struct btc_bt_link_info *bt_link_info = &btcoexist->bt_link_info;
+	u8 rssi_state;
+
+	rssi_state = halbtc8723b1ant_bt_rssi_state(2, 28, 0);
+
+	if (bt_link_info->hid_only) {  /*HID */
+		action_bt_sco_hid_only_busy(btcoexist, wifi_status);
+		coex_dm->auto_tdma_adjust = false;
+		return;
+	} else if (bt_link_info->a2dp_only) { /*A2DP */
+		if (BT_8723B_1ANT_WIFI_STATUS_CONNECTED_IDLE == wifi_status) {
+			halbtc8723b1ant_ps_tdma(btcoexist, NORMAL_EXEC, false,
+						8);
+			coex_table_with_type(btcoexist, NORMAL_EXEC, 2);
+			coex_dm->auto_tdma_adjust = false;
+		} else if ((rssi_state == BTC_RSSI_STATE_HIGH) ||
+			   (rssi_state == BTC_RSSI_STATE_STAY_HIGH)) {
+			tdma_duration_adjust_for_acl(btcoexist, wifi_status);
+			coex_table_with_type(btcoexist, NORMAL_EXEC, 1);
+		} else { /*for low BT RSSI */
+			halbtc8723b1ant_ps_tdma(btcoexist, NORMAL_EXEC,
+						true, 11);
+			coex_table_with_type(btcoexist, NORMAL_EXEC, 1);
+			coex_dm->auto_tdma_adjust = false;
+		}
+	} else if (bt_link_info->hid_exist &&
+		   bt_link_info->a2dp_exist) { /*HID+A2DP */
+		if ((rssi_state == BTC_RSSI_STATE_HIGH) ||
+		    (rssi_state == BTC_RSSI_STATE_STAY_HIGH)) {
+			halbtc8723b1ant_ps_tdma(btcoexist, NORMAL_EXEC,
+						true, 14);
+			coex_dm->auto_tdma_adjust = false;
+		} else { /*for low BT RSSI*/
+			halbtc8723b1ant_ps_tdma(btcoexist, NORMAL_EXEC,
+						true, 14);
+			coex_dm->auto_tdma_adjust = false;
+		}
+
+		coex_table_with_type(btcoexist, NORMAL_EXEC, 6);
+	 /*PAN(OPP, FTP), HID+PAN(OPP, FTP) */
+	} else if (bt_link_info->pan_only ||
+		   (bt_link_info->hid_exist && bt_link_info->pan_exist)) {
+		halbtc8723b1ant_ps_tdma(btcoexist, NORMAL_EXEC, true, 3);
+		coex_table_with_type(btcoexist, NORMAL_EXEC, 6);
+		coex_dm->auto_tdma_adjust = false;
+	 /*A2DP+PAN(OPP, FTP), HID+A2DP+PAN(OPP, FTP)*/
+	} else if ((bt_link_info->a2dp_exist && bt_link_info->pan_exist) ||
+		   (bt_link_info->hid_exist && bt_link_info->a2dp_exist &&
+		    bt_link_info->pan_exist)) {
+		halbtc8723b1ant_ps_tdma(btcoexist, NORMAL_EXEC, true, 13);
+		coex_table_with_type(btcoexist, NORMAL_EXEC, 1);
+		coex_dm->auto_tdma_adjust = false;
+	} else {
+		halbtc8723b1ant_ps_tdma(btcoexist, NORMAL_EXEC, true, 11);
+		coex_table_with_type(btcoexist, NORMAL_EXEC, 1);
+		coex_dm->auto_tdma_adjust = false;
+	}
+}
+
+static void action_wifi_not_connected(struct btc_coexist *btcoexist)
+{
+	/* power save state */
+	halbtc8723b1ant_power_save_state(btcoexist, BTC_PS_WIFI_NATIVE,
+					 0x0, 0x0);
+
+	/* tdma and coex table */
+	halbtc8723b1ant_ps_tdma(btcoexist, NORMAL_EXEC, false, 8);
+	coex_table_with_type(btcoexist, NORMAL_EXEC, 0);
+}
+
+static void action_wifi_not_connected_scan(struct btc_coexist *btcoexist)
+{
+	struct btc_bt_link_info *bt_link_info = &btcoexist->bt_link_info;
+	halbtc8723b1ant_power_save_state(btcoexist, BTC_PS_WIFI_NATIVE,
+					 0x0, 0x0);
+
+	/* tdma and coex table */
+	if (BT_8723B_1ANT_BT_STATUS_ACL_BUSY == coex_dm->bt_status) {
+		if (bt_link_info->a2dp_exist && bt_link_info->pan_exist) {
+			halbtc8723b1ant_ps_tdma(btcoexist, NORMAL_EXEC,
+						true, 22);
+			coex_table_with_type(btcoexist, NORMAL_EXEC, 1);
+		} else if (bt_link_info->pan_only) {
+			halbtc8723b1ant_ps_tdma(btcoexist, NORMAL_EXEC,
+						true, 20);
+			coex_table_with_type(btcoexist, NORMAL_EXEC, 2);
+		} else {
+			halbtc8723b1ant_ps_tdma(btcoexist, NORMAL_EXEC,
+						true, 20);
+			coex_table_with_type(btcoexist, NORMAL_EXEC, 1);
+		}
+	} else if ((BT_8723B_1ANT_BT_STATUS_SCO_BUSY == coex_dm->bt_status) ||
+		   (BT_8723B_1ANT_BT_STATUS_ACL_SCO_BUSY ==
+		    coex_dm->bt_status)) {
+		action_bt_sco_hid_only_busy(btcoexist,
+				BT_8723B_1ANT_WIFI_STATUS_CONNECTED_SCAN);
+	} else {
+		halbtc8723b1ant_ps_tdma(btcoexist, NORMAL_EXEC, false, 8);
+		coex_table_with_type(btcoexist, NORMAL_EXEC, 2);
+	}
+}
+
+static void action_wifi_not_connected_asso_auth(struct btc_coexist *btcoexist)
+{
+	struct btc_bt_link_info *bt_link_info = &btcoexist->bt_link_info;
+
+	halbtc8723b1ant_power_save_state(btcoexist, BTC_PS_WIFI_NATIVE,
+					 0x0, 0x0);
+
+	if ((BT_8723B_1ANT_BT_STATUS_CONNECTED_IDLE == coex_dm->bt_status) ||
+	    (bt_link_info->sco_exist) || (bt_link_info->hid_only) ||
+	    (bt_link_info->a2dp_only) || (bt_link_info->pan_only)) {
+		halbtc8723b1ant_ps_tdma(btcoexist, NORMAL_EXEC, false, 8);
+		coex_table_with_type(btcoexist, NORMAL_EXEC, 7);
+	} else {
+		halbtc8723b1ant_ps_tdma(btcoexist, NORMAL_EXEC, true, 20);
+		coex_table_with_type(btcoexist, NORMAL_EXEC, 1);
+	}
+}
+
+static void action_wifi_connected_scan(struct btc_coexist *btcoexist)
+{
+	struct btc_bt_link_info *bt_link_info = &btcoexist->bt_link_info;
+
+	halbtc8723b1ant_power_save_state(btcoexist, BTC_PS_WIFI_NATIVE,
+					 0x0, 0x0);
+
+	/* tdma and coex table */
+	if (BT_8723B_1ANT_BT_STATUS_ACL_BUSY == coex_dm->bt_status) {
+		if (bt_link_info->a2dp_exist && bt_link_info->pan_exist) {
+			halbtc8723b1ant_ps_tdma(btcoexist, NORMAL_EXEC,
+						true, 22);
+			coex_table_with_type(btcoexist, NORMAL_EXEC, 1);
+		} else if (bt_link_info->pan_only) {
+			halbtc8723b1ant_ps_tdma(btcoexist, NORMAL_EXEC,
+						true, 20);
+			coex_table_with_type(btcoexist, NORMAL_EXEC, 2);
+		} else {
+			halbtc8723b1ant_ps_tdma(btcoexist, NORMAL_EXEC,
+						true, 20);
+			coex_table_with_type(btcoexist, NORMAL_EXEC, 1);
+		}
+	} else if ((BT_8723B_1ANT_BT_STATUS_SCO_BUSY == coex_dm->bt_status) ||
+		   (BT_8723B_1ANT_BT_STATUS_ACL_SCO_BUSY ==
+		    coex_dm->bt_status)) {
+		action_bt_sco_hid_only_busy(btcoexist,
+				BT_8723B_1ANT_WIFI_STATUS_CONNECTED_SCAN);
+	} else {
+		halbtc8723b1ant_ps_tdma(btcoexist, NORMAL_EXEC, false, 8);
+		coex_table_with_type(btcoexist, NORMAL_EXEC, 2);
+	}
+}
+
+static void action_wifi_connected_special_packet(struct btc_coexist *btcoexist)
+{
+	bool hs_connecting = false;
+	struct btc_bt_link_info *bt_link_info = &btcoexist->bt_link_info;
+
+	btcoexist->btc_get(btcoexist, BTC_GET_BL_HS_CONNECTING, &hs_connecting);
+
+	halbtc8723b1ant_power_save_state(btcoexist, BTC_PS_WIFI_NATIVE,
+					 0x0, 0x0);
+
+	/* tdma and coex table */
+	if ((BT_8723B_1ANT_BT_STATUS_CONNECTED_IDLE == coex_dm->bt_status) ||
+	    (bt_link_info->sco_exist) || (bt_link_info->hid_only) ||
+	    (bt_link_info->a2dp_only) || (bt_link_info->pan_only)) {
+		halbtc8723b1ant_ps_tdma(btcoexist, NORMAL_EXEC, false, 8);
+		coex_table_with_type(btcoexist, NORMAL_EXEC, 7);
+	} else {
+		halbtc8723b1ant_ps_tdma(btcoexist, NORMAL_EXEC, true, 20);
+		coex_table_with_type(btcoexist, NORMAL_EXEC, 1);
+	}
+}
+
+static void halbtc8723b1ant_action_wifi_connected(struct btc_coexist *btcoexist)
+{
+	bool wifi_busy = false;
+	bool scan = false, link = false, roam = false;
+	bool under_4way = false, ap_enable = false;
+
+	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+		  "[BTCoex], CoexForWifiConnect() ===>\n");
+
+	btcoexist->btc_get(btcoexist, BTC_GET_BL_WIFI_4_WAY_PROGRESS,
+			   &under_4way);
+	if (under_4way) {
+		action_wifi_connected_special_packet(btcoexist);
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+			  "[BTCoex], CoexForWifiConnect(), return for wifi is under 4way<===\n");
+		return;
+	}
+
+	btcoexist->btc_get(btcoexist, BTC_GET_BL_WIFI_SCAN, &scan);
+	btcoexist->btc_get(btcoexist, BTC_GET_BL_WIFI_LINK, &link);
+	btcoexist->btc_get(btcoexist, BTC_GET_BL_WIFI_ROAM, &roam);
+
+	if (scan || link || roam) {
+		if (scan)
+			action_wifi_connected_scan(btcoexist);
+		else
+			action_wifi_connected_special_packet(btcoexist);
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+			  "[BTCoex], CoexForWifiConnect(), return for wifi is under scan<===\n");
+		return;
+	}
+
+	btcoexist->btc_get(btcoexist, BTC_GET_BL_WIFI_AP_MODE_ENABLE,
+			   &ap_enable);
+	btcoexist->btc_get(btcoexist, BTC_GET_BL_WIFI_BUSY, &wifi_busy);
+	/* power save state */
+	if (!ap_enable &&
+	    BT_8723B_1ANT_BT_STATUS_ACL_BUSY == coex_dm->bt_status &&
+	    !btcoexist->bt_link_info.hid_only) {
+		if (!wifi_busy && btcoexist->bt_link_info.a2dp_only)
+			halbtc8723b1ant_power_save_state(btcoexist,
+							 BTC_PS_WIFI_NATIVE,
+							 0x0, 0x0);
+		else
+			halbtc8723b1ant_power_save_state(btcoexist,
+							 BTC_PS_LPS_ON,
+							 0x50, 0x4);
+	} else {
+		halbtc8723b1ant_power_save_state(btcoexist, BTC_PS_WIFI_NATIVE,
+						 0x0, 0x0);
+	}
+	/* tdma and coex table */
+	if (!wifi_busy) {
+		if (BT_8723B_1ANT_BT_STATUS_ACL_BUSY == coex_dm->bt_status) {
+			halbtc8723b1ant_action_wifi_connected_bt_acl_busy(btcoexist,
+				      BT_8723B_1ANT_WIFI_STATUS_CONNECTED_IDLE);
+		} else if ((BT_8723B_1ANT_BT_STATUS_SCO_BUSY ==
+						coex_dm->bt_status) ||
+			   (BT_8723B_1ANT_BT_STATUS_ACL_SCO_BUSY ==
+						coex_dm->bt_status)) {
+			action_bt_sco_hid_only_busy(btcoexist,
+				     BT_8723B_1ANT_WIFI_STATUS_CONNECTED_IDLE);
+		} else {
+			halbtc8723b1ant_ps_tdma(btcoexist, NORMAL_EXEC,
+						false, 8);
+			coex_table_with_type(btcoexist, NORMAL_EXEC, 2);
+		}
+	} else {
+		if (BT_8723B_1ANT_BT_STATUS_ACL_BUSY == coex_dm->bt_status) {
+			halbtc8723b1ant_action_wifi_connected_bt_acl_busy(btcoexist,
+				    BT_8723B_1ANT_WIFI_STATUS_CONNECTED_BUSY);
+		} else if ((BT_8723B_1ANT_BT_STATUS_SCO_BUSY ==
+			    coex_dm->bt_status) ||
+			   (BT_8723B_1ANT_BT_STATUS_ACL_SCO_BUSY ==
+			    coex_dm->bt_status)) {
+			action_bt_sco_hid_only_busy(btcoexist,
+				    BT_8723B_1ANT_WIFI_STATUS_CONNECTED_BUSY);
+		} else {
+			halbtc8723b1ant_ps_tdma(btcoexist, NORMAL_EXEC, false, 8);
+			coex_table_with_type(btcoexist, NORMAL_EXEC, 2);
+		}
+	}
+}
+
+static void run_sw_coexist_mechanism(struct btc_coexist *btcoexist)
+{
+	u8 algorithm = 0;
+
+	algorithm = halbtc8723b1ant_action_algorithm(btcoexist);
+	coex_dm->cur_algorithm = algorithm;
+
+	if (!halbtc8723b1ant_is_common_action(btcoexist)) {
+		switch (coex_dm->cur_algorithm) {
+		case BT_8723B_1ANT_COEX_ALGO_SCO:
+			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+				  "[BTCoex], Action algorithm = SCO.\n");
+			halbtc8723b1ant_action_sco(btcoexist);
+			break;
+		case BT_8723B_1ANT_COEX_ALGO_HID:
+			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+				  "[BTCoex], Action algorithm = HID.\n");
+			halbtc8723b1ant_action_hid(btcoexist);
+			break;
+		case BT_8723B_1ANT_COEX_ALGO_A2DP:
+			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+				  "[BTCoex], Action algorithm = A2DP.\n");
+			halbtc8723b1ant_action_a2dp(btcoexist);
+			break;
+		case BT_8723B_1ANT_COEX_ALGO_A2DP_PANHS:
+			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+				  "[BTCoex], Action algorithm = A2DP+PAN(HS).\n");
+			halbtc8723b1ant_action_a2dp_pan_hs(btcoexist);
+			break;
+		case BT_8723B_1ANT_COEX_ALGO_PANEDR:
+			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+				  "[BTCoex], Action algorithm = PAN(EDR).\n");
+			halbtc8723b1ant_action_pan_edr(btcoexist);
+			break;
+		case BT_8723B_1ANT_COEX_ALGO_PANHS:
+			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+				  "[BTCoex], Action algorithm = HS mode.\n");
+			halbtc8723b1ant_action_pan_hs(btcoexist);
+			break;
+		case BT_8723B_1ANT_COEX_ALGO_PANEDR_A2DP:
+			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+				  "[BTCoex], Action algorithm = PAN+A2DP.\n");
+			halbtc8723b1ant_action_pan_edr_a2dp(btcoexist);
+			break;
+		case BT_8723B_1ANT_COEX_ALGO_PANEDR_HID:
+			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+				  "[BTCoex], Action algorithm = PAN(EDR)+HID.\n");
+			halbtc8723b1ant_action_pan_edr_hid(btcoexist);
+			break;
+		case BT_8723B_1ANT_COEX_ALGO_HID_A2DP_PANEDR:
+			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+				  "[BTCoex], Action algorithm = HID+A2DP+PAN.\n");
+			action_hid_a2dp_pan_edr(btcoexist);
+			break;
+		case BT_8723B_1ANT_COEX_ALGO_HID_A2DP:
+			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+				  "[BTCoex], Action algorithm = HID+A2DP.\n");
+			halbtc8723b1ant_action_hid_a2dp(btcoexist);
+			break;
+		default:
+			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+				  "[BTCoex], Action algorithm = coexist All Off!!\n");
+			break;
+		}
+		coex_dm->pre_algorithm = coex_dm->cur_algorithm;
+	}
+}
+
+static void halbtc8723b1ant_run_coexist_mechanism(struct btc_coexist *btcoexist)
+{
+	struct btc_bt_link_info *bt_link_info = &btcoexist->bt_link_info;
+	bool wifi_connected = false, bt_hs_on = false;
+	bool increase_scan_dev_num = false;
+	bool b_bt_ctrl_agg_buf_size = false;
+	u8 agg_buf_size = 5;
+	u8 wifi_rssi_state = BTC_RSSI_STATE_HIGH;
+	u32 wifi_link_status = 0;
+	u32 num_of_wifi_link = 0;
+
+	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+		  "[BTCoex], RunCoexistMechanism() ===>\n");
+
+	if (btcoexist->manual_control) {
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+			  "[BTCoex], RunCoexistMechanism(), return for Manual CTRL <===\n");
+		return;
+	}
+
+	if (btcoexist->stop_coex_dm) {
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+			  "[BTCoex], RunCoexistMechanism(), return for Stop Coex DM <===\n");
+		return;
+	}
+
+	if (coex_sta->under_ips) {
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+			  "[BTCoex], wifi is under IPS !!!\n");
+		return;
+	}
+
+	if ((BT_8723B_1ANT_BT_STATUS_ACL_BUSY == coex_dm->bt_status) ||
+	    (BT_8723B_1ANT_BT_STATUS_SCO_BUSY == coex_dm->bt_status) ||
+	    (BT_8723B_1ANT_BT_STATUS_ACL_SCO_BUSY == coex_dm->bt_status))
+		increase_scan_dev_num = true;
+
+	btcoexist->btc_set(btcoexist, BTC_SET_BL_INC_SCAN_DEV_NUM,
+			   &increase_scan_dev_num);
+
+	btcoexist->btc_get(btcoexist, BTC_GET_BL_WIFI_CONNECTED,
+			   &wifi_connected);
+
+	btcoexist->btc_get(btcoexist, BTC_GET_U4_WIFI_LINK_STATUS,
+			   &wifi_link_status);
+	num_of_wifi_link = wifi_link_status >> 16;
+	if (num_of_wifi_link >= 2) {
+		halbtc8723b1ant_limited_tx(btcoexist, NORMAL_EXEC, 0, 0, 0, 0);
+		halbtc8723b1ant_limited_rx(btcoexist, NORMAL_EXEC, false,
+					   b_bt_ctrl_agg_buf_size,
+					   agg_buf_size);
+		halbtc8723b1ant_action_wifi_multiport(btcoexist);
+		return;
+	}
+
+	if (!bt_link_info->sco_exist && !bt_link_info->hid_exist) {
+		halbtc8723b1ant_limited_tx(btcoexist, NORMAL_EXEC, 0, 0, 0, 0);
+	} else {
+		if (wifi_connected) {
+			wifi_rssi_state =
+				halbtc8723b1ant_wifi_rssi_state(btcoexist,
+								1, 2, 30, 0);
+			if ((wifi_rssi_state == BTC_RSSI_STATE_HIGH) ||
+			    (wifi_rssi_state == BTC_RSSI_STATE_STAY_HIGH)) {
+				halbtc8723b1ant_limited_tx(btcoexist,
+							   NORMAL_EXEC,
+							   1, 1, 1, 1);
+			} else {
+				halbtc8723b1ant_limited_tx(btcoexist,
+							   NORMAL_EXEC,
+							   1, 1, 1, 1);
+			}
+		} else {
+			halbtc8723b1ant_limited_tx(btcoexist, NORMAL_EXEC,
+						   0, 0, 0, 0);
+		}
+	}
+
+	if (bt_link_info->sco_exist) {
+		b_bt_ctrl_agg_buf_size = true;
+		agg_buf_size = 0x3;
+	} else if (bt_link_info->hid_exist) {
+		b_bt_ctrl_agg_buf_size = true;
+		agg_buf_size = 0x5;
+	} else if (bt_link_info->a2dp_exist || bt_link_info->pan_exist) {
+		b_bt_ctrl_agg_buf_size = true;
+		agg_buf_size = 0x8;
+	}
+	halbtc8723b1ant_limited_rx(btcoexist, NORMAL_EXEC, false,
+				   b_bt_ctrl_agg_buf_size, agg_buf_size);
+
+	run_sw_coexist_mechanism(btcoexist);
+
+	btcoexist->btc_get(btcoexist, BTC_GET_BL_HS_OPERATION, &bt_hs_on);
+
+	if (coex_sta->c2h_bt_inquiry_page) {
+		halbtc8723b1ant_action_bt_inquiry(btcoexist);
+		return;
+	} else if (bt_hs_on) {
+		halbtc8723b1ant_action_hs(btcoexist);
+		return;
+	}
+
+	if (!wifi_connected) {
+		bool scan = false, link = false, roam = false;
+
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+			  "[BTCoex], wifi is non connected-idle !!!\n");
+
+		btcoexist->btc_get(btcoexist, BTC_GET_BL_WIFI_SCAN, &scan);
+		btcoexist->btc_get(btcoexist, BTC_GET_BL_WIFI_LINK, &link);
+		btcoexist->btc_get(btcoexist, BTC_GET_BL_WIFI_ROAM, &roam);
+
+		if (scan || link || roam) {
+			if (scan)
+				action_wifi_not_connected_scan(btcoexist);
+			else
+				action_wifi_not_connected_asso_auth(btcoexist);
+		} else {
+			action_wifi_not_connected(btcoexist);
+		}
+	} else { /* wifi LPS/Busy */
+		halbtc8723b1ant_action_wifi_connected(btcoexist);
+	}
+}
+
+static void halbtc8723b1ant_init_coex_dm(struct btc_coexist *btcoexist)
+{
+	/* sw all off */
+	halbtc8723b1ant_sw_mechanism(btcoexist, false);
+
+	halbtc8723b1ant_ps_tdma(btcoexist, FORCE_EXEC, false, 8);
+	coex_table_with_type(btcoexist, FORCE_EXEC, 0);
+}
+
+static void init_hw_config(struct btc_coexist *btcoexist, bool backup)
+{
+	u32 u32tmp = 0;
+	u8 u8tmp = 0;
+	u32 cnt_bt_cal_chk = 0;
+
+	BTC_PRINT(BTC_MSG_INTERFACE, INTF_INIT,
+		  "[BTCoex], 1Ant Init HW Config!!\n");
+
+	if (backup) {/* backup rf 0x1e value */
+		coex_dm->backup_arfr_cnt1 =
+			btcoexist->btc_read_4byte(btcoexist, 0x430);
+		coex_dm->backup_arfr_cnt2 =
+			btcoexist->btc_read_4byte(btcoexist, 0x434);
+		coex_dm->backup_retry_limit =
+			btcoexist->btc_read_2byte(btcoexist, 0x42a);
+		coex_dm->backup_ampdu_max_time =
+			btcoexist->btc_read_1byte(btcoexist, 0x456);
+	}
+
+	/* WiFi goto standby while GNT_BT 0-->1 */
+	btcoexist->btc_set_rf_reg(btcoexist, BTC_RF_A, 0x1, 0xfffff, 0x780);
+	/* BT goto standby while GNT_BT 1-->0 */
+	btcoexist->btc_set_rf_reg(btcoexist, BTC_RF_A, 0x2, 0xfffff, 0x500);
+
+	btcoexist->btc_write_1byte(btcoexist, 0x974, 0xff);
+	btcoexist->btc_write_1byte_bitmask(btcoexist, 0x944, 0x3, 0x3);
+	btcoexist->btc_write_1byte(btcoexist, 0x930, 0x77);
+
+	/* BT calibration check */
+	while (cnt_bt_cal_chk <= 20) {
+		u32tmp = btcoexist->btc_read_4byte(btcoexist, 0x49d);
+		cnt_bt_cal_chk++;
+		if (u32tmp & BIT(0)) {
+			BTC_PRINT(BTC_MSG_INTERFACE, INTF_INIT,
+				  "[BTCoex], ########### BT calibration(cnt =%d) ###########\n",
+				  cnt_bt_cal_chk);
+			mdelay(50);
+		} else {
+			BTC_PRINT(BTC_MSG_INTERFACE, INTF_INIT,
+				  "[BTCoex], ********** BT NOT calibration (cnt =%d)**********\n",
+				  cnt_bt_cal_chk);
+			break;
+		}
+	}
+
+	/* 0x790[5:0] = 0x5 */
+	u8tmp = btcoexist->btc_read_1byte(btcoexist, 0x790);
+	u8tmp &= 0xc0;
+	u8tmp |= 0x5;
+	btcoexist->btc_write_1byte(btcoexist, 0x790, u8tmp);
+
+	/* Enable counter statistics */
+	/*0x76e[3] = 1, WLAN_Act control by PTA */
+	btcoexist->btc_write_1byte(btcoexist, 0x76e, 0xc);
+	btcoexist->btc_write_1byte(btcoexist, 0x778, 0x1);
+	btcoexist->btc_write_1byte_bitmask(btcoexist, 0x40, 0x20, 0x1);
+
+	/*Antenna config */
+	halbtc8723b1ant_setantpath(btcoexist, BTC_ANT_PATH_PTA, true, false);
+	/* PTA parameter */
+	coex_table_with_type(btcoexist, FORCE_EXEC, 0);
+}
+
+static void halbtc8723b1ant_wifi_off_hw_cfg(struct btc_coexist *btcoexist)
+{
+	/* set wlan_act to low */
+	btcoexist->btc_write_1byte(btcoexist, 0x76e, 0x4);
+}
+
+/**************************************************************
+ * work around function start with wa_halbtc8723b1ant_
+ **************************************************************/
+/**************************************************************
+ * extern function start with EXhalbtc8723b1ant_
+ **************************************************************/
+
+void ex_halbtc8723b1ant_init_hwconfig(struct btc_coexist *btcoexist)
+{
+	init_hw_config(btcoexist, true);
+}
+
+void ex_halbtc8723b1ant_init_coex_dm(struct btc_coexist *btcoexist)
+{
+	BTC_PRINT(BTC_MSG_INTERFACE, INTF_INIT,
+		  "[BTCoex], Coex Mechanism Init!!\n");
+
+	btcoexist->stop_coex_dm = false;
+
+	halbtc8723b1ant_init_coex_dm(btcoexist);
+
+	halbtc8723b1ant_query_bt_info(btcoexist);
+}
+
+void ex_halbtc8723b1ant_display_coex_info(struct btc_coexist *btcoexist)
+{
+	struct btc_board_info *brd_info = &btcoexist->board_info;
+	struct btc_stack_info *stack_info = &btcoexist->stack_info;
+	struct btc_bt_link_info *bt_link_info = &btcoexist->bt_link_info;
+	u8 *cli_buf = btcoexist->cli_buf;
+	u8 u8tmp[4], i, bt_info_ext, stdmacase = 0;
+	u16 u16tmp[4];
+	u32 u32tmp[4];
+	bool roam = false, scan = false;
+	bool link = false, wifi_under_5g = false;
+	bool bt_hs_on = false, wifi_busy = false;
+	s32 wifi_rssi = 0, bt_hs_rssi = 0;
+	u32 wifi_bw, wifi_traffic_dir, fa_ofdm, fa_cck, wifi_link_status;
+	u8 wifi_dot11_chnl, wifi_hs_chnl;
+	u32 fw_ver = 0, bt_patch_ver = 0;
+
+	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE,
+		   "\r\n ============[BT Coexist info] ============");
+	CL_PRINTF(cli_buf);
+
+	if (btcoexist->manual_control) {
+		CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE,
+			   "\r\n ============[Under Manual Control] ==========");
+		CL_PRINTF(cli_buf);
+		CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE,
+			   "\r\n ==========================================");
+		CL_PRINTF(cli_buf);
+	}
+	if (btcoexist->stop_coex_dm) {
+		CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE,
+			   "\r\n ============[Coex is STOPPED] ============");
+		CL_PRINTF(cli_buf);
+		CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE,
+			   "\r\n ==========================================");
+		CL_PRINTF(cli_buf);
+	}
+
+	if (!brd_info->bt_exist) {
+		CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n BT not exists !!!");
+		CL_PRINTF(cli_buf);
+		return;
+	}
+
+	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = %d/ %d/ %d",
+		   "Ant PG Num/ Ant Mech/ Ant Pos: ",
+		   brd_info->pg_ant_num, brd_info->btdm_ant_num,
+		   brd_info->btdm_ant_pos);
+	CL_PRINTF(cli_buf);
+
+	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = %s / %d",
+		   "BT stack/ hci ext ver",
+		   ((stack_info->profile_notified) ? "Yes" : "No"),
+		   stack_info->hci_version);
+	CL_PRINTF(cli_buf);
+
+	btcoexist->btc_get(btcoexist, BTC_GET_U4_BT_PATCH_VER, &bt_patch_ver);
+	btcoexist->btc_get(btcoexist, BTC_GET_U4_WIFI_FW_VER, &fw_ver);
+	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE,
+		   "\r\n %-35s = %d_%x/ 0x%x/ 0x%x(%d)",
+		   "CoexVer/ FwVer/ PatchVer",
+		   glcoex_ver_date_8723b_1ant, glcoex_ver_8723b_1ant,
+		   fw_ver, bt_patch_ver, bt_patch_ver);
+	CL_PRINTF(cli_buf);
+
+	btcoexist->btc_get(btcoexist, BTC_GET_BL_HS_OPERATION, &bt_hs_on);
+	btcoexist->btc_get(btcoexist, BTC_GET_U1_WIFI_DOT11_CHNL,
+			   &wifi_dot11_chnl);
+	btcoexist->btc_get(btcoexist, BTC_GET_U1_WIFI_HS_CHNL, &wifi_hs_chnl);
+	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = %d / %d(%d)",
+		   "Dot11 channel / HsChnl(HsMode)",
+		   wifi_dot11_chnl, wifi_hs_chnl, bt_hs_on);
+	CL_PRINTF(cli_buf);
+
+	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = %02x %02x %02x ",
+		   "H2C Wifi inform bt chnl Info",
+		   coex_dm->wifi_chnl_info[0], coex_dm->wifi_chnl_info[1],
+		   coex_dm->wifi_chnl_info[2]);
+	CL_PRINTF(cli_buf);
+
+	btcoexist->btc_get(btcoexist, BTC_GET_S4_WIFI_RSSI, &wifi_rssi);
+	btcoexist->btc_get(btcoexist, BTC_GET_S4_HS_RSSI, &bt_hs_rssi);
+	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = %d/ %d",
+		   "Wifi rssi/ HS rssi", wifi_rssi, bt_hs_rssi);
+	CL_PRINTF(cli_buf);
+
+	btcoexist->btc_get(btcoexist, BTC_GET_BL_WIFI_SCAN, &scan);
+	btcoexist->btc_get(btcoexist, BTC_GET_BL_WIFI_LINK, &link);
+	btcoexist->btc_get(btcoexist, BTC_GET_BL_WIFI_ROAM, &roam);
+	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = %d/ %d/ %d ",
+		   "Wifi link/ roam/ scan", link, roam, scan);
+	CL_PRINTF(cli_buf);
+
+	btcoexist->btc_get(btcoexist, BTC_GET_BL_WIFI_UNDER_5G,
+			   &wifi_under_5g);
+	btcoexist->btc_get(btcoexist, BTC_GET_U4_WIFI_BW, &wifi_bw);
+	btcoexist->btc_get(btcoexist, BTC_GET_BL_WIFI_BUSY, &wifi_busy);
+	btcoexist->btc_get(btcoexist, BTC_GET_U4_WIFI_TRAFFIC_DIRECTION,
+			   &wifi_traffic_dir);
+
+	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = %s / %s/ %s ",
+		   "Wifi status", (wifi_under_5g ? "5G" : "2.4G"),
+		   ((BTC_WIFI_BW_LEGACY == wifi_bw) ? "Legacy" :
+			(((BTC_WIFI_BW_HT40 == wifi_bw) ? "HT40" : "HT20"))),
+		   ((!wifi_busy) ? "idle" :
+			((BTC_WIFI_TRAFFIC_TX == wifi_traffic_dir) ?
+				"uplink" : "downlink")));
+	CL_PRINTF(cli_buf);
+
+	btcoexist->btc_get(btcoexist, BTC_GET_U4_WIFI_LINK_STATUS,
+			   &wifi_link_status);
+	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = %d/ %d/ %d/ %d/ %d",
+		   "sta/vwifi/hs/p2pGo/p2pGc",
+		   ((wifi_link_status & WIFI_STA_CONNECTED) ? 1 : 0),
+		   ((wifi_link_status & WIFI_AP_CONNECTED) ? 1 : 0),
+		   ((wifi_link_status & WIFI_HS_CONNECTED) ? 1 : 0),
+		   ((wifi_link_status & WIFI_P2P_GO_CONNECTED) ? 1 : 0),
+		   ((wifi_link_status & WIFI_P2P_GC_CONNECTED) ? 1 : 0));
+	CL_PRINTF(cli_buf);
+
+	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = [%s/ %d/ %d] ",
+		   "BT [status/ rssi/ retryCnt]",
+		   ((btcoexist->bt_info.bt_disabled) ? ("disabled") :
+		    ((coex_sta->c2h_bt_inquiry_page) ? ("inquiry/page scan") :
+		     ((BT_8723B_1ANT_BT_STATUS_NON_CONNECTED_IDLE == coex_dm->bt_status) ?
+		      "non-connected idle" :
+		      ((BT_8723B_1ANT_BT_STATUS_CONNECTED_IDLE == coex_dm->bt_status) ?
+		       "connected-idle" : "busy")))),
+		       coex_sta->bt_rssi, coex_sta->bt_retry_cnt);
+	CL_PRINTF(cli_buf);
+
+	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = %d / %d / %d / %d",
+		"SCO/HID/PAN/A2DP", bt_link_info->sco_exist,
+		bt_link_info->hid_exist, bt_link_info->pan_exist,
+		bt_link_info->a2dp_exist);
+	CL_PRINTF(cli_buf);
+	btcoexist->btc_disp_dbg_msg(btcoexist, BTC_DBG_DISP_BT_LINK_INFO);
+
+	bt_info_ext = coex_sta->bt_info_ext;
+	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = %s",
+		   "BT Info A2DP rate",
+		   (bt_info_ext & BIT(0)) ? "Basic rate" : "EDR rate");
+	CL_PRINTF(cli_buf);
+
+	for (i = 0; i < BT_INFO_SRC_8723B_1ANT_MAX; i++) {
+		if (coex_sta->bt_info_c2h_cnt[i]) {
+			CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE,
+				   "\r\n %-35s = %02x %02x %02x %02x %02x %02x %02x(%d)",
+				   glb_infosrc8723b1ant[i],
+				   coex_sta->bt_info_c2h[i][0],
+				   coex_sta->bt_info_c2h[i][1],
+				   coex_sta->bt_info_c2h[i][2],
+				   coex_sta->bt_info_c2h[i][3],
+				   coex_sta->bt_info_c2h[i][4],
+				   coex_sta->bt_info_c2h[i][5],
+				   coex_sta->bt_info_c2h[i][6],
+				   coex_sta->bt_info_c2h_cnt[i]);
+			CL_PRINTF(cli_buf);
+		}
+	}
+	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE,
+		   "\r\n %-35s = %s/%s, (0x%x/0x%x)",
+		   "PS state, IPS/LPS, (lps/rpwm)",
+		   ((coex_sta->under_ips ? "IPS ON" : "IPS OFF")),
+		   ((coex_sta->under_lps ? "LPS ON" : "LPS OFF")),
+		   btcoexist->bt_info.lps_val,
+		   btcoexist->bt_info.rpwm_val);
+	CL_PRINTF(cli_buf);
+	btcoexist->btc_disp_dbg_msg(btcoexist, BTC_DBG_DISP_FW_PWR_MODE_CMD);
+
+	if (!btcoexist->manual_control) {
+		/* Sw mechanism	*/
+		CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s",
+			   "============[Sw mechanism] ============");
+		CL_PRINTF(cli_buf);
+
+		CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = %d/",
+			   "SM[LowPenaltyRA]", coex_dm->cur_low_penalty_ra);
+		CL_PRINTF(cli_buf);
+
+		CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = %s/ %s/ %d ",
+			   "DelBA/ BtCtrlAgg/ AggSize",
+			   (btcoexist->bt_info.reject_agg_pkt ? "Yes" : "No"),
+			   (btcoexist->bt_info.b_bt_ctrl_buf_size ? "Yes" : "No"),
+			   btcoexist->bt_info.agg_buf_size);
+		CL_PRINTF(cli_buf);
+
+		CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = 0x%x ",
+			   "Rate Mask", btcoexist->bt_info.ra_mask);
+		CL_PRINTF(cli_buf);
+
+		/* Fw mechanism	*/
+		CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s",
+			   "============[Fw mechanism] ============");
+		CL_PRINTF(cli_buf);
+
+		stdmacase = coex_dm->cur_ps_tdma;
+		CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE,
+			   "\r\n %-35s = %02x %02x %02x %02x %02x case-%d (auto:%d)",
+			   "PS TDMA", coex_dm->ps_tdma_para[0],
+			   coex_dm->ps_tdma_para[1], coex_dm->ps_tdma_para[2],
+			   coex_dm->ps_tdma_para[3], coex_dm->ps_tdma_para[4],
+			   stdmacase, coex_dm->auto_tdma_adjust);
+		CL_PRINTF(cli_buf);
+
+		CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = %d ",
+			   "IgnWlanAct", coex_dm->cur_ignore_wlan_act);
+		CL_PRINTF(cli_buf);
+
+		CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = 0x%x ",
+			   "Latest error condition(should be 0)",
+			   coex_dm->error_condition);
+		CL_PRINTF(cli_buf);
+	}
+
+	/* Hw setting */
+	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s",
+		   "============[Hw setting] ============");
+	CL_PRINTF(cli_buf);
+
+	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = 0x%x/0x%x/0x%x/0x%x",
+		   "backup ARFR1/ARFR2/RL/AMaxTime", coex_dm->backup_arfr_cnt1,
+		   coex_dm->backup_arfr_cnt2, coex_dm->backup_retry_limit,
+		   coex_dm->backup_ampdu_max_time);
+	CL_PRINTF(cli_buf);
+
+	u32tmp[0] = btcoexist->btc_read_4byte(btcoexist, 0x430);
+	u32tmp[1] = btcoexist->btc_read_4byte(btcoexist, 0x434);
+	u16tmp[0] = btcoexist->btc_read_2byte(btcoexist, 0x42a);
+	u8tmp[0] = btcoexist->btc_read_1byte(btcoexist, 0x456);
+	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = 0x%x/0x%x/0x%x/0x%x",
+		   "0x430/0x434/0x42a/0x456",
+		   u32tmp[0], u32tmp[1], u16tmp[0], u8tmp[0]);
+	CL_PRINTF(cli_buf);
+
+	u8tmp[0] = btcoexist->btc_read_1byte(btcoexist, 0x778);
+	u32tmp[0] = btcoexist->btc_read_4byte(btcoexist, 0x6cc);
+	u32tmp[1] = btcoexist->btc_read_4byte(btcoexist, 0x880);
+	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = 0x%x/ 0x%x/ 0x%x",
+		   "0x778/0x6cc/0x880[29:25]", u8tmp[0], u32tmp[0],
+		   (u32tmp[1] & 0x3e000000) >> 25);
+	CL_PRINTF(cli_buf);
+
+	u32tmp[0] = btcoexist->btc_read_4byte(btcoexist, 0x948);
+	u8tmp[0] = btcoexist->btc_read_1byte(btcoexist, 0x67);
+	u8tmp[1] = btcoexist->btc_read_1byte(btcoexist, 0x765);
+	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\n %-35s = 0x%x/ 0x%x/ 0x%x",
+		   "0x948/ 0x67[5] / 0x765",
+		   u32tmp[0], ((u8tmp[0] & 0x20) >> 5), u8tmp[1]);
+	CL_PRINTF(cli_buf);
+
+	u32tmp[0] = btcoexist->btc_read_4byte(btcoexist, 0x92c);
+	u32tmp[1] = btcoexist->btc_read_4byte(btcoexist, 0x930);
+	u32tmp[2] = btcoexist->btc_read_4byte(btcoexist, 0x944);
+	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = 0x%x/ 0x%x/ 0x%x",
+		   "0x92c[1:0]/ 0x930[7:0]/0x944[1:0]",
+		   u32tmp[0] & 0x3, u32tmp[1] & 0xff, u32tmp[2] & 0x3);
+	CL_PRINTF(cli_buf);
+
+	u8tmp[0] = btcoexist->btc_read_1byte(btcoexist, 0x39);
+	u8tmp[1] = btcoexist->btc_read_1byte(btcoexist, 0x40);
+	u32tmp[0] = btcoexist->btc_read_4byte(btcoexist, 0x4c);
+	u8tmp[2] = btcoexist->btc_read_1byte(btcoexist, 0x64);
+	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE,
+		   "\r\n %-35s = 0x%x/ 0x%x/ 0x%x/ 0x%x",
+		   "0x38[11]/0x40/0x4c[24:23]/0x64[0]",
+		   ((u8tmp[0] & 0x8)>>3), u8tmp[1],
+		   ((u32tmp[0] & 0x01800000) >> 23), u8tmp[2] & 0x1);
+	CL_PRINTF(cli_buf);
+
+	u32tmp[0] = btcoexist->btc_read_4byte(btcoexist, 0x550);
+	u8tmp[0] = btcoexist->btc_read_1byte(btcoexist, 0x522);
+	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = 0x%x/ 0x%x",
+		   "0x550(bcn ctrl)/0x522", u32tmp[0], u8tmp[0]);
+	CL_PRINTF(cli_buf);
+
+	u32tmp[0] = btcoexist->btc_read_4byte(btcoexist, 0xc50);
+	u8tmp[0] = btcoexist->btc_read_1byte(btcoexist, 0x49c);
+	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = 0x%x/ 0x%x",
+		   "0xc50(dig)/0x49c(null-drop)", u32tmp[0] & 0xff, u8tmp[0]);
+	CL_PRINTF(cli_buf);
+
+	u32tmp[0] = btcoexist->btc_read_4byte(btcoexist, 0xda0);
+	u32tmp[1] = btcoexist->btc_read_4byte(btcoexist, 0xda4);
+	u32tmp[2] = btcoexist->btc_read_4byte(btcoexist, 0xda8);
+	u32tmp[3] = btcoexist->btc_read_4byte(btcoexist, 0xcf0);
+
+	u8tmp[0] = btcoexist->btc_read_1byte(btcoexist, 0xa5b);
+	u8tmp[1] = btcoexist->btc_read_1byte(btcoexist, 0xa5c);
+
+	fa_ofdm = ((u32tmp[0] & 0xffff0000) >> 16) +
+		  ((u32tmp[1] & 0xffff0000) >> 16) +
+		   (u32tmp[1] & 0xffff) +
+		   (u32tmp[2] & 0xffff) +
+		  ((u32tmp[3] & 0xffff0000) >> 16) +
+		   (u32tmp[3] & 0xffff);
+	fa_cck = (u8tmp[0] << 8) + u8tmp[1];
+
+	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = 0x%x/ 0x%x/ 0x%x",
+		   "OFDM-CCA/OFDM-FA/CCK-FA",
+		   u32tmp[0] & 0xffff, fa_ofdm, fa_cck);
+	CL_PRINTF(cli_buf);
+
+	u32tmp[0] = btcoexist->btc_read_4byte(btcoexist, 0x6c0);
+	u32tmp[1] = btcoexist->btc_read_4byte(btcoexist, 0x6c4);
+	u32tmp[2] = btcoexist->btc_read_4byte(btcoexist, 0x6c8);
+	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = 0x%x/ 0x%x/ 0x%x",
+		   "0x6c0/0x6c4/0x6c8(coexTable)",
+		   u32tmp[0], u32tmp[1], u32tmp[2]);
+	CL_PRINTF(cli_buf);
+
+	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = %d/ %d",
+		   "0x770(high-pri rx/tx)", coex_sta->high_priority_rx,
+		   coex_sta->high_priority_tx);
+	CL_PRINTF(cli_buf);
+	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = %d/ %d",
+		   "0x774(low-pri rx/tx)", coex_sta->low_priority_rx,
+		   coex_sta->low_priority_tx);
+	CL_PRINTF(cli_buf);
+#if (BT_AUTO_REPORT_ONLY_8723B_1ANT == 1)
+	halbtc8723b1ant_monitor_bt_ctr(btcoexist);
+#endif
+	btcoexist->btc_disp_dbg_msg(btcoexist, BTC_DBG_DISP_COEX_STATISTICS);
+}
+
+void ex_halbtc8723b1ant_ips_notify(struct btc_coexist *btcoexist, u8 type)
+{
+	if (btcoexist->manual_control || btcoexist->stop_coex_dm)
+		return;
+
+	if (BTC_IPS_ENTER == type) {
+		BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
+			  "[BTCoex], IPS ENTER notify\n");
+		coex_sta->under_ips = true;
+
+		halbtc8723b1ant_setantpath(btcoexist, BTC_ANT_PATH_BT,
+					   false, true);
+		/* set PTA control */
+		halbtc8723b1ant_ps_tdma(btcoexist, NORMAL_EXEC, false, 0);
+		coex_table_with_type(btcoexist,
+						     NORMAL_EXEC, 0);
+		halbtc8723b1ant_wifi_off_hw_cfg(btcoexist);
+	} else if (BTC_IPS_LEAVE == type) {
+		BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
+			  "[BTCoex], IPS LEAVE notify\n");
+		coex_sta->under_ips = false;
+
+		init_hw_config(btcoexist, false);
+		halbtc8723b1ant_init_coex_dm(btcoexist);
+		halbtc8723b1ant_query_bt_info(btcoexist);
+	}
+}
+
+void ex_halbtc8723b1ant_lps_notify(struct btc_coexist *btcoexist, u8 type)
+{
+	if (btcoexist->manual_control || btcoexist->stop_coex_dm)
+		return;
+
+	if (BTC_LPS_ENABLE == type) {
+		BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
+			  "[BTCoex], LPS ENABLE notify\n");
+		coex_sta->under_lps = true;
+	} else if (BTC_LPS_DISABLE == type) {
+		BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
+			  "[BTCoex], LPS DISABLE notify\n");
+		coex_sta->under_lps = false;
+	}
+}
+
+void ex_halbtc8723b1ant_scan_notify(struct btc_coexist *btcoexist, u8 type)
+{
+	bool wifi_connected = false, bt_hs_on = false;
+	u32 wifi_link_status = 0;
+	u32 num_of_wifi_link = 0;
+	bool bt_ctrl_agg_buf_size = false;
+	u8 agg_buf_size = 5;
+
+	if (btcoexist->manual_control || btcoexist->stop_coex_dm ||
+	    btcoexist->bt_info.bt_disabled)
+		return;
+
+	btcoexist->btc_get(btcoexist, BTC_GET_BL_HS_OPERATION, &bt_hs_on);
+	btcoexist->btc_get(btcoexist, BTC_GET_BL_WIFI_CONNECTED,
+			   &wifi_connected);
+
+	halbtc8723b1ant_query_bt_info(btcoexist);
+
+	btcoexist->btc_get(btcoexist, BTC_GET_U4_WIFI_LINK_STATUS,
+			   &wifi_link_status);
+	num_of_wifi_link = wifi_link_status >> 16;
+	if (num_of_wifi_link >= 2) {
+		halbtc8723b1ant_limited_tx(btcoexist, NORMAL_EXEC, 0, 0, 0, 0);
+		halbtc8723b1ant_limited_rx(btcoexist, NORMAL_EXEC, false,
+					   bt_ctrl_agg_buf_size, agg_buf_size);
+		halbtc8723b1ant_action_wifi_multiport(btcoexist);
+		return;
+	}
+
+	if (coex_sta->c2h_bt_inquiry_page) {
+		halbtc8723b1ant_action_bt_inquiry(btcoexist);
+		return;
+	} else if (bt_hs_on) {
+		halbtc8723b1ant_action_hs(btcoexist);
+		return;
+	}
+
+	if (BTC_SCAN_START == type) {
+		BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
+			  "[BTCoex], SCAN START notify\n");
+		if (!wifi_connected)	/* non-connected scan */
+			action_wifi_not_connected_scan(btcoexist);
+		else	/* wifi is connected */
+			action_wifi_connected_scan(btcoexist);
+	} else if (BTC_SCAN_FINISH == type) {
+		BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
+			  "[BTCoex], SCAN FINISH notify\n");
+		if (!wifi_connected)	/* non-connected scan */
+			action_wifi_not_connected(btcoexist);
+		else
+			halbtc8723b1ant_action_wifi_connected(btcoexist);
+	}
+}
+
+void ex_halbtc8723b1ant_connect_notify(struct btc_coexist *btcoexist, u8 type)
+{
+	bool wifi_connected = false, bt_hs_on = false;
+	u32 wifi_link_status = 0;
+	u32 num_of_wifi_link = 0;
+	bool bt_ctrl_agg_buf_size = false;
+	u8 agg_buf_size = 5;
+
+	if (btcoexist->manual_control || btcoexist->stop_coex_dm ||
+	    btcoexist->bt_info.bt_disabled)
+		return;
+
+	btcoexist->btc_get(btcoexist, BTC_GET_U4_WIFI_LINK_STATUS,
+			   &wifi_link_status);
+	num_of_wifi_link = wifi_link_status>>16;
+	if (num_of_wifi_link >= 2) {
+		halbtc8723b1ant_limited_tx(btcoexist, NORMAL_EXEC, 0, 0, 0, 0);
+		halbtc8723b1ant_limited_rx(btcoexist, NORMAL_EXEC, false,
+					   bt_ctrl_agg_buf_size, agg_buf_size);
+		halbtc8723b1ant_action_wifi_multiport(btcoexist);
+		return;
+	}
+
+	btcoexist->btc_get(btcoexist, BTC_GET_BL_HS_OPERATION, &bt_hs_on);
+	if (coex_sta->c2h_bt_inquiry_page) {
+		halbtc8723b1ant_action_bt_inquiry(btcoexist);
+		return;
+	} else if (bt_hs_on) {
+		halbtc8723b1ant_action_hs(btcoexist);
+		return;
+	}
+
+	if (BTC_ASSOCIATE_START == type) {
+		BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
+			  "[BTCoex], CONNECT START notify\n");
+		action_wifi_not_connected_asso_auth(btcoexist);
+	} else if (BTC_ASSOCIATE_FINISH == type) {
+		BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
+			  "[BTCoex], CONNECT FINISH notify\n");
+
+		btcoexist->btc_get(btcoexist, BTC_GET_BL_WIFI_CONNECTED,
+				   &wifi_connected);
+		if (!wifi_connected) /* non-connected scan */
+			action_wifi_not_connected(btcoexist);
+		else
+			halbtc8723b1ant_action_wifi_connected(btcoexist);
+	}
+}
+
+void ex_halbtc8723b1ant_media_status_notify(struct btc_coexist *btcoexist,
+					    u8 type)
+{
+	u8 h2c_parameter[3] = {0};
+	u32 wifi_bw;
+	u8 wificentralchnl;
+
+	if (btcoexist->manual_control || btcoexist->stop_coex_dm ||
+	    btcoexist->bt_info.bt_disabled)
+		return;
+
+	if (BTC_MEDIA_CONNECT == type)
+		BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
+			  "[BTCoex], MEDIA connect notify\n");
+	else
+		BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
+			  "[BTCoex], MEDIA disconnect notify\n");
+
+	/* only 2.4G we need to inform bt the chnl mask */
+	btcoexist->btc_get(btcoexist, BTC_GET_U1_WIFI_CENTRAL_CHNL,
+			   &wificentralchnl);
+
+	if ((BTC_MEDIA_CONNECT == type) &&
+	    (wificentralchnl <= 14)) {
+		h2c_parameter[0] = 0x0;
+		h2c_parameter[1] = wificentralchnl;
+		btcoexist->btc_get(btcoexist, BTC_GET_U4_WIFI_BW, &wifi_bw);
+		if (BTC_WIFI_BW_HT40 == wifi_bw)
+			h2c_parameter[2] = 0x30;
+		else
+			h2c_parameter[2] = 0x20;
+	}
+
+	coex_dm->wifi_chnl_info[0] = h2c_parameter[0];
+	coex_dm->wifi_chnl_info[1] = h2c_parameter[1];
+	coex_dm->wifi_chnl_info[2] = h2c_parameter[2];
+
+	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_EXEC,
+		  "[BTCoex], FW write 0x66 = 0x%x\n",
+		  h2c_parameter[0] << 16 | h2c_parameter[1] << 8 |
+		  h2c_parameter[2]);
+
+	btcoexist->btc_fill_h2c(btcoexist, 0x66, 3, h2c_parameter);
+}
+
+void ex_halbtc8723b1ant_special_packet_notify(struct btc_coexist *btcoexist,
+					      u8 type)
+{
+	bool bt_hs_on = false;
+	u32 wifi_link_status = 0;
+	u32 num_of_wifi_link = 0;
+	bool bt_ctrl_agg_buf_size = false;
+	u8 agg_buf_size = 5;
+
+	if (btcoexist->manual_control || btcoexist->stop_coex_dm ||
+	    btcoexist->bt_info.bt_disabled)
+		return;
+
+	btcoexist->btc_get(btcoexist, BTC_GET_U4_WIFI_LINK_STATUS,
+			   &wifi_link_status);
+	num_of_wifi_link = wifi_link_status >> 16;
+	if (num_of_wifi_link >= 2) {
+		halbtc8723b1ant_limited_tx(btcoexist, NORMAL_EXEC, 0, 0, 0, 0);
+		halbtc8723b1ant_limited_rx(btcoexist, NORMAL_EXEC, false,
+					   bt_ctrl_agg_buf_size, agg_buf_size);
+		halbtc8723b1ant_action_wifi_multiport(btcoexist);
+		return;
+	}
+
+	coex_sta->special_pkt_period_cnt = 0;
+
+	btcoexist->btc_get(btcoexist, BTC_GET_BL_HS_OPERATION, &bt_hs_on);
+	if (coex_sta->c2h_bt_inquiry_page) {
+		halbtc8723b1ant_action_bt_inquiry(btcoexist);
+		return;
+	} else if (bt_hs_on) {
+		halbtc8723b1ant_action_hs(btcoexist);
+		return;
+	}
+
+	if (BTC_PACKET_DHCP == type ||
+	    BTC_PACKET_EAPOL == type) {
+		BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
+			  "[BTCoex], special Packet(%d) notify\n", type);
+		action_wifi_connected_special_packet(btcoexist);
+	}
+}
+
+void ex_halbtc8723b1ant_bt_info_notify(struct btc_coexist *btcoexist,
+				       u8 *tmp_buf, u8 length)
+{
+	u8 bt_info = 0;
+	u8 i, rsp_source = 0;
+	bool wifi_connected = false;
+	bool bt_busy = false;
+
+	coex_sta->c2h_bt_info_req_sent = false;
+
+	rsp_source = tmp_buf[0] & 0xf;
+	if (rsp_source >= BT_INFO_SRC_8723B_1ANT_MAX)
+		rsp_source = BT_INFO_SRC_8723B_1ANT_WIFI_FW;
+	coex_sta->bt_info_c2h_cnt[rsp_source]++;
+
+	BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
+		  "[BTCoex], Bt info[%d], length =%d, hex data =[",
+		  rsp_source, length);
+	for (i = 0; i < length; i++) {
+		coex_sta->bt_info_c2h[rsp_source][i] = tmp_buf[i];
+		if (i == 1)
+			bt_info = tmp_buf[i];
+		if (i == length - 1)
+			BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
+				  "0x%02x]\n", tmp_buf[i]);
+		else
+			BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
+				  "0x%02x, ", tmp_buf[i]);
+	}
+
+	if (BT_INFO_SRC_8723B_1ANT_WIFI_FW != rsp_source) {
+		coex_sta->bt_retry_cnt =	/* [3:0] */
+			coex_sta->bt_info_c2h[rsp_source][2] & 0xf;
+
+		coex_sta->bt_rssi =
+			coex_sta->bt_info_c2h[rsp_source][3] * 2 + 10;
+
+		coex_sta->bt_info_ext =
+			coex_sta->bt_info_c2h[rsp_source][4];
+
+		/* Here we need to resend some wifi info to BT
+		 * because bt is reset and loss of the info.*/
+		if (coex_sta->bt_info_ext & BIT(1)) {
+			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+				  "[BTCoex], BT ext info bit1 check, send wifi BW&Chnl to BT!!\n");
+			btcoexist->btc_get(btcoexist, BTC_GET_BL_WIFI_CONNECTED,
+					   &wifi_connected);
+			if (wifi_connected)
+				ex_halbtc8723b1ant_media_status_notify(btcoexist,
+							     BTC_MEDIA_CONNECT);
+			else
+				ex_halbtc8723b1ant_media_status_notify(btcoexist,
+							  BTC_MEDIA_DISCONNECT);
+		}
+
+		if (coex_sta->bt_info_ext & BIT(3)) {
+			if (!btcoexist->manual_control &&
+			    !btcoexist->stop_coex_dm) {
+				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+					  "[BTCoex], BT ext info bit3 check, set BT NOT ignore Wlan active!!\n");
+				halbtc8723b1ant_ignore_wlan_act(btcoexist,
+								FORCE_EXEC,
+								false);
+			}
+		} else {
+			/* BT already NOT ignore Wlan active, do nothing here.*/
+		}
+#if (BT_AUTO_REPORT_ONLY_8723B_1ANT == 0)
+		if (coex_sta->bt_info_ext & BIT(4)) {
+			/* BT auto report already enabled, do nothing */
+		} else {
+			halbtc8723b1ant_bt_auto_report(btcoexist, FORCE_EXEC,
+						       true);
+		}
+#endif
+	}
+
+	/* check BIT(2) first ==> check if bt is under inquiry or page scan */
+	if (bt_info & BT_INFO_8723B_1ANT_B_INQ_PAGE)
+		coex_sta->c2h_bt_inquiry_page = true;
+	else
+		coex_sta->c2h_bt_inquiry_page = false;
+
+	/* set link exist status */
+	if (!(bt_info & BT_INFO_8723B_1ANT_B_CONNECTION)) {
+		coex_sta->bt_link_exist = false;
+		coex_sta->pan_exist = false;
+		coex_sta->a2dp_exist = false;
+		coex_sta->hid_exist = false;
+		coex_sta->sco_exist = false;
+	} else { /* connection exists */
+		coex_sta->bt_link_exist = true;
+		if (bt_info & BT_INFO_8723B_1ANT_B_FTP)
+			coex_sta->pan_exist = true;
+		else
+			coex_sta->pan_exist = false;
+		if (bt_info & BT_INFO_8723B_1ANT_B_A2DP)
+			coex_sta->a2dp_exist = true;
+		else
+			coex_sta->a2dp_exist = false;
+		if (bt_info & BT_INFO_8723B_1ANT_B_HID)
+			coex_sta->hid_exist = true;
+		else
+			coex_sta->hid_exist = false;
+		if (bt_info & BT_INFO_8723B_1ANT_B_SCO_ESCO)
+			coex_sta->sco_exist = true;
+		else
+			coex_sta->sco_exist = false;
+	}
+
+	halbtc8723b1ant_update_bt_link_info(btcoexist);
+
+	if (!(bt_info&BT_INFO_8723B_1ANT_B_CONNECTION)) {
+		coex_dm->bt_status = BT_8723B_1ANT_BT_STATUS_NON_CONNECTED_IDLE;
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+			  "[BTCoex], BtInfoNotify(), BT Non-Connected idle!\n");
+	/* connection exists but no busy */
+	} else if (bt_info == BT_INFO_8723B_1ANT_B_CONNECTION) {
+		coex_dm->bt_status = BT_8723B_1ANT_BT_STATUS_CONNECTED_IDLE;
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+			  "[BTCoex], BtInfoNotify(), BT Connected-idle!!!\n");
+	} else if ((bt_info & BT_INFO_8723B_1ANT_B_SCO_ESCO) ||
+		(bt_info & BT_INFO_8723B_1ANT_B_SCO_BUSY)) {
+		coex_dm->bt_status = BT_8723B_1ANT_BT_STATUS_SCO_BUSY;
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+			  "[BTCoex], BtInfoNotify(), BT SCO busy!!!\n");
+	} else if (bt_info & BT_INFO_8723B_1ANT_B_ACL_BUSY) {
+		if (BT_8723B_1ANT_BT_STATUS_ACL_BUSY != coex_dm->bt_status)
+			coex_dm->auto_tdma_adjust = false;
+
+		coex_dm->bt_status = BT_8723B_1ANT_BT_STATUS_ACL_BUSY;
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+			  "[BTCoex], BtInfoNotify(), BT ACL busy!!!\n");
+	} else {
+		coex_dm->bt_status =
+			BT_8723B_1ANT_BT_STATUS_MAX;
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+			  "[BTCoex], BtInfoNotify(), BT Non-Defined state!!\n");
+	}
+
+	if ((BT_8723B_1ANT_BT_STATUS_ACL_BUSY == coex_dm->bt_status) ||
+	    (BT_8723B_1ANT_BT_STATUS_SCO_BUSY == coex_dm->bt_status) ||
+	    (BT_8723B_1ANT_BT_STATUS_ACL_SCO_BUSY == coex_dm->bt_status))
+		bt_busy = true;
+	else
+		bt_busy = false;
+	btcoexist->btc_set(btcoexist, BTC_SET_BL_BT_TRAFFIC_BUSY, &bt_busy);
+
+	halbtc8723b1ant_run_coexist_mechanism(btcoexist);
+}
+
+void ex_halbtc8723b1ant_halt_notify(struct btc_coexist *btcoexist)
+{
+	BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY, "[BTCoex], Halt notify\n");
+
+	btcoexist->stop_coex_dm = true;
+
+	halbtc8723b1ant_setantpath(btcoexist, BTC_ANT_PATH_BT, false, true);
+
+	halbtc8723b1ant_wifi_off_hw_cfg(btcoexist);
+	halbtc8723b1ant_ignore_wlan_act(btcoexist, FORCE_EXEC, true);
+
+	halbtc8723b1ant_power_save_state(btcoexist, BTC_PS_WIFI_NATIVE,
+					 0x0, 0x0);
+	halbtc8723b1ant_ps_tdma(btcoexist, FORCE_EXEC, false, 0);
+
+	ex_halbtc8723b1ant_media_status_notify(btcoexist, BTC_MEDIA_DISCONNECT);
+}
+
+void ex_halbtc8723b1ant_pnp_notify(struct btc_coexist *btcoexist, u8 pnp_state)
+{
+	BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY, "[BTCoex], Pnp notify\n");
+
+	if (BTC_WIFI_PNP_SLEEP == pnp_state) {
+		BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
+			  "[BTCoex], Pnp notify to SLEEP\n");
+		btcoexist->stop_coex_dm = true;
+		halbtc8723b1ant_setantpath(btcoexist, BTC_ANT_PATH_BT, false,
+					   true);
+		halbtc8723b1ant_power_save_state(btcoexist, BTC_PS_WIFI_NATIVE,
+						 0x0, 0x0);
+		halbtc8723b1ant_ps_tdma(btcoexist, NORMAL_EXEC, false, 0);
+		coex_table_with_type(btcoexist, NORMAL_EXEC, 2);
+		halbtc8723b1ant_wifi_off_hw_cfg(btcoexist);
+	} else if (BTC_WIFI_PNP_WAKE_UP == pnp_state) {
+		BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
+			  "[BTCoex], Pnp notify to WAKE UP\n");
+		btcoexist->stop_coex_dm = false;
+		init_hw_config(btcoexist, false);
+		halbtc8723b1ant_init_coex_dm(btcoexist);
+		halbtc8723b1ant_query_bt_info(btcoexist);
+	}
+}
+
+void ex_halbtc8723b1ant_coex_dm_reset(struct btc_coexist *btcoexist)
+{
+	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+		  "[BTCoex], *****************Coex DM Reset****************\n");
+
+	init_hw_config(btcoexist, false);
+	btcoexist->btc_set_rf_reg(btcoexist, BTC_RF_A, 0x1, 0xfffff, 0x0);
+	btcoexist->btc_set_rf_reg(btcoexist, BTC_RF_A, 0x2, 0xfffff, 0x0);
+	halbtc8723b1ant_init_coex_dm(btcoexist);
+}
+
+void ex_halbtc8723b1ant_periodical(struct btc_coexist *btcoexist)
+{
+	struct btc_board_info *brd_info = &btcoexist->board_info;
+	struct btc_stack_info *stack_info = &btcoexist->stack_info;
+	static u8 dis_ver_info_cnt;
+	u32 fw_ver = 0, bt_patch_ver = 0;
+
+	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+		  "[BTCoex], ========================== Periodical ===========================\n");
+
+	if (dis_ver_info_cnt <= 5) {
+		dis_ver_info_cnt += 1;
+		BTC_PRINT(BTC_MSG_INTERFACE, INTF_INIT,
+			  "[BTCoex], ****************************************************************\n");
+		BTC_PRINT(BTC_MSG_INTERFACE, INTF_INIT,
+			  "[BTCoex], Ant PG Num/ Ant Mech/ Ant Pos = %d/ %d/ %d\n",
+			  brd_info->pg_ant_num, brd_info->btdm_ant_num,
+			  brd_info->btdm_ant_pos);
+		BTC_PRINT(BTC_MSG_INTERFACE, INTF_INIT,
+			  "[BTCoex], BT stack/ hci ext ver = %s / %d\n",
+			  ((stack_info->profile_notified) ? "Yes" : "No"),
+			  stack_info->hci_version);
+		btcoexist->btc_get(btcoexist, BTC_GET_U4_BT_PATCH_VER,
+				   &bt_patch_ver);
+		btcoexist->btc_get(btcoexist, BTC_GET_U4_WIFI_FW_VER, &fw_ver);
+		BTC_PRINT(BTC_MSG_INTERFACE, INTF_INIT,
+			  "[BTCoex], CoexVer/ FwVer/ PatchVer = %d_%x/ 0x%x/ 0x%x(%d)\n",
+			  glcoex_ver_date_8723b_1ant,
+			  glcoex_ver_8723b_1ant, fw_ver,
+			  bt_patch_ver, bt_patch_ver);
+		BTC_PRINT(BTC_MSG_INTERFACE, INTF_INIT,
+			  "[BTCoex], ****************************************************************\n");
+	}
+
+#if (BT_AUTO_REPORT_ONLY_8723B_1ANT == 0)
+	halbtc8723b1ant_query_bt_info(btcoexist);
+	halbtc8723b1ant_monitor_bt_ctr(btcoexist);
+	halbtc8723b1ant_monitor_bt_enable_disable(btcoexist);
+#else
+	if (is_wifi_status_changed(btcoexist) ||
+	    coex_dm->auto_tdma_adjust) {
+		halbtc8723b1ant_run_coexist_mechanism(btcoexist);
+	}
+
+	coex_sta->special_pkt_period_cnt++;
+#endif
+}
+
diff --git a/drivers/staging/rtl8192ee/btcoexist/halbtc8723b1ant.h b/drivers/staging/rtl8192ee/btcoexist/halbtc8723b1ant.h
new file mode 100644
index 0000000..bded373
--- /dev/null
+++ b/drivers/staging/rtl8192ee/btcoexist/halbtc8723b1ant.h
@@ -0,0 +1,160 @@
+/**********************************************************************
+ * The following is for 8723B 1ANT BT Co-exist definition
+ **********************************************************************/
+#define	BT_AUTO_REPORT_ONLY_8723B_1ANT			1
+
+#define	BT_INFO_8723B_1ANT_B_FTP			BIT(7)
+#define	BT_INFO_8723B_1ANT_B_A2DP			BIT(6)
+#define	BT_INFO_8723B_1ANT_B_HID			BIT(5)
+#define	BT_INFO_8723B_1ANT_B_SCO_BUSY			BIT(4)
+#define	BT_INFO_8723B_1ANT_B_ACL_BUSY			BIT(3)
+#define	BT_INFO_8723B_1ANT_B_INQ_PAGE			BIT(2)
+#define	BT_INFO_8723B_1ANT_B_SCO_ESCO			BIT(1)
+#define	BT_INFO_8723B_1ANT_B_CONNECTION			BIT(0)
+
+#define	BT_INFO_8723B_1ANT_A2DP_BASIC_RATE(_BT_INFO_EXT_)	\
+		(((_BT_INFO_EXT_&BIT(0))) ? true : false)
+
+#define	BTC_RSSI_COEX_THRESH_TOL_8723B_1ANT		2
+
+enum BT_INFO_SRC_8723B_1ANT {
+	BT_INFO_SRC_8723B_1ANT_WIFI_FW			= 0x0,
+	BT_INFO_SRC_8723B_1ANT_BT_RSP			= 0x1,
+	BT_INFO_SRC_8723B_1ANT_BT_ACTIVE_SEND		= 0x2,
+	BT_INFO_SRC_8723B_1ANT_MAX
+};
+
+enum BT_8723B_1ANT_BT_STATUS {
+	BT_8723B_1ANT_BT_STATUS_NON_CONNECTED_IDLE	= 0x0,
+	BT_8723B_1ANT_BT_STATUS_CONNECTED_IDLE		= 0x1,
+	BT_8723B_1ANT_BT_STATUS_INQ_PAGE		= 0x2,
+	BT_8723B_1ANT_BT_STATUS_ACL_BUSY		= 0x3,
+	BT_8723B_1ANT_BT_STATUS_SCO_BUSY		= 0x4,
+	BT_8723B_1ANT_BT_STATUS_ACL_SCO_BUSY		= 0x5,
+	BT_8723B_1ANT_BT_STATUS_MAX
+};
+
+enum BT_8723B_1ANT_WIFI_STATUS {
+	BT_8723B_1ANT_WIFI_STATUS_NON_CONNECTED_IDLE			= 0x0,
+	BT_8723B_1ANT_WIFI_STATUS_NON_CONNECTED_ASSO_AUTH_SCAN		= 0x1,
+	BT_8723B_1ANT_WIFI_STATUS_CONNECTED_SCAN			= 0x2,
+	BT_8723B_1ANT_WIFI_STATUS_CONNECTED_SPECIAL_PKT			= 0x3,
+	BT_8723B_1ANT_WIFI_STATUS_CONNECTED_IDLE			= 0x4,
+	BT_8723B_1ANT_WIFI_STATUS_CONNECTED_BUSY			= 0x5,
+	BT_8723B_1ANT_WIFI_STATUS_MAX
+};
+
+enum BT_8723B_1ANT_COEX_ALGO {
+	BT_8723B_1ANT_COEX_ALGO_UNDEFINED		= 0x0,
+	BT_8723B_1ANT_COEX_ALGO_SCO			= 0x1,
+	BT_8723B_1ANT_COEX_ALGO_HID			= 0x2,
+	BT_8723B_1ANT_COEX_ALGO_A2DP			= 0x3,
+	BT_8723B_1ANT_COEX_ALGO_A2DP_PANHS		= 0x4,
+	BT_8723B_1ANT_COEX_ALGO_PANEDR			= 0x5,
+	BT_8723B_1ANT_COEX_ALGO_PANHS			= 0x6,
+	BT_8723B_1ANT_COEX_ALGO_PANEDR_A2DP		= 0x7,
+	BT_8723B_1ANT_COEX_ALGO_PANEDR_HID		= 0x8,
+	BT_8723B_1ANT_COEX_ALGO_HID_A2DP_PANEDR		= 0x9,
+	BT_8723B_1ANT_COEX_ALGO_HID_A2DP		= 0xa,
+	BT_8723B_1ANT_COEX_ALGO_MAX			= 0xb,
+};
+
+struct coex_dm_8723b_1ant {
+	/* fw mechanism */
+	bool cur_ignore_wlan_act;
+	bool pre_ignore_wlan_act;
+	u8 pre_ps_tdma;
+	u8 cur_ps_tdma;
+	u8 ps_tdma_para[5];
+	u8 ps_tdma_du_adj_type;
+	bool auto_tdma_adjust;
+	bool pre_ps_tdma_on;
+	bool cur_ps_tdma_on;
+	bool pre_bt_auto_report;
+	bool cur_bt_auto_report;
+	u8 pre_lps;
+	u8 cur_lps;
+	u8 pre_rpwm;
+	u8 cur_rpwm;
+
+	/* sw mechanism */
+	bool pre_low_penalty_ra;
+	bool cur_low_penalty_ra;
+	u32 pre_val0x6c0;
+	u32 cur_val0x6c0;
+	u32 pre_val0x6c4;
+	u32 cur_val0x6c4;
+	u32 pre_val0x6c8;
+	u32 cur_val0x6c8;
+	u8 pre_val0x6cc;
+	u8 cur_val0x6cc;
+	bool limited_dig;
+
+	u32 backup_arfr_cnt1;	/* Auto Rate Fallback Retry cnt */
+	u32 backup_arfr_cnt2;	/* Auto Rate Fallback Retry cnt */
+	u16 backup_retry_limit;
+	u8 backup_ampdu_max_time;
+
+	/* algorithm related */
+	u8 pre_algorithm;
+	u8 cur_algorithm;
+	u8 bt_status;
+	u8 wifi_chnl_info[3];
+
+	u32 prera_mask;
+	u32 curra_mask;
+	u8 pre_arfr_type;
+	u8 cur_arfr_type;
+	u8 pre_retry_limit_type;
+	u8 cur_retry_limit_type;
+	u8 pre_ampdu_time_type;
+	u8 cur_ampdu_time_type;
+
+	u8 error_condition;
+};
+
+struct coex_sta_8723b_1ant {
+	bool bt_link_exist;
+	bool sco_exist;
+	bool a2dp_exist;
+	bool hid_exist;
+	bool pan_exist;
+
+	bool under_lps;
+	bool under_ips;
+	u32 special_pkt_period_cnt;
+	u32 high_priority_tx;
+	u32 high_priority_rx;
+	u32 low_priority_tx;
+	u32 low_priority_rx;
+	u8 bt_rssi;
+	u8 pre_bt_rssi_state;
+	u8 pre_wifi_rssi_state[4];
+	bool c2h_bt_info_req_sent;
+	u8 bt_info_c2h[BT_INFO_SRC_8723B_1ANT_MAX][10];
+	u32 bt_info_c2h_cnt[BT_INFO_SRC_8723B_1ANT_MAX];
+	bool c2h_bt_inquiry_page;
+	u8 bt_retry_cnt;
+	u8 bt_info_ext;
+};
+
+/*************************************************************************
+ * The following is interface which will notify coex module.
+ *************************************************************************/
+void ex_halbtc8723b1ant_init_hwconfig(struct btc_coexist *btcoexist);
+void ex_halbtc8723b1ant_init_coex_dm(struct btc_coexist *btcoexist);
+void ex_halbtc8723b1ant_ips_notify(struct btc_coexist *btcoexist, u8 type);
+void ex_halbtc8723b1ant_lps_notify(struct btc_coexist *btcoexist, u8 type);
+void ex_halbtc8723b1ant_scan_notify(struct btc_coexist *btcoexist, u8 type);
+void ex_halbtc8723b1ant_connect_notify(struct btc_coexist *btcoexist, u8 type);
+void ex_halbtc8723b1ant_media_status_notify(struct btc_coexist *btcoexist,
+					    u8 type);
+void ex_halbtc8723b1ant_special_packet_notify(struct btc_coexist *btcoexist,
+					      u8 type);
+void ex_halbtc8723b1ant_bt_info_notify(struct btc_coexist *btcoexist,
+				       u8 *tmpbuf, u8 length);
+void ex_halbtc8723b1ant_halt_notify(struct btc_coexist *btcoexist);
+void ex_halbtc8723b1ant_pnp_notify(struct btc_coexist *btcoexist, u8 state);
+void ex_halbtc8723b1ant_coex_dm_reset(struct btc_coexist *btcoexist);
+void ex_halbtc8723b1ant_periodical(struct btc_coexist *btcoexist);
+void ex_halbtc8723b1ant_display_coex_info(struct btc_coexist *btcoexist);
diff --git a/drivers/staging/rtl8192ee/btcoexist/halbtc8723b2ant.c b/drivers/staging/rtl8192ee/btcoexist/halbtc8723b2ant.c
new file mode 100644
index 0000000..8362063
--- /dev/null
+++ b/drivers/staging/rtl8192ee/btcoexist/halbtc8723b2ant.c
@@ -0,0 +1,3929 @@
+/***************************************************************
+ * Description:
+ *
+ * This file is for RTL8723B Co-exist mechanism
+ *
+ * History
+ * 2012/11/15 Cosa first check in.
+ *
+ **************************************************************/
+/**************************************************************
+ * include files
+ **************************************************************/
+#include "halbt_precomp.h"
+/**************************************************************
+ * Global variables, these are static variables
+ **************************************************************/
+static struct coex_dm_8723b_2ant glcoex_dm_8723b_2ant;
+static struct coex_dm_8723b_2ant *coex_dm = &glcoex_dm_8723b_2ant;
+static struct coex_sta_8723b_2ant glcoex_sta_8723b_2ant;
+static struct coex_sta_8723b_2ant *coex_sta = &glcoex_sta_8723b_2ant;
+
+static const char *const glbt_info_src_8723b_2ant[] = {
+	"BT Info[wifi fw]",
+	"BT Info[bt rsp]",
+	"BT Info[bt auto report]",
+};
+
+static u32 glcoex_ver_date_8723b_2ant = 20131113;
+static u32 glcoex_ver_8723b_2ant = 0x3f;
+
+/**************************************************************
+ * local function proto type if needed
+ **************************************************************/
+/**************************************************************
+ * local function start with halbtc8723b2ant_
+ **************************************************************/
+static u8 halbtc8723b2ant_bt_rssi_state(u8 level_num, u8 rssi_thresh,
+					u8 rssi_thresh1)
+{
+	s32 bt_rssi = 0;
+	u8 bt_rssi_state = coex_sta->pre_bt_rssi_state;
+
+	bt_rssi = coex_sta->bt_rssi;
+
+	if (level_num == 2) {
+		if ((coex_sta->pre_bt_rssi_state == BTC_RSSI_STATE_LOW) ||
+		    (coex_sta->pre_bt_rssi_state == BTC_RSSI_STATE_STAY_LOW)) {
+			if (bt_rssi >= rssi_thresh +
+				       BTC_RSSI_COEX_THRESH_TOL_8723B_2ANT) {
+				bt_rssi_state = BTC_RSSI_STATE_HIGH;
+				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_RSSI_STATE,
+					  "[BTCoex], BT Rssi state switch to High\n");
+			} else {
+				bt_rssi_state = BTC_RSSI_STATE_STAY_LOW;
+				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_RSSI_STATE,
+					  "[BTCoex], BT Rssi state stay at Low\n");
+			}
+		} else {
+			if (bt_rssi < rssi_thresh) {
+				bt_rssi_state = BTC_RSSI_STATE_LOW;
+				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_RSSI_STATE,
+					  "[BTCoex], BT Rssi state switch to Low\n");
+			} else {
+				bt_rssi_state = BTC_RSSI_STATE_STAY_HIGH;
+				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_RSSI_STATE,
+					  "[BTCoex], BT Rssi state stay at High\n");
+			}
+		}
+	} else if (level_num == 3) {
+		if (rssi_thresh > rssi_thresh1) {
+			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_RSSI_STATE,
+				  "[BTCoex], BT Rssi thresh error!!\n");
+			return coex_sta->pre_bt_rssi_state;
+		}
+
+		if ((coex_sta->pre_bt_rssi_state == BTC_RSSI_STATE_LOW) ||
+		    (coex_sta->pre_bt_rssi_state == BTC_RSSI_STATE_STAY_LOW)) {
+			if (bt_rssi >= rssi_thresh +
+				       BTC_RSSI_COEX_THRESH_TOL_8723B_2ANT) {
+				bt_rssi_state = BTC_RSSI_STATE_MEDIUM;
+				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_RSSI_STATE,
+					  "[BTCoex], BT Rssi state switch to Medium\n");
+			} else {
+				bt_rssi_state = BTC_RSSI_STATE_STAY_LOW;
+				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_RSSI_STATE,
+					  "[BTCoex], BT Rssi state stay at Low\n");
+			}
+		} else if ((coex_sta->pre_bt_rssi_state ==
+						BTC_RSSI_STATE_MEDIUM) ||
+			   (coex_sta->pre_bt_rssi_state ==
+						BTC_RSSI_STATE_STAY_MEDIUM)) {
+			if (bt_rssi >= rssi_thresh1 +
+				       BTC_RSSI_COEX_THRESH_TOL_8723B_2ANT) {
+				bt_rssi_state = BTC_RSSI_STATE_HIGH;
+				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_RSSI_STATE,
+					  "[BTCoex], BT Rssi state switch to High\n");
+			} else if (bt_rssi < rssi_thresh) {
+				bt_rssi_state = BTC_RSSI_STATE_LOW;
+				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_RSSI_STATE,
+					  "[BTCoex], BT Rssi state switch to Low\n");
+			} else {
+				bt_rssi_state = BTC_RSSI_STATE_STAY_MEDIUM;
+				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_RSSI_STATE,
+					  "[BTCoex], BT Rssi state stay at Medium\n");
+			}
+		} else {
+			if (bt_rssi < rssi_thresh1) {
+				bt_rssi_state = BTC_RSSI_STATE_MEDIUM;
+				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_RSSI_STATE,
+					  "[BTCoex], BT Rssi state switch to Medium\n");
+			} else {
+				bt_rssi_state = BTC_RSSI_STATE_STAY_HIGH;
+				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_RSSI_STATE,
+					  "[BTCoex], BT Rssi state stay at High\n");
+			}
+		}
+	}
+
+	coex_sta->pre_bt_rssi_state = bt_rssi_state;
+
+	return bt_rssi_state;
+}
+
+static u8 halbtc8723b2ant_wifi_rssi_state(struct btc_coexist *btcoexist,
+					  u8 index, u8 level_num,
+					  u8 rssi_thresh, u8 rssi_thresh1)
+{
+	s32 wifi_rssi = 0;
+	u8 wifi_rssi_state = coex_sta->pre_wifi_rssi_state[index];
+
+	btcoexist->btc_get(btcoexist, BTC_GET_S4_WIFI_RSSI, &wifi_rssi);
+
+	if (level_num == 2) {
+		if ((coex_sta->pre_wifi_rssi_state[index] ==
+						BTC_RSSI_STATE_LOW) ||
+		    (coex_sta->pre_wifi_rssi_state[index] ==
+						BTC_RSSI_STATE_STAY_LOW)) {
+			if (wifi_rssi >= rssi_thresh +
+					 BTC_RSSI_COEX_THRESH_TOL_8723B_2ANT) {
+				wifi_rssi_state = BTC_RSSI_STATE_HIGH;
+				BTC_PRINT(BTC_MSG_ALGORITHM,
+					  ALGO_WIFI_RSSI_STATE,
+					  "[BTCoex], wifi RSSI state switch to High\n");
+			} else {
+				wifi_rssi_state = BTC_RSSI_STATE_STAY_LOW;
+				BTC_PRINT(BTC_MSG_ALGORITHM,
+					  ALGO_WIFI_RSSI_STATE,
+					  "[BTCoex], wifi RSSI state stay at Low\n");
+			}
+		} else {
+			if (wifi_rssi < rssi_thresh) {
+				wifi_rssi_state = BTC_RSSI_STATE_LOW;
+				BTC_PRINT(BTC_MSG_ALGORITHM,
+					  ALGO_WIFI_RSSI_STATE,
+					  "[BTCoex], wifi RSSI state switch to Low\n");
+			} else {
+				wifi_rssi_state = BTC_RSSI_STATE_STAY_HIGH;
+				BTC_PRINT(BTC_MSG_ALGORITHM,
+					  ALGO_WIFI_RSSI_STATE,
+					  "[BTCoex], wifi RSSI state stay at High\n");
+			}
+		}
+	} else if (level_num == 3) {
+		if (rssi_thresh > rssi_thresh1) {
+			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_WIFI_RSSI_STATE,
+				  "[BTCoex], wifi RSSI thresh error!!\n");
+			return coex_sta->pre_wifi_rssi_state[index];
+		}
+
+		if ((coex_sta->pre_wifi_rssi_state[index] ==
+						BTC_RSSI_STATE_LOW) ||
+		    (coex_sta->pre_wifi_rssi_state[index] ==
+						BTC_RSSI_STATE_STAY_LOW)) {
+			if (wifi_rssi >= rssi_thresh +
+					BTC_RSSI_COEX_THRESH_TOL_8723B_2ANT) {
+				wifi_rssi_state = BTC_RSSI_STATE_MEDIUM;
+				BTC_PRINT(BTC_MSG_ALGORITHM,
+					  ALGO_WIFI_RSSI_STATE,
+					  "[BTCoex], wifi RSSI state switch to Medium\n");
+			} else {
+				wifi_rssi_state = BTC_RSSI_STATE_STAY_LOW;
+				BTC_PRINT(BTC_MSG_ALGORITHM,
+					  ALGO_WIFI_RSSI_STATE,
+					  "[BTCoex], wifi RSSI state stay at Low\n");
+			}
+		} else if ((coex_sta->pre_wifi_rssi_state[index] ==
+						BTC_RSSI_STATE_MEDIUM) ||
+			   (coex_sta->pre_wifi_rssi_state[index] ==
+						BTC_RSSI_STATE_STAY_MEDIUM)) {
+			if (wifi_rssi >= rssi_thresh1 +
+					 BTC_RSSI_COEX_THRESH_TOL_8723B_2ANT) {
+				wifi_rssi_state = BTC_RSSI_STATE_HIGH;
+				BTC_PRINT(BTC_MSG_ALGORITHM,
+					  ALGO_WIFI_RSSI_STATE,
+					  "[BTCoex], wifi RSSI state switch to High\n");
+			} else if (wifi_rssi < rssi_thresh) {
+				wifi_rssi_state = BTC_RSSI_STATE_LOW;
+				BTC_PRINT(BTC_MSG_ALGORITHM,
+					  ALGO_WIFI_RSSI_STATE,
+					  "[BTCoex], wifi RSSI state switch to Low\n");
+			} else {
+				wifi_rssi_state = BTC_RSSI_STATE_STAY_MEDIUM;
+				BTC_PRINT(BTC_MSG_ALGORITHM,
+					  ALGO_WIFI_RSSI_STATE,
+					  "[BTCoex], wifi RSSI state stay at Medium\n");
+			}
+		} else {
+			if (wifi_rssi < rssi_thresh1) {
+				wifi_rssi_state = BTC_RSSI_STATE_MEDIUM;
+				BTC_PRINT(BTC_MSG_ALGORITHM,
+					  ALGO_WIFI_RSSI_STATE,
+					  "[BTCoex], wifi RSSI state switch to Medium\n");
+			} else {
+				wifi_rssi_state = BTC_RSSI_STATE_STAY_HIGH;
+				BTC_PRINT(BTC_MSG_ALGORITHM,
+					  ALGO_WIFI_RSSI_STATE,
+					  "[BTCoex], wifi RSSI state stay at High\n");
+			}
+		}
+	}
+
+	coex_sta->pre_wifi_rssi_state[index] = wifi_rssi_state;
+
+	return wifi_rssi_state;
+}
+
+static void halbtc8723b2ant_monitor_bt_ctr(struct btc_coexist *btcoexist)
+{
+	u32 reg_hp_txrx, reg_lp_txrx, u32tmp;
+	u32 reg_hp_tx = 0, reg_hp_rx = 0;
+	u32 reg_lp_tx = 0, reg_lp_rx = 0;
+
+	reg_hp_txrx = 0x770;
+	reg_lp_txrx = 0x774;
+
+	u32tmp = btcoexist->btc_read_4byte(btcoexist, reg_hp_txrx);
+	reg_hp_tx = u32tmp & MASKLWORD;
+	reg_hp_rx = (u32tmp & MASKHWORD) >> 16;
+
+	u32tmp = btcoexist->btc_read_4byte(btcoexist, reg_lp_txrx);
+	reg_lp_tx = u32tmp & MASKLWORD;
+	reg_lp_rx = (u32tmp & MASKHWORD) >> 16;
+
+	coex_sta->high_priority_tx = reg_hp_tx;
+	coex_sta->high_priority_rx = reg_hp_rx;
+	coex_sta->low_priority_tx = reg_lp_tx;
+	coex_sta->low_priority_rx = reg_lp_rx;
+
+	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_MONITOR,
+		  "[BTCoex], High Priority Tx/Rx(reg 0x%x) = 0x%x(%d)/0x%x(%d)\n",
+		  reg_hp_txrx, reg_hp_tx, reg_hp_tx, reg_hp_rx, reg_hp_rx);
+	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_MONITOR,
+		  "[BTCoex], Low Priority Tx/Rx(reg 0x%x) = 0x%x(%d)/0x%x(%d)\n",
+		  reg_lp_txrx, reg_lp_tx, reg_lp_tx, reg_lp_rx, reg_lp_rx);
+
+	/* reset counter */
+	btcoexist->btc_write_1byte(btcoexist, 0x76e, 0xc);
+}
+
+static void halbtc8723b2ant_query_bt_info(struct btc_coexist *btcoexist)
+{
+	u8 h2c_parameter[1] = {0};
+
+	coex_sta->c2h_bt_info_req_sent = true;
+
+	h2c_parameter[0] |= BIT(0);	/* trigger */
+
+	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_EXEC,
+		  "[BTCoex], Query Bt Info, FW write 0x61 = 0x%x\n",
+		  h2c_parameter[0]);
+
+	btcoexist->btc_fill_h2c(btcoexist, 0x61, 1, h2c_parameter);
+}
+
+static bool is_wifi_status_changed(struct btc_coexist *btcoexist)
+{
+	static bool pre_wifi_busy;
+	static bool pre_under_4way;
+	static bool pre_bt_hs_on;
+	bool wifi_busy = false, under_4way = false, bt_hs_on = false;
+	bool wifi_connected = false;
+
+	btcoexist->btc_get(btcoexist, BTC_GET_BL_WIFI_CONNECTED,
+			   &wifi_connected);
+	btcoexist->btc_get(btcoexist, BTC_GET_BL_WIFI_BUSY, &wifi_busy);
+	btcoexist->btc_get(btcoexist, BTC_GET_BL_HS_OPERATION, &bt_hs_on);
+	btcoexist->btc_get(btcoexist, BTC_GET_BL_WIFI_4_WAY_PROGRESS,
+			   &under_4way);
+
+	if (wifi_connected) {
+		if (wifi_busy != pre_wifi_busy) {
+			pre_wifi_busy = wifi_busy;
+			return true;
+		}
+
+		if (under_4way != pre_under_4way) {
+			pre_under_4way = under_4way;
+			return true;
+		}
+
+		if (bt_hs_on != pre_bt_hs_on) {
+			pre_bt_hs_on = bt_hs_on;
+			return true;
+		}
+	}
+
+	return false;
+}
+
+static void halbtc8723b2ant_update_bt_link_info(struct btc_coexist *btcoexist)
+{
+	/*struct btc_stack_info *stack_info = &btcoexist->stack_info;*/
+	struct btc_bt_link_info *bt_link_info = &btcoexist->bt_link_info;
+	bool bt_hs_on = false;
+
+#if (BT_AUTO_REPORT_ONLY_8723B_2ANT == 1) /* profile from bt patch */
+	btcoexist->btc_get(btcoexist, BTC_GET_BL_HS_OPERATION, &bt_hs_on);
+
+	bt_link_info->bt_link_exist = coex_sta->bt_link_exist;
+	bt_link_info->sco_exist = coex_sta->sco_exist;
+	bt_link_info->a2dp_exist = coex_sta->a2dp_exist;
+	bt_link_info->pan_exist = coex_sta->pan_exist;
+	bt_link_info->hid_exist = coex_sta->hid_exist;
+
+	/* work around for HS mode. */
+	if (bt_hs_on) {
+		bt_link_info->pan_exist = true;
+		bt_link_info->bt_link_exist = true;
+	}
+#else	/* profile from bt stack */
+	bt_link_info->bt_link_exist = stack_info->bt_link_exist;
+	bt_link_info->sco_exist = stack_info->sco_exist;
+	bt_link_info->a2dp_exist = stack_info->a2dp_exist;
+	bt_link_info->pan_exist = stack_info->pan_exist;
+	bt_link_info->hid_exist = stack_info->hid_exist;
+
+	/*for win-8 stack HID report error*/
+	if (!stack_info->hid_exist)
+		stack_info->hid_exist = coex_sta->hid_exist;
+	/*sync  BTInfo with BT firmware and stack*/
+	/* when stack HID report error, here we use the info from bt fw.*/
+	if (!stack_info->bt_link_exist)
+		stack_info->bt_link_exist = coex_sta->bt_link_exist;
+#endif
+	/* check if Sco only */
+	if (bt_link_info->sco_exist && !bt_link_info->a2dp_exist &&
+	    !bt_link_info->pan_exist && !bt_link_info->hid_exist)
+		bt_link_info->sco_only = true;
+	else
+		bt_link_info->sco_only = false;
+
+	/* check if A2dp only */
+	if (!bt_link_info->sco_exist && bt_link_info->a2dp_exist &&
+	    !bt_link_info->pan_exist && !bt_link_info->hid_exist)
+		bt_link_info->a2dp_only = true;
+	else
+		bt_link_info->a2dp_only = false;
+
+	/* check if Pan only */
+	if (!bt_link_info->sco_exist && !bt_link_info->a2dp_exist &&
+	    bt_link_info->pan_exist && !bt_link_info->hid_exist)
+		bt_link_info->pan_only = true;
+	else
+		bt_link_info->pan_only = false;
+
+	/* check if Hid only */
+	if (!bt_link_info->sco_exist && !bt_link_info->a2dp_exist &&
+	    !bt_link_info->pan_exist && bt_link_info->hid_exist)
+		bt_link_info->hid_only = true;
+	else
+		bt_link_info->hid_only = false;
+}
+
+static u8 halbtc8723b2ant_action_algorithm(struct btc_coexist *btcoexist)
+{
+	struct btc_bt_link_info *bt_link_info = &btcoexist->bt_link_info;
+	bool bt_hs_on = false;
+	u8 algorithm = BT_8723B_2ANT_COEX_ALGO_UNDEFINED;
+	u8 num_of_diff_profile = 0;
+
+	btcoexist->btc_get(btcoexist, BTC_GET_BL_HS_OPERATION, &bt_hs_on);
+
+	if (!bt_link_info->bt_link_exist) {
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+			  "[BTCoex], No BT link exists!!!\n");
+		return algorithm;
+	}
+
+	if (bt_link_info->sco_exist)
+		num_of_diff_profile++;
+	if (bt_link_info->hid_exist)
+		num_of_diff_profile++;
+	if (bt_link_info->pan_exist)
+		num_of_diff_profile++;
+	if (bt_link_info->a2dp_exist)
+		num_of_diff_profile++;
+
+	if (num_of_diff_profile == 1) {
+		if (bt_link_info->sco_exist) {
+			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+				  "[BTCoex], SCO only\n");
+			algorithm = BT_8723B_2ANT_COEX_ALGO_SCO;
+		} else {
+			if (bt_link_info->hid_exist) {
+				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+					  "[BTCoex], HID only\n");
+				algorithm = BT_8723B_2ANT_COEX_ALGO_HID;
+			} else if (bt_link_info->a2dp_exist) {
+				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+					  "[BTCoex], A2DP only\n");
+				algorithm = BT_8723B_2ANT_COEX_ALGO_A2DP;
+			} else if (bt_link_info->pan_exist) {
+				if (bt_hs_on) {
+					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+						  "[BTCoex], PAN(HS) only\n");
+					algorithm =
+						BT_8723B_2ANT_COEX_ALGO_PANHS;
+				} else {
+					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+						  "[BTCoex], PAN(EDR) only\n");
+					algorithm =
+						BT_8723B_2ANT_COEX_ALGO_PANEDR;
+				}
+			}
+		}
+	} else if (num_of_diff_profile == 2) {
+		if (bt_link_info->sco_exist) {
+			if (bt_link_info->hid_exist) {
+				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+					  "[BTCoex], SCO + HID\n");
+				algorithm = BT_8723B_2ANT_COEX_ALGO_PANEDR_HID;
+			} else if (bt_link_info->a2dp_exist) {
+				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+					  "[BTCoex], SCO + A2DP ==> SCO\n");
+				algorithm = BT_8723B_2ANT_COEX_ALGO_PANEDR_HID;
+			} else if (bt_link_info->pan_exist) {
+				if (bt_hs_on) {
+					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+						  "[BTCoex], SCO + PAN(HS)\n");
+					algorithm = BT_8723B_2ANT_COEX_ALGO_SCO;
+				} else {
+					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+						  "[BTCoex], SCO + PAN(EDR)\n");
+					algorithm =
+					    BT_8723B_2ANT_COEX_ALGO_PANEDR_HID;
+				}
+			}
+		} else {
+			if (bt_link_info->hid_exist &&
+			    bt_link_info->a2dp_exist) {
+				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+					  "[BTCoex], HID + A2DP\n");
+				algorithm = BT_8723B_2ANT_COEX_ALGO_HID_A2DP;
+			} else if (bt_link_info->hid_exist &&
+				   bt_link_info->pan_exist) {
+				if (bt_hs_on) {
+					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+						  "[BTCoex], HID + PAN(HS)\n");
+					algorithm = BT_8723B_2ANT_COEX_ALGO_HID;
+				} else {
+					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+						  "[BTCoex], HID + PAN(EDR)\n");
+					algorithm =
+					    BT_8723B_2ANT_COEX_ALGO_PANEDR_HID;
+				}
+			} else if (bt_link_info->pan_exist &&
+				   bt_link_info->a2dp_exist) {
+				if (bt_hs_on) {
+					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+						  "[BTCoex], A2DP + PAN(HS)\n");
+					algorithm =
+					    BT_8723B_2ANT_COEX_ALGO_A2DP_PANHS;
+				} else {
+					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+						  "[BTCoex], A2DP + PAN(EDR)\n");
+					algorithm =
+					    BT_8723B_2ANT_COEX_ALGO_PANEDR_A2DP;
+				}
+			}
+		}
+	} else if (num_of_diff_profile == 3) {
+		if (bt_link_info->sco_exist) {
+			if (bt_link_info->hid_exist &&
+			    bt_link_info->a2dp_exist) {
+				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+					  "[BTCoex], SCO + HID + A2DP ==> HID\n");
+				algorithm = BT_8723B_2ANT_COEX_ALGO_PANEDR_HID;
+			} else if (bt_link_info->hid_exist &&
+				   bt_link_info->pan_exist) {
+				if (bt_hs_on) {
+					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+						  "[BTCoex], SCO + HID + PAN(HS)\n");
+					algorithm =
+					    BT_8723B_2ANT_COEX_ALGO_PANEDR_HID;
+				} else {
+					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+						  "[BTCoex], SCO + HID + PAN(EDR)\n");
+					algorithm =
+					    BT_8723B_2ANT_COEX_ALGO_PANEDR_HID;
+				}
+			} else if (bt_link_info->pan_exist &&
+				   bt_link_info->a2dp_exist) {
+				if (bt_hs_on) {
+					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+						  "[BTCoex], SCO + A2DP + PAN(HS)\n");
+					algorithm =
+					    BT_8723B_2ANT_COEX_ALGO_PANEDR_HID;
+				} else {
+					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+						  "[BTCoex], SCO + A2DP + PAN(EDR) ==> HID\n");
+					algorithm =
+					    BT_8723B_2ANT_COEX_ALGO_PANEDR_HID;
+				}
+			}
+		} else {
+			if (bt_link_info->hid_exist &&
+			    bt_link_info->pan_exist &&
+			    bt_link_info->a2dp_exist) {
+				if (bt_hs_on) {
+					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+						  "[BTCoex], HID + A2DP + PAN(HS)\n");
+					algorithm =
+					    BT_8723B_2ANT_COEX_ALGO_HID_A2DP;
+				} else {
+					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+						  "[BTCoex], HID + A2DP + PAN(EDR)\n");
+					algorithm =
+					BT_8723B_2ANT_COEX_ALGO_HID_A2DP_PANEDR;
+				}
+			}
+		}
+	} else if (num_of_diff_profile >= 3) {
+		if (bt_link_info->sco_exist) {
+			if (bt_link_info->hid_exist &&
+			    bt_link_info->pan_exist &&
+			    bt_link_info->a2dp_exist) {
+				if (bt_hs_on) {
+					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+						  "[BTCoex], Error!!! SCO + HID + A2DP + PAN(HS)\n");
+				} else {
+					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+						  "[BTCoex], SCO + HID + A2DP + PAN(EDR) ==>PAN(EDR)+HID\n");
+					algorithm =
+					    BT_8723B_2ANT_COEX_ALGO_PANEDR_HID;
+				}
+			}
+		}
+	}
+
+	return algorithm;
+}
+
+static bool halbtc8723b2ant_need_to_dec_bt_pwr(struct btc_coexist *btcoexist)
+{
+	bool ret = false;
+	bool bt_hs_on = false, wifi_connected = false;
+	s32 bt_hs_rssi = 0;
+	u8 bt_rssi_state;
+
+	if (!btcoexist->btc_get(btcoexist, BTC_GET_BL_HS_OPERATION,
+				&bt_hs_on))
+		return false;
+	if (!btcoexist->btc_get(btcoexist, BTC_GET_BL_WIFI_CONNECTED,
+				&wifi_connected))
+		return false;
+	if (!btcoexist->btc_get(btcoexist, BTC_GET_S4_HS_RSSI,
+				&bt_hs_rssi))
+		return false;
+
+	bt_rssi_state = halbtc8723b2ant_bt_rssi_state(2, 29, 0);
+
+	if (wifi_connected) {
+		if (bt_hs_on) {
+			if (bt_hs_rssi > 37) {
+				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW,
+					  "[BTCoex], Need to decrease bt power for HS mode!!\n");
+				ret = true;
+			}
+		} else {
+			if ((bt_rssi_state == BTC_RSSI_STATE_HIGH) ||
+			    (bt_rssi_state == BTC_RSSI_STATE_STAY_HIGH)) {
+				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW,
+					  "[BTCoex], Need to decrease bt power for Wifi is connected!!\n");
+				ret = true;
+			}
+		}
+	}
+
+	return ret;
+}
+
+static void set_fw_dac_swing_level(struct btc_coexist *btcoexist,
+				   u8 dac_swing_lvl)
+{
+	u8 h2c_parameter[1] = {0};
+
+	/* There are several type of dacswing
+	 * 0x18/ 0x10/ 0xc/ 0x8/ 0x4/ 0x6 */
+	h2c_parameter[0] = dac_swing_lvl;
+
+	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_EXEC,
+		  "[BTCoex], Set Dac Swing Level = 0x%x\n", dac_swing_lvl);
+	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_EXEC,
+		  "[BTCoex], FW write 0x64 = 0x%x\n", h2c_parameter[0]);
+
+	btcoexist->btc_fill_h2c(btcoexist, 0x64, 1, h2c_parameter);
+}
+
+static void halbtc8723b2ant_set_fw_dec_bt_pwr(struct btc_coexist *btcoexist,
+					      bool dec_bt_pwr)
+{
+	u8 h2c_parameter[1] = {0};
+
+	h2c_parameter[0] = 0;
+
+	if (dec_bt_pwr)
+		h2c_parameter[0] |= BIT(1);
+
+	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_EXEC,
+		  "[BTCoex], decrease Bt Power : %s, FW write 0x62 = 0x%x\n",
+		  (dec_bt_pwr ? "Yes!!" : "No!!"), h2c_parameter[0]);
+
+	btcoexist->btc_fill_h2c(btcoexist, 0x62, 1, h2c_parameter);
+}
+
+static void halbtc8723b2ant_dec_bt_pwr(struct btc_coexist *btcoexist,
+				       bool force_exec, bool dec_bt_pwr)
+{
+	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW,
+		  "[BTCoex], %s Dec BT power = %s\n",
+		  (force_exec ? "force to" : ""), (dec_bt_pwr ? "ON" : "OFF"));
+	coex_dm->cur_dec_bt_pwr = dec_bt_pwr;
+
+	if (!force_exec) {
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_DETAIL,
+			  "[BTCoex], bPreDecBtPwr =%d, bCurDecBtPwr =%d\n",
+			  coex_dm->pre_dec_bt_pwr, coex_dm->cur_dec_bt_pwr);
+
+		if (coex_dm->pre_dec_bt_pwr == coex_dm->cur_dec_bt_pwr)
+			return;
+	}
+	halbtc8723b2ant_set_fw_dec_bt_pwr(btcoexist, coex_dm->cur_dec_bt_pwr);
+
+	coex_dm->pre_dec_bt_pwr = coex_dm->cur_dec_bt_pwr;
+}
+
+static void halbtc8723b2ant_fw_dac_swing_lvl(struct btc_coexist *btcoexist,
+					     bool force_exec,
+					     u8 fw_dac_swing_lvl)
+{
+	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW,
+		  "[BTCoex], %s set FW Dac Swing level = %d\n",
+		  (force_exec ? "force to" : ""), fw_dac_swing_lvl);
+	coex_dm->cur_fw_dac_swing_lvl = fw_dac_swing_lvl;
+
+	if (!force_exec) {
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_DETAIL,
+			  "[BTCoex], preFwDacSwingLvl =%d, curFwDacSwingLvl =%d\n",
+			  coex_dm->pre_fw_dac_swing_lvl,
+			  coex_dm->cur_fw_dac_swing_lvl);
+
+		if (coex_dm->pre_fw_dac_swing_lvl ==
+		   coex_dm->cur_fw_dac_swing_lvl)
+			return;
+	}
+
+	set_fw_dac_swing_level(btcoexist, coex_dm->cur_fw_dac_swing_lvl);
+	coex_dm->pre_fw_dac_swing_lvl = coex_dm->cur_fw_dac_swing_lvl;
+}
+
+static void set_sw_rf_rx_lpf_corner(struct btc_coexist *btcoexist,
+				    bool rx_rf_shrink_on)
+{
+	if (rx_rf_shrink_on) {
+		/* Shrink RF Rx LPF corner */
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW_EXEC,
+			  "[BTCoex], Shrink RF Rx LPF corner!!\n");
+		btcoexist->btc_set_rf_reg(btcoexist, BTC_RF_A, 0x1e,
+					  0xfffff, 0xffffc);
+	} else {
+		/* Resume RF Rx LPF corner */
+		/* After initialized, we can use coex_dm->btRf0x1eBackup */
+		if (btcoexist->initilized) {
+			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW_EXEC,
+				  "[BTCoex], Resume RF Rx LPF corner!!\n");
+			btcoexist->btc_set_rf_reg(btcoexist, BTC_RF_A, 0x1e,
+						  0xfffff,
+						  coex_dm->bt_rf0x1e_backup);
+		}
+	}
+}
+
+static void halbtc8723b2ant_rf_shrink(struct btc_coexist *btcoexist,
+				      bool force_exec, bool rx_rf_shrink_on)
+{
+	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW,
+		  "[BTCoex], %s turn Rx RF Shrink = %s\n",
+		  (force_exec ? "force to" : ""),
+		  (rx_rf_shrink_on ? "ON" : "OFF"));
+	coex_dm->cur_rf_rx_lpf_shrink = rx_rf_shrink_on;
+
+	if (!force_exec) {
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW_DETAIL,
+			  "[BTCoex], bPreRfRxLpfShrink =%d, bCurRfRxLpfShrink =%d\n",
+			  coex_dm->pre_rf_rx_lpf_shrink,
+			  coex_dm->cur_rf_rx_lpf_shrink);
+
+		if (coex_dm->pre_rf_rx_lpf_shrink ==
+		    coex_dm->cur_rf_rx_lpf_shrink)
+			return;
+	}
+	set_sw_rf_rx_lpf_corner(btcoexist, coex_dm->cur_rf_rx_lpf_shrink);
+
+	coex_dm->pre_rf_rx_lpf_shrink = coex_dm->cur_rf_rx_lpf_shrink;
+}
+
+static void set_sw_penalty_txrate_adaptive(
+						struct btc_coexist *btcoexist,
+						bool low_penalty_ra)
+{
+	u8 h2c_parameter[6] = {0};
+
+	h2c_parameter[0] = 0x6;	/* opCode, 0x6 = Retry_Penalty*/
+
+	if (low_penalty_ra) {
+		h2c_parameter[1] |= BIT(0);
+		/*normal rate except MCS7/6/5, OFDM54/48/36*/
+		h2c_parameter[2] = 0x00;
+		h2c_parameter[3] = 0xf7;  /*MCS7 or OFDM54*/
+		h2c_parameter[4] = 0xf8;  /*MCS6 or OFDM48*/
+		h2c_parameter[5] = 0xf9;  /*MCS5 or OFDM36*/
+	}
+
+	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_EXEC,
+		  "[BTCoex], set WiFi Low-Penalty Retry: %s",
+		  (low_penalty_ra ? "ON!!" : "OFF!!"));
+
+	btcoexist->btc_fill_h2c(btcoexist, 0x69, 6, h2c_parameter);
+}
+
+static void halbtc8723b2ant_low_penalty_ra(struct btc_coexist *btcoexist,
+					   bool force_exec, bool low_penalty_ra)
+{
+	/*return; */
+	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW,
+		  "[BTCoex], %s turn LowPenaltyRA = %s\n",
+		  (force_exec ? "force to" : ""),
+		  (low_penalty_ra ? "ON" : "OFF"));
+	coex_dm->cur_low_penalty_ra = low_penalty_ra;
+
+	if (!force_exec) {
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW_DETAIL,
+			  "[BTCoex], bPreLowPenaltyRa =%d, bCurLowPenaltyRa =%d\n",
+			  coex_dm->pre_low_penalty_ra,
+			  coex_dm->cur_low_penalty_ra);
+
+		if (coex_dm->pre_low_penalty_ra == coex_dm->cur_low_penalty_ra)
+			return;
+	}
+	set_sw_penalty_txrate_adaptive(btcoexist, coex_dm->cur_low_penalty_ra);
+
+	coex_dm->pre_low_penalty_ra = coex_dm->cur_low_penalty_ra;
+}
+
+static void halbtc8723b2ant_set_dac_swing_reg(struct btc_coexist *btcoexist,
+					      u32 level)
+{
+	u8 val = (u8) level;
+	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW_EXEC,
+		  "[BTCoex], Write SwDacSwing = 0x%x\n", level);
+	btcoexist->btc_write_1byte_bitmask(btcoexist, 0x883, 0x3e, val);
+}
+
+static void set_sw_fulltime_dac_swing(struct btc_coexist *btcoexist,
+				      bool sw_dac_swing_on,
+				      u32 sw_dac_swing_lvl)
+{
+	if (sw_dac_swing_on)
+		halbtc8723b2ant_set_dac_swing_reg(btcoexist, sw_dac_swing_lvl);
+	else
+		halbtc8723b2ant_set_dac_swing_reg(btcoexist, 0x18);
+}
+
+static void halbtc8723b2ant_dac_swing(struct btc_coexist *btcoexist,
+				      bool force_exec, bool dac_swing_on,
+			       u32 dac_swing_lvl)
+{
+	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW,
+		  "[BTCoex], %s turn DacSwing =%s, dac_swing_lvl = 0x%x\n",
+		  (force_exec ? "force to" : ""),
+		  (dac_swing_on ? "ON" : "OFF"), dac_swing_lvl);
+	coex_dm->cur_dac_swing_on = dac_swing_on;
+	coex_dm->cur_dac_swing_lvl = dac_swing_lvl;
+
+	if (!force_exec) {
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW_DETAIL,
+			  "[BTCoex], bPreDacSwingOn =%d, preDacSwingLvl = 0x%x, bCurDacSwingOn =%d, curDacSwingLvl = 0x%x\n",
+			  coex_dm->pre_dac_swing_on, coex_dm->pre_dac_swing_lvl,
+			  coex_dm->cur_dac_swing_on,
+			  coex_dm->cur_dac_swing_lvl);
+
+		if ((coex_dm->pre_dac_swing_on == coex_dm->cur_dac_swing_on) &&
+		    (coex_dm->pre_dac_swing_lvl == coex_dm->cur_dac_swing_lvl))
+			return;
+	}
+	mdelay(30);
+	set_sw_fulltime_dac_swing(btcoexist, dac_swing_on,
+				  dac_swing_lvl);
+
+	coex_dm->pre_dac_swing_on = coex_dm->cur_dac_swing_on;
+	coex_dm->pre_dac_swing_lvl = coex_dm->cur_dac_swing_lvl;
+}
+
+static void halbtc8723b2ant_set_agc_table(struct btc_coexist *btcoexist,
+					  bool agc_table_en)
+{
+	u8 rssi_adjust_val = 0;
+
+	/*  BB AGC Gain Table */
+	if (agc_table_en) {
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW_EXEC,
+			  "[BTCoex], BB Agc Table On!\n");
+		btcoexist->btc_write_4byte(btcoexist, 0xc78, 0x6e1A0001);
+		btcoexist->btc_write_4byte(btcoexist, 0xc78, 0x6d1B0001);
+		btcoexist->btc_write_4byte(btcoexist, 0xc78, 0x6c1C0001);
+		btcoexist->btc_write_4byte(btcoexist, 0xc78, 0x6b1D0001);
+		btcoexist->btc_write_4byte(btcoexist, 0xc78, 0x6a1E0001);
+		btcoexist->btc_write_4byte(btcoexist, 0xc78, 0x691F0001);
+		btcoexist->btc_write_4byte(btcoexist, 0xc78, 0x68200001);
+	} else {
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW_EXEC,
+			  "[BTCoex], BB Agc Table Off!\n");
+		btcoexist->btc_write_4byte(btcoexist, 0xc78, 0xaa1A0001);
+		btcoexist->btc_write_4byte(btcoexist, 0xc78, 0xa91B0001);
+		btcoexist->btc_write_4byte(btcoexist, 0xc78, 0xa81C0001);
+		btcoexist->btc_write_4byte(btcoexist, 0xc78, 0xa71D0001);
+		btcoexist->btc_write_4byte(btcoexist, 0xc78, 0xa61E0001);
+		btcoexist->btc_write_4byte(btcoexist, 0xc78, 0xa51F0001);
+		btcoexist->btc_write_4byte(btcoexist, 0xc78, 0xa4200001);
+	}
+
+	/* RF Gain */
+	btcoexist->btc_set_rf_reg(btcoexist, BTC_RF_A, 0xef, 0xfffff, 0x02000);
+	if (agc_table_en) {
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW_EXEC,
+			  "[BTCoex], Agc Table On!\n");
+		btcoexist->btc_set_rf_reg(btcoexist, BTC_RF_A, 0x3b,
+					  0xfffff, 0x38fff);
+		btcoexist->btc_set_rf_reg(btcoexist, BTC_RF_A, 0x3b,
+					  0xfffff, 0x38ffe);
+	} else {
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW_EXEC,
+			  "[BTCoex], Agc Table Off!\n");
+		btcoexist->btc_set_rf_reg(btcoexist, BTC_RF_A, 0x3b,
+					  0xfffff, 0x380c3);
+		btcoexist->btc_set_rf_reg(btcoexist, BTC_RF_A, 0x3b,
+					  0xfffff, 0x28ce6);
+	}
+	btcoexist->btc_set_rf_reg(btcoexist, BTC_RF_A, 0xef, 0xfffff, 0x0);
+
+	btcoexist->btc_set_rf_reg(btcoexist, BTC_RF_A, 0xed, 0xfffff, 0x1);
+
+	if (agc_table_en) {
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW_EXEC,
+			  "[BTCoex], Agc Table On!\n");
+		btcoexist->btc_set_rf_reg(btcoexist, BTC_RF_A, 0x40,
+					  0xfffff, 0x38fff);
+		btcoexist->btc_set_rf_reg(btcoexist, BTC_RF_A, 0x40,
+					  0xfffff, 0x38ffe);
+	} else {
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW_EXEC,
+			  "[BTCoex], Agc Table Off!\n");
+		btcoexist->btc_set_rf_reg(btcoexist, BTC_RF_A, 0x40,
+					  0xfffff, 0x380c3);
+		btcoexist->btc_set_rf_reg(btcoexist, BTC_RF_A, 0x40,
+					  0xfffff, 0x28ce6);
+	}
+	btcoexist->btc_set_rf_reg(btcoexist, BTC_RF_A, 0xed, 0xfffff, 0x0);
+
+	/* set rssiAdjustVal for wifi module. */
+	if (agc_table_en)
+		rssi_adjust_val = 8;
+	btcoexist->btc_set(btcoexist, BTC_SET_U1_RSSI_ADJ_VAL_FOR_AGC_TABLE_ON,
+			   &rssi_adjust_val);
+}
+
+static void halbtc8723b2ant_agc_table(struct btc_coexist *btcoexist,
+				      bool force_exec, bool agc_table_en)
+{
+	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW,
+		  "[BTCoex], %s %s Agc Table\n",
+		  (force_exec ? "force to" : ""),
+		  (agc_table_en ? "Enable" : "Disable"));
+	coex_dm->cur_agc_table_en = agc_table_en;
+
+	if (!force_exec) {
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW_DETAIL,
+			  "[BTCoex], bPreAgcTableEn =%d, bCurAgcTableEn =%d\n",
+			  coex_dm->pre_agc_table_en, coex_dm->cur_agc_table_en);
+
+		if (coex_dm->pre_agc_table_en == coex_dm->cur_agc_table_en)
+			return;
+	}
+	halbtc8723b2ant_set_agc_table(btcoexist, agc_table_en);
+
+	coex_dm->pre_agc_table_en = coex_dm->cur_agc_table_en;
+}
+
+static void halbtc8723b2ant_set_coex_table(struct btc_coexist *btcoexist,
+					   u32 val0x6c0, u32 val0x6c4,
+					   u32 val0x6c8, u8 val0x6cc)
+{
+	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW_EXEC,
+		  "[BTCoex], set coex table, set 0x6c0 = 0x%x\n", val0x6c0);
+	btcoexist->btc_write_4byte(btcoexist, 0x6c0, val0x6c0);
+
+	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW_EXEC,
+		  "[BTCoex], set coex table, set 0x6c4 = 0x%x\n", val0x6c4);
+	btcoexist->btc_write_4byte(btcoexist, 0x6c4, val0x6c4);
+
+	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW_EXEC,
+		  "[BTCoex], set coex table, set 0x6c8 = 0x%x\n", val0x6c8);
+	btcoexist->btc_write_4byte(btcoexist, 0x6c8, val0x6c8);
+
+	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW_EXEC,
+		  "[BTCoex], set coex table, set 0x6cc = 0x%x\n", val0x6cc);
+	btcoexist->btc_write_1byte(btcoexist, 0x6cc, val0x6cc);
+}
+
+static void halbtc8723b2ant_coex_table(struct btc_coexist *btcoexist,
+				       bool force_exec, u32 val0x6c0,
+				       u32 val0x6c4, u32 val0x6c8,
+				       u8 val0x6cc)
+{
+	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW,
+		  "[BTCoex], %s write Coex Table 0x6c0 = 0x%x, 0x6c4 = 0x%x, 0x6c8 = 0x%x, 0x6cc = 0x%x\n",
+		  (force_exec ? "force to" : ""), val0x6c0,
+		  val0x6c4, val0x6c8, val0x6cc);
+	coex_dm->cur_val0x6c0 = val0x6c0;
+	coex_dm->cur_val0x6c4 = val0x6c4;
+	coex_dm->cur_val0x6c8 = val0x6c8;
+	coex_dm->cur_val0x6cc = val0x6cc;
+
+	if (!force_exec) {
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW_DETAIL,
+			  "[BTCoex], preVal0x6c0 = 0x%x, preVal0x6c4 = 0x%x, preVal0x6c8 = 0x%x, preVal0x6cc = 0x%x !!\n",
+			  coex_dm->pre_val0x6c0, coex_dm->pre_val0x6c4,
+			  coex_dm->pre_val0x6c8, coex_dm->pre_val0x6cc);
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW_DETAIL,
+			  "[BTCoex], curVal0x6c0 = 0x%x, curVal0x6c4 = 0x%x, curVal0x6c8 = 0x%x, curVal0x6cc = 0x%x !!\n",
+			  coex_dm->cur_val0x6c0, coex_dm->cur_val0x6c4,
+			  coex_dm->cur_val0x6c8, coex_dm->cur_val0x6cc);
+
+		if ((coex_dm->pre_val0x6c0 == coex_dm->cur_val0x6c0) &&
+		    (coex_dm->pre_val0x6c4 == coex_dm->cur_val0x6c4) &&
+		    (coex_dm->pre_val0x6c8 == coex_dm->cur_val0x6c8) &&
+		    (coex_dm->pre_val0x6cc == coex_dm->cur_val0x6cc))
+			return;
+	}
+	halbtc8723b2ant_set_coex_table(btcoexist, val0x6c0, val0x6c4,
+				       val0x6c8, val0x6cc);
+
+	coex_dm->pre_val0x6c0 = coex_dm->cur_val0x6c0;
+	coex_dm->pre_val0x6c4 = coex_dm->cur_val0x6c4;
+	coex_dm->pre_val0x6c8 = coex_dm->cur_val0x6c8;
+	coex_dm->pre_val0x6cc = coex_dm->cur_val0x6cc;
+}
+
+static void coex_table_with_type(struct btc_coexist *btcoexist,
+						 bool force_exec, u8 type)
+{
+	switch (type) {
+	case 0:
+		halbtc8723b2ant_coex_table(btcoexist, force_exec, 0x55555555,
+					   0x55555555, 0xffff, 0x3);
+		break;
+	case 1:
+		halbtc8723b2ant_coex_table(btcoexist, force_exec, 0x55555555,
+					   0x5afa5afa, 0xffff, 0x3);
+		break;
+	case 2:
+		halbtc8723b2ant_coex_table(btcoexist, force_exec, 0x5a5a5a5a,
+					   0x5a5a5a5a, 0xffff, 0x3);
+		break;
+	case 3:
+		halbtc8723b2ant_coex_table(btcoexist, force_exec, 0xaaaaaaaa,
+					   0xaaaaaaaa, 0xffff, 0x3);
+		break;
+	case 4:
+		halbtc8723b2ant_coex_table(btcoexist, force_exec, 0xffffffff,
+					   0xffffffff, 0xffff, 0x3);
+		break;
+	case 5:
+		halbtc8723b2ant_coex_table(btcoexist, force_exec, 0x5fff5fff,
+					   0x5fff5fff, 0xffff, 0x3);
+		break;
+	case 6:
+		halbtc8723b2ant_coex_table(btcoexist, force_exec, 0x55ff55ff,
+					   0x5a5a5a5a, 0xffff, 0x3);
+		break;
+	case 7:
+		halbtc8723b2ant_coex_table(btcoexist, force_exec, 0x55ff55ff,
+					   0x5afa5afa, 0xffff, 0x3);
+		break;
+	case 8:
+		halbtc8723b2ant_coex_table(btcoexist, force_exec, 0x5aea5aea,
+					   0x5aea5aea, 0xffff, 0x3);
+		break;
+	case 9:
+		halbtc8723b2ant_coex_table(btcoexist, force_exec, 0x55ff55ff,
+					   0x5aea5aea, 0xffff, 0x3);
+		break;
+	case 10:
+		halbtc8723b2ant_coex_table(btcoexist, force_exec, 0x55ff55ff,
+					   0x5aff5aff, 0xffff, 0x3);
+		break;
+	case 11:
+		halbtc8723b2ant_coex_table(btcoexist, force_exec, 0x55ff55ff,
+					   0x5a5f5a5f, 0xffff, 0x3);
+		break;
+	case 12:
+		halbtc8723b2ant_coex_table(btcoexist, force_exec, 0x55ff55ff,
+					   0x5f5f5f5f, 0xffff, 0x3);
+		break;
+	default:
+		break;
+	}
+}
+
+static void set_fw_ignore_wlan_act(struct btc_coexist *btcoexist,
+				   bool enable)
+{
+	u8 h2c_parameter[1] = {0};
+
+	if (enable)
+		h2c_parameter[0] |= BIT(0);/* function enable*/
+
+	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_EXEC,
+		  "[BTCoex], set FW for BT Ignore Wlan_Act, FW write 0x63 = 0x%x\n",
+		  h2c_parameter[0]);
+
+	btcoexist->btc_fill_h2c(btcoexist, 0x63, 1, h2c_parameter);
+}
+
+static void halbtc8723b2ant_ignore_wlan_act(struct btc_coexist *btcoexist,
+					    bool force_exec, bool enable)
+{
+	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW,
+		  "[BTCoex], %s turn Ignore WlanAct %s\n",
+		  (force_exec ? "force to" : ""), (enable ? "ON" : "OFF"));
+	coex_dm->cur_ignore_wlan_act = enable;
+
+	if (!force_exec) {
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_DETAIL,
+			  "[BTCoex], bPreIgnoreWlanAct = %d, bCurIgnoreWlanAct = %d!!\n",
+			  coex_dm->pre_ignore_wlan_act,
+			  coex_dm->cur_ignore_wlan_act);
+
+		if (coex_dm->pre_ignore_wlan_act ==
+		    coex_dm->cur_ignore_wlan_act)
+			return;
+	}
+	set_fw_ignore_wlan_act(btcoexist, enable);
+
+	coex_dm->pre_ignore_wlan_act = coex_dm->cur_ignore_wlan_act;
+}
+
+static void set_fw_ps_tdma(struct btc_coexist *btcoexist, u8 byte1,
+			   u8 byte2, u8 byte3, u8 byte4, u8 byte5)
+{
+	u8 h2c_parameter[5] = {0};
+
+	h2c_parameter[0] = byte1;
+	h2c_parameter[1] = byte2;
+	h2c_parameter[2] = byte3;
+	h2c_parameter[3] = byte4;
+	h2c_parameter[4] = byte5;
+
+	coex_dm->ps_tdma_para[0] = byte1;
+	coex_dm->ps_tdma_para[1] = byte2;
+	coex_dm->ps_tdma_para[2] = byte3;
+	coex_dm->ps_tdma_para[3] = byte4;
+	coex_dm->ps_tdma_para[4] = byte5;
+
+	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_EXEC,
+		  "[BTCoex], FW write 0x60(5bytes) = 0x%x%08x\n",
+		  h2c_parameter[0],
+		  h2c_parameter[1] << 24 | h2c_parameter[2] << 16 |
+		  h2c_parameter[3] << 8 | h2c_parameter[4]);
+
+	btcoexist->btc_fill_h2c(btcoexist, 0x60, 5, h2c_parameter);
+}
+
+static void halbtc8723b2ant_sw_mechanism1(struct btc_coexist *btcoexist,
+					  bool shrink_rx_lpf,
+					  bool low_penalty_ra,
+					  bool limited_dig,
+					  bool bt_lna_constrain)
+{
+	halbtc8723b2ant_rf_shrink(btcoexist, NORMAL_EXEC, shrink_rx_lpf);
+	halbtc8723b2ant_low_penalty_ra(btcoexist, NORMAL_EXEC, low_penalty_ra);
+}
+
+static void halbtc8723b2ant_sw_mechanism2(struct btc_coexist *btcoexist,
+					  bool agc_table_shift,
+					  bool adc_backoff,
+					  bool sw_dac_swing, u32 dac_swing_lvl)
+{
+	halbtc8723b2ant_agc_table(btcoexist, NORMAL_EXEC, agc_table_shift);
+	halbtc8723b2ant_dac_swing(btcoexist, NORMAL_EXEC, sw_dac_swing,
+				  dac_swing_lvl);
+}
+
+static void halbtc8723b2ant_set_ant_path(struct btc_coexist *btcoexist,
+					 u8 antpos_type, bool init_hwcfg,
+					 bool wifi_off)
+{
+	struct btc_board_info *board_info = &btcoexist->board_info;
+	u32 fw_ver = 0, u32tmp = 0;
+	bool pg_ext_switch = false;
+	bool use_ext_switch = false;
+	u8 h2c_parameter[2] = {0};
+
+	btcoexist->btc_get(btcoexist, BTC_GET_BL_EXT_SWITCH, &pg_ext_switch);
+	btcoexist->btc_get(btcoexist, BTC_GET_U4_WIFI_FW_VER, &fw_ver);
+
+	if ((fw_ver < 0xc0000) || pg_ext_switch)
+		use_ext_switch = true;
+
+	if (init_hwcfg) {
+		/* 0x4c[23] = 0, 0x4c[24] = 1  Antenna control by WL/BT */
+		u32tmp = btcoexist->btc_read_4byte(btcoexist, 0x4c);
+		u32tmp &= ~BIT(23);
+		u32tmp |= BIT(24);
+		btcoexist->btc_write_4byte(btcoexist, 0x4c, u32tmp);
+
+		btcoexist->btc_write_1byte(btcoexist, 0x974, 0xff);
+		btcoexist->btc_write_1byte_bitmask(btcoexist, 0x944, 0x3, 0x3);
+		btcoexist->btc_write_1byte(btcoexist, 0x930, 0x77);
+		btcoexist->btc_write_1byte_bitmask(btcoexist, 0x67, 0x20, 0x1);
+
+		/* Force GNT_BT to low */
+		btcoexist->btc_write_1byte_bitmask(btcoexist, 0x765, 0x18, 0x0);
+		btcoexist->btc_write_2byte(btcoexist, 0x948, 0x0);
+
+		if (board_info->btdm_ant_pos == BTC_ANTENNA_AT_MAIN_PORT) {
+			/* tell firmware "no antenna inverse" */
+			h2c_parameter[0] = 0;
+			h2c_parameter[1] = 1;  /* ext switch type */
+			btcoexist->btc_fill_h2c(btcoexist, 0x65, 2,
+						h2c_parameter);
+		} else {
+			/* tell firmware "antenna inverse" */
+			h2c_parameter[0] = 1;
+			h2c_parameter[1] = 1;  /* ext switch type */
+			btcoexist->btc_fill_h2c(btcoexist, 0x65, 2,
+						h2c_parameter);
+		}
+	}
+
+	/* ext switch setting */
+	if (use_ext_switch) {
+		/* fixed internal switch S1->WiFi, S0->BT */
+		btcoexist->btc_write_2byte(btcoexist, 0x948, 0x0);
+		switch (antpos_type) {
+		case BTC_ANT_WIFI_AT_MAIN:
+			/* ext switch main at wifi */
+			btcoexist->btc_write_1byte_bitmask(btcoexist, 0x92c,
+							   0x3, 0x1);
+			break;
+		case BTC_ANT_WIFI_AT_AUX:
+			/* ext switch aux at wifi */
+			btcoexist->btc_write_1byte_bitmask(btcoexist,
+							   0x92c, 0x3, 0x2);
+			break;
+		}
+	} else {	/* internal switch */
+		/* fixed ext switch */
+		btcoexist->btc_write_1byte_bitmask(btcoexist, 0x92c, 0x3, 0x1);
+		switch (antpos_type) {
+		case BTC_ANT_WIFI_AT_MAIN:
+			/* fixed internal switch S1->WiFi, S0->BT */
+			btcoexist->btc_write_2byte(btcoexist, 0x948, 0x0);
+			break;
+		case BTC_ANT_WIFI_AT_AUX:
+			/* fixed internal switch S0->WiFi, S1->BT */
+			btcoexist->btc_write_2byte(btcoexist, 0x948, 0x280);
+			break;
+		}
+	}
+}
+
+static void halbtc8723b2ant_ps_tdma(struct btc_coexist *btcoexist,
+				    bool force_exec, bool turn_on, u8 type)
+{
+	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW,
+		  "[BTCoex], %s turn %s PS TDMA, type =%d\n",
+		  (force_exec ? "force to" : ""),
+		  (turn_on ? "ON" : "OFF"), type);
+	coex_dm->cur_ps_tdma_on = turn_on;
+	coex_dm->cur_ps_tdma = type;
+
+	if (!force_exec) {
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_DETAIL,
+			  "[BTCoex], bPrePsTdmaOn = %d, bCurPsTdmaOn = %d!!\n",
+			  coex_dm->pre_ps_tdma_on, coex_dm->cur_ps_tdma_on);
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_DETAIL,
+			  "[BTCoex], prePsTdma = %d, curPsTdma = %d!!\n",
+			  coex_dm->pre_ps_tdma, coex_dm->cur_ps_tdma);
+
+		if ((coex_dm->pre_ps_tdma_on == coex_dm->cur_ps_tdma_on) &&
+		    (coex_dm->pre_ps_tdma == coex_dm->cur_ps_tdma))
+			return;
+	}
+	if (turn_on) {
+		switch (type) {
+		case 1:
+		default:
+			set_fw_ps_tdma(btcoexist, 0xe3, 0x1a, 0x1a, 0xe1, 0x90);
+			break;
+		case 2:
+			set_fw_ps_tdma(btcoexist, 0xe3, 0x12, 0x12, 0xe1, 0x90);
+			break;
+		case 3:
+			set_fw_ps_tdma(btcoexist, 0xe3, 0x1c, 0x3, 0xf1, 0x90);
+			break;
+		case 4:
+			set_fw_ps_tdma(btcoexist, 0xe3, 0x10, 0x03, 0xf1, 0x90);
+			break;
+		case 5:
+			set_fw_ps_tdma(btcoexist, 0xe3, 0x1a, 0x1a, 0x60, 0x90);
+			break;
+		case 6:
+			set_fw_ps_tdma(btcoexist, 0xe3, 0x12, 0x12, 0x60, 0x90);
+			break;
+		case 7:
+			set_fw_ps_tdma(btcoexist, 0xe3, 0x1c, 0x3, 0x70, 0x90);
+			break;
+		case 8:
+			set_fw_ps_tdma(btcoexist, 0xa3, 0x10, 0x3, 0x70, 0x90);
+			break;
+		case 9:
+			set_fw_ps_tdma(btcoexist, 0xe3, 0x1a, 0x1a, 0xe1, 0x90);
+			break;
+		case 10:
+			set_fw_ps_tdma(btcoexist, 0xe3, 0x12, 0x12, 0xe1, 0x90);
+			break;
+		case 11:
+			set_fw_ps_tdma(btcoexist, 0xe3, 0xa, 0xa, 0xe1, 0x90);
+			break;
+		case 12:
+			set_fw_ps_tdma(btcoexist, 0xe3, 0x5, 0x5, 0xe1, 0x90);
+			break;
+		case 13:
+			set_fw_ps_tdma(btcoexist, 0xe3, 0x1a, 0x1a, 0x60, 0x90);
+			break;
+		case 14:
+			set_fw_ps_tdma(btcoexist, 0xe3, 0x12, 0x12, 0x60, 0x90);
+			break;
+		case 15:
+			set_fw_ps_tdma(btcoexist, 0xe3, 0xa, 0xa, 0x60, 0x90);
+			break;
+		case 16:
+			set_fw_ps_tdma(btcoexist, 0xe3, 0x5, 0x5, 0x60, 0x90);
+			break;
+		case 17:
+			set_fw_ps_tdma(btcoexist, 0xa3, 0x2f, 0x2f, 0x60, 0x90);
+			break;
+		case 18:
+			set_fw_ps_tdma(btcoexist, 0xe3, 0x5, 0x5, 0xe1, 0x90);
+			break;
+		case 19:
+			set_fw_ps_tdma(btcoexist, 0xe3, 0x25, 0x25, 0xe1, 0x90);
+			break;
+		case 20:
+			set_fw_ps_tdma(btcoexist, 0xe3, 0x25, 0x25, 0x60, 0x90);
+			break;
+		case 21:
+			set_fw_ps_tdma(btcoexist, 0xe3, 0x15, 0x03, 0x70, 0x90);
+			break;
+		case 71:
+			set_fw_ps_tdma(btcoexist, 0xe3, 0x1a, 0x1a, 0xe1, 0x90);
+			break;
+		}
+	} else {
+		/* disable PS tdma */
+		switch (type) {
+		case 0:
+			set_fw_ps_tdma(btcoexist, 0x0, 0x0, 0x0, 0x40, 0x0);
+			break;
+		case 1:
+			set_fw_ps_tdma(btcoexist, 0x0, 0x0, 0x0, 0x48, 0x0);
+			break;
+		default:
+			set_fw_ps_tdma(btcoexist, 0x0, 0x0, 0x0, 0x40, 0x0);
+			break;
+		}
+	}
+
+	/* update pre state */
+	coex_dm->pre_ps_tdma_on = coex_dm->cur_ps_tdma_on;
+	coex_dm->pre_ps_tdma = coex_dm->cur_ps_tdma;
+}
+
+static void halbtc8723b2ant_coex_alloff(struct btc_coexist *btcoexist)
+{
+	/* fw all off */
+	halbtc8723b2ant_ps_tdma(btcoexist, NORMAL_EXEC, false, 1);
+	halbtc8723b2ant_fw_dac_swing_lvl(btcoexist, NORMAL_EXEC, 6);
+	halbtc8723b2ant_dec_bt_pwr(btcoexist, NORMAL_EXEC, false);
+
+	/* sw all off */
+	halbtc8723b2ant_sw_mechanism1(btcoexist, false, false, false, false);
+	halbtc8723b2ant_sw_mechanism2(btcoexist, false, false, false, 0x18);
+
+	/* hw all off */
+	btcoexist->btc_set_rf_reg(btcoexist, BTC_RF_A, 0x1, 0xfffff, 0x0);
+	coex_table_with_type(btcoexist, NORMAL_EXEC, 0);
+}
+
+static void halbtc8723b2ant_init_coex_dm(struct btc_coexist *btcoexist)
+{
+	/* force to reset coex mechanism*/
+
+	halbtc8723b2ant_ps_tdma(btcoexist, FORCE_EXEC, false, 1);
+	halbtc8723b2ant_fw_dac_swing_lvl(btcoexist, FORCE_EXEC, 6);
+	halbtc8723b2ant_dec_bt_pwr(btcoexist, FORCE_EXEC, false);
+
+	halbtc8723b2ant_sw_mechanism1(btcoexist, false, false, false, false);
+	halbtc8723b2ant_sw_mechanism2(btcoexist, false, false, false, 0x18);
+}
+
+static void halbtc8723b2ant_action_bt_inquiry(struct btc_coexist *btcoexist)
+{
+	bool wifi_connected = false;
+	bool low_pwr_disable = true;
+
+	btcoexist->btc_set(btcoexist, BTC_SET_ACT_DISABLE_LOW_POWER,
+			   &low_pwr_disable);
+	btcoexist->btc_get(btcoexist, BTC_GET_BL_WIFI_CONNECTED,
+			   &wifi_connected);
+
+	if (wifi_connected) {
+		coex_table_with_type(btcoexist, NORMAL_EXEC, 7);
+		halbtc8723b2ant_ps_tdma(btcoexist, NORMAL_EXEC, true, 3);
+	} else {
+		coex_table_with_type(btcoexist, NORMAL_EXEC, 0);
+		halbtc8723b2ant_ps_tdma(btcoexist, NORMAL_EXEC, false, 1);
+	}
+	halbtc8723b2ant_fw_dac_swing_lvl(btcoexist, FORCE_EXEC, 6);
+	halbtc8723b2ant_dec_bt_pwr(btcoexist, NORMAL_EXEC, false);
+
+	halbtc8723b2ant_sw_mechanism1(btcoexist, false, false, false, false);
+	halbtc8723b2ant_sw_mechanism2(btcoexist, false, false, false, 0x18);
+
+	coex_dm->need_recover_0x948 = true;
+	coex_dm->backup_0x948 = btcoexist->btc_read_2byte(btcoexist, 0x948);
+
+	halbtc8723b2ant_set_ant_path(btcoexist, BTC_ANT_WIFI_AT_AUX,
+				     false, false);
+}
+
+static bool halbtc8723b2ant_is_common_action(struct btc_coexist *btcoexist)
+{
+	bool common = false, wifi_connected = false;
+	bool wifi_busy = false;
+	bool bt_hs_on = false, low_pwr_disable = false;
+
+	btcoexist->btc_get(btcoexist, BTC_GET_BL_HS_OPERATION, &bt_hs_on);
+	btcoexist->btc_get(btcoexist, BTC_GET_BL_WIFI_CONNECTED,
+			   &wifi_connected);
+	btcoexist->btc_get(btcoexist, BTC_GET_BL_WIFI_BUSY, &wifi_busy);
+
+	if (!wifi_connected) {
+		low_pwr_disable = false;
+		btcoexist->btc_set(btcoexist, BTC_SET_ACT_DISABLE_LOW_POWER,
+				   &low_pwr_disable);
+
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+			  "[BTCoex], Wifi non-connected idle!!\n");
+
+		btcoexist->btc_set_rf_reg(btcoexist, BTC_RF_A, 0x1, 0xfffff,
+					  0x0);
+		coex_table_with_type(btcoexist, NORMAL_EXEC, 0);
+		halbtc8723b2ant_ps_tdma(btcoexist, NORMAL_EXEC, false, 1);
+		halbtc8723b2ant_fw_dac_swing_lvl(btcoexist, NORMAL_EXEC, 6);
+		halbtc8723b2ant_dec_bt_pwr(btcoexist, NORMAL_EXEC, false);
+
+		halbtc8723b2ant_sw_mechanism1(btcoexist, false, false, false,
+					      false);
+		halbtc8723b2ant_sw_mechanism2(btcoexist, false, false, false,
+					      0x18);
+
+		common = true;
+	} else {
+		if (BT_8723B_2ANT_BT_STATUS_NON_CONNECTED_IDLE ==
+		    coex_dm->bt_status) {
+			low_pwr_disable = false;
+			btcoexist->btc_set(btcoexist,
+					   BTC_SET_ACT_DISABLE_LOW_POWER,
+					   &low_pwr_disable);
+
+			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+				  "[BTCoex], Wifi connected + BT non connected-idle!!\n");
+
+			btcoexist->btc_set_rf_reg(btcoexist, BTC_RF_A, 0x1,
+						  0xfffff, 0x0);
+			coex_table_with_type(btcoexist,
+							     NORMAL_EXEC, 0);
+			halbtc8723b2ant_ps_tdma(btcoexist, NORMAL_EXEC, false,
+						1);
+			halbtc8723b2ant_fw_dac_swing_lvl(btcoexist, NORMAL_EXEC,
+							 0xb);
+			halbtc8723b2ant_dec_bt_pwr(btcoexist, NORMAL_EXEC,
+						   false);
+
+			halbtc8723b2ant_sw_mechanism1(btcoexist, false, false,
+						      false, false);
+			halbtc8723b2ant_sw_mechanism2(btcoexist, false, false,
+						      false, 0x18);
+
+			common = true;
+		} else if (BT_8723B_2ANT_BT_STATUS_CONNECTED_IDLE ==
+			   coex_dm->bt_status) {
+			low_pwr_disable = true;
+			btcoexist->btc_set(btcoexist,
+					   BTC_SET_ACT_DISABLE_LOW_POWER,
+					   &low_pwr_disable);
+
+			if (bt_hs_on)
+				return false;
+			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+				  "[BTCoex], Wifi connected + BT connected-idle!!\n");
+
+			btcoexist->btc_set_rf_reg(btcoexist, BTC_RF_A, 0x1,
+						  0xfffff, 0x0);
+			coex_table_with_type(btcoexist,
+							     NORMAL_EXEC, 0);
+			halbtc8723b2ant_ps_tdma(btcoexist, NORMAL_EXEC, false,
+						1);
+			halbtc8723b2ant_fw_dac_swing_lvl(btcoexist, NORMAL_EXEC,
+							 0xb);
+			halbtc8723b2ant_dec_bt_pwr(btcoexist, NORMAL_EXEC,
+						   false);
+
+			halbtc8723b2ant_sw_mechanism1(btcoexist, true, false,
+						      false, false);
+			halbtc8723b2ant_sw_mechanism2(btcoexist, false, false,
+						      false, 0x18);
+
+			common = true;
+		} else {
+			low_pwr_disable = true;
+			btcoexist->btc_set(btcoexist,
+					   BTC_SET_ACT_DISABLE_LOW_POWER,
+					   &low_pwr_disable);
+
+			if (wifi_busy) {
+				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+					  "[BTCoex], Wifi Connected-Busy + BT Busy!!\n");
+				common = false;
+			} else {
+				if (bt_hs_on)
+					return false;
+
+				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+					  "[BTCoex], Wifi Connected-Idle + BT Busy!!\n");
+
+				btcoexist->btc_set_rf_reg(btcoexist, BTC_RF_A,
+							  0x1, 0xfffff, 0x0);
+				coex_table_with_type(btcoexist,
+					    NORMAL_EXEC, 7);
+				halbtc8723b2ant_ps_tdma(btcoexist, NORMAL_EXEC,
+							true, 21);
+				halbtc8723b2ant_fw_dac_swing_lvl(btcoexist,
+								 NORMAL_EXEC,
+								 0xb);
+				if (halbtc8723b2ant_need_to_dec_bt_pwr(btcoexist))
+					halbtc8723b2ant_dec_bt_pwr(btcoexist,
+								   NORMAL_EXEC,
+								   true);
+				else
+					halbtc8723b2ant_dec_bt_pwr(btcoexist,
+								   NORMAL_EXEC,
+								   false);
+				halbtc8723b2ant_sw_mechanism1(btcoexist, false,
+							      false, false,
+							      false);
+				halbtc8723b2ant_sw_mechanism2(btcoexist, false,
+							      false, false,
+							      0x18);
+				common = true;
+			}
+		}
+	}
+
+	return common;
+}
+static void halbtc8723b2ant_tdma_duration_adjust(struct btc_coexist *btcoexist,
+						 bool sco_hid, bool tx_pause,
+						 u8 max_interval)
+{
+	static s32 up, dn, m, n, wait_count;
+	/*0: no change, +1: increase WiFi duration, -1: decrease WiFi duration*/
+	s32 result;
+	u8 retrycount = 0;
+
+	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW,
+		  "[BTCoex], TdmaDurationAdjust()\n");
+
+	if (!coex_dm->auto_tdma_adjust) {
+		coex_dm->auto_tdma_adjust = true;
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_DETAIL,
+			  "[BTCoex], first run TdmaDurationAdjust()!!\n");
+		if (sco_hid) {
+			if (tx_pause) {
+				if (max_interval == 1) {
+					halbtc8723b2ant_ps_tdma(btcoexist,
+								NORMAL_EXEC,
+								true, 13);
+					coex_dm->ps_tdma_du_adj_type = 13;
+				} else if (max_interval == 2) {
+					halbtc8723b2ant_ps_tdma(btcoexist,
+								NORMAL_EXEC,
+								true, 14);
+					coex_dm->ps_tdma_du_adj_type = 14;
+				} else if (max_interval == 3) {
+					halbtc8723b2ant_ps_tdma(btcoexist,
+								NORMAL_EXEC,
+								true, 15);
+					coex_dm->ps_tdma_du_adj_type = 15;
+				} else {
+					halbtc8723b2ant_ps_tdma(btcoexist,
+								NORMAL_EXEC,
+								true, 15);
+					coex_dm->ps_tdma_du_adj_type = 15;
+				}
+			} else {
+				if (max_interval == 1) {
+					halbtc8723b2ant_ps_tdma(btcoexist,
+								NORMAL_EXEC,
+								true, 9);
+					coex_dm->ps_tdma_du_adj_type = 9;
+				} else if (max_interval == 2) {
+					halbtc8723b2ant_ps_tdma(btcoexist,
+								NORMAL_EXEC,
+								true, 10);
+					coex_dm->ps_tdma_du_adj_type = 10;
+				} else if (max_interval == 3) {
+					halbtc8723b2ant_ps_tdma(btcoexist,
+								NORMAL_EXEC,
+								true, 11);
+					coex_dm->ps_tdma_du_adj_type = 11;
+				} else {
+					halbtc8723b2ant_ps_tdma(btcoexist,
+								NORMAL_EXEC,
+								true, 11);
+					coex_dm->ps_tdma_du_adj_type = 11;
+				}
+			}
+		} else {
+			if (tx_pause) {
+				if (max_interval == 1) {
+					halbtc8723b2ant_ps_tdma(btcoexist,
+								NORMAL_EXEC,
+								true, 5);
+					coex_dm->ps_tdma_du_adj_type = 5;
+				} else if (max_interval == 2) {
+					halbtc8723b2ant_ps_tdma(btcoexist,
+								NORMAL_EXEC,
+								true, 6);
+					coex_dm->ps_tdma_du_adj_type = 6;
+				} else if (max_interval == 3) {
+					halbtc8723b2ant_ps_tdma(btcoexist,
+								NORMAL_EXEC,
+								true, 7);
+					coex_dm->ps_tdma_du_adj_type = 7;
+				} else {
+					halbtc8723b2ant_ps_tdma(btcoexist,
+								NORMAL_EXEC,
+								true, 7);
+					coex_dm->ps_tdma_du_adj_type = 7;
+				}
+			} else {
+				if (max_interval == 1) {
+					halbtc8723b2ant_ps_tdma(btcoexist,
+								NORMAL_EXEC,
+								true, 1);
+					coex_dm->ps_tdma_du_adj_type = 1;
+				} else if (max_interval == 2) {
+					halbtc8723b2ant_ps_tdma(btcoexist,
+								NORMAL_EXEC,
+								true, 2);
+					coex_dm->ps_tdma_du_adj_type = 2;
+				} else if (max_interval == 3) {
+					halbtc8723b2ant_ps_tdma(btcoexist,
+								NORMAL_EXEC,
+								true, 3);
+					coex_dm->ps_tdma_du_adj_type = 3;
+				} else {
+					halbtc8723b2ant_ps_tdma(btcoexist,
+								NORMAL_EXEC,
+								true, 3);
+					coex_dm->ps_tdma_du_adj_type = 3;
+				}
+			}
+		}
+
+		up = 0;
+		dn = 0;
+		m = 1;
+		n = 3;
+		result = 0;
+		wait_count = 0;
+	} else {
+		/*accquire the BT TRx retry count from BT_Info byte2*/
+		retrycount = coex_sta->bt_retry_cnt;
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_DETAIL,
+			  "[BTCoex], retrycount = %d\n", retrycount);
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_DETAIL,
+			  "[BTCoex], up =%d, dn =%d, m =%d, n =%d, wait_count =%d\n",
+			  up, dn, m, n, wait_count);
+		result = 0;
+		wait_count++;
+		 /* no retry in the last 2-second duration*/
+		if (retrycount == 0) {
+			up++;
+			dn--;
+
+			if (dn <= 0)
+				dn = 0;
+
+			if (up >= n) {
+				wait_count = 0;
+				n = 3;
+				up = 0;
+				dn = 0;
+				result = 1;
+				BTC_PRINT(BTC_MSG_ALGORITHM,
+					  ALGO_TRACE_FW_DETAIL,
+					  "[BTCoex], Increase wifi duration!!\n");
+			} /* <= 3 retry in the last 2-second duration*/
+		} else if (retrycount <= 3) {
+			up--;
+			dn++;
+
+			if (up <= 0)
+				up = 0;
+
+			if (dn == 2) {
+				if (wait_count <= 2)
+					m++;
+				else
+					m = 1;
+
+				if (m >= 20)
+					m = 20;
+
+				n = 3 * m;
+				up = 0;
+				dn = 0;
+				wait_count = 0;
+				result = -1;
+				BTC_PRINT(BTC_MSG_ALGORITHM,
+					  ALGO_TRACE_FW_DETAIL,
+					  "[BTCoex], Decrease wifi duration for retrycounter<3!!\n");
+			}
+		} else {
+			if (wait_count == 1)
+				m++;
+			else
+				m = 1;
+
+			if (m >= 20)
+				m = 20;
+
+			n = 3 * m;
+			up = 0;
+			dn = 0;
+			wait_count = 0;
+			result = -1;
+			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_DETAIL,
+				  "[BTCoex], Decrease wifi duration for retrycounter>3!!\n");
+		}
+
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_DETAIL,
+			  "[BTCoex], max Interval = %d\n", max_interval);
+		if (max_interval == 1) {
+			if (tx_pause) {
+				BTC_PRINT(BTC_MSG_ALGORITHM,
+					  ALGO_TRACE_FW_DETAIL,
+					  "[BTCoex], TxPause = 1\n");
+
+				if (coex_dm->cur_ps_tdma == 71) {
+					halbtc8723b2ant_ps_tdma(btcoexist,
+								NORMAL_EXEC,
+								true, 5);
+					coex_dm->ps_tdma_du_adj_type = 5;
+				} else if (coex_dm->cur_ps_tdma == 1) {
+					halbtc8723b2ant_ps_tdma(btcoexist,
+								NORMAL_EXEC,
+								true, 5);
+					coex_dm->ps_tdma_du_adj_type = 5;
+				} else if (coex_dm->cur_ps_tdma == 2) {
+					halbtc8723b2ant_ps_tdma(btcoexist,
+								NORMAL_EXEC,
+								true, 6);
+					coex_dm->ps_tdma_du_adj_type = 6;
+				} else if (coex_dm->cur_ps_tdma == 3) {
+					halbtc8723b2ant_ps_tdma(btcoexist,
+								NORMAL_EXEC,
+								true, 7);
+					coex_dm->ps_tdma_du_adj_type = 7;
+				} else if (coex_dm->cur_ps_tdma == 4) {
+					halbtc8723b2ant_ps_tdma(btcoexist,
+								NORMAL_EXEC,
+								true, 8);
+					coex_dm->ps_tdma_du_adj_type = 8;
+				}
+
+				if (coex_dm->cur_ps_tdma == 9) {
+					halbtc8723b2ant_ps_tdma(btcoexist,
+								NORMAL_EXEC,
+								true, 13);
+					coex_dm->ps_tdma_du_adj_type = 13;
+				} else if (coex_dm->cur_ps_tdma == 10) {
+					halbtc8723b2ant_ps_tdma(btcoexist,
+								NORMAL_EXEC,
+								true, 14);
+					coex_dm->ps_tdma_du_adj_type = 14;
+				} else if (coex_dm->cur_ps_tdma == 11) {
+					halbtc8723b2ant_ps_tdma(btcoexist,
+								NORMAL_EXEC,
+								true, 15);
+					coex_dm->ps_tdma_du_adj_type = 15;
+				} else if (coex_dm->cur_ps_tdma == 12) {
+					halbtc8723b2ant_ps_tdma(btcoexist,
+								NORMAL_EXEC,
+								true, 16);
+					coex_dm->ps_tdma_du_adj_type = 16;
+				}
+
+				if (result == -1) {
+					if (coex_dm->cur_ps_tdma == 5) {
+						halbtc8723b2ant_ps_tdma(
+								btcoexist,
+								NORMAL_EXEC,
+								true, 6);
+						coex_dm->ps_tdma_du_adj_type =
+									      6;
+					} else if (coex_dm->cur_ps_tdma == 6) {
+						halbtc8723b2ant_ps_tdma(
+								btcoexist,
+								NORMAL_EXEC,
+								true, 7);
+						coex_dm->ps_tdma_du_adj_type =
+									      7;
+					} else if (coex_dm->cur_ps_tdma == 7) {
+						halbtc8723b2ant_ps_tdma(
+								btcoexist,
+								NORMAL_EXEC,
+								true, 8);
+						coex_dm->ps_tdma_du_adj_type =
+									      8;
+					} else if (coex_dm->cur_ps_tdma == 13) {
+						halbtc8723b2ant_ps_tdma(
+								btcoexist,
+								NORMAL_EXEC,
+								true, 14);
+						coex_dm->ps_tdma_du_adj_type =
+									     14;
+					} else if (coex_dm->cur_ps_tdma == 14) {
+						halbtc8723b2ant_ps_tdma(
+								btcoexist,
+								NORMAL_EXEC,
+								true, 15);
+						coex_dm->ps_tdma_du_adj_type =
+									     15;
+					} else if (coex_dm->cur_ps_tdma == 15) {
+						halbtc8723b2ant_ps_tdma(
+								btcoexist,
+								NORMAL_EXEC,
+								true, 16);
+						coex_dm->ps_tdma_du_adj_type =
+									     16;
+					}
+				}  else if (result == 1) {
+					if (coex_dm->cur_ps_tdma == 8) {
+						halbtc8723b2ant_ps_tdma(
+								btcoexist,
+								NORMAL_EXEC,
+								true, 7);
+						coex_dm->ps_tdma_du_adj_type =
+									      7;
+					} else if (coex_dm->cur_ps_tdma == 7) {
+						halbtc8723b2ant_ps_tdma(
+								btcoexist,
+								NORMAL_EXEC,
+								true, 6);
+						coex_dm->ps_tdma_du_adj_type =
+									      6;
+					} else if (coex_dm->cur_ps_tdma == 6) {
+						halbtc8723b2ant_ps_tdma(
+								btcoexist,
+								NORMAL_EXEC,
+								true, 5);
+						coex_dm->ps_tdma_du_adj_type =
+									      5;
+					} else if (coex_dm->cur_ps_tdma == 16) {
+						halbtc8723b2ant_ps_tdma(
+								btcoexist,
+								NORMAL_EXEC,
+								true, 15);
+						coex_dm->ps_tdma_du_adj_type =
+									     15;
+					} else if (coex_dm->cur_ps_tdma == 15) {
+						halbtc8723b2ant_ps_tdma(
+								btcoexist,
+								NORMAL_EXEC,
+								true, 14);
+						coex_dm->ps_tdma_du_adj_type =
+									     14;
+					} else if (coex_dm->cur_ps_tdma == 14) {
+						halbtc8723b2ant_ps_tdma(
+								btcoexist,
+								NORMAL_EXEC,
+								true, 13);
+						coex_dm->ps_tdma_du_adj_type =
+									     13;
+					}
+				}
+			} else {
+				BTC_PRINT(BTC_MSG_ALGORITHM,
+					  ALGO_TRACE_FW_DETAIL,
+					  "[BTCoex], TxPause = 0\n");
+				if (coex_dm->cur_ps_tdma == 5) {
+					halbtc8723b2ant_ps_tdma(btcoexist,
+								NORMAL_EXEC,
+								true, 71);
+					coex_dm->ps_tdma_du_adj_type = 71;
+				} else if (coex_dm->cur_ps_tdma == 6) {
+					halbtc8723b2ant_ps_tdma(btcoexist,
+								NORMAL_EXEC,
+								true, 2);
+					coex_dm->ps_tdma_du_adj_type = 2;
+				} else if (coex_dm->cur_ps_tdma == 7) {
+					halbtc8723b2ant_ps_tdma(btcoexist,
+								NORMAL_EXEC,
+								true, 3);
+					coex_dm->ps_tdma_du_adj_type = 3;
+				} else if (coex_dm->cur_ps_tdma == 8) {
+					halbtc8723b2ant_ps_tdma(btcoexist,
+								NORMAL_EXEC,
+								true, 4);
+					coex_dm->ps_tdma_du_adj_type = 4;
+				}
+
+				if (coex_dm->cur_ps_tdma == 13) {
+					halbtc8723b2ant_ps_tdma(btcoexist,
+								NORMAL_EXEC,
+								true, 9);
+					coex_dm->ps_tdma_du_adj_type = 9;
+				} else if (coex_dm->cur_ps_tdma == 14) {
+					halbtc8723b2ant_ps_tdma(btcoexist,
+								NORMAL_EXEC,
+								true, 10);
+					coex_dm->ps_tdma_du_adj_type = 10;
+				} else if (coex_dm->cur_ps_tdma == 15) {
+					halbtc8723b2ant_ps_tdma(btcoexist,
+								NORMAL_EXEC,
+								true, 11);
+					coex_dm->ps_tdma_du_adj_type = 11;
+				} else if (coex_dm->cur_ps_tdma == 16) {
+					halbtc8723b2ant_ps_tdma(btcoexist,
+								NORMAL_EXEC,
+								true, 12);
+					coex_dm->ps_tdma_du_adj_type = 12;
+				}
+
+				if (result == -1) {
+					if (coex_dm->cur_ps_tdma == 71) {
+						halbtc8723b2ant_ps_tdma(
+								btcoexist,
+								NORMAL_EXEC,
+								true, 1);
+						coex_dm->ps_tdma_du_adj_type =
+									      1;
+					} else if (coex_dm->cur_ps_tdma == 1) {
+						halbtc8723b2ant_ps_tdma(
+								btcoexist,
+								NORMAL_EXEC,
+								true, 2);
+						coex_dm->ps_tdma_du_adj_type =
+									      2;
+					} else if (coex_dm->cur_ps_tdma == 2) {
+						halbtc8723b2ant_ps_tdma(
+								btcoexist,
+								NORMAL_EXEC,
+								true, 3);
+						coex_dm->ps_tdma_du_adj_type =
+									      3;
+					} else if (coex_dm->cur_ps_tdma == 3) {
+						halbtc8723b2ant_ps_tdma(
+								btcoexist,
+								NORMAL_EXEC,
+								true, 4);
+						coex_dm->ps_tdma_du_adj_type =
+									      4;
+					} else if (coex_dm->cur_ps_tdma == 9) {
+						halbtc8723b2ant_ps_tdma(
+								btcoexist,
+								NORMAL_EXEC,
+								true, 10);
+						coex_dm->ps_tdma_du_adj_type =
+									     10;
+					} else if (coex_dm->cur_ps_tdma == 10) {
+						halbtc8723b2ant_ps_tdma(
+								btcoexist,
+								NORMAL_EXEC,
+								true, 11);
+						coex_dm->ps_tdma_du_adj_type =
+									     11;
+					} else if (coex_dm->cur_ps_tdma == 11) {
+						halbtc8723b2ant_ps_tdma(
+								btcoexist,
+								NORMAL_EXEC,
+								true, 12);
+						coex_dm->ps_tdma_du_adj_type =
+									     12;
+					}
+				}  else if (result == 1) {
+					if (coex_dm->cur_ps_tdma == 4) {
+						halbtc8723b2ant_ps_tdma(
+								btcoexist,
+								NORMAL_EXEC,
+								true, 3);
+						coex_dm->ps_tdma_du_adj_type =
+									      3;
+					} else if (coex_dm->cur_ps_tdma == 3) {
+						halbtc8723b2ant_ps_tdma(
+								btcoexist,
+								NORMAL_EXEC,
+								true, 2);
+						coex_dm->ps_tdma_du_adj_type =
+									      2;
+					} else if (coex_dm->cur_ps_tdma == 2) {
+						halbtc8723b2ant_ps_tdma(
+								btcoexist,
+								NORMAL_EXEC,
+								true, 1);
+						coex_dm->ps_tdma_du_adj_type =
+									      1;
+					} else if (coex_dm->cur_ps_tdma == 1) {
+						halbtc8723b2ant_ps_tdma(
+								btcoexist,
+								NORMAL_EXEC,
+								true, 71);
+						coex_dm->ps_tdma_du_adj_type =
+									     71;
+					} else if (coex_dm->cur_ps_tdma == 12) {
+						halbtc8723b2ant_ps_tdma(
+								btcoexist,
+								NORMAL_EXEC,
+								true, 11);
+						coex_dm->ps_tdma_du_adj_type =
+									     11;
+					} else if (coex_dm->cur_ps_tdma == 11) {
+						halbtc8723b2ant_ps_tdma(
+								btcoexist,
+								NORMAL_EXEC,
+								true, 10);
+						coex_dm->ps_tdma_du_adj_type =
+									     10;
+					} else if (coex_dm->cur_ps_tdma == 10) {
+						halbtc8723b2ant_ps_tdma(
+								btcoexist,
+								NORMAL_EXEC,
+								true, 9);
+						coex_dm->ps_tdma_du_adj_type =
+									      9;
+					}
+				}
+			}
+		} else if (max_interval == 2) {
+			if (tx_pause) {
+				BTC_PRINT(BTC_MSG_ALGORITHM,
+					  ALGO_TRACE_FW_DETAIL,
+					  "[BTCoex], TxPause = 1\n");
+				if (coex_dm->cur_ps_tdma == 1) {
+					halbtc8723b2ant_ps_tdma(btcoexist,
+								NORMAL_EXEC,
+								true, 6);
+					coex_dm->ps_tdma_du_adj_type = 6;
+				} else if (coex_dm->cur_ps_tdma == 2) {
+					halbtc8723b2ant_ps_tdma(btcoexist,
+								NORMAL_EXEC,
+								true, 6);
+					coex_dm->ps_tdma_du_adj_type = 6;
+				} else if (coex_dm->cur_ps_tdma == 3) {
+					halbtc8723b2ant_ps_tdma(btcoexist,
+								NORMAL_EXEC,
+								true, 7);
+					coex_dm->ps_tdma_du_adj_type = 7;
+				} else if (coex_dm->cur_ps_tdma == 4) {
+					halbtc8723b2ant_ps_tdma(btcoexist,
+								NORMAL_EXEC,
+								true, 8);
+					coex_dm->ps_tdma_du_adj_type = 8;
+				}
+				if (coex_dm->cur_ps_tdma == 9) {
+					halbtc8723b2ant_ps_tdma(btcoexist,
+								NORMAL_EXEC,
+								true, 14);
+					coex_dm->ps_tdma_du_adj_type = 14;
+				} else if (coex_dm->cur_ps_tdma == 10) {
+					halbtc8723b2ant_ps_tdma(btcoexist,
+								NORMAL_EXEC,
+								true, 14);
+					coex_dm->ps_tdma_du_adj_type = 14;
+				} else if (coex_dm->cur_ps_tdma == 11) {
+					halbtc8723b2ant_ps_tdma(btcoexist,
+								NORMAL_EXEC,
+								true, 15);
+					coex_dm->ps_tdma_du_adj_type = 15;
+				} else if (coex_dm->cur_ps_tdma == 12) {
+					halbtc8723b2ant_ps_tdma(btcoexist,
+								NORMAL_EXEC,
+								true, 16);
+					coex_dm->ps_tdma_du_adj_type = 16;
+				}
+				if (result == -1) {
+					if (coex_dm->cur_ps_tdma == 5) {
+						halbtc8723b2ant_ps_tdma(
+								btcoexist,
+								NORMAL_EXEC,
+								true, 6);
+						coex_dm->ps_tdma_du_adj_type =
+									      6;
+					} else if (coex_dm->cur_ps_tdma == 6) {
+						halbtc8723b2ant_ps_tdma(
+								btcoexist,
+								NORMAL_EXEC,
+								true, 7);
+						coex_dm->ps_tdma_du_adj_type =
+									      7;
+					} else if (coex_dm->cur_ps_tdma == 7) {
+						halbtc8723b2ant_ps_tdma(
+								btcoexist,
+								NORMAL_EXEC,
+								true, 8);
+						coex_dm->ps_tdma_du_adj_type =
+									      8;
+					} else if (coex_dm->cur_ps_tdma == 13) {
+						halbtc8723b2ant_ps_tdma(
+								btcoexist,
+								NORMAL_EXEC,
+								true, 14);
+						coex_dm->ps_tdma_du_adj_type =
+									     14;
+					} else if (coex_dm->cur_ps_tdma == 14) {
+						halbtc8723b2ant_ps_tdma(
+								btcoexist,
+								NORMAL_EXEC,
+								true, 15);
+						coex_dm->ps_tdma_du_adj_type =
+									     15;
+					} else if (coex_dm->cur_ps_tdma == 15) {
+						halbtc8723b2ant_ps_tdma(
+								btcoexist,
+								NORMAL_EXEC,
+								true, 16);
+						coex_dm->ps_tdma_du_adj_type =
+									     16;
+					}
+				}  else if (result == 1) {
+					if (coex_dm->cur_ps_tdma == 8) {
+						halbtc8723b2ant_ps_tdma(
+								btcoexist,
+								NORMAL_EXEC,
+								true, 7);
+						coex_dm->ps_tdma_du_adj_type =
+									      7;
+					} else if (coex_dm->cur_ps_tdma == 7) {
+						halbtc8723b2ant_ps_tdma(
+								btcoexist,
+								NORMAL_EXEC,
+								true, 6);
+						coex_dm->ps_tdma_du_adj_type =
+									      6;
+					} else if (coex_dm->cur_ps_tdma == 6) {
+						halbtc8723b2ant_ps_tdma(
+								btcoexist,
+								NORMAL_EXEC,
+								true, 6);
+						coex_dm->ps_tdma_du_adj_type =
+									      6;
+					} else if (coex_dm->cur_ps_tdma == 16) {
+						halbtc8723b2ant_ps_tdma(
+								btcoexist,
+								NORMAL_EXEC,
+								true, 15);
+						coex_dm->ps_tdma_du_adj_type =
+									     15;
+					} else if (coex_dm->cur_ps_tdma == 15) {
+						halbtc8723b2ant_ps_tdma(
+								btcoexist,
+								NORMAL_EXEC,
+								true, 14);
+						coex_dm->ps_tdma_du_adj_type =
+									     14;
+					} else if (coex_dm->cur_ps_tdma == 14) {
+						halbtc8723b2ant_ps_tdma(
+								btcoexist,
+								NORMAL_EXEC,
+								true, 14);
+						coex_dm->ps_tdma_du_adj_type =
+									     14;
+					}
+				}
+			} else {
+				BTC_PRINT(BTC_MSG_ALGORITHM,
+					  ALGO_TRACE_FW_DETAIL,
+					  "[BTCoex], TxPause = 0\n");
+				if (coex_dm->cur_ps_tdma == 5) {
+					halbtc8723b2ant_ps_tdma(btcoexist,
+								NORMAL_EXEC,
+								true, 2);
+					coex_dm->ps_tdma_du_adj_type = 2;
+				} else if (coex_dm->cur_ps_tdma == 6) {
+					halbtc8723b2ant_ps_tdma(btcoexist,
+								NORMAL_EXEC,
+								true, 2);
+					coex_dm->ps_tdma_du_adj_type = 2;
+				} else if (coex_dm->cur_ps_tdma == 7) {
+					halbtc8723b2ant_ps_tdma(btcoexist,
+								NORMAL_EXEC,
+								true, 3);
+					coex_dm->ps_tdma_du_adj_type = 3;
+				} else if (coex_dm->cur_ps_tdma == 8) {
+					halbtc8723b2ant_ps_tdma(btcoexist,
+								NORMAL_EXEC,
+								true, 4);
+					coex_dm->ps_tdma_du_adj_type = 4;
+				}
+				if (coex_dm->cur_ps_tdma == 13) {
+					halbtc8723b2ant_ps_tdma(btcoexist,
+								NORMAL_EXEC,
+								true, 10);
+					coex_dm->ps_tdma_du_adj_type = 10;
+				} else if (coex_dm->cur_ps_tdma == 14) {
+					halbtc8723b2ant_ps_tdma(btcoexist,
+								NORMAL_EXEC,
+								true, 10);
+					coex_dm->ps_tdma_du_adj_type = 10;
+				} else if (coex_dm->cur_ps_tdma == 15) {
+					halbtc8723b2ant_ps_tdma(btcoexist,
+								NORMAL_EXEC,
+								true, 11);
+					coex_dm->ps_tdma_du_adj_type = 11;
+				} else if (coex_dm->cur_ps_tdma == 16) {
+					halbtc8723b2ant_ps_tdma(btcoexist,
+								NORMAL_EXEC,
+								true, 12);
+					coex_dm->ps_tdma_du_adj_type = 12;
+				}
+				if (result == -1) {
+					if (coex_dm->cur_ps_tdma == 1) {
+						halbtc8723b2ant_ps_tdma(
+								btcoexist,
+								NORMAL_EXEC,
+								true, 2);
+						coex_dm->ps_tdma_du_adj_type =
+									      2;
+					} else if (coex_dm->cur_ps_tdma == 2) {
+						halbtc8723b2ant_ps_tdma(
+								btcoexist,
+								NORMAL_EXEC,
+								true, 3);
+						coex_dm->ps_tdma_du_adj_type =
+									      3;
+					} else if (coex_dm->cur_ps_tdma == 3) {
+						halbtc8723b2ant_ps_tdma(
+								btcoexist,
+								NORMAL_EXEC,
+								true, 4);
+						coex_dm->ps_tdma_du_adj_type =
+									      4;
+					} else if (coex_dm->cur_ps_tdma == 9) {
+						halbtc8723b2ant_ps_tdma(
+								btcoexist,
+								NORMAL_EXEC,
+								true, 10);
+						coex_dm->ps_tdma_du_adj_type =
+									     10;
+					} else if (coex_dm->cur_ps_tdma == 10) {
+						halbtc8723b2ant_ps_tdma(
+								btcoexist,
+								NORMAL_EXEC,
+								true, 11);
+						coex_dm->ps_tdma_du_adj_type =
+									     11;
+					} else if (coex_dm->cur_ps_tdma == 11) {
+						halbtc8723b2ant_ps_tdma(
+								btcoexist,
+								NORMAL_EXEC,
+								true, 12);
+						coex_dm->ps_tdma_du_adj_type =
+									     12;
+					}
+				} else if (result == 1) {
+					if (coex_dm->cur_ps_tdma == 4) {
+						halbtc8723b2ant_ps_tdma(
+								btcoexist,
+								NORMAL_EXEC,
+								true, 3);
+						coex_dm->ps_tdma_du_adj_type =
+									      3;
+					} else if (coex_dm->cur_ps_tdma == 3) {
+						halbtc8723b2ant_ps_tdma(
+								btcoexist,
+								NORMAL_EXEC,
+								true, 2);
+						coex_dm->ps_tdma_du_adj_type =
+									      2;
+					} else if (coex_dm->cur_ps_tdma == 2) {
+						halbtc8723b2ant_ps_tdma(
+								btcoexist,
+								NORMAL_EXEC,
+								true, 2);
+						coex_dm->ps_tdma_du_adj_type =
+									      2;
+					} else if (coex_dm->cur_ps_tdma == 12) {
+						halbtc8723b2ant_ps_tdma(
+								btcoexist,
+								NORMAL_EXEC,
+								true, 11);
+						coex_dm->ps_tdma_du_adj_type =
+									     11;
+					} else if (coex_dm->cur_ps_tdma == 11) {
+						halbtc8723b2ant_ps_tdma(
+								btcoexist,
+								NORMAL_EXEC,
+								true, 10);
+						coex_dm->ps_tdma_du_adj_type =
+									     10;
+					} else if (coex_dm->cur_ps_tdma == 10) {
+						halbtc8723b2ant_ps_tdma(
+								btcoexist,
+								NORMAL_EXEC,
+								true, 10);
+						coex_dm->ps_tdma_du_adj_type =
+									     10;
+					}
+				}
+			}
+		} else if (max_interval == 3) {
+			if (tx_pause) {
+				BTC_PRINT(BTC_MSG_ALGORITHM,
+					  ALGO_TRACE_FW_DETAIL,
+					  "[BTCoex], TxPause = 1\n");
+				if (coex_dm->cur_ps_tdma == 1) {
+					halbtc8723b2ant_ps_tdma(btcoexist,
+								NORMAL_EXEC,
+								true, 7);
+					coex_dm->ps_tdma_du_adj_type = 7;
+				} else if (coex_dm->cur_ps_tdma == 2) {
+					halbtc8723b2ant_ps_tdma(btcoexist,
+								NORMAL_EXEC,
+								true, 7);
+					coex_dm->ps_tdma_du_adj_type = 7;
+				} else if (coex_dm->cur_ps_tdma == 3) {
+					halbtc8723b2ant_ps_tdma(btcoexist,
+								NORMAL_EXEC,
+								true, 7);
+					coex_dm->ps_tdma_du_adj_type = 7;
+				} else if (coex_dm->cur_ps_tdma == 4) {
+					halbtc8723b2ant_ps_tdma(btcoexist,
+								NORMAL_EXEC,
+								true, 8);
+					coex_dm->ps_tdma_du_adj_type = 8;
+				}
+				if (coex_dm->cur_ps_tdma == 9) {
+					halbtc8723b2ant_ps_tdma(btcoexist,
+								NORMAL_EXEC,
+								true, 15);
+					coex_dm->ps_tdma_du_adj_type = 15;
+				} else if (coex_dm->cur_ps_tdma == 10) {
+					halbtc8723b2ant_ps_tdma(btcoexist,
+								NORMAL_EXEC,
+								true, 15);
+					coex_dm->ps_tdma_du_adj_type = 15;
+				} else if (coex_dm->cur_ps_tdma == 11) {
+					halbtc8723b2ant_ps_tdma(btcoexist,
+								NORMAL_EXEC,
+								true, 15);
+					coex_dm->ps_tdma_du_adj_type = 15;
+				} else if (coex_dm->cur_ps_tdma == 12) {
+					halbtc8723b2ant_ps_tdma(btcoexist,
+								NORMAL_EXEC,
+								true, 16);
+					coex_dm->ps_tdma_du_adj_type = 16;
+				}
+				if (result == -1) {
+					if (coex_dm->cur_ps_tdma == 5) {
+						halbtc8723b2ant_ps_tdma(
+								btcoexist,
+								NORMAL_EXEC,
+								true, 7);
+						coex_dm->ps_tdma_du_adj_type =
+									      7;
+					} else if (coex_dm->cur_ps_tdma == 6) {
+						halbtc8723b2ant_ps_tdma(
+								btcoexist,
+								NORMAL_EXEC,
+								true, 7);
+						coex_dm->ps_tdma_du_adj_type =
+									      7;
+					} else if (coex_dm->cur_ps_tdma == 7) {
+						halbtc8723b2ant_ps_tdma(
+								btcoexist,
+								NORMAL_EXEC,
+								true, 8);
+						coex_dm->ps_tdma_du_adj_type =
+									      8;
+					} else if (coex_dm->cur_ps_tdma == 13) {
+						halbtc8723b2ant_ps_tdma(
+								btcoexist,
+								NORMAL_EXEC,
+								true, 15);
+						coex_dm->ps_tdma_du_adj_type =
+									     15;
+					} else if (coex_dm->cur_ps_tdma == 14) {
+						halbtc8723b2ant_ps_tdma(
+								btcoexist,
+								NORMAL_EXEC,
+								true, 15);
+						coex_dm->ps_tdma_du_adj_type =
+									     15;
+					} else if (coex_dm->cur_ps_tdma == 15) {
+						halbtc8723b2ant_ps_tdma(
+								btcoexist,
+								NORMAL_EXEC,
+								true, 16);
+						coex_dm->ps_tdma_du_adj_type =
+									     16;
+					}
+				}  else if (result == 1) {
+					if (coex_dm->cur_ps_tdma == 8) {
+						halbtc8723b2ant_ps_tdma(
+								btcoexist,
+								NORMAL_EXEC,
+								true, 7);
+						coex_dm->ps_tdma_du_adj_type =
+									      7;
+					} else if (coex_dm->cur_ps_tdma == 7) {
+						halbtc8723b2ant_ps_tdma(
+								btcoexist,
+								NORMAL_EXEC,
+								true, 7);
+						coex_dm->ps_tdma_du_adj_type =
+									      7;
+					} else if (coex_dm->cur_ps_tdma == 6) {
+						halbtc8723b2ant_ps_tdma(
+								btcoexist,
+								NORMAL_EXEC,
+								true, 7);
+						coex_dm->ps_tdma_du_adj_type =
+									      7;
+					} else if (coex_dm->cur_ps_tdma == 16) {
+						halbtc8723b2ant_ps_tdma(
+								btcoexist,
+								NORMAL_EXEC,
+								true, 15);
+						coex_dm->ps_tdma_du_adj_type =
+									     15;
+					} else if (coex_dm->cur_ps_tdma == 15) {
+						halbtc8723b2ant_ps_tdma(
+								btcoexist,
+								NORMAL_EXEC,
+								true, 15);
+						coex_dm->ps_tdma_du_adj_type =
+									     15;
+					} else if (coex_dm->cur_ps_tdma == 14) {
+						halbtc8723b2ant_ps_tdma(
+								btcoexist,
+								NORMAL_EXEC,
+								true, 15);
+						coex_dm->ps_tdma_du_adj_type =
+									     15;
+					}
+				}
+			} else {
+				BTC_PRINT(BTC_MSG_ALGORITHM,
+					  ALGO_TRACE_FW_DETAIL,
+					  "[BTCoex], TxPause = 0\n");
+				if (coex_dm->cur_ps_tdma == 5) {
+					halbtc8723b2ant_ps_tdma(btcoexist,
+								NORMAL_EXEC,
+								true, 3);
+					coex_dm->ps_tdma_du_adj_type = 3;
+				} else if (coex_dm->cur_ps_tdma == 6) {
+					halbtc8723b2ant_ps_tdma(btcoexist,
+								NORMAL_EXEC,
+								true, 3);
+					coex_dm->ps_tdma_du_adj_type = 3;
+				} else if (coex_dm->cur_ps_tdma == 7) {
+					halbtc8723b2ant_ps_tdma(btcoexist,
+								NORMAL_EXEC,
+								true, 3);
+					coex_dm->ps_tdma_du_adj_type = 3;
+				} else if (coex_dm->cur_ps_tdma == 8) {
+					halbtc8723b2ant_ps_tdma(btcoexist,
+								NORMAL_EXEC,
+								true, 4);
+					coex_dm->ps_tdma_du_adj_type = 4;
+				}
+				if (coex_dm->cur_ps_tdma == 13) {
+					halbtc8723b2ant_ps_tdma(btcoexist,
+								NORMAL_EXEC,
+								true, 11);
+					coex_dm->ps_tdma_du_adj_type = 11;
+				} else if (coex_dm->cur_ps_tdma == 14) {
+					halbtc8723b2ant_ps_tdma(btcoexist,
+								NORMAL_EXEC,
+								true, 11);
+					coex_dm->ps_tdma_du_adj_type = 11;
+				} else if (coex_dm->cur_ps_tdma == 15) {
+					halbtc8723b2ant_ps_tdma(btcoexist,
+								NORMAL_EXEC,
+								true, 11);
+					coex_dm->ps_tdma_du_adj_type = 11;
+				} else if (coex_dm->cur_ps_tdma == 16) {
+					halbtc8723b2ant_ps_tdma(btcoexist,
+								NORMAL_EXEC,
+								true, 12);
+					coex_dm->ps_tdma_du_adj_type = 12;
+				}
+				if (result == -1) {
+					if (coex_dm->cur_ps_tdma == 1) {
+						halbtc8723b2ant_ps_tdma(
+								btcoexist,
+								NORMAL_EXEC,
+								true, 3);
+						coex_dm->ps_tdma_du_adj_type =
+									      3;
+					} else if (coex_dm->cur_ps_tdma == 2) {
+						halbtc8723b2ant_ps_tdma(
+								btcoexist,
+								NORMAL_EXEC,
+								true, 3);
+						coex_dm->ps_tdma_du_adj_type =
+									      3;
+					} else if (coex_dm->cur_ps_tdma == 3) {
+						halbtc8723b2ant_ps_tdma(
+								btcoexist,
+								NORMAL_EXEC,
+								true, 4);
+						coex_dm->ps_tdma_du_adj_type =
+									      4;
+					} else if (coex_dm->cur_ps_tdma == 9) {
+						halbtc8723b2ant_ps_tdma(
+								btcoexist,
+								NORMAL_EXEC,
+								true, 11);
+						coex_dm->ps_tdma_du_adj_type =
+									     11;
+					} else if (coex_dm->cur_ps_tdma == 10) {
+						halbtc8723b2ant_ps_tdma(
+								btcoexist,
+								NORMAL_EXEC,
+								true, 11);
+						coex_dm->ps_tdma_du_adj_type =
+									     11;
+					} else if (coex_dm->cur_ps_tdma == 11) {
+						halbtc8723b2ant_ps_tdma(
+								btcoexist,
+								NORMAL_EXEC,
+								true, 12);
+						coex_dm->ps_tdma_du_adj_type =
+									     12;
+					}
+				} else if (result == 1) {
+					if (coex_dm->cur_ps_tdma == 4) {
+						halbtc8723b2ant_ps_tdma(
+								btcoexist,
+								NORMAL_EXEC,
+								true, 3);
+						coex_dm->ps_tdma_du_adj_type =
+									      3;
+					} else if (coex_dm->cur_ps_tdma == 3) {
+						halbtc8723b2ant_ps_tdma(
+								btcoexist,
+								NORMAL_EXEC,
+								true, 3);
+						coex_dm->ps_tdma_du_adj_type =
+									      3;
+					} else if (coex_dm->cur_ps_tdma == 2) {
+						halbtc8723b2ant_ps_tdma(
+								btcoexist,
+								NORMAL_EXEC,
+								true, 3);
+						coex_dm->ps_tdma_du_adj_type =
+									      3;
+					} else if (coex_dm->cur_ps_tdma == 12) {
+						halbtc8723b2ant_ps_tdma(
+								btcoexist,
+								NORMAL_EXEC,
+								true, 11);
+						coex_dm->ps_tdma_du_adj_type =
+									     11;
+					} else if (coex_dm->cur_ps_tdma == 11) {
+						halbtc8723b2ant_ps_tdma(
+								btcoexist,
+								NORMAL_EXEC,
+								true, 11);
+						coex_dm->ps_tdma_du_adj_type =
+									     11;
+					} else if (coex_dm->cur_ps_tdma == 10) {
+						halbtc8723b2ant_ps_tdma(
+								btcoexist,
+								NORMAL_EXEC,
+								true, 11);
+						coex_dm->ps_tdma_du_adj_type =
+									     11;
+					}
+				}
+			}
+		}
+	}
+
+	/*if current PsTdma not match with the recorded one (when scan, dhcp..),
+	 *then we have to adjust it back to the previous record one.*/
+	if (coex_dm->cur_ps_tdma != coex_dm->ps_tdma_du_adj_type) {
+		bool scan = false, link = false, roam = false;
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_DETAIL,
+			  "[BTCoex], PsTdma type dismatch!!!, curPsTdma =%d, recordPsTdma =%d\n",
+			  coex_dm->cur_ps_tdma, coex_dm->ps_tdma_du_adj_type);
+
+		btcoexist->btc_get(btcoexist, BTC_GET_BL_WIFI_SCAN, &scan);
+		btcoexist->btc_get(btcoexist, BTC_GET_BL_WIFI_LINK, &link);
+		btcoexist->btc_get(btcoexist, BTC_GET_BL_WIFI_ROAM, &roam);
+
+		if (!scan && !link && !roam)
+			halbtc8723b2ant_ps_tdma(btcoexist, NORMAL_EXEC, true,
+						coex_dm->ps_tdma_du_adj_type);
+		else
+			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_DETAIL,
+				  "[BTCoex], roaming/link/scan is under progress, will adjust next time!!!\n");
+	}
+}
+
+/* SCO only or SCO+PAN(HS) */
+static void halbtc8723b2ant_action_sco(struct btc_coexist *btcoexist)
+{
+	u8 wifi_rssi_state;
+	u32 wifi_bw;
+
+	wifi_rssi_state = halbtc8723b2ant_wifi_rssi_state(btcoexist,
+							  0, 2, 15, 0);
+
+	btcoexist->btc_set_rf_reg(btcoexist, BTC_RF_A, 0x1, 0xfffff, 0x0);
+
+	halbtc8723b2ant_fw_dac_swing_lvl(btcoexist, NORMAL_EXEC, 4);
+
+	if (halbtc8723b2ant_need_to_dec_bt_pwr(btcoexist))
+		halbtc8723b2ant_dec_bt_pwr(btcoexist, NORMAL_EXEC, true);
+	else
+		halbtc8723b2ant_dec_bt_pwr(btcoexist, NORMAL_EXEC, false);
+
+	btcoexist->btc_get(btcoexist, BTC_GET_U4_WIFI_BW, &wifi_bw);
+
+	/*for SCO quality at 11b/g mode*/
+	if (BTC_WIFI_BW_LEGACY == wifi_bw)
+		coex_table_with_type(btcoexist, NORMAL_EXEC, 2);
+	else  /*for SCO quality & wifi performance balance at 11n mode*/
+		coex_table_with_type(btcoexist, NORMAL_EXEC, 8);
+
+	/*for voice quality */
+	halbtc8723b2ant_ps_tdma(btcoexist, NORMAL_EXEC, false, 0);
+
+	/* sw mechanism */
+	if (BTC_WIFI_BW_HT40 == wifi_bw) {
+		if ((wifi_rssi_state == BTC_RSSI_STATE_HIGH) ||
+		    (wifi_rssi_state == BTC_RSSI_STATE_STAY_HIGH)) {
+			halbtc8723b2ant_sw_mechanism1(btcoexist, true, true,
+						      false, false);
+			halbtc8723b2ant_sw_mechanism2(btcoexist, true, false,
+						      true, 0x4);
+		} else {
+			halbtc8723b2ant_sw_mechanism1(btcoexist, true, true,
+						      false, false);
+			halbtc8723b2ant_sw_mechanism2(btcoexist, false, false,
+						      true, 0x4);
+		}
+	} else {
+		if ((wifi_rssi_state == BTC_RSSI_STATE_HIGH) ||
+		    (wifi_rssi_state == BTC_RSSI_STATE_STAY_HIGH)) {
+			halbtc8723b2ant_sw_mechanism1(btcoexist, false, true,
+						      false, false);
+			halbtc8723b2ant_sw_mechanism2(btcoexist, true, false,
+						      true, 0x4);
+		} else {
+			halbtc8723b2ant_sw_mechanism1(btcoexist, false, true,
+						      false, false);
+			halbtc8723b2ant_sw_mechanism2(btcoexist, false, false,
+						      true, 0x4);
+		}
+	}
+}
+
+static void halbtc8723b2ant_action_hid(struct btc_coexist *btcoexist)
+{
+	u8 wifi_rssi_state, bt_rssi_state;
+	u32 wifi_bw;
+
+	wifi_rssi_state = halbtc8723b2ant_wifi_rssi_state(btcoexist,
+							  0, 2, 15, 0);
+	bt_rssi_state = halbtc8723b2ant_bt_rssi_state(2, 29, 0);
+
+	btcoexist->btc_set_rf_reg(btcoexist, BTC_RF_A, 0x1, 0xfffff, 0x0);
+
+	halbtc8723b2ant_fw_dac_swing_lvl(btcoexist, NORMAL_EXEC, 6);
+
+	if (halbtc8723b2ant_need_to_dec_bt_pwr(btcoexist))
+		halbtc8723b2ant_dec_bt_pwr(btcoexist, NORMAL_EXEC, true);
+	else
+		halbtc8723b2ant_dec_bt_pwr(btcoexist, NORMAL_EXEC, false);
+
+	btcoexist->btc_get(btcoexist, BTC_GET_U4_WIFI_BW, &wifi_bw);
+
+	if (BTC_WIFI_BW_LEGACY == wifi_bw) /*/for HID at 11b/g mode*/
+		coex_table_with_type(btcoexist, NORMAL_EXEC, 7);
+	else  /*for HID quality & wifi performance balance at 11n mode*/
+		coex_table_with_type(btcoexist, NORMAL_EXEC, 9);
+
+	if ((bt_rssi_state == BTC_RSSI_STATE_HIGH) ||
+	    (bt_rssi_state == BTC_RSSI_STATE_STAY_HIGH))
+		halbtc8723b2ant_ps_tdma(btcoexist, NORMAL_EXEC, true, 9);
+	else
+		halbtc8723b2ant_ps_tdma(btcoexist, NORMAL_EXEC, true, 13);
+
+	/* sw mechanism */
+	if (BTC_WIFI_BW_HT40 == wifi_bw) {
+		if ((wifi_rssi_state == BTC_RSSI_STATE_HIGH) ||
+		    (wifi_rssi_state == BTC_RSSI_STATE_STAY_HIGH)) {
+			halbtc8723b2ant_sw_mechanism1(btcoexist, true, true,
+						      false, false);
+			halbtc8723b2ant_sw_mechanism2(btcoexist, true, false,
+						      false, 0x18);
+		} else {
+			halbtc8723b2ant_sw_mechanism1(btcoexist, true, true,
+						      false, false);
+			halbtc8723b2ant_sw_mechanism2(btcoexist, false, false,
+						      false, 0x18);
+		}
+	} else {
+		if ((wifi_rssi_state == BTC_RSSI_STATE_HIGH) ||
+		    (wifi_rssi_state == BTC_RSSI_STATE_STAY_HIGH)) {
+			halbtc8723b2ant_sw_mechanism1(btcoexist, false, true,
+						      false, false);
+			halbtc8723b2ant_sw_mechanism2(btcoexist, true, false,
+						      false, 0x18);
+		} else {
+			halbtc8723b2ant_sw_mechanism1(btcoexist, false, true,
+						      false, false);
+			halbtc8723b2ant_sw_mechanism2(btcoexist, false, false,
+						      false, 0x18);
+		}
+	}
+}
+
+/*A2DP only / PAN(EDR) only/ A2DP+PAN(HS)*/
+static void halbtc8723b2ant_action_a2dp(struct btc_coexist *btcoexist)
+{
+	u8 wifi_rssi_state, wifi_rssi_state1, bt_rssi_state;
+	u32 wifi_bw;
+	u8 ap_num = 0;
+
+	wifi_rssi_state = halbtc8723b2ant_wifi_rssi_state(btcoexist,
+							  0, 2, 15, 0);
+	wifi_rssi_state1 = halbtc8723b2ant_wifi_rssi_state(btcoexist,
+							   1, 2, 40, 0);
+	bt_rssi_state = halbtc8723b2ant_bt_rssi_state(2, 29, 0);
+
+	btcoexist->btc_get(btcoexist, BTC_GET_U1_AP_NUM, &ap_num);
+
+	/* define the office environment */
+	/* driver don't know AP num in Linux, so we will never enter this if */
+	if (ap_num >= 10 && BTC_RSSI_HIGH(wifi_rssi_state1)) {
+		btcoexist->btc_set_rf_reg(btcoexist, BTC_RF_A, 0x1, 0xfffff,
+					  0x0);
+		halbtc8723b2ant_fw_dac_swing_lvl(btcoexist, NORMAL_EXEC, 6);
+		halbtc8723b2ant_dec_bt_pwr(btcoexist, NORMAL_EXEC, false);
+		coex_table_with_type(btcoexist, NORMAL_EXEC, 0);
+		halbtc8723b2ant_ps_tdma(btcoexist, NORMAL_EXEC, false, 1);
+
+		/* sw mechanism */
+		btcoexist->btc_get(btcoexist, BTC_GET_U4_WIFI_BW, &wifi_bw);
+		if (BTC_WIFI_BW_HT40 == wifi_bw) {
+			halbtc8723b2ant_sw_mechanism1(btcoexist, true, false,
+						      false, false);
+			halbtc8723b2ant_sw_mechanism2(btcoexist, true, false,
+						      true, 0x18);
+		} else {
+			halbtc8723b2ant_sw_mechanism1(btcoexist, false, false,
+						      false, false);
+			halbtc8723b2ant_sw_mechanism2(btcoexist, true, false,
+						      true, 0x18);
+		}
+		return;
+	}
+
+	btcoexist->btc_set_rf_reg(btcoexist, BTC_RF_A, 0x1, 0xfffff, 0x0);
+
+	halbtc8723b2ant_fw_dac_swing_lvl(btcoexist, NORMAL_EXEC, 6);
+
+	if (halbtc8723b2ant_need_to_dec_bt_pwr(btcoexist))
+		halbtc8723b2ant_dec_bt_pwr(btcoexist, NORMAL_EXEC, true);
+	else
+		halbtc8723b2ant_dec_bt_pwr(btcoexist, NORMAL_EXEC, false);
+
+	coex_table_with_type(btcoexist, NORMAL_EXEC, 7);
+
+	if ((bt_rssi_state == BTC_RSSI_STATE_HIGH) ||
+	    (bt_rssi_state == BTC_RSSI_STATE_STAY_HIGH))
+		halbtc8723b2ant_tdma_duration_adjust(btcoexist, false, false, 1);
+	else
+		halbtc8723b2ant_tdma_duration_adjust(btcoexist, false, true, 1);
+
+	/* sw mechanism */
+	btcoexist->btc_get(btcoexist, BTC_GET_U4_WIFI_BW, &wifi_bw);
+	if (BTC_WIFI_BW_HT40 == wifi_bw) {
+		if ((wifi_rssi_state == BTC_RSSI_STATE_HIGH) ||
+		    (wifi_rssi_state == BTC_RSSI_STATE_STAY_HIGH)) {
+			halbtc8723b2ant_sw_mechanism1(btcoexist, true, false,
+						      false, false);
+			halbtc8723b2ant_sw_mechanism2(btcoexist, true, false,
+						      false, 0x18);
+		} else {
+			halbtc8723b2ant_sw_mechanism1(btcoexist, true, false,
+						      false, false);
+			halbtc8723b2ant_sw_mechanism2(btcoexist, false, false,
+						      false, 0x18);
+		}
+	} else {
+		if ((wifi_rssi_state == BTC_RSSI_STATE_HIGH) ||
+		    (wifi_rssi_state == BTC_RSSI_STATE_STAY_HIGH)) {
+			halbtc8723b2ant_sw_mechanism1(btcoexist, false, false,
+						      false, false);
+			halbtc8723b2ant_sw_mechanism2(btcoexist, true, false,
+						      false, 0x18);
+		} else {
+			halbtc8723b2ant_sw_mechanism1(btcoexist, false, false,
+						      false, false);
+			halbtc8723b2ant_sw_mechanism2(btcoexist, false, false,
+						      false, 0x18);
+		}
+	}
+}
+
+static void halbtc8723b2ant_action_a2dp_pan_hs(struct btc_coexist *btcoexist)
+{
+	u8 wifi_rssi_state;
+	u32 wifi_bw;
+
+	wifi_rssi_state = halbtc8723b2ant_wifi_rssi_state(btcoexist,
+							  0, 2, 15, 0);
+
+	btcoexist->btc_set_rf_reg(btcoexist, BTC_RF_A, 0x1, 0xfffff, 0x0);
+
+	halbtc8723b2ant_fw_dac_swing_lvl(btcoexist, NORMAL_EXEC, 6);
+
+	if (halbtc8723b2ant_need_to_dec_bt_pwr(btcoexist))
+		halbtc8723b2ant_dec_bt_pwr(btcoexist, NORMAL_EXEC, true);
+	else
+		halbtc8723b2ant_dec_bt_pwr(btcoexist, NORMAL_EXEC, false);
+
+	coex_table_with_type(btcoexist, NORMAL_EXEC, 7);
+
+	halbtc8723b2ant_tdma_duration_adjust(btcoexist, false, true, 2);
+
+	/* sw mechanism */
+	btcoexist->btc_get(btcoexist,
+		BTC_GET_U4_WIFI_BW, &wifi_bw);
+	if (BTC_WIFI_BW_HT40 == wifi_bw) {
+		if ((wifi_rssi_state == BTC_RSSI_STATE_HIGH) ||
+		    (wifi_rssi_state == BTC_RSSI_STATE_STAY_HIGH)) {
+			halbtc8723b2ant_sw_mechanism1(btcoexist, true, false,
+						      false, false);
+			halbtc8723b2ant_sw_mechanism2(btcoexist, true, false,
+						      false, 0x18);
+		} else {
+			halbtc8723b2ant_sw_mechanism1(btcoexist, true, false,
+						      false, false);
+			halbtc8723b2ant_sw_mechanism2(btcoexist, false, false,
+						      false, 0x18);
+		}
+	} else {
+		if ((wifi_rssi_state == BTC_RSSI_STATE_HIGH) ||
+		    (wifi_rssi_state == BTC_RSSI_STATE_STAY_HIGH)) {
+			halbtc8723b2ant_sw_mechanism1(btcoexist, false, false,
+						      false, false);
+			halbtc8723b2ant_sw_mechanism2(btcoexist, true, false,
+						      false, 0x18);
+		} else {
+			halbtc8723b2ant_sw_mechanism1(btcoexist, false, false,
+						      false, false);
+			halbtc8723b2ant_sw_mechanism2(btcoexist, false, false,
+						      false, 0x18);
+		}
+	}
+}
+
+static void halbtc8723b2ant_action_pan_edr(struct btc_coexist *btcoexist)
+{
+	u8 wifi_rssi_state, bt_rssi_state;
+	u32 wifi_bw;
+
+	wifi_rssi_state = halbtc8723b2ant_wifi_rssi_state(btcoexist,
+							  0, 2, 15, 0);
+	bt_rssi_state = halbtc8723b2ant_bt_rssi_state(2, 29, 0);
+
+	btcoexist->btc_set_rf_reg(btcoexist, BTC_RF_A, 0x1, 0xfffff, 0x0);
+
+	halbtc8723b2ant_fw_dac_swing_lvl(btcoexist, NORMAL_EXEC, 6);
+
+	if (halbtc8723b2ant_need_to_dec_bt_pwr(btcoexist))
+		halbtc8723b2ant_dec_bt_pwr(btcoexist, NORMAL_EXEC, true);
+	else
+		halbtc8723b2ant_dec_bt_pwr(btcoexist, NORMAL_EXEC, false);
+
+	coex_table_with_type(btcoexist, NORMAL_EXEC, 10);
+
+	if ((bt_rssi_state == BTC_RSSI_STATE_HIGH) ||
+	    (bt_rssi_state == BTC_RSSI_STATE_STAY_HIGH))
+		halbtc8723b2ant_ps_tdma(btcoexist, NORMAL_EXEC, true, 1);
+	else
+		halbtc8723b2ant_ps_tdma(btcoexist, NORMAL_EXEC, true, 5);
+
+	/* sw mechanism */
+	btcoexist->btc_get(btcoexist, BTC_GET_U4_WIFI_BW, &wifi_bw);
+	if (BTC_WIFI_BW_HT40 == wifi_bw) {
+		if ((wifi_rssi_state == BTC_RSSI_STATE_HIGH) ||
+		    (wifi_rssi_state == BTC_RSSI_STATE_STAY_HIGH)) {
+			halbtc8723b2ant_sw_mechanism1(btcoexist, true, false,
+						      false, false);
+			halbtc8723b2ant_sw_mechanism2(btcoexist, true, false,
+						      false, 0x18);
+		} else {
+			halbtc8723b2ant_sw_mechanism1(btcoexist, true, false,
+						      false, false);
+			halbtc8723b2ant_sw_mechanism2(btcoexist, false, false,
+						      false, 0x18);
+		}
+	} else {
+		if ((wifi_rssi_state == BTC_RSSI_STATE_HIGH) ||
+		    (wifi_rssi_state == BTC_RSSI_STATE_STAY_HIGH)) {
+			halbtc8723b2ant_sw_mechanism1(btcoexist, false, false,
+						      false, false);
+			halbtc8723b2ant_sw_mechanism2(btcoexist, true, false,
+						      false, 0x18);
+		} else {
+			halbtc8723b2ant_sw_mechanism1(btcoexist, false, false,
+						      false, false);
+			halbtc8723b2ant_sw_mechanism2(btcoexist, false, false,
+						      false, 0x18);
+		}
+	}
+}
+
+/*PAN(HS) only*/
+static void halbtc8723b2ant_action_pan_hs(struct btc_coexist *btcoexist)
+{
+	u8 wifi_rssi_state;
+	u32 wifi_bw;
+
+	wifi_rssi_state = halbtc8723b2ant_wifi_rssi_state(btcoexist,
+							  0, 2, 15, 0);
+
+	btcoexist->btc_set_rf_reg(btcoexist, BTC_RF_A, 0x1, 0xfffff, 0x0);
+
+	halbtc8723b2ant_fw_dac_swing_lvl(btcoexist, NORMAL_EXEC, 6);
+
+	if ((wifi_rssi_state == BTC_RSSI_STATE_HIGH) ||
+	    (wifi_rssi_state == BTC_RSSI_STATE_STAY_HIGH))
+		halbtc8723b2ant_dec_bt_pwr(btcoexist, NORMAL_EXEC, true);
+	else
+		halbtc8723b2ant_dec_bt_pwr(btcoexist, NORMAL_EXEC, false);
+
+	coex_table_with_type(btcoexist, NORMAL_EXEC, 7);
+
+	halbtc8723b2ant_ps_tdma(btcoexist, NORMAL_EXEC, false, 1);
+
+	btcoexist->btc_get(btcoexist, BTC_GET_U4_WIFI_BW, &wifi_bw);
+	if (BTC_WIFI_BW_HT40 == wifi_bw) {
+		if ((wifi_rssi_state == BTC_RSSI_STATE_HIGH) ||
+		    (wifi_rssi_state == BTC_RSSI_STATE_STAY_HIGH)) {
+			halbtc8723b2ant_sw_mechanism1(btcoexist, true, false,
+						      false, false);
+			halbtc8723b2ant_sw_mechanism2(btcoexist, true, false,
+						      false, 0x18);
+		} else {
+			halbtc8723b2ant_sw_mechanism1(btcoexist, true, false,
+						      false, false);
+			halbtc8723b2ant_sw_mechanism2(btcoexist, false, false,
+						      false, 0x18);
+		}
+	} else {
+		if ((wifi_rssi_state == BTC_RSSI_STATE_HIGH) ||
+		    (wifi_rssi_state == BTC_RSSI_STATE_STAY_HIGH)) {
+			halbtc8723b2ant_sw_mechanism1(btcoexist, false, false,
+						      false, false);
+			halbtc8723b2ant_sw_mechanism2(btcoexist, true, false,
+						      false, 0x18);
+		} else {
+			halbtc8723b2ant_sw_mechanism1(btcoexist, false, false,
+						      false, false);
+			halbtc8723b2ant_sw_mechanism2(btcoexist, false, false,
+						      false, 0x18);
+		}
+	}
+}
+
+/*PAN(EDR)+A2DP*/
+static void halbtc8723b2ant_action_pan_edr_a2dp(struct btc_coexist *btcoexist)
+{
+	u8 wifi_rssi_state, bt_rssi_state;
+	u32 wifi_bw;
+
+	wifi_rssi_state = halbtc8723b2ant_wifi_rssi_state(btcoexist,
+							  0, 2, 15, 0);
+	bt_rssi_state = halbtc8723b2ant_bt_rssi_state(2, 29, 0);
+
+	btcoexist->btc_set_rf_reg(btcoexist, BTC_RF_A, 0x1, 0xfffff, 0x0);
+
+	halbtc8723b2ant_fw_dac_swing_lvl(btcoexist, NORMAL_EXEC, 6);
+
+	if (halbtc8723b2ant_need_to_dec_bt_pwr(btcoexist))
+		halbtc8723b2ant_dec_bt_pwr(btcoexist, NORMAL_EXEC, true);
+	else
+		halbtc8723b2ant_dec_bt_pwr(btcoexist, NORMAL_EXEC, false);
+
+	btcoexist->btc_get(btcoexist, BTC_GET_U4_WIFI_BW, &wifi_bw);
+
+	if ((bt_rssi_state == BTC_RSSI_STATE_HIGH) ||
+	    (bt_rssi_state == BTC_RSSI_STATE_STAY_HIGH)) {
+		coex_table_with_type(btcoexist, NORMAL_EXEC, 12);
+		if (BTC_WIFI_BW_HT40 == wifi_bw)
+			halbtc8723b2ant_tdma_duration_adjust(btcoexist, false,
+							     true, 3);
+		else
+			halbtc8723b2ant_tdma_duration_adjust(btcoexist, false,
+							     false, 3);
+	} else {
+		coex_table_with_type(btcoexist, NORMAL_EXEC, 7);
+		halbtc8723b2ant_tdma_duration_adjust(btcoexist, false, true, 3);
+	}
+
+	/* sw mechanism	*/
+	if (BTC_WIFI_BW_HT40 == wifi_bw) {
+		if ((wifi_rssi_state == BTC_RSSI_STATE_HIGH) ||
+		    (wifi_rssi_state == BTC_RSSI_STATE_STAY_HIGH)) {
+			halbtc8723b2ant_sw_mechanism1(btcoexist, true, false,
+						      false, false);
+			halbtc8723b2ant_sw_mechanism2(btcoexist, true, false,
+						      false, 0x18);
+		} else {
+			halbtc8723b2ant_sw_mechanism1(btcoexist, true, false,
+						      false, false);
+			halbtc8723b2ant_sw_mechanism2(btcoexist, false, false,
+						      false, 0x18);
+		}
+	} else {
+		if ((wifi_rssi_state == BTC_RSSI_STATE_HIGH) ||
+		    (wifi_rssi_state == BTC_RSSI_STATE_STAY_HIGH)) {
+			halbtc8723b2ant_sw_mechanism1(btcoexist, false, false,
+						      false, false);
+			halbtc8723b2ant_sw_mechanism2(btcoexist, true, false,
+						      false, 0x18);
+		} else {
+			halbtc8723b2ant_sw_mechanism1(btcoexist, false, false,
+						      false, false);
+			halbtc8723b2ant_sw_mechanism2(btcoexist, false, false,
+						      false, 0x18);
+		}
+	}
+}
+
+static void halbtc8723b2ant_action_pan_edr_hid(struct btc_coexist *btcoexist)
+{
+	u8 wifi_rssi_state, bt_rssi_state;
+	u32 wifi_bw;
+
+	wifi_rssi_state = halbtc8723b2ant_wifi_rssi_state(btcoexist,
+							  0, 2, 15, 0);
+	bt_rssi_state = halbtc8723b2ant_bt_rssi_state(2, 29, 0);
+	btcoexist->btc_get(btcoexist, BTC_GET_U4_WIFI_BW, &wifi_bw);
+
+	if (halbtc8723b2ant_need_to_dec_bt_pwr(btcoexist))
+		halbtc8723b2ant_dec_bt_pwr(btcoexist, NORMAL_EXEC, true);
+	else
+		halbtc8723b2ant_dec_bt_pwr(btcoexist, NORMAL_EXEC, false);
+
+	if ((bt_rssi_state == BTC_RSSI_STATE_HIGH) ||
+	    (bt_rssi_state == BTC_RSSI_STATE_STAY_HIGH)) {
+		if (BTC_WIFI_BW_HT40 == wifi_bw) {
+			halbtc8723b2ant_fw_dac_swing_lvl(btcoexist, NORMAL_EXEC,
+							 3);
+			coex_table_with_type(btcoexist,
+							     NORMAL_EXEC, 11);
+			btcoexist->btc_set_rf_reg(btcoexist, BTC_RF_A, 0x1,
+						  0xfffff, 0x780);
+		} else {
+			halbtc8723b2ant_fw_dac_swing_lvl(btcoexist, NORMAL_EXEC,
+							 6);
+			coex_table_with_type(btcoexist,
+							     NORMAL_EXEC, 7);
+			btcoexist->btc_set_rf_reg(btcoexist, BTC_RF_A, 0x1,
+						  0xfffff, 0x0);
+		}
+		halbtc8723b2ant_tdma_duration_adjust(btcoexist, true, false, 2);
+	} else {
+		halbtc8723b2ant_fw_dac_swing_lvl(btcoexist, NORMAL_EXEC, 6);
+		coex_table_with_type(btcoexist, NORMAL_EXEC, 11);
+		btcoexist->btc_set_rf_reg(btcoexist, BTC_RF_A, 0x1, 0xfffff,
+					  0x0);
+		halbtc8723b2ant_tdma_duration_adjust(btcoexist, true, true, 2);
+	}
+
+	/* sw mechanism */
+	if (BTC_WIFI_BW_HT40 == wifi_bw) {
+		if ((wifi_rssi_state == BTC_RSSI_STATE_HIGH) ||
+		    (wifi_rssi_state == BTC_RSSI_STATE_STAY_HIGH)) {
+			halbtc8723b2ant_sw_mechanism1(btcoexist, true, true,
+						      false, false);
+			halbtc8723b2ant_sw_mechanism2(btcoexist, true, false,
+						      false, 0x18);
+		} else {
+			halbtc8723b2ant_sw_mechanism1(btcoexist, true, true,
+						      false, false);
+			halbtc8723b2ant_sw_mechanism2(btcoexist, false, false,
+						      false, 0x18);
+		}
+	} else {
+		if ((wifi_rssi_state == BTC_RSSI_STATE_HIGH) ||
+		    (wifi_rssi_state == BTC_RSSI_STATE_STAY_HIGH)) {
+			halbtc8723b2ant_sw_mechanism1(btcoexist, false, true,
+						      false, false);
+			halbtc8723b2ant_sw_mechanism2(btcoexist, true, false,
+						      false, 0x18);
+		} else {
+			halbtc8723b2ant_sw_mechanism1(btcoexist, false, true,
+						      false, false);
+			halbtc8723b2ant_sw_mechanism2(btcoexist, false, false,
+						      false, 0x18);
+		}
+	}
+}
+
+/* HID+A2DP+PAN(EDR) */
+static void halbtc8723b2ant_action_hid_a2dp_pan_edr(struct btc_coexist *btcoexist)
+{
+	u8 wifi_rssi_state, bt_rssi_state;
+	u32 wifi_bw;
+
+	wifi_rssi_state = halbtc8723b2ant_wifi_rssi_state(btcoexist,
+							  0, 2, 15, 0);
+	bt_rssi_state = halbtc8723b2ant_bt_rssi_state(2, 29, 0);
+
+	btcoexist->btc_set_rf_reg(btcoexist, BTC_RF_A, 0x1, 0xfffff, 0x0);
+
+	halbtc8723b2ant_fw_dac_swing_lvl(btcoexist, NORMAL_EXEC, 6);
+
+	if (halbtc8723b2ant_need_to_dec_bt_pwr(btcoexist))
+		halbtc8723b2ant_dec_bt_pwr(btcoexist, NORMAL_EXEC, true);
+	else
+		halbtc8723b2ant_dec_bt_pwr(btcoexist, NORMAL_EXEC, false);
+
+	btcoexist->btc_get(btcoexist, BTC_GET_U4_WIFI_BW, &wifi_bw);
+
+	coex_table_with_type(btcoexist, NORMAL_EXEC, 7);
+
+	if ((bt_rssi_state == BTC_RSSI_STATE_HIGH) ||
+	    (bt_rssi_state == BTC_RSSI_STATE_STAY_HIGH)) {
+		if (BTC_WIFI_BW_HT40 == wifi_bw)
+			halbtc8723b2ant_tdma_duration_adjust(btcoexist, true,
+							     true, 2);
+		else
+			halbtc8723b2ant_tdma_duration_adjust(btcoexist, true,
+							     false, 3);
+	} else {
+		halbtc8723b2ant_tdma_duration_adjust(btcoexist, true, true, 3);
+	}
+
+	/* sw mechanism */
+	if (BTC_WIFI_BW_HT40 == wifi_bw) {
+		if ((wifi_rssi_state == BTC_RSSI_STATE_HIGH) ||
+		    (wifi_rssi_state == BTC_RSSI_STATE_STAY_HIGH)) {
+			halbtc8723b2ant_sw_mechanism1(btcoexist, true, true,
+						      false, false);
+			halbtc8723b2ant_sw_mechanism2(btcoexist, true, false,
+						      false, 0x18);
+		} else {
+			halbtc8723b2ant_sw_mechanism1(btcoexist, true, true,
+						      false, false);
+			halbtc8723b2ant_sw_mechanism2(btcoexist, false, false,
+						      false, 0x18);
+		}
+	} else {
+		if ((wifi_rssi_state == BTC_RSSI_STATE_HIGH) ||
+		    (wifi_rssi_state == BTC_RSSI_STATE_STAY_HIGH)) {
+			halbtc8723b2ant_sw_mechanism1(btcoexist, false, true,
+						      false, false);
+			halbtc8723b2ant_sw_mechanism2(btcoexist, true, false,
+						      false, 0x18);
+		} else {
+			halbtc8723b2ant_sw_mechanism1(btcoexist, false, true,
+						      false, false);
+			halbtc8723b2ant_sw_mechanism2(btcoexist, false, false,
+						      false, 0x18);
+		}
+	}
+}
+
+static void halbtc8723b2ant_action_hid_a2dp(struct btc_coexist *btcoexist)
+{
+	u8 wifi_rssi_state, bt_rssi_state;
+	u32 wifi_bw;
+
+	wifi_rssi_state = halbtc8723b2ant_wifi_rssi_state(btcoexist,
+							  0, 2, 15, 0);
+	bt_rssi_state = halbtc8723b2ant_bt_rssi_state(2, 29, 0);
+
+	btcoexist->btc_set_rf_reg(btcoexist, BTC_RF_A, 0x1, 0xfffff, 0x0);
+
+	halbtc8723b2ant_fw_dac_swing_lvl(btcoexist, NORMAL_EXEC, 6);
+
+	if (halbtc8723b2ant_need_to_dec_bt_pwr(btcoexist))
+		halbtc8723b2ant_dec_bt_pwr(btcoexist, NORMAL_EXEC, true);
+	else
+		halbtc8723b2ant_dec_bt_pwr(btcoexist, NORMAL_EXEC, false);
+
+	btcoexist->btc_get(btcoexist, BTC_GET_U4_WIFI_BW, &wifi_bw);
+
+	coex_table_with_type(btcoexist, NORMAL_EXEC, 7);
+
+	if ((bt_rssi_state == BTC_RSSI_STATE_HIGH) ||
+	    (bt_rssi_state == BTC_RSSI_STATE_STAY_HIGH))
+		halbtc8723b2ant_tdma_duration_adjust(btcoexist, true, false, 2);
+	else
+		halbtc8723b2ant_tdma_duration_adjust(btcoexist, true, true, 2);
+
+	/* sw mechanism */
+	if (BTC_WIFI_BW_HT40 == wifi_bw) {
+		if ((wifi_rssi_state == BTC_RSSI_STATE_HIGH) ||
+		    (wifi_rssi_state == BTC_RSSI_STATE_STAY_HIGH)) {
+			halbtc8723b2ant_sw_mechanism1(btcoexist, true, true,
+						      false, false);
+			halbtc8723b2ant_sw_mechanism2(btcoexist, true, false,
+						      false, 0x18);
+		} else {
+			halbtc8723b2ant_sw_mechanism1(btcoexist, true, true,
+						      false, false);
+			halbtc8723b2ant_sw_mechanism2(btcoexist, false, false,
+						      false, 0x18);
+		}
+	} else {
+		if ((wifi_rssi_state == BTC_RSSI_STATE_HIGH) ||
+		    (wifi_rssi_state == BTC_RSSI_STATE_STAY_HIGH)) {
+			halbtc8723b2ant_sw_mechanism1(btcoexist, false, true,
+						      false, false);
+			halbtc8723b2ant_sw_mechanism2(btcoexist, true, false,
+						      false, 0x18);
+		} else {
+			halbtc8723b2ant_sw_mechanism1(btcoexist, false, true,
+						      false, false);
+			halbtc8723b2ant_sw_mechanism2(btcoexist, false, false,
+						      false, 0x18);
+		}
+	}
+}
+
+static void halbtc8723b2ant_run_coexist_mechanism(struct btc_coexist *btcoexist)
+{
+	u8 algorithm = 0;
+
+	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+		  "[BTCoex], RunCoexistMechanism() ===>\n");
+
+	if (btcoexist->manual_control) {
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+			  "[BTCoex], RunCoexistMechanism(), return for Manual CTRL <===\n");
+		return;
+	}
+
+	if (coex_sta->under_ips) {
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+			  "[BTCoex], wifi is under IPS !!!\n");
+		return;
+	}
+
+	algorithm = halbtc8723b2ant_action_algorithm(btcoexist);
+	if (coex_sta->c2h_bt_inquiry_page &&
+	    (BT_8723B_2ANT_COEX_ALGO_PANHS != algorithm)) {
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+			  "[BTCoex], BT is under inquiry/page scan !!\n");
+		halbtc8723b2ant_action_bt_inquiry(btcoexist);
+		return;
+	} else {
+		if (coex_dm->need_recover_0x948) {
+			coex_dm->need_recover_0x948 = false;
+			btcoexist->btc_write_2byte(btcoexist, 0x948,
+						   coex_dm->backup_0x948);
+		}
+	}
+
+	coex_dm->cur_algorithm = algorithm;
+	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE, "[BTCoex], Algorithm = %d \n",
+		  coex_dm->cur_algorithm);
+
+	if (halbtc8723b2ant_is_common_action(btcoexist)) {
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+			  "[BTCoex], Action 2-Ant common.\n");
+		coex_dm->auto_tdma_adjust = false;
+	} else {
+		if (coex_dm->cur_algorithm != coex_dm->pre_algorithm) {
+			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+				  "[BTCoex], preAlgorithm =%d, curAlgorithm =%d\n", coex_dm->pre_algorithm,
+				  coex_dm->cur_algorithm);
+			coex_dm->auto_tdma_adjust = false;
+		}
+		switch (coex_dm->cur_algorithm) {
+		case BT_8723B_2ANT_COEX_ALGO_SCO:
+			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+				  "[BTCoex], Action 2-Ant, algorithm = SCO.\n");
+			halbtc8723b2ant_action_sco(btcoexist);
+			break;
+		case BT_8723B_2ANT_COEX_ALGO_HID:
+			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+				  "[BTCoex], Action 2-Ant, algorithm = HID.\n");
+			halbtc8723b2ant_action_hid(btcoexist);
+			break;
+		case BT_8723B_2ANT_COEX_ALGO_A2DP:
+			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+				  "[BTCoex], Action 2-Ant, algorithm = A2DP.\n");
+			halbtc8723b2ant_action_a2dp(btcoexist);
+			break;
+		case BT_8723B_2ANT_COEX_ALGO_A2DP_PANHS:
+			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+				  "[BTCoex], Action 2-Ant, algorithm = A2DP+PAN(HS).\n");
+			halbtc8723b2ant_action_a2dp_pan_hs(btcoexist);
+			break;
+		case BT_8723B_2ANT_COEX_ALGO_PANEDR:
+			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+				  "[BTCoex], Action 2-Ant, algorithm = PAN(EDR).\n");
+			halbtc8723b2ant_action_pan_edr(btcoexist);
+			break;
+		case BT_8723B_2ANT_COEX_ALGO_PANHS:
+			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+				  "[BTCoex], Action 2-Ant, algorithm = HS mode.\n");
+			halbtc8723b2ant_action_pan_hs(btcoexist);
+				break;
+		case BT_8723B_2ANT_COEX_ALGO_PANEDR_A2DP:
+			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+				  "[BTCoex], Action 2-Ant, algorithm = PAN+A2DP.\n");
+			halbtc8723b2ant_action_pan_edr_a2dp(btcoexist);
+			break;
+		case BT_8723B_2ANT_COEX_ALGO_PANEDR_HID:
+			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+				  "[BTCoex], Action 2-Ant, algorithm = PAN(EDR)+HID.\n");
+			halbtc8723b2ant_action_pan_edr_hid(btcoexist);
+			break;
+		case BT_8723B_2ANT_COEX_ALGO_HID_A2DP_PANEDR:
+			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+				  "[BTCoex], Action 2-Ant, algorithm = HID+A2DP+PAN.\n");
+			halbtc8723b2ant_action_hid_a2dp_pan_edr(btcoexist);
+			break;
+		case BT_8723B_2ANT_COEX_ALGO_HID_A2DP:
+			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+				  "[BTCoex], Action 2-Ant, algorithm = HID+A2DP.\n");
+			halbtc8723b2ant_action_hid_a2dp(btcoexist);
+			break;
+		default:
+			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+				  "[BTCoex], Action 2-Ant, algorithm = coexist All Off!!\n");
+			halbtc8723b2ant_coex_alloff(btcoexist);
+			break;
+		}
+		coex_dm->pre_algorithm = coex_dm->cur_algorithm;
+	}
+}
+
+static void halbtc8723b2ant_wifioff_hwcfg(struct btc_coexist *btcoexist)
+{
+	/* set wlan_act to low */
+	btcoexist->btc_write_1byte(btcoexist, 0x76e, 0x4);
+	/* Force GNT_BT to High */
+	btcoexist->btc_write_1byte_bitmask(btcoexist, 0x765, 0x18, 0x3);
+	/* BT select s0/s1 is controlled by BT */
+	btcoexist->btc_write_1byte_bitmask(btcoexist, 0x67, 0x20, 0x0);
+}
+
+/*********************************************************************
+ *  work around function start with wa_halbtc8723b2ant_
+ *********************************************************************/
+/*********************************************************************
+ *  extern function start with EXhalbtc8723b2ant_
+ *********************************************************************/
+void ex92e_halbtc8723b2ant_init_hwconfig(struct btc_coexist *btcoexist)
+{
+	u8 u8tmp = 0;
+
+	BTC_PRINT(BTC_MSG_INTERFACE, INTF_INIT,
+		  "[BTCoex], 2Ant Init HW Config!!\n");
+	coex_dm->bt_rf0x1e_backup =
+		btcoexist->btc_get_rf_reg(btcoexist, BTC_RF_A, 0x1e, 0xfffff);
+
+	/* 0x790[5:0] = 0x5 */
+	u8tmp = btcoexist->btc_read_1byte(btcoexist, 0x790);
+	u8tmp &= 0xc0;
+	u8tmp |= 0x5;
+	btcoexist->btc_write_1byte(btcoexist, 0x790, u8tmp);
+
+	/*Antenna config	*/
+	halbtc8723b2ant_set_ant_path(btcoexist, BTC_ANT_WIFI_AT_MAIN,
+				     true, false);
+
+
+
+	/* PTA parameter */
+	coex_table_with_type(btcoexist, FORCE_EXEC, 0);
+
+	/* Enable counter statistics */
+	/*0x76e[3] = 1, WLAN_Act control by PTA*/
+	btcoexist->btc_write_1byte(btcoexist, 0x76e, 0xc);
+	btcoexist->btc_write_1byte(btcoexist, 0x778, 0x3);
+	btcoexist->btc_write_1byte_bitmask(btcoexist, 0x40, 0x20, 0x1);
+}
+
+void ex92e_halbtc8723b2ant_init_coex_dm(struct btc_coexist *btcoexist)
+{
+	BTC_PRINT(BTC_MSG_INTERFACE, INTF_INIT,
+		  "[BTCoex], Coex Mechanism Init!!\n");
+	halbtc8723b2ant_init_coex_dm(btcoexist);
+}
+
+void ex_halbtc8723b2ant92e_display_coex_info(struct btc_coexist *btcoexist)
+{
+	struct btc_board_info *board_info = &btcoexist->board_info;
+	struct btc_stack_info *stack_info = &btcoexist->stack_info;
+	struct btc_bt_link_info *bt_link_info = &btcoexist->bt_link_info;
+	u8 *cli_buf = btcoexist->cli_buf;
+	u8 u8tmp[4], i, bt_info_ext, ps_tdma_case = 0;
+	u32 u32tmp[4];
+	bool roam = false, scan = false;
+	bool link = false, wifi_under_5g = false;
+	bool bt_hs_on = false, wifi_busy = false;
+	s32 wifi_rssi = 0, bt_hs_rssi = 0;
+	u32 wifi_bw, wifi_traffic_dir, fa_ofdm, fa_cck;
+	u8 wifi_dot11_chnl, wifi_hs_chnl;
+	u32 fw_ver = 0, bt_patch_ver = 0;
+	u8 ap_num = 0;
+
+	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE,
+		   "\r\n ============[BT Coexist info] ============");
+	CL_PRINTF(cli_buf);
+
+	if (btcoexist->manual_control) {
+		CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE,
+			   "\r\n ==========[Under Manual Control] ============");
+		CL_PRINTF(cli_buf);
+		CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE,
+			   "\r\n ==========================================");
+		CL_PRINTF(cli_buf);
+	}
+
+	if (!board_info->bt_exist) {
+		CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n BT not exists !!!");
+		CL_PRINTF(cli_buf);
+		return;
+	}
+
+	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = %d/ %d ",
+		   "Ant PG number/ Ant mechanism: ",
+		   board_info->pg_ant_num, board_info->btdm_ant_num);
+	CL_PRINTF(cli_buf);
+
+	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = %s / %d",
+		   "BT stack/ hci ext ver",
+		   ((stack_info->profile_notified) ? "Yes" : "No"),
+		   stack_info->hci_version);
+	CL_PRINTF(cli_buf);
+
+	btcoexist->btc_get(btcoexist, BTC_GET_U4_BT_PATCH_VER, &bt_patch_ver);
+	btcoexist->btc_get(btcoexist, BTC_GET_U4_WIFI_FW_VER, &fw_ver);
+	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE,
+		   "\r\n %-35s = %d_%x/ 0x%x/ 0x%x(%d)",
+		   "CoexVer/ fw_ver/ PatchVer",
+		   glcoex_ver_date_8723b_2ant, glcoex_ver_8723b_2ant,
+		   fw_ver, bt_patch_ver, bt_patch_ver);
+	CL_PRINTF(cli_buf);
+
+	btcoexist->btc_get(btcoexist, BTC_GET_BL_HS_OPERATION, &bt_hs_on);
+	btcoexist->btc_get(btcoexist, BTC_GET_U1_WIFI_DOT11_CHNL,
+			   &wifi_dot11_chnl);
+	btcoexist->btc_get(btcoexist, BTC_GET_U1_WIFI_HS_CHNL, &wifi_hs_chnl);
+
+	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = %d / %d(%d)",
+		   "Dot11 channel / HsChnl(HsMode)",
+		   wifi_dot11_chnl, wifi_hs_chnl, bt_hs_on);
+	CL_PRINTF(cli_buf);
+
+	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = %02x %02x %02x ",
+		   "H2C Wifi inform bt chnl Info", coex_dm->wifi_chnl_info[0],
+		   coex_dm->wifi_chnl_info[1], coex_dm->wifi_chnl_info[2]);
+	CL_PRINTF(cli_buf);
+
+	btcoexist->btc_get(btcoexist, BTC_GET_S4_WIFI_RSSI, &wifi_rssi);
+	btcoexist->btc_get(btcoexist, BTC_GET_S4_HS_RSSI, &bt_hs_rssi);
+	btcoexist->btc_get(btcoexist, BTC_GET_U1_AP_NUM, &ap_num);
+	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = %d/ %d/ %d",
+		   "Wifi rssi/ HS rssi/ AP#", wifi_rssi, bt_hs_rssi, ap_num);
+	CL_PRINTF(cli_buf);
+
+	btcoexist->btc_get(btcoexist, BTC_GET_BL_WIFI_SCAN, &scan);
+	btcoexist->btc_get(btcoexist, BTC_GET_BL_WIFI_LINK, &link);
+	btcoexist->btc_get(btcoexist, BTC_GET_BL_WIFI_ROAM, &roam);
+	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = %d/ %d/ %d ",
+		   "Wifi link/ roam/ scan", link, roam, scan);
+	CL_PRINTF(cli_buf);
+
+	btcoexist->btc_get(btcoexist, BTC_GET_BL_WIFI_UNDER_5G, &wifi_under_5g);
+	btcoexist->btc_get(btcoexist, BTC_GET_U4_WIFI_BW, &wifi_bw);
+	btcoexist->btc_get(btcoexist, BTC_GET_BL_WIFI_BUSY, &wifi_busy);
+	btcoexist->btc_get(btcoexist, BTC_GET_U4_WIFI_TRAFFIC_DIRECTION,
+			   &wifi_traffic_dir);
+	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = %s / %s/ %s ",
+		   "Wifi status", (wifi_under_5g ? "5G" : "2.4G"),
+		   ((BTC_WIFI_BW_LEGACY == wifi_bw) ? "Legacy" :
+		   (((BTC_WIFI_BW_HT40 == wifi_bw) ? "HT40" : "HT20"))),
+		   ((!wifi_busy) ? "idle" :
+		   ((BTC_WIFI_TRAFFIC_TX == wifi_traffic_dir) ?
+		   "uplink" : "downlink")));
+	CL_PRINTF(cli_buf);
+
+	CL_PRINTF(cli_buf);
+
+	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = %d / %d / %d / %d",
+		   "SCO/HID/PAN/A2DP",
+		   bt_link_info->sco_exist, bt_link_info->hid_exist,
+		   bt_link_info->pan_exist, bt_link_info->a2dp_exist);
+	CL_PRINTF(cli_buf);
+	btcoexist->btc_disp_dbg_msg(btcoexist, BTC_DBG_DISP_BT_LINK_INFO);
+
+	bt_info_ext = coex_sta->bt_info_ext;
+	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = %s",
+		   "BT Info A2DP rate",
+		   (bt_info_ext & BIT(0)) ? "Basic rate" : "EDR rate");
+	CL_PRINTF(cli_buf);
+
+	for (i = 0; i < BT_INFO_SRC_8723B_2ANT_MAX; i++) {
+		if (coex_sta->bt_info_c2h_cnt[i]) {
+			CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE,
+				   "\r\n %-35s = %02x %02x %02x %02x %02x %02x %02x(%d)",
+				   glbt_info_src_8723b_2ant[i],
+				   coex_sta->bt_info_c2h[i][0],
+				   coex_sta->bt_info_c2h[i][1],
+				   coex_sta->bt_info_c2h[i][2],
+				   coex_sta->bt_info_c2h[i][3],
+				   coex_sta->bt_info_c2h[i][4],
+				   coex_sta->bt_info_c2h[i][5],
+				   coex_sta->bt_info_c2h[i][6],
+				   coex_sta->bt_info_c2h_cnt[i]);
+			CL_PRINTF(cli_buf);
+		}
+	}
+
+	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = %s/%s",
+		   "PS state, IPS/LPS",
+		   ((coex_sta->under_ips ? "IPS ON" : "IPS OFF")),
+		   ((coex_sta->under_lps ? "LPS ON" : "LPS OFF")));
+	CL_PRINTF(cli_buf);
+	btcoexist->btc_disp_dbg_msg(btcoexist, BTC_DBG_DISP_FW_PWR_MODE_CMD);
+
+	/* Sw mechanism	*/
+	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE,
+		   "\r\n %-35s", "============[Sw mechanism] ============");
+	CL_PRINTF(cli_buf);
+	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = %d/ %d/ %d ",
+		   "SM1[ShRf/ LpRA/ LimDig]", coex_dm->cur_rf_rx_lpf_shrink,
+		   coex_dm->cur_low_penalty_ra, coex_dm->limited_dig);
+	CL_PRINTF(cli_buf);
+	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = %d/ %d/ %d(0x%x) ",
+		   "SM2[AgcT/ AdcB/ SwDacSwing(lvl)]",
+		   coex_dm->cur_agc_table_en, coex_dm->cur_adc_back_off,
+		   coex_dm->cur_dac_swing_on, coex_dm->cur_dac_swing_lvl);
+	CL_PRINTF(cli_buf);
+
+	/* Fw mechanism	*/
+	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s",
+		   "============[Fw mechanism] ============");
+	CL_PRINTF(cli_buf);
+
+	ps_tdma_case = coex_dm->cur_ps_tdma;
+	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE,
+		   "\r\n %-35s = %02x %02x %02x %02x %02x case-%d (auto:%d)",
+		   "PS TDMA", coex_dm->ps_tdma_para[0],
+		   coex_dm->ps_tdma_para[1], coex_dm->ps_tdma_para[2],
+		   coex_dm->ps_tdma_para[3], coex_dm->ps_tdma_para[4],
+		   ps_tdma_case, coex_dm->auto_tdma_adjust);
+	CL_PRINTF(cli_buf);
+
+	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = %d/ %d ",
+		   "DecBtPwr/ IgnWlanAct", coex_dm->cur_dec_bt_pwr,
+		   coex_dm->cur_ignore_wlan_act);
+	CL_PRINTF(cli_buf);
+
+	/* Hw setting */
+	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s",
+		   "============[Hw setting] ============");
+	CL_PRINTF(cli_buf);
+
+	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = 0x%x",
+		   "RF-A, 0x1e initVal", coex_dm->bt_rf0x1e_backup);
+	CL_PRINTF(cli_buf);
+
+	u8tmp[0] = btcoexist->btc_read_1byte(btcoexist, 0x778);
+	u32tmp[0] = btcoexist->btc_read_4byte(btcoexist, 0x880);
+	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = 0x%x/ 0x%x",
+		   "0x778/0x880[29:25]", u8tmp[0],
+		   (u32tmp[0]&0x3e000000) >> 25);
+	CL_PRINTF(cli_buf);
+
+	u32tmp[0] = btcoexist->btc_read_4byte(btcoexist, 0x948);
+	u8tmp[0] = btcoexist->btc_read_1byte(btcoexist, 0x67);
+	u8tmp[1] = btcoexist->btc_read_1byte(btcoexist, 0x765);
+	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = 0x%x/ 0x%x/ 0x%x",
+		   "0x948/ 0x67[5] / 0x765",
+		   u32tmp[0], ((u8tmp[0]&0x20) >> 5), u8tmp[1]);
+	CL_PRINTF(cli_buf);
+
+	u32tmp[0] = btcoexist->btc_read_4byte(btcoexist, 0x92c);
+	u32tmp[1] = btcoexist->btc_read_4byte(btcoexist, 0x930);
+	u32tmp[2] = btcoexist->btc_read_4byte(btcoexist, 0x944);
+	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = 0x%x/ 0x%x/ 0x%x",
+		   "0x92c[1:0]/ 0x930[7:0]/0x944[1:0]",
+		   u32tmp[0]&0x3, u32tmp[1]&0xff, u32tmp[2]&0x3);
+	CL_PRINTF(cli_buf);
+
+	u8tmp[0] = btcoexist->btc_read_1byte(btcoexist, 0x39);
+	u8tmp[1] = btcoexist->btc_read_1byte(btcoexist, 0x40);
+	u32tmp[0] = btcoexist->btc_read_4byte(btcoexist, 0x4c);
+	u8tmp[2] = btcoexist->btc_read_1byte(btcoexist, 0x64);
+	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = 0x%x/ 0x%x/ 0x%x/ 0x%x",
+		   "0x38[11]/0x40/0x4c[24:23]/0x64[0]",
+		   ((u8tmp[0] & 0x8)>>3), u8tmp[1],
+		   ((u32tmp[0]&0x01800000)>>23), u8tmp[2]&0x1);
+	CL_PRINTF(cli_buf);
+
+	u32tmp[0] = btcoexist->btc_read_4byte(btcoexist, 0x550);
+	u8tmp[0] = btcoexist->btc_read_1byte(btcoexist, 0x522);
+	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = 0x%x/ 0x%x",
+		   "0x550(bcn ctrl)/0x522", u32tmp[0], u8tmp[0]);
+	CL_PRINTF(cli_buf);
+
+	u32tmp[0] = btcoexist->btc_read_4byte(btcoexist, 0xc50);
+	u8tmp[0] = btcoexist->btc_read_1byte(btcoexist, 0x49c);
+	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = 0x%x/ 0x%x",
+		   "0xc50(dig)/0x49c(null-drop)", u32tmp[0]&0xff, u8tmp[0]);
+	CL_PRINTF(cli_buf);
+
+	u32tmp[0] = btcoexist->btc_read_4byte(btcoexist, 0xda0);
+	u32tmp[1] = btcoexist->btc_read_4byte(btcoexist, 0xda4);
+	u32tmp[2] = btcoexist->btc_read_4byte(btcoexist, 0xda8);
+	u32tmp[3] = btcoexist->btc_read_4byte(btcoexist, 0xcf0);
+
+	u8tmp[0] = btcoexist->btc_read_1byte(btcoexist, 0xa5b);
+	u8tmp[1] = btcoexist->btc_read_1byte(btcoexist, 0xa5c);
+
+	fa_ofdm = ((u32tmp[0]&0xffff0000) >> 16) +
+		  ((u32tmp[1]&0xffff0000) >> 16) +
+		   (u32tmp[1] & 0xffff) +
+		   (u32tmp[2] & 0xffff) +
+		  ((u32tmp[3]&0xffff0000) >> 16) +
+		   (u32tmp[3] & 0xffff);
+	fa_cck = (u8tmp[0] << 8) + u8tmp[1];
+
+	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = 0x%x/ 0x%x/ 0x%x",
+		   "OFDM-CCA/OFDM-FA/CCK-FA",
+		   u32tmp[0]&0xffff, fa_ofdm, fa_cck);
+	CL_PRINTF(cli_buf);
+
+	u32tmp[0] = btcoexist->btc_read_4byte(btcoexist, 0x6c0);
+	u32tmp[1] = btcoexist->btc_read_4byte(btcoexist, 0x6c4);
+	u32tmp[2] = btcoexist->btc_read_4byte(btcoexist, 0x6c8);
+	u8tmp[0] = btcoexist->btc_read_1byte(btcoexist, 0x6cc);
+	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE,
+		   "\r\n %-35s = 0x%x/ 0x%x/ 0x%x/ 0x%x",
+		   "0x6c0/0x6c4/0x6c8/0x6cc(coexTable)", \
+		   u32tmp[0], u32tmp[1], u32tmp[2], u8tmp[0]);
+	CL_PRINTF(cli_buf);
+
+	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = %d/ %d",
+		   "0x770(high-pri rx/tx)",
+		   coex_sta->high_priority_rx, coex_sta->high_priority_tx);
+	CL_PRINTF(cli_buf);
+	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\r\n %-35s = %d/ %d",
+		   "0x774(low-pri rx/tx)", coex_sta->low_priority_rx,
+		   coex_sta->low_priority_tx);
+	CL_PRINTF(cli_buf);
+#if (BT_AUTO_REPORT_ONLY_8723B_2ANT == 1)
+	halbtc8723b2ant_monitor_bt_ctr(btcoexist);
+#endif
+	btcoexist->btc_disp_dbg_msg(btcoexist,
+	BTC_DBG_DISP_COEX_STATISTICS);
+}
+
+void ex92e_halbtc8723b2ant_ips_notify(struct btc_coexist *btcoexist, u8 type)
+{
+	if (BTC_IPS_ENTER == type) {
+		BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
+			  "[BTCoex], IPS ENTER notify\n");
+		coex_sta->under_ips = true;
+		halbtc8723b2ant_wifioff_hwcfg(btcoexist);
+		halbtc8723b2ant_ignore_wlan_act(btcoexist, FORCE_EXEC, true);
+		halbtc8723b2ant_coex_alloff(btcoexist);
+	} else if (BTC_IPS_LEAVE == type) {
+		BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
+			  "[BTCoex], IPS LEAVE notify\n");
+		coex_sta->under_ips = false;
+		ex92e_halbtc8723b2ant_init_hwconfig(btcoexist);
+		halbtc8723b2ant_init_coex_dm(btcoexist);
+		halbtc8723b2ant_query_bt_info(btcoexist);
+	}
+}
+
+void ex92e_halbtc8723b2ant_lps_notify(struct btc_coexist *btcoexist, u8 type)
+{
+	if (BTC_LPS_ENABLE == type) {
+		BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
+			  "[BTCoex], LPS ENABLE notify\n");
+		coex_sta->under_lps = true;
+	} else if (BTC_LPS_DISABLE == type) {
+		BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
+			  "[BTCoex], LPS DISABLE notify\n");
+		coex_sta->under_lps = false;
+	}
+}
+
+void ex92e_halbtc8723b2ant_scan_notify(struct btc_coexist *btcoexist, u8 type)
+{
+	if (BTC_SCAN_START == type)
+		BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
+			  "[BTCoex], SCAN START notify\n");
+	else if (BTC_SCAN_FINISH == type)
+		BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
+			  "[BTCoex], SCAN FINISH notify\n");
+}
+
+void ex92e_halbtc8723b2ant_connect_notify(struct btc_coexist *btcoexist, u8 type)
+{
+	if (BTC_ASSOCIATE_START == type)
+		BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
+			  "[BTCoex], CONNECT START notify\n");
+	else if (BTC_ASSOCIATE_FINISH == type)
+		BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
+			  "[BTCoex], CONNECT FINISH notify\n");
+}
+
+void ex92e_halbtc8723b2ant_media_status_notify(struct btc_coexist *btcoexist,
+					    u8 type)
+{
+	u8 h2c_parameter[3] = {0};
+	u32 wifi_bw;
+	u8 wifi_central_chnl;
+
+	if (BTC_MEDIA_CONNECT == type)
+		BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
+			  "[BTCoex], MEDIA connect notify\n");
+	else
+		BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
+			  "[BTCoex], MEDIA disconnect notify\n");
+
+	/* only 2.4G we need to inform bt the chnl mask */
+	btcoexist->btc_get(btcoexist,
+		BTC_GET_U1_WIFI_CENTRAL_CHNL, &wifi_central_chnl);
+	if ((BTC_MEDIA_CONNECT == type) &&
+	    (wifi_central_chnl <= 14)) {
+		h2c_parameter[0] = 0x1;
+		h2c_parameter[1] = wifi_central_chnl;
+		btcoexist->btc_get(btcoexist,
+			BTC_GET_U4_WIFI_BW, &wifi_bw);
+		if (BTC_WIFI_BW_HT40 == wifi_bw)
+			h2c_parameter[2] = 0x30;
+		else
+			h2c_parameter[2] = 0x20;
+	}
+
+	coex_dm->wifi_chnl_info[0] = h2c_parameter[0];
+	coex_dm->wifi_chnl_info[1] = h2c_parameter[1];
+	coex_dm->wifi_chnl_info[2] = h2c_parameter[2];
+
+	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_EXEC,
+		  "[BTCoex], FW write 0x66 = 0x%x\n",
+		  h2c_parameter[0] << 16 | h2c_parameter[1] << 8 |
+		  h2c_parameter[2]);
+
+	btcoexist->btc_fill_h2c(btcoexist, 0x66, 3, h2c_parameter);
+}
+
+void ex92e_halbtc8723b2ant_special_packet_notify(struct btc_coexist *btcoexist,
+					      u8 type)
+{
+	if (type == BTC_PACKET_DHCP)
+		BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
+			  "[BTCoex], DHCP Packet notify\n");
+}
+
+void ex92e_halbtc8723b2ant_bt_info_notify(struct btc_coexist *btcoexist,
+				       u8 *tmpbuf, u8 length)
+{
+	u8 btInfo = 0;
+	u8 i, rsp_source = 0;
+	bool bt_busy = false, limited_dig = false;
+	bool wifi_connected = false;
+
+	coex_sta->c2h_bt_info_req_sent = false;
+
+	rsp_source = tmpbuf[0]&0xf;
+	if (rsp_source >= BT_INFO_SRC_8723B_2ANT_MAX)
+		rsp_source = BT_INFO_SRC_8723B_2ANT_WIFI_FW;
+	coex_sta->bt_info_c2h_cnt[rsp_source]++;
+
+	BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
+		  "[BTCoex], Bt info[%d], length =%d, hex data =[",
+		  rsp_source, length);
+	for (i = 0; i < length; i++) {
+		coex_sta->bt_info_c2h[rsp_source][i] = tmpbuf[i];
+		if (i == 1)
+			btInfo = tmpbuf[i];
+		if (i == length-1)
+			BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
+				  "0x%02x]\n", tmpbuf[i]);
+		else
+			BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
+				  "0x%02x, ", tmpbuf[i]);
+	}
+
+	if (btcoexist->manual_control) {
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+			  "[BTCoex], BtInfoNotify(), return for Manual CTRL<===\n");
+		return;
+	}
+
+	if (BT_INFO_SRC_8723B_2ANT_WIFI_FW != rsp_source) {
+		coex_sta->bt_retry_cnt =	/* [3:0]*/
+			coex_sta->bt_info_c2h[rsp_source][2] & 0xf;
+
+		coex_sta->bt_rssi =
+			coex_sta->bt_info_c2h[rsp_source][3] * 2 + 10;
+
+		coex_sta->bt_info_ext =
+			coex_sta->bt_info_c2h[rsp_source][4];
+
+		/* Here we need to resend some wifi info to BT
+		     because bt is reset and loss of the info.*/
+		if ((coex_sta->bt_info_ext & BIT(1))) {
+			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+				  "[BTCoex], BT ext info bit1 check, send wifi BW&Chnl to BT!!\n");
+			btcoexist->btc_get(btcoexist, BTC_GET_BL_WIFI_CONNECTED,
+					   &wifi_connected);
+			if (wifi_connected)
+				ex92e_halbtc8723b2ant_media_status_notify(
+							btcoexist,
+							BTC_MEDIA_CONNECT);
+			else
+				ex92e_halbtc8723b2ant_media_status_notify(
+							btcoexist,
+							BTC_MEDIA_DISCONNECT);
+		}
+
+		if ((coex_sta->bt_info_ext & BIT(3))) {
+			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+				  "[BTCoex], BT ext info bit3 check, set BT NOT to ignore Wlan active!!\n");
+			halbtc8723b2ant_ignore_wlan_act(btcoexist, FORCE_EXEC,
+							false);
+		} else {
+			/* BT already NOT ignore Wlan active, do nothing here.*/
+		}
+#if (BT_AUTO_REPORT_ONLY_8723B_2ANT == 0)
+		if ((coex_sta->bt_info_ext & BIT(4))) {
+			/* BT auto report already enabled, do nothing*/
+		} else {
+			halbtc8723b2ant_bt_auto_report(btcoexist, FORCE_EXEC,
+						       true);
+		}
+#endif
+	}
+
+	/* check BIT(2) first ==> check if bt is under inquiry or page scan*/
+	if (btInfo & BT_INFO_8723B_2ANT_B_INQ_PAGE)
+		coex_sta->c2h_bt_inquiry_page = true;
+	else
+		coex_sta->c2h_bt_inquiry_page = false;
+
+	/* set link exist status*/
+	if (!(btInfo & BT_INFO_8723B_2ANT_B_CONNECTION)) {
+		coex_sta->bt_link_exist = false;
+		coex_sta->pan_exist = false;
+		coex_sta->a2dp_exist = false;
+		coex_sta->hid_exist = false;
+		coex_sta->sco_exist = false;
+	} else {/*  connection exists */
+		coex_sta->bt_link_exist = true;
+		if (btInfo & BT_INFO_8723B_2ANT_B_FTP)
+			coex_sta->pan_exist = true;
+		else
+			coex_sta->pan_exist = false;
+		if (btInfo & BT_INFO_8723B_2ANT_B_A2DP)
+			coex_sta->a2dp_exist = true;
+		else
+			coex_sta->a2dp_exist = false;
+		if (btInfo & BT_INFO_8723B_2ANT_B_HID)
+			coex_sta->hid_exist = true;
+		else
+			coex_sta->hid_exist = false;
+		if (btInfo & BT_INFO_8723B_2ANT_B_SCO_ESCO)
+			coex_sta->sco_exist = true;
+		else
+			coex_sta->sco_exist = false;
+	}
+
+	halbtc8723b2ant_update_bt_link_info(btcoexist);
+
+	if (!(btInfo & BT_INFO_8723B_2ANT_B_CONNECTION)) {
+		coex_dm->bt_status = BT_8723B_2ANT_BT_STATUS_NON_CONNECTED_IDLE;
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+			  "[BTCoex], BtInfoNotify(), BT Non-Connected idle!!!\n");
+	/* connection exists but no busy */
+	} else if (btInfo == BT_INFO_8723B_2ANT_B_CONNECTION) {
+		coex_dm->bt_status = BT_8723B_2ANT_BT_STATUS_CONNECTED_IDLE;
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+			  "[BTCoex], BtInfoNotify(), BT Connected-idle!!!\n");
+	} else if ((btInfo & BT_INFO_8723B_2ANT_B_SCO_ESCO) ||
+		   (btInfo & BT_INFO_8723B_2ANT_B_SCO_BUSY)) {
+		coex_dm->bt_status =
+			BT_8723B_2ANT_BT_STATUS_SCO_BUSY;
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+			  "[BTCoex], BtInfoNotify(), BT SCO busy!!!\n");
+	} else if (btInfo&BT_INFO_8723B_2ANT_B_ACL_BUSY) {
+		coex_dm->bt_status =
+			BT_8723B_2ANT_BT_STATUS_ACL_BUSY;
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+			  "[BTCoex], BtInfoNotify(), BT ACL busy!!!\n");
+	} else {
+		coex_dm->bt_status = BT_8723B_2ANT_BT_STATUS_MAX;
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+			  "[BTCoex], BtInfoNotify(), BT Non-Defined state!!!\n");
+	}
+
+	if ((BT_8723B_2ANT_BT_STATUS_ACL_BUSY == coex_dm->bt_status) ||
+	    (BT_8723B_2ANT_BT_STATUS_SCO_BUSY == coex_dm->bt_status) ||
+	    (BT_8723B_2ANT_BT_STATUS_ACL_SCO_BUSY == coex_dm->bt_status)) {
+		bt_busy = true;
+		limited_dig = true;
+	} else {
+		bt_busy = false;
+		limited_dig = false;
+	}
+
+	btcoexist->btc_set(btcoexist, BTC_SET_BL_BT_TRAFFIC_BUSY, &bt_busy);
+
+	coex_dm->limited_dig = limited_dig;
+	btcoexist->btc_set(btcoexist, BTC_SET_BL_BT_LIMITED_DIG, &limited_dig);
+
+	halbtc8723b2ant_run_coexist_mechanism(btcoexist);
+}
+
+void ex92e_halbtc8723b2ant_halt_notify(struct btc_coexist *btcoexist)
+{
+	BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY, "[BTCoex], Halt notify\n");
+
+	halbtc8723b2ant_wifioff_hwcfg(btcoexist);
+	halbtc8723b2ant_ignore_wlan_act(btcoexist, FORCE_EXEC, true);
+	ex92e_halbtc8723b2ant_media_status_notify(btcoexist, BTC_MEDIA_DISCONNECT);
+}
+
+void ex92e_halbtc8723b2ant_periodical(struct btc_coexist *btcoexist)
+{
+	struct btc_board_info *board_info = &btcoexist->board_info;
+	struct btc_stack_info *stack_info = &btcoexist->stack_info;
+	static u8 dis_ver_info_cnt;
+	u32 fw_ver = 0, bt_patch_ver = 0;
+
+	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+		  "[BTCoex], ========================== Periodical ===========================\n");
+
+	if (dis_ver_info_cnt <= 5) {
+		dis_ver_info_cnt += 1;
+		BTC_PRINT(BTC_MSG_INTERFACE, INTF_INIT,
+			  "[BTCoex], ****************************************************************\n");
+		BTC_PRINT(BTC_MSG_INTERFACE, INTF_INIT,
+			  "[BTCoex], Ant PG Num/ Ant Mech/ Ant Pos = %d/%d/%d\n", board_info->pg_ant_num,
+			  board_info->btdm_ant_num, board_info->btdm_ant_pos);
+		BTC_PRINT(BTC_MSG_INTERFACE, INTF_INIT,
+			  "[BTCoex], BT stack/hci ext ver = %s/%d\n",
+			  ((stack_info->profile_notified) ? "Yes" : "No"),
+			  stack_info->hci_version);
+		btcoexist->btc_get(btcoexist, BTC_GET_U4_BT_PATCH_VER,
+				   &bt_patch_ver);
+		btcoexist->btc_get(btcoexist, BTC_GET_U4_WIFI_FW_VER, &fw_ver);
+		BTC_PRINT(BTC_MSG_INTERFACE, INTF_INIT,
+			  "[BTCoex], CoexVer/fw_ver/PatchVer = %d_%x/0x%x/0x%x(%d)\n",
+			  glcoex_ver_date_8723b_2ant, glcoex_ver_8723b_2ant,
+			  fw_ver, bt_patch_ver, bt_patch_ver);
+		BTC_PRINT(BTC_MSG_INTERFACE, INTF_INIT,
+			  "[BTCoex], ****************************************************************\n");
+	}
+
+#if (BT_AUTO_REPORT_ONLY_8723B_2ANT == 0)
+	halbtc8723b2ant_query_bt_info(btcoexist);
+	halbtc8723b2ant_monitor_bt_ctr(btcoexist);
+	halbtc8723b2ant_monitor_bt_enable_disable(btcoexist);
+#else
+	if (is_wifi_status_changed(btcoexist) ||
+	    coex_dm->auto_tdma_adjust)
+		halbtc8723b2ant_run_coexist_mechanism(btcoexist);
+#endif
+}
diff --git a/drivers/staging/rtl8192ee/btcoexist/halbtc8723b2ant.h b/drivers/staging/rtl8192ee/btcoexist/halbtc8723b2ant.h
new file mode 100644
index 0000000..8437e1c
--- /dev/null
+++ b/drivers/staging/rtl8192ee/btcoexist/halbtc8723b2ant.h
@@ -0,0 +1,145 @@
+/************************************************************************
+ * The following is for 8723B 2Ant BT Co-exist definition
+ ************************************************************************/
+#define	BT_AUTO_REPORT_ONLY_8723B_2ANT			1
+
+
+#define	BT_INFO_8723B_2ANT_B_FTP			BIT(7)
+#define	BT_INFO_8723B_2ANT_B_A2DP			BIT(6)
+#define	BT_INFO_8723B_2ANT_B_HID			BIT(5)
+#define	BT_INFO_8723B_2ANT_B_SCO_BUSY			BIT(4)
+#define	BT_INFO_8723B_2ANT_B_ACL_BUSY			BIT(3)
+#define	BT_INFO_8723B_2ANT_B_INQ_PAGE			BIT(2)
+#define	BT_INFO_8723B_2ANT_B_SCO_ESCO			BIT(1)
+#define	BT_INFO_8723B_2ANT_B_CONNECTION			BIT(0)
+
+#define BTC_RSSI_COEX_THRESH_TOL_8723B_2ANT		2
+
+enum BT_INFO_SRC_8723B_2ANT {
+	BT_INFO_SRC_8723B_2ANT_WIFI_FW			= 0x0,
+	BT_INFO_SRC_8723B_2ANT_BT_RSP			= 0x1,
+	BT_INFO_SRC_8723B_2ANT_BT_ACTIVE_SEND		= 0x2,
+	BT_INFO_SRC_8723B_2ANT_MAX
+};
+
+enum BT_8723B_2ANT_BT_STATUS {
+	BT_8723B_2ANT_BT_STATUS_NON_CONNECTED_IDLE	= 0x0,
+	BT_8723B_2ANT_BT_STATUS_CONNECTED_IDLE		= 0x1,
+	BT_8723B_2ANT_BT_STATUS_INQ_PAGE		= 0x2,
+	BT_8723B_2ANT_BT_STATUS_ACL_BUSY		= 0x3,
+	BT_8723B_2ANT_BT_STATUS_SCO_BUSY		= 0x4,
+	BT_8723B_2ANT_BT_STATUS_ACL_SCO_BUSY		= 0x5,
+	BT_8723B_2ANT_BT_STATUS_MAX
+};
+
+enum BT_8723B_2ANT_COEX_ALGO {
+	BT_8723B_2ANT_COEX_ALGO_UNDEFINED		= 0x0,
+	BT_8723B_2ANT_COEX_ALGO_SCO			= 0x1,
+	BT_8723B_2ANT_COEX_ALGO_HID			= 0x2,
+	BT_8723B_2ANT_COEX_ALGO_A2DP			= 0x3,
+	BT_8723B_2ANT_COEX_ALGO_A2DP_PANHS		= 0x4,
+	BT_8723B_2ANT_COEX_ALGO_PANEDR			= 0x5,
+	BT_8723B_2ANT_COEX_ALGO_PANHS			= 0x6,
+	BT_8723B_2ANT_COEX_ALGO_PANEDR_A2DP		= 0x7,
+	BT_8723B_2ANT_COEX_ALGO_PANEDR_HID		= 0x8,
+	BT_8723B_2ANT_COEX_ALGO_HID_A2DP_PANEDR		= 0x9,
+	BT_8723B_2ANT_COEX_ALGO_HID_A2DP		= 0xa,
+	BT_8723B_2ANT_COEX_ALGO_MAX			= 0xb,
+};
+
+struct coex_dm_8723b_2ant {
+	/* fw mechanism */
+	bool pre_dec_bt_pwr;
+	bool cur_dec_bt_pwr;
+	u8 pre_fw_dac_swing_lvl;
+	u8 cur_fw_dac_swing_lvl;
+	bool cur_ignore_wlan_act;
+	bool pre_ignore_wlan_act;
+	u8 pre_ps_tdma;
+	u8 cur_ps_tdma;
+	u8 ps_tdma_para[5];
+	u8 ps_tdma_du_adj_type;
+	bool reset_tdma_adjust;
+	bool auto_tdma_adjust;
+	bool pre_ps_tdma_on;
+	bool cur_ps_tdma_on;
+	bool pre_bt_auto_report;
+	bool cur_bt_auto_report;
+
+	/* sw mechanism */
+	bool pre_rf_rx_lpf_shrink;
+	bool cur_rf_rx_lpf_shrink;
+	u32 bt_rf0x1e_backup;
+	bool pre_low_penalty_ra;
+	bool cur_low_penalty_ra;
+	bool pre_dac_swing_on;
+	u32 pre_dac_swing_lvl;
+	bool cur_dac_swing_on;
+	u32 cur_dac_swing_lvl;
+	bool pre_adc_back_off;
+	bool cur_adc_back_off;
+	bool pre_agc_table_en;
+	bool cur_agc_table_en;
+	u32 pre_val0x6c0;
+	u32 cur_val0x6c0;
+	u32 pre_val0x6c4;
+	u32 cur_val0x6c4;
+	u32 pre_val0x6c8;
+	u32 cur_val0x6c8;
+	u8 pre_val0x6cc;
+	u8 cur_val0x6cc;
+	bool limited_dig;
+
+	/* algorithm related */
+	u8 pre_algorithm;
+	u8 cur_algorithm;
+	u8 bt_status;
+	u8 wifi_chnl_info[3];
+
+	bool need_recover_0x948;
+	u16 backup_0x948;
+};
+
+struct coex_sta_8723b_2ant {
+	bool bt_link_exist;
+	bool sco_exist;
+	bool a2dp_exist;
+	bool hid_exist;
+	bool pan_exist;
+
+	bool under_lps;
+	bool under_ips;
+	u32 high_priority_tx;
+	u32 high_priority_rx;
+	u32 low_priority_tx;
+	u32 low_priority_rx;
+	u8 bt_rssi;
+	u8 pre_bt_rssi_state;
+	u8 pre_wifi_rssi_state[4];
+	bool c2h_bt_info_req_sent;
+	u8 bt_info_c2h[BT_INFO_SRC_8723B_2ANT_MAX][10];
+	u32 bt_info_c2h_cnt[BT_INFO_SRC_8723B_2ANT_MAX];
+	bool c2h_bt_inquiry_page;
+	u8 bt_retry_cnt;
+	u8 bt_info_ext;
+};
+
+/*********************************************************************
+ * The following is interface which will notify coex module.
+ *********************************************************************/
+void ex92e_halbtc8723b2ant_init_hwconfig(struct btc_coexist *btcoexist);
+void ex92e_halbtc8723b2ant_init_coex_dm(struct btc_coexist *btcoexist);
+void ex92e_halbtc8723b2ant_ips_notify(struct btc_coexist *btcoexist, u8 type);
+void ex92e_halbtc8723b2ant_lps_notify(struct btc_coexist *btcoexist, u8 type);
+void ex92e_halbtc8723b2ant_scan_notify(struct btc_coexist *btcoexist, u8 type);
+void ex92e_halbtc8723b2ant_connect_notify(struct btc_coexist *btcoexist,
+					  u8 type);
+void ex92e_halbtc8723b2ant_media_status_notify(struct btc_coexist *btcoexist,
+					       u8 type);
+void ex92e_halbtc8723b2ant_special_packet_notify(struct btc_coexist *btcoexist,
+						 u8 type);
+void ex92e_halbtc8723b2ant_bt_info_notify(struct btc_coexist *btcoexist,
+					  u8 *tmpbuf, u8 length);
+void ex92e_halbtc8723b2ant_halt_notify(struct btc_coexist *btcoexist);
+void ex92e_halbtc8723b2ant_periodical(struct btc_coexist *btcoexist);
+void ex_halbtc8723b2ant92e_display_coex_info(struct btc_coexist *btcoexist);
diff --git a/drivers/staging/rtl8192ee/btcoexist/halbtc8821a1ant.c b/drivers/staging/rtl8192ee/btcoexist/halbtc8821a1ant.c
new file mode 100644
index 0000000..fb52863
--- /dev/null
+++ b/drivers/staging/rtl8192ee/btcoexist/halbtc8821a1ant.c
@@ -0,0 +1,2780 @@
+/*  */
+/*  Description: */
+/*  */
+/*  This file is for RTL8821A Co-exist mechanism */
+/*  */
+/*  History */
+/*  2012/11/15 Cosa first check in. */
+/*  */
+/*  */
+
+/*  */
+/*  include files */
+/*  */
+#include "halbt_precomp.h"
+/*  */
+/*  Global variables, these are static variables */
+/*  */
+static struct coex_dm_8821a_1ant glcoex_dm_8821a_1ant;
+static struct coex_dm_8821a_1ant *coex_dm = &glcoex_dm_8821a_1ant;
+static struct coex_sta_8821a_1ant glcoex_sta_8821a_1ant;
+static struct coex_sta_8821a_1ant *coex_sta = &glcoex_sta_8821a_1ant;
+
+static const char *const glbt_info_src_8821a_1ant[] = {
+	"BT Info[wifi fw]",
+	"BT Info[bt rsp]",
+	"BT Info[bt auto report]",
+};
+
+static u32 glcoex_ver_date_8821a_1ant = 20130816;
+static u32 glcoex_ver_8821a_1ant = 0x41;
+
+/*  local function proto type if needed */
+/*  local function start with halbtc8821a1ant_ */
+static u8 halbtc8821a1ant_bt_rssi_state(u8 level_num, u8 rssi_thresh,
+					u8 rssi_thresh1)
+{
+	long			bt_rssi = 0;
+	u8 bt_rssi_state = coex_sta->pre_bt_rssi_state;
+
+	bt_rssi = coex_sta->bt_rssi;
+
+	if (level_num == 2) {
+		if ((coex_sta->pre_bt_rssi_state == BTC_RSSI_STATE_LOW) ||
+		    (coex_sta->pre_bt_rssi_state == BTC_RSSI_STATE_STAY_LOW)) {
+			if (bt_rssi >= (rssi_thresh+BTC_RSSI_COEX_THRESH_TOL_8821A_1ANT)) {
+				bt_rssi_state = BTC_RSSI_STATE_HIGH;
+				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_RSSI_STATE,
+					  "[BTCoex], BT Rssi state switch to High\n");
+			} else {
+				bt_rssi_state = BTC_RSSI_STATE_STAY_LOW;
+				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_RSSI_STATE,
+					  "[BTCoex], BT Rssi state stay at Low\n");
+			}
+		} else {
+			if (bt_rssi < rssi_thresh) {
+				bt_rssi_state = BTC_RSSI_STATE_LOW;
+				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_RSSI_STATE,
+					  "[BTCoex], BT Rssi state switch to Low\n");
+			} else {
+				bt_rssi_state = BTC_RSSI_STATE_STAY_HIGH;
+				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_RSSI_STATE,
+					  "[BTCoex], BT Rssi state stay at High\n");
+			}
+		}
+	} else if (level_num == 3) {
+		if (rssi_thresh > rssi_thresh1) {
+			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_RSSI_STATE,
+				  "[BTCoex], BT Rssi thresh error!!\n");
+			return coex_sta->pre_bt_rssi_state;
+		}
+
+		if ((coex_sta->pre_bt_rssi_state == BTC_RSSI_STATE_LOW) ||
+		    (coex_sta->pre_bt_rssi_state == BTC_RSSI_STATE_STAY_LOW)) {
+			if (bt_rssi >= (rssi_thresh+BTC_RSSI_COEX_THRESH_TOL_8821A_1ANT)) {
+				bt_rssi_state = BTC_RSSI_STATE_MEDIUM;
+				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_RSSI_STATE,
+					  "[BTCoex], BT Rssi state switch to Medium\n");
+			} else {
+				bt_rssi_state = BTC_RSSI_STATE_STAY_LOW;
+				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_RSSI_STATE,
+					  "[BTCoex], BT Rssi state stay at Low\n");
+			}
+		} else if ((coex_sta->pre_bt_rssi_state == BTC_RSSI_STATE_MEDIUM) ||
+			   (coex_sta->pre_bt_rssi_state == BTC_RSSI_STATE_STAY_MEDIUM)) {
+			if (bt_rssi >= (rssi_thresh1+BTC_RSSI_COEX_THRESH_TOL_8821A_1ANT)) {
+				bt_rssi_state = BTC_RSSI_STATE_HIGH;
+				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_RSSI_STATE,
+					  "[BTCoex], BT Rssi state switch to High\n");
+			} else if (bt_rssi < rssi_thresh) {
+				bt_rssi_state = BTC_RSSI_STATE_LOW;
+				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_RSSI_STATE,
+					  "[BTCoex], BT Rssi state switch to Low\n");
+			} else {
+				bt_rssi_state = BTC_RSSI_STATE_STAY_MEDIUM;
+				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_RSSI_STATE,
+					  "[BTCoex], BT Rssi state stay at Medium\n");
+			}
+		} else {
+			if (bt_rssi < rssi_thresh1) {
+				bt_rssi_state = BTC_RSSI_STATE_MEDIUM;
+				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_RSSI_STATE,
+					  "[BTCoex], BT Rssi state switch to Medium\n");
+			} else {
+				bt_rssi_state = BTC_RSSI_STATE_STAY_HIGH;
+				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_RSSI_STATE,
+					  "[BTCoex], BT Rssi state stay at High\n");
+			}
+		}
+	}
+
+	coex_sta->pre_bt_rssi_state = bt_rssi_state;
+
+	return bt_rssi_state;
+}
+
+static u8 Wifi_rssi_state(struct btc_coexist *btcoexist, u8 index,
+			  u8 level_num, u8 rssi_thresh,
+			  u8 rssi_thresh1)
+{
+	long	wifi_rssi = 0;
+	u8 wifi_rssi_state = coex_sta->pre_wifi_rssi_state[index];
+
+	btcoexist->btc_get(btcoexist, BTC_GET_S4_WIFI_RSSI, &wifi_rssi);
+
+	if (level_num == 2) {
+		if ((coex_sta->pre_wifi_rssi_state[index] == BTC_RSSI_STATE_LOW) ||
+		    (coex_sta->pre_wifi_rssi_state[index] == BTC_RSSI_STATE_STAY_LOW)) {
+			if (wifi_rssi >= (rssi_thresh+BTC_RSSI_COEX_THRESH_TOL_8821A_1ANT)) {
+				wifi_rssi_state = BTC_RSSI_STATE_HIGH;
+				BTC_PRINT(BTC_MSG_ALGORITHM,
+					  ALGO_WIFI_RSSI_STATE,
+					  "[BTCoex], wifi RSSI state switch to High\n");
+			} else {
+				wifi_rssi_state = BTC_RSSI_STATE_STAY_LOW;
+				BTC_PRINT(BTC_MSG_ALGORITHM,
+					  ALGO_WIFI_RSSI_STATE,
+					  "[BTCoex], wifi RSSI state stay at Low\n");
+			}
+		} else {
+			if (wifi_rssi < rssi_thresh) {
+				wifi_rssi_state = BTC_RSSI_STATE_LOW;
+				BTC_PRINT(BTC_MSG_ALGORITHM,
+					  ALGO_WIFI_RSSI_STATE,
+					  "[BTCoex], wifi RSSI state switch to Low\n");
+			} else {
+				wifi_rssi_state = BTC_RSSI_STATE_STAY_HIGH;
+				BTC_PRINT(BTC_MSG_ALGORITHM,
+					  ALGO_WIFI_RSSI_STATE,
+					  "[BTCoex], wifi RSSI state stay at High\n");
+			}
+		}
+	} else if (level_num == 3) {
+		if (rssi_thresh > rssi_thresh1) {
+			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_WIFI_RSSI_STATE,
+				  "[BTCoex], wifi RSSI thresh error!!\n");
+			return coex_sta->pre_wifi_rssi_state[index];
+		}
+
+		if ((coex_sta->pre_wifi_rssi_state[index] ==
+		     BTC_RSSI_STATE_LOW) ||
+		    (coex_sta->pre_wifi_rssi_state[index] ==
+		     BTC_RSSI_STATE_STAY_LOW)) {
+			if (wifi_rssi >= (rssi_thresh +
+			    BTC_RSSI_COEX_THRESH_TOL_8821A_1ANT)) {
+				wifi_rssi_state = BTC_RSSI_STATE_MEDIUM;
+				BTC_PRINT(BTC_MSG_ALGORITHM,
+					  ALGO_WIFI_RSSI_STATE,
+					  "[BTCoex], wifi RSSI state switch to Medium\n");
+			} else {
+				wifi_rssi_state = BTC_RSSI_STATE_STAY_LOW;
+				BTC_PRINT(BTC_MSG_ALGORITHM,
+					  ALGO_WIFI_RSSI_STATE,
+					  "[BTCoex], wifi RSSI state stay at Low\n");
+			}
+		} else if ((coex_sta->pre_wifi_rssi_state[index] ==
+			    BTC_RSSI_STATE_MEDIUM) ||
+			   (coex_sta->pre_wifi_rssi_state[index] ==
+			    BTC_RSSI_STATE_STAY_MEDIUM)) {
+			if (wifi_rssi >= (rssi_thresh1 +
+			    BTC_RSSI_COEX_THRESH_TOL_8821A_1ANT)) {
+				wifi_rssi_state = BTC_RSSI_STATE_HIGH;
+				BTC_PRINT(BTC_MSG_ALGORITHM,
+					  ALGO_WIFI_RSSI_STATE,
+					  "[BTCoex], wifi RSSI state switch to High\n");
+			} else if (wifi_rssi < rssi_thresh) {
+				wifi_rssi_state = BTC_RSSI_STATE_LOW;
+				BTC_PRINT(BTC_MSG_ALGORITHM,
+					  ALGO_WIFI_RSSI_STATE,
+					  "[BTCoex], wifi RSSI state switch to Low\n");
+			} else {
+				wifi_rssi_state = BTC_RSSI_STATE_STAY_MEDIUM;
+				BTC_PRINT(BTC_MSG_ALGORITHM,
+					  ALGO_WIFI_RSSI_STATE,
+					  "[BTCoex], wifi RSSI state stay at Medium\n");
+			}
+		} else {
+			if (wifi_rssi < rssi_thresh1) {
+				wifi_rssi_state = BTC_RSSI_STATE_MEDIUM;
+				BTC_PRINT(BTC_MSG_ALGORITHM,
+					  ALGO_WIFI_RSSI_STATE,
+					  "[BTCoex], wifi RSSI state switch to Medium\n");
+			} else {
+				wifi_rssi_state = BTC_RSSI_STATE_STAY_HIGH;
+				BTC_PRINT(BTC_MSG_ALGORITHM,
+					  ALGO_WIFI_RSSI_STATE,
+					  "[BTCoex], wifi RSSI state stay at High\n");
+			}
+		}
+	}
+
+	coex_sta->pre_wifi_rssi_state[index] = wifi_rssi_state;
+
+	return wifi_rssi_state;
+}
+
+static void update_ra_mask(struct btc_coexist *btcoexist,
+			   bool force_exec, u32 dis_rate_mask)
+{
+	coex_dm->cur_ra_mask = dis_rate_mask;
+
+	if (force_exec || (coex_dm->pre_ra_mask != coex_dm->cur_ra_mask)) {
+		btcoexist->btc_set(btcoexist, BTC_SET_ACT_UPDATE_ra_mask,
+				   &coex_dm->cur_ra_mask);
+	}
+	coex_dm->pre_ra_mask = coex_dm->cur_ra_mask;
+}
+
+static void auto_rate_fallback_retry(struct btc_coexist *btcoexist,
+				     bool force_exec, u8 type)
+{
+	bool wifi_under_b_mode = false;
+
+	coex_dm->cur_arfr_type = type;
+
+	if (force_exec || (coex_dm->pre_arfr_type != coex_dm->cur_arfr_type)) {
+		switch (coex_dm->cur_arfr_type) {
+		case 0:	/*  normal mode */
+			btcoexist->btc_write_4byte(btcoexist, 0x430,
+						   coex_dm->backup_arfr_cnt1);
+			btcoexist->btc_write_4byte(btcoexist, 0x434,
+						   coex_dm->backup_arfr_cnt2);
+			break;
+		case 1:
+			btcoexist->btc_get(btcoexist,
+					   BTC_GET_BL_WIFI_UNDER_B_MODE,
+					   &wifi_under_b_mode);
+			if (wifi_under_b_mode) {
+				btcoexist->btc_write_4byte(btcoexist,
+							   0x430, 0x0);
+				btcoexist->btc_write_4byte(btcoexist,
+							   0x434,
+							   0x01010101);
+			} else {
+				btcoexist->btc_write_4byte(btcoexist,
+							   0x430, 0x0);
+				btcoexist->btc_write_4byte(btcoexist,
+							   0x434,
+							   0x04030201);
+			}
+			break;
+		default:
+			break;
+		}
+	}
+
+	coex_dm->pre_arfr_type = coex_dm->cur_arfr_type;
+}
+
+static void halbtc8821a1ant_retry_limit(struct btc_coexist *btcoexist,
+					bool force_exec, u8 type)
+{
+	coex_dm->cur_retry_limit_type = type;
+
+	if (force_exec || (coex_dm->pre_retry_limit_type !=
+	    coex_dm->cur_retry_limit_type)) {
+		switch (coex_dm->cur_retry_limit_type) {
+		case 0:	/*  normal mode */
+			btcoexist->btc_write_2byte(btcoexist, 0x42a, coex_dm->backup_retry_limit);
+			break;
+		case 1:	/*  retry limit = 8 */
+			btcoexist->btc_write_2byte(btcoexist, 0x42a, 0x0808);
+			break;
+		default:
+			break;
+		}
+	}
+
+	coex_dm->pre_retry_limit_type = coex_dm->cur_retry_limit_type;
+}
+
+static void halbtc8821a1ant_ampdu_max_time(struct btc_coexist *btcoexist,
+					   bool force_exec, u8 type)
+{
+	coex_dm->cur_ampdu_time_type = type;
+
+	if (force_exec ||
+	    (coex_dm->pre_ampdu_time_type != coex_dm->cur_ampdu_time_type)) {
+		switch (coex_dm->cur_ampdu_time_type) {
+		case 0:	/*  normal mode */
+			btcoexist->btc_write_1byte(btcoexist, 0x456, coex_dm->backup_ampdu_max_time);
+			break;
+		case 1:	/*  AMPDU timw = 0x38 * 32us */
+			btcoexist->btc_write_1byte(btcoexist, 0x456, 0x38);
+			break;
+		default:
+			break;
+		}
+	}
+
+	coex_dm->pre_ampdu_time_type = coex_dm->cur_ampdu_time_type;
+}
+
+static void halbtc8821a1ant_limited_tx(struct btc_coexist *btcoexist,
+				       bool force_exec, u8 ra_mask_type,
+				       u8 arfr_type, u8 retry_limit_type,
+				       u8 ampdu_time_type)
+{
+	switch (ra_mask_type) {
+	case 0:	/*  normal mode */
+		update_ra_mask(btcoexist, force_exec, 0x0);
+		break;
+	case 1:	/*  disable cck 1/2 */
+		update_ra_mask(btcoexist, force_exec, 0x00000003);
+		break;
+	case 2:	/*  disable cck 1/2/5.5, ofdm 6/9/12/18/24, mcs 0/1/2/3/4 */
+		update_ra_mask(btcoexist, force_exec, 0x0001f1f7);
+		break;
+	default:
+		break;
+	}
+
+	auto_rate_fallback_retry(btcoexist, force_exec, arfr_type);
+	halbtc8821a1ant_retry_limit(btcoexist, force_exec, retry_limit_type);
+	halbtc8821a1ant_ampdu_max_time(btcoexist, force_exec, ampdu_time_type);
+}
+
+static void halbtc8821a1ant_limited_rx(struct btc_coexist *btcoexist,
+				       bool force_exec, bool rej_ap_agg_pkt,
+				       bool bt_ctrl_agg_buf_size,
+				       u8 agg_buf_size)
+{
+	bool reject_rx_agg = rej_ap_agg_pkt;
+	bool bt_ctrl_rx_agg_size = bt_ctrl_agg_buf_size;
+	u8 rx_agg_size = agg_buf_size;
+
+	/*  */
+	/*	Rx Aggregation related setting */
+	/*  */
+	btcoexist->btc_set(btcoexist, BTC_SET_BL_TO_REJ_AP_AGG_PKT, &reject_rx_agg);
+	/*  decide BT control aggregation buf size or not */
+	btcoexist->btc_set(btcoexist, BTC_SET_BL_BT_CTRL_AGG_SIZE, &bt_ctrl_rx_agg_size);
+	/*  aggregation buf size, only work when BT control Rx aggregation size. */
+	btcoexist->btc_set(btcoexist, BTC_SET_U1_AGG_BUF_SIZE, &rx_agg_size);
+	/*  real update aggregation setting */
+	btcoexist->btc_set(btcoexist, BTC_SET_ACT_AGGREGATE_CTRL, NULL);
+
+}
+
+static void halbtc8821a1ant_monitor_bt_ctr(struct btc_coexist *btcoexist)
+{
+	u32 reg_hp_tx_rx, reg_lp_tx_rx, u4_tmp;
+	u32 reg_hp_tx = 0, reg_hp_rx = 0, reg_lp_tx = 0, reg_lp_rx = 0;
+
+	reg_hp_tx_rx = 0x770;
+	reg_lp_tx_rx = 0x774;
+
+	u4_tmp = btcoexist->btc_read_4byte(btcoexist, reg_hp_tx_rx);
+	reg_hp_tx = u4_tmp & MASKLWORD;
+	reg_hp_rx = (u4_tmp & MASKHWORD)>>16;
+
+	u4_tmp = btcoexist->btc_read_4byte(btcoexist, reg_lp_tx_rx);
+	reg_lp_tx = u4_tmp & MASKLWORD;
+	reg_lp_rx = (u4_tmp & MASKHWORD)>>16;
+
+	coex_sta->high_priority_tx = reg_hp_tx;
+	coex_sta->high_priority_rx = reg_hp_rx;
+	coex_sta->low_priority_tx = reg_lp_tx;
+	coex_sta->low_priority_rx = reg_lp_rx;
+
+	/*  reset counter */
+	btcoexist->btc_write_1byte(btcoexist, 0x76e, 0xc);
+}
+
+static void halbtc8821a1ant_query_bt_info(struct btc_coexist *btcoexist)
+{
+	u8 h2c_parameter[1] = {0};
+
+	coex_sta->c2h_bt_info_req_sent = true;
+
+	h2c_parameter[0] |= BIT(0);	/*  trigger */
+
+	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_EXEC,
+		  "[BTCoex], Query Bt Info, FW write 0x61 = 0x%x\n",
+		h2c_parameter[0]);
+
+	btcoexist->btc_fill_h2c(btcoexist, 0x61, 1, h2c_parameter);
+}
+
+static void halbtc8821a1ant_update_bt_link_info(struct btc_coexist *btcoexist)
+{
+	struct btc_bt_link_info	*bt_link_info = &btcoexist->bt_link_info;
+	bool bt_hs_on = false;
+
+	btcoexist->btc_get(btcoexist, BTC_GET_BL_HS_OPERATION, &bt_hs_on);
+
+	bt_link_info->bt_link_exist = coex_sta->bt_link_exist;
+	bt_link_info->sco_exist = coex_sta->sco_exist;
+	bt_link_info->a2dp_exist = coex_sta->a2dp_exist;
+	bt_link_info->pan_exist = coex_sta->pan_exist;
+	bt_link_info->hid_exist = coex_sta->hid_exist;
+
+	/*  work around for HS mode. */
+	if (bt_hs_on) {
+		bt_link_info->pan_exist = true;
+		bt_link_info->bt_link_exist = true;
+	}
+
+	/*  check if Sco only */
+	if (bt_link_info->sco_exist &&
+		!bt_link_info->a2dp_exist &&
+		!bt_link_info->pan_exist &&
+		!bt_link_info->hid_exist)
+		bt_link_info->sco_only = true;
+	else
+		bt_link_info->sco_only = false;
+
+	/*  check if A2dp only */
+	if (!bt_link_info->sco_exist &&
+		bt_link_info->a2dp_exist &&
+		!bt_link_info->pan_exist &&
+		!bt_link_info->hid_exist)
+		bt_link_info->a2dp_only = true;
+	else
+		bt_link_info->a2dp_only = false;
+
+	/*  check if Pan only */
+	if (!bt_link_info->sco_exist &&
+		!bt_link_info->a2dp_exist &&
+		bt_link_info->pan_exist &&
+		!bt_link_info->hid_exist)
+		bt_link_info->pan_only = true;
+	else
+		bt_link_info->pan_only = false;
+
+	/*  check if Hid only */
+	if (!bt_link_info->sco_exist &&
+		!bt_link_info->a2dp_exist &&
+		!bt_link_info->pan_exist &&
+		bt_link_info->hid_exist)
+		bt_link_info->hid_only = true;
+	else
+		bt_link_info->hid_only = false;
+}
+
+static u8 halbtc8821a1ant_action_algorithm(struct btc_coexist *btcoexist)
+{
+	struct btc_bt_link_info *bt_link_info = &btcoexist->bt_link_info;
+	bool bt_hs_on = false;
+	u8 algorithm = BT_8821A_1ANT_COEX_ALGO_UNDEFINED;
+	u8 num_of_diff_profile = 0;
+
+	btcoexist->btc_get(btcoexist, BTC_GET_BL_HS_OPERATION, &bt_hs_on);
+
+	if (!bt_link_info->bt_link_exist) {
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE, "[BTCoex], No BT link exists!!!\n");
+		return algorithm;
+	}
+
+	if (bt_link_info->sco_exist)
+		num_of_diff_profile++;
+	if (bt_link_info->hid_exist)
+		num_of_diff_profile++;
+	if (bt_link_info->pan_exist)
+		num_of_diff_profile++;
+	if (bt_link_info->a2dp_exist)
+		num_of_diff_profile++;
+
+	if (num_of_diff_profile == 1) {
+		if (bt_link_info->sco_exist) {
+			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE, "[BTCoex], BT Profile = SCO only\n");
+			algorithm = BT_8821A_1ANT_COEX_ALGO_SCO;
+		} else {
+			if (bt_link_info->hid_exist) {
+				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE, "[BTCoex], BT Profile = HID only\n");
+				algorithm = BT_8821A_1ANT_COEX_ALGO_HID;
+			} else if (bt_link_info->a2dp_exist) {
+				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE, "[BTCoex], BT Profile = A2DP only\n");
+				algorithm = BT_8821A_1ANT_COEX_ALGO_A2DP;
+			} else if (bt_link_info->pan_exist) {
+				if (bt_hs_on) {
+					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE, "[BTCoex], BT Profile = PAN(HS) only\n");
+					algorithm = BT_8821A_1ANT_COEX_ALGO_PANHS;
+				} else {
+					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE, "[BTCoex], BT Profile = PAN(EDR) only\n");
+					algorithm = BT_8821A_1ANT_COEX_ALGO_PANEDR;
+				}
+			}
+		}
+	} else if (num_of_diff_profile == 2) {
+		if (bt_link_info->sco_exist) {
+			if (bt_link_info->hid_exist) {
+				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE, "[BTCoex], BT Profile = SCO + HID\n");
+				algorithm = BT_8821A_1ANT_COEX_ALGO_HID;
+			} else if (bt_link_info->a2dp_exist) {
+				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE, "[BTCoex], BT Profile = SCO + A2DP ==> SCO\n");
+				algorithm = BT_8821A_1ANT_COEX_ALGO_SCO;
+			} else if (bt_link_info->pan_exist) {
+				if (bt_hs_on) {
+					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE, "[BTCoex], BT Profile = SCO + PAN(HS)\n");
+					algorithm = BT_8821A_1ANT_COEX_ALGO_SCO;
+				} else {
+					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE, "[BTCoex], BT Profile = SCO + PAN(EDR)\n");
+					algorithm = BT_8821A_1ANT_COEX_ALGO_PANEDR_HID;
+				}
+			}
+		} else {
+			if (bt_link_info->hid_exist &&
+				bt_link_info->a2dp_exist) {
+				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE, "[BTCoex], BT Profile = HID + A2DP\n");
+				algorithm = BT_8821A_1ANT_COEX_ALGO_HID_A2DP;
+			} else if (bt_link_info->hid_exist &&
+				bt_link_info->pan_exist) {
+				if (bt_hs_on) {
+					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE, "[BTCoex], BT Profile = HID + PAN(HS)\n");
+					algorithm = BT_8821A_1ANT_COEX_ALGO_HID_A2DP;
+				} else {
+					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE, "[BTCoex], BT Profile = HID + PAN(EDR)\n");
+					algorithm = BT_8821A_1ANT_COEX_ALGO_PANEDR_HID;
+				}
+			} else if (bt_link_info->pan_exist &&
+				bt_link_info->a2dp_exist) {
+				if (bt_hs_on) {
+					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE, "[BTCoex], BT Profile = A2DP + PAN(HS)\n");
+					algorithm = BT_8821A_1ANT_COEX_ALGO_A2DP_PANHS;
+				} else {
+					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE, "[BTCoex], BT Profile = A2DP + PAN(EDR)\n");
+					algorithm = BT_8821A_1ANT_COEX_ALGO_PANEDR_A2DP;
+				}
+			}
+		}
+	} else if (num_of_diff_profile == 3) {
+		if (bt_link_info->sco_exist) {
+			if (bt_link_info->hid_exist &&
+				bt_link_info->a2dp_exist) {
+				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE, "[BTCoex], BT Profile = SCO + HID + A2DP ==> HID\n");
+				algorithm = BT_8821A_1ANT_COEX_ALGO_HID;
+			} else if (bt_link_info->hid_exist &&
+				bt_link_info->pan_exist) {
+				if (bt_hs_on) {
+					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE, "[BTCoex], BT Profile = SCO + HID + PAN(HS)\n");
+					algorithm = BT_8821A_1ANT_COEX_ALGO_HID_A2DP;
+				} else {
+					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE, "[BTCoex], BT Profile = SCO + HID + PAN(EDR)\n");
+					algorithm = BT_8821A_1ANT_COEX_ALGO_PANEDR_HID;
+				}
+			} else if (bt_link_info->pan_exist &&
+				bt_link_info->a2dp_exist) {
+				if (bt_hs_on) {
+					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE, "[BTCoex], BT Profile = SCO + A2DP + PAN(HS)\n");
+					algorithm = BT_8821A_1ANT_COEX_ALGO_SCO;
+				} else {
+					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE, "[BTCoex], BT Profile = SCO + A2DP + PAN(EDR) ==> HID\n");
+					algorithm = BT_8821A_1ANT_COEX_ALGO_PANEDR_HID;
+				}
+			}
+		} else {
+			if (bt_link_info->hid_exist &&
+				bt_link_info->pan_exist &&
+				bt_link_info->a2dp_exist) {
+				if (bt_hs_on) {
+					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE, "[BTCoex], BT Profile = HID + A2DP + PAN(HS)\n");
+					algorithm = BT_8821A_1ANT_COEX_ALGO_HID_A2DP;
+				} else {
+					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE, "[BTCoex], BT Profile = HID + A2DP + PAN(EDR)\n");
+					algorithm = BT_8821A_1ANT_COEX_ALGO_HID_A2DP_PANEDR;
+				}
+			}
+		}
+	} else if (num_of_diff_profile >= 3) {
+		if (bt_link_info->sco_exist) {
+			if (bt_link_info->hid_exist &&
+				bt_link_info->pan_exist &&
+				bt_link_info->a2dp_exist) {
+				if (bt_hs_on) {
+					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE, "[BTCoex], Error!!! BT Profile = SCO + HID + A2DP + PAN(HS)\n");
+				} else {
+					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE, "[BTCoex], BT Profile = SCO + HID + A2DP + PAN(EDR) ==>PAN(EDR)+HID\n");
+					algorithm = BT_8821A_1ANT_COEX_ALGO_PANEDR_HID;
+				}
+			}
+		}
+	}
+
+	return algorithm;
+}
+
+static void halbtc8821a1ant_set_bt_auto_report(struct btc_coexist *btcoexist,
+					       bool enable_auto_report)
+{
+	u8 h2c_parameter[1] = {0};
+
+	h2c_parameter[0] = 0;
+
+	if (enable_auto_report)
+		h2c_parameter[0] |= BIT(0);
+
+	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_EXEC,
+		  "[BTCoex], BT FW auto report : %s, FW write 0x68 = 0x%x\n",
+		  (enable_auto_report ? "Enabled!!" : "Disabled!!"),
+		  h2c_parameter[0]);
+
+	btcoexist->btc_fill_h2c(btcoexist, 0x68, 1, h2c_parameter);
+}
+
+static void halbtc8821a1ant_bt_auto_report(struct btc_coexist *btcoexist,
+					   bool force_exec,
+					   bool enable_auto_report)
+{
+	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW, "[BTCoex], %s BT Auto report = %s\n",
+		(force_exec ? "force to" : ""), ((enable_auto_report) ? "Enabled" : "Disabled"));
+	coex_dm->cur_bt_auto_report = enable_auto_report;
+
+	if (!force_exec) {
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_DETAIL, "[BTCoex], pre_bt_auto_report =%d, cur_bt_auto_report =%d\n",
+			coex_dm->pre_bt_auto_report, coex_dm->cur_bt_auto_report);
+
+		if (coex_dm->pre_bt_auto_report == coex_dm->cur_bt_auto_report)
+			return;
+	}
+	halbtc8821a1ant_set_bt_auto_report(btcoexist, coex_dm->cur_bt_auto_report);
+
+	coex_dm->pre_bt_auto_report = coex_dm->cur_bt_auto_report;
+}
+
+static void set_sw_penalty_tx_rate_adaptive(struct btc_coexist *btcoexist,
+					    bool low_penalty_ra)
+{
+	u8 h2c_parameter[6] = {0};
+
+	h2c_parameter[0] = 0x6;	/*  opCode, 0x6 = Retry_Penalty */
+
+	if (low_penalty_ra) {
+		h2c_parameter[1] |= BIT(0);
+		h2c_parameter[2] = 0x00;  /* normal rate except MCS7/6/5,
+					   * OFDM54/48/36 */
+		h2c_parameter[3] = 0xf7;  /* MCS7 or OFDM54 */
+		h2c_parameter[4] = 0xf8;  /* MCS6 or OFDM48 */
+		h2c_parameter[5] = 0xf9;  /* MCS5 or OFDM36  */
+	}
+
+	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_EXEC,
+		  "[BTCoex], set WiFi Low-Penalty Retry: %s",
+		  (low_penalty_ra ? "ON!!" : "OFF!!"));
+
+	btcoexist->btc_fill_h2c(btcoexist, 0x69, 6, h2c_parameter);
+}
+
+static void halbtc8821a1ant_low_penalty_ra(struct btc_coexist *btcoexist,
+					   bool force_exec, bool low_penalty_ra)
+{
+	coex_dm->cur_low_penalty_ra = low_penalty_ra;
+
+	if (!force_exec) {
+		if (coex_dm->pre_low_penalty_ra == coex_dm->cur_low_penalty_ra)
+			return;
+	}
+	set_sw_penalty_tx_rate_adaptive(btcoexist, coex_dm->cur_low_penalty_ra);
+
+	coex_dm->pre_low_penalty_ra = coex_dm->cur_low_penalty_ra;
+}
+
+static void halbtc8821a1ant_set_coex_table(struct btc_coexist *btcoexist,
+					   u32 val0x6c0, u32 val0x6c4,
+					   u32 val0x6c8, u8 val0x6cc)
+{
+	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW_EXEC,
+		  "[BTCoex], set coex table, set 0x6c0 = 0x%x\n", val0x6c0);
+	btcoexist->btc_write_4byte(btcoexist, 0x6c0, val0x6c0);
+
+	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW_EXEC,
+		  "[BTCoex], set coex table, set 0x6c4 = 0x%x\n", val0x6c4);
+	btcoexist->btc_write_4byte(btcoexist, 0x6c4, val0x6c4);
+
+	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW_EXEC,
+		  "[BTCoex], set coex table, set 0x6c8 = 0x%x\n", val0x6c8);
+	btcoexist->btc_write_4byte(btcoexist, 0x6c8, val0x6c8);
+
+	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW_EXEC,
+		  "[BTCoex], set coex table, set 0x6cc = 0x%x\n", val0x6cc);
+	btcoexist->btc_write_1byte(btcoexist, 0x6cc, val0x6cc);
+}
+
+static void halbtc8821a1ant_coex_table(struct btc_coexist *btcoexist,
+				       bool force_exec, u32 val0x6c0,
+				       u32 val0x6c4, u32 val0x6c8, u8 val0x6cc)
+{
+	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW,
+		  "[BTCoex], %s write Coex Table 0x6c0 = 0x%x, 0x6c4 = 0x%x, 0x6c8 = 0x%x, 0x6cc = 0x%x\n",
+		  (force_exec ? "force to" : ""), val0x6c0, val0x6c4,
+		  val0x6c8, val0x6cc);
+	coex_dm->cur_val_0x6c0 = val0x6c0;
+	coex_dm->cur_val_0x6c4 = val0x6c4;
+	coex_dm->cur_val_0x6c8 = val0x6c8;
+	coex_dm->cur_val_0x6cc = val0x6cc;
+
+	if (!force_exec) {
+		if ((coex_dm->pre_val_0x6c0 == coex_dm->cur_val_0x6c0) &&
+		    (coex_dm->pre_val_0x6c4 == coex_dm->cur_val_0x6c4) &&
+		    (coex_dm->pre_val_0x6c8 == coex_dm->cur_val_0x6c8) &&
+		    (coex_dm->pre_val_0x6cc == coex_dm->cur_val_0x6cc))
+			return;
+	}
+	halbtc8821a1ant_set_coex_table(btcoexist, val0x6c0, val0x6c4,
+				       val0x6c8, val0x6cc);
+
+	coex_dm->pre_val_0x6c0 = coex_dm->cur_val_0x6c0;
+	coex_dm->pre_val_0x6c4 = coex_dm->cur_val_0x6c4;
+	coex_dm->pre_val_0x6c8 = coex_dm->cur_val_0x6c8;
+	coex_dm->pre_val_0x6cc = coex_dm->cur_val_0x6cc;
+}
+
+static void halbtc8821a1ant_coex_table_with_type(struct btc_coexist *btcoexist,
+						 bool force_exec, u8 type)
+{
+	switch (type) {
+	case 0:
+		halbtc8821a1ant_coex_table(btcoexist, force_exec,
+					   0x55555555, 0x55555555,
+					   0xffffff, 0x3);
+		break;
+	case 1:
+		halbtc8821a1ant_coex_table(btcoexist, force_exec,
+					   0x55555555, 0x5a5a5a5a,
+					   0xffffff, 0x3);
+		break;
+	case 2:
+		halbtc8821a1ant_coex_table(btcoexist, force_exec,
+					   0x5a5a5a5a, 0x5a5a5a5a,
+					   0xffffff, 0x3);
+		break;
+	case 3:
+		halbtc8821a1ant_coex_table(btcoexist, force_exec,
+					   0x55555555, 0xaaaaaaaa,
+					   0xffffff, 0x3);
+		break;
+	case 4:
+		halbtc8821a1ant_coex_table(btcoexist, force_exec,
+					   0xffffffff, 0xffffffff,
+					   0xffffff, 0x3);
+		break;
+	case 5:
+		halbtc8821a1ant_coex_table(btcoexist, force_exec,
+					   0x5fff5fff, 0x5fff5fff,
+					   0xffffff, 0x3);
+		break;
+	case 6:
+		halbtc8821a1ant_coex_table(btcoexist, force_exec,
+					   0x55ff55ff, 0x5a5a5a5a,
+					   0xffffff, 0x3);
+		break;
+	case 7:
+		halbtc8821a1ant_coex_table(btcoexist, force_exec,
+					   0x5afa5afa, 0x5afa5afa,
+					   0xffffff, 0x3);
+		break;
+	default:
+		break;
+	}
+}
+
+static void halbtc8821a1ant_set_fw_ignore_wlan_act(struct btc_coexist *btcoexist,
+						   bool enable)
+{
+	u8 h2c_parameter[1] = {0};
+
+	if (enable)
+		h2c_parameter[0] |= BIT(0);	/*  function enable */
+
+	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_EXEC,
+		  "[BTCoex], set FW for BT Ignore Wlan_Act, FW write 0x63 = 0x%x\n",
+		  h2c_parameter[0]);
+
+	btcoexist->btc_fill_h2c(btcoexist, 0x63, 1, h2c_parameter);
+}
+
+static void halbtc8821a1ant_ignore_wlan_act(struct btc_coexist *btcoexist,
+					    bool force_exec, bool enable)
+{
+	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW,
+		  "[BTCoex], %s turn Ignore WlanAct %s\n",
+		  (force_exec ? "force to" : ""), (enable ? "ON" : "OFF"));
+	coex_dm->cur_ignore_wlan_act = enable;
+
+	if (!force_exec) {
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_DETAIL,
+			  "[BTCoex], pre_ignore_wlan_act = %d, cur_ignore_wlan_act = %d!!\n",
+			  coex_dm->pre_ignore_wlan_act,
+			  coex_dm->cur_ignore_wlan_act);
+
+		if (coex_dm->pre_ignore_wlan_act ==
+		    coex_dm->cur_ignore_wlan_act)
+			return;
+	}
+	halbtc8821a1ant_set_fw_ignore_wlan_act(btcoexist, enable);
+
+	coex_dm->pre_ignore_wlan_act = coex_dm->cur_ignore_wlan_act;
+}
+
+static void
+halbtc8821a1ant_set_fw_pstdma(
+	struct btc_coexist *btcoexist,
+	u8 byte1,
+	u8 byte2,
+	u8 byte3,
+	u8 byte4,
+	u8 byte5
+	)
+{
+	u8 h2c_parameter[5] = {0};
+
+	h2c_parameter[0] = byte1;
+	h2c_parameter[1] = byte2;
+	h2c_parameter[2] = byte3;
+	h2c_parameter[3] = byte4;
+	h2c_parameter[4] = byte5;
+
+	coex_dm->ps_tdma_para[0] = byte1;
+	coex_dm->ps_tdma_para[1] = byte2;
+	coex_dm->ps_tdma_para[2] = byte3;
+	coex_dm->ps_tdma_para[3] = byte4;
+	coex_dm->ps_tdma_para[4] = byte5;
+
+	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_EXEC, "[BTCoex], PS-TDMA H2C cmd = 0x%x%08x\n",
+		h2c_parameter[0],
+		h2c_parameter[1]<<24|h2c_parameter[2]<<16|h2c_parameter[3]<<8|h2c_parameter[4]);
+
+	btcoexist->btc_fill_h2c(btcoexist, 0x60, 5, h2c_parameter);
+}
+
+static void
+halbtc8821a1ant_set_lps_rpwm(
+	struct btc_coexist *btcoexist,
+	u8 lps_val,
+	u8 rpwm_val
+	)
+{
+	u8 lps = lps_val;
+	u8 rpwm = rpwm_val;
+
+	btcoexist->btc_set(btcoexist, BTC_SET_U1_LPS_VAL, &lps);
+	btcoexist->btc_set(btcoexist, BTC_SET_U1_RPWM_VAL, &rpwm);
+}
+
+static void
+halbtc8821a1ant_lps_rpwm(
+	struct btc_coexist *btcoexist,
+	bool force_exec,
+	u8 lps_val,
+	u8 rpwm_val
+	)
+{
+	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW, "[BTCoex], %s set lps/rpwm = 0x%x/0x%x\n",
+		(force_exec ? "force to" : ""), lps_val, rpwm_val);
+	coex_dm->cur_lps = lps_val;
+	coex_dm->cur_rpwm = rpwm_val;
+
+	if (!force_exec) {
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_DETAIL, "[BTCoex], LPS-RxBeaconMode = 0x%x , LPS-RPWM = 0x%x!!\n",
+			 coex_dm->cur_lps, coex_dm->cur_rpwm);
+
+		if ((coex_dm->pre_lps == coex_dm->cur_lps) &&
+			(coex_dm->pre_rpwm == coex_dm->cur_rpwm)) {
+			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_DETAIL, "[BTCoex], LPS-RPWM_Last = 0x%x , LPS-RPWM_Now = 0x%x!!\n",
+				 coex_dm->pre_rpwm, coex_dm->cur_rpwm);
+
+			return;
+		}
+	}
+	halbtc8821a1ant_set_lps_rpwm(btcoexist, lps_val, rpwm_val);
+
+	coex_dm->pre_lps = coex_dm->cur_lps;
+	coex_dm->pre_rpwm = coex_dm->cur_rpwm;
+}
+
+static void
+halbtc8821a1ant_sw_mechanism(
+	struct btc_coexist *btcoexist,
+	bool low_penalty_ra
+	)
+{
+	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_MONITOR, "[BTCoex], SM[LpRA] = %d\n", low_penalty_ra);
+
+	halbtc8821a1ant_low_penalty_ra(btcoexist, NORMAL_EXEC, low_penalty_ra);
+}
+
+static void
+halbtc8821a1ant_set_ant_path(
+	struct btc_coexist *btcoexist,
+	u8 ant_pos_type,
+	bool init_hw_cfg,
+	bool wifi_off
+	)
+{
+	struct btc_board_info *board_info = &btcoexist->board_info;
+	u32 u4_tmp = 0;
+	u8 h2c_parameter[2] = {0};
+
+	if (init_hw_cfg) {
+		/*  0x4c[23] = 0, 0x4c[24] = 1  Antenna control by WL/BT */
+		u4_tmp = btcoexist->btc_read_4byte(btcoexist, 0x4c);
+		u4_tmp &= ~BIT(23);
+		u4_tmp |= BIT(24);
+		btcoexist->btc_write_4byte(btcoexist, 0x4c, u4_tmp);
+
+		btcoexist->btc_write_1byte_bitmask(btcoexist, 0x975, 0x3, 0x3);
+		btcoexist->btc_write_1byte(btcoexist, 0xcb4, 0x77);
+
+		if (board_info->btdm_ant_pos == BTC_ANTENNA_AT_MAIN_PORT) {
+			/* tell firmware "antenna inverse"  ==> WRONG firmware antenna control code.==>need fw to fix */
+			h2c_parameter[0] = 1;
+			h2c_parameter[1] = 1;
+			btcoexist->btc_fill_h2c(btcoexist, 0x65, 2, h2c_parameter);
+
+			btcoexist->btc_write_1byte_bitmask(btcoexist, 0x64, 0x1, 0x1); /* Main Ant to  BT for IPS case 0x4c[23] = 1 */
+		} else {
+			/* tell firmware "no antenna inverse" ==> WRONG firmware antenna control code.==>need fw to fix */
+			h2c_parameter[0] = 0;
+			h2c_parameter[1] = 1;
+			btcoexist->btc_fill_h2c(btcoexist, 0x65, 2, h2c_parameter);
+
+			btcoexist->btc_write_1byte_bitmask(btcoexist, 0x64, 0x1, 0x0); /* Aux Ant to  BT for IPS case 0x4c[23] = 1 */
+		}
+	} else if (wifi_off) {
+		/*  0x4c[24:23] = 00, Set Antenna control by BT_RFE_CTRL	BT Vendor 0xac = 0xf002 */
+		u4_tmp = btcoexist->btc_read_4byte(btcoexist, 0x4c);
+		u4_tmp &= ~BIT(23);
+		u4_tmp &= ~BIT(24);
+		btcoexist->btc_write_4byte(btcoexist, 0x4c, u4_tmp);
+	}
+
+	/*  ext switch setting */
+	switch (ant_pos_type) {
+	case BTC_ANT_PATH_WIFI:
+		if (board_info->btdm_ant_pos == BTC_ANTENNA_AT_MAIN_PORT)
+			btcoexist->btc_write_1byte_bitmask(btcoexist, 0xcb7, 0x30, 0x1);
+		else
+			btcoexist->btc_write_1byte_bitmask(btcoexist, 0xcb7, 0x30, 0x2);
+		break;
+	case BTC_ANT_PATH_BT:
+		if (board_info->btdm_ant_pos == BTC_ANTENNA_AT_MAIN_PORT)
+			btcoexist->btc_write_1byte_bitmask(btcoexist, 0xcb7, 0x30, 0x2);
+		else
+			btcoexist->btc_write_1byte_bitmask(btcoexist, 0xcb7, 0x30, 0x1);
+		break;
+	case BTC_ANT_PATH_PTA:
+	default:
+		if (board_info->btdm_ant_pos == BTC_ANTENNA_AT_MAIN_PORT)
+			btcoexist->btc_write_1byte_bitmask(btcoexist, 0xcb7, 0x30, 0x1);
+		else
+			btcoexist->btc_write_1byte_bitmask(btcoexist, 0xcb7, 0x30, 0x2);
+		break;
+	}
+}
+
+static void
+halbtc8821a1ant_ps_tdma(
+	struct btc_coexist *btcoexist,
+	bool force_exec,
+	bool turn_on,
+	u8 type
+	)
+{
+	u8 rssi_adjust_val = 0;
+
+	coex_dm->cur_ps_tdma_on = turn_on;
+	coex_dm->cur_ps_tdma = type;
+
+	if (!force_exec) {
+		if (coex_dm->cur_ps_tdma_on) {
+			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_DETAIL, "[BTCoex], ********** TDMA(on, %d) **********\n",
+				coex_dm->cur_ps_tdma);
+		} else {
+			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_DETAIL, "[BTCoex], ********** TDMA(off, %d) **********\n",
+				coex_dm->cur_ps_tdma);
+		}
+
+		if ((coex_dm->pre_ps_tdma_on == coex_dm->cur_ps_tdma_on) &&
+			(coex_dm->pre_ps_tdma == coex_dm->cur_ps_tdma))
+			return;
+	}
+	if (turn_on) {
+		switch (type) {
+		default:
+			halbtc8821a1ant_set_fw_pstdma(btcoexist, 0x51, 0x1a, 0x1a, 0x0, 0x50);
+			break;
+		case 1:
+			halbtc8821a1ant_set_fw_pstdma(btcoexist, 0x51, 0x3a, 0x03, 0x10, 0x50);
+			rssi_adjust_val = 11;
+			break;
+		case 2:
+			halbtc8821a1ant_set_fw_pstdma(btcoexist, 0x51, 0x2b, 0x03, 0x10, 0x50);
+			rssi_adjust_val = 14;
+			break;
+		case 3:
+			halbtc8821a1ant_set_fw_pstdma(btcoexist, 0x51, 0x1d, 0x1d, 0x0, 0x10);
+			break;
+		case 4:
+			halbtc8821a1ant_set_fw_pstdma(btcoexist, 0x93, 0x15, 0x3, 0x14, 0x0);
+			rssi_adjust_val = 17;
+			break;
+		case 5:
+			halbtc8821a1ant_set_fw_pstdma(btcoexist, 0x61, 0x15, 0x3, 0x11, 0x10);
+			break;
+		case 6:
+			halbtc8821a1ant_set_fw_pstdma(btcoexist, 0x13, 0xa, 0x3, 0x0, 0x0);
+			break;
+		case 7:
+			halbtc8821a1ant_set_fw_pstdma(btcoexist, 0x13, 0xc, 0x5, 0x0, 0x0);
+			break;
+		case 8:
+			halbtc8821a1ant_set_fw_pstdma(btcoexist, 0x93, 0x25, 0x3, 0x10, 0x0);
+			break;
+		case 9:
+			halbtc8821a1ant_set_fw_pstdma(btcoexist, 0x51, 0x21, 0x3, 0x10, 0x50);
+			rssi_adjust_val = 18;
+			break;
+		case 10:
+			halbtc8821a1ant_set_fw_pstdma(btcoexist, 0x13, 0xa, 0xa, 0x0, 0x40);
+			break;
+		case 11:
+			halbtc8821a1ant_set_fw_pstdma(btcoexist, 0x51, 0x14, 0x03, 0x10, 0x10);
+			rssi_adjust_val = 20;
+			break;
+		case 12:
+			halbtc8821a1ant_set_fw_pstdma(btcoexist, 0x51, 0x0a, 0x0a, 0x0, 0x50);
+			break;
+		case 13:
+			halbtc8821a1ant_set_fw_pstdma(btcoexist, 0x51, 0x18, 0x18, 0x0, 0x10);
+			break;
+		case 14:
+			halbtc8821a1ant_set_fw_pstdma(btcoexist, 0x51, 0x21, 0x3, 0x10, 0x10);
+			break;
+		case 15:
+			halbtc8821a1ant_set_fw_pstdma(btcoexist, 0x13, 0xa, 0x3, 0x8, 0x0);
+			break;
+		case 16:
+			halbtc8821a1ant_set_fw_pstdma(btcoexist, 0x93, 0x15, 0x3, 0x10, 0x0);
+			rssi_adjust_val = 18;
+			break;
+		case 18:
+			halbtc8821a1ant_set_fw_pstdma(btcoexist, 0x93, 0x25, 0x3, 0x10, 0x0);
+			rssi_adjust_val = 14;
+			break;
+		case 20:
+			halbtc8821a1ant_set_fw_pstdma(btcoexist, 0x61, 0x35, 0x03, 0x11, 0x10);
+			break;
+		case 21:
+			halbtc8821a1ant_set_fw_pstdma(btcoexist, 0x61, 0x15, 0x03, 0x11, 0x10);
+			break;
+		case 22:
+			halbtc8821a1ant_set_fw_pstdma(btcoexist, 0x61, 0x25, 0x03, 0x11, 0x10);
+			break;
+		case 23:
+			halbtc8821a1ant_set_fw_pstdma(btcoexist, 0xe3, 0x25, 0x3, 0x31, 0x18);
+			rssi_adjust_val = 22;
+			break;
+		case 24:
+			halbtc8821a1ant_set_fw_pstdma(btcoexist, 0xe3, 0x15, 0x3, 0x31, 0x18);
+			rssi_adjust_val = 22;
+			break;
+		case 25:
+			halbtc8821a1ant_set_fw_pstdma(btcoexist, 0xe3, 0xa, 0x3, 0x31, 0x18);
+			rssi_adjust_val = 22;
+			break;
+		case 26:
+			halbtc8821a1ant_set_fw_pstdma(btcoexist, 0xe3, 0xa, 0x3, 0x31, 0x18);
+			rssi_adjust_val = 22;
+			break;
+		case 27:
+			halbtc8821a1ant_set_fw_pstdma(btcoexist, 0xe3, 0x25, 0x3, 0x31, 0x98);
+			rssi_adjust_val = 22;
+			break;
+		case 28:
+			halbtc8821a1ant_set_fw_pstdma(btcoexist, 0x69, 0x25, 0x3, 0x31, 0x0);
+			break;
+		case 29:
+			halbtc8821a1ant_set_fw_pstdma(btcoexist, 0xab, 0x1a, 0x1a, 0x1, 0x10);
+			break;
+		case 30:
+			halbtc8821a1ant_set_fw_pstdma(btcoexist, 0x51, 0x14, 0x3, 0x10, 0x50);
+			break;
+		case 31:
+			halbtc8821a1ant_set_fw_pstdma(btcoexist, 0xd3, 0x1a, 0x1a, 0, 0x58);
+			break;
+		case 32:
+			halbtc8821a1ant_set_fw_pstdma(btcoexist, 0x61, 0xa, 0x3, 0x10, 0x0);
+			break;
+		case 33:
+			halbtc8821a1ant_set_fw_pstdma(btcoexist, 0xa3, 0x25, 0x3, 0x30, 0x90);
+			break;
+		case 34:
+			halbtc8821a1ant_set_fw_pstdma(btcoexist, 0x53, 0x1a, 0x1a, 0x0, 0x10);
+			break;
+		case 35:
+			halbtc8821a1ant_set_fw_pstdma(btcoexist, 0x63, 0x1a, 0x1a, 0x0, 0x10);
+			break;
+		case 36:
+			halbtc8821a1ant_set_fw_pstdma(btcoexist, 0xd3, 0x12, 0x3, 0x14, 0x50);
+				break;
+		}
+	} else {
+		/*  disable PS tdma */
+		switch (type) {
+		case 8: /* PTA Control */
+			halbtc8821a1ant_set_fw_pstdma(btcoexist, 0x8, 0x0, 0x0, 0x0, 0x0);
+			halbtc8821a1ant_set_ant_path(btcoexist, BTC_ANT_PATH_PTA, false, false);
+			break;
+		case 0:
+		default:  /* Software control, Antenna at BT side */
+			halbtc8821a1ant_set_fw_pstdma(btcoexist, 0x0, 0x0, 0x0, 0x0, 0x0);
+			halbtc8821a1ant_set_ant_path(btcoexist, BTC_ANT_PATH_BT, false, false);
+			break;
+		case 9:   /* Software control, Antenna at WiFi side */
+			halbtc8821a1ant_set_fw_pstdma(btcoexist, 0x0, 0x0, 0x0, 0x0, 0x0);
+			halbtc8821a1ant_set_ant_path(btcoexist, BTC_ANT_PATH_WIFI, false, false);
+			break;
+		case 10:	/*  under 5G */
+			halbtc8821a1ant_set_fw_pstdma(btcoexist, 0x0, 0x0, 0x0, 0x8, 0x0);
+			halbtc8821a1ant_set_ant_path(btcoexist, BTC_ANT_PATH_BT, false, false);
+			break;
+		}
+	}
+	rssi_adjust_val = 0;
+	btcoexist->btc_set(btcoexist, BTC_SET_U1_RSSI_ADJ_VAL_FOR_1ANT_COEX_TYPE, &rssi_adjust_val);
+
+	/*  update pre state */
+	coex_dm->pre_ps_tdma_on = coex_dm->cur_ps_tdma_on;
+	coex_dm->pre_ps_tdma = coex_dm->cur_ps_tdma;
+}
+
+static bool
+halbtc8821a1ant_is_common_action(
+	struct btc_coexist *btcoexist
+	)
+{
+	bool bCommon = false, wifi_connected = false, wifi_busy = false;
+
+	btcoexist->btc_get(btcoexist, BTC_GET_BL_WIFI_CONNECTED, &wifi_connected);
+	btcoexist->btc_get(btcoexist, BTC_GET_BL_WIFI_BUSY, &wifi_busy);
+
+	if (!wifi_connected &&
+		BT_8821A_1ANT_BT_STATUS_NON_CONNECTED_IDLE == coex_dm->bt_status) {
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE, "[BTCoex], Wifi non connected-idle + BT non connected-idle!!\n");
+		halbtc8821a1ant_sw_mechanism(btcoexist, false);
+
+		bCommon = true;
+	} else if (wifi_connected &&
+			(BT_8821A_1ANT_BT_STATUS_NON_CONNECTED_IDLE == coex_dm->bt_status)) {
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE, "[BTCoex], Wifi connected + BT non connected-idle!!\n");
+		halbtc8821a1ant_sw_mechanism(btcoexist, false);
+
+		bCommon = true;
+	} else if (!wifi_connected &&
+		(BT_8821A_1ANT_BT_STATUS_CONNECTED_IDLE == coex_dm->bt_status)) {
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE, "[BTCoex], Wifi non connected-idle + BT connected-idle!!\n");
+		halbtc8821a1ant_sw_mechanism(btcoexist, false);
+
+		bCommon = true;
+	} else if (wifi_connected &&
+		(BT_8821A_1ANT_BT_STATUS_CONNECTED_IDLE == coex_dm->bt_status)) {
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE, "[BTCoex], Wifi connected + BT connected-idle!!\n");
+		halbtc8821a1ant_sw_mechanism(btcoexist, false);
+
+		bCommon = true;
+	} else if (!wifi_connected &&
+		(BT_8821A_1ANT_BT_STATUS_CONNECTED_IDLE != coex_dm->bt_status)) {
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE, "[BTCoex], Wifi non connected-idle + BT Busy!!\n");
+		halbtc8821a1ant_sw_mechanism(btcoexist, false);
+
+		bCommon = true;
+	} else {
+		if (wifi_busy) {
+			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE, "[BTCoex], Wifi Connected-Busy + BT Busy!!\n");
+		} else {
+			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE, "[BTCoex], Wifi Connected-Idle + BT Busy!!\n");
+		}
+
+		bCommon = false;
+	}
+
+	return bCommon;
+}
+
+static void
+halbtc8821a1ant_tdma_duration_adjust_for_acl(
+	struct btc_coexist *btcoexist,
+	u8 wifi_status
+	)
+{
+	static long		up, dn, m, n, wait_count;
+	long			result;   /* 0: no change, +1: increase WiFi duration, -1: decrease WiFi duration */
+	u8 retry_count = 0, bt_info_ext;
+
+	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW, "[BTCoex], TdmaDurationAdjustForAcl()\n");
+
+	if ((BT_8821A_1ANT_WIFI_STATUS_NON_CONNECTED_ASSO_AUTH_SCAN == wifi_status) ||
+		(BT_8821A_1ANT_WIFI_STATUS_CONNECTED_SCAN == wifi_status) ||
+		(BT_8821A_1ANT_WIFI_STATUS_CONNECTED_SPECIAL_PKT == wifi_status)) {
+		if (coex_dm->cur_ps_tdma != 1 &&
+			coex_dm->cur_ps_tdma != 2 &&
+			coex_dm->cur_ps_tdma != 3 &&
+			coex_dm->cur_ps_tdma != 9) {
+			halbtc8821a1ant_ps_tdma(btcoexist, NORMAL_EXEC, true, 9);
+			coex_dm->ps_tdma_du_adj_type = 9;
+
+			up = 0;
+			dn = 0;
+			m = 1;
+			n = 3;
+			result = 0;
+			wait_count = 0;
+		}
+		return;
+	}
+
+	if (!coex_dm->auto_tdma_adjust) {
+		coex_dm->auto_tdma_adjust = true;
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_DETAIL, "[BTCoex], first run TdmaDurationAdjust()!!\n");
+
+		halbtc8821a1ant_ps_tdma(btcoexist, NORMAL_EXEC, true, 2);
+		coex_dm->ps_tdma_du_adj_type = 2;
+		/*  */
+		up = 0;
+		dn = 0;
+		m = 1;
+		n = 3;
+		result = 0;
+		wait_count = 0;
+	} else {
+		/* accquire the BT TRx retry count from BT_Info byte2 */
+		retry_count = coex_sta->bt_retry_cnt;
+		bt_info_ext = coex_sta->bt_info_ext;
+		/* BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_DETAIL, "[BTCoex], retry_count = %d\n", retry_count)); */
+		/* BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_DETAIL, "[BTCoex], up =%d, dn =%d, m =%d, n =%d, wait_count =%d\n",  */
+		/*	up, dn, m, n, wait_count)); */
+		result = 0;
+		wait_count++;
+
+		if (retry_count == 0) {
+			/*  no retry in the last 2-second duration */
+			up++;
+			dn--;
+
+			if (dn <= 0)
+				dn = 0;
+
+			if (up >= n) {
+				wait_count = 0;
+				n = 3;
+				up = 0;
+				dn = 0;
+				result = 1;
+				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_DETAIL, "[BTCoex], Increase wifi duration!!\n");
+			}
+		} else if (retry_count <= 3) {
+			up--;
+			dn++;
+
+			if (up <= 0)
+				up = 0;
+
+			if (dn == 2) {
+				if (wait_count <= 2)
+					m++;
+				else
+					m = 1;
+				if (m >= 20)
+					m = 20;
+
+				n = 3*m;
+				up = 0;
+				dn = 0;
+				wait_count = 0;
+				result = -1;
+				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_DETAIL, "[BTCoex], Decrease wifi duration for retryCounter<3!!\n");
+			}
+		} else {
+			if (wait_count == 1)
+				m++;
+			else
+				m = 1;
+			if (m >= 20)
+				m = 20;
+
+			n = 3*m;
+			up = 0;
+			dn = 0;
+			wait_count = 0;
+			result = -1;
+			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_DETAIL, "[BTCoex], Decrease wifi duration for retryCounter>3!!\n");
+		}
+
+		if (result == -1) {
+			if ((BT_INFO_8821A_1ANT_A2DP_BASIC_RATE(bt_info_ext)) &&
+				((coex_dm->cur_ps_tdma == 1) || (coex_dm->cur_ps_tdma == 2))) {
+				halbtc8821a1ant_ps_tdma(btcoexist, NORMAL_EXEC, true, 9);
+				coex_dm->ps_tdma_du_adj_type = 9;
+			} else if (coex_dm->cur_ps_tdma == 1) {
+				halbtc8821a1ant_ps_tdma(btcoexist, NORMAL_EXEC, true, 2);
+				coex_dm->ps_tdma_du_adj_type = 2;
+			} else if (coex_dm->cur_ps_tdma == 2) {
+				halbtc8821a1ant_ps_tdma(btcoexist, NORMAL_EXEC, true, 9);
+				coex_dm->ps_tdma_du_adj_type = 9;
+			} else if (coex_dm->cur_ps_tdma == 9) {
+				halbtc8821a1ant_ps_tdma(btcoexist, NORMAL_EXEC, true, 11);
+				coex_dm->ps_tdma_du_adj_type = 11;
+			}
+		} else if (result == 1) {
+			if ((BT_INFO_8821A_1ANT_A2DP_BASIC_RATE(bt_info_ext)) &&
+				((coex_dm->cur_ps_tdma == 1) || (coex_dm->cur_ps_tdma == 2))) {
+				halbtc8821a1ant_ps_tdma(btcoexist, NORMAL_EXEC, true, 9);
+				coex_dm->ps_tdma_du_adj_type = 9;
+			} else if (coex_dm->cur_ps_tdma == 11) {
+				halbtc8821a1ant_ps_tdma(btcoexist, NORMAL_EXEC, true, 9);
+				coex_dm->ps_tdma_du_adj_type = 9;
+			} else if (coex_dm->cur_ps_tdma == 9) {
+				halbtc8821a1ant_ps_tdma(btcoexist, NORMAL_EXEC, true, 2);
+				coex_dm->ps_tdma_du_adj_type = 2;
+			} else if (coex_dm->cur_ps_tdma == 2) {
+				halbtc8821a1ant_ps_tdma(btcoexist, NORMAL_EXEC, true, 1);
+				coex_dm->ps_tdma_du_adj_type = 1;
+			}
+		} else {
+			/* no change */
+			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_DETAIL, "[BTCoex], ********** TDMA(on, %d) **********\n",
+				coex_dm->cur_ps_tdma);
+		}
+
+		if (coex_dm->cur_ps_tdma != 1 &&
+			coex_dm->cur_ps_tdma != 2 &&
+			coex_dm->cur_ps_tdma != 9 &&
+			coex_dm->cur_ps_tdma != 11) {
+			/*  recover to previous adjust type */
+			halbtc8821a1ant_ps_tdma(btcoexist, NORMAL_EXEC, true, coex_dm->ps_tdma_du_adj_type);
+		}
+	}
+}
+
+static void
+halbtc8821a1ant_ps_tdma_check_for_power_save_state(
+	struct btc_coexist *btcoexist,
+	bool new_ps_state
+	)
+{
+	u8 lps_mode = 0x0;
+
+	btcoexist->btc_get(btcoexist, BTC_GET_U1_LPS_MODE, &lps_mode);
+
+	if (lps_mode) {
+		/*  already under LPS state */
+		if (!new_ps_state) {
+			/*  will leave LPS state, turn off psTdma first */
+			halbtc8821a1ant_ps_tdma(btcoexist, NORMAL_EXEC, false, 0);
+		}
+	} else {
+		/*  NO PS state */
+		if (new_ps_state) {
+			/*  will enter LPS state, turn off psTdma first */
+			halbtc8821a1ant_ps_tdma(btcoexist, NORMAL_EXEC, false, 0);
+		} else {
+			/*  keep state under NO PS state, do nothing. */
+		}
+	}
+}
+
+static void
+halbtc8821a1ant_power_save_state(
+	struct btc_coexist *btcoexist,
+	u8 ps_type,
+	u8 lps_val,
+	u8 rpwm_val
+	)
+{
+	bool low_pwr_disable = false;
+
+	switch (ps_type) {
+	case BTC_PS_WIFI_NATIVE:
+		/*  recover to original 32k low power setting */
+		low_pwr_disable = false;
+		btcoexist->btc_set(btcoexist, BTC_SET_ACT_DISABLE_LOW_POWER, &low_pwr_disable);
+		btcoexist->btc_set(btcoexist, BTC_SET_ACT_NORMAL_LPS, NULL);
+		break;
+	case BTC_PS_LPS_ON:
+		halbtc8821a1ant_ps_tdma_check_for_power_save_state(btcoexist, true);
+		halbtc8821a1ant_lps_rpwm(btcoexist, NORMAL_EXEC, lps_val, rpwm_val);
+		/*  when coex force to enter LPS, do not enter 32k low power. */
+		low_pwr_disable = true;
+		btcoexist->btc_set(btcoexist, BTC_SET_ACT_DISABLE_LOW_POWER, &low_pwr_disable);
+		/*  power save must executed before psTdma. */
+		btcoexist->btc_set(btcoexist, BTC_SET_ACT_ENTER_LPS, NULL);
+		break;
+	case BTC_PS_LPS_OFF:
+		halbtc8821a1ant_ps_tdma_check_for_power_save_state(btcoexist, false);
+		btcoexist->btc_set(btcoexist, BTC_SET_ACT_LEAVE_LPS, NULL);
+		break;
+	default:
+		break;
+	}
+}
+
+static void
+halbtc8821a1ant_coex_under_5g(
+	struct btc_coexist *btcoexist
+	)
+{
+	halbtc8821a1ant_power_save_state(btcoexist, BTC_PS_WIFI_NATIVE, 0x0, 0x0);
+
+	halbtc8821a1ant_ignore_wlan_act(btcoexist, NORMAL_EXEC, true);
+
+	halbtc8821a1ant_ps_tdma(btcoexist, NORMAL_EXEC, false, 10);
+
+	halbtc8821a1ant_coex_table_with_type(btcoexist, NORMAL_EXEC, 0);
+
+	halbtc8821a1ant_limited_tx(btcoexist, NORMAL_EXEC, 0, 0, 0, 0);
+
+	halbtc8821a1ant_limited_rx(btcoexist, NORMAL_EXEC, false, false, 5);
+}
+
+static void
+halbtc8821a1ant_action_wifi_only(
+	struct btc_coexist *btcoexist
+	)
+{
+	halbtc8821a1ant_coex_table_with_type(btcoexist, NORMAL_EXEC, 0);
+	halbtc8821a1ant_ps_tdma(btcoexist, NORMAL_EXEC, false, 9);
+}
+
+static void
+halbtc8821a1ant_monitor_bt_enable_disable(
+	struct btc_coexist *btcoexist
+	)
+{
+	static bool pre_bt_disabled;
+	static u32 bt_disable_cnt;
+	bool bt_active = true, bt_disabled = false;
+
+	/*  This function check if bt is disabled */
+
+	if (coex_sta->high_priority_tx == 0 &&
+		coex_sta->high_priority_rx == 0 &&
+		coex_sta->low_priority_tx == 0 &&
+		coex_sta->low_priority_rx == 0) {
+		bt_active = false;
+	}
+	if (coex_sta->high_priority_tx == 0xffff &&
+	    coex_sta->high_priority_rx == 0xffff &&
+	    coex_sta->low_priority_tx == 0xffff &&
+	    coex_sta->low_priority_rx == 0xffff) {
+		bt_active = false;
+	}
+	if (bt_active) {
+		bt_disable_cnt = 0;
+		bt_disabled = false;
+		btcoexist->btc_set(btcoexist, BTC_SET_BL_BT_DISABLE,
+				   &bt_disabled);
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_MONITOR,
+			  "[BTCoex], BT is enabled !!\n");
+	} else {
+		bt_disable_cnt++;
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_MONITOR,
+			  "[BTCoex], bt all counters = 0, %d times!!\n",
+			  bt_disable_cnt);
+		if (bt_disable_cnt >= 2) {
+			bt_disabled = true;
+			btcoexist->btc_set(btcoexist, BTC_SET_BL_BT_DISABLE,
+					   &bt_disabled);
+			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_MONITOR,
+				  "[BTCoex], BT is disabled !!\n");
+			halbtc8821a1ant_action_wifi_only(btcoexist);
+		}
+	}
+	if (pre_bt_disabled != bt_disabled) {
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_MONITOR,
+			  "[BTCoex], BT is from %s to %s!!\n",
+			  (pre_bt_disabled ? "disabled" : "enabled"),
+			  (bt_disabled ? "disabled" : "enabled"));
+		pre_bt_disabled = bt_disabled;
+		if (bt_disabled) {
+			btcoexist->btc_set(btcoexist,
+					   BTC_SET_ACT_LEAVE_LPS, NULL);
+			btcoexist->btc_set(btcoexist,
+					   BTC_SET_ACT_NORMAL_LPS, NULL);
+		}
+	}
+}
+
+/*	Software Coex Mechanism start */
+static void halbtc8821a1ant_action_sco(struct btc_coexist *btcoexist)
+{
+	halbtc8821a1ant_sw_mechanism(btcoexist, true);
+}
+
+static void halbtc8821a1ant_action_hid(struct btc_coexist *btcoexist)
+{
+	halbtc8821a1ant_sw_mechanism(btcoexist, true);
+}
+
+/* A2DP only / PAN(EDR) only/ A2DP+PAN(HS) */
+static void halbtc8821a1ant_action_a2dp(struct btc_coexist *btcoexist)
+{
+	halbtc8821a1ant_sw_mechanism(btcoexist, false);
+}
+
+static void halbtc8821a1ant_action_a2dp_pan_hs(struct btc_coexist *btcoexist)
+{
+	halbtc8821a1ant_sw_mechanism(btcoexist, false);
+}
+
+static void halbtc8821a1ant_action_pan_edr(struct btc_coexist *btcoexist)
+{
+	halbtc8821a1ant_sw_mechanism(btcoexist, false);
+}
+
+/* PAN(HS) only */
+static void halbtc8821a1ant_action_pan_hs(struct btc_coexist *btcoexist)
+{
+	halbtc8821a1ant_sw_mechanism(btcoexist, false);
+}
+
+/* PAN(EDR)+A2DP */
+static void halbtc8821a1ant_action_pan_edr_a2dp(struct btc_coexist *btcoexist)
+{
+	halbtc8821a1ant_sw_mechanism(btcoexist, false);
+}
+
+static void halbtc8821a1ant_action_pan_edr_hid(struct btc_coexist *btcoexist)
+{
+	halbtc8821a1ant_sw_mechanism(btcoexist, true);
+}
+
+/*  HID+A2DP+PAN(EDR) */
+static void halbtc8821a1ant_action_hid_a2dp_pan_edr(struct btc_coexist *btcoexist)
+{
+	halbtc8821a1ant_sw_mechanism(btcoexist, true);
+}
+
+static void halbtc8821a1ant_action_hid_a2dp(struct btc_coexist *btcoexist)
+{
+	halbtc8821a1ant_sw_mechanism(btcoexist, true);
+}
+
+/*	Non-Software Coex Mechanism start */
+static void halbtc8821a1ant_action_hs(struct btc_coexist *btcoexist)
+{
+	halbtc8821a1ant_ps_tdma(btcoexist, NORMAL_EXEC, true, 5);
+	halbtc8821a1ant_coex_table_with_type(btcoexist, FORCE_EXEC, 2);
+}
+
+static void halbtc8821a1ant_action_bt_inquiry(struct btc_coexist *btcoexist)
+{
+	struct btc_bt_link_info *bt_link_info = &btcoexist->bt_link_info;
+	bool wifi_connected = false;
+
+	btcoexist->btc_get(btcoexist, BTC_GET_BL_WIFI_CONNECTED, &wifi_connected);
+
+	if (!wifi_connected) {
+		halbtc8821a1ant_power_save_state(btcoexist, BTC_PS_WIFI_NATIVE, 0x0, 0x0);
+		halbtc8821a1ant_ps_tdma(btcoexist, NORMAL_EXEC, true, 5);
+		halbtc8821a1ant_coex_table_with_type(btcoexist, NORMAL_EXEC, 1);
+	} else if ((bt_link_info->sco_exist) ||
+			(bt_link_info->hid_only)) {
+		/*  SCO/HID-only busy */
+		halbtc8821a1ant_power_save_state(btcoexist, BTC_PS_WIFI_NATIVE, 0x0, 0x0);
+		halbtc8821a1ant_ps_tdma(btcoexist, NORMAL_EXEC, true, 32);
+		halbtc8821a1ant_coex_table_with_type(btcoexist, NORMAL_EXEC, 1);
+	} else {
+		halbtc8821a1ant_power_save_state(btcoexist, BTC_PS_LPS_ON, 0x50, 0x4);
+		halbtc8821a1ant_ps_tdma(btcoexist, NORMAL_EXEC, true, 30);
+		halbtc8821a1ant_coex_table_with_type(btcoexist, NORMAL_EXEC, 1);
+	}
+}
+
+static void
+halbtc8821a1ant_action_bt_sco_hid_only_busy(
+	struct btc_coexist *btcoexist,
+	u8 wifi_status
+	)
+{
+	/*  tdma and coex table */
+	halbtc8821a1ant_ps_tdma(btcoexist, NORMAL_EXEC, true, 5);
+
+	if (BT_8821A_1ANT_WIFI_STATUS_NON_CONNECTED_ASSO_AUTH_SCAN == wifi_status)
+		halbtc8821a1ant_coex_table_with_type(btcoexist, NORMAL_EXEC, 1);
+	else
+		halbtc8821a1ant_coex_table_with_type(btcoexist, NORMAL_EXEC, 1);
+}
+
+static void action_wifi_connected_bt_acl_busy(struct btc_coexist *btcoexist, u8 wifi_status)
+{
+	u8 bt_rssi_state;
+
+	struct btc_bt_link_info *bt_link_info = &btcoexist->bt_link_info;
+	bt_rssi_state = halbtc8821a1ant_bt_rssi_state(2, 28, 0);
+
+	if (bt_link_info->hid_only)  {
+		/* HID */
+		halbtc8821a1ant_action_bt_sco_hid_only_busy(btcoexist, wifi_status);
+		coex_dm->auto_tdma_adjust = false;
+		return;
+	} else if (bt_link_info->a2dp_only) { /* A2DP */
+		if ((bt_rssi_state == BTC_RSSI_STATE_HIGH) ||
+			(bt_rssi_state == BTC_RSSI_STATE_STAY_HIGH)) {
+			 halbtc8821a1ant_tdma_duration_adjust_for_acl(btcoexist, wifi_status);
+		} else { /* for low BT RSSI */
+			halbtc8821a1ant_ps_tdma(btcoexist, NORMAL_EXEC, true, 11);
+			coex_dm->auto_tdma_adjust = false;
+		}
+
+		halbtc8821a1ant_coex_table_with_type(btcoexist, NORMAL_EXEC, 1);
+	} else if (bt_link_info->hid_exist && bt_link_info->a2dp_exist) {
+		/* HID+A2DP */
+		if ((bt_rssi_state == BTC_RSSI_STATE_HIGH) ||
+		    (bt_rssi_state == BTC_RSSI_STATE_STAY_HIGH)) {
+			halbtc8821a1ant_ps_tdma(btcoexist, NORMAL_EXEC, true, 14);
+			coex_dm->auto_tdma_adjust = false;
+		} else /* for low BT RSSI */ {
+			halbtc8821a1ant_ps_tdma(btcoexist, NORMAL_EXEC, true, 11);
+			coex_dm->auto_tdma_adjust = false;
+		}
+
+		halbtc8821a1ant_coex_table_with_type(btcoexist, NORMAL_EXEC, 1);
+	} else if ((bt_link_info->pan_only) || (bt_link_info->hid_exist && bt_link_info->pan_exist)) {
+		/* PAN(OPP, FTP), HID+PAN(OPP, FTP) */
+		halbtc8821a1ant_ps_tdma(btcoexist, NORMAL_EXEC, true, 3);
+		halbtc8821a1ant_coex_table_with_type(btcoexist, NORMAL_EXEC, 1);
+		coex_dm->auto_tdma_adjust = false;
+	} else if (((bt_link_info->a2dp_exist) && (bt_link_info->pan_exist)) ||
+		   (bt_link_info->hid_exist && bt_link_info->a2dp_exist &&
+		    bt_link_info->pan_exist)) {
+		/* A2DP+PAN(OPP, FTP), HID+A2DP+PAN(OPP, FTP) */
+		halbtc8821a1ant_ps_tdma(btcoexist, NORMAL_EXEC, true, 13);
+		halbtc8821a1ant_coex_table_with_type(btcoexist, NORMAL_EXEC, 1);
+		coex_dm->auto_tdma_adjust = false;
+	} else {
+		halbtc8821a1ant_ps_tdma(btcoexist, NORMAL_EXEC, true, 11);
+		halbtc8821a1ant_coex_table_with_type(btcoexist, NORMAL_EXEC, 1);
+		coex_dm->auto_tdma_adjust = false;
+	}
+}
+
+static void
+halbtc8821a1ant_action_wifi_not_connected(
+	struct btc_coexist *btcoexist
+	)
+{
+	/*  power save state */
+	halbtc8821a1ant_power_save_state(btcoexist, BTC_PS_WIFI_NATIVE, 0x0, 0x0);
+
+	/*  tdma and coex table	 */
+	halbtc8821a1ant_ps_tdma(btcoexist, NORMAL_EXEC, false, 8);
+	halbtc8821a1ant_coex_table_with_type(btcoexist, NORMAL_EXEC, 0);
+}
+
+static void wifi_not_connected_asso_auth_scan(struct btc_coexist *btcoexist)
+{
+	halbtc8821a1ant_power_save_state(btcoexist, BTC_PS_WIFI_NATIVE, 0x0, 0x0);
+
+	halbtc8821a1ant_ps_tdma(btcoexist, NORMAL_EXEC, true, 22);
+	halbtc8821a1ant_coex_table_with_type(btcoexist, NORMAL_EXEC, 1);
+}
+
+static void
+halbtc8821a1ant_action_wifi_connected_scan(
+	struct btc_coexist *btcoexist
+	)
+{
+	struct btc_bt_link_info *bt_link_info = &btcoexist->bt_link_info;
+
+	/*  power save state */
+	halbtc8821a1ant_power_save_state(btcoexist, BTC_PS_WIFI_NATIVE, 0x0, 0x0);
+
+	/*  tdma and coex table */
+	if (BT_8821A_1ANT_BT_STATUS_ACL_BUSY == coex_dm->bt_status) {
+		if (bt_link_info->a2dp_exist && bt_link_info->pan_exist) {
+			halbtc8821a1ant_ps_tdma(btcoexist, NORMAL_EXEC, true, 22);
+			halbtc8821a1ant_coex_table_with_type(btcoexist, NORMAL_EXEC, 1);
+		} else {
+		halbtc8821a1ant_ps_tdma(btcoexist, NORMAL_EXEC, true, 20);
+		halbtc8821a1ant_coex_table_with_type(btcoexist, NORMAL_EXEC, 1);
+	}
+	} else if ((BT_8821A_1ANT_BT_STATUS_SCO_BUSY == coex_dm->bt_status) ||
+			(BT_8821A_1ANT_BT_STATUS_ACL_SCO_BUSY == coex_dm->bt_status)) {
+		halbtc8821a1ant_action_bt_sco_hid_only_busy(btcoexist,
+			BT_8821A_1ANT_WIFI_STATUS_CONNECTED_SCAN);
+	} else {
+		halbtc8821a1ant_ps_tdma(btcoexist, NORMAL_EXEC, true, 20);
+		halbtc8821a1ant_coex_table_with_type(btcoexist, NORMAL_EXEC, 1);
+	}
+}
+
+static void action_wifi_connected_special_packet(struct btc_coexist *btcoexist)
+{
+	bool hs_connecting = false;
+	struct btc_bt_link_info *bt_link_info = &btcoexist->bt_link_info;
+
+	btcoexist->btc_get(btcoexist, BTC_GET_BL_HS_CONNECTING, &hs_connecting);
+
+	halbtc8821a1ant_power_save_state(btcoexist, BTC_PS_WIFI_NATIVE, 0x0, 0x0);
+
+	/*  tdma and coex table */
+	if (BT_8821A_1ANT_BT_STATUS_ACL_BUSY == coex_dm->bt_status) {
+		if (bt_link_info->a2dp_exist && bt_link_info->pan_exist) {
+			halbtc8821a1ant_ps_tdma(btcoexist, NORMAL_EXEC, true, 22);
+			halbtc8821a1ant_coex_table_with_type(btcoexist, NORMAL_EXEC, 1);
+		} else {
+			halbtc8821a1ant_ps_tdma(btcoexist, NORMAL_EXEC, true, 20);
+			halbtc8821a1ant_coex_table_with_type(btcoexist, NORMAL_EXEC, 1);
+		}
+	} else {
+		halbtc8821a1ant_ps_tdma(btcoexist, NORMAL_EXEC, true, 20);
+		halbtc8821a1ant_coex_table_with_type(btcoexist, NORMAL_EXEC, 1);
+	}
+}
+
+static void halbtc8821a1ant_action_wifi_connected(struct btc_coexist *btcoexist)
+{
+	bool wifi_busy = false;
+	bool scan = false, link = false, roam = false;
+	bool under_4way = false;
+
+	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE, "[BTCoex], CoexForWifiConnect() ===>\n");
+
+	btcoexist->btc_get(btcoexist, BTC_GET_BL_WIFI_4_WAY_PROGRESS, &under_4way);
+	if (under_4way) {
+		action_wifi_connected_special_packet(btcoexist);
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE, "[BTCoex], CoexForWifiConnect(), return for wifi is under 4way<===\n");
+		return;
+	}
+
+	btcoexist->btc_get(btcoexist, BTC_GET_BL_WIFI_SCAN, &scan);
+	btcoexist->btc_get(btcoexist, BTC_GET_BL_WIFI_LINK, &link);
+	btcoexist->btc_get(btcoexist, BTC_GET_BL_WIFI_ROAM, &roam);
+	if (scan || link || roam) {
+		halbtc8821a1ant_action_wifi_connected_scan(btcoexist);
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE, "[BTCoex], CoexForWifiConnect(), return for wifi is under scan<===\n");
+		return;
+	}
+
+	/*  power save state */
+	if (BT_8821A_1ANT_BT_STATUS_ACL_BUSY == coex_dm->bt_status && !btcoexist->bt_link_info.hid_only)
+		halbtc8821a1ant_power_save_state(btcoexist, BTC_PS_LPS_ON, 0x50, 0x4);
+	else
+		halbtc8821a1ant_power_save_state(btcoexist, BTC_PS_WIFI_NATIVE, 0x0, 0x0);
+
+	/*  tdma and coex table */
+	btcoexist->btc_get(btcoexist, BTC_GET_BL_WIFI_BUSY, &wifi_busy);
+	if (!wifi_busy) {
+		if (BT_8821A_1ANT_BT_STATUS_ACL_BUSY == coex_dm->bt_status) {
+			action_wifi_connected_bt_acl_busy(btcoexist,
+				BT_8821A_1ANT_WIFI_STATUS_CONNECTED_IDLE);
+		} else if ((BT_8821A_1ANT_BT_STATUS_SCO_BUSY == coex_dm->bt_status) ||
+			(BT_8821A_1ANT_BT_STATUS_ACL_SCO_BUSY == coex_dm->bt_status)) {
+			halbtc8821a1ant_action_bt_sco_hid_only_busy(btcoexist,
+				BT_8821A_1ANT_WIFI_STATUS_CONNECTED_IDLE);
+		} else {
+			halbtc8821a1ant_ps_tdma(btcoexist, NORMAL_EXEC, true, 5);
+			halbtc8821a1ant_coex_table_with_type(btcoexist, NORMAL_EXEC, 2);
+		}
+	} else {
+		if (BT_8821A_1ANT_BT_STATUS_ACL_BUSY == coex_dm->bt_status) {
+			action_wifi_connected_bt_acl_busy(btcoexist,
+				BT_8821A_1ANT_WIFI_STATUS_CONNECTED_BUSY);
+		} else if ((BT_8821A_1ANT_BT_STATUS_SCO_BUSY ==
+			    coex_dm->bt_status) ||
+			   (BT_8821A_1ANT_BT_STATUS_ACL_SCO_BUSY ==
+			    coex_dm->bt_status)) {
+			halbtc8821a1ant_action_bt_sco_hid_only_busy(btcoexist,
+				BT_8821A_1ANT_WIFI_STATUS_CONNECTED_BUSY);
+		} else {
+			halbtc8821a1ant_ps_tdma(btcoexist, NORMAL_EXEC,
+						true, 5);
+			halbtc8821a1ant_coex_table_with_type(btcoexist,
+							     NORMAL_EXEC, 2);
+		}
+	}
+}
+
+static void run_sw_coexist_mechanism(struct btc_coexist *btcoexist)
+{
+	u8 algorithm = 0;
+
+	algorithm = halbtc8821a1ant_action_algorithm(btcoexist);
+	coex_dm->cur_algorithm = algorithm;
+
+	if (!halbtc8821a1ant_is_common_action(btcoexist)) {
+		switch (coex_dm->cur_algorithm) {
+		case BT_8821A_1ANT_COEX_ALGO_SCO:
+			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+				  "[BTCoex], Action algorithm = SCO.\n");
+			halbtc8821a1ant_action_sco(btcoexist);
+			break;
+		case BT_8821A_1ANT_COEX_ALGO_HID:
+			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+				  "[BTCoex], Action algorithm = HID.\n");
+			halbtc8821a1ant_action_hid(btcoexist);
+			break;
+		case BT_8821A_1ANT_COEX_ALGO_A2DP:
+			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+				  "[BTCoex], Action algorithm = A2DP.\n");
+			halbtc8821a1ant_action_a2dp(btcoexist);
+			break;
+		case BT_8821A_1ANT_COEX_ALGO_A2DP_PANHS:
+			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+				  "[BTCoex], Action algorithm = A2DP+PAN(HS).\n");
+			halbtc8821a1ant_action_a2dp_pan_hs(btcoexist);
+			break;
+		case BT_8821A_1ANT_COEX_ALGO_PANEDR:
+			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+				  "[BTCoex], Action algorithm = PAN(EDR).\n");
+			halbtc8821a1ant_action_pan_edr(btcoexist);
+			break;
+		case BT_8821A_1ANT_COEX_ALGO_PANHS:
+			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+				  "[BTCoex], Action algorithm = HS mode.\n");
+			halbtc8821a1ant_action_pan_hs(btcoexist);
+			break;
+		case BT_8821A_1ANT_COEX_ALGO_PANEDR_A2DP:
+			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+				  "[BTCoex], Action algorithm = PAN+A2DP.\n");
+			halbtc8821a1ant_action_pan_edr_a2dp(btcoexist);
+			break;
+		case BT_8821A_1ANT_COEX_ALGO_PANEDR_HID:
+			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+				  "[BTCoex], Action algorithm = PAN(EDR)+HID.\n");
+			halbtc8821a1ant_action_pan_edr_hid(btcoexist);
+			break;
+		case BT_8821A_1ANT_COEX_ALGO_HID_A2DP_PANEDR:
+			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+				  "[BTCoex], Action algorithm = HID+A2DP+PAN.\n");
+			halbtc8821a1ant_action_hid_a2dp_pan_edr(btcoexist);
+			break;
+		case BT_8821A_1ANT_COEX_ALGO_HID_A2DP:
+			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+				  "[BTCoex], Action algorithm = HID+A2DP.\n");
+			halbtc8821a1ant_action_hid_a2dp(btcoexist);
+			break;
+		default:
+			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+				  "[BTCoex], Action algorithm = coexist All Off!!\n");
+			break;
+		}
+		coex_dm->pre_algorithm = coex_dm->cur_algorithm;
+	}
+}
+
+static void halbtc8821a1ant_run_coexist_mechanism(struct btc_coexist *btcoexist)
+{
+	struct btc_bt_link_info *bt_link_info = &btcoexist->bt_link_info;
+	bool wifi_connected = false, bt_hs_on = false;
+	bool increase_scan_dev_num = false;
+	bool bt_ctrl_agg_buf_size = false;
+	u8 agg_buf_size = 5;
+	u8 wifi_rssi_state = BTC_RSSI_STATE_HIGH;
+	bool wifi_under_5g = false;
+
+	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+		  "[BTCoex], RunCoexistMechanism() ===>\n");
+
+	if (btcoexist->manual_control) {
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+			  "[BTCoex], RunCoexistMechanism(), return for Manual CTRL <===\n");
+		return;
+	}
+
+	if (btcoexist->stop_coex_dm) {
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+			  "[BTCoex], RunCoexistMechanism(), return for Stop Coex DM <===\n");
+		return;
+	}
+
+	if (coex_sta->under_ips) {
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+			  "[BTCoex], wifi is under IPS !!!\n");
+		return;
+	}
+
+	btcoexist->btc_get(btcoexist, BTC_GET_BL_WIFI_UNDER_5G,
+			   &wifi_under_5g);
+	if (wifi_under_5g) {
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+			  "[BTCoex], RunCoexistMechanism(), return for 5G <===\n");
+		halbtc8821a1ant_coex_under_5g(btcoexist);
+		return;
+	}
+
+	if ((BT_8821A_1ANT_BT_STATUS_ACL_BUSY == coex_dm->bt_status) ||
+	    (BT_8821A_1ANT_BT_STATUS_SCO_BUSY == coex_dm->bt_status) ||
+	    (BT_8821A_1ANT_BT_STATUS_ACL_SCO_BUSY == coex_dm->bt_status)) {
+		increase_scan_dev_num = true;
+	}
+
+	btcoexist->btc_set(btcoexist, BTC_SET_BL_INC_SCAN_DEV_NUM,
+			   &increase_scan_dev_num);
+
+	btcoexist->btc_get(btcoexist, BTC_GET_BL_WIFI_CONNECTED,
+			   &wifi_connected);
+
+	if (!bt_link_info->sco_exist && !bt_link_info->hid_exist) {
+		halbtc8821a1ant_limited_tx(btcoexist, NORMAL_EXEC, 0, 0, 0, 0);
+	} else {
+		if (wifi_connected) {
+			wifi_rssi_state = Wifi_rssi_state(btcoexist, 1, 2,
+							  30, 0);
+			if ((wifi_rssi_state == BTC_RSSI_STATE_HIGH) ||
+			    (wifi_rssi_state == BTC_RSSI_STATE_STAY_HIGH))
+				halbtc8821a1ant_limited_tx(btcoexist,
+							   NORMAL_EXEC, 1, 1,
+							   1, 1);
+			else
+				halbtc8821a1ant_limited_tx(btcoexist,
+							   NORMAL_EXEC, 1, 1,
+							   1, 1);
+		} else {
+			halbtc8821a1ant_limited_tx(btcoexist, NORMAL_EXEC,
+						   0, 0, 0, 0);
+		}
+	}
+
+	if (bt_link_info->sco_exist) {
+		bt_ctrl_agg_buf_size = true;
+		agg_buf_size = 0x3;
+	} else if (bt_link_info->hid_exist) {
+		bt_ctrl_agg_buf_size = true;
+		agg_buf_size = 0x5;
+	} else if (bt_link_info->a2dp_exist || bt_link_info->pan_exist) {
+		bt_ctrl_agg_buf_size = true;
+		agg_buf_size = 0x8;
+	}
+	halbtc8821a1ant_limited_rx(btcoexist, NORMAL_EXEC, false,
+				   bt_ctrl_agg_buf_size, agg_buf_size);
+
+	run_sw_coexist_mechanism(btcoexist);
+
+	btcoexist->btc_get(btcoexist, BTC_GET_BL_HS_OPERATION, &bt_hs_on);
+	if (coex_sta->c2h_bt_inquiry_page) {
+		halbtc8821a1ant_action_bt_inquiry(btcoexist);
+		return;
+	} else if (bt_hs_on) {
+		halbtc8821a1ant_action_hs(btcoexist);
+		return;
+	}
+
+	if (!wifi_connected) {
+		bool scan = false, link = false, roam = false;
+
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE, "[BTCoex], wifi is non connected-idle !!!\n");
+
+		btcoexist->btc_get(btcoexist, BTC_GET_BL_WIFI_SCAN, &scan);
+		btcoexist->btc_get(btcoexist, BTC_GET_BL_WIFI_LINK, &link);
+		btcoexist->btc_get(btcoexist, BTC_GET_BL_WIFI_ROAM, &roam);
+
+		if (scan || link || roam)
+			wifi_not_connected_asso_auth_scan(btcoexist);
+		else
+			halbtc8821a1ant_action_wifi_not_connected(btcoexist);
+	} else {
+		/*  wifi LPS/Busy */
+		halbtc8821a1ant_action_wifi_connected(btcoexist);
+	}
+}
+
+static void halbtc8821a1ant_init_coex_dm(struct btc_coexist *btcoexist)
+{
+	/*  force to reset coex mechanism */
+	/*  sw all off */
+	halbtc8821a1ant_sw_mechanism(btcoexist, false);
+
+	halbtc8821a1ant_ps_tdma(btcoexist, FORCE_EXEC, false, 8);
+	halbtc8821a1ant_coex_table_with_type(btcoexist, FORCE_EXEC, 0);
+}
+
+static void halbtc8821a1ant_init_hw_config(struct btc_coexist *btcoexist,
+					   bool back_up)
+{
+	u8 u1_tmp = 0;
+	bool wifi_under_5g = false;
+
+	BTC_PRINT(BTC_MSG_INTERFACE, INTF_INIT,
+		  "[BTCoex], 1Ant Init HW Config!!\n");
+
+	if (back_up) {
+		coex_dm->backup_arfr_cnt1 =
+			btcoexist->btc_read_4byte(btcoexist, 0x430);
+		coex_dm->backup_arfr_cnt2 =
+			btcoexist->btc_read_4byte(btcoexist, 0x434);
+		coex_dm->backup_retry_limit =
+			btcoexist->btc_read_2byte(btcoexist, 0x42a);
+		coex_dm->backup_ampdu_max_time =
+			btcoexist->btc_read_1byte(btcoexist, 0x456);
+	}
+
+	/*  0x790[5:0] = 0x5 */
+	u1_tmp = btcoexist->btc_read_1byte(btcoexist, 0x790);
+	u1_tmp &= 0xc0;
+	u1_tmp |= 0x5;
+	btcoexist->btc_write_1byte(btcoexist, 0x790, u1_tmp);
+
+	btcoexist->btc_get(btcoexist, BTC_GET_BL_WIFI_UNDER_5G, &wifi_under_5g);
+
+	/* Antenna config */
+	if (wifi_under_5g)
+		halbtc8821a1ant_set_ant_path(btcoexist, BTC_ANT_PATH_BT,
+					     true, false);
+	else
+		halbtc8821a1ant_set_ant_path(btcoexist, BTC_ANT_PATH_PTA,
+					     true, false);
+	/*  PTA parameter */
+	halbtc8821a1ant_coex_table_with_type(btcoexist, FORCE_EXEC, 0);
+
+	/*  Enable counter statistics */
+	/* 0x76e[3] = 1, WLAN_Act control by PTA */
+	btcoexist->btc_write_1byte(btcoexist, 0x76e, 0xc);
+	btcoexist->btc_write_1byte(btcoexist, 0x778, 0x3);
+	btcoexist->btc_write_1byte_bitmask(btcoexist, 0x40, 0x20, 0x1);
+}
+
+/*  */
+/*  work around function start with wa_halbtc8821a1ant_ */
+/*  */
+/*  */
+/*  extern function start with EXhalbtc8821a1ant_ */
+/*  */
+void
+ex_halbtc8821a1ant_init_hwconfig(
+	struct btc_coexist *btcoexist
+	)
+{
+	halbtc8821a1ant_init_hw_config(btcoexist, true);
+}
+
+void
+ex_halbtc8821a1ant_init_coex_dm(
+	struct btc_coexist *btcoexist
+	)
+{
+	BTC_PRINT(BTC_MSG_INTERFACE, INTF_INIT, "[BTCoex], Coex Mechanism Init!!\n");
+
+	btcoexist->stop_coex_dm = false;
+
+	halbtc8821a1ant_init_coex_dm(btcoexist);
+
+	halbtc8821a1ant_query_bt_info(btcoexist);
+}
+
+void ex_halbtc8821a1ant_display_coex_info(struct btc_coexist *btcoexist)
+{
+	struct btc_board_info *board_info = &btcoexist->board_info;
+	struct btc_stack_info *stack_info = &btcoexist->stack_info;
+	struct btc_bt_link_info *bt_link_info = &btcoexist->bt_link_info;
+	u8 *cli_buf = btcoexist->cli_buf;
+	u8 u1_tmp[4], i, bt_info_ext, ps_tdma_case = 0;
+	u16 u2_tmp[4];
+	u32 u4_tmp[4];
+	bool roam = false, scan = false, link = false, wifi_under_5g = false;
+	bool bt_hs_on = false, wifi_busy = false;
+	long wifi_rssi = 0, bt_hs_rssi = 0;
+	u32 wifi_bw, wifi_traffic_dir;
+	u8 wifi_dot11_chnl, wifi_hs_chnl;
+	u32 fw_ver = 0, bt_patch_ver = 0;
+
+	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE,
+		   "\n ============[BT Coexist info] ============");
+	CL_PRINTF(cli_buf);
+
+	if (btcoexist->manual_control) {
+		CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE,
+			   "\n ============[Under Manual Control] ============");
+		CL_PRINTF(cli_buf);
+		CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE,
+			   "\n ==========================================");
+		CL_PRINTF(cli_buf);
+	}
+	if (btcoexist->stop_coex_dm) {
+		CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE,
+			   "\n ============[Coex is STOPPED] ============");
+		CL_PRINTF(cli_buf);
+		CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE,
+			   "\n ==========================================");
+		CL_PRINTF(cli_buf);
+	}
+
+	if (!board_info->bt_exist) {
+		CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\n BT not exists !!!");
+		CL_PRINTF(cli_buf);
+		return;
+	}
+
+	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\n %-35s = %d/ %d/ %d",
+		   "Ant PG Num/ Ant Mech/ Ant Pos: ",
+		   board_info->pg_ant_num, board_info->btdm_ant_num,
+		   board_info->btdm_ant_pos);
+	CL_PRINTF(cli_buf);
+
+	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\n %-35s = %s / %d",
+		   "BT stack/ hci ext ver",
+		   ((stack_info->profile_notified) ? "Yes" : "No"),
+		   stack_info->hci_version);
+	CL_PRINTF(cli_buf);
+
+	btcoexist->btc_get(btcoexist, BTC_GET_U4_BT_PATCH_VER, &bt_patch_ver);
+	btcoexist->btc_get(btcoexist, BTC_GET_U4_WIFI_FW_VER, &fw_ver);
+	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\n %-35s = %d_%x/ 0x%x/ 0x%x(%d)",
+		   "CoexVer/ FwVer/ PatchVer",
+		   glcoex_ver_date_8821a_1ant, glcoex_ver_8821a_1ant, fw_ver,
+		   bt_patch_ver, bt_patch_ver);
+	CL_PRINTF(cli_buf);
+
+	btcoexist->btc_get(btcoexist, BTC_GET_BL_HS_OPERATION, &bt_hs_on);
+	btcoexist->btc_get(btcoexist, BTC_GET_U1_WIFI_DOT11_CHNL,
+			   &wifi_dot11_chnl);
+	btcoexist->btc_get(btcoexist, BTC_GET_U1_WIFI_HS_CHNL, &wifi_hs_chnl);
+	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\n %-35s = %d / %d(%d)",
+		   "Dot11 channel / HsChnl(HsMode)",
+		   wifi_dot11_chnl, wifi_hs_chnl, bt_hs_on);
+	CL_PRINTF(cli_buf);
+
+	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\n %-35s = %02x %02x %02x ",
+		   "H2C Wifi inform bt chnl Info",
+		   coex_dm->wifi_chnl_info[0], coex_dm->wifi_chnl_info[1],
+		   coex_dm->wifi_chnl_info[2]);
+	CL_PRINTF(cli_buf);
+
+	btcoexist->btc_get(btcoexist, BTC_GET_S4_WIFI_RSSI, &wifi_rssi);
+	btcoexist->btc_get(btcoexist, BTC_GET_S4_HS_RSSI, &bt_hs_rssi);
+	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\n %-35s = %d/ %d",
+		   "Wifi rssi/ HS rssi",
+		   (int)wifi_rssi, (int)bt_hs_rssi);
+	CL_PRINTF(cli_buf);
+
+	btcoexist->btc_get(btcoexist, BTC_GET_BL_WIFI_SCAN, &scan);
+	btcoexist->btc_get(btcoexist, BTC_GET_BL_WIFI_LINK, &link);
+	btcoexist->btc_get(btcoexist, BTC_GET_BL_WIFI_ROAM, &roam);
+	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\n %-35s = %d/ %d/ %d ",
+		   "Wifi link/ roam/ scan",
+		   link, roam, scan);
+	CL_PRINTF(cli_buf);
+
+	btcoexist->btc_get(btcoexist, BTC_GET_BL_WIFI_UNDER_5G, &wifi_under_5g);
+	btcoexist->btc_get(btcoexist, BTC_GET_U4_WIFI_BW, &wifi_bw);
+	btcoexist->btc_get(btcoexist, BTC_GET_BL_WIFI_BUSY, &wifi_busy);
+	btcoexist->btc_get(btcoexist, BTC_GET_U4_WIFI_TRAFFIC_DIRECTION,
+			   &wifi_traffic_dir);
+	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\n %-35s = %s / %s/ %s ",
+		   "Wifi status",
+		   (wifi_under_5g ? "5G" : "2.4G"),
+		   ((BTC_WIFI_BW_LEGACY == wifi_bw) ? "Legacy" :
+		    (((BTC_WIFI_BW_HT40 == wifi_bw) ? "HT40" : "HT20"))),
+		   ((!wifi_busy) ? "idle" :
+		    ((BTC_WIFI_TRAFFIC_TX == wifi_traffic_dir) ?
+		     "uplink" : "downlink")));
+	CL_PRINTF(cli_buf);
+	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE,
+		   "\n %-35s = [%s/ %d/ %d] ", "BT [status/ rssi/ retryCnt]",
+		   ((btcoexist->bt_info.bt_disabled) ? ("disabled") :
+		    ((coex_sta->c2h_bt_inquiry_page) ? ("inquiry/page scan") :
+		     ((BT_8821A_1ANT_BT_STATUS_NON_CONNECTED_IDLE ==
+		       coex_dm->bt_status) ? "non-connected idle" :
+		      ((BT_8821A_1ANT_BT_STATUS_CONNECTED_IDLE ==
+		       coex_dm->bt_status) ? "connected-idle" : "busy")))),
+		   coex_sta->bt_rssi, coex_sta->bt_retry_cnt);
+	CL_PRINTF(cli_buf);
+
+	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\n %-35s = %d / %d / %d / %d",
+		   "SCO/HID/PAN/A2DP",
+		   bt_link_info->sco_exist, bt_link_info->hid_exist,
+		   bt_link_info->pan_exist, bt_link_info->a2dp_exist);
+	CL_PRINTF(cli_buf);
+	btcoexist->btc_disp_dbg_msg(btcoexist, BTC_DBG_DISP_BT_LINK_INFO);
+
+	bt_info_ext = coex_sta->bt_info_ext;
+	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\n %-35s = %s",
+		   "BT Info A2DP rate",
+		   (bt_info_ext & BIT(0)) ? "Basic rate" : "EDR rate");
+	CL_PRINTF(cli_buf);
+
+	for (i = 0; i < BT_INFO_SRC_8821A_1ANT_MAX; i++) {
+		if (coex_sta->bt_info_c2h_cnt[i]) {
+			CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE,
+				   "\n %-35s = %02x %02x %02x %02x %02x %02x %02x(%d)",
+				   glbt_info_src_8821a_1ant[i],
+				   coex_sta->bt_info_c2h[i][0],
+				   coex_sta->bt_info_c2h[i][1],
+				   coex_sta->bt_info_c2h[i][2],
+				   coex_sta->bt_info_c2h[i][3],
+				   coex_sta->bt_info_c2h[i][4],
+				   coex_sta->bt_info_c2h[i][5],
+				   coex_sta->bt_info_c2h[i][6],
+				   coex_sta->bt_info_c2h_cnt[i]);
+			CL_PRINTF(cli_buf);
+		}
+	}
+	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\n %-35s = %s/%s, (0x%x/0x%x)",
+		   "PS state, IPS/LPS, (lps/rpwm)",
+		   ((coex_sta->under_ips ? "IPS ON" : "IPS OFF")),
+		   ((coex_sta->under_lps ? "LPS ON" : "LPS OFF")),
+		   btcoexist->bt_info.lps_val,
+		   btcoexist->bt_info.rpwm_val);
+	CL_PRINTF(cli_buf);
+	btcoexist->btc_disp_dbg_msg(btcoexist, BTC_DBG_DISP_FW_PWR_MODE_CMD);
+
+	if (!btcoexist->manual_control) {
+		/*  Sw mechanism	 */
+		CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE,
+			   "\n %-35s", "============[Sw mechanism] ============");
+		CL_PRINTF(cli_buf);
+
+		CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE,
+			   "\n %-35s = %d", "SM[LowPenaltyRA]",
+			   coex_dm->cur_low_penalty_ra);
+		CL_PRINTF(cli_buf);
+
+		CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE,
+			   "\n %-35s = %s/ %s/ %d ", "DelBA/ BtCtrlAgg/ AggSize",
+			   (btcoexist->bt_info.reject_agg_pkt ? "Yes" : "No"),
+			   (btcoexist->bt_info.b_bt_ctrl_buf_size ?
+			    "Yes" : "No"),
+			   btcoexist->bt_info.agg_buf_size);
+		CL_PRINTF(cli_buf);
+		CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE,
+			   "\n %-35s = 0x%x ", "Rate Mask",
+			   btcoexist->bt_info.ra_mask);
+		CL_PRINTF(cli_buf);
+
+		/*  Fw mechanism */
+		CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\n %-35s",
+			   "============[Fw mechanism] ============");
+		CL_PRINTF(cli_buf);
+
+		ps_tdma_case = coex_dm->cur_ps_tdma;
+		CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE,
+			   "\n %-35s = %02x %02x %02x %02x %02x case-%d (auto:%d)",
+			   "PS TDMA",
+			   coex_dm->ps_tdma_para[0], coex_dm->ps_tdma_para[1],
+			   coex_dm->ps_tdma_para[2], coex_dm->ps_tdma_para[3],
+			   coex_dm->ps_tdma_para[4], ps_tdma_case,
+			   coex_dm->auto_tdma_adjust);
+		CL_PRINTF(cli_buf);
+
+		CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\n %-35s = 0x%x ",
+			   "Latest error condition(should be 0)",
+			   coex_dm->error_condition);
+		CL_PRINTF(cli_buf);
+
+		CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\n %-35s = %d ",
+			   "IgnWlanAct",
+			   coex_dm->cur_ignore_wlan_act);
+		CL_PRINTF(cli_buf);
+	}
+
+	/*  Hw setting		 */
+	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\n %-35s",
+		   "============[Hw setting] ============");
+	CL_PRINTF(cli_buf);
+
+	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\n %-35s = 0x%x/0x%x/0x%x/0x%x",
+		   "backup ARFR1/ARFR2/RL/AMaxTime",
+		   coex_dm->backup_arfr_cnt1, coex_dm->backup_arfr_cnt2,
+		   coex_dm->backup_retry_limit, coex_dm->backup_ampdu_max_time);
+	CL_PRINTF(cli_buf);
+
+	u4_tmp[0] = btcoexist->btc_read_4byte(btcoexist, 0x430);
+	u4_tmp[1] = btcoexist->btc_read_4byte(btcoexist, 0x434);
+	u2_tmp[0] = btcoexist->btc_read_2byte(btcoexist, 0x42a);
+	u1_tmp[0] = btcoexist->btc_read_1byte(btcoexist, 0x456);
+	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\n %-35s = 0x%x/0x%x/0x%x/0x%x",
+		   "0x430/0x434/0x42a/0x456",
+		   u4_tmp[0], u4_tmp[1], u2_tmp[0], u1_tmp[0]);
+	CL_PRINTF(cli_buf);
+
+	u1_tmp[0] = btcoexist->btc_read_1byte(btcoexist, 0x778);
+	u4_tmp[0] = btcoexist->btc_read_4byte(btcoexist, 0xc58);
+	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE,
+		   "\n %-35s = 0x%x/ 0x%x", "0x778/ 0xc58[29:25]",
+		   u1_tmp[0], (u4_tmp[0]&0x3e000000) >> 25);
+	CL_PRINTF(cli_buf);
+
+	u1_tmp[0] = btcoexist->btc_read_1byte(btcoexist, 0x8db);
+	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\n %-35s = 0x%x", "0x8db[6:5]",
+		   ((u1_tmp[0]&0x60)>>5));
+	CL_PRINTF(cli_buf);
+
+	u1_tmp[0] = btcoexist->btc_read_1byte(btcoexist, 0x975);
+	u4_tmp[0] = btcoexist->btc_read_4byte(btcoexist, 0xcb4);
+	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\n %-35s = 0x%x/ 0x%x/ 0x%x",
+		   "0xcb4[29:28]/0xcb4[7:0]/0x974[9:8]",
+		   (u4_tmp[0]&0x30000000)>>28, u4_tmp[0]&0xff, u1_tmp[0] & 0x3);
+	CL_PRINTF(cli_buf);
+
+	u1_tmp[0] = btcoexist->btc_read_1byte(btcoexist, 0x40);
+	u4_tmp[0] = btcoexist->btc_read_4byte(btcoexist, 0x4c);
+	u1_tmp[1] = btcoexist->btc_read_1byte(btcoexist, 0x64);
+	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\n %-35s = 0x%x/ 0x%x/ 0x%x",
+		   "0x40/0x4c[24:23]/0x64[0]",
+		   u1_tmp[0], ((u4_tmp[0]&0x01800000)>>23), u1_tmp[1]&0x1);
+	CL_PRINTF(cli_buf);
+
+	u4_tmp[0] = btcoexist->btc_read_4byte(btcoexist, 0x550);
+	u1_tmp[0] = btcoexist->btc_read_1byte(btcoexist, 0x522);
+	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\n %-35s = 0x%x/ 0x%x",
+		   "0x550(bcn ctrl)/0x522",
+		   u4_tmp[0], u1_tmp[0]);
+	CL_PRINTF(cli_buf);
+
+	u4_tmp[0] = btcoexist->btc_read_4byte(btcoexist, 0xc50);
+	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\n %-35s = 0x%x", "0xc50(dig)",
+		   u4_tmp[0]&0xff);
+	CL_PRINTF(cli_buf);
+
+	u4_tmp[0] = btcoexist->btc_read_4byte(btcoexist, 0xf48);
+	u1_tmp[0] = btcoexist->btc_read_1byte(btcoexist, 0xa5d);
+	u1_tmp[1] = btcoexist->btc_read_1byte(btcoexist, 0xa5c);
+	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\n %-35s = 0x%x/ 0x%x",
+		   "OFDM-FA/ CCK-FA",
+		   u4_tmp[0], (u1_tmp[0]<<8) + u1_tmp[1]);
+	CL_PRINTF(cli_buf);
+
+	u4_tmp[0] = btcoexist->btc_read_4byte(btcoexist, 0x6c0);
+	u4_tmp[1] = btcoexist->btc_read_4byte(btcoexist, 0x6c4);
+	u4_tmp[2] = btcoexist->btc_read_4byte(btcoexist, 0x6c8);
+	u1_tmp[0] = btcoexist->btc_read_1byte(btcoexist, 0x6cc);
+	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE,
+		   "\n %-35s = 0x%x/ 0x%x/ 0x%x/ 0x%x",
+		   "0x6c0/0x6c4/0x6c8/0x6cc(coexTable)",
+		   u4_tmp[0], u4_tmp[1], u4_tmp[2], u1_tmp[0]);
+	CL_PRINTF(cli_buf);
+
+	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\n %-35s = %d/ %d",
+		   "0x770(high-pri rx/tx)",
+		   coex_sta->high_priority_rx, coex_sta->high_priority_tx);
+	CL_PRINTF(cli_buf);
+	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\n %-35s = %d/ %d",
+		   "0x774(low-pri rx/tx)",
+		   coex_sta->low_priority_rx, coex_sta->low_priority_tx);
+	CL_PRINTF(cli_buf);
+#if (BT_AUTO_REPORT_ONLY_8821A_1ANT == 1)
+	halbtc8821a1ant_monitor_bt_ctr(btcoexist);
+#endif
+	btcoexist->btc_disp_dbg_msg(btcoexist, BTC_DBG_DISP_COEX_STATISTICS);
+}
+
+void ex_halbtc8821a1ant_ips_notify(struct btc_coexist *btcoexist, u8 type)
+{
+	if (btcoexist->manual_control || btcoexist->stop_coex_dm)
+		return;
+
+	if (BTC_IPS_ENTER == type) {
+		BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
+			  "[BTCoex], IPS ENTER notify\n");
+		coex_sta->under_ips = true;
+		halbtc8821a1ant_set_ant_path(btcoexist, BTC_ANT_PATH_BT,
+					     false, true);
+		/* set PTA control */
+		halbtc8821a1ant_ps_tdma(btcoexist, NORMAL_EXEC, false, 8);
+		halbtc8821a1ant_coex_table_with_type(btcoexist, NORMAL_EXEC, 0);
+	} else if (BTC_IPS_LEAVE == type) {
+		BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
+			  "[BTCoex], IPS LEAVE notify\n");
+		coex_sta->under_ips = false;
+
+		halbtc8821a1ant_run_coexist_mechanism(btcoexist);
+	}
+}
+
+void ex_halbtc8821a1ant_lps_notify(struct btc_coexist *btcoexist, u8 type)
+{
+	if (btcoexist->manual_control || btcoexist->stop_coex_dm)
+		return;
+
+	if (BTC_LPS_ENABLE == type) {
+		BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
+			  "[BTCoex], LPS ENABLE notify\n");
+		coex_sta->under_lps = true;
+	} else if (BTC_LPS_DISABLE == type) {
+		BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
+			  "[BTCoex], LPS DISABLE notify\n");
+		coex_sta->under_lps = false;
+	}
+}
+
+void ex_halbtc8821a1ant_scan_notify(struct btc_coexist *btcoexist, u8 type)
+{
+	bool wifi_connected = false, bt_hs_on = false;
+
+	if (btcoexist->manual_control ||
+	    btcoexist->stop_coex_dm ||
+	    btcoexist->bt_info.bt_disabled)
+		return;
+
+	btcoexist->btc_get(btcoexist, BTC_GET_BL_HS_OPERATION, &bt_hs_on);
+	btcoexist->btc_get(btcoexist, BTC_GET_BL_WIFI_CONNECTED,
+			   &wifi_connected);
+
+	halbtc8821a1ant_query_bt_info(btcoexist);
+
+	if (coex_sta->c2h_bt_inquiry_page) {
+		halbtc8821a1ant_action_bt_inquiry(btcoexist);
+		return;
+	} else if (bt_hs_on) {
+		halbtc8821a1ant_action_hs(btcoexist);
+		return;
+	}
+
+	if (BTC_SCAN_START == type) {
+		BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
+			  "[BTCoex], SCAN START notify\n");
+		if (!wifi_connected) {
+			/*  non-connected scan */
+			wifi_not_connected_asso_auth_scan(btcoexist);
+		} else {
+			/*  wifi is connected */
+			halbtc8821a1ant_action_wifi_connected_scan(btcoexist);
+		}
+	} else if (BTC_SCAN_FINISH == type) {
+		BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
+			  "[BTCoex], SCAN FINISH notify\n");
+		if (!wifi_connected)	/*  non-connected scan */
+			halbtc8821a1ant_action_wifi_not_connected(btcoexist);
+		else
+			halbtc8821a1ant_action_wifi_connected(btcoexist);
+	}
+}
+
+void ex_halbtc8821a1ant_connect_notify(struct btc_coexist *btcoexist, u8 type)
+{
+	bool wifi_connected = false, bt_hs_on = false;
+
+	if (btcoexist->manual_control ||
+	    btcoexist->stop_coex_dm ||
+	    btcoexist->bt_info.bt_disabled)
+		return;
+
+	btcoexist->btc_get(btcoexist, BTC_GET_BL_HS_OPERATION, &bt_hs_on);
+	if (coex_sta->c2h_bt_inquiry_page) {
+		halbtc8821a1ant_action_bt_inquiry(btcoexist);
+		return;
+	} else if (bt_hs_on) {
+		halbtc8821a1ant_action_hs(btcoexist);
+		return;
+	}
+
+	if (BTC_ASSOCIATE_START == type) {
+		BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
+			  "[BTCoex], CONNECT START notify\n");
+		wifi_not_connected_asso_auth_scan(btcoexist);
+	} else if (BTC_ASSOCIATE_FINISH == type) {
+		BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
+			  "[BTCoex], CONNECT FINISH notify\n");
+
+		btcoexist->btc_get(btcoexist, BTC_GET_BL_WIFI_CONNECTED,
+				   &wifi_connected);
+		if (!wifi_connected) /*  non-connected scan */
+			halbtc8821a1ant_action_wifi_not_connected(btcoexist);
+		else
+			halbtc8821a1ant_action_wifi_connected(btcoexist);
+	}
+}
+
+void ex_halbtc8821a1ant_media_status_notify(struct btc_coexist *btcoexist,
+					    u8 type)
+{
+	u8 h2c_parameter[3] = {0};
+	u32 wifi_bw;
+	u8 wifi_central_chnl;
+
+	if (btcoexist->manual_control ||
+	    btcoexist->stop_coex_dm ||
+	    btcoexist->bt_info.bt_disabled)
+		return;
+
+	if (BTC_MEDIA_CONNECT == type)
+		BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
+			  "[BTCoex], MEDIA connect notify\n");
+	else
+		BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
+			  "[BTCoex], MEDIA disconnect notify\n");
+
+	/*  only 2.4G we need to inform bt the chnl mask */
+	btcoexist->btc_get(btcoexist, BTC_GET_U1_WIFI_CENTRAL_CHNL,
+			   &wifi_central_chnl);
+	if ((BTC_MEDIA_CONNECT == type) &&
+	    (wifi_central_chnl <= 14)) {
+		/* h2c_parameter[0] = 0x1; */
+		h2c_parameter[0] = 0x0;
+		h2c_parameter[1] = wifi_central_chnl;
+		btcoexist->btc_get(btcoexist, BTC_GET_U4_WIFI_BW, &wifi_bw);
+		if (BTC_WIFI_BW_HT40 == wifi_bw)
+			h2c_parameter[2] = 0x30;
+		else
+			h2c_parameter[2] = 0x20;
+	}
+
+	coex_dm->wifi_chnl_info[0] = h2c_parameter[0];
+	coex_dm->wifi_chnl_info[1] = h2c_parameter[1];
+	coex_dm->wifi_chnl_info[2] = h2c_parameter[2];
+
+	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_EXEC,
+		  "[BTCoex], FW write 0x66 = 0x%x\n",
+		  h2c_parameter[0]<<16|h2c_parameter[1]<<8|h2c_parameter[2]);
+
+	btcoexist->btc_fill_h2c(btcoexist, 0x66, 3, h2c_parameter);
+}
+
+void ex_halbtc8821a1ant_special_packet_notify(struct btc_coexist *btcoexist,
+					      u8 type)
+{
+	bool bt_hs_on = false;
+
+	if (btcoexist->manual_control ||
+	    btcoexist->stop_coex_dm ||
+	    btcoexist->bt_info.bt_disabled)
+		return;
+
+	coex_sta->special_pkt_period_cnt = 0;
+
+	btcoexist->btc_get(btcoexist, BTC_GET_BL_HS_OPERATION, &bt_hs_on);
+	if (coex_sta->c2h_bt_inquiry_page) {
+		halbtc8821a1ant_action_bt_inquiry(btcoexist);
+		return;
+	} else if (bt_hs_on) {
+		halbtc8821a1ant_action_hs(btcoexist);
+		return;
+	}
+
+	if (BTC_PACKET_DHCP == type ||
+	    BTC_PACKET_EAPOL == type) {
+		BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
+			  "[BTCoex], special Packet(%d) notify\n", type);
+		action_wifi_connected_special_packet(btcoexist);
+	}
+}
+
+void ex_halbtc8821a1ant_bt_info_notify(struct btc_coexist *btcoexist,
+				       u8 *tmp_buf, u8 length)
+{
+	u8 bt_info = 0;
+	u8 i, rsp_source = 0;
+	bool wifi_connected = false;
+	bool bt_busy = false;
+	bool wifi_under_5g = false;
+
+	coex_sta->c2h_bt_info_req_sent = false;
+
+	btcoexist->btc_get(btcoexist, BTC_GET_BL_WIFI_UNDER_5G, &wifi_under_5g);
+
+	rsp_source = tmp_buf[0]&0xf;
+	if (rsp_source >= BT_INFO_SRC_8821A_1ANT_MAX)
+		rsp_source = BT_INFO_SRC_8821A_1ANT_WIFI_FW;
+	coex_sta->bt_info_c2h_cnt[rsp_source]++;
+
+	BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
+		  "[BTCoex], Bt info[%d], length =%d, hex data =[",
+		  rsp_source, length);
+	for (i = 0; i < length; i++) {
+		coex_sta->bt_info_c2h[rsp_source][i] = tmp_buf[i];
+		if (i == 1)
+			bt_info = tmp_buf[i];
+		if (i == length-1)
+			BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
+				  "0x%02x]\n", tmp_buf[i]);
+		else
+			BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
+				  "0x%02x, ", tmp_buf[i]);
+	}
+
+	if (BT_INFO_SRC_8821A_1ANT_WIFI_FW != rsp_source) {
+		coex_sta->bt_retry_cnt =	/*  [3:0] */
+			coex_sta->bt_info_c2h[rsp_source][2]&0xf;
+
+		coex_sta->bt_rssi =
+			coex_sta->bt_info_c2h[rsp_source][3]*2+10;
+
+		coex_sta->bt_info_ext =
+			coex_sta->bt_info_c2h[rsp_source][4];
+
+		/*  Here we need to resend some wifi info to BT */
+		/*  because bt is reset and loss of the info. */
+		if (coex_sta->bt_info_ext & BIT(1)) {
+			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+				  "[BTCoex], BT ext info bit1 check, send wifi BW&Chnl to BT!!\n");
+			btcoexist->btc_get(btcoexist, BTC_GET_BL_WIFI_CONNECTED,
+					   &wifi_connected);
+			if (wifi_connected)
+				ex_halbtc8821a1ant_media_status_notify(btcoexist,
+								       BTC_MEDIA_CONNECT);
+			else
+				ex_halbtc8821a1ant_media_status_notify(btcoexist,
+								       BTC_MEDIA_DISCONNECT);
+		}
+
+		if ((coex_sta->bt_info_ext & BIT(3)) && !wifi_under_5g) {
+			if (!btcoexist->manual_control &&
+			    !btcoexist->stop_coex_dm) {
+				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+					  "[BTCoex], BT ext info bit3 check, set BT NOT to ignore Wlan active!!\n");
+				halbtc8821a1ant_ignore_wlan_act(btcoexist,
+								FORCE_EXEC, false);
+			}
+		} else {
+			/*  BT already NOT ignore Wlan active, do nothing here. */
+		}
+#if (BT_AUTO_REPORT_ONLY_8821A_1ANT == 0)
+		if ((coex_sta->bt_info_ext & BIT(4))) {
+			/*  BT auto report already enabled, do nothing */
+		} else {
+			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+				  "[BTCoex], BT ext info bit4 check, set BT to enable Auto Report!!\n");
+			halbtc8821a1ant_bt_auto_report(btcoexist,
+						       FORCE_EXEC, true);
+		}
+#endif
+	}
+
+	/*  check BIT(2) first ==> check if bt is under inquiry or page scan */
+	if (bt_info & BT_INFO_8821A_1ANT_B_INQ_PAGE)
+		coex_sta->c2h_bt_inquiry_page = true;
+	else
+		coex_sta->c2h_bt_inquiry_page = false;
+
+	/*  set link exist status */
+	if (!(bt_info&BT_INFO_8821A_1ANT_B_CONNECTION)) {
+		coex_sta->bt_link_exist = false;
+		coex_sta->pan_exist = false;
+		coex_sta->a2dp_exist = false;
+		coex_sta->hid_exist = false;
+		coex_sta->sco_exist = false;
+	} else {
+		/*  connection exists */
+		coex_sta->bt_link_exist = true;
+		if (bt_info & BT_INFO_8821A_1ANT_B_FTP)
+			coex_sta->pan_exist = true;
+		else
+			coex_sta->pan_exist = false;
+		if (bt_info & BT_INFO_8821A_1ANT_B_A2DP)
+			coex_sta->a2dp_exist = true;
+		else
+			coex_sta->a2dp_exist = false;
+		if (bt_info & BT_INFO_8821A_1ANT_B_HID)
+			coex_sta->hid_exist = true;
+		else
+			coex_sta->hid_exist = false;
+		if (bt_info & BT_INFO_8821A_1ANT_B_SCO_ESCO)
+			coex_sta->sco_exist = true;
+		else
+			coex_sta->sco_exist = false;
+	}
+
+	halbtc8821a1ant_update_bt_link_info(btcoexist);
+
+	if (!(bt_info&BT_INFO_8821A_1ANT_B_CONNECTION)) {
+		coex_dm->bt_status = BT_8821A_1ANT_BT_STATUS_NON_CONNECTED_IDLE;
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+			  "[BTCoex], BtInfoNotify(), BT Non-Connected idle!!!\n");
+	} else if (bt_info == BT_INFO_8821A_1ANT_B_CONNECTION) {
+		/*  connection exists but not busy */
+		coex_dm->bt_status = BT_8821A_1ANT_BT_STATUS_CONNECTED_IDLE;
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+			  "[BTCoex], BtInfoNotify(), BT Connected-idle!!!\n");
+	} else if ((bt_info&BT_INFO_8821A_1ANT_B_SCO_ESCO) ||
+		   (bt_info&BT_INFO_8821A_1ANT_B_SCO_BUSY)) {
+		coex_dm->bt_status = BT_8821A_1ANT_BT_STATUS_SCO_BUSY;
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+			  "[BTCoex], BtInfoNotify(), BT SCO busy!!!\n");
+	} else if (bt_info&BT_INFO_8821A_1ANT_B_ACL_BUSY) {
+		if (BT_8821A_1ANT_BT_STATUS_ACL_BUSY != coex_dm->bt_status)
+			coex_dm->auto_tdma_adjust = false;
+		coex_dm->bt_status = BT_8821A_1ANT_BT_STATUS_ACL_BUSY;
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+			  "[BTCoex], BtInfoNotify(), BT ACL busy!!!\n");
+	} else {
+		coex_dm->bt_status = BT_8821A_1ANT_BT_STATUS_MAX;
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+			  "[BTCoex], BtInfoNotify(), BT Non-Defined state!!!\n");
+	}
+
+	if ((BT_8821A_1ANT_BT_STATUS_ACL_BUSY == coex_dm->bt_status) ||
+	    (BT_8821A_1ANT_BT_STATUS_SCO_BUSY == coex_dm->bt_status) ||
+	    (BT_8821A_1ANT_BT_STATUS_ACL_SCO_BUSY == coex_dm->bt_status))
+		bt_busy = true;
+	else
+		bt_busy = false;
+	btcoexist->btc_set(btcoexist, BTC_SET_BL_BT_TRAFFIC_BUSY, &bt_busy);
+
+	halbtc8821a1ant_run_coexist_mechanism(btcoexist);
+}
+
+void ex_halbtc8821a1ant_halt_notify(struct btc_coexist *btcoexist)
+{
+	BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY, "[BTCoex], Halt notify\n");
+
+	btcoexist->stop_coex_dm = true;
+
+	halbtc8821a1ant_set_ant_path(btcoexist, BTC_ANT_PATH_BT, false, true);
+	halbtc8821a1ant_ignore_wlan_act(btcoexist, FORCE_EXEC, true);
+
+	halbtc8821a1ant_power_save_state(btcoexist, BTC_PS_WIFI_NATIVE,
+					 0x0, 0x0);
+	halbtc8821a1ant_ps_tdma(btcoexist, FORCE_EXEC, false, 0);
+
+	ex_halbtc8821a1ant_media_status_notify(btcoexist, BTC_MEDIA_DISCONNECT);
+}
+
+void ex_halbtc8821a1ant_pnp_notify(struct btc_coexist *btcoexist, u8 pnp_state)
+{
+	BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY, "[BTCoex], Pnp notify\n");
+
+	if (BTC_WIFI_PNP_SLEEP == pnp_state) {
+		BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
+			  "[BTCoex], Pnp notify to SLEEP\n");
+		btcoexist->stop_coex_dm = true;
+		halbtc8821a1ant_ignore_wlan_act(btcoexist, FORCE_EXEC, true);
+		halbtc8821a1ant_power_save_state(btcoexist, BTC_PS_WIFI_NATIVE,
+						 0x0, 0x0);
+		halbtc8821a1ant_ps_tdma(btcoexist, NORMAL_EXEC, false, 9);
+	} else if (BTC_WIFI_PNP_WAKE_UP == pnp_state) {
+		BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
+			  "[BTCoex], Pnp notify to WAKE UP\n");
+		btcoexist->stop_coex_dm = false;
+		halbtc8821a1ant_init_hw_config(btcoexist, false);
+		halbtc8821a1ant_init_coex_dm(btcoexist);
+		halbtc8821a1ant_query_bt_info(btcoexist);
+	}
+}
+
+void ex_halbtc8821a1ant_periodical(struct btc_coexist *btcoexist)
+{
+	static u8 dis_ver_info_cnt;
+	u32 fw_ver = 0, bt_patch_ver = 0;
+	struct btc_board_info *board_info = &btcoexist->board_info;
+	struct btc_stack_info *stack_info = &btcoexist->stack_info;
+
+	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+		  "[BTCoex], ========================== Periodical ===========================\n");
+
+	if (dis_ver_info_cnt <= 5) {
+		dis_ver_info_cnt += 1;
+		BTC_PRINT(BTC_MSG_INTERFACE, INTF_INIT,
+			  "[BTCoex], ****************************************************************\n");
+		BTC_PRINT(BTC_MSG_INTERFACE, INTF_INIT,
+			  "[BTCoex], Ant PG Num/ Ant Mech/ Ant Pos = %d/ %d/ %d\n",
+			  board_info->pg_ant_num, board_info->btdm_ant_num,
+			  board_info->btdm_ant_pos);
+		BTC_PRINT(BTC_MSG_INTERFACE, INTF_INIT,
+			  "[BTCoex], BT stack/ hci ext ver = %s / %d\n",
+			  ((stack_info->profile_notified) ? "Yes" : "No"),
+			  stack_info->hci_version);
+		btcoexist->btc_get(btcoexist, BTC_GET_U4_BT_PATCH_VER,
+				   &bt_patch_ver);
+		btcoexist->btc_get(btcoexist, BTC_GET_U4_WIFI_FW_VER, &fw_ver);
+		BTC_PRINT(BTC_MSG_INTERFACE, INTF_INIT,
+			  "[BTCoex], CoexVer/ FwVer/ PatchVer = %d_%x/ 0x%x/ 0x%x(%d)\n",
+			  glcoex_ver_date_8821a_1ant, glcoex_ver_8821a_1ant,
+			  fw_ver, bt_patch_ver, bt_patch_ver);
+		BTC_PRINT(BTC_MSG_INTERFACE, INTF_INIT,
+			  "[BTCoex], ****************************************************************\n");
+	}
+
+#if (BT_AUTO_REPORT_ONLY_8821A_1ANT == 0)
+	halbtc8821a1ant_query_bt_info(btcoexist);
+	halbtc8821a1ant_monitor_bt_ctr(btcoexist);
+	halbtc8821a1ant_monitor_bt_enable_disable(btcoexist);
+#else
+	if (halbtc8821a1ant_Is_wifi_status_changed(btcoexist) ||
+	    coex_dm->auto_tdma_adjust) {
+		if (coex_sta->special_pkt_period_cnt > 2)
+			halbtc8821a1ant_run_coexist_mechanism(btcoexist);
+	}
+
+	coex_sta->special_pkt_period_cnt++;
+#endif
+}
diff --git a/drivers/staging/rtl8192ee/btcoexist/halbtc8821a1ant.h b/drivers/staging/rtl8192ee/btcoexist/halbtc8821a1ant.h
new file mode 100644
index 0000000..9b991d0
--- /dev/null
+++ b/drivers/staging/rtl8192ee/btcoexist/halbtc8821a1ant.h
@@ -0,0 +1,158 @@
+/*  */
+/*  The following is for 8821A 1ANT BT Co-exist definition */
+/*  */
+#define	BT_AUTO_REPORT_ONLY_8821A_1ANT				0
+
+#define	BT_INFO_8821A_1ANT_B_FTP				BIT(7)
+#define	BT_INFO_8821A_1ANT_B_A2DP				BIT(6)
+#define	BT_INFO_8821A_1ANT_B_HID				BIT(5)
+#define	BT_INFO_8821A_1ANT_B_SCO_BUSY				BIT(4)
+#define	BT_INFO_8821A_1ANT_B_ACL_BUSY				BIT(3)
+#define	BT_INFO_8821A_1ANT_B_INQ_PAGE				BIT(2)
+#define	BT_INFO_8821A_1ANT_B_SCO_ESCO				BIT(1)
+#define	BT_INFO_8821A_1ANT_B_CONNECTION				BIT(0)
+
+#define	BT_INFO_8821A_1ANT_A2DP_BASIC_RATE(_BT_INFO_EXT_)	\
+		(((_BT_INFO_EXT_&BIT(0))) ? true : false)
+
+#define	BTC_RSSI_COEX_THRESH_TOL_8821A_1ANT		2
+
+enum BT_INFO_SRC_8821A_1ANT {
+	BT_INFO_SRC_8821A_1ANT_WIFI_FW			= 0x0,
+	BT_INFO_SRC_8821A_1ANT_BT_RSP			= 0x1,
+	BT_INFO_SRC_8821A_1ANT_BT_ACTIVE_SEND		= 0x2,
+	BT_INFO_SRC_8821A_1ANT_MAX
+};
+
+enum BT_8821A_1ANT_BT_STATUS {
+	BT_8821A_1ANT_BT_STATUS_NON_CONNECTED_IDLE	= 0x0,
+	BT_8821A_1ANT_BT_STATUS_CONNECTED_IDLE		= 0x1,
+	BT_8821A_1ANT_BT_STATUS_INQ_PAGE		= 0x2,
+	BT_8821A_1ANT_BT_STATUS_ACL_BUSY		= 0x3,
+	BT_8821A_1ANT_BT_STATUS_SCO_BUSY		= 0x4,
+	BT_8821A_1ANT_BT_STATUS_ACL_SCO_BUSY		= 0x5,
+	BT_8821A_1ANT_BT_STATUS_MAX
+};
+
+enum BT_8821A_1ANT_WIFI_STATUS {
+	BT_8821A_1ANT_WIFI_STATUS_NON_CONNECTED_IDLE			= 0x0,
+	BT_8821A_1ANT_WIFI_STATUS_NON_CONNECTED_ASSO_AUTH_SCAN		= 0x1,
+	BT_8821A_1ANT_WIFI_STATUS_CONNECTED_SCAN			= 0x2,
+	BT_8821A_1ANT_WIFI_STATUS_CONNECTED_SPECIAL_PKT			= 0x3,
+	BT_8821A_1ANT_WIFI_STATUS_CONNECTED_IDLE			= 0x4,
+	BT_8821A_1ANT_WIFI_STATUS_CONNECTED_BUSY			= 0x5,
+	BT_8821A_1ANT_WIFI_STATUS_MAX
+};
+
+enum BT_8821A_1ANT_COEX_ALGO {
+	BT_8821A_1ANT_COEX_ALGO_UNDEFINED		= 0x0,
+	BT_8821A_1ANT_COEX_ALGO_SCO			= 0x1,
+	BT_8821A_1ANT_COEX_ALGO_HID			= 0x2,
+	BT_8821A_1ANT_COEX_ALGO_A2DP			= 0x3,
+	BT_8821A_1ANT_COEX_ALGO_A2DP_PANHS		= 0x4,
+	BT_8821A_1ANT_COEX_ALGO_PANEDR			= 0x5,
+	BT_8821A_1ANT_COEX_ALGO_PANHS			= 0x6,
+	BT_8821A_1ANT_COEX_ALGO_PANEDR_A2DP		= 0x7,
+	BT_8821A_1ANT_COEX_ALGO_PANEDR_HID		= 0x8,
+	BT_8821A_1ANT_COEX_ALGO_HID_A2DP_PANEDR		= 0x9,
+	BT_8821A_1ANT_COEX_ALGO_HID_A2DP		= 0xa,
+	BT_8821A_1ANT_COEX_ALGO_MAX			= 0xb,
+};
+
+struct coex_dm_8821a_1ant {
+	/*  fw mechanism */
+	bool		cur_ignore_wlan_act;
+	bool		pre_ignore_wlan_act;
+	u8		pre_ps_tdma;
+	u8		cur_ps_tdma;
+	u8		ps_tdma_para[5];
+	u8		ps_tdma_du_adj_type;
+	bool		auto_tdma_adjust;
+	bool		pre_ps_tdma_on;
+	bool		cur_ps_tdma_on;
+	bool		pre_bt_auto_report;
+	bool		cur_bt_auto_report;
+	u8		pre_lps;
+	u8		cur_lps;
+	u8		pre_rpwm;
+	u8		cur_rpwm;
+
+	/*  sw mechanism */
+	bool	pre_low_penalty_ra;
+	bool		cur_low_penalty_ra;
+	u32		pre_val_0x6c0;
+	u32		cur_val_0x6c0;
+	u32		pre_val_0x6c4;
+	u32		cur_val_0x6c4;
+	u32		pre_val_0x6c8;
+	u32		cur_val_0x6c8;
+	u8		pre_val_0x6cc;
+	u8		cur_val_0x6cc;
+
+	u32		backup_arfr_cnt1; /*  Auto Rate Fallback Retry cnt */
+	u32		backup_arfr_cnt2; /*  Auto Rate Fallback Retry cnt */
+	u16		backup_retry_limit;
+	u8		backup_ampdu_max_time;
+
+	/*  algorithm related */
+	u8		pre_algorithm;
+	u8		cur_algorithm;
+	u8		bt_status;
+	u8		wifi_chnl_info[3];
+
+	u32		pre_ra_mask;
+	u32		cur_ra_mask;
+	u8		pre_arfr_type;
+	u8		cur_arfr_type;
+	u8		pre_retry_limit_type;
+	u8		cur_retry_limit_type;
+	u8		pre_ampdu_time_type;
+	u8		cur_ampdu_time_type;
+
+	u8		error_condition;
+};
+
+struct coex_sta_8821a_1ant {
+	bool		bt_link_exist;
+	bool		sco_exist;
+	bool		a2dp_exist;
+	bool		hid_exist;
+	bool		pan_exist;
+
+	bool		under_lps;
+	bool		under_ips;
+	u32		special_pkt_period_cnt;
+	u32		high_priority_tx;
+	u32		high_priority_rx;
+	u32		low_priority_tx;
+	u32		low_priority_rx;
+	u8		bt_rssi;
+	u8		pre_bt_rssi_state;
+	u8		pre_wifi_rssi_state[4];
+	bool		c2h_bt_info_req_sent;
+	u8		bt_info_c2h[BT_INFO_SRC_8821A_1ANT_MAX][10];
+	u32		bt_info_c2h_cnt[BT_INFO_SRC_8821A_1ANT_MAX];
+	bool		c2h_bt_inquiry_page;
+	u8		bt_retry_cnt;
+	u8		bt_info_ext;
+};
+
+/*  The following is interface which will notify coex module. */
+void ex_halbtc8821a1ant_init_hwconfig(struct btc_coexist *btcoexist);
+void ex_halbtc8821a1ant_init_coex_dm(struct btc_coexist *btcoexist);
+void ex_halbtc8821a1ant_ips_notify(struct btc_coexist *btcoexist, u8 type);
+void ex_halbtc8821a1ant_lps_notify(struct btc_coexist *btcoexist, u8 type);
+void ex_halbtc8821a1ant_scan_notify(struct btc_coexist *btcoexist, u8 type);
+void ex_halbtc8821a1ant_connect_notify(struct btc_coexist *btcoexist, u8 type);
+void ex_halbtc8821a1ant_media_status_notify(struct btc_coexist *btcoexist,
+					    u8 type);
+void ex_halbtc8821a1ant_special_packet_notify(struct btc_coexist *btcoexist,
+					      u8 type);
+void ex_halbtc8821a1ant_bt_info_notify(struct btc_coexist *btcoexist,
+				       u8 *tmpbuf, u8 length);
+void ex_halbtc8821a1ant_halt_notify(struct btc_coexist *btcoexist);
+void ex_halbtc8821a1ant_pnp_notify(struct btc_coexist *btcoexist, u8 pnpstate);
+void ex_halbtc8821a1ant_periodical(struct btc_coexist *btcoexist);
+void ex_halbtc8821a1ant_display_coex_info(struct btc_coexist *btcoexist);
+void ex_halbtc8821a1ant_dbg_control(struct btc_coexist *btcoexist, u8 op_code,
+				    u8 op_len, u8 *data);
diff --git a/drivers/staging/rtl8192ee/btcoexist/halbtc8821a2ant.c b/drivers/staging/rtl8192ee/btcoexist/halbtc8821a2ant.c
new file mode 100644
index 0000000..7fb5907
--- /dev/null
+++ b/drivers/staging/rtl8192ee/btcoexist/halbtc8821a2ant.c
@@ -0,0 +1,3438 @@
+/*  Description: */
+/*  This file is for RTL8821A Co-exist mechanism */
+/*  History */
+/*  2012/08/22 Cosa first check in. */
+/*  2012/11/14 Cosa Revise for 8821A 2Ant out sourcing. */
+
+/*  include files */
+#include "halbt_precomp.h"
+/*  Global variables, these are static variables */
+static struct coex_dm_8821a_2ant	glcoex_dm_8821a_2ant;
+static struct coex_dm_8821a_2ant	*coex_dm = &glcoex_dm_8821a_2ant;
+static struct coex_sta_8821a_2ant	glcoex_sta_8821a_2ant;
+static struct coex_sta_8821a_2ant	*coex_sta = &glcoex_sta_8821a_2ant;
+
+static const char *const glbt_info_src_8821a_2ant[] = {
+	"BT Info[wifi fw]",
+	"BT Info[bt rsp]",
+	"BT Info[bt auto report]",
+};
+
+static u32 glcoex_ver_date_8821a_2ant = 20130618;
+static u32 glcoex_ver_8821a_2ant = 0x5050;
+
+/*  local function proto type if needed */
+/*  local function start with halbtc8821a2ant_ */
+static u8 halbtc8821a2ant_bt_rssi_state(u8 level_num, u8 rssi_thresh,
+					u8 rssi_thresh1)
+{
+	long bt_rssi = 0;
+	u8 bt_rssi_state = coex_sta->pre_bt_rssi_state;
+
+	bt_rssi = coex_sta->bt_rssi;
+
+	if (level_num == 2) {
+		if ((coex_sta->pre_bt_rssi_state == BTC_RSSI_STATE_LOW) ||
+		    (coex_sta->pre_bt_rssi_state == BTC_RSSI_STATE_STAY_LOW)) {
+			if (bt_rssi >= (rssi_thresh +
+			    BTC_RSSI_COEX_THRESH_TOL_8821A_2ANT)) {
+				bt_rssi_state = BTC_RSSI_STATE_HIGH;
+				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_RSSI_STATE,
+					  "[BTCoex], BT Rssi state switch to High\n");
+			} else {
+				bt_rssi_state = BTC_RSSI_STATE_STAY_LOW;
+				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_RSSI_STATE,
+					  "[BTCoex], BT Rssi state stay at Low\n");
+			}
+		} else {
+			if (bt_rssi < rssi_thresh) {
+				bt_rssi_state = BTC_RSSI_STATE_LOW;
+				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_RSSI_STATE,
+					  "[BTCoex], BT Rssi state switch to Low\n");
+			} else {
+				bt_rssi_state = BTC_RSSI_STATE_STAY_HIGH;
+				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_RSSI_STATE,
+					  "[BTCoex], BT Rssi state stay at High\n");
+			}
+		}
+	} else if (level_num == 3) {
+		if (rssi_thresh > rssi_thresh1) {
+			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_RSSI_STATE,
+				  "[BTCoex], BT Rssi thresh error!!\n");
+			return coex_sta->pre_bt_rssi_state;
+		}
+
+		if ((coex_sta->pre_bt_rssi_state == BTC_RSSI_STATE_LOW) ||
+		    (coex_sta->pre_bt_rssi_state == BTC_RSSI_STATE_STAY_LOW)) {
+			if (bt_rssi >= (rssi_thresh +
+			    BTC_RSSI_COEX_THRESH_TOL_8821A_2ANT)) {
+				bt_rssi_state = BTC_RSSI_STATE_MEDIUM;
+				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_RSSI_STATE,
+					  "[BTCoex], BT Rssi state switch to Medium\n");
+			} else {
+				bt_rssi_state = BTC_RSSI_STATE_STAY_LOW;
+				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_RSSI_STATE,
+					  "[BTCoex], BT Rssi state stay at Low\n");
+			}
+		} else if ((coex_sta->pre_bt_rssi_state ==
+			    BTC_RSSI_STATE_MEDIUM) ||
+			   (coex_sta->pre_bt_rssi_state ==
+			    BTC_RSSI_STATE_STAY_MEDIUM)) {
+			if (bt_rssi >= (rssi_thresh1 +
+			    BTC_RSSI_COEX_THRESH_TOL_8821A_2ANT)) {
+				bt_rssi_state = BTC_RSSI_STATE_HIGH;
+				BTC_PRINT(BTC_MSG_ALGORITHM,
+					  ALGO_BT_RSSI_STATE,
+					  "[BTCoex], BT Rssi state switch to High\n");
+			} else if (bt_rssi < rssi_thresh) {
+				bt_rssi_state = BTC_RSSI_STATE_LOW;
+				BTC_PRINT(BTC_MSG_ALGORITHM,
+					  ALGO_BT_RSSI_STATE,
+					  "[BTCoex], BT Rssi state switch to Low\n");
+			} else {
+				bt_rssi_state = BTC_RSSI_STATE_STAY_MEDIUM;
+				BTC_PRINT(BTC_MSG_ALGORITHM,
+					  ALGO_BT_RSSI_STATE,
+					  "[BTCoex], BT Rssi state stay at Medium\n");
+			}
+		} else {
+			if (bt_rssi < rssi_thresh1) {
+				bt_rssi_state = BTC_RSSI_STATE_MEDIUM;
+				BTC_PRINT(BTC_MSG_ALGORITHM,
+					  ALGO_BT_RSSI_STATE,
+					  "[BTCoex], BT Rssi state switch to Medium\n");
+			} else {
+				bt_rssi_state = BTC_RSSI_STATE_STAY_HIGH;
+				BTC_PRINT(BTC_MSG_ALGORITHM,
+					  ALGO_BT_RSSI_STATE,
+					  "[BTCoex], BT Rssi state stay at High\n");
+			}
+		}
+	}
+
+	coex_sta->pre_bt_rssi_state = bt_rssi_state;
+
+	return bt_rssi_state;
+}
+
+static u8 wifi21a_rssi_state(struct btc_coexist *btcoexist,
+			     u8 index, u8 level_num,
+			     u8 rssi_thresh, u8 rssi_thresh1)
+{
+	long	wifi_rssi = 0;
+	u8 wifi_rssi_state = coex_sta->pre_wifi_rssi_state[index];
+
+	btcoexist->btc_get(btcoexist, BTC_GET_S4_WIFI_RSSI, &wifi_rssi);
+
+	if (level_num == 2) {
+		if ((coex_sta->pre_wifi_rssi_state[index] ==
+		     BTC_RSSI_STATE_LOW) ||
+		    (coex_sta->pre_wifi_rssi_state[index] ==
+		     BTC_RSSI_STATE_STAY_LOW)) {
+			if (wifi_rssi >= (rssi_thresh +
+			    BTC_RSSI_COEX_THRESH_TOL_8821A_2ANT)) {
+				wifi_rssi_state = BTC_RSSI_STATE_HIGH;
+				BTC_PRINT(BTC_MSG_ALGORITHM,
+					  ALGO_WIFI_RSSI_STATE,
+					  "[BTCoex], wifi RSSI state switch to High\n");
+			} else {
+				wifi_rssi_state = BTC_RSSI_STATE_STAY_LOW;
+				BTC_PRINT(BTC_MSG_ALGORITHM,
+					  ALGO_WIFI_RSSI_STATE,
+					  "[BTCoex], wifi RSSI state stay at Low\n");
+			}
+		} else {
+			if (wifi_rssi < rssi_thresh) {
+				wifi_rssi_state = BTC_RSSI_STATE_LOW;
+				BTC_PRINT(BTC_MSG_ALGORITHM,
+					  ALGO_WIFI_RSSI_STATE,
+					  "[BTCoex], wifi RSSI state switch to Low\n");
+			} else {
+				wifi_rssi_state = BTC_RSSI_STATE_STAY_HIGH;
+				BTC_PRINT(BTC_MSG_ALGORITHM,
+					  ALGO_WIFI_RSSI_STATE,
+					  "[BTCoex], wifi RSSI state stay at High\n");
+			}
+		}
+	} else if (level_num == 3) {
+		if (rssi_thresh > rssi_thresh1) {
+			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_WIFI_RSSI_STATE,
+				  "[BTCoex], wifi RSSI thresh error!!\n");
+			return coex_sta->pre_wifi_rssi_state[index];
+		}
+
+		if ((coex_sta->pre_wifi_rssi_state[index] ==
+		    BTC_RSSI_STATE_LOW) ||
+		    (coex_sta->pre_wifi_rssi_state[index] ==
+		     BTC_RSSI_STATE_STAY_LOW)) {
+			if (wifi_rssi >= (rssi_thresh +
+			    BTC_RSSI_COEX_THRESH_TOL_8821A_2ANT)) {
+				wifi_rssi_state = BTC_RSSI_STATE_MEDIUM;
+				BTC_PRINT(BTC_MSG_ALGORITHM,
+					  ALGO_WIFI_RSSI_STATE,
+					  "[BTCoex], wifi RSSI state switch to Medium\n");
+			} else {
+				wifi_rssi_state = BTC_RSSI_STATE_STAY_LOW;
+				BTC_PRINT(BTC_MSG_ALGORITHM,
+					  ALGO_WIFI_RSSI_STATE,
+					  "[BTCoex], wifi RSSI state stay at Low\n");
+			}
+		} else if ((coex_sta->pre_wifi_rssi_state[index] ==
+			    BTC_RSSI_STATE_MEDIUM) ||
+			   (coex_sta->pre_wifi_rssi_state[index] ==
+			    BTC_RSSI_STATE_STAY_MEDIUM)) {
+			if (wifi_rssi >= (rssi_thresh1+BTC_RSSI_COEX_THRESH_TOL_8821A_2ANT)) {
+				wifi_rssi_state = BTC_RSSI_STATE_HIGH;
+				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_WIFI_RSSI_STATE,
+					  "[BTCoex], wifi RSSI state switch to High\n");
+			} else if (wifi_rssi < rssi_thresh) {
+				wifi_rssi_state = BTC_RSSI_STATE_LOW;
+				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_WIFI_RSSI_STATE,
+					  "[BTCoex], wifi RSSI state switch to Low\n");
+			} else {
+				wifi_rssi_state = BTC_RSSI_STATE_STAY_MEDIUM;
+				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_WIFI_RSSI_STATE,
+					  "[BTCoex], wifi RSSI state stay at Medium\n");
+			}
+		} else {
+			if (wifi_rssi < rssi_thresh1) {
+				wifi_rssi_state = BTC_RSSI_STATE_MEDIUM;
+				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_WIFI_RSSI_STATE,
+					  "[BTCoex], wifi RSSI state switch to Medium\n");
+			} else {
+				wifi_rssi_state = BTC_RSSI_STATE_STAY_HIGH;
+				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_WIFI_RSSI_STATE,
+					  "[BTCoex], wifi RSSI state stay at High\n");
+			}
+		}
+	}
+
+	coex_sta->pre_wifi_rssi_state[index] = wifi_rssi_state;
+
+	return wifi_rssi_state;
+}
+
+static void monitor_bt_enable_disable(struct btc_coexist *btcoexist)
+{
+	static bool pre_bt_disabled;
+	static u32 bt_disable_cnt;
+	bool bt_active = true, bt_disabled = false;
+
+	/*  This function check if bt is disabled */
+
+	if (coex_sta->high_priority_tx == 0 &&
+	    coex_sta->high_priority_rx == 0 &&
+	    coex_sta->low_priority_tx == 0 &&
+	    coex_sta->low_priority_rx == 0)
+		bt_active = false;
+	if (coex_sta->high_priority_tx == 0xffff &&
+	    coex_sta->high_priority_rx == 0xffff &&
+	    coex_sta->low_priority_tx == 0xffff &&
+	    coex_sta->low_priority_rx == 0xffff)
+		bt_active = false;
+	if (bt_active) {
+		bt_disable_cnt = 0;
+		bt_disabled = false;
+		btcoexist->btc_set(btcoexist, BTC_SET_BL_BT_DISABLE,
+				   &bt_disabled);
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_MONITOR,
+			  "[BTCoex], BT is enabled !!\n");
+	} else {
+		bt_disable_cnt++;
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_MONITOR,
+			  "[BTCoex], bt all counters = 0, %d times!!\n",
+			  bt_disable_cnt);
+		if (bt_disable_cnt >= 2) {
+			bt_disabled = true;
+			btcoexist->btc_set(btcoexist, BTC_SET_BL_BT_DISABLE,
+					   &bt_disabled);
+			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_MONITOR,
+				  "[BTCoex], BT is disabled !!\n");
+		}
+	}
+	if (pre_bt_disabled != bt_disabled) {
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_MONITOR,
+			  "[BTCoex], BT is from %s to %s!!\n",
+			  (pre_bt_disabled ? "disabled" : "enabled"),
+			  (bt_disabled ? "disabled" : "enabled"));
+		pre_bt_disabled = bt_disabled;
+	}
+}
+
+static void halbtc8821a2ant_monitor_bt_ctr(struct btc_coexist *btcoexist)
+{
+	u32 reg_hp_txrx, reg_lp_txrx, u4tmp;
+	u32 reg_hp_tx = 0, reg_hp_rx = 0, reg_lp_tx = 0, reg_lp_rx = 0;
+
+	reg_hp_txrx = 0x770;
+	reg_lp_txrx = 0x774;
+
+	u4tmp = btcoexist->btc_read_4byte(btcoexist, reg_hp_txrx);
+	reg_hp_tx = u4tmp & MASKLWORD;
+	reg_hp_rx = (u4tmp & MASKHWORD)>>16;
+
+	u4tmp = btcoexist->btc_read_4byte(btcoexist, reg_lp_txrx);
+	reg_lp_tx = u4tmp & MASKLWORD;
+	reg_lp_rx = (u4tmp & MASKHWORD)>>16;
+
+	coex_sta->high_priority_tx = reg_hp_tx;
+	coex_sta->high_priority_rx = reg_hp_rx;
+	coex_sta->low_priority_tx = reg_lp_tx;
+	coex_sta->low_priority_rx = reg_lp_rx;
+
+	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_MONITOR,
+		  "[BTCoex], High Priority Tx/Rx (reg 0x%x) = 0x%x(%d)/0x%x(%d)\n",
+		  reg_hp_txrx, reg_hp_tx, reg_hp_tx, reg_hp_rx, reg_hp_rx);
+	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_BT_MONITOR,
+		  "[BTCoex], Low Priority Tx/Rx (reg 0x%x) = 0x%x(%d)/0x%x(%d)\n",
+		  reg_lp_txrx, reg_lp_tx, reg_lp_tx, reg_lp_rx, reg_lp_rx);
+
+	/*  reset counter */
+	btcoexist->btc_write_1byte(btcoexist, 0x76e, 0xc);
+}
+
+static void halbtc8821a2ant_query_bt_info(struct btc_coexist *btcoexist)
+{
+	u8 h2c_parameter[1] = {0};
+
+	coex_sta->c2h_bt_info_req_sent = true;
+
+	h2c_parameter[0] |= BIT(0);	/*  trigger */
+
+	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_EXEC,
+		  "[BTCoex], Query Bt Info, FW write 0x61 = 0x%x\n",
+		  h2c_parameter[0]);
+
+	btcoexist->btc_fill_h2c(btcoexist, 0x61, 1, h2c_parameter);
+}
+
+static u8 halbtc8821a2ant_action_algorithm(struct btc_coexist *btcoexist)
+{
+	struct btc_stack_info *stack_info = &btcoexist->stack_info;
+	bool bt_hs_on = false;
+	u8 algorithm = BT_8821A_2ANT_COEX_ALGO_UNDEFINED;
+	u8 num_of_diff_profile = 0;
+
+	btcoexist->btc_get(btcoexist, BTC_GET_BL_HS_OPERATION, &bt_hs_on);
+
+	/* for win-8 stack HID report error */
+	if (!stack_info->hid_exist) {
+		/* sync  BTInfo with BT firmware and stack */
+		stack_info->hid_exist = coex_sta->hid_exist;
+	}
+	/*  when stack HID report error, here we use the info from bt fw. */
+	if (!stack_info->bt_link_exist)
+		stack_info->bt_link_exist = coex_sta->bt_link_exist;
+
+	if (!coex_sta->bt_link_exist) {
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+			  "[BTCoex], No profile exists!!!\n");
+		return algorithm;
+	}
+
+	if (coex_sta->sco_exist)
+		num_of_diff_profile++;
+	if (coex_sta->hid_exist)
+		num_of_diff_profile++;
+	if (coex_sta->pan_exist)
+		num_of_diff_profile++;
+	if (coex_sta->a2dp_exist)
+		num_of_diff_profile++;
+
+	if (num_of_diff_profile == 1) {
+		if (coex_sta->sco_exist) {
+			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+				  "[BTCoex], SCO only\n");
+			algorithm = BT_8821A_2ANT_COEX_ALGO_SCO;
+		} else {
+			if (coex_sta->hid_exist) {
+				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+					  "[BTCoex], HID only\n");
+				algorithm = BT_8821A_2ANT_COEX_ALGO_HID;
+			} else if (coex_sta->a2dp_exist) {
+				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+					  "[BTCoex], A2DP only\n");
+				algorithm = BT_8821A_2ANT_COEX_ALGO_A2DP;
+			} else if (coex_sta->pan_exist) {
+				if (bt_hs_on) {
+					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+						  "[BTCoex], PAN(HS) only\n");
+					algorithm = BT_8821A_2ANT_COEX_ALGO_PANHS;
+				} else {
+					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+						  "[BTCoex], PAN(EDR) only\n");
+					algorithm = BT_8821A_2ANT_COEX_ALGO_PANEDR;
+				}
+			}
+		}
+	} else if (num_of_diff_profile == 2) {
+		if (coex_sta->sco_exist) {
+			if (coex_sta->hid_exist) {
+				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE, "[BTCoex], SCO + HID\n");
+				algorithm = BT_8821A_2ANT_COEX_ALGO_PANEDR_HID;
+			} else if (coex_sta->a2dp_exist) {
+				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+					  "[BTCoex], SCO + A2DP ==> SCO\n");
+				algorithm = BT_8821A_2ANT_COEX_ALGO_PANEDR_HID;
+			} else if (coex_sta->pan_exist) {
+				if (bt_hs_on) {
+					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+						  "[BTCoex], SCO + PAN(HS)\n");
+					algorithm = BT_8821A_2ANT_COEX_ALGO_SCO;
+				} else {
+					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+						  "[BTCoex], SCO + PAN(EDR)\n");
+					algorithm = BT_8821A_2ANT_COEX_ALGO_PANEDR_HID;
+				}
+			}
+		} else {
+			if (coex_sta->hid_exist &&
+			    coex_sta->a2dp_exist) {
+				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+					  "[BTCoex], HID + A2DP\n");
+				algorithm = BT_8821A_2ANT_COEX_ALGO_HID_A2DP;
+			} else if (coex_sta->hid_exist &&
+				   coex_sta->pan_exist) {
+				if (bt_hs_on) {
+					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+						  "[BTCoex], HID + PAN(HS)\n");
+					algorithm =  BT_8821A_2ANT_COEX_ALGO_HID;
+				} else {
+					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+						  "[BTCoex], HID + PAN(EDR)\n");
+					algorithm = BT_8821A_2ANT_COEX_ALGO_PANEDR_HID;
+				}
+			} else if (coex_sta->pan_exist &&
+				   coex_sta->a2dp_exist) {
+				if (bt_hs_on) {
+					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+						  "[BTCoex], A2DP + PAN(HS)\n");
+					algorithm = BT_8821A_2ANT_COEX_ALGO_A2DP_PANHS;
+				} else {
+					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+						  "[BTCoex], A2DP + PAN(EDR)\n");
+					algorithm = BT_8821A_2ANT_COEX_ALGO_PANEDR_A2DP;
+				}
+			}
+		}
+	} else if (num_of_diff_profile == 3) {
+		if (coex_sta->sco_exist) {
+			if (coex_sta->hid_exist &&
+			    coex_sta->a2dp_exist) {
+				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+					  "[BTCoex], SCO + HID + A2DP ==> HID\n");
+				algorithm = BT_8821A_2ANT_COEX_ALGO_PANEDR_HID;
+			} else if (coex_sta->hid_exist &&
+				   coex_sta->pan_exist) {
+				if (bt_hs_on) {
+					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+						  "[BTCoex], SCO + HID + PAN(HS)\n");
+					algorithm = BT_8821A_2ANT_COEX_ALGO_PANEDR_HID;
+				} else {
+					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+						  "[BTCoex], SCO + HID + PAN(EDR)\n");
+					algorithm = BT_8821A_2ANT_COEX_ALGO_PANEDR_HID;
+				}
+			} else if (coex_sta->pan_exist &&
+				   coex_sta->a2dp_exist) {
+				if (bt_hs_on) {
+					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+						  "[BTCoex], SCO + A2DP + PAN(HS)\n");
+					algorithm = BT_8821A_2ANT_COEX_ALGO_PANEDR_HID;
+				} else {
+					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+						  "[BTCoex], SCO + A2DP + PAN(EDR) ==> HID\n");
+					algorithm = BT_8821A_2ANT_COEX_ALGO_PANEDR_HID;
+				}
+			}
+		} else {
+			if (coex_sta->hid_exist &&
+			    coex_sta->pan_exist &&
+			    coex_sta->a2dp_exist) {
+				if (bt_hs_on) {
+					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+						  "[BTCoex], HID + A2DP + PAN(HS)\n");
+					algorithm = BT_8821A_2ANT_COEX_ALGO_HID_A2DP;
+				} else {
+					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+						  "[BTCoex], HID + A2DP + PAN(EDR)\n");
+					algorithm = BT_8821A_2ANT_COEX_ALGO_HID_A2DP_PANEDR;
+				}
+			}
+		}
+	} else if (num_of_diff_profile >= 3) {
+		if (coex_sta->sco_exist) {
+			if (coex_sta->hid_exist &&
+			    coex_sta->pan_exist &&
+			    coex_sta->a2dp_exist) {
+				if (bt_hs_on) {
+					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+						  "[BTCoex], Error!!! SCO + HID + A2DP + PAN(HS)\n");
+
+				} else {
+					BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+						  "[BTCoex], SCO + HID + A2DP + PAN(EDR) ==>PAN(EDR)+HID\n");
+					algorithm = BT_8821A_2ANT_COEX_ALGO_PANEDR_HID;
+				}
+			}
+		}
+	}
+	return algorithm;
+}
+
+static bool halbtc8821a2ant_need_to_dec_bt_pwr(struct btc_coexist *btcoexist)
+{
+	bool ret = false;
+	bool bt_hs_on = false, wifi_connected = false;
+	long bt_hs_rssi = 0;
+	u8 bt_rssi_state;
+
+	if (!btcoexist->btc_get(btcoexist, BTC_GET_BL_HS_OPERATION, &bt_hs_on))
+		return false;
+	if (!btcoexist->btc_get(btcoexist, BTC_GET_BL_WIFI_CONNECTED,
+				&wifi_connected))
+		return false;
+	if (!btcoexist->btc_get(btcoexist, BTC_GET_S4_HS_RSSI, &bt_hs_rssi))
+		return false;
+
+	bt_rssi_state = halbtc8821a2ant_bt_rssi_state(2, 35, 0);
+
+	if (wifi_connected) {
+		if (bt_hs_on) {
+			if (bt_hs_rssi > 37) {
+				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW,
+					  "[BTCoex], Need to decrease bt power for HS mode!!\n");
+				ret = true;
+			}
+		} else {
+			if ((bt_rssi_state == BTC_RSSI_STATE_HIGH) ||
+			    (bt_rssi_state == BTC_RSSI_STATE_STAY_HIGH)) {
+				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW,
+					  "[BTCoex], Need to decrease bt power for Wifi is connected!!\n");
+				ret = true;
+			}
+		}
+	}
+	return ret;
+}
+
+static void set_fw_dac_swing_level(struct btc_coexist *btcoexist,
+				   u8 dac_swing_lvl)
+{
+	u8 h2c_parameter[1] = {0};
+
+	/*  There are several type of dacswing */
+	/*  0x18/ 0x10/ 0xc/ 0x8/ 0x4/ 0x6 */
+	h2c_parameter[0] = dac_swing_lvl;
+
+	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_EXEC,
+		  "[BTCoex], Set Dac Swing Level = 0x%x\n", dac_swing_lvl);
+	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_EXEC,
+		  "[BTCoex], FW write 0x64 = 0x%x\n", h2c_parameter[0]);
+
+	btcoexist->btc_fill_h2c(btcoexist, 0x64, 1, h2c_parameter);
+}
+
+static void halbtc8821a2ant_set_fw_dec_bt_pwr(struct btc_coexist *btcoexist,
+					      bool dec_bt_pwr)
+{
+	u8 h2c_parameter[1] = {0};
+
+	h2c_parameter[0] = 0;
+
+	if (dec_bt_pwr)
+		h2c_parameter[0] |= BIT(1);
+
+	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_EXEC,
+		  "[BTCoex], decrease Bt Power : %s, FW write 0x62 = 0x%x\n",
+		  (dec_bt_pwr ? "Yes!!" : "No!!"), h2c_parameter[0]);
+
+	btcoexist->btc_fill_h2c(btcoexist, 0x62, 1, h2c_parameter);
+}
+
+static void halbtc8821a2ant_dec_bt_pwr(struct btc_coexist *btcoexist,
+				       bool force_exec, bool dec_bt_pwr)
+{
+	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW,
+		  "[BTCoex], %s Dec BT power = %s\n",
+		  (force_exec ? "force to" : ""),
+		  ((dec_bt_pwr) ? "ON" : "OFF"));
+	coex_dm->cur_dec_bt_pwr = dec_bt_pwr;
+
+	if (!force_exec) {
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_DETAIL,
+			  "[BTCoex], pre_dec_bt_pwr =%d, cur_dec_bt_pwr =%d\n",
+			  coex_dm->pre_dec_bt_pwr, coex_dm->cur_dec_bt_pwr);
+
+		if (coex_dm->pre_dec_bt_pwr == coex_dm->cur_dec_bt_pwr)
+			return;
+	}
+	halbtc8821a2ant_set_fw_dec_bt_pwr(btcoexist, coex_dm->cur_dec_bt_pwr);
+
+	coex_dm->pre_dec_bt_pwr = coex_dm->cur_dec_bt_pwr;
+}
+
+static void set_fw_bt_lna_constrain(struct btc_coexist *btcoexist,
+				    bool bt_lna_cons_on)
+{
+	u8 h2c_parameter[2] = {0};
+
+	h2c_parameter[0] = 0x3;	/*  opCode, 0x3 = BT_SET_LNA_CONSTRAIN */
+
+	if (bt_lna_cons_on)
+		h2c_parameter[1] |= BIT(0);
+
+	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_EXEC,
+		  "[BTCoex], set BT LNA Constrain: %s, FW write 0x69 = 0x%x\n",
+		  (bt_lna_cons_on ? "ON!!" : "OFF!!"),
+		  h2c_parameter[0]<<8|h2c_parameter[1]);
+
+	btcoexist->btc_fill_h2c(btcoexist, 0x69, 2, h2c_parameter);
+}
+
+static void set_bt_lna_constrain(struct btc_coexist *btcoexist, bool force_exec,
+				 bool bt_lna_cons_on)
+{
+	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW,
+		  "[BTCoex], %s BT Constrain = %s\n",
+		  (force_exec ? "force" : ""),
+		  ((bt_lna_cons_on) ? "ON" : "OFF"));
+	coex_dm->cur_bt_lna_constrain = bt_lna_cons_on;
+
+	if (!force_exec) {
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_DETAIL,
+			  "[BTCoex], pre_bt_lna_constrain =%d, cur_bt_lna_constrain =%d\n",
+			  coex_dm->pre_bt_lna_constrain,
+			  coex_dm->cur_bt_lna_constrain);
+
+		if (coex_dm->pre_bt_lna_constrain ==
+		    coex_dm->cur_bt_lna_constrain)
+			return;
+	}
+	set_fw_bt_lna_constrain(btcoexist, coex_dm->cur_bt_lna_constrain);
+
+	coex_dm->pre_bt_lna_constrain = coex_dm->cur_bt_lna_constrain;
+}
+
+static void halbtc8821a2ant_set_fw_bt_psd_mode(struct btc_coexist *btcoexist,
+					       u8 bt_psd_mode)
+{
+	u8 h2c_parameter[2] = {0};
+
+	h2c_parameter[0] = 0x2;	/*  opCode, 0x2 = BT_SET_PSD_MODE */
+
+	h2c_parameter[1] = bt_psd_mode;
+
+	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_EXEC,
+		  "[BTCoex], set BT PSD mode = 0x%x, FW write 0x69 = 0x%x\n",
+		  h2c_parameter[1],
+		  h2c_parameter[0] << 8 | h2c_parameter[1]);
+
+	btcoexist->btc_fill_h2c(btcoexist, 0x69, 2, h2c_parameter);
+}
+
+static void halbtc8821a2ant_set_bt_psd_mode(struct btc_coexist *btcoexist,
+					    bool force_exec, u8 bt_psd_mode)
+{
+	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW,
+		  "[BTCoex], %s BT PSD mode = 0x%x\n",
+		  (force_exec ? "force" : ""), bt_psd_mode);
+	coex_dm->cur_bt_psd_mode = bt_psd_mode;
+
+	if (!force_exec) {
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_DETAIL,
+			  "[BTCoex], pre_bt_psd_mode = 0x%x, cur_bt_psd_mode = 0x%x\n",
+			  coex_dm->pre_bt_psd_mode, coex_dm->cur_bt_psd_mode);
+
+		if (coex_dm->pre_bt_psd_mode == coex_dm->cur_bt_psd_mode)
+			return;
+	}
+	halbtc8821a2ant_set_fw_bt_psd_mode(btcoexist, coex_dm->cur_bt_psd_mode);
+
+	coex_dm->pre_bt_psd_mode = coex_dm->cur_bt_psd_mode;
+}
+
+static void halbtc8821a2ant_set_bt_auto_report(struct btc_coexist *btcoexist,
+					       bool enable_auto_report)
+{
+	u8 h2c_parameter[1] = {0};
+
+	h2c_parameter[0] = 0;
+
+	if (enable_auto_report)
+		h2c_parameter[0] |= BIT(0);
+
+	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_EXEC,
+		  "[BTCoex], BT FW auto report : %s, FW write 0x68 = 0x%x\n",
+		  (enable_auto_report ? "Enabled!!" : "Disabled!!"),
+		  h2c_parameter[0]);
+
+	btcoexist->btc_fill_h2c(btcoexist, 0x68, 1, h2c_parameter);
+}
+
+static void halbtc8821a2ant_bt_auto_report(struct btc_coexist *btcoexist,
+					   bool force_exec,
+					   bool enable_auto_report)
+{
+	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW,
+		  "[BTCoex], %s BT Auto report = %s\n",
+		  (force_exec ? "force to" : ""),
+		  ((enable_auto_report) ? "Enabled" : "Disabled"));
+	coex_dm->cur_bt_auto_report = enable_auto_report;
+
+	if (!force_exec) {
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_DETAIL,
+			  "[BTCoex], pre_bt_auto_report =%d, cur_bt_auto_report =%d\n",
+			  coex_dm->pre_bt_auto_report,
+			  coex_dm->cur_bt_auto_report);
+
+		if (coex_dm->pre_bt_auto_report == coex_dm->cur_bt_auto_report)
+			return;
+	}
+	halbtc8821a2ant_set_bt_auto_report(btcoexist,
+					   coex_dm->cur_bt_auto_report);
+
+	coex_dm->pre_bt_auto_report = coex_dm->cur_bt_auto_report;
+}
+
+static void halbtc8821a2ant_fw_dac_swing_lvl(struct btc_coexist *btcoexist,
+					     bool force_exec,
+					     u8 fw_dac_swing_lvl)
+{
+	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW,
+		  "[BTCoex], %s set FW Dac Swing level = %d\n",
+		  (force_exec ? "force to" : ""), fw_dac_swing_lvl);
+	coex_dm->cur_fw_dac_swing_lvl = fw_dac_swing_lvl;
+
+	if (!force_exec) {
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_DETAIL,
+			  "[BTCoex], pre_fw_dac_swing_lvl =%d, cur_fw_dac_swing_lvl =%d\n",
+			  coex_dm->pre_fw_dac_swing_lvl,
+			  coex_dm->cur_fw_dac_swing_lvl);
+
+		if (coex_dm->pre_fw_dac_swing_lvl ==
+		    coex_dm->cur_fw_dac_swing_lvl)
+			return;
+	}
+
+	set_fw_dac_swing_level(btcoexist, coex_dm->cur_fw_dac_swing_lvl);
+
+	coex_dm->pre_fw_dac_swing_lvl = coex_dm->cur_fw_dac_swing_lvl;
+}
+
+static void set_sw_rf_rx_lpf_corner(struct btc_coexist *btcoexist,
+				    bool rx_rf_shrink_on)
+{
+	if (rx_rf_shrink_on) {
+		/* Shrink RF Rx LPF corner */
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW_EXEC,
+			  "[BTCoex], Shrink RF Rx LPF corner!!\n");
+		btcoexist->btc_set_rf_reg(btcoexist, BTC_RF_A, 0x1e,
+					  0xfffff, 0xffffc);
+	} else {
+		/* Resume RF Rx LPF corner */
+		/*  After initialized, we can use coex_dm->bt_rf0x1e_backup */
+		if (btcoexist->initilized) {
+			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW_EXEC,
+				  "[BTCoex], Resume RF Rx LPF corner!!\n");
+			btcoexist->btc_set_rf_reg(btcoexist, BTC_RF_A, 0x1e,
+						  0xfffff,
+						  coex_dm->bt_rf0x1e_backup);
+		}
+	}
+}
+
+static void halbtc8821a2ant_RfShrink(struct btc_coexist *btcoexist,
+				     bool force_exec, bool rx_rf_shrink_on)
+{
+	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW,
+		  "[BTCoex], %s turn Rx RF Shrink = %s\n",
+		  (force_exec ? "force to" : ""),
+		  ((rx_rf_shrink_on) ? "ON" : "OFF"));
+	coex_dm->cur_rf_rx_lpf_shrink = rx_rf_shrink_on;
+
+	if (!force_exec) {
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW_DETAIL,
+			  "[BTCoex], pre_rf_rx_lpf_shrink =%d, cur_rf_rx_lpf_shrink =%d\n",
+			  coex_dm->pre_rf_rx_lpf_shrink,
+			  coex_dm->cur_rf_rx_lpf_shrink);
+
+		if (coex_dm->pre_rf_rx_lpf_shrink ==
+		    coex_dm->cur_rf_rx_lpf_shrink)
+			return;
+	}
+	set_sw_rf_rx_lpf_corner(btcoexist, coex_dm->cur_rf_rx_lpf_shrink);
+
+	coex_dm->pre_rf_rx_lpf_shrink = coex_dm->cur_rf_rx_lpf_shrink;
+}
+
+static void set_sw_penalty_tx_rate_adap(struct btc_coexist *btcoexist,
+					bool low_penalty_ra)
+{
+	u8 h2c_parameter[6] = {0};
+
+	h2c_parameter[0] = 0x6;	/*  opCode, 0x6 = Retry_Penalty */
+
+	if (low_penalty_ra) {
+		h2c_parameter[1] |= BIT(0);
+		/* normal rate except MCS7/6/5, OFDM54/48/36 */
+		h2c_parameter[2] = 0x00;
+		h2c_parameter[3] = 0xf7;  /* MCS7 or OFDM54 */
+		h2c_parameter[4] = 0xf8;  /* MCS6 or OFDM48 */
+		h2c_parameter[5] = 0xf9;  /* MCS5 or OFDM36  */
+	}
+
+	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_EXEC,
+		  "[BTCoex], set WiFi Low-Penalty Retry: %s",
+		  (low_penalty_ra ? "ON!!" : "OFF!!"));
+
+	btcoexist->btc_fill_h2c(btcoexist, 0x69, 6, h2c_parameter);
+}
+
+static void halbtc8821a2ant_low_penalty_ra(struct btc_coexist *btcoexist,
+					   bool force_exec, bool low_penalty_ra)
+{
+	/* return; */
+	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW,
+		  "[BTCoex], %s turn LowPenaltyRA = %s\n",
+		  (force_exec ? "force to" : ""),
+		  ((low_penalty_ra) ? "ON" : "OFF"));
+	coex_dm->cur_low_penalty_ra = low_penalty_ra;
+
+	if (!force_exec) {
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW_DETAIL,
+			  "[BTCoex], pre_low_penalty_ra =%d, cur_low_penalty_ra =%d\n",
+			  coex_dm->pre_low_penalty_ra,
+			  coex_dm->cur_low_penalty_ra);
+
+		if (coex_dm->pre_low_penalty_ra == coex_dm->cur_low_penalty_ra)
+			return;
+	}
+	set_sw_penalty_tx_rate_adap(btcoexist, coex_dm->cur_low_penalty_ra);
+
+	coex_dm->pre_low_penalty_ra = coex_dm->cur_low_penalty_ra;
+}
+
+static void halbtc8821a2ant_set_dac_swing_reg(struct btc_coexist *btcoexist,
+					      u32 level)
+{
+	u8 val = (u8)level;
+
+	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW_EXEC,
+		  "[BTCoex], Write SwDacSwing = 0x%x\n", level);
+	btcoexist->btc_write_1byte_bitmask(btcoexist, 0xc5b, 0x3e, val);
+}
+
+static void set_sw_fulltime_dac_swing(struct btc_coexist *btcoexist,
+				      bool sw_dac_swing_on,
+				      u32 sw_dac_swing_lvl)
+{
+	if (sw_dac_swing_on)
+		halbtc8821a2ant_set_dac_swing_reg(btcoexist, sw_dac_swing_lvl);
+	else
+		halbtc8821a2ant_set_dac_swing_reg(btcoexist, 0x18);
+}
+
+static void halbtc8821a2ant_dac_swing(struct btc_coexist *btcoexist,
+				      bool force_exec, bool dac_swing_on,
+				      u32 dac_swing_lvl)
+{
+	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW,
+		  "[BTCoex], %s turn DacSwing =%s, dac_swing_lvl = 0x%x\n",
+		  (force_exec ? "force to" : ""),
+		  ((dac_swing_on) ? "ON" : "OFF"), dac_swing_lvl);
+	coex_dm->cur_dac_swing_on = dac_swing_on;
+	coex_dm->cur_dac_swing_lvl = dac_swing_lvl;
+
+	if (!force_exec) {
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW_DETAIL,
+			  "[BTCoex], pre_dac_swing_on =%d, pre_dac_swing_lvl = 0x%x, cur_dac_swing_on =%d, cur_dac_swing_lvl = 0x%x\n",
+			  coex_dm->pre_dac_swing_on,
+			  coex_dm->pre_dac_swing_lvl,
+			  coex_dm->cur_dac_swing_on,
+			  coex_dm->cur_dac_swing_lvl);
+
+		if ((coex_dm->pre_dac_swing_on == coex_dm->cur_dac_swing_on) &&
+		    (coex_dm->pre_dac_swing_lvl == coex_dm->cur_dac_swing_lvl))
+			return;
+	}
+	mdelay(30);
+	set_sw_fulltime_dac_swing(btcoexist, dac_swing_on, dac_swing_lvl);
+
+	coex_dm->pre_dac_swing_on = coex_dm->cur_dac_swing_on;
+	coex_dm->pre_dac_swing_lvl = coex_dm->cur_dac_swing_lvl;
+}
+
+static void halbtc8821a2ant_set_adc_back_off(struct btc_coexist *btcoexist,
+					     bool adc_back_off)
+{
+	if (adc_back_off) {
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW_EXEC,
+			  "[BTCoex], BB BackOff Level On!\n");
+		btcoexist->btc_write_1byte_bitmask(btcoexist, 0x8db, 0x60, 0x3);
+	} else {
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW_EXEC,
+			  "[BTCoex], BB BackOff Level Off!\n");
+		btcoexist->btc_write_1byte_bitmask(btcoexist, 0x8db, 0x60, 0x1);
+	}
+}
+
+static void halbtc8821a2ant_adc_back_off(struct btc_coexist *btcoexist,
+					 bool force_exec, bool adc_back_off)
+{
+	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW,
+		  "[BTCoex], %s turn AdcBackOff = %s\n",
+		  (force_exec ? "force to" : ""),
+		  ((adc_back_off) ? "ON" : "OFF"));
+	coex_dm->cur_adc_back_off = adc_back_off;
+
+	if (!force_exec) {
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW_DETAIL,
+			  "[BTCoex], pre_adc_back_off =%d, cur_adc_back_off =%d\n",
+			coex_dm->pre_adc_back_off, coex_dm->cur_adc_back_off);
+
+		if (coex_dm->pre_adc_back_off == coex_dm->cur_adc_back_off)
+			return;
+	}
+	halbtc8821a2ant_set_adc_back_off(btcoexist, coex_dm->cur_adc_back_off);
+
+	coex_dm->pre_adc_back_off = coex_dm->cur_adc_back_off;
+}
+
+static void halbtc8821a2ant_set_coex_table(struct btc_coexist *btcoexist,
+					   u32 val0x6c0, u32 val0x6c4,
+					   u32 val0x6c8, u8 val0x6cc)
+{
+	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW_EXEC,
+		  "[BTCoex], set coex table, set 0x6c0 = 0x%x\n", val0x6c0);
+	btcoexist->btc_write_4byte(btcoexist, 0x6c0, val0x6c0);
+
+	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW_EXEC,
+		  "[BTCoex], set coex table, set 0x6c4 = 0x%x\n", val0x6c4);
+	btcoexist->btc_write_4byte(btcoexist, 0x6c4, val0x6c4);
+
+	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW_EXEC,
+		  "[BTCoex], set coex table, set 0x6c8 = 0x%x\n", val0x6c8);
+	btcoexist->btc_write_4byte(btcoexist, 0x6c8, val0x6c8);
+
+	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW_EXEC,
+		  "[BTCoex], set coex table, set 0x6cc = 0x%x\n", val0x6cc);
+	btcoexist->btc_write_1byte(btcoexist, 0x6cc, val0x6cc);
+}
+
+static void halbtc8821a2ant_coex_table(struct btc_coexist *btcoexist,
+				       bool force_exec, u32 val0x6c0,
+				       u32 val0x6c4, u32 val0x6c8, u8 val0x6cc)
+{
+	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW,
+		  "[BTCoex], %s write Coex Table 0x6c0 = 0x%x, 0x6c4 = 0x%x, 0x6c8 = 0x%x, 0x6cc = 0x%x\n",
+		  (force_exec ? "force to" : ""),
+		  val0x6c0, val0x6c4, val0x6c8, val0x6cc);
+	coex_dm->cur_val0x6c0 = val0x6c0;
+	coex_dm->cur_val0x6c4 = val0x6c4;
+	coex_dm->cur_val0x6c8 = val0x6c8;
+	coex_dm->cur_val0x6cc = val0x6cc;
+
+	if (!force_exec) {
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW_DETAIL,
+			  "[BTCoex], pre_val0x6c0 = 0x%x, pre_val0x6c4 = 0x%x, pre_val0x6c8 = 0x%x, pre_val0x6cc = 0x%x !!\n",
+			  coex_dm->pre_val0x6c0, coex_dm->pre_val0x6c4,
+			  coex_dm->pre_val0x6c8, coex_dm->pre_val0x6cc);
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_SW_DETAIL,
+			  "[BTCoex], cur_val0x6c0 = 0x%x, cur_val0x6c4 = 0x%x, cur_val0x6c8 = 0x%x, cur_val0x6cc = 0x%x !!\n",
+			  coex_dm->cur_val0x6c0, coex_dm->cur_val0x6c4,
+			  coex_dm->cur_val0x6c8, coex_dm->cur_val0x6cc);
+
+		if ((coex_dm->pre_val0x6c0 == coex_dm->cur_val0x6c0) &&
+			(coex_dm->pre_val0x6c4 == coex_dm->cur_val0x6c4) &&
+			(coex_dm->pre_val0x6c8 == coex_dm->cur_val0x6c8) &&
+			(coex_dm->pre_val0x6cc == coex_dm->cur_val0x6cc))
+			return;
+	}
+	halbtc8821a2ant_set_coex_table(btcoexist, val0x6c0, val0x6c4,
+				       val0x6c8, val0x6cc);
+
+	coex_dm->pre_val0x6c0 = coex_dm->cur_val0x6c0;
+	coex_dm->pre_val0x6c4 = coex_dm->cur_val0x6c4;
+	coex_dm->pre_val0x6c8 = coex_dm->cur_val0x6c8;
+	coex_dm->pre_val0x6cc = coex_dm->cur_val0x6cc;
+}
+
+static void set_fw_ignore_wlan_act(struct btc_coexist *btcoexist, bool enable)
+{
+	u8 h2c_parameter[1] = {0};
+
+	if (enable)
+		h2c_parameter[0] |= BIT(0);		/*  function enable */
+
+	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_EXEC,
+		  "[BTCoex], set FW for BT Ignore Wlan_Act, FW write 0x63 = 0x%x\n",
+		  h2c_parameter[0]);
+
+	btcoexist->btc_fill_h2c(btcoexist, 0x63, 1, h2c_parameter);
+}
+
+static void halbtc8821a2ant_ignore_wlan_act(struct btc_coexist *btcoexist,
+					    bool force_exec, bool enable)
+{
+	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW,
+		  "[BTCoex], %s turn Ignore WlanAct %s\n",
+		  (force_exec ? "force to" : ""), (enable ? "ON" : "OFF"));
+	coex_dm->cur_ignore_wlan_act = enable;
+
+	if (!force_exec) {
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_DETAIL,
+			  "[BTCoex], pre_ignore_wlan_act = %d, cur_ignore_wlan_act = %d!!\n",
+			  coex_dm->pre_ignore_wlan_act,
+			  coex_dm->cur_ignore_wlan_act);
+		if (coex_dm->pre_ignore_wlan_act ==
+		    coex_dm->cur_ignore_wlan_act)
+			return;
+	}
+	set_fw_ignore_wlan_act(btcoexist, enable);
+
+	coex_dm->pre_ignore_wlan_act = coex_dm->cur_ignore_wlan_act;
+}
+
+static void halbtc8821a2ant_set_fw_pstdma(struct btc_coexist *btcoexist,
+					  u8 byte1, u8 byte2, u8 byte3,
+					  u8 byte4, u8 byte5)
+{
+	u8 h2c_parameter[5] = {0};
+
+	h2c_parameter[0] = byte1;
+	h2c_parameter[1] = byte2;
+	h2c_parameter[2] = byte3;
+	h2c_parameter[3] = byte4;
+	h2c_parameter[4] = byte5;
+
+	coex_dm->ps_tdma_para[0] = byte1;
+	coex_dm->ps_tdma_para[1] = byte2;
+	coex_dm->ps_tdma_para[2] = byte3;
+	coex_dm->ps_tdma_para[3] = byte4;
+	coex_dm->ps_tdma_para[4] = byte5;
+
+	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_EXEC,
+		  "[BTCoex], FW write 0x60(5bytes) = 0x%x%08x\n",
+		  h2c_parameter[0],
+		  h2c_parameter[1] << 24 | h2c_parameter[2] << 16 |
+		  h2c_parameter[3]<<8|h2c_parameter[4]);
+
+	btcoexist->btc_fill_h2c(btcoexist, 0x60, 5, h2c_parameter);
+}
+
+static void sw_mechanism1(struct btc_coexist *btcoexist, bool shrink_rx_lpf,
+			  bool low_penalty_ra, bool limited_dig,
+			  bool bt_lna_constrain)
+{
+	u32 wifi_bw;
+
+	btcoexist->btc_get(btcoexist, BTC_GET_U4_WIFI_BW, &wifi_bw);
+
+	if (BTC_WIFI_BW_HT40 != wifi_bw) {  /* only shrink RF Rx LPF for HT40 */
+		if (shrink_rx_lpf)
+			shrink_rx_lpf = false;
+	}
+
+	 halbtc8821a2ant_RfShrink(btcoexist, NORMAL_EXEC, shrink_rx_lpf);
+	halbtc8821a2ant_low_penalty_ra(btcoexist, NORMAL_EXEC, low_penalty_ra);
+
+	/* no limited DIG */
+	/* set_bt_lna_constrain(btcoexist, NORMAL_EXEC, bBTLNAConstrain); */
+}
+
+static void sw_mechanism2(struct btc_coexist *btcoexist, bool agc_table_shift,
+			  bool adc_back_off, bool sw_dac_swing,
+			  u32 dac_swing_lvl)
+{
+	/* halbtc8821a2ant_AgcTable(btcoexist, NORMAL_EXEC, bAGCTableShift); */
+	halbtc8821a2ant_adc_back_off(btcoexist, NORMAL_EXEC, adc_back_off);
+	halbtc8821a2ant_dac_swing(btcoexist, NORMAL_EXEC, sw_dac_swing,
+				  sw_dac_swing);
+}
+
+static void halbtc8821a2ant_set_ant_path(struct btc_coexist *btcoexist,
+					 u8 ant_pos_type, bool init_hw_cfg,
+					 bool wifi_off)
+{
+	struct btc_board_info *board_info = &btcoexist->board_info;
+	u32 u4tmp = 0;
+	u8 h2c_parameter[2] = {0};
+
+	if (init_hw_cfg) {
+		/*  0x4c[23] = 0, 0x4c[24] = 1  Antenna control by WL/BT */
+		u4tmp = btcoexist->btc_read_4byte(btcoexist, 0x4c);
+		u4tmp &= ~BIT(23);
+		u4tmp |= BIT(24);
+		btcoexist->btc_write_4byte(btcoexist, 0x4c, u4tmp);
+
+		btcoexist->btc_write_4byte(btcoexist, 0x974, 0x3ff);
+		btcoexist->btc_write_1byte(btcoexist, 0xcb4, 0x77);
+
+		if (board_info->btdm_ant_pos == BTC_ANTENNA_AT_MAIN_PORT) {
+			/* tell firmware "antenna inverse"  ==> WRONG firmware
+			 * antenna control code.==>need fw to fix */
+			h2c_parameter[0] = 1;
+			h2c_parameter[1] = 1;
+			btcoexist->btc_fill_h2c(btcoexist, 0x65, 2, h2c_parameter);
+		} else {
+			/* tell firmware "no antenna inverse" ==> WRONG firmware
+			 * antenna control code.==>need fw to fix */
+			h2c_parameter[0] = 0;
+			h2c_parameter[1] = 1;
+			btcoexist->btc_fill_h2c(btcoexist, 0x65, 2,
+						h2c_parameter);
+		}
+	}
+
+	/*  ext switch setting */
+	switch (ant_pos_type) {
+	case BTC_ANT_WIFI_AT_MAIN:
+		btcoexist->btc_write_1byte_bitmask(btcoexist, 0xcb7, 0x30, 0x1);
+		break;
+	case BTC_ANT_WIFI_AT_AUX:
+		btcoexist->btc_write_1byte_bitmask(btcoexist, 0xcb7, 0x30, 0x2);
+		break;
+	}
+}
+
+static void ps21a_tdma(struct btc_coexist *btcoexist, bool force_exec,
+		       bool turn_on, u8 type)
+{
+	/* bool turn_on_by_cnt = false; */
+	/* u8 ps_tdma_type_by_cnt = 0; */
+
+	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW,
+		  "[BTCoex], %s turn %s PS TDMA, type =%d\n",
+		  (force_exec ? "force to" : ""),
+		  (turn_on ? "ON" : "OFF"), type);
+	coex_dm->cur_ps_tdma_on = turn_on;
+	coex_dm->cur_ps_tdma = type;
+
+	if (!force_exec) {
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_DETAIL,
+			  "[BTCoex], pre_ps_tdma_on = %d, cur_ps_tdma_on = %d!!\n",
+			  coex_dm->pre_ps_tdma_on, coex_dm->cur_ps_tdma_on);
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_DETAIL,
+			  "[BTCoex], pre_ps_tdma = %d, cur_ps_tdma = %d!!\n",
+			  coex_dm->pre_ps_tdma, coex_dm->cur_ps_tdma);
+
+		if ((coex_dm->pre_ps_tdma_on == coex_dm->cur_ps_tdma_on) &&
+		    (coex_dm->pre_ps_tdma == coex_dm->cur_ps_tdma))
+			return;
+	}
+	if (turn_on) {
+		switch (type) {
+		case 1:
+		default:
+			halbtc8821a2ant_set_fw_pstdma(btcoexist, 0xe3, 0x1a,
+						      0x1a, 0xe1, 0x90);
+			break;
+		case 2:
+			halbtc8821a2ant_set_fw_pstdma(btcoexist, 0xe3, 0x12,
+						      0x12, 0xe1, 0x90);
+			break;
+		case 3:
+			halbtc8821a2ant_set_fw_pstdma(btcoexist, 0xe3, 0x1c,
+						      0x3, 0xf1, 0x90);
+			break;
+		case 4:
+			halbtc8821a2ant_set_fw_pstdma(btcoexist, 0xe3, 0x10,
+						      0x03, 0xf1, 0x90);
+			break;
+		case 5:
+			halbtc8821a2ant_set_fw_pstdma(btcoexist, 0xe3, 0x1a,
+						      0x1a, 0x60, 0x90);
+			break;
+		case 6:
+			halbtc8821a2ant_set_fw_pstdma(btcoexist, 0xe3, 0x12,
+						      0x12, 0x60, 0x90);
+			break;
+		case 7:
+			halbtc8821a2ant_set_fw_pstdma(btcoexist, 0xe3, 0x1c,
+						      0x3, 0x70, 0x90);
+			break;
+		case 8:
+			halbtc8821a2ant_set_fw_pstdma(btcoexist, 0xa3, 0x10,
+						      0x3, 0x70, 0x90);
+			break;
+		case 9:
+			halbtc8821a2ant_set_fw_pstdma(btcoexist, 0xe3, 0x1a,
+						      0x1a, 0xe1, 0x90);
+			break;
+		case 10:
+			halbtc8821a2ant_set_fw_pstdma(btcoexist, 0xe3, 0x12,
+						      0x12, 0xe1, 0x90);
+			break;
+		case 11:
+			halbtc8821a2ant_set_fw_pstdma(btcoexist, 0xe3, 0xa,
+						      0xa, 0xe1, 0x90);
+			break;
+		case 12:
+			halbtc8821a2ant_set_fw_pstdma(btcoexist, 0xe3, 0x5,
+						      0x5, 0xe1, 0x90);
+			break;
+		case 13:
+			halbtc8821a2ant_set_fw_pstdma(btcoexist, 0xe3, 0x1a,
+						      0x1a, 0x60, 0x90);
+			break;
+		case 14:
+			halbtc8821a2ant_set_fw_pstdma(btcoexist, 0xe3, 0x12,
+						      0x12, 0x60, 0x90);
+			break;
+		case 15:
+			halbtc8821a2ant_set_fw_pstdma(btcoexist, 0xe3, 0xa,
+						      0xa, 0x60, 0x90);
+			break;
+		case 16:
+			halbtc8821a2ant_set_fw_pstdma(btcoexist, 0xe3, 0x5,
+						      0x5, 0x60, 0x90);
+			break;
+		case 17:
+			halbtc8821a2ant_set_fw_pstdma(btcoexist, 0xa3, 0x2f,
+						      0x2f, 0x60, 0x90);
+			break;
+		case 18:
+			halbtc8821a2ant_set_fw_pstdma(btcoexist, 0xe3, 0x5,
+						      0x5, 0xe1, 0x90);
+			break;
+		case 19:
+			halbtc8821a2ant_set_fw_pstdma(btcoexist, 0xe3, 0x25,
+						      0x25, 0xe1, 0x90);
+			break;
+		case 20:
+			halbtc8821a2ant_set_fw_pstdma(btcoexist, 0xe3, 0x25,
+						      0x25, 0x60, 0x90);
+			break;
+		case 21:
+			halbtc8821a2ant_set_fw_pstdma(btcoexist, 0xe3, 0x15,
+						      0x03, 0x70, 0x90);
+			break;
+		case 71:
+			halbtc8821a2ant_set_fw_pstdma(btcoexist, 0xe3, 0x1a,
+						      0x1a, 0xe1, 0x90);
+			break;
+		}
+	} else {
+		/*  disable PS tdma */
+		switch (type) {
+		case 0:
+			halbtc8821a2ant_set_fw_pstdma(btcoexist, 0x0, 0x0, 0x0,
+						      0x40, 0x0);
+			break;
+		case 1:
+			halbtc8821a2ant_set_fw_pstdma(btcoexist, 0x0, 0x0, 0x0,
+						      0x48, 0x0);
+			break;
+		default:
+			halbtc8821a2ant_set_fw_pstdma(btcoexist, 0x0, 0x0, 0x0,
+						      0x40, 0x0);
+			break;
+		}
+	}
+
+	/*  update pre state */
+	coex_dm->pre_ps_tdma_on = coex_dm->cur_ps_tdma_on;
+	coex_dm->pre_ps_tdma = coex_dm->cur_ps_tdma;
+}
+
+static void halbtc8821a2ant_coex_all_off(struct btc_coexist *btcoexist)
+{
+	/*  fw all off */
+	ps21a_tdma(btcoexist, NORMAL_EXEC, false, 1);
+	halbtc8821a2ant_fw_dac_swing_lvl(btcoexist, NORMAL_EXEC, 6);
+	halbtc8821a2ant_dec_bt_pwr(btcoexist, NORMAL_EXEC, false);
+
+	/*  sw all off */
+	sw_mechanism1(btcoexist, false, false, false, false);
+	sw_mechanism2(btcoexist, false, false, false, 0x18);
+
+	/*  hw all off */
+	halbtc8821a2ant_coex_table(btcoexist, NORMAL_EXEC, 0x55555555,
+				   0x55555555, 0xffff, 0x3);
+}
+
+static void halbtc8821a2ant_coex_under_5g(struct btc_coexist *btcoexist)
+{
+	halbtc8821a2ant_coex_all_off(btcoexist);
+}
+
+static void halbtc8821a2ant_init_coex_dm(struct btc_coexist *btcoexist)
+{
+	/*  force to reset coex mechanism */
+	halbtc8821a2ant_coex_table(btcoexist, FORCE_EXEC, 0x55555555,
+				   0x55555555, 0xffff, 0x3);
+
+	ps21a_tdma(btcoexist, FORCE_EXEC, false, 1);
+	halbtc8821a2ant_fw_dac_swing_lvl(btcoexist, FORCE_EXEC, 6);
+	halbtc8821a2ant_dec_bt_pwr(btcoexist, FORCE_EXEC, false);
+
+	sw_mechanism1(btcoexist, false, false, false, false);
+	sw_mechanism2(btcoexist, false, false, false, 0x18);
+}
+
+static void halbtc8821a2ant_bt_inquiry_page(struct btc_coexist *btcoexist)
+{
+	bool low_pwr_disable = true;
+
+	btcoexist->btc_set(btcoexist, BTC_SET_ACT_DISABLE_LOW_POWER,
+			   &low_pwr_disable);
+
+	halbtc8821a2ant_coex_table(btcoexist, NORMAL_EXEC, 0x55ff55ff,
+				   0x5afa5afa, 0xffff, 0x3);
+	ps21a_tdma(btcoexist, NORMAL_EXEC, true, 3);
+}
+
+static bool halbtc8821a2ant_is_common_action(struct btc_coexist *btcoexist)
+{
+	bool common = false, wifi_connected = false, wifi_busy = false;
+	bool low_pwr_disable = false;
+
+	btcoexist->btc_get(btcoexist, BTC_GET_BL_WIFI_CONNECTED,
+			   &wifi_connected);
+	btcoexist->btc_get(btcoexist, BTC_GET_BL_WIFI_BUSY, &wifi_busy);
+
+	halbtc8821a2ant_coex_table(btcoexist, NORMAL_EXEC, 0x55ff55ff,
+				   0x5afa5afa, 0xffff, 0x3);
+
+	if (!wifi_connected &&
+	    BT_8821A_2ANT_BT_STATUS_IDLE == coex_dm->bt_status) {
+		low_pwr_disable = false;
+		btcoexist->btc_set(btcoexist, BTC_SET_ACT_DISABLE_LOW_POWER,
+				   &low_pwr_disable);
+
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+			  "[BTCoex], Wifi IPS + BT IPS!!\n");
+
+		ps21a_tdma(btcoexist, NORMAL_EXEC, false, 1);
+		halbtc8821a2ant_fw_dac_swing_lvl(btcoexist, NORMAL_EXEC, 6);
+		halbtc8821a2ant_dec_bt_pwr(btcoexist, NORMAL_EXEC, false);
+
+		sw_mechanism1(btcoexist, false, false, false, false);
+		sw_mechanism2(btcoexist, false, false, false, 0x18);
+
+		common = true;
+	} else if (wifi_connected &&
+		   (BT_8821A_2ANT_BT_STATUS_IDLE == coex_dm->bt_status)) {
+		low_pwr_disable = false;
+		btcoexist->btc_set(btcoexist, BTC_SET_ACT_DISABLE_LOW_POWER,
+				   &low_pwr_disable);
+
+		if (wifi_busy) {
+			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+				  "[BTCoex], Wifi Busy + BT IPS!!\n");
+			ps21a_tdma(btcoexist, NORMAL_EXEC, false, 1);
+		} else {
+			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+				  "[BTCoex], Wifi LPS + BT IPS!!\n");
+			ps21a_tdma(btcoexist, NORMAL_EXEC, false, 1);
+		}
+
+		halbtc8821a2ant_fw_dac_swing_lvl(btcoexist, NORMAL_EXEC, 6);
+		halbtc8821a2ant_dec_bt_pwr(btcoexist, NORMAL_EXEC, false);
+
+		sw_mechanism1(btcoexist, false, false, false, false);
+		sw_mechanism2(btcoexist, false, false, false, 0x18);
+
+		common = true;
+	} else if (!wifi_connected &&
+		   (BT_8821A_2ANT_BT_STATUS_CONNECTED_IDLE ==
+		    coex_dm->bt_status)) {
+		low_pwr_disable = true;
+		btcoexist->btc_set(btcoexist, BTC_SET_ACT_DISABLE_LOW_POWER,
+				   &low_pwr_disable);
+
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+			  "[BTCoex], Wifi IPS + BT LPS!!\n");
+
+		ps21a_tdma(btcoexist, NORMAL_EXEC, false, 1);
+		halbtc8821a2ant_fw_dac_swing_lvl(btcoexist, NORMAL_EXEC, 6);
+		halbtc8821a2ant_dec_bt_pwr(btcoexist, NORMAL_EXEC, false);
+
+		sw_mechanism1(btcoexist, false, false, false, false);
+		sw_mechanism2(btcoexist, false, false, false, 0x18);
+
+		common = true;
+	} else if (wifi_connected &&
+		   (BT_8821A_2ANT_BT_STATUS_CONNECTED_IDLE ==
+		    coex_dm->bt_status)) {
+		low_pwr_disable = true;
+		btcoexist->btc_set(btcoexist, BTC_SET_ACT_DISABLE_LOW_POWER,
+				   &low_pwr_disable);
+
+		if (wifi_busy) {
+			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+				  "[BTCoex], Wifi Busy + BT LPS!!\n");
+			ps21a_tdma(btcoexist, NORMAL_EXEC, false, 1);
+		} else {
+			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+				  "[BTCoex], Wifi LPS + BT LPS!!\n");
+			ps21a_tdma(btcoexist, NORMAL_EXEC, false, 1);
+		}
+
+		halbtc8821a2ant_fw_dac_swing_lvl(btcoexist, NORMAL_EXEC, 6);
+		halbtc8821a2ant_dec_bt_pwr(btcoexist, NORMAL_EXEC, false);
+
+		sw_mechanism1(btcoexist, true, true, true, true);
+		sw_mechanism2(btcoexist, false, false, false, 0x18);
+
+		common = true;
+	} else if (!wifi_connected &&
+		   (BT_8821A_2ANT_BT_STATUS_NON_IDLE == coex_dm->bt_status)) {
+		low_pwr_disable = false;
+		btcoexist->btc_set(btcoexist, BTC_SET_ACT_DISABLE_LOW_POWER,
+				   &low_pwr_disable);
+
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+			  "[BTCoex], Wifi IPS + BT Busy!!\n");
+
+		ps21a_tdma(btcoexist, NORMAL_EXEC, false, 1);
+		halbtc8821a2ant_fw_dac_swing_lvl(btcoexist, NORMAL_EXEC, 6);
+		halbtc8821a2ant_dec_bt_pwr(btcoexist, NORMAL_EXEC, false);
+
+		sw_mechanism1(btcoexist, false, false, false, false);
+		sw_mechanism2(btcoexist, false, false, false, 0x18);
+
+		common = true;
+	} else {
+		low_pwr_disable = true;
+		btcoexist->btc_set(btcoexist, BTC_SET_ACT_DISABLE_LOW_POWER,
+				   &low_pwr_disable);
+
+		if (wifi_busy) {
+			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+				  "[BTCoex], Wifi Busy + BT Busy!!\n");
+			common = false;
+		} else {
+			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+				  "[BTCoex], Wifi LPS + BT Busy!!\n");
+			ps21a_tdma(btcoexist, NORMAL_EXEC, true, 21);
+
+			if (halbtc8821a2ant_need_to_dec_bt_pwr(btcoexist))
+				halbtc8821a2ant_dec_bt_pwr(btcoexist,
+							   NORMAL_EXEC, true);
+			else
+				halbtc8821a2ant_dec_bt_pwr(btcoexist,
+							   NORMAL_EXEC, false);
+
+			common = true;
+		}
+		sw_mechanism1(btcoexist, true, true, true, true);
+	}
+	return common;
+}
+
+static void tdma_duration_adjust(struct btc_coexist *btcoexist,
+				 bool sco_hid, bool tx_pause, u8 max_interval)
+{
+	static long up, dn, m, n, wait_count;
+	long result;
+	/* 0: no change, +1: incr WiFi duration, -1: decr WiFi duration */
+	u8 retry_count = 0;
+
+	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW,
+		  "[BTCoex], TdmaDurationAdjust()\n");
+
+	if (coex_dm->reset_tdma_adjust) {
+		coex_dm->reset_tdma_adjust = false;
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_DETAIL,
+			  "[BTCoex], first run TdmaDurationAdjust()!!\n");
+		if (sco_hid) {
+			if (tx_pause) {
+				if (max_interval == 1) {
+					ps21a_tdma(btcoexist, NORMAL_EXEC, true, 13);
+					coex_dm->ps_tdma_du_adj_type = 13;
+				} else if (max_interval == 2) {
+					ps21a_tdma(btcoexist, NORMAL_EXEC, true, 14);
+					coex_dm->ps_tdma_du_adj_type = 14;
+				} else if (max_interval == 3) {
+					ps21a_tdma(btcoexist, NORMAL_EXEC, true, 15);
+					coex_dm->ps_tdma_du_adj_type = 15;
+				} else {
+					ps21a_tdma(btcoexist, NORMAL_EXEC, true, 15);
+					coex_dm->ps_tdma_du_adj_type = 15;
+				}
+			} else {
+				if (max_interval == 1) {
+					ps21a_tdma(btcoexist, NORMAL_EXEC, true, 9);
+					coex_dm->ps_tdma_du_adj_type = 9;
+				} else if (max_interval == 2) {
+					ps21a_tdma(btcoexist, NORMAL_EXEC, true, 10);
+					coex_dm->ps_tdma_du_adj_type = 10;
+				} else if (max_interval == 3) {
+					ps21a_tdma(btcoexist, NORMAL_EXEC, true, 11);
+					coex_dm->ps_tdma_du_adj_type = 11;
+				} else {
+					ps21a_tdma(btcoexist, NORMAL_EXEC, true, 11);
+					coex_dm->ps_tdma_du_adj_type = 11;
+				}
+			}
+		} else {
+			if (tx_pause) {
+				if (max_interval == 1) {
+					ps21a_tdma(btcoexist, NORMAL_EXEC, true, 5);
+					coex_dm->ps_tdma_du_adj_type = 5;
+				} else if (max_interval == 2) {
+					ps21a_tdma(btcoexist, NORMAL_EXEC, true, 6);
+					coex_dm->ps_tdma_du_adj_type = 6;
+				} else if (max_interval == 3) {
+					ps21a_tdma(btcoexist, NORMAL_EXEC, true, 7);
+					coex_dm->ps_tdma_du_adj_type = 7;
+				} else {
+					ps21a_tdma(btcoexist, NORMAL_EXEC, true, 7);
+					coex_dm->ps_tdma_du_adj_type = 7;
+				}
+			} else {
+				if (max_interval == 1) {
+					ps21a_tdma(btcoexist, NORMAL_EXEC, true, 1);
+					coex_dm->ps_tdma_du_adj_type = 1;
+				} else if (max_interval == 2) {
+					ps21a_tdma(btcoexist, NORMAL_EXEC, true, 2);
+					coex_dm->ps_tdma_du_adj_type = 2;
+				} else if (max_interval == 3) {
+					ps21a_tdma(btcoexist, NORMAL_EXEC, true, 3);
+					coex_dm->ps_tdma_du_adj_type = 3;
+				} else {
+					ps21a_tdma(btcoexist, NORMAL_EXEC, true, 3);
+					coex_dm->ps_tdma_du_adj_type = 3;
+				}
+			}
+		}
+		up = 0;
+		dn = 0;
+		m = 1;
+		n = 3;
+		result = 0;
+		wait_count = 0;
+	} else {
+		/* accquire the BT TRx retry count from BT_Info byte2 */
+		retry_count = coex_sta->bt_retry_cnt;
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_DETAIL,
+			  "[BTCoex], retry_count = %d\n", retry_count);
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_DETAIL,
+			  "[BTCoex], up =%d, dn =%d, m =%d, n =%d, wait_count =%d\n",
+			  (int)up, (int)dn, (int)m, (int)n, (int)wait_count);
+		result = 0;
+		wait_count++;
+
+		if (retry_count == 0) {
+			/*  no retry in the last 2-second duration */
+			up++;
+			dn--;
+
+			if (dn <= 0)
+				dn = 0;
+
+			if (up >= n) {
+				wait_count = 0;
+				n = 3;
+				up = 0;
+				dn = 0;
+				result = 1;
+				BTC_PRINT(BTC_MSG_ALGORITHM,
+					  ALGO_TRACE_FW_DETAIL,
+					  "[BTCoex], Increase wifi duration!!\n");
+			}
+		} else if (retry_count <= 3) {
+			/*  <= 3 retry in the last 2-second duration */
+			up--;
+			dn++;
+
+			if (up <= 0)
+				up = 0;
+
+			if (dn == 2) {
+				if (wait_count <= 2)
+					m++;
+				else
+					m = 1;
+
+				if (m >= 20)
+					m = 20;
+
+				n = 3*m;
+				up = 0;
+				dn = 0;
+				wait_count = 0;
+				result = -1;
+				BTC_PRINT(BTC_MSG_ALGORITHM,
+					  ALGO_TRACE_FW_DETAIL,
+					  "[BTCoex], Decrease wifi duration for retryCounter<3!!\n");
+			}
+		} else {
+			if (wait_count == 1)
+				m++;
+			else
+				m = 1;
+
+			if (m >= 20)
+				m = 20;
+
+			n = 3*m;
+			up = 0;
+			dn = 0;
+			wait_count = 0;
+			result = -1;
+			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_DETAIL,
+				  "[BTCoex], Decrease wifi duration for retryCounter>3!!\n");
+		}
+
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_DETAIL,
+			  "[BTCoex], max Interval = %d\n", max_interval);
+		if (max_interval == 1) {
+			if (tx_pause) {
+				/* TODO: refactor here */
+				BTC_PRINT(BTC_MSG_ALGORITHM,
+					  ALGO_TRACE_FW_DETAIL,
+					  "[BTCoex], TxPause = 1\n");
+				if (coex_dm->cur_ps_tdma == 71) {
+					ps21a_tdma(btcoexist,
+								NORMAL_EXEC,
+								true, 5);
+					coex_dm->ps_tdma_du_adj_type = 5;
+				} else if (coex_dm->cur_ps_tdma == 1) {
+					ps21a_tdma(btcoexist,
+								NORMAL_EXEC,
+								true, 5);
+					coex_dm->ps_tdma_du_adj_type = 5;
+				} else if (coex_dm->cur_ps_tdma == 2) {
+					ps21a_tdma(btcoexist,
+								NORMAL_EXEC,
+								true, 6);
+					coex_dm->ps_tdma_du_adj_type = 6;
+				} else if (coex_dm->cur_ps_tdma == 3) {
+					ps21a_tdma(btcoexist,
+								NORMAL_EXEC,
+								true, 7);
+					coex_dm->ps_tdma_du_adj_type = 7;
+				} else if (coex_dm->cur_ps_tdma == 4) {
+					ps21a_tdma(btcoexist, NORMAL_EXEC, true, 8);
+					coex_dm->ps_tdma_du_adj_type = 8;
+				}
+				if (coex_dm->cur_ps_tdma == 9) {
+					ps21a_tdma(btcoexist, NORMAL_EXEC, true, 13);
+					coex_dm->ps_tdma_du_adj_type = 13;
+				} else if (coex_dm->cur_ps_tdma == 10) {
+					ps21a_tdma(btcoexist, NORMAL_EXEC, true, 14);
+					coex_dm->ps_tdma_du_adj_type = 14;
+				} else if (coex_dm->cur_ps_tdma == 11) {
+					ps21a_tdma(btcoexist, NORMAL_EXEC, true, 15);
+					coex_dm->ps_tdma_du_adj_type = 15;
+				} else if (coex_dm->cur_ps_tdma == 12) {
+					ps21a_tdma(btcoexist, NORMAL_EXEC, true, 16);
+					coex_dm->ps_tdma_du_adj_type = 16;
+				}
+
+				if (result == -1) {
+					if (coex_dm->cur_ps_tdma == 5) {
+						ps21a_tdma(btcoexist, NORMAL_EXEC, true, 6);
+						coex_dm->ps_tdma_du_adj_type = 6;
+					} else if (coex_dm->cur_ps_tdma == 6) {
+						ps21a_tdma(btcoexist, NORMAL_EXEC, true, 7);
+						coex_dm->ps_tdma_du_adj_type = 7;
+					} else if (coex_dm->cur_ps_tdma == 7) {
+						ps21a_tdma(btcoexist, NORMAL_EXEC, true, 8);
+						coex_dm->ps_tdma_du_adj_type = 8;
+					} else if (coex_dm->cur_ps_tdma == 13) {
+						ps21a_tdma(btcoexist, NORMAL_EXEC, true, 14);
+						coex_dm->ps_tdma_du_adj_type = 14;
+					} else if (coex_dm->cur_ps_tdma == 14) {
+						ps21a_tdma(btcoexist, NORMAL_EXEC, true, 15);
+						coex_dm->ps_tdma_du_adj_type = 15;
+					} else if (coex_dm->cur_ps_tdma == 15) {
+						ps21a_tdma(btcoexist, NORMAL_EXEC, true, 16);
+						coex_dm->ps_tdma_du_adj_type = 16;
+					}
+				} else if (result == 1) {
+					if (coex_dm->cur_ps_tdma == 8) {
+						ps21a_tdma(btcoexist, NORMAL_EXEC, true, 7);
+						coex_dm->ps_tdma_du_adj_type = 7;
+					} else if (coex_dm->cur_ps_tdma == 7) {
+						ps21a_tdma(btcoexist, NORMAL_EXEC, true, 6);
+						coex_dm->ps_tdma_du_adj_type = 6;
+					} else if (coex_dm->cur_ps_tdma == 6) {
+						ps21a_tdma(btcoexist, NORMAL_EXEC, true, 5);
+						coex_dm->ps_tdma_du_adj_type = 5;
+					} else if (coex_dm->cur_ps_tdma == 16) {
+						ps21a_tdma(btcoexist, NORMAL_EXEC, true, 15);
+						coex_dm->ps_tdma_du_adj_type = 15;
+					} else if (coex_dm->cur_ps_tdma == 15) {
+						ps21a_tdma(btcoexist, NORMAL_EXEC, true, 14);
+						coex_dm->ps_tdma_du_adj_type = 14;
+					} else if (coex_dm->cur_ps_tdma == 14) {
+						ps21a_tdma(btcoexist, NORMAL_EXEC, true, 13);
+						coex_dm->ps_tdma_du_adj_type = 13;
+					}
+				}
+			} else {
+				/* TODO: refactor here */
+				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_DETAIL, "[BTCoex], TxPause = 0\n");
+				if (coex_dm->cur_ps_tdma == 5) {
+					ps21a_tdma(btcoexist, NORMAL_EXEC, true, 71);
+					coex_dm->ps_tdma_du_adj_type = 71;
+				} else if (coex_dm->cur_ps_tdma == 6) {
+					ps21a_tdma(btcoexist, NORMAL_EXEC, true, 2);
+					coex_dm->ps_tdma_du_adj_type = 2;
+				} else if (coex_dm->cur_ps_tdma == 7) {
+					ps21a_tdma(btcoexist, NORMAL_EXEC, true, 3);
+					coex_dm->ps_tdma_du_adj_type = 3;
+				} else if (coex_dm->cur_ps_tdma == 8) {
+					ps21a_tdma(btcoexist, NORMAL_EXEC, true, 4);
+					coex_dm->ps_tdma_du_adj_type = 4;
+				}
+				if (coex_dm->cur_ps_tdma == 13) {
+					ps21a_tdma(btcoexist, NORMAL_EXEC, true, 9);
+					coex_dm->ps_tdma_du_adj_type = 9;
+				} else if (coex_dm->cur_ps_tdma == 14) {
+					ps21a_tdma(btcoexist, NORMAL_EXEC, true, 10);
+					coex_dm->ps_tdma_du_adj_type = 10;
+				} else if (coex_dm->cur_ps_tdma == 15) {
+					ps21a_tdma(btcoexist, NORMAL_EXEC, true, 11);
+					coex_dm->ps_tdma_du_adj_type = 11;
+				} else if (coex_dm->cur_ps_tdma == 16) {
+					ps21a_tdma(btcoexist, NORMAL_EXEC, true, 12);
+					coex_dm->ps_tdma_du_adj_type = 12;
+				}
+
+				if (result == -1) {
+					if (coex_dm->cur_ps_tdma == 71) {
+						ps21a_tdma(btcoexist, NORMAL_EXEC, true, 1);
+						coex_dm->ps_tdma_du_adj_type = 1;
+					} else if (coex_dm->cur_ps_tdma == 1) {
+						ps21a_tdma(btcoexist, NORMAL_EXEC, true, 2);
+						coex_dm->ps_tdma_du_adj_type = 2;
+					} else if (coex_dm->cur_ps_tdma == 2) {
+						ps21a_tdma(btcoexist, NORMAL_EXEC, true, 3);
+						coex_dm->ps_tdma_du_adj_type = 3;
+					} else if (coex_dm->cur_ps_tdma == 3) {
+						ps21a_tdma(btcoexist, NORMAL_EXEC, true, 4);
+						coex_dm->ps_tdma_du_adj_type = 4;
+					} else if (coex_dm->cur_ps_tdma == 9) {
+						ps21a_tdma(btcoexist, NORMAL_EXEC, true, 10);
+						coex_dm->ps_tdma_du_adj_type = 10;
+					} else if (coex_dm->cur_ps_tdma == 10) {
+						ps21a_tdma(btcoexist, NORMAL_EXEC, true, 11);
+						coex_dm->ps_tdma_du_adj_type = 11;
+					} else if (coex_dm->cur_ps_tdma == 11) {
+						ps21a_tdma(btcoexist, NORMAL_EXEC, true, 12);
+						coex_dm->ps_tdma_du_adj_type = 12;
+					}
+				} else if (result == 1) {
+					if (coex_dm->cur_ps_tdma == 4) {
+						ps21a_tdma(btcoexist, NORMAL_EXEC, true, 3);
+						coex_dm->ps_tdma_du_adj_type = 3;
+					} else if (coex_dm->cur_ps_tdma == 3) {
+						ps21a_tdma(btcoexist, NORMAL_EXEC, true, 2);
+						coex_dm->ps_tdma_du_adj_type = 2;
+					} else if (coex_dm->cur_ps_tdma == 2) {
+						ps21a_tdma(btcoexist, NORMAL_EXEC, true, 1);
+						coex_dm->ps_tdma_du_adj_type = 1;
+					} else if (coex_dm->cur_ps_tdma == 1) {
+						ps21a_tdma(btcoexist, NORMAL_EXEC, true, 71);
+						coex_dm->ps_tdma_du_adj_type = 71;
+					} else if (coex_dm->cur_ps_tdma == 12) {
+						ps21a_tdma(btcoexist, NORMAL_EXEC, true, 11);
+						coex_dm->ps_tdma_du_adj_type = 11;
+					} else if (coex_dm->cur_ps_tdma == 11) {
+						ps21a_tdma(btcoexist, NORMAL_EXEC, true, 10);
+						coex_dm->ps_tdma_du_adj_type = 10;
+					} else if (coex_dm->cur_ps_tdma == 10) {
+						ps21a_tdma(btcoexist, NORMAL_EXEC, true, 9);
+						coex_dm->ps_tdma_du_adj_type = 9;
+					}
+				}
+			}
+		} else if (max_interval == 2) {
+			if (tx_pause) {
+				/* TODO: refactor here */
+				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_DETAIL, "[BTCoex], TxPause = 1\n");
+				if (coex_dm->cur_ps_tdma == 1) {
+					ps21a_tdma(btcoexist, NORMAL_EXEC, true, 6);
+					coex_dm->ps_tdma_du_adj_type = 6;
+				} else if (coex_dm->cur_ps_tdma == 2) {
+					ps21a_tdma(btcoexist, NORMAL_EXEC, true, 6);
+					coex_dm->ps_tdma_du_adj_type = 6;
+				} else if (coex_dm->cur_ps_tdma == 3) {
+					ps21a_tdma(btcoexist, NORMAL_EXEC, true, 7);
+					coex_dm->ps_tdma_du_adj_type = 7;
+				} else if (coex_dm->cur_ps_tdma == 4) {
+					ps21a_tdma(btcoexist, NORMAL_EXEC, true, 8);
+					coex_dm->ps_tdma_du_adj_type = 8;
+				}
+				if (coex_dm->cur_ps_tdma == 9) {
+					ps21a_tdma(btcoexist, NORMAL_EXEC, true, 14);
+					coex_dm->ps_tdma_du_adj_type = 14;
+				} else if (coex_dm->cur_ps_tdma == 10) {
+					ps21a_tdma(btcoexist, NORMAL_EXEC, true, 14);
+					coex_dm->ps_tdma_du_adj_type = 14;
+				} else if (coex_dm->cur_ps_tdma == 11) {
+					ps21a_tdma(btcoexist, NORMAL_EXEC, true, 15);
+					coex_dm->ps_tdma_du_adj_type = 15;
+				} else if (coex_dm->cur_ps_tdma == 12) {
+					ps21a_tdma(btcoexist, NORMAL_EXEC, true, 16);
+					coex_dm->ps_tdma_du_adj_type = 16;
+				}
+				if (result == -1) {
+					if (coex_dm->cur_ps_tdma == 5) {
+						ps21a_tdma(btcoexist, NORMAL_EXEC, true, 6);
+						coex_dm->ps_tdma_du_adj_type = 6;
+					} else if (coex_dm->cur_ps_tdma == 6) {
+						ps21a_tdma(btcoexist, NORMAL_EXEC, true, 7);
+						coex_dm->ps_tdma_du_adj_type = 7;
+					} else if (coex_dm->cur_ps_tdma == 7) {
+						ps21a_tdma(btcoexist, NORMAL_EXEC, true, 8);
+						coex_dm->ps_tdma_du_adj_type = 8;
+					} else if (coex_dm->cur_ps_tdma == 13) {
+						ps21a_tdma(btcoexist, NORMAL_EXEC, true, 14);
+						coex_dm->ps_tdma_du_adj_type = 14;
+					} else if (coex_dm->cur_ps_tdma == 14) {
+						ps21a_tdma(btcoexist, NORMAL_EXEC, true, 15);
+						coex_dm->ps_tdma_du_adj_type = 15;
+					} else if (coex_dm->cur_ps_tdma == 15) {
+						ps21a_tdma(btcoexist, NORMAL_EXEC, true, 16);
+						coex_dm->ps_tdma_du_adj_type = 16;
+					}
+				} else if (result == 1) {
+					if (coex_dm->cur_ps_tdma == 8) {
+						ps21a_tdma(btcoexist, NORMAL_EXEC, true, 7);
+						coex_dm->ps_tdma_du_adj_type = 7;
+					} else if (coex_dm->cur_ps_tdma == 7) {
+						ps21a_tdma(btcoexist, NORMAL_EXEC, true, 6);
+						coex_dm->ps_tdma_du_adj_type = 6;
+					} else if (coex_dm->cur_ps_tdma == 6) {
+						ps21a_tdma(btcoexist, NORMAL_EXEC, true, 6);
+						coex_dm->ps_tdma_du_adj_type = 6;
+					} else if (coex_dm->cur_ps_tdma == 16) {
+						ps21a_tdma(btcoexist, NORMAL_EXEC, true, 15);
+						coex_dm->ps_tdma_du_adj_type = 15;
+					} else if (coex_dm->cur_ps_tdma == 15) {
+						ps21a_tdma(btcoexist, NORMAL_EXEC, true, 14);
+						coex_dm->ps_tdma_du_adj_type = 14;
+					} else if (coex_dm->cur_ps_tdma == 14) {
+						ps21a_tdma(btcoexist, NORMAL_EXEC, true, 14);
+						coex_dm->ps_tdma_du_adj_type = 14;
+					}
+				}
+			} else {
+				/* TODO: refactor here */
+				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_DETAIL,
+					  "[BTCoex], TxPause = 0\n");
+				if (coex_dm->cur_ps_tdma == 5) {
+					ps21a_tdma(btcoexist, NORMAL_EXEC, true, 2);
+					coex_dm->ps_tdma_du_adj_type = 2;
+				} else if (coex_dm->cur_ps_tdma == 6) {
+					ps21a_tdma(btcoexist, NORMAL_EXEC, true, 2);
+					coex_dm->ps_tdma_du_adj_type = 2;
+				} else if (coex_dm->cur_ps_tdma == 7) {
+					ps21a_tdma(btcoexist, NORMAL_EXEC, true, 3);
+					coex_dm->ps_tdma_du_adj_type = 3;
+				} else if (coex_dm->cur_ps_tdma == 8) {
+					ps21a_tdma(btcoexist, NORMAL_EXEC, true, 4);
+					coex_dm->ps_tdma_du_adj_type = 4;
+				}
+				if (coex_dm->cur_ps_tdma == 13) {
+					ps21a_tdma(btcoexist, NORMAL_EXEC, true, 10);
+					coex_dm->ps_tdma_du_adj_type = 10;
+				} else if (coex_dm->cur_ps_tdma == 14) {
+					ps21a_tdma(btcoexist, NORMAL_EXEC, true, 10);
+					coex_dm->ps_tdma_du_adj_type = 10;
+				} else if (coex_dm->cur_ps_tdma == 15) {
+					ps21a_tdma(btcoexist, NORMAL_EXEC, true, 11);
+					coex_dm->ps_tdma_du_adj_type = 11;
+				} else if (coex_dm->cur_ps_tdma == 16) {
+					ps21a_tdma(btcoexist, NORMAL_EXEC, true, 12);
+					coex_dm->ps_tdma_du_adj_type = 12;
+				}
+				if (result == -1) {
+					if (coex_dm->cur_ps_tdma == 1) {
+						ps21a_tdma(btcoexist, NORMAL_EXEC, true, 2);
+						coex_dm->ps_tdma_du_adj_type = 2;
+					} else if (coex_dm->cur_ps_tdma == 2) {
+						ps21a_tdma(btcoexist, NORMAL_EXEC, true, 3);
+						coex_dm->ps_tdma_du_adj_type = 3;
+					} else if (coex_dm->cur_ps_tdma == 3) {
+						ps21a_tdma(btcoexist, NORMAL_EXEC, true, 4);
+						coex_dm->ps_tdma_du_adj_type = 4;
+					} else if (coex_dm->cur_ps_tdma == 9) {
+						ps21a_tdma(btcoexist, NORMAL_EXEC, true, 10);
+						coex_dm->ps_tdma_du_adj_type = 10;
+					} else if (coex_dm->cur_ps_tdma == 10) {
+						ps21a_tdma(btcoexist, NORMAL_EXEC, true, 11);
+						coex_dm->ps_tdma_du_adj_type = 11;
+					} else if (coex_dm->cur_ps_tdma == 11) {
+						ps21a_tdma(btcoexist, NORMAL_EXEC, true, 12);
+						coex_dm->ps_tdma_du_adj_type = 12;
+					}
+				} else if (result == 1) {
+					if (coex_dm->cur_ps_tdma == 4) {
+						ps21a_tdma(btcoexist, NORMAL_EXEC, true, 3);
+						coex_dm->ps_tdma_du_adj_type = 3;
+					} else if (coex_dm->cur_ps_tdma == 3) {
+						ps21a_tdma(btcoexist, NORMAL_EXEC, true, 2);
+						coex_dm->ps_tdma_du_adj_type = 2;
+					} else if (coex_dm->cur_ps_tdma == 2) {
+						ps21a_tdma(btcoexist, NORMAL_EXEC, true, 2);
+						coex_dm->ps_tdma_du_adj_type = 2;
+					} else if (coex_dm->cur_ps_tdma == 12) {
+						ps21a_tdma(btcoexist, NORMAL_EXEC, true, 11);
+						coex_dm->ps_tdma_du_adj_type = 11;
+					} else if (coex_dm->cur_ps_tdma == 11) {
+						ps21a_tdma(btcoexist, NORMAL_EXEC, true, 10);
+						coex_dm->ps_tdma_du_adj_type = 10;
+					} else if (coex_dm->cur_ps_tdma == 10) {
+						ps21a_tdma(btcoexist, NORMAL_EXEC, true, 10);
+						coex_dm->ps_tdma_du_adj_type = 10;
+					}
+				}
+			}
+		} else if (max_interval == 3) {
+			if (tx_pause) {
+				/* TODO: refactor here */
+				BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_DETAIL,
+					  "[BTCoex], TxPause = 1\n");
+				if (coex_dm->cur_ps_tdma == 1) {
+					ps21a_tdma(btcoexist, NORMAL_EXEC, true, 7);
+					coex_dm->ps_tdma_du_adj_type = 7;
+				} else if (coex_dm->cur_ps_tdma == 2) {
+					ps21a_tdma(btcoexist, NORMAL_EXEC, true, 7);
+					coex_dm->ps_tdma_du_adj_type = 7;
+				} else if (coex_dm->cur_ps_tdma == 3) {
+					ps21a_tdma(btcoexist, NORMAL_EXEC, true, 7);
+					coex_dm->ps_tdma_du_adj_type = 7;
+				} else if (coex_dm->cur_ps_tdma == 4) {
+					ps21a_tdma(btcoexist, NORMAL_EXEC, true, 8);
+					coex_dm->ps_tdma_du_adj_type = 8;
+				}
+				if (coex_dm->cur_ps_tdma == 9) {
+					ps21a_tdma(btcoexist, NORMAL_EXEC, true, 15);
+					coex_dm->ps_tdma_du_adj_type = 15;
+				} else if (coex_dm->cur_ps_tdma == 10) {
+					ps21a_tdma(btcoexist, NORMAL_EXEC, true, 15);
+					coex_dm->ps_tdma_du_adj_type = 15;
+				} else if (coex_dm->cur_ps_tdma == 11) {
+					ps21a_tdma(btcoexist, NORMAL_EXEC, true, 15);
+					coex_dm->ps_tdma_du_adj_type = 15;
+				} else if (coex_dm->cur_ps_tdma == 12) {
+					ps21a_tdma(btcoexist, NORMAL_EXEC, true, 16);
+					coex_dm->ps_tdma_du_adj_type = 16;
+				}
+				if (result == -1) {
+					if (coex_dm->cur_ps_tdma == 5) {
+						ps21a_tdma(btcoexist, NORMAL_EXEC, true, 7);
+						coex_dm->ps_tdma_du_adj_type = 7;
+					} else if (coex_dm->cur_ps_tdma == 6) {
+						ps21a_tdma(btcoexist, NORMAL_EXEC, true, 7);
+						coex_dm->ps_tdma_du_adj_type = 7;
+					} else if (coex_dm->cur_ps_tdma == 7) {
+						ps21a_tdma(btcoexist, NORMAL_EXEC, true, 8);
+						coex_dm->ps_tdma_du_adj_type = 8;
+					} else if (coex_dm->cur_ps_tdma == 13) {
+						ps21a_tdma(btcoexist, NORMAL_EXEC, true, 15);
+						coex_dm->ps_tdma_du_adj_type = 15;
+					} else if (coex_dm->cur_ps_tdma == 14) {
+						ps21a_tdma(btcoexist, NORMAL_EXEC, true, 15);
+						coex_dm->ps_tdma_du_adj_type = 15;
+					} else if (coex_dm->cur_ps_tdma == 15) {
+						ps21a_tdma(btcoexist, NORMAL_EXEC, true, 16);
+						coex_dm->ps_tdma_du_adj_type = 16;
+					}
+				} else if (result == 1) {
+					if (coex_dm->cur_ps_tdma == 8) {
+						ps21a_tdma(btcoexist, NORMAL_EXEC, true, 7);
+						coex_dm->ps_tdma_du_adj_type = 7;
+					} else if (coex_dm->cur_ps_tdma == 7) {
+						ps21a_tdma(btcoexist, NORMAL_EXEC, true, 7);
+						coex_dm->ps_tdma_du_adj_type = 7;
+					} else if (coex_dm->cur_ps_tdma == 6) {
+						ps21a_tdma(btcoexist, NORMAL_EXEC, true, 7);
+						coex_dm->ps_tdma_du_adj_type = 7;
+					} else if (coex_dm->cur_ps_tdma == 16) {
+						ps21a_tdma(btcoexist, NORMAL_EXEC, true, 15);
+						coex_dm->ps_tdma_du_adj_type = 15;
+					} else if (coex_dm->cur_ps_tdma == 15) {
+						ps21a_tdma(btcoexist, NORMAL_EXEC, true, 15);
+						coex_dm->ps_tdma_du_adj_type = 15;
+					} else if (coex_dm->cur_ps_tdma == 14) {
+						ps21a_tdma(btcoexist, NORMAL_EXEC, true, 15);
+						coex_dm->ps_tdma_du_adj_type = 15;
+					}
+				}
+			} else {
+				BTC_PRINT(BTC_MSG_ALGORITHM,
+					  ALGO_TRACE_FW_DETAIL,
+					  "[BTCoex], TxPause = 0\n");
+				if (coex_dm->cur_ps_tdma == 5) {
+					ps21a_tdma(btcoexist, NORMAL_EXEC,
+						   true, 3);
+					coex_dm->ps_tdma_du_adj_type = 3;
+				} else if (coex_dm->cur_ps_tdma == 6) {
+					ps21a_tdma(btcoexist, NORMAL_EXEC,
+						   true, 3);
+					coex_dm->ps_tdma_du_adj_type = 3;
+				} else if (coex_dm->cur_ps_tdma == 7) {
+					ps21a_tdma(btcoexist, NORMAL_EXEC,
+						   true, 3);
+					coex_dm->ps_tdma_du_adj_type = 3;
+				} else if (coex_dm->cur_ps_tdma == 8) {
+					ps21a_tdma(btcoexist, NORMAL_EXEC,
+						   true, 4);
+					coex_dm->ps_tdma_du_adj_type = 4;
+				}
+				if (coex_dm->cur_ps_tdma == 13) {
+					ps21a_tdma(btcoexist, NORMAL_EXEC,
+						   true, 11);
+					coex_dm->ps_tdma_du_adj_type = 11;
+				} else if (coex_dm->cur_ps_tdma == 14) {
+					ps21a_tdma(btcoexist, NORMAL_EXEC,
+						   true, 11);
+					coex_dm->ps_tdma_du_adj_type = 11;
+				} else if (coex_dm->cur_ps_tdma == 15) {
+					ps21a_tdma(btcoexist, NORMAL_EXEC,
+						   true, 11);
+					coex_dm->ps_tdma_du_adj_type = 11;
+				} else if (coex_dm->cur_ps_tdma == 16) {
+					ps21a_tdma(btcoexist, NORMAL_EXEC,
+						   true, 12);
+					coex_dm->ps_tdma_du_adj_type = 12;
+				}
+				if (result == -1) {
+					if (coex_dm->cur_ps_tdma == 1) {
+						ps21a_tdma(btcoexist,
+							   NORMAL_EXEC,
+							   true, 3);
+						coex_dm->ps_tdma_du_adj_type = 3;
+					} else if (coex_dm->cur_ps_tdma == 2) {
+						ps21a_tdma(btcoexist,
+							   NORMAL_EXEC,
+							   true, 3);
+						coex_dm->ps_tdma_du_adj_type = 3;
+					} else if (coex_dm->cur_ps_tdma == 3) {
+						ps21a_tdma(btcoexist,
+							   NORMAL_EXEC,
+							   true, 4);
+						coex_dm->ps_tdma_du_adj_type = 4;
+					} else if (coex_dm->cur_ps_tdma == 9) {
+						ps21a_tdma(btcoexist, NORMAL_EXEC, true, 11);
+						coex_dm->ps_tdma_du_adj_type = 11;
+					} else if (coex_dm->cur_ps_tdma == 10) {
+						ps21a_tdma(btcoexist, NORMAL_EXEC, true, 11);
+						coex_dm->ps_tdma_du_adj_type = 11;
+					} else if (coex_dm->cur_ps_tdma == 11) {
+						ps21a_tdma(btcoexist, NORMAL_EXEC, true, 12);
+						coex_dm->ps_tdma_du_adj_type = 12;
+					}
+				} else if (result == 1) {
+					if (coex_dm->cur_ps_tdma == 4) {
+						ps21a_tdma(btcoexist, NORMAL_EXEC, true, 3);
+						coex_dm->ps_tdma_du_adj_type = 3;
+					} else if (coex_dm->cur_ps_tdma == 3) {
+						ps21a_tdma(btcoexist, NORMAL_EXEC, true, 3);
+						coex_dm->ps_tdma_du_adj_type = 3;
+					} else if (coex_dm->cur_ps_tdma == 2) {
+						ps21a_tdma(btcoexist,
+							   NORMAL_EXEC, true, 3);
+						coex_dm->ps_tdma_du_adj_type = 3;
+					} else if (coex_dm->cur_ps_tdma == 12) {
+						ps21a_tdma(btcoexist, NORMAL_EXEC,
+							   true, 11);
+						coex_dm->ps_tdma_du_adj_type = 11;
+					} else if (coex_dm->cur_ps_tdma == 11) {
+						ps21a_tdma(btcoexist,
+							   NORMAL_EXEC, true, 11);
+						coex_dm->ps_tdma_du_adj_type = 11;
+					} else if (coex_dm->cur_ps_tdma == 10) {
+						ps21a_tdma(btcoexist,
+							   NORMAL_EXEC, true, 11);
+						coex_dm->ps_tdma_du_adj_type = 11;
+					}
+				}
+			}
+		}
+	}
+
+	/*  if current PsTdma not match with the recorded one
+	 * (when scan, dhcp...),
+	 *  then we have to adjust it back to the previous record one. */
+	if (coex_dm->cur_ps_tdma != coex_dm->ps_tdma_du_adj_type) {
+		bool scan = false, link = false, roam = false;
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_DETAIL,
+			  "[BTCoex], PsTdma type dismatch!!!, cur_ps_tdma =%d, recordPsTdma =%d\n",
+			  coex_dm->cur_ps_tdma, coex_dm->ps_tdma_du_adj_type);
+
+		btcoexist->btc_get(btcoexist, BTC_GET_BL_WIFI_SCAN, &scan);
+		btcoexist->btc_get(btcoexist, BTC_GET_BL_WIFI_LINK, &link);
+		btcoexist->btc_get(btcoexist, BTC_GET_BL_WIFI_ROAM, &roam);
+
+		if (!scan && !link && !roam)
+			ps21a_tdma(btcoexist, NORMAL_EXEC, true,
+				   coex_dm->ps_tdma_du_adj_type);
+		else
+			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_DETAIL,
+				  "[BTCoex], roaming/link/scan is under progress, will adjust next time!!!\n");
+	}
+
+	/* when tdma_duration_adjust() is called, fw dac swing is
+	 * included in the function. */
+	halbtc8821a2ant_fw_dac_swing_lvl(btcoexist, NORMAL_EXEC, 0x6);
+}
+
+/*  SCO only or SCO+PAN(HS) */
+static void halbtc8821a2ant_action_sco(struct btc_coexist *btcoexist)
+{
+	u8 wifi_rssi_state, bt_rssi_state;
+	u32 wifi_bw;
+
+	wifi_rssi_state = wifi21a_rssi_state(btcoexist, 0, 2, 15, 0);
+	bt_rssi_state = halbtc8821a2ant_bt_rssi_state(2, 35, 0);
+
+	halbtc8821a2ant_fw_dac_swing_lvl(btcoexist, NORMAL_EXEC, 4);
+
+	if (halbtc8821a2ant_need_to_dec_bt_pwr(btcoexist))
+		halbtc8821a2ant_dec_bt_pwr(btcoexist, NORMAL_EXEC, true);
+	else
+		halbtc8821a2ant_dec_bt_pwr(btcoexist, NORMAL_EXEC, false);
+
+	btcoexist->btc_get(btcoexist, BTC_GET_U4_WIFI_BW, &wifi_bw);
+
+	if (BTC_WIFI_BW_LEGACY == wifi_bw) /* for SCO quality at 11b/g mode */
+		halbtc8821a2ant_coex_table(btcoexist, NORMAL_EXEC, 0x5a5a5a5a,
+					   0x5a5a5a5a, 0xffff, 0x3);
+	else  /* for SCO quality & wifi performance balance at 11n mode */
+		halbtc8821a2ant_coex_table(btcoexist, NORMAL_EXEC, 0x5aea5aea,
+					   0x5aea5aea, 0xffff, 0x3);
+
+	if (BTC_WIFI_BW_HT40 == wifi_bw) {
+		/*  fw mechanism */
+		/* ps21a_tdma(btcoexist, NORMAL_EXEC, true, 5); */
+
+		if ((bt_rssi_state == BTC_RSSI_STATE_HIGH) ||
+		    (bt_rssi_state == BTC_RSSI_STATE_STAY_HIGH))
+			ps21a_tdma(btcoexist, NORMAL_EXEC,
+				   false, 0); /* for voice qual */
+		else
+			ps21a_tdma(btcoexist, NORMAL_EXEC,
+				   false, 0); /* for voice qual */
+
+		/*  sw mechanism */
+		if ((wifi_rssi_state == BTC_RSSI_STATE_HIGH) ||
+		    (wifi_rssi_state == BTC_RSSI_STATE_STAY_HIGH)) {
+			sw_mechanism1(btcoexist, true, true, false, false);
+			sw_mechanism2(btcoexist, true, false, false, 0x18);
+		} else {
+			sw_mechanism1(btcoexist, true, true, false, false);
+			sw_mechanism2(btcoexist, false, false, false, 0x18);
+		}
+	} else {
+		/*  fw mechanism */
+
+		if ((bt_rssi_state == BTC_RSSI_STATE_HIGH) ||
+		    (bt_rssi_state == BTC_RSSI_STATE_STAY_HIGH))
+			ps21a_tdma(btcoexist, NORMAL_EXEC,
+				   false, 0); /* for voice qual */
+		else
+			ps21a_tdma(btcoexist, NORMAL_EXEC,
+				   false, 0); /* for voice qual */
+
+		/*  sw mechanism */
+		if ((wifi_rssi_state == BTC_RSSI_STATE_HIGH) ||
+		    (wifi_rssi_state == BTC_RSSI_STATE_STAY_HIGH)) {
+			sw_mechanism1(btcoexist, false, true, false, false);
+			sw_mechanism2(btcoexist, true, false, false, 0x18);
+		} else {
+			sw_mechanism1(btcoexist, false, true, false, false);
+			sw_mechanism2(btcoexist, false, false, false, 0x18);
+		}
+	}
+}
+
+static void halbtc8821a2ant_action_hid(struct btc_coexist *btcoexist)
+{
+	u8 wifi_rssi_state, bt_rssi_state;
+	u32 wifi_bw;
+
+	wifi_rssi_state = wifi21a_rssi_state(btcoexist, 0, 2, 15, 0);
+	bt_rssi_state = halbtc8821a2ant_bt_rssi_state(2, 35, 0);
+
+	halbtc8821a2ant_fw_dac_swing_lvl(btcoexist, NORMAL_EXEC, 6);
+
+	if (halbtc8821a2ant_need_to_dec_bt_pwr(btcoexist))
+		halbtc8821a2ant_dec_bt_pwr(btcoexist, NORMAL_EXEC, true);
+	else
+		halbtc8821a2ant_dec_bt_pwr(btcoexist, NORMAL_EXEC, false);
+
+	btcoexist->btc_get(btcoexist, BTC_GET_U4_WIFI_BW, &wifi_bw);
+
+	if (BTC_WIFI_BW_LEGACY == wifi_bw) /* for HID at 11b/g mode */
+		halbtc8821a2ant_coex_table(btcoexist, NORMAL_EXEC, 0x55ff55ff,
+					   0x5a5a5a5a, 0xffff, 0x3);
+	else  /* for HID quality & wifi performance balance at 11n mode */
+		halbtc8821a2ant_coex_table(btcoexist, NORMAL_EXEC, 0x55ff55ff,
+					   0x5aea5aea, 0xffff, 0x3);
+
+	if (BTC_WIFI_BW_HT40 == wifi_bw) {
+		/*  fw mechanism */
+		if ((bt_rssi_state == BTC_RSSI_STATE_HIGH) ||
+		    (bt_rssi_state == BTC_RSSI_STATE_STAY_HIGH))
+			ps21a_tdma(btcoexist, NORMAL_EXEC, true, 9);
+		else
+			ps21a_tdma(btcoexist, NORMAL_EXEC, true, 13);
+		/*  sw mechanism */
+		if ((wifi_rssi_state == BTC_RSSI_STATE_HIGH) ||
+		    (wifi_rssi_state == BTC_RSSI_STATE_STAY_HIGH)) {
+			sw_mechanism1(btcoexist, true, true, false, false);
+			sw_mechanism2(btcoexist, true, false, false, 0x18);
+		} else {
+			sw_mechanism1(btcoexist, true, true, false, false);
+			sw_mechanism2(btcoexist, false, false, false, 0x18);
+		}
+	} else {
+		/*  fw mechanism */
+		if ((bt_rssi_state == BTC_RSSI_STATE_HIGH) ||
+		    (bt_rssi_state == BTC_RSSI_STATE_STAY_HIGH))
+			ps21a_tdma(btcoexist, NORMAL_EXEC, true, 9);
+		else
+			ps21a_tdma(btcoexist, NORMAL_EXEC, true, 13);
+
+		/*  sw mechanism */
+		if ((wifi_rssi_state == BTC_RSSI_STATE_HIGH) ||
+		    (wifi_rssi_state == BTC_RSSI_STATE_STAY_HIGH)) {
+			sw_mechanism1(btcoexist, false, true, false, false);
+			sw_mechanism2(btcoexist, true, false, false, 0x18);
+		} else {
+			sw_mechanism1(btcoexist, false, true, false, false);
+			sw_mechanism2(btcoexist, false, false, false, 0x18);
+		}
+	}
+}
+
+/* A2DP only / PAN(EDR) only/ A2DP+PAN(HS) */
+static void halbtc8821a2ant_action_a2dp(struct btc_coexist *btcoexist)
+{
+	u8 wifi_rssi_state, bt_rssi_state;
+	u32 wifi_bw;
+
+	wifi_rssi_state = wifi21a_rssi_state(btcoexist, 0, 2, 15, 0);
+	bt_rssi_state = halbtc8821a2ant_bt_rssi_state(2, 35, 0);
+
+	/* fw dac swing is called in tdma_duration_adjust() */
+	/* halbtc8821a2ant_fw_dac_swing_lvl(btcoexist, NORMAL_EXEC, 6); */
+
+	if (halbtc8821a2ant_need_to_dec_bt_pwr(btcoexist))
+		halbtc8821a2ant_dec_bt_pwr(btcoexist, NORMAL_EXEC, true);
+	else
+		halbtc8821a2ant_dec_bt_pwr(btcoexist, NORMAL_EXEC, false);
+
+	btcoexist->btc_get(btcoexist, BTC_GET_U4_WIFI_BW, &wifi_bw);
+
+	if (BTC_WIFI_BW_HT40 == wifi_bw) {
+		/*  fw mechanism */
+		if ((bt_rssi_state == BTC_RSSI_STATE_HIGH) ||
+		    (bt_rssi_state == BTC_RSSI_STATE_STAY_HIGH))
+			tdma_duration_adjust(btcoexist, false, false, 1);
+		else
+			tdma_duration_adjust(btcoexist, false, true, 1);
+
+		/*  sw mechanism */
+		if ((wifi_rssi_state == BTC_RSSI_STATE_HIGH) ||
+		    (wifi_rssi_state == BTC_RSSI_STATE_STAY_HIGH)) {
+			sw_mechanism1(btcoexist, true, false, false, false);
+			sw_mechanism2(btcoexist, true, false, false, 0x18);
+		} else {
+			sw_mechanism1(btcoexist, true, false, false, false);
+			sw_mechanism2(btcoexist, false, false, false, 0x18);
+		}
+	} else {
+		/*  fw mechanism */
+		if ((bt_rssi_state == BTC_RSSI_STATE_HIGH) ||
+		    (bt_rssi_state == BTC_RSSI_STATE_STAY_HIGH))
+			tdma_duration_adjust(btcoexist, false, false, 1);
+		else
+			tdma_duration_adjust(btcoexist, false, true, 1);
+
+		/*  sw mechanism */
+		if ((wifi_rssi_state == BTC_RSSI_STATE_HIGH) ||
+		    (wifi_rssi_state == BTC_RSSI_STATE_STAY_HIGH)) {
+			sw_mechanism1(btcoexist, false, false, false, false);
+			sw_mechanism2(btcoexist, true, false, false, 0x18);
+		} else {
+			sw_mechanism1(btcoexist, false, false, false, false);
+			sw_mechanism2(btcoexist, false, false, false, 0x18);
+		}
+	}
+}
+
+static void halbtc8821a2ant_action_a2dp_pan_hs(struct btc_coexist *btcoexist)
+{
+	u8 wifi_rssi_state, bt_rssi_state, bt_info_ext;
+	u32 wifi_bw;
+
+	bt_info_ext = coex_sta->bt_info_ext;
+	wifi_rssi_state = wifi21a_rssi_state(btcoexist, 0, 2, 15, 0);
+	bt_rssi_state = halbtc8821a2ant_bt_rssi_state(2, 35, 0);
+
+	/* fw dac swing is called in tdma_duration_adjust() */
+	/* halbtc8821a2ant_fw_dac_swing_lvl(btcoexist, NORMAL_EXEC, 6); */
+
+	if (halbtc8821a2ant_need_to_dec_bt_pwr(btcoexist))
+		halbtc8821a2ant_dec_bt_pwr(btcoexist, NORMAL_EXEC, true);
+	else
+		halbtc8821a2ant_dec_bt_pwr(btcoexist, NORMAL_EXEC, false);
+
+	btcoexist->btc_get(btcoexist, BTC_GET_U4_WIFI_BW, &wifi_bw);
+
+	if (BTC_WIFI_BW_HT40 == wifi_bw) {
+		/*  fw mechanism */
+		if (bt_info_ext & BIT(0))	/* a2dp basic rate */
+			tdma_duration_adjust(btcoexist, false, true, 2);
+		else				/* a2dp edr rate */
+			tdma_duration_adjust(btcoexist, false, true, 1);
+
+		/*  sw mechanism */
+		if ((wifi_rssi_state == BTC_RSSI_STATE_HIGH) ||
+		    (wifi_rssi_state == BTC_RSSI_STATE_STAY_HIGH)) {
+			sw_mechanism1(btcoexist, true, false, false, false);
+			sw_mechanism2(btcoexist, true, false, false, 0x18);
+		} else {
+			sw_mechanism1(btcoexist, true, false, false, false);
+			sw_mechanism2(btcoexist, false, false, false, 0x18);
+		}
+	} else {
+		/*  fw mechanism */
+		if (bt_info_ext & BIT(0))	/* a2dp basic rate */
+			tdma_duration_adjust(btcoexist, false, true, 2);
+		else				/* a2dp edr rate */
+			tdma_duration_adjust(btcoexist, false, true, 1);
+
+		/*  sw mechanism */
+		if ((wifi_rssi_state == BTC_RSSI_STATE_HIGH) ||
+		    (wifi_rssi_state == BTC_RSSI_STATE_STAY_HIGH)) {
+			sw_mechanism1(btcoexist, false, false, false, false);
+			sw_mechanism2(btcoexist, true, false, false, 0x18);
+		} else {
+			sw_mechanism1(btcoexist, false, false, false, false);
+			sw_mechanism2(btcoexist, false, false, false, 0x18);
+		}
+	}
+}
+
+static void halbtc8821a2ant_action_pan_edr(struct btc_coexist *btcoexist)
+{
+	u8 wifi_rssi_state, bt_rssi_state;
+	u32 wifi_bw;
+
+	wifi_rssi_state = wifi21a_rssi_state(btcoexist, 0, 2, 15, 0);
+	bt_rssi_state = halbtc8821a2ant_bt_rssi_state(2, 35, 0);
+
+	halbtc8821a2ant_fw_dac_swing_lvl(btcoexist, NORMAL_EXEC, 6);
+
+	if (halbtc8821a2ant_need_to_dec_bt_pwr(btcoexist))
+		halbtc8821a2ant_dec_bt_pwr(btcoexist, NORMAL_EXEC, true);
+	else
+		halbtc8821a2ant_dec_bt_pwr(btcoexist, NORMAL_EXEC, false);
+
+	btcoexist->btc_get(btcoexist, BTC_GET_U4_WIFI_BW, &wifi_bw);
+
+	if (BTC_WIFI_BW_LEGACY == wifi_bw) /* for HID at 11b/g mode */
+		halbtc8821a2ant_coex_table(btcoexist, NORMAL_EXEC, 0x55ff55ff,
+					   0x5aff5aff, 0xffff, 0x3);
+	else  /* for HID quality & wifi performance balance at 11n mode */
+		halbtc8821a2ant_coex_table(btcoexist, NORMAL_EXEC, 0x55ff55ff,
+					   0x5aff5aff, 0xffff, 0x3);
+
+		if (BTC_WIFI_BW_HT40 == wifi_bw) {
+			/*  fw mechanism */
+		if ((bt_rssi_state == BTC_RSSI_STATE_HIGH) ||
+		    (bt_rssi_state == BTC_RSSI_STATE_STAY_HIGH))
+			ps21a_tdma(btcoexist, NORMAL_EXEC, true, 1);
+		else
+			ps21a_tdma(btcoexist, NORMAL_EXEC, true, 5);
+
+		/*  sw mechanism */
+		if ((wifi_rssi_state == BTC_RSSI_STATE_HIGH) ||
+		    (wifi_rssi_state == BTC_RSSI_STATE_STAY_HIGH)) {
+			sw_mechanism1(btcoexist, true, false, false, false);
+			sw_mechanism2(btcoexist, true, false, false, 0x18);
+		} else {
+			sw_mechanism1(btcoexist, true, false, false, false);
+			sw_mechanism2(btcoexist, false, false, false, 0x18);
+		}
+	} else {
+		/*  fw mechanism */
+		if ((bt_rssi_state == BTC_RSSI_STATE_HIGH) ||
+		    (bt_rssi_state == BTC_RSSI_STATE_STAY_HIGH))
+			ps21a_tdma(btcoexist, NORMAL_EXEC, true, 1);
+		else
+			ps21a_tdma(btcoexist, NORMAL_EXEC, true, 5);
+
+		/*  sw mechanism */
+		if ((wifi_rssi_state == BTC_RSSI_STATE_HIGH) ||
+		    (wifi_rssi_state == BTC_RSSI_STATE_STAY_HIGH)) {
+			sw_mechanism1(btcoexist, false, false, false, false);
+			sw_mechanism2(btcoexist, true, false, false, 0x18);
+		} else {
+			sw_mechanism1(btcoexist, false, false, false, false);
+			sw_mechanism2(btcoexist, false, false, false, 0x18);
+		}
+	}
+}
+
+/* PAN(HS) only */
+static void halbtc8821a2ant_action_pan_hs(struct btc_coexist *btcoexist)
+{
+	u8 wifi_rssi_state, bt_rssi_state;
+	u32 wifi_bw;
+
+	wifi_rssi_state = wifi21a_rssi_state(btcoexist, 0, 2, 15, 0);
+	bt_rssi_state = halbtc8821a2ant_bt_rssi_state(2, 35, 0);
+
+	halbtc8821a2ant_fw_dac_swing_lvl(btcoexist, NORMAL_EXEC, 6);
+
+	btcoexist->btc_get(btcoexist, BTC_GET_U4_WIFI_BW, &wifi_bw);
+
+	if (BTC_WIFI_BW_HT40 == wifi_bw) {
+		/*  fw mechanism */
+		if ((wifi_rssi_state == BTC_RSSI_STATE_HIGH) ||
+		    (wifi_rssi_state == BTC_RSSI_STATE_STAY_HIGH))
+			halbtc8821a2ant_dec_bt_pwr(btcoexist, NORMAL_EXEC,
+						   true);
+		else
+			halbtc8821a2ant_dec_bt_pwr(btcoexist, NORMAL_EXEC,
+						   false);
+		ps21a_tdma(btcoexist, NORMAL_EXEC, false, 1);
+
+		/*  sw mechanism */
+		if ((wifi_rssi_state == BTC_RSSI_STATE_HIGH) ||
+		    (wifi_rssi_state == BTC_RSSI_STATE_STAY_HIGH)) {
+			sw_mechanism1(btcoexist, true, false, false, false);
+			sw_mechanism2(btcoexist, true, false, false, 0x18);
+		} else {
+			sw_mechanism1(btcoexist, true, false, false, false);
+			sw_mechanism2(btcoexist, false, false, false, 0x18);
+		}
+	} else {
+		/*  fw mechanism */
+		if ((wifi_rssi_state == BTC_RSSI_STATE_HIGH) ||
+		    (wifi_rssi_state == BTC_RSSI_STATE_STAY_HIGH))
+			halbtc8821a2ant_dec_bt_pwr(btcoexist, NORMAL_EXEC,
+						   true);
+		else
+			halbtc8821a2ant_dec_bt_pwr(btcoexist, NORMAL_EXEC,
+						   false);
+
+		if ((bt_rssi_state == BTC_RSSI_STATE_HIGH) ||
+		    (bt_rssi_state == BTC_RSSI_STATE_STAY_HIGH))
+			ps21a_tdma(btcoexist, NORMAL_EXEC, false, 1);
+		else
+			ps21a_tdma(btcoexist, NORMAL_EXEC, false, 1);
+
+		/*  sw mechanism */
+		if ((wifi_rssi_state == BTC_RSSI_STATE_HIGH) ||
+		    (wifi_rssi_state == BTC_RSSI_STATE_STAY_HIGH)) {
+			sw_mechanism1(btcoexist, false, false, false, false);
+			sw_mechanism2(btcoexist, true, false, false, 0x18);
+		} else {
+			sw_mechanism1(btcoexist, false, false, false, false);
+			sw_mechanism2(btcoexist, false, false, false, 0x18);
+		}
+	}
+}
+
+/* PAN(EDR)+A2DP */
+static void halbtc8821a2ant_action_pan_edr_a2dp(struct btc_coexist *btcoexist)
+{
+	u8 wifi_rssi_state, bt_rssi_state, bt_info_ext;
+	u32 wifi_bw;
+
+	bt_info_ext = coex_sta->bt_info_ext;
+	wifi_rssi_state = wifi21a_rssi_state(btcoexist, 0, 2, 15, 0);
+	bt_rssi_state = halbtc8821a2ant_bt_rssi_state(2, 35, 0);
+
+	halbtc8821a2ant_fw_dac_swing_lvl(btcoexist, NORMAL_EXEC, 6);
+
+	if (halbtc8821a2ant_need_to_dec_bt_pwr(btcoexist))
+		halbtc8821a2ant_dec_bt_pwr(btcoexist, NORMAL_EXEC, true);
+	else
+		halbtc8821a2ant_dec_bt_pwr(btcoexist, NORMAL_EXEC, false);
+
+	btcoexist->btc_get(btcoexist, BTC_GET_U4_WIFI_BW, &wifi_bw);
+
+	if (BTC_WIFI_BW_LEGACY == wifi_bw) /* for HID at 11b/g mode */
+		halbtc8821a2ant_coex_table(btcoexist, NORMAL_EXEC, 0x55ff55ff,
+					   0x5afa5afa, 0xffff, 0x3);
+	else  /* for HID quality & wifi performance balance at 11n mode */
+		halbtc8821a2ant_coex_table(btcoexist, NORMAL_EXEC, 0x55ff55ff,
+					   0x5afa5afa, 0xffff, 0x3);
+
+	if (BTC_WIFI_BW_HT40 == wifi_bw) {
+		/*  fw mechanism */
+		if ((bt_rssi_state == BTC_RSSI_STATE_HIGH) ||
+		    (bt_rssi_state == BTC_RSSI_STATE_STAY_HIGH)) {
+			if (bt_info_ext & BIT(0))	/* a2dp basic rate */
+				tdma_duration_adjust(btcoexist, false,
+						     false, 3);
+			else				/* a2dp edr rate */
+				tdma_duration_adjust(btcoexist, false,
+						     false, 3);
+		} else {
+			if (bt_info_ext & BIT(0))	/* a2dp basic rate */
+				tdma_duration_adjust(btcoexist, false, true, 3);
+			else				/* a2dp edr rate */
+				tdma_duration_adjust(btcoexist, false, true, 3);
+		}
+
+		/*  sw mechanism */
+		if ((wifi_rssi_state == BTC_RSSI_STATE_HIGH) ||
+		    (wifi_rssi_state == BTC_RSSI_STATE_STAY_HIGH)) {
+			sw_mechanism1(btcoexist, true, false, false, false);
+			sw_mechanism2(btcoexist, true, false, false, 0x18);
+		} else {
+			sw_mechanism1(btcoexist, true, false, false, false);
+			sw_mechanism2(btcoexist, false, false, false, 0x18);
+		};
+	} else {
+		/*  fw mechanism */
+		if ((bt_rssi_state == BTC_RSSI_STATE_HIGH) ||
+		    (bt_rssi_state == BTC_RSSI_STATE_STAY_HIGH)) {
+			if (bt_info_ext & BIT(0))	/* a2dp basic rate */
+				tdma_duration_adjust(btcoexist, false,
+						     false, 3);
+			else				/* a2dp edr rate */
+				tdma_duration_adjust(btcoexist, false,
+						     false, 3);
+		} else {
+			if (bt_info_ext & BIT(0))	/* a2dp basic rate */
+				tdma_duration_adjust(btcoexist, false, true, 3);
+			else				/* a2dp edr rate */
+				tdma_duration_adjust(btcoexist, false, true, 3);
+		}
+
+		/*  sw mechanism */
+		if ((wifi_rssi_state == BTC_RSSI_STATE_HIGH) ||
+		    (wifi_rssi_state == BTC_RSSI_STATE_STAY_HIGH)) {
+			sw_mechanism1(btcoexist, false, false, false, false);
+			sw_mechanism2(btcoexist, true, false, false, 0x18);
+		} else {
+			sw_mechanism1(btcoexist, false, false, false, false);
+			sw_mechanism2(btcoexist, false, false, false, 0x18);
+		}
+	}
+}
+
+static void halbtc8821a2ant_action_pan_edr_hid(struct btc_coexist *btcoexist)
+{
+	u8 wifi_rssi_state, bt_rssi_state;
+	u32 wifi_bw;
+
+	wifi_rssi_state = wifi21a_rssi_state(btcoexist, 0, 2, 15, 0);
+	bt_rssi_state = halbtc8821a2ant_bt_rssi_state(2, 35, 0);
+
+	halbtc8821a2ant_fw_dac_swing_lvl(btcoexist, NORMAL_EXEC, 6);
+
+	if (halbtc8821a2ant_need_to_dec_bt_pwr(btcoexist))
+		halbtc8821a2ant_dec_bt_pwr(btcoexist, NORMAL_EXEC, true);
+	else
+		halbtc8821a2ant_dec_bt_pwr(btcoexist, NORMAL_EXEC, false);
+
+	btcoexist->btc_get(btcoexist, BTC_GET_U4_WIFI_BW, &wifi_bw);
+
+	if (BTC_WIFI_BW_LEGACY == wifi_bw) /* for HID at 11b/g mode */
+		halbtc8821a2ant_coex_table(btcoexist, NORMAL_EXEC, 0x55ff55ff,
+					   0x5a5f5a5f, 0xffff, 0x3);
+	else  /* for HID quality & wifi performance balance at 11n mode */
+		halbtc8821a2ant_coex_table(btcoexist, NORMAL_EXEC, 0x55ff55ff,
+					   0x5a5f5a5f, 0xffff, 0x3);
+
+	if (BTC_WIFI_BW_HT40 == wifi_bw) {
+		halbtc8821a2ant_fw_dac_swing_lvl(btcoexist, NORMAL_EXEC, 3);
+		/*  fw mechanism */
+		if ((bt_rssi_state == BTC_RSSI_STATE_HIGH) ||
+		    (bt_rssi_state == BTC_RSSI_STATE_STAY_HIGH))
+			ps21a_tdma(btcoexist, NORMAL_EXEC, true, 10);
+		else
+			ps21a_tdma(btcoexist, NORMAL_EXEC, true, 14);
+
+		/*  sw mechanism */
+		if ((wifi_rssi_state == BTC_RSSI_STATE_HIGH) ||
+		    (wifi_rssi_state == BTC_RSSI_STATE_STAY_HIGH)) {
+			sw_mechanism1(btcoexist, true, true, false, false);
+			sw_mechanism2(btcoexist, true, false, false, 0x18);
+		} else {
+			sw_mechanism1(btcoexist, true, true, false, false);
+			sw_mechanism2(btcoexist, false, false, false, 0x18);
+		}
+	} else {
+		halbtc8821a2ant_fw_dac_swing_lvl(btcoexist, NORMAL_EXEC, 6);
+		/*  fw mechanism */
+		if ((bt_rssi_state == BTC_RSSI_STATE_HIGH) ||
+		    (bt_rssi_state == BTC_RSSI_STATE_STAY_HIGH))
+			ps21a_tdma(btcoexist, NORMAL_EXEC, true, 10);
+		else
+			ps21a_tdma(btcoexist, NORMAL_EXEC, true, 14);
+
+		/*  sw mechanism */
+		if ((wifi_rssi_state == BTC_RSSI_STATE_HIGH) ||
+		    (wifi_rssi_state == BTC_RSSI_STATE_STAY_HIGH)) {
+			sw_mechanism1(btcoexist, false, true, false, false);
+			sw_mechanism2(btcoexist, true, false, false, 0x18);
+		} else {
+			sw_mechanism1(btcoexist, false, true, false, false);
+			sw_mechanism2(btcoexist, false, false, false, 0x18);
+		}
+	}
+}
+
+/*  HID+A2DP+PAN(EDR) */
+static void action_hid_a2dp_pan_edr(struct btc_coexist *btcoexist)
+{
+	u8 wifi_rssi_state, bt_rssi_state, bt_info_ext;
+	u32 wifi_bw;
+
+	bt_info_ext = coex_sta->bt_info_ext;
+	wifi_rssi_state = wifi21a_rssi_state(btcoexist, 0, 2, 15, 0);
+	bt_rssi_state = halbtc8821a2ant_bt_rssi_state(2, 35, 0);
+
+	halbtc8821a2ant_fw_dac_swing_lvl(btcoexist, NORMAL_EXEC, 6);
+
+	if (halbtc8821a2ant_need_to_dec_bt_pwr(btcoexist))
+		halbtc8821a2ant_dec_bt_pwr(btcoexist, NORMAL_EXEC, true);
+	else
+		halbtc8821a2ant_dec_bt_pwr(btcoexist, NORMAL_EXEC, false);
+
+	btcoexist->btc_get(btcoexist, BTC_GET_U4_WIFI_BW, &wifi_bw);
+
+	if (BTC_WIFI_BW_LEGACY == wifi_bw) /* for HID at 11b/g mode */
+		halbtc8821a2ant_coex_table(btcoexist, NORMAL_EXEC, 0x55ff55ff,
+					   0x5a5a5a5a, 0xffff, 0x3);
+	else  /* for HID quality & wifi performance balance at 11n mode */
+		halbtc8821a2ant_coex_table(btcoexist, NORMAL_EXEC, 0x55ff55ff,
+					   0x5a5a5a5a, 0xffff, 0x3);
+
+	if (BTC_WIFI_BW_HT40 == wifi_bw) {
+		/*  fw mechanism */
+		if ((bt_rssi_state == BTC_RSSI_STATE_HIGH) ||
+		    (bt_rssi_state == BTC_RSSI_STATE_STAY_HIGH)) {
+			if (bt_info_ext & BIT(0)) {	/* a2dp basic rate */
+				tdma_duration_adjust(btcoexist, true, true, 3);
+			} else {
+				/* a2dp edr rate */
+				tdma_duration_adjust(btcoexist, true, true, 3);
+			}
+		} else {
+			if (bt_info_ext & BIT(0))	/* a2dp basic rate */
+				tdma_duration_adjust(btcoexist, true, true, 3);
+			else				/* a2dp edr rate */
+				tdma_duration_adjust(btcoexist, true, true, 3);
+		}
+
+		/*  sw mechanism */
+		if ((wifi_rssi_state == BTC_RSSI_STATE_HIGH) ||
+		    (wifi_rssi_state == BTC_RSSI_STATE_STAY_HIGH)) {
+			sw_mechanism1(btcoexist, true, true, false, false);
+			sw_mechanism2(btcoexist, true, false, false, 0x18);
+		} else {
+			sw_mechanism1(btcoexist, true, true, false, false);
+			sw_mechanism2(btcoexist, false, false, false, 0x18);
+		}
+	} else {
+		/*  fw mechanism */
+		if ((bt_rssi_state == BTC_RSSI_STATE_HIGH) ||
+		    (bt_rssi_state == BTC_RSSI_STATE_STAY_HIGH)) {
+			if (bt_info_ext & BIT(0))	/* a2dp basic rate */
+				tdma_duration_adjust(btcoexist, true, false, 3);
+			else				/* a2dp edr rate */
+				tdma_duration_adjust(btcoexist, true, false, 3);
+		} else {
+			if (bt_info_ext & BIT(0)) {
+				/* a2dp basic rate */
+				tdma_duration_adjust(btcoexist, true, true, 3);
+			} else				/* a2dp edr rate */ {
+				tdma_duration_adjust(btcoexist, true, true, 3);
+			}
+		}
+
+		/*  sw mechanism */
+		if ((wifi_rssi_state == BTC_RSSI_STATE_HIGH) ||
+		    (wifi_rssi_state == BTC_RSSI_STATE_STAY_HIGH)) {
+			sw_mechanism1(btcoexist, false, true, false, false);
+			sw_mechanism2(btcoexist, true, false, false, 0x18);
+		} else {
+			sw_mechanism1(btcoexist, false, true, false, false);
+			sw_mechanism2(btcoexist, false, false, false, 0x18);
+		}
+	}
+}
+
+static void halbtc8821a2ant_action_hid_a2dp(struct btc_coexist *btcoexist)
+{
+	u8 wifi_rssi_state, bt_rssi_state, bt_info_ext;
+	u32 wifi_bw;
+
+	bt_info_ext = coex_sta->bt_info_ext;
+	wifi_rssi_state = wifi21a_rssi_state(btcoexist, 0, 2, 15, 0);
+	bt_rssi_state = halbtc8821a2ant_bt_rssi_state(2, 35, 0);
+
+	if (halbtc8821a2ant_need_to_dec_bt_pwr(btcoexist))
+		halbtc8821a2ant_dec_bt_pwr(btcoexist, NORMAL_EXEC, true);
+	else
+		halbtc8821a2ant_dec_bt_pwr(btcoexist, NORMAL_EXEC, false);
+
+	btcoexist->btc_get(btcoexist, BTC_GET_U4_WIFI_BW, &wifi_bw);
+
+	if (BTC_WIFI_BW_LEGACY == wifi_bw) /* for HID at 11b/g mode */
+		halbtc8821a2ant_coex_table(btcoexist, NORMAL_EXEC, 0x55ff55ff,
+					   0x5f5b5f5b, 0xffffff, 0x3);
+	else  /* for HID quality & wifi performance balance at 11n mode */
+		halbtc8821a2ant_coex_table(btcoexist, NORMAL_EXEC, 0x55ff55ff,
+					   0x5f5b5f5b, 0xffffff, 0x3);
+
+	if (BTC_WIFI_BW_HT40 == wifi_bw) {
+		/*  fw mechanism */
+		if ((bt_rssi_state == BTC_RSSI_STATE_HIGH) ||
+		    (bt_rssi_state == BTC_RSSI_STATE_STAY_HIGH)) {
+			if (bt_info_ext & BIT(0))	/* a2dp basic rate */
+				tdma_duration_adjust(btcoexist, true, true, 2);
+			else				/* a2dp edr rate */
+				tdma_duration_adjust(btcoexist, true, true, 2);
+		} else {
+			if (bt_info_ext & BIT(0))	/* a2dp basic rate */
+				tdma_duration_adjust(btcoexist, true, true, 2);
+			else				/* a2dp edr rate */
+				tdma_duration_adjust(btcoexist, true, true, 2);
+		}
+
+		/*  sw mechanism */
+		if ((wifi_rssi_state == BTC_RSSI_STATE_HIGH) ||
+		    (wifi_rssi_state == BTC_RSSI_STATE_STAY_HIGH)) {
+			sw_mechanism1(btcoexist, true, true, false, false);
+			sw_mechanism2(btcoexist, true, false, false, 0x18);
+		} else {
+			sw_mechanism1(btcoexist, true, true, false, false);
+			sw_mechanism2(btcoexist, false, false, false, 0x18);
+		}
+	} else {
+		/*  fw mechanism */
+		if ((bt_rssi_state == BTC_RSSI_STATE_HIGH) ||
+		    (bt_rssi_state == BTC_RSSI_STATE_STAY_HIGH)) {
+			if (bt_info_ext & BIT(0))	/* a2dp basic rate */
+				tdma_duration_adjust(btcoexist, true, true, 2);
+			else				/* a2dp edr rate */
+				tdma_duration_adjust(btcoexist, true, true, 2);
+		} else {
+			if (bt_info_ext & BIT(0))	/* a2dp basic rate */
+				tdma_duration_adjust(btcoexist, true, true, 2);
+			else				/* a2dp edr rate */
+				tdma_duration_adjust(btcoexist, true, true, 2);
+		}
+
+		/*  sw mechanism */
+		if ((wifi_rssi_state == BTC_RSSI_STATE_HIGH) ||
+		    (wifi_rssi_state == BTC_RSSI_STATE_STAY_HIGH)) {
+			sw_mechanism1(btcoexist, false, true, false, false);
+			sw_mechanism2(btcoexist, true, false, false, 0x18);
+		} else {
+			sw_mechanism1(btcoexist, false, true, false, false);
+			sw_mechanism2(btcoexist, false, false, false, 0x18);
+		}
+	}
+}
+
+static void halbtc8821a2ant_run_coexist_mechanism(struct btc_coexist *btcoexist)
+{
+	bool wifi_under_5g = false;
+	u8 algorithm = 0;
+
+	if (btcoexist->manual_control) {
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+			  "[BTCoex], Manual control!!!\n");
+		return;
+	}
+
+	btcoexist->btc_get(btcoexist, BTC_GET_BL_WIFI_UNDER_5G, &wifi_under_5g);
+
+	if (wifi_under_5g) {
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+			  "[BTCoex], RunCoexistMechanism(), run 5G coex setting!!<===\n");
+		halbtc8821a2ant_coex_under_5g(btcoexist);
+		return;
+	}
+
+	algorithm = halbtc8821a2ant_action_algorithm(btcoexist);
+	if (coex_sta->c2h_bt_inquiry_page &&
+	    (BT_8821A_2ANT_COEX_ALGO_PANHS != algorithm)) {
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+			  "[BTCoex], BT is under inquiry/page scan !!\n");
+		halbtc8821a2ant_bt_inquiry_page(btcoexist);
+		return;
+	}
+
+	coex_dm->cur_algorithm = algorithm;
+	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+		  "[BTCoex], Algorithm = %d\n", coex_dm->cur_algorithm);
+
+	if (halbtc8821a2ant_is_common_action(btcoexist)) {
+		BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+			  "[BTCoex], Action 2-Ant common.\n");
+		coex_dm->reset_tdma_adjust = true;
+	} else {
+		if (coex_dm->cur_algorithm != coex_dm->pre_algorithm) {
+			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+				  "[BTCoex], pre_algorithm =%d, cur_algorithm =%d\n",
+				  coex_dm->pre_algorithm,
+				  coex_dm->cur_algorithm);
+			coex_dm->reset_tdma_adjust = true;
+		}
+		switch (coex_dm->cur_algorithm) {
+		case BT_8821A_2ANT_COEX_ALGO_SCO:
+			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+				  "[BTCoex], Action 2-Ant, algorithm = SCO.\n");
+			halbtc8821a2ant_action_sco(btcoexist);
+			break;
+		case BT_8821A_2ANT_COEX_ALGO_HID:
+			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+				  "[BTCoex], Action 2-Ant, algorithm = HID.\n");
+			halbtc8821a2ant_action_hid(btcoexist);
+			break;
+		case BT_8821A_2ANT_COEX_ALGO_A2DP:
+			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+				  "[BTCoex], Action 2-Ant, algorithm = A2DP.\n");
+			halbtc8821a2ant_action_a2dp(btcoexist);
+			break;
+		case BT_8821A_2ANT_COEX_ALGO_A2DP_PANHS:
+			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+				  "[BTCoex], Action 2-Ant, algorithm = A2DP+PAN(HS).\n");
+			halbtc8821a2ant_action_a2dp_pan_hs(btcoexist);
+			break;
+		case BT_8821A_2ANT_COEX_ALGO_PANEDR:
+			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+				  "[BTCoex], Action 2-Ant, algorithm = PAN(EDR).\n");
+			halbtc8821a2ant_action_pan_edr(btcoexist);
+			break;
+		case BT_8821A_2ANT_COEX_ALGO_PANHS:
+			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+				  "[BTCoex], Action 2-Ant, algorithm = HS mode.\n");
+			halbtc8821a2ant_action_pan_hs(btcoexist);
+			break;
+		case BT_8821A_2ANT_COEX_ALGO_PANEDR_A2DP:
+			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+				  "[BTCoex], Action 2-Ant, algorithm = PAN+A2DP.\n");
+			halbtc8821a2ant_action_pan_edr_a2dp(btcoexist);
+			break;
+		case BT_8821A_2ANT_COEX_ALGO_PANEDR_HID:
+			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+				  "[BTCoex], Action 2-Ant, algorithm = PAN(EDR)+HID.\n");
+			halbtc8821a2ant_action_pan_edr_hid(btcoexist);
+			break;
+		case BT_8821A_2ANT_COEX_ALGO_HID_A2DP_PANEDR:
+			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+				  "[BTCoex], Action 2-Ant, algorithm = HID+A2DP+PAN.\n");
+			action_hid_a2dp_pan_edr(btcoexist);
+			break;
+		case BT_8821A_2ANT_COEX_ALGO_HID_A2DP:
+			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+				  "[BTCoex], Action 2-Ant, algorithm = HID+A2DP.\n");
+			halbtc8821a2ant_action_hid_a2dp(btcoexist);
+			break;
+		default:
+			BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+				  "[BTCoex], Action 2-Ant, algorithm = coexist All Off!!\n");
+			halbtc8821a2ant_coex_all_off(btcoexist);
+			break;
+		}
+		coex_dm->pre_algorithm = coex_dm->cur_algorithm;
+	}
+}
+
+/*  work around function start with wa_halbtc8821a2ant_ */
+/*  extern function start with EXhalbtc8821a2ant_ */
+void ex_halbtc8821a2ant_init_hwconfig(struct btc_coexist *btcoexist)
+{
+	u8 u1tmp = 0;
+
+	BTC_PRINT(BTC_MSG_INTERFACE, INTF_INIT,
+		  "[BTCoex], 2Ant Init HW Config!!\n");
+
+	/*  backup rf 0x1e value */
+	coex_dm->bt_rf0x1e_backup =
+		btcoexist->btc_get_rf_reg(btcoexist, BTC_RF_A, 0x1e, 0xfffff);
+
+	/*  0x790[5:0] = 0x5 */
+	u1tmp = btcoexist->btc_read_1byte(btcoexist, 0x790);
+	u1tmp &= 0xc0;
+	u1tmp |= 0x5;
+	btcoexist->btc_write_1byte(btcoexist, 0x790, u1tmp);
+
+	/* Antenna config */
+	halbtc8821a2ant_set_ant_path(btcoexist, BTC_ANT_WIFI_AT_MAIN,
+				     true, false);
+
+	/*  PTA parameter */
+	halbtc8821a2ant_coex_table(btcoexist, FORCE_EXEC,
+				   0x55555555, 0x55555555,
+				   0xffff, 0x3);
+
+	/*  Enable counter statistics */
+	/* 0x76e[3] = 1, WLAN_Act control by PTA */
+	btcoexist->btc_write_1byte(btcoexist, 0x76e, 0xc);
+	btcoexist->btc_write_1byte(btcoexist, 0x778, 0x3);
+	btcoexist->btc_write_1byte_bitmask(btcoexist, 0x40, 0x20, 0x1);
+}
+
+void ex_halbtc8821a2ant_init_coex_dm(struct btc_coexist *btcoexist)
+{
+	BTC_PRINT(BTC_MSG_INTERFACE, INTF_INIT,
+		  "[BTCoex], Coex Mechanism Init!!\n");
+
+	halbtc8821a2ant_init_coex_dm(btcoexist);
+}
+
+void ex_halbtc8821a2ant_display_coex_info(struct btc_coexist *btcoexist)
+{
+	struct btc_board_info *board_info = &btcoexist->board_info;
+	struct btc_stack_info *stack_info = &btcoexist->stack_info;
+	u8 *cli_buf = btcoexist->cli_buf;
+	u8 u1tmp[4], i, bt_info_ext, ps_tdma_case = 0;
+	u32 u4tmp[4];
+	bool roam = false, scan = false, link = false, wifi_under_5g = false;
+	bool bt_hs_on = false, wifi_busy = false;
+	long wifi_rssi = 0, bt_hs_rssi = 0;
+	u32 wifi_bw, wifi_traffic_dir;
+	u8 wifi_dot_11_chnl, wifi_hs_chnl;
+	u32 fw_ver = 0, bt_patch_ver = 0;
+
+	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE,
+		   "\n ============[BT Coexist info] ============");
+	CL_PRINTF(cli_buf);
+
+	if (!board_info->bt_exist) {
+		CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\n BT not exists !!!");
+		CL_PRINTF(cli_buf);
+		return;
+	}
+
+	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\n %-35s = %d/ %d ",
+		   "Ant PG number/ Ant mechanism: ",
+		   board_info->pg_ant_num, board_info->btdm_ant_num);
+	CL_PRINTF(cli_buf);
+
+	if (btcoexist->manual_control) {
+		CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\n %-35s",
+			   "[Action Manual control]!!");
+		CL_PRINTF(cli_buf);
+	}
+
+	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\n %-35s = %s / %d",
+		   "BT stack/ hci ext ver",
+		   ((stack_info->profile_notified) ? "Yes" : "No"),
+		   stack_info->hci_version);
+	CL_PRINTF(cli_buf);
+
+	btcoexist->btc_get(btcoexist, BTC_GET_U4_BT_PATCH_VER, &bt_patch_ver);
+	btcoexist->btc_get(btcoexist, BTC_GET_U4_WIFI_FW_VER, &fw_ver);
+	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\n %-35s = %d_%d/ 0x%x/ 0x%x(%d)",
+		   "CoexVer/ FwVer/ PatchVer",
+		   glcoex_ver_date_8821a_2ant, glcoex_ver_8821a_2ant,
+		   fw_ver, bt_patch_ver, bt_patch_ver);
+	CL_PRINTF(cli_buf);
+
+	btcoexist->btc_get(btcoexist, BTC_GET_BL_HS_OPERATION, &bt_hs_on);
+	btcoexist->btc_get(btcoexist, BTC_GET_U1_WIFI_DOT11_CHNL,
+			   &wifi_dot_11_chnl);
+	btcoexist->btc_get(btcoexist, BTC_GET_U1_WIFI_HS_CHNL, &wifi_hs_chnl);
+	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\n %-35s = %d / %d(%d)",
+		   "Dot11 channel / HsMode(HsChnl)",
+		   wifi_dot_11_chnl, bt_hs_on, wifi_hs_chnl);
+	CL_PRINTF(cli_buf);
+
+	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE,
+		   "\n %-35s = %02x %02x %02x ", "H2C Wifi inform bt chnl Info",
+		   coex_dm->wifi_chnl_info[0], coex_dm->wifi_chnl_info[1],
+		   coex_dm->wifi_chnl_info[2]);
+	CL_PRINTF(cli_buf);
+
+	btcoexist->btc_get(btcoexist, BTC_GET_S4_WIFI_RSSI, &wifi_rssi);
+	btcoexist->btc_get(btcoexist, BTC_GET_S4_HS_RSSI, &bt_hs_rssi);
+	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE,
+		   "\n %-35s = %ld/ %ld", "Wifi rssi/ HS rssi",
+		   wifi_rssi, bt_hs_rssi);
+	CL_PRINTF(cli_buf);
+
+	btcoexist->btc_get(btcoexist, BTC_GET_BL_WIFI_SCAN, &scan);
+	btcoexist->btc_get(btcoexist, BTC_GET_BL_WIFI_LINK, &link);
+	btcoexist->btc_get(btcoexist, BTC_GET_BL_WIFI_ROAM, &roam);
+	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\n %-35s = %d/ %d/ %d ",
+		   "Wifi link/ roam/ scan",
+		   link, roam, scan);
+	CL_PRINTF(cli_buf);
+
+	btcoexist->btc_get(btcoexist, BTC_GET_BL_WIFI_UNDER_5G, &wifi_under_5g);
+	btcoexist->btc_get(btcoexist, BTC_GET_U4_WIFI_BW, &wifi_bw);
+	btcoexist->btc_get(btcoexist, BTC_GET_BL_WIFI_BUSY, &wifi_busy);
+	btcoexist->btc_get(btcoexist, BTC_GET_U4_WIFI_TRAFFIC_DIRECTION,
+			   &wifi_traffic_dir);
+	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\n %-35s = %s / %s/ %s ",
+		   "Wifi status",
+		   (wifi_under_5g ? "5G" : "2.4G"),
+		   ((BTC_WIFI_BW_LEGACY == wifi_bw) ? "Legacy" :
+		    (((BTC_WIFI_BW_HT40 == wifi_bw) ? "HT40" : "HT20"))),
+		   ((!wifi_busy) ? "idle" :
+		    ((BTC_WIFI_TRAFFIC_TX == wifi_traffic_dir) ? "uplink" :
+		    "downlink")));
+	CL_PRINTF(cli_buf);
+
+	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\n %-35s = [%s/ %d/ %d] ",
+		   "BT [status/ rssi/ retryCnt]",
+		   ((coex_sta->c2h_bt_inquiry_page) ? ("inquiry/page scan") :
+		   ((BT_8821A_2ANT_BT_STATUS_IDLE == coex_dm->bt_status) ?
+		    "idle" : ((BT_8821A_2ANT_BT_STATUS_CONNECTED_IDLE ==
+		    coex_dm->bt_status) ? "connected-idle" : "busy"))),
+		coex_sta->bt_rssi, coex_sta->bt_retry_cnt);
+	CL_PRINTF(cli_buf);
+
+	if (stack_info->profile_notified) {
+		CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE,
+			   "\n %-35s = %d / %d / %d / %d", "SCO/HID/PAN/A2DP",
+			   stack_info->sco_exist, stack_info->hid_exist,
+			   stack_info->pan_exist, stack_info->a2dp_exist);
+		CL_PRINTF(cli_buf);
+
+		btcoexist->btc_disp_dbg_msg(btcoexist,
+					    BTC_DBG_DISP_BT_LINK_INFO);
+	}
+
+	bt_info_ext = coex_sta->bt_info_ext;
+	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\n %-35s = %s",
+		   "BT Info A2DP rate",
+		   (bt_info_ext & BIT(0)) ? "Basic rate" : "EDR rate");
+	CL_PRINTF(cli_buf);
+
+	for (i = 0; i < BT_INFO_SRC_8821A_2ANT_MAX; i++) {
+		if (coex_sta->bt_info_c2h_cnt[i]) {
+			CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE,
+				   "\n %-35s = %02x %02x %02x %02x %02x %02x %02x(%d)",
+				   glbt_info_src_8821a_2ant[i],
+				   coex_sta->bt_info_c2h[i][0],
+				   coex_sta->bt_info_c2h[i][1],
+				   coex_sta->bt_info_c2h[i][2],
+				   coex_sta->bt_info_c2h[i][3],
+				   coex_sta->bt_info_c2h[i][4],
+				   coex_sta->bt_info_c2h[i][5],
+				   coex_sta->bt_info_c2h[i][6],
+				   coex_sta->bt_info_c2h_cnt[i]);
+			CL_PRINTF(cli_buf);
+		}
+	}
+
+	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\n %-35s = %s/%s",
+		   "PS state, IPS/LPS",
+		   ((coex_sta->under_ips ? "IPS ON" : "IPS OFF")),
+		   ((coex_sta->under_lps ? "LPS ON" : "LPS OFF")));
+	CL_PRINTF(cli_buf);
+	btcoexist->btc_disp_dbg_msg(btcoexist, BTC_DBG_DISP_FW_PWR_MODE_CMD);
+
+	/*  Sw mechanism	 */
+	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\n %-35s",
+		   "============[Sw mechanism] ============");
+	CL_PRINTF(cli_buf);
+	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\n %-35s = %d/ %d/ %d/ %d ",
+		   "SM1[ShRf/ LpRA/ LimDig/ btLna]",
+		   coex_dm->cur_rf_rx_lpf_shrink, coex_dm->cur_low_penalty_ra,
+		   coex_dm->limited_dig, coex_dm->cur_bt_lna_constrain);
+	CL_PRINTF(cli_buf);
+	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\n %-35s = %d/ %d/ %d(0x%x) ",
+		   "SM2[AgcT/ AdcB/ SwDacSwing(lvl)]",
+		   coex_dm->cur_agc_table_en, coex_dm->cur_adc_back_off,
+		   coex_dm->cur_dac_swing_on, coex_dm->cur_dac_swing_lvl);
+	CL_PRINTF(cli_buf);
+
+	/*  Fw mechanism		 */
+	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\n %-35s",
+		   "============[Fw mechanism] ============");
+	CL_PRINTF(cli_buf);
+
+	if (!btcoexist->manual_control) {
+		ps_tdma_case = coex_dm->cur_ps_tdma;
+		CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE,
+			   "\n %-35s = %02x %02x %02x %02x %02x case-%d",
+			   "PS TDMA",
+			   coex_dm->ps_tdma_para[0], coex_dm->ps_tdma_para[1],
+			   coex_dm->ps_tdma_para[2], coex_dm->ps_tdma_para[3],
+			   coex_dm->ps_tdma_para[4], ps_tdma_case);
+		CL_PRINTF(cli_buf);
+
+		CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\n %-35s = %d/ %d ",
+			   "DecBtPwr/ IgnWlanAct",
+			   coex_dm->cur_dec_bt_pwr,
+			   coex_dm->cur_ignore_wlan_act);
+		CL_PRINTF(cli_buf);
+	}
+
+	/*  Hw setting		 */
+	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE,
+		   "\n %-35s", "============[Hw setting] ============");
+	CL_PRINTF(cli_buf);
+
+	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\n %-35s = 0x%x",
+		   "RF-A, 0x1e initVal",
+		   coex_dm->bt_rf0x1e_backup);
+	CL_PRINTF(cli_buf);
+
+	u1tmp[0] = btcoexist->btc_read_1byte(btcoexist, 0x778);
+	u1tmp[1] = btcoexist->btc_read_1byte(btcoexist, 0x6cc);
+	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\n %-35s = 0x%x/ 0x%x ",
+		   "0x778 (W_Act)/ 0x6cc (CoTab Sel)",
+		   u1tmp[0], u1tmp[1]);
+	CL_PRINTF(cli_buf);
+
+	u1tmp[0] = btcoexist->btc_read_1byte(btcoexist, 0x8db);
+	u1tmp[1] = btcoexist->btc_read_1byte(btcoexist, 0xc5b);
+	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\n %-35s = 0x%x/ 0x%x",
+		   "0x8db(ADC)/0xc5b[29:25](DAC)",
+		   ((u1tmp[0]&0x60)>>5), ((u1tmp[1]&0x3e)>>1));
+	CL_PRINTF(cli_buf);
+
+	u4tmp[0] = btcoexist->btc_read_4byte(btcoexist, 0xcb4);
+	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\n %-35s = 0x%x/ 0x%x",
+		   "0xcb4[7:0](ctrl)/ 0xcb4[29:28](val)",
+		   u4tmp[0]&0xff, ((u4tmp[0]&0x30000000)>>28));
+	CL_PRINTF(cli_buf);
+
+	u1tmp[0] = btcoexist->btc_read_1byte(btcoexist, 0x40);
+	u4tmp[0] = btcoexist->btc_read_4byte(btcoexist, 0x4c);
+	u4tmp[1] = btcoexist->btc_read_4byte(btcoexist, 0x974);
+	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\n %-35s = 0x%x/ 0x%x/ 0x%x",
+		   "0x40/ 0x4c[24:23]/ 0x974",
+		   u1tmp[0], ((u4tmp[0]&0x01800000)>>23), u4tmp[1]);
+	CL_PRINTF(cli_buf);
+
+	u4tmp[0] = btcoexist->btc_read_4byte(btcoexist, 0x550);
+	u1tmp[0] = btcoexist->btc_read_1byte(btcoexist, 0x522);
+	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\n %-35s = 0x%x/ 0x%x",
+		   "0x550(bcn ctrl)/0x522",
+		   u4tmp[0], u1tmp[0]);
+	CL_PRINTF(cli_buf);
+
+	u4tmp[0] = btcoexist->btc_read_4byte(btcoexist, 0xc50);
+	u1tmp[0] = btcoexist->btc_read_1byte(btcoexist, 0xa0a);
+	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\n %-35s = 0x%x/ 0x%x",
+		   "0xc50(DIG)/0xa0a(CCK-TH)",
+		   u4tmp[0], u1tmp[0]);
+	CL_PRINTF(cli_buf);
+
+	u4tmp[0] = btcoexist->btc_read_4byte(btcoexist, 0xf48);
+	u1tmp[0] = btcoexist->btc_read_1byte(btcoexist, 0xa5b);
+	u1tmp[1] = btcoexist->btc_read_1byte(btcoexist, 0xa5c);
+	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE,
+		   "\n %-35s = 0x%x/ 0x%x", "OFDM-FA/ CCK-FA",
+		   u4tmp[0], (u1tmp[0]<<8) + u1tmp[1]);
+	CL_PRINTF(cli_buf);
+
+	u4tmp[0] = btcoexist->btc_read_4byte(btcoexist, 0x6c0);
+	u4tmp[1] = btcoexist->btc_read_4byte(btcoexist, 0x6c4);
+	u4tmp[2] = btcoexist->btc_read_4byte(btcoexist, 0x6c8);
+	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\n %-35s = 0x%x/ 0x%x/ 0x%x",
+		   "0x6c0/0x6c4/0x6c8",
+		   u4tmp[0], u4tmp[1], u4tmp[2]);
+	CL_PRINTF(cli_buf);
+
+	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\n %-35s = %d/ %d",
+		   "0x770 (hi-pri Rx/Tx)",
+		   coex_sta->high_priority_rx, coex_sta->high_priority_tx);
+	CL_PRINTF(cli_buf);
+	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\n %-35s = %d/ %d",
+		   "0x774(low-pri Rx/Tx)",
+		   coex_sta->low_priority_rx, coex_sta->low_priority_tx);
+	CL_PRINTF(cli_buf);
+
+	/*  Tx mgnt queue hang or not, 0x41b should = 0xf, ex: 0xd ==>hang */
+	u1tmp[0] = btcoexist->btc_read_1byte(btcoexist, 0x41b);
+	CL_SPRINTF(cli_buf, BT_TMP_BUF_SIZE, "\n %-35s = 0x%x",
+		   "0x41b (mgntQ hang chk == 0xf)",
+		   u1tmp[0]);
+	CL_PRINTF(cli_buf);
+
+	btcoexist->btc_disp_dbg_msg(btcoexist, BTC_DBG_DISP_COEX_STATISTICS);
+}
+
+void ex_halbtc8821a2ant_ips_notify(struct btc_coexist *btcoexist, u8 type)
+{
+	if (BTC_IPS_ENTER == type) {
+		BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
+			  "[BTCoex], IPS ENTER notify\n");
+		coex_sta->under_ips = true;
+		halbtc8821a2ant_coex_all_off(btcoexist);
+	} else if (BTC_IPS_LEAVE == type) {
+		BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
+			  "[BTCoex], IPS LEAVE notify\n");
+		coex_sta->under_ips = false;
+	}
+}
+
+void ex_halbtc8821a2ant_lps_notify(struct btc_coexist *btcoexist, u8 type)
+{
+	if (BTC_LPS_ENABLE == type) {
+		BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
+			  "[BTCoex], LPS ENABLE notify\n");
+		coex_sta->under_lps = true;
+	} else if (BTC_LPS_DISABLE == type) {
+		BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
+			  "[BTCoex], LPS DISABLE notify\n");
+		coex_sta->under_lps = false;
+	}
+}
+
+void ex_halbtc8821a2ant_scan_notify(struct btc_coexist *btcoexist, u8 type)
+{
+	if (BTC_SCAN_START == type)
+		BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
+			  "[BTCoex], SCAN START notify\n");
+	else if (BTC_SCAN_FINISH == type)
+		BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
+			  "[BTCoex], SCAN FINISH notify\n");
+}
+
+void ex_halbtc8821a2ant_connect_notify(struct btc_coexist *btcoexist, u8 type)
+{
+	if (BTC_ASSOCIATE_START == type)
+		BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
+			  "[BTCoex], CONNECT START notify\n");
+	else if (BTC_ASSOCIATE_FINISH == type)
+		BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
+			  "[BTCoex], CONNECT FINISH notify\n");
+}
+
+void ex_halbtc8821a2ant_media_status_notify(struct btc_coexist *btcoexist,
+					    u8 type)
+{
+	u8 h2c_parameter[3] = {0};
+	u32 wifi_bw;
+	u8 wifi_central_chnl;
+
+	if (BTC_MEDIA_CONNECT == type)
+		BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
+			  "[BTCoex], MEDIA connect notify\n");
+	else
+		BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
+			  "[BTCoex], MEDIA disconnect notify\n");
+
+	/*  only 2.4G we need to inform bt the chnl mask */
+	btcoexist->btc_get(btcoexist, BTC_GET_U1_WIFI_CENTRAL_CHNL,
+			   &wifi_central_chnl);
+	if ((BTC_MEDIA_CONNECT == type) &&
+	    (wifi_central_chnl <= 14)) {
+		h2c_parameter[0] = 0x1;
+		h2c_parameter[1] = wifi_central_chnl;
+		btcoexist->btc_get(btcoexist, BTC_GET_U4_WIFI_BW, &wifi_bw);
+		if (BTC_WIFI_BW_HT40 == wifi_bw)
+			h2c_parameter[2] = 0x30;
+		else
+			h2c_parameter[2] = 0x20;
+	}
+
+	coex_dm->wifi_chnl_info[0] = h2c_parameter[0];
+	coex_dm->wifi_chnl_info[1] = h2c_parameter[1];
+	coex_dm->wifi_chnl_info[2] = h2c_parameter[2];
+
+	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE_FW_EXEC,
+		  "[BTCoex], FW write 0x66 = 0x%x\n",
+		  h2c_parameter[0] << 16 |
+		  h2c_parameter[1] << 8 | h2c_parameter[2]);
+
+	btcoexist->btc_fill_h2c(btcoexist, 0x66, 3, h2c_parameter);
+}
+
+void ex_halbtc8821a2ant_special_packet_notify(struct btc_coexist *btcoexist,
+					      u8 type)
+{
+	if (type == BTC_PACKET_DHCP)
+		BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
+			  "[BTCoex], DHCP Packet notify\n");
+}
+
+void ex_halbtc8821a2ant_bt_info_notify(struct btc_coexist *btcoexist,
+				       u8 *tmp_buf, u8 length)
+{
+	u8 bt_info = 0;
+	u8 i, rsp_source = 0;
+	static u32 set_bt_lna_cnt, set_bt_psd_mode;
+	bool bt_busy = false, limited_dig = false;
+	bool wifi_connected = false, bt_hs_on = false;
+
+	coex_sta->c2h_bt_info_req_sent = false;
+	rsp_source = tmp_buf[0]&0xf;
+	if (rsp_source >= BT_INFO_SRC_8821A_2ANT_MAX)
+		rsp_source = BT_INFO_SRC_8821A_2ANT_WIFI_FW;
+	coex_sta->bt_info_c2h_cnt[rsp_source]++;
+
+	BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY,
+		  "[BTCoex], Bt info[%d], length =%d, hex data =[",
+		  rsp_source, length);
+	for (i = 0; i < length; i++) {
+		coex_sta->bt_info_c2h[rsp_source][i] = tmp_buf[i];
+		if (i == 1)
+			bt_info = tmp_buf[i];
+		if (i == length-1)
+			BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY, "0x%02x]\n",
+				  tmp_buf[i]);
+		else
+			BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY, "0x%02x, ",
+				  tmp_buf[i]);
+	}
+
+	if (BT_INFO_SRC_8821A_2ANT_WIFI_FW != rsp_source) {
+		coex_sta->bt_retry_cnt =	/*  [3:0] */
+			coex_sta->bt_info_c2h[rsp_source][2]&0xf;
+		coex_sta->bt_rssi =
+			coex_sta->bt_info_c2h[rsp_source][3]*2+10;
+		coex_sta->bt_info_ext =
+			coex_sta->bt_info_c2h[rsp_source][4];
+
+		/*  Here we need to resend some wifi info to BT */
+		/*  because bt is reset and loss of the info. */
+		if ((coex_sta->bt_info_ext & BIT(1))) {
+			btcoexist->btc_get(btcoexist, BTC_GET_BL_WIFI_CONNECTED,
+					   &wifi_connected);
+			if (wifi_connected)
+				ex_halbtc8821a2ant_media_status_notify(btcoexist,
+								       BTC_MEDIA_CONNECT);
+			else
+				ex_halbtc8821a2ant_media_status_notify(btcoexist,
+								       BTC_MEDIA_DISCONNECT);
+
+			set_bt_psd_mode = 0;
+		}
+		if (set_bt_psd_mode <= 3) {
+			/* fix CH-BW mode  */
+			halbtc8821a2ant_set_bt_psd_mode(btcoexist,
+							FORCE_EXEC, 0x0);
+			set_bt_psd_mode++;
+		}
+
+		if (coex_dm->cur_bt_lna_constrain) {
+			if (!(coex_sta->bt_info_ext & BIT(2))) {
+				if (set_bt_lna_cnt <= 3) {
+					set_bt_lna_constrain(btcoexist,
+							     FORCE_EXEC, true);
+					set_bt_lna_cnt++;
+				}
+			}
+		} else {
+			set_bt_lna_cnt = 0;
+		}
+
+		if ((coex_sta->bt_info_ext & BIT(3)))
+			halbtc8821a2ant_ignore_wlan_act(btcoexist,
+							FORCE_EXEC, false);
+		else
+			/* BT already NOT ignore Wlan active, do nothing here */
+
+		if (!(coex_sta->bt_info_ext & BIT(4)))
+			halbtc8821a2ant_bt_auto_report(btcoexist,
+						       FORCE_EXEC, true);
+	}
+
+	btcoexist->btc_get(btcoexist, BTC_GET_BL_HS_OPERATION, &bt_hs_on);
+	/*  check BIT(2) first ==> check if bt is under inquiry or page scan */
+	if (bt_info & BT_INFO_8821A_2ANT_B_INQ_PAGE) {
+		coex_sta->c2h_bt_inquiry_page = true;
+		coex_dm->bt_status = BT_8821A_2ANT_BT_STATUS_NON_IDLE;
+	} else {
+		coex_sta->c2h_bt_inquiry_page = false;
+		if (bt_info == 0x1) {	/*  connection exists but not busy */
+			coex_sta->bt_link_exist = true;
+			coex_dm->bt_status =
+				BT_8821A_2ANT_BT_STATUS_CONNECTED_IDLE;
+		} else if (bt_info & BT_INFO_8821A_2ANT_B_CONNECTION) {
+			/*  connection exists and some link is busy */
+			coex_sta->bt_link_exist = true;
+			if (bt_info & BT_INFO_8821A_2ANT_B_FTP)
+				coex_sta->pan_exist = true;
+			else
+				coex_sta->pan_exist = false;
+			if (bt_info & BT_INFO_8821A_2ANT_B_A2DP)
+				coex_sta->a2dp_exist = true;
+			else
+				coex_sta->a2dp_exist = false;
+			if (bt_info & BT_INFO_8821A_2ANT_B_HID)
+				coex_sta->hid_exist = true;
+			else
+				coex_sta->hid_exist = false;
+			if (bt_info & BT_INFO_8821A_2ANT_B_SCO_ESCO)
+				coex_sta->sco_exist = true;
+			else
+				coex_sta->sco_exist = false;
+			coex_dm->bt_status = BT_8821A_2ANT_BT_STATUS_NON_IDLE;
+		} else {
+			coex_sta->bt_link_exist = false;
+			coex_sta->pan_exist = false;
+			coex_sta->a2dp_exist = false;
+			coex_sta->hid_exist = false;
+			coex_sta->sco_exist = false;
+			coex_dm->bt_status = BT_8821A_2ANT_BT_STATUS_IDLE;
+		}
+
+		if (bt_hs_on)
+			coex_dm->bt_status = BT_8821A_2ANT_BT_STATUS_NON_IDLE;
+	}
+
+	if (BT_8821A_2ANT_BT_STATUS_NON_IDLE == coex_dm->bt_status)
+		bt_busy = true;
+	else
+		bt_busy = false;
+	btcoexist->btc_set(btcoexist, BTC_SET_BL_BT_TRAFFIC_BUSY, &bt_busy);
+
+	if (BT_8821A_2ANT_BT_STATUS_IDLE != coex_dm->bt_status)
+		limited_dig = true;
+	else
+		limited_dig = false;
+	coex_dm->limited_dig = limited_dig;
+	btcoexist->btc_set(btcoexist, BTC_SET_BL_BT_LIMITED_DIG, &limited_dig);
+
+	halbtc8821a2ant_run_coexist_mechanism(btcoexist);
+}
+
+void ex_halbtc8821a2ant_halt_notify(struct btc_coexist *btcoexist)
+{
+	BTC_PRINT(BTC_MSG_INTERFACE, INTF_NOTIFY, "[BTCoex], Halt notify\n");
+
+	halbtc8821a2ant_ignore_wlan_act(btcoexist, FORCE_EXEC, true);
+	ex_halbtc8821a2ant_media_status_notify(btcoexist, BTC_MEDIA_DISCONNECT);
+}
+
+void ex_halbtc8821a2ant_periodical(struct btc_coexist *btcoexist)
+{
+	static u8 dis_ver_info_cnt;
+	u32 fw_ver = 0, bt_patch_ver = 0;
+	struct btc_board_info *board_info = &btcoexist->board_info;
+	struct btc_stack_info *stack_info = &btcoexist->stack_info;
+
+	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+		  "[BTCoex], ========================== Periodical ===========================\n");
+
+	if (dis_ver_info_cnt <= 5) {
+		dis_ver_info_cnt += 1;
+		BTC_PRINT(BTC_MSG_INTERFACE, INTF_INIT,
+			  "[BTCoex], ****************************************************************\n");
+		BTC_PRINT(BTC_MSG_INTERFACE, INTF_INIT,
+			  "[BTCoex], Ant PG Num/ Ant Mech/ Ant Pos = %d/ %d/ %d\n",
+			  board_info->pg_ant_num, board_info->btdm_ant_num,
+			  board_info->btdm_ant_pos);
+		BTC_PRINT(BTC_MSG_INTERFACE, INTF_INIT,
+			  "[BTCoex], BT stack/ hci ext ver = %s / %d\n",
+			  ((stack_info->profile_notified) ? "Yes" : "No"),
+			  stack_info->hci_version);
+		btcoexist->btc_get(btcoexist, BTC_GET_U4_BT_PATCH_VER,
+				   &bt_patch_ver);
+		btcoexist->btc_get(btcoexist, BTC_GET_U4_WIFI_FW_VER, &fw_ver);
+		BTC_PRINT(BTC_MSG_INTERFACE, INTF_INIT,
+			  "[BTCoex], CoexVer/ FwVer/ PatchVer = %d_%x/ 0x%x/ 0x%x(%d)\n",
+			  glcoex_ver_date_8821a_2ant,
+			  glcoex_ver_8821a_2ant,
+			  fw_ver, bt_patch_ver, bt_patch_ver);
+		BTC_PRINT(BTC_MSG_INTERFACE, INTF_INIT,
+			  "[BTCoex], ****************************************************************\n");
+	}
+
+	halbtc8821a2ant_query_bt_info(btcoexist);
+	halbtc8821a2ant_monitor_bt_ctr(btcoexist);
+	monitor_bt_enable_disable(btcoexist);
+}
diff --git a/drivers/staging/rtl8192ee/btcoexist/halbtc8821a2ant.h b/drivers/staging/rtl8192ee/btcoexist/halbtc8821a2ant.h
new file mode 100644
index 0000000..745506b
--- /dev/null
+++ b/drivers/staging/rtl8192ee/btcoexist/halbtc8821a2ant.h
@@ -0,0 +1,179 @@
+/*  */
+/*  The following is for 8821A 2Ant BT Co-exist definition */
+/*  */
+#define	BT_INFO_8821A_2ANT_B_FTP				BIT(7)
+#define	BT_INFO_8821A_2ANT_B_A2DP				BIT(6)
+#define	BT_INFO_8821A_2ANT_B_HID				BIT(5)
+#define	BT_INFO_8821A_2ANT_B_SCO_BUSY				BIT(4)
+#define	BT_INFO_8821A_2ANT_B_ACL_BUSY				BIT(3)
+#define	BT_INFO_8821A_2ANT_B_INQ_PAGE				BIT(2)
+#define	BT_INFO_8821A_2ANT_B_SCO_ESCO				BIT(1)
+#define	BT_INFO_8821A_2ANT_B_CONNECTION				BIT(0)
+
+#define		BTC_RSSI_COEX_THRESH_TOL_8821A_2ANT		2
+
+enum BT_INFO_SRC_8821A_2ANT {
+	BT_INFO_SRC_8821A_2ANT_WIFI_FW			= 0x0,
+	BT_INFO_SRC_8821A_2ANT_BT_RSP			= 0x1,
+	BT_INFO_SRC_8821A_2ANT_BT_ACTIVE_SEND		= 0x2,
+	BT_INFO_SRC_8821A_2ANT_MAX
+};
+
+enum BT_8821A_2ANT_BT_STATUS {
+	BT_8821A_2ANT_BT_STATUS_IDLE				= 0x0,
+	BT_8821A_2ANT_BT_STATUS_CONNECTED_IDLE	= 0x1,
+	BT_8821A_2ANT_BT_STATUS_NON_IDLE			= 0x2,
+	BT_8821A_2ANT_BT_STATUS_MAX
+};
+
+enum BT_8821A_2ANT_COEX_ALGO {
+	BT_8821A_2ANT_COEX_ALGO_UNDEFINED			= 0x0,
+	BT_8821A_2ANT_COEX_ALGO_SCO				= 0x1,
+	BT_8821A_2ANT_COEX_ALGO_HID				= 0x2,
+	BT_8821A_2ANT_COEX_ALGO_A2DP				= 0x3,
+	BT_8821A_2ANT_COEX_ALGO_A2DP_PANHS		= 0x4,
+	BT_8821A_2ANT_COEX_ALGO_PANEDR			= 0x5,
+	BT_8821A_2ANT_COEX_ALGO_PANHS			= 0x6,
+	BT_8821A_2ANT_COEX_ALGO_PANEDR_A2DP		= 0x7,
+	BT_8821A_2ANT_COEX_ALGO_PANEDR_HID		= 0x8,
+	BT_8821A_2ANT_COEX_ALGO_HID_A2DP_PANEDR	= 0x9,
+	BT_8821A_2ANT_COEX_ALGO_HID_A2DP			= 0xa,
+	BT_8821A_2ANT_COEX_ALGO_MAX				= 0xb,
+};
+
+struct coex_dm_8821a_2ant {
+	/*  fw mechanism */
+	bool		pre_dec_bt_pwr;
+	bool		cur_dec_bt_pwr;
+	bool		pre_bt_lna_constrain;
+	bool		cur_bt_lna_constrain;
+	u8		pre_bt_psd_mode;
+	u8		cur_bt_psd_mode;
+	u8		pre_fw_dac_swing_lvl;
+	u8		cur_fw_dac_swing_lvl;
+	bool		cur_ignore_wlan_act;
+	bool		pre_ignore_wlan_act;
+	u8		pre_ps_tdma;
+	u8		cur_ps_tdma;
+	u8		ps_tdma_para[5];
+	u8		ps_tdma_du_adj_type;
+	bool		reset_tdma_adjust;
+	bool		pre_ps_tdma_on;
+	bool		cur_ps_tdma_on;
+	bool		pre_bt_auto_report;
+	bool		cur_bt_auto_report;
+
+	/*  sw mechanism */
+	bool		pre_rf_rx_lpf_shrink;
+	bool		cur_rf_rx_lpf_shrink;
+	u32		bt_rf0x1e_backup;
+	bool	pre_low_penalty_ra;
+	bool		cur_low_penalty_ra;
+	bool		pre_dac_swing_on;
+	u32		pre_dac_swing_lvl;
+	bool		cur_dac_swing_on;
+	u32		cur_dac_swing_lvl;
+	bool		pre_adc_back_off;
+	bool		cur_adc_back_off;
+	bool	pre_agc_table_en;
+	bool		cur_agc_table_en;
+	u32		pre_val0x6c0;
+	u32		cur_val0x6c0;
+	u32		pre_val0x6c4;
+	u32		cur_val0x6c4;
+	u32		pre_val0x6c8;
+	u32		cur_val0x6c8;
+	u8		pre_val0x6cc;
+	u8		cur_val0x6cc;
+	bool		limited_dig;
+
+	/*  algorithm related */
+	u8		pre_algorithm;
+	u8		cur_algorithm;
+	u8		bt_status;
+	u8		wifi_chnl_info[3];
+};
+
+struct coex_sta_8821a_2ant {
+	bool		bt_link_exist;
+	bool		sco_exist;
+	bool		a2dp_exist;
+	bool		hid_exist;
+	bool		pan_exist;
+
+	bool		under_lps;
+	bool		under_ips;
+	u32		high_priority_tx;
+	u32		high_priority_rx;
+	u32		low_priority_tx;
+	u32		low_priority_rx;
+	u8		bt_rssi;
+	u8		pre_bt_rssi_state;
+	u8		pre_wifi_rssi_state[4];
+	bool		c2h_bt_info_req_sent;
+	u8		bt_info_c2h[BT_INFO_SRC_8821A_2ANT_MAX][10];
+	u32		bt_info_c2h_cnt[BT_INFO_SRC_8821A_2ANT_MAX];
+	bool		c2h_bt_inquiry_page;
+	u8		bt_retry_cnt;
+	u8		bt_info_ext;
+};
+
+/*  */
+/*  The following is interface which will notify coex module. */
+/*  */
+void
+ex_halbtc8821a2ant_init_hwconfig(
+	struct btc_coexist *btcoexist
+	);
+void
+ex_halbtc8821a2ant_init_coex_dm(
+	struct btc_coexist *btcoexist
+	);
+void
+ex_halbtc8821a2ant_ips_notify(
+	struct btc_coexist *btcoexist,
+	u8 type
+	);
+void
+ex_halbtc8821a2ant_lps_notify(
+	struct btc_coexist *btcoexist,
+	u8 type
+	);
+void
+ex_halbtc8821a2ant_scan_notify(
+	struct btc_coexist *btcoexist,
+	u8 type
+	);
+void
+ex_halbtc8821a2ant_connect_notify(
+	struct btc_coexist *btcoexist,
+	u8 type
+	);
+void
+ex_halbtc8821a2ant_media_status_notify(
+	struct btc_coexist *btcoexist,
+	u8 type
+	);
+void
+ex_halbtc8821a2ant_special_packet_notify(
+	struct btc_coexist *btcoexist,
+	u8 type
+	);
+void
+ex_halbtc8821a2ant_bt_info_notify(
+	struct btc_coexist *btcoexist,
+	u8 *tmp_buf,
+	u8 length
+	);
+void
+ex_halbtc8821a2ant_halt_notify(
+	struct btc_coexist *btcoexist
+	);
+void
+ex_halbtc8821a2ant_periodical(
+	struct btc_coexist *btcoexist
+	);
+void
+ex_halbtc8821a2ant_display_coex_info(
+	struct btc_coexist *btcoexist
+	);
diff --git a/drivers/staging/rtl8192ee/btcoexist/halbtcoutsrc.c b/drivers/staging/rtl8192ee/btcoexist/halbtcoutsrc.c
new file mode 100644
index 0000000..9757f13
--- /dev/null
+++ b/drivers/staging/rtl8192ee/btcoexist/halbtcoutsrc.c
@@ -0,0 +1,1307 @@
+/******************************************************************************
+ *
+ * Copyright(c) 2007 - 2013 Realtek Corporation. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for
+ * more details.
+ *
+ *
+ ******************************************************************************/
+
+#include "halbt_precomp.h"
+
+/***********************************************
+ *		Global variables
+ ***********************************************/
+static const char *const bt_profile_string[] = {
+	"NONE",
+	"A2DP",
+	"PAN",
+	"HID",
+	"SCO",
+};
+
+static const char *const bt_spec_string[] = {
+	"1.0b",
+	"1.1",
+	"1.2",
+	"2.0+EDR",
+	"2.1+EDR",
+	"3.0+HS",
+	"4.0",
+};
+
+static const char *const bt_link_role_string[] = {
+	"Master",
+	"Slave",
+};
+
+static const char *const h2c_state_string[] = {
+	"successful",
+	"h2c busy",
+	"rf off",
+	"fw not read",
+};
+
+static const char *const io_state_string[] = {
+	"IO_STATUS_SUCCESS",
+	"IO_STATUS_FAIL_CANNOT_IO",
+	"IO_STATUS_FAIL_RF_OFF",
+	"IO_STATUS_FAIL_FW_READ_CLEAR_TIMEOUT",
+	"IO_STATUS_FAIL_WAIT_IO_EVENT_TIMEOUT",
+	"IO_STATUS_INVALID_LEN",
+	"IO_STATUS_IO_IDLE_QUEUE_EMPTY",
+	"IO_STATUS_IO_INSERT_WAIT_QUEUE_FAIL",
+	"IO_STATUS_UNKNOWN_FAIL",
+	"IO_STATUS_WRONG_LEVEL",
+	"IO_STATUS_H2C_STOPPED",
+};
+
+struct btc_coexist gl92e_bt_coexist;
+
+u32 btc_92edbg_type[BTC_MSG_MAX];
+static u8 btc_dbg_buf[100];
+
+/***************************************************
+ *		Debug related function
+ ***************************************************/
+static bool is_any_client_connect_to_ap(struct btc_coexist *btcoexist)
+{
+	struct rtl_priv *rtlpriv = btcoexist->adapter;
+	struct rtl_mac *mac = rtl_mac(rtlpriv);
+	struct rtl_sta_info *drv_priv;
+	u8 cnt = 0;
+
+	if (mac->opmode == NL80211_IFTYPE_ADHOC ||
+	    mac->opmode == NL80211_IFTYPE_MESH_POINT ||
+	    mac->opmode == NL80211_IFTYPE_AP) {
+		spin_lock_bh(&rtlpriv->locks.entry_list_lock);
+		list_for_each_entry(drv_priv, &rtlpriv->entry_list, list) {
+			cnt++;
+		}
+		spin_unlock_bh(&rtlpriv->locks.entry_list_lock);
+	}
+	if (cnt > 0)
+		return true;
+	else
+		return false;
+}
+
+static bool halbtc_is_bt_coexist_available(struct btc_coexist *btcoexist)
+{
+	if (!btcoexist->binded || NULL == btcoexist->adapter)
+		return false;
+
+	return true;
+}
+
+static bool halbtc_is_wifi_busy(struct rtl_priv *rtlpriv)
+{
+	if (rtlpriv->link_info.b_busytraffic)
+		return true;
+	else
+		return false;
+}
+
+
+static void halbtc_dbg_init(void)
+{
+	u8 i;
+
+	for (i = 0; i < BTC_MSG_MAX; i++)
+		btc_92edbg_type[i] = 0;
+
+	btc_92edbg_type[BTC_MSG_INTERFACE] = 0;
+
+	btc_92edbg_type[BTC_MSG_ALGORITHM] = 0;
+}
+
+static bool halbtc_is_bt40(struct rtl_priv *adapter)
+{
+	struct rtl_priv *rtlpriv = adapter;
+	struct rtl_phy *rtlphy = &(rtlpriv->phy);
+	bool is_ht40 = true;
+	enum ht_channel_width bw = rtlphy->current_chan_bw;
+
+
+	if (bw == HT_CHANNEL_WIDTH_20)
+		is_ht40 = false;
+	else if (bw == HT_CHANNEL_WIDTH_20_40)
+		is_ht40 = true;
+
+	return is_ht40;
+}
+
+static bool halbtc_legacy(struct rtl_priv *adapter)
+{
+	struct rtl_priv *rtlpriv = adapter;
+	struct rtl_mac *mac = rtl_mac(rtlpriv);
+
+	bool is_legacy = false;
+
+	if ((mac->mode == WIRELESS_MODE_B) || (mac->mode == WIRELESS_MODE_G))
+		is_legacy = true;
+
+	return is_legacy;
+}
+
+bool halbtc92e_is_wifi_uplink(struct rtl_priv *adapter)
+{
+	struct rtl_priv *rtlpriv = adapter;
+
+	if (rtlpriv->link_info.b_tx_busy_traffic)
+		return true;
+	else
+		return false;
+}
+
+static u32 halbtc_get_wifi_bw(struct btc_coexist *btcoexist)
+{
+	struct rtl_priv *rtlpriv =
+		(struct rtl_priv *)btcoexist->adapter;
+	u32 wifi_bw = BTC_WIFI_BW_HT20;
+
+	if (halbtc_is_bt40(rtlpriv)) {
+		wifi_bw = BTC_WIFI_BW_HT40;
+	} else {
+		if (halbtc_legacy(rtlpriv))
+			wifi_bw = BTC_WIFI_BW_LEGACY;
+		else
+			wifi_bw = BTC_WIFI_BW_HT20;
+	}
+	return wifi_bw;
+}
+
+static u8 halbtc_get_wifi_central_chnl(struct btc_coexist *btcoexist)
+{
+	struct rtl_priv *rtlpriv = btcoexist->adapter;
+	struct rtl_phy	*rtlphy = &(rtlpriv->phy);
+	u8 chnl = 1;
+
+
+	if (rtlphy->current_channel != 0)
+		chnl = rtlphy->current_channel;
+	BTC_PRINT(BTC_MSG_ALGORITHM, ALGO_TRACE,
+		  "halbtc_get_wifi_central_chnl:%d\n", chnl);
+	return chnl;
+}
+
+static void halbtc_leave_lps(struct btc_coexist *btcoexist)
+{
+	struct rtl_priv *rtlpriv;
+	struct rtl_ps_ctl *ppsc;
+	bool ap_enable = false;
+
+	rtlpriv = btcoexist->adapter;
+	ppsc = rtl_psc(rtlpriv);
+
+	btcoexist->btc_get(btcoexist, BTC_GET_BL_WIFI_AP_MODE_ENABLE,
+			   &ap_enable);
+
+	if (ap_enable) {
+		pr_debug("halbtc_leave_lps()<--dont leave lps under AP mode\n");
+		return;
+	}
+
+	btcoexist->bt_info.bt_ctrl_lps = true;
+	btcoexist->bt_info.bt_lps_on = false;
+	rtl92e_lps_leave(rtlpriv->mac80211.hw);
+}
+
+static void halbtc_enter_lps(struct btc_coexist *btcoexist)
+{
+	struct rtl_priv *rtlpriv;
+	struct rtl_ps_ctl *ppsc;
+	bool ap_enable = false;
+
+	rtlpriv = btcoexist->adapter;
+	ppsc = rtl_psc(rtlpriv);
+
+	btcoexist->btc_get(btcoexist, BTC_GET_BL_WIFI_AP_MODE_ENABLE,
+			   &ap_enable);
+
+	if (ap_enable) {
+		pr_debug("halbtc_enter_lps()<--dont enter lps under AP mode\n");
+		return;
+	}
+
+	btcoexist->bt_info.bt_ctrl_lps = true;
+	btcoexist->bt_info.bt_lps_on = false;
+	rtl92e_lps_enter(rtlpriv->mac80211.hw);
+}
+
+static void halbtc_normal_lps(struct btc_coexist *btcoexist)
+{
+	if (btcoexist->bt_info.bt_ctrl_lps) {
+		btcoexist->bt_info.bt_lps_on = false;
+		btcoexist->bt_info.bt_ctrl_lps = false;
+	}
+}
+
+static void halbtc_aggregation_check(struct btc_coexist *btcoexist)
+{
+}
+
+static u32 halbtcoutsrc_get_wifi_link_status(struct btc_coexist *btcoexist)
+{
+	/*------------------------------------
+	 * return value:
+	 * [31:16] => connected port number
+	 * [15:0] => port connected bit define
+	 *------------------------------------
+	 */
+
+	struct rtl_priv *rtlpriv = btcoexist->adapter;
+	struct rtl_mac *mac = rtl_mac(rtlpriv);
+	u32 ret_val = 0;
+	u32 port_connected_status = 0, num_of_connected_port = 0;
+
+	if (mac->opmode == NL80211_IFTYPE_STATION &&
+	    mac->link_state >= MAC80211_LINKED) {
+		port_connected_status |= WIFI_STA_CONNECTED;
+		num_of_connected_port++;
+	}
+	/* AP & ADHOC & MESH */
+	if (is_any_client_connect_to_ap(btcoexist)) {
+		port_connected_status |= WIFI_AP_CONNECTED;
+		num_of_connected_port++;
+	}
+	/*if (BT_HsConnectionEstablished(Adapter))
+	{
+		port_connected_status |= WIFI_HS_CONNECTED;
+		num_of_connected_port++;
+	}*/
+	/* TODO:
+	 * P2P Connected Status	*/
+
+	ret_val = (num_of_connected_port << 16) | port_connected_status;
+
+	return ret_val;
+}
+
+
+static u32 halbtc_get_bt_patch_version(struct btc_coexist *btcoexist)
+{
+	return 0;
+}
+
+static s32 halbtc_get_wifi_rssi(struct rtl_priv *adapter)
+{
+	struct rtl_priv *rtlpriv = adapter;
+	s32	undecorated_smoothed_pwdb = 0;
+
+	if (rtlpriv->mac80211.link_state >= MAC80211_LINKED)
+		undecorated_smoothed_pwdb =
+			rtlpriv->dm.undecorated_smoothed_pwdb;
+	else /* associated entry pwdb */
+		undecorated_smoothed_pwdb =
+			rtlpriv->dm.undecorated_smoothed_pwdb;
+	return undecorated_smoothed_pwdb;
+}
+
+static bool halbtc_get(void *void_btcoexist, u8 get_type, void *out_buf)
+{
+	struct btc_coexist *btcoexist = (struct btc_coexist *)void_btcoexist;
+	struct rtl_priv *rtlpriv = btcoexist->adapter;
+	struct rtl_phy *rtlphy = &(rtlpriv->phy);
+	struct rtl_mac *mac = rtl_mac(rtlpriv);
+	struct rtl_hal *rtlhal = rtl_hal(rtlpriv);
+	bool *bool_tmp = (bool *)out_buf;
+	int *s32_tmp = (int *)out_buf;
+	u32 *u32_tmp = (u32 *)out_buf;
+	u8 *u8_tmp = (u8 *)out_buf;
+	bool tmp = false;
+
+
+	if (!halbtc_is_bt_coexist_available(btcoexist))
+		return false;
+
+
+	switch (get_type) {
+	case BTC_GET_BL_HS_OPERATION:
+		*bool_tmp = false;
+		break;
+	case BTC_GET_BL_HS_CONNECTING:
+		*bool_tmp = false;
+		break;
+	case BTC_GET_BL_WIFI_CONNECTED:
+		if (rtlpriv->mac80211.opmode == NL80211_IFTYPE_STATION &&
+		    rtlpriv->mac80211.link_state >= MAC80211_LINKED)
+			tmp = true;
+		if (is_any_client_connect_to_ap(btcoexist))
+			tmp = true;
+		*bool_tmp = tmp;
+		break;
+	case BTC_GET_BL_WIFI_BUSY:
+		if (halbtc_is_wifi_busy(rtlpriv))
+			*bool_tmp = true;
+		else
+			*bool_tmp = false;
+		break;
+	case BTC_GET_BL_WIFI_SCAN:
+		if (mac->act_scanning)
+			*bool_tmp = true;
+		else
+			*bool_tmp = false;
+		break;
+	case BTC_GET_BL_WIFI_LINK:
+		if (mac->link_state == MAC80211_LINKING)
+			*bool_tmp = true;
+		else
+			*bool_tmp = false;
+		break;
+	case BTC_GET_BL_WIFI_ROAM:	/*TODO*/
+		*bool_tmp = false;
+		break;
+	case BTC_GET_BL_WIFI_4_WAY_PROGRESS:	/*TODO*/
+		*bool_tmp = false;
+		break;
+	case BTC_GET_BL_WIFI_UNDER_5G:
+		*bool_tmp = false; /*TODO*/
+
+	case BTC_GET_BL_WIFI_DHCP:	/*TODO*/
+		break;
+	case BTC_GET_BL_WIFI_SOFTAP_IDLE:
+		*bool_tmp = true;
+		break;
+	case BTC_GET_BL_WIFI_SOFTAP_LINKING:
+		*bool_tmp = false;
+		break;
+	case BTC_GET_BL_WIFI_IN_EARLY_SUSPEND:
+		*bool_tmp = false;
+		break;
+	case BTC_GET_BL_WIFI_AP_MODE_ENABLE:
+		*bool_tmp = false;
+		break;
+	case BTC_GET_BL_WIFI_ENABLE_ENCRYPTION:
+		if (NO_ENCRYPTION == rtlpriv->sec.pairwise_enc_algorithm)
+			*bool_tmp = false;
+		else
+			*bool_tmp = true;
+		break;
+	case BTC_GET_BL_WIFI_UNDER_B_MODE:
+		if (WIRELESS_MODE_B == rtlpriv->mac80211.mode)
+			*bool_tmp = true;
+		else
+			*bool_tmp = false;
+		break;
+	case BTC_GET_BL_EXT_SWITCH:
+		*bool_tmp = false;
+		break;
+	case BTC_GET_S4_WIFI_RSSI:
+		*s32_tmp = halbtc_get_wifi_rssi(rtlpriv);
+		break;
+	case BTC_GET_S4_HS_RSSI:	/*TODO*/
+		*s32_tmp = halbtc_get_wifi_rssi(rtlpriv);
+		break;
+	case BTC_GET_U4_WIFI_BW:
+		*u32_tmp = halbtc_get_wifi_bw(btcoexist);
+		break;
+	case BTC_GET_U4_WIFI_TRAFFIC_DIRECTION:
+		if (halbtc92e_is_wifi_uplink(rtlpriv))
+			*u32_tmp = BTC_WIFI_TRAFFIC_TX;
+		else
+			*u32_tmp = BTC_WIFI_TRAFFIC_RX;
+		break;
+	case BTC_GET_U4_WIFI_FW_VER:
+		*u32_tmp = (rtlhal->fw_version << 16) | rtlhal->fw_subversion;
+		break;
+	case BTC_GET_U4_WIFI_LINK_STATUS:
+		*u32_tmp = halbtcoutsrc_get_wifi_link_status(btcoexist);
+		break;
+	case BTC_GET_U4_BT_PATCH_VER:
+		*u32_tmp = halbtc_get_bt_patch_version(btcoexist);
+		break;
+	case BTC_GET_U1_WIFI_DOT11_CHNL:
+		*u8_tmp = rtlphy->current_channel;
+		break;
+	case BTC_GET_U1_WIFI_CENTRAL_CHNL:
+		*u8_tmp = halbtc_get_wifi_central_chnl(btcoexist);
+		break;
+	case BTC_GET_U1_WIFI_HS_CHNL:
+		*u8_tmp = 1;/* BT_OperateChnl(rtlpriv); */
+		break;
+	case BTC_GET_U1_MAC_PHY_MODE:
+		*u8_tmp = BTC_MP_UNKNOWN;
+		break;
+	case BTC_GET_U1_AP_NUM:
+		/* driver don't know AP num in Linux,
+		 * So, the return value here is not right */
+		*u8_tmp = 1;/* pDefMgntInfo->NumBssDesc4Query; */
+		break;
+
+	/************* 1Ant **************/
+	case BTC_GET_U1_LPS_MODE:
+		*u8_tmp = btcoexist->pwr_mode_val[0];
+		break;
+
+	default:
+		break;
+	}
+
+	return true;
+}
+
+static bool halbtc_set(void *void_btcoexist, u8 set_type, void *in_buf)
+{
+	struct btc_coexist *btcoexist = (struct btc_coexist *)void_btcoexist;
+	bool *bool_tmp = (bool *)in_buf;
+	u8 *u8_tmp = (u8 *)in_buf;
+	u32 *u32_tmp = (u32 *)in_buf;
+
+
+	if (!halbtc_is_bt_coexist_available(btcoexist))
+		return false;
+
+	switch (set_type) {
+	/* set some bool type variables. */
+	case BTC_SET_BL_BT_DISABLE:
+		btcoexist->bt_info.bt_disabled = *bool_tmp;
+		break;
+	case BTC_SET_BL_BT_TRAFFIC_BUSY:
+		btcoexist->bt_info.bt_busy = *bool_tmp;
+		break;
+	case BTC_SET_BL_BT_LIMITED_DIG:
+		btcoexist->bt_info.limited_dig = *bool_tmp;
+		break;
+	case BTC_SET_BL_FORCE_TO_ROAM:
+		btcoexist->bt_info.force_to_roam = *bool_tmp;
+		break;
+	case BTC_SET_BL_TO_REJ_AP_AGG_PKT:
+		btcoexist->bt_info.reject_agg_pkt = *bool_tmp;
+		break;
+	case BTC_SET_BL_BT_CTRL_AGG_SIZE:
+		btcoexist->bt_info.b_bt_ctrl_buf_size = *bool_tmp;
+		break;
+	case BTC_SET_BL_INC_SCAN_DEV_NUM:
+		btcoexist->bt_info.increase_scan_dev_num = *bool_tmp;
+		break;
+		/* set some u1Byte type variables. */
+	case BTC_SET_U1_RSSI_ADJ_VAL_FOR_AGC_TABLE_ON:
+		btcoexist->bt_info.rssi_adjust_for_agc_table_on = *u8_tmp;
+		break;
+	case BTC_SET_U1_AGG_BUF_SIZE:
+		btcoexist->bt_info.agg_buf_size = *u8_tmp;
+		break;
+		/* the following are some action which will be triggered */
+	case BTC_SET_ACT_GET_BT_RSSI:
+		/*BTHCI_SendGetBtRssiEvent(rtlpriv);*/
+		break;
+	case BTC_SET_ACT_AGGREGATE_CTRL:
+		halbtc_aggregation_check(btcoexist);
+		break;
+
+		/* 1Ant */
+	case BTC_SET_U1_RSSI_ADJ_VAL_FOR_1ANT_COEX_TYPE:
+		btcoexist->bt_info.rssi_adjust_for_1ant_coex_type = *u8_tmp;
+		break;
+	case BTC_SET_U1_LPS_VAL:
+		btcoexist->bt_info.lps_val = *u8_tmp;
+		break;
+	case BTC_SET_U1_RPWM_VAL:
+		btcoexist->bt_info.rpwm_val = *u8_tmp;
+		break;
+	/* the following are some action which will be triggered  */
+	case BTC_SET_ACT_LEAVE_LPS:
+		halbtc_leave_lps(btcoexist);
+		break;
+	case BTC_SET_ACT_ENTER_LPS:
+		halbtc_enter_lps(btcoexist);
+		break;
+	case BTC_SET_ACT_NORMAL_LPS:
+		halbtc_normal_lps(btcoexist);
+		break;
+	case BTC_SET_ACT_DISABLE_LOW_POWER:
+		break;
+	case BTC_SET_ACT_UPDATE_ra_mask:
+		btcoexist->bt_info.ra_mask = *u32_tmp;
+		break;
+	case BTC_SET_ACT_SEND_MIMO_PS:
+		break;
+	case BTC_SET_ACT_INC_FORCE_EXEC_PWR_CMD_CNT:
+		btcoexist->bt_info.force_exec_pwr_cmd_cnt++;
+		break;
+	case BTC_SET_ACT_CTRL_BT_INFO: /*wait for 8812/8821*/
+		break;
+	case BTC_SET_ACT_CTRL_BT_COEX:
+		break;
+	default:
+		break;
+	}
+
+	return true;
+}
+
+static void halbtc_display_coex_statistics(struct btc_coexist *btcoexist)
+{
+}
+
+static void halbtc_display_bt_link_info(struct btc_coexist *btcoexist)
+{
+}
+
+static void halbtc_display_bt_fw_info(struct btc_coexist *btcoexist)
+{
+}
+
+static void halbtc_display_fw_pwr_mode_cmd(struct btc_coexist *btcoexist)
+{
+}
+
+/************************************************************
+ *		IO related function
+ ************************************************************/
+static u8 halbtc_read_1byte(void *bt_context, u32 reg_addr)
+{
+	struct btc_coexist *btcoexist = (struct btc_coexist *)bt_context;
+	struct rtl_priv *rtlpriv = btcoexist->adapter;
+
+	return	rtl_read_byte(rtlpriv, reg_addr);
+}
+
+
+static u16 halbtc_read_2byte(void *bt_context, u32 reg_addr)
+{
+	struct btc_coexist *btcoexist = (struct btc_coexist *)bt_context;
+	struct rtl_priv *rtlpriv = btcoexist->adapter;
+
+	return	rtl_read_word(rtlpriv, reg_addr);
+}
+
+
+static u32 halbtc_read_4byte(void *bt_context, u32 reg_addr)
+{
+	struct btc_coexist *btcoexist = (struct btc_coexist *)bt_context;
+	struct rtl_priv *rtlpriv = btcoexist->adapter;
+
+	return	rtl_read_dword(rtlpriv, reg_addr);
+}
+
+
+static void halbtc_write_1byte(void *bt_context, u32 reg_addr, u8 data)
+{
+	struct btc_coexist *btcoexist = (struct btc_coexist *)bt_context;
+	struct rtl_priv *rtlpriv = btcoexist->adapter;
+
+	rtl_write_byte(rtlpriv, reg_addr, data);
+}
+
+static void halbtc_bitmask_write_1byte(void *bt_context, u32 reg_addr,
+				       u8 bit_mask, u8 data)
+{
+	struct btc_coexist *btcoexist = (struct btc_coexist *)bt_context;
+	struct rtl_priv *rtlpriv = btcoexist->adapter;
+	u8 original_value, bit_shift = 0;
+	u8 i;
+
+	if (bit_mask != MASKBYTE0) {/*if not "byte" write*/
+		original_value = rtl_read_byte(rtlpriv, reg_addr);
+		for (i = 0; i <= 7; i++) {
+			if ((bit_mask>>i)&0x1)
+				break;
+		}
+		bit_shift = i;
+		data = (original_value & (~bit_mask)) |
+			((data << bit_shift) & bit_mask);
+	}
+	rtl_write_byte(rtlpriv, reg_addr, data);
+}
+
+
+static void halbtc_write_2byte(void *bt_context, u32 reg_addr, u16 data)
+{
+	struct btc_coexist *btcoexist = (struct btc_coexist *)bt_context;
+	struct rtl_priv *rtlpriv = btcoexist->adapter;
+
+	rtl_write_word(rtlpriv, reg_addr, data);
+}
+
+
+static void halbtc_write_4byte(void *bt_context, u32 reg_addr, u32 data)
+{
+	struct btc_coexist *btcoexist =
+		(struct btc_coexist *)bt_context;
+	struct rtl_priv *rtlpriv = btcoexist->adapter;
+
+	rtl_write_dword(rtlpriv, reg_addr, data);
+}
+
+
+static void halbtc_set_bbreg(void *bt_context, u32 reg_addr,
+			     u32 bit_mask, u32 data)
+{
+	struct btc_coexist *btcoexist = (struct btc_coexist *)bt_context;
+	struct rtl_priv *rtlpriv = btcoexist->adapter;
+
+	rtl_set_bbreg(rtlpriv->mac80211.hw, reg_addr, bit_mask, data);
+}
+
+
+static u32 halbtc_get_bbreg(void *bt_context, u32 reg_addr, u32 bit_mask)
+{
+	struct btc_coexist *btcoexist = (struct btc_coexist *)bt_context;
+	struct rtl_priv *rtlpriv = btcoexist->adapter;
+
+	return rtl_get_bbreg(rtlpriv->mac80211.hw, reg_addr, bit_mask);
+}
+
+
+static void halbtc_set_rfreg(void *bt_context, u8 rf_path, u32 reg_addr,
+			     u32 bit_mask, u32 data)
+{
+	struct btc_coexist *btcoexist = (struct btc_coexist *)bt_context;
+	struct rtl_priv *rtlpriv = btcoexist->adapter;
+
+	rtl_set_rfreg(rtlpriv->mac80211.hw, rf_path, reg_addr, bit_mask, data);
+}
+
+
+static u32 halbtc_get_rfreg(void *bt_context, u8 rf_path, u32 reg_addr,
+			    u32 bit_mask)
+{
+	struct btc_coexist *btcoexist = (struct btc_coexist *)bt_context;
+	struct rtl_priv *rtlpriv = btcoexist->adapter;
+
+	return rtl_get_rfreg(rtlpriv->mac80211.hw, rf_path, reg_addr, bit_mask);
+}
+
+
+static void halbtc_fill_h2c_cmd(void *bt_context, u8 element_id,
+				u32 cmd_len, u8 *cmd_buf)
+{
+	struct btc_coexist *btcoexist = (struct btc_coexist *)bt_context;
+	struct rtl_priv *rtlpriv = btcoexist->adapter;
+
+	rtlpriv->cfg->ops->fill_h2c_cmd(rtlpriv->mac80211.hw, element_id,
+					cmd_len, cmd_buf);
+}
+
+static void halbtc_display_dbg_msg(void *bt_context, u8 disp_type)
+{
+	struct btc_coexist *btcoexist =	(struct btc_coexist *)bt_context;
+	switch (disp_type) {
+	case BTC_DBG_DISP_COEX_STATISTICS:
+		halbtc_display_coex_statistics(btcoexist);
+		break;
+	case BTC_DBG_DISP_BT_LINK_INFO:
+		halbtc_display_bt_link_info(btcoexist);
+		break;
+	case BTC_DBG_DISP_BT_FW_VER:
+		halbtc_display_bt_fw_info(btcoexist);
+		break;
+	case BTC_DBG_DISP_FW_PWR_MODE_CMD:
+		halbtc_display_fw_pwr_mode_cmd(btcoexist);
+		break;
+	default:
+		break;
+	}
+}
+
+static bool halbtc_under_ips(struct btc_coexist *btcoexist)
+{
+	struct rtl_priv *rtlpriv = btcoexist->adapter;
+	struct rtl_ps_ctl *ppsc = rtl_psc(rtlpriv);
+	enum rf_pwrstate rtstate;
+
+	if (ppsc->b_inactiveps) {
+		rtstate = ppsc->rfpwr_state;
+
+		if (rtstate != ERFON &&
+		    ppsc->rfoff_reason == RF_CHANGE_BY_IPS)
+			return true;
+	}
+
+	return false;
+}
+
+/*****************************************************************
+ *         Extern functions called by other module
+ *****************************************************************/
+bool exhalbtc92e_initlize_variables(struct rtl_priv *adapter)
+{
+	struct btc_coexist *btcoexist = &gl92e_bt_coexist;
+
+	btcoexist->statistics.cnt_bind++;
+
+	halbtc_dbg_init();
+
+	if (btcoexist->binded)
+		return false;
+	else
+		btcoexist->binded = true;
+
+#if (defined(CONFIG_PCI_HCI))
+	btcoexist->chip_interface = BTC_INTF_PCI;
+#elif (defined(CONFIG_USB_HCI))
+	btcoexist->chip_interface = BTC_INTF_USB;
+#elif (defined(CONFIG_SDIO_HCI))
+	btcoexist->chip_interface = BTC_INTF_SDIO;
+#elif (defined(CONFIG_GSPI_HCI))
+	btcoexist->chip_interface = BTC_INTF_GSPI;
+#else
+	btcoexist->chip_interface = BTC_INTF_UNKNOWN;
+#endif
+
+	if (NULL == btcoexist->adapter)
+		btcoexist->adapter = adapter;
+
+	btcoexist->stack_info.profile_notified = false;
+
+	btcoexist->btc_read_1byte = halbtc_read_1byte;
+	btcoexist->btc_write_1byte = halbtc_write_1byte;
+	btcoexist->btc_write_1byte_bitmask = halbtc_bitmask_write_1byte;
+	btcoexist->btc_read_2byte = halbtc_read_2byte;
+	btcoexist->btc_write_2byte = halbtc_write_2byte;
+	btcoexist->btc_read_4byte = halbtc_read_4byte;
+	btcoexist->btc_write_4byte = halbtc_write_4byte;
+
+	btcoexist->btc_set_bb_reg = halbtc_set_bbreg;
+	btcoexist->btc_get_bb_reg = halbtc_get_bbreg;
+
+	btcoexist->btc_set_rf_reg = halbtc_set_rfreg;
+	btcoexist->btc_get_rf_reg = halbtc_get_rfreg;
+
+	btcoexist->btc_fill_h2c = halbtc_fill_h2c_cmd;
+	btcoexist->btc_disp_dbg_msg = halbtc_display_dbg_msg;
+
+	btcoexist->btc_get = halbtc_get;
+	btcoexist->btc_set = halbtc_set;
+
+	btcoexist->cli_buf = &btc_dbg_buf[0];
+
+	btcoexist->bt_info.b_bt_ctrl_buf_size = false;
+	btcoexist->bt_info.agg_buf_size = 5;
+
+	btcoexist->bt_info.increase_scan_dev_num = false;
+	return true;
+}
+
+void exhalbtc92e_init_hw_config(struct btc_coexist *btcoexist)
+{
+	struct rtl_priv *rtlpriv = btcoexist->adapter;
+	struct rtl_hal *rtlhal = rtl_hal(rtlpriv);
+
+	if (!halbtc_is_bt_coexist_available(btcoexist))
+		return;
+
+	btcoexist->statistics.cnt_init_hw_config++;
+
+	if (rtlhal->hw_type == HARDWARE_TYPE_RTL8723BE) {
+		if (btcoexist->board_info.btdm_ant_num == 2)
+			ex92e_halbtc8723b2ant_init_hwconfig(btcoexist);
+		else if (btcoexist->board_info.btdm_ant_num == 1)
+			ex_halbtc8723b1ant_init_hwconfig(btcoexist);
+	} else if (rtlhal->hw_type == HARDWARE_TYPE_RTL8192EE) {
+		ex_halbtc8192e2ant_init_hwconfig(btcoexist);
+	} else if (rtlhal->hw_type == HARDWARE_TYPE_RTL8821AE) {
+		if (btcoexist->board_info.btdm_ant_num == 2)
+			ex_halbtc8821a2ant_init_hwconfig(btcoexist);
+		else if (btcoexist->board_info.btdm_ant_num == 1)
+			ex_halbtc8821a1ant_init_hwconfig(btcoexist);
+	}
+}
+
+void exhalbtc92e_init_coex_dm(struct btc_coexist *btcoexist)
+{
+	struct rtl_priv *rtlpriv = btcoexist->adapter;
+	struct rtl_hal *rtlhal = rtl_hal(rtlpriv);
+
+	if (!halbtc_is_bt_coexist_available(btcoexist))
+		return;
+
+	btcoexist->statistics.cnt_init_coex_dm++;
+
+	if (rtlhal->hw_type == HARDWARE_TYPE_RTL8723BE) {
+		if (btcoexist->board_info.btdm_ant_num == 2)
+			ex92e_halbtc8723b2ant_init_coex_dm(btcoexist);
+		else if (btcoexist->board_info.btdm_ant_num == 1)
+			ex_halbtc8723b1ant_init_coex_dm(btcoexist);
+	} else if (rtlhal->hw_type == HARDWARE_TYPE_RTL8192EE) {
+		ex_halbtc8192e2ant_init_coex_dm(btcoexist);
+	} else if (rtlhal->hw_type == HARDWARE_TYPE_RTL8821AE) {
+		if (btcoexist->board_info.btdm_ant_num == 2)
+			ex_halbtc8821a2ant_init_coex_dm(btcoexist);
+		else if (btcoexist->board_info.btdm_ant_num == 1)
+			ex_halbtc8821a1ant_init_coex_dm(btcoexist);
+	}
+
+	btcoexist->initilized = true;
+}
+
+void exhalbtc92e_ips_notify(struct btc_coexist *btcoexist, u8 type)
+{
+	struct rtl_priv *rtlpriv = btcoexist->adapter;
+	struct rtl_hal *rtlhal = rtl_hal(rtlpriv);
+	u8 ips_type;
+
+	if (!halbtc_is_bt_coexist_available(btcoexist))
+		return;
+	btcoexist->statistics.cnt_ips_notify++;
+	if (btcoexist->manual_control)
+		return;
+
+	if (ERFOFF == type)
+		ips_type = BTC_IPS_ENTER;
+	else
+		ips_type = BTC_IPS_LEAVE;
+
+	if (rtlhal->hw_type == HARDWARE_TYPE_RTL8723BE) {
+		if (btcoexist->board_info.btdm_ant_num == 2)
+			ex92e_halbtc8723b2ant_ips_notify(btcoexist, ips_type);
+		else if (btcoexist->board_info.btdm_ant_num == 1)
+			ex_halbtc8723b1ant_ips_notify(btcoexist, ips_type);
+	} else if (rtlhal->hw_type == HARDWARE_TYPE_RTL8192EE) {
+		ex_halbtc8192e2ant_ips_notify(btcoexist, ips_type);
+	} else if (rtlhal->hw_type == HARDWARE_TYPE_RTL8821AE) {
+		if (btcoexist->board_info.btdm_ant_num == 2)
+			ex_halbtc8821a2ant_ips_notify(btcoexist, ips_type);
+		else if (btcoexist->board_info.btdm_ant_num == 1)
+			ex_halbtc8821a1ant_ips_notify(btcoexist, ips_type);
+	}
+}
+
+void exhalbtc92e_lps_notify(struct btc_coexist *btcoexist, u8 type)
+{
+	struct rtl_priv *rtlpriv = btcoexist->adapter;
+	struct rtl_hal *rtlhal = rtl_hal(rtlpriv);
+	u8 lps_type;
+
+	if (!halbtc_is_bt_coexist_available(btcoexist))
+		return;
+	btcoexist->statistics.cnt_lps_notify++;
+	if (btcoexist->manual_control)
+		return;
+
+	if (EACTIVE == type)
+		lps_type = BTC_LPS_DISABLE;
+	else
+		lps_type = BTC_LPS_ENABLE;
+
+	if (rtlhal->hw_type == HARDWARE_TYPE_RTL8723BE) {
+		if (btcoexist->board_info.btdm_ant_num == 2)
+			ex92e_halbtc8723b2ant_lps_notify(btcoexist, lps_type);
+		else if (btcoexist->board_info.btdm_ant_num == 1)
+			ex_halbtc8723b1ant_lps_notify(btcoexist, lps_type);
+	} else if (rtlhal->hw_type == HARDWARE_TYPE_RTL8192EE) {
+		ex_halbtc8192e2ant_lps_notify(btcoexist, lps_type);
+	} else if (rtlhal->hw_type == HARDWARE_TYPE_RTL8821AE) {
+		if (btcoexist->board_info.btdm_ant_num == 2)
+			ex_halbtc8821a2ant_lps_notify(btcoexist, lps_type);
+		else if (btcoexist->board_info.btdm_ant_num == 1)
+			ex_halbtc8821a1ant_lps_notify(btcoexist, lps_type);
+	}
+}
+
+void exhalbtc92e_scan_notify(struct btc_coexist *btcoexist, u8 type)
+{
+	struct rtl_priv *rtlpriv = btcoexist->adapter;
+	struct rtl_hal *rtlhal = rtl_hal(rtlpriv);
+	u8 scan_type;
+
+	if (!halbtc_is_bt_coexist_available(btcoexist))
+		return;
+	btcoexist->statistics.cnt_scan_notify++;
+	if (btcoexist->manual_control)
+		return;
+
+	if (type)
+		scan_type = BTC_SCAN_START;
+	else
+		scan_type = BTC_SCAN_FINISH;
+
+	if (rtlhal->hw_type == HARDWARE_TYPE_RTL8723BE) {
+		if (btcoexist->board_info.btdm_ant_num == 2)
+			ex92e_halbtc8723b2ant_scan_notify(btcoexist, scan_type);
+		else if (btcoexist->board_info.btdm_ant_num == 1)
+			ex_halbtc8723b1ant_scan_notify(btcoexist, scan_type);
+	} else if (rtlhal->hw_type == HARDWARE_TYPE_RTL8192EE) {
+		ex_halbtc8192e2ant_scan_notify(btcoexist, scan_type);
+	} else if (rtlhal->hw_type == HARDWARE_TYPE_RTL8821AE) {
+		if (btcoexist->board_info.btdm_ant_num == 2)
+			ex_halbtc8821a2ant_scan_notify(btcoexist, scan_type);
+		else if (btcoexist->board_info.btdm_ant_num == 1)
+			ex_halbtc8821a1ant_scan_notify(btcoexist, scan_type);
+	}
+}
+
+void exhalbtc92e_connect_notify(struct btc_coexist *btcoexist, u8 action)
+{
+	struct rtl_priv *rtlpriv = btcoexist->adapter;
+	struct rtl_hal *rtlhal = rtl_hal(rtlpriv);
+	u8 asso_type;
+
+	if (!halbtc_is_bt_coexist_available(btcoexist))
+		return;
+	btcoexist->statistics.cnt_connect_notify++;
+	if (btcoexist->manual_control)
+		return;
+
+	if (action)
+		asso_type = BTC_ASSOCIATE_START;
+	else
+		asso_type = BTC_ASSOCIATE_FINISH;
+
+	if (rtlhal->hw_type == HARDWARE_TYPE_RTL8723BE) {
+		if (btcoexist->board_info.btdm_ant_num == 2)
+			ex92e_halbtc8723b2ant_connect_notify(btcoexist,
+							     asso_type);
+		else if (btcoexist->board_info.btdm_ant_num == 1)
+			ex_halbtc8723b1ant_connect_notify(btcoexist, asso_type);
+	} else if (rtlhal->hw_type == HARDWARE_TYPE_RTL8192EE) {
+		ex_halbtc8192e2ant_connect_notify(btcoexist, asso_type);
+	} else if (rtlhal->hw_type == HARDWARE_TYPE_RTL8821AE) {
+		if (btcoexist->board_info.btdm_ant_num == 2)
+			ex_halbtc8821a2ant_connect_notify(btcoexist,
+							  asso_type);
+		else if (btcoexist->board_info.btdm_ant_num == 1)
+			ex_halbtc8821a1ant_connect_notify(btcoexist,
+							  asso_type);
+	}
+}
+
+void exhalbtc92e_mediastatus_notify(struct btc_coexist *btcoexist,
+				    enum rt_media_status media_status)
+{
+	struct rtl_priv *rtlpriv = btcoexist->adapter;
+	struct rtl_hal *rtlhal = rtl_hal(rtlpriv);
+	u8 status;
+
+	if (!halbtc_is_bt_coexist_available(btcoexist))
+		return;
+	btcoexist->statistics.cnt_media_status_notify++;
+	if (btcoexist->manual_control)
+		return;
+
+	if (RT_MEDIA_CONNECT == media_status)
+		status = BTC_MEDIA_CONNECT;
+	else
+		status = BTC_MEDIA_DISCONNECT;
+
+	if (rtlhal->hw_type == HARDWARE_TYPE_RTL8723BE) {
+		if (btcoexist->board_info.btdm_ant_num == 2)
+			ex92e_halbtc8723b2ant_media_status_notify(btcoexist,
+								  status);
+		else if (btcoexist->board_info.btdm_ant_num == 1)
+			ex_halbtc8723b1ant_media_status_notify(btcoexist,
+							       status);
+	} else if (rtlhal->hw_type == HARDWARE_TYPE_RTL8192EE) {
+		ex_halbtc8192e2ant_media_status_notify(btcoexist, status);
+	} else if (rtlhal->hw_type == HARDWARE_TYPE_RTL8821AE) {
+		if (btcoexist->board_info.btdm_ant_num == 2)
+			ex_halbtc8821a2ant_media_status_notify(btcoexist,
+							       status);
+		else if (btcoexist->board_info.btdm_ant_num == 1)
+			ex_halbtc8821a1ant_media_status_notify(btcoexist,
+							       status);
+	}
+}
+
+void exhalbtc92e_special_packet_notify(struct btc_coexist *btcoexist,
+				       u8 pkt_type)
+{
+	struct rtl_priv *rtlpriv = btcoexist->adapter;
+	struct rtl_hal *rtlhal = rtl_hal(rtlpriv);
+	u8 packet_type;
+
+	if (!halbtc_is_bt_coexist_available(btcoexist))
+		return;
+	btcoexist->statistics.cnt_special_packet_notify++;
+	if (btcoexist->manual_control)
+		return;
+
+	if (PACKET_DHCP == pkt_type) {
+		packet_type = BTC_PACKET_DHCP;
+	} else if (PACKET_EAPOL == pkt_type) {
+		packet_type = BTC_PACKET_EAPOL;
+	} else if (PACKET_ARP == pkt_type) {
+		packet_type = BTC_PACKET_ARP;
+	} else {
+		packet_type = BTC_PACKET_UNKNOWN;
+		return;
+	}
+
+	if (rtlhal->hw_type == HARDWARE_TYPE_RTL8723BE) {
+		if (btcoexist->board_info.btdm_ant_num == 2)
+			ex92e_halbtc8723b2ant_special_packet_notify(btcoexist,
+								    packet_type);
+		else if (btcoexist->board_info.btdm_ant_num == 1)
+			ex_halbtc8723b1ant_special_packet_notify(btcoexist,
+								 packet_type);
+	} else if (rtlhal->hw_type == HARDWARE_TYPE_RTL8821AE) {
+		if (btcoexist->board_info.btdm_ant_num == 2)
+			ex_halbtc8821a2ant_special_packet_notify(btcoexist,
+								 packet_type);
+		else if (btcoexist->board_info.btdm_ant_num == 1)
+			ex_halbtc8821a1ant_special_packet_notify(btcoexist,
+								 packet_type);
+	}
+}
+
+void exhalbtc92e_bt_info_notify(struct btc_coexist *btcoexist,
+				u8 *tmp_buf, u8 length)
+{
+	struct rtl_priv *rtlpriv = btcoexist->adapter;
+	struct rtl_hal *rtlhal = rtl_hal(rtlpriv);
+	if (!halbtc_is_bt_coexist_available(btcoexist))
+		return;
+	btcoexist->statistics.cnt_bt_info_notify++;
+
+	if (rtlhal->hw_type == HARDWARE_TYPE_RTL8723BE) {
+		if (btcoexist->board_info.btdm_ant_num == 2)
+			ex92e_halbtc8723b2ant_bt_info_notify(btcoexist,
+							     tmp_buf, length);
+		else if (btcoexist->board_info.btdm_ant_num == 1)
+			ex_halbtc8723b1ant_bt_info_notify(btcoexist, tmp_buf,
+							  length);
+	} else if (rtlhal->hw_type == HARDWARE_TYPE_RTL8192EE) {
+		/* ex_halbtc8192e2ant_bt_info_notify(btcoexist,
+						     tmp_buf, length); */
+	} else if (rtlhal->hw_type == HARDWARE_TYPE_RTL8821AE) {
+		if (btcoexist->board_info.btdm_ant_num == 2)
+			ex_halbtc8821a2ant_bt_info_notify(btcoexist,
+							  tmp_buf, length);
+		else if (btcoexist->board_info.btdm_ant_num == 1)
+			ex_halbtc8821a1ant_bt_info_notify(btcoexist,
+							  tmp_buf, length);
+	}
+}
+
+void exhalbtc92e_stack_operation_notify(struct btc_coexist *btcoexist, u8 type)
+{
+	u8 stack_op_type;
+
+	if (!halbtc_is_bt_coexist_available(btcoexist))
+		return;
+	btcoexist->statistics.cnt_stack_operation_notify++;
+	if (btcoexist->manual_control)
+		return;
+
+	if ((HCI_BT_OP_INQUIRY_START == type) ||
+	    (HCI_BT_OP_PAGING_START == type) ||
+	    (HCI_BT_OP_PAIRING_START == type))
+		stack_op_type = BTC_STACK_OP_INQ_PAGE_PAIR_START;
+	else if ((HCI_BT_OP_INQUIRY_FINISH == type) ||
+		 (HCI_BT_OP_PAGING_SUCCESS == type) ||
+		 (HCI_BT_OP_PAGING_UNSUCCESS == type) ||
+		 (HCI_BT_OP_PAIRING_FINISH == type))
+		stack_op_type = BTC_STACK_OP_INQ_PAGE_PAIR_FINISH;
+	else
+		stack_op_type = BTC_STACK_OP_NONE;
+}
+
+void exhalbtc92e_halt_notify(struct btc_coexist *btcoexist)
+{
+	struct rtl_priv *rtlpriv = btcoexist->adapter;
+	struct rtl_hal *rtlhal = rtl_hal(rtlpriv);
+	if (!halbtc_is_bt_coexist_available(btcoexist))
+		return;
+
+	btcoexist->binded = false;
+
+	if (rtlhal->hw_type == HARDWARE_TYPE_RTL8723BE) {
+		if (btcoexist->board_info.btdm_ant_num == 2)
+			ex92e_halbtc8723b2ant_halt_notify(btcoexist);
+		else if (btcoexist->board_info.btdm_ant_num == 1)
+			ex_halbtc8723b1ant_halt_notify(btcoexist);
+	} else if (rtlhal->hw_type == HARDWARE_TYPE_RTL8192EE) {
+		ex_halbtc8192e2ant_halt_notify(btcoexist);
+	} else if (rtlhal->hw_type == HARDWARE_TYPE_RTL8821AE) {
+		if (btcoexist->board_info.btdm_ant_num == 2)
+			ex_halbtc8821a2ant_halt_notify(btcoexist);
+		else if (btcoexist->board_info.btdm_ant_num == 1)
+			ex_halbtc8821a1ant_halt_notify(btcoexist);
+	}
+}
+
+void exhalbtc92e_pnp_notify(struct btc_coexist *btcoexist, u8 pnp_state)
+{
+	struct rtl_priv *rtlpriv = btcoexist->adapter;
+	struct rtl_hal *rtlhal = rtl_hal(rtlpriv);
+
+	if (!halbtc_is_bt_coexist_available(btcoexist))
+		return;
+
+	if (rtlhal->hw_type == HARDWARE_TYPE_RTL8723BE) {
+		if (btcoexist->board_info.btdm_ant_num == 1)
+			ex_halbtc8723b1ant_pnp_notify(btcoexist, pnp_state);
+	}
+}
+
+void exhalbtc_coex_dm_switch(struct btc_coexist *btcoexist)
+{
+	struct rtl_priv *rtlpriv = btcoexist->adapter;
+	struct rtl_hal *rtlhal = rtl_hal(rtlpriv);
+	if (!halbtc_is_bt_coexist_available(btcoexist))
+		return;
+	btcoexist->statistics.cnt_coex_dm_switch++;
+
+	if (rtlhal->hw_type == HARDWARE_TYPE_RTL8723BE) {
+		if (btcoexist->board_info.btdm_ant_num == 1) {
+			btcoexist->stop_coex_dm = true;
+			ex_halbtc8723b1ant_coex_dm_reset(btcoexist);
+			exhalbtc92e_set_ant_num(BT_COEX_ANT_TYPE_DETECTED, 2);
+			ex92e_halbtc8723b2ant_init_hwconfig(btcoexist);
+			ex92e_halbtc8723b2ant_init_coex_dm(btcoexist);
+			btcoexist->stop_coex_dm = false;
+		}
+	}
+}
+
+void exhalbtc92e_periodical(struct btc_coexist *btcoexist)
+{
+	struct rtl_priv *rtlpriv = btcoexist->adapter;
+	struct rtl_hal *rtlhal = rtl_hal(rtlpriv);
+	if (!halbtc_is_bt_coexist_available(btcoexist))
+		return;
+	btcoexist->statistics.cnt_periodical++;
+
+	if (rtlhal->hw_type == HARDWARE_TYPE_RTL8723BE) {
+		if (btcoexist->board_info.btdm_ant_num == 2)
+			ex92e_halbtc8723b2ant_periodical(btcoexist);
+		else if (btcoexist->board_info.btdm_ant_num == 1)
+			ex_halbtc8723b1ant_periodical(btcoexist);
+	} else if (rtlhal->hw_type == HARDWARE_TYPE_RTL8192EE) {
+		ex_halbtc8192e2ant_periodical(btcoexist);
+	} else if (rtlhal->hw_type == HARDWARE_TYPE_RTL8821AE) {
+		if (btcoexist->board_info.btdm_ant_num == 2)
+			ex_halbtc8821a2ant_periodical(btcoexist);
+		else if (btcoexist->board_info.btdm_ant_num == 1)
+			if (!halbtc_under_ips(btcoexist))
+				ex_halbtc8821a1ant_periodical(btcoexist);
+	}
+}
+
+void exhalbtc92e_dbg_control(struct btc_coexist *btcoexist,
+			     u8 code, u8 len, u8 *data)
+{
+	if (!halbtc_is_bt_coexist_available(btcoexist))
+		return;
+	btcoexist->statistics.cnt_dbg_ctrl++;
+}
+
+void exhalbtc92e_stack_update_profile_info(void)
+{
+}
+
+void exhalbtc92e_update_min_bt_rssi(char bt_rssi)
+{
+	struct btc_coexist *btcoexist = &gl92e_bt_coexist;
+
+	if (!halbtc_is_bt_coexist_available(btcoexist))
+		return;
+
+	btcoexist->stack_info.min_bt_rssi = bt_rssi;
+}
+
+
+void exhalbtc92e_set_hci_version(u16 hci_version)
+{
+	struct btc_coexist *btcoexist = &gl92e_bt_coexist;
+
+	if (!halbtc_is_bt_coexist_available(btcoexist))
+		return;
+
+	btcoexist->stack_info.hci_version = hci_version;
+}
+
+void exhalbtc92e_set_bt_patch_version(u16 bt_hci_version, u16 bt_patch_version)
+{
+	struct btc_coexist *btcoexist = &gl92e_bt_coexist;
+
+	if (!halbtc_is_bt_coexist_available(btcoexist))
+		return;
+
+	btcoexist->bt_info.bt_real_fw_ver = bt_patch_version;
+	btcoexist->bt_info.bt_hci_ver = bt_hci_version;
+}
+
+void exhalbtc92e_set_bt_exist(bool bt_exist)
+{
+	gl92e_bt_coexist.board_info.bt_exist = bt_exist;
+}
+
+void exhalbtc92e_set_chip_type(u8 chip_type)
+{
+	switch (chip_type) {
+	default:
+	case BT_2WIRE:
+	case BT_ISSC_3WIRE:
+	case BT_ACCEL:
+	case BT_RTL8756:
+		gl92e_bt_coexist.board_info.bt_chip_type = BTC_CHIP_UNDEF;
+		break;
+	case BT_CSR_BC4:
+		gl92e_bt_coexist.board_info.bt_chip_type = BTC_CHIP_CSR_BC4;
+		break;
+	case BT_CSR_BC8:
+		gl92e_bt_coexist.board_info.bt_chip_type = BTC_CHIP_CSR_BC8;
+		break;
+	case BT_RTL8723A:
+		gl92e_bt_coexist.board_info.bt_chip_type = BTC_CHIP_RTL8723A;
+		break;
+	case BT_RTL8821A:
+		gl92e_bt_coexist.board_info.bt_chip_type = BTC_CHIP_RTL8821;
+		break;
+	case BT_RTL8723B:
+		gl92e_bt_coexist.board_info.bt_chip_type = BTC_CHIP_RTL8723B;
+		break;
+	}
+}
+
+void exhalbtc92e_set_ant_num(u8 type, u8 ant_num)
+{
+	if (BT_COEX_ANT_TYPE_PG == type) {
+		gl92e_bt_coexist.board_info.pg_ant_num = ant_num;
+		gl92e_bt_coexist.board_info.btdm_ant_num = ant_num;
+		/* The antenna position:
+		 * Main (default) or Aux for pgAntNum = 2 && btdmAntNum = 1.
+		 * The antenna position should be determined by
+		 * auto-detect mechanism.
+		 * The following is assumed to main,
+		 * and those must be modified
+		 * if y auto-detect mechanism is ready
+		 */
+		if ((gl92e_bt_coexist.board_info.pg_ant_num == 2) &&
+		    (gl92e_bt_coexist.board_info.btdm_ant_num == 1))
+			gl92e_bt_coexist.board_info.btdm_ant_pos =
+						       BTC_ANTENNA_AT_MAIN_PORT;
+		else
+			gl92e_bt_coexist.board_info.btdm_ant_pos =
+						       BTC_ANTENNA_AT_MAIN_PORT;
+	} else if (BT_COEX_ANT_TYPE_ANTDIV == type) {
+		gl92e_bt_coexist.board_info.btdm_ant_num = ant_num;
+		gl92e_bt_coexist.board_info.btdm_ant_pos =
+						       BTC_ANTENNA_AT_MAIN_PORT;
+	} else if (BT_COEX_ANT_TYPE_DETECTED == type) {
+		gl92e_bt_coexist.board_info.btdm_ant_num = ant_num;
+		gl92e_bt_coexist.board_info.btdm_ant_pos =
+						       BTC_ANTENNA_AT_MAIN_PORT;
+	}
+}
+
+void exhalbtc92e_display_bt_coex_info(struct btc_coexist *btcoexist)
+{
+	struct rtl_priv *rtlpriv = btcoexist->adapter;
+	struct rtl_hal *rtlhal = rtl_hal(rtlpriv);
+
+	if (!halbtc_is_bt_coexist_available(btcoexist))
+		return;
+
+	if (rtlhal->hw_type == HARDWARE_TYPE_RTL8723BE) {
+		if (btcoexist->board_info.btdm_ant_num == 2)
+			ex_halbtc8723b2ant92e_display_coex_info(btcoexist);
+		else if (btcoexist->board_info.btdm_ant_num == 1)
+			ex_halbtc8723b1ant_display_coex_info(btcoexist);
+	} else if (rtlhal->hw_type == HARDWARE_TYPE_RTL8821AE) {
+		if (btcoexist->board_info.btdm_ant_num == 2)
+			ex_halbtc8821a2ant_display_coex_info(btcoexist);
+		else if (btcoexist->board_info.btdm_ant_num == 1)
+			ex_halbtc8821a1ant_display_coex_info(btcoexist);
+	}
+}
diff --git a/drivers/staging/rtl8192ee/btcoexist/halbtcoutsrc.h b/drivers/staging/rtl8192ee/btcoexist/halbtcoutsrc.h
new file mode 100644
index 0000000..c0a4286
--- /dev/null
+++ b/drivers/staging/rtl8192ee/btcoexist/halbtcoutsrc.h
@@ -0,0 +1,537 @@
+#ifndef	__HALBTC_OUT_SRC_H__
+#define __HALBTC_OUT_SRC_H__
+
+#include	"../wifi.h"
+
+#define		NORMAL_EXEC				false
+#define		FORCE_EXEC				true
+
+#define		BTC_RF_A				RF90_PATH_A
+#define		BTC_RF_B				RF90_PATH_B
+#define		BTC_RF_C				RF90_PATH_C
+#define		BTC_RF_D				RF90_PATH_D
+
+#define		BTC_SMSP				SINGLEMAC_SINGLEPHY
+#define		BTC_DMDP				DUALMAC_DUALPHY
+#define		BTC_DMSP				DUALMAC_SINGLEPHY
+#define		BTC_MP_UNKNOWN				0xff
+
+#define		IN
+#define		OUT
+
+#define		BT_TMP_BUF_SIZE				100
+
+#define		BT_COEX_ANT_TYPE_PG			0
+#define		BT_COEX_ANT_TYPE_ANTDIV			1
+#define		BT_COEX_ANT_TYPE_DETECTED		2
+
+#define		BTC_MIMO_PS_STATIC			0
+#define		BTC_MIMO_PS_DYNAMIC			1
+
+#define		BTC_RATE_DISABLE			0
+#define		BTC_RATE_ENABLE				1
+
+/* single Antenna definition */
+#define		BTC_ANT_PATH_WIFI			0
+#define		BTC_ANT_PATH_BT				1
+#define		BTC_ANT_PATH_PTA			2
+/* dual Antenna definition */
+#define		BTC_ANT_WIFI_AT_MAIN			0
+#define		BTC_ANT_WIFI_AT_AUX			1
+/* coupler Antenna definition */
+#define		BTC_ANT_WIFI_AT_CPL_MAIN		0
+#define		BTC_ANT_WIFI_AT_CPL_AUX			1
+
+enum btc_chip_interface {
+	BTC_INTF_UNKNOWN	= 0,
+	BTC_INTF_PCI		= 1,
+	BTC_INTF_USB		= 2,
+	BTC_INTF_SDIO		= 3,
+	BTC_INTF_GSPI		= 4,
+	BTC_INTF_MAX
+};
+
+enum btc_chip_type {
+	BTC_CHIP_UNDEF		= 0,
+	BTC_CHIP_CSR_BC4	= 1,
+	BTC_CHIP_CSR_BC8	= 2,
+	BTC_CHIP_RTL8723A	= 3,
+	BTC_CHIP_RTL8821	= 4,
+	BTC_CHIP_RTL8723B	= 5,
+	BTC_CHIP_MAX
+};
+
+enum btc_msg_type {
+	BTC_MSG_INTERFACE	= 0x0,
+	BTC_MSG_ALGORITHM	= 0x1,
+	BTC_MSG_MAX
+};
+
+extern u32 btc_92edbg_type[];
+
+/* following is for BTC_MSG_INTERFACE */
+#define		INTF_INIT				BIT(0)
+#define		INTF_NOTIFY				BIT(2)
+
+/* following is for BTC_ALGORITHM */
+#define		ALGO_BT_RSSI_STATE			BIT(0)
+#define		ALGO_WIFI_RSSI_STATE			BIT(1)
+#define		ALGO_BT_MONITOR				BIT(2)
+#define		ALGO_TRACE				BIT(3)
+#define		ALGO_TRACE_FW				BIT(4)
+#define		ALGO_TRACE_FW_DETAIL			BIT(5)
+#define		ALGO_TRACE_FW_EXEC			BIT(6)
+#define		ALGO_TRACE_SW				BIT(7)
+#define		ALGO_TRACE_SW_DETAIL			BIT(8)
+#define		ALGO_TRACE_SW_EXEC			BIT(9)
+
+/* following is for wifi link status */
+#define		WIFI_STA_CONNECTED			BIT(0)
+#define		WIFI_AP_CONNECTED			BIT(1)
+#define		WIFI_HS_CONNECTED			BIT(2)
+#define		WIFI_P2P_GO_CONNECTED			BIT(3)
+#define		WIFI_P2P_GC_CONNECTED			BIT(4)
+
+
+#define	CL_SPRINTF	snprintf
+#define	CL_PRINTF	printk
+
+#define	BTC_PRINT(dbgtype, dbgflag, printstr, ...)		\
+	do {							\
+		if (unlikely(btc_92edbg_type[dbgtype] & dbgflag)) {\
+			pr_debug(printstr, ##__VA_ARGS__);	\
+		}						\
+	} while (0)
+
+#define	BTC_PRINT_F(dbgtype, dbgflag, printstr, ...)		\
+	do {							\
+		if (unlikely(btc_92edbg_type[dbgtype] & dbgflag)) {\
+			pr_debug("%s: ", __func__);	\
+			pr_cont(printstr, ##__VA_ARGS__);	\
+		}						\
+	} while (0)
+
+#define	BTC_PRINT_ADDR(dbgtype, dbgflag, printstr, _ptr)	\
+	do {							\
+		if (unlikely(btc_92edbg_type[dbgtype] & dbgflag)) {	\
+			int __i;				\
+			u8 *__ptr = (u8 *)_ptr;			\
+			pr_debug printstr;			\
+			for (__i = 0; __i < 6; __i++)		\
+				pr_cont("%02X%s", __ptr[__i],	\
+					(__i == 5) ? "" : "-");	\
+			pr_debug("\n");				\
+		}						\
+	} while (0)
+
+#define BTC_PRINT_DATA(dbgtype, dbgflag, _titlestring, _hexdata, _hexdatalen) \
+	do {								\
+		if (unlikely(btc_92edbg_type[dbgtype] & dbgflag)) {	\
+			int __i;					\
+			u8 *__ptr = (u8 *)_hexdata;			\
+			pr_debug(_titlestring);				\
+			for (__i = 0; __i < (int)_hexdatalen; __i++) {	\
+				pr_cont("%02X%s", __ptr[__i], (((__i + 1) % 4) \
+							== 0) ? "  " : " ");\
+				if (((__i + 1) % 16) == 0)		\
+					pr_cont("\n");			\
+			}						\
+			pr_debug("\n");			\
+		}							\
+	} while (0)
+
+
+#define	BTC_RSSI_HIGH(_rssi_)	\
+	((_rssi_ == BTC_RSSI_STATE_HIGH ||	\
+	  _rssi_ == BTC_RSSI_STATE_STAY_HIGH) ? true : false)
+#define	BTC_RSSI_MEDIUM(_rssi_)	\
+	((_rssi_ == BTC_RSSI_STATE_MEDIUM ||	\
+	  _rssi_ == BTC_RSSI_STATE_STAY_MEDIUM) ? true : false)
+#define	BTC_RSSI_LOW(_rssi_)	\
+	((_rssi_ == BTC_RSSI_STATE_LOW ||	\
+	  _rssi_ == BTC_RSSI_STATE_STAY_LOW) ? true : false)
+
+
+enum btc_power_save_type {
+	BTC_PS_WIFI_NATIVE = 0,
+	BTC_PS_LPS_ON = 1,
+	BTC_PS_LPS_OFF = 2,
+	BTC_PS_LPS_MAX
+};
+
+struct btc_board_info {
+	/* The following is some board information */
+	u8 bt_chip_type;
+	u8 pg_ant_num;	/* pg ant number */
+	u8 btdm_ant_num;	/* ant number for btdm */
+	u8 btdm_ant_pos;
+	bool bt_exist;
+};
+
+enum btc_dbg_opcode {
+	BTC_DBG_SET_COEX_NORMAL = 0x0,
+	BTC_DBG_SET_COEX_WIFI_ONLY = 0x1,
+	BTC_DBG_SET_COEX_BT_ONLY = 0x2,
+	BTC_DBG_MAX
+};
+
+enum btc_rssi_state {
+	BTC_RSSI_STATE_HIGH = 0x0,
+	BTC_RSSI_STATE_MEDIUM = 0x1,
+	BTC_RSSI_STATE_LOW = 0x2,
+	BTC_RSSI_STATE_STAY_HIGH = 0x3,
+	BTC_RSSI_STATE_STAY_MEDIUM = 0x4,
+	BTC_RSSI_STATE_STAY_LOW = 0x5,
+	BTC_RSSI_MAX
+};
+
+enum btc_wifi_role {
+	BTC_ROLE_STATION = 0x0,
+	BTC_ROLE_AP = 0x1,
+	BTC_ROLE_IBSS = 0x2,
+	BTC_ROLE_HS_MODE = 0x3,
+	BTC_ROLE_MAX
+};
+
+enum btc_wifi_bw_mode {
+	BTC_WIFI_BW_LEGACY = 0x0,
+	BTC_WIFI_BW_HT20 = 0x1,
+	BTC_WIFI_BW_HT40 = 0x2,
+	BTC_WIFI_BW_MAX
+};
+
+enum btc_wifi_traffic_dir {
+	BTC_WIFI_TRAFFIC_TX = 0x0,
+	BTC_WIFI_TRAFFIC_RX = 0x1,
+	BTC_WIFI_TRAFFIC_MAX
+};
+
+enum btc_wifi_pnp {
+	BTC_WIFI_PNP_WAKE_UP = 0x0,
+	BTC_WIFI_PNP_SLEEP = 0x1,
+	BTC_WIFI_PNP_MAX
+};
+
+
+enum btc_get_type {
+	/* type bool */
+	BTC_GET_BL_HS_OPERATION,
+	BTC_GET_BL_HS_CONNECTING,
+	BTC_GET_BL_WIFI_CONNECTED,
+	BTC_GET_BL_WIFI_BUSY,
+	BTC_GET_BL_WIFI_SCAN,
+	BTC_GET_BL_WIFI_LINK,
+	BTC_GET_BL_WIFI_DHCP,
+	BTC_GET_BL_WIFI_SOFTAP_IDLE,
+	BTC_GET_BL_WIFI_SOFTAP_LINKING,
+	BTC_GET_BL_WIFI_IN_EARLY_SUSPEND,
+	BTC_GET_BL_WIFI_ROAM,
+	BTC_GET_BL_WIFI_4_WAY_PROGRESS,
+	BTC_GET_BL_WIFI_UNDER_5G,
+	BTC_GET_BL_WIFI_AP_MODE_ENABLE,
+	BTC_GET_BL_WIFI_ENABLE_ENCRYPTION,
+	BTC_GET_BL_WIFI_UNDER_B_MODE,
+	BTC_GET_BL_EXT_SWITCH,
+
+	/* type s4Byte */
+	BTC_GET_S4_WIFI_RSSI,
+	BTC_GET_S4_HS_RSSI,
+
+	/* type u32 */
+	BTC_GET_U4_WIFI_BW,
+	BTC_GET_U4_WIFI_TRAFFIC_DIRECTION,
+	BTC_GET_U4_WIFI_FW_VER,
+	BTC_GET_U4_WIFI_LINK_STATUS,
+	BTC_GET_U4_BT_PATCH_VER,
+
+	/* type u1Byte */
+	BTC_GET_U1_WIFI_DOT11_CHNL,
+	BTC_GET_U1_WIFI_CENTRAL_CHNL,
+	BTC_GET_U1_WIFI_HS_CHNL,
+	BTC_GET_U1_MAC_PHY_MODE,
+	BTC_GET_U1_AP_NUM,
+
+	/* for 1Ant */
+	BTC_GET_U1_LPS_MODE,
+	BTC_GET_BL_BT_SCO_BUSY,
+
+	/* for test mode */
+	BTC_GET_DRIVER_TEST_CFG,
+	BTC_GET_MAX
+};
+
+
+enum btc_set_type {
+	/* type bool */
+	BTC_SET_BL_BT_DISABLE,
+	BTC_SET_BL_BT_TRAFFIC_BUSY,
+	BTC_SET_BL_BT_LIMITED_DIG,
+	BTC_SET_BL_FORCE_TO_ROAM,
+	BTC_SET_BL_TO_REJ_AP_AGG_PKT,
+	BTC_SET_BL_BT_CTRL_AGG_SIZE,
+	BTC_SET_BL_INC_SCAN_DEV_NUM,
+
+	/* type u1Byte */
+	BTC_SET_U1_RSSI_ADJ_VAL_FOR_AGC_TABLE_ON,
+	BTC_SET_U1_AGG_BUF_SIZE,
+
+	/* type trigger some action */
+	BTC_SET_ACT_GET_BT_RSSI,
+	BTC_SET_ACT_AGGREGATE_CTRL,
+
+	/********* for 1Ant **********/
+	/* type bool */
+	BTC_SET_BL_BT_SCO_BUSY,
+	/* type u1Byte */
+	BTC_SET_U1_RSSI_ADJ_VAL_FOR_1ANT_COEX_TYPE,
+	BTC_SET_U1_LPS_VAL,
+	BTC_SET_U1_RPWM_VAL,
+	BTC_SET_U1_1ANT_LPS,
+	BTC_SET_U1_1ANT_RPWM,
+	/* type trigger some action */
+	BTC_SET_ACT_LEAVE_LPS,
+	BTC_SET_ACT_ENTER_LPS,
+	BTC_SET_ACT_NORMAL_LPS,
+	BTC_SET_ACT_INC_FORCE_EXEC_PWR_CMD_CNT,
+	BTC_SET_ACT_DISABLE_LOW_POWER,
+	BTC_SET_ACT_UPDATE_ra_mask,
+	BTC_SET_ACT_SEND_MIMO_PS,
+	/* BT Coex related */
+	BTC_SET_ACT_CTRL_BT_INFO,
+	BTC_SET_ACT_CTRL_BT_COEX,
+	/***************************/
+	BTC_SET_MAX
+};
+
+enum btc_dbg_disp_type {
+	BTC_DBG_DISP_COEX_STATISTICS = 0x0,
+	BTC_DBG_DISP_BT_LINK_INFO = 0x1,
+	BTC_DBG_DISP_BT_FW_VER = 0x2,
+	BTC_DBG_DISP_FW_PWR_MODE_CMD = 0x3,
+	BTC_DBG_DISP_MAX
+};
+
+enum btc_notify_type_ips {
+	BTC_IPS_LEAVE = 0x0,
+	BTC_IPS_ENTER = 0x1,
+	BTC_IPS_MAX
+};
+
+enum btc_notify_type_lps {
+	BTC_LPS_DISABLE = 0x0,
+	BTC_LPS_ENABLE = 0x1,
+	BTC_LPS_MAX
+};
+
+enum btc_notify_type_scan {
+	BTC_SCAN_FINISH = 0x0,
+	BTC_SCAN_START = 0x1,
+	BTC_SCAN_MAX
+};
+
+enum btc_notify_type_associate {
+	BTC_ASSOCIATE_FINISH = 0x0,
+	BTC_ASSOCIATE_START = 0x1,
+	BTC_ASSOCIATE_MAX
+};
+
+enum btc_notify_type_media_status {
+	BTC_MEDIA_DISCONNECT = 0x0,
+	BTC_MEDIA_CONNECT = 0x1,
+	BTC_MEDIA_MAX
+};
+
+enum btc_notify_type_special_packet {
+	BTC_PACKET_UNKNOWN = 0x0,
+	BTC_PACKET_DHCP = 0x1,
+	BTC_PACKET_ARP = 0x2,
+	BTC_PACKET_EAPOL = 0x3,
+	BTC_PACKET_MAX
+};
+
+enum hci_ext_bt_operation {
+	HCI_BT_OP_NONE = 0x0,
+	HCI_BT_OP_INQUIRY_START = 0x1,
+	HCI_BT_OP_INQUIRY_FINISH = 0x2,
+	HCI_BT_OP_PAGING_START = 0x3,
+	HCI_BT_OP_PAGING_SUCCESS = 0x4,
+	HCI_BT_OP_PAGING_UNSUCCESS = 0x5,
+	HCI_BT_OP_PAIRING_START = 0x6,
+	HCI_BT_OP_PAIRING_FINISH = 0x7,
+	HCI_BT_OP_BT_DEV_ENABLE = 0x8,
+	HCI_BT_OP_BT_DEV_DISABLE = 0x9,
+	HCI_BT_OP_MAX
+};
+
+enum btc_notify_type_stack_operation {
+	BTC_STACK_OP_NONE = 0x0,
+	BTC_STACK_OP_INQ_PAGE_PAIR_START = 0x1,
+	BTC_STACK_OP_INQ_PAGE_PAIR_FINISH = 0x2,
+	BTC_STACK_OP_MAX
+};
+
+
+struct btc_bt_info {
+	bool bt_disabled;
+	u8 rssi_adjust_for_agc_table_on;
+	u8 rssi_adjust_for_1ant_coex_type;
+	bool bt_busy;
+	u8 agg_buf_size;
+	bool limited_dig;
+	bool reject_agg_pkt;
+	bool b_bt_ctrl_buf_size;
+	bool increase_scan_dev_num;
+	u16 bt_hci_ver;
+	u16 bt_real_fw_ver;
+	u8 bt_fw_ver;
+
+	bool bt_disable_low_pwr;
+
+	/* the following is for 1Ant solution */
+	bool bt_ctrl_lps;
+	bool bt_pwr_save_mode;
+	bool bt_lps_on;
+	bool force_to_roam;
+	u8 force_exec_pwr_cmd_cnt;
+	u8 lps_val;
+	u8 rpwm_val;
+	u32 ra_mask;
+};
+
+struct btc_stack_info {
+	bool profile_notified;
+	u16 hci_version;	/* stack hci version */
+	u8 num_of_link;
+	bool bt_link_exist;
+	bool sco_exist;
+	bool acl_exist;
+	bool a2dp_exist;
+	bool hid_exist;
+	u8 num_of_hid;
+	bool pan_exist;
+	bool unknown_acl_exist;
+	char min_bt_rssi;
+};
+
+struct btc_statistics {
+	u32 cnt_bind;
+	u32 cnt_init_hw_config;
+	u32 cnt_init_coex_dm;
+	u32 cnt_ips_notify;
+	u32 cnt_lps_notify;
+	u32 cnt_scan_notify;
+	u32 cnt_connect_notify;
+	u32 cnt_media_status_notify;
+	u32 cnt_special_packet_notify;
+	u32 cnt_bt_info_notify;
+	u32 cnt_periodical;
+	u32 cnt_coex_dm_switch;
+	u32 cnt_stack_operation_notify;
+	u32 cnt_dbg_ctrl;
+};
+
+struct btc_bt_link_info {
+	bool bt_link_exist;
+	bool sco_exist;
+	bool sco_only;
+	bool a2dp_exist;
+	bool a2dp_only;
+	bool hid_exist;
+	bool hid_only;
+	bool pan_exist;
+	bool pan_only;
+};
+
+enum btc_antenna_pos {
+	BTC_ANTENNA_AT_MAIN_PORT = 0x1,
+	BTC_ANTENNA_AT_AUX_PORT = 0x2,
+};
+
+struct btc_coexist {
+	/* make sure only one adapter can bind the data context  */
+	bool binded;
+	/* default adapter */
+	void *adapter;
+	struct btc_board_info board_info;
+	/* some bt info referenced by non-bt module */
+	struct btc_bt_info bt_info;
+	struct btc_stack_info stack_info;
+	enum btc_chip_interface	chip_interface;
+	struct btc_bt_link_info bt_link_info;
+
+	bool initilized;
+	bool stop_coex_dm;
+	bool manual_control;
+	u8 *cli_buf;
+	struct btc_statistics statistics;
+	u8 pwr_mode_val[10];
+
+	/* function pointers io related */
+	u8 (*btc_read_1byte)(void *btc_context, u32 reg_addr);
+	void (*btc_write_1byte)(void *btc_context, u32 reg_addr, u8 data);
+	void (*btc_write_1byte_bitmask)(void *btc_context, u32 reg_addr,
+					u8 bit_mask, u8 data1b);
+	u16 (*btc_read_2byte)(void *btc_context, u32 reg_addr);
+	void (*btc_write_2byte)(void *btc_context, u32 reg_addr, u16 data);
+	u32 (*btc_read_4byte)(void *btc_context, u32 reg_addr);
+	void (*btc_write_4byte)(void *btc_context, u32 reg_addr, u32 data);
+
+	void (*btc_set_bb_reg)(void *btc_context, u32 reg_addr,
+			       u32 bit_mask, u32 data);
+	u32 (*btc_get_bb_reg)(void *btc_context, u32 reg_addr,
+			      u32 bit_mask);
+
+	void (*btc_set_rf_reg)(void *btc_context, u8 rf_path, u32 reg_addr,
+			       u32 bit_mask, u32 data);
+	u32 (*btc_get_rf_reg)(void *btc_context, u8 rf_path,
+			      u32 reg_addr, u32 bit_mask);
+
+
+	void (*btc_fill_h2c)(void *btc_context, u8 element_id,
+			     u32 cmd_len, u8 *cmd_buffer);
+
+	void (*btc_disp_dbg_msg)(void *btcoexist, u8 disp_type);
+
+	bool (*btc_get)(void *btcoexist, u8 get_type, void *out_buf);
+	bool (*btc_set)(void *btcoexist, u8 set_type, void *in_buf);
+};
+
+
+bool halbtc92e_is_wifi_uplink(struct rtl_priv *adapter);
+
+
+extern struct btc_coexist gl92e_bt_coexist;
+
+bool exhalbtc92e_initlize_variables(struct rtl_priv *adapter);
+void exhalbtc92e_init_hw_config(struct btc_coexist *btcoexist);
+void exhalbtc92e_init_coex_dm(struct btc_coexist *btcoexist);
+void exhalbtc92e_ips_notify(struct btc_coexist *btcoexist, u8 type);
+void exhalbtc92e_lps_notify(struct btc_coexist *btcoexist, u8 type);
+void exhalbtc92e_scan_notify(struct btc_coexist *btcoexist, u8 type);
+void exhalbtc92e_connect_notify(struct btc_coexist *btcoexist, u8 action);
+void exhalbtc92e_mediastatus_notify(struct btc_coexist *btcoexist,
+				    enum rt_media_status media_status);
+void exhalbtc92e_special_packet_notify(struct btc_coexist *btcoexist,
+				       u8 pkt_type);
+void exhalbtc92e_bt_info_notify(struct btc_coexist *btcoexist, u8 *tmp_buf,
+				u8 length);
+void exhalbtc92e_stack_operation_notify(struct btc_coexist *btcoexist, u8 type);
+void exhalbtc92e_halt_notify(struct btc_coexist *btcoexist);
+void exhalbtc92e_pnp_notify(struct btc_coexist *btcoexist, u8 pnp_state);
+void exhalbtc_coex_dm_switch(struct btc_coexist *btcoexist);
+void exhalbtc92e_periodical(struct btc_coexist *btcoexist);
+void exhalbtc92e_dbg_control(struct btc_coexist *btcoexist, u8 code, u8 len,
+			     u8 *data);
+void exhalbtc92e_stack_update_profile_info(void);
+void exhalbtc92e_set_hci_version(u16 hci_version);
+void exhalbtc92e_set_bt_patch_version(u16 bt_hci_version, u16 bt_patch_version);
+void exhalbtc92e_update_min_bt_rssi(char bt_rssi);
+void exhalbtc92e_set_bt_exist(bool bt_exist);
+void exhalbtc92e_set_chip_type(u8 chip_type);
+void exhalbtc92e_set_ant_num(u8 type, u8 ant_num);
+void exhalbtc92e_display_bt_coex_info(struct btc_coexist *btcoexist);
+void exhalbtc_signal_compensation(struct btc_coexist *btcoexist,
+				  u8 *rssi_wifi, u8 *rssi_bt);
+void exhalbtc_lps_leave(struct btc_coexist *btcoexist);
+void exhalbtc_low_wifi_traffic_notify(struct btc_coexist *btcoexist);
+#endif
diff --git a/drivers/staging/rtl8192ee/btcoexist/rtl_btc.c b/drivers/staging/rtl8192ee/btcoexist/rtl_btc.c
new file mode 100644
index 0000000..50c012a
--- /dev/null
+++ b/drivers/staging/rtl8192ee/btcoexist/rtl_btc.c
@@ -0,0 +1,194 @@
+/******************************************************************************
+ *
+ * Copyright(c) 2009-2010  Realtek Corporation.
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
+ * The full GNU General Public License is included in this distribution in the
+ * file called LICENSE.
+ *
+ * Contact Information:
+ * wlanfae <wlanfae@realtek.com>
+ * Realtek Corporation, No. 2, Innovation Road II, Hsinchu Science Park,
+ * Hsinchu 300, Taiwan.
+ *
+ * Larry Finger <Larry.Finger@lwfinger.net>
+ *
+ *****************************************************************************/
+#include <linux/vmalloc.h>
+#include <linux/module.h>
+
+#include "rtl_btc.h"
+#include "halbt_precomp.h"
+
+static struct rtl_btc_ops rtl_btc_operation = {
+	.btc_init_variables = rtl92e_btc_init_variables,
+	.btc_init_hal_vars = rtl92e_btc_init_hal_vars,
+	.btc_init_hw_config = rtl92e_btc_init_hw_config,
+	.btc_ips_notify = rtl92e_btc_ips_notify,
+	.btc_lps_notify = rtl_btc_lps_notify,
+	.btc_scan_notify = rtl92e_btc_scan_notify,
+	.btc_connect_notify = rtl92e_btc_connect_notify,
+	.btc_mediastatus_notify = rtl92e_btc_mediastatus_notify,
+	.btc_periodical = rtl92e_btc_periodical,
+	.btc_halt_notify = rtl92e_btc_halt_notify,
+	.btc_btinfo_notify = rtl92e_btc_btinfo_notify,
+	.btc_is_limited_dig = rtl92e_btc_is_limited_dig,
+	.btc_is_disable_edca_turbo = rtl92e_btc_is_disable_edca_turbo,
+	.btc_is_bt_disabled = rtl92e_btc_is_bt_disabled,
+	.btc_special_packet_notify = rtl_btc_special_packet_notify,
+};
+
+void rtl92e_btc_init_variables(struct rtl_priv *rtlpriv)
+{
+	exhalbtc92e_initlize_variables(rtlpriv);
+}
+
+void rtl92e_btc_init_hal_vars(struct rtl_priv *rtlpriv)
+{
+	u8 ant_num;
+	u8 bt_exist;
+	u8 bt_type;
+	ant_num = rtl92e_get_hwpg_ant_num(rtlpriv);
+	RT_TRACE(COMP_INIT, DBG_DMESG,
+		 ("%s, antNum is %d\n", __func__, ant_num));
+
+	bt_exist = rtl92e_get_hwpg_bt_exist(rtlpriv);
+	RT_TRACE(COMP_INIT, DBG_DMESG,
+		 ("%s, bt_exist is %d\n", __func__, bt_exist));
+	exhalbtc92e_set_bt_exist(bt_exist);
+
+	bt_type = rtl92e_get_hwpg_bt_type(rtlpriv);
+	RT_TRACE(COMP_INIT, DBG_DMESG,
+		 ("%s, bt_type is %d\n", __func__, bt_type));
+	exhalbtc92e_set_chip_type(bt_type);
+
+	exhalbtc92e_set_ant_num(BT_COEX_ANT_TYPE_PG, ant_num);
+}
+
+void rtl92e_btc_init_hw_config(struct rtl_priv *rtlpriv)
+{
+	exhalbtc92e_init_hw_config(&gl92e_bt_coexist);
+	exhalbtc92e_init_coex_dm(&gl92e_bt_coexist);
+}
+
+void rtl92e_btc_ips_notify(struct rtl_priv *rtlpriv, u8 type)
+{
+	exhalbtc92e_ips_notify(&gl92e_bt_coexist, type);
+}
+
+void rtl_btc_lps_notify(struct rtl_priv *rtlpriv, u8 type)
+{
+	exhalbtc92e_lps_notify(&gl92e_bt_coexist, type);
+}
+
+void rtl92e_btc_scan_notify(struct rtl_priv *rtlpriv, u8 scantype)
+{
+	exhalbtc92e_scan_notify(&gl92e_bt_coexist, scantype);
+}
+
+void rtl92e_btc_connect_notify(struct rtl_priv *rtlpriv, u8 action)
+{
+	exhalbtc92e_connect_notify(&gl92e_bt_coexist, action);
+}
+
+void rtl92e_btc_mediastatus_notify(struct rtl_priv *rtlpriv,
+				   enum rt_media_status mstatus)
+{
+	exhalbtc92e_mediastatus_notify(&gl92e_bt_coexist, mstatus);
+}
+
+void rtl92e_btc_periodical(struct rtl_priv *rtlpriv)
+{
+	exhalbtc92e_periodical(&gl92e_bt_coexist);
+}
+
+void rtl92e_btc_halt_notify(void)
+{
+	exhalbtc92e_halt_notify(&gl92e_bt_coexist);
+}
+
+void rtl92e_btc_btinfo_notify(struct rtl_priv *rtlpriv, u8 *tmp_buf, u8 length)
+{
+	exhalbtc92e_bt_info_notify(&gl92e_bt_coexist, tmp_buf, length);
+}
+
+bool rtl92e_btc_is_limited_dig(struct rtl_priv *rtlpriv)
+{
+	return gl92e_bt_coexist.bt_info.limited_dig;
+}
+
+bool rtl92e_btc_is_disable_edca_turbo(struct rtl_priv *rtlpriv)
+{
+	bool bt_change_edca = false;
+	u32 cur_edca_val;
+	u32 edca_bt_hs_uplink = 0x5ea42b, edca_bt_hs_downlink = 0x5ea42b;
+	u32 edca_hs;
+	u32 edca_addr = 0x504;
+
+	cur_edca_val = rtl_read_dword(rtlpriv, edca_addr);
+	if (halbtc92e_is_wifi_uplink(rtlpriv)) {
+		if (cur_edca_val != edca_bt_hs_uplink) {
+			edca_hs = edca_bt_hs_uplink;
+			bt_change_edca = true;
+		}
+	} else {
+		if (cur_edca_val != edca_bt_hs_downlink) {
+			edca_hs = edca_bt_hs_downlink;
+			bt_change_edca = true;
+		}
+	}
+
+	if (bt_change_edca)
+		rtl_write_dword(rtlpriv, edca_addr, edca_hs);
+
+	return true;
+}
+
+bool rtl92e_btc_is_bt_disabled(struct rtl_priv *rtlpriv)
+{
+	/* It seems 'bt_disabled' is never be initialized or set. */
+	if (gl92e_bt_coexist.bt_info.bt_disabled)
+		return true;
+	else
+		return false;
+}
+
+void rtl_btc_special_packet_notify(struct rtl_priv *rtlpriv, u8 pkt_type)
+{
+	return exhalbtc92e_special_packet_notify(&gl92e_bt_coexist, pkt_type);
+}
+
+struct rtl_btc_ops *stg_rtl_btc_get_ops_pointer(void)
+{
+	return &rtl_btc_operation;
+}
+EXPORT_SYMBOL(stg_rtl_btc_get_ops_pointer);
+
+u8 rtl92e_get_hwpg_ant_num(struct rtl_priv *rtlpriv)
+{
+	u8 num;
+
+	if (rtlpriv->btcoexist.btc_info.ant_num == ANT_X2)
+		num = 2;
+	else
+		num = 1;
+
+	return num;
+}
+u8 rtl92e_get_hwpg_bt_exist(struct rtl_priv *rtlpriv)
+{
+	return rtlpriv->btcoexist.btc_info.btcoexist;
+}
+
+u8 rtl92e_get_hwpg_bt_type(struct rtl_priv *rtlpriv)
+{
+	return rtlpriv->btcoexist.btc_info.bt_type;
+}
diff --git a/drivers/staging/rtl8192ee/btcoexist/rtl_btc.h b/drivers/staging/rtl8192ee/btcoexist/rtl_btc.h
new file mode 100644
index 0000000..9530eb1
--- /dev/null
+++ b/drivers/staging/rtl8192ee/btcoexist/rtl_btc.h
@@ -0,0 +1,62 @@
+/******************************************************************************
+ *
+ * Copyright(c) 2009-2010  Realtek Corporation.
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
+ * The full GNU General Public License is included in this distribution in the
+ * file called LICENSE.
+ *
+ * Contact Information:
+ * wlanfae <wlanfae@realtek.com>
+ * Realtek Corporation, No. 2, Innovation Road II, Hsinchu Science Park,
+ * Hsinchu 300, Taiwan.
+ * Larry Finger <Larry.Finger@lwfinger.net>
+ *
+ *****************************************************************************/
+
+#ifndef __RTL_BTC_H__
+#define __RTL_BTC_H__
+
+#include "halbt_precomp.h"
+
+void rtl92e_btc_init_variables(struct rtl_priv *rtlpriv);
+void rtl92e_btc_init_hal_vars(struct rtl_priv *rtlpriv);
+void rtl92e_btc_init_hw_config(struct rtl_priv *rtlpriv);
+void rtl92e_btc_ips_notify(struct rtl_priv *rtlpriv, u8 type);
+void rtl_btc_lps_notify(struct rtl_priv *rtlpriv, u8 type);
+void rtl92e_btc_scan_notify(struct rtl_priv *rtlpriv, u8 scantype);
+void rtl92e_btc_connect_notify(struct rtl_priv *rtlpriv, u8 action);
+void rtl92e_btc_mediastatus_notify(struct rtl_priv *rtlpriv,
+				   enum rt_media_status mstatus);
+void rtl92e_btc_periodical(struct rtl_priv *rtlpriv);
+void rtl92e_btc_halt_notify(void);
+void rtl92e_btc_btinfo_notify(struct rtl_priv *rtlpriv, u8 *tmpbuf, u8 length);
+bool rtl92e_btc_is_limited_dig(struct rtl_priv *rtlpriv);
+bool rtl92e_btc_is_disable_edca_turbo(struct rtl_priv *rtlpriv);
+bool rtl92e_btc_is_bt_disabled(struct rtl_priv *rtlpriv);
+void rtl_btc_special_packet_notify(struct rtl_priv *rtlpriv, u8 pkt_type);
+
+
+struct rtl_btc_ops *stg_rtl_btc_get_ops_pointer(void);
+
+u8 rtl92e_get_hwpg_ant_num(struct rtl_priv *rtlpriv);
+u8 rtl92e_get_hwpg_bt_exist(struct rtl_priv *rtlpriv);
+u8 rtl92e_get_hwpg_bt_type(struct rtl_priv *rtlpriv);
+enum rt_media_status mgnt_link_status_query(struct ieee80211_hw *hw);
+
+
+
+
+
+
+
+
+#endif
-- 
1.8.4.5
