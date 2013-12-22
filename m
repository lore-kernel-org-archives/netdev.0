From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 26/31] staging: r8188eu: Eliminate enum ODM_RADIO_PATH in favor of rf_radio_path
Date: Sun, 22 Dec 2013 17:36:57 -0600
Message-ID: <1387755422-11443-27-git-send-email-Larry.Finger@lwfinger.net>
References: <1387755422-11443-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: netdev@vger.kernel.org, devel@driverdev.osuosl.org,
	Larry Finger <Larry.Finger@lwfinger.net>
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f49.google.com ([209.85.160.49]:33628 "EHLO
	mail-pb0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756923Ab3LVXiy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Dec 2013 18:38:54 -0500
Received: by mail-pb0-f49.google.com with SMTP id jt11so4627240pbb.22
        for <netdev@vger.kernel.org>; Sun, 22 Dec 2013 15:38:53 -0800 (PST)
In-Reply-To: <1387755422-11443-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are two different enum statements that have been combined.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/staging/rtl8188eu/hal/HalHWImg8188E_RF.c   |  4 +--
 drivers/staging/rtl8188eu/hal/odm_HWConfig.c       | 32 +++++++++++-----------
 drivers/staging/rtl8188eu/hal/odm_RegConfig8188E.c |  6 ++--
 drivers/staging/rtl8188eu/hal/rtl8188e_rf6052.c    |  4 +--
 drivers/staging/rtl8188eu/include/odm.h            |  7 -----
 drivers/staging/rtl8188eu/include/odm_HWConfig.h   |  4 +--
 .../staging/rtl8188eu/include/odm_RegConfig8188E.h |  2 +-
 7 files changed, 26 insertions(+), 33 deletions(-)

diff --git a/drivers/staging/rtl8188eu/hal/HalHWImg8188E_RF.c b/drivers/staging/rtl8188eu/hal/HalHWImg8188E_RF.c
index 480c810..17c6411 100644
--- a/drivers/staging/rtl8188eu/hal/HalHWImg8188E_RF.c
+++ b/drivers/staging/rtl8188eu/hal/HalHWImg8188E_RF.c
@@ -211,7 +211,7 @@ enum HAL_STATUS ODM_ReadAndConfig_RadioA_1T_8188E(struct odm_dm_struct *pDM_Odm)
 				else if (v1 == 0xf9)
 					rtw_IOL_append_DELAY_US_cmd(pxmit_frame, 1);
 				else
-					rtw_IOL_append_WRF_cmd(pxmit_frame, ODM_RF_PATH_A, (u16)v1, v2, bRFRegOffsetMask);
+					rtw_IOL_append_WRF_cmd(pxmit_frame, RF_PATH_A, (u16)v1, v2, bRFRegOffsetMask);
 			} else {
 				odm_ConfigRF_RadioA_8188E(pDM_Odm, v1, v2);
 			}
@@ -247,7 +247,7 @@ enum HAL_STATUS ODM_ReadAndConfig_RadioA_1T_8188E(struct odm_dm_struct *pDM_Odm)
 						else if (v1 == 0xf9)
 							rtw_IOL_append_DELAY_US_cmd(pxmit_frame, 1);
 						else
-							rtw_IOL_append_WRF_cmd(pxmit_frame, ODM_RF_PATH_A, (u16)v1, v2, bRFRegOffsetMask);
+							rtw_IOL_append_WRF_cmd(pxmit_frame, RF_PATH_A, (u16)v1, v2, bRFRegOffsetMask);
 					} else {
 						odm_ConfigRF_RadioA_8188E(pDM_Odm, v1, v2);
 					}
