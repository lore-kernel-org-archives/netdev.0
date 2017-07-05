From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net-next 11/11] sctp: remove the typedef sctp_hmac_algo_param_t
Date: Wed,  5 Jul 2017 08:32:29 +0800
Message-ID: <a50a59f2ce1f9a6da5c0a8a8fa44636c95090e78.1499214692.git.lucien.xin@gmail.com>
References: <cover.1499214692.git.lucien.xin@gmail.com>
 <6ba452f31d10acdc95f3cf679ecab15833f7843c.1499214692.git.lucien.xin@gmail.com>
 <77fa3a776118873a7e5d8203dd59011995b0e865.1499214692.git.lucien.xin@gmail.com>
 <090c24ed353f37a2bbce41ecc5feec6fc8cffa8b.1499214692.git.lucien.xin@gmail.com>
 <8d2e6145478bb4d24185d4ffd5547c7058f0dca9.1499214692.git.lucien.xin@gmail.com>
 <951d998920ecfe28f690739cd311bca3060751ff.1499214692.git.lucien.xin@gmail.com>
 <f094b5d16ed0f3b6fa255462bf957a104584f220.1499214692.git.lucien.xin@gmail.com>
 <afa9a191289fea55e077dcb4ad0bc34f7daee1b9.1499214692.git.lucien.xin@gmail.com>
 <47150ed6b890f50976139be3cd42df5c2f093fdd.1499214692.git.lucien.xin@gmail.com>
 <b3819a4686f14805c3d9d9a1a5612a3b151bbb5b.1499214692.git.lucien.xin@gmail.com>
 <ff452ac5711bd9ebffab97863e7e16984848f30b.1499214692.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:32769 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752282AbdGEAeQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 4 Jul 2017 20:34:16 -0400
In-Reply-To: <ff452ac5711bd9ebffab97863e7e16984848f30b.1499214692.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1499214692.git.lucien.xin@gmail.com>
References: <cover.1499214692.git.lucien.xin@gmail.com>
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
