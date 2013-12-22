From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 20/31] staging: r8188eu: Remove even more empty routines
Date: Sun, 22 Dec 2013 17:36:51 -0600
Message-ID: <1387755422-11443-21-git-send-email-Larry.Finger@lwfinger.net>
References: <1387755422-11443-1-git-send-email-Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, netdev@vger.kernel.org,
 Larry Finger <Larry.Finger@lwfinger.net>
To: gregkh@linuxfoundation.org
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1387755422-11443-1-git-send-email-Larry.Finger@lwfinger.net>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: driverdev-devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

This patch removes the following:

odm_DynamicTxPowerAP
odm_RSSIMonitorCheckMP
odm_RSSIMonitorCheckAP
odm_TXPowerTrackingCheckMP
odm_TXPowerTrackingCheckAP
odm_SwAntDivInit
ODM_SwAntDivChkPerPktRssi
odm_SwAntDivChkAntSwitch
ODM_SwAntDivRestAfterLink
dm_GlobalAdapterCheck
odm_dtc

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/staging/rtl8188eu/hal/odm.c             | 56 -------------------------
 drivers/staging/rtl8188eu/hal/odm_HWConfig.c    |  4 +-
 drivers/staging/rtl8188eu/include/odm.h         |  4 --
 drivers/staging/rtl8188eu/include/odm_precomp.h |  7 ----
 4 files changed, 1 insertion(+), 70 deletions(-)

diff --git a/drivers/staging/rtl8188eu/hal/odm.c b/drivers/staging/rtl8188eu/hal/odm.c
index 683f2bc..f73f3af 100644
--- a/drivers/staging/rtl8188eu/hal/odm.c
+++ b/drivers/staging/rtl8188eu/hal/odm.c
@@ -195,8 +195,6 @@ void ODM_DMInit(struct odm_dm_struct *pDM_Odm)
 		    (pDM_Odm->AntDivType == CGCS_RX_HW_ANTDIV) ||
 		    (pDM_Odm->AntDivType == CG_TRX_SMART_ANTDIV))
 			odm_InitHybridAntDiv(pDM_Odm);
-		else if (pDM_Odm->AntDivType == CGCS_RX_SW_ANTDIV)
-			odm_SwAntDivInit(pDM_Odm);
 	}
 }
 
@@ -206,7 +204,6 @@ void ODM_DMInit(struct odm_dm_struct *pDM_Odm)
 void ODM_DMWatchdog(struct odm_dm_struct *pDM_Odm)
 {
 	/* 2012.05.03 Luke: For all IC series */
-	odm_GlobalAdapterCheck();
 	odm_CmnInfoHook_Debug(pDM_Odm);
 	odm_CmnInfoUpdate_Debug(pDM_Odm);
 	odm_CommonInfoSelfUpdate(pDM_Odm);
@@ -240,8 +237,6 @@ void ODM_DMWatchdog(struct odm_dm_struct *pDM_Odm)
 	    (pDM_Odm->AntDivType == CGCS_RX_HW_ANTDIV)	||
 	    (pDM_Odm->AntDivType == CG_TRX_SMART_ANTDIV))
 		odm_HwAntDiv(pDM_Odm);
-	else if (pDM_Odm->AntDivType == CGCS_RX_SW_ANTDIV)
-		odm_SwAntDivChkAntSwitch(pDM_Odm, SWAW_STEP_PEAK);
 
 	if (pDM_Odm->SupportICType & ODM_IC_11AC_SERIES) {
 		;
@@ -250,7 +245,6 @@ void ODM_DMWatchdog(struct odm_dm_struct *pDM_Odm)
 	      odm_EdcaTurboCheck(pDM_Odm);
 		odm_DynamicTxPower(pDM_Odm);
 	}
-	odm_dtc(pDM_Odm);
 }
 
 /*  Init /.. Fixed HW value. Only init time. */
@@ -1453,7 +1447,6 @@ void odm_DynamicTxPower(struct odm_dm_struct *pDM_Odm)
 		odm_DynamicTxPowerNIC(pDM_Odm);
 		break;
 	case	ODM_AP:
-		odm_DynamicTxPowerAP(pDM_Odm);
 		break;
 	case	ODM_ADSL:
 		break;
@@ -1471,10 +1464,6 @@ void odm_DynamicTxPowerNIC(struct odm_dm_struct *pDM_Odm)
 	}
 }
 
-void odm_DynamicTxPowerAP(struct odm_dm_struct *pDM_Odm)
-{
-}
-
 /* 3============================================================ */
 /* 3 RSSI Monitor */
 /* 3============================================================ */
