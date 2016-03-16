From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net-next 3/6] bridge: simplify the stp_state_store by calling store_bridge_parm
Date: Wed, 16 Mar 2016 21:34:46 +0800
Message-ID: <45f430c026ce8a2fb358c650a41452aebff9ec36.1458134414.git.lucien.xin@gmail.com>
References: <cover.1458134414.git.lucien.xin@gmail.com>
 <059d608901fd86407fed374e567c46447aa8c88f.1458134414.git.lucien.xin@gmail.com>
 <f379a033c5b7798906c57dd1bb67df89b7de02cb.1458134414.git.lucien.xin@gmail.com>
Cc: davem@davemloft.net,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	nikolay@cumulusnetworks.com
To: network dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:34230 "EHLO
	mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966327AbcCPNfK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Mar 2016 09:35:10 -0400
Received: by mail-pf0-f193.google.com with SMTP id n5so6721049pfn.1
        for <netdev@vger.kernel.org>; Wed, 16 Mar 2016 06:35:09 -0700 (PDT)
In-Reply-To: <f379a033c5b7798906c57dd1bb67df89b7de02cb.1458134414.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1458134414.git.lucien.xin@gmail.com>
References: <cover.1458134414.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are some repetitive codes in stp_state_store, we can remove
them by calling store_bridge_parm.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 net/bridge/br_sysfs_br.c | 24 +++++++-----------------
 1 file changed, 7 insertions(+), 17 deletions(-)

diff --git a/net/bridge/br_sysfs_br.c b/net/bridge/br_sysfs_br.c
index c846bf9..5d9fee2 100644
--- a/net/bridge/br_sysfs_br.c
+++ b/net/bridge/br_sysfs_br.c
@@ -128,27 +128,17 @@ static ssize_t stp_state_show(struct device *d,
 }
 
 
+static int set_stp_state(struct net_bridge *br, unsigned long val)
+{
+	br_stp_set_enabled(br, val);
+	return 0;
+}
+
 static ssize_t stp_state_store(struct device *d,
 			       struct device_attribute *attr, const char *buf,
 			       size_t len)
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
-	if (!rtnl_trylock())
-		return restart_syscall();
-	br_stp_set_enabled(br, val);
-	rtnl_unlock();
-
-	return len;
+	return store_bridge_parm(d, buf, len, set_stp_state);
 }
 static DEVICE_ATTR_RW(stp_state);
 
-- 
2.1.0
