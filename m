From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH] fix compiler warnings in mv64340_eth
Date: Wed, 7 Jul 2004 17:16:10 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040707151610.GA14330@lst.de>
References: <20040706105215.GA14731@lst.de> <40EB853E.5000504@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <40EB853E.5000504@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Jul 07, 2004 at 01:08:14AM -0400, Jeff Garzik wrote:
> patch OK, but patch(1) rejected

hmm, looks like it was for patch -p0


--- a/drivers/net/mv64340_eth.c~	2004-07-06 14:26:47.163242160 +0200
+++ b/drivers/net/mv64340_eth.c	2004-07-06 14:48:31.053020784 +0200
@@ -752,9 +752,8 @@
 		p_rx_desc[i].byte_cnt = 0x0000;
 		p_rx_desc[i].cmd_sts =
 			ETH_BUFFER_OWNED_BY_DMA | ETH_RX_ENABLE_INTERRUPT;
-		p_rx_desc[i].next_desc_ptr =
-			(struct eth_rx_desc *) mp->rx_desc_dma +
-				(i + 1) % rx_desc_num;
+		p_rx_desc[i].next_desc_ptr = mp->rx_desc_dma +
+			((i + 1) % rx_desc_num) * sizeof(struct eth_rx_desc);
 		p_rx_desc[i].buf_ptr = buffer_addr;
 
 		mp->rx_skb[i] = NULL;
@@ -818,9 +817,8 @@
 		p_tx_desc[i].byte_cnt	= 0x0000;
 		p_tx_desc[i].l4i_chk	= 0x0000;
 		p_tx_desc[i].cmd_sts	= 0x00000000;
-		p_tx_desc[i].next_desc_ptr =
-			(struct eth_tx_desc *) mp->tx_desc_dma +
-			(i + 1) % tx_desc_num;
+		p_tx_desc[i].next_desc_ptr = mp->tx_desc_dma +
+			((i + 1) % tx_desc_num) * sizeof(struct eth_tx_desc);
 		p_tx_desc[i].buf_ptr	= 0x00000000;
 		mp->tx_skb[i]		= NULL;
 	}
@@ -2329,8 +2349,8 @@
                 first_descriptor->cmd_sts = command_status;
                 first_descriptor->byte_cnt = p_pkt_info->byte_cnt;
                 first_descriptor->buf_ptr = p_pkt_info->buf_ptr;
-                first_descriptor->next_desc_ptr =
-			(struct eth_tx_desc *) mp->tx_desc_dma + tx_next_desc;
+                first_descriptor->next_desc_ptr = mp->tx_desc_dma +
+			tx_next_desc * sizeof(struct eth_tx_desc);
 		wmb();
         } else {
                 tx_first_desc = mp->tx_first_desc_q;
@@ -2343,8 +2363,8 @@
                         current_descriptor->next_desc_ptr = 0x00000000;
                 else {
                         command_status |= ETH_BUFFER_OWNED_BY_DMA;
-                        current_descriptor->next_desc_ptr =
-			  (struct eth_tx_desc *) mp->tx_desc_dma + tx_next_desc;
+                        current_descriptor->next_desc_ptr = mp->tx_desc_dma +
+				tx_next_desc * sizeof(struct eth_tx_desc);
                 }
         }
 
