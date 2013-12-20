From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 06/11] staging: r8188eu: Remove wrapper around spin_lock_init
Date: Thu, 19 Dec 2013 22:38:38 -0600
Message-ID: <1387514323-4486-7-git-send-email-Larry.Finger@lwfinger.net>
References: <1387514323-4486-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: netdev@vger.kernel.org, devel@driverdev.osuosl.org,
	Larry Finger <Larry.Finger@lwfinger.net>
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:52161 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751932Ab3LTEkv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Dec 2013 23:40:51 -0500
Received: by mail-pa0-f41.google.com with SMTP id lf10so2136354pab.0
        for <netdev@vger.kernel.org>; Thu, 19 Dec 2013 20:40:51 -0800 (PST)
In-Reply-To: <1387514323-4486-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/staging/rtl8188eu/core/rtw_ap.c           | 2 +-
 drivers/staging/rtl8188eu/core/rtw_mlme.c         | 2 +-
 drivers/staging/rtl8188eu/core/rtw_recv.c         | 4 ++--
 drivers/staging/rtl8188eu/core/rtw_sta_mgt.c      | 8 ++++----
 drivers/staging/rtl8188eu/core/rtw_xmit.c         | 4 ++--
 drivers/staging/rtl8188eu/hal/rtl8188eu_recv.c    | 2 +-
 drivers/staging/rtl8188eu/include/osdep_service.h | 1 -
 drivers/staging/rtl8188eu/os_dep/os_intfs.c       | 2 +-
 drivers/staging/rtl8188eu/os_dep/osdep_service.c  | 7 +------
 9 files changed, 13 insertions(+), 19 deletions(-)

diff --git a/drivers/staging/rtl8188eu/core/rtw_ap.c b/drivers/staging/rtl8188eu/core/rtw_ap.c
index d86f671..c3a1561 100644
--- a/drivers/staging/rtl8188eu/core/rtw_ap.c
+++ b/drivers/staging/rtl8188eu/core/rtw_ap.c
@@ -33,7 +33,7 @@ void init_mlme_ap_info(struct adapter *padapter)
 	struct wlan_acl_pool *pacl_list = &pstapriv->acl_list;
 
 
-	_rtw_spinlock_init(&pmlmepriv->bcn_update_lock);
+	spin_lock_init(&pmlmepriv->bcn_update_lock);
 
 	/* for ACL */
 	_rtw_init_queue(&pacl_list->acl_node_q);
diff --git a/drivers/staging/rtl8188eu/core/rtw_mlme.c b/drivers/staging/rtl8188eu/core/rtw_mlme.c
index 27dfba2..eb79bf3 100644
--- a/drivers/staging/rtl8188eu/core/rtw_mlme.c
+++ b/drivers/staging/rtl8188eu/core/rtw_mlme.c
@@ -54,7 +54,7 @@ _func_enter_;
 	pmlmepriv->cur_network.network.InfrastructureMode = Ndis802_11AutoUnknown;
 	pmlmepriv->scan_mode = SCAN_ACTIVE;/*  1: active, 0: pasive. Maybe someday we should rename this varable to "active_mode" (Jeff) */
 
-	_rtw_spinlock_init(&(pmlmepriv->lock));
+	spin_lock_init(&(pmlmepriv->lock));
 	_rtw_init_queue(&(pmlmepriv->free_bss_pool));
 	_rtw_init_queue(&(pmlmepriv->scanned_queue));
 
diff --git a/drivers/staging/rtl8188eu/core/rtw_recv.c b/drivers/staging/rtl8188eu/core/rtw_recv.c
index a1bd84c..1a140de 100644
--- a/drivers/staging/rtl8188eu/core/rtw_recv.c
+++ b/drivers/staging/rtl8188eu/core/rtw_recv.c
@@ -49,7 +49,7 @@ _func_enter_;
 
 	_rtw_memset((u8 *)psta_recvpriv, 0, sizeof (struct sta_recv_priv));
 
