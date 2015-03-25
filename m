From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net 2/2] ipmr,ip6mr: call ip6mr_free_table() on failure path
Date: Wed, 25 Mar 2015 14:45:03 -0700
Message-ID: <1427319903-22976-2-git-send-email-xiyou.wangcong@gmail.com>
References: <1427319903-22976-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:35963 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751500AbbCYVp1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2015 17:45:27 -0400
Received: by pdbcz9 with SMTP id cz9so41132307pdb.3
        for <netdev@vger.kernel.org>; Wed, 25 Mar 2015 14:45:26 -0700 (PDT)
In-Reply-To: <1427319903-22976-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/ipv4/ipmr.c  | 2 +-
 net/ipv6/ip6mr.c | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 68f67b8..fc12a09 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -268,7 +268,7 @@ static int __net_init ipmr_rules_init(struct net *net)
 	return 0;
 
 err2:
-	kfree(mrt);
+	ipmr_free_table(mrt);
 err1:
 	fib_rules_unregister(ops);
 	return err;
diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index 3df1ec2..9916f6f 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -252,7 +252,7 @@ static int __net_init ip6mr_rules_init(struct net *net)
 	return 0;
 
 err2:
-	kfree(mrt);
+	ip6mr_free_table(mrt);
 err1:
 	fib_rules_unregister(ops);
 	return err;
-- 
1.8.3.1
