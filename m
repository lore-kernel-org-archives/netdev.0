From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next v2 1/3] ipip: fix sparse warnings in ipip_netlink_parms()
Date: Thu, 15 Nov 2012 15:06:40 +0100
Message-ID: <1352988402-16950-1-git-send-email-nicolas.dichtel@6wind.com>
References: <1352985602.4497.31.camel@edumazet-glaptop>
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	fengguang.wu@intel.com, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:36657 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1767838Ab2KOOGc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Nov 2012 09:06:32 -0500
In-Reply-To: <1352985602.4497.31.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change fixes two sparse warnings triggered by casting the ip addresses
from netlink messages in an u32 instead of be32. This change corrects that
in order to resolve the sparse warnings.

Reported-by: Fengguang Wu <fengguang.wu@intel.com>
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
v2: enhance commit log and add "Reported-by" line

 net/ipv4/ipip.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
index 64686e1..c26c171 100644
--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -864,10 +864,10 @@ static void ipip_netlink_parms(struct nlattr *data[],
 		parms->link = nla_get_u32(data[IFLA_IPTUN_LINK]);
 
 	if (data[IFLA_IPTUN_LOCAL])
-		parms->iph.saddr = nla_get_u32(data[IFLA_IPTUN_LOCAL]);
+		parms->iph.saddr = nla_get_be32(data[IFLA_IPTUN_LOCAL]);
 
 	if (data[IFLA_IPTUN_REMOTE])
-		parms->iph.daddr = nla_get_u32(data[IFLA_IPTUN_REMOTE]);
+		parms->iph.daddr = nla_get_be32(data[IFLA_IPTUN_REMOTE]);
 
 	if (data[IFLA_IPTUN_TTL]) {
 		parms->iph.ttl = nla_get_u8(data[IFLA_IPTUN_TTL]);
-- 
1.7.12
