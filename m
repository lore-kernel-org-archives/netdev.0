From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 09/11] net: l3mdev: Remove l3mdev_fib_oif
Date: Sat, 10 Sep 2016 12:10:00 -0700
Message-ID: <1473534602-23602-10-git-send-email-dsa@cumulusnetworks.com>
References: <1473534602-23602-1-git-send-email-dsa@cumulusnetworks.com>
Cc: shm@cumulusnetworks.com, David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:35401 "EHLO
        mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753826AbcIJTLd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 10 Sep 2016 15:11:33 -0400
Received: by mail-pa0-f47.google.com with SMTP id b2so38619066pat.2
        for <netdev@vger.kernel.org>; Sat, 10 Sep 2016 12:11:33 -0700 (PDT)
In-Reply-To: <1473534602-23602-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

No longer used

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 include/net/l3mdev.h | 29 -----------------------------
 1 file changed, 29 deletions(-)

diff --git a/include/net/l3mdev.h b/include/net/l3mdev.h
index a5e506eb51de..a586035c97cb 100644
--- a/include/net/l3mdev.h
+++ b/include/net/l3mdev.h
@@ -107,26 +107,6 @@ struct net_device *l3mdev_master_dev_rcu(const struct net_device *_dev)
 	return master;
 }
 
-/* get index of an interface to use for FIB lookups. For devices
- * enslaved to an L3 master device FIB lookups are based on the
- * master index
- */
-static inline int l3mdev_fib_oif_rcu(struct net_device *dev)
-{
-	return l3mdev_master_ifindex_rcu(dev) ? : dev->ifindex;
-}
-
-static inline int l3mdev_fib_oif(struct net_device *dev)
-{
-	int oif;
-
-	rcu_read_lock();
-	oif = l3mdev_fib_oif_rcu(dev);
-	rcu_read_unlock();
-
-	return oif;
-}
-
 u32 l3mdev_fib_table_rcu(const struct net_device *dev);
 u32 l3mdev_fib_table_by_index(struct net *net, int ifindex);
 static inline u32 l3mdev_fib_table(const struct net_device *dev)
@@ -248,15 +228,6 @@ struct net_device *l3mdev_master_dev_rcu(const struct net_device *dev)
 	return NULL;
 }
 
-static inline int l3mdev_fib_oif_rcu(struct net_device *dev)
-{
-	return dev ? dev->ifindex : 0;
-}
-static inline int l3mdev_fib_oif(struct net_device *dev)
-{
-	return dev ? dev->ifindex : 0;
-}
-
 static inline u32 l3mdev_fib_table_rcu(const struct net_device *dev)
 {
 	return 0;
-- 
2.1.4
