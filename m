From: Mahesh Bandewar <maheshb@google.com>
Subject: [PATCH 3/9] net-core: Convert (hw_/vlan_/wanted_)features fields from u32 type to u64.
Date: Fri, 22 Apr 2011 16:36:01 -0700
Message-ID: <1303515367-25595-4-git-send-email-maheshb@google.com>
References: <1303515367-25595-1-git-send-email-maheshb@google.com>
 <1303515367-25595-2-git-send-email-maheshb@google.com>
 <1303515367-25595-3-git-send-email-maheshb@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Mahesh Bandewar <maheshb@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:36005 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757018Ab1DVXgR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Apr 2011 19:36:17 -0400
In-Reply-To: <1303515367-25595-3-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Mahesh Bandewar <maheshb@google.com>
---
 include/linux/skbuff.h |    2 +-
 include/net/protocol.h |    4 ++--
 include/net/sock.h     |    8 ++++----
 net/core/skbuff.c      |    2 +-
 4 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index d0ae90a..5174846 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1880,7 +1880,7 @@ extern void	       skb_split(struct sk_buff *skb,
 extern int	       skb_shift(struct sk_buff *tgt, struct sk_buff *skb,
 				 int shiftlen);
 
-extern struct sk_buff *skb_segment(struct sk_buff *skb, u32 features);
+extern struct sk_buff *skb_segment(struct sk_buff *skb, u64 features);
 
 static inline void *skb_header_pointer(const struct sk_buff *skb, int offset,
 				       int len, void *buffer)
diff --git a/include/net/protocol.h b/include/net/protocol.h
index 6f7eb80..6451e27 100644
--- a/include/net/protocol.h
+++ b/include/net/protocol.h
@@ -38,7 +38,7 @@ struct net_protocol {
 	void			(*err_handler)(struct sk_buff *skb, u32 info);
 	int			(*gso_send_check)(struct sk_buff *skb);
 	struct sk_buff	       *(*gso_segment)(struct sk_buff *skb,
-					       u32 features);
+					       u64 features);
 	struct sk_buff	      **(*gro_receive)(struct sk_buff **head,
 					       struct sk_buff *skb);
 	int			(*gro_complete)(struct sk_buff *skb);
@@ -57,7 +57,7 @@ struct inet6_protocol {
 
 	int	(*gso_send_check)(struct sk_buff *skb);
 	struct sk_buff *(*gso_segment)(struct sk_buff *skb,
-				       u32 features);
+				       u64 features);
 	struct sk_buff **(*gro_receive)(struct sk_buff **head,
 					struct sk_buff *skb);
 	int	(*gro_complete)(struct sk_buff *skb);
diff --git a/include/net/sock.h b/include/net/sock.h
index f2046e4..8a0a3fe 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -307,8 +307,8 @@ struct sock {
 	kmemcheck_bitfield_end(flags);
 	int			sk_wmem_queued;
 	gfp_t			sk_allocation;
-	int			sk_route_caps;
-	int			sk_route_nocaps;
+	u64			sk_route_caps;
+	u64			sk_route_nocaps;
 	int			sk_gso_type;
 	unsigned int		sk_gso_max_size;
 	int			sk_rcvlowat;
@@ -1377,14 +1377,14 @@ extern struct dst_entry *__sk_dst_check(struct sock *sk, u32 cookie);
 
 extern struct dst_entry *sk_dst_check(struct sock *sk, u32 cookie);
 
-static inline int sk_can_gso(const struct sock *sk)
+static inline u64 sk_can_gso(const struct sock *sk)
 {
 	return net_gso_ok(sk->sk_route_caps, sk->sk_gso_type);
 }
 
 extern void sk_setup_caps(struct sock *sk, struct dst_entry *dst);
 
-static inline void sk_nocaps_add(struct sock *sk, int flags)
+static inline void sk_nocaps_add(struct sock *sk, u64 flags)
 {
 	sk->sk_route_nocaps |= flags;
 	sk->sk_route_caps &= ~flags;
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 7ebeed0..0d748cc 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -2494,7 +2494,7 @@ EXPORT_SYMBOL_GPL(skb_pull_rcsum);
  *	a pointer to the first in a list of new skbs for the segments.
  *	In case of error it returns ERR_PTR(err).
  */
-struct sk_buff *skb_segment(struct sk_buff *skb, u32 features)
+struct sk_buff *skb_segment(struct sk_buff *skb, u64 features)
 {
 	struct sk_buff *segs = NULL;
 	struct sk_buff *tail = NULL;
-- 
1.7.3.1

