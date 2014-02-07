From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 01/12] staging: r8188eu: Remove ODM_Read1Byte
Date: Thu,  6 Feb 2014 20:45:36 -0600
Message-ID: <1391741147-3047-2-git-send-email-Larry.Finger@lwfinger.net>
References: <1391741147-3047-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: netdev@vger.kernel.org, devel@driverdev.osuosl.org,
	Larry Finger <Larry.Finger@lwfinger.net>
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f49.google.com ([209.85.219.49]:50795 "EHLO
	mail-oa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751056AbaBGCqO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Feb 2014 21:46:14 -0500
Received: by mail-oa0-f49.google.com with SMTP id i7so3473373oag.36
        for <netdev@vger.kernel.org>; Thu, 06 Feb 2014 18:46:13 -0800 (PST)
In-Reply-To: <1391741147-3047-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is essentially a synonym for rtw_read8.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/staging/rtl8188eu/hal/HalPhyRf_8188e.c    | 6 +++---
 drivers/staging/rtl8188eu/hal/odm_interface.c     | 6 ------
 drivers/staging/rtl8188eu/include/odm_interface.h | 2 --
 3 files changed, 3 insertions(+), 11 deletions(-)

diff --git a/drivers/staging/rtl8188eu/hal/HalPhyRf_8188e.c b/drivers/staging/rtl8188eu/hal/HalPhyRf_8188e.c
index 15e8e3f..6581a27 100644
--- a/drivers/staging/rtl8188eu/hal/HalPhyRf_8188e.c
+++ b/drivers/staging/rtl8188eu/hal/HalPhyRf_8188e.c
@@ -839,7 +839,7 @@ static void _PHY_SaveMACRegisters(
 	struct odm_dm_struct *dm_odm = &pHalData->odmpriv;
 	ODM_RT_TRACE(dm_odm, ODM_COMP_CALIBRATION, ODM_DBG_LOUD, ("Save MAC parameters.\n"));
 	for (i = 0; i < (IQK_MAC_REG_NUM - 1); i++) {
-		MACBackup[i] = ODM_Read1Byte(dm_odm, MACReg[i]);
+		MACBackup[i] = rtw_read8(adapt, MACReg[i]);
 	}
 	MACBackup[i] = ODM_Read4Byte(dm_odm, MACReg[i]);
 }
@@ -1227,7 +1227,7 @@ static void phy_LCCalibrate_8188E(struct adapter *adapt, bool is2t)
 	struct odm_dm_struct *dm_odm = &pHalData->odmpriv;
 
 	/* Check continuous TX and Packet TX */
-	tmpreg = ODM_Read1Byte(dm_odm, 0xd03);
+	tmpreg = rtw_read8(adapt, 0xd03);
 
 	if ((tmpreg&0x70) != 0)			/* Deal with contisuous TX case */
 		ODM_Write1Byte(dm_odm, 0xd03, tmpreg&0x8F);	/* disable all continuous TX */
@@ -1473,7 +1473,7 @@ static void phy_setrfpathswitch_8188e(struct adapter *adapt, bool main, bool is2
 
 	if (!adapt->hw_init_completed) {
 		u8 u1btmp;
-		u1btmp = ODM_Read1Byte(dm_odm, REG_LEDCFG2) | BIT7;
+		u1btmp = rtw_read8(adapt, REG_LEDCFG2) | BIT7;
 		ODM_Write1Byte(dm_odm, REG_LEDCFG2, u1btmp);
 		PHY_SetBBReg(adapt, rFPGA0_XAB_RFParameter, BIT13, 0x01);
 	}
diff --git a/drivers/staging/rtl8188eu/hal/odm_interface.c b/drivers/staging/rtl8188eu/hal/odm_interface.c
index 3cd6821..5b29067 100644
--- a/drivers/staging/rtl8188eu/hal/odm_interface.c
+++ b/drivers/staging/rtl8188eu/hal/odm_interface.c
@@ -21,12 +21,6 @@
 #include "odm_precomp.h"
 /*  ODM IO Relative API. */
 
-u8 ODM_Read1Byte(struct odm_dm_struct *pDM_Odm, u32 RegAddr)
-{
-	struct adapter *Adapter = pDM_Odm->Adapter;
-	return rtw_read8(Adapter, RegAddr);
-}
-
 u16 ODM_Read2Byte(struct odm_dm_struct *pDM_Odm, u32 RegAddr)
 {
 	struct adapter *Adapter = pDM_Odm->Adapter;
diff --git a/drivers/staging/rtl8188eu/include/odm_interface.h b/drivers/staging/rtl8188eu/include/odm_interface.h
index a50eae3..ba06101 100644
--- a/drivers/staging/rtl8188eu/include/odm_interface.h
+++ b/drivers/staging/rtl8188eu/include/odm_interface.h
@@ -77,8 +77,6 @@ typedef void (*RT_WORKITEM_CALL_BACK)(void *pContext);
 
 /*  =========== EXtern Function Prototype */
 
-u8 ODM_Read1Byte(struct odm_dm_struct *pDM_Odm, u32 RegAddr);
-
 u16 ODM_Read2Byte(struct odm_dm_struct *pDM_Odm, u32 RegAddr);
 
 u32 ODM_Read4Byte(struct odm_dm_struct *pDM_Odm, u32 RegAddr);
-- 
1.8.4.5
