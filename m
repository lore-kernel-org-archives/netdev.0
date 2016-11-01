From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 12/12] netfilter: nf_queue: place volatile data in own cacheline
Date: Tue,  1 Nov 2016 22:26:33 +0100
Message-ID: <1478035593-1362-13-git-send-email-pablo@netfilter.org>
References: <1478035593-1362-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:52656 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932275AbcKAV1M (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 1 Nov 2016 17:27:12 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 65E231683AC
        for <netdev@vger.kernel.org>; Tue,  1 Nov 2016 22:27:10 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 55D58BAC2C
        for <netdev@vger.kernel.org>; Tue,  1 Nov 2016 22:27:10 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 09980BAC32
        for <netdev@vger.kernel.org>; Tue,  1 Nov 2016 22:27:08 +0100 (CET)
In-Reply-To: <1478035593-1362-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

As the comment indicates, the data at the end of nfqnl_instance struct is
written on every queue/dequeue, so it should reside in its own cacheline.

Before this change, 'lock' was in first cacheline so we dirtied both.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nfnetlink_queue.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/nfnetlink_queue.c b/net/netfilter/nfnetlink_queue.c
index af832c526048..5379f788a372 100644
--- a/net/netfilter/nfnetlink_queue.c
+++ b/net/netfilter/nfnetlink_queue.c
@@ -69,7 +69,7 @@ struct nfqnl_instance {
  * Following fields are dirtied for each queued packet,
  * keep them in same cache line if possible.
  */
-	spinlock_t	lock;
+	spinlock_t	lock	____cacheline_aligned_in_smp;
 	unsigned int	queue_total;
 	unsigned int	id_sequence;		/* 'sequence' of pkt ids */
 	struct list_head queue_list;		/* packets in queue */
-- 
2.1.4
