From: Zach Brown <zach.brown@ni.com>
Subject: [RFC 2/3] staging: rtl8712: Change _LED_STATE enum in rtl871x driver to avoid conflicts with LED namespace
Date: Wed, 14 Sep 2016 16:55:48 -0500
Message-ID: <1473890149-2066-3-git-send-email-zach.brown@ni.com>
References: <1473890149-2066-1-git-send-email-zach.brown@ni.com>
Cc: mlindner@marvell.com, stephen@networkplumber.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        devel@driverdev.osuosl.org, florian.c.schilhabel@googlemail.com,
        Larry.Finger@lwfinger.net
To: f.fainelli@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1473890149-2066-1-git-send-email-zach.brown@ni.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Adding led support for phy causes namespace conflicts for some
phy drivers.

The rtl871 driver declared an enum for representing LED states. The enum
contains constant LED_OFF which conflicted with declartation found in
linux/leds.h. LED_OFF changed to LED_STATE_OFF

Signed-off-by: Zach Brown <zach.brown@ni.com>
---
 drivers/staging/rtl8712/rtl8712_led.c | 192 +++++++++++++++++-----------------
 1 file changed, 96 insertions(+), 96 deletions(-)

diff --git a/drivers/staging/rtl8712/rtl8712_led.c b/drivers/staging/rtl8712/rtl8712_led.c
index 9055827..d53ad76 100644
--- a/drivers/staging/rtl8712/rtl8712_led.c
+++ b/drivers/staging/rtl8712/rtl8712_led.c
@@ -52,7 +52,7 @@
 enum _LED_STATE_871x {
 	LED_UNKNOWN = 0,
 	LED_ON = 1,
-	LED_OFF = 2,
+	LED_STATE_OFF = 2,
 	LED_BLINK_NORMAL = 3,
 	LED_BLINK_SLOWLY = 4,
 	LED_POWER_ON_BLINK = 5,
@@ -92,7 +92,7 @@ static void InitLed871x(struct _adapter *padapter, struct LED_871x *pLed,
 	nic = padapter->pnetdev;
 	pLed->padapter = padapter;
 	pLed->LedPin = LedPin;
-	pLed->CurrLedState = LED_OFF;
+	pLed->CurrLedState = LED_STATE_OFF;
 	pLed->bLedOn = false;
 	pLed->bLedBlinkInProgress = false;
 	pLed->BlinkTimes = 0;
@@ -249,7 +249,7 @@ static void SwLedBlink(struct LED_871x *pLed)
 	} else {
 		/* Assign LED state to toggle. */
 		if (pLed->BlinkingLedState == LED_ON)
-			pLed->BlinkingLedState = LED_OFF;
+			pLed->BlinkingLedState = LED_STATE_OFF;
 		else
 			pLed->BlinkingLedState = LED_ON;
 
@@ -312,7 +312,7 @@ static void SwLedBlink1(struct LED_871x *pLed)
 	switch (pLed->CurrLedState) {
 	case LED_BLINK_SLOWLY:
 		if (pLed->bLedOn)
-			pLed->BlinkingLedState = LED_OFF;
+			pLed->BlinkingLedState = LED_STATE_OFF;
 		else
 			pLed->BlinkingLedState = LED_ON;
 		mod_timer(&pLed->BlinkTimer, jiffies +
@@ -320,7 +320,7 @@ static void SwLedBlink1(struct LED_871x *pLed)
 		break;
 	case LED_BLINK_NORMAL:
 		if (pLed->bLedOn)
-			pLed->BlinkingLedState = LED_OFF;
+			pLed->BlinkingLedState = LED_STATE_OFF;
 		else
 			pLed->BlinkingLedState = LED_ON;
 		mod_timer(&pLed->BlinkTimer, jiffies +
@@ -335,7 +335,7 @@ static void SwLedBlink1(struct LED_871x *pLed)
 				pLed->bLedLinkBlinkInProgress = true;
 				pLed->CurrLedState = LED_BLINK_NORMAL;
 				if (pLed->bLedOn)
-					pLed->BlinkingLedState = LED_OFF;
+					pLed->BlinkingLedState = LED_STATE_OFF;
 				else
 					pLed->BlinkingLedState = LED_ON;
 				mod_timer(&pLed->BlinkTimer, jiffies +
@@ -344,7 +344,7 @@ static void SwLedBlink1(struct LED_871x *pLed)
 				pLed->bLedNoLinkBlinkInProgress = true;
 				pLed->CurrLedState = LED_BLINK_SLOWLY;
 				if (pLed->bLedOn)
-					pLed->BlinkingLedState = LED_OFF;
+					pLed->BlinkingLedState = LED_STATE_OFF;
 				else
 					pLed->BlinkingLedState = LED_ON;
 				mod_timer(&pLed->BlinkTimer, jiffies +
@@ -353,7 +353,7 @@ static void SwLedBlink1(struct LED_871x *pLed)
 			pLed->bLedScanBlinkInProgress = false;
 		} else {
 			 if (pLed->bLedOn)
-				pLed->BlinkingLedState = LED_OFF;
+				pLed->BlinkingLedState = LED_STATE_OFF;
 			else
 				pLed->BlinkingLedState = LED_ON;
 			mod_timer(&pLed->BlinkTimer, jiffies +
@@ -369,7 +369,7 @@ static void SwLedBlink1(struct LED_871x *pLed)
 				pLed->bLedLinkBlinkInProgress = true;
 				pLed->CurrLedState = LED_BLINK_NORMAL;
 				if (pLed->bLedOn)
-					pLed->BlinkingLedState = LED_OFF;
+					pLed->BlinkingLedState = LED_STATE_OFF;
 				else
 					pLed->BlinkingLedState = LED_ON;
 				mod_timer(&pLed->BlinkTimer, jiffies +
@@ -378,7 +378,7 @@ static void SwLedBlink1(struct LED_871x *pLed)
 				pLed->bLedNoLinkBlinkInProgress = true;
 				pLed->CurrLedState = LED_BLINK_SLOWLY;
 				if (pLed->bLedOn)
-					pLed->BlinkingLedState = LED_OFF;
+					pLed->BlinkingLedState = LED_STATE_OFF;
 				else
 					pLed->BlinkingLedState = LED_ON;
 				mod_timer(&pLed->BlinkTimer, jiffies +
@@ -388,7 +388,7 @@ static void SwLedBlink1(struct LED_871x *pLed)
 			pLed->bLedBlinkInProgress = false;
 		} else {
 			 if (pLed->bLedOn)
-				pLed->BlinkingLedState = LED_OFF;
+				pLed->BlinkingLedState = LED_STATE_OFF;
 			else
 				pLed->BlinkingLedState = LED_ON;
 			mod_timer(&pLed->BlinkTimer, jiffies +
@@ -397,7 +397,7 @@ static void SwLedBlink1(struct LED_871x *pLed)
 		break;
 	case LED_BLINK_WPS:
 		if (pLed->bLedOn)
-			pLed->BlinkingLedState = LED_OFF;
+			pLed->BlinkingLedState = LED_STATE_OFF;
 		else
 			pLed->BlinkingLedState = LED_ON;
 		mod_timer(&pLed->BlinkTimer, jiffies +
@@ -405,7 +405,7 @@ static void SwLedBlink1(struct LED_871x *pLed)
 		break;
 	case LED_BLINK_WPS_STOP:	/* WPS success */
 		if (pLed->BlinkingLedState == LED_ON) {
-			pLed->BlinkingLedState = LED_OFF;
+			pLed->BlinkingLedState = LED_STATE_OFF;
 			mod_timer(&pLed->BlinkTimer, jiffies +
 				  msecs_to_jiffies(LED_BLINK_WPS_SUCESS_INTERVAL_ALPHA));
 			bStopBlinking = false;
@@ -416,7 +416,7 @@ static void SwLedBlink1(struct LED_871x *pLed)
 			pLed->bLedLinkBlinkInProgress = true;
 			pLed->CurrLedState = LED_BLINK_NORMAL;
 			if (pLed->bLedOn)
-				pLed->BlinkingLedState = LED_OFF;
+				pLed->BlinkingLedState = LED_STATE_OFF;
 			else
 				pLed->BlinkingLedState = LED_ON;
 			mod_timer(&pLed->BlinkTimer, jiffies +
@@ -451,14 +451,14 @@ static void SwLedBlink2(struct LED_871x *pLed)
 				pLed->BlinkingLedState = LED_ON;
 				SwLedOn(padapter, pLed);
 			} else if (!check_fwstate(pmlmepriv, _FW_LINKED)) {
-				pLed->CurrLedState = LED_OFF;
-				pLed->BlinkingLedState = LED_OFF;
+				pLed->CurrLedState = LED_STATE_OFF;
+				pLed->BlinkingLedState = LED_STATE_OFF;
 				SwLedOff(padapter, pLed);
 			}
 			pLed->bLedScanBlinkInProgress = false;
 		} else {
 			 if (pLed->bLedOn)
-				pLed->BlinkingLedState = LED_OFF;
+				pLed->BlinkingLedState = LED_STATE_OFF;
 			else
 				pLed->BlinkingLedState = LED_ON;
 			mod_timer(&pLed->BlinkTimer, jiffies +
@@ -475,14 +475,14 @@ static void SwLedBlink2(struct LED_871x *pLed)
 				pLed->BlinkingLedState = LED_ON;
 				SwLedOn(padapter, pLed);
 			} else if (!check_fwstate(pmlmepriv, _FW_LINKED)) {
-				pLed->CurrLedState = LED_OFF;
-				pLed->BlinkingLedState = LED_OFF;
+				pLed->CurrLedState = LED_STATE_OFF;
+				pLed->BlinkingLedState = LED_STATE_OFF;
 				SwLedOff(padapter, pLed);
 			}
 			pLed->bLedBlinkInProgress = false;
 		} else {
 			if (pLed->bLedOn)
-				pLed->BlinkingLedState = LED_OFF;
+				pLed->BlinkingLedState = LED_STATE_OFF;
 			else
 				pLed->BlinkingLedState = LED_ON;
 			mod_timer(&pLed->BlinkTimer, jiffies +
@@ -518,15 +518,15 @@ static void SwLedBlink3(struct LED_871x *pLed)
 				if (!pLed->bLedOn)
 					SwLedOn(padapter, pLed);
 			} else if (!check_fwstate(pmlmepriv, _FW_LINKED)) {
-				pLed->CurrLedState = LED_OFF;
-				pLed->BlinkingLedState = LED_OFF;
+				pLed->CurrLedState = LED_STATE_OFF;
+				pLed->BlinkingLedState = LED_STATE_OFF;
 				if (pLed->bLedOn)
 					SwLedOff(padapter, pLed);
 			}
 			pLed->bLedScanBlinkInProgress = false;
 		} else {
 			if (pLed->bLedOn)
-				pLed->BlinkingLedState = LED_OFF;
+				pLed->BlinkingLedState = LED_STATE_OFF;
 			else
 				pLed->BlinkingLedState = LED_ON;
 			mod_timer(&pLed->BlinkTimer, jiffies +
@@ -544,15 +544,15 @@ static void SwLedBlink3(struct LED_871x *pLed)
 				if (!pLed->bLedOn)
 					SwLedOn(padapter, pLed);
 			} else if (!check_fwstate(pmlmepriv, _FW_LINKED)) {
-				pLed->CurrLedState = LED_OFF;
-				pLed->BlinkingLedState = LED_OFF;
+				pLed->CurrLedState = LED_STATE_OFF;
+				pLed->BlinkingLedState = LED_STATE_OFF;
 				if (pLed->bLedOn)
 					SwLedOff(padapter, pLed);
 			}
 			pLed->bLedBlinkInProgress = false;
 		} else {
 			if (pLed->bLedOn)
-				pLed->BlinkingLedState = LED_OFF;
+				pLed->BlinkingLedState = LED_STATE_OFF;
 			else
 				pLed->BlinkingLedState = LED_ON;
 			mod_timer(&pLed->BlinkTimer, jiffies +
@@ -561,7 +561,7 @@ static void SwLedBlink3(struct LED_871x *pLed)
 		break;
 	case LED_BLINK_WPS:
 		if (pLed->bLedOn)
-			pLed->BlinkingLedState = LED_OFF;
+			pLed->BlinkingLedState = LED_STATE_OFF;
 		else
 			pLed->BlinkingLedState = LED_ON;
 		mod_timer(&pLed->BlinkTimer, jiffies +
@@ -569,7 +569,7 @@ static void SwLedBlink3(struct LED_871x *pLed)
 		break;
 	case LED_BLINK_WPS_STOP:	/*WPS success*/
 		if (pLed->BlinkingLedState == LED_ON) {
-			pLed->BlinkingLedState = LED_OFF;
+			pLed->BlinkingLedState = LED_STATE_OFF;
 			mod_timer(&pLed->BlinkTimer, jiffies +
 				  msecs_to_jiffies(LED_BLINK_WPS_SUCESS_INTERVAL_ALPHA));
 			bStopBlinking = false;
@@ -602,14 +602,14 @@ static void SwLedBlink4(struct LED_871x *pLed)
 		SwLedOff(padapter, pLed);
 	if (!pLed1->bLedWPSBlinkInProgress &&
 	    pLed1->BlinkingLedState == LED_UNKNOWN) {
-		pLed1->BlinkingLedState = LED_OFF;
-		pLed1->CurrLedState = LED_OFF;
+		pLed1->BlinkingLedState = LED_STATE_OFF;
+		pLed1->CurrLedState = LED_STATE_OFF;
 		SwLedOff(padapter, pLed1);
 	}
 	switch (pLed->CurrLedState) {
 	case LED_BLINK_SLOWLY:
 		if (pLed->bLedOn)
-			pLed->BlinkingLedState = LED_OFF;
+			pLed->BlinkingLedState = LED_STATE_OFF;
 		else
 			pLed->BlinkingLedState = LED_ON;
 		mod_timer(&pLed->BlinkTimer, jiffies +
@@ -617,7 +617,7 @@ static void SwLedBlink4(struct LED_871x *pLed)
 		break;
 	case LED_BLINK_StartToBlink:
 		if (pLed->bLedOn) {
-			pLed->BlinkingLedState = LED_OFF;
+			pLed->BlinkingLedState = LED_STATE_OFF;
 			mod_timer(&pLed->BlinkTimer, jiffies +
 				  msecs_to_jiffies(LED_BLINK_SLOWLY_INTERVAL));
 		} else {
@@ -634,7 +634,7 @@ static void SwLedBlink4(struct LED_871x *pLed)
 			pLed->bLedNoLinkBlinkInProgress = true;
 			pLed->CurrLedState = LED_BLINK_SLOWLY;
 			if (pLed->bLedOn)
-				pLed->BlinkingLedState = LED_OFF;
+				pLed->BlinkingLedState = LED_STATE_OFF;
 			else
 				pLed->BlinkingLedState = LED_ON;
 			mod_timer(&pLed->BlinkTimer, jiffies +
@@ -642,7 +642,7 @@ static void SwLedBlink4(struct LED_871x *pLed)
 			pLed->bLedScanBlinkInProgress = false;
 		} else {
 			if (pLed->bLedOn)
-				pLed->BlinkingLedState = LED_OFF;
+				pLed->BlinkingLedState = LED_STATE_OFF;
 			else
 				pLed->BlinkingLedState = LED_ON;
 			mod_timer(&pLed->BlinkTimer, jiffies +
@@ -657,7 +657,7 @@ static void SwLedBlink4(struct LED_871x *pLed)
 			pLed->bLedNoLinkBlinkInProgress = true;
 			pLed->CurrLedState = LED_BLINK_SLOWLY;
 			if (pLed->bLedOn)
-				pLed->BlinkingLedState = LED_OFF;
+				pLed->BlinkingLedState = LED_STATE_OFF;
 			else
 				pLed->BlinkingLedState = LED_ON;
 			mod_timer(&pLed->BlinkTimer, jiffies +
@@ -665,7 +665,7 @@ static void SwLedBlink4(struct LED_871x *pLed)
 			pLed->bLedBlinkInProgress = false;
 		} else {
 			 if (pLed->bLedOn)
-				pLed->BlinkingLedState = LED_OFF;
+				pLed->BlinkingLedState = LED_STATE_OFF;
 			else
 				pLed->BlinkingLedState = LED_ON;
 			mod_timer(&pLed->BlinkTimer, jiffies +
@@ -674,7 +674,7 @@ static void SwLedBlink4(struct LED_871x *pLed)
 		break;
 	case LED_BLINK_WPS:
 		if (pLed->bLedOn) {
-			pLed->BlinkingLedState = LED_OFF;
+			pLed->BlinkingLedState = LED_STATE_OFF;
 			mod_timer(&pLed->BlinkTimer, jiffies +
 				  msecs_to_jiffies(LED_BLINK_SLOWLY_INTERVAL));
 		} else {
@@ -685,7 +685,7 @@ static void SwLedBlink4(struct LED_871x *pLed)
 		break;
 	case LED_BLINK_WPS_STOP:	/*WPS authentication fail*/
 		if (pLed->bLedOn)
-			pLed->BlinkingLedState = LED_OFF;
+			pLed->BlinkingLedState = LED_STATE_OFF;
 		else
 			pLed->BlinkingLedState = LED_ON;
 		mod_timer(&pLed->BlinkTimer, jiffies +
@@ -706,7 +706,7 @@ static void SwLedBlink4(struct LED_871x *pLed)
 				  msecs_to_jiffies(LED_BLINK_LINK_INTERVAL_ALPHA));
 		} else {
 			if (pLed->bLedOn)
-				pLed->BlinkingLedState = LED_OFF;
+				pLed->BlinkingLedState = LED_STATE_OFF;
 			else
 				pLed->BlinkingLedState = LED_ON;
 			mod_timer(&pLed->BlinkTimer, jiffies +
@@ -742,7 +742,7 @@ static void SwLedBlink5(struct LED_871x *pLed)
 			pLed->bLedScanBlinkInProgress = false;
 		} else {
 			if (pLed->bLedOn)
-				pLed->BlinkingLedState = LED_OFF;
+				pLed->BlinkingLedState = LED_STATE_OFF;
 			else
 				pLed->BlinkingLedState = LED_ON;
 			mod_timer(&pLed->BlinkTimer, jiffies +
@@ -762,7 +762,7 @@ static void SwLedBlink5(struct LED_871x *pLed)
 			pLed->bLedBlinkInProgress = false;
 		} else {
 			 if (pLed->bLedOn)
-				pLed->BlinkingLedState = LED_OFF;
+				pLed->BlinkingLedState = LED_STATE_OFF;
 			else
 				pLed->BlinkingLedState = LED_ON;
 			mod_timer(&pLed->BlinkTimer, jiffies +
@@ -797,7 +797,7 @@ static void SwLedBlink6(struct LED_871x *pLed)
 			pLed->bLedBlinkInProgress = false;
 		} else {
 			if (pLed->bLedOn)
-				pLed->BlinkingLedState = LED_OFF;
+				pLed->BlinkingLedState = LED_STATE_OFF;
 			else
 				pLed->BlinkingLedState = LED_ON;
 			mod_timer(&pLed->BlinkTimer, jiffies +
@@ -806,7 +806,7 @@ static void SwLedBlink6(struct LED_871x *pLed)
 		break;
 	case LED_BLINK_WPS:
 		if (pLed->bLedOn)
-			pLed->BlinkingLedState = LED_OFF;
+			pLed->BlinkingLedState = LED_STATE_OFF;
 		else
 			pLed->BlinkingLedState = LED_ON;
 		mod_timer(&pLed->BlinkTimer, jiffies +
@@ -908,7 +908,7 @@ static void SwLedControlMode1(struct _adapter *padapter,
 			pLed->bLedNoLinkBlinkInProgress = true;
 			pLed->CurrLedState = LED_BLINK_SLOWLY;
 			if (pLed->bLedOn)
-				pLed->BlinkingLedState = LED_OFF;
+				pLed->BlinkingLedState = LED_STATE_OFF;
 			else
 				pLed->BlinkingLedState = LED_ON;
 			mod_timer(&pLed->BlinkTimer, jiffies +
@@ -931,7 +931,7 @@ static void SwLedControlMode1(struct _adapter *padapter,
 			pLed->bLedLinkBlinkInProgress = true;
 			pLed->CurrLedState = LED_BLINK_NORMAL;
 			if (pLed->bLedOn)
-				pLed->BlinkingLedState = LED_OFF;
+				pLed->BlinkingLedState = LED_STATE_OFF;
 			else
 				pLed->BlinkingLedState = LED_ON;
 			mod_timer(&pLed->BlinkTimer, jiffies +
@@ -961,7 +961,7 @@ static void SwLedControlMode1(struct _adapter *padapter,
 			pLed->CurrLedState = LED_SCAN_BLINK;
 			pLed->BlinkTimes = 24;
 			if (pLed->bLedOn)
-				pLed->BlinkingLedState = LED_OFF;
+				pLed->BlinkingLedState = LED_STATE_OFF;
 			else
 				pLed->BlinkingLedState = LED_ON;
 			mod_timer(&pLed->BlinkTimer, jiffies +
@@ -986,7 +986,7 @@ static void SwLedControlMode1(struct _adapter *padapter,
 			pLed->CurrLedState = LED_TXRX_BLINK;
 			pLed->BlinkTimes = 2;
 			if (pLed->bLedOn)
-				pLed->BlinkingLedState = LED_OFF;
+				pLed->BlinkingLedState = LED_STATE_OFF;
 			else
 				pLed->BlinkingLedState = LED_ON;
 			mod_timer(&pLed->BlinkTimer, jiffies +
@@ -1016,7 +1016,7 @@ static void SwLedControlMode1(struct _adapter *padapter,
 			pLed->bLedWPSBlinkInProgress = true;
 			pLed->CurrLedState = LED_BLINK_WPS;
 			if (pLed->bLedOn)
-				pLed->BlinkingLedState = LED_OFF;
+				pLed->BlinkingLedState = LED_STATE_OFF;
 			else
 				pLed->BlinkingLedState = LED_ON;
 			mod_timer(&pLed->BlinkTimer, jiffies +
@@ -1046,7 +1046,7 @@ static void SwLedControlMode1(struct _adapter *padapter,
 			pLed->bLedWPSBlinkInProgress = true;
 		pLed->CurrLedState = LED_BLINK_WPS_STOP;
 		if (pLed->bLedOn) {
-			pLed->BlinkingLedState = LED_OFF;
+			pLed->BlinkingLedState = LED_STATE_OFF;
 			mod_timer(&pLed->BlinkTimer, jiffies +
 				  msecs_to_jiffies(LED_BLINK_WPS_SUCESS_INTERVAL_ALPHA));
 		} else {
@@ -1063,15 +1063,15 @@ static void SwLedControlMode1(struct _adapter *padapter,
 		pLed->bLedNoLinkBlinkInProgress = true;
 		pLed->CurrLedState = LED_BLINK_SLOWLY;
 		if (pLed->bLedOn)
-			pLed->BlinkingLedState = LED_OFF;
+			pLed->BlinkingLedState = LED_STATE_OFF;
 		else
 			pLed->BlinkingLedState = LED_ON;
 		mod_timer(&pLed->BlinkTimer, jiffies +
 			  msecs_to_jiffies(LED_BLINK_NO_LINK_INTERVAL_ALPHA));
 		break;
 	case LED_CTL_POWER_OFF:
-		pLed->CurrLedState = LED_OFF;
-		pLed->BlinkingLedState = LED_OFF;
+		pLed->CurrLedState = LED_STATE_OFF;
+		pLed->BlinkingLedState = LED_STATE_OFF;
 		if (pLed->bLedNoLinkBlinkInProgress) {
 			del_timer(&pLed->BlinkTimer);
 			pLed->bLedNoLinkBlinkInProgress = false;
@@ -1123,7 +1123,7 @@ static void SwLedControlMode2(struct _adapter *padapter,
 			pLed->CurrLedState = LED_SCAN_BLINK;
 			pLed->BlinkTimes = 24;
 			if (pLed->bLedOn)
-				pLed->BlinkingLedState = LED_OFF;
+				pLed->BlinkingLedState = LED_STATE_OFF;
 			else
 				pLed->BlinkingLedState = LED_ON;
 			mod_timer(&pLed->BlinkTimer, jiffies +
@@ -1142,7 +1142,7 @@ static void SwLedControlMode2(struct _adapter *padapter,
 			pLed->CurrLedState = LED_TXRX_BLINK;
 			pLed->BlinkTimes = 2;
 			if (pLed->bLedOn)
-				pLed->BlinkingLedState = LED_OFF;
+				pLed->BlinkingLedState = LED_STATE_OFF;
 			else
 				pLed->BlinkingLedState = LED_ON;
 			mod_timer(&pLed->BlinkTimer, jiffies +
@@ -1195,8 +1195,8 @@ static void SwLedControlMode2(struct _adapter *padapter,
 
 	case LED_CTL_STOP_WPS_FAIL:
 		pLed->bLedWPSBlinkInProgress = false;
-		pLed->CurrLedState = LED_OFF;
-		pLed->BlinkingLedState = LED_OFF;
+		pLed->CurrLedState = LED_STATE_OFF;
+		pLed->BlinkingLedState = LED_STATE_OFF;
 		mod_timer(&pLed->BlinkTimer,
 			  jiffies + msecs_to_jiffies(0));
 		break;
@@ -1204,15 +1204,15 @@ static void SwLedControlMode2(struct _adapter *padapter,
 	case LED_CTL_START_TO_LINK:
 	case LED_CTL_NO_LINK:
 		if (!IS_LED_BLINKING(pLed)) {
-			pLed->CurrLedState = LED_OFF;
-			pLed->BlinkingLedState = LED_OFF;
+			pLed->CurrLedState = LED_STATE_OFF;
+			pLed->BlinkingLedState = LED_STATE_OFF;
 			mod_timer(&pLed->BlinkTimer,
 				  jiffies + msecs_to_jiffies(0));
 		}
 		break;
 	case LED_CTL_POWER_OFF:
-		pLed->CurrLedState = LED_OFF;
-		pLed->BlinkingLedState = LED_OFF;
+		pLed->CurrLedState = LED_STATE_OFF;
+		pLed->BlinkingLedState = LED_STATE_OFF;
 		if (pLed->bLedBlinkInProgress) {
 			del_timer(&pLed->BlinkTimer);
 			pLed->bLedBlinkInProgress = false;
@@ -1255,7 +1255,7 @@ static void SwLedControlMode3(struct _adapter *padapter,
 			pLed->CurrLedState = LED_SCAN_BLINK;
 			pLed->BlinkTimes = 24;
 			if (pLed->bLedOn)
-				pLed->BlinkingLedState = LED_OFF;
+				pLed->BlinkingLedState = LED_STATE_OFF;
 			else
 				pLed->BlinkingLedState = LED_ON;
 			mod_timer(&pLed->BlinkTimer, jiffies +
@@ -1273,7 +1273,7 @@ static void SwLedControlMode3(struct _adapter *padapter,
 			pLed->CurrLedState = LED_TXRX_BLINK;
 			pLed->BlinkTimes = 2;
 			if (pLed->bLedOn)
-				pLed->BlinkingLedState = LED_OFF;
+				pLed->BlinkingLedState = LED_STATE_OFF;
 			else
 				pLed->BlinkingLedState = LED_ON;
 			mod_timer(&pLed->BlinkTimer, jiffies +
@@ -1310,7 +1310,7 @@ static void SwLedControlMode3(struct _adapter *padapter,
 			pLed->bLedWPSBlinkInProgress = true;
 			pLed->CurrLedState = LED_BLINK_WPS;
 			if (pLed->bLedOn)
-				pLed->BlinkingLedState = LED_OFF;
+				pLed->BlinkingLedState = LED_STATE_OFF;
 			else
 				pLed->BlinkingLedState = LED_ON;
 			mod_timer(&pLed->BlinkTimer, jiffies +
@@ -1326,7 +1326,7 @@ static void SwLedControlMode3(struct _adapter *padapter,
 		}
 		pLed->CurrLedState = LED_BLINK_WPS_STOP;
 		if (pLed->bLedOn) {
-			pLed->BlinkingLedState = LED_OFF;
+			pLed->BlinkingLedState = LED_STATE_OFF;
 			mod_timer(&pLed->BlinkTimer, jiffies +
 				  msecs_to_jiffies(LED_BLINK_WPS_SUCESS_INTERVAL_ALPHA));
 		} else {
@@ -1340,23 +1340,23 @@ static void SwLedControlMode3(struct _adapter *padapter,
 			del_timer(&pLed->BlinkTimer);
 			pLed->bLedWPSBlinkInProgress = false;
 		}
-		pLed->CurrLedState = LED_OFF;
-		pLed->BlinkingLedState = LED_OFF;
+		pLed->CurrLedState = LED_STATE_OFF;
+		pLed->BlinkingLedState = LED_STATE_OFF;
 		mod_timer(&pLed->BlinkTimer,
 			  jiffies + msecs_to_jiffies(0));
 		break;
 	case LED_CTL_START_TO_LINK:
 	case LED_CTL_NO_LINK:
 		if (!IS_LED_BLINKING(pLed)) {
-			pLed->CurrLedState = LED_OFF;
-			pLed->BlinkingLedState = LED_OFF;
+			pLed->CurrLedState = LED_STATE_OFF;
+			pLed->BlinkingLedState = LED_STATE_OFF;
 			mod_timer(&pLed->BlinkTimer,
 				  jiffies + msecs_to_jiffies(0));
 		}
 		break;
 	case LED_CTL_POWER_OFF:
-		pLed->CurrLedState = LED_OFF;
-		pLed->BlinkingLedState = LED_OFF;
+		pLed->CurrLedState = LED_STATE_OFF;
+		pLed->BlinkingLedState = LED_STATE_OFF;
 		if (pLed->bLedBlinkInProgress) {
 			del_timer(&pLed->BlinkTimer);
 			pLed->bLedBlinkInProgress = false;
@@ -1390,8 +1390,8 @@ static void SwLedControlMode4(struct _adapter *padapter,
 		if (pLed1->bLedWPSBlinkInProgress) {
 			pLed1->bLedWPSBlinkInProgress = false;
 			del_timer(&pLed1->BlinkTimer);
-			pLed1->BlinkingLedState = LED_OFF;
-			pLed1->CurrLedState = LED_OFF;
+			pLed1->BlinkingLedState = LED_STATE_OFF;
+			pLed1->CurrLedState = LED_STATE_OFF;
 			if (pLed1->bLedOn)
 				mod_timer(&pLed->BlinkTimer,
 					  jiffies + msecs_to_jiffies(0));
@@ -1411,7 +1411,7 @@ static void SwLedControlMode4(struct _adapter *padapter,
 			pLed->bLedStartToLinkBlinkInProgress = true;
 			pLed->CurrLedState = LED_BLINK_StartToBlink;
 			if (pLed->bLedOn) {
-				pLed->BlinkingLedState = LED_OFF;
+				pLed->BlinkingLedState = LED_STATE_OFF;
 				mod_timer(&pLed->BlinkTimer, jiffies +
 					  msecs_to_jiffies(LED_BLINK_SLOWLY_INTERVAL));
 			} else {
@@ -1428,8 +1428,8 @@ static void SwLedControlMode4(struct _adapter *padapter,
 			if (pLed1->bLedWPSBlinkInProgress) {
 				pLed1->bLedWPSBlinkInProgress = false;
 				del_timer(&pLed1->BlinkTimer);
-				pLed1->BlinkingLedState = LED_OFF;
-				pLed1->CurrLedState = LED_OFF;
+				pLed1->BlinkingLedState = LED_STATE_OFF;
+				pLed1->CurrLedState = LED_STATE_OFF;
 				if (pLed1->bLedOn)
 					mod_timer(&pLed->BlinkTimer,
 						  jiffies + msecs_to_jiffies(0));
@@ -1446,7 +1446,7 @@ static void SwLedControlMode4(struct _adapter *padapter,
 			pLed->bLedNoLinkBlinkInProgress = true;
 			pLed->CurrLedState = LED_BLINK_SLOWLY;
 			if (pLed->bLedOn)
-				pLed->BlinkingLedState = LED_OFF;
+				pLed->BlinkingLedState = LED_STATE_OFF;
 			else
 				pLed->BlinkingLedState = LED_ON;
 			mod_timer(&pLed->BlinkTimer, jiffies +
@@ -1472,7 +1472,7 @@ static void SwLedControlMode4(struct _adapter *padapter,
 			pLed->CurrLedState = LED_SCAN_BLINK;
 			pLed->BlinkTimes = 24;
 			if (pLed->bLedOn)
-				pLed->BlinkingLedState = LED_OFF;
+				pLed->BlinkingLedState = LED_STATE_OFF;
 			else
 				pLed->BlinkingLedState = LED_ON;
 			mod_timer(&pLed->BlinkTimer, jiffies +
@@ -1493,7 +1493,7 @@ static void SwLedControlMode4(struct _adapter *padapter,
 			pLed->CurrLedState = LED_TXRX_BLINK;
 			pLed->BlinkTimes = 2;
 			if (pLed->bLedOn)
-				pLed->BlinkingLedState = LED_OFF;
+				pLed->BlinkingLedState = LED_STATE_OFF;
 			else
 				pLed->BlinkingLedState = LED_ON;
 			mod_timer(&pLed->BlinkTimer, jiffies +
@@ -1505,8 +1505,8 @@ static void SwLedControlMode4(struct _adapter *padapter,
 		if (pLed1->bLedWPSBlinkInProgress) {
 			pLed1->bLedWPSBlinkInProgress = false;
 			del_timer(&pLed1->BlinkTimer);
-			pLed1->BlinkingLedState = LED_OFF;
-			pLed1->CurrLedState = LED_OFF;
+			pLed1->BlinkingLedState = LED_STATE_OFF;
+			pLed1->CurrLedState = LED_STATE_OFF;
 			if (pLed1->bLedOn)
 				mod_timer(&pLed->BlinkTimer,
 					  jiffies + msecs_to_jiffies(0));
@@ -1527,7 +1527,7 @@ static void SwLedControlMode4(struct _adapter *padapter,
 			pLed->bLedWPSBlinkInProgress = true;
 			pLed->CurrLedState = LED_BLINK_WPS;
 			if (pLed->bLedOn) {
-				pLed->BlinkingLedState = LED_OFF;
+				pLed->BlinkingLedState = LED_STATE_OFF;
 				mod_timer(&pLed->BlinkTimer, jiffies +
 					  msecs_to_jiffies(LED_BLINK_SLOWLY_INTERVAL));
 			} else {
@@ -1545,7 +1545,7 @@ static void SwLedControlMode4(struct _adapter *padapter,
 		pLed->bLedNoLinkBlinkInProgress = true;
 		pLed->CurrLedState = LED_BLINK_SLOWLY;
 		if (pLed->bLedOn)
-			pLed->BlinkingLedState = LED_OFF;
+			pLed->BlinkingLedState = LED_STATE_OFF;
 		else
 			pLed->BlinkingLedState = LED_ON;
 		mod_timer(&pLed->BlinkTimer, jiffies +
@@ -1559,7 +1559,7 @@ static void SwLedControlMode4(struct _adapter *padapter,
 		pLed->bLedNoLinkBlinkInProgress = true;
 		pLed->CurrLedState = LED_BLINK_SLOWLY;
 		if (pLed->bLedOn)
-			pLed->BlinkingLedState = LED_OFF;
+			pLed->BlinkingLedState = LED_STATE_OFF;
 		else
 			pLed->BlinkingLedState = LED_ON;
 		mod_timer(&pLed->BlinkTimer, jiffies +
@@ -1571,7 +1571,7 @@ static void SwLedControlMode4(struct _adapter *padapter,
 			pLed1->bLedWPSBlinkInProgress = true;
 		pLed1->CurrLedState = LED_BLINK_WPS_STOP;
 		if (pLed1->bLedOn)
-			pLed1->BlinkingLedState = LED_OFF;
+			pLed1->BlinkingLedState = LED_STATE_OFF;
 		else
 			pLed1->BlinkingLedState = LED_ON;
 		mod_timer(&pLed->BlinkTimer, jiffies +
@@ -1585,7 +1585,7 @@ static void SwLedControlMode4(struct _adapter *padapter,
 		pLed->bLedNoLinkBlinkInProgress = true;
 		pLed->CurrLedState = LED_BLINK_SLOWLY;
 		if (pLed->bLedOn)
-			pLed->BlinkingLedState = LED_OFF;
+			pLed->BlinkingLedState = LED_STATE_OFF;
 		else
 			pLed->BlinkingLedState = LED_ON;
 		mod_timer(&pLed->BlinkTimer, jiffies +
@@ -1598,15 +1598,15 @@ static void SwLedControlMode4(struct _adapter *padapter,
 		pLed1->CurrLedState = LED_BLINK_WPS_STOP_OVERLAP;
 		pLed1->BlinkTimes = 10;
 		if (pLed1->bLedOn)
-			pLed1->BlinkingLedState = LED_OFF;
+			pLed1->BlinkingLedState = LED_STATE_OFF;
 		else
 			pLed1->BlinkingLedState = LED_ON;
 		mod_timer(&pLed->BlinkTimer, jiffies +
 			  msecs_to_jiffies(LED_BLINK_NORMAL_INTERVAL));
 		break;
 	case LED_CTL_POWER_OFF:
-		pLed->CurrLedState = LED_OFF;
-		pLed->BlinkingLedState = LED_OFF;
+		pLed->CurrLedState = LED_STATE_OFF;
+		pLed->BlinkingLedState = LED_STATE_OFF;
 		if (pLed->bLedNoLinkBlinkInProgress) {
 			del_timer(&pLed->BlinkTimer);
 			pLed->bLedNoLinkBlinkInProgress = false;
@@ -1679,7 +1679,7 @@ static void SwLedControlMode5(struct _adapter *padapter,
 			pLed->CurrLedState = LED_SCAN_BLINK;
 			pLed->BlinkTimes = 24;
 			if (pLed->bLedOn)
-				pLed->BlinkingLedState = LED_OFF;
+				pLed->BlinkingLedState = LED_STATE_OFF;
 			else
 				pLed->BlinkingLedState = LED_ON;
 			mod_timer(&pLed->BlinkTimer, jiffies +
@@ -1695,7 +1695,7 @@ static void SwLedControlMode5(struct _adapter *padapter,
 			pLed->CurrLedState = LED_TXRX_BLINK;
 			pLed->BlinkTimes = 2;
 			if (pLed->bLedOn)
-				pLed->BlinkingLedState = LED_OFF;
+				pLed->BlinkingLedState = LED_STATE_OFF;
 			else
 				pLed->BlinkingLedState = LED_ON;
 			mod_timer(&pLed->BlinkTimer, jiffies +
@@ -1703,8 +1703,8 @@ static void SwLedControlMode5(struct _adapter *padapter,
 		}
 		break;
 	case LED_CTL_POWER_OFF:
-		pLed->CurrLedState = LED_OFF;
-		pLed->BlinkingLedState = LED_OFF;
+		pLed->CurrLedState = LED_STATE_OFF;
+		pLed->BlinkingLedState = LED_STATE_OFF;
 		if (pLed->bLedBlinkInProgress) {
 			del_timer(&pLed->BlinkTimer);
 			pLed->bLedBlinkInProgress = false;
@@ -1746,7 +1746,7 @@ static void SwLedControlMode6(struct _adapter *padapter,
 			pLed->CurrLedState = LED_TXRX_BLINK;
 			pLed->BlinkTimes = 2;
 			if (pLed->bLedOn)
-				pLed->BlinkingLedState = LED_OFF;
+				pLed->BlinkingLedState = LED_STATE_OFF;
 			else
 				pLed->BlinkingLedState = LED_ON;
 			mod_timer(&pLed->BlinkTimer, jiffies +
@@ -1763,7 +1763,7 @@ static void SwLedControlMode6(struct _adapter *padapter,
 			pLed->bLedWPSBlinkInProgress = true;
 			pLed->CurrLedState = LED_BLINK_WPS;
 			if (pLed->bLedOn)
-				pLed->BlinkingLedState = LED_OFF;
+				pLed->BlinkingLedState = LED_STATE_OFF;
 			else
 				pLed->BlinkingLedState = LED_ON;
 			mod_timer(&pLed->BlinkTimer, jiffies +
@@ -1782,8 +1782,8 @@ static void SwLedControlMode6(struct _adapter *padapter,
 			  jiffies + msecs_to_jiffies(0));
 		break;
 	case LED_CTL_POWER_OFF:
-		pLed->CurrLedState = LED_OFF;
-		pLed->BlinkingLedState = LED_OFF;
+		pLed->CurrLedState = LED_STATE_OFF;
+		pLed->BlinkingLedState = LED_STATE_OFF;
 		if (pLed->bLedBlinkInProgress) {
 			del_timer(&pLed->BlinkTimer);
 			pLed->bLedBlinkInProgress = false;
-- 
2.7.4
