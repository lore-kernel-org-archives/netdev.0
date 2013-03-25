From: pablo@netfilter.org
Subject: [PATCH 06/12] netfilter: nfnetlink_queue: use xor hash function to distribute instances
Date: Mon, 25 Mar 2013 13:15:46 +0100
Message-ID: <1364213752-3934-7-git-send-email-pablo@netfilter.org>
References: <1364213752-3934-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:46530 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756974Ab3CYMQQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Mar 2013 08:16:16 -0400
In-Reply-To: <1364213752-3934-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>

Thanks to Eric Dumazet for suggesting this during the NFWS.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nfnetlink_queue_core.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/nfnetlink_queue_core.c b/net/netfilter/nfnetlink_queue_core.c
index 858fd52..350c50f 100644
--- a/net/netfilter/nfnetlink_queue_core.c
+++ b/net/netfilter/nfnetlink_queue_core.c
@@ -73,7 +73,7 @@ static struct hlist_head instance_table[INSTANCE_BUCKETS] __read_mostly;
 
 static inline u_int8_t instance_hashfn(u_int16_t queue_num)
 {
-	return ((queue_num >> 8) | queue_num) % INSTANCE_BUCKETS;
+	return ((queue_num >> 8) ^ queue_num) % INSTANCE_BUCKETS;
 }
 
 static struct nfqnl_instance *
-- 
1.7.10.4
