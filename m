From: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Subject: [patch 2/3 2.5] e100 - use NET_IP_ALIGN to set rx data buffer
 alignment
Date: Fri, 17 Sep 2004 02:54:29 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0409170208320.15233-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, <ganesh.venkatesan@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

diff -up linux-2.5/drivers/net/e100.c linux-2.5/drivers/net/e100.c.new
--- linux-2.5/drivers/net/e100.c	2004-09-09 14:51:31.000000000 -0700
+++ linux-2.5/drivers/net/e100.c.new	2004-09-09 14:51:32.000000000 -0700
@@ -1425,14 +1425,12 @@ static inline void e100_start_receiver(s
 #define RFD_BUF_LEN (sizeof(struct rfd) + VLAN_ETH_FRAME_LEN)
 static inline int e100_rx_alloc_skb(struct nic *nic, struct rx *rx)
 {
-	unsigned int rx_offset = 2; /* u32 align protocol headers */
-
-	if(!(rx->skb = dev_alloc_skb(RFD_BUF_LEN + rx_offset)))
+	if(!(rx->skb = dev_alloc_skb(RFD_BUF_LEN + NET_IP_ALIGN)))
 		return -ENOMEM;
 
 	/* Align, init, and map the RFD. */
 	rx->skb->dev = nic->netdev;
-	skb_reserve(rx->skb, rx_offset);
+	skb_reserve(rx->skb, NET_IP_ALIGN);
 	memcpy(rx->skb->data, &nic->blank_rfd, sizeof(struct rfd));
 	rx->dma_addr = pci_map_single(nic->pdev, rx->skb->data,
 		RFD_BUF_LEN, PCI_DMA_BIDIRECTIONAL);
