From: "David S. Miller" <davem@davemloft.net>
Subject: [RFC v2 PATCH 11/11] net: Remove dst->next
Date: Tue, 31 Oct 2017 23:10:54 +0900
Message-ID: <20171031141054.9954-12-davem@davemloft.net>
References: <20171031141054.9954-1-davem@davemloft.net>
Cc: "David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [106.252.28.196] ([106.252.28.196]:51332 "EHLO davemloft.net"
        rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753083AbdJaOUi (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 31 Oct 2017 10:20:38 -0400
In-Reply-To: <20171031141054.9954-1-davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are no more users.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/dst.h | 4 ----
 net/core/dst.c    | 1 -
 2 files changed, 5 deletions(-)

diff --git a/include/net/dst.h b/include/net/dst.h
index ffd0d81f861f..b0e71091d159 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -82,10 +82,6 @@ struct dst_entry {
 	short			error;
 	short			__pad;
 	__u32			tclassid;
-
-	union {
-		struct dst_entry	*next;
-	};
 };
 
 struct dst_metrics {
diff --git a/net/core/dst.c b/net/core/dst.c
index 9bc3bb6e94ef..007aa0b08291 100644
--- a/net/core/dst.c
+++ b/net/core/dst.c
@@ -86,7 +86,6 @@ void dst_init(struct dst_entry *dst, struct dst_ops *ops,
 	dst->__use = 0;
 	dst->lastuse = jiffies;
 	dst->flags = flags;
-	dst->next = NULL;
 	if (!(flags & DST_NOCOUNT))
 		dst_entries_add(ops, 1);
 }
-- 
2.13.6
