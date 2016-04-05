From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCHv2 net-next 3/6] bridge: simplify the stp_state_store by calling store_bridge_parm
Date: Tue,  5 Apr 2016 11:32:38 +0800
Message-ID: <baf4788b6ac529a2132ace735fc1caf4989307da.1459827115.git.lucien.xin@gmail.com>
References: <cover.1459827115.git.lucien.xin@gmail.com>
 <6e2cf6821542a253904dfc7d8ec431d6bbda2b4e.1459827115.git.lucien.xin@gmail.com>
 <6197a35a2eb6df2caf90edcbf1b49da12077f659.1459827115.git.lucien.xin@gmail.com>
Cc: davem@davemloft.net,
	Stephen Hemminger <stephen@networkplumber.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	nikolay@cumulusnetworks.com
To: network dev <netdev@vger.kernel.org>,
	bridge@lists.linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:33230 "EHLO
	mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753627AbcDEDdE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Apr 2016 23:33:04 -0400
Received: by mail-pf0-f193.google.com with SMTP id e190so151111pfe.0
        for <netdev@vger.kernel.org>; Mon, 04 Apr 2016 20:33:03 -0700 (PDT)
In-Reply-To: <6197a35a2eb6df2caf90edcbf1b49da12077f659.1459827115.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1459827115.git.lucien.xin@gmail.com>
References: <cover.1459827115.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are some repetitive codes in stp_state_store, we can remove
them by calling store_bridge_parm.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 net/bridge/br_sysfs_br.c | 24 +++++++-----------------
 1 file changed, 7 insertions(+), 17 deletions(-)

diff --git a/net/bridge/br_sysfs_br.c b/net/bridge/br_sysfs_br.c
index 137cd3b..9918763 100644
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
