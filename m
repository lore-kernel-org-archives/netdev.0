From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: netdev tx timeouts
Date: Tue, 12 Sep 2006 21:25:04 -0500
Message-ID: <45076C00.2000100@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Stefano Brivio <st3-sGOZH3hwPm2sTnJN9+BGXg@public.gmane.org>,
	Bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Return-path: <bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
To: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
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

Michael,

I still have not gotten a network guru to answer any questions about 
synchronize_net, but I have been testing the patch below:

Index: wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_main.c
===================================================================
--- wireless-2.6.orig/drivers/net/wireless/bcm43xx/bcm43xx_main.c
+++ wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_main.c
@@ -3169,8 +3169,8 @@ static void bcm43xx_periodic_work_handle
  		 * be preemtible.
  		 */
  		mutex_lock(&bcm->mutex);
-		netif_stop_queue(bcm->net_dev);
  		synchronize_net();
+		netif_stop_queue(bcm->net_dev);
  		spin_lock_irqsave(&bcm->irq_lock, flags);
  		bcm43xx_mac_suspend(bcm);
  		if (bcm43xx_using_pio(bcm))

With the synchronize_net call before the netif_stop_queue as shown, my device 
has run since last Saturday with no netdev watchdog tx timeouts. Roughly two 
days of that testing was done at the accelerated rate of 60X normal.

I still hope to get access to a guru, but if that doesn't happen soon, I'm going 
to push this change so that it gets into 2.6.19.

Larry
