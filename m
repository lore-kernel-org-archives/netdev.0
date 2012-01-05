From: Joe Perches <joe@perches.com>
Subject: [PATCH 2/7] rtlwifi: Standardize RT_PRINT_DATA macro and uses
Date: Wed,  4 Jan 2012 19:40:40 -0800
Message-ID: <e7d4163a9897f33145d8a07be54f507ab68e0243.1325734203.git.joe@perches.com>
References: <cover.1325734202.git.joe@perches.com>
Cc: "John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Larry Finger <Larry.Finger@lwfinger.net>,
	Chaoming Li <chaoming_li@realsil.com.cn>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1325734202.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use a single printk(KERN_DEBUG to emit the header line
to avoid any possible output interleaving.

Remove unnecessary parentheses from the calling uses.
Standardize header arg without trailing \n or colon.
Fix a few pairwiase/pairwise typos.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/wireless/rtlwifi/debug.h              |    7 +++----
 drivers/net/wireless/rtlwifi/efuse.c              |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192c/fw_common.c |    9 ++++-----
 drivers/net/wireless/rtlwifi/rtl8192ce/hw.c       |    4 ++--
 drivers/net/wireless/rtlwifi/rtl8192ce/trx.c      |    3 +--
 drivers/net/wireless/rtlwifi/rtl8192cu/hw.c       |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/mac.c      |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/trx.c      |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192de/fw.c       |    8 ++++----
 drivers/net/wireless/rtlwifi/rtl8192de/hw.c       |    4 ++--
 drivers/net/wireless/rtlwifi/rtl8192de/trx.c      |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192se/hw.c       |    4 ++--
 12 files changed, 23 insertions(+), 26 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/debug.h b/drivers/net/wireless/rtlwifi/debug.h
index 802c491..588986a 100644
--- a/drivers/net/wireless/rtlwifi/debug.h
+++ b/drivers/net/wireless/rtlwifi/debug.h
@@ -189,10 +189,9 @@ do {									\
 do {									\
 	if (unlikely(((_comp) & rtlpriv->dbg.global_debugcomponents) &&	\
 		     (_level <= rtlpriv->dbg.global_debuglevel))) {	\
-		printk(KERN_DEBUG "%s: ", KBUILD_MODNAME);		\
-		pr_cont("In process \"%s\" (pid %i):",			\
-			current->comm, current->pid);			\
-		printk(_titlestring);					\
+		printk(KERN_DEBUG "%s: In process \"%s\" (pid %i): %s\n", \
+		       KBUILD_MODNAME, current->comm, current->pid,	\
+		       _titlestring);					\
 		print_hex_dump_bytes("", DUMP_PREFIX_NONE,		\
 				     _hexdata, _hexdatalen);		\
 	}								\
diff --git a/drivers/net/wireless/rtlwifi/efuse.c b/drivers/net/wireless/rtlwifi/efuse.c
index ed1058b..91fd363 100644
--- a/drivers/net/wireless/rtlwifi/efuse.c
+++ b/drivers/net/wireless/rtlwifi/efuse.c
@@ -478,7 +478,7 @@ bool efuse_shadow_update(struct ieee80211_hw *hw)
 			       &rtlefuse->efuse_map[EFUSE_MODIFY_MAP][base],
 			       8);
 			RT_PRINT_DATA(rtlpriv, COMP_INIT, DBG_LOUD,
-				      ("U-efuse\n"), tmpdata, 8);
+				      "U-efuse", tmpdata, 8);
 
 			if (!efuse_pg_packet_write(hw, (u8) offset, word_en,
 						   tmpdata)) {
diff --git a/drivers/net/wireless/rtlwifi/rtl8192c/fw_common.c b/drivers/net/wireless/rtlwifi/rtl8192c/fw_common.c
index 931d979..5401b32 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192c/fw_common.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192c/fw_common.c
@@ -570,7 +570,7 @@ void rtl92c_set_fw_pwrmode_cmd(struct ieee80211_hw *hw, u8 mode)
 					      ppsc->reg_max_lps_awakeintvl);
 
 	RT_PRINT_DATA(rtlpriv, COMP_CMD, DBG_DMESG,
-		      "rtl92c_set_fw_rsvdpagepkt(): u1_h2c_set_pwrmode\n",
+		      "rtl92c_set_fw_rsvdpagepkt(): u1_h2c_set_pwrmode",
 		      u1_h2c_set_pwrmode, 3);
 	rtl92c_fill_h2c_cmd(hw, H2C_SETPWRMODE, 3, u1_h2c_set_pwrmode);
 
@@ -780,10 +780,10 @@ void rtl92c_set_fw_rsvdpagepkt(struct ieee80211_hw *hw, bool dl_finished)
 	totalpacketlen = TOTAL_RESERVED_PKT_LEN;
 
 	RT_PRINT_DATA(rtlpriv, COMP_CMD, DBG_LOUD,
-		      "rtl92c_set_fw_rsvdpagepkt(): HW_VAR_SET_TX_CMD: ALL\n",
+		      "rtl92c_set_fw_rsvdpagepkt(): HW_VAR_SET_TX_CMD: ALL",
 		      &reserved_page_packet[0], totalpacketlen);
 	RT_PRINT_DATA(rtlpriv, COMP_CMD, DBG_DMESG,
-		      "rtl92c_set_fw_rsvdpagepkt(): HW_VAR_SET_TX_CMD: ALL\n",
+		      "rtl92c_set_fw_rsvdpagepkt(): HW_VAR_SET_TX_CMD: ALL",
 		      u1RsvdPageLoc, 3);
 
 
@@ -800,8 +800,7 @@ void rtl92c_set_fw_rsvdpagepkt(struct ieee80211_hw *hw, bool dl_finished)
 		RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD,
 			 ("Set RSVD page location to Fw.\n"));
 		RT_PRINT_DATA(rtlpriv, COMP_CMD, DBG_DMESG,
-				"H2C_RSVDPAGE:\n",
-				u1RsvdPageLoc, 3);
+			      "H2C_RSVDPAGE", u1RsvdPageLoc, 3);
 		rtl92c_fill_h2c_cmd(hw, H2C_RSVDPAGE,
 				    sizeof(u1RsvdPageLoc), u1RsvdPageLoc);
 	} else
