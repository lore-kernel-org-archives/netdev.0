From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 1/7] netfilter: conntrack: destroy kmemcache on module removal
Date: Fri, 17 Jun 2016 20:25:13 +0200
Message-ID: <1466187919-12800-2-git-send-email-pablo@netfilter.org>
References: <1466187919-12800-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:44629 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750751AbcFQSZl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Jun 2016 14:25:41 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id 595D2E5A58
	for <netdev@vger.kernel.org>; Fri, 17 Jun 2016 20:25:40 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 489529EBBA
	for <netdev@vger.kernel.org>; Fri, 17 Jun 2016 20:25:40 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 6B2D89EBA4
	for <netdev@vger.kernel.org>; Fri, 17 Jun 2016 20:25:36 +0200 (CEST)
In-Reply-To: <1466187919-12800-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

I forgot to move the kmem_cache_destroy into the exit path.

Fixes: 0c5366b3a8c7 ("netfilter: conntrack: use single slab cache)
Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_core.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index db2312e..f204274 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -1544,6 +1544,8 @@ void nf_conntrack_cleanup_end(void)
 	nf_conntrack_tstamp_fini();
 	nf_conntrack_acct_fini();
 	nf_conntrack_expect_fini();
+
+	kmem_cache_destroy(nf_conntrack_cachep);
 }
 
 /*
-- 
2.1.4
