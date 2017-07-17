From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCHv2 net-next 03/11] sctp: remove the typedef sctp_cookie_preserve_param_t
Date: Mon, 17 Jul 2017 11:29:51 +0800
Message-ID: <c8cdb622f7de0edc639936e3fa15a262e92cfa66.1500261974.git.lucien.xin@gmail.com>
References: <cover.1500261974.git.lucien.xin@gmail.com>
 <cadd1baef89e215244af82032957ccde1189bcc8.1500261974.git.lucien.xin@gmail.com>
 <0add39ae0879e3b332bafc24aa6ccdb6b0d5c85a.1500261974.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:34532 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751248AbdGQDad (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 16 Jul 2017 23:30:33 -0400
In-Reply-To: <0add39ae0879e3b332bafc24aa6ccdb6b0d5c85a.1500261974.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1500261974.git.lucien.xin@gmail.com>
References: <cover.1500261974.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to remove the typedef sctp_cookie_preserve_param_t, and
replace with struct sctp_cookie_preserve_param in the places where it's
using this typedef.

It is also to fix some indents in sctp_sf_do_5_2_6_stale().

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/linux/sctp.h    |  6 +++---
 net/sctp/sm_statefuns.c | 11 +++++------
 2 files changed, 8 insertions(+), 9 deletions(-)

diff --git a/include/linux/sctp.h b/include/linux/sctp.h
index 6b45c8a..d8f9d8f 100644
--- a/include/linux/sctp.h
+++ b/include/linux/sctp.h
@@ -285,10 +285,10 @@ struct sctp_ipv6addr_param {
 };
 
 /* Section 3.3.2.1 Cookie Preservative (9) */
-typedef struct sctp_cookie_preserve_param {
+struct sctp_cookie_preserve_param {
 	struct sctp_paramhdr param_hdr;
-	__be32          lifespan_increment;
-} sctp_cookie_preserve_param_t;
+	__be32 lifespan_increment;
+};
 
 /* Section 3.3.2.1 Host Name Address (11) */
 typedef struct sctp_hostname_param {
diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index b2a74c3..ae4c48c 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -2336,13 +2336,12 @@ static sctp_disposition_t sctp_sf_do_5_2_6_stale(struct net *net,
 						 void *arg,
 						 sctp_cmd_seq_t *commands)
 {
-	struct sctp_chunk *chunk = arg;
-	u32 stale;
-	sctp_cookie_preserve_param_t bht;
-	sctp_errhdr_t *err;
-	struct sctp_chunk *reply;
-	struct sctp_bind_addr *bp;
 	int attempts = asoc->init_err_counter + 1;
+	struct sctp_chunk *chunk = arg, *reply;
+	struct sctp_cookie_preserve_param bht;
+	struct sctp_bind_addr *bp;
+	sctp_errhdr_t *err;
+	u32 stale;
 
 	if (attempts > asoc->max_init_attempts) {
 		sctp_add_cmd_sf(commands, SCTP_CMD_SET_SK_ERR,
-- 
2.1.0
