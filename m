From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [RFC/RFT 23/27] rtlwifi: rtl8188ee: Add files for new driver - part 14
Date: Mon, 25 Feb 2013 18:13:35 -0600
Message-ID: <1361837619-2985-24-git-send-email-Larry.Finger@lwfinger.net>
References: <1361837619-2985-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org, jcheung@suse.com, machen@suse.com,
	mmarek@suse.cz
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f52.google.com ([209.85.219.52]:39305 "EHLO
	mail-oa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932307Ab3BZAOr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Feb 2013 19:14:47 -0500
In-Reply-To: <1361837619-2985-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch includes some changes found in testing.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
Cc: jcheung@suse.com
Cc: machen@suse.com
Cc: mmarek@suse.cz
---
 drivers/net/wireless/rtlwifi/rtl8188ee/hw.c | 14 +++++++++-----
 drivers/net/wireless/rtlwifi/rtl8188ee/sw.c |  2 +-
 2 files changed, 10 insertions(+), 6 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/rtl8188ee/hw.c b/drivers/net/wireless/rtlwifi/rtl8188ee/hw.c
index 9e099da..12912a1 100644
--- a/drivers/net/wireless/rtlwifi/rtl8188ee/hw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8188ee/hw.c
@@ -1810,8 +1810,12 @@ static void _rtl88ee_read_txpower_info_from_hwpg(struct ieee80211_hw *hw,
 
 			rtlefuse->txpwrlevel_cck[rf_path][i] =
 				 pwrinfo24g.index_cck_base[rf_path][index];
-			rtlefuse->txpwrlevel_ht40_1s[rf_path][i] =
-				 pwrinfo24g.index_bw40_base[rf_path][index];
+			if (i == 13)
+				rtlefuse->txpwrlevel_ht40_1s[rf_path][i] =
+				     pwrinfo24g.index_bw40_base[rf_path][4];
+			else
+				rtlefuse->txpwrlevel_ht40_1s[rf_path][i] =
+				     pwrinfo24g.index_bw40_base[rf_path][index];
 			rtlefuse->txpwr_ht20diff[rf_path][i] =
 				 pwrinfo24g.bw20_diff[rf_path][0];
 			rtlefuse->txpwr_legacyhtdiff[rf_path][i] =
@@ -1819,7 +1823,7 @@ static void _rtl88ee_read_txpower_info_from_hwpg(struct ieee80211_hw *hw,
 		}
 
 		for (i = 0; i < 14; i++) {
-			RTPRINT(rtlpriv, FINIT, init_txpwr,
+			RTPRINT(rtlpriv, FINIT, INIT_TXPOWER,
 				"RF(%d)-Ch(%d) [CCK / HT40_1S ] = "
 				"[0x%x / 0x%x ]\n", rf_path, i,
 				rtlefuse->txpwrlevel_cck[rf_path][i],
@@ -1838,7 +1842,7 @@ static void _rtl88ee_read_txpower_info_from_hwpg(struct ieee80211_hw *hw,
 	}
 
 	rtlefuse->thermalmeter[0] = rtlefuse->eeprom_thermalmeter;
-	RTPRINT(rtlpriv, FINIT, init_txpwr,
+	RTPRINT(rtlpriv, FINIT, INIT_TXPOWER,
 		"thermalmeter = 0x%x\n", rtlefuse->eeprom_thermalmeter);
 
 	if (!autoload_fail) {
@@ -1848,7 +1852,7 @@ static void _rtl88ee_read_txpower_info_from_hwpg(struct ieee80211_hw *hw,
 	} else {
 		rtlefuse->eeprom_regulatory = 0;
 	}
-	RTPRINT(rtlpriv, FINIT, init_txpwr,
+	RTPRINT(rtlpriv, FINIT, INIT_TXPOWER,
 		"eeprom_regulatory = 0x%x\n", rtlefuse->eeprom_regulatory);
 }
 
diff --git a/drivers/net/wireless/rtlwifi/rtl8188ee/sw.c b/drivers/net/wireless/rtlwifi/rtl8188ee/sw.c
index cff2dd6..690f8e2 100644
--- a/drivers/net/wireless/rtlwifi/rtl8188ee/sw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8188ee/sw.c
@@ -181,7 +181,7 @@ int rtl88e_init_sw_vars(struct ieee80211_hw *hw)
 	release_firmware(firmware);
 
 	/* for early mode */
-	rtlpriv->rtlhal.earlymode_enable = true;
+	rtlpriv->rtlhal.earlymode_enable = false;
 	rtlpriv->rtlhal.max_earlymode_num = 10;
 	for (tid = 0; tid < 8; tid++)
 		skb_queue_head_init(&rtlpriv->mac80211.skb_waitq[tid]);
-- 
1.8.1.4
