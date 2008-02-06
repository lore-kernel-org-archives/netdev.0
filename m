From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: [patch 06/14] replace __inline__ by inline in net/decnet
Date: Wed, 06 Feb 2008 10:14:11 +0100
Message-ID: <20080206092131.776617162@mai.toulouse-stg.fr.ibm.com>
References: <20080206091405.581849582@mai.toulouse-stg.fr.ibm.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate1.de.ibm.com ([195.212.29.150]:19808 "EHLO
	mtagate1.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760430AbYBFJ1D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Feb 2008 04:27:03 -0500
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate1.de.ibm.com (8.13.8/8.13.8) with ESMTP id m169R2oK034388
	for <netdev@vger.kernel.org>; Wed, 6 Feb 2008 09:27:02 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m169R2tX2105428
	for <netdev@vger.kernel.org>; Wed, 6 Feb 2008 10:27:02 +0100
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m169R18b001442
	for <netdev@vger.kernel.org>; Wed, 6 Feb 2008 10:27:02 +0100
Content-Disposition: inline; filename=remove-__inline__-in-decnet.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

replace __inline__ by inline in net/decnet

Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
---
 net/decnet/dn_dev.c     |    2 +-
 net/decnet/dn_nsp_in.c  |    3 ++-
 net/decnet/dn_nsp_out.c |    9 +++++----
 net/decnet/dn_route.c   |    2 +-
 net/decnet/dn_table.c   |   18 +++++++++---------
 5 files changed, 18 insertions(+), 16 deletions(-)

Index: net-2.6/net/decnet/dn_dev.c
===================================================================
--- net-2.6.orig/net/decnet/dn_dev.c
+++ net-2.6/net/decnet/dn_dev.c
@@ -390,7 +390,7 @@ static struct dn_ifaddr *dn_dev_alloc_if
 	return ifa;
 }
 
-static __inline__ void dn_dev_free_ifa(struct dn_ifaddr *ifa)
+static inline void dn_dev_free_ifa(struct dn_ifaddr *ifa)
 {
 	kfree(ifa);
 }
Index: net-2.6/net/decnet/dn_nsp_in.c
===================================================================
--- net-2.6.orig/net/decnet/dn_nsp_in.c
+++ net-2.6/net/decnet/dn_nsp_in.c
@@ -573,7 +573,8 @@ out:
  * bh_lock_sock() (its already held when this is called) which
  * also allows data and other data to be queued to a socket.
  */
-static __inline__ int dn_queue_skb(struct sock *sk, struct sk_buff *skb, int sig, struct sk_buff_head *queue)
+static inline int dn_queue_skb(struct sock *sk, struct sk_buff *skb,
+			       int sig, struct sk_buff_head *queue)
 {
 	int err;
 
Index: net-2.6/net/decnet/dn_nsp_out.c
===================================================================
--- net-2.6.orig/net/decnet/dn_nsp_out.c
+++ net-2.6/net/decnet/dn_nsp_out.c
@@ -549,10 +549,11 @@ void dn_send_conn_conf(struct sock *sk, 
 }
 
 
-static __inline__ void dn_nsp_do_disc(struct sock *sk, unsigned char msgflg,
-			unsigned short reason, gfp_t gfp,
-			struct dst_entry *dst,
-			int ddl, unsigned char *dd, __le16 rem, __le16 loc)
+static inline void dn_nsp_do_disc(struct sock *sk, unsigned char msgflg,
+				  unsigned short reason, gfp_t gfp,
+				  struct dst_entry *dst,
+				  int ddl, unsigned char *dd, __le16 rem,
+				  __le16 loc)
 {
 	struct sk_buff *skb = NULL;
 	int size = 7 + ddl + ((msgflg == NSP_DISCINIT) ? 1 : 0);
Index: net-2.6/net/decnet/dn_route.c
===================================================================
--- net-2.6.orig/net/decnet/dn_route.c
+++ net-2.6/net/decnet/dn_route.c
@@ -135,7 +135,7 @@ static struct dst_ops dn_dst_ops = {
 	.entries =		ATOMIC_INIT(0),
 };
 
-static __inline__ unsigned dn_hash(__le16 src, __le16 dst)
+static inline unsigned dn_hash(__le16 src, __le16 dst)
 {
 	__u16 tmp = (__u16 __force)(src ^ dst);
 	tmp ^= (tmp >> 3);
Index: net-2.6/net/decnet/dn_table.c
===================================================================
--- net-2.6.orig/net/decnet/dn_table.c
+++ net-2.6/net/decnet/dn_table.c
@@ -381,11 +381,11 @@ errout:
 		rtnl_set_sk_err(&init_net, RTNLGRP_DECnet_ROUTE, err);
 }
 
-static __inline__ int dn_hash_dump_bucket(struct sk_buff *skb,
-				struct netlink_callback *cb,
-				struct dn_fib_table *tb,
-				struct dn_zone *dz,
-				struct dn_fib_node *f)
+static inline int dn_hash_dump_bucket(struct sk_buff *skb,
+				      struct netlink_callback *cb,
+				      struct dn_fib_table *tb,
+				      struct dn_zone *dz,
+				      struct dn_fib_node *f)
 {
 	int i, s_i;
 
@@ -410,10 +410,10 @@ static __inline__ int dn_hash_dump_bucke
 	return skb->len;
 }
 
-static __inline__ int dn_hash_dump_zone(struct sk_buff *skb,
-				struct netlink_callback *cb,
-				struct dn_fib_table *tb,
-				struct dn_zone *dz)
+static inline int dn_hash_dump_zone(struct sk_buff *skb,
+				    struct netlink_callback *cb,
+				    struct dn_fib_table *tb,
+				    struct dn_zone *dz)
 {
 	int h, s_h;
 

-- 
