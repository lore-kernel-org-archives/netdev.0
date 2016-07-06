From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 06/26] netfilter: conntrack: align nf_conn on cacheline boundary
Date: Wed,  6 Jul 2016 16:23:48 +0200
Message-ID: <1467815048-2240-7-git-send-email-pablo@netfilter.org>
References: <1467815048-2240-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:34203 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754515AbcGFO0h (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Jul 2016 10:26:37 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id B0D7017DB6C
	for <netdev@vger.kernel.org>; Wed,  6 Jul 2016 16:26:36 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id A2885FAB54
	for <netdev@vger.kernel.org>; Wed,  6 Jul 2016 16:26:36 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id E5CE49EBCF
	for <netdev@vger.kernel.org>; Wed,  6 Jul 2016 16:26:31 +0200 (CEST)
In-Reply-To: <1467815048-2240-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

increases struct size by 32 bytes (288 -> 320), but it is the right thing,
else any attempt to (re-)arrange nf_conn members by cacheline won't work.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_core.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index db2312e..2903bb4 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -1731,7 +1731,7 @@ int nf_conntrack_init_start(void)
 
 	nf_conntrack_cachep = kmem_cache_create("nf_conntrack",
 						sizeof(struct nf_conn), 0,
-						SLAB_DESTROY_BY_RCU, NULL);
+						SLAB_DESTROY_BY_RCU | SLAB_HWCACHE_ALIGN, NULL);
 	if (!nf_conntrack_cachep)
 		goto err_cachep;
 
-- 
2.1.4
