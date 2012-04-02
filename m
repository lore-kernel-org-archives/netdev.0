From: "David S. Miller" <davem@davemloft.net>
Subject: [PATCH 42/51] gen_stats: Stop using NLA_PUT*().
Date: Sun,  1 Apr 2012 22:58:32 -0400
Message-ID: <1333335521-1348-43-git-send-email-davem@davemloft.net>
References: <1333335521-1348-1-git-send-email-davem@davemloft.net>
Cc: "David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:46797 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754568Ab2DBDAc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Apr 2012 23:00:32 -0400
In-Reply-To: <1333335521-1348-1-git-send-email-davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "David S. Miller" <davem@davemloft.net>

These macros contain a hidden goto, and are thus extremely error
prone and make code hard to audit.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/core/gen_stats.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/core/gen_stats.c b/net/core/gen_stats.c
index 0452eb2..ddedf21 100644
--- a/net/core/gen_stats.c
+++ b/net/core/gen_stats.c
@@ -27,7 +27,8 @@
 static inline int
 gnet_stats_copy(struct gnet_dump *d, int type, void *buf, int size)
 {
-	NLA_PUT(d->skb, type, size, buf);
+	if (nla_put(d->skb, type, size, buf))
+		goto nla_put_failure;
 	return 0;
 
 nla_put_failure:
-- 
1.7.7.6
