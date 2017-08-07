From: Geliang Tang <geliangtang@gmail.com>
Subject: [PATCH] netfilter: xtables: use audit_log()
Date: Mon,  7 Aug 2017 21:44:26 +0800
Message-ID: <c091f8c337fe4316ffcfb121da8b24b6633fa679.1502099123.git.geliangtang@gmail.com>
References: <5f901760510d0dc6e6e971d4136c8d2d4e0a13fd.1502103408.git.geliangtang@gmail.com>
Cc: Geliang Tang <geliangtang@gmail.com>,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        Florian Westphal <fw@strlen.de>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5f901760510d0dc6e6e971d4136c8d2d4e0a13fd.1502103408.git.geliangtang@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use audit_log() instead of open-coding it.

Signed-off-by: Geliang Tang <geliangtang@gmail.com>
---
 net/netfilter/x_tables.c | 14 ++++----------
 1 file changed, 4 insertions(+), 10 deletions(-)

diff --git a/net/netfilter/x_tables.c b/net/netfilter/x_tables.c
index e164823..c83a3b5 100644
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
2.9.3
