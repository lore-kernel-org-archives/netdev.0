From: <gregkh@linuxfoundation.org>
Subject: patch "ssb: convert bus code to use dev_groups" added to driver-core tree
Date: Wed, 16 Oct 2013 18:39:19 -0700
Message-ID: <1381973959182@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ASCII
Content-Transfer-Encoding: 8bit
To: gregkh@linuxfoundation.org, m@bues.ch, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.linuxfoundation.org ([140.211.169.12]:38669 "EHLO
	mail.linuxfoundation.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760887Ab3JQBj3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Oct 2013 21:39:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This is a note to let you know that I've just added the patch titled

    ssb: convert bus code to use dev_groups

to my driver-core git tree which can be found at
    git://git.kernel.org/pub/scm/linux/kernel/git/gregkh/driver-core.git
in the driver-core-next branch.

The patch will show up in the next release of the linux-next tree
(usually sometime within the next 24 hours during the week.)

The patch will also be merged in the next major kernel release
during the merge window.

If you have any questions about this process, please let me know.


>From 4e9072d61695abcee201591ba9515a28bcb3bd33 Mon Sep 17 00:00:00 2001
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Sun, 6 Oct 2013 23:55:48 -0700
Subject: ssb: convert bus code to use dev_groups

The dev_attrs field of struct bus_type is going away soon, dev_groups
should be used instead.  This converts the ssb bus code to use the
correct field.

Cc: Michael Buesch <m@bues.ch>
Cc: <netdev@vger.kernel.org>
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
---
 drivers/ssb/main.c | 25 ++++++++++++++-----------
 1 file changed, 14 insertions(+), 11 deletions(-)

diff --git a/drivers/ssb/main.c b/drivers/ssb/main.c
index e55ddf7c..32a811d1 100644
--- a/drivers/ssb/main.c
+++ b/drivers/ssb/main.c
@@ -374,7 +374,8 @@ static ssize_t \
 attrib##_show(struct device *dev, struct device_attribute *attr, char *buf) \
 { \
 	return sprintf(buf, format_string, dev_to_ssb_dev(dev)->field); \
-}
+} \
+static DEVICE_ATTR_RO(attrib);
 
 ssb_config_attr(core_num, core_index, "%u\n")
 ssb_config_attr(coreid, id.coreid, "0x%04x\n")
@@ -387,16 +388,18 @@ name_show(struct device *dev, struct device_attribute *attr, char *buf)
 	return sprintf(buf, "%s\n",
 		       ssb_core_name(dev_to_ssb_dev(dev)->id.coreid));
 }
-
-static struct device_attribute ssb_device_attrs[] = {
-	__ATTR_RO(name),
-	__ATTR_RO(core_num),
-	__ATTR_RO(coreid),
-	__ATTR_RO(vendor),
-	__ATTR_RO(revision),
-	__ATTR_RO(irq),
-	__ATTR_NULL,
+static DEVICE_ATTR_RO(name);
+
+static struct attribute *ssb_device_attrs[] = {
+	&dev_attr_name.attr,
+	&dev_attr_core_num.attr,
+	&dev_attr_coreid.attr,
+	&dev_attr_vendor.attr,
+	&dev_attr_revision.attr,
+	&dev_attr_irq.attr,
+	NULL,
 };
+ATTRIBUTE_GROUPS(ssb_device);
 
 static struct bus_type ssb_bustype = {
 	.name		= "ssb",
@@ -407,7 +410,7 @@ static struct bus_type ssb_bustype = {
 	.suspend	= ssb_device_suspend,
 	.resume		= ssb_device_resume,
 	.uevent		= ssb_device_uevent,
-	.dev_attrs	= ssb_device_attrs,
+	.dev_groups	= ssb_device_groups,
 };
 
 static void ssb_buses_lock(void)
-- 
1.8.4.3.gca3854a
