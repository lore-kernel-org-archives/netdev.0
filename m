From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: PATCH: [SKBUFF] introduce irda_type_trans
Date: Mon, 04 Oct 2004 12:11:37 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <41616829.5070600@conectiva.com.br>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010203090900020901000700"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------010203090900020901000700
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi David,

	Please consider pulling from:

bk://kernel.bkbits.net/acme/sk_buff-2.6

	Now there are ten outstanding changesets in this tree.

Regards,

- Arnaldo

--------------010203090900020901000700
Content-Type: text/plain;
 name="irda_type_trans.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="irda_type_trans.patch"

===================================================================


ChangeSet@1.2039, 2004-10-04 12:09:26-03:00, acme@conectiva.com.br
  [SKBUFF] introduce irda_type_trans
  
  Signed-off-by: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
  Signed-off-by: David S. Miller <davem@redhat.com>


 drivers/net/irda/ali-ircc.c    |    4 +---
 drivers/net/irda/au1k_ir.c     |    4 +---
 drivers/net/irda/donauboe.c    |    4 +---
 drivers/net/irda/irda-usb.c    |    4 +---
 drivers/net/irda/nsc-ircc.c    |    4 +---
 drivers/net/irda/sa1100_ir.c   |    4 +---
 drivers/net/irda/smsc-ircc2.c  |    4 +---
 drivers/net/irda/stir4200.c    |    5 +----
 drivers/net/irda/via-ircc.c    |   16 ++++------------
 drivers/net/irda/vlsi_ir.c     |    3 +--
 drivers/net/irda/w83977af_ir.c |    4 +---
 include/net/irda/irda.h        |   10 ++++++++++
 12 files changed, 24 insertions(+), 42 deletions(-)


diff -Nru a/drivers/net/irda/ali-ircc.c b/drivers/net/irda/ali-ircc.c
--- a/drivers/net/irda/ali-ircc.c	2004-10-04 12:09:47 -03:00
+++ b/drivers/net/irda/ali-ircc.c	2004-10-04 12:09:47 -03:00
@@ -1909,9 +1909,7 @@
 			self->stats.rx_bytes += len;
 			self->stats.rx_packets++;
 
-			skb->dev = self->netdev;
-			skb_set_link_header(skb);
-			skb->protocol = htons(ETH_P_IRDA);
+			skb->protocol = irda_type_trans(skb, self->netdev);
 			netif_rx(skb);
 			self->netdev->last_rx = jiffies;
 		}
diff -Nru a/drivers/net/irda/au1k_ir.c b/drivers/net/irda/au1k_ir.c
--- a/drivers/net/irda/au1k_ir.c	2004-10-04 12:09:47 -03:00
+++ b/drivers/net/irda/au1k_ir.c	2004-10-04 12:09:47 -03:00
@@ -606,9 +606,7 @@
 			else
 				skb_put(skb, count-2);
 			memcpy(skb->data, (void *)pDB->vaddr, count-2);
-			skb->dev = dev;
-			skb_set_link_header(skb);
-			skb->protocol = htons(ETH_P_IRDA);
+			skb->protocol = irda_type_trans(skb, dev);
 			netif_rx(skb);
 			prxd->count_0 = 0;
 			prxd->count_1 = 0;
diff -Nru a/drivers/net/irda/donauboe.c b/drivers/net/irda/donauboe.c
--- a/drivers/net/irda/donauboe.c	2004-10-04 12:09:47 -03:00
+++ b/drivers/net/irda/donauboe.c	2004-10-04 12:09:47 -03:00
@@ -1297,9 +1297,7 @@
                       memcpy (skb->data, self->rx_bufs[self->rxs], len);
 
                       self->stats.rx_packets++;
