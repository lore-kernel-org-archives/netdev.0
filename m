From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next] net: l3mdev: Remove netif_index_is_l3_master
Date: Thu, 15 Sep 2016 10:18:45 -0700
Message-ID: <1473959925-22881-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:36624 "EHLO
        mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751257AbcIORSx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Sep 2016 13:18:53 -0400
Received: by mail-pf0-f170.google.com with SMTP id 128so18532953pfb.3
        for <netdev@vger.kernel.org>; Thu, 15 Sep 2016 10:18:53 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

No longer used after e0d56fdd73422 ("net: l3mdev: remove redundant calls")

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 include/net/l3mdev.h | 24 ------------------------
 1 file changed, 24 deletions(-)

diff --git a/include/net/l3mdev.h b/include/net/l3mdev.h
index 3832099289c5..b220dabeab45 100644
--- a/include/net/l3mdev.h
+++ b/include/net/l3mdev.h
@@ -114,25 +114,6 @@ static inline u32 l3mdev_fib_table(const struct net_device *dev)
 	return tb_id;
 }
 
-static inline bool netif_index_is_l3_master(struct net *net, int ifindex)
-{
-	struct net_device *dev;
-	bool rc = false;
-
-	if (ifindex == 0)
-		return false;
-
-	rcu_read_lock();
-
-	dev = dev_get_by_index_rcu(net, ifindex);
-	if (dev)
-		rc = netif_is_l3_master(dev);
-
-	rcu_read_unlock();
-
-	return rc;
-}
-
 struct dst_entry *l3mdev_link_scope_lookup(struct net *net, struct flowi6 *fl6);
 
 static inline
@@ -226,11 +207,6 @@ static inline u32 l3mdev_fib_table_by_index(struct net *net, int ifindex)
 	return 0;
 }
 
-static inline bool netif_index_is_l3_master(struct net *net, int ifindex)
-{
-	return false;
-}
-
 static inline
 struct dst_entry *l3mdev_link_scope_lookup(struct net *net, struct flowi6 *fl6)
 {
-- 
2.1.4
