From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net] ipv6: restore the behavior of ipv6_sock_ac_drop()
Date: Fri,  5 Sep 2014 14:33:00 -0700
Message-ID: <1409952780-24471-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Sabrina Dubroca <sd@queasysnail.net>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:62783 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750940AbaIEVdT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Sep 2014 17:33:19 -0400
Received: by mail-pa0-f49.google.com with SMTP id kq14so22708103pab.22
        for <netdev@vger.kernel.org>; Fri, 05 Sep 2014 14:33:19 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is possible that the interface is already gone after joining
the list of anycast on this interface as we don't hold a refcount
for the device, in this case we are safe to ignore the error.

What's more important, for API compatibility we should not
change this behavior for applications even if it were correct.

Fixes: commit a9ed4a2986e13011 ("ipv6: fix rtnl locking in setsockopt for anycast and multicast")
Cc: Sabrina Dubroca <sd@queasysnail.net>
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/ipv6/anycast.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/net/ipv6/anycast.c b/net/ipv6/anycast.c
index 45b9d81..ff2de7d 100644
--- a/net/ipv6/anycast.c
+++ b/net/ipv6/anycast.c
@@ -182,8 +182,6 @@ int ipv6_sock_ac_drop(struct sock *sk, int ifindex, const struct in6_addr *addr)
 	rtnl_unlock();
 
 	sock_kfree_s(sk, pac, sizeof(*pac));
-	if (!dev)
-		return -ENODEV;
 	return 0;
 }
 
-- 
1.8.3.1
