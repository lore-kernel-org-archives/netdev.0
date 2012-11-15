From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next v2 3/3] ip6tnl: fix sparse warnings in ip6_tnl_netlink_parms()
Date: Thu, 15 Nov 2012 15:06:42 +0100
Message-ID: <1352988402-16950-3-git-send-email-nicolas.dichtel@6wind.com>
References: <1352985602.4497.31.camel@edumazet-glaptop>
 <1352988402-16950-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	fengguang.wu@intel.com, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:36659 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1767800Ab2KOOGb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Nov 2012 09:06:31 -0500
In-Reply-To: <1352988402-16950-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change fixes a sparse warning triggered by casting the flowinfo from
netlink messages in an u32 instead of be32. This change corrects that in order
to resolve the sparse warning.

Reported-by: Fengguang Wu <fengguang.wu@intel.com>
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
v2: enhance commit log and add "Reported-by" line

 net/ipv6/ip6_tunnel.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index ab4d056..bf3a549 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -1568,7 +1568,7 @@ static void ip6_tnl_netlink_parms(struct nlattr *data[],
 		parms->encap_limit = nla_get_u8(data[IFLA_IPTUN_ENCAP_LIMIT]);
 
 	if (data[IFLA_IPTUN_FLOWINFO])
-		parms->flowinfo = nla_get_u32(data[IFLA_IPTUN_FLOWINFO]);
+		parms->flowinfo = nla_get_be32(data[IFLA_IPTUN_FLOWINFO]);
 
 	if (data[IFLA_IPTUN_FLAGS])
 		parms->flags = nla_get_u32(data[IFLA_IPTUN_FLAGS]);
-- 
1.7.12
