From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH v2 2/5] drivers: net: xgene: fix sharing of irqs
Date: Fri, 13 May 2016 16:52:58 -0700
Message-ID: <1463183581-30475-3-git-send-email-isubramanian@apm.com>
References: <1463183581-30475-1-git-send-email-isubramanian@apm.com>
Cc: linux-arm-kernel@lists.infradead.org, patches@apm.com,
	toanle@apm.com, Iyappan Subramanian <isubramanian@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:34197 "EHLO
	mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753774AbcEMXwJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 May 2016 19:52:09 -0400
Received: by mail-pf0-f179.google.com with SMTP id y69so46750448pfb.1
        for <netdev@vger.kernel.org>; Fri, 13 May 2016 16:52:09 -0700 (PDT)
In-Reply-To: <1463183581-30475-1-git-send-email-isubramanian@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since hardware doesn't allow sharing of interrupts,
this patch fixes the same by removing IRQF_SHARED flag.

Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
Tested-by: Toan Le <toanle@apm.com>
---
 drivers/net/ethernet/apm/xgene/xgene_enet_main.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
index aa87049..ed90664 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
@@ -630,7 +630,7 @@ static int xgene_enet_register_irq(struct net_device *ndev)
 		ring = pdata->rx_ring[i];
 		irq_set_status_flags(ring->irq, IRQ_DISABLE_UNLAZY);
 		ret = devm_request_irq(dev, ring->irq, xgene_enet_rx_irq,
-				       IRQF_SHARED, ring->irq_name, ring);
+				       0, ring->irq_name, ring);
 		if (ret) {
 			netdev_err(ndev, "Failed to request irq %s\n",
 				   ring->irq_name);
@@ -641,7 +641,7 @@ static int xgene_enet_register_irq(struct net_device *ndev)
 		ring = pdata->tx_ring[i]->cp_ring;
 		irq_set_status_flags(ring->irq, IRQ_DISABLE_UNLAZY);
 		ret = devm_request_irq(dev, ring->irq, xgene_enet_rx_irq,
-				       IRQF_SHARED, ring->irq_name, ring);
+				       0, ring->irq_name, ring);
 		if (ret) {
 			netdev_err(ndev, "Failed to request irq %s\n",
 				   ring->irq_name);
-- 
1.9.1
