From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 05/12] staging: r8188eu: Remove ODM_Write2Byte
Date: Thu,  6 Feb 2014 20:45:40 -0600
Message-ID: <1391741147-3047-6-git-send-email-Larry.Finger@lwfinger.net>
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

This routine is the equivalent of rtw_write16.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/staging/rtl8188eu/hal/Hal8188ERateAdaptive.c | 4 +++-
 drivers/staging/rtl8188eu/hal/odm_interface.c        | 6 ------
 drivers/staging/rtl8188eu/include/odm_interface.h    | 2 --
 3 files changed, 3 insertions(+), 9 deletions(-)

diff --git a/drivers/staging/rtl8188eu/hal/Hal8188ERateAdaptive.c b/drivers/staging/rtl8188eu/hal/Hal8188ERateAdaptive.c
index 908a2c0..dea220b 100644
--- a/drivers/staging/rtl8188eu/hal/Hal8188ERateAdaptive.c
+++ b/drivers/staging/rtl8188eu/hal/Hal8188ERateAdaptive.c
@@ -668,7 +668,9 @@ void ODM_RA_SetRSSI_8188E(struct odm_dm_struct *dm_odm, u8 macid, u8 Rssi)
 
 void ODM_RA_Set_TxRPT_Time(struct odm_dm_struct *dm_odm, u16 minRptTime)
 {
-	ODM_Write2Byte(dm_odm, REG_TX_RPT_TIME, minRptTime);
+	struct adapter *adapt = dm_odm->Adapter;
+
+	rtw_write16(adapt, REG_TX_RPT_TIME, minRptTime);
 }
 
 void ODM_RA_TxRPT2Handle_8188E(struct odm_dm_struct *dm_odm, u8 *TxRPT_Buf, u16 TxRPT_Len, u32 macid_entry0, u32 macid_entry1)
diff --git a/drivers/staging/rtl8188eu/hal/odm_interface.c b/drivers/staging/rtl8188eu/hal/odm_interface.c
index 76c54dc..202790c 100644
--- a/drivers/staging/rtl8188eu/hal/odm_interface.c
+++ b/drivers/staging/rtl8188eu/hal/odm_interface.c
@@ -21,12 +21,6 @@
 #include "odm_precomp.h"
 /*  ODM IO Relative API. */
 
-void ODM_Write2Byte(struct odm_dm_struct *pDM_Odm, u32 RegAddr, u16 Data)
-{
-	struct adapter *Adapter = pDM_Odm->Adapter;
-	rtw_write16(Adapter, RegAddr, Data);
-}
-
 void ODM_Write4Byte(struct odm_dm_struct *pDM_Odm, u32 RegAddr, u32 Data)
 {
 	struct adapter *Adapter = pDM_Odm->Adapter;
diff --git a/drivers/staging/rtl8188eu/include/odm_interface.h b/drivers/staging/rtl8188eu/include/odm_interface.h
index a11dec1..f45f172 100644
--- a/drivers/staging/rtl8188eu/include/odm_interface.h
+++ b/drivers/staging/rtl8188eu/include/odm_interface.h
@@ -77,8 +77,6 @@ typedef void (*RT_WORKITEM_CALL_BACK)(void *pContext);
 
 /*  =========== EXtern Function Prototype */
 
-void ODM_Write2Byte(struct odm_dm_struct *pDM_Odm, u32 RegAddr, u16 Data);
-
 void ODM_Write4Byte(struct odm_dm_struct *pDM_Odm, u32 RegAddr, u32 Data);
 
 /*  Memory Relative Function. */
-- 
1.8.4.5
