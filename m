From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 19/20] tipc: remove zeroing assignments to static global variables
Date: Fri, 31 Dec 2010 23:59:34 -0500
Message-ID: <1293857975-30267-20-git-send-email-paul.gortmaker@windriver.com>
References: <1293857975-30267-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com,
	Allan Stephens <Allan.Stephens@windriver.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:53350 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750994Ab1AAFAQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Jan 2011 00:00:16 -0500
In-Reply-To: <1293857975-30267-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <Allan.Stephens@windriver.com>

Cleans up TIPC's source code to eliminate the needless initialization
of static variables to zero.

These changes are purely cosmetic and do not alter the operation of TIPC
in any way.

Signed-off-by: Allan Stephens <Allan.Stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/bcast.c      |    8 ++++----
 net/tipc/bearer.c     |    2 +-
 net/tipc/eth_media.c  |    2 +-
 net/tipc/handler.c    |    2 +-
 net/tipc/name_distr.c |    2 +-
 net/tipc/name_table.c |    2 +-
 net/tipc/node.c       |    2 +-
 net/tipc/port.c       |    4 ++--
 net/tipc/ref.c        |    2 +-
 net/tipc/socket.c     |    2 +-
 net/tipc/subscr.c     |    2 +-
 11 files changed, 15 insertions(+), 15 deletions(-)

diff --git a/net/tipc/bcast.c b/net/tipc/bcast.c
index 9de3256..99a1469 100644
--- a/net/tipc/bcast.c
+++ b/net/tipc/bcast.c
@@ -103,9 +103,9 @@ struct bclink {
 };
 
 
-static struct bcbearer *bcbearer = NULL;
-static struct bclink *bclink = NULL;
-static struct link *bcl = NULL;
+static struct bcbearer *bcbearer;
+static struct bclink *bclink;
+static struct link *bcl;
 static DEFINE_SPINLOCK(bc_lock);
 
 /* broadcast-capable node map */
@@ -425,7 +425,7 @@ int tipc_bclink_send_msg(struct sk_buff *buf)
 void tipc_bclink_recv_pkt(struct sk_buff *buf)
 {
 #if (TIPC_BCAST_LOSS_RATE)
-	static int rx_count = 0;
+	static int rx_count;
 #endif
 	struct tipc_msg *msg = buf_msg(buf);
 	struct tipc_node *node = tipc_node_find(msg_prevnode(msg));
diff --git a/net/tipc/bearer.c b/net/tipc/bearer.c
index e9136f0..68e7290 100644
--- a/net/tipc/bearer.c
+++ b/net/tipc/bearer.c
@@ -42,7 +42,7 @@
 #define MAX_ADDR_STR 32
 
 static struct media media_list[MAX_MEDIA];
-static u32 media_count = 0;
+static u32 media_count;
 
 struct bearer tipc_bearers[MAX_BEARERS];
 
diff --git a/net/tipc/eth_media.c b/net/tipc/eth_media.c
index 5dfe663..b69092e 100644
--- a/net/tipc/eth_media.c
+++ b/net/tipc/eth_media.c
@@ -56,7 +56,7 @@ struct eth_bearer {
 };
 
 static struct eth_bearer eth_bearers[MAX_ETH_BEARERS];
-static int eth_started = 0;
+static int eth_started;
 static struct notifier_block notifier;
 
 /**
diff --git a/net/tipc/handler.c b/net/tipc/handler.c
index 0c70010..274c98e 100644
--- a/net/tipc/handler.c
+++ b/net/tipc/handler.c
@@ -45,7 +45,7 @@ struct queue_item {
 static struct kmem_cache *tipc_queue_item_cache;
 static struct list_head signal_queue_head;
 static DEFINE_SPINLOCK(qitem_lock);
-static int handler_enabled = 0;
+static int handler_enabled;
 
 static void process_signal_queue(unsigned long dummy);
 
diff --git a/net/tipc/name_distr.c b/net/tipc/name_distr.c
index a6c989f..483c226 100644
--- a/net/tipc/name_distr.c
+++ b/net/tipc/name_distr.c
@@ -73,7 +73,7 @@ struct distr_item {
  */
 
 static LIST_HEAD(publ_root);
-static u32 publ_cnt = 0;
+static u32 publ_cnt;
 
 /**
  * publ_to_item - add publication info to a publication message
diff --git a/net/tipc/name_table.c b/net/tipc/name_table.c
index 46b2f31..ea3e94e 100644
--- a/net/tipc/name_table.c
+++ b/net/tipc/name_table.c
@@ -104,7 +104,7 @@ struct name_table {
 	u32 local_publ_count;
 };
 
-static struct name_table table = { NULL } ;
+static struct name_table table;
 static atomic_t rsv_publ_ok = ATOMIC_INIT(0);
 DEFINE_RWLOCK(tipc_nametbl_lock);
 
diff --git a/net/tipc/node.c b/net/tipc/node.c
index 2ed162f..3af53e3 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -44,7 +44,7 @@ static void node_established_contact(struct tipc_node *n_ptr);
 
 static DEFINE_SPINLOCK(node_create_lock);
 
-u32 tipc_own_tag = 0;
+u32 tipc_own_tag;
 
 /**
  * tipc_node_create - create neighboring node
diff --git a/net/tipc/port.c b/net/tipc/port.c
index 78fcb75..c23f338 100644
--- a/net/tipc/port.c
+++ b/net/tipc/port.c
@@ -46,8 +46,8 @@
 
 #define MAX_REJECT_SIZE 1024
 
-static struct sk_buff *msg_queue_head = NULL;
-static struct sk_buff *msg_queue_tail = NULL;
+static struct sk_buff *msg_queue_head;
+static struct sk_buff *msg_queue_tail;
 
 DEFINE_SPINLOCK(tipc_port_list_lock);
 static DEFINE_SPINLOCK(queue_lock);
diff --git a/net/tipc/ref.c b/net/tipc/ref.c
index 3974529..8311689 100644
--- a/net/tipc/ref.c
+++ b/net/tipc/ref.c
@@ -89,7 +89,7 @@ struct ref_table {
  * have a reference value of 0 (although this is unlikely).
  */
 
-static struct ref_table tipc_ref_table = { NULL };
+static struct ref_table tipc_ref_table;
 
 static DEFINE_RWLOCK(ref_table_lock);
 
diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 0895dec..18aad57 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -68,7 +68,7 @@ static const struct proto_ops msg_ops;
 
 static struct proto tipc_proto;
 
-static int sockets_enabled = 0;
+static int sockets_enabled;
 
 static atomic_t tipc_queue_size = ATOMIC_INIT(0);
 
diff --git a/net/tipc/subscr.c b/net/tipc/subscr.c
index acc30e1..ca04479 100644
--- a/net/tipc/subscr.c
+++ b/net/tipc/subscr.c
@@ -70,7 +70,7 @@ struct top_srv {
 	spinlock_t lock;
 };
 
-static struct top_srv topsrv = { 0 };
+static struct top_srv topsrv;
 
 /**
  * htohl - convert value to endianness used by destination
-- 
1.7.3.3

