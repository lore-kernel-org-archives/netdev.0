From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 01/11 NEXT] rtlwifi: btcoexist: Fix Smatch warning
Date: Mon, 22 Sep 2014 09:39:17 -0500
Message-ID: <1411396767-20611-2-git-send-email-Larry.Finger@lwfinger.net>
References: <1411396767-20611-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org, troy_tan@realsil.com.cn,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f46.google.com ([209.85.219.46]:36321 "EHLO
	mail-oa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753925AbaIVOjz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2014 10:39:55 -0400
In-Reply-To: <1411396767-20611-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The capability for 802.11ac will soon be added to these drivers. Once
that is done, a bitmask will be too large for the data storage.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/net/wireless/rtlwifi/btcoexist/halbtcoutsrc.c | 2 +-
 drivers/net/wireless/rtlwifi/btcoexist/halbtcoutsrc.h | 2 +-
 drivers/net/wireless/rtlwifi/wifi.h                   | 2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/btcoexist/halbtcoutsrc.c b/drivers/net/wireless/rtlwifi/btcoexist/halbtcoutsrc.c
index fcf7459..b2791c8 100644
--- a/drivers/net/wireless/rtlwifi/btcoexist/halbtcoutsrc.c
+++ b/drivers/net/wireless/rtlwifi/btcoexist/halbtcoutsrc.c
@@ -505,7 +505,7 @@ static void halbtc_write_1byte(void *bt_context, u32 reg_addr, u32 data)
 }
 
 static void halbtc_bitmask_write_1byte(void *bt_context, u32 reg_addr,
-				       u8 bit_mask, u8 data)
+				       u32 bit_mask, u8 data)
 {
 	struct btc_coexist *btcoexist = (struct btc_coexist *)bt_context;
 	struct rtl_priv *rtlpriv = btcoexist->adapter;
diff --git a/drivers/net/wireless/rtlwifi/btcoexist/halbtcoutsrc.h b/drivers/net/wireless/rtlwifi/btcoexist/halbtcoutsrc.h
index 1345545..0a903ea 100644
--- a/drivers/net/wireless/rtlwifi/btcoexist/halbtcoutsrc.h
+++ b/drivers/net/wireless/rtlwifi/btcoexist/halbtcoutsrc.h
@@ -359,7 +359,7 @@ typedef u32 (*bfp_btc_r4)(void *btc_context, u32 reg_addr);
 typedef void (*bfp_btc_w1)(void *btc_context, u32 reg_addr, u32 data);
 
 typedef void (*bfp_btc_w1_bit_mak)(void *btc_context, u32 reg_addr,
-				   u8 bit_mask, u8 data1b);
+				   u32 bit_mask, u8 data1b);
 
 typedef void (*bfp_btc_w2)(void *btc_context, u32 reg_addr, u16 data);
 
diff --git a/drivers/net/wireless/rtlwifi/wifi.h b/drivers/net/wireless/rtlwifi/wifi.h
index 541b077..a943a24 100644
--- a/drivers/net/wireless/rtlwifi/wifi.h
+++ b/drivers/net/wireless/rtlwifi/wifi.h
@@ -1267,7 +1267,7 @@ struct rtl_mac {
 	u8 sgi_40;
 	u8 sgi_20;
 	u8 bw_40;
-	u8 mode;		/* wireless mode */
+	u16 mode;		/* wireless mode */
 	u8 slot_time;
 	u8 short_preamble;
 	u8 use_cts_protect;
-- 
1.8.4.5
