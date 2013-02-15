From: Tom Parkin <tparkin@katalix.com>
Subject: [RFC PATCH 6/6] l2tp: close sessions before initiating tunnel delete
Date: Fri, 15 Feb 2013 10:25:19 +0000
Message-ID: <1360923919-7203-7-git-send-email-tparkin@katalix.com>
References: <1360923919-7203-1-git-send-email-tparkin@katalix.com>
Cc: jchapman@katalix.com, celston@katalix.com,
	Tom Parkin <tparkin@katalix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:34093 "EHLO mail.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161241Ab3BOKZh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Feb 2013 05:25:37 -0500
In-Reply-To: <1360923919-7203-1-git-send-email-tparkin@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When a user deletes a tunnel using netlink, all the sessions in the tunnel
should also be deleted.  Since running sessions will pin the tunnel socket
with the references they hold, have the l2tp_tunnel_delete close all sessions
in a tunnel before finally closing the tunnel socket.

---
 net/l2tp/l2tp_core.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/net/l2tp/l2tp_core.c b/net/l2tp/l2tp_core.c
index 26b5f00..f3735d6 100644
--- a/net/l2tp/l2tp_core.c
+++ b/net/l2tp/l2tp_core.c
@@ -1704,6 +1704,7 @@ EXPORT_SYMBOL_GPL(l2tp_tunnel_create);
  */
 int l2tp_tunnel_delete(struct l2tp_tunnel *tunnel)
 {
+	l2tp_tunnel_closeall(tunnel);
 	return (false == queue_work(l2tp_wq, &tunnel->del_work));
 }
 EXPORT_SYMBOL_GPL(l2tp_tunnel_delete);
-- 
1.7.9.5
