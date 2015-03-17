From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net] netdevice.h: fix ndo_bridge_* comments
Date: Tue, 17 Mar 2015 11:16:00 +0100
Message-ID: <1426587360-5368-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Vlad Yasevich <vyasevic@redhat.com>,
	Roopa Prabhu <roopa@cumulusnetworks.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:34328 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753770AbbCQKQG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2015 06:16:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The argument 'flags' was missing in ndo_bridge_setlink().
ndo_bridge_dellink() was missing.

Fixes: 407af3299ef1 ("bridge: Add netlink interface to configure vlans on bridge ports")
Fixes: add511b38266 ("bridge: add flags argument to ndo_bridge_setlink and ndo_bridge_dellink")
CC: Vlad Yasevich <vyasevic@redhat.com>
CC: Roopa Prabhu <roopa@cumulusnetworks.com>
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 include/linux/netdevice.h | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 429d1790a27e..dcf6ec27739b 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -965,9 +965,12 @@ typedef u16 (*select_queue_fallback_t)(struct net_device *dev,
  *	Used to add FDB entries to dump requests. Implementers should add
  *	entries to skb and update idx with the number of entries.
  *
- * int (*ndo_bridge_setlink)(struct net_device *dev, struct nlmsghdr *nlh)
+ * int (*ndo_bridge_setlink)(struct net_device *dev, struct nlmsghdr *nlh,
+ *			     u16 flags)
  * int (*ndo_bridge_getlink)(struct sk_buff *skb, u32 pid, u32 seq,
  *			     struct net_device *dev, u32 filter_mask)
+ * int (*ndo_bridge_dellink)(struct net_device *dev, struct nlmsghdr *nlh,
+ *			     u16 flags);
  *
  * int (*ndo_change_carrier)(struct net_device *dev, bool new_carrier);
  *	Called to change device carrier. Soft-devices (like dummy, team, etc)
-- 
2.2.2
