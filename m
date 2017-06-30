From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net-next 02/11] sctp: remove the typedef sctp_chunkhdr_t
Date: Fri, 30 Jun 2017 11:52:13 +0800
Message-ID: <9b26ac600c9c3f9426b370ecd69261c25d220b2b.1498794482.git.lucien.xin@gmail.com>
References: <cover.1498794481.git.lucien.xin@gmail.com>
 <d99d14fbe257b7d7b290296646772c6df35a36c8.1498794482.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:36594 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751722AbdF3Dw7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Jun 2017 23:52:59 -0400
In-Reply-To: <d99d14fbe257b7d7b290296646772c6df35a36c8.1498794482.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1498794481.git.lucien.xin@gmail.com>
References: <cover.1498794481.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to remove the typedef sctp_chunkhdr_t, and replace
with struct sctp_chunkhdr in the places where it's using this
typedef.

It is also to fix some indents and use sizeof(variable) instead
of sizeof(type)., especially in sctp_new.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/linux/sctp.h                    | 34 ++++++++---------
 include/net/sctp/sctp.h                 |  2 +-
 net/netfilter/ipvs/ip_vs_core.c         |  4 +-
 net/netfilter/ipvs/ip_vs_proto_sctp.c   |  6 +--
 net/netfilter/nf_conntrack_proto_sctp.c | 29 +++++++-------
 net/netfilter/xt_sctp.c                 |  4 +-
 net/sctp/input.c                        | 20 +++++-----
 net/sctp/inqueue.c                      | 15 ++++----
 net/sctp/sm_make_chunk.c                | 17 +++++----
 net/sctp/sm_sideeffect.c                |  5 ++-
 net/sctp/sm_statefuns.c                 | 67 +++++++++++++++++----------------
 net/sctp/ulpevent.c                     |  2 +-
 12 files changed, 102 insertions(+), 103 deletions(-)

diff --git a/include/linux/sctp.h b/include/linux/sctp.h
index 85540ec..9ad5b9e 100644
--- a/include/linux/sctp.h
+++ b/include/linux/sctp.h
@@ -70,11 +70,11 @@ static inline struct sctphdr *sctp_hdr(const struct sk_buff *skb)
 }
 
 /* Section 3.2.  Chunk Field Descriptions. */
-typedef struct sctp_chunkhdr {
+struct sctp_chunkhdr {
 	__u8 type;
 	__u8 flags;
 	__be16 length;
-} sctp_chunkhdr_t;
+};
 
 
 /* Section 3.2.  Chunk Type Values.
@@ -236,8 +236,8 @@ typedef struct sctp_datahdr {
 } sctp_datahdr_t;
 
 typedef struct sctp_data_chunk {
-        sctp_chunkhdr_t chunk_hdr;
-        sctp_datahdr_t  data_hdr;
+	struct sctp_chunkhdr chunk_hdr;
+	sctp_datahdr_t  data_hdr;
 } sctp_data_chunk_t;
 
 /* DATA Chuck Specific Flags */
@@ -267,7 +267,7 @@ typedef struct sctp_inithdr {
 } sctp_inithdr_t;
 
 typedef struct sctp_init_chunk {
-	sctp_chunkhdr_t chunk_hdr;
+	struct sctp_chunkhdr chunk_hdr;
 	sctp_inithdr_t init_hdr;
 } sctp_init_chunk_t;
 
@@ -386,7 +386,7 @@ typedef struct sctp_sackhdr {
 } sctp_sackhdr_t;
 
 typedef struct sctp_sack_chunk {
-	sctp_chunkhdr_t chunk_hdr;
+	struct sctp_chunkhdr chunk_hdr;
 	sctp_sackhdr_t sack_hdr;
 } sctp_sack_chunk_t;
 
@@ -403,7 +403,7 @@ typedef struct sctp_heartbeathdr {
 } sctp_heartbeathdr_t;
 
 typedef struct sctp_heartbeat_chunk {
-	sctp_chunkhdr_t chunk_hdr;
+	struct sctp_chunkhdr chunk_hdr;
 	sctp_heartbeathdr_t hb_hdr;
 } sctp_heartbeat_chunk_t;
 
