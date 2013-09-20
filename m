From: Joe Perches <joe@perches.com>
Subject: [PATCH 06/11] fib_rules.h: Remove extern from function prototypes
Date: Fri, 20 Sep 2013 11:23:23 -0700
Message-ID: <10bbc6049fe0a1f2bb270e97cc4430226686dd39.1379701322.git.joe@perches.com>
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
 include/net/fib_rules.h | 17 ++++++++---------
 1 file changed, 8 insertions(+), 9 deletions(-)

diff --git a/include/net/fib_rules.h b/include/net/fib_rules.h
index 4b2b557..e584de1 100644
--- a/include/net/fib_rules.h
+++ b/include/net/fib_rules.h
@@ -115,14 +115,13 @@ static inline u32 frh_get_table(struct fib_rule_hdr *frh, struct nlattr **nla)
 	return frh->table;
 }
 
-extern struct fib_rules_ops *fib_rules_register(const struct fib_rules_ops *, struct net *);
-extern void fib_rules_unregister(struct fib_rules_ops *);
+struct fib_rules_ops *fib_rules_register(const struct fib_rules_ops *,
+					 struct net *);
+void fib_rules_unregister(struct fib_rules_ops *);
 
-extern int			fib_rules_lookup(struct fib_rules_ops *,
-						 struct flowi *, int flags,
-						 struct fib_lookup_arg *);
-extern int			fib_default_rule_add(struct fib_rules_ops *,
-						     u32 pref, u32 table,
-						     u32 flags);
-extern u32			fib_default_rule_pref(struct fib_rules_ops *ops);
+int fib_rules_lookup(struct fib_rules_ops *, struct flowi *, int flags,
+		     struct fib_lookup_arg *);
+int fib_default_rule_add(struct fib_rules_ops *, u32 pref, u32 table,
+			 u32 flags);
+u32 fib_default_rule_pref(struct fib_rules_ops *ops);
 #endif
-- 
1.8.1.2.459.gbcd45b4.dirty
