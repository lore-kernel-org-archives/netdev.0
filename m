From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 03/12] staging: r8188eu: Remove ODM_Read4Byte
Date: Thu,  6 Feb 2014 20:45:38 -0600
Message-ID: <1391741147-3047-4-git-send-email-Larry.Finger@lwfinger.net>
References: <1391741147-3047-1-git-send-email-Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, netdev@vger.kernel.org,
 Larry Finger <Larry.Finger@lwfinger.net>
To: gregkh@linuxfoundation.org
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1391741147-3047-1-git-send-email-Larry.Finger@lwfinger.net>
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

This routine is essentially a duplicate of rtw_read32.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/staging/rtl8188eu/hal/Hal8188ERateAdaptive.c | 9 +++++----
 drivers/staging/rtl8188eu/hal/HalPhyRf_8188e.c       | 2 +-
 drivers/staging/rtl8188eu/hal/odm.c                  | 8 ++++----
 drivers/staging/rtl8188eu/hal/odm_interface.c        | 6 ------
 drivers/staging/rtl8188eu/include/odm_interface.h    | 2 --
 5 files changed, 10 insertions(+), 17 deletions(-)

diff --git a/drivers/staging/rtl8188eu/hal/Hal8188ERateAdaptive.c b/drivers/staging/rtl8188eu/hal/Hal8188ERateAdaptive.c
index 3df33bc..908a2c0 100644
--- a/drivers/staging/rtl8188eu/hal/Hal8188ERateAdaptive.c
+++ b/drivers/staging/rtl8188eu/hal/Hal8188ERateAdaptive.c
@@ -331,6 +331,7 @@ static void odm_RateDecision_8188E(struct odm_dm_struct *dm_odm,
 
 static int odm_ARFBRefresh_8188E(struct odm_dm_struct *dm_odm, struct odm_ra_info *pRaInfo)
 {  /*  Wilson 2011/10/26 */
+	struct adapter *adapt = dm_odm->Adapter;
 	u32 MaskFromReg;
 	s8 i;
 
@@ -357,19 +358,19 @@ static int odm_ARFBRefresh_8188E(struct odm_dm_struct *dm_odm, struct odm_ra_inf
 		pRaInfo->RAUseRate = (pRaInfo->RateMask)&0x0000000d;
 		break;
 	case 12:
-		MaskFromReg = ODM_Read4Byte(dm_odm, REG_ARFR0);
+		MaskFromReg = rtw_read32(adapt, REG_ARFR0);
 		pRaInfo->RAUseRate = (pRaInfo->RateMask)&MaskFromReg;
 		break;
 	case 13:
-		MaskFromReg = ODM_Read4Byte(dm_odm, REG_ARFR1);
+		MaskFromReg = rtw_read32(adapt, REG_ARFR1);
 		pRaInfo->RAUseRate = (pRaInfo->RateMask)&MaskFromReg;
 		break;
 	case 14:
-		MaskFromReg = ODM_Read4Byte(dm_odm, REG_ARFR2);
+		MaskFromReg = rtw_read32(adapt, REG_ARFR2);
 		pRaInfo->RAUseRate = (pRaInfo->RateMask)&MaskFromReg;
 		break;
 	case 15:
-		MaskFromReg = ODM_Read4Byte(dm_odm, REG_ARFR3);
+		MaskFromReg = rtw_read32(adapt, REG_ARFR3);
 		pRaInfo->RAUseRate = (pRaInfo->RateMask)&MaskFromReg;
 		break;
 	default:
diff --git a/drivers/staging/rtl8188eu/hal/HalPhyRf_8188e.c b/drivers/staging/rtl8188eu/hal/HalPhyRf_8188e.c
index 6581a27..9f907f8 100644
--- a/drivers/staging/rtl8188eu/hal/HalPhyRf_8188e.c
+++ b/drivers/staging/rtl8188eu/hal/HalPhyRf_8188e.c
@@ -841,7 +841,7 @@ static void _PHY_SaveMACRegisters(
 	for (i = 0; i < (IQK_MAC_REG_NUM - 1); i++) {
 		MACBackup[i] = rtw_read8(adapt, MACReg[i]);
 	}
-	MACBackup[i] = ODM_Read4Byte(dm_odm, MACReg[i]);
+	MACBackup[i] = rtw_read32(adapt, MACReg[i]);
 }
 
 static void reload_adda_reg(struct adapter *adapt, u32 *ADDAReg, u32 *ADDABackup, u32 RegiesterNum)
diff --git a/drivers/staging/rtl8188eu/hal/odm.c b/drivers/staging/rtl8188eu/hal/odm.c
index 3555ffa..5d41ef9 100644
--- a/drivers/staging/rtl8188eu/hal/odm.c
+++ b/drivers/staging/rtl8188eu/hal/odm.c
@@ -1433,10 +1433,10 @@ void ODM_EdcaTurboInit(struct odm_dm_struct *pDM_Odm)
 	pDM_Odm->DM_EDCA_Table.bIsCurRDLState = false;
 	Adapter->recvpriv.bIsAnyNonBEPkts = false;
 
-	ODM_RT_TRACE(pDM_Odm, ODM_COMP_EDCA_TURBO, ODM_DBG_LOUD, ("Orginial VO PARAM: 0x%x\n", ODM_Read4Byte(pDM_Odm, ODM_EDCA_VO_PARAM)));
-	ODM_RT_TRACE(pDM_Odm, ODM_COMP_EDCA_TURBO, ODM_DBG_LOUD, ("Orginial VI PARAM: 0x%x\n", ODM_Read4Byte(pDM_Odm, ODM_EDCA_VI_PARAM)));
-	ODM_RT_TRACE(pDM_Odm, ODM_COMP_EDCA_TURBO, ODM_DBG_LOUD, ("Orginial BE PARAM: 0x%x\n", ODM_Read4Byte(pDM_Odm, ODM_EDCA_BE_PARAM)));
-	ODM_RT_TRACE(pDM_Odm, ODM_COMP_EDCA_TURBO, ODM_DBG_LOUD, ("Orginial BK PARAM: 0x%x\n", ODM_Read4Byte(pDM_Odm, ODM_EDCA_BK_PARAM)));
+	ODM_RT_TRACE(pDM_Odm, ODM_COMP_EDCA_TURBO, ODM_DBG_LOUD, ("Orginial VO PARAM: 0x%x\n", rtw_read32(Adapter, ODM_EDCA_VO_PARAM)));
+	ODM_RT_TRACE(pDM_Odm, ODM_COMP_EDCA_TURBO, ODM_DBG_LOUD, ("Orginial VI PARAM: 0x%x\n", rtw_read32(Adapter, ODM_EDCA_VI_PARAM)));
+	ODM_RT_TRACE(pDM_Odm, ODM_COMP_EDCA_TURBO, ODM_DBG_LOUD, ("Orginial BE PARAM: 0x%x\n", rtw_read32(Adapter, ODM_EDCA_BE_PARAM)));
+	ODM_RT_TRACE(pDM_Odm, ODM_COMP_EDCA_TURBO, ODM_DBG_LOUD, ("Orginial BK PARAM: 0x%x\n", rtw_read32(Adapter, ODM_EDCA_BK_PARAM)));
 }	/*  ODM_InitEdcaTurbo */
 
 void odm_EdcaTurboCheck(struct odm_dm_struct *pDM_Odm)
diff --git a/drivers/staging/rtl8188eu/hal/odm_interface.c b/drivers/staging/rtl8188eu/hal/odm_interface.c
index f8d1692..ae4f30c 100644
--- a/drivers/staging/rtl8188eu/hal/odm_interface.c
+++ b/drivers/staging/rtl8188eu/hal/odm_interface.c
@@ -21,12 +21,6 @@
 #include "odm_precomp.h"
 /*  ODM IO Relative API. */
 
-u32 ODM_Read4Byte(struct odm_dm_struct *pDM_Odm, u32 RegAddr)
-{
-	struct adapter *Adapter = pDM_Odm->Adapter;
-	return rtw_read32(Adapter, RegAddr);
-}
-
 void ODM_Write1Byte(struct odm_dm_struct *pDM_Odm, u32 RegAddr, u8 Data)
 {
 	struct adapter *Adapter = pDM_Odm->Adapter;
diff --git a/drivers/staging/rtl8188eu/include/odm_interface.h b/drivers/staging/rtl8188eu/include/odm_interface.h
index 84c6449..adcdc39 100644
--- a/drivers/staging/rtl8188eu/include/odm_interface.h
+++ b/drivers/staging/rtl8188eu/include/odm_interface.h
@@ -77,8 +77,6 @@ typedef void (*RT_WORKITEM_CALL_BACK)(void *pContext);
 
 /*  =========== EXtern Function Prototype */
 
-u32 ODM_Read4Byte(struct odm_dm_struct *pDM_Odm, u32 RegAddr);
-
 void ODM_Write1Byte(struct odm_dm_struct *pDM_Odm, u32 RegAddr, u8 Data);
 
 void ODM_Write2Byte(struct odm_dm_struct *pDM_Odm, u32 RegAddr, u16 Data);
-- 
1.8.4.5
