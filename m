From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net-next 02/14] sctp: fix the name of struct sctp_shutdown_chunk_t
Date: Thu,  3 Aug 2017 15:42:10 +0800
Message-ID: <457c0c30e478f1ead75d3606e17519ca23daddfc.1501745729.git.lucien.xin@gmail.com>
References: <cover.1501745729.git.lucien.xin@gmail.com>
 <8149f8b0a190eb047abfe48a7fa79ba74e4e4544.1501745729.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:32781 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751220AbdHCHms (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2017 03:42:48 -0400
In-Reply-To: <8149f8b0a190eb047abfe48a7fa79ba74e4e4544.1501745729.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1501745729.git.lucien.xin@gmail.com>
References: <cover.1501745729.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to fix the name of struct sctp_shutdown_chunk_t
, replace with struct sctp_initack_chunk in the places where
it's using it.

It is also to fix some indent problem.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/linux/sctp.h    |  2 +-
 net/sctp/sm_statefuns.c | 16 ++++++++--------
 2 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/include/linux/sctp.h b/include/linux/sctp.h
index 7a586ba..553020c 100644
--- a/include/linux/sctp.h
+++ b/include/linux/sctp.h
@@ -420,7 +420,7 @@ struct sctp_shutdownhdr {
 	__be32 cum_tsn_ack;
 };
 
-struct sctp_shutdown_chunk_t {
+struct sctp_shutdown_chunk {
 	struct sctp_chunkhdr chunk_hdr;
 	struct sctp_shutdownhdr shutdown_hdr;
 };
diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index 5b95e2d..d4d8fab 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -2665,8 +2665,7 @@ sctp_disposition_t sctp_sf_do_9_2_shutdown(struct net *net,
 		return sctp_sf_pdiscard(net, ep, asoc, type, arg, commands);
 
 	/* Make sure that the SHUTDOWN chunk has a valid length. */
-	if (!sctp_chunk_length_valid(chunk,
-				      sizeof(struct sctp_shutdown_chunk_t)))
+	if (!sctp_chunk_length_valid(chunk, sizeof(struct sctp_shutdown_chunk)))
 		return sctp_sf_violation_chunklen(net, ep, asoc, type, arg,
 						  commands);
 
@@ -2753,8 +2752,7 @@ sctp_disposition_t sctp_sf_do_9_2_shut_ctsn(struct net *net,
 		return sctp_sf_pdiscard(net, ep, asoc, type, arg, commands);
 
 	/* Make sure that the SHUTDOWN chunk has a valid length. */
-	if (!sctp_chunk_length_valid(chunk,
-				      sizeof(struct sctp_shutdown_chunk_t)))
+	if (!sctp_chunk_length_valid(chunk, sizeof(struct sctp_shutdown_chunk)))
 		return sctp_sf_violation_chunklen(net, ep, asoc, type, arg,
 						  commands);
 
@@ -5419,12 +5417,14 @@ sctp_disposition_t sctp_sf_do_9_2_shutdown_ack(
 	 */
 	if (chunk) {
 		if (!sctp_vtag_verify(chunk, asoc))
-			return sctp_sf_pdiscard(net, ep, asoc, type, arg, commands);
+			return sctp_sf_pdiscard(net, ep, asoc, type, arg,
+						commands);
 
 		/* Make sure that the SHUTDOWN chunk has a valid length. */
-		if (!sctp_chunk_length_valid(chunk, sizeof(struct sctp_shutdown_chunk_t)))
-			return sctp_sf_violation_chunklen(net, ep, asoc, type, arg,
-							  commands);
+		if (!sctp_chunk_length_valid(
+				chunk, sizeof(struct sctp_shutdown_chunk)))
+			return sctp_sf_violation_chunklen(net, ep, asoc, type,
+							  arg, commands);
 	}
 
 	/* If it has no more outstanding DATA chunks, the SHUTDOWN receiver
-- 
2.1.0
