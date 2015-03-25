From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net 2/2] ipmr,ip6mr: call list_del_rcu() when deleting mr table from list
Date: Wed, 25 Mar 2015 12:05:45 -0700
Message-ID: <1427310345-29829-2-git-send-email-xiyou.wangcong@gmail.com>
References: <1427310345-29829-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:36007 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750764AbbCYTF5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2015 15:05:57 -0400
Received: by pdbcz9 with SMTP id cz9so37314581pdb.3
        for <netdev@vger.kernel.org>; Wed, 25 Mar 2015 12:05:56 -0700 (PDT)
In-Reply-To: <1427310345-29829-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Probably not a big deal, just for corretness.

Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/ipv4/ipmr.c  | 2 +-
 net/ipv6/ip6mr.c | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index d6fede8..68f67b8 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -280,7 +280,7 @@ static void __net_exit ipmr_rules_exit(struct net *net)
 
 	rtnl_lock();
 	list_for_each_entry_safe(mrt, next, &net->ipv4.mr_tables, list) {
-		list_del(&mrt->list);
+		list_del_rcu(&mrt->list);
 		ipmr_free_table(mrt);
 	}
 	rtnl_unlock();
diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index 34b6826..3df1ec2 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -264,7 +264,7 @@ static void __net_exit ip6mr_rules_exit(struct net *net)
 
 	rtnl_lock();
 	list_for_each_entry_safe(mrt, next, &net->ipv6.mr6_tables, list) {
-		list_del(&mrt->list);
+		list_del_rcu(&mrt->list);
 		ip6mr_free_table(mrt);
 	}
 	rtnl_unlock();
-- 
1.8.3.1
