From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [IPV4 5/5] fib_semantics: sparse warnings
Date: Wed, 23 Jan 2008 14:48:49 -0800
Message-ID: <20080123224859.070666632@linux-foundation.org>
References: <20080123224844.610730277@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:57043 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752244AbYAWXAs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Jan 2008 18:00:48 -0500
Content-Disposition: inline; filename=fib-semantic-sparse.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The magic macro change_nexthops introduces a variable nh which overlaps
previous declaration of nh.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/net/ipv4/fib_semantics.c	2008-01-23 11:03:55.000000000 -0800
+++ b/net/ipv4/fib_semantics.c	2008-01-23 11:05:12.000000000 -0800
@@ -1059,14 +1059,14 @@ int fib_sync_down(__be32 local, struct n
 		unsigned int hash = fib_devindex_hashfn(dev->ifindex);
 		struct hlist_head *head = &fib_info_devhash[hash];
 		struct hlist_node *node;
-		struct fib_nh *nh;
+		struct fib_nh *nh1;
 
-		hlist_for_each_entry(nh, node, head, nh_hash) {
-			struct fib_info *fi = nh->nh_parent;
+		hlist_for_each_entry(nh1, node, head, nh_hash) {
+			struct fib_info *fi = nh1->nh_parent;
 			int dead;
 
 			BUG_ON(!fi->fib_nhs);
-			if (nh->nh_dev != dev || fi == prev_fi)
+			if (nh1->nh_dev != dev || fi == prev_fi)
 				continue;
 			prev_fi = fi;
 			dead = 0;
@@ -1091,6 +1091,7 @@ int fib_sync_down(__be32 local, struct n
 				}
 #endif
 			} endfor_nexthops(fi)
+
 			if (dead == fi->fib_nhs) {
 				fi->fib_flags |= RTNH_F_DEAD;
 				ret++;
@@ -1114,7 +1115,7 @@ int fib_sync_up(struct net_device *dev)
 	unsigned int hash;
 	struct hlist_head *head;
 	struct hlist_node *node;
-	struct fib_nh *nh;
+	struct fib_nh *nh1;
 	int ret;
 
 	if (!(dev->flags&IFF_UP))
@@ -1125,12 +1126,12 @@ int fib_sync_up(struct net_device *dev)
 	head = &fib_info_devhash[hash];
 	ret = 0;
 
-	hlist_for_each_entry(nh, node, head, nh_hash) {
-		struct fib_info *fi = nh->nh_parent;
+	hlist_for_each_entry(nh1, node, head, nh_hash) {
+		struct fib_info *fi = nh1->nh_parent;
 		int alive;
 
 		BUG_ON(!fi->fib_nhs);
-		if (nh->nh_dev != dev || fi == prev_fi)
+		if (nh1->nh_dev != dev || fi == prev_fi)
 			continue;
 
 		prev_fi = fi;

-- 
Stephen Hemminger <stephen.hemminger@vyatta.com>

