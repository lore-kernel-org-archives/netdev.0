From: Alexander Beregalov <a.beregalov@gmail.com>
Subject: [PATCH] irda: fix incomplete conversation to internal stats
Date: Fri, 9 Jan 2009 03:14:21 +0300
Message-ID: <20090109001421.GA22382@orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org, shemminger@vyatta.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f21.google.com ([209.85.218.21]:33959 "EHLO
	mail-bw0-f21.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755704AbZAIAOc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jan 2009 19:14:32 -0500
Received: by bwz14 with SMTP id 14so28234954bwz.13
        for <netdev@vger.kernel.org>; Thu, 08 Jan 2009 16:14:30 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix for commit af0490810c (irda: convert to internal stats)

Signed-off-by: Alexander Beregalov <a.beregalov@gmail.com>
---

 drivers/net/irda/au1k_ir.c  |    2 +-
 drivers/net/irda/donauboe.c |    8 ++++----
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/irda/au1k_ir.c b/drivers/net/irda/au1k_ir.c
index 75a1d0a..9411640 100644
--- a/drivers/net/irda/au1k_ir.c
+++ b/drivers/net/irda/au1k_ir.c
@@ -594,7 +594,7 @@ static int au1k_irda_rx(struct net_device *dev)
 			update_rx_stats(dev, flags, count);
 			skb=alloc_skb(count+1,GFP_ATOMIC);
 			if (skb == NULL) {
-				aup->stats.rx_dropped++;
+				aup->netdev->stats.rx_dropped++;
 				continue;
 			}
 			skb_reserve(skb, 1);
diff --git a/drivers/net/irda/donauboe.c b/drivers/net/irda/donauboe.c
index 687c2d5..6f3e7f7 100644
--- a/drivers/net/irda/donauboe.c
+++ b/drivers/net/irda/donauboe.c
@@ -1194,13 +1194,13 @@ toshoboe_interrupt (int irq, void *dev_id)
               txp = txpc;
               txpc++;
               txpc %= TX_SLOTS;
-              self->stats.tx_packets++;
+              self->netdev->stats.tx_packets++;
               if (self->ring->tx[txpc].control & OBOE_CTL_TX_HW_OWNS)
                   self->ring->tx[txp].control &= ~OBOE_CTL_TX_RTCENTX;
             }
-          self->stats.tx_packets--;
+          self->netdev->stats.tx_packets--;
 #else
-          self->stats.tx_packets++;
+          self->netdev->stats.tx_packets++;
 #endif
           toshoboe_start_DMA(self, OBOE_CONFIG0H_ENTX);
         }
@@ -1280,7 +1280,7 @@ dumpbufs(self->rx_bufs[self->rxs],len,'<');
                       skb_put (skb, len);
                       skb_copy_to_linear_data(skb, self->rx_bufs[self->rxs],
 					      len);
-                      self->stats.rx_packets++;
+                      self->netdev->stats.rx_packets++;
                       skb->dev = self->netdev;
                       skb_reset_mac_header(skb);
                       skb->protocol = htons (ETH_P_IRDA);
