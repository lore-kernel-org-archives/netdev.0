From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 09/16] tipc: rename tipc_createport_raw to tipc_createport
Date: Mon, 17 Jun 2013 10:54:44 -0400
Message-ID: <1371480891-5264-10-git-send-email-paul.gortmaker@windriver.com>
References: <1371480891-5264-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, Jon Maloy <jon.maloy@ericsson.com>,
	Ying Xue <ying.xue@windriver.com>,
	Erik Hugne <erik.hugne@ericsson.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:63172 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751533Ab3FQOzS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Jun 2013 10:55:18 -0400
In-Reply-To: <1371480891-5264-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ying Xue <ying.xue@windriver.com>

After the removal of the native API, there is now only one way to
to create a TIPC port instance -- the function tipc_createport_raw().
We make it more readable by renaming it to tipc_createport().

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/port.c   | 4 ++--
 net/tipc/port.h   | 2 +-
 net/tipc/socket.c | 4 ++--
 3 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/tipc/port.c b/net/tipc/port.c
index f628c84..84b2a57 100644
--- a/net/tipc/port.c
+++ b/net/tipc/port.c
@@ -202,11 +202,11 @@ exit:
 }
 
 /**
- * tipc_createport_raw - create a generic TIPC port
+ * tipc_createport - create a generic TIPC port
  *
  * Returns pointer to (locked) TIPC port, or NULL if unable to create it
  */
-struct tipc_port *tipc_createport_raw(void *usr_handle,
+struct tipc_port *tipc_createport(void *usr_handle,
 			u32 (*dispatcher)(struct tipc_port *, struct sk_buff *),
 			void (*wakeup)(struct tipc_port *),
 			const u32 importance)
diff --git a/net/tipc/port.h b/net/tipc/port.h
index 4779f0a..4583882 100644
--- a/net/tipc/port.h
+++ b/net/tipc/port.h
@@ -106,7 +106,7 @@ struct tipc_port_list;
 /*
  * TIPC port manipulation routines
  */
-struct tipc_port *tipc_createport_raw(void *usr_handle,
+struct tipc_port *tipc_createport(void *usr_handle,
 		u32 (*dispatcher)(struct tipc_port *, struct sk_buff *),
 		void (*wakeup)(struct tipc_port *), const u32 importance);
 
diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 9510fe8..67f4e1f 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -195,8 +195,8 @@ static int tipc_sk_create(struct net *net, struct socket *sock, int protocol,
 		return -ENOMEM;
 
 	/* Allocate TIPC port for socket to use */
-	tp_ptr = tipc_createport_raw(sk, &dispatch, &wakeupdispatch,
-				     TIPC_LOW_IMPORTANCE);
+	tp_ptr = tipc_createport(sk, &dispatch, &wakeupdispatch,
+				 TIPC_LOW_IMPORTANCE);
 	if (unlikely(!tp_ptr)) {
 		sk_free(sk);
 		return -ENOMEM;
-- 
1.8.1.2
