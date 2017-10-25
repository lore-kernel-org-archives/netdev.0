From: David Miller <davem@davemloft.net>
Subject: [RFC PATCH 12/12] net: Remove dst->next
Date: Wed, 25 Oct 2017 23:04:54 +0900 (KST)
Message-ID: <20171025.230454.969875106493989911.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48374 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751892AbdJYOE5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Oct 2017 10:04:57 -0400
Received: from localhost (unknown [106.252.28.196])
        (using TLSv1 with cipher AES256-SHA (256/256 bits))
        (Client did not present a certificate)
        (Authenticated sender: davem-davemloft)
        by shards.monkeyblade.net (Postfix) with ESMTPSA id A7E7B133F06AD
        for <netdev@vger.kernel.org>; Wed, 25 Oct 2017 07:04:56 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


There are no more users.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/dst.h | 4 ----
 net/core/dst.c    | 1 -
 2 files changed, 5 deletions(-)

diff --git a/include/net/dst.h b/include/net/dst.h
index 403b1c02a26f..ad24d41c0149 100644
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
