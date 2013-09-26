From: Joe Perches <joe@perches.com>
Subject: [PATCH 2/3] net.h/skbuff.h: Remove extern from function prototypes
Date: Thu, 26 Sep 2013 15:18:32 -0700
Message-ID: <7965bd4d71ef7cf1db00afb9e406ddfc13443c13.1380233637.git.joe@perches.com>
References: <cover.1380233637.git.joe@perches.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1380233637.git.joe@perches.com>
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
 include/linux/net.h    |  82 ++++++++--------
 include/linux/skbuff.h | 250 ++++++++++++++++++++++---------------------------
 2 files changed, 148 insertions(+), 184 deletions(-)

diff --git a/include/linux/net.h b/include/linux/net.h
index 4f27575..ca9ec85 100644
--- a/include/linux/net.h
+++ b/include/linux/net.h
@@ -195,27 +195,23 @@ enum {
 	SOCK_WAKE_URG,
 };
 
-extern int	     sock_wake_async(struct socket *sk, int how, int band);
-extern int	     sock_register(const struct net_proto_family *fam);
-extern void	     sock_unregister(int family);
-extern int	     __sock_create(struct net *net, int family, int type, int proto,
-				 struct socket **res, int kern);
-extern int	     sock_create(int family, int type, int proto,
-				 struct socket **res);
-extern int	     sock_create_kern(int family, int type, int proto,
-				      struct socket **res);
-extern int	     sock_create_lite(int family, int type, int proto,
-				      struct socket **res); 
-extern void	     sock_release(struct socket *sock);
-extern int   	     sock_sendmsg(struct socket *sock, struct msghdr *msg,
-				  size_t len);
-extern int	     sock_recvmsg(struct socket *sock, struct msghdr *msg,
-				  size_t size, int flags);
-extern struct file  *sock_alloc_file(struct socket *sock, int flags, const char *dname);
-extern struct socket *sockfd_lookup(int fd, int *err);
-extern struct socket *sock_from_file(struct file *file, int *err);
+int sock_wake_async(struct socket *sk, int how, int band);
+int sock_register(const struct net_proto_family *fam);
+void sock_unregister(int family);
+int __sock_create(struct net *net, int family, int type, int proto,
+		  struct socket **res, int kern);
+int sock_create(int family, int type, int proto, struct socket **res);
+int sock_create_kern(int family, int type, int proto, struct socket **res);
+int sock_create_lite(int family, int type, int proto, struct socket **res);
+void sock_release(struct socket *sock);
+int sock_sendmsg(struct socket *sock, struct msghdr *msg, size_t len);
+int sock_recvmsg(struct socket *sock, struct msghdr *msg, size_t size,
+		 int flags);
+struct file *sock_alloc_file(struct socket *sock, int flags, const char *dname);
+struct socket *sockfd_lookup(int fd, int *err);
+struct socket *sock_from_file(struct file *file, int *err);
 #define		     sockfd_put(sock) fput(sock->file)
