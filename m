From: David Miller <davem@davemloft.net>
Subject: [PATCH 18/18] netlink: Delete NLMSG_PUT and NLMSG_NEW.
Date: Tue, 26 Jun 2012 22:02:57 -0700 (PDT)
Message-ID: <20120626.220257.279071850246220686.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39242 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751756Ab2F0FC6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jun 2012 01:02:58 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id A158B584196
	for <netdev@vger.kernel.org>; Tue, 26 Jun 2012 22:02:58 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


No longer used and a poor interface as they were macros
with embedded gotos.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/linux/netlink.h |    8 --------
 1 file changed, 8 deletions(-)

diff --git a/include/linux/netlink.h b/include/linux/netlink.h
index 0f628ff..ed33f09 100644
--- a/include/linux/netlink.h
+++ b/include/linux/netlink.h
@@ -241,14 +241,6 @@ struct netlink_notify {
 struct nlmsghdr *
 __nlmsg_put(struct sk_buff *skb, u32 pid, u32 seq, int type, int len, int flags);
 
-#define NLMSG_NEW(skb, pid, seq, type, len, flags) \
-({	if (unlikely(skb_tailroom(skb) < (int)NLMSG_SPACE(len))) \
-		goto nlmsg_failure; \
-	__nlmsg_put(skb, pid, seq, type, len, flags); })
-
-#define NLMSG_PUT(skb, pid, seq, type, len) \
-	NLMSG_NEW(skb, pid, seq, type, len, 0)
-
 struct netlink_dump_control {
 	int (*dump)(struct sk_buff *skb, struct netlink_callback *);
 	int (*done)(struct netlink_callback*);
-- 
1.7.10.2