@@ -413,7 +413,7 @@ typedef struct sctp_heartbeat_chunk {
  * chunk descriptor.
  */
 typedef struct sctp_abort_chunk {
-        sctp_chunkhdr_t uh;
+	struct sctp_chunkhdr uh;
 } sctp_abort_chunk_t;
 
 
@@ -425,8 +425,8 @@ typedef struct sctp_shutdownhdr {
 } sctp_shutdownhdr_t;
 
 struct sctp_shutdown_chunk_t {
-        sctp_chunkhdr_t    chunk_hdr;
-        sctp_shutdownhdr_t shutdown_hdr;
+	struct sctp_chunkhdr chunk_hdr;
+	sctp_shutdownhdr_t shutdown_hdr;
 };
 
 /* RFC 2960.  Section 3.3.10 Operation Error (ERROR) (9) */
@@ -438,8 +438,8 @@ typedef struct sctp_errhdr {
 } sctp_errhdr_t;
 
 typedef struct sctp_operr_chunk {
-        sctp_chunkhdr_t chunk_hdr;
-	sctp_errhdr_t   err_hdr;
+	struct sctp_chunkhdr chunk_hdr;
+	sctp_errhdr_t err_hdr;
 } sctp_operr_chunk_t;
 
 /* RFC 2960 3.3.10 - Operation Error
@@ -528,7 +528,7 @@ typedef struct sctp_ecnehdr {
 } sctp_ecnehdr_t;
 
 typedef struct sctp_ecne_chunk {
-	sctp_chunkhdr_t chunk_hdr;
+	struct sctp_chunkhdr chunk_hdr;
 	sctp_ecnehdr_t ence_hdr;
 } sctp_ecne_chunk_t;
 
@@ -540,7 +540,7 @@ typedef struct sctp_cwrhdr {
 } sctp_cwrhdr_t;
 
 typedef struct sctp_cwr_chunk {
-	sctp_chunkhdr_t chunk_hdr;
+	struct sctp_chunkhdr chunk_hdr;
 	sctp_cwrhdr_t cwr_hdr;
 } sctp_cwr_chunk_t;
 
@@ -649,7 +649,7 @@ typedef struct sctp_addiphdr {
 } sctp_addiphdr_t;
 
 typedef struct sctp_addip_chunk {
-	sctp_chunkhdr_t chunk_hdr;
+	struct sctp_chunkhdr chunk_hdr;
 	sctp_addiphdr_t addip_hdr;
 } sctp_addip_chunk_t;
 
@@ -709,7 +709,7 @@ typedef struct sctp_authhdr {
 } sctp_authhdr_t;
 
 typedef struct sctp_auth_chunk {
-	sctp_chunkhdr_t chunk_hdr;
+	struct sctp_chunkhdr chunk_hdr;
 	sctp_authhdr_t auth_hdr;
 } sctp_auth_chunk_t;
 
@@ -719,7 +719,7 @@ struct sctp_infox {
 };
 
 struct sctp_reconf_chunk {
-	sctp_chunkhdr_t chunk_hdr;
+	struct sctp_chunkhdr chunk_hdr;
 	__u8 params[0];
 };
 
diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
index 069582e..d756bd0 100644
--- a/include/net/sctp/sctp.h
+++ b/include/net/sctp/sctp.h
@@ -478,7 +478,7 @@ _sctp_walk_errors((err), (chunk_hdr), ntohs((chunk_hdr)->length))
 
 #define _sctp_walk_errors(err, chunk_hdr, end)\
 for (err = (sctp_errhdr_t *)((void *)chunk_hdr + \
-	    sizeof(sctp_chunkhdr_t));\
+	    sizeof(struct sctp_chunkhdr));\
      (void *)err <= (void *)chunk_hdr + end - ntohs(err->length) &&\
      ntohs(err->length) >= sizeof(sctp_errhdr_t); \
      err = (sctp_errhdr_t *)((void *)err + SCTP_PAD4(ntohs(err->length))))
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 6f39af9..e31956b 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -1037,7 +1037,7 @@ static int ip_vs_out_icmp_v6(struct netns_ipvs *ipvs, struct sk_buff *skb,
  */
 static inline int is_sctp_abort(const struct sk_buff *skb, int nh_len)
 {
-	sctp_chunkhdr_t *sch, schunk;
+	struct sctp_chunkhdr *sch, schunk;
 	sch = skb_header_pointer(skb, nh_len + sizeof(struct sctphdr),
 				 sizeof(schunk), &schunk);
 	if (sch == NULL)
@@ -1070,7 +1070,7 @@ static inline bool is_new_conn(const struct sk_buff *skb,
 		return th->syn;
 	}
 	case IPPROTO_SCTP: {
-		sctp_chunkhdr_t *sch, schunk;
+		struct sctp_chunkhdr *sch, schunk;
 
 		sch = skb_header_pointer(skb, iph->len + sizeof(struct sctphdr),
 					 sizeof(schunk), &schunk);
diff --git a/net/netfilter/ipvs/ip_vs_proto_sctp.c b/net/netfilter/ipvs/ip_vs_proto_sctp.c
index 6b38cad..3ffad4a 100644
--- a/net/netfilter/ipvs/ip_vs_proto_sctp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_sctp.c
@@ -15,7 +15,7 @@ sctp_conn_schedule(struct netns_ipvs *ipvs, int af, struct sk_buff *skb,
 		   struct ip_vs_iphdr *iph)
 {
 	struct ip_vs_service *svc;
-	sctp_chunkhdr_t _schunkh, *sch;
+	struct sctp_chunkhdr _schunkh, *sch;
 	struct sctphdr *sh, _sctph;
 	__be16 _ports[2], *ports = NULL;
 
@@ -377,7 +377,7 @@ static inline void
 set_sctp_state(struct ip_vs_proto_data *pd, struct ip_vs_conn *cp,
 		int direction, const struct sk_buff *skb)
 {
-	sctp_chunkhdr_t _sctpch, *sch;
+	struct sctp_chunkhdr _sctpch, *sch;
 	unsigned char chunk_type;
 	int event, next_state;
 	int ihl, cofs;
@@ -409,7 +409,7 @@ set_sctp_state(struct ip_vs_proto_data *pd, struct ip_vs_conn *cp,
 	    (sch->type == SCTP_CID_COOKIE_ACK)) {
 		int clen = ntohs(sch->length);
 
-		if (clen >= sizeof(sctp_chunkhdr_t)) {
+		if (clen >= sizeof(_sctpch)) {
 			sch = skb_header_pointer(skb, cofs + ALIGN(clen, 4),
 						 sizeof(_sctpch), &_sctpch);
 			if (sch && sch->type == SCTP_CID_ABORT)
diff --git a/net/netfilter/nf_conntrack_proto_sctp.c b/net/netfilter/nf_conntrack_proto_sctp.c
index db87af4..b841a8a 100644
--- a/net/netfilter/nf_conntrack_proto_sctp.c
+++ b/net/netfilter/nf_conntrack_proto_sctp.c
@@ -202,7 +202,7 @@ static int do_basic_checks(struct nf_conn *ct,
 			   unsigned long *map)
 {
 	u_int32_t offset, count;
-	sctp_chunkhdr_t _sch, *sch;
+	struct sctp_chunkhdr _sch, *sch;
 	int flag;
 
 	flag = 0;
@@ -397,7 +397,7 @@ static int sctp_packet(struct nf_conn *ct,
 		    sch->type == SCTP_CID_INIT_ACK) {
 			sctp_inithdr_t _inithdr, *ih;
 
-			ih = skb_header_pointer(skb, offset + sizeof(sctp_chunkhdr_t),
+			ih = skb_header_pointer(skb, offset + sizeof(_sch),
 						sizeof(_inithdr), &_inithdr);
 			if (ih == NULL)
 				goto out_unlock;
@@ -471,23 +471,20 @@ static bool sctp_new(struct nf_conn *ct, const struct sk_buff *skb,
 
 		/* Copy the vtag into the state info */
 		if (sch->type == SCTP_CID_INIT) {
-			if (sh->vtag == 0) {
-				sctp_inithdr_t _inithdr, *ih;
+			sctp_inithdr_t _inithdr, *ih;
+			/* Sec 8.5.1 (A) */
+			if (sh->vtag)
+				return false;
 
-				ih = skb_header_pointer(skb, offset + sizeof(sctp_chunkhdr_t),
-							sizeof(_inithdr), &_inithdr);
-				if (ih == NULL)
-					return false;
+			ih = skb_header_pointer(skb, offset + sizeof(_sch),
+						sizeof(_inithdr), &_inithdr);
+			if (!ih)
+				return false;
 
-				pr_debug("Setting vtag %x for new conn\n",
-					 ih->init_tag);
+			pr_debug("Setting vtag %x for new conn\n",
+				 ih->init_tag);
 
-				ct->proto.sctp.vtag[IP_CT_DIR_REPLY] =
-								ih->init_tag;
-			} else {
-				/* Sec 8.5.1 (A) */
-				return false;
-			}
+			ct->proto.sctp.vtag[IP_CT_DIR_REPLY] = ih->init_tag;
 		} else if (sch->type == SCTP_CID_HEARTBEAT) {
 			pr_debug("Setting vtag %x for secondary conntrack\n",
 				 sh->vtag);
diff --git a/net/netfilter/xt_sctp.c b/net/netfilter/xt_sctp.c
index 0f20ea4..2d2fa1d 100644
--- a/net/netfilter/xt_sctp.c
+++ b/net/netfilter/xt_sctp.c
@@ -42,8 +42,8 @@ match_packet(const struct sk_buff *skb,
 	     bool *hotdrop)
 {
 	u_int32_t chunkmapcopy[256 / sizeof (u_int32_t)];
-	const sctp_chunkhdr_t *sch;
-	sctp_chunkhdr_t _sch;
+	const struct sctp_chunkhdr *sch;
+	struct sctp_chunkhdr _sch;
 	int chunk_match_type = info->chunk_match_type;
 	const struct xt_sctp_flag_info *flag_info = info->flag_info;
 	int flag_count = info->flag_count;
diff --git a/net/sctp/input.c b/net/sctp/input.c
index ba9ad32..a9994c4 100644
--- a/net/sctp/input.c
+++ b/net/sctp/input.c
@@ -663,19 +663,19 @@ void sctp_v4_err(struct sk_buff *skb, __u32 info)
  */
 static int sctp_rcv_ootb(struct sk_buff *skb)
 {
-	sctp_chunkhdr_t *ch, _ch;
+	struct sctp_chunkhdr *ch, _ch;
 	int ch_end, offset = 0;
 
 	/* Scan through all the chunks in the packet.  */
 	do {
 		/* Make sure we have at least the header there */
-		if (offset + sizeof(sctp_chunkhdr_t) > skb->len)
+		if (offset + sizeof(_ch) > skb->len)
 			break;
 
 		ch = skb_header_pointer(skb, offset, sizeof(*ch), &_ch);
 
 		/* Break out if chunk length is less then minimal. */
-		if (ntohs(ch->length) < sizeof(sctp_chunkhdr_t))
+		if (ntohs(ch->length) < sizeof(_ch))
 			break;
 
 		ch_end = offset + SCTP_PAD4(ntohs(ch->length));
@@ -1106,7 +1106,7 @@ static struct sctp_association *__sctp_rcv_init_lookup(struct net *net,
  */
 static struct sctp_association *__sctp_rcv_asconf_lookup(
 					struct net *net,
-					sctp_chunkhdr_t *ch,
+					struct sctp_chunkhdr *ch,
 					const union sctp_addr *laddr,
 					__be16 peer_port,
 					struct sctp_transport **transportp)
@@ -1144,7 +1144,7 @@ static struct sctp_association *__sctp_rcv_walk_lookup(struct net *net,
 				      struct sctp_transport **transportp)
 {
 	struct sctp_association *asoc = NULL;
-	sctp_chunkhdr_t *ch;
+	struct sctp_chunkhdr *ch;
 	int have_auth = 0;
 	unsigned int chunk_num = 1;
 	__u8 *ch_end;
@@ -1152,10 +1152,10 @@ static struct sctp_association *__sctp_rcv_walk_lookup(struct net *net,
 	/* Walk through the chunks looking for AUTH or ASCONF chunks
 	 * to help us find the association.
 	 */
-	ch = (sctp_chunkhdr_t *) skb->data;
+	ch = (struct sctp_chunkhdr *)skb->data;
 	do {
 		/* Break out if chunk length is less then minimal. */
-		if (ntohs(ch->length) < sizeof(sctp_chunkhdr_t))
+		if (ntohs(ch->length) < sizeof(*ch))
 			break;
 
 		ch_end = ((__u8 *)ch) + SCTP_PAD4(ntohs(ch->length));
@@ -1192,7 +1192,7 @@ static struct sctp_association *__sctp_rcv_walk_lookup(struct net *net,
 		if (asoc)
 			break;
 
-		ch = (sctp_chunkhdr_t *) ch_end;
+		ch = (struct sctp_chunkhdr *)ch_end;
 		chunk_num++;
 	} while (ch_end < skb_tail_pointer(skb));
 
@@ -1210,7 +1210,7 @@ static struct sctp_association *__sctp_rcv_lookup_harder(struct net *net,
 				      const union sctp_addr *laddr,
 				      struct sctp_transport **transportp)
 {
-	sctp_chunkhdr_t *ch;
+	struct sctp_chunkhdr *ch;
 
 	/* We do not allow GSO frames here as we need to linearize and
 	 * then cannot guarantee frame boundaries. This shouldn't be an
@@ -1220,7 +1220,7 @@ static struct sctp_association *__sctp_rcv_lookup_harder(struct net *net,
 	if ((skb_shinfo(skb)->gso_type & SKB_GSO_SCTP) == SKB_GSO_SCTP)
 		return NULL;
 
-	ch = (sctp_chunkhdr_t *) skb->data;
+	ch = (struct sctp_chunkhdr *)skb->data;
 
 	/* The code below will attempt to walk the chunk and extract
 	 * parameter information.  Before we do that, we need to verify
diff --git a/net/sctp/inqueue.c b/net/sctp/inqueue.c
index f731de3..4839255 100644
--- a/net/sctp/inqueue.c
+++ b/net/sctp/inqueue.c
@@ -99,7 +99,7 @@ void sctp_inq_push(struct sctp_inq *q, struct sctp_chunk *chunk)
 struct sctp_chunkhdr *sctp_inq_peek(struct sctp_inq *queue)
 {
 	struct sctp_chunk *chunk;
-	sctp_chunkhdr_t *ch = NULL;
+	struct sctp_chunkhdr *ch = NULL;
 
 	chunk = queue->in_progress;
 	/* If there is no more chunks in this packet, say so */
@@ -108,7 +108,7 @@ struct sctp_chunkhdr *sctp_inq_peek(struct sctp_inq *queue)
 	    chunk->pdiscard)
 		    return NULL;
 
-	ch = (sctp_chunkhdr_t *)chunk->chunk_end;
+	ch = (struct sctp_chunkhdr *)chunk->chunk_end;
 
 	return ch;
 }
@@ -122,7 +122,7 @@ struct sctp_chunkhdr *sctp_inq_peek(struct sctp_inq *queue)
 struct sctp_chunk *sctp_inq_pop(struct sctp_inq *queue)
 {
 	struct sctp_chunk *chunk;
-	sctp_chunkhdr_t *ch = NULL;
+	struct sctp_chunkhdr *ch = NULL;
 
 	/* The assumption is that we are safe to process the chunks
 	 * at this time.
@@ -151,7 +151,7 @@ struct sctp_chunk *sctp_inq_pop(struct sctp_inq *queue)
 			chunk = queue->in_progress = NULL;
 		} else {
 			/* Nothing to do. Next chunk in the packet, please. */
-			ch = (sctp_chunkhdr_t *) chunk->chunk_end;
+			ch = (struct sctp_chunkhdr *)chunk->chunk_end;
 			/* Force chunk->skb->data to chunk->chunk_end.  */
 			skb_pull(chunk->skb, chunk->chunk_end - chunk->skb->data);
 			/* We are guaranteed to pull a SCTP header. */
@@ -195,7 +195,7 @@ struct sctp_chunk *sctp_inq_pop(struct sctp_inq *queue)
 
 new_skb:
 		/* This is the first chunk in the packet.  */
-		ch = (sctp_chunkhdr_t *) chunk->skb->data;
+		ch = (struct sctp_chunkhdr *)chunk->skb->data;
 		chunk->singleton = 1;
 		chunk->data_accepted = 0;
 		chunk->pdiscard = 0;
@@ -214,11 +214,10 @@ struct sctp_chunk *sctp_inq_pop(struct sctp_inq *queue)
 
 	chunk->chunk_hdr = ch;
 	chunk->chunk_end = ((__u8 *)ch) + SCTP_PAD4(ntohs(ch->length));
-	skb_pull(chunk->skb, sizeof(sctp_chunkhdr_t));
+	skb_pull(chunk->skb, sizeof(*ch));
 	chunk->subh.v = NULL; /* Subheader is no longer valid.  */
 
-	if (chunk->chunk_end + sizeof(sctp_chunkhdr_t) <
-	    skb_tail_pointer(chunk->skb)) {
+	if (chunk->chunk_end + sizeof(*ch) < skb_tail_pointer(chunk->skb)) {
 		/* This is not a singleton */
 		chunk->singleton = 0;
 	} else if (chunk->chunk_end > skb_tail_pointer(chunk->skb)) {
diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index 4b19679..7d4c5a8 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -1379,20 +1379,20 @@ static struct sctp_chunk *_sctp_make_chunk(const struct sctp_association *asoc,
 					    gfp_t gfp)
 {
 	struct sctp_chunk *retval;
-	sctp_chunkhdr_t *chunk_hdr;
+	struct sctp_chunkhdr *chunk_hdr;
 	struct sk_buff *skb;
 	struct sock *sk;
 
 	/* No need to allocate LL here, as this is only a chunk. */
-	skb = alloc_skb(SCTP_PAD4(sizeof(sctp_chunkhdr_t) + paylen), gfp);
+	skb = alloc_skb(SCTP_PAD4(sizeof(*chunk_hdr) + paylen), gfp);
 	if (!skb)
 		goto nodata;
 
 	/* Make room for the chunk header.  */
-	chunk_hdr = skb_put(skb, sizeof(sctp_chunkhdr_t));
+	chunk_hdr = (struct sctp_chunkhdr *)skb_put(skb, sizeof(*chunk_hdr));
 	chunk_hdr->type	  = type;
 	chunk_hdr->flags  = flags;
-	chunk_hdr->length = htons(sizeof(sctp_chunkhdr_t));
+	chunk_hdr->length = htons(sizeof(*chunk_hdr));
 
 	sk = asoc ? asoc->base.sk : NULL;
 	retval = sctp_chunkify(skb, asoc, sk, gfp);
@@ -1402,7 +1402,7 @@ static struct sctp_chunk *_sctp_make_chunk(const struct sctp_association *asoc,
 	}
 
 	retval->chunk_hdr = chunk_hdr;
-	retval->chunk_end = ((__u8 *)chunk_hdr) + sizeof(struct sctp_chunkhdr);
+	retval->chunk_end = ((__u8 *)chunk_hdr) + sizeof(*chunk_hdr);
 
 	/* Determine if the chunk needs to be authenticated */
 	if (sctp_auth_send_cid(type, asoc))
@@ -1710,7 +1710,7 @@ struct sctp_association *sctp_unpack_cookie(
 	/* Header size is static data prior to the actual cookie, including
 	 * any padding.
 	 */
-	headersize = sizeof(sctp_chunkhdr_t) +
+	headersize = sizeof(struct sctp_chunkhdr) +
 		     (sizeof(struct sctp_signed_cookie) -
 		      sizeof(struct sctp_cookie));
 	bodysize = ntohs(chunk->chunk_hdr->length) - headersize;
@@ -3218,7 +3218,8 @@ struct sctp_chunk *sctp_process_asconf(struct sctp_association *asoc,
 	int	chunk_len;
 	__u32	serial;
 
-	chunk_len = ntohs(asconf->chunk_hdr->length) - sizeof(sctp_chunkhdr_t);
+	chunk_len = ntohs(asconf->chunk_hdr->length) -
+		    sizeof(struct sctp_chunkhdr);
 	hdr = (sctp_addiphdr_t *)asconf->skb->data;
 	serial = ntohl(hdr->serial);
 
@@ -3364,7 +3365,7 @@ static __be16 sctp_get_asconf_response(struct sctp_chunk *asconf_ack,
 		err_code = SCTP_ERROR_REQ_REFUSED;
 
 	asconf_ack_len = ntohs(asconf_ack->chunk_hdr->length) -
-			     sizeof(sctp_chunkhdr_t);
+			 sizeof(struct sctp_chunkhdr);
 
 	/* Skip the addiphdr from the asconf_ack chunk and store a pointer to
 	 * the first asconf_ack parameter.
diff --git a/net/sctp/sm_sideeffect.c b/net/sctp/sm_sideeffect.c
index dfe1fcb..b255339 100644
--- a/net/sctp/sm_sideeffect.c
+++ b/net/sctp/sm_sideeffect.c
@@ -955,9 +955,10 @@ static void sctp_cmd_process_operr(sctp_cmd_seq_t *cmds,
 		switch (err_hdr->cause) {
 		case SCTP_ERROR_UNKNOWN_CHUNK:
 		{
-			sctp_chunkhdr_t *unk_chunk_hdr;
+			struct sctp_chunkhdr *unk_chunk_hdr;
 
-			unk_chunk_hdr = (sctp_chunkhdr_t *)err_hdr->variable;
+			unk_chunk_hdr = (struct sctp_chunkhdr *)
+							err_hdr->variable;
 			switch (unk_chunk_hdr->type) {
 			/* ADDIP 4.1 A9) If the peer responds to an ASCONF with
 			 * an ERROR chunk reporting that it did not recognized
diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index 8feff96..2b7c07f 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -235,7 +235,7 @@ sctp_disposition_t sctp_sf_do_4_C(struct net *net,
 		return sctp_sf_violation_chunk(net, ep, asoc, type, arg, commands);
 
 	/* Make sure that the SHUTDOWN_COMPLETE chunk has a valid length. */
-	if (!sctp_chunk_length_valid(chunk, sizeof(sctp_chunkhdr_t)))
+	if (!sctp_chunk_length_valid(chunk, sizeof(struct sctp_chunkhdr)))
 		return sctp_sf_violation_chunklen(net, ep, asoc, type, arg,
 						  commands);
 
@@ -368,9 +368,9 @@ sctp_disposition_t sctp_sf_do_5_1B_init(struct net *net,
 		if (err_chunk) {
 			packet = sctp_abort_pkt_new(net, ep, asoc, arg,
 					(__u8 *)(err_chunk->chunk_hdr) +
-					sizeof(sctp_chunkhdr_t),
+					sizeof(struct sctp_chunkhdr),
 					ntohs(err_chunk->chunk_hdr->length) -
-					sizeof(sctp_chunkhdr_t));
+					sizeof(struct sctp_chunkhdr));
 
 			sctp_chunk_free(err_chunk);
 
@@ -417,7 +417,7 @@ sctp_disposition_t sctp_sf_do_5_1B_init(struct net *net,
 	len = 0;
 	if (err_chunk)
 		len = ntohs(err_chunk->chunk_hdr->length) -
-			sizeof(sctp_chunkhdr_t);
+		      sizeof(struct sctp_chunkhdr);
 
 	repl = sctp_make_init_ack(new_asoc, chunk, GFP_ATOMIC, len);
 	if (!repl)
@@ -437,7 +437,7 @@ sctp_disposition_t sctp_sf_do_5_1B_init(struct net *net,
 		 */
 		unk_param = (sctp_unrecognized_param_t *)
 			    ((__u8 *)(err_chunk->chunk_hdr) +
-			    sizeof(sctp_chunkhdr_t));
+			    sizeof(struct sctp_chunkhdr));
 		/* Replace the cause code with the "Unrecognized parameter"
 		 * parameter type.
 		 */
@@ -540,9 +540,9 @@ sctp_disposition_t sctp_sf_do_5_1C_ack(struct net *net,
 		if (err_chunk) {
 			packet = sctp_abort_pkt_new(net, ep, asoc, arg,
 					(__u8 *)(err_chunk->chunk_hdr) +
-					sizeof(sctp_chunkhdr_t),
+					sizeof(struct sctp_chunkhdr),
 					ntohs(err_chunk->chunk_hdr->length) -
-					sizeof(sctp_chunkhdr_t));
+					sizeof(struct sctp_chunkhdr));
 
 			sctp_chunk_free(err_chunk);
 
@@ -673,7 +673,7 @@ sctp_disposition_t sctp_sf_do_5_1D_ce(struct net *net,
 	 * chunk header.  More detailed verification is done
 	 * in sctp_unpack_cookie().
 	 */
-	if (!sctp_chunk_length_valid(chunk, sizeof(sctp_chunkhdr_t)))
+	if (!sctp_chunk_length_valid(chunk, sizeof(struct sctp_chunkhdr)))
 		return sctp_sf_pdiscard(net, ep, asoc, type, arg, commands);
 
 	/* If the endpoint is not listening or if the number of associations
@@ -691,7 +691,7 @@ sctp_disposition_t sctp_sf_do_5_1D_ce(struct net *net,
 	chunk->subh.cookie_hdr =
 		(struct sctp_signed_cookie *)chunk->skb->data;
 	if (!pskb_pull(chunk->skb, ntohs(chunk->chunk_hdr->length) -
-					 sizeof(sctp_chunkhdr_t)))
+					 sizeof(struct sctp_chunkhdr)))
 		goto nomem;
 
 	/* 5.1 D) Upon reception of the COOKIE ECHO chunk, Endpoint
@@ -770,9 +770,10 @@ sctp_disposition_t sctp_sf_do_5_1D_ce(struct net *net,
 		auth.skb = chunk->auth_chunk;
 		auth.asoc = chunk->asoc;
 		auth.sctp_hdr = chunk->sctp_hdr;
-		auth.chunk_hdr = skb_push(chunk->auth_chunk,
-					  sizeof(sctp_chunkhdr_t));
-		skb_pull(chunk->auth_chunk, sizeof(sctp_chunkhdr_t));
+		auth.chunk_hdr = (struct sctp_chunkhdr *)
+					skb_push(chunk->auth_chunk,
+						 sizeof(struct sctp_chunkhdr));
+		skb_pull(chunk->auth_chunk, sizeof(struct sctp_chunkhdr));
 		auth.transport = chunk->transport;
 
 		ret = sctp_sf_authenticate(net, ep, new_asoc, type, &auth);
@@ -886,7 +887,7 @@ sctp_disposition_t sctp_sf_do_5_1E_ca(struct net *net,
 	/* Verify that the chunk length for the COOKIE-ACK is OK.
 	 * If we don't do this, any bundled chunks may be junked.
 	 */
-	if (!sctp_chunk_length_valid(chunk, sizeof(sctp_chunkhdr_t)))
+	if (!sctp_chunk_length_valid(chunk, sizeof(struct sctp_chunkhdr)))
 		return sctp_sf_violation_chunklen(net, ep, asoc, type, arg,
 						  commands);
 
@@ -1099,7 +1100,7 @@ sctp_disposition_t sctp_sf_beat_8_3(struct net *net,
 	 */
 	chunk->subh.hb_hdr = (sctp_heartbeathdr_t *) chunk->skb->data;
 	param_hdr = (sctp_paramhdr_t *) chunk->subh.hb_hdr;
-	paylen = ntohs(chunk->chunk_hdr->length) - sizeof(sctp_chunkhdr_t);
+	paylen = ntohs(chunk->chunk_hdr->length) - sizeof(struct sctp_chunkhdr);
 
 	if (ntohs(param_hdr->length) > paylen)
 		return sctp_sf_violation_paramlen(net, ep, asoc, type, arg,
@@ -1164,7 +1165,7 @@ sctp_disposition_t sctp_sf_backbeat_8_3(struct net *net,
 		return sctp_sf_pdiscard(net, ep, asoc, type, arg, commands);
 
 	/* Make sure that the HEARTBEAT-ACK chunk has a valid length.  */
-	if (!sctp_chunk_length_valid(chunk, sizeof(sctp_chunkhdr_t) +
+	if (!sctp_chunk_length_valid(chunk, sizeof(struct sctp_chunkhdr) +
 					    sizeof(sctp_sender_hb_info_t)))
 		return sctp_sf_violation_chunklen(net, ep, asoc, type, arg,
 						  commands);
@@ -1469,9 +1470,9 @@ static sctp_disposition_t sctp_sf_do_unexpected_init(
 		if (err_chunk) {
 			packet = sctp_abort_pkt_new(net, ep, asoc, arg,
 					(__u8 *)(err_chunk->chunk_hdr) +
-					sizeof(sctp_chunkhdr_t),
+					sizeof(struct sctp_chunkhdr),
 					ntohs(err_chunk->chunk_hdr->length) -
-					sizeof(sctp_chunkhdr_t));
+					sizeof(struct sctp_chunkhdr));
 
 			if (packet) {
 				sctp_add_cmd_sf(commands, SCTP_CMD_SEND_PKT,
@@ -1535,7 +1536,7 @@ static sctp_disposition_t sctp_sf_do_unexpected_init(
 	len = 0;
 	if (err_chunk) {
 		len = ntohs(err_chunk->chunk_hdr->length) -
-			sizeof(sctp_chunkhdr_t);
+		      sizeof(struct sctp_chunkhdr);
 	}
 
 	repl = sctp_make_init_ack(new_asoc, chunk, GFP_ATOMIC, len);
@@ -1556,7 +1557,7 @@ static sctp_disposition_t sctp_sf_do_unexpected_init(
 		 */
 		unk_param = (sctp_unrecognized_param_t *)
 			    ((__u8 *)(err_chunk->chunk_hdr) +
-			    sizeof(sctp_chunkhdr_t));
+			    sizeof(struct sctp_chunkhdr));
 		/* Replace the cause code with the "Unrecognized parameter"
 		 * parameter type.
 		 */
@@ -2044,7 +2045,7 @@ sctp_disposition_t sctp_sf_do_5_2_4_dupcook(struct net *net,
 	 * enough for the chunk header.  Cookie length verification is
 	 * done later.
 	 */
-	if (!sctp_chunk_length_valid(chunk, sizeof(sctp_chunkhdr_t)))
+	if (!sctp_chunk_length_valid(chunk, sizeof(struct sctp_chunkhdr)))
 		return sctp_sf_violation_chunklen(net, ep, asoc, type, arg,
 						  commands);
 
@@ -2053,7 +2054,7 @@ sctp_disposition_t sctp_sf_do_5_2_4_dupcook(struct net *net,
 	 */
 	chunk->subh.cookie_hdr = (struct sctp_signed_cookie *)chunk->skb->data;
 	if (!pskb_pull(chunk->skb, ntohs(chunk->chunk_hdr->length) -
-					sizeof(sctp_chunkhdr_t)))
+					sizeof(struct sctp_chunkhdr)))
 		goto nomem;
 
 	/* In RFC 2960 5.2.4 3, if both Verification Tags in the State Cookie
@@ -2806,7 +2807,7 @@ sctp_disposition_t sctp_sf_do_9_2_reshutack(struct net *net,
 	struct sctp_chunk *reply;
 
 	/* Make sure that the chunk has a valid length */
-	if (!sctp_chunk_length_valid(chunk, sizeof(sctp_chunkhdr_t)))
+	if (!sctp_chunk_length_valid(chunk, sizeof(struct sctp_chunkhdr)))
 		return sctp_sf_violation_chunklen(net, ep, asoc, type, arg,
 						  commands);
 
@@ -3358,7 +3359,7 @@ sctp_disposition_t sctp_sf_do_9_2_final(struct net *net,
 		return sctp_sf_pdiscard(net, ep, asoc, type, arg, commands);
 
 	/* Make sure that the SHUTDOWN_ACK chunk has a valid length. */
-	if (!sctp_chunk_length_valid(chunk, sizeof(sctp_chunkhdr_t)))
+	if (!sctp_chunk_length_valid(chunk, sizeof(struct sctp_chunkhdr)))
 		return sctp_sf_violation_chunklen(net, ep, asoc, type, arg,
 						  commands);
 	/* 10.2 H) SHUTDOWN COMPLETE notification
@@ -3435,7 +3436,7 @@ sctp_disposition_t sctp_sf_ootb(struct net *net,
 {
 	struct sctp_chunk *chunk = arg;
 	struct sk_buff *skb = chunk->skb;
-	sctp_chunkhdr_t *ch;
+	struct sctp_chunkhdr *ch;
 	sctp_errhdr_t *err;
 	__u8 *ch_end;
 	int ootb_shut_ack = 0;
@@ -3443,10 +3444,10 @@ sctp_disposition_t sctp_sf_ootb(struct net *net,
 
 	SCTP_INC_STATS(net, SCTP_MIB_OUTOFBLUES);
 
-	ch = (sctp_chunkhdr_t *) chunk->chunk_hdr;
+	ch = (struct sctp_chunkhdr *)chunk->chunk_hdr;
 	do {
 		/* Report violation if the chunk is less then minimal */
-		if (ntohs(ch->length) < sizeof(sctp_chunkhdr_t))
+		if (ntohs(ch->length) < sizeof(*ch))
 			return sctp_sf_violation_chunklen(net, ep, asoc, type, arg,
 						  commands);
 
@@ -3487,7 +3488,7 @@ sctp_disposition_t sctp_sf_ootb(struct net *net,
 			}
 		}
 
-		ch = (sctp_chunkhdr_t *) ch_end;
+		ch = (struct sctp_chunkhdr *)ch_end;
 	} while (ch_end < skb_tail_pointer(skb));
 
 	if (ootb_shut_ack)
@@ -3560,7 +3561,7 @@ static sctp_disposition_t sctp_sf_shut_8_4_5(struct net *net,
 	/* If the chunk length is invalid, we don't want to process
 	 * the reset of the packet.
 	 */
-	if (!sctp_chunk_length_valid(chunk, sizeof(sctp_chunkhdr_t)))
+	if (!sctp_chunk_length_valid(chunk, sizeof(struct sctp_chunkhdr)))
 		return sctp_sf_pdiscard(net, ep, asoc, type, arg, commands);
 
 	/* We need to discard the rest of the packet to prevent
@@ -3591,7 +3592,7 @@ sctp_disposition_t sctp_sf_do_8_5_1_E_sa(struct net *net,
 	struct sctp_chunk *chunk = arg;
 
 	/* Make sure that the SHUTDOWN_ACK chunk has a valid length. */
-	if (!sctp_chunk_length_valid(chunk, sizeof(sctp_chunkhdr_t)))
+	if (!sctp_chunk_length_valid(chunk, sizeof(struct sctp_chunkhdr)))
 		return sctp_sf_violation_chunklen(net, ep, asoc, type, arg,
 						  commands);
 
@@ -4256,7 +4257,7 @@ sctp_disposition_t sctp_sf_unk_chunk(struct net *net,
 {
 	struct sctp_chunk *unk_chunk = arg;
 	struct sctp_chunk *err_chunk;
-	sctp_chunkhdr_t *hdr;
+	struct sctp_chunkhdr *hdr;
 
 	pr_debug("%s: processing unknown chunk id:%d\n", __func__, type.chunk);
 
@@ -4267,7 +4268,7 @@ sctp_disposition_t sctp_sf_unk_chunk(struct net *net,
 	 * Since we don't know the chunk type, we use a general
 	 * chunkhdr structure to make a comparison.
 	 */
-	if (!sctp_chunk_length_valid(unk_chunk, sizeof(sctp_chunkhdr_t)))
+	if (!sctp_chunk_length_valid(unk_chunk, sizeof(*hdr)))
 		return sctp_sf_violation_chunklen(net, ep, asoc, type, arg,
 						  commands);
 
@@ -4340,7 +4341,7 @@ sctp_disposition_t sctp_sf_discard_chunk(struct net *net,
 	 * Since we don't know the chunk type, we use a general
 	 * chunkhdr structure to make a comparison.
 	 */
-	if (!sctp_chunk_length_valid(chunk, sizeof(sctp_chunkhdr_t)))
+	if (!sctp_chunk_length_valid(chunk, sizeof(struct sctp_chunkhdr)))
 		return sctp_sf_violation_chunklen(net, ep, asoc, type, arg,
 						  commands);
 
@@ -4405,7 +4406,7 @@ sctp_disposition_t sctp_sf_violation(struct net *net,
 	struct sctp_chunk *chunk = arg;
 
 	/* Make sure that the chunk has a valid length. */
-	if (!sctp_chunk_length_valid(chunk, sizeof(sctp_chunkhdr_t)))
+	if (!sctp_chunk_length_valid(chunk, sizeof(struct sctp_chunkhdr)))
 		return sctp_sf_violation_chunklen(net, ep, asoc, type, arg,
 						  commands);
 
diff --git a/net/sctp/ulpevent.c b/net/sctp/ulpevent.c
index 17854fb..5f86c50 100644
--- a/net/sctp/ulpevent.c
+++ b/net/sctp/ulpevent.c
@@ -158,7 +158,7 @@ struct sctp_ulpevent  *sctp_ulpevent_make_assoc_change(
 		/* Trim the buffer to the right length.  */
 		skb_trim(skb, sizeof(struct sctp_assoc_change) +
 			 ntohs(chunk->chunk_hdr->length) -
-			 sizeof(sctp_chunkhdr_t));
+			 sizeof(struct sctp_chunkhdr));
 	} else {
 		event = sctp_ulpevent_new(sizeof(struct sctp_assoc_change),
 				  MSG_NOTIFICATION, gfp);
-- 
2.1.0
