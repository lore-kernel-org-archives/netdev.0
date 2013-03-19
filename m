From: Tom Parkin <tparkin@katalix.com>
Subject: [PATCH 06/12] l2tp: take a reference for kernel sockets in l2tp_tunnel_sock_lookup
Date: Tue, 19 Mar 2013 16:11:17 +0000
Message-ID: <1363709483-24021-7-git-send-email-tparkin@katalix.com>
References: <1363709483-24021-1-git-send-email-tparkin@katalix.com>
Cc: Tom Parkin <tparkin@katalix.com>,
	James Chapman <jchapman@katalix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:36146 "EHLO bert.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932436Ab3CSQLb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Mar 2013 12:11:31 -0400
In-Reply-To: <1363709483-24021-1-git-send-email-tparkin@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When looking up the tunnel socket in struct l2tp_tunnel, hold a reference
whether the socket was created by the kernel or by userspace.

Signed-off-by: Tom Parkin <tparkin@katalix.com>
Signed-off-by: James Chapman <jchapman@katalix.com>
---
 net/l2tp/l2tp_core.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/l2tp/l2tp_core.c b/net/l2tp/l2tp_core.c
index 0dd50c0..45373fe 100644
--- a/net/l2tp/l2tp_core.c
+++ b/net/l2tp/l2tp_core.c
@@ -191,6 +191,7 @@ struct sock *l2tp_tunnel_sock_lookup(struct l2tp_tunnel *tunnel)
 	} else {
 		/* Socket is owned by kernelspace */
 		sk = tunnel->sock;
+		sock_hold(sk);
 	}
 
 out:
@@ -209,6 +210,7 @@ void l2tp_tunnel_sock_put(struct sock *sk)
 		}
 		sock_put(sk);
 	}
+	sock_put(sk);
 }
 EXPORT_SYMBOL_GPL(l2tp_tunnel_sock_put);
 
-- 
1.7.9.5
