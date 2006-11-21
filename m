From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Subject: [PATCH 10/11] [TIPC]: Use kzalloc where appropriate
Date: Tue, 21 Nov 2006 01:29:20 -0200
Message-ID: <20061121032920.GK7039@mandriva.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.mandriva.com ([212.85.150.183]:21997 "EHLO mx1.mandriva.com")
	by vger.kernel.org with ESMTP id S1030691AbWKUD30 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Nov 2006 22:29:26 -0500
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>
---
 net/tipc/bcast.c  |    6 ++----
 net/tipc/node.c   |    3 +--
 net/tipc/subscr.c |    3 +--
 3 files changed, 4 insertions(+), 8 deletions(-)

diff --git a/net/tipc/bcast.c b/net/tipc/bcast.c
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
diff --git a/net/tipc/node.c b/net/tipc/node.c
index 106cd0d..4111a31 100644
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
diff --git a/net/tipc/subscr.c b/net/tipc/subscr.c
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
-- 
1.4.2.1.g3d5c

