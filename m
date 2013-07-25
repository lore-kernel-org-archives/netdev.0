From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v4 3/4] net: export physical port id via sysfs
Date: Thu, 25 Jul 2013 15:03:04 +0200
Message-ID: <1374757385-10875-4-git-send-email-jiri@resnulli.us>
References: <1374757385-10875-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, stephen@networkplumber.org,
	Narendra_K@Dell.com, bhutchings@solarflare.com,
	john.r.fastabend@intel.com, or.gerlitz@gmail.com,
	jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	bruce.w.allan@intel.com, carolyn.wyborny@intel.com,
	donald.c.skidmore@intel.com, gregory.v.rose@intel.com,
	peter.p.waskiewicz.jr@intel.com, alexander.h.duyck@intel.com,
	john.ronciak@intel.com, tushar.n.dave@intel.com,
	matthew.vick@intel.com, mitch.a.williams@intel.com,
	vyasevic@redhat.com, amwang@redhat.com, johannes@sipsolutions.net,
	Narendra K <narendra_k@dell.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f50.google.com ([74.125.83.50]:34543 "EHLO
	mail-ee0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755909Ab3GYNDW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jul 2013 09:03:22 -0400
Received: by mail-ee0-f50.google.com with SMTP id d49so899301eek.37
        for <netdev@vger.kernel.org>; Thu, 25 Jul 2013 06:03:20 -0700 (PDT)
In-Reply-To: <1374757385-10875-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
Acked-by: Ben Hutchings <bhutchings@solarflare.com>
Signed-off-by: Narendra K <narendra_k@dell.com>
---
 net/core/net-sysfs.c | 22 ++++++++++++++++++++++
 1 file changed, 22 insertions(+)

diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index 981fed3..8826b0d 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -334,6 +334,27 @@ static ssize_t store_group(struct device *dev, struct device_attribute *attr,
 	return netdev_store(dev, attr, buf, len, change_group);
 }
 
+static ssize_t show_phys_port_id(struct device *dev,
+				 struct device_attribute *attr, char *buf)
+{
+	struct net_device *netdev = to_net_dev(dev);
+	ssize_t ret = -EINVAL;
+
+	if (!rtnl_trylock())
+		return restart_syscall();
+
+	if (dev_isalive(netdev)) {
+		struct netdev_phys_port_id ppid;
+
+		ret = dev_get_phys_port_id(netdev, &ppid);
+		if (!ret)
+			ret = sprintf(buf, "%*phN\n", ppid.id_len, ppid.id);
+	}
+	rtnl_unlock();
+
+	return ret;
+}
+
 static struct device_attribute net_class_attributes[] = {
 	__ATTR(addr_assign_type, S_IRUGO, show_addr_assign_type, NULL),
 	__ATTR(addr_len, S_IRUGO, show_addr_len, NULL),
@@ -355,6 +376,7 @@ static struct device_attribute net_class_attributes[] = {
 	__ATTR(tx_queue_len, S_IRUGO | S_IWUSR, show_tx_queue_len,
 	       store_tx_queue_len),
 	__ATTR(netdev_group, S_IRUGO | S_IWUSR, show_group, store_group),
+	__ATTR(phys_port_id, S_IRUGO, show_phys_port_id, NULL),
 	{}
 };
 
-- 
1.8.1.4
