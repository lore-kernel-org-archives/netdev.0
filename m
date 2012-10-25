From: <zhanghonghui@huawei.com>
Subject: [PATCH] netlink: get rid of the useless function of nlmsg_get_pos()
Date: Thu, 25 Oct 2012 18:00:08 +0800
Message-ID: <1351159208-9308-1-git-send-email-zhanghonghui@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Hans Zhang <zhanghonghui@huawei.com>
To: <davem@davemloft.net>, <kuznet@ms2.inr.ac.ru>, <jmorris@namei.org>,
	<lizefan@huawei.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:14132 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934884Ab2JYKB2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Oct 2012 06:01:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hans Zhang <zhanghonghui@huawei.com>

This function just report the pointer of skb->tail, and there's only
one use in the kernel.

Signed-off-by: Hans Zhang <zhanghonghui@huawei.com>
---
 include/net/netlink.h    |   12 ------------
 net/ipv4/fib_semantics.c |    2 +-
 2 files changed, 1 insertions(+), 13 deletions(-)

diff --git a/include/net/netlink.h b/include/net/netlink.h
index 9690b0f..ca36b08 100644
--- a/include/net/netlink.h
+++ b/include/net/netlink.h
@@ -36,7 +36,6 @@
  *   nlmsg_put()			add a netlink message to an skb
  *   nlmsg_put_answer()			callback based nlmsg_put()
  *   nlmsg_end()			finalize netlink message
- *   nlmsg_get_pos()			return current position in message
  *   nlmsg_trim()			trim part of message
  *   nlmsg_cancel()			cancel message construction
  *   nlmsg_free()			free a netlink message
@@ -514,17 +513,6 @@ static inline int nlmsg_end(struct sk_buff *skb, struct nlmsghdr *nlh)
 }
 
 /**
- * nlmsg_get_pos - return current position in netlink message
- * @skb: socket buffer the message is stored in
- *
- * Returns a pointer to the current tail of the message.
- */
-static inline void *nlmsg_get_pos(struct sk_buff *skb)
-{
-	return skb_tail_pointer(skb);
-}
-
-/**
  * nlmsg_trim - Trim message to a mark
  * @skb: socket buffer the message is stored in
  * @mark: mark to trim to
diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index 4797a80..8d047bf 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -1072,7 +1072,7 @@ int fib_dump_info(struct sk_buff *skb, u32 portid, u32 seq, int event,
 				goto nla_put_failure;
 #endif
 			/* length of rtnetlink header + attributes */
-			rtnh->rtnh_len = nlmsg_get_pos(skb) - (void *) rtnh;
+			rtnh->rtnh_len = (void *) skb_tail_pointer(skb) - (void *) rtnh;
 		} endfor_nexthops(fi);
 
 		nla_nest_end(skb, mp);
-- 
1.7.1
