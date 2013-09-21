From: Joe Perches <joe@perches.com>
Subject: [PATCH 07/12] ndisc.h: Remove extern from function prototypes
Date: Sat, 21 Sep 2013 10:22:47 -0700
Message-ID: <51c24bca01d49a2080f5f06affeb8bb2862a54ee.1379783995.git.joe@perches.com>
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
 include/net/ndisc.h | 61 +++++++++++++++++++++++------------------------------
 1 file changed, 26 insertions(+), 35 deletions(-)

diff --git a/include/net/ndisc.h b/include/net/ndisc.h
index ea0cc26..6bbda34 100644
--- a/include/net/ndisc.h
+++ b/include/net/ndisc.h
@@ -110,8 +110,8 @@ struct ndisc_options {
 
 #define NDISC_OPT_SPACE(len) (((len)+2+7)&~7)
 
-extern struct ndisc_options *ndisc_parse_options(u8 *opt, int opt_len,
-						 struct ndisc_options *ndopts);
+struct ndisc_options *ndisc_parse_options(u8 *opt, int opt_len,
+					  struct ndisc_options *ndopts);
 
 /*
  * Return the padding between the option length and the start of the
@@ -189,60 +189,51 @@ static inline struct neighbour *__ipv6_neigh_lookup(struct net_device *dev, cons
 	return n;
 }
 
-extern int			ndisc_init(void);
-extern int			ndisc_late_init(void);
+int ndisc_init(void);
+int ndisc_late_init(void);
 
-extern void			ndisc_late_cleanup(void);
-extern void			ndisc_cleanup(void);
+void ndisc_late_cleanup(void);
+void ndisc_cleanup(void);
 
-extern int			ndisc_rcv(struct sk_buff *skb);
+int ndisc_rcv(struct sk_buff *skb);
 
-extern void			ndisc_send_ns(struct net_device *dev,
-					      struct neighbour *neigh,
-					      const struct in6_addr *solicit,
-					      const struct in6_addr *daddr,
-					      const struct in6_addr *saddr);
+void ndisc_send_ns(struct net_device *dev, struct neighbour *neigh,
+		   const struct in6_addr *solicit,
+		   const struct in6_addr *daddr, const struct in6_addr *saddr);
 
-extern void			ndisc_send_rs(struct net_device *dev,
-					      const struct in6_addr *saddr,
-					      const struct in6_addr *daddr);
-extern void			ndisc_send_na(struct net_device *dev, struct neighbour *neigh,
-					      const struct in6_addr *daddr,
-					      const struct in6_addr *solicited_addr,
-					      bool router, bool solicited, bool override,
-					      bool inc_opt);
+void ndisc_send_rs(struct net_device *dev,
+		   const struct in6_addr *saddr, const struct in6_addr *daddr);
+void ndisc_send_na(struct net_device *dev, struct neighbour *neigh,
+		   const struct in6_addr *daddr,
+		   const struct in6_addr *solicited_addr,
+		   bool router, bool solicited, bool override, bool inc_opt);
 
-extern void			ndisc_send_redirect(struct sk_buff *skb,
-						    const struct in6_addr *target);
+void ndisc_send_redirect(struct sk_buff *skb, const struct in6_addr *target);
 
-extern int			ndisc_mc_map(const struct in6_addr *addr, char *buf,
-					     struct net_device *dev, int dir);
+int ndisc_mc_map(const struct in6_addr *addr, char *buf, struct net_device *dev,
+		 int dir);
 
 
 /*
  *	IGMP
  */
-extern int			igmp6_init(void);
+int igmp6_init(void);
 
-extern void			igmp6_cleanup(void);
+void igmp6_cleanup(void);
 
-extern int			igmp6_event_query(struct sk_buff *skb);
+int igmp6_event_query(struct sk_buff *skb);
 
-extern int			igmp6_event_report(struct sk_buff *skb);
+int igmp6_event_report(struct sk_buff *skb);
 
 
 #ifdef CONFIG_SYSCTL
-extern int 			ndisc_ifinfo_sysctl_change(struct ctl_table *ctl,
-							   int write,
-							   void __user *buffer,
-							   size_t *lenp,
-							   loff_t *ppos);
+int ndisc_ifinfo_sysctl_change(struct ctl_table *ctl, int write,
+			       void __user *buffer, size_t *lenp, loff_t *ppos);
 int ndisc_ifinfo_sysctl_strategy(struct ctl_table *ctl,
 				 void __user *oldval, size_t __user *oldlenp,
 				 void __user *newval, size_t newlen);
 #endif
 
-extern void 			inet6_ifinfo_notify(int event,
-						    struct inet6_dev *idev);
+void inet6_ifinfo_notify(int event, struct inet6_dev *idev);
 
 #endif
-- 
1.8.1.2.459.gbcd45b4.dirty
