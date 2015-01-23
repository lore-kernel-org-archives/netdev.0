From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: [PATCH 2/6] rtlwifi: btcoexist: Remove typedef statements
Date: Fri, 23 Jan 2015 11:10:40 -0600
Message-ID: <1422033044-7461-3-git-send-email-Larry.Finger@lwfinger.net>
References: <1422033044-7461-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1422033044-7461-1-git-send-email-Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

In btcoexist, there are a number of typedef statements. Not only do
they violate the rule of avoiding new typdef statements in the kernel,
these are also pointless as they merely introduce an extra level of
indirection in the definition of some function pointers.

Signed-off-by: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
---
 .../net/wireless/rtlwifi/btcoexist/halbtcoutsrc.c  |  2 +-
 .../net/wireless/rtlwifi/btcoexist/halbtcoutsrc.h  | 84 +++++++---------------
 2 files changed, 26 insertions(+), 60 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/btcoexist/halbtcoutsrc.c b/drivers/net/wireless/rtlwifi/btcoexist/halbtcoutsrc.c
index b2791c8..7a72636 100644
--- a/drivers/net/wireless/rtlwifi/btcoexist/halbtcoutsrc.c
+++ b/drivers/net/wireless/rtlwifi/btcoexist/halbtcoutsrc.c
@@ -496,7 +496,7 @@ static u32 halbtc_read_4byte(void *bt_context, u32 reg_addr)
 	return	rtl_read_dword(rtlpriv, reg_addr);
 }
 
-static void halbtc_write_1byte(void *bt_context, u32 reg_addr, u32 data)
+static void halbtc_write_1byte(void *bt_context, u32 reg_addr, u8 data)
 {
 	struct btc_coexist *btcoexist = (struct btc_coexist *)bt_context;
 	struct rtl_priv *rtlpriv = btcoexist->adapter;
diff --git a/drivers/net/wireless/rtlwifi/btcoexist/halbtcoutsrc.h b/drivers/net/wireless/rtlwifi/btcoexist/halbtcoutsrc.h
index 0a903ea..8c64acf 100644
--- a/drivers/net/wireless/rtlwifi/btcoexist/halbtcoutsrc.h
+++ b/drivers/net/wireless/rtlwifi/btcoexist/halbtcoutsrc.h
@@ -350,45 +350,6 @@ enum btc_notify_type_stack_operation {
 	BTC_STACK_OP_MAX
 };
 
-typedef u8 (*bfp_btc_r1)(void *btc_context, u32 reg_addr);
-
-typedef u16 (*bfp_btc_r2)(void *btc_context, u32 reg_addr);
-
-typedef u32 (*bfp_btc_r4)(void *btc_context, u32 reg_addr);
-
-typedef void (*bfp_btc_w1)(void *btc_context, u32 reg_addr, u32 data);
-
-typedef void (*bfp_btc_w1_bit_mak)(void *btc_context, u32 reg_addr,
-				   u32 bit_mask, u8 data1b);
-
-typedef void (*bfp_btc_w2)(void *btc_context, u32 reg_addr, u16 data);
-
-typedef void (*bfp_btc_w4)(void *btc_context, u32 reg_addr, u32 data);
-
-typedef void (*bfp_btc_wr_1byte_bit_mask)(void *btc_context, u32 reg_addr,
-					  u8 bit_mask, u8 data);
-
-typedef void (*bfp_btc_set_bb_reg)(void *btc_context, u32 reg_addr,
-				   u32 bit_mask, u32 data);
-
-typedef u32 (*bfp_btc_get_bb_reg)(void *btc_context, u32 reg_addr,
-				  u32 bit_mask);
-
-typedef void (*bfp_btc_set_rf_reg)(void *btc_context, u8 rf_path, u32 reg_addr,
-				   u32 bit_mask, u32 data);
-
-typedef u32 (*bfp_btc_get_rf_reg)(void *btc_context, u8 rf_path,
-				  u32 reg_addr, u32 bit_mask);
-
-typedef void (*bfp_btc_fill_h2c)(void *btc_context, u8 element_id,
-				 u32 cmd_len, u8 *cmd_buffer);
-
-typedef	bool (*bfp_btc_get)(void *btcoexist, u8 get_type, void *out_buf);
-
-typedef	bool (*bfp_btc_set)(void *btcoexist, u8 set_type, void *in_buf);
-
-typedef void (*bfp_btc_disp_dbg_msg)(void *btcoexist, u8 disp_type);
-
 struct btc_bt_info {
 	bool bt_disabled;
 	u8 rssi_adjust_for_agc_table_on;
@@ -484,26 +445,31 @@ struct btc_coexist {
 	u8 pwr_mode_val[10];
 
 	/* function pointers - io related */
-	bfp_btc_r1 btc_read_1byte;
-	bfp_btc_w1 btc_write_1byte;
-	bfp_btc_w1_bit_mak btc_write_1byte_bitmask;
-	bfp_btc_r2 btc_read_2byte;
-	bfp_btc_w2 btc_write_2byte;
-	bfp_btc_r4 btc_read_4byte;
-	bfp_btc_w4 btc_write_4byte;
-
-	bfp_btc_set_bb_reg btc_set_bb_reg;
-	bfp_btc_get_bb_reg btc_get_bb_reg;
-
-	bfp_btc_set_rf_reg btc_set_rf_reg;
-	bfp_btc_get_rf_reg btc_get_rf_reg;
-
-	bfp_btc_fill_h2c btc_fill_h2c;
-
-	bfp_btc_disp_dbg_msg btc_disp_dbg_msg;
-
-	bfp_btc_get btc_get;
-	bfp_btc_set btc_set;
+	u8 (*btc_read_1byte)(void *btc_context, u32 reg_addr);
+	void (*btc_write_1byte)(void *btc_context, u32 reg_addr, u8 data);
+	void (*btc_write_1byte_bitmask)(void *btc_context, u32 reg_addr,
+					u32 bit_mask, u8 data1b);
+	u16 (*btc_read_2byte)(void *btc_context, u32 reg_addr);
+	void (*btc_write_2byte)(void *btc_context, u32 reg_addr, u16 data);
+	u32 (*btc_read_4byte)(void *btc_context, u32 reg_addr);
+	void (*btc_write_4byte)(void *btc_context, u32 reg_addr, u32 data);
+
+	void (*btc_set_bb_reg)(void *btc_context, u32 reg_addr,
+			       u32 bit_mask, u32 data);
+	u32 (*btc_get_bb_reg)(void *btc_context, u32 reg_addr, u32 bit_mask);
+
+	void (*btc_set_rf_reg)(void *btc_context, u8 rf_path, u32 reg_addr,
+			       u32 bit_mask, u32 data);
+	u32 (*btc_get_rf_reg)(void *btc_context, u8 rf_path,
+			      u32 reg_addr, u32 bit_mask);
+
+	void (*btc_fill_h2c)(void *btc_context, u8 element_id,
+			     u32 cmd_len, u8 *cmd_buffer);
+
+	void (*btc_disp_dbg_msg)(void *btcoexist, u8 disp_type);
+
+	bool (*btc_get)(void *btcoexist, u8 get_type, void *out_buf);
+	bool (*btc_set)(void *btcoexist, u8 set_type, void *in_buf);
 };
 
 bool halbtc_is_wifi_uplink(struct rtl_priv *adapter);
-- 
2.1.2

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
