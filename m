From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 27/29] netfilter: remove __nf_ct_kill_acct helper
Date: Mon,  5 Sep 2016 12:58:42 +0200
Message-ID: <1473073124-5015-28-git-send-email-pablo@netfilter.org>
References: <1473073124-5015-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:35204 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933583AbcIEK7U (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 5 Sep 2016 06:59:20 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 216442EFEB9
        for <netdev@vger.kernel.org>; Mon,  5 Sep 2016 12:59:19 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 00E2D1150D1
        for <netdev@vger.kernel.org>; Mon,  5 Sep 2016 12:59:19 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id B76481150D3
        for <netdev@vger.kernel.org>; Mon,  5 Sep 2016 12:59:16 +0200 (CEST)
In-Reply-To: <1473073124-5015-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

After timer removal this just calls nf_ct_delete so remove the __ prefix
version and make nf_ct_kill a shorthand for nf_ct_delete.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_conntrack.h | 13 +++----------
 net/netfilter/nf_conntrack_core.c    | 12 +++++-------
 2 files changed, 8 insertions(+), 17 deletions(-)

diff --git a/include/net/netfilter/nf_conntrack.h b/include/net/netfilter/nf_conntrack.h
index 7277751..5041805 100644
--- a/include/net/netfilter/nf_conntrack.h
+++ b/include/net/netfilter/nf_conntrack.h
@@ -219,21 +219,14 @@ static inline void nf_ct_refresh(struct nf_conn *ct,
 	__nf_ct_refresh_acct(ct, 0, skb, extra_jiffies, 0);
 }
 
-bool __nf_ct_kill_acct(struct nf_conn *ct, enum ip_conntrack_info ctinfo,
-		       const struct sk_buff *skb, int do_acct);
-
 /* kill conntrack and do accounting */
-static inline bool nf_ct_kill_acct(struct nf_conn *ct,
-				   enum ip_conntrack_info ctinfo,
-				   const struct sk_buff *skb)
-{
-	return __nf_ct_kill_acct(ct, ctinfo, skb, 1);
-}
+bool nf_ct_kill_acct(struct nf_conn *ct, enum ip_conntrack_info ctinfo,
+		     const struct sk_buff *skb);
 
 /* kill conntrack without accounting */
 static inline bool nf_ct_kill(struct nf_conn *ct)
 {
-	return __nf_ct_kill_acct(ct, 0, NULL, 0);
+	return nf_ct_delete(ct, 0, 0);
 }
 
 /* These are for NAT.  Icky. */
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index 7c66ce40..ac1db40 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -1430,17 +1430,15 @@ acct:
 }
 EXPORT_SYMBOL_GPL(__nf_ct_refresh_acct);
 
-bool __nf_ct_kill_acct(struct nf_conn *ct,
-		       enum ip_conntrack_info ctinfo,
-		       const struct sk_buff *skb,
-		       int do_acct)
+bool nf_ct_kill_acct(struct nf_conn *ct,
+		     enum ip_conntrack_info ctinfo,
+		     const struct sk_buff *skb)
 {
-	if (do_acct)
-		nf_ct_acct_update(ct, ctinfo, skb->len);
+	nf_ct_acct_update(ct, ctinfo, skb->len);
 
 	return nf_ct_delete(ct, 0, 0);
 }
-EXPORT_SYMBOL_GPL(__nf_ct_kill_acct);
+EXPORT_SYMBOL_GPL(nf_ct_kill_acct);
 
 #if IS_ENABLED(CONFIG_NF_CT_NETLINK)
 
-- 
2.1.4
