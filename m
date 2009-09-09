From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH] niu: Use resource_size instead of private function
Date: Wed,  9 Sep 2009 09:25:50 +0200
Message-ID: <1252481150-12166-1-git-send-email-tklauser@distanz.ch>
Cc: netdev@vger.kernel.org, Tobias Klauser <tklauser@distanz.ch>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.zhaw.ch ([160.85.104.51]:63769 "EHLO mx2.zhaw.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751622AbZIIHZt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Sep 2009 03:25:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The function res_size in drivers/net/niu.c is a copy of resource_size in
linux/ioport.h. Remove the function and use resource_size instead.

Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 drivers/net/niu.c |   23 +++++++++--------------
 1 files changed, 9 insertions(+), 14 deletions(-)

diff --git a/drivers/net/niu.c b/drivers/net/niu.c
index 119fd4e..76cc261 100644
--- a/drivers/net/niu.c
+++ b/drivers/net/niu.c
@@ -10145,11 +10145,6 @@ static const struct niu_ops niu_phys_ops = {
 	.unmap_single	= niu_phys_unmap_single,
 };
 
-static unsigned long res_size(struct resource *r)
-{
-	return r->end - r->start + 1UL;
-}
-
 static int __devinit niu_of_probe(struct of_device *op,
 				  const struct of_device_id *match)
 {
@@ -10189,7 +10184,7 @@ static int __devinit niu_of_probe(struct of_device *op,
 	dev->features |= (NETIF_F_SG | NETIF_F_HW_CSUM);
 
 	np->regs = of_ioremap(&op->resource[1], 0,
-			      res_size(&op->resource[1]),
+			      resource_size(&op->resource[1]),
 			      "niu regs");
 	if (!np->regs) {
 		dev_err(&op->dev, PFX "Cannot map device registers, "
@@ -10199,7 +10194,7 @@ static int __devinit niu_of_probe(struct of_device *op,
 	}
 
 	np->vir_regs_1 = of_ioremap(&op->resource[2], 0,
-				    res_size(&op->resource[2]),
+				    resource_size(&op->resource[2]),
 				    "niu vregs-1");
 	if (!np->vir_regs_1) {
 		dev_err(&op->dev, PFX "Cannot map device vir registers 1, "
@@ -10209,7 +10204,7 @@ static int __devinit niu_of_probe(struct of_device *op,
 	}
 
 	np->vir_regs_2 = of_ioremap(&op->resource[3], 0,
-				    res_size(&op->resource[3]),
+				    resource_size(&op->resource[3]),
 				    "niu vregs-2");
 	if (!np->vir_regs_2) {
 		dev_err(&op->dev, PFX "Cannot map device vir registers 2, "
@@ -10244,19 +10239,19 @@ static int __devinit niu_of_probe(struct of_device *op,
 err_out_iounmap:
 	if (np->vir_regs_1) {
 		of_iounmap(&op->resource[2], np->vir_regs_1,
-			   res_size(&op->resource[2]));
+			   resource_size(&op->resource[2]));
 		np->vir_regs_1 = NULL;
 	}
 
 	if (np->vir_regs_2) {
 		of_iounmap(&op->resource[3], np->vir_regs_2,
-			   res_size(&op->resource[3]));
+			   resource_size(&op->resource[3]));
 		np->vir_regs_2 = NULL;
 	}
 
 	if (np->regs) {
 		of_iounmap(&op->resource[1], np->regs,
-			   res_size(&op->resource[1]));
+			   resource_size(&op->resource[1]));
 		np->regs = NULL;
 	}
 
@@ -10281,19 +10276,19 @@ static int __devexit niu_of_remove(struct of_device *op)
 
 		if (np->vir_regs_1) {
 			of_iounmap(&op->resource[2], np->vir_regs_1,
-				   res_size(&op->resource[2]));
+				   resource_size(&op->resource[2]));
 			np->vir_regs_1 = NULL;
 		}
 
 		if (np->vir_regs_2) {
 			of_iounmap(&op->resource[3], np->vir_regs_2,
-				   res_size(&op->resource[3]));
+				   resource_size(&op->resource[3]));
 			np->vir_regs_2 = NULL;
 		}
 
 		if (np->regs) {
 			of_iounmap(&op->resource[1], np->regs,
-				   res_size(&op->resource[1]));
+				   resource_size(&op->resource[1]));
 			np->regs = NULL;
 		}
 
-- 
1.6.0.4

