From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 09/31] staging: r8188eu: Replace wrapper around sema_init
Date: Sun, 22 Dec 2013 17:36:40 -0600
Message-ID: <1387755422-11443-10-git-send-email-Larry.Finger@lwfinger.net>
References: <1387755422-11443-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: netdev@vger.kernel.org, devel@driverdev.osuosl.org,
	Larry Finger <Larry.Finger@lwfinger.net>
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:33280 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756731Ab3LVXhq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Dec 2013 18:37:46 -0500
Received: by mail-pd0-f171.google.com with SMTP id z10so4514737pdj.16
        for <netdev@vger.kernel.org>; Sun, 22 Dec 2013 15:37:46 -0800 (PST)
In-Reply-To: <1387755422-11443-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/staging/rtl8188eu/core/rtw_cmd.c          | 6 +++---
 drivers/staging/rtl8188eu/core/rtw_recv.c         | 2 +-
 drivers/staging/rtl8188eu/core/rtw_xmit.c         | 6 +++---
 drivers/staging/rtl8188eu/include/osdep_service.h | 1 -
 drivers/staging/rtl8188eu/include/rtw_pwrctrl.h   | 2 +-
 drivers/staging/rtl8188eu/os_dep/osdep_service.c  | 5 -----
 drivers/staging/rtl8188eu/os_dep/usb_intf.c       | 2 +-
 7 files changed, 9 insertions(+), 15 deletions(-)

diff --git a/drivers/staging/rtl8188eu/core/rtw_cmd.c b/drivers/staging/rtl8188eu/core/rtw_cmd.c
index f01564f..a46aadd 100644
--- a/drivers/staging/rtl8188eu/core/rtw_cmd.c
+++ b/drivers/staging/rtl8188eu/core/rtw_cmd.c
@@ -38,9 +38,9 @@ int	_rtw_init_cmd_priv (struct	cmd_priv *pcmdpriv)
 
 _func_enter_;
 
-	_rtw_init_sema(&(pcmdpriv->cmd_queue_sema), 0);
-	/* _rtw_init_sema(&(pcmdpriv->cmd_done_sema), 0); */
-	_rtw_init_sema(&(pcmdpriv->terminate_cmdthread_sema), 0);
+	sema_init(&(pcmdpriv->cmd_queue_sema), 0);
+	/* sema_init(&(pcmdpriv->cmd_done_sema), 0); */
+	sema_init(&(pcmdpriv->terminate_cmdthread_sema), 0);
 
 
 	_rtw_init_queue(&(pcmdpriv->cmd_queue));
diff --git a/drivers/staging/rtl8188eu/core/rtw_recv.c b/drivers/staging/rtl8188eu/core/rtw_recv.c
index 7c5403a..c9c1806 100644
--- a/drivers/staging/rtl8188eu/core/rtw_recv.c
+++ b/drivers/staging/rtl8188eu/core/rtw_recv.c
@@ -102,7 +102,7 @@ _func_enter_;
 	}
 	precvpriv->rx_pending_cnt = 1;
 
-	_rtw_init_sema(&precvpriv->allrxreturnevt, 0);
+	sema_init(&precvpriv->allrxreturnevt, 0);
 
 	res = rtw_hal_init_recv_priv(padapter);
 
diff --git a/drivers/staging/rtl8188eu/core/rtw_xmit.c b/drivers/staging/rtl8188eu/core/rtw_xmit.c
index 0ebcc7a..b372408 100644
--- a/drivers/staging/rtl8188eu/core/rtw_xmit.c
+++ b/drivers/staging/rtl8188eu/core/rtw_xmit.c
@@ -68,8 +68,8 @@ _func_enter_;
 	/*  We don't need to memset padapter->XXX to zero, because adapter is allocated by rtw_zvmalloc(). */
 
 	spin_lock_init(&pxmitpriv->lock);
-	_rtw_init_sema(&pxmitpriv->xmit_sema, 0);
-	_rtw_init_sema(&pxmitpriv->terminate_xmitthread_sema, 0);
+	sema_init(&pxmitpriv->xmit_sema, 0);
+	sema_init(&pxmitpriv->terminate_xmitthread_sema, 0);
 
 	/*
 	Please insert all the queue initializaiton using _rtw_init_queue below
@@ -210,7 +210,7 @@ _func_enter_;
 
 	pxmitpriv->txirp_cnt = 1;
 
-	_rtw_init_sema(&(pxmitpriv->tx_retevt), 0);
+	sema_init(&(pxmitpriv->tx_retevt), 0);
 
 	/* per AC pending irp */
 	pxmitpriv->beq_cnt = 0;
diff --git a/drivers/staging/rtl8188eu/include/osdep_service.h b/drivers/staging/rtl8188eu/include/osdep_service.h
index b36fc20..77829b9 100644
--- a/drivers/staging/rtl8188eu/include/osdep_service.h
+++ b/drivers/staging/rtl8188eu/include/osdep_service.h
@@ -256,7 +256,6 @@ void rtw_list_insert_head(struct list_head *plist, struct list_head *phead);
 void rtw_list_insert_tail(struct list_head *plist, struct list_head *phead);
 void rtw_list_delete(struct list_head *plist);
 
-void _rtw_init_sema(struct semaphore *sema, int init_val);
 void _rtw_free_sema(struct semaphore *sema);
 void _rtw_up_sema(struct semaphore *sema);
 u32  _rtw_down_sema(struct semaphore *sema);
diff --git a/drivers/staging/rtl8188eu/include/rtw_pwrctrl.h b/drivers/staging/rtl8188eu/include/rtw_pwrctrl.h
index d4b8acb..3946c03 100644
--- a/drivers/staging/rtl8188eu/include/rtw_pwrctrl.h
+++ b/drivers/staging/rtl8188eu/include/rtw_pwrctrl.h
@@ -99,7 +99,7 @@ struct reportpwrstate_parm {
 
 static inline void _init_pwrlock(struct semaphore  *plock)
 {
-	_rtw_init_sema(plock, 1);
+	sema_init(plock, 1);
 }
 
 static inline void _free_pwrlock(struct semaphore  *plock)
diff --git a/drivers/staging/rtl8188eu/os_dep/osdep_service.c b/drivers/staging/rtl8188eu/os_dep/osdep_service.c
index 77f5310..f292427 100644
--- a/drivers/staging/rtl8188eu/os_dep/osdep_service.c
+++ b/drivers/staging/rtl8188eu/os_dep/osdep_service.c
@@ -161,11 +161,6 @@ void rtw_list_insert_tail(struct list_head *plist, struct list_head *phead)
 Caller must check if the list is empty before calling rtw_list_delete
 */
 
-void _rtw_init_sema(struct semaphore *sema, int init_val)
-{
-	sema_init(sema, init_val);
-}
-
 void _rtw_free_sema(struct semaphore *sema)
 {
 }
diff --git a/drivers/staging/rtl8188eu/os_dep/usb_intf.c b/drivers/staging/rtl8188eu/os_dep/usb_intf.c
index 28903aa..8642397 100644
--- a/drivers/staging/rtl8188eu/os_dep/usb_intf.c
+++ b/drivers/staging/rtl8188eu/os_dep/usb_intf.c
@@ -240,7 +240,7 @@ _func_enter_;
 	}
 
 	/* 3 misc */
-	_rtw_init_sema(&(pdvobjpriv->usb_suspend_sema), 0);
+	sema_init(&(pdvobjpriv->usb_suspend_sema), 0);
 	rtw_reset_continual_urb_error(pdvobjpriv);
 
 	usb_get_dev(pusbd);
-- 
1.8.4
