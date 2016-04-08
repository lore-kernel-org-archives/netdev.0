From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCHv3 net-next 2/6] bridge: simplify the forward_delay_store by calling store_bridge_parm
Date: Sat,  9 Apr 2016 00:03:29 +0800
Message-ID: <6197a35a2eb6df2caf90edcbf1b49da12077f659.1460131308.git.lucien.xin@gmail.com>
References: <cover.1460131308.git.lucien.xin@gmail.com>
 <6e2cf6821542a253904dfc7d8ec431d6bbda2b4e.1460131308.git.lucien.xin@gmail.com>
Cc: davem@davemloft.net,
	Stephen Hemminger <stephen@networkplumber.org>,
	nikolay@cumulusnetworks.com
To: network dev <netdev@vger.kernel.org>,
	bridge@lists.linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:35556 "EHLO
	mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932200AbcDHQDt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Apr 2016 12:03:49 -0400
Received: by mail-pf0-f196.google.com with SMTP id r187so9826410pfr.2
        for <netdev@vger.kernel.org>; Fri, 08 Apr 2016 09:03:49 -0700 (PDT)
In-Reply-To: <6e2cf6821542a253904dfc7d8ec431d6bbda2b4e.1460131308.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1460131308.git.lucien.xin@gmail.com>
References: <cover.1460131308.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are some repetitive codes in forward_delay_store, we can remove
them by calling store_bridge_parm.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 net/bridge/br_sysfs_br.c | 27 ++++++++++-----------------
 1 file changed, 10 insertions(+), 17 deletions(-)

diff --git a/net/bridge/br_sysfs_br.c b/net/bridge/br_sysfs_br.c
index c48f6b0..137cd3b 100644
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
