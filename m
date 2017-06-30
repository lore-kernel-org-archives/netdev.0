From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net-next 10/11] sctp: remove the typedef sctp_inithdr_t
Date: Fri, 30 Jun 2017 11:52:21 +0800
Message-ID: <311bd2b7c35122d71d8922700a1fddf9f0b4a5a1.1498794482.git.lucien.xin@gmail.com>
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
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:33498 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751808AbdF3DyH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Jun 2017 23:54:07 -0400
In-Reply-To: <029bbe69851dfbdc58ffa19e9712fa84d54eb9b5.1498794482.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1498794481.git.lucien.xin@gmail.com>
References: <cover.1498794481.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to remove the typedef sctp_inithdr_t, and replace
with struct sctp_inithdr in the places where it's using this
typedef.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/linux/sctp.h                    |  6 +++---
 net/netfilter/nf_conntrack_proto_sctp.c |  4 ++--
 net/sctp/sm_make_chunk.c                |  4 ++--
 net/sctp/sm_statefuns.c                 | 12 ++++++------
 4 files changed, 13 insertions(+), 13 deletions(-)

diff --git a/include/linux/sctp.h b/include/linux/sctp.h
index 91c888f..5624195 100644
--- a/include/linux/sctp.h
+++ b/include/linux/sctp.h
@@ -257,18 +257,18 @@ enum { SCTP_DATA_FRAG_MASK = 0x03, };
  *  This chunk is used to initiate a SCTP association between two
  *  endpoints.
  */
-typedef struct sctp_inithdr {
+struct sctp_inithdr {
 	__be32 init_tag;
 	__be32 a_rwnd;
 	__be16 num_outbound_streams;
 	__be16 num_inbound_streams;
 	__be32 initial_tsn;
 	__u8  params[0];
-} sctp_inithdr_t;
+};
 
 typedef struct sctp_init_chunk {
 	struct sctp_chunkhdr chunk_hdr;
-	sctp_inithdr_t init_hdr;
+	struct sctp_inithdr init_hdr;
 } sctp_init_chunk_t;
 
 
diff --git a/net/netfilter/nf_conntrack_proto_sctp.c b/net/netfilter/nf_conntrack_proto_sctp.c
index b841a8a..31c6c8e 100644
--- a/net/netfilter/nf_conntrack_proto_sctp.c
+++ b/net/netfilter/nf_conntrack_proto_sctp.c
@@ -395,7 +395,7 @@ static int sctp_packet(struct nf_conn *ct,
 		/* If it is an INIT or an INIT ACK note down the vtag */
 		if (sch->type == SCTP_CID_INIT ||
 		    sch->type == SCTP_CID_INIT_ACK) {
-			sctp_inithdr_t _inithdr, *ih;
+			struct sctp_inithdr _inithdr, *ih;
 
 			ih = skb_header_pointer(skb, offset + sizeof(_sch),
 						sizeof(_inithdr), &_inithdr);
@@ -471,7 +471,7 @@ static bool sctp_new(struct nf_conn *ct, const struct sk_buff *skb,
 
 		/* Copy the vtag into the state info */
 		if (sch->type == SCTP_CID_INIT) {
-			sctp_inithdr_t _inithdr, *ih;
+			struct sctp_inithdr _inithdr, *ih;
 			/* Sec 8.5.1 (A) */
 			if (sh->vtag)
 				return false;
diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index 3ed2108..8b9ca10 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -217,7 +217,7 @@ struct sctp_chunk *sctp_make_init(const struct sctp_association *asoc,
 {
 	struct net *net = sock_net(asoc->base.sk);
 	struct sctp_endpoint *ep = asoc->ep;
-	sctp_inithdr_t init;
+	struct sctp_inithdr init;
 	union sctp_params addrs;
 	size_t chunksize;
 	struct sctp_chunk *retval = NULL;
@@ -385,7 +385,7 @@ struct sctp_chunk *sctp_make_init_ack(const struct sctp_association *asoc,
 				 const struct sctp_chunk *chunk,
 				 gfp_t gfp, int unkparam_len)
 {
-	sctp_inithdr_t initack;
+	struct sctp_inithdr initack;
 	struct sctp_chunk *retval;
 	union sctp_params addrs;
 	struct sctp_sock *sp;
diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index 212fe76..71b6e3f 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -389,10 +389,10 @@ sctp_disposition_t sctp_sf_do_5_1B_init(struct net *net,
 	}
 
 	/* Grab the INIT header.  */
-	chunk->subh.init_hdr = (sctp_inithdr_t *)chunk->skb->data;
+	chunk->subh.init_hdr = (struct sctp_inithdr *)chunk->skb->data;
 
 	/* Tag the variable length parameters.  */
-	chunk->param_hdr.v = skb_pull(chunk->skb, sizeof(sctp_inithdr_t));
+	chunk->param_hdr.v = skb_pull(chunk->skb, sizeof(struct sctp_inithdr));
 
 	new_asoc = sctp_make_temp_asoc(ep, chunk, GFP_ATOMIC);
 	if (!new_asoc)
@@ -522,7 +522,7 @@ sctp_disposition_t sctp_sf_do_5_1C_ack(struct net *net,
 		return sctp_sf_violation_chunklen(net, ep, asoc, type, arg,
 						  commands);
 	/* Grab the INIT header.  */
-	chunk->subh.init_hdr = (sctp_inithdr_t *) chunk->skb->data;
+	chunk->subh.init_hdr = (struct sctp_inithdr *)chunk->skb->data;
 
 	/* Verify the INIT chunk before processing it. */
 	err_chunk = NULL;
@@ -576,7 +576,7 @@ sctp_disposition_t sctp_sf_do_5_1C_ack(struct net *net,
 	/* Tag the variable length parameters.  Note that we never
 	 * convert the parameters in an INIT chunk.
 	 */
-	chunk->param_hdr.v = skb_pull(chunk->skb, sizeof(sctp_inithdr_t));
+	chunk->param_hdr.v = skb_pull(chunk->skb, sizeof(struct sctp_inithdr));
 
 	initchunk = (sctp_init_chunk_t *) chunk->chunk_hdr;
 
@@ -1454,10 +1454,10 @@ static sctp_disposition_t sctp_sf_do_unexpected_init(
 		return sctp_sf_violation_chunklen(net, ep, asoc, type, arg,
 						  commands);
 	/* Grab the INIT header.  */
-	chunk->subh.init_hdr = (sctp_inithdr_t *) chunk->skb->data;
+	chunk->subh.init_hdr = (struct sctp_inithdr *)chunk->skb->data;
 
 	/* Tag the variable length parameters.  */
-	chunk->param_hdr.v = skb_pull(chunk->skb, sizeof(sctp_inithdr_t));
+	chunk->param_hdr.v = skb_pull(chunk->skb, sizeof(struct sctp_inithdr));
 
 	/* Verify the INIT chunk before processing it. */
 	err_chunk = NULL;
-- 
2.1.0
