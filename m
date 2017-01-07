From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next] net: ipmr: Remove nowait arg to ipmr_get_route
Date: Fri,  6 Jan 2017 17:39:06 -0800
Message-ID: <1483753146-16168-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f47.google.com ([74.125.83.47]:34964 "EHLO
        mail-pg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1759483AbdAGBjL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Jan 2017 20:39:11 -0500
Received: by mail-pg0-f47.google.com with SMTP id i5so192232691pgh.2
        for <netdev@vger.kernel.org>; Fri, 06 Jan 2017 17:39:11 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ipmr_get_route has 1 caller and the nowait arg is 0. Remove the arg and
simplify ipmr_get_route accordingly.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 include/linux/mroute.h | 2 +-
 net/ipv4/ipmr.c        | 7 +------
 net/ipv4/route.c       | 2 +-
 3 files changed, 3 insertions(+), 8 deletions(-)

diff --git a/include/linux/mroute.h b/include/linux/mroute.h
index e5fb81376e92..f019b62f27b5 100644
--- a/include/linux/mroute.h
+++ b/include/linux/mroute.h
@@ -120,5 +120,5 @@ struct mfc_cache {
 struct rtmsg;
 int ipmr_get_route(struct net *net, struct sk_buff *skb,
 		   __be32 saddr, __be32 daddr,
-		   struct rtmsg *rtm, int nowait, u32 portid);
+		   struct rtmsg *rtm, u32 portid);
 #endif
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index b35dda57586b..824c4fdf21eb 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -2136,7 +2136,7 @@ static int __ipmr_fill_mroute(struct mr_table *mrt, struct sk_buff *skb,
 
 int ipmr_get_route(struct net *net, struct sk_buff *skb,
 		   __be32 saddr, __be32 daddr,
-		   struct rtmsg *rtm, int nowait, u32 portid)
+		   struct rtmsg *rtm, u32 portid)
 {
 	struct mfc_cache *cache;
 	struct mr_table *mrt;
@@ -2160,11 +2160,6 @@ int ipmr_get_route(struct net *net, struct sk_buff *skb,
 		struct net_device *dev;
 		int vif = -1;
 
-		if (nowait) {
-			rcu_read_unlock();
-			return -EAGAIN;
-		}
-
 		dev = skb->dev;
 		read_lock(&mrt_lock);
 		if (dev)
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index b9bff78274bf..f51823dc998b 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2540,7 +2540,7 @@ static int rt_fill_info(struct net *net,  __be32 dst, __be32 src, u32 table_id,
 		    IPV4_DEVCONF_ALL(net, MC_FORWARDING)) {
 			int err = ipmr_get_route(net, skb,
 						 fl4->saddr, fl4->daddr,
-						 r, 0, portid);
+						 r, portid);
 
 			if (err <= 0) {
 				if (err == 0)
-- 
2.1.4
