From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 12/13] netfilter: conntrack: restart gc immediately if GC_MAX_EVICTS is reached
Date: Fri, 21 Oct 2016 12:12:22 +0200
Message-ID: <1477044743-18948-13-git-send-email-pablo@netfilter.org>
References: <1477044743-18948-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:36318 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754916AbcJUKMr (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 21 Oct 2016 06:12:47 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 969F026E20
        for <netdev@vger.kernel.org>; Fri, 21 Oct 2016 12:12:46 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 86B10DA84E
        for <netdev@vger.kernel.org>; Fri, 21 Oct 2016 12:12:46 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 16F0CDA858
        for <netdev@vger.kernel.org>; Fri, 21 Oct 2016 12:12:44 +0200 (CEST)
In-Reply-To: <1477044743-18948-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>

When the maximum evictions number is reached, do not wait 5 seconds before
the next run.

CC: Florian Westphal <fw@strlen.de>
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Acked-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_core.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index ba6a1d421222..df2f5a3901df 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -983,7 +983,7 @@ static void gc_worker(struct work_struct *work)
 		return;
 
 	ratio = scanned ? expired_count * 100 / scanned : 0;
-	if (ratio >= 90)
+	if (ratio >= 90 || expired_count == GC_MAX_EVICTS)
 		next_run = 0;
 
 	gc_work->last_bucket = i;
-- 
2.1.4
