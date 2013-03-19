From: Tom Parkin <tparkin@katalix.com>
Subject: [PATCH 05/12] l2tp: close sessions before initiating tunnel delete
Date: Tue, 19 Mar 2013 16:11:16 +0000
Message-ID: <1363709483-24021-6-git-send-email-tparkin@katalix.com>
References: <1363709483-24021-1-git-send-email-tparkin@katalix.com>
Cc: Tom Parkin <tparkin@katalix.com>,
	James Chapman <jchapman@katalix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:36145 "EHLO bert.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932778Ab3CSQLb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Mar 2013 12:11:31 -0400
In-Reply-To: <1363709483-24021-1-git-send-email-tparkin@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When a user deletes a tunnel using netlink, all the sessions in the tunnel
should also be deleted.  Since running sessions will pin the tunnel socket
with the references they hold, have the l2tp_tunnel_delete close all sessions
in a tunnel before finally closing the tunnel socket.

Signed-off-by: Tom Parkin <tparkin@katalix.com>
Signed-off-by: James Chapman <jchapman@katalix.com>
---
 net/l2tp/l2tp_core.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/net/l2tp/l2tp_core.c b/net/l2tp/l2tp_core.c
index 287e327..0dd50c0 100644
--- a/net/l2tp/l2tp_core.c
+++ b/net/l2tp/l2tp_core.c
@@ -1737,6 +1737,7 @@ EXPORT_SYMBOL_GPL(l2tp_tunnel_create);
  */
 int l2tp_tunnel_delete(struct l2tp_tunnel *tunnel)
 {
+	l2tp_tunnel_closeall(tunnel);
 	return (false == queue_work(l2tp_wq, &tunnel->del_work));
 }
 EXPORT_SYMBOL_GPL(l2tp_tunnel_delete);
-- 
1.7.9.5
