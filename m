From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] de4x5 - missing free on error path
Date: Wed, 12 Nov 2003 16:30:09 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031112163009.2be5e47d.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

NE54-de4x5 - fix missing free on error path - found by viro

diff -Nru a/drivers/net/tulip/de4x5.c b/drivers/net/tulip/de4x5.c
--- a/drivers/net/tulip/de4x5.c	Tue Nov 11 14:15:07 2003
+++ b/drivers/net/tulip/de4x5.c	Tue Nov 11 14:15:07 2003
@@ -1237,6 +1237,8 @@
 	if (lp->useSROM) {
 	    lp->state = INITIALISED;
 	    if (srom_infoleaf_info(dev)) {
+	        dma_free_coherent (gendev, lp->dma_size,
+			       lp->rx_ring, lp->dma_rings);
 		return -ENXIO;
 	    }
 	    srom_init(dev);
