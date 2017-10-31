From: Guillaume Nault <g.nault@alphalink.fr>
Subject: [PATCH net-next 2/4] l2tp: remove l2tp specific refcount debugging
Date: Tue, 31 Oct 2017 17:36:44 +0100
Message-ID: <8904b1b6b68e233f872c6b81fc2294033c2b2283.1509466904.git.g.nault@alphalink.fr>
References: <cover.1509466904.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: James Chapman <jchapman@katalix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:38653 "EHLO
        zimbra.alphalink.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751565AbdJaQgu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 12:36:50 -0400
Content-Disposition: inline
In-Reply-To: <cover.1509466904.git.g.nault@alphalink.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With conversion to refcount_t, such manual debugging code doesn't make
sense anymore.
The tunnel part was already dropped by
54652eb12c1b ("l2tp: hold tunnel while looking up sessions in l2tp_netlink").

Signed-off-by: Guillaume Nault <g.nault@alphalink.fr>
---
 net/l2tp/l2tp_core.h | 24 ++----------------------
 1 file changed, 2 insertions(+), 22 deletions(-)

diff --git a/net/l2tp/l2tp_core.h b/net/l2tp/l2tp_core.h
index 92c90e72259c..9534e16965cc 100644
--- a/net/l2tp/l2tp_core.h
+++ b/net/l2tp/l2tp_core.h
@@ -294,37 +294,17 @@ static inline void l2tp_tunnel_dec_refcount(struct l2tp_tunnel *tunnel)
 /* Session reference counts. Incremented when code obtains a reference
  * to a session.
  */
-static inline void l2tp_session_inc_refcount_1(struct l2tp_session *session)
+static inline void l2tp_session_inc_refcount(struct l2tp_session *session)
 {
 	refcount_inc(&session->ref_count);
 }
 
-static inline void l2tp_session_dec_refcount_1(struct l2tp_session *session)
+static inline void l2tp_session_dec_refcount(struct l2tp_session *session)
 {
 	if (refcount_dec_and_test(&session->ref_count))
 		l2tp_session_free(session);
 }
 
-#ifdef L2TP_REFCNT_DEBUG
-#define l2tp_session_inc_refcount(_s)					\
-do {									\
-	pr_debug("l2tp_session_inc_refcount: %s:%d %s: cnt=%d\n",	\
-		 __func__, __LINE__, (_s)->name,			\
-		 refcount_read(&_s->ref_count));			\
-	l2tp_session_inc_refcount_1(_s);				\
-} while (0)
-#define l2tp_session_dec_refcount(_s)					\
-do {									\
-	pr_debug("l2tp_session_dec_refcount: %s:%d %s: cnt=%d\n",	\
-		 __func__, __LINE__, (_s)->name,			\
-		 refcount_read(&_s->ref_count));			\
-	l2tp_session_dec_refcount_1(_s);				\
-} while (0)
-#else
-#define l2tp_session_inc_refcount(s) l2tp_session_inc_refcount_1(s)
-#define l2tp_session_dec_refcount(s) l2tp_session_dec_refcount_1(s)
-#endif
-
 #define l2tp_printk(ptr, type, func, fmt, ...)				\
 do {									\
 	if (((ptr)->debug) & (type))					\
-- 
2.15.0
