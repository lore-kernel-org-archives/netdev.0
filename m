From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 6/7][TG3]: Use msleep.
Date: Wed, 06 Dec 2006 23:47:17 -0800
Message-ID: <1165477637.8488.32.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3248 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1031750AbWLGG5L (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Dec 2006 01:57:11 -0500
To: davem@davemloft.net, netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[TG3]: Use msleep.

Change some udelay() in some eeprom functions to msleep().  Eeprom
related functions are always called from sleepable context.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 99fb4e4..61e9533 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -9467,16 +9467,12 @@ static void __devinit tg3_get_5906_nvram
 /* Chips other than 5700/5701 use the NVRAM for fetching info. */
 static void __devinit tg3_nvram_init(struct tg3 *tp)
 {
-	int j;
-
 	tw32_f(GRC_EEPROM_ADDR,
 	     (EEPROM_ADDR_FSM_RESET |
 	      (EEPROM_DEFAULT_CLOCK_PERIOD <<
 	       EEPROM_ADDR_CLKPERD_SHIFT)));
 
-	/* XXX schedule_timeout() ... */
-	for (j = 0; j < 100; j++)
-		udelay(10);
+	msleep(1);
 
 	/* Enable seeprom accesses. */
 	tw32_f(GRC_LOCAL_CTRL,
@@ -9537,12 +9533,12 @@ static int tg3_nvram_read_using_eeprom(s
 	      EEPROM_ADDR_ADDR_MASK) |
 	     EEPROM_ADDR_READ | EEPROM_ADDR_START);
 
-	for (i = 0; i < 10000; i++) {
+	for (i = 0; i < 1000; i++) {
 		tmp = tr32(GRC_EEPROM_ADDR);
 
 		if (tmp & EEPROM_ADDR_COMPLETE)
 			break;
-		udelay(100);
+		msleep(1);
 	}
 	if (!(tmp & EEPROM_ADDR_COMPLETE))
 		return -EBUSY;
@@ -9667,12 +9663,12 @@ static int tg3_nvram_write_block_using_e
 			EEPROM_ADDR_START |
 			EEPROM_ADDR_WRITE);
 
-		for (j = 0; j < 10000; j++) {
+		for (j = 0; j < 1000; j++) {
 			val = tr32(GRC_EEPROM_ADDR);
 
 			if (val & EEPROM_ADDR_COMPLETE)
 				break;
-			udelay(100);
+			msleep(1);
 		}
 		if (!(val & EEPROM_ADDR_COMPLETE)) {
 			rc = -EBUSY;


