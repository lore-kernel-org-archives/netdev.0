From: Roger Luethi <rl@hellgate.ch>
Subject: [PATCH 2.6] Nuke HAS_IP_COPYSUM for net drivers
Date: Tue, 25 May 2004 21:11:16 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040525191115.GA18454@k3.hellgate.ch>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="liOOAslEiF7prFVr"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>, Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--liOOAslEiF7prFVr
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Entirely untested, but Obviously Correct(TM). HAS_IP_COPYSUM has been
utterly meaningless for a long time.

Respective patch for via-rhine follows once I know the state of its
pending patches (which I wouldn't mind getting feedback on (hint,
hint!)).

Roger

--liOOAslEiF7prFVr
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="copysum-2.6.6.diff"

diff -urp linux-2.6.6/drivers/net/epic100.c linux-2.6.6-patch/drivers/net/epic100.c
--- linux-2.6.6/drivers/net/epic100.c	2004-04-04 05:37:06.000000000 +0200
+++ linux-2.6.6-patch/drivers/net/epic100.c	2004-05-25 20:45:55.273480945 +0200
@@ -1215,13 +1215,8 @@ static int epic_rx(struct net_device *de
 							    ep->rx_ring[entry].bufaddr,
 							    ep->rx_buf_sz,
 							    PCI_DMA_FROMDEVICE);
-#if 1 /* HAS_IP_COPYSUM */
 				eth_copy_and_sum(skb, ep->rx_skbuff[entry]->tail, pkt_len, 0);
 				skb_put(skb, pkt_len);
-#else
-				memcpy(skb_put(skb, pkt_len), ep->rx_skbuff[entry]->tail,
-					   pkt_len);
-#endif
 				pci_dma_sync_single_for_device(ep->pci_dev,
 							       ep->rx_ring[entry].bufaddr,
 							       ep->rx_buf_sz,
diff -urp linux-2.6.6/drivers/net/natsemi.c linux-2.6.6-patch/drivers/net/natsemi.c
--- linux-2.6.6/drivers/net/natsemi.c	2004-05-20 16:17:38.000000000 +0200
+++ linux-2.6.6-patch/drivers/net/natsemi.c	2004-05-25 20:51:58.171336667 +0200
@@ -1798,14 +1798,9 @@ static void netdev_rx(struct net_device 
 					np->rx_dma[entry],
 					buflen,
 					PCI_DMA_FROMDEVICE);
-#if HAS_IP_COPYSUM
 				eth_copy_and_sum(skb,
 					np->rx_skbuff[entry]->tail, pkt_len, 0);
 				skb_put(skb, pkt_len);
-#else
-				memcpy(skb_put(skb, pkt_len),
-					np->rx_skbuff[entry]->tail, pkt_len);
-#endif
 				pci_dma_sync_single_for_device(np->pci_dev,
 					np->rx_dma[entry],
 					buflen,
diff -urp linux-2.6.6/drivers/net/tulip/winbond-840.c linux-2.6.6-patch/drivers/net/tulip/winbond-840.c
--- linux-2.6.6/drivers/net/tulip/winbond-840.c	2004-04-04 05:36:26.000000000 +0200
+++ linux-2.6.6-patch/drivers/net/tulip/winbond-840.c	2004-05-25 20:46:26.439782500 +0200
@@ -1292,14 +1292,8 @@ static int netdev_rx(struct net_device *
 				pci_dma_sync_single_for_cpu(np->pci_dev,np->rx_addr[entry],
 							    np->rx_skbuff[entry]->len,
 							    PCI_DMA_FROMDEVICE);
-				/* Call copy + cksum if available. */
-#if HAS_IP_COPYSUM
 				eth_copy_and_sum(skb, np->rx_skbuff[entry]->tail, pkt_len, 0);
 				skb_put(skb, pkt_len);
-#else
-				memcpy(skb_put(skb, pkt_len), np->rx_skbuff[entry]->tail,
-					   pkt_len);
-#endif
 				pci_dma_sync_single_for_device(np->pci_dev,np->rx_addr[entry],
 							       np->rx_skbuff[entry]->len,
 							       PCI_DMA_FROMDEVICE);
diff -urp linux-2.6.6/drivers/net/yellowfin.c linux-2.6.6-patch/drivers/net/yellowfin.c
--- linux-2.6.6/drivers/net/yellowfin.c	2004-04-04 05:36:56.000000000 +0200
+++ linux-2.6.6-patch/drivers/net/yellowfin.c	2004-05-25 20:46:46.609742086 +0200
@@ -1201,13 +1201,8 @@ static int yellowfin_rx(struct net_devic
 					break;
 				skb->dev = dev;
 				skb_reserve(skb, 2);	/* 16 byte align the IP header */
-#if HAS_IP_COPYSUM
 				eth_copy_and_sum(skb, rx_skb->tail, pkt_len, 0);
 				skb_put(skb, pkt_len);
-#else
-				memcpy(skb_put(skb, pkt_len), 
-					rx_skb->tail, pkt_len);
-#endif
 				pci_dma_sync_single_for_device(yp->pci_dev, desc->addr,
 											   yp->rx_buf_sz,
 											   PCI_DMA_FROMDEVICE);

--liOOAslEiF7prFVr--
