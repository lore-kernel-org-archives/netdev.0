From: Florian Westphal <fw@strlen.de>
Subject: [PATCH net-next v3 3/6] rtnetlink: add helper to dump ifalias
Date: Sat, 23 Sep 2017 21:26:33 +0200
Message-ID: <20170923192636.3932-4-fw@strlen.de>
References: <20170923192636.3932-1-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:46818 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751740AbdIWT03 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 23 Sep 2017 15:26:29 -0400
In-Reply-To: <20170923192636.3932-1-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reviewed-by: David Ahern <dsahern@gmail.com>
Signed-off-by: Florian Westphal <fw@strlen.de>
---
 Changes since v3: don't add rtnl assertion, I placed the assertion
 in my working tree instead as a reminder.

 net/core/rtnetlink.c | 11 +++++++++--
 1 file changed, 9 insertions(+), 2 deletions(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index c801212ee40e..47c17c3de79a 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1332,6 +1332,14 @@ static int nla_put_iflink(struct sk_buff *skb, const struct net_device *dev)
 	return nla_put_u32(skb, IFLA_LINK, ifindex);
 }
 
+static noinline int nla_put_ifalias(struct sk_buff *skb, struct net_device *dev)
+{
+	if (dev->ifalias)
+		return nla_put_string(skb, IFLA_IFALIAS, dev->ifalias);
+
+	return 0;
+}
+
 static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 			    int type, u32 pid, u32 seq, u32 change,
 			    unsigned int flags, u32 ext_filter_mask,
@@ -1374,8 +1382,7 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 	    nla_put_u8(skb, IFLA_CARRIER, netif_carrier_ok(dev)) ||
 	    (dev->qdisc &&
 	     nla_put_string(skb, IFLA_QDISC, dev->qdisc->ops->id)) ||
-	    (dev->ifalias &&
-	     nla_put_string(skb, IFLA_IFALIAS, dev->ifalias)) ||
+	    nla_put_ifalias(skb, dev) ||
 	    nla_put_u32(skb, IFLA_CARRIER_CHANGES,
 			atomic_read(&dev->carrier_changes)) ||
 	    nla_put_u8(skb, IFLA_PROTO_DOWN, dev->proto_down))
-- 
2.13.5
