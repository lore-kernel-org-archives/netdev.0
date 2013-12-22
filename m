From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 19/31] staging: r8188eu: Remove more empty routines
Date: Sun, 22 Dec 2013 17:36:50 -0600
Message-ID: <1387755422-11443-20-git-send-email-Larry.Finger@lwfinger.net>
References: <1387755422-11443-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: netdev@vger.kernel.org, devel@driverdev.osuosl.org,
	Larry Finger <Larry.Finger@lwfinger.net>
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:53950 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756862Ab3LVXiZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Dec 2013 18:38:25 -0500
Received: by mail-pb0-f46.google.com with SMTP id md12so4681330pbc.33
        for <netdev@vger.kernel.org>; Sun, 22 Dec 2013 15:38:25 -0800 (PST)
In-Reply-To: <1387755422-11443-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This batch includes

ODM_StartWorkItem
ODM_StopWorkItem
ODM_FreeWorkItem
ODM_AcquireSpinLoc
ODM_ReleaseSpinLock
ODM_ReleaseTimer
ODM_ReleaseAllTimers

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/staging/rtl8188eu/hal/odm.c               |  7 -------
 drivers/staging/rtl8188eu/hal/odm_interface.c     | 20 --------------------
 drivers/staging/rtl8188eu/include/odm.h           |  2 --
 drivers/staging/rtl8188eu/include/odm_interface.h | 14 --------------
 4 files changed, 43 deletions(-)

diff --git a/drivers/staging/rtl8188eu/hal/odm.c b/drivers/staging/rtl8188eu/hal/odm.c
index e146c39..683f2bc 100644
--- a/drivers/staging/rtl8188eu/hal/odm.c
+++ b/drivers/staging/rtl8188eu/hal/odm.c
@@ -1597,13 +1597,6 @@ void ODM_CancelAllTimers(struct odm_dm_struct *pDM_Odm)
 	ODM_CancelTimer(pDM_Odm, &pDM_Odm->DM_SWAT_Table.SwAntennaSwitchTimer);
 }
 
-void ODM_ReleaseAllTimers(struct odm_dm_struct *pDM_Odm)
-{
-	ODM_ReleaseTimer(pDM_Odm, &pDM_Odm->DM_SWAT_Table.SwAntennaSwitchTimer);
-
-	ODM_ReleaseTimer(pDM_Odm, &pDM_Odm->FastAntTrainingTimer);
-}
-
 /* 3============================================================ */
 /* 3 Tx Power Tracking */
 /* 3============================================================ */
diff --git a/drivers/staging/rtl8188eu/hal/odm_interface.c b/drivers/staging/rtl8188eu/hal/odm_interface.c
index 74d37cf..3cd6821 100644
--- a/drivers/staging/rtl8188eu/hal/odm_interface.c
+++ b/drivers/staging/rtl8188eu/hal/odm_interface.c
@@ -74,22 +74,6 @@ s32 ODM_CompareMemory(struct odm_dm_struct *pDM_Odm, void *pBuf1, void *pBuf2, u
 	return _rtw_memcmp(pBuf1, pBuf2, length);
 }
 
-/*  ODM MISC relative API. */
-void ODM_AcquireSpinLock(struct odm_dm_struct *pDM_Odm, enum RT_SPINLOCK_TYPE type)
-{
-}
-
-void ODM_ReleaseSpinLock(struct odm_dm_struct *pDM_Odm, enum RT_SPINLOCK_TYPE type)
-{
-}
-
-/*  Work item relative API. FOr MP driver only~! */
-void ODM_InitializeWorkItem(struct odm_dm_struct *pDM_Odm, void *pRtWorkItem,
-			    RT_WORKITEM_CALL_BACK RtWorkItemCallback,
-			    void *pContext, const char *szID)
-{
-}
-
 void ODM_SetTimer(struct odm_dm_struct *pDM_Odm, struct timer_list *pTimer, u32 msDelay)
 {
 	_set_timer(pTimer, msDelay); /* ms */
@@ -108,10 +92,6 @@ void ODM_CancelTimer(struct odm_dm_struct *pDM_Odm, struct timer_list *pTimer)
 	_cancel_timer_ex(pTimer);
 }
 
-void ODM_ReleaseTimer(struct odm_dm_struct *pDM_Odm, struct timer_list *pTimer)
-{
-}
-
 /*  ODM FW relative API. */
 u32 ODM_FillH2CCmd(u8 *pH2CBuffer, u32 H2CBufferLen, u32 CmdNum,
 		      u32 *pElementID, u32 *pCmdLen,
diff --git a/drivers/staging/rtl8188eu/include/odm.h b/drivers/staging/rtl8188eu/include/odm.h
index eaa4bc1..8934de9 100644
--- a/drivers/staging/rtl8188eu/include/odm.h
+++ b/drivers/staging/rtl8188eu/include/odm.h
@@ -1180,8 +1180,6 @@ void ODM_InitAllTimers(struct odm_dm_struct *pDM_Odm);
 
 void ODM_CancelAllTimers(struct odm_dm_struct *pDM_Odm);
 
-void ODM_ReleaseAllTimers(struct odm_dm_struct *pDM_Odm);
-
 void ODM_ResetIQKResult(struct odm_dm_struct *pDM_Odm);
 
 void ODM_AntselStatistics_88C(struct odm_dm_struct *pDM_Odm, u8 MacId,
diff --git a/drivers/staging/rtl8188eu/include/odm_interface.h b/drivers/staging/rtl8188eu/include/odm_interface.h
index f2e32a1..7cefb97 100644
--- a/drivers/staging/rtl8188eu/include/odm_interface.h
+++ b/drivers/staging/rtl8188eu/include/odm_interface.h
@@ -96,18 +96,6 @@ void ODM_FreeMemory(struct odm_dm_struct *pDM_Odm, void *pPtr, u32 length);
 s32 ODM_CompareMemory(struct odm_dm_struct *pDM_Odm, void *pBuf1, void *pBuf2,
 		      u32 length);
 
-/*  ODM MISC-spin lock relative API. */
-void ODM_AcquireSpinLock(struct odm_dm_struct *pDM_Odm,
-			 enum RT_SPINLOCK_TYPE type);
-
-void ODM_ReleaseSpinLock(struct odm_dm_struct *pDM_Odm,
-			 enum RT_SPINLOCK_TYPE type);
-
-/*  ODM MISC-workitem relative API. */
-void ODM_InitializeWorkItem(struct odm_dm_struct *pDM_Odm, void *pRtWorkItem,
-			    RT_WORKITEM_CALL_BACK RtWorkItemCallback,
-			    void *pContext, const char *szID);
-
 /*  ODM Timer relative API. */
 void ODM_SetTimer(struct odm_dm_struct *pDM_Odm, struct timer_list *pTimer,
 		  u32 msDelay);
@@ -118,8 +106,6 @@ void ODM_InitializeTimer(struct odm_dm_struct *pDM_Odm,
 
 void ODM_CancelTimer(struct odm_dm_struct *pDM_Odm, struct timer_list *pTimer);
 
-void ODM_ReleaseTimer(struct odm_dm_struct *pDM_Odm, struct timer_list *pTimer);
-
 /*  ODM FW relative API. */
 u32 ODM_FillH2CCmd(u8 *pH2CBuffer, u32 H2CBufferLen, u32 CmdNum,
 		   u32 *pElementID, u32 *pCmdLen, u8 **pCmbBuffer,
-- 
1.8.4
