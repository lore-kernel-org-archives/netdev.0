From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 2/6] ipv6: ipv6_count_addresses() rcu conversion
Date: Sat,  7 Oct 2017 19:30:24 -0700
Message-ID: <20171008023028.32071-3-edumazet@google.com>
References: <20171008023028.32071-1-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f47.google.com ([74.125.83.47]:56339 "EHLO
        mail-pg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753336AbdJHCal (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 7 Oct 2017 22:30:41 -0400
Received: by mail-pg0-f47.google.com with SMTP id m18so5530869pgd.13
        for <netdev@vger.kernel.org>; Sat, 07 Oct 2017 19:30:41 -0700 (PDT)
In-Reply-To: <20171008023028.32071-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv6/addrconf.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index d1ff0955b709eaa6b5d94bd8d740334eb1eed6d7..2e029c8be1f2e2746e804a47bb5a3eb632adaa5d 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -152,7 +152,7 @@ static void ipv6_regen_rndid(struct inet6_dev *idev);
 static void ipv6_try_regen_rndid(struct inet6_dev *idev, struct in6_addr *tmpaddr);
 
 static int ipv6_generate_eui64(u8 *eui, struct net_device *dev);
-static int ipv6_count_addresses(struct inet6_dev *idev);
+static int ipv6_count_addresses(const struct inet6_dev *idev);
 static int ipv6_generate_stable_address(struct in6_addr *addr,
 					u8 dad_count,
 					const struct inet6_dev *idev);
@@ -1785,15 +1785,15 @@ int ipv6_get_lladdr(struct net_device *dev, struct in6_addr *addr,
 	return err;
 }
 
-static int ipv6_count_addresses(struct inet6_dev *idev)
+static int ipv6_count_addresses(const struct inet6_dev *idev)
 {
+	const struct inet6_ifaddr *ifp;
 	int cnt = 0;
-	struct inet6_ifaddr *ifp;
 
-	read_lock_bh(&idev->lock);
-	list_for_each_entry(ifp, &idev->addr_list, if_list)
+	rcu_read_lock();
+	list_for_each_entry_rcu(ifp, &idev->addr_list, if_list)
 		cnt++;
-	read_unlock_bh(&idev->lock);
+	rcu_read_unlock();
 	return cnt;
 }
 
-- 
2.14.2.920.gcf0c67979c-goog
