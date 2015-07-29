From: Vladimir Zapolskiy <vz@mleia.com>
Subject: [PATCH] net: phy: spi_ks8995: clean up ks8995_registers_read/write
Date: Thu, 30 Jul 2015 00:44:20 +0300
Message-ID: <1438206260-13465-1-git-send-email-vz@mleia.com>
Cc: netdev@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from li271-223.members.linode.com ([178.79.152.223]:38084 "EHLO
	mail.mleia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752711AbbG2VvL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Jul 2015 17:51:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The change removes redundant sysfs binary file boundary checks,
since this task is already done on caller side in fs/sysfs/file.c

Signed-off-by: Vladimir Zapolskiy <vz@mleia.com>
---
 drivers/net/phy/spi_ks8995.c | 22 ----------------------
 1 file changed, 22 deletions(-)

diff --git a/drivers/net/phy/spi_ks8995.c b/drivers/net/phy/spi_ks8995.c
index 4653015..f091d69 100644
--- a/drivers/net/phy/spi_ks8995.c
+++ b/drivers/net/phy/spi_ks8995.c
@@ -209,8 +209,6 @@ static int ks8995_reset(struct ks8995_switch *ks)
 	return ks8995_start(ks);
 }
 
-/* ------------------------------------------------------------------------ */
-
 static ssize_t ks8995_registers_read(struct file *filp, struct kobject *kobj,
 	struct bin_attribute *bin_attr, char *buf, loff_t off, size_t count)
 {
@@ -220,19 +218,9 @@ static ssize_t ks8995_registers_read(struct file *filp, struct kobject *kobj,
 	dev = container_of(kobj, struct device, kobj);
 	ks8995 = dev_get_drvdata(dev);
 
-	if (unlikely(off > ks8995->regs_attr.size))
-		return 0;
-
-	if ((off + count) > ks8995->regs_attr.size)
-		count = ks8995->regs_attr.size - off;
-
-	if (unlikely(!count))
-		return count;
-
 	return ks8995_read(ks8995, buf, off, count);
 }
 
-
 static ssize_t ks8995_registers_write(struct file *filp, struct kobject *kobj,
 	struct bin_attribute *bin_attr, char *buf, loff_t off, size_t count)
 {
@@ -242,19 +230,9 @@ static ssize_t ks8995_registers_write(struct file *filp, struct kobject *kobj,
 	dev = container_of(kobj, struct device, kobj);
 	ks8995 = dev_get_drvdata(dev);
 
-	if (unlikely(off >= ks8995->regs_attr.size))
-		return -EFBIG;
-
-	if ((off + count) > ks8995->regs_attr.size)
-		count = ks8995->regs_attr.size - off;
-
-	if (unlikely(!count))
-		return count;
-
 	return ks8995_write(ks8995, buf, off, count);
 }
 
-
 static const struct bin_attribute ks8995_registers_attr = {
 	.attr = {
 		.name   = "registers",
-- 
2.1.4
