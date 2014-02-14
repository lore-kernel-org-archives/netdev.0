From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 12/13] staging: r8188eu: Remove wrapper routine _set_workitem()
Date: Fri, 14 Feb 2014 16:54:16 -0600
Message-ID: <1392418457-3203-13-git-send-email-Larry.Finger@lwfinger.net>
References: <1392418457-3203-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: netdev@vger.kernel.org, devel@driverdev.osuosl.org,
	Larry Finger <Larry.Finger@lwfinger.net>
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f45.google.com ([209.85.219.45]:41643 "EHLO
	mail-oa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753059AbaBNWzF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Feb 2014 17:55:05 -0500
Received: by mail-oa0-f45.google.com with SMTP id i11so15437523oag.32
        for <netdev@vger.kernel.org>; Fri, 14 Feb 2014 14:55:04 -0800 (PST)
In-Reply-To: <1392418457-3203-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is simply a wrapper around schedule_work().

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/staging/rtl8188eu/core/rtw_led.c          | 2 +-
 drivers/staging/rtl8188eu/include/osdep_service.h | 5 -----
 2 files changed, 1 insertion(+), 6 deletions(-)

diff --git a/drivers/staging/rtl8188eu/core/rtw_led.c b/drivers/staging/rtl8188eu/core/rtw_led.c
index b9c9fc0..42b41ab 100644
--- a/drivers/staging/rtl8188eu/core/rtw_led.c
+++ b/drivers/staging/rtl8188eu/core/rtw_led.c
@@ -34,7 +34,7 @@ void BlinkTimerCallback(void *data)
 	if ((padapter->bSurpriseRemoved) || (padapter->bDriverStopped))
 		return;
 
-	_set_workitem(&(pLed->BlinkWorkItem));
+	schedule_work(&(pLed->BlinkWorkItem));
 }
 
 /*  */
diff --git a/drivers/staging/rtl8188eu/include/osdep_service.h b/drivers/staging/rtl8188eu/include/osdep_service.h
index 76f5827..882ff16 100644
--- a/drivers/staging/rtl8188eu/include/osdep_service.h
+++ b/drivers/staging/rtl8188eu/include/osdep_service.h
@@ -97,11 +97,6 @@ static inline void _cancel_timer(struct timer_list *ptimer, u8 *bcancelled)
 #define RTW_DECLARE_TIMER_HDL(name) \
 	void RTW_TIMER_HDL_NAME(name)(RTW_TIMER_HDL_ARGS)
 
-static inline void _set_workitem(struct work_struct *pwork)
-{
-	schedule_work(pwork);
-}
-
 static inline void _cancel_workitem_sync(struct work_struct *pwork)
 {
 	cancel_work_sync(pwork);
-- 
1.8.4.5
