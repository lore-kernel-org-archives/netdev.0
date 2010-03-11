From: Grant Likely <grant.likely@secretlab.ca>
Subject: [PATCH 16/37] drivers/sbus: use .dev.of_node instead of .node in
	struct of_device
Date: Thu, 11 Mar 2010 11:05:16 -0700
Message-ID: <20100311180515.4824.50590.stgit__37523.6336527907$1268331447$gmane$org@angua>
References: <20100311174830.4824.19820.stgit@angua>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: monstr@monstr.eu, gregkh@suse.de, benh@kernel.crashing.org,
	akpm@linux-foundation.org, davem@davemloft.net,
	sfr@canb.auug.org.au, jgarzik@pobox.com, ben-linux@fluff.org,
	dwmw2@infrade
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:63703 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933665Ab0CKSFZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Mar 2010 13:05:25 -0500
In-Reply-To: <20100311174830.4824.19820.stgit@angua>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

.node is being removed

Signed-off-by: Grant Likely <grant.likely@secretlab.ca>
---

 drivers/sbus/char/bbc_envctrl.c |    4 ++--
 drivers/sbus/char/bbc_i2c.c     |    4 ++--
 drivers/sbus/char/display7seg.c |    2 +-
 drivers/sbus/char/envctrl.c     |    2 +-
 drivers/sbus/char/flash.c       |    4 ++--
 drivers/sbus/char/uctrl.c       |    2 +-
 6 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/drivers/sbus/char/bbc_envctrl.c b/drivers/sbus/char/bbc_envctrl.c
index 28d86f9..53c0230 100644
--- a/drivers/sbus/char/bbc_envctrl.c
+++ b/drivers/sbus/char/bbc_envctrl.c
@@ -564,9 +564,9 @@ int bbc_envctrl_init(struct bbc_i2c_bus *bp)
 	int devidx = 0;
 
 	while ((op = bbc_i2c_getdev(bp, devidx++)) != NULL) {
-		if (!strcmp(op->node->name, "temperature"))
+		if (!strcmp(op->dev.of_node->name, "temperature"))
 			attach_one_temp(bp, op, temp_index++);
-		if (!strcmp(op->node->name, "fan-control"))
+		if (!strcmp(op->dev.of_node->name, "fan-control"))
 			attach_one_fan(bp, op, fan_index++);
 	}
 	if (temp_index != 0 && fan_index != 0) {
diff --git a/drivers/sbus/char/bbc_i2c.c b/drivers/sbus/char/bbc_i2c.c
index 7e30e5f..1543ac3 100644
--- a/drivers/sbus/char/bbc_i2c.c
+++ b/drivers/sbus/char/bbc_i2c.c
@@ -97,7 +97,7 @@ struct bbc_i2c_client *bbc_i2c_attach(struct bbc_i2c_bus *bp, struct of_device *
 	client->bp = bp;
 	client->op = op;
 
-	reg = of_get_property(op->node, "reg", NULL);
+	reg = of_get_property(op->dev.of_node, "reg", NULL);
 	if (!reg) {
 		kfree(client);
 		return NULL;
@@ -327,7 +327,7 @@ static struct bbc_i2c_bus * __init attach_one_i2c(struct of_device *op, int inde
 	spin_lock_init(&bp->lock);
 
 	entry = 0;
-	for (dp = op->node->child;
+	for (dp = op->dev.of_node->child;
 	     dp && entry < 8;
 	     dp = dp->sibling, entry++) {
 		struct of_device *child_op;
diff --git a/drivers/sbus/char/display7seg.c b/drivers/sbus/char/display7seg.c
index 4431578..d0a10f4 100644
--- a/drivers/sbus/char/display7seg.c
+++ b/drivers/sbus/char/display7seg.c
@@ -215,7 +215,7 @@ static int __devinit d7s_probe(struct of_device *op,
 	writeb(regs,  p->regs);
 
 	printk(KERN_INFO PFX "7-Segment Display%s at [%s:0x%llx] %s\n",
-	       op->node->full_name,
+	       op->dev.of_node->full_name,
 	       (regs & D7S_FLIP) ? " (FLIPPED)" : "",
 	       op->resource[0].start,
 	       sol_compat ? "in sol_compat mode" : "");
diff --git a/drivers/sbus/char/envctrl.c b/drivers/sbus/char/envctrl.c
index aa2b60a..84a4310 100644
--- a/drivers/sbus/char/envctrl.c
+++ b/drivers/sbus/char/envctrl.c
@@ -1042,7 +1042,7 @@ static int __devinit envctrl_probe(struct of_device *op,
 		return -ENOMEM;
 
 	index = 0;
-	dp = op->node->child;
+	dp = op->dev.of_node->child;
 	while (dp) {
 		if (!strcmp(dp->name, "gpio")) {
 			i2c_childlist[index].i2ctype = I2C_GPIO;
diff --git a/drivers/sbus/char/flash.c b/drivers/sbus/char/flash.c
index 4108347..dc8f95d 100644
--- a/drivers/sbus/char/flash.c
+++ b/drivers/sbus/char/flash.c
@@ -163,7 +163,7 @@ static struct miscdevice flash_dev = { FLASH_MINOR, "flash", &flash_fops };
 static int __devinit flash_probe(struct of_device *op,
 				 const struct of_device_id *match)
 {
-	struct device_node *dp = op->node;
+	struct device_node *dp = op->dev.of_node;
 	struct device_node *parent;
 
 	parent = dp->parent;
@@ -185,7 +185,7 @@ static int __devinit flash_probe(struct of_device *op,
 	flash.busy = 0;
 
 	printk(KERN_INFO "%s: OBP Flash, RD %lx[%lx] WR %lx[%lx]\n",
-	       op->node->full_name,
+	       op->dev.of_node->full_name,
 	       flash.read_base, flash.read_size,
 	       flash.write_base, flash.write_size);
 
diff --git a/drivers/sbus/char/uctrl.c b/drivers/sbus/char/uctrl.c
index 2c56fd5..acc6738 100644
--- a/drivers/sbus/char/uctrl.c
+++ b/drivers/sbus/char/uctrl.c
@@ -382,7 +382,7 @@ static int __devinit uctrl_probe(struct of_device *op,
 
 	sbus_writel(UCTRL_INTR_RXNE_REQ|UCTRL_INTR_RXNE_MSK, &p->regs->uctrl_intr);
 	printk(KERN_INFO "%s: uctrl regs[0x%p] (irq %d)\n",
-	       op->node->full_name, p->regs, p->irq);
+	       op->dev.of_node->full_name, p->regs, p->irq);
 	uctrl_get_event_status(p);
 	uctrl_get_external_status(p);
 

