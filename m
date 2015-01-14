From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 6/8] netfilter: nf_ct_seqadj: print ack seq in the right host byte order
Date: Wed, 14 Jan 2015 21:34:47 +0100
Message-ID: <1421267689-24894-7-git-send-email-pablo@netfilter.org>
References: <1421267689-24894-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:49661 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752099AbbANUcF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Jan 2015 15:32:05 -0500
In-Reply-To: <1421267689-24894-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao feng <gaofeng@cn.fujitsu.com>

new_start_seq and new_end_seq are network byte order,
print the host byte order in debug message and print
seq number as the type of unsigned int.

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
Signed-off-by: Pablo Neira Ayuso <pablo@soleta.eu>
---
 net/netfilter/nf_conntrack_seqadj.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/netfilter/nf_conntrack_seqadj.c b/net/netfilter/nf_conntrack_seqadj.c
index f6e2ae9..ce3e840c8 100644
--- a/net/netfilter/nf_conntrack_seqadj.c
+++ b/net/netfilter/nf_conntrack_seqadj.c
@@ -98,9 +98,9 @@ static void nf_ct_sack_block_adjust(struct sk_buff *skb,
 			new_end_seq = htonl(ntohl(sack->end_seq) -
 				      seq->offset_before);
 
-		pr_debug("sack_adjust: start_seq: %d->%d, end_seq: %d->%d\n",
-			 ntohl(sack->start_seq), new_start_seq,
-			 ntohl(sack->end_seq), new_end_seq);
+		pr_debug("sack_adjust: start_seq: %u->%u, end_seq: %u->%u\n",
+			 ntohl(sack->start_seq), ntohl(new_start_seq),
+			 ntohl(sack->end_seq), ntohl(new_end_seq));
 
 		inet_proto_csum_replace4(&tcph->check, skb,
 					 sack->start_seq, new_start_seq, 0);
-- 
1.7.10.4