diff --git a/drivers/net/wireless/rtlwifi/rtl8192ce/hw.c b/drivers/net/wireless/rtlwifi/rtl8192ce/hw.c
index a3deaef..2156378 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192ce/hw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192ce/hw.c
@@ -1570,7 +1570,7 @@ static void _rtl92ce_read_adapter_info(struct ieee80211_hw *hw)
 			 ("RTL819X Not boot from eeprom, check it !!"));
 	}
 
-	RT_PRINT_DATA(rtlpriv, COMP_INIT, DBG_DMESG, ("MAP\n"),
+	RT_PRINT_DATA(rtlpriv, COMP_INIT, DBG_DMESG, "MAP",
 		      hwinfo, HWSET_MAX_SIZE);
 
 	eeprom_id = *((u16 *)&hwinfo[0]);
@@ -2134,7 +2134,7 @@ void rtl92ce_set_key(struct ieee80211_hw *hw, u32 key_index,
 				 ("add one entry\n"));
 			if (is_pairwise) {
 				RT_PRINT_DATA(rtlpriv, COMP_SEC, DBG_LOUD,
-					      "Pairwiase Key content :",
+					      "Pairwise Key content",
 					      rtlpriv->sec.pairwise_key,
 					      rtlpriv->sec.
 					      key_len[PAIRWISE_KEYIDX]);
diff --git a/drivers/net/wireless/rtlwifi/rtl8192ce/trx.c b/drivers/net/wireless/rtlwifi/rtl8192ce/trx.c
index 4fb5ae2..378bc56 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192ce/trx.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192ce/trx.c
@@ -821,8 +821,7 @@ void rtl92ce_tx_fill_cmddesc(struct ieee80211_hw *hw,
 	}
 
 	RT_PRINT_DATA(rtlpriv, COMP_CMD, DBG_LOUD,
-		      "H2C Tx Cmd Content\n",
-		      pdesc, TX_DESC_SIZE);
+		      "H2C Tx Cmd Content", pdesc, TX_DESC_SIZE);
 }
 
 void rtl92ce_set_desc(u8 *pdesc, bool istx, u8 desc_name, u8 *val)
diff --git a/drivers/net/wireless/rtlwifi/rtl8192cu/hw.c b/drivers/net/wireless/rtlwifi/rtl8192cu/hw.c
index 124cf63..778c0e6 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192cu/hw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192cu/hw.c
@@ -496,7 +496,7 @@ static void _rtl92cu_read_adapter_info(struct ieee80211_hw *hw)
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
 			 ("RTL819X Not boot from eeprom, check it !!"));
 	}
