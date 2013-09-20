From: Joe Perches <joe@perches.com>
Subject: [PATCH 07/11] flow.h/flow_keys.h: Remove extern from function prototypes
Date: Fri, 20 Sep 2013 11:23:24 -0700
Message-ID: <e353e88cf7202a9977a6caada9123dc57d968ee6.1379701322.git.joe@perches.com>
References: <597c1b62607f823af60dc4a99d59373dddfb7837.1379701322.git.joe@perches.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <597c1b62607f823af60dc4a99d59373dddfb7837.1379701322.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There are a mix of function prototypes with and without extern
in the kernel sources.  Standardize on not using extern for
function prototypes.

Function prototypes don't need to be written with extern.
extern is assumed by the compiler.  Its use is as unnecessary as
using auto to declare automatic/local variables in a block.

Signed-off-by: Joe Perches <joe@perches.com>
---
 include/net/flow.h      | 11 ++++++-----
 include/net/flow_keys.h |  2 +-
 2 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/include/net/flow.h b/include/net/flow.h
index 628e11b..65ce471 100644
--- a/include/net/flow.h
+++ b/include/net/flow.h
@@ -215,12 +215,13 @@ typedef struct flow_cache_object *(*flow_resolve_t)(
 		struct net *net, const struct flowi *key, u16 family,
 		u8 dir, struct flow_cache_object *oldobj, void *ctx);
 
-extern struct flow_cache_object *flow_cache_lookup(
-		struct net *net, const struct flowi *key, u16 family,
-		u8 dir, flow_resolve_t resolver, void *ctx);
+struct flow_cache_object *flow_cache_lookup(struct net *net,
+					    const struct flowi *key, u16 family,
+					    u8 dir, flow_resolve_t resolver,
+					    void *ctx);
 
-extern void flow_cache_flush(void);
-extern void flow_cache_flush_deferred(void);
+void flow_cache_flush(void);
+void flow_cache_flush_deferred(void);
 extern atomic_t flow_cache_genid;
 
 #endif
diff --git a/include/net/flow_keys.h b/include/net/flow_keys.h
index bb8271d..ac2439d 100644
--- a/include/net/flow_keys.h
+++ b/include/net/flow_keys.h
@@ -13,5 +13,5 @@ struct flow_keys {
 	u8 ip_proto;
 };
 
-extern bool skb_flow_dissect(const struct sk_buff *skb, struct flow_keys *flow);
+bool skb_flow_dissect(const struct sk_buff *skb, struct flow_keys *flow);
 #endif
-- 
1.8.1.2.459.gbcd45b4.dirty
