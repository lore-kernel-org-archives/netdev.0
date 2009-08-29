From: Mike McCormack <mikem@ring3k.org>
Subject: [PATCH] sky2: Don't try to turn led off in sky2_down()
Date: Sat, 29 Aug 2009 22:10:33 +0900
Message-ID: <4A9928C9.7000907@ring3k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Rene Mayrhofer <rene.mayrhofer@gibraltar.at>,
	Richard Leitner <leitner@esys.at>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f204.google.com ([209.85.223.204]:41517 "EHLO
	mail-iw0-f204.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751436AbZH2NOa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Aug 2009 09:14:30 -0400
Received: by iwn42 with SMTP id 42so1232737iwn.33
        for <netdev@vger.kernel.org>; Sat, 29 Aug 2009 06:14:32 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are a few problems with the following line of code in sky2_down()

     sky2_write16(hw, B0_Y2LED, LED_STAT_OFF);

 * It doesn't specify which port's LED to turn off.
 * We don't turn send LED_STAT_ON on in sky2_up()
 * B0_LED is 0x0006 in the vendor driver, but 0x0005 in sky2.
   B0_LED is right next to B0_POWER_CTRL, so this is possibly
   accounts for the device being accidently powered down as
   reported by Rene Mayrhofer.

Signed-off-by: Mike McCormack <mikem@ring3k.org>
---
 drivers/net/sky2.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index dd630cf..aec8ad3 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -1866,9 +1866,6 @@ static int sky2_down(struct net_device *dev)
 	sky2_phy_power_down(hw, port);
 	spin_unlock_bh(&sky2->phy_lock);
 
-	/* turn off LED's */
-	sky2_write16(hw, B0_Y2LED, LED_STAT_OFF);
-
 	sky2_tx_reset(hw, port);
 
 	/* Free any pending frames stuck in HW queue */
-- 
1.5.6.5


