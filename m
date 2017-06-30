From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net-next 11/11] sctp: remove the typedef sctp_init_chunk_t
Date: Fri, 30 Jun 2017 11:52:22 +0800
Message-ID: <ab87e9c7c656977ed9365ddf4894ce0061c300c5.1498794482.git.lucien.xin@gmail.com>
References: <cover.1498794481.git.lucien.xin@gmail.com>
 <d99d14fbe257b7d7b290296646772c6df35a36c8.1498794482.git.lucien.xin@gmail.com>
 <9b26ac600c9c3f9426b370ecd69261c25d220b2b.1498794482.git.lucien.xin@gmail.com>
 <d522a5f819078da037df984f9fa1897b0cf57433.1498794482.git.lucien.xin@gmail.com>
 <bd4d24bbff8ff402d30c8a148f6ea4332beb5005.1498794482.git.lucien.xin@gmail.com>
 <2ae031641ce87e8fa77af7d3ea31b163f6c25f3d.1498794482.git.lucien.xin@gmail.com>
 <794094c6a1a0fdbf5374c983b2558e1316a51fd4.1498794482.git.lucien.xin@gmail.com>
 <81c68360c17817528e46216d9d48168b35e44434.1498794482.git.lucien.xin@gmail.com>
 <e33aff0cf96df1a50ec1ead7a4d5101492df9aac.1498794482.git.lucien.xin@gmail.com>
 <029bbe69851dfbdc58ffa19e9712fa84d54eb9b5.1498794482.git.lucien.xin@gmail.com>
 <311bd2b7c35122d71d8922700a1fddf9f0b4a5a1.1498794482.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:33539 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751696AbdF3DyU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Jun 2017 23:54:20 -0400
In-Reply-To: <311bd2b7c35122d71d8922700a1fddf9f0b4a5a1.1498794482.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1498794481.git.lucien.xin@gmail.com>
References: <cover.1498794481.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to remove the typedef sctp_init_chunk_t, and replace
with struct sctp_init_chunk in the places where it's using this
typedef.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/linux/sctp.h       |  6 +++---
 include/net/sctp/command.h |  4 ++--
 include/net/sctp/structs.h |  4 ++--
 net/sctp/input.c           |  4 ++--
 net/sctp/sm_make_chunk.c   |  6 +++---
 net/sctp/sm_sideeffect.c   |  2 +-
 net/sctp/sm_statefuns.c    | 28 ++++++++++++++--------------
 7 files changed, 27 insertions(+), 27 deletions(-)

diff --git a/include/linux/sctp.h b/include/linux/sctp.h
index 5624195..99e8664 100644
--- a/include/linux/sctp.h
+++ b/include/linux/sctp.h
@@ -266,10 +266,10 @@ struct sctp_inithdr {
 	__u8  params[0];
 };
 
-typedef struct sctp_init_chunk {
+struct sctp_init_chunk {
 	struct sctp_chunkhdr chunk_hdr;
 	struct sctp_inithdr init_hdr;
-} sctp_init_chunk_t;
+};
 
 
 /* Section 3.3.2.1. IPv4 Address Parameter (5) */
