From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2.6.9 2/3] hp100: use inline for comple usage of dev->priv
Date: Tue, 19 Oct 2004 14:18:18 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041019141818.10ecb40c@zqx3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jean Tourrilhes <jt@bougret.hpl.hp.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Make a separate function for the one more complex usage of netdev_priv.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/drivers/net/hp100.c b/drivers/net/hp100.c
--- a/drivers/net/hp100.c	2004-10-18 15:57:57 -07:00
+++ b/drivers/net/hp100.c	2004-10-18 15:57:57 -07:00
@@ -284,6 +284,12 @@
 	return ((u_long) ptr) + lp->whatever_offset;
 }
 
+static inline u_int pdl_map_data(struct hp100_private *lp, void *data)
+{
+	return pci_map_single(lp->pci_dev, data, 
+			      MAX_ETHER_SIZE, PCI_DMA_FROMDEVICE);
+}
+
 /* TODO: This function should not really be needed in a good design... */
 static void wait(void)
 {
@@ -1273,7 +1279,8 @@
 		/* Conversion to new PCI API : map skbuf data to PCI bus.
 		 * Doc says it's OK for EISA as well - Jean II */
 		ringptr->pdl[0] = 0x00020000;	/* Write PDH */
-		ringptr->pdl[3] = ((u_int) pci_map_single(((struct hp100_private *) (dev->priv))->pci_dev, ringptr->skb->data, MAX_ETHER_SIZE, PCI_DMA_FROMDEVICE));
+		ringptr->pdl[3] = pdl_map_data(netdev_priv(dev), 
+					       ringptr->skb->data);
 		ringptr->pdl[4] = MAX_ETHER_SIZE;	/* Length of Data */
 
 #ifdef HP100_DEBUG_BM
