From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [patch 26/45] olympic: convert to internal network device stats
Date: Fri, 09 Jan 2009 15:01:23 -0800
Message-ID: <20090109230138.644938114@linux-foundation.org>
References: <20090109230057.575650817@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:42221 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753852AbZAIXR6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Jan 2009 18:17:58 -0500
Content-Disposition: inline; filename=olympic-stats.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
 drivers/net/tokenring/olympic.c |   21 ++++++---------------
 drivers/net/tokenring/olympic.h |    1 -
 2 files changed, 6 insertions(+), 16 deletions(-)

--- a/drivers/net/tokenring/olympic.c	2009-01-09 13:56:07.000000000 -0800
+++ b/drivers/net/tokenring/olympic.c	2009-01-09 13:59:50.000000000 -0800
@@ -187,7 +187,6 @@ static int olympic_close(struct net_devi
 static void olympic_set_rx_mode(struct net_device *dev);
 static void olympic_freemem(struct net_device *dev) ;  
 static irqreturn_t olympic_interrupt(int irq, void *dev_id);
-static struct net_device_stats * olympic_get_stats(struct net_device *dev);
 static int olympic_set_mac_address(struct net_device *dev, void *addr) ; 
 static void olympic_arb_cmd(struct net_device *dev);
 static int olympic_change_mtu(struct net_device *dev, int mtu);
@@ -259,7 +258,6 @@ static int __devinit olympic_probe(struc
 	dev->stop=&olympic_close;
 	dev->do_ioctl=NULL;
 	dev->set_multicast_list=&olympic_set_rx_mode;
-	dev->get_stats=&olympic_get_stats ;
 	dev->set_mac_address=&olympic_set_mac_address ;  
 	SET_NETDEV_DEV(dev, &pdev->dev);
 
@@ -785,7 +783,7 @@ static void olympic_rx(struct net_device
 				} 
 				olympic_priv->rx_ring_last_received += i ; 
 				olympic_priv->rx_ring_last_received &= (OLYMPIC_RX_RING_SIZE -1) ; 
-				olympic_priv->olympic_stats.rx_errors++;	 
+				dev->stats.rx_errors++;
 			} else {	
 			
 				if (buffer_cnt == 1) {
@@ -796,7 +794,7 @@ static void olympic_rx(struct net_device
 
 				if (skb == NULL) {
 					printk(KERN_WARNING "%s: Not enough memory to copy packet to upper layers. \n",dev->name) ;
-					olympic_priv->olympic_stats.rx_dropped++ ; 
+					dev->stats.rx_dropped++;
 					/* Update counters even though we don't transfer the frame */
 					olympic_priv->rx_ring_last_received += i ; 
 					olympic_priv->rx_ring_last_received &= (OLYMPIC_RX_RING_SIZE -1) ;  
@@ -862,8 +860,8 @@ static void olympic_rx(struct net_device
 						skb->protocol = tr_type_trans(skb,dev);
 						netif_rx(skb) ; 
 					} 
-					olympic_priv->olympic_stats.rx_packets++ ; 
-					olympic_priv->olympic_stats.rx_bytes += length ; 
+					dev->stats.rx_packets++ ;
+					dev->stats.rx_bytes += length ;
 				} /* if skb == null */
 			} /* If status & 0x3b */
 
@@ -971,8 +969,8 @@ static irqreturn_t olympic_interrupt(int
 				olympic_priv->tx_ring_last_status++;
 				olympic_priv->tx_ring_last_status &= (OLYMPIC_TX_RING_SIZE-1);
 				olympic_priv->free_tx_ring_entries++;
-				olympic_priv->olympic_stats.tx_bytes += olympic_priv->tx_ring_skb[olympic_priv->tx_ring_last_status]->len;
-				olympic_priv->olympic_stats.tx_packets++ ; 
+				dev->stats.tx_bytes += olympic_priv->tx_ring_skb[olympic_priv->tx_ring_last_status]->len;
+				dev->stats.tx_packets++ ;
 				pci_unmap_single(olympic_priv->pdev, 
 					le32_to_cpu(olympic_priv->olympic_tx_ring[olympic_priv->tx_ring_last_status].buffer), 
 					olympic_priv->tx_ring_skb[olympic_priv->tx_ring_last_status]->len,PCI_DMA_TODEVICE);
@@ -1344,13 +1342,6 @@ static void olympic_srb_bh(struct net_de
 
 } 
 
-static struct net_device_stats * olympic_get_stats(struct net_device *dev)
-{
-	struct olympic_private *olympic_priv ;
-	olympic_priv=netdev_priv(dev);
-	return (struct net_device_stats *) &olympic_priv->olympic_stats; 
-}
-
 static int olympic_set_mac_address (struct net_device *dev, void *addr) 
 {
 	struct sockaddr *saddr = addr ; 
--- a/drivers/net/tokenring/olympic.h	2009-01-09 13:56:07.000000000 -0800
+++ b/drivers/net/tokenring/olympic.h	2009-01-09 13:59:37.000000000 -0800
@@ -275,7 +275,6 @@ struct olympic_private {
 	struct sk_buff *tx_ring_skb[OLYMPIC_TX_RING_SIZE], *rx_ring_skb[OLYMPIC_RX_RING_SIZE];	
 	int tx_ring_free, tx_ring_last_status, rx_ring_last_received,rx_status_last_received, free_tx_ring_entries;
 
-	struct net_device_stats olympic_stats ;
 	u16 olympic_lan_status ;
 	u8 olympic_ring_speed ;
 	u16 pkt_buf_sz ; 


