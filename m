From: Joe Perches <joe@perches.com>
Subject: [PATCH 02/12] udp.h: Remove extern from function prototypes
Date: Mon, 23 Sep 2013 11:33:36 -0700
Message-ID: <1eb47b92bce9209f3d2d1e0aa56a98d4dfff0f2b.1379961014.git.joe@perches.com>
References: <445209f8885ccd8234fa787c30d63e63fc7917d7.1379961014.git.joe@perches.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <445209f8885ccd8234fa787c30d63e63fc7917d7.1379961014.git.joe@perches.com>
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
 include/net/udp.h | 94 +++++++++++++++++++++++++++----------------------------
 1 file changed, 47 insertions(+), 47 deletions(-)

diff --git a/include/net/udp.h b/include/net/udp.h
index ef2e0b7..510b8cb 100644
--- a/include/net/udp.h
+++ b/include/net/udp.h
@@ -79,7 +79,7 @@ struct udp_table {
 	unsigned int		log;
 };
 extern struct udp_table udp_table;
-extern void udp_table_init(struct udp_table *, const char *);
+void udp_table_init(struct udp_table *, const char *);
 static inline struct udp_hslot *udp_hashslot(struct udp_table *table,
 					     struct net *net, unsigned int num)
 {
@@ -162,52 +162,52 @@ static inline void udp_lib_hash(struct sock *sk)
 	BUG();
 }
 
-extern void udp_lib_unhash(struct sock *sk);
-extern void udp_lib_rehash(struct sock *sk, u16 new_hash);
+void udp_lib_unhash(struct sock *sk);
+void udp_lib_rehash(struct sock *sk, u16 new_hash);
 
 static inline void udp_lib_close(struct sock *sk, long timeout)
 {
 	sk_common_release(sk);
 }
 
-extern int udp_lib_get_port(struct sock *sk, unsigned short snum,
-			    int (*)(const struct sock *,const struct sock *),
-			    unsigned int hash2_nulladdr);
+int udp_lib_get_port(struct sock *sk, unsigned short snum,
+		     int (*)(const struct sock *, const struct sock *),
+		     unsigned int hash2_nulladdr);
 
 /* net/ipv4/udp.c */
-extern int udp_get_port(struct sock *sk, unsigned short snum,
-			int (*saddr_cmp)(const struct sock *,
-					 const struct sock *));
-extern void udp_err(struct sk_buff *, u32);
-extern int udp_sendmsg(struct kiocb *iocb, struct sock *sk,
-			    struct msghdr *msg, size_t len);
-extern int udp_push_pending_frames(struct sock *sk);
-extern void udp_flush_pending_frames(struct sock *sk);
-extern void udp4_hwcsum(struct sk_buff *skb, __be32 src, __be32 dst);
-extern int udp_rcv(struct sk_buff *skb);
-extern int udp_ioctl(struct sock *sk, int cmd, unsigned long arg);
-extern int udp_disconnect(struct sock *sk, int flags);
-extern unsigned int udp_poll(struct file *file, struct socket *sock,
-			     poll_table *wait);
-extern struct sk_buff *skb_udp_tunnel_segment(struct sk_buff *skb,
-					      netdev_features_t features);
-extern int udp_lib_getsockopt(struct sock *sk, int level, int optname,
-			      char __user *optval, int __user *optlen);
-extern int udp_lib_setsockopt(struct sock *sk, int level, int optname,
-			      char __user *optval, unsigned int optlen,
-			      int (*push_pending_frames)(struct sock *));
-extern struct sock *udp4_lib_lookup(struct net *net, __be32 saddr, __be16 sport,
-				    __be32 daddr, __be16 dport,
-				    int dif);
-extern struct sock *__udp4_lib_lookup(struct net *net, __be32 saddr, __be16 sport,
-				    __be32 daddr, __be16 dport,
-				    int dif, struct udp_table *tbl);
-extern struct sock *udp6_lib_lookup(struct net *net, const struct in6_addr *saddr, __be16 sport,
-				    const struct in6_addr *daddr, __be16 dport,
-				    int dif);
-extern struct sock *__udp6_lib_lookup(struct net *net, const struct in6_addr *saddr, __be16 sport,
-				    const struct in6_addr *daddr, __be16 dport,
-				    int dif, struct udp_table *tbl);
+int udp_get_port(struct sock *sk, unsigned short snum,
+		 int (*saddr_cmp)(const struct sock *,
+				  const struct sock *));
+void udp_err(struct sk_buff *, u32);
+int udp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
+		size_t len);
+int udp_push_pending_frames(struct sock *sk);
+void udp_flush_pending_frames(struct sock *sk);
+void udp4_hwcsum(struct sk_buff *skb, __be32 src, __be32 dst);
+int udp_rcv(struct sk_buff *skb);
+int udp_ioctl(struct sock *sk, int cmd, unsigned long arg);
+int udp_disconnect(struct sock *sk, int flags);
+unsigned int udp_poll(struct file *file, struct socket *sock, poll_table *wait);
+struct sk_buff *skb_udp_tunnel_segment(struct sk_buff *skb,
+				       netdev_features_t features);
+int udp_lib_getsockopt(struct sock *sk, int level, int optname,
+		       char __user *optval, int __user *optlen);
+int udp_lib_setsockopt(struct sock *sk, int level, int optname,
+		       char __user *optval, unsigned int optlen,
+		       int (*push_pending_frames)(struct sock *));
+struct sock *udp4_lib_lookup(struct net *net, __be32 saddr, __be16 sport,
+			     __be32 daddr, __be16 dport, int dif);
+struct sock *__udp4_lib_lookup(struct net *net, __be32 saddr, __be16 sport,
+			       __be32 daddr, __be16 dport, int dif,
+			       struct udp_table *tbl);
+struct sock *udp6_lib_lookup(struct net *net,
+			     const struct in6_addr *saddr, __be16 sport,
+			     const struct in6_addr *daddr, __be16 dport,
+			     int dif);
+struct sock *__udp6_lib_lookup(struct net *net,
+			       const struct in6_addr *saddr, __be16 sport,
+			       const struct in6_addr *daddr, __be16 dport,
+			       int dif, struct udp_table *tbl);
 
 /*
  * 	SNMP statistics for UDP and UDP-Lite
@@ -259,19 +259,19 @@ struct udp_iter_state {
 };
 
 #ifdef CONFIG_PROC_FS
-extern int udp_proc_register(struct net *net, struct udp_seq_afinfo *afinfo);
-extern void udp_proc_unregister(struct net *net, struct udp_seq_afinfo *afinfo);
+int udp_proc_register(struct net *net, struct udp_seq_afinfo *afinfo);
+void udp_proc_unregister(struct net *net, struct udp_seq_afinfo *afinfo);
 
-extern int udp4_proc_init(void);
-extern void udp4_proc_exit(void);
+int udp4_proc_init(void);
+void udp4_proc_exit(void);
 #endif
 
-extern int udpv4_offload_init(void);
+int udpv4_offload_init(void);
 
-extern void udp_init(void);
+void udp_init(void);
 
-extern void udp_encap_enable(void);
+void udp_encap_enable(void);
 #if IS_ENABLED(CONFIG_IPV6)
-extern void udpv6_encap_enable(void);
+void udpv6_encap_enable(void);
 #endif
 #endif	/* _UDP_H */
-- 
1.8.1.2.459.gbcd45b4.dirty
