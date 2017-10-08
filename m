From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 5/6] ipv6: __ipv6_dev_get_saddr() rcu conversion
Date: Sat,  7 Oct 2017 19:30:27 -0700
Message-ID: <20171008023028.32071-6-edumazet@google.com>
References: <20171008023028.32071-1-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:51334 "EHLO
        mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750981AbdJHCar (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 7 Oct 2017 22:30:47 -0400
Received: by mail-pf0-f172.google.com with SMTP id n14so9306407pfh.8
        for <netdev@vger.kernel.org>; Sat, 07 Oct 2017 19:30:47 -0700 (PDT)
In-Reply-To: <20171008023028.32071-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Callers hold rcu_read_lock(), so we do not need
the rcu_read_lock()/rcu_read_unlock() pair.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv6/addrconf.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index ea63442209bf268f1a19b5e014cb8c7e34fd40b4..20c3ca777529fc49ebf749ca6f7d8c2451258d55 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -1558,8 +1558,7 @@ static int __ipv6_dev_get_saddr(struct net *net,
 {
 	struct ipv6_saddr_score *score = &scores[1 - hiscore_idx], *hiscore = &scores[hiscore_idx];
 
-	read_lock_bh(&idev->lock);
-	list_for_each_entry(score->ifa, &idev->addr_list, if_list) {
+	list_for_each_entry_rcu(score->ifa, &idev->addr_list, if_list) {
 		int i;
 
 		/*
@@ -1625,7 +1624,6 @@ static int __ipv6_dev_get_saddr(struct net *net,
 		}
 	}
 out:
-	read_unlock_bh(&idev->lock);
 	return hiscore_idx;
 }
 
-- 
2.14.2.920.gcf0c67979c-goog
