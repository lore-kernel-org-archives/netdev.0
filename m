From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: [PATCH] 2.6.x Tulip oops while doing eject/rmmod on live interface
Date: Mon, 26 Apr 2004 03:30:41 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <m3hdv7o79a.fsf@defiant.pm.waw.pl>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-=-="
Cc: <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--=-=-=

Hi,

The attached patch fixes an "oops" in tulip driver when a live interface
is deactivated (i.e. PC Card ejected or module unloaded) without being
brought down first.

Please apply to Linux 2.6. Thanks.
-- 
Krzysztof Halasa, B*FH

--=-=-=
Content-Type: text/x-patch
Content-Disposition: inline; filename=tulip-rmmod.patch

--- linux/drivers/net/tulip/tulip_core.c	19 Apr 2004 17:04:06 -0000
+++ linux.orig/drivers/net/tulip/tulip_core.c	26 Apr 2004 01:08:31 -0000
@@ -1761,11 +1761,11 @@
 		return;
 
 	tp = netdev_priv(dev);
+	unregister_netdev(dev);
 	pci_free_consistent (pdev,
 			     sizeof (struct tulip_rx_desc) * RX_RING_SIZE +
 			     sizeof (struct tulip_tx_desc) * TX_RING_SIZE,
 			     tp->rx_ring, tp->rx_ring_dma);
-	unregister_netdev (dev);
 	if (tp->mtable)
 		kfree (tp->mtable);
 #ifndef USE_IO_OPS

--=-=-=--
