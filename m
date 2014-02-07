From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 10/12] staging: r8188eu: Remove ODM_CompareMemory
Date: Thu,  6 Feb 2014 20:45:45 -0600
Message-ID: <1391741147-3047-11-git-send-email-Larry.Finger@lwfinger.net>
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

This routine is a wrapper for _rtw_memcmp(), which is a wrapper for memcmp.
In a later change, _rtw_memcmp will be removed.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/staging/rtl8188eu/hal/HalPhyRf_8188e.c    | 4 ++--
 drivers/staging/rtl8188eu/hal/odm_interface.c     | 5 -----
 drivers/staging/rtl8188eu/include/odm_interface.h | 3 ---
 3 files changed, 2 insertions(+), 10 deletions(-)

diff --git a/drivers/staging/rtl8188eu/hal/HalPhyRf_8188e.c b/drivers/staging/rtl8188eu/hal/HalPhyRf_8188e.c
index 6af70ce..4b5caa1 100644
--- a/drivers/staging/rtl8188eu/hal/HalPhyRf_8188e.c
+++ b/drivers/staging/rtl8188eu/hal/HalPhyRf_8188e.c
@@ -217,7 +217,7 @@ odm_TXPowerTrackingCallback_ThermalMeter_8188E(
 
 		for (i = 0; i < CCK_TABLE_SIZE; i++) {
 			if (dm_odm->RFCalibrateInfo.bCCKinCH14) {
-				if (ODM_CompareMemory(dm_odm, (void *)&TempCCk, (void *)&CCKSwingTable_Ch14[i][2], 4) == 0) {
+				if (_rtw_memcmp((void *)&TempCCk, (void *)&CCKSwingTable_Ch14[i][2], 4) == 0) {
 					CCK_index_old = (u8)i;
 					dm_odm->BbSwingIdxCckBase = (u8)i;
 					ODM_RT_TRACE(dm_odm, ODM_COMP_CALIBRATION, ODM_DBG_LOUD,
@@ -229,7 +229,7 @@ odm_TXPowerTrackingCallback_ThermalMeter_8188E(
 				ODM_RT_TRACE(dm_odm, ODM_COMP_CALIBRATION, ODM_DBG_LOUD,
 					     ("RegA24: 0x%X, CCKSwingTable_Ch1_Ch13[%d][2]: CCKSwingTable_Ch1_Ch13[i][2]: 0x%X\n",
 					     TempCCk, i, CCKSwingTable_Ch1_Ch13[i][2]));
-				if (ODM_CompareMemory(dm_odm, (void *)&TempCCk, (void *)&CCKSwingTable_Ch1_Ch13[i][2], 4) == 0) {
+				if (_rtw_memcmp((void *)&TempCCk, (void *)&CCKSwingTable_Ch1_Ch13[i][2], 4) == 0) {
 					CCK_index_old = (u8)i;
 					dm_odm->BbSwingIdxCckBase = (u8)i;
 					ODM_RT_TRACE(dm_odm, ODM_COMP_CALIBRATION, ODM_DBG_LOUD,
diff --git a/drivers/staging/rtl8188eu/hal/odm_interface.c b/drivers/staging/rtl8188eu/hal/odm_interface.c
index 0f5b32f..f6e8c1c 100644
--- a/drivers/staging/rtl8188eu/hal/odm_interface.c
+++ b/drivers/staging/rtl8188eu/hal/odm_interface.c
@@ -20,11 +20,6 @@
 
 #include "odm_precomp.h"
 
-s32 ODM_CompareMemory(struct odm_dm_struct *pDM_Odm, void *pBuf1, void *pBuf2, u32 length)
-{
-	return _rtw_memcmp(pBuf1, pBuf2, length);
-}
-
 void ODM_SetTimer(struct odm_dm_struct *pDM_Odm, struct timer_list *pTimer, u32 msDelay)
 {
 	_set_timer(pTimer, msDelay); /* ms */
diff --git a/drivers/staging/rtl8188eu/include/odm_interface.h b/drivers/staging/rtl8188eu/include/odm_interface.h
index 8e07754..35de915 100644
--- a/drivers/staging/rtl8188eu/include/odm_interface.h
+++ b/drivers/staging/rtl8188eu/include/odm_interface.h
@@ -79,9 +79,6 @@ typedef void (*RT_WORKITEM_CALL_BACK)(void *pContext);
 
 /*  Memory Relative Function. */
 
-s32 ODM_CompareMemory(struct odm_dm_struct *pDM_Odm, void *pBuf1, void *pBuf2,
-		      u32 length);
-
 /*  ODM Timer relative API. */
 void ODM_SetTimer(struct odm_dm_struct *pDM_Odm, struct timer_list *pTimer,
 		  u32 msDelay);
-- 
1.8.4.5
