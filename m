From: Tom Parkin <tparkin@katalix.com>
Subject: [PATCH 09/12] l2tp: purge session reorder queue on delete
Date: Tue, 19 Mar 2013 16:11:20 +0000
Message-ID: <1363709483-24021-10-git-send-email-tparkin@katalix.com>
References: <1363709483-24021-1-git-send-email-tparkin@katalix.com>
Cc: Tom Parkin <tparkin@katalix.com>,
	James Chapman <jchapman@katalix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:36146 "EHLO bert.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932699Ab3CSQLc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Mar 2013 12:11:32 -0400
In-Reply-To: <1363709483-24021-1-git-send-email-tparkin@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add calls to l2tp_session_queue_purge as a part of l2tp_tunnel_closeall
and l2tp_session_delete.  Pseudowire implementations which are deleted only
via. l2tp_core l2tp_session_delete calls can dispense with their own code for
flushing the reorder queue.

Signed-off-by: Tom Parkin <tparkin@katalix.com>
Signed-off-by: James Chapman <jchapman@katalix.com>
---
 net/l2tp/l2tp_core.c |    4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/l2tp/l2tp_core.c b/net/l2tp/l2tp_core.c
index 69c316d..c00f31b 100644
--- a/net/l2tp/l2tp_core.c
+++ b/net/l2tp/l2tp_core.c
@@ -1373,6 +1373,8 @@ again:
 				synchronize_rcu();
 			}
 
+			l2tp_session_queue_purge(session);
+
 			if (session->session_close != NULL)
 				(*session->session_close)(session);
 
@@ -1813,6 +1815,8 @@ EXPORT_SYMBOL_GPL(l2tp_session_free);
  */
 int l2tp_session_delete(struct l2tp_session *session)
 {
+	l2tp_session_queue_purge(session);
+
 	if (session->session_close != NULL)
 		(*session->session_close)(session);
 
-- 
1.7.9.5
