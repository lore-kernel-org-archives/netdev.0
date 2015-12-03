From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net] gre6: allow to update all parameters via rtnl
Date: Thu,  3 Dec 2015 17:21:50 +0100
Message-ID: <1449159710-489-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from host.76.145.23.62.rev.coltfrance.com ([62.23.145.76]:51451 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752486AbbLCQWN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2015 11:22:13 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Parameters were updated only if the kernel was unable to find the tunnel
with the new parameters, ie only if core pamareters were updated (keys,
addr, link, type).
Now it's possible to update ttl, hoplimit, flowinfo and flags.

Fixes: c12b395a4664 ("gre: Support GRE over IPv6")
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/ipv6/ip6_gre.c | 8 +++-----
 1 file changed, 3 insertions(+), 5 deletions(-)

diff --git a/net/ipv6/ip6_gre.c b/net/ipv6/ip6_gre.c
index 3c7b9310b33f..e5ea177d34c6 100644
--- a/net/ipv6/ip6_gre.c
+++ b/net/ipv6/ip6_gre.c
@@ -1571,13 +1571,11 @@ static int ip6gre_changelink(struct net_device *dev, struct nlattr *tb[],
 			return -EEXIST;
 	} else {
 		t = nt;
-
-		ip6gre_tunnel_unlink(ign, t);
-		ip6gre_tnl_change(t, &p, !tb[IFLA_MTU]);
-		ip6gre_tunnel_link(ign, t);
-		netdev_state_change(dev);
 	}
 
+	ip6gre_tunnel_unlink(ign, t);
+	ip6gre_tnl_change(t, &p, !tb[IFLA_MTU]);
+	ip6gre_tunnel_link(ign, t);
 	return 0;
 }
 
-- 
2.4.2
