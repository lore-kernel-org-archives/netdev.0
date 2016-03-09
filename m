From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH 2/2] drivers: net: xgene: fix: Remove IRQF_SHARED flag
Date: Tue,  8 Mar 2016 21:49:37 -0800
Message-ID: <1457502577-2606-3-git-send-email-isubramanian@apm.com>
References: <1457502577-2606-1-git-send-email-isubramanian@apm.com>
Cc: linux-arm-kernel@lists.infradead.org, patches@apm.com,
	toanle@apm.com, Iyappan Subramanian <isubramanian@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:35186 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751107AbcCIFtT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Mar 2016 00:49:19 -0500
Received: by mail-pa0-f50.google.com with SMTP id td3so3966398pab.2
        for <netdev@vger.kernel.org>; Tue, 08 Mar 2016 21:49:18 -0800 (PST)
In-Reply-To: <1457502577-2606-1-git-send-email-isubramanian@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Not allowing sharing of IRQs.

Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
Tested-by: Toan Le <toanle@apm.com>
---
 drivers/net/ethernet/apm/xgene/xgene_enet_main.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
index 0878aec..f68c187 100644
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
