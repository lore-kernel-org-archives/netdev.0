From: Brice Goglin <brice@myri.com>
Subject: [PATCH 2/2] myri10ge: set 64bits consistent DMA mask
Date: Wed, 06 Aug 2008 16:15:23 +0200
Message-ID: <4899B1FB.8070700@myri.com>
References: <4899B198.1060508@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:2015 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754844AbYHFOPu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Aug 2008 10:15:50 -0400
In-Reply-To: <4899B198.1060508@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Set 64bits consistent DMA mask since it improves performance
in some cases. No need to check the return value since it is
not required for the driver to work.

Signed-off-by: Brice Goglin <brice@myri.com> 
---
 drivers/net/myri10ge/myri10ge.c |    1 +
 1 file changed, 1 insertion(+)

Index: linux-2.6/drivers/net/myri10ge/myri10ge.c
===================================================================
--- linux-2.6.orig/drivers/net/myri10ge/myri10ge.c	2008-07-23 09:18:21.000000000 +0200
+++ linux-2.6/drivers/net/myri10ge/myri10ge.c	2008-08-04 13:22:14.000000000 +0200
@@ -3699,6 +3699,7 @@
 		dev_err(&pdev->dev, "Error %d setting DMA mask\n", status);
 		goto abort_with_netdev;
 	}
+	(void)pci_set_consistent_dma_mask(pdev, DMA_64BIT_MASK);
 	mgp->cmd = dma_alloc_coherent(&pdev->dev, sizeof(*mgp->cmd),
 				      &mgp->cmd_bus, GFP_KERNEL);
 	if (mgp->cmd == NULL)


