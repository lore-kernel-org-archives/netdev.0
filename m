From: Matt Porter <mporter@kernel.crashing.org>
Subject: [PATCH] emac: fix jumbo frame support
Date: Tue, 8 Feb 2005 22:34:33 -0700
Message-ID: <20050208223433.A12821@cox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, linuxppc-embedded@ozlabs.org
To: jgarzik@pobox.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Fixes a bug in RX buffer allocation so that jumbo size skbs are
allocated when the MTU size is changed. Also removes the deprecated
restore_flags() call.  Please apply.

Signed-off-by: Matt Porter <mporter@kernel.crashing.org>

===== drivers/net/ibm_emac/ibm_emac_core.c 1.7 vs edited =====
--- 1.7/drivers/net/ibm_emac/ibm_emac_core.c	2004-12-07 10:06:23 -07:00
+++ edited/drivers/net/ibm_emac/ibm_emac_core.c	2005-02-08 22:25:39 -07:00
@@ -912,7 +912,6 @@
 		PKT_DEBUG(("emac_start_xmit() stopping queue\n"));
 		netif_stop_queue(dev);
 		spin_unlock_irqrestore(&fep->lock, flags);
-		restore_flags(flags);
 		return -EBUSY;
 	}
 
@@ -1281,7 +1280,7 @@
 	/* Format the receive descriptor ring. */
 	ep->rx_slot = 0;
 	/* Default is MTU=1500 + Ethernet overhead */
-	ep->rx_buffer_size = ENET_DEF_BUF_SIZE;
+	ep->rx_buffer_size = dev->mtu + ENET_HEADER_SIZE + ENET_FCS_SIZE;
 	emac_rx_fill(dev, 0);
 	if (ep->rx_slot != 0) {
 		printk(KERN_ERR
===== drivers/net/ibm_emac/ibm_emac_core.h 1.2 vs edited =====
--- 1.2/drivers/net/ibm_emac/ibm_emac_core.h	2004-08-05 07:26:55 -07:00
+++ edited/drivers/net/ibm_emac/ibm_emac_core.h	2005-02-08 22:24:52 -07:00
@@ -77,8 +77,6 @@
 
 #define ENET_HEADER_SIZE	14
 #define ENET_FCS_SIZE		4
-#define ENET_DEF_MTU_SIZE	1500
-#define ENET_DEF_BUF_SIZE	(ENET_DEF_MTU_SIZE + ENET_HEADER_SIZE + ENET_FCS_SIZE)
 #define EMAC_MIN_FRAME		64
 #define EMAC_MAX_FRAME		9018
 #define EMAC_MIN_MTU		(EMAC_MIN_FRAME - ENET_HEADER_SIZE - ENET_FCS_SIZE)
