From: Michael Grzeschik <m.grzeschik@pengutronix.de>
Subject: [PATCH 2/4] arcnet: com20020-pci: add attribute to readback backplane status
Date: Wed, 28 Jun 2017 18:32:19 +0200
Message-ID: <20170628163221.32301-3-m.grzeschik@pengutronix.de>
References: <20170628163221.32301-1-m.grzeschik@pengutronix.de>
Cc: netdev@vger.kernel.org, kernel@pengutronix.de
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:47083 "EHLO
        metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752486AbdF1Qce (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Jun 2017 12:32:34 -0400
In-Reply-To: <20170628163221.32301-1-m.grzeschik@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We add the sysfs interface the read back the backplane
status of the interface.

Signed-off-by: Michael Grzeschik <m.grzeschik@pengutronix.de>
---
 drivers/net/arcnet/com20020-pci.c | 22 ++++++++++++++++++++++
 1 file changed, 22 insertions(+)

diff --git a/drivers/net/arcnet/com20020-pci.c b/drivers/net/arcnet/com20020-pci.c
index 239de38fbd6a5..dec300cac55f9 100644
--- a/drivers/net/arcnet/com20020-pci.c
+++ b/drivers/net/arcnet/com20020-pci.c
@@ -93,6 +93,27 @@ static void led_recon_set(struct led_classdev *led_cdev,
 	outb(!!value, priv->misc + ci->leds[card->index].red);
 }
 
+static ssize_t backplane_mode_show(struct device *dev,
+				   struct device_attribute *attr,
+				   char *buf)
+{
+	struct net_device *net_dev = to_net_dev(dev);
+	struct arcnet_local *lp = netdev_priv(net_dev);
+
+	return sprintf(buf, "%s\n", lp->backplane ? "true" : "false");
+}
+static DEVICE_ATTR_RO(backplane_mode);
+
+static struct attribute *com20020_state_attrs[] = {
+	&dev_attr_backplane_mode.attr,
+	NULL,
+};
+
+static struct attribute_group com20020_state_group = {
+	.name = NULL,
+	.attrs = com20020_state_attrs,
+};
+
 static void com20020pci_remove(struct pci_dev *pdev);
 
 static int com20020pci_probe(struct pci_dev *pdev,
@@ -168,6 +189,7 @@ static int com20020pci_probe(struct pci_dev *pdev,
 
 		dev->base_addr = ioaddr;
 		dev->dev_addr[0] = node;
+		dev->sysfs_groups[0] = &com20020_state_group;
 		dev->irq = pdev->irq;
 		lp->card_name = "PCI COM20020";
 		lp->card_flags = ci->flags;
-- 
2.11.0
