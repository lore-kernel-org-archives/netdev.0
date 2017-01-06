From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next] net: ipv4: make fib_select_default static
Date: Thu,  5 Jan 2017 19:33:59 -0800
Message-ID: <1483673639-14417-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f41.google.com ([74.125.83.41]:36658 "EHLO
        mail-pg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1162359AbdAFDeG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 5 Jan 2017 22:34:06 -0500
Received: by mail-pg0-f41.google.com with SMTP id f188so247091341pgc.3
        for <netdev@vger.kernel.org>; Thu, 05 Jan 2017 19:34:06 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

fib_select_default has a single caller within the same file.
Make it static.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 include/net/ip_fib.h     | 1 -
 net/ipv4/fib_semantics.c | 2 +-
 2 files changed, 1 insertion(+), 2 deletions(-)

diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
index 5f376af377c7..57c2a863d0b2 100644
--- a/include/net/ip_fib.h
+++ b/include/net/ip_fib.h
@@ -344,7 +344,6 @@ __be32 fib_compute_spec_dst(struct sk_buff *skb);
 int fib_validate_source(struct sk_buff *skb, __be32 src, __be32 dst,
 			u8 tos, int oif, struct net_device *dev,
 			struct in_device *idev, u32 *itag);
-void fib_select_default(const struct flowi4 *flp, struct fib_result *res);
 #ifdef CONFIG_IP_ROUTE_CLASSID
 static inline int fib_num_tclassid_users(struct net *net)
 {
diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index 7a5b4c7d9a87..05c911d21782 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -1434,7 +1434,7 @@ int fib_sync_down_dev(struct net_device *dev, unsigned long event, bool force)
 }
 
 /* Must be invoked inside of an RCU protected region.  */
-void fib_select_default(const struct flowi4 *flp, struct fib_result *res)
+static void fib_select_default(const struct flowi4 *flp, struct fib_result *res)
 {
 	struct fib_info *fi = NULL, *last_resort = NULL;
 	struct hlist_head *fa_head = res->fa_head;
-- 
2.1.4
