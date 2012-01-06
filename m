From: Joe Perches <joe@perches.com>
Subject: [PATCH 2/2] rtlwifi: Simplify chip version id logging
Date: Fri,  6 Jan 2012 11:31:43 -0800
Message-ID: <066ccb110481f572dd34b5fc83671194f3d2e00a.1325878172.git.joe@perches.com>
References: <0f80cb0e369db8c8884d4a1d46e70a60c1dfb19c.1325878172.git.joe@perches.com>
Cc: "John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Larry Finger <Larry.Finger@lwfinger.net>,
	Chaoming Li <chaoming_li@realsil.com.cn>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:52121 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755282Ab2AFTb6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Jan 2012 14:31:58 -0500
In-Reply-To: <0f80cb0e369db8c8884d4a1d46e70a60c1dfb19c.1325878172.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reduce object size a few KB too.

$ size drivers/net/wireless/rtlwifi/built-in.o*
   text	   data	    bss	    dec	    hex	filename
 584493	  55333	 126800	 766626	  bb2a2	drivers/net/wireless/rtlwifi/built-in.o.new
 586904	  55333	 127216	 769453	  bbdad	drivers/net/wireless/rtlwifi/built-in.o.old

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/wireless/rtlwifi/rtl8192ce/hw.c  |   19 +++++------
 drivers/net/wireless/rtlwifi/rtl8192cu/mac.c |   46 ++++++++++----------------
 2 files changed, 27 insertions(+), 38 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/rtl8192ce/hw.c b/drivers/net/wireless/rtlwifi/rtl8192ce/hw.c
index 18f615c..971bd29 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192ce/hw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192ce/hw.c
@@ -991,6 +991,7 @@ static enum version_8192c _rtl92ce_read_chip_version(struct ieee80211_hw *hw)
 	struct rtl_phy *rtlphy = &(rtlpriv->phy);
 	enum version_8192c version = VERSION_UNKNOWN;
 	u32 value32;
+	const char *versionid;
 
 	value32 = rtl_read_dword(rtlpriv, REG_SYS_CFG);
 	if (value32 & TRP_VAUX_EN) {
@@ -1003,27 +1004,25 @@ static enum version_8192c _rtl92ce_read_chip_version(struct ieee80211_hw *hw)
 
 	switch (version) {
 	case VERSION_B_CHIP_92C:
-		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-			 "Chip Version ID: VERSION_B_CHIP_92C\n");
+		versionid = "B_CHIP_92C";
 		break;
 	case VERSION_B_CHIP_88C:
-		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-			 "Chip Version ID: VERSION_B_CHIP_88C\n");
+		versionid = "B_CHIP_88C";
 		break;
 	case VERSION_A_CHIP_92C:
-		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-			 "Chip Version ID: VERSION_A_CHIP_92C\n");
+		versionid = "A_CHIP_92C";
 		break;
 	case VERSION_A_CHIP_88C:
-		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-			 "Chip Version ID: VERSION_A_CHIP_88C\n");
+		versionid = "A_CHIP_88C";
 		break;
 	default:
-		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 "Chip Version ID: Unknown. Bug?\n");
+		versionid = "Unknown. Bug?";
 		break;
 	}
 
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
+		 "Chip Version ID: %s\n", versionid);
+
 	switch (version & 0x3) {
 	case CHIP_88C:
 		rtlphy->rf_type = RF_1T1R;
diff --git a/drivers/net/wireless/rtlwifi/rtl8192cu/mac.c b/drivers/net/wireless/rtlwifi/rtl8192cu/mac.c
index 71c7aca..060ed5f 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192cu/mac.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192cu/mac.c
@@ -57,6 +57,7 @@ void rtl92c_read_chip_version(struct ieee80211_hw *hw)
 	struct rtl_phy *rtlphy = &(rtlpriv->phy);
 	struct rtl_hal *rtlhal = rtl_hal(rtlpriv);
 	enum version_8192c chip_version = VERSION_UNKNOWN;
+	const char *versionid;
 	u32 value32;
 
 	value32 = rtl_read_dword(rtlpriv, REG_SYS_CFG);
@@ -87,62 +88,51 @@ void rtl92c_read_chip_version(struct ieee80211_hw *hw)
 	pr_info("Chip version 0x%x\n", chip_version);
 	switch (rtlhal->version) {
 	case VERSION_NORMAL_TSMC_CHIP_92C_1T2R:
-		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-			 "Chip Version ID: VERSION_B_CHIP_92C\n");
+		versionid = "NORMAL_B_CHIP_92C";
 		break;
 	case VERSION_NORMAL_TSMC_CHIP_92C:
-		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-			 "Chip Version ID: VERSION_NORMAL_TSMC_CHIP_92C\n");
+		versionid = "NORMAL_TSMC_CHIP_92C";
 		break;
 	case VERSION_NORMAL_TSMC_CHIP_88C:
