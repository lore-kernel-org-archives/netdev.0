From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] neigh: reorder fields in struct neighbour
Date: Thu, 30 Sep 2010 17:36:29 +0200
Message-ID: <1285860989.2615.650.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:36258 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932082Ab0I3Pgg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Sep 2010 11:36:36 -0400
Received: by fxm4 with SMTP id 4so811809fxm.19
        for <netdev@vger.kernel.org>; Thu, 30 Sep 2010 08:36:35 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 64bit arches, there are two 32bit holes that we can remove.

sizeof(struct neighbour) shrinks from 0xf8 to 0xf0 bytes

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/net/neighbour.h |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/include/net/neighbour.h b/include/net/neighbour.h
index 242879b..7d08fd1 100644
--- a/include/net/neighbour.h
+++ b/include/net/neighbour.h
@@ -94,7 +94,7 @@ struct neighbour {
 	struct neighbour	*next;
 	struct neigh_table	*tbl;
 	struct neigh_parms	*parms;
-	struct net_device		*dev;
+	struct net_device	*dev;
 	unsigned long		used;
 	unsigned long		confirmed;
 	unsigned long		updated;
@@ -102,11 +102,11 @@ struct neighbour {
 	__u8			nud_state;
 	__u8			type;
 	__u8			dead;
+	atomic_t		refcnt;
 	atomic_t		probes;
 	rwlock_t		lock;
 	unsigned char		ha[ALIGN(MAX_ADDR_LEN, sizeof(unsigned long))];
 	struct hh_cache		*hh;
-	atomic_t		refcnt;
 	int			(*output)(struct sk_buff *skb);
 	struct sk_buff_head	arp_queue;
 	struct timer_list	timer;
@@ -163,7 +163,7 @@ struct neigh_table {
 	atomic_t		entries;
 	rwlock_t		lock;
 	unsigned long		last_rand;
-	struct kmem_cache		*kmem_cachep;
+	struct kmem_cache	*kmem_cachep;
 	struct neigh_statistics	__percpu *stats;
 	struct neighbour	**hash_buckets;
 	unsigned int		hash_mask;


