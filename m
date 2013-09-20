From: Joe Perches <joe@perches.com>
Subject: [PATCH 04/11] dst.h: Remove extern from function prototypes
Date: Fri, 20 Sep 2013 11:23:21 -0700
Message-ID: <904b1a9237750c84ba1f197f5b05c7d874bdb8e9.1379701322.git.joe@perches.com>
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
 include/net/dst.h | 25 ++++++++++++-------------
 1 file changed, 12 insertions(+), 13 deletions(-)

diff --git a/include/net/dst.h b/include/net/dst.h
index 3bc4865..211dcf1 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -106,7 +106,7 @@ struct dst_entry {
 	};
 };
 
-extern u32 *dst_cow_metrics_generic(struct dst_entry *dst, unsigned long old);
+u32 *dst_cow_metrics_generic(struct dst_entry *dst, unsigned long old);
 extern const u32 dst_default_metrics[];
 
 #define DST_METRICS_READ_ONLY	0x1UL
@@ -119,7 +119,7 @@ static inline bool dst_metrics_read_only(const struct dst_entry *dst)
 	return dst->_metrics & DST_METRICS_READ_ONLY;
 }
 
-extern void __dst_destroy_metrics_generic(struct dst_entry *dst, unsigned long old);
+void __dst_destroy_metrics_generic(struct dst_entry *dst, unsigned long old);
 
 static inline void dst_destroy_metrics_generic(struct dst_entry *dst)
 {
@@ -262,7 +262,7 @@ static inline struct dst_entry *dst_clone(struct dst_entry *dst)
 	return dst;
 }
 
-extern void dst_release(struct dst_entry *dst);
+void dst_release(struct dst_entry *dst);
 
 static inline void refdst_drop(unsigned long refdst)
 {
@@ -362,12 +362,11 @@ static inline struct dst_entry *skb_dst_pop(struct sk_buff *skb)
 	return child;
 }
 
-extern int dst_discard(struct sk_buff *skb);
-extern void *dst_alloc(struct dst_ops *ops, struct net_device *dev,
-		       int initial_ref, int initial_obsolete,
-		       unsigned short flags);
-extern void __dst_free(struct dst_entry *dst);
-extern struct dst_entry *dst_destroy(struct dst_entry *dst);
+int dst_discard(struct sk_buff *skb);
+void *dst_alloc(struct dst_ops *ops, struct net_device *dev, int initial_ref,
+		int initial_obsolete, unsigned short flags);
+void __dst_free(struct dst_entry *dst);
+struct dst_entry *dst_destroy(struct dst_entry *dst);
 
 static inline void dst_free(struct dst_entry *dst)
 {
@@ -463,7 +462,7 @@ static inline struct dst_entry *dst_check(struct dst_entry *dst, u32 cookie)
 	return dst;
 }
 
-extern void		dst_init(void);
+void dst_init(void);
 
 /* Flags for xfrm_lookup flags argument. */
 enum {
@@ -480,9 +479,9 @@ static inline struct dst_entry *xfrm_lookup(struct net *net,
 	return dst_orig;
 } 
 #else
-extern struct dst_entry *xfrm_lookup(struct net *net, struct dst_entry *dst_orig,
-				     const struct flowi *fl, struct sock *sk,
-				     int flags);
+struct dst_entry *xfrm_lookup(struct net *net, struct dst_entry *dst_orig,
+			      const struct flowi *fl, struct sock *sk,
+			      int flags);
 #endif
 
 #endif /* _NET_DST_H */
-- 
1.8.1.2.459.gbcd45b4.dirty
