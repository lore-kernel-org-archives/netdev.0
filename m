From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 5/8] d80211/bcm43xx: Modify bcm43xx_main.c for wireless statistics.
Date: Tue, 08 Aug 2006 18:59:38 -0500
Message-ID: <44D9256A.6020304@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtiwmhc12.worldnet.att.net ([204.127.131.116]:34974 "EHLO
	mtiwmhc12.worldnet.att.net") by vger.kernel.org with ESMTP
	id S1030351AbWHHX7k (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Aug 2006 19:59:40 -0400
To: John Linville <linville@tuxdriver.com>, netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Part 5 of 8 to add wireless statistics to the bcm43xx-d80211 system.
This patch removes the bogus calculation of link_quality and saves the
value of link_noise in the new variable bcm->stats.link_noise.



The patch is for the August 8 version of Linville's wireless-dev tree.

Signed-Off-By: Larry Finger <Larry.Finger@lwfinger.net>



diff --git a/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c
b/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c
index 59d137b..d712544 100644
--- a/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c
+++ b/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c
@@ -1506,15 +1506,7 @@ static void handle_irq_noise(struct bcm4
  		else
  			average -= 48;

-		if (average > -65)
-			bcm->stats.link_quality = 0;
-		else if (average > -75)
-			bcm->stats.link_quality = 1;
-		else if (average > -85)
-			bcm->stats.link_quality = 2;
-		else
-			bcm->stats.link_quality = 3;
-//		dprintk(KERN_INFO PFX "Link Quality: %u (avg was %d)\n", bcm->stats.link_quality, average);
+		bcm->stats.link_noise = average;
  drop_calculation:
  		bcm->noisecalc.calculation_running = 0;
  		return;