@@ -1491,13 +1480,11 @@ void odm_RSSIMonitorCheck(struct odm_dm_struct *pDM_Odm)
 	/*  */
 	switch	(pDM_Odm->SupportPlatform) {
 	case	ODM_MP:
-		odm_RSSIMonitorCheckMP(pDM_Odm);
 		break;
 	case	ODM_CE:
 		odm_RSSIMonitorCheckCE(pDM_Odm);
 		break;
 	case	ODM_AP:
-		odm_RSSIMonitorCheckAP(pDM_Odm);
 		break;
 	case	ODM_ADSL:
 		/* odm_DIGAP(pDM_Odm); */
@@ -1506,10 +1493,6 @@ void odm_RSSIMonitorCheck(struct odm_dm_struct *pDM_Odm)
 
 }	/*  odm_RSSIMonitorCheck */
 
-void odm_RSSIMonitorCheckMP(struct odm_dm_struct *pDM_Odm)
-{
-}
-
 static void FindMinimumRSSI(struct adapter *pAdapter)
 {
 	struct hal_data_8188e	*pHalData = GET_HAL_DATA(pAdapter);
@@ -1582,10 +1565,6 @@ void odm_RSSIMonitorCheckCE(struct odm_dm_struct *pDM_Odm)
 	ODM_CmnInfoUpdate(&pHalData->odmpriv , ODM_CMNINFO_RSSI_MIN, pdmpriv->MinUndecoratedPWDBForDM);
 }
 
-void odm_RSSIMonitorCheckAP(struct odm_dm_struct *pDM_Odm)
-{
-}
-
 void ODM_InitAllTimers(struct odm_dm_struct *pDM_Odm)
 {
 	ODM_InitializeTimer(pDM_Odm, &pDM_Odm->DM_SWAT_Table.SwAntennaSwitchTimer,
@@ -1625,13 +1604,11 @@ void ODM_TXPowerTrackingCheck(struct odm_dm_struct *pDM_Odm)
 	/*  HW dynamic mechanism. */
 	switch	(pDM_Odm->SupportPlatform) {
 	case	ODM_MP:
-		odm_TXPowerTrackingCheckMP(pDM_Odm);
 		break;
 	case	ODM_CE:
 		odm_TXPowerTrackingCheckCE(pDM_Odm);
 		break;
 	case	ODM_AP:
-		odm_TXPowerTrackingCheckAP(pDM_Odm);
 		break;
 	case	ODM_ADSL:
 		break;
@@ -1656,14 +1633,6 @@ void odm_TXPowerTrackingCheckCE(struct odm_dm_struct *pDM_Odm)
 	}
 }
 
-void odm_TXPowerTrackingCheckMP(struct odm_dm_struct *pDM_Odm)
-{
-}
-
-void odm_TXPowerTrackingCheckAP(struct odm_dm_struct *pDM_Odm)
-{
-}
-
 /* antenna mapping info */
 /*  1: right-side antenna */
 /*  2/0: left-side antenna */
@@ -1675,21 +1644,6 @@ void odm_TXPowerTrackingCheckAP(struct odm_dm_struct *pDM_Odm)
 /* 3============================================================ */
 /* 3 SW Antenna Diversity */
 /* 3============================================================ */
-void odm_SwAntDivInit(struct odm_dm_struct *pDM_Odm)
-{
-}
-
-void ODM_SwAntDivChkPerPktRssi(struct odm_dm_struct *pDM_Odm, u8 StationID, struct odm_phy_status_info *pPhyInfo)
-{
-}
-
-void odm_SwAntDivChkAntSwitch(struct odm_dm_struct *pDM_Odm, u8 Step)
-{
-}
-
-void ODM_SwAntDivRestAfterLink(struct odm_dm_struct *pDM_Odm)
-{
-}
 
 void odm_SwAntDivChkAntSwitchCallback(void *FunctionContext)
 {
@@ -1904,11 +1858,6 @@ u32 ConvertTo_dB(u32 Value)
 	return dB;
 }
 
-/*  2011/09/22 MH Add for 92D global spin lock utilization. */
-void odm_GlobalAdapterCheck(void)
-{
-}	/*  odm_GlobalAdapterCheck */
-
 /*  Description: */
 /* 	Set Single/Dual Antenna default setting for products that do not do detection in advance. */
 /*  Added by Joseph, 2012.03.22 */
@@ -2168,8 +2117,3 @@ bool ODM_SingleDualAntennaDetection(struct odm_dm_struct *pDM_Odm, u8 mode)
 	}
 	return bResult;
 }
