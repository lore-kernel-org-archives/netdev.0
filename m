From: akpm@osdl.org
Subject: [patch 05/11] drivers/net/tokenring/lanstreamer.c Removal of old code
Date: Mon, 25 Sep 2006 16:39:20 -0700
Message-ID: <200609252339.k8PNdKti002637@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@osdl.org,
	michal.k.k.piotrowski@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:12724 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751711AbWIYXj1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Sep 2006 19:39:27 -0400
To: jeff@garzik.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>

Signed-off-by: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Cc: Jeff Garzik <jeff@garzik.org>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 drivers/net/tokenring/lanstreamer.c |   59 --------------------------
 1 file changed, 59 deletions(-)

diff -puN drivers/net/tokenring/lanstreamer.c~drivers-net-tokenring-lanstreamerc-removal-of-old-code drivers/net/tokenring/lanstreamer.c
--- a/drivers/net/tokenring/lanstreamer.c~drivers-net-tokenring-lanstreamerc-removal-of-old-code
+++ a/drivers/net/tokenring/lanstreamer.c
@@ -1876,7 +1876,6 @@ static int sprintf_info(char *buffer, st
 		datap[size+1]=io_word & 0xff;
 	}
 
-
 	size = sprintf(buffer, "\n%6s: Adapter Address   : Node Address      : Functional Addr\n", dev->name);
 
 	size += sprintf(buffer + size,
@@ -1932,64 +1931,6 @@ static int sprintf_info(char *buffer, st
 #endif
 #endif
 
-#if STREAMER_IOCTL && (LINUX_VERSION_CODE < KERNEL_VERSION(2,5,0))
-static int streamer_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
-{
-        int i;
-	struct streamer_private *streamer_priv = (struct streamer_private *) dev->priv;
-	u8 __iomem *streamer_mmio = streamer_priv->streamer_mmio;
-
-	switch(cmd) {
-	case IOCTL_SISR_MASK:
-		writew(SISR_MI, streamer_mmio + SISR_MASK_SUM);
-		break;
-	case IOCTL_SPIN_LOCK_TEST:
-	        printk(KERN_INFO "spin_lock() called.\n");
-		spin_lock(&streamer_priv->streamer_lock);
-		spin_unlock(&streamer_priv->streamer_lock);
-		printk(KERN_INFO "spin_unlock() finished.\n");
-		break;
-	case IOCTL_PRINT_BDAS:
-	        printk(KERN_INFO "bdas: RXBDA: %x RXLBDA: %x TX2FDA: %x TX2LFDA: %x\n",
-		       readw(streamer_mmio + RXBDA),
-		       readw(streamer_mmio + RXLBDA),
-		       readw(streamer_mmio + TX2FDA),
-		       readw(streamer_mmio + TX2LFDA));
-		break;
-	case IOCTL_PRINT_REGISTERS:
-	        printk(KERN_INFO "registers:\n");
-		printk(KERN_INFO "SISR: %04x MISR: %04x LISR: %04x BCTL: %04x BMCTL: %04x\nmask  %04x mask  %04x\n", 
-		       readw(streamer_mmio + SISR),
-		       readw(streamer_mmio + MISR_RUM),
-		       readw(streamer_mmio + LISR),
-		       readw(streamer_mmio + BCTL),
-		       readw(streamer_mmio + BMCTL_SUM),
-		       readw(streamer_mmio + SISR_MASK),
-		       readw(streamer_mmio + MISR_MASK));
-		break;
-	case IOCTL_PRINT_RX_BUFS:
-	        printk(KERN_INFO "Print rx bufs:\n");
-		for(i=0; i<STREAMER_RX_RING_SIZE; i++)
-		        printk(KERN_INFO "rx_ring %d status: 0x%x\n", i, 
-			       streamer_priv->streamer_rx_ring[i].status);
-		break;
-	case IOCTL_PRINT_TX_BUFS:
-	        printk(KERN_INFO "Print tx bufs:\n");
-		for(i=0; i<STREAMER_TX_RING_SIZE; i++)
-		        printk(KERN_INFO "tx_ring %d status: 0x%x\n", i, 
-			       streamer_priv->streamer_tx_ring[i].status);
-		break;
-	case IOCTL_RX_CMD:
-	        streamer_rx(dev);
-		printk(KERN_INFO "Sent rx command.\n");
-		break;
-	default:
-	        printk(KERN_INFO "Bad ioctl!\n");
-	}
-	return 0;
-}
-#endif
-
 static struct pci_driver streamer_pci_driver = {
   .name     = "lanstreamer",
   .id_table = streamer_pci_tbl,
_
