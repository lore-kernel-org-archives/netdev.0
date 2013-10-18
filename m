From: Joe Perches <joe@perches.com>
Subject: [PATCH 3/4] net: ipv4/ipv6: Remove extern from function prototypes
Date: Fri, 18 Oct 2013 13:48:24 -0700
Message-ID: <aba4218f77bc1a69d5483f6294d18f074d5eae3b.1382129045.git.joe@perches.com>
References: <cover.1382129045.git.joe@perches.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1382129045.git.joe@perches.com>
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
 net/ipv4/fib_lookup.h | 26 +++++++++++---------------
 net/ipv4/tcp_vegas.h  | 10 +++++-----
 net/ipv4/udp_impl.h   | 36 ++++++++++++++++++------------------
 net/ipv6/udp_impl.h   | 41 ++++++++++++++++++++---------------------
 4 files changed, 54 insertions(+), 59 deletions(-)

diff --git a/net/ipv4/fib_lookup.h b/net/ipv4/fib_lookup.h
index 50cfb3e..388d113 100644
--- a/net/ipv4/fib_lookup.h
+++ b/net/ipv4/fib_lookup.h
@@ -24,21 +24,17 @@ static inline void fib_alias_accessed(struct fib_alias *fa)
 }
 
 /* Exported by fib_semantics.c */
-extern void fib_release_info(struct fib_info *);
-extern struct fib_info *fib_create_info(struct fib_config *cfg);
-extern int fib_nh_match(struct fib_config *cfg, struct fib_info *fi);
-extern int fib_dump_info(struct sk_buff *skb, u32 pid, u32 seq, int event,
-			 u32 tb_id, u8 type, __be32 dst,
-			 int dst_len, u8 tos, struct fib_info *fi,
-			 unsigned int);
-extern void rtmsg_fib(int event, __be32 key, struct fib_alias *fa,
-		      int dst_len, u32 tb_id, const struct nl_info *info,
-		      unsigned int nlm_flags);
-extern struct fib_alias *fib_find_alias(struct list_head *fah,
-					u8 tos, u32 prio);
-extern int fib_detect_death(struct fib_info *fi, int order,
-			    struct fib_info **last_resort,
-			    int *last_idx, int dflt);
+void fib_release_info(struct fib_info *);
+struct fib_info *fib_create_info(struct fib_config *cfg);
+int fib_nh_match(struct fib_config *cfg, struct fib_info *fi);
+int fib_dump_info(struct sk_buff *skb, u32 pid, u32 seq, int event, u32 tb_id,
+		  u8 type, __be32 dst, int dst_len, u8 tos, struct fib_info *fi,
+		  unsigned int);
+void rtmsg_fib(int event, __be32 key, struct fib_alias *fa, int dst_len,
+	       u32 tb_id, const struct nl_info *info, unsigned int nlm_flags);
+struct fib_alias *fib_find_alias(struct list_head *fah, u8 tos, u32 prio);
+int fib_detect_death(struct fib_info *fi, int order,
+		     struct fib_info **last_resort, int *last_idx, int dflt);
 
 static inline void fib_result_assign(struct fib_result *res,
 				     struct fib_info *fi)
diff --git a/net/ipv4/tcp_vegas.h b/net/ipv4/tcp_vegas.h
index 6c0eea2..0531b99 100644
--- a/net/ipv4/tcp_vegas.h
+++ b/net/ipv4/tcp_vegas.h
@@ -15,10 +15,10 @@ struct vegas {
 	u32	baseRTT;	/* the min of all Vegas RTT measurements seen (in usec) */
 };
 
-extern void tcp_vegas_init(struct sock *sk);
-extern void tcp_vegas_state(struct sock *sk, u8 ca_state);
-extern void tcp_vegas_pkts_acked(struct sock *sk, u32 cnt, s32 rtt_us);
-extern void tcp_vegas_cwnd_event(struct sock *sk, enum tcp_ca_event event);
-extern void tcp_vegas_get_info(struct sock *sk, u32 ext, struct sk_buff *skb);
+void tcp_vegas_init(struct sock *sk);
+void tcp_vegas_state(struct sock *sk, u8 ca_state);
+void tcp_vegas_pkts_acked(struct sock *sk, u32 cnt, s32 rtt_us);
+void tcp_vegas_cwnd_event(struct sock *sk, enum tcp_ca_event event);
+void tcp_vegas_get_info(struct sock *sk, u32 ext, struct sk_buff *skb);
 
 #endif	/* __TCP_VEGAS_H */
diff --git a/net/ipv4/udp_impl.h b/net/ipv4/udp_impl.h
index 5a681e2..f3c2789 100644
--- a/net/ipv4/udp_impl.h
+++ b/net/ipv4/udp_impl.h
@@ -5,30 +5,30 @@
 #include <net/protocol.h>
 #include <net/inet_common.h>
 
-extern int  	__udp4_lib_rcv(struct sk_buff *, struct udp_table *, int );
-extern void 	__udp4_lib_err(struct sk_buff *, u32, struct udp_table *);
+int __udp4_lib_rcv(struct sk_buff *, struct udp_table *, int);
+void __udp4_lib_err(struct sk_buff *, u32, struct udp_table *);
 
-extern int	udp_v4_get_port(struct sock *sk, unsigned short snum);
+int udp_v4_get_port(struct sock *sk, unsigned short snum);
 
