From: pablo@netfilter.org
Subject: [PATCH 1/4] ipvs: remove silly double assignment
Date: Fri, 16 Nov 2012 13:40:50 +0100
Message-ID: <1353069653-3231-2-git-send-email-pablo@netfilter.org>
References: <1353069653-3231-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:44480 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750817Ab2KPMlE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Nov 2012 07:41:04 -0500
In-Reply-To: <1353069653-3231-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alan Cox <alan@linux.intel.com>

I don't even want to think what the C spec says for this 8)

Signed-off-by: Alan Cox <alan@linux.intel.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/ipvs/ip_vs_nfct.c |    2 +-
 net/netfilter/ipvs/ip_vs_xmit.c |    8 ++++----
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_nfct.c b/net/netfilter/ipvs/ip_vs_nfct.c
index 022e77e..c8beafd 100644
--- a/net/netfilter/ipvs/ip_vs_nfct.c
+++ b/net/netfilter/ipvs/ip_vs_nfct.c
@@ -82,7 +82,7 @@ void
 ip_vs_update_conntrack(struct sk_buff *skb, struct ip_vs_conn *cp, int outin)
 {
 	enum ip_conntrack_info ctinfo;
-	struct nf_conn *ct = ct = nf_ct_get(skb, &ctinfo);
+	struct nf_conn *ct = nf_ct_get(skb, &ctinfo);
 	struct nf_conntrack_tuple new_tuple;
 
 	if (ct == NULL || nf_ct_is_confirmed(ct) || nf_ct_is_untracked(ct) ||
diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index 12008b4..ee6b7a9 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -594,7 +594,7 @@ ip_vs_nat_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 #if IS_ENABLED(CONFIG_NF_CONNTRACK)
 	if (cp->flags & IP_VS_CONN_F_SYNC && local) {
 		enum ip_conntrack_info ctinfo;
-		struct nf_conn *ct = ct = nf_ct_get(skb, &ctinfo);
+		struct nf_conn *ct = nf_ct_get(skb, &ctinfo);
 
 		if (ct && !nf_ct_is_untracked(ct)) {
 			IP_VS_DBG_RL_PKT(10, AF_INET, pp, skb, 0,
@@ -710,7 +710,7 @@ ip_vs_nat_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 #if IS_ENABLED(CONFIG_NF_CONNTRACK)
 	if (cp->flags & IP_VS_CONN_F_SYNC && local) {
 		enum ip_conntrack_info ctinfo;
-		struct nf_conn *ct = ct = nf_ct_get(skb, &ctinfo);
+		struct nf_conn *ct = nf_ct_get(skb, &ctinfo);
 
 		if (ct && !nf_ct_is_untracked(ct)) {
 			IP_VS_DBG_RL_PKT(10, AF_INET6, pp, skb, 0,
@@ -1235,7 +1235,7 @@ ip_vs_icmp_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 #if IS_ENABLED(CONFIG_NF_CONNTRACK)
 	if (cp->flags & IP_VS_CONN_F_SYNC && local) {
 		enum ip_conntrack_info ctinfo;
-		struct nf_conn *ct = ct = nf_ct_get(skb, &ctinfo);
+		struct nf_conn *ct = nf_ct_get(skb, &ctinfo);
 
 		if (ct && !nf_ct_is_untracked(ct)) {
 			IP_VS_DBG(10, "%s(): "
@@ -1356,7 +1356,7 @@ ip_vs_icmp_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 #if IS_ENABLED(CONFIG_NF_CONNTRACK)
 	if (cp->flags & IP_VS_CONN_F_SYNC && local) {
 		enum ip_conntrack_info ctinfo;
-		struct nf_conn *ct = ct = nf_ct_get(skb, &ctinfo);
+		struct nf_conn *ct = nf_ct_get(skb, &ctinfo);
 
 		if (ct && !nf_ct_is_untracked(ct)) {
 			IP_VS_DBG(10, "%s(): "
-- 
1.7.10.4