@@ -341,7 +341,7 @@ typedef struct sctp_hmac_algo_param {
  *   The INIT ACK chunk is used to acknowledge the initiation of an SCTP
  *   association.
  */
-typedef sctp_init_chunk_t sctp_initack_chunk_t;
+typedef struct sctp_init_chunk sctp_initack_chunk_t;
 
 /* Section 3.3.3.1 State Cookie (7) */
 typedef struct sctp_cookie_param {
diff --git a/include/net/sctp/command.h b/include/net/sctp/command.h
index d4a20d0..d4679e7 100644
--- a/include/net/sctp/command.h
+++ b/include/net/sctp/command.h
@@ -132,7 +132,7 @@ typedef union {
 	struct sctp_association *asoc;
 	struct sctp_transport *transport;
 	struct sctp_bind_addr *bp;
-	sctp_init_chunk_t *init;
+	struct sctp_init_chunk *init;
 	struct sctp_ulpevent *ulpevent;
 	struct sctp_packet *packet;
 	sctp_sackhdr_t *sackh;
@@ -173,7 +173,7 @@ SCTP_ARG_CONSTRUCTOR(CHUNK,	struct sctp_chunk *, chunk)
 SCTP_ARG_CONSTRUCTOR(ASOC,	struct sctp_association *, asoc)
 SCTP_ARG_CONSTRUCTOR(TRANSPORT,	struct sctp_transport *, transport)
 SCTP_ARG_CONSTRUCTOR(BA,	struct sctp_bind_addr *, bp)
-SCTP_ARG_CONSTRUCTOR(PEER_INIT,	sctp_init_chunk_t *, init)
+SCTP_ARG_CONSTRUCTOR(PEER_INIT,	struct sctp_init_chunk *, init)
 SCTP_ARG_CONSTRUCTOR(ULPEVENT,  struct sctp_ulpevent *, ulpevent)
 SCTP_ARG_CONSTRUCTOR(PACKET,	struct sctp_packet *, packet)
 SCTP_ARG_CONSTRUCTOR(SACKH,	sctp_sackhdr_t *, sackh)
diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index 2393d2e..07c11fe 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -1298,11 +1298,11 @@ int sctp_has_association(struct net *net, const union sctp_addr *laddr,
 
 int sctp_verify_init(struct net *net, const struct sctp_endpoint *ep,
 		     const struct sctp_association *asoc,
-		     enum sctp_cid cid, sctp_init_chunk_t *peer_init,
+		     enum sctp_cid cid, struct sctp_init_chunk *peer_init,
 		     struct sctp_chunk *chunk, struct sctp_chunk **err_chunk);
 int sctp_process_init(struct sctp_association *, struct sctp_chunk *chunk,
 		      const union sctp_addr *peer,
-		      sctp_init_chunk_t *init, gfp_t gfp);
+		      struct sctp_init_chunk *init, gfp_t gfp);
 __u32 sctp_generate_tag(const struct sctp_endpoint *);
 __u32 sctp_generate_tsn(const struct sctp_endpoint *);
 
diff --git a/net/sctp/input.c b/net/sctp/input.c
index a9994c4..41eb2ec 100644
--- a/net/sctp/input.c
+++ b/net/sctp/input.c
@@ -1051,7 +1051,7 @@ static struct sctp_association *__sctp_rcv_init_lookup(struct net *net,
 	union sctp_addr *paddr = &addr;
 	struct sctphdr *sh = sctp_hdr(skb);
 	union sctp_params params;
-	sctp_init_chunk_t *init;
+	struct sctp_init_chunk *init;
 	struct sctp_af *af;
 
 	/*
@@ -1070,7 +1070,7 @@ static struct sctp_association *__sctp_rcv_init_lookup(struct net *net,
 	/* Find the start of the TLVs and the end of the chunk.  This is
 	 * the region we search for address parameters.
 	 */
-	init = (sctp_init_chunk_t *)skb->data;
+	init = (struct sctp_init_chunk *)skb->data;
 
 	/* Walk the parameters looking for embedded addresses. */
 	sctp_walk_params(params, init, init_hdr.params) {
diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index 8b9ca10..3af4dd0 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -2242,8 +2242,8 @@ static sctp_ierror_t sctp_verify_param(struct net *net,
 /* Verify the INIT packet before we process it.  */
 int sctp_verify_init(struct net *net, const struct sctp_endpoint *ep,
 		     const struct sctp_association *asoc, enum sctp_cid cid,
-		     sctp_init_chunk_t *peer_init, struct sctp_chunk *chunk,
-		     struct sctp_chunk **errp)
+		     struct sctp_init_chunk *peer_init,
+		     struct sctp_chunk *chunk, struct sctp_chunk **errp)
 {
 	union sctp_params param;
 	bool has_cookie = false;
@@ -2307,7 +2307,7 @@ int sctp_verify_init(struct net *net, const struct sctp_endpoint *ep,
  */
 int sctp_process_init(struct sctp_association *asoc, struct sctp_chunk *chunk,
 		      const union sctp_addr *peer_addr,
-		      sctp_init_chunk_t *peer_init, gfp_t gfp)
+		      struct sctp_init_chunk *peer_init, gfp_t gfp)
 {
 	struct net *net = sock_net(asoc->base.sk);
 	union sctp_params param;
diff --git a/net/sctp/sm_sideeffect.c b/net/sctp/sm_sideeffect.c
index b255339..d6e5e9e 100644
--- a/net/sctp/sm_sideeffect.c
+++ b/net/sctp/sm_sideeffect.c
@@ -647,7 +647,7 @@ static void sctp_cmd_assoc_failed(sctp_cmd_seq_t *commands,
 static int sctp_cmd_process_init(sctp_cmd_seq_t *commands,
 				 struct sctp_association *asoc,
 				 struct sctp_chunk *chunk,
-				 sctp_init_chunk_t *peer_init,
+				 struct sctp_init_chunk *peer_init,
 				 gfp_t gfp)
 {
 	int error;
diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index 71b6e3f..b2a74c3 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -345,7 +345,7 @@ sctp_disposition_t sctp_sf_do_5_1B_init(struct net *net,
 	 * error, but since we don't have an association, we'll
 	 * just discard the packet.
 	 */
-	if (!sctp_chunk_length_valid(chunk, sizeof(sctp_init_chunk_t)))
+	if (!sctp_chunk_length_valid(chunk, sizeof(struct sctp_init_chunk)))
 		return sctp_sf_pdiscard(net, ep, asoc, type, arg, commands);
 
 	/* If the INIT is coming toward a closing socket, we'll send back
@@ -360,7 +360,7 @@ sctp_disposition_t sctp_sf_do_5_1B_init(struct net *net,
 	/* Verify the INIT chunk before processing it. */
 	err_chunk = NULL;
 	if (!sctp_verify_init(net, ep, asoc, chunk->chunk_hdr->type,
-			      (sctp_init_chunk_t *)chunk->chunk_hdr, chunk,
+			      (struct sctp_init_chunk *)chunk->chunk_hdr, chunk,
 			      &err_chunk)) {
 		/* This chunk contains fatal error. It is to be discarded.
 		 * Send an ABORT, with causes if there is any.
@@ -405,7 +405,7 @@ sctp_disposition_t sctp_sf_do_5_1B_init(struct net *net,
 
 	/* The call, sctp_process_init(), can fail on memory allocation.  */
 	if (!sctp_process_init(new_asoc, chunk, sctp_source(chunk),
-			       (sctp_init_chunk_t *)chunk->chunk_hdr,
+			       (struct sctp_init_chunk *)chunk->chunk_hdr,
 			       GFP_ATOMIC))
 		goto nomem_init;
 
@@ -503,7 +503,7 @@ sctp_disposition_t sctp_sf_do_5_1C_ack(struct net *net,
 				       sctp_cmd_seq_t *commands)
 {
 	struct sctp_chunk *chunk = arg;
-	sctp_init_chunk_t *initchunk;
+	struct sctp_init_chunk *initchunk;
 	struct sctp_chunk *err_chunk;
 	struct sctp_packet *packet;
 
@@ -527,7 +527,7 @@ sctp_disposition_t sctp_sf_do_5_1C_ack(struct net *net,
 	/* Verify the INIT chunk before processing it. */
 	err_chunk = NULL;
 	if (!sctp_verify_init(net, ep, asoc, chunk->chunk_hdr->type,
-			      (sctp_init_chunk_t *)chunk->chunk_hdr, chunk,
+			      (struct sctp_init_chunk *)chunk->chunk_hdr, chunk,
 			      &err_chunk)) {
 
 		sctp_error_t error = SCTP_ERROR_NO_RESOURCE;
@@ -578,7 +578,7 @@ sctp_disposition_t sctp_sf_do_5_1C_ack(struct net *net,
 	 */
 	chunk->param_hdr.v = skb_pull(chunk->skb, sizeof(struct sctp_inithdr));
 
-	initchunk = (sctp_init_chunk_t *) chunk->chunk_hdr;
+	initchunk = (struct sctp_init_chunk *)chunk->chunk_hdr;
 
 	sctp_add_cmd_sf(commands, SCTP_CMD_PEER_INIT,
 			SCTP_PEER_INIT(initchunk));
@@ -653,7 +653,7 @@ sctp_disposition_t sctp_sf_do_5_1D_ce(struct net *net,
 {
 	struct sctp_chunk *chunk = arg;
 	struct sctp_association *new_asoc;
-	sctp_init_chunk_t *peer_init;
+	struct sctp_init_chunk *peer_init;
 	struct sctp_chunk *repl;
 	struct sctp_ulpevent *ev, *ai_ev = NULL;
 	int error = 0;
@@ -1450,7 +1450,7 @@ static sctp_disposition_t sctp_sf_do_unexpected_init(
 	 * In this case, we generate a protocol violation since we have
 	 * an association established.
 	 */
-	if (!sctp_chunk_length_valid(chunk, sizeof(sctp_init_chunk_t)))
+	if (!sctp_chunk_length_valid(chunk, sizeof(struct sctp_init_chunk)))
 		return sctp_sf_violation_chunklen(net, ep, asoc, type, arg,
 						  commands);
 	/* Grab the INIT header.  */
@@ -1462,7 +1462,7 @@ static sctp_disposition_t sctp_sf_do_unexpected_init(
 	/* Verify the INIT chunk before processing it. */
 	err_chunk = NULL;
 	if (!sctp_verify_init(net, ep, asoc, chunk->chunk_hdr->type,
-			      (sctp_init_chunk_t *)chunk->chunk_hdr, chunk,
+			      (struct sctp_init_chunk *)chunk->chunk_hdr, chunk,
 			      &err_chunk)) {
 		/* This chunk contains fatal error. It is to be discarded.
 		 * Send an ABORT, with causes if there is any.
@@ -1509,7 +1509,7 @@ static sctp_disposition_t sctp_sf_do_unexpected_init(
 	 * place (local tie-tag and per tie-tag) within the state cookie.
 	 */
 	if (!sctp_process_init(new_asoc, chunk, sctp_source(chunk),
-			       (sctp_init_chunk_t *)chunk->chunk_hdr,
+			       (struct sctp_init_chunk *)chunk->chunk_hdr,
 			       GFP_ATOMIC))
 		goto nomem;
 
@@ -1730,7 +1730,7 @@ static sctp_disposition_t sctp_sf_do_dupcook_a(struct net *net,
 					sctp_cmd_seq_t *commands,
 					struct sctp_association *new_asoc)
 {
-	sctp_init_chunk_t *peer_init;
+	struct sctp_init_chunk *peer_init;
 	struct sctp_ulpevent *ev;
 	struct sctp_chunk *repl;
 	struct sctp_chunk *err;
@@ -1845,7 +1845,7 @@ static sctp_disposition_t sctp_sf_do_dupcook_b(struct net *net,
 					sctp_cmd_seq_t *commands,
 					struct sctp_association *new_asoc)
 {
-	sctp_init_chunk_t *peer_init;
+	struct sctp_init_chunk *peer_init;
 	struct sctp_chunk *repl;
 
 	/* new_asoc is a brand-new association, so these are not yet
@@ -6124,9 +6124,9 @@ static struct sctp_packet *sctp_ootb_pkt_new(struct net *net,
 		switch (chunk->chunk_hdr->type) {
 		case SCTP_CID_INIT:
 		{
-			sctp_init_chunk_t *init;
+			struct sctp_init_chunk *init;
 
-			init = (sctp_init_chunk_t *)chunk->chunk_hdr;
+			init = (struct sctp_init_chunk *)chunk->chunk_hdr;
 			vtag = ntohl(init->init_hdr.init_tag);
 			break;
 		}
-- 
2.1.0
