From: Roger Luethi <rl@hellgate.ch>
Subject: [1/9][PATCH 2.6] Nuke HAS_IP_COPYSUM
Date: Wed, 2 Jun 2004 13:57:54 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040602115754.GA17396@k3.hellgate.ch>
References: <20040602115703.GA16079@k3.hellgate.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>, Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
In-Reply-To: <20040602115703.GA16079@k3.hellgate.ch>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

HAS_IP_COPYSUM has been utterly meaningless for a long time.

Signed-off-by: Roger Luethi <rl@hellgate.ch>

--- orig/drivers/net/via-rhine.c
+++ mod/drivers/net/via-rhine.c
@@ -1563,15 +1563,10 @@
 				   eth_copy_and_sum is memcpy for all archs so
 				   this is kind of pointless right now
 				   ... or? */
-#if HAS_IP_COPYSUM		/* Call copy + cksum if available. */
 				eth_copy_and_sum(skb,
 						 rp->rx_skbuff[entry]->tail,
 						 pkt_len, 0);
 				skb_put(skb, pkt_len);
-#else
-				memcpy(skb_put(skb, pkt_len),
-				       rp->rx_skbuff[entry]->tail, pkt_len);
-#endif
 				pci_dma_sync_single_for_device(rp->pdev,
 							       rp->rx_skbuff_dma[entry],
 							       rp->rx_buf_sz,
