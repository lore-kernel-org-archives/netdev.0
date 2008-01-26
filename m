From: Florian Westphal <fw@strlen.de>
Subject: [PATCH] [TIPC]: Supress minor sparse warnings.
Date: Sat, 26 Jan 2008 03:07:13 +0100
Message-ID: <1201313233-32733-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>,
	Allan Stephens <allan.stephens@windriver.com>,
	Jon Paul Maloy <jon.maloy@ericsson.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:32963 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758563AbYAZCDx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jan 2008 21:03:53 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

cluster.c:145:2: warning: Using plain integer as NULL pointer
link.c:3254:36: warning: Using plain integer as NULL pointer
ref.c:151:15: warning: Using plain integer as NULL pointer
socket.c:91:13: warning: context imbalance in 'sock_lock' - wrong count at exit
socket.c:99:13: warning: context imbalance in 'sock_unlock' - unexpected unlock

CC: Allan Stephens <allan.stephens@windriver.com>
CC: Jon Paul Maloy <jon.maloy@ericsson.com>
Signed-off-by: Florian Westphal <fw@strlen.de>
---
 net/tipc/cluster.c |    2 +-
 net/tipc/link.c    |    2 +-
 net/tipc/ref.c     |    2 +-
 net/tipc/socket.c  |    2 ++
 net/tipc/zone.c    |    2 +-
 5 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/net/tipc/cluster.c b/net/tipc/cluster.c
index 95b3739..4bb3404 100644
--- a/net/tipc/cluster.c
+++ b/net/tipc/cluster.c
@@ -142,7 +142,7 @@ void tipc_cltr_attach_node(struct cluster *c_ptr, struct node *n_ptr)
 		max_n_num = tipc_highest_allowed_slave;
 	assert(n_num > 0);
 	assert(n_num <= max_n_num);
-	assert(c_ptr->nodes[n_num] == 0);
+	assert(c_ptr->nodes[n_num] == NULL);
 	c_ptr->nodes[n_num] = n_ptr;
 	if (n_num > c_ptr->highest_node)
 		c_ptr->highest_node = n_num;
diff --git a/net/tipc/link.c b/net/tipc/link.c
index 1b17fec..cefa998 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -3251,7 +3251,7 @@ static void link_print(struct link *l_ptr, struct print_buf *buf,
 		if ((mod(msg_seqno(buf_msg(l_ptr->last_out)) -
 			 msg_seqno(buf_msg(l_ptr->first_out)))
 		     != (l_ptr->out_queue_size - 1))
-		    || (l_ptr->last_out->next != 0)) {
+		    || (l_ptr->last_out->next != NULL)) {
 			tipc_printf(buf, "\nSend queue inconsistency\n");
 			tipc_printf(buf, "first_out= %x ", l_ptr->first_out);
 			tipc_printf(buf, "next_out= %x ", l_ptr->next_out);
diff --git a/net/tipc/ref.c b/net/tipc/ref.c
index 6704a58..c38744c 100644
--- a/net/tipc/ref.c
+++ b/net/tipc/ref.c
@@ -148,7 +148,7 @@ u32 tipc_ref_acquire(void *object, spinlock_t **lock)
 		reference = (next_plus_upper & ~index_mask) + index;
 		entry->data.reference = reference;
 		entry->object = object;
-		if (lock != 0)
+		if (lock != NULL)
 			*lock = &entry->lock;
 		spin_unlock_bh(&entry->lock);
 	}
diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 2290903..26ea0a6 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -89,6 +89,7 @@ static atomic_t tipc_queue_size = ATOMIC_INIT(0);
  * See net.c for description of locking policy.
  */
 static void sock_lock(struct tipc_sock* tsock)
+__acquires(tsock->p->lock)
 {
 	spin_lock_bh(tsock->p->lock);
 }
@@ -97,6 +98,7 @@ static void sock_lock(struct tipc_sock* tsock)
  * sock_unlock(): Unlock a port/socket pair
  */
 static void sock_unlock(struct tipc_sock* tsock)
+__releases(tsock->p->lock)
 {
 	spin_unlock_bh(tsock->p->lock);
 }
diff --git a/net/tipc/zone.c b/net/tipc/zone.c
index 114e173..3506f85 100644
--- a/net/tipc/zone.c
+++ b/net/tipc/zone.c
@@ -82,7 +82,7 @@ void tipc_zone_attach_cluster(struct _zone *z_ptr, struct cluster *c_ptr)
 
 	assert(c_ptr->addr);
 	assert(c_num <= tipc_max_clusters);
-	assert(z_ptr->clusters[c_num] == 0);
+	assert(z_ptr->clusters[c_num] == NULL);
 	z_ptr->clusters[c_num] = c_ptr;
 }
 
-- 
1.5.3.7

