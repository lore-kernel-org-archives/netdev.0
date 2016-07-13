From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: [PATCH net-next 5/6] sctp: do not clear chunk->ecn_ce_done flag
Date: Wed, 13 Jul 2016 15:08:59 -0300
Message-ID: <349cf5fdf54449cf16097503d5200f60ae388a65.1468432819.git.marcelo.leitner@gmail.com>
References: <cover.1468432819.git.marcelo.leitner@gmail.com>
Cc: Neil Horman <nhorman@tuxdriver.com>,
	Vlad Yasevich <vyasevich@gmail.com>, linux-sctp@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38166 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752604AbcGMSKD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Jul 2016 14:10:03 -0400
In-Reply-To: <cover.1468432819.git.marcelo.leitner@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We should not clear that flag when switching to a new skb from a GSO skb
because it would cause ECN processing to happen multiple times per GSO
skb, which is not wanted. Instead, let it be processed once per chunk.
That is, in other words, once per IP header available.

Fixes: 90017accff61 ("sctp: Add GSO support")
Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
---
 net/sctp/inqueue.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/net/sctp/inqueue.c b/net/sctp/inqueue.c
index 8fc773f9b59a8a9ad123dd132cfa5b7f916732b6..942770675f4cc0efc9686f4e4038450f060f34ae 100644
--- a/net/sctp/inqueue.c
+++ b/net/sctp/inqueue.c
@@ -217,7 +217,6 @@ new_skb:
 		chunk->auth = 0;
 		chunk->has_asconf = 0;
 		chunk->end_of_packet = 0;
-		chunk->ecn_ce_done = 0;
 		if (chunk->head_skb) {
 			struct sctp_input_cb
 				*cb = SCTP_INPUT_CB(chunk->skb),
-- 
2.7.4