-extern int	     net_ratelimit(void);
+int net_ratelimit(void);
 
 #define net_ratelimited_function(function, ...)			\
 do {								\
@@ -243,32 +239,28 @@ do {								\
 #define net_random()		prandom_u32()
 #define net_srandom(seed)	prandom_seed((__force u32)(seed))
 
-extern int   	     kernel_sendmsg(struct socket *sock, struct msghdr *msg,
-				    struct kvec *vec, size_t num, size_t len);
-extern int   	     kernel_recvmsg(struct socket *sock, struct msghdr *msg,
-				    struct kvec *vec, size_t num,
-				    size_t len, int flags);
+int kernel_sendmsg(struct socket *sock, struct msghdr *msg, struct kvec *vec,
+		   size_t num, size_t len);
+int kernel_recvmsg(struct socket *sock, struct msghdr *msg, struct kvec *vec,
+		   size_t num, size_t len, int flags);
 
-extern int kernel_bind(struct socket *sock, struct sockaddr *addr,
-		       int addrlen);
-extern int kernel_listen(struct socket *sock, int backlog);
-extern int kernel_accept(struct socket *sock, struct socket **newsock,
-			 int flags);
-extern int kernel_connect(struct socket *sock, struct sockaddr *addr,
-			  int addrlen, int flags);
-extern int kernel_getsockname(struct socket *sock, struct sockaddr *addr,
-			      int *addrlen);
-extern int kernel_getpeername(struct socket *sock, struct sockaddr *addr,
-			      int *addrlen);
-extern int kernel_getsockopt(struct socket *sock, int level, int optname,
-			     char *optval, int *optlen);
-extern int kernel_setsockopt(struct socket *sock, int level, int optname,
-			     char *optval, unsigned int optlen);
-extern int kernel_sendpage(struct socket *sock, struct page *page, int offset,
-			   size_t size, int flags);
-extern int kernel_sock_ioctl(struct socket *sock, int cmd, unsigned long arg);
-extern int kernel_sock_shutdown(struct socket *sock,
-				enum sock_shutdown_cmd how);
+int kernel_bind(struct socket *sock, struct sockaddr *addr, int addrlen);
+int kernel_listen(struct socket *sock, int backlog);
+int kernel_accept(struct socket *sock, struct socket **newsock, int flags);
+int kernel_connect(struct socket *sock, struct sockaddr *addr, int addrlen,
+		   int flags);
+int kernel_getsockname(struct socket *sock, struct sockaddr *addr,
+		       int *addrlen);
+int kernel_getpeername(struct socket *sock, struct sockaddr *addr,
+		       int *addrlen);
+int kernel_getsockopt(struct socket *sock, int level, int optname, char *optval,
+		      int *optlen);
+int kernel_setsockopt(struct socket *sock, int level, int optname, char *optval,
+		      unsigned int optlen);
+int kernel_sendpage(struct socket *sock, struct page *page, int offset,
+		    size_t size, int flags);
+int kernel_sock_ioctl(struct socket *sock, int cmd, unsigned long arg);
+int kernel_sock_shutdown(struct socket *sock, enum sock_shutdown_cmd how);
 
 #define MODULE_ALIAS_NETPROTO(proto) \
 	MODULE_ALIAS("net-pf-" __stringify(proto))
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 2ddb48d..6d56840 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -585,8 +585,8 @@ static inline void skb_dst_set(struct sk_buff *skb, struct dst_entry *dst)
 	skb->_skb_refdst = (unsigned long)dst;
 }
 
-extern void __skb_dst_set_noref(struct sk_buff *skb, struct dst_entry *dst,
-				bool force);
+void __skb_dst_set_noref(struct sk_buff *skb, struct dst_entry *dst,
+			 bool force);
 
 /**
  * skb_dst_set_noref - sets skb dst, hopefully, without taking reference
@@ -634,20 +634,20 @@ static inline struct rtable *skb_rtable(const struct sk_buff *skb)
 	return (struct rtable *)skb_dst(skb);
 }
 
-extern void kfree_skb(struct sk_buff *skb);
-extern void kfree_skb_list(struct sk_buff *segs);
-extern void skb_tx_error(struct sk_buff *skb);
-extern void consume_skb(struct sk_buff *skb);
-extern void	       __kfree_skb(struct sk_buff *skb);
+void kfree_skb(struct sk_buff *skb);
+void kfree_skb_list(struct sk_buff *segs);
+void skb_tx_error(struct sk_buff *skb);
+void consume_skb(struct sk_buff *skb);
+void  __kfree_skb(struct sk_buff *skb);
 extern struct kmem_cache *skbuff_head_cache;
 
-extern void kfree_skb_partial(struct sk_buff *skb, bool head_stolen);
-extern bool skb_try_coalesce(struct sk_buff *to, struct sk_buff *from,
-			     bool *fragstolen, int *delta_truesize);
+void kfree_skb_partial(struct sk_buff *skb, bool head_stolen);
+bool skb_try_coalesce(struct sk_buff *to, struct sk_buff *from,
+		      bool *fragstolen, int *delta_truesize);
 
-extern struct sk_buff *__alloc_skb(unsigned int size,
-				   gfp_t priority, int flags, int node);
-extern struct sk_buff *build_skb(void *data, unsigned int frag_size);
+struct sk_buff *__alloc_skb(unsigned int size, gfp_t priority, int flags,
+			    int node);
+struct sk_buff *build_skb(void *data, unsigned int frag_size);
 static inline struct sk_buff *alloc_skb(unsigned int size,
 					gfp_t priority)
 {
@@ -660,41 +660,33 @@ static inline struct sk_buff *alloc_skb_fclone(unsigned int size,
 	return __alloc_skb(size, priority, SKB_ALLOC_FCLONE, NUMA_NO_NODE);
 }
 
-extern struct sk_buff *__alloc_skb_head(gfp_t priority, int node);
+struct sk_buff *__alloc_skb_head(gfp_t priority, int node);
 static inline struct sk_buff *alloc_skb_head(gfp_t priority)
 {
 	return __alloc_skb_head(priority, -1);
 }
 
-extern struct sk_buff *skb_morph(struct sk_buff *dst, struct sk_buff *src);
-extern int skb_copy_ubufs(struct sk_buff *skb, gfp_t gfp_mask);
-extern struct sk_buff *skb_clone(struct sk_buff *skb,
-				 gfp_t priority);
-extern struct sk_buff *skb_copy(const struct sk_buff *skb,
-				gfp_t priority);
-extern struct sk_buff *__pskb_copy(struct sk_buff *skb,
-				 int headroom, gfp_t gfp_mask);
-
-extern int	       pskb_expand_head(struct sk_buff *skb,
-					int nhead, int ntail,
-					gfp_t gfp_mask);
-extern struct sk_buff *skb_realloc_headroom(struct sk_buff *skb,
-					    unsigned int headroom);
-extern struct sk_buff *skb_copy_expand(const struct sk_buff *skb,
-				       int newheadroom, int newtailroom,
-				       gfp_t priority);
-extern int	       skb_to_sgvec(struct sk_buff *skb,
-				    struct scatterlist *sg, int offset,
-				    int len);
-extern int	       skb_cow_data(struct sk_buff *skb, int tailbits,
-				    struct sk_buff **trailer);
-extern int	       skb_pad(struct sk_buff *skb, int pad);
+struct sk_buff *skb_morph(struct sk_buff *dst, struct sk_buff *src);
+int skb_copy_ubufs(struct sk_buff *skb, gfp_t gfp_mask);
+struct sk_buff *skb_clone(struct sk_buff *skb, gfp_t priority);
+struct sk_buff *skb_copy(const struct sk_buff *skb, gfp_t priority);
+struct sk_buff *__pskb_copy(struct sk_buff *skb, int headroom, gfp_t gfp_mask);
+
+int pskb_expand_head(struct sk_buff *skb, int nhead, int ntail, gfp_t gfp_mask);
+struct sk_buff *skb_realloc_headroom(struct sk_buff *skb,
+				     unsigned int headroom);
+struct sk_buff *skb_copy_expand(const struct sk_buff *skb, int newheadroom,
+				int newtailroom, gfp_t priority);
+int skb_to_sgvec(struct sk_buff *skb, struct scatterlist *sg, int offset,
+		 int len);
+int skb_cow_data(struct sk_buff *skb, int tailbits, struct sk_buff **trailer);
+int skb_pad(struct sk_buff *skb, int pad);
 #define dev_kfree_skb(a)	consume_skb(a)
 
-extern int skb_append_datato_frags(struct sock *sk, struct sk_buff *skb,
-			int getfrag(void *from, char *to, int offset,
-			int len,int odd, struct sk_buff *skb),
-			void *from, int length);
+int skb_append_datato_frags(struct sock *sk, struct sk_buff *skb,
+			    int getfrag(void *from, char *to, int offset,
+					int len, int odd, struct sk_buff *skb),
+			    void *from, int length);
 
 struct skb_seq_state {
 	__u32		lower_offset;
@@ -706,18 +698,17 @@ struct skb_seq_state {
 	__u8		*frag_data;
 };
 
-extern void	      skb_prepare_seq_read(struct sk_buff *skb,
-					   unsigned int from, unsigned int to,
-					   struct skb_seq_state *st);
-extern unsigned int   skb_seq_read(unsigned int consumed, const u8 **data,
-				   struct skb_seq_state *st);
-extern void	      skb_abort_seq_read(struct skb_seq_state *st);
+void skb_prepare_seq_read(struct sk_buff *skb, unsigned int from,
+			  unsigned int to, struct skb_seq_state *st);
+unsigned int skb_seq_read(unsigned int consumed, const u8 **data,
+			  struct skb_seq_state *st);
+void skb_abort_seq_read(struct skb_seq_state *st);
 
-extern unsigned int   skb_find_text(struct sk_buff *skb, unsigned int from,
-				    unsigned int to, struct ts_config *config,
-				    struct ts_state *state);
+unsigned int skb_find_text(struct sk_buff *skb, unsigned int from,
+			   unsigned int to, struct ts_config *config,
+			   struct ts_state *state);
 
-extern void __skb_get_rxhash(struct sk_buff *skb);
+void __skb_get_rxhash(struct sk_buff *skb);
 static inline __u32 skb_get_rxhash(struct sk_buff *skb)
 {
 	if (!skb->l4_rxhash)
@@ -1095,7 +1086,8 @@ static inline void skb_queue_head_init_class(struct sk_buff_head *list,
  *	The "__skb_xxxx()" functions are the non-atomic ones that
  *	can only be called with interrupts disabled.
  */
-extern void        skb_insert(struct sk_buff *old, struct sk_buff *newsk, struct sk_buff_head *list);
+void skb_insert(struct sk_buff *old, struct sk_buff *newsk,
+		struct sk_buff_head *list);
 static inline void __skb_insert(struct sk_buff *newsk,
 				struct sk_buff *prev, struct sk_buff *next,
 				struct sk_buff_head *list)
@@ -1201,8 +1193,8 @@ static inline void __skb_queue_after(struct sk_buff_head *list,
 	__skb_insert(newsk, prev, prev->next, list);
 }
 
-extern void skb_append(struct sk_buff *old, struct sk_buff *newsk,
-		       struct sk_buff_head *list);
+void skb_append(struct sk_buff *old, struct sk_buff *newsk,
+		struct sk_buff_head *list);
 
 static inline void __skb_queue_before(struct sk_buff_head *list,
 				      struct sk_buff *next,
@@ -1221,7 +1213,7 @@ static inline void __skb_queue_before(struct sk_buff_head *list,
  *
  *	A buffer cannot be placed on two lists at the same time.
  */
-extern void skb_queue_head(struct sk_buff_head *list, struct sk_buff *newsk);
+void skb_queue_head(struct sk_buff_head *list, struct sk_buff *newsk);
 static inline void __skb_queue_head(struct sk_buff_head *list,
 				    struct sk_buff *newsk)
 {
@@ -1238,7 +1230,7 @@ static inline void __skb_queue_head(struct sk_buff_head *list,
  *
  *	A buffer cannot be placed on two lists at the same time.
  */
-extern void skb_queue_tail(struct sk_buff_head *list, struct sk_buff *newsk);
+void skb_queue_tail(struct sk_buff_head *list, struct sk_buff *newsk);
 static inline void __skb_queue_tail(struct sk_buff_head *list,
 				   struct sk_buff *newsk)
 {
@@ -1249,7 +1241,7 @@ static inline void __skb_queue_tail(struct sk_buff_head *list,
  * remove sk_buff from list. _Must_ be called atomically, and with
  * the list known..
  */
-extern void	   skb_unlink(struct sk_buff *skb, struct sk_buff_head *list);
+void skb_unlink(struct sk_buff *skb, struct sk_buff_head *list);
 static inline void __skb_unlink(struct sk_buff *skb, struct sk_buff_head *list)
 {
 	struct sk_buff *next, *prev;
@@ -1270,7 +1262,7 @@ static inline void __skb_unlink(struct sk_buff *skb, struct sk_buff_head *list)
  *	so must be used with appropriate locks held only. The head item is
  *	returned or %NULL if the list is empty.
  */
-extern struct sk_buff *skb_dequeue(struct sk_buff_head *list);
+struct sk_buff *skb_dequeue(struct sk_buff_head *list);
 static inline struct sk_buff *__skb_dequeue(struct sk_buff_head *list)
 {
 	struct sk_buff *skb = skb_peek(list);
@@ -1287,7 +1279,7 @@ static inline struct sk_buff *__skb_dequeue(struct sk_buff_head *list)
  *	so must be used with appropriate locks held only. The tail item is
  *	returned or %NULL if the list is empty.
  */
-extern struct sk_buff *skb_dequeue_tail(struct sk_buff_head *list);
+struct sk_buff *skb_dequeue_tail(struct sk_buff_head *list);
 static inline struct sk_buff *__skb_dequeue_tail(struct sk_buff_head *list)
 {
 	struct sk_buff *skb = skb_peek_tail(list);
@@ -1373,8 +1365,8 @@ static inline void skb_fill_page_desc(struct sk_buff *skb, int i,
 	skb_shinfo(skb)->nr_frags = i + 1;
 }
 
-extern void skb_add_rx_frag(struct sk_buff *skb, int i, struct page *page,
-			    int off, int size, unsigned int truesize);
+void skb_add_rx_frag(struct sk_buff *skb, int i, struct page *page, int off,
+		     int size, unsigned int truesize);
 
 #define SKB_PAGE_ASSERT(skb) 	BUG_ON(skb_shinfo(skb)->nr_frags)
 #define SKB_FRAG_ASSERT(skb) 	BUG_ON(skb_has_frag_list(skb))
@@ -1418,7 +1410,7 @@ static inline void skb_set_tail_pointer(struct sk_buff *skb, const int offset)
 /*
  *	Add data to an sk_buff
  */
-extern unsigned char *skb_put(struct sk_buff *skb, unsigned int len);
+unsigned char *skb_put(struct sk_buff *skb, unsigned int len);
 static inline unsigned char *__skb_put(struct sk_buff *skb, unsigned int len)
 {
 	unsigned char *tmp = skb_tail_pointer(skb);
@@ -1428,7 +1420,7 @@ static inline unsigned char *__skb_put(struct sk_buff *skb, unsigned int len)
 	return tmp;
 }
 
-extern unsigned char *skb_push(struct sk_buff *skb, unsigned int len);
+unsigned char *skb_push(struct sk_buff *skb, unsigned int len);
 static inline unsigned char *__skb_push(struct sk_buff *skb, unsigned int len)
 {
 	skb->data -= len;
@@ -1436,7 +1428,7 @@ static inline unsigned char *__skb_push(struct sk_buff *skb, unsigned int len)
 	return skb->data;
 }
 
-extern unsigned char *skb_pull(struct sk_buff *skb, unsigned int len);
+unsigned char *skb_pull(struct sk_buff *skb, unsigned int len);
 static inline unsigned char *__skb_pull(struct sk_buff *skb, unsigned int len)
 {
 	skb->len -= len;
@@ -1449,7 +1441,7 @@ static inline unsigned char *skb_pull_inline(struct sk_buff *skb, unsigned int l
 	return unlikely(len > skb->len) ? NULL : __skb_pull(skb, len);
 }
 
-extern unsigned char *__pskb_pull_tail(struct sk_buff *skb, int delta);
+unsigned char *__pskb_pull_tail(struct sk_buff *skb, int delta);
 
 static inline unsigned char *__pskb_pull(struct sk_buff *skb, unsigned int len)
 {
@@ -1753,7 +1745,7 @@ static inline int pskb_network_may_pull(struct sk_buff *skb, unsigned int len)
 #define NET_SKB_PAD	max(32, L1_CACHE_BYTES)
 #endif
 
-extern int ___pskb_trim(struct sk_buff *skb, unsigned int len);
+int ___pskb_trim(struct sk_buff *skb, unsigned int len);
 
 static inline void __skb_trim(struct sk_buff *skb, unsigned int len)
 {
@@ -1765,7 +1757,7 @@ static inline void __skb_trim(struct sk_buff *skb, unsigned int len)
 	skb_set_tail_pointer(skb, len);
 }
 
-extern void skb_trim(struct sk_buff *skb, unsigned int len);
+void skb_trim(struct sk_buff *skb, unsigned int len);
 
 static inline int __pskb_trim(struct sk_buff *skb, unsigned int len)
 {
@@ -1838,7 +1830,7 @@ static inline int skb_orphan_frags(struct sk_buff *skb, gfp_t gfp_mask)
  *	the list and one reference dropped. This function does not take the
  *	list lock and the caller must hold the relevant locks to use it.
  */
-extern void skb_queue_purge(struct sk_buff_head *list);
+void skb_queue_purge(struct sk_buff_head *list);
 static inline void __skb_queue_purge(struct sk_buff_head *list)
 {
 	struct sk_buff *skb;
@@ -1850,11 +1842,10 @@ static inline void __skb_queue_purge(struct sk_buff_head *list)
 #define NETDEV_FRAG_PAGE_MAX_SIZE  (PAGE_SIZE << NETDEV_FRAG_PAGE_MAX_ORDER)
 #define NETDEV_PAGECNT_MAX_BIAS	   NETDEV_FRAG_PAGE_MAX_SIZE
 
-extern void *netdev_alloc_frag(unsigned int fragsz);
+void *netdev_alloc_frag(unsigned int fragsz);
 
-extern struct sk_buff *__netdev_alloc_skb(struct net_device *dev,
-					  unsigned int length,
-					  gfp_t gfp_mask);
+struct sk_buff *__netdev_alloc_skb(struct net_device *dev, unsigned int length,
+				   gfp_t gfp_mask);
 
 /**
  *	netdev_alloc_skb - allocate an skbuff for rx on a specific device
@@ -2342,60 +2333,42 @@ static inline void skb_frag_add_head(struct sk_buff *skb, struct sk_buff *frag)
 #define skb_walk_frags(skb, iter)	\
 	for (iter = skb_shinfo(skb)->frag_list; iter; iter = iter->next)
 
-extern struct sk_buff *__skb_recv_datagram(struct sock *sk, unsigned flags,
-					   int *peeked, int *off, int *err);
-extern struct sk_buff *skb_recv_datagram(struct sock *sk, unsigned flags,
-					 int noblock, int *err);
-extern unsigned int    datagram_poll(struct file *file, struct socket *sock,
-				     struct poll_table_struct *wait);
-extern int	       skb_copy_datagram_iovec(const struct sk_buff *from,
-					       int offset, struct iovec *to,
-					       int size);
-extern int	       skb_copy_and_csum_datagram_iovec(struct sk_buff *skb,
-							int hlen,
-							struct iovec *iov);
-extern int	       skb_copy_datagram_from_iovec(struct sk_buff *skb,
-						    int offset,
-						    const struct iovec *from,
-						    int from_offset,
-						    int len);
-extern int	       zerocopy_sg_from_iovec(struct sk_buff *skb,
-					      const struct iovec *frm,
-					      int offset,
-					      size_t count);
-extern int	       skb_copy_datagram_const_iovec(const struct sk_buff *from,
-						     int offset,
-						     const struct iovec *to,
-						     int to_offset,
-						     int size);
-extern void	       skb_free_datagram(struct sock *sk, struct sk_buff *skb);
-extern void	       skb_free_datagram_locked(struct sock *sk,
-						struct sk_buff *skb);
-extern int	       skb_kill_datagram(struct sock *sk, struct sk_buff *skb,
-					 unsigned int flags);
-extern __wsum	       skb_checksum(const struct sk_buff *skb, int offset,
-				    int len, __wsum csum);
-extern int	       skb_copy_bits(const struct sk_buff *skb, int offset,
-				     void *to, int len);
-extern int	       skb_store_bits(struct sk_buff *skb, int offset,
-				      const void *from, int len);
-extern __wsum	       skb_copy_and_csum_bits(const struct sk_buff *skb,
-					      int offset, u8 *to, int len,
-					      __wsum csum);
-extern int             skb_splice_bits(struct sk_buff *skb,
-						unsigned int offset,
-						struct pipe_inode_info *pipe,
-						unsigned int len,
-						unsigned int flags);
-extern void	       skb_copy_and_csum_dev(const struct sk_buff *skb, u8 *to);
-extern void	       skb_split(struct sk_buff *skb,
-				 struct sk_buff *skb1, const u32 len);
-extern int	       skb_shift(struct sk_buff *tgt, struct sk_buff *skb,
-				 int shiftlen);
-extern void	       skb_scrub_packet(struct sk_buff *skb, bool xnet);
-
-extern struct sk_buff *skb_segment(struct sk_buff *skb,
-				   netdev_features_t features);
+struct sk_buff *__skb_recv_datagram(struct sock *sk, unsigned flags,
+				    int *peeked, int *off, int *err);
+struct sk_buff *skb_recv_datagram(struct sock *sk, unsigned flags, int noblock,
+				  int *err);
+unsigned int datagram_poll(struct file *file, struct socket *sock,
+			   struct poll_table_struct *wait);
+int skb_copy_datagram_iovec(const struct sk_buff *from, int offset,
+			    struct iovec *to, int size);
+int skb_copy_and_csum_datagram_iovec(struct sk_buff *skb, int hlen,
+				     struct iovec *iov);
+int skb_copy_datagram_from_iovec(struct sk_buff *skb, int offset,
+				 const struct iovec *from, int from_offset,
+				 int len);
+int zerocopy_sg_from_iovec(struct sk_buff *skb, const struct iovec *frm,
+			   int offset, size_t count);
+int skb_copy_datagram_const_iovec(const struct sk_buff *from, int offset,
+				  const struct iovec *to, int to_offset,
+				  int size);
+void skb_free_datagram(struct sock *sk, struct sk_buff *skb);
+void skb_free_datagram_locked(struct sock *sk, struct sk_buff *skb);
+int skb_kill_datagram(struct sock *sk, struct sk_buff *skb, unsigned int flags);
+__wsum skb_checksum(const struct sk_buff *skb, int offset, int len,
+		    __wsum csum);
+int skb_copy_bits(const struct sk_buff *skb, int offset, void *to, int len);
+int skb_store_bits(struct sk_buff *skb, int offset, const void *from, int len);
+__wsum skb_copy_and_csum_bits(const struct sk_buff *skb, int offset, u8 *to,
+			      int len, __wsum csum);
+int skb_splice_bits(struct sk_buff *skb, unsigned int offset,
+		    struct pipe_inode_info *pipe, unsigned int len,
+		    unsigned int flags);
+void skb_copy_and_csum_dev(const struct sk_buff *skb, u8 *to);
+void skb_split(struct sk_buff *skb, struct sk_buff *skb1, const u32 len);
+int skb_shift(struct sk_buff *tgt, struct sk_buff *skb, int shiftlen);
+void skb_scrub_packet(struct sk_buff *skb, bool xnet);
+
+struct sk_buff *skb_segment(struct sk_buff *skb, netdev_features_t features);
 
 static inline void *skb_header_pointer(const struct sk_buff *skb, int offset,
 				       int len, void *buffer)
@@ -2440,7 +2413,7 @@ static inline void skb_copy_to_linear_data_offset(struct sk_buff *skb,
 	memcpy(skb->data + offset, from, len);
 }
 
-extern void skb_init(void);
+void skb_init(void);
 
 static inline ktime_t skb_get_ktime(const struct sk_buff *skb)
 {
@@ -2483,12 +2456,12 @@ static inline ktime_t net_invalid_timestamp(void)
 	return ktime_set(0, 0);
 }
 
-extern void skb_timestamping_init(void);
+void skb_timestamping_init(void);
 
 #ifdef CONFIG_NETWORK_PHY_TIMESTAMPING
 
-extern void skb_clone_tx_timestamp(struct sk_buff *skb);
-extern bool skb_defer_rx_timestamp(struct sk_buff *skb);
+void skb_clone_tx_timestamp(struct sk_buff *skb);
+bool skb_defer_rx_timestamp(struct sk_buff *skb);
 
 #else /* CONFIG_NETWORK_PHY_TIMESTAMPING */
 
@@ -2529,8 +2502,8 @@ void skb_complete_tx_timestamp(struct sk_buff *skb,
  * generates a software time stamp (otherwise), then queues the clone
  * to the error queue of the socket.  Errors are silently ignored.
  */
-extern void skb_tstamp_tx(struct sk_buff *orig_skb,
-			struct skb_shared_hwtstamps *hwtstamps);
+void skb_tstamp_tx(struct sk_buff *orig_skb,
+		   struct skb_shared_hwtstamps *hwtstamps);
 
 static inline void sw_tx_timestamp(struct sk_buff *skb)
 {
@@ -2562,8 +2535,8 @@ static inline void skb_tx_timestamp(struct sk_buff *skb)
  */
 void skb_complete_wifi_ack(struct sk_buff *skb, bool acked);
 
-extern __sum16 __skb_checksum_complete_head(struct sk_buff *skb, int len);
-extern __sum16 __skb_checksum_complete(struct sk_buff *skb);
+__sum16 __skb_checksum_complete_head(struct sk_buff *skb, int len);
+__sum16 __skb_checksum_complete(struct sk_buff *skb);
 
 static inline int skb_csum_unnecessary(const struct sk_buff *skb)
 {
@@ -2593,7 +2566,7 @@ static inline __sum16 skb_checksum_complete(struct sk_buff *skb)
 }
 
 #if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE)
-extern void nf_conntrack_destroy(struct nf_conntrack *nfct);
+void nf_conntrack_destroy(struct nf_conntrack *nfct);
 static inline void nf_conntrack_put(struct nf_conntrack *nfct)
 {
 	if (nfct && atomic_dec_and_test(&nfct->use))
@@ -2732,9 +2705,8 @@ static inline bool skb_rx_queue_recorded(const struct sk_buff *skb)
 	return skb->queue_mapping != 0;
 }
 
-extern u16 __skb_tx_hash(const struct net_device *dev,
-			 const struct sk_buff *skb,
-			 unsigned int num_tx_queues);
+u16 __skb_tx_hash(const struct net_device *dev, const struct sk_buff *skb,
+		  unsigned int num_tx_queues);
 
 #ifdef CONFIG_XFRM
 static inline struct sec_path *skb_sec_path(struct sk_buff *skb)
@@ -2788,7 +2760,7 @@ static inline bool skb_is_gso_v6(const struct sk_buff *skb)
 	return skb_shinfo(skb)->gso_type & SKB_GSO_TCPV6;
 }
 
-extern void __skb_warn_lro_forwarding(const struct sk_buff *skb);
+void __skb_warn_lro_forwarding(const struct sk_buff *skb);
 
 static inline bool skb_warn_if_lro(const struct sk_buff *skb)
 {
-- 
1.8.1.2.459.gbcd45b4.dirty
