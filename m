From: kaber@trash.net
Subject: [PATCH 1/2] netfilter: don't xt_jumpstack_alloc twice in xt_register_table
Date: Mon, 31 May 2010 18:14:46 +0200
Message-ID: <1275322487-19026-2-git-send-email-kaber@trash.net>
References: <1275322487-19026-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:60784 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751886Ab0EaQOw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 May 2010 12:14:52 -0400
In-Reply-To: <1275322487-19026-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xiaotian Feng <dfeng@redhat.com>

In xt_register_table, xt_jumpstack_alloc is called first, later
xt_replace_table is used. But in xt_replace_table, xt_jumpstack_alloc
will be used again. Then the memory allocated by previous xt_jumpstack_alloc
will be leaked. We can simply remove the previous xt_jumpstack_alloc because
there aren't any users of newinfo between xt_jumpstack_alloc and
xt_replace_table.

Signed-off-by: Xiaotian Feng <dfeng@redhat.com>
Cc: Patrick McHardy <kaber@trash.net>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Jan Engelhardt <jengelh@medozas.de>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Rusty Russell <rusty@rustcorp.com.au>
Cc: Alexey Dobriyan <adobriyan@gmail.com>
Acked-By: Jan Engelhardt <jengelh@medozas.de>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/netfilter/x_tables.c |    4 ----
 1 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/net/netfilter/x_tables.c b/net/netfilter/x_tables.c
index 445de70..47b1e79 100644
--- a/net/netfilter/x_tables.c
+++ b/net/netfilter/x_tables.c
@@ -844,10 +844,6 @@ struct xt_table *xt_register_table(struct net *net,
 	struct xt_table_info *private;
 	struct xt_table *t, *table;
 
-	ret = xt_jumpstack_alloc(newinfo);
-	if (ret < 0)
-		return ERR_PTR(ret);
-
 	/* Don't add one object to multiple lists. */
 	table = kmemdup(input_table, sizeof(struct xt_table), GFP_KERNEL);
 	if (!table) {
-- 
1.7.0.4