-	_rtw_spinlock_init(&psta_recvpriv->lock);
+	spin_lock_init(&psta_recvpriv->lock);
 
 	_rtw_init_queue(&psta_recvpriv->defrag_q);
 
@@ -65,7 +65,7 @@ int _rtw_init_recv_priv(struct recv_priv *precvpriv, struct adapter *padapter)
 	int	res = _SUCCESS;
 
 _func_enter_;
-	_rtw_spinlock_init(&precvpriv->lock);
+	spin_lock_init(&precvpriv->lock);
 
 	_rtw_init_queue(&precvpriv->free_recv_queue);
 	_rtw_init_queue(&precvpriv->recv_pending_queue);
diff --git a/drivers/staging/rtl8188eu/core/rtw_sta_mgt.c b/drivers/staging/rtl8188eu/core/rtw_sta_mgt.c
index 0b8c1bf..81bb7a5 100644
--- a/drivers/staging/rtl8188eu/core/rtw_sta_mgt.c
+++ b/drivers/staging/rtl8188eu/core/rtw_sta_mgt.c
@@ -31,7 +31,7 @@ static void _rtw_init_stainfo(struct sta_info *psta)
 _func_enter_;
 	_rtw_memset((u8 *)psta, 0, sizeof (struct sta_info));
 
-	 _rtw_spinlock_init(&psta->lock);
+	 spin_lock_init(&psta->lock);
 	_rtw_init_listhead(&psta->list);
 	_rtw_init_listhead(&psta->hash_list);
 	_rtw_init_queue(&psta->sleep_q);
@@ -89,7 +89,7 @@ _func_enter_;
 
 	_rtw_init_queue(&pstapriv->free_sta_queue);
 
-	_rtw_spinlock_init(&pstapriv->sta_hash_lock);
+	spin_lock_init(&pstapriv->sta_hash_lock);
 
 	pstapriv->asoc_sta_count = 0;
 	_rtw_init_queue(&pstapriv->sleep_q);
@@ -114,8 +114,8 @@ _func_enter_;
 
 	_rtw_init_listhead(&pstapriv->asoc_list);
 	_rtw_init_listhead(&pstapriv->auth_list);
-	_rtw_spinlock_init(&pstapriv->asoc_list_lock);
-	_rtw_spinlock_init(&pstapriv->auth_list_lock);
+	spin_lock_init(&pstapriv->asoc_list_lock);
+	spin_lock_init(&pstapriv->auth_list_lock);
 	pstapriv->asoc_list_cnt = 0;
 	pstapriv->auth_list_cnt = 0;
 