-extern int	udp_setsockopt(struct sock *sk, int level, int optname,
-			       char __user *optval, unsigned int optlen);
-extern int	udp_getsockopt(struct sock *sk, int level, int optname,
-			       char __user *optval, int __user *optlen);
+int udp_setsockopt(struct sock *sk, int level, int optname,
+		   char __user *optval, unsigned int optlen);
+int udp_getsockopt(struct sock *sk, int level, int optname,
+		   char __user *optval, int __user *optlen);
 
 #ifdef CONFIG_COMPAT
-extern int	compat_udp_setsockopt(struct sock *sk, int level, int optname,
-				      char __user *optval, unsigned int optlen);
-extern int	compat_udp_getsockopt(struct sock *sk, int level, int optname,
-				      char __user *optval, int __user *optlen);
+int compat_udp_setsockopt(struct sock *sk, int level, int optname,
+			  char __user *optval, unsigned int optlen);
+int compat_udp_getsockopt(struct sock *sk, int level, int optname,
+			  char __user *optval, int __user *optlen);
 #endif
-extern int	udp_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
-			    size_t len, int noblock, int flags, int *addr_len);
-extern int	udp_sendpage(struct sock *sk, struct page *page, int offset,
-			     size_t size, int flags);
-extern int	udp_queue_rcv_skb(struct sock *sk, struct sk_buff *skb);
-extern void	udp_destroy_sock(struct sock *sk);
+int udp_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
+		size_t len, int noblock, int flags, int *addr_len);
+int udp_sendpage(struct sock *sk, struct page *page, int offset, size_t size,
+		 int flags);
+int udp_queue_rcv_skb(struct sock *sk, struct sk_buff *skb);
+void udp_destroy_sock(struct sock *sk);
 
 #ifdef CONFIG_PROC_FS
-extern int	udp4_seq_show(struct seq_file *seq, void *v);
+int udp4_seq_show(struct seq_file *seq, void *v);
 #endif
 #endif	/* _UDP4_IMPL_H */
diff --git a/net/ipv6/udp_impl.h b/net/ipv6/udp_impl.h
index 4691ed5..c779c3c 100644
--- a/net/ipv6/udp_impl.h
+++ b/net/ipv6/udp_impl.h
@@ -7,33 +7,32 @@
 #include <net/inet_common.h>
 #include <net/transp_v6.h>
 
-extern int  	__udp6_lib_rcv(struct sk_buff *, struct udp_table *, int );
-extern void 	__udp6_lib_err(struct sk_buff *, struct inet6_skb_parm *,
-			       u8 , u8 , int , __be32 , struct udp_table *);
+int __udp6_lib_rcv(struct sk_buff *, struct udp_table *, int);
+void __udp6_lib_err(struct sk_buff *, struct inet6_skb_parm *, u8, u8, int,
+		    __be32, struct udp_table *);
 
-extern int	udp_v6_get_port(struct sock *sk, unsigned short snum);
+int udp_v6_get_port(struct sock *sk, unsigned short snum);
 
-extern int	udpv6_getsockopt(struct sock *sk, int level, int optname,
-				 char __user *optval, int __user *optlen);
-extern int	udpv6_setsockopt(struct sock *sk, int level, int optname,
-				 char __user *optval, unsigned int optlen);
+int udpv6_getsockopt(struct sock *sk, int level, int optname,
+		     char __user *optval, int __user *optlen);
+int udpv6_setsockopt(struct sock *sk, int level, int optname,
+		     char __user *optval, unsigned int optlen);
 #ifdef CONFIG_COMPAT
-extern int	compat_udpv6_setsockopt(struct sock *sk, int level, int optname,
-					char __user *optval, unsigned int optlen);
-extern int	compat_udpv6_getsockopt(struct sock *sk, int level, int optname,
-				       char __user *optval, int __user *optlen);
+int compat_udpv6_setsockopt(struct sock *sk, int level, int optname,
+			    char __user *optval, unsigned int optlen);
+int compat_udpv6_getsockopt(struct sock *sk, int level, int optname,
+			    char __user *optval, int __user *optlen);
 #endif
-extern int	udpv6_sendmsg(struct kiocb *iocb, struct sock *sk,
-			      struct msghdr *msg, size_t len);
-extern int	udpv6_recvmsg(struct kiocb *iocb, struct sock *sk,
-			      struct msghdr *msg, size_t len,
-			      int noblock, int flags, int *addr_len);
-extern int	udpv6_queue_rcv_skb(struct sock * sk, struct sk_buff *skb);
-extern void	udpv6_destroy_sock(struct sock *sk);
+int udpv6_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
+		  size_t len);
+int udpv6_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
+		  size_t len, int noblock, int flags, int *addr_len);
+int udpv6_queue_rcv_skb(struct sock *sk, struct sk_buff *skb);
+void udpv6_destroy_sock(struct sock *sk);
 
-extern void udp_v6_clear_sk(struct sock *sk, int size);
+void udp_v6_clear_sk(struct sock *sk, int size);
 
 #ifdef CONFIG_PROC_FS
-extern int	udp6_seq_show(struct seq_file *seq, void *v);
+int udp6_seq_show(struct seq_file *seq, void *v);
 #endif
 #endif	/* _UDP6_IMPL_H */
-- 
1.8.1.2.459.gbcd45b4.dirty
