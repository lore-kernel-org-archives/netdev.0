From: "David S. Miller" <davem@davemloft.net>
Subject: [PATCH 04/51] phonet: Stop using NLA_PUT*().
Date: Sun,  1 Apr 2012 22:57:54 -0400
Message-ID: <1333335521-1348-5-git-send-email-davem@davemloft.net>
References: <1333335521-1348-1-git-send-email-davem@davemloft.net>
Cc: "David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:46701 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754258Ab2DBC7d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Apr 2012 22:59:33 -0400
In-Reply-To: <1333335521-1348-1-git-send-email-davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "David S. Miller" <davem@davemloft.net>

These macros contain a hidden goto, and are thus extremely error
prone and make code hard to audit.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/phonet/pn_netlink.c |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/net/phonet/pn_netlink.c b/net/phonet/pn_netlink.c
index d61f676..cfdf135 100644
--- a/net/phonet/pn_netlink.c
+++ b/net/phonet/pn_netlink.c
@@ -116,7 +116,8 @@ static int fill_addr(struct sk_buff *skb, struct net_device *dev, u8 addr,
 	ifm->ifa_flags = IFA_F_PERMANENT;
 	ifm->ifa_scope = RT_SCOPE_LINK;
 	ifm->ifa_index = dev->ifindex;
-	NLA_PUT_U8(skb, IFA_LOCAL, addr);
+	if (nla_put_u8(skb, IFA_LOCAL, addr))
+		goto nla_put_failure;
 	return nlmsg_end(skb, nlh);
 
 nla_put_failure:
@@ -183,8 +184,9 @@ static int fill_route(struct sk_buff *skb, struct net_device *dev, u8 dst,
 	rtm->rtm_scope = RT_SCOPE_UNIVERSE;
 	rtm->rtm_type = RTN_UNICAST;
 	rtm->rtm_flags = 0;
-	NLA_PUT_U8(skb, RTA_DST, dst);
-	NLA_PUT_U32(skb, RTA_OIF, dev->ifindex);
+	if (nla_put_u8(skb, RTA_DST, dst) ||
+	    nla_put_u32(skb, RTA_OIF, dev->ifindex))
+		goto nla_put_failure;
 	return nlmsg_end(skb, nlh);
 
 nla_put_failure:
-- 
1.7.7.6