diff --git a/drivers/staging/rtl8188eu/core/rtw_xmit.c b/drivers/staging/rtl8188eu/core/rtw_xmit.c
index bf01c30..c0ccbaf 100644
--- a/drivers/staging/rtl8188eu/core/rtw_xmit.c
+++ b/drivers/staging/rtl8188eu/core/rtw_xmit.c
@@ -43,7 +43,7 @@ void	_rtw_init_sta_xmit_priv(struct sta_xmit_priv *psta_xmitpriv)
 {
 _func_enter_;
 	_rtw_memset((unsigned char *)psta_xmitpriv, 0, sizeof (struct sta_xmit_priv));
-	_rtw_spinlock_init(&psta_xmitpriv->lock);
+	spin_lock_init(&psta_xmitpriv->lock);
 	_init_txservq(&psta_xmitpriv->be_q);
 	_init_txservq(&psta_xmitpriv->bk_q);
 	_init_txservq(&psta_xmitpriv->vi_q);
@@ -67,7 +67,7 @@ _func_enter_;
 
 	/*  We don't need to memset padapter->XXX to zero, because adapter is allocated by rtw_zvmalloc(). */
 
-	_rtw_spinlock_init(&pxmitpriv->lock);
+	spin_lock_init(&pxmitpriv->lock);
 	_rtw_init_sema(&pxmitpriv->xmit_sema, 0);
 	_rtw_init_sema(&pxmitpriv->terminate_xmitthread_sema, 0);
 
diff --git a/drivers/staging/rtl8188eu/hal/rtl8188eu_recv.c b/drivers/staging/rtl8188eu/hal/rtl8188eu_recv.c
index 0f47b89..17c94f4 100644
--- a/drivers/staging/rtl8188eu/hal/rtl8188eu_recv.c
+++ b/drivers/staging/rtl8188eu/hal/rtl8188eu_recv.c
@@ -75,7 +75,7 @@ int	rtl8188eu_init_recv_priv(struct adapter *padapter)
 
 	for (i = 0; i < NR_RECVBUFF; i++) {
 		_rtw_init_listhead(&precvbuf->list);
-		_rtw_spinlock_init(&precvbuf->recvbuf_lock);
+		spin_lock_init(&precvbuf->recvbuf_lock);
 		precvbuf->alloc_sz = MAX_RECVBUF_SZ;
 		res = rtw_os_recvbuf_resource_alloc(padapter, precvbuf);
 		if (res == _FAIL)
diff --git a/drivers/staging/rtl8188eu/include/osdep_service.h b/drivers/staging/rtl8188eu/include/osdep_service.h
index a42c554..4b1a6ae 100644
--- a/drivers/staging/rtl8188eu/include/osdep_service.h
+++ b/drivers/staging/rtl8188eu/include/osdep_service.h
@@ -262,7 +262,6 @@ void _rtw_up_sema(struct semaphore *sema);
 u32  _rtw_down_sema(struct semaphore *sema);
 void _rtw_mutex_init(struct mutex *pmutex);
 void _rtw_mutex_free(struct mutex *pmutex);
-void _rtw_spinlock_init(spinlock_t *plock);
 void _rtw_spinlock_free(spinlock_t *plock);
 
 void _rtw_init_queue(struct __queue *pqueue);
diff --git a/drivers/staging/rtl8188eu/os_dep/os_intfs.c b/drivers/staging/rtl8188eu/os_dep/os_intfs.c
index 17659bb..bc2986a 100644
--- a/drivers/staging/rtl8188eu/os_dep/os_intfs.c
+++ b/drivers/staging/rtl8188eu/os_dep/os_intfs.c
@@ -924,7 +924,7 @@ _func_enter_;
 
 	rtw_hal_sreset_init(padapter);
 
-	_rtw_spinlock_init(&padapter->br_ext_lock);
+	spin_lock_init(&padapter->br_ext_lock);
 
 exit:
 	RT_TRACE(_module_os_intfs_c_, _drv_info_, ("-rtw_init_drv_sw\n"));
diff --git a/drivers/staging/rtl8188eu/os_dep/osdep_service.c b/drivers/staging/rtl8188eu/os_dep/osdep_service.c
index 2ffb418..13d9b13 100644
--- a/drivers/staging/rtl8188eu/os_dep/osdep_service.c
+++ b/drivers/staging/rtl8188eu/os_dep/osdep_service.c
@@ -193,11 +193,6 @@ void	_rtw_mutex_free(struct mutex *pmutex)
 	mutex_destroy(pmutex);
 }
 
-void	_rtw_spinlock_init(spinlock_t *plock)
-{
-	spin_lock_init(plock);
-}
-
 void	_rtw_spinlock_free(spinlock_t *plock)
 {
 }
@@ -205,7 +200,7 @@ void	_rtw_spinlock_free(spinlock_t *plock)
 void	_rtw_init_queue(struct __queue *pqueue)
 {
 	_rtw_init_listhead(&(pqueue->queue));
-	_rtw_spinlock_init(&(pqueue->lock));
+	spin_lock_init(&(pqueue->lock));
 }
 
 u32	  _rtw_queue_empty(struct __queue *pqueue)
-- 
1.8.4
