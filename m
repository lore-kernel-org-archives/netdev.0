From: Kukjin Kim <kgene@kernel.org>
Subject: [PATCH] net: sxgbe: Fix NULL dereferece when using DT
Date: Thu, 15 Jan 2015 10:41:47 +0900
Message-ID: <1421286107-9514-1-git-send-email-kgene@kernel.org>
Cc: Dave Miller <davem@davemloft.ne>,
	"Girish K.S" <ks.giri@samsung.com>,
	Byungho An <bh74.an@samsung.com>, Kukjin Kim <kgene@kernel.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout4.samsung.com ([203.254.224.34]:26702 "EHLO
	mailout4.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750826AbbAOBlp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2015 20:41:45 -0500
Received: from epcpsbgm1.samsung.com (epcpsbgm1 [203.254.230.26])
 by mailout4.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NI700DQV3DJAQ80@mailout4.samsung.com> for
 netdev@vger.kernel.org; Thu, 15 Jan 2015 10:41:43 +0900 (KST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Girish K.S <ks.giri@samsung.com>

When the MAC address is provided in the device tree file, the
condition is true and kernel crashes due to NULL dereference.

Signed-off-by: Girish K.S <ks.giri@samsung.com>
Signed-off-by: Byungho An <bh74.an@samsung.com>
Signed-off-by: Kukjin Kim <kgene@kernel.org>
---
 drivers/net/ethernet/samsung/sxgbe/sxgbe_platform.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/samsung/sxgbe/sxgbe_platform.c b/drivers/net/ethernet/samsung/sxgbe/sxgbe_platform.c
index 866560e..b02eed1 100644
--- a/drivers/net/ethernet/samsung/sxgbe/sxgbe_platform.c
+++ b/drivers/net/ethernet/samsung/sxgbe/sxgbe_platform.c
@@ -108,10 +108,6 @@ static int sxgbe_platform_probe(struct platform_device *pdev)
 		}
 	}
 
-	/* Get MAC address if available (DT) */
-	if (mac)
-		ether_addr_copy(priv->dev->dev_addr, mac);
-
 	priv = sxgbe_drv_probe(&(pdev->dev), plat_dat, addr);
 	if (!priv) {
 		pr_err("%s: main driver probe failed\n", __func__);
@@ -125,6 +121,10 @@ static int sxgbe_platform_probe(struct platform_device *pdev)
 		goto err_drv_remove;
 	}
 
+	/* Get MAC address if available (DT) */
+	if (mac)
+		ether_addr_copy(priv->dev->dev_addr, mac);
+
 	/* Get the TX/RX IRQ numbers */
 	for (i = 0, chan = 1; i < SXGBE_TX_QUEUES; i++) {
 		priv->txq[i]->irq_no = irq_of_parse_and_map(node, chan++);
-- 
2.0.0
