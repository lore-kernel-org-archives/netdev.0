From: "Dale Farnsworth" <dale@farnsworth.org>
Subject: mv643xx_eth: Unmap DMA buffers in receive path
Date: Tue, 12 Sep 2006 11:22:34 -0700
Message-ID: <20060912182229.GA11522@xyzzy.farnsworth.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Manish Lachwani <mlachwani@mvista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xyzzy.farnsworth.org ([65.39.95.219]:15877 "HELO farnsworth.org")
	by vger.kernel.org with SMTP id S1030340AbWILSWj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Sep 2006 14:22:39 -0400
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dale Farnsworth <dale@farnsworth.org>

Fix a missing call to dma_unmap_single() in the receive path.  Without
this call, errors have been observed on non-cache-coherent systems.

Signed-off-by Dale Farnsworth <dale@farnsworth.org>

---

 drivers/net/mv643xx_eth.c |    2 ++
 1 file changed, 2 insertions(+)

Index: linux-2.6.10/drivers/net/mv643xx_eth.c
===================================================================
--- linux-2.6.10.orig/drivers/net/mv643xx_eth.c
+++ linux-2.6.10/drivers/net/mv643xx_eth.c
@@ -402,6 +402,8 @@ static int mv643xx_eth_receive_queue(str
 #else
 	while (eth_port_receive(mp, &pkt_info) == ETH_OK) {
 #endif
+		dma_unmap_single(NULL, pkt_info.buf_ptr, RX_SKB_SIZE,
+							DMA_FROM_DEVICE);
 		mp->rx_desc_count--;
 		received_packets++;
 
