From: kaber@trash.net
Subject: [PATCH 20/37] IPVS: Add sysctl_expire_nodest_conn()
Date: Tue, 15 Mar 2011 20:44:00 +0100
Message-ID: <1300218257-26953-21-git-send-email-kaber@trash.net>
References: <1300218257-26953-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:49424 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757552Ab1COToa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Mar 2011 15:44:30 -0400
In-Reply-To: <1300218257-26953-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Horman <horms@verge.net.au>

In preparation for not including sysctl_expire_nodest_conn in
struct netns_ipvs when CONFIG_SYCTL is not defined.

Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_core.c |    8 +++++++-
 1 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 6a0053d..d418bc6 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -613,10 +613,16 @@ static int sysctl_nat_icmp_send(struct net *net)
 	return ipvs->sysctl_nat_icmp_send;
 }
 
+static int sysctl_expire_nodest_conn(struct netns_ipvs *ipvs)
+{
+	return ipvs->sysctl_expire_nodest_conn;
+}
+
 #else
 
 static int sysctl_snat_reroute(struct sk_buff *skb) { return 0; }
 static int sysctl_nat_icmp_send(struct net *net) { return 0; }
+static int sysctl_expire_nodest_conn(struct netns_ipvs *ipvs) { return 0; }
 
 #endif
 
@@ -1583,7 +1589,7 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *skb, int af)
 	if (cp->dest && !(cp->dest->flags & IP_VS_DEST_F_AVAILABLE)) {
 		/* the destination server is not available */
 
-		if (ipvs->sysctl_expire_nodest_conn) {
+		if (sysctl_expire_nodest_conn(ipvs)) {
 			/* try to expire the connection immediately */
 			ip_vs_conn_expire_now(cp);
 		}
-- 
1.7.2.3

