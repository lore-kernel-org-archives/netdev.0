From: Michael Opdenacker <michael.opdenacker@free-electrons.com>
Subject: [PATCH] net: lantiq_etop: remove deprecated IRQF_DISABLED
Date: Fri, 13 Sep 2013 05:59:42 +0200
Message-ID: <1379044782-6542-1-git-send-email-michael.opdenacker@free-electrons.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Michael Opdenacker <michael.opdenacker@free-electrons.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from top.free-electrons.com ([176.31.233.9]:42890 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753160Ab3IMD7w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Sep 2013 23:59:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch proposes to remove the IRQF_DISABLED flag from
drivers/net/ethernet/lantiq_etop.c

It's a NOOP since 2.6.35 and it will be removed one day.

Signed-off-by: Michael Opdenacker <michael.opdenacker@free-electrons.com>
---
 drivers/net/ethernet/lantiq_etop.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/lantiq_etop.c b/drivers/net/ethernet/lantiq_etop.c
index bfdb0686..6a6c1f7 100644
--- a/drivers/net/ethernet/lantiq_etop.c
+++ b/drivers/net/ethernet/lantiq_etop.c
@@ -282,8 +282,7 @@ ltq_etop_hw_init(struct net_device *dev)
 
 		if (IS_TX(i)) {
 			ltq_dma_alloc_tx(&ch->dma);
-			request_irq(irq, ltq_etop_dma_irq, IRQF_DISABLED,
-				"etop_tx", priv);
+			request_irq(irq, ltq_etop_dma_irq, 0, "etop_tx", priv);
 		} else if (IS_RX(i)) {
 			ltq_dma_alloc_rx(&ch->dma);
 			for (ch->dma.desc = 0; ch->dma.desc < LTQ_DESC_NUM;
@@ -291,8 +290,7 @@ ltq_etop_hw_init(struct net_device *dev)
 				if (ltq_etop_alloc_skb(ch))
 					return -ENOMEM;
 			ch->dma.desc = 0;
-			request_irq(irq, ltq_etop_dma_irq, IRQF_DISABLED,
-				"etop_rx", priv);
+			request_irq(irq, ltq_etop_dma_irq, 0, "etop_rx", priv);
 		}
 		ch->dma.irq = irq;
 	}
-- 
1.8.1.2
