From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: [PATCH] bcm43xx-softmac: optimization of DMA bitfields.]
Date: Wed, 16 Aug 2006 10:36:26 -0500
Message-ID: <44E33B7A.3060804@lwfinger.net>
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

Please pull this patch for the wireless-2.6 tree.

This patch depends on the 64bit DMA patch, which is already
submitted for inclusion.

Convert the bitfields in the bcm43xx DMA code to properly
aligned u8 booleans. These flags are accessed in the DMA
hotpath, so it's a good idea to waste a few bytes of memory
for the sake of speed by not requiring masking (and probably
shifting) of the bitfields.

Signed-off-by: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Signed-Off-By: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>

Index: wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_dma.h
===================================================================
--- wireless-2.6.orig/drivers/net/wireless/bcm43xx/bcm43xx_dma.h	2006-08-16 12:47:27.000000000 +0200
+++ wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_dma.h	2006-08-16 12:49:43.000000000 +0200
@@ -235,9 +235,12 @@
 	u16 mmio_base;
 	/* DMA controller index number (0-5). */
 	int index;
-	u8 tx:1,	/* TRUE, if this is a TX ring. */
-	   dma64:1,	/* TRUE, if 64-bit DMA is enabled (FALSE if 32bit). */
-	   suspended:1;	/* TRUE, if transfers are suspended on this ring. */
+	/* Boolean. Is this a TX ring? */
+	u8 tx
+	/* Boolean. 64bit DMA if true, 32bit DMA otherwise. */
+	u8 dma64;
+	/* Boolean. Are transfers suspended on this ring? */
+	u8 suspended;
 	struct bcm43xx_private *bcm;
 #ifdef CONFIG_BCM43XX_DEBUG
 	/* Maximum number of used slots. */
