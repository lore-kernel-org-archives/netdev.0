From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 13/31] staging: r8188eu: Remove macro ODM_GetBBReg
Date: Sun, 22 Dec 2013 17:36:44 -0600
Message-ID: <1387755422-11443-14-git-send-email-Larry.Finger@lwfinger.net>
References: <1387755422-11443-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: netdev@vger.kernel.org, devel@driverdev.osuosl.org,
	Larry Finger <Larry.Finger@lwfinger.net>
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:50938 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756772Ab3LVXiD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Dec 2013 18:38:03 -0500
Received: by mail-pd0-f173.google.com with SMTP id p10so4540803pdj.4
        for <netdev@vger.kernel.org>; Sun, 22 Dec 2013 15:38:03 -0800 (PST)
In-Reply-To: <1387755422-11443-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This one is a duplicate of PHY_QueryBBReg.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/staging/rtl8188eu/hal/HalPhyRf_8188e.c    | 68 +++++++++++------------
 drivers/staging/rtl8188eu/hal/odm.c               | 49 ++++++++--------
 drivers/staging/rtl8188eu/hal/odm_interface.c     |  6 --
 drivers/staging/rtl8188eu/include/odm_interface.h |  2 -
 4 files changed, 60 insertions(+), 65 deletions(-)

diff --git a/drivers/staging/rtl8188eu/hal/HalPhyRf_8188e.c b/drivers/staging/rtl8188eu/hal/HalPhyRf_8188e.c
index 1422118..1dbe601 100644
--- a/drivers/staging/rtl8188eu/hal/HalPhyRf_8188e.c
+++ b/drivers/staging/rtl8188eu/hal/HalPhyRf_8188e.c
@@ -186,7 +186,7 @@ odm_TXPowerTrackingCallback_ThermalMeter_8188E(
 
 	if (ThermalValue) {
 		/* Query OFDM path A default setting */
-		ele_D = ODM_GetBBReg(dm_odm, rOFDM0_XATxIQImbalance, bMaskDWord)&bMaskOFDM_D;
+		ele_D = PHY_QueryBBReg(Adapter, rOFDM0_XATxIQImbalance, bMaskDWord)&bMaskOFDM_D;
 		for (i = 0; i < OFDM_TABLE_SIZE_92D; i++) {	/* find the index */
 			if (ele_D == (OFDMSwingTable[i]&bMaskOFDM_D)) {
 				OFDM_index_old[0] = (u8)i;
@@ -200,7 +200,7 @@ odm_TXPowerTrackingCallback_ThermalMeter_8188E(
 
 		/* Query OFDM path B default setting */
 		if (is2t) {
-			ele_D = ODM_GetBBReg(dm_odm, rOFDM0_XBTxIQImbalance, bMaskDWord)&bMaskOFDM_D;
+			ele_D = PHY_QueryBBReg(Adapter, rOFDM0_XBTxIQImbalance, bMaskDWord)&bMaskOFDM_D;
 			for (i = 0; i < OFDM_TABLE_SIZE_92D; i++) {	/* find the index */
 				if (ele_D == (OFDMSwingTable[i]&bMaskOFDM_D)) {
 					OFDM_index_old[1] = (u8)i;
@@ -449,7 +449,7 @@ odm_TXPowerTrackingCallback_ThermalMeter_8188E(
 
 				ODM_RT_TRACE(dm_odm, ODM_COMP_CALIBRATION, ODM_DBG_LOUD,
 					     ("TxPwrTracking 0xc80 = 0x%x, 0xc94 = 0x%x RF 0x24 = 0x%x\n",
-					     ODM_GetBBReg(dm_odm, 0xc80, bMaskDWord), ODM_GetBBReg(dm_odm,
+					     PHY_QueryBBReg(Adapter, 0xc80, bMaskDWord), PHY_QueryBBReg(Adapter,
 					     0xc94, bMaskDWord), ODM_GetRFReg(dm_odm, RF_PATH_A, 0x24, bRFRegOffsetMask)));
 			}
 		}
@@ -505,13 +505,13 @@ phy_PathA_IQK_8188E(struct adapter *adapt, bool configPathB)
 	mdelay(IQK_DELAY_TIME_88E);
 
 	/*  Check failed */
-	regeac = ODM_GetBBReg(dm_odm, rRx_Power_After_IQK_A_2, bMaskDWord);
+	regeac = PHY_QueryBBReg(adapt, rRx_Power_After_IQK_A_2, bMaskDWord);
 	ODM_RT_TRACE(dm_odm, ODM_COMP_CALIBRATION, ODM_DBG_LOUD, ("0xeac = 0x%x\n", regeac));
-	regE94 = ODM_GetBBReg(dm_odm, rTx_Power_Before_IQK_A, bMaskDWord);
+	regE94 = PHY_QueryBBReg(adapt, rTx_Power_Before_IQK_A, bMaskDWord);
 	ODM_RT_TRACE(dm_odm, ODM_COMP_CALIBRATION, ODM_DBG_LOUD, ("0xe94 = 0x%x\n", regE94));
-	regE9C = ODM_GetBBReg(dm_odm, rTx_Power_After_IQK_A, bMaskDWord);
+	regE9C = PHY_QueryBBReg(adapt, rTx_Power_After_IQK_A, bMaskDWord);
 	ODM_RT_TRACE(dm_odm, ODM_COMP_CALIBRATION, ODM_DBG_LOUD,  ("0xe9c = 0x%x\n", regE9C));
-	regEA4 = ODM_GetBBReg(dm_odm, rRx_Power_Before_IQK_A_2, bMaskDWord);
+	regEA4 = PHY_QueryBBReg(adapt, rRx_Power_Before_IQK_A_2, bMaskDWord);
 	ODM_RT_TRACE(dm_odm, ODM_COMP_CALIBRATION, ODM_DBG_LOUD, ("0xea4 = 0x%x\n", regEA4));
 
 	if (!(regeac & BIT28) &&
@@ -571,13 +571,13 @@ phy_PathA_RxIQK(struct adapter *adapt, bool configPathB)
 	mdelay(IQK_DELAY_TIME_88E);
 
 	/*  Check failed */
-	regeac = ODM_GetBBReg(dm_odm, rRx_Power_After_IQK_A_2, bMaskDWord);
+	regeac = PHY_QueryBBReg(adapt, rRx_Power_After_IQK_A_2, bMaskDWord);
 	ODM_RT_TRACE(dm_odm, ODM_COMP_CALIBRATION, ODM_DBG_LOUD,
 		     ("0xeac = 0x%x\n", regeac));
-	regE94 = ODM_GetBBReg(dm_odm, rTx_Power_Before_IQK_A, bMaskDWord);
+	regE94 = PHY_QueryBBReg(adapt, rTx_Power_Before_IQK_A, bMaskDWord);
 	ODM_RT_TRACE(dm_odm, ODM_COMP_CALIBRATION, ODM_DBG_LOUD,
 		     ("0xe94 = 0x%x\n", regE94));
-	regE9C = ODM_GetBBReg(dm_odm, rTx_Power_After_IQK_A, bMaskDWord);
+	regE9C = PHY_QueryBBReg(adapt, rTx_Power_After_IQK_A, bMaskDWord);
 	ODM_RT_TRACE(dm_odm, ODM_COMP_CALIBRATION, ODM_DBG_LOUD,
 		     ("0xe9c = 0x%x\n", regE9C));
 
@@ -590,7 +590,7 @@ phy_PathA_RxIQK(struct adapter *adapt, bool configPathB)
 
 	u4tmp = 0x80007C00 | (regE94&0x3FF0000)  | ((regE9C&0x3FF0000) >> 16);
 	PHY_SetBBReg(adapt, rTx_IQK, bMaskDWord, u4tmp);
-	ODM_RT_TRACE(dm_odm, ODM_COMP_CALIBRATION, ODM_DBG_LOUD, ("0xe40 = 0x%x u4tmp = 0x%x\n", ODM_GetBBReg(dm_odm, rTx_IQK, bMaskDWord), u4tmp));
+	ODM_RT_TRACE(dm_odm, ODM_COMP_CALIBRATION, ODM_DBG_LOUD, ("0xe40 = 0x%x u4tmp = 0x%x\n", PHY_QueryBBReg(adapt, rTx_IQK, bMaskDWord), u4tmp));
 
 	/* 1 RX IQK */
 	/* modify RXIQK mode table */
@@ -626,13 +626,13 @@ phy_PathA_RxIQK(struct adapter *adapt, bool configPathB)
 	mdelay(IQK_DELAY_TIME_88E);
 
 	/*  Check failed */
-	regeac = ODM_GetBBReg(dm_odm, rRx_Power_After_IQK_A_2, bMaskDWord);
+	regeac = PHY_QueryBBReg(adapt, rRx_Power_After_IQK_A_2, bMaskDWord);
 	ODM_RT_TRACE(dm_odm, ODM_COMP_CALIBRATION, ODM_DBG_LOUD,  ("0xeac = 0x%x\n", regeac));
-	regE94 = ODM_GetBBReg(dm_odm, rTx_Power_Before_IQK_A, bMaskDWord);
+	regE94 = PHY_QueryBBReg(adapt, rTx_Power_Before_IQK_A, bMaskDWord);
 	ODM_RT_TRACE(dm_odm, ODM_COMP_CALIBRATION, ODM_DBG_LOUD,  ("0xe94 = 0x%x\n", regE94));
-	regE9C = ODM_GetBBReg(dm_odm, rTx_Power_After_IQK_A, bMaskDWord);
+	regE9C = PHY_QueryBBReg(adapt, rTx_Power_After_IQK_A, bMaskDWord);
 	ODM_RT_TRACE(dm_odm, ODM_COMP_CALIBRATION, ODM_DBG_LOUD,  ("0xe9c = 0x%x\n", regE9C));
-	regEA4 = ODM_GetBBReg(dm_odm, rRx_Power_Before_IQK_A_2, bMaskDWord);
+	regEA4 = PHY_QueryBBReg(adapt, rRx_Power_Before_IQK_A_2, bMaskDWord);
 	ODM_RT_TRACE(dm_odm, ODM_COMP_CALIBRATION, ODM_DBG_LOUD,  ("0xea4 = 0x%x\n", regEA4));
 
 	/* reload RF 0xdf */
@@ -670,19 +670,19 @@ phy_PathB_IQK_8188E(struct adapter *adapt)
 	mdelay(IQK_DELAY_TIME_88E);
 
 	/*  Check failed */
-	regeac = ODM_GetBBReg(dm_odm, rRx_Power_After_IQK_A_2, bMaskDWord);
+	regeac = PHY_QueryBBReg(adapt, rRx_Power_After_IQK_A_2, bMaskDWord);
 	ODM_RT_TRACE(dm_odm, ODM_COMP_CALIBRATION, ODM_DBG_LOUD,
 		     ("0xeac = 0x%x\n", regeac));
-	regeb4 = ODM_GetBBReg(dm_odm, rTx_Power_Before_IQK_B, bMaskDWord);
+	regeb4 = PHY_QueryBBReg(adapt, rTx_Power_Before_IQK_B, bMaskDWord);
 	ODM_RT_TRACE(dm_odm, ODM_COMP_CALIBRATION, ODM_DBG_LOUD,
 		     ("0xeb4 = 0x%x\n", regeb4));
-	regebc = ODM_GetBBReg(dm_odm, rTx_Power_After_IQK_B, bMaskDWord);
+	regebc = PHY_QueryBBReg(adapt, rTx_Power_After_IQK_B, bMaskDWord);
 	ODM_RT_TRACE(dm_odm, ODM_COMP_CALIBRATION, ODM_DBG_LOUD,
 		     ("0xebc = 0x%x\n", regebc));
-	regec4 = ODM_GetBBReg(dm_odm, rRx_Power_Before_IQK_B_2, bMaskDWord);
+	regec4 = PHY_QueryBBReg(adapt, rRx_Power_Before_IQK_B_2, bMaskDWord);
 	ODM_RT_TRACE(dm_odm, ODM_COMP_CALIBRATION, ODM_DBG_LOUD,
 		     ("0xec4 = 0x%x\n", regec4));
-	regecc = ODM_GetBBReg(dm_odm, rRx_Power_After_IQK_B_2, bMaskDWord);
+	regecc = PHY_QueryBBReg(adapt, rRx_Power_After_IQK_B_2, bMaskDWord);
 	ODM_RT_TRACE(dm_odm, ODM_COMP_CALIBRATION, ODM_DBG_LOUD,
 		     ("0xecc = 0x%x\n", regecc));
 
@@ -715,7 +715,7 @@ static void patha_fill_iqk(struct adapter *adapt, bool iqkok, s32 result[][8], u
 	if (final_candidate == 0xFF) {
 		return;
 	} else if (iqkok) {
-		Oldval_0 = (ODM_GetBBReg(dm_odm, rOFDM0_XATxIQImbalance, bMaskDWord) >> 22) & 0x3FF;
+		Oldval_0 = (PHY_QueryBBReg(adapt, rOFDM0_XATxIQImbalance, bMaskDWord) >> 22) & 0x3FF;
 
 		X = result[final_candidate][0];
 		if ((X & 0x00000200) != 0)
@@ -768,7 +768,7 @@ static void pathb_fill_iqk(struct adapter *adapt, bool iqkok, s32 result[][8], u
 	if (final_candidate == 0xFF) {
 		return;
 	} else if (iqkok) {
-		Oldval_1 = (ODM_GetBBReg(dm_odm, rOFDM0_XBTxIQImbalance, bMaskDWord) >> 22) & 0x3FF;
+		Oldval_1 = (PHY_QueryBBReg(adapt, rOFDM0_XBTxIQImbalance, bMaskDWord) >> 22) & 0x3FF;
 
 		X = result[final_candidate][4];
 		if ((X & 0x00000200) != 0)
@@ -824,7 +824,7 @@ void _PHY_SaveADDARegisters(struct adapter *adapt, u32 *ADDAReg, u32 *ADDABackup
 
 	ODM_RT_TRACE(dm_odm, ODM_COMP_CALIBRATION, ODM_DBG_LOUD, ("Save ADDA parameters.\n"));
 	for (i = 0; i < RegisterNum; i++) {
-		ADDABackup[i] = ODM_GetBBReg(dm_odm, ADDAReg[i], bMaskDWord);
+		ADDABackup[i] = PHY_QueryBBReg(adapt, ADDAReg[i], bMaskDWord);
 	}
 }
 
@@ -1097,7 +1097,7 @@ static void phy_IQCalibrate_8188E(struct adapter *adapt, s32 result[][8], u8 t,
 
 	_PHY_PathADDAOn(adapt, ADDA_REG, true, is2t);
 	if (t == 0)
-		dm_odm->RFCalibrateInfo.bRfPiEnable = (u8)ODM_GetBBReg(dm_odm, rFPGA0_XA_HSSIParameter1, BIT(8));
+		dm_odm->RFCalibrateInfo.bRfPiEnable = (u8)PHY_QueryBBReg(adapt, rFPGA0_XA_HSSIParameter1, BIT(8));
 
 	if (!dm_odm->RFCalibrateInfo.bRfPiEnable) {
 		/*  Switch BB to PI mode to do IQ Calibration. */
@@ -1140,8 +1140,8 @@ static void phy_IQCalibrate_8188E(struct adapter *adapt, s32 result[][8], u8 t,
 		PathAOK = phy_PathA_IQK_8188E(adapt, is2t);
 		if (PathAOK == 0x01) {
 			ODM_RT_TRACE(dm_odm, ODM_COMP_CALIBRATION, ODM_DBG_LOUD, ("Path A Tx IQK Success!!\n"));
-				result[t][0] = (ODM_GetBBReg(dm_odm, rTx_Power_Before_IQK_A, bMaskDWord)&0x3FF0000)>>16;
-				result[t][1] = (ODM_GetBBReg(dm_odm, rTx_Power_After_IQK_A, bMaskDWord)&0x3FF0000)>>16;
+				result[t][0] = (PHY_QueryBBReg(adapt, rTx_Power_Before_IQK_A, bMaskDWord)&0x3FF0000)>>16;
+				result[t][1] = (PHY_QueryBBReg(adapt, rTx_Power_After_IQK_A, bMaskDWord)&0x3FF0000)>>16;
 			break;
 		}
 	}
@@ -1150,8 +1150,8 @@ static void phy_IQCalibrate_8188E(struct adapter *adapt, s32 result[][8], u8 t,
 		PathAOK = phy_PathA_RxIQK(adapt, is2t);
 		if (PathAOK == 0x03) {
 			ODM_RT_TRACE(dm_odm, ODM_COMP_CALIBRATION, ODM_DBG_LOUD,  ("Path A Rx IQK Success!!\n"));
-				result[t][2] = (ODM_GetBBReg(dm_odm, rRx_Power_Before_IQK_A_2, bMaskDWord)&0x3FF0000)>>16;
-				result[t][3] = (ODM_GetBBReg(dm_odm, rRx_Power_After_IQK_A_2, bMaskDWord)&0x3FF0000)>>16;
+				result[t][2] = (PHY_QueryBBReg(adapt, rRx_Power_Before_IQK_A_2, bMaskDWord)&0x3FF0000)>>16;
+				result[t][3] = (PHY_QueryBBReg(adapt, rRx_Power_After_IQK_A_2, bMaskDWord)&0x3FF0000)>>16;
 			break;
 		} else {
 			ODM_RT_TRACE(dm_odm, ODM_COMP_CALIBRATION, ODM_DBG_LOUD, ("Path A Rx IQK Fail!!\n"));
@@ -1172,15 +1172,15 @@ static void phy_IQCalibrate_8188E(struct adapter *adapt, s32 result[][8], u8 t,
 			PathBOK = phy_PathB_IQK_8188E(adapt);
 			if (PathBOK == 0x03) {
 				ODM_RT_TRACE(dm_odm, ODM_COMP_CALIBRATION, ODM_DBG_LOUD, ("Path B IQK Success!!\n"));
-				result[t][4] = (ODM_GetBBReg(dm_odm, rTx_Power_Before_IQK_B, bMaskDWord)&0x3FF0000)>>16;
-				result[t][5] = (ODM_GetBBReg(dm_odm, rTx_Power_After_IQK_B, bMaskDWord)&0x3FF0000)>>16;
-				result[t][6] = (ODM_GetBBReg(dm_odm, rRx_Power_Before_IQK_B_2, bMaskDWord)&0x3FF0000)>>16;
-				result[t][7] = (ODM_GetBBReg(dm_odm, rRx_Power_After_IQK_B_2, bMaskDWord)&0x3FF0000)>>16;
+				result[t][4] = (PHY_QueryBBReg(adapt, rTx_Power_Before_IQK_B, bMaskDWord)&0x3FF0000)>>16;
+				result[t][5] = (PHY_QueryBBReg(adapt, rTx_Power_After_IQK_B, bMaskDWord)&0x3FF0000)>>16;
+				result[t][6] = (PHY_QueryBBReg(adapt, rRx_Power_Before_IQK_B_2, bMaskDWord)&0x3FF0000)>>16;
+				result[t][7] = (PHY_QueryBBReg(adapt, rRx_Power_After_IQK_B_2, bMaskDWord)&0x3FF0000)>>16;
 				break;
 			} else if (i == (retryCount - 1) && PathBOK == 0x01) {	/* Tx IQK OK */
 				ODM_RT_TRACE(dm_odm, ODM_COMP_CALIBRATION, ODM_DBG_LOUD, ("Path B Only Tx IQK Success!!\n"));
-				result[t][4] = (ODM_GetBBReg(dm_odm, rTx_Power_Before_IQK_B, bMaskDWord)&0x3FF0000)>>16;
-				result[t][5] = (ODM_GetBBReg(dm_odm, rTx_Power_After_IQK_B, bMaskDWord)&0x3FF0000)>>16;
+				result[t][4] = (PHY_QueryBBReg(adapt, rTx_Power_Before_IQK_B, bMaskDWord)&0x3FF0000)>>16;
+				result[t][5] = (PHY_QueryBBReg(adapt, rTx_Power_After_IQK_B, bMaskDWord)&0x3FF0000)>>16;
 			}
 		}
 
diff --git a/drivers/staging/rtl8188eu/hal/odm.c b/drivers/staging/rtl8188eu/hal/odm.c
index 3a45238..18d3a00 100644
--- a/drivers/staging/rtl8188eu/hal/odm.c
+++ b/drivers/staging/rtl8188eu/hal/odm.c
@@ -457,8 +457,10 @@ void ODM_CmnInfoUpdate(struct odm_dm_struct *pDM_Odm, u32 CmnInfo, u64 Value)
 
 void odm_CommonInfoSelfInit(struct odm_dm_struct *pDM_Odm)
 {
-	pDM_Odm->bCckHighPower = (bool) ODM_GetBBReg(pDM_Odm, 0x824, BIT9);
-	pDM_Odm->RFPathRxEnable = (u8) ODM_GetBBReg(pDM_Odm, 0xc04, 0x0F);
+	struct adapter *adapter = pDM_Odm->Adapter;
+
+	pDM_Odm->bCckHighPower = (bool) PHY_QueryBBReg(adapter, 0x824, BIT9);
+	pDM_Odm->RFPathRxEnable = (u8) PHY_QueryBBReg(adapter, 0xc04, 0x0F);
 	if (pDM_Odm->SupportICType & (ODM_RTL8192C|ODM_RTL8192D))
 		pDM_Odm->AntDivType = CG_TRX_HW_ANTDIV;
 	if (pDM_Odm->SupportICType & (ODM_RTL8723A))
@@ -647,9 +649,10 @@ void odm_DIGbyRSSI_LPS(struct odm_dm_struct *pDM_Odm)
 
 void odm_DIGInit(struct odm_dm_struct *pDM_Odm)
 {
+	struct adapter *adapter = pDM_Odm->Adapter;
 	struct rtw_dig *pDM_DigTable = &pDM_Odm->DM_DigTable;
 
-	pDM_DigTable->CurIGValue = (u8) ODM_GetBBReg(pDM_Odm, ODM_REG(IGI_A, pDM_Odm), ODM_BIT(IGI, pDM_Odm));
+	pDM_DigTable->CurIGValue = (u8) PHY_QueryBBReg(adapter, ODM_REG(IGI_A, pDM_Odm), ODM_BIT(IGI, pDM_Odm));
 	pDM_DigTable->RssiLowThresh	= DM_DIG_THRESH_LOW;
 	pDM_DigTable->RssiHighThresh	= DM_DIG_THRESH_HIGH;
 	pDM_DigTable->FALowThresh	= DM_false_ALARM_THRESH_LOW;
@@ -929,16 +932,16 @@ void odm_FalseAlarmCounterStatistics(struct odm_dm_struct *pDM_Odm)
 		PHY_SetBBReg(adapter, ODM_REG_OFDM_FA_HOLDC_11N, BIT31, 1); /* hold page C counter */
 		PHY_SetBBReg(adapter, ODM_REG_OFDM_FA_RSTD_11N, BIT31, 1); /* hold page D counter */
 
-		ret_value = ODM_GetBBReg(pDM_Odm, ODM_REG_OFDM_FA_TYPE1_11N, bMaskDWord);
+		ret_value = PHY_QueryBBReg(adapter, ODM_REG_OFDM_FA_TYPE1_11N, bMaskDWord);
 		FalseAlmCnt->Cnt_Fast_Fsync = (ret_value&0xffff);
 		FalseAlmCnt->Cnt_SB_Search_fail = ((ret_value&0xffff0000)>>16);
-		ret_value = ODM_GetBBReg(pDM_Odm, ODM_REG_OFDM_FA_TYPE2_11N, bMaskDWord);
+		ret_value = PHY_QueryBBReg(adapter, ODM_REG_OFDM_FA_TYPE2_11N, bMaskDWord);
 		FalseAlmCnt->Cnt_OFDM_CCA = (ret_value&0xffff);
 		FalseAlmCnt->Cnt_Parity_Fail = ((ret_value&0xffff0000)>>16);
-		ret_value = ODM_GetBBReg(pDM_Odm, ODM_REG_OFDM_FA_TYPE3_11N, bMaskDWord);
+		ret_value = PHY_QueryBBReg(adapter, ODM_REG_OFDM_FA_TYPE3_11N, bMaskDWord);
 		FalseAlmCnt->Cnt_Rate_Illegal = (ret_value&0xffff);
 		FalseAlmCnt->Cnt_Crc8_fail = ((ret_value&0xffff0000)>>16);
-		ret_value = ODM_GetBBReg(pDM_Odm, ODM_REG_OFDM_FA_TYPE4_11N, bMaskDWord);
+		ret_value = PHY_QueryBBReg(adapter, ODM_REG_OFDM_FA_TYPE4_11N, bMaskDWord);
 		FalseAlmCnt->Cnt_Mcs_fail = (ret_value&0xffff);
 
 		FalseAlmCnt->Cnt_Ofdm_fail = FalseAlmCnt->Cnt_Parity_Fail + FalseAlmCnt->Cnt_Rate_Illegal +
@@ -946,7 +949,7 @@ void odm_FalseAlarmCounterStatistics(struct odm_dm_struct *pDM_Odm)
 					     FalseAlmCnt->Cnt_Fast_Fsync + FalseAlmCnt->Cnt_SB_Search_fail;
 
 		if (pDM_Odm->SupportICType == ODM_RTL8188E) {
-			ret_value = ODM_GetBBReg(pDM_Odm, ODM_REG_SC_CNT_11N, bMaskDWord);
+			ret_value = PHY_QueryBBReg(adapter, ODM_REG_SC_CNT_11N, bMaskDWord);
 			FalseAlmCnt->Cnt_BW_LSC = (ret_value&0xffff);
 			FalseAlmCnt->Cnt_BW_USC = ((ret_value&0xffff0000)>>16);
 		}
@@ -955,12 +958,12 @@ void odm_FalseAlarmCounterStatistics(struct odm_dm_struct *pDM_Odm)
 		PHY_SetBBReg(adapter, ODM_REG_CCK_FA_RST_11N, BIT12, 1);
 		PHY_SetBBReg(adapter, ODM_REG_CCK_FA_RST_11N, BIT14, 1);
 
-		ret_value = ODM_GetBBReg(pDM_Odm, ODM_REG_CCK_FA_LSB_11N, bMaskByte0);
+		ret_value = PHY_QueryBBReg(adapter, ODM_REG_CCK_FA_LSB_11N, bMaskByte0);
 		FalseAlmCnt->Cnt_Cck_fail = ret_value;
-		ret_value = ODM_GetBBReg(pDM_Odm, ODM_REG_CCK_FA_MSB_11N, bMaskByte3);
+		ret_value = PHY_QueryBBReg(adapter, ODM_REG_CCK_FA_MSB_11N, bMaskByte3);
 		FalseAlmCnt->Cnt_Cck_fail +=  (ret_value & 0xff)<<8;
 
-		ret_value = ODM_GetBBReg(pDM_Odm, ODM_REG_CCK_CCA_CNT_11N, bMaskDWord);
+		ret_value = PHY_QueryBBReg(adapter, ODM_REG_CCK_CCA_CNT_11N, bMaskDWord);
 		FalseAlmCnt->Cnt_CCK_CCA = ((ret_value&0xFF)<<8) | ((ret_value&0xFF00)>>8);
 
 		FalseAlmCnt->Cnt_all = (FalseAlmCnt->Cnt_Fast_Fsync +
@@ -1003,8 +1006,8 @@ void odm_FalseAlarmCounterStatistics(struct odm_dm_struct *pDM_Odm)
 			     FalseAlmCnt->Cnt_Crc8_fail, FalseAlmCnt->Cnt_Mcs_fail));
 	} else { /* FOR ODM_IC_11AC_SERIES */
 		/* read OFDM FA counter */
-		FalseAlmCnt->Cnt_Ofdm_fail = ODM_GetBBReg(pDM_Odm, ODM_REG_OFDM_FA_11AC, bMaskLWord);
-		FalseAlmCnt->Cnt_Cck_fail = ODM_GetBBReg(pDM_Odm, ODM_REG_CCK_FA_11AC, bMaskLWord);
+		FalseAlmCnt->Cnt_Ofdm_fail = PHY_QueryBBReg(adapter, ODM_REG_OFDM_FA_11AC, bMaskLWord);
+		FalseAlmCnt->Cnt_Cck_fail = PHY_QueryBBReg(adapter, ODM_REG_CCK_FA_11AC, bMaskLWord);
 		FalseAlmCnt->Cnt_all = FalseAlmCnt->Cnt_Ofdm_fail + FalseAlmCnt->Cnt_Cck_fail;
 
 		/*  reset OFDM FA coutner */
@@ -1143,10 +1146,10 @@ void ODM_RF_Saving(struct odm_dm_struct *pDM_Odm, u8 bForceInNormal)
 		Rssi_Low_bound = 45;
 	}
 	if (pDM_PSTable->initialize == 0) {
-		pDM_PSTable->Reg874 = (ODM_GetBBReg(pDM_Odm, 0x874, bMaskDWord)&0x1CC000)>>14;
-		pDM_PSTable->RegC70 = (ODM_GetBBReg(pDM_Odm, 0xc70, bMaskDWord)&BIT3)>>3;
-		pDM_PSTable->Reg85C = (ODM_GetBBReg(pDM_Odm, 0x85c, bMaskDWord)&0xFF000000)>>24;
-		pDM_PSTable->RegA74 = (ODM_GetBBReg(pDM_Odm, 0xa74, bMaskDWord)&0xF000)>>12;
+		pDM_PSTable->Reg874 = (PHY_QueryBBReg(adapter, 0x874, bMaskDWord)&0x1CC000)>>14;
+		pDM_PSTable->RegC70 = (PHY_QueryBBReg(adapter, 0xc70, bMaskDWord)&BIT3)>>3;
+		pDM_PSTable->Reg85C = (PHY_QueryBBReg(adapter, 0x85c, bMaskDWord)&0xFF000000)>>24;
+		pDM_PSTable->RegA74 = (PHY_QueryBBReg(adapter, 0xa74, bMaskDWord)&0xF000)>>12;
 		pDM_PSTable->initialize = 1;
 	}
 
@@ -1876,7 +1879,7 @@ u32 GetPSDData(struct odm_dm_struct *pDM_Odm, unsigned int point, u8 initial_gai
 	udelay(30);
 	PHY_SetBBReg(adapter, 0x808, BIT22, 0);
 	/* Read PSD report, Reg8B4[15:0] */
-	psd_report = ODM_GetBBReg(pDM_Odm, 0x8B4, bMaskDWord) & 0x0000FFFF;
+	psd_report = PHY_QueryBBReg(adapter, 0x8B4, bMaskDWord) & 0x0000FFFF;
 
 	psd_report = (u32) (ConvertTo_dB(psd_report))+(u32)(initial_gain_psd-0x1c);
 
@@ -1934,7 +1937,7 @@ static void odm_PHY_SaveAFERegisters(struct odm_dm_struct *pDM_Odm, u32 *AFEReg,
 
 	/* RTPRINT(FINIT, INIT_IQK, ("Save ADDA parameters.\n")); */
 	for (i = 0; i < RegisterNum; i++)
-		AFEBackup[i] = ODM_GetBBReg(pDM_Odm, AFEReg[i], bMaskDWord);
+		AFEBackup[i] = PHY_QueryBBReg(adapter, AFEReg[i], bMaskDWord);
 }
 
 static void odm_PHY_ReloadAFERegisters(struct odm_dm_struct *pDM_Odm, u32 *AFEReg, u32 *AFEBackup, u32 RegiesterNum)
@@ -1997,10 +2000,10 @@ bool ODM_SingleDualAntennaDetection(struct odm_dm_struct *pDM_Odm, u8 mode)
 	udelay(10);
 
 	/* Store A Path Register 88c, c08, 874, c50 */
-	Reg88c = ODM_GetBBReg(pDM_Odm, rFPGA0_AnalogParameter4, bMaskDWord);
-	Regc08 = ODM_GetBBReg(pDM_Odm, rOFDM0_TRMuxPar, bMaskDWord);
-	Reg874 = ODM_GetBBReg(pDM_Odm, rFPGA0_XCD_RFInterfaceSW, bMaskDWord);
-	Regc50 = ODM_GetBBReg(pDM_Odm, rOFDM0_XAAGCCore1, bMaskDWord);
+	Reg88c = PHY_QueryBBReg(adapter, rFPGA0_AnalogParameter4, bMaskDWord);
+	Regc08 = PHY_QueryBBReg(adapter, rOFDM0_TRMuxPar, bMaskDWord);
+	Reg874 = PHY_QueryBBReg(adapter, rFPGA0_XCD_RFInterfaceSW, bMaskDWord);
+	Regc50 = PHY_QueryBBReg(adapter, rOFDM0_XAAGCCore1, bMaskDWord);
 
 	/*  Store AFE Registers */
 	odm_PHY_SaveAFERegisters(pDM_Odm, AFE_REG_8723A, AFE_Backup, 16);
diff --git a/drivers/staging/rtl8188eu/hal/odm_interface.c b/drivers/staging/rtl8188eu/hal/odm_interface.c
index 8ac7690..68a3391 100644
--- a/drivers/staging/rtl8188eu/hal/odm_interface.c
+++ b/drivers/staging/rtl8188eu/hal/odm_interface.c
@@ -69,12 +69,6 @@ u32 ODM_GetMACReg(struct odm_dm_struct *pDM_Odm, u32 RegAddr, u32 BitMask)
 	return PHY_QueryBBReg(Adapter, RegAddr, BitMask);
 }
 
-u32 ODM_GetBBReg(struct odm_dm_struct *pDM_Odm, u32 RegAddr, u32 BitMask)
-{
-	struct adapter *Adapter = pDM_Odm->Adapter;
-	return PHY_QueryBBReg(Adapter, RegAddr, BitMask);
-}
-
 void ODM_SetRFReg(struct odm_dm_struct *pDM_Odm, enum ODM_RF_RADIO_PATH	eRFPath, u32 RegAddr, u32 BitMask, u32 Data)
 {
 	struct adapter *Adapter = pDM_Odm->Adapter;
diff --git a/drivers/staging/rtl8188eu/include/odm_interface.h b/drivers/staging/rtl8188eu/include/odm_interface.h
index c649164..65493dd 100644
--- a/drivers/staging/rtl8188eu/include/odm_interface.h
+++ b/drivers/staging/rtl8188eu/include/odm_interface.h
@@ -94,8 +94,6 @@ void ODM_SetMACReg(struct odm_dm_struct *pDM_Odm, u32 RegAddr,
 
 u32 ODM_GetMACReg(struct odm_dm_struct *pDM_Odm, u32 RegAddr, u32 BitMask);
 
-u32 ODM_GetBBReg(struct odm_dm_struct *pDM_Odm, u32 RegAddr, u32 BitMask);
-
 void ODM_SetRFReg(struct odm_dm_struct *pDM_Odm, enum ODM_RF_RADIO_PATH eRFPath,
 		  u32 RegAddr, u32 BitMask, u32 Data);
 
-- 
1.8.4
