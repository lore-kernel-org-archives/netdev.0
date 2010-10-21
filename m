From: kaber@trash.net
Subject: [PATCH 30/72] netfilter: unregister nf hooks, matches and targets in the reverse order
Date: Thu, 21 Oct 2010 17:19:17 +0200
Message-ID: <1287674399-31455-31-git-send-email-kaber@trash.net>
References: <1287674399-31455-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1287674399-31455-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Changli Gao <xiaosuo@gmail.com>

Since we register nf hooks, matches and targets in order, we'd better
unregister them in the reverse order.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/netfilter/core.c     |    6 ++----
 net/netfilter/x_tables.c |   12 ++++--------
 2 files changed, 6 insertions(+), 12 deletions(-)

diff --git a/net/netfilter/core.c b/net/netfilter/core.c
index 78b505d..8f014f2 100644
--- a/net/netfilter/core.c
+++ b/net/netfilter/core.c
@@ -105,10 +105,8 @@ EXPORT_SYMBOL(nf_register_hooks);
 
 void nf_unregister_hooks(struct nf_hook_ops *reg, unsigned int n)
 {
-	unsigned int i;
-
-	for (i = 0; i < n; i++)
-		nf_unregister_hook(&reg[i]);
+	while (n-- > 0)
+		nf_unregister_hook(&reg[n]);
 }
 EXPORT_SYMBOL(nf_unregister_hooks);
 
diff --git a/net/netfilter/x_tables.c b/net/netfilter/x_tables.c
index e34622f..8046350 100644
--- a/net/netfilter/x_tables.c
+++ b/net/netfilter/x_tables.c
@@ -116,10 +116,8 @@ EXPORT_SYMBOL(xt_register_targets);
 void
 xt_unregister_targets(struct xt_target *target, unsigned int n)
 {
-	unsigned int i;
-
-	for (i = 0; i < n; i++)
-		xt_unregister_target(&target[i]);
+	while (n-- > 0)
+		xt_unregister_target(&target[n]);
 }
 EXPORT_SYMBOL(xt_unregister_targets);
 
@@ -174,10 +172,8 @@ EXPORT_SYMBOL(xt_register_matches);
 void
 xt_unregister_matches(struct xt_match *match, unsigned int n)
 {
-	unsigned int i;
-
-	for (i = 0; i < n; i++)
-		xt_unregister_match(&match[i]);
+	while (n-- > 0)
+		xt_unregister_match(&match[n]);
 }
 EXPORT_SYMBOL(xt_unregister_matches);
 
-- 
1.7.1

