From: "Dale Farnsworth" <dale@farnsworth.org>
Subject: PATCH mv643xx_eth: Unmap DMA buffers in receive path
Date: Wed, 13 Sep 2006 09:21:08 -0700
Message-ID: <20060913162108.GA2171@xyzzy.farnsworth.org>
References: <20060912182229.GA11522@xyzzy.farnsworth.org> <45076774.5030909@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Manish Lachwani <mlachwani@mvista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xyzzy.farnsworth.org ([65.39.95.219]:14597 "HELO farnsworth.org")
	by vger.kernel.org with SMTP id S1751010AbWIMQVF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Sep 2006 12:21:05 -0400
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <45076774.5030909@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dale Farnsworth <dale@farnsworth.org>

Fix a missing call to dma_unmap_single() in the receive path.  Without
this call, errors have been observed on non-cache-coherent systems.

Signed-off-by Dale Farnsworth <dale@farnsworth.org>

---

> ACK, but
> error: patch failed: drivers/net/mv643xx_eth.c:402
> error: drivers/net/mv643xx_eth.c: patch does not apply

Sorry.  Patch was against an old version.
This one's current.

-Dale

 drivers/net/mv643xx_eth.c |    2 ++
  1 file changed, 2 insertions(+)


diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index 760c61b..eeab1df 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -385,6 +385,8 @@ static int mv643xx_eth_receive_queue(str
 	struct pkt_info pkt_info;
 
 	while (budget-- > 0 && eth_port_receive(mp, &pkt_info) == ETH_OK) {
+		dma_unmap_single(NULL, pkt_info.buf_ptr, RX_SKB_SIZE,
+							DMA_FROM_DEVICE);
 		mp->rx_desc_count--;
 		received_packets++;
 
