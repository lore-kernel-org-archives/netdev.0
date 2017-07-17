From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCHv2 net-next 10/11] sctp: remove the typedef sctp_chunks_param_t
Date: Mon, 17 Jul 2017 11:29:58 +0800
Message-ID: <9bb0e27cbd338aa6ec71a07d19cad692edabe80b.1500261974.git.lucien.xin@gmail.com>
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
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:36280 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751248AbdGQDb2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 16 Jul 2017 23:31:28 -0400
In-Reply-To: <febcd28f69981f971e95de45041e834692e0f03e.1500261974.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1500261974.git.lucien.xin@gmail.com>
References: <cover.1500261974.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to remove the typedef sctp_chunks_param_t, and
replace with struct sctp_chunks_param in the places where it's
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
index 9b1aa39..b52def9 100644
--- a/include/linux/sctp.h
+++ b/include/linux/sctp.h
@@ -321,10 +321,10 @@ struct sctp_random_param {
 };
 
 /* AUTH Section 3.2 Chunk List */
-typedef struct sctp_chunks_param {
+struct sctp_chunks_param {
 	struct sctp_paramhdr param_hdr;
 	__u8 chunks[0];
-} sctp_chunks_param_t;
+};
 
 /* AUTH Section 3.3 HMAC Algorithm */
 typedef struct sctp_hmac_algo_param {
diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index f22c079..8042e63 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -1557,7 +1557,7 @@ struct sctp_association {
 		 * cookie and these are just pointers to those locations
 		 */
 		struct sctp_random_param *peer_random;
-		sctp_chunks_param_t *peer_chunks;
+		struct sctp_chunks_param *peer_chunks;
 		sctp_hmac_algo_param_t *peer_hmacs;
 	} peer;
 
diff --git a/net/sctp/auth.c b/net/sctp/auth.c
index 0d9c63e..367994d 100644
--- a/net/sctp/auth.c
+++ b/net/sctp/auth.c
@@ -186,7 +186,7 @@ static int sctp_auth_compare_vectors(struct sctp_auth_bytes *vector1,
  */
 static struct sctp_auth_bytes *sctp_auth_make_key_vector(
 			struct sctp_random_param *random,
-			sctp_chunks_param_t *chunks,
+			struct sctp_chunks_param *chunks,
 			sctp_hmac_algo_param_t *hmacs,
 			gfp_t gfp)
 {
@@ -227,7 +227,7 @@ static struct sctp_auth_bytes *sctp_auth_make_local_vector(
 {
 	return sctp_auth_make_key_vector(
 			(struct sctp_random_param *)asoc->c.auth_random,
-			(sctp_chunks_param_t *)asoc->c.auth_chunks,
+			(struct sctp_chunks_param *)asoc->c.auth_chunks,
 			(sctp_hmac_algo_param_t *)asoc->c.auth_hmacs, gfp);
 }
 
diff --git a/net/sctp/endpointola.c b/net/sctp/endpointola.c
index 0e86f98..35bf5af 100644
--- a/net/sctp/endpointola.c
+++ b/net/sctp/endpointola.c
@@ -78,8 +78,8 @@ static struct sctp_endpoint *sctp_endpoint_init(struct sctp_endpoint *ep,
 		if (!auth_hmacs)
 			goto nomem;
 
-		auth_chunks = kzalloc(sizeof(sctp_chunks_param_t) +
-					SCTP_NUM_CHUNK_TYPES, gfp);
+		auth_chunks = kzalloc(sizeof(*auth_chunks) +
+				      SCTP_NUM_CHUNK_TYPES, gfp);
 		if (!auth_chunks)
 			goto nomem;
 
-- 
2.1.0
