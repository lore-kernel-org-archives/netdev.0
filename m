From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 2/4] net: allow to change carrier via sysfs
Date: Wed, 12 Dec 2012 11:58:05 +0100
Message-ID: <1355309887-1081-3-git-send-email-jiri@resnulli.us>
References: <1355309887-1081-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, edumazet@google.com,
	bhutchings@solarflare.com, mirqus@gmail.com, shemminger@vyatta.com,
	greearb@candelatech.com, fbl@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:51582 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751632Ab2LLK6U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Dec 2012 05:58:20 -0500
Received: by mail-ee0-f46.google.com with SMTP id e53so325427eek.19
        for <netdev@vger.kernel.org>; Wed, 12 Dec 2012 02:58:19 -0800 (PST)
In-Reply-To: <1355309887-1081-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make carrier writable

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 net/core/net-sysfs.c | 15 ++++++++++++++-
 1 file changed, 14 insertions(+), 1 deletion(-)

diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index 334efd5..7eda40a 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -126,6 +126,19 @@ static ssize_t show_broadcast(struct device *dev,
 	return -EINVAL;
 }
 
+static int change_carrier(struct net_device *net, unsigned long new_carrier)
+{
+	if (!netif_running(net))
+		return -EINVAL;
+	return dev_change_carrier(net, (bool) new_carrier);
+}
+
+static ssize_t store_carrier(struct device *dev, struct device_attribute *attr,
+			 const char *buf, size_t len)
+{
+	return netdev_store(dev, attr, buf, len, change_carrier);
+}
+
 static ssize_t show_carrier(struct device *dev,
 			    struct device_attribute *attr, char *buf)
 {
@@ -331,7 +344,7 @@ static struct device_attribute net_class_attributes[] = {
 	__ATTR(link_mode, S_IRUGO, show_link_mode, NULL),
 	__ATTR(address, S_IRUGO, show_address, NULL),
 	__ATTR(broadcast, S_IRUGO, show_broadcast, NULL),
-	__ATTR(carrier, S_IRUGO, show_carrier, NULL),
+	__ATTR(carrier, S_IRUGO | S_IWUSR, show_carrier, store_carrier),
 	__ATTR(speed, S_IRUGO, show_speed, NULL),
 	__ATTR(duplex, S_IRUGO, show_duplex, NULL),
 	__ATTR(dormant, S_IRUGO, show_dormant, NULL),
-- 
1.8.0