-
-/* Justin: According to the current RRSI to adjust Response Frame TX power, 2012/11/05 */
-void odm_dtc(struct odm_dm_struct *pDM_Odm)
-{
-}
diff --git a/drivers/staging/rtl8188eu/hal/odm_HWConfig.c b/drivers/staging/rtl8188eu/hal/odm_HWConfig.c
index 19c509a..286d262 100644
--- a/drivers/staging/rtl8188eu/hal/odm_HWConfig.c
+++ b/drivers/staging/rtl8188eu/hal/odm_HWConfig.c
@@ -531,9 +531,7 @@ static void ODM_PhyStatusQuery_92CSeries(struct odm_dm_struct *dm_odm,
 	odm_RxPhyStatus92CSeries_Parsing(dm_odm, pPhyInfo, pPhyStatus,
 					 pPktinfo);
 	if (dm_odm->RSSI_test) {
-		/*  Select the packets to do RSSI checking for antenna switching. */
-		if (pPktinfo->bPacketToSelf || pPktinfo->bPacketBeacon)
-				ODM_SwAntDivChkPerPktRssi(dm_odm, pPktinfo->StationID, pPhyInfo);
+		;/*  Select the packets to do RSSI checking for antenna switching. */
 	} else {
 		odm_Process_RSSIForDM(dm_odm, pPhyInfo, pPktinfo);
 	}
diff --git a/drivers/staging/rtl8188eu/include/odm.h b/drivers/staging/rtl8188eu/include/odm.h
index 8934de9..f3d2773 100644
--- a/drivers/staging/rtl8188eu/include/odm.h
+++ b/drivers/staging/rtl8188eu/include/odm.h
@@ -1146,10 +1146,6 @@ void ODM_TXPowerTrackingCheck(struct odm_dm_struct *pDM_Odm);
 bool ODM_RAStateCheck(struct odm_dm_struct *pDM_Odm, s32 RSSI,
 		      bool bForceUpdate, u8 *pRATRState);
 
-#define dm_SWAW_RSSI_Check	ODM_SwAntDivChkPerPktRssi
-void ODM_SwAntDivChkPerPktRssi(struct odm_dm_struct *pDM_Odm, u8 StationID,
-			       struct odm_phy_status_info *pPhyInfo);
-
 u32 ConvertTo_dB(u32 Value);
 
 u32 GetPSDData(struct odm_dm_struct *pDM_Odm, unsigned int point,
diff --git a/drivers/staging/rtl8188eu/include/odm_precomp.h b/drivers/staging/rtl8188eu/include/odm_precomp.h
index d1d95f4..6e6a656 100644
--- a/drivers/staging/rtl8188eu/include/odm_precomp.h
+++ b/drivers/staging/rtl8188eu/include/odm_precomp.h
@@ -64,7 +64,6 @@ void odm_DynamicTxPowerInit(struct odm_dm_struct *pDM_Odm);
 void odm_TXPowerTrackingInit(struct odm_dm_struct *pDM_Odm);
 void ODM_EdcaTurboInit(struct odm_dm_struct *pDM_Odm);
 void odm_SwAntDivInit_NIC(struct odm_dm_struct *pDM_Odm);
-void odm_GlobalAdapterCheck(void);
 void odm_CmnInfoUpdate_Debug(struct odm_dm_struct *pDM_Odm);
 void odm_CommonInfoSelfUpdate(struct odm_dm_struct *pDM_Odm);
 void odm_FalseAlarmCounterStatistics(struct odm_dm_struct *pDM_Odm);
@@ -76,22 +75,16 @@ void odm_SwAntDivChkAntSwitch(struct odm_dm_struct *pDM_Odm, u8 Step);
 void odm_EdcaTurboCheck(struct odm_dm_struct *pDM_Odm);
 void odm_DynamicTxPower(struct odm_dm_struct *pDM_Odm);
 void odm_CommonInfoSelfInit(struct odm_dm_struct *pDM_Odm);
-void odm_SwAntDivInit(struct odm_dm_struct *pDM_Odm);
 void odm_RSSIMonitorCheck(struct odm_dm_struct *pDM_Odm);
 void odm_RefreshRateAdaptiveMask(struct odm_dm_struct *pDM_Odm);
 void odm_1R_CCA(struct odm_dm_struct *pDM_Odm);
 void odm_RefreshRateAdaptiveMaskCE(struct odm_dm_struct *pDM_Odm);
 void odm_RefreshRateAdaptiveMaskAPADSL(struct odm_dm_struct *pDM_Odm);
 void odm_DynamicTxPowerNIC(struct odm_dm_struct *pDM_Odm);
-void odm_DynamicTxPowerAP(struct odm_dm_struct *pDM_Odm);
-void odm_RSSIMonitorCheckMP(struct odm_dm_struct *pDM_Odm);
 void odm_RSSIMonitorCheckCE(struct odm_dm_struct *pDM_Odm);
-void odm_RSSIMonitorCheckAP(struct odm_dm_struct *pDM_Odm);
 void odm_TXPowerTrackingThermalMeterInit(struct odm_dm_struct *pDM_Odm);
 void odm_EdcaTurboCheckCE(struct odm_dm_struct *pDM_Odm);
 void odm_TXPowerTrackingCheckCE(struct odm_dm_struct *pDM_Odm);
-void odm_TXPowerTrackingCheckMP(struct odm_dm_struct *pDM_Odm);
-void odm_TXPowerTrackingCheckAP(struct odm_dm_struct *pDM_Odm);
 void odm_SwAntDivChkAntSwitchCallback(void *FunctionContext);
 void odm_InitHybridAntDiv(struct odm_dm_struct *pDM_Odm);
 void odm_HwAntDiv(struct odm_dm_struct *pDM_Odm);
-- 
1.8.4
