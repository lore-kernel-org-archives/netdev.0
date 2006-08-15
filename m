From: akpm@osdl.org
Subject: [patch 12/13] net/decnet/: cleanups
Date: Mon, 14 Aug 2006 23:03:46 -0700
Message-ID: <200608150603.k7F63k5w012958@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@osdl.org, bunk@stusta.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:9109 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S965174AbWHOGHC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2006 02:07:02 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Adrian Bunk <bunk@stusta.de>

- make the following needlessly global functions static:
  - dn_fib.c: dn_fib_sync_down()
  - dn_fib.c: dn_fib_sync_up()
  - dn_rules.c: dn_fib_rule_action()
- remove the following unneeded prototype:
  - dn_fib.c: dn_cache_dump()

Signed-off-by: Adrian Bunk <bunk@stusta.de>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 include/net/dn_fib.h  |    3 ---
 net/decnet/dn_fib.c   |    9 +++++----
 net/decnet/dn_rules.c |    4 ++--
 3 files changed, 7 insertions(+), 9 deletions(-)

diff -puN include/net/dn_fib.h~net-decnet-cleanups include/net/dn_fib.h
--- a/include/net/dn_fib.h~net-decnet-cleanups
+++ a/include/net/dn_fib.h
@@ -131,9 +131,6 @@ extern __le16 dn_fib_get_attr16(struct r
 extern void dn_fib_flush(void);
 extern void dn_fib_select_multipath(const struct flowi *fl,
 					struct dn_fib_res *res);
-extern int dn_fib_sync_down(__le16 local, struct net_device *dev,
-				int force);
-extern int dn_fib_sync_up(struct net_device *dev);
 
 /*
  * dn_tables.c
diff -puN net/decnet/dn_fib.c~net-decnet-cleanups net/decnet/dn_fib.c
--- a/net/decnet/dn_fib.c~net-decnet-cleanups
+++ a/net/decnet/dn_fib.c
@@ -55,8 +55,6 @@
 
 #define endfor_nexthops(fi) }
 
-extern int dn_cache_dump(struct sk_buff *skb, struct netlink_callback *cb);
-
 static DEFINE_SPINLOCK(dn_fib_multipath_lock);
 static struct dn_fib_info *dn_fib_info_list;
 static DEFINE_SPINLOCK(dn_fib_info_lock);
@@ -80,6 +78,9 @@ static struct
 	[RTN_XRESOLVE] =    { .error = -EINVAL, .scope = RT_SCOPE_NOWHERE },
 };
 
+static int dn_fib_sync_down(__le16 local, struct net_device *dev, int force);
+static int dn_fib_sync_up(struct net_device *dev);
+
 void dn_fib_free_info(struct dn_fib_info *fi)
 {
 	if (fi->fib_dead == 0) {
@@ -651,7 +652,7 @@ static int dn_fib_dnaddr_event(struct no
 	return NOTIFY_DONE;
 }
 
-int dn_fib_sync_down(__le16 local, struct net_device *dev, int force)
+static int dn_fib_sync_down(__le16 local, struct net_device *dev, int force)
 {
         int ret = 0;
         int scope = RT_SCOPE_NOWHERE;
@@ -695,7 +696,7 @@ int dn_fib_sync_down(__le16 local, struc
 }
 
 
-int dn_fib_sync_up(struct net_device *dev)
+static int dn_fib_sync_up(struct net_device *dev)
 {
         int ret = 0;
 
diff -puN net/decnet/dn_rules.c~net-decnet-cleanups net/decnet/dn_rules.c
--- a/net/decnet/dn_rules.c~net-decnet-cleanups
+++ a/net/decnet/dn_rules.c
@@ -75,8 +75,8 @@ int dn_fib_lookup(struct flowi *flp, str
 	return err;
 }
 
-int dn_fib_rule_action(struct fib_rule *rule, struct flowi *flp, int flags,
-		       struct fib_lookup_arg *arg)
+static int dn_fib_rule_action(struct fib_rule *rule, struct flowi *flp,
+			      int flags, struct fib_lookup_arg *arg)
 {
 	int err = -EAGAIN;
 	struct dn_fib_table *tbl;
_