diff --git a/drivers/staging/rtl8188eu/hal/odm_HWConfig.c b/drivers/staging/rtl8188eu/hal/odm_HWConfig.c
index a452c7d..a755df3 100644
--- a/drivers/staging/rtl8188eu/hal/odm_HWConfig.c
+++ b/drivers/staging/rtl8188eu/hal/odm_HWConfig.c
@@ -106,8 +106,8 @@ static void odm_RxPhyStatus92CSeries_Parsing(struct odm_dm_struct *dm_odm,
 
 	isCCKrate = ((pPktinfo->Rate >= DESC92C_RATE1M) && (pPktinfo->Rate <= DESC92C_RATE11M)) ? true : false;
 
-	pPhyInfo->RxMIMOSignalQuality[ODM_RF_PATH_A] = -1;
-	pPhyInfo->RxMIMOSignalQuality[ODM_RF_PATH_B] = -1;
+	pPhyInfo->RxMIMOSignalQuality[RF_PATH_A] = -1;
+	pPhyInfo->RxMIMOSignalQuality[RF_PATH_B] = -1;
 
 	if (isCCKrate) {
 		u8 cck_agc_rpt;
@@ -190,15 +190,15 @@ static void odm_RxPhyStatus92CSeries_Parsing(struct odm_dm_struct *dm_odm,
 					SQ = ((64-SQ_rpt) * 100) / 44;
 			}
 			pPhyInfo->SignalQuality = SQ;
-			pPhyInfo->RxMIMOSignalQuality[ODM_RF_PATH_A] = SQ;
-			pPhyInfo->RxMIMOSignalQuality[ODM_RF_PATH_B] = -1;
+			pPhyInfo->RxMIMOSignalQuality[RF_PATH_A] = SQ;
+			pPhyInfo->RxMIMOSignalQuality[RF_PATH_B] = -1;
 		}
 	} else { /* is OFDM rate */
 		dm_odm->PhyDbgInfo.NumQryPhyStatusOFDM++;
 
 		/*  (1)Get RSSI for HT rate */
 
-		 for (i = ODM_RF_PATH_A; i < ODM_RF_PATH_MAX; i++) {
+		 for (i = RF_PATH_A; i < RF_PATH_MAX; i++) {
 			/*  2008/01/30 MH we will judge RF RX path now. */
 			if (dm_odm->RFPathRxEnable & BIT(i))
 				rf_rx_num++;
@@ -252,7 +252,7 @@ static void odm_RxPhyStatus92CSeries_Parsing(struct odm_dm_struct *dm_odm,
 			EVM = odm_EVMdbToPercentage((pPhyStaRpt->stream_rxevm[i]));	/* dbm */
 
 			if (pPktinfo->bPacketMatchBSSID) {
-				if (i == ODM_RF_PATH_A) /*  Fill value in RFD, Get the first spatial stream only */
+				if (i == RF_PATH_A) /*  Fill value in RFD, Get the first spatial stream only */
 					pPhyInfo->SignalQuality = (u8)(EVM & 0xff);
 				pPhyInfo->RxMIMOSignalQuality[i] = (u8)(EVM & 0xff);
 			}
@@ -330,15 +330,15 @@ static void odm_Process_RSSIForDM(struct odm_dm_struct *dm_odm,
 
 	if (pPktinfo->bPacketToSelf || pPktinfo->bPacketBeacon) {
 		if (!isCCKrate) { /* ofdm rate */
-			if (pPhyInfo->RxMIMOSignalStrength[ODM_RF_PATH_B] == 0) {
-				RSSI_Ave = pPhyInfo->RxMIMOSignalStrength[ODM_RF_PATH_A];
+			if (pPhyInfo->RxMIMOSignalStrength[RF_PATH_B] == 0) {
+				RSSI_Ave = pPhyInfo->RxMIMOSignalStrength[RF_PATH_A];
 			} else {
-				if (pPhyInfo->RxMIMOSignalStrength[ODM_RF_PATH_A] > pPhyInfo->RxMIMOSignalStrength[ODM_RF_PATH_B]) {
-					RSSI_max = pPhyInfo->RxMIMOSignalStrength[ODM_RF_PATH_A];
-					RSSI_min = pPhyInfo->RxMIMOSignalStrength[ODM_RF_PATH_B];
+				if (pPhyInfo->RxMIMOSignalStrength[RF_PATH_A] > pPhyInfo->RxMIMOSignalStrength[RF_PATH_B]) {
+					RSSI_max = pPhyInfo->RxMIMOSignalStrength[RF_PATH_A];
+					RSSI_min = pPhyInfo->RxMIMOSignalStrength[RF_PATH_B];
 				} else {
-					RSSI_max = pPhyInfo->RxMIMOSignalStrength[ODM_RF_PATH_B];
-					RSSI_min = pPhyInfo->RxMIMOSignalStrength[ODM_RF_PATH_A];
+					RSSI_max = pPhyInfo->RxMIMOSignalStrength[RF_PATH_B];
+					RSSI_min = pPhyInfo->RxMIMOSignalStrength[RF_PATH_A];
 				}
 				if ((RSSI_max - RSSI_min) < 3)
 					RSSI_Ave = RSSI_max;
@@ -445,11 +445,11 @@ void ODM_MacStatusQuery(struct odm_dm_struct *dm_odm, u8 *mac_stat,
 }
 
 enum HAL_STATUS ODM_ConfigRFWithHeaderFile(struct odm_dm_struct *dm_odm,
-					   enum ODM_RF_RADIO_PATH content,
-					   enum ODM_RF_RADIO_PATH rfpath)
+					   enum rf_radio_path content,
+					   enum rf_radio_path rfpath)
 {
 	ODM_RT_TRACE(dm_odm, ODM_COMP_INIT, ODM_DBG_LOUD, ("===>ODM_ConfigRFWithHeaderFile\n"));
-	if (rfpath == ODM_RF_PATH_A)
+	if (rfpath == RF_PATH_A)
 		READ_AND_CONFIG(8188E, _RadioA_1T_);
 	ODM_RT_TRACE(dm_odm, ODM_COMP_INIT, ODM_DBG_LOUD, (" ===> ODM_ConfigRFWithHeaderFile() Radio_A:Rtl8188ERadioA_1TArray\n"));
 	ODM_RT_TRACE(dm_odm, ODM_COMP_INIT, ODM_DBG_LOUD, (" ===> ODM_ConfigRFWithHeaderFile() Radio_B:Rtl8188ERadioB_1TArray\n"));
diff --git a/drivers/staging/rtl8188eu/hal/odm_RegConfig8188E.c b/drivers/staging/rtl8188eu/hal/odm_RegConfig8188E.c
index 0594e70..6193d9f 100644
--- a/drivers/staging/rtl8188eu/hal/odm_RegConfig8188E.c
+++ b/drivers/staging/rtl8188eu/hal/odm_RegConfig8188E.c
@@ -21,7 +21,7 @@
 #include "odm_precomp.h"
 
 void odm_ConfigRFReg_8188E(struct odm_dm_struct *pDM_Odm, u32 Addr,
-			   u32 Data, enum ODM_RF_RADIO_PATH RF_PATH,
+			   u32 Data, enum rf_radio_path RF_PATH,
 			   u32 RegAddr)
 {
 	struct adapter *adapter = pDM_Odm->Adapter;
@@ -50,7 +50,7 @@ void odm_ConfigRF_RadioA_8188E(struct odm_dm_struct *pDM_Odm, u32 Addr, u32 Data
 	u32  content = 0x1000; /*  RF_Content: radioa_txt */
 	u32 maskforPhySet = (u32)(content&0xE000);
 
-	odm_ConfigRFReg_8188E(pDM_Odm, Addr, Data, ODM_RF_PATH_A, Addr|maskforPhySet);
+	odm_ConfigRFReg_8188E(pDM_Odm, Addr, Data, RF_PATH_A, Addr|maskforPhySet);
 	ODM_RT_TRACE(pDM_Odm, ODM_COMP_INIT, ODM_DBG_TRACE, ("===> ODM_ConfigRFWithHeaderFile: [RadioA] %08X %08X\n", Addr, Data));
 }
 
@@ -59,7 +59,7 @@ void odm_ConfigRF_RadioB_8188E(struct odm_dm_struct *pDM_Odm, u32 Addr, u32 Data
 	u32  content = 0x1001; /*  RF_Content: radiob_txt */
 	u32 maskforPhySet = (u32)(content&0xE000);
 
-	odm_ConfigRFReg_8188E(pDM_Odm, Addr, Data, ODM_RF_PATH_B, Addr|maskforPhySet);
+	odm_ConfigRFReg_8188E(pDM_Odm, Addr, Data, RF_PATH_B, Addr|maskforPhySet);
 
 	ODM_RT_TRACE(pDM_Odm, ODM_COMP_INIT, ODM_DBG_TRACE, ("===> ODM_ConfigRFWithHeaderFile: [RadioB] %08X %08X\n", Addr, Data));
 }
diff --git a/drivers/staging/rtl8188eu/hal/rtl8188e_rf6052.c b/drivers/staging/rtl8188eu/hal/rtl8188e_rf6052.c
index 2999da7..b1cb5c4 100644
--- a/drivers/staging/rtl8188eu/hal/rtl8188e_rf6052.c
+++ b/drivers/staging/rtl8188eu/hal/rtl8188e_rf6052.c
@@ -518,11 +518,11 @@ static int phy_RF6052_Config_ParaFile(struct adapter *Adapter)
 		/*----Initialize RF fom connfiguration file----*/
 		switch (eRFPath) {
 		case RF_PATH_A:
-			if (HAL_STATUS_FAILURE == ODM_ConfigRFWithHeaderFile(&pHalData->odmpriv, (enum ODM_RF_RADIO_PATH)eRFPath, (enum ODM_RF_RADIO_PATH)eRFPath))
+			if (HAL_STATUS_FAILURE == ODM_ConfigRFWithHeaderFile(&pHalData->odmpriv, (enum rf_radio_path)eRFPath, (enum rf_radio_path)eRFPath))
 				rtStatus = _FAIL;
 			break;
 		case RF_PATH_B:
-		if (HAL_STATUS_FAILURE == ODM_ConfigRFWithHeaderFile(&pHalData->odmpriv, (enum ODM_RF_RADIO_PATH)eRFPath, (enum ODM_RF_RADIO_PATH)eRFPath))
+		if (HAL_STATUS_FAILURE == ODM_ConfigRFWithHeaderFile(&pHalData->odmpriv, (enum rf_radio_path)eRFPath, (enum rf_radio_path)eRFPath))
 				rtStatus = _FAIL;
 			break;
 		case RF_PATH_C:
diff --git a/drivers/staging/rtl8188eu/include/odm.h b/drivers/staging/rtl8188eu/include/odm.h
index cc5d0b2..8e9c92c 100644
--- a/drivers/staging/rtl8188eu/include/odm.h
+++ b/drivers/staging/rtl8188eu/include/odm.h
@@ -928,13 +928,6 @@ struct odm_dm_struct {
 
 #define ODM_RF_PATH_MAX 3
 
-enum ODM_RF_RADIO_PATH {
-	ODM_RF_PATH_A = 0,   /* Radio Path A */
-	ODM_RF_PATH_B = 1,   /* Radio Path B */
-	ODM_RF_PATH_C = 2,   /* Radio Path C */
-	ODM_RF_PATH_D = 3,   /* Radio Path D */
-};
-
 enum ODM_RF_CONTENT {
 	odm_radioa_txt = 0x1000,
 	odm_radiob_txt = 0x1001,
diff --git a/drivers/staging/rtl8188eu/include/odm_HWConfig.h b/drivers/staging/rtl8188eu/include/odm_HWConfig.h
index df52722..49e7e16 100644
--- a/drivers/staging/rtl8188eu/include/odm_HWConfig.h
+++ b/drivers/staging/rtl8188eu/include/odm_HWConfig.h
@@ -121,8 +121,8 @@ void ODM_MacStatusQuery(struct odm_dm_struct *pDM_Odm,
 			bool	bPacketBeacon);
 
 enum HAL_STATUS ODM_ConfigRFWithHeaderFile(struct odm_dm_struct *pDM_Odm,
-					   enum ODM_RF_RADIO_PATH Content,
-					   enum ODM_RF_RADIO_PATH eRFPath);
+					   enum rf_radio_path Content,
+					   enum rf_radio_path eRFPath);
 
 enum HAL_STATUS ODM_ConfigBBWithHeaderFile(struct odm_dm_struct *pDM_Odm,
 					   enum odm_bb_config_type ConfigType);
diff --git a/drivers/staging/rtl8188eu/include/odm_RegConfig8188E.h b/drivers/staging/rtl8188eu/include/odm_RegConfig8188E.h
index 727e6b2..f2bf7a0 100644
--- a/drivers/staging/rtl8188eu/include/odm_RegConfig8188E.h
+++ b/drivers/staging/rtl8188eu/include/odm_RegConfig8188E.h
@@ -21,7 +21,7 @@
 #define __INC_ODM_REGCONFIG_H_8188E
 
 void odm_ConfigRFReg_8188E(struct odm_dm_struct *pDM_Odm, u32 Addr, u32 Data,
-			   enum ODM_RF_RADIO_PATH  RF_PATH, u32 RegAddr);
+			   enum rf_radio_path  RF_PATH, u32 RegAddr);
 
 void odm_ConfigRF_RadioA_8188E(struct odm_dm_struct *pDM_Odm,
 			       u32 Addr, u32 Data);
-- 
1.8.4
