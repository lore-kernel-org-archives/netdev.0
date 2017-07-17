From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCHv2 net-next 08/11] sctp: remove the typedef sctp_supported_ext_param_t
Date: Mon, 17 Jul 2017 11:29:56 +0800
Message-ID: <2d6a7b26e6b2766ed9fd0d86d8ac390e12762b02.1500261974.git.lucien.xin@gmail.com>
References: <cover.1500261974.git.lucien.xin@gmail.com>
 <cadd1baef89e215244af82032957ccde1189bcc8.1500261974.git.lucien.xin@gmail.com>
 <0add39ae0879e3b332bafc24aa6ccdb6b0d5c85a.1500261974.git.lucien.xin@gmail.com>
 <c8cdb622f7de0edc639936e3fa15a262e92cfa66.1500261974.git.lucien.xin@gmail.com>
 <7faff4d9e2bef97652b742006c0165641ad84504.1500261974.git.lucien.xin@gmail.com>
 <6c3cea13894a96c24fb2e84fc0fab8363cb4b70f.1500261974.git.lucien.xin@gmail.com>
 <ec19ee88ce40e1e11b7bef6c84c1372dfebd5704.1500261974.git.lucien.xin@gmail.com>
 <3dda87d79e20cdb2487fc3baa3ffad883bb3a7fb.1500261974.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:36024 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751248AbdGQDbM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 16 Jul 2017 23:31:12 -0400
In-Reply-To: <3dda87d79e20cdb2487fc3baa3ffad883bb3a7fb.1500261974.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1500261974.git.lucien.xin@gmail.com>
References: <cover.1500261974.git.lucien.xin@gmail.com>
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
