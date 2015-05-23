From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH] staging: r8712u: Fix kernel warning for improper call of del_timer_sync()
Date: Sat, 23 May 2015 16:16:52 -0500
Message-ID: <1432415812-1285-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: netdev@vger.kernel.org, devel@driverdev.osuosl.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	linux-wireless@vger.kernel.org, Stable <stable@vger.kernel.org>,
	Haggi Eran <haggai.eran@gmail.com>
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f180.google.com ([209.85.214.180]:36670 "EHLO
	mail-ob0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751324AbbEWVRA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 May 2015 17:17:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver is reporting a warning at kernel/time/timer.c:1096 due to calling
del_timer_sync() while in interrupt mode. Such warnings are fixed by calling
del_timer() instead.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
Cc: Stable <stable@vger.kernel.org>
Cc: Haggi Eran <haggai.eran@gmail.com>
---
 drivers/staging/rtl8712/rtl8712_led.c  | 2 +-
 drivers/staging/rtl8712/rtl871x_mlme.c | 4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/staging/rtl8712/rtl8712_led.c b/drivers/staging/rtl8712/rtl8712_led.c
index f1d47a0..8cc716c 100644
--- a/drivers/staging/rtl8712/rtl8712_led.c
+++ b/drivers/staging/rtl8712/rtl8712_led.c
@@ -921,7 +921,7 @@ static void SwLedControlMode1(struct _adapter *padapter,
 			    IS_LED_WPS_BLINKING(pLed))
 				return;
 			if (pLed->bLedNoLinkBlinkInProgress == true) {
-				del_timer_sync(&pLed->BlinkTimer);
+				del_timer(&pLed->BlinkTimer);
 				pLed->bLedNoLinkBlinkInProgress = false;
 			}
 			if (pLed->bLedBlinkInProgress == true) {
diff --git a/drivers/staging/rtl8712/rtl871x_mlme.c b/drivers/staging/rtl8712/rtl871x_mlme.c
index fb2b195..ace88ab 100644
--- a/drivers/staging/rtl8712/rtl871x_mlme.c
+++ b/drivers/staging/rtl8712/rtl871x_mlme.c
@@ -582,7 +582,7 @@ void r8712_surveydone_event_callback(struct _adapter *adapter, u8 *pbuf)
 	spin_lock_irqsave(&pmlmepriv->lock, irqL);
 
 	if (check_fwstate(pmlmepriv, _FW_UNDER_SURVEY) == true) {
-		del_timer_sync(&pmlmepriv->scan_to_timer);
+		del_timer(&pmlmepriv->scan_to_timer);
 
 		_clr_fwstate_(pmlmepriv, _FW_UNDER_SURVEY);
 	}
@@ -910,7 +910,7 @@ void r8712_joinbss_event_callback(struct _adapter *adapter, u8 *pbuf)
 			if (check_fwstate(pmlmepriv, WIFI_STATION_STATE)
 				== true)
 				r8712_indicate_connect(adapter);
-			del_timer_sync(&pmlmepriv->assoc_timer);
+			del_timer(&pmlmepriv->assoc_timer);
 		} else
 			goto ignore_joinbss_callback;
 	} else {
-- 
2.1.4
