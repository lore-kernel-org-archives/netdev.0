From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net-next 04/14] sctp: remove the typedef sctp_operr_chunk_t
Date: Thu,  3 Aug 2017 15:42:12 +0800
Message-ID: <61746e2a2efa75634ab632cf264ad902aa3f9685.1501745729.git.lucien.xin@gmail.com>
References: <cover.1501745729.git.lucien.xin@gmail.com>
 <8149f8b0a190eb047abfe48a7fa79ba74e4e4544.1501745729.git.lucien.xin@gmail.com>
 <457c0c30e478f1ead75d3606e17519ca23daddfc.1501745729.git.lucien.xin@gmail.com>
 <ef0bf503017711311e9fc167c4b5bfd9de885d04.1501745729.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:37423 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751262AbdHCHnO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2017 03:43:14 -0400
In-Reply-To: <ef0bf503017711311e9fc167c4b5bfd9de885d04.1501745729.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1501745729.git.lucien.xin@gmail.com>
References: <cover.1501745729.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to remove the typedef sctp_operr_chunk_t, and
replace with struct sctp_operr_chunk in the places where it's
using this typedef.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/linux/sctp.h    | 4 ++--
 net/sctp/sm_statefuns.c | 4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/include/linux/sctp.h b/include/linux/sctp.h
index d35bdd3..07c12e9 100644
--- a/include/linux/sctp.h
+++ b/include/linux/sctp.h
@@ -433,10 +433,10 @@ struct sctp_errhdr {
 	__u8  variable[0];
 };
 
-typedef struct sctp_operr_chunk {
+struct sctp_operr_chunk {
 	struct sctp_chunkhdr chunk_hdr;
 	struct sctp_errhdr err_hdr;
-} sctp_operr_chunk_t;
+};
 
 /* RFC 2960 3.3.10 - Operation Error
  *
diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index 7a2ba4c..3b121d2 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -2278,7 +2278,7 @@ sctp_disposition_t sctp_sf_cookie_echoed_err(struct net *net,
 	/* Make sure that the ERROR chunk has a valid length.
 	 * The parameter walking depends on this as well.
 	 */
-	if (!sctp_chunk_length_valid(chunk, sizeof(sctp_operr_chunk_t)))
+	if (!sctp_chunk_length_valid(chunk, sizeof(struct sctp_operr_chunk)))
 		return sctp_sf_violation_chunklen(net, ep, asoc, type, arg,
 						  commands);
 
@@ -3317,7 +3317,7 @@ sctp_disposition_t sctp_sf_operr_notify(struct net *net,
 		return sctp_sf_pdiscard(net, ep, asoc, type, arg, commands);
 
 	/* Make sure that the ERROR chunk has a valid length. */
-	if (!sctp_chunk_length_valid(chunk, sizeof(sctp_operr_chunk_t)))
+	if (!sctp_chunk_length_valid(chunk, sizeof(struct sctp_operr_chunk)))
 		return sctp_sf_violation_chunklen(net, ep, asoc, type, arg,
 						  commands);
 	sctp_walk_errors(err, chunk->chunk_hdr);
-- 
2.1.0
