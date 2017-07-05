From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net-next 07/11] sctp: remove the typedef sctp_adaptation_ind_param_t
Date: Wed,  5 Jul 2017 08:32:25 +0800
Message-ID: <afa9a191289fea55e077dcb4ad0bc34f7daee1b9.1499214692.git.lucien.xin@gmail.com>
References: <cover.1499214692.git.lucien.xin@gmail.com>
 <6ba452f31d10acdc95f3cf679ecab15833f7843c.1499214692.git.lucien.xin@gmail.com>
 <77fa3a776118873a7e5d8203dd59011995b0e865.1499214692.git.lucien.xin@gmail.com>
 <090c24ed353f37a2bbce41ecc5feec6fc8cffa8b.1499214692.git.lucien.xin@gmail.com>
 <8d2e6145478bb4d24185d4ffd5547c7058f0dca9.1499214692.git.lucien.xin@gmail.com>
 <951d998920ecfe28f690739cd311bca3060751ff.1499214692.git.lucien.xin@gmail.com>
 <f094b5d16ed0f3b6fa255462bf957a104584f220.1499214692.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:35529 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752282AbdGEAdf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 4 Jul 2017 20:33:35 -0400
In-Reply-To: <f094b5d16ed0f3b6fa255462bf957a104584f220.1499214692.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1499214692.git.lucien.xin@gmail.com>
References: <cover.1499214692.git.lucien.xin@gmail.com>
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
