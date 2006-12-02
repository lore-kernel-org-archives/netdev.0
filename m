From: Florian Westphal <fw-kernel@strlen.de>
Subject: [patch] net/tipc: kmalloc/kzalloc conversion
Date: Sat, 2 Dec 2006 12:09:44 +0100
Message-ID: <20061202110944.GA15887@Chamillionaire.breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, tipc-discussion@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:51934 "EHLO
	Chamillionaire.breakpoint.cc") by vger.kernel.org with ESMTP
	id S1162219AbWLBLLj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 2 Dec 2006 06:11:39 -0500
To: kernel-janitors@lists.osdl.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Westphal <fw@strlen.de>

convert kmalloc/memset to kzalloc.

Signed-off-by: Florian Westphal <fw@strlen.de>

---

compile tested only.

index 1bb7570..730c5c4 100644
--- a/net/tipc/bcast.c
+++ b/net/tipc/bcast.c
@@ -774,8 +774,8 @@ int tipc_bclink_set_queue_limits(u32 lim
 
 int tipc_bclink_init(void)
 {
-	bcbearer = kmalloc(sizeof(*bcbearer), GFP_ATOMIC);
-	bclink = kmalloc(sizeof(*bclink), GFP_ATOMIC);
+	bcbearer = kzalloc(sizeof(*bcbearer), GFP_ATOMIC);
+	bclink = kzalloc(sizeof(*bclink), GFP_ATOMIC);
 	if (!bcbearer || !bclink) {
  nomem:
 	 	warn("Multicast link creation failed, no memory\n");
@@ -786,14 +786,12 @@ int tipc_bclink_init(void)
 		return -ENOMEM;
 	}
 
-	memset(bcbearer, 0, sizeof(struct bcbearer));
 	INIT_LIST_HEAD(&bcbearer->bearer.cong_links);
 	bcbearer->bearer.media = &bcbearer->media;
 	bcbearer->media.send_msg = tipc_bcbearer_send;
 	sprintf(bcbearer->media.name, "tipc-multicast");
 
 	bcl = &bclink->link;
-	memset(bclink, 0, sizeof(struct bclink));
 	INIT_LIST_HEAD(&bcl->waiting_ports);
 	bcl->next_out_no = 1;
 	spin_lock_init(&bclink->node.lock);
index 049242e..2d3f486 100644
--- a/net/tipc/name_table.c
+++ b/net/tipc/name_table.c
@@ -1052,12 +1052,11 @@ int tipc_nametbl_init(void)
 {
 	int array_size = sizeof(struct hlist_head) * tipc_nametbl_size;
 
-	table.types = kmalloc(array_size, GFP_ATOMIC);
+	table.types = kzalloc(array_size, GFP_ATOMIC);
 	if (!table.types)
 		return -ENOMEM;
 
 	write_lock_bh(&tipc_nametbl_lock);
-	memset(table.types, 0, array_size);
 	table.local_publ_count = 0;
 	write_unlock_bh(&tipc_nametbl_lock);
 	return 0;
index 886bda5..76c2abb 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -60,7 +60,7 @@ struct node *tipc_node_create(u32 addr)
 	struct node *n_ptr;
         struct node **curr_node;
 
-	n_ptr = kmalloc(sizeof(*n_ptr),GFP_ATOMIC);
+	n_ptr = kzalloc(sizeof(*n_ptr),GFP_ATOMIC);
 	if (!n_ptr) {
 		warn("Node creation failed, no memory\n");
 		return NULL;
@@ -75,7 +75,6 @@ struct node *tipc_node_create(u32 addr)
 		return NULL;
 	}
 		
-	memset(n_ptr, 0, sizeof(*n_ptr));
 	n_ptr->addr = addr;
                 spin_lock_init(&n_ptr->lock);
 	INIT_LIST_HEAD(&n_ptr->nsub);
index 7a918f1..ddade73 100644
--- a/net/tipc/subscr.c
+++ b/net/tipc/subscr.c
@@ -350,7 +350,7 @@ static void subscr_subscribe(struct tipc
 
 	/* Allocate subscription object */
 
-	sub = kmalloc(sizeof(*sub), GFP_ATOMIC);
+	sub = kzalloc(sizeof(*sub), GFP_ATOMIC);
 	if (!sub) {
 		warn("Subscription rejected, no memory\n");
 		subscr_terminate(subscriber);
@@ -359,7 +359,6 @@ static void subscr_subscribe(struct tipc
 
 	/* Initialize subscription object */
 
-	memset(sub, 0, sizeof(*sub));
 	sub->seq.type = htohl(s->seq.type, subscriber->swap);
 	sub->seq.lower = htohl(s->seq.lower, subscriber->swap);
 	sub->seq.upper = htohl(s->seq.upper, subscriber->swap);
