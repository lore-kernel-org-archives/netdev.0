From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 11/13] staging: r8188eu: Remove wrapper routine _init_workitem()
Date: Fri, 14 Feb 2014 16:54:15 -0600
Message-ID: <1392418457-3203-12-git-send-email-Larry.Finger@lwfinger.net>
References: <1392418457-3203-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: netdev@vger.kernel.org, devel@driverdev.osuosl.org,
	Larry Finger <Larry.Finger@lwfinger.net>
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f175.google.com ([209.85.214.175]:60167 "EHLO
	mail-ob0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753067AbaBNWzD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Feb 2014 17:55:03 -0500
Received: by mail-ob0-f175.google.com with SMTP id wn1so14520576obc.6
        for <netdev@vger.kernel.org>; Fri, 14 Feb 2014 14:55:02 -0800 (PST)
In-Reply-To: <1392418457-3203-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is simply another name for INIT_WORK().

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/staging/rtl8188eu/core/rtw_cmd.c          | 2 +-
 drivers/staging/rtl8188eu/core/rtw_led.c          | 2 +-
 drivers/staging/rtl8188eu/include/osdep_service.h | 6 ------
 3 files changed, 2 insertions(+), 8 deletions(-)

diff --git a/drivers/staging/rtl8188eu/core/rtw_cmd.c b/drivers/staging/rtl8188eu/core/rtw_cmd.c
index bc78736..c0a0a52 100644
--- a/drivers/staging/rtl8188eu/core/rtw_cmd.c
+++ b/drivers/staging/rtl8188eu/core/rtw_cmd.c
@@ -84,7 +84,7 @@ int _rtw_init_evt_priv(struct evt_priv *pevtpriv)
 	atomic_set(&pevtpriv->event_seq, 0);
 	pevtpriv->evt_done_cnt = 0;
 
-	_init_workitem(&pevtpriv->c2h_wk, c2h_wk_callback, NULL);
+	INIT_WORK(&pevtpriv->c2h_wk, c2h_wk_callback);
 	pevtpriv->c2h_wk_alive = false;
 	pevtpriv->c2h_queue = rtw_cbuf_alloc(C2H_QUEUE_MAX_LEN+1);
 
diff --git a/drivers/staging/rtl8188eu/core/rtw_led.c b/drivers/staging/rtl8188eu/core/rtw_led.c
index afac537..b9c9fc0 100644
--- a/drivers/staging/rtl8188eu/core/rtw_led.c
+++ b/drivers/staging/rtl8188eu/core/rtw_led.c
@@ -80,7 +80,7 @@ void InitLed871x(struct adapter *padapter, struct LED_871x *pLed, enum LED_PIN_8
 
 	_init_timer(&(pLed->BlinkTimer), padapter->pnetdev, BlinkTimerCallback, pLed);
 
-	_init_workitem(&(pLed->BlinkWorkItem), BlinkWorkItemCallback, pLed);
+	INIT_WORK(&(pLed->BlinkWorkItem), BlinkWorkItemCallback);
 }
 
 
diff --git a/drivers/staging/rtl8188eu/include/osdep_service.h b/drivers/staging/rtl8188eu/include/osdep_service.h
index 64a7c34..76f5827 100644
--- a/drivers/staging/rtl8188eu/include/osdep_service.h
+++ b/drivers/staging/rtl8188eu/include/osdep_service.h
@@ -97,12 +97,6 @@ static inline void _cancel_timer(struct timer_list *ptimer, u8 *bcancelled)
 #define RTW_DECLARE_TIMER_HDL(name) \
 	void RTW_TIMER_HDL_NAME(name)(RTW_TIMER_HDL_ARGS)
 
-static inline void _init_workitem(struct work_struct *pwork, void *pfunc,
-				  void *cntx)
-{
-	INIT_WORK(pwork, pfunc);
-}
-
 static inline void _set_workitem(struct work_struct *pwork)
 {
 	schedule_work(pwork);
-- 
1.8.4.5