-	RT_PRINT_DATA(rtlpriv, COMP_INIT, DBG_LOUD, ("MAP\n"),
+	RT_PRINT_DATA(rtlpriv, COMP_INIT, DBG_LOUD, "MAP",
 		      hwinfo, HWSET_MAX_SIZE);
 	eeprom_id = le16_to_cpu(*((__le16 *)&hwinfo[0]));
 	if (eeprom_id != RTL8190_EEPROM_ID) {
diff --git a/drivers/net/wireless/rtlwifi/rtl8192cu/mac.c b/drivers/net/wireless/rtlwifi/rtl8192cu/mac.c
index 9e0c8fc..487ee90 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192cu/mac.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192cu/mac.c
@@ -331,7 +331,7 @@ void rtl92c_set_key(struct ieee80211_hw *hw, u32 key_index,
 				 ("add one entry\n"));
 			if (is_pairwise) {
 				RT_PRINT_DATA(rtlpriv, COMP_SEC, DBG_LOUD,
-					      "Pairwiase Key content :",
+					      "Pairwise Key content",
 					      rtlpriv->sec.pairwise_key,
 					      rtlpriv->sec.
 					      key_len[PAIRWISE_KEYIDX]);
diff --git a/drivers/net/wireless/rtlwifi/rtl8192cu/trx.c b/drivers/net/wireless/rtlwifi/rtl8192cu/trx.c
index b3cc7b9..128cfcd 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192cu/trx.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192cu/trx.c
@@ -677,7 +677,7 @@ void rtl92cu_tx_fill_cmddesc(struct ieee80211_hw *hw,
 		SET_TX_DESC_HWSEQ_EN(pdesc, 1);
 		SET_TX_DESC_PKT_ID(pdesc, 8);
 	}
-	RT_PRINT_DATA(rtlpriv, COMP_CMD, DBG_LOUD, "H2C Tx Cmd Content\n",
+	RT_PRINT_DATA(rtlpriv, COMP_CMD, DBG_LOUD, "H2C Tx Cmd Content",
 		      pdesc, RTL_TX_DESC_SIZE);
 }
 
diff --git a/drivers/net/wireless/rtlwifi/rtl8192de/fw.c b/drivers/net/wireless/rtlwifi/rtl8192de/fw.c
index 82f060b..db6972f 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192de/fw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192de/fw.c
@@ -565,7 +565,7 @@ void rtl92d_set_fw_pwrmode_cmd(struct ieee80211_hw *hw, u8 mode)
 	SET_H2CCMD_PWRMODE_PARM_BCN_PASS_TIME(u1_h2c_set_pwrmode,
 					      ppsc->reg_max_lps_awakeintvl);
 	RT_PRINT_DATA(rtlpriv, COMP_CMD, DBG_DMESG,
-		      "rtl92d_set_fw_rsvdpagepkt(): u1_h2c_set_pwrmode\n",
+		      "rtl92d_set_fw_rsvdpagepkt(): u1_h2c_set_pwrmode",
 		      u1_h2c_set_pwrmode, 3);
 	rtl92d_fill_h2c_cmd(hw, H2C_SETPWRMODE, 3, u1_h2c_set_pwrmode);
 }
@@ -757,10 +757,10 @@ void rtl92d_set_fw_rsvdpagepkt(struct ieee80211_hw *hw, bool dl_finished)
 	SET_H2CCMD_RSVDPAGE_LOC_PROBE_RSP(u1RsvdPageLoc, PROBERSP_PG);
 	totalpacketlen = TOTAL_RESERVED_PKT_LEN;
 	RT_PRINT_DATA(rtlpriv, COMP_CMD, DBG_LOUD,
-		      "rtl92d_set_fw_rsvdpagepkt(): HW_VAR_SET_TX_CMD: ALL\n",
+		      "rtl92d_set_fw_rsvdpagepkt(): HW_VAR_SET_TX_CMD: ALL",
 		      &reserved_page_packet[0], totalpacketlen);
 	RT_PRINT_DATA(rtlpriv, COMP_CMD, DBG_DMESG,
-		      "rtl92d_set_fw_rsvdpagepkt(): HW_VAR_SET_TX_CMD: ALL\n",
+		      "rtl92d_set_fw_rsvdpagepkt(): HW_VAR_SET_TX_CMD: ALL",
 		      u1RsvdPageLoc, 3);
 	skb = dev_alloc_skb(totalpacketlen);
 	memcpy((u8 *) skb_put(skb, totalpacketlen), &reserved_page_packet,
@@ -773,7 +773,7 @@ void rtl92d_set_fw_rsvdpagepkt(struct ieee80211_hw *hw, bool dl_finished)
 		RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD,
 			("Set RSVD page location to Fw.\n"));
 		RT_PRINT_DATA(rtlpriv, COMP_CMD, DBG_DMESG,
-			      "H2C_RSVDPAGE:\n", u1RsvdPageLoc, 3);
+			      "H2C_RSVDPAGE", u1RsvdPageLoc, 3);
 		rtl92d_fill_h2c_cmd(hw, H2C_RSVDPAGE,
 			sizeof(u1RsvdPageLoc), u1RsvdPageLoc);
 	} else
