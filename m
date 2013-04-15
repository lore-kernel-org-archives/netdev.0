From: Denis Kirjanov <kda@linux-powerpc.org>
Subject: [PATCH][nex-next] sis900: check for DMA map errors
Date: Mon, 15 Apr 2013 11:11:29 +0400
Message-ID: <1366009889-2068-1-git-send-email-kda@linux-powerpc.org>
Cc: netdev@vger.kernel.org, Denis Kirjanov <kda@linux-powerpc.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f47.google.com ([209.85.215.47]:57668 "EHLO
	mail-la0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753915Ab3DOLIg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Apr 2013 07:08:36 -0400
Received: by mail-la0-f47.google.com with SMTP id eh20so3147752lab.20
        for <netdev@vger.kernel.org>; Mon, 15 Apr 2013 04:08:34 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The first backtrace appears on tx path with DMA mapping operations debug
enabled.

[  345.637919] ------------[ cut here ]------------
[  345.637971] WARNING: at lib/dma-debug.c:937 check_unmap+0x4df/0x910()
[  345.637977] Hardware name: System Name
[  345.637987] sis900 0000:00:01.1: DMA-API: device driver failed to check map error[device address=0x000000000d4aed02] [si
ze=60 bytes] [mapped as single]
[  345.637993] Modules linked in: bridge stp llc dmfe sundance 3c59x sis900
[  345.638022] Pid: 0, comm: swapper Not tainted 3.9.0-rc6+ #4
[  345.638028] Call Trace:
[  345.638042]  [<c122097f>] ? check_unmap+0x4df/0x910
[  345.638059]  [<c102b19c>] warn_slowpath_common+0x7c/0xa0
[  345.638070]  [<c122097f>] ? check_unmap+0x4df/0x910
[  345.638081]  [<c102b23e>] warn_slowpath_fmt+0x2e/0x30
[  345.638092]  [<c122097f>] check_unmap+0x4df/0x910
[  345.638107]  [<c100bfeb>] ? save_stack_trace+0x2b/0x50
[  345.638120]  [<c107238e>] ? mark_lock+0x31e/0x5d0
[  345.638132]  [<c1072b2c>] ? __lock_acquire+0x4ec/0x7d0
[  345.638143]  [<c1220f6d>] debug_dma_unmap_page+0x6d/0x80
[  345.638166]  [<cf834dec>] sis900_interrupt+0x49c/0x860 [sis900]
[  345.638195]  [<c1094b73>] handle_irq_event_percpu+0x43/0x1c0
[  345.638206]  [<c1094d1e>] ? handle_irq_event+0x2e/0x60
[  345.638217]  [<c1094d27>] handle_irq_event+0x37/0x60
[  345.638235]  [<c10973f0>] ? irq_set_chip_data+0x40/0x40
[  345.638246]  [<c1097442>] handle_level_irq+0x52/0xa0
[  345.638251]  <IRQ>  [<c1003629>] ? do_IRQ+0x39/0xa0
[  345.638293]  [<c1484631>] ? common_interrupt+0x31/0x36
[  345.638347]  [<d08c2c52>] ? br_flood_forward+0x12/0x20 [bridge]
[  345.638364]  [<d08c2d40>] ? br_dev_queue_push_xmit+0x60/0x60 [bridge]
[  345.638381]  [<d08c3b2b>] ? br_handle_frame_finish+0x25b/0x280 [bridge]
[  345.638399]  [<d08c3ce3>] ? br_handle_frame+0x193/0x290 [bridge]
[  345.638416]  [<d08c3b50>] ? br_handle_frame_finish+0x280/0x280 [bridge]
[  345.638431]  [<c13b3c87>] ? __netif_receive_skb_core+0x1d7/0x710
[  345.638442]  [<c13b3b19>] ? __netif_receive_skb_core+0x69/0x710
[  345.638454]  [<c13b41e1>] ? __netif_receive_skb+0x21/0x70
[  345.638464]  [<c13b42b5>] ? process_backlog+0x85/0x130
[  345.638476]  [<c13b4bbb>] ? net_rx_action+0xfb/0x1d0
[  345.638497]  [<c1032768>] ? __do_softirq+0xa8/0x1f0
[  345.638527]  [<c147daad>] ? _raw_spin_unlock+0x1d/0x20
[  345.638538]  [<c10038c0>] ? handle_irq+0x20/0xd0
[  345.638550]  [<c1032f27>] ? irq_exit+0x97/0xa0
[  345.638560]  [<c1003632>] ? do_IRQ+0x42/0xa0
[  345.638580]  [<c104d003>] ? hrtimer_start+0x23/0x30
[  345.638580]  [<c1484631>] ? common_interrupt+0x31/0x36
[  345.638580]  [<c1008703>] ? default_idle+0x33/0xc0
[  345.638580]  [<c10086ac>] ? cpu_idle+0x4c/0x70
[  345.638580]  [<c14787e0>] ? rest_init+0xa0/0xb0
[  345.638580]  [<c1478740>] ? reciprocal_value+0x50/0x50
[  345.638580]  [<c16b5bcf>] ? start_kernel+0x28f/0x320
[  345.638580]  [<c16b54e0>] ? repair_env_string+0x60/0x60
[  345.638580]  [<c16b5269>] ? i386_start_kernel+0x39/0xa0
[  345.638580] ---[ end trace a244264b69b8a7ae ]---
[  345.638580] Mapped at:
[  345.638580]  [<c1221c65>] debug_dma_map_page+0x65/0x110
[  345.638580]  [<cf8355a9>] sis900_start_xmit+0x129/0x210 [sis900]
[  345.638580]  [<c13b2527>] dev_hard_start_xmit+0x1b7/0x530
[  345.638580]  [<c13cc32e>] sch_direct_xmit+0x8e/0x280
[  345.638580]  [<c13b4e39>] dev_queue_xmit+0x1a9/0x5b0

Signed-off-by: Denis Kirjanov <kda@linux-powerpc.org>
---
 drivers/net/ethernet/sis/sis900.c | 34 ++++++++++++++++++++++++++++++----
 1 file changed, 30 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/sis/sis900.c b/drivers/net/ethernet/sis/sis900.c
index e458296..eb4aea3 100644
--- a/drivers/net/ethernet/sis/sis900.c
+++ b/drivers/net/ethernet/sis/sis900.c
@@ -1187,8 +1187,14 @@ sis900_init_rx_ring(struct net_device *net_dev)
 		}
 		sis_priv->rx_skbuff[i] = skb;
 		sis_priv->rx_ring[i].cmdsts = RX_BUF_SIZE;
