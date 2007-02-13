From: Kumar Gala <galak@kernel.crashing.org>
Subject: [git patches] gianfar sysfs driver fix
Date: Mon, 12 Feb 2007 23:55:29 -0600 (CST)
Message-ID: <Pine.LNX.4.64.0702122354080.21656@localhost.localdomain>
References: <Pine.LNX.4.64.0702081118090.29779@localhost.localdomain>
 <45CCE357.3030203@pobox.com> <Pine.LNX.4.64.0702091531090.8491@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nommos.sslcatacombnetworking.com ([67.18.224.114]:39896 "EHLO
	nommos.sslcatacombnetworking.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751110AbXBMF6R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Feb 2007 00:58:17 -0500
In-Reply-To: <Pine.LNX.4.64.0702091531090.8491@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Please pull from 'gfar' branch of
master.kernel.org/pub/scm/linux/kernel/git/galak/powerpc.git gfar

(will try this as a git pull request, see if that works better :)

to receive the following updates:

  drivers/net/gianfar_sysfs.c |  108 ++++++++++++++++++++++----------------------
  1 file changed, 55 insertions(+), 53 deletions(-)

Kumar Gala (1):
       Convert network devices to use struct device instead of class_device

diff --git a/drivers/net/gianfar_sysfs.c b/drivers/net/gianfar_sysfs.c
index 9dd387f..6e2166a 100644
--- a/drivers/net/gianfar_sysfs.c
+++ b/drivers/net/gianfar_sysfs.c
@@ -39,13 +39,15 @@
  #include "gianfar.h"

  #define GFAR_ATTR(_name) \
-static ssize_t gfar_show_##_name(struct class_device *cdev, char *buf); \
-static ssize_t gfar_set_##_name(struct class_device *cdev, \
+static ssize_t gfar_show_##_name(struct device *dev, \
+	 struct device_attribute *attr, char *buf); \
+static ssize_t gfar_set_##_name(struct device *dev, \
+		struct device_attribute *attr, \
  		const char *buf, size_t count); \
