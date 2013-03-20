From: pablo@netfilter.org
Subject: [PATCH 2/7] netfilter: nfnetlink_queue: fix incorrect initialization of copy range field
Date: Wed, 20 Mar 2013 11:49:29 +0100
Message-ID: <1363776574-4766-3-git-send-email-pablo@netfilter.org>
References: <1363776574-4766-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:51264 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755565Ab3CTKtt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Mar 2013 06:49:49 -0400
In-Reply-To: <1363776574-4766-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>

2^16 = 0xffff, not 0xfffff (note the extra 'f'). Not dangerous since you
adjust it to min_t(data_len, skb->len) just after on.

Reported-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nfnetlink_queue_core.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/nfnetlink_queue_core.c b/net/netfilter/nfnetlink_queue_core.c
index 858fd52..1cb4854 100644
--- a/net/netfilter/nfnetlink_queue_core.c
+++ b/net/netfilter/nfnetlink_queue_core.c
@@ -112,7 +112,7 @@ instance_create(u_int16_t queue_num, int portid)
 	inst->queue_num = queue_num;
 	inst->peer_portid = portid;
 	inst->queue_maxlen = NFQNL_QMAX_DEFAULT;
-	inst->copy_range = 0xfffff;
+	inst->copy_range = 0xffff;
 	inst->copy_mode = NFQNL_COPY_NONE;
 	spin_lock_init(&inst->lock);
 	INIT_LIST_HEAD(&inst->queue_list);
-- 
1.7.10.4
