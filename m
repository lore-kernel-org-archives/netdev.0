From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 02/12] netfilter: nfnetlink_log: Use GFP_NOWARN for skb allocation
Date: Tue,  1 Nov 2016 22:26:23 +0100
Message-ID: <1478035593-1362-3-git-send-email-pablo@netfilter.org>
References: <1478035593-1362-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:52512 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932207AbcKAV0s (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 1 Nov 2016 17:26:48 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 523231683A7
        for <netdev@vger.kernel.org>; Tue,  1 Nov 2016 22:26:46 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 3E2FDBAC26
        for <netdev@vger.kernel.org>; Tue,  1 Nov 2016 22:26:46 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 29EECDA850
        for <netdev@vger.kernel.org>; Tue,  1 Nov 2016 22:26:40 +0100 (CET)
In-Reply-To: <1478035593-1362-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Calvin Owens <calvinowens@fb.com>

Since the code explicilty falls back to a smaller allocation when the
large one fails, we shouldn't complain when that happens.

Signed-off-by: Calvin Owens <calvinowens@fb.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nfnetlink_log.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/nfnetlink_log.c b/net/netfilter/nfnetlink_log.c
index eb086a192c5a..7435505037b7 100644
--- a/net/netfilter/nfnetlink_log.c
+++ b/net/netfilter/nfnetlink_log.c
@@ -330,7 +330,7 @@ nfulnl_alloc_skb(struct net *net, u32 peer_portid, unsigned int inst_size,
 	 * message.  WARNING: has to be <= 128k due to slab restrictions */
 
 	n = max(inst_size, pkt_size);
-	skb = alloc_skb(n, GFP_ATOMIC);
+	skb = alloc_skb(n, GFP_ATOMIC | __GFP_NOWARN);
 	if (!skb) {
 		if (n > pkt_size) {
 			/* try to allocate only as much as we need for current
-- 
2.1.4
