From: "Samuel Ortiz" <samuel@sortiz.org>
Subject: [PATCH 1/4] irda: via-ircc proper dma freeing
Date: Mon, 30 Jun 2008 21:23:52 +0200
Message-ID: <20080630192753.854146476@sortiz.org>
References: <20080630192351.765611690@sortiz.org>
Cc: netdev@vger.kernel.org, irda-users@lists.sourceforge.net,
	Wang Chen <wangchen@cn.fujitsu.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2b.orange.fr ([80.12.242.146]:18760 "EHLO smtp2b.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751762AbYF3T0Y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Jun 2008 15:26:24 -0400
Content-Disposition: inline; filename=dma_cleanup.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wang Chen <wangchen@cn.fujitsu.com>

1. dma should be freed when dma2 request fail.
2. dma2 should be freed too when device close.

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
Signed-off-by: Samuel Ortiz <samuel@sortiz.org>
---
 drivers/net/irda/via-ircc.c |    3 +++
 1 file changed, 3 insertions(+)

Index: net-next-2.6/drivers/net/irda/via-ircc.c
===================================================================
--- net-next-2.6.orig/drivers/net/irda/via-ircc.c	2008-06-14 13:20:23.000000000 +0200
+++ net-next-2.6/drivers/net/irda/via-ircc.c	2008-06-14 13:25:18.000000000 +0200
@@ -1546,6 +1546,7 @@ static int via_ircc_net_open(struct net_
 			IRDA_WARNING("%s, unable to allocate dma2=%d\n",
 				     driver_name, self->io.dma2);
 			free_irq(self->io.irq, self);
+			free_dma(self->io.dma);
 			return -EAGAIN;
 		}
 	}
@@ -1606,6 +1607,8 @@ static int via_ircc_net_close(struct net
 	EnAllInt(iobase, OFF);
 	free_irq(self->io.irq, dev);
 	free_dma(self->io.dma);
+	if (self->io.dma2 != self->io.dma)
+		free_dma(self->io.dma2);
 
 	return 0;
 }

-- 