-		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-			 "Chip Version ID: VERSION_NORMAL_TSMC_CHIP_88C\n");
+		versionid = "NORMAL_TSMC_CHIP_88C";
 		break;
 	case VERSION_NORMAL_UMC_CHIP_92C_1T2R_A_CUT:
-		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-			 "Chip Version ID: VERSION_NORMAL_UMC_CHIP_i92C_1T2R_A_CUT\n");
+		versionid = "NORMAL_UMC_CHIP_i92C_1T2R_A_CUT";
 		break;
 	case VERSION_NORMAL_UMC_CHIP_92C_A_CUT:
-		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-			 "Chip Version ID: VERSION_NORMAL_UMC_CHIP_92C_A_CUT\n");
+		versionid = "NORMAL_UMC_CHIP_92C_A_CUT";
 		break;
 	case VERSION_NORMAL_UMC_CHIP_88C_A_CUT:
-		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-			 "Chip Version ID: VERSION_NORMAL_UMC_CHIP_88C_A_CUT\n");
+		versionid = "NORMAL_UMC_CHIP_88C_A_CUT";
 		break;
 	case VERSION_NORMAL_UMC_CHIP_92C_1T2R_B_CUT:
-		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-			 "Chip Version ID: VERSION_NORMAL_UMC_CHIP_92C_1T2R_B_CUT\n");
+		versionid = "NORMAL_UMC_CHIP_92C_1T2R_B_CUT";
 		break;
 	case VERSION_NORMAL_UMC_CHIP_92C_B_CUT:
-		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-			 "Chip Version ID: VERSION_NORMAL_UMC_CHIP_92C_B_CUT\n");
+		versionid = "NORMAL_UMC_CHIP_92C_B_CUT";
 		break;
 	case VERSION_NORMAL_UMC_CHIP_88C_B_CUT:
-		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-			 "Chip Version ID: VERSION_NORMAL_UMC_CHIP_88C_B_CUT\n");
+		versionid = "NORMAL_UMC_CHIP_88C_B_CUT";
 		break;
 	case VERSION_NORMA_UMC_CHIP_8723_1T1R_A_CUT:
-		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-			 "Chip Version ID: VERSION_NORMA_UMC_CHIP_8723_1T1R_A_CUT\n");
+		versionid = "NORMAL_UMC_CHIP_8723_1T1R_A_CUT";
 		break;
 	case VERSION_NORMA_UMC_CHIP_8723_1T1R_B_CUT:
-		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-			 "Chip Version ID: VERSION_NORMA_UMC_CHIP_8723_1T1R_B_CUT\n");
+		versionid = "NORMAL_UMC_CHIP_8723_1T1R_B_CUT";
 		break;
 	case VERSION_TEST_CHIP_92C:
-		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-			 "Chip Version ID: VERSION_TEST_CHIP_92C\n");
+		versionid = "TEST_CHIP_92C";
 		break;
 	case VERSION_TEST_CHIP_88C:
-		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-			 "Chip Version ID: VERSION_TEST_CHIP_88C\n");
+		versionid = "TEST_CHIP_88C";
 		break;
 	default:
-		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-			 "Chip Version ID: ???????????????\n");
+		versionid = "UNKNOWN";
 		break;
 	}
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
+		 "Chip Version ID: %s\n", versionid);
+
 	if (IS_92C_SERIAL(rtlhal->version))
 		rtlphy->rf_type =
 			 (IS_92C_1T2R(rtlhal->version)) ? RF_1T2R : RF_2T2R;
-- 
1.7.8.111.gad25c.dirty
