From: Vlad Yasevich <vyasevich@gmail.com>
Subject: [PATCH v4 net 1/3] net: dst: provide accessor function to dst->xfrm
Date: Tue, 15 Oct 2013 22:01:29 -0400
Message-ID: <1381888891-31186-2-git-send-email-vyasevich@gmail.com>
References: <1381888891-31186-1-git-send-email-vyasevich@gmail.com>
Cc: linux-sctp@vger.kernel.org, fan.du@windriver.com,
	Vlad Yasevich <vyasevich@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qe0-f45.google.com ([209.85.128.45]:56937 "EHLO
	mail-qe0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932759Ab3JPCB7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Oct 2013 22:01:59 -0400
In-Reply-To: <1381888891-31186-1-git-send-email-vyasevich@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

dst->xfrm is conditionally defined.  Provide accessor funtion that
is always available.

Signed-off-by: Vlad Yasevich <vyasevich@gmail.com>
---
 include/net/dst.h | 12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/include/net/dst.h b/include/net/dst.h
index 3bc4865..3c4c944 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -479,10 +479,22 @@ static inline struct dst_entry *xfrm_lookup(struct net *net,
 {
 	return dst_orig;
 } 
+
+static inline struct xfrm_state *dst_xfrm(const struct dst_entry *dst)
+{
+	return NULL;
+}
+
 #else
 extern struct dst_entry *xfrm_lookup(struct net *net, struct dst_entry *dst_orig,
 				     const struct flowi *fl, struct sock *sk,
 				     int flags);
+
+/* skb attached with this dst needs transformation if dst->xfrm is valid */
+static inline struct xfrm_state *dst_xfrm(const struct dst_entry *dst)
+{
+	return dst->xfrm;
+}
 #endif
 
 #endif /* _NET_DST_H */
-- 
1.8.3.1
