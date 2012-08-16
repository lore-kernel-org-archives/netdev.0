From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 3/9] tipc: remove pointless name sanity check and tipc_alphabet array
Date: Thu, 16 Aug 2012 18:09:08 -0400
Message-ID: <1345154954-12526-4-git-send-email-paul.gortmaker@windriver.com>
References: <1345154954-12526-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, Jon Maloy <jon.maloy@ericsson.com>,
	Ying Xue <ying.xue@windriver.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:57485 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753284Ab2HPWOu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Aug 2012 18:14:50 -0400
In-Reply-To: <1345154954-12526-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ying Xue <ying.xue@windriver.com>

There is no real reason to check whether all letters in the given
media name and network interface name are within the character set
defined in tipc_alphabet array. Even if we eliminate the checking,
the rest of checking conditions in tipc_enable_bearer() can ensure
we do not enable an invalid or illegal bearer.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/bearer.c | 6 ++----
 net/tipc/core.c   | 3 ---
 net/tipc/core.h   | 2 --
 net/tipc/link.c   | 4 +---
 4 files changed, 3 insertions(+), 12 deletions(-)

diff --git a/net/tipc/bearer.c b/net/tipc/bearer.c
index 09e7124..6b2faa5 100644
--- a/net/tipc/bearer.c
+++ b/net/tipc/bearer.c
@@ -60,7 +60,7 @@ static int media_name_valid(const char *name)
 	len = strlen(name);
 	if ((len + 1) > TIPC_MAX_MEDIA_NAME)
 		return 0;
-	return strspn(name, tipc_alphabet) == len;
+	return 1;
 }
 
 /**
@@ -206,9 +206,7 @@ static int bearer_name_validate(const char *name,
 
 	/* validate component parts of bearer name */
 	if ((media_len <= 1) || (media_len > TIPC_MAX_MEDIA_NAME) ||
-	    (if_len <= 1) || (if_len > TIPC_MAX_IF_NAME) ||
-	    (strspn(media_name, tipc_alphabet) != (media_len - 1)) ||
-	    (strspn(if_name, tipc_alphabet) != (if_len - 1)))
+	    (if_len <= 1) || (if_len > TIPC_MAX_IF_NAME))
 		return 0;
 
 	/* return bearer name components, if necessary */
diff --git a/net/tipc/core.c b/net/tipc/core.c
index 6586eac..c261a5d 100644
--- a/net/tipc/core.c
+++ b/net/tipc/core.c
@@ -50,9 +50,6 @@
 /* global variables used by multiple sub-systems within TIPC */
 int tipc_random;
 
-const char tipc_alphabet[] =
-	"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_.";
-
 /* configurable TIPC parameters */
 u32 tipc_own_addr;
 int tipc_max_ports;
diff --git a/net/tipc/core.h b/net/tipc/core.h
index fd42e10..e4e46cd 100644
--- a/net/tipc/core.h
+++ b/net/tipc/core.h
@@ -85,8 +85,6 @@ extern int tipc_remote_management;
  * Other global variables
  */
 extern int tipc_random;
-extern const char tipc_alphabet[];
-
 
 /*
  * Routines available to privileged subsystems
diff --git a/net/tipc/link.c b/net/tipc/link.c
index 1c1e615..a79c755 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -210,9 +210,7 @@ static int link_name_validate(const char *name,
 	    (z_local > 255) || (c_local > 4095) || (n_local > 4095) ||
 	    (z_peer  > 255) || (c_peer  > 4095) || (n_peer  > 4095) ||
 	    (if_local_len <= 1) || (if_local_len > TIPC_MAX_IF_NAME) ||
-	    (if_peer_len  <= 1) || (if_peer_len  > TIPC_MAX_IF_NAME) ||
-	    (strspn(if_local, tipc_alphabet) != (if_local_len - 1)) ||
-	    (strspn(if_peer, tipc_alphabet) != (if_peer_len - 1)))
+	    (if_peer_len  <= 1) || (if_peer_len  > TIPC_MAX_IF_NAME))
 		return 0;
 
 	/* return link name components, if necessary */
-- 
1.7.11.1