-                sis_priv->rx_ring[i].bufptr = pci_map_single(sis_priv->pci_dev,
-                        skb->data, RX_BUF_SIZE, PCI_DMA_FROMDEVICE);
+		sis_priv->rx_ring[i].bufptr = pci_map_single(sis_priv->pci_dev,
+				skb->data, RX_BUF_SIZE, PCI_DMA_FROMDEVICE);
+		if (unlikely(pci_dma_mapping_error(sis_priv->pci_dev,
+				sis_priv->rx_ring[i].bufptr))) {
+			dev_kfree_skb(skb);
+			sis_priv->rx_skbuff[i] = NULL;
+			break;
+		}
 	}
 	sis_priv->dirty_rx = (unsigned int) (i - NUM_RX_DESC);
 
@@ -1621,6 +1627,14 @@ sis900_start_xmit(struct sk_buff *skb, struct net_device *net_dev)
 	/* set the transmit buffer descriptor and enable Transmit State Machine */
 	sis_priv->tx_ring[entry].bufptr = pci_map_single(sis_priv->pci_dev,
 		skb->data, skb->len, PCI_DMA_TODEVICE);
+	if (unlikely(pci_dma_mapping_error(sis_priv->pci_dev,
+		sis_priv->tx_ring[entry].bufptr))) {
+			dev_kfree_skb(skb);
+			sis_priv->tx_skbuff[entry] = NULL;
+			net_dev->stats.tx_dropped++;
+			spin_unlock_irqrestore(&sis_priv->lock, flags);
+			return NETDEV_TX_OK;
+	}
 	sis_priv->tx_ring[entry].cmdsts = (OWN | skb->len);
 	sw32(cr, TxENA | sr32(cr));
 
@@ -1824,9 +1838,15 @@ static int sis900_rx(struct net_device *net_dev)
 refill_rx_ring:
 			sis_priv->rx_skbuff[entry] = skb;
 			sis_priv->rx_ring[entry].cmdsts = RX_BUF_SIZE;
-                	sis_priv->rx_ring[entry].bufptr =
+			sis_priv->rx_ring[entry].bufptr =
 				pci_map_single(sis_priv->pci_dev, skb->data,
 					RX_BUF_SIZE, PCI_DMA_FROMDEVICE);
+			if (unlikely(pci_dma_mapping_error(sis_priv->pci_dev,
+				sis_priv->rx_ring[entry].bufptr))) {
+				dev_kfree_skb_irq(skb);
+				sis_priv->rx_skbuff[entry] = NULL;
+				break;
+			}
 		}
 		sis_priv->cur_rx++;
 		entry = sis_priv->cur_rx % NUM_RX_DESC;
@@ -1852,9 +1872,15 @@ refill_rx_ring:
 			}
 			sis_priv->rx_skbuff[entry] = skb;
 			sis_priv->rx_ring[entry].cmdsts = RX_BUF_SIZE;
-                	sis_priv->rx_ring[entry].bufptr =
+			sis_priv->rx_ring[entry].bufptr =
 				pci_map_single(sis_priv->pci_dev, skb->data,
 					RX_BUF_SIZE, PCI_DMA_FROMDEVICE);
+			if (unlikely(pci_dma_mapping_error(sis_priv->pci_dev,
+					sis_priv->rx_ring[entry].bufptr))) {
+				dev_kfree_skb_irq(skb);
+				sis_priv->rx_skbuff[entry] = NULL;
+				break;
+			}
 		}
 	}
 	/* re-enable the potentially idle receive state matchine */
-- 
1.8.0.2
