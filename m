From: Divy Le Ray <divy@chelsio.com>
Subject: [PATCH 7/9] cxgb3 - sysfs methods clean up
Date: Fri, 16 Nov 2007 11:22:10 -0800
Message-ID: <20071116192210.31132.75678.stgit@speedy5>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, swise@opengridcomputing.com,
	wenxiong@us.ibm.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:25071 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757393AbXKPTWP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Nov 2007 14:22:15 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Divy Le Ray <divy@chelsio.com>

Remove unused argument in sysfs methods

Signed-off-by: Divy Le Ray <divy@chelsio.com>
---

 drivers/net/cxgb3/cxgb3_main.c |   19 +++++++++----------
 1 files changed, 9 insertions(+), 10 deletions(-)

diff --git a/drivers/net/cxgb3/cxgb3_main.c b/drivers/net/cxgb3/cxgb3_main.c
index 1b9a711..b4ee18b 100644
--- a/drivers/net/cxgb3/cxgb3_main.c
+++ b/drivers/net/cxgb3/cxgb3_main.c
@@ -410,8 +410,7 @@ static int setup_sge_qsets(struct adapter *adap)
 	return 0;
 }
 
-static ssize_t attr_show(struct device *d, struct device_attribute *attr,
-			 char *buf,
+static ssize_t attr_show(struct device *d, char *buf,
 			 ssize_t(*format) (struct net_device *, char *))
 {
 	ssize_t len;
@@ -423,7 +422,7 @@ static ssize_t attr_show(struct device *d, struct device_attribute *attr,
 	return len;
 }
 
-static ssize_t attr_store(struct device *d, struct device_attribute *attr,
+static ssize_t attr_store(struct device *d,
 			  const char *buf, size_t len,
 			  ssize_t(*set) (struct net_device *, unsigned int),
 			  unsigned int min_val, unsigned int max_val)
@@ -457,7 +456,7 @@ static ssize_t format_##name(struct net_device *dev, char *buf) \
 static ssize_t show_##name(struct device *d, struct device_attribute *attr, \
 			   char *buf) \
 { \
-	return attr_show(d, attr, buf, format_##name); \
+	return attr_show(d, buf, format_##name); \
 }
 
 static ssize_t set_nfilters(struct net_device *dev, unsigned int val)
@@ -480,7 +479,7 @@ static ssize_t set_nfilters(struct net_device *dev, unsigned int val)
 static ssize_t store_nfilters(struct device *d, struct device_attribute *attr,
 			      const char *buf, size_t len)
 {
-	return attr_store(d, attr, buf, len, set_nfilters, 0, ~0);
+	return attr_store(d, buf, len, set_nfilters, 0, ~0);
 }
 
 static ssize_t set_nservers(struct net_device *dev, unsigned int val)
@@ -500,7 +499,7 @@ static ssize_t set_nservers(struct net_device *dev, unsigned int val)
 static ssize_t store_nservers(struct device *d, struct device_attribute *attr,
 			      const char *buf, size_t len)
 {
-	return attr_store(d, attr, buf, len, set_nservers, 0, ~0);
+	return attr_store(d, buf, len, set_nservers, 0, ~0);
 }
 
 #define CXGB3_ATTR_R(name, val_expr) \
@@ -524,7 +523,7 @@ static struct attribute *cxgb3_attrs[] = {
 
 static struct attribute_group cxgb3_attr_group = {.attrs = cxgb3_attrs };
 
-static ssize_t tm_attr_show(struct device *d, struct device_attribute *attr,
+static ssize_t tm_attr_show(struct device *d,
 			    char *buf, int sched)
 {
 	struct port_info *pi = netdev_priv(to_net_dev(d));
@@ -550,7 +549,7 @@ static ssize_t tm_attr_show(struct device *d, struct device_attribute *attr,
 	return len;
 }
 
-static ssize_t tm_attr_store(struct device *d, struct device_attribute *attr,
+static ssize_t tm_attr_store(struct device *d,
 			     const char *buf, size_t len, int sched)
 {
 	struct port_info *pi = netdev_priv(to_net_dev(d));
@@ -578,12 +577,12 @@ static ssize_t tm_attr_store(struct device *d, struct device_attribute *attr,
 static ssize_t show_##name(struct device *d, struct device_attribute *attr, \
 			   char *buf) \
 { \
-	return tm_attr_show(d, attr, buf, sched); \
+	return tm_attr_show(d, buf, sched); \
 } \
 static ssize_t store_##name(struct device *d, struct device_attribute *attr, \
 			    const char *buf, size_t len) \
 { \
-	return tm_attr_store(d, attr, buf, len, sched); \
+	return tm_attr_store(d, buf, len, sched); \
 } \
 static DEVICE_ATTR(name, S_IRUGO | S_IWUSR, show_##name, store_##name)
 
