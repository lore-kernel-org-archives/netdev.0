From: Joe Perches <joe@perches.com>
Subject: [PATCH 4/8] arp/neighbour.h: Remove extern from function prototypes
Date: Wed, 31 Jul 2013 17:31:35 -0700
Message-ID: <1547933442787a524aeb83c21c456ca67a4a4a31.1375316912.git.joe@perches.com>
References: <cover.1375316912.git.joe@perches.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1375316912.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There are a mix of function prototypes with and without extern
in the kernel sources.  Standardize on not using extern for
function prototypes.

Function prototypes don't need to be written with extern.
extern is assumed by the compiler.  Its use is as unnecessary as
using auto to declare automatic/local variables in a block.

Reflow modified prototypes to 80 columns.

Signed-off-by: Joe Perches <joe@perches.com>
---
 include/net/arp.h       | 30 +++++++--------
 include/net/neighbour.h | 98 ++++++++++++++++++++++++-------------------------
 2 files changed, 63 insertions(+), 65 deletions(-)

diff --git a/include/net/arp.h b/include/net/arp.h
index b630dae..7509d9d 100644
--- a/include/net/arp.h
+++ b/include/net/arp.h
@@ -46,22 +46,22 @@ static inline struct neighbour *__ipv4_neigh_lookup(struct net_device *dev, u32
 	return n;
 }
 
-extern void	arp_init(void);
-extern int	arp_find(unsigned char *haddr, struct sk_buff *skb);
-extern int	arp_ioctl(struct net *net, unsigned int cmd, void __user *arg);
-extern void     arp_send(int type, int ptype, __be32 dest_ip,
-			 struct net_device *dev, __be32 src_ip,
-			 const unsigned char *dest_hw,
-			 const unsigned char *src_hw, const unsigned char *th);
-extern int	arp_mc_map(__be32 addr, u8 *haddr, struct net_device *dev, int dir);
-extern void	arp_ifdown(struct net_device *dev);
+void arp_init(void);
+int arp_find(unsigned char *haddr, struct sk_buff *skb);
+int arp_ioctl(struct net *net, unsigned int cmd, void __user *arg);
+void arp_send(int type, int ptype, __be32 dest_ip,
+	      struct net_device *dev, __be32 src_ip,
+	      const unsigned char *dest_hw,
+	      const unsigned char *src_hw, const unsigned char *th);
+int arp_mc_map(__be32 addr, u8 *haddr, struct net_device *dev, int dir);
+void arp_ifdown(struct net_device *dev);
 
-extern struct sk_buff *arp_create(int type, int ptype, __be32 dest_ip,
-				  struct net_device *dev, __be32 src_ip,
-				  const unsigned char *dest_hw,
-				  const unsigned char *src_hw,
-				  const unsigned char *target_hw);
-extern void arp_xmit(struct sk_buff *skb);
+struct sk_buff *arp_create(int type, int ptype, __be32 dest_ip,
+			   struct net_device *dev, __be32 src_ip,
+			   const unsigned char *dest_hw,
+			   const unsigned char *src_hw,
+			   const unsigned char *target_hw);
+void arp_xmit(struct sk_buff *skb);
 int arp_invalidate(struct net_device *dev, __be32 ip);
 
 #endif	/* _ARP_H */
diff --git a/include/net/neighbour.h b/include/net/neighbour.h
index 7e748ad..536501a 100644
--- a/include/net/neighbour.h
+++ b/include/net/neighbour.h
@@ -195,68 +195,67 @@ static inline void *neighbour_priv(const struct neighbour *n)
 #define NEIGH_UPDATE_F_ISROUTER			0x40000000
 #define NEIGH_UPDATE_F_ADMIN			0x80000000
 
-extern void			neigh_table_init(struct neigh_table *tbl);
-extern int			neigh_table_clear(struct neigh_table *tbl);
-extern struct neighbour *	neigh_lookup(struct neigh_table *tbl,
-					     const void *pkey,
-					     struct net_device *dev);
-extern struct neighbour *	neigh_lookup_nodev(struct neigh_table *tbl,
-						   struct net *net,
-						   const void *pkey);
-extern struct neighbour *	__neigh_create(struct neigh_table *tbl,
-					       const void *pkey,
-					       struct net_device *dev,
-					       bool want_ref);
+void neigh_table_init(struct neigh_table *tbl);
+int neigh_table_clear(struct neigh_table *tbl);
+struct neighbour *neigh_lookup(struct neigh_table *tbl, const void *pkey,
+			       struct net_device *dev);
+struct neighbour *neigh_lookup_nodev(struct neigh_table *tbl, struct net *net,
+				     const void *pkey);
+struct neighbour *__neigh_create(struct neigh_table *tbl, const void *pkey,
+				 struct net_device *dev, bool want_ref);
 static inline struct neighbour *neigh_create(struct neigh_table *tbl,
 					     const void *pkey,
 					     struct net_device *dev)
 {
 	return __neigh_create(tbl, pkey, dev, true);
 }
