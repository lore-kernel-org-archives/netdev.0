From: Grant Likely <grant.likely@secretlab.ca>
Subject: [PATCH] net/fec_mpc52xx: fix BUG on missing dma_ops
Date: Mon, 30 Mar 2009 12:53:14 -0600
Message-ID: <20090330184423.31699.61150.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.236]:56861 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756286AbZC3SxS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Mar 2009 14:53:18 -0400
Received: by rv-out-0506.google.com with SMTP id f9so2586196rvb.1
        for <netdev@vger.kernel.org>; Mon, 30 Mar 2009 11:53:16 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Grant Likely <grant.likely@secretlab.ca>

The driver triggers a BUG_ON() when allocating DMA buffers if the
arch/powerpc dma_ops from the of_platform device are not copied
into net_device structure.

Signed-off-by: Grant Likely <grant.likely@secretlab.ca>
---
David, do you want to pick this one up right away, or should I merge it
through Ben's powerpc tree?

g.

 drivers/net/fec_mpc52xx.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)


diff --git a/drivers/net/fec_mpc52xx.c b/drivers/net/fec_mpc52xx.c
index 049b0a7..215207d 100644
--- a/drivers/net/fec_mpc52xx.c
+++ b/drivers/net/fec_mpc52xx.c
@@ -928,6 +928,9 @@ mpc52xx_fec_probe(struct of_device *op, const struct of_device_id *match)
 	if (!request_mem_region(mem.start, sizeof(struct mpc52xx_fec), DRIVER_NAME))
 		return -EBUSY;
 
+	/* Copy the PowerPC dma_ops from the of_device */
+	set_dma_ops(&ndev->dev, get_dma_ops(&op->dev));
+
 	/* Init ether ndev with what we have */
 	ndev->open		= mpc52xx_fec_open;
 	ndev->stop		= mpc52xx_fec_close;

