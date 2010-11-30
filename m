From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 11/11] tipc: Delete tipc_ownidentity()
Date: Tue, 30 Nov 2010 17:01:03 -0500
Message-ID: <1291154463-26346-12-git-send-email-paul.gortmaker@windriver.com>
References: <1291154463-26346-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:58737 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753078Ab0K3WBR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Nov 2010 17:01:17 -0500
In-Reply-To: <1291154463-26346-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <Allan.Stephens@windriver.com>

Moves the content of the native API routine tipc_ownidentity() into the
sole routine that calls it, since it can no longer be called in isolation.

Signed-off-by: Allan Stephens <Allan.Stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/port.c   |    7 -------
 net/tipc/port.h   |    2 --
 net/tipc/socket.c |    3 ++-
 3 files changed, 2 insertions(+), 10 deletions(-)

diff --git a/net/tipc/port.c b/net/tipc/port.c
index 73f232c..7873283 100644
--- a/net/tipc/port.c
+++ b/net/tipc/port.c
@@ -983,13 +983,6 @@ int tipc_createport(u32 user_ref,
 	return 0;
 }
 
-int tipc_ownidentity(u32 ref, struct tipc_portid *id)
-{
-	id->ref = ref;
-	id->node = tipc_own_addr;
-	return 0;
-}
-
 int tipc_portimportance(u32 ref, unsigned int *importance)
 {
 	struct port *p_ptr;
diff --git a/net/tipc/port.h b/net/tipc/port.h
index 3f6c0aa..3a807fc 100644
--- a/net/tipc/port.h
+++ b/net/tipc/port.h
@@ -191,8 +191,6 @@ int tipc_createport(unsigned int tipc_user, void *usr_handle,
 
 int tipc_deleteport(u32 portref);
 
-int tipc_ownidentity(u32 portref, struct tipc_portid *port);
-
 int tipc_portimportance(u32 portref, unsigned int *importance);
 int tipc_set_portimportance(u32 portref, unsigned int importance);
 
diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 34f96ed..cd0bb77 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -403,7 +403,8 @@ static int get_name(struct socket *sock, struct sockaddr *uaddr,
 		addr->addr.id.ref = tsock->peer_name.ref;
 		addr->addr.id.node = tsock->peer_name.node;
 	} else {
-		tipc_ownidentity(tsock->p->ref, &addr->addr.id);
+		addr->addr.id.ref = tsock->p->ref;
+		addr->addr.id.node = tipc_own_addr;
 	}
 
 	*uaddr_len = sizeof(*addr);
-- 
1.7.3.2.146.g2d444

