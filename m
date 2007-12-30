From: "chas williams - CONTRACTOR" <chas@cmf.nrl.navy.mil>
Subject: [PATCH net-2.6.25 2/7][ATM]: Convert struct class_device to struct device
Date: Sat, 29 Dec 2007 20:06:24 -0500
Message-ID: <200712300106.lBU16O1P003529@cmf.nrl.navy.mil>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ginger.cmf.nrl.navy.mil ([134.207.10.161]:59182 "EHLO
	ginger.cmf.nrl.navy.mil" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752000AbXL3BGj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Dec 2007 20:06:39 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 03c544e08cfe22f0c8a952c0aed1265917dca469
Author: Kay Sievers <kay.sievers@vrfy.org>
Date:   Fri Oct 26 07:28:29 2007 -0400

    [ATM]: Convert struct class_device to struct device
    
    Signed-off-by: Kay Sievers <kay.sievers@vrfy.org>
    Cc: Tony Jones <tonyj@suse.de>
    Signed-off-by: Greg Kroah-Hartman <gregkh@suse.de>
    Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>

diff --git a/net/atm/atm_sysfs.c b/net/atm/atm_sysfs.c
index 9ef07ed..1b88311 100644
--- a/net/atm/atm_sysfs.c
+++ b/net/atm/atm_sysfs.c
@@ -9,13 +9,15 @@
 
 #define to_atm_dev(cldev) container_of(cldev, struct atm_dev, class_dev)
 
-static ssize_t show_type(struct class_device *cdev, char *buf)
+static ssize_t show_type(struct device *cdev,
+			 struct device_attribute *attr, char *buf)
 {
 	struct atm_dev *adev = to_atm_dev(cdev);
 	return sprintf(buf, "%s\n", adev->type);
 }
 
-static ssize_t show_address(struct class_device *cdev, char *buf)
+static ssize_t show_address(struct device *cdev,
+			    struct device_attribute *attr, char *buf)
 {
 	char *pos = buf;
 	struct atm_dev *adev = to_atm_dev(cdev);
@@ -28,7 +30,8 @@ static ssize_t show_address(struct class_device *cdev, char *buf)
 	return pos - buf;
 }
 
-static ssize_t show_atmaddress(struct class_device *cdev, char *buf)
+static ssize_t show_atmaddress(struct device *cdev,
+			       struct device_attribute *attr, char *buf)
 {
 	unsigned long flags;
 	char *pos = buf;
@@ -54,7 +57,8 @@ static ssize_t show_atmaddress(struct class_device *cdev, char *buf)
 	return pos - buf;
 }
 
-static ssize_t show_carrier(struct class_device *cdev, char *buf)
+static ssize_t show_carrier(struct device *cdev,
+			    struct device_attribute *attr, char *buf)
 {
 	char *pos = buf;
 	struct atm_dev *adev = to_atm_dev(cdev);
@@ -65,7 +69,8 @@ static ssize_t show_carrier(struct class_device *cdev, char *buf)
 	return pos - buf;
 }
 
-static ssize_t show_link_rate(struct class_device *cdev, char *buf)
+static ssize_t show_link_rate(struct device *cdev,
+			      struct device_attribute *attr, char *buf)
 {
 	char *pos = buf;
 	struct atm_dev *adev = to_atm_dev(cdev);
@@ -90,22 +95,23 @@ static ssize_t show_link_rate(struct class_device *cdev, char *buf)
 	return pos - buf;
 }
 
-static CLASS_DEVICE_ATTR(address, S_IRUGO, show_address, NULL);
-static CLASS_DEVICE_ATTR(atmaddress, S_IRUGO, show_atmaddress, NULL);
-static CLASS_DEVICE_ATTR(carrier, S_IRUGO, show_carrier, NULL);
-static CLASS_DEVICE_ATTR(type, S_IRUGO, show_type, NULL);
-static CLASS_DEVICE_ATTR(link_rate, S_IRUGO, show_link_rate, NULL);
-
-static struct class_device_attribute *atm_attrs[] = {
-	&class_device_attr_atmaddress,
-	&class_device_attr_address,
-	&class_device_attr_carrier,
-	&class_device_attr_type,
-	&class_device_attr_link_rate,
+static DEVICE_ATTR(address, S_IRUGO, show_address, NULL);
+static DEVICE_ATTR(atmaddress, S_IRUGO, show_atmaddress, NULL);
+static DEVICE_ATTR(carrier, S_IRUGO, show_carrier, NULL);
+static DEVICE_ATTR(type, S_IRUGO, show_type, NULL);
+static DEVICE_ATTR(link_rate, S_IRUGO, show_link_rate, NULL);
+
+static struct device_attribute *atm_attrs[] = {
+	&dev_attr_atmaddress,
+	&dev_attr_address,
+	&dev_attr_carrier,
+	&dev_attr_type,
+	&dev_attr_link_rate,
 	NULL
 };
 
-static int atm_uevent(struct class_device *cdev, struct kobj_uevent_env *env)
+
+static int atm_uevent(struct device *cdev, struct kobj_uevent_env *env)
 {
 	struct atm_dev *adev;
 
@@ -122,7 +128,7 @@ static int atm_uevent(struct class_device *cdev, struct kobj_uevent_env *env)
 	return 0;
 }
 
-static void atm_release(struct class_device *cdev)
+static void atm_release(struct device *cdev)
 {
 	struct atm_dev *adev = to_atm_dev(cdev);
 
@@ -131,25 +137,25 @@ static void atm_release(struct class_device *cdev)
 
 static struct class atm_class = {
 	.name		= "atm",
-	.release	= atm_release,
-	.uevent		= atm_uevent,
+	.dev_release	= atm_release,
+	.dev_uevent		= atm_uevent,
 };
 
 int atm_register_sysfs(struct atm_dev *adev)
 {
-	struct class_device *cdev = &adev->class_dev;
+	struct device *cdev = &adev->class_dev;
 	int i, j, err;
 
 	cdev->class = &atm_class;
-	class_set_devdata(cdev, adev);
+	dev_set_drvdata(cdev, adev);
 
-	snprintf(cdev->class_id, BUS_ID_SIZE, "%s%d", adev->type, adev->number);
-	err = class_device_register(cdev);
+	snprintf(cdev->bus_id, BUS_ID_SIZE, "%s%d", adev->type, adev->number);
+	err = device_register(cdev);
 	if (err < 0)
 		return err;
 
 	for (i = 0; atm_attrs[i]; i++) {
-		err = class_device_create_file(cdev, atm_attrs[i]);
+		err = device_create_file(cdev, atm_attrs[i]);
 		if (err)
 			goto err_out;
 	}
@@ -158,16 +164,16 @@ int atm_register_sysfs(struct atm_dev *adev)
 
 err_out:
 	for (j = 0; j < i; j++)
-		class_device_remove_file(cdev, atm_attrs[j]);
-	class_device_del(cdev);
+		device_remove_file(cdev, atm_attrs[j]);
+	device_del(cdev);
 	return err;
 }
 
 void atm_unregister_sysfs(struct atm_dev *adev)
 {
-	struct class_device *cdev = &adev->class_dev;
+	struct device *cdev = &adev->class_dev;
 
-	class_device_del(cdev);
+	device_del(cdev);
 }
 
 int __init atm_sysfs_init(void)
diff --git a/include/linux/atmdev.h b/include/linux/atmdev.h
index 2096e5c..a3d07c2 100644
--- a/include/linux/atmdev.h
+++ b/include/linux/atmdev.h
@@ -359,7 +359,7 @@ struct atm_dev {
 	struct proc_dir_entry *proc_entry; /* proc entry */
 	char *proc_name;		/* proc entry name */
 #endif
-	struct class_device class_dev;	/* sysfs class device */
+	struct device class_dev;	/* sysfs device */
 	struct list_head dev_list;	/* linkage */
 };
 
@@ -461,7 +461,7 @@ static inline void atm_dev_put(struct atm_dev *dev)
 		BUG_ON(!test_bit(ATM_DF_REMOVED, &dev->flags));
 		if (dev->ops->dev_close)
 			dev->ops->dev_close(dev);
-		class_device_put(&dev->class_dev);
+		put_device(&dev->class_dev);
 	}
 }
 
