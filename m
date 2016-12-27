From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: [PATCH net-next 2/5] sctp: reduce indent level in sctp_sf_shut_8_4_5
Date: Tue, 27 Dec 2016 15:08:29 -0200
Message-ID: <516c622c83445125697aa64f6c28c6538a09a37d.1482857832.git.marcelo.leitner@gmail.com>
References: <cover.1482857832.git.marcelo.leitner@gmail.com>
Cc: linux-sctp@vger.kernel.org, Vlad Yasevich <vyasevich@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f194.google.com ([209.85.220.194]:33613 "EHLO
        mail-qk0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753057AbcL0RKe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Dec 2016 12:10:34 -0500
In-Reply-To: <cover.1482857832.git.marcelo.leitner@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
---
 net/sctp/sm_statefuns.c | 58 ++++++++++++++++++++++++-------------------------
 1 file changed, 28 insertions(+), 30 deletions(-)

diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index 32587b1f84e729221965e270607fea7ef93a7430..a95915ef9dbabad30f6171f77b26feab61752f36 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -3501,45 +3501,43 @@ static sctp_disposition_t sctp_sf_shut_8_4_5(struct net *net,
 	struct sctp_chunk *shut;
 
 	packet = sctp_ootb_pkt_new(net, asoc, chunk);
+	if (!packet)
+		return SCTP_DISPOSITION_NOMEM;
 
-	if (packet) {
-		/* Make an SHUTDOWN_COMPLETE.
-		 * The T bit will be set if the asoc is NULL.
-		 */
-		shut = sctp_make_shutdown_complete(asoc, chunk);
-		if (!shut) {
-			sctp_ootb_pkt_free(packet);
-			return SCTP_DISPOSITION_NOMEM;
-		}
-
-		/* Reflect vtag if T-Bit is set */
-		if (sctp_test_T_bit(shut))
-			packet->vtag = ntohl(chunk->sctp_hdr->vtag);
+	/* Make an SHUTDOWN_COMPLETE.
+	 * The T bit will be set if the asoc is NULL.
+	 */
+	shut = sctp_make_shutdown_complete(asoc, chunk);
+	if (!shut) {
+		sctp_ootb_pkt_free(packet);
+		return SCTP_DISPOSITION_NOMEM;
+	}
 
-		/* Set the skb to the belonging sock for accounting.  */
-		shut->skb->sk = ep->base.sk;
+	/* Reflect vtag if T-Bit is set */
+	if (sctp_test_T_bit(shut))
+		packet->vtag = ntohl(chunk->sctp_hdr->vtag);
 
-		sctp_packet_append_chunk(packet, shut);
+	/* Set the skb to the belonging sock for accounting.  */
+	shut->skb->sk = ep->base.sk;
 
-		sctp_add_cmd_sf(commands, SCTP_CMD_SEND_PKT,
-				SCTP_PACKET(packet));
+	sctp_packet_append_chunk(packet, shut);
 
-		SCTP_INC_STATS(net, SCTP_MIB_OUTCTRLCHUNKS);
+	sctp_add_cmd_sf(commands, SCTP_CMD_SEND_PKT,
+			SCTP_PACKET(packet));
 
-		/* If the chunk length is invalid, we don't want to process
-		 * the reset of the packet.
-		 */
-		if (!sctp_chunk_length_valid(chunk, sizeof(sctp_chunkhdr_t)))
-			return sctp_sf_pdiscard(net, ep, asoc, type, arg, commands);
+	SCTP_INC_STATS(net, SCTP_MIB_OUTCTRLCHUNKS);
 
-		/* We need to discard the rest of the packet to prevent
-		 * potential bomming attacks from additional bundled chunks.
-		 * This is documented in SCTP Threats ID.
-		 */
+	/* If the chunk length is invalid, we don't want to process
+	 * the reset of the packet.
+	 */
+	if (!sctp_chunk_length_valid(chunk, sizeof(sctp_chunkhdr_t)))
 		return sctp_sf_pdiscard(net, ep, asoc, type, arg, commands);
-	}
 
-	return SCTP_DISPOSITION_NOMEM;
+	/* We need to discard the rest of the packet to prevent
+	 * potential bomming attacks from additional bundled chunks.
+	 * This is documented in SCTP Threats ID.
+	 */
+	return sctp_sf_pdiscard(net, ep, asoc, type, arg, commands);
 }
 
 /*
-- 
2.9.3
