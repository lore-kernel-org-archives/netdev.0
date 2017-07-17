From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCHv2 net-next 07/11] sctp: remove the typedef sctp_adaptation_ind_param_t
Date: Mon, 17 Jul 2017 11:29:55 +0800
Message-ID: <3dda87d79e20cdb2487fc3baa3ffad883bb3a7fb.1500261974.git.lucien.xin@gmail.com>
References: <cover.1500261974.git.lucien.xin@gmail.com>
 <cadd1baef89e215244af82032957ccde1189bcc8.1500261974.git.lucien.xin@gmail.com>
 <0add39ae0879e3b332bafc24aa6ccdb6b0d5c85a.1500261974.git.lucien.xin@gmail.com>
 <c8cdb622f7de0edc639936e3fa15a262e92cfa66.1500261974.git.lucien.xin@gmail.com>
 <7faff4d9e2bef97652b742006c0165641ad84504.1500261974.git.lucien.xin@gmail.com>
 <6c3cea13894a96c24fb2e84fc0fab8363cb4b70f.1500261974.git.lucien.xin@gmail.com>
 <ec19ee88ce40e1e11b7bef6c84c1372dfebd5704.1500261974.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:34165 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751248AbdGQDbF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 16 Jul 2017 23:31:05 -0400
In-Reply-To: <ec19ee88ce40e1e11b7bef6c84c1372dfebd5704.1500261974.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1500261974.git.lucien.xin@gmail.com>
References: <cover.1500261974.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to remove the typedef sctp_adaptation_ind_param_t, and
replace with struct sctp_adaptation_ind_param in the places where it's
using this typedef.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/linux/sctp.h     | 4 ++--
 net/sctp/sm_make_chunk.c | 4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/include/linux/sctp.h b/include/linux/sctp.h
index 7552482..72b8787 100644
--- a/include/linux/sctp.h
+++ b/include/linux/sctp.h
@@ -303,10 +303,10 @@ struct sctp_supported_addrs_param {
 };
 
 /* ADDIP Section 3.2.6 Adaptation Layer Indication */
-typedef struct sctp_adaptation_ind_param {
+struct sctp_adaptation_ind_param {
 	struct sctp_paramhdr param_hdr;
 	__be32 adaptation_ind;
-} sctp_adaptation_ind_param_t;
+};
 
 /* ADDIP Section 4.2.7 Supported Extensions Parameter */
 typedef struct sctp_supported_ext_param {
diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index fb06d4f..d5f82c2 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -225,7 +225,7 @@ struct sctp_chunk *sctp_make_init(const struct sctp_association *asoc,
 	struct sctp_sock *sp;
 	struct sctp_supported_addrs_param sat;
 	__be16 types[2];
-	sctp_adaptation_ind_param_t aiparam;
+	struct sctp_adaptation_ind_param aiparam;
 	sctp_supported_ext_param_t ext_param;
 	int num_ext = 0;
 	__u8 extensions[3];
@@ -393,7 +393,7 @@ struct sctp_chunk *sctp_make_init_ack(const struct sctp_association *asoc,
 	sctp_cookie_param_t *cookie;
 	int cookie_len;
 	size_t chunksize;
-	sctp_adaptation_ind_param_t aiparam;
+	struct sctp_adaptation_ind_param aiparam;
 	sctp_supported_ext_param_t ext_param;
 	int num_ext = 0;
 	__u8 extensions[3];
-- 
2.1.0
