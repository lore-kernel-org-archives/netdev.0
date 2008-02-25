From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: [PATCH] tipc: fix integer as NULL pointer sparse warnings in tipc
Date: Sun, 24 Feb 2008 17:59:05 -0800
Message-ID: <1203904745.1767.19.camel@brick>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-netdev <netdev@vger.kernel.org>
To: Jeff Garzik <jeff@garzik.org>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from el-out-1112.google.com ([209.85.162.182]:44060 "EHLO
	el-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752326AbYBYB7B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Feb 2008 20:59:01 -0500
Received: by el-out-1112.google.com with SMTP id v27so1104323ele.23
        for <netdev@vger.kernel.org>; Sun, 24 Feb 2008 17:59:00 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

net/tipc/cluster.c:145:2: warning: Using plain integer as NULL pointer
net/tipc/link.c:3254:36: warning: Using plain integer as NULL pointer
net/tipc/ref.c:151:15: warning: Using plain integer as NULL pointer
net/tipc/zone.c:85:2: warning: Using plain integer as NULL pointer

Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
---
 net/tipc/cluster.c |    2 +-
 net/tipc/link.c    |    2 +-
 net/tipc/ref.c     |    2 +-
 net/tipc/zone.c    |    2 +-
 4 files changed, 4 insertions(+), 4 deletions(-)

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
1.5.4.2.200.g99e75



