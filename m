From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net-next 08/11] sctp: remove the typedef sctp_supported_ext_param_t
Date: Wed,  5 Jul 2017 08:32:26 +0800
Message-ID: <47150ed6b890f50976139be3cd42df5c2f093fdd.1499214692.git.lucien.xin@gmail.com>
References: <cover.1499214692.git.lucien.xin@gmail.com>
 <6ba452f31d10acdc95f3cf679ecab15833f7843c.1499214692.git.lucien.xin@gmail.com>
 <77fa3a776118873a7e5d8203dd59011995b0e865.1499214692.git.lucien.xin@gmail.com>
 <090c24ed353f37a2bbce41ecc5feec6fc8cffa8b.1499214692.git.lucien.xin@gmail.com>
 <8d2e6145478bb4d24185d4ffd5547c7058f0dca9.1499214692.git.lucien.xin@gmail.com>
 <951d998920ecfe28f690739cd311bca3060751ff.1499214692.git.lucien.xin@gmail.com>
 <f094b5d16ed0f3b6fa255462bf957a104584f220.1499214692.git.lucien.xin@gmail.com>
 <afa9a191289fea55e077dcb4ad0bc34f7daee1b9.1499214692.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:33427 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752282AbdGEAdr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 4 Jul 2017 20:33:47 -0400
In-Reply-To: <afa9a191289fea55e077dcb4ad0bc34f7daee1b9.1499214692.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1499214692.git.lucien.xin@gmail.com>
References: <cover.1499214692.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to remove the typedef sctp_supported_ext_param_t, and
replace with struct sctp_supported_ext_param in the places where it's
using this typedef.

It is also to use sizeof(variable) instead of sizeof(type).

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/linux/sctp.h     |  4 ++--
 net/sctp/sm_make_chunk.c | 22 ++++++++--------------
 2 files changed, 10 insertions(+), 16 deletions(-)

diff --git a/include/linux/sctp.h b/include/linux/sctp.h
index 72b8787..7624568 100644
--- a/include/linux/sctp.h
+++ b/include/linux/sctp.h
@@ -309,10 +309,10 @@ struct sctp_adaptation_ind_param {
 };
 
 /* ADDIP Section 4.2.7 Supported Extensions Parameter */
-typedef struct sctp_supported_ext_param {
+struct sctp_supported_ext_param {
 	struct sctp_paramhdr param_hdr;
 	__u8 chunks[0];
-} sctp_supported_ext_param_t;
+};
 
 /* AUTH Section 3.1 Random */
 typedef struct sctp_random_param {
diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index d5f82c2..06dc351 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -226,7 +226,7 @@ struct sctp_chunk *sctp_make_init(const struct sctp_association *asoc,
 	struct sctp_supported_addrs_param sat;
 	__be16 types[2];
 	struct sctp_adaptation_ind_param aiparam;
-	sctp_supported_ext_param_t ext_param;
+	struct sctp_supported_ext_param ext_param;
 	int num_ext = 0;
 	__u8 extensions[3];
 	struct sctp_paramhdr *auth_chunks = NULL,
@@ -305,8 +305,7 @@ struct sctp_chunk *sctp_make_init(const struct sctp_association *asoc,
 
 	/* If we have any extensions to report, account for that */
 	if (num_ext)
-		chunksize += SCTP_PAD4(sizeof(sctp_supported_ext_param_t) +
-				       num_ext);
+		chunksize += SCTP_PAD4(sizeof(ext_param) + num_ext);
 
 	/* RFC 2960 3.3.2 Initiation (INIT) (1)
 	 *
@@ -348,10 +347,8 @@ struct sctp_chunk *sctp_make_init(const struct sctp_association *asoc,
 	 */
 	if (num_ext) {
 		ext_param.param_hdr.type = SCTP_PARAM_SUPPORTED_EXT;
-		ext_param.param_hdr.length =
-			    htons(sizeof(sctp_supported_ext_param_t) + num_ext);
-		sctp_addto_chunk(retval, sizeof(sctp_supported_ext_param_t),
-				&ext_param);
+		ext_param.param_hdr.length = htons(sizeof(ext_param) + num_ext);
+		sctp_addto_chunk(retval, sizeof(ext_param), &ext_param);
 		sctp_addto_param(retval, num_ext, extensions);
 	}
 
@@ -394,7 +391,7 @@ struct sctp_chunk *sctp_make_init_ack(const struct sctp_association *asoc,
 	int cookie_len;
 	size_t chunksize;
 	struct sctp_adaptation_ind_param aiparam;
-	sctp_supported_ext_param_t ext_param;
+	struct sctp_supported_ext_param ext_param;
 	int num_ext = 0;
 	__u8 extensions[3];
 	struct sctp_paramhdr *auth_chunks = NULL,
@@ -468,8 +465,7 @@ struct sctp_chunk *sctp_make_init_ack(const struct sctp_association *asoc,
 	}
 
 	if (num_ext)
-		chunksize += SCTP_PAD4(sizeof(sctp_supported_ext_param_t) +
-				       num_ext);
+		chunksize += SCTP_PAD4(sizeof(ext_param) + num_ext);
 
 	/* Now allocate and fill out the chunk.  */
 	retval = sctp_make_control(asoc, SCTP_CID_INIT_ACK, 0, chunksize, gfp);
@@ -495,10 +491,8 @@ struct sctp_chunk *sctp_make_init_ack(const struct sctp_association *asoc,
 		sctp_addto_chunk(retval, sizeof(ecap_param), &ecap_param);
 	if (num_ext) {
 		ext_param.param_hdr.type = SCTP_PARAM_SUPPORTED_EXT;
-		ext_param.param_hdr.length =
-			    htons(sizeof(sctp_supported_ext_param_t) + num_ext);
-		sctp_addto_chunk(retval, sizeof(sctp_supported_ext_param_t),
-				 &ext_param);
+		ext_param.param_hdr.length = htons(sizeof(ext_param) + num_ext);
+		sctp_addto_chunk(retval, sizeof(ext_param), &ext_param);
 		sctp_addto_param(retval, num_ext, extensions);
 	}
 	if (asoc->peer.prsctp_capable)
-- 
2.1.0
