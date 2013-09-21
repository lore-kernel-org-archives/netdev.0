From: Joe Perches <joe@perches.com>
Subject: [PATCH 08/12] net_namespace.h: Remove extern from function prototypes
Date: Sat, 21 Sep 2013 10:22:48 -0700
Message-ID: <06e3cfbaf8d24024d683f7ce0ddf94a52193a0b7.1379783996.git.joe@perches.com>
References: <005f102eb1322058f9e797a7268ae8be01ecfaae.1379783995.git.joe@perches.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <005f102eb1322058f9e797a7268ae8be01ecfaae.1379783995.git.joe@perches.com>
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
 include/net/net_namespace.h | 28 ++++++++++++++--------------
 1 file changed, 14 insertions(+), 14 deletions(-)

diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
index 1313456..38c2afb 100644
--- a/include/net/net_namespace.h
+++ b/include/net/net_namespace.h
@@ -136,8 +136,8 @@ struct net {
 extern struct net init_net;
 
 #ifdef CONFIG_NET_NS
-extern struct net *copy_net_ns(unsigned long flags,
-	struct user_namespace *user_ns, struct net *old_net);
+struct net *copy_net_ns(unsigned long flags, struct user_namespace *user_ns,
+			struct net *old_net);
 
 #else /* CONFIG_NET_NS */
 #include <linux/sched.h>
@@ -154,11 +154,11 @@ static inline struct net *copy_net_ns(unsigned long flags,
 
 extern struct list_head net_namespace_list;
 
-extern struct net *get_net_ns_by_pid(pid_t pid);
-extern struct net *get_net_ns_by_fd(int pid);
+struct net *get_net_ns_by_pid(pid_t pid);
+struct net *get_net_ns_by_fd(int pid);
 
 #ifdef CONFIG_NET_NS
-extern void __put_net(struct net *net);
+void __put_net(struct net *net);
 
 static inline struct net *get_net(struct net *net)
 {
@@ -190,7 +190,7 @@ int net_eq(const struct net *net1, const struct net *net2)
 	return net1 == net2;
 }
 
-extern void net_drop_ns(void *);
+void net_drop_ns(void *);
 
 #else
 
@@ -307,19 +307,19 @@ struct pernet_operations {
  * device which caused kernel oops, and panics during network
  * namespace cleanup.   So please don't get this wrong.
  */
-extern int register_pernet_subsys(struct pernet_operations *);
-extern void unregister_pernet_subsys(struct pernet_operations *);
-extern int register_pernet_device(struct pernet_operations *);
-extern void unregister_pernet_device(struct pernet_operations *);
+int register_pernet_subsys(struct pernet_operations *);
+void unregister_pernet_subsys(struct pernet_operations *);
+int register_pernet_device(struct pernet_operations *);
+void unregister_pernet_device(struct pernet_operations *);
 
 struct ctl_table;
 struct ctl_table_header;
 
 #ifdef CONFIG_SYSCTL
-extern int net_sysctl_init(void);
-extern struct ctl_table_header *register_net_sysctl(struct net *net,
-	const char *path, struct ctl_table *table);
-extern void unregister_net_sysctl_table(struct ctl_table_header *header);
+int net_sysctl_init(void);
+struct ctl_table_header *register_net_sysctl(struct net *net, const char *path,
+					     struct ctl_table *table);
+void unregister_net_sysctl_table(struct ctl_table_header *header);
 #else
 static inline int net_sysctl_init(void) { return 0; }
 static inline struct ctl_table_header *register_net_sysctl(struct net *net,
-- 
1.8.1.2.459.gbcd45b4.dirty
