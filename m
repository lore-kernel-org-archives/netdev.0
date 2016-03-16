From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net-next 2/6] bridge: simplify the forward_delay_store by calling store_bridge_parm
Date: Wed, 16 Mar 2016 21:34:45 +0800
Message-ID: <f379a033c5b7798906c57dd1bb67df89b7de02cb.1458134414.git.lucien.xin@gmail.com>
References: <cover.1458134414.git.lucien.xin@gmail.com>
 <059d608901fd86407fed374e567c46447aa8c88f.1458134414.git.lucien.xin@gmail.com>
Cc: davem@davemloft.net,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	nikolay@cumulusnetworks.com
To: network dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:32866 "EHLO
	mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966228AbcCPNfG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Mar 2016 09:35:06 -0400
Received: by mail-pf0-f194.google.com with SMTP id x3so6722897pfb.0
        for <netdev@vger.kernel.org>; Wed, 16 Mar 2016 06:35:06 -0700 (PDT)
In-Reply-To: <059d608901fd86407fed374e567c46447aa8c88f.1458134414.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1458134414.git.lucien.xin@gmail.com>
References: <cover.1458134414.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are some repetitive codes in forward_delay_store, we can remove
them by calling store_bridge_parm.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 net/bridge/br_sysfs_br.c | 27 ++++++++++-----------------
 1 file changed, 10 insertions(+), 17 deletions(-)

diff --git a/net/bridge/br_sysfs_br.c b/net/bridge/br_sysfs_br.c
index 095a751..c846bf9 100644
--- a/net/bridge/br_sysfs_br.c
+++ b/net/bridge/br_sysfs_br.c
@@ -160,29 +160,22 @@ static ssize_t group_fwd_mask_show(struct device *d,
 	return sprintf(buf, "%#x\n", br->group_fwd_mask);
 }
 
-
-static ssize_t group_fwd_mask_store(struct device *d,
-				    struct device_attribute *attr,
-				    const char *buf,
-				    size_t len)
+static int set_group_fwd_mask(struct net_bridge *br, unsigned long val)
 {
-	struct net_bridge *br = to_bridge(d);
-	char *endp;
-	unsigned long val;
-
-	if (!ns_capable(dev_net(br->dev)->user_ns, CAP_NET_ADMIN))
-		return -EPERM;
-
-	val = simple_strtoul(buf, &endp, 0);
-	if (endp == buf)
-		return -EINVAL;
-
 	if (val & BR_GROUPFWD_RESTRICTED)
 		return -EINVAL;
 
 	br->group_fwd_mask = val;
 
-	return len;
+	return 0;
+}
+
+static ssize_t group_fwd_mask_store(struct device *d,
+				    struct device_attribute *attr,
+				    const char *buf,
+				    size_t len)
+{
+	return store_bridge_parm(d, buf, len, set_group_fwd_mask);
 }
 static DEVICE_ATTR_RW(group_fwd_mask);
 
-- 
2.1.0
