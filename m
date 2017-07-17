From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCHv2 net-next 11/11] sctp: remove the typedef sctp_hmac_algo_param_t
Date: Mon, 17 Jul 2017 11:29:59 +0800
Message-ID: <d1fd31b9587d5bf729ad95b524b89872ee5a1f5d.1500261974.git.lucien.xin@gmail.com>
References: <cover.1500261974.git.lucien.xin@gmail.com>
 <cadd1baef89e215244af82032957ccde1189bcc8.1500261974.git.lucien.xin@gmail.com>
 <0add39ae0879e3b332bafc24aa6ccdb6b0d5c85a.1500261974.git.lucien.xin@gmail.com>
 <c8cdb622f7de0edc639936e3fa15a262e92cfa66.1500261974.git.lucien.xin@gmail.com>
 <7faff4d9e2bef97652b742006c0165641ad84504.1500261974.git.lucien.xin@gmail.com>
 <6c3cea13894a96c24fb2e84fc0fab8363cb4b70f.1500261974.git.lucien.xin@gmail.com>
 <ec19ee88ce40e1e11b7bef6c84c1372dfebd5704.1500261974.git.lucien.xin@gmail.com>
 <3dda87d79e20cdb2487fc3baa3ffad883bb3a7fb.1500261974.git.lucien.xin@gmail.com>
 <2d6a7b26e6b2766ed9fd0d86d8ac390e12762b02.1500261974.git.lucien.xin@gmail.com>
 <febcd28f69981f971e95de45041e834692e0f03e.1500261974.git.lucien.xin@gmail.com>
 <9bb0e27cbd338aa6ec71a07d19cad692edabe80b.1500261974.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:33079 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751248AbdGQDbg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 16 Jul 2017 23:31:36 -0400
In-Reply-To: <9bb0e27cbd338aa6ec71a07d19cad692edabe80b.1500261974.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1500261974.git.lucien.xin@gmail.com>
References: <cover.1500261974.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to remove the typedef sctp_hmac_algo_param_t, and
replace with struct sctp_hmac_algo_param in the places where it's
using this typedef.

It is also to use sizeof(variable) instead of sizeof(type).

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/linux/sctp.h       | 4 ++--
 include/net/sctp/structs.h | 2 +-
 net/sctp/auth.c            | 4 ++--
 net/sctp/endpointola.c     | 4 ++--
 4 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/include/linux/sctp.h b/include/linux/sctp.h
index b52def9..913474d 100644
--- a/include/linux/sctp.h
+++ b/include/linux/sctp.h
@@ -327,10 +327,10 @@ struct sctp_chunks_param {
 };
 
 /* AUTH Section 3.3 HMAC Algorithm */
-typedef struct sctp_hmac_algo_param {
+struct sctp_hmac_algo_param {
 	struct sctp_paramhdr param_hdr;
 	__be16 hmac_ids[0];
-} sctp_hmac_algo_param_t;
+};
 
 /* RFC 2960.  Section 3.3.3 Initiation Acknowledgement (INIT ACK) (2):
  *   The INIT ACK chunk is used to acknowledge the initiation of an SCTP
diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index 8042e63..66cd763 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -1558,7 +1558,7 @@ struct sctp_association {
 		 */
 		struct sctp_random_param *peer_random;
 		struct sctp_chunks_param *peer_chunks;
-		sctp_hmac_algo_param_t *peer_hmacs;
+		struct sctp_hmac_algo_param *peer_hmacs;
 	} peer;
 
 	/* State       : A state variable indicating what state the
diff --git a/net/sctp/auth.c b/net/sctp/auth.c
index 367994d..00667c5 100644
--- a/net/sctp/auth.c
+++ b/net/sctp/auth.c
@@ -187,7 +187,7 @@ static int sctp_auth_compare_vectors(struct sctp_auth_bytes *vector1,
 static struct sctp_auth_bytes *sctp_auth_make_key_vector(
 			struct sctp_random_param *random,
 			struct sctp_chunks_param *chunks,
-			sctp_hmac_algo_param_t *hmacs,
+			struct sctp_hmac_algo_param *hmacs,
 			gfp_t gfp)
 {
 	struct sctp_auth_bytes *new;
@@ -228,7 +228,7 @@ static struct sctp_auth_bytes *sctp_auth_make_local_vector(
 	return sctp_auth_make_key_vector(
 			(struct sctp_random_param *)asoc->c.auth_random,
 			(struct sctp_chunks_param *)asoc->c.auth_chunks,
-			(sctp_hmac_algo_param_t *)asoc->c.auth_hmacs, gfp);
+			(struct sctp_hmac_algo_param *)asoc->c.auth_hmacs, gfp);
 }
 
 /* Make a key vector based on peer's parameters */
diff --git a/net/sctp/endpointola.c b/net/sctp/endpointola.c
index 35bf5af..3d506b2 100644
--- a/net/sctp/endpointola.c
+++ b/net/sctp/endpointola.c
@@ -73,8 +73,8 @@ static struct sctp_endpoint *sctp_endpoint_init(struct sctp_endpoint *ep,
 		 * variables.  There are arrays that we encode directly
 		 * into parameters to make the rest of the operations easier.
 		 */
-		auth_hmacs = kzalloc(sizeof(sctp_hmac_algo_param_t) +
-				sizeof(__u16) * SCTP_AUTH_NUM_HMACS, gfp);
+		auth_hmacs = kzalloc(sizeof(*auth_hmacs) +
+				     sizeof(__u16) * SCTP_AUTH_NUM_HMACS, gfp);
 		if (!auth_hmacs)
 			goto nomem;
 
-- 
2.1.0
