From: Tom Parkin <tparkin@katalix.com>
Subject: [RFC PATCH 3/6] l2tp: drop session refs in l2tp_tunnel_closeall
Date: Fri, 15 Feb 2013 10:25:16 +0000
Message-ID: <1360923919-7203-4-git-send-email-tparkin@katalix.com>
References: <1360923919-7203-1-git-send-email-tparkin@katalix.com>
Cc: jchapman@katalix.com, celston@katalix.com,
	Tom Parkin <tparkin@katalix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:34090 "EHLO mail.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161230Ab3BOKZg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Feb 2013 05:25:36 -0500
In-Reply-To: <1360923919-7203-1-git-send-email-tparkin@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

l2tp_tunnel_closeall is intended to close and free all sessions running in a
given tunnel.  It lacked a session dereference, however, meaning these
sessions would all leak rather than being properly freed.

Add a session deref call in l2tp_tunnel_closeall to prevent this leak.

---
 net/l2tp/l2tp_core.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/l2tp/l2tp_core.c b/net/l2tp/l2tp_core.c
index 3842f67..7f3ab65 100644
--- a/net/l2tp/l2tp_core.c
+++ b/net/l2tp/l2tp_core.c
@@ -1328,6 +1328,8 @@ again:
 			if (session->deref != NULL)
 				(*session->deref)(session);
 
+			l2tp_session_dec_refcount(session);
+
 			write_lock_bh(&tunnel->hlist_lock);
 
 			/* Now restart from the beginning of this hash
-- 
1.7.9.5
