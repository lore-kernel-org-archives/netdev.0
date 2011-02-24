From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 03/17] tipc: Remove unused global variable tipc_user_count
Date: Wed, 23 Feb 2011 20:26:31 -0500
Message-ID: <1298510805-20630-4-git-send-email-paul.gortmaker@windriver.com>
References: <1298510805-20630-1-git-send-email-paul.gortmaker@windriver.com>
Cc: allan.stephens@windriver.com, netdev@vger.kernel.org,
	Allan Stephens <Allan.Stephens@windriver.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:34482 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754205Ab1BXB1F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Feb 2011 20:27:05 -0500
In-Reply-To: <1298510805-20630-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <Allan.Stephens@windriver.com>

Eliminates a global variable that was previously used by TIPC's user
registry to track the number of distinct applications using TIPC. Due to
the recent elimination of the user registry this variable no longer serves
any purpose and can be removed.

Signed-off-by: Allan Stephens <Allan.Stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/core.c   |    3 +--
 net/tipc/core.h   |    3 +--
 net/tipc/socket.c |    4 +---
 3 files changed, 3 insertions(+), 7 deletions(-)

diff --git a/net/tipc/core.c b/net/tipc/core.c
index e071579..2da1fc7 100644
--- a/net/tipc/core.c
+++ b/net/tipc/core.c
@@ -2,7 +2,7 @@
  * net/tipc/core.c: TIPC module code
  *
  * Copyright (c) 2003-2006, Ericsson AB
- * Copyright (c) 2005-2006, Wind River Systems
+ * Copyright (c) 2005-2006, 2010-2011, Wind River Systems
  * All rights reserved.
  *
  * Redistribution and use in source and binary forms, with or without
@@ -57,7 +57,6 @@
 
 int tipc_mode = TIPC_NOT_RUNNING;
 int tipc_random;
-atomic_t tipc_user_count = ATOMIC_INIT(0);
 
 const char tipc_alphabet[] =
 	"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_.";
diff --git a/net/tipc/core.h b/net/tipc/core.h
index 9971585..37544d9 100644
--- a/net/tipc/core.h
+++ b/net/tipc/core.h
@@ -2,7 +2,7 @@
  * net/tipc/core.h: Include file for TIPC global declarations
  *
  * Copyright (c) 2005-2006, Ericsson AB
- * Copyright (c) 2005-2007, Wind River Systems
+ * Copyright (c) 2005-2007, 2010-2011, Wind River Systems
  * All rights reserved.
  *
  * Redistribution and use in source and binary forms, with or without
@@ -161,7 +161,6 @@ extern int tipc_remote_management;
 extern int tipc_mode;
 extern int tipc_random;
 extern const char tipc_alphabet[];
-extern atomic_t tipc_user_count;
 
 
 /*
diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 2b02a3a..893ca6e 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -2,7 +2,7 @@
  * net/tipc/socket.c: TIPC socket API
  *
  * Copyright (c) 2001-2007, Ericsson AB
- * Copyright (c) 2004-2008, Wind River Systems
+ * Copyright (c) 2004-2008, 2010-2011, Wind River Systems
  * All rights reserved.
  *
  * Redistribution and use in source and binary forms, with or without
@@ -241,7 +241,6 @@ static int tipc_create(struct net *net, struct socket *sock, int protocol,
 			tipc_set_portunreliable(tp_ptr->ref, 1);
 	}
 
-	atomic_inc(&tipc_user_count);
 	return 0;
 }
 
@@ -321,7 +320,6 @@ static int release(struct socket *sock)
 	sock_put(sk);
 	sock->sk = NULL;
 
-	atomic_dec(&tipc_user_count);
 	return res;
 }
 
-- 
1.7.3.3

