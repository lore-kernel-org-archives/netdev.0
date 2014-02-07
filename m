From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 06/12] staging: r8188eu: Remove ODM_Write4Byte
Date: Thu,  6 Feb 2014 20:45:41 -0600
Message-ID: <1391741147-3047-7-git-send-email-Larry.Finger@lwfinger.net>
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

This routine is the equivalent of rtw_write32.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/staging/rtl8188eu/hal/HalPhyRf_8188e.c    | 2 +-
 drivers/staging/rtl8188eu/hal/odm_interface.c     | 7 -------
 drivers/staging/rtl8188eu/include/odm_interface.h | 2 --
 3 files changed, 1 insertion(+), 10 deletions(-)

diff --git a/drivers/staging/rtl8188eu/hal/HalPhyRf_8188e.c b/drivers/staging/rtl8188eu/hal/HalPhyRf_8188e.c
index bb80b8a..6af70ce 100644
--- a/drivers/staging/rtl8188eu/hal/HalPhyRf_8188e.c
+++ b/drivers/staging/rtl8188eu/hal/HalPhyRf_8188e.c
@@ -870,7 +870,7 @@ _PHY_ReloadMACRegisters(
 	for (i = 0; i < (IQK_MAC_REG_NUM - 1); i++) {
 		rtw_write8(adapt, MACReg[i], (u8)MACBackup[i]);
 	}
-	ODM_Write4Byte(dm_odm, MACReg[i], MACBackup[i]);
+	rtw_write32(adapt, MACReg[i], MACBackup[i]);
 }
 
 void
diff --git a/drivers/staging/rtl8188eu/hal/odm_interface.c b/drivers/staging/rtl8188eu/hal/odm_interface.c
index 202790c..b84b111 100644
--- a/drivers/staging/rtl8188eu/hal/odm_interface.c
+++ b/drivers/staging/rtl8188eu/hal/odm_interface.c
@@ -19,13 +19,6 @@
  ******************************************************************************/
 
 #include "odm_precomp.h"
-/*  ODM IO Relative API. */
-
-void ODM_Write4Byte(struct odm_dm_struct *pDM_Odm, u32 RegAddr, u32 Data)
-{
-	struct adapter *Adapter = pDM_Odm->Adapter;
-	rtw_write32(Adapter, RegAddr, Data);
-}
 
 /*  ODM Memory relative API. */
 void ODM_AllocateMemory(struct odm_dm_struct *pDM_Odm, void **pPtr, u32 length)
diff --git a/drivers/staging/rtl8188eu/include/odm_interface.h b/drivers/staging/rtl8188eu/include/odm_interface.h
index f45f172..9284eb8 100644
--- a/drivers/staging/rtl8188eu/include/odm_interface.h
+++ b/drivers/staging/rtl8188eu/include/odm_interface.h
@@ -77,8 +77,6 @@ typedef void (*RT_WORKITEM_CALL_BACK)(void *pContext);
 
 /*  =========== EXtern Function Prototype */
 
-void ODM_Write4Byte(struct odm_dm_struct *pDM_Odm, u32 RegAddr, u32 Data);
-
 /*  Memory Relative Function. */
 void ODM_AllocateMemory(struct odm_dm_struct *pDM_Odm, void **pPtr, u32 length);
 void ODM_FreeMemory(struct odm_dm_struct *pDM_Odm, void *pPtr, u32 length);
-- 
1.8.4.5
