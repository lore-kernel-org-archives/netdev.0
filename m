From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net-next 08/14] sctp: remove the typedef sctp_ierror_t
Date: Sat,  5 Aug 2017 19:59:58 +0800
Message-ID: <1bd9e98627fc627a28f90ad587e941845b91b108.1501934087.git.lucien.xin@gmail.com>
References: <cover.1501934086.git.lucien.xin@gmail.com>
 <88e505f76dd927887d8cdcc7de2b82595237aa85.1501934087.git.lucien.xin@gmail.com>
 <7ceee2b1bf33403b8ecb04c9c30354f71dd2198a.1501934087.git.lucien.xin@gmail.com>
 <09ffe75e4e16f00b61b682261e2a4b05fa76e814.1501934087.git.lucien.xin@gmail.com>
 <f8669af1f44d19322287665b8f7d97e0e2a4dc46.1501934087.git.lucien.xin@gmail.com>
 <9049d5fd9299328397722053f090a66d97de8451.1501934087.git.lucien.xin@gmail.com>
 <e92ab93f0d646a935384c74848671fc56956c754.1501934087.git.lucien.xin@gmail.com>
 <a26ddefe25442293b3e1020ce56f859125a93412.1501934087.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:34722 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751950AbdHEMBQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 5 Aug 2017 08:01:16 -0400
In-Reply-To: <a26ddefe25442293b3e1020ce56f859125a93412.1501934087.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1501934086.git.lucien.xin@gmail.com>
References: <cover.1501934086.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to remove the typedef sctp_ierror_t, and
replace with enum sctp_ierror in the places where it's
using this typedef.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/net/sctp/constants.h |  5 ++---
 net/sctp/sm_make_chunk.c     | 23 ++++++++++++-----------
 net/sctp/sm_statefuns.c      | 28 +++++++++++++++-------------
 3 files changed, 29 insertions(+), 27 deletions(-)

diff --git a/include/net/sctp/constants.h b/include/net/sctp/constants.h
index 311b2e3..9a69465 100644
--- a/include/net/sctp/constants.h
+++ b/include/net/sctp/constants.h
@@ -155,8 +155,7 @@ SCTP_SUBTYPE_CONSTRUCTOR(PRIMITIVE,	sctp_event_primitive_t,	primitive)
 				- sizeof(struct sctp_data_chunk)))
 
 /* Internal error codes */
-typedef enum {
-
+enum sctp_ierror {
 	SCTP_IERROR_NO_ERROR	        = 0,
 	SCTP_IERROR_BASE		= 1000,
 	SCTP_IERROR_NO_COOKIE,
@@ -177,7 +176,7 @@ typedef enum {
 	SCTP_IERROR_PROTO_VIOLATION,
 	SCTP_IERROR_ERROR,
 	SCTP_IERROR_ABORT,
-} sctp_ierror_t;
+};
 
 
 
diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index a034d84..3a8fb1d 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -2065,10 +2065,11 @@ static void sctp_process_ext_param(struct sctp_association *asoc,
  * 	SCTP_IERROR_ERROR    - stop and report an error.
  * 	SCTP_IERROR_NOMEME   - out of memory.
  */
-static sctp_ierror_t sctp_process_unk_param(const struct sctp_association *asoc,
-					    union sctp_params param,
-					    struct sctp_chunk *chunk,
-					    struct sctp_chunk **errp)
+static enum sctp_ierror sctp_process_unk_param(
+					const struct sctp_association *asoc,
+					union sctp_params param,
+					struct sctp_chunk *chunk,
+					struct sctp_chunk **errp)
 {
 	int retval = SCTP_IERROR_NO_ERROR;
 
@@ -2117,13 +2118,13 @@ static sctp_ierror_t sctp_process_unk_param(const struct sctp_association *asoc,
  *	SCTP_IERROR_ERROR - stop processing, trigger an ERROR
  * 	SCTP_IERROR_NO_ERROR - continue with the chunk
  */
-static sctp_ierror_t sctp_verify_param(struct net *net,
-					const struct sctp_endpoint *ep,
-					const struct sctp_association *asoc,
-					union sctp_params param,
-					enum sctp_cid cid,
-					struct sctp_chunk *chunk,
-					struct sctp_chunk **err_chunk)
+static enum sctp_ierror sctp_verify_param(struct net *net,
+					  const struct sctp_endpoint *ep,
+					  const struct sctp_association *asoc,
+					  union sctp_params param,
+					  enum sctp_cid cid,
+					  struct sctp_chunk *chunk,
+					  struct sctp_chunk **err_chunk)
 {
 	struct sctp_hmac_algo_param *hmacs;
 	int retval = SCTP_IERROR_NO_ERROR;
diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index 8af90a5..5381697 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -144,11 +144,12 @@ static sctp_disposition_t sctp_sf_violation_chunk(
 				     void *arg,
 				     sctp_cmd_seq_t *commands);
 
-static sctp_ierror_t sctp_sf_authenticate(struct net *net,
-				    const struct sctp_endpoint *ep,
-				    const struct sctp_association *asoc,
-				    const sctp_subtype_t type,
-				    struct sctp_chunk *chunk);
+static enum sctp_ierror sctp_sf_authenticate(
+				struct net *net,
+				const struct sctp_endpoint *ep,
+				const struct sctp_association *asoc,
+				const sctp_subtype_t type,
+				struct sctp_chunk *chunk);
 
 static sctp_disposition_t __sctp_sf_do_9_1_abort(struct net *net,
 					const struct sctp_endpoint *ep,
@@ -756,7 +757,7 @@ sctp_disposition_t sctp_sf_do_5_1D_ce(struct net *net,
 	 */
 	if (chunk->auth_chunk) {
 		struct sctp_chunk auth;
-		sctp_ierror_t ret;
+		enum sctp_ierror ret;
 
 		/* Make sure that we and the peer are AUTH capable */
 		if (!net->sctp.auth_enable || !new_asoc->peer.auth_capable) {
@@ -4077,11 +4078,12 @@ sctp_disposition_t sctp_sf_eat_fwd_tsn_fast(
  *
  * The return value is the disposition of the chunk.
  */
-static sctp_ierror_t sctp_sf_authenticate(struct net *net,
-				    const struct sctp_endpoint *ep,
-				    const struct sctp_association *asoc,
-				    const sctp_subtype_t type,
-				    struct sctp_chunk *chunk)
+static enum sctp_ierror sctp_sf_authenticate(
+				struct net *net,
+				const struct sctp_endpoint *ep,
+				const struct sctp_association *asoc,
+				const sctp_subtype_t type,
+				struct sctp_chunk *chunk)
 {
 	struct sctp_authhdr *auth_hdr;
 	struct sctp_hmac *hmac;
@@ -4159,10 +4161,10 @@ sctp_disposition_t sctp_sf_eat_auth(struct net *net,
 				    void *arg,
 				    sctp_cmd_seq_t *commands)
 {
-	struct sctp_authhdr *auth_hdr;
 	struct sctp_chunk *chunk = arg;
+	struct sctp_authhdr *auth_hdr;
 	struct sctp_chunk *err_chunk;
-	sctp_ierror_t error;
+	enum sctp_ierror error;
 
 	/* Make sure that the peer has AUTH capable */
 	if (!asoc->peer.auth_capable)
-- 
2.1.0
