From: Daniel Ritz <daniel.ritz@gmx.ch>
Subject: [PATCH 2.6] missing s/dev->priv/netdev_priv(dev) in drivers/net/pcmcia/
Date: Wed, 24 Mar 2004 23:15:53 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200403242315.53770.daniel.ritz@gmx.ch>
Reply-To: daniel.ritz@gmx.ch
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

clean up the last two instances of dev->priv in drivers/net/pcmcia.
against 2.6.5-rc2-bk.

--- 1.27/drivers/net/pcmcia/3c589_cs.c	Wed Mar  3 01:03:51 2004
+++ edited/drivers/net/pcmcia/3c589_cs.c	Wed Mar 24 22:29:35 2004
@@ -716,7 +716,7 @@
 	  "status %4.4x.\n", dev->name, (long)skb->len,
 	  inw(ioaddr + EL3_STATUS));
 
-    ((struct el3_private *)dev->priv)->stats.tx_bytes += skb->len;
+    ((struct el3_private *)netdev_priv(dev))->stats.tx_bytes += skb->len;
 
     /* Put out the doubleword header... */
     outw(skb->len, ioaddr + TX_FIFO);
--- 1.24/drivers/net/pcmcia/ibmtr_cs.c	Wed Mar  3 01:06:03 2004
+++ edited/drivers/net/pcmcia/ibmtr_cs.c	Wed Mar 24 22:29:51 2004
@@ -444,7 +444,7 @@
         link->state &= ~DEV_PRESENT;
         if (link->state & DEV_CONFIG) {
 	    /* set flag to bypass normal interrupt code */
-	    ((struct tok_info *)dev->priv)->sram_virt |= 1;
+	    ((struct tok_info *)netdev_priv(dev))->sram_virt |= 1;
 	    netif_device_detach(dev);
 	    ibmtr_release(link);
         }
