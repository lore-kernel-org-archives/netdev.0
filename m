From: "David S. Miller" <davem@davemloft.net>
Subject: [PATCH 31/51] infiniband: Stop using NLA_PUT*().
Date: Sun,  1 Apr 2012 22:58:21 -0400
Message-ID: <1333335521-1348-32-git-send-email-davem@davemloft.net>
References: <1333335521-1348-1-git-send-email-davem@davemloft.net>
Cc: "David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:46757 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754391Ab2DBC75 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Apr 2012 22:59:57 -0400
In-Reply-To: <1333335521-1348-1-git-send-email-davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "David S. Miller" <davem@davemloft.net>

These macros contain a hidden goto, and are thus extremely error
prone and make code hard to audit.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/infiniband/core/netlink.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/infiniband/core/netlink.c b/drivers/infiniband/core/netlink.c
index 396e293..e497dfb 100644
--- a/drivers/infiniband/core/netlink.c
+++ b/drivers/infiniband/core/netlink.c
@@ -125,7 +125,8 @@ int ibnl_put_attr(struct sk_buff *skb, struct nlmsghdr *nlh,
 	unsigned char *prev_tail;
 
 	prev_tail = skb_tail_pointer(skb);
-	NLA_PUT(skb, type, len, data);
+	if (nla_put(skb, type, len, data))
+		goto nla_put_failure;
 	nlh->nlmsg_len += skb_tail_pointer(skb) - prev_tail;
 	return 0;
 
-- 
1.7.7.6
