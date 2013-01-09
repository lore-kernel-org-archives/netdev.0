From: Tom Parkin <tparkin@katalix.com>
Subject: [PATCH 4/4] l2tp: clear tunnel socket field as soon as we release it
Date: Wed,  9 Jan 2013 18:36:23 +0000
Message-ID: <1357756583-22535-5-git-send-email-tparkin@katalix.com>
References: <1357756583-22535-1-git-send-email-tparkin@katalix.com>
Cc: Tom Parkin <tparkin@katalix.com>,
	James Chapman <jchapman@katalix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:55331 "EHLO mail.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932234Ab3AISgs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Jan 2013 13:36:48 -0500
In-Reply-To: <1357756583-22535-1-git-send-email-tparkin@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

L2TP's struct l2tp_tunnel is freed and removed from the tunnel list
by the socket destructor, which may or may not run when we release our
reference to the socket in l2tp_tunnel_delete.  To prevent any chance of
accidentally reusing the socket after it is released, clear out the field
in l2tp_tunnel_delete.

Signed-off-by: Tom Parkin <tparkin@katalix.com>
Signed-off-by: James Chapman <jchapman@katalix.com>
---
 net/l2tp/l2tp_core.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/net/l2tp/l2tp_core.c b/net/l2tp/l2tp_core.c
index 5922eac..0cfc701 100644
--- a/net/l2tp/l2tp_core.c
+++ b/net/l2tp/l2tp_core.c
@@ -1668,6 +1668,7 @@ int l2tp_tunnel_delete(struct l2tp_tunnel *tunnel)
 	 * sessions are removed via. the socket destructor.
 	 */
 	if (sock != NULL) {
+		tunnel->sock = NULL;
 		if (sock->file == NULL) {
 			kernel_sock_shutdown(sock, SHUT_RDWR);
 			sk_release_kernel(sock->sk);
-- 
1.7.9.5
