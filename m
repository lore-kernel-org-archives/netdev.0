From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 04/12] staging: r8188eu: Remove ODM_Write1Byte
Date: Thu,  6 Feb 2014 20:45:39 -0600
Message-ID: <1391741147-3047-5-git-send-email-Larry.Finger@lwfinger.net>
References: <1391741147-3047-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: netdev@vger.kernel.org, devel@driverdev.osuosl.org,
	Larry Finger <Larry.Finger@lwfinger.net>
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:52662 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751529AbaBGCqo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Feb 2014 21:46:44 -0500
Received: by mail-ob0-f174.google.com with SMTP id uy5so3308258obc.5
        for <netdev@vger.kernel.org>; Thu, 06 Feb 2014 18:46:44 -0800 (PST)
In-Reply-To: <1391741147-3047-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This routine is the equivalent of rtl_write6.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/staging/rtl8188eu/hal/HalPhyRf_8188e.c     | 23 +++++++++-------------
 drivers/staging/rtl8188eu/hal/odm.c                |  3 ++-
 drivers/staging/rtl8188eu/hal/odm_RegConfig8188E.c |  4 +++-
 drivers/staging/rtl8188eu/hal/odm_interface.c      |  6 ------
 drivers/staging/rtl8188eu/include/odm_interface.h  |  2 --
 5 files changed, 14 insertions(+), 24 deletions(-)

diff --git a/drivers/staging/rtl8188eu/hal/HalPhyRf_8188e.c b/drivers/staging/rtl8188eu/hal/HalPhyRf_8188e.c
index 9f907f8..bb80b8a 100644
--- a/drivers/staging/rtl8188eu/hal/HalPhyRf_8188e.c
+++ b/drivers/staging/rtl8188eu/hal/HalPhyRf_8188e.c
@@ -868,7 +868,7 @@ _PHY_ReloadMACRegisters(
 
 	ODM_RT_TRACE(dm_odm, ODM_COMP_CALIBRATION, ODM_DBG_LOUD,  ("Reload MAC parameters !\n"));
 	for (i = 0; i < (IQK_MAC_REG_NUM - 1); i++) {
-		ODM_Write1Byte(dm_odm, MACReg[i], (u8)MACBackup[i]);
+		rtw_write8(adapt, MACReg[i], (u8)MACBackup[i]);
 	}
 	ODM_Write4Byte(dm_odm, MACReg[i], MACBackup[i]);
 }
@@ -912,12 +912,12 @@ _PHY_MACSettingCalibration(
 
 	ODM_RT_TRACE(dm_odm, ODM_COMP_CALIBRATION, ODM_DBG_LOUD, ("MAC settings for Calibration.\n"));
 
-	ODM_Write1Byte(dm_odm, MACReg[i], 0x3F);
+	rtw_write8(adapt, MACReg[i], 0x3F);
 
 	for (i = 1; i < (IQK_MAC_REG_NUM - 1); i++) {
-		ODM_Write1Byte(dm_odm, MACReg[i], (u8)(MACBackup[i]&(~BIT3)));
+		rtw_write8(adapt, MACReg[i], (u8)(MACBackup[i]&(~BIT3)));
 	}
-	ODM_Write1Byte(dm_odm, MACReg[i], (u8)(MACBackup[i]&(~BIT5)));
+	rtw_write8(adapt, MACReg[i], (u8)(MACBackup[i]&(~BIT5)));
 }
 
 void
