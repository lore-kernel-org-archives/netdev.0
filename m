From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCHv2 net-next 09/11] sctp: remove the typedef sctp_random_param_t
Date: Mon, 17 Jul 2017 11:29:57 +0800
Message-ID: <febcd28f69981f971e95de45041e834692e0f03e.1500261974.git.lucien.xin@gmail.com>
References: <cover.1500261974.git.lucien.xin@gmail.com>
 <cadd1baef89e215244af82032957ccde1189bcc8.1500261974.git.lucien.xin@gmail.com>
 <0add39ae0879e3b332bafc24aa6ccdb6b0d5c85a.1500261974.git.lucien.xin@gmail.com>
 <c8cdb622f7de0edc639936e3fa15a262e92cfa66.1500261974.git.lucien.xin@gmail.com>
 <7faff4d9e2bef97652b742006c0165641ad84504.1500261974.git.lucien.xin@gmail.com>
 <6c3cea13894a96c24fb2e84fc0fab8363cb4b70f.1500261974.git.lucien.xin@gmail.com>
 <ec19ee88ce40e1e11b7bef6c84c1372dfebd5704.1500261974.git.lucien.xin@gmail.com>
 <3dda87d79e20cdb2487fc3baa3ffad883bb3a7fb.1500261974.git.lucien.xin@gmail.com>
 <2d6a7b26e6b2766ed9fd0d86d8ac390e12762b02.1500261974.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:36238 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751248AbdGQDbU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 16 Jul 2017 23:31:20 -0400
In-Reply-To: <2d6a7b26e6b2766ed9fd0d86d8ac390e12762b02.1500261974.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1500261974.git.lucien.xin@gmail.com>
References: <cover.1500261974.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to remove the typedef sctp_random_param_t, and
replace with struct sctp_random_param in the places where it's
using this typedef.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/linux/sctp.h       | 4 ++--
 include/net/sctp/structs.h | 2 +-
 net/sctp/auth.c            | 9 ++++-----
 3 files changed, 7 insertions(+), 8 deletions(-)

diff --git a/include/linux/sctp.h b/include/linux/sctp.h
index 7624568..9b1aa39 100644
--- a/include/linux/sctp.h
+++ b/include/linux/sctp.h
@@ -315,10 +315,10 @@ struct sctp_supported_ext_param {
 };
 
 /* AUTH Section 3.1 Random */
-typedef struct sctp_random_param {
+struct sctp_random_param {
 	struct sctp_paramhdr param_hdr;
 	__u8 random_val[0];
-} sctp_random_param_t;
+};
 
 /* AUTH Section 3.2 Chunk List */
 typedef struct sctp_chunks_param {
diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index 5ab29af..f22c079 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -1556,7 +1556,7 @@ struct sctp_association {
 		 * and authenticated chunk list.  All that is part of the
 		 * cookie and these are just pointers to those locations
 		 */
-		sctp_random_param_t *peer_random;
+		struct sctp_random_param *peer_random;
 		sctp_chunks_param_t *peer_chunks;
 		sctp_hmac_algo_param_t *peer_hmacs;
 	} peer;
diff --git a/net/sctp/auth.c b/net/sctp/auth.c
index e001b01..0d9c63e 100644
--- a/net/sctp/auth.c
+++ b/net/sctp/auth.c
@@ -185,7 +185,7 @@ static int sctp_auth_compare_vectors(struct sctp_auth_bytes *vector1,
  *    are called the two key vectors.
  */
 static struct sctp_auth_bytes *sctp_auth_make_key_vector(
-			sctp_random_param_t *random,
+			struct sctp_random_param *random,
 			sctp_chunks_param_t *chunks,
 			sctp_hmac_algo_param_t *hmacs,
 			gfp_t gfp)
@@ -226,10 +226,9 @@ static struct sctp_auth_bytes *sctp_auth_make_local_vector(
 				    gfp_t gfp)
 {
 	return sctp_auth_make_key_vector(
-				    (sctp_random_param_t *)asoc->c.auth_random,
-				    (sctp_chunks_param_t *)asoc->c.auth_chunks,
-				    (sctp_hmac_algo_param_t *)asoc->c.auth_hmacs,
-				    gfp);
+			(struct sctp_random_param *)asoc->c.auth_random,
+			(sctp_chunks_param_t *)asoc->c.auth_chunks,
+			(sctp_hmac_algo_param_t *)asoc->c.auth_hmacs, gfp);
 }
 
 /* Make a key vector based on peer's parameters */
-- 
2.1.0
