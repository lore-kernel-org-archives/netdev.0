From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net-next 09/11] sctp: remove the typedef sctp_random_param_t
Date: Wed,  5 Jul 2017 08:32:27 +0800
Message-ID: <b3819a4686f14805c3d9d9a1a5612a3b151bbb5b.1499214692.git.lucien.xin@gmail.com>
References: <cover.1499214692.git.lucien.xin@gmail.com>
 <6ba452f31d10acdc95f3cf679ecab15833f7843c.1499214692.git.lucien.xin@gmail.com>
 <77fa3a776118873a7e5d8203dd59011995b0e865.1499214692.git.lucien.xin@gmail.com>
 <090c24ed353f37a2bbce41ecc5feec6fc8cffa8b.1499214692.git.lucien.xin@gmail.com>
 <8d2e6145478bb4d24185d4ffd5547c7058f0dca9.1499214692.git.lucien.xin@gmail.com>
 <951d998920ecfe28f690739cd311bca3060751ff.1499214692.git.lucien.xin@gmail.com>
 <f094b5d16ed0f3b6fa255462bf957a104584f220.1499214692.git.lucien.xin@gmail.com>
 <afa9a191289fea55e077dcb4ad0bc34f7daee1b9.1499214692.git.lucien.xin@gmail.com>
 <47150ed6b890f50976139be3cd42df5c2f093fdd.1499214692.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:36566 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752282AbdGEAdz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 4 Jul 2017 20:33:55 -0400
In-Reply-To: <47150ed6b890f50976139be3cd42df5c2f093fdd.1499214692.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1499214692.git.lucien.xin@gmail.com>
References: <cover.1499214692.git.lucien.xin@gmail.com>
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
