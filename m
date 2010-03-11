From: Grant Likely <grant.likely@secretlab.ca>
Subject: [PATCH 26/37] drivers/mtd: use .dev.of_node instead of .node in
	struct of_device
Date: Thu, 11 Mar 2010 11:06:11 -0700
Message-ID: <20100311180611.4824.60029.stgit__12074.6298264296$1268331239$gmane$org@angua>
References: <20100311174830.4824.19820.stgit@angua>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: monstr@monstr.eu, gregkh@suse.de, benh@kernel.crashing.org,
	akpm@linux-foundation.org, davem@davemloft.net,
	sfr@canb.auug.org.au, jgarzik@pobox.com, ben-linux@fluff.org,
	dwmw2@infrade
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f194.google.com ([209.85.222.194]:34774 "EHLO
	mail-pz0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933744Ab0CKSGO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Mar 2010 13:06:14 -0500
In-Reply-To: <20100311174830.4824.19820.stgit@angua>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

.node is being removed

Signed-off-by: Grant Likely <grant.likely@secretlab.ca>
---

 drivers/mtd/maps/physmap_of.c    |    6 +++---
 drivers/mtd/maps/sun_uflash.c    |    2 +-
 drivers/mtd/nand/fsl_elbc_nand.c |    6 +++---
 drivers/mtd/nand/pasemi_nand.c   |    2 +-
 4 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/mtd/maps/physmap_of.c b/drivers/mtd/maps/physmap_of.c
index 61e4eb4..494af8e 100644
--- a/drivers/mtd/maps/physmap_of.c
+++ b/drivers/mtd/maps/physmap_of.c
@@ -142,7 +142,7 @@ static int of_flash_remove(struct of_device *dev)
 static struct mtd_info * __devinit obsolete_probe(struct of_device *dev,
 						  struct map_info *map)
 {
-	struct device_node *dp = dev->node;
+	struct device_node *dp = dev->dev.of_node;
 	const char *of_probe;
 	struct mtd_info *mtd;
 	static const char *rom_probe_types[]
@@ -179,7 +179,7 @@ static int __devinit of_flash_probe(struct of_device *dev,
 	static const char *part_probe_types[]
 		= { "cmdlinepart", "RedBoot", NULL };
 #endif
-	struct device_node *dp = dev->node;
+	struct device_node *dp = dev->dev.of_node;
 	struct resource res;
 	struct of_flash *info;
 	const char *probe_type = match->data;
@@ -203,7 +203,7 @@ static int __devinit of_flash_probe(struct of_device *dev,
 	p = of_get_property(dp, "reg", &count);
 	if (count % reg_tuple_size != 0) {
 		dev_err(&dev->dev, "Malformed reg property on %s\n",
-				dev->node->full_name);
+				dev->dev.of_node->full_name);
 		err = -EINVAL;
 		goto err_flash_remove;
 	}
diff --git a/drivers/mtd/maps/sun_uflash.c b/drivers/mtd/maps/sun_uflash.c
index fd7a101..365811d 100644
--- a/drivers/mtd/maps/sun_uflash.c
+++ b/drivers/mtd/maps/sun_uflash.c
@@ -109,7 +109,7 @@ int uflash_devinit(struct of_device *op, struct device_node *dp)
 
 static int __devinit uflash_probe(struct of_device *op, const struct of_device_id *match)
 {
-	struct device_node *dp = op->node;
+	struct device_node *dp = op->dev.of_node;
 
 	/* Flashprom must have the "user" property in order to
 	 * be used by this driver.
diff --git a/drivers/mtd/nand/fsl_elbc_nand.c b/drivers/mtd/nand/fsl_elbc_nand.c
index ae30fb6..4a60795 100644
--- a/drivers/mtd/nand/fsl_elbc_nand.c
+++ b/drivers/mtd/nand/fsl_elbc_nand.c
@@ -1030,14 +1030,14 @@ static int __devinit fsl_elbc_ctrl_probe(struct of_device *ofdev,
 	init_waitqueue_head(&ctrl->controller.wq);
 	init_waitqueue_head(&ctrl->irq_wait);
 
-	ctrl->regs = of_iomap(ofdev->node, 0);
+	ctrl->regs = of_iomap(ofdev->dev.of_node, 0);
 	if (!ctrl->regs) {
 		dev_err(&ofdev->dev, "failed to get memory region\n");
 		ret = -ENODEV;
 		goto err;
 	}
 
-	ctrl->irq = of_irq_to_resource(ofdev->node, 0, NULL);
+	ctrl->irq = of_irq_to_resource(ofdev->dev.of_node, 0, NULL);
 	if (ctrl->irq == NO_IRQ) {
 		dev_err(&ofdev->dev, "failed to get irq resource\n");
 		ret = -ENODEV;
@@ -1058,7 +1058,7 @@ static int __devinit fsl_elbc_ctrl_probe(struct of_device *ofdev,
 		goto err;
 	}
 
-	for_each_child_of_node(ofdev->node, child)
+	for_each_child_of_node(ofdev->dev.of_node, child)
 		if (of_device_is_compatible(child, "fsl,elbc-fcm-nand"))
 			fsl_elbc_chip_probe(ctrl, child);
 
diff --git a/drivers/mtd/nand/pasemi_nand.c b/drivers/mtd/nand/pasemi_nand.c
index a8b9376..edfc27b 100644
--- a/drivers/mtd/nand/pasemi_nand.c
+++ b/drivers/mtd/nand/pasemi_nand.c
@@ -93,7 +93,7 @@ static int __devinit pasemi_nand_probe(struct of_device *ofdev,
 				      const struct of_device_id *match)
 {
 	struct pci_dev *pdev;
-	struct device_node *np = ofdev->node;
+	struct device_node *np = ofdev->dev.of_node;
 	struct resource res;
 	struct nand_chip *chip;
 	int err = 0;

