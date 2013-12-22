From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 23/31] staging: r8188eu: Remove unneeded prototypes from include/odm.h
Date: Sun, 22 Dec 2013 17:36:54 -0600
Message-ID: <1387755422-11443-24-git-send-email-Larry.Finger@lwfinger.net>
References: <1387755422-11443-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: netdev@vger.kernel.org, devel@driverdev.osuosl.org,
	Larry Finger <Larry.Finger@lwfinger.net>
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f51.google.com ([209.85.160.51]:38297 "EHLO
	mail-pb0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756902Ab3LVXim (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Dec 2013 18:38:42 -0500
Received: by mail-pb0-f51.google.com with SMTP id up15so4668124pbc.38
        for <netdev@vger.kernel.org>; Sun, 22 Dec 2013 15:38:41 -0800 (PST)
In-Reply-To: <1387755422-11443-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This header contains a number of routines that do not to be available
globally. Once this change was made, a number of the routines were not
used, and could be removed.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/staging/rtl8188eu/hal/odm.c     | 67 ---------------------------------
 drivers/staging/rtl8188eu/include/odm.h | 49 ++++--------------------
 2 files changed, 8 insertions(+), 108 deletions(-)

diff --git a/drivers/staging/rtl8188eu/hal/odm.c b/drivers/staging/rtl8188eu/hal/odm.c
index 3ce881d..c73df3b 100644
--- a/drivers/staging/rtl8188eu/hal/odm.c
+++ b/drivers/staging/rtl8188eu/hal/odm.c
@@ -1348,17 +1348,6 @@ void odm_RSSIMonitorCheckCE(struct odm_dm_struct *pDM_Odm)
 	ODM_CmnInfoUpdate(&pHalData->odmpriv , ODM_CMNINFO_RSSI_MIN, pdmpriv->MinUndecoratedPWDBForDM);
 }
 
-void ODM_InitAllTimers(struct odm_dm_struct *pDM_Odm)
-{
-	ODM_InitializeTimer(pDM_Odm, &pDM_Odm->DM_SWAT_Table.SwAntennaSwitchTimer,
-			    (void *)odm_SwAntDivChkAntSwitchCallback, NULL, "SwAntennaSwitchTimer");
-}
-
-void ODM_CancelAllTimers(struct odm_dm_struct *pDM_Odm)
-{
-	ODM_CancelTimer(pDM_Odm, &pDM_Odm->DM_SWAT_Table.SwAntennaSwitchTimer);
-}
-
 /* 3============================================================ */
 /* 3 Tx Power Tracking */
 /* 3============================================================ */
@@ -1436,27 +1425,6 @@ void odm_InitHybridAntDiv(struct odm_dm_struct *pDM_Odm)
 	ODM_AntennaDiversityInit_88E(pDM_Odm);
 }
 
