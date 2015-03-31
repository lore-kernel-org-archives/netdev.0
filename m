From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net] ip6mr: call del_timer_sync() in ip6mr_free_table()
Date: Tue, 31 Mar 2015 11:01:47 -0700
Message-ID: <1427824907-13331-3-git-send-email-xiyou.wangcong@gmail.com>
References: <1427824907-13331-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:34592 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753402AbbCaSCy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Mar 2015 14:02:54 -0400
Received: by pactp5 with SMTP id tp5so26590698pac.1
        for <netdev@vger.kernel.org>; Tue, 31 Mar 2015 11:02:53 -0700 (PDT)
In-Reply-To: <1427824907-13331-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We need to wait for the flying timers, since we
are going to free the mrtable right after it.

Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/ipv6/ip6mr.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index 2f1fd9f..312e0ff 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -336,7 +336,7 @@ static struct mr6_table *ip6mr_new_table(struct net *net, u32 id)
 
 static void ip6mr_free_table(struct mr6_table *mrt)
 {
-	del_timer(&mrt->ipmr_expire_timer);
+	del_timer_sync(&mrt->ipmr_expire_timer);
 	mroute_clean_tables(mrt);
 	kfree(mrt);
 }
-- 
1.8.3.1
