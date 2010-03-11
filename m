From: Grant Likely <grant.likely@secretlab.ca>
Subject: [PATCH 13/37] drivers/macintosh: use .dev.of_node instead of .node in
	struct of_device
Date: Thu, 11 Mar 2010 11:04:59 -0700
Message-ID: <20100311180459.4824.89079.stgit__12397.595603443$1268331479$gmane$org@angua>
References: <20100311174830.4824.19820.stgit@angua>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: monstr@monstr.eu, gregkh@suse.de, benh@kernel.crashing.org,
	akpm@linux-foundation.org, davem@davemloft.net,
	sfr@canb.auug.org.au, jgarzik@pobox.com, ben-linux@fluff.org,
	dwmw2@infrade
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:53447 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933634Ab0CKSFD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Mar 2010 13:05:03 -0500
In-Reply-To: <20100311174830.4824.19820.stgit@angua>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

.node is being removed

Signed-off-by: Grant Likely <grant.likely@secretlab.ca>
---

 drivers/macintosh/macio_asic.c  |   16 ++++++++--------
 drivers/macintosh/macio_sysfs.c |    6 +++---
 drivers/macintosh/rack-meter.c  |    4 ++--
 drivers/macintosh/therm_pm72.c  |    2 +-
 4 files changed, 14 insertions(+), 14 deletions(-)

diff --git a/drivers/macintosh/macio_asic.c b/drivers/macintosh/macio_asic.c
index 26a303a..67fe13f 100644
--- a/drivers/macintosh/macio_asic.c
+++ b/drivers/macintosh/macio_asic.c
@@ -248,7 +248,7 @@ static void macio_create_fixup_irq(struct macio_dev *dev, int index,
 
 static void macio_add_missing_resources(struct macio_dev *dev)
 {
-	struct device_node *np = dev->ofdev.node;
+	struct device_node *np = dev->ofdev.dev.of_node;
 	unsigned int irq_base;
 
 	/* Gatwick has some missing interrupts on child nodes */
@@ -289,7 +289,7 @@ static void macio_add_missing_resources(struct macio_dev *dev)
 
 static void macio_setup_interrupts(struct macio_dev *dev)
 {
-	struct device_node *np = dev->ofdev.node;
+	struct device_node *np = dev->ofdev.dev.of_node;
 	unsigned int irq;
 	int i = 0, j = 0;
 
@@ -317,7 +317,7 @@ static void macio_setup_interrupts(struct macio_dev *dev)
 static void macio_setup_resources(struct macio_dev *dev,
 				  struct resource *parent_res)
 {
-	struct device_node *np = dev->ofdev.node;
+	struct device_node *np = dev->ofdev.dev.of_node;
 	struct resource r;
 	int index;
 
@@ -373,7 +373,7 @@ static struct macio_dev * macio_add_one_device(struct macio_chip *chip,
 
 	dev->bus = &chip->lbus;
 	dev->media_bay = in_bay;
-	dev->ofdev.node = np;
+	dev->ofdev.dev.of_node = np;
 	dev->ofdev.dma_mask = 0xffffffffUL;
 	dev->ofdev.dev.dma_mask = &dev->ofdev.dma_mask;
 	dev->ofdev.dev.parent = parent;
@@ -494,9 +494,9 @@ static void macio_pci_add_devices(struct macio_chip *chip)
 	}
 
 	/* Add media bay devices if any */
+	pnode = mbdev->ofdev.dev.of_node;
 	if (mbdev)
-		for (np = NULL; (np = of_get_next_child(mbdev->ofdev.node, np))
-			     != NULL;) {
+		for (np = NULL; (np = of_get_next_child(pnode, np)) != NULL;) {
 			if (macio_skip_device(np))
 				continue;
 			of_node_get(np);
@@ -506,9 +506,9 @@ static void macio_pci_add_devices(struct macio_chip *chip)
 		}
 
 	/* Add serial ports if any */
+	pnode = sdev->ofdev.dev.of_node;
 	if (sdev) {
-		for (np = NULL; (np = of_get_next_child(sdev->ofdev.node, np))
-			     != NULL;) {
+		for (np = NULL; (np = of_get_next_child(pnode, np)) != NULL;) {
 			if (macio_skip_device(np))
 				continue;
 			of_node_get(np);
diff --git a/drivers/macintosh/macio_sysfs.c b/drivers/macintosh/macio_sysfs.c
index 9e9453b..6999ce5 100644
--- a/drivers/macintosh/macio_sysfs.c
+++ b/drivers/macintosh/macio_sysfs.c
@@ -9,7 +9,7 @@ field##_show (struct device *dev, struct device_attribute *attr,	\
               char *buf)						\
 {									\
 	struct macio_dev *mdev = to_macio_device (dev);			\
-	return sprintf (buf, format_string, mdev->ofdev.node->field);	\
+	return sprintf (buf, format_string, mdev->ofdev.dev.of_node->field); \
 }
 
 static ssize_t
@@ -21,7 +21,7 @@ compatible_show (struct device *dev, struct device_attribute *attr, char *buf)
 	int length = 0;
 
 	of = &to_macio_device (dev)->ofdev;
-	compat = of_get_property(of->node, "compatible", &cplen);
+	compat = of_get_property(of->dev.of_node, "compatible", &cplen);
 	if (!compat) {
 		*buf = '\0';
 		return 0;
@@ -58,7 +58,7 @@ static ssize_t devspec_show(struct device *dev,
 	struct of_device *ofdev;
 
 	ofdev = to_of_device(dev);
-	return sprintf(buf, "%s\n", ofdev->node->full_name);
+	return sprintf(buf, "%s\n", ofdev->dev.of_node->full_name);
 }
 
 macio_config_of_attr (name, "%s\n");
diff --git a/drivers/macintosh/rack-meter.c b/drivers/macintosh/rack-meter.c
index 93fb320..6a715d0 100644
--- a/drivers/macintosh/rack-meter.c
+++ b/drivers/macintosh/rack-meter.c
@@ -374,7 +374,7 @@ static int __devinit rackmeter_probe(struct macio_dev* mdev,
 	pr_debug("rackmeter_probe()\n");
 
 	/* Get i2s-a node */
-	while ((i2s = of_get_next_child(mdev->ofdev.node, i2s)) != NULL)
+	while ((i2s = of_get_next_child(mdev->ofdev.dev.of_node, i2s)) != NULL)
 	       if (strcmp(i2s->name, "i2s-a") == 0)
 		       break;
 	if (i2s == NULL) {
@@ -430,7 +430,7 @@ static int __devinit rackmeter_probe(struct macio_dev* mdev,
 	    of_address_to_resource(i2s, 1, &rdma)) {
 		printk(KERN_ERR
 		       "rackmeter: found match but lacks resources: %s",
-		       mdev->ofdev.node->full_name);
+		       mdev->ofdev.dev.of_node->full_name);
 		rc = -ENXIO;
 		goto bail_free;
 	}
diff --git a/drivers/macintosh/therm_pm72.c b/drivers/macintosh/therm_pm72.c
index 5738d8b..f5b0f9e 100644
--- a/drivers/macintosh/therm_pm72.c
+++ b/drivers/macintosh/therm_pm72.c
@@ -2198,7 +2198,7 @@ static int fcu_of_probe(struct of_device* dev, const struct of_device_id *match)
 	state = state_detached;
 
 	/* Lookup the fans in the device tree */
-	fcu_lookup_fans(dev->node);
+	fcu_lookup_fans(dev->dev.of_node);
 
 	/* Add the driver */
 	return i2c_add_driver(&therm_pm72_driver);

