From: pablo@netfilter.org
Subject: [PATCH 03/25] netfilter: nf_conntrack: use this_cpu_inc()
Date: Tue,  8 May 2012 20:38:01 +0200
Message-ID: <1336502303-1722-4-git-send-email-pablo@netfilter.org>
References: <1336502303-1722-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, openbsc@lists.osmocom.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:39043 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755901Ab2EHSj2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 May 2012 14:39:28 -0400
In-Reply-To: <1336502303-1722-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

this_cpu_inc() is IRQ safe and faster than
local_bh_disable()/__this_cpu_inc()/local_bh_enable(), at least on x86.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Patrick McHardy <kaber@trash.net>
Cc: Christoph Lameter <cl@linux.com>
Cc: Tejun Heo <tj@kernel.org>
Reviewed-by: Christoph Lameter <cl@linux.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_conntrack.h |   10 ++--------
 1 file changed, 2 insertions(+), 8 deletions(-)

diff --git a/include/net/netfilter/nf_conntrack.h b/include/net/netfilter/nf_conntrack.h
index ab86036..cce7f6a 100644
--- a/include/net/netfilter/nf_conntrack.h
+++ b/include/net/netfilter/nf_conntrack.h
@@ -321,14 +321,8 @@ extern unsigned int nf_conntrack_max;
 extern unsigned int nf_conntrack_hash_rnd;
 void init_nf_conntrack_hash_rnd(void);
 
-#define NF_CT_STAT_INC(net, count)	\
-	__this_cpu_inc((net)->ct.stat->count)
-#define NF_CT_STAT_INC_ATOMIC(net, count)		\
-do {							\
-	local_bh_disable();				\
-	__this_cpu_inc((net)->ct.stat->count);		\
-	local_bh_enable();				\
-} while (0)
+#define NF_CT_STAT_INC(net, count)	  __this_cpu_inc((net)->ct.stat->count)
+#define NF_CT_STAT_INC_ATOMIC(net, count) this_cpu_inc((net)->ct.stat->count)
 
 #define MODULE_ALIAS_NFCT_HELPER(helper) \
         MODULE_ALIAS("nfct-helper-" helper)
-- 
1.7.9.5
