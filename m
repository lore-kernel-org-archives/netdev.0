From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net-next 05/11] sctp: remove the typedef sctp_paramhdr_t
Date: Fri, 30 Jun 2017 11:52:16 +0800
Message-ID: <2ae031641ce87e8fa77af7d3ea31b163f6c25f3d.1498794482.git.lucien.xin@gmail.com>
References: <cover.1498794481.git.lucien.xin@gmail.com>
 <d99d14fbe257b7d7b290296646772c6df35a36c8.1498794482.git.lucien.xin@gmail.com>
 <9b26ac600c9c3f9426b370ecd69261c25d220b2b.1498794482.git.lucien.xin@gmail.com>
 <d522a5f819078da037df984f9fa1897b0cf57433.1498794482.git.lucien.xin@gmail.com>
 <bd4d24bbff8ff402d30c8a148f6ea4332beb5005.1498794482.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:32901 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751722AbdF3Dx3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Jun 2017 23:53:29 -0400
In-Reply-To: <bd4d24bbff8ff402d30c8a148f6ea4332beb5005.1498794482.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1498794481.git.lucien.xin@gmail.com>
References: <cover.1498794481.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to remove the typedef sctp_paramhdr_t, and replace
with struct sctp_paramhdr in the places where it's using this
typedef.

It is also to fix some indents and  use sizeof(variable) instead
of sizeof(type).

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/linux/sctp.h       | 44 +++++++++++++++++++++----------------------
 include/net/sctp/sctp.h    |  2 +-
 include/net/sctp/structs.h |  5 +++--
 net/sctp/associola.c       |  6 +++---
 net/sctp/auth.c            | 22 +++++++++++++---------
 net/sctp/endpointola.c     |  7 ++++---
 net/sctp/sm_make_chunk.c   | 47 +++++++++++++++++++++++-----------------------
 net/sctp/sm_statefuns.c    |  6 +++---
 net/sctp/socket.c          |  7 ++++---
 net/sctp/stream.c          |  4 ++--
 10 files changed, 79 insertions(+), 71 deletions(-)

diff --git a/include/linux/sctp.h b/include/linux/sctp.h
index ffdccb4..142bb6a 100644
--- a/include/linux/sctp.h
+++ b/include/linux/sctp.h
@@ -162,10 +162,10 @@ enum { SCTP_CHUNK_FLAG_T = 0x01 };
  * Section 3.2.1 Optional/Variable-length Parmaeter Format.
  */
 
