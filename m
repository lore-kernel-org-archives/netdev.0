From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: [PATCH next] sctp: make use of WORD_TRUNC macro
Date: Thu, 15 Sep 2016 15:12:30 -0300
Message-ID: <b40b1bd4adff2d389588d9a4710af0399ce68d1e.1473963064.git.marcelo.leitner@gmail.com>
Cc: linux-sctp@vger.kernel.org, Neil Horman <nhorman@tuxdriver.com>,
        Vlad Yasevich <vyasevich@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41606 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753418AbcIOSMj (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 15 Sep 2016 14:12:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

No functional change. Just to avoid the usage of '&~3'.
Also break the line to make it easier to read.

Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
---
 net/sctp/chunk.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/net/sctp/chunk.c b/net/sctp/chunk.c
index a55e54738b81ff8cf9cd711cf5fc466ac71374c0..adae4a41ca2078cfee387631f76e5cb768c2269c 100644
--- a/net/sctp/chunk.c
+++ b/net/sctp/chunk.c
@@ -182,9 +182,10 @@ struct sctp_datamsg *sctp_datamsg_from_user(struct sctp_association *asoc,
 	/* This is the biggest possible DATA chunk that can fit into
 	 * the packet
 	 */
-	max_data = (asoc->pathmtu -
-		sctp_sk(asoc->base.sk)->pf->af->net_header_len -
-		sizeof(struct sctphdr) - sizeof(struct sctp_data_chunk)) & ~3;
+	max_data = asoc->pathmtu -
+		   sctp_sk(asoc->base.sk)->pf->af->net_header_len -
+		   sizeof(struct sctphdr) - sizeof(struct sctp_data_chunk);
+	max_data = WORD_TRUNC(max_data);
 
 	max = asoc->frag_point;
 	/* If the the peer requested that we authenticate DATA chunks
-- 
2.7.4