-void ODM_AntselStatistics_88C(struct odm_dm_struct *pDM_Odm, u8 MacId, u32 PWDBAll, bool isCCKrate)
-{
-	struct sw_ant_switch *pDM_SWAT_Table = &pDM_Odm->DM_SWAT_Table;
-
-	if (pDM_SWAT_Table->antsel == 1) {
-		if (isCCKrate) {
-			pDM_SWAT_Table->CCK_Ant1_Cnt[MacId]++;
-		} else {
-			pDM_SWAT_Table->OFDM_Ant1_Cnt[MacId]++;
-			pDM_SWAT_Table->RSSI_Ant1_Sum[MacId] += PWDBAll;
-		}
-	} else {
-		if (isCCKrate) {
-			pDM_SWAT_Table->CCK_Ant2_Cnt[MacId]++;
-		} else {
-			pDM_SWAT_Table->OFDM_Ant2_Cnt[MacId]++;
-			pDM_SWAT_Table->RSSI_Ant2_Sum[MacId] += PWDBAll;
-		}
-	}
-}
-
 void odm_HwAntDiv(struct odm_dm_struct *pDM_Odm)
 {
 	if (!(pDM_Odm->SupportAbility & ODM_BB_ANT_DIV)) {
@@ -1569,30 +1537,6 @@ dm_CheckEdcaTurbo_EXIT:
 	precvpriv->last_rx_bytes = precvpriv->rx_bytes;
 }
 
-/*  need to ODM CE Platform */
-/* move to here for ANT detection mechanism using */
-
-u32 GetPSDData(struct odm_dm_struct *pDM_Odm, unsigned int point, u8 initial_gain_psd)
-{
-	struct adapter *adapter = pDM_Odm->Adapter;
-	u32 psd_report;
-
-	/* Set DCO frequency index, offset=(40MHz/SamplePts)*point */
-	PHY_SetBBReg(adapter, 0x808, 0x3FF, point);
-
-	/* Start PSD calculation, Reg808[22]=0->1 */
-	PHY_SetBBReg(adapter, 0x808, BIT22, 1);
-	/* Need to wait for HW PSD report */
-	udelay(30);
-	PHY_SetBBReg(adapter, 0x808, BIT22, 0);
-	/* Read PSD report, Reg8B4[15:0] */
-	psd_report = PHY_QueryBBReg(adapter, 0x8B4, bMaskDWord) & 0x0000FFFF;
-
-	psd_report = (u32) (ConvertTo_dB(psd_report))+(u32)(initial_gain_psd-0x1c);
-
-	return psd_report;
-}
-
 u32 ConvertTo_dB(u32 Value)
 {
 	u8 i;
@@ -1617,14 +1561,3 @@ u32 ConvertTo_dB(u32 Value)
 
 	return dB;
 }
-
-/*  Description: */
-/* 	Set Single/Dual Antenna default setting for products that do not do detection in advance. */
-/*  Added by Joseph, 2012.03.22 */
-void ODM_SingleDualAntennaDefaultSetting(struct odm_dm_struct *pDM_Odm)
-{
-	struct sw_ant_switch *pDM_SWAT_Table = &pDM_Odm->DM_SWAT_Table;
-
-	pDM_SWAT_Table->ANTA_ON = true;
-	pDM_SWAT_Table->ANTB_ON = true;
-}
diff --git a/drivers/staging/rtl8188eu/include/odm.h b/drivers/staging/rtl8188eu/include/odm.h
index db1d593..8e15847 100644
--- a/drivers/staging/rtl8188eu/include/odm.h
+++ b/drivers/staging/rtl8188eu/include/odm.h
@@ -1128,61 +1128,28 @@ extern	u8 CCKSwingTable_Ch14 [CCK_TABLE_SIZE][8];
 #define SWAW_STEP_PEAK		0
 #define SWAW_STEP_DETERMINE	1
 
-void ODM_Write_DIG(struct odm_dm_struct *pDM_Odm, u8 CurrentIGI);
-void ODM_Write_CCK_CCA_Thres(struct odm_dm_struct *pDM_Odm, u8 CurCCK_CCAThres);
-
-void ODM_SetAntenna(struct odm_dm_struct *pDM_Odm, u8 Antenna);
-
-
+#define dm_CheckTXPowerTracking ODM_TXPowerTrackingCheck
 #define dm_RF_Saving	ODM_RF_Saving
-void ODM_RF_Saving(struct odm_dm_struct *pDM_Odm, u8 bForceInNormal);
-
-#define SwAntDivRestAfterLink	ODM_SwAntDivRestAfterLink
-void ODM_SwAntDivRestAfterLink(struct odm_dm_struct *pDM_Odm);
 
-#define dm_CheckTXPowerTracking ODM_TXPowerTrackingCheck
+void ODM_RF_Saving(struct odm_dm_struct *pDM_Odm, u8 bForceInNormal);
 void ODM_TXPowerTrackingCheck(struct odm_dm_struct *pDM_Odm);
-
+void odm_DIGbyRSSI_LPS(struct odm_dm_struct *pDM_Odm);
+void ODM_Write_CCK_CCA_Thres(struct odm_dm_struct *pDM_Odm, u8 CurCCK_CCAThres);
 bool ODM_RAStateCheck(struct odm_dm_struct *pDM_Odm, s32 RSSI,
 		      bool bForceUpdate, u8 *pRATRState);
-
 u32 ConvertTo_dB(u32 Value);
-
-u32 GetPSDData(struct odm_dm_struct *pDM_Odm, unsigned int point,
-	       u8 initial_gain_psd);
-
-void odm_DIGbyRSSI_LPS(struct odm_dm_struct *pDM_Odm);
-
 u32 ODM_Get_Rate_Bitmap(struct odm_dm_struct *pDM_Odm, u32 macid,
 			u32 ra_mask, u8 rssi_level);
-
-void ODM_DMInit(struct odm_dm_struct *pDM_Odm);
-
-void ODM_DMWatchdog(struct odm_dm_struct *pDM_Odm);
-
 void ODM_CmnInfoInit(struct odm_dm_struct *pDM_Odm,
 		     enum odm_common_info_def CmnInfo, u32 Value);
-
+void ODM_CmnInfoUpdate(struct odm_dm_struct *pDM_Odm, u32 CmnInfo, u64 Value);
 void ODM_CmnInfoHook(struct odm_dm_struct *pDM_Odm,
 		     enum odm_common_info_def CmnInfo, void *pValue);
-
 void ODM_CmnInfoPtrArrayHook(struct odm_dm_struct *pDM_Odm,
 			     enum odm_common_info_def CmnInfo,
 			     u16 Index, void *pValue);
-
-void ODM_CmnInfoUpdate(struct odm_dm_struct *pDM_Odm, u32 CmnInfo, u64 Value);
-
-void ODM_InitAllTimers(struct odm_dm_struct *pDM_Odm);
-
-void ODM_CancelAllTimers(struct odm_dm_struct *pDM_Odm);
-
-void ODM_ResetIQKResult(struct odm_dm_struct *pDM_Odm);
-
-void ODM_AntselStatistics_88C(struct odm_dm_struct *pDM_Odm, u8 MacId,
-			      u32 PWDBAll, bool isCCKrate);
-
-void ODM_SingleDualAntennaDefaultSetting(struct odm_dm_struct *pDM_Odm);
-
-void odm_dtc(struct odm_dm_struct *pDM_Odm);
+void ODM_DMInit(struct odm_dm_struct *pDM_Odm);
+void ODM_DMWatchdog(struct odm_dm_struct *pDM_Odm);
+void ODM_Write_DIG(struct odm_dm_struct *pDM_Odm, u8 CurrentIGI);
 
 #endif
-- 
1.8.4