diff --git a/drivers/net/wireless/rtlwifi/rtl8192de/hw.c b/drivers/net/wireless/rtlwifi/rtl8192de/hw.c
index c8c4cf9..5c8a639 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192de/hw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192de/hw.c
@@ -1777,7 +1777,7 @@ static void _rtl92de_read_adapter_info(struct ieee80211_hw *hw)
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
 			 ("RTL819X Not boot from eeprom, check it !!"));
 	}
-	RT_PRINT_DATA(rtlpriv, COMP_INIT, DBG_DMESG, ("MAP\n"),
+	RT_PRINT_DATA(rtlpriv, COMP_INIT, DBG_DMESG, "MAP",
 		      hwinfo, HWSET_MAX_SIZE);
 
 	eeprom_id = *((u16 *)&hwinfo[0]);
@@ -2279,7 +2279,7 @@ void rtl92de_set_key(struct ieee80211_hw *hw, u32 key_index,
 				 ("add one entry\n"));
 			if (is_pairwise) {
 				RT_PRINT_DATA(rtlpriv, COMP_SEC, DBG_LOUD,
-					      "Pairwiase Key content :",
+					      "Pairwise Key content",
 					      rtlpriv->sec.pairwise_key,
 					      rtlpriv->
 					      sec.key_len[PAIRWISE_KEYIDX]);
diff --git a/drivers/net/wireless/rtlwifi/rtl8192de/trx.c b/drivers/net/wireless/rtlwifi/rtl8192de/trx.c
index 3637c0c..e84b8d5 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192de/trx.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192de/trx.c
@@ -776,7 +776,7 @@ void rtl92de_tx_fill_cmddesc(struct ieee80211_hw *hw,
 	}
 
 	RT_PRINT_DATA(rtlpriv, COMP_CMD, DBG_LOUD,
-		      "H2C Tx Cmd Content\n", pdesc, TX_DESC_SIZE);
+		      "H2C Tx Cmd Content", pdesc, TX_DESC_SIZE);
 	wmb();
 	SET_TX_DESC_OWN(pdesc, 1);
 }
diff --git a/drivers/net/wireless/rtlwifi/rtl8192se/hw.c b/drivers/net/wireless/rtlwifi/rtl8192se/hw.c
index c474486..f9ba077 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192se/hw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192se/hw.c
@@ -1636,7 +1636,7 @@ static void _rtl92se_read_adapter_info(struct ieee80211_hw *hw)
 			HWSET_MAX_SIZE_92S);
 	}
 
-	RT_PRINT_DATA(rtlpriv, COMP_INIT, DBG_DMESG, ("MAP\n"),
+	RT_PRINT_DATA(rtlpriv, COMP_INIT, DBG_DMESG, "MAP",
 		      hwinfo, HWSET_MAX_SIZE_92S);
 
 	eeprom_id = *((u16 *)&hwinfo[0]);
@@ -2453,7 +2453,7 @@ void rtl92se_set_key(struct ieee80211_hw *hw, u32 key_index, u8 *p_macaddr,
 				 ("add one entry\n"));
 			if (is_pairwise) {
 				RT_PRINT_DATA(rtlpriv, COMP_SEC, DBG_LOUD,
-				      "Pairwiase Key content :",
+				      "Pairwise Key content",
 				       rtlpriv->sec.pairwise_key,
 				       rtlpriv->sec.key_len[PAIRWISE_KEYIDX]);
 
-- 
1.7.8.111.gad25c.dirty
