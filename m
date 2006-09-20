From: "Dale Farnsworth" <dale@farnsworth.org>
Subject: [PATCH 2/2] mv643xx_eth: Fix typo: RX_SKB_SIZE ==> ETH_RX_SKB_SIZE
Date: Wed, 20 Sep 2006 12:27:21 -0700
Message-ID: <20060920192721.GA13150@xyzzy.farnsworth.org>
References: <20060920192434.GA13293@xyzzy.farnsworth.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Manish Lachwani <mlachwani@mvista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xyzzy.farnsworth.org ([65.39.95.219]:53260 "HELO farnsworth.org")
	by vger.kernel.org with SMTP id S932309AbWITT1Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Sep 2006 15:27:16 -0400
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <20060920192434.GA13293@xyzzy.farnsworth.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dale Farnsworth <dale@farnsworth.org>

Bug was introduced in commit 71d28725548be203e8b8f6ad63b1f64fd7f02d4d.
How embarrassing.  It wasn't caught because dma_umap_single()
is defined away on arch/ppc and 32-bit arch/powerpc.

Signed-off-by: Dale Farnsworth <dale@farnsworth.org>

---

Arggh.  (And that's not pirate talk.)

This isn't urgent since dma_unmap_single() is defined away for ppc32
both in arch/ppc and arch/powerpc.  It was caught on ppc64 arch/powerpc,
but isn't needed by any ppc64 platforms.

diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index eeab1df..59de3e7 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -385,7 +385,7 @@ static int mv643xx_eth_receive_queue(str
 	struct pkt_info pkt_info;
 
 	while (budget-- > 0 && eth_port_receive(mp, &pkt_info) == ETH_OK) {
-		dma_unmap_single(NULL, pkt_info.buf_ptr, RX_SKB_SIZE,
+		dma_unmap_single(NULL, pkt_info.buf_ptr, ETH_RX_SKB_SIZE,
 							DMA_FROM_DEVICE);
 		mp->rx_desc_count--;
 		received_packets++;
