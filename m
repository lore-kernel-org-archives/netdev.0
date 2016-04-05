From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCHv2 net-next 1/6] bridge: simplify the flush_store by calling store_bridge_parm
Date: Tue,  5 Apr 2016 11:32:36 +0800
Message-ID: <6e2cf6821542a253904dfc7d8ec431d6bbda2b4e.1459827115.git.lucien.xin@gmail.com>
References: <cover.1459827115.git.lucien.xin@gmail.com>
Cc: davem@davemloft.net,
	Stephen Hemminger <stephen@networkplumber.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	nikolay@cumulusnetworks.com
To: network dev <netdev@vger.kernel.org>,
	bridge@lists.linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:36224 "EHLO
	mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753291AbcDEDcx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Apr 2016 23:32:53 -0400
Received: by mail-pf0-f193.google.com with SMTP id q129so141521pfb.3
        for <netdev@vger.kernel.org>; Mon, 04 Apr 2016 20:32:52 -0700 (PDT)
In-Reply-To: <cover.1459827115.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1459827115.git.lucien.xin@gmail.com>
References: <cover.1459827115.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are some repetitive codes in flush_store, we can remove
them by calling store_bridge_parm, also, it would send rtnl notification
after we add it in store_bridge_parm in the following patches.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 net/bridge/br_sysfs_br.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/net/bridge/br_sysfs_br.c b/net/bridge/br_sysfs_br.c
index 6b80914..c48f6b0 100644
--- a/net/bridge/br_sysfs_br.c
+++ b/net/bridge/br_sysfs_br.c
@@ -336,17 +336,17 @@ static ssize_t group_addr_store(struct device *d,
 
 static DEVICE_ATTR_RW(group_addr);
 
+static int set_flush(struct net_bridge *br, unsigned long val)
+{
+	br_fdb_flush(br);
+	return 0;
+}
+
 static ssize_t flush_store(struct device *d,
 			   struct device_attribute *attr,
 			   const char *buf, size_t len)
 {
-	struct net_bridge *br = to_bridge(d);
-
-	if (!ns_capable(dev_net(br->dev)->user_ns, CAP_NET_ADMIN))
-		return -EPERM;
-
-	br_fdb_flush(br);
-	return len;
+	return store_bridge_parm(d, buf, len, set_flush);
 }
 static DEVICE_ATTR_WO(flush);
 
-- 
2.1.0