@@ -1223,16 +1223,14 @@ static void phy_LCCalibrate_8188E(struct adapter *adapt, bool is2t)
 {
 	u8 tmpreg;
 	u32 RF_Amode = 0, RF_Bmode = 0, LC_Cal;
-	struct hal_data_8188e	*pHalData = GET_HAL_DATA(adapt);
-	struct odm_dm_struct *dm_odm = &pHalData->odmpriv;
 
 	/* Check continuous TX and Packet TX */
 	tmpreg = rtw_read8(adapt, 0xd03);
 
 	if ((tmpreg&0x70) != 0)			/* Deal with contisuous TX case */
-		ODM_Write1Byte(dm_odm, 0xd03, tmpreg&0x8F);	/* disable all continuous TX */
+		rtw_write8(adapt, 0xd03, tmpreg&0x8F);	/* disable all continuous TX */
 	else							/*  Deal with Packet TX case */
-		ODM_Write1Byte(dm_odm, REG_TXPAUSE, 0xFF);			/*  block all queues */
+		rtw_write8(adapt, REG_TXPAUSE, 0xFF);			/*  block all queues */
 
 	if ((tmpreg&0x70) != 0) {
 		/* 1. Read original RF mode */
@@ -1264,7 +1262,7 @@ static void phy_LCCalibrate_8188E(struct adapter *adapt, bool is2t)
 	if ((tmpreg&0x70) != 0) {
 		/* Deal with continuous TX case */
 		/* Path-A */
-		ODM_Write1Byte(dm_odm, 0xd03, tmpreg);
+		rtw_write8(adapt, 0xd03, tmpreg);
 		PHY_SetRFReg(adapt, RF_PATH_A, RF_AC, bMask12Bits, RF_Amode);
 
 		/* Path-B */
@@ -1272,7 +1270,7 @@ static void phy_LCCalibrate_8188E(struct adapter *adapt, bool is2t)
 			PHY_SetRFReg(adapt, RF_PATH_B, RF_AC, bMask12Bits, RF_Bmode);
 	} else {
 		/*  Deal with Packet TX case */
-		ODM_Write1Byte(dm_odm, REG_TXPAUSE, 0x00);
+		rtw_write8(adapt, REG_TXPAUSE, 0x00);
 	}
 }
 
@@ -1468,13 +1466,10 @@ void PHY_LCCalibrate_8188E(struct adapter *adapt)
 
 static void phy_setrfpathswitch_8188e(struct adapter *adapt, bool main, bool is2t)
 {
-	struct hal_data_8188e	*pHalData = GET_HAL_DATA(adapt);
-	struct odm_dm_struct *dm_odm = &pHalData->odmpriv;
-
 	if (!adapt->hw_init_completed) {
 		u8 u1btmp;
 		u1btmp = rtw_read8(adapt, REG_LEDCFG2) | BIT7;
-		ODM_Write1Byte(dm_odm, REG_LEDCFG2, u1btmp);
+		rtw_write8(adapt, REG_LEDCFG2, u1btmp);
 		PHY_SetBBReg(adapt, rFPGA0_XAB_RFParameter, BIT13, 0x01);
 	}
 
diff --git a/drivers/staging/rtl8188eu/hal/odm.c b/drivers/staging/rtl8188eu/hal/odm.c
index 5d41ef9..fc05e48 100644
--- a/drivers/staging/rtl8188eu/hal/odm.c
+++ b/drivers/staging/rtl8188eu/hal/odm.c
@@ -887,9 +887,10 @@ void odm_CCKPacketDetectionThresh(struct odm_dm_struct *pDM_Odm)
 void ODM_Write_CCK_CCA_Thres(struct odm_dm_struct *pDM_Odm, u8 CurCCK_CCAThres)
 {
 	struct rtw_dig *pDM_DigTable = &pDM_Odm->DM_DigTable;
+	struct adapter *adapt = pDM_Odm->Adapter;
 
 	if (pDM_DigTable->CurCCK_CCAThres != CurCCK_CCAThres)		/* modify by Guo.Mingzhi 2012-01-03 */
-		ODM_Write1Byte(pDM_Odm, ODM_REG(CCK_CCA, pDM_Odm), CurCCK_CCAThres);
+		rtw_write8(adapt, ODM_REG(CCK_CCA, pDM_Odm), CurCCK_CCAThres);
 	pDM_DigTable->PreCCK_CCAThres = pDM_DigTable->CurCCK_CCAThres;
 	pDM_DigTable->CurCCK_CCAThres = CurCCK_CCAThres;
 }
diff --git a/drivers/staging/rtl8188eu/hal/odm_RegConfig8188E.c b/drivers/staging/rtl8188eu/hal/odm_RegConfig8188E.c
index 6193d9f..a988612 100644
--- a/drivers/staging/rtl8188eu/hal/odm_RegConfig8188E.c
+++ b/drivers/staging/rtl8188eu/hal/odm_RegConfig8188E.c
@@ -66,7 +66,9 @@ void odm_ConfigRF_RadioB_8188E(struct odm_dm_struct *pDM_Odm, u32 Addr, u32 Data
 
 void odm_ConfigMAC_8188E(struct odm_dm_struct *pDM_Odm, u32 Addr, u8 Data)
 {
-	ODM_Write1Byte(pDM_Odm, Addr, Data);
+	struct adapter *adapt = pDM_Odm->Adapter;
+
+	rtw_write8(adapt, Addr, Data);
 	ODM_RT_TRACE(pDM_Odm, ODM_COMP_INIT, ODM_DBG_TRACE, ("===> ODM_ConfigMACWithHeaderFile: [MAC_REG] %08X %08X\n", Addr, Data));
 }
 
diff --git a/drivers/staging/rtl8188eu/hal/odm_interface.c b/drivers/staging/rtl8188eu/hal/odm_interface.c
index ae4f30c..76c54dc 100644
--- a/drivers/staging/rtl8188eu/hal/odm_interface.c
+++ b/drivers/staging/rtl8188eu/hal/odm_interface.c
@@ -21,12 +21,6 @@
 #include "odm_precomp.h"
 /*  ODM IO Relative API. */
 
-void ODM_Write1Byte(struct odm_dm_struct *pDM_Odm, u32 RegAddr, u8 Data)
-{
-	struct adapter *Adapter = pDM_Odm->Adapter;
-	rtw_write8(Adapter, RegAddr, Data);
-}
-
 void ODM_Write2Byte(struct odm_dm_struct *pDM_Odm, u32 RegAddr, u16 Data)
 {
 	struct adapter *Adapter = pDM_Odm->Adapter;
diff --git a/drivers/staging/rtl8188eu/include/odm_interface.h b/drivers/staging/rtl8188eu/include/odm_interface.h
index adcdc39..a11dec1 100644
--- a/drivers/staging/rtl8188eu/include/odm_interface.h
+++ b/drivers/staging/rtl8188eu/include/odm_interface.h
@@ -77,8 +77,6 @@ typedef void (*RT_WORKITEM_CALL_BACK)(void *pContext);
 
 /*  =========== EXtern Function Prototype */
 
-void ODM_Write1Byte(struct odm_dm_struct *pDM_Odm, u32 RegAddr, u8 Data);
-
 void ODM_Write2Byte(struct odm_dm_struct *pDM_Odm, u32 RegAddr, u16 Data);
 
 void ODM_Write4Byte(struct odm_dm_struct *pDM_Odm, u32 RegAddr, u32 Data);
-- 
1.8.4.5
