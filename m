From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 4/6] ipv6: ipv6_chk_prefix() rcu conversion
Date: Sat,  7 Oct 2017 19:30:26 -0700
Message-ID: <20171008023028.32071-5-edumazet@google.com>
References: <20171008023028.32071-1-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f50.google.com ([74.125.83.50]:51553 "EHLO
        mail-pg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753363AbdJHCap (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 7 Oct 2017 22:30:45 -0400
Received: by mail-pg0-f50.google.com with SMTP id u144so8934731pgb.8
        for <netdev@vger.kernel.org>; Sat, 07 Oct 2017 19:30:45 -0700 (PDT)
In-Reply-To: <20171008023028.32071-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv6/addrconf.c | 8 +++-----
 1 file changed, 3 insertions(+), 5 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 33ee84c2512b50e316a0a6ed38a604a382ce5319..ea63442209bf268f1a19b5e014cb8c7e34fd40b4 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -1880,22 +1880,20 @@ EXPORT_SYMBOL(ipv6_chk_custom_prefix);
 
 int ipv6_chk_prefix(const struct in6_addr *addr, struct net_device *dev)
 {
-	struct inet6_dev *idev;
-	struct inet6_ifaddr *ifa;
+	const struct inet6_ifaddr *ifa;
+	const struct inet6_dev *idev;
 	int	onlink;
 
 	onlink = 0;
 	rcu_read_lock();
 	idev = __in6_dev_get(dev);
 	if (idev) {
-		read_lock_bh(&idev->lock);
-		list_for_each_entry(ifa, &idev->addr_list, if_list) {
+		list_for_each_entry_rcu(ifa, &idev->addr_list, if_list) {
 			onlink = ipv6_prefix_equal(addr, &ifa->addr,
 						   ifa->prefix_len);
 			if (onlink)
 				break;
 		}
-		read_unlock_bh(&idev->lock);
 	}
 	rcu_read_unlock();
 	return onlink;
-- 
2.14.2.920.gcf0c67979c-goog