-static CLASS_DEVICE_ATTR(_name, 0644, gfar_show_##_name, gfar_set_##_name)
+static DEVICE_ATTR(_name, 0644, gfar_show_##_name, gfar_set_##_name)

  #define GFAR_CREATE_FILE(_dev, _name) \
-	class_device_create_file(&_dev->class_dev, &class_device_attr_##_name)
+	device_create_file(&_dev->dev, &dev_attr_##_name)

  GFAR_ATTR(bd_stash);
  GFAR_ATTR(rx_stash_size);
@@ -54,29 +56,28 @@ GFAR_ATTR(fifo_threshold);
  GFAR_ATTR(fifo_starve);
  GFAR_ATTR(fifo_starve_off);

-#define to_net_dev(cd) container_of(cd, struct net_device, class_dev)
-
-static ssize_t gfar_show_bd_stash(struct class_device *cdev, char *buf)
+static ssize_t gfar_show_bd_stash(struct device *dev,
+				  struct device_attribute *attr, char *buf)
  {
-	struct net_device *dev = to_net_dev(cdev);
-	struct gfar_private *priv = netdev_priv(dev);
+	struct gfar_private *priv = netdev_priv(to_net_dev(dev));

-	return sprintf(buf, "%s\n", priv->bd_stash_en? "on" : "off");
+	return sprintf(buf, "%s\n", priv->bd_stash_en ? "on" : "off");
  }

-static ssize_t gfar_set_bd_stash(struct class_device *cdev,
-		const char *buf, size_t count)
+static ssize_t gfar_set_bd_stash(struct device *dev,
+				 struct device_attribute *attr,
+				 const char *buf, size_t count)
  {
-	struct net_device *dev = to_net_dev(cdev);
-	struct gfar_private *priv = netdev_priv(dev);
+	struct gfar_private *priv = netdev_priv(to_net_dev(dev));
  	int new_setting = 0;
  	u32 temp;
  	unsigned long flags;

  	/* Find out the new setting */
-	if (!strncmp("on", buf, count-1) || !strncmp("1", buf, count-1))
+	if (!strncmp("on", buf, count - 1) || !strncmp("1", buf, count - 1))
  		new_setting = 1;
-	else if (!strncmp("off", buf, count-1) || !strncmp("0", buf, count-1))
+	else if (!strncmp("off", buf, count - 1)
+		 || !strncmp("0", buf, count - 1))
  		new_setting = 0;
  	else
  		return count;
@@ -100,19 +101,19 @@ static ssize_t gfar_set_bd_stash(struct class_device *cdev,
  	return count;
  }

-static ssize_t gfar_show_rx_stash_size(struct class_device *cdev, char *buf)
+static ssize_t gfar_show_rx_stash_size(struct device *dev,
+				       struct device_attribute *attr, char *buf)
  {
-	struct net_device *dev = to_net_dev(cdev);
-	struct gfar_private *priv = netdev_priv(dev);
+	struct gfar_private *priv = netdev_priv(to_net_dev(dev));

  	return sprintf(buf, "%d\n", priv->rx_stash_size);
  }

-static ssize_t gfar_set_rx_stash_size(struct class_device *cdev,
-		const char *buf, size_t count)
+static ssize_t gfar_set_rx_stash_size(struct device *dev,
+				      struct device_attribute *attr,
+				      const char *buf, size_t count)
  {
-	struct net_device *dev = to_net_dev(cdev);
-	struct gfar_private *priv = netdev_priv(dev);
+	struct gfar_private *priv = netdev_priv(to_net_dev(dev));
  	unsigned int length = simple_strtoul(buf, NULL, 0);
  	u32 temp;
  	unsigned long flags;
@@ -146,21 +147,21 @@ static ssize_t gfar_set_rx_stash_size(struct class_device *cdev,
  	return count;
  }

-
  /* Stashing will only be enabled when rx_stash_size != 0 */
-static ssize_t gfar_show_rx_stash_index(struct class_device *cdev, char *buf)
+static ssize_t gfar_show_rx_stash_index(struct device *dev,
+					struct device_attribute *attr,
+					char *buf)
  {
-	struct net_device *dev = to_net_dev(cdev);
-	struct gfar_private *priv = netdev_priv(dev);
+	struct gfar_private *priv = netdev_priv(to_net_dev(dev));

  	return sprintf(buf, "%d\n", priv->rx_stash_index);
  }

-static ssize_t gfar_set_rx_stash_index(struct class_device *cdev,
-		const char *buf, size_t count)
+static ssize_t gfar_set_rx_stash_index(struct device *dev,
+				       struct device_attribute *attr,
+				       const char *buf, size_t count)
  {
-	struct net_device *dev = to_net_dev(cdev);
-	struct gfar_private *priv = netdev_priv(dev);
+	struct gfar_private *priv = netdev_priv(to_net_dev(dev));
  	unsigned short index = simple_strtoul(buf, NULL, 0);
  	u32 temp;
  	unsigned long flags;
@@ -184,19 +185,20 @@ static ssize_t gfar_set_rx_stash_index(struct class_device *cdev,
  	return count;
  }

-static ssize_t gfar_show_fifo_threshold(struct class_device *cdev, char *buf)
+static ssize_t gfar_show_fifo_threshold(struct device *dev,
+					struct device_attribute *attr,
+					char *buf)
  {
-	struct net_device *dev = to_net_dev(cdev);
-	struct gfar_private *priv = netdev_priv(dev);
+	struct gfar_private *priv = netdev_priv(to_net_dev(dev));

  	return sprintf(buf, "%d\n", priv->fifo_threshold);
  }

-static ssize_t gfar_set_fifo_threshold(struct class_device *cdev,
-		const char *buf, size_t count)
+static ssize_t gfar_set_fifo_threshold(struct device *dev,
+				       struct device_attribute *attr,
+				       const char *buf, size_t count)
  {
-	struct net_device *dev = to_net_dev(cdev);
-	struct gfar_private *priv = netdev_priv(dev);
+	struct gfar_private *priv = netdev_priv(to_net_dev(dev));
  	unsigned int length = simple_strtoul(buf, NULL, 0);
  	u32 temp;
  	unsigned long flags;
@@ -218,20 +220,19 @@ static ssize_t gfar_set_fifo_threshold(struct class_device *cdev,
  	return count;
  }

-static ssize_t gfar_show_fifo_starve(struct class_device *cdev, char *buf)
+static ssize_t gfar_show_fifo_starve(struct device *dev,
+				     struct device_attribute *attr, char *buf)
  {
-	struct net_device *dev = to_net_dev(cdev);
-	struct gfar_private *priv = netdev_priv(dev);
+	struct gfar_private *priv = netdev_priv(to_net_dev(dev));

  	return sprintf(buf, "%d\n", priv->fifo_starve);
  }

-
-static ssize_t gfar_set_fifo_starve(struct class_device *cdev,
-		const char *buf, size_t count)
+static ssize_t gfar_set_fifo_starve(struct device *dev,
+				    struct device_attribute *attr,
+				    const char *buf, size_t count)
  {
-	struct net_device *dev = to_net_dev(cdev);
-	struct gfar_private *priv = netdev_priv(dev);
+	struct gfar_private *priv = netdev_priv(to_net_dev(dev));
  	unsigned int num = simple_strtoul(buf, NULL, 0);
  	u32 temp;
  	unsigned long flags;
@@ -253,19 +254,20 @@ static ssize_t gfar_set_fifo_starve(struct class_device *cdev,
  	return count;
  }

-static ssize_t gfar_show_fifo_starve_off(struct class_device *cdev, char *buf)
+static ssize_t gfar_show_fifo_starve_off(struct device *dev,
+					 struct device_attribute *attr,
+					 char *buf)
  {
-	struct net_device *dev = to_net_dev(cdev);
-	struct gfar_private *priv = netdev_priv(dev);
+	struct gfar_private *priv = netdev_priv(to_net_dev(dev));

  	return sprintf(buf, "%d\n", priv->fifo_starve_off);
  }

-static ssize_t gfar_set_fifo_starve_off(struct class_device *cdev,
-		const char *buf, size_t count)
+static ssize_t gfar_set_fifo_starve_off(struct device *dev,
+					struct device_attribute *attr,
+					const char *buf, size_t count)
  {
-	struct net_device *dev = to_net_dev(cdev);
-	struct gfar_private *priv = netdev_priv(dev);
+	struct gfar_private *priv = netdev_priv(to_net_dev(dev));
  	unsigned int num = simple_strtoul(buf, NULL, 0);
  	u32 temp;
  	unsigned long flags;
