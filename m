From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net-next 01/11] sctp: remove the typedef sctp_initack_chunk_t
Date: Sun, 23 Jul 2017 09:34:26 +0800
Message-ID: <daa1cc9a380f5a1eb37b3d30fd64942d310fe81d.1500773578.git.lucien.xin@gmail.com>
References: <cover.1500773578.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:33889 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754501AbdGWBex (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 22 Jul 2017 21:34:53 -0400
In-Reply-To: <cover.1500773578.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1500773578.git.lucien.xin@gmail.com>
References: <cover.1500773578.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to remove the typedef sctp_initack_chunk_t, and
replace with struct sctp_initack_chunk in the places where it's
using this typedef.

It is also to use sizeof(variable) instead of sizeof(type).

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/linux/sctp.h    |  5 ++++-
 net/sctp/sm_statefuns.c | 13 ++++++-------
 2 files changed, 10 insertions(+), 8 deletions(-)

diff --git a/include/linux/sctp.h b/include/linux/sctp.h
index 913474d..05c2099 100644
--- a/include/linux/sctp.h
+++ b/include/linux/sctp.h
@@ -336,7 +336,10 @@ struct sctp_hmac_algo_param {
  *   The INIT ACK chunk is used to acknowledge the initiation of an SCTP
  *   association.
  */
-typedef struct sctp_init_chunk sctp_initack_chunk_t;
+struct sctp_initack_chunk {
+	struct sctp_chunkhdr chunk_hdr;
+	struct sctp_inithdr init_hdr;
+};
 
 /* Section 3.3.3.1 State Cookie (7) */
 typedef struct sctp_cookie_param {
diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index ae4c48c..6568fc3 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -518,7 +518,7 @@ sctp_disposition_t sctp_sf_do_5_1C_ack(struct net *net,
 		return sctp_sf_violation_chunk(net, ep, asoc, type, arg, commands);
 
 	/* Make sure that the INIT-ACK chunk has a valid length */
-	if (!sctp_chunk_length_valid(chunk, sizeof(sctp_initack_chunk_t)))
+	if (!sctp_chunk_length_valid(chunk, sizeof(struct sctp_initack_chunk)))
 		return sctp_sf_violation_chunklen(net, ep, asoc, type, arg,
 						  commands);
 	/* Grab the INIT header.  */
@@ -4453,11 +4453,10 @@ static sctp_disposition_t sctp_sf_abort_violation(
 		/* Treat INIT-ACK as a special case during COOKIE-WAIT. */
 		if (chunk->chunk_hdr->type == SCTP_CID_INIT_ACK &&
 		    !asoc->peer.i.init_tag) {
-			sctp_initack_chunk_t *initack;
+			struct sctp_initack_chunk *initack;
 
-			initack = (sctp_initack_chunk_t *)chunk->chunk_hdr;
-			if (!sctp_chunk_length_valid(chunk,
-						     sizeof(sctp_initack_chunk_t)))
+			initack = (struct sctp_initack_chunk *)chunk->chunk_hdr;
+			if (!sctp_chunk_length_valid(chunk, sizeof(*initack)))
 				abort->chunk_hdr->flags |= SCTP_CHUNK_FLAG_T;
 			else {
 				unsigned int inittag;
@@ -6106,9 +6105,9 @@ static struct sctp_packet *sctp_ootb_pkt_new(struct net *net,
 		switch (chunk->chunk_hdr->type) {
 		case SCTP_CID_INIT_ACK:
 		{
-			sctp_initack_chunk_t *initack;
+			struct sctp_initack_chunk *initack;
 
-			initack = (sctp_initack_chunk_t *)chunk->chunk_hdr;
+			initack = (struct sctp_initack_chunk *)chunk->chunk_hdr;
 			vtag = ntohl(initack->init_hdr.init_tag);
 			break;
 		}
-- 
2.1.0
