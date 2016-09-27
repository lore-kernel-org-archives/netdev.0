From: Zach Brown <zach.brown@ni.com>
Subject: [RFC v2 2/4] staging: rtl8712: Change _LED_STATE enum in rtl871x
 driver to avoid conflicts with LED namespace
Date: Tue, 27 Sep 2016 16:51:49 -0500
Message-ID: <1475013111-18942-3-git-send-email-zach.brown@ni.com>
References: <1475013111-18942-1-git-send-email-zach.brown@ni.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, florian.c.schilhabel@googlemail.com,
 netdev@vger.kernel.org, linux-kernel@vger.kernel.org, zach.brown@ni.com,
 gregkh@linuxfoundation.org, Larry.Finger@lwfinger.net, mlindner@marvell.com
To: f.fainelli@gmail.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1475013111-18942-1-git-send-email-zach.brown@ni.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

Adding led support for phy causes namespace conflicts for some
phy drivers.

The rtl871 driver declared an enum for representing LED states. The enum
contains constant LED_OFF which conflicted with declaration found in
linux/leds.h. LED_OFF changed to LED_STATE_OFF
In order to avoid a possible future collision LED_ON was changed to
LED_STATE_ON as well.

Signed-off-by: Zach Brown <zach.brown@ni.com>
---
 drivers/staging/rtl8712/rtl8712_led.c | 388 +++++++++++++++++-----------------
 1 file changed, 194 insertions(+), 194 deletions(-)

diff --git a/drivers/staging/rtl8712/rtl8712_led.c b/drivers/staging/rtl8712/rtl8712_led.c
index 9055827..8a524ac 100644
--- a/drivers/staging/rtl8712/rtl8712_led.c
+++ b/drivers/staging/rtl8712/rtl8712_led.c
@@ -51,8 +51,8 @@
  */
 enum _LED_STATE_871x {
 	LED_UNKNOWN = 0,
-	LED_ON = 1,
-	LED_OFF = 2,
+	LED_STATE_ON = 1,
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
@@ -208,7 +208,7 @@ static void SwLedBlink(struct LED_871x *pLed)
 	u8 bStopBlinking = false;
 
 	/* Change LED according to BlinkingLedState specified. */
-	if (pLed->BlinkingLedState == LED_ON)
+	if (pLed->BlinkingLedState == LED_STATE_ON)
 		SwLedOn(padapter, pLed);
 	else
 		SwLedOff(padapter, pLed);
@@ -248,10 +248,10 @@ static void SwLedBlink(struct LED_871x *pLed)
 		pLed->bLedBlinkInProgress = false;
 	} else {
 		/* Assign LED state to toggle. */
-		if (pLed->BlinkingLedState == LED_ON)
-			pLed->BlinkingLedState = LED_OFF;
+		if (pLed->BlinkingLedState == LED_STATE_ON)
+			pLed->BlinkingLedState = LED_STATE_OFF;
 		else
-			pLed->BlinkingLedState = LED_ON;
+			pLed->BlinkingLedState = LED_STATE_ON;
 
 		/* Schedule a timer to toggle LED state. */
 		switch (pLed->CurrLedState) {
@@ -288,7 +288,7 @@ static void SwLedBlink1(struct LED_871x *pLed)
 	if (peeprompriv->CustomerID == RT_CID_819x_CAMEO)
 		pLed = &(ledpriv->SwLed1);
 	/* Change LED according to BlinkingLedState specified. */
-	if (pLed->BlinkingLedState == LED_ON)
+	if (pLed->BlinkingLedState == LED_STATE_ON)
 		SwLedOn(padapter, pLed);
 	else
 		SwLedOff(padapter, pLed);
@@ -312,17 +312,17 @@ static void SwLedBlink1(struct LED_871x *pLed)
 	switch (pLed->CurrLedState) {
 	case LED_BLINK_SLOWLY:
 		if (pLed->bLedOn)
-			pLed->BlinkingLedState = LED_OFF;
+			pLed->BlinkingLedState = LED_STATE_OFF;
 		else
-			pLed->BlinkingLedState = LED_ON;
+			pLed->BlinkingLedState = LED_STATE_ON;
 		mod_timer(&pLed->BlinkTimer, jiffies +
 			  msecs_to_jiffies(LED_BLINK_NO_LINK_INTERVAL_ALPHA));
 		break;
 	case LED_BLINK_NORMAL:
 		if (pLed->bLedOn)
-			pLed->BlinkingLedState = LED_OFF;
+			pLed->BlinkingLedState = LED_STATE_OFF;
 		else
-			pLed->BlinkingLedState = LED_ON;
+			pLed->BlinkingLedState = LED_STATE_ON;
 		mod_timer(&pLed->BlinkTimer, jiffies +
 			  msecs_to_jiffies(LED_BLINK_LINK_INTERVAL_ALPHA));
 		break;
@@ -335,27 +335,27 @@ static void SwLedBlink1(struct LED_871x *pLed)
 				pLed->bLedLinkBlinkInProgress = true;
 				pLed->CurrLedState = LED_BLINK_NORMAL;
 				if (pLed->bLedOn)
-					pLed->BlinkingLedState = LED_OFF;
+					pLed->BlinkingLedState = LED_STATE_OFF;
 				else
-					pLed->BlinkingLedState = LED_ON;
+					pLed->BlinkingLedState = LED_STATE_ON;
 				mod_timer(&pLed->BlinkTimer, jiffies +
 					  msecs_to_jiffies(LED_BLINK_LINK_INTERVAL_ALPHA));
 			} else if (!check_fwstate(pmlmepriv, _FW_LINKED)) {
 				pLed->bLedNoLinkBlinkInProgress = true;
 				pLed->CurrLedState = LED_BLINK_SLOWLY;
 				if (pLed->bLedOn)
-					pLed->BlinkingLedState = LED_OFF;
+					pLed->BlinkingLedState = LED_STATE_OFF;
 				else
-					pLed->BlinkingLedState = LED_ON;
+					pLed->BlinkingLedState = LED_STATE_ON;
 				mod_timer(&pLed->BlinkTimer, jiffies +
 					  msecs_to_jiffies(LED_BLINK_NO_LINK_INTERVAL_ALPHA));
 			}
 			pLed->bLedScanBlinkInProgress = false;
 		} else {
 			 if (pLed->bLedOn)
-				pLed->BlinkingLedState = LED_OFF;
+				pLed->BlinkingLedState = LED_STATE_OFF;
 			else
-				pLed->BlinkingLedState = LED_ON;
+				pLed->BlinkingLedState = LED_STATE_ON;
 			mod_timer(&pLed->BlinkTimer, jiffies +
 				  msecs_to_jiffies(LED_BLINK_SCAN_INTERVAL_ALPHA));
 		}
@@ -369,18 +369,18 @@ static void SwLedBlink1(struct LED_871x *pLed)
 				pLed->bLedLinkBlinkInProgress = true;
 				pLed->CurrLedState = LED_BLINK_NORMAL;
 				if (pLed->bLedOn)
-					pLed->BlinkingLedState = LED_OFF;
+					pLed->BlinkingLedState = LED_STATE_OFF;
 				else
-					pLed->BlinkingLedState = LED_ON;
+					pLed->BlinkingLedState = LED_STATE_ON;
 				mod_timer(&pLed->BlinkTimer, jiffies +
 					  msecs_to_jiffies(LED_BLINK_LINK_INTERVAL_ALPHA));
 			} else if (!check_fwstate(pmlmepriv, _FW_LINKED)) {
 				pLed->bLedNoLinkBlinkInProgress = true;
 				pLed->CurrLedState = LED_BLINK_SLOWLY;
 				if (pLed->bLedOn)
-					pLed->BlinkingLedState = LED_OFF;
+					pLed->BlinkingLedState = LED_STATE_OFF;
 				else
-					pLed->BlinkingLedState = LED_ON;
+					pLed->BlinkingLedState = LED_STATE_ON;
 				mod_timer(&pLed->BlinkTimer, jiffies +
 					  msecs_to_jiffies(LED_BLINK_NO_LINK_INTERVAL_ALPHA));
 			}
