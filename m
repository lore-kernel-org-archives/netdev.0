From: "David S. Miller" <davem@davemloft.net>
Subject: [PATCH 50/51] xfrm: Stop using NLA_PUT*().
Date: Sun,  1 Apr 2012 22:58:40 -0400
Message-ID: <1333335521-1348-51-git-send-email-davem@davemloft.net>
References: <1333335521-1348-1-git-send-email-davem@davemloft.net>
Cc: "David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:46831 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754568Ab2DBDA4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Apr 2012 23:00:56 -0400
In-Reply-To: <1333335521-1348-1-git-send-email-davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "David S. Miller" <davem@davemloft.net>

These macros contain a hidden goto, and are thus extremely error
prone and make code hard to audit.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/xfrm.h |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 96239e7..1cb32bf 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -1682,8 +1682,9 @@ static inline int xfrm_mark_get(struct nlattr **attrs, struct xfrm_mark *m)
 
 static inline int xfrm_mark_put(struct sk_buff *skb, const struct xfrm_mark *m)
 {
-	if (m->m | m->v)
-		NLA_PUT(skb, XFRMA_MARK, sizeof(struct xfrm_mark), m);
+	if ((m->m | m->v) &&
+	    nla_put(skb, XFRMA_MARK, sizeof(struct xfrm_mark), m))
+		goto nla_put_failure;
 	return 0;
 
 nla_put_failure:
-- 
1.7.7.6
