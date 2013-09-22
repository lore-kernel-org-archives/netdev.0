From: Joe Perches <joe@perches.com>
Subject: [PATCH 08/12] rtnetlink.h: Remove extern from function prototypes
Date: Sun, 22 Sep 2013 10:32:23 -0700
Message-ID: <940639b0a395925321149293dceec59fe91c724e.1379870986.git.joe@perches.com>
References: <b692aba58032f629907ea2d462c99b87906645ca.1379870986.git.joe@perches.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <b692aba58032f629907ea2d462c99b87906645ca.1379870986.git.joe@perches.com>
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
 include/net/rtnetlink.h | 40 +++++++++++++++++++---------------------
 1 file changed, 19 insertions(+), 21 deletions(-)

diff --git a/include/net/rtnetlink.h b/include/net/rtnetlink.h
index 7026648..bb13a18 100644
--- a/include/net/rtnetlink.h
+++ b/include/net/rtnetlink.h
@@ -8,14 +8,12 @@ typedef int (*rtnl_doit_func)(struct sk_buff *, struct nlmsghdr *);
 typedef int (*rtnl_dumpit_func)(struct sk_buff *, struct netlink_callback *);
 typedef u16 (*rtnl_calcit_func)(struct sk_buff *, struct nlmsghdr *);
 
-extern int	__rtnl_register(int protocol, int msgtype,
-				rtnl_doit_func, rtnl_dumpit_func,
-				rtnl_calcit_func);
-extern void	rtnl_register(int protocol, int msgtype,
-			      rtnl_doit_func, rtnl_dumpit_func,
-			      rtnl_calcit_func);
-extern int	rtnl_unregister(int protocol, int msgtype);
-extern void	rtnl_unregister_all(int protocol);
+int __rtnl_register(int protocol, int msgtype,
+		    rtnl_doit_func, rtnl_dumpit_func, rtnl_calcit_func);
+void rtnl_register(int protocol, int msgtype,
+		   rtnl_doit_func, rtnl_dumpit_func, rtnl_calcit_func);
+int rtnl_unregister(int protocol, int msgtype);
+void rtnl_unregister_all(int protocol);
 
 static inline int rtnl_msg_family(const struct nlmsghdr *nlh)
 {
@@ -83,11 +81,11 @@ struct rtnl_link_ops {
 	unsigned int		(*get_num_rx_queues)(void);
 };
 
-extern int	__rtnl_link_register(struct rtnl_link_ops *ops);
-extern void	__rtnl_link_unregister(struct rtnl_link_ops *ops);
+int __rtnl_link_register(struct rtnl_link_ops *ops);
+void __rtnl_link_unregister(struct rtnl_link_ops *ops);
 
-extern int	rtnl_link_register(struct rtnl_link_ops *ops);
-extern void	rtnl_link_unregister(struct rtnl_link_ops *ops);
+int rtnl_link_register(struct rtnl_link_ops *ops);
+void rtnl_link_unregister(struct rtnl_link_ops *ops);
 
 /**
  * 	struct rtnl_af_ops - rtnetlink address family operations
@@ -117,18 +115,18 @@ struct rtnl_af_ops {
 					       const struct nlattr *attr);
 };
 
-extern int	__rtnl_af_register(struct rtnl_af_ops *ops);
-extern void	__rtnl_af_unregister(struct rtnl_af_ops *ops);
+int __rtnl_af_register(struct rtnl_af_ops *ops);
+void __rtnl_af_unregister(struct rtnl_af_ops *ops);
 
-extern int	rtnl_af_register(struct rtnl_af_ops *ops);
-extern void	rtnl_af_unregister(struct rtnl_af_ops *ops);
+int rtnl_af_register(struct rtnl_af_ops *ops);
+void rtnl_af_unregister(struct rtnl_af_ops *ops);
 
+struct net *rtnl_link_get_net(struct net *src_net, struct nlattr *tb[]);
+struct net_device *rtnl_create_link(struct net *net, char *ifname,
+				    const struct rtnl_link_ops *ops,
+				    struct nlattr *tb[]);
+int rtnl_configure_link(struct net_device *dev, const struct ifinfomsg *ifm);
 
-extern struct net *rtnl_link_get_net(struct net *src_net, struct nlattr *tb[]);
-extern struct net_device *rtnl_create_link(struct net *net,
-	char *ifname, const struct rtnl_link_ops *ops, struct nlattr *tb[]);
-extern int rtnl_configure_link(struct net_device *dev,
-			       const struct ifinfomsg *ifm);
 extern const struct nla_policy ifla_policy[IFLA_MAX+1];
 
 #define MODULE_ALIAS_RTNL_LINK(kind) MODULE_ALIAS("rtnl-link-" kind)
-- 
1.8.1.2.459.gbcd45b4.dirty
