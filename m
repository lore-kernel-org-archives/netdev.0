From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 3/9] netfilter: nf_nat: don't bug when mapping already exists
Date: Fri,  8 Sep 2017 19:45:42 +0200
Message-ID: <1504892748-1605-4-git-send-email-pablo@netfilter.org>
References: <1504892748-1605-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:54484 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756614AbdIHRqB (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 8 Sep 2017 13:46:01 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 4204D8D0507
        for <netdev@vger.kernel.org>; Fri,  8 Sep 2017 19:45:30 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 2C442B5027
        for <netdev@vger.kernel.org>; Fri,  8 Sep 2017 19:45:30 +0200 (CEST)
In-Reply-To: <1504892748-1605-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

It seems preferrable to limp along if we have a conflicting mapping,
its certainly better than a BUG().

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_nat_core.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/netfilter/nf_nat_core.c b/net/netfilter/nf_nat_core.c
index 40573aa6c133..dc3519cc7209 100644
--- a/net/netfilter/nf_nat_core.c
+++ b/net/netfilter/nf_nat_core.c
@@ -416,7 +416,9 @@ nf_nat_setup_info(struct nf_conn *ct,
 
 	WARN_ON(maniptype != NF_NAT_MANIP_SRC &&
 		maniptype != NF_NAT_MANIP_DST);
-	BUG_ON(nf_nat_initialized(ct, maniptype));
+
+	if (WARN_ON(nf_nat_initialized(ct, maniptype)))
+		return NF_DROP;
 
 	/* What we've got will look like inverse of reply. Normally
 	 * this is what is in the conntrack, except for prior
-- 
2.1.4
