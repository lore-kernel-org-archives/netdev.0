From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net-next 02/11] sctp: remove the typedef sctp_cookie_param_t
Date: Sun, 23 Jul 2017 09:34:27 +0800
Message-ID: <78a33af4a9d7ef7116637943dbd0ae1403d20114.1500773578.git.lucien.xin@gmail.com>
References: <cover.1500773578.git.lucien.xin@gmail.com>
 <daa1cc9a380f5a1eb37b3d30fd64942d310fe81d.1500773578.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:37449 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755172AbdGWBfB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 22 Jul 2017 21:35:01 -0400
In-Reply-To: <daa1cc9a380f5a1eb37b3d30fd64942d310fe81d.1500773578.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1500773578.git.lucien.xin@gmail.com>
References: <cover.1500773578.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to remove the typedef sctp_cookie_param_t, and
replace with struct sctp_cookie_param in the places where it's
using this typedef.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/linux/sctp.h     |  4 ++--
 net/sctp/sm_make_chunk.c | 18 ++++++++++--------
 2 files changed, 12 insertions(+), 10 deletions(-)

diff --git a/include/linux/sctp.h b/include/linux/sctp.h
index 05c2099..9e77abd 100644
--- a/include/linux/sctp.h
+++ b/include/linux/sctp.h
@@ -342,10 +342,10 @@ struct sctp_initack_chunk {
 };
 
 /* Section 3.3.3.1 State Cookie (7) */
-typedef struct sctp_cookie_param {
+struct sctp_cookie_param {
 	struct sctp_paramhdr p;
 	__u8 body[0];
-} sctp_cookie_param_t;
+};
 
 /* Section 3.3.3.1 Unrecognized Parameters (8) */
 typedef struct sctp_unrecognized_param {
diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index 0b36e96..163004e 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -69,7 +69,8 @@ static struct sctp_chunk *sctp_make_data(const struct sctp_association *asoc,
 static struct sctp_chunk *_sctp_make_chunk(const struct sctp_association *asoc,
 					   __u8 type, __u8 flags, int paylen,
 					   gfp_t gfp);
-static sctp_cookie_param_t *sctp_pack_cookie(const struct sctp_endpoint *ep,
+static struct sctp_cookie_param *sctp_pack_cookie(
+					const struct sctp_endpoint *ep,
 					const struct sctp_association *asoc,
 					const struct sctp_chunk *init_chunk,
 					int *cookie_len,
@@ -387,7 +388,7 @@ struct sctp_chunk *sctp_make_init_ack(const struct sctp_association *asoc,
 	union sctp_params addrs;
 	struct sctp_sock *sp;
 	int addrs_len;
-	sctp_cookie_param_t *cookie;
+	struct sctp_cookie_param *cookie;
 	int cookie_len;
 	size_t chunksize;
 	struct sctp_adaptation_ind_param aiparam;
@@ -1595,14 +1596,15 @@ struct sctp_association *sctp_make_temp_asoc(const struct sctp_endpoint *ep,
 /* Build a cookie representing asoc.
  * This INCLUDES the param header needed to put the cookie in the INIT ACK.
  */
-static sctp_cookie_param_t *sctp_pack_cookie(const struct sctp_endpoint *ep,
-				      const struct sctp_association *asoc,
-				      const struct sctp_chunk *init_chunk,
-				      int *cookie_len,
-				      const __u8 *raw_addrs, int addrs_len)
+static struct sctp_cookie_param *sctp_pack_cookie(
+					const struct sctp_endpoint *ep,
+					const struct sctp_association *asoc,
+					const struct sctp_chunk *init_chunk,
+					int *cookie_len,
+					const __u8 *raw_addrs, int addrs_len)
 {
-	sctp_cookie_param_t *retval;
 	struct sctp_signed_cookie *cookie;
+	struct sctp_cookie_param *retval;
 	int headersize, bodysize;
 
 	/* Header size is static data prior to the actual cookie, including
-- 
2.1.0
