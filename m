From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 1/3] netfilter: conntrack: init all_locks to avoid debug warning
Date: Mon,  9 May 2016 21:52:01 +0200
Message-ID: <1462823523-6682-2-git-send-email-pablo@netfilter.org>
References: <1462823523-6682-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:53583 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750951AbcEITwN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 May 2016 15:52:13 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id B8BDEEAA6F
	for <netdev@vger.kernel.org>; Mon,  9 May 2016 21:52:11 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id A5748134720
	for <netdev@vger.kernel.org>; Mon,  9 May 2016 21:52:11 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 8CABBFAB48
	for <netdev@vger.kernel.org>; Mon,  9 May 2016 21:52:08 +0200 (CEST)
In-Reply-To: <1462823523-6682-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

Else we get 'BUG: spinlock bad magic on CPU#' on resize when
spin lock debugging is enabled.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_core.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index afde5f5..895d11d 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -66,7 +66,7 @@ EXPORT_SYMBOL_GPL(nf_conntrack_locks);
 __cacheline_aligned_in_smp DEFINE_SPINLOCK(nf_conntrack_expect_lock);
 EXPORT_SYMBOL_GPL(nf_conntrack_expect_lock);
 
-static __read_mostly spinlock_t nf_conntrack_locks_all_lock;
+static __read_mostly DEFINE_SPINLOCK(nf_conntrack_locks_all_lock);
 static __read_mostly bool nf_conntrack_locks_all;
 
 void nf_conntrack_lock(spinlock_t *lock) __acquires(lock)
-- 
2.1.4