@@ -388,24 +388,24 @@ static void SwLedBlink1(struct LED_871x *pLed)
 			pLed->bLedBlinkInProgress = false;
 		} else {
 			 if (pLed->bLedOn)
-				pLed->BlinkingLedState = LED_OFF;
+				pLed->BlinkingLedState = LED_STATE_OFF;
 			else
-				pLed->BlinkingLedState = LED_ON;
+				pLed->BlinkingLedState = LED_STATE_ON;
 			mod_timer(&pLed->BlinkTimer, jiffies +
 				  msecs_to_jiffies(LED_BLINK_FASTER_INTERVAL_ALPHA));
 		}
 		break;
 	case LED_BLINK_WPS:
 		if (pLed->bLedOn)
-			pLed->BlinkingLedState = LED_OFF;
+			pLed->BlinkingLedState = LED_STATE_OFF;
 		else
-			pLed->BlinkingLedState = LED_ON;
+			pLed->BlinkingLedState = LED_STATE_ON;
 		mod_timer(&pLed->BlinkTimer, jiffies +
 			  msecs_to_jiffies(LED_BLINK_SCAN_INTERVAL_ALPHA));
 		break;
 	case LED_BLINK_WPS_STOP:	/* WPS success */
-		if (pLed->BlinkingLedState == LED_ON) {
-			pLed->BlinkingLedState = LED_OFF;
+		if (pLed->BlinkingLedState == LED_STATE_ON) {
+			pLed->BlinkingLedState = LED_STATE_OFF;
 			mod_timer(&pLed->BlinkTimer, jiffies +
 				  msecs_to_jiffies(LED_BLINK_WPS_SUCESS_INTERVAL_ALPHA));
 			bStopBlinking = false;
@@ -416,9 +416,9 @@ static void SwLedBlink1(struct LED_871x *pLed)
 			pLed->bLedLinkBlinkInProgress = true;
 			pLed->CurrLedState = LED_BLINK_NORMAL;
 			if (pLed->bLedOn)
-				pLed->BlinkingLedState = LED_OFF;
+				pLed->BlinkingLedState = LED_STATE_OFF;
 			else
-				pLed->BlinkingLedState = LED_ON;
+				pLed->BlinkingLedState = LED_STATE_ON;
 			mod_timer(&pLed->BlinkTimer, jiffies +
 				  msecs_to_jiffies(LED_BLINK_LINK_INTERVAL_ALPHA));
 		}
@@ -436,7 +436,7 @@ static void SwLedBlink2(struct LED_871x *pLed)
 	u8 bStopBlinking = false;
 
 	/* Change LED according to BlinkingLedState specified. */
-	if (pLed->BlinkingLedState == LED_ON)
+	if (pLed->BlinkingLedState == LED_STATE_ON)
 		SwLedOn(padapter, pLed);
 	else
 		SwLedOff(padapter, pLed);
@@ -447,20 +447,20 @@ static void SwLedBlink2(struct LED_871x *pLed)
 			bStopBlinking = true;
 		if (bStopBlinking) {
 			if (check_fwstate(pmlmepriv, _FW_LINKED)) {
-				pLed->CurrLedState = LED_ON;
-				pLed->BlinkingLedState = LED_ON;
+				pLed->CurrLedState = LED_STATE_ON;
+				pLed->BlinkingLedState = LED_STATE_ON;
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
-				pLed->BlinkingLedState = LED_ON;
+				pLed->BlinkingLedState = LED_STATE_ON;
 			mod_timer(&pLed->BlinkTimer, jiffies +
 				  msecs_to_jiffies(LED_BLINK_SCAN_INTERVAL_ALPHA));
 		}
@@ -471,20 +471,20 @@ static void SwLedBlink2(struct LED_871x *pLed)
 			bStopBlinking = true;
 		if (bStopBlinking) {
 			if (check_fwstate(pmlmepriv, _FW_LINKED)) {
-				pLed->CurrLedState = LED_ON;
-				pLed->BlinkingLedState = LED_ON;
+				pLed->CurrLedState = LED_STATE_ON;
+				pLed->BlinkingLedState = LED_STATE_ON;
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
-				pLed->BlinkingLedState = LED_ON;
+				pLed->BlinkingLedState = LED_STATE_ON;
 			mod_timer(&pLed->BlinkTimer, jiffies +
 				  msecs_to_jiffies(LED_BLINK_FASTER_INTERVAL_ALPHA));
 		}
@@ -501,7 +501,7 @@ static void SwLedBlink3(struct LED_871x *pLed)
 	u8 bStopBlinking = false;
 
 	/* Change LED according to BlinkingLedState specified. */
-	if (pLed->BlinkingLedState == LED_ON)
+	if (pLed->BlinkingLedState == LED_STATE_ON)
 		SwLedOn(padapter, pLed);
 	else
 		if (pLed->CurrLedState != LED_BLINK_WPS_STOP)
@@ -513,22 +513,22 @@ static void SwLedBlink3(struct LED_871x *pLed)
 			bStopBlinking = true;
 		if (bStopBlinking) {
 			if (check_fwstate(pmlmepriv, _FW_LINKED)) {
-				pLed->CurrLedState = LED_ON;
-				pLed->BlinkingLedState = LED_ON;
+				pLed->CurrLedState = LED_STATE_ON;
+				pLed->BlinkingLedState = LED_STATE_ON;
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
-				pLed->BlinkingLedState = LED_ON;
+				pLed->BlinkingLedState = LED_STATE_ON;
 			mod_timer(&pLed->BlinkTimer, jiffies +
 				  msecs_to_jiffies(LED_BLINK_SCAN_INTERVAL_ALPHA));
 		}
@@ -539,37 +539,37 @@ static void SwLedBlink3(struct LED_871x *pLed)
 			bStopBlinking = true;
 		if (bStopBlinking) {
 			if (check_fwstate(pmlmepriv, _FW_LINKED)) {
-				pLed->CurrLedState = LED_ON;
-				pLed->BlinkingLedState = LED_ON;
+				pLed->CurrLedState = LED_STATE_ON;
+				pLed->BlinkingLedState = LED_STATE_ON;
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
-				pLed->BlinkingLedState = LED_ON;
+				pLed->BlinkingLedState = LED_STATE_ON;
 			mod_timer(&pLed->BlinkTimer, jiffies +
 				  msecs_to_jiffies(LED_BLINK_FASTER_INTERVAL_ALPHA));
 		}
 		break;
 	case LED_BLINK_WPS:
 		if (pLed->bLedOn)
-			pLed->BlinkingLedState = LED_OFF;
+			pLed->BlinkingLedState = LED_STATE_OFF;
 		else
-			pLed->BlinkingLedState = LED_ON;
+			pLed->BlinkingLedState = LED_STATE_ON;
 		mod_timer(&pLed->BlinkTimer, jiffies +
 			  msecs_to_jiffies(LED_BLINK_SCAN_INTERVAL_ALPHA));
 		break;
 	case LED_BLINK_WPS_STOP:	/*WPS success*/
-		if (pLed->BlinkingLedState == LED_ON) {
-			pLed->BlinkingLedState = LED_OFF;
+		if (pLed->BlinkingLedState == LED_STATE_ON) {
+			pLed->BlinkingLedState = LED_STATE_OFF;
 			mod_timer(&pLed->BlinkTimer, jiffies +
 				  msecs_to_jiffies(LED_BLINK_WPS_SUCESS_INTERVAL_ALPHA));
 			bStopBlinking = false;
@@ -577,8 +577,8 @@ static void SwLedBlink3(struct LED_871x *pLed)
 			bStopBlinking = true;
 		}
 		if (bStopBlinking) {
-			pLed->CurrLedState = LED_ON;
-			pLed->BlinkingLedState = LED_ON;
+			pLed->CurrLedState = LED_STATE_ON;
+			pLed->BlinkingLedState = LED_STATE_ON;
 			SwLedOn(padapter, pLed);
 			pLed->bLedWPSBlinkInProgress = false;
 		}
@@ -596,32 +596,32 @@ static void SwLedBlink4(struct LED_871x *pLed)
 	u8 bStopBlinking = false;
 
 	/* Change LED according to BlinkingLedState specified. */
-	if (pLed->BlinkingLedState == LED_ON)
+	if (pLed->BlinkingLedState == LED_STATE_ON)
 		SwLedOn(padapter, pLed);
 	else
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
-			pLed->BlinkingLedState = LED_ON;
+			pLed->BlinkingLedState = LED_STATE_ON;
 		mod_timer(&pLed->BlinkTimer, jiffies +
 			  msecs_to_jiffies(LED_BLINK_NO_LINK_INTERVAL_ALPHA));
 		break;
 	case LED_BLINK_StartToBlink:
 		if (pLed->bLedOn) {
-			pLed->BlinkingLedState = LED_OFF;
+			pLed->BlinkingLedState = LED_STATE_OFF;
 			mod_timer(&pLed->BlinkTimer, jiffies +
 				  msecs_to_jiffies(LED_BLINK_SLOWLY_INTERVAL));
 		} else {
-			pLed->BlinkingLedState = LED_ON;
+			pLed->BlinkingLedState = LED_STATE_ON;
 			mod_timer(&pLed->BlinkTimer, jiffies +
 				  msecs_to_jiffies(LED_BLINK_NORMAL_INTERVAL));
 		}
@@ -634,17 +634,17 @@ static void SwLedBlink4(struct LED_871x *pLed)
 			pLed->bLedNoLinkBlinkInProgress = true;
 			pLed->CurrLedState = LED_BLINK_SLOWLY;
 			if (pLed->bLedOn)
-				pLed->BlinkingLedState = LED_OFF;
+				pLed->BlinkingLedState = LED_STATE_OFF;
 			else
-				pLed->BlinkingLedState = LED_ON;
+				pLed->BlinkingLedState = LED_STATE_ON;
 			mod_timer(&pLed->BlinkTimer, jiffies +
 				  msecs_to_jiffies(LED_BLINK_NO_LINK_INTERVAL_ALPHA));
 			pLed->bLedScanBlinkInProgress = false;
 		} else {
 			if (pLed->bLedOn)
-				pLed->BlinkingLedState = LED_OFF;
+				pLed->BlinkingLedState = LED_STATE_OFF;
 			else
-				pLed->BlinkingLedState = LED_ON;
+				pLed->BlinkingLedState = LED_STATE_ON;
 			mod_timer(&pLed->BlinkTimer, jiffies +
 				  msecs_to_jiffies(LED_BLINK_SCAN_INTERVAL_ALPHA));
 		}
@@ -657,37 +657,37 @@ static void SwLedBlink4(struct LED_871x *pLed)
 			pLed->bLedNoLinkBlinkInProgress = true;
 			pLed->CurrLedState = LED_BLINK_SLOWLY;
 			if (pLed->bLedOn)
-				pLed->BlinkingLedState = LED_OFF;
+				pLed->BlinkingLedState = LED_STATE_OFF;
 			else
-				pLed->BlinkingLedState = LED_ON;
+				pLed->BlinkingLedState = LED_STATE_ON;
 			mod_timer(&pLed->BlinkTimer, jiffies +
 				  msecs_to_jiffies(LED_BLINK_NO_LINK_INTERVAL_ALPHA));
 			pLed->bLedBlinkInProgress = false;
 		} else {
 			 if (pLed->bLedOn)
-				pLed->BlinkingLedState = LED_OFF;
+				pLed->BlinkingLedState = LED_STATE_OFF;
 			else
-				pLed->BlinkingLedState = LED_ON;
+				pLed->BlinkingLedState = LED_STATE_ON;
 			mod_timer(&pLed->BlinkTimer, jiffies +
 				  msecs_to_jiffies(LED_BLINK_FASTER_INTERVAL_ALPHA));
 		}
 		break;
 	case LED_BLINK_WPS:
 		if (pLed->bLedOn) {
-			pLed->BlinkingLedState = LED_OFF;
+			pLed->BlinkingLedState = LED_STATE_OFF;
 			mod_timer(&pLed->BlinkTimer, jiffies +
 				  msecs_to_jiffies(LED_BLINK_SLOWLY_INTERVAL));
 		} else {
-			pLed->BlinkingLedState = LED_ON;
+			pLed->BlinkingLedState = LED_STATE_ON;
 			mod_timer(&pLed->BlinkTimer, jiffies +
 				  msecs_to_jiffies(LED_BLINK_NORMAL_INTERVAL));
 		}
 		break;
 	case LED_BLINK_WPS_STOP:	/*WPS authentication fail*/
 		if (pLed->bLedOn)
-			pLed->BlinkingLedState = LED_OFF;
+			pLed->BlinkingLedState = LED_STATE_OFF;
 		else
-			pLed->BlinkingLedState = LED_ON;
+			pLed->BlinkingLedState = LED_STATE_ON;
 		mod_timer(&pLed->BlinkTimer, jiffies +
 			  msecs_to_jiffies(LED_BLINK_NORMAL_INTERVAL));
 		break;
@@ -701,14 +701,14 @@ static void SwLedBlink4(struct LED_871x *pLed)
 		}
 		if (bStopBlinking) {
 			pLed->BlinkTimes = 10;
-			pLed->BlinkingLedState = LED_ON;
+			pLed->BlinkingLedState = LED_STATE_ON;
 			mod_timer(&pLed->BlinkTimer, jiffies +
 				  msecs_to_jiffies(LED_BLINK_LINK_INTERVAL_ALPHA));
 		} else {
 			if (pLed->bLedOn)
-				pLed->BlinkingLedState = LED_OFF;
+				pLed->BlinkingLedState = LED_STATE_OFF;
 			else
-				pLed->BlinkingLedState = LED_ON;
+				pLed->BlinkingLedState = LED_STATE_ON;
 			mod_timer(&pLed->BlinkTimer, jiffies +
 				  msecs_to_jiffies(LED_BLINK_NORMAL_INTERVAL));
 		}
@@ -724,7 +724,7 @@ static void SwLedBlink5(struct LED_871x *pLed)
 	u8 bStopBlinking = false;
 
 	/* Change LED according to BlinkingLedState specified. */
-	if (pLed->BlinkingLedState == LED_ON)
+	if (pLed->BlinkingLedState == LED_STATE_ON)
 		SwLedOn(padapter, pLed);
 	else
 		SwLedOff(padapter, pLed);
@@ -734,17 +734,17 @@ static void SwLedBlink5(struct LED_871x *pLed)
 		if (pLed->BlinkTimes == 0)
 			bStopBlinking = true;
 		if (bStopBlinking) {
-			pLed->CurrLedState = LED_ON;
-			pLed->BlinkingLedState = LED_ON;
+			pLed->CurrLedState = LED_STATE_ON;
+			pLed->BlinkingLedState = LED_STATE_ON;
 			if (!pLed->bLedOn)
 				mod_timer(&pLed->BlinkTimer, jiffies +
 					  msecs_to_jiffies(LED_BLINK_FASTER_INTERVAL_ALPHA));
 			pLed->bLedScanBlinkInProgress = false;
 		} else {
 			if (pLed->bLedOn)
-				pLed->BlinkingLedState = LED_OFF;
+				pLed->BlinkingLedState = LED_STATE_OFF;
 			else
-				pLed->BlinkingLedState = LED_ON;
+				pLed->BlinkingLedState = LED_STATE_ON;
 			mod_timer(&pLed->BlinkTimer, jiffies +
 				  msecs_to_jiffies(LED_BLINK_SCAN_INTERVAL_ALPHA));
 		}
@@ -754,17 +754,17 @@ static void SwLedBlink5(struct LED_871x *pLed)
 		if (pLed->BlinkTimes == 0)
 			bStopBlinking = true;
 		if (bStopBlinking) {
-			pLed->CurrLedState = LED_ON;
-			pLed->BlinkingLedState = LED_ON;
+			pLed->CurrLedState = LED_STATE_ON;
+			pLed->BlinkingLedState = LED_STATE_ON;
 			if (!pLed->bLedOn)
 				mod_timer(&pLed->BlinkTimer, jiffies +
 					  msecs_to_jiffies(LED_BLINK_FASTER_INTERVAL_ALPHA));
 			pLed->bLedBlinkInProgress = false;
 		} else {
 			 if (pLed->bLedOn)
-				pLed->BlinkingLedState = LED_OFF;
+				pLed->BlinkingLedState = LED_STATE_OFF;
 			else
-				pLed->BlinkingLedState = LED_ON;
+				pLed->BlinkingLedState = LED_STATE_ON;
 			mod_timer(&pLed->BlinkTimer, jiffies +
 				  msecs_to_jiffies(LED_BLINK_FASTER_INTERVAL_ALPHA));
 		}
@@ -780,7 +780,7 @@ static void SwLedBlink6(struct LED_871x *pLed)
 	u8 bStopBlinking = false;
 
 	/* Change LED according to BlinkingLedState specified. */
-	if (pLed->BlinkingLedState == LED_ON)
+	if (pLed->BlinkingLedState == LED_STATE_ON)
 		SwLedOn(padapter, pLed);
 	else
 		SwLedOff(padapter, pLed);
@@ -790,25 +790,25 @@ static void SwLedBlink6(struct LED_871x *pLed)
 		if (pLed->BlinkTimes == 0)
 			bStopBlinking = true;
 		if (bStopBlinking) {
-			pLed->CurrLedState = LED_ON;
-			pLed->BlinkingLedState = LED_ON;
+			pLed->CurrLedState = LED_STATE_ON;
+			pLed->BlinkingLedState = LED_STATE_ON;
 			if (!pLed->bLedOn)
 				SwLedOn(padapter, pLed);
 			pLed->bLedBlinkInProgress = false;
 		} else {
 			if (pLed->bLedOn)
-				pLed->BlinkingLedState = LED_OFF;
+				pLed->BlinkingLedState = LED_STATE_OFF;
 			else
-				pLed->BlinkingLedState = LED_ON;
+				pLed->BlinkingLedState = LED_STATE_ON;
 			mod_timer(&pLed->BlinkTimer, jiffies +
 				  msecs_to_jiffies(LED_BLINK_FASTER_INTERVAL_ALPHA));
 		}
 		break;
 	case LED_BLINK_WPS:
 		if (pLed->bLedOn)
-			pLed->BlinkingLedState = LED_OFF;
+			pLed->BlinkingLedState = LED_STATE_OFF;
 		else
-			pLed->BlinkingLedState = LED_ON;
+			pLed->BlinkingLedState = LED_STATE_ON;
 		mod_timer(&pLed->BlinkTimer, jiffies +
 			  msecs_to_jiffies(LED_BLINK_SCAN_INTERVAL_ALPHA));
 		break;
@@ -908,9 +908,9 @@ static void SwLedControlMode1(struct _adapter *padapter,
 			pLed->bLedNoLinkBlinkInProgress = true;
 			pLed->CurrLedState = LED_BLINK_SLOWLY;
 			if (pLed->bLedOn)
-				pLed->BlinkingLedState = LED_OFF;
+				pLed->BlinkingLedState = LED_STATE_OFF;
 			else
-				pLed->BlinkingLedState = LED_ON;
+				pLed->BlinkingLedState = LED_STATE_ON;
 			mod_timer(&pLed->BlinkTimer, jiffies +
 				  msecs_to_jiffies(LED_BLINK_NO_LINK_INTERVAL_ALPHA));
 		}
@@ -931,9 +931,9 @@ static void SwLedControlMode1(struct _adapter *padapter,
 			pLed->bLedLinkBlinkInProgress = true;
 			pLed->CurrLedState = LED_BLINK_NORMAL;
 			if (pLed->bLedOn)
-				pLed->BlinkingLedState = LED_OFF;
+				pLed->BlinkingLedState = LED_STATE_OFF;
 			else
-				pLed->BlinkingLedState = LED_ON;
+				pLed->BlinkingLedState = LED_STATE_ON;
 			mod_timer(&pLed->BlinkTimer, jiffies +
 				  msecs_to_jiffies(LED_BLINK_LINK_INTERVAL_ALPHA));
 		}
@@ -961,9 +961,9 @@ static void SwLedControlMode1(struct _adapter *padapter,
 			pLed->CurrLedState = LED_SCAN_BLINK;
 			pLed->BlinkTimes = 24;
 			if (pLed->bLedOn)
-				pLed->BlinkingLedState = LED_OFF;
+				pLed->BlinkingLedState = LED_STATE_OFF;
 			else
-				pLed->BlinkingLedState = LED_ON;
+				pLed->BlinkingLedState = LED_STATE_ON;
 			mod_timer(&pLed->BlinkTimer, jiffies +
 				  msecs_to_jiffies(LED_BLINK_SCAN_INTERVAL_ALPHA));
 		 }
@@ -986,9 +986,9 @@ static void SwLedControlMode1(struct _adapter *padapter,
 			pLed->CurrLedState = LED_TXRX_BLINK;
 			pLed->BlinkTimes = 2;
 			if (pLed->bLedOn)
-				pLed->BlinkingLedState = LED_OFF;
+				pLed->BlinkingLedState = LED_STATE_OFF;
 			else
-				pLed->BlinkingLedState = LED_ON;
+				pLed->BlinkingLedState = LED_STATE_ON;
 			mod_timer(&pLed->BlinkTimer, jiffies +
 				  msecs_to_jiffies(LED_BLINK_FASTER_INTERVAL_ALPHA));
 		}
@@ -1016,9 +1016,9 @@ static void SwLedControlMode1(struct _adapter *padapter,
 			pLed->bLedWPSBlinkInProgress = true;
 			pLed->CurrLedState = LED_BLINK_WPS;
 			if (pLed->bLedOn)
-				pLed->BlinkingLedState = LED_OFF;
+				pLed->BlinkingLedState = LED_STATE_OFF;
 			else
-				pLed->BlinkingLedState = LED_ON;
+				pLed->BlinkingLedState = LED_STATE_ON;
 			mod_timer(&pLed->BlinkTimer, jiffies +
 				  msecs_to_jiffies(LED_BLINK_SCAN_INTERVAL_ALPHA));
 		}
@@ -1046,11 +1046,11 @@ static void SwLedControlMode1(struct _adapter *padapter,
 			pLed->bLedWPSBlinkInProgress = true;
 		pLed->CurrLedState = LED_BLINK_WPS_STOP;
 		if (pLed->bLedOn) {
-			pLed->BlinkingLedState = LED_OFF;
+			pLed->BlinkingLedState = LED_STATE_OFF;
 			mod_timer(&pLed->BlinkTimer, jiffies +
 				  msecs_to_jiffies(LED_BLINK_WPS_SUCESS_INTERVAL_ALPHA));
 		} else {
-			pLed->BlinkingLedState = LED_ON;
+			pLed->BlinkingLedState = LED_STATE_ON;
 			mod_timer(&pLed->BlinkTimer,
 				  jiffies + msecs_to_jiffies(0));
 		}
@@ -1063,15 +1063,15 @@ static void SwLedControlMode1(struct _adapter *padapter,
 		pLed->bLedNoLinkBlinkInProgress = true;
 		pLed->CurrLedState = LED_BLINK_SLOWLY;
 		if (pLed->bLedOn)
-			pLed->BlinkingLedState = LED_OFF;
+			pLed->BlinkingLedState = LED_STATE_OFF;
 		else
-			pLed->BlinkingLedState = LED_ON;
+			pLed->BlinkingLedState = LED_STATE_ON;
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
@@ -1123,9 +1123,9 @@ static void SwLedControlMode2(struct _adapter *padapter,
 			pLed->CurrLedState = LED_SCAN_BLINK;
 			pLed->BlinkTimes = 24;
 			if (pLed->bLedOn)
-				pLed->BlinkingLedState = LED_OFF;
+				pLed->BlinkingLedState = LED_STATE_OFF;
 			else
-				pLed->BlinkingLedState = LED_ON;
+				pLed->BlinkingLedState = LED_STATE_ON;
 			mod_timer(&pLed->BlinkTimer, jiffies +
 				  msecs_to_jiffies(LED_BLINK_SCAN_INTERVAL_ALPHA));
 		 }
@@ -1142,17 +1142,17 @@ static void SwLedControlMode2(struct _adapter *padapter,
 			pLed->CurrLedState = LED_TXRX_BLINK;
 			pLed->BlinkTimes = 2;
 			if (pLed->bLedOn)
-				pLed->BlinkingLedState = LED_OFF;
+				pLed->BlinkingLedState = LED_STATE_OFF;
 			else
-				pLed->BlinkingLedState = LED_ON;
+				pLed->BlinkingLedState = LED_STATE_ON;
 			mod_timer(&pLed->BlinkTimer, jiffies +
 				  msecs_to_jiffies(LED_BLINK_FASTER_INTERVAL_ALPHA));
 		}
 		break;
 
 	case LED_CTL_LINK:
-		pLed->CurrLedState = LED_ON;
-		pLed->BlinkingLedState = LED_ON;
+		pLed->CurrLedState = LED_STATE_ON;
+		pLed->BlinkingLedState = LED_STATE_ON;
 		if (pLed->bLedBlinkInProgress) {
 			del_timer(&pLed->BlinkTimer);
 			pLed->bLedBlinkInProgress = false;
@@ -1178,8 +1178,8 @@ static void SwLedControlMode2(struct _adapter *padapter,
 				pLed->bLedScanBlinkInProgress = false;
 			}
 			pLed->bLedWPSBlinkInProgress = true;
-			pLed->CurrLedState = LED_ON;
-			pLed->BlinkingLedState = LED_ON;
+			pLed->CurrLedState = LED_STATE_ON;
+			pLed->BlinkingLedState = LED_STATE_ON;
 			mod_timer(&pLed->BlinkTimer,
 				  jiffies + msecs_to_jiffies(0));
 		 }
@@ -1187,16 +1187,16 @@ static void SwLedControlMode2(struct _adapter *padapter,
 
 	case LED_CTL_STOP_WPS:
 		pLed->bLedWPSBlinkInProgress = false;
-		pLed->CurrLedState = LED_ON;
-		pLed->BlinkingLedState = LED_ON;
+		pLed->CurrLedState = LED_STATE_ON;
+		pLed->BlinkingLedState = LED_STATE_ON;
 		mod_timer(&pLed->BlinkTimer,
 			  jiffies + msecs_to_jiffies(0));
 		break;
 
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
@@ -1255,9 +1255,9 @@ static void SwLedControlMode3(struct _adapter *padapter,
 			pLed->CurrLedState = LED_SCAN_BLINK;
 			pLed->BlinkTimes = 24;
 			if (pLed->bLedOn)
-				pLed->BlinkingLedState = LED_OFF;
+				pLed->BlinkingLedState = LED_STATE_OFF;
 			else
-				pLed->BlinkingLedState = LED_ON;
+				pLed->BlinkingLedState = LED_STATE_ON;
 			mod_timer(&pLed->BlinkTimer, jiffies +
 				  msecs_to_jiffies(LED_BLINK_SCAN_INTERVAL_ALPHA));
 		}
@@ -1273,9 +1273,9 @@ static void SwLedControlMode3(struct _adapter *padapter,
 			pLed->CurrLedState = LED_TXRX_BLINK;
 			pLed->BlinkTimes = 2;
 			if (pLed->bLedOn)
-				pLed->BlinkingLedState = LED_OFF;
+				pLed->BlinkingLedState = LED_STATE_OFF;
 			else
-				pLed->BlinkingLedState = LED_ON;
+				pLed->BlinkingLedState = LED_STATE_ON;
 			mod_timer(&pLed->BlinkTimer, jiffies +
 				  msecs_to_jiffies(LED_BLINK_FASTER_INTERVAL_ALPHA));
 		}
@@ -1283,8 +1283,8 @@ static void SwLedControlMode3(struct _adapter *padapter,
 	case LED_CTL_LINK:
 		if (IS_LED_WPS_BLINKING(pLed))
 			return;
-		pLed->CurrLedState = LED_ON;
-		pLed->BlinkingLedState = LED_ON;
+		pLed->CurrLedState = LED_STATE_ON;
+		pLed->BlinkingLedState = LED_STATE_ON;
 		if (pLed->bLedBlinkInProgress) {
 			del_timer(&pLed->BlinkTimer);
 			pLed->bLedBlinkInProgress = false;
@@ -1310,9 +1310,9 @@ static void SwLedControlMode3(struct _adapter *padapter,
 			pLed->bLedWPSBlinkInProgress = true;
 			pLed->CurrLedState = LED_BLINK_WPS;
 			if (pLed->bLedOn)
-				pLed->BlinkingLedState = LED_OFF;
+				pLed->BlinkingLedState = LED_STATE_OFF;
 			else
-				pLed->BlinkingLedState = LED_ON;
+				pLed->BlinkingLedState = LED_STATE_ON;
 			mod_timer(&pLed->BlinkTimer, jiffies +
 				  msecs_to_jiffies(LED_BLINK_SCAN_INTERVAL_ALPHA));
 		}
@@ -1326,11 +1326,11 @@ static void SwLedControlMode3(struct _adapter *padapter,
 		}
 		pLed->CurrLedState = LED_BLINK_WPS_STOP;
 		if (pLed->bLedOn) {
-			pLed->BlinkingLedState = LED_OFF;
+			pLed->BlinkingLedState = LED_STATE_OFF;
 			mod_timer(&pLed->BlinkTimer, jiffies +
 				  msecs_to_jiffies(LED_BLINK_WPS_SUCESS_INTERVAL_ALPHA));
 		} else {
-			pLed->BlinkingLedState = LED_ON;
+			pLed->BlinkingLedState = LED_STATE_ON;
 			mod_timer(&pLed->BlinkTimer,
 				  jiffies + msecs_to_jiffies(0));
 		}
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
@@ -1411,11 +1411,11 @@ static void SwLedControlMode4(struct _adapter *padapter,
 			pLed->bLedStartToLinkBlinkInProgress = true;
 			pLed->CurrLedState = LED_BLINK_StartToBlink;
 			if (pLed->bLedOn) {
-				pLed->BlinkingLedState = LED_OFF;
+				pLed->BlinkingLedState = LED_STATE_OFF;
 				mod_timer(&pLed->BlinkTimer, jiffies +
 					  msecs_to_jiffies(LED_BLINK_SLOWLY_INTERVAL));
 			} else {
-				pLed->BlinkingLedState = LED_ON;
+				pLed->BlinkingLedState = LED_STATE_ON;
 				mod_timer(&pLed->BlinkTimer, jiffies +
 					  msecs_to_jiffies(LED_BLINK_NORMAL_INTERVAL));
 			}
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
@@ -1446,9 +1446,9 @@ static void SwLedControlMode4(struct _adapter *padapter,
 			pLed->bLedNoLinkBlinkInProgress = true;
 			pLed->CurrLedState = LED_BLINK_SLOWLY;
 			if (pLed->bLedOn)
-				pLed->BlinkingLedState = LED_OFF;
+				pLed->BlinkingLedState = LED_STATE_OFF;
 			else
-				pLed->BlinkingLedState = LED_ON;
+				pLed->BlinkingLedState = LED_STATE_ON;
 			mod_timer(&pLed->BlinkTimer, jiffies +
 				  msecs_to_jiffies(LED_BLINK_NO_LINK_INTERVAL_ALPHA));
 		}
@@ -1472,9 +1472,9 @@ static void SwLedControlMode4(struct _adapter *padapter,
 			pLed->CurrLedState = LED_SCAN_BLINK;
 			pLed->BlinkTimes = 24;
 			if (pLed->bLedOn)
-				pLed->BlinkingLedState = LED_OFF;
+				pLed->BlinkingLedState = LED_STATE_OFF;
 			else
-				pLed->BlinkingLedState = LED_ON;
+				pLed->BlinkingLedState = LED_STATE_ON;
 			mod_timer(&pLed->BlinkTimer, jiffies +
 				  msecs_to_jiffies(LED_BLINK_SCAN_INTERVAL_ALPHA));
 		}
@@ -1493,9 +1493,9 @@ static void SwLedControlMode4(struct _adapter *padapter,
 			pLed->CurrLedState = LED_TXRX_BLINK;
 			pLed->BlinkTimes = 2;
 			if (pLed->bLedOn)
-				pLed->BlinkingLedState = LED_OFF;
+				pLed->BlinkingLedState = LED_STATE_OFF;
 			else
-				pLed->BlinkingLedState = LED_ON;
+				pLed->BlinkingLedState = LED_STATE_ON;
 			mod_timer(&pLed->BlinkTimer, jiffies +
 				  msecs_to_jiffies(LED_BLINK_FASTER_INTERVAL_ALPHA));
 		}
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
@@ -1527,11 +1527,11 @@ static void SwLedControlMode4(struct _adapter *padapter,
 			pLed->bLedWPSBlinkInProgress = true;
 			pLed->CurrLedState = LED_BLINK_WPS;
 			if (pLed->bLedOn) {
-				pLed->BlinkingLedState = LED_OFF;
+				pLed->BlinkingLedState = LED_STATE_OFF;
 				mod_timer(&pLed->BlinkTimer, jiffies +
 					  msecs_to_jiffies(LED_BLINK_SLOWLY_INTERVAL));
 			} else {
-				pLed->BlinkingLedState = LED_ON;
+				pLed->BlinkingLedState = LED_STATE_ON;
 				mod_timer(&pLed->BlinkTimer, jiffies +
 					  msecs_to_jiffies(LED_BLINK_NORMAL_INTERVAL));
 			}
@@ -1545,9 +1545,9 @@ static void SwLedControlMode4(struct _adapter *padapter,
 		pLed->bLedNoLinkBlinkInProgress = true;
 		pLed->CurrLedState = LED_BLINK_SLOWLY;
 		if (pLed->bLedOn)
-			pLed->BlinkingLedState = LED_OFF;
+			pLed->BlinkingLedState = LED_STATE_OFF;
 		else
-			pLed->BlinkingLedState = LED_ON;
+			pLed->BlinkingLedState = LED_STATE_ON;
 		mod_timer(&pLed->BlinkTimer, jiffies +
 			  msecs_to_jiffies(LED_BLINK_NO_LINK_INTERVAL_ALPHA));
 		break;
@@ -1559,9 +1559,9 @@ static void SwLedControlMode4(struct _adapter *padapter,
 		pLed->bLedNoLinkBlinkInProgress = true;
 		pLed->CurrLedState = LED_BLINK_SLOWLY;
 		if (pLed->bLedOn)
-			pLed->BlinkingLedState = LED_OFF;
+			pLed->BlinkingLedState = LED_STATE_OFF;
 		else
-			pLed->BlinkingLedState = LED_ON;
+			pLed->BlinkingLedState = LED_STATE_ON;
 		mod_timer(&pLed->BlinkTimer, jiffies +
 			  msecs_to_jiffies(LED_BLINK_NO_LINK_INTERVAL_ALPHA));
 		/*LED1 settings*/
@@ -1571,9 +1571,9 @@ static void SwLedControlMode4(struct _adapter *padapter,
 			pLed1->bLedWPSBlinkInProgress = true;
 		pLed1->CurrLedState = LED_BLINK_WPS_STOP;
 		if (pLed1->bLedOn)
-			pLed1->BlinkingLedState = LED_OFF;
+			pLed1->BlinkingLedState = LED_STATE_OFF;
 		else
-			pLed1->BlinkingLedState = LED_ON;
+			pLed1->BlinkingLedState = LED_STATE_ON;
 		mod_timer(&pLed->BlinkTimer, jiffies +
 			  msecs_to_jiffies(LED_BLINK_NORMAL_INTERVAL));
 		break;
@@ -1585,9 +1585,9 @@ static void SwLedControlMode4(struct _adapter *padapter,
 		pLed->bLedNoLinkBlinkInProgress = true;
 		pLed->CurrLedState = LED_BLINK_SLOWLY;
 		if (pLed->bLedOn)
-			pLed->BlinkingLedState = LED_OFF;
+			pLed->BlinkingLedState = LED_STATE_OFF;
 		else
-			pLed->BlinkingLedState = LED_ON;
+			pLed->BlinkingLedState = LED_STATE_ON;
 		mod_timer(&pLed->BlinkTimer, jiffies +
 			  msecs_to_jiffies(LED_BLINK_NO_LINK_INTERVAL_ALPHA));
 		/*LED1 settings*/
@@ -1598,15 +1598,15 @@ static void SwLedControlMode4(struct _adapter *padapter,
 		pLed1->CurrLedState = LED_BLINK_WPS_STOP_OVERLAP;
 		pLed1->BlinkTimes = 10;
 		if (pLed1->bLedOn)
-			pLed1->BlinkingLedState = LED_OFF;
+			pLed1->BlinkingLedState = LED_STATE_OFF;
 		else
-			pLed1->BlinkingLedState = LED_ON;
+			pLed1->BlinkingLedState = LED_STATE_ON;
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
@@ -1660,8 +1660,8 @@ static void SwLedControlMode5(struct _adapter *padapter,
 	case LED_CTL_LINK:	/* solid blue */
 		if (pLed->CurrLedState == LED_SCAN_BLINK)
 			return;
-		pLed->CurrLedState = LED_ON;
-		pLed->BlinkingLedState = LED_ON;
+		pLed->CurrLedState = LED_STATE_ON;
+		pLed->BlinkingLedState = LED_STATE_ON;
 		pLed->bLedBlinkInProgress = false;
 		mod_timer(&pLed->BlinkTimer,
 			  jiffies + msecs_to_jiffies(0));
@@ -1679,9 +1679,9 @@ static void SwLedControlMode5(struct _adapter *padapter,
 			pLed->CurrLedState = LED_SCAN_BLINK;
 			pLed->BlinkTimes = 24;
 			if (pLed->bLedOn)
-				pLed->BlinkingLedState = LED_OFF;
+				pLed->BlinkingLedState = LED_STATE_OFF;
 			else
-				pLed->BlinkingLedState = LED_ON;
+				pLed->BlinkingLedState = LED_STATE_ON;
 			mod_timer(&pLed->BlinkTimer, jiffies +
 				  msecs_to_jiffies(LED_BLINK_SCAN_INTERVAL_ALPHA));
 		}
@@ -1695,16 +1695,16 @@ static void SwLedControlMode5(struct _adapter *padapter,
 			pLed->CurrLedState = LED_TXRX_BLINK;
 			pLed->BlinkTimes = 2;
 			if (pLed->bLedOn)
-				pLed->BlinkingLedState = LED_OFF;
+				pLed->BlinkingLedState = LED_STATE_OFF;
 			else
-				pLed->BlinkingLedState = LED_ON;
+				pLed->BlinkingLedState = LED_STATE_ON;
 			mod_timer(&pLed->BlinkTimer, jiffies +
 				  msecs_to_jiffies(LED_BLINK_FASTER_INTERVAL_ALPHA));
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
@@ -1731,8 +1731,8 @@ static void SwLedControlMode6(struct _adapter *padapter,
 	case LED_CTL_SITE_SURVEY:
 		if (IS_LED_WPS_BLINKING(pLed))
 				return;
-		pLed->CurrLedState = LED_ON;
-		pLed->BlinkingLedState = LED_ON;
+		pLed->CurrLedState = LED_STATE_ON;
+		pLed->BlinkingLedState = LED_STATE_ON;
 		pLed->bLedBlinkInProgress = false;
 		mod_timer(&(pLed->BlinkTimer), jiffies + msecs_to_jiffies(0));
 		break;
@@ -1746,9 +1746,9 @@ static void SwLedControlMode6(struct _adapter *padapter,
 			pLed->CurrLedState = LED_TXRX_BLINK;
 			pLed->BlinkTimes = 2;
 			if (pLed->bLedOn)
-				pLed->BlinkingLedState = LED_OFF;
+				pLed->BlinkingLedState = LED_STATE_OFF;
 			else
-				pLed->BlinkingLedState = LED_ON;
+				pLed->BlinkingLedState = LED_STATE_ON;
 			mod_timer(&pLed->BlinkTimer, jiffies +
 				  msecs_to_jiffies(LED_BLINK_FASTER_INTERVAL_ALPHA));
 		}
@@ -1763,9 +1763,9 @@ static void SwLedControlMode6(struct _adapter *padapter,
 			pLed->bLedWPSBlinkInProgress = true;
 			pLed->CurrLedState = LED_BLINK_WPS;
 			if (pLed->bLedOn)
-				pLed->BlinkingLedState = LED_OFF;
+				pLed->BlinkingLedState = LED_STATE_OFF;
 			else
-				pLed->BlinkingLedState = LED_ON;
+				pLed->BlinkingLedState = LED_STATE_ON;
 			mod_timer(&pLed->BlinkTimer, jiffies +
 				  msecs_to_jiffies(LED_BLINK_SCAN_INTERVAL_ALPHA));
 		}
@@ -1776,14 +1776,14 @@ static void SwLedControlMode6(struct _adapter *padapter,
 			del_timer(&pLed->BlinkTimer);
 			pLed->bLedWPSBlinkInProgress = false;
 		}
-		pLed->CurrLedState = LED_ON;
-		pLed->BlinkingLedState = LED_ON;
+		pLed->CurrLedState = LED_STATE_ON;
+		pLed->BlinkingLedState = LED_STATE_ON;
 		mod_timer(&pLed->BlinkTimer,
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
