From: roy.qing.li@gmail.com
Subject: [PATCH][net-next] ipv6: replace write lock with read lock in addrconf_permanent_addr
Date: Mon, 14 Mar 2016 17:35:08 +0800
Message-ID: <1457948108-24837-1-git-send-email-roy.qing.li@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:51554 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753139AbcCNJfL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2016 05:35:11 -0400
Received: from localhost (lrq.corp.ad.wrs.com [128.224.162.186])
	by mail.windriver.com (8.15.2/8.15.1) with ESMTP id u2E9Z9bm009114
	for <netdev@vger.kernel.org>; Mon, 14 Mar 2016 02:35:10 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li RongQing <roy.qing.li@gmail.com>

nothing of idev is changed, so read lock is enough

Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
---
 net/ipv6/addrconf.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 8c0dab2..d3f0d87 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -3228,21 +3228,21 @@ static void addrconf_permanent_addr(struct net_device *dev)
 	if (!idev)
 		return;
 
-	write_lock_bh(&idev->lock);
+	read_lock_bh(&idev->lock);
 
 	list_for_each_entry_safe(ifp, tmp, &idev->addr_list, if_list) {
 		if ((ifp->flags & IFA_F_PERMANENT) &&
 		    fixup_permanent_addr(idev, ifp) < 0) {
-			write_unlock_bh(&idev->lock);
+			read_unlock_bh(&idev->lock);
 			ipv6_del_addr(ifp);
-			write_lock_bh(&idev->lock);
+			read_lock_bh(&idev->lock);
 
 			net_info_ratelimited("%s: Failed to add prefix route for address %pI6c; dropping\n",
 					     idev->dev->name, &ifp->addr);
 		}
 	}
 
-	write_unlock_bh(&idev->lock);
+	read_unlock_bh(&idev->lock);
 }
 
 static int addrconf_notify(struct notifier_block *this, unsigned long event,
-- 
2.1.4
