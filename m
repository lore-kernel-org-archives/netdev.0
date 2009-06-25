From: Ionut Nicu <ionut.nicu@freescale.com>
Subject: [PATCH] fsl_pq_mdio: Fix fsl_pq_mdio to work with modules
Date: Thu, 25 Jun 2009 11:23:39 +0300
Message-ID: <1245918219-27299-1-git-send-email-ionut.nicu@freescale.com>
Cc: Ionut Nicu <ionut.nicu@freescale.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:34788 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751000AbZFYIXr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jun 2009 04:23:47 -0400
Received: from de01smr01.freescale.net (de01smr01.freescale.net [10.208.0.31])
	by az33egw02.freescale.net (8.14.3/az33egw02) with ESMTP id n5P8NksF028377
	for <netdev@vger.kernel.org>; Thu, 25 Jun 2009 01:23:47 -0700 (MST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes the case when ucc_geth or gianfar are compiled
as modules. Without this patch the call to phy_connect() fails.

Signed-off-by: Ionut Nicu <ionut.nicu@freescale.com>
Acked-by: Andy Fleming <afleming@freescale.com>
---
 drivers/net/fsl_pq_mdio.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/fsl_pq_mdio.c b/drivers/net/fsl_pq_mdio.c
index 3af5813..d167090 100644
--- a/drivers/net/fsl_pq_mdio.c
+++ b/drivers/net/fsl_pq_mdio.c
@@ -188,7 +188,7 @@ static int fsl_pq_mdio_find_free(struct mii_bus *new_bus)
 }
 
 
-#ifdef CONFIG_GIANFAR
+#if defined(CONFIG_GIANFAR) || defined(CONFIG_GIANFAR_MODULE)
 static u32 __iomem *get_gfar_tbipa(struct fsl_pq_mdio __iomem *regs)
 {
 	struct gfar __iomem *enet_regs;
@@ -206,7 +206,7 @@ static u32 __iomem *get_gfar_tbipa(struct fsl_pq_mdio __iomem *regs)
 #endif
 
 
-#ifdef CONFIG_UCC_GETH
+#if defined(CONFIG_UCC_GETH) || defined(CONFIG_UCC_GETH_MODULE)
 static int get_ucc_id_for_range(u64 start, u64 end, u32 *ucc_id)
 {
 	struct device_node *np = NULL;
@@ -291,7 +291,7 @@ static int fsl_pq_mdio_probe(struct of_device *ofdev,
 	if (of_device_is_compatible(np, "fsl,gianfar-mdio") ||
 			of_device_is_compatible(np, "fsl,gianfar-tbi") ||
 			of_device_is_compatible(np, "gianfar")) {
-#ifdef CONFIG_GIANFAR
+#if defined(CONFIG_GIANFAR) || defined(CONFIG_GIANFAR_MODULE)
 		tbipa = get_gfar_tbipa(regs);
 #else
 		err = -ENODEV;
@@ -299,7 +299,7 @@ static int fsl_pq_mdio_probe(struct of_device *ofdev,
 #endif
 	} else if (of_device_is_compatible(np, "fsl,ucc-mdio") ||
 			of_device_is_compatible(np, "ucc_geth_phy")) {
-#ifdef CONFIG_UCC_GETH
+#if defined(CONFIG_UCC_GETH) || defined(CONFIG_UCC_GETH_MODULE)
 		u32 id;
 		static u32 mii_mng_master;
 
-- 
1.6.2.4

