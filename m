From: Joe Perches <joe@perches.com>
Subject: [PATCH 03/11] decnet (dn*.h): Remove extern from function prototypes
Date: Fri, 20 Sep 2013 11:23:20 -0700
Message-ID: <2bd646b9518163db935505c69884b39b8a5a9c26.1379701322.git.joe@perches.com>
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
 include/net/dn.h       | 20 +++++++++++---------
 include/net/dn_dev.h   | 30 +++++++++++++++---------------
 include/net/dn_fib.h   | 47 ++++++++++++++++++++++-------------------------
 include/net/dn_neigh.h | 12 ++++++------
 include/net/dn_nsp.h   | 49 ++++++++++++++++++++++++++-----------------------
 include/net/dn_route.h | 13 +++++++------
 6 files changed, 87 insertions(+), 84 deletions(-)

diff --git a/include/net/dn.h b/include/net/dn.h
index c88bf4e..ccc1558 100644
--- a/include/net/dn.h
+++ b/include/net/dn.h
@@ -199,24 +199,26 @@ static inline void dn_sk_ports_copy(struct flowidn *fld, struct dn_scp *scp)
 	fld->fld_dport = scp->addrrem;
 }
 
-extern unsigned int dn_mss_from_pmtu(struct net_device *dev, int mtu);
+unsigned int dn_mss_from_pmtu(struct net_device *dev, int mtu);
 
 #define DN_MENUVER_ACC 0x01
 #define DN_MENUVER_USR 0x02
 #define DN_MENUVER_PRX 0x04
 #define DN_MENUVER_UIC 0x08
 
-extern struct sock *dn_sklist_find_listener(struct sockaddr_dn *addr);
-extern struct sock *dn_find_by_skb(struct sk_buff *skb);
+struct sock *dn_sklist_find_listener(struct sockaddr_dn *addr);
+struct sock *dn_find_by_skb(struct sk_buff *skb);
 #define DN_ASCBUF_LEN 9
-extern char *dn_addr2asc(__u16, char *);
-extern int dn_destroy_timer(struct sock *sk);
+char *dn_addr2asc(__u16, char *);
+int dn_destroy_timer(struct sock *sk);
 
-extern int dn_sockaddr2username(struct sockaddr_dn *addr, unsigned char *buf, unsigned char type);
-extern int dn_username2sockaddr(unsigned char *data, int len, struct sockaddr_dn *addr, unsigned char *type);
+int dn_sockaddr2username(struct sockaddr_dn *addr, unsigned char *buf,
+			 unsigned char type);
+int dn_username2sockaddr(unsigned char *data, int len, struct sockaddr_dn *addr,
+			 unsigned char *type);
 
-extern void dn_start_slow_timer(struct sock *sk);
-extern void dn_stop_slow_timer(struct sock *sk);
+void dn_start_slow_timer(struct sock *sk);
+void dn_stop_slow_timer(struct sock *sk);
 
 extern __le16 decnet_address;
 extern int decnet_debug_level;
diff --git a/include/net/dn_dev.h b/include/net/dn_dev.h
index b9e32db..20b5ab0 100644
--- a/include/net/dn_dev.h
+++ b/include/net/dn_dev.h
@@ -148,27 +148,27 @@ struct rtnode_hello_message {
 } __packed;
 
 
-extern void dn_dev_init(void);
-extern void dn_dev_cleanup(void);
+void dn_dev_init(void);
+void dn_dev_cleanup(void);
 
-extern int dn_dev_ioctl(unsigned int cmd, void __user *arg);
+int dn_dev_ioctl(unsigned int cmd, void __user *arg);
 
-extern void dn_dev_devices_off(void);
-extern void dn_dev_devices_on(void);
+void dn_dev_devices_off(void);
+void dn_dev_devices_on(void);
 
-extern void dn_dev_init_pkt(struct sk_buff *skb);
-extern void dn_dev_veri_pkt(struct sk_buff *skb);
-extern void dn_dev_hello(struct sk_buff *skb);
+void dn_dev_init_pkt(struct sk_buff *skb);
+void dn_dev_veri_pkt(struct sk_buff *skb);
+void dn_dev_hello(struct sk_buff *skb);
 
-extern void dn_dev_up(struct net_device *);
-extern void dn_dev_down(struct net_device *);
+void dn_dev_up(struct net_device *);
+void dn_dev_down(struct net_device *);
 
-extern int dn_dev_set_default(struct net_device *dev, int force);
-extern struct net_device *dn_dev_get_default(void);
-extern int dn_dev_bind_default(__le16 *addr);
+int dn_dev_set_default(struct net_device *dev, int force);
+struct net_device *dn_dev_get_default(void);
+int dn_dev_bind_default(__le16 *addr);
 
