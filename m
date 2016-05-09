From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 24/36] netfilter: conntrack: __nf_ct_l4proto_find() always returns valid pointer
Date: Mon,  9 May 2016 20:46:42 +0200
Message-ID: <1462819614-5402-25-git-send-email-pablo@netfilter.org>
References: <1462819614-5402-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:45770 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752714AbcEISr2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 May 2016 14:47:28 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id 49A17E8E92
	for <netdev@vger.kernel.org>; Mon,  9 May 2016 20:47:27 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 3BFA3134704
	for <netdev@vger.kernel.org>; Mon,  9 May 2016 20:47:27 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 30EFB134706
	for <netdev@vger.kernel.org>; Mon,  9 May 2016 20:47:25 +0200 (CEST)
In-Reply-To: <1462819614-5402-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove unnecessary check for non-nul pointer in destroy_conntrack()
given that __nf_ct_l4proto_find() returns the generic protocol tracker
if the protocol is not supported.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_core.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index e3787cf..f72ede1 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -363,7 +363,7 @@ destroy_conntrack(struct nf_conntrack *nfct)
 	}
 	rcu_read_lock();
 	l4proto = __nf_ct_l4proto_find(nf_ct_l3num(ct), nf_ct_protonum(ct));
-	if (l4proto && l4proto->destroy)
+	if (l4proto->destroy)
 		l4proto->destroy(ct);
 
 	rcu_read_unlock();
-- 
2.1.4
