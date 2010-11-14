From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH] netfilter: don't use atomic bit operation
Date: Sun, 14 Nov 2010 17:05:34 +0800
Message-ID: <1289725534-8439-1-git-send-email-xiaosuo@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	Changli Gao <xiaosuo@gmail.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

As we own ct, and the others can't see it until we confirm it, we don't
need to use atomic bit operation on ct->status.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
---
 include/net/netfilter/nf_nat_core.h |    4 ++--
 net/ipv4/netfilter/nf_nat_core.c    |    4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)
diff --git a/include/net/netfilter/nf_nat_core.h b/include/net/netfilter/nf_nat_core.h
index 33602ab..52ac1d8 100644
--- a/include/net/netfilter/nf_nat_core.h
+++ b/include/net/netfilter/nf_nat_core.h
@@ -21,9 +21,9 @@ static inline int nf_nat_initialized(struct nf_conn *ct,
 				     enum nf_nat_manip_type manip)
 {
 	if (manip == IP_NAT_MANIP_SRC)
-		return test_bit(IPS_SRC_NAT_DONE_BIT, &ct->status);
+		return IPS_SRC_NAT_DONE_BIT & ct->status;
 	else
-		return test_bit(IPS_DST_NAT_DONE_BIT, &ct->status);
+		return IPS_DST_NAT_DONE_BIT & ct->status;
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
