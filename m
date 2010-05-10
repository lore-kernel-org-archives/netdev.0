From: kaber@trash.net
Subject: [PATCH 58/84] netfilter: only do skb_checksum_help on CHECKSUM_PARTIAL in nfnetlink_queue
Date: Mon, 10 May 2010 22:18:29 +0200
Message-ID: <1273522735-24672-59-git-send-email-kaber@trash.net>
References: <1273522735-24672-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1273522735-24672-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>

As we will set ip_summed to CHECKSUM_NONE when necessary in
nfqnl_mangle, there is no need to zap CHECKSUM_COMPLETE in
nfqnl_build_packet_message.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/netfilter/nfnetlink_queue.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/nfnetlink_queue.c b/net/netfilter/nfnetlink_queue.c
index 7ba4abc..08c1a33 100644
--- a/net/netfilter/nfnetlink_queue.c
+++ b/net/netfilter/nfnetlink_queue.c
@@ -245,8 +245,7 @@ nfqnl_build_packet_message(struct nfqnl_instance *queue,
 		break;
 
 	case NFQNL_COPY_PACKET:
-		if ((entskb->ip_summed == CHECKSUM_PARTIAL ||
-		     entskb->ip_summed == CHECKSUM_COMPLETE) &&
+		if (entskb->ip_summed == CHECKSUM_PARTIAL &&
 		    skb_checksum_help(entskb)) {
 			spin_unlock_bh(&queue->lock);
 			return NULL;
-- 
1.7.0.4

