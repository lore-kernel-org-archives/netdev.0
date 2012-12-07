From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 04/10] tipc: change sk_receive_queue upper limit
Date: Fri, 7 Dec 2012 09:28:12 -0500
Message-ID: <1354890498-6448-5-git-send-email-paul.gortmaker@windriver.com>
References: <1354890498-6448-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, Jon Maloy <jon.maloy@ericsson.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:62568 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030752Ab2LGO2f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Dec 2012 09:28:35 -0500
In-Reply-To: <1354890498-6448-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Maloy <jon.maloy@ericsson.com>

The sk_recv_queue upper limit for connectionless sockets has empirically
turned out to be too low. When we double the current limit we get much
fewer rejected messages and no noticable negative side-effects.

Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/socket.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 4d6a448..65a6bfc 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -1,7 +1,7 @@
 /*
  * net/tipc/socket.c: TIPC socket API
  *
- * Copyright (c) 2001-2007, Ericsson AB
+ * Copyright (c) 2001-2007, 2012 Ericsson AB
  * Copyright (c) 2004-2008, 2010-2012, Wind River Systems
  * All rights reserved.
  *
@@ -43,7 +43,7 @@
 #define SS_LISTENING	-1	/* socket is listening */
 #define SS_READY	-2	/* socket is connectionless */
 
-#define OVERLOAD_LIMIT_BASE	5000
+#define OVERLOAD_LIMIT_BASE	10000
 #define CONN_TIMEOUT_DEFAULT	8000	/* default connect timeout = 8s */
 
 struct tipc_sock {
-- 
1.7.12.1
