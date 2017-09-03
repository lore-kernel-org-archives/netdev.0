From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 26/47] netfilter: use audit_log()
Date: Mon,  4 Sep 2017 00:40:14 +0200
Message-ID: <1504478435-13160-4-git-send-email-pablo@netfilter.org>
References: <1504478435-13160-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1504478435-13160-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Geliang Tang <geliangtang@gmail.com>

Use audit_log() instead of open-coding it.

Signed-off-by: Geliang Tang <geliangtang@gmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/bridge/netfilter/ebtables.c | 13 ++++---------
 net/netfilter/x_tables.c        | 14 ++++----------
 2 files changed, 8 insertions(+), 19 deletions(-)

diff --git a/net/bridge/netfilter/ebtables.c b/net/bridge/netfilter/ebtables.c
index 9c6e619f452b..54c7ef4e970e 100644
--- a/net/bridge/netfilter/ebtables.c
+++ b/net/bridge/netfilter/ebtables.c
@@ -1069,15 +1069,10 @@ static int do_replace_finish(struct net *net, struct ebt_replace *repl,
 
 #ifdef CONFIG_AUDIT
 	if (audit_enabled) {
-		struct audit_buffer *ab;
-
-		ab = audit_log_start(current->audit_context, GFP_KERNEL,
-				     AUDIT_NETFILTER_CFG);
-		if (ab) {
-			audit_log_format(ab, "table=%s family=%u entries=%u",
-					 repl->name, AF_BRIDGE, repl->nentries);
-			audit_log_end(ab);
-		}
+		audit_log(current->audit_context, GFP_KERNEL,
+			  AUDIT_NETFILTER_CFG,
+			  "table=%s family=%u entries=%u",
+			  repl->name, AF_BRIDGE, repl->nentries);
 	}
 #endif
 	return ret;
diff --git a/net/netfilter/x_tables.c b/net/netfilter/x_tables.c
index e1648238a9c9..c83a3b5e1c6c 100644
--- a/net/netfilter/x_tables.c
+++ b/net/netfilter/x_tables.c
@@ -1192,16 +1192,10 @@ xt_replace_table(struct xt_table *table,
 
 #ifdef CONFIG_AUDIT
 	if (audit_enabled) {
-		struct audit_buffer *ab;
-
-		ab = audit_log_start(current->audit_context, GFP_KERNEL,
-				     AUDIT_NETFILTER_CFG);
-		if (ab) {
-			audit_log_format(ab, "table=%s family=%u entries=%u",
-					 table->name, table->af,
-					 private->number);
-			audit_log_end(ab);
-		}
+		audit_log(current->audit_context, GFP_KERNEL,
+			  AUDIT_NETFILTER_CFG,
+			  "table=%s family=%u entries=%u",
+			  table->name, table->af, private->number);
 	}
 #endif
 
-- 
2.1.4


