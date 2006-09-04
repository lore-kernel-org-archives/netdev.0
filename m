From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: [PATCH V2] remove dead code from bcm43xx-softmac
Date: Mon, 04 Sep 2006 08:20:08 -0500
Message-ID: <44FC2808.2080308@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Stefano Brivio <st3-sGOZH3hwPm2sTnJN9+BGXg@public.gmane.org>,
	Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>, Bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Return-path: <bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
To: John Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/bcm43xx-dev>
List-Post: <mailto:bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

John,

Please queue the following patch for wireless-2.6. It removes some code that was made obsolete by
the wireless statistics changes of several weeks ago, but was not noticed them.

Thanks,

Larry

=================

This patch removes code that was make obsolete when the wireless statistics in bcm43xx-softmac were
changed, but was overlooked at that time. The value of bcm->stats.link_quality computed here is
never used, so it is removed as well.

Signed-off-by: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>

Index: wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_main.c
===================================================================
--- wireless-2.6.orig/drivers/net/wireless/bcm43xx/bcm43xx_main.c
+++ wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_main.c
@@ -1549,17 +1549,7 @@ static void handle_irq_noise(struct bcm4
  		else
  			average -= 48;

-/* FIXME: This is wrong, but people want fancy stats. well... */
-bcm->stats.noise = average;
-		if (average > -65)
-			bcm->stats.link_quality = 0;
-		else if (average > -75)
-			bcm->stats.link_quality = 1;
-		else if (average > -85)
-			bcm->stats.link_quality = 2;
-		else
-			bcm->stats.link_quality = 3;
-//		dprintk(KERN_INFO PFX "Link Quality: %u (avg was %d)\n", bcm->stats.link_quality, average);
+		bcm->stats.noise = average;
  drop_calculation:
  		bcm->noisecalc.calculation_running = 0;
  		return;
Index: wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx.h
===================================================================
--- wireless-2.6.orig/drivers/net/wireless/bcm43xx/bcm43xx.h
+++ wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx.h
@@ -688,7 +688,6 @@ struct bcm43xx_noise_calculation {
  };

  struct bcm43xx_stats {
-	u8 link_quality;
  	u8 noise;
  	struct iw_statistics wstats;
  	/* Store the last TX/RX times here for updating the leds. */
