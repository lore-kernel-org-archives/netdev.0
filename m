From: kaber@trash.net
Subject: [PATCH 06/79] netfilter: nf_nat: don't use atomic bit operation
Date: Wed, 19 Jan 2011 20:14:06 +0100
Message-ID: <1295464519-21763-7-git-send-email-kaber@trash.net>
References: <1295464519-21763-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:51973 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753551Ab1ASTP0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jan 2011 14:15:26 -0500
In-Reply-To: <1295464519-21763-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Changli Gao <xiaosuo@gmail.com>

As we own the conntrack and the others can't see it until we confirm it,
we don't need to use atomic bit operation on ct->status.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 include/net/netfilter/nf_nat_core.h |    4 ++--
 net/ipv4/netfilter/nf_nat_core.c    |    4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/include/net/netfilter/nf_nat_core.h b/include/net/netfilter/nf_nat_core.h
index 33602ab..5aec85c 100644
--- a/include/net/netfilter/nf_nat_core.h
+++ b/include/net/netfilter/nf_nat_core.h
@@ -21,9 +21,9 @@ static inline int nf_nat_initialized(struct nf_conn *ct,
 				     enum nf_nat_manip_type manip)
 {
 	if (manip == IP_NAT_MANIP_SRC)
-		return test_bit(IPS_SRC_NAT_DONE_BIT, &ct->status);
+		return ct->status & IPS_SRC_NAT_DONE_BIT;
 	else
-		return test_bit(IPS_DST_NAT_DONE_BIT, &ct->status);
+		return ct->status & IPS_DST_NAT_DONE_BIT;
 }
 
 struct nlattr;
diff --git a/net/ipv4/netfilter/nf_nat_core.c b/net/ipv4/netfilter/nf_nat_core.c
index c04787c..ab877ac 100644
--- a/net/ipv4/netfilter/nf_nat_core.c
+++ b/net/ipv4/netfilter/nf_nat_core.c
@@ -323,9 +323,9 @@ nf_nat_setup_info(struct nf_conn *ct,
 
 	/* It's done. */
 	if (maniptype == IP_NAT_MANIP_DST)
-		set_bit(IPS_DST_NAT_DONE_BIT, &ct->status);
+		ct->status |= IPS_DST_NAT_DONE_BIT;
 	else
-		set_bit(IPS_SRC_NAT_DONE_BIT, &ct->status);
+		ct->status |= IPS_SRC_NAT_DONE_BIT;
 
 	return NF_ACCEPT;
 }
-- 
1.7.2.3

