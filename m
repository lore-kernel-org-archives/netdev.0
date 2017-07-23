From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net-next 03/11] sctp: remove the typedef sctp_unrecognized_param_t
Date: Sun, 23 Jul 2017 09:34:28 +0800
Message-ID: <54eca4d5d79aae83b386754b4613edc388521d54.1500773578.git.lucien.xin@gmail.com>
References: <cover.1500773578.git.lucien.xin@gmail.com>
 <daa1cc9a380f5a1eb37b3d30fd64942d310fe81d.1500773578.git.lucien.xin@gmail.com>
 <78a33af4a9d7ef7116637943dbd0ae1403d20114.1500773578.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:36071 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755172AbdGWBfJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 22 Jul 2017 21:35:09 -0400
In-Reply-To: <78a33af4a9d7ef7116637943dbd0ae1403d20114.1500773578.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1500773578.git.lucien.xin@gmail.com>
References: <cover.1500773578.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to remove the typedef sctp_unrecognized_param_t, and
replace with struct sctp_unrecognized_param in the places where it's
using this typedef.

It is also to fix some indents in sctp_sf_do_unexpected_init() and
sctp_sf_do_5_1B_init().

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/linux/sctp.h    |  4 ++--
 net/sctp/sm_statefuns.c | 18 +++++++-----------
 2 files changed, 9 insertions(+), 13 deletions(-)

diff --git a/include/linux/sctp.h b/include/linux/sctp.h
index 9e77abd..c323b3e 100644
--- a/include/linux/sctp.h
+++ b/include/linux/sctp.h
@@ -348,10 +348,10 @@ struct sctp_cookie_param {
 };
 
 /* Section 3.3.3.1 Unrecognized Parameters (8) */
-typedef struct sctp_unrecognized_param {
+struct sctp_unrecognized_param {
 	struct sctp_paramhdr param_hdr;
 	struct sctp_paramhdr unrecognized;
-} sctp_unrecognized_param_t;
+};
 
 
 
diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index 6568fc3..7f85239 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -306,12 +306,10 @@ sctp_disposition_t sctp_sf_do_5_1B_init(struct net *net,
 					void *arg,
 					sctp_cmd_seq_t *commands)
 {
-	struct sctp_chunk *chunk = arg;
-	struct sctp_chunk *repl;
+	struct sctp_chunk *chunk = arg, *repl, *err_chunk;
+	struct sctp_unrecognized_param *unk_param;
 	struct sctp_association *new_asoc;
-	struct sctp_chunk *err_chunk;
 	struct sctp_packet *packet;
-	sctp_unrecognized_param_t *unk_param;
 	int len;
 
 	/* 6.10 Bundling
@@ -435,7 +433,7 @@ sctp_disposition_t sctp_sf_do_5_1B_init(struct net *net,
 		 * construct the parameters in INIT ACK by copying the
 		 * ERROR causes over.
 		 */
-		unk_param = (sctp_unrecognized_param_t *)
+		unk_param = (struct sctp_unrecognized_param *)
 			    ((__u8 *)(err_chunk->chunk_hdr) +
 			    sizeof(struct sctp_chunkhdr));
 		/* Replace the cause code with the "Unrecognized parameter"
@@ -1419,13 +1417,11 @@ static sctp_disposition_t sctp_sf_do_unexpected_init(
 	const sctp_subtype_t type,
 	void *arg, sctp_cmd_seq_t *commands)
 {
-	sctp_disposition_t retval;
-	struct sctp_chunk *chunk = arg;
-	struct sctp_chunk *repl;
+	struct sctp_chunk *chunk = arg, *repl, *err_chunk;
+	struct sctp_unrecognized_param *unk_param;
 	struct sctp_association *new_asoc;
-	struct sctp_chunk *err_chunk;
 	struct sctp_packet *packet;
-	sctp_unrecognized_param_t *unk_param;
+	sctp_disposition_t retval;
 	int len;
 
 	/* 6.10 Bundling
@@ -1555,7 +1551,7 @@ static sctp_disposition_t sctp_sf_do_unexpected_init(
 		 * construct the parameters in INIT ACK by copying the
 		 * ERROR causes over.
 		 */
-		unk_param = (sctp_unrecognized_param_t *)
+		unk_param = (struct sctp_unrecognized_param *)
 			    ((__u8 *)(err_chunk->chunk_hdr) +
 			    sizeof(struct sctp_chunkhdr));
 		/* Replace the cause code with the "Unrecognized parameter"
-- 
2.1.0
