From: Hauke Mehrtens <hauke@hauke-m.de>
Subject: [PATCH] ssb: Add sysfs attributes to ssb devices
Date: Sat, 27 Nov 2010 18:49:26 +0100
Message-ID: <1290880166-2092-1-git-send-email-hauke@hauke-m.de>
Cc: netdev@vger.kernel.org, Hauke Mehrtens <hauke@hauke-m.de>,
	Bernhard Loos <bernhardloos@googlemail.com>
To: mb@bu3sch.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from server19320154104.serverpool.info ([193.201.54.104]:32782 "EHLO
	hauke-m.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752706Ab0K0Rtd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 27 Nov 2010 12:49:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make it possible to read out the attributes, till now only show on
dmesg, through sysfs.

This patch was some time in OpenWrt.

Signed-off-by: Bernhard Loos <bernhardloos@googlemail.com>
Signed-off-by: Hauke Mehrtens <hauke@hauke-m.de>
---
 drivers/ssb/main.c |   30 ++++++++++++++++++++++++++++++
 1 files changed, 30 insertions(+), 0 deletions(-)

diff --git a/drivers/ssb/main.c b/drivers/ssb/main.c
index c68b3dc..3918d2c 100644
--- a/drivers/ssb/main.c
+++ b/drivers/ssb/main.c
@@ -383,6 +383,35 @@ static int ssb_device_uevent(struct device *dev, struct kobj_uevent_env *env)
 			     ssb_dev->id.revision);
 }
 
+#define ssb_config_attr(attrib, field, format_string) \
+static ssize_t \
+attrib##_show(struct device *dev, struct device_attribute *attr, char *buf) \
+{ \
+	return sprintf(buf, format_string, dev_to_ssb_dev(dev)->field); \
+}
+
+ssb_config_attr(core_num, core_index, "%u\n")
+ssb_config_attr(coreid, id.coreid, "0x%04x\n")
+ssb_config_attr(vendor, id.vendor, "0x%04x\n")
+ssb_config_attr(revision, id.revision, "%u\n")
+ssb_config_attr(irq, irq, "%u\n")
+static ssize_t
+name_show(struct device *dev, struct device_attribute *attr, char *buf)
+{
+	return sprintf(buf, "%s\n",
+		       ssb_core_name(dev_to_ssb_dev(dev)->id.coreid));
+}
+
+static struct device_attribute ssb_device_attrs[] = {
+	__ATTR_RO(name),
+	__ATTR_RO(core_num),
+	__ATTR_RO(coreid),
+	__ATTR_RO(vendor),
+	__ATTR_RO(revision),
+	__ATTR_RO(irq),
+	__ATTR_NULL,
+};
+
 static struct bus_type ssb_bustype = {
 	.name		= "ssb",
 	.match		= ssb_bus_match,
@@ -392,6 +421,7 @@ static struct bus_type ssb_bustype = {
 	.suspend	= ssb_device_suspend,
 	.resume		= ssb_device_resume,
 	.uevent		= ssb_device_uevent,
+	.dev_attrs	= ssb_device_attrs,
 };
 
 static void ssb_buses_lock(void)
-- 
1.7.1

