From: kaber@trash.net
Subject: [PATCH 69/79] netfilter: nf_nat: fix conversion to non-atomic bit ops
Date: Wed, 19 Jan 2011 20:15:09 +0100
Message-ID: <1295464519-21763-70-git-send-email-kaber@trash.net>
References: <1295464519-21763-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:52012 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754012Ab1ASTPl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jan 2011 14:15:41 -0500
In-Reply-To: <1295464519-21763-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Changli Gao <xiaosuo@gmail.com>

My previous patch (netfilter: nf_nat: don't use atomic bit operation)
made a mistake when converting atomic_set to a normal bit 'or'.
IPS_*_BIT should be replaced with IPS_*.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
Cc: Tim Gardner <tim.gardner@canonical.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 include/net/netfilter/nf_nat_core.h |    4 ++--
 net/ipv4/netfilter/nf_nat_core.c    |    4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/include/net/netfilter/nf_nat_core.h b/include/net/netfilter/nf_nat_core.h
index 5aec85c..3dc7b98 100644
--- a/include/net/netfilter/nf_nat_core.h
+++ b/include/net/netfilter/nf_nat_core.h
@@ -21,9 +21,9 @@ static inline int nf_nat_initialized(struct nf_conn *ct,
 				     enum nf_nat_manip_type manip)
 {
 	if (manip == IP_NAT_MANIP_SRC)
-		return ct->status & IPS_SRC_NAT_DONE_BIT;
+		return ct->status & IPS_SRC_NAT_DONE;
 	else
-		return ct->status & IPS_DST_NAT_DONE_BIT;
+		return ct->status & IPS_DST_NAT_DONE;
 }
 
 struct nlattr;
diff --git a/net/ipv4/netfilter/nf_nat_core.c b/net/ipv4/netfilter/nf_nat_core.c
index 6972cee..3002c04 100644
--- a/net/ipv4/netfilter/nf_nat_core.c
+++ b/net/ipv4/netfilter/nf_nat_core.c
@@ -323,9 +323,9 @@ nf_nat_setup_info(struct nf_conn *ct,
 
 	/* It's done. */
 	if (maniptype == IP_NAT_MANIP_DST)
-		ct->status |= IPS_DST_NAT_DONE_BIT;
+		ct->status |= IPS_DST_NAT_DONE;
 	else
-		ct->status |= IPS_SRC_NAT_DONE_BIT;
+		ct->status |= IPS_SRC_NAT_DONE;
 
 	return NF_ACCEPT;
 }
-- 
1.7.2.3