-extern void			neigh_destroy(struct neighbour *neigh);
-extern int			__neigh_event_send(struct neighbour *neigh, struct sk_buff *skb);
-extern int			neigh_update(struct neighbour *neigh, const u8 *lladdr, u8 new, 
-					     u32 flags);
-extern void			neigh_changeaddr(struct neigh_table *tbl, struct net_device *dev);
-extern int			neigh_ifdown(struct neigh_table *tbl, struct net_device *dev);
-extern int			neigh_resolve_output(struct neighbour *neigh, struct sk_buff *skb);
-extern int			neigh_connected_output(struct neighbour *neigh, struct sk_buff *skb);
-extern int			neigh_compat_output(struct neighbour *neigh, struct sk_buff *skb);
-extern int			neigh_direct_output(struct neighbour *neigh, struct sk_buff *skb);
-extern struct neighbour 	*neigh_event_ns(struct neigh_table *tbl,
+void neigh_destroy(struct neighbour *neigh);
+int __neigh_event_send(struct neighbour *neigh, struct sk_buff *skb);
+int neigh_update(struct neighbour *neigh, const u8 *lladdr, u8 new, u32 flags);
+void neigh_changeaddr(struct neigh_table *tbl, struct net_device *dev);
+int neigh_ifdown(struct neigh_table *tbl, struct net_device *dev);
+int neigh_resolve_output(struct neighbour *neigh, struct sk_buff *skb);
+int neigh_connected_output(struct neighbour *neigh, struct sk_buff *skb);
+int neigh_compat_output(struct neighbour *neigh, struct sk_buff *skb);
+int neigh_direct_output(struct neighbour *neigh, struct sk_buff *skb);
+struct neighbour *neigh_event_ns(struct neigh_table *tbl,
 						u8 *lladdr, void *saddr,
 						struct net_device *dev);
 
-extern struct neigh_parms	*neigh_parms_alloc(struct net_device *dev, struct neigh_table *tbl);
-extern void			neigh_parms_release(struct neigh_table *tbl, struct neigh_parms *parms);
+struct neigh_parms *neigh_parms_alloc(struct net_device *dev,
+				      struct neigh_table *tbl);
+void neigh_parms_release(struct neigh_table *tbl, struct neigh_parms *parms);
 
 static inline
-struct net			*neigh_parms_net(const struct neigh_parms *parms)
+struct net *neigh_parms_net(const struct neigh_parms *parms)
 {
 	return read_pnet(&parms->net);
 }
 
-extern unsigned long		neigh_rand_reach_time(unsigned long base);
+unsigned long neigh_rand_reach_time(unsigned long base);
 
-extern void			pneigh_enqueue(struct neigh_table *tbl, struct neigh_parms *p,
-					       struct sk_buff *skb);
-extern struct pneigh_entry	*pneigh_lookup(struct neigh_table *tbl, struct net *net, const void *key, struct net_device *dev, int creat);
-extern struct pneigh_entry	*__pneigh_lookup(struct neigh_table *tbl,
-						 struct net *net,
-						 const void *key,
-						 struct net_device *dev);
-extern int			pneigh_delete(struct neigh_table *tbl, struct net *net, const void *key, struct net_device *dev);
+void pneigh_enqueue(struct neigh_table *tbl, struct neigh_parms *p,
+		    struct sk_buff *skb);
+struct pneigh_entry *pneigh_lookup(struct neigh_table *tbl, struct net *net,
+				   const void *key, struct net_device *dev,
+				   int creat);
+struct pneigh_entry *__pneigh_lookup(struct neigh_table *tbl, struct net *net,
+				     const void *key, struct net_device *dev);
+int pneigh_delete(struct neigh_table *tbl, struct net *net, const void *key,
+		  struct net_device *dev);
 
-static inline
-struct net			*pneigh_net(const struct pneigh_entry *pneigh)
+static inline struct net *pneigh_net(const struct pneigh_entry *pneigh)
 {
 	return read_pnet(&pneigh->net);
 }
 
-extern void neigh_app_ns(struct neighbour *n);
-extern void neigh_for_each(struct neigh_table *tbl, void (*cb)(struct neighbour *, void *), void *cookie);
-extern void __neigh_for_each_release(struct neigh_table *tbl, int (*cb)(struct neighbour *));
-extern void pneigh_for_each(struct neigh_table *tbl, void (*cb)(struct pneigh_entry *));
+void neigh_app_ns(struct neighbour *n);
+void neigh_for_each(struct neigh_table *tbl,
+		    void (*cb)(struct neighbour *, void *), void *cookie);
+void __neigh_for_each_release(struct neigh_table *tbl,
+			      int (*cb)(struct neighbour *));
+void pneigh_for_each(struct neigh_table *tbl,
+		     void (*cb)(struct pneigh_entry *));
 
 struct neigh_seq_state {
 	struct seq_net_private p;
@@ -270,15 +269,14 @@ struct neigh_seq_state {
 #define NEIGH_SEQ_IS_PNEIGH	0x00000002
 #define NEIGH_SEQ_SKIP_NOARP	0x00000004
 };
-extern void *neigh_seq_start(struct seq_file *, loff_t *, struct neigh_table *, unsigned int);
-extern void *neigh_seq_next(struct seq_file *, void *, loff_t *);
-extern void neigh_seq_stop(struct seq_file *, void *);
-
-extern int			neigh_sysctl_register(struct net_device *dev, 
-						      struct neigh_parms *p,
-						      char *p_name,
-						      proc_handler *proc_handler);
-extern void			neigh_sysctl_unregister(struct neigh_parms *p);
+void *neigh_seq_start(struct seq_file *, loff_t *, struct neigh_table *,
+		      unsigned int);
+void *neigh_seq_next(struct seq_file *, void *, loff_t *);
+void neigh_seq_stop(struct seq_file *, void *);
+
+int neigh_sysctl_register(struct net_device *dev, struct neigh_parms *p,
+			  char *p_name, proc_handler *proc_handler);
+void neigh_sysctl_unregister(struct neigh_parms *p);
 
 static inline void __neigh_parms_put(struct neigh_parms *parms)
 {
-- 
1.8.1.2.459.gbcd45b4.dirty
