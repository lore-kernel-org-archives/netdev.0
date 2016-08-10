From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 7/9] netfilter: nfnetlink_queue: reject verdict request from different portid
Date: Wed, 10 Aug 2016 21:16:43 +0200
Message-ID: <1470856605-7903-8-git-send-email-pablo@netfilter.org>
References: <1470856605-7903-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:58042 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S941254AbcHJTRE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Aug 2016 15:17:04 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id 9A3001F18CB
	for <netdev@vger.kernel.org>; Wed, 10 Aug 2016 21:16:57 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 8A573100798
	for <netdev@vger.kernel.org>; Wed, 10 Aug 2016 21:16:57 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 96414FF2FE
	for <netdev@vger.kernel.org>; Wed, 10 Aug 2016 21:16:55 +0200 (CEST)
In-Reply-To: <1470856605-7903-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Liping Zhang <liping.zhang@spreadtrum.com>

Like NFQNL_MSG_VERDICT_BATCH do, we should also reject the verdict
request when the portid is not same with the initial portid(maybe
from another process).

Fixes: 97d32cf9440d ("netfilter: nfnetlink_queue: batch verdict support")
Signed-off-by: Liping Zhang <liping.zhang@spreadtrum.com>
Reviewed-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nfnetlink_queue.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/net/netfilter/nfnetlink_queue.c b/net/netfilter/nfnetlink_queue.c
index 5d36a09..f49f450 100644
--- a/net/netfilter/nfnetlink_queue.c
+++ b/net/netfilter/nfnetlink_queue.c
@@ -1145,10 +1145,8 @@ static int nfqnl_recv_verdict(struct net *net, struct sock *ctnl,
 	struct nfnl_queue_net *q = nfnl_queue_pernet(net);
 	int err;
 
-	queue = instance_lookup(q, queue_num);
-	if (!queue)
-		queue = verdict_instance_lookup(q, queue_num,
-						NETLINK_CB(skb).portid);
+	queue = verdict_instance_lookup(q, queue_num,
+					NETLINK_CB(skb).portid);
 	if (IS_ERR(queue))
 		return PTR_ERR(queue);
 
-- 
2.1.4
