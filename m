From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 01/13] netfilter: nf_tables: fix issue with verdict support
Date: Mon,  6 Jan 2014 14:46:30 +0100
Message-ID: <1389016002-9116-2-git-send-email-pablo@netfilter.org>
References: <1389016002-9116-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:59526 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754662AbaAFNqy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Jan 2014 08:46:54 -0500
In-Reply-To: <1389016002-9116-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Leblond <eric@regit.org>

The test on verdict was simply done on the value of the verdict
which is not correct as far as queue is concern. In fact, the test
of verdict test must be done with respect to the verdict mask for
verdicts which are not internal to nftables.

Signed-off-by: Eric Leblond <eric@regit.org>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_tables_core.c |    5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/net/netfilter/nf_tables_core.c b/net/netfilter/nf_tables_core.c
index cb9e685..e8fcc34 100644
--- a/net/netfilter/nf_tables_core.c
+++ b/net/netfilter/nf_tables_core.c
@@ -164,7 +164,7 @@ next_rule:
 		break;
 	}
 
-	switch (data[NFT_REG_VERDICT].verdict) {
+	switch (data[NFT_REG_VERDICT].verdict & NF_VERDICT_MASK) {
 	case NF_ACCEPT:
 	case NF_DROP:
 	case NF_QUEUE:
@@ -172,6 +172,9 @@ next_rule:
 			nft_trace_packet(pkt, chain, rulenum, NFT_TRACE_RULE);
 
 		return data[NFT_REG_VERDICT].verdict;
+	}
+
+	switch (data[NFT_REG_VERDICT].verdict) {
 	case NFT_JUMP:
 		if (unlikely(pkt->skb->nf_trace))
 			nft_trace_packet(pkt, chain, rulenum, NFT_TRACE_RULE);
-- 
1.7.10.4