-                      skb->dev = self->netdev;
-                      skb_set_link_header(skb);
-                      skb->protocol = htons (ETH_P_IRDA);
+                      skb->protocol = irda_type_trans(skb, self->netdev);
                     }
                   else
                     {
diff -Nru a/drivers/net/irda/irda-usb.c b/drivers/net/irda/irda-usb.c
--- a/drivers/net/irda/irda-usb.c	2004-10-04 12:09:47 -03:00
+++ b/drivers/net/irda/irda-usb.c	2004-10-04 12:09:47 -03:00
@@ -829,9 +829,7 @@
 	skb_pull(dataskb, USB_IRDA_HEADER);
 
 	/* Ask the networking layer to queue the packet for the IrDA stack */
-	dataskb->dev = self->netdev;
-	skb_set_link_header(dataskb);
-	dataskb->protocol = htons(ETH_P_IRDA);
+	dataskb->protocol = irda_type_trans(dataskb, self->netdev);
 	netif_rx(dataskb);
 
 	/* Keep stats up to date */
diff -Nru a/drivers/net/irda/nsc-ircc.c b/drivers/net/irda/nsc-ircc.c
--- a/drivers/net/irda/nsc-ircc.c	2004-10-04 12:09:47 -03:00
+++ b/drivers/net/irda/nsc-ircc.c	2004-10-04 12:09:47 -03:00
@@ -1731,9 +1731,7 @@
 			self->stats.rx_bytes += len;
 			self->stats.rx_packets++;
 
-			skb->dev = self->netdev;
-			skb_set_link_header(skb);
-			skb->protocol = htons(ETH_P_IRDA);
+			skb->protocol = irda_type_trans(skb, self->netdev);
 			netif_rx(skb);
 			self->netdev->last_rx = jiffies;
 		}
diff -Nru a/drivers/net/irda/sa1100_ir.c b/drivers/net/irda/sa1100_ir.c
--- a/drivers/net/irda/sa1100_ir.c	2004-10-04 12:09:47 -03:00
+++ b/drivers/net/irda/sa1100_ir.c	2004-10-04 12:09:47 -03:00
@@ -569,9 +569,7 @@
 		si->rxskb = NULL;
 
 		skb_put(skb, len);
-		skb->dev = dev;
-		skb_set_link_header(skb);
-		skb->protocol = htons(ETH_P_IRDA);
+		skb->protocol = irda_type_trans(skb, dev);
 		si->stats.rx_packets++;
 		si->stats.rx_bytes += len;
 
diff -Nru a/drivers/net/irda/smsc-ircc2.c b/drivers/net/irda/smsc-ircc2.c
--- a/drivers/net/irda/smsc-ircc2.c	2004-10-04 12:09:47 -03:00
+++ b/drivers/net/irda/smsc-ircc2.c	2004-10-04 12:09:47 -03:00
@@ -1343,9 +1343,7 @@
 	self->stats.rx_packets++;
 	self->stats.rx_bytes += len;
 
-	skb->dev = self->netdev;
-	skb_set_link_header(skb);
-	skb->protocol = htons(ETH_P_IRDA);
+	skb->protocol = irda_type_trans(skb, self->netdev);
 	netif_rx(skb);
 }
 
diff -Nru a/drivers/net/irda/stir4200.c b/drivers/net/irda/stir4200.c
--- a/drivers/net/irda/stir4200.c	2004-10-04 12:09:47 -03:00
+++ b/drivers/net/irda/stir4200.c	2004-10-04 12:09:47 -03:00
@@ -368,10 +368,7 @@
 
 	skb_put(skb, len);
 
-	skb_set_link_header(skb);
-	skb->protocol = htons(ETH_P_IRDA);
-	skb->dev = stir->netdev;
-
+	skb->protocol = irda_type_trans(skb, stir->netdev);
 	netif_rx(skb);
 
 	stir->stats.rx_packets++;
diff -Nru a/drivers/net/irda/via-ircc.c b/drivers/net/irda/via-ircc.c
--- a/drivers/net/irda/via-ircc.c	2004-10-04 12:09:47 -03:00
+++ b/drivers/net/irda/via-ircc.c	2004-10-04 12:09:47 -03:00
@@ -1078,9 +1078,7 @@
 		self->rx_buff.data += len;
 		self->stats.rx_bytes += len;
 		self->stats.rx_packets++;
