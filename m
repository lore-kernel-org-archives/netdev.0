From: Shan Wei <shanwei@cn.fujitsu.com>
Subject: [PATCH BUGFIX ] ipv6: fix the bug of address check
Date: Mon, 17 May 2010 20:23:38 +0800
Message-ID: <4BF1354A.3060003@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:52381 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752747Ab0EQMYj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 May 2010 08:24:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


If there are several IPv6 addresses with same hash value in hashlist,
and they are all not matched with addr argument.
In this case, ipv6_chk_addr() should return 0.

This bug is introduced by commit c2e21293c054817c42eb5fa9c613d2ad51954136
(title: ipv6: convert addrconf list to hlist).

Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>
---
 net/ipv6/addrconf.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 3984f52..d8e5907 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -1291,7 +1291,7 @@ int ipv6_chk_addr(struct net *net, struct in6_addr *addr,
 	}
 	rcu_read_unlock_bh();
 
-	return ifp != NULL;
+	return node != NULL;
 }
 EXPORT_SYMBOL(ipv6_chk_addr);
 
-- 
1.6.3.3
