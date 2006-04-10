From: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Subject: [PATCH] bcm43xx-d80211: protect tx_stat callback from uninitialized device
Date: Mon, 10 Apr 2006 02:25:00 +0200
Message-ID: <200604100225.01548.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, jbenc-AlSwsSmVLrQ@public.gmane.org
Return-path: <bcm43xx-dev-admin-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Content-Disposition: inline
Sender: bcm43xx-dev-admin-tdrK/OAtAx2ELgA04lAiVw@public.gmane.org
Errors-To: bcm43xx-dev-admin-tdrK/OAtAx2ELgA04lAiVw@public.gmane.org
List-Help: <mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Post: <mailto:bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Subscribe: <http://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
List-Unsubscribe: <http://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.berlios.de/pipermail/bcm43xx-dev/>
List-Id: netdev.vger.kernel.org

diff --git a/drivers/net/wireless/bcm43xx-d80211/bcm43xx_main.c b/drivers/net/wireless/bcm43xx-d80211/bcm43xx_main.c
index 043a5cf..f0f4f78 100644
--- a/drivers/net/wireless/bcm43xx-d80211/bcm43xx_main.c
+++ b/drivers/net/wireless/bcm43xx-d80211/bcm43xx_main.c
@@ -4128,15 +4128,19 @@ static int bcm43xx_net_get_tx_stats(stru
 {
 	struct bcm43xx_private *bcm = bcm43xx_priv(net_dev);
 	unsigned long flags;
+	int err = -ENODEV;
 
 	bcm43xx_lock(bcm, flags);
-	if (bcm43xx_using_pio(bcm))
-		bcm43xx_pio_get_tx_stats(bcm, stats);
-	else
-		bcm43xx_dma_get_tx_stats(bcm, stats);
+	if (likely(bcm->initialized)) {
+		if (bcm43xx_using_pio(bcm))
+			bcm43xx_pio_get_tx_stats(bcm, stats);
+		else
+			bcm43xx_dma_get_tx_stats(bcm, stats);
+		err = 0;
+	}
 	bcm43xx_unlock(bcm, flags);
 
-	return 0;
+	return err;
 }
 
 static int bcm43xx_net_get_stats(struct net_device *net_dev,

-- 
Greetings Michael.
