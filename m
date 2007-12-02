From: Grant Likely <grant.likely@secretlab.ca>
Subject: [PATCH] gianfar driver: eliminate compiler warnings and unnecessary
	macros
Date: Sat, 01 Dec 2007 22:12:45 -0700
Message-ID: <20071202051245.8918.24063.stgit@trillian.secretlab.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org,
	galak@kernel.crashing.org, jgarzik@pobox.com,
	afleming@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from idcmail-mo1so.shaw.ca ([24.71.223.10]:39844 "EHLO
	pd3mo1so.prod.shaw.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750964AbXLBFMs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Dec 2007 00:12:48 -0500
Received: from pd2mr1so.prod.shaw.ca
 (pd2mr1so-qfe3.prod.shaw.ca [10.0.141.110]) by l-daemon
 (Sun ONE Messaging Server 6.0 HotFix 1.01 (built Mar 15 2004))
 with ESMTP id <0JSE004RMP5BBQ50@l-daemon> for netdev@vger.kernel.org; Sat,
 01 Dec 2007 22:12:47 -0700 (MST)
Received: from pn2ml6so.prod.shaw.ca ([10.0.121.150])
 by pd2mr1so.prod.shaw.ca (Sun Java System Messaging Server 6.2-7.05 (built Sep
 5 2006)) with ESMTP id <0JSE00K2XP5A8O40@pd2mr1so.prod.shaw.ca> for
 netdev@vger.kernel.org; Sat, 01 Dec 2007 22:12:48 -0700 (MST)
Received: from trillian.cg.shawcable.net ([68.147.67.118])
 by l-daemon (Sun ONE Messaging Server 6.0 HotFix 1.01 (built Mar 15 2004))
 with ESMTP id <0JSE007HSP59DM40@l-daemon> for netdev@vger.kernel.org; Sat,
 01 Dec 2007 22:12:45 -0700 (MST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Grant Likely <grant.likely@secretlab.ca>

This patch eliminates the warning of unused return values when the driver
registers it sysfs files.  Now the driver will print an error if it is
unable to register the sysfs files.

It also eliminates the macros used to wrap the DEVICE_ATTR macro and the
device_create_file function call.  The macros don't reduce the number of
lines of source code in the file and the name munging makes is so that
cscope and friends don't see the references to the functions.  It's better
to just call the kernel API directly.

While we're at it, the DEVICE_ATTR instances have been moved down to
be grouped with the functions they depend on.

Signed-off-by: Grant Likely <grant.likely@secretlab.ca>
---

 drivers/net/gianfar_sysfs.c |   50 ++++++++++++++++++++++---------------------
 1 files changed, 25 insertions(+), 25 deletions(-)

diff --git a/drivers/net/gianfar_sysfs.c b/drivers/net/gianfar_sysfs.c
index aec9ab1..230878b 100644
--- a/drivers/net/gianfar_sysfs.c
+++ b/drivers/net/gianfar_sysfs.c
@@ -37,24 +37,6 @@
 
 #include "gianfar.h"
 
-#define GFAR_ATTR(_name) \
-static ssize_t gfar_show_##_name(struct device *dev, \
-	 struct device_attribute *attr, char *buf); \
-static ssize_t gfar_set_##_name(struct device *dev, \
-		struct device_attribute *attr, \
-		const char *buf, size_t count); \
-static DEVICE_ATTR(_name, 0644, gfar_show_##_name, gfar_set_##_name)
-
-#define GFAR_CREATE_FILE(_dev, _name) \
-	device_create_file(&_dev->dev, &dev_attr_##_name)
-
-GFAR_ATTR(bd_stash);
-GFAR_ATTR(rx_stash_size);
-GFAR_ATTR(rx_stash_index);
-GFAR_ATTR(fifo_threshold);
-GFAR_ATTR(fifo_starve);
-GFAR_ATTR(fifo_starve_off);
-
 static ssize_t gfar_show_bd_stash(struct device *dev,
 				  struct device_attribute *attr, char *buf)
 {
@@ -100,6 +82,8 @@ static ssize_t gfar_set_bd_stash(struct device *dev,
 	return count;
 }
 
+DEVICE_ATTR(bd_stash, 0644, gfar_show_bd_stash, gfar_set_bd_stash);
+
 static ssize_t gfar_show_rx_stash_size(struct device *dev,
 				       struct device_attribute *attr, char *buf)
 {
@@ -146,6 +130,9 @@ static ssize_t gfar_set_rx_stash_size(struct device *dev,
 	return count;
 }
 
+DEVICE_ATTR(rx_stash_size, 0644, gfar_show_rx_stash_size,
+	    gfar_set_rx_stash_size);
+
 /* Stashing will only be enabled when rx_stash_size != 0 */
 static ssize_t gfar_show_rx_stash_index(struct device *dev,
 					struct device_attribute *attr,
@@ -184,6 +171,9 @@ static ssize_t gfar_set_rx_stash_index(struct device *dev,
 	return count;
 }
 
+DEVICE_ATTR(rx_stash_index, 0644, gfar_show_rx_stash_index,
+	    gfar_set_rx_stash_index);
+
 static ssize_t gfar_show_fifo_threshold(struct device *dev,
 					struct device_attribute *attr,
 					char *buf)
@@ -219,6 +209,9 @@ static ssize_t gfar_set_fifo_threshold(struct device *dev,
 	return count;
 }
 
+DEVICE_ATTR(fifo_threshold, 0644, gfar_show_fifo_threshold,
+	    gfar_set_fifo_threshold);
+
 static ssize_t gfar_show_fifo_starve(struct device *dev,
 				     struct device_attribute *attr, char *buf)
 {
@@ -253,6 +246,8 @@ static ssize_t gfar_set_fifo_starve(struct device *dev,
 	return count;
 }
 
+DEVICE_ATTR(fifo_starve, 0644, gfar_show_fifo_starve, gfar_set_fifo_starve);
+
 static ssize_t gfar_show_fifo_starve_off(struct device *dev,
 					 struct device_attribute *attr,
 					 char *buf)
@@ -288,9 +283,13 @@ static ssize_t gfar_set_fifo_starve_off(struct device *dev,
 	return count;
 }
 
+DEVICE_ATTR(fifo_starve_off, 0644, gfar_show_fifo_starve_off,
+	    gfar_set_fifo_starve_off);
+
 void gfar_init_sysfs(struct net_device *dev)
 {
 	struct gfar_private *priv = netdev_priv(dev);
+	int rc;
 
 	/* Initialize the default values */
 	priv->rx_stash_size = DEFAULT_STASH_LENGTH;
@@ -301,11 +300,12 @@ void gfar_init_sysfs(struct net_device *dev)
 	priv->bd_stash_en = DEFAULT_BD_STASH;
 
 	/* Create our sysfs files */
-	GFAR_CREATE_FILE(dev, bd_stash);
-	GFAR_CREATE_FILE(dev, rx_stash_size);
-	GFAR_CREATE_FILE(dev, rx_stash_index);
-	GFAR_CREATE_FILE(dev, fifo_threshold);
-	GFAR_CREATE_FILE(dev, fifo_starve);
-	GFAR_CREATE_FILE(dev, fifo_starve_off);
-
+	rc = device_create_file(&dev->dev, &dev_attr_bd_stash);
+	rc |= device_create_file(&dev->dev, &dev_attr_rx_stash_size);
+	rc |= device_create_file(&dev->dev, &dev_attr_rx_stash_index);
+	rc |= device_create_file(&dev->dev, &dev_attr_fifo_threshold);
+	rc |= device_create_file(&dev->dev, &dev_attr_fifo_starve);
+	rc |= device_create_file(&dev->dev, &dev_attr_fifo_starve_off);
+	if (rc)
+		dev_err(&dev->dev, "Error creating gianfar sysfs files.\n");
 }

