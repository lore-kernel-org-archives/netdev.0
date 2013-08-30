From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 22/31] net: niu: use dev_get_platdata()
Date: Fri, 30 Aug 2013 14:04:17 +0900
Message-ID: <004601cea53e$610647c0$2312d740$%han@samsung.com>
References: <003101cea53b$9fc95b30$df5c1190$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Jingoo Han' <jg1.han@samsung.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout2.samsung.com ([203.254.224.25]:61392 "EHLO
	mailout2.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752567Ab3H3FES (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Aug 2013 01:04:18 -0400
Received: from epcpsbgr1.samsung.com
 (u141.gpu120.samsung.co.kr [203.254.230.141])
 by mailout2.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MSB009VTVDQ8RQ0@mailout2.samsung.com> for
 netdev@vger.kernel.org; Fri, 30 Aug 2013 14:04:17 +0900 (KST)
In-reply-to: <003101cea53b$9fc95b30$df5c1190$%han@samsung.com>
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the wrapper function for retrieving the platform data instead of
accessing dev->platform_data directly. This is a cosmetic change
to make the code simpler and enhance the readability.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/ethernet/sun/niu.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/sun/niu.c b/drivers/net/ethernet/sun/niu.c
index 52b2adf..f28460c 100644
--- a/drivers/net/ethernet/sun/niu.c
+++ b/drivers/net/ethernet/sun/niu.c
@@ -9360,7 +9360,7 @@ static ssize_t show_port_phy(struct device *dev,
 			     struct device_attribute *attr, char *buf)
 {
 	struct platform_device *plat_dev = to_platform_device(dev);
-	struct niu_parent *p = plat_dev->dev.platform_data;
+	struct niu_parent *p = dev_get_platdata(&plat_dev->dev);
 	u32 port_phy = p->port_phy;
 	char *orig_buf = buf;
 	int i;
@@ -9390,7 +9390,7 @@ static ssize_t show_plat_type(struct device *dev,
 			      struct device_attribute *attr, char *buf)
 {
 	struct platform_device *plat_dev = to_platform_device(dev);
-	struct niu_parent *p = plat_dev->dev.platform_data;
+	struct niu_parent *p = dev_get_platdata(&plat_dev->dev);
 	const char *type_str;
 
 	switch (p->plat_type) {
@@ -9419,7 +9419,7 @@ static ssize_t __show_chan_per_port(struct device *dev,
 				    int rx)
 {
 	struct platform_device *plat_dev = to_platform_device(dev);
-	struct niu_parent *p = plat_dev->dev.platform_data;
+	struct niu_parent *p = dev_get_platdata(&plat_dev->dev);
 	char *orig_buf = buf;
 	u8 *arr;
 	int i;
@@ -9452,7 +9452,7 @@ static ssize_t show_num_ports(struct device *dev,
 			      struct device_attribute *attr, char *buf)
 {
 	struct platform_device *plat_dev = to_platform_device(dev);
-	struct niu_parent *p = plat_dev->dev.platform_data;
+	struct niu_parent *p = dev_get_platdata(&plat_dev->dev);
 
 	return sprintf(buf, "%d\n", p->num_ports);
 }
-- 
1.7.10.4
