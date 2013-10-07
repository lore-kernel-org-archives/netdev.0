From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: [PATCH 09/11] ssb: convert bus code to use dev_groups
Date: Sun,  6 Oct 2013 23:55:48 -0700
Message-ID: <1381128950-28125-10-git-send-email-gregkh@linuxfoundation.org>
References: <1381128950-28125-1-git-send-email-gregkh@linuxfoundation.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Michael Buesch <m@bues.ch>, <netdev@vger.kernel.org>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1381128950-28125-1-git-send-email-gregkh@linuxfoundation.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The dev_attrs field of struct bus_type is going away soon, dev_groups
should be used instead.  This converts the ssb bus code to use the
correct field.

Cc: Michael Buesch <m@bues.ch>
Cc: <netdev@vger.kernel.org>
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
---

Michael, I can take this through my driver-core tree if you like, just
let me know what would be the easiest for you.

 drivers/ssb/main.c | 25 ++++++++++++++-----------
 1 file changed, 14 insertions(+), 11 deletions(-)

diff --git a/drivers/ssb/main.c b/drivers/ssb/main.c
index e55ddf7..32a811d 100644
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
1.8.4.6.g82e253f.dirty
