From: David Miller <davem@davemloft.net>
Subject: [RFC PATCH 04/12] net: Make generic dst->child usage more explicit.
Date: Wed, 25 Oct 2017 23:03:11 +0900 (KST)
Message-ID: <20171025.230311.1944266209591105385.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48320 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751977AbdJYODP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Oct 2017 10:03:15 -0400
Received: from localhost (unknown [106.252.28.196])
        (using TLSv1 with cipher AES256-SHA (256/256 bits))
        (Client did not present a certificate)
        (Authenticated sender: davem-davemloft)
        by shards.monkeyblade.net (Postfix) with ESMTPSA id 85984133F06AD
        for <netdev@vger.kernel.org>; Wed, 25 Oct 2017 07:03:14 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Only IPSEC (xfrm) routes have a dst->child which is non-NULL.
xfrm routes are identified by dst->xfrm being non-NULL.

Codify this explicitly in dst_destroy().

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/core/dst.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/net/core/dst.c b/net/core/dst.c
index 662a2d4a3d19..6a3c21b8fc8d 100644
--- a/net/core/dst.c
+++ b/net/core/dst.c
@@ -116,12 +116,14 @@ EXPORT_SYMBOL(dst_alloc);
 
 struct dst_entry *dst_destroy(struct dst_entry * dst)
 {
-	struct dst_entry *child;
+	struct dst_entry *child = NULL;
 
 	smp_rmb();
 
-	child = dst->child;
-
+#ifdef CONFIG_XFRM
+	if (dst->xfrm)
+		child = dst->child;
+#endif
 	if (!(dst->flags & DST_NOCOUNT))
 		dst_entries_add(dst->ops, -1);
 
-- 
2.13.6
