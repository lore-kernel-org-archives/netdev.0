From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: [PATCH] sctp: flush if we can't fit another DATA chunk
Date: Tue, 29 Mar 2016 10:41:25 -0300
Message-ID: <1459258885-21502-1-git-send-email-marcelo.leitner@gmail.com>
Cc: Neil Horman <nhorman@tuxdriver.com>,
	Vlad Yasevich <vyasevich@gmail.com>, linux-sctp@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43734 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756368AbcC2Nle (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Mar 2016 09:41:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is no point in delaying the packet if we can't fit a single byte
of data on it anymore. So lets just reduce the threshold by the amount
that a data chunk with 4 bytes (rounding) would use.

Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
---
 net/sctp/output.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/sctp/output.c b/net/sctp/output.c
index 97745351d58c2fb32b9f9b57d61831d7724d83b2..c518569123ce42a8f21f80754756306c39875013 100644
--- a/net/sctp/output.c
+++ b/net/sctp/output.c
@@ -705,7 +705,8 @@ static sctp_xmit_t sctp_packet_can_append_data(struct sctp_packet *packet,
 	/* Check whether this chunk and all the rest of pending data will fit
 	 * or delay in hopes of bundling a full sized packet.
 	 */
-	if (chunk->skb->len + q->out_qlen >= transport->pathmtu - packet->overhead)
+	if (chunk->skb->len + q->out_qlen >
+		maxsize - packet->overhead - sizeof(sctp_data_chunk_t) - 4)
 		/* Enough data queued to fill a packet */
 		return SCTP_XMIT_OK;
 
-- 
2.5.0
