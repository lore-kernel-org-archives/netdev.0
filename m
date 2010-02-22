From: gfilip@ee.ethz.ch
Subject: [PATCH 3/5] temac: dma deinit
Date: Mon, 22 Feb 2010 20:06:59 +0100
Message-ID: <1266865621-28955-3-git-send-email-gfilip@ee.ethz.ch>
References: <1266865621-28955-1-git-send-email-gfilip@ee.ethz.ch>
 <1266865621-28955-2-git-send-email-gfilip@ee.ethz.ch>
Cc: glikely@secretlab.ca, Filip Gospodinov <gfilip@ee.ethz.ch>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ee.ethz.ch ([129.132.2.219]:56360 "EHLO smtp.ee.ethz.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753506Ab0BVTOh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Feb 2010 14:14:37 -0500
In-Reply-To: <1266865621-28955-2-git-send-email-gfilip@ee.ethz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch belongs to a set of patches which extends the temac driver to support Virtex4-FX. It was successfully tested on the ML403 evaluation board.

Signed-off-by: Filip Gospodinov <gfilip@ee.ethz.ch>
---
 drivers/net/ll_temac_main.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ll_temac_main.c b/drivers/net/ll_temac_main.c
index 0d4b1c5..2e7421c 100644
--- a/drivers/net/ll_temac_main.c
+++ b/drivers/net/ll_temac_main.c
@@ -946,6 +946,9 @@ static int __devexit temac_of_remove(struct of_device *op)
 	if (lp->phy_node)
 		of_node_put(lp->phy_node);
 	lp->phy_node = NULL;
+#ifdef CONFIG_XILINX_VIRTEX_4_FX
+	iounmap((void *) lp->dma_regs);
+#endif
 	dev_set_drvdata(&op->dev, NULL);
 	free_netdev(ndev);
 	return 0;
-- 
1.6.4.4

