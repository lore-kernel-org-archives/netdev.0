From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 31/53] netfilter: nf_tables: improve nft payload fast eval
Date: Mon, 26 Sep 2016 01:06:41 +0200
Message-ID: <1474844823-2026-32-git-send-email-pablo@netfilter.org>
References: <1474844823-2026-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:54686 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1034720AbcIYXHv (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 25 Sep 2016 19:07:51 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id CAD1AC1066
        for <netdev@vger.kernel.org>; Mon, 26 Sep 2016 01:07:50 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id BAC05DA84C
        for <netdev@vger.kernel.org>; Mon, 26 Sep 2016 01:07:50 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id AC67BDA81B
        for <netdev@vger.kernel.org>; Mon, 26 Sep 2016 01:07:48 +0200 (CEST)
In-Reply-To: <1474844823-2026-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Liping Zhang <liping.zhang@spreadtrum.com>

There's an off-by-one issue in nft_payload_fast_eval, skb_tail_pointer
and ptr + priv->len all point to the last valid address plus 1. So if
they are equal, we can still fetch the valid data. It's unnecessary to
fall back to nft_payload_eval.

Signed-off-by: Liping Zhang <liping.zhang@spreadtrum.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_tables_core.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/nf_tables_core.c b/net/netfilter/nf_tables_core.c
index fb8b5892b5ff..36ba4e55d84e 100644
--- a/net/netfilter/nf_tables_core.c
+++ b/net/netfilter/nf_tables_core.c
@@ -98,7 +98,7 @@ static bool nft_payload_fast_eval(const struct nft_expr *expr,
 
 	ptr += priv->offset;
 
-	if (unlikely(ptr + priv->len >= skb_tail_pointer(skb)))
+	if (unlikely(ptr + priv->len > skb_tail_pointer(skb)))
 		return false;
 
 	*dest = 0;
-- 
2.1.4