-		skb->dev = self->netdev;
-		skb_set_link_header(skb);
-		skb->protocol = htons(ETH_P_IRDA);
+		skb->protocol = irda_type_trans(skb, self->netdev);
 		netif_rx(skb);
 		return TRUE;
 	}
@@ -1162,9 +1160,7 @@
 		self->rx_buff.data += len;
 		self->stats.rx_bytes += len;
 		self->stats.rx_packets++;
-		skb->dev = self->netdev;
-		skb_set_link_header(skb);
-		skb->protocol = htons(ETH_P_IRDA);
+		skb->protocol = irda_type_trans(skb, self->netdev);
 		netif_rx(skb);
 
 //F01_E
@@ -1204,9 +1200,7 @@
 	self->rx_buff.data += len;
 	self->stats.rx_bytes += len;
 	self->stats.rx_packets++;
-	skb->dev = self->netdev;
-	skb_set_link_header(skb);
-	skb->protocol = htons(ETH_P_IRDA);
+	skb->protocol = irda_type_trans(skb, self->netdev);
 	netif_rx(skb);
 	if (st_fifo->len < (MAX_RX_WINDOW + 2)) {
 		RXStart(iobase, ON);
@@ -1274,9 +1268,7 @@
 			self->rx_buff.data += len;
 			self->stats.rx_bytes += len;
 			self->stats.rx_packets++;
-			skb->dev = self->netdev;
-			skb_set_link_header(skb);
-			skb->protocol = htons(ETH_P_IRDA);
+			skb->protocol = irda_type_trans(skb, self->netdev);
 			netif_rx(skb);
 		}		//while
 		self->RetryCount = 0;
diff -Nru a/drivers/net/irda/vlsi_ir.c b/drivers/net/irda/vlsi_ir.c
--- a/drivers/net/irda/vlsi_ir.c	2004-10-04 12:09:47 -03:00
+++ b/drivers/net/irda/vlsi_ir.c	2004-10-04 12:09:47 -03:00
@@ -594,9 +594,8 @@
 
 	skb = rd->skb;
 	rd->skb = NULL;
-	skb->dev = ndev;
 	memcpy(skb_put(skb,len), rd->buf, len);
-	skb_set_link_header(skb);
+	skb->protocol = irda_type_trans(skb, ndev);
 	if (in_interrupt())
 		netif_rx(skb);
 	else
diff -Nru a/drivers/net/irda/w83977af_ir.c b/drivers/net/irda/w83977af_ir.c
--- a/drivers/net/irda/w83977af_ir.c	2004-10-04 12:09:47 -03:00
+++ b/drivers/net/irda/w83977af_ir.c	2004-10-04 12:09:47 -03:00
@@ -919,9 +919,7 @@
 			self->rx_buff.data += len;
 			self->stats.rx_packets++;
 			
-			skb->dev = self->netdev;
-			skb_set_link_header(skb);
-			skb->protocol = htons(ETH_P_IRDA);
+			skb->protocol = irda_type_trans(skb, self->netdev);
 			netif_rx(skb);
 			self->netdev->last_rx = jiffies;
 		}
diff -Nru a/include/net/irda/irda.h b/include/net/irda/irda.h
--- a/include/net/irda/irda.h	2004-10-04 12:09:47 -03:00
+++ b/include/net/irda/irda.h	2004-10-04 12:09:47 -03:00
@@ -111,4 +111,14 @@
 #define IAS_IRCOMM_ID 0x2343
 #define IAS_IRLPT_ID  0x9876
 
+#include <linux/if_ether.h>
+
+static inline unsigned short irda_type_trans(struct sk_buff *skb,
+					     struct net_device *dev)
+{
+	skb->dev = dev;
+	skb_set_link_header(skb);
+	return htons(ETH_P_IRDA);
+}
+
 #endif /* NET_IRDA_H */


--------------010203090900020901000700--
