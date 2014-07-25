From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next] netlink: Fix shadow warning on jiffies
Date: Fri, 25 Jul 2014 02:18:17 -0700
Message-ID: <1406279897-6403-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mark Rustad <mark.d.rustad@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:8932 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758075AbaGYJSV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Jul 2014 05:18:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Rustad <mark.d.rustad@intel.com>

Change formal parameter name to not shadow the global jiffies.

Signed-off-by: Mark Rustad <mark.d.rustad@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 include/net/netlink.h | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/include/net/netlink.h b/include/net/netlink.h
index 2b47eaa..6c10762 100644
--- a/include/net/netlink.h
+++ b/include/net/netlink.h
@@ -949,12 +949,12 @@ static inline int nla_put_flag(struct sk_buff *skb, int attrtype)
  * nla_put_msecs - Add a msecs netlink attribute to a socket buffer
  * @skb: socket buffer to add attribute to
  * @attrtype: attribute type
- * @jiffies: number of msecs in jiffies
+ * @njiffies: number of jiffies to convert to msecs
  */
 static inline int nla_put_msecs(struct sk_buff *skb, int attrtype,
-				unsigned long jiffies)
+				unsigned long njiffies)
 {
-	u64 tmp = jiffies_to_msecs(jiffies);
+	u64 tmp = jiffies_to_msecs(njiffies);
 	return nla_put(skb, attrtype, sizeof(u64), &tmp);
 }
 
-- 
1.9.3
