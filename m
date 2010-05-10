From: kaber@trash.net
Subject: [PATCH 79/84] netfilter: ip_tables: convert pr_devel() to pr_debug()
Date: Mon, 10 May 2010 22:18:50 +0200
Message-ID: <1273522735-24672-80-git-send-email-kaber@trash.net>
References: <1273522735-24672-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1273522735-24672-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>

We want to be able to use CONFIG_DYNAMIC_DEBUG in netfilter code, switch
the few existing pr_devel() calls to pr_debug().

Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/ipv4/netfilter/ip_tables.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
index bb5e0d9..3e6af10 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -363,7 +363,7 @@ ipt_do_table(struct sk_buff *skb,
 
 	e = get_entry(table_base, private->hook_entry[hook]);
 
-	pr_devel("Entering %s(hook %u); sp at %u (UF %p)\n",
+	pr_debug("Entering %s(hook %u); sp at %u (UF %p)\n",
 		 table->name, hook, origptr,
 		 get_entry(table_base, private->underflow[hook]));
 
@@ -409,11 +409,11 @@ ipt_do_table(struct sk_buff *skb,
 				if (*stackptr == 0) {
 					e = get_entry(table_base,
 					    private->underflow[hook]);
-					pr_devel("Underflow (this is normal) "
+					pr_debug("Underflow (this is normal) "
 						 "to %p\n", e);
 				} else {
 					e = jumpstack[--*stackptr];
-					pr_devel("Pulled %p out from pos %u\n",
+					pr_debug("Pulled %p out from pos %u\n",
 						 e, *stackptr);
 					e = ipt_next_entry(e);
 				}
@@ -426,7 +426,7 @@ ipt_do_table(struct sk_buff *skb,
 					break;
 				}
 				jumpstack[(*stackptr)++] = e;
-				pr_devel("Pushed %p into pos %u\n",
+				pr_debug("Pushed %p into pos %u\n",
 					 e, *stackptr - 1);
 			}
 
@@ -448,7 +448,7 @@ ipt_do_table(struct sk_buff *skb,
 			break;
 	} while (!hotdrop);
 	xt_info_rdunlock_bh();
-	pr_devel("Exiting %s; resetting sp from %u to %u\n",
+	pr_debug("Exiting %s; resetting sp from %u to %u\n",
 		 __func__, *stackptr, origptr);
 	*stackptr = origptr;
 #ifdef DEBUG_ALLOW_ALL
-- 
1.7.0.4