-typedef struct sctp_paramhdr {
+struct sctp_paramhdr {
 	__be16 type;
 	__be16 length;
-} sctp_paramhdr_t;
+};
 
 typedef enum {
 
@@ -274,37 +274,37 @@ typedef struct sctp_init_chunk {
 
 /* Section 3.3.2.1. IPv4 Address Parameter (5) */
 typedef struct sctp_ipv4addr_param {
-	sctp_paramhdr_t param_hdr;
+	struct sctp_paramhdr param_hdr;
 	struct in_addr  addr;
 } sctp_ipv4addr_param_t;
 
 /* Section 3.3.2.1. IPv6 Address Parameter (6) */
 typedef struct sctp_ipv6addr_param {
-	sctp_paramhdr_t param_hdr;
+	struct sctp_paramhdr param_hdr;
 	struct in6_addr addr;
 } sctp_ipv6addr_param_t;
 
 /* Section 3.3.2.1 Cookie Preservative (9) */
 typedef struct sctp_cookie_preserve_param {
-	sctp_paramhdr_t param_hdr;
+	struct sctp_paramhdr param_hdr;
 	__be32          lifespan_increment;
 } sctp_cookie_preserve_param_t;
 
 /* Section 3.3.2.1 Host Name Address (11) */
 typedef struct sctp_hostname_param {
-	sctp_paramhdr_t param_hdr;
+	struct sctp_paramhdr param_hdr;
 	uint8_t hostname[0];
 } sctp_hostname_param_t;
 
 /* Section 3.3.2.1 Supported Address Types (12) */
 typedef struct sctp_supported_addrs_param {
-	sctp_paramhdr_t param_hdr;
+	struct sctp_paramhdr param_hdr;
 	__be16 types[0];
 } sctp_supported_addrs_param_t;
 
 /* Appendix A. ECN Capable (32768) */
 typedef struct sctp_ecn_capable_param {
-	sctp_paramhdr_t param_hdr;
+	struct sctp_paramhdr param_hdr;
 } sctp_ecn_capable_param_t;
 
 /* ADDIP Section 3.2.6 Adaptation Layer Indication */
@@ -321,19 +321,19 @@ typedef struct sctp_supported_ext_param {
 
 /* AUTH Section 3.1 Random */
 typedef struct sctp_random_param {
-	sctp_paramhdr_t param_hdr;
+	struct sctp_paramhdr param_hdr;
 	__u8 random_val[0];
 } sctp_random_param_t;
 
 /* AUTH Section 3.2 Chunk List */
 typedef struct sctp_chunks_param {
-	sctp_paramhdr_t param_hdr;
+	struct sctp_paramhdr param_hdr;
 	__u8 chunks[0];
 } sctp_chunks_param_t;
 
 /* AUTH Section 3.3 HMAC Algorithm */
 typedef struct sctp_hmac_algo_param {
-	sctp_paramhdr_t param_hdr;
+	struct sctp_paramhdr param_hdr;
 	__be16 hmac_ids[0];
 } sctp_hmac_algo_param_t;
 
@@ -345,14 +345,14 @@ typedef sctp_init_chunk_t sctp_initack_chunk_t;
 
 /* Section 3.3.3.1 State Cookie (7) */
 typedef struct sctp_cookie_param {
-	sctp_paramhdr_t p;
+	struct sctp_paramhdr p;
 	__u8 body[0];
 } sctp_cookie_param_t;
 
 /* Section 3.3.3.1 Unrecognized Parameters (8) */
 typedef struct sctp_unrecognized_param {
-	sctp_paramhdr_t param_hdr;
-	sctp_paramhdr_t unrecognized;
+	struct sctp_paramhdr param_hdr;
+	struct sctp_paramhdr unrecognized;
 } sctp_unrecognized_param_t;
 
 
@@ -399,7 +399,7 @@ typedef struct sctp_sack_chunk {
  */
 
 typedef struct sctp_heartbeathdr {
-	sctp_paramhdr_t info;
+	struct sctp_paramhdr info;
 } sctp_heartbeathdr_t;
 
 typedef struct sctp_heartbeat_chunk {
@@ -639,7 +639,7 @@ struct sctp_fwdtsn_chunk {
  *	report status of ASCONF processing.
  */
 typedef struct sctp_addip_param {
-	sctp_paramhdr_t	param_hdr;
+	struct sctp_paramhdr	param_hdr;
 	__be32		crr_id;
 } sctp_addip_param_t;
 
@@ -724,7 +724,7 @@ struct sctp_reconf_chunk {
 };
 
 struct sctp_strreset_outreq {
-	sctp_paramhdr_t param_hdr;
+	struct sctp_paramhdr param_hdr;
 	__u32 request_seq;
 	__u32 response_seq;
 	__u32 send_reset_at_tsn;
@@ -732,18 +732,18 @@ struct sctp_strreset_outreq {
 };
 
 struct sctp_strreset_inreq {
-	sctp_paramhdr_t param_hdr;
+	struct sctp_paramhdr param_hdr;
 	__u32 request_seq;
 	__u16 list_of_streams[0];
 };
 
 struct sctp_strreset_tsnreq {
-	sctp_paramhdr_t param_hdr;
+	struct sctp_paramhdr param_hdr;
 	__u32 request_seq;
 };
 
 struct sctp_strreset_addstrm {
-	sctp_paramhdr_t param_hdr;
+	struct sctp_paramhdr param_hdr;
 	__u32 request_seq;
 	__u16 number_of_streams;
 	__u16 reserved;
@@ -760,13 +760,13 @@ enum {
 };
 
 struct sctp_strreset_resp {
-	sctp_paramhdr_t param_hdr;
+	struct sctp_paramhdr param_hdr;
 	__u32 response_seq;
 	__u32 result;
 };
 
 struct sctp_strreset_resptsn {
-	sctp_paramhdr_t param_hdr;
+	struct sctp_paramhdr param_hdr;
 	__u32 response_seq;
 	__u32 result;
 	__u32 senders_next_tsn;
diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
index d756bd0..a9519a0 100644
--- a/include/net/sctp/sctp.h
+++ b/include/net/sctp/sctp.h
@@ -470,7 +470,7 @@ _sctp_walk_params((pos), (chunk), ntohs((chunk)->chunk_hdr.length), member)
 #define _sctp_walk_params(pos, chunk, end, member)\
 for (pos.v = chunk->member;\
      pos.v <= (void *)chunk + end - ntohs(pos.p->length) &&\
-     ntohs(pos.p->length) >= sizeof(sctp_paramhdr_t);\
+     ntohs(pos.p->length) >= sizeof(struct sctp_paramhdr);\
      pos.v += SCTP_PAD4(ntohs(pos.p->length)))
 
 #define sctp_walk_errors(err, chunk_hdr)\
diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index 9e9605e..2393d2e 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -310,9 +310,10 @@ struct sctp_cookie {
 
 	__u32 adaptation_ind;
 
-	__u8 auth_random[sizeof(sctp_paramhdr_t) + SCTP_AUTH_RANDOM_LENGTH];
+	__u8 auth_random[sizeof(struct sctp_paramhdr) +
+			 SCTP_AUTH_RANDOM_LENGTH];
 	__u8 auth_hmacs[SCTP_AUTH_NUM_HMACS * sizeof(__u16) + 2];
-	__u8 auth_chunks[sizeof(sctp_paramhdr_t) + SCTP_AUTH_MAX_CHUNKS];
+	__u8 auth_chunks[sizeof(struct sctp_paramhdr) + SCTP_AUTH_MAX_CHUNKS];
 
 	/* This is a shim for my peer's INIT packet, followed by
 	 * a copy of the raw address list of the association.
diff --git a/net/sctp/associola.c b/net/sctp/associola.c
index 757be41..fa4f530 100644
--- a/net/sctp/associola.c
+++ b/net/sctp/associola.c
@@ -71,7 +71,7 @@ static struct sctp_association *sctp_association_init(struct sctp_association *a
 {
 	struct net *net = sock_net(sk);
 	struct sctp_sock *sp;
-	sctp_paramhdr_t *p;
+	struct sctp_paramhdr *p;
 	int i;
 
 	/* Retrieve the SCTP per socket area.  */
@@ -284,9 +284,9 @@ static struct sctp_association *sctp_association_init(struct sctp_association *a
 			ntohs(ep->auth_chunk_list->param_hdr.length));
 
 	/* Get the AUTH random number for this association */
-	p = (sctp_paramhdr_t *)asoc->c.auth_random;
+	p = (struct sctp_paramhdr *)asoc->c.auth_random;
 	p->type = SCTP_PARAM_RANDOM;
-	p->length = htons(sizeof(sctp_paramhdr_t) + SCTP_AUTH_RANDOM_LENGTH);
+	p->length = htons(sizeof(*p) + SCTP_AUTH_RANDOM_LENGTH);
 	get_random_bytes(p+1, SCTP_AUTH_RANDOM_LENGTH);
 
 	return asoc;
diff --git a/net/sctp/auth.c b/net/sctp/auth.c
index 7171dd3..8ffa598 100644
--- a/net/sctp/auth.c
+++ b/net/sctp/auth.c
@@ -538,7 +538,8 @@ struct sctp_hmac *sctp_auth_asoc_get_hmac(const struct sctp_association *asoc)
 	if (!hmacs)
 		return NULL;
 
-	n_elt = (ntohs(hmacs->param_hdr.length) - sizeof(sctp_paramhdr_t)) >> 1;
+	n_elt = (ntohs(hmacs->param_hdr.length) -
+		 sizeof(struct sctp_paramhdr)) >> 1;
 	for (i = 0; i < n_elt; i++) {
 		id = ntohs(hmacs->hmac_ids[i]);
 
@@ -589,7 +590,8 @@ int sctp_auth_asoc_verify_hmac_id(const struct sctp_association *asoc,
 		return 0;
 
 	hmacs = (struct sctp_hmac_algo_param *)asoc->c.auth_hmacs;
-	n_elt = (ntohs(hmacs->param_hdr.length) - sizeof(sctp_paramhdr_t)) >> 1;
+	n_elt = (ntohs(hmacs->param_hdr.length) -
+		 sizeof(struct sctp_paramhdr)) >> 1;
 
 	return __sctp_auth_find_hmacid(hmacs->hmac_ids, n_elt, hmac_id);
 }
@@ -612,8 +614,8 @@ void sctp_auth_asoc_set_default_hmac(struct sctp_association *asoc,
 	if (asoc->default_hmac_id)
 		return;
 
-	n_params = (ntohs(hmacs->param_hdr.length)
-				- sizeof(sctp_paramhdr_t)) >> 1;
+	n_params = (ntohs(hmacs->param_hdr.length) -
+		    sizeof(struct sctp_paramhdr)) >> 1;
 	ep = asoc->ep;
 	for (i = 0; i < n_params; i++) {
 		id = ntohs(hmacs->hmac_ids[i]);
@@ -641,7 +643,7 @@ static int __sctp_auth_cid(enum sctp_cid chunk, struct sctp_chunks_param *param)
 	if (!param || param->param_hdr.length == 0)
 		return 0;
 
-	len = ntohs(param->param_hdr.length) - sizeof(sctp_paramhdr_t);
+	len = ntohs(param->param_hdr.length) - sizeof(struct sctp_paramhdr);
 
 	/* SCTP-AUTH, Section 3.2
 	 *    The chunk types for INIT, INIT-ACK, SHUTDOWN-COMPLETE and AUTH
@@ -775,7 +777,7 @@ int sctp_auth_ep_add_chunkid(struct sctp_endpoint *ep, __u8 chunk_id)
 
 	/* Check if we can add this chunk to the array */
 	param_len = ntohs(p->param_hdr.length);
-	nchunks = param_len - sizeof(sctp_paramhdr_t);
+	nchunks = param_len - sizeof(struct sctp_paramhdr);
 	if (nchunks == SCTP_NUM_CHUNK_TYPES)
 		return -EINVAL;
 
@@ -812,9 +814,11 @@ int sctp_auth_ep_set_hmacs(struct sctp_endpoint *ep,
 		return -EINVAL;
 
 	for (i = 0; i < hmacs->shmac_num_idents; i++)
-		ep->auth_hmacs_list->hmac_ids[i] = htons(hmacs->shmac_idents[i]);
-	ep->auth_hmacs_list->param_hdr.length = htons(sizeof(sctp_paramhdr_t) +
-				hmacs->shmac_num_idents * sizeof(__u16));
+		ep->auth_hmacs_list->hmac_ids[i] =
+				htons(hmacs->shmac_idents[i]);
+	ep->auth_hmacs_list->param_hdr.length =
+			htons(sizeof(struct sctp_paramhdr) +
+			hmacs->shmac_num_idents * sizeof(__u16));
 	return 0;
 }
 
diff --git a/net/sctp/endpointola.c b/net/sctp/endpointola.c
index 3dcd0ec..2ae9ce1 100644
--- a/net/sctp/endpointola.c
+++ b/net/sctp/endpointola.c
@@ -90,12 +90,13 @@ static struct sctp_endpoint *sctp_endpoint_init(struct sctp_endpoint *ep,
 		 */
 		auth_hmacs->param_hdr.type = SCTP_PARAM_HMAC_ALGO;
 		auth_hmacs->param_hdr.length =
-					htons(sizeof(sctp_paramhdr_t) + 2);
+					htons(sizeof(struct sctp_paramhdr) + 2);
 		auth_hmacs->hmac_ids[0] = htons(SCTP_AUTH_HMAC_ID_SHA1);
 
 		/* Initialize the CHUNKS parameter */
 		auth_chunks->param_hdr.type = SCTP_PARAM_CHUNKS;
-		auth_chunks->param_hdr.length = htons(sizeof(sctp_paramhdr_t));
+		auth_chunks->param_hdr.length =
+					htons(sizeof(struct sctp_paramhdr));
 
 		/* If the Add-IP functionality is enabled, we must
 		 * authenticate, ASCONF and ASCONF-ACK chunks
@@ -104,7 +105,7 @@ static struct sctp_endpoint *sctp_endpoint_init(struct sctp_endpoint *ep,
 			auth_chunks->chunks[0] = SCTP_CID_ASCONF;
 			auth_chunks->chunks[1] = SCTP_CID_ASCONF_ACK;
 			auth_chunks->param_hdr.length =
-					htons(sizeof(sctp_paramhdr_t) + 2);
+					htons(sizeof(struct sctp_paramhdr) + 2);
 		}
 	}
 
diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index 78c3f21..9f9d40c 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -229,7 +229,7 @@ struct sctp_chunk *sctp_make_init(const struct sctp_association *asoc,
 	sctp_supported_ext_param_t ext_param;
 	int num_ext = 0;
 	__u8 extensions[3];
-	sctp_paramhdr_t *auth_chunks = NULL,
+	struct sctp_paramhdr *auth_chunks = NULL,
 			*auth_hmacs = NULL;
 
 	/* RFC 2960 3.3.2 Initiation (INIT) (1)
@@ -286,14 +286,14 @@ struct sctp_chunk *sctp_make_init(const struct sctp_association *asoc,
 		chunksize += sizeof(asoc->c.auth_random);
 
 		/* Add HMACS parameter length if any were defined */
-		auth_hmacs = (sctp_paramhdr_t *)asoc->c.auth_hmacs;
+		auth_hmacs = (struct sctp_paramhdr *)asoc->c.auth_hmacs;
 		if (auth_hmacs->length)
 			chunksize += SCTP_PAD4(ntohs(auth_hmacs->length));
 		else
 			auth_hmacs = NULL;
 
 		/* Add CHUNKS parameter length */
-		auth_chunks = (sctp_paramhdr_t *)asoc->c.auth_chunks;
+		auth_chunks = (struct sctp_paramhdr *)asoc->c.auth_chunks;
 		if (auth_chunks->length)
 			chunksize += SCTP_PAD4(ntohs(auth_chunks->length));
 		else
@@ -397,7 +397,7 @@ struct sctp_chunk *sctp_make_init_ack(const struct sctp_association *asoc,
 	sctp_supported_ext_param_t ext_param;
 	int num_ext = 0;
 	__u8 extensions[3];
-	sctp_paramhdr_t *auth_chunks = NULL,
+	struct sctp_paramhdr *auth_chunks = NULL,
 			*auth_hmacs = NULL,
 			*auth_random = NULL;
 
@@ -448,16 +448,16 @@ struct sctp_chunk *sctp_make_init_ack(const struct sctp_association *asoc,
 		chunksize += sizeof(aiparam);
 
 	if (asoc->peer.auth_capable) {
-		auth_random = (sctp_paramhdr_t *)asoc->c.auth_random;
+		auth_random = (struct sctp_paramhdr *)asoc->c.auth_random;
 		chunksize += ntohs(auth_random->length);
 
-		auth_hmacs = (sctp_paramhdr_t *)asoc->c.auth_hmacs;
+		auth_hmacs = (struct sctp_paramhdr *)asoc->c.auth_hmacs;
 		if (auth_hmacs->length)
 			chunksize += SCTP_PAD4(ntohs(auth_hmacs->length));
 		else
 			auth_hmacs = NULL;
 
-		auth_chunks = (sctp_paramhdr_t *)asoc->c.auth_chunks;
+		auth_chunks = (struct sctp_paramhdr *)asoc->c.auth_chunks;
 		if (auth_chunks->length)
 			chunksize += SCTP_PAD4(ntohs(auth_chunks->length));
 		else
@@ -1085,18 +1085,18 @@ struct sctp_chunk *sctp_make_abort_violation(
 	struct sctp_chunk  *retval;
 	struct sctp_paramhdr phdr;
 
-	retval = sctp_make_abort(asoc, chunk, sizeof(sctp_errhdr_t) + paylen
-					+ sizeof(sctp_paramhdr_t));
+	retval = sctp_make_abort(asoc, chunk, sizeof(sctp_errhdr_t) + paylen +
+					      sizeof(phdr));
 	if (!retval)
 		goto end;
 
-	sctp_init_cause(retval, SCTP_ERROR_PROTO_VIOLATION, paylen
-					+ sizeof(sctp_paramhdr_t));
+	sctp_init_cause(retval, SCTP_ERROR_PROTO_VIOLATION, paylen +
+							    sizeof(phdr));
 
 	phdr.type = htons(chunk->chunk_hdr->type);
 	phdr.length = chunk->chunk_hdr->length;
 	sctp_addto_chunk(retval, paylen, payload);
-	sctp_addto_param(retval, sizeof(sctp_paramhdr_t), &phdr);
+	sctp_addto_param(retval, sizeof(phdr), &phdr);
 
 end:
 	return retval;
@@ -1110,16 +1110,16 @@ struct sctp_chunk *sctp_make_violation_paramlen(
 	struct sctp_chunk *retval;
 	static const char error[] = "The following parameter had invalid length:";
 	size_t payload_len = sizeof(error) + sizeof(sctp_errhdr_t) +
-				sizeof(sctp_paramhdr_t);
+			     sizeof(*param);
 
 	retval = sctp_make_abort(asoc, chunk, payload_len);
 	if (!retval)
 		goto nodata;
 
 	sctp_init_cause(retval, SCTP_ERROR_PROTO_VIOLATION,
-			sizeof(error) + sizeof(sctp_paramhdr_t));
+			sizeof(error) + sizeof(*param));
 	sctp_addto_chunk(retval, sizeof(error), error);
-	sctp_addto_param(retval, sizeof(sctp_paramhdr_t), param);
+	sctp_addto_param(retval, sizeof(*param), param);
 
 nodata:
 	return retval;
@@ -1614,7 +1614,7 @@ static sctp_cookie_param_t *sctp_pack_cookie(const struct sctp_endpoint *ep,
 	/* Header size is static data prior to the actual cookie, including
 	 * any padding.
 	 */
-	headersize = sizeof(sctp_paramhdr_t) +
+	headersize = sizeof(struct sctp_paramhdr) +
 		     (sizeof(struct sctp_signed_cookie) -
 		      sizeof(struct sctp_cookie));
 	bodysize = sizeof(struct sctp_cookie)
@@ -1975,7 +1975,7 @@ static int sctp_process_hn_param(const struct sctp_association *asoc,
 
 static int sctp_verify_ext_param(struct net *net, union sctp_params param)
 {
-	__u16 num_ext = ntohs(param.p->length) - sizeof(sctp_paramhdr_t);
+	__u16 num_ext = ntohs(param.p->length) - sizeof(struct sctp_paramhdr);
 	int have_auth = 0;
 	int have_asconf = 0;
 	int i;
@@ -2010,7 +2010,7 @@ static void sctp_process_ext_param(struct sctp_association *asoc,
 				    union sctp_params param)
 {
 	struct net *net = sock_net(asoc->base.sk);
-	__u16 num_ext = ntohs(param.p->length) - sizeof(sctp_paramhdr_t);
+	__u16 num_ext = ntohs(param.p->length) - sizeof(struct sctp_paramhdr);
 	int i;
 
 	for (i = 0; i < num_ext; i++) {
@@ -2180,7 +2180,7 @@ static sctp_ierror_t sctp_verify_param(struct net *net,
 		 * cause 'Protocol Violation'.
 		 */
 		if (SCTP_AUTH_RANDOM_LENGTH !=
-			ntohs(param.p->length) - sizeof(sctp_paramhdr_t)) {
+			ntohs(param.p->length) - sizeof(struct sctp_paramhdr)) {
 			sctp_process_inv_paramlength(asoc, param.p,
 							chunk, err_chunk);
 			retval = SCTP_IERROR_ABORT;
@@ -2208,7 +2208,8 @@ static sctp_ierror_t sctp_verify_param(struct net *net,
 			goto fallthrough;
 
 		hmacs = (struct sctp_hmac_algo_param *)param.p;
-		n_elt = (ntohs(param.p->length) - sizeof(sctp_paramhdr_t)) >> 1;
+		n_elt = (ntohs(param.p->length) -
+			 sizeof(struct sctp_paramhdr)) >> 1;
 
 		/* SCTP-AUTH: Section 6.1
 		 * The HMAC algorithm based on SHA-1 MUST be supported and
@@ -2565,7 +2566,7 @@ static int sctp_process_param(struct sctp_association *asoc,
 			asoc->peer.ipv4_address = 1;
 
 		/* Cycle through address types; avoid divide by 0. */
-		sat = ntohs(param.p->length) - sizeof(sctp_paramhdr_t);
+		sat = ntohs(param.p->length) - sizeof(struct sctp_paramhdr);
 		if (sat)
 			sat /= sizeof(__u16);
 
@@ -2592,7 +2593,7 @@ static int sctp_process_param(struct sctp_association *asoc,
 
 	case SCTP_PARAM_STATE_COOKIE:
 		asoc->peer.cookie_len =
-			ntohs(param.p->length) - sizeof(sctp_paramhdr_t);
+			ntohs(param.p->length) - sizeof(struct sctp_paramhdr);
 		asoc->peer.cookie = param.cookie->body;
 		break;
 
@@ -3176,7 +3177,7 @@ bool sctp_verify_asconf(const struct sctp_association *asoc,
 				return false;
 			length = ntohs(param.addip->param_hdr.length);
 			if (length < sizeof(sctp_addip_param_t) +
-				     sizeof(sctp_paramhdr_t))
+				     sizeof(**errp))
 				return false;
 			break;
 		case SCTP_PARAM_SUCCESS_REPORT:
diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index 2b7c07f..0a01c68 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -1081,7 +1081,7 @@ sctp_disposition_t sctp_sf_beat_8_3(struct net *net,
 				    void *arg,
 				    sctp_cmd_seq_t *commands)
 {
-	sctp_paramhdr_t *param_hdr;
+	struct sctp_paramhdr *param_hdr;
 	struct sctp_chunk *chunk = arg;
 	struct sctp_chunk *reply;
 	size_t paylen = 0;
@@ -1098,8 +1098,8 @@ sctp_disposition_t sctp_sf_beat_8_3(struct net *net,
 	 * respond with a HEARTBEAT ACK that contains the Heartbeat
 	 * Information field copied from the received HEARTBEAT chunk.
 	 */
-	chunk->subh.hb_hdr = (sctp_heartbeathdr_t *) chunk->skb->data;
-	param_hdr = (sctp_paramhdr_t *) chunk->subh.hb_hdr;
+	chunk->subh.hb_hdr = (sctp_heartbeathdr_t *)chunk->skb->data;
+	param_hdr = (struct sctp_paramhdr *)chunk->subh.hb_hdr;
 	paylen = ntohs(chunk->chunk_hdr->length) - sizeof(struct sctp_chunkhdr);
 
 	if (ntohs(param_hdr->length) > paylen)
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 7b6e20e..d028bf6 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -6033,7 +6033,8 @@ static int sctp_getsockopt_hmac_ident(struct sock *sk, int len,
 		return -EACCES;
 
 	hmacs = ep->auth_hmacs_list;
-	data_len = ntohs(hmacs->param_hdr.length) - sizeof(sctp_paramhdr_t);
+	data_len = ntohs(hmacs->param_hdr.length) -
+		   sizeof(struct sctp_paramhdr);
 
 	if (len < sizeof(struct sctp_hmacalgo) + data_len)
 		return -EINVAL;
@@ -6117,7 +6118,7 @@ static int sctp_getsockopt_peer_auth_chunks(struct sock *sk, int len,
 		goto num;
 
 	/* See if the user provided enough room for all the data */
-	num_chunks = ntohs(ch->param_hdr.length) - sizeof(sctp_paramhdr_t);
+	num_chunks = ntohs(ch->param_hdr.length) - sizeof(struct sctp_paramhdr);
 	if (len < num_chunks)
 		return -EINVAL;
 
@@ -6165,7 +6166,7 @@ static int sctp_getsockopt_local_auth_chunks(struct sock *sk, int len,
 	if (!ch)
 		goto num;
 
-	num_chunks = ntohs(ch->param_hdr.length) - sizeof(sctp_paramhdr_t);
+	num_chunks = ntohs(ch->param_hdr.length) - sizeof(struct sctp_paramhdr);
 	if (len < sizeof(struct sctp_authchunks) + num_chunks)
 		return -EINVAL;
 
diff --git a/net/sctp/stream.c b/net/sctp/stream.c
index 82e6d40..63ea155 100644
--- a/net/sctp/stream.c
+++ b/net/sctp/stream.c
@@ -304,7 +304,7 @@ int sctp_send_add_streams(struct sctp_association *asoc,
 	return retval;
 }
 
-static sctp_paramhdr_t *sctp_chunk_lookup_strreset_param(
+static struct sctp_paramhdr *sctp_chunk_lookup_strreset_param(
 			struct sctp_association *asoc, __u32 resp_seq,
 			__be16 type)
 {
@@ -749,7 +749,7 @@ struct sctp_chunk *sctp_process_strreset_resp(
 	struct sctp_strreset_resp *resp = param.v;
 	struct sctp_transport *t;
 	__u16 i, nums, flags = 0;
-	sctp_paramhdr_t *req;
+	struct sctp_paramhdr *req;
 	__u32 result;
 
 	req = sctp_chunk_lookup_strreset_param(asoc, resp->response_seq, 0);
-- 
2.1.0