-extern int register_dnaddr_notifier(struct notifier_block *nb);
-extern int unregister_dnaddr_notifier(struct notifier_block *nb);
+int register_dnaddr_notifier(struct notifier_block *nb);
+int unregister_dnaddr_notifier(struct notifier_block *nb);
 
 static inline int dn_dev_islocal(struct net_device *dev, __le16 addr)
 {
diff --git a/include/net/dn_fib.h b/include/net/dn_fib.h
index 74004af..f2ca135 100644
--- a/include/net/dn_fib.h
+++ b/include/net/dn_fib.h
@@ -95,41 +95,38 @@ struct dn_fib_table {
 /*
  * dn_fib.c
  */
-extern void dn_fib_init(void);
-extern void dn_fib_cleanup(void);
-
-extern int dn_fib_ioctl(struct socket *sock, unsigned int cmd, 
-			unsigned long arg);
-extern struct dn_fib_info *dn_fib_create_info(const struct rtmsg *r, 
-				struct nlattr *attrs[],
-				const struct nlmsghdr *nlh, int *errp);
-extern int dn_fib_semantic_match(int type, struct dn_fib_info *fi, 
-			const struct flowidn *fld,
-			struct dn_fib_res *res);
-extern void dn_fib_release_info(struct dn_fib_info *fi);
-extern void dn_fib_flush(void);
-extern void dn_fib_select_multipath(const struct flowidn *fld,
-					struct dn_fib_res *res);
+void dn_fib_init(void);
+void dn_fib_cleanup(void);
+
+int dn_fib_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg);
+struct dn_fib_info *dn_fib_create_info(const struct rtmsg *r,
+				       struct nlattr *attrs[],
+				       const struct nlmsghdr *nlh, int *errp);
+int dn_fib_semantic_match(int type, struct dn_fib_info *fi,
+			  const struct flowidn *fld, struct dn_fib_res *res);
+void dn_fib_release_info(struct dn_fib_info *fi);
+void dn_fib_flush(void);
+void dn_fib_select_multipath(const struct flowidn *fld, struct dn_fib_res *res);
 
 /*
  * dn_tables.c
  */
-extern struct dn_fib_table *dn_fib_get_table(u32 n, int creat);
-extern struct dn_fib_table *dn_fib_empty_table(void);
-extern void dn_fib_table_init(void);
-extern void dn_fib_table_cleanup(void);
+struct dn_fib_table *dn_fib_get_table(u32 n, int creat);
+struct dn_fib_table *dn_fib_empty_table(void);
+void dn_fib_table_init(void);
+void dn_fib_table_cleanup(void);
 
 /*
  * dn_rules.c
  */
-extern void dn_fib_rules_init(void);
-extern void dn_fib_rules_cleanup(void);
-extern unsigned int dnet_addr_type(__le16 addr);
-extern int dn_fib_lookup(struct flowidn *fld, struct dn_fib_res *res);
+void dn_fib_rules_init(void);
+void dn_fib_rules_cleanup(void);
+unsigned int dnet_addr_type(__le16 addr);
+int dn_fib_lookup(struct flowidn *fld, struct dn_fib_res *res);
 
-extern int dn_fib_dump(struct sk_buff *skb, struct netlink_callback *cb);
+int dn_fib_dump(struct sk_buff *skb, struct netlink_callback *cb);
 
-extern void dn_fib_free_info(struct dn_fib_info *fi);
+void dn_fib_free_info(struct dn_fib_info *fi);
 
 static inline void dn_fib_info_put(struct dn_fib_info *fi)
 {
diff --git a/include/net/dn_neigh.h b/include/net/dn_neigh.h
index 4cb4ae7..fac4e3f 100644
--- a/include/net/dn_neigh.h
+++ b/include/net/dn_neigh.h
@@ -16,12 +16,12 @@ struct dn_neigh {
 	__u8 priority;
 };
 
-extern void dn_neigh_init(void);
-extern void dn_neigh_cleanup(void);
-extern int dn_neigh_router_hello(struct sk_buff *skb);
-extern int dn_neigh_endnode_hello(struct sk_buff *skb);
-extern void dn_neigh_pointopoint_hello(struct sk_buff *skb);
-extern int dn_neigh_elist(struct net_device *dev, unsigned char *ptr, int n);
+void dn_neigh_init(void);
+void dn_neigh_cleanup(void);
+int dn_neigh_router_hello(struct sk_buff *skb);
+int dn_neigh_endnode_hello(struct sk_buff *skb);
+void dn_neigh_pointopoint_hello(struct sk_buff *skb);
+int dn_neigh_elist(struct net_device *dev, unsigned char *ptr, int n);
 
 extern struct neigh_table dn_neigh_table;
 
diff --git a/include/net/dn_nsp.h b/include/net/dn_nsp.h
index e43a289..3a3e33d 100644
--- a/include/net/dn_nsp.h
+++ b/include/net/dn_nsp.h
@@ -15,29 +15,32 @@
 *******************************************************************************/
 /* dn_nsp.c functions prototyping */
 
-extern void dn_nsp_send_data_ack(struct sock *sk);
-extern void dn_nsp_send_oth_ack(struct sock *sk);
-extern void dn_nsp_delayed_ack(struct sock *sk);
-extern void dn_send_conn_ack(struct sock *sk);
-extern void dn_send_conn_conf(struct sock *sk, gfp_t gfp);
-extern void dn_nsp_send_disc(struct sock *sk, unsigned char type, 
-			unsigned short reason, gfp_t gfp);
-extern void dn_nsp_return_disc(struct sk_buff *skb, unsigned char type,
-				unsigned short reason);
-extern void dn_nsp_send_link(struct sock *sk, unsigned char lsflags, char fcval);
-extern void dn_nsp_send_conninit(struct sock *sk, unsigned char flags);
-
-extern void dn_nsp_output(struct sock *sk);
-extern int dn_nsp_check_xmit_queue(struct sock *sk, struct sk_buff *skb, struct sk_buff_head *q, unsigned short acknum);
-extern void dn_nsp_queue_xmit(struct sock *sk, struct sk_buff *skb, gfp_t gfp, int oob);
-extern unsigned long dn_nsp_persist(struct sock *sk);
-extern int dn_nsp_xmit_timeout(struct sock *sk);
-
-extern int dn_nsp_rx(struct sk_buff *);
-extern int dn_nsp_backlog_rcv(struct sock *sk, struct sk_buff *skb);
-
-extern struct sk_buff *dn_alloc_skb(struct sock *sk, int size, gfp_t pri);
-extern struct sk_buff *dn_alloc_send_skb(struct sock *sk, size_t *size, int noblock, long timeo, int *err);
+void dn_nsp_send_data_ack(struct sock *sk);
+void dn_nsp_send_oth_ack(struct sock *sk);
+void dn_nsp_delayed_ack(struct sock *sk);
+void dn_send_conn_ack(struct sock *sk);
+void dn_send_conn_conf(struct sock *sk, gfp_t gfp);
+void dn_nsp_send_disc(struct sock *sk, unsigned char type,
+		      unsigned short reason, gfp_t gfp);
+void dn_nsp_return_disc(struct sk_buff *skb, unsigned char type,
+			unsigned short reason);
+void dn_nsp_send_link(struct sock *sk, unsigned char lsflags, char fcval);
+void dn_nsp_send_conninit(struct sock *sk, unsigned char flags);
+
+void dn_nsp_output(struct sock *sk);
+int dn_nsp_check_xmit_queue(struct sock *sk, struct sk_buff *skb,
+			    struct sk_buff_head *q, unsigned short acknum);
+void dn_nsp_queue_xmit(struct sock *sk, struct sk_buff *skb, gfp_t gfp,
+		       int oob);
+unsigned long dn_nsp_persist(struct sock *sk);
+int dn_nsp_xmit_timeout(struct sock *sk);
+
+int dn_nsp_rx(struct sk_buff *);
+int dn_nsp_backlog_rcv(struct sock *sk, struct sk_buff *skb);
+
+struct sk_buff *dn_alloc_skb(struct sock *sk, int size, gfp_t pri);
+struct sk_buff *dn_alloc_send_skb(struct sock *sk, size_t *size, int noblock,
+				  long timeo, int *err);
 
 #define NSP_REASON_OK 0		/* No error */
 #define NSP_REASON_NR 1		/* No resources */
diff --git a/include/net/dn_route.h b/include/net/dn_route.h
index 2e9d317..b409ad6 100644
--- a/include/net/dn_route.h
+++ b/include/net/dn_route.h
@@ -15,10 +15,11 @@
     GNU General Public License for more details.
 *******************************************************************************/
 
-extern struct sk_buff *dn_alloc_skb(struct sock *sk, int size, gfp_t pri);
-extern int dn_route_output_sock(struct dst_entry __rcu **pprt, struct flowidn *, struct sock *sk, int flags);
-extern int dn_cache_dump(struct sk_buff *skb, struct netlink_callback *cb);
-extern void dn_rt_cache_flush(int delay);
+struct sk_buff *dn_alloc_skb(struct sock *sk, int size, gfp_t pri);
+int dn_route_output_sock(struct dst_entry __rcu **pprt, struct flowidn *,
+			 struct sock *sk, int flags);
+int dn_cache_dump(struct sk_buff *skb, struct netlink_callback *cb);
+void dn_rt_cache_flush(int delay);
 
 /* Masks for flags field */
 #define DN_RT_F_PID 0x07 /* Mask for packet type                      */
@@ -92,8 +93,8 @@ static inline bool dn_is_output_route(struct dn_route *rt)
 	return rt->fld.flowidn_iif == 0;
 }
 
-extern void dn_route_init(void);
-extern void dn_route_cleanup(void);
+void dn_route_init(void);
+void dn_route_cleanup(void);
 
 #include <net/sock.h>
 #include <linux/if_arp.h>
-- 
1.8.1.2.459.gbcd45b4.dirty
