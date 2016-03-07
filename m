From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH 1/2] sh_eth: fix NULL pointer dereference in sh_eth_ring_format()
Date: Tue, 08 Mar 2016 01:36:28 +0300
Message-ID: <1725708.Wzdm5RnPU1@wasted.cogentembedded.com>
References: <4881302.XJJSmqvE1J@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: linux-renesas-soc@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <4881302.XJJSmqvE1J@wasted.cogentembedded.com>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In a low memory situation, if netdev_alloc_skb() fails on a first RX ring
loop iteration  in sh_eth_ring_format(), 'rxdesc' is still NULL.  Avoid
kernel oops by adding the 'rxdesc' check after the loop.

Reported-by: Wolfram Sang <wsa+renesas@sang-engineering.com>
Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
 drivers/net/ethernet/renesas/sh_eth.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

Index: net/drivers/net/ethernet/renesas/sh_eth.c
===================================================================
--- net.orig/drivers/net/ethernet/renesas/sh_eth.c
+++ net/drivers/net/ethernet/renesas/sh_eth.c
@@ -1163,7 +1163,8 @@ static void sh_eth_ring_format(struct ne
 	mdp->dirty_rx = (u32) (i - mdp->num_rx_ring);
 
 	/* Mark the last entry as wrapping the ring. */
-	rxdesc->status |= cpu_to_le32(RD_RDLE);
+	if (rxdesc)
+		rxdesc->status |= cpu_to_le32(RD_RDLE);
 
 	memset(mdp->tx_ring, 0, tx_ringsize);
 
