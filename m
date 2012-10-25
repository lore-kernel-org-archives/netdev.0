From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: [PATCH] netfilter: remove silly double assignment
Date: Thu, 25 Oct 2012 15:59:27 +0100
Message-ID: <20121025145918.17642.22376.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lxorguk.ukuu.org.uk ([81.2.110.251]:53828 "EHLO
	lxorguk.ukuu.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756149Ab2JYO5w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Oct 2012 10:57:52 -0400
Received: from localhost.localdomain (earthlight.etchedpixels.co.uk [81.2.110.250])
	by lxorguk.ukuu.org.uk (8.14.5/8.14.1) with ESMTP id q9PFTn1u007176
	for <netdev@vger.kernel.org>; Thu, 25 Oct 2012 16:29:55 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alan Cox <alan@linux.intel.com>

I don't even want to think what the C spec says for this 8)

Signed-off-by: Alan Cox <alan@linux.intel.com>
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
index cc4c809..d8ce87a 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -592,7 +592,7 @@ ip_vs_nat_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 #if IS_ENABLED(CONFIG_NF_CONNTRACK)
 	if (cp->flags & IP_VS_CONN_F_SYNC && local) {
 		enum ip_conntrack_info ctinfo;
-		struct nf_conn *ct = ct = nf_ct_get(skb, &ctinfo);
+		struct nf_conn *ct = nf_ct_get(skb, &ctinfo);
 
 		if (ct && !nf_ct_is_untracked(ct)) {
 			IP_VS_DBG_RL_PKT(10, AF_INET, pp, skb, 0,
@@ -709,7 +709,7 @@ ip_vs_nat_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 #if IS_ENABLED(CONFIG_NF_CONNTRACK)
 	if (cp->flags & IP_VS_CONN_F_SYNC && local) {
 		enum ip_conntrack_info ctinfo;
-		struct nf_conn *ct = ct = nf_ct_get(skb, &ctinfo);
+		struct nf_conn *ct = nf_ct_get(skb, &ctinfo);
 
 		if (ct && !nf_ct_is_untracked(ct)) {
 			IP_VS_DBG_RL_PKT(10, AF_INET6, pp, skb, 0,
@@ -1227,7 +1227,7 @@ ip_vs_icmp_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 #if IS_ENABLED(CONFIG_NF_CONNTRACK)
 	if (cp->flags & IP_VS_CONN_F_SYNC && local) {
 		enum ip_conntrack_info ctinfo;
-		struct nf_conn *ct = ct = nf_ct_get(skb, &ctinfo);
+		struct nf_conn *ct = nf_ct_get(skb, &ctinfo);
 
 		if (ct && !nf_ct_is_untracked(ct)) {
 			IP_VS_DBG(10, "%s(): "
@@ -1347,7 +1347,7 @@ ip_vs_icmp_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 #if IS_ENABLED(CONFIG_NF_CONNTRACK)
 	if (cp->flags & IP_VS_CONN_F_SYNC && local) {
 		enum ip_conntrack_info ctinfo;
-		struct nf_conn *ct = ct = nf_ct_get(skb, &ctinfo);
+		struct nf_conn *ct = nf_ct_get(skb, &ctinfo);
 
 		if (ct && !nf_ct_is_untracked(ct)) {
 			IP_VS_DBG(10, "%s(): "
